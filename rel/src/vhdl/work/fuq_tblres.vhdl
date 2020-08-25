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

-- 11111111111111000000 111111000000101 0
-- 11111000000110111001 111101000110110 1
-- 11110000011110000001 111011010010000 2
-- 11101001000011110001 111001100010010 3
-- 11100001110111011111 110111110111100 4
-- 11011010111000100001 110110010001100 5
-- 11010100000110010101 110100101111100 6
-- 11001101100000010111 110011010001110 7
-- 11000111000110000111 110001111000000 8
-- 11000000110111000111 110000100001100 9
-- 10111010110010111001 101111001110110 10
-- 10110100111001000001 101101111111010 11
-- 10101111001001000111 101100110010110 12
-- 10101001100010101111 101011101001010 13
-- 10100100000101100101 101010100010100 14
-- 10011110110001001111 101001011110100 15
-- 10011001100101011001 101000011101000 16
-- 10010100100001110001 100111011101110 17
-- 10001111100110000001 100110100001000 18
-- 10001010110001111001 100101100110010 19
-- 10000110000101000111 100100101101110 20
-- 10000001011111011001 100011110111000 21
-- 01111101000000011111 100011000010010 22
-- 01111000101000001101 100010001111010 23
-- 01110100010110010001 100001011110000 24
-- 01110000001010100001 100000101110100 25
-- 01101100000100101101 100000000000100 26
-- 01101000000100101001 011111010011110 27
-- 01100100001010001001 011110101000110 28
-- 01100000010101000001 011101111111000 29
-- 01011100100101001001 011101010110100 30
-- 01011000111010010011 011100101111100 31
-- 01010101010100010101 011100001001100 32
-- 01010001110011000111 011011100100110 33
-- 01001110010110100001 011011000001010 34
-- 01001010111110010111 011010011110100 35
-- 01000111101010100001 011001111101000 36
-- 01000100011010111001 011001011100100 37
-- 01000001001111010101 011000111100110 38
-- 00111110000111101101 011000011110000 39
-- 00111011000011111011 011000000000010 40
-- 00111000000011111001 010111100011010 41
-- 00110101000111011101 010111000111000 42
-- 00110010001110100011 010110101011110 43
-- 00101111011001000101 010110010001000 44
-- 00101100100110111011 010101110111010 45
-- 00101001111000000001 010101011110000 46
-- 00100111001100010001 010101000101100 47
-- 00100100100011100101 010100101101100 48
-- 00100001111101110111 010100010110010 49
-- 00011111011011000101 010011111111100 50
-- 00011100111011000111 010011101001100 51
-- 00011010011101111001 010011010100000 52
-- 00011000000011011001 010010111111000 53
-- 00010101101011011111 010010101010110 54
-- 00010011010110001001 010010010110110 55
-- 00010001000011010001 010010000011010 56
-- 00001110110010110101 010001110000100 57
-- 00001100100100110001 010001011110000 58
-- 00001010011001000001 010001001100000 59
-- 00001000001111100001 010000111010010 60
-- 00000110001000001101 010000101001000 61
-- 00000100000011000101 010000011000010 62
-- 00000010000000000001 010000001000000 63


 
entity fuq_tblres is
generic(   expand_type               : integer := 2  ); -- 0 - ibm tech, 1 - other );
port( 
       f    :in   std_ulogic_vector(1 to 6);
       est  :out  std_ulogic_vector(1 to 20);
       rng  :out  std_ulogic_vector(6 to 20)
       
); -- end ports
 
 
 
