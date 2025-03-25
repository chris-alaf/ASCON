library ieee;
use ieee.std_logic_1164.all;


entity fsm is
	port( new_data, ver : in std_logic;
		n_A,n_P : in integer range 0 to 31;
		clk,rst : in std_logic;
		mode : in std_logic_vector(1 downto 0);
		sel0, sel1, sel2, sel3, sel4 : out std_logic_vector(1 downto 0);
		c : out integer range 0 to 11;
		sel, seld, done, ready, valid : out std_logic);
		
end fsm;

architecture fsm_arch of fsm is 

type state is (idle,init,initr,assoc1,assocr,assoc,pl1,pl1d,plr,pl,pld,sp,spd,a1,sph,h1,h,final,finald,finalr,tag);
signal pr_state, nx_state: state;

signal t,pa,pb: integer range 0 to 12;
signal a,p: integer range 0 to 31;

begin

--timer & block counter
process(clk,rst)
begin
	if rst='1' then
		a<= 0;
		p<= 0;
		t<= 0;
	elsif rising_edge(clk) then
		if pr_state = idle then
			a<= 0;
			p<= 0;
			t<= 0;
		end if;
		if pr_state = assoc1 or pr_state = assoc or pr_state = h then
			a<= a+1;
		end if;
		if pr_state = pl1 or pr_state = pl or pr_state = pl1d or pr_state = pld or pr_state = a1 then
			p<= p+1;
		end if;
		if pr_state /= nx_state then 
			t<= 0;
		elsif t /= 11 and pr_state/=idle then
			t<= t+1;
		end if;
	end if;
end process;

--state reg
process(clk,rst)
begin
	if rst='1' then
		pr_state<= idle;
	elsif rising_edge(clk) then
		pr_state<=nx_state;
	end if;
end process;

