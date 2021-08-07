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
library support; 
  use ibm.std_ulogic_support.all; 
  use ibm.std_ulogic_function_support.all; 
  use ibm.std_ulogic_ao_support.all; 
  use ibm.std_ulogic_mux_support.all; 

ENTITY fuq_hc16pp_lsb IS  PORT(
     x           : IN  std_ulogic_vector(0 to 13);
     y           : IN  std_ulogic_vector(0 to 12);
     s0          : OUT std_ulogic_vector(0 to 13);
     s1          : OUT std_ulogic_vector(0 to 13);
     g16         : out std_ulogic;
     t16         : out std_ulogic
);


END                                 fuq_hc16pp_lsb;

ARCHITECTURE fuq_hc16pp_lsb OF fuq_hc16pp_lsb IS

  constant tiup : std_ulogic := '1';
  constant tidn : std_ulogic := '0';


   signal g01_b :std_ulogic_vector(0 to 12);
   signal t01_b, p01_b, p01 :std_ulogic_vector(0 to 13);

   signal  g01od    :std_ulogic_vector(0 to 5);
   signal  t01od    :std_ulogic_vector(0 to 6);


   signal g02ev  , t02ev      :std_ulogic_vector(0 to 6);
   signal g02ev_b, t02ev_b    :std_ulogic_vector(1 to 6);
   signal g04ev  , t04ev      :std_ulogic_vector(1 to 6);
   signal g08ev_b, t08ev_b    :std_ulogic_vector(1 to 6);
   signal g16ev  , t16ev      :std_ulogic_vector(1 to 6);
   signal c0_b                :std_ulogic_vector(1 to 12);
   signal c1_b                :std_ulogic_vector(1 to 13);

   signal glb_g04_e01_b, glb_g04_e23_b, glb_g04_e45_b, glb_g04_e67_b :std_ulogic;
   signal glb_t04_e01_b, glb_t04_e23_b, glb_t04_e45_b, glb_t04_e67_b :std_ulogic;
   signal glb_g08_e03  , glb_g08_e47  , glb_t08_e03  , glb_t08_e47   :std_ulogic;
   signal glb_g16_e07_b, glb_t16_e07_b                               :std_ulogic;



 
