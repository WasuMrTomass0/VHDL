library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

-- QUOTIENT = DIVIDEND / DIVIDER
-- QUOTIENT = DIVIDEND * (2**Nbit / DIVIDER) / 2**Nbits
-- QUOTIENT = DIVIDEND *       FACTOR        / 2**Nbits

-----------------------------------------------------------------------------
entity DIVIDER_BY_CONST is
  generic (
    FACTOR_VALUE_G  : integer;  
    -- If factor is set to 0 then two below generics are used to calculate factor
    DIVIDER_VALUE_G : integer;
    NUM_OF_BITS_G   : natural;
    -- Data type
    DATA_TYPE_G  : string;  -- unsigned|signed
    DATA_WIDTH_G : natural
  );
  port (
    -- Control
    CLK : in std_logic;
    RST : in std_logic;
    EN  : in std_logic;
    
    -- Data
    DIVIDEND : in std_logic_vector(DATA_WIDTH_G-1 downto 0);
    QUOTIENT : out std_logic_vector(DATA_WIDTH_G-1 downto 0)
  );
end DIVIDER_BY_CONST;


-----------------------------------------------------------------------------
architecture RTL of DIVIDER_BY_CONST is
  
begin

  FACTOR_NOT_ZERO_GEN : if FACTOR_VALUE_G /= 0 generate
    -----------------------------------------------------------------------------
    MAIN_FNZ_PROC : process(CLK, RST)
      constant FACTOR_SIGNED_C   : signed(NUM_OF_BITS_G-1 downto 0)   := to_signed(FACTOR_VALUE_G, NUM_OF_BITS_G);
      constant FACTOR_UNSIGNED_C : unsigned(NUM_OF_BITS_G-1 downto 0) := to_unsigned(FACTOR_VALUE_G, NUM_OF_BITS_G);

      variable mult_result_v : std_logic_vector(DIVIDEND'length+NUM_OF_BITS_G-1 downto 0);
      
      constant ONE_C : unsigned(mult_result_v'range) := to_unsigned(1, mult_result_v'length);
      constant ROUNDING_VALUE_C : std_logic_vector(mult_result_v'range) := std_logic_vector(ONE_C sll (NUM_OF_BITS_G-1));

    begin
      if RST = '1' then
        QUOTIENT <= (others => '0');
    
      elsif rising_edge(CLK) then
        if DATA_TYPE_G = "signed" then
          mult_result_v := std_logic_vector(FACTOR_SIGNED_C * signed(DIVIDEND) + signed(ROUNDING_VALUE_C));
        elsif DATA_TYPE_G = "unsigned" then
          mult_result_v := std_logic_vector(FACTOR_UNSIGNED_C * unsigned(DIVIDEND) + unsigned(ROUNDING_VALUE_C));
        else
          assert false
            report "Invalid data type. Use unsigned or signed. Got " & DATA_TYPE_G
            severity failure;
        end if;
        QUOTIENT <= mult_result_v(mult_result_v'left downto (mult_result_v'left-DIVIDEND'length+1));

      end if;
    end process;
  end generate;

  
  FACTOR_IS_ZERO_GEN : if FACTOR_VALUE_G = 0 and DIVIDER_VALUE_G /= 0 generate
    -----------------------------------------------------------------------------
    MAIN_FNZ_PROC : process(CLK, RST)
      constant FACTOR_INT_C : integer := integer(2.0**NUM_OF_BITS_G) / DIVIDER_VALUE_G;
      constant FACTOR_SIGNED_C   : signed(NUM_OF_BITS_G-1 downto 0)   := to_signed(FACTOR_INT_C, NUM_OF_BITS_G);
      constant FACTOR_UNSIGNED_C : unsigned(NUM_OF_BITS_G-1 downto 0) := to_unsigned(FACTOR_INT_C, NUM_OF_BITS_G);
      variable mult_result_v : std_logic_vector(DIVIDEND'length+NUM_OF_BITS_G-1 downto 0);

      constant ONE_C : unsigned(mult_result_v'range) := to_unsigned(1, mult_result_v'length);
      constant ROUNDING_VALUE_C : std_logic_vector(mult_result_v'range) := std_logic_vector(ONE_C sll (NUM_OF_BITS_G-1));
    begin
      if RST = '1' then
        QUOTIENT <= (others => '0');
    
      elsif rising_edge(CLK) then
        if DATA_TYPE_G = "signed" then
          mult_result_v := std_logic_vector(FACTOR_SIGNED_C * signed(DIVIDEND) + signed(ROUNDING_VALUE_C));
        elsif DATA_TYPE_G = "unsigned" then
          mult_result_v := std_logic_vector(FACTOR_UNSIGNED_C * unsigned(DIVIDEND) + unsigned(ROUNDING_VALUE_C));
        else
          assert false
            report "Invalid data type. Use unsigned or signed. Got " & DATA_TYPE_G
            severity failure;
        end if;
        QUOTIENT <= mult_result_v(mult_result_v'left downto (mult_result_v'left-DIVIDEND'length+1));

      end if;
    end process;
  end generate;

  ERROR_GEN : if FACTOR_VALUE_G = 0 and DIVIDER_VALUE_G = 0 generate
    -----------------------------------------------------------------------------
    ERROR_PROC : process(CLK)
    begin
      assert false
        report "Invalid generic values. One of them must be non zero -> FACTOR_VALUE_G, DIVIDER_VALUE_G"
        severity failure;  -- note, warning, error, failure
    end process;
  end generate;

end architecture;
