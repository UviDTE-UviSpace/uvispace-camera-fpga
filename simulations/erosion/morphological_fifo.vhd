------------------------------------------------------------------------
-- morphological_fifo
------------------------------------------------------------------------
-- morphological_fifo is a memory that stores the lines needed to 
-- perform a morphological operation to an image. Its output is the 
-- pixels of the moving window that in conjuction with a kernel will 
-- be used to perform the morphological operation. The size of the 
-- moving window is KERN_SIZE x KERN_SIZE. PIX_SIZE is the number of bits
-- per pixel (1 for binary, 8 for 8-bit gray, and so on). 
-- The moving window size in this component is fixed on compilation time, 
-- but the width of the input image is not. The width is pased as a
-- parameter called img_width. This permits to change the resolution
-- of the image used without the need to recompile the hardware.
-- MAX_IMG_WIDTH specifies the maximum img_with that can be used because
-- it defines the depht of the internal buffers. User should set this 
-- parameter as the witdh of the biggest resolution that will be used.
-- As usual, data_valid is used to know when a pixel is valid in the 
-- input and data_valid_out does the same for the output.
------------------------------------------------------------------------
library IEEE;
	use IEEE.STD_LOGIC_1164.ALL;
	use ieee.math_real.all;          -- For using ceil and log2.
	use IEEE.NUMERIC_STD.all;        -- For using to_unsigned.
	use ieee.std_logic_unsigned.all; -- Needed for the sum used in counter.

LIBRARY work;
	use work.array_package.all;
	
entity morphological_fifo is
    generic (
        --Basic configuration of the component
		    -- Size of each pixel (binary image by default)
          PIX_SIZE  : integer := 1;
		    --Size of the kernel moving along the image (3x3 by default)
			 KERN_SIZE : integer := 3;
		  --Advanced features
		    --Maximum line img_width
			 --Default resolution is 640x480 so max width is 640.
		    MAX_IMG_WIDTH : integer := 640
    );
    port (
        -- Clock and reset.
        clk             : in STD_LOGIC;
        reset_n         : in STD_LOGIC;
        
		  -- Configuration
		  img_width   :in STD_LOGIC_VECTOR(15 downto 0);
		  
        -- Input image and sync signals
        pix		     : in STD_LOGIC_VECTOR((PIX_SIZE - 1) downto 0);--one pixel
		  data_valid  : in STD_LOGIC; --there is a valid pixel in pix
		  frame_valid : in STD_LOGIC;
		 
        -- Output signal is the moving window to do the morphological operation
		  moving_window    : array2D_of_std_logic_vector((KERN_SIZE-1) downto 0)((KERN_SIZE-1)  downto 0)((PIX_SIZE-1) downto 0);
		  window_valid     : array2D_of_std_logic_vector((KERN_SIZE-1) downto 0)((KERN_SIZE-1)  downto 0)((PIX_SIZE-1) downto 0);
		  data_valid_out   : out STD_LOGIC; 
		  frame_valid_out  : in STD_LOGIC;
    );
end morphological_fifo;

architecture arch of erosion is
	--Variables for the state machine
	  constant NUMBER_OF_STATES   : INTEGER := 4;
    --signals for the evolution of the state machine
    signal current_state        : INTEGER range 0 to (NUMBER_OF_STATES - 1);
    signal next_state           : INTEGER range 0 to (NUMBER_OF_STATES - 1);
    -- Conditions to change next state.
    -- State_condition(x) condition to go from x to x+1.
    signal state_condition      : STD_LOGIC_VECTOR((NUMBER_OF_STATES - 2)
                                    downto 0);
	 signal condition_3_to_2     : STD_LOGIC; 
	 -- the output image starts and ends KERN_SIZE-1 lines delayed with respect to
	 -- the input image. This variable flags that moment to generate a delayed
	 -- version of frame buffer
	 signal end_of_output_img    : STD_LOGIC; 
    --counters.
		--Counts pixels in each line
    signal pix_counter          : STD_LOGIC_VECTOR(23 downto 0);
	 signal line_end_reached	  : STD_LOGIC; 
	   --Counts lines
	 signal line_counter         : STD_LOGIC_VECTOR(23 downto 0);
    signal image_end_reached    : STD_LOGIC;
	   --Counts the number of cycles that the out_frame_valid will last
	 signal wait_counter         : STD_LOGIC_VECTOR(23 downto 0);
    signal wait_end_reached     : STD_LOGIC;
	 constant FRAME_VALID_TIME   : INTEGER := 10; --clock cycles
	
	
	--Variables to save pixels needed to show the moving window
	--pix_buff stores (KERN_SIZE-1) previous lines
	 SIGNAL pix_buff :array2D_of_std_logic_vector((KERN_SIZE-2) downto 0)((MAX_WIDTH-1) downto 0)((PIX_SIZE-1) downto 0);
	 --pix_buff_last stores last values and needs to be only KERN_SIZE depth
	 SIGNAL pix_buff_last:array_of_std_logic_vector((KERN_SIZE-1) downto 0)((PIX_SIZE-1) downto 0);

