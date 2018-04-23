------------------------------------------------------------------------
-- morphological_fifo
------------------------------------------------------------------------
-- morphological_fifo is a memory that stores the lines needed to
-- perform a morphological operation to an image. Its output is the
-- pixels of the moving window that in conjuction with a kernel will
-- be used to perform the morphological operation. The size of the
-- moving window is KERN_SIZE x KERN_SIZE. PIX_SIZE is the number of bits
-- per pixel (1 for binary, 8 for 8-bit gray, and so on).
-- The moving window size in this component is fixed on compilation time,
-- but the width of the input image is not. The width is pased as a
-- parameter called img_width. This permits to change the resolution
-- of the image used without the need to recompile the hardware.
-- MAX_IMG_WIDTH specifies the maximum img_with that can be used because
-- it defines the depht of the internal buffers. User should set this
-- parameter as the witdh of the biggest resolution that will be used.
-- As usual, data_valid is used to know when a pixel is valid in the
-- input and data_valid_out does the same for the output.
------------------------------------------------------------------------
library IEEE;
	use IEEE.STD_LOGIC_1164.ALL;
	use ieee.math_real.all;          -- For using ceil and log2.
	use IEEE.NUMERIC_STD.all;        -- For using to_unsigned.
	use ieee.std_logic_unsigned.all; -- Needed for the sum used in counter.

LIBRARY work;
	use work.array_package.all;

entity morphological_fifo is
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
	  	data_valid    : in STD_LOGIC; --there is a valid pixel in pix

      -- Output signal is the moving window to do the morphological operation
	  	moving_window  : out array2D_of_std_logic_vector((KERN_SIZE-1) downto 0)((KERN_SIZE-1)  downto 0)((PIX_SIZE-1) downto 0);
	  	window_valid   : out array2D_of_std_logic((KERN_SIZE-1) downto 0)((KERN_SIZE-1)  downto 0);
	  	data_valid_out : out STD_LOGIC
  	);
end morphological_fifo;

architecture arch of morphological_fifo is

	COMPONENT shift_reg_ram is
		GENERIC(
			DATA_SIZE	:	integer	:=	8
		);
		PORT(
			clk             :	IN STD_LOGIC;
			reset_n			    :	IN STD_LOGIC;
			depth           : IN STD_LOGIC_VECTOR (15 downto 0);
			data_in         :	IN STD_LOGIC_VECTOR ((DATA_SIZE-1) DOWNTO 0);
			data_out        :	OUT STD_LOGIC_VECTOR ((DATA_SIZE-1) DOWNTO 0);
			data_valid      : IN STD_LOGIC;
			data_valid_out  : OUT STD_LOGIC
		);
		END COMPONENT;

	 --Enables propagation of data_valid input to data_valid_out output
	 --When doing morphological operations there is always a delay of
	 --(KERN_SIZE-1) lines and (KERN_SIZE-1) pixels between the moment
	 --the 1st pixel of the input image enters and the 1st pixel of the
	 --output image goes out. This variable helps to produce the waiting
	 --for this initial delay.
	 signal enable_data_valid    : STD_LOGIC;
	 --counters.
	 --Counts pixels in each line
	 signal pix_counter          : STD_LOGIC_VECTOR(23 downto 0);
	 --Counts lines
	 signal line_counter         : STD_LOGIC_VECTOR(23 downto 0);

	 --Variables to save pixels needed to show the moving window
	 --output of the shift_reg_rams
	 SIGNAL shift_reg_output:array_of_std_logic_vector((KERN_SIZE-2) downto 0)((PIX_SIZE-1) downto 0);
	 --pix_buff stores (KERN_SIZE-1) previous lines
	 SIGNAL pix_buff :array2D_of_std_logic_vector((KERN_SIZE-2) downto 0)((KERN_SIZE-1) downto 0)((PIX_SIZE-1) downto 0);
	 --pix_buff_last stores last values and needs to be only KERN_SIZE depth
	 SIGNAL pix_buff_last:array_of_std_logic_vector((KERN_SIZE-1) downto 0)((PIX_SIZE-1) downto 0);



