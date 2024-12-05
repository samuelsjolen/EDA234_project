library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity rtc_tb is
end entity;

architecture rtc_tb_arch of rtc_tb is

  component rtc is 
    port(
      clk        : in      std_logic;  -- Clock signal
      reset      : in      std_logic;  -- 
      data_trans : inout   std_logic;  -- Pin 2 (Yellow)
      sclk       : out     std_logic;  -- Pin 1 (Green)
      ce         : out     std_logic;  -- Pin 3 (CE)
      init_byte_ver   : out     std_logic_vector(7 downto 0)
    );
    end component;

  signal clk_tb         : STD_LOGIC;
  signal reset_tb       : std_logic;
  signal data_trans_tb  : std_logic;
  signal SCLK_tb        : std_logic;
  signal CE_tb          : std_logic;
  signal init_byte_ver  : std_logic_vector(7 downto 0);
  signal ce_internal    : std_logic;
  signal recieved       : std_logic_vector(7 downto 0);


  constant clk_period : time := 1 ns; -- 100 MHz

begin
  ce_internal <= ce_tb

rtc_inst: rtc
 port map(
    clk => clk_tb,
    reset => reset_tb,
    data_trans => data_trans_tb,
    SCLK => SCLK_tb,
    CE => CE_tb,
    init_byte_ver => init_byte_ver
);
  
clk_process: process
begin
    while true loop
        clk_tb <= '1';
        wait for 10*clk_period / 2;
        clk_tb <= '0';
        wait for 10*clk_period / 2;
    end loop;
end process;

rst_process: process
begin
  reset_tb <= '1';
  wait for 5*clk_period;
  reset_tb <= '0';
  wait for 5*clk_period;
  reset_tb <= '1';
  wait for 100000*clk_period;
end process;

ver_proc : process (sclk, reset, ce_internal)
  signal shifted_out : std_logic;
begin
  if recieved = "10101010" then
    -- Transmit data here

    else
          
      if ce_internal = '1' then
        recieved <= data_trans_tb & recieved(6 downto 0);

  end if;
  
end process;

end architecture;