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


entity fuq_add_glbc is port(
     ex3_g16               :in  std_ulogic_vector(0 to 6); -- from each byte section
     ex3_t16               :in  std_ulogic_vector(0 to 6); -- from each byte section

     ex3_inc_all1          :in  std_ulogic;
     ex3_effsub            :in  std_ulogic; 
     ex3_effsub_npz        :in  std_ulogic; 
     ex3_effadd_npz        :in  std_ulogic; 
     f_alg_ex3_frc_sel_p1  :in  std_ulogic;
     f_alg_ex3_sticky      :in  std_ulogic;
     f_pic_ex3_is_nan      :in  std_ulogic;
     f_pic_ex3_is_gt       :in  std_ulogic;
     f_pic_ex3_is_lt       :in  std_ulogic;
     f_pic_ex3_is_eq       :in  std_ulogic;
     f_pic_ex3_cmp_sgnpos  :in  std_ulogic;
     f_pic_ex3_cmp_sgnneg  :in  std_ulogic;
     --------------------
     ex3_g128              :out std_ulogic_vector(1 to 6); -- to each byte section
     ex3_g128_b            :out std_ulogic_vector(1 to 6); -- to each byte section
     ex3_t128              :out std_ulogic_vector(1 to 6); -- to each byte section
     ex3_t128_b            :out std_ulogic_vector(1 to 6); -- to each byte section
     --------------------
     ex3_flip_inc_p0       :out std_ulogic;
     ex3_flip_inc_p1       :out std_ulogic;
     ex3_inc_sel_p0        :out std_ulogic;
     ex3_inc_sel_p1        :out std_ulogic;
     ex3_eac_sel_p0n       :out std_ulogic_vector(0 to 6);
     ex3_eac_sel_p0        :out std_ulogic_vector(0 to 6);
     ex3_eac_sel_p1        :out std_ulogic_vector(0 to 6);

     ex3_sign_carry        :out std_ulogic;
     ex3_flag_nan_cp1      :out std_ulogic;
     ex3_flag_gt_cp1       :out std_ulogic;
     ex3_flag_lt_cp1       :out std_ulogic;
     ex3_flag_eq_cp1       :out std_ulogic;
     ex3_flag_nan          :out std_ulogic;
     ex3_flag_gt           :out std_ulogic;
     ex3_flag_lt           :out std_ulogic;
     ex3_flag_eq           :out std_ulogic
 );



END                                 fuq_add_glbc;


ARCHITECTURE fuq_add_glbc  OF fuq_add_glbc  IS

 constant tiup : std_ulogic := '1';
 constant tidn : std_ulogic := '0';


 signal cp0_g32_01_b,  cp0_g32_23_b,  cp0_g32_45_b, cp0_g32_66_b :std_ulogic;
 signal cp0_t32_01_b , cp0_t32_23_b,  cp0_t32_45_b, cp0_t32_66_b :std_ulogic;
 signal cp0_g64_03,    cp0_g64_46,    cp0_t64_03,   cp0_t64_46   :std_ulogic;
 signal cp0_g128_06_b, cp0_t128_06_b :std_ulogic;
 signal cp0_all1_b, cp0_all1_p,  cp0_co_p0, cp0_co_p1 :std_ulogic;
 signal cp0_flip_inc_p1_b, ex3_inc_sel_p0_b, ex3_sign_carry_b  :std_ulogic;
 signal ex3_my_gt_b,   ex3_my_lt , ex3_my_eq_b   :std_ulogic;
 signal ex3_my_gt ,    ex3_my_eq      :std_ulogic;
 signal ex3_gt_pos_b , ex3_gt_neg_b , ex3_lt_pos_b , ex3_lt_neg_b , ex3_eq_eq_b    :std_ulogic;
 signal ex3_is_gt_b,   ex3_is_lt_b,   ex3_is_eq_b,  ex3_sgn_eq :std_ulogic;

 signal  cp7_g32_00_b    ,  cp7_g32_12_b    ,  cp7_g32_34_b    ,  cp7_g32_56_b    :std_ulogic;
 signal  cp7_t32_00_b    ,  cp7_t32_12_b    ,  cp7_t32_34_b      :std_ulogic;
 signal  cp7_g64_02      ,  cp7_g64_36      ,  cp7_t64_02         :std_ulogic;
 signal  cp7_g128_06_b   :std_ulogic;
 signal  cp7_all1_b      ,  cp7_all1_p      ,  cp7_co_p0       :std_ulogic;
 signal  cp7_sel_p0n_x_b ,  cp7_sel_p0n_y_b :std_ulogic;
 signal  cp7_sel_p0_b    ,  cp7_sel_p1_b    :std_ulogic;
 signal  cp7_sub_sticky  ,  cp7_sub_stickyn :std_ulogic;
 signal  cp7_add_frcp1_b ,  cp7_add_frcp0_b :std_ulogic;

 signal  cp6_g32_00_b    ,  cp6_g32_12_b    ,  cp6_g32_34_b    ,  cp6_g32_56_b    :std_ulogic;
 signal  cp6_t32_00_b    ,  cp6_t32_12_b    ,  cp6_t32_34_b       :std_ulogic;
 signal  cp6_g64_02      ,  cp6_g64_36      ,  cp6_t64_02          :std_ulogic;
 signal  cp6_g128_06_b   :std_ulogic;
 signal  cp6_all1_b      ,  cp6_all1_p      ,  cp6_co_p0       :std_ulogic;
 signal  cp6_sel_p0n_x_b ,  cp6_sel_p0n_y_b :std_ulogic;
 signal  cp6_sel_p0_b    ,  cp6_sel_p1_b    :std_ulogic;
 signal  cp6_sub_sticky  ,  cp6_sub_stickyn :std_ulogic;
 signal  cp6_add_frcp1_b ,  cp6_add_frcp0_b :std_ulogic;

 signal  cp5_g32_00_b    ,  cp5_g32_12_b    ,  cp5_g32_34_b    ,  cp5_g32_56_b    :std_ulogic;
 signal  cp5_t32_00_b    ,  cp5_t32_12_b    ,  cp5_t32_34_b    ,  cp5_t32_56_b    :std_ulogic;
 signal  cp5_g64_02      ,  cp5_g64_36      ,  cp5_t64_02        :std_ulogic;
 signal  cp5_g128_06_b   :std_ulogic;
 signal  cp5_all1_b      ,  cp5_all1_p      ,  cp5_co_p0       :std_ulogic;
 signal  cp5_sel_p0n_x_b ,  cp5_sel_p0n_y_b :std_ulogic;
 signal  cp5_sel_p0_b    ,  cp5_sel_p1_b    :std_ulogic;
 signal  cp5_sub_sticky  ,  cp5_sub_stickyn :std_ulogic;
 signal  cp5_add_frcp1_b ,  cp5_add_frcp0_b :std_ulogic;



 signal  cp4_g32_01_b,  cp4_g32_23_b,  cp4_g32_45_b, cp4_g32_66_b :std_ulogic;
 signal  cp4_t32_01_b , cp4_t32_23_b,  cp4_t32_45_b, cp4_t32_66_b :std_ulogic;
 signal  cp4_g64_03,    cp4_g64_46,    cp4_t64_03,   cp4_t64_46   :std_ulogic;
 signal  cp4_g128_06_b :std_ulogic;
 signal  cp4_all1_b      ,  cp4_all1_p      ,  cp4_co_p0       :std_ulogic;
 signal  cp4_sel_p0n_x_b ,  cp4_sel_p0n_y_b :std_ulogic;
 signal  cp4_sel_p0_b    ,  cp4_sel_p1_b    :std_ulogic;
 signal  cp4_sub_sticky  ,  cp4_sub_stickyn :std_ulogic;
 signal  cp4_add_frcp1_b ,  cp4_add_frcp0_b :std_ulogic;


 signal  cp3_g32_00_b    ,  cp3_g32_12_b    ,  cp3_g32_34_b    ,  cp3_g32_56_b    :std_ulogic;
 signal  cp3_t32_00_b    ,  cp3_t32_12_b    ,  cp3_t32_34_b    ,  cp3_t32_56_b    :std_ulogic;
 signal  cp3_g64_02      ,  cp3_g64_36      ,  cp3_t64_02      ,  cp3_t64_36      :std_ulogic;
 signal  cp3_g128_06_b     :std_ulogic;
 signal  cp3_all1_b      ,  cp3_all1_p      ,  cp3_co_p0        :std_ulogic;
 signal  cp3_sel_p0n_x_b ,  cp3_sel_p0n_y_b :std_ulogic;
 signal  cp3_sel_p0_b    ,  cp3_sel_p1_b    :std_ulogic;
 signal  cp3_sub_sticky  ,  cp3_sub_stickyn :std_ulogic;
 signal  cp3_add_frcp1_b ,  cp3_add_frcp0_b :std_ulogic;

 signal  cp2_g32_01_b,  cp2_g32_23_b,  cp2_g32_45_b, cp2_g32_66_b :std_ulogic;
 signal  cp2_t32_01_b , cp2_t32_23_b,  cp2_t32_45_b, cp2_t32_66_b :std_ulogic;
 signal  cp2_g64_03,    cp2_g64_46,    cp2_t64_03,   cp2_t64_46   :std_ulogic;
 signal  cp2_g128_06_b :std_ulogic;
 signal  cp2_all1_b      ,  cp2_all1_p      ,  cp2_co_p0        :std_ulogic;
 signal  cp2_sel_p0n_x_b ,  cp2_sel_p0n_y_b :std_ulogic;
 signal  cp2_sel_p0_b    ,  cp2_sel_p1_b    :std_ulogic;
 signal  cp2_sub_sticky  ,  cp2_sub_stickyn :std_ulogic;
 signal  cp2_add_frcp1_b ,  cp2_add_frcp0_b :std_ulogic;

 signal  cp1_g32_01_b,  cp1_g32_23_b,  cp1_g32_45_b, cp1_g32_66_b :std_ulogic;
 signal  cp1_t32_01_b , cp1_t32_23_b,  cp1_t32_45_b, cp1_t32_66_b :std_ulogic;
 signal  cp1_g64_03,    cp1_g64_46,    cp1_t64_03,   cp1_t64_46   :std_ulogic;
 signal  cp1_g128_06_b :std_ulogic;
 signal  cp1_all1_b      ,  cp1_all1_p      ,  cp1_co_p0        :std_ulogic;
 signal  cp1_sel_p0n_x_b ,  cp1_sel_p0n_y_b :std_ulogic;
 signal  cp1_sel_p0_b    ,  cp1_sel_p1_b    :std_ulogic;
 signal  cp1_sub_sticky  ,  cp1_sub_stickyn :std_ulogic;
 signal  cp1_add_frcp1_b ,  cp1_add_frcp0_b :std_ulogic;

