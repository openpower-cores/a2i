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


 
entity fuq_tblsqe is
generic(   expand_type               : integer := 2  ); 
port( 
       f    :in   std_ulogic_vector(1 to 6);
       est  :out  std_ulogic_vector(1 to 20);
       rng  :out  std_ulogic_vector(6 to 20)
       
); 
 
 
 
end fuq_tblsqe; 
 
 
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



    combo2_1000 <=       not f(5) and not f(6)   ;
    combo2_0100 <=       not f(5) and     f(6)   ;
    combo2_1100 <=       not f(5)                ;
    combo2_0010 <=           f(5) and not f(6)   ;
    combo2_1010 <=                    not f(6)   ;
    combo2_0110 <=           f(5) xor     f(6)   ;
    combo2_1110 <=  not(     f(5) and     f(6) ) ;
    combo2_0001 <=           f(5) and     f(6)   ;
    combo2_1001 <=  not(     f(5) xor     f(6) ) ;
    combo2_0101 <=                        f(6)   ;
    combo2_1101 <=  not(     f(5) and not f(6) ) ;
    combo2_0011 <=           f(5)                ;
    combo2_1011 <=  not( not f(5) and     f(6) ) ;
    combo2_0111 <=  not( not f(5) and not f(6) ) ;



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


    combo3_0000_0001 <= not(                        combo2_xxxx_0001_b );
    combo3_0000_0011 <= not(                        combo2_xxxx_0011_b );
    combo3_0000_0100 <= not(                        combo2_xxxx_0100_b );
    combo3_0000_0111 <= not(                        combo2_xxxx_0111_b );
    combo3_0000_1001 <= not(                        combo2_xxxx_1001_b );
    combo3_0000_1010 <= not(                        combo2_xxxx_1010_b );
    combo3_0000_1011 <= not(                        combo2_xxxx_1011_b );
    combo3_0000_1101 <= not(                        combo2_xxxx_1101_b );
    combo3_0000_1111 <= not(                        not f(4)           );
    combo3_0001_0001 <= not( not combo2_0001                           );
    combo3_0001_0010 <= not( combo2_0001_xxxx_b and combo2_xxxx_0010_b );
    combo3_0001_0100 <= not( combo2_0001_xxxx_b and combo2_xxxx_0100_b );
    combo3_0001_0101 <= not( combo2_0001_xxxx_b and combo2_xxxx_0101_b );
    combo3_0001_0111 <= not( combo2_0001_xxxx_b and combo2_xxxx_0111_b );
    combo3_0001_1000 <= not( combo2_0001_xxxx_b and combo2_xxxx_1000_b );
    combo3_0001_1100 <= not( combo2_0001_xxxx_b and combo2_xxxx_1100_b );
    combo3_0001_1101 <= not( combo2_0001_xxxx_b and combo2_xxxx_1101_b );
    combo3_0001_1110 <= not( combo2_0001_xxxx_b and combo2_xxxx_1110_b );
    combo3_0001_1111 <= not( combo2_0001_xxxx_b and not f(4)           );
    combo3_0010_0001 <= not( combo2_0010_xxxx_b and combo2_xxxx_0001_b );
    combo3_0010_0011 <= not( combo2_0010_xxxx_b and combo2_xxxx_0011_b );
    combo3_0010_0100 <= not( combo2_0010_xxxx_b and combo2_xxxx_0100_b );
    combo3_0010_0101 <= not( combo2_0010_xxxx_b and combo2_xxxx_0101_b );
    combo3_0010_1000 <= not( combo2_0010_xxxx_b and combo2_xxxx_1000_b );
    combo3_0010_1001 <= not( combo2_0010_xxxx_b and combo2_xxxx_1001_b );
    combo3_0010_1010 <= not( combo2_0010_xxxx_b and combo2_xxxx_1010_b );
    combo3_0010_1100 <= not( combo2_0010_xxxx_b and combo2_xxxx_1100_b );
    combo3_0010_1101 <= not( combo2_0010_xxxx_b and combo2_xxxx_1101_b );
    combo3_0010_1110 <= not( combo2_0010_xxxx_b and combo2_xxxx_1110_b );
    combo3_0010_1111 <= not( combo2_0010_xxxx_b and not f(4)           );
    combo3_0011_0000 <= not( combo2_0011_xxxx_b                        );
    combo3_0011_0001 <= not( combo2_0011_xxxx_b and combo2_xxxx_0001_b );
    combo3_0011_0011 <= not( not combo2_0011                           );
    combo3_0011_0101 <= not( combo2_0011_xxxx_b and combo2_xxxx_0101_b );
    combo3_0011_0110 <= not( combo2_0011_xxxx_b and combo2_xxxx_0110_b );
    combo3_0011_1000 <= not( combo2_0011_xxxx_b and combo2_xxxx_1000_b );
    combo3_0011_1001 <= not( combo2_0011_xxxx_b and combo2_xxxx_1001_b );
    combo3_0011_1110 <= not( combo2_0011_xxxx_b and combo2_xxxx_1110_b );
    combo3_0011_1111 <= not( combo2_0011_xxxx_b and not f(4)           );
    combo3_0100_0000 <= not( combo2_0100_xxxx_b                        );
    combo3_0100_0010 <= not( combo2_0100_xxxx_b and combo2_xxxx_0010_b );
    combo3_0100_0100 <= not( not combo2_0100                           );
    combo3_0100_0101 <= not( combo2_0100_xxxx_b and combo2_xxxx_0101_b );
    combo3_0100_1001 <= not( combo2_0100_xxxx_b and combo2_xxxx_1001_b );
    combo3_0100_1100 <= not( combo2_0100_xxxx_b and combo2_xxxx_1100_b );
    combo3_0100_1110 <= not( combo2_0100_xxxx_b and combo2_xxxx_1110_b );
    combo3_0100_1111 <= not( combo2_0100_xxxx_b and not f(4)           );
    combo3_0101_0010 <= not( combo2_0101_xxxx_b and combo2_xxxx_0010_b );
    combo3_0101_0100 <= not( combo2_0101_xxxx_b and combo2_xxxx_0100_b );
    combo3_0101_0110 <= not( combo2_0101_xxxx_b and combo2_xxxx_0110_b );
    combo3_0101_1001 <= not( combo2_0101_xxxx_b and combo2_xxxx_1001_b );
    combo3_0101_1100 <= not( combo2_0101_xxxx_b and combo2_xxxx_1100_b );
    combo3_0101_1111 <= not( combo2_0101_xxxx_b and not f(4)           );
    combo3_0110_0000 <= not( combo2_0110_xxxx_b                        );
    combo3_0110_0011 <= not( combo2_0110_xxxx_b and combo2_xxxx_0011_b );
    combo3_0110_0110 <= not( not combo2_0110                           );
    combo3_0110_0111 <= not( combo2_0110_xxxx_b and combo2_xxxx_0111_b );
    combo3_0110_1100 <= not( combo2_0110_xxxx_b and combo2_xxxx_1100_b );
    combo3_0110_1101 <= not( combo2_0110_xxxx_b and combo2_xxxx_1101_b );
    combo3_0110_1111 <= not( combo2_0110_xxxx_b and not f(4)           );
    combo3_0111_0000 <= not( combo2_0111_xxxx_b                        );
    combo3_0111_0101 <= not( combo2_0111_xxxx_b and combo2_xxxx_0101_b );
    combo3_0111_0111 <= not( not combo2_0111                           );
    combo3_0111_1000 <= not( combo2_0111_xxxx_b and combo2_xxxx_1000_b );
    combo3_0111_1001 <= not( combo2_0111_xxxx_b and combo2_xxxx_1001_b );
    combo3_0111_1010 <= not( combo2_0111_xxxx_b and combo2_xxxx_1010_b );
    combo3_0111_1111 <= not( combo2_0111_xxxx_b and not f(4)           );
    combo3_1000_0000 <= not( combo2_1000_xxxx_b                        );
    combo3_1000_0011 <= not( combo2_1000_xxxx_b and combo2_xxxx_0011_b );
    combo3_1000_0110 <= not( combo2_1000_xxxx_b and combo2_xxxx_0110_b );
    combo3_1000_0111 <= not( combo2_1000_xxxx_b and combo2_xxxx_0111_b );
    combo3_1000_1010 <= not( combo2_1000_xxxx_b and combo2_xxxx_1010_b );
    combo3_1000_1110 <= not( combo2_1000_xxxx_b and combo2_xxxx_1110_b );
    combo3_1001_0000 <= not( combo2_1001_xxxx_b                        );
    combo3_1001_0001 <= not( combo2_1001_xxxx_b and combo2_xxxx_0001_b );
    combo3_1001_0010 <= not( combo2_1001_xxxx_b and combo2_xxxx_0010_b );
    combo3_1001_0100 <= not( combo2_1001_xxxx_b and combo2_xxxx_0100_b );
    combo3_1001_0110 <= not( combo2_1001_xxxx_b and combo2_xxxx_0110_b );
    combo3_1001_0111 <= not( combo2_1001_xxxx_b and combo2_xxxx_0111_b );
    combo3_1001_1000 <= not( combo2_1001_xxxx_b and combo2_xxxx_1000_b );
    combo3_1001_1001 <= not( not combo2_1001                           );
    combo3_1001_1010 <= not( combo2_1001_xxxx_b and combo2_xxxx_1010_b );
    combo3_1001_1011 <= not( combo2_1001_xxxx_b and combo2_xxxx_1011_b );
    combo3_1001_1100 <= not( combo2_1001_xxxx_b and combo2_xxxx_1100_b );
    combo3_1010_0000 <= not( combo2_1010_xxxx_b                        );
    combo3_1010_0001 <= not( combo2_1010_xxxx_b and combo2_xxxx_0001_b );
    combo3_1010_0010 <= not( combo2_1010_xxxx_b and combo2_xxxx_0010_b );
    combo3_1010_0100 <= not( combo2_1010_xxxx_b and combo2_xxxx_0100_b );
    combo3_1010_0101 <= not( combo2_1010_xxxx_b and combo2_xxxx_0101_b );
    combo3_1010_0110 <= not( combo2_1010_xxxx_b and combo2_xxxx_0110_b );
    combo3_1010_0111 <= not( combo2_1010_xxxx_b and combo2_xxxx_0111_b );
    combo3_1010_1001 <= not( combo2_1010_xxxx_b and combo2_xxxx_1001_b );
    combo3_1010_1010 <= not( not combo2_1010                           );
    combo3_1010_1100 <= not( combo2_1010_xxxx_b and combo2_xxxx_1100_b );
    combo3_1010_1101 <= not( combo2_1010_xxxx_b and combo2_xxxx_1101_b );
    combo3_1010_1111 <= not( combo2_1010_xxxx_b and not f(4)           );
    combo3_1011_0001 <= not( combo2_1011_xxxx_b and combo2_xxxx_0001_b );
    combo3_1011_0010 <= not( combo2_1011_xxxx_b and combo2_xxxx_0010_b );
    combo3_1011_0100 <= not( combo2_1011_xxxx_b and combo2_xxxx_0100_b );
    combo3_1011_0101 <= not( combo2_1011_xxxx_b and combo2_xxxx_0101_b );
    combo3_1011_1000 <= not( combo2_1011_xxxx_b and combo2_xxxx_1000_b );
    combo3_1011_1010 <= not( combo2_1011_xxxx_b and combo2_xxxx_1010_b );
    combo3_1011_1100 <= not( combo2_1011_xxxx_b and combo2_xxxx_1100_b );
    combo3_1100_0000 <= not( combo2_1100_xxxx_b                        );
    combo3_1100_0001 <= not( combo2_1100_xxxx_b and combo2_xxxx_0001_b );
    combo3_1100_0011 <= not( combo2_1100_xxxx_b and combo2_xxxx_0011_b );
    combo3_1100_0101 <= not( combo2_1100_xxxx_b and combo2_xxxx_0101_b );
    combo3_1100_0110 <= not( combo2_1100_xxxx_b and combo2_xxxx_0110_b );
    combo3_1100_0111 <= not( combo2_1100_xxxx_b and combo2_xxxx_0111_b );
    combo3_1100_1001 <= not( combo2_1100_xxxx_b and combo2_xxxx_1001_b );
    combo3_1100_1010 <= not( combo2_1100_xxxx_b and combo2_xxxx_1010_b );
    combo3_1100_1011 <= not( combo2_1100_xxxx_b and combo2_xxxx_1011_b );
    combo3_1100_1101 <= not( combo2_1100_xxxx_b and combo2_xxxx_1101_b );
    combo3_1100_1111 <= not( combo2_1100_xxxx_b and not f(4)           );
    combo3_1101_0010 <= not( combo2_1101_xxxx_b and combo2_xxxx_0010_b );
    combo3_1101_0011 <= not( combo2_1101_xxxx_b and combo2_xxxx_0011_b );
    combo3_1101_1000 <= not( combo2_1101_xxxx_b and combo2_xxxx_1000_b );
    combo3_1101_1001 <= not( combo2_1101_xxxx_b and combo2_xxxx_1001_b );
    combo3_1101_1010 <= not( combo2_1101_xxxx_b and combo2_xxxx_1010_b );
    combo3_1101_1100 <= not( combo2_1101_xxxx_b and combo2_xxxx_1100_b );
    combo3_1101_1110 <= not( combo2_1101_xxxx_b and combo2_xxxx_1110_b );
    combo3_1101_1111 <= not( combo2_1101_xxxx_b and not f(4)           );
    combo3_1110_0000 <= not( combo2_1110_xxxx_b                        );
    combo3_1110_0001 <= not( combo2_1110_xxxx_b and combo2_xxxx_0001_b );
    combo3_1110_0011 <= not( combo2_1110_xxxx_b and combo2_xxxx_0011_b );
    combo3_1110_0110 <= not( combo2_1110_xxxx_b and combo2_xxxx_0110_b );
    combo3_1110_1000 <= not( combo2_1110_xxxx_b and combo2_xxxx_1000_b );
    combo3_1110_1010 <= not( combo2_1110_xxxx_b and combo2_xxxx_1010_b );
    combo3_1110_1101 <= not( combo2_1110_xxxx_b and combo2_xxxx_1101_b );
    combo3_1111_0000 <= not(     f(4)                                  );
    combo3_1111_0001 <= not(     f(4)           and combo2_xxxx_0001_b );
    combo3_1111_0010 <= not(     f(4)           and combo2_xxxx_0010_b );
    combo3_1111_1000 <= not(     f(4)           and combo2_xxxx_1000_b );
    combo3_1111_1001 <= not(     f(4)           and combo2_xxxx_1001_b );
    combo3_1111_1010 <= not(     f(4)           and combo2_xxxx_1010_b );
    combo3_1111_1100 <= not(     f(4)           and combo2_xxxx_1100_b );



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





  est(1 to 20) <= e(0 to 19);
  rng(6 to 20) <= r(0 to 14);


end; 
  
