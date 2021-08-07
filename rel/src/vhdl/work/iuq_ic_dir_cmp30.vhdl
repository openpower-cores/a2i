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



-- ###################################################################
-- ## Address decoder
-- ###################################################################


LIBRARY ieee;       USE ieee.std_logic_1164.all;
                    USE ieee.numeric_std.all;
LIBRARY ibm;        
                    USE ibm.std_ulogic_support.all;
                    USE ibm.std_ulogic_unsigned.all;
                    USE ibm.std_ulogic_function_support.all;
LIBRARY support;    
                    USE support.power_logic_pkg.all;
LIBRARY tri;        USE tri.tri_latches_pkg.all;


entity iuq_ic_dir_cmp30 is
generic( expand_type: integer := 2  ); -- 0 - ibm tech, 1 - other );
port(
       d0_b                :in  std_ulogic_vector(0 to 29);
       d1                  :in  std_ulogic_vector(0 to 29);
       eq_b                :out std_ulogic
);

-- synopsys translate_off

-- synopsys translate_on



end iuq_ic_dir_cmp30; -- ENTITY

architecture iuq_ic_dir_cmp30 of iuq_ic_dir_cmp30 is
   constant tiup : std_ulogic := '1';
   constant tidn : std_ulogic := '0';

   signal                         eq01      :std_ulogic_vector(0 to 29) ;
-- synopsys translate_off
-- synopsys translate_on

   signal eq02_b   : std_ulogic_vector(0 to 14);
   signal eq04     : std_ulogic_vector(0 to 7);
   signal eq08_b   : std_ulogic_vector(0 to 3);
   signal eq16     : std_ulogic_vector(0 to 1);

-- synopsys translate_off






-- synopsys translate_on


begin


  u_eq01: eq01(0 to 29) <= ( d0_b(0 to 29) xor d1(0 to 29) ); --x1


  u_00_eq02: eq02_b( 0) <= not( eq01  ( 0) and eq01  ( 1) );  --lv1 x1
  u_02_eq02: eq02_b( 1) <= not( eq01  ( 2) and eq01  ( 3) );  --lv1 x1
  u_04_eq02: eq02_b( 2) <= not( eq01  ( 4) and eq01  ( 5) );  --lv1 x1
  u_06_eq02: eq02_b( 3) <= not( eq01  ( 6) and eq01  ( 7) );  --lv1 x1
  u_08_eq02: eq02_b( 4) <= not( eq01  ( 8) and eq01  ( 9) );  --lv1 x1
  u_10_eq02: eq02_b( 5) <= not( eq01  (10) and eq01  (11) );  --lv1 x1
  u_12_eq02: eq02_b( 6) <= not( eq01  (12) and eq01  (13) );  --lv1 x1
  u_14_eq02: eq02_b( 7) <= not( eq01  (14) and eq01  (15) );  --lv1 x1
  u_16_eq02: eq02_b( 8) <= not( eq01  (16) and eq01  (17) );  --lv1 x1
  u_18_eq02: eq02_b( 9) <= not( eq01  (18) and eq01  (19) );  --lv1 x1
  u_20_eq02: eq02_b(10) <= not( eq01  (20) and eq01  (21) );  --lv1 x1
  u_22_eq02: eq02_b(11) <= not( eq01  (22) and eq01  (23) );  --lv1 x1
  u_24_eq02: eq02_b(12) <= not( eq01  (24) and eq01  (25) );  --lv1 x1
  u_26_eq02: eq02_b(13) <= not( eq01  (26) and eq01  (27) );  --lv1 x1
  u_28_eq02: eq02_b(14) <= not( eq01  (28) and eq01  (29) );  --lv1 x1

  u_01_eq04: eq04  ( 0) <= not( eq02_b( 0) or  eq02_b( 1) );  --lv2 x2
  u_05_eq04: eq04  ( 1) <= not( eq02_b( 2) or  eq02_b( 3) );  --lv2 x2
  u_09_eq04: eq04  ( 2) <= not( eq02_b( 4) or  eq02_b( 5) );  --lv2 x2
  u_13_eq04: eq04  ( 3) <= not( eq02_b( 6) or  eq02_b( 7) );  --lv2 x2
  u_17_eq04: eq04  ( 4) <= not( eq02_b( 8) or  eq02_b( 9) );  --lv2 x2
  u_21_eq04: eq04  ( 5) <= not( eq02_b(10) or  eq02_b(11) );  --lv2 x2
  u_25_eq04: eq04  ( 6) <= not( eq02_b(12) or  eq02_b(13) );  --lv2 x2
  u_29_eq04: eq04  ( 7) <= not( eq02_b(14)                );  --lv2 x2

  u_03_eq08: eq08_b( 0) <= not( eq04  ( 0) and eq04  ( 1) );  --lv3 x4 r
  u_11_eq08: eq08_b( 1) <= not( eq04  ( 2) and eq04  ( 3) );  --lv3 x4 r
  u_19_eq08: eq08_b( 2) <= not( eq04  ( 4) and eq04  ( 5) );  --lv3 x4 r
  u_27_eq08: eq08_b( 3) <= not( eq04  ( 6) and eq04  ( 7) );  --lv3 x4 r

  u_07_eq16: eq16  ( 0) <= not( eq08_b( 0) or  eq08_b( 1) );  --lv4 x6 r
  u_23_eq16: eq16  ( 1) <= not( eq08_b( 2) or  eq08_b( 3) );  --lv4 x6 r

  u_15_eq32: eq_b       <= not( eq16  ( 0) and eq16  ( 1) );  --lv5 x8 r --output

end; -- iuq_ic_dir_cmp30 ARCHITECTURE
