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
  use ibm.std_ulogic_ao_support.all; 
  use ibm.std_ulogic_mux_support.all; 

entity iuq_fxu_dep_cmp is

port(
     is1_v                      : in  std_ulogic;      
     is2_v                      : in  std_ulogic;
     rf0_v                      : in  std_ulogic;
     rf1_v                      : in  std_ulogic;
     ex1_v                      : in  std_ulogic;
     ex2_v                      : in  std_ulogic;
     lm0_v                      : in  std_ulogic;
     lm1_v                      : in  std_ulogic;
     lm2_v                      : in  std_ulogic;
     lm3_v                      : in  std_ulogic;
     lm4_v                      : in  std_ulogic;
     lm5_v                      : in  std_ulogic;
     lm6_v                      : in  std_ulogic;
     lm7_v                      : in  std_ulogic;

     is1_ad                     : in  std_ulogic_vector(0 to 5);
     is2_ad                     : in  std_ulogic_vector(0 to 5);
     rf0_ad                     : in  std_ulogic_vector(0 to 5);
     rf1_ad                     : in  std_ulogic_vector(0 to 5);
     ex1_ad                     : in  std_ulogic_vector(0 to 5);
     ex2_ad                     : in  std_ulogic_vector(0 to 5);
     lm0_ad                     : in  std_ulogic_vector(0 to 5);
     lm1_ad                     : in  std_ulogic_vector(0 to 5);
     lm2_ad                     : in  std_ulogic_vector(0 to 5);
     lm3_ad                     : in  std_ulogic_vector(0 to 5);
     lm4_ad                     : in  std_ulogic_vector(0 to 5);
     lm5_ad                     : in  std_ulogic_vector(0 to 5);
     lm6_ad                     : in  std_ulogic_vector(0 to 5);
     lm7_ad                     : in  std_ulogic_vector(0 to 5);

     ad_hit_b                   : out std_ulogic
     
     );
 
 
     
end iuq_fxu_dep_cmp;

architecture iuq_fxu_dep_cmp of iuq_fxu_dep_cmp is

signal lm0_ad_buf, lm0_ad_buf_b :std_ulogic_vector(0 to 5);
signal lm1_ad_buf, lm1_ad_buf_b :std_ulogic_vector(0 to 5);
signal lm2_ad_buf, lm2_ad_buf_b :std_ulogic_vector(0 to 5);
signal lm3_ad_buf, lm3_ad_buf_b :std_ulogic_vector(0 to 5);
signal lm4_ad_buf, lm4_ad_buf_b :std_ulogic_vector(0 to 5);
signal lm5_ad_buf, lm5_ad_buf_b :std_ulogic_vector(0 to 5);
signal lm6_ad_buf, lm6_ad_buf_b :std_ulogic_vector(0 to 5);
signal lm7_ad_buf, lm7_ad_buf_b :std_ulogic_vector(0 to 5);
signal ex2_ad_buf, ex2_ad_buf_b :std_ulogic_vector(0 to 5);
signal ex1_ad_buf, ex1_ad_buf_b :std_ulogic_vector(0 to 5);
signal rf1_ad_buf, rf1_ad_buf_b :std_ulogic_vector(0 to 5);
signal rf0_ad_buf, rf0_ad_buf_b :std_ulogic_vector(0 to 5);
signal is2_ad_buf, is2_ad_buf_b :std_ulogic_vector(0 to 5);
signal is1_ad_buf0, is1_ad_buf0_b :std_ulogic_vector(0 to 5);
signal is1_ad_buf1, is1_ad_buf1_b :std_ulogic_vector(0 to 5);
signal is1_ad_buf2, is1_ad_buf2_b :std_ulogic_vector(0 to 5);

signal a_eq_lm0_x  :std_ulogic_vector(0 to 5); 
signal a_eq_lm0_01_b , a_eq_lm0_23_b , a_eq_lm0_45_b  :std_ulogic;
signal a_eq_lm0_u ,a_eq_lm0_v , a_eq_lm0_b   :std_ulogic;

