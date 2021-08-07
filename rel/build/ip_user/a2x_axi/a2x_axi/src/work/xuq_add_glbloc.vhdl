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


entity xuq_add_glbloc is port(
     g01        :in  std_ulogic_vector(0 to 7) ; 
     t01        :in  std_ulogic_vector(0 to 7) ;
     g08        :out std_ulogic ;
     t08        :out std_ulogic
 );
END                                 xuq_add_glbloc;


ARCHITECTURE xuq_add_glbloc  OF xuq_add_glbloc  IS

 constant tiup : std_ulogic := '1';
 constant tidn : std_ulogic := '0';

 signal g02_b, t02_b :std_ulogic_vector(0 to 3);
 signal g04,   t04   :std_ulogic_vector(0 to 1);
 signal g08_b, t08_b :std_ulogic;







BEGIN

  u_g02_0: g02_b(0) <= not ( g01(0) or ( t01(0) and g01(1) ) );
  u_g02_1: g02_b(1) <= not ( g01(2) or ( t01(2) and g01(3) ) );
  u_g02_2: g02_b(2) <= not ( g01(4) or ( t01(4) and g01(5) ) );
  u_g02_3: g02_b(3) <= not ( g01(6) or ( t01(6) and g01(7) ) );

  u_t02_0: t02_b(0) <= not (             t01(0) and t01(1) ) ;
  u_t02_1: t02_b(1) <= not (             t01(2) and t01(3) ) ;
  u_t02_2: t02_b(2) <= not (             t01(4) and t01(5) ) ;
  u_t02_3: t02_b(3) <= not (             t01(6) and t01(7) ) ;



  u_g04_0: g04(0)   <= not ( g02_b(0) and ( t02_b(0) or  g02_b(1) ) ) ;
  u_g04_1: g04(1)   <= not ( g02_b(2) and ( t02_b(2) or  g02_b(3) ) ) ;

  u_t04_0: t04(0)   <= not (                t02_b(0) or  t02_b(1) ) ;
  u_t04_1: t04(1)   <= not (                t02_b(2) or  t02_b(3) ) ;



  u_g08_y: g08_b    <= not ( g04(0) or  ( t04(0) and g04(1) ) ) ;

  u_t08_y: t08_b    <= not (            ( t04(0) and t04(1))  ) ;



  u_g08_x: g08      <= not ( g08_b  ) ; 

  u_t08_x: t08      <= not ( t08_b  ) ; 

END; 

