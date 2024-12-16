library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity ic is
    Port (
        clk         	: in    std_logic;
        reset       	: in    std_logic; 
        SEG         	: out   std_logic_vector(7 downto 0);
        AN          	: out   std_logic_vector(7 downto 0);
				reset_lcd			: out		std_logic; -- Reset to update the LCD every clock cycle
				h_tens_lcd		: out   std_logic_vector(7 downto 0);
				h_ones_lcd		:	out 	std_logic_vector(7 downto 0);
				min_ones_lcd	:	out 	std_logic_vector(7 downto 0);
				min_tens_lcd	:	out 	std_logic_vector(7 downto 0)
    );
end ic;

architecture ic_arch of ic is

-- Internal signals
signal sec_clk_enable : STD_LOGIC := '0'; -- Enable signal instead of using derived clock
signal LED_activate   : STD_LOGIC; 
signal refresh        : Unsigned(18 downto 0); 
signal counter_sec    : integer := 0;
signal num            : unsigned(3 downto 0);   
signal sec_ones       : unsigned(3 downto 0); 
signal sec_tens       : unsigned(3 downto 0);
signal min_ones       : unsigned(3 downto 0);
signal min_tens       : unsigned(3 downto 0);
signal h_ones         : unsigned(3 downto 0);
signal h_tens         : unsigned(3 downto 0);
signal reset_lcd_flag	: std_logic;
signal reset_lcd_int	: std_logic;



begin

	reset_lcd <= reset_lcd_int;

-- Reset logic, inverted on board

-- Counter 
sec_counter : process (clk, reset)
begin
	if rising_edge(clk) then 
		if reset = '0' then
			counter_sec <= 0;
			sec_clk_enable <= '0';
		else
			if counter_sec = 100000000 then  -- Adjust based on input clock frequency
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

LED_activate <= refresh(13);  -- Change this division if display flickers

-- Process to switch between AN1 and AN0
an_proc : process (clk, reset, LED_activate)
begin
	if rising_edge(clk) then
		if reset = '0' then 
			AN <= (others => '0'); 
		else 
			if LED_activate = '1' then 
				AN <= "11111110"; -- Activates AN0
			else
				AN <= "11111101"; -- Activates AN1
			end if;
		end if; 
	end if;
end process;

-- Counter for displaying values
clock_counters : process (clk, reset)
begin
	if rising_edge(clk) then
		if reset = '0' then
			 reset_lcd <= '0';
			sec_ones  <= (others => '0');
			sec_tens  <= (others => '0');
      min_ones  <= (others => '0');
      min_tens  <= (others => '0');
      h_ones    <= (others => '0');
      h_tens    <= (others => '0');
		elsif sec_clk_enable = '1' then
			sec_ones <= sec_ones + 1;
			if sec_ones = "1001" then  -- If sec_ones reaches 9
				sec_ones <= (others => '0');
				sec_tens <= sec_tens + 1;
				if sec_tens = "0101" then  -- If sec_tens reaches 5
					sec_tens <= (others => '0');
          min_ones <= min_ones + 1;
					reset_lcd_flag <= '1';
						if reset_lcd_int = '1' then
							reset_lcd_flag <= '0';
						end if;
	          if min_ones = "1001" then -- If min_ones reaches 9
            min_ones <= (others => '0');
            min_tens <= min_tens + 1;
            if min_tens = "0101" then -- If min_tens reaches 5
              min_tens <= (others => '0');
              h_ones <= h_ones + 1;
              if h_ones = "1001" then -- If h_ones reaches 9
                h_ones <= (others => '0');
                h_tens <= h_tens + 1;
                if h_tens = "0010" then -- If h_tens reaches 2
                  h_tens <= (others => '0');
                end if;
              end if;
            end if;
          end if;
         end if;
			end if;
		end if;
	end if;
end process;

rst_lcd_proc : process (clk)
variable counter : integer :=0;
begin
	if rising_edge(clk) then
			if reset = '0' then
				reset_lcd_int <= '0';
			end if;
			if reset_lcd_flag = '1' then
				if counter = 1000 then -- Change depending on how long reset should be pressed
					reset_lcd_int <= '1';
				else
					counter := counter + 1;
					reset_lcd_int <= '0';
				end if;
		end if;
	end if;
end process;