begin
------------ Evaluation and update pix_counter and line counter-------------
		pix_counter_proc:process (clk)
		begin
			if rising_edge(clk) then
				if (reset_n = '0') then
					-- reset the pixel counter
					pix_counter <= (others => '0');
					line_counter <= (others => '0');
				elsif (data_valid = '1') then
					-- Increment the pixel counter
					if pix_counter = (img_width - 1) then
						pix_counter <= (others => '0');
						if line_counter = (img_height - 1) then
							line_counter <= (others => '0');
						else
							line_counter <= line_counter + 1;
						end if;
					else
						pix_counter <= pix_counter + 1;
					end if;
				end if;
			end if;
    end process;

---------------------------SAVE DATA IN MEMORY------------------
		--Implement the shif_reg_rams
		shift_reg_ram_generate: for LINE_I in 0 to (KERN_SIZE-2) generate
			Regular_lines: if LINE_I < (KERN_SIZE-2) generate
				shift_reg : shift_reg_ram
					generic map ( DATA_SIZE => PIX_SIZE)
					port map (
						clk => clk,
						data_in => pix_buff(LINE_I+1)(0),
						data_out => shift_reg_output(LINE_I),
						data_valid => data_valid,
						data_valid_out => open,
						depth => (img_width-KERN_SIZE),
						reset_n => reset_n
					);
			end generate Regular_lines;
			last_line: if  LINE_I = (KERN_SIZE-2) generate
				shift_reg : shift_reg_ram
					generic map ( DATA_SIZE => PIX_SIZE)
					port map (
						clk => clk,
						data_in => pix_buff_last(0),
						data_out => shift_reg_output(LINE_I),
						data_valid => data_valid,
						data_valid_out => open,
						depth => (img_width-KERN_SIZE),
						reset_n => reset_n
					);
			end generate last_line;
	  end generate shift_reg_ram_generate;

		--Save the previous (KERN_SIZE) lines in memory
		--Full image width lines. They are (KERN_SIZE-1) lines
		Pix_buffer_generate: for LINE_I in 0 to (KERN_SIZE-2) generate
			Line_generate: for PIX_I in 0 to (KERN_SIZE-1) generate
				Update_pix_proc: process(clk) begin
				if rising_edge(clk) then
					if reset_n = '0' then
						pix_buff(LINE_I)(PIX_I) <= (others => '0');
					elsif (data_valid = '1') then
						if PIX_I<(KERN_SIZE-1) then
							pix_buff(LINE_I)(PIX_I) <= pix_buff(LINE_I)(PIX_I+1);
						else --	if PIX_I=(KERN_SIZE-1)
							pix_buff(LINE_I)(PIX_I) <= shift_reg_output(LINE_I);
						end if;
					end if;
				end if;
				end process;
			end generate Line_generate;
		end generate Pix_buffer_generate;

		--Last line of the buffer only stores KERN_SIZE PIXELS
		Last_Line_generate: for PIX_I in 0 to (KERN_SIZE-1) generate

			Regular_pixels: if PIX_I<(KERN_SIZE-1) generate
				Update_pix_proc: process(clk) begin
				if rising_edge(clk) then
					if reset_n = '0' then
						pix_buff_last(PIX_I) <= (others => '0');
					elsif (data_valid = '1') then
						pix_buff_last(PIX_I) <= pix_buff_last(PIX_I+1);
					end if;
				end if;
				end process;
			end generate Regular_pixels;

			Last_pixel: if PIX_I=(KERN_SIZE-1) generate
				Update_pix_proc: process(clk) begin
				if rising_edge(clk) then
					if reset_n = '0' then
						pix_buff_last(PIX_I) <= (others => '0');
					elsif (data_valid = '1') then
						pix_buff_last(PIX_I) <= pix;
					end if;
				end if;
				end process;
			end generate Last_pixel;
		end generate Last_Line_generate;

