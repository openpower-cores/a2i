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

entity tri_lcbs is

  generic ( expand_type : integer := 1 ); 

  port (
        vd          : inout power_logic;
        gd          : inout power_logic;
        delay_lclkr : in    std_ulogic;
        nclk        : in    clk_logic;
        forcee       : in    std_ulogic;
        thold_b     : in    std_ulogic;
        dclk        : out   std_ulogic;
        lclk        : out   clk_logic
       );

  -- synopsys translate_off

  -- synopsys translate_on

end entity tri_lcbs;

architecture tri_lcbs of tri_lcbs is

begin

  a: if expand_type = 1 generate
    signal unused : std_ulogic;
    -- synopsys translate_off
    -- synopsys translate_on
  begin
    dclk <= thold_b;
    lclk <= nclk;
    unused <= delay_lclkr or forcee;
  end generate a;

end tri_lcbs;

