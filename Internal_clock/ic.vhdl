LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY ic IS
	PORT (
		clk : IN std_logic;
		reset : IN std_logic;
		SEG : OUT std_logic_vector(7 DOWNTO 0);
		AN : OUT std_logic_vector(7 DOWNTO 0);
	
		h_tens_lcd : OUT std_logic_vector(7 DOWNTO 0);
		h_ones_lcd : OUT std_logic_vector(7 DOWNTO 0);
		min_ones_lcd : OUT std_logic_vector(7 DOWNTO 0);
		min_tens_lcd : OUT std_logic_vector(7 DOWNTO 0)
	);
END ic;

ARCHITECTURE ic_arch OF ic IS

	-- Internal signals
	SIGNAL sec_clk_enable : STD_LOGIC := '0'; -- Enable signal instead of using derived clock
	SIGNAL LED_activate : STD_LOGIC;
	SIGNAL refresh : Unsigned(18 DOWNTO 0);
	SIGNAL counter_sec : INTEGER := 0;
	SIGNAL num : unsigned(3 DOWNTO 0); 
	SIGNAL sec_ones : unsigned(3 DOWNTO 0);
	SIGNAL sec_tens : unsigned(3 DOWNTO 0);
	SIGNAL min_ones : unsigned(3 DOWNTO 0);
	SIGNAL min_tens : unsigned(3 DOWNTO 0);
	SIGNAL h_ones : unsigned(3 DOWNTO 0);
	SIGNAL h_tens : unsigned(3 DOWNTO 0);
	
	

