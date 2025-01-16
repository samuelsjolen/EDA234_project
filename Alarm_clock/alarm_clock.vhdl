library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity alarm_clock is
  port(
  clk               : in    std_logic; -- General
  reset             : in    std_logic; -- General
  seg               : out   std_logic_vector(7 downto 0); -- Keypad
  AN                : out   std_logic_vector(7 downto 0); -- Keypad
  LED               : out   std_logic;
  led_sec			      : out	  std_logic_vector(5 downto 0);
	led_min			      : out   std_logic_vector(3 downto 0);
	led_h	 			      : out   std_logic_vector(3 downto 0);	
  row               : out   std_logic_vector(3 downto 0); -- Keypad
  col               : in    std_logic_vector(3 downto 0); -- Keypad
  speaker           : out   std_logic:= '1';
  alarm_led         : out   std_logic:= '1';
  seg_output        : out   std_logic_vector(7 downto 0); -- Testbench
  state             : out   std_logic_vector(3 downto 0); -- Testbench
  keypad_ctrl       : out   std_logic_vector(15 downto 0); -- Testbench
  ic_ctrl           : out   std_logic_vector(15 downto 0); -- Testbench
  keypad_h_tens_ctrl    : out   std_logic_vector(3 downto 0);-- Testbench
  keypad_h_ones_ctrl    : out   std_logic_vector(3 downto 0);-- Testbench
  keypad_m_tens_ctrl    : out   std_logic_vector(3 downto 0);-- Testbench
  keypad_m_ones_ctrl    : out   std_logic_vector(3 downto 0)-- Testbench
  );
end entity;



architecture alarm_arch of alarm_clock is

  ---------- SIGNAL DECLARATIONS ----------
signal ic_h_tens      : std_logic_vector(3 downto 0);
signal ic_h_ones      : std_logic_vector(3 downto 0);   
signal ic_m_tens      : std_logic_vector(3 downto 0); 
signal ic_m_ones      : std_logic_vector(3 downto 0); 
signal keypad_h_tens  : std_logic_vector(3 downto 0);
signal keypad_h_ones  : std_logic_vector(3 downto 0);   
signal keypad_m_tens  : std_logic_vector(3 downto 0); 
signal keypad_m_ones  : std_logic_vector(3 downto 0); 
signal keypad_ctrl_internal    : std_logic_vector(15 downto 0);
signal ic_ctrl_internal        : std_logic_vector(15 downto 0);
  ---------- TYPE DECLARATIONS ----------


  ---------- COMPONENT DECLARATIONS ----------
  component ic is
    port (
    clk           : in  std_logic;
    reset         : in  std_logic;
    led_sec				: out	std_logic_vector(5 downto 0);
		led_min				: out std_logic_vector(3 downto 0);
		led_h	 				: out std_logic_vector(3 downto 0);	
    ic_h_tens     : out std_logic_vector(3 downto 0);
    ic_h_ones     : out std_logic_vector(3 downto 0);
    ic_m_tens     : out std_logic_vector(3 downto 0);
    ic_m_ones     : out std_logic_vector(3 downto 0));
    end component;

    component keyboard is
      port(
        clk             : in  std_logic;
        reset           : in  std_logic;
        col             : in  std_logic_vector(3 downto 0);
        row             : out std_logic_vector(3 downto 0);
        seg             : out std_logic_vector(7 downto 0);
        AN              : out std_logic_vector(7 downto 0);
        LED             : out std_logic;
        keypad_h_tens   : out std_logic_vector(3 downto 0);
        keypad_h_ones   : out std_logic_vector(3 downto 0);
        keypad_m_tens   : out std_logic_vector(3 downto 0);
        keypad_m_ones   : out std_logic_vector(3 downto 0);  
        seg_output      : out std_logic_vector(7 downto 0); -- TB
        state           : out std_logic_vector(3 downto 0)  -- TB
        );
      end component;

  begin

    keypad_ctrl_internal <= keypad_h_tens & keypad_h_ones & keypad_m_tens & keypad_m_ones;
    keypad_ctrl <= keypad_ctrl_internal; -- TB
    ic_ctrl_internal <= ic_h_tens & ic_h_ones & ic_m_tens & ic_m_ones;
    ic_ctrl <= ic_ctrl_internal; -- TB


    keypad_h_tens_ctrl <= keypad_h_tens;    
    keypad_h_ones_ctrl <= keypad_h_ones;
    keypad_m_tens_ctrl <= keypad_m_tens;
    keypad_m_ones_ctrl <= keypad_h_ones;
    
    ic_inst : ic
      port map(
        clk => clk,
        reset => reset,
        led_sec => led_sec,
        led_min => led_min,
        led_h => led_h,
        ic_h_tens => ic_h_tens,
        ic_h_ones => ic_h_ones,
        ic_m_tens => ic_m_tens,
        ic_m_ones => ic_m_ones
      );

    keyboard_inst : keyboard
      port map(
        clk => clk,
        reset => reset,
        row => row,
        col => col,
        seg => seg,
        AN => AN,
        LED => LED,
        keypad_h_tens => keypad_h_tens,
        keypad_h_ones => keypad_h_ones,
        keypad_m_tens => keypad_m_tens,
        keypad_m_ones => keypad_m_ones,
        seg_output => seg_output,
        state => state
      );


  alarm_process : process (clk)
  begin
    if keypad_ctrl_internal = ic_ctrl_internal then
      speaker <= '0';
      alarm_led <= '0';
    else
      speaker <= '1';
      alarm_led <= '1';
    end if;
  end process;

end architecture;

