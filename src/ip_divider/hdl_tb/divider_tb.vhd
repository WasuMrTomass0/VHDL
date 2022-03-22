library STD;
use STD.TEXTIO.all;
use STD.STANDARD.all;
-- use STD.TEXTIO.all;

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;
-- use IEEE.STD_LOGIC_TEXTIO.all;
-- use IEEE.STD_LOGIC_ARITH.all;
-- use IEEE.NUMERIC_BIT.all;
-- use IEEE.STD_LOGIC_SIGNED.all;
-- use IEEE.STD_LOGIC_UNSIGNED.all;
-- use IEEE.MATH_REAL.all;
-- use IEEE.MATH_COMPLEX.all;

library VUNIT_LIB;
context VUNIT_LIB.VUNIT_CONTEXT;
context VUNIT_LIB.VC_CONTEXT;

library COMMON_TB_LIB;
use COMMON_TB_LIB.COMMON_TB_PKG.all;
use COMMON_TB_LIB.FIXED_TRUNC_PKG.all;

library OSVVM;
use OSVVM.CoveragePkg.all;

-- DUT and models
library DIVIDER_LIB;
use DIVIDER_LIB.DIVIDER;


----------------------------------------------------------------------
entity DIVIDER_TB is
  generic (
    DATA_TYPE_G         : string;   -- signed|unsigned|invalid
    DIVIDEND_WIDTH_G    : natural;
    DIVIDEND_INT_BITS_G : natural;  -- Fixed point format of divident
    DIVISOR_WIDTH_G     : natural;
    DIVISOR_INT_BITS_G  : natural;  -- Fixed point format of divisor
    runner_cfg : string := runner_cfg_default
  );
end DIVIDER_TB;
----------------------------------------------------------------------

architecture BEH of DIVIDER_TB is
  -----------------------------------------------------------------------------
  -- Constant declarations
  -----------------------------------------------------------------------------
  constant CLK_PERIOD_C : time := 2 ns;

  -----------------------------------------------------------------------------
  -- Signal declarations
  -----------------------------------------------------------------------------
  signal RST : std_logic := '0';
  signal EN  : std_logic := '1';
  signal CLK : std_logic := '0';

  signal dut_start, dut_done : std_logic;
  signal dut_dividend : std_logic_vector(DIVIDEND_WIDTH_G-1 downto 0);
  signal dut_divisor  : std_logic_vector(DIVISOR_WIDTH_G-1 downto 0);
  signal dut_quotient : std_logic_vector(DIVIDEND_WIDTH_G+DIVISOR_WIDTH_G-1 downto 0);

  -----------------------------------------------------------------------------
  -- Others
  -----------------------------------------------------------------------------
  shared variable cov_divident_sv, cov_divisor_sv : CovPType;

  -----------------------------------------------------------------------------
  -- Functions
  -----------------------------------------------------------------------------
  function real_to_slv_f( value : real; int : integer; len : integer) 
    return std_logic_vector is
  begin

    if DATA_TYPE_G = "signed" then
      return to_slv(to_sfixed(value, int, -(len - 1 - int) ) );
    elsif DATA_TYPE_G = "unsigned" then
      return to_slv(to_ufixed(value, int, -(len - int) ) );
    end if;

  end function;
  -----------------------------------------------------------------------------

