library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL; -- Correct arithmetic library

entity Keypad_Controller is
    Port (
        clk          : in  STD_LOGIC;              -- Clock signal
        resetn       : in  STD_LOGIC;              -- Reset signal
        row          : in  STD_LOGIC_VECTOR(3 downto 0); -- Input rows from keypad
        col          : out STD_LOGIC_VECTOR(3 downto 0); -- Output columns to keypad
        seg          : out STD_LOGIC_VECTOR(7 downto 0); -- 7-segment display output
        AN           : out std_logic_vector(7 downto 0)
    );
end Keypad_Controller;

architecture Behavioral of Keypad_Controller is

    -- Declare the array type and constant
    type KeyMap_Type is array (0 to 3, 0 to 3) of STD_LOGIC_VECTOR(3 downto 0);
    constant KEY_MAP : KeyMap_Type := (
        ("0000", "0001", "0010", "0011"), -- Row 0: Keys 0, 1, 2, 3
        ("0100", "0101", "0110", "0111"), -- Row 1: Keys 4, 5, 6, 7
        ("1000", "1001", "1010", "1011"), -- Row 2: Keys 8, 9, A, B
        ("1100", "1101", "1110", "1111")  -- Row 3: Keys C, D, E, F
    );

    -- Define 7-segment display mapping for Hex values (0-9, A-F)
    type Seg_Type is array (0 to 15) of STD_LOGIC_VECTOR(7 downto 0);
    constant SEG_MAP : Seg_Type := (
        "10000001", -- 0
        "11001111", -- 1
        "10010010", -- 2
        "10000110", -- 3
        "11001100", -- 4
        "10100100", -- 5
        "10100000", -- 6
        "10001111", -- 7
        "10000000", -- 8
        "10000100", -- 9
        "10001000", -- A
        "11100000", -- B
        "10110001", -- C
        "11000010", -- D
        "10110000", -- E
        "10111000"  -- F
    );

    type State_Type is (IDLE, SCAN);
    signal state        : State_Type := IDLE;
    signal col_index    : integer range 0 to 3 := 0;
    signal debounce_cnt : integer range 0 to 10000 := 0;
    signal row_value    : STD_LOGIC_VECTOR(3 downto 0);
    signal key_hex      : STD_LOGIC_VECTOR(3 downto 0);
    signal reset        : std_logic;

begin
  AN <= "11111110"; 
  reset <= not resetn;



    process(clk, reset)
    begin
        if reset = '1' then
            state <= IDLE;
            col <= "1111"; -- All columns inactive
            seg <= "11111111"; -- Turn off all segments
            col_index <= 0;
        elsif rising_edge(clk) then
            case state is
                when IDLE =>
                    -- Reset and prepare to scan
                    col <= "1111"; -- Deactivate all columns
                    if debounce_cnt > 1000 then
                        debounce_cnt <= 0;
                        col_index <= 0;
                        state <= SCAN;
                    else
                        debounce_cnt <= debounce_cnt + 1;
                    end if;

                when SCAN =>
                    -- Activate the current column
                    col <= NOT std_logic_vector(to_unsigned(col_index, 4));

                    -- Check if any row is active
                    row_value <= row;
                    if row_value /= "0000" then
                        -- Decode key based on row and column
                        for i in 0 to 3 loop
                            if row(i) = '1' then
                                key_hex <= KEY_MAP(i, col_index);
                                -- Output the corresponding 7-segment display pattern
                                seg <= SEG_MAP(to_integer(unsigned(key_hex)));
                                state <= IDLE; -- Return to IDLE after detecting a key
                                exit;
                            end if;
                        end loop;
                    else
                        -- Move to the next column
                        if col_index < 3 then
                            col_index <= col_index + 1;
                        else
                            col_index <= 0;
                        end if;
                    end if;
            end case;
        end if;
    end process;

end Behavioral;
