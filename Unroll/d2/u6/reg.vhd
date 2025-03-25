library ieee;
use ieee.std_logic_1164.all;


entity reg is
	generic(n:integer);
	port( 	x: in std_logic_vector(n-1 downto 0);
		clk, rst : in std_logic;
		y : out std_logic_vector(n-1 downto 0));
end reg;

architecture reg_arch of reg is 

begin

process(clk,rst)

begin
	if rst='1' then
		y<=(others=>'0');
	elsif rising_edge(clk) then
		y<= x;
	end if;
end process;
end reg_arch;
