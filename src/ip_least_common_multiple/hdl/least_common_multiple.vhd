--------------------------------------------------------------------------------
-- Copyright (c) 2022 Woodward Inc
-- All Rights Reserved
--------------------------------------------------------------------------------
-- File      : least_common_multiple.vhd
-- Author(s) : Molęda Tomasz
-- Language  : VHDL 1993
--------------------------------------------------------------------------------
-- Description: 
-- Least common multiple module
--------------------------------------------------------------------------------
-- Change History:
-- YYYY/MM/DD  Author         Description
-- 2022/03/13  Molęda Tomasz  Initial Release
--------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;


-----------------------------------------------------------------------------
entity LEAST_COMMON_MULTIPLE is
  generic (
    DATA_TYPE_G  : string;  -- signed|unsigned|invalid
    DATA_WIDTH_G : natural
  );
  port (
    RST : in std_logic;
    CLK : in std_logic;
    
    M   : in std_logic_vector(DATA_WIDTH_G-1 downto 0);
    N   : in std_logic_vector(DATA_WIDTH_G-1 downto 0);
    LCM : out std_logic_vector(2*DATA_WIDTH_G-1 downto 0);

    START  : in std_logic;
    READY  : in std_logic
  );
end LEAST_COMMON_MULTIPLE;


-----------------------------------------------------------------------------
architecture RTL of LEAST_COMMON_MULTIPLE is
  type state_t is (IDLE, OP);
  signal state_i, next_state_i : state_t;

  signal a_i, next_a_i    : unsigned(LCM'range);
  signal b_i, next_b_i    : unsigned(LCM'range);
  signal add_a_i, add_b_i : unsigned(LCM'range);

  constant ZEROS_C : std_logic_vector(LCM'length - M'length - 1 downto 0) := (others => '0');

begin
  -----------------------------------------------------------------------------
  -- Concurrent statements
  -----------------------------------------------------------------------------
  READY <= '1' when state_i = IDLE else '0';

  ------------------------------------------------------------------------------
  -- Name    : NEXT_STATE_PROC
  -- Purpose : Apply next_state_i to state_i signal. (Control path)
  -- Inputs  : next_state_i
  -- Output  : signal
  -----------------------------------------------------------------------------
  NEXT_STATE_PROC : process(CLK, RST)
  begin
    if RST = '1' then
      state_i <= IDLE;
  
    elsif rising_edge(CLK) then
      state_i <= next_state_i;
  
    end if;
  end process;

  ------------------------------------------------------------------------------
  -- Name    : STATE_SELECT_PROC
  -- Purpose : Select next state. (Control path)
  -- Inputs  : START, M, N, add_a_i, add_b_i
  -- Output  : next_state_i
  -----------------------------------------------------------------------------
  STATE_SELECT_PROC : process(START, M, N, add_a_i, add_b_i)
  begin
    case state_i is

      when IDLE =>
        if START = '1' then
          if M = N then
            next_state_i <= IDLE;
          else
            next_state_i <= OP;
          end if;
        else
          next_state_i <= IDLE;
        end if;

      when OP =>
        if add_a_i = add_b_i then
          next_state_i <= IDLE;
        else
          next_state_i <= OP;
        end if;
    
    end case;
  end process;

  ------------------------------------------------------------------------------
  -- Name    : AB_NEXT_PROC
  -- Purpose : Drives next_(a|b)_i values to (a|b)_i signals. (Data path)
  -- Inputs  : next_a_i, next_b_i
  -- Output  : a_i, b_i
  -----------------------------------------------------------------------------
  AB_NEXT_PROC : process(CLK, RST)
  begin
    if RST = '1' then
      a_i <= (others => '0');
      b_i <= (others => '0');
  
    elsif rising_edge(CLK) then
      a_i <= next_a_i;
      b_i <= next_b_i;
  
    end if;
  end process;

  ------------------------------------------------------------------------------
  -- Name    : MUX_AB_PROC
  -- Purpose : Multiplexing a and b registers. (Data path)
  -- Inputs  : 
  -- Output  : 
  -----------------------------------------------------------------------------
  MUX_AB_PROC : process( )
  begin
    case state_i is
      when IDLE =>
        next_a_i <= unsigned(ZEROS_C & M);
        next_b_i <= unsigned(ZEROS_C & N);

      when OP =>

        if a_i > b_i then
          
        else
          
        end if;
    
    end case;
  end process;


end architecture;
