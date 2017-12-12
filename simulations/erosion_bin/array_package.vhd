library ieee;
	use ieee.math_real.all;
	use ieee.std_logic_1164.all;

	use ieee.numeric_std.all;		 -- casting int to unsigned
	use ieee.std_logic_textio.all; -- read std_vector_logic from a file

	
package array_package is
	--std_logic_vector arrays
	type array_of_std_logic_vector is array(natural range <>) of std_logic_vector;
	type array2D_of_std_logic_vector is array (natural range <>) of array_of_std_logic_vector;
	type array_of_std_logic is array(natural range <>) of std_logic;
	type array2D_of_std_logic is array (natural range <>) of array_of_std_logic;
	
	--integer arrays
	type array_of_int is array(natural range <>) of integer;
	type array2D_of_int is array (natural range <>) of array_of_int;
end package;

package body array_package is


end package body;