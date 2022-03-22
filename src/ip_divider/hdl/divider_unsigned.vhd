library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

entity DIVIDER_UNSIGNED is
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
end DIVIDER_UNSIGNED;



architecture rtl of DIVIDER_UNSIGNED is

  signal start_i, done_i : std_logic;
  signal dividend_i, divisor_i, quotient_i : std_logic_vector(DATA_WIDTH_G-1 downto 0);

  signal a : unsigned(dividend'range);
  signal b : unsigned(divisor'range);
  signal p : unsigned(dividend'length downto 0);

  subtype index_t is natural range 0 to b'length;
  signal index_i : index_t; 

  type state_t is (IDLE, SHIFT, SUB, INSERT, CALC_DONE);
  signal state_i : state_t;

begin
  -----------------------------------------------------------------------------
  start_i    <= START;
  dividend_i <= DIVIDEND;
  divisor_i  <= DIVISOR;
  QUOTIENT   <= quotient_i;
  DONE       <= done_i;

  -----------------------------------------------------------------------------
  MAIN_PROC : process(CLK, RST)
  begin
    if RST = '1' then
      done_i <= '0';
      state_i <= IDLE;
      quotient_i <= (others => '0');

  
    elsif rising_edge(CLK) then
      case state_i is
        when IDLE =>
          if start_i = '1' then
            -- Change state
            state_i <= SHIFT;
            -- Init values
            index_i <= 0;
            -- Read inputs
            a <= unsigned(dividend_i);
            b <= unsigned(divisor_i);
            p <= (others => '0');
            -- Clear done flag
            done_i <= '0';
          end if;
        
        when SHIFT =>
          -- Change state
          state_i <= SUB;
          -- Increment index
          index_i <= index_i + 1;
          -- Shift bits
          p(b'length-1 downto 1) <= p(b'length-2 downto 0);
          p(0) <= a(a'length-1);
          a(a'length-1 downto 1) <= a(a'length-2 downto 0);

        when SUB =>
          -- Change state
          state_i <= INSERT;
          -- Substract
          p <= p - b;

        when INSERT =>
          -- Change state
          if index_i = index_t'right then
            state_i <= CALC_DONE;
          else
            state_i <= SHIFT;
          end if;
          -- Insert bit
          if p(b'left) = '1' then
            a(0) <= '0';
            p <= p + b;
          else
            a(0) <= '1';
          end if;
      
        when CALC_DONE =>
          -- Change state
            state_i <= IDLE;
          -- Set node flag
          done_i <= '1';
          -- Assign result
          quotient_i <= std_logic_vector(a);
      
        when others => 
          state_i <= IDLE;
      end case;
  
    end if;
  end process;

end architecture;


architecture beh of DIVIDER_UNSIGNED is

  -- dividend / divisor = quotient
  function  divide  (dividend : UNSIGNED; divisor : UNSIGNED) return UNSIGNED is
    variable a : unsigned(dividend'range) := dividend;
    variable b : unsigned(divisor'range)  := divisor;
    variable p : unsigned(dividend'length downto 0) := (others => '0');
    
  begin

    for i in 0 to b'length-1 loop
      p(b'length-1 downto 1) := p(b'length-2 downto 0);
      p(0) := a(a'length-1);

      a(a'length-1 downto 1) := a(a'length-2 downto 0);
      p := p - b;

      if p(b'left) = '1' then
        a(0) := '0';
        p := p + b;
      else
        a(0) := '1';
      end if;
    end loop;

    return a;
  end divide;

begin

  -----------------------------------------------------------------------------
  MAIN_PROC : process(CLK, RST)
  begin
    if RST = '1' then
      DONE <= '0';
      QUOTIENT <= (others => '0');
  
    elsif rising_edge(CLK) then
      if START = '1' then
        QUOTIENT <= std_logic_vector(divide(unsigned(DIVIDEND), unsigned(DIVISOR)));
        DONE <= '1';
      end if;
  
    end if;
  end process;

end architecture;
