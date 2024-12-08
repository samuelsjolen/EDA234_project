library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity rtc is
  port(
    clk         : in      std_logic;
    reset       : in      std_logic;
    data_trans  : inout   std_logic;  -- Pin 2 (Yellow)
    sclk        : out     std_logic;  -- Pin 1 (Green)
    ce          : out     std_logic;  -- Pin 3 (Blue)
    init_byte_ver   : out     std_logic_vector(7 downto 0); -- VERIFICATION
    state       : out     std_logic_vector(2 downto 0) -- VERIFICATION
 );
  end entity;

  architecture rtc_arch of rtc is

    ----------- DEFINES A TYPE FOR EACH STATE -----------
    type states is(
      idle,
      transmit,
      recieve
    );
  ----------- SIGNAL DECLARATIONS ----------- 
  signal init_byte      : std_logic_vector(7 downto 0);
  signal sclk_count     : std_logic;
  signal sclk_internal  : std_logic;
  signal io             : std_logic; -- '0' indicates recieve, and vice versa
  
  signal current_state  : states;
  signal next_state     : states;


  begin
    init_byte_ver <= init_byte;
    sclk <= sclk_internal;

   
    ----------- SLOWER CLOCK USED TO SYNC DATA TRANSFER -----------
    sclk_proc : process(reset, clk)
      variable counter: integer := 0;
    begin
      if rising_edge(clk) then
        if reset = '0' then
          counter := 0;
          sclk_internal <= '0';
        elsif rising_edge(clk) then
          if counter = 10 then
            sclk_internal <= not sclk_internal;
            counter := 0;
          else
            counter := counter + 1;
          end if;
        end if;
      end if;
    end process;

  ----------- CASE PROCESS, DESCRIBES EACH STATE -----------
  case_proc : process (current_state)
  begin
    case current_state is
      when idle =>
        ce <= '0';
        io <= 'Z';
        data_trans <= 'Z';
      when transmit =>
        io <= '1';
        ce <= '1';
      when recieve =>
        io <= '0';
        ce <= '1';
        data_trans <= 'Z';
    end case;
  end process;

  ----------- PROCESS TO HANDLE TIMING OF STATE SWITCHING -----------
  state_change_proc : process (sclk_internal, reset)
  begin
    if rising_edge(sclk_internal) then
      if reset = '0' then
	      current_state <= idle;
      else
	      current_state <= next_state;
      end if;
    end if;
  end process state_change_proc;



    ----------- PROCESS -----------
    state_next_proc : process (sclk_internal, current_state)
    begin
        if current_state = idle then
          init_byte <= "10101010"; -- Reloads the initial data
          state <= "001";
          next_state <= transmit;
        elsif current_state = transmit then
          state <= "010";
          data_trans <= init_byte(0);
          init_byte <= '0' & init_byte(7 downto 1);
          if init_byte = "00000000" then
            next_state <= recieve;
          end if;
        elsif current_state = recieve then
          state <= "011";
        end if;
    end process;
end architecture;