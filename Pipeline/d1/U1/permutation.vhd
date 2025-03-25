library ieee;
use ieee.std_logic_1164.all;

--do for finalization last round
entity permutation is
	generic(n:integer:=64);
	port( 	x0,x1,x2,x3,x4 : in std_logic_vector(n-1 downto 0);
		i: in integer range 0 to 11;
		y0,y1,y2,y3,y4 : out std_logic_vector(n-1 downto 0));
end permutation;

architecture permutation_arch of permutation is 

component pc is
	generic(n:integer:=64);
	port( x2 : in std_logic_vector(n-1 downto 0);
		i: in integer range 0 to 11;
		c2 : out std_logic_vector(n-1 downto 0));
end component;

component ps is
	generic(n:integer:=64);
	port( 	x0,x1,x2,x3,x4 : in std_logic_vector(n-1 downto 0);
		y0,y1,y2,y3,y4 : out std_logic_vector(n-1 downto 0));
end component;

component pl is
	generic(n:integer:=64);
	port( x0,x1,x2,x3,x4 : in std_logic_vector(n-1 downto 0);
		l0,l1,l2,l3,l4 : out std_logic_vector(n-1 downto 0));
end component;

signal c2,t0,t1,t2,t3,t4: std_logic_vector(n-1 downto 0);

begin

U1: pc port map(x2,i,c2);
U2: ps port map(x0,x1,c2,x3,x4,t0,t1,t2,t3,t4);
U3: pl port map(t0,t1,t2,t3,t4,y0,y1,y2,y3,y4);

end permutation_arch;

