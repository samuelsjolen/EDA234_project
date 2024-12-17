library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity keyboard is
  port (
    clk     : in  std_logic;
    reset   : in  std_logic;
    row     : out std_logic_vector(3 downto 0); -- Pin ja1 -> ja4
    col     : in  std_logic_vector(3 downto 0); -- Pin ja7 -> ja10
    seg     : out std_logic_vector(7 downto 0); -- Output on segment display
    AN      : out std_logic_vector(7 downto 0)  -- Decides which segment to output on
  );
end entity;

architecture keyboard_arch of keyboard is
  ---------- TYPE DECLARATIONS ----------
  ---------- SIGNAL DECLARATIONS ----------
  -- VARIOUS
  signal row_reg        : unsigned(3 downto 0);
  signal shifted_out    : std_logic;
  signal row_internal   : std_logic_vector(3 downto 0);
  signal col_reg        : std_logic_vector(3 downto 0);
  signal seg_buffer     : std_logic_vector(7 downto 0);
  signal slow_clk       : std_logic := '0';

  -- 7-SEG SIGNALS
  signal refresh        : Unsigned(18 downto 0); 
  signal LED_activate   : std_logic_vector(1 downto 0); 



begin


  -- Process used to generate a slow clock
process (clk)
  variable counter : integer := 0;
begin
    if reset = '0' then
        counter := 0;
        slow_clk <= '0';
    else
        if rising_edge(clk) then
            counter := counter + 1;
            if counter = 10000 then
                slow_clk <= not slow_clk;
                counter := 0;
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

LED_activate <= refresh(12) & refresh(13); 


 -- Handles seg output
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

-- Process used to scan between the rows
reg_proc : process (slow_clk)
begin
  if reset = '0' then
    seg <= (others => '0');
    row_internal <= (others => '1');
    row_reg <= "1110";
    shifted_out <= '1';
    col_reg <= (others => '1');
  elsif rising_edge(slow_clk) then
    seg <= seg_buffer;
    shifted_out <= row_reg(3); -- Save the last bit of row_reg
    row_reg <= row_reg(2 downto 0) & row_reg(3); -- Shift row_reg
    row_internal <= std_logic_vector(row_reg); -- Convert to std_logic_vector
    col_reg <= col;
  end if;
  row <= row_internal;
end process;

-- Process used to output correct number, depending on active row
input_proc : process (clk)
begin
  if rising_edge(clk) then
    if row_internal = "1110" then
        if col = "1110" then
            seg_buffer <= "11111001"; -- Displays 1 (0xF9)
          elsif col = "1101" then
            seg_buffer <= "10100100"; -- Displays 2 (0xA4)
          elsif col = "1011" then
            seg_buffer <= "10110000"; -- Displays 3 (0xB0)
          elsif col = "0111" then
            seg_buffer <= "10001000"; -- Displays A (0x88)
          else
            seg_buffer <= "11111111";
          end if;
        elsif row_internal = "1101" then
          if col = "1110" then
            seg_buffer <= "10011001"; -- Displays 4 (0x99)
          elsif col = "1101" then
            seg_buffer <= "10010010"; -- Displays 5 (0x92)
          elsif col = "1011" then
            seg_buffer <= "10000010"; -- Displays 6 (0x82)
          elsif col = "0111" then
            seg_buffer <= "10000011"; -- Displays B (0xF8)
          else
            seg_buffer <= "11111111";
          end if;
        elsif row_internal = "1011" then
          if col = "1110" then
            seg_buffer <= "11111000"; -- Displays 7 (0x83)
          elsif col = "1101" then
            seg_buffer <= "10000000"; -- Displays 8 (0x80)
          elsif col = "1011" then
            seg_buffer <= "10010000"; -- Displays 9 (0x90)
          elsif col = "0111" then
            seg_buffer <= "11000110"; -- Displays C (0x89)
          else
            seg_buffer <= "11111111";
          end if;
        elsif row_internal = "0111" then
            if col = "1110" then
              seg_buffer <= "01101101"; -- Displays * (0x83)
            elsif col = "1101" then
              seg_buffer <= "11000000"; -- Displays 0 (0x00)
            elsif col = "1011" then
              seg_buffer <= "01011011"; -- Displays # (0x90)
            elsif col = "0111" then
              seg_buffer <= "10100001"; -- Displays d (0x89)
            else
              seg_buffer <= "11111111";
          end if;
        end if;
    end if;
end process;

end architecture;