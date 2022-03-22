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
use DIVIDER_LIB.DIVIDER_UFXP;
use DIVIDER_LIB.DIVIDER_SFXP;


----------------------------------------------------------------------
entity DIVIDER_FXP_TB is
  generic (
    DIVIDEND_WIDTH_G    : natural := 7;
    DIVIDEND_UFXP_INT_BITS_G : natural := 3;

    DIVISOR_WIDTH_G     : natural := 11;
    DIVISOR_UFXP_INT_BITS_G  : natural := 5;

    runner_cfg    : string   := runner_cfg_default
  );
end DIVIDER_FXP_TB;
----------------------------------------------------------------------

architecture BEH of DIVIDER_FXP_TB is
  -----------------------------------------------------------------------------
  -- Constant declarations
  -----------------------------------------------------------------------------
  constant CLK_PERIOD_C : time := 2 ns;
  -- constant CLK_FREQ_C   : natural := natural(1 sec / CLK_PERIOD_C);  -- Hz

  constant DIVIDENT_FRAC_BITS_C : natural := DIVIDEND_WIDTH_G - DIVIDEND_UFXP_INT_BITS_G;
  constant DIVISOR_FRAC_BITS_C  : natural := DIVISOR_WIDTH_G  - DIVISOR_UFXP_INT_BITS_G;

  constant DIVIDEND_SFXP_INT_BITS_G : natural := DIVIDEND_UFXP_INT_BITS_G - 1;
  constant DIVISOR_SFXP_INT_BITS_G  : natural := DIVISOR_UFXP_INT_BITS_G  - 1;

  constant QUOTIENT_WIDTH_C     : natural := DIVIDEND_WIDTH_G + DIVISOR_WIDTH_G;
  constant QUOTIENT_INT_BITS_C  : natural := DIVIDEND_UFXP_INT_BITS_G + DIVISOR_FRAC_BITS_C;
  constant QUOTIENT_FRAC_BITS_C : natural := DIVIDENT_FRAC_BITS_C + DIVISOR_UFXP_INT_BITS_G;

  -----------------------------------------------------------------------------
  -- Signal declarations
  -----------------------------------------------------------------------------
  signal RST : std_logic := '0';
  signal CLK : std_logic := '0';
  
  signal dut_start, dut_ufxp_done, dut_sfxp_done : std_logic;
  signal dut_dividend : std_logic_vector(DIVIDEND_WIDTH_G-1 downto 0);
  signal dut_divisor  : std_logic_vector(DIVISOR_WIDTH_G-1  downto 0);
  signal dut_ufxp_quotient : std_logic_vector(DIVIDEND_WIDTH_G + DIVISOR_WIDTH_G - 1 downto 0);
  signal dut_sfxp_quotient : std_logic_vector(DIVIDEND_WIDTH_G + DIVISOR_WIDTH_G - 1 downto 0);
  
  -----------------------------------------------------------------------------
  -- Others
  -----------------------------------------------------------------------------
  shared variable cov_divident_ufxp_sv, cov_divisor_ufxp_sv : CovPType;
  shared variable cov_divident_sfxp_sv, cov_divisor_sfxp_sv : CovPType;

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
    variable quotient_ufxp_slv_v : std_logic_vector(dut_ufxp_quotient'range);
    variable quotient_sfxp_slv_v : std_logic_vector(dut_sfxp_quotient'range);

  begin
    -----------------------------------------------------------------------------
    -- VUnit tb settings
    -----------------------------------------------------------------------------
    test_runner_setup(runner, runner_cfg);
    show(display_handler, pass);  -- show passed tests

    ---------------------------------------------------------------------------
    -- Initialization phase
    ---------------------------------------------------------------------------
    cov_divident_ufxp_sv.AddBins(GenBin(0, 2**DIVIDEND_WIDTH_G-1, 57));
    cov_divident_ufxp_sv.AddBins(GenBin(0, 100, 10));
    cov_divisor_ufxp_sv.AddBins(GenBin(0, 20, 10));
    cov_divisor_ufxp_sv.AddBins(GenBin(0, 2**DIVISOR_WIDTH_G-1, 48));

    cov_divident_sfxp_sv.AddBins(GenBin(-2**(DIVIDEND_WIDTH_G-1), 2**(DIVIDEND_WIDTH_G-1)-1, 57));
    cov_divident_sfxp_sv.AddBins(GenBin(-50, 50, 10));
    cov_divisor_sfxp_sv.AddBins(GenBin(-10, 10, 10));
    cov_divisor_sfxp_sv.AddBins(GenBin(-2**(DIVISOR_WIDTH_G-1), 2**(DIVISOR_WIDTH_G-1)-1, 48));
    
    ---------------------------------------------------------------------------
    -- Debug info
    ---------------------------------------------------------------------------
    info("CLK_PERIOD_C = " & to_string(CLK_PERIOD_C), line_num => 126, file_name => "divider_fxp_tb.vhd");

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
        banner_p("T1: Fixed testcase");

        if DIVIDEND_WIDTH_G = 7 and DIVIDEND_UFXP_INT_BITS_G = 3 and DIVISOR_WIDTH_G = 11 and DIVISOR_UFXP_INT_BITS_G = 5 then
          -- Fixed test case
          dividend_slv_v := "1111111";
          divisor_slv_v  := "00000000001";
          info("dividend_slv_v  = " & to_string(dividend_slv_v) & ", x" & to_hstring(dividend_slv_v), line_num => 149, file_name => "divider_fxp_tb.vhd");
          info("divisor_slv_v   = " & to_string(divisor_slv_v)  & ", x" & to_hstring(divisor_slv_v), line_num => 150, file_name => "divider_fxp_tb.vhd");
          
          divident_real_v := to_real(to_ufixed(dividend_slv_v, DIVIDEND_UFXP_INT_BITS_G-1, -DIVIDENT_FRAC_BITS_C));
          divisor_real_v  := to_real(to_ufixed(divisor_slv_v,  DIVISOR_UFXP_INT_BITS_G-1,  -DIVISOR_FRAC_BITS_C));
          info("divident_real_v = " & to_string(divident_real_v), line_num => 154, file_name => "divider_fxp_tb.vhd");
          info("divisor_real_v  = " & to_string(divisor_real_v), line_num => 155, file_name => "divider_fxp_tb.vhd");

          divident_int_v := to_integer(unsigned(dividend_slv_v));
          divisor_int_v  := to_integer(unsigned(divisor_slv_v));
          info("divident_int_v  = " & to_string(divident_int_v), line_num => 159, file_name => "divider_fxp_tb.vhd");
          info("divisor_int_v   = " & to_string(divisor_int_v), line_num => 160, file_name => "divider_fxp_tb.vhd");

          -- Drive to DUT
          dut_dividend  <= dividend_slv_v;
          dut_divisor   <= divisor_slv_v;

          dut_start <= '1';
          wait for CLK_PERIOD_C * 1;
          dut_start <= '0';
          wait for CLK_PERIOD_C * 1;
          wait until dut_ufxp_done = '1';

          -- Show results
          quotient_ufxp_slv_v := dut_ufxp_quotient;
          quotient_real_v  := to_real(to_ufixed(quotient_ufxp_slv_v,  QUOTIENT_INT_BITS_C-1,  -QUOTIENT_FRAC_BITS_C));
          quotient_int_v := to_integer(unsigned(quotient_ufxp_slv_v));

          info("quotient_ufxp_slv_v  = " & to_string(quotient_ufxp_slv_v) & ", x" & to_hstring(quotient_ufxp_slv_v), line_num => 177, file_name => "divider_fxp_tb.vhd");
          info("quotient_real_v = " & to_string(quotient_real_v), line_num => 178, file_name => "divider_fxp_tb.vhd");
          info("quotient_int_v  = " & to_string(quotient_int_v ), line_num => 179, file_name => "divider_fxp_tb.vhd");
          
          quotient_ufxp_slv_v := "111111100000000000";
          check_equal(dut_ufxp_quotient, quotient_ufxp_slv_v, level=>warning, line_num => 182, file_name => "divider_fxp_tb.vhd");

        end if;

        ---------------------------------------------------------------------------
        -- Test:  
        ---------------------------------------------------------------------------
        elsif(run("T2")) then
          banner_p("T2: DUT Unsigned FxP vs IEEE.FixedPointPkg");

          while not cov_divident_ufxp_sv.IsCovered or not cov_divisor_ufxp_sv.IsCovered loop
            divident_int_v := cov_divident_ufxp_sv.RandCovPoint;
            cov_divident_ufxp_sv.ICoverLast;

            divisor_int_v := cov_divisor_ufxp_sv.RandCovPoint;
            cov_divisor_ufxp_sv.ICoverLast;
            
            divident_real_v := real(divident_int_v) / real(2 ** DIVIDENT_FRAC_BITS_C);
            dividend_slv_v := to_slv(to_ufixed(divident_real_v, DIVIDEND_UFXP_INT_BITS_G-1, -DIVIDENT_FRAC_BITS_C));
            info("divident = "&to_string(divident_int_v)&" / 2**"&to_string(DIVIDENT_FRAC_BITS_C)&" = "&to_string(divident_real_v)
              &" = "&to_string(dividend_slv_v)&" = x"&to_hstring(dividend_slv_v), line_num => 201, file_name => "divider_fxp_tb.vhd");

            divisor_real_v := real(divisor_int_v) / real(2 ** DIVISOR_FRAC_BITS_C);
            divisor_slv_v := to_slv(to_ufixed(divisor_real_v, DIVISOR_UFXP_INT_BITS_G-1, -DIVISOR_FRAC_BITS_C));
            info("divisor  = "&to_string(divisor_int_v)&" / 2**"&to_string(DIVISOR_FRAC_BITS_C)&" = "&to_string(divisor_real_v)
              &" = "&to_string(divisor_slv_v)&" = x"&to_hstring(divisor_slv_v), line_num => 206, file_name => "divider_fxp_tb.vhd");

            quotient_int_v  := divident_int_v / divisor_int_v;
            quotient_real_v := divident_real_v / divisor_real_v;
            quotient_ufxp_slv_v := to_slv(to_ufixed(divident_real_v, DIVIDEND_UFXP_INT_BITS_G-1, -DIVIDENT_FRAC_BITS_C) / to_ufixed(divisor_real_v, DIVISOR_UFXP_INT_BITS_G-1, -DIVISOR_FRAC_BITS_C));
            info("quotient = x / 2**"&to_string(QUOTIENT_FRAC_BITS_C)&" = "&to_string(quotient_real_v)
              &" = "&to_string(quotient_ufxp_slv_v)&" = x"&to_hstring(quotient_ufxp_slv_v), line_num => 212, file_name => "divider_fxp_tb.vhd");

            dut_dividend <= dividend_slv_v;
            dut_divisor  <= divisor_slv_v;

            dut_start <= '1';
            wait for CLK_PERIOD_C * 1;
            dut_start <= '0';
            wait for CLK_PERIOD_C * 1;
            wait until dut_ufxp_done = '1';

            check_equal(dut_ufxp_quotient, quotient_ufxp_slv_v, level=>warning, line_num => 224, file_name => "divider_fxp_tb.vhd");

            wait for CLK_PERIOD_C * 2;

          end loop;
        
        ---------------------------------------------------------------------------
        -- Test:  
        ---------------------------------------------------------------------------
        elsif(run("T3")) then
          banner_p("T3: DUT Signed FxP vs IEEE.FixedPointPkg");

          while not cov_divident_sfxp_sv.IsCovered or not cov_divisor_sfxp_sv.IsCovered loop
            divident_int_v := cov_divident_sfxp_sv.RandCovPoint;
            cov_divident_sfxp_sv.ICoverLast;  

            divisor_int_v := cov_divisor_sfxp_sv.RandCovPoint;
            cov_divisor_sfxp_sv.ICoverLast;
            
            divident_real_v := real(divident_int_v) / real(2 ** DIVIDENT_FRAC_BITS_C);
            dividend_slv_v := to_slv(to_sfixed(divident_real_v, DIVIDEND_SFXP_INT_BITS_G, -DIVIDENT_FRAC_BITS_C));
            info("divident = "&to_string(divident_int_v)&" / 2**"&to_string(DIVIDENT_FRAC_BITS_C)&" = "&to_string(divident_real_v)
              &" = "&to_string(dividend_slv_v)&" = x"&to_hstring(dividend_slv_v), line_num => 245, file_name => "divider_fxp_tb.vhd");

            divisor_real_v := real(divisor_int_v) / real(2 ** DIVISOR_FRAC_BITS_C);
            divisor_slv_v := to_slv(to_sfixed(divisor_real_v, DIVISOR_SFXP_INT_BITS_G, -DIVISOR_FRAC_BITS_C));
            info("divisor  = "&to_string(divisor_int_v)&" / 2**"&to_string(DIVISOR_FRAC_BITS_C)&" = "&to_string(divisor_real_v)
              &" = "&to_string(divisor_slv_v)&" = x"&to_hstring(divisor_slv_v), line_num => 250, file_name => "divider_fxp_tb.vhd");

            quotient_int_v  := divident_int_v / divisor_int_v;
            quotient_real_v := divident_real_v / divisor_real_v;
            quotient_ufxp_slv_v := to_slv(to_sfixed(divident_real_v, DIVIDEND_SFXP_INT_BITS_G, -DIVIDENT_FRAC_BITS_C) / to_sfixed(divisor_real_v, DIVISOR_SFXP_INT_BITS_G, -DIVISOR_FRAC_BITS_C));
            info("quotient = x / 2**"&to_string(QUOTIENT_FRAC_BITS_C)&" = "&to_string(quotient_real_v)
              &" = "&to_string(quotient_ufxp_slv_v)&" = x"&to_hstring(quotient_ufxp_slv_v), line_num => 256, file_name => "divider_fxp_tb.vhd");

            dut_dividend <= dividend_slv_v;
            dut_divisor  <= divisor_slv_v;

            dut_start <= '1';
            wait for CLK_PERIOD_C * 1;
            dut_start <= '0';
            wait for CLK_PERIOD_C * 1;
            wait until dut_ufxp_done = '1';

            check_equal(dut_ufxp_quotient, quotient_ufxp_slv_v, level=>warning, line_num => 268, file_name => "divider_fxp_tb.vhd");

            wait for CLK_PERIOD_C * 2;

          end loop;

      ---------------------------------------------------------------------------
      end if;

    end loop TEST_CASES_LOOP;

    -----------------------------------------------------------------------------
    -- Summary
    -----------------------------------------------------------------------------
    wait for CLK_PERIOD_C;
    check_equal(get_checker_stat.n_failed, 0, "Number of failed tests", error, line_num => 283, file_name => "divider_fxp_tb.vhd");
    info(to_string(get_checker_stat), line_num => 284, file_name => "divider_fxp_tb.vhd");
    info(" ", line_num => 285, file_name => "divider_fxp_tb.vhd");
    info("*** End of Simulation ***", line_num => 286, file_name => "divider_fxp_tb.vhd");
    test_runner_cleanup(runner);
  end process;



  ---------------------------------------------------------------------------
  -- DUT_UFXP
  ---------------------------------------------------------------------------
  DUT_UFXP : entity DIVIDER_UFXP(RTL)
    generic map (
      DIVIDEND_INT_BITS_G => DIVIDEND_UFXP_INT_BITS_G,
      DIVISOR_INT_BITS_G => DIVISOR_UFXP_INT_BITS_G
    )
    port map (
      RST => RST,
      CLK => CLK,

      DIVIDEND => dut_dividend,  -- in
      DIVISOR  => dut_divisor,   -- in
      QUOTIENT => dut_ufxp_quotient,  -- out

      START => dut_start,        -- in
      DONE  => dut_ufxp_done          -- out
    );
  
    
  -- ---------------------------------------------------------------------------
  -- -- DUT_SFXP
  -- ---------------------------------------------------------------------------
  -- DUT_SFXP : entity DIVIDER_SFXP(RTL)
  -- generic map (
  --   DIVIDEND_INT_BITS_G => DIVIDEND_SFXP_INT_BITS_G,
  --   DIVISOR_INT_BITS_G  => DIVISOR_SFXP_INT_BITS_G
  -- )
  -- port map (
  --   RST => RST,
  --   CLK => CLK,

  --   DIVIDEND => dut_dividend,  -- in
  --   DIVISOR  => dut_divisor,   -- in
  --   QUOTIENT => dut_sfxp_quotient,  -- out

  --   START => dut_start,        -- in
  --   DONE  => dut_sfxp_done     -- out
  -- );

end BEH;