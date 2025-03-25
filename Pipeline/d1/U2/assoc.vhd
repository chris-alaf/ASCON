library ieee;
use ieee.std_logic_1164.all;


entity assoc is
	generic(n:integer:=64);
	port( 	x0,x1,x2,x3,x4,k1,k2,ad : in std_logic_vector(n-1 downto 0);
		i : in integer range 0 to 11;
		clk,rst,en: std_logic;
		sel, selr, selh : std_logic;
		y0,y1,y2,y3,y4 : out std_logic_vector(n-1 downto 0));
end assoc;

architecture assoc_arch of assoc is 

component permutation is
	generic(n:integer);
	port( 	x0,x1,x2,x3,x4 : in std_logic_vector(n-1 downto 0);
		i: in integer range 0 to 11;
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

signal t0,t1,t2,t3,t4,l0,l1,l2,l3,l4,s0,s1,s2,s3,s4,xora,xorz,xork3,xork4,byad,g0,g1,g2,g3,g4: std_logic_vector(n-1 downto 0);
signal j: integer range 0 to 11;
begin

--counters for u
j<=i+1;

--logic for inputs
xora<= t0 xor ad;
xork3<= x3 xor k1;
xork4<= x4 xor k2;
--mux for bypassing xor
U6: mux2to1 generic map(64) port map(xora,t0,selr,byad);

--muxes for perm input
U1: mux2to1 generic map(64) port map(x0,s0,sel,t0);
U2: mux2to1 generic map(64) port map(x1,s1,sel,t1);
U3: mux2to1 generic map(64) port map(x2,s2,sel,t2);
U4: mux2to1 generic map(64) port map(xork3,s3,sel,t3);
U5: mux2to1 generic map(64) port map(xork4,s4,sel,t4);

--permutation round
U7: permutation generic map(64) port map(byad,t1,t2,t3,t4,i,l0,l1,l2,l3,l4);

--u2
U14: permutation generic map(64) port map(l0,l1,l2,l3,l4,j,g0,g1,g2,g3,g4);

--regs for output
U8: reg generic map(64) port map(g0,clk,rst,en,s0);
U9: reg generic map(64) port map(g1,clk,rst,en,s1);
U10: reg generic map(64) port map(g2,clk,rst,en,s2);
U11: reg generic map(64) port map(g3,clk,rst,en,s3);
U12: reg generic map(64) port map(g4,clk,rst,en,s4);

--output
y0<=s0;
y1<=s1;
y2<=s2;
y3<=s3;

--mux for output y4(diff in hash)
xorz<=s4(63 downto 1)&(s4(0) xor '1');
U15: mux2to1 generic map(64) port map(xorz,s4,selh,y4);

end assoc_arch;


