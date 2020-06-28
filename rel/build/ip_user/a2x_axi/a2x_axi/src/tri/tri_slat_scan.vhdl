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
library support;                  use support.power_logic_pkg.all;
library tri; use tri.tri_latches_pkg.all;

entity tri_slat_scan is

  generic ( width              : positive range 1 to 65536 := 1 ;
            offset             : natural  range 0 to 65535 := 0;
            init               : std_ulogic_vector         := "0" ;
            synthclonedlatch   : string                    := "" ;
            btr                : string                    := "c_slat_scan" ;
            reset_inverts_scan : boolean                   := true;
            expand_type : integer := 1 ); 
  port (
        vd       : inout power_logic;
        gd       : inout power_logic;
        dclk     : in    std_ulogic;
        lclk     : in    clk_logic;
        scan_in  : in    std_ulogic_vector(offset to offset+width-1);
        scan_out : out   std_ulogic_vector(offset to offset+width-1);
        q        : out   std_ulogic_vector(offset to offset+width-1);
        q_b      : out   std_ulogic_vector(offset to offset+width-1)
       );

  -- synopsys translate_off

  -- synopsys translate_on

end entity tri_slat_scan;

architecture tri_slat_scan of tri_slat_scan is

begin

  a: if expand_type = 1 generate
    constant zeros : std_ulogic_vector(0 to width-1) := (0 to width-1 => '0');
    constant initv : std_ulogic_vector(0 to (init'length + width-1)):=init & (0 to width-1=>'0');
    signal  unused : std_ulogic_vector(0 to width);
    -- synopsys translate_off
    -- synopsys translate_on
  begin
    scan_out <= zeros;
    q <= initv(0 to width-1);
    q_b <= not initv(0 to width-1);
    unused(0) <= dclk;
    unused(1 to width) <= scan_in;
  end generate a;

end tri_slat_scan;

