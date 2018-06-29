-- Copyright (C) 1991-2016 Altera Corporation. All rights reserved.
-- Your use of Altera Corporation's design tools, logic functions
-- and other software and tools, and its AMPP partner logic
-- functions, and any output files from any of the foregoing
-- (including device programming or simulation files), and any
-- associated documentation or information are expressly subject
-- to the terms and conditions of the Altera Program License
-- Subscription Agreement, the Altera Quartus Prime License Agreement,
-- the Altera MegaCore Function License Agreement, or other
-- applicable license agreement, including, without limitation,
-- that your use is for the sole purpose of programming logic
-- devices manufactured by Altera and sold by Altera or its
-- authorized distributors.  Please refer to the applicable
-- agreement for further details.

-- ***************************************************************************
-- This file contains a Vhdl test bench template that is freely editable to
-- suit user's needs .Comments are provided in each section to help the user
-- fill out necessary details.
-- ***************************************************************************
-- Generated on "04/06/2018 10:20:25"

-- Vhdl Test Bench template for design  :  raw2rgb
--
-- Simulation tool : ModelSim-Altera (VHDL)
--


--**WARNING! Edit the explanation of the test, including the new 2 pixels added in each row

LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY raw2rgb_vhd_tst IS
END raw2rgb_vhd_tst;
ARCHITECTURE raw2rgb_arch OF raw2rgb_vhd_tst IS
-- signals
SIGNAL clk        : STD_LOGIC;
SIGNAL data_valid : STD_LOGIC;
SIGNAL img_height : STD_LOGIC_VECTOR(15 DOWNTO 0);
SIGNAL img_width  : STD_LOGIC_VECTOR(15 DOWNTO 0);
SIGNAL oBlue      : STD_LOGIC_VECTOR(11 DOWNTO 0);
SIGNAL oDVAL      : STD_LOGIC;
SIGNAL oGreen     : STD_LOGIC_VECTOR(11 DOWNTO 0);
SIGNAL oRed       : STD_LOGIC_VECTOR(11 DOWNTO 0);
SIGNAL pix        : STD_LOGIC_VECTOR(11 DOWNTO 0);
SIGNAL reset_n    : STD_LOGIC;
COMPONENT raw2rgb
	PORT (
	clk        : IN STD_LOGIC;
	data_valid : IN STD_LOGIC;
	img_height : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
	img_width  : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
	oBlue      : OUT STD_LOGIC_VECTOR(11 DOWNTO 0);
	oDVAL      : OUT STD_LOGIC;
	oGreen     : OUT STD_LOGIC_VECTOR(11 DOWNTO 0);
	oRed       : OUT STD_LOGIC_VECTOR(11 DOWNTO 0);
	pix        : IN STD_LOGIC_VECTOR(11 DOWNTO 0);
	reset_n    : IN STD_LOGIC
	);
END COMPONENT;

-------------------------------------------------------------
----------------    SIMULATION SIGNALS & VARIABLES    -------

	signal sim_clk             : STD_LOGIC 	:= '0';
	signal sim_reset           : STD_LOGIC 	:= '0';
	signal sim_trig            : STD_LOGIC 	:= '0';
	shared variable edge_rise  : integer    	:= -1;
	shared variable edge_fall  : integer    	:= -1;

BEGIN
	i1 : raw2rgb
	PORT MAP (
-- list connections between master ports and signals
	clk => clk,
	data_valid => data_valid,
	img_height => img_height,
	img_width => img_width,
	oBlue => oBlue,
	oDVAL => oDVAL,
	oGreen => oGreen,
	oRed => oRed,
	pix => pix,
	reset_n => reset_n
	);

-------------------------------------------------------------
----------------    CLOCK & RESET SIGNALS    ----------------
	clk 	  <= sim_clk;
	reset_n <= sim_reset;
