library ieee;
use ieee.std_logic_1164.all;

entity mux3to1 is
	generic (n :integer);
	port(A,B,C: in std_logic_vector(n-1 downto 0);
	     Sel: in std_logic_vector(1 downto 0);
	     G: out std_logic_vector(n-1 downto 0));
end mux3to1;

architecture mux3to1_arch of mux3to1 is
begin
	with Sel select
		G <= A when "00",
		     B when "01",
		     C when OTHERS;
end mux3to1_arch;	

