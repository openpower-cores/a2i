-- © IBM Corp. 2020
-- This softcore is licensed under and subject to the terms of the CC-BY 4.0
-- license (https://creativecommons.org/licenses/by/4.0/legalcode). 
-- Additional rights, including the right to physically implement a softcore 
-- that is compliant with the required sections of the Power ISA 
-- Specification, will be available at no cost via the OpenPOWER Foundation. 
-- This README will be updated with additional information when OpenPOWER's 
-- license is available.

library ieee;
use ieee.std_logic_1164.all ;
library support;
use support.power_logic_pkg.all;
library tri;


entity pcq_psro_soft is
  port (
         vdd               : inout power_logic; 
         gnd               : inout power_logic; 
         pcq_psro_enable   : in std_ulogic_vector(0 to 2); 
         psro_pcq_ringsig  : out std_ulogic 
       );

end pcq_psro_soft;


architecture pcq_psro_soft of pcq_psro_soft is
begin

  pcq_init: entity tri.tri_psro_soft
    port map
    ( vdd           => vdd                      ,
      gnd           => gnd                      ,
      psro_enable   => pcq_psro_enable(0 to 2)  , 
      psro_ringsig  => psro_pcq_ringsig         );

end pcq_psro_soft;
