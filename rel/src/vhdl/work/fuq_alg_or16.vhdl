-- © IBM Corp. 2020
-- This softcore is licensed under and subject to the terms of the CC-BY 4.0
-- license (https://creativecommons.org/licenses/by/4.0/legalcode). 
-- Additional rights, including the right to physically implement a softcore 
-- that is compliant with the required sections of the Power ISA 
-- Specification, will be available at no cost via the OpenPOWER Foundation. 
-- This README will be updated with additional information when OpenPOWER's 
-- license is available.


library ieee,ibm,support,tri,work;
   use ieee.std_logic_1164.all;
   use ibm.std_ulogic_unsigned.all;
   use ibm.std_ulogic_support.all; 
   use ibm.std_ulogic_function_support.all;
   use support.power_logic_pkg.all;
   use tri.tri_latches_pkg.all;
   use ibm.std_ulogic_ao_support.all; 
   use ibm.std_ulogic_mux_support.all; 
 
entity fuq_alg_or16 is
generic(       expand_type               : integer := 2  ); -- 0 - ibm tech, 1 - other );
port(
      ex2_sh_lvl2              :in   std_ulogic_vector(0 to 67) ;
      ex2_sticky_or16          :out  std_ulogic_vector(0 to 4)  
);



end fuq_alg_or16; -- ENTITY

architecture fuq_alg_or16 of fuq_alg_or16 is

  constant tiup : std_ulogic := '1';
  constant tidn : std_ulogic := '0';
  signal ex2_g1o2_b :std_ulogic_vector(0 to 7);
  signal ex2_g2o2_b :std_ulogic_vector(0 to 7);
  signal ex2_g3o2_b :std_ulogic_vector(0 to 7);
  signal ex2_g4o2_b :std_ulogic_vector(0 to 7);
  signal ex2_g1o4   :std_ulogic_vector(0 to 3);
  signal ex2_g2o4   :std_ulogic_vector(0 to 3);
  signal ex2_g3o4   :std_ulogic_vector(0 to 3);
  signal ex2_g4o4   :std_ulogic_vector(0 to 3);
  signal ex2_g0o8_b :std_ulogic_vector(0 to 1);
  signal ex2_g1o8_b :std_ulogic_vector(0 to 1);
  signal ex2_g2o8_b :std_ulogic_vector(0 to 1);
  signal ex2_g3o8_b :std_ulogic_vector(0 to 1);
  signal ex2_g4o8_b :std_ulogic_vector(0 to 1);
  signal ex2_o16, ex2_o16_b :std_ulogic_vector(0 to 4);

    


begin

------------------------------------------------------------
-- UnMapped origianl equations
------------------------------------------------------------
--  ex2_sticky_or16(4) <=  OR( ex2_sh_lvl2[52:67] );
--  ex2_sticky_or16(3) <=  OR( ex2_sh_lvl2[36:51] );
--  ex2_sticky_or16(2) <=  OR( ex2_sh_lvl2[20:35] );
--  ex2_sticky_or16(1) <=  OR( ex2_sh_lvl2[ 4:19] );
--  ex2_sticky_or16(0) <=  OR( ex2_sh_lvl2[ 0: 3] );
-----------------------------------------------------------


g1o2_0:  ex2_g1o2_b(0) <= not( ex2_sh_lvl2( 4) or ex2_sh_lvl2( 5) );
g1o2_1:  ex2_g1o2_b(1) <= not( ex2_sh_lvl2( 6) or ex2_sh_lvl2( 7) );
g1o2_2:  ex2_g1o2_b(2) <= not( ex2_sh_lvl2( 8) or ex2_sh_lvl2( 9) );
g1o2_3:  ex2_g1o2_b(3) <= not( ex2_sh_lvl2(10) or ex2_sh_lvl2(11) );
g1o2_4:  ex2_g1o2_b(4) <= not( ex2_sh_lvl2(12) or ex2_sh_lvl2(13) );
g1o2_5:  ex2_g1o2_b(5) <= not( ex2_sh_lvl2(14) or ex2_sh_lvl2(15) );
g1o2_6:  ex2_g1o2_b(6) <= not( ex2_sh_lvl2(16) or ex2_sh_lvl2(17) );
g1o2_7:  ex2_g1o2_b(7) <= not( ex2_sh_lvl2(18) or ex2_sh_lvl2(19) );

