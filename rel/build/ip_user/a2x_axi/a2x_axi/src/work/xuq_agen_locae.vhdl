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



entity xuq_agen_locae is port(
     addr_sel   :in  std_ulogic ; 
     addr_nsel  :in  std_ulogic ; 
     addr       :in  std_ulogic_vector(0 to 3) ;
     x_b        :in  std_ulogic_vector(0 to 7) ; 
     y_b        :in  std_ulogic_vector(0 to 7) ;
     sum_0      :out std_ulogic_vector(0 to 3) ;
     sum_1      :out std_ulogic_vector(0 to 3) 
 );



END                                 xuq_agen_locae;


ARCHITECTURE xuq_agen_locae  OF xuq_agen_locae  IS

 constant tiup : std_ulogic := '1';
 constant tidn : std_ulogic := '0';


    signal x     :std_ulogic_vector(0 to 7);
    signal y     :std_ulogic_vector(0 to 7);
    signal g01_b :std_ulogic_vector(1 to 7);
    signal t01_b :std_ulogic_vector(1 to 7);
    signal p01   :std_ulogic_vector(0 to 3);
    signal p01_b :std_ulogic_vector(0 to 3);


 signal  g08_b  :std_ulogic_vector(1 to 4);
 signal  g08    :std_ulogic_vector(1 to 4);
 signal  g04_b  :std_ulogic_vector(1 to 7);
 signal  g02    :std_ulogic_vector(1 to 7);
 signal  t02    :std_ulogic_vector(1 to 7);
 signal  t04_b  :std_ulogic_vector(1 to 7);
 signal  t08    :std_ulogic_vector(1 to 4);
 signal  t08_b  :std_ulogic_vector(1 to 4);


















  signal h01, h01_b :std_ulogic_vector(0 to 3);





