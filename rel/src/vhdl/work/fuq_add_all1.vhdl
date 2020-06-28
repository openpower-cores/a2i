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


entity fuq_add_all1 is port(
     ex3_inc_byt_c_b       :in  std_ulogic_vector(0 to 6); 
     ex3_inc_byt_c_glb     :out std_ulogic_vector(1 to 6);
     ex3_inc_byt_c_glb_b   :out std_ulogic_vector(1 to 6);
     ex3_inc_all1          :out std_ulogic
 );



END                                 fuq_add_all1;


ARCHITECTURE fuq_add_all1  OF fuq_add_all1  IS

 constant tiup : std_ulogic := '1';
 constant tidn : std_ulogic := '0';

 signal ex3_inc_byt_g1 :std_ulogic_vector(0 to 6);
 signal ex3_inc_byt_g2_b :std_ulogic_vector(0 to 6);
 signal ex3_inc_byt_g4   :std_ulogic_vector(0 to 6);
 signal ex3_inc_byt_g8_b :std_ulogic_vector(0 to 6);
 signal ex3_inc_byt_g_glb_int  :std_ulogic_vector(1 to 6);
  








BEGIN

 ii:    ex3_inc_byt_g1(0 to 6)  <= not ex3_inc_byt_c_b(0 to 6);

 g26:   ex3_inc_byt_g2_b(6) <= not( ex3_inc_byt_g1(6) );
 g25:   ex3_inc_byt_g2_b(5) <= not( ex3_inc_byt_g1(5) and ex3_inc_byt_g1(6) );
 g24:   ex3_inc_byt_g2_b(4) <= not( ex3_inc_byt_g1(4) and ex3_inc_byt_g1(5) );
 g23:   ex3_inc_byt_g2_b(3) <= not( ex3_inc_byt_g1(3) and ex3_inc_byt_g1(4) );
 g22:   ex3_inc_byt_g2_b(2) <= not( ex3_inc_byt_g1(2) and ex3_inc_byt_g1(3) );
 g21:   ex3_inc_byt_g2_b(1) <= not( ex3_inc_byt_g1(1) and ex3_inc_byt_g1(2) );
 g20:   ex3_inc_byt_g2_b(0) <= not( ex3_inc_byt_g1(0) and ex3_inc_byt_g1(1) );

 g46:   ex3_inc_byt_g4(6) <= not( ex3_inc_byt_g2_b(6) ); 
 g45:   ex3_inc_byt_g4(5) <= not( ex3_inc_byt_g2_b(5) ); 
 g44:   ex3_inc_byt_g4(4) <= not( ex3_inc_byt_g2_b(4) or   ex3_inc_byt_g2_b(6) ); 
 g43:   ex3_inc_byt_g4(3) <= not( ex3_inc_byt_g2_b(3) or   ex3_inc_byt_g2_b(5) ); 
 g42:   ex3_inc_byt_g4(2) <= not( ex3_inc_byt_g2_b(2) or   ex3_inc_byt_g2_b(4) ); 
 g41:   ex3_inc_byt_g4(1) <= not( ex3_inc_byt_g2_b(1) or   ex3_inc_byt_g2_b(3) ); 
 g40:   ex3_inc_byt_g4(0) <= not( ex3_inc_byt_g2_b(0) or   ex3_inc_byt_g2_b(2) ); 

 g86:   ex3_inc_byt_g8_b(6) <= not( ex3_inc_byt_g4(6) );
 g85:   ex3_inc_byt_g8_b(5) <= not( ex3_inc_byt_g4(5) );
 g84:   ex3_inc_byt_g8_b(4) <= not( ex3_inc_byt_g4(4) );
 g83:   ex3_inc_byt_g8_b(3) <= not( ex3_inc_byt_g4(3) );
 g82:   ex3_inc_byt_g8_b(2) <= not( ex3_inc_byt_g4(2) and  ex3_inc_byt_g4(6) );
 g81:   ex3_inc_byt_g8_b(1) <= not( ex3_inc_byt_g4(1) and  ex3_inc_byt_g4(5) );
 g80:   ex3_inc_byt_g8_b(0) <= not( ex3_inc_byt_g4(0) and  ex3_inc_byt_g4(4) );

 all1:   ex3_inc_all1           <= not ex3_inc_byt_g8_b(0);
 iop1:   ex3_inc_byt_c_glb(1)   <= not ex3_inc_byt_g8_b(1); 
 iop2:   ex3_inc_byt_c_glb(2)   <= not ex3_inc_byt_g8_b(2); 
 iop3:   ex3_inc_byt_c_glb(3)   <= not ex3_inc_byt_g8_b(3); 
 iop4:   ex3_inc_byt_c_glb(4)   <= not ex3_inc_byt_g8_b(4); 
 iop5:   ex3_inc_byt_c_glb(5)   <= not ex3_inc_byt_g8_b(5); 
 iop6:   ex3_inc_byt_c_glb(6)   <= not ex3_inc_byt_g8_b(6); 

 ionn1:  ex3_inc_byt_g_glb_int(1) <= not ex3_inc_byt_g8_b(1); 
 ionn2:  ex3_inc_byt_g_glb_int(2) <= not ex3_inc_byt_g8_b(2); 
 ionn3:  ex3_inc_byt_g_glb_int(3) <= not ex3_inc_byt_g8_b(3); 
 ionn4:  ex3_inc_byt_g_glb_int(4) <= not ex3_inc_byt_g8_b(4); 
 ionn5:  ex3_inc_byt_g_glb_int(5) <= not ex3_inc_byt_g8_b(5); 
 ionn6:  ex3_inc_byt_g_glb_int(6) <= not ex3_inc_byt_g8_b(6); 

 ion1:  ex3_inc_byt_c_glb_b(1) <= not ex3_inc_byt_g_glb_int(1) ; 
 ion2:  ex3_inc_byt_c_glb_b(2) <= not ex3_inc_byt_g_glb_int(2) ; 
 ion3:  ex3_inc_byt_c_glb_b(3) <= not ex3_inc_byt_g_glb_int(3) ; 
 ion4:  ex3_inc_byt_c_glb_b(4) <= not ex3_inc_byt_g_glb_int(4) ; 
 ion5:  ex3_inc_byt_c_glb_b(5) <= not ex3_inc_byt_g_glb_int(5) ; 
 ion6:  ex3_inc_byt_c_glb_b(6) <= not ex3_inc_byt_g_glb_int(6) ; 

      

END; 


