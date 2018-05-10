------------------------------------------------------------------------
-- raw2rgb
------------------------------------------------------------------------
-- Module for converting input RAW data to RGB values.

-- The input data presents the 'Bayer patter' i.e. There are 4 different
-- components (G1-R-B-G2): Even rows contain the first green component
-- (G1) and the red one; whereas the odd rows contain the blue component
-- and the second green one (G2). However, the camera is configured with
-- the mirror mode (both rows and columns are mirrored) and the previous
-- pattern is inverted.

-- The output data has an RGB format. There is a output pixel (RGB) for
-- each imput pixel (R, G1, G2 or B) in the component. Each output pixel
-- is formed by merging the pixel in the same position at the input and
-- 8 surrounding pixels, and getting the average value of each colour.In
-- case that there is a odd number of pixels of one colour, one is rejec-
-- ted to simplify de division.
------------------------------------------------------------------------

library ieee;
	use ieee.math_real.all;
	use ieee.std_logic_1164.all;
	use ieee.numeric_std.all;					-- casting int to unsigned
	use ieee.std_logic_textio.all;		-- read std_vector_logic from a file
	use ieee.std_logic_unsigned.all;	-- Needed for the sum used in counter.

library work;
	use work.array_package.all;

entity raw2rgb is
	generic (
		-- Basic configuration of the component:
		-- Size of each pixel (R, G1, G2 or B)
		PIX_SIZE	:	integer	:=	12
	);
	port (
		pix 				:	IN STD_LOGIC_VECTOR (11 DOWNTO 0); --iDATA, pixel input
		data_valid	:	IN STD_LOGIC;--iDVAL, data valid input
		clk					:	IN STD_LOGIC; --iCLK
		reset_n			:	IN STD_LOGIC; --iRST
		img_width		:	IN STD_LOGIC_VECTOR(15 downto 0);
		img_height	:	IN STD_LOGIC_VECTOR(15 downto 0);
		oRed				:	OUT STD_LOGIC_VECTOR (11 DOWNTO 0);
		oGreen			:	OUT STD_LOGIC_VECTOR (11 DOWNTO 0);
		oBlue				:	OUT STD_LOGIC_VECTOR (11 DOWNTO 0);
		oDVAL				:	OUT STD_LOGIC
	);
end raw2rgb;

architecture arch of raw2rgb is
	component morphological_fifo
		generic (
			-- Basic configuration of the component:
			-- Size of each pixel (R, G1, G2 or B)
			PIX_SIZE	:	integer	:=	12;
			--Size of the kernel moving along the image (3x3 by default)
			KERN_SIZE	:	integer	:=	3
		);
		port(
			-- Clock and reset.
			clk				: in STD_LOGIC;
			reset_n		: in STD_LOGIC;
			-- Configuration.
			img_width		:in STD_LOGIC_VECTOR(15 downto 0);
			img_height	:in STD_LOGIC_VECTOR(15 downto 0);
			-- Input image and sync signals
			pix					: in STD_LOGIC_VECTOR((PIX_SIZE - 1) downto 0);--one pixel
			data_valid	: in STD_LOGIC; --there is a valid pixel in pix
			-- Output signal is the moving window to do the morphological operation
			moving_window		: out array2D_of_std_logic_vector((KERN_SIZE-1) downto 0)((KERN_SIZE-1)  downto 0)((PIX_SIZE-1) downto 0);
			window_valid		: out array2D_of_std_logic((KERN_SIZE-1) downto 0)((KERN_SIZE-1)  downto 0);
			data_valid_out	: out STD_LOGIC
		);
	end component;
	--Size of the kernel moving along the image (3x3 by default)
	constant KERN_SIZE	:	integer	:=	3;

	--signal declarations (example: signal enable_data_valid    : STD_LOGIC;)
	--Module internal signals:
	SIGNAL mf_moving_window2 : array2D_of_std_logic_vector((KERN_SIZE-1) downto 0)((KERN_SIZE-1)  downto 0)((PIX_SIZE - 1) downto 0);
	SIGNAL mf_moving_window : array2D_of_std_logic_vector((KERN_SIZE-1) downto 0)((KERN_SIZE-1)  downto 0)((PIX_SIZE + 1) downto 0);
	SIGNAL mf_window_valid  : array2D_of_std_logic((KERN_SIZE-1) downto 0)((KERN_SIZE-1)  downto 0);
	SIGNAL mf_data_valid    : STD_LOGIC;
	SIGNAL sum_R		: STD_LOGIC_VECTOR ((PIX_SIZE + 1) DOWNTO 0);
	SIGNAL sum_G		: STD_LOGIC_VECTOR ((PIX_SIZE + 1) DOWNTO 0);
	SIGNAL sum_B		: STD_LOGIC_VECTOR ((PIX_SIZE + 1) DOWNTO 0);
	SIGNAL pix_R		: STD_LOGIC_VECTOR ((PIX_SIZE + 1) DOWNTO 0);
	SIGNAL pix_G		: STD_LOGIC_VECTOR ((PIX_SIZE + 1) DOWNTO 0);
	SIGNAL pix_B		: STD_LOGIC_VECTOR ((PIX_SIZE + 1) DOWNTO 0);
	SIGNAL iX_Cont 	: STD_LOGIC_VECTOR (12 DOWNTO 0);
	SIGNAL iY_Cont	: STD_LOGIC_VECTOR (12 DOWNTO 0);


