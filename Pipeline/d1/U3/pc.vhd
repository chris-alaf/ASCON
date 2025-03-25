library ieee;
use ieee.std_logic_1164.all;


entity pc is
	generic(n:integer);
	port( x2 : in std_logic_vector(n-1 downto 0);
		i : in integer range 0 to 11;
		c2 : out std_logic_vector(n-1 downto 0));
end pc;

architecture pc_arch of pc is 

component coni is 
port( i : in integer range 0 to 11;
	con : out std_logic_vector(7 downto 0));
end component;

signal t, con: std_logic_vector(7 downto 0);

begin

U1: coni port map (i,con);
t <= x2(7 downto 0) xor con;
c2 <= x2 (n-1 downto 8) & t;
end pc_arch;
