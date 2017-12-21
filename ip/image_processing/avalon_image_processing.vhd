------------------------------------------------------------------------
-- avalon_image_processing component
------------------------------------------------------------------------
-- Connects the processor and the image_processing component so
-- the image processing parameters can be changed from software
-- It is a custom component for this application. 
------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.math_real.all;          -- For using ceil and log2.
use IEEE.NUMERIC_STD.all;        -- For using to_unsigned.
use ieee.std_logic_unsigned.all; -- Needed for the sum used in counter.

entity avalon_image_processing is
    generic(
        --Default value of the registers
		  HUE_THRESHOLD_L  : integer := 220;
		  HUE_THRESHOLD_H  : integer := 30;
		  BRIGHTNESS_THRESHOLD_L  : integer := 60;
		  BRIGHTNESS_THRESHOLD_H  : integer := 255;
		  SATURATION_THRESHOLD_L  : integer := 60;
		  SATURATION_THRESHOLD_H  : integer := 255
    );
    port (
        -- Clock and reset.
        clk             : in STD_LOGIC;
        reset_n         : in STD_LOGIC;
        
		  -- Avalon MM Slave port to access from processor
		  S_address 		:in STD_LOGIC_VECTOR(6 downto 0);  --Address bus (4byte word addresses)
		  S_writedata		:in STD_LOGIC_VECTOR(31 downto 0); --Input data bus (4byte word)
		  S_readdata		:out STD_LOGIC_VECTOR(31 downto 0);--Output data bus (4byte word)
		  S_write			:in STD_LOGIC;	--Write signal
		  S_read				:in STD_LOGIC; --Read signal
			
        -- Signals to export to the image_processing component
        hue_threshold_l_out         : out STD_LOGIC_VECTOR(7 downto 0);
        hue_threshold_h_out         : out STD_LOGIC_VECTOR(7 downto 0);
        brightness_threshold_l_out  : out STD_LOGIC_VECTOR(7 downto 0);
		  brightness_threshold_h_out  : out STD_LOGIC_VECTOR(7 downto 0);
        saturation_threshold_l_out  : out STD_LOGIC_VECTOR(7 downto 0);
		  saturation_threshold_h_out  : out STD_LOGIC_VECTOR(7 downto 0) 
    );
end avalon_image_processing;

architecture arch of avalon_image_processing is

  --Internal register address map 
	 constant HUE_THRES_L_ADDRESS  : integer := 0;
	 constant HUE_THRES_H_ADDRESS  : integer := 1;
	 constant BRI_THRES_L_ADDRESS  : integer := 2;
	 constant BRI_THRES_H_ADDRESS  : integer := 3;
	 constant SAT_THRES_L_ADDRESS  : integer := 4;
	 constant SAT_THRES_H_ADDRESS  : integer := 5;
	 
  --Associated registers
	 signal hue_thres_l 	:STD_LOGIC_VECTOR(7 downto 0);
	 signal hue_thres_h 	:STD_LOGIC_VECTOR(7 downto 0);
	 signal bri_thres_l 	:STD_LOGIC_VECTOR(7 downto 0);
	 signal bri_thres_h 	:STD_LOGIC_VECTOR(7 downto 0);
	 signal sat_thres_l 	:STD_LOGIC_VECTOR(7 downto 0);
	 signal sat_thres_h 	:STD_LOGIC_VECTOR(7 downto 0);
  --Chip select
	 SIGNAL CS           : std_logic_vector((2**7-1) downto 0);
	 
begin

	--Chip select for Avalon slave registers
	CS_generate: for I in 0 to (2**7-1) generate
		CS(I) <= '1' when (I=S_address) else '0';
	end generate CS_generate;
	
	--Implement the logic of the registers connected to avalon slave
	avalon_slave: process (clk) begin
	if rising_edge(clk)  then
		if reset_n = '0' then --synchronous reset
			hue_thres_l <= std_logic_vector(to_unsigned(HUE_THRESHOLD_L, 8));
			hue_thres_h <= std_logic_vector(to_unsigned(HUE_THRESHOLD_H, 8));
			bri_thres_l <= std_logic_vector(to_unsigned(BRIGHTNESS_THRESHOLD_L, 8));
			bri_thres_h <= std_logic_vector(to_unsigned(BRIGHTNESS_THRESHOLD_H, 8));
			sat_thres_l <= std_logic_vector(to_unsigned(SATURATION_THRESHOLD_L, 8));
			sat_thres_h <= std_logic_vector(to_unsigned(SATURATION_THRESHOLD_H, 8));
		elsif S_write ='1' then --write operation
			if CS(HUE_THRES_L_ADDRESS)='1' then 
				hue_thres_l <= S_writedata(7 downto 0);
			elsif CS(HUE_THRES_H_ADDRESS)='1' then 
				hue_thres_h <= S_writedata(7 downto 0);
			elsif CS(BRI_THRES_L_ADDRESS)='1' then 
				bri_thres_l <= S_writedata(7 downto 0);
		   elsif CS(BRI_THRES_H_ADDRESS)='1' then 
				bri_thres_h <= S_writedata(7 downto 0);
			elsif CS(SAT_THRES_L_ADDRESS)='1' then 
				sat_thres_l <= S_writedata(7 downto 0);
			elsif CS(SAT_THRES_H_ADDRESS)='1' then 
				sat_thres_h <= S_writedata(7 downto 0);
			end if;	
	  end if;
	end if;
	if S_read ='1' then --read operation
		if CS(HUE_THRES_L_ADDRESS)='1' then 
			S_readdata <= (31 downto 8 => '0') & hue_thres_l;
		elsif CS(HUE_THRES_H_ADDRESS)='1' then 
			S_readdata <= (31 downto 8 => '0') & hue_thres_h;
		elsif CS(BRI_THRES_L_ADDRESS)='1' then 
			S_readdata <= (31 downto 8 => '0') & bri_thres_l;
		elsif CS(BRI_THRES_H_ADDRESS)='1' then 
			S_readdata <= (31 downto 8 => '0') & bri_thres_h;
		elsif CS(SAT_THRES_L_ADDRESS)='1' then 
			S_readdata <= (31 downto 8 => '0') & sat_thres_l;
		elsif CS(SAT_THRES_H_ADDRESS)='1' then 
			S_readdata <= (31 downto 8 => '0') & sat_thres_h;
		else
			S_readdata <= (others => '0');
		end if;
	end if;
	end process avalon_slave;

    -- Export the registers
	 hue_threshold_l_out <= hue_thres_l;
	 hue_threshold_h_out <= hue_thres_h;
	 brightness_threshold_l_out <= bri_thres_l;
	 brightness_threshold_h_out <= bri_thres_h;
	 saturation_threshold_l_out <= sat_thres_l;
	 saturation_threshold_h_out <= sat_thres_h;

end arch;