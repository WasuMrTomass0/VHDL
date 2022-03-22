library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;


-----------------------------------------------------------------------------
entity LEAST_COMMON_MULTIPLE is
  generic (
    DATA_TYPE_G  : string;  -- signed|unsigned|invalid
    DATA_WIDTH_G : natural
  );
  port (
    RST : in std_logic;
    CLK : in std_logic;
    EN  : in std_logic;
    
    X : in std_logic_vector(DATA_WIDTH_G-1 downto 0);
    Y : in std_logic_vector(DATA_WIDTH_G-1 downto 0);

    START  : in std_logic;
    READY  : in std_logic
  );
end LEAST_COMMON_MULTIPLE;


-----------------------------------------------------------------------------
architecture RTL of LEAST_COMMON_MULTIPLE is

begin

end architecture;
