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


 
entity fuq_nrm_or16 is
generic(       expand_type               : integer := 2  ); 
port(
      f_add_ex4_res    :in   std_ulogic_vector(0 to 162) ;
      ex4_or_grp16     :out  std_ulogic_vector(0 to 10)  
);



end fuq_nrm_or16; 

architecture fuq_nrm_or16 of fuq_nrm_or16 is

   constant tiup : std_ulogic := '1';
   constant tidn : std_ulogic := '0';

signal ex4_res_b :std_ulogic_vector(0 to 162);
signal g00_or02 :std_ulogic_vector(0 to 3);
signal g01_or02, g02_or02, g03_or02, g04_or02, g05_or02, g06_or02, g07_or02, g08_or02, g09_or02 :std_ulogic_vector(0 to 7);
signal g10_or02 :std_ulogic_vector(0 to 5);

signal g00_or04_b :std_ulogic_vector(0 to 1);
signal g01_or04_b :std_ulogic_vector(0 to 3);
signal g02_or04_b :std_ulogic_vector(0 to 3);
signal g03_or04_b :std_ulogic_vector(0 to 3);
signal g04_or04_b :std_ulogic_vector(0 to 3);
signal g05_or04_b :std_ulogic_vector(0 to 3);
signal g06_or04_b :std_ulogic_vector(0 to 3);
signal g07_or04_b :std_ulogic_vector(0 to 3);
signal g08_or04_b :std_ulogic_vector(0 to 3);
signal g09_or04_b :std_ulogic_vector(0 to 3);
signal g10_or04_b :std_ulogic_vector(0 to 2);


signal g00_or08 :std_ulogic_vector(0 to 0);
signal g01_or08 :std_ulogic_vector(0 to 1);
signal g02_or08 :std_ulogic_vector(0 to 1);
signal g03_or08 :std_ulogic_vector(0 to 1);
signal g04_or08 :std_ulogic_vector(0 to 1);
signal g05_or08 :std_ulogic_vector(0 to 1);
signal g06_or08 :std_ulogic_vector(0 to 1);
signal g07_or08 :std_ulogic_vector(0 to 1);
signal g08_or08 :std_ulogic_vector(0 to 1);
signal g09_or08 :std_ulogic_vector(0 to 1);
signal g10_or08 :std_ulogic_vector(0 to 1);

signal g00_or16_b :std_ulogic ;
signal g01_or16_b :std_ulogic ;
signal g02_or16_b :std_ulogic ;
signal g03_or16_b :std_ulogic ;
signal g04_or16_b :std_ulogic ;
signal g05_or16_b :std_ulogic ;
signal g06_or16_b :std_ulogic ;
signal g07_or16_b :std_ulogic ;
signal g08_or16_b :std_ulogic ;
signal g09_or16_b :std_ulogic ;
signal g10_or16_b :std_ulogic ;









begin



u_or_inv:  ex4_res_b(0 to 162) <= not f_add_ex4_res(0 to 162); 



u_g00_or02_0: g00_or02(0) <= not( ex4_res_b(  0) and ex4_res_b(  1) ); 
u_g00_or02_1: g00_or02(1) <= not( ex4_res_b(  2) and ex4_res_b(  3) ); 
u_g00_or02_2: g00_or02(2) <= not( ex4_res_b(  4) and ex4_res_b(  5) ); 
u_g00_or02_3: g00_or02(3) <= not( ex4_res_b(  6) and ex4_res_b(  7) ); 

u_g01_or02_0: g01_or02(0) <= not( ex4_res_b(  8) and ex4_res_b(  9) ); 
u_g01_or02_1: g01_or02(1) <= not( ex4_res_b( 10) and ex4_res_b( 11) ); 
u_g01_or02_2: g01_or02(2) <= not( ex4_res_b( 12) and ex4_res_b( 13) ); 
u_g01_or02_3: g01_or02(3) <= not( ex4_res_b( 14) and ex4_res_b( 15) ); 
u_g01_or02_4: g01_or02(4) <= not( ex4_res_b( 16) and ex4_res_b( 17) ); 
u_g01_or02_5: g01_or02(5) <= not( ex4_res_b( 18) and ex4_res_b( 19) ); 
u_g01_or02_6: g01_or02(6) <= not( ex4_res_b( 20) and ex4_res_b( 21) ); 
u_g01_or02_7: g01_or02(7) <= not( ex4_res_b( 22) and ex4_res_b( 23) ); 

