library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity keyboard_tb is
end entity;

architecture testbench of keyboard_tb is
  -- Component declaration
  component keyboard
    port (
      clk   : in  std_logic;
      resetn: in  std_logic;
      row   : in  std_logic_vector(3 downto 0);
      col   : in  std_logic_vector(3 downto 0);
      seg   : out std_logic_vector(7 downto 0);
      AN    : out std_logic_vector(7 downto 0)
    );
  end component;

  -- Testbench signals
  signal clk   : std_logic := '0';
  signal resetn: std_logic := '1';
  signal row   : std_logic_vector(3 downto 0) := (others => '0');
  signal col   : std_logic_vector(3 downto 0) := (others => '0');
  signal seg   : std_logic_vector(7 downto 0);
  signal AN    : std_logic_vector(7 downto 0);

  -- Clock period constant
  constant clk_period : time := 10 ns;

  -- Function to convert std_logic_vector to string
  function to_string(slv: std_logic_vector) return string is
    variable result: string(1 to slv'length);
  begin
    for i in slv'range loop
      if slv(i) = '0' then
        result(i - slv'low + 1) := '0';
      else
        result(i - slv'low + 1) := '1';
      end if;
    end loop;
    return result;
  end function;

begin
  -- Instantiate the keyboard component
  uut: keyboard
    port map (
      clk   => clk,
      resetn => resetn,
      row   => row,
      col   => col,
      seg   => seg,
      AN    => AN
    );

  -- Clock generation process
  clk_process : process
  begin
    clk <= '0';
    wait for clk_period / 2;
    clk <= '1';
    wait for clk_period / 2;
  end process;

  -- Test process
  stim_proc : process
  begin
    -- Test case 1: Reset condition
    resetn <= '0';
    wait for clk_period;
    resetn <= '1';

    -- Test each row and column combination
    for r in 0 to 3 loop
      for c in 0 to 3 loop
        row <= std_logic_vector(to_unsigned(2**r, 4)); -- Set one row active
        col <= std_logic_vector(to_unsigned(2**c, 4)); -- Set one column active
        wait for clk_period * 2;

        -- Report the results
        report "Testing row: " & integer'image(r) & ", col: " & integer'image(c) & 
               ", seg: " & to_string(seg) severity note;
      end loop;
    end loop;

    -- Test invalid state
    row <= "0000"; -- No row active
    col <= "0000"; -- No column active
    wait for clk_period * 2;

    report "Testbench completed" severity note;
    wait;
  end process;
end architecture;
