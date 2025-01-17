library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity alarm_clock is
  port(
  clk               : in    std_logic;                    -- General
  reset             : in    std_logic;                    -- General
  seg               : out   std_logic_vector(7 downto 0); -- Keypad
  AN                : out   std_logic_vector(7 downto 0); -- Keypad
  row               : out   std_logic_vector(3 downto 0); -- Keypad
  col               : in    std_logic_vector(3 downto 0); -- Keypad
  led_sec			      : out	  std_logic_vector(5 downto 0); -- Binary LED counter 
	led_min			      : out   std_logic_vector(3 downto 0); -- Binary LED counter
	led_h	 			      : out   std_logic_vector(3 downto 0); -- Binary LED counter	
  alarm_set_led     : out   std_logic;                    -- Green LED indicating alarm is set
  alarm_active_led  : out   std_logic;                    -- Red LED indicating alarm is active
  speaker           : out   std_logic;                    -- Speaker indicating alarm is active
  lcd_db            : inout std_logic_vector(7 DOWNTO 0); -- LCD
  lcd_rs            : out   std_logic;                    -- LCD
  lcd_rw            : out   std_logic;                    -- LCD
  lcd_e             : out   std_logic                     -- LCD
  );
end entity;



architecture alarm_arch of alarm_clock is

  ----------------------------------------------------------------------------
  ---------- SIGNAL DECLARATIONS ----------
  ----------------------------------------------------------------------------
  -- Signals from the IC, used to activate the alarm
  signal ic_h_tens                : std_logic_vector(3 downto 0);
  signal ic_h_ones                : std_logic_vector(3 downto 0);   
  signal ic_m_tens                : std_logic_vector(3 downto 0); 
  signal ic_m_ones                : std_logic_vector(3 downto 0); 

  -- Signals from the keypad, used to activate alarm
  signal keypad_h_tens            : std_logic_vector(3 downto 0);
  signal keypad_h_ones            : std_logic_vector(3 downto 0);   
  signal keypad_m_tens            : std_logic_vector(3 downto 0); 
  signal keypad_m_ones            : std_logic_vector(3 downto 0); 

  -- Internal signals used for time comparison
  signal keypad_ctrl_internal     : std_logic_vector(15 downto 0);
  signal ic_ctrl_internal         : std_logic_vector(15 downto 0);

  -- Reads the LED flag from the keyboard module, indicates set alarm
  signal LED                      : std_logic;

  -- Signals used to read and write data to the LCD
  signal h_tens	                  : std_logic_vector(7 downto 0);	
  signal h_ones	                  : std_logic_vector(7 downto 0);	
  signal min_ones                 : std_logic_vector(7 downto 0);
  signal min_tens                 : std_logic_vector(7 downto 0);

 

  ----------------------------------------------------------------------------
  ---------- CONSTANT DECLARATIONS ----------
  ----------------------------------------------------------------------------
  -- Constants used to generat sound
  constant CLK_FREQ : integer := 50000000;
  constant SPK_FREQ : integer := 1000; -- Desired beep frequency in Hz (1kHz beep)
  -- Calculate the counter value for the specified beep frequency
  constant COUNTER_MAX : integer := CLK_FREQ / (2 * SPK_FREQ); -- Toggle the speaker at half the desired frequency

  -- Signals used for sound output
  signal counter : integer range 0 to COUNTER_MAX - 1 := 0;
  signal speaker_out : std_logic := '0'; -- Speaker signal

  ----------------------------------------------------------------------------
  ---------- COMPONENT DECLARATIONS ----------
  ----------------------------------------------------------------------------
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
    ic_m_ones     : out std_logic_vector(3 downto 0);
    h_tens_lcd		: out   std_logic_vector(7 downto 0);
    h_ones_lcd		: out 	std_logic_vector(7 downto 0);
    min_ones_lcd	: out 	std_logic_vector(7 downto 0);
    min_tens_lcd	: out 	std_logic_vector(7 downto 0)
    ); 
  end component;

  component keyboard is
    port(
      clk             : in  std_logic;
      reset           : in  std_logic;
      LED             : out std_logic;
      col             : in  std_logic_vector(3 downto 0);
      row             : out std_logic_vector(3 downto 0);
      seg             : out std_logic_vector(7 downto 0);
      AN              : out std_logic_vector(7 downto 0);
      keypad_h_tens   : out std_logic_vector(3 downto 0);
      keypad_h_ones   : out std_logic_vector(3 downto 0);
      keypad_m_tens   : out std_logic_vector(3 downto 0);
      keypad_m_ones   : out std_logic_vector(3 downto 0)  
      );
  end component;

  component lcd_init is
    port( 
      clk       : in    std_logic;
      reset     : in    std_logic;
      lcd_rs    : out   std_logic;
      lcd_rw    : out   std_logic;
      lcd_e     : out   std_logic;
      lcd_db    : inout std_logic_vector(7 DOWNTO 0);   
      hour_one  : in    std_logic_vector(7 downto 0);
      hour_tens : in    std_logic_vector(7 downto 0);
      min_one   : in    std_logic_vector(7 downto 0);
      min_tens  : in    std_logic_vector(7 downto 0)
      );
  end component;

  begin

  -- Assigns value to the internal signals, which are used to trigger the alarm
  keypad_ctrl_internal <= keypad_h_tens & keypad_h_ones & keypad_m_tens & keypad_m_ones;
  ic_ctrl_internal <= ic_h_tens & ic_h_ones & ic_m_tens & ic_m_ones;


  ----------------------------------------------------------------------------
  ---------- COMPONENT INSTANTIATIONS ----------  
  ----------------------------------------------------------------------------
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
      ic_m_ones => ic_m_ones,
      h_tens_lcd => h_tens,
      h_ones_lcd => h_ones,
      min_tens_lcd => min_tens,
      min_ones_lcd => min_ones
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
    );

    lcd_inst : lcd_init
    port map(
      clk => clk,
      reset => reset,
      lcd_rs => lcd_rs,
      lcd_rw => lcd_rw,
      lcd_e  => lcd_e,
      lcd_db => lcd_db,
      hour_one => h_ones, 
      hour_tens => h_tens,
      min_one  => min_ones,
      min_tens => min_tens
    );


  ----------------------------------------------------------------------------
  ---------- PROCESSES ----------  
  ----------------------------------------------------------------------------
  -- Process generating the beep sound
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

  -- Process triggering the alarm
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

