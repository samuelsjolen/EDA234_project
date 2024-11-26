library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity keyboard is
  port (
    clk    : in  std_logic;
    resetn : in  std_logic;
    row    : out std_logic_vector(3 downto 0); -- Pin ja1 -> ja4
    col    : in  std_logic_vector(3 downto 0); -- Pin ja7 -> ja10
    seg    : out std_logic_vector(7 downto 0); -- Output on segment display
    AN     : out std_logic_vector(7 downto 0)  -- Decides which segment to output on
  );
end entity;

architecture keyboard_arch of keyboard is
  signal row_reg        : unsigned(3 downto 0);
  signal shifted_out    : std_logic;
  signal row_internal   : std_logic_vector(3 downto 0);
  signal col_reg        : std_logic_vector(3 downto 0);
  signal seg_buffer     : std_logic_vector(7 downto 0);
  -- signal slow_clk       : std_logic := '0';

begin


reg_proc : process (clk)
begin
  if resetn = '0' then
    seg <= (others => '0');
    row_internal <= (others => '1');
    row_reg <= "1110";
    shifted_out <= '1';
    col_reg <= (others => '1');
    -- slow_clk <= '0';
  elsif rising_edge(clk) then
    seg <= seg_buffer;
    shifted_out <= row_reg(3);
    row_reg <= row_reg(2 downto 0) & row_reg(3);
    row_internal <= std_logic_vector(row_reg);
    col_reg <= col;
  end if;
  row <= row_internal;
end process;

AN <= "11111110";

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
        seg_buffer <= "10111111";
      end if;
    elsif row_internal = "1101" then
      if col = "1110" then
        seg_buffer <= "11111001"; -- Displays 1 (0xF9)
      elsif col = "1101" then
        seg_buffer <= "10100100"; -- Displays 2 (0xA4)
      elsif col = "1011" then
        seg_buffer <= "10110000"; -- Displays 3 (0xB0)
      elsif col = "0111" then
        seg_buffer <= "10001000"; -- Displays A (0x88)
      else
        seg_buffer <= "10111111";
      end if;
    elsif row_internal = "1011" then
      if col = "1110" then
        seg_buffer <= "11111001"; -- Displays 1 (0xF9)
      elsif col = "1101" then
        seg_buffer <= "10100100"; -- Displays 2 (0xA4)
      elsif col = "1011" then
        seg_buffer <= "10110000"; -- Displays 3 (0xB0)
      elsif col = "0111" then
        seg_buffer <= "10001000"; -- Displays A (0x88)
      else
        seg_buffer <= "10111111";
      end if;
    elsif row_internal = "0111" then
      if col = "1110" then
        seg_buffer <= "11111001"; -- Displays 1 (0xF9)
      elsif col = "1101" then
        seg_buffer <= "10100100"; -- Displays 2 (0xA4)
      elsif col = "1011" then
        seg_buffer <= "10110000"; -- Displays 3 (0xB0)
      elsif col = "0111" then
        seg_buffer <= "10001000"; -- Displays A (0x88)
      else
        seg_buffer <= "10111111";
      end if;
    end if;
  end if;
end process;

end architecture;