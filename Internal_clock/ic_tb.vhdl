library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_ic is
end entity;

architecture behavior of tb_ic is

  -- Component Declaration for the Unit Under Test (UUT)
  component ic is
    port(
      clk               : in      std_logic;
      reset             : in      std_logic;
      reset_lcd_flag    : in      std_logic;
      LED_activate      : in      std_logic;
      sec_ones          : in      std_logic_vector(3 downto 0);
      sec_tens          : in      std_logic_vector(3 downto 0);
      min_ones          : in      std_logic_vector(3 downto 0);
      min_tens          : in      std_logic_vector(3 downto 0);
      SEG               : out     std_logic_vector(7 downto 0);
      num               : out     std_logic_vector(3 downto 0);
      min_ones_lcd      : out     std_logic_vector(7 downto 0)
    );
  end component;

  -- Signals for connecting to the UUT
  signal clk           : std_logic := '0';
  signal reset         : std_logic := '0';
  signal reset_lcd_flag: std_logic := '0';
  signal LED_activate  : std_logic := '0';
  signal sec_ones      : std_logic_vector(3 downto 0) := "0000";
  signal sec_tens      : std_logic_vector(3 downto 0) := "0000";
  signal min_ones      : std_logic_vector(3 downto 0) := "0000";
  signal min_tens      : std_logic_vector(3 downto 0) := "0000";
  signal SEG           : std_logic_vector(7 downto 0);
  signal num           : std_logic_vector(3 downto 0);
  signal min_ones_lcd  : std_logic_vector(7 downto 0);

  -- Clock period definition
  constant clk_period : time := 10 ns;

begin

  -- Instantiate the Unit Under Test (UUT)
  uut: ic
    port map (
      clk           => clk,
      reset         => reset,
      reset_lcd_flag=> reset_lcd_flag,
      LED_activate  => LED_activate,
      sec_ones      => sec_ones,
      sec_tens      => sec_tens,
      min_ones      => min_ones,
      min_tens      => min_tens,
      SEG           => SEG,
      num           => num,
      min_ones_lcd  => min_ones_lcd
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

  -- Stimulus process
  stim_proc: process
  begin
    -- Initialize Inputs
    reset <= '1';
    reset_lcd_flag <= '0';
    LED_activate <= '0';
    sec_ones <= "0000";
    sec_tens <= "0000";
    min_ones <= "0000";
    min_tens <= "0000";
    wait for 20 ns;

    -- Apply reset
    reset <= '0';
    wait for 20 ns;
    reset <= '1';
    wait for 20 ns;

    -- Test case 1: Display seconds ones
    sec_ones <= "0001"; -- 1
    LED_activate <= '1';
    wait for 20 ns;

    -- Test case 2: Display seconds tens
    sec_tens <= "0010"; -- 2
    LED_activate <= '0';
    wait for 20 ns;

    -- Test case 3: Display minutes ones
    min_ones <= "0011"; -- 3
    LED_activate <= '1';
    wait for 20 ns;

    -- Test case 4: Display minutes tens
    min_tens <= "0100"; -- 4
    LED_activate <= '0';
    wait for 20 ns;

    -- Test case 5: Reset LCD flag
    reset_lcd_flag <= '1';
    wait for 20 ns;
    reset_lcd_flag <= '0';
    wait for 20 ns;

    -- Add more test cases as needed

    -- End simulation
    wait;
  end process;

end architecture;