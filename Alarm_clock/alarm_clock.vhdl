library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity alarm_clock is
  port(
  clk         : in    std_logic; -- General
  reset       : in    std_logic; -- General
  SEG         : out   std_logic_vector(7 downto 0);   -- IC
  AN          : out   std_logic_vector(7 downto 0);   -- IC
  lcd_db      : inout std_logic_vector(7 DOWNTO 0);  -- LCD
  lcd_rs      : out   std_logic; -- LCD
  lcd_rw      : out   std_logic; -- LCD
  lcd_e       : out   std_logic -- LCD
  );
end entity;



architecture alarm_arch of alarm_clock is

  ---------- COMPONENT DECLARATIONS ----------
  component ic is
    port (clk       : in    std_logic;
    reset           : in    std_logic; 
  
    SEG             : out   std_logic_vector(7 downto 0);
    AN              : out   std_logic_vector(7 downto 0);
    h_tens_lcd		: out   std_logic_vector(7 downto 0);
    h_ones_lcd		: out 	std_logic_vector(7 downto 0);
    min_ones_lcd	: out 	std_logic_vector(7 downto 0);
    min_tens_lcd	: out 	std_logic_vector(7 downto 0));
  end component;

    component lcd_init is
     port( clk  : in    std_logic;                      -- 100 MHz clock
      reset     : in    std_logic;                      -- Active-low reset
      lcd_rs    : out   std_logic;                      -- Register select
      lcd_rw    : out   std_logic;                      -- Read/write
      lcd_e     : out   std_logic;                      -- Enable
      lcd_db    : inout std_logic_vector(7 DOWNTO 0);   -- Data bus
      hour_one  : in    std_logic_vector(7 downto 0);
      hour_tens : in    std_logic_vector(7 downto 0);
      min_one   : in    std_logic_vector(7 downto 0);
      min_tens  : in    std_logic_vector(7 downto 0));
    end component;

    ---------- SIGNAL DECLARATIONS ----------
    signal update_lcd : std_logic;
    signal h_tens	  : std_logic_vector(7 downto 0);	
    signal h_ones	  : std_logic_vector(7 downto 0);	
    signal min_ones   : std_logic_vector(7 downto 0);
    signal min_tens   : std_logic_vector(7 downto 0);


    ---------- TYPE DECLARATIONS ----------
    type states is(
      idle,           -- Only supposed to show time
      setting_alarm,  -- In the process of setting the alarm
      alarm_set,      -- An alarm is set, will notify at given time
      alarm_active    -- Alarm is active, speaker beeping
    );

  begin
    
    ic_inst : ic
      port map(
        clk => clk, 
        reset => reset,
        SEG => SEG,
        AN => AN,
        h_tens_lcd => h_tens,
        h_ones_lcd => h_ones,
        min_tens_lcd => min_tens,
        min_ones_lcd => min_ones
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

end architecture;
