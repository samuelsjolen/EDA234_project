library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity ic is
    Port (
        clk         	: in  std_logic;
        reset       	: in  std_logic;
				led_sec				: out	std_logic_vector(5 downto 0);
				led_min				: out std_logic_vector(3 downto 0);
				led_h	 				: out std_logic_vector(3 downto 0);	
				ic_h_tens			: out std_logic_vector(3 downto 0);--:= (Others => '0');
				ic_h_ones			: out std_logic_vector(3 downto 0);--:= (Others => '0');
				ic_m_tens			: out std_logic_vector(3 downto 0);--:= (Others => '0');
				ic_m_ones			: out std_logic_vector(3 downto 0)--:= (Others => '0')
				--num_ctrl			: out std_logic_vector(3 downto 0)
    );
end ic;

architecture ic_arch of ic is

-- Internal signals
signal sec_clk_enable : STD_LOGIC := '0'; -- Enable signal instead of using derived clock
signal LED_activate   : std_logic_vector(1 downto 0); 
signal refresh        : Unsigned(18 downto 0); 
signal counter_sec    : integer := 0;
signal num            : unsigned(3 downto 0);   
signal sec_ones       : unsigned(3 downto 0); 
signal sec_tens       : unsigned(3 downto 0);
signal min_ones       : unsigned(3 downto 0);
signal min_tens       : unsigned(3 downto 0);
signal h_ones         : unsigned(3 downto 0);
signal h_tens         : unsigned(3 downto 0);
signal SEG   					: unsigned(7 downto 0);
signal AN    					: unsigned(7 downto 0);
signal bin_sec				: unsigned(5 downto 0);
signal bin_min				: unsigned(3 downto 0);
signal bin_h  				: unsigned(3 downto 0);

signal val_h_tens			: unsigned(3 downto 0):= (Others => '0');
signal val_h_ones			: unsigned(3 downto 0):= (Others => '0');
signal val_m_tens			: unsigned(3 downto 0):= (Others => '0');
signal val_m_ones			: unsigned(3 downto 0):= (Others => '0');

begin
led_sec <= std_logic_vector(bin_sec); 		-- Used to display clock on FPGA LEDs
led_min <= std_logic_vector(bin_min); 		-- Used to display clock on FPGA LEDs
led_h 	<= std_logic_vector(bin_h);				-- Used to display clock on FPGA LEDs

ic_h_tens	<= std_logic_vector(h_tens); 		-- Used to trigger the alarm
ic_h_ones	<= std_logic_vector(h_ones); 		-- Used to trigger the alarm
ic_m_tens	<= std_logic_vector(min_tens); 	-- Used to trigger the alarm
ic_m_ones	<= std_logic_vector(min_ones); 	-- Used to trigger the alarm



--num_ctrl <= std_logic_vector(num);  -- TB 2

-- Reset logic, inverted on board

-- Counter 
sec_counter : process (clk, reset)
begin
	if rising_edge(clk) then 
		if reset = '0' then
			counter_sec <= 0;
			sec_clk_enable <= '0';
		else
			if counter_sec = 1 then -- Testbench
			--if counter_sec = 10000000 then -- Hardware
				counter_sec <= 0;
				sec_clk_enable <= '1';       -- Trigger events that depend on 1-second intervals
			else
				counter_sec <= counter_sec + 1; 
				sec_clk_enable <= '0';
			end if;
		end if;
	end if;
end process;

-- Process to create a toggling signal
refresh_proc : process (clk, reset)
begin
	if rising_edge(clk) then
		if reset = '0' then
			refresh <= (others => '0');
		else
			refresh <= refresh + 1;
		end if;
	end if;
end process;

LED_activate <= refresh(1) & refresh(2);  -- Testbench
-- LED_activate <= refresh(12) & refresh(13); -- Hardware

-- Process to switch between AN1 and AN0
an_proc : process (clk, reset, LED_activate)
begin
	if rising_edge(clk) then
		if reset = '0' then 
			AN <= (others => '0'); 
		else 
			if LED_activate = "00" then 
				AN <= "11111110"; -- Activates AN0
			elsif LED_activate = "01" then 
				AN <= "11111101"; -- Activates AN1
			elsif LED_activate = "10" then
				AN <= "11111011"; -- Activates AN2
			else
				AN <= "11110111"; -- Activates AN3
			end if;
		end if; 
	end if;
