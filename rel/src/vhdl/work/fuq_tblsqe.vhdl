-- © IBM Corp. 2020
-- Licensed under the Apache License, Version 2.0 (the "License"), as modified by
-- the terms below; you may not use the files in this repository except in
-- compliance with the License as modified.
-- You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0
--
-- Modified Terms:
--
--    1) For the purpose of the patent license granted to you in Section 3 of the
--    License, the "Work" hereby includes implementations of the work of authorship
--    in physical form.
--
--    2) Notwithstanding any terms to the contrary in the License, any licenses
--    necessary for implementation of the Work that are available from OpenPOWER
--    via the Power ISA End User License Agreement (EULA) are explicitly excluded
--    hereunder, and may be obtained from OpenPOWER under the terms and conditions
--    of the EULA.  
--
-- Unless required by applicable law or agreed to in writing, the reference design
-- distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
-- WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License
-- for the specific language governing permissions and limitations under the License.
-- 
-- Additional rights, including the ability to physically implement a softcore that
-- is compliant with the required sections of the Power ISA Specification, are
-- available at no cost under the terms of the OpenPOWER Power ISA EULA, which can be
-- obtained (along with the Power ISA) here: https://openpowerfoundation.org. 

 
library ieee; 
  use ieee.std_logic_1164.all ; 
library ibm; 
  use ibm.std_ulogic_support.all; 
  use ibm.std_ulogic_function_support.all; 
  use ibm.std_ulogic_ao_support.all; 
  use ibm.std_ulogic_mux_support.all; 

-- 01101010000001011111 010110010111010 0
-- 01100111001110100011 010101110110100 1
-- 01100100011111101101 010101010111010 2
-- 01100001110100110011 010100111001000 3
-- 01011111001101101011 010100011011110 4
-- 01011100101010001011 010011111111100 5
-- 01011010001010001101 010011100100100 6
-- 01010111101101101001 010011001010010 7
-- 01010101010100010101 010010110001000 8
-- 01010010111110001101 010010011000100 9
-- 01010000101011000111 010010000001000 10
-- 01001110011010111101 010001101010010 11
-- 01001100001101101011 010001010100000 12
-- 01001010000011001011 010000111110110 13
-- 01000111111011010101 010000101010000 14
-- 01000101110110000011 010000010110000 15
-- 01000011110011010011 010000000010100 16
-- 01000001110010111111 001111101111110 17
-- 00111111110101000001 001111011101010 18
-- 00111101111001010101 001111001011110 19
-- 00111011111111110111 001110111010100 20
-- 00111010001000100001 001110101001110 21
-- 00111000010011010011 001110011001100 22
-- 00110110100000000101 001110001001110 23
-- 00110100101110110111 001101111010100 24
-- 00110010111111100001 001101101011100 25
-- 00110001010010000011 001101011101000 26
-- 00101111100110011001 001101001111000 27
-- 00101101111100100001 001101000001010 28
-- 00101100010100010101 001100110100000 29
-- 00101010101101110101 001100100111000 30
-- 00101001001000111011 001100011010010 31
-- 00100111100101100111 001100001110000 32
-- 00100110000011110101 001100000010000 33
-- 00100100100011100101 001011110110010 34
-- 00100011000100110001 001011101011000 35
-- 00100001100111011001 001011011111110 36
-- 00100000001011011001 001011010101000 37
-- 00011110110000110001 001011001010100 38
-- 00011101010111011101 001011000000000 39
-- 00011011111111011011 001010110110000 40
-- 00011010101000101001 001010101100000 41
-- 00011001010011000111 001010100010100 42
-- 00010111111110110011 001010011001000 43
-- 00010110101011101001 001010010000000 44
-- 00010101011001101001 001010000111000 45
-- 00010100001000101111 001001111110010 46
-- 00010010111000111101 001001110101110 47
-- 00010001101010001111 001001101101010 48
-- 00010000011100100011 001001100101000 49
-- 00001111001111111011 001001011101000 50
-- 00001110000100010001 001001010101010 51
-- 00001100111001100111 001001001101100 52
-- 00001011101111111001 001001000110000 53
-- 00001010100111000111 001000111110110 54
-- 00001001011111010001 001000110111100 55
-- 00001000011000010101 001000110000100 56
-- 00000111010010010001 001000101001100 57
-- 00000110001101000011 001000100010110 58
-- 00000101001000101101 001000011100000 59
-- 00000100000101001011 001000010101100 60
-- 00000011000010011101 001000001111010 61
-- 00000010000000100001 001000001001000 62
-- 00000000111111011001 001000000011000 63

 
entity fuq_tblsqe is
generic(   expand_type               : integer := 2  ); -- 0 - ibm tech, 1 - other );
port( 
       f    :in   std_ulogic_vector(1 to 6);
       est  :out  std_ulogic_vector(1 to 20);
       rng  :out  std_ulogic_vector(6 to 20)
       
); -- end ports
 
 
 
