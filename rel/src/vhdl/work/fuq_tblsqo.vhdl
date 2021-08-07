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

-- 11111111111111000001 011111101000010 0
-- 11111100000001111101 011110111010000 1
-- 11111000001010101101 011110001101100 2
-- 11110100011000111111 011101100010110 3
-- 11110000101100101001 011100111001100 4
-- 11101101000101011011 011100010001110 5
-- 11101001100011001101 011011101011010 6
-- 11100110000101110001 011011000110010 7
-- 11100010101100111101 011010100010100 8
-- 11011111011000101001 011010000000000 9
-- 11011100001000100111 011001011110100 10
-- 11011000111100110011 011000111110010 11
-- 11010101110100111111 011000011111000 12
-- 11010010110001000101 011000000000110 13
-- 11001111110000111101 010111100011100 14
-- 11001100110100100001 010111000111010 15
-- 11001001111011100101 010110101011110 16
-- 11000111000110000111 010110010001000 17
-- 11000100010011111101 010101110111010 18
-- 11000001100101000011 010101011110010 19
-- 10111110111001010001 010101000101110 20
-- 10111100010000100001 010100101110010 21
-- 10111001101010101101 010100010111010 22
-- 10110111000111110011 010100000001000 23
-- 10110100100111101001 010011101011010 24
-- 10110010001010001101 010011010110010 25
-- 10101111101111011001 010011000001110 26
-- 10101101010111001011 010010101110000 27
-- 10101011000001011001 010010011010100 28
-- 10101000101110000101 010010000111110 29
-- 10100110011101000101 010001110101010 30
-- 10100100001110011011 010001100011100 31
-- 10100010000001111101 010001010010000 32
-- 10011111110111101101 010001000001000 33
-- 10011101101111100011 010000110000100 34
-- 10011011101001011101 010000100000100 35
-- 10011001100101011001 010000010000110 36
-- 10010111100011010011 010000000001010 37
-- 10010101100011000111 001111110010010 38
-- 10010011100100110101 001111100011110 39
-- 10010001101000010101 001111010101100 40
-- 10001111101101101001 001111000111100 41
-- 10001101110100101011 001110111010000 42
-- 10001011111101011011 001110101100110 43
-- 10001010000111110101 001110011111110 44
-- 10001000010011110101 001110010011000 45
-- 10000110100001011101 001110000110100 46
-- 10000100110000100111 001101111010100 47
-- 10000011000001010001 001101101110110 48
-- 10000001010011011011 001101100011000 49
-- 01111111100111000011 001101010111110 50
-- 01111101111100000011 001101001100110 51
-- 01111100010010011101 001101000001110 52
-- 01111010101010001111 001100110111010 53
-- 01111001000011010011 001100101100110 54
-- 01110111011101101101 001100100010100 55
-- 01110101111001010111 001100011000100 56
-- 01110100010110010001 001100001110110 57
-- 01110010110100011001 001100000101010 58
-- 01110001010011101111 001011111100000 59
-- 01101111110100001111 001011110010110 60
-- 01101110010101110111 001011101001110 61
-- 01101100111000101001 001011100001000 62
-- 01101011011100100001 001011011000010 63



 
entity fuq_tblsqo is
generic(   expand_type               : integer := 2  ); -- 0 - ibm tech, 1 - other );
port( 
       f    :in   std_ulogic_vector(1 to 6);
       est  :out  std_ulogic_vector(1 to 20);
       rng  :out  std_ulogic_vector(6 to 20)
       
); 
 
 
 
