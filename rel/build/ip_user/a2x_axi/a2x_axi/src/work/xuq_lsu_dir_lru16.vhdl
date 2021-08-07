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

library ibm, ieee, work, tri, support;
use ibm.std_ulogic_support.all;
use ibm.std_ulogic_function_support.all;
use ibm.std_ulogic_unsigned.all;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use tri.tri_latches_pkg.all;
use support.power_logic_pkg.all;

entity xuq_lsu_dir_lru16  is
generic(expand_type     : integer := 2;                
        dc_size         : natural := 14;
        lmq_entries     : integer := 8;
        cl_size         : natural := 6);
port(

     ex1_stg_act                :in  std_ulogic;
     ex2_stg_act                :in  std_ulogic;
     ex3_stg_act                :in  std_ulogic;
     ex4_stg_act                :in  std_ulogic;
     ex5_stg_act                :in  std_ulogic;
     rel1_stg_act               :in  std_ulogic;
     rel2_stg_act               :in  std_ulogic;
     rel3_stg_act               :in  std_ulogic;

     rel1_val                   :in  std_ulogic;                        
     rel1_classid               :in  std_ulogic_vector(0 to 1);         
     rel_mid_val                :in  std_ulogic;                        
     rel_retry_val              :in  std_ulogic;                        
     rel3_val                   :in  std_ulogic;                        
     rel4_recirc_val            :in  std_ulogic;                        
     rel4_ecc_err               :in  std_ulogic;                        
     rel_st_tag_early           :in  std_ulogic_vector(1 to 3);         
     rel_st_tag                 :in  std_ulogic_vector(1 to 3);         
     rel_addr_early             :in  std_ulogic_vector(64-(dc_size-3) to 63-cl_size);       
     rel_lock_en                :in  std_ulogic;                        

     rel_way_val_a              :in  std_ulogic;                        
     rel_way_val_b              :in  std_ulogic;                        
     rel_way_val_c              :in  std_ulogic;                        
     rel_way_val_d              :in  std_ulogic;                        
     rel_way_val_e              :in  std_ulogic;                        
     rel_way_val_f              :in  std_ulogic;                        
     rel_way_val_g              :in  std_ulogic;                        
     rel_way_val_h              :in  std_ulogic;                        

     rel_way_lock_a             :in  std_ulogic;                        
     rel_way_lock_b             :in  std_ulogic;                        
     rel_way_lock_c             :in  std_ulogic;                        
     rel_way_lock_d             :in  std_ulogic;                        
     rel_way_lock_e             :in  std_ulogic;                        
     rel_way_lock_f             :in  std_ulogic;                        
     rel_way_lock_g             :in  std_ulogic;                        
     rel_way_lock_h             :in  std_ulogic;                        

     ex1_p_addr                 :in  std_ulogic_vector(64-(dc_size-3) to 63-cl_size);       
     ex3_cache_en               :in  std_ulogic;                        
     ex2_no_lru_upd             :in  std_ulogic;                        

     ex4_way_a_hit              :in  std_ulogic;                        
     ex4_way_b_hit              :in  std_ulogic;                        
     ex4_way_c_hit              :in  std_ulogic;                        
     ex4_way_d_hit              :in  std_ulogic;                        
     ex4_way_e_hit              :in  std_ulogic;                        
     ex4_way_f_hit              :in  std_ulogic;                        
     ex4_way_g_hit              :in  std_ulogic;                        
     ex4_way_h_hit              :in  std_ulogic;                        
     ex3_hit                    :in  std_ulogic;                        

     spr_xucr2_rmt              :in  std_ulogic_vector(0 to 31);        
     spr_xucr0_wlck             :in  std_ulogic;                        
     spr_xucr0_dcdis            :in  std_ulogic;                        
     spr_xucr0_cls              :in  std_ulogic;                        
 
     ex3_stg_flush              :in  std_ulogic;                        
     ex4_stg_flush              :in  std_ulogic;                        
     ex5_stg_flush              :in  std_ulogic;                        

     rel_way_upd_a              :out std_ulogic;                        
     rel_way_upd_b              :out std_ulogic;                        
     rel_way_upd_c              :out std_ulogic;                        
     rel_way_upd_d              :out std_ulogic;                        
     rel_way_upd_e              :out std_ulogic;                        
     rel_way_upd_f              :out std_ulogic;                        
     rel_way_upd_g              :out std_ulogic;                        
     rel_way_upd_h              :out std_ulogic;                        

     rel_way_wen_a              :out std_ulogic;                        
     rel_way_wen_b              :out std_ulogic;                        
     rel_way_wen_c              :out std_ulogic;                        
     rel_way_wen_d              :out std_ulogic;                        
     rel_way_wen_e              :out std_ulogic;                        
     rel_way_wen_f              :out std_ulogic;                        
     rel_way_wen_g              :out std_ulogic;                        
     rel_way_wen_h              :out std_ulogic;                        

     rel_way_clr_a              :out std_ulogic;                        
     rel_way_clr_b              :out std_ulogic;                        
     rel_way_clr_c              :out std_ulogic;                        
     rel_way_clr_d              :out std_ulogic;                        
     rel_way_clr_e              :out std_ulogic;                        
     rel_way_clr_f              :out std_ulogic;                        
     rel_way_clr_g              :out std_ulogic;                        
     rel_way_clr_h              :out std_ulogic;                        
     rel_dcarr_val_upd          :out std_ulogic;                        
     rel_up_way_addr_b          :out std_ulogic_vector(0 to 2);         
     rel_dcarr_addr_en          :out std_ulogic;                        

     lsu_xu_spr_xucr0_clo       :out std_ulogic;                        

     ex4_dir_lru                :out std_ulogic_vector(0 to 6);

     dc_lru_dbg_data            :out std_ulogic_vector(0 to 81);

     vdd                        :inout power_logic;
     gnd                        :inout power_logic;
     nclk                       :in  clk_logic;
     sg_0                       :in  std_ulogic;
     func_sl_thold_0_b          :in  std_ulogic;
     func_sl_force              :in  std_ulogic;
     func_nsl_thold_0_b         :in  std_ulogic;
     func_nsl_force             :in  std_ulogic;
     d_mode_dc                  :in  std_ulogic;
     delay_lclkr_dc             :in  std_ulogic;
     mpw1_dc_b                  :in  std_ulogic;
     mpw2_dc_b                  :in  std_ulogic;
     scan_in                    :in  std_ulogic;
     scan_out                   :out std_ulogic     
   );
-- synopsys translate_off
-- synopsys translate_on
end xuq_lsu_dir_lru16;
ARCHITECTURE XUQ_LSU_DIR_LRU16
          OF XUQ_LSU_DIR_LRU16
          IS
