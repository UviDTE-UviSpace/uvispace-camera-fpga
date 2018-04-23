------------------------------------------------------------------------
-- dilation_bin
------------------------------------------------------------------------
-- dilation_bin produces the morphological operation of dilation to
-- a binary image. It uses morphological_fifo to generate the moving
-- window needed to perform a morphological operation.
-- In this file the dilation is produced with the binary operation "or"
-- thats why this ip core can only be a applied to binary images. To
-- generate a more generic version that can be applied to a gray or
-- RGB image the "or" operation should be sustitued by the maximum
-- (as theory in image processing defines dilation).
------------------------------------------------------------------------
library IEEE;
	use IEEE.STD_LOGIC_1164.ALL;
	use ieee.math_real.all;          -- For using ceil and log2.
	use IEEE.NUMERIC_STD.all;        -- For using to_unsigned.
	use ieee.std_logic_unsigned.all; -- Needed for the sum used in counter.

LIBRARY work;
	use work.array_package.all;

entity dilation_bin is
    generic (
        --Basic configuration of the component
		    --Size of the kernel moving along the image (3x3 by default)
			 KERN_SIZE : integer := 3;
			  --Kernel applied
			 KERNEL : array2D_of_int(2 downto 0)(2 downto 0) := ((0,1,0),
												                          (1,1,1),
												                          (0,1,0))
    );
    port (
        -- Clock and reset.
        clk            : in STD_LOGIC;
        reset_n        : in STD_LOGIC;

		  -- Configuration
		  img_width      :in STD_LOGIC_VECTOR(15 downto 0);
		  img_height     :in STD_LOGIC_VECTOR(15 downto 0);

        -- Input image and sync signals
        pix		        : in STD_LOGIC;--binary pixels of the input image
		  data_valid     : in STD_LOGIC; --when 1 there is a valid pixel in pix

        -- Output signals
		  pix_out        : out STD_LOGIC;--binary pixels of the output dilated img
		  data_valid_out : out STD_LOGIC
    );
end dilation_bin;

architecture arch of dilation_bin is

	--Declare morphological_fifo, the component storing the pixels to
	--genrate the moving window used in morphological operations
	component morphological_fifo
    generic (
        --Basic configuration of the component
		    -- Size of each pixel (binary image by default)
          PIX_SIZE  : integer := 8;
		    --Size of the kernel moving along the image (3x3 by default)
			 KERN_SIZE : integer := 3
    );
    port (
        -- Clock and reset.
        clk            : in STD_LOGIC;
        reset_n        : in STD_LOGIC;

		  -- Configuration
		  img_width      :in STD_LOGIC_VECTOR(15 downto 0);
		  img_height     :in STD_LOGIC_VECTOR(15 downto 0);

        -- Input image and sync signals
        pix		        : in STD_LOGIC_VECTOR((PIX_SIZE - 1) downto 0);--one pixel
		  data_valid     : in STD_LOGIC; --there is a valid pixel in pix

        -- Output signal is the moving window to do the morphological operation
		  moving_window  : out array2D_of_std_logic_vector((KERN_SIZE-1) downto 0)((KERN_SIZE-1)  downto 0)((PIX_SIZE-1) downto 0);
		  window_valid   : out array2D_of_std_logic((KERN_SIZE-1) downto 0)((KERN_SIZE-1)  downto 0);
		  data_valid_out : out STD_LOGIC
    );
	 end component;

	 --internal signals
	 SIGNAL mf_moving_window : array2D_of_std_logic_vector((KERN_SIZE-1) downto 0)((KERN_SIZE-1)  downto 0)(0 downto 0);
	 SIGNAL mf_window_valid  : array2D_of_std_logic((KERN_SIZE-1) downto 0)((KERN_SIZE-1)  downto 0);
	 SIGNAL mf_data_valid    : STD_LOGIC;

begin

	--Instantiate morphological_fifo
	MF : morphological_fifo
	generic map ( PIX_SIZE  => 1,
	              KERN_SIZE => KERN_SIZE)
	port map    ( clk => clk,
	              reset_n => reset_n,
					  img_width => img_width,
					  img_height => img_height,
					  pix(0) => pix,
					  data_valid => data_valid,
					  moving_window => mf_moving_window,
					  window_valid => mf_window_valid,
					  data_valid_out => mf_data_valid);

	--Perform the dilation to the input image calculating the maximum
	--of the pixels of the moving_window with a 1 in the KERNEL
	dilation: process (mf_moving_window, clk)
		variable result : std_ulogic;
	begin
		result := '0';
		for i in 0 to (KERN_SIZE-1) loop
			for j in 0 to (KERN_SIZE-1) loop
				if mf_window_valid(i)(j) = '1' and
				KERNEL(i)(j) = 1 then
					result := result or mf_moving_window(i)(j)(0);
				end if;
			end loop;
		end loop;

		if rising_edge(clk) then
			if reset_n <= '0' then
				pix_out <= '0';
				data_valid_out <= '0';
			else
				pix_out <= result;
				data_valid_out <= mf_data_valid;
			end if;
		end if;
	end process;

end arch;