BEGIN


  hc00_g01: g01_b( 0) <= not( x( 0) and y( 0) ); 
  hc01_g01: g01_b( 1) <= not( x( 1) and y( 1) ); 
  hc02_g01: g01_b( 2) <= not( x( 2) and y( 2) ); 
  hc03_g01: g01_b( 3) <= not( x( 3) and y( 3) ); 
  hc04_g01: g01_b( 4) <= not( x( 4) and y( 4) ); 
  hc05_g01: g01_b( 5) <= not( x( 5) and y( 5) ); 
  hc06_g01: g01_b( 6) <= not( x( 6) and y( 6) ); 
  hc07_g01: g01_b( 7) <= not( x( 7) and y( 7) ); 
  hc08_g01: g01_b( 8) <= not( x( 8) and y( 8) ); 
  hc09_g01: g01_b( 9) <= not( x( 9) and y( 9) ); 
  hc10_g01: g01_b(10) <= not( x(10) and y(10) ); 
  hc11_g01: g01_b(11) <= not( x(11) and y(11) ); 
  hc12_g01: g01_b(12) <= not( x(12) and y(12) ); 

  hc00_t01: t01_b( 0) <= not( x( 0) or  y( 0) ); 
  hc01_t01: t01_b( 1) <= not( x( 1) or  y( 1) ); 
  hc02_t01: t01_b( 2) <= not( x( 2) or  y( 2) ); 
  hc03_t01: t01_b( 3) <= not( x( 3) or  y( 3) ); 
  hc04_t01: t01_b( 4) <= not( x( 4) or  y( 4) ); 
  hc05_t01: t01_b( 5) <= not( x( 5) or  y( 5) ); 
  hc06_t01: t01_b( 6) <= not( x( 6) or  y( 6) ); 
  hc07_t01: t01_b( 7) <= not( x( 7) or  y( 7) ); 
  hc08_t01: t01_b( 8) <= not( x( 8) or  y( 8) ); 
  hc09_t01: t01_b( 9) <= not( x( 9) or  y( 9) ); 
  hc10_t01: t01_b(10) <= not( x(10) or  y(10) ); 
  hc11_t01: t01_b(11) <= not( x(11) or  y(11) ); 
  hc12_t01: t01_b(12) <= not( x(12) or  y(12) ); 
  hc13_t01: t01_b(13) <= not( x(13)           ); 

  hc00_p01: p01( 0) <=    ( x( 0) xor y( 0) ); 
  hc01_p01: p01( 1) <=    ( x( 1) xor y( 1) ); 
  hc02_p01: p01( 2) <=    ( x( 2) xor y( 2) ); 
  hc03_p01: p01( 3) <=    ( x( 3) xor y( 3) ); 
  hc04_p01: p01( 4) <=    ( x( 4) xor y( 4) ); 
  hc05_p01: p01( 5) <=    ( x( 5) xor y( 5) ); 
  hc06_p01: p01( 6) <=    ( x( 6) xor y( 6) ); 
  hc07_p01: p01( 7) <=    ( x( 7) xor y( 7) ); 
  hc08_p01: p01( 8) <=    ( x( 8) xor y( 8) ); 
  hc09_p01: p01( 9) <=    ( x( 9) xor y( 9) ); 
  hc10_p01: p01(10) <=    ( x(10) xor y(10) ); 
  hc11_p01: p01(11) <=    ( x(11) xor y(11) ); 
  hc12_p01: p01(12) <=    ( x(12) xor y(12) ); 
  hc13_p01: p01(13) <= not p01_b(13) ;

  hc00_p01b: p01_b( 0) <= not( p01( 0) ); 
  hc01_p01b: p01_b( 1) <= not( p01( 1) ); 
  hc02_p01b: p01_b( 2) <= not( p01( 2) ); 
  hc03_p01b: p01_b( 3) <= not( p01( 3) ); 
  hc04_p01b: p01_b( 4) <= not( p01( 4) ); 
  hc05_p01b: p01_b( 5) <= not( p01( 5) ); 
  hc06_p01b: p01_b( 6) <= not( p01( 6) ); 
  hc07_p01b: p01_b( 7) <= not( p01( 7) ); 
  hc08_p01b: p01_b( 8) <= not( p01( 8) ); 
  hc09_p01b: p01_b( 9) <= not( p01( 9) ); 
  hc10_p01b: p01_b(10) <= not( p01(10) ); 
  hc11_p01b: p01_b(11) <= not( p01(11) ); 
  hc12_p01b: p01_b(12) <= not( p01(12) ); 
  hc13_p01b: p01_b(13) <= not( x(13)           ); 

  hc01_g01o: g01od(0) <= not g01_b( 1);
  hc03_g01o: g01od(1) <= not g01_b( 3);
  hc05_g01o: g01od(2) <= not g01_b( 5);
  hc07_g01o: g01od(3) <= not g01_b( 7);
  hc09_g01o: g01od(4) <= not g01_b( 9);
  hc11_g01o: g01od(5) <= not g01_b(11);
 
  hc01_t01o: t01od(0) <= not t01_b( 1);
  hc03_t01o: t01od(1) <= not t01_b( 3);
  hc05_t01o: t01od(2) <= not t01_b( 5);
  hc07_t01o: t01od(3) <= not t01_b( 7);
  hc09_t01o: t01od(4) <= not t01_b( 9);
  hc11_t01o: t01od(5) <= not t01_b(11);
  hc13_t01o: t01od(6) <= not t01_b(13);

  

  hc12_g02: g02ev(6) <= not(                                g01_b(12) );
  hc10_g02: g02ev(5) <= not( ( t01_b(10) or g01_b(11) ) and g01_b(10) );
  hc08_g02: g02ev(4) <= not( ( t01_b( 8) or g01_b( 9) ) and g01_b( 8) );
  hc06_g02: g02ev(3) <= not( ( t01_b( 6) or g01_b( 7) ) and g01_b( 6) );
  hc04_g02: g02ev(2) <= not( ( t01_b( 4) or g01_b( 5) ) and g01_b( 4) );
  hc02_g02: g02ev(1) <= not( ( t01_b( 2) or g01_b( 3) ) and g01_b( 2) );
  hc00_g02: g02ev(0) <= not( ( t01_b( 0) or g01_b( 1) ) and g01_b( 0) );

  hc12_t02: t02ev(6) <= not( ( t01_b(12) or t01_b(13) ) and g01_b(12) );
  hc10_t02: t02ev(5) <= not( ( t01_b(10) or t01_b(11) )               );
  hc08_t02: t02ev(4) <= not( ( t01_b( 8) or t01_b( 9) )               );
  hc06_t02: t02ev(3) <= not( ( t01_b( 6) or t01_b( 7) )               );
  hc04_t02: t02ev(2) <= not( ( t01_b( 4) or t01_b( 5) )               );
  hc02_t02: t02ev(1) <= not( ( t01_b( 2) or t01_b( 3) )               );
  hc00_t02: t02ev(0) <= not( ( t01_b( 0) or t01_b( 1) )               );

 hc12_g02b:  g02ev_b(6) <= not( g02ev(6) ); 
 hc10_g02b:  g02ev_b(5) <= not( g02ev(5) ); 
 hc08_g02b:  g02ev_b(4) <= not( g02ev(4) ); 
 hc06_g02b:  g02ev_b(3) <= not( g02ev(3) ); 
 hc04_g02b:  g02ev_b(2) <= not( g02ev(2) ); 
 hc02_g02b:  g02ev_b(1) <= not( g02ev(1) ); 
                                                            
 hc12_t02b:  t02ev_b(6) <= not( t02ev(6) ); 
 hc10_t02b:  t02ev_b(5) <= not( t02ev(5) ); 
 hc08_t02b:  t02ev_b(4) <= not( t02ev(4) ); 
 hc06_t02b:  t02ev_b(3) <= not( t02ev(3) ); 
 hc04_t02b:  t02ev_b(2) <= not( t02ev(2) ); 
 hc02_t02b:  t02ev_b(1) <= not( t02ev(1) ); 


 u_glb_g04_e01: glb_g04_e01_b <= not( g02ev(0)      or  ( t02ev(0)      and g02ev(1)      ) );
 u_glb_g04_e23: glb_g04_e23_b <= not( g02ev(2)      or  ( t02ev(2)      and g02ev(3)      ) ); 
 u_glb_g04_e45: glb_g04_e45_b <= not( g02ev(4)      or  ( t02ev(4)      and g02ev(5)      ) ); 
 u_glb_g04_e67: glb_g04_e67_b <= not( g02ev(6)                                              ); 
 u_glb_t04_e01: glb_t04_e01_b <= not(                     t02ev(0)      and t02ev(1)        );
 u_glb_t04_e23: glb_t04_e23_b <= not(                     t02ev(2)      and t02ev(3)        ); 
 u_glb_t04_e45: glb_t04_e45_b <= not(                     t02ev(4)      and t02ev(5)        ); 
 u_glb_t04_e67: glb_t04_e67_b <= not(                     t02ev(6)                          ); 

 u_glb_g08_e03: glb_g08_e03   <= not( glb_g04_e01_b and ( glb_t04_e01_b or  glb_g04_e23_b ) );
 u_glb_g08_e47: glb_g08_e47   <= not( glb_g04_e45_b and ( glb_t04_e45_b or  glb_g04_e67_b ) ); 
 u_glb_t08_e03: glb_t08_e03   <= not(                     glb_t04_e01_b or  glb_t04_e23_b   );
 u_glb_t08_e47: glb_t08_e47   <= not( glb_g04_e45_b and ( glb_t04_e45_b or  glb_t04_e67_b ) ); 

 u_glb_g16_e07: glb_g16_e07_b <= not( glb_g08_e03   or  ( glb_t08_e03   and glb_g08_e47   ) );
 u_glb_t16_e07: glb_t16_e07_b <= not( glb_g08_e03   or  ( glb_t08_e03   and glb_t08_e47   ) );

 u_g16o:        g16           <= not( glb_g16_e07_b );
 u_t16o:        t16           <= not( glb_t16_e07_b );


  hc12_g04: g04ev  (6) <= not(                                 g02ev_b(6)  );
  hc10_g04: g04ev  (5) <= not( (t02ev_b(5) or  g02ev_b(6)) and g02ev_b(5)  );
  hc08_g04: g04ev  (4) <= not( (t02ev_b(4) or  g02ev_b(5)) and g02ev_b(4)  );
  hc06_g04: g04ev  (3) <= not( (t02ev_b(3) or  g02ev_b(4)) and g02ev_b(3)  );
  hc04_g04: g04ev  (2) <= not( (t02ev_b(2) or  g02ev_b(3)) and g02ev_b(2)  );
  hc02_g04: g04ev  (1) <= not( (t02ev_b(1) or  g02ev_b(2)) and g02ev_b(1)  );

                                                          
  hc12_t04: t04ev  (6) <= not(  t02ev_b(6)                                 );
  hc10_t04: t04ev  (5) <= not( (t02ev_b(5) or  t02ev_b(6)) and g02ev_b(5)  );
  hc08_t04: t04ev  (4) <= not(  t02ev_b(4) or  t02ev_b(5)                  );
  hc06_t04: t04ev  (3) <= not(  t02ev_b(3) or  t02ev_b(4)                  );
  hc04_t04: t04ev  (2) <= not(  t02ev_b(2) or  t02ev_b(3)                  );
  hc02_t04: t04ev  (1) <= not(  t02ev_b(1) or  t02ev_b(2)                  );



  hc12_g08: g08ev_b(6) <= not( g04ev  (6)                                 );
  hc10_g08: g08ev_b(5) <= not( g04ev  (5)                                 );
  hc08_g08: g08ev_b(4) <= not( g04ev  (4) or  (t04ev  (4) and g04ev  (6)) );
  hc06_g08: g08ev_b(3) <= not( g04ev  (3) or  (t04ev  (3) and g04ev  (5)) );
  hc04_g08: g08ev_b(2) <= not( g04ev  (2) or  (t04ev  (2) and g04ev  (4)) );
  hc02_g08: g08ev_b(1) <= not( g04ev  (1) or  (t04ev  (1) and g04ev  (3)) );


  hc12_t08: t08ev_b(6) <= not( t04ev  (6)                                 );
  hc10_t08: t08ev_b(5) <= not( t04ev  (5)                                 );
  hc08_t08: t08ev_b(4) <= not( g04ev  (4) or  (t04ev  (4) and t04ev  (6)) );
  hc06_t08: t08ev_b(3) <= not( g04ev  (3) or  (t04ev  (3) and t04ev  (5)) );
  hc04_t08: t08ev_b(2) <= not(                 t04ev  (2) and t04ev  (4)  );
  hc02_t08: t08ev_b(1) <= not(                 t04ev  (1) and t04ev  (3)  );



  hc12_g16: g16ev  (6) <= not(                                 g08ev_b(6) );
  hc10_g16: g16ev  (5) <= not(                                 g08ev_b(5) );
  hc08_g16: g16ev  (4) <= not(                                 g08ev_b(4) );
  hc06_g16: g16ev  (3) <= not(                                 g08ev_b(3) ); 
  hc04_g16: g16ev  (2) <= not( (t08ev_b(2) or  g08ev_b(6)) and g08ev_b(2) ); 
  hc02_g16: g16ev  (1) <= not( (t08ev_b(1) or  g08ev_b(5)) and g08ev_b(1) ); 

                                                          
  hc12_t16: t16ev  (6) <= not(                                 t08ev_b(6) );
  hc10_t16: t16ev  (5) <= not(                                 t08ev_b(5) );
  hc08_t16: t16ev  (4) <= not(                                 t08ev_b(4) );
  hc06_t16: t16ev  (3) <= not(                                 t08ev_b(3) );
  hc04_t16: t16ev  (2) <= not( (t08ev_b(2) or  t08ev_b(6)) and g08ev_b(2) ); 
  hc02_t16: t16ev  (1) <= not( (t08ev_b(1) or  t08ev_b(5)) and g08ev_b(1) ); 



  hc12_c0: c0_b(12) <= not(                g16ev  (6)                 );
  hc10_c0: c0_b(10) <= not(                g16ev  (5)                 );
  hc08_c0: c0_b( 8) <= not(                g16ev  (4)                 );
  hc06_c0: c0_b( 6) <= not(                g16ev  (3)                 );
  hc04_c0: c0_b( 4) <= not(                g16ev  (2)                 );
  hc02_c0: c0_b( 2) <= not(                g16ev  (1)                 );
                                                     
  hc12_c1: c1_b(12) <= not(                t16ev  (6)                 );
  hc10_c1: c1_b(10) <= not(                t16ev  (5)                 );
  hc08_c1: c1_b( 8) <= not(                t16ev  (4)                 );
  hc06_c1: c1_b( 6) <= not(                t16ev  (3)                 );
  hc04_c1: c1_b( 4) <= not(                t16ev  (2)                 );
  hc02_c1: c1_b( 2) <= not(                t16ev  (1)                 );

  hc11_c0: c0_b(11) <= not( (t01od(5) and g16ev  (6))  or  g01od(5));
  hc09_c0: c0_b( 9) <= not( (t01od(4) and g16ev  (5))  or  g01od(4));
  hc07_c0: c0_b( 7) <= not( (t01od(3) and g16ev  (4))  or  g01od(3));
  hc05_c0: c0_b( 5) <= not( (t01od(2) and g16ev  (3))  or  g01od(2));
  hc03_c0: c0_b( 3) <= not( (t01od(1) and g16ev  (2))  or  g01od(1));
  hc01_c0: c0_b( 1) <= not( (t01od(0) and g16ev  (1))  or  g01od(0));
                                                          
  hc13_c1: c1_b(13) <= not(                                t01od(6));
  hc11_c1: c1_b(11) <= not( (t01od(5) and t16ev  (6))  or  g01od(5));
  hc09_c1: c1_b( 9) <= not( (t01od(4) and t16ev  (5))  or  g01od(4));
  hc07_c1: c1_b( 7) <= not( (t01od(3) and t16ev  (4))  or  g01od(3));
  hc05_c1: c1_b( 5) <= not( (t01od(2) and t16ev  (3))  or  g01od(2));
  hc03_c1: c1_b( 3) <= not( (t01od(1) and t16ev  (2))  or  g01od(1));
  hc01_c1: c1_b( 1) <= not( (t01od(0) and t16ev  (1))  or  g01od(0));


  hc00_s0: s0( 0) <=    ( p01_b( 0) xor c0_b( 1) );
  hc01_s0: s0( 1) <=    ( p01_b( 1) xor c0_b( 2) );
  hc02_s0: s0( 2) <=    ( p01_b( 2) xor c0_b( 3) );
  hc03_s0: s0( 3) <=    ( p01_b( 3) xor c0_b( 4) );
  hc04_s0: s0( 4) <=    ( p01_b( 4) xor c0_b( 5) );
  hc05_s0: s0( 5) <=    ( p01_b( 5) xor c0_b( 6) );
  hc06_s0: s0( 6) <=    ( p01_b( 6) xor c0_b( 7) );
  hc07_s0: s0( 7) <=    ( p01_b( 7) xor c0_b( 8) );
  hc08_s0: s0( 8) <=    ( p01_b( 8) xor c0_b( 9) );
  hc09_s0: s0( 9) <=    ( p01_b( 9) xor c0_b(10) );
  hc10_s0: s0(10) <=    ( p01_b(10) xor c0_b(11) );
  hc11_s0: s0(11) <=    ( p01_b(11) xor c0_b(12) );
  hc12_s0: s0(12) <= not( p01_b(12)            );
  hc13_s0: s0(13) <= not( p01_b(13)            );

  hc00_s1: s1( 0) <=    ( p01_b( 0) xor c1_b( 1) );
  hc01_s1: s1( 1) <=    ( p01_b( 1) xor c1_b( 2) );
  hc02_s1: s1( 2) <=    ( p01_b( 2) xor c1_b( 3) );
  hc03_s1: s1( 3) <=    ( p01_b( 3) xor c1_b( 4) );
  hc04_s1: s1( 4) <=    ( p01_b( 4) xor c1_b( 5) );
  hc05_s1: s1( 5) <=    ( p01_b( 5) xor c1_b( 6) );
  hc06_s1: s1( 6) <=    ( p01_b( 6) xor c1_b( 7) );
  hc07_s1: s1( 7) <=    ( p01_b( 7) xor c1_b( 8) );
  hc08_s1: s1( 8) <=    ( p01_b( 8) xor c1_b( 9) );
  hc09_s1: s1( 9) <=    ( p01_b( 9) xor c1_b(10) );
  hc10_s1: s1(10) <=    ( p01_b(10) xor c1_b(11) );
  hc11_s1: s1(11) <=    ( p01_b(11) xor c1_b(12) );
  hc12_s1: s1(12) <=    ( p01_b(12) xor c1_b(13) );
  hc13_s1: s1(13) <= not( p01(13)              );


END; 



