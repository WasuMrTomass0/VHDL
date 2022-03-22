library STD;
use STD.STANDARD.all;

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

-- VUnit
library VUNIT_LIB;
context VUNIT_LIB.VUNIT_CONTEXT;
context VUNIT_LIB.VC_CONTEXT;

-- OSVVM
-- library OSVVM;
-- use OSVVM.CoveragePkg.all;

-- Files
-- use STD.TEXTIO.all;

-- DUT and models
library DIVIDER_LIB;
use DIVIDER_LIB.DIVIDER_BY_CONST;

----------------------------------------------------------------------
entity divider_by_const_tb is
  generic (
    runner_cfg    : string   := runner_cfg_default;

    FACTOR_VALUE_G  : integer := 0;
    -- If factor is set to 0 then two below generics are used to calculate factor
    DIVIDER_VALUE_G : integer := 7;
    NUM_OF_BITS_G   : natural := 8;

    DATA_TYPE_G  : string := "unsigned";  -- unsigned|signed
    DATA_WIDTH_G : natural := 16
  );
end divider_by_const_tb;
----------------------------------------------------------------------

architecture beh of divider_by_const_tb is
  -- Simulation constants
  constant CLK_PERIOD_C : time      := 2 ns;

  -- Signals
  signal RST : std_logic := '0';
  signal EN  : std_logic := '1';
  signal CLK : std_logic := '0';
  
  signal dut_dividend     : std_logic_vector(DATA_WIDTH_G-1 downto 0);
  signal dut_quotient     : std_logic_vector(DATA_WIDTH_G-1 downto 0);
 
  -- Other
  
  function divide_alg_f(divident : integer) return integer is
    variable factor_v, result_v, modulo_v : integer;
    constant POWER_OF_TWO_C : integer := 2**NUM_OF_BITS_G;
  begin
    if FACTOR_VALUE_G /= 0 then
      factor_v := FACTOR_VALUE_G;

    elsif DIVIDER_VALUE_G /= 0 then
      factor_v := POWER_OF_TWO_C / DIVIDER_VALUE_G;

    else
      assert false
        report "Invalid generic values. One of them must be non zero -> FACTOR_VALUE_G ("&to_string(FACTOR_VALUE_G)&"), DIVIDER_VALUE_G ("&to_string(DIVIDER_VALUE_G)&")"
        severity failure;  -- note, warning, error, failure
    end if;

    result_v := divident * factor_v;
    modulo_v := result_v mod POWER_OF_TWO_C;
    result_v := result_v / POWER_OF_TWO_C;

    if modulo_v >= POWER_OF_TWO_C / 2 then
      result_v := result_v + 1;
    end if;

    return result_v;

  end function;

