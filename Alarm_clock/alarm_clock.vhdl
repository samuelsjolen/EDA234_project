library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity alarm_clock is
  port(
  clk               : in    std_logic; -- General
  reset             : in    std_logic; -- General
  seg               : out   std_logic_vector(7 downto 0); -- Keypad
  AN                : out   std_logic_vector(7 downto 0); -- Keypad
  led_sec			      : out	  std_logic_vector(5 downto 0);
	led_min			      : out   std_logic_vector(3 downto 0);
	led_h	 			      : out   std_logic_vector(3 downto 0);	
  row               : out   std_logic_vector(3 downto 0); -- Keypad
  col               : in    std_logic_vector(3 downto 0); -- Keypad
  alarm_set_led     : out   std_logic;
  --LED               : out   std_logic;
  alarm_active_led  : out   std_logic;
  speaker           : out   std_logic

 -- seg_output        : out   std_logic_vector(7 downto 0); -- Testbench
 -- state             : out   std_logic_vector(3 downto 0); -- Testbench
 -- keypad_ctrl       : out   std_logic_vector(15 downto 0); -- Testbench
 -- ic_ctrl           : out   std_logic_vector(15 downto 0); -- Testbench
 -- keypad_h_tens_ctrl    : out   std_logic_vector(3 downto 0);-- Testbench
 -- keypad_h_ones_ctrl    : out   std_logic_vector(3 downto 0);-- Testbench
 -- keypad_m_tens_ctrl    : out   std_logic_vector(3 downto 0);-- Testbench
 -- keypad_m_ones_ctrl    : out   std_logic_vector(3 downto 0)-- Testbench
  );
end entity;



architecture alarm_arch of alarm_clock is

  ---------- SIGNAL DECLARATIONS ----------
signal ic_h_tens                : std_logic_vector(3 downto 0);
signal ic_h_ones                : std_logic_vector(3 downto 0);   
signal ic_m_tens                : std_logic_vector(3 downto 0); 
signal ic_m_ones                : std_logic_vector(3 downto 0); 
signal keypad_h_tens            : std_logic_vector(3 downto 0);
signal keypad_h_ones            : std_logic_vector(3 downto 0);   
signal keypad_m_tens            : std_logic_vector(3 downto 0); 
signal keypad_m_ones            : std_logic_vector(3 downto 0); 
signal keypad_ctrl_internal     : std_logic_vector(15 downto 0);
signal ic_ctrl_internal         : std_logic_vector(15 downto 0);
signal LED                      : std_logic;



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
        keypad_m_ones   : out std_logic_vector(3 downto 0)  
--        seg_output      : out std_logic_vector(7 downto 0); -- TB
--        state           : out std_logic_vector(3 downto 0)  -- TB
        );
      end component;


      ----- SPEAKER SIGNALS -----
      -- Constants
constant CLK_FREQ : integer := 50000000;
constant SPK_FREQ : integer := 1000; -- Desired beep frequency in Hz (1kHz beep)
-- Calculate the counter value for the specified beep frequency
constant COUNTER_MAX : integer := CLK_FREQ / (2 * SPK_FREQ); -- Toggle the speaker at half the desired frequency
-- Signals
signal counter : integer range 0 to COUNTER_MAX - 1 := 0;
signal speaker_out : std_logic := '0'; -- Speaker signal

  begin

    keypad_ctrl_internal <= keypad_h_tens & keypad_h_ones & keypad_m_tens & keypad_m_ones;
--    keypad_ctrl <= keypad_ctrl_internal; -- TB
    ic_ctrl_internal <= ic_h_tens & ic_h_ones & ic_m_tens & ic_m_ones;
--    ic_ctrl <= ic_ctrl_internal; -- TB

    
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
        keypad_m_ones => keypad_m_ones
        --seg_output => seg_output
        --state => state
      );


-- Process to generate the beep sound
beep_process : process(clk, reset)
begin
if reset = '0' then -- If reset is active
counter <= 0;
speaker_out <= '0'; -- Set speaker to low (no sound)
elsif rising_edge(clk) then
if counter = COUNTER_MAX - 1 then
counter <= 0;
speaker_out <= not speaker_out; -- Toggle speaker output
else
counter <= counter + 1;
end if;
end if;
end process beep_process;
-- Output the signal to the speaker


 alarm_process : process (clk)
  begin
    if LED = '1' then
      alarm_set_led <= LED;
      if keypad_ctrl_internal = ic_ctrl_internal then
        speaker <= speaker_out;
        alarm_active_led <= '1';
        alarm_set_led <= '0';
      else
        speaker <= '1';
        alarm_active_led <= '0';
      end if;
    else
      alarm_active_led <= '0';
    end if;
  end process;

end architecture;

