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
-- Generated on "12/12/2017 15:13:56"
                                                            
-- Vhdl Test Bench template for design  :  erosion_bin
-- 
-- Simulation tool : ModelSim-Altera (VHDL)
-- 

LIBRARY ieee;                                               
USE ieee.std_logic_1164.all;                                

ENTITY erosion_bin_vhd_tst IS
END erosion_bin_vhd_tst;
ARCHITECTURE erosion_bin_arch OF erosion_bin_vhd_tst IS
-- constants                                                 
-- signals                                                   
SIGNAL clk : STD_LOGIC;
SIGNAL data_valid : STD_LOGIC;
SIGNAL data_valid_out : STD_LOGIC;
SIGNAL img_height : STD_LOGIC_VECTOR(15 DOWNTO 0);
SIGNAL img_width : STD_LOGIC_VECTOR(15 DOWNTO 0);
SIGNAL pix : STD_LOGIC;
SIGNAL pix_out : STD_LOGIC;
SIGNAL reset_n : STD_LOGIC;
COMPONENT erosion_bin
	PORT (
	clk : IN STD_LOGIC;
	data_valid : IN STD_LOGIC;
	data_valid_out : BUFFER STD_LOGIC;
	img_height : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
	img_width : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
	pix : IN STD_LOGIC;
	pix_out : BUFFER STD_LOGIC;
	reset_n : IN STD_LOGIC
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
	i1 : erosion_bin
	PORT MAP (
-- list connections between master ports and signals
	clk => clk,
	data_valid => data_valid,
	data_valid_out => data_valid_out,
	img_height => img_height,
	img_width => img_width,
	pix => pix,
	pix_out => pix_out,
	reset_n => reset_n
	);
	
-------------------------------------------------------------
----------------    CLOCK & RESET SIGNALS    ----------------  
	clk 	<= sim_clk;
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
			img_height <= X"0006";
			img_width <= X"0006";
			pix <= '0';
		end if;
		if ( edge_rise = 1 ) then
			sim_reset 	<= '1';	-- stop reset
		end if;
	
		--Now put the following image in the imput and see the output
	   --  1  1  1  1  0  0
		--  0  0  1  0  0  1
		--  0  0  0  0  1  1
		--  0  0  0  1  1  1
		--  0  0  0  1  1  1
		--  0  0  1  1  1  0
		
		--The output eroded image should be:
		--  0  0  1  0  0  0
		--  0  0  0  0  0  0
		--  0  0  0  0  0  1
		--  0  0  0  0  1  1
		--  0  0  0  0  1  0
		--  0  0  0  1  0  0
		
		-------------Line 1
		--1
		if ( edge_rise = 10 ) then
			data_valid 	<= '1';
			pix <= '1';
		end if;
		if ( edge_rise = 11 ) then
			data_valid 	<= '0';
		end if;
		--2
 		if ( edge_rise = 12 ) then
			data_valid 	<= '1';
			pix <= '1';
		end if;
		if ( edge_rise = 13 ) then
			data_valid 	<= '0';
		end if;
		--3
 		if ( edge_rise = 14 ) then
			data_valid 	<= '1';
			pix <= '1';
		end if;
		if ( edge_rise = 15 ) then
			data_valid 	<= '0';
		end if;
		--4
		if ( edge_rise = 16 ) then
			data_valid 	<= '1';
			pix <= '1';
		end if;
		if ( edge_rise = 17 ) then
			data_valid 	<= '0';
		end if;
		--5
 		if ( edge_rise = 18 ) then
			data_valid 	<= '1';
			pix <= '0';
		end if;
		if ( edge_rise = 19 ) then
			data_valid 	<= '0';
		end if;
		--6
 		if ( edge_rise = 20 ) then
			data_valid 	<= '1';
			pix <= '0';
		end if;
		if ( edge_rise = 21 ) then
			data_valid 	<= '0';
		end if;
		
		-------------Line 2
		--1
		if ( edge_rise = 30 ) then
			data_valid 	<= '1';
			pix <= '0';
		end if;
		if ( edge_rise = 31 ) then
			data_valid 	<= '0';
		end if;
		--2
 		if ( edge_rise = 32 ) then
			data_valid 	<= '1';
			pix <= '0';
		end if;
		if ( edge_rise = 33 ) then
			data_valid 	<= '0';
		end if;
		--3
 		if ( edge_rise = 34 ) then
			data_valid 	<= '1';
			pix <= '1';
		end if;
		if ( edge_rise = 35 ) then
			data_valid 	<= '0';
		end if;
		--4
		if ( edge_rise = 36 ) then
			data_valid 	<= '1';
			pix <= '0';
		end if;
		if ( edge_rise = 37 ) then
			data_valid 	<= '0';
		end if;
		--5
 		if ( edge_rise = 38 ) then
			data_valid 	<= '1';
			pix <= '0';
		end if;
		if ( edge_rise = 39 ) then
			data_valid 	<= '0';
		end if;
		--6
 		if ( edge_rise = 40 ) then
			data_valid 	<= '1';
			pix <= '1';
		end if;
		if ( edge_rise = 41 ) then
			data_valid 	<= '0';
		end if;
		
		-------------Line 3
		--1
		if ( edge_rise = 50 ) then
			data_valid 	<= '1';
			pix <= '0';
		end if;
		if ( edge_rise = 51 ) then
			data_valid 	<= '0';
		end if;
		--2
 		if ( edge_rise = 52 ) then
			data_valid 	<= '1';
			pix <= '0';
		end if;
		if ( edge_rise = 53 ) then
			data_valid 	<= '0';
		end if;
		--3
 		if ( edge_rise = 54 ) then
			data_valid 	<= '1';
			pix <= '0';
		end if;
		if ( edge_rise = 55 ) then
			data_valid 	<= '0';
		end if;
		--4
		if ( edge_rise = 56 ) then
			data_valid 	<= '1';
			pix <= '0';
		end if;
		if ( edge_rise = 57 ) then
			data_valid 	<= '0';
		end if;
		--5
 		if ( edge_rise = 58 ) then
			data_valid 	<= '1';
			pix <= '1';
		end if;
		if ( edge_rise = 59 ) then
			data_valid 	<= '0';
		end if;
		--6
 		if ( edge_rise = 60 ) then
			data_valid 	<= '1';
			pix <= '1';
		end if;
		if ( edge_rise = 61 ) then
			data_valid 	<= '0';
		end if;
		
		-------------Line 4
		--1
		if ( edge_rise = 70 ) then
			data_valid 	<= '1';
			pix <= '0';
		end if;
		--2
 		if ( edge_rise = 71 ) then
			data_valid 	<= '1';
			pix <= '0';
		end if;
		--3
 		if ( edge_rise = 72 ) then
			data_valid 	<= '1';
			pix <= '0';
		end if;
		--4
		if ( edge_rise = 73 ) then
			data_valid 	<= '1';
			pix <= '1';
		end if;
		--5
 		if ( edge_rise = 74 ) then
			data_valid 	<= '1';
			pix <= '1';
		end if;
		--6
 		if ( edge_rise = 75 ) then
			data_valid 	<= '1';
			pix <= '1';
		end if;
		if ( edge_rise = 76 ) then
			data_valid 	<= '0';
		end if;
		
		-------------Line 5
		--1
		if ( edge_rise = 80 ) then
			data_valid 	<= '1';
			pix <= '0';
		end if;
		--2
 		if ( edge_rise = 81 ) then
			data_valid 	<= '1';
			pix <= '0';
		end if;
		--3
 		if ( edge_rise = 82 ) then
			data_valid 	<= '1';
			pix <= '0';
		end if;
		--4
		if ( edge_rise = 83 ) then
			data_valid 	<= '1';
			pix <= '1';
		end if;
		--5
 		if ( edge_rise = 84 ) then
			data_valid 	<= '1';
			pix <= '1';
		end if;
		--6
 		if ( edge_rise = 85 ) then
			data_valid 	<= '1';
			pix <= '1';
		end if;
		if ( edge_rise = 86 ) then
			data_valid 	<= '0';
		end if;
		
		-------------Line 6
		--1
		if ( edge_rise = 90 ) then
			data_valid 	<= '1';
			pix <= '0';
		end if;
		--2
 		if ( edge_rise = 91 ) then
			data_valid 	<= '1';
			pix <= '0';
		end if;
		--3
 		if ( edge_rise = 92 ) then
			data_valid 	<= '1';
			pix <= '1';
		end if;
		--4
		if ( edge_rise = 93 ) then
			data_valid 	<= '1';
			pix <= '1';
		end if;
		--5
 		if ( edge_rise = 94 ) then
			data_valid 	<= '1';
			pix <= '1';
		end if;
		--6
 		if ( edge_rise = 95 ) then
			data_valid 	<= '1';
			pix <= '0';
		end if;
		if ( edge_rise = 96 ) then
			data_valid 	<= '0';
		end if;
		
		---------------------------START IMAGE 2 SO IMAGE 1 IS FULLY PUSHED OUT
		-------------Line 1
		--1
		if ( edge_rise = 100 ) then
			data_valid 	<= '1';
			pix <= '1';
		end if;
		if ( edge_rise = 101 ) then
			data_valid 	<= '0';
		end if;
		--2
 		if ( edge_rise = 102 ) then
			data_valid 	<= '1';
			pix <= '1';
		end if;
		if ( edge_rise = 103 ) then
			data_valid 	<= '0';
		end if;
		--3
 		if ( edge_rise = 104 ) then
			data_valid 	<= '1';
			pix <= '1';
		end if;
		if ( edge_rise = 105 ) then
			data_valid 	<= '0';
		end if;
		--4
		if ( edge_rise = 106 ) then
			data_valid 	<= '1';
			pix <= '1';
		end if;
		if ( edge_rise = 107 ) then
			data_valid 	<= '0';
		end if;
		--5
 		if ( edge_rise = 108 ) then
			data_valid 	<= '1';
			pix <= '0';
		end if;
		if ( edge_rise = 109 ) then
			data_valid 	<= '0';
		end if;
		--6
 		if ( edge_rise = 110 ) then
			data_valid 	<= '1';
			pix <= '0';
		end if;
		if ( edge_rise = 111 ) then
			data_valid 	<= '0';
		end if;
		
		-------------Line 2
		--1
		if ( edge_rise = 120 ) then
			data_valid 	<= '1';
			pix <= '0';
		end if;
		if ( edge_rise = 121 ) then
			data_valid 	<= '0';
		end if;
		--2
 		if ( edge_rise = 122 ) then
			data_valid 	<= '1';
			pix <= '0';
		end if;
		if ( edge_rise = 123 ) then
			data_valid 	<= '0';
		end if;
		--3
 		if ( edge_rise = 124 ) then
			data_valid 	<= '1';
			pix <= '1';
		end if;
		if ( edge_rise = 125 ) then
			data_valid 	<= '0';
		end if;
		--4
		if ( edge_rise = 126 ) then
			data_valid 	<= '1';
			pix <= '0';
		end if;
		if ( edge_rise = 127 ) then
			data_valid 	<= '0';
		end if;
		--5
 		if ( edge_rise = 128 ) then
			data_valid 	<= '1';
			pix <= '0';
		end if;
		if ( edge_rise = 129 ) then
			data_valid 	<= '0';
		end if;
		--6
 		if ( edge_rise = 130 ) then
			data_valid 	<= '1';
			pix <= '1';
		end if;
		if ( edge_rise = 131 ) then
			data_valid 	<= '0';
		end if;
		
	end process stimuli;         
	
END erosion_bin_arch;
