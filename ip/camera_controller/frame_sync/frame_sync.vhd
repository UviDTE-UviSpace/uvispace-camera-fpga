------------------------------------------------------------------------
-- frame_sync
------------------------------------------------------------------------
-- This component permorms a frame synchronization needed at the
-- beggining because each component has a different start-up time.
-- It waits N frames until it permits pixels, frame valid, line_valid
-- and data_valid to be propagated to the rest of the circuit.
-- This way the VGA memory starts writing data in order and images never
-- get shifted in the screen. 
------------------------------------------------------------------------
library IEEE;
	use IEEE.STD_LOGIC_1164.ALL;
	use ieee.math_real.all;          -- For using ceil and log2.
	use IEEE.NUMERIC_STD.all;        -- For using to_unsigned.
	use ieee.std_logic_unsigned.all; -- Needed for the sum used in counter.

entity frame_sync is
    generic (
		  --number of frames to skip after a reset
        N : integer := 2
    );
    port (
        -- Clock and reset.
        clk             : in STD_LOGIC;
        reset_n         : in STD_LOGIC;
		  
        -- Input image and sync signals
        in_pix	       : in STD_LOGIC_VECTOR(11 downto 0);
		  in_data_valid    : in STD_LOGIC; 
		  in_frame_valid   : in STD_LOGIC;
		 
		  -- Output image and sync signals
        out_pix		    : out STD_LOGIC_VECTOR(11 downto 0);
		  out_data_valid   : out STD_LOGIC; 
		  out_frame_valid  : out STD_LOGIC
    );
end frame_sync;

architecture arch of frame_sync is
  --Variables for the state machine
	 constant NUMBER_OF_STATES   : INTEGER := 3;
    --signals for the evolution of the state machine
    signal current_state        	: INTEGER range 0 to (NUMBER_OF_STATES - 1);
    signal next_state           	: INTEGER range 0 to (NUMBER_OF_STATES - 1);
    -- Conditions to change next state.
    -- State_condition(x) condition to go from x to x+1.
    signal state_condition      	: STD_LOGIC_VECTOR((NUMBER_OF_STATES - 2)
                                    downto 0);
    signal frame_counter         : STD_LOGIC_VECTOR(9 downto 0);
	 signal frame_count_reached 	: STD_LOGIC;
	 --Registers to reduce combinational path at the input of frame_sync
	 signal pix_reg: STD_LOGIC_VECTOR(11 downto 0);
	 signal dval_reg : STD_LOGIC;
	 signal fval_reg : STD_LOGIC;
begin
---------------------------Save inputs in registers----------------------
	input_regs_proc: process (clk)
	begin
		if rising_edge(clk) then
			pix_reg <= in_pix;
			dval_reg <= in_data_valid;
			fval_reg <= in_frame_valid;
		end if;
	end process;

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
    comb_fsm: process (current_state, state_condition)
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
                 next_state<=2;  
            when others =>
                next_state <= 0;
        end case;
    end process comb_fsm;
	 
	 -- Conditions of FSM.
	 state_condition(0) <= '1';
    state_condition(1) <= frame_count_reached;
	 
	 -- Evaluation and update frame_counter.
    frame_counter_proc:process (reset_n, fval_reg, clk)
    begin
		  if (reset_n = '0') then
            -- reset the pixel counter
            frame_counter <= (others => '0');
        elsif (reset_n = '1') and (current_state = 1) and falling_edge(fval_reg) then
            -- Increment the pixel counter
            frame_counter <= frame_counter + 1;
        end if;
        if frame_counter = N then
            frame_count_reached <= '1';
        else
            frame_count_reached <= '0';
        end if;
    end process;
	 
	 -- Propagate signals only after N complete frames have passed
	 output_process: process (fval_reg,dval_reg,pix_reg, clk)
	 begin
		if (current_state = 2) then
			out_pix <= pix_reg;
			out_data_valid <= dval_reg;
			out_frame_valid <= fval_reg;
		else
			out_pix <= (others => '0');
			out_data_valid <= '0';
			out_frame_valid <= '0';
		end if;
	 end process;
end arch;
