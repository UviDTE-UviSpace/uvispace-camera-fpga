------------------------------------------------------------------
-- image_processing component
------------------------------------------------------------------
-- This component is used to condense all application-related
-- image processing.
-- In this case it converts RGB signal in HSV to ease a
-- binarization by color. The the image is binarized using a range
-- in hue, saturation and brightness. The binary image is then
-- eroded and dilated to erase small noise remaining.
------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.all;

LIBRARY work;
	use work.array_package.all;

entity image_processing is
    generic(
        -- Size of each pixel component
        COMPONENT_SIZE  : integer := 8
    );
    port(
        -- Control signals
        clock           : in STD_LOGIC;
        reset_n         : in STD_LOGIC;
		  -- Configuration
		    --Image dimensions
		  img_width       : in STD_LOGIC_VECTOR(15 downto 0);
		  img_height      : in STD_LOGIC_VECTOR(15 downto 0);
		    --binarization thresholds
		  hue_l_threshold : in STD_LOGIC_VECTOR(COMPONENT_SIZE-1 downto 0);
        hue_h_threshold : in STD_LOGIC_VECTOR(COMPONENT_SIZE-1 downto 0);
        sat_l_threshold : in STD_LOGIC_VECTOR(COMPONENT_SIZE-1 downto 0);
		  sat_h_threshold : in STD_LOGIC_VECTOR(COMPONENT_SIZE-1 downto 0);
        bri_l_threshold : in STD_LOGIC_VECTOR(COMPONENT_SIZE-1 downto 0);
		  bri_h_threshold : in STD_LOGIC_VECTOR(COMPONENT_SIZE-1 downto 0);
        -- Data input
        in_red          : in STD_LOGIC_VECTOR(COMPONENT_SIZE-1 downto 0);
        in_green        : in STD_LOGIC_VECTOR(COMPONENT_SIZE-1 downto 0);
        in_blue         : in STD_LOGIC_VECTOR(COMPONENT_SIZE-1 downto 0);
		  in_valid        : in STD_LOGIC;
        -- Data output
		    --RGB HSV
		  export_red           : out STD_LOGIC_VECTOR(COMPONENT_SIZE-1 downto 0);
        export_green         : out STD_LOGIC_VECTOR(COMPONENT_SIZE-1 downto 0);
        export_blue          : out STD_LOGIC_VECTOR(COMPONENT_SIZE-1 downto 0);
        export_hue           : out STD_LOGIC_VECTOR(COMPONENT_SIZE-1 downto 0);
        export_hsv_valid     : out STD_LOGIC;
			 --RGB to Gray
		  export_gray			  : out STD_LOGIC_VECTOR(COMPONENT_SIZE-1 downto 0);
		  export_gray_valid	  : out STD_LOGIC;
		    --Simple binary
		  export_bin           : out STD_LOGIC;
        export_bin_valid     : out STD_LOGIC;
		    --Binary signal after erosion
		  export_erosion       : out STD_LOGIC;
		  export_erosion_valid : out STD_LOGIC;
		    --Binary signal after dilation
		  export_dilation      : out STD_LOGIC;
		  export_dilation_valid: out STD_LOGIC

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

	 --Transforms RGB into Gray image
	 component rgb2gray
    port(
        -- Control signals
        clk			: in STD_LOGIC;
        reset_n	: in STD_LOGIC;
        -- Data input
		  R      	: in STD_LOGIC_VECTOR(COMPONENT_SIZE-1 downto 0);
        G      	: in STD_LOGIC_VECTOR(COMPONENT_SIZE-1 downto 0);
        B	   	: in STD_LOGIC_VECTOR(COMPONENT_SIZE-1 downto 0);
		  in_valid 	: in STD_LOGIC;
        -- Data output
		  Gray		: out STD_LOGIC_VECTOR(COMPONENT_SIZE-1 downto 0);
		  out_valid	: out STD_LOGIC
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
            sat_l_threshold : in STD_LOGIC_VECTOR(COMPONENT_SIZE-1 downto 0);
				sat_h_threshold : in STD_LOGIC_VECTOR(COMPONENT_SIZE-1 downto 0);
            bri_l_threshold : in STD_LOGIC_VECTOR(COMPONENT_SIZE-1 downto 0);
				bri_h_threshold : in STD_LOGIC_VECTOR(COMPONENT_SIZE-1 downto 0);
            in_valid        : in STD_LOGIC;
            -- Data output
            out_bin         : out STD_LOGIC;
            out_valid       : out STD_LOGIC
            );
    end component;

	 -- Component to provoke a 3x3 erosion  to the binary image
	 component erosion_bin
    generic (
			 KERN_SIZE : integer := 3;
			 KERNEL : array2D_of_int(2 downto 0)(2 downto 0) := ((0,1,0),
												                          (1,1,1),
												                          (0,1,0))
    );
    port (
        clk            : in STD_LOGIC;
        reset_n        : in STD_LOGIC;
		  img_width      :in STD_LOGIC_VECTOR(15 downto 0);
		  img_height     :in STD_LOGIC_VECTOR(15 downto 0);
        pix		        : in STD_LOGIC;--binary pixels of the input image
		  data_valid     : in STD_LOGIC;
		  pix_out        : out STD_LOGIC;--binary pixels of the output eroded img
		  data_valid_out : out STD_LOGIC
    );
    end component;

	 -- Component to provoke a 3x3 dilation  to the binary image
	 component dilation_bin
    generic (
			 KERN_SIZE : integer := 3;
			 KERNEL : array2D_of_int(2 downto 0)(2 downto 0) := ((0,1,0),
												                          (1,1,1),
												                          (0,1,0))
    );
    port (
        clk            : in STD_LOGIC;
        reset_n        : in STD_LOGIC;
		  img_width      :in STD_LOGIC_VECTOR(15 downto 0);
		  img_height     :in STD_LOGIC_VECTOR(15 downto 0);
        pix		        : in STD_LOGIC;--binary pixels of the input image
		  data_valid     : in STD_LOGIC;
		  pix_out        : out STD_LOGIC;--binary pixels of the output dilated img
		  data_valid_out : out STD_LOGIC
    );
    end component;

    -- Intermediate signals declaration
    signal hsv_out_valid        : STD_LOGIC;
	 signal hsv_out_red          : STD_LOGIC_VECTOR(COMPONENT_SIZE-1 downto 0);
	 signal hsv_out_green        : STD_LOGIC_VECTOR(COMPONENT_SIZE-1 downto 0);
	 signal hsv_out_blue         : STD_LOGIC_VECTOR(COMPONENT_SIZE-1 downto 0);
    signal hsv_out_hue          : STD_LOGIC_VECTOR(COMPONENT_SIZE-1 downto 0);
    signal hsv_out_saturation   : STD_LOGIC_VECTOR(COMPONENT_SIZE-1 downto 0);
    signal hsv_out_brightness   : STD_LOGIC_VECTOR(COMPONENT_SIZE-1 downto 0);
	     --Outpus of HSVtoBIN
	 signal bin_out              : STD_LOGIC;
	 signal bin_out_valid        : STD_LOGIC;
	 	  --Outputs of Erosion
    signal erosion_out         : STD_LOGIC;
	 signal erosion_out_valid   : STD_LOGIC;
	     --Outputs of Dilation
    signal dilation_out         : STD_LOGIC;
	 signal dilation_out_valid   : STD_LOGIC;

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
                out_red         => hsv_out_red,
                out_green       => hsv_out_green,
                out_blue        => hsv_out_blue,
                out_hue         => hsv_out_hue,
                out_saturation  => hsv_out_saturation,
                out_brightness  => hsv_out_brightness,
                out_valid       => hsv_out_valid,
                out_visual      => open,
                out_done        => open
                );

		  -- Instantiation and mappingof rgb2gray component
		  rgb2gray_component : rgb2gray
		  port map(
				-- Control signals
				 clk           => clock,
             reset_n       => reset_n,
				 -- Data input
				 R         		=> hsv_out_red,
             G    	 		=> hsv_out_green,
             B     	 		=> hsv_out_blue,
             in_valid    	=> hsv_out_valid,
				 -- Data output
				 Gray				=> export_gray,
				 out_valid		=> export_gray_valid
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
                sat_l_threshold => sat_l_threshold,
					 sat_h_threshold => sat_h_threshold,
                bri_l_threshold => bri_l_threshold,
					 bri_h_threshold => bri_h_threshold,
                in_valid        => hsv_out_valid,
                -- Data output
                out_bin         => bin_out,
                out_valid       => bin_out_valid
                );


		  -- Instantiation and mapping of the dilation and erosion components.
		  -- Together they delete small noise dots of the binarization
		  erosion_component : erosion_bin
		  generic map(
		     KERN_SIZE => 3,
			  KERNEL => ((0,1,0),
                      (1,1,1),
                      (0,1,0)))

		  port map(
			  -- Clock and reset.
			  clk             => clock,
			  reset_n         => reset_n,
			  -- Configuration
			  img_width 	   => img_width,
			  img_height      => img_height,
			  --input binay pixels
			  pix             =>  bin_out,
			  data_valid      =>  bin_out_valid,
			  --output binay pixels eroded
			  pix_out         =>  erosion_out,
			  data_valid_out  =>  erosion_out_valid
			  );

		  dilation_component : dilation_bin
		  generic map(
		     KERN_SIZE => 3,
			  KERNEL => ((0,1,0),
                      (1,1,1),
                      (0,1,0)))

		  port map(
			  -- Clock and reset.
			  clk             => clock,
			  reset_n         => reset_n,
			  -- Configuration
			  img_width 	   => img_width,
			  img_height      => img_height,
			  --input binay pixels
			  pix             =>  erosion_out,
			  data_valid      =>  erosion_out_valid,
			  --output binay pixels eroded
			  pix_out         =>  dilation_out,
			  data_valid_out  =>  dilation_out_valid
			  );

			--Export output signals
			export_red<= hsv_out_red;
			export_green<= hsv_out_green;
			export_blue<= hsv_out_blue;
			export_hue<= hsv_out_hue;
			export_hsv_valid <= hsv_out_valid;
			export_bin <= bin_out;
			export_bin_valid <= bin_out_valid;
			export_erosion <= erosion_out;
			export_erosion_valid <= erosion_out_valid;
			export_dilation <= dilation_out;
			export_dilation_valid <= dilation_out_valid;

end arch;
