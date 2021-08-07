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

-- #######################################################
-- ##  want equivalence to  (A[53:63] + B[53:63]) => sum[53:63] , then sum[53:57] == z[53:57]
-- ##  this is all complicated by another mode for                     sum[53:56] == z[53:56]
-- ##
-- ##  the short cut is to compute  (A+B-C)=="00000" / (A+B-c)=="0000"
-- ##  it is a shortcut because you substitute a 3:2 compressor delay for a 12 bit adder delay
-- ##  since there are more bits in (A+B) than C, there needs to be a carry-in to the compare
-- #######################################################

-- 0(53) 1(54) 2(55) 3(56) 4(57) 5(58) 6(59) 7(60) 8(61) 9(62) 10(63)

entity xuq_agen_cmp is port(
     x_b                  :in  std_ulogic_vector(53 to 63) ; 
     y_b                  :in  std_ulogic_vector(53 to 63) ;
     z                    :in  std_ulogic_vector(53 to 57) ;

     inv1_val_b           :in  std_ulogic;   
     ex1_cache_acc_b      :in  std_ulogic;
     dir_ig_57_b          :in  std_ulogic; -- when this is low , bit 57 becomes "1" .
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

  --###########################################################################
  --# dont want too put too much loads on the input (slows down rest of agen)
  --###########################################################################

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

  --##################################################################################
  --# compressors  (a+b-c ... sort of A+B+!C + 1 <== missing the +1 at this point
  --##################################################################################


  u_ac_csa_0: entity clib.c_prism_csa32 port map(
        vd               => vdd,
        gd               => gnd,
        a                =>   x(0)                    ,--i--
        b                =>   y(0)                    ,--i--
        c                => z_b(0)                    ,--i--
        sum              => sum(0)                    ,--o--
        car              => unused_car               );--o--

  u_ac_csa_1: entity clib.c_prism_csa32 port map(
        vd               => vdd,
        gd               => gnd,
        a                =>   x(1)                    ,--i--
        b                =>   y(1)                    ,--i--
        c                => z_b(1)                    ,--i--
        sum              => sum(1)                    ,--o--
        car              => car(0)                   );--o--

  u_ac_csa_2: entity clib.c_prism_csa32 port map(
        vd               => vdd,
        gd               => gnd,
        a                =>   x(2)                    ,--i--
        b                =>   y(2)                    ,--i--
        c                => z_b(2)                    ,--i--
        sum              => sum(2)                    ,--o--
        car              => car(1)                   );--o--

  u_ac_csa_3: entity clib.c_prism_csa32 port map(
        vd               => vdd,
        gd               => gnd,
        a                =>   x(3)                    ,--i--
        b                =>   y(3)                    ,--i--
        c                => z_b(3)                    ,--i--
        sum              => sum(3)                    ,--o--
        car              => car(2)                   );--o--

  u_ac_csa_4: entity clib.c_prism_csa32 port map(
        vd               => vdd,
        gd               => gnd,
        a                =>   x(4)                    ,--i--
        b                =>   y(4)                    ,--i--
        c                => z_b(4)                    ,--i--
        sum              => sum(4)                    ,--o--
        car              => car(3)                   );--o--


  --####################################################################
  --# carry path  (conditionally includes bit 4 <57> )
  --####################################################################

 u_g_4:   g_4_b  <= not( g1(4) );
 u_g_4e:  g_4e   <= not( g_4_b or  dir_ig_57_b); -- neg input and : g1(4) and !dir_ig_57
 u_t_4:   t_4e_b <= not( t1(4) or  dir_ig_57_b); --                 t1(4) or   dir_ig_57
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


  --####################################################################
  --# combine it all
  --####################################################################


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
  u_match_i: match       <= not( match_arr_b );--output-- small to buffer off
  match_oth   <= match   ; --output-- rename

  -- ######################################################
  -- ## drive to the array pins
  -- ######################################################
 
   --    ARRAY positions ---------------------
   --    array_01    array_45
   --    array_23    array_67

   rel3_val_01 <= rel3_val and ( way(0) or way(1) );
   rel3_val_23 <= rel3_val and ( way(2) or way(3) );
   rel3_val_45 <= rel3_val and ( way(4) or way(5) );
   rel3_val_67 <= rel3_val and ( way(6) or way(7) );

   
   u_match_lv0_i0: match_lv0_i0 <= not( match_arr_b  ); --6

   u_match_lv1_i0: match_lv1_i0_b <= not( match_lv0_i0   ); --2
   u_match_lv1_i1: match_lv1_i1_b <= not( match_lv0_i0   ); --6

   u_wact_01b:     ary_write_act_01_b <= not( match_lv1_i0_b and rel3_val_01 ) ; --3
   u_wact_45b:     ary_write_act_45_b <= not( match_lv1_i0_b and rel3_val_45 ) ; --3
   u_wact_23b:     ary_write_act_23_b <= not( match_lv1_i1_b and rel3_val_23 ) ; --4
   u_wact_67b:     ary_write_act_67_b <= not( match_lv1_i1_b and rel3_val_67 ) ; --4

   u_wact_01:      ary_write_act_01 <= not( ary_write_act_01_b ) ; --6 --output--
   u_wact_45:      ary_write_act_45 <= not( ary_write_act_45_b ) ; --6 --output--
   u_wact_23:      ary_write_act_23 <= not( ary_write_act_23_b ) ; --6 --output--
   u_wact_67:      ary_write_act_67 <= not( ary_write_act_67_b ) ; --6 --output--

   u_wact:         ary_write_act_cpy <= not (ary_write_act_01_b & ary_write_act_23_b & ary_write_act_45_b & ary_write_act_67_b);
   ary_write_act <= ary_write_act_cpy;
END; -- ARCH xuq_agen_cmp
