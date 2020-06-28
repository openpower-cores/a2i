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


entity fuq_loc8inc_lsb is  port(
     x           :in  std_ulogic_vector(0 to 4); 
     co_b        :out std_ulogic;
     s0          :out std_ulogic_vector(0 to 4);
     s1          :out std_ulogic_vector(0 to 4)
);
END                                 fuq_loc8inc_lsb;

ARCHITECTURE fuq_loc8inc_lsb OF fuq_loc8inc_lsb IS

  signal x_b, t2_b, t4  :std_ulogic_vector(0 to 4);









BEGIN


 i0_xb: x_b(0) <= not x(0) ; 
 i1_xb: x_b(1) <= not x(1) ;
 i2_xb: x_b(2) <= not x(2) ;
 i3_xb: x_b(3) <= not x(3) ;
 i4_xb: x_b(4) <= not x(4) ;


 i0_t2: t2_b(0) <= not( x(0) );
 i1_t2: t2_b(1) <= not( x(1) and x(2) );
 i2_t2: t2_b(2) <= not( x(2) and x(3) );
 i3_t2: t2_b(3) <= not( x(3) and x(4) );
 i4_t2: t2_b(4) <= not( x(4) );

 i0_t4: t4(0)   <= not( t2_b(0) );
 i1_t4: t4(1)   <= not( t2_b(1) or t2_b(3) );
 i2_t4: t4(2)   <= not( t2_b(2) or t2_b(4) );
 i3_t4: t4(3)   <= not( t2_b(3) );
 i4_t4: t4(4)   <= not( t2_b(4) );

 i0_t8: co_b    <= not( t4(0) and t4(1) );


  i0_s0: s0(0) <= not( x_b(0) );
  i1_s0: s0(1) <= not( x_b(1) );
  i2_s0: s0(2) <= not( x_b(2) );
  i3_s0: s0(3) <= not( x_b(3) );
  i4_s0: s0(4) <= not( x_b(4) );

  i0_s1: s1(0) <= not( x_b(0) xor t4(1) );
  i1_s1: s1(1) <= not( x_b(1) xor t4(2) );
  i2_s1: s1(2) <= not( x_b(2) xor t4(3) );
  i3_s1: s1(3) <= not( x_b(3) xor t4(4) );
  i4_s1: s1(4) <= not(            t4(4) );
       



END; 




       