u_g02_or02_0: g02_or02(0) <= not( ex4_res_b( 24) and ex4_res_b( 25) ); 
u_g02_or02_1: g02_or02(1) <= not( ex4_res_b( 26) and ex4_res_b( 27) ); 
u_g02_or02_2: g02_or02(2) <= not( ex4_res_b( 28) and ex4_res_b( 29) ); 
u_g02_or02_3: g02_or02(3) <= not( ex4_res_b( 30) and ex4_res_b( 31) ); 
u_g02_or02_4: g02_or02(4) <= not( ex4_res_b( 32) and ex4_res_b( 33) ); 
u_g02_or02_5: g02_or02(5) <= not( ex4_res_b( 34) and ex4_res_b( 35) ); 
u_g02_or02_6: g02_or02(6) <= not( ex4_res_b( 36) and ex4_res_b( 37) ); 
u_g02_or02_7: g02_or02(7) <= not( ex4_res_b( 38) and ex4_res_b( 39) ); 

u_g03_or02_0: g03_or02(0) <= not( ex4_res_b( 40) and ex4_res_b( 41) ); 
u_g03_or02_1: g03_or02(1) <= not( ex4_res_b( 42) and ex4_res_b( 43) ); 
u_g03_or02_2: g03_or02(2) <= not( ex4_res_b( 44) and ex4_res_b( 45) ); 
u_g03_or02_3: g03_or02(3) <= not( ex4_res_b( 46) and ex4_res_b( 47) ); 
u_g03_or02_4: g03_or02(4) <= not( ex4_res_b( 48) and ex4_res_b( 49) ); 
u_g03_or02_5: g03_or02(5) <= not( ex4_res_b( 50) and ex4_res_b( 51) ); 
u_g03_or02_6: g03_or02(6) <= not( ex4_res_b( 52) and ex4_res_b( 53) ); 
u_g03_or02_7: g03_or02(7) <= not( ex4_res_b( 54) and ex4_res_b( 55) ); 

u_g04_or02_0: g04_or02(0) <= not( ex4_res_b( 56) and ex4_res_b( 57) ); 
u_g04_or02_1: g04_or02(1) <= not( ex4_res_b( 58) and ex4_res_b( 59) ); 
u_g04_or02_2: g04_or02(2) <= not( ex4_res_b( 60) and ex4_res_b( 61) ); 
u_g04_or02_3: g04_or02(3) <= not( ex4_res_b( 62) and ex4_res_b( 63) ); 
u_g04_or02_4: g04_or02(4) <= not( ex4_res_b( 64) and ex4_res_b( 65) ); 
u_g04_or02_5: g04_or02(5) <= not( ex4_res_b( 66) and ex4_res_b( 67) ); 
u_g04_or02_6: g04_or02(6) <= not( ex4_res_b( 68) and ex4_res_b( 69) ); 
u_g04_or02_7: g04_or02(7) <= not( ex4_res_b( 70) and ex4_res_b( 71) ); 

u_g05_or02_0: g05_or02(0) <= not( ex4_res_b( 72) and ex4_res_b( 73) ); 
u_g05_or02_1: g05_or02(1) <= not( ex4_res_b( 74) and ex4_res_b( 75) ); 
u_g05_or02_2: g05_or02(2) <= not( ex4_res_b( 76) and ex4_res_b( 77) ); 
u_g05_or02_3: g05_or02(3) <= not( ex4_res_b( 78) and ex4_res_b( 79) ); 
u_g05_or02_4: g05_or02(4) <= not( ex4_res_b( 80) and ex4_res_b( 81) ); 
u_g05_or02_5: g05_or02(5) <= not( ex4_res_b( 82) and ex4_res_b( 83) ); 
u_g05_or02_6: g05_or02(6) <= not( ex4_res_b( 84) and ex4_res_b( 85) ); 
u_g05_or02_7: g05_or02(7) <= not( ex4_res_b( 86) and ex4_res_b( 87) ); 

