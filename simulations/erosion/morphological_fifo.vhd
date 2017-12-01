------------------------------------------------------------------------
-- morphological_fifo
------------------------------------------------------------------------
-- morphological_fifo
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
	
entity morphological_fifo is
    generic (
        --Basic configuration of the component
		    -- Size of each pixel (binary image by default)
          PIX_SIZE  : integer := 1;
		    --Size of the kernel moving along the image (3x3 by default)
			 KERN_SIZE : integer := 3;
		  --Advanced features
		    --Maximum line width. Defines the depth of the memory that stores 
			 --lines. In a system that can change resolution should be the 
			 --size of the width of the maximum resolution allowed.
			 --Default resolution is 640x480 so max width is 640.
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
end morphological_fifo;

architecture arch of erosion is
	--Variables to save pixels needed to show the moving window
	--pix_buff stores (KERN_SIZE-1) previous lines
	 SIGNAL pix_buff :array2D_of_std_logic_vector((KERN_SIZE-2) downto 0)((MAX_WIDTH-1) downto 0)((PIX_SIZE-1) downto 0);
	 --pix_buff_last stores last values and needs to be only KERN_SIZE depth
	 SIGNAL pix_buff_last:array_of_std_logic_vector((KERN_SIZE-1) downto 0)((PIX_SIZE-1) downto 0);
begin

	--Save the previous (KERN_SIZE) lines in memory
		--Full image width lines. They are (KERN_SIZE-1) lines
		Pix_buffer_generate: for LINE_I in 0 to (KERN_SIZE-2) generate
			Line_generate: for PIX_I in 0 to (MAX_WIDTH-1) generate
			
				Regular_lines: if LINE_I < (KERN_SIZE-2) generate
					Reg_line_regular_pixels: if PIX_I<(MAX_WIDTH-1) 
						Update_pix_proc: process(clk) begin
						if rising_edge(clk) then
							if reset_n = '1' then
								pix_buff(LINE_I)(PIX_I) <= (others => '0');
							elsif (data_valid = '1') then
								if (PIX_I<(img_width-1)) then --regular pixels
									pix_buff(LINE_I)(PIX_I) <= pix_buff(LINE_I)(PIX_I+1);
								elsif (PIX_I=(img_width-1)) then --last pixel used in line
									pix_buff(LINE_I)(PIX_I) <= pix_buff(LINE_I+1)(0);
								else --not used pixel
									pix_buff(LINE_I)(PIX_I) <= (others => '0');
							end if;
						end if;
						end process;
					end generate Reg_line_regular_pixels
					
					Reg_line_last_pixel: if PIX_I=(MAX_WIDTH-1) 
						Update_pix_proc: process(clk) begin
						if rising_edge(clk) then
							if reset_n = '1' then 
								pix_buff(LINE_I)(PIX_I) <= (others => '0');
							elsif (data_valid = '1') then
								if (PIX_I=(img_width-1)) then --last pixel used in line
									pix_buff(LINE_I)(PIX_I) <= pix_buff(LINE_I+1)(0);
								else --not used
									pix_buff(LINE_I)(PIX_I) <= (others => '0');
							end if;
						end if;
						end process;
					end generate Reg_line_last_pixel;
				end generate Regular_lines;
			
				Last_line: if LINE_I = (KERN_SIZE-2) generate
					Last_line_regular_pixels: if PIX_I<(MAX_WIDTH-1) 
						Update_pix_proc: process(clk) begin
						if rising_edge(clk) then
							if reset_n = '1' then 
								pix_buff(LINE_I)(PIX_I) <= (others => '0');
							elsif (data_valid = '1') then
								if (PIX_I<(img_width-1)) then --regular pixels
									pix_buff(LINE_I)(PIX_I) <= pix_buff(LINE_I)(PIX_I+1);
								elsif (PIX_I=(img_width-1)) then --last pixel used in line
									pix_buff(LINE_I)(PIX_I) <= pix_buff_last(0);
								else
									pix_buff(LINE_I)(PIX_I) <= (others => '0');
								end if;
							end if;
						end if;
						end process;
					end generate Last_line_regular_pixels
				
					Last_line_last_pixel: if PIX_I=(MAX_WIDTH-1) 
						Update_pix_proc: process(clk) begin
						if rising_edge(clk) then
							if reset_n = '1' then 
								pix_buff(LINE_I)(PIX_I) <= (others => '0');
							elsif (data_valid = '1') then
								if (PIX_I=(img_width-1)) then --last pixel used in line
									pix_buff(LINE_I)(PIX_I) <= pix_buff_last(0);
								else
									pix_buff(LINE_I)(PIX_I) <= (others => '0');
								end if;
							end if;
						end if;
						end process;
					end generate Last_line_last_pixel;
				end generate Last_line;
			
			end generate Line_generate;
		end generate Pix_buffer_generate;
		
		--Last line of the buffer only stores KERN_SIZE PIXELS
		Last_Line_generate: for PIX_I in 0 to (MAX_WIDTH-1) generate
			
			Regular_pixels: if PIX_I<(KERN_SIZE-1) generate
				Update_pix_proc: process(clk) begin
				if rising_edge(clk) then
					if reset_n = '1' then 
						pix_buff(LINE_I)(PIX_I) <= (others => '0');
					else if (data_valid = '1') then
						pix_buff(LINE_I)(PIX_I) <= pix_buff(LINE_I)(PIX_I+1);
					end if;
				end if;
				end process;
			end generate Reg_line_regular_pixels;
			
			Last_pixel: if PIX_I=(KERN_SIZE-1) generate
				Update_pix_proc: process(clk) begin
				if rising_edge(clk) then
					if reset_n = '1' then 
						pix_buff(LINE_I)(PIX_I) <= (others => '0');
					else if (data_valid = '1') then
						pix_buff(LINE_I)(PIX_I) <= pix;
					end if;
				end if;
				end process;
			end generate Last_pixel;
		end generate Line_generate;
		
	--Generate the data_valid output. It is one clock cycle delayed from input
		Data_valid_proc: process(clk) begin
			if rising_edge(clk) then
				if reset_n = '1' then 
					data_valid_out <= (others => '0');
				else
					data_valid_out <= data_valid;
				end if;
			end if;
		end process;
		
	--Map the moving_window output to the memory elements of the pix_buffer
	Mapping: for LINE_I in 0 to (KERN_SIZE-1) generate
		Line_generate: for PIX_I in 0 to (KERN_SIZE-1) generate
			Regular_lines: if LINE_I < (KERN_SIZE-1) generate 
				moving_window(LINE_I)(PIX_I) <= pix_buff(LINE_I)(PIX_I);
			end generate Regular_lines;
			Last_line: if LINE_I = (KERN_SIZE-1) generate 
				moving_window(LINE_I)(PIX_I) <= pix_buff_last(LINE_I)(PIX_I);
			end generate Last_line;
		end generate Line_generate;
	end generate Mapping;
end arch;