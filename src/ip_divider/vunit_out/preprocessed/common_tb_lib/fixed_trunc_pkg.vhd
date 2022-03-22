library IEEE;

package FIXED_TRUNC_PKG is new IEEE.FIXED_GENERIC_PKG
  generic map (
    fixed_round_style    => IEEE.fixed_float_types.fixed_truncate,
    fixed_overflow_style => IEEE.fixed_float_types.fixed_saturate,
    fixed_guard_bits     => 3,
    no_warning           => false
    );
