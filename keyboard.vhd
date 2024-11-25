library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity keyboard is
  port (
    clk   : in  std_logic;
    resetn: in  std_logic;
    key   : in  STD_LOGIC_VECTOR(7 downto 0); 
                                              -- X1 -> X4 = pin 1 -> pin 4
                                              -- Y1 -> Y4 = pin 7 -> pin 10
    seg   : out STD_LOGIC_VECTOR(7 downto 0):= (others => '0');
    AN    : out STD_LOGIC_VECTOR(7 downto 0):= (others => '0')
  );
end entity;

architecture keyboard_arch of keyboard is

signal key_sig    : std_logic_vector(7 downto 0);
signal seg_buffer : std_logic_vector(7 downto 0) := "10111111";
-- signal an_sig   : std_logic_vector(7 downto 0);
signal rst_sig  : std_logic;




begin
  rst_sig <= not resetn;
  AN <= "11111110"; -- Activates AN0

-- Meant to change the value of key_sig when a physical key is pressed
  key_input_proc : process (clk)
  begin
      if rst_sig = '1' then
        key_sig <= (others => '0');
      else
        key_sig <= key;
      end if;
  end process;


 
  
-- Meant to change the segment output when a key is pressed
  key_output_proc : process (clk)
  begin
    if rst_sig = '1' then
    seg <= "00000000"; -- Displays 0 
    else
      case key_sig is
        when "00000000" => seg <= seg_buffer;
        when "00010001" => seg <= "11111001"; -- Displays 1 (0xF9)
        when "00010010" => seg <= "10100100"; -- Displays 2 (0xA4)
        when "00011000" => seg <= "10001000"; -- Displays A (0x88)
        when "00100001" => seg <= "10011001"; -- Displays 4 (0x99)
        when "00010100" => seg <= "10110000"; -- Displays 3 (0xB0)
        when "00100010" => seg <= "10010010"; -- Displays 5 (0x92)
        when "00100100" => seg <= "10000010"; -- Displays 6 (0x82)
        when "00101000" => seg <= "10000011"; -- Displays b (0x83)
        when "01000001" => seg <= "11111000"; -- Displays 7 (0xF8)
        when "01000010" => seg <= "10000000"; -- Displays 8 (0x80)
        when "01000100" => seg <= "10010000"; -- Displays 9 (0x90)
        when "01001000" => seg <= "10001110"; -- Displays C (0x8E)
        when "10000001" => seg <= "10001110"; -- Displays F (0x8E)
        when "10000010" => seg <= "10100000"; -- Displays 0 (0xA0)
        when "10000100" => seg <= "10000110"; -- Displays E (0x86)
        when "10001000" => seg <= "11000001"; -- Displays d (0xC1)
        when others     => seg <= "10111111"; -- Error state (0xDF)
    end case;
    --seg_buffer <= seg;
  end if;
  end process;

end architecture;

