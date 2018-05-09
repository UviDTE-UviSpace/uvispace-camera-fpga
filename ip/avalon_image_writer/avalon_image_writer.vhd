------------------------------------------------------------------------
-- avalon_image_writer component
------------------------------------------------------------------------
-- This component is used to save an image in memory. 
-- It saves it in buffers in processor memory at address buff0 or buff1. 
-- It has 2 modes: SINGLE SHOT mode and CONTINUOUS mode. 
--
-- In SINGLE SHOT mode the user writes a 1 in start_capture register and 
-- the component waits until the next image starts (synchronization) and 
-- saves the image in memory. User can check the standby register to know
-- when the image finished. Using the buffer_select register the user 
-- can choose where the image will be saved: buff0 or buff1. SINGLE SHOT
-- is useful to take a picture.
--
-- In CONTINUOUS MODE the user writes a 1 in start_capture register
-- to start a continuous aquisition to memory. The component goes saving
-- all images into memory so the processor does not have to wait for 
-- sinchronization and for the image to be captured. Therefore the CPU 
-- has the last image in memory and can process it inmediately. With the 
-- cont_double_buff register the user can choose if using 1 or 2
-- buffers. When using 1 the component will save all images in the 
-- buffer pointed by buff_select. Otherwise it will alternate and save
-- images 0, 2, 4... in buff0 and images 1, 3, 5 to buff1. The register
-- last_buff indicates the buffer containing the last image. CPU should
-- always get the image pointed by last buff because while the CPU 
-- processes this image the component is saving a newer image in the other 
-- and the data corruption for simultaneous access is avoided.
-- CONTINUOUS mode is useful for streaming video or doing image processing
-- in CPU.
--
-- This component has the port input_data to input the pixels. Each
-- pixel is NUMBER_COMPONENTS of color components with COMPONENT_SIZE
-- bits each. 
-- To minimize the number of writings in system it packs input data 
-- and saves in memory PIX_WR pixels at a time.
-- The component also has the possibility of downsample the image. If
-- downsampling register is set to 1 all image is captured but if 2 is 
-- written only half of lines and rows will be captured (size in memory
-- is reduced by 4). When downsampling is 4 it is reduced 16 times and 
-- so on.
--
-- Lastly the component has an image counter starting from 0 after a 
-- reset and updating any time a new image finishes in the input.
-- It can be used to get how many images we miss from the CPU. It could 
-- be useful for debugging algorithms to know if the algorithm is 
-- so slow that we miss images.
------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.math_real.all;          -- For using ceil and log2.
use IEEE.NUMERIC_STD.all;        -- For using to_unsigned.
use ieee.std_logic_unsigned.all; -- Needed for the sum used in counter.

entity avalon_image_writer is
    generic (
        -- Size of each color component in bits (8 or 16).
        COMPONENT_SIZE  : integer := 8;
		  -- Number of components per pixel that you will 
		  --introduce in input_data (power of 2)
		  NUMBER_COMPONENTS : integer := 1;
        -- Number of pixels (all components) per write in the output avalon bus 
		  --(>=1)
        PIX_WR  : integer := 4
    );
    port (
        -- Clock and reset.
        clk             : in STD_LOGIC;
        reset_n         : in STD_LOGIC;
		  --stream reset only sets to 0 the pic and line counters 
		  --to synchronize with the stream in case it is reset 
		  --and save the configuration written by the processor. 
		  stream_reset_n  : in STD_LOGIC;
		  
		  -- Image size
		  img_width			: in STD_LOGIC_VECTOR(15 downto 0);
		  img_height		: in STD_LOGIC_VECTOR(15 downto 0);
        
        -- Signals from the video stream representing one pixel
        input_data		: in STD_LOGIC_VECTOR((NUMBER_COMPONENTS*COMPONENT_SIZE - 1) downto 0);
		 
        -- Signals to control the component
        -- When frame_valid is 1, the image from camera is being acquired.
        data_valid      : in STD_LOGIC; -- Valid pixel in R,G,B,Gray inputs.
        
		  -- Avalon MM Slave port to configure the component
		  S_address 		:in STD_LOGIC_VECTOR(3 downto 0);  --Address bus (4byte word addresses)
		  S_writedata		:in STD_LOGIC_VECTOR(31 downto 0); --Input data bus (4byte word)
		  S_readdata		:out STD_LOGIC_VECTOR(31 downto 0);--Output data bus (4byte word)
		  S_write			:in STD_LOGIC;	--Write signal
		  S_read				:in STD_LOGIC; --Read signal
			
        -- Avalon MM Master port to save data into a memory.
        -- Byte addresses are multiples of 4 when accessing 32-bit data.
        M_address         : out STD_LOGIC_VECTOR(31 downto 0);
        M_write           : out STD_LOGIC;
        M_byteenable      : out STD_LOGIC_VECTOR((PIX_WR*NUMBER_COMPONENTS*COMPONENT_SIZE/8 - 1)
                                               downto 0);
        M_writedata       : out STD_LOGIC_VECTOR((PIX_WR*NUMBER_COMPONENTS*COMPONENT_SIZE - 1)
                                               downto 0);
        M_waitrequest     : in STD_LOGIC;
        M_burstcount      : out STD_LOGIC_VECTOR(6 downto 0)
		  
		  	   
    );
