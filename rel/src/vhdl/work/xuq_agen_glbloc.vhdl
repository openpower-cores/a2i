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


entity xuq_agen_glbloc is port(
     x_b        :in  std_ulogic_vector(0 to 7) ;
     y_b        :in  std_ulogic_vector(0 to 7) ;
     g08        :out std_ulogic ;
     t08        :out std_ulogic     
 );


END                                 xuq_agen_glbloc;


ARCHITECTURE xuq_agen_glbloc  OF xuq_agen_glbloc  IS

 constant tiup : std_ulogic := '1';
 constant tidn : std_ulogic := '0';

 signal g01, t01     :std_ulogic_vector(0 to 7);
 signal g02_b, t02_b :std_ulogic_vector(0 to 3);
 signal g04,   t04   :std_ulogic_vector(0 to 1);
 signal g08_b, t08_b :std_ulogic;


BEGIN

  u_g01_0: g01(0)   <= not( x_b(0) or  y_b(0) );
  u_g01_1: g01(1)   <= not( x_b(1) or  y_b(1) );
  u_g01_2: g01(2)   <= not( x_b(2) or  y_b(2) );
  u_g01_3: g01(3)   <= not( x_b(3) or  y_b(3) );
  u_g01_4: g01(4)   <= not( x_b(4) or  y_b(4) );
  u_g01_5: g01(5)   <= not( x_b(5) or  y_b(5) );
  u_g01_6: g01(6)   <= not( x_b(6) or  y_b(6) );
  u_g01_7: g01(7)   <= not( x_b(7) or  y_b(7) );

  u_t01_0: t01(0)   <= not( x_b(0) and y_b(0) );
  u_t01_1: t01(1)   <= not( x_b(1) and y_b(1) );
  u_t01_2: t01(2)   <= not( x_b(2) and y_b(2) );
  u_t01_3: t01(3)   <= not( x_b(3) and y_b(3) );
  u_t01_4: t01(4)   <= not( x_b(4) and y_b(4) );
  u_t01_5: t01(5)   <= not( x_b(5) and y_b(5) );
  u_t01_6: t01(6)   <= not( x_b(6) and y_b(6) );
  u_t01_7: t01(7)   <= not( x_b(7) and y_b(7) );


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



  u_g08_x: g08      <= not ( g08_b  ) ; -- output

  u_t08_x: t08      <= not ( t08_b  ) ; -- output

END; -- ARCH xuq_agen_glbloc
