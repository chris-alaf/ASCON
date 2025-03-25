library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity top is
	generic(n:integer:=64);
	port( 	x0,x1,x2,x3,x4 : in std_logic_vector(n-1 downto 0);
	     	txt : in std_logic_vector(n-1 downto 0);
		data : in std_logic_vector(n-1 downto 0);
		clk, rst, new_data, ver : in std_logic;
		mode : in std_logic_vector(1 downto 0);
		n_A,n_P : in std_logic_vector(4 downto 0);
		done, ready, valid : out std_logic;
	   	y: out std_logic_vector(2*n-1 downto 0));
end top;

architecture top_arch of top is

component core is
	generic(n:integer:=64);
	port( 	x0,x1,x2,x3,x4 : in std_logic_vector(n-1 downto 0);
		txt : in std_logic_vector(n-1 downto 0);
		data : in std_logic_vector(n-1 downto 0);
		clk, rst, sel, seld : in std_logic;
		c : integer range 0 to 11; 
		sel0,sel1,sel2,sel3,sel4 : in std_logic_vector(1 downto 0);
		y : out std_logic_vector(127 downto 0));
end component;

component fsm is
	port( new_data, ver : in std_logic;
		n_A,n_P : in integer range 0 to 31;
		clk,rst : in std_logic;
		mode : in std_logic_vector(1 downto 0);
		sel0, sel1, sel2, sel3, sel4 : out std_logic_vector(1 downto 0);
		c : out integer range 0 to 11;
		sel, seld, done, ready, valid : out std_logic);
		
end component;

component reg is
	generic(n:integer);
	port( 	x: in std_logic_vector(n-1 downto 0);
		clk, rst : in std_logic;
		y : out std_logic_vector(n-1 downto 0));
end component;

signal x0t,x1t,x2t,x3t,x4t,txtt,datat :  std_logic_vector(n-1 downto 0);
signal n_At,n_Pt :  std_logic_vector(4 downto 0);
signal sel0, sel1, sel2, sel3, sel4, modet : std_logic_vector(1 downto 0);
signal sel, seld, new_datat, vert : std_logic;
signal c : integer range 0 to 11;
signal a,p: integer range 0 to 31;

begin

rg1: reg generic map(64) port map (x0,clk,rst,x0t);
rg2: reg generic map(64) port map (x1,clk,rst,x1t);
rg3: reg generic map(64) port map (x2,clk,rst,x2t);
rg4: reg generic map(64) port map (x3,clk,rst,x3t);
rg5: reg generic map(64) port map (x4,clk,rst,x4t);
rg6: reg generic map(64) port map (txt,clk,rst,txtt);
rg7: reg generic map(64) port map (data,clk,rst,datat);
rg8: reg generic map(2) port map (mode,clk,rst,modet);
rg9: reg generic map(5) port map (n_A,clk,rst,n_At);
rg10: reg generic map(5) port map (n_P,clk,rst,n_Pt);

process(clk,rst)

begin
	if rst='1' then
		vert<='0';
		new_datat<='0';
	elsif rising_edge(clk) then
		vert<= ver;
		new_datat<=new_data;
	end if;
end process;

--to int
a<=to_integer(unsigned(n_At));
p<=to_integer(unsigned(n_Pt));

U1: fsm port map(new_datat,vert,a,p,clk,rst,modet,sel0,sel1,sel2,sel3,sel4,c,sel,seld,done,ready,valid);
U2: core port map(x0t,x1t,x2t,x3t,x4t,txtt,datat,clk,rst,sel,seld,c,sel0,sel1,sel2,sel3,sel4,y);
end top_arch;	

