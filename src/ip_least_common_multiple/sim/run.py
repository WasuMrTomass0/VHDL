from vunit import VUnit
from os.path import dirname, pardir, join
import sys

"""
root/
├─ hdl/
|  └─ *.vhd
├─ hdl_tb/
|  └─ *.vhd
└─ sim/
   └─ run.py
"""

# Paths
sim_dir = dirname(__file__)
root = dirname(sim_dir)
hdl_dir = join(root, 'hdl')
hdl_tb_dir = join(root, 'hdl_tb')

# VUnit instance
VU = VUnit.from_argv()
VU.add_osvvm()
VU.enable_location_preprocessing()
VU.add_verification_components()

# External libraries - use "add_external_library" snippet


# Other libraries - use "add_library" snippet


# Create libraries
least_common_multiple_lib = VU.add_library("least_common_multiple_lib")
least_common_multiple_lib.add_source_files(join(hdl_dir, "*vhd"), vhdl_standard='93')

least_common_multiple_tb_lib = VU.add_library("least_common_multiple_tb_lib")
least_common_multiple_tb_lib.add_source_files(join(hdl_tb_dir, "*vhd"), vhdl_standard='2008')

# Test cases
# TEST = least_common_multiple_tb_lib.entity("least_common_multiple_tb")

# Single configured test cases
# test_name = 'TestName'
# generics = {
#   'DATA_WIDTH_G': 16,
#   'DATA_TYPE_G': "signed"
# }
# TEST.add_config(name=test_name, generics=generics)

# Generated configs
# for DATA_WIDTH_G in [4, 8, 16]:
#   for DATA_TYPE_G in ["signed", "unsigned"]:
#     test_name = f'TestName_{DATA_WIDTH_G}_{DATA_TYPE_G}'
#     generics = {
#       'DATA_WIDTH_G': DATA_WIDTH_G,
#       'DATA_TYPE_G': DATA_TYPE_G
#     }
#     TEST.add_config(name=test_name, generics=generics)
#     pass

# Command line arguments
print(f"{sys.argv = }")
# Load wave.do file if -g flag was passed
if '-g' in sys.argv:
  VU.set_sim_option("modelsim.init_files.after_load", [join(root, "vunit_out", "modelsim", "wave.do")])
# Flags
VU.set_sim_option("modelsim.vsim_flags", ["-t ns"])
VU.main()
