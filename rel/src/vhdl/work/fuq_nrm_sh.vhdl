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


 
entity fuq_nrm_sh is
generic(       expand_type               : integer := 2  ); -- 0 - ibm tech, 1 - other );
port(
      ----------- SHIFT CONTROLS -----------------
      f_lza_ex4_sh_rgt_en      :in   std_ulogic;
      f_lza_ex4_lza_amt_cp1    :in   std_ulogic_vector(2 to 7) ;
      f_lza_ex4_lza_dcd64_cp1  :in   std_ulogic_vector(0 to 2) ;
      f_lza_ex4_lza_dcd64_cp2  :in   std_ulogic_vector(0 to 1) ;
      f_lza_ex4_lza_dcd64_cp3  :in   std_ulogic_vector(0 to 0) ;

      ----------- SHIFT DATA -----------------
      f_add_ex4_res            :in   std_ulogic_vector(0 to 162) ;

      ---------- SHIFT OUTPUT ---------------
      ex4_sh2_o                :out  std_ulogic_vector(26 to 72);
      ex4_sh4_25               :out  std_ulogic;
      ex4_sh4_54               :out  std_ulogic;
      ex4_shift_extra_cp1      :out  std_ulogic ;
      ex4_shift_extra_cp2      :out  std_ulogic ;
      ex4_sh5_x_b              :out std_ulogic_vector(0 to 53); 
      ex4_sh5_y_b              :out std_ulogic_vector(0 to 53)  
);





end fuq_nrm_sh; -- ENTITY

architecture fuq_nrm_sh of fuq_nrm_sh is

   constant tiup : std_ulogic := '1';
   constant tidn : std_ulogic := '0';

   signal ex4_sh1_x_b :std_ulogic_vector(0 to 120);
   signal ex4_sh1_y_b :std_ulogic_vector(0 to 99);
   signal ex4_sh1_u_b :std_ulogic_vector(0 to 35);
   signal ex4_sh1_z_b :std_ulogic_vector(65 to 118);
   signal ex4_sh2_x_b, ex4_sh2_y_b :std_ulogic_vector(0 to 72);
   signal ex4_sh3_x_b, ex4_sh3_y_b :std_ulogic_vector(0 to 57);
   signal ex4_sh4_x_b, ex4_sh4_y_b :std_ulogic_vector(0 to 54);
   signal ex4_sh4_x_00_b, ex4_sh4_y_00_b :std_ulogic;
   signal ex4_shift_extra_cp1_b :std_ulogic ;
   signal ex4_shift_extra_cp2_b :std_ulogic ;
   signal ex4_shift_extra_cp3_b :std_ulogic ;
   signal ex4_shift_extra_cp4_b :std_ulogic ;
   signal ex4_shift_extra_cp3 :std_ulogic ;
   signal ex4_shift_extra_cp4 :std_ulogic ;
   signal ex4_sh4          :std_ulogic_vector(0 to 54);
   signal ex4_sh3          :std_ulogic_vector(0 to 57);
   signal ex4_sh2          :std_ulogic_vector(0 to 72);
   signal ex4_sh1          :std_ulogic_vector(0 to 120);
   signal ex4_shctl_64     :std_ulogic_vector(0 to 2);
   signal ex4_shctl_64_cp2 :std_ulogic_vector(0 to 1);
   signal ex4_shctl_64_cp3 :std_ulogic_vector(0 to 0);
   signal ex4_shctl_16     :std_ulogic_vector(0 to 3); 
   signal ex4_shctl_04     :std_ulogic_vector(0 to 3); 
   signal ex4_shctl_01     :std_ulogic_vector(0 to 3);
   signal ex4_shift_extra_10_cp3      :std_ulogic;
   signal ex4_shift_extra_20_cp3_b    :std_ulogic;
   signal ex4_shift_extra_11_cp3      :std_ulogic;
   signal ex4_shift_extra_21_cp3_b    :std_ulogic;
   signal ex4_shift_extra_31_cp3      :std_ulogic;
   signal ex4_shift_extra_10_cp4      :std_ulogic;
   signal ex4_shift_extra_20_cp4_b    :std_ulogic;
   signal ex4_shift_extra_11_cp4      :std_ulogic;
   signal ex4_shift_extra_21_cp4_b    :std_ulogic;
   signal ex4_shift_extra_31_cp4      :std_ulogic;
   signal ex4_shift_extra_00_cp3_b    :std_ulogic;
   signal ex4_shift_extra_00_cp4_b    :std_ulogic;

begin


--//##############################################
--# EX4 logic: shift decode
--//##############################################

  ex4_shctl_64(0 to 2)     <= f_lza_ex4_lza_dcd64_cp1(0 to 2) ;
  ex4_shctl_64_cp2(0 to 1) <= f_lza_ex4_lza_dcd64_cp2(0 to 1) ;
  ex4_shctl_64_cp3(0)      <= f_lza_ex4_lza_dcd64_cp3(0) ;
 
  ex4_shctl_16(0) <= not f_lza_ex4_lza_amt_cp1(2) and not f_lza_ex4_lza_amt_cp1(3) ; --SH000
  ex4_shctl_16(1) <= not f_lza_ex4_lza_amt_cp1(2) and     f_lza_ex4_lza_amt_cp1(3) ; --SH016
  ex4_shctl_16(2) <=     f_lza_ex4_lza_amt_cp1(2) and not f_lza_ex4_lza_amt_cp1(3) ; --SH032
  ex4_shctl_16(3) <=     f_lza_ex4_lza_amt_cp1(2) and     f_lza_ex4_lza_amt_cp1(3) ; --SH048
 
  ex4_shctl_04(0) <= not f_lza_ex4_lza_amt_cp1(4) and not f_lza_ex4_lza_amt_cp1(5) ; --SH000
  ex4_shctl_04(1) <= not f_lza_ex4_lza_amt_cp1(4) and     f_lza_ex4_lza_amt_cp1(5) ; --SH004
  ex4_shctl_04(2) <=     f_lza_ex4_lza_amt_cp1(4) and not f_lza_ex4_lza_amt_cp1(5) ; --SH008
  ex4_shctl_04(3) <=     f_lza_ex4_lza_amt_cp1(4) and     f_lza_ex4_lza_amt_cp1(5) ; --SH012
 
  ex4_shctl_01(0) <= not f_lza_ex4_lza_amt_cp1(6) and not f_lza_ex4_lza_amt_cp1(7) ; --SH000
  ex4_shctl_01(1) <= not f_lza_ex4_lza_amt_cp1(6) and     f_lza_ex4_lza_amt_cp1(7) ; --SH001
  ex4_shctl_01(2) <=     f_lza_ex4_lza_amt_cp1(6) and not f_lza_ex4_lza_amt_cp1(7) ; --SH002
  ex4_shctl_01(3) <=     f_lza_ex4_lza_amt_cp1(6) and     f_lza_ex4_lza_amt_cp1(7) ; --SH003
 
--//##############################################
--# EX4 logic: shifting
--//##############################################
  --//## big shifts first (come sooner from LZA,
  --//## when shift amount is [0] we need to start out with a "dummy" leading bit to sacrifice for shift_extra

  ex4_sh2_o(26 to 72) <= ex4_sh2(26 to 72); -- for sticky bit

  ex4_sh4_25 <= ex4_sh4(25) ; -- for sticky bit
  ex4_sh4_54 <= ex4_sh4(54) ; -- for sticky bit




---------------------------------------------------------
u_sh1x_000:  ex4_sh1_x_b(  0) <= not( tidn               and  ex4_shctl_64(0) );
u_sh1x_001:  ex4_sh1_x_b(  1) <= not( f_add_ex4_res(  0) and  ex4_shctl_64(0) );
u_sh1x_002:  ex4_sh1_x_b(  2) <= not( f_add_ex4_res(  1) and  ex4_shctl_64(0) );
u_sh1x_003:  ex4_sh1_x_b(  3) <= not( f_add_ex4_res(  2) and  ex4_shctl_64(0) );
u_sh1x_004:  ex4_sh1_x_b(  4) <= not( f_add_ex4_res(  3) and  ex4_shctl_64(0) );
u_sh1x_005:  ex4_sh1_x_b(  5) <= not( f_add_ex4_res(  4) and  ex4_shctl_64(0) );
u_sh1x_006:  ex4_sh1_x_b(  6) <= not( f_add_ex4_res(  5) and  ex4_shctl_64(0) );
u_sh1x_007:  ex4_sh1_x_b(  7) <= not( f_add_ex4_res(  6) and  ex4_shctl_64(0) );
u_sh1x_008:  ex4_sh1_x_b(  8) <= not( f_add_ex4_res(  7) and  ex4_shctl_64(0) );
u_sh1x_009:  ex4_sh1_x_b(  9) <= not( f_add_ex4_res(  8) and  ex4_shctl_64(0) );
u_sh1x_010:  ex4_sh1_x_b( 10) <= not( f_add_ex4_res(  9) and  ex4_shctl_64(0) );
u_sh1x_011:  ex4_sh1_x_b( 11) <= not( f_add_ex4_res( 10) and  ex4_shctl_64(0) );
u_sh1x_012:  ex4_sh1_x_b( 12) <= not( f_add_ex4_res( 11) and  ex4_shctl_64(0) );
u_sh1x_013:  ex4_sh1_x_b( 13) <= not( f_add_ex4_res( 12) and  ex4_shctl_64(0) );
u_sh1x_014:  ex4_sh1_x_b( 14) <= not( f_add_ex4_res( 13) and  ex4_shctl_64(0) );
u_sh1x_015:  ex4_sh1_x_b( 15) <= not( f_add_ex4_res( 14) and  ex4_shctl_64(0) );
u_sh1x_016:  ex4_sh1_x_b( 16) <= not( f_add_ex4_res( 15) and  ex4_shctl_64(0) );
u_sh1x_017:  ex4_sh1_x_b( 17) <= not( f_add_ex4_res( 16) and  ex4_shctl_64(0) );
u_sh1x_018:  ex4_sh1_x_b( 18) <= not( f_add_ex4_res( 17) and  ex4_shctl_64(0) );
u_sh1x_019:  ex4_sh1_x_b( 19) <= not( f_add_ex4_res( 18) and  ex4_shctl_64(0) );
u_sh1x_020:  ex4_sh1_x_b( 20) <= not( f_add_ex4_res( 19) and  ex4_shctl_64(0) );
u_sh1x_021:  ex4_sh1_x_b( 21) <= not( f_add_ex4_res( 20) and  ex4_shctl_64(0) );
u_sh1x_022:  ex4_sh1_x_b( 22) <= not( f_add_ex4_res( 21) and  ex4_shctl_64(0) );
u_sh1x_023:  ex4_sh1_x_b( 23) <= not( f_add_ex4_res( 22) and  ex4_shctl_64(0) );
u_sh1x_024:  ex4_sh1_x_b( 24) <= not( f_add_ex4_res( 23) and  ex4_shctl_64(0) );
u_sh1x_025:  ex4_sh1_x_b( 25) <= not( f_add_ex4_res( 24) and  ex4_shctl_64(0) );
u_sh1x_026:  ex4_sh1_x_b( 26) <= not( f_add_ex4_res( 25) and  ex4_shctl_64(0) );
u_sh1x_027:  ex4_sh1_x_b( 27) <= not( f_add_ex4_res( 26) and  ex4_shctl_64(0) );
u_sh1x_028:  ex4_sh1_x_b( 28) <= not( f_add_ex4_res( 27) and  ex4_shctl_64(0) );
u_sh1x_029:  ex4_sh1_x_b( 29) <= not( f_add_ex4_res( 28) and  ex4_shctl_64(0) );
u_sh1x_030:  ex4_sh1_x_b( 30) <= not( f_add_ex4_res( 29) and  ex4_shctl_64(0) );
u_sh1x_031:  ex4_sh1_x_b( 31) <= not( f_add_ex4_res( 30) and  ex4_shctl_64(0) );
u_sh1x_032:  ex4_sh1_x_b( 32) <= not( f_add_ex4_res( 31) and  ex4_shctl_64(0) );
u_sh1x_033:  ex4_sh1_x_b( 33) <= not( f_add_ex4_res( 32) and  ex4_shctl_64(0) );
u_sh1x_034:  ex4_sh1_x_b( 34) <= not( f_add_ex4_res( 33) and  ex4_shctl_64(0) );
u_sh1x_035:  ex4_sh1_x_b( 35) <= not( f_add_ex4_res( 34) and  ex4_shctl_64(0) );
u_sh1x_036:  ex4_sh1_x_b( 36) <= not( f_add_ex4_res( 35) and  ex4_shctl_64(0) );
u_sh1x_037:  ex4_sh1_x_b( 37) <= not( f_add_ex4_res( 36) and  ex4_shctl_64(0) );
u_sh1x_038:  ex4_sh1_x_b( 38) <= not( f_add_ex4_res( 37) and  ex4_shctl_64(0) );
u_sh1x_039:  ex4_sh1_x_b( 39) <= not( f_add_ex4_res( 38) and  ex4_shctl_64(0) );
u_sh1x_040:  ex4_sh1_x_b( 40) <= not( f_add_ex4_res( 39) and  ex4_shctl_64_cp2(0) );----------
u_sh1x_041:  ex4_sh1_x_b( 41) <= not( f_add_ex4_res( 40) and  ex4_shctl_64_cp2(0) );
u_sh1x_042:  ex4_sh1_x_b( 42) <= not( f_add_ex4_res( 41) and  ex4_shctl_64_cp2(0) );
u_sh1x_043:  ex4_sh1_x_b( 43) <= not( f_add_ex4_res( 42) and  ex4_shctl_64_cp2(0) );
u_sh1x_044:  ex4_sh1_x_b( 44) <= not( f_add_ex4_res( 43) and  ex4_shctl_64_cp2(0) );
u_sh1x_045:  ex4_sh1_x_b( 45) <= not( f_add_ex4_res( 44) and  ex4_shctl_64_cp2(0) );
u_sh1x_046:  ex4_sh1_x_b( 46) <= not( f_add_ex4_res( 45) and  ex4_shctl_64_cp2(0) );
u_sh1x_047:  ex4_sh1_x_b( 47) <= not( f_add_ex4_res( 46) and  ex4_shctl_64_cp2(0) );
u_sh1x_048:  ex4_sh1_x_b( 48) <= not( f_add_ex4_res( 47) and  ex4_shctl_64_cp2(0) );
u_sh1x_049:  ex4_sh1_x_b( 49) <= not( f_add_ex4_res( 48) and  ex4_shctl_64_cp2(0) );
u_sh1x_050:  ex4_sh1_x_b( 50) <= not( f_add_ex4_res( 49) and  ex4_shctl_64_cp2(0) );
u_sh1x_051:  ex4_sh1_x_b( 51) <= not( f_add_ex4_res( 50) and  ex4_shctl_64_cp2(0) );
u_sh1x_052:  ex4_sh1_x_b( 52) <= not( f_add_ex4_res( 51) and  ex4_shctl_64_cp2(0) );
u_sh1x_053:  ex4_sh1_x_b( 53) <= not( f_add_ex4_res( 52) and  ex4_shctl_64_cp2(0) );
u_sh1x_054:  ex4_sh1_x_b( 54) <= not( f_add_ex4_res( 53) and  ex4_shctl_64_cp2(0) );
u_sh1x_055:  ex4_sh1_x_b( 55) <= not( f_add_ex4_res( 54) and  ex4_shctl_64_cp2(0) );
u_sh1x_056:  ex4_sh1_x_b( 56) <= not( f_add_ex4_res( 55) and  ex4_shctl_64_cp2(0) );
u_sh1x_057:  ex4_sh1_x_b( 57) <= not( f_add_ex4_res( 56) and  ex4_shctl_64_cp2(0) );
u_sh1x_058:  ex4_sh1_x_b( 58) <= not( f_add_ex4_res( 57) and  ex4_shctl_64_cp2(0) );
u_sh1x_059:  ex4_sh1_x_b( 59) <= not( f_add_ex4_res( 58) and  ex4_shctl_64_cp2(0) );
u_sh1x_060:  ex4_sh1_x_b( 60) <= not( f_add_ex4_res( 59) and  ex4_shctl_64_cp2(0) );
u_sh1x_061:  ex4_sh1_x_b( 61) <= not( f_add_ex4_res( 60) and  ex4_shctl_64_cp2(0) );
u_sh1x_062:  ex4_sh1_x_b( 62) <= not( f_add_ex4_res( 61) and  ex4_shctl_64_cp2(0) );
u_sh1x_063:  ex4_sh1_x_b( 63) <= not( f_add_ex4_res( 62) and  ex4_shctl_64_cp2(0) );
u_sh1x_064:  ex4_sh1_x_b( 64) <= not( f_add_ex4_res( 63) and  ex4_shctl_64_cp2(0) );
u_sh1x_065:  ex4_sh1_x_b( 65) <= not( f_add_ex4_res( 64) and  ex4_shctl_64_cp2(0) );
u_sh1x_066:  ex4_sh1_x_b( 66) <= not( f_add_ex4_res( 65) and  ex4_shctl_64_cp2(0) );
u_sh1x_067:  ex4_sh1_x_b( 67) <= not( f_add_ex4_res( 66) and  ex4_shctl_64_cp2(0) );
u_sh1x_068:  ex4_sh1_x_b( 68) <= not( f_add_ex4_res( 67) and  ex4_shctl_64_cp2(0) );
u_sh1x_069:  ex4_sh1_x_b( 69) <= not( f_add_ex4_res( 68) and  ex4_shctl_64_cp2(0) );
u_sh1x_070:  ex4_sh1_x_b( 70) <= not( f_add_ex4_res( 69) and  ex4_shctl_64_cp2(0) );
u_sh1x_071:  ex4_sh1_x_b( 71) <= not( f_add_ex4_res( 70) and  ex4_shctl_64_cp2(0) );
u_sh1x_072:  ex4_sh1_x_b( 72) <= not( f_add_ex4_res( 71) and  ex4_shctl_64_cp2(0) );
u_sh1x_073:  ex4_sh1_x_b( 73) <= not( f_add_ex4_res( 72) and  ex4_shctl_64_cp2(0) );
u_sh1x_074:  ex4_sh1_x_b( 74) <= not( f_add_ex4_res( 73) and  ex4_shctl_64_cp2(0) );
u_sh1x_075:  ex4_sh1_x_b( 75) <= not( f_add_ex4_res( 74) and  ex4_shctl_64_cp2(0) );
u_sh1x_076:  ex4_sh1_x_b( 76) <= not( f_add_ex4_res( 75) and  ex4_shctl_64_cp2(0) );
u_sh1x_077:  ex4_sh1_x_b( 77) <= not( f_add_ex4_res( 76) and  ex4_shctl_64_cp2(0) );
u_sh1x_078:  ex4_sh1_x_b( 78) <= not( f_add_ex4_res( 77) and  ex4_shctl_64_cp2(0) );
u_sh1x_079:  ex4_sh1_x_b( 79) <= not( f_add_ex4_res( 78) and  ex4_shctl_64_cp2(0) );
u_sh1x_080:  ex4_sh1_x_b( 80) <= not( f_add_ex4_res( 79) and  ex4_shctl_64_cp2(0) );
u_sh1x_081:  ex4_sh1_x_b( 81) <= not( f_add_ex4_res( 80) and  ex4_shctl_64_cp3(0) );------
u_sh1x_082:  ex4_sh1_x_b( 82) <= not( f_add_ex4_res( 81) and  ex4_shctl_64_cp3(0) );
u_sh1x_083:  ex4_sh1_x_b( 83) <= not( f_add_ex4_res( 82) and  ex4_shctl_64_cp3(0) );
u_sh1x_084:  ex4_sh1_x_b( 84) <= not( f_add_ex4_res( 83) and  ex4_shctl_64_cp3(0) );
u_sh1x_085:  ex4_sh1_x_b( 85) <= not( f_add_ex4_res( 84) and  ex4_shctl_64_cp3(0) );
u_sh1x_086:  ex4_sh1_x_b( 86) <= not( f_add_ex4_res( 85) and  ex4_shctl_64_cp3(0) );
u_sh1x_087:  ex4_sh1_x_b( 87) <= not( f_add_ex4_res( 86) and  ex4_shctl_64_cp3(0) );
u_sh1x_088:  ex4_sh1_x_b( 88) <= not( f_add_ex4_res( 87) and  ex4_shctl_64_cp3(0) );
u_sh1x_089:  ex4_sh1_x_b( 89) <= not( f_add_ex4_res( 88) and  ex4_shctl_64_cp3(0) );
u_sh1x_090:  ex4_sh1_x_b( 90) <= not( f_add_ex4_res( 89) and  ex4_shctl_64_cp3(0) );
u_sh1x_091:  ex4_sh1_x_b( 91) <= not( f_add_ex4_res( 90) and  ex4_shctl_64_cp3(0) );
u_sh1x_092:  ex4_sh1_x_b( 92) <= not( f_add_ex4_res( 91) and  ex4_shctl_64_cp3(0) );
u_sh1x_093:  ex4_sh1_x_b( 93) <= not( f_add_ex4_res( 92) and  ex4_shctl_64_cp3(0) );
u_sh1x_094:  ex4_sh1_x_b( 94) <= not( f_add_ex4_res( 93) and  ex4_shctl_64_cp3(0) );
u_sh1x_095:  ex4_sh1_x_b( 95) <= not( f_add_ex4_res( 94) and  ex4_shctl_64_cp3(0) );
u_sh1x_096:  ex4_sh1_x_b( 96) <= not( f_add_ex4_res( 95) and  ex4_shctl_64_cp3(0) );
u_sh1x_097:  ex4_sh1_x_b( 97) <= not( f_add_ex4_res( 96) and  ex4_shctl_64_cp3(0) );
u_sh1x_098:  ex4_sh1_x_b( 98) <= not( f_add_ex4_res( 97) and  ex4_shctl_64_cp3(0) );
u_sh1x_099:  ex4_sh1_x_b( 99) <= not( f_add_ex4_res( 98) and  ex4_shctl_64_cp3(0) );
u_sh1x_100:  ex4_sh1_x_b(100) <= not( f_add_ex4_res( 99) and  ex4_shctl_64_cp3(0) );
u_sh1x_101:  ex4_sh1_x_b(101) <= not( f_add_ex4_res(100) and  ex4_shctl_64_cp3(0) );
u_sh1x_102:  ex4_sh1_x_b(102) <= not( f_add_ex4_res(101) and  ex4_shctl_64_cp3(0) );
u_sh1x_103:  ex4_sh1_x_b(103) <= not( f_add_ex4_res(102) and  ex4_shctl_64_cp3(0) );
u_sh1x_104:  ex4_sh1_x_b(104) <= not( f_add_ex4_res(103) and  ex4_shctl_64_cp3(0) );
u_sh1x_105:  ex4_sh1_x_b(105) <= not( f_add_ex4_res(104) and  ex4_shctl_64_cp3(0) );
u_sh1x_106:  ex4_sh1_x_b(106) <= not( f_add_ex4_res(105) and  ex4_shctl_64_cp3(0) );
u_sh1x_107:  ex4_sh1_x_b(107) <= not( f_add_ex4_res(106) and  ex4_shctl_64_cp3(0) );
u_sh1x_108:  ex4_sh1_x_b(108) <= not( f_add_ex4_res(107) and  ex4_shctl_64_cp3(0) );
u_sh1x_109:  ex4_sh1_x_b(109) <= not( f_add_ex4_res(108) and  ex4_shctl_64_cp3(0) );
u_sh1x_110:  ex4_sh1_x_b(110) <= not( f_add_ex4_res(109) and  ex4_shctl_64_cp3(0) );
u_sh1x_111:  ex4_sh1_x_b(111) <= not( f_add_ex4_res(110) and  ex4_shctl_64_cp3(0) );
u_sh1x_112:  ex4_sh1_x_b(112) <= not( f_add_ex4_res(111) and  ex4_shctl_64_cp3(0) );
u_sh1x_113:  ex4_sh1_x_b(113) <= not( f_add_ex4_res(112) and  ex4_shctl_64_cp3(0) );
u_sh1x_114:  ex4_sh1_x_b(114) <= not( f_add_ex4_res(113) and  ex4_shctl_64_cp3(0) );
u_sh1x_115:  ex4_sh1_x_b(115) <= not( f_add_ex4_res(114) and  ex4_shctl_64_cp3(0) );
u_sh1x_116:  ex4_sh1_x_b(116) <= not( f_add_ex4_res(115) and  ex4_shctl_64_cp3(0) );
u_sh1x_117:  ex4_sh1_x_b(117) <= not( f_add_ex4_res(116) and  ex4_shctl_64_cp3(0) );
u_sh1x_118:  ex4_sh1_x_b(118) <= not( f_add_ex4_res(117) and  ex4_shctl_64_cp3(0) );
u_sh1x_119:  ex4_sh1_x_b(119) <= not( f_add_ex4_res(118) and  ex4_shctl_64_cp3(0) );
u_sh1x_120:  ex4_sh1_x_b(120) <= not( f_add_ex4_res(119) and  ex4_shctl_64_cp3(0) );


