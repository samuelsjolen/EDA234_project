library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity wrapper is
  port(
  clk         : in std_logic;
  reset       : in  std_logc;
  row         : out std_logic_vector(3 downto 0); -- Keypad
  col         : in  std_logic_vector(3 downto 0); -- Keypad
  seg         : out std_logic_vector(7 downto 0); -- Keypad
  AN          : out std_logic_vector(7 downto 0)  -- Keypad
  data_trans  : inout   std_logic;  -- RTC
  sclk        : out     std_logic;  -- RTC
  ce          : out     std_logic;  -- RTC
  );
end entity;



architecture wrapper_arch of wrapper is



end architecture;

