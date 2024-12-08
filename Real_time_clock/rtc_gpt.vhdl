library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity rtc is
  port(
    clk         : in      std_logic;
    reset       : in      std_logic;
    data_trans  : inout   std_logic;  -- Pin 2 (Yellow)
    sclk        : out     std_logic;  -- Pin 1 (Green)
    ce          : out     std_logic   -- Pin 3 (Blue)
  );
end entity;

architecture rtc_arch of rtc is
  signal init_byte      : std_logic_vector(7 downto 0) := "10101010";  -- Command byte
  signal sclk_internal  : std_logic := '0';
  signal ce_internal    : std_logic := '0';
  signal state          : integer := 0;  -- State machine
  signal bit_counter    : integer := 0;  -- Bit counter for command byte
begin

  -- Output signal assignments
  sclk <= sclk_internal;
  ce <= ce_internal;

  -- SCLK generation: slow clock
  sclk_proc : process(reset, clk)
    variable counter: integer := 0;
  begin
    if reset = '0' then
      counter := 0;
      sclk_internal <= '0';
    elsif rising_edge(clk) then
      if counter = 1000 then  -- Adjust value to match desired SCLK frequency
        sclk_internal <= not sclk_internal;
        counter := 0;
      else
        counter := counter + 1;
      end if;
    end if;
  end process;

  -- Main state machine for communication
  main_proc : process(clk, reset)
  begin
    if reset = '0' then
      state <= 0;
      ce_internal <= '0';
      bit_counter <= 0;
      init_byte <= "10101010";
      data_trans <= 'Z';  -- Release the data line
    elsif rising_edge(clk) then
      case state is
        when 0 =>  -- Idle state
          if sclk_internal = '0' then
            ce_internal <= '1';  -- Drive CE high
            state <= 1;  -- Move to transmit command byte
          end if;

        when 1 =>  -- Transmit command byte
          if sclk_internal = '0' then  -- Shift on falling edge of SCLK
            data_trans <= init_byte(0);  -- Shift out LSB first
            init_byte <= '0' & init_byte(7 downto 1);
            bit_counter <= bit_counter + 1;
            if bit_counter = 8 then  -- After 8 bits are sent
              bit_counter <= 0;
              data_trans <= 'Z';  -- Release the data line
              state <= 2;  -- Move to next phase
            end if;
          end if;

        when 2 =>  -- Complete transfer
          ce_internal <= '0';  -- Drive CE low
          state <= 0;  -- Return to idle state

        when others =>
          state <= 0;
      end case;
    end if;
  end process;

end architecture;
