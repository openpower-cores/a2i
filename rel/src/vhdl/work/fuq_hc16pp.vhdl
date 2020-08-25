-- © IBM Corp. 2020
-- This softcore is licensed under and subject to the terms of the CC-BY 4.0
-- license (https://creativecommons.org/licenses/by/4.0/legalcode). 
-- Additional rights, including the right to physically implement a softcore 
-- that is compliant with the required sections of the Power ISA 
-- Specification, will be available at no cost via the OpenPOWER Foundation. 
-- This README will be updated with additional information when OpenPOWER's 
-- license is available.



library ieee; use ieee.std_logic_1164.all ; 

library ibm;
  use ibm.std_ulogic_support.all; 
  use ibm.std_ulogic_function_support.all; 
  use ibm.std_ulogic_ao_support.all; 
  use ibm.std_ulogic_mux_support.all; 

ENTITY fuq_hc16pp IS  PORT(
     x           : IN  std_ulogic_vector(0 to 15);
     y           : IN  std_ulogic_vector(0 to 15);
     ci0         : IN  std_ulogic;
     ci0_b       : IN  std_ulogic;
     ci1         : IN  std_ulogic;
     ci1_b       : IN  std_ulogic;
     s0          : OUT std_ulogic_vector(0 to 15);
     s1          : OUT std_ulogic_vector(0 to 15);
     g16         : out std_ulogic;
     t16         : out std_ulogic
);



END                                 fuq_hc16pp;

ARCHITECTURE fuq_hc16pp OF fuq_hc16pp IS

   signal g01_b, t01_b, p01_b, p01 :std_ulogic_vector(0 to 15);
   signal g01od,   t01od      :std_ulogic_vector(0 to 7);
   signal g02ev  , t02ev      :std_ulogic_vector(0 to 7);
   signal g02ev_b , t02ev_b   :std_ulogic_vector(1 to 7);
   signal g04ev,    t04ev     :std_ulogic_vector(1 to 7);
   signal g08ev_b, t08ev_b    :std_ulogic_vector(1 to 7);
   signal g16ev, t16ev        :std_ulogic_vector(1 to 7);
   signal c0_b  ,    c1_b     :std_ulogic_vector(1 to 15);
   signal s0_raw, s1_raw      :std_ulogic_vector(0 to 15);
   signal s0_x_b, s0_y_b      :std_ulogic_vector(0 to 15);
   signal s1_x_b, s1_y_b      :std_ulogic_vector(0 to 15);

   signal glb_g04_e01_b, glb_g04_e23_b, glb_g04_e45_b, glb_g04_e67_b :std_ulogic;
   signal glb_t04_e01_b, glb_t04_e23_b, glb_t04_e45_b, glb_t04_e67_b :std_ulogic;
   signal glb_g08_e03  , glb_g08_e47  , glb_t08_e03  , glb_t08_e47   :std_ulogic;
   signal glb_g16_e07_b, glb_t16_e07_b                               :std_ulogic;











BEGIN

--//#####################################
--//## group 1
--//#####################################

  hc00_g01: g01_b( 0) <= not( x( 0) and y( 0) ); --critical
  hc01_g01: g01_b( 1) <= not( x( 1) and y( 1) ); --critical
  hc02_g01: g01_b( 2) <= not( x( 2) and y( 2) ); --critical
  hc03_g01: g01_b( 3) <= not( x( 3) and y( 3) ); --critical
  hc04_g01: g01_b( 4) <= not( x( 4) and y( 4) ); --critical
  hc05_g01: g01_b( 5) <= not( x( 5) and y( 5) ); --critical
  hc06_g01: g01_b( 6) <= not( x( 6) and y( 6) ); --critical
  hc07_g01: g01_b( 7) <= not( x( 7) and y( 7) ); --critical
  hc08_g01: g01_b( 8) <= not( x( 8) and y( 8) ); --critical
  hc09_g01: g01_b( 9) <= not( x( 9) and y( 9) ); --critical
  hc10_g01: g01_b(10) <= not( x(10) and y(10) ); --critical
  hc11_g01: g01_b(11) <= not( x(11) and y(11) ); --critical
  hc12_g01: g01_b(12) <= not( x(12) and y(12) ); --critical
  hc13_g01: g01_b(13) <= not( x(13) and y(13) ); --critical
  hc14_g01: g01_b(14) <= not( x(14) and y(14) ); --critical
  hc15_g01: g01_b(15) <= not( x(15) and y(15) ); --critical

  hc00_t01: t01_b( 0) <= not( x( 0) or  y( 0) ); --critical
  hc01_t01: t01_b( 1) <= not( x( 1) or  y( 1) ); --critical
  hc02_t01: t01_b( 2) <= not( x( 2) or  y( 2) ); --critical
  hc03_t01: t01_b( 3) <= not( x( 3) or  y( 3) ); --critical
  hc04_t01: t01_b( 4) <= not( x( 4) or  y( 4) ); --critical
  hc05_t01: t01_b( 5) <= not( x( 5) or  y( 5) ); --critical
  hc06_t01: t01_b( 6) <= not( x( 6) or  y( 6) ); --critical
  hc07_t01: t01_b( 7) <= not( x( 7) or  y( 7) ); --critical
  hc08_t01: t01_b( 8) <= not( x( 8) or  y( 8) ); --critical
  hc09_t01: t01_b( 9) <= not( x( 9) or  y( 9) ); --critical
  hc10_t01: t01_b(10) <= not( x(10) or  y(10) ); --critical
  hc11_t01: t01_b(11) <= not( x(11) or  y(11) ); --critical
  hc12_t01: t01_b(12) <= not( x(12) or  y(12) ); --critical
  hc13_t01: t01_b(13) <= not( x(13) or  y(13) ); --critical
  hc14_t01: t01_b(14) <= not( x(14) or  y(14) ); --critical
  hc15_t01: t01_b(15) <= not( x(15) or  y(15) ); --critical

  hc00_p01: p01( 0) <=    ( x( 0) xor y( 0) ); --not critical
  hc01_p01: p01( 1) <=    ( x( 1) xor y( 1) ); --not critical
  hc02_p01: p01( 2) <=    ( x( 2) xor y( 2) ); --not critical
  hc03_p01: p01( 3) <=    ( x( 3) xor y( 3) ); --not critical
  hc04_p01: p01( 4) <=    ( x( 4) xor y( 4) ); --not critical
  hc05_p01: p01( 5) <=    ( x( 5) xor y( 5) ); --not critical
  hc06_p01: p01( 6) <=    ( x( 6) xor y( 6) ); --not critical
  hc07_p01: p01( 7) <=    ( x( 7) xor y( 7) ); --not critical
  hc08_p01: p01( 8) <=    ( x( 8) xor y( 8) ); --not critical
  hc09_p01: p01( 9) <=    ( x( 9) xor y( 9) ); --not critical
  hc10_p01: p01(10) <=    ( x(10) xor y(10) ); --not critical
  hc11_p01: p01(11) <=    ( x(11) xor y(11) ); --not critical
  hc12_p01: p01(12) <=    ( x(12) xor y(12) ); --not critical
  hc13_p01: p01(13) <=    ( x(13) xor y(13) ); --not critical
  hc14_p01: p01(14) <=    ( x(14) xor y(14) ); --not critical
  hc15_p01: p01(15) <=    ( x(15) xor y(15) ); --not critical

  hc00_p01b: p01_b( 0) <= not( p01( 0) ); --not critical
  hc01_p01b: p01_b( 1) <= not( p01( 1) ); --not critical
  hc02_p01b: p01_b( 2) <= not( p01( 2) ); --not critical
  hc03_p01b: p01_b( 3) <= not( p01( 3) ); --not critical
  hc04_p01b: p01_b( 4) <= not( p01( 4) ); --not critical
  hc05_p01b: p01_b( 5) <= not( p01( 5) ); --not critical
  hc06_p01b: p01_b( 6) <= not( p01( 6) ); --not critical
  hc07_p01b: p01_b( 7) <= not( p01( 7) ); --not critical
  hc08_p01b: p01_b( 8) <= not( p01( 8) ); --not critical
  hc09_p01b: p01_b( 9) <= not( p01( 9) ); --not critical
  hc10_p01b: p01_b(10) <= not( p01(10) ); --not critical
  hc11_p01b: p01_b(11) <= not( p01(11) ); --not critical
  hc12_p01b: p01_b(12) <= not( p01(12) ); --not critical
  hc13_p01b: p01_b(13) <= not( p01(13) ); --not critical
  hc14_p01b: p01_b(14) <= not( p01(14) ); --not critical
  hc15_p01b: p01_b(15) <= not( p01(15) ); --not critical


  hc01_g01o: g01od(0) <= not g01_b( 1);
  hc03_g01o: g01od(1) <= not g01_b( 3);
  hc05_g01o: g01od(2) <= not g01_b( 5);
  hc07_g01o: g01od(3) <= not g01_b( 7);
  hc09_g01o: g01od(4) <= not g01_b( 9);
  hc11_g01o: g01od(5) <= not g01_b(11);
  hc13_g01o: g01od(6) <= not g01_b(13);
  hc15_g01o: g01od(7) <= not g01_b(15);

  hc01_t01o: t01od(0) <= not t01_b( 1);
  hc03_t01o: t01od(1) <= not t01_b( 3);
  hc05_t01o: t01od(2) <= not t01_b( 5);
  hc07_t01o: t01od(3) <= not t01_b( 7);
  hc09_t01o: t01od(4) <= not t01_b( 9);
  hc11_t01o: t01od(5) <= not t01_b(11);
  hc13_t01o: t01od(6) <= not t01_b(13);
  hc15_t01o: t01od(7) <= not t01_b(15);



  
--//#####################################
--//## group 2   // local and global (shared)
--//#####################################

 hc14_g02:  g02ev(7) <= not( ( t01_b(14) or g01_b(15) ) and g01_b(14) );--final
 hc12_g02:  g02ev(6) <= not( ( t01_b(12) or g01_b(13) ) and g01_b(12) );
 hc10_g02:  g02ev(5) <= not( ( t01_b(10) or g01_b(11) ) and g01_b(10) );
 hc08_g02:  g02ev(4) <= not( ( t01_b( 8) or g01_b( 9) ) and g01_b( 8) );
 hc06_g02:  g02ev(3) <= not( ( t01_b( 6) or g01_b( 7) ) and g01_b( 6) );
 hc04_g02:  g02ev(2) <= not( ( t01_b( 4) or g01_b( 5) ) and g01_b( 4) );
 hc02_g02:  g02ev(1) <= not( ( t01_b( 2) or g01_b( 3) ) and g01_b( 2) );
 hc00_g02:  g02ev(0) <= not( ( t01_b( 0) or g01_b( 1) ) and g01_b( 0) );
                                                            
 hc14_t02:  t02ev(7) <= not( ( t01_b(14) or t01_b(15) ) and g01_b(14) );--final
 hc12_t02:  t02ev(6) <= not(   t01_b(12) or t01_b(13)                 );
 hc10_t02:  t02ev(5) <= not(   t01_b(10) or t01_b(11)                 );
 hc08_t02:  t02ev(4) <= not(   t01_b( 8) or t01_b( 9)                 );
 hc06_t02:  t02ev(3) <= not(   t01_b( 6) or t01_b( 7)                 );
 hc04_t02:  t02ev(2) <= not(   t01_b( 4) or t01_b( 5)                 );
 hc02_t02:  t02ev(1) <= not(   t01_b( 2) or t01_b( 3)                 );
 hc00_t02:  t02ev(0) <= not(   t01_b( 0) or t01_b( 1)                 );

 hc14_g02b:  g02ev_b(7) <= not( g02ev(7) ); 
 hc12_g02b:  g02ev_b(6) <= not( g02ev(6) ); 
 hc10_g02b:  g02ev_b(5) <= not( g02ev(5) ); 
 hc08_g02b:  g02ev_b(4) <= not( g02ev(4) ); 
 hc06_g02b:  g02ev_b(3) <= not( g02ev(3) ); 
 hc04_g02b:  g02ev_b(2) <= not( g02ev(2) ); 
 hc02_g02b:  g02ev_b(1) <= not( g02ev(1) ); 
                                                            
 hc14_t02b:  t02ev_b(7) <= not( t02ev(7) ); 
 hc12_t02b:  t02ev_b(6) <= not( t02ev(6) ); 
 hc10_t02b:  t02ev_b(5) <= not( t02ev(5) ); 
 hc08_t02b:  t02ev_b(4) <= not( t02ev(4) ); 
 hc06_t02b:  t02ev_b(3) <= not( t02ev(3) ); 
 hc04_t02b:  t02ev_b(2) <= not( t02ev(2) ); 
 hc02_t02b:  t02ev_b(1) <= not( t02ev(1) ); 

--//#####################################
--//## replicating for global chain
--//#####################################

 u_glb_g04_e01: glb_g04_e01_b <= not( g02ev(0)      or  ( t02ev(0)      and g02ev(1)      ) );
 u_glb_g04_e23: glb_g04_e23_b <= not( g02ev(2)      or  ( t02ev(2)      and g02ev(3)      ) ); 
 u_glb_g04_e45: glb_g04_e45_b <= not( g02ev(4)      or  ( t02ev(4)      and g02ev(5)      ) ); 
 u_glb_g04_e67: glb_g04_e67_b <= not( g02ev(6)      or  ( t02ev(6)      and g02ev(7)      ) ); 
 u_glb_t04_e01: glb_t04_e01_b <= not(                     t02ev(0)      and t02ev(1)        );
 u_glb_t04_e23: glb_t04_e23_b <= not(                     t02ev(2)      and t02ev(3)        ); 
 u_glb_t04_e45: glb_t04_e45_b <= not(                     t02ev(4)      and t02ev(5)        ); 
 u_glb_t04_e67: glb_t04_e67_b <= not( g02ev(6)      or  ( t02ev(6)      and t02ev(7)      ) ); 

 u_glb_g08_e03: glb_g08_e03   <= not( glb_g04_e01_b and ( glb_t04_e01_b or  glb_g04_e23_b ) );
 u_glb_g08_e47: glb_g08_e47   <= not( glb_g04_e45_b and ( glb_t04_e45_b or  glb_g04_e67_b ) ); 
 u_glb_t08_e03: glb_t08_e03   <= not(                     glb_t04_e01_b or  glb_t04_e23_b   );
 u_glb_t08_e47: glb_t08_e47   <= not( glb_g04_e45_b and ( glb_t04_e45_b or  glb_t04_e67_b ) ); 

 u_glb_g16_e07: glb_g16_e07_b <= not( glb_g08_e03   or  ( glb_t08_e03   and glb_g08_e47   ) );
 u_glb_t16_e07: glb_t16_e07_b <= not( glb_g08_e03   or  ( glb_t08_e03   and glb_t08_e47   ) );

 u_g16o:        g16           <= not( glb_g16_e07_b );--output
 u_t16o:        t16           <= not( glb_t16_e07_b );--output


--//#####################################
--//## group 4 // delayed for local chain ... reverse phase
--//#####################################

 hc14_g04:  g04ev(7) <= not( g02ev_b(7)                                  );
 hc12_g04:  g04ev(6) <= not( g02ev_b(6) and (t02ev_b(6) or  g02ev_b(7))  );--final
 hc10_g04:  g04ev(5) <= not( g02ev_b(5) and (t02ev_b(5) or  g02ev_b(6))  );
 hc08_g04:  g04ev(4) <= not( g02ev_b(4) and (t02ev_b(4) or  g02ev_b(5))  );
 hc06_g04:  g04ev(3) <= not( g02ev_b(3) and (t02ev_b(3) or  g02ev_b(4))  );
 hc04_g04:  g04ev(2) <= not( g02ev_b(2) and (t02ev_b(2) or  g02ev_b(3))  );
 hc02_g04:  g04ev(1) <= not( g02ev_b(1) and (t02ev_b(1) or  g02ev_b(2))  );


 hc14_t04:  t04ev(7) <= not( t02ev_b(7)                                  );
 hc12_t04:  t04ev(6) <= not( g02ev_b(6) and (t02ev_b(6) or  t02ev_b(7))  );--final
 hc10_t04:  t04ev(5) <= not(                 t02ev_b(5) or  t02ev_b(6)   );
 hc08_t04:  t04ev(4) <= not(                 t02ev_b(4) or  t02ev_b(5)   );
 hc06_t04:  t04ev(3) <= not(                 t02ev_b(3) or  t02ev_b(4)   );
 hc04_t04:  t04ev(2) <= not(                 t02ev_b(2) or  t02ev_b(3)   );
 hc02_t04:  t04ev(1) <= not(                 t02ev_b(1) or  t02ev_b(2)   );


--//#####################################
--//## group 8
--//#####################################

 hc14_g08:  g08ev_b(7) <= not( g04ev(7)                             );
 hc12_g08:  g08ev_b(6) <= not( g04ev(6)                             );
 hc10_g08:  g08ev_b(5) <= not( g04ev(5) or  (t04ev(5) and g04ev(7)) );--final
 hc08_g08:  g08ev_b(4) <= not( g04ev(4) or  (t04ev(4) and g04ev(6)) );--final
 hc06_g08:  g08ev_b(3) <= not( g04ev(3) or  (t04ev(3) and g04ev(5)) );
 hc04_g08:  g08ev_b(2) <= not( g04ev(2) or  (t04ev(2) and g04ev(4)) );
 hc02_g08:  g08ev_b(1) <= not( g04ev(1) or  (t04ev(1) and g04ev(3)) );


 hc14_t08:  t08ev_b(7) <= not( t04ev(7)                             );
 hc12_t08:  t08ev_b(6) <= not( t04ev(6)                             );
 hc10_t08:  t08ev_b(5) <= not( g04ev(5) or  (t04ev(5) and t04ev(7)) );--final
 hc08_t08:  t08ev_b(4) <= not( g04ev(4) or  (t04ev(4) and t04ev(6)) );--final
 hc06_t08:  t08ev_b(3) <= not(               t04ev(3) and t04ev(5)  );
 hc04_t08:  t08ev_b(2) <= not(               t04ev(2) and t04ev(4)  );
 hc02_t08:  t08ev_b(1) <= not(               t04ev(1) and t04ev(3)  );


--//#####################################
--//## group 16
--//#####################################

 hc14_g16: g16ev(7) <= not( g08ev_b(7)                                 );
 hc12_g16: g16ev(6) <= not( g08ev_b(6)                                 );
 hc10_g16: g16ev(5) <= not( g08ev_b(5)                                 );
 hc08_g16: g16ev(4) <= not( g08ev_b(4)                                 );
 hc06_g16: g16ev(3) <= not( g08ev_b(3) and (t08ev_b(3) or  g08ev_b(7)) ); --final
 hc04_g16: g16ev(2) <= not( g08ev_b(2) and (t08ev_b(2) or  g08ev_b(6)) ); --final
 hc02_g16: g16ev(1) <= not( g08ev_b(1) and (t08ev_b(1) or  g08ev_b(5)) ); --final

 hc14_t16: t16ev(7) <= not( t08ev_b(7)                                 );
 hc12_t16: t16ev(6) <= not( t08ev_b(6)                                 );
 hc10_t16: t16ev(5) <= not( t08ev_b(5)                                 );
 hc08_t16: t16ev(4) <= not( t08ev_b(4)                                 );
 hc06_t16: t16ev(3) <= not( g08ev_b(3) and (t08ev_b(3) or  t08ev_b(7)) ); --final
 hc04_t16: t16ev(2) <= not( g08ev_b(2) and (t08ev_b(2) or  t08ev_b(6)) ); --final
 hc02_t16: t16ev(1) <= not( g08ev_b(1) and (t08ev_b(1) or  t08ev_b(5)) ); --final


--//#####################################
--//## group 16 delayed
--//#####################################
                                                     
 hc14_c0:  c0_b(14) <= not(                g16ev(7)                 );
 hc12_c0:  c0_b(12) <= not(                g16ev(6)                 );
 hc10_c0:  c0_b(10) <= not(                g16ev(5)                 );
 hc08_c0:  c0_b( 8) <= not(                g16ev(4)                 );
 hc06_c0:  c0_b( 6) <= not(                g16ev(3)                 );
 hc04_c0:  c0_b( 4) <= not(                g16ev(2)                 );
 hc02_c0:  c0_b( 2) <= not(                g16ev(1)                 );

 hc14_c1:  c1_b(14) <= not(                t16ev(7)                 );
 hc12_c1:  c1_b(12) <= not(                t16ev(6)                 );
 hc10_c1:  c1_b(10) <= not(                t16ev(5)                 );
 hc08_c1:  c1_b( 8) <= not(                t16ev(4)                 );
 hc06_c1:  c1_b( 6) <= not(                t16ev(3)                 );
 hc04_c1:  c1_b( 4) <= not(                t16ev(2)                 );
 hc02_c1:  c1_b( 2) <= not(                t16ev(1)                 );

 hc15_c0:  c0_b(15) <= not(                              g01od(7));
 hc13_c0:  c0_b(13) <= not( (t01od(6) and g16ev(7))  or  g01od(6));
 hc11_c0:  c0_b(11) <= not( (t01od(5) and g16ev(6))  or  g01od(5));
 hc09_c0:  c0_b( 9) <= not( (t01od(4) and g16ev(5))  or  g01od(4));
 hc07_c0:  c0_b( 7) <= not( (t01od(3) and g16ev(4))  or  g01od(3));
 hc05_c0:  c0_b( 5) <= not( (t01od(2) and g16ev(3))  or  g01od(2));
 hc03_c0:  c0_b( 3) <= not( (t01od(1) and g16ev(2))  or  g01od(1));
 hc01_c0:  c0_b( 1) <= not( (t01od(0) and g16ev(1))  or  g01od(0));

 hc15_c1:  c1_b(15) <= not(  t01od(7)                            );
 hc13_c1:  c1_b(13) <= not( (t01od(6) and t16ev(7)) or  g01od(6) );
 hc11_c1:  c1_b(11) <= not( (t01od(5) and t16ev(6)) or  g01od(5) );
 hc09_c1:  c1_b( 9) <= not( (t01od(4) and t16ev(5)) or  g01od(4) );
 hc07_c1:  c1_b( 7) <= not( (t01od(3) and t16ev(4)) or  g01od(3) );
 hc05_c1:  c1_b( 5) <= not( (t01od(2) and t16ev(3)) or  g01od(2) );
 hc03_c1:  c1_b( 3) <= not( (t01od(1) and t16ev(2)) or  g01od(1) );
 hc01_c1:  c1_b( 1) <= not( (t01od(0) and t16ev(1)) or  g01od(0) );

--//#####################################
--//## sum before select
--//#####################################

 hc00_s0r:  s0_raw( 0) <=    ( p01_b( 0) xor c0_b( 1) );
 hc01_s0r:  s0_raw( 1) <=    ( p01_b( 1) xor c0_b( 2) );
 hc02_s0r:  s0_raw( 2) <=    ( p01_b( 2) xor c0_b( 3) );
 hc03_s0r:  s0_raw( 3) <=    ( p01_b( 3) xor c0_b( 4) );
 hc04_s0r:  s0_raw( 4) <=    ( p01_b( 4) xor c0_b( 5) );
 hc05_s0r:  s0_raw( 5) <=    ( p01_b( 5) xor c0_b( 6) );
 hc06_s0r:  s0_raw( 6) <=    ( p01_b( 6) xor c0_b( 7) );
 hc07_s0r:  s0_raw( 7) <=    ( p01_b( 7) xor c0_b( 8) );
 hc08_s0r:  s0_raw( 8) <=    ( p01_b( 8) xor c0_b( 9) );
 hc09_s0r:  s0_raw( 9) <=    ( p01_b( 9) xor c0_b(10) );
 hc10_s0r:  s0_raw(10) <=    ( p01_b(10) xor c0_b(11) );
 hc11_s0r:  s0_raw(11) <=    ( p01_b(11) xor c0_b(12) );
 hc12_s0r:  s0_raw(12) <=    ( p01_b(12) xor c0_b(13) );
 hc13_s0r:  s0_raw(13) <=    ( p01_b(13) xor c0_b(14) );
 hc14_s0r:  s0_raw(14) <=    ( p01_b(14) xor c0_b(15) );
 hc15_s0r:  s0_raw(15) <= not  p01_b(15);

 hc00_s1r:  s1_raw( 0) <=    ( p01_b( 0) xor c1_b( 1) );
 hc01_s1r:  s1_raw( 1) <=    ( p01_b( 1) xor c1_b( 2) );
 hc02_s1r:  s1_raw( 2) <=    ( p01_b( 2) xor c1_b( 3) );
 hc03_s1r:  s1_raw( 3) <=    ( p01_b( 3) xor c1_b( 4) );
 hc04_s1r:  s1_raw( 4) <=    ( p01_b( 4) xor c1_b( 5) );
 hc05_s1r:  s1_raw( 5) <=    ( p01_b( 5) xor c1_b( 6) );
 hc06_s1r:  s1_raw( 6) <=    ( p01_b( 6) xor c1_b( 7) );
 hc07_s1r:  s1_raw( 7) <=    ( p01_b( 7) xor c1_b( 8) );
 hc08_s1r:  s1_raw( 8) <=    ( p01_b( 8) xor c1_b( 9) );
 hc09_s1r:  s1_raw( 9) <=    ( p01_b( 9) xor c1_b(10) );
 hc10_s1r:  s1_raw(10) <=    ( p01_b(10) xor c1_b(11) );
 hc11_s1r:  s1_raw(11) <=    ( p01_b(11) xor c1_b(12) );
 hc12_s1r:  s1_raw(12) <=    ( p01_b(12) xor c1_b(13) );
 hc13_s1r:  s1_raw(13) <=    ( p01_b(13) xor c1_b(14) );
 hc14_s1r:  s1_raw(14) <=    ( p01_b(14) xor c1_b(15) );
 hc15_s1r:  s1_raw(15) <= not  s0_raw(15);


--//#####################################
--//## sum after select
--//#####################################

 
 hc00_s0x:  s0_x_b( 0) <= not( s0_raw( 0) and ci0_b      );
 hc00_s0y:  s0_y_b( 0) <= not( s1_raw( 0) and ci0        );
 hc00_s1x:  s1_x_b( 0) <= not( s0_raw( 0) and ci1_b      );
 hc00_s1y:  s1_y_b( 0) <= not( s1_raw( 0) and ci1        );
 hc00_s0:   s0    ( 0) <= not( s0_x_b( 0) and s0_y_b( 0) );
 hc00_s1:   s1    ( 0) <= not( s1_x_b( 0) and s1_y_b( 0) );

 hc01_s0x:  s0_x_b( 1) <= not( s0_raw( 1) and ci0_b      );
 hc01_s0y:  s0_y_b( 1) <= not( s1_raw( 1) and ci0        );
 hc01_s1x:  s1_x_b( 1) <= not( s0_raw( 1) and ci1_b      );
 hc01_s1y:  s1_y_b( 1) <= not( s1_raw( 1) and ci1        );
 hc01_s0:   s0    ( 1) <= not( s0_x_b( 1) and s0_y_b( 1) );
 hc01_s1:   s1    ( 1) <= not( s1_x_b( 1) and s1_y_b( 1) );

 hc02_s0x:  s0_x_b( 2) <= not( s0_raw( 2) and ci0_b      );
 hc02_s0y:  s0_y_b( 2) <= not( s1_raw( 2) and ci0        );
 hc02_s1x:  s1_x_b( 2) <= not( s0_raw( 2) and ci1_b      );
 hc02_s1y:  s1_y_b( 2) <= not( s1_raw( 2) and ci1        );
 hc02_s0:   s0    ( 2) <= not( s0_x_b( 2) and s0_y_b( 2) );
 hc02_s1:   s1    ( 2) <= not( s1_x_b( 2) and s1_y_b( 2) );

 hc03_s0x:  s0_x_b( 3) <= not( s0_raw( 3) and ci0_b      );
 hc03_s0y:  s0_y_b( 3) <= not( s1_raw( 3) and ci0        );
 hc03_s1x:  s1_x_b( 3) <= not( s0_raw( 3) and ci1_b      );
 hc03_s1y:  s1_y_b( 3) <= not( s1_raw( 3) and ci1        );
 hc03_s0:   s0    ( 3) <= not( s0_x_b( 3) and s0_y_b( 3) );
 hc03_s1:   s1    ( 3) <= not( s1_x_b( 3) and s1_y_b( 3) );

 hc04_s0x:  s0_x_b( 4) <= not( s0_raw( 4) and ci0_b      );
 hc04_s0y:  s0_y_b( 4) <= not( s1_raw( 4) and ci0        );
 hc04_s1x:  s1_x_b( 4) <= not( s0_raw( 4) and ci1_b      );
 hc04_s1y:  s1_y_b( 4) <= not( s1_raw( 4) and ci1        );
 hc04_s0:   s0    ( 4) <= not( s0_x_b( 4) and s0_y_b( 4) );
 hc04_s1:   s1    ( 4) <= not( s1_x_b( 4) and s1_y_b( 4) );

 hc05_s0x:  s0_x_b( 5) <= not( s0_raw( 5) and ci0_b      );
 hc05_s0y:  s0_y_b( 5) <= not( s1_raw( 5) and ci0        );
 hc05_s1x:  s1_x_b( 5) <= not( s0_raw( 5) and ci1_b      );
 hc05_s1y:  s1_y_b( 5) <= not( s1_raw( 5) and ci1        );
 hc05_s0:   s0    ( 5) <= not( s0_x_b( 5) and s0_y_b( 5) );
 hc05_s1:   s1    ( 5) <= not( s1_x_b( 5) and s1_y_b( 5) );

 hc06_s0x:  s0_x_b( 6) <= not( s0_raw( 6) and ci0_b      );
 hc06_s0y:  s0_y_b( 6) <= not( s1_raw( 6) and ci0        );
 hc06_s1x:  s1_x_b( 6) <= not( s0_raw( 6) and ci1_b      );
 hc06_s1y:  s1_y_b( 6) <= not( s1_raw( 6) and ci1        );
 hc06_s0:   s0    ( 6) <= not( s0_x_b( 6) and s0_y_b( 6) );
 hc06_s1:   s1    ( 6) <= not( s1_x_b( 6) and s1_y_b( 6) );

 hc07_s0x:  s0_x_b( 7) <= not( s0_raw( 7) and ci0_b      );
 hc07_s0y:  s0_y_b( 7) <= not( s1_raw( 7) and ci0        );
 hc07_s1x:  s1_x_b( 7) <= not( s0_raw( 7) and ci1_b      );
 hc07_s1y:  s1_y_b( 7) <= not( s1_raw( 7) and ci1        );
 hc07_s0:   s0    ( 7) <= not( s0_x_b( 7) and s0_y_b( 7) );
 hc07_s1:   s1    ( 7) <= not( s1_x_b( 7) and s1_y_b( 7) );

 hc08_s0x:  s0_x_b( 8) <= not( s0_raw( 8) and ci0_b      );
 hc08_s0y:  s0_y_b( 8) <= not( s1_raw( 8) and ci0        );
 hc08_s1x:  s1_x_b( 8) <= not( s0_raw( 8) and ci1_b      );
 hc08_s1y:  s1_y_b( 8) <= not( s1_raw( 8) and ci1        );
 hc08_s0:   s0    ( 8) <= not( s0_x_b( 8) and s0_y_b( 8) );
 hc08_s1:   s1    ( 8) <= not( s1_x_b( 8) and s1_y_b( 8) );

 hc09_s0x:  s0_x_b( 9) <= not( s0_raw( 9) and ci0_b      );
 hc09_s0y:  s0_y_b( 9) <= not( s1_raw( 9) and ci0        );
 hc09_s1x:  s1_x_b( 9) <= not( s0_raw( 9) and ci1_b      );
 hc09_s1y:  s1_y_b( 9) <= not( s1_raw( 9) and ci1        );
 hc09_s0:   s0    ( 9) <= not( s0_x_b( 9) and s0_y_b( 9) );
 hc09_s1:   s1    ( 9) <= not( s1_x_b( 9) and s1_y_b( 9) );

 hc10_s0x:  s0_x_b(10) <= not( s0_raw(10) and ci0_b      );
 hc10_s0y:  s0_y_b(10) <= not( s1_raw(10) and ci0        );
 hc10_s1x:  s1_x_b(10) <= not( s0_raw(10) and ci1_b      );
 hc10_s1y:  s1_y_b(10) <= not( s1_raw(10) and ci1        );
 hc10_s0:   s0    (10) <= not( s0_x_b(10) and s0_y_b(10) );
 hc10_s1:   s1    (10) <= not( s1_x_b(10) and s1_y_b(10) );

 hc11_s0x:  s0_x_b(11) <= not( s0_raw(11) and ci0_b      );
 hc11_s0y:  s0_y_b(11) <= not( s1_raw(11) and ci0        );
 hc11_s1x:  s1_x_b(11) <= not( s0_raw(11) and ci1_b      );
 hc11_s1y:  s1_y_b(11) <= not( s1_raw(11) and ci1        );
 hc11_s0:   s0    (11) <= not( s0_x_b(11) and s0_y_b(11) );
 hc11_s1:   s1    (11) <= not( s1_x_b(11) and s1_y_b(11) );

 hc12_s0x:  s0_x_b(12) <= not( s0_raw(12) and ci0_b      );
 hc12_s0y:  s0_y_b(12) <= not( s1_raw(12) and ci0        );
 hc12_s1x:  s1_x_b(12) <= not( s0_raw(12) and ci1_b      );
 hc12_s1y:  s1_y_b(12) <= not( s1_raw(12) and ci1        );
 hc12_s0:   s0    (12) <= not( s0_x_b(12) and s0_y_b(12) );
 hc12_s1:   s1    (12) <= not( s1_x_b(12) and s1_y_b(12) );

 hc13_s0x:  s0_x_b(13) <= not( s0_raw(13) and ci0_b      );
 hc13_s0y:  s0_y_b(13) <= not( s1_raw(13) and ci0        );
 hc13_s1x:  s1_x_b(13) <= not( s0_raw(13) and ci1_b      );
 hc13_s1y:  s1_y_b(13) <= not( s1_raw(13) and ci1        );
 hc13_s0:   s0    (13) <= not( s0_x_b(13) and s0_y_b(13) );
 hc13_s1:   s1    (13) <= not( s1_x_b(13) and s1_y_b(13) );

 hc14_s0x:  s0_x_b(14) <= not( s0_raw(14) and ci0_b      );
 hc14_s0y:  s0_y_b(14) <= not( s1_raw(14) and ci0        );
 hc14_s1x:  s1_x_b(14) <= not( s0_raw(14) and ci1_b      );
 hc14_s1y:  s1_y_b(14) <= not( s1_raw(14) and ci1        );
 hc14_s0:   s0    (14) <= not( s0_x_b(14) and s0_y_b(14) );
 hc14_s1:   s1    (14) <= not( s1_x_b(14) and s1_y_b(14) );

 hc15_s0x:  s0_x_b(15) <= not( s0_raw(15) and ci0_b      );
 hc15_s0y:  s0_y_b(15) <= not( s1_raw(15) and ci0        );
 hc15_s1x:  s1_x_b(15) <= not( s0_raw(15) and ci1_b      );
 hc15_s1y:  s1_y_b(15) <= not( s1_raw(15) and ci1        );
 hc15_s0:   s0    (15) <= not( s0_x_b(15) and s0_y_b(15) );
 hc15_s1:   s1    (15) <= not( s1_x_b(15) and s1_y_b(15) );


END; -- ARCH fuq_hc16pp