signal a_eq_lm1_x  :std_ulogic_vector(0 to 5); 
signal a_eq_lm1_01_b , a_eq_lm1_23_b , a_eq_lm1_45_b  :std_ulogic;
signal a_eq_lm1_u ,a_eq_lm1_v , a_eq_lm1_b   :std_ulogic;

signal a_eq_lm2_x  :std_ulogic_vector(0 to 5); 
signal a_eq_lm2_01_b , a_eq_lm2_23_b , a_eq_lm2_45_b  :std_ulogic;
signal a_eq_lm2_u ,a_eq_lm2_v , a_eq_lm2_b   :std_ulogic;

signal a_eq_lm3_x  :std_ulogic_vector(0 to 5); 
signal a_eq_lm3_01_b , a_eq_lm3_23_b , a_eq_lm3_45_b  :std_ulogic;
signal a_eq_lm3_u ,a_eq_lm3_v , a_eq_lm3_b   :std_ulogic;

signal a_eq_lm4_x  :std_ulogic_vector(0 to 5); 
signal a_eq_lm4_01_b , a_eq_lm4_23_b , a_eq_lm4_45_b  :std_ulogic;
signal a_eq_lm4_u ,a_eq_lm4_v , a_eq_lm4_b   :std_ulogic;

signal a_eq_lm5_x  :std_ulogic_vector(0 to 5); 
signal a_eq_lm5_01_b , a_eq_lm5_23_b , a_eq_lm5_45_b  :std_ulogic;
signal a_eq_lm5_u ,a_eq_lm5_v , a_eq_lm5_b   :std_ulogic;

signal a_eq_lm6_x  :std_ulogic_vector(0 to 5); 
signal a_eq_lm6_01_b , a_eq_lm6_23_b , a_eq_lm6_45_b  :std_ulogic;
signal a_eq_lm6_u ,a_eq_lm6_v , a_eq_lm6_b   :std_ulogic;

signal a_eq_lm7_x  :std_ulogic_vector(0 to 5); 
signal a_eq_lm7_01_b , a_eq_lm7_23_b , a_eq_lm7_45_b  :std_ulogic;
signal a_eq_lm7_u ,a_eq_lm7_v , a_eq_lm7_b   :std_ulogic;

signal a_eq_ex2_x  :std_ulogic_vector(0 to 5); 
signal a_eq_ex2_01_b , a_eq_ex2_23_b , a_eq_ex2_45_b  :std_ulogic;
signal a_eq_ex2_u ,a_eq_ex2_v , a_eq_ex2_b   :std_ulogic;

signal a_eq_ex1_x  :std_ulogic_vector(0 to 5); 
signal a_eq_ex1_01_b , a_eq_ex1_23_b , a_eq_ex1_45_b  :std_ulogic;
signal a_eq_ex1_u ,a_eq_ex1_v , a_eq_ex1_b   :std_ulogic;

signal a_eq_rf1_x  :std_ulogic_vector(0 to 5); 
signal a_eq_rf1_01_b , a_eq_rf1_23_b , a_eq_rf1_45_b  :std_ulogic;
signal a_eq_rf1_u ,a_eq_rf1_v , a_eq_rf1_b   :std_ulogic;

signal a_eq_rf0_x  :std_ulogic_vector(0 to 5); 
signal a_eq_rf0_01_b , a_eq_rf0_23_b , a_eq_rf0_45_b  :std_ulogic;
signal a_eq_rf0_u ,a_eq_rf0_v , a_eq_rf0_b   :std_ulogic;

signal a_eq_is2_x  :std_ulogic_vector(0 to 5); 
signal a_eq_is2_01_b , a_eq_is2_23_b , a_eq_is2_45_b  :std_ulogic;
signal a_eq_is2_u ,a_eq_is2_v , a_eq_is2_b   :std_ulogic;

signal a_or_1_1 , a_or_1_2 , a_or_1_3 , a_or_1_4  :std_ulogic;
signal a_or_1_5 , a_or_1_6  :std_ulogic;
signal a_or_2_1_b , a_or_2_2_b , a_or_2_3_b  :std_ulogic;
signal a_or_3_1 , a_or_4_b  :std_ulogic;


signal a_group_en       :std_ulogic;