signal cp1_g32_11_b, cp1_t32_11_b, cp1_g64_13, cp1_t64_13, cp1_g128_16_b, cp1_t128_16_b :std_ulogic; --EXTRA
signal cp2_g64_23, cp2_t64_23, cp2_g128_26_b, cp2_t128_26_b :std_ulogic;
signal cp3_g128_36_b, cp3_t128_36_b :std_ulogic;
signal cp4_g128_46_b, cp4_t128_46_b :std_ulogic;
signal cp5_g64_56,    cp5_t64_56, cp5_g128_56_b, cp5_t128_56_b :std_ulogic;
signal cp6_g32_66_b,  cp6_t32_66_b :std_ulogic;

signal cp1_g128_16,  cp1_t128_16  :std_ulogic; --DRIVER
signal cp2_g128_26,  cp2_t128_26  :std_ulogic;
signal cp3_g128_36,  cp3_t128_36  :std_ulogic;
signal cp4_g128_46,  cp4_t128_46  :std_ulogic;
signal cp5_g128_56,  cp5_t128_56  :std_ulogic;
signal cp6_g128_66,  cp6_t128_66  :std_ulogic;

   



BEGIN

--=#########################################
--= global carry chain <PARALLEL VERSIONS>
--=#########################################
  -- try to put all long wire from BYT to global
  -- parallel copies should allow for smaller aoi/oai blocks

--=#########################################
--= CMP COPY
--=#########################################


ucp0_g32_01:   cp0_g32_01_b <= not( ex3_g16(0) or ( ex3_t16(0) and ex3_g16(1) ) ); --cw_aoi21
ucp0_g32_23:   cp0_g32_23_b <= not( ex3_g16(2) or ( ex3_t16(2) and ex3_g16(3) ) ); --cw_aoi21
ucp0_g32_45:   cp0_g32_45_b <= not( ex3_g16(4) or ( ex3_t16(4) and ex3_g16(5) ) ); --cw_aoi21
ucp0_g32_66:   cp0_g32_66_b <= not( ex3_g16(6)                                  ); --cw_invert --done

ucp0_t32_01:   cp0_t32_01_b <= not( ex3_t16(0) and ex3_t16(1) ); --cw_nand2
ucp0_t32_23:   cp0_t32_23_b <= not( ex3_t16(2) and ex3_t16(3) ); --cw_nand2
ucp0_t32_45:   cp0_t32_45_b <= not( ex3_t16(4) and ex3_t16(5) ); --cw_nand2
ucp0_t32_66:   cp0_t32_66_b <= not( ex3_t16(6)                ); --cw_invert