BEGIN
	

	-- Reset logic, inverted on board

	-- Counter
	sec_counter : PROCESS (clk, reset)
	BEGIN
		IF rising_edge(clk) THEN
			IF reset = '0' THEN
				counter_sec <= 0;
				sec_clk_enable <= '0';
			ELSE
				IF counter_sec = 100000000 THEN -- Adjust based on input clock frequency
					counter_sec <= 0;
					sec_clk_enable <= '1'; -- Trigger events that depend on 1-second intervals
				ELSE
					counter_sec <= counter_sec + 1;
					sec_clk_enable <= '0';
				END IF;
			END IF;
		END IF;
	END PROCESS;

	-- Process to create a toggling signal
	refresh_proc : PROCESS (clk, reset)
	BEGIN
		IF rising_edge(clk) THEN
			IF reset = '0' THEN
				refresh <= (OTHERS => '0');
			ELSE
				refresh <= refresh + 1;
			END IF;
		END IF;
	END PROCESS;

	LED_activate <= refresh(13); -- Change this division if display flickers

	-- Process to switch between AN1 and AN0
	an_proc : PROCESS (clk, reset, LED_activate)
	BEGIN
		IF rising_edge(clk) THEN
			IF reset = '0' THEN
				AN <= (OTHERS => '0');
			ELSE
				IF LED_activate = '1' THEN
					AN <= "11111110"; -- Activates AN0
				ELSE
					AN <= "11111101"; -- Activates AN1
				END IF;
			END IF;
		END IF;
	END PROCESS;

	-- Counter for displaying values
	clock_counters : PROCESS (clk, reset)
	BEGIN
		IF rising_edge(clk) THEN
			IF reset = '0' THEN
			
				sec_ones <= (OTHERS => '0');
				sec_tens <= (OTHERS => '0');
				min_ones <= (OTHERS => '0');
				min_tens <= (OTHERS => '0');
				h_ones <= (OTHERS => '0');
				h_tens <= (OTHERS => '0');
			ELSIF sec_clk_enable = '1' THEN
				sec_ones <= sec_ones + 1;
				IF sec_ones = "1001" THEN -- If sec_ones reaches 9
					sec_ones <= (OTHERS => '0');
					sec_tens <= sec_tens + 1;
					IF sec_tens = "0101" THEN -- If sec_tens reaches 5
						sec_tens <= (OTHERS => '0');
						min_ones <= min_ones + 1;
					
						
						IF min_ones = "1001" THEN -- If min_ones reaches 9
							min_ones <= (OTHERS => '0');
							min_tens <= min_tens + 1;
							IF min_tens = "0101" THEN -- If min_tens reaches 5
								min_tens <= (OTHERS => '0');
								h_ones <= h_ones + 1;
								IF h_ones = "1001" THEN -- If h_ones reaches 9
									h_ones <= (OTHERS => '0');
									h_tens <= h_tens + 1;
									IF h_tens = "0010" THEN -- If h_tens reaches 2
										h_tens <= (OTHERS => '0');
									END IF;
								END IF;
							END IF;
						END IF;
					END IF;
				END IF;
			END IF;
		END IF;
	END PROCESS;



	-- Multiplexer deciding which digit to send, depending on which segment is lit
	MUX : PROCESS (sec_ones, sec_tens, LED_activate)
	BEGIN
		IF LED_activate = '1' THEN
			num <= sec_ones;
		ELSE
			num <= sec_tens;
		END IF;
	END PROCESS;

	an_display_proc : PROCESS (num)
	BEGIN
		CASE num IS
			WHEN "0000" => 
				SEG <= "11000000"; -- Displays 0
			WHEN "0001" => 
				SEG <= "11111001"; -- Displays 1
			WHEN "0010" => 
				SEG <= "10100100"; -- Displays 2
			WHEN "0011" => 
				SEG <= "10110000"; -- Displays 3
			WHEN "0100" => 
				SEG <= "10011001"; -- Displays 4
			WHEN "0101" => 
				SEG <= "10010010"; -- Displays 5
			WHEN "0110" => 
				SEG <= "10000010"; -- Displays 6
			WHEN "0111" => 
				SEG <= "11111000"; -- Displays 7
			WHEN "1000" => 
				SEG <= "10000000"; -- Displays 8
			WHEN "1001" => 
				SEG <= "10010000"; -- Displays 9
			WHEN OTHERS => 
				SEG <= "11111101"; -- Default (error state)
		END CASE;
	END PROCESS;

	-- Display output
	display_min_ones : PROCESS (min_ones)
	BEGIN
		CASE min_ones IS
			WHEN "0000" => 
				min_ones_lcd <= "00110000"; -- Displays 0
			WHEN "0001" => 
				min_ones_lcd <= "00110001"; -- Displays 1
			WHEN "0010" => 
				min_ones_lcd <= "00110010"; -- Displays 2
			WHEN "0011" => 
				min_ones_lcd <= "00110011"; -- Displays 3
			WHEN "0100" => 
				min_ones_lcd <= "00110100"; -- Displays 4
			WHEN "0101" => 
				min_ones_lcd <= "00110101"; -- Displays 5
			WHEN "0110" => 
				min_ones_lcd <= "00110110"; -- Displays 6
			WHEN "0111" => 
				min_ones_lcd <= "00110111"; -- Displays 7
			WHEN "1000" => 
				min_ones_lcd <= "00111000"; -- Displays 8
			WHEN "1001" => 
				min_ones_lcd <= "00111001"; -- Displays 9
			WHEN OTHERS => 
				min_ones_lcd <= "00101101"; -- Default (error state)
		END CASE;
	END PROCESS display_min_ones;

	-- Display output
	display_min_tens : PROCESS (min_tens)
	BEGIN
		CASE min_tens IS
			WHEN "0000" => 
				min_tens_lcd <= "00110000"; -- Displays 0
			WHEN "0001" => 
				min_tens_lcd <= "00110001"; -- Displays 1
			WHEN "0010" => 
				min_tens_lcd <= "00110010"; -- Displays 2
			WHEN "0011" => 
				min_tens_lcd <= "00110011"; -- Displays 3
			WHEN "0100" => 
				min_tens_lcd <= "00110100"; -- Displays 4
			WHEN "0101" => 
				min_tens_lcd <= "00110101"; -- Displays 5
			WHEN "0110" => 
				min_tens_lcd <= "00110110"; -- Displays 6
			WHEN OTHERS => 
				min_tens_lcd <= "00101101"; -- Default (error state)
		END CASE;
	END PROCESS display_min_tens;
	-- Display output
	display_h_ones : PROCESS (h_ones)
	BEGIN
		CASE h_ones IS
			WHEN "0000" => 
				h_ones_lcd <= "00110000"; -- Displays 0
			WHEN "0001" => 
				h_ones_lcd <= "00110001"; -- Displays 1
			WHEN "0010" => 
				h_ones_lcd <= "00110010"; -- Displays 2
			WHEN "0011" => 
				h_ones_lcd <= "00110011"; -- Displays 3
			WHEN "0100" => 
				h_ones_lcd <= "00110100"; -- Displays 4
			WHEN "0101" => 
				h_ones_lcd <= "00110101"; -- Displays 5
			WHEN "0110" => 
				h_ones_lcd <= "00110110"; -- Displays 6
			WHEN "0111" => 
				h_ones_lcd <= "00110111"; -- Displays 7
			WHEN "1000" => 
				h_ones_lcd <= "00111000"; -- Displays 8
			WHEN "1001" => 
				h_ones_lcd <= "00111001"; -- Displays 9
			WHEN OTHERS => 
				h_ones_lcd <= "00101101"; -- Default (error state)
		END CASE;
	END PROCESS display_h_ones;

	-- Display output
	display_h_tens : PROCESS (h_tens)
	BEGIN
		CASE h_tens IS
			WHEN "0000" => 
				h_tens_lcd <= "00110000"; -- Displays 0
			WHEN "0001" => 
				h_tens_lcd <= "00110001"; -- Displays 1
			WHEN "0010" => 
				h_tens_lcd <= "00110010"; -- Displays 2
			WHEN OTHERS => 
				h_tens_lcd <= "00101101"; -- Default (error state)
		END CASE;
	END PROCESS display_h_tens;
	
	-- ASCII Codes Table for Clock Display
	-- | ASCII Code (Binary) | Comment |
	-- |---------------------|--------------------------|
	-- | `0011 0000` | Digit 0 |
	-- | `0011 0001` | Digit 1 |
	-- | `0011 0010` | Digit 2 |
	-- | `0011 0011` | Digit 3 |
	-- | `0011 0100` | Digit 4 |
	-- | `0011 0101` | Digit 5 |
	-- | `0011 0110` | Digit 6 |
	-- | `0011 0111` | Digit 7 |
	-- | `0011 1000` | Digit 8 |
	-- | `0011 1001` | Digit 9 |
	-- | `0011 1010` | Colon |
	-- | `0010 0000` | Space (used for padding) |

END ARCHITECTURE;
