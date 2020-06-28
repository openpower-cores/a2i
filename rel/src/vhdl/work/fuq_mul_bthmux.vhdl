-- © IBM Corp. 2020
-- This softcore is licensed under and subject to the terms of the CC-BY 4.0
-- license (https://creativecommons.org/licenses/by/4.0/legalcode). 
-- Additional rights, including the right to physically implement a softcore 
-- that is compliant with the required sections of the Power ISA 
-- Specification, will be available at no cost via the OpenPOWER Foundation. 
-- This README will be updated with additional information when OpenPOWER's 
-- license is available.


library ieee;
use ieee.std_logic_1164.all;
library ibm;
use ibm.std_ulogic_support.all;
use ibm.std_ulogic_function_support.all;
use ibm.std_ulogic_ao_support.all;
use ibm.std_ulogic_mux_support.all;

entity fuq_mul_bthmux  is  port(
     X      : IN  STD_ULOGIC;
     SNEG   : IN  STD_ULOGIC; 
     SX     : IN  STD_ULOGIC; 
     SX2    : IN  STD_ULOGIC; 
     RIGHT  : IN  STD_ULOGIC; 
     LEFT   : OUT STD_ULOGIC; 
     Q      : OUT STD_ULOGIC  
);




end fuq_mul_bthmux;

architecture fuq_mul_bthmux of fuq_mul_bthmux is

  signal center, q_b :std_ulogic ;



begin

   u_bmx_xor: center  <= x xor sneg ;

              left    <= center ; 

   u_bmx_aoi: q_b     <= not(  ( sx  and center  ) or
                               ( sx2 and right   )    );

   u_bmx_inv: q       <= not q_b    ; 



end;