end fuq_tblsqo; -- ENTITY
 
 
architecture fuq_tblsqo of fuq_tblsqo is 
 
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
  signal combo3_0000_1011 :std_ulogic; 
  signal combo3_0000_1100 :std_ulogic; 
  signal combo3_0000_1101 :std_ulogic; 
  signal combo3_0000_1111 :std_ulogic; 
  signal combo3_0001_0001 :std_ulogic; 
  signal combo3_0001_0010 :std_ulogic; 
  signal combo3_0001_0100 :std_ulogic; 
  signal combo3_0001_0101 :std_ulogic; 
  signal combo3_0001_0111 :std_ulogic; 
  signal combo3_0001_1000 :std_ulogic; 
  signal combo3_0001_1110 :std_ulogic; 
  signal combo3_0001_1111 :std_ulogic; 
  signal combo3_0010_0001 :std_ulogic; 
  signal combo3_0010_0010 :std_ulogic; 
  signal combo3_0010_0011 :std_ulogic; 
  signal combo3_0010_0100 :std_ulogic; 
  signal combo3_0010_0110 :std_ulogic; 
  signal combo3_0010_1001 :std_ulogic; 
  signal combo3_0010_1101 :std_ulogic; 
  signal combo3_0010_1110 :std_ulogic; 
  signal combo3_0011_0000 :std_ulogic; 
  signal combo3_0011_0001 :std_ulogic; 
  signal combo3_0011_0011 :std_ulogic; 
  signal combo3_0011_0100 :std_ulogic; 
  signal combo3_0011_0101 :std_ulogic; 
  signal combo3_0011_1000 :std_ulogic; 
  signal combo3_0011_1001 :std_ulogic; 
  signal combo3_0011_1010 :std_ulogic; 
  signal combo3_0011_1100 :std_ulogic; 
  signal combo3_0011_1110 :std_ulogic; 
  signal combo3_0011_1111 :std_ulogic; 
  signal combo3_0100_0000 :std_ulogic; 
  signal combo3_0100_0101 :std_ulogic; 
  signal combo3_0100_0110 :std_ulogic; 
  signal combo3_0100_1000 :std_ulogic; 
  signal combo3_0100_1001 :std_ulogic; 
  signal combo3_0100_1010 :std_ulogic; 
  signal combo3_0100_1100 :std_ulogic; 
  signal combo3_0100_1101 :std_ulogic; 
  signal combo3_0101_0000 :std_ulogic; 
  signal combo3_0101_0001 :std_ulogic; 
  signal combo3_0101_0011 :std_ulogic; 
  signal combo3_0101_0101 :std_ulogic; 
  signal combo3_0101_0110 :std_ulogic; 
  signal combo3_0101_1001 :std_ulogic; 
  signal combo3_0101_1010 :std_ulogic; 
  signal combo3_0101_1110 :std_ulogic; 
  signal combo3_0101_1111 :std_ulogic; 
  signal combo3_0110_0011 :std_ulogic; 
  signal combo3_0110_0110 :std_ulogic; 
  signal combo3_0110_0111 :std_ulogic; 
  signal combo3_0110_1001 :std_ulogic; 
  signal combo3_0110_1010 :std_ulogic; 
  signal combo3_0110_1011 :std_ulogic; 
  signal combo3_0110_1100 :std_ulogic; 
  signal combo3_0110_1101 :std_ulogic; 
  signal combo3_0110_1110 :std_ulogic; 
  signal combo3_0110_1111 :std_ulogic; 
  signal combo3_0111_0000 :std_ulogic; 
  signal combo3_0111_0010 :std_ulogic; 
  signal combo3_0111_0011 :std_ulogic; 
  signal combo3_0111_0110 :std_ulogic; 
  signal combo3_0111_1000 :std_ulogic; 
  signal combo3_0111_1001 :std_ulogic; 
  signal combo3_0111_1100 :std_ulogic; 
  signal combo3_0111_1110 :std_ulogic; 
  signal combo3_0111_1111 :std_ulogic; 
  signal combo3_1000_0000 :std_ulogic; 
  signal combo3_1000_0001 :std_ulogic; 
  signal combo3_1000_0011 :std_ulogic; 
  signal combo3_1000_0110 :std_ulogic; 
  signal combo3_1000_1000 :std_ulogic; 
  signal combo3_1000_1010 :std_ulogic; 
  signal combo3_1000_1101 :std_ulogic; 
  signal combo3_1000_1110 :std_ulogic; 
  signal combo3_1000_1111 :std_ulogic; 
  signal combo3_1001_0000 :std_ulogic; 
  signal combo3_1001_0010 :std_ulogic; 
  signal combo3_1001_0011 :std_ulogic; 
  signal combo3_1001_0100 :std_ulogic; 
  signal combo3_1001_0111 :std_ulogic; 
  signal combo3_1001_1000 :std_ulogic; 
  signal combo3_1001_1001 :std_ulogic; 
  signal combo3_1001_1010 :std_ulogic; 
  signal combo3_1001_1100 :std_ulogic; 
  signal combo3_1001_1101 :std_ulogic; 
  signal combo3_1001_1110 :std_ulogic; 
  signal combo3_1001_1111 :std_ulogic; 
  signal combo3_1010_0010 :std_ulogic; 
  signal combo3_1010_0100 :std_ulogic; 
  signal combo3_1010_0101 :std_ulogic; 
  signal combo3_1010_0110 :std_ulogic; 
  signal combo3_1010_0111 :std_ulogic; 
  signal combo3_1010_1010 :std_ulogic; 
  signal combo3_1010_1100 :std_ulogic; 
  signal combo3_1010_1101 :std_ulogic; 
  signal combo3_1010_1110 :std_ulogic; 
  signal combo3_1011_0011 :std_ulogic; 
  signal combo3_1011_0110 :std_ulogic; 
  signal combo3_1011_0111 :std_ulogic; 
  signal combo3_1011_1000 :std_ulogic; 
  signal combo3_1011_1001 :std_ulogic; 
  signal combo3_1011_1010 :std_ulogic; 
  signal combo3_1011_1011 :std_ulogic; 
  signal combo3_1011_1110 :std_ulogic; 
  signal combo3_1100_0000 :std_ulogic; 
  signal combo3_1100_0001 :std_ulogic; 
  signal combo3_1100_0011 :std_ulogic; 
  signal combo3_1100_0110 :std_ulogic; 
  signal combo3_1100_0111 :std_ulogic; 
  signal combo3_1100_1010 :std_ulogic; 
  signal combo3_1100_1100 :std_ulogic; 
  signal combo3_1100_1110 :std_ulogic; 
  signal combo3_1101_0000 :std_ulogic; 
  signal combo3_1101_0011 :std_ulogic; 
  signal combo3_1101_0101 :std_ulogic; 
  signal combo3_1101_1000 :std_ulogic; 
  signal combo3_1101_1010 :std_ulogic; 
  signal combo3_1101_1011 :std_ulogic; 
  signal combo3_1101_1101 :std_ulogic; 
  signal combo3_1110_0000 :std_ulogic; 
  signal combo3_1110_0001 :std_ulogic; 
  signal combo3_1110_0010 :std_ulogic; 
  signal combo3_1110_0011 :std_ulogic; 
  signal combo3_1110_0100 :std_ulogic; 
  signal combo3_1110_0101 :std_ulogic; 
  signal combo3_1110_0110 :std_ulogic; 
  signal combo3_1110_1010 :std_ulogic; 
  signal combo3_1110_1011 :std_ulogic; 
  signal combo3_1111_0000 :std_ulogic; 
  signal combo3_1111_0011 :std_ulogic; 
  signal combo3_1111_0101 :std_ulogic; 
  signal combo3_1111_1000 :std_ulogic; 
  signal combo3_1111_1001 :std_ulogic; 
  signal combo3_1111_1011 :std_ulogic; 
  signal combo3_1111_1100 :std_ulogic; 
  signal combo3_1111_1110 :std_ulogic; 
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
    combo3_0000_0011 <= not(                        combo2_xxxx_0011_b );--i=3, 4 2
    combo3_0000_0100 <= not(                        combo2_xxxx_0100_b );--i=4, 1 3
    combo3_0000_1011 <= not(                        combo2_xxxx_1011_b );--i=11, 1 4
    combo3_0000_1100 <= not(                        combo2_xxxx_1100_b );--i=12, 1 5
    combo3_0000_1101 <= not(                        combo2_xxxx_1101_b );--i=13, 1 6
    combo3_0000_1111 <= not(                        not f(4)           );--i=15, 4 7
    combo3_0001_0001 <= not( not combo2_0001                           );--i=17, 1 8*
    combo3_0001_0010 <= not( combo2_0001_xxxx_b and combo2_xxxx_0010_b );--i=18, 1 9
    combo3_0001_0100 <= not( combo2_0001_xxxx_b and combo2_xxxx_0100_b );--i=20, 1 10
    combo3_0001_0101 <= not( combo2_0001_xxxx_b and combo2_xxxx_0101_b );--i=21, 2 11
    combo3_0001_0111 <= not( combo2_0001_xxxx_b and combo2_xxxx_0111_b );--i=23, 1 12
    combo3_0001_1000 <= not( combo2_0001_xxxx_b and combo2_xxxx_1000_b );--i=24, 1 13
    combo3_0001_1110 <= not( combo2_0001_xxxx_b and combo2_xxxx_1110_b );--i=30, 1 14
    combo3_0001_1111 <= not( combo2_0001_xxxx_b and not f(4)           );--i=31, 2 15
    combo3_0010_0001 <= not( combo2_0010_xxxx_b and combo2_xxxx_0001_b );--i=33, 1 16
    combo3_0010_0010 <= not( not combo2_0010                           );--i=34, 1 17*
    combo3_0010_0011 <= not( combo2_0010_xxxx_b and combo2_xxxx_0011_b );--i=35, 1 18
    combo3_0010_0100 <= not( combo2_0010_xxxx_b and combo2_xxxx_0100_b );--i=36, 1 19
    combo3_0010_0110 <= not( combo2_0010_xxxx_b and combo2_xxxx_0110_b );--i=38, 2 20
    combo3_0010_1001 <= not( combo2_0010_xxxx_b and combo2_xxxx_1001_b );--i=41, 2 21
    combo3_0010_1101 <= not( combo2_0010_xxxx_b and combo2_xxxx_1101_b );--i=45, 2 22
    combo3_0010_1110 <= not( combo2_0010_xxxx_b and combo2_xxxx_1110_b );--i=46, 1 23
    combo3_0011_0000 <= not( combo2_0011_xxxx_b                        );--i=48, 1 24
    combo3_0011_0001 <= not( combo2_0011_xxxx_b and combo2_xxxx_0001_b );--i=49, 3 25
    combo3_0011_0011 <= not( not combo2_0011                           );--i=51, 1 26*
    combo3_0011_0100 <= not( combo2_0011_xxxx_b and combo2_xxxx_0100_b );--i=52, 1 27
    combo3_0011_0101 <= not( combo2_0011_xxxx_b and combo2_xxxx_0101_b );--i=53, 1 28
    combo3_0011_1000 <= not( combo2_0011_xxxx_b and combo2_xxxx_1000_b );--i=56, 5 29
    combo3_0011_1001 <= not( combo2_0011_xxxx_b and combo2_xxxx_1001_b );--i=57, 4 30
    combo3_0011_1010 <= not( combo2_0011_xxxx_b and combo2_xxxx_1010_b );--i=58, 1 31
    combo3_0011_1100 <= not( combo2_0011_xxxx_b and combo2_xxxx_1100_b );--i=60, 2 32
    combo3_0011_1110 <= not( combo2_0011_xxxx_b and combo2_xxxx_1110_b );--i=62, 2 33
    combo3_0011_1111 <= not( combo2_0011_xxxx_b and not f(4)           );--i=63, 3 34
    combo3_0100_0000 <= not( combo2_0100_xxxx_b                        );--i=64, 1 35
    combo3_0100_0101 <= not( combo2_0100_xxxx_b and combo2_xxxx_0101_b );--i=69, 1 36
    combo3_0100_0110 <= not( combo2_0100_xxxx_b and combo2_xxxx_0110_b );--i=70, 1 37
    combo3_0100_1000 <= not( combo2_0100_xxxx_b and combo2_xxxx_1000_b );--i=72, 1 38
    combo3_0100_1001 <= not( combo2_0100_xxxx_b and combo2_xxxx_1001_b );--i=73, 1 39
    combo3_0100_1010 <= not( combo2_0100_xxxx_b and combo2_xxxx_1010_b );--i=74, 2 40
    combo3_0100_1100 <= not( combo2_0100_xxxx_b and combo2_xxxx_1100_b );--i=76, 1 41
    combo3_0100_1101 <= not( combo2_0100_xxxx_b and combo2_xxxx_1101_b );--i=77, 1 42
    combo3_0101_0000 <= not( combo2_0101_xxxx_b                        );--i=80, 1 43
    combo3_0101_0001 <= not( combo2_0101_xxxx_b and combo2_xxxx_0001_b );--i=81, 2 44
    combo3_0101_0011 <= not( combo2_0101_xxxx_b and combo2_xxxx_0011_b );--i=83, 1 45
    combo3_0101_0101 <= not( not combo2_0101                           );--i=85, 1 46*
    combo3_0101_0110 <= not( combo2_0101_xxxx_b and combo2_xxxx_0110_b );--i=86, 1 47
    combo3_0101_1001 <= not( combo2_0101_xxxx_b and combo2_xxxx_1001_b );--i=89, 1 48
    combo3_0101_1010 <= not( combo2_0101_xxxx_b and combo2_xxxx_1010_b );--i=90, 1 49
    combo3_0101_1110 <= not( combo2_0101_xxxx_b and combo2_xxxx_1110_b );--i=94, 1 50
    combo3_0101_1111 <= not( combo2_0101_xxxx_b and not f(4)           );--i=95, 1 51
    combo3_0110_0011 <= not( combo2_0110_xxxx_b and combo2_xxxx_0011_b );--i=99, 1 52
    combo3_0110_0110 <= not( not combo2_0110                           );--i=102, 2 53*
    combo3_0110_0111 <= not( combo2_0110_xxxx_b and combo2_xxxx_0111_b );--i=103, 1 54
    combo3_0110_1001 <= not( combo2_0110_xxxx_b and combo2_xxxx_1001_b );--i=105, 1 55
    combo3_0110_1010 <= not( combo2_0110_xxxx_b and combo2_xxxx_1010_b );--i=106, 1 56
    combo3_0110_1011 <= not( combo2_0110_xxxx_b and combo2_xxxx_1011_b );--i=107, 1 57
    combo3_0110_1100 <= not( combo2_0110_xxxx_b and combo2_xxxx_1100_b );--i=108, 1 58
    combo3_0110_1101 <= not( combo2_0110_xxxx_b and combo2_xxxx_1101_b );--i=109, 4 59
    combo3_0110_1110 <= not( combo2_0110_xxxx_b and combo2_xxxx_1110_b );--i=110, 1 60
    combo3_0110_1111 <= not( combo2_0110_xxxx_b and not f(4)           );--i=111, 1 61
    combo3_0111_0000 <= not( combo2_0111_xxxx_b                        );--i=112, 1 62
    combo3_0111_0010 <= not( combo2_0111_xxxx_b and combo2_xxxx_0010_b );--i=114, 3 63
    combo3_0111_0011 <= not( combo2_0111_xxxx_b and combo2_xxxx_0011_b );--i=115, 1 64
    combo3_0111_0110 <= not( combo2_0111_xxxx_b and combo2_xxxx_0110_b );--i=118, 1 65
    combo3_0111_1000 <= not( combo2_0111_xxxx_b and combo2_xxxx_1000_b );--i=120, 2 66
    combo3_0111_1001 <= not( combo2_0111_xxxx_b and combo2_xxxx_1001_b );--i=121, 1 67
    combo3_0111_1100 <= not( combo2_0111_xxxx_b and combo2_xxxx_1100_b );--i=124, 2 68
    combo3_0111_1110 <= not( combo2_0111_xxxx_b and combo2_xxxx_1110_b );--i=126, 1 69
    combo3_0111_1111 <= not( combo2_0111_xxxx_b and not f(4)           );--i=127, 3 70
    combo3_1000_0000 <= not( combo2_1000_xxxx_b                        );--i=128, 4 71
    combo3_1000_0001 <= not( combo2_1000_xxxx_b and combo2_xxxx_0001_b );--i=129, 1 72
    combo3_1000_0011 <= not( combo2_1000_xxxx_b and combo2_xxxx_0011_b );--i=131, 2 73
    combo3_1000_0110 <= not( combo2_1000_xxxx_b and combo2_xxxx_0110_b );--i=134, 1 74
    combo3_1000_1000 <= not( not combo2_1000                           );--i=136, 1 75*
    combo3_1000_1010 <= not( combo2_1000_xxxx_b and combo2_xxxx_1010_b );--i=138, 2 76
    combo3_1000_1101 <= not( combo2_1000_xxxx_b and combo2_xxxx_1101_b );--i=141, 1 77
    combo3_1000_1110 <= not( combo2_1000_xxxx_b and combo2_xxxx_1110_b );--i=142, 1 78
    combo3_1000_1111 <= not( combo2_1000_xxxx_b and not f(4)           );--i=143, 1 79
    combo3_1001_0000 <= not( combo2_1001_xxxx_b                        );--i=144, 1 80
    combo3_1001_0010 <= not( combo2_1001_xxxx_b and combo2_xxxx_0010_b );--i=146, 2 81
    combo3_1001_0011 <= not( combo2_1001_xxxx_b and combo2_xxxx_0011_b );--i=147, 2 82
    combo3_1001_0100 <= not( combo2_1001_xxxx_b and combo2_xxxx_0100_b );--i=148, 2 83
    combo3_1001_0111 <= not( combo2_1001_xxxx_b and combo2_xxxx_0111_b );--i=151, 1 84
    combo3_1001_1000 <= not( combo2_1001_xxxx_b and combo2_xxxx_1000_b );--i=152, 1 85
    combo3_1001_1001 <= not( not combo2_1001                           );--i=153, 3 86*
    combo3_1001_1010 <= not( combo2_1001_xxxx_b and combo2_xxxx_1010_b );--i=154, 2 87
    combo3_1001_1100 <= not( combo2_1001_xxxx_b and combo2_xxxx_1100_b );--i=156, 2 88
    combo3_1001_1101 <= not( combo2_1001_xxxx_b and combo2_xxxx_1101_b );--i=157, 1 89
    combo3_1001_1110 <= not( combo2_1001_xxxx_b and combo2_xxxx_1110_b );--i=158, 1 90
    combo3_1001_1111 <= not( combo2_1001_xxxx_b and not f(4)           );--i=159, 1 91
    combo3_1010_0010 <= not( combo2_1010_xxxx_b and combo2_xxxx_0010_b );--i=162, 1 92
    combo3_1010_0100 <= not( combo2_1010_xxxx_b and combo2_xxxx_0100_b );--i=164, 2 93
    combo3_1010_0101 <= not( combo2_1010_xxxx_b and combo2_xxxx_0101_b );--i=165, 1 94
    combo3_1010_0110 <= not( combo2_1010_xxxx_b and combo2_xxxx_0110_b );--i=166, 1 95
    combo3_1010_0111 <= not( combo2_1010_xxxx_b and combo2_xxxx_0111_b );--i=167, 2 96
    combo3_1010_1010 <= not( not combo2_1010                           );--i=170, 2 97*
    combo3_1010_1100 <= not( combo2_1010_xxxx_b and combo2_xxxx_1100_b );--i=172, 1 98
    combo3_1010_1101 <= not( combo2_1010_xxxx_b and combo2_xxxx_1101_b );--i=173, 1 99
    combo3_1010_1110 <= not( combo2_1010_xxxx_b and combo2_xxxx_1110_b );--i=174, 1 100
    combo3_1011_0011 <= not( combo2_1011_xxxx_b and combo2_xxxx_0011_b );--i=179, 1 101
    combo3_1011_0110 <= not( combo2_1011_xxxx_b and combo2_xxxx_0110_b );--i=182, 2 102
    combo3_1011_0111 <= not( combo2_1011_xxxx_b and combo2_xxxx_0111_b );--i=183, 1 103
    combo3_1011_1000 <= not( combo2_1011_xxxx_b and combo2_xxxx_1000_b );--i=184, 1 104
    combo3_1011_1001 <= not( combo2_1011_xxxx_b and combo2_xxxx_1001_b );--i=185, 1 105
    combo3_1011_1010 <= not( combo2_1011_xxxx_b and combo2_xxxx_1010_b );--i=186, 1 106
    combo3_1011_1011 <= not( not combo2_1011                           );--i=187, 2 107*
    combo3_1011_1110 <= not( combo2_1011_xxxx_b and combo2_xxxx_1110_b );--i=190, 2 108
    combo3_1100_0000 <= not( combo2_1100_xxxx_b                        );--i=192, 3 109
    combo3_1100_0001 <= not( combo2_1100_xxxx_b and combo2_xxxx_0001_b );--i=193, 1 110
    combo3_1100_0011 <= not( combo2_1100_xxxx_b and combo2_xxxx_0011_b );--i=195, 2 111
    combo3_1100_0110 <= not( combo2_1100_xxxx_b and combo2_xxxx_0110_b );--i=198, 1 112
    combo3_1100_0111 <= not( combo2_1100_xxxx_b and combo2_xxxx_0111_b );--i=199, 2 113
    combo3_1100_1010 <= not( combo2_1100_xxxx_b and combo2_xxxx_1010_b );--i=202, 2 114
    combo3_1100_1100 <= not( not combo2_1100                           );--i=204, 2 115*
    combo3_1100_1110 <= not( combo2_1100_xxxx_b and combo2_xxxx_1110_b );--i=206, 1 116
    combo3_1101_0000 <= not( combo2_1101_xxxx_b                        );--i=208, 1 117
    combo3_1101_0011 <= not( combo2_1101_xxxx_b and combo2_xxxx_0011_b );--i=211, 2 118
    combo3_1101_0101 <= not( combo2_1101_xxxx_b and combo2_xxxx_0101_b );--i=213, 3 119
    combo3_1101_1000 <= not( combo2_1101_xxxx_b and combo2_xxxx_1000_b );--i=216, 1 120
    combo3_1101_1010 <= not( combo2_1101_xxxx_b and combo2_xxxx_1010_b );--i=218, 2 121
    combo3_1101_1011 <= not( combo2_1101_xxxx_b and combo2_xxxx_1011_b );--i=219, 1 122
    combo3_1101_1101 <= not( not combo2_1101                           );--i=221, 1 123*
    combo3_1110_0000 <= not( combo2_1110_xxxx_b                        );--i=224, 1 124
    combo3_1110_0001 <= not( combo2_1110_xxxx_b and combo2_xxxx_0001_b );--i=225, 1 125
    combo3_1110_0010 <= not( combo2_1110_xxxx_b and combo2_xxxx_0010_b );--i=226, 1 126
    combo3_1110_0011 <= not( combo2_1110_xxxx_b and combo2_xxxx_0011_b );--i=227, 4 127
    combo3_1110_0100 <= not( combo2_1110_xxxx_b and combo2_xxxx_0100_b );--i=228, 1 128
    combo3_1110_0101 <= not( combo2_1110_xxxx_b and combo2_xxxx_0101_b );--i=229, 1 129
    combo3_1110_0110 <= not( combo2_1110_xxxx_b and combo2_xxxx_0110_b );--i=230, 2 130
    combo3_1110_1010 <= not( combo2_1110_xxxx_b and combo2_xxxx_1010_b );--i=234, 1 131
    combo3_1110_1011 <= not( combo2_1110_xxxx_b and combo2_xxxx_1011_b );--i=235, 1 132
    combo3_1111_0000 <= not(     f(4)                                  );--i=240, 4 133
    combo3_1111_0011 <= not(     f(4)           and combo2_xxxx_0011_b );--i=243, 2 134
    combo3_1111_0101 <= not(     f(4)           and combo2_xxxx_0101_b );--i=245, 1 135
    combo3_1111_1000 <= not(     f(4)           and combo2_xxxx_1000_b );--i=248, 2 136
    combo3_1111_1001 <= not(     f(4)           and combo2_xxxx_1001_b );--i=249, 1 137
    combo3_1111_1011 <= not(     f(4)           and combo2_xxxx_1011_b );--i=251, 1 138
    combo3_1111_1100 <= not(     f(4)           and combo2_xxxx_1100_b );--i=252, 4 139
    combo3_1111_1110 <= not(     f(4)           and combo2_xxxx_1110_b );--i=254, 2 140


