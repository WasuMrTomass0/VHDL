-- [B: 94|PDF:102] Chapter 3 "Sequential Statements" - Ex. 1
-- Task: 
-- 1. [➊ 3.1] Write an if statement that sets a variable odd to ‘1’ if an integer n is odd, or to
-- ‘0’ if it is even. Rewrite your if statement as a conditional variable assignment.

-- Answer:
-- odd number   - liczba nieparzysta - '1'
-- even number  - liczba parzysta    - '0'

if int_v mod 2 = 1 then
    odd_v := '1';
else
    odd_v := '0';
end if;

odd_v := '1' when int_v mod 2 = 1 else '0';
