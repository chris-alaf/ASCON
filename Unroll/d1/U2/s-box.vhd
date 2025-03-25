library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity sbox is
	port( 	i0,i1,i2,i3,i4 : in std_logic;
		s0,s1,s2,s3,s4 : out std_logic);
end sbox;

architecture sbox_arch of sbox is 

signal i,s: std_logic_vector(4 downto 0);

begin

i<=i0&i1&i2&i3&i4;

s<= '0'&x"4" when i<='0'&x"0" else
	'0'&x"b" when i<='0'&x"1" else
	'1'&x"f" when i<='0'&x"2" else
	'1'&x"4" when i<='0'&x"3" else
	'1'&x"a" when i<='0'&x"4" else
	'1'&x"5" when i<='0'&x"5" else
	'0'&x"9" when i<='0'&x"6" else
	'0'&x"2" when i<='0'&x"7" else
	'1'&x"b" when i<='0'&x"8" else
	'0'&x"5" when i<='0'&x"9" else
	'0'&x"8" when i<='0'&x"a" else
	'1'&x"2" when i<='0'&x"b" else
	'1'&x"d" when i<='0'&x"c" else
	'0'&x"3" when i<='0'&x"d" else
	'0'&x"6" when i<='0'&x"e" else
	'1'&x"c" when i<='0'&x"f" else
	'1'&x"e" when i<='1'&x"0" else
	'1'&x"3" when i<='1'&x"1" else
	'0'&x"7" when i<='1'&x"2" else
	'0'&x"e" when i<='1'&x"3" else
	'0'&x"0" when i<='1'&x"4" else
	'0'&x"d" when i<='1'&x"5" else
	'1'&x"1" when i<='1'&x"6" else
	'1'&x"8" when i<='1'&x"7" else
	'1'&x"0" when i<='1'&x"8" else
	'0'&x"c" when i<='1'&x"9" else
	'0'&x"1" when i<='1'&x"a" else
	'1'&x"9" when i<='1'&x"b" else
	'1'&x"6" when i<='1'&x"c" else
	'0'&x"a" when i<='1'&x"d" else
	'0'&x"f" when i<='1'&x"e" else
	'1'&x"7" when i<='1'&x"f";

s0<=s(0);
s1<=s(1);
s2<=s(2);
s3<=s(3);
s4<=s(4);
end sbox_arch;

