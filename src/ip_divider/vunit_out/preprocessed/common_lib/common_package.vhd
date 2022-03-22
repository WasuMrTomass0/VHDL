library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

-----------------------------------------------------------------------------
package COMMON_PKG is

  -- Calculate number of fractional bits
  function num_of_frac_bits(word_width : natural; int_bits : natural; data_type : string) return natural;

  -- Cast boolean to std_logic
  function bool2std_logic_f(bool_val : boolean) return std_logic;

  -- Extend fixed point number
  procedure extend_signed_fxp_p(
    signal IN_SLV : in std_logic_vector; 
    signal OUT_SLV: out std_logic_vector;
    
    constant IN_INT_BITS_C    : natural;
    constant OUT_INT_BITS_C   : natural
  );

  -- Shorten fixed point number
  procedure shorten_signed_fxp_p(
    signal IN_SLV   : in  std_logic_vector; 
    signal OUT_SLV  : out std_logic_vector;
    signal OUT_OVERFLOW : out std_logic;
    
    constant IN_INT_BITS_C    : natural;
    constant OUT_INT_BITS_C   : natural;
    constant SATURATE_C       : boolean := false
  );
  -----------------------------------------------------------------------------
  
  function hstring_to_std_logic_vector_f( s : string; descending : boolean := true ) return std_logic_vector;

  function reverse_f( s : string ) return string; 

  function lower_f( s : string ) return string;

  function upper_f( s : string ) return string;

  constant UPPER_A_INDEX_C : natural := character'pos('A');
  constant LOWER_A_INDEX_C : natural := character'pos('a');
  constant UPPER_F_INDEX_C : natural := character'pos('F');
  constant LOWER_F_INDEX_C : natural := character'pos('f');
  constant UPPER_Z_INDEX_C : natural := character'pos('Z');
  constant LOWER_Z_INDEX_C : natural := character'pos('z');

end package;