constant congr_cl0_lru_offset           :natural := 0;
constant congr_cl1_lru_offset           :natural := congr_cl0_lru_offset   + 7;
constant congr_cl2_lru_offset           :natural := congr_cl1_lru_offset   + 7;
constant congr_cl3_lru_offset           :natural := congr_cl2_lru_offset   + 7;
constant congr_cl4_lru_offset           :natural := congr_cl3_lru_offset   + 7;
constant congr_cl5_lru_offset           :natural := congr_cl4_lru_offset   + 7;
constant congr_cl6_lru_offset           :natural := congr_cl5_lru_offset   + 7;
constant congr_cl7_lru_offset           :natural := congr_cl6_lru_offset   + 7;
constant congr_cl8_lru_offset           :natural := congr_cl7_lru_offset   + 7;
constant congr_cl9_lru_offset           :natural := congr_cl8_lru_offset   + 7;
constant congr_cl10_lru_offset          :natural := congr_cl9_lru_offset   + 7;
constant congr_cl11_lru_offset          :natural := congr_cl10_lru_offset  + 7;
constant congr_cl12_lru_offset          :natural := congr_cl11_lru_offset  + 7;
constant congr_cl13_lru_offset          :natural := congr_cl12_lru_offset  + 7;
constant congr_cl14_lru_offset          :natural := congr_cl13_lru_offset  + 7;
constant congr_cl15_lru_offset          :natural := congr_cl14_lru_offset  + 7;
constant congr_cl16_lru_offset          :natural := congr_cl15_lru_offset  + 7;
constant congr_cl17_lru_offset          :natural := congr_cl16_lru_offset  + 7;
constant congr_cl18_lru_offset          :natural := congr_cl17_lru_offset  + 7;
constant congr_cl19_lru_offset          :natural := congr_cl18_lru_offset  + 7;
constant congr_cl20_lru_offset          :natural := congr_cl19_lru_offset  + 7;
constant congr_cl21_lru_offset          :natural := congr_cl20_lru_offset  + 7;
constant congr_cl22_lru_offset          :natural := congr_cl21_lru_offset  + 7;
constant congr_cl23_lru_offset          :natural := congr_cl22_lru_offset  + 7;
constant congr_cl24_lru_offset          :natural := congr_cl23_lru_offset  + 7;
constant congr_cl25_lru_offset          :natural := congr_cl24_lru_offset  + 7;
constant congr_cl26_lru_offset          :natural := congr_cl25_lru_offset  + 7;
constant congr_cl27_lru_offset          :natural := congr_cl26_lru_offset  + 7;
constant congr_cl28_lru_offset          :natural := congr_cl27_lru_offset  + 7;
constant congr_cl29_lru_offset          :natural := congr_cl28_lru_offset  + 7;
constant congr_cl30_lru_offset          :natural := congr_cl29_lru_offset  + 7;
constant congr_cl31_lru_offset          :natural := congr_cl30_lru_offset  + 7;
constant congr_cl_lru_b_offset          :natural := congr_cl31_lru_offset + 7;
constant rel_congr_cl_lru_b_offset      :natural := congr_cl_lru_b_offset + 7;
constant reld_q_sel_offset              :natural := rel_congr_cl_lru_b_offset + 7;
constant ex5_congr_cl_offset            :natural := reld_q_sel_offset + 8;
constant rel_congr_cl_offset            :natural := ex5_congr_cl_offset + 5;
constant relu_congr_cl_offset           :natural := rel_congr_cl_offset + 5;
constant ex5_lru_upd_offset             :natural := relu_congr_cl_offset + 5;
constant rel2_val_offset                :natural := ex5_lru_upd_offset + 7;
constant relu_val_wen_offset            :natural := rel2_val_offset + 1;
constant ex4_hit_offset                 :natural := relu_val_wen_offset + 1;
constant ex4_c_acc_offset               :natural := ex4_hit_offset + 1;
constant ex5_c_acc_offset               :natural := ex4_c_acc_offset + 1;
constant ex6_c_acc_val_offset           :natural := ex5_c_acc_offset + 1;
constant ex3_congr_cl_offset            :natural := ex6_c_acc_val_offset + 1;
constant rel_val_wen_offset             :natural := ex3_congr_cl_offset + 5;
constant relu_lru_upd_offset            :natural := rel_val_wen_offset + 1;
constant rel_way_qsel_offset            :natural := relu_lru_upd_offset + 7;
constant rel_val_qsel_offset            :natural := rel_way_qsel_offset + 8;
constant rel_way_early_qsel_offset      :natural := rel_val_qsel_offset + 1;
constant rel_val_early_qsel_offset      :natural := rel_way_early_qsel_offset + 8;
constant rel4_val_offset                :natural := rel_val_early_qsel_offset + 1;
constant rel2_mid_val_offset            :natural := rel4_val_offset + 1;
constant rel4_retry_val_offset          :natural := rel2_mid_val_offset + 1;
constant rel2_wlock_offset              :natural := rel4_retry_val_offset + 1;
constant reld_q0_congr_cl_offset        :natural := rel2_wlock_offset + 8;
constant reld_q1_congr_cl_offset        :natural := reld_q0_congr_cl_offset   + 5;
constant reld_q2_congr_cl_offset        :natural := reld_q1_congr_cl_offset   + 5;
constant reld_q3_congr_cl_offset        :natural := reld_q2_congr_cl_offset   + 5;
constant reld_q4_congr_cl_offset        :natural := reld_q3_congr_cl_offset   + 5;
constant reld_q5_congr_cl_offset        :natural := reld_q4_congr_cl_offset   + 5;
constant reld_q6_congr_cl_offset        :natural := reld_q5_congr_cl_offset   + 5;
constant reld_q7_congr_cl_offset        :natural := reld_q6_congr_cl_offset   + 5;
constant reld_q0_way_offset             :natural := reld_q7_congr_cl_offset + 5;
constant reld_q1_way_offset             :natural := reld_q0_way_offset   + 8;
constant reld_q2_way_offset             :natural := reld_q1_way_offset   + 8;
constant reld_q3_way_offset             :natural := reld_q2_way_offset   + 8;
constant reld_q4_way_offset             :natural := reld_q3_way_offset   + 8;
constant reld_q5_way_offset             :natural := reld_q4_way_offset   + 8;
constant reld_q6_way_offset             :natural := reld_q5_way_offset   + 8;
constant reld_q7_way_offset             :natural := reld_q6_way_offset   + 8;
constant reld_q0_val_offset             :natural := reld_q7_way_offset + 8;
constant reld_q1_val_offset             :natural := reld_q0_val_offset   + 1;
constant reld_q2_val_offset             :natural := reld_q1_val_offset   + 1;
constant reld_q3_val_offset             :natural := reld_q2_val_offset   + 1;
constant reld_q4_val_offset             :natural := reld_q3_val_offset   + 1;
constant reld_q5_val_offset             :natural := reld_q4_val_offset   + 1;
constant reld_q6_val_offset             :natural := reld_q5_val_offset   + 1;
constant reld_q7_val_offset             :natural := reld_q6_val_offset   + 1;
constant reld_q0_lock_offset            :natural := reld_q7_val_offset + 1;
constant reld_q1_lock_offset            :natural := reld_q0_lock_offset   + 1;
constant reld_q2_lock_offset            :natural := reld_q1_lock_offset   + 1;
constant reld_q3_lock_offset            :natural := reld_q2_lock_offset   + 1;
constant reld_q4_lock_offset            :natural := reld_q3_lock_offset   + 1;
constant reld_q5_lock_offset            :natural := reld_q4_lock_offset   + 1;
constant reld_q6_lock_offset            :natural := reld_q5_lock_offset   + 1;
constant reld_q7_lock_offset            :natural := reld_q6_lock_offset   + 1;
constant rel_m_q_way_offset             :natural := reld_q7_lock_offset + 1;
constant ex3_no_lru_upd_offset          :natural := rel_m_q_way_offset + 8;
constant rel2_lock_en_offset            :natural := ex3_no_lru_upd_offset + 1;
constant xucr0_clo_offset               :natural := rel2_lock_en_offset + 1;
constant rel_up_way_addr_offset         :natural := xucr0_clo_offset + 1;
constant rel_dcarr_addr_en_offset       :natural := rel_up_way_addr_offset + 3;
constant rel_dcarr_val_upd_offset       :natural := rel_dcarr_addr_en_offset + 1;
constant congr_cl_ex3_ex4_cmp_offset    :natural := rel_dcarr_val_upd_offset + 1;
constant congr_cl_ex3_ex5_cmp_offset    :natural := congr_cl_ex3_ex4_cmp_offset + 1;
constant congr_cl_ex3_ex6_cmp_offset    :natural := congr_cl_ex3_ex5_cmp_offset + 1;
constant congr_cl_ex3_rel2_cmp_offset   :natural := congr_cl_ex3_ex6_cmp_offset + 1;
constant congr_cl_ex3_rel_upd_cmp_offset :natural := congr_cl_ex3_rel2_cmp_offset + 1;
constant congr_cl_rel1_ex4_cmp_offset   :natural := congr_cl_ex3_rel_upd_cmp_offset + 1;
constant congr_cl_rel1_ex5_cmp_offset   :natural := congr_cl_rel1_ex4_cmp_offset + 1;
constant congr_cl_rel1_ex6_cmp_offset   :natural := congr_cl_rel1_ex5_cmp_offset + 1;
constant congr_cl_rel1_rel2_cmp_offset  :natural := congr_cl_rel1_ex6_cmp_offset + 1;
constant congr_cl_rel1_relu_cmp_offset  :natural := congr_cl_rel1_rel2_cmp_offset + 1;
constant congr_cl_rel1_rel_upd_cmp_offset :natural := congr_cl_rel1_relu_cmp_offset + 1;
constant congr_cl_act_offset            :natural := congr_cl_rel1_rel_upd_cmp_offset + 1;
constant scan_right                     :natural := congr_cl_act_offset + 1 - 1;
signal congr_cl0_lru_d          :std_ulogic_vector(0 to 6);
signal congr_cl0_lru_q          :std_ulogic_vector(0 to 6);
signal congr_cl0_lru_wen        :std_ulogic;
signal xu_op_cl0_lru_wen        :std_ulogic;
signal rel_cl0_lru_wen          :std_ulogic;
signal rel_ldst_cl0_lru         :std_ulogic_vector(0 to 6);
signal congr_cl1_lru_d          :std_ulogic_vector(0 to 6);
signal congr_cl1_lru_q          :std_ulogic_vector(0 to 6);
signal congr_cl1_lru_wen        :std_ulogic;
signal xu_op_cl1_lru_wen        :std_ulogic;
signal rel_cl1_lru_wen          :std_ulogic;
signal rel_ldst_cl1_lru         :std_ulogic_vector(0 to 6);
signal congr_cl2_lru_d          :std_ulogic_vector(0 to 6);
signal congr_cl2_lru_q          :std_ulogic_vector(0 to 6);
signal congr_cl2_lru_wen        :std_ulogic;
signal xu_op_cl2_lru_wen        :std_ulogic;
signal rel_cl2_lru_wen          :std_ulogic;
signal rel_ldst_cl2_lru         :std_ulogic_vector(0 to 6);
signal congr_cl3_lru_d          :std_ulogic_vector(0 to 6);
signal congr_cl3_lru_q          :std_ulogic_vector(0 to 6);
signal congr_cl3_lru_wen        :std_ulogic;
signal xu_op_cl3_lru_wen        :std_ulogic;
signal rel_cl3_lru_wen          :std_ulogic;
signal rel_ldst_cl3_lru         :std_ulogic_vector(0 to 6);
signal congr_cl4_lru_d          :std_ulogic_vector(0 to 6);
signal congr_cl4_lru_q          :std_ulogic_vector(0 to 6);
signal congr_cl4_lru_wen        :std_ulogic;
signal xu_op_cl4_lru_wen        :std_ulogic;
signal rel_cl4_lru_wen          :std_ulogic;
signal rel_ldst_cl4_lru         :std_ulogic_vector(0 to 6);
signal congr_cl5_lru_d          :std_ulogic_vector(0 to 6);
signal congr_cl5_lru_q          :std_ulogic_vector(0 to 6);
signal congr_cl5_lru_wen        :std_ulogic;
signal xu_op_cl5_lru_wen        :std_ulogic;
signal rel_cl5_lru_wen          :std_ulogic;
signal rel_ldst_cl5_lru         :std_ulogic_vector(0 to 6);
signal congr_cl6_lru_d          :std_ulogic_vector(0 to 6);
signal congr_cl6_lru_q          :std_ulogic_vector(0 to 6);
signal congr_cl6_lru_wen        :std_ulogic;
signal xu_op_cl6_lru_wen        :std_ulogic;
signal rel_cl6_lru_wen          :std_ulogic;
signal rel_ldst_cl6_lru         :std_ulogic_vector(0 to 6);
signal congr_cl7_lru_d          :std_ulogic_vector(0 to 6);
signal congr_cl7_lru_q          :std_ulogic_vector(0 to 6);
signal congr_cl7_lru_wen        :std_ulogic;
signal xu_op_cl7_lru_wen        :std_ulogic;
signal rel_cl7_lru_wen          :std_ulogic;
signal rel_ldst_cl7_lru         :std_ulogic_vector(0 to 6);
signal congr_cl8_lru_d          :std_ulogic_vector(0 to 6);
signal congr_cl8_lru_q          :std_ulogic_vector(0 to 6);
signal congr_cl8_lru_wen        :std_ulogic;
signal xu_op_cl8_lru_wen        :std_ulogic;
signal rel_cl8_lru_wen          :std_ulogic;
signal rel_ldst_cl8_lru         :std_ulogic_vector(0 to 6);
signal congr_cl9_lru_d          :std_ulogic_vector(0 to 6);
signal congr_cl9_lru_q          :std_ulogic_vector(0 to 6);
signal congr_cl9_lru_wen        :std_ulogic;
signal xu_op_cl9_lru_wen        :std_ulogic;
signal rel_cl9_lru_wen          :std_ulogic;
signal rel_ldst_cl9_lru         :std_ulogic_vector(0 to 6);
signal congr_cl10_lru_d         :std_ulogic_vector(0 to 6);
signal congr_cl10_lru_q         :std_ulogic_vector(0 to 6);
signal congr_cl10_lru_wen       :std_ulogic;
signal xu_op_cl10_lru_wen       :std_ulogic;
signal rel_cl10_lru_wen         :std_ulogic;
signal rel_ldst_cl10_lru        :std_ulogic_vector(0 to 6);
signal congr_cl11_lru_d         :std_ulogic_vector(0 to 6);
signal congr_cl11_lru_q         :std_ulogic_vector(0 to 6);
signal congr_cl11_lru_wen       :std_ulogic;
signal xu_op_cl11_lru_wen       :std_ulogic;
signal rel_cl11_lru_wen         :std_ulogic;
signal rel_ldst_cl11_lru        :std_ulogic_vector(0 to 6);
signal congr_cl12_lru_d         :std_ulogic_vector(0 to 6);
signal congr_cl12_lru_q         :std_ulogic_vector(0 to 6);
signal congr_cl12_lru_wen       :std_ulogic;
signal xu_op_cl12_lru_wen       :std_ulogic;
signal rel_cl12_lru_wen         :std_ulogic;
signal rel_ldst_cl12_lru        :std_ulogic_vector(0 to 6);
signal congr_cl13_lru_d         :std_ulogic_vector(0 to 6);
signal congr_cl13_lru_q         :std_ulogic_vector(0 to 6);
signal congr_cl13_lru_wen       :std_ulogic;
signal xu_op_cl13_lru_wen       :std_ulogic;
signal rel_cl13_lru_wen         :std_ulogic;
signal rel_ldst_cl13_lru        :std_ulogic_vector(0 to 6);
signal congr_cl14_lru_d         :std_ulogic_vector(0 to 6);
signal congr_cl14_lru_q         :std_ulogic_vector(0 to 6);
signal congr_cl14_lru_wen       :std_ulogic;
signal xu_op_cl14_lru_wen       :std_ulogic;
signal rel_cl14_lru_wen         :std_ulogic;
signal rel_ldst_cl14_lru        :std_ulogic_vector(0 to 6);
signal congr_cl15_lru_d         :std_ulogic_vector(0 to 6);
signal congr_cl15_lru_q         :std_ulogic_vector(0 to 6);
signal congr_cl15_lru_wen       :std_ulogic;
signal xu_op_cl15_lru_wen       :std_ulogic;
signal rel_cl15_lru_wen         :std_ulogic;
signal rel_ldst_cl15_lru        :std_ulogic_vector(0 to 6);
signal congr_cl16_lru_d         :std_ulogic_vector(0 to 6);
signal congr_cl16_lru_q         :std_ulogic_vector(0 to 6);
signal congr_cl16_lru_wen       :std_ulogic;
signal xu_op_cl16_lru_wen       :std_ulogic;
signal rel_cl16_lru_wen         :std_ulogic;
signal rel_ldst_cl16_lru        :std_ulogic_vector(0 to 6);
signal congr_cl17_lru_d         :std_ulogic_vector(0 to 6);
signal congr_cl17_lru_q         :std_ulogic_vector(0 to 6);
signal congr_cl17_lru_wen       :std_ulogic;
signal xu_op_cl17_lru_wen       :std_ulogic;
signal rel_cl17_lru_wen         :std_ulogic;
signal rel_ldst_cl17_lru        :std_ulogic_vector(0 to 6);
signal congr_cl18_lru_d         :std_ulogic_vector(0 to 6);
signal congr_cl18_lru_q         :std_ulogic_vector(0 to 6);
signal congr_cl18_lru_wen       :std_ulogic;
signal xu_op_cl18_lru_wen       :std_ulogic;
signal rel_cl18_lru_wen         :std_ulogic;
signal rel_ldst_cl18_lru        :std_ulogic_vector(0 to 6);
signal congr_cl19_lru_d         :std_ulogic_vector(0 to 6);
signal congr_cl19_lru_q         :std_ulogic_vector(0 to 6);
signal congr_cl19_lru_wen       :std_ulogic;
signal xu_op_cl19_lru_wen       :std_ulogic;
signal rel_cl19_lru_wen         :std_ulogic;
signal rel_ldst_cl19_lru        :std_ulogic_vector(0 to 6);
signal congr_cl20_lru_d         :std_ulogic_vector(0 to 6);
signal congr_cl20_lru_q         :std_ulogic_vector(0 to 6);
signal congr_cl20_lru_wen       :std_ulogic;
signal xu_op_cl20_lru_wen       :std_ulogic;
signal rel_cl20_lru_wen         :std_ulogic;
signal rel_ldst_cl20_lru        :std_ulogic_vector(0 to 6);
signal congr_cl21_lru_d         :std_ulogic_vector(0 to 6);
signal congr_cl21_lru_q         :std_ulogic_vector(0 to 6);
signal congr_cl21_lru_wen       :std_ulogic;
signal xu_op_cl21_lru_wen       :std_ulogic;
signal rel_cl21_lru_wen         :std_ulogic;
signal rel_ldst_cl21_lru        :std_ulogic_vector(0 to 6);
signal congr_cl22_lru_d         :std_ulogic_vector(0 to 6);
signal congr_cl22_lru_q         :std_ulogic_vector(0 to 6);
signal congr_cl22_lru_wen       :std_ulogic;
signal xu_op_cl22_lru_wen       :std_ulogic;
signal rel_cl22_lru_wen         :std_ulogic;
signal rel_ldst_cl22_lru        :std_ulogic_vector(0 to 6);
signal congr_cl23_lru_d         :std_ulogic_vector(0 to 6);
signal congr_cl23_lru_q         :std_ulogic_vector(0 to 6);
signal congr_cl23_lru_wen       :std_ulogic;
signal xu_op_cl23_lru_wen       :std_ulogic;
signal rel_cl23_lru_wen         :std_ulogic;
signal rel_ldst_cl23_lru        :std_ulogic_vector(0 to 6);
signal congr_cl24_lru_d         :std_ulogic_vector(0 to 6);
signal congr_cl24_lru_q         :std_ulogic_vector(0 to 6);
signal congr_cl24_lru_wen       :std_ulogic;
signal xu_op_cl24_lru_wen       :std_ulogic;
signal rel_cl24_lru_wen         :std_ulogic;
signal rel_ldst_cl24_lru        :std_ulogic_vector(0 to 6);
signal congr_cl25_lru_d         :std_ulogic_vector(0 to 6);
signal congr_cl25_lru_q         :std_ulogic_vector(0 to 6);
signal congr_cl25_lru_wen       :std_ulogic;
signal xu_op_cl25_lru_wen       :std_ulogic;
signal rel_cl25_lru_wen         :std_ulogic;
signal rel_ldst_cl25_lru        :std_ulogic_vector(0 to 6);
signal congr_cl26_lru_d         :std_ulogic_vector(0 to 6);
signal congr_cl26_lru_q         :std_ulogic_vector(0 to 6);
signal congr_cl26_lru_wen       :std_ulogic;
signal xu_op_cl26_lru_wen       :std_ulogic;
signal rel_cl26_lru_wen         :std_ulogic;
signal rel_ldst_cl26_lru        :std_ulogic_vector(0 to 6);
signal congr_cl27_lru_d         :std_ulogic_vector(0 to 6);
signal congr_cl27_lru_q         :std_ulogic_vector(0 to 6);
signal congr_cl27_lru_wen       :std_ulogic;
signal xu_op_cl27_lru_wen       :std_ulogic;
signal rel_cl27_lru_wen         :std_ulogic;
signal rel_ldst_cl27_lru        :std_ulogic_vector(0 to 6);
signal congr_cl28_lru_d         :std_ulogic_vector(0 to 6);
signal congr_cl28_lru_q         :std_ulogic_vector(0 to 6);
signal congr_cl28_lru_wen       :std_ulogic;
signal xu_op_cl28_lru_wen       :std_ulogic;
signal rel_cl28_lru_wen         :std_ulogic;
signal rel_ldst_cl28_lru        :std_ulogic_vector(0 to 6);
signal congr_cl29_lru_d         :std_ulogic_vector(0 to 6);
signal congr_cl29_lru_q         :std_ulogic_vector(0 to 6);
signal congr_cl29_lru_wen       :std_ulogic;
signal xu_op_cl29_lru_wen       :std_ulogic;
signal rel_cl29_lru_wen         :std_ulogic;
signal rel_ldst_cl29_lru        :std_ulogic_vector(0 to 6);
signal congr_cl30_lru_d         :std_ulogic_vector(0 to 6);
signal congr_cl30_lru_q         :std_ulogic_vector(0 to 6);
signal congr_cl30_lru_wen       :std_ulogic;
signal xu_op_cl30_lru_wen       :std_ulogic;
signal rel_cl30_lru_wen         :std_ulogic;
signal rel_ldst_cl30_lru        :std_ulogic_vector(0 to 6);
signal congr_cl31_lru_d         :std_ulogic_vector(0 to 6);
signal congr_cl31_lru_q         :std_ulogic_vector(0 to 6);
signal congr_cl31_lru_wen       :std_ulogic;
signal xu_op_cl31_lru_wen       :std_ulogic;
signal rel_cl31_lru_wen         :std_ulogic;
signal rel_ldst_cl31_lru        :std_ulogic_vector(0 to 6);
signal ex1_congr_cl             :std_ulogic_vector(3 to 7);
signal ex2_congr_cl_d           :std_ulogic_vector(3 to 7);
signal ex2_congr_cl_q           :std_ulogic_vector(3 to 7);
signal ex3_congr_cl_d           :std_ulogic_vector(3 to 7);
signal ex3_congr_cl_q           :std_ulogic_vector(3 to 7);
signal ex4_congr_cl_d           :std_ulogic_vector(3 to 7);
signal ex4_congr_cl_q           :std_ulogic_vector(3 to 7);
signal ex5_congr_cl_d           :std_ulogic_vector(3 to 7);
signal ex5_congr_cl_q           :std_ulogic_vector(3 to 7);
signal ex6_congr_cl_d           :std_ulogic_vector(3 to 7);
signal ex6_congr_cl_q           :std_ulogic_vector(3 to 7);
signal rel_early_congr_cl       :std_ulogic_vector(3 to 7);
signal rel_congr_cl_d           :std_ulogic_vector(3 to 7);
signal rel_congr_cl_q           :std_ulogic_vector(3 to 7);
signal rel_congr_cl_stg_d       :std_ulogic_vector(3 to 7);
signal rel_congr_cl_stg_q       :std_ulogic_vector(3 to 7);
signal relu_congr_cl_d          :std_ulogic_vector(3 to 7);
signal relu_congr_cl_q          :std_ulogic_vector(3 to 7);
signal rel2_val_d               :std_ulogic;
signal rel2_val_q               :std_ulogic;
signal relu_val_wen_d           :std_ulogic;
signal relu_val_wen_q           :std_ulogic;
signal rel_val_wen_d            :std_ulogic;
signal rel_val_wen_q            :std_ulogic;
signal congr_cl_lru_b_q         :std_ulogic_vector(0 to 6);
signal rel_wayA_clr             :std_ulogic;
signal rel_wayB_clr             :std_ulogic;
signal rel_wayC_clr             :std_ulogic;
signal rel_wayD_clr             :std_ulogic;
signal rel_wayE_clr             :std_ulogic;
signal rel_wayF_clr             :std_ulogic;
signal rel_wayG_clr             :std_ulogic;
signal rel_wayH_clr             :std_ulogic;
signal rel_hit_vec              :std_ulogic_vector(0 to 7);
signal hit_wayA_upd             :std_ulogic_vector(0 to 6);
signal hit_wayB_upd             :std_ulogic_vector(0 to 6);
signal hit_wayC_upd             :std_ulogic_vector(0 to 6);
signal hit_wayD_upd             :std_ulogic_vector(0 to 6);
signal hit_wayE_upd             :std_ulogic_vector(0 to 6);
signal hit_wayF_upd             :std_ulogic_vector(0 to 6);
signal hit_wayG_upd             :std_ulogic_vector(0 to 6);
signal hit_wayh_upd             :std_ulogic_vector(0 to 6);
signal rel_hit_wayA_upd         :std_ulogic_vector(0 to 6);
signal rel_hit_wayB_upd         :std_ulogic_vector(0 to 6);
signal rel_hit_wayC_upd         :std_ulogic_vector(0 to 6);
signal rel_hit_wayD_upd         :std_ulogic_vector(0 to 6);
signal rel_hit_wayE_upd         :std_ulogic_vector(0 to 6);
signal rel_hit_wayF_upd         :std_ulogic_vector(0 to 6);
signal rel_hit_wayG_upd         :std_ulogic_vector(0 to 6);
signal rel_hit_wayh_upd         :std_ulogic_vector(0 to 6);
signal ldst_wayA_hit            :std_ulogic;
signal ldst_wayB_hit            :std_ulogic;
signal ldst_wayC_hit            :std_ulogic;
signal ldst_wayD_hit            :std_ulogic;
signal ldst_wayE_hit            :std_ulogic;
signal ldst_wayF_hit            :std_ulogic;
signal ldst_wayG_hit            :std_ulogic;
signal ldst_wayH_hit            :std_ulogic;
signal lru_upd                  :std_ulogic_vector(0 to 6);
signal relu_lru_upd_d           :std_ulogic_vector(0 to 6);
signal relu_lru_upd_q           :std_ulogic_vector(0 to 6);
signal rel_lru_val_d            :std_ulogic_vector(0 to 6);
signal rel_lru_val_q            :std_ulogic_vector(0 to 6);
signal ex5_lru_upd_d            :std_ulogic_vector(0 to 6);
signal ex5_lru_upd_q            :std_ulogic_vector(0 to 6);
signal ex6_lru_upd_d            :std_ulogic_vector(0 to 6);
signal ex6_lru_upd_q            :std_ulogic_vector(0 to 6);
signal ex4_hit_d                :std_ulogic;
signal ex4_hit_q                :std_ulogic;
signal ex3_c_acc_val            :std_ulogic;
signal ex4_c_acc_val            :std_ulogic;
signal ex4_c_acc                :std_ulogic;
signal ex4_c_acc_d              :std_ulogic;
signal ex4_c_acc_q              :std_ulogic;
signal ex5_c_acc_val            :std_ulogic;
signal ex5_c_acc_d              :std_ulogic;
signal ex5_c_acc_q              :std_ulogic;
signal ex6_c_acc_val_d          :std_ulogic;
signal ex6_c_acc_val_q          :std_ulogic;
signal ex3_flush                :std_ulogic;
signal ex4_flush                :std_ulogic;
signal ex5_flush                :std_ulogic;
signal xu_op_lru                :std_ulogic_vector(0 to 6);
signal rel_op_lru               :std_ulogic_vector(0 to 6);
signal ldst_hit_vector          :std_ulogic_vector(0 to 7);
signal arr_congr_cl_lru         :std_ulogic_vector(0 to 6);
signal rel_congr_cl_lru         :std_ulogic_vector(0 to 6);
signal p0_arr_lru_rd            :std_ulogic_vector(0 to 6);
signal p1_arr_lru_rd            :std_ulogic_vector(0 to 6);
signal rel_congr_cl_lru_b_q     :std_ulogic_vector(0 to 6);
signal congr_cl_ex3_ex4_m       :std_ulogic;
signal congr_cl_ex3_ex5_m       :std_ulogic;
signal congr_cl_ex3_p0_m        :std_ulogic;
signal congr_cl_ex3_rel2_m      :std_ulogic;
signal congr_cl_ex3_p1_m        :std_ulogic;
signal congr_cl_ex3_ex4_cmp_d   :std_ulogic;
signal congr_cl_ex3_ex4_cmp_q   :std_ulogic;
signal congr_cl_ex3_ex5_cmp_d   :std_ulogic;
signal congr_cl_ex3_ex5_cmp_q   :std_ulogic;
signal congr_cl_ex3_ex6_cmp_d   :std_ulogic;
signal congr_cl_ex3_ex6_cmp_q   :std_ulogic;
signal congr_cl_ex3_rel2_cmp_d  :std_ulogic;
signal congr_cl_ex3_rel2_cmp_q  :std_ulogic;
signal congr_cl_ex3_rel_upd_cmp_d :std_ulogic;
signal congr_cl_ex3_rel_upd_cmp_q :std_ulogic;
signal congr_cl_rel1_ex4_cmp_d  :std_ulogic;
signal congr_cl_rel1_ex4_cmp_q  :std_ulogic;
signal congr_cl_rel1_ex5_cmp_d  :std_ulogic;
signal congr_cl_rel1_ex5_cmp_q  :std_ulogic;
signal congr_cl_rel1_ex6_cmp_d  :std_ulogic;
signal congr_cl_rel1_ex6_cmp_q  :std_ulogic;
signal congr_cl_rel1_rel2_cmp_d :std_ulogic;
signal congr_cl_rel1_rel2_cmp_q :std_ulogic;
signal congr_cl_rel1_relu_cmp_d :std_ulogic;
signal congr_cl_rel1_relu_cmp_q :std_ulogic;
signal congr_cl_rel1_rel_upd_cmp_d :std_ulogic;
signal congr_cl_rel1_rel_upd_cmp_q :std_ulogic;
signal ex3_no_lru_upd_d         :std_ulogic;
signal ex3_no_lru_upd_q         :std_ulogic;
signal ex3_l1hit                :std_ulogic;
signal rel2_wayA_val            :std_ulogic;
signal rel2_wayB_val            :std_ulogic;
signal rel2_wayC_val            :std_ulogic;
signal rel2_wayD_val            :std_ulogic;
signal rel2_wayE_val            :std_ulogic;
signal rel2_wayF_val            :std_ulogic;
signal rel2_wayG_val            :std_ulogic;
signal rel2_wayH_val            :std_ulogic;
signal congr_cl_full            :std_ulogic;
signal empty_way                :std_ulogic_vector(0 to 7);
signal full_way                 :std_ulogic_vector(0 to 7);
signal rel_hit                  :std_ulogic_vector(0 to 7);
signal rel_upd_congr_cl_d       :std_ulogic_vector(3 to 7);
signal rel_upd_congr_cl_q       :std_ulogic_vector(3 to 7);
signal congr_cl_ex3_byp         :std_ulogic_vector(0 to 4);
signal congr_cl_ex3_sel         :std_ulogic_vector(1 to 4);
signal congr_cl_rel1_ex4_m      :std_ulogic;
signal congr_cl_rel1_ex5_m      :std_ulogic;
signal congr_cl_rel1_p0_m       :std_ulogic;
signal congr_cl_rel1_rel2_m     :std_ulogic;
signal congr_cl_rel1_relu_m     :std_ulogic;
signal congr_cl_rel1_p1_m       :std_ulogic;
signal rel_lru_early_sel        :std_ulogic_vector(0 to 6);
signal rel_lru_early_sel_b      :std_ulogic_vector(0 to 6);
signal congr_cl_rel1_byp        :std_ulogic_vector(0 to 5);
signal congr_cl_rel1_sel        :std_ulogic_vector(1 to 5);
signal rel_way_qsel_d           :std_ulogic_vector(0 to 7);
signal rel_way_qsel_q           :std_ulogic_vector(0 to 7);
signal rel_tag_d                :std_ulogic_vector(0 to 2);
signal rel_tag_q                :std_ulogic_vector(0 to 2);
signal rel4_val_d               :std_ulogic;
signal rel4_val_q               :std_ulogic;
signal rel4_retry_val_d         :std_ulogic;
signal rel4_retry_val_q         :std_ulogic;
signal rel_wayA_upd             :std_ulogic;
signal rel_wayB_upd             :std_ulogic;
signal rel_wayC_upd             :std_ulogic;
signal rel_wayD_upd             :std_ulogic;
signal rel_wayE_upd             :std_ulogic;
signal rel_wayF_upd             :std_ulogic;
signal rel_wayG_upd             :std_ulogic;
signal rel_wayH_upd             :std_ulogic;
signal rel_wayA_set             :std_ulogic;
signal rel_wayB_set             :std_ulogic;
signal rel_wayC_set             :std_ulogic;
signal rel_wayD_set             :std_ulogic;
signal rel_wayE_set             :std_ulogic;
signal rel_wayF_set             :std_ulogic;
signal rel_wayG_set             :std_ulogic;
signal rel_wayH_set             :std_ulogic;
signal rel_wayA_mid             :std_ulogic;
signal rel_wayB_mid             :std_ulogic;
signal rel_wayC_mid             :std_ulogic;
signal rel_wayD_mid             :std_ulogic;
signal rel_wayE_mid             :std_ulogic;
signal rel_wayF_mid             :std_ulogic;
signal rel_wayG_mid             :std_ulogic;
signal rel_wayH_mid             :std_ulogic;
signal rel1_wlock_b             :std_ulogic_vector(0 to 7);
signal rel2_wlock_d             :std_ulogic_vector(0 to 7);
signal rel2_wlock_q             :std_ulogic_vector(0 to 7);
signal rel2_wayA_lock           :std_ulogic;
signal rel2_wayB_lock           :std_ulogic;
signal rel2_wayC_lock           :std_ulogic;
signal rel2_wayD_lock           :std_ulogic;
signal rel2_wayE_lock           :std_ulogic;
signal rel2_wayF_lock           :std_ulogic;
signal rel2_wayG_lock           :std_ulogic;
signal rel2_wayH_lock           :std_ulogic;
signal rel_lock_line            :std_ulogic_vector(0 to 7);
signal rel_ovrd_lru             :std_ulogic_vector(0 to 6);
signal rel_ovrd_wayAB           :std_ulogic_vector(0 to 1);
signal rel_ovrd_wayCD           :std_ulogic_vector(0 to 1);
signal rel_ovrd_wayEF           :std_ulogic_vector(0 to 1);
signal rel_ovrd_wayGH           :std_ulogic_vector(0 to 1);
signal rel_ovrd_wayABCD         :std_ulogic_vector(0 to 1);
signal rel_ovrd_wayEFGH         :std_ulogic_vector(0 to 1);
signal rel_ovrd_wayABCDEFGH     :std_ulogic_vector(0 to 1);
signal ovr_lock_det             :std_ulogic;
signal ovr_lock_det_wlkon       :std_ulogic;
signal ovr_lock_det_wlkoff      :std_ulogic;
signal wayA_not_empty           :std_ulogic;
signal wayB_not_empty           :std_ulogic;
signal wayC_not_empty           :std_ulogic;
signal wayD_not_empty           :std_ulogic;
signal wayE_not_empty           :std_ulogic;
signal wayF_not_empty           :std_ulogic;
signal wayg_not_empty           :std_ulogic;
signal wayH_not_empty           :std_ulogic;
signal rel_way_not_empty_d      :std_ulogic_vector(0 to 7);
signal rel_way_not_empty_q      :std_ulogic_vector(0 to 7);
signal reld_q0_chk_val          :std_ulogic;
signal reld_q0_chk_way          :std_ulogic_vector(0 to 7);
signal reld_q0_way_m            :std_ulogic;
signal reld_q0_set              :std_ulogic;
signal reld_q0_inval            :std_ulogic;
signal reld_q0_val_sel          :std_ulogic_vector(0 to 1);
signal reld_q0_congr_cl_d       :std_ulogic_vector(3 to 7);
signal reld_q0_congr_cl_q       :std_ulogic_vector(3 to 7);
signal reld_q0_way_d            :std_ulogic_vector(0 to 7);
signal reld_q0_way_q            :std_ulogic_vector(0 to 7);
signal reld_q0_val_d            :std_ulogic;
signal reld_q0_val_q            :std_ulogic;
signal reld_q0_lock_d           :std_ulogic;
signal reld_q0_lock_q           :std_ulogic;
signal rel_m_q0                 :std_ulogic;
signal reld_q1_chk_val          :std_ulogic;
signal reld_q1_chk_way          :std_ulogic_vector(0 to 7);
signal reld_q1_way_m            :std_ulogic;
signal reld_q1_set              :std_ulogic;
signal reld_q1_inval            :std_ulogic;
signal reld_q1_val_sel          :std_ulogic_vector(0 to 1);
signal reld_q1_congr_cl_d       :std_ulogic_vector(3 to 7);
signal reld_q1_congr_cl_q       :std_ulogic_vector(3 to 7);
signal reld_q1_way_d            :std_ulogic_vector(0 to 7);
signal reld_q1_way_q            :std_ulogic_vector(0 to 7);
signal reld_q1_val_d            :std_ulogic;
signal reld_q1_val_q            :std_ulogic;
signal reld_q1_lock_d           :std_ulogic;
signal reld_q1_lock_q           :std_ulogic;
signal rel_m_q1                 :std_ulogic;
signal reld_q2_chk_val          :std_ulogic;
signal reld_q2_chk_way          :std_ulogic_vector(0 to 7);
signal reld_q2_way_m            :std_ulogic;
signal reld_q2_set              :std_ulogic;
signal reld_q2_inval            :std_ulogic;
signal reld_q2_val_sel          :std_ulogic_vector(0 to 1);
signal reld_q2_congr_cl_d       :std_ulogic_vector(3 to 7);
signal reld_q2_congr_cl_q       :std_ulogic_vector(3 to 7);
signal reld_q2_way_d            :std_ulogic_vector(0 to 7);
signal reld_q2_way_q            :std_ulogic_vector(0 to 7);
signal reld_q2_val_d            :std_ulogic;
signal reld_q2_val_q            :std_ulogic;
signal reld_q2_lock_d           :std_ulogic;
signal reld_q2_lock_q           :std_ulogic;
signal rel_m_q2                 :std_ulogic;
signal reld_q3_chk_val          :std_ulogic;
signal reld_q3_chk_way          :std_ulogic_vector(0 to 7);
signal reld_q3_way_m            :std_ulogic;
signal reld_q3_set              :std_ulogic;
signal reld_q3_inval            :std_ulogic;
signal reld_q3_val_sel          :std_ulogic_vector(0 to 1);
signal reld_q3_congr_cl_d       :std_ulogic_vector(3 to 7);
signal reld_q3_congr_cl_q       :std_ulogic_vector(3 to 7);
signal reld_q3_way_d            :std_ulogic_vector(0 to 7);
signal reld_q3_way_q            :std_ulogic_vector(0 to 7);
signal reld_q3_val_d            :std_ulogic;
signal reld_q3_val_q            :std_ulogic;
signal reld_q3_lock_d           :std_ulogic;
signal reld_q3_lock_q           :std_ulogic;
signal rel_m_q3                 :std_ulogic;
signal reld_q4_chk_val          :std_ulogic;
signal reld_q4_chk_way          :std_ulogic_vector(0 to 7);
signal reld_q4_way_m            :std_ulogic;
signal reld_q4_set              :std_ulogic;
signal reld_q4_inval            :std_ulogic;
signal reld_q4_val_sel          :std_ulogic_vector(0 to 1);
signal reld_q4_congr_cl_d       :std_ulogic_vector(3 to 7);
signal reld_q4_congr_cl_q       :std_ulogic_vector(3 to 7);
signal reld_q4_way_d            :std_ulogic_vector(0 to 7);
signal reld_q4_way_q            :std_ulogic_vector(0 to 7);
signal reld_q4_val_d            :std_ulogic;
signal reld_q4_val_q            :std_ulogic;
signal reld_q4_lock_d           :std_ulogic;
signal reld_q4_lock_q           :std_ulogic;
signal rel_m_q4                 :std_ulogic;
signal reld_q5_chk_val          :std_ulogic;
signal reld_q5_chk_way          :std_ulogic_vector(0 to 7);
signal reld_q5_way_m            :std_ulogic;
signal reld_q5_set              :std_ulogic;
signal reld_q5_inval            :std_ulogic;
signal reld_q5_val_sel          :std_ulogic_vector(0 to 1);
signal reld_q5_congr_cl_d       :std_ulogic_vector(3 to 7);
signal reld_q5_congr_cl_q       :std_ulogic_vector(3 to 7);
signal reld_q5_way_d            :std_ulogic_vector(0 to 7);
signal reld_q5_way_q            :std_ulogic_vector(0 to 7);
signal reld_q5_val_d            :std_ulogic;
signal reld_q5_val_q            :std_ulogic;
signal reld_q5_lock_d           :std_ulogic;
signal reld_q5_lock_q           :std_ulogic;
signal rel_m_q5                 :std_ulogic;
signal reld_q6_chk_val          :std_ulogic;
signal reld_q6_chk_way          :std_ulogic_vector(0 to 7);
signal reld_q6_way_m            :std_ulogic;
signal reld_q6_set              :std_ulogic;
signal reld_q6_inval            :std_ulogic;
signal reld_q6_val_sel          :std_ulogic_vector(0 to 1);
signal reld_q6_congr_cl_d       :std_ulogic_vector(3 to 7);
signal reld_q6_congr_cl_q       :std_ulogic_vector(3 to 7);
signal reld_q6_way_d            :std_ulogic_vector(0 to 7);
signal reld_q6_way_q            :std_ulogic_vector(0 to 7);
signal reld_q6_val_d            :std_ulogic;
signal reld_q6_val_q            :std_ulogic;
signal reld_q6_lock_d           :std_ulogic;
signal reld_q6_lock_q           :std_ulogic;
signal rel_m_q6                 :std_ulogic;
signal reld_q7_chk_val          :std_ulogic;
signal reld_q7_chk_way          :std_ulogic_vector(0 to 7);
signal reld_q7_way_m            :std_ulogic;
signal reld_q7_set              :std_ulogic;
signal reld_q7_inval            :std_ulogic;
signal reld_q7_val_sel          :std_ulogic_vector(0 to 1);
signal reld_q7_congr_cl_d       :std_ulogic_vector(3 to 7);
signal reld_q7_congr_cl_q       :std_ulogic_vector(3 to 7);
signal reld_q7_way_d            :std_ulogic_vector(0 to 7);
signal reld_q7_way_q            :std_ulogic_vector(0 to 7);
signal reld_q7_val_d            :std_ulogic;
signal reld_q7_val_q            :std_ulogic;
signal reld_q7_lock_d           :std_ulogic;
signal reld_q7_lock_q           :std_ulogic;
signal rel_m_q7                 :std_ulogic;
signal reld_match               :std_ulogic_vector(0 to 7);
signal reld_q_sel_d             :std_ulogic_vector(0 to 7);
signal reld_q_sel_q             :std_ulogic_vector(0 to 7);
signal rel_val_qsel_d           :std_ulogic;
signal rel_val_qsel_q           :std_ulogic;
signal spr_rmt_table            :std_ulogic_vector(0 to 31);
signal rel_class_id             :std_ulogic_vector(0 to 1);
signal rel2_class_id_d          :std_ulogic_vector(0 to 1);
signal rel2_class_id_q          :std_ulogic_vector(0 to 1);
signal rel_m_q_way_b            :std_ulogic_vector(0 to 7);
signal rel_m_q_way_d            :std_ulogic_vector(0 to 7);
signal rel_m_q_way_q            :std_ulogic_vector(0 to 7);
signal rel_m_q_lock_way         :std_ulogic_vector(0 to 7);
signal rel2_lock_en_d           :std_ulogic;
signal rel2_lock_en_q           :std_ulogic;
signal xucr0_clo_d              :std_ulogic;
signal xucr0_clo_q              :std_ulogic;
signal rel_way_dwen             :std_ulogic_vector(0 to 7);
signal rel24_way_dwen_stg_d     :std_ulogic_vector(0 to 7);
signal rel24_way_dwen_stg_q     :std_ulogic_vector(0 to 7);
signal rel_up_way_addr_d        :std_ulogic_vector(0 to 2);
signal rel_up_way_addr_q        :std_ulogic_vector(0 to 2);
signal rel_dcarr_addr_en_d      :std_ulogic;
signal rel_dcarr_addr_en_q      :std_ulogic;
signal rel_dcarr_val_upd_d      :std_ulogic;
signal rel_dcarr_val_upd_q      :std_ulogic;
signal rel_lru_late_sel         :std_ulogic;
signal rel_lru_late_stg_pri     :std_ulogic_vector(0 to 6);
signal rel_lru_late_stg_arr     :std_ulogic_vector(0 to 6);
signal lru_late_sel             :std_ulogic;
signal lru_late_stg_pri         :std_ulogic_vector(0 to 6);
signal lru_late_stg_arr         :std_ulogic_vector(0 to 6);
signal lru_early_sel            :std_ulogic_vector(0 to 6);
signal lru_early_sel_b          :std_ulogic_vector(0 to 6);
signal rel_hit_lru_upd          :std_ulogic_vector(0 to 6);
signal ldst_hit_vec_sel         :std_ulogic;
signal ldst_hit_lru_upd         :std_ulogic_vector(0 to 6);
signal rel_wlock_rmt            :std_ulogic_vector(0 to 7);
signal congr_cl_act_d           :std_ulogic;
signal congr_cl_act_q           :std_ulogic;
signal rel2_mid_val_d           :std_ulogic;
signal rel2_mid_val_q           :std_ulogic;
signal relq_m_way_val           :std_ulogic_vector(0 to 7);
signal rel_m_q_upd              :std_ulogic;
signal rel_m_q_upd_way          :std_ulogic_vector(0 to 7);
signal rel_m_q_upd_lock_way     :std_ulogic_vector(0 to 7);
signal reld_q_early_sel         :std_ulogic_vector(0 to 7);
signal rel_way_early_qsel       :std_ulogic_vector(0 to 7);
signal rel_way_early_qsel_d     :std_ulogic_vector(0 to 7);
signal rel_way_early_qsel_q     :std_ulogic_vector(0 to 7);
signal rel_val_early_qsel       :std_ulogic;
signal rel_val_early_qsel_d     :std_ulogic;
signal rel_val_early_qsel_q     :std_ulogic;
signal reld_q_early_byp         :std_ulogic;
signal reld_way_early_byp       :std_ulogic_vector(0 to 7);
signal reld_q_val               :std_ulogic_vector(0 to 7);
signal ex4_fxubyp_val_d         :std_ulogic;
signal ex4_fxubyp_val_q         :std_ulogic;
signal ex4_relbyp_val_d         :std_ulogic;
signal ex4_relbyp_val_q         :std_ulogic;
signal ex4_lru_byp_sel          :std_ulogic_vector(0 to 1);
signal rel2_fxubyp_val_d        :std_ulogic;
signal rel2_fxubyp_val_q        :std_ulogic;
signal rel2_relbyp_val_d        :std_ulogic;
signal rel2_relbyp_val_q        :std_ulogic;
signal rel2_lru_byp_sel         :std_ulogic_vector(0 to 1);
signal tiup                     :std_ulogic;
signal siv                      :std_ulogic_vector(0 to scan_right);
signal sov                      :std_ulogic_vector(0 to scan_right);
  BEGIN 