u_sh1y_000:  ex4_sh1_y_b(  0) <= not( f_add_ex4_res( 63) and  ex4_shctl_64(1) );
u_sh1y_001:  ex4_sh1_y_b(  1) <= not( f_add_ex4_res( 64) and  ex4_shctl_64(1) );
u_sh1y_002:  ex4_sh1_y_b(  2) <= not( f_add_ex4_res( 65) and  ex4_shctl_64(1) );
u_sh1y_003:  ex4_sh1_y_b(  3) <= not( f_add_ex4_res( 66) and  ex4_shctl_64(1) );
u_sh1y_004:  ex4_sh1_y_b(  4) <= not( f_add_ex4_res( 67) and  ex4_shctl_64(1) );
u_sh1y_005:  ex4_sh1_y_b(  5) <= not( f_add_ex4_res( 68) and  ex4_shctl_64(1) );
u_sh1y_006:  ex4_sh1_y_b(  6) <= not( f_add_ex4_res( 69) and  ex4_shctl_64(1) );
u_sh1y_007:  ex4_sh1_y_b(  7) <= not( f_add_ex4_res( 70) and  ex4_shctl_64(1) );
u_sh1y_008:  ex4_sh1_y_b(  8) <= not( f_add_ex4_res( 71) and  ex4_shctl_64(1) );
u_sh1y_009:  ex4_sh1_y_b(  9) <= not( f_add_ex4_res( 72) and  ex4_shctl_64(1) );
u_sh1y_010:  ex4_sh1_y_b( 10) <= not( f_add_ex4_res( 73) and  ex4_shctl_64(1) );
u_sh1y_011:  ex4_sh1_y_b( 11) <= not( f_add_ex4_res( 74) and  ex4_shctl_64(1) );
u_sh1y_012:  ex4_sh1_y_b( 12) <= not( f_add_ex4_res( 75) and  ex4_shctl_64(1) );
u_sh1y_013:  ex4_sh1_y_b( 13) <= not( f_add_ex4_res( 76) and  ex4_shctl_64(1) );
u_sh1y_014:  ex4_sh1_y_b( 14) <= not( f_add_ex4_res( 77) and  ex4_shctl_64(1) );
u_sh1y_015:  ex4_sh1_y_b( 15) <= not( f_add_ex4_res( 78) and  ex4_shctl_64(1) );
u_sh1y_016:  ex4_sh1_y_b( 16) <= not( f_add_ex4_res( 79) and  ex4_shctl_64(1) );
u_sh1y_017:  ex4_sh1_y_b( 17) <= not( f_add_ex4_res( 80) and  ex4_shctl_64(1) );
u_sh1y_018:  ex4_sh1_y_b( 18) <= not( f_add_ex4_res( 81) and  ex4_shctl_64(1) );
u_sh1y_019:  ex4_sh1_y_b( 19) <= not( f_add_ex4_res( 82) and  ex4_shctl_64(1) );
u_sh1y_020:  ex4_sh1_y_b( 20) <= not( f_add_ex4_res( 83) and  ex4_shctl_64(1) );
u_sh1y_021:  ex4_sh1_y_b( 21) <= not( f_add_ex4_res( 84) and  ex4_shctl_64(1) );
u_sh1y_022:  ex4_sh1_y_b( 22) <= not( f_add_ex4_res( 85) and  ex4_shctl_64(1) );
u_sh1y_023:  ex4_sh1_y_b( 23) <= not( f_add_ex4_res( 86) and  ex4_shctl_64(1) );
u_sh1y_024:  ex4_sh1_y_b( 24) <= not( f_add_ex4_res( 87) and  ex4_shctl_64(1) );
u_sh1y_025:  ex4_sh1_y_b( 25) <= not( f_add_ex4_res( 88) and  ex4_shctl_64(1) );
u_sh1y_026:  ex4_sh1_y_b( 26) <= not( f_add_ex4_res( 89) and  ex4_shctl_64(1) );
u_sh1y_027:  ex4_sh1_y_b( 27) <= not( f_add_ex4_res( 90) and  ex4_shctl_64(1) );
u_sh1y_028:  ex4_sh1_y_b( 28) <= not( f_add_ex4_res( 91) and  ex4_shctl_64(1) );
u_sh1y_029:  ex4_sh1_y_b( 29) <= not( f_add_ex4_res( 92) and  ex4_shctl_64(1) );
u_sh1y_030:  ex4_sh1_y_b( 30) <= not( f_add_ex4_res( 93) and  ex4_shctl_64(1) );
u_sh1y_031:  ex4_sh1_y_b( 31) <= not( f_add_ex4_res( 94) and  ex4_shctl_64(1) );
u_sh1y_032:  ex4_sh1_y_b( 32) <= not( f_add_ex4_res( 95) and  ex4_shctl_64(1) );
u_sh1y_033:  ex4_sh1_y_b( 33) <= not( f_add_ex4_res( 96) and  ex4_shctl_64(1) );
u_sh1y_034:  ex4_sh1_y_b( 34) <= not( f_add_ex4_res( 97) and  ex4_shctl_64(1) );
u_sh1y_035:  ex4_sh1_y_b( 35) <= not( f_add_ex4_res( 98) and  ex4_shctl_64(1) );
u_sh1y_036:  ex4_sh1_y_b( 36) <= not( f_add_ex4_res( 99) and  ex4_shctl_64(1) );
u_sh1y_037:  ex4_sh1_y_b( 37) <= not( f_add_ex4_res(100) and  ex4_shctl_64(1) );
u_sh1y_038:  ex4_sh1_y_b( 38) <= not( f_add_ex4_res(101) and  ex4_shctl_64(1) );
u_sh1y_039:  ex4_sh1_y_b( 39) <= not( f_add_ex4_res(102) and  ex4_shctl_64(1) );
u_sh1y_040:  ex4_sh1_y_b( 40) <= not( f_add_ex4_res(103) and  ex4_shctl_64(1) );
u_sh1y_041:  ex4_sh1_y_b( 41) <= not( f_add_ex4_res(104) and  ex4_shctl_64(1) );
u_sh1y_042:  ex4_sh1_y_b( 42) <= not( f_add_ex4_res(105) and  ex4_shctl_64(1) );
u_sh1y_043:  ex4_sh1_y_b( 43) <= not( f_add_ex4_res(106) and  ex4_shctl_64(1) );
u_sh1y_044:  ex4_sh1_y_b( 44) <= not( f_add_ex4_res(107) and  ex4_shctl_64(1) );
u_sh1y_045:  ex4_sh1_y_b( 45) <= not( f_add_ex4_res(108) and  ex4_shctl_64(1) );
u_sh1y_046:  ex4_sh1_y_b( 46) <= not( f_add_ex4_res(109) and  ex4_shctl_64(1) );
u_sh1y_047:  ex4_sh1_y_b( 47) <= not( f_add_ex4_res(110) and  ex4_shctl_64(1) );
u_sh1y_048:  ex4_sh1_y_b( 48) <= not( f_add_ex4_res(111) and  ex4_shctl_64(1) );
u_sh1y_049:  ex4_sh1_y_b( 49) <= not( f_add_ex4_res(112) and  ex4_shctl_64(1) );
u_sh1y_050:  ex4_sh1_y_b( 50) <= not( f_add_ex4_res(113) and  ex4_shctl_64(1) );
u_sh1y_051:  ex4_sh1_y_b( 51) <= not( f_add_ex4_res(114) and  ex4_shctl_64(1) );
u_sh1y_052:  ex4_sh1_y_b( 52) <= not( f_add_ex4_res(115) and  ex4_shctl_64(1) );
u_sh1y_053:  ex4_sh1_y_b( 53) <= not( f_add_ex4_res(116) and  ex4_shctl_64(1) );
u_sh1y_054:  ex4_sh1_y_b( 54) <= not( f_add_ex4_res(117) and  ex4_shctl_64(1) );
u_sh1y_055:  ex4_sh1_y_b( 55) <= not( f_add_ex4_res(118) and  ex4_shctl_64_cp2(1) );
u_sh1y_056:  ex4_sh1_y_b( 56) <= not( f_add_ex4_res(119) and  ex4_shctl_64_cp2(1) );
u_sh1y_057:  ex4_sh1_y_b( 57) <= not( f_add_ex4_res(120) and  ex4_shctl_64_cp2(1) );
u_sh1y_058:  ex4_sh1_y_b( 58) <= not( f_add_ex4_res(121) and  ex4_shctl_64_cp2(1) );
u_sh1y_059:  ex4_sh1_y_b( 59) <= not( f_add_ex4_res(122) and  ex4_shctl_64_cp2(1) );
u_sh1y_060:  ex4_sh1_y_b( 60) <= not( f_add_ex4_res(123) and  ex4_shctl_64_cp2(1) );
u_sh1y_061:  ex4_sh1_y_b( 61) <= not( f_add_ex4_res(124) and  ex4_shctl_64_cp2(1) );
u_sh1y_062:  ex4_sh1_y_b( 62) <= not( f_add_ex4_res(125) and  ex4_shctl_64_cp2(1) );
u_sh1y_063:  ex4_sh1_y_b( 63) <= not( f_add_ex4_res(126) and  ex4_shctl_64_cp2(1) );
u_sh1y_064:  ex4_sh1_y_b( 64) <= not( f_add_ex4_res(127) and  ex4_shctl_64_cp2(1) );
u_sh1y_065:  ex4_sh1_y_b( 65) <= not( f_add_ex4_res(128) and  ex4_shctl_64_cp2(1) );
u_sh1y_066:  ex4_sh1_y_b( 66) <= not( f_add_ex4_res(129) and  ex4_shctl_64_cp2(1) );
u_sh1y_067:  ex4_sh1_y_b( 67) <= not( f_add_ex4_res(130) and  ex4_shctl_64_cp2(1) );
u_sh1y_068:  ex4_sh1_y_b( 68) <= not( f_add_ex4_res(131) and  ex4_shctl_64_cp2(1) );
u_sh1y_069:  ex4_sh1_y_b( 69) <= not( f_add_ex4_res(132) and  ex4_shctl_64_cp2(1) );
u_sh1y_070:  ex4_sh1_y_b( 70) <= not( f_add_ex4_res(133) and  ex4_shctl_64_cp2(1) );
u_sh1y_071:  ex4_sh1_y_b( 71) <= not( f_add_ex4_res(134) and  ex4_shctl_64_cp2(1) );
u_sh1y_072:  ex4_sh1_y_b( 72) <= not( f_add_ex4_res(135) and  ex4_shctl_64_cp2(1) );
u_sh1y_073:  ex4_sh1_y_b( 73) <= not( f_add_ex4_res(136) and  ex4_shctl_64_cp2(1) );
u_sh1y_074:  ex4_sh1_y_b( 74) <= not( f_add_ex4_res(137) and  ex4_shctl_64_cp2(1) );
u_sh1y_075:  ex4_sh1_y_b( 75) <= not( f_add_ex4_res(138) and  ex4_shctl_64_cp2(1) );
u_sh1y_076:  ex4_sh1_y_b( 76) <= not( f_add_ex4_res(139) and  ex4_shctl_64_cp2(1) );
u_sh1y_077:  ex4_sh1_y_b( 77) <= not( f_add_ex4_res(140) and  ex4_shctl_64_cp2(1) );
u_sh1y_078:  ex4_sh1_y_b( 78) <= not( f_add_ex4_res(141) and  ex4_shctl_64_cp2(1) );
u_sh1y_079:  ex4_sh1_y_b( 79) <= not( f_add_ex4_res(142) and  ex4_shctl_64_cp2(1) );
u_sh1y_080:  ex4_sh1_y_b( 80) <= not( f_add_ex4_res(143) and  ex4_shctl_64_cp2(1) );
u_sh1y_081:  ex4_sh1_y_b( 81) <= not( f_add_ex4_res(144) and  ex4_shctl_64_cp2(1) );
u_sh1y_082:  ex4_sh1_y_b( 82) <= not( f_add_ex4_res(145) and  ex4_shctl_64_cp2(1) );
u_sh1y_083:  ex4_sh1_y_b( 83) <= not( f_add_ex4_res(146) and  ex4_shctl_64_cp2(1) );
u_sh1y_084:  ex4_sh1_y_b( 84) <= not( f_add_ex4_res(147) and  ex4_shctl_64_cp2(1) );
u_sh1y_085:  ex4_sh1_y_b( 85) <= not( f_add_ex4_res(148) and  ex4_shctl_64_cp2(1) );
u_sh1y_086:  ex4_sh1_y_b( 86) <= not( f_add_ex4_res(149) and  ex4_shctl_64_cp2(1) );
u_sh1y_087:  ex4_sh1_y_b( 87) <= not( f_add_ex4_res(150) and  ex4_shctl_64_cp2(1) );
u_sh1y_088:  ex4_sh1_y_b( 88) <= not( f_add_ex4_res(151) and  ex4_shctl_64_cp2(1) );
u_sh1y_089:  ex4_sh1_y_b( 89) <= not( f_add_ex4_res(152) and  ex4_shctl_64_cp2(1) );
u_sh1y_090:  ex4_sh1_y_b( 90) <= not( f_add_ex4_res(153) and  ex4_shctl_64_cp2(1) );
u_sh1y_091:  ex4_sh1_y_b( 91) <= not( f_add_ex4_res(154) and  ex4_shctl_64_cp2(1) );
u_sh1y_092:  ex4_sh1_y_b( 92) <= not( f_add_ex4_res(155) and  ex4_shctl_64_cp2(1) );
u_sh1y_093:  ex4_sh1_y_b( 93) <= not( f_add_ex4_res(156) and  ex4_shctl_64_cp2(1) );
u_sh1y_094:  ex4_sh1_y_b( 94) <= not( f_add_ex4_res(157) and  ex4_shctl_64_cp2(1) );
u_sh1y_095:  ex4_sh1_y_b( 95) <= not( f_add_ex4_res(158) and  ex4_shctl_64_cp2(1) );
u_sh1y_096:  ex4_sh1_y_b( 96) <= not( f_add_ex4_res(159) and  ex4_shctl_64_cp2(1) );
u_sh1y_097:  ex4_sh1_y_b( 97) <= not( f_add_ex4_res(160) and  ex4_shctl_64_cp2(1) );
u_sh1y_098:  ex4_sh1_y_b( 98) <= not( f_add_ex4_res(161) and  ex4_shctl_64_cp2(1) );
u_sh1y_099:  ex4_sh1_y_b( 99) <= not( f_add_ex4_res(162) and  ex4_shctl_64_cp2(1) );

u_sh1u_000:  ex4_sh1_u_b(  0) <= not( f_add_ex4_res(127) and  ex4_shctl_64(2) );
u_sh1u_001:  ex4_sh1_u_b(  1) <= not( f_add_ex4_res(128) and  ex4_shctl_64(2) );
u_sh1u_002:  ex4_sh1_u_b(  2) <= not( f_add_ex4_res(129) and  ex4_shctl_64(2) );
u_sh1u_003:  ex4_sh1_u_b(  3) <= not( f_add_ex4_res(130) and  ex4_shctl_64(2) );
u_sh1u_004:  ex4_sh1_u_b(  4) <= not( f_add_ex4_res(131) and  ex4_shctl_64(2) );
u_sh1u_005:  ex4_sh1_u_b(  5) <= not( f_add_ex4_res(132) and  ex4_shctl_64(2) );
u_sh1u_006:  ex4_sh1_u_b(  6) <= not( f_add_ex4_res(133) and  ex4_shctl_64(2) );
u_sh1u_007:  ex4_sh1_u_b(  7) <= not( f_add_ex4_res(134) and  ex4_shctl_64(2) );
u_sh1u_008:  ex4_sh1_u_b(  8) <= not( f_add_ex4_res(135) and  ex4_shctl_64(2) );
u_sh1u_009:  ex4_sh1_u_b(  9) <= not( f_add_ex4_res(136) and  ex4_shctl_64(2) );
u_sh1u_010:  ex4_sh1_u_b( 10) <= not( f_add_ex4_res(137) and  ex4_shctl_64(2) );
u_sh1u_011:  ex4_sh1_u_b( 11) <= not( f_add_ex4_res(138) and  ex4_shctl_64(2) );
u_sh1u_012:  ex4_sh1_u_b( 12) <= not( f_add_ex4_res(139) and  ex4_shctl_64(2) );
u_sh1u_013:  ex4_sh1_u_b( 13) <= not( f_add_ex4_res(140) and  ex4_shctl_64(2) );
u_sh1u_014:  ex4_sh1_u_b( 14) <= not( f_add_ex4_res(141) and  ex4_shctl_64(2) );
u_sh1u_015:  ex4_sh1_u_b( 15) <= not( f_add_ex4_res(142) and  ex4_shctl_64(2) );
u_sh1u_016:  ex4_sh1_u_b( 16) <= not( f_add_ex4_res(143) and  ex4_shctl_64(2) );
u_sh1u_017:  ex4_sh1_u_b( 17) <= not( f_add_ex4_res(144) and  ex4_shctl_64(2) );
u_sh1u_018:  ex4_sh1_u_b( 18) <= not( f_add_ex4_res(145) and  ex4_shctl_64(2) );
u_sh1u_019:  ex4_sh1_u_b( 19) <= not( f_add_ex4_res(146) and  ex4_shctl_64(2) );
u_sh1u_020:  ex4_sh1_u_b( 20) <= not( f_add_ex4_res(147) and  ex4_shctl_64(2) );
u_sh1u_021:  ex4_sh1_u_b( 21) <= not( f_add_ex4_res(148) and  ex4_shctl_64(2) );
u_sh1u_022:  ex4_sh1_u_b( 22) <= not( f_add_ex4_res(149) and  ex4_shctl_64(2) );
u_sh1u_023:  ex4_sh1_u_b( 23) <= not( f_add_ex4_res(150) and  ex4_shctl_64(2) );
u_sh1u_024:  ex4_sh1_u_b( 24) <= not( f_add_ex4_res(151) and  ex4_shctl_64(2) );
u_sh1u_025:  ex4_sh1_u_b( 25) <= not( f_add_ex4_res(152) and  ex4_shctl_64(2) );
u_sh1u_026:  ex4_sh1_u_b( 26) <= not( f_add_ex4_res(153) and  ex4_shctl_64(2) );
u_sh1u_027:  ex4_sh1_u_b( 27) <= not( f_add_ex4_res(154) and  ex4_shctl_64(2) );
u_sh1u_028:  ex4_sh1_u_b( 28) <= not( f_add_ex4_res(155) and  ex4_shctl_64(2) );
u_sh1u_029:  ex4_sh1_u_b( 29) <= not( f_add_ex4_res(156) and  ex4_shctl_64(2) );
u_sh1u_030:  ex4_sh1_u_b( 30) <= not( f_add_ex4_res(157) and  ex4_shctl_64(2) );
u_sh1u_031:  ex4_sh1_u_b( 31) <= not( f_add_ex4_res(158) and  ex4_shctl_64(2) );
u_sh1u_032:  ex4_sh1_u_b( 32) <= not( f_add_ex4_res(159) and  ex4_shctl_64(2) );
u_sh1u_033:  ex4_sh1_u_b( 33) <= not( f_add_ex4_res(160) and  ex4_shctl_64(2) );
u_sh1u_034:  ex4_sh1_u_b( 34) <= not( f_add_ex4_res(161) and  ex4_shctl_64(2) );
u_sh1u_035:  ex4_sh1_u_b( 35) <= not( f_add_ex4_res(162) and  ex4_shctl_64(2) );