end fuq_tblsqe; -- ENTITY
 
 
architecture fuq_tblsqe of fuq_tblsqe is 
 
  constant tiup  :std_ulogic := '1';
  constant tidn  :std_ulogic := '0';

  signal dcd_00x :std_ulogic; 
  signal dcd_01x :std_ulogic; 
  signal dcd_10x :std_ulogic; 
  signal dcd_11x :std_ulogic; 
  signal dcd_000 :std_ulogic; 
  signal dcd_001 :std_ulogic; 
  signal dcd_010 :std_ulogic; 
  signal dcd_011 :std_ulogic; 
  signal dcd_100 :std_ulogic; 
  signal dcd_101 :std_ulogic; 
  signal dcd_110 :std_ulogic; 
  signal dcd_111 :std_ulogic; 
  signal combo2_1000 :std_ulogic; 
  signal combo2_0100 :std_ulogic; 
  signal combo2_1100 :std_ulogic; 
  signal combo2_0010 :std_ulogic; 
  signal combo2_1010 :std_ulogic; 
  signal combo2_0110 :std_ulogic; 
  signal combo2_1110 :std_ulogic; 
  signal combo2_0001 :std_ulogic; 
  signal combo2_1001 :std_ulogic; 
  signal combo2_0101 :std_ulogic; 
  signal combo2_1101 :std_ulogic; 
  signal combo2_0011 :std_ulogic; 
  signal combo2_1011 :std_ulogic; 
  signal combo2_0111 :std_ulogic; 
  signal combo2_1000_xxxx_b :std_ulogic; 
  signal combo2_0100_xxxx_b :std_ulogic; 
  signal combo2_1100_xxxx_b :std_ulogic; 
  signal combo2_0010_xxxx_b :std_ulogic; 
  signal combo2_1010_xxxx_b :std_ulogic; 
  signal combo2_0110_xxxx_b :std_ulogic; 
  signal combo2_1110_xxxx_b :std_ulogic; 
  signal combo2_0001_xxxx_b :std_ulogic; 
  signal combo2_1001_xxxx_b :std_ulogic; 
  signal combo2_0101_xxxx_b :std_ulogic; 
  signal combo2_1101_xxxx_b :std_ulogic; 
  signal combo2_0011_xxxx_b :std_ulogic; 
  signal combo2_1011_xxxx_b :std_ulogic; 
  signal combo2_0111_xxxx_b :std_ulogic; 
  signal combo2_xxxx_1000_b :std_ulogic; 
  signal combo2_xxxx_0100_b :std_ulogic; 
  signal combo2_xxxx_1100_b :std_ulogic; 
  signal combo2_xxxx_0010_b :std_ulogic; 
  signal combo2_xxxx_1010_b :std_ulogic; 
  signal combo2_xxxx_0110_b :std_ulogic; 
  signal combo2_xxxx_1110_b :std_ulogic; 
  signal combo2_xxxx_0001_b :std_ulogic; 
  signal combo2_xxxx_1001_b :std_ulogic; 
  signal combo2_xxxx_0101_b :std_ulogic; 
  signal combo2_xxxx_1101_b :std_ulogic; 
  signal combo2_xxxx_0011_b :std_ulogic; 
  signal combo2_xxxx_1011_b :std_ulogic; 
  signal combo2_xxxx_0111_b :std_ulogic; 
  signal combo3_0000_0001 :std_ulogic; 
  signal combo3_0000_0011 :std_ulogic; 
  signal combo3_0000_0100 :std_ulogic; 
  signal combo3_0000_0111 :std_ulogic; 
  signal combo3_0000_1001 :std_ulogic; 
  signal combo3_0000_1010 :std_ulogic; 
  signal combo3_0000_1011 :std_ulogic; 
  signal combo3_0000_1101 :std_ulogic; 
  signal combo3_0000_1111 :std_ulogic; 
  signal combo3_0001_0001 :std_ulogic; 
  signal combo3_0001_0010 :std_ulogic; 
  signal combo3_0001_0100 :std_ulogic; 
  signal combo3_0001_0101 :std_ulogic; 
  signal combo3_0001_0111 :std_ulogic; 
  signal combo3_0001_1000 :std_ulogic; 
  signal combo3_0001_1100 :std_ulogic; 
  signal combo3_0001_1101 :std_ulogic; 
  signal combo3_0001_1110 :std_ulogic; 
  signal combo3_0001_1111 :std_ulogic; 
  signal combo3_0010_0001 :std_ulogic; 
  signal combo3_0010_0011 :std_ulogic; 
  signal combo3_0010_0100 :std_ulogic; 
  signal combo3_0010_0101 :std_ulogic; 
  signal combo3_0010_1000 :std_ulogic; 
  signal combo3_0010_1001 :std_ulogic; 
  signal combo3_0010_1010 :std_ulogic; 
  signal combo3_0010_1100 :std_ulogic; 
  signal combo3_0010_1101 :std_ulogic; 
  signal combo3_0010_1110 :std_ulogic; 
  signal combo3_0010_1111 :std_ulogic; 
  signal combo3_0011_0000 :std_ulogic; 
  signal combo3_0011_0001 :std_ulogic; 
  signal combo3_0011_0011 :std_ulogic; 
  signal combo3_0011_0101 :std_ulogic; 
  signal combo3_0011_0110 :std_ulogic; 
  signal combo3_0011_1000 :std_ulogic; 
  signal combo3_0011_1001 :std_ulogic; 
  signal combo3_0011_1110 :std_ulogic; 
  signal combo3_0011_1111 :std_ulogic; 
  signal combo3_0100_0000 :std_ulogic; 
  signal combo3_0100_0010 :std_ulogic; 
  signal combo3_0100_0100 :std_ulogic; 
  signal combo3_0100_0101 :std_ulogic; 
  signal combo3_0100_1001 :std_ulogic; 
  signal combo3_0100_1100 :std_ulogic; 
  signal combo3_0100_1110 :std_ulogic; 
  signal combo3_0100_1111 :std_ulogic; 
  signal combo3_0101_0010 :std_ulogic; 
  signal combo3_0101_0100 :std_ulogic; 
  signal combo3_0101_0110 :std_ulogic; 
  signal combo3_0101_1001 :std_ulogic; 
  signal combo3_0101_1100 :std_ulogic; 
  signal combo3_0101_1111 :std_ulogic; 
  signal combo3_0110_0000 :std_ulogic; 
  signal combo3_0110_0011 :std_ulogic; 
  signal combo3_0110_0110 :std_ulogic; 
  signal combo3_0110_0111 :std_ulogic; 
  signal combo3_0110_1100 :std_ulogic; 
  signal combo3_0110_1101 :std_ulogic; 
  signal combo3_0110_1111 :std_ulogic; 
  signal combo3_0111_0000 :std_ulogic; 
  signal combo3_0111_0101 :std_ulogic; 
  signal combo3_0111_0111 :std_ulogic; 
  signal combo3_0111_1000 :std_ulogic; 
  signal combo3_0111_1001 :std_ulogic; 
  signal combo3_0111_1010 :std_ulogic; 
  signal combo3_0111_1111 :std_ulogic; 
  signal combo3_1000_0000 :std_ulogic; 
  signal combo3_1000_0011 :std_ulogic; 
  signal combo3_1000_0110 :std_ulogic; 
  signal combo3_1000_0111 :std_ulogic; 
  signal combo3_1000_1010 :std_ulogic; 
  signal combo3_1000_1110 :std_ulogic; 
  signal combo3_1001_0000 :std_ulogic; 
  signal combo3_1001_0001 :std_ulogic; 
  signal combo3_1001_0010 :std_ulogic; 
  signal combo3_1001_0100 :std_ulogic; 
  signal combo3_1001_0110 :std_ulogic; 
  signal combo3_1001_0111 :std_ulogic; 
  signal combo3_1001_1000 :std_ulogic; 
  signal combo3_1001_1001 :std_ulogic; 
  signal combo3_1001_1010 :std_ulogic; 
  signal combo3_1001_1011 :std_ulogic; 
  signal combo3_1001_1100 :std_ulogic; 
  signal combo3_1010_0000 :std_ulogic; 
  signal combo3_1010_0001 :std_ulogic; 
  signal combo3_1010_0010 :std_ulogic; 
  signal combo3_1010_0100 :std_ulogic; 
  signal combo3_1010_0101 :std_ulogic; 
  signal combo3_1010_0110 :std_ulogic; 
  signal combo3_1010_0111 :std_ulogic; 
  signal combo3_1010_1001 :std_ulogic; 
  signal combo3_1010_1010 :std_ulogic; 
  signal combo3_1010_1100 :std_ulogic; 
  signal combo3_1010_1101 :std_ulogic; 
  signal combo3_1010_1111 :std_ulogic; 
  signal combo3_1011_0001 :std_ulogic; 
  signal combo3_1011_0010 :std_ulogic; 
  signal combo3_1011_0100 :std_ulogic; 
  signal combo3_1011_0101 :std_ulogic; 
  signal combo3_1011_1000 :std_ulogic; 
  signal combo3_1011_1010 :std_ulogic; 
  signal combo3_1011_1100 :std_ulogic; 
  signal combo3_1100_0000 :std_ulogic; 
  signal combo3_1100_0001 :std_ulogic; 
  signal combo3_1100_0011 :std_ulogic; 
  signal combo3_1100_0101 :std_ulogic; 
  signal combo3_1100_0110 :std_ulogic; 
  signal combo3_1100_0111 :std_ulogic; 
  signal combo3_1100_1001 :std_ulogic; 
  signal combo3_1100_1010 :std_ulogic; 
  signal combo3_1100_1011 :std_ulogic; 
  signal combo3_1100_1101 :std_ulogic; 
  signal combo3_1100_1111 :std_ulogic; 
  signal combo3_1101_0010 :std_ulogic; 
  signal combo3_1101_0011 :std_ulogic; 
  signal combo3_1101_1000 :std_ulogic; 
  signal combo3_1101_1001 :std_ulogic; 
  signal combo3_1101_1010 :std_ulogic; 
  signal combo3_1101_1100 :std_ulogic; 
  signal combo3_1101_1110 :std_ulogic; 
  signal combo3_1101_1111 :std_ulogic; 
  signal combo3_1110_0000 :std_ulogic; 
  signal combo3_1110_0001 :std_ulogic; 
  signal combo3_1110_0011 :std_ulogic; 
  signal combo3_1110_0110 :std_ulogic; 
  signal combo3_1110_1000 :std_ulogic; 
  signal combo3_1110_1010 :std_ulogic; 
  signal combo3_1110_1101 :std_ulogic; 
  signal combo3_1111_0000 :std_ulogic; 
  signal combo3_1111_0001 :std_ulogic; 
  signal combo3_1111_0010 :std_ulogic; 
  signal combo3_1111_1000 :std_ulogic; 
  signal combo3_1111_1001 :std_ulogic; 
  signal combo3_1111_1010 :std_ulogic; 
  signal combo3_1111_1100 :std_ulogic; 
  signal e_00_b :std_ulogic_vector(0 to 7); 
  signal e_01_b :std_ulogic_vector(0 to 7); 
  signal e_02_b :std_ulogic_vector(0 to 7); 
  signal e_03_b :std_ulogic_vector(0 to 7); 
  signal e_04_b :std_ulogic_vector(0 to 7); 
  signal e_05_b :std_ulogic_vector(0 to 7); 
  signal e_06_b :std_ulogic_vector(0 to 7); 
  signal e_07_b :std_ulogic_vector(0 to 7); 
  signal e_08_b :std_ulogic_vector(0 to 7); 
  signal e_09_b :std_ulogic_vector(0 to 7); 
  signal e_10_b :std_ulogic_vector(0 to 7); 
  signal e_11_b :std_ulogic_vector(0 to 7); 
  signal e_12_b :std_ulogic_vector(0 to 7); 
  signal e_13_b :std_ulogic_vector(0 to 7); 
  signal e_14_b :std_ulogic_vector(0 to 7); 
  signal e_15_b :std_ulogic_vector(0 to 7); 
  signal e_16_b :std_ulogic_vector(0 to 7); 
  signal e_17_b :std_ulogic_vector(0 to 7); 
  signal e_18_b :std_ulogic_vector(0 to 7); 
  signal e_19_b :std_ulogic_vector(0 to 7); 
  signal e :std_ulogic_vector(0 to 19); 
  signal r_00_b :std_ulogic_vector(0 to 7); 
  signal r_01_b :std_ulogic_vector(0 to 7); 
  signal r_02_b :std_ulogic_vector(0 to 7); 
  signal r_03_b :std_ulogic_vector(0 to 7); 
  signal r_04_b :std_ulogic_vector(0 to 7); 
  signal r_05_b :std_ulogic_vector(0 to 7); 
  signal r_06_b :std_ulogic_vector(0 to 7); 
  signal r_07_b :std_ulogic_vector(0 to 7); 
  signal r_08_b :std_ulogic_vector(0 to 7); 
  signal r_09_b :std_ulogic_vector(0 to 7); 
  signal r_10_b :std_ulogic_vector(0 to 7); 
  signal r_11_b :std_ulogic_vector(0 to 7); 
  signal r_12_b :std_ulogic_vector(0 to 7); 
  signal r_13_b :std_ulogic_vector(0 to 7); 
  signal r_14_b :std_ulogic_vector(0 to 7); 
  signal r :std_ulogic_vector(0 to 14); 


