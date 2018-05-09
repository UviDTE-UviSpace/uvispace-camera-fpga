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
-- Generated on "12/04/2017 14:38:06"
                                                            
-- Vhdl Test Bench template for design  :  frame_sync
-- 
-- Simulation tool : ModelSim-Altera (VHDL)
-- 

LIBRARY ieee;                                               
USE ieee.std_logic_1164.all;                                

ENTITY frame_sync_vhd_tst IS
END frame_sync_vhd_tst;
ARCHITECTURE frame_sync_arch OF frame_sync_vhd_tst IS
-- constants                                                 
-- signals                                                   
SIGNAL clk : STD_LOGIC;
SIGNAL in_data_valid : STD_LOGIC;
SIGNAL in_frame_valid : STD_LOGIC;
SIGNAL in_pix : STD_LOGIC_VECTOR(11 DOWNTO 0);
SIGNAL out_data_valid : STD_LOGIC;
SIGNAL out_frame_valid : STD_LOGIC;
SIGNAL out_pix : STD_LOGIC_VECTOR(11 DOWNTO 0);
SIGNAL reset_n : STD_LOGIC;
COMPONENT frame_sync
	PORT (
	clk : IN STD_LOGIC;
	in_data_valid : IN STD_LOGIC;
	in_frame_valid : IN STD_LOGIC;
	in_pix : IN STD_LOGIC_VECTOR(11 DOWNTO 0);
	out_data_valid : OUT STD_LOGIC;
	out_frame_valid : OUT STD_LOGIC;
	out_pix : OUT STD_LOGIC_VECTOR(11 DOWNTO 0);
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
	i1 : frame_sync
	GENERIC MAP(N=>2) --skip 3 frames
	PORT MAP (
-- list connections between master ports and signals
	clk => clk,
	in_data_valid => in_data_valid,
	in_frame_valid => in_frame_valid,
	in_pix => in_pix,
	out_data_valid => out_data_valid,
	out_frame_valid => out_frame_valid,
	out_pix => out_pix,
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
		constant max_cycles    	: integer   := 100;
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
		
		if ( edge_rise = 0 ) then
			in_pix <= (others => '0');
			in_frame_valid <= '0';
			in_data_valid <= '0';
			sim_reset 	<= '0';	-- reset
		end if;
		if ( edge_rise = 1 ) then
			sim_reset 	<= '1';	-- stop reset
		end if;
		
		--frame 1
		if ( edge_rise = 4 ) then
			in_frame_valid <= '1';
		end if;
		
		if ( edge_rise = 7 ) then
			in_data_valid <= '1';
			in_pix <= "000011111111";
		end if;
		if ( edge_rise = 8 ) then
			in_data_valid <= '0';
			in_pix <= (others => '0');
		end if;
		if ( edge_rise = 9 ) then
			in_data_valid <= '1';
			in_pix <= "000011111111";
		end if;
		if ( edge_rise = 10 ) then
			in_data_valid <= '0';
			in_pix <= (others => '0');
		end if;
		if ( edge_rise = 12 ) then
			in_frame_valid <= '0';
		end if;
		
		--frame 2
		if ( edge_rise = 14 ) then
			in_frame_valid <= '1';
		end if;
		
		if ( edge_rise = 17 ) then
			in_data_valid <= '1';
			in_pix <= "000011111111";
		end if;
		if ( edge_rise = 18 ) then
			in_data_valid <= '0';
			in_pix <= (others => '0');
		end if;
		if ( edge_rise = 19 ) then
			in_data_valid <= '1';
			in_pix <= "000011111111";
		end if;
		if ( edge_rise = 20 ) then
			in_data_valid <= '0';
			in_pix <= (others => '0');
		end if;
		if ( edge_rise = 22 ) then
			in_frame_valid <= '0';
		end if;

		
		--frame 3
		if ( edge_rise = 24 ) then
			in_frame_valid <= '1';
		end if;
		
		if ( edge_rise = 27 ) then
			in_data_valid <= '1';
			in_pix <= "000011111111";
		end if;
		if ( edge_rise = 28 ) then
			in_data_valid <= '0';
			in_pix <= (others => '0');
		end if;
		if ( edge_rise = 29 ) then
			in_data_valid <= '1';
			in_pix <= "000011111111";
		end if;
		if ( edge_rise = 30 ) then
			in_data_valid <= '0';
			in_pix <= (others => '0');
		end if;
		if ( edge_rise = 32 ) then
			in_frame_valid <= '0';
		end if;
	
		--frame 4
		if ( edge_rise = 34 ) then
			in_frame_valid <= '1';
		end if;
		
		if ( edge_rise = 37 ) then
			in_data_valid <= '1';
			in_pix <= "000011111111";
		end if;
		if ( edge_rise = 38 ) then
			in_data_valid <= '0';
			in_pix <= (others => '0');
		end if;
		if ( edge_rise = 39 ) then
			in_data_valid <= '1';
			in_pix <= "000011111111";
		end if;
		if ( edge_rise = 40 ) then
			in_data_valid <= '0';
			in_pix <= (others => '0');
		end if;
		if ( edge_rise = 42 ) then
			in_frame_valid <= '0';
		end if;
		
	end process stimuli;   

END frame_sync_arch;