signal lm0_a_cmp_en     :std_ulogic;
signal lm1_a_cmp_en     :std_ulogic;
signal lm2_a_cmp_en     :std_ulogic;
signal lm3_a_cmp_en     :std_ulogic;
signal lm4_a_cmp_en     :std_ulogic;
signal lm5_a_cmp_en     :std_ulogic;
signal lm6_a_cmp_en     :std_ulogic;
signal lm7_a_cmp_en     :std_ulogic;

signal is2_a_cmp_en     :std_ulogic;
signal rf0_a_cmp_en     :std_ulogic;
signal rf1_a_cmp_en     :std_ulogic;
signal ex1_a_cmp_en     :std_ulogic;
signal ex2_a_cmp_en     :std_ulogic;



















 
begin




ucmp_lm0adbufb: lm0_ad_buf_b(0 to 5) <= not lm0_ad(0 to 5);
ucmp_lm1adbufb: lm1_ad_buf_b(0 to 5) <= not lm1_ad(0 to 5);
ucmp_lm2adbufb: lm2_ad_buf_b(0 to 5) <= not lm2_ad(0 to 5);
ucmp_lm3adbufb: lm3_ad_buf_b(0 to 5) <= not lm3_ad(0 to 5);
ucmp_lm4adbufb: lm4_ad_buf_b(0 to 5) <= not lm4_ad(0 to 5);
ucmp_lm5adbufb: lm5_ad_buf_b(0 to 5) <= not lm5_ad(0 to 5);
ucmp_lm6adbufb: lm6_ad_buf_b(0 to 5) <= not lm6_ad(0 to 5);
ucmp_lm7adbufb: lm7_ad_buf_b(0 to 5) <= not lm7_ad(0 to 5);
ucmp_ex2adbufb: ex2_ad_buf_b(0 to 5) <= not ex2_ad(0 to 5);
ucmp_ex1adbufb: ex1_ad_buf_b(0 to 5) <= not ex1_ad(0 to 5);
ucmp_rf1adbufb: rf1_ad_buf_b(0 to 5) <= not rf1_ad(0 to 5);
ucmp_rf0adbufb: rf0_ad_buf_b(0 to 5) <= not rf0_ad(0 to 5);
ucmp_is2adbufb: is2_ad_buf_b(0 to 5) <= not is2_ad(0 to 5);
ucmp_is1adbuf0b: is1_ad_buf0_b(0 to 5) <= not is1_ad(0 to 5);
ucmp_is1adbuf1b: is1_ad_buf1_b(0 to 5) <= not is1_ad(0 to 5);
ucmp_is1adbuf2b: is1_ad_buf2_b(0 to 5) <= not is1_ad(0 to 5);

