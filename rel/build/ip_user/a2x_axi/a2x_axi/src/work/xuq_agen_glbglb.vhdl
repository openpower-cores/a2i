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



library ieee; use ieee.std_logic_1164.all ; 
library ibm; 
  use ibm.std_ulogic_support.all; 
  use ibm.std_ulogic_function_support.all; 
  use ibm.std_ulogic_ao_support.all; 
  use ibm.std_ulogic_mux_support.all; 


entity xuq_agen_glbglb is port(
     g08        :in  std_ulogic_vector(1 to 7) ; 
     t08        :in  std_ulogic_vector(1 to 6) ;
     c64_b      :out std_ulogic_vector(1 to 7)
 );



END                                 xuq_agen_glbglb;


ARCHITECTURE xuq_agen_glbglb  OF xuq_agen_glbglb  IS

 constant tiup : std_ulogic := '1';
 constant tidn : std_ulogic := '0';

 signal b1_g16_b :std_ulogic_vector(0 to 3);
 signal b1_t16_b :std_ulogic_vector(0 to 2);
 signal b1_g32   :std_ulogic_vector(0 to 1);
 signal b1_t32   :std_ulogic_vector(0 to 0);
 signal b2_g16_b :std_ulogic_vector(0 to 3);
 signal b2_t16_b :std_ulogic_vector(0 to 2);
 signal b2_g32   :std_ulogic_vector(0 to 1);
 signal b2_t32   :std_ulogic_vector(0 to 0);
 signal b3_g16_b :std_ulogic_vector(0 to 3);
 signal b3_t16_b :std_ulogic_vector(0 to 2);
 signal b3_g32   :std_ulogic_vector(0 to 1);
 signal b3_t32   :std_ulogic_vector(0 to 0);
 signal b4_g16_b :std_ulogic_vector(0 to 3);
 signal b4_t16_b :std_ulogic_vector(0 to 2);
 signal b4_g32   :std_ulogic_vector(0 to 1);
 signal b4_t32   :std_ulogic_vector(0 to 0);
 signal b5_g16_b :std_ulogic_vector(0 to 2);
 signal b5_t16_b :std_ulogic_vector(0 to 1);
 signal b5_g32   :std_ulogic_vector(0 to 1);
 signal b5_t32   :std_ulogic_vector(0 to 0);
 signal b6_g16_b :std_ulogic_vector(0 to 1);
 signal b6_t16_b :std_ulogic_vector(0 to 0);
 signal b6_g32   :std_ulogic_vector(0 to 0);
 signal b7_g16_b :std_ulogic_vector(0 to 0);
 signal b7_g32   :std_ulogic_vector(0 to 0);











