-- [B:205|PDF:213] Chapter 5 "Basic Modeling Constructs" - Ex. 27
-- Task: 
-- 27. [➋ 5.2] Develop a functional model using conditional signal assignment statements of
-- an address decoder for a microcomputer system. The decoder has an address input
-- port of type natural and a number of active-low select outputs, each activated when
-- the address is within a given range. The outputs and their corresponding ranges are

-- ROM_sel_n 16#0000# to 16#3FFF#
-- RAM_sel_n 16#4000# to 16#5FFF#
-- PIO_sel_n 16#8000# to 16#8FFF#
-- SIO_sel_n 16#9000# to 16#9FFF#
-- INT_sel_n 16#F000# to 16#FFFF#

-- Answer:
-- port: IN_ADDR : integer

ROM_sel <= '1' when x"0000" <= IN_ADDR and IN_ADDR <= x"3FFF" else '0';
RAM_sel <= '1' when x"4000" <= IN_ADDR and IN_ADDR <= x"5FFF" else '0';
PIO_sel <= '1' when x"8000" <= IN_ADDR and IN_ADDR <= x"8FFF" else '0';
SIO_sel <= '1' when x"9000" <= IN_ADDR and IN_ADDR <= x"9FFF" else '0';
INT_sel <= '1' when x"F000" <= IN_ADDR and IN_ADDR <= x"FFFF" else '0';