begin
  -----------------------------------------------------------------------------
  -- Concurrent statements
  -----------------------------------------------------------------------------
  CLK <= not CLK after CLK_PERIOD_C / 2.0;



  ------------------------------------------------------------------------------
  -- Name    : SIMULATION_PROC
  -- Purpose : Simulates DUT with test cases
  ------------------------------------------------------------------------------
  SIMULATION_PROC : process is
    variable divisor_int_v,  divident_int_v,  quotient_int_v  : integer;
    variable divisor_real_v, divident_real_v, quotient_real_v : real;
    variable dividend_slv_v : std_logic_vector(dut_dividend'range);
    variable divisor_slv_v  : std_logic_vector(dut_divisor'range);
    variable quotient_slv_v : std_logic_vector(dut_quotient'range);

    variable max_v, min_v, num_bins_v : integer;
  begin
    -----------------------------------------------------------------------------
    -- VUnit tb settings
    -----------------------------------------------------------------------------
    test_runner_setup(runner, runner_cfg);
    show(display_handler, pass);  -- show passed tests

    ---------------------------------------------------------------------------
    -- Initialization phase
    ---------------------------------------------------------------------------
    if DATA_TYPE_G = "signed" then
      max_v :=   2 ** (DIVIDEND_WIDTH_G-1) - 1;
      min_v := - 2 ** (DIVIDEND_WIDTH_G-1);
    elsif DATA_TYPE_G = "unsigned" then
      max_v := 2 ** DIVIDEND_WIDTH_G - 1;
      min_v := 0;
    end if;
    -- Add bins
    num_bins_v := 22;
    cov_divident_sv.AddBins(GenBin(min_v, max_v, num_bins_v));

    if DATA_TYPE_G = "signed" then
      max_v :=   2 ** (DIVISOR_WIDTH_G-1) - 1;
      min_v := - 2 ** (DIVISOR_WIDTH_G-1);
    elsif DATA_TYPE_G = "unsigned" then
      max_v := 2 ** DIVISOR_WIDTH_G - 1;
      min_v := 0;
    end if;
    -- Add bins
    num_bins_v := num_bins_v + 3;
    cov_divisor_sv.AddBins(GenBin(min_v, max_v, num_bins_v));

    ---------------------------------------------------------------------------
    -- Debug info
    ---------------------------------------------------------------------------
    info("CLK_PERIOD_C = " & to_string(CLK_PERIOD_C));

    -----------------------------------------------------------------------------
    -- Reset module
    -----------------------------------------------------------------------------
    RST <= '1';
    wait until rising_edge(CLK);
    RST <= '0';


    -----------------------------------------------------------------------------
    -----------------------------------------------------------------------------
    TEST_CASES_LOOP : while test_suite loop
      ---------------------------------------------------------------------------
      -- Test:
      ---------------------------------------------------------------------------
      if (run("T1")) then
        banner_p("T1");

        while not cov_divident_sv.IsCovered or not cov_divisor_sv.IsCovered loop
          divident_int_v := cov_divident_sv.RandCovPoint;
          cov_divident_sv.ICoverLast;

          divisor_int_v := cov_divisor_sv.RandCovPoint;
          cov_divisor_sv.ICoverLast;
          
          divident_real_v := real(divident_int_v) / real(2 ** DIVIDENT_FRAC_BITS_C);
          dividend_slv_v := real_to_slv_f(divident_real_v, DIVIDEND_INT_BITS_G, dividend_slv_v'length);
          info("divident = "&to_string(divident_int_v)&" / 2**"&to_string(DIVIDENT_FRAC_BITS_C)&" = "&to_string(divident_real_v)
            &" = "&to_string(dividend_slv_v)&" = x"&to_hstring(dividend_slv_v));

          divisor_real_v := real(divisor_int_v) / real(2 ** DIVISOR_FRAC_BITS_C);
          divisor_slv_v := real_to_slv_f(divisor_real_v, DIVISOR_INT_BITS_G, divisor_slv_v'length);
          info("divisor  = "&to_string(divisor_int_v)&" / 2**"&to_string(DIVISOR_FRAC_BITS_C)&" = "&to_string(divisor_real_v)
            &" = "&to_string(divisor_slv_v)&" = x"&to_hstring(divisor_slv_v));

          quotient_int_v  := divident_int_v / divisor_int_v;
          quotient_real_v := divident_real_v / divisor_real_v;
          quotient_slv_v := to_slv(to_ufixed(divident_real_v, DIVIDEND_INT_BITS_G-1, -DIVIDENT_FRAC_BITS_C) / to_ufixed(divisor_real_v, DIVISOR_INT_BITS_G-1, -DIVISOR_FRAC_BITS_C));
          info("quotient = x / 2**"&to_string(QUOTIENT_FRAC_BITS_C)&" = "&to_string(quotient_real_v)
            &" = "&to_string(quotient_slv_v)&" = x"&to_hstring(quotient_slv_v));

          dut_dividend <= dividend_slv_v;
          dut_divisor  <= divisor_slv_v;

          dut_start <= '1';
          wait for CLK_PERIOD_C * 1;
          dut_start <= '0';
          wait for CLK_PERIOD_C * 1;
          wait until dut_done = '1';

          check_equal(dut_quotient, quotient_slv_v, level=>warning);

          wait for CLK_PERIOD_C * 2;

        end loop;


      ---------------------------------------------------------------------------
      end if;

    end loop TEST_CASES_LOOP;


    -----------------------------------------------------------------------------
    -- Summary
    -----------------------------------------------------------------------------
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
  DUT : entity DIVIDER(RTL)
  generic map (
    DATA_TYPE_G => DATA_TYPE_G,
    DIVIDEND_INT_BITS_G => DIVIDEND_INT_BITS_G,
    DIVISOR_INT_BITS_G  => DIVISOR_INT_BITS_G
  )
  port map (
    RST => RST,
    CLK => CLK,

    DIVIDEND => dut_dividend,  -- in
    DIVISOR  => dut_divisor,   -- in
    QUOTIENT => dut_quotient,  -- out

    START => dut_start,  -- in
    DONE  => dut_done    -- out
  );

end BEH;