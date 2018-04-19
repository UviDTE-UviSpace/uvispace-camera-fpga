-- Copyright (C) 1991-2014 Altera Corporation. All rights reserved.
-- Your use of Altera Corporation's design tools, logic functions
-- and other software and tools, and its AMPP partner logic
-- functions, and any output files from any of the foregoing
-- (including device programming or simulation files), and any
-- associated documentation or information are expressly subject
-- to the terms and conditions of the Altera Program License
-- Subscription Agreement, the Altera Quartus II License Agreement,
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
-- Generated on "12/09/2017 16:38:11"

-- Vhdl Test Bench template for design  :  morphological_fifo
--
-- Simulation tool : ModelSim-Altera (VHDL)
--

LIBRARY ieee;
USE ieee.std_logic_1164.all;

LIBRARY work;
	use work.array_package.all;

--PACKAGE morphological_fifo_data_type IS
--TYPE window_valid_2_0_type IS ARRAY (2 DOWNTO 0) OF STD_LOGIC;
--TYPE window_valid_2_0_2_0_type IS ARRAY (2 DOWNTO 0) OF window_valid_2_0_type;
--SUBTYPE window_valid_type IS window_valid_2_0_2_0_type;
--END morphological_fifo_data_type;

LIBRARY ieee;
USE ieee.std_logic_1164.all;

--library work;
--use work.morphological_fifo_data_type.all;

ENTITY morphological_fifo_vhd_tst IS
END morphological_fifo_vhd_tst;
ARCHITECTURE morphological_fifo_arch OF morphological_fifo_vhd_tst IS
-- constants
-- signals
SIGNAL clk : STD_LOGIC;
SIGNAL data_valid : STD_LOGIC;
SIGNAL data_valid_out : STD_LOGIC;
SIGNAL img_height : STD_LOGIC_VECTOR(15 DOWNTO 0);
SIGNAL img_width : STD_LOGIC_VECTOR(15 DOWNTO 0);
SIGNAL moving_window : array2D_of_std_logic_vector(2 downto 0)(2 downto 0)(7 downto 0);
SIGNAL pix : STD_LOGIC_VECTOR(7 DOWNTO 0);
SIGNAL reset_n : STD_LOGIC;
SIGNAL window_valid : array2D_of_std_logic(2 downto 0)(2  downto 0);
COMPONENT morphological_fifo
	PORT (
	clk : IN STD_LOGIC;
	data_valid : IN STD_LOGIC;
	data_valid_out : OUT STD_LOGIC;
	img_height : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
	img_width : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
	moving_window : OUT array2D_of_std_logic_vector(2 downto 0)(2 downto 0)(7 downto 0);
	pix : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
	reset_n : IN STD_LOGIC;
	window_valid : OUT array2D_of_std_logic(2 downto 0)(2  downto 0)
	);
END COMPONENT;
-------------------------------------------------------------
----------------    SIMULATION SIGNALS & VARIABLES    -------

	signal sim_clk   				: STD_LOGIC 	:= '0';
	signal sim_reset 				: STD_LOGIC 	:= '0';
	signal sim_trig  				: STD_LOGIC 	:= '0';
	shared variable edge_rise  : integer    	:= -1;
	shared variable edge_fall 	: integer    	:= -1;
BEGIN
	i1 : morphological_fifo
	PORT MAP (
-- list connections between master ports and signals
	clk => clk,
	data_valid => data_valid,
	data_valid_out => data_valid_out,
	img_height => img_height,
	img_width => img_width,
	moving_window=> moving_window,
	pix => pix,
	reset_n => reset_n,
	window_valid => window_valid
	);

	-------------------------------------------------------------
----------------    CLOCK & RESET SIGNALS    ----------------
	clk 	<= sim_clk;
	reset_n <= sim_reset;