u_g06_or02_0: g06_or02(0) <= not( ex4_res_b( 88) and ex4_res_b( 89) ); 
u_g06_or02_1: g06_or02(1) <= not( ex4_res_b( 90) and ex4_res_b( 91) ); 
u_g06_or02_2: g06_or02(2) <= not( ex4_res_b( 92) and ex4_res_b( 93) ); 
u_g06_or02_3: g06_or02(3) <= not( ex4_res_b( 94) and ex4_res_b( 95) ); 
u_g06_or02_4: g06_or02(4) <= not( ex4_res_b( 96) and ex4_res_b( 97) ); 
u_g06_or02_5: g06_or02(5) <= not( ex4_res_b( 98) and ex4_res_b( 99) ); 
u_g06_or02_6: g06_or02(6) <= not( ex4_res_b(100) and ex4_res_b(101) ); 
u_g06_or02_7: g06_or02(7) <= not( ex4_res_b(102) and ex4_res_b(103) ); 

u_g07_or02_0: g07_or02(0) <= not( ex4_res_b(104) and ex4_res_b(105) ); 
u_g07_or02_1: g07_or02(1) <= not( ex4_res_b(106) and ex4_res_b(107) ); 
u_g07_or02_2: g07_or02(2) <= not( ex4_res_b(108) and ex4_res_b(109) ); 
u_g07_or02_3: g07_or02(3) <= not( ex4_res_b(110) and ex4_res_b(111) ); 
u_g07_or02_4: g07_or02(4) <= not( ex4_res_b(112) and ex4_res_b(113) ); 
u_g07_or02_5: g07_or02(5) <= not( ex4_res_b(114) and ex4_res_b(115) ); 
u_g07_or02_6: g07_or02(6) <= not( ex4_res_b(116) and ex4_res_b(117) ); 
u_g07_or02_7: g07_or02(7) <= not( ex4_res_b(118) and ex4_res_b(119) ); 

u_g08_or02_0: g08_or02(0) <= not( ex4_res_b(120) and ex4_res_b(121) ); 
u_g08_or02_1: g08_or02(1) <= not( ex4_res_b(122) and ex4_res_b(123) ); 
u_g08_or02_2: g08_or02(2) <= not( ex4_res_b(124) and ex4_res_b(125) ); 
u_g08_or02_3: g08_or02(3) <= not( ex4_res_b(126) and ex4_res_b(127) ); 
u_g08_or02_4: g08_or02(4) <= not( ex4_res_b(128) and ex4_res_b(129) ); 
u_g08_or02_5: g08_or02(5) <= not( ex4_res_b(130) and ex4_res_b(131) ); 
u_g08_or02_6: g08_or02(6) <= not( ex4_res_b(132) and ex4_res_b(133) ); 
u_g08_or02_7: g08_or02(7) <= not( ex4_res_b(134) and ex4_res_b(135) ); 

u_g09_or02_0: g09_or02(0) <= not( ex4_res_b(136) and ex4_res_b(137) ); 
u_g09_or02_1: g09_or02(1) <= not( ex4_res_b(138) and ex4_res_b(139) ); 
u_g09_or02_2: g09_or02(2) <= not( ex4_res_b(140) and ex4_res_b(141) ); 
u_g09_or02_3: g09_or02(3) <= not( ex4_res_b(142) and ex4_res_b(143) ); 
u_g09_or02_4: g09_or02(4) <= not( ex4_res_b(144) and ex4_res_b(145) ); 
u_g09_or02_5: g09_or02(5) <= not( ex4_res_b(146) and ex4_res_b(147) ); 
u_g09_or02_6: g09_or02(6) <= not( ex4_res_b(148) and ex4_res_b(149) ); 
u_g09_or02_7: g09_or02(7) <= not( ex4_res_b(150) and ex4_res_b(151) ); 

u_g10_or02_0: g10_or02(0) <= not( ex4_res_b(152) and ex4_res_b(153) ); 
u_g10_or02_1: g10_or02(1) <= not( ex4_res_b(154) and ex4_res_b(155) ); 
u_g10_or02_2: g10_or02(2) <= not( ex4_res_b(156) and ex4_res_b(157) ); 
u_g10_or02_3: g10_or02(3) <= not( ex4_res_b(158) and ex4_res_b(159) ); 
u_g10_or02_4: g10_or02(4) <= not( ex4_res_b(160) and ex4_res_b(161) ); 
u_g10_or02_5: g10_or02(5) <= not( ex4_res_b(162)                    ); 


u_g00_or04_0: g00_or04_b(0) <= not( g00_or02(0) or g00_or02(1) ); 
u_g00_or04_1: g00_or04_b(1) <= not( g00_or02(2) or g00_or02(3) ); 

