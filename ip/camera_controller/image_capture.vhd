------------------------------------------------------------------
-- image_capture component
------------------------------------------------------------------
-- This component is used to save an image in memory. It uses one
-- buffer in processor memory with addresses buff to do it.
-- When start_capture is asserted the component waits for the next
-- positive flank of frame valid to synchronize and start at the
-- beginning of a new image. Then, every time data_valid is
-- asserted the component packs the {R,G,B,Gray} components into a
-- 32-bit (when components are 8-bit) or 64-bit (when
-- components are 16-bit) word and writes it to the avalon bus.
-- It is supossed that the bus can react in a single
-- clock cycle to the writes because waitrequest signal of avalon
-- specification is not implemented. In case the slave bus cannot
-- react in a single cycle an Avalon FIFO should be implemented
-- in between the master of this component and the slave where
-- data is being written. The component starts writting in buff0.
-- When a line from the image is acquired buff0full signal is
-- asserted during 1 clock cycle. Next line is written into buff1.
-- When a line from the image is acquired again the bus asserts
-- buff1full line for 1 cycle. Next line is saved in buff0 again.
-- So the component goes writing odd lines in buff0 and even lines
-- in buff1 until all lines in one image (image_height) are acquired.
-- The processor (or whatever component processes acquired lines)
-- should empty one buffer before this component finishes
-- filling the other one so data is not lost.
------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.math_real.all;          -- For using ceil and log2.
use IEEE.NUMERIC_STD.all;        -- For using to_unsigned.
use ieee.std_logic_unsigned.all; -- Needed for the sum used in counter.

ENTITY image_capture IS
    GENERIC (
        -- Size of each color component in bits (8 or 16).
        COMPONENT_SIZE  : integer := 8;
		  -- Number of pixels per write in the output avalon bus (>=1)
        PIX_WR  : integer := 4
    );
    PORT (
        -- Clock and reset.
        clk             : IN STD_LOGIC;
        reset_n         : IN STD_LOGIC;
        
        -- Signals from the video stream representing one pixel in RGB and gray
        R               : IN STD_LOGIC_VECTOR((COMPONENT_SIZE - 1) downto 0);
        G               : IN STD_LOGIC_VECTOR((COMPONENT_SIZE - 1) downto 0);
        B               : IN STD_LOGIC_VECTOR((COMPONENT_SIZE - 1) downto 0);
        Gray            : IN STD_LOGIC_VECTOR((COMPONENT_SIZE - 1) downto 0);
        
        --Signals to control the component
        -- When fram_valid is 1, the image from camera is being aquired.
        frame_valid     : IN STD_LOGIC;
        data_valid      : IN STD_LOGIC; -- Valid pixel in R,G,B,Gray inputs.
        -- Signals to control this component (usually coming from avalon_camera)
        -- When start_capture is 1, start getting a new image.
        start_capture   : IN STD_LOGIC;
        -- Number of columns and rows in the input image array.
        image_size     : IN STD_LOGIC_VECTOR(23 downto 0);
        -- Image buffer address.
        buff           : IN STD_LOGIC_VECTOR(31 downto 0);
        -- Flag that indicates that the image has been captured 
		  -- (Active 1 clock cycle only).
        image_captured : OUT STD_LOGIC;
        -- Signal indicating standby state 
        --(outside of reset, waiting for flank in start_capture)
        standby         : OUT STD_LOGIC;
        
        -- Avalon MM Master port to save data into a memory.
        -- Byte adresses are multiples of 4 when accessing 32-bit data.
        address         : OUT STD_LOGIC_VECTOR(31 downto 0);
        write           : OUT STD_LOGIC;
        byteenable      : OUT STD_LOGIC_VECTOR(((PIX_WR*COMPONENT_SIZE)/2-1) downto 0);
        writedata       : OUT STD_LOGIC_VECTOR((PIX_WR*COMPONENT_SIZE*4-1) downto 0);
        waitrequest     : IN STD_LOGIC;
        burstcount      : OUT STD_LOGIC_VECTOR(6 downto 0)
    );
END image_capture;

ARCHITECTURE arch OF image_capture IS 
    type array_of_std_logic_vector is array(natural range <>) of std_logic_vector;
	 constant NUMBER_OF_STATES : INTEGER := 6;
    --signals for the evolution of the state machine
    SIGNAL current_state    : INTEGER range 0 to (NUMBER_OF_STATES - 1);
    SIGNAL next_state       : INTEGER range 0 to (NUMBER_OF_STATES - 1);
    -- Conditions to change next state.
    -- State_condition(x) condition to go from x to x+1.
    SIGNAL state_condition  : STD_LOGIC_VECTOR((NUMBER_OF_STATES - 2) downto 0);
    SIGNAL condition_5_to_1 : STD_LOGIC;
    --counters.
    SIGNAL pix_counter      : STD_LOGIC_VECTOR(23 downto 0);
    SIGNAL image_end_reached: STD_LOGIC;
	 SIGNAL pix_wr_counter   : STD_LOGIC_VECTOR(integer(ceil(log2(real(PIX_WR+1)))) downto 0);
    -- Write_buff: it saves the address where the next pixel will be saved.
    SIGNAL write_buff       : STD_LOGIC_VECTOR(31 downto 0);
	 SIGNAL av_write				 : STD_LOGIC; --internal copy of the write output signal
	 -- Extra buffers to pack the pixels and reduce the number of writes in bus
	 SIGNAL output_buff : array_of_std_logic_vector((PIX_WR-1) downto 0)((COMPONENT_SIZE*4-1) downto 0);
	 SIGNAL out_buff_EN		:STD_LOGIC_VECTOR((PIX_WR-1) downto 0);
	 --Packs input components into a single variable
	 SIGNAL input_data 		:STD_LOGIC_VECTOR((COMPONENT_SIZE*4-1) downto 0);
    -- captures a flank in start capture that comes from other clock region.
    SIGNAL start_capture_reg: STD_LOGIC;