begin 


--//#######################################
--//## decode the upper 3 index bits
--//#######################################

   dcd_00x <= not f(1) and not f(2) ; 
   dcd_01x <= not f(1) and     f(2) ; 
   dcd_10x <=     f(1) and not f(2) ; 
   dcd_11x <=     f(1) and     f(2) ; 
   
   dcd_000 <= not f(3) and dcd_00x  ; 
   dcd_001 <=     f(3) and dcd_00x  ; 
   dcd_010 <= not f(3) and dcd_01x  ; 
   dcd_011 <=     f(3) and dcd_01x  ; 
   dcd_100 <= not f(3) and dcd_10x  ; 
   dcd_101 <=     f(3) and dcd_10x  ; 
   dcd_110 <= not f(3) and dcd_11x  ; 
   dcd_111 <=     f(3) and dcd_11x  ; 


--//#######################################
--//## combos based on lower 2 index bits
--//#######################################

    combo2_1000 <=       not f(5) and not f(6)   ;-- [0]
    combo2_0100 <=       not f(5) and     f(6)   ;-- [1]
    combo2_1100 <=       not f(5)                ;-- [0,1]
    combo2_0010 <=           f(5) and not f(6)   ;-- [2]
    combo2_1010 <=                    not f(6)   ;-- [0,2]
    combo2_0110 <=           f(5) xor     f(6)   ;-- [1,2]
    combo2_1110 <=  not(     f(5) and     f(6) ) ;-- [0,1,2]
    combo2_0001 <=           f(5) and     f(6)   ;-- [3]
    combo2_1001 <=  not(     f(5) xor     f(6) ) ;-- [0,3]
    combo2_0101 <=                        f(6)   ;-- [1,3]
    combo2_1101 <=  not(     f(5) and not f(6) ) ;-- [1,2,3]
    combo2_0011 <=           f(5)                ;-- [2,3]
    combo2_1011 <=  not( not f(5) and     f(6) ) ;-- [0,2,3]
    combo2_0111 <=  not( not f(5) and not f(6) ) ;-- [1,2,3]