ucp0_g64_03:   cp0_g64_03   <= not( cp0_g32_01_b and (cp0_t32_01_b or  cp0_g32_23_b) ); --cw_oai21
ucp0_g64_46:   cp0_g64_46   <= not( cp0_g32_45_b and (cp0_t32_45_b or  cp0_g32_66_b) ); --cw_oai21

ucp0_t64_03:   cp0_t64_03   <= not(                   cp0_t32_01_b or  cp0_t32_23_b  ); --cw_nor2
ucp0_t64_46:   cp0_t64_46   <= not( cp0_g32_45_b and (cp0_t32_45_b or  cp0_t32_66_b) ); --cw_oai21

ucp0_g128_06:  cp0_g128_06_b <= not( cp0_g64_03 or ( cp0_t64_03 and cp0_g64_46 ) ); --cw_aoi21
ucp0_t128_06:  cp0_t128_06_b <= not( cp0_g64_03 or ( cp0_t64_03 and cp0_t64_46 ) ); --cw_aoi21

ucp0_all1n:    cp0_all1_b     <= not ex3_inc_all1     ;--cw_invert
ucp0_all1p:    cp0_all1_p     <= not  cp0_all1_b      ;--cw_invert
ucp0_co_p0:    cp0_co_p0      <= not( cp0_g128_06_b ) ;--cw_invert
ucp0_co_p1:    cp0_co_p1      <= not( cp0_t128_06_b ) ;--cw_invert


              ---------------- incr eac selects --------------------

               ex3_flip_inc_p0   <= ex3_effsub; --NOT MAPPED --output--
ucp0_f1in:     cp0_flip_inc_p1_b <= not( ex3_effsub and cp0_all1_b ); --cw_nand2
ucp0_f1i:      ex3_flip_inc_p1   <= not( cp0_flip_inc_p1_b ); --cw_invert --output--

ucp0_s1i:      ex3_inc_sel_p1    <= not cp0_g128_06_b   ; --cw_invert --OUTPUT--
ucp0_s0in:     ex3_inc_sel_p0_b  <= not cp0_g128_06_b   ; --cw_invert
ucp0_s0i:      ex3_inc_sel_p0    <= not ex3_inc_sel_p0_b; --cw_invert --OUTPUT--

              ---------------- sign selects --------------------

ucp0_sgn0:     ex3_sign_carry_b <= not( ex3_effsub and cp0_all1_p and cp0_co_p0 );--cw_nand3
ucp0_sgn1:     ex3_sign_carry   <= not( ex3_sign_carry_b ); --cw_invert --OUTPUT--

             ----------------- compares ---------------------------

ucp0_my_gtn:  ex3_my_gt_b   <= not( cp0_co_p0 and cp0_all1_p );--cw_nand2
ucp0_my_lt:   ex3_my_lt     <= not( cp0_co_p1 and cp0_all1_p );--cw_nand2
ucp0_my_eqb:  ex3_my_eq_b   <= not( cp0_co_p1 and cp0_all1_p and cp0_g128_06_b );--cw_nand3

ucp0_my_gt:   ex3_my_gt     <= not ex3_my_gt_b ; --cw_invert
ucp0_my_eq:   ex3_my_eq     <= not ex3_my_eq_b ; --cw_invert

ucp0_gt_pos:  ex3_gt_pos_b  <= not( ex3_my_gt and f_pic_ex3_cmp_sgnpos);--cw_nand2
ucp0_gt_neg:  ex3_gt_neg_b  <= not( ex3_my_lt and f_pic_ex3_cmp_sgnneg);--cw_nand2
ucp0_lt_pos:  ex3_lt_pos_b  <= not( ex3_my_lt and f_pic_ex3_cmp_sgnpos);--cw_nand2
ucp0_lt_neg:  ex3_lt_neg_b  <= not( ex3_my_gt and f_pic_ex3_cmp_sgnneg);--cw_nand2
ucp0_eq_eq:   ex3_eq_eq_b   <= not( ex3_my_eq and       ex3_sgn_eq    );--cw_nand3

ucp0_flg_gt:  ex3_flag_gt       <= not( ex3_gt_pos_b and ex3_gt_neg_b and ex3_is_gt_b );--cw_nand3 --output--
ucp0_flg_gt1: ex3_flag_gt_cp1   <= not( ex3_gt_pos_b and ex3_gt_neg_b and ex3_is_gt_b );--cw_nand3 --output--
ucp0_flg_lt:  ex3_flag_lt       <= not( ex3_lt_pos_b and ex3_lt_neg_b and ex3_is_lt_b );--cw_nand3 --output--
ucp0_flg_lt1: ex3_flag_lt_cp1   <= not( ex3_lt_pos_b and ex3_lt_neg_b and ex3_is_lt_b );--cw_nand3 --output--
ucp0_flg_eq:  ex3_flag_eq       <= not( ex3_eq_eq_b                   and ex3_is_eq_b );--cw_nand2 --output--
ucp0_flg_eq1: ex3_flag_eq_cp1   <= not( ex3_eq_eq_b                   and ex3_is_eq_b );--cw_nand2 --output--

              ex3_flag_nan      <=  f_pic_ex3_is_nan;    --NOT MAPPED --output--
              ex3_flag_nan_cp1  <=  f_pic_ex3_is_nan;    --NOT MAPPED --output--

              ex3_is_gt_b <= not( f_pic_ex3_is_gt );--NOT MAPPED
              ex3_is_lt_b <= not( f_pic_ex3_is_lt );--NOT MAPPED
              ex3_is_eq_b <= not( f_pic_ex3_is_eq );--NOT MAPPED
              ex3_sgn_eq  <= f_pic_ex3_cmp_sgnpos or f_pic_ex3_cmp_sgnneg ; --NOT MAPPED


--=#########################################
--= BYT_0 MSB COPY
--=#########################################

ucp1_g32_11:   cp1_g32_11_b <= not( ex3_g16(1)                                  ); --cw_aoi21 --EXTRA
ucp1_g32_01:   cp1_g32_01_b <= not( ex3_g16(0) or ( ex3_t16(0) and ex3_g16(1) ) ); --cw_aoi21
ucp1_g32_23:   cp1_g32_23_b <= not( ex3_g16(2) or ( ex3_t16(2) and ex3_g16(3) ) ); --cw_aoi21
ucp1_g32_45:   cp1_g32_45_b <= not( ex3_g16(4) or ( ex3_t16(4) and ex3_g16(5) ) ); --cw_aoi21
ucp1_g32_66:   cp1_g32_66_b <= not( ex3_g16(6)                                  ); --cw_invert --done

