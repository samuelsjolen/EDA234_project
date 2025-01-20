library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity keyboard is
  port (
    clk             : in  std_logic;
    reset           : in  std_logic;
    col             : in  std_logic_vector(3 downto 0); -- Pin ja7 -> ja10
    row             : out std_logic_vector(3 downto 0); -- Pin ja1 -> ja4
    seg             : out std_logic_vector(7 downto 0); -- Output on segment display
    AN              : out std_logic_vector(7 downto 0);--;  -- Decides which segment to output on
    LED             : out std_logic;
    keypad_h_tens   : out std_logic_vector(3 downto 0);
    keypad_h_ones   : out std_logic_vector(3 downto 0);
    keypad_m_tens   : out std_logic_vector(3 downto 0);
    keypad_m_ones   : out std_logic_vector(3 downto 0)
    );
end entity;

architecture keyboard_arch of keyboard is


  ----------------------------------------------------------------------------
  ---------- TYPE DECLARATIONS ----------
  ----------------------------------------------------------------------------

  type states is(
    idle,
    set_h_tens,
    set_h_ones,
    set_m_tens,
    set_m_ones,
    buffer_state,
    alarm_state
  );

  
  ----------------------------------------------------------------------------
  ---------- SIGNAL DECLARATIONS ----------
  ----------------------------------------------------------------------------

  -- VARIOUS
  signal row_reg        : unsigned(3 downto 0);
  signal shifted_out    : std_logic;
  signal row_internal   : std_logic_vector(3 downto 0);
  signal col_reg        : std_logic_vector(3 downto 0);
  signal seg_buffer     : std_logic_vector(7 downto 0);
  signal slow_clk       : std_logic := '0';

  -- 7-SEG SIGNALS
  signal an_lit         : std_logic;
  signal refresh        : Unsigned(18 downto 0); 
  signal LED_activate   : std_logic_vector(1 downto 0); 

  -- STATE SIGNALS
  signal current_state  : states:= idle;
  signal delay_state    : states;
  signal next_state     : states:= idle;

  -- Clock numbering
  signal seg_h_tens     : std_logic_vector(7 downto 0);
  signal seg_h_ones     : std_logic_vector(7 downto 0);
  signal seg_m_tens     : std_logic_vector(7 downto 0);
  signal seg_m_ones     : std_logic_vector(7 downto 0);

  signal val_h_tens     : unsigned(3 downto 0);  
  signal val_h_ones     : unsigned(3 downto 0);
  signal val_m_tens     : unsigned(3 downto 0);
  signal val_m_ones     : unsigned(3 downto 0);  

begin
row <= row_internal; -- Flyttade ur reg_proc


----------------------------------------------------------------------------
---------- PROCESSES ----------
----------------------------------------------------------------------------

  -- Process used to generate a slow clock
process (clk)
  variable counter : integer := 0;
begin
    if reset = '0' then
        counter := 0;
        slow_clk <= '0';
    else
        if rising_edge(clk) then
            counter := counter + 1;
            if counter = 100 then -- Hardware
                slow_clk <= not slow_clk;
                counter := 0;
            end if;
        end if;
    end if;
end process;

  -- Process to create a toggling signal
refresh_proc : process (clk, reset)
begin
	if rising_edge(clk) then
		if reset = '0' then
			refresh <= (others => '0');
		else
			refresh <= refresh + 1;
		end if;
	end if;
end process;

LED_activate <= refresh(12) & refresh(13); -- Hardware


 -- Handles seg output
an_proc : process (clk, reset, LED_activate)
begin
	if rising_edge(clk) then
		if reset = '0' then 
			AN <= (others => '0'); 
      seg <= (others => '0');
    else
     if an_lit = '1' then
        if LED_activate = "00" then 
          seg <= seg_m_ones;
          AN <= "11111110"; -- Activates AN0
        elsif LED_activate = "01" then 
          seg <= seg_m_tens;
          AN <= "11111101"; -- Activates AN1
        elsif LED_activate = "10" then
          seg <= seg_h_ones;
          AN <= "11111011"; -- Activates AN2
        else
          seg <= seg_h_tens;
          AN <= "11110111"; -- Activates AN3
        end if;
     else
        AN <= (others => '1'); 
		  end if;
		end if; 
	end if;
end process;

-- Process used to scan between the rows
reg_proc : process (slow_clk, reset)
begin
  if reset = '0' then
    --seg <= (others => '0');
    row_internal <= (others => '1');
    row_reg <= "1110";
    shifted_out <= '1';
    col_reg <= (others => '1');
  elsif rising_edge(slow_clk) then
    --seg <= seg_buffer;
    shifted_out <= row_reg(3); -- Save the last bit of row_reg
    row_reg <= row_reg(2 downto 0) & row_reg(3); -- Shift row_reg
    row_internal <= std_logic_vector(row_reg); -- Convert to std_logic_vector
    col_reg <= col;
  end if;