tiup  <=  '1';
rel2_val_d        <=  rel1_val;
rel2_mid_val_d    <=  rel_mid_val;
rel4_retry_val_d  <=  rel_retry_val;
rel4_val_d        <=  rel3_val;
rel_tag_d         <=  rel_st_tag;
rel_class_id      <=  rel1_classid;
rel2_class_id_d   <=  rel_class_id;
rel2_lock_en_d    <=  rel_lock_en;
rel2_wayA_val  <=  rel_way_val_a;
rel2_wayB_val  <=  rel_way_val_b;
rel2_wayC_val  <=  rel_way_val_c;
rel2_wayD_val  <=  rel_way_val_d;
rel2_wayE_val  <=  rel_way_val_e;
rel2_wayF_val  <=  rel_way_val_f;
rel2_wayG_val  <=  rel_way_val_g;
rel2_wayH_val  <=  rel_way_val_h;
rel2_wayA_lock  <=  rel_way_lock_a;
rel2_wayB_lock  <=  rel_way_lock_b;
rel2_wayC_lock  <=  rel_way_lock_c;
rel2_wayD_lock  <=  rel_way_lock_d;
rel2_wayE_lock  <=  rel_way_lock_e;
rel2_wayF_lock  <=  rel_way_lock_f;
rel2_wayG_lock  <=  rel_way_lock_g;
rel2_wayH_lock  <=  rel_way_lock_h;
spr_rmt_table  <=  spr_xucr2_rmt;
ldst_wayA_hit  <=  ex4_way_a_hit;
ldst_wayB_hit  <=  ex4_way_b_hit;
ldst_wayC_hit  <=  ex4_way_c_hit;
ldst_wayD_hit  <=  ex4_way_d_hit;
ldst_wayE_hit  <=  ex4_way_e_hit;
ldst_wayF_hit  <=  ex4_way_f_hit;
ldst_wayG_hit  <=  ex4_way_g_hit;
ldst_wayH_hit  <=  ex4_way_h_hit;
ex3_l1hit      <=  ex3_hit;
ex3_no_lru_upd_d  <=  ex2_no_lru_upd;
ex3_flush  <=  ex3_stg_flush;
ex4_flush  <=  ex4_stg_flush;
ex5_flush  <=  ex5_stg_flush;
ex1_congr_cl        <=  ex1_p_addr;
cl64size : if (cl_size=6) generate
begin
      rel_early_congr_cl(3 TO 6) <=  rel_addr_early(64-(dc_size-3) to 63-cl_size-1);
rel_early_congr_cl(7) <=  rel_addr_early(63-cl_size) or spr_xucr0_cls;
end generate cl64size;
cl32size : if (cl_size=5) generate
begin
      rel_early_congr_cl(3 TO 5) <=  rel_addr_early(64-(dc_size-3) to 63-cl_size-2);
rel_early_congr_cl(6) <=  rel_addr_early(63-cl_size-1) or spr_xucr0_cls;
rel_early_congr_cl(7) <=  rel_addr_early(63-cl_size);
end generate cl32size;
rel_congr_cl_d  <=  rel_early_congr_cl;
ex2_congr_cl_d  <=  ex1_congr_cl;
ex3_congr_cl_d  <=  ex2_congr_cl_q;
ex4_congr_cl_d  <=  ex3_congr_cl_q;
ex5_congr_cl_d  <=  ex4_congr_cl_q;
ex6_congr_cl_d  <=  ex5_congr_cl_q;
with rel_congr_cl_q select
    rel_congr_cl_lru  <= 
                        congr_cl0_lru_q   when "00000",
                        congr_cl1_lru_q   when "00001",
                        congr_cl2_lru_q   when "00010",
                        congr_cl3_lru_q   when "00011",
                        congr_cl4_lru_q   when "00100",
                        congr_cl5_lru_q   when "00101",
                        congr_cl6_lru_q   when "00110",
                        congr_cl7_lru_q   when "00111",
                        congr_cl8_lru_q   when "01000",
                        congr_cl9_lru_q   when "01001",
                        congr_cl10_lru_q  when "01010",
                        congr_cl11_lru_q  when "01011",
                        congr_cl12_lru_q  when "01100",
                        congr_cl13_lru_q  when "01101",
                        congr_cl14_lru_q  when "01110",
                        congr_cl15_lru_q  when "01111",
                        congr_cl16_lru_q  when "10000",
                        congr_cl17_lru_q  when "10001",
                        congr_cl18_lru_q  when "10010",
                        congr_cl19_lru_q  when "10011",
                        congr_cl20_lru_q  when "10100",
                        congr_cl21_lru_q  when "10101",
                        congr_cl22_lru_q  when "10110",
                        congr_cl23_lru_q  when "10111",
                        congr_cl24_lru_q  when "11000",
                        congr_cl25_lru_q  when "11001",
                        congr_cl26_lru_q  when "11010",
                        congr_cl27_lru_q  when "11011",
                        congr_cl28_lru_q  when "11100",
                        congr_cl29_lru_q  when "11101",
                        congr_cl30_lru_q  when "11110",
                        congr_cl31_lru_q when others;
p1_arr_lru_rd       <=  rel_congr_cl_lru;
rel_m_q_upd           <=  (rel_congr_cl_q = rel_congr_cl_stg_q) and rel2_val_q;
rel_m_q_upd_way       <=  gate(rel_hit_vec, rel_m_q_upd);
rel_m_q_upd_lock_way  <=  gate(rel_hit_vec, (rel_m_q_upd and rel2_lock_en_q));
rel_m_q0    <=  (rel_congr_cl_q = reld_q0_congr_cl_q)   and reld_q0_val_q;
rel_m_q1    <=  (rel_congr_cl_q = reld_q1_congr_cl_q)   and reld_q1_val_q;
rel_m_q2    <=  (rel_congr_cl_q = reld_q2_congr_cl_q)   and reld_q2_val_q;
rel_m_q3    <=  (rel_congr_cl_q = reld_q3_congr_cl_q)   and reld_q3_val_q;
rel_m_q4    <=  (rel_congr_cl_q = reld_q4_congr_cl_q)   and reld_q4_val_q;
rel_m_q5    <=  (rel_congr_cl_q = reld_q5_congr_cl_q)   and reld_q5_val_q;
rel_m_q6    <=  (rel_congr_cl_q = reld_q6_congr_cl_q)   and reld_q6_val_q;
rel_m_q7    <=  (rel_congr_cl_q = reld_q7_congr_cl_q)   and reld_q7_val_q;
relq_m_way_val  <=  gate(reld_q0_way_q, rel_m_q0) or
                 gate(reld_q1_way_q,   rel_m_q1)   or
                 gate(reld_q2_way_q,   rel_m_q2)   or
                 gate(reld_q3_way_q,   rel_m_q3)   or
                 gate(reld_q4_way_q,   rel_m_q4)   or
                 gate(reld_q5_way_q,   rel_m_q5)   or
                 gate(reld_q6_way_q,   rel_m_q6)   or
                 gate(reld_q7_way_q, rel_m_q7);
relMQWayB: rel_m_q_way_b  <=  not (relq_m_way_val or rel_m_q_upd_way);
rel_m_q_way_d  <=  not rel_m_q_way_b;
rel_m_q_lock_way  <=  gate(gate(reld_q0_way_q, reld_q0_lock_q), rel_m_q0) or 
                    gate(gate(reld_q1_way_q,   reld_q1_lock_q),   rel_m_q1)   or
                    gate(gate(reld_q2_way_q,   reld_q2_lock_q),   rel_m_q2)   or
                    gate(gate(reld_q3_way_q,   reld_q3_lock_q),   rel_m_q3)   or
                    gate(gate(reld_q4_way_q,   reld_q4_lock_q),   rel_m_q4)   or
                    gate(gate(reld_q5_way_q,   reld_q5_lock_q),   rel_m_q5)   or
                    gate(gate(reld_q6_way_q,   reld_q6_lock_q),   rel_m_q6)   or
                    gate(gate(reld_q7_way_q, reld_q7_lock_q), rel_m_q7) or
                    rel_wlock_rmt;
congr_cl_rel1_ex4_cmp_d      <=  (rel_early_congr_cl = ex3_congr_cl_q);
congr_cl_rel1_ex5_cmp_d      <=  (rel_early_congr_cl = ex4_congr_cl_q);
congr_cl_rel1_ex6_cmp_d      <=  (rel_early_congr_cl = ex5_congr_cl_q);
congr_cl_rel1_rel2_cmp_d     <=  (rel_early_congr_cl = rel_congr_cl_q);
congr_cl_rel1_relu_cmp_d     <=  (rel_early_congr_cl = rel_congr_cl_stg_q);
congr_cl_rel1_rel_upd_cmp_d  <=  (rel_early_congr_cl = relu_congr_cl_q);
congr_cl_rel1_ex4_m     <=  congr_cl_rel1_ex4_cmp_q     and ex4_c_acc;
congr_cl_rel1_ex5_m     <=  congr_cl_rel1_ex5_cmp_q     and ex5_c_acc_q;
congr_cl_rel1_rel2_m    <=  congr_cl_rel1_rel2_cmp_q    and rel2_val_q and not ovr_lock_det;
congr_cl_rel1_relu_m    <=  congr_cl_rel1_relu_cmp_q    and relu_val_wen_q;
congr_cl_rel1_p0_m      <=  congr_cl_rel1_ex6_cmp_q     and ex6_c_acc_val_q;
congr_cl_rel1_p1_m      <=  congr_cl_rel1_rel_upd_cmp_q and rel_val_wen_q;
congr_cl_rel1_byp(0) <=  congr_cl_rel1_rel2_m;
congr_cl_rel1_byp(1) <=  congr_cl_rel1_ex4_m;
congr_cl_rel1_byp(2) <=  congr_cl_rel1_relu_m;
congr_cl_rel1_byp(3) <=  congr_cl_rel1_ex5_m;
congr_cl_rel1_byp(4) <=  congr_cl_rel1_p1_m;
congr_cl_rel1_byp(5) <=  congr_cl_rel1_p0_m;
rel2_fxubyp_val_d     <=  congr_cl_rel1_byp(1) or congr_cl_rel1_byp(3) or congr_cl_rel1_byp(5);
rel2_relbyp_val_d     <=  congr_cl_rel1_byp(0) or congr_cl_rel1_byp(2) or congr_cl_rel1_byp(4);
rel2_lru_byp_sel      <=  rel2_fxubyp_val_q & rel2_relbyp_val_q;
congr_cl_rel1_sel(1) <=  congr_cl_rel1_byp(1);
congr_cl_rel1_sel(2) <=  congr_cl_rel1_byp(2) and not congr_cl_rel1_byp(1);
congr_cl_rel1_sel(3) <=  congr_cl_rel1_byp(3) and not or_reduce(congr_cl_rel1_byp(1 to 2));
congr_cl_rel1_sel(4) <=  congr_cl_rel1_byp(4) and not or_reduce(congr_cl_rel1_byp(1 to 3));
congr_cl_rel1_sel(5) <=  congr_cl_rel1_byp(5) and not or_reduce(congr_cl_rel1_byp(1 to 4));
rel_lru_late_sel      <=  or_reduce(congr_cl_rel1_byp(1 to 5));
rel_lru_late_stg_pri  <=  gate(lru_upd,         congr_cl_rel1_sel(1)) or
                        gate(relu_lru_upd_q,  congr_cl_rel1_sel(2)) or
                        gate(ex5_lru_upd_q,   congr_cl_rel1_sel(3)) or
                        gate(rel_lru_val_q,   congr_cl_rel1_sel(4)) or
                        gate(ex6_lru_upd_q,   congr_cl_rel1_sel(5));
