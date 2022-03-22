onerror {quit -code 1}
source "C:/Projekty/VHDL/Overwatch/src/ip_divider/vunit_out/test_output/divider_tb_lib.divider_fxp_tb.T2_024c1697edc3dc9caf249819e2d1f17a85ae7ff0/modelsim/common.do"
set failed [vunit_load]
if {$failed} {quit -code 1}
set failed [vunit_run]
if {$failed} {quit -code 1}
quit -code 0