u_sh1z_065:  ex4_sh1_z_b( 65) <= not( f_add_ex4_res(  0) and f_lza_ex4_sh_rgt_en );
u_sh1z_066:  ex4_sh1_z_b( 66) <= not( f_add_ex4_res(  1) and f_lza_ex4_sh_rgt_en );
u_sh1z_067:  ex4_sh1_z_b( 67) <= not( f_add_ex4_res(  2) and f_lza_ex4_sh_rgt_en );
u_sh1z_068:  ex4_sh1_z_b( 68) <= not( f_add_ex4_res(  3) and f_lza_ex4_sh_rgt_en );
u_sh1z_069:  ex4_sh1_z_b( 69) <= not( f_add_ex4_res(  4) and f_lza_ex4_sh_rgt_en );
u_sh1z_070:  ex4_sh1_z_b( 70) <= not( f_add_ex4_res(  5) and f_lza_ex4_sh_rgt_en );
u_sh1z_071:  ex4_sh1_z_b( 71) <= not( f_add_ex4_res(  6) and f_lza_ex4_sh_rgt_en );
u_sh1z_072:  ex4_sh1_z_b( 72) <= not( f_add_ex4_res(  7) and f_lza_ex4_sh_rgt_en );
u_sh1z_073:  ex4_sh1_z_b( 73) <= not( f_add_ex4_res(  8) and f_lza_ex4_sh_rgt_en );
u_sh1z_074:  ex4_sh1_z_b( 74) <= not( f_add_ex4_res(  9) and f_lza_ex4_sh_rgt_en );
u_sh1z_075:  ex4_sh1_z_b( 75) <= not( f_add_ex4_res( 10) and f_lza_ex4_sh_rgt_en );
u_sh1z_076:  ex4_sh1_z_b( 76) <= not( f_add_ex4_res( 11) and f_lza_ex4_sh_rgt_en );
u_sh1z_077:  ex4_sh1_z_b( 77) <= not( f_add_ex4_res( 12) and f_lza_ex4_sh_rgt_en );
u_sh1z_078:  ex4_sh1_z_b( 78) <= not( f_add_ex4_res( 13) and f_lza_ex4_sh_rgt_en );
u_sh1z_079:  ex4_sh1_z_b( 79) <= not( f_add_ex4_res( 14) and f_lza_ex4_sh_rgt_en );
u_sh1z_080:  ex4_sh1_z_b( 80) <= not( f_add_ex4_res( 15) and f_lza_ex4_sh_rgt_en );
u_sh1z_081:  ex4_sh1_z_b( 81) <= not( f_add_ex4_res( 16) and f_lza_ex4_sh_rgt_en );
u_sh1z_082:  ex4_sh1_z_b( 82) <= not( f_add_ex4_res( 17) and f_lza_ex4_sh_rgt_en );
u_sh1z_083:  ex4_sh1_z_b( 83) <= not( f_add_ex4_res( 18) and f_lza_ex4_sh_rgt_en );
u_sh1z_084:  ex4_sh1_z_b( 84) <= not( f_add_ex4_res( 19) and f_lza_ex4_sh_rgt_en );
u_sh1z_085:  ex4_sh1_z_b( 85) <= not( f_add_ex4_res( 20) and f_lza_ex4_sh_rgt_en );
u_sh1z_086:  ex4_sh1_z_b( 86) <= not( f_add_ex4_res( 21) and f_lza_ex4_sh_rgt_en );
u_sh1z_087:  ex4_sh1_z_b( 87) <= not( f_add_ex4_res( 22) and f_lza_ex4_sh_rgt_en );
u_sh1z_088:  ex4_sh1_z_b( 88) <= not( f_add_ex4_res( 23) and f_lza_ex4_sh_rgt_en );
u_sh1z_089:  ex4_sh1_z_b( 89) <= not( f_add_ex4_res( 24) and f_lza_ex4_sh_rgt_en );
u_sh1z_090:  ex4_sh1_z_b( 90) <= not( f_add_ex4_res( 25) and f_lza_ex4_sh_rgt_en );
u_sh1z_091:  ex4_sh1_z_b( 91) <= not( f_add_ex4_res( 26) and f_lza_ex4_sh_rgt_en );
u_sh1z_092:  ex4_sh1_z_b( 92) <= not( f_add_ex4_res( 27) and f_lza_ex4_sh_rgt_en );
u_sh1z_093:  ex4_sh1_z_b( 93) <= not( f_add_ex4_res( 28) and f_lza_ex4_sh_rgt_en );
u_sh1z_094:  ex4_sh1_z_b( 94) <= not( f_add_ex4_res( 29) and f_lza_ex4_sh_rgt_en );
u_sh1z_095:  ex4_sh1_z_b( 95) <= not( f_add_ex4_res( 30) and f_lza_ex4_sh_rgt_en );
u_sh1z_096:  ex4_sh1_z_b( 96) <= not( f_add_ex4_res( 31) and f_lza_ex4_sh_rgt_en );
u_sh1z_097:  ex4_sh1_z_b( 97) <= not( f_add_ex4_res( 32) and f_lza_ex4_sh_rgt_en );
u_sh1z_098:  ex4_sh1_z_b( 98) <= not( f_add_ex4_res( 33) and f_lza_ex4_sh_rgt_en );
u_sh1z_099:  ex4_sh1_z_b( 99) <= not( f_add_ex4_res( 34) and f_lza_ex4_sh_rgt_en );
u_sh1z_100:  ex4_sh1_z_b(100) <= not( f_add_ex4_res( 35) and f_lza_ex4_sh_rgt_en );
u_sh1z_101:  ex4_sh1_z_b(101) <= not( f_add_ex4_res( 36) and f_lza_ex4_sh_rgt_en );
u_sh1z_102:  ex4_sh1_z_b(102) <= not( f_add_ex4_res( 37) and f_lza_ex4_sh_rgt_en );
u_sh1z_103:  ex4_sh1_z_b(103) <= not( f_add_ex4_res( 38) and f_lza_ex4_sh_rgt_en );
u_sh1z_104:  ex4_sh1_z_b(104) <= not( f_add_ex4_res( 39) and f_lza_ex4_sh_rgt_en );
u_sh1z_105:  ex4_sh1_z_b(105) <= not( f_add_ex4_res( 40) and f_lza_ex4_sh_rgt_en );
u_sh1z_106:  ex4_sh1_z_b(106) <= not( f_add_ex4_res( 41) and f_lza_ex4_sh_rgt_en );
u_sh1z_107:  ex4_sh1_z_b(107) <= not( f_add_ex4_res( 42) and f_lza_ex4_sh_rgt_en );
u_sh1z_108:  ex4_sh1_z_b(108) <= not( f_add_ex4_res( 43) and f_lza_ex4_sh_rgt_en );
u_sh1z_109:  ex4_sh1_z_b(109) <= not( f_add_ex4_res( 44) and f_lza_ex4_sh_rgt_en );
u_sh1z_110:  ex4_sh1_z_b(110) <= not( f_add_ex4_res( 45) and f_lza_ex4_sh_rgt_en );
u_sh1z_111:  ex4_sh1_z_b(111) <= not( f_add_ex4_res( 46) and f_lza_ex4_sh_rgt_en );
u_sh1z_112:  ex4_sh1_z_b(112) <= not( f_add_ex4_res( 47) and f_lza_ex4_sh_rgt_en );
u_sh1z_113:  ex4_sh1_z_b(113) <= not( f_add_ex4_res( 48) and f_lza_ex4_sh_rgt_en );
u_sh1z_114:  ex4_sh1_z_b(114) <= not( f_add_ex4_res( 49) and f_lza_ex4_sh_rgt_en );
u_sh1z_115:  ex4_sh1_z_b(115) <= not( f_add_ex4_res( 50) and f_lza_ex4_sh_rgt_en );
u_sh1z_116:  ex4_sh1_z_b(116) <= not( f_add_ex4_res( 51) and f_lza_ex4_sh_rgt_en );
u_sh1z_117:  ex4_sh1_z_b(117) <= not( f_add_ex4_res( 52) and f_lza_ex4_sh_rgt_en );
u_sh1z_118:  ex4_sh1_z_b(118) <= not( f_add_ex4_res( 53) and f_lza_ex4_sh_rgt_en );




u_sh1_000:  ex4_sh1(  0) <= not( ex4_sh1_x_b(  0) and ex4_sh1_y_b(  0)  and ex4_sh1_u_b(  0) );
u_sh1_001:  ex4_sh1(  1) <= not( ex4_sh1_x_b(  1) and ex4_sh1_y_b(  1)  and ex4_sh1_u_b(  1) );
u_sh1_002:  ex4_sh1(  2) <= not( ex4_sh1_x_b(  2) and ex4_sh1_y_b(  2)  and ex4_sh1_u_b(  2) );
u_sh1_003:  ex4_sh1(  3) <= not( ex4_sh1_x_b(  3) and ex4_sh1_y_b(  3)  and ex4_sh1_u_b(  3) );
u_sh1_004:  ex4_sh1(  4) <= not( ex4_sh1_x_b(  4) and ex4_sh1_y_b(  4)  and ex4_sh1_u_b(  4) );
u_sh1_005:  ex4_sh1(  5) <= not( ex4_sh1_x_b(  5) and ex4_sh1_y_b(  5)  and ex4_sh1_u_b(  5) );
u_sh1_006:  ex4_sh1(  6) <= not( ex4_sh1_x_b(  6) and ex4_sh1_y_b(  6)  and ex4_sh1_u_b(  6) );
u_sh1_007:  ex4_sh1(  7) <= not( ex4_sh1_x_b(  7) and ex4_sh1_y_b(  7)  and ex4_sh1_u_b(  7) );
u_sh1_008:  ex4_sh1(  8) <= not( ex4_sh1_x_b(  8) and ex4_sh1_y_b(  8)  and ex4_sh1_u_b(  8) );
u_sh1_009:  ex4_sh1(  9) <= not( ex4_sh1_x_b(  9) and ex4_sh1_y_b(  9)  and ex4_sh1_u_b(  9) );
u_sh1_010:  ex4_sh1( 10) <= not( ex4_sh1_x_b( 10) and ex4_sh1_y_b( 10)  and ex4_sh1_u_b( 10) );
u_sh1_011:  ex4_sh1( 11) <= not( ex4_sh1_x_b( 11) and ex4_sh1_y_b( 11)  and ex4_sh1_u_b( 11) );
u_sh1_012:  ex4_sh1( 12) <= not( ex4_sh1_x_b( 12) and ex4_sh1_y_b( 12)  and ex4_sh1_u_b( 12) );
u_sh1_013:  ex4_sh1( 13) <= not( ex4_sh1_x_b( 13) and ex4_sh1_y_b( 13)  and ex4_sh1_u_b( 13) );
u_sh1_014:  ex4_sh1( 14) <= not( ex4_sh1_x_b( 14) and ex4_sh1_y_b( 14)  and ex4_sh1_u_b( 14) );
u_sh1_015:  ex4_sh1( 15) <= not( ex4_sh1_x_b( 15) and ex4_sh1_y_b( 15)  and ex4_sh1_u_b( 15) );
u_sh1_016:  ex4_sh1( 16) <= not( ex4_sh1_x_b( 16) and ex4_sh1_y_b( 16)  and ex4_sh1_u_b( 16) );
u_sh1_017:  ex4_sh1( 17) <= not( ex4_sh1_x_b( 17) and ex4_sh1_y_b( 17)  and ex4_sh1_u_b( 17) );
u_sh1_018:  ex4_sh1( 18) <= not( ex4_sh1_x_b( 18) and ex4_sh1_y_b( 18)  and ex4_sh1_u_b( 18) );
u_sh1_019:  ex4_sh1( 19) <= not( ex4_sh1_x_b( 19) and ex4_sh1_y_b( 19)  and ex4_sh1_u_b( 19) );
u_sh1_020:  ex4_sh1( 20) <= not( ex4_sh1_x_b( 20) and ex4_sh1_y_b( 20)  and ex4_sh1_u_b( 20) );
u_sh1_021:  ex4_sh1( 21) <= not( ex4_sh1_x_b( 21) and ex4_sh1_y_b( 21)  and ex4_sh1_u_b( 21) );
u_sh1_022:  ex4_sh1( 22) <= not( ex4_sh1_x_b( 22) and ex4_sh1_y_b( 22)  and ex4_sh1_u_b( 22) );
u_sh1_023:  ex4_sh1( 23) <= not( ex4_sh1_x_b( 23) and ex4_sh1_y_b( 23)  and ex4_sh1_u_b( 23) );
u_sh1_024:  ex4_sh1( 24) <= not( ex4_sh1_x_b( 24) and ex4_sh1_y_b( 24)  and ex4_sh1_u_b( 24) );
u_sh1_025:  ex4_sh1( 25) <= not( ex4_sh1_x_b( 25) and ex4_sh1_y_b( 25)  and ex4_sh1_u_b( 25) );
u_sh1_026:  ex4_sh1( 26) <= not( ex4_sh1_x_b( 26) and ex4_sh1_y_b( 26)  and ex4_sh1_u_b( 26) );
u_sh1_027:  ex4_sh1( 27) <= not( ex4_sh1_x_b( 27) and ex4_sh1_y_b( 27)  and ex4_sh1_u_b( 27) );
u_sh1_028:  ex4_sh1( 28) <= not( ex4_sh1_x_b( 28) and ex4_sh1_y_b( 28)  and ex4_sh1_u_b( 28) );
u_sh1_029:  ex4_sh1( 29) <= not( ex4_sh1_x_b( 29) and ex4_sh1_y_b( 29)  and ex4_sh1_u_b( 29) );
u_sh1_030:  ex4_sh1( 30) <= not( ex4_sh1_x_b( 30) and ex4_sh1_y_b( 30)  and ex4_sh1_u_b( 30) );
u_sh1_031:  ex4_sh1( 31) <= not( ex4_sh1_x_b( 31) and ex4_sh1_y_b( 31)  and ex4_sh1_u_b( 31) );
u_sh1_032:  ex4_sh1( 32) <= not( ex4_sh1_x_b( 32) and ex4_sh1_y_b( 32)  and ex4_sh1_u_b( 32) );
u_sh1_033:  ex4_sh1( 33) <= not( ex4_sh1_x_b( 33) and ex4_sh1_y_b( 33)  and ex4_sh1_u_b( 33) );
u_sh1_034:  ex4_sh1( 34) <= not( ex4_sh1_x_b( 34) and ex4_sh1_y_b( 34)  and ex4_sh1_u_b( 34) );
u_sh1_035:  ex4_sh1( 35) <= not( ex4_sh1_x_b( 35) and ex4_sh1_y_b( 35)  and ex4_sh1_u_b( 35) );
u_sh1_036:  ex4_sh1( 36) <= not( ex4_sh1_x_b( 36) and ex4_sh1_y_b( 36)  );
u_sh1_037:  ex4_sh1( 37) <= not( ex4_sh1_x_b( 37) and ex4_sh1_y_b( 37)  );
u_sh1_038:  ex4_sh1( 38) <= not( ex4_sh1_x_b( 38) and ex4_sh1_y_b( 38)  );
u_sh1_039:  ex4_sh1( 39) <= not( ex4_sh1_x_b( 39) and ex4_sh1_y_b( 39)  );
u_sh1_040:  ex4_sh1( 40) <= not( ex4_sh1_x_b( 40) and ex4_sh1_y_b( 40)  );
u_sh1_041:  ex4_sh1( 41) <= not( ex4_sh1_x_b( 41) and ex4_sh1_y_b( 41)  );
u_sh1_042:  ex4_sh1( 42) <= not( ex4_sh1_x_b( 42) and ex4_sh1_y_b( 42)  );
u_sh1_043:  ex4_sh1( 43) <= not( ex4_sh1_x_b( 43) and ex4_sh1_y_b( 43)  );
u_sh1_044:  ex4_sh1( 44) <= not( ex4_sh1_x_b( 44) and ex4_sh1_y_b( 44)  );
u_sh1_045:  ex4_sh1( 45) <= not( ex4_sh1_x_b( 45) and ex4_sh1_y_b( 45)  );
u_sh1_046:  ex4_sh1( 46) <= not( ex4_sh1_x_b( 46) and ex4_sh1_y_b( 46)  );
u_sh1_047:  ex4_sh1( 47) <= not( ex4_sh1_x_b( 47) and ex4_sh1_y_b( 47)  );
u_sh1_048:  ex4_sh1( 48) <= not( ex4_sh1_x_b( 48) and ex4_sh1_y_b( 48)  );
u_sh1_049:  ex4_sh1( 49) <= not( ex4_sh1_x_b( 49) and ex4_sh1_y_b( 49)  );
u_sh1_050:  ex4_sh1( 50) <= not( ex4_sh1_x_b( 50) and ex4_sh1_y_b( 50)  );
u_sh1_051:  ex4_sh1( 51) <= not( ex4_sh1_x_b( 51) and ex4_sh1_y_b( 51)  );
u_sh1_052:  ex4_sh1( 52) <= not( ex4_sh1_x_b( 52) and ex4_sh1_y_b( 52)  );
u_sh1_053:  ex4_sh1( 53) <= not( ex4_sh1_x_b( 53) and ex4_sh1_y_b( 53)  );
u_sh1_054:  ex4_sh1( 54) <= not( ex4_sh1_x_b( 54) and ex4_sh1_y_b( 54)  );
u_sh1_055:  ex4_sh1( 55) <= not( ex4_sh1_x_b( 55) and ex4_sh1_y_b( 55)  );
u_sh1_056:  ex4_sh1( 56) <= not( ex4_sh1_x_b( 56) and ex4_sh1_y_b( 56)  );
u_sh1_057:  ex4_sh1( 57) <= not( ex4_sh1_x_b( 57) and ex4_sh1_y_b( 57)  );
u_sh1_058:  ex4_sh1( 58) <= not( ex4_sh1_x_b( 58) and ex4_sh1_y_b( 58)  );
u_sh1_059:  ex4_sh1( 59) <= not( ex4_sh1_x_b( 59) and ex4_sh1_y_b( 59)  );
u_sh1_060:  ex4_sh1( 60) <= not( ex4_sh1_x_b( 60) and ex4_sh1_y_b( 60)  );
u_sh1_061:  ex4_sh1( 61) <= not( ex4_sh1_x_b( 61) and ex4_sh1_y_b( 61)  );
u_sh1_062:  ex4_sh1( 62) <= not( ex4_sh1_x_b( 62) and ex4_sh1_y_b( 62)  );
u_sh1_063:  ex4_sh1( 63) <= not( ex4_sh1_x_b( 63) and ex4_sh1_y_b( 63)  );
u_sh1_064:  ex4_sh1( 64) <= not( ex4_sh1_x_b( 64) and ex4_sh1_y_b( 64)  );
u_sh1_065:  ex4_sh1( 65) <= not( ex4_sh1_x_b( 65) and ex4_sh1_y_b( 65)  and ex4_sh1_z_b( 65) );
u_sh1_066:  ex4_sh1( 66) <= not( ex4_sh1_x_b( 66) and ex4_sh1_y_b( 66)  and ex4_sh1_z_b( 66) );
u_sh1_067:  ex4_sh1( 67) <= not( ex4_sh1_x_b( 67) and ex4_sh1_y_b( 67)  and ex4_sh1_z_b( 67) );
u_sh1_068:  ex4_sh1( 68) <= not( ex4_sh1_x_b( 68) and ex4_sh1_y_b( 68)  and ex4_sh1_z_b( 68) );
u_sh1_069:  ex4_sh1( 69) <= not( ex4_sh1_x_b( 69) and ex4_sh1_y_b( 69)  and ex4_sh1_z_b( 69) );
u_sh1_070:  ex4_sh1( 70) <= not( ex4_sh1_x_b( 70) and ex4_sh1_y_b( 70)  and ex4_sh1_z_b( 70) );
u_sh1_071:  ex4_sh1( 71) <= not( ex4_sh1_x_b( 71) and ex4_sh1_y_b( 71)  and ex4_sh1_z_b( 71) );
u_sh1_072:  ex4_sh1( 72) <= not( ex4_sh1_x_b( 72) and ex4_sh1_y_b( 72)  and ex4_sh1_z_b( 72) );
u_sh1_073:  ex4_sh1( 73) <= not( ex4_sh1_x_b( 73) and ex4_sh1_y_b( 73)  and ex4_sh1_z_b( 73) );
u_sh1_074:  ex4_sh1( 74) <= not( ex4_sh1_x_b( 74) and ex4_sh1_y_b( 74)  and ex4_sh1_z_b( 74) );
u_sh1_075:  ex4_sh1( 75) <= not( ex4_sh1_x_b( 75) and ex4_sh1_y_b( 75)  and ex4_sh1_z_b( 75) );
u_sh1_076:  ex4_sh1( 76) <= not( ex4_sh1_x_b( 76) and ex4_sh1_y_b( 76)  and ex4_sh1_z_b( 76) );
u_sh1_077:  ex4_sh1( 77) <= not( ex4_sh1_x_b( 77) and ex4_sh1_y_b( 77)  and ex4_sh1_z_b( 77) );
u_sh1_078:  ex4_sh1( 78) <= not( ex4_sh1_x_b( 78) and ex4_sh1_y_b( 78)  and ex4_sh1_z_b( 78) );
u_sh1_079:  ex4_sh1( 79) <= not( ex4_sh1_x_b( 79) and ex4_sh1_y_b( 79)  and ex4_sh1_z_b( 79) );
u_sh1_080:  ex4_sh1( 80) <= not( ex4_sh1_x_b( 80) and ex4_sh1_y_b( 80)  and ex4_sh1_z_b( 80) );
u_sh1_081:  ex4_sh1( 81) <= not( ex4_sh1_x_b( 81) and ex4_sh1_y_b( 81)  and ex4_sh1_z_b( 81) );
u_sh1_082:  ex4_sh1( 82) <= not( ex4_sh1_x_b( 82) and ex4_sh1_y_b( 82)  and ex4_sh1_z_b( 82) );
u_sh1_083:  ex4_sh1( 83) <= not( ex4_sh1_x_b( 83) and ex4_sh1_y_b( 83)  and ex4_sh1_z_b( 83) );
u_sh1_084:  ex4_sh1( 84) <= not( ex4_sh1_x_b( 84) and ex4_sh1_y_b( 84)  and ex4_sh1_z_b( 84) );
u_sh1_085:  ex4_sh1( 85) <= not( ex4_sh1_x_b( 85) and ex4_sh1_y_b( 85)  and ex4_sh1_z_b( 85) );
u_sh1_086:  ex4_sh1( 86) <= not( ex4_sh1_x_b( 86) and ex4_sh1_y_b( 86)  and ex4_sh1_z_b( 86) );
u_sh1_087:  ex4_sh1( 87) <= not( ex4_sh1_x_b( 87) and ex4_sh1_y_b( 87)  and ex4_sh1_z_b( 87) );
u_sh1_088:  ex4_sh1( 88) <= not( ex4_sh1_x_b( 88) and ex4_sh1_y_b( 88)  and ex4_sh1_z_b( 88) );
u_sh1_089:  ex4_sh1( 89) <= not( ex4_sh1_x_b( 89) and ex4_sh1_y_b( 89)  and ex4_sh1_z_b( 89) );
u_sh1_090:  ex4_sh1( 90) <= not( ex4_sh1_x_b( 90) and ex4_sh1_y_b( 90)  and ex4_sh1_z_b( 90) );
u_sh1_091:  ex4_sh1( 91) <= not( ex4_sh1_x_b( 91) and ex4_sh1_y_b( 91)  and ex4_sh1_z_b( 91) );
u_sh1_092:  ex4_sh1( 92) <= not( ex4_sh1_x_b( 92) and ex4_sh1_y_b( 92)  and ex4_sh1_z_b( 92) );
u_sh1_093:  ex4_sh1( 93) <= not( ex4_sh1_x_b( 93) and ex4_sh1_y_b( 93)  and ex4_sh1_z_b( 93) );
u_sh1_094:  ex4_sh1( 94) <= not( ex4_sh1_x_b( 94) and ex4_sh1_y_b( 94)  and ex4_sh1_z_b( 94) );
u_sh1_095:  ex4_sh1( 95) <= not( ex4_sh1_x_b( 95) and ex4_sh1_y_b( 95)  and ex4_sh1_z_b( 95) );
u_sh1_096:  ex4_sh1( 96) <= not( ex4_sh1_x_b( 96) and ex4_sh1_y_b( 96)  and ex4_sh1_z_b( 96) );
u_sh1_097:  ex4_sh1( 97) <= not( ex4_sh1_x_b( 97) and ex4_sh1_y_b( 97)  and ex4_sh1_z_b( 97) );
u_sh1_098:  ex4_sh1( 98) <= not( ex4_sh1_x_b( 98) and ex4_sh1_y_b( 98)  and ex4_sh1_z_b( 98) );
u_sh1_099:  ex4_sh1( 99) <= not( ex4_sh1_x_b( 99) and ex4_sh1_y_b( 99)  and ex4_sh1_z_b( 99) );
u_sh1_100:  ex4_sh1(100) <= not( ex4_sh1_x_b(100)                       and ex4_sh1_z_b(100) );
u_sh1_101:  ex4_sh1(101) <= not( ex4_sh1_x_b(101)                       and ex4_sh1_z_b(101) );
u_sh1_102:  ex4_sh1(102) <= not( ex4_sh1_x_b(102)                       and ex4_sh1_z_b(102) );
u_sh1_103:  ex4_sh1(103) <= not( ex4_sh1_x_b(103)                       and ex4_sh1_z_b(103) );
u_sh1_104:  ex4_sh1(104) <= not( ex4_sh1_x_b(104)                       and ex4_sh1_z_b(104) );
u_sh1_105:  ex4_sh1(105) <= not( ex4_sh1_x_b(105)                       and ex4_sh1_z_b(105) );
u_sh1_106:  ex4_sh1(106) <= not( ex4_sh1_x_b(106)                       and ex4_sh1_z_b(106) );
u_sh1_107:  ex4_sh1(107) <= not( ex4_sh1_x_b(107)                       and ex4_sh1_z_b(107) );
u_sh1_108:  ex4_sh1(108) <= not( ex4_sh1_x_b(108)                       and ex4_sh1_z_b(108) );
u_sh1_109:  ex4_sh1(109) <= not( ex4_sh1_x_b(109)                       and ex4_sh1_z_b(109) );
u_sh1_110:  ex4_sh1(110) <= not( ex4_sh1_x_b(110)                       and ex4_sh1_z_b(110) );
u_sh1_111:  ex4_sh1(111) <= not( ex4_sh1_x_b(111)                       and ex4_sh1_z_b(111) );
u_sh1_112:  ex4_sh1(112) <= not( ex4_sh1_x_b(112)                       and ex4_sh1_z_b(112) );
u_sh1_113:  ex4_sh1(113) <= not( ex4_sh1_x_b(113)                       and ex4_sh1_z_b(113) );
u_sh1_114:  ex4_sh1(114) <= not( ex4_sh1_x_b(114)                       and ex4_sh1_z_b(114) );
u_sh1_115:  ex4_sh1(115) <= not( ex4_sh1_x_b(115)                       and ex4_sh1_z_b(115) );
u_sh1_116:  ex4_sh1(116) <= not( ex4_sh1_x_b(116)                       and ex4_sh1_z_b(116) );
u_sh1_117:  ex4_sh1(117) <= not( ex4_sh1_x_b(117)                       and ex4_sh1_z_b(117) );
u_sh1_118:  ex4_sh1(118) <= not( ex4_sh1_x_b(118)                       and ex4_sh1_z_b(118) );
u_sh1_119:  ex4_sh1(119) <= not( ex4_sh1_x_b(119) );
u_sh1_120:  ex4_sh1(120) <= not( ex4_sh1_x_b(120) );

 ------------------------------------------------------------------------------------