rel_lru_late_stg_arr  <=  gate(p1_arr_lru_rd,   not rel_lru_late_sel) or rel_lru_late_stg_pri;
rel_lru_early_sel    <=  (others=>congr_cl_rel1_byp(0));
rel_lru_early_sel_b  <=  (others=>(not congr_cl_rel1_byp(0)));
rel_op_lru  <=  not rel_congr_cl_lru_b_q;
rel_congr_cl_stg_d   <=  rel_congr_cl_q;
relu_congr_cl_d      <=  rel_congr_cl_stg_q;
rel_upd_congr_cl_d   <=  relu_congr_cl_q;
relu_val_wen_d       <=  rel2_val_q and not ovr_lock_det;
rel_val_wen_d        <=  relu_val_wen_q;
rel_dcarr_addr_en_d  <=  rel2_val_q or (rel4_val_q and not rel4_retry_val_q) or rel2_mid_val_q;
with rel_class_id select
    rel_wlock_rmt  <=  not spr_rmt_table(0 to 7)   when "11",
                     not spr_rmt_table(8 to 15)  when "10",
                     not spr_rmt_table(16 to 23) when "01",
                     not spr_rmt_table(24 to 31) when others;
rel1WlockB: rel1_wlock_b  <=  not (rel_m_q_upd_lock_way or rel_m_q_lock_way);
rel2_wlock_d  <=  not rel1_wlock_b;
rel_lock_line(0) <=  rel2_wayA_lock or rel2_wlock_q(0);
rel_lock_line(1) <=  rel2_wayB_lock or rel2_wlock_q(1);
rel_lock_line(2) <=  rel2_wayC_lock or rel2_wlock_q(2);
rel_lock_line(3) <=  rel2_wayD_lock or rel2_wlock_q(3);
rel_lock_line(4) <=  rel2_wayE_lock or rel2_wlock_q(4);
rel_lock_line(5) <=  rel2_wayF_lock or rel2_wlock_q(5);
rel_lock_line(6) <=  rel2_wayG_lock or rel2_wlock_q(6);
rel_lock_line(7) <=  rel2_wayH_lock or rel2_wlock_q(7);
ovr_lock_det  <=  rel_lock_line(0) and rel_lock_line(1) and rel_lock_line(2) and rel_lock_line(3) and
                rel_lock_line(4) and rel_lock_line(5) and rel_lock_line(6) and rel_lock_line(7);
ovr_lock_det_wlkon   <=  ovr_lock_det and rel2_val_q;
ovr_lock_det_wlkoff  <=  ovr_lock_det and rel2_lock_en_q and rel2_val_q;
with spr_xucr0_wlck select
    xucr0_clo_d  <=   ovr_lock_det_wlkon when '1',
                   ovr_lock_det_wlkoff when others;
rel_ovrd_wayABCDEFGH  <=  (rel_lock_line(0) and rel_lock_line(1) and rel_lock_line(2) and rel_lock_line(3)) &
                        (rel_lock_line(4) and rel_lock_line(5) and rel_lock_line(6) and rel_lock_line(7));
rel_ovrd_lru(0) <=  (rel_op_lru(0) and not rel_ovrd_wayABCDEFGH(1)) or rel_ovrd_wayABCDEFGH(0);
rel_ovrd_wayABCD  <=  (rel_lock_line(0) and rel_lock_line(1)) & (rel_lock_line(2) and rel_lock_line(3));
rel_ovrd_lru(1) <=  (rel_op_lru(1) and not rel_ovrd_wayABCD(1)) or rel_ovrd_wayABCD(0);
rel_ovrd_wayEFGH  <=  (rel_lock_line(4) and rel_lock_line(5)) & (rel_lock_line(6) and rel_lock_line(7));
rel_ovrd_lru(2) <=  (rel_op_lru(2) and not rel_ovrd_wayEFGH(1)) or rel_ovrd_wayEFGH(0);
rel_ovrd_wayAB  <=  rel_lock_line(0 to 1);
rel_ovrd_lru(3) <=  (rel_op_lru(3) and not rel_ovrd_wayAB(1)) or rel_ovrd_wayAB(0);
rel_ovrd_wayCD  <=  rel_lock_line(2 to 3);
rel_ovrd_lru(4) <=  (rel_op_lru(4) and not rel_ovrd_wayCD(1)) or rel_ovrd_wayCD(0);
rel_ovrd_wayEF  <=  rel_lock_line(4 to 5);
rel_ovrd_lru(5) <=  (rel_op_lru(5) and not rel_ovrd_wayEF(1)) or rel_ovrd_wayEF(0);
rel_ovrd_wayGH  <=  rel_lock_line(6 to 7);
rel_ovrd_lru(6) <=  (rel_op_lru(6) and not rel_ovrd_wayGH(1)) or rel_ovrd_wayGH(0);
full_way(0) <=  not rel_ovrd_lru(0) and not rel_ovrd_lru(1) and not rel_ovrd_lru(3);
full_way(1) <=  not rel_ovrd_lru(0) and not rel_ovrd_lru(1) and rel_ovrd_lru(3);
full_way(2) <=  not rel_ovrd_lru(0) and rel_ovrd_lru(1) and not rel_ovrd_lru(4);
full_way(3) <=  not rel_ovrd_lru(0) and rel_ovrd_lru(1) and rel_ovrd_lru(4);
full_way(4) <=  rel_ovrd_lru(0) and not rel_ovrd_lru(2) and not rel_ovrd_lru(5);
full_way(5) <=  rel_ovrd_lru(0) and not rel_ovrd_lru(2) and rel_ovrd_lru(5);
full_way(6) <=  rel_ovrd_lru(0) and rel_ovrd_lru(2) and not rel_ovrd_lru(6);
full_way(7) <=  rel_ovrd_lru(0) and rel_ovrd_lru(2) and rel_ovrd_lru(6);
wayA_not_empty  <=  rel2_wayA_val or rel2_wlock_q(0) or rel_m_q_way_q(0);
wayB_not_empty  <=  rel2_wayB_val or rel2_wlock_q(1) or rel_m_q_way_q(1);
wayC_not_empty  <=  rel2_wayC_val or rel2_wlock_q(2) or rel_m_q_way_q(2);
wayD_not_empty  <=  rel2_wayD_val or rel2_wlock_q(3) or rel_m_q_way_q(3);
wayE_not_empty  <=  rel2_wayE_val or rel2_wlock_q(4) or rel_m_q_way_q(4);
wayF_not_empty  <=  rel2_wayF_val or rel2_wlock_q(5) or rel_m_q_way_q(5);
wayG_not_empty  <=  rel2_wayG_val or rel2_wlock_q(6) or rel_m_q_way_q(6);
wayH_not_empty  <=  rel2_wayH_val or rel2_wlock_q(7) or rel_m_q_way_q(7);
rel_way_not_empty_d  <=  wayA_not_empty & wayB_not_empty & wayC_not_empty & wayD_not_empty &
                       wayE_not_empty & wayF_not_empty & wayG_not_empty & wayH_not_empty;
congr_cl_full  <=  wayA_not_empty and wayB_not_empty and wayC_not_empty and wayD_not_empty and
                 wayE_not_empty and wayF_not_empty and wayG_not_empty and wayH_not_empty;
empty_way(0) <=  not     wayA_not_empty;
empty_way(1) <=     (    wayA_not_empty and not wayB_not_empty);
empty_way(2) <=     (    wayA_not_empty and     wayB_not_empty and not wayC_not_empty);
empty_way(3) <=     (    wayA_not_empty and     wayB_not_empty and     wayC_not_empty and not wayD_not_empty);
empty_way(4) <=     (    wayA_not_empty and     wayB_not_empty and     wayC_not_empty and     wayD_not_empty and
                    not wayE_not_empty);
empty_way(5) <=     (    wayA_not_empty and     wayB_not_empty and     wayC_not_empty and     wayD_not_empty and
                        wayE_not_empty and not wayF_not_empty);
empty_way(6) <=     (    wayA_not_empty and     wayB_not_empty and     wayC_not_empty and     wayD_not_empty and
                        wayE_not_empty and     wayF_not_empty and not wayG_not_empty);
empty_way(7) <=     (    wayA_not_empty and     wayB_not_empty and     wayC_not_empty and     wayD_not_empty and
                        wayE_not_empty and     wayF_not_empty and     wayG_not_empty);
rel_hit  <=  gate(empty_way, not congr_cl_full) or gate(full_way, congr_cl_full);
rel_wayA_clr  <=  rel_hit(0) and rel2_val_q and not ovr_lock_det;
rel_wayB_clr  <=  rel_hit(1) and rel2_val_q and not ovr_lock_det;
rel_wayC_clr  <=  rel_hit(2) and rel2_val_q and not ovr_lock_det;
rel_wayD_clr  <=  rel_hit(3) and rel2_val_q and not ovr_lock_det;
rel_wayE_clr  <=  rel_hit(4) and rel2_val_q and not ovr_lock_det;
rel_wayF_clr  <=  rel_hit(5) and rel2_val_q and not ovr_lock_det;
rel_wayG_clr  <=  rel_hit(6) and rel2_val_q and not ovr_lock_det;
rel_wayH_clr  <=  rel_hit(7) and rel2_val_q and not ovr_lock_det;
rel_hit_vec  <=  rel_wayA_clr & rel_wayB_clr & rel_wayC_clr & rel_wayD_clr &
               rel_wayE_clr & rel_wayF_clr & rel_wayG_clr & rel_wayH_clr;
rel_hit_wayA_upd  <=  "11" & rel_ovrd_lru(2) & "1" & rel_ovrd_lru(4 to 6);
rel_hit_wayB_upd  <=  "11" & rel_ovrd_lru(2) & "0" & rel_ovrd_lru(4 to 6);
rel_hit_wayC_upd  <=  "10" & rel_ovrd_lru(2 to 3) & "1" & rel_ovrd_lru(5 to 6);
rel_hit_wayD_upd  <=  "10" & rel_ovrd_lru(2 to 3) & "0" & rel_ovrd_lru(5 to 6);
rel_hit_wayE_upd  <=  "0" & rel_ovrd_lru(1) & "1" & rel_ovrd_lru(3 to 4) & "1" & rel_ovrd_lru(6);
rel_hit_wayF_upd  <=  "0" & rel_ovrd_lru(1) & "1" & rel_ovrd_lru(3 to 4) & "0" & rel_ovrd_lru(6);
rel_hit_wayG_upd  <=  "0" & rel_ovrd_lru(1) & "0" & rel_ovrd_lru(3 to 5) & "1";
rel_hit_wayh_upd  <=  "0" & rel_ovrd_lru(1) & "0" & rel_ovrd_lru(3 to 5) & "0";
rel_hit_lru_upd  <=  gate(rel_hit_wayA_upd, rel_hit_vec(0)) or gate(rel_hit_wayB_upd, rel_hit_vec(1)) or
                   gate(rel_hit_wayC_upd, rel_hit_vec(2)) or gate(rel_hit_wayD_upd, rel_hit_vec(3)) or
                   gate(rel_hit_wayE_upd, rel_hit_vec(4)) or gate(rel_hit_wayF_upd, rel_hit_vec(5)) or
                   gate(rel_hit_wayG_upd, rel_hit_vec(6)) or gate(rel_hit_wayH_upd, rel_hit_vec(7));
relu_lru_upd_d   <=  rel_hit_lru_upd;
rel_lru_val_d    <=  relu_lru_upd_q;
reld_q0_chk_val    <=  (reld_q0_congr_cl_q   = rel_congr_cl_stg_q) and reld_q0_val_q   and rel2_val_q and not ovr_lock_det;
reld_q0_chk_way    <=  gate(reld_q0_way_q,   reld_q0_chk_val);
reld_q0_way_m      <=  or_reduce((reld_q0_chk_way   and rel_hit));
reld_match(0) <=  reld_q0_way_m;
reld_q0_set        <=  rel2_val_q and (rel_tag_q = tconv(0,3));
reld_q0_inval      <=  (rel4_val_q and (not rel4_recirc_val or rel4_ecc_err) and reld_q_sel_q(0))   or reld_match(0);
reld_q0_val_sel    <=  reld_q0_set   & reld_q0_inval;
with reld_q0_set   select
    reld_q0_congr_cl_d    <=  rel_congr_cl_stg_q when '1',
                          reld_q0_congr_cl_q   when others;
with reld_q0_set   select
    reld_q0_way_d    <=    rel_hit_vec when '1',
                     reld_q0_way_q   when others;
with reld_q0_val_sel   select
    reld_q0_val_d    <=            '0' when "01",
                     reld_q0_val_q   when "00",
                                 '1' when others;
reld_q_val(0) <=  reld_q0_val_q;
with reld_q0_val_sel   select
    reld_q0_lock_d    <=            '0' when "01",
                     reld_q0_lock_q   when "00",
                       rel2_lock_en_q when others;
reld_q_early_sel(0) <=  (rel_st_tag_early = tconv(0,3));
reld_q_sel_d(0) <=  (rel_st_tag = tconv(0,3));
reld_q1_chk_val    <=  (reld_q1_congr_cl_q   = rel_congr_cl_stg_q) and reld_q1_val_q   and rel2_val_q and not ovr_lock_det;
reld_q1_chk_way    <=  gate(reld_q1_way_q,   reld_q1_chk_val);
reld_q1_way_m      <=  or_reduce((reld_q1_chk_way   and rel_hit));
reld_match(1) <=  reld_q1_way_m;
reld_q1_set        <=  rel2_val_q and (rel_tag_q = tconv(1,3));
reld_q1_inval      <=  (rel4_val_q and (not rel4_recirc_val or rel4_ecc_err) and reld_q_sel_q(1))   or reld_match(1);
reld_q1_val_sel    <=  reld_q1_set   & reld_q1_inval;
with reld_q1_set   select
    reld_q1_congr_cl_d    <=  rel_congr_cl_stg_q when '1',
                          reld_q1_congr_cl_q   when others;
with reld_q1_set   select
    reld_q1_way_d    <=    rel_hit_vec when '1',
                     reld_q1_way_q   when others;
with reld_q1_val_sel   select
    reld_q1_val_d    <=            '0' when "01",
                     reld_q1_val_q   when "00",
                                 '1' when others;
reld_q_val(1) <=  reld_q1_val_q;
with reld_q1_val_sel   select
    reld_q1_lock_d    <=            '0' when "01",
                     reld_q1_lock_q   when "00",
                       rel2_lock_en_q when others;
reld_q_early_sel(1) <=  (rel_st_tag_early = tconv(1,3));
reld_q_sel_d(1) <=  (rel_st_tag = tconv(1,3));
reld_q2_chk_val    <=  (reld_q2_congr_cl_q   = rel_congr_cl_stg_q) and reld_q2_val_q   and rel2_val_q and not ovr_lock_det;
reld_q2_chk_way    <=  gate(reld_q2_way_q,   reld_q2_chk_val);
reld_q2_way_m      <=  or_reduce((reld_q2_chk_way   and rel_hit));
reld_match(2) <=  reld_q2_way_m;
reld_q2_set        <=  rel2_val_q and (rel_tag_q = tconv(2,3));
reld_q2_inval      <=  (rel4_val_q and (not rel4_recirc_val or rel4_ecc_err) and reld_q_sel_q(2))   or reld_match(2);
reld_q2_val_sel    <=  reld_q2_set   & reld_q2_inval;
with reld_q2_set   select
    reld_q2_congr_cl_d    <=  rel_congr_cl_stg_q when '1',
                          reld_q2_congr_cl_q   when others;
with reld_q2_set   select
    reld_q2_way_d    <=    rel_hit_vec when '1',
                     reld_q2_way_q   when others;
with reld_q2_val_sel   select
    reld_q2_val_d    <=            '0' when "01",
                     reld_q2_val_q   when "00",
                                 '1' when others;
reld_q_val(2) <=  reld_q2_val_q;
with reld_q2_val_sel   select
    reld_q2_lock_d    <=            '0' when "01",
                     reld_q2_lock_q   when "00",
                       rel2_lock_en_q when others;
reld_q_early_sel(2) <=  (rel_st_tag_early = tconv(2,3));
reld_q_sel_d(2) <=  (rel_st_tag = tconv(2,3));
reld_q3_chk_val    <=  (reld_q3_congr_cl_q   = rel_congr_cl_stg_q) and reld_q3_val_q   and rel2_val_q and not ovr_lock_det;
reld_q3_chk_way    <=  gate(reld_q3_way_q,   reld_q3_chk_val);
reld_q3_way_m      <=  or_reduce((reld_q3_chk_way   and rel_hit));
reld_match(3) <=  reld_q3_way_m;
reld_q3_set        <=  rel2_val_q and (rel_tag_q = tconv(3,3));
reld_q3_inval      <=  (rel4_val_q and (not rel4_recirc_val or rel4_ecc_err) and reld_q_sel_q(3))   or reld_match(3);
reld_q3_val_sel    <=  reld_q3_set   & reld_q3_inval;
with reld_q3_set   select
    reld_q3_congr_cl_d    <=  rel_congr_cl_stg_q when '1',
                          reld_q3_congr_cl_q   when others;
with reld_q3_set   select
    reld_q3_way_d    <=    rel_hit_vec when '1',
                     reld_q3_way_q   when others;
with reld_q3_val_sel   select
    reld_q3_val_d    <=            '0' when "01",
                     reld_q3_val_q   when "00",
                                 '1' when others;
reld_q_val(3) <=  reld_q3_val_q;
with reld_q3_val_sel   select
    reld_q3_lock_d    <=            '0' when "01",
                     reld_q3_lock_q   when "00",
                       rel2_lock_en_q when others;
reld_q_early_sel(3) <=  (rel_st_tag_early = tconv(3,3));
reld_q_sel_d(3) <=  (rel_st_tag = tconv(3,3));
reld_q4_chk_val    <=  (reld_q4_congr_cl_q   = rel_congr_cl_stg_q) and reld_q4_val_q   and rel2_val_q and not ovr_lock_det;
reld_q4_chk_way    <=  gate(reld_q4_way_q,   reld_q4_chk_val);
reld_q4_way_m      <=  or_reduce((reld_q4_chk_way   and rel_hit));
reld_match(4) <=  reld_q4_way_m;
reld_q4_set        <=  rel2_val_q and (rel_tag_q = tconv(4,3));
reld_q4_inval      <=  (rel4_val_q and (not rel4_recirc_val or rel4_ecc_err) and reld_q_sel_q(4))   or reld_match(4);
reld_q4_val_sel    <=  reld_q4_set   & reld_q4_inval;
with reld_q4_set   select
    reld_q4_congr_cl_d    <=  rel_congr_cl_stg_q when '1',
                          reld_q4_congr_cl_q   when others;
with reld_q4_set   select
    reld_q4_way_d    <=    rel_hit_vec when '1',
                     reld_q4_way_q   when others;
with reld_q4_val_sel   select
    reld_q4_val_d    <=            '0' when "01",
                     reld_q4_val_q   when "00",
                                 '1' when others;
reld_q_val(4) <=  reld_q4_val_q;
with reld_q4_val_sel   select
    reld_q4_lock_d    <=            '0' when "01",
                     reld_q4_lock_q   when "00",
                       rel2_lock_en_q when others;
reld_q_early_sel(4) <=  (rel_st_tag_early = tconv(4,3));
reld_q_sel_d(4) <=  (rel_st_tag = tconv(4,3));
reld_q5_chk_val    <=  (reld_q5_congr_cl_q   = rel_congr_cl_stg_q) and reld_q5_val_q   and rel2_val_q and not ovr_lock_det;
reld_q5_chk_way    <=  gate(reld_q5_way_q,   reld_q5_chk_val);
reld_q5_way_m      <=  or_reduce((reld_q5_chk_way   and rel_hit));
reld_match(5) <=  reld_q5_way_m;
reld_q5_set        <=  rel2_val_q and (rel_tag_q = tconv(5,3));
reld_q5_inval      <=  (rel4_val_q and (not rel4_recirc_val or rel4_ecc_err) and reld_q_sel_q(5))   or reld_match(5);
reld_q5_val_sel    <=  reld_q5_set   & reld_q5_inval;
with reld_q5_set   select
    reld_q5_congr_cl_d    <=  rel_congr_cl_stg_q when '1',
                          reld_q5_congr_cl_q   when others;
with reld_q5_set   select
    reld_q5_way_d    <=    rel_hit_vec when '1',
                     reld_q5_way_q   when others;
