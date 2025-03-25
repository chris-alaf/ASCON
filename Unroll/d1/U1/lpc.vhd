library ieee;
use     ieee.std_logic_1164.all;
use     ieee.std_logic_arith.all;
use     ieee.std_logic_unsigned.all;

entity lpc is
   port(
      -- Global Signals
      clk  : in  std_logic; -- clock
      rst  : in  std_logic; -- asynchronous clear
      -- I/O
      sin  : in  std_logic; -- Serial input
      sout : out std_logic  -- Serial output
   );
end lpc;

architecture rtl of lpc is
   
   component top
	generic(n:integer:=64);
	port( 	
	       x0,x1,x2,x3,x4 : in std_logic_vector(n-1 downto 0);
	       txt : in std_logic_vector(n-1 downto 0);
		  data : in std_logic_vector(n-1 downto 0);
		  clk, rst, new_data, ver : in std_logic;
		  mode : in std_logic_vector(1 downto 0);
		  n_A,n_P : in std_logic_vector(4 downto 0);
		  done, ready, valid : out std_logic;
	   	   y: out std_logic_vector(2*n-1 downto 0));
end component;
   
   constant x0_lo : integer := 0;
   constant x0_hi : integer := x0_lo + 63;
   constant x1_lo : integer := x0_hi + 1;
   constant x1_hi : integer := x1_lo + 63;
   constant x2_lo : integer := x1_hi + 1;
   constant x2_hi : integer := x2_lo + 63;
   constant x3_lo : integer := x2_hi + 1;
   constant x3_hi : integer := x3_lo + 63;
   constant x4_lo : integer := x3_hi + 1;
   constant x4_hi : integer := x4_lo + 63;
   constant txt_lo : integer := x4_hi + 1;
   constant txt_hi : integer := txt_lo + 63;
   constant data_lo : integer := txt_hi + 1;
   constant data_hi : integer := data_lo + 63;
   constant new_data_flag : integer := data_hi + 1;
   constant ver_flag : integer := new_data_flag + 1;
   constant mode_lo : integer := ver_flag + 1;
   constant mode_hi : integer := mode_lo + 1;
   constant n_A_lo : integer := mode_hi + 1;
   constant n_A_hi : integer := n_A_lo + 4;
   constant n_P_lo : integer := n_A_hi + 1;
   constant n_P_hi : integer := n_P_lo + 4;
   constant input_sin_w : integer := n_P_hi + 1;

   constant done_flag : integer := 0;
   constant ready_flag : integer := done_flag + 1;
   constant valid_flag : integer := ready_flag + 1;
   constant y_lo : integer := valid_flag + 1;
   constant y_hi : integer := y_lo + 127;
   constant output_sin_w : integer := y_hi + 1;
   
   signal x0,x1,x2,x3,x4 : std_logic_vector(63 downto 0);
   signal txt,data : std_logic_vector(63 downto 0);
   signal new_data,ver : std_logic;
   signal mode : std_logic_vector(1 downto 0);
   signal n_A,n_P : std_logic_vector(4 downto 0);
   signal done,ready,valid : std_logic;
   signal y : std_logic_vector(127 downto 0);

   signal sin_r1  : std_logic;
   signal srin    : std_logic_vector(input_sin_w - 1 downto 0);
   signal srout    : std_logic_vector(output_sin_w - 1 downto 0);
   signal srout_r1 : std_logic_vector(output_sin_w - 1 downto 0);
   signal sh_flag  : std_logic;
   signal sout_r1 : std_logic;

begin
   srin_proc : process(rst, clk)
   begin
      if (rst='1') then
         srin <= (others=>'0');
      elsif (rising_edge(clk)) then
            for i in input_sin_w - 1  downto 1 loop
               srin(i) <= srin(i-1);
            end loop;
            sin_r1 <= sin;
            srin(0) <= sin_r1;

	    x0 <= srin(x0_hi downto x0_lo);
	    x1 <= srin(x1_hi downto x1_lo);
	    x2 <= srin(x2_hi downto x2_lo);
	    x3 <= srin(x3_hi downto x3_lo);
	    x4 <= srin(x4_hi downto x4_lo);
	    txt <= srin(txt_hi downto txt_lo);
	    data <= srin(data_hi downto data_lo);
	    new_data <= srin(new_data_flag);
	    ver <= srin(ver_flag);
	    mode <= srin(mode_hi downto mode_lo);
	    n_A <= srin(n_A_hi downto n_A_lo);
	    n_P <= srin(n_P_hi downto n_P_lo);
   
      end if;
   end process;

   srout_proc : process(rst, clk)
   begin
      if (rst='1') then
         srout    <= (others=>'0');
         srout_r1 <= (others=>'0');
         sh_flag  <= '0';
      elsif (rising_edge(clk)) then

             srout(done_flag) <= done;
             srout(ready_flag) <= ready;
             srout(valid_flag) <= valid;
             srout(y_hi downto y_lo) <= y;

            if (sh_flag  <= '0') then
               srout_r1 <= srout;
               sh_flag <= '1';
            else
               for i in 1 to output_sin_w - 1 loop
                  srout_r1(i) <= srout_r1(i-1);
               end loop;
               sh_flag     <= '0';
               srout_r1(0) <= srout_r1(output_sin_w - 1);
            end if;

            sout_r1 <= srout_r1(output_sin_w - 1);
            sout    <= sout_r1;
         
      end if;
   end process;

   u_top : top generic map(64)
      port map (
	 x0 => x0,
	 x1 => x1,
	 x2 => x2,
	 x3 => x3,
	 x4 => x4,
	 txt => txt,
	 data => data,
         clk => clk,
         rst => rst,
	 new_data => new_data,
	 ver => ver,
	 mode => mode,
	 n_A => n_A,
	 n_P => n_P,
	 done => done,
	 ready => ready,
	 valid => valid,
	 y => y);

end rtl;