--comb logic
process(rst,clk,pr_state,nx_state,t)
begin
	case pr_state is
		-- initial-waiting state
		when idle =>	ready<= '1';
				done<= '0';
				valid<= '0';
				if ver = '0' and (mode = "00" or mode = "01") then
					pa<=12;
					pb<=6;
				elsif ver = '0' and mode = "10" then
					pa<=12;
					pb<=12;
				elsif ver = '1' then
					pa<=12;
					pb<=8;
				end if;
				if new_data='1' then nx_state<= init;
				end if;
		-- state for init stage inputs
		when init =>	ready<= '0';
				done<= '0';
				valid<='0';
				c<= t;
				seld<= '0';
				sel<= '0';
				sel0<= "00";
				sel1<="00";
				sel2<= "00";
				sel3<="00";
				sel4<= "00";
				nx_state<= initr;
		-- init rounds 
		when initr =>	ready<= '0';
				done<= '0';
				valid<='0';
				c<= t+1;
				seld<= '0';
				sel<='0';
				sel0<= "01";
				sel1<="01";
				sel2<= "01";
				sel3<="01";
				sel4<= "01";
				if t = 10 and n_P = 1 and  mode = "10" then nx_state<= sph;
				elsif t = 10 and  mode = "10" then nx_state<= pl;
				elsif t = 10 then nx_state<= assoc1;
				end if;
		-- state for assoc stage 1st block inputs
		when assoc1 =>	ready<= '0';
				done<= '0';
				valid<='0';
				c<= t+pa-pb;
				seld<= '0';
				sel<='0';
				sel0<= "10";
				sel1<="01";
				sel2<= "01";
				sel3<="10";
				sel4<= "10";
				nx_state<= assocr;
		-- assoc rounds
		when assocr =>	ready<= '0';
				done<= '0';
				valid<='0';
				c<= t+pa-pb+1;
				seld<= '0';
				sel<='0';
				sel0<= "01";
				sel1<="01";
				sel2<= "01";
				sel3<="01";
				sel4<= "01";
				if t = 10-(pa-pb) and a /= n_A and mode ="10" then nx_state<= h;
				elsif t = 10-(pa-pb) and a = n_A and mode ="10" then nx_state<= idle;
				elsif t = 10-(pa-pb) and a /= n_A then nx_state<= assoc;
				elsif t = 10-(pa-pb) and n_P = 1 and  mode = "00" then nx_state<= sp;
				elsif t = 10-(pa-pb) and n_P = 1 and  mode = "01" then nx_state<= spd;
				elsif t = 10-(pa-pb) and  mode = "00" then nx_state<= pl1;
				elsif t = 10-(pa-pb) and  mode = "01" then nx_state<= pl1d;
				end if;
		-- state for assoc stage rest blocks inputs
		when assoc =>	ready<= '0';
				done<= '0';
				valid<='0';
				c<= t+pa-pb;
				seld<= '0';
				sel<='0';
				sel0<= "10";
				sel1<="01";
				sel2<= "01";
				sel3<="01";
				sel4<= "01";
				nx_state<= assocr;
		-- state for plaintxt stage 1st block inputs
		when pl1 =>	ready<= '0';
				done<= '0';
				if mode="10" then valid<='0';
				else valid<='1';
				end if;
				c<= t+pa-pb;
				seld<= '0';
				sel<='0';
				sel0<= "11";
				sel1<="01";
				sel2<= "01";
				sel3<="01";
				sel4<= "11";
				nx_state<= plr;
		-- alt state for dec mode
		when pl1d =>	ready<= '0';
				done<= '0';
				if mode="10" then valid<='0';
				else valid<='1';
				end if;
				c<= t+pa-pb;
				seld<= '1';
				sel<='0';
				sel0<= "11";
				sel1<="01";
				sel2<= "01";
				sel3<="01";
				sel4<= "11";
				nx_state<= plr;
		-- pl rounds and absorb rounds for hash
		when plr =>	ready<= '0';
				done<= '0';
				valid<='0';
				c<= t+pa-pb+1;
				seld<= '0'; 
				sel<='0';
				sel0<= "01";
				sel1<="01";
				sel2<= "01";
				sel3<="01";
				sel4<= "01";
				if t = 10-(pa-pb) and p /= n_P-1 and mode = "00" then nx_state<= pl;
				elsif t = 10-(pa-pb) and p /= n_P-1 and mode = "01" then nx_state<= pld;
				elsif t = 10-(pa-pb) and p /= n_P-1 and mode = "10" then nx_state<= pl;
				elsif t = 10-(pa-pb) and mode ="00" then nx_state<= final;
				elsif t = 10-(pa-pb) and mode ="01" then nx_state<= finald;
				elsif t = 10-(pa-pb) and mode ="10" then nx_state<= h1;
				end if;
		-- state for pl stage rest blocks inputs and absorb message for hash
		when pl =>	ready<= '0';
				done<= '0';
				if mode="10" then valid<='0';
				else valid<='1';
				end if;
				c<= t+pa-pb;
				seld<= '0';
				sel<='0';
				sel0<= "11";
				sel1<="01";
				sel2<= "01";
				sel3<="01";
				sel4<= "01";
				nx_state<= plr;
		-- alt state for dec mode
		when pld =>	ready<= '0';
				done<= '0';
				if mode="10" then valid<='0';
				else valid<='1';
				end if;
				c<= t+pa-pb;
				seld<= '1';
				sel<='0';
				sel0<= "11";
				sel1<="01";
				sel2<= "01";
				sel3<="01";
				sel4<= "01";
				nx_state<= plr;
		-- state for first=last pl block (pl & final)
		when sp =>	ready<= '0';
				done<= '0';
				valid<='1';
				c<= t;
				seld<= '0';
				sel<='0';
				sel0<= "11";
				sel1<="10";
				sel2<= "10";
				sel3<="01";
				sel4<= "11";
				nx_state<= finalr;
		-- alt state  for dec mode
		when spd =>	ready<= '0';
				done<= '0';
				valid<='1';
				c<= t;
				seld<= '1';
				sel<='0';
				sel0<= "11";
				sel1<="10";
				sel2<= "10";
				sel3<="01";
				sel4<= "11";
				nx_state<= finalr;
		-- state for finalization stage inputs
		when final =>	ready<= '0';
				done<= '0';
				valid<='1';
				c<= t;
				seld<= '0';
				sel<='0';
				sel0<= "11";
				sel1<="10";
				sel2<= "10";
				sel3<="01";
				sel4<= "01";
				nx_state<= finalr;
		-- alt state for dec mode
		when finald =>	ready<= '0';
				done<= '0';
				valid<='1';
				c<= t;
				seld<='1';
				sel<='0';
				sel0<= "11";
				sel1<="10";
				sel2<= "10";
				sel3<="01";
				sel4<= "01";
				nx_state<= finalr;
		-- final rounds
		when finalr =>	ready<= '0';
				done<= '0';
				valid<='0';
				c<= t+1;
				seld<= '0';
				sel<='0';
				sel0<= "01";
				sel1<="01";
				sel2<= "01";
				sel3<="01";
				sel4<= "01";
				if t = 10-(pa-pb) and mode ="10" then nx_state<= h;
				elsif t = 10 and mode ="10" then nx_state<= idle;
				elsif t = 10 then nx_state<= tag;
				end if;
		-- state for tag calculation
		when tag =>	ready<= '0';
				done<= '1';
				valid<='0';
				c<= t;
				seld<='0';
				sel<='1';
				sel0<= "01";
				sel1<="01";
				sel2<= "01";
				sel3<="10";
				sel4<= "10";
				nx_state<= idle;
		-- hashing
		-- using plr,finalr and asscor to reduce the number of states
		-- absorb message

		-- state for plaintxt stage 1st block inputs
		when a1 =>	ready<= '0';
				done<= '0';
				valid<='0';
				c<= t;
				seld<= '0';
				sel<='0';
				sel0<= "11";
				sel1<="01";
				sel2<= "01";
				sel3<="01";
				sel4<= "01";
				nx_state<= plr;
		-- hash1, squeeze hash first (no output)
		when h1 =>	ready<= '0';
				done<= '0';
				valid<='0';
				c<= t;
				seld<='0';
				sel<='0';
				sel0<= "11";
				sel1<="01";
				sel2<= "01";
				sel3<="01";
				sel4<= "01";
				nx_state<= finalr;
		-- hash rest
		when h =>	ready<= '0';
				done<= '0';
				valid<='1';
				c<= t;
				seld<='0';
				sel<='0';
				sel0<= "01";
				sel1<="01";
				sel2<= "01";
				sel3<="01";
				sel4<= "01";
				nx_state<= assocr;
		--special absorb
		when sph =>	ready<= '0';
				done<= '0';
				valid<='0';
				c<= t;
				seld<='0';
				sel<='0';
				sel0<= "11";
				sel1<="01";
				sel2<= "01";
				sel3<="01";
				sel4<= "01";
				nx_state<= finalr;
	end case;
end process;

end fsm_arch;