with reld_q5_val_sel   select
    reld_q5_val_d    <=            '0' when "01",
                     reld_q5_val_q   when "00",
                                 '1' when others;
reld_q_val(5) <=  reld_q5_val_q;
with reld_q5_val_sel   select
    reld_q5_lock_d    <=            '0' when "01",
                     reld_q5_lock_q   when "00",
                       rel2_lock_en_q when others;
reld_q_early_sel(5) <=  (rel_st_tag_early = tconv(5,3));
reld_q_sel_d(5) <=  (rel_st_tag = tconv(5,3));
reld_q6_chk_val    <=  (reld_q6_congr_cl_q   = rel_congr_cl_stg_q) and reld_q6_val_q   and rel2_val_q and not ovr_lock_det;
reld_q6_chk_way    <=  gate(reld_q6_way_q,   reld_q6_chk_val);
reld_q6_way_m      <=  or_reduce((reld_q6_chk_way   and rel_hit));
reld_match(6) <=  reld_q6_way_m;
reld_q6_set        <=  rel2_val_q and (rel_tag_q = tconv(6,3));
reld_q6_inval      <=  (rel4_val_q and (not rel4_recirc_val or rel4_ecc_err) and reld_q_sel_q(6))   or reld_match(6);
reld_q6_val_sel    <=  reld_q6_set   & reld_q6_inval;
with reld_q6_set   select
    reld_q6_congr_cl_d    <=  rel_congr_cl_stg_q when '1',
                          reld_q6_congr_cl_q   when others;
with reld_q6_set   select
    reld_q6_way_d    <=    rel_hit_vec when '1',
                     reld_q6_way_q   when others;
with reld_q6_val_sel   select
    reld_q6_val_d    <=            '0' when "01",
                     reld_q6_val_q   when "00",
                                 '1' when others;
reld_q_val(6) <=  reld_q6_val_q;
with reld_q6_val_sel   select
    reld_q6_lock_d    <=            '0' when "01",
                     reld_q6_lock_q   when "00",
                       rel2_lock_en_q when others;
reld_q_early_sel(6) <=  (rel_st_tag_early = tconv(6,3));
reld_q_sel_d(6) <=  (rel_st_tag = tconv(6,3));
reld_q7_chk_val    <=  (reld_q7_congr_cl_q   = rel_congr_cl_stg_q) and reld_q7_val_q   and rel2_val_q and not ovr_lock_det;
reld_q7_chk_way    <=  gate(reld_q7_way_q,   reld_q7_chk_val);
reld_q7_way_m      <=  or_reduce((reld_q7_chk_way   and rel_hit));
reld_match(7) <=  reld_q7_way_m;
reld_q7_set        <=  rel2_val_q and (rel_tag_q = tconv(7,3));
reld_q7_inval      <=  (rel4_val_q and (not rel4_recirc_val or rel4_ecc_err) and reld_q_sel_q(7))   or reld_match(7);
reld_q7_val_sel    <=  reld_q7_set   & reld_q7_inval;
with reld_q7_set   select
    reld_q7_congr_cl_d    <=  rel_congr_cl_stg_q when '1',
                          reld_q7_congr_cl_q   when others;
with reld_q7_set   select
    reld_q7_way_d    <=    rel_hit_vec when '1',
                     reld_q7_way_q   when others;
with reld_q7_val_sel   select
    reld_q7_val_d    <=            '0' when "01",
                     reld_q7_val_q   when "00",
                                 '1' when others;
reld_q_val(7) <=  reld_q7_val_q;
with reld_q7_val_sel   select
    reld_q7_lock_d    <=            '0' when "01",
                     reld_q7_lock_q   when "00",
                       rel2_lock_en_q when others;
reld_q_early_sel(7) <=  (rel_st_tag_early = tconv(7,3));
reld_q_sel_d(7) <=  (rel_st_tag = tconv(7,3));
rel_way_early_qsel  <=  gate(reld_q0_way_q, reld_q_early_sel(0)) or
                gate(reld_q1_way_q,   reld_q_early_sel(1))   or
                gate(reld_q2_way_q,   reld_q_early_sel(2))   or
                gate(reld_q3_way_q,   reld_q_early_sel(3))   or
                gate(reld_q4_way_q,   reld_q_early_sel(4))   or
                gate(reld_q5_way_q,   reld_q_early_sel(5))   or
                gate(reld_q6_way_q,   reld_q_early_sel(6))   or
                gate(reld_q7_way_q, reld_q_early_sel(7));
rel_val_early_qsel  <=  (reld_q0_val_q and reld_q_early_sel(0)) or
                (reld_q1_val_q   and reld_q_early_sel(1))   or
                (reld_q2_val_q   and reld_q_early_sel(2))   or
                (reld_q3_val_q   and reld_q_early_sel(3))   or
                (reld_q4_val_q   and reld_q_early_sel(4))   or
                (reld_q5_val_q   and reld_q_early_sel(5))   or
                (reld_q6_val_q   and reld_q_early_sel(6))   or
                (reld_q7_val_q and reld_q_early_sel(7));
reld_q_early_byp    <=  (rel_st_tag_early = rel_tag_q) and rel2_val_q;
reld_way_early_byp  <=  rel_hit_vec;
rel_way_early_qsel_d  <=  gate(rel_way_early_qsel, not reld_q_early_byp) or gate(reld_way_early_byp, reld_q_early_byp);
rel_val_early_qsel_d  <=  rel_val_early_qsel or reld_q_early_byp;
rel_way_qsel_d  <=  gate(reld_q0_way_q, reld_q_sel_d(0)) or
                gate(reld_q1_way_q,   reld_q_sel_d(1))   or
                gate(reld_q2_way_q,   reld_q_sel_d(2))   or
                gate(reld_q3_way_q,   reld_q_sel_d(3))   or
                gate(reld_q4_way_q,   reld_q_sel_d(4))   or
                gate(reld_q5_way_q,   reld_q_sel_d(5))   or
                gate(reld_q6_way_q,   reld_q_sel_d(6))   or
                gate(reld_q7_way_q, reld_q_sel_d(7));
rel_val_qsel_d  <=  (reld_q0_val_q and reld_q_sel_d(0) and not reld_match(0)) or
                (reld_q1_val_q   and reld_q_sel_d(1)   and not reld_match(1))   or
                (reld_q2_val_q   and reld_q_sel_d(2)   and not reld_match(2))   or
                (reld_q3_val_q   and reld_q_sel_d(3)   and not reld_match(3))   or
                (reld_q4_val_q   and reld_q_sel_d(4)   and not reld_match(4))   or
                (reld_q5_val_q   and reld_q_sel_d(5)   and not reld_match(5))   or
                (reld_q6_val_q   and reld_q_sel_d(6)   and not reld_match(6))   or
                (reld_q7_val_q and reld_q_sel_d(7) and not reld_match(7));
rel_wayA_upd  <=  rel_way_early_qsel_q(0) and rel_val_early_qsel_q;
rel_wayB_upd  <=  rel_way_early_qsel_q(1) and rel_val_early_qsel_q;
rel_wayC_upd  <=  rel_way_early_qsel_q(2) and rel_val_early_qsel_q;
rel_wayD_upd  <=  rel_way_early_qsel_q(3) and rel_val_early_qsel_q;
rel_wayE_upd  <=  rel_way_early_qsel_q(4) and rel_val_early_qsel_q;
rel_wayF_upd  <=  rel_way_early_qsel_q(5) and rel_val_early_qsel_q;
rel_wayG_upd  <=  rel_way_early_qsel_q(6) and rel_val_early_qsel_q;
rel_wayH_upd  <=  rel_way_early_qsel_q(7) and rel_val_early_qsel_q;
rel_wayA_set  <=  rel_way_qsel_q(0) and rel4_val_q and rel_val_qsel_q;
rel_wayB_set  <=  rel_way_qsel_q(1) and rel4_val_q and rel_val_qsel_q;
rel_wayC_set  <=  rel_way_qsel_q(2) and rel4_val_q and rel_val_qsel_q;
rel_wayD_set  <=  rel_way_qsel_q(3) and rel4_val_q and rel_val_qsel_q;
rel_wayE_set  <=  rel_way_qsel_q(4) and rel4_val_q and rel_val_qsel_q;
rel_wayF_set  <=  rel_way_qsel_q(5) and rel4_val_q and rel_val_qsel_q;
rel_wayG_set  <=  rel_way_qsel_q(6) and rel4_val_q and rel_val_qsel_q;
rel_wayH_set  <=  rel_way_qsel_q(7) and rel4_val_q and rel_val_qsel_q;
rel_wayA_mid  <=  rel_way_qsel_q(0) and rel2_mid_val_q and rel_val_qsel_q;
rel_wayB_mid  <=  rel_way_qsel_q(1) and rel2_mid_val_q and rel_val_qsel_q;
rel_wayC_mid  <=  rel_way_qsel_q(2) and rel2_mid_val_q and rel_val_qsel_q;
rel_wayD_mid  <=  rel_way_qsel_q(3) and rel2_mid_val_q and rel_val_qsel_q;
rel_wayE_mid  <=  rel_way_qsel_q(4) and rel2_mid_val_q and rel_val_qsel_q;
rel_wayF_mid  <=  rel_way_qsel_q(5) and rel2_mid_val_q and rel_val_qsel_q;
rel_wayG_mid  <=  rel_way_qsel_q(6) and rel2_mid_val_q and rel_val_qsel_q;
rel_wayH_mid  <=  rel_way_qsel_q(7) and rel2_mid_val_q and rel_val_qsel_q;
with ex3_congr_cl_q select
    arr_congr_cl_lru  <= 
                        congr_cl0_lru_q   when "00000",
                        congr_cl1_lru_q   when "00001",
                        congr_cl2_lru_q   when "00010",
                        congr_cl3_lru_q   when "00011",
                        congr_cl4_lru_q   when "00100",
                        congr_cl5_lru_q   when "00101",
                        congr_cl6_lru_q   when "00110",
                        congr_cl7_lru_q   when "00111",
                        congr_cl8_lru_q   when "01000",
                        congr_cl9_lru_q   when "01001",
                        congr_cl10_lru_q  when "01010",
                        congr_cl11_lru_q  when "01011",
                        congr_cl12_lru_q  when "01100",
                        congr_cl13_lru_q  when "01101",
                        congr_cl14_lru_q  when "01110",
                        congr_cl15_lru_q  when "01111",
                        congr_cl16_lru_q  when "10000",
                        congr_cl17_lru_q  when "10001",
                        congr_cl18_lru_q  when "10010",
                        congr_cl19_lru_q  when "10011",
                        congr_cl20_lru_q  when "10100",
                        congr_cl21_lru_q  when "10101",
                        congr_cl22_lru_q  when "10110",
                        congr_cl23_lru_q  when "10111",
                        congr_cl24_lru_q  when "11000",
                        congr_cl25_lru_q  when "11001",
                        congr_cl26_lru_q  when "11010",
                        congr_cl27_lru_q  when "11011",
                        congr_cl28_lru_q  when "11100",
                        congr_cl29_lru_q  when "11101",
                        congr_cl30_lru_q  when "11110",
                        congr_cl31_lru_q when others;
p0_arr_lru_rd  <=  arr_congr_cl_lru;
ex3_c_acc_val    <=  ex3_cache_en and not (ex3_no_lru_upd_q or spr_xucr0_dcdis or ex3_flush);
ex4_hit_d        <=  ex3_l1hit;
ex4_c_acc_d      <=  ex3_c_acc_val;
ex4_c_acc        <=  ex4_c_acc_q and ex4_hit_q;
ex4_c_acc_val    <=  ex4_c_acc and not ex4_flush;
ex5_c_acc_d      <=  ex4_c_acc_val;
ex5_c_acc_val    <=  ex5_c_acc_q and not ex5_flush;
ex6_c_acc_val_d  <=  ex5_c_acc_val;
congr_cl_ex3_ex4_cmp_d      <=  (ex2_congr_cl_q = ex3_congr_cl_q);
congr_cl_ex3_ex5_cmp_d      <=  (ex2_congr_cl_q = ex4_congr_cl_q);
congr_cl_ex3_ex6_cmp_d      <=  (ex2_congr_cl_q = ex5_congr_cl_q);
congr_cl_ex3_rel2_cmp_d     <=  (ex2_congr_cl_q = rel_congr_cl_q);
congr_cl_ex3_rel_upd_cmp_d  <=  (ex2_congr_cl_q = relu_congr_cl_q);
congr_cl_ex3_ex4_m     <=  congr_cl_ex3_ex4_cmp_q     and ex4_c_acc;
congr_cl_ex3_ex5_m     <=  congr_cl_ex3_ex5_cmp_q     and ex5_c_acc_q;
congr_cl_ex3_rel2_m    <=  congr_cl_ex3_rel2_cmp_q    and rel2_val_q and not ovr_lock_det;
congr_cl_ex3_p0_m      <=  congr_cl_ex3_ex6_cmp_q     and ex6_c_acc_val_q;
congr_cl_ex3_p1_m      <=  congr_cl_ex3_rel_upd_cmp_q and rel_val_wen_q;
congr_cl_ex3_byp(0) <=  congr_cl_ex3_rel2_m;
congr_cl_ex3_byp(1) <=  congr_cl_ex3_ex4_m;
congr_cl_ex3_byp(2) <=  congr_cl_ex3_ex5_m;
congr_cl_ex3_byp(3) <=  congr_cl_ex3_p1_m;
congr_cl_ex3_byp(4) <=  congr_cl_ex3_p0_m;
ex4_fxubyp_val_d     <=  congr_cl_ex3_byp(1) or congr_cl_ex3_byp(2) or congr_cl_ex3_byp(4);
ex4_relbyp_val_d     <=  congr_cl_ex3_byp(0) or congr_cl_ex3_byp(3);
ex4_lru_byp_sel      <=  ex4_fxubyp_val_q & ex4_relbyp_val_q;
congr_cl_ex3_sel(1) <=  congr_cl_ex3_byp(1);
congr_cl_ex3_sel(2) <=  congr_cl_ex3_byp(2) and not congr_cl_ex3_byp(1);
congr_cl_ex3_sel(3) <=  congr_cl_ex3_byp(3) and not or_reduce(congr_cl_ex3_byp(1 to 2));
congr_cl_ex3_sel(4) <=  congr_cl_ex3_byp(4) and not or_reduce(congr_cl_ex3_byp(1 to 3));
lru_late_sel      <=  or_reduce(congr_cl_ex3_byp(1 to 4));
lru_late_stg_pri  <=  gate(lru_upd,         congr_cl_ex3_sel(1)) or
                    gate(ex5_lru_upd_q,   congr_cl_ex3_sel(2)) or
                    gate(rel_lru_val_q,   congr_cl_ex3_sel(3)) or
                    gate(ex6_lru_upd_q,   congr_cl_ex3_sel(4));
lru_late_stg_arr  <=  gate(p0_arr_lru_rd,   not lru_late_sel) or lru_late_stg_pri;
lru_early_sel    <=  (others=>congr_cl_ex3_byp(0));
lru_early_sel_b  <=  (others=>(not congr_cl_ex3_byp(0)));
xu_op_lru  <=  not congr_cl_lru_b_q;
ldst_hit_vector  <=  ldst_wayA_hit & ldst_wayB_hit & ldst_wayC_hit & ldst_wayD_hit &
                   ldst_wayE_hit & ldst_wayF_hit & ldst_wayG_hit & ldst_wayH_hit;
hit_wayA_upd  <=  "11" & xu_op_lru(2) & "1" & xu_op_lru(4 to 6);
hit_wayB_upd  <=  "11" & xu_op_lru(2) & "0" & xu_op_lru(4 to 6);
hit_wayC_upd  <=  "10" & xu_op_lru(2 to 3) & "1" & xu_op_lru(5 to 6);
hit_wayD_upd  <=  "10" & xu_op_lru(2 to 3) & "0" & xu_op_lru(5 to 6);
hit_wayE_upd  <=  "0" & xu_op_lru(1) & "1" & xu_op_lru(3 to 4) & "1" & xu_op_lru(6);
hit_wayF_upd  <=  "0" & xu_op_lru(1) & "1" & xu_op_lru(3 to 4) & "0" & xu_op_lru(6);
hit_wayG_upd  <=  "0" & xu_op_lru(1) & "0" & xu_op_lru(3 to 5) & "1";
hit_wayh_upd  <=  "0" & xu_op_lru(1) & "0" & xu_op_lru(3 to 5) & "0";
ldst_hit_vec_sel  <=  or_reduce(ldst_hit_vector);
ldst_hit_lru_upd  <=  gate(hit_wayA_upd, ldst_hit_vector(0)) or gate(hit_wayB_upd, ldst_hit_vector(1)) or
                    gate(hit_wayC_upd, ldst_hit_vector(2)) or gate(hit_wayD_upd, ldst_hit_vector(3)) or
                    gate(hit_wayE_upd, ldst_hit_vector(4)) or gate(hit_wayF_upd, ldst_hit_vector(5)) or
                    gate(hit_wayG_upd, ldst_hit_vector(6)) or gate(hit_wayH_upd, ldst_hit_vector(7));
with ldst_hit_vec_sel select
    lru_upd  <=  ldst_hit_lru_upd when '1',
                      xu_op_lru when others;
ex5_lru_upd_d  <=  lru_upd;
ex6_lru_upd_d  <=  ex5_lru_upd_q;
rel_way_dwen  <=  (rel_wayA_clr or rel_wayA_set or rel_wayA_mid) & (rel_wayB_clr or rel_wayB_set or rel_wayB_mid) &
                (rel_wayC_clr or rel_wayC_set or rel_wayC_mid) & (rel_wayD_clr or rel_wayD_set or rel_wayD_mid) &
                (rel_wayE_clr or rel_wayE_set or rel_wayE_mid) & (rel_wayF_clr or rel_wayF_set or rel_wayF_mid) &
                (rel_wayG_clr or rel_wayG_set or rel_wayG_mid) & (rel_wayH_clr or rel_wayH_set or rel_wayH_mid);
rel24_way_dwen_stg_d  <=  rel_way_dwen;
rel_dcarr_val_upd_d  <=  or_reduce(rel_way_dwen) and not rel4_retry_val_q;
rel_up_way_addr_d  <=                                  gate("001", rel_way_dwen(1)) or
                     gate("010", rel_way_dwen(2)) or gate("011", rel_way_dwen(3)) or
                     gate("100", rel_way_dwen(4)) or gate("101", rel_way_dwen(5)) or
                     gate("110", rel_way_dwen(6)) or gate("111", rel_way_dwen(7));
rel_up_way_addr_b     <=  not rel_up_way_addr_q;
rel_dcarr_addr_en     <=  rel_dcarr_addr_en_q;
congr_cl_act_d  <=  ex5_c_acc_q or relu_val_wen_q;
xu_op_cl0_lru_wen    <=  (ex6_congr_cl_q     = tconv(0,5))   and ex6_c_acc_val_q;
rel_cl0_lru_wen      <=  (rel_upd_congr_cl_q = tconv(0,5))   and rel_val_wen_q;
congr_cl0_lru_wen    <=  xu_op_cl0_lru_wen   or rel_cl0_lru_wen;
with rel_cl0_lru_wen   select
    rel_ldst_cl0_lru    <=  rel_lru_val_q when '1',
                          ex6_lru_upd_q when others;
with congr_cl0_lru_wen   select
    congr_cl0_lru_d    <=  rel_ldst_cl0_lru   when '1',
                          congr_cl0_lru_q   when others;
xu_op_cl1_lru_wen    <=  (ex6_congr_cl_q     = tconv(1,5))   and ex6_c_acc_val_q;
rel_cl1_lru_wen      <=  (rel_upd_congr_cl_q = tconv(1,5))   and rel_val_wen_q;
congr_cl1_lru_wen    <=  xu_op_cl1_lru_wen   or rel_cl1_lru_wen;
with rel_cl1_lru_wen   select
    rel_ldst_cl1_lru    <=  rel_lru_val_q when '1',
                          ex6_lru_upd_q when others;
with congr_cl1_lru_wen   select
    congr_cl1_lru_d    <=  rel_ldst_cl1_lru   when '1',
                          congr_cl1_lru_q   when others;
xu_op_cl2_lru_wen    <=  (ex6_congr_cl_q     = tconv(2,5))   and ex6_c_acc_val_q;
rel_cl2_lru_wen      <=  (rel_upd_congr_cl_q = tconv(2,5))   and rel_val_wen_q;
congr_cl2_lru_wen    <=  xu_op_cl2_lru_wen   or rel_cl2_lru_wen;
with rel_cl2_lru_wen   select
    rel_ldst_cl2_lru    <=  rel_lru_val_q when '1',
                          ex6_lru_upd_q when others;
with congr_cl2_lru_wen   select
    congr_cl2_lru_d    <=  rel_ldst_cl2_lru   when '1',
                          congr_cl2_lru_q   when others;
xu_op_cl3_lru_wen    <=  (ex6_congr_cl_q     = tconv(3,5))   and ex6_c_acc_val_q;
rel_cl3_lru_wen      <=  (rel_upd_congr_cl_q = tconv(3,5))   and rel_val_wen_q;
congr_cl3_lru_wen    <=  xu_op_cl3_lru_wen   or rel_cl3_lru_wen;
with rel_cl3_lru_wen   select
    rel_ldst_cl3_lru    <=  rel_lru_val_q when '1',
                          ex6_lru_upd_q when others;
with congr_cl3_lru_wen   select
    congr_cl3_lru_d    <=  rel_ldst_cl3_lru   when '1',
                          congr_cl3_lru_q   when others;
xu_op_cl4_lru_wen    <=  (ex6_congr_cl_q     = tconv(4,5))   and ex6_c_acc_val_q;
rel_cl4_lru_wen      <=  (rel_upd_congr_cl_q = tconv(4,5))   and rel_val_wen_q;
congr_cl4_lru_wen    <=  xu_op_cl4_lru_wen   or rel_cl4_lru_wen;
with rel_cl4_lru_wen   select
    rel_ldst_cl4_lru    <=  rel_lru_val_q when '1',
                          ex6_lru_upd_q when others;
