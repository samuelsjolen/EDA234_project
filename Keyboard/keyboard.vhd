library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity keyboard is
  port (
    clk    : in  std_logic;
    resetn : in  std_logic;
    row    : out std_logic_vector(3 downto 0); -- Pin 3 to 1
    col    : in  std_logic_vector(3 downto 0); -- Pin 7 to 4
    seg    : out std_logic_vector(7 downto 0); 
    AN     : out std_logic_vector(7 downto 0)
  );
end entity;

architecture keyboard_arch of keyboard is
  signal row_reg   : std_logic_vector(3 downto 0):="1110";
  signal col_reg   : std_logic_vector(3 downto 0);
  signal seg_buffer: std_logic_vector(7 downto 0);

begin

  AN <= "11111110"; 
input_proc : process (clk)
begin
    if rising_edge(clk) then
        for i in 0 to 3 loop 
            unsigned(row_reg);
            shift_left(row_reg);
            row <= std_logic_vector(row_reg(0 downto 3));
            if col = "1110" then
                seg_buffer <= "11111001"; -- Displays 1 (0xF9)
            elsif col = "1101" then
                seg_buffer <= "10100100"; -- Displays 2 (0xA4)
            elsif col = "1011" then
                seg_buffer <= "10110000"; -- Displays 3 (0xB0)
            elsif col = "0111" then
                seg_buffer <= "10001000"; -- Displays A (0x88)
            else
                seg_buffer <= (others => '0');
            end if; 
        end if;
    end loop; 
end process;



  reg_process : process(clk, resetn)
  begin 
    if resetn = '0' then 
      seg <= "11111111";
      row <= (others => '0');
      col_reg <= (others => '0');
    elsif rising_edge(clk) then
      seg <= seg_buffer;
      row <= "1110";
      col_reg <= col;
    end if;
        
  end process;
  

end architecture;