BEGIN



 u1_g16_0: b1_g16_b(0) <= not( g08(1) or ( t08(1) and g08(2) )  );
 u1_g16_1: b1_g16_b(1) <= not( g08(3) or ( t08(3) and g08(4) )  );
 u1_g16_2: b1_g16_b(2) <= not( g08(5) or ( t08(5) and g08(6) )  );
 u1_g16_3: b1_g16_b(3) <= not( g08(7)                           );

 u1_t16_0: b1_t16_b(0) <= not(             t08(1) and t08(2)    );
 u1_t16_1: b1_t16_b(1) <= not(             t08(3) and t08(4)    );
 u1_t16_2: b1_t16_b(2) <= not(             t08(5) and t08(6)    );

 u1_g32_0: b1_g32(0)    <= not( b1_g16_b(0) and ( b1_t16_b(0) or  b1_g16_b(1) ) ) ;
 u1_g32_1: b1_g32(1)    <= not( b1_g16_b(2) and ( b1_t16_b(2) or  b1_g16_b(3) ) ) ; 
 u1_t32_0: b1_t32(0)    <= not(                   b1_t16_b(0) or  b1_t16_b(1)   ) ;

 u1_g64_0: c64_b(1)     <= not( b1_g32(0) or (b1_t32(0) and b1_g32(1) ) ); 



 u2_g16_0: b2_g16_b(0) <= not( g08(2) or ( t08(2) and g08(3) )  );
 u2_g16_1: b2_g16_b(1) <= not( g08(4) or ( t08(4) and g08(5) )  );
 u2_g16_2: b2_g16_b(2) <= not( g08(6)                           );
 u2_g16_3: b2_g16_b(3) <= not( g08(7)                           );

 u2_t16_0: b2_t16_b(0) <= not(             t08(2) and t08(3)    );
 u2_t16_1: b2_t16_b(1) <= not(             t08(4) and t08(5)    );
 u2_t16_2: b2_t16_b(2) <= not(             t08(6)               );

 u2_g32_0: b2_g32(0)    <= not( b2_g16_b(0) and ( b2_t16_b(0) or  b2_g16_b(1) ) ) ;
 u2_g32_1: b2_g32(1)    <= not( b2_g16_b(2) and ( b2_t16_b(2) or  b2_g16_b(3) ) ) ; 
 u2_t32_0: b2_t32(0)    <= not(                   b2_t16_b(0) or  b2_t16_b(1)   ) ;

 u2_g64_0: c64_b(2)     <= not( b2_g32(0) or (b2_t32(0) and b2_g32(1) ) ); 



 u3_g16_0: b3_g16_b(0) <= not( g08(3) or ( t08(3) and g08(4) )  );
 u3_g16_1: b3_g16_b(1) <= not( g08(5)                           );
 u3_g16_2: b3_g16_b(2) <= not( g08(6)                           );
 u3_g16_3: b3_g16_b(3) <= not( g08(7)                           );

 u3_t16_0: b3_t16_b(0) <= not(             t08(3) and t08(4)    );
 u3_t16_1: b3_t16_b(1) <= not(             t08(5)               );
 u3_t16_2: b3_t16_b(2) <= not(             t08(6)               );

 u3_g32_0: b3_g32(0)    <= not( b3_g16_b(0) and ( b3_t16_b(0) or  b3_g16_b(1) ) ) ;
 u3_g32_1: b3_g32(1)    <= not( b3_g16_b(2) and ( b3_t16_b(2) or  b3_g16_b(3) ) ) ; 
 u3_t32_0: b3_t32(0)    <= not(                   b3_t16_b(0) or  b3_t16_b(1)   ) ;

 u3_g64_0: c64_b(3)     <= not( b3_g32(0) or (b3_t32(0) and b3_g32(1) ) );  



 u4_g16_0: b4_g16_b(0) <= not( g08(4)                           );
 u4_g16_1: b4_g16_b(1) <= not( g08(5)                           );
 u4_g16_2: b4_g16_b(2) <= not( g08(6)                           );
 u4_g16_3: b4_g16_b(3) <= not( g08(7)                           );

 u4_t16_0: b4_t16_b(0) <= not(             t08(4)               );
 u4_t16_1: b4_t16_b(1) <= not(             t08(5)               );
 u4_t16_2: b4_t16_b(2) <= not(             t08(6)               );

 u4_g32_0: b4_g32(0)    <= not( b4_g16_b(0) and ( b4_t16_b(0) or  b4_g16_b(1) ) ) ;
 u4_g32_1: b4_g32(1)    <= not( b4_g16_b(2) and ( b4_t16_b(2) or  b4_g16_b(3) ) ) ; 
 u4_t32_0: b4_t32(0)    <= not(                   b4_t16_b(0) or  b4_t16_b(1)   ) ;

 u4_g64_0: c64_b(4)     <= not( b4_g32(0) or (b4_t32(0) and b4_g32(1) ) );  



 u5_g16_0: b5_g16_b(0) <= not( g08(5)                           );
 u5_g16_1: b5_g16_b(1) <= not( g08(6)                           );
 u5_g16_2: b5_g16_b(2) <= not( g08(7)                           );

 u5_t16_0: b5_t16_b(0) <= not(             t08(5)               );
 u5_t16_1: b5_t16_b(1) <= not(             t08(6)               );

 u5_g32_0: b5_g32(0)    <= not( b5_g16_b(0) and ( b5_t16_b(0) or  b5_g16_b(1) ) ) ;
 u5_g32_1: b5_g32(1)    <= not( b5_g16_b(2)                                     ) ;
 u5_t32_0: b5_t32(0)    <= not(                   b5_t16_b(0) or  b5_t16_b(1)   ) ;

 u5_g64_0: c64_b(5)     <= not( b5_g32(0) or (b5_t32(0) and b5_g32(1) ) );  



 u6_g16_0: b6_g16_b(0) <= not( g08(6)                           );
 u6_g16_1: b6_g16_b(1) <= not( g08(7)                           );

 u6_t16_0: b6_t16_b(0) <= not(             t08(6)               );


 u6_g32_0: b6_g32(0)    <= not( b6_g16_b(0) and ( b6_t16_b(0) or  b6_g16_b(1) ) ) ;


 u6_g64_0: c64_b(6)     <= not( b6_g32(0) ) ;  


 u7_g16_0: b7_g16_b(0) <= not( g08(7)                           );

 u7_g32_0: b7_g32(0)    <= not( b7_g16_b(0) );

 u7_g64_0: c64_b(7)     <= not( b7_g32(0) ) ;  


END; 












