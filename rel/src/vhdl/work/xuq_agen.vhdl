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
generic(       expand_type               : integer := 2  ); -- 0 - ibm tech, 1 - other );
port(
     x            :in  std_ulogic_vector(0 to 63) ; 
     y            :in  std_ulogic_vector(0 to 63) ;
     snoop_addr   :in  std_ulogic_vector(0 to 51) ; --new snoop_address
     snoop_sel    :in  std_ulogic  ;
     binv_val     :in  std_ulogic  ;
     mode64       :in  std_ulogic  ; -- 1 per byte [0:31]
     dir_ig_57_b  :in  std_ulogic  ; -- when this is low , bit 57 becomes "1" .


     sum_non_erat :out std_ulogic_vector(0 to 63) ; -- for compares and uses other than array address
     sum          :out std_ulogic_vector(0 to 51) ; -- 0:51 for erat
     sum_arr_dir01  :out std_ulogic_vector(53 to 57) ;
     sum_arr_dir23  :out std_ulogic_vector(53 to 57) ;
     sum_arr_dir45  :out std_ulogic_vector(53 to 57) ;
     sum_arr_dir67  :out std_ulogic_vector(53 to 57) ;

     z                 :in  std_ulogic_vector(53 to 57) ;-- 5 bits of compare data
     way               :in  std_ulogic_vector(0 to 7)   ;-- 8 bit vector use to be in array model
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



end xuq_agen; -- ENTITY

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

  signal sum_arr         :std_ulogic_vector(53 to 57); -- 0:11
  signal sum_arr_lv1_0_b :std_ulogic_vector(53 to 57);
  signal sum_arr_lv1_1_b :std_ulogic_vector(53 to 57);
 


begin


     addr_nsel_64 <= mode64 and not (snoop_sel and not binv_val) ;
     addr_nsel    <=            not (snoop_sel and not binv_val) ;
     addr_sel_64  <=                (snoop_sel and not binv_val) ;
     addr_sel     <=                (snoop_sel and not binv_val) ;


-- assume pins come in the top
-- start global carry along the top .
-- byte groups (0 near top) stretch out along the macro.

  u_xi: x_b(0 to 63) <= not( x(0 to 63) ); -- receiving inverter near pin
  u_yi: y_b(0 to 63) <= not( y(0 to 63) ); -- receiving inverter near pin
   
--//##################################################
--//## local part of byte group
--//##################################################

 loc_0: entity work.xuq_agen_loca(xuq_agen_loca) port map(
         addr_sel     => addr_sel_64            ,--i--
         addr_nsel    => addr_nsel_64           ,--i--
         addr(0 to 7) => snoop_addr(0 to 7)     ,--i--
          x_b(0 to 7) =>      x_b(0 to 7)       ,--i--
          y_b(0 to 7) =>      y_b(0 to 7)       ,--i--
        sum_0(0 to 7) =>    sum_0(0 to 7)       ,--o--
        sum_1(0 to 7) =>    sum_1(0 to 7)      );--o--

 loc_1: entity work.xuq_agen_loca(xuq_agen_loca) port map(
         addr_sel     => addr_sel_64            ,--i--
         addr_nsel    => addr_nsel_64           ,--i--
         addr(0 to 7) => snoop_addr(8 to 15)    ,--i--
          x_b(0 to 7) =>      x_b(8 to 15)      ,--i--
          y_b(0 to 7) =>      y_b(8 to 15)      ,--i--
        sum_0(0 to 7) =>    sum_0(8 to 15)      ,--o--
        sum_1(0 to 7) =>    sum_1(8 to 15)     );--o--

 loc_2: entity work.xuq_agen_loca(xuq_agen_loca) port map(
         addr_sel     => addr_sel_64            ,--i--
         addr_nsel    => addr_nsel_64           ,--i--
         addr(0 to 7) => snoop_addr(16 to 23)   ,--i--
          x_b(0 to 7) =>      x_b(16 to 23)     ,--i--
          y_b(0 to 7) =>      y_b(16 to 23)     ,--i--
        sum_0(0 to 7) =>    sum_0(16 to 23)     ,--o--
        sum_1(0 to 7) =>    sum_1(16 to 23)    );--o--

 loc_3: entity work.xuq_agen_loca(xuq_agen_loca) port map(
         addr_sel     => addr_sel_64            ,--i--
         addr_nsel    => addr_nsel_64           ,--i--
         addr(0 to 7) => snoop_addr(24 to 31)   ,--i--
          x_b(0 to 7) =>      x_b(24 to 31)     ,--i--
          y_b(0 to 7) =>      y_b(24 to 31)     ,--i--
        sum_0(0 to 7) =>    sum_0(24 to 31)     ,--o--
        sum_1(0 to 7) =>    sum_1(24 to 31)    );--o--

 loc_4: entity work.xuq_agen_loca(xuq_agen_loca) port map(
         addr_sel     => addr_sel             ,--i--
         addr_nsel    => addr_nsel            ,--i--
         addr(0 to 7) => snoop_addr(32 to 39) ,--i--
          x_b(0 to 7) =>    x_b(32 to 39)     ,--i--
          y_b(0 to 7) =>    y_b(32 to 39)     ,--i--
        sum_0(0 to 7) =>  sum_0(32 to 39)     ,--o--
        sum_1(0 to 7) =>  sum_1(32 to 39)    );--o--

 loc_5: entity work.xuq_agen_loca(xuq_agen_loca) port map(
         addr_sel     => addr_sel             ,--i--
         addr_nsel    => addr_nsel            ,--i--
         addr(0 to 7) => snoop_addr(40 to 47) ,--i--
          x_b(0 to 7) =>    x_b(40 to 47)     ,--i--
          y_b(0 to 7) =>    y_b(40 to 47)     ,--i--
        sum_0(0 to 7) =>  sum_0(40 to 47)     ,--o--
        sum_1(0 to 7) =>  sum_1(40 to 47)    );--o--

 loc_6: entity work.xuq_agen_locae(xuq_agen_locae) port map(
         addr_sel     => addr_sel             ,--i--
         addr_nsel    => addr_nsel            ,--i--
         addr(0 to 3) => snoop_addr(48 to 51) ,--i--
          x_b(0 to 7) =>    x_b(48 to 55)     ,--i--
          y_b(0 to 7) =>    y_b(48 to 55)     ,--i--
        sum_0(0 to 3) =>  sum_0(48 to 51)     ,--o--
        sum_1(0 to 3) =>  sum_1(48 to 51)    );--o--


--//##################################################
--//## local part of global carry
--//##################################################

 gclc_1: entity work.xuq_agen_glbloc(xuq_agen_glbloc) port map(
      x_b(0 to 7)  => x_b(8 to 15)       ,--i--
      y_b(0 to 7)  => y_b(8 to 15)       ,--i--
      g08          => g08(1)             ,--o--
      t08          => t08(1)            );--o--

 gclc_2: entity work.xuq_agen_glbloc(xuq_agen_glbloc) port map(
      x_b(0 to 7)  => x_b(16 to 23)      ,--i--
      y_b(0 to 7)  => y_b(16 to 23)      ,--i--
      g08          => g08(2)             ,--o--
      t08          => t08(2)            );--o--

 gclc_3: entity work.xuq_agen_glbloc(xuq_agen_glbloc) port map(
      x_b(0 to 7)  => x_b(24 to 31)      ,--i--
      y_b(0 to 7)  => y_b(24 to 31)      ,--i--
      g08          => g08(3)             ,--o--
      t08          => t08(3)            );--o--

 gclc_4: entity work.xuq_agen_glbloc(xuq_agen_glbloc) port map(
      x_b(0 to 7)  => x_b(32 to 39)      ,--i--
      y_b(0 to 7)  => y_b(32 to 39)      ,--i--
      g08          => g08(4)             ,--o--
      t08          => t08(4)            );--o--

 gclc_5: entity work.xuq_agen_glbloc(xuq_agen_glbloc) port map(
      x_b(0 to 7)  => x_b(40 to 47)      ,--i--
      y_b(0 to 7)  => y_b(40 to 47)      ,--i--
      g08          => g08(5)             ,--o--
      t08          => t08(5)            );--o--

 gclc_6: entity work.xuq_agen_glbloc(xuq_agen_glbloc) port map(
      x_b(0 to 7)  => x_b(48 to 55)      ,--i--
      y_b(0 to 7)  => y_b(48 to 55)      ,--i--
      g08          => g08(6)             ,--o--
      t08          => t08(6)            );--o--

 gclc_7: entity work.xuq_agen_glbloc_lsb(xuq_agen_glbloc_lsb) port map(
      x_b(0 to 7)  => x_b(56 to 63)      ,--i--
      y_b(0 to 7)  => y_b(56 to 63)      ,--i--
      g08          => g08(7)            );--o--
--    t08          => t08(7)            );--o--