----------------------------GENERATE OUTPUTS--------------------
	--Generate the data_valid output. It is one clock cycle delayed from input
	Data_valid_proc: process(clk) begin
		if rising_edge(clk) then
			if (reset_n = '0') then
				enable_data_valid <= '0';
				data_valid_out <= '0';
			else
				if (line_counter = (KERN_SIZE-1)/2) and (pix_counter = (KERN_SIZE-1)/2) and (data_valid = '1') then
					enable_data_valid <= '1';
					data_valid_out <= '1';
				elsif (enable_data_valid = '1') and (data_valid = '1')  then
					data_valid_out <= '1';
				else
					data_valid_out <= '0';
				end if;
			end if;
		end if;
	end process;

	--Map the moving_window output to the memory elements of the pix_buffer
	Window_Mapping: for LINE_I in 0 to (KERN_SIZE-1) generate
		Line_generate: for PIX_I in 0 to (KERN_SIZE-1) generate
			Regular_lines: if LINE_I < (KERN_SIZE-1) generate
				moving_window(LINE_I)(PIX_I) <= pix_buff(LINE_I)(PIX_I);
			end generate Regular_lines;
			Last_line: if LINE_I = (KERN_SIZE-1) generate
				moving_window(LINE_I)(PIX_I) <= pix_buff_last(PIX_I);
			end generate Last_line;
		end generate Line_generate;
	end generate Window_Mapping;

	--The whole output window should usually be used but in the borders only
	--some pixels are valid. The non valid pixels are from previous image
	--(top rows), next image (last rows), previous lines (1st pixels in a )
	--line) or next line (last ones). Only the pixels indicated in window_valid
	--should be used in the outter morphological operation with the kernel.
	Window_Valid_Mapping: for LINE_I in 0 to (KERN_SIZE-1) generate
		Line_generate: for PIX_I in 0 to (KERN_SIZE-1) generate
			win_valid_proc: process(clk,line_counter, pix_counter) begin

				if (pix_counter = 0) then
					if (line_counter<((KERN_SIZE+1)/2)) then
						if (LINE_I > (KERN_SIZE-line_counter-1)) then
							window_valid(LINE_I)(PIX_I) <= '0';
						else
							window_valid(LINE_I)(PIX_I) <= '1';
						end if;
					elsif (line_counter < KERN_SIZE) then
						if (LINE_I < (KERN_SIZE-line_counter)) then
							window_valid(LINE_I)(PIX_I) <= '0';
						else
							window_valid(LINE_I)(PIX_I) <= '1';
						end if;
					else
						window_valid(LINE_I)(PIX_I) <= '1';
					end if;

				elsif (pix_counter<((KERN_SIZE+1)/2)) then
					if (PIX_I > KERN_SIZE-pix_counter-1) then
						window_valid(LINE_I)(PIX_I) <= '0';
					else
						if (line_counter<(KERN_SIZE+1)/2) then
							if (LINE_I > (KERN_SIZE-line_counter-1)) then
								window_valid(LINE_I)(PIX_I) <= '0';
							else
								window_valid(LINE_I)(PIX_I) <= '1';
							end if;
						elsif (line_counter < KERN_SIZE) then
							if (LINE_I < (KERN_SIZE-line_counter)) then
								window_valid(LINE_I)(PIX_I) <= '0';
							else
								window_valid(LINE_I)(PIX_I) <= '1';
							end if;
						else
							window_valid(LINE_I)(PIX_I) <= '1';
						end if;
					end if;

				elsif (pix_counter < KERN_SIZE) then
					if (PIX_I < KERN_SIZE-pix_counter) then
						window_valid(LINE_I)(PIX_I) <= '0';
					else
						if (line_counter<((KERN_SIZE-1)/2)) then
							if (LINE_I > (KERN_SIZE-line_counter-2)) then
								window_valid(LINE_I)(PIX_I) <= '0';
							else
								window_valid(LINE_I)(PIX_I) <= '1';
							end if;
						elsif (line_counter < (KERN_SIZE-1)) then
							if (LINE_I < (KERN_SIZE-line_counter-1)) then
								window_valid(LINE_I)(PIX_I) <= '0';
							else
								window_valid(LINE_I)(PIX_I) <= '1';
							end if;
						else
							window_valid(LINE_I)(PIX_I) <= '1';
						end if;
					end if;

				else
					if (line_counter<((KERN_SIZE-1)/2)) then
						if (LINE_I > (KERN_SIZE-line_counter-2)) then
							window_valid(LINE_I)(PIX_I) <= '0';
						else
							window_valid(LINE_I)(PIX_I) <= '1';
						end if;
					elsif (line_counter < KERN_SIZE) then
						if (LINE_I < (KERN_SIZE-line_counter-1)) then
							window_valid(LINE_I)(PIX_I) <= '0';
						else
							window_valid(LINE_I)(PIX_I) <= '1';
						end if;
					else
						window_valid(LINE_I)(PIX_I) <= '1';
					end if;
				end if;

			end process;
		end generate Line_generate;
	end generate Window_Valid_Mapping;

end arch;