--//#######################################
--//## ESTIMATE VECTORs
--//#######################################

    e_00_b(0) <= not( dcd_000 and tiup );
    e_00_b(1) <= not( dcd_001 and tiup );
    e_00_b(2) <= not( dcd_010 and tiup );
    e_00_b(3) <= not( dcd_011 and tiup );
    e_00_b(4) <= not( dcd_100 and tiup );
    e_00_b(5) <= not( dcd_101 and tiup );
    e_00_b(6) <= not( dcd_110 and combo3_1100_0000 );
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
    e_01_b(2) <= not( dcd_010 and combo3_1111_0000 );
    e_01_b(3) <= not( dcd_011 and tidn );
    e_01_b(4) <= not( dcd_100 and tidn );
    e_01_b(5) <= not( dcd_101 and tidn );
    e_01_b(6) <= not( dcd_110 and combo3_0011_1111 );
    e_01_b(7) <= not( dcd_111 and tiup );

    e( 1) <= not( e_01_b(0) and  
                  e_01_b(1) and  
                  e_01_b(2) and  
                  e_01_b(3) and  
                  e_01_b(4) and  
                  e_01_b(5) and  
                  e_01_b(6) and  
                  e_01_b(7)  );  

    e_02_b(0) <= not( dcd_000 and tiup );
    e_02_b(1) <= not( dcd_001 and combo3_1000_0000 );
    e_02_b(2) <= not( dcd_010 and combo3_0000_1111 );
    e_02_b(3) <= not( dcd_011 and tiup );
    e_02_b(4) <= not( dcd_100 and combo3_1000_0000 );
    e_02_b(5) <= not( dcd_101 and tidn );
    e_02_b(6) <= not( dcd_110 and combo3_0011_1111 );
    e_02_b(7) <= not( dcd_111 and tiup );

    e( 2) <= not( e_02_b(0) and  
                  e_02_b(1) and  
                  e_02_b(2) and  
                  e_02_b(3) and  
                  e_02_b(4) and  
                  e_02_b(5) and  
                  e_02_b(6) and  
                  e_02_b(7)  );  

    e_03_b(0) <= not( dcd_000 and combo3_1111_1000 );
    e_03_b(1) <= not( dcd_001 and combo3_0111_1100 );
    e_03_b(2) <= not( dcd_010 and combo3_0000_1111 );
    e_03_b(3) <= not( dcd_011 and combo3_1100_0000 );
    e_03_b(4) <= not( dcd_100 and combo3_0111_1111 );
    e_03_b(5) <= not( dcd_101 and combo3_1000_0000 );
    e_03_b(6) <= not( dcd_110 and combo3_0011_1111 );
    e_03_b(7) <= not( dcd_111 and combo3_1111_0000 );

    e( 3) <= not( e_03_b(0) and  
                  e_03_b(1) and  
                  e_03_b(2) and  
                  e_03_b(3) and  
                  e_03_b(4) and  
                  e_03_b(5) and  
                  e_03_b(6) and  
                  e_03_b(7)  );  

    e_04_b(0) <= not( dcd_000 and combo3_1110_0110 );
    e_04_b(1) <= not( dcd_001 and combo3_0111_0011 );
    e_04_b(2) <= not( dcd_010 and combo3_1000_1110 );
    e_04_b(3) <= not( dcd_011 and combo3_0011_1100 );
    e_04_b(4) <= not( dcd_100 and combo3_0111_1000 );
    e_04_b(5) <= not( dcd_101 and combo3_0111_1100 );
    e_04_b(6) <= not( dcd_110 and combo3_0011_1110 );
    e_04_b(7) <= not( dcd_111 and combo3_0000_1111 );

    e( 4) <= not( e_04_b(0) and  
                  e_04_b(1) and  
                  e_04_b(2) and  
                  e_04_b(3) and  
                  e_04_b(4) and  
                  e_04_b(5) and  
                  e_04_b(6) and  
                  e_04_b(7)  );  

    e_05_b(0) <= not( dcd_000 and combo3_1101_0101 );
    e_05_b(1) <= not( dcd_001 and combo3_0110_1011 );
    e_05_b(2) <= not( dcd_010 and combo3_0110_1101 );
    e_05_b(3) <= not( dcd_011 and combo3_1011_0011 );
    e_05_b(4) <= not( dcd_100 and combo3_0110_0110 );
    e_05_b(5) <= not( dcd_101 and combo3_0110_0011 );
    e_05_b(6) <= not( dcd_110 and combo3_0011_1001 );
    e_05_b(7) <= not( dcd_111 and combo3_1100_1110 );

    e( 5) <= not( e_05_b(0) and  
                  e_05_b(1) and  
                  e_05_b(2) and  
                  e_05_b(3) and  
                  e_05_b(4) and  
                  e_05_b(5) and  
                  e_05_b(6) and  
                  e_05_b(7)  );  

    e_06_b(0) <= not( dcd_000 and combo3_1000_0001 );
    e_06_b(1) <= not( dcd_001 and combo3_1100_0110 );
    e_06_b(2) <= not( dcd_010 and combo3_0100_1001 );
    e_06_b(3) <= not( dcd_011 and combo3_0110_1010 );
    e_06_b(4) <= not( dcd_100 and combo3_1101_0101 );
    e_06_b(5) <= not( dcd_101 and combo3_0101_1010 );
    e_06_b(6) <= not( dcd_110 and combo3_1010_0101 );
    e_06_b(7) <= not( dcd_111 and combo3_0010_1101 );

    e( 6) <= not( e_06_b(0) and  
                  e_06_b(1) and  
                  e_06_b(2) and  
                  e_06_b(3) and  
                  e_06_b(4) and  
                  e_06_b(5) and  
                  e_06_b(6) and  
                  e_06_b(7)  );  

    e_07_b(0) <= not( dcd_000 and combo3_1000_0110 );
    e_07_b(1) <= not( dcd_001 and combo3_0100_1010 );
    e_07_b(2) <= not( dcd_010 and combo3_1101_0011 );
    e_07_b(3) <= not( dcd_011 and combo3_0011_1000 );
    e_07_b(4) <= not( dcd_100 and combo3_0111_1111 );
    e_07_b(5) <= not( dcd_101 and combo3_1111_0000 );
    e_07_b(6) <= not( dcd_110 and combo3_1111_0011 );
    e_07_b(7) <= not( dcd_111 and combo3_1001_1001 );

    e( 7) <= not( e_07_b(0) and  
                  e_07_b(1) and  
                  e_07_b(2) and  
                  e_07_b(3) and  
                  e_07_b(4) and  
                  e_07_b(5) and  
                  e_07_b(6) and  
                  e_07_b(7)  );  

    e_08_b(0) <= not( dcd_000 and combo3_1000_1010 );
    e_08_b(1) <= not( dcd_001 and combo3_1001_1111 );
    e_08_b(2) <= not( dcd_010 and combo3_1001_1010 );
    e_08_b(3) <= not( dcd_011 and combo3_1010_0100 );
    e_08_b(4) <= not( dcd_100 and combo3_0111_1111 );
    e_08_b(5) <= not( dcd_101 and combo3_1111_0011 );
    e_08_b(6) <= not( dcd_110 and combo3_0011_0100 );
    e_08_b(7) <= not( dcd_111 and combo3_1010_1010 );

    e( 8) <= not( e_08_b(0) and  
                  e_08_b(1) and  
                  e_08_b(2) and  
                  e_08_b(3) and  
                  e_08_b(4) and  
                  e_08_b(5) and  
                  e_08_b(6) and  
                  e_08_b(7)  );  

    e_09_b(0) <= not( dcd_000 and combo3_1001_0000 );
    e_09_b(1) <= not( dcd_001 and combo3_0101_1111 );
    e_09_b(2) <= not( dcd_010 and combo3_1010_1100 );
    e_09_b(3) <= not( dcd_011 and combo3_0001_0010 );
    e_09_b(4) <= not( dcd_100 and combo3_0100_0000 );
    e_09_b(5) <= not( dcd_101 and combo3_0011_0101 );
    e_09_b(6) <= not( dcd_110 and combo3_0101_1001 );
    e_09_b(7) <= not( dcd_111 and tiup );

    e( 9) <= not( e_09_b(0) and  
                  e_09_b(1) and  
                  e_09_b(2) and  
                  e_09_b(3) and  
                  e_09_b(4) and  
                  e_09_b(5) and  
                  e_09_b(6) and  
                  e_09_b(7)  );  

    e_10_b(0) <= not( dcd_000 and combo3_1011_1000 );
    e_10_b(1) <= not( dcd_001 and combo3_1111_0000 );
    e_10_b(2) <= not( dcd_010 and combo3_1000_1010 );
    e_10_b(3) <= not( dcd_011 and combo3_0110_0111 );
    e_10_b(4) <= not( dcd_100 and combo3_0011_0000 );
    e_10_b(5) <= not( dcd_101 and combo3_1101_0000 );
    e_10_b(6) <= not( dcd_110 and combo3_0001_0101 );
    e_10_b(7) <= not( dcd_111 and combo3_1000_0011 );

    e(10) <= not( e_10_b(0) and  
                  e_10_b(1) and  
                  e_10_b(2) and  
                  e_10_b(3) and  
                  e_10_b(4) and  
                  e_10_b(5) and  
                  e_10_b(6) and  
                  e_10_b(7)  );  

    e_11_b(0) <= not( dcd_000 and combo3_1000_1101 );
    e_11_b(1) <= not( dcd_001 and combo3_1001_1001 );
    e_11_b(2) <= not( dcd_010 and combo3_0101_0001 );
    e_11_b(3) <= not( dcd_011 and combo3_1011_0111 );
    e_11_b(4) <= not( dcd_100 and combo3_0110_1001 );
    e_11_b(5) <= not( dcd_101 and combo3_0111_1000 );
    e_11_b(6) <= not( dcd_110 and combo3_0011_0001 );
    e_11_b(7) <= not( dcd_111 and combo3_0110_1101 );

    e(11) <= not( e_11_b(0) and  
                  e_11_b(1) and  
                  e_11_b(2) and  
                  e_11_b(3) and  
                  e_11_b(4) and  
                  e_11_b(5) and  
                  e_11_b(6) and  
                  e_11_b(7)  );  

    e_12_b(0) <= not( dcd_000 and combo3_1010_0010 );
    e_12_b(1) <= not( dcd_001 and tidn );
    e_12_b(2) <= not( dcd_010 and combo3_1110_0011 );
    e_12_b(3) <= not( dcd_011 and combo3_1111_0101 );
    e_12_b(4) <= not( dcd_100 and combo3_0110_0110 );
    e_12_b(5) <= not( dcd_101 and combo3_0000_1100 );
    e_12_b(6) <= not( dcd_110 and combo3_0110_1110 );
    e_12_b(7) <= not( dcd_111 and combo3_0101_0000 );

    e(12) <= not( e_12_b(0) and  
                  e_12_b(1) and  
                  e_12_b(2) and  
                  e_12_b(3) and  
                  e_12_b(4) and  
                  e_12_b(5) and  
                  e_12_b(6) and  
                  e_12_b(7)  );  

    e_13_b(0) <= not( dcd_000 and combo3_1100_0111 );
    e_13_b(1) <= not( dcd_001 and combo3_0000_0100 );
    e_13_b(2) <= not( dcd_010 and combo3_1011_1001 );
    e_13_b(3) <= not( dcd_011 and combo3_1011_1010 );
    e_13_b(4) <= not( dcd_100 and combo3_1111_1110 );
    e_13_b(5) <= not( dcd_101 and combo3_0101_1110 );
    e_13_b(6) <= not( dcd_110 and combo3_1110_0011 );
    e_13_b(7) <= not( dcd_111 and combo3_1001_0100 );

    e(13) <= not( e_13_b(0) and  
                  e_13_b(1) and  
                  e_13_b(2) and  
                  e_13_b(3) and  
                  e_13_b(4) and  
                  e_13_b(5) and  
                  e_13_b(6) and  
                  e_13_b(7)  );  

    e_14_b(0) <= not( dcd_000 and combo3_0111_1001 );
    e_14_b(1) <= not( dcd_001 and combo3_1111_1011 );
    e_14_b(2) <= not( dcd_010 and combo3_1010_0111 );
    e_14_b(3) <= not( dcd_011 and combo3_1000_0000 );
    e_14_b(4) <= not( dcd_100 and combo3_1110_0001 );
    e_14_b(5) <= not( dcd_101 and combo3_0110_1101 );
    e_14_b(6) <= not( dcd_110 and combo3_0000_0001 );
    e_14_b(7) <= not( dcd_111 and combo3_0001_0111 );

    e(14) <= not( e_14_b(0) and  
                  e_14_b(1) and  
                  e_14_b(2) and  
                  e_14_b(3) and  
                  e_14_b(4) and  
                  e_14_b(5) and  
                  e_14_b(6) and  
                  e_14_b(7)  );  

    e_15_b(0) <= not( dcd_000 and combo3_0101_0101 );
    e_15_b(1) <= not( dcd_001 and combo3_1001_1010 );
    e_15_b(2) <= not( dcd_010 and combo3_0010_1001 );
    e_15_b(3) <= not( dcd_011 and combo3_0010_1001 );
    e_15_b(4) <= not( dcd_100 and combo3_1001_1101 );
    e_15_b(5) <= not( dcd_101 and combo3_1001_1110 );
    e_15_b(6) <= not( dcd_110 and combo3_1100_1010 );
    e_15_b(7) <= not( dcd_111 and combo3_1110_0100 );

    e(15) <= not( e_15_b(0) and  
                  e_15_b(1) and  
                  e_15_b(2) and  
                  e_15_b(3) and  
                  e_15_b(4) and  
                  e_15_b(5) and  
                  e_15_b(6) and  
                  e_15_b(7)  );  

    e_16_b(0) <= not( dcd_000 and combo3_0111_1110 );
    e_16_b(1) <= not( dcd_001 and combo3_1100_1010 );
    e_16_b(2) <= not( dcd_010 and combo3_0010_0010 );
    e_16_b(3) <= not( dcd_011 and combo3_1111_1001 );
    e_16_b(4) <= not( dcd_100 and combo3_1101_1000 );
    e_16_b(5) <= not( dcd_101 and combo3_0111_0010 );
    e_16_b(6) <= not( dcd_110 and combo3_0100_1101 );
    e_16_b(7) <= not( dcd_111 and combo3_0011_1010 );

    e(16) <= not( e_16_b(0) and  
                  e_16_b(1) and  
                  e_16_b(2) and  
                  e_16_b(3) and  
                  e_16_b(4) and  
                  e_16_b(5) and  
                  e_16_b(6) and  
                  e_16_b(7)  );  

    e_17_b(0) <= not( dcd_000 and combo3_0111_0010 );
    e_17_b(1) <= not( dcd_001 and combo3_1010_1110 );
    e_17_b(2) <= not( dcd_010 and combo3_1110_0010 );
    e_17_b(3) <= not( dcd_011 and combo3_0100_0110 );
    e_17_b(4) <= not( dcd_100 and combo3_1101_0011 );
    e_17_b(5) <= not( dcd_101 and combo3_1000_1111 );
    e_17_b(6) <= not( dcd_110 and combo3_0000_1101 );
    e_17_b(7) <= not( dcd_111 and combo3_1001_1100 );

    e(17) <= not( e_17_b(0) and  
                  e_17_b(1) and  
                  e_17_b(2) and  
                  e_17_b(3) and  
                  e_17_b(4) and  
                  e_17_b(5) and  
                  e_17_b(6) and  
                  e_17_b(7)  );  

    e_18_b(0) <= not( dcd_000 and combo3_0001_0100 );
    e_18_b(1) <= not( dcd_001 and combo3_0011_1000 );
    e_18_b(2) <= not( dcd_010 and combo3_0101_0001 );
    e_18_b(3) <= not( dcd_011 and combo3_0001_0001 );
    e_18_b(4) <= not( dcd_100 and combo3_0010_0110 );
    e_18_b(5) <= not( dcd_101 and combo3_0011_0001 );
    e_18_b(6) <= not( dcd_110 and combo3_0111_0110 );
    e_18_b(7) <= not( dcd_111 and combo3_1001_1100 );

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
    r_01_b(2) <= not( dcd_010 and tiup );
    r_01_b(3) <= not( dcd_011 and tiup );
    r_01_b(4) <= not( dcd_100 and combo3_1111_1100 );
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

    r_02_b(0) <= not( dcd_000 and tiup );
    r_02_b(1) <= not( dcd_001 and combo3_1111_1100 );
    r_02_b(2) <= not( dcd_010 and tidn );
    r_02_b(3) <= not( dcd_011 and tidn );
    r_02_b(4) <= not( dcd_100 and combo3_0000_0011 );
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

    r_03_b(0) <= not( dcd_000 and combo3_1111_1100 );
    r_03_b(1) <= not( dcd_001 and combo3_0000_0011 );
    r_03_b(2) <= not( dcd_010 and tiup );
    r_03_b(3) <= not( dcd_011 and tidn );
    r_03_b(4) <= not( dcd_100 and combo3_0000_0011 );
    r_03_b(5) <= not( dcd_101 and tiup );
    r_03_b(6) <= not( dcd_110 and tiup );
    r_03_b(7) <= not( dcd_111 and combo3_1110_0000 );

    r( 3) <= not( r_03_b(0) and  
                  r_03_b(1) and  
                  r_03_b(2) and  
                  r_03_b(3) and  
                  r_03_b(4) and  
                  r_03_b(5) and  
                  r_03_b(6) and  
                  r_03_b(7)  );  

    r_04_b(0) <= not( dcd_000 and combo3_1110_0011 );
    r_04_b(1) <= not( dcd_001 and combo3_1100_0011 );
    r_04_b(2) <= not( dcd_010 and combo3_1100_0000 );
    r_04_b(3) <= not( dcd_011 and combo3_1111_1100 );
    r_04_b(4) <= not( dcd_100 and combo3_0000_0011 );
    r_04_b(5) <= not( dcd_101 and combo3_1111_1110 );
    r_04_b(6) <= not( dcd_110 and tidn );
    r_04_b(7) <= not( dcd_111 and combo3_0001_1111 );

    r( 4) <= not( r_04_b(0) and  
                  r_04_b(1) and  
                  r_04_b(2) and  
                  r_04_b(3) and  
                  r_04_b(4) and  
                  r_04_b(5) and  
                  r_04_b(6) and  
                  r_04_b(7)  );  

    r_05_b(0) <= not( dcd_000 and combo3_1001_0011 );
    r_05_b(1) <= not( dcd_001 and combo3_0010_0011 );
    r_05_b(2) <= not( dcd_010 and combo3_0011_1000 );
    r_05_b(3) <= not( dcd_011 and combo3_1110_0011 );
    r_05_b(4) <= not( dcd_100 and combo3_1100_0011 );
    r_05_b(5) <= not( dcd_101 and combo3_1100_0001 );
    r_05_b(6) <= not( dcd_110 and combo3_1111_1000 );
    r_05_b(7) <= not( dcd_111 and combo3_0001_1111 );

    r( 5) <= not( r_05_b(0) and  
                  r_05_b(1) and  
                  r_05_b(2) and  
                  r_05_b(3) and  
                  r_05_b(4) and  
                  r_05_b(5) and  
                  r_05_b(6) and  
                  r_05_b(7)  );  

    r_06_b(0) <= not( dcd_000 and combo3_1101_1010 );
    r_06_b(1) <= not( dcd_001 and combo3_1001_0010 );
    r_06_b(2) <= not( dcd_010 and combo3_1010_0100 );
    r_06_b(3) <= not( dcd_011 and combo3_1001_0011 );
    r_06_b(4) <= not( dcd_100 and combo3_0011_0011 );
    r_06_b(5) <= not( dcd_101 and combo3_0011_0001 );
    r_06_b(6) <= not( dcd_110 and combo3_1100_0111 );
    r_06_b(7) <= not( dcd_111 and combo3_0001_1110 );

    r( 6) <= not( r_06_b(0) and  
                  r_06_b(1) and  
                  r_06_b(2) and  
                  r_06_b(3) and  
                  r_06_b(4) and  
                  r_06_b(5) and  
                  r_06_b(6) and  
                  r_06_b(7)  );  

    r_07_b(0) <= not( dcd_000 and combo3_0100_1100 );
    r_07_b(1) <= not( dcd_001 and combo3_0011_1000 );
    r_07_b(2) <= not( dcd_010 and combo3_0111_0010 );
    r_07_b(3) <= not( dcd_011 and combo3_0100_1010 );
    r_07_b(4) <= not( dcd_100 and combo3_1010_1010 );
    r_07_b(5) <= not( dcd_101 and combo3_1010_1101 );
    r_07_b(6) <= not( dcd_110 and combo3_0010_0100 );
    r_07_b(7) <= not( dcd_111 and combo3_1001_1001 );

    r( 7) <= not( r_07_b(0) and  
                  r_07_b(1) and  
                  r_07_b(2) and  
                  r_07_b(3) and  
                  r_07_b(4) and  
                  r_07_b(5) and  
                  r_07_b(6) and  
                  r_07_b(7)  );  

    r_08_b(0) <= not( dcd_000 and combo3_1110_1010 );
    r_08_b(1) <= not( dcd_001 and combo3_0011_1000 );
    r_08_b(2) <= not( dcd_010 and combo3_1001_0100 );
    r_08_b(3) <= not( dcd_011 and combo3_1001_1000 );
    r_08_b(4) <= not( dcd_100 and tidn );
    r_08_b(5) <= not( dcd_101 and combo3_0011_1001 );
    r_08_b(6) <= not( dcd_110 and combo3_1001_0010 );
    r_08_b(7) <= not( dcd_111 and combo3_1101_0101 );

    r( 8) <= not( r_08_b(0) and  
                  r_08_b(1) and  
                  r_08_b(2) and  
                  r_08_b(3) and  
                  r_08_b(4) and  
                  r_08_b(5) and  
                  r_08_b(6) and  
                  r_08_b(7)  );  

    r_09_b(0) <= not( dcd_000 and combo3_0010_0001 );
    r_09_b(1) <= not( dcd_001 and combo3_0011_1001 );
    r_09_b(2) <= not( dcd_010 and combo3_0011_1110 );
    r_09_b(3) <= not( dcd_011 and combo3_0101_0110 );
    r_09_b(4) <= not( dcd_100 and tidn );
    r_09_b(5) <= not( dcd_101 and combo3_1101_1010 );
    r_09_b(6) <= not( dcd_110 and combo3_1011_0110 );
    r_09_b(7) <= not( dcd_111 and combo3_0111_0000 );

    r( 9) <= not( r_09_b(0) and  
                  r_09_b(1) and  
                  r_09_b(2) and  
                  r_09_b(3) and  
                  r_09_b(4) and  
                  r_09_b(5) and  
                  r_09_b(6) and  
                  r_09_b(7)  );  

    r_10_b(0) <= not( dcd_000 and combo3_0101_0011 );
    r_10_b(1) <= not( dcd_001 and combo3_1011_1011 );
    r_10_b(2) <= not( dcd_010 and combo3_1011_0110 );
    r_10_b(3) <= not( dcd_011 and combo3_1101_1101 );
    r_10_b(4) <= not( dcd_100 and combo3_1000_0011 );
    r_10_b(5) <= not( dcd_101 and combo3_0110_1111 );
    r_10_b(6) <= not( dcd_110 and combo3_1110_0101 );
    r_10_b(7) <= not( dcd_111 and combo3_0100_1000 );

    r(10) <= not( r_10_b(0) and  
                  r_10_b(1) and  
                  r_10_b(2) and  
                  r_10_b(3) and  
                  r_10_b(4) and  
                  r_10_b(5) and  
                  r_10_b(6) and  
                  r_10_b(7)  );  

    r_11_b(0) <= not( dcd_000 and combo3_0010_1110 );
    r_11_b(1) <= not( dcd_001 and combo3_0000_1011 );
    r_11_b(2) <= not( dcd_010 and combo3_1110_1011 );
    r_11_b(3) <= not( dcd_011 and combo3_1010_0111 );
    r_11_b(4) <= not( dcd_100 and combo3_0100_0101 );
    r_11_b(5) <= not( dcd_101 and combo3_1100_1100 );
    r_11_b(6) <= not( dcd_110 and combo3_0110_1100 );
    r_11_b(7) <= not( dcd_111 and combo3_0010_0110 );

    r(11) <= not( r_11_b(0) and  
                  r_11_b(1) and  
                  r_11_b(2) and  
                  r_11_b(3) and  
                  r_11_b(4) and  
                  r_11_b(5) and  
                  r_11_b(6) and  
                  r_11_b(7)  );  

    r_12_b(0) <= not( dcd_000 and combo3_0011_1100 );
    r_12_b(1) <= not( dcd_001 and combo3_1010_0110 );
    r_12_b(2) <= not( dcd_010 and combo3_1000_1000 );
    r_12_b(3) <= not( dcd_011 and combo3_0010_1101 );
    r_12_b(4) <= not( dcd_100 and combo3_0011_1001 );
    r_12_b(5) <= not( dcd_101 and combo3_1101_1011 );
    r_12_b(6) <= not( dcd_110 and combo3_1011_1011 );
    r_12_b(7) <= not( dcd_111 and combo3_1100_1100 );

    r(12) <= not( r_12_b(0) and  
                  r_12_b(1) and  
                  r_12_b(2) and  
                  r_12_b(3) and  
                  r_12_b(4) and  
                  r_12_b(5) and  
                  r_12_b(6) and  
                  r_12_b(7)  );  

    r_13_b(0) <= not( dcd_000 and combo3_1001_0111 );
    r_13_b(1) <= not( dcd_001 and combo3_0001_0101 );
    r_13_b(2) <= not( dcd_010 and combo3_1011_1110 );
    r_13_b(3) <= not( dcd_011 and combo3_1110_0110 );
    r_13_b(4) <= not( dcd_100 and combo3_0000_1111 );
    r_13_b(5) <= not( dcd_101 and combo3_0001_1000 );
    r_13_b(6) <= not( dcd_110 and combo3_1011_1110 );
    r_13_b(7) <= not( dcd_111 and combo3_0110_1101 );

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


end; -- fuq_tblsqo ARCHITECTURE
