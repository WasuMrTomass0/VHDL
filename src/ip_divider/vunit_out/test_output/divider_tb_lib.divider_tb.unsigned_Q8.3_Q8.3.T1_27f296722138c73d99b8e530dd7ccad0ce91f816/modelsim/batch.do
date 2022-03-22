onerror {quit -code 1}
source "C:/Projekty/VHDL/Overwatch/src/ip_divider/vunit_out/test_output/divider_tb_lib.divider_tb.unsigned_Q8.3_Q8.3.T1_27f296722138c73d99b8e530dd7ccad0ce91f816/modelsim/common.do"
set failed [vunit_load]
if {$failed} {quit -code 1}
set failed [vunit_run]
if {$failed} {quit -code 1}
quit -code 0