ucp1_t32_11:   cp1_t32_11_b <= not(                ex3_t16(1) ); --cw_invert --EXTRA
ucp1_t32_01:   cp1_t32_01_b <= not( ex3_t16(0) and ex3_t16(1) ); --cw_nand2
ucp1_t32_23:   cp1_t32_23_b <= not( ex3_t16(2) and ex3_t16(3) ); --cw_nand2
ucp1_t32_45:   cp1_t32_45_b <= not( ex3_t16(4) and ex3_t16(5) ); --cw_nand2
ucp1_t32_66:   cp1_t32_66_b <= not( ex3_t16(6)                ); --cw_invert

ucp1_g64_03:   cp1_g64_03   <= not( cp1_g32_01_b and (cp1_t32_01_b or  cp1_g32_23_b) ); --cw_oai21
ucp1_g64_13:   cp1_g64_13   <= not( cp1_g32_11_b and (cp1_t32_11_b or  cp1_g32_23_b) ); --cw_oai21 --EXTRA
ucp1_g64_46:   cp1_g64_46   <= not( cp1_g32_45_b and (cp1_t32_45_b or  cp1_g32_66_b) ); --cw_oai21

ucp1_t64_03:   cp1_t64_03   <= not(                   cp1_t32_01_b or  cp1_t32_23_b  ); --cw_nor2
ucp1_t64_13:   cp1_t64_13   <= not(                   cp1_t32_11_b or  cp1_t32_23_b  ); --cw_nor2 --EXTRA
ucp1_t64_46:   cp1_t64_46   <= not( cp1_g32_45_b and (cp1_t32_45_b or  cp1_t32_66_b) ); --cw_oai21

ucp1_g128_06:  cp1_g128_06_b <= not( cp1_g64_03 or ( cp1_t64_03 and cp1_g64_46 ) ); --cw_aoi21
ucp1_g128_16:  cp1_g128_16_b <= not( cp1_g64_13 or ( cp1_t64_13 and cp1_g64_46 ) ); --cw_aoi21 --EXTRA
ucp1_t128_16:  cp1_t128_16_b <= not( cp1_g64_13 or ( cp1_t64_13 and cp1_t64_46 ) ); --cw_aoi21 --EXTRA


ucp1_cog:  ex3_g128(1)   <= not( cp1_g128_16_b);--cw_invert --OUTPUT--
ucp1_cogx: cp1_g128_16   <= not( cp1_g128_16_b);--cw_invert
ucp1_cogb: ex3_g128_b(1) <= not( cp1_g128_16  );--cw_invert --OUTPUT--
ucp1_cot:  ex3_t128(1)   <= not( cp1_t128_16_b);--cw_invert --OUTPUT--
ucp1_cotx: cp1_t128_16   <= not( cp1_t128_16_b);--cw_invert
ucp1_cotb: ex3_t128_b(1) <= not( cp1_t128_16  );--cw_invert --OUTPUT--

ucp1_all1n:    cp1_all1_b <= not ex3_inc_all1     ;--cw_invert
ucp1_all1p:    cp1_all1_p <= not  cp1_all1_b      ;--cw_invert
ucp1_co_p0:    cp1_co_p0  <= not( cp1_g128_06_b ) ;--cw_invert

ucp1_espnx: cp1_sel_p0n_x_b <= not( cp1_all1_b    and ex3_effsub_npz);--cw_nand2
ucp1_espny: cp1_sel_p0n_y_b <= not( cp1_g128_06_b and ex3_effsub_npz);--cw_nand2
ucp1_selp0: cp1_sel_p0_b    <= not( cp1_co_p0     and cp1_all1_p and cp1_sub_sticky  );--cw_nand3
ucp1_selp1: cp1_sel_p1_b    <= not( cp1_co_p0     and cp1_all1_p and cp1_sub_stickyn );--cw_nand3

ucp1_espn:  ex3_eac_sel_p0n(0) <= not( cp1_sel_p0n_x_b and cp1_sel_p0n_y_b);--cw_nand2 --OUTPUT--
ucp1_esp0:  ex3_eac_sel_p0(0)  <= not( cp1_sel_p0_b    and cp1_add_frcp0_b);--cw_nand2 --OUTPUT--
ucp1_esp1:  ex3_eac_sel_p1(0)  <= not( cp1_sel_p1_b    and cp1_add_frcp1_b);--cw_nand2 --OUTPUT--

    cp1_sub_sticky  <=      ex3_effsub_npz and     f_alg_ex3_sticky      ;--NOT MAPPED
    cp1_sub_stickyn <=      ex3_effsub_npz and not f_alg_ex3_sticky      ;--NOT MAPPED
    cp1_add_frcp1_b <= not( ex3_effadd_npz and     f_alg_ex3_frc_sel_p1 );--NOT MAPPED
    cp1_add_frcp0_b <= not( ex3_effadd_npz and not f_alg_ex3_frc_sel_p1 );--NOT MAPPED


--=#########################################
--= BYT_1 MSB COPY
--=#########################################

ucp2_g32_01:   cp2_g32_01_b <= not( ex3_g16(0) or ( ex3_t16(0) and ex3_g16(1) ) ); --cw_aoi21
ucp2_g32_23:   cp2_g32_23_b <= not( ex3_g16(2) or ( ex3_t16(2) and ex3_g16(3) ) ); --cw_aoi21
ucp2_g32_45:   cp2_g32_45_b <= not( ex3_g16(4) or ( ex3_t16(4) and ex3_g16(5) ) ); --cw_aoi21
ucp2_g32_66:   cp2_g32_66_b <= not( ex3_g16(6)                                  ); --cw_invert --done

ucp2_t32_01:   cp2_t32_01_b <= not( ex3_t16(0) and ex3_t16(1) ); --cw_nand2
ucp2_t32_23:   cp2_t32_23_b <= not( ex3_t16(2) and ex3_t16(3) ); --cw_nand2
ucp2_t32_45:   cp2_t32_45_b <= not( ex3_t16(4) and ex3_t16(5) ); --cw_nand2
ucp2_t32_66:   cp2_t32_66_b <= not( ex3_t16(6)                ); --cw_invert

ucp2_g64_23:   cp2_g64_23   <= not(                                    cp2_g32_23_b  ); --cw_invert --EXTRA
ucp2_g64_03:   cp2_g64_03   <= not( cp2_g32_01_b and (cp2_t32_01_b or  cp2_g32_23_b) ); --cw_oai21
ucp2_g64_46:   cp2_g64_46   <= not( cp2_g32_45_b and (cp2_t32_45_b or  cp2_g32_66_b) ); --cw_oai21

ucp2_t64_23:   cp2_t64_23   <= not(                                    cp2_t32_23_b  ); --cw_invert --EXTRA
ucp2_t64_03:   cp2_t64_03   <= not(                   cp2_t32_01_b or  cp2_t32_23_b  ); --cw_nor2
ucp2_t64_46:   cp2_t64_46   <= not( cp2_g32_45_b and (cp2_t32_45_b or  cp2_t32_66_b) ); --cw_oai21

