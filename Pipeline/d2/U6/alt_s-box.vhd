library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity alt_sbox is
	port( 	i0,i1,i2,i3,i4 : in std_logic;
		s0,s1,s2,s3,s4 : out std_logic);
end alt_sbox;

architecture alt_sbox_arch of alt_sbox is 

signal a0,a1,b0,b1,c0,c1,d0,d1,e0,e1,t0,t1,t2,t3,t4,t5,t6: std_logic;

begin

--between a for x0,e for x4
a0<= t0 xor '1';
a1<= a0 and i1;
b0<= i1 xor '1';
b1<= b0 and t3;
c0<= t3 xor '1';
c1<= c0 and i3;
d0<= i3 xor '1';
d1<= d0 and t6;
e0<= t6 xor '1';
e1<= e0 and t0;
--x0
t0<= i0 xor i4;
t1<= t0 xor b1;
s4<= t1 xor (t6 xor a1);
--x1
t2<= i1 xor c1;
s3<= t2 xor t1;
--x2
t3<= i2 xor i1;
t4<= t3 xor d1;
s2<= t4 xor '1';
--x3
t5<= i3 xor e1;
s1<= t5 xor t4;
--x4
t6<= i4 xor i3;
s0<= t6 xor a1;

end alt_sbox_arch;