u_sh2x_00:  ex4_sh2_x_b( 0) <= not( (ex4_sh1(  0) and ex4_shctl_16(0) ) or ( ex4_sh1( 16) and ex4_shctl_16(1) ) );
u_sh2x_01:  ex4_sh2_x_b( 1) <= not( (ex4_sh1(  1) and ex4_shctl_16(0) ) or ( ex4_sh1( 17) and ex4_shctl_16(1) ) );
u_sh2x_02:  ex4_sh2_x_b( 2) <= not( (ex4_sh1(  2) and ex4_shctl_16(0) ) or ( ex4_sh1( 18) and ex4_shctl_16(1) ) );
u_sh2x_03:  ex4_sh2_x_b( 3) <= not( (ex4_sh1(  3) and ex4_shctl_16(0) ) or ( ex4_sh1( 19) and ex4_shctl_16(1) ) );
u_sh2x_04:  ex4_sh2_x_b( 4) <= not( (ex4_sh1(  4) and ex4_shctl_16(0) ) or ( ex4_sh1( 20) and ex4_shctl_16(1) ) );
u_sh2x_05:  ex4_sh2_x_b( 5) <= not( (ex4_sh1(  5) and ex4_shctl_16(0) ) or ( ex4_sh1( 21) and ex4_shctl_16(1) ) );
u_sh2x_06:  ex4_sh2_x_b( 6) <= not( (ex4_sh1(  6) and ex4_shctl_16(0) ) or ( ex4_sh1( 22) and ex4_shctl_16(1) ) );
u_sh2x_07:  ex4_sh2_x_b( 7) <= not( (ex4_sh1(  7) and ex4_shctl_16(0) ) or ( ex4_sh1( 23) and ex4_shctl_16(1) ) );
u_sh2x_08:  ex4_sh2_x_b( 8) <= not( (ex4_sh1(  8) and ex4_shctl_16(0) ) or ( ex4_sh1( 24) and ex4_shctl_16(1) ) );
u_sh2x_09:  ex4_sh2_x_b( 9) <= not( (ex4_sh1(  9) and ex4_shctl_16(0) ) or ( ex4_sh1( 25) and ex4_shctl_16(1) ) );
u_sh2x_10:  ex4_sh2_x_b(10) <= not( (ex4_sh1( 10) and ex4_shctl_16(0) ) or ( ex4_sh1( 26) and ex4_shctl_16(1) ) );
u_sh2x_11:  ex4_sh2_x_b(11) <= not( (ex4_sh1( 11) and ex4_shctl_16(0) ) or ( ex4_sh1( 27) and ex4_shctl_16(1) ) );
u_sh2x_12:  ex4_sh2_x_b(12) <= not( (ex4_sh1( 12) and ex4_shctl_16(0) ) or ( ex4_sh1( 28) and ex4_shctl_16(1) ) );
u_sh2x_13:  ex4_sh2_x_b(13) <= not( (ex4_sh1( 13) and ex4_shctl_16(0) ) or ( ex4_sh1( 29) and ex4_shctl_16(1) ) );
u_sh2x_14:  ex4_sh2_x_b(14) <= not( (ex4_sh1( 14) and ex4_shctl_16(0) ) or ( ex4_sh1( 30) and ex4_shctl_16(1) ) );
u_sh2x_15:  ex4_sh2_x_b(15) <= not( (ex4_sh1( 15) and ex4_shctl_16(0) ) or ( ex4_sh1( 31) and ex4_shctl_16(1) ) );
u_sh2x_16:  ex4_sh2_x_b(16) <= not( (ex4_sh1( 16) and ex4_shctl_16(0) ) or ( ex4_sh1( 32) and ex4_shctl_16(1) ) );
u_sh2x_17:  ex4_sh2_x_b(17) <= not( (ex4_sh1( 17) and ex4_shctl_16(0) ) or ( ex4_sh1( 33) and ex4_shctl_16(1) ) );
u_sh2x_18:  ex4_sh2_x_b(18) <= not( (ex4_sh1( 18) and ex4_shctl_16(0) ) or ( ex4_sh1( 34) and ex4_shctl_16(1) ) );
u_sh2x_19:  ex4_sh2_x_b(19) <= not( (ex4_sh1( 19) and ex4_shctl_16(0) ) or ( ex4_sh1( 35) and ex4_shctl_16(1) ) );
u_sh2x_20:  ex4_sh2_x_b(20) <= not( (ex4_sh1( 20) and ex4_shctl_16(0) ) or ( ex4_sh1( 36) and ex4_shctl_16(1) ) );
u_sh2x_21:  ex4_sh2_x_b(21) <= not( (ex4_sh1( 21) and ex4_shctl_16(0) ) or ( ex4_sh1( 37) and ex4_shctl_16(1) ) );
u_sh2x_22:  ex4_sh2_x_b(22) <= not( (ex4_sh1( 22) and ex4_shctl_16(0) ) or ( ex4_sh1( 38) and ex4_shctl_16(1) ) );
u_sh2x_23:  ex4_sh2_x_b(23) <= not( (ex4_sh1( 23) and ex4_shctl_16(0) ) or ( ex4_sh1( 39) and ex4_shctl_16(1) ) );
u_sh2x_24:  ex4_sh2_x_b(24) <= not( (ex4_sh1( 24) and ex4_shctl_16(0) ) or ( ex4_sh1( 40) and ex4_shctl_16(1) ) );
u_sh2x_25:  ex4_sh2_x_b(25) <= not( (ex4_sh1( 25) and ex4_shctl_16(0) ) or ( ex4_sh1( 41) and ex4_shctl_16(1) ) );
u_sh2x_26:  ex4_sh2_x_b(26) <= not( (ex4_sh1( 26) and ex4_shctl_16(0) ) or ( ex4_sh1( 42) and ex4_shctl_16(1) ) );
u_sh2x_27:  ex4_sh2_x_b(27) <= not( (ex4_sh1( 27) and ex4_shctl_16(0) ) or ( ex4_sh1( 43) and ex4_shctl_16(1) ) );
u_sh2x_28:  ex4_sh2_x_b(28) <= not( (ex4_sh1( 28) and ex4_shctl_16(0) ) or ( ex4_sh1( 44) and ex4_shctl_16(1) ) );
u_sh2x_29:  ex4_sh2_x_b(29) <= not( (ex4_sh1( 29) and ex4_shctl_16(0) ) or ( ex4_sh1( 45) and ex4_shctl_16(1) ) );
u_sh2x_30:  ex4_sh2_x_b(30) <= not( (ex4_sh1( 30) and ex4_shctl_16(0) ) or ( ex4_sh1( 46) and ex4_shctl_16(1) ) );
u_sh2x_31:  ex4_sh2_x_b(31) <= not( (ex4_sh1( 31) and ex4_shctl_16(0) ) or ( ex4_sh1( 47) and ex4_shctl_16(1) ) );
u_sh2x_32:  ex4_sh2_x_b(32) <= not( (ex4_sh1( 32) and ex4_shctl_16(0) ) or ( ex4_sh1( 48) and ex4_shctl_16(1) ) );
u_sh2x_33:  ex4_sh2_x_b(33) <= not( (ex4_sh1( 33) and ex4_shctl_16(0) ) or ( ex4_sh1( 49) and ex4_shctl_16(1) ) );
u_sh2x_34:  ex4_sh2_x_b(34) <= not( (ex4_sh1( 34) and ex4_shctl_16(0) ) or ( ex4_sh1( 50) and ex4_shctl_16(1) ) );
u_sh2x_35:  ex4_sh2_x_b(35) <= not( (ex4_sh1( 35) and ex4_shctl_16(0) ) or ( ex4_sh1( 51) and ex4_shctl_16(1) ) );
u_sh2x_36:  ex4_sh2_x_b(36) <= not( (ex4_sh1( 36) and ex4_shctl_16(0) ) or ( ex4_sh1( 52) and ex4_shctl_16(1) ) );
u_sh2x_37:  ex4_sh2_x_b(37) <= not( (ex4_sh1( 37) and ex4_shctl_16(0) ) or ( ex4_sh1( 53) and ex4_shctl_16(1) ) );
u_sh2x_38:  ex4_sh2_x_b(38) <= not( (ex4_sh1( 38) and ex4_shctl_16(0) ) or ( ex4_sh1( 54) and ex4_shctl_16(1) ) );
u_sh2x_39:  ex4_sh2_x_b(39) <= not( (ex4_sh1( 39) and ex4_shctl_16(0) ) or ( ex4_sh1( 55) and ex4_shctl_16(1) ) );
u_sh2x_40:  ex4_sh2_x_b(40) <= not( (ex4_sh1( 40) and ex4_shctl_16(0) ) or ( ex4_sh1( 56) and ex4_shctl_16(1) ) );
u_sh2x_41:  ex4_sh2_x_b(41) <= not( (ex4_sh1( 41) and ex4_shctl_16(0) ) or ( ex4_sh1( 57) and ex4_shctl_16(1) ) );
u_sh2x_42:  ex4_sh2_x_b(42) <= not( (ex4_sh1( 42) and ex4_shctl_16(0) ) or ( ex4_sh1( 58) and ex4_shctl_16(1) ) );
u_sh2x_43:  ex4_sh2_x_b(43) <= not( (ex4_sh1( 43) and ex4_shctl_16(0) ) or ( ex4_sh1( 59) and ex4_shctl_16(1) ) );
u_sh2x_44:  ex4_sh2_x_b(44) <= not( (ex4_sh1( 44) and ex4_shctl_16(0) ) or ( ex4_sh1( 60) and ex4_shctl_16(1) ) );
u_sh2x_45:  ex4_sh2_x_b(45) <= not( (ex4_sh1( 45) and ex4_shctl_16(0) ) or ( ex4_sh1( 61) and ex4_shctl_16(1) ) );
u_sh2x_46:  ex4_sh2_x_b(46) <= not( (ex4_sh1( 46) and ex4_shctl_16(0) ) or ( ex4_sh1( 62) and ex4_shctl_16(1) ) );
u_sh2x_47:  ex4_sh2_x_b(47) <= not( (ex4_sh1( 47) and ex4_shctl_16(0) ) or ( ex4_sh1( 63) and ex4_shctl_16(1) ) );
u_sh2x_48:  ex4_sh2_x_b(48) <= not( (ex4_sh1( 48) and ex4_shctl_16(0) ) or ( ex4_sh1( 64) and ex4_shctl_16(1) ) );
u_sh2x_49:  ex4_sh2_x_b(49) <= not( (ex4_sh1( 49) and ex4_shctl_16(0) ) or ( ex4_sh1( 65) and ex4_shctl_16(1) ) );
u_sh2x_50:  ex4_sh2_x_b(50) <= not( (ex4_sh1( 50) and ex4_shctl_16(0) ) or ( ex4_sh1( 66) and ex4_shctl_16(1) ) );
u_sh2x_51:  ex4_sh2_x_b(51) <= not( (ex4_sh1( 51) and ex4_shctl_16(0) ) or ( ex4_sh1( 67) and ex4_shctl_16(1) ) );
u_sh2x_52:  ex4_sh2_x_b(52) <= not( (ex4_sh1( 52) and ex4_shctl_16(0) ) or ( ex4_sh1( 68) and ex4_shctl_16(1) ) );
u_sh2x_53:  ex4_sh2_x_b(53) <= not( (ex4_sh1( 53) and ex4_shctl_16(0) ) or ( ex4_sh1( 69) and ex4_shctl_16(1) ) );
u_sh2x_54:  ex4_sh2_x_b(54) <= not( (ex4_sh1( 54) and ex4_shctl_16(0) ) or ( ex4_sh1( 70) and ex4_shctl_16(1) ) );
u_sh2x_55:  ex4_sh2_x_b(55) <= not( (ex4_sh1( 55) and ex4_shctl_16(0) ) or ( ex4_sh1( 71) and ex4_shctl_16(1) ) );
u_sh2x_56:  ex4_sh2_x_b(56) <= not( (ex4_sh1( 56) and ex4_shctl_16(0) ) or ( ex4_sh1( 72) and ex4_shctl_16(1) ) );
u_sh2x_57:  ex4_sh2_x_b(57) <= not( (ex4_sh1( 57) and ex4_shctl_16(0) ) or ( ex4_sh1( 73) and ex4_shctl_16(1) ) );
u_sh2x_58:  ex4_sh2_x_b(58) <= not( (ex4_sh1( 58) and ex4_shctl_16(0) ) or ( ex4_sh1( 74) and ex4_shctl_16(1) ) );
u_sh2x_59:  ex4_sh2_x_b(59) <= not( (ex4_sh1( 59) and ex4_shctl_16(0) ) or ( ex4_sh1( 75) and ex4_shctl_16(1) ) );
u_sh2x_60:  ex4_sh2_x_b(60) <= not( (ex4_sh1( 60) and ex4_shctl_16(0) ) or ( ex4_sh1( 76) and ex4_shctl_16(1) ) );
u_sh2x_61:  ex4_sh2_x_b(61) <= not( (ex4_sh1( 61) and ex4_shctl_16(0) ) or ( ex4_sh1( 77) and ex4_shctl_16(1) ) );
u_sh2x_62:  ex4_sh2_x_b(62) <= not( (ex4_sh1( 62) and ex4_shctl_16(0) ) or ( ex4_sh1( 78) and ex4_shctl_16(1) ) );
u_sh2x_63:  ex4_sh2_x_b(63) <= not( (ex4_sh1( 63) and ex4_shctl_16(0) ) or ( ex4_sh1( 79) and ex4_shctl_16(1) ) );
u_sh2x_64:  ex4_sh2_x_b(64) <= not( (ex4_sh1( 64) and ex4_shctl_16(0) ) or ( ex4_sh1( 80) and ex4_shctl_16(1) ) );
u_sh2x_65:  ex4_sh2_x_b(65) <= not( (ex4_sh1( 65) and ex4_shctl_16(0) ) or ( ex4_sh1( 81) and ex4_shctl_16(1) ) );
u_sh2x_66:  ex4_sh2_x_b(66) <= not( (ex4_sh1( 66) and ex4_shctl_16(0) ) or ( ex4_sh1( 82) and ex4_shctl_16(1) ) );
u_sh2x_67:  ex4_sh2_x_b(67) <= not( (ex4_sh1( 67) and ex4_shctl_16(0) ) or ( ex4_sh1( 83) and ex4_shctl_16(1) ) );
u_sh2x_68:  ex4_sh2_x_b(68) <= not( (ex4_sh1( 68) and ex4_shctl_16(0) ) or ( ex4_sh1( 84) and ex4_shctl_16(1) ) );
u_sh2x_69:  ex4_sh2_x_b(69) <= not( (ex4_sh1( 69) and ex4_shctl_16(0) ) or ( ex4_sh1( 85) and ex4_shctl_16(1) ) );
u_sh2x_70:  ex4_sh2_x_b(70) <= not( (ex4_sh1( 70) and ex4_shctl_16(0) ) or ( ex4_sh1( 86) and ex4_shctl_16(1) ) );
u_sh2x_71:  ex4_sh2_x_b(71) <= not( (ex4_sh1( 71) and ex4_shctl_16(0) ) or ( ex4_sh1( 87) and ex4_shctl_16(1) ) );
u_sh2x_72:  ex4_sh2_x_b(72) <= not( (ex4_sh1( 72) and ex4_shctl_16(0) ) or ( ex4_sh1( 88) and ex4_shctl_16(1) ) );

u_sh2y_00:  ex4_sh2_y_b( 0) <= not( (ex4_sh1( 32) and ex4_shctl_16(2) ) or ( ex4_sh1( 48) and ex4_shctl_16(3) ) );
u_sh2y_01:  ex4_sh2_y_b( 1) <= not( (ex4_sh1( 33) and ex4_shctl_16(2) ) or ( ex4_sh1( 49) and ex4_shctl_16(3) ) );
u_sh2y_02:  ex4_sh2_y_b( 2) <= not( (ex4_sh1( 34) and ex4_shctl_16(2) ) or ( ex4_sh1( 50) and ex4_shctl_16(3) ) );
u_sh2y_03:  ex4_sh2_y_b( 3) <= not( (ex4_sh1( 35) and ex4_shctl_16(2) ) or ( ex4_sh1( 51) and ex4_shctl_16(3) ) );
u_sh2y_04:  ex4_sh2_y_b( 4) <= not( (ex4_sh1( 36) and ex4_shctl_16(2) ) or ( ex4_sh1( 52) and ex4_shctl_16(3) ) );
u_sh2y_05:  ex4_sh2_y_b( 5) <= not( (ex4_sh1( 37) and ex4_shctl_16(2) ) or ( ex4_sh1( 53) and ex4_shctl_16(3) ) );
u_sh2y_06:  ex4_sh2_y_b( 6) <= not( (ex4_sh1( 38) and ex4_shctl_16(2) ) or ( ex4_sh1( 54) and ex4_shctl_16(3) ) );
u_sh2y_07:  ex4_sh2_y_b( 7) <= not( (ex4_sh1( 39) and ex4_shctl_16(2) ) or ( ex4_sh1( 55) and ex4_shctl_16(3) ) );
u_sh2y_08:  ex4_sh2_y_b( 8) <= not( (ex4_sh1( 40) and ex4_shctl_16(2) ) or ( ex4_sh1( 56) and ex4_shctl_16(3) ) );
u_sh2y_09:  ex4_sh2_y_b( 9) <= not( (ex4_sh1( 41) and ex4_shctl_16(2) ) or ( ex4_sh1( 57) and ex4_shctl_16(3) ) );
u_sh2y_10:  ex4_sh2_y_b(10) <= not( (ex4_sh1( 42) and ex4_shctl_16(2) ) or ( ex4_sh1( 58) and ex4_shctl_16(3) ) );
u_sh2y_11:  ex4_sh2_y_b(11) <= not( (ex4_sh1( 43) and ex4_shctl_16(2) ) or ( ex4_sh1( 59) and ex4_shctl_16(3) ) );
u_sh2y_12:  ex4_sh2_y_b(12) <= not( (ex4_sh1( 44) and ex4_shctl_16(2) ) or ( ex4_sh1( 60) and ex4_shctl_16(3) ) );
u_sh2y_13:  ex4_sh2_y_b(13) <= not( (ex4_sh1( 45) and ex4_shctl_16(2) ) or ( ex4_sh1( 61) and ex4_shctl_16(3) ) );
u_sh2y_14:  ex4_sh2_y_b(14) <= not( (ex4_sh1( 46) and ex4_shctl_16(2) ) or ( ex4_sh1( 62) and ex4_shctl_16(3) ) );
u_sh2y_15:  ex4_sh2_y_b(15) <= not( (ex4_sh1( 47) and ex4_shctl_16(2) ) or ( ex4_sh1( 63) and ex4_shctl_16(3) ) );
u_sh2y_16:  ex4_sh2_y_b(16) <= not( (ex4_sh1( 48) and ex4_shctl_16(2) ) or ( ex4_sh1( 64) and ex4_shctl_16(3) ) );
u_sh2y_17:  ex4_sh2_y_b(17) <= not( (ex4_sh1( 49) and ex4_shctl_16(2) ) or ( ex4_sh1( 65) and ex4_shctl_16(3) ) );
u_sh2y_18:  ex4_sh2_y_b(18) <= not( (ex4_sh1( 50) and ex4_shctl_16(2) ) or ( ex4_sh1( 66) and ex4_shctl_16(3) ) );
u_sh2y_19:  ex4_sh2_y_b(19) <= not( (ex4_sh1( 51) and ex4_shctl_16(2) ) or ( ex4_sh1( 67) and ex4_shctl_16(3) ) );
u_sh2y_20:  ex4_sh2_y_b(20) <= not( (ex4_sh1( 52) and ex4_shctl_16(2) ) or ( ex4_sh1( 68) and ex4_shctl_16(3) ) );
u_sh2y_21:  ex4_sh2_y_b(21) <= not( (ex4_sh1( 53) and ex4_shctl_16(2) ) or ( ex4_sh1( 69) and ex4_shctl_16(3) ) );
u_sh2y_22:  ex4_sh2_y_b(22) <= not( (ex4_sh1( 54) and ex4_shctl_16(2) ) or ( ex4_sh1( 70) and ex4_shctl_16(3) ) );
u_sh2y_23:  ex4_sh2_y_b(23) <= not( (ex4_sh1( 55) and ex4_shctl_16(2) ) or ( ex4_sh1( 71) and ex4_shctl_16(3) ) );
u_sh2y_24:  ex4_sh2_y_b(24) <= not( (ex4_sh1( 56) and ex4_shctl_16(2) ) or ( ex4_sh1( 72) and ex4_shctl_16(3) ) );
u_sh2y_25:  ex4_sh2_y_b(25) <= not( (ex4_sh1( 57) and ex4_shctl_16(2) ) or ( ex4_sh1( 73) and ex4_shctl_16(3) ) );
u_sh2y_26:  ex4_sh2_y_b(26) <= not( (ex4_sh1( 58) and ex4_shctl_16(2) ) or ( ex4_sh1( 74) and ex4_shctl_16(3) ) );
u_sh2y_27:  ex4_sh2_y_b(27) <= not( (ex4_sh1( 59) and ex4_shctl_16(2) ) or ( ex4_sh1( 75) and ex4_shctl_16(3) ) );
u_sh2y_28:  ex4_sh2_y_b(28) <= not( (ex4_sh1( 60) and ex4_shctl_16(2) ) or ( ex4_sh1( 76) and ex4_shctl_16(3) ) );
u_sh2y_29:  ex4_sh2_y_b(29) <= not( (ex4_sh1( 61) and ex4_shctl_16(2) ) or ( ex4_sh1( 77) and ex4_shctl_16(3) ) );
u_sh2y_30:  ex4_sh2_y_b(30) <= not( (ex4_sh1( 62) and ex4_shctl_16(2) ) or ( ex4_sh1( 78) and ex4_shctl_16(3) ) );
u_sh2y_31:  ex4_sh2_y_b(31) <= not( (ex4_sh1( 63) and ex4_shctl_16(2) ) or ( ex4_sh1( 79) and ex4_shctl_16(3) ) );
u_sh2y_32:  ex4_sh2_y_b(32) <= not( (ex4_sh1( 64) and ex4_shctl_16(2) ) or ( ex4_sh1( 80) and ex4_shctl_16(3) ) );
u_sh2y_33:  ex4_sh2_y_b(33) <= not( (ex4_sh1( 65) and ex4_shctl_16(2) ) or ( ex4_sh1( 81) and ex4_shctl_16(3) ) );
u_sh2y_34:  ex4_sh2_y_b(34) <= not( (ex4_sh1( 66) and ex4_shctl_16(2) ) or ( ex4_sh1( 82) and ex4_shctl_16(3) ) );
u_sh2y_35:  ex4_sh2_y_b(35) <= not( (ex4_sh1( 67) and ex4_shctl_16(2) ) or ( ex4_sh1( 83) and ex4_shctl_16(3) ) );
u_sh2y_36:  ex4_sh2_y_b(36) <= not( (ex4_sh1( 68) and ex4_shctl_16(2) ) or ( ex4_sh1( 84) and ex4_shctl_16(3) ) );
u_sh2y_37:  ex4_sh2_y_b(37) <= not( (ex4_sh1( 69) and ex4_shctl_16(2) ) or ( ex4_sh1( 85) and ex4_shctl_16(3) ) );
u_sh2y_38:  ex4_sh2_y_b(38) <= not( (ex4_sh1( 70) and ex4_shctl_16(2) ) or ( ex4_sh1( 86) and ex4_shctl_16(3) ) );
u_sh2y_39:  ex4_sh2_y_b(39) <= not( (ex4_sh1( 71) and ex4_shctl_16(2) ) or ( ex4_sh1( 87) and ex4_shctl_16(3) ) );
u_sh2y_40:  ex4_sh2_y_b(40) <= not( (ex4_sh1( 72) and ex4_shctl_16(2) ) or ( ex4_sh1( 88) and ex4_shctl_16(3) ) );
u_sh2y_41:  ex4_sh2_y_b(41) <= not( (ex4_sh1( 73) and ex4_shctl_16(2) ) or ( ex4_sh1( 89) and ex4_shctl_16(3) ) );
u_sh2y_42:  ex4_sh2_y_b(42) <= not( (ex4_sh1( 74) and ex4_shctl_16(2) ) or ( ex4_sh1( 90) and ex4_shctl_16(3) ) );
u_sh2y_43:  ex4_sh2_y_b(43) <= not( (ex4_sh1( 75) and ex4_shctl_16(2) ) or ( ex4_sh1( 91) and ex4_shctl_16(3) ) );
u_sh2y_44:  ex4_sh2_y_b(44) <= not( (ex4_sh1( 76) and ex4_shctl_16(2) ) or ( ex4_sh1( 92) and ex4_shctl_16(3) ) );
u_sh2y_45:  ex4_sh2_y_b(45) <= not( (ex4_sh1( 77) and ex4_shctl_16(2) ) or ( ex4_sh1( 93) and ex4_shctl_16(3) ) );
u_sh2y_46:  ex4_sh2_y_b(46) <= not( (ex4_sh1( 78) and ex4_shctl_16(2) ) or ( ex4_sh1( 94) and ex4_shctl_16(3) ) );
u_sh2y_47:  ex4_sh2_y_b(47) <= not( (ex4_sh1( 79) and ex4_shctl_16(2) ) or ( ex4_sh1( 95) and ex4_shctl_16(3) ) );
u_sh2y_48:  ex4_sh2_y_b(48) <= not( (ex4_sh1( 80) and ex4_shctl_16(2) ) or ( ex4_sh1( 96) and ex4_shctl_16(3) ) );
u_sh2y_49:  ex4_sh2_y_b(49) <= not( (ex4_sh1( 81) and ex4_shctl_16(2) ) or ( ex4_sh1( 97) and ex4_shctl_16(3) ) );
u_sh2y_50:  ex4_sh2_y_b(50) <= not( (ex4_sh1( 82) and ex4_shctl_16(2) ) or ( ex4_sh1( 98) and ex4_shctl_16(3) ) );
u_sh2y_51:  ex4_sh2_y_b(51) <= not( (ex4_sh1( 83) and ex4_shctl_16(2) ) or ( ex4_sh1( 99) and ex4_shctl_16(3) ) );
u_sh2y_52:  ex4_sh2_y_b(52) <= not( (ex4_sh1( 84) and ex4_shctl_16(2) ) or ( ex4_sh1(100) and ex4_shctl_16(3) ) );
u_sh2y_53:  ex4_sh2_y_b(53) <= not( (ex4_sh1( 85) and ex4_shctl_16(2) ) or ( ex4_sh1(101) and ex4_shctl_16(3) ) );
u_sh2y_54:  ex4_sh2_y_b(54) <= not( (ex4_sh1( 86) and ex4_shctl_16(2) ) or ( ex4_sh1(102) and ex4_shctl_16(3) ) );
u_sh2y_55:  ex4_sh2_y_b(55) <= not( (ex4_sh1( 87) and ex4_shctl_16(2) ) or ( ex4_sh1(103) and ex4_shctl_16(3) ) );
u_sh2y_56:  ex4_sh2_y_b(56) <= not( (ex4_sh1( 88) and ex4_shctl_16(2) ) or ( ex4_sh1(104) and ex4_shctl_16(3) ) );
u_sh2y_57:  ex4_sh2_y_b(57) <= not( (ex4_sh1( 89) and ex4_shctl_16(2) ) or ( ex4_sh1(105) and ex4_shctl_16(3) ) );
u_sh2y_58:  ex4_sh2_y_b(58) <= not( (ex4_sh1( 90) and ex4_shctl_16(2) ) or ( ex4_sh1(106) and ex4_shctl_16(3) ) );
u_sh2y_59:  ex4_sh2_y_b(59) <= not( (ex4_sh1( 91) and ex4_shctl_16(2) ) or ( ex4_sh1(107) and ex4_shctl_16(3) ) );
u_sh2y_60:  ex4_sh2_y_b(60) <= not( (ex4_sh1( 92) and ex4_shctl_16(2) ) or ( ex4_sh1(108) and ex4_shctl_16(3) ) );
u_sh2y_61:  ex4_sh2_y_b(61) <= not( (ex4_sh1( 93) and ex4_shctl_16(2) ) or ( ex4_sh1(109) and ex4_shctl_16(3) ) );
u_sh2y_62:  ex4_sh2_y_b(62) <= not( (ex4_sh1( 94) and ex4_shctl_16(2) ) or ( ex4_sh1(110) and ex4_shctl_16(3) ) );
u_sh2y_63:  ex4_sh2_y_b(63) <= not( (ex4_sh1( 95) and ex4_shctl_16(2) ) or ( ex4_sh1(111) and ex4_shctl_16(3) ) );
u_sh2y_64:  ex4_sh2_y_b(64) <= not( (ex4_sh1( 96) and ex4_shctl_16(2) ) or ( ex4_sh1(112) and ex4_shctl_16(3) ) );
u_sh2y_65:  ex4_sh2_y_b(65) <= not( (ex4_sh1( 97) and ex4_shctl_16(2) ) or ( ex4_sh1(113) and ex4_shctl_16(3) ) );
u_sh2y_66:  ex4_sh2_y_b(66) <= not( (ex4_sh1( 98) and ex4_shctl_16(2) ) or ( ex4_sh1(114) and ex4_shctl_16(3) ) );
u_sh2y_67:  ex4_sh2_y_b(67) <= not( (ex4_sh1( 99) and ex4_shctl_16(2) ) or ( ex4_sh1(115) and ex4_shctl_16(3) ) );
u_sh2y_68:  ex4_sh2_y_b(68) <= not( (ex4_sh1(100) and ex4_shctl_16(2) ) or ( ex4_sh1(116) and ex4_shctl_16(3) ) );
u_sh2y_69:  ex4_sh2_y_b(69) <= not( (ex4_sh1(101) and ex4_shctl_16(2) ) or ( ex4_sh1(117) and ex4_shctl_16(3) ) );
u_sh2y_70:  ex4_sh2_y_b(70) <= not( (ex4_sh1(102) and ex4_shctl_16(2) ) or ( ex4_sh1(118) and ex4_shctl_16(3) ) );
u_sh2y_71:  ex4_sh2_y_b(71) <= not( (ex4_sh1(103) and ex4_shctl_16(2) ) or ( ex4_sh1(119) and ex4_shctl_16(3) ) );
u_sh2y_72:  ex4_sh2_y_b(72) <= not( (ex4_sh1(104) and ex4_shctl_16(2) ) or ( ex4_sh1(120) and ex4_shctl_16(3) ) );



