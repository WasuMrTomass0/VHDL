library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;


library DIVIDER_LIB;
use DIVIDER_LIB.DIVIDER_UFXP;


-----------------------------------------------------------------------------
entity DIVIDER is
  generic (
    -- signed|unsigned|invalid
    DATA_TYPE_G : string;
    -- Fixed point format of divident
    DIVIDEND_INT_BITS_G : natural;
    -- Fixed point format of divisor
    DIVISOR_INT_BITS_G  : natural
  );
  port (
    -- Control
    CLK : in std_logic;
    RST : in std_logic;

    -- Data
    DIVIDEND : in  std_logic_vector;
    DIVISOR  : in  std_logic_vector;
    QUOTIENT : out std_logic_vector;

    START : in std_logic;
    DONE  : out std_logic
  );
end DIVIDER;


-----------------------------------------------------------------------------
architecture RTL of DIVIDER is
  signal div_dividend_i : std_logic_vector(DIVIDEND'range);
  signal div_divisor_i  : std_logic_vector(DIVISOR'range);
  signal div_quotient_i : std_logic_vector(QUOTIENT'range);

begin
  -----------------------------------------------------------------------------
  SIGNED_GEN : if DATA_TYPE_G = "signed" generate
    div_dividend_i <= std_logic_vector(unsigned(not DIVIDEND) + to_unsigned(1, DIVIDEND'length));
    div_divisor_i  <= std_logic_vector(unsigned(not DIVISOR)  + to_unsigned(1, DIVISOR'length));
    QUOTIENT <= std_logic_vector(unsigned(not div_quotient_i) + to_unsigned(1, QUOTIENT'length));
  end generate;
  -----------------------------------------------------------------------------
  UNSIGNED_GEN : if DATA_TYPE_G = "unsigned" generate
    div_dividend_i <= DIVIDEND;
    div_divisor_i  <= DIVISOR;
    QUOTIENT <= div_quotient_i;
  end generate;
  -----------------------------------------------------------------------------
  -- Asserts
  -----------------------------------------------------------------------------
  assert DATA_TYPE_G = "signed" or DATA_TYPE_G = "unsigned"
    report "Invalid data type. Use unsigned or signed. Got " & DATA_TYPE_G
    severity failure;
  ---------------------------------------------------------------------------
  -- DIV
  ---------------------------------------------------------------------------
  DIV : entity DIVIDER_UFXP(RTL)
    generic map (
      DIVIDEND_INT_BITS_G => DIVIDEND_INT_BITS_G,
      DIVISOR_INT_BITS_G  => DIVISOR_INT_BITS_G
    )
    port map (
      RST => RST,
      CLK => CLK,

      DIVIDEND => div_dividend_i,
      DIVISOR  => div_divisor_i,
      QUOTIENT => div_quotient_i,
      START => START,
      DONE  => DONE
    );

end architecture;