-------------------------------------------------------------
----------------    CLOCK PROCESS    ------------------------
	simulation_clock : process
		-- repeat the counters edge_rise & edge_fall
		constant max_cycles    	: integer   := 140;
	begin
		-- set sim_clk signal
		sim_clk <= not(sim_clk);
		-- adjust
		if (sim_clk = '0') then
			edge_rise := edge_rise + 1;
		else
			edge_fall := edge_fall + 1;
		end if;
		if( edge_fall = max_cycles ) then
			edge_rise := 0;
			edge_fall := 0;
		end if;
		-- trigger the stimuli process
		wait for 0.05 ns;
		sim_trig <= not(sim_trig);
		-- wait until end of 1/2 period
		wait for 0.45 ns;
	end process simulation_clock;


-------------------------------------------------------------
----------------    STIMULI PROCESS    ----------------------
	stimuli : process (sim_trig)
		variable  sample_count : integer := 0;
	begin
		--Initialization
		if ( edge_rise = 0 ) then
			sim_reset 	<= '0';	-- reset
			data_valid 	<= '0';
			img_height <= X"0004";
			img_width <= X"000A";
			pix <= B"000000000000";
		end if;
		if ( edge_rise = 1 ) then
			sim_reset 	<= '1';	-- stop reset
		end if;

		--Now put the following image in the imput and see the output:
		--------------------------------------------------------------------------
	  -- |B-3900|G- 800|B-4000|G- 700|B-3200|G- 900|B-3900|G- 800|B-4000|G- 700|
		--------------------------------------------------------------------------
		-- |G- 300|R-2000|G- 600|R-1500|G- 100|R-1800|G- 300|R-2000|G- 600|R-1500|
		--------------------------------------------------------------------------
		-- |B-3700|G- 600|B-3500|G- 500|B-2900|G- 200|B-3700|G- 600|B-3500|G- 500|
		--------------------------------------------------------------------------
		--  G- 400|R-2100|G- 500|R-2300|G- 300|R-2500|G- 400|R-2100|G- 500|R-2300|
		--------------------------------------------------------------------------

		--The output RGB image should be (R-G-B):




		--------------------------------------------------------------------------
	  -- |R-2000|R-2000|R-1750|R-1500|R-1650|R-1800|R-1900|R-2000|R-1750|R-1500|
		-- |G-550 |G-450 |G-750 |G-350 |G-800 |G-200 |G-850 |G-450 |G-750 |G-650 |
		-- |B-3900|B-3950|B-4000|B-4000|B-3200|B-3550|B-3900|B-3950|B-4000|B-4000|
		--------------------------------------------------------------------------
		-- |R-2000|R-2000|R-1750|R-1500|R-1650|R-1800|R-1900|R-2000|R-1750|R-1500|
		-- |G-700 |G-575 |G-650 |G-475 |G-575 |G-375 |G-625 |G-575 |G-650 |G-600 |
		-- |B-3800|B-3775|B-3750|B-3400|B-3050|B-3425|B-3800|B-3775|B-3750|B-3750|
		--------------------------------------------------------------------------
		-- |R-2050|R-1750|R-1975|R-1900|R-2025|R-2150|R-2100|R-2050|R-1975|R-1900|
		-- |G-350 |G-450 |G-550 |G-375 |G-275 |G-275 |G-375 |G-450 |G-550 |G-550 |
		-- |B-3700|B-3600|B-3500|B-3200|B-2900|B-3300|B-3700|B-3600|B-3500|B-3500|
		------------------------------------------------------------------------
		-- |R-2100|R-2100|R-2200|R-2300|R-2400|R-2500|R-2300|R-2100|R-2200|R-2300|
		-- |G-500 |G-450 |G-550 |G-400 |G-350 |G-350 |G-400 |G-450 |G-550 |G-500 |
		-- |B-3700|B-3600|B-3500|B-3200|B-2900|B-3300|B-3700|B-3600|B-3500|B-3500|
		--------------------------------------------------------------------------

		-------------Line 1
		--1
		if ( edge_rise = 10 ) then
			data_valid 	<= '1';
			pix <= B"111100111100";--3900
		end if;
		if ( edge_rise = 11 ) then
			data_valid 	<= '0';
		end if;
		--2
 		if ( edge_rise = 12 ) then
			data_valid 	<= '1';
			pix <= B"001100100000";--800
		end if;
		if ( edge_rise = 13 ) then
			data_valid 	<= '0';
		end if;
		--3
 		if ( edge_rise = 14 ) then
			data_valid 	<= '1';
			pix <= B"111110100000";--4000
		end if;
		if ( edge_rise = 15 ) then
			data_valid 	<= '0';
		end if;
		--4
		if ( edge_rise = 16 ) then
			data_valid 	<= '1';
			pix <= B"001010111100";--700
		end if;
		if ( edge_rise = 17 ) then
			data_valid 	<= '0';
		end if;
		--5
		if ( edge_rise = 18 ) then
			data_valid 	<= '1';
			pix <= B"110010000000";--3200
		end if;
		if ( edge_rise = 19 ) then
			data_valid 	<= '0';
		end if;
		--6
		if ( edge_rise = 20 ) then
			data_valid 	<= '1';
			pix <= B"001110000100";--900
		end if;
		if ( edge_rise = 21 ) then
			data_valid 	<= '0';
		end if;
		--7
		if ( edge_rise = 22 ) then
			data_valid 	<= '1';
			pix <= B"111100111100";--3900
		end if;
		if ( edge_rise = 23 ) then
			data_valid 	<= '0';
		end if;
		--8
 		if ( edge_rise = 24 ) then
			data_valid 	<= '1';
			pix <= B"001100100000";--800
		end if;
		if ( edge_rise = 25 ) then
			data_valid 	<= '0';
		end if;
		--9
 		if ( edge_rise = 26 ) then
			data_valid 	<= '1';
			pix <= B"111110100000";--4000
		end if;
		if ( edge_rise = 27 ) then
			data_valid 	<= '0';
		end if;
		--10
		if ( edge_rise = 28 ) then
			data_valid 	<= '1';
			pix <= B"001010111100";--700
		end if;
		if ( edge_rise = 29 ) then
			data_valid 	<= '0';
		end if;
		--Line 2
    --1
 		if ( edge_rise = 30 ) then
			data_valid 	<= '1';
			pix <= B"000100101100";--300
		end if;
		if ( edge_rise = 31 ) then
			data_valid 	<= '0';
		end if;
		--2
 		if ( edge_rise = 32 ) then
			data_valid 	<= '1';
			pix <= B"011111010000";--2000
		end if;
		if ( edge_rise = 33 ) then
			data_valid 	<= '0';
		end if;
    --3
		if ( edge_rise = 34 ) then
			data_valid 	<= '1';
			pix <= B"001001011000";--600
		end if;
		if ( edge_rise = 35 ) then
			data_valid 	<= '0';
		end if;
		--4
 		if ( edge_rise = 36 ) then
			data_valid 	<= '1';
			pix <= B"010111011100";--1500
		end if;
		if ( edge_rise = 37 ) then
			data_valid 	<= '0';
		end if;
		--5
 		if ( edge_rise = 38 ) then
			data_valid 	<= '1';
			pix <= B"000001100100";--100
		end if;
		if ( edge_rise = 39 ) then
			data_valid 	<= '0';
		end if;
		--6
 		if ( edge_rise = 40 ) then
			data_valid 	<= '1';
			pix <= B"011100001000";--1800
		end if;
		if ( edge_rise = 41 ) then
			data_valid 	<= '0';
		end if;
		--7
 		if ( edge_rise = 42 ) then
			data_valid 	<= '1';
			pix <= B"000100101100";--300
		end if;
		if ( edge_rise = 43 ) then
			data_valid 	<= '0';
		end if;
		--8
 		if ( edge_rise = 44 ) then
			data_valid 	<= '1';
			pix <= B"011111010000";--2000
		end if;
		if ( edge_rise = 45 ) then
			data_valid 	<= '0';
		end if;
    --9
		if ( edge_rise = 46 ) then
			data_valid 	<= '1';
			pix <= B"001001011000";--600
		end if;
		if ( edge_rise = 47 ) then
			data_valid 	<= '0';
		end if;
		--10
 		if ( edge_rise = 48 ) then
			data_valid 	<= '1';
			pix <= B"010111011100";--1500
		end if;
		if ( edge_rise = 49 ) then
			data_valid 	<= '0';
		end if;
		--Line 3:
    --1
 		if ( edge_rise = 50 ) then
			data_valid 	<= '1';
			pix <= B"111001110100";--3700
		end if;
		if ( edge_rise = 51 ) then
			data_valid 	<= '0';
		end if;
		--2
		if ( edge_rise = 52 ) then
			data_valid 	<= '1';
			pix <= B"001001011000";--600
		end if;
		if ( edge_rise = 53 ) then
			data_valid 	<= '0';
		end if;
		--3
 		if ( edge_rise = 54 ) then
			data_valid 	<= '1';
			pix <= B"110110101100";--3500
		end if;
		if ( edge_rise = 55 ) then
			data_valid 	<= '0';
		end if;
		--4
 		if ( edge_rise = 56 ) then
			data_valid 	<= '1';
			pix <= B"000111110100";--500
		end if;
		if ( edge_rise = 57 ) then
			data_valid 	<= '0';
		end if;
		--5
		if ( edge_rise = 58 ) then
			data_valid 	<= '1';
			pix <= B"101101010100";--2900
		end if;
		if ( edge_rise = 59 ) then
			data_valid 	<= '0';
		end if;
		--6
		if ( edge_rise = 60 ) then
			data_valid 	<= '1';
			pix <= B"000011001000";--200
		end if;
		if ( edge_rise = 61 ) then
			data_valid 	<= '0';
		end if;
		--7
 		if ( edge_rise = 62 ) then
			data_valid 	<= '1';
			pix <= B"111001110100";--3700
		end if;
		if ( edge_rise = 63 ) then
			data_valid 	<= '0';
		end if;
		--8
		if ( edge_rise = 64 ) then
			data_valid 	<= '1';
			pix <= B"001001011000";--600
		end if;
		if ( edge_rise = 65 ) then
			data_valid 	<= '0';
		end if;
		--9
 		if ( edge_rise = 66 ) then
			data_valid 	<= '1';
			pix <= B"110110101100";--3500
		end if;
		if ( edge_rise = 67 ) then
			data_valid 	<= '0';
		end if;
		--10
 		if ( edge_rise = 68 ) then
			data_valid 	<= '1';
			pix <= B"000111110100";--500
		end if;
		if ( edge_rise = 69 ) then
			data_valid 	<= '0';
		end if;
		-------------Line 4
		--1
		if ( edge_rise = 70 ) then
			data_valid 	<= '1';
			pix <= B"000110010000";--400
		end if;
		if ( edge_rise = 71 ) then
			data_valid 	<= '0';
		end if;
		--2
 		if ( edge_rise = 72 ) then
			data_valid 	<= '1';
			pix <= B"100000110100";--2100
		end if;
		if ( edge_rise = 73 ) then
			data_valid 	<= '0';
		end if;
		--3
 		if ( edge_rise = 74 ) then
			data_valid 	<= '1';
			pix <= B"000111110100";--500
		end if;
		if ( edge_rise = 75 ) then
			data_valid 	<= '0';
		end if;
		--4
		if ( edge_rise = 76 ) then
			data_valid 	<= '1';
			pix <= B"100011111100";--2300
		end if;
		if ( edge_rise = 77 ) then
			data_valid 	<= '0';
		end if;
		--5
		if ( edge_rise = 78 ) then
			data_valid 	<= '1';
			pix <= B"000100101100";--300
		end if;
		if ( edge_rise = 79 ) then
			data_valid 	<= '0';
		end if;
		--6
		if ( edge_rise = 80 ) then
			data_valid 	<= '1';
			pix <= B"100111000100";--2500
		end if;
		if ( edge_rise = 81 ) then
			data_valid 	<= '0';
		end if;
		--7
		if ( edge_rise = 82 ) then
			data_valid 	<= '1';
			pix <= B"000110010000";--400
		end if;
		if ( edge_rise = 83 ) then
			data_valid 	<= '0';
		end if;
		--8
 		if ( edge_rise = 84 ) then
			data_valid 	<= '1';
			pix <= B"100000110100";--2100
		end if;
		if ( edge_rise = 85 ) then
			data_valid 	<= '0';
		end if;
		--9
 		if ( edge_rise = 86 ) then
			data_valid 	<= '1';
			pix <= B"000111110100";--500
		end if;
		if ( edge_rise = 87 ) then
			data_valid 	<= '0';
		end if;
		--10
		if ( edge_rise = 88 ) then
			data_valid 	<= '1';
			pix <= B"100011111100";--2300
		end if;
		if ( edge_rise = 89 ) then
			data_valid 	<= '0';
		end if;
    --fin
    if ( edge_rise = 90 ) then
      data_valid 	<= '1';
      pix <= B"100011111100";--2300
    end if;
    if ( edge_rise = 91 ) then
      data_valid 	<= '0';
    end if;
    if ( edge_rise = 92 ) then
      data_valid 	<= '1';
      pix <= B"100011111100";--2300
    end if;
    if ( edge_rise = 93 ) then
      data_valid 	<= '0';
    end if;
    if ( edge_rise = 94 ) then
      data_valid 	<= '1';
      pix <= B"100011111100";--2300
    end if;
    if ( edge_rise = 95 ) then
      data_valid 	<= '0';
    end if;
    if ( edge_rise = 96 ) then
      data_valid 	<= '1';
      pix <= B"100011111100";--2300
    end if;
    if ( edge_rise = 97 ) then
      data_valid 	<= '0';
    end if;
    if ( edge_rise = 98 ) then
      data_valid 	<= '1';
      pix <= B"100011111100";--2300
    end if;
    if ( edge_rise = 99 ) then
      data_valid 	<= '0';
    end if;
    if ( edge_rise = 100 ) then
      data_valid 	<= '1';
      pix <= B"100011111100";--2300
    end if;
    if ( edge_rise = 101 ) then
      data_valid 	<= '0';
    end if;
    if ( edge_rise = 102 ) then
      data_valid 	<= '1';
      pix <= B"100011111100";--2300
    end if;
    if ( edge_rise = 103 ) then
      data_valid 	<= '0';
    end if;
    if ( edge_rise = 104 ) then
      data_valid 	<= '1';
      pix <= B"100011111100";--2300
    end if;
    if ( edge_rise = 105 ) then
      data_valid 	<= '0';
    end if;
    if ( edge_rise = 106 ) then
      data_valid 	<= '1';
      pix <= B"100011111100";--2300
    end if;
    if ( edge_rise = 107 ) then
      data_valid 	<= '0';
    end if;
    if ( edge_rise = 108 ) then
      data_valid 	<= '1';
      pix <= B"100011111100";--2300
    end if;
    if ( edge_rise = 109 ) then
      data_valid 	<= '0';
    end if;
    if ( edge_rise = 110 ) then
      data_valid 	<= '1';
      pix <= B"100011111100";--2300
    end if;
    if ( edge_rise = 111 ) then
      data_valid 	<= '0';
    end if;

	end process stimuli;
END raw2rgb_arch;