ucmp_lm0adbuf: lm0_ad_buf(0 to 5) <= not lm0_ad_buf_b(0 to 5);
ucmp_lm1adbuf: lm1_ad_buf(0 to 5) <= not lm1_ad_buf_b(0 to 5);
ucmp_lm2adbuf: lm2_ad_buf(0 to 5) <= not lm2_ad_buf_b(0 to 5);
ucmp_lm3adbuf: lm3_ad_buf(0 to 5) <= not lm3_ad_buf_b(0 to 5);
ucmp_lm4adbuf: lm4_ad_buf(0 to 5) <= not lm4_ad_buf_b(0 to 5);
ucmp_lm5adbuf: lm5_ad_buf(0 to 5) <= not lm5_ad_buf_b(0 to 5);
ucmp_lm6adbuf: lm6_ad_buf(0 to 5) <= not lm6_ad_buf_b(0 to 5);
ucmp_lm7adbuf: lm7_ad_buf(0 to 5) <= not lm7_ad_buf_b(0 to 5);
ucmp_ex2adbuf: ex2_ad_buf(0 to 5) <= not ex2_ad_buf_b(0 to 5);
ucmp_ex1adbuf: ex1_ad_buf(0 to 5) <= not ex1_ad_buf_b(0 to 5);
ucmp_rf1adbuf: rf1_ad_buf(0 to 5) <= not rf1_ad_buf_b(0 to 5);
ucmp_rf0adbuf: rf0_ad_buf(0 to 5) <= not rf0_ad_buf_b(0 to 5);
ucmp_is2adbuf: is2_ad_buf(0 to 5) <= not is2_ad_buf_b(0 to 5);
ucmp_is1adbuf0: is1_ad_buf0(0 to 5) <= not is1_ad_buf0_b(0 to 5);
ucmp_is1adbuf1: is1_ad_buf1(0 to 5) <= not is1_ad_buf1_b(0 to 5);
ucmp_is1adbuf2: is1_ad_buf2(0 to 5) <= not is1_ad_buf2_b(0 to 5);


  
ucmp_aeqis2_x:  a_eq_is2_x(0 to 5) <= not( is2_ad_buf(0 to 5) xor is1_ad_buf0(0 to 5) ); 
ucmp_aeqis2_01: a_eq_is2_01_b      <= not( a_eq_is2_x(0) and a_eq_is2_x(1) ); 
ucmp_aeqis2_23: a_eq_is2_23_b      <= not( a_eq_is2_x(2) and a_eq_is2_x(3) ); 
ucmp_aeqis2_45: a_eq_is2_45_b      <= not( a_eq_is2_x(4) and a_eq_is2_x(5) ); 
ucmp_aeqis2_u:  a_eq_is2_u         <= not( a_eq_is2_01_b or a_eq_is2_23_b ); 
ucmp_aeqis2_w:  a_eq_is2_v         <= not( a_eq_is2_45_b ); 
ucmp_aeqis2:    a_eq_is2_b         <= not( a_eq_is2_u and a_eq_is2_v and is2_a_cmp_en ); 

ucmp_aeqrf0_x:  a_eq_rf0_x(0 to 5) <= not( rf0_ad_buf(0 to 5) xor is1_ad_buf0(0 to 5) ); 
ucmp_aeqrf0_01: a_eq_rf0_01_b      <= not( a_eq_rf0_x(0) and a_eq_rf0_x(1) ); 
ucmp_aeqrf0_23: a_eq_rf0_23_b      <= not( a_eq_rf0_x(2) and a_eq_rf0_x(3) ); 
ucmp_aeqrf0_45: a_eq_rf0_45_b      <= not( a_eq_rf0_x(4) and a_eq_rf0_x(5) ); 
ucmp_aeqrf0_u:  a_eq_rf0_u         <= not( a_eq_rf0_01_b or a_eq_rf0_23_b ); 
ucmp_aeqrf0_w:  a_eq_rf0_v         <= not( a_eq_rf0_45_b ); 
ucmp_aeqrf0:    a_eq_rf0_b         <= not( a_eq_rf0_u and a_eq_rf0_v and rf0_a_cmp_en );

ucmp_aeqrf1_x:  a_eq_rf1_x(0 to 5) <= not( rf1_ad_buf(0 to 5) xor is1_ad_buf0(0 to 5) ); 
ucmp_aeqrf1_01: a_eq_rf1_01_b      <= not( a_eq_rf1_x(0) and a_eq_rf1_x(1) ); 
ucmp_aeqrf1_23: a_eq_rf1_23_b      <= not( a_eq_rf1_x(2) and a_eq_rf1_x(3) ); 
ucmp_aeqrf1_45: a_eq_rf1_45_b      <= not( a_eq_rf1_x(4) and a_eq_rf1_x(5) ); 
ucmp_aeqrf1_u:  a_eq_rf1_u         <= not( a_eq_rf1_01_b or a_eq_rf1_23_b ); 
ucmp_aeqrf1_w:  a_eq_rf1_v         <= not( a_eq_rf1_45_b ); 
ucmp_aeqrf1:    a_eq_rf1_b         <= not( a_eq_rf1_u and a_eq_rf1_v and rf1_a_cmp_en ); 