begin

------------------------------STATE MACHINE---------------------
	-- FSM (Finite State Machine) clocking and reset.
	 fsm_mem: process (clk)
    begin
        if rising_edge(clk) then
            if reset_n = '0' then 
                current_state <= 0;
            else
                current_state <= next_state;
            end if;
        end if;
    end process fsm_mem;

    -- Evolution of FSM.
    comb_fsm: process (current_state, state_condition, condition_3_to_2)
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
                if state_condition(2) = '1' then
                    next_state <= 3;
                else
                    next_state<=2;
                end if;
            when 3 =>
                if condition_3_to_2 = '1' then
                    next_state <= 1;
                else
                    next_state<=2;
                end if;
            when others =>
                next_state <= 0;
        end case;
    end process comb_fsm;
	 
	 -- Conditions of FSM.
	 state_condition(0) <= frame_valid;
    state_condition(1) <= end_of_output_img;
    state_condition(2) <= wait_end_reached;
    condition_3_to_2   <= end_of_output_img;
	 
	 end_of_output_img <= 
	 
	 -- Evaluation and update pix_counter.
    pix_counter_proc:process (clk)
    begin
        if rising_edge(clk) then
            if (current_state = 0) or (line_end_reached = '1') then
                -- reset the pixel counter
                pix_counter <= (others => '0');
            elsif (data_valid = '1') then
                 -- Increment the pixel counter
                pix_counter <= pix_counter + 1;
            end if;
        end if;
        if pix_counter = img_width then
            line_end_reached <= '1';
        else
            line_end_reached <= '0';
        end if;
    end process;
	 
	 -- Evaluation and update line_counter.
    line_counter_proc:process (clk)
    begin
        if rising_edge(clk) then
            if (current_state = 0) or (image_end_reached = '1') then
                -- reset the pixel counter
                line_counter <= (others => '0');
            elsif (line_end_reached = '1') then
                 -- Increment the pixel counter
                line_counter <= line_counter + 1;
            end if;
        end if;
        if line_counter = img_height then
            image_end_reached <= '1';
        else
            image_end_reached <= '0';
        end if;
    end process;
	 
	 -- Evaluation and update wait_counter.
	 wait_counter_proc:process (clk)
    begin
        if rising_edge(clk) then
            if (current_state = 0) or (wait_end_reached = '1') then
                -- reset the pixel counter
                wait_counter <= (others => '0');
            elsif (current_state = 2) then
                 -- Increment the pixel counter
                wait_counter <= wait_counter + 1;
            end if;
        end if;
        if wait_counter = FRAME_VALID_TIME then
            wait_end_reached <= '1';
        else
            wait_end_reached <= '0';
        end if;
    end process;


