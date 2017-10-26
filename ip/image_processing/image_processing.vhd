------------------------------------------------------------------
-- image_processing component
------------------------------------------------------------------
-- This component is used to 
------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.all;


entity image_processing is
    generic(
        -- Size of each pixel component
        COMPONENT_SIZE  : integer := 8
    );
    port(
        -- Control signals
        clock           : in STD_LOGIC;
        reset_n         : in STD_LOGIC;
        -- Data input
        in_red          : in STD_LOGIC_VECTOR(COMPONENT_SIZE-1 downto 0);
        in_green        : in STD_LOGIC_VECTOR(COMPONENT_SIZE-1 downto 0);
        in_blue         : in STD_LOGIC_VECTOR(COMPONENT_SIZE-1 downto 0);
        hue_l_threshold : in STD_LOGIC_VECTOR(COMPONENT_SIZE-1 downto 0);
        hue_h_threshold : in STD_LOGIC_VECTOR(COMPONENT_SIZE-1 downto 0);
        sat_threshold   : in STD_LOGIC_VECTOR(COMPONENT_SIZE-1 downto 0);
        bri_threshold   : in STD_LOGIC_VECTOR(COMPONENT_SIZE-1 downto 0);
        in_valid        : in STD_LOGIC;
        -- Data output
        out_hue         : out STD_LOGIC_VECTOR(COMPONENT_SIZE-1 downto 0);
        out_bin         : out STD_LOGIC;
        out_valid       : out STD_LOGIC
    );
end image_processing;


-- Top component architecture
architecture arch of image_processing is

    -- Sub-components declarations.
    --
    -- This components returns the HSV components of the given RGB image.
    component rgb2hsv
        port(
            -- Control signals
            clock           : in STD_LOGIC;
            reset_n         : in STD_LOGIC;
            -- Data input
            in_red          : in STD_LOGIC_VECTOR(COMPONENT_SIZE-1 downto 0);
            in_green        : in STD_LOGIC_VECTOR(COMPONENT_SIZE-1 downto 0);
            in_blue         : in STD_LOGIC_VECTOR(COMPONENT_SIZE-1 downto 0);
            in_valid        : in STD_LOGIC;
            in_visual       : in STD_LOGIC;
            in_done         : in STD_LOGIC;
            -- Data output
            out_red         : out STD_LOGIC_VECTOR(COMPONENT_SIZE-1 downto 0);
            out_green       : out STD_LOGIC_VECTOR(COMPONENT_SIZE-1 downto 0);
            out_blue        : out STD_LOGIC_VECTOR(COMPONENT_SIZE-1 downto 0);
            out_hue         : out STD_LOGIC_VECTOR(COMPONENT_SIZE-1 downto 0);
            out_saturation  : out STD_LOGIC_VECTOR(COMPONENT_SIZE-1 downto 0);
            out_brightness  : out STD_LOGIC_VECTOR(COMPONENT_SIZE-1 downto 0);
            out_valid       : out STD_LOGIC;
            out_visual      : out STD_LOGIC;
            out_done        : out STD_LOGIC
            );
    end component;

    -- This component returns a binary map of a given HSV image, belonging the
    -- '1' pixels to a specified Hue range, altogether with a minimum saturation
    -- and brightness value.
    component hsv2bin
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
    end component;

    -- Intermediate signals declaration
    signal hsv_out_valid        : STD_LOGIC;
    signal hsv_out_hue          : STD_LOGIC_VECTOR(COMPONENT_SIZE-1 downto 0);
    signal hsv_out_saturation   : STD_LOGIC_VECTOR(COMPONENT_SIZE-1 downto 0);
    signal hsv_out_brightness   : STD_LOGIC_VECTOR(COMPONENT_SIZE-1 downto 0);


    begin
        -- Instantiation and mapping of the rgb2hsv component.
        rgb2hsv_component : rgb2hsv
        port map(
                -- Control signals
                clock           => clock,
                reset_n         => reset_n,
                -- Data input
                in_red          => in_red,
                in_green        => in_green,
                in_blue         => in_blue,
                in_valid        => in_valid,
                in_visual       => '1',
                in_done         => '1',
                -- Data output
                out_red         => open,
                out_green       => open,
                out_blue        => open,
                out_hue         => hsv_out_hue,
                out_saturation  => hsv_out_saturation,
                out_brightness  => hsv_out_brightness,
                out_valid       => hsv_out_valid,
                out_visual      => open,
                out_done        => open
                );
        -- Instantiation and mapping of the hsv2bin component. 
        hsv2bin_component : hsv2bin
        port map(
                -- Control signals
                clk             => clock,
                reset_n         => reset_n,
                -- Data input
                hue             => hsv_out_hue,
                saturation      => hsv_out_saturation,
                brightness      => hsv_out_brightness,
                hue_l_threshold => hue_l_threshold,
                hue_h_threshold => hue_h_threshold,
                sat_threshold   => sat_threshold,
                bri_threshold   => bri_threshold,
                in_valid        => hsv_out_valid,
                -- Data output
                out_bin         => out_bin,
                out_valid       => out_valid
                );

end arch;
