LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY ic IS
    PORT (
        clk          : IN  std_logic;
        reset        : IN  std_logic;  -- aktiv låg
        
        -- 7-seg utgångar (om du fortfarande vill ha dem)
        SEG          : OUT std_logic_vector(7 DOWNTO 0);
        AN           : OUT std_logic_vector(7 DOWNTO 0);
        
        -- ASCII-utgångar till LCD
        h_tens_lcd   : OUT std_logic_vector(7 DOWNTO 0);
        h_ones_lcd   : OUT std_logic_vector(7 DOWNTO 0);
        min_tens_lcd : OUT std_logic_vector(7 DOWNTO 0);
        min_ones_lcd : OUT std_logic_vector(7 DOWNTO 0);
        
        -- NY signal: hög puls = "skriv nya HH:MM på LCD"
        update_lcd   : OUT std_logic
    );
END ic;

ARCHITECTURE ic_arch OF ic IS

    ----------------------------------------------------------------------------
    -- Signaler för klockräkning (timme, minut, sek).
    ----------------------------------------------------------------------------
    SIGNAL sec_clk_enable : STD_LOGIC := '0'; -- 1 Hz enable
    SIGNAL counter_sec    : INTEGER := 0;
    SIGNAL sec_ones       : unsigned(3 DOWNTO 0) := (others => '0');
    SIGNAL sec_tens       : unsigned(3 DOWNTO 0) := (others => '0');
    SIGNAL min_ones       : unsigned(3 DOWNTO 0) := (others => '0');
    SIGNAL min_tens       : unsigned(3 DOWNTO 0) := (others => '0');
    SIGNAL h_ones         : unsigned(3 DOWNTO 0) := (others => '0');
    SIGNAL h_tens         : unsigned(3 DOWNTO 0) := (others => '0');
    
    -- Intern signal för att trigga en LCD-uppdatering. Pulserar en klockcykel.
    SIGNAL update_lcd_int : std_logic := '0';
    ----------------------------------------------------------------------------

