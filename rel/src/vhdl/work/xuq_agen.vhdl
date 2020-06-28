-- © IBM Corp. 2020
-- This softcore is licensed under and subject to the terms of the CC-BY 4.0
-- license (https://creativecommons.org/licenses/by/4.0/legalcode). 
-- Additional rights, including the right to physically implement a softcore 
-- that is compliant with the required sections of the Power ISA 
-- Specification, will be available at no cost via the OpenPOWER Foundation. 
-- This README will be updated with additional information when OpenPOWER's 
-- license is available.



library ieee,ibm,support,tri,work;
   use ieee.std_logic_1164.all;
   use ibm.std_ulogic_unsigned.all; 
   use ibm.std_ulogic_support.all; 
   use ibm.std_ulogic_function_support.all;
   use support.power_logic_pkg.all;
   use tri.tri_latches_pkg.all;
   use ibm.std_ulogic_ao_support.all; 
   use ibm.std_ulogic_mux_support.all; 


entity xuq_agen is
generic(       expand_type               : integer := 2  ); 
port(
     x            :in  std_ulogic_vector(0 to 63) ; 
     y            :in  std_ulogic_vector(0 to 63) ;
     snoop_addr   :in  std_ulogic_vector(0 to 51) ; 
     snoop_sel    :in  std_ulogic  ;
     binv_val     :in  std_ulogic  ;
     mode64       :in  std_ulogic  ; 
     dir_ig_57_b  :in  std_ulogic  ; 


     sum_non_erat :out std_ulogic_vector(0 to 63) ; 
     sum          :out std_ulogic_vector(0 to 51) ; 
     sum_arr_dir01  :out std_ulogic_vector(53 to 57) ;
     sum_arr_dir23  :out std_ulogic_vector(53 to 57) ;
     sum_arr_dir45  :out std_ulogic_vector(53 to 57) ;
     sum_arr_dir67  :out std_ulogic_vector(53 to 57) ;

     z                 :in  std_ulogic_vector(53 to 57) ;
     way               :in  std_ulogic_vector(0 to 7)   ;
     inv1_val_b        :in  std_ulogic                  ;
     ex1_cache_acc_b   :in  std_ulogic                  ;
     rel3_val          :in  std_ulogic                  ;
     ary_write_act_01  :out std_ulogic                  ;
     ary_write_act_23  :out std_ulogic                  ;
     ary_write_act_45  :out std_ulogic                  ;
     ary_write_act_67  :out std_ulogic                  ;
     ary_write_act     :out std_ulogic_vector(0 to 3)   ;
     match_oth         :out std_ulogic                  ;
     vdd               :inout power_logic;
     gnd               :inout power_logic

);




end xuq_agen; 

architecture xuq_agen of xuq_agen is

 constant tiup : std_ulogic := '1';
 constant tidn : std_ulogic := '0';



 signal sum_int, sum_non_erat_b :std_ulogic_vector(0 to 51);
 signal sum_0 :std_ulogic_vector(0 to 51);
 signal sum_1 :std_ulogic_vector(0 to 51);
 signal g08 :std_ulogic_vector(1 to 7);
 signal t08 :std_ulogic_vector(1 to 6);
 signal c64_b :std_ulogic_vector(1 to 7);
 signal x_b, y_b :std_ulogic_vector(0 to 63);




  
    signal addr_sel, addr_nsel, addr_sel_64, addr_nsel_64 :std_ulogic;

  signal sum_arr         :std_ulogic_vector(53 to 57); 
  signal sum_arr_lv1_0_b :std_ulogic_vector(53 to 57);
  signal sum_arr_lv1_1_b :std_ulogic_vector(53 to 57);
 
 
 
  



begin


     addr_nsel_64 <= mode64 and not (snoop_sel and not binv_val) ;
     addr_nsel    <=            not (snoop_sel and not binv_val) ;
     addr_sel_64  <=                (snoop_sel and not binv_val) ;
     addr_sel     <=                (snoop_sel and not binv_val) ;



  u_xi: x_b(0 to 63) <= not( x(0 to 63) ); 
  u_yi: y_b(0 to 63) <= not( y(0 to 63) ); 
   

 loc_0: entity work.xuq_agen_loca(xuq_agen_loca) port map(
         addr_sel     => addr_sel_64            ,
         addr_nsel    => addr_nsel_64           ,
         addr(0 to 7) => snoop_addr(0 to 7)     ,
          x_b(0 to 7) =>      x_b(0 to 7)       ,
          y_b(0 to 7) =>      y_b(0 to 7)       ,
        sum_0(0 to 7) =>    sum_0(0 to 7)       ,
        sum_1(0 to 7) =>    sum_1(0 to 7)      );

 loc_1: entity work.xuq_agen_loca(xuq_agen_loca) port map(
         addr_sel     => addr_sel_64            ,
         addr_nsel    => addr_nsel_64           ,
         addr(0 to 7) => snoop_addr(8 to 15)    ,
          x_b(0 to 7) =>      x_b(8 to 15)      ,
          y_b(0 to 7) =>      y_b(8 to 15)      ,
        sum_0(0 to 7) =>    sum_0(8 to 15)      ,
        sum_1(0 to 7) =>    sum_1(8 to 15)     );

 loc_2: entity work.xuq_agen_loca(xuq_agen_loca) port map(
         addr_sel     => addr_sel_64            ,
         addr_nsel    => addr_nsel_64           ,
         addr(0 to 7) => snoop_addr(16 to 23)   ,
          x_b(0 to 7) =>      x_b(16 to 23)     ,
          y_b(0 to 7) =>      y_b(16 to 23)     ,
        sum_0(0 to 7) =>    sum_0(16 to 23)     ,
        sum_1(0 to 7) =>    sum_1(16 to 23)    );

 loc_3: entity work.xuq_agen_loca(xuq_agen_loca) port map(
         addr_sel     => addr_sel_64            ,
         addr_nsel    => addr_nsel_64           ,
         addr(0 to 7) => snoop_addr(24 to 31)   ,
          x_b(0 to 7) =>      x_b(24 to 31)     ,
          y_b(0 to 7) =>      y_b(24 to 31)     ,
        sum_0(0 to 7) =>    sum_0(24 to 31)     ,
        sum_1(0 to 7) =>    sum_1(24 to 31)    );

 loc_4: entity work.xuq_agen_loca(xuq_agen_loca) port map(
         addr_sel     => addr_sel             ,
         addr_nsel    => addr_nsel            ,
         addr(0 to 7) => snoop_addr(32 to 39) ,
          x_b(0 to 7) =>    x_b(32 to 39)     ,
          y_b(0 to 7) =>    y_b(32 to 39)     ,
        sum_0(0 to 7) =>  sum_0(32 to 39)     ,
        sum_1(0 to 7) =>  sum_1(32 to 39)    );

 loc_5: entity work.xuq_agen_loca(xuq_agen_loca) port map(
         addr_sel     => addr_sel             ,
         addr_nsel    => addr_nsel            ,
         addr(0 to 7) => snoop_addr(40 to 47) ,
          x_b(0 to 7) =>    x_b(40 to 47)     ,
          y_b(0 to 7) =>    y_b(40 to 47)     ,
        sum_0(0 to 7) =>  sum_0(40 to 47)     ,
        sum_1(0 to 7) =>  sum_1(40 to 47)    );

 loc_6: entity work.xuq_agen_locae(xuq_agen_locae) port map(
         addr_sel     => addr_sel             ,
         addr_nsel    => addr_nsel            ,
         addr(0 to 3) => snoop_addr(48 to 51) ,
          x_b(0 to 7) =>    x_b(48 to 55)     ,
          y_b(0 to 7) =>    y_b(48 to 55)     ,
        sum_0(0 to 3) =>  sum_0(48 to 51)     ,
        sum_1(0 to 3) =>  sum_1(48 to 51)    );





 gclc_1: entity work.xuq_agen_glbloc(xuq_agen_glbloc) port map(
      x_b(0 to 7)  => x_b(8 to 15)       ,
      y_b(0 to 7)  => y_b(8 to 15)       ,
      g08          => g08(1)             ,
      t08          => t08(1)            );

 gclc_2: entity work.xuq_agen_glbloc(xuq_agen_glbloc) port map(
      x_b(0 to 7)  => x_b(16 to 23)      ,
      y_b(0 to 7)  => y_b(16 to 23)      ,
      g08          => g08(2)             ,
      t08          => t08(2)            );

 gclc_3: entity work.xuq_agen_glbloc(xuq_agen_glbloc) port map(
      x_b(0 to 7)  => x_b(24 to 31)      ,
      y_b(0 to 7)  => y_b(24 to 31)      ,
      g08          => g08(3)             ,
      t08          => t08(3)            );

 gclc_4: entity work.xuq_agen_glbloc(xuq_agen_glbloc) port map(
      x_b(0 to 7)  => x_b(32 to 39)      ,
      y_b(0 to 7)  => y_b(32 to 39)      ,
      g08          => g08(4)             ,
      t08          => t08(4)            );

 gclc_5: entity work.xuq_agen_glbloc(xuq_agen_glbloc) port map(
      x_b(0 to 7)  => x_b(40 to 47)      ,
      y_b(0 to 7)  => y_b(40 to 47)      ,
      g08          => g08(5)             ,
      t08          => t08(5)            );

 gclc_6: entity work.xuq_agen_glbloc(xuq_agen_glbloc) port map(
      x_b(0 to 7)  => x_b(48 to 55)      ,
      y_b(0 to 7)  => y_b(48 to 55)      ,
      g08          => g08(6)             ,
      t08          => t08(6)            );

 gclc_7: entity work.xuq_agen_glbloc_lsb(xuq_agen_glbloc_lsb) port map(
      x_b(0 to 7)  => x_b(56 to 63)      ,
      y_b(0 to 7)  => y_b(56 to 63)      ,
      g08          => g08(7)            );



 gc: entity work.xuq_agen_glbglb(xuq_agen_glbglb) port map(
     g08(1 to 7)    => g08(1 to 7)    ,
     t08(1 to 6)    => t08(1 to 6)    ,
     c64_b(1 to 7)  => c64_b(1 to 7) );
  

       

 fm_0: entity work.xuq_agen_csmux(xuq_agen_csmux) port map(
  ci_b             => c64_b(1)               ,
  sum_0(0 to 7)    => sum_0    (0 to 7)      ,
  sum_1(0 to 7)    => sum_1    (0 to 7)      ,
  sum  (0 to 7)    => sum_int  (0 to 7)     );

 fm_1: entity work.xuq_agen_csmux(xuq_agen_csmux) port map(
  ci_b             => c64_b(2)               ,
  sum_0(0 to 7)    => sum_0    (8 to 15)     ,
  sum_1(0 to 7)    => sum_1    (8 to 15)     ,
  sum  (0 to 7)    => sum_int  (8 to 15)    );

 fm_2: entity work.xuq_agen_csmux(xuq_agen_csmux) port map(
  ci_b             => c64_b(3)               ,
  sum_0(0 to 7)    => sum_0    (16 to 23)    ,
  sum_1(0 to 7)    => sum_1    (16 to 23)    ,
  sum  (0 to 7)    => sum_int  (16 to 23)   );

 fm_3: entity work.xuq_agen_csmux(xuq_agen_csmux) port map(
  ci_b             => c64_b(4)               ,
  sum_0(0 to 7)    => sum_0    (24 to 31)    ,
  sum_1(0 to 7)    => sum_1    (24 to 31)    ,
  sum  (0 to 7)    => sum_int  (24 to 31)   );

 fm_4: entity work.xuq_agen_csmux(xuq_agen_csmux) port map(
  ci_b             => c64_b(5)               ,
  sum_0(0 to 7)    => sum_0    (32 to 39)    ,
  sum_1(0 to 7)    => sum_1    (32 to 39)    ,
  sum  (0 to 7)    => sum_int  (32 to 39)   );

 fm_5: entity work.xuq_agen_csmux(xuq_agen_csmux) port map(
  ci_b             => c64_b(6)              ,
  sum_0(0 to 7)    => sum_0    (40 to 47)    ,
  sum_1(0 to 7)    => sum_1    (40 to 47)    ,
  sum  (0 to 7)    => sum_int  (40 to 47)   );

    
 fm_6: entity work.xuq_agen_csmuxe(xuq_agen_csmuxe) port map( 
  ci_b             => c64_b(7)               ,
  sum_0(0 to 3)    => sum_0    (48 to 51)    ,
  sum_1(0 to 3)    => sum_1    (48 to 51)    ,
  sum  (0 to 3)    => sum_int  (48 to 51)   );

 kog: entity work.xuq_agen_lo(xuq_agen_lo) port map( 
     dir_ig_57_b      => dir_ig_57_b             ,
     x_b    (0 to 11) => x_b         (52 to 63)  ,
     y_b    (0 to 11) => y_b         (52 to 63)  ,
     sum    (0 to 11) => sum_non_erat(52 to 63)  ,
     sum_arr(1 to  5) => sum_arr     (53 to 57) );


  u_non_b:   sum_non_erat_b(0 to 51) <= not( sum_int(0 to 51) );
  u_non:     sum_non_erat  (0 to 51) <= not( sum_non_erat_b(0 to 51) );

  sum(0 to 51) <= sum_int(0 to 51) ; 




   u_sum_lv1_1:  sum_arr_lv1_1_b(53 to 57) <= not( sum_arr        (53 to 57) ); 
   u_sum_lv2_0:  sum_arr_dir01(53 to 57)   <= not( sum_arr_lv1_1_b(53 to 57) ); 
   u_sum_lv2_1:  sum_arr_dir45(53 to 57)   <= not( sum_arr_lv1_1_b(53 to 57) ); 


   u_sum_lv1_0:  sum_arr_lv1_0_b(53 to 57) <= not( sum_arr        (53 to 57) ); 
   u_sum_lv2_2:  sum_arr_dir23(53 to 57)   <= not( sum_arr_lv1_0_b(53 to 57) ); 
   u_sum_lv2_3:  sum_arr_dir67(53 to 57)   <= not( sum_arr_lv1_0_b(53 to 57) ); 



 agcmp: entity work.xuq_agen_cmp(xuq_agen_cmp) port map( 
     x_b(53 to 63)        => x_b(53 to 63)      ,
     y_b(53 to 63)        => y_b(53 to 63)      ,
     z  (53 to 57)        => z  (53 to 57)      ,
     inv1_val_b           => inv1_val_b         ,
     ex1_cache_acc_b      => ex1_cache_acc_b    ,
     dir_ig_57_b          => dir_ig_57_b        ,
     rel3_val             => rel3_val           ,
     way(0 to 7)          => way(0 to 7)        ,
     ary_write_act_01     => ary_write_act_01   ,
     ary_write_act_23     => ary_write_act_23   ,
     ary_write_act_45     => ary_write_act_45   ,
     ary_write_act_67     => ary_write_act_67   ,
     ary_write_act        => ary_write_act      ,
     match_oth            => match_oth          ,
     vdd                  => vdd                ,
     gnd                  => gnd);


end; 