end process;

-- Process used to output correct number, depending on active row
input_proc : process (clk)
begin
  if rising_edge(clk) then
    if row_internal = "1110" then
        if col = "1110" then
            seg_buffer <= "11111001"; -- Displays 1 (0xF9)
          elsif col = "1101" then
            seg_buffer <= "10100100"; -- Displays 2 (0xA4)
          elsif col = "1011" then
            seg_buffer <= "10110000"; -- Displays 3 (0xB0)
          elsif col = "0111" then
            seg_buffer <= "10001000"; -- Displays A (0x88)
          else
            seg_buffer <= "11111111";
          end if;
        elsif row_internal = "1101" then
          if col = "1110" then
            seg_buffer <= "10011001"; -- Displays 4 (0x99)
          elsif col = "1101" then
            seg_buffer <= "10010010"; -- Displays 5 (0x92)
          elsif col = "1011" then
            seg_buffer <= "10000010"; -- Displays 6 (0x82)
          elsif col = "0111" then
            seg_buffer <= "10000011"; -- Displays B (0xF8)
          else
            seg_buffer <= "11111111";
          end if;
        elsif row_internal = "1011" then
          if col = "1110" then
            seg_buffer <= "11111000"; -- Displays 7 (0x83)
          elsif col = "1101" then
            seg_buffer <= "10000000"; -- Displays 8 (0x80)
          elsif col = "1011" then
            seg_buffer <= "10010000"; -- Displays 9 (0x90)
          elsif col = "0111" then
            seg_buffer <= "11000110"; -- Displays C (0x89)
          else
            seg_buffer <= "11111111";
          end if;
        elsif row_internal = "0111" then
            if col = "1110" then
              seg_buffer <= "01101101"; -- Displays * (0x83)
            elsif col = "1101" then
              seg_buffer <= "11000000"; -- Displays 0 (0x00)
            elsif col = "1011" then
              seg_buffer <= "01011011"; -- Displays # (0x90)
            elsif col = "0111" then
              seg_buffer <= "10100001"; -- Displays d (0x89)
            else
              seg_buffer <= "11111111";
          end if;
        end if;
    end if;
end process;

switch_state_proc : process (reset, next_state, clk)
begin
  if rising_edge(clk) then
    if reset = '0' then
      current_state <= idle;
    else 
      current_state <= next_state;
    end if;
  end if;
end process;



next_state_proc : process (reset,clk)
  variable counter_ht : integer := 0;
  variable counter_ho : integer := 0;
  variable counter_mt : integer := 0;
  variable counter_mo : integer := 0;
  variable counter_bs : integer := 0;
  variable counter_as : integer := 0;
