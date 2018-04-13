------------------------------------------------------------------------
-- shift_reg_ram
------------------------------------------------------------------------
-- Main fuction of this component (one sentence).

-- Description of the component (10-15 lines)
------------------------------------------------------------------------

library ieee;
	use ieee.math_real.all;
	use ieee.std_logic_1164.all;
	use ieee.numeric_std.all;					-- casting int to unsigned
	use ieee.std_logic_textio.all;		-- read std_vector_logic from a file
	use ieee.std_logic_unsigned.all;	-- Needed for the sum used in counter.

entity shift_reg_ram is
	generic (
    DATA_SIZE	:	integer	:=	8
	);
	port (
    clk             :	IN STD_LOGIC;
    reset_n			    :	IN STD_LOGIC;
    depth           : IN STD_LOGIC_VECTOR (15 downto 0);
    data_in         :	IN STD_LOGIC_VECTOR ((DATA_SIZE-1) DOWNTO 0);
		data_out        :	OUT STD_LOGIC_VECTOR ((DATA_SIZE-1) DOWNTO 0);
    data_valid      : IN STD_LOGIC;
    data_valid_out  : OUT STD_LOGIC
	);
end shift_reg_ram;

architecture arch of shift_reg_ram is
  COMPONENT double_port_ram
  	PORT (
  	clock    	 : IN STD_LOGIC;
  	data       : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
  	q          : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
  	rdaddress  : IN STD_LOGIC_VECTOR(10 DOWNTO 0);
  	wraddress  : IN STD_LOGIC_VECTOR(10 DOWNTO 0);
		rden			 : IN STD_LOGIC;
  	wren       : IN STD_LOGIC
  	);
  END COMPONENT;

	--signal declarations (example: signal enable_data_valid    : STD_LOGIC;)
	--Module internal signals:

  SIGNAL  AB_in  : STD_LOGIC_VECTOR(10 DOWNTO 0);
  SIGNAL  AB_out : STD_LOGIC_VECTOR(10 DOWNTO 0);
  SIGNAL  ram_out : STD_LOGIC_VECTOR(15 DOWNTO 0);--((DATA_SIZE - 1) DOWNTO 0);
  SIGNAL  ram_out_reg : STD_LOGIC_VECTOR((DATA_SIZE - 1) DOWNTO 0);
  SIGNAL  ram_out_reg2 : STD_LOGIC_VECTOR((DATA_SIZE - 1) DOWNTO 0);
  SIGNAL  internal_slave_address  : STD_LOGIC_VECTOR(15 DOWNTO 0);
	--SIGNAL	data_valid_out_buffer	:	STD_LOGIC;

begin
  internal_slave_address <= std_logic_vector((15 downto DATA_SIZE => '0') &  data_in);
  ram_memory : double_port_ram
	PORT MAP (
-- list connections between master ports and signals
	clock => clk,
	data => internal_slave_address,--(15 downto DATA_SIZE => '0') &  data_in,--(15 downto DATA_SIZE => '0') &  data_in,--
	q => ram_out,--(11 DOWNTO 0 => ram_out, others => '0'),-- (DATA_SIZE - 1) DOWNTO 0 =>
	rdaddress => AB_out,
	wraddress => AB_in,
	rden	 => data_valid,
	wren => data_valid
	);

  counter_write:process (data_valid, clk)
  begin
    if rising_edge(clk) then
      if (reset_n = '0') then
        AB_in <= (others => '0');
      elsif (data_valid = '1') then
        if AB_in = (depth - 1) then
          AB_in <= (others => '0');
        else
          AB_in <= AB_in + 1;
        end if;
      end if;
    end if;
  end process;

  counter_read:process (data_valid, clk)
  begin
    if rising_edge(clk) then--rising_edge(clk) then
      if (reset_n = '0') then
        AB_out <= (0 => '1', 1 => '1' , others => '0');
      elsif (data_valid = '1') then--(data_valid_out_buffer = '1'
        if AB_out = (depth - 1) then
          AB_out <= (others => '0');
        else
          AB_out <= AB_out + 1;
        end if;
      end if;
    end if;
  end process;

	data_valid_out_proc: process(clk)
	BEGIN
		if rising_edge(clk) then
			if (reset_n = '0') then
				--data_valid_out_buffer <= '0';
				data_valid_out <= '0';
			else
				--data_valid_out_buffer <= data_valid;
				data_valid_out <= data_valid;
			end if;
		end if;
	end PROCESS;

	ram_out_proc: process(clk)
  BEGIN
    if rising_edge(clk) then
      if (reset_n = '0') then
        ram_out_reg <= (others => '0');
      elsif (data_valid = '1') then
        ram_out_reg <= ram_out ((DATA_SIZE - 1) downto 0);
      end if;
    end if;
  end PROCESS;

  ram_out_proc2: process(clk)
  BEGIN
    if rising_edge(clk) then
      if (reset_n = '0') then
        ram_out_reg2 <= (others => '0');
      elsif (data_valid = '1') then
        ram_out_reg2 <= ram_out_reg;
      end if;
    end if;
  end PROCESS;

  data_out <= ram_out_reg2;--ram_out ((DATA_SIZE - 1) downto 0); --ram_out_reg;--((DATA_SIZE-1) DOWNTO 0);
end arch;
