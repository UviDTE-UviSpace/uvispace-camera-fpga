------------------------------------------------------------------
-- image_capture component
------------------------------------------------------------------
-- This component is used to save an image in memory. It uses two
-- buffers in memory with addresses buff0 and buff1 to do it.
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
         -- Size of each color component (8 or 16).
        COMPONENT_SIZE  : integer := 8
    );
    PORT (
        -- Clock and reset.
        clk             : IN STD_LOGIC;
        reset_n         : IN STD_LOGIC;
        -- Signals from the video stream.
        R               : IN STD_LOGIC_VECTOR((COMPONENT_SIZE - 1) downto 0);
        G               : IN STD_LOGIC_VECTOR((COMPONENT_SIZE - 1) downto 0);
        B               : IN STD_LOGIC_VECTOR((COMPONENT_SIZE - 1) downto 0);
        Gray            : IN STD_LOGIC_VECTOR((COMPONENT_SIZE - 1) downto 0);
        -- When fram_valid is 1, the image from camera is being aquired.
        frame_valid     : IN STD_LOGIC;
        data_valid      : IN STD_LOGIC; -- Valid pixel in R,G,B,Gray inputs.
        -- Signals to control this component (usually coming from avalon_camera)
        -- When start_capture is 1, start getting a new image.
        start_capture   : IN STD_LOGIC;
        -- Number of columns and rows in the input image array.
        image_width     : IN STD_LOGIC_VECTOR(15 downto 0);
        image_height    : IN STD_LOGIC_VECTOR(15 downto 0);
        -- Odd lines buffer address.
        buff0           : IN STD_LOGIC_VECTOR(31 downto 0);
        -- Even lines buffer address.
        buff1           : IN STD_LOGIC_VECTOR(31 downto 0);
        -- Signals indicating that buffers are full (Active 1 clock cycle only).
        buff0full       : OUT STD_LOGIC;
        buff1full       : OUT STD_LOGIC;
        -- Avalon MM Master port to save data into a memory.
        -- Byte adresses are multiples of 4 when accessing 32-bit data.
        AB              : OUT STD_LOGIC_VECTOR(31 downto 0);
        Dout            : OUT STD_LOGIC_VECTOR((COMPONENT_SIZE*4 - 1) downto 0);
        WR              : OUT STD_LOGIC
    );
END image_capture;


ARCHITECTURE arch OF image_capture IS 
    constant NUMBER_OF_STATES : INTEGER := 7;
    --signals for the evolution of the state machine
    SIGNAL current_state    : INTEGER range 0 to (NUMBER_OF_STATES - 1);
    SIGNAL next_state       : INTEGER range 0 to (NUMBER_OF_STATES - 1);
    -- Conditions to change next state.
    -- State_condition(x) condition to go from x to x+1.
    SIGNAL state_condition  : STD_LOGIC_VECTOR((NUMBER_OF_STATES - 2) downto 0);
    SIGNAL condition_5_to_4 : STD_LOGIC;
    SIGNAL condition_5_to_5 : STD_LOGIC;
    SIGNAL condition_6_to_1 : STD_LOGIC;
    SIGNAL condition_6_to_4 : STD_LOGIC;
    --counters.
    SIGNAL pix_counter      : STD_LOGIC_VECTOR(12 downto 0);
    SIGNAL line_counter     : STD_LOGIC_VECTOR(12 downto 0);
    SIGNAL line_end_reached : STD_LOGIC;
    SIGNAL image_end_reached: STD_LOGIC;
    -- Write_buff: it saves the address where the next pixel will be saved.
    SIGNAL write_buff       : STD_LOGIC_VECTOR(31 downto 0);
    -- 0 if writting in buff0, 1 if writting in buff1.
    SIGNAL current_buff     : STD_LOGIC;
    -- captures a flank that comes from othe clock region.
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
    -- Evolution of FSM
    comb_fsm: PROCESS (current_state, state_condition, condition_5_to_4,
                       condition_5_to_5, condition_6_to_1)
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
                IF state_condition(5) = '1' THEN next_state <= 6;
                ELSIF condition_5_to_4 = '1' THEN next_state <= 4;
                ELSIF condition_5_to_5 = '1' THEN next_state <= 5;
                ELSE next_state<=5; END IF;
            WHEN 6 =>
                IF condition_6_to_1 = '1' THEN next_state <= 1;
                ELSIF condition_6_to_4 = '1' THEN next_state <= 4;
                ELSE next_state<=6; END IF;
            WHEN OTHERS =>
                next_state <= 0;
        END CASE;
    END PROCESS comb_fsm;
    -- Conditions of FSM.
    state_condition(0) <= '1';
    state_condition(1) <= start_capture_reg;
    state_condition(2) <= not(frame_valid);
    state_condition(3) <= frame_valid;
    state_condition(4) <= data_valid;
    state_condition(5) <= line_end_reached;
    condition_5_to_4   <= not(data_valid) and not(line_end_reached);
    condition_5_to_5   <= data_valid and not(line_end_reached);
    condition_6_to_1   <= image_end_reached;
    condition_6_to_4   <= not(image_end_reached);
    -- Update counters.
    pix_counter_proc:process (clk, current_state)
    begin
        if rising_edge(clk) then
            if (current_state = 1) or (current_state = 6) then
                pix_counter <= (others => '0'); --reset ctr
            elsif (current_state = 5) then -- ctr incremented
                pix_counter <= pix_counter + 1;
            end if;
        end if;
        if pix_counter = image_width(12 downto 0) then
            line_end_reached <= '1';
        else
            line_end_reached <= '0';
        end if;
    end process;
    -- Evaluation and update of line_counter.
    line_counter_proc:process (clk, current_state)
    begin
        if rising_edge(clk) then
            if (current_state = 1) then
                line_counter <= (others => '0');   -- reset ctr
            elsif (current_state = 6) then         -- ctr incremented
                line_counter <= line_counter + 1;
            end if;
        end if;
        if line_counter = image_height(12 downto 0) then
            image_end_reached <= '1';
        else
            image_end_reached <= '0';
        end if;
    end process;
    -- Generate output signals using the states of the FSM
    -- Signals that are stable during the whole state: buff0full
    bufffull_proc:process(clk, current_state)
    begin
        if current_state = 6 then
            if current_buff = '0' then
                buff0full <= '1';
            else
                buff1full <= '1';
            end if;
        else
            buff0full <= '0';
            buff1full <= '0';
        end if;
    end process;
    -- AB
    AB <= write_buff;
    -- DB
    Dout((COMPONENT_SIZE*4-1) downto 0) <= Gray & B & G & R;
    -- WR
    WITH current_state SELECT WR <=
        '1' WHEN 5,
        '0' WHEN OTHERS;
    -- Write_buff update. 
    write_buff_proc:process (clk, current_state)
    begin
        if rising_edge(clk) then
            if current_state = 1 then
                write_buff <= buff0;
            elsif current_state = 6 and current_buff = '0'then
                write_buff <= buff1;
                current_buff <= '1';
            elsif current_state = 6 and current_buff = '1'then
                write_buff <= buff0;
                current_buff <= '0';
            elsif current_state = 5 then
                write_buff <= write_buff + (COMPONENT_SIZE/2);
            end if;
        end if;
    end process;
    -- Detection of a flank in start_capture. This signal is coming from the
    -- processor and could have different clock. That's why flank is detected
    -- instead of level.
    start_capture_reg_proc:process(start_capture)
    begin
        if (current_state = 2 or current_state = 0) then
            start_capture_reg <= '0';
        elsif rising_edge(start_capture) then
            start_capture_reg <= '1';
        end if;
    end process;
END arch;