ucp2_g128_06:  cp2_g128_06_b <= not( cp2_g64_03 or ( cp2_t64_03 and cp2_g64_46 ) ); --cw_aoi21
ucp2_g128_26:  cp2_g128_26_b <= not( cp2_g64_23 or ( cp2_t64_23 and cp2_g64_46 ) ); --cw_aoi21 --EXTRA
ucp2_t128_26:  cp2_t128_26_b <= not( cp2_g64_23 or ( cp2_t64_23 and cp2_t64_46 ) ); --cw_aoi21 --EXTRA


ucp2_cog:  ex3_g128(2)   <= not( cp2_g128_26_b);--cw_invert --OUTPUT--
ucp2_cogx: cp2_g128_26   <= not( cp2_g128_26_b);--cw_invert
ucp2_cogb: ex3_g128_b(2) <= not( cp2_g128_26  );--cw_invert --OUTPUT--
ucp2_cot:  ex3_t128(2)   <= not( cp2_t128_26_b);--cw_invert --OUTPUT--
ucp2_cotx: cp2_t128_26   <= not( cp2_t128_26_b);--cw_invert
ucp2_cotb: ex3_t128_b(2) <= not( cp2_t128_26  );--cw_invert --OUTPUT--


ucp2_all1n:    cp2_all1_b <= not ex3_inc_all1     ;--cw_invert
ucp2_all1p:    cp2_all1_p <= not  cp2_all1_b      ;--cw_invert
ucp2_co_p0:    cp2_co_p0  <= not( cp2_g128_06_b ) ;--cw_invert

ucp2_espnx: cp2_sel_p0n_x_b <= not( cp2_all1_b    and ex3_effsub_npz);--cw_nand2
ucp2_espny: cp2_sel_p0n_y_b <= not( cp2_g128_06_b and ex3_effsub_npz);--cw_nand2
ucp2_selp0: cp2_sel_p0_b    <= not( cp2_co_p0     and cp2_all1_p and cp2_sub_sticky  );--cw_nand3
ucp2_selp1: cp2_sel_p1_b    <= not( cp2_co_p0     and cp2_all1_p and cp2_sub_stickyn );--cw_nand3

ucp2_espn:  ex3_eac_sel_p0n(1) <= not( cp2_sel_p0n_x_b and cp2_sel_p0n_y_b);--cw_nand2 --OUTPUT--
ucp2_esp0:  ex3_eac_sel_p0(1)  <= not( cp2_sel_p0_b    and cp2_add_frcp0_b);--cw_nand2 --OUTPUT--
ucp2_esp1:  ex3_eac_sel_p1(1)  <= not( cp2_sel_p1_b    and cp2_add_frcp1_b);--cw_nand2 --OUTPUT--

    cp2_sub_sticky  <=          ex3_effsub_npz and     f_alg_ex3_sticky      ;--NOT MAPPED
    cp2_sub_stickyn <=          ex3_effsub_npz and not f_alg_ex3_sticky      ;--NOT MAPPED
    cp2_add_frcp1_b <= not(     ex3_effadd_npz and     f_alg_ex3_frc_sel_p1 );--NOT MAPPED
    cp2_add_frcp0_b <= not(     ex3_effadd_npz and not f_alg_ex3_frc_sel_p1 );--NOT MAPPED


--=#########################################
--= BYT_2 MSB COPY
--=#########################################

ucp3_g32_00:   cp3_g32_00_b <= not( ex3_g16(0)                                  ) ; --cw_invert
ucp3_g32_12:   cp3_g32_12_b <= not( ex3_g16(1) or ( ex3_t16(1) and ex3_g16(2) ) ); --cw_aoi21
ucp3_g32_34:   cp3_g32_34_b <= not( ex3_g16(3) or ( ex3_t16(3) and ex3_g16(4) ) ); --cw_aoi21
ucp3_g32_56:   cp3_g32_56_b <= not( ex3_g16(5) or ( ex3_t16(5) and ex3_g16(6) ) ); --cw_aoi21

ucp3_t32_00:   cp3_t32_00_b <= not( ex3_t16(0)                ); --cw_invert
ucp3_t32_12:   cp3_t32_12_b <= not( ex3_t16(1) and ex3_t16(2) ); --cw_nand2
ucp3_t32_34:   cp3_t32_34_b <= not( ex3_t16(3) and ex3_t16(4) ); --cw_nand2
ucp3_t32_56:   cp3_t32_56_b <= not( ex3_g16(5) or ( ex3_t16(5) and ex3_t16(6) ) ); --cw_aoi21

ucp3_g64_02:   cp3_g64_02   <= not( cp3_g32_00_b and (cp3_t32_00_b or  cp3_g32_12_b) ); --cw_oai21
ucp3_g64_36:   cp3_g64_36   <= not( cp3_g32_34_b and (cp3_t32_34_b or  cp3_g32_56_b) ); --cw_oai21

ucp3_t64_02:   cp3_t64_02   <= not(                   cp3_t32_00_b or  cp3_t32_12_b  ); --cw_nor2
ucp3_t64_36:   cp3_t64_36   <= not( cp3_g32_34_b and (cp3_t32_34_b or  cp3_t32_56_b) ); --cw_oai21

ucp3_g128_06:  cp3_g128_06_b <= not( cp3_g64_02 or ( cp3_t64_02 and cp3_g64_36 ) ); --cw_aoi21
ucp3_g128_36:  cp3_g128_36_b <= not(                                cp3_g64_36   ); --cw_invert --EXTRA
ucp3_t128_36:  cp3_t128_36_b <= not(                                cp3_t64_36   ); --cw_invert --EXTRA


ucp3_cog:  ex3_g128(3)   <= not( cp3_g128_36_b);--cw_invert --OUTPUT--
ucp3_cogx: cp3_g128_36   <= not( cp3_g128_36_b);--cw_invert
ucp3_cogb: ex3_g128_b(3) <= not( cp3_g128_36  );--cw_invert --OUTPUT--
ucp3_cot:  ex3_t128(3)   <= not( cp3_t128_36_b);--cw_invert --OUTPUT--
ucp3_cotx: cp3_t128_36   <= not( cp3_t128_36_b);--cw_invert
ucp3_cotb: ex3_t128_b(3) <= not( cp3_t128_36  );--cw_invert --OUTPUT--


ucp3_all1n:    cp3_all1_b <= not ex3_inc_all1     ;--cw_invert
ucp3_all1p:    cp3_all1_p <= not  cp3_all1_b      ;--cw_invert
ucp3_co_p0:    cp3_co_p0  <= not( cp3_g128_06_b ) ;--cw_invert

