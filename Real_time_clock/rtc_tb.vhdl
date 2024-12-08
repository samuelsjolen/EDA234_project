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
      init_byte_ver   : out     std_logic_vector(7 downto 0);
      state       : out     std_logic_vector(2 downto 0)
    );
    end component;

  signal clk            : std_logic;
  signal reset          : std_logic;
  signal sclk           : std_logic;
  signal ce             : std_logic;
  signal ce_internal    : std_logic;
  signal data_trans     : std_logic;
  signal init_byte_ver  : std_logic_vector(7 downto 0);
  signal data_in        : std_logic_vector(7 downto 0):= "00000000";
  signal data_out       : std_logic_vector(7 downto 0);
  signal state          : std_logic_vector(2 downto 0);


  constant clk_period : time := 10 ns; -- 100 MHz

begin
  ce_internal <= ce;

rtc_inst: rtc
 port map(
    clk => clk,
    reset => reset,
    data_trans => data_trans,
    sclk => sclk,
    ce => ce,
    init_byte_ver => init_byte_ver,
    state => state
);
  
clk_process: process
begin
    while true loop
        clk <= '1';
        wait for 10*clk_period / 2;
        clk <= '0';
        wait for 10*clk_period / 2;
    end loop;
end process;

rst_process: process
begin
  reset <= '1';
  wait for 5*clk_period;
  reset <= '0';
  wait for 20*clk_period;
  reset <= '1';
  wait;
end process;

ver_proc : process (sclk, reset, ce)
begin
    if ce = '1' then
      data_in <= data_trans & data_in(7 downto 1);
    end if;  
end process;


out_proc : process (reset, sclk, ce)
  variable counter : integer :=0;
begin
  if reset = '0' then
    data_out <= "10110010";
    counter := 0;
  else
    if ce = '0' then
      counter := 0;
      data_trans <= 'Z';
    elsif ce = '1' then
      counter := counter + 1;
      if counter >= 7 then
        data_trans <= data_out(0);
        data_out <= '0' & data_out(7 downto 1);
      else 
        data_trans <= 'Z';
      end if;
    end if;
  end if;
end process;  
end architecture;