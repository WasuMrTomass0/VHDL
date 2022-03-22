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
library OSVVM;
use OSVVM.CoveragePkg.all;

-- Files
-- use STD.TEXTIO.all;

-- DUT and models
library DIVIDER_LIB;
use DIVIDER_LIB.DIVIDER_UNSIGNED;

----------------------------------------------------------------------
entity divider_unsigned_tb is
  generic (
    runner_cfg   : string  := runner_cfg_default;
    DATA_WIDTH_G : natural := 16
  );
end divider_unsigned_tb;
----------------------------------------------------------------------

architecture beh of divider_unsigned_tb is
  -- Simulation constants
  constant CLK_PERIOD_C : time      := 2 ns;

  -- Signals
  signal RST : std_logic := '0';
  signal CLK : std_logic := '0';
  
  signal dut_dividend     : std_logic_vector(DATA_WIDTH_G-1 downto 0);
  signal dut_divisor      : std_logic_vector(DATA_WIDTH_G-1 downto 0);
  signal dut_quotient     : std_logic_vector(DATA_WIDTH_G-1 downto 0);
  signal dut_beh_quotient : std_logic_vector(DATA_WIDTH_G-1 downto 0);
  
  signal dut_start    : std_logic;
  signal dut_done     : std_logic;
  signal dut_beh_done : std_logic;
 
  -- Other
  shared variable cov_divident_sv, cov_divisor_sv : CovPType;

begin
  ---------------------------------------------------------------------------
  CLK <= not CLK after CLK_PERIOD_C / 2.0;
  
  ---------------------------------------------------------------------------
  SIMULATION_PROC : process is    
    variable divisor_v, divident_v, quotient_v : integer;
  begin
    test_runner_setup(runner, runner_cfg);
    show(display_handler, pass);  -- show passed tests
    -----------------------------------------------------------------------------
    cov_divident_sv.AddBins(GenBin(0, 2**DATA_WIDTH_G-1, 50));
    cov_divisor_sv.AddBins(GenBin(0, 100, 50));
    
    ---------------------------------------------------------------------------
    -- Initialization phase:
    ---------------------------------------------------------------------------
    RST <= '1';
    wait until rising_edge(CLK);
    RST <= '0';
  
    TEST_CASES_LOOP : while test_suite loop
      ---------------------------------------------------------------------------
      -- Test:
      ---------------------------------------------------------------------------
      if (run("T1")) then
        info("T1", line_num => 79, file_name => "divider_unsigned_tb.vhd");
        
        while not cov_divident_sv.IsCovered loop    
          divident_v := cov_divident_sv.RandCovPoint;
          cov_divident_sv.ICoverLast;  

          divisor_v := cov_divisor_sv.RandCovPoint;
          cov_divisor_sv.ICoverLast;
          
          quotient_v := divident_v / divisor_v; 
          
          dut_dividend <= std_logic_vector(to_unsigned(divident_v, dut_dividend'length));
          dut_divisor  <= std_logic_vector(to_unsigned(divisor_v, dut_divisor'length));
          dut_start <= '1';
          wait for CLK_PERIOD_C * 1;
          
          dut_start <= '0';
          wait for CLK_PERIOD_C * 1;
          wait until dut_done = '1';

          check_equal(dut_quotient, quotient_v,       "Quotient "&to_string(divident_v)&"/"&to_string(divisor_v), warning, line_num => 99, file_name => "divider_unsigned_tb.vhd");
          check_equal(dut_quotient, dut_beh_quotient, "Quotient "&to_string(divident_v)&"/"&to_string(divisor_v)&" BEH", warning, line_num => 100, file_name => "divider_unsigned_tb.vhd");

          wait for CLK_PERIOD_C * 2;

        end loop;

      
      ---------------------------------------------------------------------------
      end if;

    end loop TEST_CASES_LOOP;
        
    wait for CLK_PERIOD_C;
    check_equal(get_checker_stat.n_failed, 0, "Number of failed tests", error, line_num => 113, file_name => "divider_unsigned_tb.vhd");
    info(to_string(get_checker_stat), line_num => 114, file_name => "divider_unsigned_tb.vhd");
    info(" ", line_num => 115, file_name => "divider_unsigned_tb.vhd");
    info("*** End of Simulation ***", line_num => 116, file_name => "divider_unsigned_tb.vhd");
    test_runner_cleanup(runner);
  end process;

  ---------------------------------------------------------------------------
  -- DUT
  ---------------------------------------------------------------------------
  DUT : entity DIVIDER_UNSIGNED(RTL)
    generic map (
      DATA_WIDTH_G => DATA_WIDTH_G
    )
    port map (
      RST        => RST,
      CLK        => CLK,

      DIVIDEND   => dut_dividend,
      DIVISOR    => dut_divisor,
      QUOTIENT   => dut_quotient,

      START => dut_start,
      DONE  => dut_done
    );

  ---------------------------------------------------------------------------
  -- DUT_BEH
  ---------------------------------------------------------------------------
  DUT_BEH : entity DIVIDER_UNSIGNED(BEH)
    generic map (
      DATA_WIDTH_G => DATA_WIDTH_G
    )
    port map (
      RST        => RST,
      CLK        => CLK,

      DIVIDEND   => dut_dividend,
      DIVISOR    => dut_divisor,
      QUOTIENT   => dut_beh_quotient,

      START => dut_start,
      DONE  => dut_beh_done
    );

end beh;