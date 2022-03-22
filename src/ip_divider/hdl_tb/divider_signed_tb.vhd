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
use DIVIDER_LIB.DIVIDER_SIGNED;


----------------------------------------------------------------------
entity DIVIDER_SIGNED_TB is
  generic (
    DATA_WIDTH_G : natural := 16;
    runner_cfg : string := runner_cfg_default
  );
end DIVIDER_SIGNED_TB;
----------------------------------------------------------------------

architecture BEH of DIVIDER_SIGNED_TB is
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
  
  -- signal dut_ : std_logic;
  -- signal dut_ : std_logic_vector(DATA_WIDTH_G-1 downto 0);
  signal dut_dividend : std_logic_vector(DATA_WIDTH_G-1 downto 0);
  signal dut_divisor  : std_logic_vector(DATA_WIDTH_G-1 downto 0);
  signal dut_quotient : std_logic_vector(DATA_WIDTH_G-1 downto 0);
  signal dut_start : std_logic;
  signal dut_done  : std_logic;
  
  -----------------------------------------------------------------------------
  -- Others
  -----------------------------------------------------------------------------
  shared variable cov_divident_sv, cov_divisor_sv : CovPType;

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
    variable divisor_v, divident_v, quotient_v : integer;
  begin
    -----------------------------------------------------------------------------
    -- VUnit tb settings
    -----------------------------------------------------------------------------
    test_runner_setup(runner, runner_cfg);
    show(display_handler, pass);  -- show passed tests

    ---------------------------------------------------------------------------
    -- Initialization phase
    ---------------------------------------------------------------------------
    cov_divident_sv.AddBins(GenBin(-2**(DATA_WIDTH_G-1), 2**(DATA_WIDTH_G-1)-1, 50));
    cov_divisor_sv.AddBins(GenBin(-250, 100, 50));

    
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
    EN  <= '1';
  

    -----------------------------------------------------------------------------
    -----------------------------------------------------------------------------
    TEST_CASES_LOOP : while test_suite loop
      ---------------------------------------------------------------------------
      -- Test:  
      ---------------------------------------------------------------------------
      if (run("T1")) then
        banner_p("T1");
        
        while not cov_divident_sv.IsCovered loop    
          divident_v := cov_divident_sv.RandCovPoint;
          cov_divident_sv.ICoverLast;  

          divisor_v := cov_divisor_sv.RandCovPoint;
          cov_divisor_sv.ICoverLast;
          
          quotient_v := divident_v / divisor_v; 
          
          dut_dividend <= std_logic_vector(to_signed(divident_v, dut_dividend'length));
          dut_divisor  <= std_logic_vector(to_signed(divisor_v, dut_divisor'length));
          dut_start <= '1';
          wait for CLK_PERIOD_C * 1;
          
          dut_start <= '0';
          wait for CLK_PERIOD_C * 1;
          wait until dut_done = '1';

          check_equal(signed(dut_quotient), quotient_v,       "Quotient "&to_string(divident_v)&"/"&to_string(divisor_v), warning);
          -- check_equal(dut_quotient, dut_beh_quotient, "Quotient "&to_string(divident_v)&"/"&to_string(divisor_v)&" BEH", warning);

          wait for CLK_PERIOD_C * 2;

        end loop;


      ---------------------------------------------------------------------------
      -- Test:  
      ---------------------------------------------------------------------------
      -- elsif(run("T2")) then
      --   banner_p("T2");
        

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
  DUT : entity DIVIDER_SIGNED(RTL)
  generic map (
    DATA_WIDTH_G => DATA_WIDTH_G
  )
  port map (
    RST => RST,
    CLK => CLK,

    DIVIDEND => dut_dividend,
    DIVISOR  => dut_divisor,
    QUOTIENT => dut_quotient,
    START => dut_start,
    DONE  => dut_done
  );

end BEH;