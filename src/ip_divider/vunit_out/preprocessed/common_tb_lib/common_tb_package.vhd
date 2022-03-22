library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

library STD;
use STD.STANDARD.all;

library VUNIT_LIB;
context VUNIT_LIB.VUNIT_CONTEXT;
context VUNIT_LIB.VC_CONTEXT;



-----------------------------------------------------------------------------
package COMMON_TB_PKG is

  -- Print banner in console
  procedure banner_p (constant s : in string);

end package;

-----------------------------------------------------------------------------
package body COMMON_TB_PKG is

  -----------------------------------------------------------------------------
  procedure banner_p (constant s : in string) is
    variable dashes : string(1 to 256) := (others => '-');
  begin
    info(
      '+' & dashes(s'range) & '+' & LF &
      '|' & s & '|' & LF &
      '+' & dashes(s'range) & '+'
      -- '+' & dashes(s'RANGE) & '+' & LF
    , line_num => 29, file_name => "common_tb_package.vhd");
  end banner_p;

end package body;