ucmp_aeqex1_x:  a_eq_ex1_x(0 to 5) <= not( ex1_ad_buf(0 to 5) xor is1_ad_buf0(0 to 5) ); 
ucmp_aeqex1_01: a_eq_ex1_01_b      <= not( a_eq_ex1_x(0) and a_eq_ex1_x(1) ); 
ucmp_aeqex1_23: a_eq_ex1_23_b      <= not( a_eq_ex1_x(2) and a_eq_ex1_x(3) ); 
ucmp_aeqex1_45: a_eq_ex1_45_b      <= not( a_eq_ex1_x(4) and a_eq_ex1_x(5) ); 
ucmp_aeqex1_u:  a_eq_ex1_u         <= not( a_eq_ex1_01_b or a_eq_ex1_23_b ); 
ucmp_aeqex1_w:  a_eq_ex1_v         <= not( a_eq_ex1_45_b ); 
ucmp_aeqex1:    a_eq_ex1_b         <= not( a_eq_ex1_u and a_eq_ex1_v and ex1_a_cmp_en ); 

ucmp_aeqex2_x:  a_eq_ex2_x(0 to 5) <= not( ex2_ad_buf(0 to 5) xor is1_ad_buf0(0 to 5) ); 
ucmp_aeqex2_01: a_eq_ex2_01_b      <= not( a_eq_ex2_x(0) and a_eq_ex2_x(1) ); 
ucmp_aeqex2_23: a_eq_ex2_23_b      <= not( a_eq_ex2_x(2) and a_eq_ex2_x(3) ); 
ucmp_aeqex2_45: a_eq_ex2_45_b      <= not( a_eq_ex2_x(4) and a_eq_ex2_x(5) ); 
ucmp_aeqex2_u:  a_eq_ex2_u         <= not( a_eq_ex2_01_b or a_eq_ex2_23_b ); 
ucmp_aeqex2_w:  a_eq_ex2_v         <= not( a_eq_ex2_45_b ); 
ucmp_aeqex2:    a_eq_ex2_b         <= not( a_eq_ex2_u and a_eq_ex2_v and ex2_a_cmp_en ); 

ucmp_aeqlm0_x:  a_eq_lm0_x(0 to 5) <= not( lm0_ad_buf(0 to 5) xor is1_ad_buf1(0 to 5) ); 
ucmp_aeqlm0_01: a_eq_lm0_01_b      <= not( a_eq_lm0_x(0) and a_eq_lm0_x(1) ); 
ucmp_aeqlm0_23: a_eq_lm0_23_b      <= not( a_eq_lm0_x(2) and a_eq_lm0_x(3) ); 
ucmp_aeqlm0_45: a_eq_lm0_45_b      <= not( a_eq_lm0_x(4) and a_eq_lm0_x(5) ); 
ucmp_aeqlm0_u:  a_eq_lm0_u         <= not( a_eq_lm0_01_b or a_eq_lm0_23_b ); 
ucmp_aeqlm0_w:  a_eq_lm0_v         <= not( a_eq_lm0_45_b ); 
ucmp_aeqlm0:    a_eq_lm0_b         <= not( a_eq_lm0_u and a_eq_lm0_v and lm0_a_cmp_en ); 

ucmp_aeqlm1_x:  a_eq_lm1_x(0 to 5) <= not( lm1_ad_buf(0 to 5) xor is1_ad_buf1(0 to 5) ); 
ucmp_aeqlm1_01: a_eq_lm1_01_b      <= not( a_eq_lm1_x(0) and a_eq_lm1_x(1) ); 
ucmp_aeqlm1_23: a_eq_lm1_23_b      <= not( a_eq_lm1_x(2) and a_eq_lm1_x(3) ); 
ucmp_aeqlm1_45: a_eq_lm1_45_b      <= not( a_eq_lm1_x(4) and a_eq_lm1_x(5) ); 
ucmp_aeqlm1_u:  a_eq_lm1_u         <= not( a_eq_lm1_01_b or a_eq_lm1_23_b ); 
ucmp_aeqlm1_w:  a_eq_lm1_v         <= not( a_eq_lm1_45_b ); 
ucmp_aeqlm1:    a_eq_lm1_b         <= not( a_eq_lm1_u and a_eq_lm1_v and lm1_a_cmp_en ); 

