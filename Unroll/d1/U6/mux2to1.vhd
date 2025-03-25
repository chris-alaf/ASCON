library ieee;
use ieee.std_logic_1164.all;

entity mux2to1 is
	generic (n :integer);
	port(A,B: in std_logic_vector(n-1 downto 0);
	     Sel: in std_logic;
	     G: out std_logic_vector(n-1 downto 0));
end mux2to1;

architecture mux2to1_arch of mux2to1 is
begin
	with Sel select
		G <= A when '0',
		     B when OTHERS;
end mux2to1_arch;	

