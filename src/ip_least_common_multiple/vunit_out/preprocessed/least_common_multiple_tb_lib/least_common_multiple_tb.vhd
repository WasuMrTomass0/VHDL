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

-- library COMMON_TB_LIB;
-- use COMMON_TB_LIB.COMMON_TB_PKG.all;
-- use COMMON_TB_LIB.FIXED_TRUNC_PKG.all;

-- library OSVVM;
-- use OSVVM.CoveragePkg.all;

-- DUT and models
library LEAST_COMMON_MULTIPLE_LIB;
use LEAST_COMMON_MULTIPLE_LIB.LEAST_COMMON_MULTIPLE;


----------------------------------------------------------------------
entity LEAST_COMMON_MULTIPLE_TB is
  generic (
    
    runner_cfg    : string   := runner_cfg_default
  );
end LEAST_COMMON_MULTIPLE_TB;
----------------------------------------------------------------------

architecture BEH of LEAST_COMMON_MULTIPLE_TB is
  -----------------------------------------------------------------------------
  -- Constant declarations
  -----------------------------------------------------------------------------
  constant CLK_PERIOD_C : time := 2 ns;
  constant CLK_FREQ_C   : real := 1.0 / CLK_PERIOD_C;

  -----------------------------------------------------------------------------
  -- Signal declarations
  -----------------------------------------------------------------------------
  signal RST : std_logic := '0';
  signal EN  : std_logic := '1';
  signal CLK : std_logic := '0';
  
  signal dut_ : std_logic;
  signal dut_ : std_logic_vector(DATA_WIDTH_G-1 downto 0);
  
  -----------------------------------------------------------------------------
  -- Others
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
    
  begin
    -----------------------------------------------------------------------------
    -- VUnit tb settings
    -----------------------------------------------------------------------------
    test_runner_setup(runner, runner_cfg);
    show(display_handler, pass);  -- show passed tests

    ---------------------------------------------------------------------------
    -- Initialization phase
    ---------------------------------------------------------------------------

    
    ---------------------------------------------------------------------------
    -- Debug info
    ---------------------------------------------------------------------------
    info("CLK_PERIOD_C = " & to_string(CLK_PERIOD_C), line_num => 93, file_name => "least_common_multiple_tb.vhd");
    info("CLK_FREQ_C   = " & to_string(CLK_FREQ_C), line_num => 94, file_name => "least_common_multiple_tb.vhd");

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
        
        wait for CLK_PERIOD_C;


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
    check_equal(get_checker_stat.n_failed, 0, "Number of failed tests", error, line_num => 134, file_name => "least_common_multiple_tb.vhd");
    info(to_string(get_checker_stat), line_num => 135, file_name => "least_common_multiple_tb.vhd");
    info(" ", line_num => 136, file_name => "least_common_multiple_tb.vhd");
    info("*** End of Simulation ***", line_num => 137, file_name => "least_common_multiple_tb.vhd");
    test_runner_cleanup(runner);
  end process;



  ---------------------------------------------------------------------------
  -- DUT
  ---------------------------------------------------------------------------
  DUT : entity LEAST_COMMON_MULTIPLE(RTL)
    generic map (
       => ,
       => 
    )
    port map (
      RST => RST,
      CLK => CLK,
      EN  => EN,

       => dut_,  -- in
       => dut_,  -- in
       => dut_,  -- out
       => dut_   -- out
    );

end BEH;
