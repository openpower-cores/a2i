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

-- input phase is important
-- (change X (B) by switching xor/xnor )

entity xuq_agen_lo is port(
     x_b         :in  std_ulogic_vector(0 to 11) ; -- after xor
     y_b         :in  std_ulogic_vector(0 to 11) ;
     sum         :out std_ulogic_vector(0 to 11) ; 
     sum_arr     :out std_ulogic_vector(1 to  5) ;
     dir_ig_57_b :in std_ulogic -- when this is low , bit 57 becomes "1" .
 );


END                                 xuq_agen_lo;


ARCHITECTURE xuq_agen_lo  OF xuq_agen_lo  IS

 constant tiup : std_ulogic := '1';
 constant tidn : std_ulogic := '0';

   signal p01_b, p01 :std_ulogic_vector(0 to 11);
   signal g01        :std_ulogic_vector(1 to 11);
   signal t01        :std_ulogic_vector(1 to 10);
   signal sum_x, sum_b :std_ulogic_vector(0 to 11);
   signal sum_x_11_b   :std_ulogic;
   signal g12_x_b,  g02_b, g04 ,c :std_ulogic_vector(1 to 11);
   signal g12_y_b :std_ulogic_vector(1 to 7);
   signal g12_z_b :std_ulogic_vector(1 to 3);
   signal t02_b :std_ulogic_vector(1 to 9);
   signal t04   :std_ulogic_vector(1 to 7);