ucmp_aeqlm2_x:  a_eq_lm2_x(0 to 5) <= not( lm2_ad_buf(0 to 5) xor is1_ad_buf1(0 to 5) ); 
ucmp_aeqlm2_01: a_eq_lm2_01_b      <= not( a_eq_lm2_x(0) and a_eq_lm2_x(1) ); 
ucmp_aeqlm2_23: a_eq_lm2_23_b      <= not( a_eq_lm2_x(2) and a_eq_lm2_x(3) ); 
ucmp_aeqlm2_45: a_eq_lm2_45_b      <= not( a_eq_lm2_x(4) and a_eq_lm2_x(5) ); 
ucmp_aeqlm2_u:  a_eq_lm2_u         <= not( a_eq_lm2_01_b or a_eq_lm2_23_b ); 
ucmp_aeqlm2_w:  a_eq_lm2_v         <= not( a_eq_lm2_45_b ); 
ucmp_aeqlm2:    a_eq_lm2_b         <= not( a_eq_lm2_u and a_eq_lm2_v and lm2_a_cmp_en ); 

ucmp_aeqlm3_x:  a_eq_lm3_x(0 to 5) <= not( lm3_ad_buf(0 to 5) xor is1_ad_buf1(0 to 5) ); 
ucmp_aeqlm3_01: a_eq_lm3_01_b      <= not( a_eq_lm3_x(0) and a_eq_lm3_x(1) ); 
ucmp_aeqlm3_23: a_eq_lm3_23_b      <= not( a_eq_lm3_x(2) and a_eq_lm3_x(3) ); 
ucmp_aeqlm3_45: a_eq_lm3_45_b      <= not( a_eq_lm3_x(4) and a_eq_lm3_x(5) ); 
ucmp_aeqlm3_u:  a_eq_lm3_u         <= not( a_eq_lm3_01_b or a_eq_lm3_23_b ); 
ucmp_aeqlm3_w:  a_eq_lm3_v         <= not( a_eq_lm3_45_b ); 
ucmp_aeqlm3:    a_eq_lm3_b         <= not( a_eq_lm3_u and a_eq_lm3_v and lm3_a_cmp_en ); 

ucmp_aeqlm4_x:  a_eq_lm4_x(0 to 5) <= not( lm4_ad_buf(0 to 5) xor is1_ad_buf2(0 to 5) ); 
ucmp_aeqlm4_01: a_eq_lm4_01_b      <= not( a_eq_lm4_x(0) and a_eq_lm4_x(1) ); 
ucmp_aeqlm4_23: a_eq_lm4_23_b      <= not( a_eq_lm4_x(2) and a_eq_lm4_x(3) ); 
ucmp_aeqlm4_45: a_eq_lm4_45_b      <= not( a_eq_lm4_x(4) and a_eq_lm4_x(5) ); 
ucmp_aeqlm4_u:  a_eq_lm4_u         <= not( a_eq_lm4_01_b or a_eq_lm4_23_b ); 
ucmp_aeqlm4_w:  a_eq_lm4_v         <= not( a_eq_lm4_45_b ); 
ucmp_aeqlm4:    a_eq_lm4_b         <= not( a_eq_lm4_u and a_eq_lm4_v and lm4_a_cmp_en ); 

ucmp_aeqlm5_x:  a_eq_lm5_x(0 to 5) <= not( lm5_ad_buf(0 to 5) xor is1_ad_buf2(0 to 5) ); 
ucmp_aeqlm5_01: a_eq_lm5_01_b      <= not( a_eq_lm5_x(0) and a_eq_lm5_x(1) ); 
ucmp_aeqlm5_23: a_eq_lm5_23_b      <= not( a_eq_lm5_x(2) and a_eq_lm5_x(3) ); 
ucmp_aeqlm5_45: a_eq_lm5_45_b      <= not( a_eq_lm5_x(4) and a_eq_lm5_x(5) ); 
ucmp_aeqlm5_u:  a_eq_lm5_u         <= not( a_eq_lm5_01_b or a_eq_lm5_23_b ); 
ucmp_aeqlm5_w:  a_eq_lm5_v         <= not( a_eq_lm5_45_b ); 
ucmp_aeqlm5:    a_eq_lm5_b         <= not( a_eq_lm5_u and a_eq_lm5_v and lm5_a_cmp_en ); 

