------------------------------------------------------------------
-- hsv2bin component
------------------------------------------------------------------
-- This component gets inputRGB pixel and outputs the equvalent
-- gray pixel doing (2xG+R+B)/4
------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_UNSIGNED.ALL;--to make +


entity rgb2gray is
    generic(
        -- Size of each pixel component
        COMPONENT_SIZE  : integer := 8
    );
    port(
        -- Control signals
        clk			: in STD_LOGIC;
        reset_n	: in STD_LOGIC;
        -- Data input
		  R      	: in STD_LOGIC_VECTOR(COMPONENT_SIZE-1 downto 0);
        G      	: in STD_LOGIC_VECTOR(COMPONENT_SIZE-1 downto 0);
        B	   	: in STD_LOGIC_VECTOR(COMPONENT_SIZE-1 downto 0);
		  in_valid	: in STD_LOGIC;
        -- Data output
		  Gray 		: out STD_LOGIC_VECTOR(COMPONENT_SIZE-1 downto 0); 
		  out_valid	: out STD_LOGIC
        );
end rgb2gray;


--Component architecture
architecture arch of rgb2gray is
	--Add 2 bits more than COMPONENT SIZE so the sum can fit
	signal Gray_aux: STD_LOGIC_VECTOR(COMPONENT_SIZE+1 downto 0);
begin
	--Convert RGB into gray in a single clock cycle
	--Add 2 times green,1 time red and 1 time blue
	add_proc: process(R, G, B)
	begin
		Gray_aux <= ('0' & G & '0') + ("00" & R) + ("00" & R) ; 
	end process;
	--and divide by 4
	Gray <= Gray_aux(COMPONENT_SIZE+1 downto 2);
	
	out_valid <= in_valid;
end arch;