ucp3_espnx: cp3_sel_p0n_x_b <= not( cp3_all1_b    and ex3_effsub_npz);--cw_nand2
ucp3_espny: cp3_sel_p0n_y_b <= not( cp3_g128_06_b and ex3_effsub_npz);--cw_nand2
ucp3_selp0: cp3_sel_p0_b    <= not( cp3_co_p0     and cp3_all1_p and cp3_sub_sticky  );--cw_nand3
ucp3_selp1: cp3_sel_p1_b    <= not( cp3_co_p0     and cp3_all1_p and cp3_sub_stickyn );--cw_nand3

ucp3_espn:  ex3_eac_sel_p0n(2) <= not( cp3_sel_p0n_x_b and cp3_sel_p0n_y_b);--cw_nand2 --OUTPUT--
ucp3_esp0:  ex3_eac_sel_p0(2)  <= not( cp3_sel_p0_b    and cp3_add_frcp0_b);--cw_nand2 --OUTPUT--
ucp3_esp1:  ex3_eac_sel_p1(2)  <= not( cp3_sel_p1_b    and cp3_add_frcp1_b);--cw_nand2 --OUTPUT--

    cp3_sub_sticky  <=          ex3_effsub_npz and     f_alg_ex3_sticky      ;--NOT MAPPED
    cp3_sub_stickyn <=          ex3_effsub_npz and not f_alg_ex3_sticky      ;--NOT MAPPED
    cp3_add_frcp1_b <= not(     ex3_effadd_npz and     f_alg_ex3_frc_sel_p1 );--NOT MAPPED
    cp3_add_frcp0_b <= not(     ex3_effadd_npz and not f_alg_ex3_frc_sel_p1 );--NOT MAPPED



--=#########################################
--= BYT_3 MSB COPY
--=#########################################

ucp4_g32_01:   cp4_g32_01_b <= not( ex3_g16(0) or ( ex3_t16(0) and ex3_g16(1) ) ); --cw_aoi21
ucp4_g32_23:   cp4_g32_23_b <= not( ex3_g16(2) or ( ex3_t16(2) and ex3_g16(3) ) ); --cw_aoi21
ucp4_g32_45:   cp4_g32_45_b <= not( ex3_g16(4) or ( ex3_t16(4) and ex3_g16(5) ) ); --cw_aoi21
ucp4_g32_66:   cp4_g32_66_b <= not( ex3_g16(6)                                  ); --cw_invert --done

ucp4_t32_01:   cp4_t32_01_b <= not( ex3_t16(0) and ex3_t16(1) ); --cw_nand2
ucp4_t32_23:   cp4_t32_23_b <= not( ex3_t16(2) and ex3_t16(3) ); --cw_nand2
ucp4_t32_45:   cp4_t32_45_b <= not( ex3_t16(4) and ex3_t16(5) ); --cw_nand2
ucp4_t32_66:   cp4_t32_66_b <= not( ex3_t16(6)                ); --cw_invert

ucp4_g64_03:   cp4_g64_03   <= not( cp4_g32_01_b and (cp4_t32_01_b or  cp4_g32_23_b) ); --cw_oai21
ucp4_g64_46:   cp4_g64_46   <= not( cp4_g32_45_b and (cp4_t32_45_b or  cp4_g32_66_b) ); --cw_oai21

ucp4_t64_03:   cp4_t64_03   <= not(                   cp4_t32_01_b or  cp4_t32_23_b  ); --cw_nor2
ucp4_t64_46:   cp4_t64_46   <= not( cp4_g32_45_b and (cp4_t32_45_b or  cp4_t32_66_b) ); --cw_oai21

ucp4_g128_06:  cp4_g128_06_b <= not( cp4_g64_03 or ( cp4_t64_03 and cp4_g64_46 ) ); --cw_aoi21
ucp4_g128_46:  cp4_g128_46_b <= not(                                cp4_g64_46   ); --cw_invert --EXTRA
ucp4_t128_46:  cp4_t128_46_b <= not(                                cp4_t64_46   ); --cw_invert --EXTRA

ucp4_cog:  ex3_g128(4)   <= not( cp4_g128_46_b);--cw_invert --OUTPUT--
ucp4_cogx: cp4_g128_46   <= not( cp4_g128_46_b);--cw_invert
ucp4_cogb: ex3_g128_b(4) <= not( cp4_g128_46  );--cw_invert --OUTPUT--
ucp4_cot:  ex3_t128(4)   <= not( cp4_t128_46_b);--cw_invert --OUTPUT--
ucp4_cotx: cp4_t128_46   <= not( cp4_t128_46_b);--cw_invert
ucp4_cotb: ex3_t128_b(4) <= not( cp4_t128_46  );--cw_invert --OUTPUT--

ucp4_all1n:    cp4_all1_b <= not ex3_inc_all1     ;--cw_invert
ucp4_all1p:    cp4_all1_p <= not  cp4_all1_b      ;--cw_invert
ucp4_co_p0:    cp4_co_p0  <= not( cp4_g128_06_b ) ;--cw_invert

ucp4_espnx: cp4_sel_p0n_x_b <= not( cp4_all1_b    and ex3_effsub_npz);--cw_nand2
ucp4_espny: cp4_sel_p0n_y_b <= not( cp4_g128_06_b and ex3_effsub_npz);--cw_nand2
ucp4_selp0: cp4_sel_p0_b    <= not( cp4_co_p0     and cp4_all1_p and cp4_sub_sticky  );--cw_nand3
ucp4_selp1: cp4_sel_p1_b    <= not( cp4_co_p0     and cp4_all1_p and cp4_sub_stickyn );--cw_nand3

ucp4_espn:  ex3_eac_sel_p0n(3) <= not( cp4_sel_p0n_x_b and cp4_sel_p0n_y_b);--cw_nand2 --OUTPUT--
ucp4_esp0:  ex3_eac_sel_p0(3)  <= not( cp4_sel_p0_b    and cp4_add_frcp0_b);--cw_nand2 --OUTPUT--
ucp4_esp1:  ex3_eac_sel_p1(3)  <= not( cp4_sel_p1_b    and cp4_add_frcp1_b);--cw_nand2 --OUTPUT--

    cp4_sub_sticky  <=          ex3_effsub_npz and     f_alg_ex3_sticky      ;--NOT MAPPED
    cp4_sub_stickyn <=          ex3_effsub_npz and not f_alg_ex3_sticky      ;--NOT MAPPED
    cp4_add_frcp1_b <= not(     ex3_effadd_npz and     f_alg_ex3_frc_sel_p1 );--NOT MAPPED
    cp4_add_frcp0_b <= not(     ex3_effadd_npz and not f_alg_ex3_frc_sel_p1 );--NOT MAPPED


--=#########################################
--= BYT_4
--=#########################################

