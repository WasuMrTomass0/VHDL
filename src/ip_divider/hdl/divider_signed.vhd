library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

library DIVIDER_LIB;
use DIVIDER_LIB.DIVIDER_UNSIGNED;

-----------------------------------------------------------------------------
entity DIVIDER_SIGNED is
  generic (
    DATA_WIDTH_G : natural
  );
  port (
    -- Control
    CLK : in std_logic;
    RST : in std_logic;
    
    -- Data
    DIVIDEND : in std_logic_vector(DATA_WIDTH_G-1 downto 0);
    DIVISOR  : in std_logic_vector(DATA_WIDTH_G-1 downto 0);
    QUOTIENT : out std_logic_vector(DATA_WIDTH_G-1 downto 0);

    START : in std_logic;
    DONE  : out std_logic
  );
end DIVIDER_SIGNED;


architecture RTL of DIVIDER_SIGNED is
  signal start_i, done_i : std_logic;
  signal dividend_sign_i, divisor_sign_i, quotient_sign_i : std_logic;
  signal dividend_i, divisor_i, quotient_i : std_logic_vector(DATA_WIDTH_G-1 downto 0);

  signal div_start_i, div_done_i, div_rst_i : std_logic;
  signal div_dividend_i, div_divisor_i, div_quotient_i : std_logic_vector(DATA_WIDTH_G-2 downto 0);
  constant ONE_C : unsigned(div_dividend_i'range) := to_unsigned(1, div_dividend_i'length);

  type state_t is (IDLE, SIGN_IN, CALC, SIGN_OUT);
  signal state_i : state_t;

begin
  -----------------------------------------------------------------------------
  -- Concurrent statements
  -----------------------------------------------------------------------------
  start_i    <= START;
  QUOTIENT   <= quotient_i;
  DONE       <= done_i;

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
            -- Next state
            state_i <= SIGN_IN;
            -- Clear done flag
            done_i <= '0';
            -- Read inputs
            dividend_i <= DIVIDEND;
            divisor_i  <= DIVISOR;
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
            div_dividend_i <= std_logic_vector(unsigned(not dividend_i(dividend_i'left-1 downto 0)) + ONE_C);
          else
            div_dividend_i <= dividend_i(dividend_i'left-1 downto 0);
          end if;
          if divisor_sign_i = '1' then
            div_divisor_i <= std_logic_vector(unsigned(not divisor_i(divisor_i'left-1 downto 0)) + ONE_C);
          else
          div_divisor_i <= divisor_i(divisor_i'left-1 downto 0);
          end if;

        when CALC =>
          -- Stop division 
          div_start_i <= '0';
          -- Wait for done
          if div_done_i = '1' then
            state_i <= SIGN_OUT;
          end if;
          
        when SIGN_OUT =>
          -- Next state
          state_i <= IDLE;
          -- Convert to signed
          if quotient_sign_i = '1' then
            quotient_i <= quotient_sign_i & std_logic_vector(unsigned(not div_quotient_i) + ONE_C);
          else
            quotient_i <= quotient_sign_i & div_quotient_i;
          end if;
          -- Set flag
          done_i <= '1';
          div_rst_i <= '1';
          
      end case;
  
    end if;
  end process;

  ---------------------------------------------------------------------------
  -- DIV_UNSIGNED
  ---------------------------------------------------------------------------
  DIV_UNSIGNED : entity DIVIDER_UNSIGNED(RTL)
    generic map (
      DATA_WIDTH_G => DATA_WIDTH_G-1
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


architecture BEH of DIVIDER_SIGNED is
begin

  ------------------------------------------------------------------------------
  -- Name    : DIVISION_PROC
  -- Purpose : Divide signed numbers
  -- Inputs  : START, DIVIDEND, DIVISOR
  -- Output  : QUOTIENT, DONE
  -----------------------------------------------------------------------------
  DIVISION_PROC : process(CLK, RST)
  begin

    if RST = '1' then
      DONE <= '0';
      QUOTIENT <= (others => '0');

    elsif rising_edge(CLK) then
      if START = '1' then
        QUOTIENT <= std_logic_vector(signed(DIVIDEND) / signed(DIVISOR));
        DONE     <= '1';

      end if;  

    end if;
    
  end process;

end architecture;
