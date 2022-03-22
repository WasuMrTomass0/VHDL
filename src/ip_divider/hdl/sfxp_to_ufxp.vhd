--------------------------------------------------------------------------------
-- Copyright (c) 2022 Woodward Inc
-- All Rights Reserved
--------------------------------------------------------------------------------
-- File      : sfxp_to_ufxp.vhd
-- Author(s) : Molęda Tomasz
-- Language  : VHDL 1993
--------------------------------------------------------------------------------
-- Description: 
-- Returns absolute value of signed fixed point number in unsigned fixed point format
--------------------------------------------------------------------------------
-- Change History:
-- YYYY/MM/DD  Author         Description
-- 2022/03/18  Molęda Tomasz  Initial Release
--------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;


-----------------------------------------------------------------------------
entity SFXP_TO_UFXP is
  generic (
    DATA_WIDTH_G : natural
  );
  port (
    RST : in std_logic;
    CLK : in std_logic;
    
    SIGN_BIT : out std_logic;
    SFXP : in  std_logic_vector(DATA_WIDTH_G-1 downto 0);
    UFXP : out std_logic_vector(DATA_WIDTH_G-1 downto 0);

    START        : in  std_logic;
    DONE_TRIGGER : out std_logic  -- Only for one clock
  );
  -----------------------------------------------------------------------------
  constant ONE_C : unsigned(UFXP'range) := to_unsigned(1, UFXP'length);

end SFXP_TO_UFXP;


-----------------------------------------------------------------------------
architecture AREA of SFXP_TO_UFXP is
begin
  -----------------------------------------------------------------------------
  -- Concurrent statements
  -----------------------------------------------------------------------------
  SIGN_BIT <= '0' when RST = '1' else SFXP(SFXP'left);
  UFXP <= (others => '0') when RST = '1' else SFXP when SFXP(SFXP'left) = '0' else std_logic_vector(unsigned(not SFXP) + ONE_C);

  ------------------------------------------------------------------------------
  -- Name    : DONE_FLAG_PROC
  -- Purpose : Set done flag on START. Clear on RST
  -- Inputs  : START
  -- Output  : DONE_TRIGGER
  -----------------------------------------------------------------------------
  DONE_FLAG_PROC : process(CLK, RST)
  begin
    if RST = '1' then
      DONE_TRIGGER <= '0';
  
    elsif rising_edge(CLK) then
      if START = '1' then
        DONE_TRIGGER <= '1';
      end if;
  
    end if;
  end process;

end architecture;


-----------------------------------------------------------------------------
architecture FREQ of SFXP_TO_UFXP is
  type state_t is (IDLE, CONVERT, HOLD);
  signal state_i : state_t;

  signal sign_bit_i : std_logic;
  signal ufxp_i    : std_logic_vector(DATA_WIDTH_G-1 downto 0); 
  signal negated_i : std_logic_vector(DATA_WIDTH_G-2 downto 0);

begin
  -----------------------------------------------------------------------------
  -- Concurrent statements
  -----------------------------------------------------------------------------
  sign_bit_i <= SFXP(SFXP'left);
  negated_i <= not SFXP(SFXP'left-1 downto 0);

  ------------------------------------------------------------------------------
  -- Name    : CONVERTION_PROC
  -- Purpose : Converts sfxp to ufxp
  -- Inputs  : 
  -- Output  : 
  -----------------------------------------------------------------------------
  CONVERTION_PROC : process(CLK, RST)
  begin
    if RST = '1' then
      UFXP <= (others => '0');
      DONE_TRIGGER <= '0';
      SIGN_BIT <= '0';

    elsif rising_edge(CLK) then
        case state_i is        
          when IDLE =>
            -- Clear done flag
            DONE_TRIGGER <= '0';
            -- Detect start
            if START = '1' then
              -- Assign sign bit to output
              SIGN_BIT <= sign_bit_i;
              if sign_bit_i = '1' then
                -- Next state
                state_i <= CONVERT;
                -- Negate output
                ufxp_i <= '0' & negated_i;
              else
                -- Next state
                state_i <= HOLD;
              end if;
            end if;

          when CONVERT =>
            -- Next state
            state_i <= IDLE;
            -- Add one
            UFXP <= std_logic_vector(unsigned(ufxp_i) + ONE_C);
            -- Set trigger flag
            DONE_TRIGGER <= '1';
            
          when HOLD =>
            -- Next state
            state_i <= IDLE;
            -- Set trigger flag
            DONE_TRIGGER <= '1';
            -- Assign - it is positive value
            UFXP <= SFXP;

          when others => 
              -- Next state
            state_i <= IDLE;

        end case;

    end if;

  end process;

end architecture;