u_sh2_00:  ex4_sh2( 0) <= not( ex4_sh2_x_b( 0) and ex4_sh2_y_b( 0) );
u_sh2_01:  ex4_sh2( 1) <= not( ex4_sh2_x_b( 1) and ex4_sh2_y_b( 1) );
u_sh2_02:  ex4_sh2( 2) <= not( ex4_sh2_x_b( 2) and ex4_sh2_y_b( 2) );
u_sh2_03:  ex4_sh2( 3) <= not( ex4_sh2_x_b( 3) and ex4_sh2_y_b( 3) );
u_sh2_04:  ex4_sh2( 4) <= not( ex4_sh2_x_b( 4) and ex4_sh2_y_b( 4) );
u_sh2_05:  ex4_sh2( 5) <= not( ex4_sh2_x_b( 5) and ex4_sh2_y_b( 5) );
u_sh2_06:  ex4_sh2( 6) <= not( ex4_sh2_x_b( 6) and ex4_sh2_y_b( 6) );
u_sh2_07:  ex4_sh2( 7) <= not( ex4_sh2_x_b( 7) and ex4_sh2_y_b( 7) );
u_sh2_08:  ex4_sh2( 8) <= not( ex4_sh2_x_b( 8) and ex4_sh2_y_b( 8) );
u_sh2_09:  ex4_sh2( 9) <= not( ex4_sh2_x_b( 9) and ex4_sh2_y_b( 9) );
u_sh2_10:  ex4_sh2(10) <= not( ex4_sh2_x_b(10) and ex4_sh2_y_b(10) );
u_sh2_11:  ex4_sh2(11) <= not( ex4_sh2_x_b(11) and ex4_sh2_y_b(11) );
u_sh2_12:  ex4_sh2(12) <= not( ex4_sh2_x_b(12) and ex4_sh2_y_b(12) );
u_sh2_13:  ex4_sh2(13) <= not( ex4_sh2_x_b(13) and ex4_sh2_y_b(13) );
u_sh2_14:  ex4_sh2(14) <= not( ex4_sh2_x_b(14) and ex4_sh2_y_b(14) );
u_sh2_15:  ex4_sh2(15) <= not( ex4_sh2_x_b(15) and ex4_sh2_y_b(15) );
u_sh2_16:  ex4_sh2(16) <= not( ex4_sh2_x_b(16) and ex4_sh2_y_b(16) );
u_sh2_17:  ex4_sh2(17) <= not( ex4_sh2_x_b(17) and ex4_sh2_y_b(17) );
u_sh2_18:  ex4_sh2(18) <= not( ex4_sh2_x_b(18) and ex4_sh2_y_b(18) );
u_sh2_19:  ex4_sh2(19) <= not( ex4_sh2_x_b(19) and ex4_sh2_y_b(19) );
u_sh2_20:  ex4_sh2(20) <= not( ex4_sh2_x_b(20) and ex4_sh2_y_b(20) );
u_sh2_21:  ex4_sh2(21) <= not( ex4_sh2_x_b(21) and ex4_sh2_y_b(21) );
u_sh2_22:  ex4_sh2(22) <= not( ex4_sh2_x_b(22) and ex4_sh2_y_b(22) );
u_sh2_23:  ex4_sh2(23) <= not( ex4_sh2_x_b(23) and ex4_sh2_y_b(23) );
u_sh2_24:  ex4_sh2(24) <= not( ex4_sh2_x_b(24) and ex4_sh2_y_b(24) );
u_sh2_25:  ex4_sh2(25) <= not( ex4_sh2_x_b(25) and ex4_sh2_y_b(25) );
u_sh2_26:  ex4_sh2(26) <= not( ex4_sh2_x_b(26) and ex4_sh2_y_b(26) );
u_sh2_27:  ex4_sh2(27) <= not( ex4_sh2_x_b(27) and ex4_sh2_y_b(27) );
u_sh2_28:  ex4_sh2(28) <= not( ex4_sh2_x_b(28) and ex4_sh2_y_b(28) );
u_sh2_29:  ex4_sh2(29) <= not( ex4_sh2_x_b(29) and ex4_sh2_y_b(29) );
u_sh2_30:  ex4_sh2(30) <= not( ex4_sh2_x_b(30) and ex4_sh2_y_b(30) );
u_sh2_31:  ex4_sh2(31) <= not( ex4_sh2_x_b(31) and ex4_sh2_y_b(31) );
u_sh2_32:  ex4_sh2(32) <= not( ex4_sh2_x_b(32) and ex4_sh2_y_b(32) );
u_sh2_33:  ex4_sh2(33) <= not( ex4_sh2_x_b(33) and ex4_sh2_y_b(33) );
u_sh2_34:  ex4_sh2(34) <= not( ex4_sh2_x_b(34) and ex4_sh2_y_b(34) );
u_sh2_35:  ex4_sh2(35) <= not( ex4_sh2_x_b(35) and ex4_sh2_y_b(35) );
u_sh2_36:  ex4_sh2(36) <= not( ex4_sh2_x_b(36) and ex4_sh2_y_b(36) );
u_sh2_37:  ex4_sh2(37) <= not( ex4_sh2_x_b(37) and ex4_sh2_y_b(37) );
u_sh2_38:  ex4_sh2(38) <= not( ex4_sh2_x_b(38) and ex4_sh2_y_b(38) );
u_sh2_39:  ex4_sh2(39) <= not( ex4_sh2_x_b(39) and ex4_sh2_y_b(39) );
u_sh2_40:  ex4_sh2(40) <= not( ex4_sh2_x_b(40) and ex4_sh2_y_b(40) );
u_sh2_41:  ex4_sh2(41) <= not( ex4_sh2_x_b(41) and ex4_sh2_y_b(41) );
u_sh2_42:  ex4_sh2(42) <= not( ex4_sh2_x_b(42) and ex4_sh2_y_b(42) );
u_sh2_43:  ex4_sh2(43) <= not( ex4_sh2_x_b(43) and ex4_sh2_y_b(43) );
u_sh2_44:  ex4_sh2(44) <= not( ex4_sh2_x_b(44) and ex4_sh2_y_b(44) );
u_sh2_45:  ex4_sh2(45) <= not( ex4_sh2_x_b(45) and ex4_sh2_y_b(45) );
u_sh2_46:  ex4_sh2(46) <= not( ex4_sh2_x_b(46) and ex4_sh2_y_b(46) );
u_sh2_47:  ex4_sh2(47) <= not( ex4_sh2_x_b(47) and ex4_sh2_y_b(47) );
u_sh2_48:  ex4_sh2(48) <= not( ex4_sh2_x_b(48) and ex4_sh2_y_b(48) );
u_sh2_49:  ex4_sh2(49) <= not( ex4_sh2_x_b(49) and ex4_sh2_y_b(49) );
u_sh2_50:  ex4_sh2(50) <= not( ex4_sh2_x_b(50) and ex4_sh2_y_b(50) );
u_sh2_51:  ex4_sh2(51) <= not( ex4_sh2_x_b(51) and ex4_sh2_y_b(51) );
u_sh2_52:  ex4_sh2(52) <= not( ex4_sh2_x_b(52) and ex4_sh2_y_b(52) );
u_sh2_53:  ex4_sh2(53) <= not( ex4_sh2_x_b(53) and ex4_sh2_y_b(53) );
u_sh2_54:  ex4_sh2(54) <= not( ex4_sh2_x_b(54) and ex4_sh2_y_b(54) );
u_sh2_55:  ex4_sh2(55) <= not( ex4_sh2_x_b(55) and ex4_sh2_y_b(55) );
u_sh2_56:  ex4_sh2(56) <= not( ex4_sh2_x_b(56) and ex4_sh2_y_b(56) );
u_sh2_57:  ex4_sh2(57) <= not( ex4_sh2_x_b(57) and ex4_sh2_y_b(57) );
u_sh2_58:  ex4_sh2(58) <= not( ex4_sh2_x_b(58) and ex4_sh2_y_b(58) );
u_sh2_59:  ex4_sh2(59) <= not( ex4_sh2_x_b(59) and ex4_sh2_y_b(59) );
u_sh2_60:  ex4_sh2(60) <= not( ex4_sh2_x_b(60) and ex4_sh2_y_b(60) );
u_sh2_61:  ex4_sh2(61) <= not( ex4_sh2_x_b(61) and ex4_sh2_y_b(61) );
u_sh2_62:  ex4_sh2(62) <= not( ex4_sh2_x_b(62) and ex4_sh2_y_b(62) );
u_sh2_63:  ex4_sh2(63) <= not( ex4_sh2_x_b(63) and ex4_sh2_y_b(63) );
u_sh2_64:  ex4_sh2(64) <= not( ex4_sh2_x_b(64) and ex4_sh2_y_b(64) );
u_sh2_65:  ex4_sh2(65) <= not( ex4_sh2_x_b(65) and ex4_sh2_y_b(65) );
u_sh2_66:  ex4_sh2(66) <= not( ex4_sh2_x_b(66) and ex4_sh2_y_b(66) );
u_sh2_67:  ex4_sh2(67) <= not( ex4_sh2_x_b(67) and ex4_sh2_y_b(67) );
u_sh2_68:  ex4_sh2(68) <= not( ex4_sh2_x_b(68) and ex4_sh2_y_b(68) );
u_sh2_69:  ex4_sh2(69) <= not( ex4_sh2_x_b(69) and ex4_sh2_y_b(69) );
u_sh2_70:  ex4_sh2(70) <= not( ex4_sh2_x_b(70) and ex4_sh2_y_b(70) );
u_sh2_71:  ex4_sh2(71) <= not( ex4_sh2_x_b(71) and ex4_sh2_y_b(71) );
u_sh2_72:  ex4_sh2(72) <= not( ex4_sh2_x_b(72) and ex4_sh2_y_b(72) );

   -----------------------------------------------


u_sh3x_00:  ex4_sh3_x_b( 0) <= not( (ex4_sh2( 0) and ex4_shctl_04(0) ) or ( ex4_sh2( 4) and ex4_shctl_04(1) ) );
u_sh3x_01:  ex4_sh3_x_b( 1) <= not( (ex4_sh2( 1) and ex4_shctl_04(0) ) or ( ex4_sh2( 5) and ex4_shctl_04(1) ) );
u_sh3x_02:  ex4_sh3_x_b( 2) <= not( (ex4_sh2( 2) and ex4_shctl_04(0) ) or ( ex4_sh2( 6) and ex4_shctl_04(1) ) );
u_sh3x_03:  ex4_sh3_x_b( 3) <= not( (ex4_sh2( 3) and ex4_shctl_04(0) ) or ( ex4_sh2( 7) and ex4_shctl_04(1) ) );
u_sh3x_04:  ex4_sh3_x_b( 4) <= not( (ex4_sh2( 4) and ex4_shctl_04(0) ) or ( ex4_sh2( 8) and ex4_shctl_04(1) ) );
u_sh3x_05:  ex4_sh3_x_b( 5) <= not( (ex4_sh2( 5) and ex4_shctl_04(0) ) or ( ex4_sh2( 9) and ex4_shctl_04(1) ) );
u_sh3x_06:  ex4_sh3_x_b( 6) <= not( (ex4_sh2( 6) and ex4_shctl_04(0) ) or ( ex4_sh2(10) and ex4_shctl_04(1) ) );
u_sh3x_07:  ex4_sh3_x_b( 7) <= not( (ex4_sh2( 7) and ex4_shctl_04(0) ) or ( ex4_sh2(11) and ex4_shctl_04(1) ) );
u_sh3x_08:  ex4_sh3_x_b( 8) <= not( (ex4_sh2( 8) and ex4_shctl_04(0) ) or ( ex4_sh2(12) and ex4_shctl_04(1) ) );
u_sh3x_09:  ex4_sh3_x_b( 9) <= not( (ex4_sh2( 9) and ex4_shctl_04(0) ) or ( ex4_sh2(13) and ex4_shctl_04(1) ) );
u_sh3x_10:  ex4_sh3_x_b(10) <= not( (ex4_sh2(10) and ex4_shctl_04(0) ) or ( ex4_sh2(14) and ex4_shctl_04(1) ) );
u_sh3x_11:  ex4_sh3_x_b(11) <= not( (ex4_sh2(11) and ex4_shctl_04(0) ) or ( ex4_sh2(15) and ex4_shctl_04(1) ) );
u_sh3x_12:  ex4_sh3_x_b(12) <= not( (ex4_sh2(12) and ex4_shctl_04(0) ) or ( ex4_sh2(16) and ex4_shctl_04(1) ) );
u_sh3x_13:  ex4_sh3_x_b(13) <= not( (ex4_sh2(13) and ex4_shctl_04(0) ) or ( ex4_sh2(17) and ex4_shctl_04(1) ) );
u_sh3x_14:  ex4_sh3_x_b(14) <= not( (ex4_sh2(14) and ex4_shctl_04(0) ) or ( ex4_sh2(18) and ex4_shctl_04(1) ) );
u_sh3x_15:  ex4_sh3_x_b(15) <= not( (ex4_sh2(15) and ex4_shctl_04(0) ) or ( ex4_sh2(19) and ex4_shctl_04(1) ) );
u_sh3x_16:  ex4_sh3_x_b(16) <= not( (ex4_sh2(16) and ex4_shctl_04(0) ) or ( ex4_sh2(20) and ex4_shctl_04(1) ) );
u_sh3x_17:  ex4_sh3_x_b(17) <= not( (ex4_sh2(17) and ex4_shctl_04(0) ) or ( ex4_sh2(21) and ex4_shctl_04(1) ) );
u_sh3x_18:  ex4_sh3_x_b(18) <= not( (ex4_sh2(18) and ex4_shctl_04(0) ) or ( ex4_sh2(22) and ex4_shctl_04(1) ) );
u_sh3x_19:  ex4_sh3_x_b(19) <= not( (ex4_sh2(19) and ex4_shctl_04(0) ) or ( ex4_sh2(23) and ex4_shctl_04(1) ) );
u_sh3x_20:  ex4_sh3_x_b(20) <= not( (ex4_sh2(20) and ex4_shctl_04(0) ) or ( ex4_sh2(24) and ex4_shctl_04(1) ) );
u_sh3x_21:  ex4_sh3_x_b(21) <= not( (ex4_sh2(21) and ex4_shctl_04(0) ) or ( ex4_sh2(25) and ex4_shctl_04(1) ) );
u_sh3x_22:  ex4_sh3_x_b(22) <= not( (ex4_sh2(22) and ex4_shctl_04(0) ) or ( ex4_sh2(26) and ex4_shctl_04(1) ) );
u_sh3x_23:  ex4_sh3_x_b(23) <= not( (ex4_sh2(23) and ex4_shctl_04(0) ) or ( ex4_sh2(27) and ex4_shctl_04(1) ) );
u_sh3x_24:  ex4_sh3_x_b(24) <= not( (ex4_sh2(24) and ex4_shctl_04(0) ) or ( ex4_sh2(28) and ex4_shctl_04(1) ) );
u_sh3x_25:  ex4_sh3_x_b(25) <= not( (ex4_sh2(25) and ex4_shctl_04(0) ) or ( ex4_sh2(29) and ex4_shctl_04(1) ) );
u_sh3x_26:  ex4_sh3_x_b(26) <= not( (ex4_sh2(26) and ex4_shctl_04(0) ) or ( ex4_sh2(30) and ex4_shctl_04(1) ) );
u_sh3x_27:  ex4_sh3_x_b(27) <= not( (ex4_sh2(27) and ex4_shctl_04(0) ) or ( ex4_sh2(31) and ex4_shctl_04(1) ) );
u_sh3x_28:  ex4_sh3_x_b(28) <= not( (ex4_sh2(28) and ex4_shctl_04(0) ) or ( ex4_sh2(32) and ex4_shctl_04(1) ) );
u_sh3x_29:  ex4_sh3_x_b(29) <= not( (ex4_sh2(29) and ex4_shctl_04(0) ) or ( ex4_sh2(33) and ex4_shctl_04(1) ) );
u_sh3x_30:  ex4_sh3_x_b(30) <= not( (ex4_sh2(30) and ex4_shctl_04(0) ) or ( ex4_sh2(34) and ex4_shctl_04(1) ) );
u_sh3x_31:  ex4_sh3_x_b(31) <= not( (ex4_sh2(31) and ex4_shctl_04(0) ) or ( ex4_sh2(35) and ex4_shctl_04(1) ) );
u_sh3x_32:  ex4_sh3_x_b(32) <= not( (ex4_sh2(32) and ex4_shctl_04(0) ) or ( ex4_sh2(36) and ex4_shctl_04(1) ) );
u_sh3x_33:  ex4_sh3_x_b(33) <= not( (ex4_sh2(33) and ex4_shctl_04(0) ) or ( ex4_sh2(37) and ex4_shctl_04(1) ) );
u_sh3x_34:  ex4_sh3_x_b(34) <= not( (ex4_sh2(34) and ex4_shctl_04(0) ) or ( ex4_sh2(38) and ex4_shctl_04(1) ) );
u_sh3x_35:  ex4_sh3_x_b(35) <= not( (ex4_sh2(35) and ex4_shctl_04(0) ) or ( ex4_sh2(39) and ex4_shctl_04(1) ) );
u_sh3x_36:  ex4_sh3_x_b(36) <= not( (ex4_sh2(36) and ex4_shctl_04(0) ) or ( ex4_sh2(40) and ex4_shctl_04(1) ) );
u_sh3x_37:  ex4_sh3_x_b(37) <= not( (ex4_sh2(37) and ex4_shctl_04(0) ) or ( ex4_sh2(41) and ex4_shctl_04(1) ) );
u_sh3x_38:  ex4_sh3_x_b(38) <= not( (ex4_sh2(38) and ex4_shctl_04(0) ) or ( ex4_sh2(42) and ex4_shctl_04(1) ) );
u_sh3x_39:  ex4_sh3_x_b(39) <= not( (ex4_sh2(39) and ex4_shctl_04(0) ) or ( ex4_sh2(43) and ex4_shctl_04(1) ) );
u_sh3x_40:  ex4_sh3_x_b(40) <= not( (ex4_sh2(40) and ex4_shctl_04(0) ) or ( ex4_sh2(44) and ex4_shctl_04(1) ) );
u_sh3x_41:  ex4_sh3_x_b(41) <= not( (ex4_sh2(41) and ex4_shctl_04(0) ) or ( ex4_sh2(45) and ex4_shctl_04(1) ) );
u_sh3x_42:  ex4_sh3_x_b(42) <= not( (ex4_sh2(42) and ex4_shctl_04(0) ) or ( ex4_sh2(46) and ex4_shctl_04(1) ) );
u_sh3x_43:  ex4_sh3_x_b(43) <= not( (ex4_sh2(43) and ex4_shctl_04(0) ) or ( ex4_sh2(47) and ex4_shctl_04(1) ) );
u_sh3x_44:  ex4_sh3_x_b(44) <= not( (ex4_sh2(44) and ex4_shctl_04(0) ) or ( ex4_sh2(48) and ex4_shctl_04(1) ) );
u_sh3x_45:  ex4_sh3_x_b(45) <= not( (ex4_sh2(45) and ex4_shctl_04(0) ) or ( ex4_sh2(49) and ex4_shctl_04(1) ) );
u_sh3x_46:  ex4_sh3_x_b(46) <= not( (ex4_sh2(46) and ex4_shctl_04(0) ) or ( ex4_sh2(50) and ex4_shctl_04(1) ) );
u_sh3x_47:  ex4_sh3_x_b(47) <= not( (ex4_sh2(47) and ex4_shctl_04(0) ) or ( ex4_sh2(51) and ex4_shctl_04(1) ) );
u_sh3x_48:  ex4_sh3_x_b(48) <= not( (ex4_sh2(48) and ex4_shctl_04(0) ) or ( ex4_sh2(52) and ex4_shctl_04(1) ) );
u_sh3x_49:  ex4_sh3_x_b(49) <= not( (ex4_sh2(49) and ex4_shctl_04(0) ) or ( ex4_sh2(53) and ex4_shctl_04(1) ) );
u_sh3x_50:  ex4_sh3_x_b(50) <= not( (ex4_sh2(50) and ex4_shctl_04(0) ) or ( ex4_sh2(54) and ex4_shctl_04(1) ) );
u_sh3x_51:  ex4_sh3_x_b(51) <= not( (ex4_sh2(51) and ex4_shctl_04(0) ) or ( ex4_sh2(55) and ex4_shctl_04(1) ) );
u_sh3x_52:  ex4_sh3_x_b(52) <= not( (ex4_sh2(52) and ex4_shctl_04(0) ) or ( ex4_sh2(56) and ex4_shctl_04(1) ) );
u_sh3x_53:  ex4_sh3_x_b(53) <= not( (ex4_sh2(53) and ex4_shctl_04(0) ) or ( ex4_sh2(57) and ex4_shctl_04(1) ) );
u_sh3x_54:  ex4_sh3_x_b(54) <= not( (ex4_sh2(54) and ex4_shctl_04(0) ) or ( ex4_sh2(58) and ex4_shctl_04(1) ) );
u_sh3x_55:  ex4_sh3_x_b(55) <= not( (ex4_sh2(55) and ex4_shctl_04(0) ) or ( ex4_sh2(59) and ex4_shctl_04(1) ) );
u_sh3x_56:  ex4_sh3_x_b(56) <= not( (ex4_sh2(56) and ex4_shctl_04(0) ) or ( ex4_sh2(60) and ex4_shctl_04(1) ) );
u_sh3x_57:  ex4_sh3_x_b(57) <= not( (ex4_sh2(57) and ex4_shctl_04(0) ) or ( ex4_sh2(61) and ex4_shctl_04(1) ) );
     