BEGIN
    
    ----------------------------------------------------------------------------
    -- Exponera update_lcd_int externt, men se till att den bara är hög i en cykel
    ----------------------------------------------------------------------------
    update_lcd <= update_lcd_int;

    ----------------------------------------------------------------------------
    -- 1 Hz enable (räknar upp till t.ex. 100000000 om clk = 100 MHz)
    ----------------------------------------------------------------------------
    sec_counter : PROCESS(clk, reset)
    BEGIN
        IF rising_edge(clk) THEN
            IF reset = '0' THEN
                counter_sec <= 0;
                sec_clk_enable <= '0';
            ELSE
                IF counter_sec = 100000000 - 1 THEN  
                    counter_sec <= 0;
                    sec_clk_enable <= '1';
                ELSE
                    counter_sec <= counter_sec + 1;
                    sec_clk_enable <= '0';
                END IF;
            END IF;
        END IF;
    END PROCESS;

    ----------------------------------------------------------------------------
    -- Räknar sekunder, minuter, timmar i BCD. Uppdaterar ASCII-signaler.
    -- Skickar också en puls på update_lcd_int varje gång vi förändrat HH:MM.
    ----------------------------------------------------------------------------
    clock_counters : PROCESS(clk, reset)
    BEGIN
        IF rising_edge(clk) THEN
            IF reset = '0' THEN
                sec_ones <= (OTHERS => '0');
                sec_tens <= (OTHERS => '0');
                min_ones <= (OTHERS => '0');
                min_tens <= (OTHERS => '0');
                h_ones   <= (OTHERS => '0');
                h_tens   <= (OTHERS => '0');
                update_lcd_int <= '0';
                
            ELSIF sec_clk_enable = '1' THEN
                -- Nollställ update_lcd_int först:
                update_lcd_int <= '0';
                
                -- Räkna sekunder
                sec_ones <= sec_ones + 1;
                IF sec_ones = "1001" THEN  -- 9
                    sec_ones <= (OTHERS => '0');
                    sec_tens <= sec_tens + 1;
                    
                    IF sec_tens = "0101" THEN -- 5 => sek = 59 -> nollställ + +minut
                        sec_tens <= (OTHERS => '0');
                        min_ones <= min_ones + 1;
                        
                        IF min_ones = "1001" THEN -- 9
                            min_ones <= (OTHERS => '0');
                            min_tens <= min_tens + 1;
                            
                            IF min_tens = "0101" THEN -- 5 => minut = 59 -> +timme
                                min_tens <= (OTHERS => '0');
                                h_ones   <= h_ones + 1;
                                
                                IF h_ones = "1001" THEN  -- 9 => -> 0, + h_tens
                                    h_ones <= (OTHERS => '0');
                                    h_tens <= h_tens + 1;
                                    
                                    -- Beroende på om du vill 24h-format: 
                                    IF h_tens = "0010" AND h_ones = "0011" THEN
                                        -- 23:59 -> 00:00
                                        h_tens <= (OTHERS => '0');
                                        h_ones <= (OTHERS => '0');
                                    END IF;
                                END IF;
                            END IF;
                        END IF;
                        
                        -- Trigga en uppdatering av LCD **varje gång** minuten ändras:
                        update_lcd_int <= '1'; 
                        
                    END IF; -- sec_tens=5
                END IF; -- sec_ones=9
            END IF; -- rising_edge
        END IF;
    END PROCESS;

    ----------------------------------------------------------------------------
    -- Här kan du ha kvar logiken för 7-seg visning (om du vill).
    -- ex. processer som aktiverar AN0, AN1 etc.
    -- ...
    ----------------------------------------------------------------------------
    
    ----------------------------------------------------------------------------
    -- ASCII-omvandling för LCD (befintlig logik)
    ----------------------------------------------------------------------------
    display_min_ones : PROCESS(min_ones)
    BEGIN
        CASE min_ones IS
            WHEN "0000" =>  min_ones_lcd <= "00110000"; -- '0'
            WHEN "0001" =>  min_ones_lcd <= "00110001"; -- '1'
            WHEN "0010" =>  min_ones_lcd <= "00110010"; -- '2'
            WHEN "0011" =>  min_ones_lcd <= "00110011"; -- '3'
            WHEN "0100" =>  min_ones_lcd <= "00110100"; -- '4'
            WHEN "0101" =>  min_ones_lcd <= "00110101"; -- '5'
            WHEN "0110" =>  min_ones_lcd <= "00110110"; -- '6'
            WHEN "0111" =>  min_ones_lcd <= "00110111"; -- '7'
            WHEN "1000" =>  min_ones_lcd <= "00111000"; -- '8'
            WHEN "1001" =>  min_ones_lcd <= "00111001"; -- '9'
            WHEN OTHERS =>  min_ones_lcd <= "00100000"; -- ' ' (space eller valfri)
        END CASE;
    END PROCESS;

    display_min_tens : PROCESS(min_tens)
    BEGIN
        CASE min_tens IS
            WHEN "0000" =>  min_tens_lcd <= "00110000"; -- '0'
            WHEN "0001" =>  min_tens_lcd <= "00110001"; -- '1'
            WHEN "0010" =>  min_tens_lcd <= "00110010"; -- '2'
            WHEN "0011" =>  min_tens_lcd <= "00110011"; -- '3'
            WHEN "0100" =>  min_tens_lcd <= "00110100"; -- '4'
            WHEN "0101" =>  min_tens_lcd <= "00110101"; -- '5'
            WHEN OTHERS =>  min_tens_lcd <= "00100000"; -- ' '
        END CASE;
    END PROCESS;

    display_h_ones : PROCESS(h_ones)
    BEGIN
        CASE h_ones IS
            WHEN "0000" =>  h_ones_lcd <= "00110000"; -- '0'
            WHEN "0001" =>  h_ones_lcd <= "00110001"; -- '1'
            WHEN "0010" =>  h_ones_lcd <= "00110010"; -- '2'
            WHEN "0011" =>  h_ones_lcd <= "00110011"; -- '3'
            WHEN "0100" =>  h_ones_lcd <= "00110100"; -- '4'
            WHEN "0101" =>  h_ones_lcd <= "00110101"; -- '5'
            WHEN "0110" =>  h_ones_lcd <= "00110110"; -- '6'
            WHEN "0111" =>  h_ones_lcd <= "00110111"; -- '7'
            WHEN "1000" =>  h_ones_lcd <= "00111000"; -- '8'
            WHEN "1001" =>  h_ones_lcd <= "00111001"; -- '9'
            WHEN OTHERS =>  h_ones_lcd <= "00100000"; -- ' '
        END CASE;
    END PROCESS;

    display_h_tens : PROCESS(h_tens)
    BEGIN
        CASE h_tens IS
            WHEN "0000" =>  h_tens_lcd <= "00110000"; -- '0'
            WHEN "0001" =>  h_tens_lcd <= "00110001"; -- '1'
            WHEN "0010" =>  h_tens_lcd <= "00110010"; -- '2'
            WHEN "0011" =>  h_tens_lcd <= "00110011"; -- '3' (om man skulle köra 24h klocka förbi '2')
            WHEN OTHERS =>  h_tens_lcd <= "00100000"; -- ' '
        END CASE;
    END PROCESS;

END ARCHITECTURE;
