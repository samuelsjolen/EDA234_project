-- COMMANDE BYTE INITIATES --
-- Lasts 8 cycles
-- Bit 7 - '1', otherwise writes disabled
-- Bit 6 - '0' clock/calender, '1' RAM data
-- Bit 5 - '0' register A4 read, '1' register A4 write
-- Bit 4 - '0' register A3 read, '1' register A3 write
-- Bit 3 - '0' register A2 read, '1' register A2 write
-- Bit 2 - '0' register A1 read, '1' register A1 write
-- Bit 1 - '0' register A0 read, '1' register A0 write 
-- Bit 0 - '0' write data, '1' read data

-- CE --
-- CE driven high initiates data transfer 
-- CE driven low terminates all data transfers 
-- CE must be low until V_cc > 2V 
-- SCLK must be 0 when CE turs high

-- DATA INPUT --
-- Bit 0 comes first


-- DATA OUTPUT --
-- Bit 0 comes first
-- Continues while CE high


-- CLOCK/CALENDAR -- 
-- Registers binary coded decimal format
-- Day of week user defined
-- Bit 7 of hours register, low 23-hour format


-- CLOCK HALT -- 
-- Stop the count, Bit 7 seconds register set to high


-- WRITE-PROTECT -- 
-- Before any write, set bit 7 control register to low

----- Cycle -----
-- CE turns high (SCLK low)
-- Next 8 SCLK, command bytes
-- Following 8 SCLK, data transfer


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity rtc is
  port(
    clk         : in      std_logic;
    reset       : in      std_logic;
    data_trans  : inout   std_logic;  -- Pin 2 (Yellow)
    sclk        : out     std_logic;  -- Pin 1 (Green)
    ce          : out     std_logic--;  -- Pin 3 (Blue)
    --init_byte_ver   : out     std_logic_vector(7 downto 0)
    --seg         : out std_logic_vector(7 downto 0); -- Output on segment display, only for testing
    --AN          : out std_logic_vector(7 downto 0)  -- To lit display, only for testing
  );
  end entity;



  architecture rtc_arch of rtc is
  -- CLK must be at 0 when CE driven to high
  -- 
  signal init_byte      : std_logic_vector(7 downto 0):="10111111";
  signal sclk_count     : std_logic;
  signal sclk_internal  : std_logic;
  signal ce_internal    : std_logic;
  signal shifted_out    : std_logic;

  --signal date_time  : std_logic_vector();

  begin
    --init_byte_ver <= init_byte;
    sclk <= sclk_internal;
    ce <= ce_internal;
   -- AN <= "11111110";

   -- Behöver initiera allt med en reset, därefter ska ce bli 1
   
   -- Creates a slow clock
    sclk_proc : process(reset, clk)
      variable counter: integer := 0;
    begin
      if reset = '0' then
 -- Bra att börja med falling edge
        counter := 0;
        sclk_internal <= '0';
      elsif rising_edge(clk) then
        if counter = 1000000 then
          sclk_internal <= not sclk_internal;
          counter := 0;
        else
          counter := counter + 1;
        end if;
      end if;
    end process;

    -- Shifts out the command byte on the I/O
    init_proc : process(reset, sclk_internal, ce_internal)
    begin
      if reset = '0' then
        init_byte <= "10101010";
      else
        if ce_internal = '1'  then      
          data_trans <= init_byte(0);
          init_byte <= '0' & init_byte(7 downto 1);
          if init_byte = "00000000" then -- Kommer ej fungera om sista biten är '0'
            data_trans <= 'Z'; -- Disable drive through the port
          end if;
        else
          init_byte <= "10101010";
        end if;
      end if;
    end process;

   -- rec_proc : process()

    --end process;
  
    ce_proc : process(reset, sclk_internal)
    variable counter: integer := 0;
    begin
      if reset = '0' then
        ce_internal <= '0';
        counter := 0;
      else
        if falling_edge(sclk_internal) then
          if counter = 15 then
            ce_internal <= not ce_internal;
            counter :=0;
          else
            counter := counter + 1;
          end if;
        end if;
      end if;
 
    end process;


   -- read_proc : process(SCLK)
     -- if init_byte = "00000000" then
      
    --end process;

  end architecture;