begin
	-- Instanciate signals declarations:
	MF_component : morphological_fifo
	generic map ( PIX_SIZE  		=> PIX_SIZE,
								KERN_SIZE 		=> KERN_SIZE)

	port map    ( clk 						=> clk,
								reset_n 				=> reset_n,
								img_width 			=> img_width,
								img_height 			=> img_height,
								pix 						=> pix,
								data_valid 			=> data_valid,
								moving_window 	=> mf_moving_window2,
								window_valid 		=> mf_window_valid,
								data_valid_out 	=> mf_data_valid--,
								--pix_col					=> iX_Cont,
								--pix_row					=> iY_Cont
								);

window_move:for i in 0 to (KERN_SIZE-1) generate
		window_move2: for j in 0 to (KERN_SIZE-1) generate
			mf_moving_window(i)(j) <= '0' & '0' & mf_moving_window2(i)(j);
		end generate;
end generate;

pix_counter_proc:process (clk)
begin
	if rising_edge(clk) then
		if (reset_n = '0') then
			-- reset the pixel counter
			iX_Cont <= (others => '0');
			iY_Cont <= (others => '0');
		elsif (mf_data_valid = '1') then
			-- Increment the pixel counter
			if iX_Cont = (img_width - 1) then
				iX_Cont <= (others => '0');
				if iY_Cont = (img_height - 1) then
					iY_Cont <= (others => '0');
				else
					iY_Cont <= iY_Cont + 1;
				end if;
			else
				iX_Cont <= iX_Cont + 1;
			end if;
		end if;
	end if;
end process;

