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
library ibm;
use ibm.std_ulogic_support.all;
use ibm.std_ulogic_function_support.all;
library support;
use support.power_logic_pkg.all;


entity tri_psro_soft is
  port (
         vdd            : inout power_logic;            
         gnd            : inout power_logic;            
         psro_enable    : in std_ulogic_vector(0 to 2); 
         psro_ringsig   : out std_ulogic                
       );

-- synopsys translate_off
-- synopsys translate_on
end tri_psro_soft;


architecture tri_psro_soft of tri_psro_soft is
begin

  psro_ringsig  <=  or_reduce(psro_enable(0 to 2));

end tri_psro_soft;
