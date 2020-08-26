-- © IBM Corp. 2020
-- This softcore is licensed under and subject to the terms of the CC-BY 4.0
-- license (https://creativecommons.org/licenses/by/4.0/legalcode). 
-- Additional rights, including the right to physically implement a softcore 
-- that is compliant with the required sections of the Power ISA 
-- Specification, will be available at no cost via the OpenPOWER Foundation. 
-- This README will be updated with additional information when OpenPOWER's 
-- license is available.

library ieee; use ieee.std_logic_1164.all ; 
library ibm; 
  use ibm.std_ulogic_support.all; 
  use ibm.std_ulogic_function_support.all; 
  use ibm.std_ulogic_ao_support.all; 
  use ibm.std_ulogic_mux_support.all; 

ENTITY fuq_csa22_h2 IS
  PORT(
   a       : IN  std_ulogic;
   b       : IN  std_ulogic;
   car     : OUT std_ulogic;
   sum     : OUT std_ulogic
  );
END                               fuq_csa22_h2;

ARCHITECTURE fuq_csa22_h2 OF fuq_csa22_h2 IS

    signal car_b, sum_b : std_ulogic;



BEGIN

  u_22nandc: car_b <= not( a and b );
  u_22nands: sum_b <= not( car_b and (a or b) ); -- this is equiv to an xnor
  u_22invc:  car   <= not car_b;
  u_22invs:  sum   <= not sum_b ;

END;
