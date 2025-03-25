library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity core is
	generic(n:integer:=64);
	port( 	x0,x1,x2,x3,x4 : in std_logic_vector(n-1 downto 0);
		txt : in std_logic_vector(n-1 downto 0);
		data : in std_logic_vector(n-1 downto 0);
		clk, rst, sel, seld : in std_logic;
		c: integer range 0 to 11;
		sel0, sel1, sel2, sel3, sel4 : in std_logic_vector(1 downto 0);
		y : out std_logic_vector(2*n-1 downto 0));
end core;

architecture core_arch of core is 

component permutation is
	generic(n:integer);
	port( 	x0,x1,x2,x3,x4 : in std_logic_vector(n-1 downto 0);
		i: in integer range 0 to 11;
		y0,y1,y2,y3,y4 : out std_logic_vector(n-1 downto 0));
end component;

component reg is
	generic(n:integer);
	port( 	x: in std_logic_vector(n-1 downto 0);
		clk, rst : in std_logic;
		y : out std_logic_vector(n-1 downto 0));
end component;

component mux2to1 is
	generic (n :integer);
	port(A,B: in std_logic_vector(n-1 downto 0);
	     Sel: in std_logic;
	     G: out std_logic_vector(n-1 downto 0));
end component;

component mux4to1 is
	generic (n :integer);
	port(A,B,C,D: in std_logic_vector(n-1 downto 0);
	     Sel: in std_logic_vector(1 downto 0);
	     G: out std_logic_vector(n-1 downto 0));
end component;

component mux3to1 is
	generic (n :integer);
	port(A,B,C: in std_logic_vector(n-1 downto 0);
	     Sel: in std_logic_vector(1 downto 0);
	     G: out std_logic_vector(n-1 downto 0));
end component;

signal xorpl,xora,xors1,xors2,xors3,xors4,xorz,l0,l1,l2,l3,l4,t0,t1,t2,t3,t4,s0,s1,s2,s3,s4,d,g0,g1,g2,g3,g4,h0,h1,h2,h3,h4: std_logic_vector(n-1 downto 0);
signal yp,yt: std_logic_vector(2*n-1 downto 0);
signal i,j: integer range 0 to 11;

begin

--counters
i<=c+1;
j<=c+2;
--xor with pl/data
xorpl<= txt xor s0;
xora<= data xor s0;

--xor with key
xors1<= s1 xor x1;
xors2<= s2 xor x2;
xors3<= s3 xor x1;
xors4<= s4 xor x2;

--xor with 0||1
xorz<= s4(n-1 downto 1)&(s4(0) xor '1');

--muxes for perm inputs
U1: mux4to1 generic map(64) port map(x0,s0,xora,xorpl,sel0,t0);
U2: mux3to1 generic map(64) port map(x1,s1,xors1,sel1,t1);
U3: mux3to1 generic map(64) port map(x2,s2,xors2,sel2,t2);
U4: mux3to1 generic map(64) port map(x3,s3,xors3,sel3,t3);
U5: mux4to1 generic map(64) port map(x4,s4,xors4,xorz,sel4,t4);
--dec
U8: mux2to1 generic map(64) port map(t0,txt,seld,d);
--perm u=2
U6: permutation generic map(64) port map(d,t1,t2,t3,t4,c,l0,l1,l2,l3,l4);
U9: permutation generic map(64) port map(l0,l1,l2,l3,l4,i,g0,g1,g2,g3,g4);
U10: permutation generic map(64) port map(g0,g1,g2,g3,g4,j,h0,h1,h2,h3,h4);
--state regs
R1: reg generic map(64) port map (h0,clk,rst,s0);
R2: reg generic map(64) port map (h1,clk,rst,s1);
R3: reg generic map(64) port map (h2,clk,rst,s2);
R4: reg generic map(64) port map (h3,clk,rst,s3);
R5: reg generic map(64) port map (h4,clk,rst,s4);

--outputs
yp<= std_logic_vector(resize(unsigned(t0),2*n));
yt<= t3&t4;
U7: mux2to1 generic map(128) port map(yp,yt,sel,y);

end core_arch;
