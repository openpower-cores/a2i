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
-- pragma translate_off
-- pragma translate_on

entity tri_direct_err_rpt is

  generic (
      width         : positive := 1 ;      
      expand_type   : integer  := 1 );     
  port (
      vd            : inout power_logic;
      gd            : inout power_logic;

      err_in        : in  std_ulogic_vector(0 to width-1);
      err_out       : out std_ulogic_vector(0 to width-1)
  );
  -- synopsys translate_off

  -- synopsys translate_on

end tri_direct_err_rpt;

architecture tri_direct_err_rpt of tri_direct_err_rpt is

begin  

  a: if expand_type /= 2 generate
  begin
    err_out <= err_in;
  end generate a;

end tri_direct_err_rpt;