begin
  if rising_edge(clk) then
    if reset = '0' then
      next_state <= idle;
    else
    case current_state is 
    -- STATE FOR IDLE --
    when idle =>
      an_lit <= '0';
      LED <= '0';
      seg_h_tens <= "10111111";         -- Resets every alarm value
      seg_h_ones <= "10111111";         -- Resets every alarm value
      seg_m_tens <= "10111111";         -- Resets every alarm value
      seg_m_ones <= "10111111";         -- Resets every alarm value
      keypad_h_tens <= "ZZZZ";          -- Don't want any output until alarm is set
      keypad_h_ones <= "ZZZZ";          -- Don't want any output until alarm is set
      keypad_m_tens <= "ZZZZ";          -- Don't want any output until alarm is set
      keypad_m_ones <= "ZZZZ";          -- Don't want any output until alarm is set
      counter_ht  := 0;                 -- Enables delay to avoid unintended press
      counter_ho  := 0;                 -- Enables delay to avoid unintended press
      counter_mt  := 0;                 -- Enables delay to avoid unintended press
      counter_mo  := 0;                 -- Enables delay to avoid unintended press
        if seg_buffer = "10001000" then -- If A is pressed
          next_state <= set_h_tens;
        end if;
        if seg_buffer = "10100001" then
          next_state <= idle;
        end if;

      -- STATE FOR SETTING HOUR FIRST DIGIT --
    when set_h_tens =>
      an_lit <= '1';
      if seg_buffer = "11111001" then     -- If 1 is pressed (0xF9)
        seg_h_tens <= "11111001";         -- Graphical representation for 7-seg display
        val_h_tens <= "0001";             -- Numerical value to compare with the time of the IC
        next_state <= set_h_ones;
      elsif seg_buffer = "10100100" then  -- If 2 is pressed (0xA4)
        seg_h_tens <= "10100100";         -- Graphical representation for 7-seg display
        val_h_tens <= "0010";             -- Numerical value to compare with the time of the IC
        next_state <= set_h_ones;
      elsif seg_buffer = "11000000" then  -- If 0 is pressed
        seg_h_tens <= "11000000";         -- Graphical representation for 7-seg display
        val_h_tens <= "0000";             -- Numerical value to compare with the time of the IC
        next_state <= set_h_ones;
      else
        seg_h_tens <= "10111111";
        seg_h_ones <= "10111111";
        seg_m_tens <= "10111111";
        seg_m_ones <= "10111111";
      end if;   

      -- STATE FOR SETTING HOUR SECOND DIGIT --
      when set_h_ones =>
      if counter_ho = 40000000 then           -- Delay to avoid unintended press
        an_lit <= '1';
        if seg_h_tens = "10100100" then       -- If tens = 2, then only 0-4 acceptable inputs
          if seg_buffer = "11111001" then     -- If 1 is pressed (0xF9)
            seg_h_ones <= "11111001";
            val_h_ones <= "0001";             -- Numerical value to compare with the time of the IC
            next_state <= set_m_tens;
            counter_ho := 0;
          elsif seg_buffer = "10100100" then  -- If 2 is pressed (0xA4)
            seg_h_ones <= "10100100"; 
            val_h_ones <= "0010";             -- Numerical value to compare with the time of the IC
            next_state <= set_m_tens;
            counter_ho := 0;
          elsif seg_buffer = "10110000" then  -- If 3 is pressed (0xB0)
            seg_h_ones <= "10110000"; 
            val_h_ones <= "0011";             -- Numerical value to compare with the time of the IC
            next_state <= set_m_tens;
            counter_ho := 0;
          elsif seg_buffer = "10011001" then  -- If 4 is pressed (0x99)
            seg_h_ones <= "10011001"; 
            val_h_ones <= "0100";             -- Numerical value to compare with the time of the IC
            next_state <= set_m_tens;
            counter_ho := 0;
          elsif seg_buffer = "11000000" then  -- If 0 is pressed (0xC0)
            seg_h_ones <= "11000000"; 
            val_h_ones <= "0000";             -- Numerical value to compare with the time of the IC
            next_state <= set_m_tens;
            counter_ho := 0;
          else 
            null;
          end if; 
        else
          if seg_buffer = "11111001" then     -- If 1 is pressed (0xF9)
            seg_h_ones <= "11111001";
            val_h_ones <= "0001";             -- Numerical value to compare with the time of the IC
            next_state <= set_m_tens;
            counter_ho := 0;
          elsif seg_buffer = "10100100" then  -- If 2 is pressed (0xA4)
            seg_h_ones <= "10100100"; 
            val_h_ones <= "0010";             -- Numerical value to compare with the time of the IC
            next_state <= set_m_tens;
            counter_ho := 0;
          elsif seg_buffer = "10110000" then  -- If 3 is pressed (0xB0)
            seg_h_ones <= "10110000"; 
            val_h_ones <= "0011";             -- Numerical value to compare with the time of the IC
            next_state <= set_m_tens;
            counter_ho := 0;
          elsif seg_buffer = "10011001" then  -- If 4 is pressed (0x99)
            seg_h_ones <= "10011001"; 
            val_h_ones <= "0100";             -- Numerical value to compare with the time of the IC
            next_state <= set_m_tens;
            counter_ho := 0;
          elsif seg_buffer = "11000000" then  -- If 0 is pressed (0xC0)
            seg_h_ones <= "11000000"; 
            val_h_ones <= "0000";             -- Numerical value to compare with the time of the IC
            next_state <= set_m_tens;
            counter_ho := 0;
          else 
            null;
          end if;  
        end if;
      else 
        counter_ho := counter_ho + 1;
      end if;


      -- STATE FOR SETTING MINUTES FIRST DIGIT --
      when set_m_tens =>
      if counter_mt = 40000000 then -- Hardware  -- Delay to avoid unintented press
        an_lit <= '1';
        if seg_buffer = "11111001" then     -- If 1 is pressed (0xF9)
          seg_m_tens <= "11111001";
          val_m_tens <= "0001";
          next_state <= set_m_ones;
          counter_mt := 0;
        elsif seg_buffer = "10100100" then  -- If 2 is pressed (0xA4)
          seg_m_tens <= "10100100"; 
          val_m_tens <= "0010";
          next_state <= set_m_ones;
          counter_mt := 0;
        elsif seg_buffer = "10110000" then  -- If 3 is pressed (0xA4)
          seg_m_tens <= "10110000"; 
          val_m_tens <= "0011";
          next_state <= set_m_ones;
          counter_mt := 0;
        elsif seg_buffer = "10011001" then  -- If 4 is pressed (0xA4)
          seg_m_tens <= "10011001"; 
          val_m_tens <= "0100";
          next_state <= set_m_ones;
          counter_mt := 0;
        elsif seg_buffer = "10010010" then  -- If 5 is pressed (0xA4)
          seg_m_tens <= "10010010"; 
          val_m_tens <= "0101";
          next_state <= set_m_ones;
          counter_mt := 0;
        elsif seg_buffer = "11000000" then  -- If 0 is pressed (0xA4)
          seg_m_tens <= "11000000"; 
          val_m_tens <= "0000";
          next_state <= set_m_ones;
          counter_mt := 0;
        else null;
        end if;  
      else 
        counter_mt := counter_mt + 1;
      end if;

      -- STATE FOR SETTING MINUTES SECOND DIGIT --
      when set_m_ones =>
      if counter_mo = 40000000 then -- Delay
        if seg_buffer = "11111001" then     -- If 1 is pressed (0xF9)
          seg_m_ones <= "11111001";
          val_m_ones <= "0001";
          next_state <= buffer_state;
          counter_mo := 0;
        elsif seg_buffer = "10100100" then  -- If 2 is pressed (0xA4)
          seg_m_ones <= "10100100"; 
          val_m_ones <= "0010";
          next_state <= buffer_state;
          counter_mo := 0;
        elsif seg_buffer = "10110000" then  -- If 3 is pressed (0xA4)
          seg_m_ones <= "10110000"; 
          val_m_ones <= "0011";
          next_state <= buffer_state;
          counter_mo := 0;
        elsif seg_buffer = "10011001" then  -- If 4 is pressed (0xA4)
          seg_m_ones <= "10011001"; 
          val_m_ones <= "0100";
          next_state <= buffer_state;
          counter_mo := 0;
        elsif seg_buffer = "10010010" then  -- If 5 is pressed (0xA4)
          seg_m_ones <= "10010010"; 
          val_m_ones <= "0101";
          next_state <= buffer_state;
          counter_mo := 0;
        elsif seg_buffer = "10000010" then  -- If 6 is pressed (0xA4)
          seg_m_ones <= "10000010"; 
          val_m_ones <= "0110";
          next_state <= buffer_state;
          counter_mo := 0;
        elsif seg_buffer = "11111000" then  -- If 7 is pressed (0xA4)
          seg_m_ones <= "11111000"; 
          val_m_ones <= "0111";
          next_state <= buffer_state;
          counter_mo := 0;
        elsif seg_buffer = "10000000" then  -- If 8 is pressed (0xA4)
          seg_m_ones <= "10000000"; 
          val_m_ones <= "1000";
          next_state <= buffer_state;
          counter_mo := 0;
        elsif seg_buffer = "10010000" then  -- If 9 is pressed (0xA4)
          seg_m_ones <= "10010000"; 
          next_state <= buffer_state;
          counter_mo := 0;
        elsif seg_buffer = "11000000" then  -- If 0 is pressed (0xA4)
          seg_m_ones <= "11000000"; 
          next_state <= buffer_state;
          counter_mo := 0;
        else 
          null;
        end if;  
      else
        counter_mo := counter_mo + 1;
    end if;

    -- BUFFER STATE, USED TO CONFIRM OR REDO THE TIME --
    when buffer_state =>
    if counter_bs = 100000000 then
      if seg_buffer = "10000011" then -- Press B to confirm
        next_state <= alarm_state;
        counter_bs := 0;     
      elsif seg_buffer = "11111001" then
        seg_h_tens <= "11111001";
        val_h_tens <= "0001";
        next_state <= set_h_ones;
        counter_bs := 0;     
      elsif seg_buffer = "10100100" then 
        seg_h_tens <= "10100100";        
        val_h_tens <= "0010";            
        next_state <= set_h_ones;
        counter_bs := 0;     
      elsif seg_buffer = "11000000" then 
        seg_h_tens <= "11000000";        
        val_h_tens <= "0000";            
        next_state <= set_h_ones;
        counter_bs := 0;     
      end if;
    else
      counter_bs := counter_bs + 1;
    end if;

    -- WAITING FOR ALARM --
    when alarm_state =>
    LED <= '1';
      keypad_h_tens <= std_logic_vector(val_h_tens);
      keypad_h_ones <= std_logic_vector(val_h_ones);
      keypad_m_tens <= std_logic_vector(val_m_tens);
      keypad_m_ones <= std_logic_vector(val_m_ones);
      if counter_as = 40000000 then -- Delay
        if seg_buffer = "11000110" then -- Press C to cancel alarm
          next_state <= idle;
          counter_as := 0;
        else
          null;
        end if;
      else
        counter_as := counter_as + 1;
      end if;
      end case;
    end if;
  end if;
end process;
end architecture;