BEGIN



    u_xi: x(0 to 7) <= not x_b(0 to 7) ; 
    u_yi: y(0 to 7) <= not y_b(0 to 7) ; 


    u_g01:    g01_b(1 to 7) <= not( x(1 to 7) and  y(1 to 7) );
    u_t01:    t01_b(1 to 7) <= not( x(1 to 7) or   y(1 to 7) );
    u_p01b:   p01_b(0 to 3) <= not( x(0 to 3) xor  y(0 to 3) );
    u_p01:    p01  (0 to 3) <= not( p01_b(0 to 3) );


  u_g02_1: g02(1) <= not( g01_b(1) and ( t01_b(1) or  g01_b(2) ) ) ;
  u_g02_2: g02(2) <= not( g01_b(2) and ( t01_b(2) or  g01_b(3) ) ) ;
  u_g02_3: g02(3) <= not( g01_b(3) and ( t01_b(3) or  g01_b(4) ) ) ;
  u_g02_4: g02(4) <= not( g01_b(4) and ( t01_b(4) or  g01_b(5) ) ) ;
  u_g02_5: g02(5) <= not( g01_b(5) and ( t01_b(5) or  g01_b(6) ) ) ;
  u_g02_6: g02(6) <= not( g01_b(6) and ( t01_b(6) or  g01_b(7) ) ) ;
  u_g02_7: g02(7) <= not( g01_b(7)                               ) ;

  u_t02_1: t02(1) <= not(                t01_b(1) or  t01_b(2)   ) ;
  u_t02_2: t02(2) <= not(                t01_b(2) or  t01_b(3)   ) ;
  u_t02_3: t02(3) <= not(                t01_b(3) or  t01_b(4)   ) ;
  u_t02_4: t02(4) <= not(                t01_b(4) or  t01_b(5)   ) ;
  u_t02_5: t02(5) <= not(                t01_b(5) or  t01_b(6)   ) ;
  u_t02_6: t02(6) <= not( g01_b(6) and ( t01_b(6) or  t01_b(7) ) ) ;
  u_t02_7: t02(7) <= not(                t01_b(7)                ) ;



  u_g04_1: g04_b(1) <= not( g02(1) or  ( t02(1) and g02(3) ) ) ;
  u_g04_2: g04_b(2) <= not( g02(2) or  ( t02(2) and g02(4) ) ) ;
  u_g04_3: g04_b(3) <= not( g02(3) or  ( t02(3) and g02(5) ) ) ;
  u_g04_4: g04_b(4) <= not( g02(4) or  ( t02(4) and g02(6) ) ) ;
  u_g04_5: g04_b(5) <= not( g02(5) or  ( t02(5) and g02(7) ) ) ;
  u_g04_6: g04_b(6) <= not( g02(6)                           ) ;
  u_g04_7: g04_b(7) <= not( g02(7)                           ) ;

  u_t04_1: t04_b(1) <= not(              t02(1) and t02(3)   ) ;
  u_t04_2: t04_b(2) <= not(              t02(2) and t02(4)   ) ;
  u_t04_3: t04_b(3) <= not(              t02(3) and t02(5)   ) ;
  u_t04_4: t04_b(4) <= not( g02(4) or  ( t02(4) and t02(6) ) ) ;
  u_t04_5: t04_b(5) <= not( g02(5) or  ( t02(5) and t02(7) ) ) ;
  u_t04_6: t04_b(6) <= not(              t02(6)              ) ;
  u_t04_7: t04_b(7) <= not(              t02(7)              ) ;



  u_g08_1: g08(1) <= not( g04_b(1) and ( t04_b(1) or  g04_b(5) ) ) ;
  u_g08_2: g08(2) <= not( g04_b(2) and ( t04_b(2) or  g04_b(6) ) ) ;
  u_g08_3: g08(3) <= not( g04_b(3) and ( t04_b(3) or  g04_b(7) ) ) ;
  u_g08_4: g08(4) <= not( g04_b(4)                               ) ;

  u_t08_1: t08(1) <= not( g04_b(1) and ( t04_b(1) or  t04_b(5) ) ) ;
  u_t08_2: t08(2) <= not( g04_b(2) and ( t04_b(2) or  t04_b(6) ) ) ;
  u_t08_3: t08(3) <= not( g04_b(3) and ( t04_b(3) or  t04_b(7) ) ) ;
  u_t08_4: t08(4) <= not(                t04_b(4)                ) ;





    u_g08i_1: g08_b(1) <= not g08(1) ;
    u_g08i_2: g08_b(2) <= not g08(2) ;
    u_g08i_3: g08_b(3) <= not g08(3) ;
    u_g08i_4: g08_b(4) <= not g08(4) ;

    u_t08i_1: t08_b(1) <= not t08(1) ;
    u_t08i_2: t08_b(2) <= not t08(2) ;
    u_t08i_3: t08_b(3) <= not t08(3) ;
    u_t08i_4: t08_b(4) <= not t08(4) ;



    u_h01:  h01  (0 to 3) <= not( (p01_b(0 to 3) and (0 to 3=> addr_nsel)  ) or
                                  (addr (0 to 3) and (0 to 3=> addr_sel )  ) );

    u_h01b: h01_b(0 to 3) <= not( (p01  (0 to 3) and (0 to 3=> addr_nsel)  ) or
                                  (addr (0 to 3) and (0 to 3=> addr_sel )  ) );


    u_sum_0_0: sum_0(0) <= not(  ( h01(0) and  g08(1) ) or  ( h01_b(0) and  g08_b(1) )   ); 
    u_sum_0_1: sum_0(1) <= not(  ( h01(1) and  g08(2) ) or  ( h01_b(1) and  g08_b(2) )   ); 
    u_sum_0_2: sum_0(2) <= not(  ( h01(2) and  g08(3) ) or  ( h01_b(2) and  g08_b(3) )   ); 
    u_sum_0_3: sum_0(3) <= not(  ( h01(3) and  g08(4) ) or  ( h01_b(3) and  g08_b(4) )   ); 
                                    
                                    
    u_sum_1_0: sum_1(0) <= not(  ( h01(0) and  t08(1) ) or  ( h01_b(0) and  t08_b(1) )   ); 
    u_sum_1_1: sum_1(1) <= not(  ( h01(1) and  t08(2) ) or  ( h01_b(1) and  t08_b(2) )   ); 
    u_sum_1_2: sum_1(2) <= not(  ( h01(2) and  t08(3) ) or  ( h01_b(2) and  t08_b(3) )   ); 
    u_sum_1_3: sum_1(3) <= not(  ( h01(3) and  t08(4) ) or  ( h01_b(3) and  t08_b(4) )   ); 
                                    
                                    


END; 

