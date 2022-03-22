library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

library VUNIT_LIB;
context VUNIT_LIB.VUNIT_CONTEXT;
context VUNIT_LIB.VC_CONTEXT;

library COMMON_TB_LIB;
use COMMON_TB_LIB.COMMON_TB_PKG.all;

-- DUT and models
library DIVIDER_LIB;
use DIVIDER_LIB.SFXP_TO_UFXP;


----------------------------------------------------------------------
entity SFXP_TO_UFXP_TB is
  generic (
    DATA_WIDTH_G : natural := 8;
    runner_cfg : string := runner_cfg_default
  );
end SFXP_TO_UFXP_TB;
----------------------------------------------------------------------

architecture BEH of SFXP_TO_UFXP_TB is
  -----------------------------------------------------------------------------
  -- Constant declarations
  -----------------------------------------------------------------------------
  constant CLK_PERIOD_C : time := 2 ns;

  -----------------------------------------------------------------------------
  -- Signal declarations
  -----------------------------------------------------------------------------
  signal RST : std_logic := '0';
  signal CLK : std_logic := '0';
  
  signal dut_start, dut_done_trigger, dut_sign_bit : std_logic;
  signal dut_sfxp : std_logic_vector(DATA_WIDTH_G-1 downto 0);
  signal dut_ufxp : std_logic_vector(DATA_WIDTH_G-1 downto 0);
  
  -----------------------------------------------------------------------------
  -- Others
  -----------------------------------------------------------------------------
  
  procedure test_dut(
    i : integer;
    signal start        : out std_logic;
    signal done_trigger : in std_logic;
    
    signal sfxp : out std_logic_vector;
    signal ufxp : in std_logic_vector
    ) is
  begin
    sfxp <= std_logic_vector(to_signed(i, sfxp'length));
          
    start <= '1';
    wait for CLK_PERIOD_C;
    start <= '0';
    
    check_equal(done_trigger, '0', "done_trigger", warning);

    wait for CLK_PERIOD_C * 2;      
    info("SFxP = "&to_string(sfxp)&", x"&to_hstring(sfxp));
    info("UFxP = "&to_string(ufxp)&", x"&to_hstring(ufxp));  
    check_equal(to_integer(unsigned(ufxp)), abs(i), "i = "&to_string(i), warning);
    check_equal(dut_sign_bit, sfxp(sfxp'left), "sign_bit", warning);
    check_equal(done_trigger, '1', "done_trigger", warning);
  end procedure;

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
        
        for i in -10 to 10 loop
          test_dut(
            i=>i,
            start=> dut_start,
            done_trigger=> dut_done_trigger,
            sfxp=> dut_sfxp,
            ufxp=> dut_ufxp
          );
          
        end loop;

      ---------------------------------------------------------------------------
      -- Test: 
      ---------------------------------------------------------------------------
      elsif (run("T2")) then
        banner_p("T2: Min max values");

        test_dut(i=>2**(DATA_WIDTH_G-1)-1, start=>dut_start, done_trigger=>dut_done_trigger, sfxp=>dut_sfxp, ufxp=>dut_ufxp);
        test_dut(i=>-1,                    start=>dut_start, done_trigger=>dut_done_trigger, sfxp=>dut_sfxp, ufxp=>dut_ufxp);
        test_dut(i=>0,                     start=>dut_start, done_trigger=>dut_done_trigger, sfxp=>dut_sfxp, ufxp=>dut_ufxp);
        test_dut(i=>1,                     start=>dut_start, done_trigger=>dut_done_trigger, sfxp=>dut_sfxp, ufxp=>dut_ufxp);
        test_dut(i=>-2**(DATA_WIDTH_G-1),  start=>dut_start, done_trigger=>dut_done_trigger, sfxp=>dut_sfxp, ufxp=>dut_ufxp);

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
  DUT : entity SFXP_TO_UFXP(RTL)  -- RTL AREA
    generic map (
      DATA_WIDTH_G => DATA_WIDTH_G
    )
    port map (
      RST => RST,
      CLK => CLK,

      SIGN_BIT => dut_sign_bit,          -- out

      SFXP  => dut_sfxp,                 -- in
      UFXP  => dut_ufxp,                 -- out

      START => dut_start,                -- in
      DONE_TRIGGER => dut_done_trigger   -- out
    );

end BEH;
