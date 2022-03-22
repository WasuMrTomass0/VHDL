library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

library DIVIDER_LIB;
use DIVIDER_LIB.DIVIDER_UFXP;
use DIVIDER_LIB.SFXP_TO_UFXP;
use DIVIDER_LIB.UFXP_TO_SFXP;

library COMMON_LIB;
use COMMON_LIB.COMMON_PKG.all;

-----------------------------------------------------------------------------
entity DIVIDER_SFXP is
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
    DIVIDEND : in std_logic_vector;
    DIVISOR  : in std_logic_vector;
    QUOTIENT : out std_logic_vector;

    START : in std_logic;
    DONE  : out std_logic
  );
end DIVIDER_SFXP;


architecture RTL of DIVIDER_SFXP is
  -- Signals
  signal start_i, done_i : std_logic;

  -- DIV
  constant UNSIGNED_DIVIDEND_INT_BITS_C : natural := 1 + DIVIDEND_INT_BITS_G;
  constant UNSIGNED_DIVISOR_INT_BITS_C  : natural := 1 + DIVISOR_INT_BITS_G;
  signal div_start_i, div_done_i, div_rst_i : std_logic;
  signal div_dividend_i : std_logic_vector(DIVIDEND'range);
  signal div_divisor_i  : std_logic_vector(DIVISOR'range);
  signal div_quotient_i : std_logic_vector(DIVIDEND'length+DIVISOR'length-1 downto 0);  -- One less bit
  signal quotient_i     : std_logic_vector(QUOTIENT'range);

  -- ABS_DIVIDENT
  signal abs_divident_sfxp_i : std_logic_vector(DIVIDEND'length-1 downto 0);
  signal abs_divident_ufxp_i : std_logic_vector(DIVIDEND'length-1 downto 0);
  signal abs_divident_start_i, abs_divident_done_trigger_i, abs_divident_sign_bit_i : std_logic;

  -- ABS_DIVISOR
  signal abs_divisor_sfxp_i : std_logic_vector(DIVISOR'length-1 downto 0);
  signal abs_divisor_ufxp_i : std_logic_vector(DIVISOR'length-1 downto 0);
  signal abs_divisor_start_i, abs_divisor_done_trigger_i, abs_divisor_sign_bit_i : std_logic;

  -- QUOT_SFXP
  signal quot_sfxp_sfxp_i : std_logic_vector(QUOTIENT'range);
  signal quot_sfxp_ufxp_i : std_logic_vector(div_quotient_i'range);
  signal quot_sfxp_sign_bit_i, quot_sfxp_start_i, quot_sfxp_done_trigger_i : std_logic;

begin
  -----------------------------------------------------------------------------
  -- Assert
  -----------------------------------------------------------------------------
  -- QUOTIENT is S.I.F where
  -- I = DIVIDEND.I + DIVISOR.F + 1
  -- F = DIVIDEND.F + DIVISOR.I + 1
  assert QUOTIENT'length = DIVIDEND'length + DIVISOR'length
    report "I/O ports lenghts do not match"
    severity error;


  -----------------------------------------------------------------------------
  -- Concurrent statements
  -----------------------------------------------------------------------------
  abs_divident_sfxp_i <= DIVIDEND;
  abs_divisor_sfxp_i  <= DIVISOR;

  abs_divident_start_i <= start_i;
  abs_divisor_start_i  <= start_i;

  div_dividend_i <= abs_divident_ufxp_i;
  div_divisor_i  <= abs_divisor_ufxp_i;
  div_start_i <= abs_divident_done_trigger_i and abs_divisor_done_trigger_i;

  ---------------------------------------------------------------------------
  -- ABS_DIVIDENT
  ---------------------------------------------------------------------------
  ABS_DIVIDENT : entity SFXP_TO_UFXP(RTL)
    generic map (
      DATA_WIDTH_G => DIVIDEND'length
    )
    port map (
      RST => RST,
      CLK => CLK,
  
      SFXP => abs_divident_sfxp_i,
      UFXP => abs_divident_ufxp_i,
      SIGN_BIT => abs_divident_sign_bit_i,

      START => abs_divident_start_i,
      DONE_TRIGGER => abs_divident_done_trigger_i
    );
  
  ---------------------------------------------------------------------------
  -- ABS_DIVISOR
  ---------------------------------------------------------------------------
  ABS_DIVISOR : entity SFXP_TO_UFXP(RTL)
    generic map (
      DATA_WIDTH_G => DIVISOR'length
    )
    port map (
      RST => RST,
      CLK => CLK,
  
      SFXP => abs_divisor_sfxp_i,
      UFXP => abs_divisor_ufxp_i,
      SIGN_BIT => abs_divisor_sign_bit_i,

      START => abs_divisor_start_i,
      DONE_TRIGGER => abs_divisor_done_trigger_i
    );

  ---------------------------------------------------------------------------
  -- DIV_UFXP
  ---------------------------------------------------------------------------
  DIV_UFXP : entity DIVIDER_UFXP(RTL)
    generic map (
      DIVIDEND_INT_BITS_G => UNSIGNED_DIVIDEND_INT_BITS_C,
      DIVISOR_INT_BITS_G  => UNSIGNED_DIVISOR_INT_BITS_C
    )
    port map (
      RST => div_rst_i,
      CLK => CLK,
  
      DIVIDEND => div_dividend_i,
      DIVISOR  => div_divisor_i,
      QUOTIENT => div_quotient_i,
      START => div_start_i,
      DONE  => div_done_i
    );

    
  ---------------------------------------------------------------------------
  -- QUOT_SFXP
  ---------------------------------------------------------------------------
  QUOT_SFXP : entity UFXP_TO_SFXP(RTL)
  generic map (
    DATA_WIDTH_G => QUOTIENT'length-1
  )
  port map (
    RST => RST,
    CLK => CLK,

    SFXP => quot_sfxp_sfxp_i,
    UFXP => quot_sfxp_ufxp_i,
    SIGN_BIT => quot_sfxp_sign_bit_i,

    START => quot_sfxp_start_i,
    DONE_TRIGGER => quot_sfxp_done_trigger_i
  );
end architecture;
