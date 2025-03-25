library ieee;
use ieee.std_logic_1164.all;

entity mux4to1 is
	generic (n :integer);
	port(A,B,C,D: in std_logic_vector(n-1 downto 0);
	     Sel: in std_logic_vector(1 downto 0);
	     G: out std_logic_vector(n-1 downto 0));
end mux4to1;

architecture mux4to1_arch of mux4to1 is
begin
	with Sel select
		G <= A when "00",
		     B when "01",
		     C when "10",
		     D when OTHERS;
end mux4to1_arch;	