with congr_cl4_lru_wen   select
    congr_cl4_lru_d    <=  rel_ldst_cl4_lru   when '1',
                          congr_cl4_lru_q   when others;
xu_op_cl5_lru_wen    <=  (ex6_congr_cl_q     = tconv(5,5))   and ex6_c_acc_val_q;
rel_cl5_lru_wen      <=  (rel_upd_congr_cl_q = tconv(5,5))   and rel_val_wen_q;
congr_cl5_lru_wen    <=  xu_op_cl5_lru_wen   or rel_cl5_lru_wen;
with rel_cl5_lru_wen   select
    rel_ldst_cl5_lru    <=  rel_lru_val_q when '1',
                          ex6_lru_upd_q when others;
with congr_cl5_lru_wen   select
    congr_cl5_lru_d    <=  rel_ldst_cl5_lru   when '1',
                          congr_cl5_lru_q   when others;
xu_op_cl6_lru_wen    <=  (ex6_congr_cl_q     = tconv(6,5))   and ex6_c_acc_val_q;
rel_cl6_lru_wen      <=  (rel_upd_congr_cl_q = tconv(6,5))   and rel_val_wen_q;
congr_cl6_lru_wen    <=  xu_op_cl6_lru_wen   or rel_cl6_lru_wen;
with rel_cl6_lru_wen   select
    rel_ldst_cl6_lru    <=  rel_lru_val_q when '1',
                          ex6_lru_upd_q when others;
with congr_cl6_lru_wen   select
    congr_cl6_lru_d    <=  rel_ldst_cl6_lru   when '1',
                          congr_cl6_lru_q   when others;
xu_op_cl7_lru_wen    <=  (ex6_congr_cl_q     = tconv(7,5))   and ex6_c_acc_val_q;
rel_cl7_lru_wen      <=  (rel_upd_congr_cl_q = tconv(7,5))   and rel_val_wen_q;
congr_cl7_lru_wen    <=  xu_op_cl7_lru_wen   or rel_cl7_lru_wen;
with rel_cl7_lru_wen   select
    rel_ldst_cl7_lru    <=  rel_lru_val_q when '1',
                          ex6_lru_upd_q when others;
with congr_cl7_lru_wen   select
    congr_cl7_lru_d    <=  rel_ldst_cl7_lru   when '1',
                          congr_cl7_lru_q   when others;
xu_op_cl8_lru_wen    <=  (ex6_congr_cl_q     = tconv(8,5))   and ex6_c_acc_val_q;
rel_cl8_lru_wen      <=  (rel_upd_congr_cl_q = tconv(8,5))   and rel_val_wen_q;
congr_cl8_lru_wen    <=  xu_op_cl8_lru_wen   or rel_cl8_lru_wen;
with rel_cl8_lru_wen   select
    rel_ldst_cl8_lru    <=  rel_lru_val_q when '1',
                          ex6_lru_upd_q when others;
with congr_cl8_lru_wen   select
    congr_cl8_lru_d    <=  rel_ldst_cl8_lru   when '1',
                          congr_cl8_lru_q   when others;
xu_op_cl9_lru_wen    <=  (ex6_congr_cl_q     = tconv(9,5))   and ex6_c_acc_val_q;
rel_cl9_lru_wen      <=  (rel_upd_congr_cl_q = tconv(9,5))   and rel_val_wen_q;
congr_cl9_lru_wen    <=  xu_op_cl9_lru_wen   or rel_cl9_lru_wen;
with rel_cl9_lru_wen   select
    rel_ldst_cl9_lru    <=  rel_lru_val_q when '1',
                          ex6_lru_upd_q when others;
with congr_cl9_lru_wen   select
    congr_cl9_lru_d    <=  rel_ldst_cl9_lru   when '1',
                          congr_cl9_lru_q   when others;
xu_op_cl10_lru_wen   <=  (ex6_congr_cl_q     = tconv(10,5))  and ex6_c_acc_val_q;
rel_cl10_lru_wen     <=  (rel_upd_congr_cl_q = tconv(10,5))  and rel_val_wen_q;
congr_cl10_lru_wen   <=  xu_op_cl10_lru_wen  or rel_cl10_lru_wen;
with rel_cl10_lru_wen  select
    rel_ldst_cl10_lru   <=  rel_lru_val_q when '1',
                          ex6_lru_upd_q when others;
with congr_cl10_lru_wen  select
    congr_cl10_lru_d   <=  rel_ldst_cl10_lru  when '1',
                          congr_cl10_lru_q  when others;
xu_op_cl11_lru_wen   <=  (ex6_congr_cl_q     = tconv(11,5))  and ex6_c_acc_val_q;
rel_cl11_lru_wen     <=  (rel_upd_congr_cl_q = tconv(11,5))  and rel_val_wen_q;
congr_cl11_lru_wen   <=  xu_op_cl11_lru_wen  or rel_cl11_lru_wen;
with rel_cl11_lru_wen  select
    rel_ldst_cl11_lru   <=  rel_lru_val_q when '1',
                          ex6_lru_upd_q when others;
with congr_cl11_lru_wen  select
    congr_cl11_lru_d   <=  rel_ldst_cl11_lru  when '1',
                          congr_cl11_lru_q  when others;
xu_op_cl12_lru_wen   <=  (ex6_congr_cl_q     = tconv(12,5))  and ex6_c_acc_val_q;
rel_cl12_lru_wen     <=  (rel_upd_congr_cl_q = tconv(12,5))  and rel_val_wen_q;
congr_cl12_lru_wen   <=  xu_op_cl12_lru_wen  or rel_cl12_lru_wen;
with rel_cl12_lru_wen  select
    rel_ldst_cl12_lru   <=  rel_lru_val_q when '1',
                          ex6_lru_upd_q when others;
with congr_cl12_lru_wen  select
    congr_cl12_lru_d   <=  rel_ldst_cl12_lru  when '1',
                          congr_cl12_lru_q  when others;
xu_op_cl13_lru_wen   <=  (ex6_congr_cl_q     = tconv(13,5))  and ex6_c_acc_val_q;
rel_cl13_lru_wen     <=  (rel_upd_congr_cl_q = tconv(13,5))  and rel_val_wen_q;
congr_cl13_lru_wen   <=  xu_op_cl13_lru_wen  or rel_cl13_lru_wen;
with rel_cl13_lru_wen  select
    rel_ldst_cl13_lru   <=  rel_lru_val_q when '1',
                          ex6_lru_upd_q when others;
with congr_cl13_lru_wen  select
    congr_cl13_lru_d   <=  rel_ldst_cl13_lru  when '1',
                          congr_cl13_lru_q  when others;
xu_op_cl14_lru_wen   <=  (ex6_congr_cl_q     = tconv(14,5))  and ex6_c_acc_val_q;
rel_cl14_lru_wen     <=  (rel_upd_congr_cl_q = tconv(14,5))  and rel_val_wen_q;
congr_cl14_lru_wen   <=  xu_op_cl14_lru_wen  or rel_cl14_lru_wen;
with rel_cl14_lru_wen  select
    rel_ldst_cl14_lru   <=  rel_lru_val_q when '1',
                          ex6_lru_upd_q when others;
with congr_cl14_lru_wen  select
    congr_cl14_lru_d   <=  rel_ldst_cl14_lru  when '1',
                          congr_cl14_lru_q  when others;
xu_op_cl15_lru_wen   <=  (ex6_congr_cl_q     = tconv(15,5))  and ex6_c_acc_val_q;
rel_cl15_lru_wen     <=  (rel_upd_congr_cl_q = tconv(15,5))  and rel_val_wen_q;
congr_cl15_lru_wen   <=  xu_op_cl15_lru_wen  or rel_cl15_lru_wen;
with rel_cl15_lru_wen  select
    rel_ldst_cl15_lru   <=  rel_lru_val_q when '1',
                          ex6_lru_upd_q when others;
with congr_cl15_lru_wen  select
    congr_cl15_lru_d   <=  rel_ldst_cl15_lru  when '1',
                          congr_cl15_lru_q  when others;
xu_op_cl16_lru_wen   <=  (ex6_congr_cl_q     = tconv(16,5))  and ex6_c_acc_val_q;
rel_cl16_lru_wen     <=  (rel_upd_congr_cl_q = tconv(16,5))  and rel_val_wen_q;
congr_cl16_lru_wen   <=  xu_op_cl16_lru_wen  or rel_cl16_lru_wen;
with rel_cl16_lru_wen  select
    rel_ldst_cl16_lru   <=  rel_lru_val_q when '1',
                          ex6_lru_upd_q when others;
with congr_cl16_lru_wen  select
    congr_cl16_lru_d   <=  rel_ldst_cl16_lru  when '1',
                          congr_cl16_lru_q  when others;
xu_op_cl17_lru_wen   <=  (ex6_congr_cl_q     = tconv(17,5))  and ex6_c_acc_val_q;
rel_cl17_lru_wen     <=  (rel_upd_congr_cl_q = tconv(17,5))  and rel_val_wen_q;
congr_cl17_lru_wen   <=  xu_op_cl17_lru_wen  or rel_cl17_lru_wen;
with rel_cl17_lru_wen  select
    rel_ldst_cl17_lru   <=  rel_lru_val_q when '1',
                          ex6_lru_upd_q when others;
with congr_cl17_lru_wen  select
    congr_cl17_lru_d   <=  rel_ldst_cl17_lru  when '1',
                          congr_cl17_lru_q  when others;
xu_op_cl18_lru_wen   <=  (ex6_congr_cl_q     = tconv(18,5))  and ex6_c_acc_val_q;
rel_cl18_lru_wen     <=  (rel_upd_congr_cl_q = tconv(18,5))  and rel_val_wen_q;
congr_cl18_lru_wen   <=  xu_op_cl18_lru_wen  or rel_cl18_lru_wen;
with rel_cl18_lru_wen  select
    rel_ldst_cl18_lru   <=  rel_lru_val_q when '1',
                          ex6_lru_upd_q when others;
with congr_cl18_lru_wen  select
    congr_cl18_lru_d   <=  rel_ldst_cl18_lru  when '1',
                          congr_cl18_lru_q  when others;
xu_op_cl19_lru_wen   <=  (ex6_congr_cl_q     = tconv(19,5))  and ex6_c_acc_val_q;
rel_cl19_lru_wen     <=  (rel_upd_congr_cl_q = tconv(19,5))  and rel_val_wen_q;
congr_cl19_lru_wen   <=  xu_op_cl19_lru_wen  or rel_cl19_lru_wen;
with rel_cl19_lru_wen  select
    rel_ldst_cl19_lru   <=  rel_lru_val_q when '1',
                          ex6_lru_upd_q when others;
with congr_cl19_lru_wen  select
    congr_cl19_lru_d   <=  rel_ldst_cl19_lru  when '1',
                          congr_cl19_lru_q  when others;
xu_op_cl20_lru_wen   <=  (ex6_congr_cl_q     = tconv(20,5))  and ex6_c_acc_val_q;
rel_cl20_lru_wen     <=  (rel_upd_congr_cl_q = tconv(20,5))  and rel_val_wen_q;
congr_cl20_lru_wen   <=  xu_op_cl20_lru_wen  or rel_cl20_lru_wen;
with rel_cl20_lru_wen  select
    rel_ldst_cl20_lru   <=  rel_lru_val_q when '1',
                          ex6_lru_upd_q when others;
with congr_cl20_lru_wen  select
    congr_cl20_lru_d   <=  rel_ldst_cl20_lru  when '1',
                          congr_cl20_lru_q  when others;
xu_op_cl21_lru_wen   <=  (ex6_congr_cl_q     = tconv(21,5))  and ex6_c_acc_val_q;
rel_cl21_lru_wen     <=  (rel_upd_congr_cl_q = tconv(21,5))  and rel_val_wen_q;
congr_cl21_lru_wen   <=  xu_op_cl21_lru_wen  or rel_cl21_lru_wen;
with rel_cl21_lru_wen  select
    rel_ldst_cl21_lru   <=  rel_lru_val_q when '1',
                          ex6_lru_upd_q when others;
with congr_cl21_lru_wen  select
    congr_cl21_lru_d   <=  rel_ldst_cl21_lru  when '1',
                          congr_cl21_lru_q  when others;
xu_op_cl22_lru_wen   <=  (ex6_congr_cl_q     = tconv(22,5))  and ex6_c_acc_val_q;
rel_cl22_lru_wen     <=  (rel_upd_congr_cl_q = tconv(22,5))  and rel_val_wen_q;
congr_cl22_lru_wen   <=  xu_op_cl22_lru_wen  or rel_cl22_lru_wen;
with rel_cl22_lru_wen  select
    rel_ldst_cl22_lru   <=  rel_lru_val_q when '1',
                          ex6_lru_upd_q when others;
with congr_cl22_lru_wen  select
    congr_cl22_lru_d   <=  rel_ldst_cl22_lru  when '1',
                          congr_cl22_lru_q  when others;
xu_op_cl23_lru_wen   <=  (ex6_congr_cl_q     = tconv(23,5))  and ex6_c_acc_val_q;
rel_cl23_lru_wen     <=  (rel_upd_congr_cl_q = tconv(23,5))  and rel_val_wen_q;
congr_cl23_lru_wen   <=  xu_op_cl23_lru_wen  or rel_cl23_lru_wen;
with rel_cl23_lru_wen  select
    rel_ldst_cl23_lru   <=  rel_lru_val_q when '1',
                          ex6_lru_upd_q when others;
with congr_cl23_lru_wen  select
    congr_cl23_lru_d   <=  rel_ldst_cl23_lru  when '1',
                          congr_cl23_lru_q  when others;
xu_op_cl24_lru_wen   <=  (ex6_congr_cl_q     = tconv(24,5))  and ex6_c_acc_val_q;
rel_cl24_lru_wen     <=  (rel_upd_congr_cl_q = tconv(24,5))  and rel_val_wen_q;
congr_cl24_lru_wen   <=  xu_op_cl24_lru_wen  or rel_cl24_lru_wen;
with rel_cl24_lru_wen  select
    rel_ldst_cl24_lru   <=  rel_lru_val_q when '1',
                          ex6_lru_upd_q when others;
with congr_cl24_lru_wen  select
    congr_cl24_lru_d   <=  rel_ldst_cl24_lru  when '1',
                          congr_cl24_lru_q  when others;
xu_op_cl25_lru_wen   <=  (ex6_congr_cl_q     = tconv(25,5))  and ex6_c_acc_val_q;
rel_cl25_lru_wen     <=  (rel_upd_congr_cl_q = tconv(25,5))  and rel_val_wen_q;
congr_cl25_lru_wen   <=  xu_op_cl25_lru_wen  or rel_cl25_lru_wen;
with rel_cl25_lru_wen  select
    rel_ldst_cl25_lru   <=  rel_lru_val_q when '1',
                          ex6_lru_upd_q when others;
with congr_cl25_lru_wen  select
    congr_cl25_lru_d   <=  rel_ldst_cl25_lru  when '1',
                          congr_cl25_lru_q  when others;
xu_op_cl26_lru_wen   <=  (ex6_congr_cl_q     = tconv(26,5))  and ex6_c_acc_val_q;
rel_cl26_lru_wen     <=  (rel_upd_congr_cl_q = tconv(26,5))  and rel_val_wen_q;
congr_cl26_lru_wen   <=  xu_op_cl26_lru_wen  or rel_cl26_lru_wen;
with rel_cl26_lru_wen  select
    rel_ldst_cl26_lru   <=  rel_lru_val_q when '1',
                          ex6_lru_upd_q when others;
with congr_cl26_lru_wen  select
    congr_cl26_lru_d   <=  rel_ldst_cl26_lru  when '1',
                          congr_cl26_lru_q  when others;
xu_op_cl27_lru_wen   <=  (ex6_congr_cl_q     = tconv(27,5))  and ex6_c_acc_val_q;
rel_cl27_lru_wen     <=  (rel_upd_congr_cl_q = tconv(27,5))  and rel_val_wen_q;
congr_cl27_lru_wen   <=  xu_op_cl27_lru_wen  or rel_cl27_lru_wen;
with rel_cl27_lru_wen  select
    rel_ldst_cl27_lru   <=  rel_lru_val_q when '1',
                          ex6_lru_upd_q when others;
with congr_cl27_lru_wen  select
    congr_cl27_lru_d   <=  rel_ldst_cl27_lru  when '1',
                          congr_cl27_lru_q  when others;
xu_op_cl28_lru_wen   <=  (ex6_congr_cl_q     = tconv(28,5))  and ex6_c_acc_val_q;
rel_cl28_lru_wen     <=  (rel_upd_congr_cl_q = tconv(28,5))  and rel_val_wen_q;
congr_cl28_lru_wen   <=  xu_op_cl28_lru_wen  or rel_cl28_lru_wen;
with rel_cl28_lru_wen  select
    rel_ldst_cl28_lru   <=  rel_lru_val_q when '1',
                          ex6_lru_upd_q when others;
with congr_cl28_lru_wen  select
    congr_cl28_lru_d   <=  rel_ldst_cl28_lru  when '1',
                          congr_cl28_lru_q  when others;
xu_op_cl29_lru_wen   <=  (ex6_congr_cl_q     = tconv(29,5))  and ex6_c_acc_val_q;
rel_cl29_lru_wen     <=  (rel_upd_congr_cl_q = tconv(29,5))  and rel_val_wen_q;
congr_cl29_lru_wen   <=  xu_op_cl29_lru_wen  or rel_cl29_lru_wen;
with rel_cl29_lru_wen  select
    rel_ldst_cl29_lru   <=  rel_lru_val_q when '1',
                          ex6_lru_upd_q when others;
with congr_cl29_lru_wen  select
    congr_cl29_lru_d   <=  rel_ldst_cl29_lru  when '1',
                          congr_cl29_lru_q  when others;
xu_op_cl30_lru_wen   <=  (ex6_congr_cl_q     = tconv(30,5))  and ex6_c_acc_val_q;
rel_cl30_lru_wen     <=  (rel_upd_congr_cl_q = tconv(30,5))  and rel_val_wen_q;
congr_cl30_lru_wen   <=  xu_op_cl30_lru_wen  or rel_cl30_lru_wen;
with rel_cl30_lru_wen  select
    rel_ldst_cl30_lru   <=  rel_lru_val_q when '1',
                          ex6_lru_upd_q when others;
with congr_cl30_lru_wen  select
    congr_cl30_lru_d   <=  rel_ldst_cl30_lru  when '1',
                          congr_cl30_lru_q  when others;
xu_op_cl31_lru_wen   <=  (ex6_congr_cl_q     = tconv(31,5))  and ex6_c_acc_val_q;
rel_cl31_lru_wen     <=  (rel_upd_congr_cl_q = tconv(31,5))  and rel_val_wen_q;
congr_cl31_lru_wen   <=  xu_op_cl31_lru_wen  or rel_cl31_lru_wen;
with rel_cl31_lru_wen  select
    rel_ldst_cl31_lru   <=  rel_lru_val_q when '1',
                          ex6_lru_upd_q when others;
with congr_cl31_lru_wen  select
    congr_cl31_lru_d   <=  rel_ldst_cl31_lru  when '1',
                          congr_cl31_lru_q  when others;
rel_way_clr_a  <=  rel_wayA_clr;
rel_way_clr_b  <=  rel_wayB_clr;
rel_way_clr_c  <=  rel_wayC_clr;
rel_way_clr_d  <=  rel_wayD_clr;
rel_way_clr_e  <=  rel_wayE_clr;
rel_way_clr_f  <=  rel_wayF_clr;
rel_way_clr_g  <=  rel_wayG_clr;
rel_way_clr_h  <=  rel_wayH_clr;
rel_way_upd_a  <=  rel_wayA_upd;
rel_way_upd_b  <=  rel_wayB_upd;
rel_way_upd_c  <=  rel_wayC_upd;
rel_way_upd_d  <=  rel_wayD_upd;
rel_way_upd_e  <=  rel_wayE_upd;
rel_way_upd_f  <=  rel_wayF_upd;
rel_way_upd_g  <=  rel_wayG_upd;
rel_way_upd_h  <=  rel_wayH_upd;
rel_way_wen_a  <=  rel_wayA_set;
rel_way_wen_b  <=  rel_wayB_set;
rel_way_wen_c  <=  rel_wayC_set;
rel_way_wen_d  <=  rel_wayD_set;
rel_way_wen_e  <=  rel_wayE_set;
rel_way_wen_f  <=  rel_wayF_set;
rel_way_wen_g  <=  rel_wayG_set;
rel_way_wen_h  <=  rel_wayH_set;
rel_dcarr_val_upd  <=  rel_dcarr_val_upd_q;
lsu_xu_spr_xucr0_clo  <=  xucr0_clo_q;
ex4_dir_lru  <=  xu_op_lru;
dc_lru_dbg_data  <=  rel24_way_dwen_stg_q & reld_q_val      & rel_m_q_way_q    & rel2_wlock_q  &  
                   rel_way_not_empty_q  & ex4_lru_byp_sel & rel2_lru_byp_sel & rel_val_wen_q &  
                   rel_op_lru           & rel_lru_val_q   & xucr0_clo_q      & xu_op_lru     &  
                   ex6_c_acc_val_q      & ex6_lru_upd_q   & rel2_class_id_q  & rel_tag_q     &  
                   rel4_retry_val_q     & ex4_c_acc;