---------------------------SAVE DATA IN MEMORY------------------

	--Save the previous (KERN_SIZE) lines in memory
		--Full image width lines. They are (KERN_SIZE-1) lines
		Pix_buffer_generate: for LINE_I in 0 to (KERN_SIZE-2) generate
			Line_generate: for PIX_I in 0 to (MAX_WIDTH-1) generate
			
				Regular_lines: if LINE_I < (KERN_SIZE-2) generate
					Reg_line_regular_pixels: if PIX_I<(MAX_WIDTH-1) 
						Update_pix_proc: process(clk) begin
						if rising_edge(clk) then
							if reset_n = '1' then
								pix_buff(LINE_I)(PIX_I) <= (others => '0');
							elsif (current_state != 0) and (data_valid = '1') then
								if (PIX_I<(img_width-1)) then --regular pixels
									pix_buff(LINE_I)(PIX_I) <= pix_buff(LINE_I)(PIX_I+1);
								elsif (PIX_I=(img_width-1)) then --last pixel used in line
									pix_buff(LINE_I)(PIX_I) <= pix_buff(LINE_I+1)(0);
								else --not used pixel
									pix_buff(LINE_I)(PIX_I) <= (others => '0');
							end if;
						end if;
						end process;
					end generate Reg_line_regular_pixels
					
					Reg_line_last_pixel: if PIX_I=(MAX_WIDTH-1) 
						Update_pix_proc: process(clk) begin
						if rising_edge(clk) then
							if reset_n = '1' then 
								pix_buff(LINE_I)(PIX_I) <= (others => '0');
							elsif (current_state != 0) and (data_valid = '1') then
								if (PIX_I=(img_width-1)) then --last pixel used in line
									pix_buff(LINE_I)(PIX_I) <= pix_buff(LINE_I+1)(0);
								else --not used
									pix_buff(LINE_I)(PIX_I) <= (others => '0');
							end if;
						end if;
						end process;
					end generate Reg_line_last_pixel;
				end generate Regular_lines;
			
				Last_line: if LINE_I = (KERN_SIZE-2) generate
					Last_line_regular_pixels: if PIX_I<(MAX_WIDTH-1) 
						Update_pix_proc: process(clk) begin
						if rising_edge(clk) then
							if reset_n = '1' then 
								pix_buff(LINE_I)(PIX_I) <= (others => '0');
							elsif (current_state != 0) and (data_valid = '1') then
								if (PIX_I<(img_width-1)) then --regular pixels
									pix_buff(LINE_I)(PIX_I) <= pix_buff(LINE_I)(PIX_I+1);
								elsif (PIX_I=(img_width-1)) then --last pixel used in line
									pix_buff(LINE_I)(PIX_I) <= pix_buff_last(0);
								else
									pix_buff(LINE_I)(PIX_I) <= (others => '0');
								end if;
							end if;
						end if;
						end process;
					end generate Last_line_regular_pixels
				
					Last_line_last_pixel: if PIX_I=(MAX_WIDTH-1) 
						Update_pix_proc: process(clk) begin
						if rising_edge(clk) then
							if reset_n = '1' then 
								pix_buff(LINE_I)(PIX_I) <= (others => '0');
							elsif (current_state != 0) and (data_valid = '1') then
								if (PIX_I=(img_width-1)) then --last pixel used in line
									pix_buff(LINE_I)(PIX_I) <= pix_buff_last(0);
								else
									pix_buff(LINE_I)(PIX_I) <= (others => '0');
								end if;
							end if;
						end if;
						end process;
					end generate Last_line_last_pixel;
				end generate Last_line;
			
			end generate Line_generate;
		end generate Pix_buffer_generate;
		
		--Last line of the buffer only stores KERN_SIZE PIXELS
		Last_Line_generate: for PIX_I in 0 to (MAX_WIDTH-1) generate
			
			Regular_pixels: if PIX_I<(KERN_SIZE-1) generate
				Update_pix_proc: process(clk) begin
				if rising_edge(clk) then
					if reset_n = '1' then 
						pix_buff(LINE_I)(PIX_I) <= (others => '0');
					else if (current_state != 0) and (data_valid = '1') then
						pix_buff(LINE_I)(PIX_I) <= pix_buff(LINE_I)(PIX_I+1);
					end if;
				end if;
				end process;
			end generate Reg_line_regular_pixels;
			
			Last_pixel: if PIX_I=(KERN_SIZE-1) generate
				Update_pix_proc: process(clk) begin
				if rising_edge(clk) then
					if reset_n = '1' then 
						pix_buff(LINE_I)(PIX_I) <= (others => '0');
					else if (current_state != 0) and (data_valid = '1') then
						pix_buff(LINE_I)(PIX_I) <= pix;
					end if;
				end if;
				end process;
			end generate Last_pixel;
		end generate Line_generate;
		
	

----------------------------GENERATE OUTPUTS--------------------
	--Generate the data_valid output. It is one clock cycle delayed from input
	Data_valid_proc: process(clk) begin
		if rising_edge(clk) then
			if current_state = 0 then 
				data_valid_out <= (others => '0');
			else if (current state = 2) or (current_state = 3) then
				data_valid_out <= data_valid;
			end if;
		end if;
	end process;
		
	--The output frame buffer is active in state 2
	Frame_valid_proc: process(clk) begin
		if current_state = 2 then
			frame_valid_out <= '1';
		else
			frame_valid_out <= '0';
		end if;
	end process;

	--Map the moving_window output to the memory elements of the pix_buffer
	Mapping: for LINE_I in 0 to (KERN_SIZE-1) generate
		Line_generate: for PIX_I in 0 to (KERN_SIZE-1) generate
			Regular_lines: if LINE_I < (KERN_SIZE-1) generate 
				moving_window(LINE_I)(PIX_I) <= pix_buff(LINE_I)(PIX_I);
			end generate Regular_lines;
			Last_line: if LINE_I = (KERN_SIZE-1) generate 
				moving_window(LINE_I)(PIX_I) <= pix_buff_last(LINE_I)(PIX_I);
			end generate Last_line;
		end generate Line_generate;
	end generate Mapping;
	
	--The whole output window should usually be used but in the borders only 
	--some pixels are valid. The non valid pixels are from previous image
	--(top rows), next image (last rows), previous lines (last pixels in a )
	--line) or next line (). Only the pixels indicated in window_valid 
	--should be used in the outter morphological operation with the kernel.
	
end arch;