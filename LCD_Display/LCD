LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY lcd_init IS
    PORT (
        clk     : IN  std_logic;                 -- 100 MHz clock
        reset   : IN  std_logic;                 -- Active-low reset
        lcd_rs  : OUT std_logic;                 -- Register select
        lcd_rw  : OUT std_logic;                 -- Read/write
        lcd_e   : OUT std_logic;                 -- Enable
        lcd_db  : INOUT std_logic_vector(7 DOWNTO 0)  -- Data bus
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
    -- Characters for "11:45"
    ----------------------------------------------------------------------------
    TYPE msg_array_type IS ARRAY(0 TO 4) OF std_logic_vector(7 DOWNTO 0);

    CONSTANT MSG : msg_array_type := (
        "00110001", -- '1'
        "00110001", -- '1'
        "00111010", -- ':'
        "00110100", -- '4'
        "00110101"  -- '5'
    );

    ----------------------------------------------------------------------------
    -- Final Initialization Commands
    ----------------------------------------------------------------------------
    TYPE cmd_array_type IS ARRAY(0 TO 4) OF std_logic_vector(7 DOWNTO 0);
    CONSTANT FINAL_CMDS : cmd_array_type := (
        CMD_FUNC_SET_FINAL,
        CMD_DISPLAY_OFF,
        CMD_CLEAR,
        CMD_ENTRY_MODE,
        CMD_DISPLAY_ON
    );

    ----------------------------------------------------------------------------
    -- State Machine States
    ----------------------------------------------------------------------------
    TYPE state_type IS (
        -- Initial steps (no BF checking, will rely on delays)
        wait_power_on,
        send_first_30, wait_first_30,
        send_second_30, wait_second_30,
        send_third_30,
        wait_third_30_done,

        -- BF check for final init commands
        check_busy_start, check_busy_pulse_high, check_busy_pulse_wait, check_busy_pulse_low, check_busy_eval,
        send_cmd_enable_high, send_cmd_enable_low,

        -- After final init commands done
        check_done,

        -- States to write multiple characters
        write_data_check_busy,
        write_data_pulse_high,
        write_data_pulse_wait,
        write_data_pulse_low,
        send_data_enable,
        increment_char_index,
        done_writing,

        finished
    );

    ----------------------------------------------------------------------------
    -- Signals
    ----------------------------------------------------------------------------
    SIGNAL state         : state_type := wait_power_on;
    SIGNAL delay_counter : integer := 0;
    SIGNAL busy_flag     : std_logic := '1';

    SIGNAL reg_rs : std_logic := '0';
    SIGNAL reg_rw : std_logic := '0';
    SIGNAL reg_e  : std_logic := '0';
    SIGNAL reg_db : std_logic_vector(7 DOWNTO 0) := (OTHERS => '0');

    SIGNAL cmd_data_value : std_logic_vector(7 DOWNTO 0) := (OTHERS => '0');
    SIGNAL cmd_index      : integer := 0;

    -- Index for writing the message "11:45"
    SIGNAL msg_index : integer := 0;

BEGIN

    lcd_rs <= reg_rs;
    lcd_rw <= reg_rw;
    lcd_e  <= reg_e;
    lcd_db <= reg_db WHEN reg_rw='0' ELSE (OTHERS => 'Z'); --tri-state condition

    PROCESS(clk, reset)
    BEGIN
        IF reset = '0' THEN
            state <= wait_power_on;
            delay_counter <= 0;
            reg_rs <= '0';
            reg_rw <= '0';
            reg_e <= '0';
            reg_db <= (OTHERS => '0');
            busy_flag <= '1';
            cmd_data_value <= (OTHERS => '0');
            cmd_index <= 0;
            msg_index <= 0;
        ELSIF rising_edge(clk) THEN
            CASE state IS

                -- Power-on wait >15ms
                WHEN wait_power_on =>
                    IF delay_counter < POWER_ON_DELAY THEN
                        delay_counter <= delay_counter + 1;
                    ELSE
                        delay_counter <= 0;
                        cmd_data_value <= CMD_FUNC_SET_30;
                        reg_rs <= '0'; reg_rw <= '0'; reg_db <= CMD_FUNC_SET_30;
                        state <= send_first_30;
                    END IF;

                -- Send first function set (0x30), wait >4.1ms
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
                        cmd_data_value <= CMD_FUNC_SET_30;
                        reg_rs <= '0'; reg_rw <= '0'; reg_db <= CMD_FUNC_SET_30;
                        state <= send_second_30;
                    END IF;

                -- Send second function set (0x30), wait >100µs
                WHEN send_second_30 =>
                    reg_e <= '1';
                    IF delay_counter < ENABLE_PULSE THEN
                        delay_counter <= delay_counter + 1;
                    ELSE
                        reg_e <= '0';
                        delay_counter <= 0;
                        state <= wait_second_30;
                    END IF;

                WHEN wait_second_30 =>
                    IF delay_counter < WAIT_100_US THEN
                        delay_counter <= delay_counter + 1;
                    ELSE
                        delay_counter <= 0;
                        cmd_data_value <= CMD_FUNC_SET_30;
                        reg_rs <= '0'; reg_rw <= '0'; reg_db <= CMD_FUNC_SET_30;
                        state <= send_third_30;
                    END IF;

                -- Send third function set (0x30)
                WHEN send_third_30 =>
                    reg_e <= '1';
                    IF delay_counter < ENABLE_PULSE THEN
                        delay_counter <= delay_counter + 1;
                    ELSE
                        reg_e <= '0';
                        delay_counter <= 0;
                        state <= wait_third_30_done;
                    END IF;

                WHEN wait_third_30_done =>
                    cmd_index <= 0;
                    cmd_data_value <= FINAL_CMDS(cmd_index);
                    state <= check_busy_start;

                -- Check busy flag routine for commands
                WHEN check_busy_start =>
                    reg_rs <= '0';
                    reg_rw <= '1';
                    reg_e <= '0';
                    delay_counter <= 0;
                    state <= check_busy_pulse_high;

                WHEN check_busy_pulse_high =>
                    reg_e <= '1';
                    IF delay_counter < ENABLE_PULSE THEN
                        delay_counter <= delay_counter + 1;
                    ELSE
                        delay_counter <= 0;
                        state <= check_busy_pulse_wait;
                    END IF;

                WHEN check_busy_pulse_wait =>
                    IF delay_counter < ENABLE_PULSE THEN
                        delay_counter <= delay_counter + 1;
                    ELSE
                        delay_counter <= 0;
                        state <= check_busy_pulse_low;
                    END IF;

                WHEN check_busy_pulse_low =>
                    busy_flag <= lcd_db(7);
                    reg_e <= '0';
                    delay_counter <= 0;
                    state <= check_busy_eval;

                WHEN check_busy_eval =>
                    IF busy_flag = '0' THEN
                        reg_rs <= '0'; reg_rw <= '0'; reg_db <= cmd_data_value;
                        delay_counter <= 0;
                        state <= send_cmd_enable_high;
                    ELSE
                        IF delay_counter < BUSY_RECHECK THEN
                            delay_counter <= delay_counter + 1;
                        ELSE
                            delay_counter <= 0;
                            state <= check_busy_start;
                        END IF;
                    END IF;

                -- Enable high for command
                WHEN send_cmd_enable_high =>
                    reg_e <= '1';
                    IF delay_counter < ENABLE_PULSE THEN
                        delay_counter <= delay_counter + 1;
                    ELSE
                        reg_e <= '0';
                        delay_counter <= 0;
                        state <= send_cmd_enable_low;
                    END IF;

                -- Enable low, move to next command
                WHEN send_cmd_enable_low =>
                    IF cmd_index < 5 THEN
                        cmd_index <= cmd_index + 1;
                        cmd_data_value <= FINAL_CMDS(cmd_index);
                        state <= check_busy_start;
                    ELSE
                        state <= check_done;
                    END IF;

                -- Initialization complete, write "11:45"
                WHEN check_done =>
                    msg_index <= 0;
                    state <= write_data_check_busy;

                -- Write each character
                WHEN write_data_check_busy =>
                    reg_rs <= '0'; reg_rw <= '1'; reg_e <= '0';
                    IF delay_counter < ENABLE_PULSE THEN
                        delay_counter <= delay_counter + 1;
                    ELSE
                        delay_counter <= 0;
                        state <= write_data_pulse_high;
                    END IF;

                WHEN write_data_pulse_high => --delays for writing
                    reg_e <= '1';
                    IF delay_counter < ENABLE_PULSE THEN
                        delay_counter <= delay_counter + 1;
                    ELSE
                        delay_counter <= 0;
                        state <= write_data_pulse_wait;
                    END IF;

                WHEN write_data_pulse_wait => --delays
                    IF delay_counter < ENABLE_PULSE THEN
                        delay_counter <= delay_counter + 1;
                    ELSE
                        delay_counter <= 0;
                        state <= write_data_pulse_low;
                    END IF;

                WHEN write_data_pulse_low =>
                    busy_flag <= lcd_db(7);
                    reg_e <= '0';
                    delay_counter <= 0;
                    IF busy_flag = '0' THEN
                        reg_rs <= '1'; -- Data register, cahnge so that we can write to the lcd
                        reg_rw <= '0';
                        reg_db <= MSG(msg_index);
                        state <= send_data_enable;
                    ELSE
                        IF delay_counter < BUSY_RECHECK THEN
                            delay_counter <= delay_counter + 1;
                        ELSE
                            delay_counter <= 0;
                            state <= write_data_check_busy;
                        END IF;
                    END IF;

                WHEN send_data_enable =>
                    reg_e <= '1';
                    IF delay_counter < ENABLE_PULSE THEN
                        delay_counter <= delay_counter + 1;
                    ELSE
                        reg_e <= '0';
                        delay_counter <= 0;
                        state <= increment_char_index;
                    END IF;

                WHEN increment_char_index =>
                    msg_index <= msg_index + 1;
                    IF msg_index < 5 THEN
                        state <= write_data_check_busy;
                    ELSE
                        state <= done_writing;
                    END IF;

                WHEN done_writing =>
                    state <= finished;

                WHEN finished =>
                    NULL;

                WHEN OTHERS =>
                    state <= wait_power_on;

            END CASE;
        END IF;
    END PROCESS;

END behavior;
