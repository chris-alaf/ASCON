library ieee;
use ieee.std_logic_1164.all;


entity fsm is
	port( new_data: in std_logic;
		nA, nP : in integer range 0 to 31;
		clk,rst: in std_logic;
		mode : in std_logic_vector(1 downto 0);
		sel, self, sela, selp, selr, seld, selb, selh, selhb : out std_logic;
		en1, en2, en3 : out std_logic;
		selk1, selk2, selk3 : out std_logic_vector(1 downto 0);
		c1, c2, c3 : out integer range 0 to 11;
		done,valid : out std_logic);
		
end fsm;

architecture fsm_arch of fsm is

type state is (idle,init1,initr1,init2,initr2,first,round1,round2,second);
signal pr_state, nx_state: state;

signal t: integer range 0 to 4;
signal a,p,v,h: integer range 0 to 31;
signal init,fin,dtemp,vt: std_logic;
signal f:integer range 0 to 3;

begin

--timer & counters
process(clk,rst)
variable selkt1, selkt2, selkt3 :  std_logic_vector(1 downto 0);
begin
	if rst='1' then
		t<= 0;
		a<= 0;
		p<= 0;
		f<= 0;
		h<= 0;
		v<= 0;
		vt<='0';
		dtemp<='0';
		init<='0';
		fin<='0';
		selkt1:="00";
		selkt2:="00";
		selkt3:="00";
		selk1<="00";
		selk2<="00";
		selk3<="00";
	elsif rising_edge(clk) then
		--a counter for assoc blocks
		if h=nA-2 and pr_state=first then h<=nA-1;
		end if;
		if a=0 and mode="10" and h>0 then a<=nA;
			if h<nA-1 then h<=h+1;
			end if;
		elsif a=0 and mode="10" then a<=nA-1;
			if h<nA-1 then h<=h+1;
			end if;
		elsif a=0 and mode/="10" then a<=nA;
		elsif mode/="10" and (pr_state= first or pr_state= second) then a<=a-1;
		elsif mode="10" and (pr_state= first) then a<=a-1;
		end if;
		--p counter for pl blocks & 1st finalization start (f=2)
		if p=0 and mode/="10" then p<=nP;
		elsif mode="10" and (p=0 or (h=nA-2 and nA/=1)) then p<=nP;
		elsif mode/="10" and (pr_state= first or pr_state= second) then 
			p<=p-1;
			if f<2 and p= 1 then f<=f+1;
			end if;
		elsif mode="10" and (pr_state= second) then
			p<=p-1;
			if f<2 and p= 1 then f<=f+1;
			end if;
		end if;
		if pr_state=first and h=nA-1 then 
			if v/=nP-1 then v<=v+1;
			else v<=0;
			end if;
		end if;
		--done bug fix for hash
		if mode="10" and h=nA-1 and v=0 and pr_state=first then dtemp<='1';
		end if;
		if (mode/= "10" and f>0 and t=0) or (mode="10" and h>nA-2 and t=0) then vt<='1';
		else vt<='0';
		end if;
		-- init counter flip
		if pr_state=round2 and nA mod 2 /=0 and f>0 and init='0' and t=2 then init<= '1';
		elsif pr_state=round2 and nA mod 2 /=0 and f>0 and init='1' and t=2 then init<= '0';
		end if;
		-- final counter flip
		if pr_state=round2 and nA mod 2 /=0 and f>1 and fin='0' and t=2 then fin<= '1';
		elsif pr_state=round2 and nA mod 2 /=0 and f>1 and fin='1' and t=2 then fin<= '0';
		end if;
		--change first init key
		if pr_state = initr2 and t=2 then 
			selkt1:="01";
			selk1<=selkt1;
		end if;
		--change selk1,2,3
		if (pr_state= round1 and t=2) or (pr_state= round2 and t=2) then
				if a=1 then 
					if selkt1="00" then selkt1:="01";
					elsif selkt1="01" then selkt1:="10";
					else selkt1:="00";
					end if;
					if selkt2="00" then selkt2:="01";
					elsif selkt2="01" then selkt2:="10";
					else selkt2:="00";
					end if;
					selk1<=selkt1;
					selk2<=selkt2;
				end if;
				if p=1 and f>1 then 
					if selkt3="00" then selkt3:="01";
					elsif selkt3="01" then selkt3:="10";
					else selkt3:="00";
					end if;
					selk3<=selkt3;
				end if;
		end if;
		if pr_state = idle then
			t<= 0;
		end if;
		if pr_state /= nx_state then 
			t<= 0;
		elsif t /= 2 then
			t<= t+2;
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
		when idle =>	en1<='1';
				en2<='1';
				en3<='1';
				done<='0';
				valid<='0';
				if new_data='1' then nx_state<= init1;
				end if;

		-- 4 states for 1st msg init
		when init1 =>	-- calc counters
				c1<=t;
				-- sel outputs
				sel<= '0';
				nx_state<= initr1;

		when initr1 =>	-- calc counters
				c1<= t+2;
				-- sel outputs 
				sel<= '1';
				if t=2 then nx_state<= init2;
				end if;

		when init2 =>	-- calc counters
				c1<= t+6;
				-- sel outputs
				sel<= '1';
				nx_state<= initr2;

		when initr2 =>	-- calc counters
				c1<= t+8;
				-- sel outputs
				sel<= '1';
				if t=2 then nx_state<= first;
				end if;
		-- states for rest functions
		when first =>	-- calc counters
				--c1/init
				if mode="10" then c1<=t;
				elsif mode/="10" and (nA mod 2 = 0 or nA=1) then c1<=t;
				elsif mode/="10" and (nA mod 2 /= 0 and init = '1')  then c1<=t;
				else c1<=t+6;
				end if;
				--hash/normal
				if mode="10" then c2<= t;
				else c2<= t+6;
				end if;
				--c3/fin
				if mode="10" then c3<=t;
				elsif mode/="10" and (nA mod 2 = 0 or nA=1) then c3<= t+6;
				elsif mode/="10" and (nA mod 2 /= 0 and fin = '0') then c3<= t+6;
				else c3<= t;
				end if;
				-- sel outputs
				--check for init sel 
				if mode="10" then sel<='0';
				elsif mode/="10" and (nA mod 2 = 0 or nA=1 or (nA mod 2 /= 0 and init= '1')) then sel<= '0';
				else sel<= '1';
				end if;
				--check for final sel
				if mode="10" then self<='0';
			 	elsif mode/="10" and (nA mod 2 = 0 or nA=1 or (nA mod 2 /= 0 and fin= '0')) then self<= '1';
				else self<= '0';
				end if;
				--check for start of assoc/pl 
				if a = nA and mode/="10" then sela<= '0';
				elsif a = nA-1 and mode="10" then sela<= '0';
				else sela<= '1';
				end if;
				if p = nP and mode/="10" then selp<= '0';
				elsif p = nP and mode="10" then selp<= '0';
				else selp<= '1';
				end if;
				--rest
				selr<='0';
				if mode = "00" or mode = "10" then seld<= '0';
				elsif mode = "01" then seld<= '1';
				end if;
				if nP=1 then selb<= '1';
				else selb<='0';
				end if;
				--hash
				if mode="10" and nA=1 then selhb<='1';
				else selhb<='0';
				end if;
				if mode ="10" then selh<='1';
				else selh<='0';
				end if;
				valid<='0';
				done<='0';
				nx_state<= round1;

		when round1 =>	-- calc counters
				--c1/init
				if mode="10" then c1<=t+2;
				elsif mode/="10" and (nA mod 2 = 0 or nA=1) then c1<=t+2;
				elsif mode/="10" and (nA mod 2 /= 0 and init = '1') then c1<=t+2;
				else c1<=t+8;
				end if;
				if mode="10" then c2<= t+2;
				else c2<= t+8;
				end if;
				--c3/fin
				if mode="10" then c3<=t+2;
				elsif mode/="10" and (nA mod 2 = 0 or nA=1) then c3<= t+8;
				elsif mode/="10" and (nA mod 2 /= 0 and fin = '0') then c3<= t+8;
				else c3<= t+2;
				end if;
				-- sel outputs 
				sel<= '1';
				self<='1';
				sela<= '1';
				selp<= '1';
				selr<= '1';
				seld<= '0';
				selb<= '0';
				if vt='1' and t=0 then valid<='1';
				--elsif mode="10" and h>nA-2 and t=0 then valid<='1';
				else valid<='0';
				end if;
				if mode="10" and h=nA-1 and v=1 and dtemp='1' and t=0 then done<='1';
				else done<='0';
				end if;
				if t=2 then nx_state<= second;
				end if;

		when second =>	-- calc counters
				--c1/init
				if mode="10" then c1<=t+6;
				elsif mode/="10" and (nA mod 2 = 0 or nA=1) then
					c1<=t+6;
				elsif  mode/="10" and (nA mod 2 /= 0 and init = '1')  then
					c1<=t+6;
				else
					c1<=t;
				end if;
				c2<= t+6;
				--c3/fin
				if mode="10" then c3<=t+6;
				elsif mode/="10" and (nA mod 2 = 0 or nA=1) then
					c3<= t;
				elsif mode/="10" and (nA mod 2 /= 0 and fin = '0')  then
					c3<= t;
				else
					c3<= t+6;
				end if;
				-- sel outputs
				--check for init sel 
				if mode="10" then sel<='1';
				elsif mode/="10" and (nA mod 2 = 0 or (nA mod 2 /= 0 and init= '0')) then sel<= '1';
				else sel<= '0';
				end if;
				--check for final sel 
				if mode="10" then self<='1';
				elsif mode/="10" and (nA mod 2 = 0 or nA=1 or (nA mod 2 /= 0 and fin= '0')) then self<= '0';
				else self<= '1';
				end if;
				--check for start of assoc/pl 
				if mode="10" then sela<='1';
				elsif a = nA and mode/="10" then sela<= '0';
				else sela<= '1';
				end if;
				if mode="10" then selp<='1';
				elsif p = nP and mode/="10" then selp<= '0';
				--elsif p = nP and mode="10" then selp<= '0';
				else selp<= '1';
				end if;
				if mode="10" then selr<= '1';
				else selr<='0';
				end if;
				if mode = "00" or mode = "10" then seld<= '0';
				elsif mode = "01" then seld<= '1';
				end if;
				if nP=1 then selb<= '1';
				else selb<='0';
				end if;
				--hash
				if mode="10" and nA=1 then selhb<='1';
				else selhb<='0';
				end if;
				if mode ="10" then selh<='1';
				else selh<='0';
				end if;
				valid<='0';
				done<='0';
				nx_state<= round2;

		when round2 =>	-- calc counters
				--c1/init
				if mode="10" then c1<=t+8;
				elsif mode/="10" and (nA mod 2 = 0 or nA=1) then
					c1<=t+8;
				elsif mode/="10" and (nA mod 2 /= 0 and init = '1')  then
					c1<=t+8;
				else
					c1<=t+2;
				end if;
				c2<= t+8;
				--c3/fin
				if mode="10" then c3<=t+8;
				elsif mode/="10" and (nA mod 2 = 0 or nA=1) then
					c3<= t+2;
				elsif mode/="10" and (nA mod 2 /= 0 and fin= '0')  then
					c3<= t+2;
				else
					c3<= t+8;
				end if;
				-- sel outputs
				sel<= '1';
				self<= '1';
				sela<= '1';
				selp<= '1';
				selr<= '1';
				seld<= '0';
				selb<= '0';
				if vt='1' and t=0 and mode/="10" then valid<='1';
				else valid<='0';
				end if;
				if (p=nP-2 and f=2 and mode/="10" and t=0) or (nA=1 and mode/="10" and t=0) then done<='1';
				else done<='0';
				end if;
				if t=2 then nx_state<= first;
				end if;
	end case;
end process;

end fsm_arch;
