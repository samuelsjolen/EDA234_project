library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_ic is
end entity;

architecture behavior of tb_ic is

  -- Component Declaration for the Unit Under Test (UUT)
  component ic is
    port(
      clk         	: in  std_logic;
      reset       	: in  std_logic;
      led_sec				: out	std_logic_vector(5 downto 0);
      led_min				: out std_logic_vector(3 downto 0);
      led_h	 				: out std_logic_vector(3 downto 0);	
      ic_h_tens			: out std_logic_vector(7 downto 0);
      ic_h_ones			: out std_logic_vector(7 downto 0);
      ic_m_tens			: out std_logic_vector(7 downto 0);
      ic_m_ones			: out std_logic_vector(7 downto 0)
    );
  end component;

  -- Signals for connecting to the UUT
  signal clk           : std_logic := '0';
  signal reset         : std_logic := '0';
  signal led_sec    : std_logic(5 downto 0);   
  signal led_min    : std_logic(3 downto 0);   
  signal led_h      : std_logic(3 downto 0); 
  signal ic_h_tens  : std_logic(7 downto 0);     
  signal ic_h_ones  : std_logic(7 downto 0);     
  signal ic_m_tens  : std_logic(7 downto 0);    
  signal ic_m_ones  : std_logic(7 downto 0);     


  -- Clock period definition
  constant clk_period : time := 10 ns;

begin

  -- Instantiate the Unit Under Test (UUT)
  uut: ic
    port map (
      clk  => clk,
      reset => reset,
      led_sec => led_sec,
      led_min => led_min,      
      led_h => led_h,
      ic_h_tens => ic_h_tens,      
      ic_h_ones => ic_h_ones,
      ic_m_tens => ic_m_tens,      
      ic_m_ones => ic_m_ones  
    );

  -- Clock process definitions
  clk_process : process
  begin
    while true loop
      clk <= '0';
      wait for clk_period / 2;
      clk <= '1';
      wait for clk_period / 2;
    end loop;
  end process;


end architecture;