-- Multiplexer deciding which digit to send, depending on which segment is lit
MUX : process (sec_ones, sec_tens, LED_activate)
begin
	if LED_activate = '1' then
		num <= sec_ones; 
	else
		num <= sec_tens;
	end if; 
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

-- Display output 
display_min_ones  : process (min_ones)
begin
	case min_ones is
		when "0000" => 
			min_ones_lcd <= "00110000"; -- Displays 0
		when "0001" => 
			min_ones_lcd <= "00110001"; -- Displays 1
		when "0010" => 
			min_ones_lcd <= "00110010"; -- Displays 2
		when "0011" => 
			min_ones_lcd <= "00110011"; -- Displays 3
		when "0100" => 
			min_ones_lcd <= "00110100"; -- Displays 4
		when "0101" => 
			min_ones_lcd <= "00110101"; -- Displays 5
		when "0110" => 
			min_ones_lcd <= "00110110"; -- Displays 6
		when "0111" => 
			min_ones_lcd <= "00110111"; -- Displays 7
		when "1000" =>
			min_ones_lcd <= "00111000"; -- Displays 8
		when "1001" => 
			min_ones_lcd <= "00111001"; -- Displays 9
		when others => 
			min_ones_lcd <= "00101101"; -- Default (error state)
	end case;
end process display_min_ones;

-- Display output 
display_min_tens  : process (min_tens)
begin
	case min_tens is
		when "0000" => 
			min_tens_lcd <= "00110000"; -- Displays 0
		when "0001" => 
			min_tens_lcd <= "00110001"; -- Displays 1
		when "0010" => 
			min_tens_lcd <= "00110010"; -- Displays 2
		when "0011" => 
			min_tens_lcd <= "00110011"; -- Displays 3
		when "0100" => 
			min_tens_lcd <= "00110100"; -- Displays 4
		when "0101" => 
			min_tens_lcd <= "00110101"; -- Displays 5
		when "0110" => 
			min_tens_lcd <= "00110110"; -- Displays 6
		when others => 
			min_tens_lcd <= "00101101"; -- Default (error state)
	end case;
end process display_min_tens;


-- Display output 
display_h_ones  : process (h_ones)
begin
	case h_ones is
		when "0000" => 
			h_ones_lcd <= "00110000"; -- Displays 0
		when "0001" => 
			h_ones_lcd <= "00110001"; -- Displays 1
		when "0010" => 
			h_ones_lcd <= "00110010"; -- Displays 2
		when "0011" => 
			h_ones_lcd <= "00110011"; -- Displays 3
		when "0100" => 
			h_ones_lcd <= "00110100"; -- Displays 4
		when "0101" => 
			h_ones_lcd <= "00110101"; -- Displays 5
		when "0110" => 
			h_ones_lcd <= "00110110"; -- Displays 6
		when "0111" => 
			h_ones_lcd <= "00110111"; -- Displays 7
		when "1000" =>
			h_ones_lcd <= "00111000"; -- Displays 8
		when "1001" => 
			h_ones_lcd <= "00111001"; -- Displays 9
		when others => 
			h_ones_lcd <= "00101101"; -- Default (error state)
	end case;
end process display_h_ones;

-- Display output 
display_h_tens  : process (h_tens)
begin
	case h_tens is
		when "0000" => 
			h_tens_lcd <= "00110000"; -- Displays 0
		when "0001" => 
			h_tens_lcd <= "00110001"; -- Displays 1
		when "0010" => 
			h_tens_lcd <= "00110010"; -- Displays 2
		when others => 
			h_tens_lcd <= "00101101"; -- Default (error state)
	end case;
end process display_h_tens;


-- ASCII Codes Table for Clock Display
-- | ASCII Code (Binary) | Comment                  |
-- |---------------------|--------------------------|
-- | `0011 0000`         | Digit 0                  |
-- | `0011 0001`         | Digit 1                  |
-- | `0011 0010`         | Digit 2                  |
-- | `0011 0011`         | Digit 3                  |
-- | `0011 0100`         | Digit 4                  |
-- | `0011 0101`         | Digit 5                  |
-- | `0011 0110`         | Digit 6                  |
-- | `0011 0111`         | Digit 7                  |
-- | `0011 1000`         | Digit 8                  |
-- | `0011 1001`         | Digit 9                  |
-- | `0011 1010`         | Colon                    |
-- | `0010 0000`         | Space (used for padding) | 

end architecture;