end process;

-- Multiplexer deciding which digit to send, depending on which segment is lit
MUX : process (sec_ones, sec_tens, LED_activate)
begin
	if LED_activate = "00" then
		num <= min_ones;
		--ic_m_ones <= std_logic_vector(SEG);
	elsif LED_activate = "01" then
		num <= min_tens;
		--ic_m_tens <= std_logic_vector(SEG);
	elsif LED_activate = "10" then
		num <= h_ones; 
		--ic_h_ones <= std_logic_vector(SEG);
	else
		num <= h_tens;
		--ic_h_tens <= std_logic_vector(SEG);
	end if; 
end process; 

-- Counter for displaying values
clock_counters : process (clk, reset)
begin
	if rising_edge(clk) then
		if reset = '0' then
			sec_ones  <= (others => '0'); -- Keeps track of time
			sec_tens  <= (others => '0'); -- Keeps track of time
      min_ones  <= (others => '0'); -- Keeps track of time
      min_tens  <= (others => '0'); -- Keeps track of time
      h_ones    <= (others => '0'); -- Keeps track of time
      h_tens    <= (others => '0'); -- Keeps track of time

			bin_sec 	<= (others => '0');	-- Used to display clock on FPGA LEDs
			bin_min		<= (others => '0');	-- Used to display clock on FPGA LEDs
			bin_h			<= (others => '0');	-- Used to display clock on FPGA LEDs
		elsif sec_clk_enable = '1' then
			sec_ones <= sec_ones + 1;
			bin_sec  <= bin_sec + 1;
			if sec_ones = "1001" then  -- If sec_ones reaches 9
					sec_ones <= (others => '0');
					sec_tens <= sec_tens + 1;
					bin_sec  <= bin_sec + 1;
					if sec_tens = "0101" then  -- If sec_tens reaches 5
							sec_tens <= (others => '0');
							bin_sec  <= (others => '0');
							min_ones <= min_ones + 1;
							bin_min  <= bin_min + 1;
									if min_ones = "1001" then -- If min_ones reaches 9
											min_ones <= (others => '0');
											min_tens <= min_tens + 1;
											bin_min  <= bin_min + 1;
													if min_tens = "0101" then -- If min_tens reaches 5
															min_tens <= (others => '0');
															val_m_ones <= (others => '0');
															h_ones <= h_ones + 1;
															bin_h  <= bin_h + 1;
															val_h_tens <= val_h_tens + 1;
																	if h_ones = "0011" then
																			if h_tens = "0010" then
																					h_ones <=  (others => '0');
																					h_tens <=  (others => '0');
																					bin_h  <=  (others => '0');
																			end if;
																	elsif h_ones = "1001" then
																			h_ones <= (others => '0');
																			h_tens <= h_tens + 1;
																			bin_h  <= bin_h + 1;
																	end if;
													end if;
										end if;
						end if;
					end if;
				end if;
		end if;
	--end if;
end process;

an_display_proc : process (num)
begin
	case num is
		when "0000" => 
			SEG <= "11000000"; -- Displays 0
		when "0001" => 
			SEG <= "11111001"; -- Displays 1
		when "0010" => 
			SEG <= "10100100"; -- Displays 2
		when "0011" => 
			SEG <= "10110000"; -- Displays 3
		when "0100" => 
			SEG <= "10011001"; -- Displays 4
		when "0101" => 
			SEG <= "10010010"; -- Displays 5
		when "0110" => 
			SEG <= "10000010"; -- Displays 6
		when "0111" => 
			SEG <= "11111000"; -- Displays 7
		when "1000" =>
			SEG <= "10000000"; -- Displays 8
		when "1001" => 
			SEG <= "10010000"; -- Displays 9
		when others => 
			SEG <= "11111101"; -- Default (error state)
	end case;
end process;
end architecture;
