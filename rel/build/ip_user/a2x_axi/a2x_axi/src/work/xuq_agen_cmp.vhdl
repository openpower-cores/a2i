-- © IBM Corp. 2020
-- This softcore is licensed under and subject to the terms of the CC-BY 4.0
-- license (https://creativecommons.org/licenses/by/4.0/legalcode). 
-- Additional rights, including the right to physically implement a softcore 
-- that is compliant with the required sections of the Power ISA 
-- Specification, will be available at no cost via the OpenPOWER Foundation. 
-- This README will be updated with additional information when OpenPOWER's 
-- license is available.


library ieee,ibm,support,tri, work; 
   use ieee.std_logic_1164.all;
   use ibm.std_ulogic_unsigned.all;
   use ibm.std_ulogic_support.all; 
   use ibm.std_ulogic_function_support.all;
   use support.power_logic_pkg.all;
   use tri.tri_latches_pkg.all;
   use ibm.std_ulogic_ao_support.all; 
   use ibm.std_ulogic_mux_support.all; 
library clib ;



entity xuq_agen_cmp is port(
     x_b                  :in  std_ulogic_vector(53 to 63) ; 
     y_b                  :in  std_ulogic_vector(53 to 63) ;
     z                    :in  std_ulogic_vector(53 to 57) ;

     inv1_val_b           :in  std_ulogic;   
     ex1_cache_acc_b      :in  std_ulogic;
     dir_ig_57_b          :in  std_ulogic; 
     rel3_val             :in  std_ulogic;
     way                  :in  std_ulogic_vector(0 to 7);

     ary_write_act_01     :out std_ulogic ;
     ary_write_act_23     :out std_ulogic ;
     ary_write_act_45     :out std_ulogic ;
     ary_write_act_67     :out std_ulogic ;
     ary_write_act        :out std_ulogic_vector(0 to 3);

     match_oth            :out std_ulogic ;
     vdd                  :inout power_logic;
     gnd                  :inout power_logic
 );


END                                 xuq_agen_cmp;


ARCHITECTURE xuq_agen_cmp  OF xuq_agen_cmp  IS

   constant tiup : std_ulogic := '1';
   constant tidn : std_ulogic := '0';

   signal unused_car :std_ulogic;
   signal sum :std_ulogic_vector(0 to 4);
   signal car :std_ulogic_vector(0 to 3);

   signal                       x        :std_ulogic_vector(0 to 4);
   signal                       y        :std_ulogic_vector(0 to 4);
   signal                       z_b      :std_ulogic_vector(0 to 4);

   signal                       g1       :std_ulogic_vector(4 to 10);
   signal                       t1       :std_ulogic_vector(4 to 9);


   signal                       g_4_b        :std_ulogic;
   signal                       g_4e         :std_ulogic;  
   signal                       t_4e_b       :std_ulogic;
   signal                       t_4e         :std_ulogic;
   signal                       g_5t7_0_b    :std_ulogic;
   signal                       g_5t7_1_b    :std_ulogic;
   signal                       g_5t7_2_b    :std_ulogic;
   signal                       g_5t7        :std_ulogic;
   signal                       t_5t7_b      :std_ulogic;
   signal                       t_5t7        :std_ulogic;
   signal                       g_8t10_0_b   :std_ulogic;
   signal                       g_8t10_1_b   :std_ulogic;
   signal                       g_8t10_2_b   :std_ulogic;
   signal                       g_8t10       :std_ulogic;
   signal                       g_4t10_0_b   :std_ulogic;
   signal                       g_4t10_1_b   :std_ulogic;
   signal                       g_4t10_2_b   :std_ulogic;
   signal                       g_4t10       :std_ulogic;


   signal                       dir_ig_57       :std_ulogic;
   signal                       xorcmp          :std_ulogic_vector(0 to 3);
   signal                       ulp_0_b         :std_ulogic;
   signal                       ulp_1_b         :std_ulogic;
   signal                       ulp             :std_ulogic;
   signal                       enable_part     :std_ulogic;
   signal                       gp1_a_b         :std_ulogic;
   signal                       gp2_a_b         :std_ulogic;
   signal                       gp12_a          :std_ulogic;
   signal                       gp3             :std_ulogic;
   signal                       match_arr_b     :std_ulogic;
   signal                       match           :std_ulogic;

   signal                       rel3_val_01        :std_ulogic;
   signal                       rel3_val_23        :std_ulogic;
   signal                       rel3_val_45        :std_ulogic;
   signal                       rel3_val_67        :std_ulogic;

   signal                       match_lv0_i0       :std_ulogic;
   signal                       match_lv1_i0_b     :std_ulogic;
   signal                       match_lv1_i1_b     :std_ulogic;
   signal                       ary_write_act_01_b :std_ulogic;
   signal                       ary_write_act_45_b :std_ulogic;
   signal                       ary_write_act_23_b :std_ulogic;
   signal                       ary_write_act_67_b :std_ulogic;

   signal                       ary_write_act_cpy  :std_ulogic_vector(0 to 3);

BEGIN

  dir_ig_57   <= not dir_ig_57_b ;


   u_x1_0:  x(0) <= not x_b(53) ;
   u_x1_1:  x(1) <= not x_b(54) ;
   u_x1_2:  x(2) <= not x_b(55) ;
   u_x1_3:  x(3) <= not x_b(56) ;
   u_x1_4:  x(4) <= not x_b(57) ;

   u_y1_0:  y(0) <= not y_b(53) ;
   u_y1_1:  y(1) <= not y_b(54) ;
   u_y1_2:  y(2) <= not y_b(55) ;
   u_y1_3:  y(3) <= not y_b(56) ;
   u_y1_4:  y(4) <= not y_b(57) ;

   u_z1_0:  z_b(0) <= not( z(53) );
   u_z1_1:  z_b(1) <= not( z(54) );
   u_z1_2:  z_b(2) <= not( z(55) );
   u_z1_3:  z_b(3) <= not( z(56) );
   u_z1_4:  z_b(4) <= not( z(57) );

   u_g1_4:  g1(4)  <= not( x_b(57)  or  y_b(57)  );
   u_g1_5:  g1(5)  <= not( x_b(58)  or  y_b(58)  );
   u_g1_6:  g1(6)  <= not( x_b(59)  or  y_b(59)  );
   u_g1_7:  g1(7)  <= not( x_b(60)  or  y_b(60)  );
   u_g1_8:  g1(8)  <= not( x_b(61)  or  y_b(61)  );
   u_g1_9:  g1(9)  <= not( x_b(62)  or  y_b(62)  );
   u_g1_10: g1(10) <= not( x_b(63)  or  y_b(63)  );

   u_t1_4:  t1(4)  <= not( x_b(57)  and y_b(57)  );
   u_t1_5:  t1(5)  <= not( x_b(58)  and y_b(58)  );
   u_t1_6:  t1(6)  <= not( x_b(59)  and y_b(59)  );
   u_t1_7:  t1(7)  <= not( x_b(60)  and y_b(60)  );
   u_t1_8:  t1(8)  <= not( x_b(61)  and y_b(61)  );
   u_t1_9:  t1(9)  <= not( x_b(62)  and y_b(62)  );



  u_ac_csa_0: entity clib.c_prism_csa32 port map(
        vd               => vdd,
        gd               => gnd,
        a                =>   x(0)                    ,
        b                =>   y(0)                    ,
        c                => z_b(0)                    ,
        sum              => sum(0)                    ,
        car              => unused_car               );

  u_ac_csa_1: entity clib.c_prism_csa32 port map(
        vd               => vdd,
        gd               => gnd,
        a                =>   x(1)                    ,
        b                =>   y(1)                    ,
        c                => z_b(1)                    ,
        sum              => sum(1)                    ,
        car              => car(0)                   );

  u_ac_csa_2: entity clib.c_prism_csa32 port map(
        vd               => vdd,
        gd               => gnd,
        a                =>   x(2)                    ,
        b                =>   y(2)                    ,
        c                => z_b(2)                    ,
        sum              => sum(2)                    ,
        car              => car(1)                   );

  u_ac_csa_3: entity clib.c_prism_csa32 port map(
        vd               => vdd,
        gd               => gnd,
        a                =>   x(3)                    ,
        b                =>   y(3)                    ,
        c                => z_b(3)                    ,
        sum              => sum(3)                    ,
        car              => car(2)                   );

  u_ac_csa_4: entity clib.c_prism_csa32 port map(
        vd               => vdd,
        gd               => gnd,
        a                =>   x(4)                    ,
        b                =>   y(4)                    ,
        c                => z_b(4)                    ,
        sum              => sum(4)                    ,
        car              => car(3)                   );



 u_g_4:   g_4_b  <= not( g1(4) );
 u_g_4e:  g_4e   <= not( g_4_b or  dir_ig_57_b); 
 u_t_4:   t_4e_b <= not( t1(4) or  dir_ig_57_b); 
 u_t_4e:  t_4e   <= not( t_4e_b );

 u_g_5t7_0:  g_5t7_0_b  <= not( g1(5) );
 u_g_5t7_1:  g_5t7_1_b  <= not( t1(5) and g1(6) );
 u_g_5t7_2:  g_5t7_2_b  <= not( t1(5) and t1(6) and g1(7) );
 u_g_5t7:    g_5t7      <= not( g_5t7_0_b and g_5t7_1_b and g_5t7_2_b );
 u_t_5t7_0:  t_5t7_b    <= not( t1(5) and t1(6) and t1(7) );
 u_t_5t7:    t_5t7      <= not( t_5t7_b );

 u_g_8t10_0: g_8t10_0_b <= not( g1(8) );
 u_g_8t10_1: g_8t10_1_b <= not( t1(8) and g1(9) );
 u_g_8t10_2: g_8t10_2_b <= not( t1(8) and t1(9) and g1(10) );
 u_g_8t10:   g_8t10     <= not( g_8t10_0_b and g_8t10_1_b and g_8t10_2_b );

 u_g_4t10_0: g_4t10_0_b <= not( g_4e ) ;
 u_g_4t10_1: g_4t10_1_b <= not( t_4e and g_5t7 ) ;
 u_g_4t10_2: g_4t10_2_b <= not( t_4e and t_5t7 and g_8t10 ) ;
 u_g_4t10:   g_4t10     <= not( g_4t10_0_b and g_4t10_1_b and g_4t10_2_b );




  u_xorcmp_0: xorcmp(0) <= sum(0) xor car(0) ;
  u_xorcmp_1: xorcmp(1) <= sum(1) xor car(1) ;
  u_xorcmp_2: xorcmp(2) <= sum(2) xor car(2) ;
  u_xorcmp_3: xorcmp(3) <= sum(3) xor car(3) ;

  u_ulp_0:    ulp_0_b <= not( sum(3) and dir_ig_57   );
  u_ulp_1:    ulp_1_b <= not( sum(4) and dir_ig_57_b );
  u_ulp:      ulp     <= not( ulp_0_b and ulp_1_b );


  u_en_part: enable_part <= not( inv1_val_b and ex1_cache_acc_b );


  u_gp1_a:  gp1_a_b <= not( xorcmp(0) and xorcmp(1) and xorcmp(2) );
  u_gp2_a:  gp2_a_b <= not( enable_part and ( xorcmp(3) or dir_ig_57 ) );
  u_gp12_a: gp12_a  <= not( gp1_a_b or gp2_a_b );

  u_gp3:   gp3 <= ulp xor g_4t10 ;

  u_match_a: match_arr_b <= not( gp12_a and gp3 );
  u_match_i: match       <= not( match_arr_b );
  match_oth   <= match   ; 

 


   rel3_val_01 <= rel3_val and ( way(0) or way(1) );
   rel3_val_23 <= rel3_val and ( way(2) or way(3) );
   rel3_val_45 <= rel3_val and ( way(4) or way(5) );
   rel3_val_67 <= rel3_val and ( way(6) or way(7) );

   
   u_match_lv0_i0: match_lv0_i0 <= not( match_arr_b  ); 

   u_match_lv1_i0: match_lv1_i0_b <= not( match_lv0_i0   ); 
   u_match_lv1_i1: match_lv1_i1_b <= not( match_lv0_i0   ); 

   u_wact_01b:     ary_write_act_01_b <= not( match_lv1_i0_b and rel3_val_01 ) ; 
   u_wact_45b:     ary_write_act_45_b <= not( match_lv1_i0_b and rel3_val_45 ) ; 
   u_wact_23b:     ary_write_act_23_b <= not( match_lv1_i1_b and rel3_val_23 ) ; 
   u_wact_67b:     ary_write_act_67_b <= not( match_lv1_i1_b and rel3_val_67 ) ; 

   u_wact_01:      ary_write_act_01 <= not( ary_write_act_01_b ) ; 
   u_wact_45:      ary_write_act_45 <= not( ary_write_act_45_b ) ; 
   u_wact_23:      ary_write_act_23 <= not( ary_write_act_23_b ) ; 
   u_wact_67:      ary_write_act_67 <= not( ary_write_act_67_b ) ; 

   u_wact:         ary_write_act_cpy <= not (ary_write_act_01_b & ary_write_act_23_b & ary_write_act_45_b & ary_write_act_67_b);
   ary_write_act <= ary_write_act_cpy;
END; 

