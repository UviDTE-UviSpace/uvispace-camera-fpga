-- library declaration
library IEEE;
use IEEE.std_logic_1164.all;

-- entity
entity CCD_capture is
generic(
    N           : integer := 8;
    COL_WIDTH   : integer := 1280
    );
port(
    CLK             : in std_logic;
    in_reset_n      : in std_logic;
    in_start		: in std_logic;
    in_line_valid	: in std_logic;
    in_frame_valid	: in std_logic;
    in_data         : in std_logic_vector (N-1 downto 0);
    -- Data output
    out_valid       : out std_logic;
    out_captured    : out std_logic;
    out_data        : out std_logic_vector (N-1 downto 0);
    out_count_x     : out std_logic_vector (11 downto 0);
    out_count_y     : out std_logic_vector (11 downto 0)
    );
end CCD_capture;


architecture capture of CCD_capture is
    signal reset_n  : std_logic;   -- component reset signal
    signal count_x  : unsigned (12 downto 0);
    signal count_y  : unsigned (12 downto 0);
    signal captured : std_logic;
    signal count_x_enable : std_logic;
    signal count_y_enable : std_logic;

begin
    -- 12-bit synchronous up counter for the col coordinates with enable signal.
    process (CLK)
    begin
        -- The enable signal is directly wired to the reset.
        if rising_edge(CLK) then
            if ((count_x_enable = '0') or (reset_n = '0') then
                count_x <= (others => '0');
            else
                if count_x_enable then
                    count_x <= count_x + 1;
                end if;
            end if;
        end if;
    end process;
    -- 12-bit synchronous up counter for the row coordinates with enable signal.
    process (CLK)
    begin
        if rising_edge(CLK) then
            if (reset_n = '0') then
                count_y <= (others => '0');
            else
                if count_y_enable then
                    count_y <= count_y + 1;
                end if;
            end if;
        end if;
    end process;

    -- Synchronous register for the camera captured data
    process (CLK)
    begin
        if rising_edge(CLK) then
            if (reset_n = '0') then
                out_data <= (others => '0');
            else
                out_data <= in_data;
            end if;
        end if;
    end process;

    -- Enable the count of column coordinates until the whole width is covered.
    if count_x < (COL_WIDTH - 1) then
        count_x_enable <= '1';
        count_y_enable <= '0';
    else
        count_x_enable <= '0';
        -- Enable row count during one clock cycle every time a row finishes.
        if count_y < (ROW_HEIGHT - 1) then
            count_y_enable <= '1';
        -- The frame capture was finished.
        else
            captured <= '1'
            count_y_enable <= '0';
        end if ;
    end if;    

end capture;