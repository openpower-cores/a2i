-- © IBM Corp. 2020
-- This softcore is licensed under and subject to the terms of the CC-BY 4.0
-- license (https://creativecommons.org/licenses/by/4.0/legalcode). 
-- Additional rights, including the right to physically implement a softcore 
-- that is compliant with the required sections of the Power ISA 
-- Specification, will be available at no cost via the OpenPOWER Foundation. 
-- This README will be updated with additional information when OpenPOWER's 
-- license is available.

-- *!****************************************************************
-- *! FILENAME    : tri_lcbor.vhdl
-- *! DESCRIPTION : Used to generate LCB controls
-- *!****************************************************************

library ieee; use ieee.std_logic_1164.all;
              use ieee.numeric_std.all;

library support; 
                 use support.power_logic_pkg.all;

entity tri_lcbor is

  generic ( expand_type : integer := 1 ); -- 1 = non-ibm, 2 = ibm (MPG)

  port (
        clkoff_b : in    std_ulogic;
        thold    : in    std_ulogic;
        sg       : in    std_ulogic;
        act_dis  : in    std_ulogic;
        forcee    : out   std_ulogic;
        thold_b  : out   std_ulogic
       );

end entity tri_lcbor;

architecture tri_lcbor of tri_lcbor is

  signal unused : std_ulogic;

begin

  a: if expand_type = 1 generate
    forcee <= '0';
    thold_b <= not thold;
    unused <= clkoff_b or sg or act_dis;
  end generate a;

end tri_lcbor;
