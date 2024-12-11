library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity rtc_tb is
end entity;

architecture rtc_tb_arch of rtc_tb is


  component rtc is 
    port(
      clk               : in      std_logic;  -- Clock signal
      reset             : in      std_logic;  -- Reset
      data_trans        : inout   std_logic;  -- Pin 2 (Yellow)
      sclk              : out     std_logic;  -- Pin 1 (Green)
      ce                : out     std_logic;  -- Pin 3 (CE)
      init_byte_ver     : out     std_logic_vector(7 downto 0); -- VERIFICATION
      state             : out     std_logic_vector(2 downto 0); -- VERIFICATION
      data_recieved_ver : out     std_logic_vector(7 downto 0); -- VERIFICATION
      transmitted_ver   : out     std_logic;  -- VERIFICATION
      recieved_ver      : out     std_logic   -- VERIFICATION
    );
    end component;

  signal clk                : std_logic;
  signal reset              : std_logic;
  signal sclk               : std_logic;
  signal ce                 : std_logic;
  signal ce_internal        : std_logic;
  signal data_trans         : std_logic;
  signal init_byte_ver      : std_logic_vector(7 downto 0);
  signal data_to_tb         : std_logic_vector(7 downto 0);
  signal data_from_tb       : std_logic_vector(7 downto 0);
  signal state              : std_logic_vector(2 downto 0);
  signal data_recieved_ver  : std_logic_vector(7 downto 0);
  signal recieved_ver       : std_logic; -- Flag turns '1' when message fully recieved
  signal transmitted_ver    : std_logic; -- Flag turns '1' when message fully transmitted



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
    state => state,
    data_recieved_ver => data_recieved_ver,
    transmitted_ver => transmitted_ver,
    recieved_ver => recieved_ver
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
  wait for 100*clk_period;
  reset <= '0';
  wait for 200*clk_period;
  reset <= '1';
  wait;
end process;

ver_proc : process (sclk, reset, ce)
begin
    if ce = '1' then
      data_to_tb <= data_trans & data_to_tb(7 downto 1);
    end if;  
end process;




out_proc : process (reset, sclk, ce)
  variable counter : integer :=0;
begin
  if reset = '0' then
    data_from_tb <= "10101010";
    counter := 0;
  else
    if ce = '0' then
      counter := 0;
      data_trans <= 'Z';
    elsif ce = '1' then
      counter := counter + 1;
      if state = "011" then
        data_trans <= data_from_tb(0);
        data_from_tb <= '0' & data_from_tb(7 downto 1);
      elsif state = "010" then 
        data_trans <= 'Z';
      end if;
    end if;
  end if;
end process;  
end architecture;