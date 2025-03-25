library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity core is
	generic(n:integer:=64);
	port( 	IV : in std_logic_vector(n-1 downto 0);
		k1,k2,k3,nonce : in std_logic_vector(2*n-1 downto 0);
		txt : in std_logic_vector(n-1 downto 0);
		data : in std_logic_vector(n-1 downto 0);
		en1,en2,en3: in std_logic;
		clk, rst, sel, self, sela, selp, selr, seld, selb, selh, selhb : in std_logic;
		selk1,selk2,selk3 : in std_logic_vector(1 downto 0);
		c1, c2, c3 : in integer range 0 to 11;
		p1,p2 : out std_logic_vector(n-1 downto 0);
		tag : out std_logic_vector(2*n-1 downto 0));
end core;

architecture core_arch of core is 

component init is
	generic(n:integer:=64);
	port( 	x0,x1,x2,x3,x4 : in std_logic_vector(n-1 downto 0);
		i : in integer range 0 to 11;
		clk,rst,en: std_logic;
		sel : std_logic;
		y0,y1,y2,y3,y4 : out std_logic_vector(n-1 downto 0));
end component;

component assoc is
	generic(n:integer:=64);
	port( 	x0,x1,x2,x3,x4,k1,k2,ad : in std_logic_vector(n-1 downto 0);
		i : in integer range 0 to 11;
		clk,rst,en: std_logic;
		sel,selr,selh : std_logic;
		y0,y1,y2,y3,y4 : out std_logic_vector(n-1 downto 0));
end component;

component encdec is
	generic(n:integer:=64);
	port( 	x0,x1,x2,x3,x4,txt : in std_logic_vector(n-1 downto 0);
		i : in integer range 0 to 11;
		clk,rst,en: std_logic;
		sel,selr,seld : std_logic;
		output,y0,y1,y2,y3,y4 : out std_logic_vector(n-1 downto 0));
end component;

component final is
	generic(n:integer:=64);
	port( 	x0,x1,x2,x3,x4,k1,k2: in std_logic_vector(n-1 downto 0);
		i : in integer range 0 to 11;
		clk,rst,en: std_logic;
		sel : std_logic;
		tagout : out std_logic_vector(2*n-1 downto 0));
end component;

component mux2to1 is
	generic (n :integer);
	port(A,B: in std_logic_vector(n-1 downto 0);
	     Sel: in std_logic;
	     G: out std_logic_vector(n-1 downto 0));
end component;

component mux3to1 is
	generic (n :integer);
	port(A,B,C: in std_logic_vector(n-1 downto 0);
	     Sel: in std_logic_vector(1 downto 0);
	     G: out std_logic_vector(n-1 downto 0));
end component;

component reg is
	generic(n:integer);
	port( 	x: in std_logic_vector(n-1 downto 0);
		clk, rst, en : in std_logic;
		y : out std_logic_vector(n-1 downto 0));
end component;

signal t0,t1,t2,t3,t4,v0,v1,v2,v3,v4,z0,z1,z2,z3,z4,b0,b1,b2,b3,b4,byp,pl,ha0,ha1,ha2,ha3,ha4,xorh,hlast: std_logic_vector(n-1 downto 0);
signal kinit,kfin,kass: std_logic_vector(2*n-1 downto 0);

begin

--key selection muxes
U12: mux3to1 generic map(128) port map(k1,k2,k3,selk1,kinit);
U13: mux3to1 generic map(128) port map(k1,k2,k3,selk2,kass);
U14: mux3to1 generic map(128) port map(k1,k2,k3,selk3,kfin);

-- stages
U1: init port map(IV,kinit(2*n-1 downto n),kinit(n-1 downto 0),nonce(2*n-1 downto n),nonce(n-1 downto 0),c1,clk,rst,en1,sel,t0,t1,t2,t3,t4);
U2: assoc port map(t0,t1,t2,t3,t4,kass(2*n-1 downto n),kass(n-1 downto 0),data,c2,clk,rst,en2,sela,selr,selh,z0,z1,z2,z3,z4);
U3: encdec port map(ha0,ha1,ha2,ha3,ha4,txt,c2,clk,rst,en3,selp,selr,seld,p1,v0,v1,v2,v3,v4);
U4: final port map(byp,b1,b2,b3,b4,kfin(2*n-1 downto n),kfin(n-1 downto 0),c3,clk,rst,'1',self,tag);

--bypass muxes for num of pl blocks
U6: mux2to1 generic map(64) port map(v0,ha0,selb,b0);
U7: mux2to1 generic map(64) port map(v1,ha1,selb,b1);
U8: mux2to1 generic map(64) port map(v2,ha2,selb,b2);
U9: mux2to1 generic map(64) port map(v3,ha3,selb,b3);
U10: mux2to1 generic map(64) port map(v4,ha4,selb,b4);


--xor last bock of absorb message
U5: mux2to1 generic map(64) port map(z0,t0,selhb,hlast);

--xor for hash if nA=1
xorh<= hlast xor data;

--byp hash last absorb
U16: mux2to1 generic map(64) port map(z0,xorh,selh,ha0);

--bypass muxes for hash
U17: mux2to1 generic map(64) port map(z1,t1,selhb,ha1);
U18: mux2to1 generic map(64) port map(z2,t2,selhb,ha2);
U19: mux2to1 generic map(64) port map(z3,t3,selhb,ha3);
U20: mux2to1 generic map(64) port map(z4,t4,selhb,ha4);

--p2 calc (last block)
pl<= b0 xor txt;
U21: reg generic map(64) port map(pl,clk,rst,'1',p2);
--mux for dec 
U11: mux2to1 generic map(64) port map(pl,txt,seld,byp);

end core_arch;
