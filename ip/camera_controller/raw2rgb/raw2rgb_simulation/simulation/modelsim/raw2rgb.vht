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
-- constants
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
			pix <= B"000000000100";
		end if;
		if ( edge_rise = 1 ) then
			sim_reset 	<= '1';	-- stop reset
		end if;

		--Now put the following image in the imput and see the output
	  --  R-3900   G- 800   R-4000   G- 700
		--  G- 300   B-2000   G- 600   B-1500
		--  R-3700   G- 600   R-3500   G- 500
		--  G- 400   B-2100   G- 500   B-2300

		--The output eroded image should be (R-G-B):
		--  3900- 550-2000    3950- 450-2000    4000- 750-1750    4000- 650-1500
    --  3800- 700-2000    3775- 575-1750    3750- 650-1750    3750- 600-1500
    --  3700- 350-2050    3600- 450-2050    3500- 550-1975    3500- 550-1900
    --  3700- 500-2100    3600- 450-2100    3500- 550-2200    3500- 500-2300

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

		---------------------------START IMAGE 2 SO IMAGE 1 IS FULLY PUSHED OUT
		-------------Line 1
		--1
		if ( edge_rise = 110 ) then
			data_valid 	<= '1';
			pix <= B"111100111100";--3900
		end if;
		if ( edge_rise = 111 ) then
			data_valid 	<= '0';
		end if;
		--2
 		if ( edge_rise = 112 ) then
			data_valid 	<= '1';
			pix <= B"001100100000";--800
		end if;
		if ( edge_rise = 113 ) then
			data_valid 	<= '0';
		end if;
		--3
 		if ( edge_rise = 114 ) then
			data_valid 	<= '1';
			pix <= B"111110100000";--4000
		end if;
		if ( edge_rise = 115 ) then
			data_valid 	<= '0';
		end if;
		--4
		if ( edge_rise = 116 ) then
			data_valid 	<= '1';
			pix <= B"001010111100";--700
		end if;
		if ( edge_rise = 117 ) then
			data_valid 	<= '0';
		end if;
		--5
		if ( edge_rise = 118 ) then
			data_valid 	<= '1';
			pix <= B"110010000000";--3200
		end if;
		if ( edge_rise = 119 ) then
			data_valid 	<= '0';
		end if;
		--6
		if ( edge_rise = 120 ) then
			data_valid 	<= '1';
			pix <= B"001110000100";--900
		end if;
		if ( edge_rise = 121 ) then
			data_valid 	<= '0';
		end if;
		--7
		if ( edge_rise = 122 ) then
			data_valid 	<= '1';
			pix <= B"111100111100";--3900
		end if;
		if ( edge_rise = 123 ) then
			data_valid 	<= '0';
		end if;
		--8
 		if ( edge_rise = 124 ) then
			data_valid 	<= '1';
			pix <= B"001100100000";--800
		end if;
		if ( edge_rise = 125 ) then
			data_valid 	<= '0';
		end if;
		--9
 		if ( edge_rise = 126 ) then
			data_valid 	<= '1';
			pix <= B"111110100000";--4000
		end if;
		if ( edge_rise = 127 ) then
			data_valid 	<= '0';
		end if;
		--10
		if ( edge_rise = 128 ) then
			data_valid 	<= '1';
			pix <= B"001010111100";--700
		end if;
		if ( edge_rise = 129 ) then
			data_valid 	<= '0';
		end if;
		--Line 2
    --1
 		if ( edge_rise = 130 ) then
			data_valid 	<= '1';
			pix <= B"000100101100";--300
		end if;
		if ( edge_rise = 131 ) then
			data_valid 	<= '0';
		end if;
		--2
 		if ( edge_rise = 132 ) then
			data_valid 	<= '1';
			pix <= B"011111010000";--2000
		end if;
		if ( edge_rise = 133 ) then
			data_valid 	<= '0';
		end if;
    --3
		if ( edge_rise = 134 ) then
			data_valid 	<= '1';
			pix <= B"001001011000";--600
		end if;
		if ( edge_rise = 135 ) then
			data_valid 	<= '0';
		end if;
		--4
 		if ( edge_rise = 136 ) then
			data_valid 	<= '1';
			pix <= B"010111011100";--1500
		end if;
		if ( edge_rise = 137 ) then
			data_valid 	<= '0';
		end if;
		--5
 		if ( edge_rise = 138 ) then
			data_valid 	<= '1';
			pix <= B"000001100100";--100
		end if;
		if ( edge_rise = 139 ) then
			data_valid 	<= '0';
		end if;
		--6
 		if ( edge_rise = 140 ) then
			data_valid 	<= '1';
			pix <= B"011100001000";--1800
		end if;
		if ( edge_rise = 141 ) then
			data_valid 	<= '0';
		end if;
		--7
 		if ( edge_rise = 142 ) then
			data_valid 	<= '1';
			pix <= B"000100101100";--300
		end if;
		if ( edge_rise = 143 ) then
			data_valid 	<= '0';
		end if;
		--8
 		if ( edge_rise = 144 ) then
			data_valid 	<= '1';
			pix <= B"011111010000";--2000
		end if;
		if ( edge_rise = 145 ) then
			data_valid 	<= '0';
		end if;
    --9
		if ( edge_rise = 146 ) then
			data_valid 	<= '1';
			pix <= B"001001011000";--600
		end if;
		if ( edge_rise = 147 ) then
			data_valid 	<= '0';
		end if;
		--10
 		if ( edge_rise = 148 ) then
			data_valid 	<= '1';
			pix <= B"010111011100";--1500
		end if;
		if ( edge_rise = 149 ) then
			data_valid 	<= '0';
		end if;
		--Line 3:
    --1
 		if ( edge_rise = 150 ) then
			data_valid 	<= '1';
			pix <= B"111001110100";--3700
		end if;
		if ( edge_rise = 151 ) then
			data_valid 	<= '0';
		end if;
		--2
		if ( edge_rise = 152 ) then
			data_valid 	<= '1';
			pix <= B"001001011000";--600
		end if;
		if ( edge_rise = 153 ) then
			data_valid 	<= '0';
		end if;
		--3
 		if ( edge_rise = 154 ) then
			data_valid 	<= '1';
			pix <= B"110110101100";--3500
		end if;
		if ( edge_rise = 155 ) then
			data_valid 	<= '0';
		end if;
		--4
 		if ( edge_rise = 156 ) then
			data_valid 	<= '1';
			pix <= B"000111110100";--500
		end if;
		if ( edge_rise = 157 ) then
			data_valid 	<= '0';
		end if;
		--5
		if ( edge_rise = 158 ) then
			data_valid 	<= '1';
			pix <= B"101101010100";--2900
		end if;
		if ( edge_rise = 159 ) then
			data_valid 	<= '0';
		end if;
		--6
		if ( edge_rise = 160 ) then
			data_valid 	<= '1';
			pix <= B"000011001000";--200
		end if;
		if ( edge_rise = 161 ) then
			data_valid 	<= '0';
		end if;
		--7
 		if ( edge_rise = 162 ) then
			data_valid 	<= '1';
			pix <= B"111001110100";--3700
		end if;
		if ( edge_rise = 163 ) then
			data_valid 	<= '0';
		end if;
		--8
		if ( edge_rise = 164 ) then
			data_valid 	<= '1';
			pix <= B"001001011000";--600
		end if;
		if ( edge_rise = 165 ) then
			data_valid 	<= '0';
		end if;
		--9
 		if ( edge_rise = 166 ) then
			data_valid 	<= '1';
			pix <= B"110110101100";--3500
		end if;
		if ( edge_rise = 167 ) then
			data_valid 	<= '0';
		end if;
		--10
 		if ( edge_rise = 168 ) then
			data_valid 	<= '1';
			pix <= B"000111110100";--500
		end if;
		if ( edge_rise = 169 ) then
			data_valid 	<= '0';
		end if;
		-------------Line 4
		--1
		if ( edge_rise = 170 ) then
			data_valid 	<= '1';
			pix <= B"000110010000";--400
		end if;
		if ( edge_rise = 171 ) then
			data_valid 	<= '0';
		end if;
		--2
 		if ( edge_rise = 172 ) then
			data_valid 	<= '1';
			pix <= B"100000110100";--2100
		end if;
		if ( edge_rise = 173 ) then
			data_valid 	<= '0';
		end if;
		--3
 		if ( edge_rise = 174 ) then
			data_valid 	<= '1';
			pix <= B"000111110100";--500
		end if;
		if ( edge_rise = 175 ) then
			data_valid 	<= '0';
		end if;
		--4
		if ( edge_rise = 176 ) then
			data_valid 	<= '1';
			pix <= B"100011111100";--2300
		end if;
		if ( edge_rise = 177 ) then
			data_valid 	<= '0';
		end if;
		--5
		if ( edge_rise = 178 ) then
			data_valid 	<= '1';
			pix <= B"000100101100";--300
		end if;
		if ( edge_rise = 179 ) then
			data_valid 	<= '0';
		end if;
		--6
		if ( edge_rise = 180 ) then
			data_valid 	<= '1';
			pix <= B"100111000100";--2500
		end if;
		if ( edge_rise = 181 ) then
			data_valid 	<= '0';
		end if;
		--7
		if ( edge_rise = 182 ) then
			data_valid 	<= '1';
			pix <= B"000110010000";--400
		end if;
		if ( edge_rise = 183 ) then
			data_valid 	<= '0';
		end if;
		--8
 		if ( edge_rise = 184 ) then
			data_valid 	<= '1';
			pix <= B"100000110100";--2100
		end if;
		if ( edge_rise = 185 ) then
			data_valid 	<= '0';
		end if;
		--9
 		if ( edge_rise = 186 ) then
			data_valid 	<= '1';
			pix <= B"000111110100";--500
		end if;
		if ( edge_rise = 187 ) then
			data_valid 	<= '0';
		end if;
		--10
		if ( edge_rise = 188 ) then
			data_valid 	<= '1';
			pix <= B"100011111100";--2300
		end if;
		if ( edge_rise = 189 ) then
			data_valid 	<= '0';
		end if;
	end process stimuli;
END raw2rgb_arch;