------------ Evaluation and update pix_counter and line counter-------------
raw2rgb_proc: process(mf_moving_window,sum_R,sum_G,sum_B) begin
	if mf_window_valid(1)(0) = '0' then -- (image's pixel in the) first column
			if mf_window_valid(0)(1) = '0' then -- first column & first row
				--G2 pixel:
				sum_R <= mf_moving_window(2)(1);
				sum_G <= mf_moving_window(1)(1) + mf_moving_window(2)(2);
				sum_B <= mf_moving_window(1)(2);
				pix_R <= sum_R;
				pix_G <= '0' & sum_G((PIX_SIZE + 1) downto 1);
				pix_B <= sum_B;
			elsif mf_window_valid(2)(1) = '0' then -- first column & last row
				--R pixel
				sum_R <= mf_moving_window(1)(1);
				sum_G <= mf_moving_window(1)(2) + mf_moving_window(0)(1);
				sum_B <= mf_moving_window(0)(2);
				pix_R <= sum_R;
				pix_G <= '0' & sum_G((PIX_SIZE + 1) downto 1);
				pix_B <= sum_B;
			else -- first column & no corner
				if (iY_Cont(0) = '0') then --if (iX_Cont(0) = '0') then
					--G2 pixel
					sum_R <= mf_moving_window(0)(1) + mf_moving_window(2)(1);
					sum_G <= mf_moving_window(0)(2) + mf_moving_window(2)(2);
					sum_B <= mf_moving_window(1)(2);
					pix_R <= '0' & sum_R((PIX_SIZE + 1) downto 1);
					pix_G <= '0' & sum_G((PIX_SIZE + 1) downto 1);
					pix_B <= sum_B;
				else
					--R pixel
					sum_R <= mf_moving_window(1)(1);
					sum_G <= mf_moving_window(0)(1) + mf_moving_window(2)(1);
					sum_B <= mf_moving_window(0)(2) + mf_moving_window(2)(2);
					pix_R <= sum_R;
					pix_G <= '0' & sum_G((PIX_SIZE + 1) downto 1);
					pix_B <= '0' & sum_B((PIX_SIZE + 1) downto 1);
				end if;
			end if;
		elsif mf_window_valid(1)(2) = '0' then -- last column
			if mf_window_valid(0)(1) = '0' then -- last column & first row
				--B pixel
				sum_R <= mf_moving_window(2)(0);
				sum_G <= mf_moving_window(1)(0) + mf_moving_window(2)(1);
				sum_B <= mf_moving_window(1)(1);
				pix_R <= sum_R;
				pix_G <= '0' & sum_G((PIX_SIZE + 1) downto 1);
				pix_B <= sum_B;
			elsif mf_window_valid(2)(1) = '0' then -- last column & last row
				--G1 pixels
				sum_R <= mf_moving_window(1)(0);
				sum_G <= mf_moving_window(1)(1) + mf_moving_window(0)(0);
				sum_B <= mf_moving_window(0)(1);
				pix_R <= sum_R;
				pix_G <= '0' & sum_G((PIX_SIZE + 1) downto 1);
				pix_B <= sum_B;
			else -- last column & no corner
				if (iY_Cont(0) = '0') then --if (iX_Cont(0) = '0') then
					--B pixel
					sum_R <= mf_moving_window(0)(0) + mf_moving_window(2)(0);
					sum_G <= mf_moving_window(0)(1) + mf_moving_window(2)(1);
					sum_B <= mf_moving_window(1)(1);
					pix_R <= '0' & sum_R((PIX_SIZE + 1) downto 1);
					pix_G <= '0' & sum_G((PIX_SIZE + 1) downto 1);
					pix_B <= sum_B;
				else
					--G1 pixel
					sum_R <= mf_moving_window(1)(0);
					sum_G <= mf_moving_window(0)(0) + mf_moving_window(2)(0);
					sum_B <= mf_moving_window(0)(1) + mf_moving_window(2)(1);
					pix_R <= sum_R;
					pix_G <= '0' & sum_G((PIX_SIZE + 1) downto 1);
					pix_B <= '0' & sum_B((PIX_SIZE + 1) downto 1);
				end if;
			end if;
		elsif mf_window_valid(0)(1) = '0' then -- first row & no corner
			if (iX_Cont(0) = '0') then
				--G2 pixel
				sum_R <= mf_moving_window(2)(1);
				sum_G <= mf_moving_window(2)(0) + mf_moving_window(2)(2);
				sum_B <= mf_moving_window(1)(0) + mf_moving_window(1)(2);
				pix_R <= sum_R;
				pix_G <= '0' & sum_G((PIX_SIZE + 1) downto 1);
				pix_B <= '0' & sum_B((PIX_SIZE + 1) downto 1);
			else
				--B pixel
				sum_R <= mf_moving_window(2)(0) + mf_moving_window(2)(2);
				sum_G <= mf_moving_window(1)(0) + mf_moving_window(1)(2);
				sum_B <= mf_moving_window(1)(1);
				pix_R <= '0' & sum_R((PIX_SIZE + 1) downto 1);
				pix_G <= '0' & sum_G((PIX_SIZE + 1) downto 1);
				pix_B <= sum_B;
			end if;
		elsif mf_window_valid(2)(1) = '0' then -- last row & no corner
			if (iX_Cont(0) = '0') then
				--R pixel
				sum_R <= mf_moving_window(1)(1);
				sum_G <= mf_moving_window(1)(0) + mf_moving_window(1)(2);
				sum_B <= mf_moving_window(0)(0) + mf_moving_window(0)(2);
				pix_R <= sum_R;
				pix_G <= '0' & sum_G((PIX_SIZE + 1) downto 1);
				pix_B <= '0' & sum_B((PIX_SIZE + 1) downto 1);
			else
				--G1 pixel
				sum_R <= mf_moving_window(1)(0) + mf_moving_window(1)(2);
				sum_G <= mf_moving_window(0)(0) + mf_moving_window(0)(2);
				sum_B <= mf_moving_window(0)(1);
				pix_R <= '0' & sum_R((PIX_SIZE + 1) downto 1);
				pix_G <= '0' & sum_G((PIX_SIZE + 1) downto 1);
				pix_B <= sum_B;
			end if;
		else -- image's internal area
			if (iX_Cont(0) = '1' and iY_Cont(0) = '1') then --even row % even column
				-- G1 pixel (Red Green row)
				sum_R <= mf_moving_window(1)(0) + mf_moving_window(1)(2);
				sum_G <= mf_moving_window(0)(0) + mf_moving_window(0)(2) + mf_moving_window(2)(0) + mf_moving_window(2)(2);
				sum_B <= mf_moving_window(0)(1) + mf_moving_window(2)(1);
				pix_R <= '0' & sum_R((PIX_SIZE + 1) downto 1);
				pix_G <= '0' & '0' & sum_G((PIX_SIZE + 1) downto 2);
				pix_B <= '0' & sum_B((PIX_SIZE + 1) downto 1);
			elsif (iX_Cont(0) = '0' and iY_Cont(0) = '1') then --even row % odd col.
				-- R pixel
				sum_R <= mf_moving_window(1)(1);
				sum_G <= mf_moving_window(0)(1) + mf_moving_window(2)(1) + mf_moving_window(1)(0) + mf_moving_window(1)(2);
				sum_B <= mf_moving_window(0)(0) + mf_moving_window(0)(2) + mf_moving_window(2)(0) + mf_moving_window(2)(2);
				pix_R <= sum_R;
				pix_G <= '0' & '0' & sum_G((PIX_SIZE + 1) downto 2);
				pix_B <= '0' & '0' & sum_B((PIX_SIZE + 1) downto 2);
			elsif (iX_Cont(0) = '1' and iY_Cont(0) = '0') then --odd row % even col.
				-- B pixel
				sum_R <= mf_moving_window(0)(0) + mf_moving_window(0)(2) + mf_moving_window(2)(0) + mf_moving_window(2)(2);
				sum_G <= mf_moving_window(1)(0) + mf_moving_window(1)(2) + mf_moving_window(0)(1) + mf_moving_window(2)(1);
				sum_B <= mf_moving_window(1)(1);
				pix_R <= '0' & '0' & sum_R((PIX_SIZE + 1) downto 2);
				pix_G <= '0' & '0' & sum_G((PIX_SIZE + 1) downto 2);
				pix_B <= sum_B;
			else --odd row & odd column
				-- G2 pixel (Blue Green row)
				sum_R <= mf_moving_window(0)(1) + mf_moving_window(2)(1);
				sum_G <= mf_moving_window(0)(0) + mf_moving_window(0)(2) + mf_moving_window(2)(0) + mf_moving_window(2)(2);
				sum_B <= mf_moving_window(1)(0) + mf_moving_window(1)(2);
				pix_R <= '0' & sum_R((PIX_SIZE + 1) downto 1);
				pix_G <= '0' & '0' & sum_G((PIX_SIZE + 1) downto 2);
				pix_B <= '0' & sum_B((PIX_SIZE + 1) downto 1);
			end if;
						-- ** In the cases that the kernel area includes 3 or 5 pixels of a
						-- 		color the system only considers 2 or 4 in order to simplify
						--		division operation (using multiple of 2 numbers).
		end if;
end process;
outputs_proc: process(clk) begin
		if rising_edge(clk) then
					oRed		<= pix_R(11 downto 0);
					oGreen	<= pix_G(11 downto 0);
					oBlue		<= pix_B(11 downto 0);
					oDVAL	 <= mf_data_valid;
		end if;
	end process;
end arch;
