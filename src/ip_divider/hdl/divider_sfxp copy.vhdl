library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

library DIVIDER_LIB;
use DIVIDER_LIB.DIVIDER_UFXP;

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
  -- Fractional bits for divident and divisor
  constant DIVIDENT_FRAC_BITS_C : natural := num_of_frac_bits(word_width=>DIVIDEND'length, int_bits=>DIVIDEND_INT_BITS_G, data_type=>"signed");
  constant DIVISOR_FRAC_BITS_C  : natural := num_of_frac_bits(word_width=>DIVISOR'length,  int_bits=>DIVISOR_INT_BITS_G,  data_type=>"signed");

  -- Data width 
  constant QUOTIENT_WIDTH_C     : natural := DIVIDEND'length + DIVISOR'length - 1;
  constant QUOTIENT_INT_BITS_C  : natural := DIVIDEND_INT_BITS_G + DIVISOR_FRAC_BITS_C;
  constant QUOTIENT_FRAC_BITS_C : natural := DIVIDENT_FRAC_BITS_C + DIVISOR_INT_BITS_G;

  -- Signals
  signal start_i, done_i : std_logic;
  signal dividend_sign_i, divisor_sign_i, quotient_sign_i : std_logic;

  signal div_dividend_i : std_logic_vector(DIVIDEND'left-1 downto 0);
  signal div_divisor_i  : std_logic_vector(DIVISOR'left-1 downto 0);
  signal div_quotient_i : std_logic_vector(QUOTIENT_WIDTH_C-2 downto 0);
  signal quotient_i     : std_logic_vector(QUOTIENT'range);

  signal div_start_i, div_done_i, div_rst_i : std_logic;
  constant ONE_C : unsigned(div_dividend_i'range) := to_unsigned(1, div_dividend_i'length);

  type state_t is (IDLE, SIGN_IN, CALC, SIGN_OUT);
  signal state_i : state_t;

begin
  -----------------------------------------------------------------------------
  -- Concurrent statements
  -----------------------------------------------------------------------------
  start_i    <= START;
  DONE       <= done_i;


  -----------------------------------------------------------------------------
  -- Assert correct fixed point format
  -----------------------------------------------------------------------------
  assert QUOTIENT'length-1 = DIVIDEND'length + DIVISOR'length
    report "Invalid quotient fixed-point format (invalid contants)"
    severity error;
  assert QUOTIENT'length = QUOTIENT_WIDTH_C
    report "Expected quotient's lenght is invalid"
    severity error;

  ------------------------------------------------------------------------------
  -- Name    : MAIN_PROC
  -- Purpose : Prepare input data for unsigned division module. Prepare output from unsigned division
  -- Inputs  : 
  -- Output  : 
  -----------------------------------------------------------------------------
  MAIN_PROC : process(CLK, RST)
  begin
    if RST = '1' then
      done_i <= '0';
      div_start_i <= '0';
      div_rst_i <= '1';
      quotient_i <= (others => '0');
      state_i <= IDLE;
  
    elsif rising_edge(CLK) then
      case state_i is
        when IDLE =>
          if start_i = '1' then
            -- Clear done flag
            done_i <= '0';
            -- Next state
            if DIVIDEND(DIVIDEND'left) = '1' or DIVISOR(DIVISOR'left) = '1' then
              state_i <= SIGN_IN;
              -- Write neg value if needed
              if DIVIDEND(DIVIDEND'left) = '1' then
                div_dividend_i <= not DIVIDEND(DIVIDEND'left-1 downto 0);
              else
                div_dividend_i <= DIVIDEND(DIVIDEND'left-1 downto 0);
              end if;
              -- Write neg value if needed
              if DIVISOR(DIVISOR'left) = '1' then
                div_divisor_i <= not DIVISOR(DIVISOR'left-1 downto 0);
              else
                div_divisor_i <= DIVISOR(DIVISOR'left-1 downto 0);
              end if;

            else
              state_i <= CALC;
              -- Read inputs
              div_dividend_i <= DIVIDEND(DIVIDEND'left-1 downto 0);
              div_divisor_i  <= DIVISOR(DIVISOR'left-1 downto 0);
            end if;
            -- Read sign bits
            dividend_sign_i <= DIVIDEND(DIVIDEND'left);
            divisor_sign_i  <= DIVISOR(DIVISOR'left);
          end if;  

        when SIGN_IN =>
          -- Next state
          state_i <= CALC;
          -- Run division module
          div_start_i <= '1';
          div_rst_i <= '0';

          -- Output sign
          quotient_sign_i <= dividend_sign_i xor divisor_sign_i;

          -- Convert signed to absolute value stored as unsigned
          if dividend_sign_i = '1' then
            div_dividend_i <= std_logic_vector(unsigned(div_dividend_i) + ONE_C);
          end if;
          if divisor_sign_i = '1' then
            div_divisor_i <= std_logic_vector(unsigned(div_divisor_i) + ONE_C);
          end if;

        when CALC =>
          -- Stop division 
          div_start_i <= '0';
          -- Wait for done
          if div_done_i = '1' then
            state_i <= SIGN_OUT;
            -- Negate if needed
            if quotient_sign_i = '1' then
              quotient_i <= quotient_sign_i & not div_quotient_i;
            else
              quotient_i <= quotient_sign_i & div_quotient_i;
            end if;

          end if;
          
        when SIGN_OUT =>
          -- Next state
          state_i <= IDLE;
          -- Convert to signed
          if quotient_sign_i = '1' then
            quotient_i <= std_logic_vector(unsigned(quotient_i) + ONE_C);
          end if;
          -- Set flag
          done_i    <= '1';
          div_rst_i <= '1';
          -- Set output
          QUOTIENT  <= quotient_i;
          
      end case;
  
    end if;
  end process;

  ---------------------------------------------------------------------------
  -- DIV_UFXP
  ---------------------------------------------------------------------------
  DIV_UFXP : entity DIVIDER_UFXP(RTL)
    generic map (
      DIVIDEND_INT_BITS_G => DIVIDEND_INT_BITS_G,
      DIVISOR_INT_BITS_G  => DIVISOR_INT_BITS_G
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

end architecture;