end avalon_image_writer;

architecture arch of avalon_image_writer is
--Avalon slave

  --Internal register address map 
    --Mode permits to select between 2 modes: 
	   --A 0 in this register (default) selects "SINGLE SHOT" mode.
		--A 1 in this register selects "CONTINUOUS" mode.
	 constant MODE_ADDRESS            : integer := 0;
	 constant BUFF0_ADDRESS           : integer := 1;
	 constant BUFF1_ADDRESS           : integer := 2;
	 --In continuous mode selects saving in 1 buffer (write a 0 here, 
	 --the default after reset) or 2 buffers (write a 1 here)
	 constant CONT_DOUBLE_BUFF_ADDRESS: integer := 3;
	 --Number of the buffer where you wanna write next image (0 or 1)
	 --In CONTINUOUS mode writing in 2 buffers it is ignored cause
	 --the component alternates buff0 and buff1.
	 constant BUFFER_SELECT_ADDRESS  : integer  := 4;
	 -- Start the capure of image (SINGLE SHOT) or images (CONTINUOUS).
	 -- In SINGLE SHOT write a 1 here to save 1 image to memory. It 
	 -- automatically goes to 0 after writing a 1.
	 -- In CONTINUOUS MODE write a 1 here to start capturing all images
	 -- and write a 0 to stop the capture. 
	 constant START_CAPTURE_ADDRESS  : integer  := 5;
	 -- Signal indicating standby state 
    --(outside of reset, waiting for flank in start_capture)
	 --In SINGLE_SHOT mode it can be used after setting start_capture to 
	 --check if writting the image to memory finished
	 constant STANDBY_ADDRESS        : integer  := 6;
	 --Last buffer indicates which buffer was the last one written (0 or 1)
	 constant LAST_BUFFER_ADDRESS    : integer  := 7;
	 --Downsampling rate (1=get all image, 2=half of rows and columns so
	 --size is reduced by four, 4= one fourth of cols and rows are capture, 
	 --so on...)
	 constant DOWNSAMPLING_ADDRESS   : integer  := 8;
	 --Image counter
	 constant IMAGE_COUNTER_ADDRESS  : integer  := 9;
	 

	 
  --Associated registers
	 signal mode         	:STD_LOGIC;
	 signal buff0 		      :STD_LOGIC_VECTOR(31 downto 0);
	 signal buff1 		      :STD_LOGIC_VECTOR(31 downto 0);
	 signal cont_double_buff:STD_LOGIC;
	 signal buffer_select	:STD_LOGIC;
	 signal start_capture 	:STD_LOGIC;
	 signal standby		   :STD_LOGIC;
	 signal last_buffer		:STD_LOGIC;
	 signal downsampling    :STD_LOGIC_VECTOR(6 downto 0);
	 signal image_counter 	:STD_LOGIC_VECTOR(31 downto 0);
	 
  --Create macros for the modes (mode reg)
    constant SINGLE_SHOT   : STD_LOGIC := '0';
	 constant CONTINUOUS    : STD_LOGIC := '1';
--Create macros for cont_double_buff reg 
    constant SINGLE_BUFF   : STD_LOGIC := '0';
	 constant DOUBLE_BUFF   : STD_LOGIC := '1';
	 
  --Chip select
	 SIGNAL cs              : STD_LOGIC_VECTOR((2**4-1) downto 0);
	 
