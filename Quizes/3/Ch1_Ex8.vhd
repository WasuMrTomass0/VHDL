-- [B: 30|PDF: 38] Chapter 1 "Fundamental Concepts" - Ex. 8
-- Task: 
-- Express the following octal and hexadecimal bit strings 
-- as binary bit-string literals, or, if they are illegal, say why.

8?
93
2002
2008
2019

-- Answer:
10UO"747"   -> "0_111_100_111"
10UO"377"   -> "0_011_111_111"
10UO"1_345" -> "1_011_100_101"
10SO"747"   -> "0_111_100_111"
10SO"377"   -> "0_011_111_111"
10SO"1_345" -> "1_011_100_101"  ???
12UX"F2"    -> "0000_1111_0010"
12SX"F2"    -> "0000_1111_0010"
10UX"F2"    -> "00_1111_0010"
10SX"F2"    -> "00_1111_0010"


"110011"
Step_1
11_00_11 -> 51
Step:
    11
  -  1
  = 10
  quotient 1????
Step:
    10_00
  -  1_01
  =    11
  quotient 11???
Step:
    11_11
  - 11_01
  =    10
  quotient 111 -> 7
  reminder 10 -> 2

"00_01_11" -> 7

    00
  -  1
  = would be negative
  quotient 0????

    00_01
  -  0_01
  =     0
  quotient 01??? 

  00_00_11
  -  01_01
  =  would be negative
  quotient 010 -> 2
  reminder 11 -> 3
