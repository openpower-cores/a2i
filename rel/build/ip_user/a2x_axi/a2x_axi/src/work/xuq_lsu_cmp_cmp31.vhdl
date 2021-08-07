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





LIBRARY ieee;       USE ieee.std_logic_1164.all;
                    USE ieee.numeric_std.all;
LIBRARY ibm;        
                    USE ibm.std_ulogic_support.all;
                    USE ibm.std_ulogic_unsigned.all;
                    USE ibm.std_ulogic_function_support.all;
LIBRARY support;    
                    USE support.power_logic_pkg.all;
LIBRARY tri;        USE tri.tri_latches_pkg.all;
LIBRARY clib ;
-- pragma translate_off
LIBRARY latches ;
LIBRARY macros ;
-- pragma translate_on


entity xuq_lsu_cmp_cmp31 is
generic( expand_type: integer := 2  ); 
port(       
       d0                  :in  std_ulogic_vector(0 to 30);
       d1                  :in  std_ulogic_vector(0 to 30);
       eq                  :out std_ulogic
);





end xuq_lsu_cmp_cmp31; 

architecture xuq_lsu_cmp_cmp31 of xuq_lsu_cmp_cmp31 is
   constant tiup : std_ulogic := '1';
   constant tidn : std_ulogic := '0';

   signal eq01     :std_ulogic_vector(0 to 30) ;
   signal eq03_b   : std_ulogic_vector(0 to 11);
   signal eq06     : std_ulogic_vector(0 to 5);
   signal eq18_b   : std_ulogic_vector(0 to 1);








begin


  u_eq01: eq01(0 to 30) <= not( d0(0 to 30) xor d1(0 to 30) );

  u_eq03_00: eq03_b( 0) <= not( eq01( 0) and eq01( 1) and eq01( 2) );
  u_eq03_01: eq03_b( 1) <= not( eq01( 3) and eq01( 4) and eq01( 5) );
  u_eq03_02: eq03_b( 2) <= not( eq01( 6) and eq01( 7) and eq01( 8) );
  u_eq03_03: eq03_b( 3) <= not( eq01( 9) and eq01(10) and eq01(11) );
  u_eq03_04: eq03_b( 4) <= not( eq01(12) and eq01(13) and eq01(14) );
  u_eq03_05: eq03_b( 5) <= not( eq01(15) and eq01(16) and eq01(17) );
  u_eq03_06: eq03_b( 6) <= not( eq01(18) and eq01(19) and eq01(20) );
  u_eq03_07: eq03_b( 7) <= not( eq01(21) and eq01(22)              );
  u_eq03_08: eq03_b( 8) <= not( eq01(23) and eq01(24)              );
  u_eq03_09: eq03_b( 9) <= not( eq01(25) and eq01(26)              );
  u_eq03_10: eq03_b(10) <= not( eq01(27) and eq01(28)              );
  u_eq03_11: eq03_b(11) <= not( eq01(29) and eq01(30)              );

  u_eq06_00: eq06( 0)   <= not( eq03_b( 0) or  eq03_b( 1) );
  u_eq06_01: eq06( 1)   <= not( eq03_b( 2) or  eq03_b( 3) );
  u_eq06_02: eq06( 2)   <= not( eq03_b( 4) or  eq03_b( 5) );
  u_eq06_03: eq06( 3)   <= not( eq03_b( 6) or  eq03_b( 7) );
  u_eq06_04: eq06( 4)   <= not( eq03_b( 8) or  eq03_b( 9) );
  u_eq06_05: eq06( 5)   <= not( eq03_b(10) or  eq03_b(11) );

  u_eq18_00: eq18_b( 0) <= not( eq06(0) and eq06(1) and eq06(2) );
  u_eq18_01: eq18_b( 1) <= not( eq06(3) and eq06(4) and eq06(5) );

  u_eq36_00: eq         <= not( eq18_b( 0) or  eq18_b( 1) ); 



end; 