begin
  ---------------------------------------------------------------------------
  CLK <= not CLK after CLK_PERIOD_C / 2.0;
  
  ---------------------------------------------------------------------------
  SIMULATION_PROC : process is    
    variable loop_max_v, mod_val_v, nhood_v, divider_value_v, max_accepted_val_v : integer;
  begin
    test_runner_setup(runner, runner_cfg);
    show(display_handler, pass);  -- show passed tests
    -----------------------------------------------------------------------------
    -- Generics
    info("FACTOR_VALUE_G  = " & to_string(FACTOR_VALUE_G));
    info("DIVIDER_VALUE_G = " & to_string(DIVIDER_VALUE_G));
    info("NUM_OF_BITS_G - = " & to_string(NUM_OF_BITS_G));
    info("DATA_TYPE_G --- = " & to_string(DATA_TYPE_G));
    info("DATA_WIDTH_G -- = " & to_string(DATA_WIDTH_G));
    
    if DATA_TYPE_G = "signed" then
      max_accepted_val_v := 2**(DATA_WIDTH_G-1)-1;
    elsif DATA_TYPE_G = "unsigned" then
      max_accepted_val_v := 2**DATA_WIDTH_G-1;
    else
      assert false
        report "Invalid data type. Use unsigned or signed. Got " & DATA_TYPE_G
        severity failure;
    end if;
    
    ---------------------------------------------------------------------------
    -- Initialization phase:
    ---------------------------------------------------------------------------
    RST <= '1';
    wait until falling_edge(CLK);
    RST <= '0';
    EN  <= '1';
  
    TEST_CASES_LOOP : while test_suite loop
      ---------------------------------------------------------------------------
      -- Test:
      ---------------------------------------------------------------------------
      if (run("T1")) then
        info("T1");
        
        if DIVIDER_VALUE_G /= 0 and FACTOR_VALUE_G = 0 then
          loop_max_v := 4*DIVIDER_VALUE_G;
          divider_value_v := DIVIDER_VALUE_G;
          
        elsif DIVIDER_VALUE_G = 0 and FACTOR_VALUE_G /= 0 then
          divider_value_v := (2**NUM_OF_BITS_G) / FACTOR_VALUE_G;
          loop_max_v := 2 * divider_value_v;

        elsif DIVIDER_VALUE_G /= 0 and FACTOR_VALUE_G /= 0 then
          loop_max_v := 4*DIVIDER_VALUE_G;
          divider_value_v := DIVIDER_VALUE_G;

        else
          assert false
            report "Invalid generic values. One of them must be non zero -> FACTOR_VALUE_G ("&to_string(FACTOR_VALUE_G)&"), DIVIDER_VALUE_G ("&to_string(DIVIDER_VALUE_G)&")"
            severity failure;  -- note, warning, error, failure
        end if;
        
        -- Limit
        if loop_max_v >= max_accepted_val_v then
          loop_max_v := max_accepted_val_v;
        end if;

        info("loop_max_v ---- = " & to_string(loop_max_v));
        info("divider_value_v = " & to_string(divider_value_v));

        nhood_v := 3;
        for i in 0 to loop_max_v loop
          mod_val_v := i mod divider_value_v;

          if mod_val_v <= nhood_v or mod_val_v >= divider_value_v-nhood_v or (mod_val_v >= divider_value_v/2-nhood_v and mod_val_v <= divider_value_v/2+nhood_v) then
            if DATA_TYPE_G = "signed" then
              dut_dividend <= std_logic_vector(to_signed(i, dut_dividend'length));
              wait for CLK_PERIOD_C;
              check_equal(to_integer(signed(dut_quotient)), divide_alg_f(i), to_string(i)&"/"&to_string(divider_value_v)&"=", warning);

            elsif DATA_TYPE_G = "unsigned" then
              dut_dividend <= std_logic_vector(to_unsigned(i, dut_dividend'length));
              wait for CLK_PERIOD_C;
              check_equal(to_integer(unsigned(dut_quotient)), divide_alg_f(i), to_string(i)&"/"&to_string(divider_value_v)&"=", warning);
              
            end if;
          end if;
        end loop;

      ---------------------------------------------------------------------------
      -- Test:
      ---------------------------------------------------------------------------
      -- elsif(run("T2")) then
      --   info("Info T2");
      
      ---------------------------------------------------------------------------
      end if;

    end loop TEST_CASES_LOOP;
        
    wait for CLK_PERIOD_C;
    check_equal(get_checker_stat.n_failed, 0, "Number of failed tests", error);
    info(to_string(get_checker_stat));
    info(" ");
    info("*** End of Simulation ***");
    test_runner_cleanup(runner);
  end process;

  ---------------------------------------------------------------------------
  -- DUT
  ---------------------------------------------------------------------------
  DUT : entity divider_by_const(rtl)
    generic map (
      DATA_TYPE_G  => DATA_TYPE_G,
      DATA_WIDTH_G => DATA_WIDTH_G,
      FACTOR_VALUE_G  => FACTOR_VALUE_G,
      DIVIDER_VALUE_G => DIVIDER_VALUE_G,
      NUM_OF_BITS_G   => NUM_OF_BITS_G
    )
    port map (
      RST        => RST,
      EN         => EN,
      CLK        => CLK,

      DIVIDEND   => dut_dividend,
      QUOTIENT   => dut_quotient
    );

end beh;