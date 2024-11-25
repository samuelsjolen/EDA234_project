library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use STD.textio.all;


entity keyboard_tb is
end entity;


architecture keyboard_tb_arch of keyboard_tb is

  component keyboard is
    port (
      clk   : in  std_logic;
      resetn: in  std_logic;
      key   : in  STD_LOGIC_VECTOR(7 downto 0); -- X1 -> X4 = pin 1 -> pin 4
                                                -- Y1 -> Y4 = pin 7 -> pin 10
      seg   : out STD_LOGIC_VECTOR(7 downto 0);
      AN    : out STD_LOGIC_VECTOR(7 downto 0)
    );
    end component keyboard;

  file key_vectors : text open read_mode is "C:\Chalmers\EDA234\EDA_234_project\test_vectors\key_vectors.txt"; -- <Keyword> <name in code> : <file_type> is <mode> "<file_path>"
  file seg_vectors : text open read_mode is "C:\Chalmers\EDA234\EDA_234_project\test_vectors\seg_vectors.txt"; -- <Keyword> <name in code> : <file_type> is <mode> "<file_path>"

  signal clk_sig  : std_logic := '0';
  signal reset_sig: std_logic := '0';
  signal seg_sig  : STD_LOGIC_VECTOR(7 downto 0);
  signal key_sig  : STD_LOGIC_VECTOR(7 downto 0);
  signal AN_sig   : STD_LOGIC_VECTOR(7 downto 0); 

  constant PERIOD : time      := 10 ns; 
  
  function to_stdlogicvector(s : string) return std_logic_vector is -- Funktion för att omvandla string till std_logic_vector
    variable result : std_logic_vector(s'length-1 downto 0);
  begin
    for i in s'range loop
      if s(i) = '0' then
        result(i-1) := '0';
      elsif s(i) = '1' then
        result(i-1) := '1';
      else
        result(i-1) := 'X'; -- Hantera okända tecken
      end if;
    end loop;
    return result;
  end function;

  function to_string(slv: std_logic_vector) return string is
    variable result: string(1 to slv'length);
 begin
    for i in slv'range loop
       result(i - slv'low + 1) := character'VALUE(std_ulogic'IMAGE(slv(i)));
    end loop;
    return result;
 end function;
  

  begin
    keyboard_inst : component keyboard
      port map (
        clk     => clk_sig,
        resetn  => reset_sig,
        key     => key_sig,
        seg     => seg_sig,
        AN      => AN_sig
      );

    clk_sig <= not clk_sig after PERIOD/2.0; 

    verification_proc : process
      variable key_buffer : line;
      variable seg_buffer : line;
      variable key_value  : std_logic_vector(7 downto 0);
      variable seg_value  : std_logic_vector(7 downto 0);
      variable key_str    : string(1 to 8); -- Temporär variabel för att läsa av sträng
      variable seg_str    : string(1 to 8); -- Temporär variabel för att läsa av sträng
    begin
      reset_sig <= '1';
      wait for PERIOD;
      reset_sig <= '0';
      wait for PERIOD;
      reset_sig <= '1';
      wait for PERIOD;
      while not endfile(key_vectors) loop
        readline(key_vectors, key_buffer); -- Reads line from key_vectors and stores in key_buffer
        readline(seg_vectors, seg_buffer); -- Reads line from seg_vectors and stores in seg_buffer

        read(key_buffer, key_str); -- Läser in key_buffer som en sträng på key_str
        read(seg_buffer, seg_str); -- Läser in seg_buffer som en sträng på seg_str

        key_value := to_stdlogicvector(key_str); -- Omvandlar key_str till std_logic_vector
        seg_value := to_stdlogicvector(seg_str); -- Omvandlar seg_str till std_logic_vector

        key_sig <= key_value;
        wait for 3*PERIOD;
        if seg_sig = seg_value then
          report "Match";
        end if;
        assert seg_sig = seg_value
        report "Mismatched vectors: seg_sig = " & to_string(seg_sig) & ", Seg should be = " & to_string(seg_value) & 
          ", Key should be = " & to_string(key_value) & ", key_sig = " & to_string(key_sig)
        severity WARNING;
        wait for 5*PERIOD;
      end loop;
      wait for 1000*PERIOD;
      report "Testbench finished" severity FAILURE;
    end process;
  

end architecture;