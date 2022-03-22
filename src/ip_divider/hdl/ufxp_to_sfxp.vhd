--------------------------------------------------------------------------------
-- Copyright (c) 2022 Woodward Inc
-- All Rights Reserved
--------------------------------------------------------------------------------
-- File      : ufxp_to_sfxp.vhd
-- Author(s) : Molęda Tomasz
-- Language  : VHDL 1993
--------------------------------------------------------------------------------
-- Description: 
-- Convert unsigned fixed point number to signed fixed point
--------------------------------------------------------------------------------
-- Change History:
-- YYYY/MM/DD  Author         Description
-- 2022/03/18  Molęda Tomasz  Initial Release
--------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;


-----------------------------------------------------------------------------
entity UFXP_TO_SFXP is
  generic (
    DATA_WIDTH_G : natural
  );
  port (
    RST : in std_logic;
    CLK : in std_logic;
    
    SIGN_BIT : in std_logic;
    UFXP : in std_logic_vector(DATA_WIDTH_G-1 downto 0);
    SFXP : out  std_logic_vector(DATA_WIDTH_G downto 0);

    START        : in  std_logic;
    DONE_TRIGGER : out std_logic  -- Only for one clock
  );
  -----------------------------------------------------------------------------
  constant ONE_C : unsigned(UFXP'range) := to_unsigned(1, UFXP'length);
  
end UFXP_TO_SFXP;


-----------------------------------------------------------------------------
architecture AREA of UFXP_TO_SFXP is
  signal pos_i, neg_i : std_logic_vector(SFXP'range);
begin
  -----------------------------------------------------------------------------
  -- Concurrent statements
  -----------------------------------------------------------------------------
  pos_i <= '0' & UFXP;
  neg_i <= '1' & std_logic_vector(unsigned(not UFXP) + ONE_C);

  SFXP <= (others => '0') when RST = '1' else pos_i when SIGN_BIT = '0' else neg_i;

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
architecture FREQ of UFXP_TO_SFXP is
  type state_t is (IDLE, CONVERT, HOLD);
  signal state_i : state_t;

  signal sfxp_i    : std_logic_vector(DATA_WIDTH_G downto 0); 
  signal negated_i : std_logic_vector(DATA_WIDTH_G-1 downto 0);


begin
  -----------------------------------------------------------------------------
  -- Concurrent statements
  -----------------------------------------------------------------------------
  negated_i <= not UFXP;

  ------------------------------------------------------------------------------
  -- Name    : CONVERTION_PROC
  -- Purpose : 
  -- Inputs  : 
  -- Output  : 
  -----------------------------------------------------------------------------
  CONVERTION_PROC : process(CLK, RST)
  begin
    if RST = '1' then
      SFXP <= (others => '0');
      DONE_TRIGGER <= '0';

    elsif rising_edge(CLK) then
        case state_i is        
          when IDLE =>
            -- Clear done flag
            DONE_TRIGGER <= '0';
            -- Detect start
            if START = '1' then
              if SIGN_BIT = '1' then
                -- Next state
                state_i <= CONVERT;
                -- Negate output
                sfxp_i <= '1' & negated_i;
              else
                -- Next state
                state_i <= HOLD;
              end if;
            end if;

          when CONVERT =>
            -- Next state
            state_i <= IDLE;
            -- Add one
            SFXP <= std_logic_vector(unsigned(sfxp_i) + ONE_C);
            -- Set trigger flag
            DONE_TRIGGER <= '1';
            
          when HOLD =>
            -- Next state
            state_i <= IDLE;
            -- Set trigger flag
            DONE_TRIGGER <= '1';
            -- Assign - it is positive value
            SFXP <= UFXP;

          when others => 
              -- Next state
            state_i <= IDLE;

        end case;

    end if;

  end process;

end architecture;