ucp5_g32_00:   cp5_g32_00_b <= not( ex3_g16(0)                                  ); --cw_invert
ucp5_g32_12:   cp5_g32_12_b <= not( ex3_g16(1) or ( ex3_t16(1) and ex3_g16(2) ) ); --cw_aoi21
ucp5_g32_34:   cp5_g32_34_b <= not( ex3_g16(3) or ( ex3_t16(3) and ex3_g16(4) ) ); --cw_aoi21
ucp5_g32_56:   cp5_g32_56_b <= not( ex3_g16(5) or ( ex3_t16(5) and ex3_g16(6) ) ); --cw_aoi21

ucp5_t32_00:   cp5_t32_00_b <= not( ex3_t16(0)                ); --cw_invert
ucp5_t32_12:   cp5_t32_12_b <= not( ex3_t16(1) and ex3_t16(2) ); --cw_nand2
ucp5_t32_34:   cp5_t32_34_b <= not( ex3_t16(3) and ex3_t16(4) ); --cw_nand2
ucp5_t32_56:   cp5_t32_56_b <= not( ex3_g16(5) or ( ex3_t16(5) and ex3_t16(6) ) ); --cw_aoi21


ucp5_g64_02:   cp5_g64_02   <= not( cp5_g32_00_b and (cp5_t32_00_b or  cp5_g32_12_b) ); --cw_oai21
ucp5_g64_36:   cp5_g64_36   <= not( cp5_g32_34_b and (cp5_t32_34_b or  cp5_g32_56_b) ); --cw_oai21
ucp5_g64_56:   cp5_g64_56   <= not(                                    cp5_g32_56_b  ); --cw_invert --EXTRA

ucp5_t64_02:   cp5_t64_02   <= not(                   cp5_t32_00_b or  cp5_t32_12_b  ); --cw_nor2
ucp5_t64_56:   cp5_t64_56   <= not(                                    cp5_t32_56_b  ); --cw_invert --EXTRA

ucp5_g128_06:  cp5_g128_06_b <= not( cp5_g64_02 or ( cp5_t64_02 and cp5_g64_36 ) ); --cw_aoi21
ucp5_g128_56:  cp5_g128_56_b <= not(                                cp5_g64_56   ); --cw_invert --EXTRA
ucp5_t128_56:  cp5_t128_56_b <= not(                                cp5_t64_56   ); --cw_invert --EXTRA


ucp5_cog:  ex3_g128(5)   <= not( cp5_g128_56_b);--cw_invert --OUTPUT--
ucp5_cogx: cp5_g128_56   <= not( cp5_g128_56_b);--cw_invert
ucp5_cogb: ex3_g128_b(5) <= not( cp5_g128_56  );--cw_invert --OUTPUT--
ucp5_cot:  ex3_t128(5)   <= not( cp5_t128_56_b);--cw_invert --OUTPUT--
ucp5_cotx: cp5_t128_56   <= not( cp5_t128_56_b);--cw_invert
ucp5_cotb: ex3_t128_b(5) <= not( cp5_t128_56  );--cw_invert --OUTPUT--

ucp5_all1n:    cp5_all1_b <= not ex3_inc_all1     ;--cw_invert
ucp5_all1p:    cp5_all1_p <= not  cp5_all1_b      ;--cw_invert
ucp5_co_p0:    cp5_co_p0  <= not( cp5_g128_06_b ) ;--cw_invert

ucp5_espnx: cp5_sel_p0n_x_b <= not( cp5_all1_b    and ex3_effsub_npz);--cw_nand2
ucp5_espny: cp5_sel_p0n_y_b <= not( cp5_g128_06_b and ex3_effsub_npz);--cw_nand2
ucp5_selp0: cp5_sel_p0_b    <= not( cp5_co_p0     and cp5_all1_p and cp5_sub_sticky  );--cw_nand3
ucp5_selp1: cp5_sel_p1_b    <= not( cp5_co_p0     and cp5_all1_p and cp5_sub_stickyn );--cw_nand3

ucp5_espn:  ex3_eac_sel_p0n(4) <= not( cp5_sel_p0n_x_b and cp5_sel_p0n_y_b);--cw_nand2 --OUTPUT--
ucp5_esp0:  ex3_eac_sel_p0(4)  <= not( cp5_sel_p0_b    and cp5_add_frcp0_b);--cw_nand2 --OUTPUT--
ucp5_esp1:  ex3_eac_sel_p1(4)  <= not( cp5_sel_p1_b    and cp5_add_frcp1_b);--cw_nand2 --OUTPUT--

    cp5_sub_sticky  <=          ex3_effsub_npz and     f_alg_ex3_sticky      ;--NOT MAPPED
    cp5_sub_stickyn <=          ex3_effsub_npz and not f_alg_ex3_sticky      ;--NOT MAPPED
    cp5_add_frcp1_b <= not(     ex3_effadd_npz and     f_alg_ex3_frc_sel_p1 );--NOT MAPPED
    cp5_add_frcp0_b <= not(     ex3_effadd_npz and not f_alg_ex3_frc_sel_p1 );--NOT MAPPED


--=#########################################
--= BYT_5
--=#########################################

ucp6_g32_00:   cp6_g32_00_b <= not( ex3_g16(0)                                  ); --cw_invert
ucp6_g32_12:   cp6_g32_12_b <= not( ex3_g16(1) or ( ex3_t16(1) and ex3_g16(2) ) ); --cw_aoi21
ucp6_g32_34:   cp6_g32_34_b <= not( ex3_g16(3) or ( ex3_t16(3) and ex3_g16(4) ) ); --cw_aoi21
ucp6_g32_56:   cp6_g32_56_b <= not( ex3_g16(5) or ( ex3_t16(5) and ex3_g16(6) ) ); --cw_aoi21
ucp6_g32_66:   cp6_g32_66_b <= not( ex3_g16(6)                                  ); --cw_invert EXTRA

ucp6_t32_00:   cp6_t32_00_b <= not( ex3_t16(0)                ); --cw_invert
ucp6_t32_12:   cp6_t32_12_b <= not( ex3_t16(1) and ex3_t16(2) ); --cw_nand2
ucp6_t32_34:   cp6_t32_34_b <= not( ex3_t16(3) and ex3_t16(4) ); --cw_nand2
ucp6_t32_66:   cp6_t32_66_b <= not( ex3_t16(6)                                  ); --cw_invert EXTRA

ucp6_g64_02:   cp6_g64_02   <= not( cp6_g32_00_b and (cp6_t32_00_b or  cp6_g32_12_b) ); --cw_oai21
ucp6_g64_36:   cp6_g64_36   <= not( cp6_g32_34_b and (cp6_t32_34_b or  cp6_g32_56_b) ); --cw_oai21

ucp6_t64_02:   cp6_t64_02   <= not(                   cp6_t32_00_b or  cp6_t32_12_b  ); --cw_nor2

