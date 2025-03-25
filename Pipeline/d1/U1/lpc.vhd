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
   
component top is
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
end component;
   
   constant IV_lo : integer := 0;
   constant IV_hi : integer := IV_lo + 63;
   constant k1_lo : integer := IV_hi + 1;
   constant k1_hi : integer := k1_lo + 127;
   constant k2_lo : integer := k1_hi + 1;
   constant k2_hi : integer := k2_lo + 127;
   constant k3_lo : integer := k2_hi + 1;
   constant k3_hi : integer := k3_lo + 127;
   constant nonce_lo : integer := k3_hi + 1;
   constant nonce_hi : integer := nonce_lo + 127;
   constant txt_lo : integer := nonce_hi + 1;
   constant txt_hi : integer := txt_lo + 63;
   constant data_lo : integer := txt_hi + 1;
   constant data_hi : integer := data_lo + 63;
   constant new_data_flag : integer := data_hi + 1;
   constant mode_lo : integer := new_data_flag + 1;
   constant mode_hi : integer := mode_lo + 1;
   constant nA_lo : integer := mode_hi + 1;
   constant nA_hi : integer := nA_lo + 4;
   constant nP_lo : integer := nA_hi + 1;
   constant nP_hi : integer := nP_lo + 4;
   constant input_sin_w : integer := nP_hi + 1;

   constant p1_lo : integer := 0;
   constant p1_hi : integer := p1_lo + 63;
   constant p2_lo : integer := p1_hi + 1;
   constant p2_hi : integer := p2_lo + 63;
   constant tag_lo : integer := p2_hi + 1;
   constant tag_hi : integer := tag_lo + 127;
   constant done_flag : integer := tag_hi + 1;
   constant valid_flag : integer := done_flag + 1;
   constant output_sin_w : integer := valid_flag + 1;
   
   signal IV : std_logic_vector(63 downto 0);
   signal k1,k2,k3,nonce : std_logic_vector(127 downto 0);
   signal txt,data : std_logic_vector(63 downto 0);
   signal new_data : std_logic;
   signal mode : std_logic_vector(1 downto 0);
   signal nA,nP : std_logic_vector(4 downto 0);
   signal p1,p2 : std_logic_vector(63 downto 0);
   signal tag : std_logic_vector(127 downto 0);
   signal done,valid : std_logic;

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

	    IV <= srin(IV_hi downto IV_lo);
	    k1 <= srin(k1_hi downto k1_lo);
	    k2 <= srin(k2_hi downto k2_lo);
	    k3 <= srin(k3_hi downto k3_lo);
	    nonce <= srin(nonce_hi downto nonce_lo);
	    txt <= srin(txt_hi downto txt_lo);
	    data <= srin(data_hi downto data_lo);
	    new_data <= srin(new_data_flag);
	    mode <= srin(mode_hi downto mode_lo);
	    nA <= srin(nA_hi downto nA_lo);
	    nP <= srin(nP_hi downto nP_lo);
   
      end if;
   end process;

   srout_proc : process(rst, clk)
   begin
      if (rst='1') then
         srout    <= (others=>'0');
         srout_r1 <= (others=>'0');
         sh_flag  <= '0';
      elsif (rising_edge(clk)) then

             srout(p1_hi downto p1_lo) <= p1;
             srout(p2_hi downto p2_lo) <= p2;
             srout(tag_hi downto tag_lo) <= tag;
             srout(done_flag) <= done;
             srout(valid_flag) <= valid;

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
	 IV => IV,
	 k1 => k1,
	 k2 => k2,
	 k3 => k3,
	 nonce => nonce,
	 txt => txt,
	 data => data,
         clk => clk,
         rst => rst,
	 new_data => new_data,
	 mode => mode,
	 nA => nA,
	 nP => nP,
	 p1 => p1,
	 p2 => p2,
	 tag => tag,
	 done => done,
	 valid => valid);

end rtl;


