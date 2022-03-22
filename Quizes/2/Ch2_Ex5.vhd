-- [B: 64|PDF: 72] Chapter 2 "Scalar Data Types and Operations" - Ex. 5
-- Task: 
-- 5. [➊ 2.2] Given the following declarations:
signal a, b, c : std_ulogic;
type state_type is (idle, req, ack);
signal state : state_type;
-- indicate whether each of the following expressions is legal as a Boolean condition,
-- and if not, correct it:
a and not b and c                     -- a. 
a and not b and state = idle          -- b. 
a = '0' and b and state = idle        -- c. 
a = '1' and b = '0' and state = idle  -- d. 

-- Answer:
-- 93'.   OK: a d     NOK: b c 
-- All must be std_logic | std_ulogic | boolean