--Variables for the state machine that writes values in memory
	 type array_of_std_logic_vector is array(natural range <>) 
            of STD_LOGIC_VECTOR;
    constant NUMBER_OF_STATES   : INTEGER := 4;
    --signals for the evolution of the state machine
    signal current_state        : INTEGER range 0 to (NUMBER_OF_STATES - 1);
    signal next_state           : INTEGER range 0 to (NUMBER_OF_STATES - 1);
    -- Conditions to change next state.
    -- State_condition(x) condition to go from x to x+1.
    signal state_condition      : STD_LOGIC_VECTOR((NUMBER_OF_STATES - 2)
                                    downto 0);
	 signal condition_2_to_1     : STD_LOGIC; 
    --counters.
    signal pix_counter          : STD_LOGIC_VECTOR(15 downto 0) := (others => '0');
	 signal line_counter         : STD_LOGIC_VECTOR(15 downto 0) := (others => '0');
    signal pix_wr_counter       : STD_LOGIC_VECTOR(integer(
                                    ceil(log2(real(PIX_WR+1)))) downto 0);
	 signal downsamp_counter_pixels : STD_LOGIC_VECTOR(6 downto 0);
	 signal downsamp_counter_lines : STD_LOGIC_VECTOR(6 downto 0);
	 signal enable_saving        : STD_LOGIC;
	 signal reset_buffer_address : STD_LOGIC;
	 signal synchronized         : STD_LOGIC;
    -- Write_buff saves the address where the next pixel will be saved.
    signal write_buff           : STD_LOGIC_VECTOR(31 downto 0);
    -- Internal copy of the write output signal
    signal av_write             : STD_LOGIC;
     -- Extra buffers to pack the pixels and reduce the number of writes in bus
    signal output_buff          : array_of_std_logic_vector((PIX_WR - 1)
                                    downto 0) ((COMPONENT_SIZE*NUMBER_COMPONENTS-1) downto 0);
    signal out_buff_EN          :STD_LOGIC_VECTOR((PIX_WR - 1) downto 0);