BEGIN

  --####################################################################
  --# propagate, generate, transmit
  --####################################################################

    u_g01:    g01  (1 to 11) <= not( x_b(1 to 11) or   y_b(1 to 11) );
    u_t01:    t01  (1 to 10) <= not( x_b(1 to 10) and  y_b(1 to 10) );
    u_p01b:   p01_b(0 to 11) <= not( x_b(0 to 11) xor  y_b(0 to 11) );
    u_p01:    p01  (0 to 11) <= not( p01_b(0 to 11) );

  --####################################################################
  --# final sum and drive
  --####################################################################

    u_sumx:      sum_x(0 to 10)  <= p01(0 to 10) xor c(1 to 11);
    u_sumx11b:   sum_x_11_b <= not( p01(11) );
    u_sumx11:    sum_x(11)  <= not( sum_x_11_b );

      -- 00 01 02 03 04 05 06 07 08 09 10 11
      -- 52 53 54 55 56 57 58 59 60 61 62 63

    u_sum_b:     sum_b  (0 to 11) <= not( sum_x(0 to 11) );
    u_sum:       sum    (0 to 11) <= not( sum_b(0 to 11) );
    u_sum_arr1:  sum_arr(1)       <= not( sum_b(1) );
    u_sum_arr2:  sum_arr(2)       <= not( sum_b(2) );
    u_sum_arr3:  sum_arr(3)       <= not( sum_b(3) );
    u_sum_arr4:  sum_arr(4)       <= not( sum_b(4) );
    u_sum_arr5:  sum_arr(5)       <= not( sum_b(5) and dir_ig_57_b ); -- OR with negative inputs

  --####################################################################
  --# carry path is cogge-stone
  --####################################################################


    u_g02_1:  g02_b( 1) <= not( g01( 1) or ( t01( 1) and g01( 2) ) );
    u_g02_2:  g02_b( 2) <= not( g01( 2) or ( t01( 2) and g01( 3) ) );
    u_g02_3:  g02_b( 3) <= not( g01( 3) or ( t01( 3) and g01( 4) ) );
    u_g02_4:  g02_b( 4) <= not( g01( 4) or ( t01( 4) and g01( 5) ) );
    u_g02_5:  g02_b( 5) <= not( g01( 5) or ( t01( 5) and g01( 6) ) );
    u_g02_6:  g02_b( 6) <= not( g01( 6) or ( t01( 6) and g01( 7) ) );
    u_g02_7:  g02_b( 7) <= not( g01( 7) or ( t01( 7) and g01( 8) ) );
    u_g02_8:  g02_b( 8) <= not( g01( 8) or ( t01( 8) and g01( 9) ) );
    u_g02_9:  g02_b( 9) <= not( g01( 9) or ( t01( 9) and g01(10) ) );
    u_g02_10: g02_b(10) <= not( g01(10) or ( t01(10) and g01(11) ) );
    u_g02_11: g02_b(11) <= not( g01(11)                            );


    u_t02_1:  t02_b( 1) <= not(              t01( 1) and t01( 2)   );
    u_t02_2:  t02_b( 2) <= not(              t01( 2) and t01( 3)   );
    u_t02_3:  t02_b( 3) <= not(              t01( 3) and t01( 4)   );
    u_t02_4:  t02_b( 4) <= not(              t01( 4) and t01( 5)   );
    u_t02_5:  t02_b( 5) <= not(              t01( 5) and t01( 6)   );
    u_t02_6:  t02_b( 6) <= not(              t01( 6) and t01( 7)   );
    u_t02_7:  t02_b( 7) <= not(              t01( 7) and t01( 8)   );
    u_t02_8:  t02_b( 8) <= not(              t01( 8) and t01( 9)   );
    u_t02_9:  t02_b( 9) <= not(              t01( 9) and t01(10)   );
    


    u_g04_1:  g04  ( 1) <= not( g02_b( 1) and ( t02_b( 1) or g02_b( 3) ) );
    u_g04_2:  g04  ( 2) <= not( g02_b( 2) and ( t02_b( 2) or g02_b( 4) ) );
    u_g04_3:  g04  ( 3) <= not( g02_b( 3) and ( t02_b( 3) or g02_b( 5) ) );
    u_g04_4:  g04  ( 4) <= not( g02_b( 4) and ( t02_b( 4) or g02_b( 6) ) );
    u_g04_5:  g04  ( 5) <= not( g02_b( 5) and ( t02_b( 5) or g02_b( 7) ) );
    u_g04_6:  g04  ( 6) <= not( g02_b( 6) and ( t02_b( 6) or g02_b( 8) ) );
    u_g04_7:  g04  ( 7) <= not( g02_b( 7) and ( t02_b( 7) or g02_b( 9) ) );
    u_g04_8:  g04  ( 8) <= not( g02_b( 8) and ( t02_b( 8) or g02_b(10) ) );
    u_g04_9:  g04  ( 9) <= not( g02_b( 9) and ( t02_b( 9) or g02_b(11) ) );
    u_g04_10: g04  (10) <= not( g02_b(10)                                );
    u_g04_11: g04  (11) <= not( g02_b(11)                                );

 
    u_t04_1:  t04  ( 1) <= not(                 t02_b( 1) or t02_b( 3)   );
    u_t04_2:  t04  ( 2) <= not(                 t02_b( 2) or t02_b( 4)   );
    u_t04_3:  t04  ( 3) <= not(                 t02_b( 3) or t02_b( 5)   );
    u_t04_4:  t04  ( 4) <= not(                 t02_b( 4) or t02_b( 6)   );
    u_t04_5:  t04  ( 5) <= not(                 t02_b( 5) or t02_b( 7)   );
    u_t04_6:  t04  ( 6) <= not(                 t02_b( 6) or t02_b( 8)   );
    u_t04_7:  t04  ( 7) <= not(                 t02_b( 7) or t02_b( 9)   );


    u_g12x_1:  g12_x_b( 1) <= not( g04( 1)                                     );
    u_g12y_1:  g12_y_b( 1) <= not( t04( 1)     and  g04( 5)                    );
    u_g12z_1:  g12_z_b( 1) <= not( t04( 1)     and  t04( 5)    and g04( 9)     );
       u_c_1:        c( 1) <= not( g12_x_b( 1) and g12_y_b( 1) and g12_z_b( 1) );

    u_g12x_2:  g12_x_b( 2) <= not( g04( 2)                                     );
    u_g12y_2:  g12_y_b( 2) <= not( t04( 2)     and  g04( 6)                    );
    u_g12z_2:  g12_z_b( 2) <= not( t04( 2)     and  t04( 6)    and g04(10)     );
       u_c_2:        c( 2) <= not( g12_x_b( 2) and g12_y_b( 2) and g12_z_b( 2) );

    u_g12x_3:  g12_x_b( 3) <= not( g04( 3)                                     );
    u_g12y_3:  g12_y_b( 3) <= not( t04( 3)     and  g04( 7)                    );
    u_g12z_3:  g12_z_b( 3) <= not( t04( 3)     and  t04( 7)    and g04(11)     );
       u_c_3:        c( 3) <= not( g12_x_b( 3) and g12_y_b( 3) and g12_z_b( 3) );

    u_g12x_4:  g12_x_b( 4) <= not( g04( 4)                                     );
    u_g12y_4:  g12_y_b( 4) <= not( t04( 4)     and  g04( 8)                    );
       u_c_4:        c( 4) <= not( g12_x_b( 4) and g12_y_b( 4)                 );

    u_g12x_5:  g12_x_b( 5) <= not( g04( 5)                                     );
    u_g12y_5:  g12_y_b( 5) <= not( t04( 5)     and  g04( 9)                    );
       u_c_5:        c( 5) <= not( g12_x_b( 5) and g12_y_b( 5)                 );

    u_g12x_6:  g12_x_b( 6) <= not( g04( 6)                                     );
    u_g12y_6:  g12_y_b( 6) <= not( t04( 6)     and  g04(10)                    );
       u_c_6:        c( 6) <= not( g12_x_b( 6) and g12_y_b( 6)                 );

    u_g12x_7:  g12_x_b( 7) <= not( g04( 7)                                     );
    u_g12y_7:  g12_y_b( 7) <= not( t04( 7)     and  g04(11)                    );
       u_c_7:        c( 7) <= not( g12_x_b( 7) and g12_y_b( 7)                 );

    u_g12x_8:  g12_x_b( 8) <= not( g04( 8)                                     );
       u_c_8:        c( 8) <= not( g12_x_b( 8)                                 );

    u_g12x_9:  g12_x_b( 9) <= not( g04( 9)                                     );
       u_c_9:        c( 9) <= not( g12_x_b( 9)                                 );

    u_g12x_10: g12_x_b(10) <= not( g04(10)                                     );
       u_c_10:       c(10) <= not( g12_x_b(10)                                 );

    u_g12x_11: g12_x_b(11) <= not( g04(11)                                     );
       u_c_11:       c(11) <= not( g12_x_b(11)                                 );




END; -- ARCH xuq_agen_lo
