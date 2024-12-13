library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity alarm_clock is
  port(
  clk         : in std_logic;
  reset       : in  std_logc;
  SEG         : out std_logic_vector(7 downto 0); -- IC
  AN          : out std_logic_vector(7 downto 0); -- IC
  lcd_db      : inout std_logic_vector(7 DOWNTO 0)  -- LCD
  lcd_rs      : out std_logic; -- LCD
  lcd_rw      : out std_logic; -- LCD
  lcd_e       : out std_logic; -- LCD
  );
end entity;



architecture wrapper_arch of alarm_clock is

  ---------- COMPONENT DECLARATIONS ----------
  component ic
    clk           : in    std_logic;
    reset         : in    std_logic; 
    reset_lcd		  : out		std_logic; -- Reset to update the LCD every clock cycle
    SEG           : out   std_logic_vector(7 downto 0);
    AN            : out   std_logic_vector(7 downto 0);
    h_tens_lcd		: out   std_logic_vector(7 downto 0);
    h_ones_lcd		:	out 	std_logic_vector(7 downto 0);
    min_ones_lcd	:	out 	std_logic_vector(7 downto 0);
    min_tens_lcd	:	out 	std_logic_vector(7 downto 0)
  end component:

    component lcd_init
      clk       : IN  std_logic;                 -- 100 MHz clock
      reset     : IN  std_logic;                 -- Active-low reset
      lcd_rs    : OUT std_logic;                 -- Register select
      lcd_rw    : OUT std_logic;                 -- Read/write
      lcd_e     : OUT std_logic;                 -- Enable
      lcd_db    : INOUT std_logic_vector(7 DOWNTO 0);  -- Data bus
      hour_one  : in std_logic_vector(7 downto 0);
      hour_tens : in std_logic_vector(7 downto 0);
      min_one   : in std_logic_vector(7 downto 0);
      min_tens  : in std_logic_vector(7 downto 0);
    end component;

    ---------- SIGNAL DECLARATIONS ----------
    signal reset_lcd : std_logic;

  begin
    
    ic_inst : ic
      port map(
        clk => clk,
        reset => reset,
        SEG => SEG,
        AN => AN,
        reset_lcd => reset_lcd,
        

      );

    lcd_inst : lcd_init
      port map(
        clk => clk,
        reset_lcd => reset,

        

      )

end architecture;