g2o2_0:  ex2_g2o2_b(0) <= not( ex2_sh_lvl2(20) or ex2_sh_lvl2(21) );
g2o2_1:  ex2_g2o2_b(1) <= not( ex2_sh_lvl2(22) or ex2_sh_lvl2(23) );
g2o2_2:  ex2_g2o2_b(2) <= not( ex2_sh_lvl2(24) or ex2_sh_lvl2(25) );
g2o2_3:  ex2_g2o2_b(3) <= not( ex2_sh_lvl2(26) or ex2_sh_lvl2(27) );
g2o2_4:  ex2_g2o2_b(4) <= not( ex2_sh_lvl2(28) or ex2_sh_lvl2(29) );
g2o2_5:  ex2_g2o2_b(5) <= not( ex2_sh_lvl2(30) or ex2_sh_lvl2(31) );
g2o2_6:  ex2_g2o2_b(6) <= not( ex2_sh_lvl2(32) or ex2_sh_lvl2(33) );
g2o2_7:  ex2_g2o2_b(7) <= not( ex2_sh_lvl2(34) or ex2_sh_lvl2(35) );

g3o2_0:  ex2_g3o2_b(0) <= not( ex2_sh_lvl2(36) or ex2_sh_lvl2(37) );
g3o2_1:  ex2_g3o2_b(1) <= not( ex2_sh_lvl2(38) or ex2_sh_lvl2(39) );
g3o2_2:  ex2_g3o2_b(2) <= not( ex2_sh_lvl2(40) or ex2_sh_lvl2(41) );
g3o2_3:  ex2_g3o2_b(3) <= not( ex2_sh_lvl2(42) or ex2_sh_lvl2(43) );
g3o2_4:  ex2_g3o2_b(4) <= not( ex2_sh_lvl2(44) or ex2_sh_lvl2(45) );
g3o2_5:  ex2_g3o2_b(5) <= not( ex2_sh_lvl2(46) or ex2_sh_lvl2(47) );
g3o2_6:  ex2_g3o2_b(6) <= not( ex2_sh_lvl2(48) or ex2_sh_lvl2(49) );
g3o2_7:  ex2_g3o2_b(7) <= not( ex2_sh_lvl2(50) or ex2_sh_lvl2(51) );

g4o2_0:  ex2_g4o2_b(0) <= not( ex2_sh_lvl2(52) or ex2_sh_lvl2(53) );
g4o2_1:  ex2_g4o2_b(1) <= not( ex2_sh_lvl2(54) or ex2_sh_lvl2(55) );
g4o2_2:  ex2_g4o2_b(2) <= not( ex2_sh_lvl2(56) or ex2_sh_lvl2(57) );
g4o2_3:  ex2_g4o2_b(3) <= not( ex2_sh_lvl2(58) or ex2_sh_lvl2(59) );
g4o2_4:  ex2_g4o2_b(4) <= not( ex2_sh_lvl2(60) or ex2_sh_lvl2(61) );
g4o2_5:  ex2_g4o2_b(5) <= not( ex2_sh_lvl2(62) or ex2_sh_lvl2(63) );
g4o2_6:  ex2_g4o2_b(6) <= not( ex2_sh_lvl2(64) or ex2_sh_lvl2(65) );
g4o2_7:  ex2_g4o2_b(7) <= not( ex2_sh_lvl2(66) or ex2_sh_lvl2(67) );

--------------------------------------------

g1o4_0: ex2_g1o4(0) <= not(ex2_g1o2_b(0) and ex2_g1o2_b(1) );
g1o4_1: ex2_g1o4(1) <= not(ex2_g1o2_b(2) and ex2_g1o2_b(3) );
g1o4_2: ex2_g1o4(2) <= not(ex2_g1o2_b(4) and ex2_g1o2_b(5) );
g1o4_3: ex2_g1o4(3) <= not(ex2_g1o2_b(6) and ex2_g1o2_b(7) );

