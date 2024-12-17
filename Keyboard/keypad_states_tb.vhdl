library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity keypad_states_tb is
end entity;


architecture arch of keypad_states_tb is

  component keyboard is
    port (
        clk     : in  std_logic;
        reset   : in  std_logic;
        col     : in  std_logic_vector(3 downto 0);
        row     : out std_logic_vector(3 downto 0);
        seg     : out std_logic_vector(7 downto 0);
        AN      : out std_logic_vector(7 downto 0);
        state   : out std_logic_vector(1 downto 0);
        sclk    : out std_logic
    );
end component;

---------- SIGNAL DECLARATIONS ----------

-- PORT SIGNALS
signal clk    : std_logic:= '0';
signal reset  : std_logic;
signal row    : std_logic_vector(3 downto 0);
signal col    : std_logic_vector(3 downto 0);
signal seg    : std_logic_vector(7 downto 0);
signal AN     : std_logic_vector(7 downto 0);
signal sclk   : std_logic;


constant clk_period : time := 10 ns;

begin

  keypad_inst : component keyboard
  port map (
  clk    => clk,
  reset => reset,
  row    => row,
  col    => col,
  seg    => seg,
  AN     => AN,

  sclk  => sclk
  );


  -- Clock generation
  clk_process: process
  begin
      while true loop
          clk <= '0';
          wait for clk_period / 2;
          clk <= '1';
          wait for clk_period / 2;
      end loop;
  end process;

  -- Verificatiojn process
   ver_proc : process 
   begin
    wait for 10*clk_period;
    reset <= '1';
    wait for 5*clk_period;
    reset <= '0';
    wait for 5*clk_period;
    wait;
   end process;
end architecture;