congr_cl0_lru_reg:   tri_rlmreg_p
generic map (width => 7, init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => congr_cl_act_q,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(congr_cl0_lru_offset   to congr_cl0_lru_offset   + congr_cl0_lru_d'length-1),
            scout   => sov(congr_cl0_lru_offset   to congr_cl0_lru_offset   + congr_cl0_lru_d'length-1),
            din     => congr_cl0_lru_d,
            dout    => congr_cl0_lru_q);
congr_cl1_lru_reg:   tri_rlmreg_p
generic map (width => 7, init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => congr_cl_act_q,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(congr_cl1_lru_offset   to congr_cl1_lru_offset   + congr_cl1_lru_d'length-1),
            scout   => sov(congr_cl1_lru_offset   to congr_cl1_lru_offset   + congr_cl1_lru_d'length-1),
            din     => congr_cl1_lru_d,
            dout    => congr_cl1_lru_q);
congr_cl2_lru_reg:   tri_rlmreg_p
generic map (width => 7, init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => congr_cl_act_q,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(congr_cl2_lru_offset   to congr_cl2_lru_offset   + congr_cl2_lru_d'length-1),
            scout   => sov(congr_cl2_lru_offset   to congr_cl2_lru_offset   + congr_cl2_lru_d'length-1),
            din     => congr_cl2_lru_d,
            dout    => congr_cl2_lru_q);
congr_cl3_lru_reg:   tri_rlmreg_p
generic map (width => 7, init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => congr_cl_act_q,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(congr_cl3_lru_offset   to congr_cl3_lru_offset   + congr_cl3_lru_d'length-1),
            scout   => sov(congr_cl3_lru_offset   to congr_cl3_lru_offset   + congr_cl3_lru_d'length-1),
            din     => congr_cl3_lru_d,
            dout    => congr_cl3_lru_q);
congr_cl4_lru_reg:   tri_rlmreg_p
generic map (width => 7, init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => congr_cl_act_q,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(congr_cl4_lru_offset   to congr_cl4_lru_offset   + congr_cl4_lru_d'length-1),
            scout   => sov(congr_cl4_lru_offset   to congr_cl4_lru_offset   + congr_cl4_lru_d'length-1),
            din     => congr_cl4_lru_d,
            dout    => congr_cl4_lru_q);
congr_cl5_lru_reg:   tri_rlmreg_p
generic map (width => 7, init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => congr_cl_act_q,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(congr_cl5_lru_offset   to congr_cl5_lru_offset   + congr_cl5_lru_d'length-1),
            scout   => sov(congr_cl5_lru_offset   to congr_cl5_lru_offset   + congr_cl5_lru_d'length-1),
            din     => congr_cl5_lru_d,
            dout    => congr_cl5_lru_q);
congr_cl6_lru_reg:   tri_rlmreg_p
generic map (width => 7, init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => congr_cl_act_q,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(congr_cl6_lru_offset   to congr_cl6_lru_offset   + congr_cl6_lru_d'length-1),
            scout   => sov(congr_cl6_lru_offset   to congr_cl6_lru_offset   + congr_cl6_lru_d'length-1),
            din     => congr_cl6_lru_d,
            dout    => congr_cl6_lru_q);
congr_cl7_lru_reg:   tri_rlmreg_p
generic map (width => 7, init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => congr_cl_act_q,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(congr_cl7_lru_offset   to congr_cl7_lru_offset   + congr_cl7_lru_d'length-1),
            scout   => sov(congr_cl7_lru_offset   to congr_cl7_lru_offset   + congr_cl7_lru_d'length-1),
            din     => congr_cl7_lru_d,
            dout    => congr_cl7_lru_q);
congr_cl8_lru_reg:   tri_rlmreg_p
generic map (width => 7, init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => congr_cl_act_q,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(congr_cl8_lru_offset   to congr_cl8_lru_offset   + congr_cl8_lru_d'length-1),
            scout   => sov(congr_cl8_lru_offset   to congr_cl8_lru_offset   + congr_cl8_lru_d'length-1),
            din     => congr_cl8_lru_d,
            dout    => congr_cl8_lru_q);
congr_cl9_lru_reg:   tri_rlmreg_p
generic map (width => 7, init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => congr_cl_act_q,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(congr_cl9_lru_offset   to congr_cl9_lru_offset   + congr_cl9_lru_d'length-1),
            scout   => sov(congr_cl9_lru_offset   to congr_cl9_lru_offset   + congr_cl9_lru_d'length-1),
            din     => congr_cl9_lru_d,
            dout    => congr_cl9_lru_q);
congr_cl10_lru_reg:  tri_rlmreg_p
generic map (width => 7, init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => congr_cl_act_q,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(congr_cl10_lru_offset  to congr_cl10_lru_offset  + congr_cl10_lru_d'length-1),
            scout   => sov(congr_cl10_lru_offset  to congr_cl10_lru_offset  + congr_cl10_lru_d'length-1),
            din     => congr_cl10_lru_d,
            dout    => congr_cl10_lru_q);
congr_cl11_lru_reg:  tri_rlmreg_p
generic map (width => 7, init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => congr_cl_act_q,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(congr_cl11_lru_offset  to congr_cl11_lru_offset  + congr_cl11_lru_d'length-1),
            scout   => sov(congr_cl11_lru_offset  to congr_cl11_lru_offset  + congr_cl11_lru_d'length-1),
            din     => congr_cl11_lru_d,
            dout    => congr_cl11_lru_q);
congr_cl12_lru_reg:  tri_rlmreg_p
generic map (width => 7, init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => congr_cl_act_q,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(congr_cl12_lru_offset  to congr_cl12_lru_offset  + congr_cl12_lru_d'length-1),
            scout   => sov(congr_cl12_lru_offset  to congr_cl12_lru_offset  + congr_cl12_lru_d'length-1),
            din     => congr_cl12_lru_d,
            dout    => congr_cl12_lru_q);
congr_cl13_lru_reg:  tri_rlmreg_p
generic map (width => 7, init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => congr_cl_act_q,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(congr_cl13_lru_offset  to congr_cl13_lru_offset  + congr_cl13_lru_d'length-1),
            scout   => sov(congr_cl13_lru_offset  to congr_cl13_lru_offset  + congr_cl13_lru_d'length-1),
            din     => congr_cl13_lru_d,
            dout    => congr_cl13_lru_q);
congr_cl14_lru_reg:  tri_rlmreg_p
generic map (width => 7, init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => congr_cl_act_q,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(congr_cl14_lru_offset  to congr_cl14_lru_offset  + congr_cl14_lru_d'length-1),
            scout   => sov(congr_cl14_lru_offset  to congr_cl14_lru_offset  + congr_cl14_lru_d'length-1),
            din     => congr_cl14_lru_d,
            dout    => congr_cl14_lru_q);
congr_cl15_lru_reg:  tri_rlmreg_p
generic map (width => 7, init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => congr_cl_act_q,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(congr_cl15_lru_offset  to congr_cl15_lru_offset  + congr_cl15_lru_d'length-1),
            scout   => sov(congr_cl15_lru_offset  to congr_cl15_lru_offset  + congr_cl15_lru_d'length-1),
            din     => congr_cl15_lru_d,
            dout    => congr_cl15_lru_q);
congr_cl16_lru_reg:  tri_rlmreg_p
generic map (width => 7, init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => congr_cl_act_q,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(congr_cl16_lru_offset  to congr_cl16_lru_offset  + congr_cl16_lru_d'length-1),
            scout   => sov(congr_cl16_lru_offset  to congr_cl16_lru_offset  + congr_cl16_lru_d'length-1),
            din     => congr_cl16_lru_d,
            dout    => congr_cl16_lru_q);
congr_cl17_lru_reg:  tri_rlmreg_p
generic map (width => 7, init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => congr_cl_act_q,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(congr_cl17_lru_offset  to congr_cl17_lru_offset  + congr_cl17_lru_d'length-1),
            scout   => sov(congr_cl17_lru_offset  to congr_cl17_lru_offset  + congr_cl17_lru_d'length-1),
            din     => congr_cl17_lru_d,
            dout    => congr_cl17_lru_q);
congr_cl18_lru_reg:  tri_rlmreg_p
generic map (width => 7, init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => congr_cl_act_q,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(congr_cl18_lru_offset  to congr_cl18_lru_offset  + congr_cl18_lru_d'length-1),
            scout   => sov(congr_cl18_lru_offset  to congr_cl18_lru_offset  + congr_cl18_lru_d'length-1),
            din     => congr_cl18_lru_d,
            dout    => congr_cl18_lru_q);
congr_cl19_lru_reg:  tri_rlmreg_p
generic map (width => 7, init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => congr_cl_act_q,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(congr_cl19_lru_offset  to congr_cl19_lru_offset  + congr_cl19_lru_d'length-1),
            scout   => sov(congr_cl19_lru_offset  to congr_cl19_lru_offset  + congr_cl19_lru_d'length-1),
            din     => congr_cl19_lru_d,
            dout    => congr_cl19_lru_q);
congr_cl20_lru_reg:  tri_rlmreg_p
generic map (width => 7, init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => congr_cl_act_q,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(congr_cl20_lru_offset  to congr_cl20_lru_offset  + congr_cl20_lru_d'length-1),
            scout   => sov(congr_cl20_lru_offset  to congr_cl20_lru_offset  + congr_cl20_lru_d'length-1),
            din     => congr_cl20_lru_d,
            dout    => congr_cl20_lru_q);
congr_cl21_lru_reg:  tri_rlmreg_p
generic map (width => 7, init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => congr_cl_act_q,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(congr_cl21_lru_offset  to congr_cl21_lru_offset  + congr_cl21_lru_d'length-1),
            scout   => sov(congr_cl21_lru_offset  to congr_cl21_lru_offset  + congr_cl21_lru_d'length-1),
            din     => congr_cl21_lru_d,
            dout    => congr_cl21_lru_q);
congr_cl22_lru_reg:  tri_rlmreg_p
generic map (width => 7, init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => congr_cl_act_q,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(congr_cl22_lru_offset  to congr_cl22_lru_offset  + congr_cl22_lru_d'length-1),
            scout   => sov(congr_cl22_lru_offset  to congr_cl22_lru_offset  + congr_cl22_lru_d'length-1),
            din     => congr_cl22_lru_d,
            dout    => congr_cl22_lru_q);
congr_cl23_lru_reg:  tri_rlmreg_p
generic map (width => 7, init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => congr_cl_act_q,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(congr_cl23_lru_offset  to congr_cl23_lru_offset  + congr_cl23_lru_d'length-1),
            scout   => sov(congr_cl23_lru_offset  to congr_cl23_lru_offset  + congr_cl23_lru_d'length-1),
            din     => congr_cl23_lru_d,
            dout    => congr_cl23_lru_q);
congr_cl24_lru_reg:  tri_rlmreg_p
generic map (width => 7, init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => congr_cl_act_q,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(congr_cl24_lru_offset  to congr_cl24_lru_offset  + congr_cl24_lru_d'length-1),
            scout   => sov(congr_cl24_lru_offset  to congr_cl24_lru_offset  + congr_cl24_lru_d'length-1),
            din     => congr_cl24_lru_d,
            dout    => congr_cl24_lru_q);
congr_cl25_lru_reg:  tri_rlmreg_p
generic map (width => 7, init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => congr_cl_act_q,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(congr_cl25_lru_offset  to congr_cl25_lru_offset  + congr_cl25_lru_d'length-1),
            scout   => sov(congr_cl25_lru_offset  to congr_cl25_lru_offset  + congr_cl25_lru_d'length-1),
            din     => congr_cl25_lru_d,
            dout    => congr_cl25_lru_q);
congr_cl26_lru_reg:  tri_rlmreg_p
generic map (width => 7, init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => congr_cl_act_q,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(congr_cl26_lru_offset  to congr_cl26_lru_offset  + congr_cl26_lru_d'length-1),
            scout   => sov(congr_cl26_lru_offset  to congr_cl26_lru_offset  + congr_cl26_lru_d'length-1),
            din     => congr_cl26_lru_d,
            dout    => congr_cl26_lru_q);
congr_cl27_lru_reg:  tri_rlmreg_p
generic map (width => 7, init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => congr_cl_act_q,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(congr_cl27_lru_offset  to congr_cl27_lru_offset  + congr_cl27_lru_d'length-1),
            scout   => sov(congr_cl27_lru_offset  to congr_cl27_lru_offset  + congr_cl27_lru_d'length-1),
            din     => congr_cl27_lru_d,
            dout    => congr_cl27_lru_q);
congr_cl28_lru_reg:  tri_rlmreg_p
generic map (width => 7, init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => congr_cl_act_q,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(congr_cl28_lru_offset  to congr_cl28_lru_offset  + congr_cl28_lru_d'length-1),
            scout   => sov(congr_cl28_lru_offset  to congr_cl28_lru_offset  + congr_cl28_lru_d'length-1),
            din     => congr_cl28_lru_d,
            dout    => congr_cl28_lru_q);
congr_cl29_lru_reg:  tri_rlmreg_p
generic map (width => 7, init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => congr_cl_act_q,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(congr_cl29_lru_offset  to congr_cl29_lru_offset  + congr_cl29_lru_d'length-1),
            scout   => sov(congr_cl29_lru_offset  to congr_cl29_lru_offset  + congr_cl29_lru_d'length-1),
            din     => congr_cl29_lru_d,
            dout    => congr_cl29_lru_q);
congr_cl30_lru_reg:  tri_rlmreg_p
generic map (width => 7, init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => congr_cl_act_q,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(congr_cl30_lru_offset  to congr_cl30_lru_offset  + congr_cl30_lru_d'length-1),
            scout   => sov(congr_cl30_lru_offset  to congr_cl30_lru_offset  + congr_cl30_lru_d'length-1),
            din     => congr_cl30_lru_d,
            dout    => congr_cl30_lru_q);
congr_cl31_lru_reg:  tri_rlmreg_p
generic map (width => 7, init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => congr_cl_act_q,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(congr_cl31_lru_offset  to congr_cl31_lru_offset  + congr_cl31_lru_d'length-1),
            scout   => sov(congr_cl31_lru_offset  to congr_cl31_lru_offset  + congr_cl31_lru_d'length-1),
            din     => congr_cl31_lru_d,
            dout    => congr_cl31_lru_q);
congr_cl_lru_b_reg: tri_aoi22_nlats_wlcb
generic map (width => 7, init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => ex3_stg_act,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(congr_cl_lru_b_offset to congr_cl_lru_b_offset + congr_cl_lru_b_q'length-1),
            scout   => sov(congr_cl_lru_b_offset to congr_cl_lru_b_offset + congr_cl_lru_b_q'length-1),
            a1      => rel_hit_lru_upd,
            a2      => lru_early_sel,
            b1      => lru_late_stg_arr,
            b2      => lru_early_sel_b,
            qb      => congr_cl_lru_b_q);
rel_congr_cl_lru_b_reg: tri_aoi22_nlats_wlcb
generic map (width => 7, init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => rel1_stg_act,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(rel_congr_cl_lru_b_offset to rel_congr_cl_lru_b_offset + rel_congr_cl_lru_b_q'length-1),
            scout   => sov(rel_congr_cl_lru_b_offset to rel_congr_cl_lru_b_offset + rel_congr_cl_lru_b_q'length-1),
            a1      => rel_hit_lru_upd,
            a2      => rel_lru_early_sel,
            b1      => rel_lru_late_stg_arr,
            b2      => rel_lru_early_sel_b,
            qb      => rel_congr_cl_lru_b_q);
reld_q_sel_reg: tri_rlmreg_p
generic map (width => 8, init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => rel1_stg_act,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(reld_q_sel_offset to reld_q_sel_offset + reld_q_sel_d'length-1),
            scout   => sov(reld_q_sel_offset to reld_q_sel_offset + reld_q_sel_d'length-1),
            din     => reld_q_sel_d,
            dout    => reld_q_sel_q);
ex4_congr_cl_reg: tri_regk
generic map (width => 5, init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => ex3_stg_act,
            forcee => func_nsl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_nsl_thold_0_b,
            din     => ex4_congr_cl_d,
            dout    => ex4_congr_cl_q);
ex5_congr_cl_reg: tri_rlmreg_p
generic map (width => 5, init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => ex4_stg_act,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex5_congr_cl_offset to ex5_congr_cl_offset + ex5_congr_cl_d'length-1),
            scout   => sov(ex5_congr_cl_offset to ex5_congr_cl_offset + ex5_congr_cl_d'length-1),
            din     => ex5_congr_cl_d,
            dout    => ex5_congr_cl_q);
ex6_congr_cl_reg: tri_regk
generic map (width => 5, init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => ex5_stg_act,
            forcee => func_nsl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_nsl_thold_0_b,
            din     => ex6_congr_cl_d,
            dout    => ex6_congr_cl_q);
rel_congr_cl_reg: tri_rlmreg_p
generic map (width => 5, init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => tiup,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(rel_congr_cl_offset to rel_congr_cl_offset + rel_congr_cl_d'length-1),
            scout   => sov(rel_congr_cl_offset to rel_congr_cl_offset + rel_congr_cl_d'length-1),
            din     => rel_congr_cl_d,
            dout    => rel_congr_cl_q);
rel_congr_cl_stg_reg: tri_regk
generic map (width => 5, init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => rel1_stg_act,
            forcee => func_nsl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_nsl_thold_0_b,
            din     => rel_congr_cl_stg_d,
            dout    => rel_congr_cl_stg_q);
relu_congr_cl_reg: tri_rlmreg_p
generic map (width => 5, init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => rel2_stg_act,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(relu_congr_cl_offset to relu_congr_cl_offset + relu_congr_cl_d'length-1),
            scout   => sov(relu_congr_cl_offset to relu_congr_cl_offset + relu_congr_cl_d'length-1),
            din     => relu_congr_cl_d,
            dout    => relu_congr_cl_q);
ex5_lru_upd_reg: tri_rlmreg_p
generic map (width => 7, init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => ex4_stg_act,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex5_lru_upd_offset to ex5_lru_upd_offset + ex5_lru_upd_d'length-1),
            scout   => sov(ex5_lru_upd_offset to ex5_lru_upd_offset + ex5_lru_upd_d'length-1),
            din     => ex5_lru_upd_d,
            dout    => ex5_lru_upd_q);
ex6_lru_upd_reg: tri_regk
generic map (width => 7, init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => ex5_stg_act,
            forcee => func_nsl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_nsl_thold_0_b,
            din     => ex6_lru_upd_d,
            dout    => ex6_lru_upd_q);
rel2_val_reg: tri_rlmlatch_p
generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => tiup,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(rel2_val_offset),
            scout   => sov(rel2_val_offset),
            din     => rel2_val_d,
            dout    => rel2_val_q);
rel2_class_id_reg: tri_regk
generic map (width => 2, init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => rel1_stg_act,
            forcee => func_nsl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_nsl_thold_0_b,
            din     => rel2_class_id_d,
            dout    => rel2_class_id_q);
relu_val_wen_reg: tri_rlmlatch_p
generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => tiup,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(relu_val_wen_offset),
            scout   => sov(relu_val_wen_offset),
            din     => relu_val_wen_d,
            dout    => relu_val_wen_q);
ex4_hit_reg: tri_rlmlatch_p
generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => ex3_stg_act,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex4_hit_offset),
            scout   => sov(ex4_hit_offset),
            din     => ex4_hit_d,
            dout    => ex4_hit_q);
ex4_fxubyp_val_reg: tri_regk
generic map (width => 1, init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => ex3_stg_act,
            forcee => func_nsl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_nsl_thold_0_b,
            din(0)  => ex4_fxubyp_val_d,
            dout(0) => ex4_fxubyp_val_q);
ex4_relbyp_val_reg: tri_regk
generic map (width => 1, init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => ex3_stg_act,
            forcee => func_nsl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_nsl_thold_0_b,
            din(0)  => ex4_relbyp_val_d,
            dout(0) => ex4_relbyp_val_q);
ex4_c_acc_reg: tri_rlmlatch_p
generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => tiup,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex4_c_acc_offset),
            scout   => sov(ex4_c_acc_offset),
            din     => ex4_c_acc_d,
            dout    => ex4_c_acc_q);
ex5_c_acc_reg: tri_rlmlatch_p
generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => tiup,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex5_c_acc_offset),
            scout   => sov(ex5_c_acc_offset),
            din     => ex5_c_acc_d,
            dout    => ex5_c_acc_q);
ex6_c_acc_val_reg: tri_rlmlatch_p
generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => tiup,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex6_c_acc_val_offset),
            scout   => sov(ex6_c_acc_val_offset),
            din     => ex6_c_acc_val_d,
            dout    => ex6_c_acc_val_q);
ex2_congr_cl_reg: tri_regk
generic map (width => 5, init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => ex1_stg_act,
            forcee => func_nsl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_nsl_thold_0_b,
            din     => ex2_congr_cl_d,
            dout    => ex2_congr_cl_q);
ex3_congr_cl_reg: tri_rlmreg_p
generic map (width => 5, init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => ex2_stg_act,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex3_congr_cl_offset to ex3_congr_cl_offset + ex3_congr_cl_d'length-1),
            scout   => sov(ex3_congr_cl_offset to ex3_congr_cl_offset + ex3_congr_cl_d'length-1),
            din     => ex3_congr_cl_d,
            dout    => ex3_congr_cl_q);
rel_val_wen_reg: tri_rlmlatch_p
generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => tiup,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(rel_val_wen_offset),
            scout   => sov(rel_val_wen_offset),
            din     => rel_val_wen_d,
            dout    => rel_val_wen_q);
rel_way_not_empty_reg: tri_regk
generic map (width => 8, init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => rel2_stg_act,
            forcee => func_nsl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_nsl_thold_0_b,
            din     => rel_way_not_empty_d,
            dout    => rel_way_not_empty_q);
relu_lru_upd_reg: tri_rlmreg_p
generic map (width => 7, init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => rel2_stg_act,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(relu_lru_upd_offset to relu_lru_upd_offset + relu_lru_upd_d'length-1),
            scout   => sov(relu_lru_upd_offset to relu_lru_upd_offset + relu_lru_upd_d'length-1),
            din     => relu_lru_upd_d,
            dout    => relu_lru_upd_q);
rel_lru_val_reg: tri_regk
generic map (width => 7, init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => rel3_stg_act,
            forcee => func_nsl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_nsl_thold_0_b,
            din     => rel_lru_val_d,
            dout    => rel_lru_val_q);
rel_upd_congr_cl_reg: tri_regk
generic map (width => 5, init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => rel3_stg_act,
            forcee => func_nsl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_nsl_thold_0_b,
            din     => rel_upd_congr_cl_d,
            dout    => rel_upd_congr_cl_q);
rel_tag_reg: tri_regk
generic map (width => 3, init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => rel1_stg_act,
            forcee => func_nsl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_nsl_thold_0_b,
            din     => rel_tag_d,
            dout    => rel_tag_q);
rel_way_qsel_reg: tri_rlmreg_p
generic map (width => 8, init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => rel1_stg_act,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(rel_way_qsel_offset to rel_way_qsel_offset + rel_way_qsel_d'length-1),
            scout   => sov(rel_way_qsel_offset to rel_way_qsel_offset + rel_way_qsel_d'length-1),
            din     => rel_way_qsel_d,
            dout    => rel_way_qsel_q);
rel_val_qsel_reg: tri_rlmlatch_p
generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => tiup,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(rel_val_qsel_offset),
            scout   => sov(rel_val_qsel_offset),
            din     => rel_val_qsel_d,
            dout    => rel_val_qsel_q);
rel_way_early_qsel_reg: tri_rlmreg_p
generic map (width => 8, init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => tiup,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(rel_way_early_qsel_offset to rel_way_early_qsel_offset + rel_way_early_qsel_d'length-1),
            scout   => sov(rel_way_early_qsel_offset to rel_way_early_qsel_offset + rel_way_early_qsel_d'length-1),
            din     => rel_way_early_qsel_d,
            dout    => rel_way_early_qsel_q);
rel_val_early_qsel_reg: tri_rlmlatch_p
generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => tiup,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(rel_val_early_qsel_offset),
            scout   => sov(rel_val_early_qsel_offset),
            din     => rel_val_early_qsel_d,
            dout    => rel_val_early_qsel_q);
rel4_val_reg: tri_rlmlatch_p
generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => tiup,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(rel4_val_offset),
            scout   => sov(rel4_val_offset),
            din     => rel4_val_d,
            dout    => rel4_val_q);
rel2_mid_val_reg: tri_rlmlatch_p
generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => tiup,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(rel2_mid_val_offset),
            scout   => sov(rel2_mid_val_offset),
            din     => rel2_mid_val_d,
            dout    => rel2_mid_val_q);
rel4_retry_val_reg: tri_rlmlatch_p
generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => tiup,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(rel4_retry_val_offset),
            scout   => sov(rel4_retry_val_offset),
            din     => rel4_retry_val_d,
            dout    => rel4_retry_val_q);
rel2_fxubyp_val_reg: tri_regk
generic map (width => 1, init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => rel1_stg_act,
            forcee => func_nsl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_nsl_thold_0_b,
            din(0)  => rel2_fxubyp_val_d,
            dout(0) => rel2_fxubyp_val_q);
rel2_relbyp_val_reg: tri_regk
generic map (width => 1, init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => rel1_stg_act,
            forcee => func_nsl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_nsl_thold_0_b,
            din(0)  => rel2_relbyp_val_d,
            dout(0) => rel2_relbyp_val_q);
rel2_wlock_reg: tri_rlmreg_p
generic map (width => 8, init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => rel1_stg_act,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(rel2_wlock_offset to rel2_wlock_offset + rel2_wlock_d'length-1),
            scout   => sov(rel2_wlock_offset to rel2_wlock_offset + rel2_wlock_d'length-1),
            din     => rel2_wlock_d,
            dout    => rel2_wlock_q);
reld_q0_congr_cl_reg:   tri_rlmreg_p
generic map (width => 5, init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => rel2_stg_act,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(reld_q0_congr_cl_offset   to reld_q0_congr_cl_offset   + reld_q0_congr_cl_d'length-1),
            scout   => sov(reld_q0_congr_cl_offset   to reld_q0_congr_cl_offset   + reld_q0_congr_cl_d'length-1),
            din     => reld_q0_congr_cl_d,
            dout    => reld_q0_congr_cl_q);
reld_q0_way_reg:   tri_rlmreg_p
generic map (width => 8, init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => rel2_stg_act,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(reld_q0_way_offset   to reld_q0_way_offset   + reld_q0_way_d'length-1),
            scout   => sov(reld_q0_way_offset   to reld_q0_way_offset   + reld_q0_way_d'length-1),
            din     => reld_q0_way_d,
            dout    => reld_q0_way_q);
reld_q0_val_reg:   tri_rlmlatch_p
generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => tiup,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(reld_q0_val_offset),
            scout   => sov(reld_q0_val_offset),
            din     => reld_q0_val_d,
            dout    => reld_q0_val_q);
reld_q0_lock_reg:   tri_rlmlatch_p
generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => tiup,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(reld_q0_lock_offset),
            scout   => sov(reld_q0_lock_offset),
            din     => reld_q0_lock_d,
            dout    => reld_q0_lock_q);
reld_q1_congr_cl_reg:   tri_rlmreg_p
generic map (width => 5, init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => rel2_stg_act,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(reld_q1_congr_cl_offset   to reld_q1_congr_cl_offset   + reld_q1_congr_cl_d'length-1),
            scout   => sov(reld_q1_congr_cl_offset   to reld_q1_congr_cl_offset   + reld_q1_congr_cl_d'length-1),
            din     => reld_q1_congr_cl_d,
            dout    => reld_q1_congr_cl_q);
reld_q1_way_reg:   tri_rlmreg_p
generic map (width => 8, init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => rel2_stg_act,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(reld_q1_way_offset   to reld_q1_way_offset   + reld_q1_way_d'length-1),
            scout   => sov(reld_q1_way_offset   to reld_q1_way_offset   + reld_q1_way_d'length-1),
            din     => reld_q1_way_d,
            dout    => reld_q1_way_q);
reld_q1_val_reg:   tri_rlmlatch_p
generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => tiup,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(reld_q1_val_offset),
            scout   => sov(reld_q1_val_offset),
            din     => reld_q1_val_d,
            dout    => reld_q1_val_q);
reld_q1_lock_reg:   tri_rlmlatch_p
generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => tiup,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(reld_q1_lock_offset),
            scout   => sov(reld_q1_lock_offset),
            din     => reld_q1_lock_d,
            dout    => reld_q1_lock_q);
reld_q2_congr_cl_reg:   tri_rlmreg_p
generic map (width => 5, init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => rel2_stg_act,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(reld_q2_congr_cl_offset   to reld_q2_congr_cl_offset   + reld_q2_congr_cl_d'length-1),
            scout   => sov(reld_q2_congr_cl_offset   to reld_q2_congr_cl_offset   + reld_q2_congr_cl_d'length-1),
            din     => reld_q2_congr_cl_d,
            dout    => reld_q2_congr_cl_q);
reld_q2_way_reg:   tri_rlmreg_p
generic map (width => 8, init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => rel2_stg_act,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(reld_q2_way_offset   to reld_q2_way_offset   + reld_q2_way_d'length-1),
            scout   => sov(reld_q2_way_offset   to reld_q2_way_offset   + reld_q2_way_d'length-1),
            din     => reld_q2_way_d,
            dout    => reld_q2_way_q);
reld_q2_val_reg:   tri_rlmlatch_p
generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => tiup,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(reld_q2_val_offset),
            scout   => sov(reld_q2_val_offset),
            din     => reld_q2_val_d,
            dout    => reld_q2_val_q);
reld_q2_lock_reg:   tri_rlmlatch_p
generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => tiup,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(reld_q2_lock_offset),
            scout   => sov(reld_q2_lock_offset),
            din     => reld_q2_lock_d,
            dout    => reld_q2_lock_q);
reld_q3_congr_cl_reg:   tri_rlmreg_p
generic map (width => 5, init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => rel2_stg_act,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(reld_q3_congr_cl_offset   to reld_q3_congr_cl_offset   + reld_q3_congr_cl_d'length-1),
            scout   => sov(reld_q3_congr_cl_offset   to reld_q3_congr_cl_offset   + reld_q3_congr_cl_d'length-1),
            din     => reld_q3_congr_cl_d,
            dout    => reld_q3_congr_cl_q);
reld_q3_way_reg:   tri_rlmreg_p
generic map (width => 8, init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => rel2_stg_act,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(reld_q3_way_offset   to reld_q3_way_offset   + reld_q3_way_d'length-1),
            scout   => sov(reld_q3_way_offset   to reld_q3_way_offset   + reld_q3_way_d'length-1),
            din     => reld_q3_way_d,
            dout    => reld_q3_way_q);
reld_q3_val_reg:   tri_rlmlatch_p
generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => tiup,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(reld_q3_val_offset),
            scout   => sov(reld_q3_val_offset),
            din     => reld_q3_val_d,
            dout    => reld_q3_val_q);
reld_q3_lock_reg:   tri_rlmlatch_p
generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => tiup,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(reld_q3_lock_offset),
            scout   => sov(reld_q3_lock_offset),
            din     => reld_q3_lock_d,
            dout    => reld_q3_lock_q);
reld_q4_congr_cl_reg:   tri_rlmreg_p
generic map (width => 5, init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => rel2_stg_act,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(reld_q4_congr_cl_offset   to reld_q4_congr_cl_offset   + reld_q4_congr_cl_d'length-1),
            scout   => sov(reld_q4_congr_cl_offset   to reld_q4_congr_cl_offset   + reld_q4_congr_cl_d'length-1),
            din     => reld_q4_congr_cl_d,
            dout    => reld_q4_congr_cl_q);
reld_q4_way_reg:   tri_rlmreg_p
generic map (width => 8, init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => rel2_stg_act,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(reld_q4_way_offset   to reld_q4_way_offset   + reld_q4_way_d'length-1),
            scout   => sov(reld_q4_way_offset   to reld_q4_way_offset   + reld_q4_way_d'length-1),
            din     => reld_q4_way_d,
            dout    => reld_q4_way_q);
reld_q4_val_reg:   tri_rlmlatch_p
generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => tiup,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(reld_q4_val_offset),
            scout   => sov(reld_q4_val_offset),
            din     => reld_q4_val_d,
            dout    => reld_q4_val_q);
reld_q4_lock_reg:   tri_rlmlatch_p
generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => tiup,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(reld_q4_lock_offset),
            scout   => sov(reld_q4_lock_offset),
            din     => reld_q4_lock_d,
            dout    => reld_q4_lock_q);
reld_q5_congr_cl_reg:   tri_rlmreg_p
generic map (width => 5, init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => rel2_stg_act,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(reld_q5_congr_cl_offset   to reld_q5_congr_cl_offset   + reld_q5_congr_cl_d'length-1),
            scout   => sov(reld_q5_congr_cl_offset   to reld_q5_congr_cl_offset   + reld_q5_congr_cl_d'length-1),
            din     => reld_q5_congr_cl_d,
            dout    => reld_q5_congr_cl_q);
reld_q5_way_reg:   tri_rlmreg_p
generic map (width => 8, init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => rel2_stg_act,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(reld_q5_way_offset   to reld_q5_way_offset   + reld_q5_way_d'length-1),
            scout   => sov(reld_q5_way_offset   to reld_q5_way_offset   + reld_q5_way_d'length-1),
            din     => reld_q5_way_d,
            dout    => reld_q5_way_q);
reld_q5_val_reg:   tri_rlmlatch_p
generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => tiup,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(reld_q5_val_offset),
            scout   => sov(reld_q5_val_offset),
            din     => reld_q5_val_d,
            dout    => reld_q5_val_q);
reld_q5_lock_reg:   tri_rlmlatch_p
generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => tiup,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(reld_q5_lock_offset),
            scout   => sov(reld_q5_lock_offset),
            din     => reld_q5_lock_d,
            dout    => reld_q5_lock_q);
reld_q6_congr_cl_reg:   tri_rlmreg_p
generic map (width => 5, init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => rel2_stg_act,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(reld_q6_congr_cl_offset   to reld_q6_congr_cl_offset   + reld_q6_congr_cl_d'length-1),
            scout   => sov(reld_q6_congr_cl_offset   to reld_q6_congr_cl_offset   + reld_q6_congr_cl_d'length-1),
            din     => reld_q6_congr_cl_d,
            dout    => reld_q6_congr_cl_q);
reld_q6_way_reg:   tri_rlmreg_p
generic map (width => 8, init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => rel2_stg_act,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(reld_q6_way_offset   to reld_q6_way_offset   + reld_q6_way_d'length-1),
            scout   => sov(reld_q6_way_offset   to reld_q6_way_offset   + reld_q6_way_d'length-1),
            din     => reld_q6_way_d,
            dout    => reld_q6_way_q);
reld_q6_val_reg:   tri_rlmlatch_p
generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => tiup,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(reld_q6_val_offset),
            scout   => sov(reld_q6_val_offset),
            din     => reld_q6_val_d,
            dout    => reld_q6_val_q);
reld_q6_lock_reg:   tri_rlmlatch_p
generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => tiup,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(reld_q6_lock_offset),
            scout   => sov(reld_q6_lock_offset),
            din     => reld_q6_lock_d,
            dout    => reld_q6_lock_q);
reld_q7_congr_cl_reg:   tri_rlmreg_p
generic map (width => 5, init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => rel2_stg_act,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(reld_q7_congr_cl_offset   to reld_q7_congr_cl_offset   + reld_q7_congr_cl_d'length-1),
            scout   => sov(reld_q7_congr_cl_offset   to reld_q7_congr_cl_offset   + reld_q7_congr_cl_d'length-1),
            din     => reld_q7_congr_cl_d,
            dout    => reld_q7_congr_cl_q);
reld_q7_way_reg:   tri_rlmreg_p
generic map (width => 8, init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => rel2_stg_act,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(reld_q7_way_offset   to reld_q7_way_offset   + reld_q7_way_d'length-1),
            scout   => sov(reld_q7_way_offset   to reld_q7_way_offset   + reld_q7_way_d'length-1),
            din     => reld_q7_way_d,
            dout    => reld_q7_way_q);
reld_q7_val_reg:   tri_rlmlatch_p
generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => tiup,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(reld_q7_val_offset),
            scout   => sov(reld_q7_val_offset),
            din     => reld_q7_val_d,
            dout    => reld_q7_val_q);
reld_q7_lock_reg:   tri_rlmlatch_p
generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => tiup,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(reld_q7_lock_offset),
            scout   => sov(reld_q7_lock_offset),
            din     => reld_q7_lock_d,
            dout    => reld_q7_lock_q);
rel_m_q_way_reg: tri_rlmreg_p
generic map (width => 8, init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => tiup,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(rel_m_q_way_offset to rel_m_q_way_offset + rel_m_q_way_d'length-1),
            scout   => sov(rel_m_q_way_offset to rel_m_q_way_offset + rel_m_q_way_d'length-1),
            din     => rel_m_q_way_d,
            dout    => rel_m_q_way_q);
ex3_no_lru_upd_reg: tri_rlmlatch_p
generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => ex2_stg_act,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex3_no_lru_upd_offset),
            scout   => sov(ex3_no_lru_upd_offset),
            din     => ex3_no_lru_upd_d,
            dout    => ex3_no_lru_upd_q);
rel2_lock_en_reg: tri_rlmlatch_p
generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => rel1_stg_act,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(rel2_lock_en_offset),
            scout   => sov(rel2_lock_en_offset),
            din     => rel2_lock_en_d,
            dout    => rel2_lock_en_q);
xucr0_clo_reg: tri_rlmlatch_p
generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => tiup,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(xucr0_clo_offset),
            scout   => sov(xucr0_clo_offset),
            din     => xucr0_clo_d,
            dout    => xucr0_clo_q);
rel_up_way_addr_reg: tri_rlmreg_p
generic map (width => 3, init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => rel2_stg_act,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(rel_up_way_addr_offset to rel_up_way_addr_offset + rel_up_way_addr_d'length-1),
            scout   => sov(rel_up_way_addr_offset to rel_up_way_addr_offset + rel_up_way_addr_d'length-1),
            din     => rel_up_way_addr_d,
            dout    => rel_up_way_addr_q);
rel24_way_dwen_stg_reg: tri_regk
generic map (width => 8, init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => rel2_stg_act,
            forcee => func_nsl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_nsl_thold_0_b,
            din     => rel24_way_dwen_stg_d,
            dout    => rel24_way_dwen_stg_q);
rel_dcarr_addr_en_reg: tri_rlmlatch_p
generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => tiup,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(rel_dcarr_addr_en_offset),
            scout   => sov(rel_dcarr_addr_en_offset),
            din     => rel_dcarr_addr_en_d,
            dout    => rel_dcarr_addr_en_q);
rel_dcarr_val_upd_reg: tri_rlmlatch_p
generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => tiup,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(rel_dcarr_val_upd_offset),
            scout   => sov(rel_dcarr_val_upd_offset),
            din     => rel_dcarr_val_upd_d,
            dout    => rel_dcarr_val_upd_q);
congr_cl_ex3_ex4_cmp_reg: tri_rlmlatch_p
generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => tiup,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(congr_cl_ex3_ex4_cmp_offset),
            scout   => sov(congr_cl_ex3_ex4_cmp_offset),
            din     => congr_cl_ex3_ex4_cmp_d,
            dout    => congr_cl_ex3_ex4_cmp_q);
congr_cl_ex3_ex5_cmp_reg: tri_rlmlatch_p
generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => tiup,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(congr_cl_ex3_ex5_cmp_offset),
            scout   => sov(congr_cl_ex3_ex5_cmp_offset),
            din     => congr_cl_ex3_ex5_cmp_d,
            dout    => congr_cl_ex3_ex5_cmp_q);
congr_cl_ex3_ex6_cmp_reg: tri_rlmlatch_p
generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => tiup,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(congr_cl_ex3_ex6_cmp_offset),
            scout   => sov(congr_cl_ex3_ex6_cmp_offset),
            din     => congr_cl_ex3_ex6_cmp_d,
            dout    => congr_cl_ex3_ex6_cmp_q);
congr_cl_ex3_rel2_cmp_reg: tri_rlmlatch_p
generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => tiup,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(congr_cl_ex3_rel2_cmp_offset),
            scout   => sov(congr_cl_ex3_rel2_cmp_offset),
            din     => congr_cl_ex3_rel2_cmp_d,
            dout    => congr_cl_ex3_rel2_cmp_q);
congr_cl_ex3_rel_upd_cmp_reg: tri_rlmlatch_p
generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => tiup,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(congr_cl_ex3_rel_upd_cmp_offset),
            scout   => sov(congr_cl_ex3_rel_upd_cmp_offset),
            din     => congr_cl_ex3_rel_upd_cmp_d,
            dout    => congr_cl_ex3_rel_upd_cmp_q);
congr_cl_rel1_ex4_cmp_reg: tri_rlmlatch_p
generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => tiup,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(congr_cl_rel1_ex4_cmp_offset),
            scout   => sov(congr_cl_rel1_ex4_cmp_offset),
            din     => congr_cl_rel1_ex4_cmp_d,
            dout    => congr_cl_rel1_ex4_cmp_q);
congr_cl_rel1_ex5_cmp_reg: tri_rlmlatch_p
generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => tiup,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(congr_cl_rel1_ex5_cmp_offset),
            scout   => sov(congr_cl_rel1_ex5_cmp_offset),
            din     => congr_cl_rel1_ex5_cmp_d,
            dout    => congr_cl_rel1_ex5_cmp_q);
congr_cl_rel1_ex6_cmp_reg: tri_rlmlatch_p
generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => tiup,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(congr_cl_rel1_ex6_cmp_offset),
            scout   => sov(congr_cl_rel1_ex6_cmp_offset),
            din     => congr_cl_rel1_ex6_cmp_d,
            dout    => congr_cl_rel1_ex6_cmp_q);
congr_cl_rel1_rel2_cmp_reg: tri_rlmlatch_p
generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => tiup,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(congr_cl_rel1_rel2_cmp_offset),
            scout   => sov(congr_cl_rel1_rel2_cmp_offset),
            din     => congr_cl_rel1_rel2_cmp_d,
            dout    => congr_cl_rel1_rel2_cmp_q);
congr_cl_rel1_relu_cmp_reg: tri_rlmlatch_p
generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => tiup,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(congr_cl_rel1_relu_cmp_offset),
            scout   => sov(congr_cl_rel1_relu_cmp_offset),
            din     => congr_cl_rel1_relu_cmp_d,
            dout    => congr_cl_rel1_relu_cmp_q);
congr_cl_rel1_rel_upd_cmp_reg: tri_rlmlatch_p
generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => tiup,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(congr_cl_rel1_rel_upd_cmp_offset),
            scout   => sov(congr_cl_rel1_rel_upd_cmp_offset),
            din     => congr_cl_rel1_rel_upd_cmp_d,
            dout    => congr_cl_rel1_rel_upd_cmp_q);
congr_cl_act_reg: tri_rlmlatch_p
generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => tiup,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(congr_cl_act_offset),
            scout   => sov(congr_cl_act_offset),
            din     => congr_cl_act_d,
            dout    => congr_cl_act_q);
siv(0 TO scan_right) <=  sov(1 to scan_right) & scan_in;
scan_out  <=  sov(0);
END XUQ_LSU_DIR_LRU16;

