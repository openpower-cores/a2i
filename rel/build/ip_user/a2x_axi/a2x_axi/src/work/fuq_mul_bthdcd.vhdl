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
use ieee.std_logic_1164.all;
library ibm;
use ibm.std_ulogic_support.all;
use ibm.std_ulogic_function_support.all;
use ibm.std_ulogic_ao_support.all;
use ibm.std_ulogic_mux_support.all;

entity fuq_mul_bthdcd is
  port(
    i0    : in  std_ulogic;
    i1    : in  std_ulogic;
    i2    : in  std_ulogic;
    s_neg : out std_ulogic;
    s_x   : out std_ulogic;
    s_x2  : out std_ulogic);





end fuq_mul_bthdcd;

architecture fuq_mul_bthdcd of fuq_mul_bthdcd is


 signal s_add    :std_ulogic;
 signal sx1_a0_b :std_ulogic; 
 signal sx1_a1_b :std_ulogic; 
 signal sx1_t    :std_ulogic; 
 signal sx1_i    :std_ulogic; 
 signal sx2_a0_b :std_ulogic; 
 signal sx2_a1_b :std_ulogic; 
 signal sx2_t    :std_ulogic; 
 signal sx2_i    :std_ulogic;
 signal i0_b, i1_b, i2_b :std_ulogic;









begin



u_0i: i0_b <= not( i0 );
u_1i: i1_b <= not( i1 );
u_2i: i2_b <= not( i2 );


u_add: s_add <= not( i0 );
u_sub: s_neg <= not( s_add );

u_sx1_a0: sx1_a0_b <= not(          i1_b and i2   ) ;
u_sx1_a1: sx1_a1_b <= not(          i1   and i2_b ) ;
u_sx1_t:  sx1_t    <= not( sx1_a0_b and sx1_a1_b  ) ;   
u_sx1_i:  sx1_i    <= not( sx1_t );
u_sx1_ii: s_x      <= not( sx1_i );

u_sx2_a0: sx2_a0_b <= not( i0   and i1_b and i2_b ) ;
u_sx2_a1: sx2_a1_b <= not( i0_b and i1   and i2   ) ;
u_sx2_t:  sx2_t    <= not( sx2_a0_b and sx2_a1_b  ) ;   
u_sx2_i:  sx2_i    <= not( sx2_t );
u_sx2_ii: s_x2     <= not( sx2_i );





end;