ucmp_aeqlm6_x:  a_eq_lm6_x(0 to 5) <= not( lm6_ad_buf(0 to 5) xor is1_ad_buf2(0 to 5) ); 
ucmp_aeqlm6_01: a_eq_lm6_01_b      <= not( a_eq_lm6_x(0) and a_eq_lm6_x(1) ); 
ucmp_aeqlm6_23: a_eq_lm6_23_b      <= not( a_eq_lm6_x(2) and a_eq_lm6_x(3) ); 
ucmp_aeqlm6_45: a_eq_lm6_45_b      <= not( a_eq_lm6_x(4) and a_eq_lm6_x(5) ); 
ucmp_aeqlm6_u:  a_eq_lm6_u         <= not( a_eq_lm6_01_b or a_eq_lm6_23_b ); 
ucmp_aeqlm6_w:  a_eq_lm6_v         <= not( a_eq_lm6_45_b ); 
ucmp_aeqlm6:    a_eq_lm6_b         <= not( a_eq_lm6_u and a_eq_lm6_v and lm6_a_cmp_en ); 

ucmp_aeqlm7_x:  a_eq_lm7_x(0 to 5) <= not( lm7_ad_buf(0 to 5) xor is1_ad_buf2(0 to 5) ); 
ucmp_aeqlm7_01: a_eq_lm7_01_b      <= not( a_eq_lm7_x(0) and a_eq_lm7_x(1) ); 
ucmp_aeqlm7_23: a_eq_lm7_23_b      <= not( a_eq_lm7_x(2) and a_eq_lm7_x(3) ); 
ucmp_aeqlm7_45: a_eq_lm7_45_b      <= not( a_eq_lm7_x(4) and a_eq_lm7_x(5) ); 
ucmp_aeqlm7_u:  a_eq_lm7_u         <= not( a_eq_lm7_01_b or a_eq_lm7_23_b ); 
ucmp_aeqlm7_w:  a_eq_lm7_v         <= not( a_eq_lm7_45_b ); 
ucmp_aeqlm7:    a_eq_lm7_b         <= not( a_eq_lm7_u and a_eq_lm7_v and lm7_a_cmp_en ); 
  


ucmp_aor11: a_or_1_1   <= not( a_eq_lm0_b and a_eq_lm1_b );
ucmp_aor12: a_or_1_2   <= not( a_eq_lm2_b and a_eq_lm3_b );
ucmp_aor13: a_or_1_3   <= not( a_eq_lm4_b and a_eq_lm5_b );
ucmp_aor14: a_or_1_4   <= not( a_eq_lm6_b and a_eq_lm7_b );
ucmp_aor15: a_or_1_5   <= not( a_eq_ex2_b and a_eq_ex1_b );
ucmp_aor16: a_or_1_6   <= not( a_eq_rf1_b and a_eq_rf0_b and a_eq_is2_b );

ucmp_aor21: a_or_2_1_b <= not( a_or_1_1   or  a_or_1_2 );
ucmp_aor22: a_or_2_2_b <= not( a_or_1_3   or  a_or_1_4 );
ucmp_aor23: a_or_2_3_b <= not( a_or_1_5   or  a_or_1_6 );

ucmp_aor31: a_or_3_1   <= not( a_or_2_1_b and a_or_2_2_b and a_or_2_3_b );

ucmp_aor4:  a_or_4_b   <= not( a_group_en and a_or_3_1);




a_group_en   <= is1_v; 

lm0_a_cmp_en <= lm0_v;
lm1_a_cmp_en <= lm1_v;
lm2_a_cmp_en <= lm2_v;
lm3_a_cmp_en <= lm3_v;
lm4_a_cmp_en <= lm4_v;
lm5_a_cmp_en <= lm5_v;
lm6_a_cmp_en <= lm6_v;
lm7_a_cmp_en <= lm7_v;
is2_a_cmp_en <= is2_v;
rf0_a_cmp_en <= rf0_v;
rf1_a_cmp_en <= rf1_v;
ex1_a_cmp_en <= ex1_v;
ex2_a_cmp_en <= ex2_v;

ad_hit_b     <= a_or_4_b;

    
end iuq_fxu_dep_cmp;

