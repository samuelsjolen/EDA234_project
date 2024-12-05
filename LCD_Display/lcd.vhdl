library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity lcd is
  port (
    clk   : in    std_logic; -- Clock
    reset : in    std_logic; -- Inverted reset
    pb    : in    std_logic; -- 
    lcd_db: inout std_logic_vector(7 downto 0);
    lcd_e : out   std_logc; -- Enable, '1' start data signal
    lcd_rs: out   std_logic; -- Register select
    lcd_rw: out   std_logic; -- '1' read '0' write
    
  );
end entity;


architecture lcd_arch of lcd is

  signal lcd_rs_

begin

  

end architecture;