u_sh3y_00:  ex4_sh3_y_b( 0) <= not( (ex4_sh2( 8) and ex4_shctl_04(2) ) or ( ex4_sh2(12) and ex4_shctl_04(3) ) );
u_sh3y_01:  ex4_sh3_y_b( 1) <= not( (ex4_sh2( 9) and ex4_shctl_04(2) ) or ( ex4_sh2(13) and ex4_shctl_04(3) ) );
u_sh3y_02:  ex4_sh3_y_b( 2) <= not( (ex4_sh2(10) and ex4_shctl_04(2) ) or ( ex4_sh2(14) and ex4_shctl_04(3) ) );
u_sh3y_03:  ex4_sh3_y_b( 3) <= not( (ex4_sh2(11) and ex4_shctl_04(2) ) or ( ex4_sh2(15) and ex4_shctl_04(3) ) );
u_sh3y_04:  ex4_sh3_y_b( 4) <= not( (ex4_sh2(12) and ex4_shctl_04(2) ) or ( ex4_sh2(16) and ex4_shctl_04(3) ) );
u_sh3y_05:  ex4_sh3_y_b( 5) <= not( (ex4_sh2(13) and ex4_shctl_04(2) ) or ( ex4_sh2(17) and ex4_shctl_04(3) ) );
u_sh3y_06:  ex4_sh3_y_b( 6) <= not( (ex4_sh2(14) and ex4_shctl_04(2) ) or ( ex4_sh2(18) and ex4_shctl_04(3) ) );
u_sh3y_07:  ex4_sh3_y_b( 7) <= not( (ex4_sh2(15) and ex4_shctl_04(2) ) or ( ex4_sh2(19) and ex4_shctl_04(3) ) );
u_sh3y_08:  ex4_sh3_y_b( 8) <= not( (ex4_sh2(16) and ex4_shctl_04(2) ) or ( ex4_sh2(20) and ex4_shctl_04(3) ) );
u_sh3y_09:  ex4_sh3_y_b( 9) <= not( (ex4_sh2(17) and ex4_shctl_04(2) ) or ( ex4_sh2(21) and ex4_shctl_04(3) ) );
u_sh3y_10:  ex4_sh3_y_b(10) <= not( (ex4_sh2(18) and ex4_shctl_04(2) ) or ( ex4_sh2(22) and ex4_shctl_04(3) ) );
u_sh3y_11:  ex4_sh3_y_b(11) <= not( (ex4_sh2(19) and ex4_shctl_04(2) ) or ( ex4_sh2(23) and ex4_shctl_04(3) ) );
u_sh3y_12:  ex4_sh3_y_b(12) <= not( (ex4_sh2(20) and ex4_shctl_04(2) ) or ( ex4_sh2(24) and ex4_shctl_04(3) ) );
u_sh3y_13:  ex4_sh3_y_b(13) <= not( (ex4_sh2(21) and ex4_shctl_04(2) ) or ( ex4_sh2(25) and ex4_shctl_04(3) ) );
u_sh3y_14:  ex4_sh3_y_b(14) <= not( (ex4_sh2(22) and ex4_shctl_04(2) ) or ( ex4_sh2(26) and ex4_shctl_04(3) ) );
u_sh3y_15:  ex4_sh3_y_b(15) <= not( (ex4_sh2(23) and ex4_shctl_04(2) ) or ( ex4_sh2(27) and ex4_shctl_04(3) ) );
u_sh3y_16:  ex4_sh3_y_b(16) <= not( (ex4_sh2(24) and ex4_shctl_04(2) ) or ( ex4_sh2(28) and ex4_shctl_04(3) ) );
u_sh3y_17:  ex4_sh3_y_b(17) <= not( (ex4_sh2(25) and ex4_shctl_04(2) ) or ( ex4_sh2(29) and ex4_shctl_04(3) ) );
u_sh3y_18:  ex4_sh3_y_b(18) <= not( (ex4_sh2(26) and ex4_shctl_04(2) ) or ( ex4_sh2(30) and ex4_shctl_04(3) ) );
u_sh3y_19:  ex4_sh3_y_b(19) <= not( (ex4_sh2(27) and ex4_shctl_04(2) ) or ( ex4_sh2(31) and ex4_shctl_04(3) ) );
u_sh3y_20:  ex4_sh3_y_b(20) <= not( (ex4_sh2(28) and ex4_shctl_04(2) ) or ( ex4_sh2(32) and ex4_shctl_04(3) ) );
u_sh3y_21:  ex4_sh3_y_b(21) <= not( (ex4_sh2(29) and ex4_shctl_04(2) ) or ( ex4_sh2(33) and ex4_shctl_04(3) ) );
u_sh3y_22:  ex4_sh3_y_b(22) <= not( (ex4_sh2(30) and ex4_shctl_04(2) ) or ( ex4_sh2(34) and ex4_shctl_04(3) ) );
u_sh3y_23:  ex4_sh3_y_b(23) <= not( (ex4_sh2(31) and ex4_shctl_04(2) ) or ( ex4_sh2(35) and ex4_shctl_04(3) ) );
u_sh3y_24:  ex4_sh3_y_b(24) <= not( (ex4_sh2(32) and ex4_shctl_04(2) ) or ( ex4_sh2(36) and ex4_shctl_04(3) ) );
u_sh3y_25:  ex4_sh3_y_b(25) <= not( (ex4_sh2(33) and ex4_shctl_04(2) ) or ( ex4_sh2(37) and ex4_shctl_04(3) ) );
u_sh3y_26:  ex4_sh3_y_b(26) <= not( (ex4_sh2(34) and ex4_shctl_04(2) ) or ( ex4_sh2(38) and ex4_shctl_04(3) ) );
u_sh3y_27:  ex4_sh3_y_b(27) <= not( (ex4_sh2(35) and ex4_shctl_04(2) ) or ( ex4_sh2(39) and ex4_shctl_04(3) ) );
u_sh3y_28:  ex4_sh3_y_b(28) <= not( (ex4_sh2(36) and ex4_shctl_04(2) ) or ( ex4_sh2(40) and ex4_shctl_04(3) ) );
u_sh3y_29:  ex4_sh3_y_b(29) <= not( (ex4_sh2(37) and ex4_shctl_04(2) ) or ( ex4_sh2(41) and ex4_shctl_04(3) ) );
u_sh3y_30:  ex4_sh3_y_b(30) <= not( (ex4_sh2(38) and ex4_shctl_04(2) ) or ( ex4_sh2(42) and ex4_shctl_04(3) ) );
u_sh3y_31:  ex4_sh3_y_b(31) <= not( (ex4_sh2(39) and ex4_shctl_04(2) ) or ( ex4_sh2(43) and ex4_shctl_04(3) ) );
u_sh3y_32:  ex4_sh3_y_b(32) <= not( (ex4_sh2(40) and ex4_shctl_04(2) ) or ( ex4_sh2(44) and ex4_shctl_04(3) ) );
u_sh3y_33:  ex4_sh3_y_b(33) <= not( (ex4_sh2(41) and ex4_shctl_04(2) ) or ( ex4_sh2(45) and ex4_shctl_04(3) ) );
u_sh3y_34:  ex4_sh3_y_b(34) <= not( (ex4_sh2(42) and ex4_shctl_04(2) ) or ( ex4_sh2(46) and ex4_shctl_04(3) ) );
u_sh3y_35:  ex4_sh3_y_b(35) <= not( (ex4_sh2(43) and ex4_shctl_04(2) ) or ( ex4_sh2(47) and ex4_shctl_04(3) ) );
u_sh3y_36:  ex4_sh3_y_b(36) <= not( (ex4_sh2(44) and ex4_shctl_04(2) ) or ( ex4_sh2(48) and ex4_shctl_04(3) ) );
u_sh3y_37:  ex4_sh3_y_b(37) <= not( (ex4_sh2(45) and ex4_shctl_04(2) ) or ( ex4_sh2(49) and ex4_shctl_04(3) ) );
u_sh3y_38:  ex4_sh3_y_b(38) <= not( (ex4_sh2(46) and ex4_shctl_04(2) ) or ( ex4_sh2(50) and ex4_shctl_04(3) ) );
u_sh3y_39:  ex4_sh3_y_b(39) <= not( (ex4_sh2(47) and ex4_shctl_04(2) ) or ( ex4_sh2(51) and ex4_shctl_04(3) ) );
u_sh3y_40:  ex4_sh3_y_b(40) <= not( (ex4_sh2(48) and ex4_shctl_04(2) ) or ( ex4_sh2(52) and ex4_shctl_04(3) ) );
u_sh3y_41:  ex4_sh3_y_b(41) <= not( (ex4_sh2(49) and ex4_shctl_04(2) ) or ( ex4_sh2(53) and ex4_shctl_04(3) ) );
u_sh3y_42:  ex4_sh3_y_b(42) <= not( (ex4_sh2(50) and ex4_shctl_04(2) ) or ( ex4_sh2(54) and ex4_shctl_04(3) ) );
u_sh3y_43:  ex4_sh3_y_b(43) <= not( (ex4_sh2(51) and ex4_shctl_04(2) ) or ( ex4_sh2(55) and ex4_shctl_04(3) ) );
u_sh3y_44:  ex4_sh3_y_b(44) <= not( (ex4_sh2(52) and ex4_shctl_04(2) ) or ( ex4_sh2(56) and ex4_shctl_04(3) ) );
u_sh3y_45:  ex4_sh3_y_b(45) <= not( (ex4_sh2(53) and ex4_shctl_04(2) ) or ( ex4_sh2(57) and ex4_shctl_04(3) ) );
u_sh3y_46:  ex4_sh3_y_b(46) <= not( (ex4_sh2(54) and ex4_shctl_04(2) ) or ( ex4_sh2(58) and ex4_shctl_04(3) ) );
u_sh3y_47:  ex4_sh3_y_b(47) <= not( (ex4_sh2(55) and ex4_shctl_04(2) ) or ( ex4_sh2(59) and ex4_shctl_04(3) ) );
u_sh3y_48:  ex4_sh3_y_b(48) <= not( (ex4_sh2(56) and ex4_shctl_04(2) ) or ( ex4_sh2(60) and ex4_shctl_04(3) ) );
u_sh3y_49:  ex4_sh3_y_b(49) <= not( (ex4_sh2(57) and ex4_shctl_04(2) ) or ( ex4_sh2(61) and ex4_shctl_04(3) ) );
u_sh3y_50:  ex4_sh3_y_b(50) <= not( (ex4_sh2(58) and ex4_shctl_04(2) ) or ( ex4_sh2(62) and ex4_shctl_04(3) ) );
u_sh3y_51:  ex4_sh3_y_b(51) <= not( (ex4_sh2(59) and ex4_shctl_04(2) ) or ( ex4_sh2(63) and ex4_shctl_04(3) ) );
u_sh3y_52:  ex4_sh3_y_b(52) <= not( (ex4_sh2(60) and ex4_shctl_04(2) ) or ( ex4_sh2(64) and ex4_shctl_04(3) ) );
u_sh3y_53:  ex4_sh3_y_b(53) <= not( (ex4_sh2(61) and ex4_shctl_04(2) ) or ( ex4_sh2(65) and ex4_shctl_04(3) ) );
u_sh3y_54:  ex4_sh3_y_b(54) <= not( (ex4_sh2(62) and ex4_shctl_04(2) ) or ( ex4_sh2(66) and ex4_shctl_04(3) ) );
u_sh3y_55:  ex4_sh3_y_b(55) <= not( (ex4_sh2(63) and ex4_shctl_04(2) ) or ( ex4_sh2(67) and ex4_shctl_04(3) ) );
u_sh3y_56:  ex4_sh3_y_b(56) <= not( (ex4_sh2(64) and ex4_shctl_04(2) ) or ( ex4_sh2(68) and ex4_shctl_04(3) ) );
u_sh3y_57:  ex4_sh3_y_b(57) <= not( (ex4_sh2(65) and ex4_shctl_04(2) ) or ( ex4_sh2(69) and ex4_shctl_04(3) ) );

u_sh3_00:  ex4_sh3( 0) <= not( ex4_sh3_x_b( 0) and ex4_sh3_y_b( 0) );
u_sh3_01:  ex4_sh3( 1) <= not( ex4_sh3_x_b( 1) and ex4_sh3_y_b( 1) );
u_sh3_02:  ex4_sh3( 2) <= not( ex4_sh3_x_b( 2) and ex4_sh3_y_b( 2) );
u_sh3_03:  ex4_sh3( 3) <= not( ex4_sh3_x_b( 3) and ex4_sh3_y_b( 3) );
u_sh3_04:  ex4_sh3( 4) <= not( ex4_sh3_x_b( 4) and ex4_sh3_y_b( 4) );
u_sh3_05:  ex4_sh3( 5) <= not( ex4_sh3_x_b( 5) and ex4_sh3_y_b( 5) );
u_sh3_06:  ex4_sh3( 6) <= not( ex4_sh3_x_b( 6) and ex4_sh3_y_b( 6) );
u_sh3_07:  ex4_sh3( 7) <= not( ex4_sh3_x_b( 7) and ex4_sh3_y_b( 7) );
u_sh3_08:  ex4_sh3( 8) <= not( ex4_sh3_x_b( 8) and ex4_sh3_y_b( 8) );
u_sh3_09:  ex4_sh3( 9) <= not( ex4_sh3_x_b( 9) and ex4_sh3_y_b( 9) );
u_sh3_10:  ex4_sh3(10) <= not( ex4_sh3_x_b(10) and ex4_sh3_y_b(10) );
u_sh3_11:  ex4_sh3(11) <= not( ex4_sh3_x_b(11) and ex4_sh3_y_b(11) );
u_sh3_12:  ex4_sh3(12) <= not( ex4_sh3_x_b(12) and ex4_sh3_y_b(12) );
u_sh3_13:  ex4_sh3(13) <= not( ex4_sh3_x_b(13) and ex4_sh3_y_b(13) );
u_sh3_14:  ex4_sh3(14) <= not( ex4_sh3_x_b(14) and ex4_sh3_y_b(14) );
u_sh3_15:  ex4_sh3(15) <= not( ex4_sh3_x_b(15) and ex4_sh3_y_b(15) );
u_sh3_16:  ex4_sh3(16) <= not( ex4_sh3_x_b(16) and ex4_sh3_y_b(16) );
u_sh3_17:  ex4_sh3(17) <= not( ex4_sh3_x_b(17) and ex4_sh3_y_b(17) );
u_sh3_18:  ex4_sh3(18) <= not( ex4_sh3_x_b(18) and ex4_sh3_y_b(18) );
u_sh3_19:  ex4_sh3(19) <= not( ex4_sh3_x_b(19) and ex4_sh3_y_b(19) );
u_sh3_20:  ex4_sh3(20) <= not( ex4_sh3_x_b(20) and ex4_sh3_y_b(20) );
u_sh3_21:  ex4_sh3(21) <= not( ex4_sh3_x_b(21) and ex4_sh3_y_b(21) );
u_sh3_22:  ex4_sh3(22) <= not( ex4_sh3_x_b(22) and ex4_sh3_y_b(22) );
u_sh3_23:  ex4_sh3(23) <= not( ex4_sh3_x_b(23) and ex4_sh3_y_b(23) );
u_sh3_24:  ex4_sh3(24) <= not( ex4_sh3_x_b(24) and ex4_sh3_y_b(24) );
u_sh3_25:  ex4_sh3(25) <= not( ex4_sh3_x_b(25) and ex4_sh3_y_b(25) );
u_sh3_26:  ex4_sh3(26) <= not( ex4_sh3_x_b(26) and ex4_sh3_y_b(26) );
u_sh3_27:  ex4_sh3(27) <= not( ex4_sh3_x_b(27) and ex4_sh3_y_b(27) );
u_sh3_28:  ex4_sh3(28) <= not( ex4_sh3_x_b(28) and ex4_sh3_y_b(28) );
u_sh3_29:  ex4_sh3(29) <= not( ex4_sh3_x_b(29) and ex4_sh3_y_b(29) );
u_sh3_30:  ex4_sh3(30) <= not( ex4_sh3_x_b(30) and ex4_sh3_y_b(30) );
u_sh3_31:  ex4_sh3(31) <= not( ex4_sh3_x_b(31) and ex4_sh3_y_b(31) );
u_sh3_32:  ex4_sh3(32) <= not( ex4_sh3_x_b(32) and ex4_sh3_y_b(32) );
u_sh3_33:  ex4_sh3(33) <= not( ex4_sh3_x_b(33) and ex4_sh3_y_b(33) );
u_sh3_34:  ex4_sh3(34) <= not( ex4_sh3_x_b(34) and ex4_sh3_y_b(34) );
u_sh3_35:  ex4_sh3(35) <= not( ex4_sh3_x_b(35) and ex4_sh3_y_b(35) );
u_sh3_36:  ex4_sh3(36) <= not( ex4_sh3_x_b(36) and ex4_sh3_y_b(36) );
u_sh3_37:  ex4_sh3(37) <= not( ex4_sh3_x_b(37) and ex4_sh3_y_b(37) );
u_sh3_38:  ex4_sh3(38) <= not( ex4_sh3_x_b(38) and ex4_sh3_y_b(38) );
u_sh3_39:  ex4_sh3(39) <= not( ex4_sh3_x_b(39) and ex4_sh3_y_b(39) );
u_sh3_40:  ex4_sh3(40) <= not( ex4_sh3_x_b(40) and ex4_sh3_y_b(40) );
u_sh3_41:  ex4_sh3(41) <= not( ex4_sh3_x_b(41) and ex4_sh3_y_b(41) );
u_sh3_42:  ex4_sh3(42) <= not( ex4_sh3_x_b(42) and ex4_sh3_y_b(42) );
u_sh3_43:  ex4_sh3(43) <= not( ex4_sh3_x_b(43) and ex4_sh3_y_b(43) );
u_sh3_44:  ex4_sh3(44) <= not( ex4_sh3_x_b(44) and ex4_sh3_y_b(44) );
u_sh3_45:  ex4_sh3(45) <= not( ex4_sh3_x_b(45) and ex4_sh3_y_b(45) );
u_sh3_46:  ex4_sh3(46) <= not( ex4_sh3_x_b(46) and ex4_sh3_y_b(46) );
u_sh3_47:  ex4_sh3(47) <= not( ex4_sh3_x_b(47) and ex4_sh3_y_b(47) );
u_sh3_48:  ex4_sh3(48) <= not( ex4_sh3_x_b(48) and ex4_sh3_y_b(48) );
u_sh3_49:  ex4_sh3(49) <= not( ex4_sh3_x_b(49) and ex4_sh3_y_b(49) );
u_sh3_50:  ex4_sh3(50) <= not( ex4_sh3_x_b(50) and ex4_sh3_y_b(50) );
u_sh3_51:  ex4_sh3(51) <= not( ex4_sh3_x_b(51) and ex4_sh3_y_b(51) );
u_sh3_52:  ex4_sh3(52) <= not( ex4_sh3_x_b(52) and ex4_sh3_y_b(52) );
u_sh3_53:  ex4_sh3(53) <= not( ex4_sh3_x_b(53) and ex4_sh3_y_b(53) );
u_sh3_54:  ex4_sh3(54) <= not( ex4_sh3_x_b(54) and ex4_sh3_y_b(54) );
u_sh3_55:  ex4_sh3(55) <= not( ex4_sh3_x_b(55) and ex4_sh3_y_b(55) );
u_sh3_56:  ex4_sh3(56) <= not( ex4_sh3_x_b(56) and ex4_sh3_y_b(56) );
u_sh3_57:  ex4_sh3(57) <= not( ex4_sh3_x_b(57) and ex4_sh3_y_b(57) );

   -----------------------------------------------

