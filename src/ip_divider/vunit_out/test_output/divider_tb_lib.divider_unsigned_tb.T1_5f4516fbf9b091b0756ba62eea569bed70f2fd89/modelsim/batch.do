onerror {quit -code 1}
source "C:/Projekty/VHDL/Overwatch/src/ip_divider/vunit_out/test_output/divider_tb_lib.divider_unsigned_tb.T1_5f4516fbf9b091b0756ba62eea569bed70f2fd89/modelsim/common.do"
set failed [vunit_load]
if {$failed} {quit -code 1}
set failed [vunit_run]
if {$failed} {quit -code 1}
quit -code 0
