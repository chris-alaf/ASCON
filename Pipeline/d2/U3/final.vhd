library ieee;
use ieee.std_logic_1164.all;


entity final is
	generic(n:integer:=64);
	port( 	x0,x1,x2,x3,x4,k1,k2 : in std_logic_vector(n-1 downto 0);
		i : integer range 0 to 11;
		clk,rst,en: std_logic;
		sel : std_logic;
		tagout : out std_logic_vector(2*n-1 downto 0));
end final;

architecture final_arch of final is 

component permutation is
	generic(n:integer);
	port( 	x0,x1,x2,x3,x4 : in std_logic_vector(n-1 downto 0);
		i: integer range 0 to 11;
		y0,y1,y2,y3,y4 : out std_logic_vector(n-1 downto 0));
end component;

component reg is
	generic(n:integer);
	port( 	x: in std_logic_vector(n-1 downto 0);
		clk, rst, en : in std_logic;
		y : out std_logic_vector(n-1 downto 0));
end component;

component mux2to1 is
	generic (n :integer);
	port(A,B: in std_logic_vector(n-1 downto 0);
	     Sel: in std_logic;
	     G: out std_logic_vector(n-1 downto 0));
end component;

signal t0,t1,t2,t3,t4,l0,l1,l2,l3,l4,s0,s1,s2,s3,s4,xors3,xors4,xork1,xork2,g0,g1,g2,g3,g4,h0,h1,h2,h3,h4: std_logic_vector(n-1 downto 0);
signal j,k: integer range 0 to 11;
signal tag: std_logic_vector(2*n-1 downto 0);
begin

--counters for u
j<=i+1;
k<=i+2;

--logic for inputs
xork1<= x1 xor k1;
xork2<= x2 xor k2;
xors3<= s3 xor k1;
xors4<= s4 xor k2;

--muxes for perm input
U1: mux2to1 generic map(64) port map(x0,s0,sel,t0);
U2: mux2to1 generic map(64) port map(xork1,s1,sel,t1);
U3: mux2to1 generic map(64) port map(xork2,s2,sel,t2);
U4: mux2to1 generic map(64) port map(x3,s3,sel,t3);
U5: mux2to1 generic map(64) port map(x4,s4,sel,t4);

--permutation round
U6: permutation generic map(64) port map(t0,t1,t2,t3,t4,i,l0,l1,l2,l3,l4);

--u2
U12: permutation generic map(64) port map(l0,l1,l2,l3,l4,j,g0,g1,g2,g3,g4);
U13: permutation generic map(64) port map(g0,g1,g2,g3,g4,k,h0,h1,h2,h3,h4);

--regs for output
U7: reg generic map(64) port map(h0,clk,rst,en,s0);
U8: reg generic map(64) port map(h1,clk,rst,en,s1);
U9: reg generic map(64) port map(h2,clk,rst,en,s2);
U10: reg generic map(64) port map(h3,clk,rst,en,s3);
U11: reg generic map(64) port map(h4,clk,rst,en,s4);

tag<= xors3&xors4;
U14: reg generic map(128) port map(tag,clk,rst,'1',tagout);

end final_arch;