u_sh4x_00cp1: ex4_sh4_x_00_b  <= not( (ex4_sh3( 0) and ex4_shctl_01(0) ) or ( ex4_sh3( 1) and ex4_shctl_01(1) ) );
u_sh4x_00:  ex4_sh4_x_b( 0) <= not( (ex4_sh3( 0) and ex4_shctl_01(0) ) or ( ex4_sh3( 1) and ex4_shctl_01(1) ) );
u_sh4x_01:  ex4_sh4_x_b( 1) <= not( (ex4_sh3( 1) and ex4_shctl_01(0) ) or ( ex4_sh3( 2) and ex4_shctl_01(1) ) );
u_sh4x_02:  ex4_sh4_x_b( 2) <= not( (ex4_sh3( 2) and ex4_shctl_01(0) ) or ( ex4_sh3( 3) and ex4_shctl_01(1) ) );
u_sh4x_03:  ex4_sh4_x_b( 3) <= not( (ex4_sh3( 3) and ex4_shctl_01(0) ) or ( ex4_sh3( 4) and ex4_shctl_01(1) ) );
u_sh4x_04:  ex4_sh4_x_b( 4) <= not( (ex4_sh3( 4) and ex4_shctl_01(0) ) or ( ex4_sh3( 5) and ex4_shctl_01(1) ) );
u_sh4x_05:  ex4_sh4_x_b( 5) <= not( (ex4_sh3( 5) and ex4_shctl_01(0) ) or ( ex4_sh3( 6) and ex4_shctl_01(1) ) );
u_sh4x_06:  ex4_sh4_x_b( 6) <= not( (ex4_sh3( 6) and ex4_shctl_01(0) ) or ( ex4_sh3( 7) and ex4_shctl_01(1) ) );
u_sh4x_07:  ex4_sh4_x_b( 7) <= not( (ex4_sh3( 7) and ex4_shctl_01(0) ) or ( ex4_sh3( 8) and ex4_shctl_01(1) ) );
u_sh4x_08:  ex4_sh4_x_b( 8) <= not( (ex4_sh3( 8) and ex4_shctl_01(0) ) or ( ex4_sh3( 9) and ex4_shctl_01(1) ) );
u_sh4x_09:  ex4_sh4_x_b( 9) <= not( (ex4_sh3( 9) and ex4_shctl_01(0) ) or ( ex4_sh3(10) and ex4_shctl_01(1) ) );
u_sh4x_10:  ex4_sh4_x_b(10) <= not( (ex4_sh3(10) and ex4_shctl_01(0) ) or ( ex4_sh3(11) and ex4_shctl_01(1) ) );
u_sh4x_11:  ex4_sh4_x_b(11) <= not( (ex4_sh3(11) and ex4_shctl_01(0) ) or ( ex4_sh3(12) and ex4_shctl_01(1) ) );
u_sh4x_12:  ex4_sh4_x_b(12) <= not( (ex4_sh3(12) and ex4_shctl_01(0) ) or ( ex4_sh3(13) and ex4_shctl_01(1) ) );
u_sh4x_13:  ex4_sh4_x_b(13) <= not( (ex4_sh3(13) and ex4_shctl_01(0) ) or ( ex4_sh3(14) and ex4_shctl_01(1) ) );
u_sh4x_14:  ex4_sh4_x_b(14) <= not( (ex4_sh3(14) and ex4_shctl_01(0) ) or ( ex4_sh3(15) and ex4_shctl_01(1) ) );
u_sh4x_15:  ex4_sh4_x_b(15) <= not( (ex4_sh3(15) and ex4_shctl_01(0) ) or ( ex4_sh3(16) and ex4_shctl_01(1) ) );
u_sh4x_16:  ex4_sh4_x_b(16) <= not( (ex4_sh3(16) and ex4_shctl_01(0) ) or ( ex4_sh3(17) and ex4_shctl_01(1) ) );
u_sh4x_17:  ex4_sh4_x_b(17) <= not( (ex4_sh3(17) and ex4_shctl_01(0) ) or ( ex4_sh3(18) and ex4_shctl_01(1) ) );
u_sh4x_18:  ex4_sh4_x_b(18) <= not( (ex4_sh3(18) and ex4_shctl_01(0) ) or ( ex4_sh3(19) and ex4_shctl_01(1) ) );
u_sh4x_19:  ex4_sh4_x_b(19) <= not( (ex4_sh3(19) and ex4_shctl_01(0) ) or ( ex4_sh3(20) and ex4_shctl_01(1) ) );
u_sh4x_20:  ex4_sh4_x_b(20) <= not( (ex4_sh3(20) and ex4_shctl_01(0) ) or ( ex4_sh3(21) and ex4_shctl_01(1) ) );
u_sh4x_21:  ex4_sh4_x_b(21) <= not( (ex4_sh3(21) and ex4_shctl_01(0) ) or ( ex4_sh3(22) and ex4_shctl_01(1) ) );
u_sh4x_22:  ex4_sh4_x_b(22) <= not( (ex4_sh3(22) and ex4_shctl_01(0) ) or ( ex4_sh3(23) and ex4_shctl_01(1) ) );
u_sh4x_23:  ex4_sh4_x_b(23) <= not( (ex4_sh3(23) and ex4_shctl_01(0) ) or ( ex4_sh3(24) and ex4_shctl_01(1) ) );
u_sh4x_24:  ex4_sh4_x_b(24) <= not( (ex4_sh3(24) and ex4_shctl_01(0) ) or ( ex4_sh3(25) and ex4_shctl_01(1) ) );
u_sh4x_25:  ex4_sh4_x_b(25) <= not( (ex4_sh3(25) and ex4_shctl_01(0) ) or ( ex4_sh3(26) and ex4_shctl_01(1) ) );
u_sh4x_26:  ex4_sh4_x_b(26) <= not( (ex4_sh3(26) and ex4_shctl_01(0) ) or ( ex4_sh3(27) and ex4_shctl_01(1) ) );
u_sh4x_27:  ex4_sh4_x_b(27) <= not( (ex4_sh3(27) and ex4_shctl_01(0) ) or ( ex4_sh3(28) and ex4_shctl_01(1) ) );
u_sh4x_28:  ex4_sh4_x_b(28) <= not( (ex4_sh3(28) and ex4_shctl_01(0) ) or ( ex4_sh3(29) and ex4_shctl_01(1) ) );
u_sh4x_29:  ex4_sh4_x_b(29) <= not( (ex4_sh3(29) and ex4_shctl_01(0) ) or ( ex4_sh3(30) and ex4_shctl_01(1) ) );
u_sh4x_30:  ex4_sh4_x_b(30) <= not( (ex4_sh3(30) and ex4_shctl_01(0) ) or ( ex4_sh3(31) and ex4_shctl_01(1) ) );
u_sh4x_31:  ex4_sh4_x_b(31) <= not( (ex4_sh3(31) and ex4_shctl_01(0) ) or ( ex4_sh3(32) and ex4_shctl_01(1) ) );
u_sh4x_32:  ex4_sh4_x_b(32) <= not( (ex4_sh3(32) and ex4_shctl_01(0) ) or ( ex4_sh3(33) and ex4_shctl_01(1) ) );
u_sh4x_33:  ex4_sh4_x_b(33) <= not( (ex4_sh3(33) and ex4_shctl_01(0) ) or ( ex4_sh3(34) and ex4_shctl_01(1) ) );
u_sh4x_34:  ex4_sh4_x_b(34) <= not( (ex4_sh3(34) and ex4_shctl_01(0) ) or ( ex4_sh3(35) and ex4_shctl_01(1) ) );
u_sh4x_35:  ex4_sh4_x_b(35) <= not( (ex4_sh3(35) and ex4_shctl_01(0) ) or ( ex4_sh3(36) and ex4_shctl_01(1) ) );
u_sh4x_36:  ex4_sh4_x_b(36) <= not( (ex4_sh3(36) and ex4_shctl_01(0) ) or ( ex4_sh3(37) and ex4_shctl_01(1) ) );
u_sh4x_37:  ex4_sh4_x_b(37) <= not( (ex4_sh3(37) and ex4_shctl_01(0) ) or ( ex4_sh3(38) and ex4_shctl_01(1) ) );
u_sh4x_38:  ex4_sh4_x_b(38) <= not( (ex4_sh3(38) and ex4_shctl_01(0) ) or ( ex4_sh3(39) and ex4_shctl_01(1) ) );
u_sh4x_39:  ex4_sh4_x_b(39) <= not( (ex4_sh3(39) and ex4_shctl_01(0) ) or ( ex4_sh3(40) and ex4_shctl_01(1) ) );
u_sh4x_40:  ex4_sh4_x_b(40) <= not( (ex4_sh3(40) and ex4_shctl_01(0) ) or ( ex4_sh3(41) and ex4_shctl_01(1) ) );
u_sh4x_41:  ex4_sh4_x_b(41) <= not( (ex4_sh3(41) and ex4_shctl_01(0) ) or ( ex4_sh3(42) and ex4_shctl_01(1) ) );
u_sh4x_42:  ex4_sh4_x_b(42) <= not( (ex4_sh3(42) and ex4_shctl_01(0) ) or ( ex4_sh3(43) and ex4_shctl_01(1) ) );
u_sh4x_43:  ex4_sh4_x_b(43) <= not( (ex4_sh3(43) and ex4_shctl_01(0) ) or ( ex4_sh3(44) and ex4_shctl_01(1) ) );
u_sh4x_44:  ex4_sh4_x_b(44) <= not( (ex4_sh3(44) and ex4_shctl_01(0) ) or ( ex4_sh3(45) and ex4_shctl_01(1) ) );
u_sh4x_45:  ex4_sh4_x_b(45) <= not( (ex4_sh3(45) and ex4_shctl_01(0) ) or ( ex4_sh3(46) and ex4_shctl_01(1) ) );
u_sh4x_46:  ex4_sh4_x_b(46) <= not( (ex4_sh3(46) and ex4_shctl_01(0) ) or ( ex4_sh3(47) and ex4_shctl_01(1) ) );
u_sh4x_47:  ex4_sh4_x_b(47) <= not( (ex4_sh3(47) and ex4_shctl_01(0) ) or ( ex4_sh3(48) and ex4_shctl_01(1) ) );
u_sh4x_48:  ex4_sh4_x_b(48) <= not( (ex4_sh3(48) and ex4_shctl_01(0) ) or ( ex4_sh3(49) and ex4_shctl_01(1) ) );
u_sh4x_49:  ex4_sh4_x_b(49) <= not( (ex4_sh3(49) and ex4_shctl_01(0) ) or ( ex4_sh3(50) and ex4_shctl_01(1) ) );
u_sh4x_50:  ex4_sh4_x_b(50) <= not( (ex4_sh3(50) and ex4_shctl_01(0) ) or ( ex4_sh3(51) and ex4_shctl_01(1) ) );
u_sh4x_51:  ex4_sh4_x_b(51) <= not( (ex4_sh3(51) and ex4_shctl_01(0) ) or ( ex4_sh3(52) and ex4_shctl_01(1) ) );
u_sh4x_52:  ex4_sh4_x_b(52) <= not( (ex4_sh3(52) and ex4_shctl_01(0) ) or ( ex4_sh3(53) and ex4_shctl_01(1) ) );
u_sh4x_53:  ex4_sh4_x_b(53) <= not( (ex4_sh3(53) and ex4_shctl_01(0) ) or ( ex4_sh3(54) and ex4_shctl_01(1) ) );
u_sh4x_54:  ex4_sh4_x_b(54) <= not( (ex4_sh3(54) and ex4_shctl_01(0) ) or ( ex4_sh3(55) and ex4_shctl_01(1) ) );

u_sh4y_00cp1:  ex4_sh4_y_00_b  <= not( (ex4_sh3( 2) and ex4_shctl_01(2) ) or ( ex4_sh3( 3) and ex4_shctl_01(3) ) );
u_sh4y_00:  ex4_sh4_y_b( 0) <= not( (ex4_sh3( 2) and ex4_shctl_01(2) ) or ( ex4_sh3( 3) and ex4_shctl_01(3) ) );
u_sh4y_01:  ex4_sh4_y_b( 1) <= not( (ex4_sh3( 3) and ex4_shctl_01(2) ) or ( ex4_sh3( 4) and ex4_shctl_01(3) ) );
u_sh4y_02:  ex4_sh4_y_b( 2) <= not( (ex4_sh3( 4) and ex4_shctl_01(2) ) or ( ex4_sh3( 5) and ex4_shctl_01(3) ) );
u_sh4y_03:  ex4_sh4_y_b( 3) <= not( (ex4_sh3( 5) and ex4_shctl_01(2) ) or ( ex4_sh3( 6) and ex4_shctl_01(3) ) );
u_sh4y_04:  ex4_sh4_y_b( 4) <= not( (ex4_sh3( 6) and ex4_shctl_01(2) ) or ( ex4_sh3( 7) and ex4_shctl_01(3) ) );
u_sh4y_05:  ex4_sh4_y_b( 5) <= not( (ex4_sh3( 7) and ex4_shctl_01(2) ) or ( ex4_sh3( 8) and ex4_shctl_01(3) ) );
u_sh4y_06:  ex4_sh4_y_b( 6) <= not( (ex4_sh3( 8) and ex4_shctl_01(2) ) or ( ex4_sh3( 9) and ex4_shctl_01(3) ) );
u_sh4y_07:  ex4_sh4_y_b( 7) <= not( (ex4_sh3( 9) and ex4_shctl_01(2) ) or ( ex4_sh3(10) and ex4_shctl_01(3) ) );
u_sh4y_08:  ex4_sh4_y_b( 8) <= not( (ex4_sh3(10) and ex4_shctl_01(2) ) or ( ex4_sh3(11) and ex4_shctl_01(3) ) );
u_sh4y_09:  ex4_sh4_y_b( 9) <= not( (ex4_sh3(11) and ex4_shctl_01(2) ) or ( ex4_sh3(12) and ex4_shctl_01(3) ) );
u_sh4y_10:  ex4_sh4_y_b(10) <= not( (ex4_sh3(12) and ex4_shctl_01(2) ) or ( ex4_sh3(13) and ex4_shctl_01(3) ) );
u_sh4y_11:  ex4_sh4_y_b(11) <= not( (ex4_sh3(13) and ex4_shctl_01(2) ) or ( ex4_sh3(14) and ex4_shctl_01(3) ) );
u_sh4y_12:  ex4_sh4_y_b(12) <= not( (ex4_sh3(14) and ex4_shctl_01(2) ) or ( ex4_sh3(15) and ex4_shctl_01(3) ) );
u_sh4y_13:  ex4_sh4_y_b(13) <= not( (ex4_sh3(15) and ex4_shctl_01(2) ) or ( ex4_sh3(16) and ex4_shctl_01(3) ) );
u_sh4y_14:  ex4_sh4_y_b(14) <= not( (ex4_sh3(16) and ex4_shctl_01(2) ) or ( ex4_sh3(17) and ex4_shctl_01(3) ) );
u_sh4y_15:  ex4_sh4_y_b(15) <= not( (ex4_sh3(17) and ex4_shctl_01(2) ) or ( ex4_sh3(18) and ex4_shctl_01(3) ) );
u_sh4y_16:  ex4_sh4_y_b(16) <= not( (ex4_sh3(18) and ex4_shctl_01(2) ) or ( ex4_sh3(19) and ex4_shctl_01(3) ) );
u_sh4y_17:  ex4_sh4_y_b(17) <= not( (ex4_sh3(19) and ex4_shctl_01(2) ) or ( ex4_sh3(20) and ex4_shctl_01(3) ) );
u_sh4y_18:  ex4_sh4_y_b(18) <= not( (ex4_sh3(20) and ex4_shctl_01(2) ) or ( ex4_sh3(21) and ex4_shctl_01(3) ) );
u_sh4y_19:  ex4_sh4_y_b(19) <= not( (ex4_sh3(21) and ex4_shctl_01(2) ) or ( ex4_sh3(22) and ex4_shctl_01(3) ) );
u_sh4y_20:  ex4_sh4_y_b(20) <= not( (ex4_sh3(22) and ex4_shctl_01(2) ) or ( ex4_sh3(23) and ex4_shctl_01(3) ) );
u_sh4y_21:  ex4_sh4_y_b(21) <= not( (ex4_sh3(23) and ex4_shctl_01(2) ) or ( ex4_sh3(24) and ex4_shctl_01(3) ) );
u_sh4y_22:  ex4_sh4_y_b(22) <= not( (ex4_sh3(24) and ex4_shctl_01(2) ) or ( ex4_sh3(25) and ex4_shctl_01(3) ) );
u_sh4y_23:  ex4_sh4_y_b(23) <= not( (ex4_sh3(25) and ex4_shctl_01(2) ) or ( ex4_sh3(26) and ex4_shctl_01(3) ) );
u_sh4y_24:  ex4_sh4_y_b(24) <= not( (ex4_sh3(26) and ex4_shctl_01(2) ) or ( ex4_sh3(27) and ex4_shctl_01(3) ) );
u_sh4y_25:  ex4_sh4_y_b(25) <= not( (ex4_sh3(27) and ex4_shctl_01(2) ) or ( ex4_sh3(28) and ex4_shctl_01(3) ) );
u_sh4y_26:  ex4_sh4_y_b(26) <= not( (ex4_sh3(28) and ex4_shctl_01(2) ) or ( ex4_sh3(29) and ex4_shctl_01(3) ) );
u_sh4y_27:  ex4_sh4_y_b(27) <= not( (ex4_sh3(29) and ex4_shctl_01(2) ) or ( ex4_sh3(30) and ex4_shctl_01(3) ) );
u_sh4y_28:  ex4_sh4_y_b(28) <= not( (ex4_sh3(30) and ex4_shctl_01(2) ) or ( ex4_sh3(31) and ex4_shctl_01(3) ) );
u_sh4y_29:  ex4_sh4_y_b(29) <= not( (ex4_sh3(31) and ex4_shctl_01(2) ) or ( ex4_sh3(32) and ex4_shctl_01(3) ) );
u_sh4y_30:  ex4_sh4_y_b(30) <= not( (ex4_sh3(32) and ex4_shctl_01(2) ) or ( ex4_sh3(33) and ex4_shctl_01(3) ) );
u_sh4y_31:  ex4_sh4_y_b(31) <= not( (ex4_sh3(33) and ex4_shctl_01(2) ) or ( ex4_sh3(34) and ex4_shctl_01(3) ) );
u_sh4y_32:  ex4_sh4_y_b(32) <= not( (ex4_sh3(34) and ex4_shctl_01(2) ) or ( ex4_sh3(35) and ex4_shctl_01(3) ) );
u_sh4y_33:  ex4_sh4_y_b(33) <= not( (ex4_sh3(35) and ex4_shctl_01(2) ) or ( ex4_sh3(36) and ex4_shctl_01(3) ) );
u_sh4y_34:  ex4_sh4_y_b(34) <= not( (ex4_sh3(36) and ex4_shctl_01(2) ) or ( ex4_sh3(37) and ex4_shctl_01(3) ) );
u_sh4y_35:  ex4_sh4_y_b(35) <= not( (ex4_sh3(37) and ex4_shctl_01(2) ) or ( ex4_sh3(38) and ex4_shctl_01(3) ) );
u_sh4y_36:  ex4_sh4_y_b(36) <= not( (ex4_sh3(38) and ex4_shctl_01(2) ) or ( ex4_sh3(39) and ex4_shctl_01(3) ) );
u_sh4y_37:  ex4_sh4_y_b(37) <= not( (ex4_sh3(39) and ex4_shctl_01(2) ) or ( ex4_sh3(40) and ex4_shctl_01(3) ) );
u_sh4y_38:  ex4_sh4_y_b(38) <= not( (ex4_sh3(40) and ex4_shctl_01(2) ) or ( ex4_sh3(41) and ex4_shctl_01(3) ) );
u_sh4y_39:  ex4_sh4_y_b(39) <= not( (ex4_sh3(41) and ex4_shctl_01(2) ) or ( ex4_sh3(42) and ex4_shctl_01(3) ) );
u_sh4y_40:  ex4_sh4_y_b(40) <= not( (ex4_sh3(42) and ex4_shctl_01(2) ) or ( ex4_sh3(43) and ex4_shctl_01(3) ) );
u_sh4y_41:  ex4_sh4_y_b(41) <= not( (ex4_sh3(43) and ex4_shctl_01(2) ) or ( ex4_sh3(44) and ex4_shctl_01(3) ) );
u_sh4y_42:  ex4_sh4_y_b(42) <= not( (ex4_sh3(44) and ex4_shctl_01(2) ) or ( ex4_sh3(45) and ex4_shctl_01(3) ) );
u_sh4y_43:  ex4_sh4_y_b(43) <= not( (ex4_sh3(45) and ex4_shctl_01(2) ) or ( ex4_sh3(46) and ex4_shctl_01(3) ) );
u_sh4y_44:  ex4_sh4_y_b(44) <= not( (ex4_sh3(46) and ex4_shctl_01(2) ) or ( ex4_sh3(47) and ex4_shctl_01(3) ) );
u_sh4y_45:  ex4_sh4_y_b(45) <= not( (ex4_sh3(47) and ex4_shctl_01(2) ) or ( ex4_sh3(48) and ex4_shctl_01(3) ) );
u_sh4y_46:  ex4_sh4_y_b(46) <= not( (ex4_sh3(48) and ex4_shctl_01(2) ) or ( ex4_sh3(49) and ex4_shctl_01(3) ) );
u_sh4y_47:  ex4_sh4_y_b(47) <= not( (ex4_sh3(49) and ex4_shctl_01(2) ) or ( ex4_sh3(50) and ex4_shctl_01(3) ) );
u_sh4y_48:  ex4_sh4_y_b(48) <= not( (ex4_sh3(50) and ex4_shctl_01(2) ) or ( ex4_sh3(51) and ex4_shctl_01(3) ) );
u_sh4y_49:  ex4_sh4_y_b(49) <= not( (ex4_sh3(51) and ex4_shctl_01(2) ) or ( ex4_sh3(52) and ex4_shctl_01(3) ) );
u_sh4y_50:  ex4_sh4_y_b(50) <= not( (ex4_sh3(52) and ex4_shctl_01(2) ) or ( ex4_sh3(53) and ex4_shctl_01(3) ) );
u_sh4y_51:  ex4_sh4_y_b(51) <= not( (ex4_sh3(53) and ex4_shctl_01(2) ) or ( ex4_sh3(54) and ex4_shctl_01(3) ) );
u_sh4y_52:  ex4_sh4_y_b(52) <= not( (ex4_sh3(54) and ex4_shctl_01(2) ) or ( ex4_sh3(55) and ex4_shctl_01(3) ) );
u_sh4y_53:  ex4_sh4_y_b(53) <= not( (ex4_sh3(55) and ex4_shctl_01(2) ) or ( ex4_sh3(56) and ex4_shctl_01(3) ) );
u_sh4y_54:  ex4_sh4_y_b(54) <= not( (ex4_sh3(56) and ex4_shctl_01(2) ) or ( ex4_sh3(57) and ex4_shctl_01(3) ) );

u_extra_cp1:  ex4_shift_extra_cp1_b    <= not(ex4_sh4_x_00_b and ex4_sh4_y_00_b ); -- shift extra when implicit bit is not 1
u_extra_cp2:  ex4_shift_extra_cp2_b    <= not(ex4_sh4_x_00_b and ex4_sh4_y_00_b ); -- shift extra when implicit bit is not 1
u_extra_cp3:  ex4_shift_extra_00_cp3_b <= not(ex4_sh4_x_b(0) and ex4_sh4_y_b(0) ); -- shift extra when implicit bit is not 1
u_extra_cp4:  ex4_shift_extra_00_cp4_b <= not(ex4_sh4_x_b(0) and ex4_sh4_y_b(0) ); -- shift extra when implicit bit is not 1

  ex4_shift_extra_cp1 <= not ex4_shift_extra_cp1_b ; --output--
  ex4_shift_extra_cp2 <= not ex4_shift_extra_cp2_b ; --output--


u_extra_10_cp3: ex4_shift_extra_10_cp3    <= not ex4_shift_extra_00_cp3_b    ; -- x4
u_extra_20_cp3: ex4_shift_extra_20_cp3_b  <= not ex4_shift_extra_10_cp3   ; -- x6
u_extra_30_cp3: ex4_shift_extra_cp3       <= not ex4_shift_extra_20_cp3_b ; -- x9

u_extra_11_cp3: ex4_shift_extra_11_cp3    <= not ex4_shift_extra_00_cp3_b    ; -- x2
u_extra_21_cp3: ex4_shift_extra_21_cp3_b  <= not ex4_shift_extra_11_cp3   ; -- x4
u_extra_31_cp3: ex4_shift_extra_31_cp3    <= not ex4_shift_extra_21_cp3_b ; -- x6
u_extra_41_cp3: ex4_shift_extra_cp3_b     <= not ex4_shift_extra_31_cp3   ; -- x9

