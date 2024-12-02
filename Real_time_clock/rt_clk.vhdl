-- Left side
-- VCC2 Primary voltage source (red)
--
-- GND (black)


-- Right side
-- I/O (blue)
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity rtc is
  port(
    -- power out : std_logic;
    
    input : in  std_logic_vector(7 downto 0) -- Pin 2
    sclk  : out std_logic;  -- Pin 1
    ce    : out std_logic;  -- Pin 3

  );



  architecture rtc_arch of rtc is
  
  begin
  
    
  
  end architecture;