end fuq_tblres; -- ENTITY
 
 
architecture fuq_tblres of fuq_tblres is 
 
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
  signal combo3_0000_0010 :std_ulogic; 
  signal combo3_0000_0011 :std_ulogic; 
  signal combo3_0000_0100 :std_ulogic; 
  signal combo3_0000_0101 :std_ulogic; 
  signal combo3_0000_0110 :std_ulogic; 
  signal combo3_0000_1001 :std_ulogic; 
  signal combo3_0000_1010 :std_ulogic; 
  signal combo3_0000_1011 :std_ulogic; 
  signal combo3_0000_1110 :std_ulogic; 
  signal combo3_0000_1111 :std_ulogic; 
  signal combo3_0001_0001 :std_ulogic; 
  signal combo3_0001_0010 :std_ulogic; 
  signal combo3_0001_0100 :std_ulogic; 
  signal combo3_0001_0101 :std_ulogic; 
  signal combo3_0001_0111 :std_ulogic; 
  signal combo3_0001_1000 :std_ulogic; 
  signal combo3_0001_1010 :std_ulogic; 
  signal combo3_0001_1011 :std_ulogic; 
  signal combo3_0001_1100 :std_ulogic; 
  signal combo3_0001_1110 :std_ulogic; 
  signal combo3_0001_1111 :std_ulogic; 
  signal combo3_0010_0000 :std_ulogic; 
  signal combo3_0010_0100 :std_ulogic; 
  signal combo3_0010_0101 :std_ulogic; 
  signal combo3_0010_0110 :std_ulogic; 
  signal combo3_0010_0111 :std_ulogic; 
  signal combo3_0010_1000 :std_ulogic; 
  signal combo3_0010_1001 :std_ulogic; 
  signal combo3_0010_1101 :std_ulogic; 
  signal combo3_0011_0000 :std_ulogic; 
  signal combo3_0011_0001 :std_ulogic; 
  signal combo3_0011_0011 :std_ulogic; 
  signal combo3_0011_0101 :std_ulogic; 
  signal combo3_0011_1000 :std_ulogic; 
  signal combo3_0011_1001 :std_ulogic; 
  signal combo3_0011_1010 :std_ulogic; 
  signal combo3_0011_1011 :std_ulogic; 
  signal combo3_0011_1100 :std_ulogic; 
  signal combo3_0011_1110 :std_ulogic; 
  signal combo3_0011_1111 :std_ulogic; 
  signal combo3_0100_0000 :std_ulogic; 
  signal combo3_0100_0011 :std_ulogic; 
  signal combo3_0100_0110 :std_ulogic; 
  signal combo3_0100_1000 :std_ulogic; 
  signal combo3_0100_1001 :std_ulogic; 
  signal combo3_0100_1010 :std_ulogic; 
  signal combo3_0100_1100 :std_ulogic; 
  signal combo3_0100_1101 :std_ulogic; 
  signal combo3_0100_1110 :std_ulogic; 
  signal combo3_0101_0000 :std_ulogic; 
  signal combo3_0101_0001 :std_ulogic; 
  signal combo3_0101_0010 :std_ulogic; 
  signal combo3_0101_0100 :std_ulogic; 
  signal combo3_0101_0101 :std_ulogic; 
  signal combo3_0101_0110 :std_ulogic; 
  signal combo3_0101_1000 :std_ulogic; 
  signal combo3_0101_1011 :std_ulogic; 
  signal combo3_0101_1111 :std_ulogic; 
  signal combo3_0110_0000 :std_ulogic; 
  signal combo3_0110_0010 :std_ulogic; 
  signal combo3_0110_0011 :std_ulogic; 
  signal combo3_0110_0110 :std_ulogic; 
  signal combo3_0110_0111 :std_ulogic; 
  signal combo3_0110_1000 :std_ulogic; 
  signal combo3_0110_1010 :std_ulogic; 
  signal combo3_0110_1011 :std_ulogic; 
  signal combo3_0110_1100 :std_ulogic; 
  signal combo3_0110_1101 :std_ulogic; 
  signal combo3_0111_0000 :std_ulogic; 
  signal combo3_0111_0001 :std_ulogic; 
  signal combo3_0111_0101 :std_ulogic; 
  signal combo3_0111_0110 :std_ulogic; 
  signal combo3_0111_1000 :std_ulogic; 
  signal combo3_0111_1001 :std_ulogic; 
  signal combo3_0111_1010 :std_ulogic; 
  signal combo3_0111_1011 :std_ulogic; 
  signal combo3_0111_1101 :std_ulogic; 
  signal combo3_0111_1111 :std_ulogic; 
  signal combo3_1000_0000 :std_ulogic; 
  signal combo3_1000_0001 :std_ulogic; 
  signal combo3_1000_0011 :std_ulogic; 
  signal combo3_1000_0100 :std_ulogic; 
  signal combo3_1000_0101 :std_ulogic; 
  signal combo3_1000_1010 :std_ulogic; 
  signal combo3_1000_1100 :std_ulogic; 
  signal combo3_1000_1101 :std_ulogic; 
  signal combo3_1001_0100 :std_ulogic; 
  signal combo3_1001_0110 :std_ulogic; 
  signal combo3_1001_0111 :std_ulogic; 
  signal combo3_1001_1000 :std_ulogic; 
  signal combo3_1001_1001 :std_ulogic; 
  signal combo3_1001_1010 :std_ulogic; 
  signal combo3_1001_1011 :std_ulogic; 
  signal combo3_1001_1111 :std_ulogic; 
  signal combo3_1010_0100 :std_ulogic; 
  signal combo3_1010_0110 :std_ulogic; 
  signal combo3_1010_1000 :std_ulogic; 
  signal combo3_1010_1001 :std_ulogic; 
  signal combo3_1010_1010 :std_ulogic; 
  signal combo3_1010_1011 :std_ulogic; 
  signal combo3_1010_1100 :std_ulogic; 
  signal combo3_1010_1101 :std_ulogic; 
  signal combo3_1011_0010 :std_ulogic; 
  signal combo3_1011_0011 :std_ulogic; 
  signal combo3_1011_0100 :std_ulogic; 
  signal combo3_1011_0101 :std_ulogic; 
  signal combo3_1011_0110 :std_ulogic; 
  signal combo3_1011_0111 :std_ulogic; 
  signal combo3_1100_0000 :std_ulogic; 
  signal combo3_1100_0001 :std_ulogic; 
  signal combo3_1100_0010 :std_ulogic; 
  signal combo3_1100_0011 :std_ulogic; 
  signal combo3_1100_0100 :std_ulogic; 
  signal combo3_1100_0111 :std_ulogic; 
  signal combo3_1100_1000 :std_ulogic; 
  signal combo3_1100_1001 :std_ulogic; 
  signal combo3_1100_1010 :std_ulogic; 
  signal combo3_1100_1101 :std_ulogic; 
  signal combo3_1100_1110 :std_ulogic; 
  signal combo3_1100_1111 :std_ulogic; 
  signal combo3_1101_0010 :std_ulogic; 
  signal combo3_1101_0011 :std_ulogic; 
  signal combo3_1101_0100 :std_ulogic; 
  signal combo3_1101_0101 :std_ulogic; 
  signal combo3_1101_0110 :std_ulogic; 
  signal combo3_1101_0111 :std_ulogic; 
  signal combo3_1101_1100 :std_ulogic; 
  signal combo3_1101_1101 :std_ulogic; 
  signal combo3_1101_1110 :std_ulogic; 
  signal combo3_1110_0000 :std_ulogic; 
  signal combo3_1110_0100 :std_ulogic; 
  signal combo3_1110_0101 :std_ulogic; 
  signal combo3_1110_0110 :std_ulogic; 
  signal combo3_1110_1000 :std_ulogic; 
  signal combo3_1110_1010 :std_ulogic; 
  signal combo3_1110_1101 :std_ulogic; 
  signal combo3_1111_0000 :std_ulogic; 
  signal combo3_1111_0001 :std_ulogic; 
  signal combo3_1111_0010 :std_ulogic; 
  signal combo3_1111_0100 :std_ulogic; 
  signal combo3_1111_1000 :std_ulogic; 
  signal combo3_1111_1001 :std_ulogic; 
  signal combo3_1111_1010 :std_ulogic; 
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


    combo3_0000_0001 <= not(                        combo2_xxxx_0001_b );--i=1, 2 1
    combo3_0000_0010 <= not(                        combo2_xxxx_0010_b );--i=2, 1 2
    combo3_0000_0011 <= not(                        combo2_xxxx_0011_b );--i=3, 3 3
    combo3_0000_0100 <= not(                        combo2_xxxx_0100_b );--i=4, 1 4
    combo3_0000_0101 <= not(                        combo2_xxxx_0101_b );--i=5, 2 5
    combo3_0000_0110 <= not(                        combo2_xxxx_0110_b );--i=6, 2 6
    combo3_0000_1001 <= not(                        combo2_xxxx_1001_b );--i=9, 1 7
    combo3_0000_1010 <= not(                        combo2_xxxx_1010_b );--i=10, 2 8
    combo3_0000_1011 <= not(                        combo2_xxxx_1011_b );--i=11, 2 9
    combo3_0000_1110 <= not(                        combo2_xxxx_1110_b );--i=14, 1 10
    combo3_0000_1111 <= not(                        not f(4)           );--i=15, 2 11
    combo3_0001_0001 <= not( not combo2_0001                           );--i=17, 2 12*
    combo3_0001_0010 <= not( combo2_0001_xxxx_b and combo2_xxxx_0010_b );--i=18, 1 13
    combo3_0001_0100 <= not( combo2_0001_xxxx_b and combo2_xxxx_0100_b );--i=20, 1 14
    combo3_0001_0101 <= not( combo2_0001_xxxx_b and combo2_xxxx_0101_b );--i=21, 1 15
    combo3_0001_0111 <= not( combo2_0001_xxxx_b and combo2_xxxx_0111_b );--i=23, 1 16
    combo3_0001_1000 <= not( combo2_0001_xxxx_b and combo2_xxxx_1000_b );--i=24, 3 17
    combo3_0001_1010 <= not( combo2_0001_xxxx_b and combo2_xxxx_1010_b );--i=26, 1 18
    combo3_0001_1011 <= not( combo2_0001_xxxx_b and combo2_xxxx_1011_b );--i=27, 1 19
    combo3_0001_1100 <= not( combo2_0001_xxxx_b and combo2_xxxx_1100_b );--i=28, 1 20
    combo3_0001_1110 <= not( combo2_0001_xxxx_b and combo2_xxxx_1110_b );--i=30, 1 21
    combo3_0001_1111 <= not( combo2_0001_xxxx_b and not f(4)           );--i=31, 4 22
    combo3_0010_0000 <= not( combo2_0010_xxxx_b                        );--i=32, 2 23
    combo3_0010_0100 <= not( combo2_0010_xxxx_b and combo2_xxxx_0100_b );--i=36, 1 24
    combo3_0010_0101 <= not( combo2_0010_xxxx_b and combo2_xxxx_0101_b );--i=37, 1 25
    combo3_0010_0110 <= not( combo2_0010_xxxx_b and combo2_xxxx_0110_b );--i=38, 2 26
    combo3_0010_0111 <= not( combo2_0010_xxxx_b and combo2_xxxx_0111_b );--i=39, 1 27
    combo3_0010_1000 <= not( combo2_0010_xxxx_b and combo2_xxxx_1000_b );--i=40, 2 28
    combo3_0010_1001 <= not( combo2_0010_xxxx_b and combo2_xxxx_1001_b );--i=41, 1 29
    combo3_0010_1101 <= not( combo2_0010_xxxx_b and combo2_xxxx_1101_b );--i=45, 4 30
    combo3_0011_0000 <= not( combo2_0011_xxxx_b                        );--i=48, 1 31
    combo3_0011_0001 <= not( combo2_0011_xxxx_b and combo2_xxxx_0001_b );--i=49, 3 32
    combo3_0011_0011 <= not( not combo2_0011                           );--i=51, 1 33*
    combo3_0011_0101 <= not( combo2_0011_xxxx_b and combo2_xxxx_0101_b );--i=53, 1 34
    combo3_0011_1000 <= not( combo2_0011_xxxx_b and combo2_xxxx_1000_b );--i=56, 3 35
    combo3_0011_1001 <= not( combo2_0011_xxxx_b and combo2_xxxx_1001_b );--i=57, 1 36
    combo3_0011_1010 <= not( combo2_0011_xxxx_b and combo2_xxxx_1010_b );--i=58, 1 37
    combo3_0011_1011 <= not( combo2_0011_xxxx_b and combo2_xxxx_1011_b );--i=59, 1 38
    combo3_0011_1100 <= not( combo2_0011_xxxx_b and combo2_xxxx_1100_b );--i=60, 3 39
    combo3_0011_1110 <= not( combo2_0011_xxxx_b and combo2_xxxx_1110_b );--i=62, 1 40
    combo3_0011_1111 <= not( combo2_0011_xxxx_b and not f(4)           );--i=63, 4 41
    combo3_0100_0000 <= not( combo2_0100_xxxx_b                        );--i=64, 1 42
    combo3_0100_0011 <= not( combo2_0100_xxxx_b and combo2_xxxx_0011_b );--i=67, 2 43
    combo3_0100_0110 <= not( combo2_0100_xxxx_b and combo2_xxxx_0110_b );--i=70, 1 44
    combo3_0100_1000 <= not( combo2_0100_xxxx_b and combo2_xxxx_1000_b );--i=72, 2 45
    combo3_0100_1001 <= not( combo2_0100_xxxx_b and combo2_xxxx_1001_b );--i=73, 2 46
    combo3_0100_1010 <= not( combo2_0100_xxxx_b and combo2_xxxx_1010_b );--i=74, 2 47
    combo3_0100_1100 <= not( combo2_0100_xxxx_b and combo2_xxxx_1100_b );--i=76, 1 48
    combo3_0100_1101 <= not( combo2_0100_xxxx_b and combo2_xxxx_1101_b );--i=77, 1 49
    combo3_0100_1110 <= not( combo2_0100_xxxx_b and combo2_xxxx_1110_b );--i=78, 1 50
    combo3_0101_0000 <= not( combo2_0101_xxxx_b                        );--i=80, 3 51
    combo3_0101_0001 <= not( combo2_0101_xxxx_b and combo2_xxxx_0001_b );--i=81, 1 52
    combo3_0101_0010 <= not( combo2_0101_xxxx_b and combo2_xxxx_0010_b );--i=82, 1 53
    combo3_0101_0100 <= not( combo2_0101_xxxx_b and combo2_xxxx_0100_b );--i=84, 3 54
    combo3_0101_0101 <= not( not combo2_0101                           );--i=85, 1 55*
    combo3_0101_0110 <= not( combo2_0101_xxxx_b and combo2_xxxx_0110_b );--i=86, 1 56
    combo3_0101_1000 <= not( combo2_0101_xxxx_b and combo2_xxxx_1000_b );--i=88, 1 57
    combo3_0101_1011 <= not( combo2_0101_xxxx_b and combo2_xxxx_1011_b );--i=91, 3 58
    combo3_0101_1111 <= not( combo2_0101_xxxx_b and not f(4)           );--i=95, 1 59
    combo3_0110_0000 <= not( combo2_0110_xxxx_b                        );--i=96, 1 60
    combo3_0110_0010 <= not( combo2_0110_xxxx_b and combo2_xxxx_0010_b );--i=98, 1 61
    combo3_0110_0011 <= not( combo2_0110_xxxx_b and combo2_xxxx_0011_b );--i=99, 1 62
    combo3_0110_0110 <= not( not combo2_0110                           );--i=102, 1 63*
    combo3_0110_0111 <= not( combo2_0110_xxxx_b and combo2_xxxx_0111_b );--i=103, 3 64
    combo3_0110_1000 <= not( combo2_0110_xxxx_b and combo2_xxxx_1000_b );--i=104, 1 65
    combo3_0110_1010 <= not( combo2_0110_xxxx_b and combo2_xxxx_1010_b );--i=106, 2 66
    combo3_0110_1011 <= not( combo2_0110_xxxx_b and combo2_xxxx_1011_b );--i=107, 1 67
    combo3_0110_1100 <= not( combo2_0110_xxxx_b and combo2_xxxx_1100_b );--i=108, 1 68
    combo3_0110_1101 <= not( combo2_0110_xxxx_b and combo2_xxxx_1101_b );--i=109, 1 69
    combo3_0111_0000 <= not( combo2_0111_xxxx_b                        );--i=112, 3 70
    combo3_0111_0001 <= not( combo2_0111_xxxx_b and combo2_xxxx_0001_b );--i=113, 1 71
    combo3_0111_0101 <= not( combo2_0111_xxxx_b and combo2_xxxx_0101_b );--i=117, 1 72
    combo3_0111_0110 <= not( combo2_0111_xxxx_b and combo2_xxxx_0110_b );--i=118, 1 73
    combo3_0111_1000 <= not( combo2_0111_xxxx_b and combo2_xxxx_1000_b );--i=120, 3 74
    combo3_0111_1001 <= not( combo2_0111_xxxx_b and combo2_xxxx_1001_b );--i=121, 1 75
    combo3_0111_1010 <= not( combo2_0111_xxxx_b and combo2_xxxx_1010_b );--i=122, 2 76
    combo3_0111_1011 <= not( combo2_0111_xxxx_b and combo2_xxxx_1011_b );--i=123, 1 77
    combo3_0111_1101 <= not( combo2_0111_xxxx_b and combo2_xxxx_1101_b );--i=125, 1 78
    combo3_0111_1111 <= not( combo2_0111_xxxx_b and not f(4)           );--i=127, 3 79
    combo3_1000_0000 <= not( combo2_1000_xxxx_b                        );--i=128, 7 80
    combo3_1000_0001 <= not( combo2_1000_xxxx_b and combo2_xxxx_0001_b );--i=129, 1 81
    combo3_1000_0011 <= not( combo2_1000_xxxx_b and combo2_xxxx_0011_b );--i=131, 1 82
    combo3_1000_0100 <= not( combo2_1000_xxxx_b and combo2_xxxx_0100_b );--i=132, 2 83
    combo3_1000_0101 <= not( combo2_1000_xxxx_b and combo2_xxxx_0101_b );--i=133, 1 84
    combo3_1000_1010 <= not( combo2_1000_xxxx_b and combo2_xxxx_1010_b );--i=138, 1 85
    combo3_1000_1100 <= not( combo2_1000_xxxx_b and combo2_xxxx_1100_b );--i=140, 1 86
    combo3_1000_1101 <= not( combo2_1000_xxxx_b and combo2_xxxx_1101_b );--i=141, 1 87
    combo3_1001_0100 <= not( combo2_1001_xxxx_b and combo2_xxxx_0100_b );--i=148, 1 88
    combo3_1001_0110 <= not( combo2_1001_xxxx_b and combo2_xxxx_0110_b );--i=150, 3 89
    combo3_1001_0111 <= not( combo2_1001_xxxx_b and combo2_xxxx_0111_b );--i=151, 1 90
    combo3_1001_1000 <= not( combo2_1001_xxxx_b and combo2_xxxx_1000_b );--i=152, 1 91
    combo3_1001_1001 <= not( not combo2_1001                           );--i=153, 3 92*
    combo3_1001_1010 <= not( combo2_1001_xxxx_b and combo2_xxxx_1010_b );--i=154, 1 93
    combo3_1001_1011 <= not( combo2_1001_xxxx_b and combo2_xxxx_1011_b );--i=155, 1 94
    combo3_1001_1111 <= not( combo2_1001_xxxx_b and not f(4)           );--i=159, 1 95
    combo3_1010_0100 <= not( combo2_1010_xxxx_b and combo2_xxxx_0100_b );--i=164, 1 96
    combo3_1010_0110 <= not( combo2_1010_xxxx_b and combo2_xxxx_0110_b );--i=166, 1 97
    combo3_1010_1000 <= not( combo2_1010_xxxx_b and combo2_xxxx_1000_b );--i=168, 2 98
    combo3_1010_1001 <= not( combo2_1010_xxxx_b and combo2_xxxx_1001_b );--i=169, 1 99
    combo3_1010_1010 <= not( not combo2_1010                           );--i=170, 1 100*
    combo3_1010_1011 <= not( combo2_1010_xxxx_b and combo2_xxxx_1011_b );--i=171, 1 101
    combo3_1010_1100 <= not( combo2_1010_xxxx_b and combo2_xxxx_1100_b );--i=172, 2 102
    combo3_1010_1101 <= not( combo2_1010_xxxx_b and combo2_xxxx_1101_b );--i=173, 2 103
    combo3_1011_0010 <= not( combo2_1011_xxxx_b and combo2_xxxx_0010_b );--i=178, 1 104
    combo3_1011_0011 <= not( combo2_1011_xxxx_b and combo2_xxxx_0011_b );--i=179, 3 105
    combo3_1011_0100 <= not( combo2_1011_xxxx_b and combo2_xxxx_0100_b );--i=180, 1 106
    combo3_1011_0101 <= not( combo2_1011_xxxx_b and combo2_xxxx_0101_b );--i=181, 2 107
    combo3_1011_0110 <= not( combo2_1011_xxxx_b and combo2_xxxx_0110_b );--i=182, 3 108
    combo3_1011_0111 <= not( combo2_1011_xxxx_b and combo2_xxxx_0111_b );--i=183, 1 109
    combo3_1100_0000 <= not( combo2_1100_xxxx_b                        );--i=192, 4 110
    combo3_1100_0001 <= not( combo2_1100_xxxx_b and combo2_xxxx_0001_b );--i=193, 1 111
    combo3_1100_0010 <= not( combo2_1100_xxxx_b and combo2_xxxx_0010_b );--i=194, 1 112
    combo3_1100_0011 <= not( combo2_1100_xxxx_b and combo2_xxxx_0011_b );--i=195, 2 113
    combo3_1100_0100 <= not( combo2_1100_xxxx_b and combo2_xxxx_0100_b );--i=196, 1 114
    combo3_1100_0111 <= not( combo2_1100_xxxx_b and combo2_xxxx_0111_b );--i=199, 1 115
    combo3_1100_1000 <= not( combo2_1100_xxxx_b and combo2_xxxx_1000_b );--i=200, 1 116
    combo3_1100_1001 <= not( combo2_1100_xxxx_b and combo2_xxxx_1001_b );--i=201, 2 117
    combo3_1100_1010 <= not( combo2_1100_xxxx_b and combo2_xxxx_1010_b );--i=202, 2 118
    combo3_1100_1101 <= not( combo2_1100_xxxx_b and combo2_xxxx_1101_b );--i=205, 2 119
    combo3_1100_1110 <= not( combo2_1100_xxxx_b and combo2_xxxx_1110_b );--i=206, 2 120
    combo3_1100_1111 <= not( combo2_1100_xxxx_b and not f(4)           );--i=207, 2 121
    combo3_1101_0010 <= not( combo2_1101_xxxx_b and combo2_xxxx_0010_b );--i=210, 1 122
    combo3_1101_0011 <= not( combo2_1101_xxxx_b and combo2_xxxx_0011_b );--i=211, 1 123
    combo3_1101_0100 <= not( combo2_1101_xxxx_b and combo2_xxxx_0100_b );--i=212, 2 124
    combo3_1101_0101 <= not( combo2_1101_xxxx_b and combo2_xxxx_0101_b );--i=213, 1 125
    combo3_1101_0110 <= not( combo2_1101_xxxx_b and combo2_xxxx_0110_b );--i=214, 2 126
    combo3_1101_0111 <= not( combo2_1101_xxxx_b and combo2_xxxx_0111_b );--i=215, 1 127
    combo3_1101_1100 <= not( combo2_1101_xxxx_b and combo2_xxxx_1100_b );--i=220, 1 128
    combo3_1101_1101 <= not( not combo2_1101                           );--i=221, 1 129*
    combo3_1101_1110 <= not( combo2_1101_xxxx_b and combo2_xxxx_1110_b );--i=222, 1 130
    combo3_1110_0000 <= not( combo2_1110_xxxx_b                        );--i=224, 2 131
    combo3_1110_0100 <= not( combo2_1110_xxxx_b and combo2_xxxx_0100_b );--i=228, 2 132
    combo3_1110_0101 <= not( combo2_1110_xxxx_b and combo2_xxxx_0101_b );--i=229, 1 133
    combo3_1110_0110 <= not( combo2_1110_xxxx_b and combo2_xxxx_0110_b );--i=230, 1 134
    combo3_1110_1000 <= not( combo2_1110_xxxx_b and combo2_xxxx_1000_b );--i=232, 1 135
    combo3_1110_1010 <= not( combo2_1110_xxxx_b and combo2_xxxx_1010_b );--i=234, 1 136
    combo3_1110_1101 <= not( combo2_1110_xxxx_b and combo2_xxxx_1101_b );--i=237, 2 137
    combo3_1111_0000 <= not(     f(4)                                  );--i=240, 2 138
    combo3_1111_0001 <= not(     f(4)           and combo2_xxxx_0001_b );--i=241, 1 139
    combo3_1111_0010 <= not(     f(4)           and combo2_xxxx_0010_b );--i=242, 1 140
    combo3_1111_0100 <= not(     f(4)           and combo2_xxxx_0100_b );--i=244, 2 141
    combo3_1111_1000 <= not(     f(4)           and combo2_xxxx_1000_b );--i=248, 1 142
    combo3_1111_1001 <= not(     f(4)           and combo2_xxxx_1001_b );--i=249, 1 143
    combo3_1111_1010 <= not(     f(4)           and combo2_xxxx_1010_b );--i=250, 1 144
    combo3_1111_1100 <= not(     f(4)           and combo2_xxxx_1100_b );--i=252, 2 145
    combo3_1111_1110 <= not(     f(4)           and combo2_xxxx_1110_b );--i=254, 2 146