u_extra_10_cp4: ex4_shift_extra_10_cp4    <= not ex4_shift_extra_00_cp4_b    ; -- x4
u_extra_20_cp4: ex4_shift_extra_20_cp4_b  <= not ex4_shift_extra_10_cp4   ; -- x6
u_extra_30_cp4: ex4_shift_extra_cp4       <= not ex4_shift_extra_20_cp4_b ; -- x9

u_extra_11_cp4: ex4_shift_extra_11_cp4    <= not ex4_shift_extra_00_cp4_b    ; -- x2
u_extra_21_cp4: ex4_shift_extra_21_cp4_b  <= not ex4_shift_extra_11_cp4   ; -- x4
u_extra_31_cp4: ex4_shift_extra_31_cp4    <= not ex4_shift_extra_21_cp4_b ; -- x6
u_extra_41_cp4: ex4_shift_extra_cp4_b     <= not ex4_shift_extra_31_cp4   ; -- x9






u_sh4_00:  ex4_sh4( 0) <= not( ex4_sh4_x_b( 0) and ex4_sh4_y_b( 0) );
u_sh4_01:  ex4_sh4( 1) <= not( ex4_sh4_x_b( 1) and ex4_sh4_y_b( 1) );
u_sh4_02:  ex4_sh4( 2) <= not( ex4_sh4_x_b( 2) and ex4_sh4_y_b( 2) );
u_sh4_03:  ex4_sh4( 3) <= not( ex4_sh4_x_b( 3) and ex4_sh4_y_b( 3) );
u_sh4_04:  ex4_sh4( 4) <= not( ex4_sh4_x_b( 4) and ex4_sh4_y_b( 4) );
u_sh4_05:  ex4_sh4( 5) <= not( ex4_sh4_x_b( 5) and ex4_sh4_y_b( 5) );
u_sh4_06:  ex4_sh4( 6) <= not( ex4_sh4_x_b( 6) and ex4_sh4_y_b( 6) );
u_sh4_07:  ex4_sh4( 7) <= not( ex4_sh4_x_b( 7) and ex4_sh4_y_b( 7) );
u_sh4_08:  ex4_sh4( 8) <= not( ex4_sh4_x_b( 8) and ex4_sh4_y_b( 8) );
u_sh4_09:  ex4_sh4( 9) <= not( ex4_sh4_x_b( 9) and ex4_sh4_y_b( 9) );
u_sh4_10:  ex4_sh4(10) <= not( ex4_sh4_x_b(10) and ex4_sh4_y_b(10) );
u_sh4_11:  ex4_sh4(11) <= not( ex4_sh4_x_b(11) and ex4_sh4_y_b(11) );
u_sh4_12:  ex4_sh4(12) <= not( ex4_sh4_x_b(12) and ex4_sh4_y_b(12) );
u_sh4_13:  ex4_sh4(13) <= not( ex4_sh4_x_b(13) and ex4_sh4_y_b(13) );
u_sh4_14:  ex4_sh4(14) <= not( ex4_sh4_x_b(14) and ex4_sh4_y_b(14) );
u_sh4_15:  ex4_sh4(15) <= not( ex4_sh4_x_b(15) and ex4_sh4_y_b(15) );
u_sh4_16:  ex4_sh4(16) <= not( ex4_sh4_x_b(16) and ex4_sh4_y_b(16) );
u_sh4_17:  ex4_sh4(17) <= not( ex4_sh4_x_b(17) and ex4_sh4_y_b(17) );
u_sh4_18:  ex4_sh4(18) <= not( ex4_sh4_x_b(18) and ex4_sh4_y_b(18) );
u_sh4_19:  ex4_sh4(19) <= not( ex4_sh4_x_b(19) and ex4_sh4_y_b(19) );
u_sh4_20:  ex4_sh4(20) <= not( ex4_sh4_x_b(20) and ex4_sh4_y_b(20) );
u_sh4_21:  ex4_sh4(21) <= not( ex4_sh4_x_b(21) and ex4_sh4_y_b(21) );
u_sh4_22:  ex4_sh4(22) <= not( ex4_sh4_x_b(22) and ex4_sh4_y_b(22) );
u_sh4_23:  ex4_sh4(23) <= not( ex4_sh4_x_b(23) and ex4_sh4_y_b(23) );
u_sh4_24:  ex4_sh4(24) <= not( ex4_sh4_x_b(24) and ex4_sh4_y_b(24) );
u_sh4_25:  ex4_sh4(25) <= not( ex4_sh4_x_b(25) and ex4_sh4_y_b(25) );
u_sh4_26:  ex4_sh4(26) <= not( ex4_sh4_x_b(26) and ex4_sh4_y_b(26) );
u_sh4_27:  ex4_sh4(27) <= not( ex4_sh4_x_b(27) and ex4_sh4_y_b(27) );
u_sh4_28:  ex4_sh4(28) <= not( ex4_sh4_x_b(28) and ex4_sh4_y_b(28) );
u_sh4_29:  ex4_sh4(29) <= not( ex4_sh4_x_b(29) and ex4_sh4_y_b(29) );
u_sh4_30:  ex4_sh4(30) <= not( ex4_sh4_x_b(30) and ex4_sh4_y_b(30) );
u_sh4_31:  ex4_sh4(31) <= not( ex4_sh4_x_b(31) and ex4_sh4_y_b(31) );
u_sh4_32:  ex4_sh4(32) <= not( ex4_sh4_x_b(32) and ex4_sh4_y_b(32) );
u_sh4_33:  ex4_sh4(33) <= not( ex4_sh4_x_b(33) and ex4_sh4_y_b(33) );
u_sh4_34:  ex4_sh4(34) <= not( ex4_sh4_x_b(34) and ex4_sh4_y_b(34) );
u_sh4_35:  ex4_sh4(35) <= not( ex4_sh4_x_b(35) and ex4_sh4_y_b(35) );
u_sh4_36:  ex4_sh4(36) <= not( ex4_sh4_x_b(36) and ex4_sh4_y_b(36) );
u_sh4_37:  ex4_sh4(37) <= not( ex4_sh4_x_b(37) and ex4_sh4_y_b(37) );
u_sh4_38:  ex4_sh4(38) <= not( ex4_sh4_x_b(38) and ex4_sh4_y_b(38) );
u_sh4_39:  ex4_sh4(39) <= not( ex4_sh4_x_b(39) and ex4_sh4_y_b(39) );
u_sh4_40:  ex4_sh4(40) <= not( ex4_sh4_x_b(40) and ex4_sh4_y_b(40) );
u_sh4_41:  ex4_sh4(41) <= not( ex4_sh4_x_b(41) and ex4_sh4_y_b(41) );
u_sh4_42:  ex4_sh4(42) <= not( ex4_sh4_x_b(42) and ex4_sh4_y_b(42) );
u_sh4_43:  ex4_sh4(43) <= not( ex4_sh4_x_b(43) and ex4_sh4_y_b(43) );
u_sh4_44:  ex4_sh4(44) <= not( ex4_sh4_x_b(44) and ex4_sh4_y_b(44) );
u_sh4_45:  ex4_sh4(45) <= not( ex4_sh4_x_b(45) and ex4_sh4_y_b(45) );
u_sh4_46:  ex4_sh4(46) <= not( ex4_sh4_x_b(46) and ex4_sh4_y_b(46) );
u_sh4_47:  ex4_sh4(47) <= not( ex4_sh4_x_b(47) and ex4_sh4_y_b(47) );
u_sh4_48:  ex4_sh4(48) <= not( ex4_sh4_x_b(48) and ex4_sh4_y_b(48) );
u_sh4_49:  ex4_sh4(49) <= not( ex4_sh4_x_b(49) and ex4_sh4_y_b(49) );
u_sh4_50:  ex4_sh4(50) <= not( ex4_sh4_x_b(50) and ex4_sh4_y_b(50) );
u_sh4_51:  ex4_sh4(51) <= not( ex4_sh4_x_b(51) and ex4_sh4_y_b(51) );
u_sh4_52:  ex4_sh4(52) <= not( ex4_sh4_x_b(52) and ex4_sh4_y_b(52) );
u_sh4_53:  ex4_sh4(53) <= not( ex4_sh4_x_b(53) and ex4_sh4_y_b(53) );
u_sh4_54:  ex4_sh4(54) <= not( ex4_sh4_x_b(54) and ex4_sh4_y_b(54) );
 
   -----------------------------------------------
          

u_nrm_sh5x_00:  ex4_sh5_x_b( 0) <= not( ex4_sh4( 0) and ex4_shift_extra_cp3_b );
u_nrm_sh5x_01:  ex4_sh5_x_b( 1) <= not( ex4_sh4( 1) and ex4_shift_extra_cp3_b );
u_nrm_sh5x_02:  ex4_sh5_x_b( 2) <= not( ex4_sh4( 2) and ex4_shift_extra_cp3_b );
u_nrm_sh5x_03:  ex4_sh5_x_b( 3) <= not( ex4_sh4( 3) and ex4_shift_extra_cp3_b );
u_nrm_sh5x_04:  ex4_sh5_x_b( 4) <= not( ex4_sh4( 4) and ex4_shift_extra_cp3_b );
u_nrm_sh5x_05:  ex4_sh5_x_b( 5) <= not( ex4_sh4( 5) and ex4_shift_extra_cp3_b );
u_nrm_sh5x_06:  ex4_sh5_x_b( 6) <= not( ex4_sh4( 6) and ex4_shift_extra_cp3_b );
u_nrm_sh5x_07:  ex4_sh5_x_b( 7) <= not( ex4_sh4( 7) and ex4_shift_extra_cp3_b );
u_nrm_sh5x_08:  ex4_sh5_x_b( 8) <= not( ex4_sh4( 8) and ex4_shift_extra_cp3_b );
u_nrm_sh5x_09:  ex4_sh5_x_b( 9) <= not( ex4_sh4( 9) and ex4_shift_extra_cp3_b );
u_nrm_sh5x_10:  ex4_sh5_x_b(10) <= not( ex4_sh4(10) and ex4_shift_extra_cp3_b );
u_nrm_sh5x_11:  ex4_sh5_x_b(11) <= not( ex4_sh4(11) and ex4_shift_extra_cp3_b );
u_nrm_sh5x_12:  ex4_sh5_x_b(12) <= not( ex4_sh4(12) and ex4_shift_extra_cp3_b );
u_nrm_sh5x_13:  ex4_sh5_x_b(13) <= not( ex4_sh4(13) and ex4_shift_extra_cp3_b );
u_nrm_sh5x_14:  ex4_sh5_x_b(14) <= not( ex4_sh4(14) and ex4_shift_extra_cp3_b );
u_nrm_sh5x_15:  ex4_sh5_x_b(15) <= not( ex4_sh4(15) and ex4_shift_extra_cp3_b );
u_nrm_sh5x_16:  ex4_sh5_x_b(16) <= not( ex4_sh4(16) and ex4_shift_extra_cp3_b );
u_nrm_sh5x_17:  ex4_sh5_x_b(17) <= not( ex4_sh4(17) and ex4_shift_extra_cp3_b );
u_nrm_sh5x_18:  ex4_sh5_x_b(18) <= not( ex4_sh4(18) and ex4_shift_extra_cp3_b );
u_nrm_sh5x_19:  ex4_sh5_x_b(19) <= not( ex4_sh4(19) and ex4_shift_extra_cp3_b );
u_nrm_sh5x_20:  ex4_sh5_x_b(20) <= not( ex4_sh4(20) and ex4_shift_extra_cp3_b );
u_nrm_sh5x_21:  ex4_sh5_x_b(21) <= not( ex4_sh4(21) and ex4_shift_extra_cp3_b );
u_nrm_sh5x_22:  ex4_sh5_x_b(22) <= not( ex4_sh4(22) and ex4_shift_extra_cp3_b );
u_nrm_sh5x_23:  ex4_sh5_x_b(23) <= not( ex4_sh4(23) and ex4_shift_extra_cp3_b );
u_nrm_sh5x_24:  ex4_sh5_x_b(24) <= not( ex4_sh4(24) and ex4_shift_extra_cp3_b );
u_nrm_sh5x_25:  ex4_sh5_x_b(25) <= not( ex4_sh4(25) and ex4_shift_extra_cp3_b );
u_nrm_sh5x_26:  ex4_sh5_x_b(26) <= not( ex4_sh4(26) and ex4_shift_extra_cp4_b );
u_nrm_sh5x_27:  ex4_sh5_x_b(27) <= not( ex4_sh4(27) and ex4_shift_extra_cp4_b );
u_nrm_sh5x_28:  ex4_sh5_x_b(28) <= not( ex4_sh4(28) and ex4_shift_extra_cp4_b );
u_nrm_sh5x_29:  ex4_sh5_x_b(29) <= not( ex4_sh4(29) and ex4_shift_extra_cp4_b );
u_nrm_sh5x_30:  ex4_sh5_x_b(30) <= not( ex4_sh4(30) and ex4_shift_extra_cp4_b );
u_nrm_sh5x_31:  ex4_sh5_x_b(31) <= not( ex4_sh4(31) and ex4_shift_extra_cp4_b );
u_nrm_sh5x_32:  ex4_sh5_x_b(32) <= not( ex4_sh4(32) and ex4_shift_extra_cp4_b );
u_nrm_sh5x_33:  ex4_sh5_x_b(33) <= not( ex4_sh4(33) and ex4_shift_extra_cp4_b );
u_nrm_sh5x_34:  ex4_sh5_x_b(34) <= not( ex4_sh4(34) and ex4_shift_extra_cp4_b );
u_nrm_sh5x_35:  ex4_sh5_x_b(35) <= not( ex4_sh4(35) and ex4_shift_extra_cp4_b );
u_nrm_sh5x_36:  ex4_sh5_x_b(36) <= not( ex4_sh4(36) and ex4_shift_extra_cp4_b );
u_nrm_sh5x_37:  ex4_sh5_x_b(37) <= not( ex4_sh4(37) and ex4_shift_extra_cp4_b );
u_nrm_sh5x_38:  ex4_sh5_x_b(38) <= not( ex4_sh4(38) and ex4_shift_extra_cp4_b );
u_nrm_sh5x_39:  ex4_sh5_x_b(39) <= not( ex4_sh4(39) and ex4_shift_extra_cp4_b );
u_nrm_sh5x_40:  ex4_sh5_x_b(40) <= not( ex4_sh4(40) and ex4_shift_extra_cp4_b );
u_nrm_sh5x_41:  ex4_sh5_x_b(41) <= not( ex4_sh4(41) and ex4_shift_extra_cp4_b );
u_nrm_sh5x_42:  ex4_sh5_x_b(42) <= not( ex4_sh4(42) and ex4_shift_extra_cp4_b );
u_nrm_sh5x_43:  ex4_sh5_x_b(43) <= not( ex4_sh4(43) and ex4_shift_extra_cp4_b );
u_nrm_sh5x_44:  ex4_sh5_x_b(44) <= not( ex4_sh4(44) and ex4_shift_extra_cp4_b );
u_nrm_sh5x_45:  ex4_sh5_x_b(45) <= not( ex4_sh4(45) and ex4_shift_extra_cp4_b );
u_nrm_sh5x_46:  ex4_sh5_x_b(46) <= not( ex4_sh4(46) and ex4_shift_extra_cp4_b );
u_nrm_sh5x_47:  ex4_sh5_x_b(47) <= not( ex4_sh4(47) and ex4_shift_extra_cp4_b );
u_nrm_sh5x_48:  ex4_sh5_x_b(48) <= not( ex4_sh4(48) and ex4_shift_extra_cp4_b );
u_nrm_sh5x_49:  ex4_sh5_x_b(49) <= not( ex4_sh4(49) and ex4_shift_extra_cp4_b );
u_nrm_sh5x_50:  ex4_sh5_x_b(50) <= not( ex4_sh4(50) and ex4_shift_extra_cp4_b );
u_nrm_sh5x_51:  ex4_sh5_x_b(51) <= not( ex4_sh4(51) and ex4_shift_extra_cp4_b );
u_nrm_sh5x_52:  ex4_sh5_x_b(52) <= not( ex4_sh4(52) and ex4_shift_extra_cp4_b );
u_nrm_sh5x_53:  ex4_sh5_x_b(53) <= not( ex4_sh4(53) and ex4_shift_extra_cp4_b );

 
u_nrm_sh5y_00:  ex4_sh5_y_b( 0) <= not( ex4_sh4( 1) and     ex4_shift_extra_cp3 );
u_nrm_sh5y_01:  ex4_sh5_y_b( 1) <= not( ex4_sh4( 2) and     ex4_shift_extra_cp3 );
u_nrm_sh5y_02:  ex4_sh5_y_b( 2) <= not( ex4_sh4( 3) and     ex4_shift_extra_cp3 );
u_nrm_sh5y_03:  ex4_sh5_y_b( 3) <= not( ex4_sh4( 4) and     ex4_shift_extra_cp3 );
u_nrm_sh5y_04:  ex4_sh5_y_b( 4) <= not( ex4_sh4( 5) and     ex4_shift_extra_cp3 );
u_nrm_sh5y_05:  ex4_sh5_y_b( 5) <= not( ex4_sh4( 6) and     ex4_shift_extra_cp3 );
u_nrm_sh5y_06:  ex4_sh5_y_b( 6) <= not( ex4_sh4( 7) and     ex4_shift_extra_cp3 );
u_nrm_sh5y_07:  ex4_sh5_y_b( 7) <= not( ex4_sh4( 8) and     ex4_shift_extra_cp3 );
u_nrm_sh5y_08:  ex4_sh5_y_b( 8) <= not( ex4_sh4( 9) and     ex4_shift_extra_cp3 );
u_nrm_sh5y_09:  ex4_sh5_y_b( 9) <= not( ex4_sh4(10) and     ex4_shift_extra_cp3 );
u_nrm_sh5y_10:  ex4_sh5_y_b(10) <= not( ex4_sh4(11) and     ex4_shift_extra_cp3 );
u_nrm_sh5y_11:  ex4_sh5_y_b(11) <= not( ex4_sh4(12) and     ex4_shift_extra_cp3 );
u_nrm_sh5y_12:  ex4_sh5_y_b(12) <= not( ex4_sh4(13) and     ex4_shift_extra_cp3 );
u_nrm_sh5y_13:  ex4_sh5_y_b(13) <= not( ex4_sh4(14) and     ex4_shift_extra_cp3 );
u_nrm_sh5y_14:  ex4_sh5_y_b(14) <= not( ex4_sh4(15) and     ex4_shift_extra_cp3 );
u_nrm_sh5y_15:  ex4_sh5_y_b(15) <= not( ex4_sh4(16) and     ex4_shift_extra_cp3 );
u_nrm_sh5y_16:  ex4_sh5_y_b(16) <= not( ex4_sh4(17) and     ex4_shift_extra_cp3 );
u_nrm_sh5y_17:  ex4_sh5_y_b(17) <= not( ex4_sh4(18) and     ex4_shift_extra_cp3 );
u_nrm_sh5y_18:  ex4_sh5_y_b(18) <= not( ex4_sh4(19) and     ex4_shift_extra_cp3 );
u_nrm_sh5y_19:  ex4_sh5_y_b(19) <= not( ex4_sh4(20) and     ex4_shift_extra_cp3 );
u_nrm_sh5y_20:  ex4_sh5_y_b(20) <= not( ex4_sh4(21) and     ex4_shift_extra_cp3 );
u_nrm_sh5y_21:  ex4_sh5_y_b(21) <= not( ex4_sh4(22) and     ex4_shift_extra_cp3 );
u_nrm_sh5y_22:  ex4_sh5_y_b(22) <= not( ex4_sh4(23) and     ex4_shift_extra_cp3 );
u_nrm_sh5y_23:  ex4_sh5_y_b(23) <= not( ex4_sh4(24) and     ex4_shift_extra_cp3 );
u_nrm_sh5y_24:  ex4_sh5_y_b(24) <= not( ex4_sh4(25) and     ex4_shift_extra_cp3 );
u_nrm_sh5y_25:  ex4_sh5_y_b(25) <= not( ex4_sh4(26) and     ex4_shift_extra_cp3 );
u_nrm_sh5y_26:  ex4_sh5_y_b(26) <= not( ex4_sh4(27) and     ex4_shift_extra_cp4 );
u_nrm_sh5y_27:  ex4_sh5_y_b(27) <= not( ex4_sh4(28) and     ex4_shift_extra_cp4 );
u_nrm_sh5y_28:  ex4_sh5_y_b(28) <= not( ex4_sh4(29) and     ex4_shift_extra_cp4 );
u_nrm_sh5y_29:  ex4_sh5_y_b(29) <= not( ex4_sh4(30) and     ex4_shift_extra_cp4 );
u_nrm_sh5y_30:  ex4_sh5_y_b(30) <= not( ex4_sh4(31) and     ex4_shift_extra_cp4 );
u_nrm_sh5y_31:  ex4_sh5_y_b(31) <= not( ex4_sh4(32) and     ex4_shift_extra_cp4 );
u_nrm_sh5y_32:  ex4_sh5_y_b(32) <= not( ex4_sh4(33) and     ex4_shift_extra_cp4 );
u_nrm_sh5y_33:  ex4_sh5_y_b(33) <= not( ex4_sh4(34) and     ex4_shift_extra_cp4 );
u_nrm_sh5y_34:  ex4_sh5_y_b(34) <= not( ex4_sh4(35) and     ex4_shift_extra_cp4 );
u_nrm_sh5y_35:  ex4_sh5_y_b(35) <= not( ex4_sh4(36) and     ex4_shift_extra_cp4 );
u_nrm_sh5y_36:  ex4_sh5_y_b(36) <= not( ex4_sh4(37) and     ex4_shift_extra_cp4 );
u_nrm_sh5y_37:  ex4_sh5_y_b(37) <= not( ex4_sh4(38) and     ex4_shift_extra_cp4 );
u_nrm_sh5y_38:  ex4_sh5_y_b(38) <= not( ex4_sh4(39) and     ex4_shift_extra_cp4 );
u_nrm_sh5y_39:  ex4_sh5_y_b(39) <= not( ex4_sh4(40) and     ex4_shift_extra_cp4 );
u_nrm_sh5y_40:  ex4_sh5_y_b(40) <= not( ex4_sh4(41) and     ex4_shift_extra_cp4 );
u_nrm_sh5y_41:  ex4_sh5_y_b(41) <= not( ex4_sh4(42) and     ex4_shift_extra_cp4 );
u_nrm_sh5y_42:  ex4_sh5_y_b(42) <= not( ex4_sh4(43) and     ex4_shift_extra_cp4 );
u_nrm_sh5y_43:  ex4_sh5_y_b(43) <= not( ex4_sh4(44) and     ex4_shift_extra_cp4 );
u_nrm_sh5y_44:  ex4_sh5_y_b(44) <= not( ex4_sh4(45) and     ex4_shift_extra_cp4 );
u_nrm_sh5y_45:  ex4_sh5_y_b(45) <= not( ex4_sh4(46) and     ex4_shift_extra_cp4 );
u_nrm_sh5y_46:  ex4_sh5_y_b(46) <= not( ex4_sh4(47) and     ex4_shift_extra_cp4 );
u_nrm_sh5y_47:  ex4_sh5_y_b(47) <= not( ex4_sh4(48) and     ex4_shift_extra_cp4 );
u_nrm_sh5y_48:  ex4_sh5_y_b(48) <= not( ex4_sh4(49) and     ex4_shift_extra_cp4 );
u_nrm_sh5y_49:  ex4_sh5_y_b(49) <= not( ex4_sh4(50) and     ex4_shift_extra_cp4 );
u_nrm_sh5y_50:  ex4_sh5_y_b(50) <= not( ex4_sh4(51) and     ex4_shift_extra_cp4 );
u_nrm_sh5y_51:  ex4_sh5_y_b(51) <= not( ex4_sh4(52) and     ex4_shift_extra_cp4 );
u_nrm_sh5y_52:  ex4_sh5_y_b(52) <= not( ex4_sh4(53) and     ex4_shift_extra_cp4 );
u_nrm_sh5y_53:  ex4_sh5_y_b(53) <= not( ex4_sh4(54) and     ex4_shift_extra_cp4 );



end; -- fuq_nrm_sh ARCHITECTURE
