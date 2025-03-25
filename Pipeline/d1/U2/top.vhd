library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity top is
	generic(n:integer:=64);
	port( 	IV : in std_logic_vector(n-1 downto 0);
		k1,k2,k3,nonce : in std_logic_vector(2*n-1 downto 0);
	     	txt : in std_logic_vector(n-1 downto 0);
		data : in std_logic_vector(n-1 downto 0);
		clk, rst, new_data : in std_logic;
		mode : in std_logic_vector(1 downto 0);
		nA,nP : in std_logic_vector(4 downto 0);
		p1,p2: out std_logic_vector(n-1 downto 0);
	   	tag: out std_logic_vector(2*n-1 downto 0);
		done,valid : out std_logic);
end top;

architecture top_arch of top is

component core is
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
end component;

component fsm is
	port( new_data: in std_logic;
		nA, nP : in integer range 0 to 31;
		clk,rst : in std_logic;
		mode : in std_logic_vector(1 downto 0);
		sel, self, sela, selp, selr, seld, selb, selh, selhb : out std_logic;
		en1, en2, en3 : out std_logic;
		selk1, selk2, selk3 : out std_logic_vector(1 downto 0);
		c1, c2, c3 : out integer range 0 to 11;
		done,valid : out std_logic);
		
end component;

component reg is
	generic(n:integer);
	port( 	x: in std_logic_vector(n-1 downto 0);
		clk, rst, en : in std_logic;
		y : out std_logic_vector(n-1 downto 0));
end component;

signal IVt,txtt,datat : std_logic_vector(n-1 downto 0);
signal k1t,k2t,k3t,noncet : std_logic_vector(2*n-1 downto 0);
signal sel, self, sela, selp, selr, seld, selb, selh, selhb, en1, en2, en3, new_datat : std_logic;
signal c1, c2, c3 : integer range 0 to 11;
signal selk1, selk2, selk3, modet :  std_logic_vector(1 downto 0);
signal nAt, nPt : std_logic_vector(4 downto 0);
signal a,p: integer range 0 to 31;

begin

rg1: reg generic map(64) port map (IV,clk,rst,'1',IVt);
rg2: reg generic map(64) port map (txt,clk,rst,'1',txtt);
rg3: reg generic map(64) port map (data,clk,rst,'1',datat);
rg4: reg generic map(128) port map (k1,clk,rst,'1',k1t);
rg5: reg generic map(128) port map (k2,clk,rst,'1',k2t);
rg6: reg generic map(128) port map (k3,clk,rst,'1',k3t);
rg7: reg generic map(128) port map (nonce,clk,rst,'1',noncet);
rg8: reg generic map(2) port map (mode,clk,rst,'1',modet);
rg9: reg generic map(5) port map (nA,clk,rst,'1',nAt);
rg10: reg generic map(5) port map (nP,clk,rst,'1',nPt);

process(clk,rst)

begin
	if rst='1' then
		new_datat<='0';
	elsif rising_edge(clk) then
		new_datat<=new_data;
	end if;
end process;

--to int
a<=to_integer(unsigned(nAt));
p<=to_integer(unsigned(nPt));
	
U1: fsm port map(new_datat,a,p,clk,rst,modet,sel,self,sela,selp,selr,seld,selb,selh,selhb,en1,en2,en3,selk1,selk2,selk3,c1,c2,c3,done,valid);
U2: core port map(IVt,k1t,k2t,k3t,noncet,txtt,datat,en1,en2,en3,clk,rst,sel,self,sela,selp,selr,seld,selb,selh,selhb,selk1,selk2,selk3,c1,c2,c3,p1,p2,tag);

end top_arch;	


