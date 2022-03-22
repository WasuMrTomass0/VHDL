from vunit import VUnit
from os.path import dirname, pardir, join
import sys

"""
hdl/
├─ *.vhd
hdl_tb/
├─ *.vhd
sim/
├─ run.py
"""

# # # # # # # # Paths # # # # # # # #
sim_dir = dirname(__file__)
root = dirname(sim_dir)
hdl_dir = join(root, 'hdl')
hdl_tb_dir = join(root, 'hdl_tb')

# # # # # # # # VUnit instance # # # # # # # #
VU = VUnit.from_argv()
VU.add_osvvm()
VU.enable_location_preprocessing()
VU.add_verification_components()

# # # # # # # # Additional libraries # # # # # # # #
# smartfustion2_path = join(dirname(__file__), "../tb_utils/libero2021.2_msim_lib/smartfusion2")
# VU.add_external_library("smartfusion2", smartfustion2_path)

# macc_lib = VU.add_library("macc_lib")
# macc_lib.add_source_files(join(root, "../../ip_ig_macc/hdl/*.vhd"), vhdl_standard='93')
common_tb_lib = VU.add_library("common_tb_lib")
common_tb_lib.add_source_files(join(root, "../common/hdl_tb/*.vhd"), vhdl_standard='2008')
common_lib = VU.add_library("common_lib")
common_lib.add_source_files(join(root, "../common/hdl/*.vhd"), vhdl_standard='93')

# # # # # # # # Libraries - work should be changed to full name # # # # # # # #
divider_lib = VU.add_library("divider_lib")
divider_lib.add_source_files(join(hdl_dir, "*vhd"), vhdl_standard='93')

divider_tb_lib = VU.add_library("divider_tb_lib")
divider_tb_lib.add_source_files(join(hdl_tb_dir, "*vhd"), vhdl_standard='2008')

# # # # # # # # Test cases # # # # # # # # 
TEST = divider_tb_lib.entity("divider_by_const_tb")  # Done once
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# Below can be repeated to create more cases
# stimulus = [
#   # (FACTOR_VALUE_G, DIVIDER_VALUE_G, NUM_OF_BITS_G)
#   (0, 5, 8), (0, 5, 16), (0, 7, 16), (0, 123, 8), (0, 123, 16),
#   (51, 5, 8), (13107, 5, 16), (9362, 7, 16), (2, 123, 8), (532, 123, 16),  # FACTOR_VALUE_G and DIVIDER_VALUE_G depend on each other 
#   (51, 0, 8), (13107, 0, 16), (9362, 0, 16), (2, 0, 8), (532, 0, 16),
#   (462, 0, 10), (13107, 0, 15), (2597, 0, 20), (3670, 0, 22), (2260, 0, 25),
#   (0, 999, 10), (0, 1120, 15), (0, 2608, 20), (0, 1560, 22), (0, 9765, 25)
# ]

# for DATA_TYPE_G in ["signed", "unsigned"]:
#   for FACTOR_VALUE_G, DIVIDER_VALUE_G, NUM_OF_BITS_G in stimulus:
#     for DATA_WIDTH_G in [16, 24, 30]:  # max is 31 - due to integers being 32 bits long      
#       test_name = f"{DATA_TYPE_G}_W{DATA_WIDTH_G}_F{FACTOR_VALUE_G}_D{DIVIDER_VALUE_G}_Nb{NUM_OF_BITS_G}"
#       generics = {
#         'DATA_TYPE_G' : DATA_TYPE_G,
#         'FACTOR_VALUE_G' : FACTOR_VALUE_G,
#         'DIVIDER_VALUE_G' : DIVIDER_VALUE_G,
#         'NUM_OF_BITS_G' : NUM_OF_BITS_G,
#         'DATA_WIDTH_G' : DATA_WIDTH_G
#       }
#       TEST.add_config(name=test_name, generics=generics)
#       pass
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
TEST = divider_tb_lib.entity("divider_tb")  # Done once
for DATA_TYPE_G in ["signed", "unsigned"]:
  for DIVIDEND_WIDTH_G, DIVIDEND_INT_BITS_G in [(8, 3)]:
    for DIVISOR_WIDTH_G, DIVISOR_INT_BITS_G in [(8, 3)]:
      test_name = f"{DATA_TYPE_G}_Q{DIVIDEND_WIDTH_G}.{DIVIDEND_INT_BITS_G}/Q{DIVISOR_WIDTH_G}.{DIVISOR_INT_BITS_G}"
      generics = {
        'DATA_TYPE_G' : DATA_TYPE_G,
        'DIVIDEND_WIDTH_G' : DIVIDEND_WIDTH_G,
        'DIVIDEND_INT_BITS_G' : DIVIDEND_INT_BITS_G,
        'DIVISOR_WIDTH_G' : DIVISOR_WIDTH_G,
        'DIVISOR_INT_BITS_G' : DIVISOR_INT_BITS_G
      }
      TEST.add_config(name=test_name, generics=generics)
      pass


# # # # # # # # Flags # # # # # # # #
VU.set_sim_option("modelsim.vsim_flags", ["-t ns"])

# Command line arguments
print(f"{sys.argv = }")
# Load wave.do file if -g flag was passed
# if '-g' in sys.argv:
#   VU.set_sim_option("modelsim.init_files.after_load", [join(root, "vunit_out", "modelsim", "wave.do")])

VU.main()
