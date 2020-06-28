-- © IBM Corp. 2020
-- This softcore is licensed under and subject to the terms of the CC-BY 4.0
-- license (https://creativecommons.org/licenses/by/4.0/legalcode). 
-- Additional rights, including the right to physically implement a softcore 
-- that is compliant with the required sections of the Power ISA 
-- Specification, will be available at no cost via the OpenPOWER Foundation. 
-- This README will be updated with additional information when OpenPOWER's 
-- license is available.


library ieee; use ieee.std_logic_1164.all;
              use ieee.numeric_std.all;

library support; 
                 use support.power_logic_pkg.all;
library tri; use tri.tri_latches_pkg.all;
-- pragma translate_off
-- pragma translate_on

entity tri_err_rpt is

  generic (
      width        : positive := 1;               
      mask_reset_value : std_ulogic_vector := "0";
      inline       : boolean := false;            
      share_mask   : boolean := false;            
      use_nlats    : boolean := false;            
      needs_sreset : integer := 1 ;        
      expand_type  : integer := 1 );       

  port (
      vd            : inout power_logic;
      gd            : inout power_logic;
      err_d1clk     : in  std_ulogic;           
      err_d2clk     : in  std_ulogic;
      err_lclk      : in  clk_logic;
      err_scan_in   : in  std_ulogic_vector(0 to width-1);
      err_scan_out  : out std_ulogic_vector(0 to width-1);
      mode_dclk     : in  std_ulogic;
      mode_lclk     : in  clk_logic;
      mode_scan_in  : in  std_ulogic_vector(0 to width-1);
      mode_scan_out : out std_ulogic_vector(0 to width-1);

      err_in        : in  std_ulogic_vector(0 to width-1);
      err_out       : out std_ulogic_vector(0 to width-1);

      hold_out      : out std_ulogic_vector(0 to width-1); 
      mask_out      : out std_ulogic_vector(0 to width-1)
  );
  -- synopsys translate_off

  -- synopsys translate_on

end tri_err_rpt;

architecture tri_err_rpt of tri_err_rpt is

begin  

  a: if expand_type /= 2 generate
    constant mask_initv : std_ulogic_vector(0 to (mask_reset_value'length + width-1)):=mask_reset_value & (0 to width-1=>'0');
    signal hold_in      : std_ulogic_vector(0 to width-1);
    signal hold_lt      : std_ulogic_vector(0 to width-1);
    signal mask_lt      : std_ulogic_vector(0 to width-1);
    signal unused : std_ulogic_vector(0 to width);
    -- synopsys translate_off
    -- synopsys translate_on
  begin
    hold_in  <= err_in or hold_lt;

    hold: entity tri.tri_nlat_scan
    generic map( width => width,
                 needs_sreset => needs_sreset,
                 expand_type => expand_type )
    port map
     ( vd        => vd,
       gd        => gd,
       d1clk     => err_d1clk,
       d2clk     => err_d2clk,
       lclk      => err_lclk,
       scan_in   => err_scan_in(0 to width-1),
       scan_out  => err_scan_out(0 to width-1),
       din       => hold_in,
       q         => hold_lt,
       q_b       => open
     );

    m: if (share_mask = false) generate
        mask_lt <= mask_initv(0 to width-1);
    end generate m;
    sm: if (share_mask = true) generate
        mask_lt <= (others => mask_initv(0));
    end generate sm;

    mode_scan_out <= (others => '0');

    hold_out <= hold_lt;
    mask_out <= mask_lt;

    inline_hold: if (inline = true) generate
        err_out <= hold_lt and not mask_lt;
    end generate inline_hold;

    side_hold: if (inline = false) generate
        err_out <= err_in and not mask_lt;
    end generate side_hold;

    unused(0) <= mode_dclk;
    unused(1 to width) <= mode_scan_in;
  end generate a;

end tri_err_rpt;

