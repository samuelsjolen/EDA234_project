library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity keypad_states_tb is
end entity;


architecture arch of keypad_states_tb is

  component keyboard is
    port (
        clk             : in  std_logic;
        reset           : in  std_logic;
        col             : in  std_logic_vector(3 downto 0);
        row             : out std_logic_vector(3 downto 0);
        seg             : out std_logic_vector(7 downto 0);
        AN              : out std_logic_vector(7 downto 0);
        sclk            : out std_logic;
        row_reg_tb      : out unsigned(3 downto 0); -- Testbench
        state           : out std_logic_vector(3 downto 0); -- TB
        if_active       : out std_logic;
        an_lit_tb       : out std_logic;
        seg_h_tens_tb   : out std_logic_vector(7 downto 0); -- TB 
        seg_h_ones_tb   : out std_logic_vector(7 downto 0); -- TB
        seg_m_tens_tb   : out std_logic_vector(7 downto 0); -- TB
        seg_m_ones_tb   : out std_logic_vector(7 downto 0)  -- TB

    );
end component;

---------- SIGNAL DECLARATIONS ----------

-- PORT SIGNALS
signal clk              : std_logic:= '0';
signal reset            : std_logic;
signal row              : std_logic_vector(3 downto 0);
signal col              : std_logic_vector(3 downto 0);
signal seg              : std_logic_vector(7 downto 0);
signal AN               : std_logic_vector(7 downto 0);
signal sclk             : std_logic;
signal row_reg_tb       : unsigned(3 downto 0);
signal state            : std_logic_vector(3 downto 0);
signal if_active        : std_logic;
signal an_lit_tb        : std_logic;
signal seg_h_tens_tb    : std_logic_vector(7 downto 0);
signal seg_h_ones_tb    : std_logic_vector(7 downto 0);
signal seg_m_tens_tb    : std_logic_vector(7 downto 0);
signal seg_m_ones_tb    : std_logic_vector(7 downto 0);

constant clk_period : time := 10 ns;

begin

  keypad_inst : component keyboard
  port map (
  clk           => clk,
  reset         => reset,
  row           => row,
  col           => col,
  seg           => seg,
  AN            => AN,
  sclk          => sclk,
  row_reg_tb    => row_reg_tb,
  state         => state,
  if_active     => if_active,
  an_lit_tb     => an_lit_tb,
  seg_h_tens_tb => seg_h_tens_tb,
  seg_h_ones_tb => seg_h_ones_tb,
  seg_m_tens_tb => seg_m_tens_tb,
  seg_m_ones_tb => seg_m_ones_tb
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
    reset <= '0';
    wait for 500*clk_period;
    reset <= '1';
    wait for 1200*clk_period;
    wait until row = "1110";  -- Press A (Move to next state)
    col <= "0111";            -- Press A (Move to next state)
    wait for 50*clk_period;  
    wait until row = "1011";  -- Press 9 (Testing for error)
    col <= "1011";            -- Press 9 (Testing for error)
    wait for 500*clk_period; 
    wait until row = "1110";  -- Press 1 (Move to next state)
    col <= "1011";            -- Press 1 (Move to next state)
    wait for 50*clk_period;
    col <= "ZZZZ";
    wait until row = "1110";
    col <= "1101";
    wait for 50*clk_period;
    col <= "ZZZZ";
    wait;
   end process;

--  -- Case process
--  case_proc : process 
--  begin
--    case row is
--      when "1110" =>
--        col <= "0111";
--      when "" =>
--        col <= "ZZZZ";
--    end case;
--    wait for clk_period; -- Add wait statement to avoid infinite loop
--  end process; 
end architecture;