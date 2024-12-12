library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity ic is
    Port ( 
        SEG        : out STD_LOGIC_VECTOR (7 downto 0);
        AN         : out STD_LOGIC_VECTOR (7 downto 0);
        clk        : in STD_LOGIC;
        reset      : in STD_LOGIC
        -- Decad_db : out std_logic_vector(3 downto 0);     -- Used for debugging
	    -- tio_pot_db : out std_logic_vector(3 downto 0));  -- Used for debugging
    );
end counter;

architecture behavioral of counter is

-- Internal signals
signal sec_clk_enable : STD_LOGIC := '0'; -- Enable signal instead of using derived clock
signal LED_activate   : STD_LOGIC; 
signal refresh        : Unsigned(18 downto 0); 
signal counter_sec    : integer := 0;
signal reset          : STD_LOGIC;
signal num            : unsigned(3 downto 0);   
signal Decad          : unsigned(3 downto 0);
signal tio_pot        : unsigned(3 downto 0);

begin

-- Reset logic, inverted on board

-- Counter 
sec_counter : process (clk, reset)
begin
	if rising_edge(clk) then 
		if reset = '1' then
			counter_sec <= 0;
			sec_clk_enable <= '0';
		else
			if counter_sec = 25000000 then  -- Adjust based on input clock frequency
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
		if reset = '1' then
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
		if reset = '1' then 
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
DcadCnt : process (clk, reset)
begin
	if rising_edge(clk) then
		if reset = '1' then
			Decad <= (others => '0');
			tio_pot <= (others => '0');
		elsif sec_clk_enable = '1' then
			Decad <= Decad + 1;
			if Decad = "1001" then  -- If Decad reaches 9
				Decad <= (others => '0');
				tio_pot <= tio_pot + 1;
				if tio_pot = "0101" then  -- If tio_pot reaches 5
					tio_pot <= (others => '0');
				end if;
			end if;
		end if;
	end if;
end process;

-- Multiplexer deciding which digit to send, depending on which segment is lit
MUX : process (Decad, tio_pot, LED_activate)
begin
	if LED_activate = '1' then
		num <= Decad; 
	else
		num <= tio_pot;
	end if; 
end process; 

-- Display output 
display_output_proc : process (num)
begin
	case num is
		when "0000" => SEG <= "11000000"; -- Displays 0
		when "0001" => SEG <= "11111001"; -- Displays 1
		when "0010" => SEG <= "10100100"; -- Displays 2
		when "0011" => SEG <= "10110000"; -- Displays 3
		when "0100" => SEG <= "10011001"; -- Displays 4
		when "0101" => SEG <= "10010010"; -- Displays 5
		when "0110" => SEG <= "10000010"; -- Displays 6
		when "0111" => SEG <= "11111000"; -- Displays 7
		when "1000" => SEG <= "10000000"; -- Displays 8
		when "1001" => SEG <= "10010000"; -- Displays 9
		when others => SEG <= "11111101"; -- Default (error state)
	end case;
end process display_output_proc;

end behavioral;