BEGIN

    -- FSM (Finite State Machine) clocking and reset.
    fsm_mem: PROCESS (clk,reset_n)
    BEGIN
        IF rising_edge(clk) THEN
            IF reset_n='0' THEN current_state <= 0;
            ELSE
                current_state<=next_state;
            END IF;
        END IF;
    END PROCESS fsm_mem;

    -- Evolution of FSM.
    comb_fsm: PROCESS (current_state, state_condition, condition_5_to_1)
    BEGIN
        CASE current_state IS
            WHEN 0 =>
                IF state_condition(0) = '1' THEN next_state <= 1;
                ELSE next_state<=0; END IF;
            WHEN 1 =>
                IF state_condition(1) = '1' THEN next_state <= 2;
                ELSE next_state<=1; END IF;
            WHEN 2 =>
                IF state_condition(2) = '1' THEN next_state <= 3;
                ELSE next_state<=2; END IF;
            WHEN 3 =>
                IF state_condition(3) = '1' THEN next_state <= 4;
                ELSE next_state<=3; END IF;
            WHEN 4 =>
                IF state_condition(4) = '1' THEN next_state <= 5;
                ELSE next_state<=4; END IF;
				WHEN 5 =>
                IF condition_5_to_1 = '1' THEN next_state <= 1;
                ELSE next_state<=5; END IF;
            WHEN OTHERS =>
                next_state <= 0;
        END CASE;
    END PROCESS comb_fsm;

    -- Conditions of FSM.
    state_condition(0) <= '1';
    state_condition(1) <= start_capture_reg;
    state_condition(2) <= not(frame_valid);
    state_condition(3) <= frame_valid;
    state_condition(4) <= image_end_reached;
    condition_5_to_1   <= '1';
    
    -- Evaluation and update pix_counter.
    pix_counter_proc:process (clk, current_state, data_valid)
    begin
        if rising_edge(clk) then
            if (current_state = 1) then
                pix_counter <= (others => '0'); --reset ctr
            elsif (current_state = 4) and (data_valid = '1') then -- ctr incremented
                pix_counter <= pix_counter + 1;
            end if;
        end if;
        if pix_counter = image_size(23 downto 0) then
            image_end_reached <= '1';
        else
            image_end_reached <= '0';
        end if;
    end process;
	 
	 -- Evaluation and update pix_wr_counter.
	 pix_wr_counter_proc:process (clk)
    begin
        if rising_edge(clk) then
            if (current_state = 1) then
                pix_wr_counter <= (others => '0'); --reset ctr
            elsif (current_state = 4) and (data_valid = '1') then -- ctr incremented
					if pix_wr_counter = (PIX_WR-1) then
						pix_wr_counter <= (others => '0');
					else
						pix_wr_counter <= pix_wr_counter + 1;
					end if;
            end if;
        end if;
    end process;

    -- Generate standby signal
    WITH current_state SELECT standby <=
        '1' WHEN 1,
        '0' WHEN OTHERS;
		  
	 -- Generate image_captured signal
    WITH current_state SELECT image_captured <=
        '1' WHEN 5,
        '0' WHEN OTHERS;
        
    -- Save data in extra output buffers
	 input_data <= Gray & B & G & R;
	 out_buff_generate: for I in 0 to (PIX_WR-1) generate
			output_buff_proc: process (clk)
			begin	
				if rising_edge(clk) then
					if current_state = 0 or current_state = 1 then
						output_buff(I) <= (others => '0');
					elsif(out_buff_EN(I)='1') then
						output_buff(I) <= input_data;
					end if;
				end if;
			end process;
				
			out_buff_EN_proc: process (clk, data_valid, pix_wr_counter, current_state)
			begin
				if (data_valid = '1') and (pix_wr_counter = I) and (current_state = 4) then
					out_buff_EN(I) <= '1';
				else
					out_buff_EN(I) <= '0';
				end if;
			end process;
	 end generate out_buff_generate;	
	 
	 --Generate Avalon signals
		--write data
	 write_data_generate : for I in 0 to (PIX_WR-1) generate
		writedata(((I+1)*4*COMPONENT_SIZE-1) downto (I*4*COMPONENT_SIZE)) <= output_buff(I);
	 end generate write_data_generate;
		--byteenable
	 byteenable <= (others => '1'); 
		--burstcount
	 burstcount <= "0000001"; --always single transactions (no burst)
    	--write
	 write_proc: process (clk)
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
	 write <= av_write;
		--address 
    buff_proc:process (clk)
    begin
        if rising_edge(clk) then
            if current_state = 1 then --reset signals to initial values
                write_buff <= buff;
            elsif av_write = '1' then
                write_buff <= write_buff + (PIX_WR*COMPONENT_SIZE/2);
            end if;
        end if;
    end process;
	 address <= write_buff;

    -- Detection of a flank in start_capture. This signal is coming from the
    -- processor and could have different clock. That's why flank is detected
    -- instead of level.
    start_capture_reg_proc:process(start_capture, current_state)
    begin
        if (current_state = 2 or current_state = 0) then
            start_capture_reg <= '0';
        elsif rising_edge(start_capture) then
            start_capture_reg <= '1';
        end if;
    end process;
END arch;