g2o4_0: ex2_g2o4(0) <= not(ex2_g2o2_b(0) and ex2_g2o2_b(1) );
g2o4_1: ex2_g2o4(1) <= not(ex2_g2o2_b(2) and ex2_g2o2_b(3) );
g2o4_2: ex2_g2o4(2) <= not(ex2_g2o2_b(4) and ex2_g2o2_b(5) );
g2o4_3: ex2_g2o4(3) <= not(ex2_g2o2_b(6) and ex2_g2o2_b(7) );

g3o4_0: ex2_g3o4(0) <= not(ex2_g3o2_b(0) and ex2_g3o2_b(1) );
g3o4_1: ex2_g3o4(1) <= not(ex2_g3o2_b(2) and ex2_g3o2_b(3) );
g3o4_2: ex2_g3o4(2) <= not(ex2_g3o2_b(4) and ex2_g3o2_b(5) );
g3o4_3: ex2_g3o4(3) <= not(ex2_g3o2_b(6) and ex2_g3o2_b(7) );

g4o4_0: ex2_g4o4(0) <= not(ex2_g4o2_b(0) and ex2_g4o2_b(1) );
g4o4_1: ex2_g4o4(1) <= not(ex2_g4o2_b(2) and ex2_g4o2_b(3) );
g4o4_2: ex2_g4o4(2) <= not(ex2_g4o2_b(4) and ex2_g4o2_b(5) );
g4o4_3: ex2_g4o4(3) <= not(ex2_g4o2_b(6) and ex2_g4o2_b(7) );

-----------------------------------------------

g0o8_0:  ex2_g0o8_b(0) <= not( ex2_sh_lvl2( 0) or ex2_sh_lvl2( 1) );
g0o8_1:  ex2_g0o8_b(1) <= not( ex2_sh_lvl2( 2) or ex2_sh_lvl2( 3) );

g1o8_0: ex2_g1o8_b(0) <= not( ex2_g1o4(0) or ex2_g1o4(1) ); 
g1o8_1: ex2_g1o8_b(1) <= not( ex2_g1o4(2) or ex2_g1o4(3) ); 

g2o8_0: ex2_g2o8_b(0) <= not( ex2_g2o4(0) or ex2_g2o4(1) ); 
g2o8_1: ex2_g2o8_b(1) <= not( ex2_g2o4(2) or ex2_g2o4(3) ); 

g3o8_0: ex2_g3o8_b(0) <= not( ex2_g3o4(0) or ex2_g3o4(1) ); 
g3o8_1: ex2_g3o8_b(1) <= not( ex2_g3o4(2) or ex2_g3o4(3) ); 

g4o8_0: ex2_g4o8_b(0) <= not( ex2_g4o4(0) or ex2_g4o4(1) ); 
g4o8_1: ex2_g4o8_b(1) <= not( ex2_g4o4(2) or ex2_g4o4(3) ); 

--------------------------------------------------

g0o16: ex2_o16(0) <= not(ex2_g0o8_b(0) and ex2_g0o8_b(1) );
g1o16: ex2_o16(1) <= not(ex2_g1o8_b(0) and ex2_g1o8_b(1) );
g2o16: ex2_o16(2) <= not(ex2_g2o8_b(0) and ex2_g2o8_b(1) );
g3o16: ex2_o16(3) <= not(ex2_g3o8_b(0) and ex2_g3o8_b(1) );
g4o16: ex2_o16(4) <= not(ex2_g4o8_b(0) and ex2_g4o8_b(1) );

--------------------------------------------------

g0o16i: ex2_o16_b(0) <= not( ex2_o16(0) );
g1o16i: ex2_o16_b(1) <= not( ex2_o16(1) );
g2o16i: ex2_o16_b(2) <= not( ex2_o16(2) );
g3o16i: ex2_o16_b(3) <= not( ex2_o16(3) );
g4o16i: ex2_o16_b(4) <= not( ex2_o16(4) );

--------------------------------------------------

g0o16ii: ex2_sticky_or16(0) <= not( ex2_o16_b(0) );
g1o16ii: ex2_sticky_or16(1) <= not( ex2_o16_b(1) );
g2o16ii: ex2_sticky_or16(2) <= not( ex2_o16_b(2) );
g3o16ii: ex2_sticky_or16(3) <= not( ex2_o16_b(3) );
g4o16ii: ex2_sticky_or16(4) <= not( ex2_o16_b(4) );

end; -- fuq_alg_or16 ARCHITECTURE