-----------------------------------------------------------------------------
package body COMMON_PKG is

  -----------------------------------------------------------------------------
  function num_of_frac_bits(word_width : natural; int_bits : natural; data_type : string) return natural is
  begin
    if data_type = "signed" then
      return word_width - 1 - int_bits;
    
    elsif data_type = "unsigned" then
      return word_width - int_bits;
    
    else
      assert false
        report "Invalid data type. Use unsigned or signed. Got " & data_type
        severity failure;
      return natural'high;
    end if;

  end function;

  -----------------------------------------------------------------------------
  function bool2std_logic_f(bool_val : boolean) return std_logic is
    begin
      
      if bool_val = true then
        return '1';
      else
        return '0';
      end if;
  
    end function;

  -----------------------------------------------------------------------------
  procedure extend_signed_fxp_p(
    signal IN_SLV : in std_logic_vector; 
    signal OUT_SLV: out std_logic_vector;
    
    constant IN_INT_BITS_C    : natural;
    constant OUT_INT_BITS_C   : natural

    ) is
    constant IN_FRACT_BITS_C  : natural := IN_SLV'length  - 1 - IN_INT_BITS_C;
    constant OUT_FRACT_BITS_C : natural := OUT_SLV'length - 1 - OUT_INT_BITS_C;
      
    -- Ascending
    constant ASC_FROM_INDEX_C : integer := OUT_INT_BITS_C - IN_INT_BITS_C;
    constant ASC_TO_INDEX_C   : integer := ASC_FROM_INDEX_C + IN_SLV'length - 1;
    
    -- Descending
    constant DSC_FROM_INDEX_C   : integer := OUT_SLV'length - (OUT_INT_BITS_C - IN_INT_BITS_C) - 1;
    constant DSC_DOWNTO_INDEX_C : integer := DSC_FROM_INDEX_C - IN_SLV'length + 1;

  begin
    
    assert IN_SLV'length <= OUT_SLV'length
      report "Input vector isn't longer than output!"
      severity error;  -- note, warning, error, failure
    
    if OUT_SLV'ascending then  -- Ascending array

      -- Extends sign bit
      if OUT_SLV'left <= ASC_FROM_INDEX_C-1 then
        OUT_SLV(OUT_SLV'left to ASC_FROM_INDEX_C-1) <= (others => in_slv(in_slv'left));
      end if;

      -- Copy in_slv
      OUT_SLV(ASC_FROM_INDEX_C to ASC_TO_INDEX_C) <= in_slv;

      if ASC_TO_INDEX_C+1 <= OUT_SLV'right then
        -- Add zeroes
        OUT_SLV(ASC_TO_INDEX_C+1 to OUT_SLV'right) <= (others => '0');
      end if;

    else  -- Descending order

      -- Extends sign bit
      if OUT_SLV'left >= DSC_FROM_INDEX_C+1 then
        OUT_SLV(OUT_SLV'left downto DSC_FROM_INDEX_C+1) <= (others => in_slv(in_slv'left));
      end if;

      -- Copy in_slv
      OUT_SLV(DSC_FROM_INDEX_C downto DSC_DOWNTO_INDEX_C) <= in_slv;

      if DSC_DOWNTO_INDEX_C-1 >= OUT_SLV'right then
        -- Add zeroes
        OUT_SLV(DSC_DOWNTO_INDEX_C-1 downto OUT_SLV'right) <= (others => '0');
      end if;

    end if;

    
  end procedure;

  -----------------------------------------------------------------------------
  procedure shorten_signed_fxp_p(
    signal IN_SLV : in std_logic_vector; 
    signal OUT_SLV: out std_logic_vector;
    signal OUT_OVERFLOW : out std_logic;
    
    constant IN_INT_BITS_C    : natural;
    constant OUT_INT_BITS_C   : natural;
    constant SATURATE_C       : boolean := false

    ) is
    constant IN_FRACT_BITS_C  : natural := IN_SLV'length  - 1 - IN_INT_BITS_C;
    constant OUT_FRACT_BITS_C : natural := OUT_SLV'length - 1 - OUT_INT_BITS_C;

    -- Ascending
    constant ASC_FROM_INDEX_C : integer := IN_INT_BITS_C - OUT_INT_BITS_C + 1;
    constant ASC_TO_INDEX_C   : integer := ASC_FROM_INDEX_C + OUT_SLV'length - 1;

    -- Descending
    constant DSC_DOWNTO_INDEX_C : integer := IN_FRACT_BITS_C - OUT_FRACT_BITS_C;
    constant DSC_FROM_INDEX_C   : integer := DSC_DOWNTO_INDEX_C + OUT_SLV'length - 2;

    -- All zeros / ones
    constant ZEROS_C : std_logic_vector(IN_SLV'range) := (others => '0');
    constant ONES_C  : std_logic_vector(IN_SLV'range) := (others => '1');


  begin
    assert IN_SLV'length >= OUT_SLV'length
      report "Input vector isn't longer than output!"
      severity error;  -- note, warning, error, failure

    if OUT_SLV'ascending then  -- Ascending array
      if SATURATE_C and (ZEROS_C = IN_SLV(IN_SLV'left to ASC_FROM_INDEX_C+1) or ONES_C = IN_SLV(IN_SLV'left to ASC_FROM_INDEX_C+1)) then
        -- Saturation is needed
        -- OUT_SLV <= IN_SLV(IN_SLV'left) & ZEROS_C(ZEROS_C'left-1 to 0);
        if IN_SLV(IN_SLV'left) = '1' then
          -- Drive 100...0
          OUT_SLV <= '1' & (OUT_SLV'left+1 to OUT_SLV'right => '0');
        else
          -- Drive 011...1
          OUT_SLV <= '0' & (OUT_SLV'left+1 to OUT_SLV'right => '1');
        end if;
        OUT_OVERFLOW <= '1';
      else
        -- No overflow or overflow with saturation being turned off
        OUT_SLV <= IN_SLV(IN_SLV'left) & IN_SLV(ASC_FROM_INDEX_C to ASC_TO_INDEX_C);
        OUT_OVERFLOW <= '0';
      end if;

    else  -- Descending order
      if SATURATE_C and (ZEROS_C = IN_SLV(IN_SLV'left downto DSC_FROM_INDEX_C+1) or ONES_C = IN_SLV(IN_SLV'left downto DSC_FROM_INDEX_C+1)) then
        -- Saturation is needed
        -- OUT_SLV <= IN_SLV(IN_SLV'left) & ZEROS_C(ZEROS_C'left-1 downto 0);
        if IN_SLV(IN_SLV'left) = '1' then
          -- Drive 100...0
          OUT_SLV <= '1' & (OUT_SLV'left-1 downto OUT_SLV'right => '0');
        else
          -- Drive 011...1
          OUT_SLV <= '0' & (OUT_SLV'left-1 downto OUT_SLV'right => '1');
        end if;
        OUT_OVERFLOW <= '1';
      else
        -- No overflow or overflow with saturation being turned off
        OUT_SLV <= IN_SLV(IN_SLV'left) & IN_SLV(DSC_FROM_INDEX_C downto DSC_DOWNTO_INDEX_C);
        OUT_OVERFLOW <= '0';
      end if;
    end if;

  end procedure;

  -----------------------------------------------------------------------------
  function hstring_to_std_logic_vector_f( s : string; descending : boolean := true ) return std_logic_vector is
    constant LEFT_INDEX_C  : natural := s'length * 4;
    constant RIGHT_INDEX_C : natural := 0;
		variable r : std_logic_vector( LEFT_INDEX_C downto RIGHT_INDEX_C );
    variable index : natural range r'range;
	begin

		for i in 1 to s'high loop
			r(i * 8 - 1 downto (i - 1) * 8) := std_logic_vector(to_unsigned( character'pos(s(i)), 8));
		end loop ;

		return r ;

	end function ;

  -----------------------------------------------------------------------------
  function reverse_f( s : string ) return string is
		variable r : string(s'high downto s'low) ;
	begin

		for i in 1 to s'high loop
			r(s'high + 1 - i) := s(i);
		end loop ;

	  return r ;

	end function ;

  -----------------------------------------------------------------------------
  function lower_f( s : string ) return string is
		variable r : string(s'high downto s'low) ;
    variable c : character;
    variable c_pos : natural;
    constant CHAR_DIFF_C : integer := UPPER_A_INDEX_C - LOWER_A_INDEX_C;
	
  begin

		for i in 1 to s'high loop
      -- read character
      c := s(i);
      c_pos := character'pos(c);
      -- is upper letter
      if UPPER_A_INDEX_C <= c_pos and c_pos <= UPPER_Z_INDEX_C then
        c_pos := c_pos - CHAR_DIFF_C;
        c := character'val(c_pos);
      end if;
      -- write to r
			r(s'high + 1 - i) := c;
		end loop ;
    
	  return r ;

	end function ;

    -----------------------------------------------------------------------------
    function upper_f( s : string ) return string is
      variable r : string(s'high downto s'low) ;
      variable c : character;
      variable c_pos : natural;
      constant CHAR_DIFF_C : integer := UPPER_A_INDEX_C - LOWER_A_INDEX_C;
    
    begin
  
      for i in 1 to s'high loop
        -- read character
        c := s(i);
        c_pos := character'pos(c);
        -- is lower letter
        if LOWER_A_INDEX_C <= c_pos and c_pos <= LOWER_Z_INDEX_C then
          c_pos := c_pos + CHAR_DIFF_C;
          c := character'val(c_pos);
        end if;
        -- write to r
        r(s'high + 1 - i) := c;
      end loop ;
      
      return r ;
  
    end function ;



end package body;
