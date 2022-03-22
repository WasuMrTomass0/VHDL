from ntpath import join
from os import chdir, mkdir, getcwd
from os.path import join, dirname
import logging

# Constants
HDL_DIR_NAME = "hdl"
HDLTB_DIR_NAME = "hdl_tb"
SIM_DIR_NAME = "sim"
CURR_DIR = dirname(__file__)
SRC_DIR = join(CURR_DIR, "src")


def create_dir(dir_name: str, move_to_it: bool=False) -> None:
  mkdir(dir_name)
  if move_to_it:
    chdir(dir_name)
  pass

def create_file(file_name: str, content: str = None) -> str:
  content = content if content else file_name
  
  with open(file_name, 'w') as token:
    token.write(content)
  pass

def main():
  # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # 
  ENTITY_NAME = "least_common_multiple".lower()
  # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # 

  print(f"Creating {ENTITY_NAME}")

  dir_ip_name = f"ip_{ENTITY_NAME}".lower()

  file_hdl_name = f"{ENTITY_NAME}.vhd".lower()
  file_hdltb_name = f"{ENTITY_NAME}_tb.vhd".lower()
  file_sim_name = "run.py"

  entity_hdl_name = f"{ENTITY_NAME}".upper()
  entity_hdltb_name = f"{ENTITY_NAME}_tb".lower()

  vhd_hdl_lib_name = f"{ENTITY_NAME}_lib".lower()
  vhd_hdltb_lib_name = f"{ENTITY_NAME}_tb_lib".lower()

  if not ENTITY_NAME:
    logging.error(f"{ENTITY_NAME=} is not valid!")
    return

  # Move from scripts to src
  chdir(SRC_DIR)

  # Create parent directory
  create_dir(dir_ip_name, move_to_it=True)

  # Create hdl, hdl_tb, sim directories
  create_dir(HDL_DIR_NAME, move_to_it=True)
  create_file(file_hdl_name, content=entity_hdl_name)
  chdir("..")

  create_dir(HDLTB_DIR_NAME, move_to_it=True)
  content = f"{ENTITY_NAME = }\n{entity_hdl_name = }\n{entity_hdltb_name = }"
  create_file(file_hdltb_name, content=content)
  chdir("..")
  
  create_dir(SIM_DIR_NAME, move_to_it=True)
  content = f"{ENTITY_NAME = }\n{entity_hdl_name = }\n{vhd_hdl_lib_name = }\n{vhd_hdltb_lib_name = }"
  create_file(file_sim_name, content=content)
  chdir("..")
  pass


if __name__ == "__main__":
  main()