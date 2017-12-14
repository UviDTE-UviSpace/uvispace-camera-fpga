---Avalon Bridge
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.math_real.all;          -- For using ceil and log2.

ENTITY avalon_write_bridge_128 IS
    GENERIC (
		  MASTER_ADDRESS_SIZE  		   : integer := 32;
		  BURSCOUNT_SIZE			   : integer := 7
    );
    PORT (
			clk             		: IN STD_LOGIC;
			reset_n         		: IN STD_LOGIC;
			--avalon master
			avm_write_address		: OUT STD_LOGIC_VECTOR((MASTER_ADDRESS_SIZE-1) downto 0);
			avm_write_write  		: OUT STD_LOGIC;
			avm_write_byteenable : OUT STD_LOGIC_VECTOR((16 - 1) downto 0);
			avm_write_writedata  : OUT STD_LOGIC_VECTOR((128-1) downto 0);
			avm_write_waitrequest: IN  STD_LOGIC;
			avm_write_burstcount	: OUT STD_LOGIC_VECTOR((BURSCOUNT_SIZE-1) downto 0);
			--avalon slave
			avs_write_address		: IN STD_LOGIC_VECTOR((MASTER_ADDRESS_SIZE - 4 - 1 ) downto 0);
			avs_write_write  		: IN STD_LOGIC;
			avs_write_byteenable : IN STD_LOGIC_VECTOR((16-1) downto 0);
			avs_write_writedata  : IN STD_LOGIC_VECTOR((128-1) downto 0);
			avs_write_waitrequest: OUT STD_LOGIC;
			avs_write_burstcount	: IN STD_LOGIC_VECTOR((BURSCOUNT_SIZE-1) downto 0)
    );
END avalon_write_bridge_128;


ARCHITECTURE arch OF avalon_write_bridge_128 IS
BEGIN
	avm_write_address((MASTER_ADDRESS_SIZE-1) downto 4) <= avs_write_address;
	avm_write_address(3 downto 0) <= ( others => '0');
	avm_write_write <= avs_write_write;
	avm_write_byteenable <= avs_write_byteenable;
	avm_write_writedata <= avs_write_writedata;
	avs_write_waitrequest <= avm_write_waitrequest;
	avm_write_burstcount <= avs_write_burstcount;

END arch;