--//#######################################
--//## combos based on lower 3 index bits
--//#######################################

    combo2_1000_xxxx_b <= not( not f(4) and combo2_1000 ); 
    combo2_0100_xxxx_b <= not( not f(4) and combo2_0100 ); 
    combo2_1100_xxxx_b <= not( not f(4) and combo2_1100 ); 
    combo2_0010_xxxx_b <= not( not f(4) and combo2_0010 ); 
    combo2_1010_xxxx_b <= not( not f(4) and combo2_1010 ); 
    combo2_0110_xxxx_b <= not( not f(4) and combo2_0110 ); 
    combo2_1110_xxxx_b <= not( not f(4) and combo2_1110 ); 
    combo2_0001_xxxx_b <= not( not f(4) and combo2_0001 ); 
    combo2_1001_xxxx_b <= not( not f(4) and combo2_1001 ); 
    combo2_0101_xxxx_b <= not( not f(4) and combo2_0101 ); 
    combo2_1101_xxxx_b <= not( not f(4) and combo2_1101 ); 
    combo2_0011_xxxx_b <= not( not f(4) and combo2_0011 ); 
    combo2_1011_xxxx_b <= not( not f(4) and combo2_1011 ); 
    combo2_0111_xxxx_b <= not( not f(4) and combo2_0111 ); 


    combo2_xxxx_1000_b <= not(     f(4) and combo2_1000 ); 
    combo2_xxxx_0100_b <= not(     f(4) and combo2_0100 ); 
    combo2_xxxx_1100_b <= not(     f(4) and combo2_1100 ); 
    combo2_xxxx_0010_b <= not(     f(4) and combo2_0010 ); 
    combo2_xxxx_1010_b <= not(     f(4) and combo2_1010 ); 
    combo2_xxxx_0110_b <= not(     f(4) and combo2_0110 ); 
    combo2_xxxx_1110_b <= not(     f(4) and combo2_1110 ); 
    combo2_xxxx_0001_b <= not(     f(4) and combo2_0001 ); 
    combo2_xxxx_1001_b <= not(     f(4) and combo2_1001 ); 
    combo2_xxxx_0101_b <= not(     f(4) and combo2_0101 ); 
    combo2_xxxx_1101_b <= not(     f(4) and combo2_1101 ); 
    combo2_xxxx_0011_b <= not(     f(4) and combo2_0011 ); 
    combo2_xxxx_1011_b <= not(     f(4) and combo2_1011 ); 
    combo2_xxxx_0111_b <= not(     f(4) and combo2_0111 ); 


    combo3_0000_0001 <= not(                        combo2_xxxx_0001_b );--i=1, 1 1
    combo3_0000_0011 <= not(                        combo2_xxxx_0011_b );--i=3, 5 2
    combo3_0000_0100 <= not(                        combo2_xxxx_0100_b );--i=4, 1 3
    combo3_0000_0111 <= not(                        combo2_xxxx_0111_b );--i=7, 1 4
    combo3_0000_1001 <= not(                        combo2_xxxx_1001_b );--i=9, 1 5
    combo3_0000_1010 <= not(                        combo2_xxxx_1010_b );--i=10, 1 6
    combo3_0000_1011 <= not(                        combo2_xxxx_1011_b );--i=11, 1 7
    combo3_0000_1101 <= not(                        combo2_xxxx_1101_b );--i=13, 2 8
    combo3_0000_1111 <= not(                        not f(4)           );--i=15, 1 9
    combo3_0001_0001 <= not( not combo2_0001                           );--i=17, 1 10*
    combo3_0001_0010 <= not( combo2_0001_xxxx_b and combo2_xxxx_0010_b );--i=18, 1 11
    combo3_0001_0100 <= not( combo2_0001_xxxx_b and combo2_xxxx_0100_b );--i=20, 1 12
    combo3_0001_0101 <= not( combo2_0001_xxxx_b and combo2_xxxx_0101_b );--i=21, 2 13
    combo3_0001_0111 <= not( combo2_0001_xxxx_b and combo2_xxxx_0111_b );--i=23, 1 14
    combo3_0001_1000 <= not( combo2_0001_xxxx_b and combo2_xxxx_1000_b );--i=24, 2 15
    combo3_0001_1100 <= not( combo2_0001_xxxx_b and combo2_xxxx_1100_b );--i=28, 4 16
    combo3_0001_1101 <= not( combo2_0001_xxxx_b and combo2_xxxx_1101_b );--i=29, 2 17
    combo3_0001_1110 <= not( combo2_0001_xxxx_b and combo2_xxxx_1110_b );--i=30, 1 18
    combo3_0001_1111 <= not( combo2_0001_xxxx_b and not f(4)           );--i=31, 1 19
    combo3_0010_0001 <= not( combo2_0010_xxxx_b and combo2_xxxx_0001_b );--i=33, 1 20
    combo3_0010_0011 <= not( combo2_0010_xxxx_b and combo2_xxxx_0011_b );--i=35, 1 21
    combo3_0010_0100 <= not( combo2_0010_xxxx_b and combo2_xxxx_0100_b );--i=36, 1 22
    combo3_0010_0101 <= not( combo2_0010_xxxx_b and combo2_xxxx_0101_b );--i=37, 1 23
    combo3_0010_1000 <= not( combo2_0010_xxxx_b and combo2_xxxx_1000_b );--i=40, 3 24
    combo3_0010_1001 <= not( combo2_0010_xxxx_b and combo2_xxxx_1001_b );--i=41, 2 25
    combo3_0010_1010 <= not( combo2_0010_xxxx_b and combo2_xxxx_1010_b );--i=42, 1 26
    combo3_0010_1100 <= not( combo2_0010_xxxx_b and combo2_xxxx_1100_b );--i=44, 1 27
    combo3_0010_1101 <= not( combo2_0010_xxxx_b and combo2_xxxx_1101_b );--i=45, 1 28
    combo3_0010_1110 <= not( combo2_0010_xxxx_b and combo2_xxxx_1110_b );--i=46, 1 29
    combo3_0010_1111 <= not( combo2_0010_xxxx_b and not f(4)           );--i=47, 1 30
    combo3_0011_0000 <= not( combo2_0011_xxxx_b                        );--i=48, 2 31
    combo3_0011_0001 <= not( combo2_0011_xxxx_b and combo2_xxxx_0001_b );--i=49, 1 32
    combo3_0011_0011 <= not( not combo2_0011                           );--i=51, 1 33*
    combo3_0011_0101 <= not( combo2_0011_xxxx_b and combo2_xxxx_0101_b );--i=53, 1 34
    combo3_0011_0110 <= not( combo2_0011_xxxx_b and combo2_xxxx_0110_b );--i=54, 2 35
    combo3_0011_1000 <= not( combo2_0011_xxxx_b and combo2_xxxx_1000_b );--i=56, 1 36
    combo3_0011_1001 <= not( combo2_0011_xxxx_b and combo2_xxxx_1001_b );--i=57, 1 37
    combo3_0011_1110 <= not( combo2_0011_xxxx_b and combo2_xxxx_1110_b );--i=62, 1 38
    combo3_0011_1111 <= not( combo2_0011_xxxx_b and not f(4)           );--i=63, 5 39
    combo3_0100_0000 <= not( combo2_0100_xxxx_b                        );--i=64, 1 40
    combo3_0100_0010 <= not( combo2_0100_xxxx_b and combo2_xxxx_0010_b );--i=66, 1 41
    combo3_0100_0100 <= not( not combo2_0100                           );--i=68, 1 42*
    combo3_0100_0101 <= not( combo2_0100_xxxx_b and combo2_xxxx_0101_b );--i=69, 1 43
    combo3_0100_1001 <= not( combo2_0100_xxxx_b and combo2_xxxx_1001_b );--i=73, 1 44
    combo3_0100_1100 <= not( combo2_0100_xxxx_b and combo2_xxxx_1100_b );--i=76, 2 45
    combo3_0100_1110 <= not( combo2_0100_xxxx_b and combo2_xxxx_1110_b );--i=78, 1 46
    combo3_0100_1111 <= not( combo2_0100_xxxx_b and not f(4)           );--i=79, 1 47
    combo3_0101_0010 <= not( combo2_0101_xxxx_b and combo2_xxxx_0010_b );--i=82, 2 48
    combo3_0101_0100 <= not( combo2_0101_xxxx_b and combo2_xxxx_0100_b );--i=84, 1 49
    combo3_0101_0110 <= not( combo2_0101_xxxx_b and combo2_xxxx_0110_b );--i=86, 4 50
    combo3_0101_1001 <= not( combo2_0101_xxxx_b and combo2_xxxx_1001_b );--i=89, 2 51
    combo3_0101_1100 <= not( combo2_0101_xxxx_b and combo2_xxxx_1100_b );--i=92, 1 52
    combo3_0101_1111 <= not( combo2_0101_xxxx_b and not f(4)           );--i=95, 2 53
    combo3_0110_0000 <= not( combo2_0110_xxxx_b                        );--i=96, 1 54
    combo3_0110_0011 <= not( combo2_0110_xxxx_b and combo2_xxxx_0011_b );--i=99, 1 55
    combo3_0110_0110 <= not( not combo2_0110                           );--i=102, 2 56*
    combo3_0110_0111 <= not( combo2_0110_xxxx_b and combo2_xxxx_0111_b );--i=103, 1 57
    combo3_0110_1100 <= not( combo2_0110_xxxx_b and combo2_xxxx_1100_b );--i=108, 2 58
    combo3_0110_1101 <= not( combo2_0110_xxxx_b and combo2_xxxx_1101_b );--i=109, 2 59
    combo3_0110_1111 <= not( combo2_0110_xxxx_b and not f(4)           );--i=111, 1 60
    combo3_0111_0000 <= not( combo2_0111_xxxx_b                        );--i=112, 1 61
    combo3_0111_0101 <= not( combo2_0111_xxxx_b and combo2_xxxx_0101_b );--i=117, 1 62
    combo3_0111_0111 <= not( not combo2_0111                           );--i=119, 3 63*
    combo3_0111_1000 <= not( combo2_0111_xxxx_b and combo2_xxxx_1000_b );--i=120, 1 64
    combo3_0111_1001 <= not( combo2_0111_xxxx_b and combo2_xxxx_1001_b );--i=121, 2 65
    combo3_0111_1010 <= not( combo2_0111_xxxx_b and combo2_xxxx_1010_b );--i=122, 2 66
    combo3_0111_1111 <= not( combo2_0111_xxxx_b and not f(4)           );--i=127, 4 67
    combo3_1000_0000 <= not( combo2_1000_xxxx_b                        );--i=128, 3 68
    combo3_1000_0011 <= not( combo2_1000_xxxx_b and combo2_xxxx_0011_b );--i=131, 1 69
    combo3_1000_0110 <= not( combo2_1000_xxxx_b and combo2_xxxx_0110_b );--i=134, 1 70
    combo3_1000_0111 <= not( combo2_1000_xxxx_b and combo2_xxxx_0111_b );--i=135, 1 71
    combo3_1000_1010 <= not( combo2_1000_xxxx_b and combo2_xxxx_1010_b );--i=138, 1 72
    combo3_1000_1110 <= not( combo2_1000_xxxx_b and combo2_xxxx_1110_b );--i=142, 2 73
    combo3_1001_0000 <= not( combo2_1001_xxxx_b                        );--i=144, 2 74
    combo3_1001_0001 <= not( combo2_1001_xxxx_b and combo2_xxxx_0001_b );--i=145, 1 75
    combo3_1001_0010 <= not( combo2_1001_xxxx_b and combo2_xxxx_0010_b );--i=146, 2 76
    combo3_1001_0100 <= not( combo2_1001_xxxx_b and combo2_xxxx_0100_b );--i=148, 1 77
    combo3_1001_0110 <= not( combo2_1001_xxxx_b and combo2_xxxx_0110_b );--i=150, 1 78
    combo3_1001_0111 <= not( combo2_1001_xxxx_b and combo2_xxxx_0111_b );--i=151, 1 79
    combo3_1001_1000 <= not( combo2_1001_xxxx_b and combo2_xxxx_1000_b );--i=152, 1 80
    combo3_1001_1001 <= not( not combo2_1001                           );--i=153, 2 81*
    combo3_1001_1010 <= not( combo2_1001_xxxx_b and combo2_xxxx_1010_b );--i=154, 1 82
    combo3_1001_1011 <= not( combo2_1001_xxxx_b and combo2_xxxx_1011_b );--i=155, 2 83
    combo3_1001_1100 <= not( combo2_1001_xxxx_b and combo2_xxxx_1100_b );--i=156, 1 84
    combo3_1010_0000 <= not( combo2_1010_xxxx_b                        );--i=160, 1 85
    combo3_1010_0001 <= not( combo2_1010_xxxx_b and combo2_xxxx_0001_b );--i=161, 1 86
    combo3_1010_0010 <= not( combo2_1010_xxxx_b and combo2_xxxx_0010_b );--i=162, 1 87
    combo3_1010_0100 <= not( combo2_1010_xxxx_b and combo2_xxxx_0100_b );--i=164, 1 88
    combo3_1010_0101 <= not( combo2_1010_xxxx_b and combo2_xxxx_0101_b );--i=165, 2 89
    combo3_1010_0110 <= not( combo2_1010_xxxx_b and combo2_xxxx_0110_b );--i=166, 1 90
    combo3_1010_0111 <= not( combo2_1010_xxxx_b and combo2_xxxx_0111_b );--i=167, 1 91
    combo3_1010_1001 <= not( combo2_1010_xxxx_b and combo2_xxxx_1001_b );--i=169, 2 92
    combo3_1010_1010 <= not( not combo2_1010                           );--i=170, 2 93*
    combo3_1010_1100 <= not( combo2_1010_xxxx_b and combo2_xxxx_1100_b );--i=172, 2 94
    combo3_1010_1101 <= not( combo2_1010_xxxx_b and combo2_xxxx_1101_b );--i=173, 1 95
    combo3_1010_1111 <= not( combo2_1010_xxxx_b and not f(4)           );--i=175, 1 96
    combo3_1011_0001 <= not( combo2_1011_xxxx_b and combo2_xxxx_0001_b );--i=177, 1 97
    combo3_1011_0010 <= not( combo2_1011_xxxx_b and combo2_xxxx_0010_b );--i=178, 1 98
    combo3_1011_0100 <= not( combo2_1011_xxxx_b and combo2_xxxx_0100_b );--i=180, 1 99
    combo3_1011_0101 <= not( combo2_1011_xxxx_b and combo2_xxxx_0101_b );--i=181, 1 100
    combo3_1011_1000 <= not( combo2_1011_xxxx_b and combo2_xxxx_1000_b );--i=184, 1 101
    combo3_1011_1010 <= not( combo2_1011_xxxx_b and combo2_xxxx_1010_b );--i=186, 1 102
    combo3_1011_1100 <= not( combo2_1011_xxxx_b and combo2_xxxx_1100_b );--i=188, 1 103
    combo3_1100_0000 <= not( combo2_1100_xxxx_b                        );--i=192, 4 104
    combo3_1100_0001 <= not( combo2_1100_xxxx_b and combo2_xxxx_0001_b );--i=193, 1 105
    combo3_1100_0011 <= not( combo2_1100_xxxx_b and combo2_xxxx_0011_b );--i=195, 1 106
    combo3_1100_0101 <= not( combo2_1100_xxxx_b and combo2_xxxx_0101_b );--i=197, 1 107
    combo3_1100_0110 <= not( combo2_1100_xxxx_b and combo2_xxxx_0110_b );--i=198, 1 108
    combo3_1100_0111 <= not( combo2_1100_xxxx_b and combo2_xxxx_0111_b );--i=199, 1 109
    combo3_1100_1001 <= not( combo2_1100_xxxx_b and combo2_xxxx_1001_b );--i=201, 1 110
    combo3_1100_1010 <= not( combo2_1100_xxxx_b and combo2_xxxx_1010_b );--i=202, 2 111
    combo3_1100_1011 <= not( combo2_1100_xxxx_b and combo2_xxxx_1011_b );--i=203, 3 112
    combo3_1100_1101 <= not( combo2_1100_xxxx_b and combo2_xxxx_1101_b );--i=205, 1 113
    combo3_1100_1111 <= not( combo2_1100_xxxx_b and not f(4)           );--i=207, 1 114
    combo3_1101_0010 <= not( combo2_1101_xxxx_b and combo2_xxxx_0010_b );--i=210, 1 115
    combo3_1101_0011 <= not( combo2_1101_xxxx_b and combo2_xxxx_0011_b );--i=211, 2 116
    combo3_1101_1000 <= not( combo2_1101_xxxx_b and combo2_xxxx_1000_b );--i=216, 1 117
    combo3_1101_1001 <= not( combo2_1101_xxxx_b and combo2_xxxx_1001_b );--i=217, 2 118
    combo3_1101_1010 <= not( combo2_1101_xxxx_b and combo2_xxxx_1010_b );--i=218, 2 119
    combo3_1101_1100 <= not( combo2_1101_xxxx_b and combo2_xxxx_1100_b );--i=220, 1 120
    combo3_1101_1110 <= not( combo2_1101_xxxx_b and combo2_xxxx_1110_b );--i=222, 1 121
    combo3_1101_1111 <= not( combo2_1101_xxxx_b and not f(4)           );--i=223, 2 122
    combo3_1110_0000 <= not( combo2_1110_xxxx_b                        );--i=224, 5 123
    combo3_1110_0001 <= not( combo2_1110_xxxx_b and combo2_xxxx_0001_b );--i=225, 1 124
    combo3_1110_0011 <= not( combo2_1110_xxxx_b and combo2_xxxx_0011_b );--i=227, 2 125
    combo3_1110_0110 <= not( combo2_1110_xxxx_b and combo2_xxxx_0110_b );--i=230, 1 126
    combo3_1110_1000 <= not( combo2_1110_xxxx_b and combo2_xxxx_1000_b );--i=232, 1 127
    combo3_1110_1010 <= not( combo2_1110_xxxx_b and combo2_xxxx_1010_b );--i=234, 1 128
    combo3_1110_1101 <= not( combo2_1110_xxxx_b and combo2_xxxx_1101_b );--i=237, 3 129
    combo3_1111_0000 <= not(     f(4)                                  );--i=240, 2 130
    combo3_1111_0001 <= not(     f(4)           and combo2_xxxx_0001_b );--i=241, 1 131
    combo3_1111_0010 <= not(     f(4)           and combo2_xxxx_0010_b );--i=242, 2 132
    combo3_1111_1000 <= not(     f(4)           and combo2_xxxx_1000_b );--i=248, 3 133
    combo3_1111_1001 <= not(     f(4)           and combo2_xxxx_1001_b );--i=249, 2 134
    combo3_1111_1010 <= not(     f(4)           and combo2_xxxx_1010_b );--i=250, 2 135
    combo3_1111_1100 <= not(     f(4)           and combo2_xxxx_1100_b );--i=252, 4 136


