library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity coni is
	port( i : in integer range 0 to 11;
	      con : out std_logic_vector(7 downto 0));
end coni;

architecture coni_arch of coni is 

begin

con<= std_logic_vector(to_unsigned(15-i, 4))& std_logic_vector(to_unsigned(i, 4));

end coni_arch;
