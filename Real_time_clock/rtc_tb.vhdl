library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity rtc_tb is
end entity;

architecture rtc_tb_arch of rtc_tb is

  component rtc is 
    port(
      clk_tb        : in      std_logic;  -- Clock signal
      reset_tb      : in      std_logic;  -- 
      data_trans_tb : inout   std_logic;  -- Pin 2 (Yellow)
      SCLK_tb       : out     std_logic;  -- Pin 1 (Green)
      CE_tb         : out     std_logic;  -- Pin 3 (CE)
    );
    end component;

  signal clk_tb         : STD_LOGIC;
  signal reset_tb       : std_logic;
  signal data_trans_tb  : std_logic;
  signal SCLK_tb        : std_logic;
  signal CE_tb          : std_logic;

  constant clk_period : time := 10 ns; -- 100 MHz

begin

rtc_inst: rtc
 port map(
    clk => clk_tb,
    reset => reset_tb,
    data_trans => data_trans_tb,
    SCLK => SCLK_tb,
    CE => CE_tb
);
  
clk_process: process
begin
    while true loop
        clk_tb <= '1';
        wait for clk_period / 2;
        clk_tb <= '0';
        wait for clk_period / 2;
    end loop;
end process;

ce_process: process
begin


end architecture;