ucp6_g128_06:  cp6_g128_06_b <= not( cp6_g64_02 or ( cp6_t64_02 and cp6_g64_36 ) ); --cw_aoi21


ucp6_cog:  ex3_g128(6)   <= not( cp6_g32_66_b );--cw_invert --OUTPUT--
ucp6_cogx: cp6_g128_66   <= not( cp6_g32_66_b );--cw_invert
ucp6_cogb: ex3_g128_b(6) <= not( cp6_g128_66  );--cw_invert --OUTPUT--
ucp6_cot:  ex3_t128(6)   <= not( cp6_t32_66_b );--cw_invert --OUTPUT--
ucp6_cotx: cp6_t128_66   <= not( cp6_t32_66_b );--cw_invert
ucp6_cotb: ex3_t128_b(6) <= not( cp6_t128_66  );--cw_invert --OUTPUT--


ucp6_all1n:    cp6_all1_b <= not ex3_inc_all1     ;--cw_invert
ucp6_all1p:    cp6_all1_p <= not  cp6_all1_b      ;--cw_invert
ucp6_co_p0:    cp6_co_p0  <= not( cp6_g128_06_b ) ;--cw_invert

ucp6_espnx: cp6_sel_p0n_x_b <= not( cp6_all1_b    and ex3_effsub_npz);--cw_nand2
ucp6_espny: cp6_sel_p0n_y_b <= not( cp6_g128_06_b and ex3_effsub_npz);--cw_nand2
ucp6_selp0: cp6_sel_p0_b    <= not( cp6_co_p0     and cp6_all1_p and cp6_sub_sticky  );--cw_nand3
ucp6_selp1: cp6_sel_p1_b    <= not( cp6_co_p0     and cp6_all1_p and cp6_sub_stickyn );--cw_nand3

ucp6_espn:  ex3_eac_sel_p0n(5) <= not( cp6_sel_p0n_x_b and cp6_sel_p0n_y_b);--cw_nand2 --OUTPUT--
ucp6_esp0:  ex3_eac_sel_p0(5)  <= not( cp6_sel_p0_b    and cp6_add_frcp0_b);--cw_nand2 --OUTPUT--
ucp6_esp1:  ex3_eac_sel_p1(5)  <= not( cp6_sel_p1_b    and cp6_add_frcp1_b);--cw_nand2 --OUTPUT--

    cp6_sub_sticky  <=          ex3_effsub_npz and     f_alg_ex3_sticky      ;--NOT MAPPED
    cp6_sub_stickyn <=          ex3_effsub_npz and not f_alg_ex3_sticky      ;--NOT MAPPED
    cp6_add_frcp1_b <= not(     ex3_effadd_npz and     f_alg_ex3_frc_sel_p1 );--NOT MAPPED
    cp6_add_frcp0_b <= not(     ex3_effadd_npz and not f_alg_ex3_frc_sel_p1 );--NOT MAPPED


--=#########################################
--= BYT_6 LSB COPY
--=#########################################

ucp7_g32_00:   cp7_g32_00_b <= not( ex3_g16(0)                                  ) ; --cw_invert
ucp7_g32_12:   cp7_g32_12_b <= not( ex3_g16(1) or ( ex3_t16(1) and ex3_g16(2) ) ); --cw_aoi21
ucp7_g32_34:   cp7_g32_34_b <= not( ex3_g16(3) or ( ex3_t16(3) and ex3_g16(4) ) ); --cw_aoi21
ucp7_g32_56:   cp7_g32_56_b <= not( ex3_g16(5) or ( ex3_t16(5) and ex3_g16(6) ) ); --cw_aoi21

ucp7_t32_00:   cp7_t32_00_b <= not( ex3_t16(0)                ); --cw_invert
ucp7_t32_12:   cp7_t32_12_b <= not( ex3_t16(1) and ex3_t16(2) ); --cw_nand2
ucp7_t32_34:   cp7_t32_34_b <= not( ex3_t16(3) and ex3_t16(4) ); --cw_nand2


ucp7_g64_02:   cp7_g64_02   <= not( cp7_g32_00_b and (cp7_t32_00_b or  cp7_g32_12_b) ); --cw_oai21
ucp7_g64_36:   cp7_g64_36   <= not( cp7_g32_34_b and (cp7_t32_34_b or  cp7_g32_56_b) ); --cw_oai21

ucp7_t64_02:   cp7_t64_02   <= not(                   cp7_t32_00_b or  cp7_t32_12_b  ); --cw_nor2

ucp7_g128_06:  cp7_g128_06_b <= not( cp7_g64_02 or ( cp7_t64_02 and cp7_g64_36 ) ); --cw_aoi21

ucp7_all1n:    cp7_all1_b <= not ex3_inc_all1     ;--cw_invert
ucp7_all1p:    cp7_all1_p <= not  cp7_all1_b      ;--cw_invert
ucp7_co_p0:    cp7_co_p0  <= not( cp7_g128_06_b ) ;--cw_invert

ucp7_espnx: cp7_sel_p0n_x_b <= not( cp7_all1_b    and ex3_effsub_npz);--cw_nand2
ucp7_espny: cp7_sel_p0n_y_b <= not( cp7_g128_06_b and ex3_effsub_npz);--cw_nand2
ucp7_selp0: cp7_sel_p0_b    <= not( cp7_co_p0     and cp7_all1_p and cp7_sub_sticky  );--cw_nand3
ucp7_selp1: cp7_sel_p1_b    <= not( cp7_co_p0     and cp7_all1_p and cp7_sub_stickyn );--cw_nand3

ucp7_espn:  ex3_eac_sel_p0n(6) <= not( cp7_sel_p0n_x_b and cp7_sel_p0n_y_b);--cw_nand2 --OUTPUT--
ucp7_esp0:  ex3_eac_sel_p0(6)  <= not( cp7_sel_p0_b    and cp7_add_frcp0_b);--cw_nand2 --OUTPUT--
ucp7_esp1:  ex3_eac_sel_p1(6)  <= not( cp7_sel_p1_b    and cp7_add_frcp1_b);--cw_nand2 --OUTPUT--

    cp7_sub_sticky  <=          ex3_effsub_npz and     f_alg_ex3_sticky      ;--NOT MAPPED
    cp7_sub_stickyn <=          ex3_effsub_npz and not f_alg_ex3_sticky      ;--NOT MAPPED
    cp7_add_frcp1_b <= not(     ex3_effadd_npz and     f_alg_ex3_frc_sel_p1 );--NOT MAPPED
    cp7_add_frcp0_b <= not(     ex3_effadd_npz and not f_alg_ex3_frc_sel_p1 );--NOT MAPPED

END; -- ARCH fuq_add_glbc
