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


entity fuq_lza_clz is port(
     lv0_or       :in  std_ulogic_vector(0 to 162);
     lv6_or_0     :out std_ulogic;
     lv6_or_1     :out std_ulogic; 
     lza_any_b    :out std_ulogic ;
     lza_amt_b    :out std_ulogic_vector(0 to 7)
 );
END                                 fuq_lza_clz;


ARCHITECTURE fuq_lza_clz  OF fuq_lza_clz  IS

  constant tiup : std_ulogic := '1';
  constant tidn : std_ulogic := '0';

  signal lv1_or_b   :std_ulogic_vector(0 to 81);
  signal lv1_inv_b  :std_ulogic_vector(0 to 81);
  signal lv1_enc7_b :std_ulogic_vector(0 to 81);

  signal lv2_or     :std_ulogic_vector(0 to 40);
  signal lv2_inv    :std_ulogic_vector(0 to 40);
  signal lv2_enc6   :std_ulogic_vector(0 to 40);
  signal lv2_enc7   :std_ulogic_vector(0 to 40);
  
  signal lv3_or_b   :std_ulogic_vector(0 to 20);
  signal lv3_inv_b  :std_ulogic_vector(0 to 20);
  signal lv3_enc5_b :std_ulogic_vector(0 to 20);
  signal lv3_enc6_b :std_ulogic_vector(0 to 20);
  signal lv3_enc7_b :std_ulogic_vector(0 to 20);
  
  signal lv4_or     :std_ulogic_vector(0 to 10);
  signal lv4_inv    :std_ulogic_vector(0 to 10);
  signal lv4_enc4   :std_ulogic_vector(0 to 10);
  signal lv4_enc5   :std_ulogic_vector(0 to 10);
  signal lv4_enc6   :std_ulogic_vector(0 to 10);
  signal lv4_enc7   :std_ulogic_vector(0 to 10);

  signal lv4_or_b   :std_ulogic_vector(0 to 10);
  signal lv4_enc4_b :std_ulogic_vector(0 to 10);
  signal lv4_enc5_b :std_ulogic_vector(0 to 10);
  signal lv4_enc6_b :std_ulogic_vector(0 to 10);
  signal lv4_enc7_b :std_ulogic_vector(0 to 10);


  signal lv5_or     :std_ulogic_vector(0 to 5);
  signal lv5_inv    :std_ulogic_vector(0 to 5);
  signal lv5_enc3   :std_ulogic_vector(0 to 5);
  signal lv5_enc4   :std_ulogic_vector(0 to 5);
  signal lv5_enc5   :std_ulogic_vector(0 to 5);
  signal lv5_enc6   :std_ulogic_vector(0 to 5);
  signal lv5_enc7   :std_ulogic_vector(0 to 5);

  signal lv6_or_b   :std_ulogic_vector(0 to 2);
  signal lv6_inv_b  :std_ulogic_vector(0 to 2);
  signal lv6_enc2_b :std_ulogic_vector(0 to 2);
  signal lv6_enc3_b :std_ulogic_vector(0 to 2);
  signal lv6_enc4_b :std_ulogic_vector(0 to 2);
  signal lv6_enc5_b :std_ulogic_vector(0 to 2);
  signal lv6_enc6_b :std_ulogic_vector(0 to 2);
  signal lv6_enc7_b :std_ulogic_vector(0 to 2);

  signal lv7_or     :std_ulogic_vector(0 to 1);
  signal lv7_inv    :std_ulogic_vector(0 to 1);
  signal lv7_enc1   :std_ulogic_vector(0 to 1);
  signal lv7_enc2   :std_ulogic_vector(0 to 1);
  signal lv7_enc3   :std_ulogic_vector(0 to 1);
  signal lv7_enc4   :std_ulogic_vector(0 to 1);
  signal lv7_enc5   :std_ulogic_vector(0 to 1);
  signal lv7_enc6   :std_ulogic_vector(0 to 1);
  signal lv7_enc7   :std_ulogic_vector(0 to 1);

  signal lv8_or_b   :std_ulogic_vector(0 to 0);
  signal lv8_inv_b  :std_ulogic_vector(0 to 0);
  signal lv8_enc0_b :std_ulogic_vector(0 to 0);
  signal lv8_enc1_b :std_ulogic_vector(0 to 0);
  signal lv8_enc2_b :std_ulogic_vector(0 to 0);
  signal lv8_enc3_b :std_ulogic_vector(0 to 0);
  signal lv8_enc4_b :std_ulogic_vector(0 to 0);
  signal lv8_enc5_b :std_ulogic_vector(0 to 0);
  signal lv8_enc6_b :std_ulogic_vector(0 to 0);
  signal lv8_enc7_b :std_ulogic_vector(0 to 0);
































 
 
 

