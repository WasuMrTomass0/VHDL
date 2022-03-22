library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

library COMMON_LIB;
use COMMON_LIB.COMMON_PKG.all;

library DIVIDER_LIB;
use DIVIDER_LIB.DIVIDER_UNSIGNED;


-----------------------------------------------------------------------------
entity DIVIDER_UFXP is
  generic (
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
end DIVIDER_UFXP;


-----------------------------------------------------------------------------
architecture RTL of DIVIDER_UFXP is
  -- Fractional bits for divident and divisor
  constant DIVIDENT_FRAC_BITS_C : natural := num_of_frac_bits(word_width=>DIVIDEND'length, int_bits=>DIVIDEND_INT_BITS_G, data_type=>"unsigned");
  constant DIVISOR_FRAC_BITS_C  : natural := num_of_frac_bits(word_width=>DIVISOR'length,  int_bits=>DIVISOR_INT_BITS_G,  data_type=>"unsigned");

  -- Data width 
  constant QUOTIENT_WIDTH_C     : natural := DIVIDEND'length + DIVISOR'length;
  constant QUOTIENT_INT_BITS_C  : natural := DIVIDEND_INT_BITS_G + DIVISOR_FRAC_BITS_C;
  constant QUOTIENT_FRAC_BITS_C : natural := DIVIDENT_FRAC_BITS_C + DIVISOR_INT_BITS_G;

  -- Zeros used to resize voctors
  constant ZEROS_FOR_DIVIDENT_C : std_logic_vector(DIVISOR'range)  := (others => '0');
  constant ZEROS_FOR_DIVISOR_C  : std_logic_vector(DIVIDEND'range) := (others => '0');

  -- Internal signals
  signal div_start_i, div_done_i : std_logic;
  signal div_dividend_i, div_divisor_i, div_quotient_i : std_logic_vector(QUOTIENT_WIDTH_C-1 downto 0);

begin
  -----------------------------------------------------------------------------
  -- Concurrent statements
  -----------------------------------------------------------------------------
  div_dividend_i <= DIVIDEND & ZEROS_FOR_DIVIDENT_C;
  div_divisor_i  <= ZEROS_FOR_DIVISOR_C & DIVISOR;
  QUOTIENT <= div_quotient_i;

  div_start_i <= START;
  DONE <= div_done_i;
  

  -----------------------------------------------------------------------------
  -- Assert correct fixed point format
  -----------------------------------------------------------------------------
  assert QUOTIENT_WIDTH_C = QUOTIENT_INT_BITS_C + QUOTIENT_FRAC_BITS_C
    report "Invalid quotient fixed-point format (invalid contants)"
    severity error;
  assert QUOTIENT_WIDTH_C = QUOTIENT'length
    report "Invalid port width for QUOTIENT - based on width of DIVIDEND and DIVISOR"
    severity error;

  
  ---------------------------------------------------------------------------
  -- DIV
  ---------------------------------------------------------------------------
  DIV : entity DIVIDER_UNSIGNED(RTL)
    generic map (
      DATA_WIDTH_G => QUOTIENT_WIDTH_C
    )
    port map (
      RST => RST,
      CLK => CLK,
  
      DIVIDEND => div_dividend_i,
      DIVISOR  => div_divisor_i,
      QUOTIENT => div_quotient_i,

      START => div_start_i,
      DONE  => div_done_i
    );

end architecture;
