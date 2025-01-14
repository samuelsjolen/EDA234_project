library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity alarm_clock_tb is

end entity

architecture arch_tb of alarm_clock_tb is

  component alarm_clock is
    port(
      clk         : in    std_logic; -- General
      reset       : in    std_logic; -- General
      SEG         : out   std_logic_vector(7 downto 0);   -- IC
      AN          : out   std_logic_vector(7 downto 0)   -- IC
      row         : out std_logic_vector(3 downto 0); -- Keypad
      col         : in  std_logic_vector(3 downto 0); -- Keypad
      );
begin

  

end architecture;