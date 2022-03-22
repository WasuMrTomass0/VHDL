-- [B:205|PDF:213] Chapter 5 "Basic Modeling Constructs" - Ex. 30
-- Task: 
-- 30. [➋ 5.3] Develop a structural model of an 8-bit odd-parity checker using instances of
-- an exclusive-or gate entity. The parity checker has eight inputs, i0 to i7, and an output,
-- p, all of type std_ulogic. The logic equation describing the parity checker is

-- Answer:
entity parity_checker is
    port (
        i0 : in std_ulogic;
        i1 : in std_ulogic;
        i2 : in std_ulogic;
        i3 : in std_ulogic;
        i4 : in std_ulogic;
        i5 : in std_ulogic;
        i6 : in std_ulogic;
        i7 : in std_ulogic;
        p  : out std_ulogic
    );
end parity_checker;

architecture rtl of parity_checker is
begin
    p <= i0 xor i1 xor i2 xor i3 xor i4 xor i5 xor i6 xor i7;
end architecture;
