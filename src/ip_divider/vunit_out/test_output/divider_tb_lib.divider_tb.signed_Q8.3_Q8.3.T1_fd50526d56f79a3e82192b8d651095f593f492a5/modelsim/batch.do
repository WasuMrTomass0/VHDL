onerror {quit -code 1}
source "C:/Projekty/VHDL/Overwatch/src/ip_divider/vunit_out/test_output/divider_tb_lib.divider_tb.signed_Q8.3_Q8.3.T1_fd50526d56f79a3e82192b8d651095f593f492a5/modelsim/common.do"
set failed [vunit_load]
if {$failed} {quit -code 1}
set failed [vunit_run]
if {$failed} {quit -code 1}
quit -code 0
