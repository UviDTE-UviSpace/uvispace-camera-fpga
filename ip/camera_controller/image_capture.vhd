------------------------------------------------------------------------
-- image_capture component
------------------------------------------------------------------------
-- This component is used to save an image in memory. It uses one
-- buffer in processor memory at address 'buff'.

-- When 'start_capture' is asserted the component waits for the next
-- positive flank of 'frame_valid' for synchronizing and starting at the
-- beginning of a new image. Then, every time 'data_valid' is
-- asserted the component packs the {R,G,B,Gray} components into a
-- 32-bit (when components are 8-bit) or 64-bit (when
-- components are 16-bit) word and writes it to the avalon bus.

-- It is assumed that the bus can react in a single clock cycle to the
-- writings because 'waitrequest' signal of avalon specification is not
-- implemented. 

-- In case the slave bus cannot react in a single cycle, an
-- Avalon FIFO should be implemented in between the master of this
-- component and the slave where data is being written. In this case,
-- the component behaviour would be the following:
-- The component starts writing in buff0.
-- When a line from the image is acquired buff0full signal is
-- asserted during 1 clock cycle. Next line is written into buff1.
-- When a line from the image is acquired again the bus asserts
-- buff1full line for 1 cycle. Next line is saved in buff0 again.
-- So the component goes writing odd lines in buff0 and even lines
-- in buff1 until all lines in one image (image_height) are acquired.
-- The processor (or whatever component processes acquired lines)
-- should empty one buffer before this component finishes
-- filling the other one so data is not lost.
------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.math_real.all;          -- For using ceil and log2.
use IEEE.NUMERIC_STD.all;        -- For using to_unsigned.
use ieee.std_logic_unsigned.all; -- Needed for the sum used in counter.

entity image_capture is
    generic (
        -- Size of each color component in bits (8 or 16).
        COMPONENT_SIZE  : integer := 8;
        -- Number of pixels per write in the output avalon bus (>=1)
        PIX_WR  : integer := 4
    );
    port (
        -- Clock and reset.
        clk             : in STD_LOGIC;
        reset_n         : in STD_LOGIC;
        
        -- Signals from the video stream representing one pixel in RGB and grey
        R               : in STD_LOGIC_VECTOR((COMPONENT_SIZE - 1) downto 0);
        G               : in STD_LOGIC_VECTOR((COMPONENT_SIZE - 1) downto 0);
        B               : in STD_LOGIC_VECTOR((COMPONENT_SIZE - 1) downto 0);
        Gray            : in STD_LOGIC_VECTOR((COMPONENT_SIZE - 1) downto 0);
        
        -- Signals to control the component
        -- When frame_valid is 1, the image from camera is being acquired.
        frame_valid     : in STD_LOGIC;
        data_valid      : in STD_LOGIC; -- Valid pixel in R,G,B,Gray inputs.
        -- Signals to control this component (usually coming from avalon_camera)
        -- When start_capture is 1, start getting a new image.
        start_capture   : in STD_LOGIC;
        -- Number of columns and rows in the input image array.
        image_size      : in STD_LOGIC_VECTOR(23 downto 0);
        -- Image buffer address.
        buff            : in STD_LOGIC_VECTOR(31 downto 0);
        -- Flag that indicates that the image has been captured 
          -- (Active 1 clock cycle only).
        image_captured  : out STD_LOGIC;
        -- Signal indicating standby state 
        --(outside of reset, waiting for flank in start_capture)
        standby         : out STD_LOGIC;
        
        -- Avalon MM Master port to save data into a memory.
        -- Byte addresses are multiples of 4 when accessing 32-bit data.
        address         : out STD_LOGIC_VECTOR(31 downto 0);
        write           : out STD_LOGIC;
        byteenable      : out STD_LOGIC_VECTOR((PIX_WR*COMPONENT_SIZE/2 - 1)
                                               downto 0);
        writedata       : out STD_LOGIC_VECTOR((PIX_WR*COMPONENT_SIZE*4 - 1)
                                               downto 0);
        waitrequest     : in STD_LOGIC;
        burstcount      : out STD_LOGIC_VECTOR(6 downto 0)
    );
