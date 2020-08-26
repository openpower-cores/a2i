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
     SNEG   : IN  STD_ULOGIC; -- DO NOT FLIP THE INPUT (ADD)
     SX     : IN  STD_ULOGIC; -- SHIFT BY 1
     SX2    : IN  STD_ULOGIC; -- SHIFT BY 2
     RIGHT  : IN  STD_ULOGIC; -- BIT FROM THE RIGHT (LSB)
     LEFT   : OUT STD_ULOGIC; -- BIT FROM THE LEFT
     Q      : OUT STD_ULOGIC  -- FINAL OUTPUT
);




end fuq_mul_bthmux;

architecture fuq_mul_bthmux of fuq_mul_bthmux is

  signal center, q_b :std_ulogic ;



begin

   u_bmx_xor: center  <= x xor sneg ;

              left    <= center ; --output-- rename, no gate

   u_bmx_aoi: q_b     <= not(  ( sx  and center  ) or
                               ( sx2 and right   )    );

   u_bmx_inv: q       <= not q_b    ; -- output--



end;
