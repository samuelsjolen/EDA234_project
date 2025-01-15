LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY lcd_init IS
    PORT (
        clk        : IN  std_logic;                 -- 100 MHz clock
        reset      : IN  std_logic;                 -- Active-low reset
        lcd_rs     : OUT std_logic;                 -- Register select
        lcd_rw     : OUT std_logic;                 -- Read/write
        lcd_e      : OUT std_logic;                 -- Enable
        lcd_db     : INOUT std_logic_vector(7 DOWNTO 0);  -- Data bus
        HOUR_ONE   : IN  STD_LOGIC_VECTOR(7 DOWNTO 0);
        HOUR_TENS  : IN  STD_LOGIC_VECTOR(7 DOWNTO 0);
        MIN_ONE    : IN  STD_LOGIC_VECTOR(7 DOWNTO 0);
        MIN_TENS   : IN  STD_LOGIC_VECTOR(7 DOWNTO 0)
    );
END ENTITY;

ARCHITECTURE behavior OF lcd_init IS
    ----------------------------------------------------------------------------
    -- Timing constants
    ----------------------------------------------------------------------------
    CONSTANT POWER_ON_DELAY : integer := 2_000_000;  -- ~20 ms
    CONSTANT WAIT_4_1_MS    : integer := 500_000;    -- ~5 ms
    CONSTANT WAIT_100_US    : integer := 20_000;     -- ~200 µs
    CONSTANT ENABLE_PULSE   : integer := 1_000;      -- ~10 µs E high
    CONSTANT BUSY_RECHECK   : integer := 20_000;     -- ~200 µs between BF checks

    ----------------------------------------------------------------------------
    -- Commands
    ----------------------------------------------------------------------------
    CONSTANT CMD_FUNC_SET_30    : std_logic_vector(7 DOWNTO 0) := "00110000"; -- 0x30
    CONSTANT CMD_FUNC_SET_FINAL : std_logic_vector(7 DOWNTO 0) := "00111000"; -- 0x38
    CONSTANT CMD_DISPLAY_OFF    : std_logic_vector(7 DOWNTO 0) := "00001000"; -- 0x08
    CONSTANT CMD_CLEAR          : std_logic_vector(7 DOWNTO 0) := "00000001"; -- 0x01
    CONSTANT CMD_ENTRY_MODE     : std_logic_vector(7 DOWNTO 0) := "00000110"; -- 0x06
    CONSTANT CMD_DISPLAY_ON     : std_logic_vector(7 DOWNTO 0) := "00001100"; -- 0x0C

    ----------------------------------------------------------------------------
    -- Characters for "HH:MM"
    ----------------------------------------------------------------------------
    TYPE msg_array_type IS ARRAY(0 TO 4) OF std_logic_vector(7 DOWNTO 0);

    SIGNAL MSG : msg_array_type := (
        (OTHERS => (OTHERS => '0'))
    );

    ----------------------------------------------------------------------------
    -- Counter for periodic updates (1 minute)
    ----------------------------------------------------------------------------
    --CONSTANT CNT_MAX : integer := 6000_000_000;  -- Adjust for 1 minute @ 100 MHz
    CONSTANT CNT_MAX : unsigned(35 downto 0) := "000101100101101000001011110000000000";
    --SIGNAL counter   : integer := 0;
    SIGNAL counter   : unsigned(35 downto 0) := "000000000000000000000000000000000000";
    SIGNAL pulse_o   : std_logic := '0';

    ----------------------------------------------------------------------------
    -- State Machine States
    ----------------------------------------------------------------------------
    TYPE state_type IS (
        wait_power_on,
        send_first_30, wait_first_30,
        send_second_30, wait_second_30,
        send_third_30, wait_third_30_done,
        check_busy_start, check_busy_pulse_high, check_busy_pulse_wait, check_busy_pulse_low, check_busy_eval,
        send_cmd_enable_high, send_cmd_enable_low,
        check_done,
        write_data_check_busy,
        write_data_pulse_high, write_data_pulse_wait, write_data_pulse_low,
        increment_char_index,
        wait_for_update,
        finished
    );
    
   

    SIGNAL state         : state_type := wait_power_on;
    SIGNAL delay_counter : integer := 0;
    SIGNAL busy_flag     : std_logic := '1';

    SIGNAL reg_rs : std_logic := '0';
    SIGNAL reg_rw : std_logic := '0';
    SIGNAL reg_e  : std_logic := '0';
    SIGNAL reg_db : std_logic_vector(7 DOWNTO 0) := (OTHERS => '0');

    SIGNAL update_flag : std_logic := '0';
    SIGNAL msg_index   : integer := 0;