u_g01_or04_0: g01_or04_b(0) <= not( g01_or02(0) or g01_or02(1) ); 
u_g01_or04_1: g01_or04_b(1) <= not( g01_or02(2) or g01_or02(3) ); 
u_g01_or04_2: g01_or04_b(2) <= not( g01_or02(4) or g01_or02(5) ); 
u_g01_or04_3: g01_or04_b(3) <= not( g01_or02(6) or g01_or02(7) ); 

u_g02_or04_0: g02_or04_b(0) <= not( g02_or02(0) or g02_or02(1) ); 
u_g02_or04_1: g02_or04_b(1) <= not( g02_or02(2) or g02_or02(3) ); 
u_g02_or04_2: g02_or04_b(2) <= not( g02_or02(4) or g02_or02(5) ); 
u_g02_or04_3: g02_or04_b(3) <= not( g02_or02(6) or g02_or02(7) ); 

u_g03_or04_0: g03_or04_b(0) <= not( g03_or02(0) or g03_or02(1) ); 
u_g03_or04_1: g03_or04_b(1) <= not( g03_or02(2) or g03_or02(3) ); 
u_g03_or04_2: g03_or04_b(2) <= not( g03_or02(4) or g03_or02(5) ); 
u_g03_or04_3: g03_or04_b(3) <= not( g03_or02(6) or g03_or02(7) ); 

u_g04_or04_0: g04_or04_b(0) <= not( g04_or02(0) or g04_or02(1) ); 
u_g04_or04_1: g04_or04_b(1) <= not( g04_or02(2) or g04_or02(3) ); 
u_g04_or04_2: g04_or04_b(2) <= not( g04_or02(4) or g04_or02(5) ); 
u_g04_or04_3: g04_or04_b(3) <= not( g04_or02(6) or g04_or02(7) ); 

u_g05_or04_0: g05_or04_b(0) <= not( g05_or02(0) or g05_or02(1) ); 
u_g05_or04_1: g05_or04_b(1) <= not( g05_or02(2) or g05_or02(3) ); 
u_g05_or04_2: g05_or04_b(2) <= not( g05_or02(4) or g05_or02(5) ); 
u_g05_or04_3: g05_or04_b(3) <= not( g05_or02(6) or g05_or02(7) ); 

u_g06_or04_0: g06_or04_b(0) <= not( g06_or02(0) or g06_or02(1) ); 
u_g06_or04_1: g06_or04_b(1) <= not( g06_or02(2) or g06_or02(3) ); 
u_g06_or04_2: g06_or04_b(2) <= not( g06_or02(4) or g06_or02(5) ); 
u_g06_or04_3: g06_or04_b(3) <= not( g06_or02(6) or g06_or02(7) ); 

u_g07_or04_0: g07_or04_b(0) <= not( g07_or02(0) or g07_or02(1) ); 
u_g07_or04_1: g07_or04_b(1) <= not( g07_or02(2) or g07_or02(3) ); 
u_g07_or04_2: g07_or04_b(2) <= not( g07_or02(4) or g07_or02(5) ); 
u_g07_or04_3: g07_or04_b(3) <= not( g07_or02(6) or g07_or02(7) ); 

u_g08_or04_0: g08_or04_b(0) <= not( g08_or02(0) or g08_or02(1) ); 
u_g08_or04_1: g08_or04_b(1) <= not( g08_or02(2) or g08_or02(3) ); 
u_g08_or04_2: g08_or04_b(2) <= not( g08_or02(4) or g08_or02(5) ); 
u_g08_or04_3: g08_or04_b(3) <= not( g08_or02(6) or g08_or02(7) ); 

u_g09_or04_0: g09_or04_b(0) <= not( g09_or02(0) or g09_or02(1) ); 
u_g09_or04_1: g09_or04_b(1) <= not( g09_or02(2) or g09_or02(3) ); 
u_g09_or04_2: g09_or04_b(2) <= not( g09_or02(4) or g09_or02(5) ); 
u_g09_or04_3: g09_or04_b(3) <= not( g09_or02(6) or g09_or02(7) ); 

u_g10_or04_0: g10_or04_b(0) <= not( g10_or02(0) or g10_or02(1) ); 
u_g10_or04_1: g10_or04_b(1) <= not( g10_or02(2) or g10_or02(3) ); 
u_g10_or04_2: g10_or04_b(2) <= not( g10_or02(4) or g10_or02(5) ); 



u_g00_or08_0: g00_or08(0) <= not( g00_or04_b(0) and g00_or04_b(1) ); 