--//#######################################
--//## ESTIMATE VECTORs
--//#######################################

    e_00_b(0) <= not( dcd_000 and tiup );
    e_00_b(1) <= not( dcd_001 and tiup );
    e_00_b(2) <= not( dcd_010 and combo3_1111_1100 );
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
    e_01_b(1) <= not( dcd_001 and combo3_1100_0000 );
    e_01_b(2) <= not( dcd_010 and combo3_0000_0011 );
    e_01_b(3) <= not( dcd_011 and tiup );
    e_01_b(4) <= not( dcd_100 and combo3_1111_1110 );
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

    e_02_b(0) <= not( dcd_000 and combo3_1111_1000 );
    e_02_b(1) <= not( dcd_001 and combo3_0011_1110 );
    e_02_b(2) <= not( dcd_010 and combo3_0000_0011 );
    e_02_b(3) <= not( dcd_011 and combo3_1111_1100 );
    e_02_b(4) <= not( dcd_100 and combo3_0000_0001 );
    e_02_b(5) <= not( dcd_101 and tiup );
    e_02_b(6) <= not( dcd_110 and combo3_1100_0000 );
    e_02_b(7) <= not( dcd_111 and tidn );

    e( 2) <= not( e_02_b(0) and  
                  e_02_b(1) and  
                  e_02_b(2) and  
                  e_02_b(3) and  
                  e_02_b(4) and  
                  e_02_b(5) and  
                  e_02_b(6) and  
                  e_02_b(7)  );  

    e_03_b(0) <= not( dcd_000 and combo3_1110_0110 );
    e_03_b(1) <= not( dcd_001 and combo3_0011_0001 );
    e_03_b(2) <= not( dcd_010 and combo3_1100_0011 );
    e_03_b(3) <= not( dcd_011 and combo3_1100_0011 );
    e_03_b(4) <= not( dcd_100 and combo3_1100_0001 );
    e_03_b(5) <= not( dcd_101 and combo3_1111_0000 );
    e_03_b(6) <= not( dcd_110 and combo3_0011_1111 );
    e_03_b(7) <= not( dcd_111 and combo3_1000_0000 );

    e( 3) <= not( e_03_b(0) and  
                  e_03_b(1) and  
                  e_03_b(2) and  
                  e_03_b(3) and  
                  e_03_b(4) and  
                  e_03_b(5) and  
                  e_03_b(6) and  
                  e_03_b(7)  );  

    e_04_b(0) <= not( dcd_000 and combo3_1101_0101 );
    e_04_b(1) <= not( dcd_001 and combo3_0010_1101 );
    e_04_b(2) <= not( dcd_010 and combo3_1011_0011 );
    e_04_b(3) <= not( dcd_011 and combo3_0011_0011 );
    e_04_b(4) <= not( dcd_100 and combo3_0011_0001 );
    e_04_b(5) <= not( dcd_101 and combo3_1100_1110 );
    e_04_b(6) <= not( dcd_110 and combo3_0011_1100 );
    e_04_b(7) <= not( dcd_111 and combo3_0111_1000 );

    e( 4) <= not( e_04_b(0) and  
                  e_04_b(1) and  
                  e_04_b(2) and  
                  e_04_b(3) and  
                  e_04_b(4) and  
                  e_04_b(5) and  
                  e_04_b(6) and  
                  e_04_b(7)  );  

    e_05_b(0) <= not( dcd_000 and combo3_1000_0011 );
    e_05_b(1) <= not( dcd_001 and combo3_1001_1011 );
    e_05_b(2) <= not( dcd_010 and combo3_0110_1010 );
    e_05_b(3) <= not( dcd_011 and combo3_1010_1010 );
    e_05_b(4) <= not( dcd_100 and combo3_1010_1101 );
    e_05_b(5) <= not( dcd_101 and combo3_0010_1101 );
    e_05_b(6) <= not( dcd_110 and combo3_1011_0010 );
    e_05_b(7) <= not( dcd_111 and combo3_0110_0110 );

    e( 5) <= not( e_05_b(0) and  
                  e_05_b(1) and  
                  e_05_b(2) and  
                  e_05_b(3) and  
                  e_05_b(4) and  
                  e_05_b(5) and  
                  e_05_b(6) and  
                  e_05_b(7)  );  

    e_06_b(0) <= not( dcd_000 and combo3_1000_0100 );
    e_06_b(1) <= not( dcd_001 and combo3_1010_1001 );
    e_06_b(2) <= not( dcd_010 and combo3_0011_1000 );
    e_06_b(3) <= not( dcd_011 and tidn );
    e_06_b(4) <= not( dcd_100 and combo3_0011_1001 );
    e_06_b(5) <= not( dcd_101 and combo3_1001_1001 );
    e_06_b(6) <= not( dcd_110 and combo3_0010_1001 );
    e_06_b(7) <= not( dcd_111 and combo3_0101_0101 );

    e( 6) <= not( e_06_b(0) and  
                  e_06_b(1) and  
                  e_06_b(2) and  
                  e_06_b(3) and  
                  e_06_b(4) and  
                  e_06_b(5) and  
                  e_06_b(6) and  
                  e_06_b(7)  );  

    e_07_b(0) <= not( dcd_000 and combo3_1001_1001 );
    e_07_b(1) <= not( dcd_001 and combo3_1000_1100 );
    e_07_b(2) <= not( dcd_010 and combo3_1010_0110 );
    e_07_b(3) <= not( dcd_011 and tidn );
    e_07_b(4) <= not( dcd_100 and combo3_1100_1010 );
    e_07_b(5) <= not( dcd_101 and combo3_1010_1011 );
    e_07_b(6) <= not( dcd_110 and combo3_0110_0011 );
    e_07_b(7) <= not( dcd_111 and combo3_1000_0000 );

    e( 7) <= not( e_07_b(0) and  
                  e_07_b(1) and  
                  e_07_b(2) and  
                  e_07_b(3) and  
                  e_07_b(4) and  
                  e_07_b(5) and  
                  e_07_b(6) and  
                  e_07_b(7)  );  

    e_08_b(0) <= not( dcd_000 and combo3_1000_1101 );
    e_08_b(1) <= not( dcd_001 and combo3_0111_0101 );
    e_08_b(2) <= not( dcd_010 and combo3_1111_0001 );
    e_08_b(3) <= not( dcd_011 and combo3_0000_0011 );
    e_08_b(4) <= not( dcd_100 and combo3_0101_1000 );
    e_08_b(5) <= not( dcd_101 and combo3_0000_0110 );
    e_08_b(6) <= not( dcd_110 and combo3_1101_0010 );
    e_08_b(7) <= not( dcd_111 and combo3_0110_0000 );

    e( 8) <= not( e_08_b(0) and  
                  e_08_b(1) and  
                  e_08_b(2) and  
                  e_08_b(3) and  
                  e_08_b(4) and  
                  e_08_b(5) and  
                  e_08_b(6) and  
                  e_08_b(7)  );  

    e_09_b(0) <= not( dcd_000 and combo3_1010_1100 );
    e_09_b(1) <= not( dcd_001 and combo3_0111_0001 );
    e_09_b(2) <= not( dcd_010 and combo3_0001_0100 );
    e_09_b(3) <= not( dcd_011 and combo3_1000_0101 );
    e_09_b(4) <= not( dcd_100 and combo3_1111_0100 );
    e_09_b(5) <= not( dcd_101 and combo3_0000_1010 );
    e_09_b(6) <= not( dcd_110 and combo3_0111_1001 );
    e_09_b(7) <= not( dcd_111 and combo3_0101_0000 );

    e( 9) <= not( e_09_b(0) and  
                  e_09_b(1) and  
                  e_09_b(2) and  
                  e_09_b(3) and  
                  e_09_b(4) and  
                  e_09_b(5) and  
                  e_09_b(6) and  
                  e_09_b(7)  );  

    e_10_b(0) <= not( dcd_000 and combo3_1010_0100 );
    e_10_b(1) <= not( dcd_001 and combo3_0001_1000 );
    e_10_b(2) <= not( dcd_010 and combo3_0000_0101 );
    e_10_b(3) <= not( dcd_011 and combo3_0100_1001 );
    e_10_b(4) <= not( dcd_100 and combo3_0001_1110 );
    e_10_b(5) <= not( dcd_101 and combo3_0001_1011 );
    e_10_b(6) <= not( dcd_110 and combo3_0111_1010 );
    e_10_b(7) <= not( dcd_111 and combo3_0001_1100 );

    e(10) <= not( e_10_b(0) and  
                  e_10_b(1) and  
                  e_10_b(2) and  
                  e_10_b(3) and  
                  e_10_b(4) and  
                  e_10_b(5) and  
                  e_10_b(6) and  
                  e_10_b(7)  );  

    e_11_b(0) <= not( dcd_000 and combo3_1110_1010 );
    e_11_b(1) <= not( dcd_001 and combo3_1100_0010 );
    e_11_b(2) <= not( dcd_010 and combo3_1010_1100 );
    e_11_b(3) <= not( dcd_011 and combo3_1011_0110 );
    e_11_b(4) <= not( dcd_100 and combo3_1011_0011 );
    e_11_b(5) <= not( dcd_101 and combo3_0011_0101 );
    e_11_b(6) <= not( dcd_110 and combo3_0100_1001 );
    e_11_b(7) <= not( dcd_111 and combo3_0010_1000 );

    e(11) <= not( e_11_b(0) and  
                  e_11_b(1) and  
                  e_11_b(2) and  
                  e_11_b(3) and  
                  e_11_b(4) and  
                  e_11_b(5) and  
                  e_11_b(6) and  
                  e_11_b(7)  );  

    e_12_b(0) <= not( dcd_000 and combo3_1111_1010 );
    e_12_b(1) <= not( dcd_001 and combo3_1110_0100 );
    e_12_b(2) <= not( dcd_010 and combo3_0010_0100 );
    e_12_b(3) <= not( dcd_011 and combo3_1100_1001 );
    e_12_b(4) <= not( dcd_100 and combo3_0111_1111 );
    e_12_b(5) <= not( dcd_101 and combo3_1111_0100 );
    e_12_b(6) <= not( dcd_110 and combo3_1011_0111 );
    e_12_b(7) <= not( dcd_111 and combo3_1100_1010 );

    e(12) <= not( e_12_b(0) and  
                  e_12_b(1) and  
                  e_12_b(2) and  
                  e_12_b(3) and  
                  e_12_b(4) and  
                  e_12_b(5) and  
                  e_12_b(6) and  
                  e_12_b(7)  );  

    e_13_b(0) <= not( dcd_000 and combo3_1001_1000 );
    e_13_b(1) <= not( dcd_001 and combo3_0101_1011 );
    e_13_b(2) <= not( dcd_010 and combo3_1101_1100 );
    e_13_b(3) <= not( dcd_011 and combo3_0000_0110 );
    e_13_b(4) <= not( dcd_100 and combo3_0100_0011 );
    e_13_b(5) <= not( dcd_101 and combo3_1110_1000 );
    e_13_b(6) <= not( dcd_110 and combo3_1111_1110 );
    e_13_b(7) <= not( dcd_111 and combo3_1001_1010 );

    e(13) <= not( e_13_b(0) and  
                  e_13_b(1) and  
                  e_13_b(2) and  
                  e_13_b(3) and  
                  e_13_b(4) and  
                  e_13_b(5) and  
                  e_13_b(6) and  
                  e_13_b(7)  );  

    e_14_b(0) <= not( dcd_000 and combo3_0101_0100 );
    e_14_b(1) <= not( dcd_001 and combo3_0010_0110 );
    e_14_b(2) <= not( dcd_010 and combo3_0101_0000 );
    e_14_b(3) <= not( dcd_011 and combo3_0111_0000 );
    e_14_b(4) <= not( dcd_100 and combo3_0010_1101 );
    e_14_b(5) <= not( dcd_101 and combo3_1101_0100 );
    e_14_b(6) <= not( dcd_110 and combo3_1100_1000 );
    e_14_b(7) <= not( dcd_111 and combo3_0110_1000 );

    e(14) <= not( e_14_b(0) and  
                  e_14_b(1) and  
                  e_14_b(2) and  
                  e_14_b(3) and  
                  e_14_b(4) and  
                  e_14_b(5) and  
                  e_14_b(6) and  
                  e_14_b(7)  );  

    e_15_b(0) <= not( dcd_000 and combo3_0101_1011 );
    e_15_b(1) <= not( dcd_001 and combo3_0010_0000 );
    e_15_b(2) <= not( dcd_010 and combo3_1101_0110 );
    e_15_b(3) <= not( dcd_011 and combo3_1000_0001 );
    e_15_b(4) <= not( dcd_100 and combo3_1001_0110 );
    e_15_b(5) <= not( dcd_101 and combo3_1110_0101 );
    e_15_b(6) <= not( dcd_110 and combo3_0100_1110 );
    e_15_b(7) <= not( dcd_111 and combo3_1110_0000 );

    e(15) <= not( e_15_b(0) and  
                  e_15_b(1) and  
                  e_15_b(2) and  
                  e_15_b(3) and  
                  e_15_b(4) and  
                  e_15_b(5) and  
                  e_15_b(6) and  
                  e_15_b(7)  );  

    e_16_b(0) <= not( dcd_000 and combo3_0100_1000 );
    e_16_b(1) <= not( dcd_001 and combo3_0010_0101 );
    e_16_b(2) <= not( dcd_010 and combo3_1001_0111 );
    e_16_b(3) <= not( dcd_011 and combo3_0011_1010 );
    e_16_b(4) <= not( dcd_100 and combo3_0000_0101 );
    e_16_b(5) <= not( dcd_101 and combo3_1110_0100 );
    e_16_b(6) <= not( dcd_110 and combo3_0000_1111 );
    e_16_b(7) <= not( dcd_111 and combo3_0000_0100 );

    e(16) <= not( e_16_b(0) and  
                  e_16_b(1) and  
                  e_16_b(2) and  
                  e_16_b(3) and  
                  e_16_b(4) and  
                  e_16_b(5) and  
                  e_16_b(6) and  
                  e_16_b(7)  );  

    e_17_b(0) <= not( dcd_000 and combo3_0000_1011 );
    e_17_b(1) <= not( dcd_001 and combo3_1100_1111 );
    e_17_b(2) <= not( dcd_010 and combo3_0000_1011 );
    e_17_b(3) <= not( dcd_011 and combo3_0010_0000 );
    e_17_b(4) <= not( dcd_100 and combo3_1101_0011 );
    e_17_b(5) <= not( dcd_101 and combo3_0010_1000 );
    e_17_b(6) <= not( dcd_110 and combo3_1111_0010 );
    e_17_b(7) <= not( dcd_111 and combo3_0100_0110 );

    e(17) <= not( e_17_b(0) and  
                  e_17_b(1) and  
                  e_17_b(2) and  
                  e_17_b(3) and  
                  e_17_b(4) and  
                  e_17_b(5) and  
                  e_17_b(6) and  
                  e_17_b(7)  );  

    e_18_b(0) <= not( dcd_000 and combo3_0000_1001 );
    e_18_b(1) <= not( dcd_001 and combo3_1100_1101 );
    e_18_b(2) <= not( dcd_010 and combo3_0000_1010 );
    e_18_b(3) <= not( dcd_011 and combo3_0000_0001 );
    e_18_b(4) <= not( dcd_100 and combo3_0101_0000 );
    e_18_b(5) <= not( dcd_101 and combo3_1001_0100 );
    e_18_b(6) <= not( dcd_110 and combo3_0101_0010 );
    e_18_b(7) <= not( dcd_111 and tidn );

    e(18) <= not( e_18_b(0) and  
                  e_18_b(1) and  
                  e_18_b(2) and  
                  e_18_b(3) and  
                  e_18_b(4) and  
                  e_18_b(5) and  
                  e_18_b(6) and  
                  e_18_b(7)  );  

    e_19_b(0) <= not( dcd_000 and combo3_0111_1111 );
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

    r_00_b(0) <= not( dcd_000 and tiup );
    r_00_b(1) <= not( dcd_001 and tiup );
    r_00_b(2) <= not( dcd_010 and tiup );
    r_00_b(3) <= not( dcd_011 and combo3_1110_0000 );
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
    r_01_b(1) <= not( dcd_001 and combo3_1100_0000 );
    r_01_b(2) <= not( dcd_010 and tidn );
    r_01_b(3) <= not( dcd_011 and combo3_0001_1111 );
    r_01_b(4) <= not( dcd_100 and tiup );
    r_01_b(5) <= not( dcd_101 and tiup );
    r_01_b(6) <= not( dcd_110 and tiup );
    r_01_b(7) <= not( dcd_111 and tiup );

    r( 1) <= not( r_01_b(0) and  
                  r_01_b(1) and  
                  r_01_b(2) and  
                  r_01_b(3) and  
                  r_01_b(4) and  
                  r_01_b(5) and  
                  r_01_b(6) and  
                  r_01_b(7)  );  

    r_02_b(0) <= not( dcd_000 and combo3_1111_0000 );
    r_02_b(1) <= not( dcd_001 and combo3_0011_1111 );
    r_02_b(2) <= not( dcd_010 and combo3_1000_0000 );
    r_02_b(3) <= not( dcd_011 and combo3_0001_1111 );
    r_02_b(4) <= not( dcd_100 and tiup );
    r_02_b(5) <= not( dcd_101 and combo3_1000_0000 );
    r_02_b(6) <= not( dcd_110 and tidn );
    r_02_b(7) <= not( dcd_111 and tidn );

    r( 2) <= not( r_02_b(0) and  
                  r_02_b(1) and  
                  r_02_b(2) and  
                  r_02_b(3) and  
                  r_02_b(4) and  
                  r_02_b(5) and  
                  r_02_b(6) and  
                  r_02_b(7)  );  

    r_03_b(0) <= not( dcd_000 and combo3_1100_1110 );
    r_03_b(1) <= not( dcd_001 and combo3_0011_1000 );
    r_03_b(2) <= not( dcd_010 and combo3_0111_1000 );
    r_03_b(3) <= not( dcd_011 and combo3_0001_1111 );
    r_03_b(4) <= not( dcd_100 and combo3_1000_0000 );
    r_03_b(5) <= not( dcd_101 and combo3_0111_1111 );
    r_03_b(6) <= not( dcd_110 and combo3_1100_0000 );
    r_03_b(7) <= not( dcd_111 and tidn );

    r( 3) <= not( r_03_b(0) and  
                  r_03_b(1) and  
                  r_03_b(2) and  
                  r_03_b(3) and  
                  r_03_b(4) and  
                  r_03_b(5) and  
                  r_03_b(6) and  
                  r_03_b(7)  );  

    r_04_b(0) <= not( dcd_000 and combo3_1010_1101 );
    r_04_b(1) <= not( dcd_001 and combo3_0010_0110 );
    r_04_b(2) <= not( dcd_010 and combo3_0110_0111 );
    r_04_b(3) <= not( dcd_011 and combo3_0001_1000 );
    r_04_b(4) <= not( dcd_100 and combo3_0111_0000 );
    r_04_b(5) <= not( dcd_101 and combo3_0111_1000 );
    r_04_b(6) <= not( dcd_110 and combo3_0011_1111 );
    r_04_b(7) <= not( dcd_111 and combo3_1000_0000 );

    r( 4) <= not( r_04_b(0) and  
                  r_04_b(1) and  
                  r_04_b(2) and  
                  r_04_b(3) and  
                  r_04_b(4) and  
                  r_04_b(5) and  
                  r_04_b(6) and  
                  r_04_b(7)  );  

    r_05_b(0) <= not( dcd_000 and combo3_1111_1001 );
    r_05_b(1) <= not( dcd_001 and combo3_1011_0101 );
    r_05_b(2) <= not( dcd_010 and combo3_0101_0110 );
    r_05_b(3) <= not( dcd_011 and combo3_1001_0110 );
    r_05_b(4) <= not( dcd_100 and combo3_0110_1100 );
    r_05_b(5) <= not( dcd_101 and combo3_0110_0111 );
    r_05_b(6) <= not( dcd_110 and combo3_0011_1000 );
    r_05_b(7) <= not( dcd_111 and combo3_0111_0000 );

    r( 5) <= not( r_05_b(0) and  
                  r_05_b(1) and  
                  r_05_b(2) and  
                  r_05_b(3) and  
                  r_05_b(4) and  
                  r_05_b(5) and  
                  r_05_b(6) and  
                  r_05_b(7)  );  

    r_06_b(0) <= not( dcd_000 and combo3_0001_1010 );
    r_06_b(1) <= not( dcd_001 and combo3_1101_1110 );
    r_06_b(2) <= not( dcd_010 and combo3_0011_1100 );
    r_06_b(3) <= not( dcd_011 and combo3_0100_1101 );
    r_06_b(4) <= not( dcd_100 and combo3_0100_1010 );
    r_06_b(5) <= not( dcd_101 and combo3_0101_0100 );
    r_06_b(6) <= not( dcd_110 and combo3_1011_0110 );
    r_06_b(7) <= not( dcd_111 and combo3_0100_1100 );

    r( 6) <= not( r_06_b(0) and  
                  r_06_b(1) and  
                  r_06_b(2) and  
                  r_06_b(3) and  
                  r_06_b(4) and  
                  r_06_b(5) and  
                  r_06_b(6) and  
                  r_06_b(7)  );  

    r_07_b(0) <= not( dcd_000 and combo3_0010_1101 );
    r_07_b(1) <= not( dcd_001 and combo3_1001_1001 );
    r_07_b(2) <= not( dcd_010 and combo3_1100_0100 );
    r_07_b(3) <= not( dcd_011 and combo3_1001_0110 );
    r_07_b(4) <= not( dcd_100 and combo3_0001_1111 );
    r_07_b(5) <= not( dcd_101 and combo3_0000_1110 );
    r_07_b(6) <= not( dcd_110 and combo3_0110_1101 );
    r_07_b(7) <= not( dcd_111 and combo3_0110_1010 );

    r( 7) <= not( r_07_b(0) and  
                  r_07_b(1) and  
                  r_07_b(2) and  
                  r_07_b(3) and  
                  r_07_b(4) and  
                  r_07_b(5) and  
                  r_07_b(6) and  
                  r_07_b(7)  );  

    r_08_b(0) <= not( dcd_000 and combo3_0000_0010 );
    r_08_b(1) <= not( dcd_001 and combo3_1011_0101 );
    r_08_b(2) <= not( dcd_010 and combo3_1100_1001 );
    r_08_b(3) <= not( dcd_011 and combo3_1100_1101 );
    r_08_b(4) <= not( dcd_100 and combo3_1001_1111 );
    r_08_b(5) <= not( dcd_101 and combo3_0001_0010 );
    r_08_b(6) <= not( dcd_110 and combo3_1011_0110 );
    r_08_b(7) <= not( dcd_111 and combo3_0011_1111 );

    r( 8) <= not( r_08_b(0) and  
                  r_08_b(1) and  
                  r_08_b(2) and  
                  r_08_b(3) and  
                  r_08_b(4) and  
                  r_08_b(5) and  
                  r_08_b(6) and  
                  r_08_b(7)  );  

    r_09_b(0) <= not( dcd_000 and combo3_0100_1010 );
    r_09_b(1) <= not( dcd_001 and combo3_0011_0001 );
    r_09_b(2) <= not( dcd_010 and combo3_1101_1101 );
    r_09_b(3) <= not( dcd_011 and combo3_1100_0111 );
    r_09_b(4) <= not( dcd_100 and combo3_0101_1111 );
    r_09_b(5) <= not( dcd_101 and combo3_0010_0111 );
    r_09_b(6) <= not( dcd_110 and combo3_1110_1101 );
    r_09_b(7) <= not( dcd_111 and combo3_0011_0000 );

    r( 9) <= not( r_09_b(0) and  
                  r_09_b(1) and  
                  r_09_b(2) and  
                  r_09_b(3) and  
                  r_09_b(4) and  
                  r_09_b(5) and  
                  r_09_b(6) and  
                  r_09_b(7)  );  

    r_10_b(0) <= not( dcd_000 and combo3_0111_1010 );
    r_10_b(1) <= not( dcd_001 and combo3_0011_1011 );
    r_10_b(2) <= not( dcd_010 and combo3_0001_0111 );
    r_10_b(3) <= not( dcd_011 and combo3_1101_0111 );
    r_10_b(4) <= not( dcd_100 and combo3_0001_0001 );
    r_10_b(5) <= not( dcd_101 and combo3_0111_0110 );
    r_10_b(6) <= not( dcd_110 and combo3_0110_0111 );
    r_10_b(7) <= not( dcd_111 and combo3_1010_1000 );

    r(10) <= not( r_10_b(0) and  
                  r_10_b(1) and  
                  r_10_b(2) and  
                  r_10_b(3) and  
                  r_10_b(4) and  
                  r_10_b(5) and  
                  r_10_b(6) and  
                  r_10_b(7)  );  

    r_11_b(0) <= not( dcd_000 and combo3_0000_1111 );
    r_11_b(1) <= not( dcd_001 and combo3_0101_0100 );
    r_11_b(2) <= not( dcd_010 and combo3_1110_1101 );
    r_11_b(3) <= not( dcd_011 and combo3_0001_0101 );
    r_11_b(4) <= not( dcd_100 and combo3_1010_1000 );
    r_11_b(5) <= not( dcd_101 and combo3_0111_1101 );
    r_11_b(6) <= not( dcd_110 and combo3_1011_0100 );
    r_11_b(7) <= not( dcd_111 and combo3_1000_0100 );

    r(11) <= not( r_11_b(0) and  
                  r_11_b(1) and  
                  r_11_b(2) and  
                  r_11_b(3) and  
                  r_11_b(4) and  
                  r_11_b(5) and  
                  r_11_b(6) and  
                  r_11_b(7)  );  

    r_12_b(0) <= not( dcd_000 and combo3_1100_1111 );
    r_12_b(1) <= not( dcd_001 and combo3_0110_1011 );
    r_12_b(2) <= not( dcd_010 and combo3_0100_1000 );
    r_12_b(3) <= not( dcd_011 and combo3_0111_1011 );
    r_12_b(4) <= not( dcd_100 and combo3_1101_0110 );
    r_12_b(5) <= not( dcd_101 and combo3_0001_0001 );
    r_12_b(6) <= not( dcd_110 and combo3_1011_0011 );
    r_12_b(7) <= not( dcd_111 and combo3_0100_0000 );

    r(12) <= not( r_12_b(0) and  
                  r_12_b(1) and  
                  r_12_b(2) and  
                  r_12_b(3) and  
                  r_12_b(4) and  
                  r_12_b(5) and  
                  r_12_b(6) and  
                  r_12_b(7)  );  

    r_13_b(0) <= not( dcd_000 and combo3_0101_0001 );
    r_13_b(1) <= not( dcd_001 and combo3_0011_1100 );
    r_13_b(2) <= not( dcd_010 and combo3_0101_1011 );
    r_13_b(3) <= not( dcd_011 and combo3_0001_1000 );
    r_13_b(4) <= not( dcd_100 and combo3_0110_0010 );
    r_13_b(5) <= not( dcd_101 and combo3_1101_0100 );
    r_13_b(6) <= not( dcd_110 and combo3_0100_0011 );
    r_13_b(7) <= not( dcd_111 and combo3_1000_1010 );

    r(13) <= not( r_13_b(0) and  
                  r_13_b(1) and  
                  r_13_b(2) and  
                  r_13_b(3) and  
                  r_13_b(4) and  
                  r_13_b(5) and  
                  r_13_b(6) and  
                  r_13_b(7)  );  

    r_14_b(0) <= not( dcd_000 and combo3_1000_0000 );
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


end; -- fuq_tblres ARCHITECTURE
