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
library support; 
use support.power_logic_pkg.all;
library tri; use tri.tri_latches_pkg.all;

entity fuq_gst_add11 is
  port(
     a_b   :in  std_ulogic_vector(0 to 10);
     b_b   :in  std_ulogic_vector(0 to 10);
     s0    :out std_ulogic_vector(0 to 10)  

 );




end fuq_gst_add11;

architecture fuq_gst_add11 of fuq_gst_add11 is

  signal p1      :std_ulogic_vector(0 to 10);
  signal g1      :std_ulogic_vector(1 to 10);
  signal t1      :std_ulogic_vector(1 to  9);
  signal g2_b    :std_ulogic_vector(1 to 10);
  signal g4      :std_ulogic_vector(1 to 10);
  signal g8_b    :std_ulogic_vector(1 to 10);
  signal c16     :std_ulogic_vector(1 to 10);
  signal t2_b    :std_ulogic_vector(1 to 8);
  signal t4      :std_ulogic_vector(1 to 6);
  signal t8_b    :std_ulogic_vector(1 to 2);






begin


u_p1:  p1(0 to 10) <=    ( a_b(0 to 10) xor b_b(0 to 10) );
u_g1:  g1(1 to 10) <= not( a_b(1 to 10) or  b_b(1 to 10) );
u_t1:  t1(1 to  9) <= not( a_b(1 to  9) and b_b(1 to  9) );


 u_g2_01: g2_b(1)  <= not( g1(1)  or ( t1(1) and g1(2)  ) );
 u_g2_02: g2_b(2)  <= not( g1(2)  or ( t1(2) and g1(3)  ) );
 u_g2_03: g2_b(3)  <= not( g1(3)  or ( t1(3) and g1(4)  ) );
 u_g2_04: g2_b(4)  <= not( g1(4)  or ( t1(4) and g1(5)  ) );
 u_g2_05: g2_b(5)  <= not( g1(5)  or ( t1(5) and g1(6)  ) );
 u_g2_06: g2_b(6)  <= not( g1(6)  or ( t1(6) and g1(7)  ) );
 u_g2_07: g2_b(7)  <= not( g1(7)  or ( t1(7) and g1(8)  ) );
 u_g2_08: g2_b(8)  <= not( g1(8)  or ( t1(8) and g1(9)  ) );
 u_g2_09: g2_b(9)  <= not( g1(9)  or ( t1(9) and g1(10) ) ); 
 u_g2_10: g2_b(10) <= not( g1(10) ); 

 u_t2_01: t2_b(1)  <= not(             t1(1) and t1(2)    );
 u_t2_02: t2_b(2)  <= not(             t1(2) and t1(3)    );
 u_t2_03: t2_b(3)  <= not(             t1(3) and t1(4)    );
 u_t2_04: t2_b(4)  <= not(             t1(4) and t1(5)    );
 u_t2_05: t2_b(5)  <= not(             t1(5) and t1(6)    );
 u_t2_06: t2_b(6)  <= not(             t1(6) and t1(7)    );
 u_t2_07: t2_b(7)  <= not(             t1(7) and t1(8)    );
 u_t2_08: t2_b(8)  <= not(             t1(8) and t1(9)    );



 u_g4_01: g4(1)  <= not( g2_b(1)  and ( t2_b(1) or g2_b(3)  ) );
 u_g4_02: g4(2)  <= not( g2_b(2)  and ( t2_b(2) or g2_b(4)  ) );
 u_g4_03: g4(3)  <= not( g2_b(3)  and ( t2_b(3) or g2_b(5)  ) );
 u_g4_04: g4(4)  <= not( g2_b(4)  and ( t2_b(4) or g2_b(6)  ) );
 u_g4_05: g4(5)  <= not( g2_b(5)  and ( t2_b(5) or g2_b(7)  ) );
 u_g4_06: g4(6)  <= not( g2_b(6)  and ( t2_b(6) or g2_b(8)  ) );
 u_g4_07: g4(7)  <= not( g2_b(7)  and ( t2_b(7) or g2_b(9)  ) );
 u_g4_08: g4(8)  <= not( g2_b(8)  and ( t2_b(8) or g2_b(10) ) );
 u_g4_09: g4(9)  <= not( g2_b(9)  );
 u_g4_10: g4(10) <= not( g2_b(10) );

 u_t4_01: t4(1)  <= not(                t2_b(1) or t2_b(3)    );
 u_t4_02: t4(2)  <= not(                t2_b(2) or t2_b(4)    );
 u_t4_03: t4(3)  <= not(                t2_b(3) or t2_b(5)    );
 u_t4_04: t4(4)  <= not(                t2_b(4) or t2_b(6)    );
 u_t4_05: t4(5)  <= not(                t2_b(5) or t2_b(7)    );
 u_t4_06: t4(6)  <= not(                t2_b(6) or t2_b(8)    );



 u_g8_01: g8_b(1)  <= not( g4(1)  or  ( t4(1) and  g4(5)  ) );
 u_g8_02: g8_b(2)  <= not( g4(2)  or  ( t4(2) and  g4(6)  ) );
 u_g8_03: g8_b(3)  <= not( g4(3)  or  ( t4(3) and  g4(7)  ) );
 u_g8_04: g8_b(4)  <= not( g4(4)  or  ( t4(4) and  g4(8)  ) );
 u_g8_05: g8_b(5)  <= not( g4(5)  or  ( t4(5) and  g4(9)  ) );
 u_g8_06: g8_b(6)  <= not( g4(6)  or  ( t4(6) and  g4(10) ) );
 u_g8_07: g8_b(7)  <= not( g4(7)  );
 u_g8_08: g8_b(8)  <= not( g4(8)  );
 u_g8_09: g8_b(9)  <= not( g4(9)  );
 u_g8_10: g8_b(10) <= not( g4(10) );

 u_t8_01: t8_b(1)  <= not(              t4(1) and  t4(5)    );
 u_t8_02: t8_b(2)  <= not(              t4(2) and  t4(6)    );
          
 u_c16_01: c16(1)  <= not( g8_b(1)  and ( t8_b(1) or  g8_b(9)  ) );
 u_c16_02: c16(2)  <= not( g8_b(2)  and ( t8_b(2) or  g8_b(10) ) );
 u_c16_03: c16(3)  <= not( g8_b(3)  );
 u_c16_04: c16(4)  <= not( g8_b(4)  );
 u_c16_05: c16(5)  <= not( g8_b(5)  );
 u_c16_06: c16(6)  <= not( g8_b(6)  );
 u_c16_07: c16(7)  <= not( g8_b(7)  );
 u_c16_08: c16(8)  <= not( g8_b(8)  );
 u_c16_09: c16(9)  <= not( g8_b(9)  );
 u_c16_10: c16(10) <= not( g8_b(10) );
          



 s0(0 to 9) <= p1(0 to 9) xor c16(1 to 10);
 s0(10)     <= p1(10) ;

    
end fuq_gst_add11     ;


