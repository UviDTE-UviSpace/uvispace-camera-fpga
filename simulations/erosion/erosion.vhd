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
	 
	 --Define subcomponents 
	 component morphological_fifo
    generic (

          PIX_SIZE  : integer := 1;
			 KERN_SIZE : integer := 3;
		    MAX_IMG_WIDTH : integer := 640
			 );
			 port (
				  -- Clock and reset.
				  clk             : in STD_LOGIC;
				  reset_n         : in STD_LOGIC;
				  -- Configuration
				  img_width  :in STD_LOGIC_VECTOR(15 downto 0);
				  -- Input image and sync signals
				  pix		    : in STD_LOGIC_VECTOR((PIX_SIZE - 1) downto 0);--one pixel
				  data_valid  : in STD_LOGIC; --there is a valid pixel in pix
				  -- Output signal is the moving window to do the morphological operation
				  moving_window    : array2D_of_std_logic_vector((KERN_SIZE-1) downto 0)((KERN_SIZE-1)  downto 0)((PIX_SIZE-1) downto 0);
				  data_valid_out   : out STD_LOGIC; 
			 );
		end component;
begin

--------------------------Implement a State machine----------------------
--Implement a State machine that permits the synchronization of the
--morphological operation so it starts a new image when a rising
--edge in frame_buffer. States 1 and 2 do that. In state 3 the 
--image is eroded.	 

	 
	 
------------------------------Erosion process--------------------------
	
	--Do erosion and generate output signals
	erosion: process(clk)
	begin
		if rising_edge(clk) and current_state=3 then
			
		end if;
	end process;
	
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
