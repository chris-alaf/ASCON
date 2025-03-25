library ieee;
use ieee.std_logic_1164.all;


entity ps is
	generic(n:integer);
	port( 	x0,x1,x2,x3,x4 : in std_logic_vector(n-1 downto 0);
		y0,y1,y2,y3,y4 : out std_logic_vector(n-1 downto 0));
end ps;

architecture ps_arch of ps is 

component alt_sbox is
	port( 	i0,i1,i2,i3,i4 : in std_logic;
		s0,s1,s2,s3,s4 : out std_logic);
end component;

type type1Dx1D is array (0 to 4) of std_logic_vector(n-1 downto 0);
signal t: type1Dx1D;

begin

L1:for i in 0 to n-1 generate
	u1: alt_sbox port map(x0(i),x1(i),x2(i),x3(i),x4(i),t(0)(i),t(1)(i),t(2)(i),t(3)(i),t(4)(i));
end generate;

y0<= t(4);
y1<= t(3);
y2<= t(2);
y3<= t(1);
y4<= t(0);
end ps_arch;

