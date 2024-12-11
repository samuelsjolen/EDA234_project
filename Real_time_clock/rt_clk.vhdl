library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
--Library UNISIM;
--use UNISIM.vcomponents.all;

entity rtc is
  port(
    clk               : in      std_logic;
    reset             : in      std_logic;
    data_trans        : inout   std_logic;  -- Pin 2 (Yellow)
    sclk              : out     std_logic;  -- Pin 1 (Green)
    ce                : out     std_logic;  -- Pin 3 (Blue)
    init_byte_ver     : out     std_logic_vector(7 downto 0); -- VERIFICATION
    state             : out     std_logic_vector(2 downto 0); -- VERIFICATION
    data_recieved_ver : out     std_logic_vector(7 downto 0); -- VERIFICATION
    transmitted_ver   : out     std_logic;
    recieved_ver      : out     std_logic
 );
  end entity;

  architecture rtc_arch of rtc is


    ----------- STATES TYPE DEFINITION -----------
    type states is(
      idle,
      transmitting,
      recieving
    );
  ----------- SIGNAL DECLARATIONS ----------- 
  signal init_byte      : std_logic_vector(7 downto 0);
  signal sclk_internal  : std_logic;
  signal send           : std_logic;
  signal data_recieved  : std_logic_vector(7 downto 0);
  signal ce_internal    : std_logic;
  signal recieved       : std_logic; -- Flag turns '1' when message fully recieved
  signal transmitted    : std_logic; -- Flag turns '1' when message fully transmitted
  signal ce_enable      : std_logic; -- Flag to indicate ce can turn high
  
  signal current_state  : states;
  signal next_state     : states;


  begin
  

 -- IOBUF_inst : IOBUF
 -- generic map (
 --    DRIVE => 12,
 --    IOSTANDARD => "DEFAULT",
 --    SLEW => "SLOW")
 -- port map (
 --    O => O,     -- Buffer output
 --    IO => data_trans,   -- Buffer inout port (connect directly to top-level port)
 --    I => I,     -- Buffer input
 --    T => T      -- 3-state enable input, high=input, low=output 
 -- );
  
    ----- VERIFICATION -----
    init_byte_ver <= init_byte;
    data_recieved_ver <= data_recieved;
    transmitted_ver <= transmitted; 
    recieved_ver <= recieved;

    ----- INTERNAL SIGNALS -----
    sclk <= sclk_internal;
    ce <= ce_internal;

   
    ----------- SLOWER CLOCK USED TO SYNC DATA TRANSFER -----------
    sclk_proc : process(reset, clk)
      variable counter: integer := 0;
    begin
      if rising_edge(clk) then
        if reset = '0' then
          counter := 0;
          sclk_internal <= '0';
        else
          if counter = 50 then
            sclk_internal <= not sclk_internal;
            counter := 0;
          else
            counter := counter + 1;
          end if;
        end if;
      end if;
    end process;

  ----------- PROCESS TO HANDLE TIMING OF STATE SWITCHING -----------
  state_change_proc : process (sclk_internal)
  begin
    if falling_edge(sclk_internal) then
      if reset = '0' then
	      current_state <= idle;
      else
	      current_state <= next_state;
      end if;
    end if;
  end process state_change_proc;



  ----------- PROCESSS DICTATING WHEN TO SWITCH -----------
  state_next_proc : process (current_state, transmitted, recieved)
  begin
    next_state <= current_state;
    case current_state is
      when idle =>
        ce_enable <= '0';
        next_state <= transmitting;
      when transmitting =>
        ce_enable <= '1';
        if transmitted = '1' then
          next_state <= recieving;
        else
          next_state <= transmitting;
        end if;
      when recieving =>
          if recieved = '1' then
            next_state <= idle;
          end if;
    end case;
  end process;

        



-- Process to wait for low sclk --
  init_wait_proc : process (clk)
  variable counter : integer := 0;
  begin
    if rising_edge(clk) then
      if reset = '0' then
        ce_internal <= '0';
      else
        if ce_enable = '1' then
          if counter = 25 then
            ce_internal <= '1';
          else
            ce_internal <= '0';
            counter := counter + 1;
          end if;
        end if;
      end if;
    end if;
  end process;


--  data_read_proc : process ()
 --   if data_read = '1' then




  --data_write_proc : process ()
    --if data_write = '1' then







--  ----------- PROCESSS DICTATING FUNCTIONS OF EACH STATE -----------
--  state_func_proc : process (current_state)
--  begin
--    case current_state is
--      when idle =>
--        send <= '0';
--        state <= "001"; -- VERIFICATION
--      when transmitting =>
--        send <= '1';
--        state <= "010"; -- VERIFICATION
--      when recieving =>
--        send <= '0';
--        state <= "011"; -- VERIFICATION
--    end case;
--  end process;
--
--    trans_proc : process (sclk_internal, send)
--    variable counter_r : integer := 0;
--    variable counter_t : integer := 0;
--    begin
--    if falling_edge(sclk_internal) then
--      -- Recieves
--      if send = '0' then
--        transmitted <= '0';
--        init_byte <= "10000011"; -- Reloads the initial data
--        data_trans <= 'Z';
--          if ce_internal = '1' then
--            data_recieved <= data_trans & data_recieved(7 downto 1);
--            if counter_r = 8 then
--              recieved <= '1';
--              counter_r := 0;
--            else 
--              counter_r := counter_r + 1;
--              recieved <= '0';
--            end if;
--          end if;
--      end if;
--          -- Transmits
--          if send = '1' then
--            recieved <= '0';
--            data_trans <= init_byte(0);
--            init_byte <= '0' & init_byte(7 downto 1);
--            if counter_t = 8 then
--              transmitted <= '1';
--              counter_t := 0;
--            else 
--              counter_t := counter_t + 1;
--              transmitted <= '0';
--          end if;
--          end if;
--      end if;
--    end process;

end architecture;
