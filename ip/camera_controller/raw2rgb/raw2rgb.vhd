clklibrary ieee;
	use ieee.math_real.all;
	use ieee.std_logic_1164.all;
	use ieee.numeric_std.all;			 -- casting int to unsigned
	use ieee.std_logic_textio.all; -- read std_vector_logic from a file

library work;
	use work.array_package.all;

entity raw2rgb is
	-- genereric()        PIX_SIZE : integer :=8;

	port (
		--clk : in/out std_logic;
		-- img_width :in/out std_logic_vector(15 downto 0);
		iX_Cont 		IN STD_LOGIC_VECTOR (10 DOWNTO 0);
		iY_Cont 		IN STD_LOGIC_VECTOR (10 DOWNTO 0);
		pix 				IN STD_LOGIC_VECTOR (11 DOWNTO 0); --iDATA, pixel input
		data_valid	IN STD_LOGIC;--iDVAL, data valid input
		clk					IN STD_LOGIC; --iCLK
		reset_n			IN STD_LOGIC; --iRST
		img_width		IN STD_LOGIC_VECTOR(15 downto 0);
		img_height	IN STD_LOGIC_VECTOR(15 downto 0);
		oRed				OUT STD_LOGIC_VECTOR (11 DOWNTO 0);
		oGreen			OUT STD_LOGIC_VECTOR (11 DOWNTO 0);
		oBlue				OUT STD_LOGIC_VECTOR (11 DOWNTO 0);
		oDVAL				OUT STD_LOGIC
	);
end raw2rgb;

architecture arch of raw2rgb is
	component morphological_fifo
		generic (
			-- Basic configuration of the component:
			-- Size of each pixel (R, G1, G2 or B)
			PIX_SIZE	:	integer	:=	12;
			--Size of the kernel moving along the image (3x3 by default)
			KERN_SIZE	:	integer	:=	3;
			--Default resolution is 640x480 so max width is 640.
			MAX_IMG_WIDTH	:	integer	:=	640
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
			moving_window		: out array2D_of_std_logic_vector((KERN_SIZE-1) downto 0)
														((KERN_SIZE-1)  downto 0)((PIX_SIZE-1) downto 0);
			window_valid		: out array2D_of_std_logic((KERN_SIZE-1) downto 0)
														((KERN_SIZE-1)  downto 0);
			data_valid_out	: out STD_LOGIC
		);
	end component;
	--signal declarations (example: signal enable_data_valid    : STD_LOGIC;)
	--Module internal signals:
	SIGNAL mf_moving_window : array2D_of_std_logic_vector((KERN_SIZE-1) downto 0)((KERN_SIZE-1)  downto 0)(0 downto 0);
	SIGNAL mf_window_valid  : array2D_of_std_logic((KERN_SIZE-1) downto 0)	((KERN_SIZE-1)  downto 0);
	SIGNAL mf_data_valid    : STD_LOGIC;
	SIGNAL sum_R	: STD_LOGIC_VECTOR (12 DOWNTO 0);
	SIGNAL sum_G	: STD_LOGIC_VECTOR (13 DOWNTO 0);
	SIGNAL sum_B	: STD_LOGIC_VECTOR (12 DOWNTO 0);

begin
	-- Instanciate signals declarations:
	MF_component : morphological_fifo
	generic map ( PIX_SIZE  		=> PIX_SIZE,
								KERN_SIZE 		=> KERN_SIZE,
								MAX_IMG_WIDTH => MAX_IMG_WIDTH)

	port map    ( clk 						=> clk,
								reset_n 				=> reset_n,
								img_width 			=> img_width,
								img_height 			=> img_height,
								pix 						=> pix,
								data_valid 			=> data_valid,
								moving_window 	=> mf_moving_window,
								window_valid 		=> mf_window_valid,
								data_valid_out 	=> mf_data_valid);


	raw2rgb_proc: process(clk)
	begin
		--considero 0,0 arriba der
		if mf_window_valid(1)(0) = '0' then --lateral der
			if mf_window_valid(0)(1) = '0' then
				--esquina superior der.
			elsif mf_window_valid(2)(1) = '0' then
				--esquina superior der.
			else
				--lateral der.
			end if;
		elsif mf_window_valid(1)(2) = '0' then --lateral der
			if mf_window_valid(0)(1) = '0' then
				--esquina superior izq.
			elsif mf_window_valid(2)(1) = '0' then
				--esquina superior izq.
			else
				--lateral izq.
			end if;
		elsif mf_window_valid(0)(1) = '0' then
			--zona superior
			-- if par.. else...
		elsif mf_window_valid(2)(1) = '0' then
			--zona inferior
			--if par...else...
		else
			--zona interior
			--if red..if blue..,if green1..if green2
		end if;





	--Asignments:
	fifo_write_en <= data_valid and (not iY_Cont(0)) ;
	fifo_read_en <= data_valid and  iY_Cont(0) ;
	--Output signals:
	oRed		<=	mCCD_R;
	oGreen 	<=	mCCD_G; --ojo mCCD_G variable de 13 bit, no 12
	oBlue		<=	mCCD_B;
	oDVAL		<=	mDVAL;
	begin
		process(clk)
			if rising_edge(clk) then
				if reset_n <= 0 then
					--pongo a cero registros
				else
					--trabajo normal
				end if;

			end if;
		end process;
end arch;