-------------------------------------------------------------
----------------    CLOCK PROCESS    ------------------------
	simulation_clock : process
		-- repeat the counters edge_rise & edge_fall
		constant max_cycles    	: integer   := 130;
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
			pix <= X"00";
		end if;
		if ( edge_rise = 1 ) then
			sim_reset 	<= '1';	-- stop reset
		end if;

		--Now put the following image in the imput and see the output
	  --   1   2   3   4   5   6   7   8   9  10
    --  11  12  13  14  15  16  17  18  19  20
    --  21  22  23  24  25  26  27  28  29  30
    --  31  32  33  34  35  36  37  38  39  40

		-------------Line 1
		--1
		if ( edge_rise = 6 ) then
			data_valid 	<= '1';
			pix <= X"01";
		end if;
		if ( edge_rise = 7 ) then
			data_valid 	<= '0';
		end if;
		--2
		if ( edge_rise = 8 ) then
			data_valid 	<= '1';
			pix <= X"02";
		end if;
		if ( edge_rise = 9 ) then
			data_valid 	<= '0';
		end if;
		--3
		if ( edge_rise = 10 ) then
			data_valid 	<= '1';
			pix <= X"03";
		end if;
		if ( edge_rise = 11 ) then
			data_valid 	<= '0';
		end if;
		--4
		if ( edge_rise = 12 ) then
			data_valid 	<= '1';
			pix <= X"04";
		end if;
		if ( edge_rise = 13 ) then
			data_valid 	<= '0';
		end if;
		--5
		if ( edge_rise = 14 ) then
			data_valid 	<= '1';
			pix <= X"05";
		end if;
		if ( edge_rise = 15 ) then
			data_valid 	<= '0';
		end if;
		--6
		if ( edge_rise = 16 ) then
			data_valid 	<= '1';
			pix <= X"06";
		end if;
		if ( edge_rise = 17 ) then
			data_valid 	<= '0';
		end if;
		--7
		if ( edge_rise = 26 ) then
			data_valid 	<= '1';
			pix <= X"07";
		end if;
		if ( edge_rise = 27 ) then
			data_valid 	<= '0';
		end if;
		--8
		if ( edge_rise = 28 ) then
			data_valid 	<= '1';
			pix <= X"08";
		end if;
		if ( edge_rise = 29 ) then
			data_valid 	<= '0';
		end if;
		--9
		if ( edge_rise = 30 ) then
			data_valid 	<= '1';
			pix <= X"09";
		end if;
		if ( edge_rise = 31 ) then
			data_valid 	<= '0';
		end if;
		--10
		if ( edge_rise = 32 ) then
			data_valid 	<= '1';
			pix <= X"0A";
		end if;
		if ( edge_rise = 32 ) then
			data_valid 	<= '0';
		end if;

    ----------Line 2
		--11
		if ( edge_rise = 34 ) then
			data_valid 	<= '1';
			pix <= X"0B";
		end if;
		if ( edge_rise = 35 ) then
			data_valid 	<= '0';
		end if;
		--12
		if ( edge_rise = 36 ) then
			data_valid 	<= '1';
			pix <= X"0C";
		end if;
		if ( edge_rise = 37 ) then
			data_valid 	<= '0';
		end if;
		--13
		if ( edge_rise = 46 ) then
			data_valid 	<= '1';
			pix <= X"0D";
		end if;
		if ( edge_rise = 47 ) then
			data_valid 	<= '0';
		end if;
		--14
		if ( edge_rise = 48 ) then
			data_valid 	<= '1';
			pix <= X"0E";
		end if;
		if ( edge_rise = 49 ) then
			data_valid 	<= '0';
		end if;
		--15
		if ( edge_rise = 50 ) then
			data_valid 	<= '1';
			pix <= X"0F";
		end if;
		if ( edge_rise = 51 ) then
			data_valid 	<= '0';
		end if;
		--16
		if ( edge_rise = 52 ) then
			data_valid 	<= '1';
			pix <= X"10";
		end if;
		if ( edge_rise = 53 ) then
			data_valid 	<= '0';
		end if;
		--17
		if ( edge_rise = 54 ) then
			data_valid 	<= '1';
			pix <= X"11";
		end if;
		if ( edge_rise = 55 ) then
			data_valid 	<= '0';
		end if;
		--18
		if ( edge_rise = 56 ) then
			data_valid 	<= '1';
			pix <= X"12";
		end if;
		if ( edge_rise = 57 ) then
			data_valid 	<= '0';
		end if;
		--19
		if ( edge_rise = 66 ) then
			data_valid 	<= '1';
			pix <= X"13";
		end if;
		if ( edge_rise = 67 ) then
			data_valid 	<= '0';
		end if;
		--20
		if ( edge_rise = 68 ) then
			data_valid 	<= '1';
			pix <= X"14";
		end if;
		if ( edge_rise = 69 ) then
			data_valid 	<= '0';
		end if;
    -------------Line 3
		--21
		if ( edge_rise = 70 ) then
			data_valid 	<= '1';
			pix <= X"15";
		end if;
		if ( edge_rise = 71 ) then
			data_valid 	<= '0';
		end if;
		--22
		if ( edge_rise = 72 ) then
			data_valid 	<= '1';
			pix <= X"16";
		end if;
		if ( edge_rise = 73 ) then
			data_valid 	<= '0';
		end if;
		--23
		if ( edge_rise = 74 ) then
			data_valid 	<= '1';
			pix <= X"17";
		end if;
		if ( edge_rise = 75 ) then
			data_valid 	<= '0';
		end if;
		--24
		if ( edge_rise = 76 ) then
			data_valid 	<= '1';
			pix <= X"18";
		end if;
		if ( edge_rise = 77 ) then
			data_valid 	<= '0';
		end if;
		--25
		if ( edge_rise = 86 ) then
			data_valid 	<= '1';
			pix <= X"19";
		end if;
		if ( edge_rise = 87 ) then
			data_valid 	<= '0';
		end if;
		--26
		if ( edge_rise = 88 ) then
			data_valid 	<= '1';
			pix <= X"1A";
		end if;
		if ( edge_rise = 89 ) then
			data_valid 	<= '0';
		end if;
		--27
		if ( edge_rise = 90 ) then
			data_valid 	<= '1';
			pix <= X"1B";
		end if;
		if ( edge_rise = 91 ) then
			data_valid 	<= '0';
		end if;
		--28
		if ( edge_rise = 92 ) then
			data_valid 	<= '1';
			pix <= X"1C";
		end if;
		if ( edge_rise = 93 ) then
			data_valid 	<= '0';
		end if;
		--29
		if ( edge_rise = 94 ) then
			data_valid 	<= '1';
			pix <= X"1D";
		end if;
		if ( edge_rise = 95 ) then
			data_valid 	<= '0';
		end if;
		--30
		if ( edge_rise = 96 ) then
			data_valid 	<= '1';
			pix <= X"1E";
		end if;
		if ( edge_rise = 97 ) then
			data_valid 	<= '0';
		end if;
		----------Line 4
		--31
		if ( edge_rise = 106 ) then
			data_valid 	<= '1';
			pix <= X"1F";
		end if;
		if ( edge_rise = 107 ) then
			data_valid 	<= '0';
		end if;
		--32
		if ( edge_rise = 108 ) then
			data_valid 	<= '1';
			pix <= X"20";
		end if;
		if ( edge_rise = 109 ) then
			data_valid 	<= '0';
		end if;
		--33
		if ( edge_rise = 110 ) then
			data_valid 	<= '1';
			pix <= X"21";
		end if;
		if ( edge_rise = 111 ) then
			data_valid 	<= '0';
		end if;
		--34
		if ( edge_rise = 112 ) then
			data_valid 	<= '1';
			pix <= X"22";
		end if;
		if ( edge_rise = 113 ) then
			data_valid 	<= '0';
		end if;
		--35
		if ( edge_rise = 114 ) then
			data_valid 	<= '1';
			pix <= X"23";
		end if;
		if ( edge_rise = 115 ) then
			data_valid 	<= '0';
		end if;
		--36
		if ( edge_rise = 116 ) then
			data_valid 	<= '1';
			pix <= X"24";
		end if;
		if ( edge_rise = 117 ) then
			data_valid 	<= '0';
		end if;
    --37
		if ( edge_rise = 116 ) then
			data_valid 	<= '1';
			pix <= X"25";
		end if;
		if ( edge_rise = 117 ) then
			data_valid 	<= '0';
		end if;
    --38
		if ( edge_rise = 116 ) then
			data_valid 	<= '1';
			pix <= X"26";
		end if;
		if ( edge_rise = 117 ) then
			data_valid 	<= '0';
		end if;
    --39
		if ( edge_rise = 116 ) then
			data_valid 	<= '1';
			pix <= X"27";
		end if;
		if ( edge_rise = 117 ) then
			data_valid 	<= '0';
		end if;
    --40
		if ( edge_rise = 116 ) then
			data_valid 	<= '1';
			pix <= X"28";
		end if;
		if ( edge_rise = 117 ) then
			data_valid 	<= '0';
		end if;

    -- End of the pixels of image 1

		--Now put some pixels more to see the behaviour with second image
		if ( edge_rise = 124 ) then
			data_valid 	<= '1';
			pix <= X"25";
		end if;
		if ( edge_rise = 125 ) then
			data_valid 	<= '1';
			pix <= X"26";
		end if;
		if ( edge_rise = 126 ) then
			data_valid 	<= '1';
			pix <= X"27";
		end if;
		if ( edge_rise = 127 ) then
			data_valid 	<= '1';
			pix <= X"28";
		end if;
		if ( edge_rise = 128 ) then
			data_valid 	<= '0';
		end if;

	end process stimuli;
END morphological_fifo_arch;