end image_capture;

architecture arch of image_capture is
    type array_of_std_logic_vector is array(natural range <>) 
            of STD_LOGIC_VECTOR;
    constant NUMBER_OF_STATES   : INTEGER := 6;
    --signals for the evolution of the state machine
    signal current_state        : INTEGER range 0 to (NUMBER_OF_STATES - 1);
    signal next_state           : INTEGER range 0 to (NUMBER_OF_STATES - 1);
    -- Conditions to change next state.
    -- State_condition(x) condition to go from x to x+1.
    signal state_condition      : STD_LOGIC_VECTOR((NUMBER_OF_STATES - 2)
                                    downto 0);
    signal condition_5_to_1     : STD_LOGIC;
    --counters.
    signal pix_counter          : STD_LOGIC_VECTOR(23 downto 0);
    signal image_end_reached    : STD_LOGIC;
    signal pix_wr_counter       : STD_LOGIC_VECTOR(integer(
                                    ceil(log2(real(PIX_WR+1)))) downto 0);
    -- Write_buff saves the address where the next pixel will be saved.
    signal write_buff           : STD_LOGIC_VECTOR(31 downto 0);
    -- Internal copy of the write output signal
    signal av_write             : STD_LOGIC;
     -- Extra buffers to pack the pixels and reduce the number of writes in bus
    signal output_buff          : array_of_std_logic_vector((PIX_WR - 1)
                                    downto 0) ((COMPONENT_SIZE*4-1) downto 0);
    signal out_buff_EN          :STD_LOGIC_VECTOR((PIX_WR - 1) downto 0);
     --Packs input components into a single variable
    signal input_data           :STD_LOGIC_VECTOR((COMPONENT_SIZE*4 - 1)
                                    downto 0);
    -- captures a flank in start capture that comes from other clock region.
    signal start_capture_reg    : STD_LOGIC;

begin

    -- FSM (Finite State Machine) clocking and reset.
    fsm_mem: process (clk,reset_n)
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
    comb_fsm: process (current_state, state_condition, condition_5_to_1)
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
                if state_condition(3) = '1' then
                    next_state <= 4;
                else
                    next_state<=3;
                end if;
            when 4 =>
                if state_condition(4) = '1' then
                    next_state <= 5;
                else
                    next_state<=4;
                end if;
            when 5 =>
                if condition_5_to_1 = '1' then
                    next_state <= 1;
                else 
                    next_state<=5;
                end if;
            when others =>
                next_state <= 0;
        end case;
    end process comb_fsm;

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
                -- reset the pixel counter
                pix_counter <= (others => '0');
            elsif (current_state = 4) and (data_valid = '1') then
                 -- Increment the pixel counter
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
                -- reset the pixel write counter
                pix_wr_counter <= (others => '0');
            elsif (current_state = 4) and (data_valid = '1') then
                    -- Increment the pixel write counter
                    if pix_wr_counter = (PIX_WR-1) then
                        pix_wr_counter <= (others => '0');
                    else
                        pix_wr_counter <= pix_wr_counter + 1;
                    end if;
            end if;
        end if;
    end process;

    -- Generate standby signal
    with current_state select standby <=
        '1' when 1,
        '0' when others;
          
     -- Generate image_captured signal
    with current_state select image_captured <=
        '1' when 5,
        '0' when others;
        
    -- Save data in extra output buffers
    input_data <= Gray & B & G & R;
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
                        and (current_state = 4) then
                    out_buff_EN(I) <= '1';
                else
                    out_buff_EN(I) <= '0';
                end if;
            end process;
    end generate out_buff_generate;    
     
     --Generate Avalon signals
        --write data
    write_data_generate : for I in 0 to (PIX_WR-1) generate
        writedata(((I+1)*4*COMPONENT_SIZE - 1) downto (I*4*COMPONENT_SIZE)) <= 
                output_buff(I);
    end generate write_data_generate;
        --byteenable
     byteenable <= (others => '1'); 
        --burstcount
    -- Always single transactions (no burst)
     burstcount <= "0000001"; 
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
     write <= av_write;
    -- address 
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

end arch;