BEGIN
    lcd_rs <= reg_rs;
    lcd_rw <= reg_rw;
    lcd_e  <= reg_e;
    lcd_db <= reg_db WHEN reg_rw = '0' ELSE (OTHERS => 'Z'); -- Tri-state condition

    ----------------------------------------------------------------------------
    -- Counter for Periodic Updates
    ----------------------------------------------------------------------------
    PROCESS(clk, reset)
    BEGIN
        IF reset = '0' THEN
            counter <= (others => '0');
            pulse_o <= '0';
        ELSIF rising_edge(clk) THEN
            IF counter = CNT_MAX THEN
                pulse_o <= '1';  -- Generate a pulse
                counter <= (others => '0');
            ELSE
                pulse_o <= '0';
                counter <= counter + 1;
            END IF;
        END IF;
    END PROCESS;

    ----------------------------------------------------------------------------
    -- Update MSG with Input Values
    ----------------------------------------------------------------------------
    PROCESS(clk, reset)
    BEGIN
        IF reset = '0' THEN
            update_flag <= '0';
            MSG(0) <= (OTHERS => '0');
            MSG(1) <= (OTHERS => '0');
            MSG(2) <= "00111010";  -- Colon ":"
            MSG(3) <= (OTHERS => '0');
            MSG(4) <= (OTHERS => '0');
        ELSIF rising_edge(clk) THEN
            IF pulse_o = '1' THEN
                MSG(0) <= HOUR_TENS;
                MSG(1) <= HOUR_ONE;
                MSG(3) <= MIN_TENS;
                MSG(4) <= MIN_ONE;
                update_flag <= '1';
            END IF;
        END IF;
    END PROCESS;

    ----------------------------------------------------------------------------
    -- State Machine for LCD Control
    ----------------------------------------------------------------------------
    PROCESS(clk, reset)
    BEGIN
        IF reset = '0' THEN
            state <= wait_power_on;
            delay_counter <= 0;
            reg_rs <= '0';
            reg_rw <= '0';
            reg_e  <= '0';
            reg_db <= (OTHERS => '0');
            busy_flag <= '1';
            msg_index <= 0;
            update_flag <= '0';
        ELSIF rising_edge(clk) THEN
            CASE state IS
                WHEN wait_power_on =>
                    IF delay_counter < POWER_ON_DELAY THEN
                        delay_counter <= delay_counter + 1;
                    ELSE
                        delay_counter <= 0;
                        reg_db <= CMD_FUNC_SET_30;
                        state <= send_first_30;
                    END IF;

                WHEN send_first_30 =>
                    reg_e <= '1';
                    IF delay_counter < ENABLE_PULSE THEN
                        delay_counter <= delay_counter + 1;
                    ELSE
                        reg_e <= '0';
                        delay_counter <= 0;
                        state <= wait_first_30;
                    END IF;

                WHEN wait_first_30 =>
                    IF delay_counter < WAIT_4_1_MS THEN
                        delay_counter <= delay_counter + 1;
                    ELSE
                        delay_counter <= 0;
                        reg_db <= CMD_FUNC_SET_30;
                        state <= send_second_30;
                    END IF;

                -- Additional Initialization States Omitted for Brevity...

                WHEN check_done =>
                    IF update_flag = '1' THEN
                        msg_index <= 0;
                        update_flag <= '0';
                        state <= write_data_check_busy;
                    ELSE
                        state <= wait_for_update;
                    END IF;

                WHEN write_data_check_busy =>
                    reg_rs <= '0'; reg_rw <= '1'; reg_e <= '0';
                    delay_counter <= 0;
                    state <= write_data_pulse_high;

                -- Writing Data States Omitted for Brevity...

                WHEN OTHERS =>
                    state <= wait_power_on;
            END CASE;
        END IF;
    END PROCESS;

END ARCHITECTURE;
