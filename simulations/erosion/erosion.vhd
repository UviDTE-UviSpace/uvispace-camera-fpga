------------------------------------------------------------------------
-- erosion
------------------------------------------------------------------------
-- erosion
--
--
--
------------------------------------------------------------------------
library IEEE;
	use IEEE.STD_LOGIC_1164.ALL;
	use ieee.math_real.all;          -- For using ceil and log2.
	use IEEE.NUMERIC_STD.all;        -- For using to_unsigned.
	use ieee.std_logic_unsigned.all; -- Needed for the sum used in counter.

LIBRARY work;
	use work.array_package.all;

entity erosion is
    generic (
        --Basic configuration of the component
		    -- Size of each pixel (binary image by default)
          PIX_SIZE  : integer := 1;
		    --Size of the kernel moving along the image (3x3 by default)
			 KERN_SIZE : integer := 3;
			 --Kernel applied 
			 KERNEL : array2D_of_int(2 downto 0)(2 downto 0) := ((1,1,1),
												                          (1,1,1),
												                          (1,1,1));
		  --Advanced features
		    --Maximum line width. Defines the depth of the memory that stores 
			 --lines. In a system that can change resolution should be the 
			 --size of the width of the maximum resolution allowed.
			 --Default resolution is 640x480 so max width is 640.
		    MAX_WIDTH : integer := 640
    );
    port (
        -- Clock and reset.
        clk             : in STD_LOGIC;
        reset_n         : in STD_LOGIC;
        
		  -- Configuration
		  img_width  :in STD_LOGIC_VECTOR(15 downto 0);
		  img_height :in STD_LOGIC_VECTOR(15 downto 0);
		  
        -- Input image and sync signals
        pix		    : in STD_LOGIC_VECTOR((PIX_SIZE - 1) downto 0);--one pixel
		  data_valid  : in STD_LOGIC; --there is a valid pixel in pix
		  frame_valid: in STD_LOGIC; --1 img pixels are coming, 0 between 2 imgs
		 
        -- Output eroded image and sync signals
		  pix_out		    : out STD_LOGIC_VECTOR((PIX_SIZE - 1) downto 0);
		  data_valid_out    : out STD_LOGIC; 
		  frame_valid_out  : out STD_LOGIC
    );
end erosion;

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
	 signal condition_3_to_1     : STD_LOGIC; 
    --counters.
    signal pix_counter          : STD_LOGIC_VECTOR(23 downto 0);
	 signal line_end_reached	  : STD_LOGIC;
	 signal line_counter         : STD_LOGIC_VECTOR(23 downto 0);
    signal image_end_reached    : STD_LOGIC;
	 
	 --Moving window that will generate the output pixel
	 SIGNAL moving_window : array2D_of_std_logic_vector((KERN_SIZE-1) downto 0)((KERN_SIZE-1) downto 0)((PIX_SIZE-1) downto 0);
begin

--------------------------Implement a State machine----------------------
--Implement a State machine that permits the synchronization of the
--morphological operation so it starts a new image when a rising
--edge in frame_buffer. States 1 and 2 do that. In state 3 the 
--image is eroded.	 

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
    comb_fsm: process (current_state, state_condition, condition_3_to_1)
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
                if condition_3_to_1 = '1' then
                    next_state <= 1;
                else
                    next_state<=3;
                end if;
            when others =>
                next_state <= 0;
        end case;
    end process comb_fsm;
	 
	 -- Conditions of FSM.
	 state_condition(0) <= '1';
    state_condition(1) <= not(frame_valid);
    state_condition(2) <= frame_valid;
    condition_3_to_1   <= image_end_reached;
	 
	 -- Evaluation and update pix_counter.
    pix_counter_proc:process (clk)
    begin
        if rising_edge(clk) then
            if (current_state = 1) or (line_end_reached = '1') then
                -- reset the pixel counter
                pix_counter <= (others => '0');
            elsif (current_state = 3) and (data_valid = '1') then
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
            if (current_state = 1) then
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
	 
------------------------------Erosion process--------------------------
	
	
	
	--Do erosion and generate output signals
	
	
	--Generate Frame valid for the next stage
	frame_valid_proc: process(clk)
	begin
		if (rising_edge(clk) and (current_state=3) ) then
			frame_valid_out <= '1';
		else
			frame_valid_out <= '0';
		end if;
	end process;
	
end arch;
