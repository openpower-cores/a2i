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

--  Description:  XU LSU Compare Logic


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

entity xuq_lsu_cmp_cmp36e is
generic( expand_type: integer := 2  ); -- 0 - ibm tech, 1 - other );
port(
       enable_lsb          :in  std_ulogic; -- when "0" the LSB is disabled
       d0                  :in  std_ulogic_vector(0 to 35);
       d1                  :in  std_ulogic_vector(0 to 35);
       eq                  :out std_ulogic
);





end xuq_lsu_cmp_cmp36e; -- ENTITY

architecture xuq_lsu_cmp_cmp36e of xuq_lsu_cmp_cmp36e is
   constant tiup : std_ulogic := '1';
   constant tidn : std_ulogic := '0';

   signal eq01_b   :std_ulogic_vector(0 to 35) ;
   signal eq02     :std_ulogic_vector(0 to 18) ;
   signal eq04_b   :std_ulogic_vector(0 to  9);
   signal eq08     :std_ulogic_vector(0 to  4);
   signal eq24_b   :std_ulogic_vector(0 to  1);


begin


      u_eq01: eq01_b(0 to 35) <= ( d0(0 to 35) xor d1(0 to 35) );

      u_eq_00: eq02  ( 0) <= not( eq01_b( 0) or  eq01_b( 1)    );
      u_eq_02: eq02  ( 1) <= not( eq01_b( 2) or  eq01_b( 3)    );
      u_eq_04: eq02  ( 2) <= not( eq01_b( 4) or  eq01_b( 5)    );
      u_eq_06: eq02  ( 3) <= not( eq01_b( 6) or  eq01_b( 7)    );
      u_eq_08: eq02  ( 4) <= not( eq01_b( 8) or  eq01_b( 9)    );
      u_eq_10: eq02  ( 5) <= not( eq01_b(10) or  eq01_b(11)    );
      u_eq_12: eq02  ( 6) <= not( eq01_b(12) or  eq01_b(13)    );
      u_eq_14: eq02  ( 7) <= not( eq01_b(14) or  eq01_b(15)    );
      u_eq_16: eq02  ( 8) <= not( eq01_b(16) or  eq01_b(17)    );
      u_eq_18: eq02  ( 9) <= not( eq01_b(18) or  eq01_b(19)    );
      u_eq_20: eq02  (10) <= not( eq01_b(20) or  eq01_b(21)    );
      u_eq_22: eq02  (11) <= not( eq01_b(22) or  eq01_b(23)    );
      u_eq_24: eq02  (12) <= not( eq01_b(24) or  eq01_b(25)    );
      u_eq_26: eq02  (13) <= not( eq01_b(26) or  eq01_b(27)    );
      u_eq_28: eq02  (14) <= not( eq01_b(28) or  eq01_b(29)    );
      u_eq_30: eq02  (15) <= not( eq01_b(30) or  eq01_b(31)    );
      u_eq_31: eq02  (16) <= not( eq01_b(32) or  eq01_b(33)    );
      u_eq_33: eq02  (17) <= not( eq01_b(34)                   );
      u_eq_35: eq02  (18) <= not( eq01_b(35) and enable_lsb    );
    
      u_eq_01: eq04_b( 0) <= not( eq02  ( 0) and eq02  ( 1)    );
      u_eq_05: eq04_b( 1) <= not( eq02  ( 2) and eq02  ( 3)    );
      u_eq_09: eq04_b( 2) <= not( eq02  ( 4) and eq02  ( 5)    );
      u_eq_13: eq04_b( 3) <= not( eq02  ( 6) and eq02  ( 7)    );
      u_eq_17: eq04_b( 4) <= not( eq02  ( 8) and eq02  ( 9)    );
      u_eq_21: eq04_b( 5) <= not( eq02  (10) and eq02  (11)    );
      u_eq_25: eq04_b( 6) <= not( eq02  (12) and eq02  (13)    );
      u_eq_29: eq04_b( 7) <= not( eq02  (14) and eq02  (15)    );
      u_eq_32: eq04_b( 8) <= not( eq02  (16) and eq02  (17)    );
      u_eq_36: eq04_b( 9) <= not( eq02  (18)                   );
    
      u_eq_03: eq08  ( 0) <= not( eq04_b( 0) or  eq04_b( 1)    );
      u_eq_11: eq08  ( 1) <= not( eq04_b( 2) or  eq04_b( 3)    );
      u_eq_19: eq08  ( 2) <= not( eq04_b( 4) or  eq04_b( 5)    );
      u_eq_27: eq08  ( 3) <= not( eq04_b( 6) or  eq04_b( 7)    );
      u_eq_34: eq08  ( 4) <= not( eq04_b( 8) or  eq04_b( 9)    );
    
      u_eq_07: eq24_b( 0) <= not( eq08  ( 0) and eq08  ( 1)  and eq08  ( 2)     );
      u_eq_23: eq24_b( 1) <= not( eq08  ( 3) and eq08  ( 4)    );
    
      u_eq_15: eq         <= not( eq24_b( 0) or  eq24_b( 1)    ); -- output


end; -- xuq_lsu_cmp_cmp36e ARCHITECTURE
