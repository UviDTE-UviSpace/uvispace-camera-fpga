------------------------------------------------------------------
-- hsv2bin component
------------------------------------------------------------------
-- This component gets input HSV pixel data and returns a binary value
-- per pixel, depending if the pixel belongs to the specified colour
-- area.
--
-- With the Hue low and high tresholds, an specific range of colours is
-- selected. The saturation and brightness thresholds are needed in
-- order to have a stable algorithm, as small changes in the original
-- RGB pixel components can lead to huge changes in the Hue value if the
-- saturation or brightness are small.
------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.all;


entity hsv2bin is
    generic(
        -- Size of each pixel component
        COMPONENT_SIZE  : integer := 8
    );
    port(
        -- Control signals
        clk             : in STD_LOGIC;
        reset_n         : in STD_LOGIC;
        -- Data input
        hue             : in STD_LOGIC_VECTOR(COMPONENT_SIZE-1 downto 0);
        saturation      : in STD_LOGIC_VECTOR(COMPONENT_SIZE-1 downto 0);
        brightness      : in STD_LOGIC_VECTOR(COMPONENT_SIZE-1 downto 0);
        hue_l_threshold : in STD_LOGIC_VECTOR(COMPONENT_SIZE-1 downto 0);
        hue_h_threshold : in STD_LOGIC_VECTOR(COMPONENT_SIZE-1 downto 0);
        sat_threshold   : in STD_LOGIC_VECTOR(COMPONENT_SIZE-1 downto 0);
        bri_threshold   : in STD_LOGIC_VECTOR(COMPONENT_SIZE-1 downto 0);
        in_valid        : in STD_LOGIC;
        -- Data output
        out_bin         : out STD_LOGIC;
        out_valid       : out STD_LOGIC
        );
end hsv2bin;


--Component architecture
architecture arch of hsv2bin is

begin
    -- Implementation of the main algorithm, that will be updated on every clock
    -- positive pulse.
    main_process: process(clk)
    begin
        if (reset_n = '0') then
            out_bin <= '0';
            out_valid <= '0';
        else
            if (saturation>sat_threshold) and (brightness>bri_threshold)
                    and ((hue>hue_l_threshold) or (hue<hue_h_threshold)) then
                out_bin <= '1';
            else
                out_bin <= '0';
            end if;
            out_valid <= in_valid;
        end if;
    end process main_process;

end arch;