--//#######################################
--//## ESTIMATE VECTORs
--//#######################################

    e_00_b(0) <= not( dcd_000 and tidn );
    e_00_b(1) <= not( dcd_001 and tidn );
    e_00_b(2) <= not( dcd_010 and tidn );
    e_00_b(3) <= not( dcd_011 and tidn );
    e_00_b(4) <= not( dcd_100 and tidn );
    e_00_b(5) <= not( dcd_101 and tidn );
    e_00_b(6) <= not( dcd_110 and tidn );
    e_00_b(7) <= not( dcd_111 and tidn );

    e( 0) <= not( e_00_b(0) and  
                  e_00_b(1) and  
                  e_00_b(2) and  
                  e_00_b(3) and  
                  e_00_b(4) and  
                  e_00_b(5) and  
                  e_00_b(6) and  
                  e_00_b(7)  );  

    e_01_b(0) <= not( dcd_000 and tiup );
    e_01_b(1) <= not( dcd_001 and tiup );
    e_01_b(2) <= not( dcd_010 and combo3_1100_0000 );
    e_01_b(3) <= not( dcd_011 and tidn );
    e_01_b(4) <= not( dcd_100 and tidn );
    e_01_b(5) <= not( dcd_101 and tidn );
    e_01_b(6) <= not( dcd_110 and tidn );
    e_01_b(7) <= not( dcd_111 and tidn );

    e( 1) <= not( e_01_b(0) and  
                  e_01_b(1) and  
                  e_01_b(2) and  
                  e_01_b(3) and  
                  e_01_b(4) and  
                  e_01_b(5) and  
                  e_01_b(6) and  
                  e_01_b(7)  );  

    e_02_b(0) <= not( dcd_000 and combo3_1111_0000 );
    e_02_b(1) <= not( dcd_001 and tidn );
    e_02_b(2) <= not( dcd_010 and combo3_0011_1111 );
    e_02_b(3) <= not( dcd_011 and tiup );
    e_02_b(4) <= not( dcd_100 and combo3_1111_1100 );
    e_02_b(5) <= not( dcd_101 and tidn );
    e_02_b(6) <= not( dcd_110 and tidn );
    e_02_b(7) <= not( dcd_111 and tidn );

    e( 2) <= not( e_02_b(0) and  
                  e_02_b(1) and  
                  e_02_b(2) and  
                  e_02_b(3) and  
                  e_02_b(4) and  
                  e_02_b(5) and  
                  e_02_b(6) and  
                  e_02_b(7)  );  

    e_03_b(0) <= not( dcd_000 and combo3_0000_1111 );
    e_03_b(1) <= not( dcd_001 and combo3_1110_0000 );
    e_03_b(2) <= not( dcd_010 and combo3_0011_1111 );
    e_03_b(3) <= not( dcd_011 and combo3_1110_0000 );
    e_03_b(4) <= not( dcd_100 and combo3_0000_0011 );
    e_03_b(5) <= not( dcd_101 and tiup );
    e_03_b(6) <= not( dcd_110 and combo3_1100_0000 );
    e_03_b(7) <= not( dcd_111 and tidn );

    e( 3) <= not( e_03_b(0) and  
                  e_03_b(1) and  
                  e_03_b(2) and  
                  e_03_b(3) and  
                  e_03_b(4) and  
                  e_03_b(5) and  
                  e_03_b(6) and  
                  e_03_b(7)  );  

    e_04_b(0) <= not( dcd_000 and combo3_1000_1110 );
    e_04_b(1) <= not( dcd_001 and combo3_0001_1100 );
    e_04_b(2) <= not( dcd_010 and combo3_0011_1110 );
    e_04_b(3) <= not( dcd_011 and combo3_0001_1111 );
    e_04_b(4) <= not( dcd_100 and combo3_0000_0011 );
    e_04_b(5) <= not( dcd_101 and combo3_1110_0000 );
    e_04_b(6) <= not( dcd_110 and combo3_0011_1111 );
    e_04_b(7) <= not( dcd_111 and combo3_1000_0000 );

    e( 4) <= not( e_04_b(0) and  
                  e_04_b(1) and  
                  e_04_b(2) and  
                  e_04_b(3) and  
                  e_04_b(4) and  
                  e_04_b(5) and  
                  e_04_b(6) and  
                  e_04_b(7)  );  

    e_05_b(0) <= not( dcd_000 and combo3_0110_1101 );
    e_05_b(1) <= not( dcd_001 and combo3_1001_1011 );
    e_05_b(2) <= not( dcd_010 and combo3_0011_0001 );
    e_05_b(3) <= not( dcd_011 and combo3_1001_1100 );
    e_05_b(4) <= not( dcd_100 and combo3_1110_0011 );
    e_05_b(5) <= not( dcd_101 and combo3_0001_1110 );
    e_05_b(6) <= not( dcd_110 and combo3_0011_1000 );
    e_05_b(7) <= not( dcd_111 and combo3_0111_1000 );

    e( 5) <= not( e_05_b(0) and  
                  e_05_b(1) and  
                  e_05_b(2) and  
                  e_05_b(3) and  
                  e_05_b(4) and  
                  e_05_b(5) and  
                  e_05_b(6) and  
                  e_05_b(7)  );  

    e_06_b(0) <= not( dcd_000 and combo3_1100_1011 );
    e_06_b(1) <= not( dcd_001 and combo3_0101_0110 );
    e_06_b(2) <= not( dcd_010 and combo3_1010_1101 );
    e_06_b(3) <= not( dcd_011 and combo3_0101_0010 );
    e_06_b(4) <= not( dcd_100 and combo3_1101_0010 );
    e_06_b(5) <= not( dcd_101 and combo3_1101_1001 );
    e_06_b(6) <= not( dcd_110 and combo3_0011_0110 );
    e_06_b(7) <= not( dcd_111 and combo3_0110_0110 );

    e( 6) <= not( e_06_b(0) and  
                  e_06_b(1) and  
                  e_06_b(2) and  
                  e_06_b(3) and  
                  e_06_b(4) and  
                  e_06_b(5) and  
                  e_06_b(6) and  
                  e_06_b(7)  );  

    e_07_b(0) <= not( dcd_000 and combo3_0101_1001 );
    e_07_b(1) <= not( dcd_001 and combo3_1000_0011 );
    e_07_b(2) <= not( dcd_010 and combo3_1111_1000 );
    e_07_b(3) <= not( dcd_011 and combo3_0011_1001 );
    e_07_b(4) <= not( dcd_100 and combo3_1001_1001 );
    e_07_b(5) <= not( dcd_101 and combo3_1011_0100 );
    e_07_b(6) <= not( dcd_110 and combo3_1010_0101 );
    e_07_b(7) <= not( dcd_111 and combo3_0101_0100 );

    e( 7) <= not( e_07_b(0) and  
                  e_07_b(1) and  
                  e_07_b(2) and  
                  e_07_b(3) and  
                  e_07_b(4) and  
                  e_07_b(5) and  
                  e_07_b(6) and  
                  e_07_b(7)  );  

    e_08_b(0) <= not( dcd_000 and combo3_0001_0101 );
    e_08_b(1) <= not( dcd_001 and combo3_0110_0011 );
    e_08_b(2) <= not( dcd_010 and combo3_1111_1001 );
    e_08_b(3) <= not( dcd_011 and combo3_1101_1010 );
    e_08_b(4) <= not( dcd_100 and combo3_1010_1010 );
    e_08_b(5) <= not( dcd_101 and combo3_1101_1001 );
    e_08_b(6) <= not( dcd_110 and combo3_1000_1110 );
    e_08_b(7) <= not( dcd_111 and combo3_0000_0001 );

    e( 8) <= not( e_08_b(0) and  
                  e_08_b(1) and  
                  e_08_b(2) and  
                  e_08_b(3) and  
                  e_08_b(4) and  
                  e_08_b(5) and  
                  e_08_b(6) and  
                  e_08_b(7)  );  

    e_09_b(0) <= not( dcd_000 and combo3_0011_0000 );
    e_09_b(1) <= not( dcd_001 and combo3_1101_0011 );
    e_09_b(2) <= not( dcd_010 and combo3_1111_1010 );
    e_09_b(3) <= not( dcd_011 and combo3_0110_1100 );
    e_09_b(4) <= not( dcd_100 and combo3_0000_0011 );
    e_09_b(5) <= not( dcd_101 and combo3_1011_0101 );
    e_09_b(6) <= not( dcd_110 and combo3_0100_1001 );
    e_09_b(7) <= not( dcd_111 and combo3_1100_0001 );

    e( 9) <= not( e_09_b(0) and  
                  e_09_b(1) and  
                  e_09_b(2) and  
                  e_09_b(3) and  
                  e_09_b(4) and  
                  e_09_b(5) and  
                  e_09_b(6) and  
                  e_09_b(7)  );  

    e_10_b(0) <= not( dcd_000 and combo3_0110_1111 );
    e_10_b(1) <= not( dcd_001 and combo3_0111_1010 );
    e_10_b(2) <= not( dcd_010 and combo3_0001_1100 );
    e_10_b(3) <= not( dcd_011 and combo3_1100_1011 );
    e_10_b(4) <= not( dcd_100 and combo3_0000_0100 );
    e_10_b(5) <= not( dcd_101 and combo3_1101_1111 );
    e_10_b(6) <= not( dcd_110 and combo3_1110_1101 );
    e_10_b(7) <= not( dcd_111 and combo3_1011_0001 );

    e(10) <= not( e_10_b(0) and  
                  e_10_b(1) and  
                  e_10_b(2) and  
                  e_10_b(3) and  
                  e_10_b(4) and  
                  e_10_b(5) and  
                  e_10_b(6) and  
                  e_10_b(7)  );  

    e_11_b(0) <= not( dcd_000 and combo3_0111_1001 );
    e_11_b(1) <= not( dcd_001 and combo3_1100_1001 );
    e_11_b(2) <= not( dcd_010 and combo3_0010_1000 );
    e_11_b(3) <= not( dcd_011 and combo3_1101_1110 );
    e_11_b(4) <= not( dcd_100 and combo3_1001_1001 );
    e_11_b(5) <= not( dcd_101 and combo3_1001_0000 );
    e_11_b(6) <= not( dcd_110 and combo3_0111_0111 );
    e_11_b(7) <= not( dcd_111 and combo3_0010_1001 );

    e(11) <= not( e_11_b(0) and  
                  e_11_b(1) and  
                  e_11_b(2) and  
                  e_11_b(3) and  
                  e_11_b(4) and  
                  e_11_b(5) and  
                  e_11_b(6) and  
                  e_11_b(7)  );  

    e_12_b(0) <= not( dcd_000 and combo3_0110_0110 );
    e_12_b(1) <= not( dcd_001 and combo3_0111_0111 );
    e_12_b(2) <= not( dcd_010 and combo3_1100_1010 );
    e_12_b(3) <= not( dcd_011 and combo3_1111_0000 );
    e_12_b(4) <= not( dcd_100 and combo3_0110_1101 );
    e_12_b(5) <= not( dcd_101 and combo3_1011_1000 );
    e_12_b(6) <= not( dcd_110 and combo3_1010_0111 );
    e_12_b(7) <= not( dcd_111 and combo3_0100_0101 );

    e(12) <= not( e_12_b(0) and  
                  e_12_b(1) and  
                  e_12_b(2) and  
                  e_12_b(3) and  
                  e_12_b(4) and  
                  e_12_b(5) and  
                  e_12_b(6) and  
                  e_12_b(7)  );  

    e_13_b(0) <= not( dcd_000 and combo3_1010_1001 );
    e_13_b(1) <= not( dcd_001 and combo3_0010_1110 );
    e_13_b(2) <= not( dcd_010 and combo3_1011_1010 );
    e_13_b(3) <= not( dcd_011 and combo3_0100_0010 );
    e_13_b(4) <= not( dcd_100 and combo3_1110_1101 );
    e_13_b(5) <= not( dcd_101 and combo3_1010_1100 );
    e_13_b(6) <= not( dcd_110 and combo3_0010_1111 );
    e_13_b(7) <= not( dcd_111 and combo3_0010_1001 );

    e(13) <= not( e_13_b(0) and  
                  e_13_b(1) and  
                  e_13_b(2) and  
                  e_13_b(3) and  
                  e_13_b(4) and  
                  e_13_b(5) and  
                  e_13_b(6) and  
                  e_13_b(7)  );  

    e_14_b(0) <= not( dcd_000 and combo3_0111_1001 );
    e_14_b(1) <= not( dcd_001 and combo3_0001_1000 );
    e_14_b(2) <= not( dcd_010 and combo3_0100_1100 );
    e_14_b(3) <= not( dcd_011 and combo3_1100_1011 );
    e_14_b(4) <= not( dcd_100 and combo3_1111_0010 );
    e_14_b(5) <= not( dcd_101 and combo3_0101_1111 );
    e_14_b(6) <= not( dcd_110 and combo3_0110_1100 );
    e_14_b(7) <= not( dcd_111 and combo3_0001_0010 );

    e(14) <= not( e_14_b(0) and  
                  e_14_b(1) and  
                  e_14_b(2) and  
                  e_14_b(3) and  
                  e_14_b(4) and  
                  e_14_b(5) and  
                  e_14_b(6) and  
                  e_14_b(7)  );  

    e_15_b(0) <= not( dcd_000 and combo3_1001_0000 );
    e_15_b(1) <= not( dcd_001 and combo3_1001_0010 );
    e_15_b(2) <= not( dcd_010 and combo3_1101_1010 );
    e_15_b(3) <= not( dcd_011 and combo3_1001_0111 );
    e_15_b(4) <= not( dcd_100 and combo3_0101_1111 );
    e_15_b(5) <= not( dcd_101 and combo3_1001_0001 );
    e_15_b(6) <= not( dcd_110 and combo3_0011_0101 );
    e_15_b(7) <= not( dcd_111 and combo3_1100_0101 );

    e(15) <= not( e_15_b(0) and  
                  e_15_b(1) and  
                  e_15_b(2) and  
                  e_15_b(3) and  
                  e_15_b(4) and  
                  e_15_b(5) and  
                  e_15_b(6) and  
                  e_15_b(7)  );  

    e_16_b(0) <= not( dcd_000 and combo3_1010_1111 );
    e_16_b(1) <= not( dcd_001 and combo3_0101_1100 );
    e_16_b(2) <= not( dcd_010 and combo3_0100_0000 );
    e_16_b(3) <= not( dcd_011 and combo3_0001_0001 );
    e_16_b(4) <= not( dcd_100 and combo3_0000_1101 );
    e_16_b(5) <= not( dcd_101 and combo3_1100_1111 );
    e_16_b(6) <= not( dcd_110 and combo3_1010_0100 );
    e_16_b(7) <= not( dcd_111 and combo3_0001_1101 );

    e(16) <= not( e_16_b(0) and  
                  e_16_b(1) and  
                  e_16_b(2) and  
                  e_16_b(3) and  
                  e_16_b(4) and  
                  e_16_b(5) and  
                  e_16_b(6) and  
                  e_16_b(7)  );  

    e_17_b(0) <= not( dcd_000 and combo3_1010_0010 );
    e_17_b(1) <= not( dcd_001 and combo3_1111_0010 );
    e_17_b(2) <= not( dcd_010 and combo3_0101_1001 );
    e_17_b(3) <= not( dcd_011 and combo3_1000_0110 );
    e_17_b(4) <= not( dcd_100 and combo3_1110_0001 );
    e_17_b(5) <= not( dcd_101 and combo3_0010_0011 );
    e_17_b(6) <= not( dcd_110 and combo3_1000_1010 );
    e_17_b(7) <= not( dcd_111 and combo3_1001_0100 );

    e(17) <= not( e_17_b(0) and  
                  e_17_b(1) and  
                  e_17_b(2) and  
                  e_17_b(3) and  
                  e_17_b(4) and  
                  e_17_b(5) and  
                  e_17_b(6) and  
                  e_17_b(7)  );  

    e_18_b(0) <= not( dcd_000 and combo3_1101_1100 );
    e_18_b(1) <= not( dcd_001 and combo3_0010_1101 );
    e_18_b(2) <= not( dcd_010 and combo3_1100_1010 );
    e_18_b(3) <= not( dcd_011 and combo3_1010_0001 );
    e_18_b(4) <= not( dcd_100 and combo3_1000_0000 );
    e_18_b(5) <= not( dcd_101 and combo3_1011_0010 );
    e_18_b(6) <= not( dcd_110 and combo3_1110_1010 );
    e_18_b(7) <= not( dcd_111 and combo3_0010_1000 );

    e(18) <= not( e_18_b(0) and  
                  e_18_b(1) and  
                  e_18_b(2) and  
                  e_18_b(3) and  
                  e_18_b(4) and  
                  e_18_b(5) and  
                  e_18_b(6) and  
                  e_18_b(7)  );  

    e_19_b(0) <= not( dcd_000 and tiup );
    e_19_b(1) <= not( dcd_001 and tiup );
    e_19_b(2) <= not( dcd_010 and tiup );
    e_19_b(3) <= not( dcd_011 and tiup );
    e_19_b(4) <= not( dcd_100 and tiup );
    e_19_b(5) <= not( dcd_101 and tiup );
    e_19_b(6) <= not( dcd_110 and tiup );
    e_19_b(7) <= not( dcd_111 and tiup );

    e(19) <= not( e_19_b(0) and  
                  e_19_b(1) and  
                  e_19_b(2) and  
                  e_19_b(3) and  
                  e_19_b(4) and  
                  e_19_b(5) and  
                  e_19_b(6) and  
                  e_19_b(7)  );  