--//##################################################
--//## global part of global carry  {replicate ending of global carry vertical)
--//##################################################

 gc: entity work.xuq_agen_glbglb(xuq_agen_glbglb) port map(
     g08(1 to 7)    => g08(1 to 7)    ,--i--
     t08(1 to 6)    => t08(1 to 6)    ,--i--
     c64_b(1 to 7)  => c64_b(1 to 7) );--o--
  

       
--//##################################################
--//## final mux  (vertical)
--//##################################################

 fm_0: entity work.xuq_agen_csmux(xuq_agen_csmux) port map(
  ci_b             => c64_b(1)               ,--i--
  sum_0(0 to 7)    => sum_0    (0 to 7)      ,--i--
  sum_1(0 to 7)    => sum_1    (0 to 7)      ,--i--
  sum  (0 to 7)    => sum_int  (0 to 7)     );--o--

 fm_1: entity work.xuq_agen_csmux(xuq_agen_csmux) port map(
  ci_b             => c64_b(2)               ,--i--
  sum_0(0 to 7)    => sum_0    (8 to 15)     ,--i--
  sum_1(0 to 7)    => sum_1    (8 to 15)     ,--i--
  sum  (0 to 7)    => sum_int  (8 to 15)    );--o--

 fm_2: entity work.xuq_agen_csmux(xuq_agen_csmux) port map(
  ci_b             => c64_b(3)               ,--i--
  sum_0(0 to 7)    => sum_0    (16 to 23)    ,--i--
  sum_1(0 to 7)    => sum_1    (16 to 23)    ,--i--
  sum  (0 to 7)    => sum_int  (16 to 23)   );--o--

 fm_3: entity work.xuq_agen_csmux(xuq_agen_csmux) port map(
  ci_b             => c64_b(4)               ,--i--
  sum_0(0 to 7)    => sum_0    (24 to 31)    ,--i--
  sum_1(0 to 7)    => sum_1    (24 to 31)    ,--i--
  sum  (0 to 7)    => sum_int  (24 to 31)   );--o--

 fm_4: entity work.xuq_agen_csmux(xuq_agen_csmux) port map(
  ci_b             => c64_b(5)               ,--i--
  sum_0(0 to 7)    => sum_0    (32 to 39)    ,--i--
  sum_1(0 to 7)    => sum_1    (32 to 39)    ,--i--
  sum  (0 to 7)    => sum_int  (32 to 39)   );--o--

 fm_5: entity work.xuq_agen_csmux(xuq_agen_csmux) port map(
  ci_b             => c64_b(6)              ,--i--
  sum_0(0 to 7)    => sum_0    (40 to 47)    ,--i--
  sum_1(0 to 7)    => sum_1    (40 to 47)    ,--i--
  sum  (0 to 7)    => sum_int  (40 to 47)   );--o--

    
 fm_6: entity work.xuq_agen_csmuxe(xuq_agen_csmuxe) port map( -- just the 4 msb of the byte go to erat
  ci_b             => c64_b(7)               ,--i--
  sum_0(0 to 3)    => sum_0    (48 to 51)    ,--i--
  sum_1(0 to 3)    => sum_1    (48 to 51)    ,--i--
  sum  (0 to 3)    => sum_int  (48 to 51)   );--o--

 kog: entity work.xuq_agen_lo(xuq_agen_lo) port map( -- 12 lsbs are for the DIRECTORY
     dir_ig_57_b      => dir_ig_57_b             ,--i--xuq_agen_lo(kog) // force dir addr 57 to "1"
     x_b    (0 to 11) => x_b         (52 to 63)  ,--i--xuq_agen_lo(kog)
     y_b    (0 to 11) => y_b         (52 to 63)  ,--i--xuq_agen_lo(kog)
     sum    (0 to 11) => sum_non_erat(52 to 63)  ,--o--xuq_agen_lo(kog) // for the compares etc
     sum_arr(1 to  5) => sum_arr     (53 to 57) );--o--xuq_agen_lo(kog) // for the array address


  u_non_b:   sum_non_erat_b(0 to 51) <= not( sum_int(0 to 51) );
  u_non:     sum_non_erat  (0 to 51) <= not( sum_non_erat_b(0 to 51) );

  sum(0 to 51) <= sum_int(0 to 51) ; --rename-- to ERAT only


 -- ###################################
 -- # repower network for directory
 -- ###################################


   u_sum_lv1_1:  sum_arr_lv1_1_b(53 to 57) <= not( sum_arr        (53 to 57) ); -- 4x
   u_sum_lv2_0:  sum_arr_dir01(53 to 57)   <= not( sum_arr_lv1_1_b(53 to 57) ); -- 4x --output--
   u_sum_lv2_1:  sum_arr_dir45(53 to 57)   <= not( sum_arr_lv1_1_b(53 to 57) ); -- 4x --output--


   u_sum_lv1_0:  sum_arr_lv1_0_b(53 to 57) <= not( sum_arr        (53 to 57) ); -- 6x
   u_sum_lv2_2:  sum_arr_dir23(53 to 57)   <= not( sum_arr_lv1_0_b(53 to 57) ); -- 4x --output--
   u_sum_lv2_3:  sum_arr_dir67(53 to 57)   <= not( sum_arr_lv1_0_b(53 to 57) ); -- 4x --output--


  -- ######################################################################
  -- ## this experimental piece is for directory read/write collisions
  -- ######################################################################
     -- it is a multi-mode 4 or 5 bit compare

 agcmp: entity work.xuq_agen_cmp(xuq_agen_cmp) port map( -- 11 lsbs are for the DIRECTORY
     x_b(53 to 63)        => x_b(53 to 63)      ,--i--agcmp--
     y_b(53 to 63)        => y_b(53 to 63)      ,--i--agcmp--
     z  (53 to 57)        => z  (53 to 57)      ,--i--agcmp--   (compare data)
     inv1_val_b           => inv1_val_b         ,--i--agcmp--
     ex1_cache_acc_b      => ex1_cache_acc_b    ,--i--agamp--
     dir_ig_57_b          => dir_ig_57_b        ,--i--agcmp--
     rel3_val             => rel3_val           ,--i--agcmp--
     way(0 to 7)          => way(0 to 7)        ,--i--agcmp--
     ary_write_act_01     => ary_write_act_01   ,--o--agcmp--
     ary_write_act_23     => ary_write_act_23   ,--o--agcmp--
     ary_write_act_45     => ary_write_act_45   ,--o--agcmp--
     ary_write_act_67     => ary_write_act_67   ,--o--agcmp--
     ary_write_act        => ary_write_act      ,
     match_oth            => match_oth          ,--o--agcmp-- for other uses
     vdd                  => vdd                ,
     gnd                  => gnd);


end; -- xuq_agen ARCHITECTURE
