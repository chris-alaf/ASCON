library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity pl is
	generic(n:integer);
	port( x0,x1,x2,x3,x4 : in std_logic_vector(n-1 downto 0);
		l0,l1,l2,l3,l4 : out std_logic_vector(n-1 downto 0));
end pl;

architecture pl_arch of pl is 

begin
l0<=x0 xor (x0(18 downto 0)&x0(63 downto 19)) xor (x0(27 downto 0)&x0(63 downto 28));
l1<=x1 xor (x1(60 downto 0)&x1(63 downto 61)) xor (x1(38 downto 0)&x1(63 downto 39));
l2<=x2 xor (x2(0)&x2(63 downto 1)) xor (x2(5 downto 0)&x2(63 downto 6));
l3<=x3 xor (x3(9 downto 0)&x3(63 downto 10)) xor (x3(16 downto 0)&x3(63 downto 17));
l4<=x4 xor (x4(6 downto 0)&x4(63 downto 7)) xor (x4(40 downto 0)&x4(63 downto 41));

end pl_arch;