begin

	--Chip select for Avalon slave registers
	cs_generate: for I in 0 to (2**4-1) generate
		cs(I) <= '1' when (I=S_address) else '0';
	end generate cs_generate;
	
	--Implement the logic of the registers connected to avalon slave
	avalon_slave: process (clk) begin
	if rising_edge(clk)  then
		if reset_n = '0' then --synchronous reset
		   --reset only the registers only written from bus
			mode <= '0';
			buff0 <= (others => '0');
			buff1 <= (others => '0');
			cont_double_buff  <= '0';
			buffer_select  <= '0';
			downsampling <= (others => '0');
		elsif S_write ='1' then --write operation
			if cs(MODE_ADDRESS)='1' then 
				mode <= S_writedata(0);
			elsif cs(BUFF0_ADDRESS)='1' then 
				buff0 <= S_writedata(31 downto 0);
			elsif cs(BUFF1_ADDRESS)='1' then 
				buff1 <= S_writedata(31 downto 0);
			elsif cs(CONT_DOUBLE_BUFF_ADDRESS)='1' then 
				cont_double_buff <= S_writedata(0);
			elsif cs(BUFFER_SELECT_ADDRESS)='1' then 
				buffer_select <= S_writedata(0);
			elsif cs(DOWNSAMPLING_ADDRESS)='1' then 
				downsampling <= S_writedata(6 downto 0);
			end if;	
	  end if;
	end if;
	if S_read ='1' then --read operation
		if cs(MODE_ADDRESS)='1' then 
			S_readdata <= (31 downto 1 => '0') & mode;
		elsif cs(BUFF0_ADDRESS)='1' then 
			S_readdata <= buff0;
		elsif cs(BUFF1_ADDRESS)='1' then 
			S_readdata <= buff1;
		elsif cs(CONT_DOUBLE_BUFF_ADDRESS)='1' then 
			S_readdata <= (31 downto 1 => '0') & cont_double_buff;
		elsif cs(BUFFER_SELECT_ADDRESS)='1' then 
			S_readdata <= (31 downto 1 => '0') & buffer_select;
		elsif cs(START_CAPTURE_ADDRESS)='1' then 
			S_readdata <= (31 downto 1 => '0') & start_capture;
		elsif cs(STANDBY_ADDRESS)='1' then 
			S_readdata <= (31 downto 1 => '0') & standby;
		elsif cs(LAST_BUFFER_ADDRESS)='1' then 
			S_readdata <= (31 downto 1 => '0') & last_buffer;
		elsif cs(DOWNSAMPLING_ADDRESS)='1' then 
			S_readdata <= (31 downto 7 => '0') & downsampling;
		elsif cs(IMAGE_COUNTER_ADDRESS)='1' then 
			S_readdata <= image_counter;
		else
			S_readdata <= (others => '0');
		end if;
	end if;
	end process avalon_slave;

    -- FSM (Finite State Machine) clocking and reset.
    fsm_mem: process (clk)
    begin
        if rising_edge(clk) then
            if (reset_n = '0' or stream_reset_n = '0') then 
                current_state <= 0;
            else
                current_state <= next_state;
            end if;
        end if;
    end process fsm_mem;

    -- Evolution of FSM.
    comb_fsm: process (current_state, state_condition, condition_2_to_1)
    begin
        case current_state is
            when 0 =>
                if state_condition(0) = '1' then 
                    next_state <= 1;
                else 
                    next_state <= 0;
                end if;
            when 1 =>
                if state_condition(1) = '1' then
                    next_state <= 2;
                else
                    next_state<=1;  
                end if;
            when 2 =>
                if condition_2_to_1 = '1' then
                    next_state <= 1;
                else
                    next_state<=2;
                end if;
            when others =>
                next_state <= 0;
        end case;
    end process comb_fsm;

    -- Conditions of FSM.
    state_condition(0) <= '1';
    state_condition(1) <= start_capture;
	 
    --Evaluation and update pix_counter and line_counter
    pix_counter_proc:process (clk)
	   variable end_of_image : std_ulogic;
		variable end_of_line : std_ulogic;
    begin
      if rising_edge(clk) then
		    
		  --Always count with pix and line counters
		  if (current_state = 0) then
		    pix_counter <= (others => '0');
			 line_counter <= (others => '0');
			 image_counter <= (others => '0');
			 end_of_image := '0';
			 end_of_line := '0';
		  elsif (data_valid = '1') then --new pixel in the input
			 if pix_counter = (img_width - 1) then 
			   pix_counter <= (others => '0'); 
				end_of_line := '1';
				if line_counter = (img_height - 1) then
				  line_counter <= (others => '0');
				  end_of_image := '1';
				  image_counter <= image_counter+1;
				else 
				  line_counter <= line_counter + 1;
				  end_of_image := '0';
				end if;
			 else
			   pix_counter <= pix_counter + 1;
				end_of_image := '0';
				end_of_line := '0';
		    end if;
		  end if;
		
        if (current_state = 1) then
			 downsamp_counter_pixels <= (others => '0');
			 downsamp_counter_lines <= (others => '0');
			 pix_wr_counter <= (others => '0');
			 condition_2_to_1 <= '0';
			 reset_buffer_address <= '0';
			 enable_saving <= '0';
        else
		    if (data_valid = '1') then --new pixel in the input
				--Generate the conditions to change state
				if (synchronized = '1') --at least 1 image captured at this point
				and (end_of_image = '1') 
				and (mode = SINGLE_SHOT or (mode = CONTINUOUS and start_capture = '0')) then
				  condition_2_to_1 <= '1';
				end if;
				--Generate signal to permit saving in registers
				if end_of_image = '1' then
				  enable_saving <= '1';
				end if;
			   --Generate downsampling counters and write counter (count only if savinf is enabled)
			   if enable_saving = '1' and data_valid = '1' then 
				  if end_of_image = '1' then
				    downsamp_counter_lines <= (others => '0');  
				  elsif end_of_line = '1' then 
					 if downsamp_counter_lines+1 = downsampling then
                  downsamp_counter_lines <= (others => '0');
                else
                  downsamp_counter_lines <= downsamp_counter_lines + 1;
                end if;
				  end if;

				  if end_of_line = '1' then
				    downsamp_counter_pixels <= (others => '0');
				  else
					 if downsamp_counter_pixels+1 = downsampling then
                  downsamp_counter_pixels <= (others => '0');
                else
                  downsamp_counter_pixels <= downsamp_counter_pixels + 1;
                end if;
				  end if;
				
				  if (downsamp_counter_pixels+1) = downsampling and 
				  (downsamp_counter_lines+1) = downsampling then 
				    if pix_wr_counter = (PIX_WR-1) then
                  pix_wr_counter <= (others => '0');
                else 
                  pix_wr_counter <= pix_wr_counter + 1;
                end if;
				  end if;
			   end if;
				--Update buffer address at the end of the image
				if (end_of_image = '1') then
				  reset_buffer_address <= '1';
				else
				  reset_buffer_address <= '0';
				end if;
				
			 end if;
        end if;
	   end if; 
    end process;

	 sync_proc:process (clk)
    begin
      if rising_edge(clk) then
        if (current_state = 1) then
			 synchronized <= '0';
		  elsif(data_valid = '1') and (current_state = 2) and enable_saving = '1' then
		    synchronized <= '1';
		  end if;
		end if;
	 end process;
	 
    -- Generate standby signal
    with current_state select standby <=
        '1' when 1,
        '0' when others;
		  
	--generate start_capture
	start_capture_proc:process (clk)
    begin
        if rising_edge(clk) then
            if (reset_n = '0') then
					start_capture <= '0';
				elsif mode = SINGLE_SHOT then
					if start_capture = '1' then 
				     start_capture <= '0';
					else
					  if S_write = '1' and cs(START_CAPTURE_ADDRESS) = '1' then 
					    start_capture <= S_writedata(0);
					  end if;
					end if;
            elsif mode = CONTINUOUS then
				     if S_write ='1' and cs(START_CAPTURE_ADDRESS)='1' then 
					    start_capture <= S_writedata(0);
					  end if;
            end if;
        end if;
    end process;
	 
	 
    -- Save data in extra output buffers 
    out_buff_generate: for I in 0 to (PIX_WR-1) generate
            output_buff_proc: process (clk)
            begin   
                if rising_edge(clk) then
                    if current_state = 0 or current_state = 1 then
                        output_buff(I) <= (others => '0');
                    elsif (out_buff_EN(I)='1') then
                        output_buff(I) <= input_data;
                    end if;
                end if;
            end process;
                
            out_buff_EN_proc: process (clk, data_valid, pix_wr_counter,
                                       current_state)
            begin
                if (data_valid = '1') and (pix_wr_counter = I) 
                        and (downsamp_counter_pixels+1) = downsampling 
								and (downsamp_counter_lines+1) = downsampling
								and (enable_saving = '1') then
                    out_buff_EN(I) <= '1';
                else
                    out_buff_EN(I) <= '0';
                end if;
            end process;
    end generate out_buff_generate;    
     
    --Generate Avalon signals
        --write data
    write_data_generate : for I in 0 to (PIX_WR-1) generate
        M_writedata(((I+1)*NUMBER_COMPONENTS*COMPONENT_SIZE - 1) 
		  downto (I*NUMBER_COMPONENTS*COMPONENT_SIZE)) <= 
                output_buff(I);
    end generate write_data_generate;
        --byteenable
     M_byteenable <= (others => '1'); 
        --burstcount
    -- Always single transactions (no burst)
     M_burstcount <= "0000001"; 
    -- write
     write_proc : process (clk)
    begin
        if rising_edge(clk) then
            if current_state = 0 or current_state = 1 then 
                av_write <= '0';
            elsif out_buff_EN(PIX_WR-1) = '1' then 
                av_write <= '1';
            else 
                av_write <= '0'; 
            end if;
        end if;
    end process;
    M_write <= av_write;
    -- address 
    buff_proc:process (clk)
    begin
        if rising_edge(clk) then
            if (reset_n = '0' or stream_reset_n = '0') then 
					write_buff <= (others => '0');
					last_buffer <= '0';
				elsif current_state = 1 then
				  --Initialize buffer
					 if mode = SINGLE_SHOT or (mode = CONTINUOUS and cont_double_buff = '0') then
						if buffer_select = '0' then
							write_buff <= buff0;
							last_buffer <= '0';
						else
							write_buff <= buff1;
							last_buffer <= '1';
						end if;
					else --mode = CONTINUOUS and cont_double_buff = '1'
						write_buff <= buff0;
						last_buffer <= '1';
					end if;
				elsif av_write = '1'  then
				    if reset_buffer_address = '1' and mode = CONTINUOUS and cont_double_buff = '1' then
						if last_buffer = '1' then
						   last_buffer <= '0';
							write_buff  <= buff1;
						else
						   last_buffer <= '1';
						   write_buff  <= buff0;
						end if;
					 elsif reset_buffer_address = '1' and mode = CONTINUOUS and cont_double_buff = '0' then
					   if last_buffer = '0' then
						   last_buffer <= '0';
							write_buff  <= buff0;
						else
						   last_buffer <= '1';
						   write_buff  <= buff1;
						end if;
				    else
				      write_buff <= write_buff + (PIX_WR*NUMBER_COMPONENTS*COMPONENT_SIZE/8);
					 end if;
				end if;
        end if;
    end process;
    M_address <= write_buff;
end arch;