u_g01_or08_0: g01_or08(0) <= not( g01_or04_b(0) and g01_or04_b(1) ); 
u_g01_or08_1: g01_or08(1) <= not( g01_or04_b(2) and g01_or04_b(3) ); 

u_g02_or08_0: g02_or08(0) <= not( g02_or04_b(0) and g02_or04_b(1) ); 
u_g02_or08_1: g02_or08(1) <= not( g02_or04_b(2) and g02_or04_b(3) ); 

u_g03_or08_0: g03_or08(0) <= not( g03_or04_b(0) and g03_or04_b(1) ); 
u_g03_or08_1: g03_or08(1) <= not( g03_or04_b(2) and g03_or04_b(3) ); 

u_g04_or08_0: g04_or08(0) <= not( g04_or04_b(0) and g04_or04_b(1) ); 
u_g04_or08_1: g04_or08(1) <= not( g04_or04_b(2) and g04_or04_b(3) ); 

u_g05_or08_0: g05_or08(0) <= not( g05_or04_b(0) and g05_or04_b(1) ); 
u_g05_or08_1: g05_or08(1) <= not( g05_or04_b(2) and g05_or04_b(3) ); 

u_g06_or08_0: g06_or08(0) <= not( g06_or04_b(0) and g06_or04_b(1) ); 
u_g06_or08_1: g06_or08(1) <= not( g06_or04_b(2) and g06_or04_b(3) ); 

u_g07_or08_0: g07_or08(0) <= not( g07_or04_b(0) and g07_or04_b(1) ); 
u_g07_or08_1: g07_or08(1) <= not( g07_or04_b(2) and g07_or04_b(3) ); 

u_g08_or08_0: g08_or08(0) <= not( g08_or04_b(0) and g08_or04_b(1) ); 
u_g08_or08_1: g08_or08(1) <= not( g08_or04_b(2) and g08_or04_b(3) ); 

u_g09_or08_0: g09_or08(0) <= not( g09_or04_b(0) and g09_or04_b(1) ); 
u_g09_or08_1: g09_or08(1) <= not( g09_or04_b(2) and g09_or04_b(3) ); 

u_g10_or08_0: g10_or08(0) <= not( g10_or04_b(0) and g10_or04_b(1) ); 
u_g10_or08_1: g10_or08(1) <= not( g10_or04_b(2)                   ); 



u_g00_or16_0: g00_or16_b <= not( g00_or08(0)    );
u_g01_or16_0: g01_or16_b <= not( g01_or08(0) or g01_or08(1) ); 
u_g02_or16_0: g02_or16_b <= not( g02_or08(0) or g02_or08(1) ); 
u_g03_or16_0: g03_or16_b <= not( g03_or08(0) or g03_or08(1) ); 
u_g04_or16_0: g04_or16_b <= not( g04_or08(0) or g04_or08(1) ); 
u_g05_or16_0: g05_or16_b <= not( g05_or08(0) or g05_or08(1) ); 
u_g06_or16_0: g06_or16_b <= not( g06_or08(0) or g06_or08(1) ); 
u_g07_or16_0: g07_or16_b <= not( g07_or08(0) or g07_or08(1) ); 
u_g08_or16_0: g08_or16_b <= not( g08_or08(0) or g08_or08(1) ); 
u_g09_or16_0: g09_or16_b <= not( g09_or08(0) or g09_or08(1) ); 
u_g10_or16_0: g10_or16_b <= not( g10_or08(0) or g10_or08(1) ); 




u_g00_drv: ex4_or_grp16(0)  <= not( g00_or16_b  ); 
u_g01_drv: ex4_or_grp16(1)  <= not( g01_or16_b  ); 
u_g02_drv: ex4_or_grp16(2)  <= not( g02_or16_b  ); 
u_g03_drv: ex4_or_grp16(3)  <= not( g03_or16_b  ); 
u_g04_drv: ex4_or_grp16(4)  <= not( g04_or16_b  ); 
u_g05_drv: ex4_or_grp16(5)  <= not( g05_or16_b  ); 
u_g06_drv: ex4_or_grp16(6)  <= not( g06_or16_b  ); 
u_g07_drv: ex4_or_grp16(7)  <= not( g07_or16_b  ); 
u_g08_drv: ex4_or_grp16(8)  <= not( g08_or16_b  ); 
u_g09_drv: ex4_or_grp16(9)  <= not( g09_or16_b  ); 
u_g10_drv: ex4_or_grp16(10) <= not( g10_or16_b  ); 

end; 


