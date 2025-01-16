library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity alarm_clock_tb is

end entity;

architecture arch_tb of alarm_clock_tb is

  component alarm_clock is
    port(
      clk                   : in    std_logic; -- General
      reset                 : in    std_logic; -- General
      seg                   : out   std_logic_vector(7 downto 0); -- Keypad
      AN                    : out   std_logic_vector(7 downto 0); -- Keypad
      LED                   : out   std_logic;
      led_sec			          : out	  std_logic_vector(5 downto 0);
      led_min			          : out   std_logic_vector(3 downto 0);
      led_h	 			          : out   std_logic_vector(3 downto 0);	
      row                   : out   std_logic_vector(3 downto 0); -- Keypad
      col                   : in    std_logic_vector(3 downto 0); -- Keypad
      
      speaker               : out   std_logic;
      alarm_led             : out   std_logic;
      seg_output            : out   std_logic_vector(7 downto 0);
      state                 : out   std_logic_vector(3 downto 0);
      keypad_ctrl           : out   std_logic_vector(15 downto 0);
      ic_ctrl               : out   std_logic_vector(15 downto 0);
      keypad_h_tens_ctrl    : out   std_logic_vector(3 downto 0);
      keypad_h_ones_ctrl    : out   std_logic_vector(3 downto 0);
      keypad_m_tens_ctrl    : out   std_logic_vector(3 downto 0);
      keypad_m_ones_ctrl    : out   std_logic_vector(3 downto 0)
      );
    end component;

      signal clk_tb                 : std_logic := '0';
      signal reset_tb               : std_logic := '1';
      signal row_tb                 : std_logic_vector(3 downto 0);
      signal col_tb                 : std_logic_vector(3 downto 0) := (others => '1');
      signal seg_tb                 : std_logic_vector(7 downto 0);
      signal AN_tb                  : std_logic_vector(7 downto 0);
      signal LED_tb                 : std_logic;
      signal led_sec_tb             : std_logic_vector(5 downto 0);
      signal led_min_tb             : std_logic_vector(3 downto 0);
      signal led_h_tb               : std_logic_vector(3 downto 0);
      signal speaker_tb             : std_logic;
      signal alarm_led_tb           : std_logic;
      signal seg_output_tb          : std_logic_vector(7 downto 0);
      signal state_tb               : std_logic_vector(3 downto 0);
      signal keypad_ctrl_tb         : std_logic_vector(15 downto 0);
      signal ic_ctrl_tb             : std_logic_vector(15 downto 0); 

          -- Clock period definition
    constant clk_period : time := 10 ns;

    function std_logic_vector_to_string(slv: std_logic_vector) return string is
      variable result: string(1 to slv'length);  -- Ensure string length matches slv
  begin
      for i in slv'range loop
          if slv(i) = '1' then
              result(i - slv'low + 1) := '1';  -- Map '1'
          else
              result(i - slv'low + 1) := '0';  -- Map all others to '0'
          end if;
      end loop;
      return result;
  end function;


begin

  alarm_inst : alarm_clock
  port map (
    clk         => clk_tb,
    reset       => reset_tb,
    row         => row_tb,
    col         => col_tb,
    seg         => seg_tb,
    AN          => AN_tb,
    LED         => LED_tb,
    led_sec     => led_sec_tb,
    led_min     => led_min_tb,
    led_h       => led_h_tb,
    speaker     => speaker_tb,
    alarm_led   => alarm_led_tb,
    seg_output  => seg_output_tb,
    state       => state_tb,
    keypad_ctrl => keypad_ctrl_tb,
    ic_ctrl     => ic_ctrl_tb
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
          reset_tb <= '0';
          wait for 20 ns;
          reset_tb <= '1';
          --for i in 0 to 2 loop
              wait for 20*clk_period;
          -- Test input sequence for col values



          -- Presses A to set alarm, DON'T TOUCH --
          wait until row_tb = "1110";
          col_tb <= "0111";
          wait for 5*clk_period;
          assert seg_output_tb = "10001000" report "Skriver ej A" severity warning;
          wait for 15*clk_period;
          col_tb <= "0000";



          ------------- Setting alarm -------------
          wait until row_tb = "0111";
          -- Presses 0
          col_tb <= "1101";
          wait for 15*clk_period;
          assert seg_output_tb = "11000000" report "Skriver ej 0 (1)" severity warning;
          col_tb <= "0000";

          
          -- Presses 0
          wait until row_tb = "0111";
          col_tb <= "1101";
          wait for 15*clk_period;
          assert seg_output_tb = "11000000" report "Skriver ej 0 (3)" severity warning;
          col_tb <= "0000";


          -- Presses 0
          wait until row_tb = "0111";
          col_tb <= "1101";
          wait for 15*clk_period;
          assert seg_output_tb = "11000000" report "Skriver ej 0 (3)" severity warning;
          col_tb <= "0000";

          -- Presses 7
          wait until row_tb = "1011";
          col_tb <= "1110";
          wait for 15*clk_period;
          assert seg_output_tb = "11111000" report "Skriver ej 7 (4)" severity warning;
          col_tb <= "0000";



          -- Presses B - DON'T TOUCH --
          wait until row_tb = "1101";
          col_tb <= "0111";
          wait for 15*clk_period;
          assert seg_output_tb = "10000011" report "Skriver ej B" severity warning;



          -- Reset col to default state and observe behavior
          col_tb <= (others => '1');
          wait until led_min_tb = "0111";
          wait for 10*clk_period;
          assert ic_ctrl_tb = keypad_ctrl_tb
          report "ic_ctrl_tb: " & std_logic_vector_to_string(ic_ctrl_tb) & 
                 " keypad_ctrl_tb: " & std_logic_vector_to_string(keypad_ctrl_tb)
          severity warning;
          report "ic_ctrl_tb: " & std_logic_vector_to_string(ic_ctrl_tb) & 
          " keypad_ctrl_tb: " & std_logic_vector_to_string(keypad_ctrl_tb);
          assert speaker_tb = '0'; report "Högtalare ej aktiverad" severity warning;
  
          -- Finish simulation
          wait;
      end process;
  

end architecture;