BEGIN


 b000_002_any:  lv1_or_b(0) <= not( lv0_or(0) or  lv0_or(1) );
 b001_002_any:  lv1_or_b(1) <= not( lv0_or(2) or  lv0_or(3) );
 b002_002_any:  lv1_or_b(2) <= not( lv0_or(4) or  lv0_or(5) );
 b003_002_any:  lv1_or_b(3) <= not( lv0_or(6) or  lv0_or(7) );
 b004_002_any:  lv1_or_b(4) <= not( lv0_or(8) or  lv0_or(9) );
 b005_002_any:  lv1_or_b(5) <= not( lv0_or(10) or  lv0_or(11) );
 b006_002_any:  lv1_or_b(6) <= not( lv0_or(12) or  lv0_or(13) );
 b007_002_any:  lv1_or_b(7) <= not( lv0_or(14) or  lv0_or(15) );
 b008_002_any:  lv1_or_b(8) <= not( lv0_or(16) or  lv0_or(17) );
 b009_002_any:  lv1_or_b(9) <= not( lv0_or(18) or  lv0_or(19) );
 b010_002_any:  lv1_or_b(10) <= not( lv0_or(20) or  lv0_or(21) );
 b011_002_any:  lv1_or_b(11) <= not( lv0_or(22) or  lv0_or(23) );
 b012_002_any:  lv1_or_b(12) <= not( lv0_or(24) or  lv0_or(25) );
 b013_002_any:  lv1_or_b(13) <= not( lv0_or(26) or  lv0_or(27) );
 b014_002_any:  lv1_or_b(14) <= not( lv0_or(28) or  lv0_or(29) );
 b015_002_any:  lv1_or_b(15) <= not( lv0_or(30) or  lv0_or(31) );
 b016_002_any:  lv1_or_b(16) <= not( lv0_or(32) or  lv0_or(33) );
 b017_002_any:  lv1_or_b(17) <= not( lv0_or(34) or  lv0_or(35) );
 b018_002_any:  lv1_or_b(18) <= not( lv0_or(36) or  lv0_or(37) );
 b019_002_any:  lv1_or_b(19) <= not( lv0_or(38) or  lv0_or(39) );
 b020_002_any:  lv1_or_b(20) <= not( lv0_or(40) or  lv0_or(41) );
 b021_002_any:  lv1_or_b(21) <= not( lv0_or(42) or  lv0_or(43) );
 b022_002_any:  lv1_or_b(22) <= not( lv0_or(44) or  lv0_or(45) );
 b023_002_any:  lv1_or_b(23) <= not( lv0_or(46) or  lv0_or(47) );
 b024_002_any:  lv1_or_b(24) <= not( lv0_or(48) or  lv0_or(49) );
 b025_002_any:  lv1_or_b(25) <= not( lv0_or(50) or  lv0_or(51) );
 b026_002_any:  lv1_or_b(26) <= not( lv0_or(52) or  lv0_or(53) );
 b027_002_any:  lv1_or_b(27) <= not( lv0_or(54) or  lv0_or(55) );
 b028_002_any:  lv1_or_b(28) <= not( lv0_or(56) or  lv0_or(57) );
 b029_002_any:  lv1_or_b(29) <= not( lv0_or(58) or  lv0_or(59) );
 b030_002_any:  lv1_or_b(30) <= not( lv0_or(60) or  lv0_or(61) );
 b031_002_any:  lv1_or_b(31) <= not( lv0_or(62) or  lv0_or(63) );
 b032_002_any:  lv1_or_b(32) <= not( lv0_or(64) or  lv0_or(65) );
 b033_002_any:  lv1_or_b(33) <= not( lv0_or(66) or  lv0_or(67) );
 b034_002_any:  lv1_or_b(34) <= not( lv0_or(68) or  lv0_or(69) );
 b035_002_any:  lv1_or_b(35) <= not( lv0_or(70) or  lv0_or(71) );
 b036_002_any:  lv1_or_b(36) <= not( lv0_or(72) or  lv0_or(73) );
 b037_002_any:  lv1_or_b(37) <= not( lv0_or(74) or  lv0_or(75) );
 b038_002_any:  lv1_or_b(38) <= not( lv0_or(76) or  lv0_or(77) );
 b039_002_any:  lv1_or_b(39) <= not( lv0_or(78) or  lv0_or(79) );
 b040_002_any:  lv1_or_b(40) <= not( lv0_or(80) or  lv0_or(81) );
 b041_002_any:  lv1_or_b(41) <= not( lv0_or(82) or  lv0_or(83) );
 b042_002_any:  lv1_or_b(42) <= not( lv0_or(84) or  lv0_or(85) );
 b043_002_any:  lv1_or_b(43) <= not( lv0_or(86) or  lv0_or(87) );
 b044_002_any:  lv1_or_b(44) <= not( lv0_or(88) or  lv0_or(89) );
 b045_002_any:  lv1_or_b(45) <= not( lv0_or(90) or  lv0_or(91) );
 b046_002_any:  lv1_or_b(46) <= not( lv0_or(92) or  lv0_or(93) );
 b047_002_any:  lv1_or_b(47) <= not( lv0_or(94) or  lv0_or(95) );
 b048_002_any:  lv1_or_b(48) <= not( lv0_or(96) or  lv0_or(97) );
 b049_002_any:  lv1_or_b(49) <= not( lv0_or(98) or  lv0_or(99) );
 b050_002_any:  lv1_or_b(50) <= not( lv0_or(100) or  lv0_or(101) );
 b051_002_any:  lv1_or_b(51) <= not( lv0_or(102) or  lv0_or(103) );
 b052_002_any:  lv1_or_b(52) <= not( lv0_or(104) or  lv0_or(105) );
 b053_002_any:  lv1_or_b(53) <= not( lv0_or(106) or  lv0_or(107) );
 b054_002_any:  lv1_or_b(54) <= not( lv0_or(108) or  lv0_or(109) );
 b055_002_any:  lv1_or_b(55) <= not( lv0_or(110) or  lv0_or(111) );
 b056_002_any:  lv1_or_b(56) <= not( lv0_or(112) or  lv0_or(113) );
 b057_002_any:  lv1_or_b(57) <= not( lv0_or(114) or  lv0_or(115) );
 b058_002_any:  lv1_or_b(58) <= not( lv0_or(116) or  lv0_or(117) );
 b059_002_any:  lv1_or_b(59) <= not( lv0_or(118) or  lv0_or(119) );
 b060_002_any:  lv1_or_b(60) <= not( lv0_or(120) or  lv0_or(121) );
 b061_002_any:  lv1_or_b(61) <= not( lv0_or(122) or  lv0_or(123) );
 b062_002_any:  lv1_or_b(62) <= not( lv0_or(124) or  lv0_or(125) );
 b063_002_any:  lv1_or_b(63) <= not( lv0_or(126) or  lv0_or(127) );
 b064_002_any:  lv1_or_b(64) <= not( lv0_or(128) or  lv0_or(129) );
 b065_002_any:  lv1_or_b(65) <= not( lv0_or(130) or  lv0_or(131) );
 b066_002_any:  lv1_or_b(66) <= not( lv0_or(132) or  lv0_or(133) );
 b067_002_any:  lv1_or_b(67) <= not( lv0_or(134) or  lv0_or(135) );
 b068_002_any:  lv1_or_b(68) <= not( lv0_or(136) or  lv0_or(137) );
 b069_002_any:  lv1_or_b(69) <= not( lv0_or(138) or  lv0_or(139) );
 b070_002_any:  lv1_or_b(70) <= not( lv0_or(140) or  lv0_or(141) );
 b071_002_any:  lv1_or_b(71) <= not( lv0_or(142) or  lv0_or(143) );
 b072_002_any:  lv1_or_b(72) <= not( lv0_or(144) or  lv0_or(145) );
 b073_002_any:  lv1_or_b(73) <= not( lv0_or(146) or  lv0_or(147) );
 b074_002_any:  lv1_or_b(74) <= not( lv0_or(148) or  lv0_or(149) );
 b075_002_any:  lv1_or_b(75) <= not( lv0_or(150) or  lv0_or(151) );
 b076_002_any:  lv1_or_b(76) <= not( lv0_or(152) or  lv0_or(153) );
 b077_002_any:  lv1_or_b(77) <= not( lv0_or(154) or  lv0_or(155) );
 b078_002_any:  lv1_or_b(78) <= not( lv0_or(156) or  lv0_or(157) );
 b079_002_any:  lv1_or_b(79) <= not( lv0_or(158) or  lv0_or(159) );
 b080_002_any:  lv1_or_b(80) <= not( lv0_or(160) or  lv0_or(161) );
 b081_002_any:  lv1_or_b(81) <= not( lv0_or(162) );

 b000_002_inv:  lv1_inv_b(0) <= not( lv0_or(0) );
 b001_002_inv:  lv1_inv_b(1) <= not( lv0_or(2) );
 b002_002_inv:  lv1_inv_b(2) <= not( lv0_or(4) );
 b003_002_inv:  lv1_inv_b(3) <= not( lv0_or(6) );
 b004_002_inv:  lv1_inv_b(4) <= not( lv0_or(8) );
 b005_002_inv:  lv1_inv_b(5) <= not( lv0_or(10) );
 b006_002_inv:  lv1_inv_b(6) <= not( lv0_or(12) );
 b007_002_inv:  lv1_inv_b(7) <= not( lv0_or(14) );
 b008_002_inv:  lv1_inv_b(8) <= not( lv0_or(16) );
 b009_002_inv:  lv1_inv_b(9) <= not( lv0_or(18) );
 b010_002_inv:  lv1_inv_b(10) <= not( lv0_or(20) );
 b011_002_inv:  lv1_inv_b(11) <= not( lv0_or(22) );
 b012_002_inv:  lv1_inv_b(12) <= not( lv0_or(24) );
 b013_002_inv:  lv1_inv_b(13) <= not( lv0_or(26) );
 b014_002_inv:  lv1_inv_b(14) <= not( lv0_or(28) );
 b015_002_inv:  lv1_inv_b(15) <= not( lv0_or(30) );
 b016_002_inv:  lv1_inv_b(16) <= not( lv0_or(32) );
 b017_002_inv:  lv1_inv_b(17) <= not( lv0_or(34) );
 b018_002_inv:  lv1_inv_b(18) <= not( lv0_or(36) );
 b019_002_inv:  lv1_inv_b(19) <= not( lv0_or(38) );
 b020_002_inv:  lv1_inv_b(20) <= not( lv0_or(40) );
 b021_002_inv:  lv1_inv_b(21) <= not( lv0_or(42) );
 b022_002_inv:  lv1_inv_b(22) <= not( lv0_or(44) );
 b023_002_inv:  lv1_inv_b(23) <= not( lv0_or(46) );
 b024_002_inv:  lv1_inv_b(24) <= not( lv0_or(48) );
 b025_002_inv:  lv1_inv_b(25) <= not( lv0_or(50) );
 b026_002_inv:  lv1_inv_b(26) <= not( lv0_or(52) );
 b027_002_inv:  lv1_inv_b(27) <= not( lv0_or(54) );
 b028_002_inv:  lv1_inv_b(28) <= not( lv0_or(56) );
 b029_002_inv:  lv1_inv_b(29) <= not( lv0_or(58) );
 b030_002_inv:  lv1_inv_b(30) <= not( lv0_or(60) );
 b031_002_inv:  lv1_inv_b(31) <= not( lv0_or(62) );
 b032_002_inv:  lv1_inv_b(32) <= not( lv0_or(64) );
 b033_002_inv:  lv1_inv_b(33) <= not( lv0_or(66) );
 b034_002_inv:  lv1_inv_b(34) <= not( lv0_or(68) );
 b035_002_inv:  lv1_inv_b(35) <= not( lv0_or(70) );
 b036_002_inv:  lv1_inv_b(36) <= not( lv0_or(72) );
 b037_002_inv:  lv1_inv_b(37) <= not( lv0_or(74) );
 b038_002_inv:  lv1_inv_b(38) <= not( lv0_or(76) );
 b039_002_inv:  lv1_inv_b(39) <= not( lv0_or(78) );
 b040_002_inv:  lv1_inv_b(40) <= not( lv0_or(80) );
 b041_002_inv:  lv1_inv_b(41) <= not( lv0_or(82) );
 b042_002_inv:  lv1_inv_b(42) <= not( lv0_or(84) );
 b043_002_inv:  lv1_inv_b(43) <= not( lv0_or(86) );
 b044_002_inv:  lv1_inv_b(44) <= not( lv0_or(88) );
 b045_002_inv:  lv1_inv_b(45) <= not( lv0_or(90) );
 b046_002_inv:  lv1_inv_b(46) <= not( lv0_or(92) );
 b047_002_inv:  lv1_inv_b(47) <= not( lv0_or(94) );
 b048_002_inv:  lv1_inv_b(48) <= not( lv0_or(96) );
 b049_002_inv:  lv1_inv_b(49) <= not( lv0_or(98) );
 b050_002_inv:  lv1_inv_b(50) <= not( lv0_or(100) );
 b051_002_inv:  lv1_inv_b(51) <= not( lv0_or(102) );
 b052_002_inv:  lv1_inv_b(52) <= not( lv0_or(104) );
 b053_002_inv:  lv1_inv_b(53) <= not( lv0_or(106) );
 b054_002_inv:  lv1_inv_b(54) <= not( lv0_or(108) );
 b055_002_inv:  lv1_inv_b(55) <= not( lv0_or(110) );
 b056_002_inv:  lv1_inv_b(56) <= not( lv0_or(112) );
 b057_002_inv:  lv1_inv_b(57) <= not( lv0_or(114) );
 b058_002_inv:  lv1_inv_b(58) <= not( lv0_or(116) );
 b059_002_inv:  lv1_inv_b(59) <= not( lv0_or(118) );
 b060_002_inv:  lv1_inv_b(60) <= not( lv0_or(120) );
 b061_002_inv:  lv1_inv_b(61) <= not( lv0_or(122) );
 b062_002_inv:  lv1_inv_b(62) <= not( lv0_or(124) );
 b063_002_inv:  lv1_inv_b(63) <= not( lv0_or(126) );
 b064_002_inv:  lv1_inv_b(64) <= not( lv0_or(128) );
 b065_002_inv:  lv1_inv_b(65) <= not( lv0_or(130) );
 b066_002_inv:  lv1_inv_b(66) <= not( lv0_or(132) );
 b067_002_inv:  lv1_inv_b(67) <= not( lv0_or(134) );
 b068_002_inv:  lv1_inv_b(68) <= not( lv0_or(136) );
 b069_002_inv:  lv1_inv_b(69) <= not( lv0_or(138) );
 b070_002_inv:  lv1_inv_b(70) <= not( lv0_or(140) );
 b071_002_inv:  lv1_inv_b(71) <= not( lv0_or(142) );
 b072_002_inv:  lv1_inv_b(72) <= not( lv0_or(144) );
 b073_002_inv:  lv1_inv_b(73) <= not( lv0_or(146) );
 b074_002_inv:  lv1_inv_b(74) <= not( lv0_or(148) );
 b075_002_inv:  lv1_inv_b(75) <= not( lv0_or(150) );
 b076_002_inv:  lv1_inv_b(76) <= not( lv0_or(152) );
 b077_002_inv:  lv1_inv_b(77) <= not( lv0_or(154) );
 b078_002_inv:  lv1_inv_b(78) <= not( lv0_or(156) );
 b079_002_inv:  lv1_inv_b(79) <= not( lv0_or(158) );
 b080_002_inv:  lv1_inv_b(80) <= not( lv0_or(160) );
 b081_002_inv:  lv1_inv_b(81) <= not( lv0_or(162) );

 b000_002_enc7:  lv1_enc7_b(0) <= not( lv1_inv_b(0) and lv0_or(1) );
 b001_002_enc7:  lv1_enc7_b(1) <= not( lv1_inv_b(1) and lv0_or(3) );
 b002_002_enc7:  lv1_enc7_b(2) <= not( lv1_inv_b(2) and lv0_or(5) );
 b003_002_enc7:  lv1_enc7_b(3) <= not( lv1_inv_b(3) and lv0_or(7) );
 b004_002_enc7:  lv1_enc7_b(4) <= not( lv1_inv_b(4) and lv0_or(9) );
 b005_002_enc7:  lv1_enc7_b(5) <= not( lv1_inv_b(5) and lv0_or(11) );
 b006_002_enc7:  lv1_enc7_b(6) <= not( lv1_inv_b(6) and lv0_or(13) );
 b007_002_enc7:  lv1_enc7_b(7) <= not( lv1_inv_b(7) and lv0_or(15) );
 b008_002_enc7:  lv1_enc7_b(8) <= not( lv1_inv_b(8) and lv0_or(17) );
 b009_002_enc7:  lv1_enc7_b(9) <= not( lv1_inv_b(9) and lv0_or(19) );
 b010_002_enc7:  lv1_enc7_b(10) <= not( lv1_inv_b(10) and lv0_or(21) );
 b011_002_enc7:  lv1_enc7_b(11) <= not( lv1_inv_b(11) and lv0_or(23) );
 b012_002_enc7:  lv1_enc7_b(12) <= not( lv1_inv_b(12) and lv0_or(25) );
 b013_002_enc7:  lv1_enc7_b(13) <= not( lv1_inv_b(13) and lv0_or(27) );
 b014_002_enc7:  lv1_enc7_b(14) <= not( lv1_inv_b(14) and lv0_or(29) );
 b015_002_enc7:  lv1_enc7_b(15) <= not( lv1_inv_b(15) and lv0_or(31) );
 b016_002_enc7:  lv1_enc7_b(16) <= not( lv1_inv_b(16) and lv0_or(33) );
 b017_002_enc7:  lv1_enc7_b(17) <= not( lv1_inv_b(17) and lv0_or(35) );
 b018_002_enc7:  lv1_enc7_b(18) <= not( lv1_inv_b(18) and lv0_or(37) );
 b019_002_enc7:  lv1_enc7_b(19) <= not( lv1_inv_b(19) and lv0_or(39) );
 b020_002_enc7:  lv1_enc7_b(20) <= not( lv1_inv_b(20) and lv0_or(41) );
 b021_002_enc7:  lv1_enc7_b(21) <= not( lv1_inv_b(21) and lv0_or(43) );
 b022_002_enc7:  lv1_enc7_b(22) <= not( lv1_inv_b(22) and lv0_or(45) );
 b023_002_enc7:  lv1_enc7_b(23) <= not( lv1_inv_b(23) and lv0_or(47) );
 b024_002_enc7:  lv1_enc7_b(24) <= not( lv1_inv_b(24) and lv0_or(49) );
 b025_002_enc7:  lv1_enc7_b(25) <= not( lv1_inv_b(25) and lv0_or(51) );
 b026_002_enc7:  lv1_enc7_b(26) <= not( lv1_inv_b(26) and lv0_or(53) );
 b027_002_enc7:  lv1_enc7_b(27) <= not( lv1_inv_b(27) and lv0_or(55) );
 b028_002_enc7:  lv1_enc7_b(28) <= not( lv1_inv_b(28) and lv0_or(57) );
 b029_002_enc7:  lv1_enc7_b(29) <= not( lv1_inv_b(29) and lv0_or(59) );
 b030_002_enc7:  lv1_enc7_b(30) <= not( lv1_inv_b(30) and lv0_or(61) );
 b031_002_enc7:  lv1_enc7_b(31) <= not( lv1_inv_b(31) and lv0_or(63) );
 b032_002_enc7:  lv1_enc7_b(32) <= not( lv1_inv_b(32) and lv0_or(65) );
 b033_002_enc7:  lv1_enc7_b(33) <= not( lv1_inv_b(33) and lv0_or(67) );
 b034_002_enc7:  lv1_enc7_b(34) <= not( lv1_inv_b(34) and lv0_or(69) );
 b035_002_enc7:  lv1_enc7_b(35) <= not( lv1_inv_b(35) and lv0_or(71) );
 b036_002_enc7:  lv1_enc7_b(36) <= not( lv1_inv_b(36) and lv0_or(73) );
 b037_002_enc7:  lv1_enc7_b(37) <= not( lv1_inv_b(37) and lv0_or(75) );
 b038_002_enc7:  lv1_enc7_b(38) <= not( lv1_inv_b(38) and lv0_or(77) );
 b039_002_enc7:  lv1_enc7_b(39) <= not( lv1_inv_b(39) and lv0_or(79) );
 b040_002_enc7:  lv1_enc7_b(40) <= not( lv1_inv_b(40) and lv0_or(81) );
 b041_002_enc7:  lv1_enc7_b(41) <= not( lv1_inv_b(41) and lv0_or(83) );
 b042_002_enc7:  lv1_enc7_b(42) <= not( lv1_inv_b(42) and lv0_or(85) );
 b043_002_enc7:  lv1_enc7_b(43) <= not( lv1_inv_b(43) and lv0_or(87) );
 b044_002_enc7:  lv1_enc7_b(44) <= not( lv1_inv_b(44) and lv0_or(89) );
 b045_002_enc7:  lv1_enc7_b(45) <= not( lv1_inv_b(45) and lv0_or(91) );
 b046_002_enc7:  lv1_enc7_b(46) <= not( lv1_inv_b(46) and lv0_or(93) );
 b047_002_enc7:  lv1_enc7_b(47) <= not( lv1_inv_b(47) and lv0_or(95) );
 b048_002_enc7:  lv1_enc7_b(48) <= not( lv1_inv_b(48) and lv0_or(97) );
 b049_002_enc7:  lv1_enc7_b(49) <= not( lv1_inv_b(49) and lv0_or(99) );
 b050_002_enc7:  lv1_enc7_b(50) <= not( lv1_inv_b(50) and lv0_or(101) );
 b051_002_enc7:  lv1_enc7_b(51) <= not( lv1_inv_b(51) and lv0_or(103) );
 b052_002_enc7:  lv1_enc7_b(52) <= not( lv1_inv_b(52) and lv0_or(105) );
 b053_002_enc7:  lv1_enc7_b(53) <= not( lv1_inv_b(53) and lv0_or(107) );
 b054_002_enc7:  lv1_enc7_b(54) <= not( lv1_inv_b(54) and lv0_or(109) );
 b055_002_enc7:  lv1_enc7_b(55) <= not( lv1_inv_b(55) and lv0_or(111) );
 b056_002_enc7:  lv1_enc7_b(56) <= not( lv1_inv_b(56) and lv0_or(113) );
 b057_002_enc7:  lv1_enc7_b(57) <= not( lv1_inv_b(57) and lv0_or(115) );
 b058_002_enc7:  lv1_enc7_b(58) <= not( lv1_inv_b(58) and lv0_or(117) );
 b059_002_enc7:  lv1_enc7_b(59) <= not( lv1_inv_b(59) and lv0_or(119) );
 b060_002_enc7:  lv1_enc7_b(60) <= not( lv1_inv_b(60) and lv0_or(121) );
 b061_002_enc7:  lv1_enc7_b(61) <= not( lv1_inv_b(61) and lv0_or(123) );
 b062_002_enc7:  lv1_enc7_b(62) <= not( lv1_inv_b(62) and lv0_or(125) );
 b063_002_enc7:  lv1_enc7_b(63) <= not( lv1_inv_b(63) and lv0_or(127) );
 b064_002_enc7:  lv1_enc7_b(64) <= not( lv1_inv_b(64) and lv0_or(129) );
 b065_002_enc7:  lv1_enc7_b(65) <= not( lv1_inv_b(65) and lv0_or(131) );
 b066_002_enc7:  lv1_enc7_b(66) <= not( lv1_inv_b(66) and lv0_or(133) );
 b067_002_enc7:  lv1_enc7_b(67) <= not( lv1_inv_b(67) and lv0_or(135) );
 b068_002_enc7:  lv1_enc7_b(68) <= not( lv1_inv_b(68) and lv0_or(137) );
 b069_002_enc7:  lv1_enc7_b(69) <= not( lv1_inv_b(69) and lv0_or(139) );
 b070_002_enc7:  lv1_enc7_b(70) <= not( lv1_inv_b(70) and lv0_or(141) );
 b071_002_enc7:  lv1_enc7_b(71) <= not( lv1_inv_b(71) and lv0_or(143) );
 b072_002_enc7:  lv1_enc7_b(72) <= not( lv1_inv_b(72) and lv0_or(145) );
 b073_002_enc7:  lv1_enc7_b(73) <= not( lv1_inv_b(73) and lv0_or(147) );
 b074_002_enc7:  lv1_enc7_b(74) <= not( lv1_inv_b(74) and lv0_or(149) );
 b075_002_enc7:  lv1_enc7_b(75) <= not( lv1_inv_b(75) and lv0_or(151) );
 b076_002_enc7:  lv1_enc7_b(76) <= not( lv1_inv_b(76) and lv0_or(153) );
 b077_002_enc7:  lv1_enc7_b(77) <= not( lv1_inv_b(77) and lv0_or(155) );
 b078_002_enc7:  lv1_enc7_b(78) <= not( lv1_inv_b(78) and lv0_or(157) );
 b079_002_enc7:  lv1_enc7_b(79) <= not( lv1_inv_b(79) and lv0_or(159) );
 b080_002_enc7:  lv1_enc7_b(80) <= not( lv1_inv_b(80) and lv0_or(161) );
 b081_002_enc7:  lv1_enc7_b(81) <= not( lv1_inv_b(81) );



 b000_004_any:  lv2_or(0) <= not( lv1_or_b(0) and lv1_or_b(1) );
 b001_004_any:  lv2_or(1) <= not( lv1_or_b(2) and lv1_or_b(3) );
 b002_004_any:  lv2_or(2) <= not( lv1_or_b(4) and lv1_or_b(5) );
 b003_004_any:  lv2_or(3) <= not( lv1_or_b(6) and lv1_or_b(7) );
 b004_004_any:  lv2_or(4) <= not( lv1_or_b(8) and lv1_or_b(9) );
 b005_004_any:  lv2_or(5) <= not( lv1_or_b(10) and lv1_or_b(11) );
 b006_004_any:  lv2_or(6) <= not( lv1_or_b(12) and lv1_or_b(13) );
 b007_004_any:  lv2_or(7) <= not( lv1_or_b(14) and lv1_or_b(15) );
 b008_004_any:  lv2_or(8) <= not( lv1_or_b(16) and lv1_or_b(17) );
 b009_004_any:  lv2_or(9) <= not( lv1_or_b(18) and lv1_or_b(19) );
 b010_004_any:  lv2_or(10) <= not( lv1_or_b(20) and lv1_or_b(21) );
 b011_004_any:  lv2_or(11) <= not( lv1_or_b(22) and lv1_or_b(23) );
 b012_004_any:  lv2_or(12) <= not( lv1_or_b(24) and lv1_or_b(25) );
 b013_004_any:  lv2_or(13) <= not( lv1_or_b(26) and lv1_or_b(27) );
 b014_004_any:  lv2_or(14) <= not( lv1_or_b(28) and lv1_or_b(29) );
 b015_004_any:  lv2_or(15) <= not( lv1_or_b(30) and lv1_or_b(31) );
 b016_004_any:  lv2_or(16) <= not( lv1_or_b(32) and lv1_or_b(33) );
 b017_004_any:  lv2_or(17) <= not( lv1_or_b(34) and lv1_or_b(35) );
 b018_004_any:  lv2_or(18) <= not( lv1_or_b(36) and lv1_or_b(37) );
 b019_004_any:  lv2_or(19) <= not( lv1_or_b(38) and lv1_or_b(39) );
 b020_004_any:  lv2_or(20) <= not( lv1_or_b(40) and lv1_or_b(41) );
 b021_004_any:  lv2_or(21) <= not( lv1_or_b(42) and lv1_or_b(43) );
 b022_004_any:  lv2_or(22) <= not( lv1_or_b(44) and lv1_or_b(45) );
 b023_004_any:  lv2_or(23) <= not( lv1_or_b(46) and lv1_or_b(47) );
 b024_004_any:  lv2_or(24) <= not( lv1_or_b(48) and lv1_or_b(49) );
 b025_004_any:  lv2_or(25) <= not( lv1_or_b(50) and lv1_or_b(51) );
 b026_004_any:  lv2_or(26) <= not( lv1_or_b(52) and lv1_or_b(53) );
 b027_004_any:  lv2_or(27) <= not( lv1_or_b(54) and lv1_or_b(55) );
 b028_004_any:  lv2_or(28) <= not( lv1_or_b(56) and lv1_or_b(57) );
 b029_004_any:  lv2_or(29) <= not( lv1_or_b(58) and lv1_or_b(59) );
 b030_004_any:  lv2_or(30) <= not( lv1_or_b(60) and lv1_or_b(61) );
 b031_004_any:  lv2_or(31) <= not( lv1_or_b(62) and lv1_or_b(63) );
 b032_004_any:  lv2_or(32) <= not( lv1_or_b(64) and lv1_or_b(65) );
 b033_004_any:  lv2_or(33) <= not( lv1_or_b(66) and lv1_or_b(67) );
 b034_004_any:  lv2_or(34) <= not( lv1_or_b(68) and lv1_or_b(69) );
 b035_004_any:  lv2_or(35) <= not( lv1_or_b(70) and lv1_or_b(71) );
 b036_004_any:  lv2_or(36) <= not( lv1_or_b(72) and lv1_or_b(73) );
 b037_004_any:  lv2_or(37) <= not( lv1_or_b(74) and lv1_or_b(75) );
 b038_004_any:  lv2_or(38) <= not( lv1_or_b(76) and lv1_or_b(77) );
 b039_004_any:  lv2_or(39) <= not( lv1_or_b(78) and lv1_or_b(79) );
 b040_004_any:  lv2_or(40) <= not( lv1_or_b(80) and lv1_or_b(81) );

 b000_004_inv:  lv2_inv(0) <= not( lv1_or_b(0) );
 b001_004_inv:  lv2_inv(1) <= not( lv1_or_b(2) );
 b002_004_inv:  lv2_inv(2) <= not( lv1_or_b(4) );
 b003_004_inv:  lv2_inv(3) <= not( lv1_or_b(6) );
 b004_004_inv:  lv2_inv(4) <= not( lv1_or_b(8) );
 b005_004_inv:  lv2_inv(5) <= not( lv1_or_b(10) );
 b006_004_inv:  lv2_inv(6) <= not( lv1_or_b(12) );
 b007_004_inv:  lv2_inv(7) <= not( lv1_or_b(14) );
 b008_004_inv:  lv2_inv(8) <= not( lv1_or_b(16) );
 b009_004_inv:  lv2_inv(9) <= not( lv1_or_b(18) );
 b010_004_inv:  lv2_inv(10) <= not( lv1_or_b(20) );
 b011_004_inv:  lv2_inv(11) <= not( lv1_or_b(22) );
 b012_004_inv:  lv2_inv(12) <= not( lv1_or_b(24) );
 b013_004_inv:  lv2_inv(13) <= not( lv1_or_b(26) );
 b014_004_inv:  lv2_inv(14) <= not( lv1_or_b(28) );
 b015_004_inv:  lv2_inv(15) <= not( lv1_or_b(30) );
 b016_004_inv:  lv2_inv(16) <= not( lv1_or_b(32) );
 b017_004_inv:  lv2_inv(17) <= not( lv1_or_b(34) );
 b018_004_inv:  lv2_inv(18) <= not( lv1_or_b(36) );
 b019_004_inv:  lv2_inv(19) <= not( lv1_or_b(38) );
 b020_004_inv:  lv2_inv(20) <= not( lv1_or_b(40) );
 b021_004_inv:  lv2_inv(21) <= not( lv1_or_b(42) );
 b022_004_inv:  lv2_inv(22) <= not( lv1_or_b(44) );
 b023_004_inv:  lv2_inv(23) <= not( lv1_or_b(46) );
 b024_004_inv:  lv2_inv(24) <= not( lv1_or_b(48) );
 b025_004_inv:  lv2_inv(25) <= not( lv1_or_b(50) );
 b026_004_inv:  lv2_inv(26) <= not( lv1_or_b(52) );
 b027_004_inv:  lv2_inv(27) <= not( lv1_or_b(54) );
 b028_004_inv:  lv2_inv(28) <= not( lv1_or_b(56) );
 b029_004_inv:  lv2_inv(29) <= not( lv1_or_b(58) );
 b030_004_inv:  lv2_inv(30) <= not( lv1_or_b(60) );
 b031_004_inv:  lv2_inv(31) <= not( lv1_or_b(62) );
 b032_004_inv:  lv2_inv(32) <= not( lv1_or_b(64) );
 b033_004_inv:  lv2_inv(33) <= not( lv1_or_b(66) );
 b034_004_inv:  lv2_inv(34) <= not( lv1_or_b(68) );
 b035_004_inv:  lv2_inv(35) <= not( lv1_or_b(70) );
 b036_004_inv:  lv2_inv(36) <= not( lv1_or_b(72) );
 b037_004_inv:  lv2_inv(37) <= not( lv1_or_b(74) );
 b038_004_inv:  lv2_inv(38) <= not( lv1_or_b(76) );
 b039_004_inv:  lv2_inv(39) <= not( lv1_or_b(78) );
 b040_004_inv:  lv2_inv(40) <= not( lv1_or_b(80) );

 b000_004_enc6:  lv2_enc6(0) <= not( lv2_inv(0) or  lv1_or_b(1) );
 b001_004_enc6:  lv2_enc6(1) <= not( lv2_inv(1) or  lv1_or_b(3) );
 b002_004_enc6:  lv2_enc6(2) <= not( lv2_inv(2) or  lv1_or_b(5) );
 b003_004_enc6:  lv2_enc6(3) <= not( lv2_inv(3) or  lv1_or_b(7) );
 b004_004_enc6:  lv2_enc6(4) <= not( lv2_inv(4) or  lv1_or_b(9) );
 b005_004_enc6:  lv2_enc6(5) <= not( lv2_inv(5) or  lv1_or_b(11) );
 b006_004_enc6:  lv2_enc6(6) <= not( lv2_inv(6) or  lv1_or_b(13) );
 b007_004_enc6:  lv2_enc6(7) <= not( lv2_inv(7) or  lv1_or_b(15) );
 b008_004_enc6:  lv2_enc6(8) <= not( lv2_inv(8) or  lv1_or_b(17) );
 b009_004_enc6:  lv2_enc6(9) <= not( lv2_inv(9) or  lv1_or_b(19) );
 b010_004_enc6:  lv2_enc6(10) <= not( lv2_inv(10) or  lv1_or_b(21) );
 b011_004_enc6:  lv2_enc6(11) <= not( lv2_inv(11) or  lv1_or_b(23) );
 b012_004_enc6:  lv2_enc6(12) <= not( lv2_inv(12) or  lv1_or_b(25) );
 b013_004_enc6:  lv2_enc6(13) <= not( lv2_inv(13) or  lv1_or_b(27) );
 b014_004_enc6:  lv2_enc6(14) <= not( lv2_inv(14) or  lv1_or_b(29) );
 b015_004_enc6:  lv2_enc6(15) <= not( lv2_inv(15) or  lv1_or_b(31) );
 b016_004_enc6:  lv2_enc6(16) <= not( lv2_inv(16) or  lv1_or_b(33) );
 b017_004_enc6:  lv2_enc6(17) <= not( lv2_inv(17) or  lv1_or_b(35) );
 b018_004_enc6:  lv2_enc6(18) <= not( lv2_inv(18) or  lv1_or_b(37) );
 b019_004_enc6:  lv2_enc6(19) <= not( lv2_inv(19) or  lv1_or_b(39) );
 b020_004_enc6:  lv2_enc6(20) <= not( lv2_inv(20) or  lv1_or_b(41) );
 b021_004_enc6:  lv2_enc6(21) <= not( lv2_inv(21) or  lv1_or_b(43) );
 b022_004_enc6:  lv2_enc6(22) <= not( lv2_inv(22) or  lv1_or_b(45) );
 b023_004_enc6:  lv2_enc6(23) <= not( lv2_inv(23) or  lv1_or_b(47) );
 b024_004_enc6:  lv2_enc6(24) <= not( lv2_inv(24) or  lv1_or_b(49) );
 b025_004_enc6:  lv2_enc6(25) <= not( lv2_inv(25) or  lv1_or_b(51) );
 b026_004_enc6:  lv2_enc6(26) <= not( lv2_inv(26) or  lv1_or_b(53) );
 b027_004_enc6:  lv2_enc6(27) <= not( lv2_inv(27) or  lv1_or_b(55) );
 b028_004_enc6:  lv2_enc6(28) <= not( lv2_inv(28) or  lv1_or_b(57) );
 b029_004_enc6:  lv2_enc6(29) <= not( lv2_inv(29) or  lv1_or_b(59) );
 b030_004_enc6:  lv2_enc6(30) <= not( lv2_inv(30) or  lv1_or_b(61) );
 b031_004_enc6:  lv2_enc6(31) <= not( lv2_inv(31) or  lv1_or_b(63) );
 b032_004_enc6:  lv2_enc6(32) <= not( lv2_inv(32) or  lv1_or_b(65) );
 b033_004_enc6:  lv2_enc6(33) <= not( lv2_inv(33) or  lv1_or_b(67) );
 b034_004_enc6:  lv2_enc6(34) <= not( lv2_inv(34) or  lv1_or_b(69) );
 b035_004_enc6:  lv2_enc6(35) <= not( lv2_inv(35) or  lv1_or_b(71) );
 b036_004_enc6:  lv2_enc6(36) <= not( lv2_inv(36) or  lv1_or_b(73) );
 b037_004_enc6:  lv2_enc6(37) <= not( lv2_inv(37) or  lv1_or_b(75) );
 b038_004_enc6:  lv2_enc6(38) <= not( lv2_inv(38) or  lv1_or_b(77) );
 b039_004_enc6:  lv2_enc6(39) <= not( lv2_inv(39) or  lv1_or_b(79) );
 b040_004_enc6:  lv2_enc6(40) <= not( lv2_inv(40) );

 b000_004_enc7:  lv2_enc7(0) <= not( lv1_enc7_b(0) and (lv1_enc7_b(1) or  lv2_inv(0))  );
 b001_004_enc7:  lv2_enc7(1) <= not( lv1_enc7_b(2) and (lv1_enc7_b(3) or  lv2_inv(1))  );
 b002_004_enc7:  lv2_enc7(2) <= not( lv1_enc7_b(4) and (lv1_enc7_b(5) or  lv2_inv(2))  );
 b003_004_enc7:  lv2_enc7(3) <= not( lv1_enc7_b(6) and (lv1_enc7_b(7) or  lv2_inv(3))  );
 b004_004_enc7:  lv2_enc7(4) <= not( lv1_enc7_b(8) and (lv1_enc7_b(9) or  lv2_inv(4))  );
 b005_004_enc7:  lv2_enc7(5) <= not( lv1_enc7_b(10) and (lv1_enc7_b(11) or  lv2_inv(5))  );
 b006_004_enc7:  lv2_enc7(6) <= not( lv1_enc7_b(12) and (lv1_enc7_b(13) or  lv2_inv(6))  );
 b007_004_enc7:  lv2_enc7(7) <= not( lv1_enc7_b(14) and (lv1_enc7_b(15) or  lv2_inv(7))  );
 b008_004_enc7:  lv2_enc7(8) <= not( lv1_enc7_b(16) and (lv1_enc7_b(17) or  lv2_inv(8))  );
 b009_004_enc7:  lv2_enc7(9) <= not( lv1_enc7_b(18) and (lv1_enc7_b(19) or  lv2_inv(9))  );
 b010_004_enc7:  lv2_enc7(10) <= not( lv1_enc7_b(20) and (lv1_enc7_b(21) or  lv2_inv(10))  );
 b011_004_enc7:  lv2_enc7(11) <= not( lv1_enc7_b(22) and (lv1_enc7_b(23) or  lv2_inv(11))  );
 b012_004_enc7:  lv2_enc7(12) <= not( lv1_enc7_b(24) and (lv1_enc7_b(25) or  lv2_inv(12))  );
 b013_004_enc7:  lv2_enc7(13) <= not( lv1_enc7_b(26) and (lv1_enc7_b(27) or  lv2_inv(13))  );
 b014_004_enc7:  lv2_enc7(14) <= not( lv1_enc7_b(28) and (lv1_enc7_b(29) or  lv2_inv(14))  );
 b015_004_enc7:  lv2_enc7(15) <= not( lv1_enc7_b(30) and (lv1_enc7_b(31) or  lv2_inv(15))  );
 b016_004_enc7:  lv2_enc7(16) <= not( lv1_enc7_b(32) and (lv1_enc7_b(33) or  lv2_inv(16))  );
 b017_004_enc7:  lv2_enc7(17) <= not( lv1_enc7_b(34) and (lv1_enc7_b(35) or  lv2_inv(17))  );
 b018_004_enc7:  lv2_enc7(18) <= not( lv1_enc7_b(36) and (lv1_enc7_b(37) or  lv2_inv(18))  );
 b019_004_enc7:  lv2_enc7(19) <= not( lv1_enc7_b(38) and (lv1_enc7_b(39) or  lv2_inv(19))  );
 b020_004_enc7:  lv2_enc7(20) <= not( lv1_enc7_b(40) and (lv1_enc7_b(41) or  lv2_inv(20))  );
 b021_004_enc7:  lv2_enc7(21) <= not( lv1_enc7_b(42) and (lv1_enc7_b(43) or  lv2_inv(21))  );
 b022_004_enc7:  lv2_enc7(22) <= not( lv1_enc7_b(44) and (lv1_enc7_b(45) or  lv2_inv(22))  );
 b023_004_enc7:  lv2_enc7(23) <= not( lv1_enc7_b(46) and (lv1_enc7_b(47) or  lv2_inv(23))  );
 b024_004_enc7:  lv2_enc7(24) <= not( lv1_enc7_b(48) and (lv1_enc7_b(49) or  lv2_inv(24))  );
 b025_004_enc7:  lv2_enc7(25) <= not( lv1_enc7_b(50) and (lv1_enc7_b(51) or  lv2_inv(25))  );
 b026_004_enc7:  lv2_enc7(26) <= not( lv1_enc7_b(52) and (lv1_enc7_b(53) or  lv2_inv(26))  );
 b027_004_enc7:  lv2_enc7(27) <= not( lv1_enc7_b(54) and (lv1_enc7_b(55) or  lv2_inv(27))  );
 b028_004_enc7:  lv2_enc7(28) <= not( lv1_enc7_b(56) and (lv1_enc7_b(57) or  lv2_inv(28))  );
 b029_004_enc7:  lv2_enc7(29) <= not( lv1_enc7_b(58) and (lv1_enc7_b(59) or  lv2_inv(29))  );
 b030_004_enc7:  lv2_enc7(30) <= not( lv1_enc7_b(60) and (lv1_enc7_b(61) or  lv2_inv(30))  );
 b031_004_enc7:  lv2_enc7(31) <= not( lv1_enc7_b(62) and (lv1_enc7_b(63) or  lv2_inv(31))  );
 b032_004_enc7:  lv2_enc7(32) <= not( lv1_enc7_b(64) and (lv1_enc7_b(65) or  lv2_inv(32))  );
 b033_004_enc7:  lv2_enc7(33) <= not( lv1_enc7_b(66) and (lv1_enc7_b(67) or  lv2_inv(33))  );
 b034_004_enc7:  lv2_enc7(34) <= not( lv1_enc7_b(68) and (lv1_enc7_b(69) or  lv2_inv(34))  );
 b035_004_enc7:  lv2_enc7(35) <= not( lv1_enc7_b(70) and (lv1_enc7_b(71) or  lv2_inv(35))  );
 b036_004_enc7:  lv2_enc7(36) <= not( lv1_enc7_b(72) and (lv1_enc7_b(73) or  lv2_inv(36))  );
 b037_004_enc7:  lv2_enc7(37) <= not( lv1_enc7_b(74) and (lv1_enc7_b(75) or  lv2_inv(37))  );
 b038_004_enc7:  lv2_enc7(38) <= not( lv1_enc7_b(76) and (lv1_enc7_b(77) or  lv2_inv(38))  );
 b039_004_enc7:  lv2_enc7(39) <= not( lv1_enc7_b(78) and (lv1_enc7_b(79) or  lv2_inv(39))  );
 b040_004_enc7:  lv2_enc7(40) <= not( lv1_enc7_b(80) and (lv1_enc7_b(81) or  lv2_inv(40))  );



 b000_008_any:  lv3_or_b(0) <= not( lv2_or(0) or  lv2_or(1) );
 b001_008_any:  lv3_or_b(1) <= not( lv2_or(2) or  lv2_or(3) );
 b002_008_any:  lv3_or_b(2) <= not( lv2_or(4) or  lv2_or(5) );
 b003_008_any:  lv3_or_b(3) <= not( lv2_or(6) or  lv2_or(7) );
 b004_008_any:  lv3_or_b(4) <= not( lv2_or(8) or  lv2_or(9) );
 b005_008_any:  lv3_or_b(5) <= not( lv2_or(10) or  lv2_or(11) );
 b006_008_any:  lv3_or_b(6) <= not( lv2_or(12) or  lv2_or(13) );
 b007_008_any:  lv3_or_b(7) <= not( lv2_or(14) or  lv2_or(15) );
 b008_008_any:  lv3_or_b(8) <= not( lv2_or(16) or  lv2_or(17) );
 b009_008_any:  lv3_or_b(9) <= not( lv2_or(18) or  lv2_or(19) );
 b010_008_any:  lv3_or_b(10) <= not( lv2_or(20) or  lv2_or(21) );
 b011_008_any:  lv3_or_b(11) <= not( lv2_or(22) or  lv2_or(23) );
 b012_008_any:  lv3_or_b(12) <= not( lv2_or(24) or  lv2_or(25) );
 b013_008_any:  lv3_or_b(13) <= not( lv2_or(26) or  lv2_or(27) );
 b014_008_any:  lv3_or_b(14) <= not( lv2_or(28) or  lv2_or(29) );
 b015_008_any:  lv3_or_b(15) <= not( lv2_or(30) or  lv2_or(31) );
 b016_008_any:  lv3_or_b(16) <= not( lv2_or(32) or  lv2_or(33) );
 b017_008_any:  lv3_or_b(17) <= not( lv2_or(34) or  lv2_or(35) );
 b018_008_any:  lv3_or_b(18) <= not( lv2_or(36) or  lv2_or(37) );
 b019_008_any:  lv3_or_b(19) <= not( lv2_or(38) or  lv2_or(39) );
 b020_008_any:  lv3_or_b(20) <= not( lv2_or(40) );

 b000_008_inv:  lv3_inv_b(0) <= not( lv2_or(0) );
 b001_008_inv:  lv3_inv_b(1) <= not( lv2_or(2) );
 b002_008_inv:  lv3_inv_b(2) <= not( lv2_or(4) );
 b003_008_inv:  lv3_inv_b(3) <= not( lv2_or(6) );
 b004_008_inv:  lv3_inv_b(4) <= not( lv2_or(8) );
 b005_008_inv:  lv3_inv_b(5) <= not( lv2_or(10) );
 b006_008_inv:  lv3_inv_b(6) <= not( lv2_or(12) );
 b007_008_inv:  lv3_inv_b(7) <= not( lv2_or(14) );
 b008_008_inv:  lv3_inv_b(8) <= not( lv2_or(16) );
 b009_008_inv:  lv3_inv_b(9) <= not( lv2_or(18) );
 b010_008_inv:  lv3_inv_b(10) <= not( lv2_or(20) );
 b011_008_inv:  lv3_inv_b(11) <= not( lv2_or(22) );
 b012_008_inv:  lv3_inv_b(12) <= not( lv2_or(24) );
 b013_008_inv:  lv3_inv_b(13) <= not( lv2_or(26) );
 b014_008_inv:  lv3_inv_b(14) <= not( lv2_or(28) );
 b015_008_inv:  lv3_inv_b(15) <= not( lv2_or(30) );
 b016_008_inv:  lv3_inv_b(16) <= not( lv2_or(32) );
 b017_008_inv:  lv3_inv_b(17) <= not( lv2_or(34) );
 b018_008_inv:  lv3_inv_b(18) <= not( lv2_or(36) );
 b019_008_inv:  lv3_inv_b(19) <= not( lv2_or(38) );
 b020_008_inv:  lv3_inv_b(20) <= not( lv2_or(40) );

 b000_008_enc5:  lv3_enc5_b(0) <= not( lv3_inv_b(0) and lv2_or(1) );
 b001_008_enc5:  lv3_enc5_b(1) <= not( lv3_inv_b(1) and lv2_or(3) );
 b002_008_enc5:  lv3_enc5_b(2) <= not( lv3_inv_b(2) and lv2_or(5) );
 b003_008_enc5:  lv3_enc5_b(3) <= not( lv3_inv_b(3) and lv2_or(7) );
 b004_008_enc5:  lv3_enc5_b(4) <= not( lv3_inv_b(4) and lv2_or(9) );
 b005_008_enc5:  lv3_enc5_b(5) <= not( lv3_inv_b(5) and lv2_or(11) );
 b006_008_enc5:  lv3_enc5_b(6) <= not( lv3_inv_b(6) and lv2_or(13) );
 b007_008_enc5:  lv3_enc5_b(7) <= not( lv3_inv_b(7) and lv2_or(15) );
 b008_008_enc5:  lv3_enc5_b(8) <= not( lv3_inv_b(8) and lv2_or(17) );
 b009_008_enc5:  lv3_enc5_b(9) <= not( lv3_inv_b(9) and lv2_or(19) );
 b010_008_enc5:  lv3_enc5_b(10) <= not( lv3_inv_b(10) and lv2_or(21) );
 b011_008_enc5:  lv3_enc5_b(11) <= not( lv3_inv_b(11) and lv2_or(23) );
 b012_008_enc5:  lv3_enc5_b(12) <= not( lv3_inv_b(12) and lv2_or(25) );
 b013_008_enc5:  lv3_enc5_b(13) <= not( lv3_inv_b(13) and lv2_or(27) );
 b014_008_enc5:  lv3_enc5_b(14) <= not( lv3_inv_b(14) and lv2_or(29) );
 b015_008_enc5:  lv3_enc5_b(15) <= not( lv3_inv_b(15) and lv2_or(31) );
 b016_008_enc5:  lv3_enc5_b(16) <= not( lv3_inv_b(16) and lv2_or(33) );
 b017_008_enc5:  lv3_enc5_b(17) <= not( lv3_inv_b(17) and lv2_or(35) );
 b018_008_enc5:  lv3_enc5_b(18) <= not( lv3_inv_b(18) and lv2_or(37) );
 b019_008_enc5:  lv3_enc5_b(19) <= not( lv3_inv_b(19) and lv2_or(39) );
                 lv3_enc5_b(20) <= tiup ;

 b000_008_enc6:  lv3_enc6_b(0) <= not( lv2_enc6(0) or  (lv2_enc6(1) and lv3_inv_b(0))  );
 b001_008_enc6:  lv3_enc6_b(1) <= not( lv2_enc6(2) or  (lv2_enc6(3) and lv3_inv_b(1))  );
 b002_008_enc6:  lv3_enc6_b(2) <= not( lv2_enc6(4) or  (lv2_enc6(5) and lv3_inv_b(2))  );
 b003_008_enc6:  lv3_enc6_b(3) <= not( lv2_enc6(6) or  (lv2_enc6(7) and lv3_inv_b(3))  );
 b004_008_enc6:  lv3_enc6_b(4) <= not( lv2_enc6(8) or  (lv2_enc6(9) and lv3_inv_b(4))  );
 b005_008_enc6:  lv3_enc6_b(5) <= not( lv2_enc6(10) or  (lv2_enc6(11) and lv3_inv_b(5))  );
 b006_008_enc6:  lv3_enc6_b(6) <= not( lv2_enc6(12) or  (lv2_enc6(13) and lv3_inv_b(6))  );
 b007_008_enc6:  lv3_enc6_b(7) <= not( lv2_enc6(14) or  (lv2_enc6(15) and lv3_inv_b(7))  );
 b008_008_enc6:  lv3_enc6_b(8) <= not( lv2_enc6(16) or  (lv2_enc6(17) and lv3_inv_b(8))  );
 b009_008_enc6:  lv3_enc6_b(9) <= not( lv2_enc6(18) or  (lv2_enc6(19) and lv3_inv_b(9))  );
 b010_008_enc6:  lv3_enc6_b(10) <= not( lv2_enc6(20) or  (lv2_enc6(21) and lv3_inv_b(10))  );
 b011_008_enc6:  lv3_enc6_b(11) <= not( lv2_enc6(22) or  (lv2_enc6(23) and lv3_inv_b(11))  );
 b012_008_enc6:  lv3_enc6_b(12) <= not( lv2_enc6(24) or  (lv2_enc6(25) and lv3_inv_b(12))  );
 b013_008_enc6:  lv3_enc6_b(13) <= not( lv2_enc6(26) or  (lv2_enc6(27) and lv3_inv_b(13))  );
 b014_008_enc6:  lv3_enc6_b(14) <= not( lv2_enc6(28) or  (lv2_enc6(29) and lv3_inv_b(14))  );
 b015_008_enc6:  lv3_enc6_b(15) <= not( lv2_enc6(30) or  (lv2_enc6(31) and lv3_inv_b(15))  );
 b016_008_enc6:  lv3_enc6_b(16) <= not( lv2_enc6(32) or  (lv2_enc6(33) and lv3_inv_b(16))  );
 b017_008_enc6:  lv3_enc6_b(17) <= not( lv2_enc6(34) or  (lv2_enc6(35) and lv3_inv_b(17))  );
 b018_008_enc6:  lv3_enc6_b(18) <= not( lv2_enc6(36) or  (lv2_enc6(37) and lv3_inv_b(18))  );
 b019_008_enc6:  lv3_enc6_b(19) <= not( lv2_enc6(38) or  (lv2_enc6(39) and lv3_inv_b(19))  );
 b020_008_enc6:  lv3_enc6_b(20) <= not( lv2_enc6(40) or   lv3_inv_b(20)  );

 b000_008_enc7:  lv3_enc7_b(0) <= not( lv2_enc7(0) or  (lv2_enc7(1) and lv3_inv_b(0))  );
 b001_008_enc7:  lv3_enc7_b(1) <= not( lv2_enc7(2) or  (lv2_enc7(3) and lv3_inv_b(1))  );
 b002_008_enc7:  lv3_enc7_b(2) <= not( lv2_enc7(4) or  (lv2_enc7(5) and lv3_inv_b(2))  );
 b003_008_enc7:  lv3_enc7_b(3) <= not( lv2_enc7(6) or  (lv2_enc7(7) and lv3_inv_b(3))  );
 b004_008_enc7:  lv3_enc7_b(4) <= not( lv2_enc7(8) or  (lv2_enc7(9) and lv3_inv_b(4))  );
 b005_008_enc7:  lv3_enc7_b(5) <= not( lv2_enc7(10) or  (lv2_enc7(11) and lv3_inv_b(5))  );
 b006_008_enc7:  lv3_enc7_b(6) <= not( lv2_enc7(12) or  (lv2_enc7(13) and lv3_inv_b(6))  );
 b007_008_enc7:  lv3_enc7_b(7) <= not( lv2_enc7(14) or  (lv2_enc7(15) and lv3_inv_b(7))  );
 b008_008_enc7:  lv3_enc7_b(8) <= not( lv2_enc7(16) or  (lv2_enc7(17) and lv3_inv_b(8))  );
 b009_008_enc7:  lv3_enc7_b(9) <= not( lv2_enc7(18) or  (lv2_enc7(19) and lv3_inv_b(9))  );
 b010_008_enc7:  lv3_enc7_b(10) <= not( lv2_enc7(20) or  (lv2_enc7(21) and lv3_inv_b(10))  );
 b011_008_enc7:  lv3_enc7_b(11) <= not( lv2_enc7(22) or  (lv2_enc7(23) and lv3_inv_b(11))  );
 b012_008_enc7:  lv3_enc7_b(12) <= not( lv2_enc7(24) or  (lv2_enc7(25) and lv3_inv_b(12))  );
 b013_008_enc7:  lv3_enc7_b(13) <= not( lv2_enc7(26) or  (lv2_enc7(27) and lv3_inv_b(13))  );
 b014_008_enc7:  lv3_enc7_b(14) <= not( lv2_enc7(28) or  (lv2_enc7(29) and lv3_inv_b(14))  );
 b015_008_enc7:  lv3_enc7_b(15) <= not( lv2_enc7(30) or  (lv2_enc7(31) and lv3_inv_b(15))  );
 b016_008_enc7:  lv3_enc7_b(16) <= not( lv2_enc7(32) or  (lv2_enc7(33) and lv3_inv_b(16))  );
 b017_008_enc7:  lv3_enc7_b(17) <= not( lv2_enc7(34) or  (lv2_enc7(35) and lv3_inv_b(17))  );
 b018_008_enc7:  lv3_enc7_b(18) <= not( lv2_enc7(36) or  (lv2_enc7(37) and lv3_inv_b(18))  );
 b019_008_enc7:  lv3_enc7_b(19) <= not( lv2_enc7(38) or  (lv2_enc7(39) and lv3_inv_b(19))  );
 b020_008_enc7:  lv3_enc7_b(20) <= not( lv2_enc7(40) or   lv3_inv_b(20)  );



 b000_016_any:  lv4_or(0) <= not( lv3_or_b(0) and lv3_or_b(1) );
 b001_016_any:  lv4_or(1) <= not( lv3_or_b(2) and lv3_or_b(3) );
 b002_016_any:  lv4_or(2) <= not( lv3_or_b(4) and lv3_or_b(5) );
 b003_016_any:  lv4_or(3) <= not( lv3_or_b(6) and lv3_or_b(7) );
 b004_016_any:  lv4_or(4) <= not( lv3_or_b(8) and lv3_or_b(9) );
 b005_016_any:  lv4_or(5) <= not( lv3_or_b(10) and lv3_or_b(11) );
 b006_016_any:  lv4_or(6) <= not( lv3_or_b(12) and lv3_or_b(13) );
 b007_016_any:  lv4_or(7) <= not( lv3_or_b(14) and lv3_or_b(15) );
 b008_016_any:  lv4_or(8) <= not( lv3_or_b(16) and lv3_or_b(17) );
 b009_016_any:  lv4_or(9) <= not( lv3_or_b(18) and lv3_or_b(19) );
 b010_016_any:  lv4_or(10) <= not( lv3_or_b(20) );

 b000_016_inv:  lv4_inv(0) <= not( lv3_or_b(0) );
 b001_016_inv:  lv4_inv(1) <= not( lv3_or_b(2) );
 b002_016_inv:  lv4_inv(2) <= not( lv3_or_b(4) );
 b003_016_inv:  lv4_inv(3) <= not( lv3_or_b(6) );
 b004_016_inv:  lv4_inv(4) <= not( lv3_or_b(8) );
 b005_016_inv:  lv4_inv(5) <= not( lv3_or_b(10) );
 b006_016_inv:  lv4_inv(6) <= not( lv3_or_b(12) );
 b007_016_inv:  lv4_inv(7) <= not( lv3_or_b(14) );
 b008_016_inv:  lv4_inv(8) <= not( lv3_or_b(16) );
 b009_016_inv:  lv4_inv(9) <= not( lv3_or_b(18) );
 b010_016_inv:  lv4_inv(10) <= not( lv3_or_b(20) );

 b000_016_enc4:  lv4_enc4(0) <= not( lv4_inv(0) or  lv3_or_b(1) );
 b001_016_enc4:  lv4_enc4(1) <= not( lv4_inv(1) or  lv3_or_b(3) );
 b002_016_enc4:  lv4_enc4(2) <= not( lv4_inv(2) or  lv3_or_b(5) );
 b003_016_enc4:  lv4_enc4(3) <= not( lv4_inv(3) or  lv3_or_b(7) );
 b004_016_enc4:  lv4_enc4(4) <= not( lv4_inv(4) or  lv3_or_b(9) );
 b005_016_enc4:  lv4_enc4(5) <= not( lv4_inv(5) or  lv3_or_b(11) );
 b006_016_enc4:  lv4_enc4(6) <= not( lv4_inv(6) or  lv3_or_b(13) );
 b007_016_enc4:  lv4_enc4(7) <= not( lv4_inv(7) or  lv3_or_b(15) );
 b008_016_enc4:  lv4_enc4(8) <= not( lv4_inv(8) or  lv3_or_b(17) );
 b009_016_enc4:  lv4_enc4(9) <= not( lv4_inv(9) or  lv3_or_b(19) );
                 lv4_enc4(10) <= tidn ;

 b000_016_enc5:  lv4_enc5(0) <= not( lv3_enc5_b(0) and (lv3_enc5_b(1) or  lv4_inv(0))  );
 b001_016_enc5:  lv4_enc5(1) <= not( lv3_enc5_b(2) and (lv3_enc5_b(3) or  lv4_inv(1))  );
 b002_016_enc5:  lv4_enc5(2) <= not( lv3_enc5_b(4) and (lv3_enc5_b(5) or  lv4_inv(2))  );
 b003_016_enc5:  lv4_enc5(3) <= not( lv3_enc5_b(6) and (lv3_enc5_b(7) or  lv4_inv(3))  );
 b004_016_enc5:  lv4_enc5(4) <= not( lv3_enc5_b(8) and (lv3_enc5_b(9) or  lv4_inv(4))  );
 b005_016_enc5:  lv4_enc5(5) <= not( lv3_enc5_b(10) and (lv3_enc5_b(11) or  lv4_inv(5))  );
 b006_016_enc5:  lv4_enc5(6) <= not( lv3_enc5_b(12) and (lv3_enc5_b(13) or  lv4_inv(6))  );
 b007_016_enc5:  lv4_enc5(7) <= not( lv3_enc5_b(14) and (lv3_enc5_b(15) or  lv4_inv(7))  );
 b008_016_enc5:  lv4_enc5(8) <= not( lv3_enc5_b(16) and (lv3_enc5_b(17) or  lv4_inv(8))  );
 b009_016_enc5:  lv4_enc5(9) <= not( lv3_enc5_b(18) and (lv3_enc5_b(19) or  lv4_inv(9))  );
 b010_016_enc5:  lv4_enc5(10) <= not( lv3_enc5_b(20) );
 

 b000_016_enc6:  lv4_enc6(0) <= not( lv3_enc6_b(0) and (lv3_enc6_b(1) or  lv4_inv(0))  );
 b001_016_enc6:  lv4_enc6(1) <= not( lv3_enc6_b(2) and (lv3_enc6_b(3) or  lv4_inv(1))  );
 b002_016_enc6:  lv4_enc6(2) <= not( lv3_enc6_b(4) and (lv3_enc6_b(5) or  lv4_inv(2))  );
 b003_016_enc6:  lv4_enc6(3) <= not( lv3_enc6_b(6) and (lv3_enc6_b(7) or  lv4_inv(3))  );
 b004_016_enc6:  lv4_enc6(4) <= not( lv3_enc6_b(8) and (lv3_enc6_b(9) or  lv4_inv(4))  );
 b005_016_enc6:  lv4_enc6(5) <= not( lv3_enc6_b(10) and (lv3_enc6_b(11) or  lv4_inv(5))  );
 b006_016_enc6:  lv4_enc6(6) <= not( lv3_enc6_b(12) and (lv3_enc6_b(13) or  lv4_inv(6))  );
 b007_016_enc6:  lv4_enc6(7) <= not( lv3_enc6_b(14) and (lv3_enc6_b(15) or  lv4_inv(7))  );
 b008_016_enc6:  lv4_enc6(8) <= not( lv3_enc6_b(16) and (lv3_enc6_b(17) or  lv4_inv(8))  );
 b009_016_enc6:  lv4_enc6(9) <= not( lv3_enc6_b(18) and (lv3_enc6_b(19) or  lv4_inv(9))  );
 b010_016_enc6:  lv4_enc6(10) <= not( lv3_enc6_b(20) and  lv4_inv(10)  );

 b000_016_enc7:  lv4_enc7(0) <= not( lv3_enc7_b(0) and (lv3_enc7_b(1) or  lv4_inv(0))  );
 b001_016_enc7:  lv4_enc7(1) <= not( lv3_enc7_b(2) and (lv3_enc7_b(3) or  lv4_inv(1))  );
 b002_016_enc7:  lv4_enc7(2) <= not( lv3_enc7_b(4) and (lv3_enc7_b(5) or  lv4_inv(2))  );
 b003_016_enc7:  lv4_enc7(3) <= not( lv3_enc7_b(6) and (lv3_enc7_b(7) or  lv4_inv(3))  );
 b004_016_enc7:  lv4_enc7(4) <= not( lv3_enc7_b(8) and (lv3_enc7_b(9) or  lv4_inv(4))  );
 b005_016_enc7:  lv4_enc7(5) <= not( lv3_enc7_b(10) and (lv3_enc7_b(11) or  lv4_inv(5))  );
 b006_016_enc7:  lv4_enc7(6) <= not( lv3_enc7_b(12) and (lv3_enc7_b(13) or  lv4_inv(6))  );
 b007_016_enc7:  lv4_enc7(7) <= not( lv3_enc7_b(14) and (lv3_enc7_b(15) or  lv4_inv(7))  );
 b008_016_enc7:  lv4_enc7(8) <= not( lv3_enc7_b(16) and (lv3_enc7_b(17) or  lv4_inv(8))  );
 b009_016_enc7:  lv4_enc7(9) <= not( lv3_enc7_b(18) and (lv3_enc7_b(19) or  lv4_inv(9))  );
 b010_016_enc7:  lv4_enc7(10) <= not( lv3_enc7_b(20) and  lv4_inv(10)  );


 r000_004_or:      lv4_or_b(0)      <= not( lv4_or(0)         );
 r001_004_or:      lv4_or_b(1)      <= not( lv4_or(1)         );
 r002_004_or:      lv4_or_b(2)      <= not( lv4_or(2)         );
 r003_004_or:      lv4_or_b(3)      <= not( lv4_or(3)         );
 r004_004_or:      lv4_or_b(4)      <= not( lv4_or(4)         );
 r005_004_or:      lv4_or_b(5)      <= not( lv4_or(5)         );
 r006_004_or:      lv4_or_b(6)      <= not( lv4_or(6)         );
 r007_004_or:      lv4_or_b(7)      <= not( lv4_or(7)         );
 r008_004_or:      lv4_or_b(8)      <= not( lv4_or(8)         );
 r009_004_or:      lv4_or_b(9)      <= not( lv4_or(9)         );
 r010_004_or:      lv4_or_b(10)     <= not( lv4_or(10)        );
 r000_004_enc4:    lv4_enc4_b(0)    <= not( lv4_enc4(0)       );
 r001_004_enc4:    lv4_enc4_b(1)    <= not( lv4_enc4(1)       );
 r002_004_enc4:    lv4_enc4_b(2)    <= not( lv4_enc4(2)       );
 r003_004_enc4:    lv4_enc4_b(3)    <= not( lv4_enc4(3)       );
 r004_004_enc4:    lv4_enc4_b(4)    <= not( lv4_enc4(4)       );
 r005_004_enc4:    lv4_enc4_b(5)    <= not( lv4_enc4(5)       );
 r006_004_enc4:    lv4_enc4_b(6)    <= not( lv4_enc4(6)       );
 r007_004_enc4:    lv4_enc4_b(7)    <= not( lv4_enc4(7)       );
 r008_004_enc4:    lv4_enc4_b(8)    <= not( lv4_enc4(8)       );
 r009_004_enc4:    lv4_enc4_b(9)    <= not( lv4_enc4(9)       );
 r010_004_enc4:    lv4_enc4_b(10)   <= not( lv4_enc4(10)      );
 r000_004_enc5:    lv4_enc5_b(0)    <= not( lv4_enc5(0)       );
 r001_004_enc5:    lv4_enc5_b(1)    <= not( lv4_enc5(1)       );
 r002_004_enc5:    lv4_enc5_b(2)    <= not( lv4_enc5(2)       );
 r003_004_enc5:    lv4_enc5_b(3)    <= not( lv4_enc5(3)       );
 r004_004_enc5:    lv4_enc5_b(4)    <= not( lv4_enc5(4)       );
 r005_004_enc5:    lv4_enc5_b(5)    <= not( lv4_enc5(5)       );
 r006_004_enc5:    lv4_enc5_b(6)    <= not( lv4_enc5(6)       );
 r007_004_enc5:    lv4_enc5_b(7)    <= not( lv4_enc5(7)       );
 r008_004_enc5:    lv4_enc5_b(8)    <= not( lv4_enc5(8)       );
 r009_004_enc5:    lv4_enc5_b(9)    <= not( lv4_enc5(9)       );
 r010_004_enc5:    lv4_enc5_b(10)   <= not( lv4_enc5(10)      );
 r000_004_enc6:    lv4_enc6_b(0)    <= not( lv4_enc6(0)       );
 r001_004_enc6:    lv4_enc6_b(1)    <= not( lv4_enc6(1)       );
 r002_004_enc6:    lv4_enc6_b(2)    <= not( lv4_enc6(2)       );
 r003_004_enc6:    lv4_enc6_b(3)    <= not( lv4_enc6(3)       );
 r004_004_enc6:    lv4_enc6_b(4)    <= not( lv4_enc6(4)       );
 r005_004_enc6:    lv4_enc6_b(5)    <= not( lv4_enc6(5)       );
 r006_004_enc6:    lv4_enc6_b(6)    <= not( lv4_enc6(6)       );
 r007_004_enc6:    lv4_enc6_b(7)    <= not( lv4_enc6(7)       );
 r008_004_enc6:    lv4_enc6_b(8)    <= not( lv4_enc6(8)       );
 r009_004_enc6:    lv4_enc6_b(9)    <= not( lv4_enc6(9)       );
 r010_004_enc6:    lv4_enc6_b(10)   <= not( lv4_enc6(10)      );
 r000_004_enc7:    lv4_enc7_b(0)    <= not( lv4_enc7(0)       );
 r001_004_enc7:    lv4_enc7_b(1)    <= not( lv4_enc7(1)       );
 r002_004_enc7:    lv4_enc7_b(2)    <= not( lv4_enc7(2)       );
 r003_004_enc7:    lv4_enc7_b(3)    <= not( lv4_enc7(3)       );
 r004_004_enc7:    lv4_enc7_b(4)    <= not( lv4_enc7(4)       );
 r005_004_enc7:    lv4_enc7_b(5)    <= not( lv4_enc7(5)       );
 r006_004_enc7:    lv4_enc7_b(6)    <= not( lv4_enc7(6)       );
 r007_004_enc7:    lv4_enc7_b(7)    <= not( lv4_enc7(7)       );
 r008_004_enc7:    lv4_enc7_b(8)    <= not( lv4_enc7(8)       );
 r009_004_enc7:    lv4_enc7_b(9)    <= not( lv4_enc7(9)       );
 r010_004_enc7:    lv4_enc7_b(10)   <= not( lv4_enc7(10)      );



 b000_032_any:  lv5_or(0) <= not( lv4_or_b(0) and lv4_or_b(1) );
 b001_032_any:  lv5_or(1) <= not( lv4_or_b(2) and lv4_or_b(3) );
 b002_032_any:  lv5_or(2) <= not( lv4_or_b(4) and lv4_or_b(5) );
 b003_032_any:  lv5_or(3) <= not( lv4_or_b(6) and lv4_or_b(7) );
 b004_032_any:  lv5_or(4) <= not( lv4_or_b(8) and lv4_or_b(9) );
 b005_032_any:  lv5_or(5) <= not( lv4_or_b(10) );

 b000_032_inv:  lv5_inv(0) <= not( lv4_or_b(0) );
 b001_032_inv:  lv5_inv(1) <= not( lv4_or_b(2) );
 b002_032_inv:  lv5_inv(2) <= not( lv4_or_b(4) );
 b003_032_inv:  lv5_inv(3) <= not( lv4_or_b(6) );
 b004_032_inv:  lv5_inv(4) <= not( lv4_or_b(8) );
 b005_032_inv:  lv5_inv(5) <= not( lv4_or_b(10) );

 b000_032_enc3:  lv5_enc3(0) <= not( lv5_inv(0) or  lv4_or_b(1) );
 b001_032_enc3:  lv5_enc3(1) <= not( lv5_inv(1) or  lv4_or_b(3) );
 b002_032_enc3:  lv5_enc3(2) <= not( lv5_inv(2) or  lv4_or_b(5) );
 b003_032_enc3:  lv5_enc3(3) <= not( lv5_inv(3) or  lv4_or_b(7) );
 b004_032_enc3:  lv5_enc3(4) <= not( lv5_inv(4) or  lv4_or_b(9) );
               lv5_enc3(5) <= tidn ;

 b000_032_enc4:  lv5_enc4(0) <= not( lv4_enc4_b(0) and (lv4_enc4_b(1) or  lv5_inv(0))  );
 b001_032_enc4:  lv5_enc4(1) <= not( lv4_enc4_b(2) and (lv4_enc4_b(3) or  lv5_inv(1))  );
 b002_032_enc4:  lv5_enc4(2) <= not( lv4_enc4_b(4) and (lv4_enc4_b(5) or  lv5_inv(2))  );
 b003_032_enc4:  lv5_enc4(3) <= not( lv4_enc4_b(6) and (lv4_enc4_b(7) or  lv5_inv(3))  );
 b004_032_enc4:  lv5_enc4(4) <= not( lv4_enc4_b(8) and (lv4_enc4_b(9) or  lv5_inv(4))  );
 b005_032_enc4:  lv5_enc4(5) <= not( lv4_enc4_b(10) );

 b000_032_enc5:  lv5_enc5(0) <= not( lv4_enc5_b(0) and (lv4_enc5_b(1) or  lv5_inv(0))  );
 b001_032_enc5:  lv5_enc5(1) <= not( lv4_enc5_b(2) and (lv4_enc5_b(3) or  lv5_inv(1))  );
 b002_032_enc5:  lv5_enc5(2) <= not( lv4_enc5_b(4) and (lv4_enc5_b(5) or  lv5_inv(2))  );
 b003_032_enc5:  lv5_enc5(3) <= not( lv4_enc5_b(6) and (lv4_enc5_b(7) or  lv5_inv(3))  );
 b004_032_enc5:  lv5_enc5(4) <= not( lv4_enc5_b(8) and (lv4_enc5_b(9) or  lv5_inv(4))  );
 b005_032_enc5:  lv5_enc5(5) <= not( lv4_enc5_b(10) );

 b000_032_enc6:  lv5_enc6(0) <= not( lv4_enc6_b(0) and (lv4_enc6_b(1) or  lv5_inv(0))  );
 b001_032_enc6:  lv5_enc6(1) <= not( lv4_enc6_b(2) and (lv4_enc6_b(3) or  lv5_inv(1))  );
 b002_032_enc6:  lv5_enc6(2) <= not( lv4_enc6_b(4) and (lv4_enc6_b(5) or  lv5_inv(2))  );
 b003_032_enc6:  lv5_enc6(3) <= not( lv4_enc6_b(6) and (lv4_enc6_b(7) or  lv5_inv(3))  );
 b004_032_enc6:  lv5_enc6(4) <= not( lv4_enc6_b(8) and (lv4_enc6_b(9) or  lv5_inv(4))  );
 b005_032_enc6:  lv5_enc6(5) <= not( lv4_enc6_b(10) and  lv5_inv(5)  );

 b000_032_enc7:  lv5_enc7(0) <= not( lv4_enc7_b(0) and (lv4_enc7_b(1) or  lv5_inv(0))  );
 b001_032_enc7:  lv5_enc7(1) <= not( lv4_enc7_b(2) and (lv4_enc7_b(3) or  lv5_inv(1))  );
 b002_032_enc7:  lv5_enc7(2) <= not( lv4_enc7_b(4) and (lv4_enc7_b(5) or  lv5_inv(2))  );
 b003_032_enc7:  lv5_enc7(3) <= not( lv4_enc7_b(6) and (lv4_enc7_b(7) or  lv5_inv(3))  );
 b004_032_enc7:  lv5_enc7(4) <= not( lv4_enc7_b(8) and (lv4_enc7_b(9) or  lv5_inv(4))  );
 b005_032_enc7:  lv5_enc7(5) <= not( lv4_enc7_b(10) and  lv5_inv(5)  );



 lv6_or_0 <= not lv6_or_b(0) ;
 lv6_or_1 <= not lv6_or_b(1) ;


 b000_064_any:  lv6_or_b(0) <= not( lv5_or(0) or  lv5_or(1) );
 b001_064_any:  lv6_or_b(1) <= not( lv5_or(2) or  lv5_or(3) );
 b002_064_any:  lv6_or_b(2) <= not( lv5_or(4) or  lv5_or(5) );

 b000_064_inv:  lv6_inv_b(0) <= not( lv5_or(0) );
 b001_064_inv:  lv6_inv_b(1) <= not( lv5_or(2) );
 b002_064_inv:  lv6_inv_b(2) <= not( lv5_or(4) );

 b000_064_enc2:  lv6_enc2_b(0) <= not( lv6_inv_b(0) and lv5_or(1) );
 b001_064_enc2:  lv6_enc2_b(1) <= not( lv6_inv_b(1) and lv5_or(3) );
 b002_064_enc2:  lv6_enc2_b(2) <= not( lv6_inv_b(2) );

 b000_064_enc3:  lv6_enc3_b(0) <= not( lv5_enc3(0) or  (lv5_enc3(1) and lv6_inv_b(0))  );
 b001_064_enc3:  lv6_enc3_b(1) <= not( lv5_enc3(2) or  (lv5_enc3(3) and lv6_inv_b(1))  );
 b002_064_enc3:  lv6_enc3_b(2) <= not( lv5_enc3(4) or  (lv5_enc3(5) and lv6_inv_b(2))  );

 b000_064_enc4:  lv6_enc4_b(0) <= not( lv5_enc4(0) or  (lv5_enc4(1) and lv6_inv_b(0))  );
 b001_064_enc4:  lv6_enc4_b(1) <= not( lv5_enc4(2) or  (lv5_enc4(3) and lv6_inv_b(1))  );
 b002_064_enc4:  lv6_enc4_b(2) <= not( lv5_enc4(4) or  (lv5_enc4(5) and lv6_inv_b(2))  );

 b000_064_enc5:  lv6_enc5_b(0) <= not( lv5_enc5(0) or  (lv5_enc5(1) and lv6_inv_b(0))  );
 b001_064_enc5:  lv6_enc5_b(1) <= not( lv5_enc5(2) or  (lv5_enc5(3) and lv6_inv_b(1))  );
 b002_064_enc5:  lv6_enc5_b(2) <= not( lv5_enc5(4) or  (lv5_enc5(5) and lv6_inv_b(2))  );

 b000_064_enc6:  lv6_enc6_b(0) <= not( lv5_enc6(0) or  (lv5_enc6(1) and lv6_inv_b(0))  );
 b001_064_enc6:  lv6_enc6_b(1) <= not( lv5_enc6(2) or  (lv5_enc6(3) and lv6_inv_b(1))  );
 b002_064_enc6:  lv6_enc6_b(2) <= not( lv5_enc6(4) or  (lv5_enc6(5) and lv6_inv_b(2))  );

 b000_064_enc7:  lv6_enc7_b(0) <= not( lv5_enc7(0) or  (lv5_enc7(1) and lv6_inv_b(0))  );
 b001_064_enc7:  lv6_enc7_b(1) <= not( lv5_enc7(2) or  (lv5_enc7(3) and lv6_inv_b(1))  );
 b002_064_enc7:  lv6_enc7_b(2) <= not( lv5_enc7(4) or  (lv5_enc7(5) and lv6_inv_b(2))  );



 b000_128_any:  lv7_or(0) <= not( lv6_or_b(0) and lv6_or_b(1) );
 b001_128_any:  lv7_or(1) <= not( lv6_or_b(2) );

 b000_128_inv:  lv7_inv(0) <= not( lv6_or_b(0) );
 b001_128_inv:  lv7_inv(1) <= not( lv6_or_b(2) );

 b000_128_enc1:  lv7_enc1(0) <= not( lv7_inv(0) or  lv6_or_b(1) );
               lv7_enc1(1) <= tidn ;

 b000_128_enc2:  lv7_enc2(0) <= not( lv6_enc2_b(0) and (lv6_enc2_b(1) or  lv7_inv(0))  );
 b001_128_enc2:  lv7_enc2(1) <= not( lv6_enc2_b(2) and  lv7_inv(1)  );

 b000_128_enc3:  lv7_enc3(0) <= not( lv6_enc3_b(0) and (lv6_enc3_b(1) or  lv7_inv(0))  );
 b001_128_enc3:  lv7_enc3(1) <= not( lv6_enc3_b(2) );

 b000_128_enc4:  lv7_enc4(0) <= not( lv6_enc4_b(0) and (lv6_enc4_b(1) or  lv7_inv(0))  );
 b001_128_enc4:  lv7_enc4(1) <= not( lv6_enc4_b(2) );

 b000_128_enc5:  lv7_enc5(0) <= not( lv6_enc5_b(0) and (lv6_enc5_b(1) or  lv7_inv(0))  );
 b001_128_enc5:  lv7_enc5(1) <= not( lv6_enc5_b(2) );

 b000_128_enc6:  lv7_enc6(0) <= not( lv6_enc6_b(0) and (lv6_enc6_b(1) or  lv7_inv(0))  );
 b001_128_enc6:  lv7_enc6(1) <= not( lv6_enc6_b(2) and  lv7_inv(1)  );

 b000_128_enc7:  lv7_enc7(0) <= not( lv6_enc7_b(0) and (lv6_enc7_b(1) or  lv7_inv(0))  );
 b001_128_enc7:  lv7_enc7(1) <= not( lv6_enc7_b(2) and  lv7_inv(1)  );



 b000_256_any:  lv8_or_b(0) <= not( lv7_or(0) or  lv7_or(1) );

 b000_256_inv:  lv8_inv_b(0) <= not( lv7_or(0) );

 b000_256_enc0:  lv8_enc0_b(0) <= not( lv8_inv_b(0) );

 b000_256_enc1:  lv8_enc1_b(0) <= not( lv7_enc1(0) or  (lv7_enc1(1) and lv8_inv_b(0))  );

 b000_256_enc2:  lv8_enc2_b(0) <= not( lv7_enc2(0) or  (lv7_enc2(1) and lv8_inv_b(0))  );

 b000_256_enc3:  lv8_enc3_b(0) <= not( lv7_enc3(0) or  (lv7_enc3(1) and lv8_inv_b(0))  );

 b000_256_enc4:  lv8_enc4_b(0) <= not( lv7_enc4(0) or  (lv7_enc4(1) and lv8_inv_b(0))  );

 b000_256_enc5:  lv8_enc5_b(0) <= not( lv7_enc5(0) or  (lv7_enc5(1) and lv8_inv_b(0))  );

 b000_256_enc6:  lv8_enc6_b(0) <= not( lv7_enc6(0) or  (lv7_enc6(1) and lv8_inv_b(0))  );

 b000_256_enc7:  lv8_enc7_b(0) <= not( lv7_enc7(0) or  (lv7_enc7(1) and lv8_inv_b(0))  );


 o_any:            lza_any_b          <=    ( lv8_or_b(0)       );
 o_enc0:           lza_amt_b(0)       <=    ( lv8_enc0_b(0)     );
 o_enc1:           lza_amt_b(1)       <=    ( lv8_enc1_b(0)     );
 o_enc2:           lza_amt_b(2)       <=    ( lv8_enc2_b(0)     );
 o_enc3:           lza_amt_b(3)       <=    ( lv8_enc3_b(0)     );
 o_enc4:           lza_amt_b(4)       <=    ( lv8_enc4_b(0)     );
 o_enc5:           lza_amt_b(5)       <=    ( lv8_enc5_b(0)     );
 o_enc6:           lza_amt_b(6)       <=    ( lv8_enc6_b(0)     );
 o_enc7:           lza_amt_b(7)       <=    ( lv8_enc7_b(0)     );








END; 
