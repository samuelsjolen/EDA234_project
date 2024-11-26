library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity keyboard_tb is
-- Testbench has no ports
end entity;

architecture behavior of keyboard_tb is
    -- Component declaration for the unit under test (UUT)
    component keyboard is
        port (
            clk    : in  std_logic;
            resetn : in  std_logic;
            row    : out std_logic_vector(3 downto 0);
            col    : in  std_logic_vector(3 downto 0);
            seg    : out std_logic_vector(7 downto 0);
            AN     : out std_logic_vector(7 downto 0)
        );
    end component;

    -- Signals to connect to the UUT
    signal clk_tb    : std_logic := '0';
    signal resetn_tb : std_logic := '1';
    signal row_tb    : std_logic_vector(3 downto 0);
    signal col_tb    : std_logic_vector(3 downto 0) := (others => '1');
    signal seg_tb    : std_logic_vector(7 downto 0);
    signal AN_tb     : std_logic_vector(7 downto 0);

    -- Clock period definition
    constant clk_period : time := 10 ns;

begin
    -- Instantiate the Unit Under Test (UUT)
    uut: keyboard
        port map (
            clk    => clk_tb,
            resetn => resetn_tb,
            row    => row_tb,
            col    => col_tb,
            seg    => seg_tb,
            AN     => AN_tb
        );

    -- Clock generation
    clk_process: process
    begin
        while true loop
            clk_tb <= '0';
            wait for clk_period / 2;
            clk_tb <= '1';
            wait for clk_period / 2;
        end loop;
    end process;

    -- Stimulus process
    stim_process: process
    begin
        -- Initialize inputs
        resetn_tb <= '0';
        wait for 20 ns;
        resetn_tb <= '1';

        -- Test input sequence for col values
        -- Expect to display "1" (0xF9) when col = "1110"
        col_tb <= "1110";
        wait for 2*clk_period;

        -- Expect to display "2" (0xA4) when col = "1101"
        col_tb <= "1101";
        wait for 2*clk_period;

        -- Expect to display "3" (0xB0) when col = "1011"
        col_tb <= "1011";
        wait for 2*clk_period;

        -- Expect to display "A" (0x88) when col = "0111"
        col_tb <= "0111";
        wait for 2*clk_period;

        -- Reset col to default state and observe behavior
        col_tb <= (others => '1');
        wait for 2*clk_period;

        -- Finish simulation
        wait;
    end process;
end architecture;