--//#######################################
--//## RANGE VECTORs
--//#######################################

    r_00_b(0) <= not( dcd_000 and tidn );
    r_00_b(1) <= not( dcd_001 and tidn );
    r_00_b(2) <= not( dcd_010 and tidn );
    r_00_b(3) <= not( dcd_011 and tidn );
    r_00_b(4) <= not( dcd_100 and tidn );
    r_00_b(5) <= not( dcd_101 and tidn );
    r_00_b(6) <= not( dcd_110 and tidn );
    r_00_b(7) <= not( dcd_111 and tidn );

    r( 0) <= not( r_00_b(0) and  
                  r_00_b(1) and  
                  r_00_b(2) and  
                  r_00_b(3) and  
                  r_00_b(4) and  
                  r_00_b(5) and  
                  r_00_b(6) and  
                  r_00_b(7)  );  

    r_01_b(0) <= not( dcd_000 and tiup );
    r_01_b(1) <= not( dcd_001 and tiup );
    r_01_b(2) <= not( dcd_010 and combo3_1000_0000 );
    r_01_b(3) <= not( dcd_011 and tidn );
    r_01_b(4) <= not( dcd_100 and tidn );
    r_01_b(5) <= not( dcd_101 and tidn );
    r_01_b(6) <= not( dcd_110 and tidn );
    r_01_b(7) <= not( dcd_111 and tidn );

    r( 1) <= not( r_01_b(0) and  
                  r_01_b(1) and  
                  r_01_b(2) and  
                  r_01_b(3) and  
                  r_01_b(4) and  
                  r_01_b(5) and  
                  r_01_b(6) and  
                  r_01_b(7)  );  

    r_02_b(0) <= not( dcd_000 and tidn );
    r_02_b(1) <= not( dcd_001 and tidn );
    r_02_b(2) <= not( dcd_010 and combo3_0111_1111 );
    r_02_b(3) <= not( dcd_011 and tiup );
    r_02_b(4) <= not( dcd_100 and tiup );
    r_02_b(5) <= not( dcd_101 and tiup );
    r_02_b(6) <= not( dcd_110 and tiup );
    r_02_b(7) <= not( dcd_111 and tiup );

    r( 2) <= not( r_02_b(0) and  
                  r_02_b(1) and  
                  r_02_b(2) and  
                  r_02_b(3) and  
                  r_02_b(4) and  
                  r_02_b(5) and  
                  r_02_b(6) and  
                  r_02_b(7)  );  

    r_03_b(0) <= not( dcd_000 and combo3_1111_1000 );
    r_03_b(1) <= not( dcd_001 and tidn );
    r_03_b(2) <= not( dcd_010 and combo3_0111_1111 );
    r_03_b(3) <= not( dcd_011 and tiup );
    r_03_b(4) <= not( dcd_100 and combo3_1100_0000 );
    r_03_b(5) <= not( dcd_101 and tidn );
    r_03_b(6) <= not( dcd_110 and tidn );
    r_03_b(7) <= not( dcd_111 and tidn );

    r( 3) <= not( r_03_b(0) and  
                  r_03_b(1) and  
                  r_03_b(2) and  
                  r_03_b(3) and  
                  r_03_b(4) and  
                  r_03_b(5) and  
                  r_03_b(6) and  
                  r_03_b(7)  );  

    r_04_b(0) <= not( dcd_000 and combo3_1000_0111 );
    r_04_b(1) <= not( dcd_001 and combo3_1110_0000 );
    r_04_b(2) <= not( dcd_010 and combo3_0111_1111 );
    r_04_b(3) <= not( dcd_011 and tidn );
    r_04_b(4) <= not( dcd_100 and combo3_0011_1111 );
    r_04_b(5) <= not( dcd_101 and combo3_1111_1100 );
    r_04_b(6) <= not( dcd_110 and tidn );
    r_04_b(7) <= not( dcd_111 and tidn );

    r( 4) <= not( r_04_b(0) and  
                  r_04_b(1) and  
                  r_04_b(2) and  
                  r_04_b(3) and  
                  r_04_b(4) and  
                  r_04_b(5) and  
                  r_04_b(6) and  
                  r_04_b(7)  );  

    r_05_b(0) <= not( dcd_000 and combo3_0110_0111 );
    r_05_b(1) <= not( dcd_001 and combo3_0001_1000 );
    r_05_b(2) <= not( dcd_010 and combo3_0111_0000 );
    r_05_b(3) <= not( dcd_011 and combo3_1111_1000 );
    r_05_b(4) <= not( dcd_100 and combo3_0011_1111 );
    r_05_b(5) <= not( dcd_101 and combo3_0000_0011 );
    r_05_b(6) <= not( dcd_110 and combo3_1111_1100 );
    r_05_b(7) <= not( dcd_111 and tidn );

    r( 5) <= not( r_05_b(0) and  
                  r_05_b(1) and  
                  r_05_b(2) and  
                  r_05_b(3) and  
                  r_05_b(4) and  
                  r_05_b(5) and  
                  r_05_b(6) and  
                  r_05_b(7)  );  

    r_06_b(0) <= not( dcd_000 and combo3_0101_0110 );
    r_06_b(1) <= not( dcd_001 and combo3_1001_0110 );
    r_06_b(2) <= not( dcd_010 and combo3_0100_1100 );
    r_06_b(3) <= not( dcd_011 and combo3_1100_0110 );
    r_06_b(4) <= not( dcd_100 and combo3_0011_0000 );
    r_06_b(5) <= not( dcd_101 and combo3_1110_0011 );
    r_06_b(6) <= not( dcd_110 and combo3_1100_0011 );
    r_06_b(7) <= not( dcd_111 and combo3_1110_0000 );

    r( 6) <= not( r_06_b(0) and  
                  r_06_b(1) and  
                  r_06_b(2) and  
                  r_06_b(3) and  
                  r_06_b(4) and  
                  r_06_b(5) and  
                  r_06_b(6) and  
                  r_06_b(7)  );  

    r_07_b(0) <= not( dcd_000 and combo3_1111_1100 );
    r_07_b(1) <= not( dcd_001 and combo3_1100_1101 );
    r_07_b(2) <= not( dcd_010 and combo3_0010_1010 );
    r_07_b(3) <= not( dcd_011 and combo3_1010_0101 );
    r_07_b(4) <= not( dcd_100 and combo3_0010_1100 );
    r_07_b(5) <= not( dcd_101 and combo3_1001_1011 );
    r_07_b(6) <= not( dcd_110 and combo3_0011_0011 );
    r_07_b(7) <= not( dcd_111 and combo3_1001_1000 );

    r( 7) <= not( r_07_b(0) and  
                  r_07_b(1) and  
                  r_07_b(2) and  
                  r_07_b(3) and  
                  r_07_b(4) and  
                  r_07_b(5) and  
                  r_07_b(6) and  
                  r_07_b(7)  );  

    r_08_b(0) <= not( dcd_000 and combo3_0001_1101 );
    r_08_b(1) <= not( dcd_001 and combo3_0101_0110 );
    r_08_b(2) <= not( dcd_010 and combo3_0111_1111 );
    r_08_b(3) <= not( dcd_011 and combo3_1111_0001 );
    r_08_b(4) <= not( dcd_100 and combo3_1001_1010 );
    r_08_b(5) <= not( dcd_101 and combo3_0101_0010 );
    r_08_b(6) <= not( dcd_110 and combo3_1010_1010 );
    r_08_b(7) <= not( dcd_111 and combo3_0101_0110 );

    r( 8) <= not( r_08_b(0) and  
                  r_08_b(1) and  
                  r_08_b(2) and  
                  r_08_b(3) and  
                  r_08_b(4) and  
                  r_08_b(5) and  
                  r_08_b(6) and  
                  r_08_b(7)  );  

    r_09_b(0) <= not( dcd_000 and combo3_1110_0110 );
    r_09_b(1) <= not( dcd_001 and combo3_0000_1101 );
    r_09_b(2) <= not( dcd_010 and combo3_0110_0000 );
    r_09_b(3) <= not( dcd_011 and combo3_0011_0110 );
    r_09_b(4) <= not( dcd_100 and combo3_1010_1100 );
    r_09_b(5) <= not( dcd_101 and combo3_1100_0111 );
    r_09_b(6) <= not( dcd_110 and tiup );
    r_09_b(7) <= not( dcd_111 and combo3_0001_1100 );

    r( 9) <= not( r_09_b(0) and  
                  r_09_b(1) and  
                  r_09_b(2) and  
                  r_09_b(3) and  
                  r_09_b(4) and  
                  r_09_b(5) and  
                  r_09_b(6) and  
                  r_09_b(7)  );  

    r_10_b(0) <= not( dcd_000 and combo3_1110_1101 );
    r_10_b(1) <= not( dcd_001 and combo3_0001_0111 );
    r_10_b(2) <= not( dcd_010 and combo3_1101_1000 );
    r_10_b(3) <= not( dcd_011 and combo3_1101_0011 );
    r_10_b(4) <= not( dcd_100 and combo3_1111_1010 );
    r_10_b(5) <= not( dcd_101 and combo3_1010_0110 );
    r_10_b(6) <= not( dcd_110 and combo3_0000_0111 );
    r_10_b(7) <= not( dcd_111 and combo3_0010_0101 );

    r(10) <= not( r_10_b(0) and  
                  r_10_b(1) and  
                  r_10_b(2) and  
                  r_10_b(3) and  
                  r_10_b(4) and  
                  r_10_b(5) and  
                  r_10_b(6) and  
                  r_10_b(7)  );  

    r_11_b(0) <= not( dcd_000 and combo3_1011_1100 );
    r_11_b(1) <= not( dcd_001 and combo3_1010_0000 );
    r_11_b(2) <= not( dcd_010 and combo3_0111_0111 );
    r_11_b(3) <= not( dcd_011 and combo3_0111_1010 );
    r_11_b(4) <= not( dcd_100 and combo3_0001_1100 );
    r_11_b(5) <= not( dcd_101 and combo3_0001_0101 );
    r_11_b(6) <= not( dcd_110 and combo3_1111_1001 );
    r_11_b(7) <= not( dcd_111 and combo3_0100_1111 );

    r(11) <= not( r_11_b(0) and  
                  r_11_b(1) and  
                  r_11_b(2) and  
                  r_11_b(3) and  
                  r_11_b(4) and  
                  r_11_b(5) and  
                  r_11_b(6) and  
                  r_11_b(7)  );  

    r_12_b(0) <= not( dcd_000 and combo3_0100_1110 );
    r_12_b(1) <= not( dcd_001 and combo3_0100_0100 );
    r_12_b(2) <= not( dcd_010 and combo3_1101_1111 );
    r_12_b(3) <= not( dcd_011 and combo3_1100_0000 );
    r_12_b(4) <= not( dcd_100 and combo3_0000_1010 );
    r_12_b(5) <= not( dcd_101 and combo3_0010_0001 );
    r_12_b(6) <= not( dcd_110 and combo3_0000_1011 );
    r_12_b(7) <= not( dcd_111 and combo3_1110_1000 );

    r(12) <= not( r_12_b(0) and  
                  r_12_b(1) and  
                  r_12_b(2) and  
                  r_12_b(3) and  
                  r_12_b(4) and  
                  r_12_b(5) and  
                  r_12_b(6) and  
                  r_12_b(7)  );  

    r_13_b(0) <= not( dcd_000 and combo3_1010_1001 );
    r_13_b(1) <= not( dcd_001 and combo3_0001_0100 );
    r_13_b(2) <= not( dcd_010 and combo3_0111_0101 );
    r_13_b(3) <= not( dcd_011 and combo3_0000_1001 );
    r_13_b(4) <= not( dcd_100 and combo3_0010_1000 );
    r_13_b(5) <= not( dcd_101 and combo3_0000_0011 );
    r_13_b(6) <= not( dcd_110 and combo3_1001_0010 );
    r_13_b(7) <= not( dcd_111 and combo3_0010_0100 );

    r(13) <= not( r_13_b(0) and  
                  r_13_b(1) and  
                  r_13_b(2) and  
                  r_13_b(3) and  
                  r_13_b(4) and  
                  r_13_b(5) and  
                  r_13_b(6) and  
                  r_13_b(7)  );  

    r_14_b(0) <= not( dcd_000 and tidn );
    r_14_b(1) <= not( dcd_001 and tidn );
    r_14_b(2) <= not( dcd_010 and tidn );
    r_14_b(3) <= not( dcd_011 and tidn );
    r_14_b(4) <= not( dcd_100 and tidn );
    r_14_b(5) <= not( dcd_101 and tidn );
    r_14_b(6) <= not( dcd_110 and tidn );
    r_14_b(7) <= not( dcd_111 and tidn );

    r(14) <= not( r_14_b(0) and  
                  r_14_b(1) and  
                  r_14_b(2) and  
                  r_14_b(3) and  
                  r_14_b(4) and  
                  r_14_b(5) and  
                  r_14_b(6) and  
                  r_14_b(7)  );  




--//#######################################
--//## RENUMBERING OUTPUTS
--//#######################################

  est(1 to 20) <= e(0 to 19);-- renumbering
  rng(6 to 20) <= r(0 to 14);-- renumbering


end; -- fuq_tblsqe ARCHITECTURE
