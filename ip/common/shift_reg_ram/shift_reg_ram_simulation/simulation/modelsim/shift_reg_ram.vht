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
-- Generated on "04/10/2018 16:53:54"

-- Vhdl Test Bench template for design  :  shift_reg_ram
--
-- Simulation tool : ModelSim-Altera (VHDL)
--

LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY shift_reg_ram_vhd_tst IS
END shift_reg_ram_vhd_tst;
ARCHITECTURE shift_reg_ram_arch OF shift_reg_ram_vhd_tst IS
-- constants
-- signals
SIGNAL clk : STD_LOGIC;
SIGNAL data_in : STD_LOGIC_VECTOR(7 DOWNTO 0);
SIGNAL data_out : STD_LOGIC_VECTOR(7 DOWNTO 0);
SIGNAL data_valid : STD_LOGIC;
SIGNAL data_valid_out : STD_LOGIC;
SIGNAL depth : STD_LOGIC_VECTOR(15 DOWNTO 0);
SIGNAL reset_n : STD_LOGIC;
COMPONENT shift_reg_ram
	PORT (
	clk : IN STD_LOGIC;
	data_in : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
	data_out : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
	data_valid : IN STD_LOGIC;
	data_valid_out : OUT STD_LOGIC;
	depth : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
	reset_n : IN STD_LOGIC
	);
END COMPONENT;
-------------------------------------------------------------
----------------    SIMULATION SIGNALS & VARIABLES    -------

	signal sim_clk             : STD_LOGIC 	 := '0';
	signal sim_reset           : STD_LOGIC 	 := '0';
	signal sim_trig            : STD_LOGIC 	 := '0';
	shared variable edge_rise  : integer     := -1;
	shared variable edge_fall  : integer     := -1;

BEGIN
	i1 : shift_reg_ram
	PORT MAP (
-- list connections between master ports and signals
	clk => clk,
	data_in => data_in,
	data_out => data_out,
	data_valid => data_valid,
	data_valid_out => data_valid_out,
	depth => depth,
	reset_n => reset_n
	);

-------------------------------------------------------------
----------------    CLOCK & RESET SIGNALS    ----------------
	clk 	  <= sim_clk;
  reset_n   <= sim_reset;
-------------------------------------------------------------
----------------    CLOCK PROCESS    ------------------------
	simulation_clock : process
		-- repeat the counters edge_rise & edge_fall
		constant max_cycles    	: integer   := 140;
	begin
		-- set sim_clk signal
		sim_clk <= not(sim_clk);
		-- adjust
    -- simular lectura escritura y lectura/escrura a un ciclo y a la vez
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
			data_in <= X"00";
			depth <= X"0005";
		end if;
		if ( edge_rise = 1 ) then
			sim_reset 	<= '1';	-- stop reset
		end if;
		if ( edge_rise = 6 ) then
			data_valid 	<= '1';
			data_in <= X"00";
		end if;
    if ( edge_rise = 7 ) then
      data_valid 	<= '0';
    end if;
		if ( edge_rise = 8 ) then
      data_valid 	<= '1';
      data_in <= X"01";
		end if;
    if ( edge_rise = 9 ) then
      data_valid 	<= '0';
    end if;
		if ( edge_rise = 10 ) then
      data_valid 	<= '1';
      data_in <= X"02";
		end if;
    if ( edge_rise = 11 ) then
      data_valid 	<= '0';
    end if;
		if ( edge_rise = 12 ) then
      data_valid 	<= '1';
      data_in <= X"03";
		end if;
    if ( edge_rise = 13 ) then
      data_valid 	<= '0';
    end if;
		if ( edge_rise = 14 ) then
      data_valid 	<= '1';
      data_in <= X"04";
		end if;
		if ( edge_rise = 15 ) then
			data_in <= X"05";
		end if;
		if ( edge_rise = 16 ) then
      data_in <= X"06";
		end if;
		if ( edge_rise = 17 ) then
			data_valid 	<= '0';
		end if;
		if ( edge_rise = 20 ) then
      data_valid <= '1';
      data_in <= X"07";
		end if;
    if ( edge_rise = 21 ) then
      data_valid 	<= '0';
    end if;
		if ( edge_rise = 27 ) then
      data_valid <= '1';
      data_in <= X"08";
		end if;
		if ( edge_rise = 28 ) then
			data_valid <= '0';
		end if;

		if ( edge_rise = 30 ) then
			data_valid 	<= '1';
			data_in <= X"09";
		end if;
		if ( edge_rise = 31 ) then
			data_valid 	<= '0';
		end if;
		if ( edge_rise = 32 ) then
			data_valid 	<= '1';
			data_in <= X"0A";
		end if;
		if ( edge_rise = 33 ) then
			data_valid 	<= '0';
		end if;
		if ( edge_rise = 34 ) then
			data_valid 	<= '1';
			data_in <= X"0B";
		end if;
		if ( edge_rise = 35 ) then
			data_valid 	<= '0';
		end if;
		if ( edge_rise = 36 ) then
			data_valid 	<= '1';
			data_in <= X"0C";
		end if;
		if ( edge_rise = 37 ) then
			data_valid 	<= '0';
		end if;
		if ( edge_rise = 38 ) then
			data_valid 	<= '1';
			data_in <= X"0D";
		end if;
		if ( edge_rise = 39 ) then
			data_in <= X"0E";
		end if;
		if ( edge_rise = 40 ) then
			data_in <= X"10";
		end if;
		if ( edge_rise = 41 ) then
			data_valid 	<= '0';
		end if;
		if ( edge_rise = 42 ) then
			data_valid <= '1';
			data_in <= X"11";
		end if;
		if ( edge_rise = 43 ) then
			data_valid 	<= '0';
		end if;
		if ( edge_rise = 44 ) then
			data_valid <= '1';
			data_in <= X"12";
		end if;
		if ( edge_rise =45 ) then
			data_valid <= '0';
		end if;


  end process stimuli;
END shift_reg_ram_arch;
