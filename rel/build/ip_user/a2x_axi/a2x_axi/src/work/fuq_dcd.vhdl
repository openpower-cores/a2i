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


library IEEE,ibm,clib;
use IEEE.STD_LOGIC_1164.all;

use ibm.std_ulogic_function_support.all;
use ibm.std_ulogic_support.all;
library support; 
use support.power_logic_pkg.all;


library tri;  use tri.tri_latches_pkg.all;

entity fuq_dcd is
generic(
     expand_type                    : integer := 2 ;  
     eff_ifar                       : integer := 62;
     regmode                        : integer := 6);  
port( 
     nclk                           : in  clk_logic;
     clkoff_b                       : in  std_ulogic; 
     act_dis                        : in  std_ulogic; 
     flush                          : in  std_ulogic; 
     delay_lclkr                    : in  std_ulogic_vector(0 to 9); 
     mpw1_b                         : in  std_ulogic_vector(0 to 9); 
     mpw2_b                         : in  std_ulogic_vector(0 to 1); 
     thold_1                        : in  std_ulogic;
     cfg_sl_thold_1                 : in  std_ulogic;
     func_slp_sl_thold_1            : in  std_ulogic;

     sg_1                           : in  std_ulogic;
     f_dcd_si                       : in  std_ulogic;
     f_dcd_so                       : out std_ulogic;
     dcfg_scan_in                   : in std_ulogic;
     dcfg_scan_out                  : out std_ulogic;
     bcfg_scan_in                   : in std_ulogic;
     bcfg_scan_out                  : out std_ulogic;
     ccfg_scan_in                   : in std_ulogic;
     ccfg_scan_out                  : out std_ulogic;
     vdd                            : inout power_logic;
     gnd                            : inout power_logic;
     f_dcd_msr_fp_act               : out std_ulogic;
     fu_xu_rf1_act                  : out std_ulogic_vector(0 to 3);

     iu_fu_rf0_instr_v              : in  std_ulogic;
     iu_fu_rf0_instr                : in  std_ulogic_vector(0 to 31);
     iu_fu_rf0_fra_v                : in  std_ulogic;
     iu_fu_rf0_frb_v                : in  std_ulogic;
     iu_fu_rf0_frc_v                : in  std_ulogic;
     iu_fu_rf0_tid                  : in  std_ulogic_vector(0 to 1);
     iu_fu_rf0_fra                  : in  std_ulogic_vector(0 to 6);
     iu_fu_rf0_frb                  : in  std_ulogic_vector(0 to 6);
     iu_fu_rf0_frc                  : in  std_ulogic_vector(0 to 6);
     iu_fu_rf0_frt                  : in  std_ulogic_vector(0 to 6);
     iu_fu_rf0_ifar                 : in  std_ulogic_vector(62-eff_ifar to 61);
     iu_fu_rf0_str_val              : in  std_ulogic;
     iu_fu_rf0_ldst_val             : in  std_ulogic;
     iu_fu_rf0_ldst_tid             : in  std_ulogic_vector(0 to 1);
     iu_fu_rf0_ldst_tag             : in  std_ulogic_vector(0 to 8);
     iu_fu_rf0_bypsel               : in  std_ulogic_vector(0 to 5);
     iu_fu_rf0_instr_match          : in  std_ulogic;
     iu_fu_rf0_is_ucode             : in  std_ulogic;
     iu_fu_rf0_ucfmul               : in  std_ulogic;
     iu_fu_is2_tid_decode           : in  std_ulogic_vector(0 to 3);
     iu_fu_ex2_n_flush              : in  std_ulogic_vector(0 to 3);

     f_fpr_ex7_load_addr            : in  std_ulogic_vector(0 to 7);
     f_fpr_ex7_load_v               : in  std_ulogic;
     xu_is2_flush                   : in  std_ulogic_vector(0 to 3);
     xu_rf0_flush                   : in  std_ulogic_vector(0 to 3);
     xu_rf1_flush                   : in  std_ulogic_vector(0 to 3);
     xu_ex1_flush                   : in  std_ulogic_vector(0 to 3);
     xu_ex2_flush                   : in  std_ulogic_vector(0 to 3);
     xu_ex3_flush                   : in  std_ulogic_vector(0 to 3);
     xu_ex4_flush                   : in  std_ulogic_vector(0 to 3);
     xu_ex5_flush                   : in  std_ulogic_vector(0 to 3);
     f_dcd_ex5_flush_int            : out std_ulogic_vector(0 to 3);       
     xu_fu_ex5_reload_val           : in  std_ulogic;
     xu_fu_ex5_load_val             : in  std_ulogic_vector(0 to 3);

     f_dcd_perr_sm_running          : out std_ulogic;

        f_scr_ex7_cr_fld            : in  std_ulogic_vector (0 to 3)     ;
        f_add_ex4_fpcc_iu           : in  std_ulogic_vector (0 to 3)     ;
        f_pic_ex5_fpr_wr_dis_b      : in  std_ulogic                     ;
        f_dcd_rf1_aop_valid         : out std_ulogic;
        f_dcd_rf1_cop_valid         : out std_ulogic;
        f_dcd_rf1_bop_valid         : out std_ulogic;
        f_dcd_rf1_sp                : out std_ulogic; 
        f_dcd_rf1_emin_dp           : out std_ulogic;                 
        f_dcd_rf1_emin_sp           : out std_ulogic;                 
        f_dcd_rf1_force_pass_b      : out std_ulogic;                 

        f_dcd_rf1_fsel_b            : out std_ulogic;                 
        f_dcd_rf1_from_integer_b    : out std_ulogic;                 
        f_dcd_rf1_to_integer_b      : out std_ulogic;                 
        f_dcd_rf1_rnd_to_int_b      : out std_ulogic;                 
        f_dcd_rf1_math_b            : out std_ulogic;                 
        f_dcd_rf1_est_recip_b       : out std_ulogic;                 
        f_dcd_rf1_est_rsqrt_b       : out std_ulogic;                 
        f_dcd_rf1_move_b            : out std_ulogic;                 
        f_dcd_rf1_prenorm_b         : out std_ulogic;                 
        f_dcd_rf1_frsp_b            : out std_ulogic;                 
        f_dcd_rf1_compare_b         : out std_ulogic;                 
        f_dcd_rf1_ordered_b         : out std_ulogic;                 

        f_dcd_rf1_force_excp_dis    : out std_ulogic;                 
        f_dcd_rf1_nj_deni           : out std_ulogic;                 
        f_dcd_rf1_nj_deno           : out std_ulogic;                 
        f_dcd_rf1_sp_conv_b         : out std_ulogic;                 
        f_dcd_rf1_uns_b             : out std_ulogic;                 

        f_dcd_rf1_word_b            : out std_ulogic;                 
        f_dcd_rf1_sub_op_b          : out std_ulogic;                 
        f_dcd_rf1_op_rnd_v_b        : out std_ulogic;                 
        f_dcd_rf1_op_rnd_b          : out std_ulogic_vector(0 to 1);  
        f_dcd_rf1_inv_sign_b        : out std_ulogic;                 
        f_dcd_rf1_sign_ctl_b        : out std_ulogic_vector(0 to 1);  
        f_dcd_rf1_sgncpy_b          : out std_ulogic;                 
        
        f_dcd_rf1_fpscr_bit_data_b  : out std_ulogic_vector(0 to 3);  
        f_dcd_rf1_fpscr_bit_mask_b  : out std_ulogic_vector(0 to 3);  
        f_dcd_rf1_fpscr_nib_mask_b  : out std_ulogic_vector(0 to 8);  
        f_dcd_rf1_mv_to_scr_b       : out std_ulogic;                 
        f_dcd_rf1_mv_from_scr_b     : out std_ulogic;                 
        f_dcd_rf1_mtfsbx_b          : out std_ulogic;                 
        f_dcd_rf1_mcrfs_b           : out std_ulogic;                 
        f_dcd_rf1_mtfsf_b           : out std_ulogic;                 
        f_dcd_rf1_mtfsfi_b          : out std_ulogic;                 
        f_dcd_rf1_thread_b          : out std_ulogic_vector(0 to 3);
        f_dcd_rf1_sto_dp            : out std_ulogic                    ;
        f_dcd_rf1_sto_sp            : out std_ulogic                    ;
        f_dcd_rf1_sto_wd            : out std_ulogic                    ;
        f_dcd_rf1_log2e_b           : out std_ulogic                    ;
        f_dcd_rf1_pow2e_b           : out std_ulogic                    ;
        f_dcd_rf1_ftdiv             : out std_ulogic                    ;
        f_dcd_rf1_ftsqrt            : out std_ulogic                    ;
        f_dcd_rf1_mad_act           : out std_ulogic                    ;
        f_dcd_rf1_sto_act           : out std_ulogic                    ;
        f_dcd_ex6_cancel            : out std_ulogic                    ;
     f_dcd_rf1_bypsel_a_res0        : out std_ulogic;
     f_dcd_rf1_bypsel_a_load0       : out std_ulogic;
     f_dcd_rf1_bypsel_b_res0        : out std_ulogic;
     f_dcd_rf1_bypsel_b_load0       : out std_ulogic;
     f_dcd_rf1_bypsel_c_res0        : out std_ulogic;
     f_dcd_rf1_bypsel_c_load0       : out std_ulogic;
     f_dcd_rf0_bypsel_a_res1        : out std_ulogic;
     f_dcd_rf0_bypsel_b_res1        : out std_ulogic;
     f_dcd_rf0_bypsel_c_res1        : out std_ulogic;
     f_dcd_rf0_bypsel_s_res1        : out std_ulogic;
     f_dcd_rf0_bypsel_a_load1       : out std_ulogic;
     f_dcd_rf0_bypsel_b_load1       : out std_ulogic;
     f_dcd_rf0_bypsel_c_load1       : out std_ulogic;
     f_dcd_rf0_bypsel_s_load1       : out std_ulogic;
     f_dcd_ex1_perr_force_c         : out std_ulogic;
     f_dcd_ex1_perr_fsel_ovrd       : out std_ulogic;

     slowspr_val_in                 : in  std_ulogic;
     slowspr_rw_in                  : in  std_ulogic;
     slowspr_etid_in                : in  std_ulogic_vector(0 to 1);
     slowspr_addr_in                : in  std_ulogic_vector(0 to 9);
     slowspr_data_in                : in  std_ulogic_vector(64-(2**regmode) to 63);
     slowspr_done_in                : in  std_ulogic;
     slowspr_val_out                : out std_ulogic;
     slowspr_rw_out                 : out std_ulogic;
     slowspr_etid_out               : out std_ulogic_vector(0 to 1);
     slowspr_addr_out               : out std_ulogic_vector(0 to 9);
     slowspr_data_out               : out std_ulogic_vector(64-(2**regmode) to 63);
     slowspr_done_out               : out std_ulogic;
     pc_fu_trace_bus_enable         : in  std_ulogic;
     pc_fu_event_bus_enable         : in  std_ulogic;
     pc_fu_debug_mux_ctrls          : in  std_ulogic_vector(0 to 15);
     pc_fu_event_count_mode         : in  std_ulogic_vector(0 to 2);
     pc_fu_event_mux_ctrls          : in  std_ulogic_vector(0 to 31);
     debug_data_in                  : in  std_ulogic_vector(0 to 87);
     debug_data_out                 : out std_ulogic_vector(0 to 87);
     trace_triggers_in              : in  std_ulogic_vector(0 to 11);
     trace_triggers_out             : out std_ulogic_vector(0 to 11);
     fu_pc_event_data               : out std_ulogic_vector(0 to 7);
     f_rnd_ex6_res_expo             : in  std_ulogic_vector (1 to 13);
     f_rnd_ex6_res_frac             : in  std_ulogic_vector (0 to 52);
     f_rnd_ex6_res_sign             : in  std_ulogic ;
     pc_fu_ram_mode                 : in  std_ulogic;
     pc_fu_ram_thread               : in  std_ulogic_vector(0 to 1);
     fu_pc_ram_done                 : out std_ulogic;
     fu_pc_ram_data                 : out std_ulogic_vector(0 to 63);
     f_sto_ex2_s_parity_check       : in  std_ulogic;
     f_mad_ex2_a_parity_check       : in  std_ulogic;
     f_mad_ex2_b_parity_check       : in  std_ulogic;
     f_mad_ex2_c_parity_check       : in  std_ulogic;
     fu_pc_err_regfile_parity       : out std_ulogic_vector(0 to 3);
     fu_pc_err_regfile_ue           : out std_ulogic_vector(0 to 3);
     fu_xu_ex3_regfile_err_det      : out std_ulogic_vector(0 to 3);
     xu_fu_regfile_seq_beg          : in  std_ulogic;
     fu_xu_regfile_seq_end          : out std_ulogic;
     fu_xu_ex2_async_block          : out std_ulogic_vector(0 to 3);

     xu_fu_msr_fp                   : in  std_ulogic_vector(0 to 3);
     xu_fu_msr_pr                   : in  std_ulogic_vector(0 to 3);
     xu_fu_msr_gs                   : in  std_ulogic_vector(0 to 3);
     pc_fu_instr_trace_mode         : in  std_ulogic;
     pc_fu_instr_trace_tid          : in  std_ulogic_vector(0 to 1);

     f_dcd_ex6_frt_addr             : out std_ulogic_vector(0 to 5);
     f_dcd_ex6_frt_tid              : out std_ulogic_vector(0 to 1);
     f_dcd_ex5_frt_tid              : out std_ulogic_vector(0 to 1);
     f_dcd_ex6_frt_wen              : out std_ulogic;
     fu_xu_ex2_store_data_val       : out std_ulogic;
     fu_xu_ex4_cr                   : out std_ulogic_vector(0 to 3);               
     fu_xu_ex4_cr_val               : out std_ulogic_vector(0 to 3);               
     fu_xu_ex4_cr_bf                : out std_ulogic_vector(0 to 2);
     fu_xu_ex4_cr_noflush           : out std_ulogic_vector(0 to 3);
     f_scr_ex7_fx_thread0           : in  std_ulogic_vector(0 to 3);
     f_scr_ex7_fx_thread1           : in  std_ulogic_vector(0 to 3);
     f_scr_ex7_fx_thread2           : in  std_ulogic_vector(0 to 3);
     f_scr_ex7_fx_thread3           : in  std_ulogic_vector(0 to 3);
     f_dcd_rf0_tid                  : out std_ulogic_vector(0 to 1);
     f_dcd_rf0_fra                  : out std_ulogic_vector(0 to 5);
     f_dcd_rf0_frb                  : out std_ulogic_vector(0 to 5);
     f_dcd_rf0_frc                  : out std_ulogic_vector(0 to 5);
     f_dcd_rf1_div_beg              : out std_ulogic;                 
     f_dcd_rf1_sqrt_beg             : out std_ulogic;                 
     f_dcd_rf1_uc_ft_pos            : out std_ulogic;
     f_dcd_rf1_uc_ft_neg            : out std_ulogic;
     f_dcd_rf1_uc_fa_pos            : out std_ulogic;
     f_dcd_rf1_uc_fc_pos            : out std_ulogic;
     f_dcd_rf1_uc_fb_pos            : out std_ulogic;
     f_dcd_rf1_uc_fc_hulp           : out std_ulogic;
     f_dcd_rf1_uc_fc_0_5            : out std_ulogic;
     f_dcd_rf1_uc_fc_1_0            : out std_ulogic;
     f_dcd_rf1_uc_fc_1_minus        : out std_ulogic;
     f_dcd_rf1_uc_fb_1_0            : out std_ulogic;
     f_dcd_rf1_uc_fb_0_75           : out std_ulogic;
     f_dcd_rf1_uc_fb_0_5            : out std_ulogic;
     f_dcd_ex2_uc_inc_lsb           : out std_ulogic;
     f_dcd_rf1_uc_mid               : out std_ulogic;
     f_dcd_rf1_uc_end               : out std_ulogic;
     fu_iu_uc_special               : out std_ulogic_vector(0 to 3);
     f_dcd_rf1_uc_special           : out std_ulogic;
     f_dcd_ex2_uc_gs_v              : out std_ulogic;
     f_dcd_ex2_uc_gs                : out std_ulogic_vector(0 to 1);
     f_dcd_ex2_uc_vxsnan            : out std_ulogic;                  
     f_dcd_ex2_uc_zx                : out std_ulogic;
     f_dcd_ex2_uc_vxidi             : out std_ulogic;
     f_dcd_ex2_uc_vxzdz             : out std_ulogic;
     f_dcd_ex2_uc_vxsqrt            : out std_ulogic;
     f_mad_ex6_uc_sign              : in  std_ulogic;
     f_mad_ex6_uc_zero              : in  std_ulogic;
     f_mad_ex3_uc_special           : in  std_ulogic;
     f_mad_ex3_uc_vxsnan            : in  std_ulogic;                  
     f_mad_ex3_uc_zx                : in  std_ulogic;
     f_mad_ex3_uc_vxidi             : in  std_ulogic;
     f_mad_ex3_uc_vxzdz             : in  std_ulogic;
     f_mad_ex3_uc_vxsqrt            : in  std_ulogic;
     f_mad_ex3_uc_res_sign          : in  std_ulogic;
     f_mad_ex3_uc_round_mode        : in  std_ulogic_vector(0 to 1);

     f_ex2_b_den_flush              : in  std_ulogic;
     xu_fu_ex3_eff_addr             : in  std_ulogic_vector(59 to 63);
     fu_xu_ex3_n_flush              : out std_ulogic_vector(0 to 3);
     fu_xu_ex3_np1_flush            : out std_ulogic_vector(0 to 3);
     fu_xu_ex3_ap_int_req           : out std_ulogic_vector(0 to 3);
     fu_xu_ex3_flush2ucode          : out std_ulogic_vector(0 to 3);
     fu_xu_ex2_instr_type           : out std_ulogic_vector(0 to 11);
     fu_xu_ex2_instr_match          : out std_ulogic_vector(0 to 3);
     fu_xu_ex2_is_ucode             : out std_ulogic_vector(0 to 3);
     fu_xu_ex3_trap                 : out std_ulogic_vector(0 to 3);
     fu_xu_ex2_ifar_val             : out std_ulogic_vector(0 to 3);
     fu_xu_ex2_ifar_issued          : out std_ulogic_vector(0 to 3);
     fu_xu_ex1_ifar                 : out std_ulogic_vector(62-eff_ifar to 61)
);
     -- synopsys translate_off

     -- synopsys translate_on

end fuq_dcd;

architecture fuq_dcd of fuq_dcd is




signal  tilo                           : std_ulogic;
signal  tihi                           : std_ulogic;
signal  tilo_out                       : std_ulogic;
signal  tihi_out                       : std_ulogic;

signal  thold_0                        : std_ulogic;
signal  thold_0_b                      : std_ulogic;
signal  sg_0                           : std_ulogic;
signal  forcee                          : std_ulogic;
signal  cfg_sl_thold_0                 : std_ulogic;
signal  cfg_sl_thold_0_b               : std_ulogic;
signal  cfg_sl_force                   : std_ulogic;
signal  func_slp_sl_thold_0            : std_ulogic;
signal  func_slp_sl_force              : std_ulogic;
signal  func_slp_sl_thold_0_b          : std_ulogic;

signal  rf0_str_v                      : std_ulogic;
signal  rf0_ldst_valid                 : std_ulogic_vector(0 to 3);
signal  rf0_str_tag                    : std_ulogic_vector(0 to 1);
signal  rf0_instr_valid                : std_ulogic_vector(0 to 3);
signal  rf0_instr_fra                  : std_ulogic_vector(0 to 5);
signal  rf0_instr_frb                  : std_ulogic_vector(0 to 5);
signal  rf0_instr_frc                  : std_ulogic_vector(0 to 5);
signal  rf0_instr_frs                  : std_ulogic_vector(0 to 5);
signal  rf0_instr_frt                  : std_ulogic_vector(0 to 5);
signal  rf0_instr_tid_1hot             : std_ulogic_vector(0 to 3);
signal  thread_id_rf0                  : std_ulogic_vector(0 to 3);
signal  rf0_thread_so, rf0_thread_si   :std_ulogic_vector(0 to 3);
signal  rf0_tid                        : std_ulogic_vector(0 to 1);
signal  rf0_bypsel                     : std_ulogic_vector(0 to 5);
signal  rf0_bypsel_a_res0              : std_ulogic;
signal  rf0_bypsel_b_res0              : std_ulogic;
signal  rf0_bypsel_c_res0              : std_ulogic;
signal  rf0_bypsel_a_load0             : std_ulogic;
signal  rf0_bypsel_b_load0             : std_ulogic;
signal  rf0_bypsel_c_load0             : std_ulogic;
signal  rf0_bypsel_a_res1              : std_ulogic;
signal  rf0_bypsel_b_res1              : std_ulogic;
signal  rf0_bypsel_s_res1              : std_ulogic;
signal  rf0_bypsel_c_res1              : std_ulogic;
signal  rf0_bypsel_a_load1             : std_ulogic;
signal  rf0_bypsel_b_load1             : std_ulogic;
signal  rf0_bypsel_c_load1             : std_ulogic;
signal  rf0_bypsel_s_load1             : std_ulogic;
signal  rf0_instr_match                : std_ulogic;
signal  rf0_is_ucode                   : std_ulogic;
signal  rf0_frs_byp                    : std_ulogic;
 
signal  xu_ex5_flush_int               : std_ulogic_vector(0 to 3);

signal  ex5_reload_val_b                 : std_ulogic_vector(0 to 3);
     
signal  rf1_v                          : std_ulogic;
signal  rf1_axu_v                      : std_ulogic;
signal  rf1_instr_v                    : std_ulogic_vector(0 to 3);
signal  rf1_tid                        : std_ulogic_vector(0 to 1);
signal  rf1_instr_valid                : std_ulogic_vector(0 to 3);
signal  rf1_instr                      : std_ulogic_vector(0 to 31);
signal  rf1_instr_fra_v                : std_ulogic;
signal  rf1_instr_frb_v                : std_ulogic;
signal  rf1_instr_frc_v                : std_ulogic;
signal  rf1_instr_frt                  : std_ulogic_vector(0 to 5);
signal  rf1_instr_fra                  : std_ulogic_vector(0 to 5);
signal  rf1_instr_frb                  : std_ulogic_vector(0 to 5);
signal  rf1_instr_frc                  : std_ulogic_vector(0 to 5);
signal  rf1_instr_frs                  : std_ulogic_vector(0 to 5);
signal  rf1_instr_ifar                 : std_ulogic_vector(62-eff_ifar to 61);
signal  rf1_str_v                      : std_ulogic;
signal  rf1_ldst_v                     : std_ulogic_vector(0 to 3);
signal  rf1_ldst_valid                 : std_ulogic_vector(0 to 3);
signal  rf1_str_tag                    : std_ulogic_vector(0 to 1);
signal  rf1_bypsel_a_res0              : std_ulogic;
signal  rf1_bypsel_b_res0              : std_ulogic;
signal  rf1_bypsel_c_res0              : std_ulogic;
signal  rf1_bypsel_a_load0             : std_ulogic;
signal  rf1_bypsel_b_load0             : std_ulogic;
signal  rf1_bypsel_c_load0             : std_ulogic;
signal  rf1_bypsel_a_res1              : std_ulogic;
signal  rf1_bypsel_b_res1              : std_ulogic;
signal  rf1_bypsel_c_res1              : std_ulogic;
signal  rf1_bypsel_a_load1             : std_ulogic;
signal  rf1_bypsel_b_load1             : std_ulogic;
signal  rf1_bypsel_c_load1             : std_ulogic;
signal  rf1_frs_byp                    : std_ulogic;

signal  rf1_primary                    : std_ulogic_vector(0 to 5);
signal  rf1_sec_xform                  : std_ulogic_vector(0 to 9);
signal  rf1_sec_aform                  : std_ulogic_vector(0 to 4);
signal  rf1_dp                         : std_ulogic;
signal  rf1_sp                         : std_ulogic;
signal  rf1_dporsp                     : std_ulogic;
signal  rf1_fcfid                      : std_ulogic;
signal  rf1_fcfidu                     : std_ulogic;
signal  rf1_fcfids                     : std_ulogic;
signal  rf1_fcfidus                    : std_ulogic;
signal  rf1_fcfiwu                     : std_ulogic;
signal  rf1_fcfiwus                    : std_ulogic;
signal  rf1_fctid                      : std_ulogic;
signal  rf1_fctidu                     : std_ulogic;
signal  rf1_fctidz                     : std_ulogic;
signal  rf1_fctiduz                    : std_ulogic;
signal  rf1_frim                       : std_ulogic;
signal  rf1_frin                       : std_ulogic;
signal  rf1_frip                       : std_ulogic;
signal  rf1_friz                       : std_ulogic;
signal  rf1_frsp                       : std_ulogic;
signal  rf1_fmr                        : std_ulogic;
signal  rf1_fneg                       : std_ulogic;
signal  rf1_fabs                       : std_ulogic;
signal  rf1_fnabs                      : std_ulogic;
signal  rf1_fsel                       : std_ulogic;
signal  rf1_frsqrte                    : std_ulogic;
signal  rf1_fres                       : std_ulogic;
signal  rf1_fctiw                      : std_ulogic;
signal  rf1_fctiwu                     : std_ulogic;
signal  rf1_fctiwz                     : std_ulogic;
signal  rf1_fctiwuz                    : std_ulogic;
signal  rf1_fcmpu                      : std_ulogic;
signal  rf1_fcmpo                      : std_ulogic;
signal  rf1_fcpsgn                     : std_ulogic;
signal  rf1_fadd                       : std_ulogic;
signal  rf1_fsub                       : std_ulogic;
signal  rf1_fmul                       : std_ulogic;
signal  rf1_fmadd                      : std_ulogic;
signal  rf1_fmsub                      : std_ulogic;
signal  rf1_fnmadd                     : std_ulogic;
signal  rf1_fnmsub                     : std_ulogic;
signal  rf1_mffs                       : std_ulogic;
signal  rf1_mcrfs                      : std_ulogic;
signal  rf1_mtfsfi                     : std_ulogic;
signal  rf1_mtfsf                      : std_ulogic;
signal  rf1_mtfsb0                     : std_ulogic;
signal  rf1_mtfsb1                     : std_ulogic;
signal  rf1_cr_val                     : std_ulogic;
signal  ex1_cr_val_din                 : std_ulogic;
signal  rf1_record                     : std_ulogic;
signal  rf1_moves                      : std_ulogic;
signal  rf1_to_ints                    : std_ulogic;
signal  rf1_from_ints                  : std_ulogic;
signal  rf1_fpscr_moves                : std_ulogic;
signal  rf1_mtfsb_bt                   : std_ulogic_vector(0 to 3);
signal  rf1_mtfs_bf                    : std_ulogic_vector(0 to 7);
signal  rf1_mcrfs_bfa                  : std_ulogic_vector(0 to 7);
signal  rf1_mtfsf_nib                  : std_ulogic_vector(0 to 7);
signal  rf1_mtfsf_l                    : std_ulogic;
signal  rf1_mtfsf_w                    : std_ulogic;
signal  rf1_fpscr_bit_data             : std_ulogic_vector(0 to 3);
signal  rf1_fpscr_bit_mask             : std_ulogic_vector(0 to 3);
signal  rf1_fpscr_nib_mask             : std_ulogic_vector(0 to 8);
signal  rf1_loge                       : std_ulogic;
signal  rf1_expte                      : std_ulogic;
signal  rf1_ftdiv                      : std_ulogic;
signal  rf1_ftsqrt                     : std_ulogic;
signal  rf1_rnd0                       : std_ulogic;
signal  rf1_rnd1                       : std_ulogic;
signal  rf1_kill_wen                   : std_ulogic;
signal  rf1_instr_match                : std_ulogic;
signal  rf1_is_ucode                   : std_ulogic;
signal  rf1_prenorm                    : std_ulogic;
signal  rf1_div_beg                    : std_ulogic;
signal  rf1_sqrt_beg                   : std_ulogic;
signal  rf1_divsqrt_beg                : std_ulogic;
signal  rf1_fra_v                      : std_ulogic;
signal  rf1_frb_v                      : std_ulogic;
signal  rf1_frc_v                      : std_ulogic;
signal  rf1_byp_a                      : std_ulogic;
signal  rf1_byp_b                      : std_ulogic;
signal  rf1_byp_c                      : std_ulogic;
signal  rf1_uc_end                     : std_ulogic;
signal  f_dcd_rf1_uc_fa_dis_par        : std_ulogic;
signal  f_dcd_rf1_uc_fb_dis_par        : std_ulogic;
signal  f_dcd_rf1_uc_fc_dis_par        : std_ulogic;

signal  ex1_v                          : std_ulogic;
signal  ex1_axu_v                      : std_ulogic;
signal  ex1_instr_v                    : std_ulogic_vector(0 to 3);
signal  ex1_instr_valid                : std_ulogic_vector(0 to 3);
signal  ex1_instr_frt                  : std_ulogic_vector(0 to 5);
signal  ex1_str_v                      : std_ulogic;
signal  ex1_str_valid                  : std_ulogic;
signal  ex1_ldst_v                     : std_ulogic_vector(0 to 3);
signal  ex1_ldst_valid                 : std_ulogic_vector(0 to 3);
signal  ex1_instr_ifar                 : std_ulogic_vector(62-eff_ifar to 61);
signal  ex1_cr_val                     : std_ulogic;
signal  ex1_record                     : std_ulogic;
signal  ex1_kill_wen                   : std_ulogic;
signal  ex1_mcrfs                      : std_ulogic;
signal  ex1_instr_match                : std_ulogic;
signal  ex1_is_ucode                   : std_ulogic;
signal  ex1_divsqrt_beg                : std_ulogic;
signal  ex1_ifar_val                   : std_ulogic_vector(0 to 3);
signal  ex1_fra_v                      : std_ulogic;
signal  ex1_frb_v                      : std_ulogic;
signal  ex1_frc_v                      : std_ulogic;
signal  ex1_fra_valid                  : std_ulogic;
signal  ex1_frb_valid                  : std_ulogic;
signal  ex1_frc_valid                  : std_ulogic;
signal  ex1_frs_byp                    : std_ulogic;
signal  ex1_async_block                : std_ulogic_vector(0 to 3);

signal  ex2_axu_v                      : std_ulogic;
signal  ex2_instr_v                    : std_ulogic_vector(0 to 3);
signal  ex2_instr_valid                : std_ulogic_vector(0 to 3);
signal  ex2_instr_frt                  : std_ulogic_vector(0 to 5);
signal  ex2_cr_val                     : std_ulogic;
signal  ex2_record                     : std_ulogic;
signal  ex2_kill_wen                   : std_ulogic;
signal  ex2_mcrfs                      : std_ulogic;
signal  ex2_instr_match                : std_ulogic;
signal  ex2_is_ucode                   : std_ulogic;
signal  ex2_ifar_val                   : std_ulogic_vector(0 to 3);
signal  ex2_iu_n_flush                 : std_ulogic_vector(0 to 3);
signal  ex2_fra_v                      : std_ulogic;
signal  ex2_frb_v                      : std_ulogic;
signal  ex2_frc_v                      : std_ulogic;
signal  ex2_sto_perr                   : std_ulogic_vector(0 to 3);
signal  ex2_abc_perr                   : std_ulogic_vector(0 to 3);
signal  ex2_fpr_perr                   : std_ulogic_vector(0 to 3);
signal  ex2_ldst_v                     : std_ulogic_vector(0 to 3);
signal  ex2_str_v                      : std_ulogic;
signal  ex2_fu_or_ldst_v               : std_ulogic_vector(0 to 3);
signal  ex2_n_flush                    : std_ulogic_vector(0 to 3);
signal  ex2_flush2ucode                : std_ulogic_vector(0 to 3);
signal  ex2_frs_byp                    : std_ulogic;
signal  ex2_async_block                : std_ulogic_vector(0 to 3);

signal  ex3_instr_v                    : std_ulogic_vector(0 to 3);
signal  ex3_instr_valid                : std_ulogic_vector(0 to 3);
signal  ex3_instr_frt                  : std_ulogic_vector(0 to 5);
signal  ex3_cr_val                     : std_ulogic;
signal  ex3_record                     : std_ulogic;
signal  ex3_b_den_flush                : std_ulogic;
signal  ex4_b_den_flush_din            : std_ulogic;
signal  ex3_kill_wen                   : std_ulogic;
signal  ex3_mcrfs                      : std_ulogic;
signal  ex3_instr_match                : std_ulogic;
signal  ex3_is_ucode                   : std_ulogic;
signal  ex3_n_flush                    : std_ulogic_vector(0 to 3);
signal  ex3_flush2ucode                : std_ulogic_vector(0 to 3);

signal  ex4_instr_v                    : std_ulogic_vector(0 to 3);
signal  ex4_instr_valid                : std_ulogic_vector(0 to 3);
signal  ex4_instr_tid                  : std_ulogic_vector(0 to 1);
signal  ex4_instr_frt                  : std_ulogic_vector(0 to 5);
signal  ex5_instr_frt_din               : std_ulogic_vector(0 to 5);
signal  ex4_cr_val, ex4_cr_val_cp, ex4_cr_val_cp_b                     : std_ulogic;
signal  ex4_fpcc_x_b, ex7_cr_fld_x_b :std_ulogic_vector(0 to 3);
signal  ex4_record                     : std_ulogic;
signal  ex4_kill_wen                   : std_ulogic;
signal  ex4_mcrfs                      : std_ulogic;
signal  ex4_is_ucode                   : std_ulogic;
signal  ex4_b_den_flush                : std_ulogic;
signal  ex4_uc_special                 : std_ulogic;

signal  ex5_instr_valid_din            : std_ulogic_vector(0 to 3);
signal  ex5_instr_v                    : std_ulogic_vector(0 to 3);
signal  ex5_instr_valid                : std_ulogic_vector(0 to 3);
signal  ex5_instr_bypval               : std_ulogic_vector(0 to 3);
signal  ex5_instr_tid                  : std_ulogic_vector(0 to 1);
signal  ex5_instr_frt                  : std_ulogic_vector(0 to 5);
signal  ex5_record_din                 : std_ulogic;
signal  ex5_mcrfs_din                  : std_ulogic;
signal  ex5_record                     : std_ulogic;
signal  ex5_mcrfs                      : std_ulogic;
signal  ex5_is_ucode                   : std_ulogic;
signal  ex5_instr_flush                : std_ulogic;
signal  ex5_cr_val_din                 : std_ulogic;
signal  ex5_cr_val                     : std_ulogic;
signal  ex5_kill_wen_din               : std_ulogic;
signal  ex5_kill_wen                   : std_ulogic;
signal  ex6_instr_valid_din            : std_ulogic_vector(0 to 3);

signal  ex6_instr_v                    : std_ulogic_vector(0 to 3);
signal  ex6_instr_valid                : std_ulogic;
signal  ex6_instr_tid                  : std_ulogic_vector(0 to 1);
signal  ex6_instr_frt                  : std_ulogic_vector(0 to 5);
signal  ex6_record                     : std_ulogic;
signal  ex6_record_v                   : std_ulogic_vector(0 to 3);
signal  ex6_bf                         : std_ulogic_vector(0 to 2);
signal  ex6_mcrfs                      : std_ulogic;
signal  ex6_is_ucode                   : std_ulogic;
signal  ex6_is_fixperr                 : std_ulogic;
signal  ex6_record_din                 : std_ulogic;
signal  ex6_mcrfs_din                  : std_ulogic;
signal  ex6_cr_val_din                 : std_ulogic;
signal  ex6_cr_val                     : std_ulogic;
signal  ex6_kill_wen                   : std_ulogic;
signal  ex6_kill_wen_din                   : std_ulogic;

signal  ex7_record_v                   : std_ulogic_vector(0 to 3);
signal  ex7_bf                         : std_ulogic_vector(0 to 2);

signal  rf1_uc_op_rnd_v                : std_ulogic;
signal  rf1_uc_op_rnd                  : std_ulogic_vector(0 to 1);

signal  ex1_instr_frs                  : std_ulogic_vector(0 to 5);
signal  ex1_instr_fra                  : std_ulogic_vector(0 to 5);
signal  ex1_instr_frb                  : std_ulogic_vector(0 to 5);
signal  ex1_instr_frc                  : std_ulogic_vector(0 to 5);
signal  ex1_perr_si, ex1_perr_so       : std_ulogic_vector(0 to 23);
signal  ex2_instr_frs                  : std_ulogic_vector(0 to 5);
signal  ex2_instr_fra                  : std_ulogic_vector(0 to 5);
signal  ex2_instr_frb                  : std_ulogic_vector(0 to 5);
signal  ex2_instr_frc                  : std_ulogic_vector(0 to 5);
signal  ex2_perr_si, ex2_perr_so       : std_ulogic_vector(0 to 23);
signal  ex2_f0a_perr                   : std_ulogic;
signal  ex2_f0c_perr                   : std_ulogic;
signal  ex2_f1b_perr                   : std_ulogic;
signal  ex2_f1s_perr                   : std_ulogic;
signal  perr_sm_ns                     : std_ulogic_vector(0 to 2);
signal  perr_sm_si, perr_sm_so         : std_ulogic_vector(0 to 2);
signal  perr_sm_din                    : std_ulogic_vector(0 to 2);
signal  perr_sm_l2                     : std_ulogic_vector(0 to 2);
signal  perr_ctl_si, perr_ctl_so       : std_ulogic_vector(0 to 24);
signal  perr_addr_din             : std_ulogic_vector(0 to 5);
signal  perr_addr_l2              : std_ulogic_vector(0 to 5);
signal  perr_tid_din                   : std_ulogic_vector(0 to 3);
signal  perr_tid_l2                    : std_ulogic_vector(0 to 3);
signal  perr_tid_enc                   : std_ulogic_vector(0 to 1);
signal  new_perr_sm_instr_v            : std_ulogic;
signal  rf0_perr_sm_instr_v            : std_ulogic;
signal  rf0_perr_sm_instr_v_b          : std_ulogic;
signal  rf0_frc_perr_x_b               : std_ulogic_vector(0 to 5);
signal  rf0_frc_iu_x_b                 : std_ulogic_vector(0 to 5);
signal  rf0_frb_perr_x_b               : std_ulogic_vector(0 to 5);
signal  rf0_frb_iu_x_b                 : std_ulogic_vector(0 to 5);
signal  rf0_tid_perr_x_b               : std_ulogic_vector(0 to 1);
signal  rf0_tid_iu_x_b                 : std_ulogic_vector(0 to 1);
signal  rf1_perr_sm_instr_v            : std_ulogic;
signal  ex1_perr_sm_instr_v            : std_ulogic;
signal  ex2_perr_sm_instr_v            : std_ulogic;
signal  ex3_perr_sm_instr_v            : std_ulogic;
signal  ex4_perr_sm_instr_v            : std_ulogic;
signal  ex5_perr_sm_instr_v            : std_ulogic;
signal  perr_move_f0_to_f1             : std_ulogic;
signal  perr_move_f1_to_f0             : std_ulogic;
signal  perr_move_f0_to_f1_l2          : std_ulogic;
signal  perr_move_f1_to_f0_l2          : std_ulogic;
signal  rf0_perr_move_f0_to_f1         : std_ulogic;
signal  rf0_perr_move_f1_to_f0         : std_ulogic;
signal  rf0_perr_force_c               : std_ulogic;
signal  rf1_perr_force_c               : std_ulogic;
signal  ex1_perr_force_c               : std_ulogic;
signal  regfile_seq_beg                : std_ulogic;
signal  regfile_seq_end                : std_ulogic;
signal  ex2_regfile_err_det            : std_ulogic;
signal  ex3_regfile_err_det            : std_ulogic_vector(0 to 3);
signal  rf0_regfile_ue                 : std_ulogic;
signal  rf0_regfile_ce                 : std_ulogic;
signal  rf1_regfile_ue                 : std_ulogic;
signal  rf1_regfile_ce                 : std_ulogic;
signal  ex4_eff_addr                   : std_ulogic_vector(59 to 63);
signal  err_regfile_parity             : std_ulogic_vector(0 to 3);
signal  err_regfile_ue                 : std_ulogic_vector(0 to 3);

signal  slowspr_in_val                 : std_ulogic;
signal  slowspr_in_rw                  : std_ulogic;
signal  slowspr_in_etid                : std_ulogic_vector(0 to 1);
signal  slowspr_in_addr                : std_ulogic_vector(0 to 9);
signal  slowspr_in_data                : std_ulogic_vector(64-(2**regmode) to 63);
signal  slowspr_in_done                : std_ulogic;
signal  slowspr_out_val                : std_ulogic;
signal  slowspr_out_rw                 : std_ulogic;
signal  slowspr_out_etid               : std_ulogic_vector(0 to 1);
signal  slowspr_out_addr               : std_ulogic_vector(0 to 9);
signal  slowspr_out_data               : std_ulogic_vector(64-(2**regmode) to 63);
signal  slowspr_out_done               : std_ulogic;
signal  axucr0_dec                     : std_ulogic;
signal  axucr0_rd                      : std_ulogic;
signal  axucr0_wr                      : std_ulogic;
signal  axucr0_din                     : std_ulogic_vector(61 to 63);
signal  axucr0_q                       : std_ulogic_vector(61 to 63);
signal  debug_data_d                   : std_ulogic_vector(0 to 87);
signal  debug_data_q                   : std_ulogic_vector(0 to 87);
signal  debug_trig_d                   : std_ulogic_vector(0 to 11);
signal  debug_trig_q                   : std_ulogic_vector(0 to 11);
signal  debug_mux_ctrls_q              : std_ulogic_vector(0 to 15);
signal  debug_mux_ctrls_muxed          : std_ulogic_vector(0 to 15);

signal      trace_data_in      :  std_ulogic_vector(0 to 87);
signal      trigger_data_in    :  std_ulogic_vector(0 to 11);
signal      dbg_group0        :  std_ulogic_vector(0 to 87);
signal      dbg_group1        :  std_ulogic_vector(0 to 87);
signal      dbg_group2        :  std_ulogic_vector(0 to 87);
signal      dbg_group3        :  std_ulogic_vector(0 to 87);
signal      trg_group0        :  std_ulogic_vector(0 to 11);
signal      trg_group1        :  std_ulogic_vector(0 to 11);
signal      trg_group2        :  std_ulogic_vector(0 to 11);
signal      trg_group3        :  std_ulogic_vector(0 to 11);
signal      trigger_data_out   :  std_ulogic_vector(0 to 11);
signal      trace_data_out     :  std_ulogic_vector(0 to 87);
signal      uc_hooks_debug     :  std_ulogic_vector(0 to 55); 

signal  t0_events                      : std_ulogic_vector(0 to 7);
signal  t1_events                      : std_ulogic_vector(0 to 7);
signal  t2_events                      : std_ulogic_vector(0 to 7);
signal  t3_events                      : std_ulogic_vector(0 to 7);
signal  t0_events_in                   : std_ulogic_vector(0 to 7);
signal  t1_events_in                   : std_ulogic_vector(0 to 7);
signal  t2_events_in                   : std_ulogic_vector(0 to 7);
signal  t3_events_in                   : std_ulogic_vector(0 to 7);
signal  evnt_axu_instr_cmt             : std_ulogic_vector(0 to 3);
signal  evnt_axu_cr_cmt                : std_ulogic_vector(0 to 3);
signal  evnt_axu_idle                  : std_ulogic_vector(0 to 3);
signal  evnt_div_sqrt_ip               : std_ulogic_vector(0 to 3);
signal  evnt_denrm_flush               : std_ulogic_vector(0 to 3);
signal  evnt_uc_instr_cmt              : std_ulogic_vector(0 to 3);
signal  event_data_d                   : std_ulogic_vector(0 to 7);
signal  event_data_q                   : std_ulogic_vector(0 to 7);
signal  evnt_fpu_fex                   : std_ulogic_vector(0 to 3);
signal  evnt_fpu_fx                    : std_ulogic_vector(0 to 3);
signal  event_en_d                     : std_ulogic_vector(0 to 3);
signal  event_en_q                     : std_ulogic_vector(0 to 3);
signal  event_count_mode_q             : std_ulogic_vector(0 to 2);
signal  msr_pr_q                       : std_ulogic_vector(0 to 3);
signal  msr_gs_q                       : std_ulogic_vector(0 to 3);
signal  instr_trace_mode_q             : std_ulogic;
signal  instr_trace_tid_q              : std_ulogic_vector(0 to 1);

signal rf1_instr_iss              : std_ulogic_vector(0 to 3);
signal ex1_instr_iss              : std_ulogic_vector(0 to 3);
signal ex2_instr_iss              : std_ulogic_vector(0 to 3);

signal  ex6_ram_sign                   : std_ulogic;
signal  ex6_ram_frac                   : std_ulogic_vector(0 to 52);
signal  ex6_ram_expo                   : std_ulogic_vector(3 to 13);
signal  ex6_ram_done                   : std_ulogic;
signal  ex7_ram_done                   : std_ulogic;
signal  ex7_ram_sign                   : std_ulogic;
signal  ex7_ram_frac                   : std_ulogic_vector(0 to 52);
signal  ex7_ram_expo                   : std_ulogic_vector(3 to 13);
signal  ex7_ram_data                   : std_ulogic_vector(0 to 63);

signal  rf1_iu_si,      rf1_iu_so      : std_ulogic_vector(0 to 14);
signal  rf1_frt_si,     rf1_frt_so     : std_ulogic_vector(0 to 31);
signal  uc_hooks_rc_rf0                : std_ulogic;
signal  dbg0_act                       : std_ulogic;
signal  event_act                      : std_ulogic;

signal  SPARE_L2                       : std_ulogic_vector(0 to 23);

signal  act_lat_si,     act_lat_so     : std_ulogic_vector(0 to 2);
signal  rf1_ifr_si,     rf1_ifr_so     : std_ulogic_vector(62-eff_ifar to 61);
signal  rf1_instl_si,   rf1_instl_so   : std_ulogic_vector(0 to 31);
signal  rf1_byp_si,     rf1_byp_so     : std_ulogic_vector(0 to 11);
signal  ex1_ctl_si,     ex1_ctl_so     : std_ulogic_vector(0 to 7);
signal  ex1_frt_si,     ex1_frt_so     : std_ulogic_vector(0 to 17);
signal  ex1_ifar_si,    ex1_ifar_so    : std_ulogic_vector(62-eff_ifar to 61);
signal  ex2_ctl_si,     ex2_ctl_so     : std_ulogic_vector(0 to 15);
signal  ex2_ctlng_si,   ex2_ctlng_so   : std_ulogic_vector(0 to 16);
signal  ex3_ctlng_si,   ex3_ctlng_so   : std_ulogic_vector(0 to 15);
signal  ex3_ctl_si,     ex3_ctl_so     : std_ulogic_vector(0 to 12);
signal  ex4_ctl_si,     ex4_ctl_so     : std_ulogic_vector(0 to 15);
signal  ex5_ctl_si,     ex5_ctl_so     : std_ulogic_vector(0 to 14);
signal  ex6_ctl_si,     ex6_ctl_so     : std_ulogic_vector(0 to 15);
signal  ex7_ctl_si,     ex7_ctl_so     : std_ulogic_vector(0 to 6);
signal  spr_ctl_si,     spr_ctl_so     : std_ulogic_vector(0 to 14);
signal  spr_data_si,    spr_data_so    : std_ulogic_vector(64-(2**regmode) to 63);
signal  ram_data_si,    ram_data_so    : std_ulogic_vector(0 to 64);
signal  ram_datav_si,   ram_datav_so   : std_ulogic_vector(0 to 0);
signal  perf_data_si,    perf_data_so    : std_ulogic_vector(0 to 38);
signal  dbg0_data_si,    dbg0_data_so    : std_ulogic_vector(0 to 115);
signal  dbg1_data_si,    dbg1_data_so    : std_ulogic_vector(0 to 4);
signal  spare_si,        spare_so      : std_ulogic_vector(0 to 23);
signal  f_ucode_si,     f_ucode_so     : std_ulogic;
signal  axucr0_lat_si, axucr0_lat_so   : std_ulogic_vector(0 to 2);

signal cfg_slat_d2clk : std_ulogic;
signal cfg_slat_lclk  : clk_logic;


signal ex2_store_valid , ex2_stdv_si, ex2_stdv_so : std_ulogic; 
signal msr_fp                                     : std_ulogic;
signal msr_fp_raw                                 : std_ulogic;
signal msr_fp_act                                 : std_ulogic;

signal perr_sm_running                            : std_ulogic;

signal spare_unused : std_ulogic_vector(0 to 10);




  signal ex5_iflush_int_b, ex5_iflush_b :std_ulogic_vector(0 to 3);
  signal ex5_iflush_01, ex5_iflush_23, ex5_instr_flush_b :std_ulogic;



begin


   tilo      <= '0';
   tihi      <= '1';
   fu_buf_up: tihi_out <= tihi;
   fu_buf_dn: tilo_out <= tilo;


    thold_reg_0:  tri_plat  generic map (expand_type => expand_type, width => 3) port map (
         vd        => vdd,
         gd        => gnd,
         nclk      => nclk,  
         flush     => flush ,
         din(0)    => thold_1,
         din(1)    => cfg_sl_thold_1,
         din(2)    => func_slp_sl_thold_1,
         q(0)      => thold_0,
         q(1)      => cfg_sl_thold_0,
         q(2)      => func_slp_sl_thold_0  ); 
    
    sg_reg_0:  tri_plat     generic map (expand_type => expand_type) port map (
         vd        => vdd,
         gd        => gnd,
         nclk      => nclk,
         flush     => flush ,
         din(0)    => sg_1  ,     
         q(0)      => sg_0  );   


    lcbor_0: tri_lcbor generic map (expand_type => expand_type ) port map (
        clkoff_b     => clkoff_b,
        thold        => thold_0,  
        sg           => sg_0,
        act_dis      => act_dis,
        forcee => forcee,
        thold_b      => thold_0_b );

    cfg_sl_lcbor_0: tri_lcbor generic map (expand_type => expand_type ) port map (
        clkoff_b     => clkoff_b,
        thold        => cfg_sl_thold_0,  
        sg           => sg_0,
        act_dis      => act_dis,
        forcee => cfg_sl_force,
        thold_b      => cfg_sl_thold_0_b );

    func_slp_sl_lcbor_0: tri_lcbor generic map (expand_type => expand_type ) port map (
        clkoff_b     => clkoff_b,
        thold        => func_slp_sl_thold_0,  
        sg           => sg_0,
        act_dis      => act_dis,
        forcee => func_slp_sl_force,
        thold_b      => func_slp_sl_thold_0_b );


   msr_fp <= or_reduce(xu_fu_msr_fp(0 to 3));

   act_lat: tri_rlmreg_p   generic map (init => 0, expand_type => expand_type, width => 3)   port map ( 
             nclk     => nclk,
             act      => tihi,
             forcee => forcee,
             delay_lclkr => delay_lclkr(9),
             mpw1_b      => mpw1_b(9),
             mpw2_b      => mpw2_b(1),
             thold_b  => thold_0_b,
             sg       => sg_0,
             vd       => vdd,
             gd       => gnd,
             scin          => act_lat_si(0 to 2),
             scout         => act_lat_so(0 to 2),
             din(0)        => pc_fu_trace_bus_enable,
             din(1)        => pc_fu_event_bus_enable,
             din(2)        => msr_fp,
             dout(0)       => dbg0_act ,
             dout(1)       => event_act ,
             dout(2)       => msr_fp_raw);

   msr_fp_act       <= msr_fp_raw or not axucr0_q(63);

   f_dcd_msr_fp_act <= msr_fp_act;



   rf0_str_tag(0 to 1)    <= iu_fu_rf0_ldst_tag(0 to 1);

   rf0_ldst_valid(0)   <= iu_fu_rf0_ldst_val and not xu_rf0_flush(0) and iu_fu_rf0_ldst_tid(0 to 1) = "00";
   rf0_ldst_valid(1)   <= iu_fu_rf0_ldst_val and not xu_rf0_flush(1) and iu_fu_rf0_ldst_tid(0 to 1) = "01";
   rf0_ldst_valid(2)   <= iu_fu_rf0_ldst_val and not xu_rf0_flush(2) and iu_fu_rf0_ldst_tid(0 to 1) = "10";
   rf0_ldst_valid(3)   <= iu_fu_rf0_ldst_val and not xu_rf0_flush(3) and iu_fu_rf0_ldst_tid(0 to 1) = "11";

   rf0_str_v                <= iu_fu_rf0_str_val;

   rf0_instr_match       <= iu_fu_rf0_instr_match;
   rf0_is_ucode          <= iu_fu_rf0_is_ucode;

   rf0_tid(0 to 1)       <= iu_fu_rf0_tid(0 to 1);
   rf0_instr_tid_1hot(0) <= (rf0_tid(0 to 1) = "00") and iu_fu_rf0_instr_v;
   rf0_instr_tid_1hot(1) <= (rf0_tid(0 to 1) = "01") and iu_fu_rf0_instr_v;
   rf0_instr_tid_1hot(2) <= (rf0_tid(0 to 1) = "10") and iu_fu_rf0_instr_v;
   rf0_instr_tid_1hot(3) <= (rf0_tid(0 to 1) = "11") and iu_fu_rf0_instr_v;

   rf0_instr_valid(0 to 3) <= rf0_instr_tid_1hot(0 to 3) and not xu_rf0_flush(0 to 3);

   rf0_thread_lat: tri_rlmreg_p   generic map (init => 0, expand_type => expand_type, width => 4)   port map ( 
             nclk     => nclk,
             act      => msr_fp_act,
             forcee => forcee,
             delay_lclkr => delay_lclkr(8),
             mpw1_b      => mpw1_b(8),
             mpw2_b      => mpw2_b(1),
             thold_b  => thold_0_b,
             sg       => sg_0,
             vd       => vdd,
             gd       => gnd,
             scin          => rf0_thread_si(0 to 3),
             scout         => rf0_thread_so(0 to 3),
             din(0 to 3)   => iu_fu_is2_tid_decode(0 to 3),
             dout(0 to 3)  => thread_id_rf0(0 to 3) ) ; 


   rf0_instr_frt(0 to 5)   <= iu_fu_rf0_frt(1 to 6); 
   rf0_instr_fra(0 to 5)   <= iu_fu_rf0_fra(1 to 6); 
   rf0_instr_frb(0 to 5)   <= iu_fu_rf0_frb(1 to 6); 
   rf0_instr_frc(0 to 5)   <= iu_fu_rf0_frc(1 to 6); 
   rf0_instr_frs(0 to 5)   <= iu_fu_rf0_ldst_tag(3 to 8);
   


   rf0_bypsel(0 to 5) <= iu_fu_rf0_bypsel(0 to 5);

   rf0_bypsel_a_res0  <= rf0_bypsel(3) and or_reduce(ex5_instr_bypval(0 to 3));  
   rf0_bypsel_c_res0  <= rf0_bypsel(4) and or_reduce(ex5_instr_bypval(0 to 3));  
   rf0_bypsel_b_res0  <= rf0_bypsel(5) and or_reduce(ex5_instr_bypval(0 to 3));  

   rf0_bypsel_a_res1  <= (ex6_instr_tid(0 to 1) & ex6_instr_frt(0 to 5)) = (rf0_tid(0 to 1) & rf0_instr_fra(0 to 5)) and
                         (ex6_instr_valid and not ex6_kill_wen) and iu_fu_rf0_fra_v and not rf0_bypsel_a_res0 and not rf0_bypsel_a_load0;
   rf0_bypsel_c_res1  <= (ex6_instr_tid(0 to 1) & ex6_instr_frt(0 to 5)) = (rf0_tid(0 to 1) & rf0_instr_frc(0 to 5)) and
                         (ex6_instr_valid and not ex6_kill_wen) and iu_fu_rf0_frc_v and not rf0_bypsel_c_res0 and not rf0_bypsel_c_load0;
   rf0_bypsel_b_res1  <= (ex6_instr_tid(0 to 1) & ex6_instr_frt(0 to 5)) = (rf0_tid(0 to 1) & rf0_instr_frb(0 to 5)) and
                         (ex6_instr_valid and not ex6_kill_wen) and iu_fu_rf0_frb_v and not rf0_bypsel_b_res0 and not rf0_bypsel_b_load0;

   rf0_bypsel_s_res1  <= (ex6_instr_tid(0 to 1) & ex6_instr_frt(0 to 5)) = (iu_fu_rf0_ldst_tid(0 to 1) & rf0_instr_frs(0 to 5)) and
                         (ex6_instr_valid and not ex6_kill_wen) and rf0_str_v;

   rf0_bypsel_a_load0 <= rf0_bypsel(0);
   rf0_bypsel_c_load0 <= rf0_bypsel(1);
   rf0_bypsel_b_load0 <= rf0_bypsel(2);

   rf0_bypsel_a_load1 <= (f_fpr_ex7_load_addr(0 to 7) ) = (rf0_tid(0 to 1) & rf0_instr_fra(0 to 5)) and f_fpr_ex7_load_v and iu_fu_rf0_fra_v and not rf0_bypsel_a_load0 and not rf0_bypsel_a_res0;
   rf0_bypsel_c_load1 <= (f_fpr_ex7_load_addr(0 to 7) ) = (rf0_tid(0 to 1) & rf0_instr_frc(0 to 5)) and f_fpr_ex7_load_v and iu_fu_rf0_frc_v and not rf0_bypsel_c_load0 and not rf0_bypsel_c_res0;
   rf0_bypsel_b_load1 <= (f_fpr_ex7_load_addr(0 to 7) ) = (rf0_tid(0 to 1) & rf0_instr_frb(0 to 5)) and f_fpr_ex7_load_v and iu_fu_rf0_frb_v and not rf0_bypsel_b_load0 and not rf0_bypsel_b_res0;
   rf0_bypsel_s_load1 <= (f_fpr_ex7_load_addr(0 to 7) ) = (iu_fu_rf0_ldst_tid(0 to 1) & rf0_instr_frs(0 to 5)) and f_fpr_ex7_load_v and rf0_str_v;

   f_dcd_rf0_bypsel_a_res1     <= rf0_bypsel_a_res1;
   f_dcd_rf0_bypsel_b_res1     <= rf0_bypsel_b_res1;
   f_dcd_rf0_bypsel_c_res1     <= rf0_bypsel_c_res1;
   f_dcd_rf0_bypsel_a_load1    <= rf0_bypsel_a_load1;
   f_dcd_rf0_bypsel_b_load1    <= rf0_bypsel_b_load1;
   f_dcd_rf0_bypsel_c_load1    <= rf0_bypsel_c_load1;

   f_dcd_rf0_bypsel_s_res1     <= rf0_bypsel_s_res1;
   f_dcd_rf0_bypsel_s_load1    <= rf0_bypsel_s_load1;

   rf0_frs_byp    <= rf0_bypsel_s_res1 or rf0_bypsel_s_load1;


   rf1_iu: tri_rlmreg_p
   generic map (init => 0, expand_type => expand_type, width => 15)
   port map (nclk     => nclk,
             act      => tihi,
             forcee => forcee,
             delay_lclkr => delay_lclkr(0),
             mpw1_b      => mpw1_b(0),
             mpw2_b      => mpw2_b(0),
             thold_b  => thold_0_b,
             sg       => sg_0,
             vd       => vdd,
             gd       => gnd,
             scin     => rf1_iu_si(0 to 14),
             scout    => rf1_iu_so(0 to 14),
             din(0)        => iu_fu_rf0_fra_v,
             din(1)        => iu_fu_rf0_frb_v,
             din(2)        => iu_fu_rf0_frc_v,
             din(3 to 6)   => rf0_instr_valid(0 to 3),
             din(7 to 10)  => rf0_ldst_valid(0 to 3),
             din(11 to 12) => rf0_str_tag(0 to 1),
             din(13)       => rf0_str_v,
             din(14)       => rf0_frs_byp,
             dout(0)       => rf1_instr_fra_v,
             dout(1)       => rf1_instr_frb_v,
             dout(2)       => rf1_instr_frc_v,
             dout(3 to 6)  => rf1_instr_v(0 to 3),
             dout(7 to 10) => rf1_ldst_v(0 to 3),
             dout(11 to 12) => rf1_str_tag(0 to 1),
             dout(13)       => rf1_str_v,
             dout(14)       => rf1_frs_byp
             );
   rf1_frt: tri_rlmreg_p
   generic map (init => 0, expand_type => expand_type, width => 32)
   port map (nclk    => nclk,
             act     => msr_fp_act,
             forcee => forcee,
             delay_lclkr => delay_lclkr(0),
             mpw1_b      => mpw1_b(0),
             mpw2_b      => mpw2_b(0),
             thold_b => thold_0_b,
             sg      => sg_0,
             vd       => vdd,
             gd       => gnd,
             scin    => rf1_frt_si(0 to 31),
             scout   => rf1_frt_so(0 to 31),
             din( 0 to  5)  => rf0_instr_frt(0 to 5)   ,
             din( 6 to 11)  => rf0_instr_fra(0 to 5)   ,
             din(12 to 17)  => rf0_instr_frb(0 to 5)   ,
             din(18 to 23)  => rf0_instr_frc(0 to 5)   ,
             din(24 to 29)  => rf0_instr_frs(0 to 5)   ,
             din(30)        => rf0_instr_match         ,
             din(31)        => rf0_is_ucode            ,
             dout( 0 to  5) => rf1_instr_frt(0 to 5)   ,
             dout( 6 to 11) => rf1_instr_fra(0 to 5)   ,
             dout(12 to 17) => rf1_instr_frb(0 to 5)   ,
             dout(18 to 23) => rf1_instr_frc(0 to 5)   ,
             dout(24 to 29) => rf1_instr_frs(0 to 5)   ,
             dout(30)       => rf1_instr_match         ,
             dout(31)       => rf1_is_ucode
             );
   rf1_ifr: tri_rlmreg_p
   generic map (init => 0, expand_type => expand_type, width => eff_ifar) 
   port map (nclk    => nclk,
             act     => tihi,
             forcee => forcee,
             delay_lclkr => delay_lclkr(0),
             mpw1_b      => mpw1_b(0),
             mpw2_b      => mpw2_b(0),
             thold_b => thold_0_b,
             sg      => sg_0,
             vd       => vdd,
             gd       => gnd,
             scin    => rf1_ifr_si,
             scout   => rf1_ifr_so,
             din     => iu_fu_rf0_ifar,
             dout    => rf1_instr_ifar   );
   rf1_instl: tri_rlmreg_p
   generic map (init => 0, expand_type => expand_type, width => 32)
   port map (nclk    => nclk,
             act     => msr_fp_act,
             forcee => forcee,
             delay_lclkr => delay_lclkr(0),
             mpw1_b      => mpw1_b(0),
             mpw2_b      => mpw2_b(0),
             thold_b => thold_0_b,
             sg      => sg_0,
             vd       => vdd,
             gd       => gnd,
             scin    => rf1_instl_si(0 to 31),
             scout   => rf1_instl_so(0 to 31),
             din(0 to 30)  => iu_fu_rf0_instr(0 to 30),
             din(31)       => uc_hooks_rc_rf0, 
             dout          => rf1_instr(0 to 31)   );
   rf1_byp: tri_rlmreg_p
   generic map (init => 0, expand_type => expand_type, width => 12)
   port map (nclk    => nclk,
             act     => msr_fp_act,
             forcee => forcee,
             delay_lclkr => delay_lclkr(0),
             mpw1_b      => mpw1_b(0),
             mpw2_b      => mpw2_b(0),
             thold_b => thold_0_b,
             sg      => sg_0,
             vd       => vdd,
             gd       => gnd,
             scin    => rf1_byp_si(0 to 11),
             scout   => rf1_byp_so(0 to 11),
             din(0)  => rf0_bypsel_a_res0,
             din(1)  => rf0_bypsel_c_res0,
             din(2)  => rf0_bypsel_b_res0,
             din(3)  => rf0_bypsel_a_res1,
             din(4)  => rf0_bypsel_c_res1,
             din(5)  => rf0_bypsel_b_res1,
             din(6)  => rf0_bypsel_a_load0,
             din(7)  => rf0_bypsel_c_load0,
             din(8)  => rf0_bypsel_b_load0,
             din(9)  => rf0_bypsel_a_load1,
             din(10) => rf0_bypsel_c_load1,
             din(11) => rf0_bypsel_b_load1,
             dout(0)  => rf1_bypsel_a_res0,
             dout(1)  => rf1_bypsel_c_res0,
             dout(2)  => rf1_bypsel_b_res0,
             dout(3)  => rf1_bypsel_a_res1,
             dout(4)  => rf1_bypsel_c_res1,
             dout(5)  => rf1_bypsel_b_res1,
             dout(6)  => rf1_bypsel_a_load0,
             dout(7)  => rf1_bypsel_c_load0,
             dout(8)  => rf1_bypsel_b_load0,
             dout(9)  => rf1_bypsel_a_load1,
             dout(10) => rf1_bypsel_c_load1,
             dout(11) => rf1_bypsel_b_load1
            );

   rf1_instr_valid(0 to 3)     <=  rf1_instr_v(0 to 3)  and not xu_rf1_flush(0 to 3);
   rf1_ldst_valid(0 to 3)      <=  rf1_ldst_v(0 to 3)   and not xu_rf1_flush(0 to 3);

   fu_xu_rf1_act(0 to 3)       <=  rf1_instr_v(0 to 3);

   rf1_tid(0) <= rf1_instr_v(2) or rf1_instr_v(3);
   rf1_tid(1) <= rf1_instr_v(1) or rf1_instr_v(3);


   rf1_primary(0 to 5)        <= rf1_instr(0 to 5);
   rf1_sec_xform(0 to 9)      <= rf1_instr(21 to 30);
   rf1_sec_aform(0 to 4)      <= rf1_instr(26 to 30);
   rf1_v                      <= rf1_instr_v(0) or rf1_instr_v(1) or rf1_instr_v(2) or rf1_instr_v(3);
   rf1_axu_v                  <= rf1_v or rf1_ldst_v(0) or rf1_ldst_v(1) or rf1_ldst_v(2) or rf1_ldst_v(3) or rf1_perr_sm_instr_v;
   rf1_dp                     <=  (rf1_primary(0 to 5) = "111111") and rf1_v and not rf1_perr_sm_instr_v; 
   rf1_sp                     <=  (rf1_primary(0 to 5) = "111011") and rf1_v and not rf1_perr_sm_instr_v;
   rf1_dporsp                 <=  rf1_dp or rf1_sp;

   rf1_fabs                   <=  rf1_dp     and (rf1_sec_xform(0 to 9)   = "0100001000");
   rf1_fadd                   <=  rf1_dporsp and (rf1_sec_aform(0 to 4)   = "10101");
   rf1_fcfid                  <=  rf1_dp     and (rf1_sec_xform(0 to 9)   = "1101001110");
   rf1_fcfidu                 <=  rf1_dp     and (rf1_sec_xform(0 to 9)   = "1111001110");
   rf1_fcfids                 <=  rf1_sp     and (rf1_sec_xform(0 to 9)   = "1101001110");
   rf1_fcfidus                <=  rf1_sp     and (rf1_sec_xform(0 to 9)   = "1111001110");
   rf1_fcfiwu                 <=  rf1_dp     and (rf1_sec_xform(0 to 9)   = "0011001110");
   rf1_fcfiwus                <=  rf1_sp     and (rf1_sec_xform(0 to 9)   = "0011001110");
   rf1_fcmpo                  <=  rf1_dp     and (rf1_sec_xform(0 to 9)   = "0000100000");
   rf1_fcmpu                  <=  rf1_dp     and (rf1_sec_xform(0 to 9)   = "0000000000");
   rf1_fcpsgn                 <=  rf1_dp     and (rf1_sec_xform(0 to 9)   = "0000001000");
   rf1_fctid                  <=  rf1_dp     and (rf1_sec_xform(0 to 9)   = "1100101110");
   rf1_fctidu                 <=  rf1_dp     and (rf1_sec_xform(0 to 9)   = "1110101110");
   rf1_fctidz                 <=  rf1_dp     and (rf1_sec_xform(0 to 9)   = "1100101111");
   rf1_fctiduz                <=  rf1_dp     and (rf1_sec_xform(0 to 9)   = "1110101111");
   rf1_fctiw                  <=  rf1_dp     and (rf1_sec_xform(0 to 9)   = "0000001110");
   rf1_fctiwu                 <=  rf1_dp     and (rf1_sec_xform(0 to 9)   = "0010001110");
   rf1_fctiwz                 <=  rf1_dp     and (rf1_sec_xform(0 to 9)   = "0000001111");
   rf1_fctiwuz                <=  rf1_dp     and (rf1_sec_xform(0 to 9)   = "0010001111");
   rf1_fmadd                  <=  rf1_dporsp and (rf1_sec_aform(0 to 4)   = "11101");
   rf1_fmr                    <=  rf1_dp     and (rf1_sec_xform(0 to 9)   = "0001001000");
   rf1_fmsub                  <=  rf1_dporsp and (rf1_sec_aform(0 to 4)   = "11100");
   rf1_fmul                   <=  rf1_dporsp and ((rf1_sec_aform(0 to 4)   = "11001") or
                                                  (rf1_sec_aform(0 to 4)   = "10001")); 
   rf1_fnabs                  <=  rf1_dp     and (rf1_sec_xform(0 to 9)   = "0010001000");
   rf1_fneg                   <=  rf1_dp     and (rf1_sec_xform(0 to 9)   = "0000101000");
   rf1_fnmadd                 <=  rf1_dporsp and (rf1_sec_aform(0 to 4)   = "11111");
   rf1_fnmsub                 <=  rf1_dporsp and (rf1_sec_aform(0 to 4)   = "11110");
   rf1_fres                   <=  rf1_dporsp and (rf1_sec_aform(0 to 4)   = "11000");
   rf1_frim                   <=  rf1_dp     and (rf1_sec_xform(0 to 9)   = "0111101000");
   rf1_frin                   <=  rf1_dp     and (rf1_sec_xform(0 to 9)   = "0110001000");
   rf1_frip                   <=  rf1_dp     and (rf1_sec_xform(0 to 9)   = "0111001000");
   rf1_friz                   <=  rf1_dp     and (rf1_sec_xform(0 to 9)   = "0110101000");
   rf1_frsp                   <=  rf1_dp     and (rf1_sec_xform(0 to 9)   = "0000001100");
   rf1_frsqrte                <=  rf1_dporsp and (rf1_sec_aform(0 to 4)   = "11010");
   rf1_fsel                   <=  (rf1_dp     and (rf1_sec_aform(0 to 4)   = "10111"))
                                  or (not perr_sm_l2(0)); 

   rf1_fsub                   <=  rf1_dporsp and (rf1_sec_aform(0 to 4)   = "10100");
   rf1_mcrfs                  <=  rf1_dp     and (rf1_sec_xform(0 to 9)   = "0001000000");
   rf1_mffs                   <=  rf1_dp     and (rf1_sec_xform(0 to 9)   = "1001000111");
   rf1_mtfsb0                 <=  rf1_dp     and (rf1_sec_xform(0 to 9)   = "0001000110");
   rf1_mtfsb1                 <=  rf1_dp     and (rf1_sec_xform(0 to 9)   = "0000100110");
   rf1_mtfsf                  <=  rf1_dp     and (rf1_sec_xform(0 to 9)   = "1011000111");
   rf1_mtfsfi                 <=  rf1_dp     and (rf1_sec_xform(0 to 9)   = "0010000110");
   rf1_loge                   <=  rf1_dporsp and (rf1_sec_xform(0 to 9)   = "0011100101");
   rf1_expte                  <=  rf1_dporsp and (rf1_sec_xform(0 to 9)   = "0011000101");
   rf1_prenorm                <=  rf1_dporsp and (rf1_sec_xform(5 to 9)   =      "10000");

   rf1_ftdiv                  <=  rf1_dp     and (rf1_sec_xform(0 to 9)   = "0010000000");
   rf1_ftsqrt                 <=  rf1_dp     and (rf1_sec_xform(0 to 9)   = "0010100000");

   rf1_cr_val                 <= rf1_fcmpu or rf1_fcmpo;
   rf1_record                 <= (rf1_dporsp and rf1_instr(31)) and not rf1_cr_val and not rf1_mcrfs
                                                                and not rf1_ftdiv  and not rf1_ftsqrt;

   rf1_moves                  <= rf1_fmr   or rf1_fabs or rf1_fnabs or rf1_fneg or rf1_fcpsgn ;

   rf1_to_ints                <= rf1_fctid or rf1_fctidu or rf1_fctidz or rf1_fctiduz or
                                 rf1_fctiw or rf1_fctiwu or rf1_fctiwz or rf1_fctiwuz;
   rf1_from_ints              <= rf1_fcfid or rf1_fcfidu or rf1_fcfids or rf1_fcfidus or
                                 rf1_fcfiwu or rf1_fcfiwus;
   rf1_fpscr_moves            <= rf1_mtfsb0 or rf1_mtfsb1 or rf1_mtfsf or rf1_mtfsfi or rf1_mcrfs;

   rf1_kill_wen               <= rf1_cr_val or rf1_fpscr_moves or rf1_ftdiv or rf1_ftsqrt;


   rf1_mtfsb_bt(0)   <= not rf1_instr(9) and not rf1_instr(10); 
   rf1_mtfsb_bt(1)   <= not rf1_instr(9) and     rf1_instr(10); 
   rf1_mtfsb_bt(2)   <=     rf1_instr(9) and not rf1_instr(10); 
   rf1_mtfsb_bt(3)   <=     rf1_instr(9) and     rf1_instr(10); 

   rf1_mtfs_bf(0)    <= not rf1_instr(6) and not rf1_instr(7) and not rf1_instr(8); 
   rf1_mtfs_bf(1)    <= not rf1_instr(6) and not rf1_instr(7) and     rf1_instr(8); 
   rf1_mtfs_bf(2)    <= not rf1_instr(6) and     rf1_instr(7) and not rf1_instr(8); 
   rf1_mtfs_bf(3)    <= not rf1_instr(6) and     rf1_instr(7) and     rf1_instr(8); 
   rf1_mtfs_bf(4)    <=     rf1_instr(6) and not rf1_instr(7) and not rf1_instr(8); 
   rf1_mtfs_bf(5)    <=     rf1_instr(6) and not rf1_instr(7) and     rf1_instr(8); 
   rf1_mtfs_bf(6)    <=     rf1_instr(6) and     rf1_instr(7) and not rf1_instr(8); 
   rf1_mtfs_bf(7)    <=     rf1_instr(6) and     rf1_instr(7) and     rf1_instr(8); 

   rf1_mcrfs_bfa(0)  <= not rf1_instr(11) and not rf1_instr(12) and not rf1_instr(13); 
   rf1_mcrfs_bfa(1)  <= not rf1_instr(11) and not rf1_instr(12) and     rf1_instr(13); 
   rf1_mcrfs_bfa(2)  <= not rf1_instr(11) and     rf1_instr(12) and not rf1_instr(13); 
   rf1_mcrfs_bfa(3)  <= not rf1_instr(11) and     rf1_instr(12) and     rf1_instr(13); 
   rf1_mcrfs_bfa(4)  <=     rf1_instr(11) and not rf1_instr(12) and not rf1_instr(13); 
   rf1_mcrfs_bfa(5)  <=     rf1_instr(11) and not rf1_instr(12) and     rf1_instr(13); 
   rf1_mcrfs_bfa(6)  <=     rf1_instr(11) and     rf1_instr(12) and not rf1_instr(13); 
   rf1_mcrfs_bfa(7)  <=     rf1_instr(11) and     rf1_instr(12) and     rf1_instr(13); 

   rf1_mtfsf_l       <=     rf1_instr(6);
   rf1_mtfsf_w       <=     rf1_instr(15);


   rf1_fpscr_bit_data(0 to 3) <= (rf1_instr(16 to 19)  or (0 to 3 => rf1_mtfsb1)) and not
                                 (0 to 3 => rf1_mtfsb0 or rf1_mtfsf or rf1_mcrfs);

   rf1_fpscr_bit_mask(0 to 3) <=  rf1_mtfsb_bt(0 to 3)  or
                                 (0 to 3 => rf1_mtfsfi or rf1_mtfsf or rf1_mcrfs);

   rf1_fpscr_nib_mask(0 to 7) <= (rf1_mtfs_bf (0 to  7) and (0 to 7 => rf1_mtfsb1 or rf1_mtfsb0)      ) or
                                 (rf1_mtfs_bf (0 to  7) and (0 to 7 => rf1_mtfsfi and not rf1_mtfsf_w)) or
                                 (rf1_mtfsf_nib(0 to 7) and (0 to 7 => rf1_mtfsf)                     ) or 
                                 (rf1_mcrfs_bfa(0 to 7) and (0 to 7 => rf1_mcrfs)                     );



   rf1_mtfsf_nib(0 to 7)      <= (rf1_instr(7 to 14) or (7 to 14 => rf1_mtfsf_l)) and not (0 to 7 => not rf1_mtfsf_l and rf1_mtfsf_w);

   rf1_fpscr_nib_mask(8)      <= (rf1_mtfsfi and     rf1_mtfsf_w and rf1_mtfs_bf(7)) or
                                 (rf1_mtfsf  and     rf1_mtfsf_l                   ) or
                                 (rf1_mtfsf  and not rf1_mtfsf_l and rf1_mtfsf_w and rf1_instr(14));

   f_dcd_rf1_fpscr_bit_data_b(0 to 3)      <= not rf1_fpscr_bit_data(0 to 3);
   f_dcd_rf1_fpscr_bit_mask_b(0 to 3)      <= not rf1_fpscr_bit_mask(0 to 3);
   f_dcd_rf1_fpscr_nib_mask_b(0 to 8)      <= not rf1_fpscr_nib_mask(0 to 8);

  
   f_dcd_rf1_aop_valid                     <= rf1_instr_fra_v;
   f_dcd_rf1_cop_valid                     <= rf1_instr_frc_v or
                                                             (not perr_sm_l2(0) and rf1_perr_sm_instr_v);  
   f_dcd_rf1_bop_valid                     <= rf1_instr_frb_v or
                                                             (not perr_sm_l2(0) and rf1_perr_sm_instr_v);  

   f_dcd_rf1_sp                           <= rf1_sp and not (rf1_fcfids or rf1_fcfiwus or rf1_fcfidus);
   f_dcd_rf1_emin_dp                      <= tilo;
   f_dcd_rf1_emin_sp                      <= rf1_frsp;
   f_dcd_rf1_force_pass_b                 <= not (rf1_fmr or rf1_fabs or rf1_fnabs or rf1_fneg or rf1_mtfsf or rf1_fcpsgn);
   f_dcd_rf1_fsel_b                       <= not  rf1_fsel;
   f_dcd_rf1_from_integer_b               <= not  rf1_from_ints;
   f_dcd_rf1_to_integer_b                 <= not (rf1_to_ints or rf1_frim or rf1_frin or rf1_frip or rf1_friz);
   f_dcd_rf1_rnd_to_int_b                 <= not (rf1_frim or rf1_frin or rf1_frip or rf1_friz);
   f_dcd_rf1_math_b                       <= not (rf1_fmul or rf1_fmadd or rf1_fmsub or rf1_fadd or rf1_fsub or rf1_fnmsub or rf1_fnmadd);
   f_dcd_rf1_est_recip_b                  <= not  rf1_fres;
   f_dcd_rf1_est_rsqrt_b                  <= not  rf1_frsqrte;
   f_dcd_rf1_move_b                       <= not (rf1_moves);
   f_dcd_rf1_prenorm_b                    <= not (rf1_prenorm);
   f_dcd_rf1_frsp_b                       <= not  rf1_frsp;
   f_dcd_rf1_compare_b                    <= not  rf1_cr_val;
   f_dcd_rf1_ordered_b                    <= not  rf1_fcmpo;
   f_dcd_rf1_sp_conv_b                    <= not (rf1_fcfids or rf1_fcfidus or rf1_fcfiwus);
   f_dcd_rf1_uns_b                        <= not (rf1_fcfidu or rf1_fcfidus or rf1_fcfiwu or rf1_fcfiwus or
                                                  rf1_fctidu or rf1_fctiduz or rf1_fctiwu or rf1_fctiwuz);
   f_dcd_rf1_word_b                       <= not (rf1_fctiw  or rf1_fctiwu  or rf1_fctiwz or rf1_fctiwuz or
                                                  rf1_fcfiwu or rf1_fcfiwus);
   f_dcd_rf1_sub_op_b                     <= not (rf1_fsub   or rf1_fmsub   or rf1_fnmsub or rf1_cr_val);
   f_dcd_rf1_inv_sign_b                   <= not (rf1_fnmadd or rf1_fnmsub);
   f_dcd_rf1_sign_ctl_b(0)                <= not (rf1_fmr or rf1_fnabs);
   f_dcd_rf1_sign_ctl_b(1)                <= not (rf1_fneg or rf1_fnabs);
   f_dcd_rf1_sgncpy_b                     <= not  rf1_fcpsgn;
   f_dcd_rf1_mv_to_scr_b                  <= not (rf1_mcrfs or rf1_mtfsf or rf1_mtfsfi or rf1_mtfsb0 or rf1_mtfsb1);
   f_dcd_rf1_mv_from_scr_b                <= not  rf1_mffs;
   f_dcd_rf1_mtfsbx_b                     <= not (rf1_mtfsb0 or rf1_mtfsb1);
   f_dcd_rf1_mcrfs_b                      <= not  rf1_mcrfs;
   f_dcd_rf1_mtfsf_b                      <= not  rf1_mtfsf;
   f_dcd_rf1_mtfsfi_b                     <= not  rf1_mtfsfi;

   f_dcd_rf1_mad_act                      <= rf1_v or rf1_perr_sm_instr_v;

   f_dcd_rf1_sto_act                      <= (rf1_ldst_v(0) or rf1_ldst_v(1) or rf1_ldst_v(2) or rf1_ldst_v(3)) and rf1_str_v;

   rf1_rnd0                               <= ((rf1_frim or rf1_frip) and not rf1_uc_op_rnd_v) or
                                              (rf1_uc_op_rnd(0)      and     rf1_uc_op_rnd_v);

   rf1_rnd1                               <= ((rf1_fctidz or rf1_fctiwz or rf1_fctiduz or rf1_fctiwuz or rf1_friz or rf1_frim) and not rf1_uc_op_rnd_v) or
                                              (rf1_uc_op_rnd(1)                                                                and     rf1_uc_op_rnd_v);


   f_dcd_rf1_op_rnd_v_b                   <= not (rf1_fctidz or rf1_fctiwz or rf1_fctiduz or rf1_fctiwuz or
                                                  rf1_frim   or rf1_frin   or rf1_frip    or rf1_friz    or rf1_uc_op_rnd_v);
   f_dcd_rf1_op_rnd_b(0 to 1)             <= not (rf1_rnd0 & rf1_rnd1);

   f_dcd_rf1_thread_b(0 to 3)             <= not rf1_instr_v(0 to 3);

   f_dcd_rf1_sto_dp                       <= not rf1_str_tag(0);
   f_dcd_rf1_sto_sp                       <=     rf1_str_tag(0) and not rf1_str_tag(1);
   f_dcd_rf1_sto_wd                       <=     rf1_str_tag(0) and     rf1_str_tag(1);

   f_dcd_rf1_log2e_b                      <= not rf1_loge;
   f_dcd_rf1_pow2e_b                      <= not rf1_expte;

   f_dcd_rf1_ftdiv                        <= rf1_ftdiv;
   f_dcd_rf1_ftsqrt                       <= rf1_ftsqrt;


   f_dcd_rf1_bypsel_a_res0   <= rf1_bypsel_a_res0  ;
   f_dcd_rf1_bypsel_a_load0  <= rf1_bypsel_a_load0 ;
   f_dcd_rf1_bypsel_b_res0   <= rf1_bypsel_b_res0  ;
   f_dcd_rf1_bypsel_b_load0  <= rf1_bypsel_b_load0 ;
   f_dcd_rf1_bypsel_c_res0   <= rf1_bypsel_c_res0  ;
   f_dcd_rf1_bypsel_c_load0  <= rf1_bypsel_c_load0 ;


   rf1_byp_a    <= rf1_bypsel_a_res0 or rf1_bypsel_a_res1 or rf1_bypsel_a_load0 or rf1_bypsel_a_load1;
   rf1_byp_b    <= rf1_bypsel_b_res0 or rf1_bypsel_b_res1 or rf1_bypsel_b_load0 or rf1_bypsel_b_load1;
   rf1_byp_c    <= rf1_bypsel_c_res0 or rf1_bypsel_c_res1 or rf1_bypsel_c_load0 or rf1_bypsel_c_load1;
   rf1_fra_v    <= rf1_instr_fra_v and not rf1_byp_a and not f_dcd_rf1_uc_fa_dis_par;
   rf1_frb_v    <= rf1_instr_frb_v and not rf1_byp_b and not f_dcd_rf1_uc_fb_dis_par;
   rf1_frc_v    <= rf1_instr_frc_v and not rf1_byp_c and not f_dcd_rf1_uc_fc_dis_par and not rf1_uc_end; 


   ex1_cr_val_din <= rf1_cr_val or rf1_ftdiv or rf1_ftsqrt;

   ex1_ctl: tri_rlmreg_p
   generic map (init => 0, expand_type => expand_type, width => 8) 
   port map (nclk     => nclk,
             act      => tihi,
             forcee => forcee,
             delay_lclkr => delay_lclkr(1),
             mpw1_b      => mpw1_b(1),
             mpw2_b      => mpw2_b(0),
             thold_b  => thold_0_b,
             sg       => sg_0,
             vd       => vdd,
             gd       => gnd,
             scin     => ex1_ctl_si(0 to 7),
             scout    => ex1_ctl_so(0 to 7),
             din(0 to 3)    => rf1_instr_valid(0 to 3),
             din(4 to 7)    => rf1_ldst_valid(0 to 3),
             dout(0 to 3)   => ex1_instr_v(0 to 3),
             dout(4 to 7)   => ex1_ldst_v(0 to 3)
             );

   ex1_frt: tri_rlmreg_p
   generic map (init => 0, expand_type => expand_type, width => 18) 
   port map (nclk     => nclk,
             act      => rf1_axu_v,
             forcee => forcee,
             delay_lclkr => delay_lclkr(1),
             mpw1_b      => mpw1_b(1),
             mpw2_b      => mpw2_b(0),
             thold_b  => thold_0_b,
             sg       => sg_0,
             vd       => vdd,
             gd       => gnd,
             scin     => ex1_frt_si(0 to 17),
             scout    => ex1_frt_so(0 to 17),
             din(0 to 5)   => rf1_instr_frt(0 to 5),
             din( 6)       => ex1_cr_val_din,
             din( 7)       => rf1_record,
             din( 8)        => rf1_kill_wen,
             din( 9)        => rf1_mcrfs,
             din(10)        => rf1_instr_match,
             din(11)        => rf1_is_ucode,
             din(12)        => rf1_divsqrt_beg,
             din(13)        => rf1_fra_v,
             din(14)        => rf1_frb_v,
             din(15)        => rf1_frc_v,
             din(16)        => rf1_str_v,
             din(17)        => rf1_frs_byp,
             dout(0 to 5)  => ex1_instr_frt(0 to 5),
             dout(6)        => ex1_cr_val,
             dout(7)        => ex1_record,
             dout(8)       => ex1_kill_wen,
             dout(9)       => ex1_mcrfs,
             dout(10)       => ex1_instr_match,
             dout(11)       => ex1_is_ucode,
             dout(12)       => ex1_divsqrt_beg,
             dout(13)       => ex1_fra_v,
             dout(14)       => ex1_frb_v,
             dout(15)       => ex1_frc_v,
             dout(16)       => ex1_str_v,
             dout(17)       => ex1_frs_byp
             );
   ex1_ifar: tri_rlmreg_p
   generic map (init => 0, expand_type => expand_type, width => eff_ifar) 
   port map (nclk     => nclk,
             act      => rf1_v,
             forcee => forcee,
             delay_lclkr => delay_lclkr(1),
             mpw1_b      => mpw1_b(1),
             mpw2_b      => mpw2_b(0),
             thold_b  => thold_0_b,
             sg       => sg_0,
             vd       => vdd,
             gd       => gnd,
             scin     => ex1_ifar_si,
             scout    => ex1_ifar_so,
             din   => rf1_instr_ifar,
             dout  => ex1_instr_ifar
             );

   ex1_perr: tri_rlmreg_p
   generic map (init => 0, expand_type => expand_type, width => 24)
   port map (nclk    => nclk,
             act     => rf1_axu_v,
             forcee => forcee,
             delay_lclkr => delay_lclkr(1),
             mpw1_b      => mpw1_b(1),
             mpw2_b      => mpw2_b(0),
             thold_b => thold_0_b,
             sg      => sg_0,
             vd       => vdd,
             gd       => gnd,
             scin    => ex1_perr_si(0 to 23),
             scout   => ex1_perr_so(0 to 23),
             din( 0 to  5)  => rf1_instr_frs(0 to 5)   ,
             din( 6 to 11)  => rf1_instr_fra(0 to 5)   ,
             din(12 to 17)  => rf1_instr_frb(0 to 5)   ,
             din(18 to 23)  => rf1_instr_frc(0 to 5)   ,
             dout( 0 to  5) => ex1_instr_frs(0 to 5)   ,
             dout( 6 to 11) => ex1_instr_fra(0 to 5)   ,
             dout(12 to 17) => ex1_instr_frb(0 to 5)   ,
             dout(18 to 23) => ex1_instr_frc(0 to 5)   
             );

   ex1_instr_valid(0 to 3)     <= ex1_instr_v(0 to 3) and not xu_ex1_flush(0 to 3);
   ex1_v                       <= ex1_instr_v(0) or ex1_instr_v(1) or ex1_instr_v(2) or ex1_instr_v(3);
   ex1_axu_v                   <= ex1_v or ex1_ldst_v(0) or ex1_ldst_v(1) or ex1_ldst_v(2) or ex1_ldst_v(3);

   ex1_ldst_valid              <= ex1_ldst_v(0 to 3)  and not xu_ex1_flush(0 to 3);

   ex1_str_valid               <= ex1_str_v and or_reduce(ex1_ldst_valid(0 to 3));
   ex1_fra_valid               <= ex1_fra_v and or_reduce(ex1_instr_valid(0 to 3));
   ex1_frb_valid               <= ex1_frb_v and or_reduce(ex1_instr_valid(0 to 3));
   ex1_frc_valid               <= ex1_frc_v and or_reduce(ex1_instr_valid(0 to 3));

   ex1_ifar_val(0 to 3)        <= ex1_instr_valid(0 to 3) and not (0 to 3 => ex1_divsqrt_beg);

   fu_xu_ex1_ifar              <= ex1_instr_ifar;



   ex1_async_block(0 to 3)       <= ex1_instr_v(0 to 3) or 
                                    ex2_instr_v(0 to 3) or 
                                    ex3_instr_v(0 to 3) or 
                                    ex4_instr_v(0 to 3) or 
                                    ex5_instr_v(0 to 3) ;  


   ex2_ctlng_lat: tri_rlmreg_p    generic map (init => 0, expand_type => expand_type, width => 17)   port map (
             nclk     => nclk,
             act      => tihi,
             forcee => forcee,
             delay_lclkr => delay_lclkr(2),
             mpw1_b      => mpw1_b(2),
             mpw2_b      => mpw2_b(0),
             thold_b  => thold_0_b,
             sg       => sg_0,
             vd       => vdd,
             gd       => gnd,
             scin     => ex2_ctlng_si(0 to 16),
             scout    => ex2_ctlng_so(0 to 16),
             din( 0 to  3)  => ex1_instr_valid(0 to 3),
             din( 4 to  7)  => ex1_ifar_val(0 to 3),
             din( 8 to 11)  => ex1_ldst_valid(0 to 3),
             din(12 to 15)  => ex1_async_block(0 to 3),
             din(16)        => ex1_str_valid,
             dout( 0 to  3) => ex2_instr_v(0 to 3),
             dout( 4 to  7) => ex2_ifar_val(0 to 3),
             dout( 8 to 11) => ex2_ldst_v(0 to 3),
             dout(12 to 15) => ex2_async_block(0 to 3),
             dout(16)       => ex2_str_v
             );

   ex2_ctl_lat: tri_rlmreg_p    generic map (init => 0, expand_type => expand_type, width => 16)   port map (
             nclk     => nclk,
             act      => ex1_axu_v,
             forcee => forcee,
             delay_lclkr => delay_lclkr(2),
             mpw1_b      => mpw1_b(2),
             mpw2_b      => mpw2_b(0),
             thold_b  => thold_0_b,
             sg       => sg_0,
             vd       => vdd,
             gd       => gnd,
             scin     => ex2_ctl_si(0 to 15),
             scout    => ex2_ctl_so(0 to 15),
             din(0 to 5)    => ex1_instr_frt(0 to 5),
             din(6)         => ex1_cr_val,
             din(7)         => ex1_record,
             din(8)         => ex1_kill_wen,
             din(9)         => ex1_mcrfs,
             din(10)        => ex1_instr_match,
             din(11)        => ex1_is_ucode,
             din(12)        => ex1_fra_valid,
             din(13)        => ex1_frb_valid,
             din(14)        => ex1_frc_valid,
             din(15)        => ex1_frs_byp,
             dout(0 to 5)   => ex2_instr_frt(0 to 5),
             dout(6)        => ex2_cr_val,
             dout(7)        => ex2_record,
             dout(8)        => ex2_kill_wen,
             dout(9)        => ex2_mcrfs,
             dout(10)       => ex2_instr_match,
             dout(11)       => ex2_is_ucode,
             dout(12)       => ex2_fra_v,
             dout(13)       => ex2_frb_v,
             dout(14)       => ex2_frc_v,
             dout(15)       => ex2_frs_byp
             );


   ex2_stdv_lat: tri_rlmreg_p    generic map (init => 0, expand_type => expand_type, width => 1)   port map ( 
             nclk     => nclk,
             act      => tihi,
             forcee => forcee,
             delay_lclkr => delay_lclkr(2),
             mpw1_b      => mpw1_b(2),
             mpw2_b      => mpw2_b(0),
             thold_b  => thold_0_b,
             sg       => sg_0,
             vd       => vdd,
             gd       => gnd,
             scin(0)  => ex2_stdv_si,
             scout(0) => ex2_stdv_so,
             din(0)        => ex1_str_valid,            
             dout(0)       => ex2_store_valid     ); 



   ex2_perr: tri_rlmreg_p
   generic map (init => 0, expand_type => expand_type, width => 24)
   port map (nclk    => nclk,
             act     => ex1_axu_v,
             forcee => forcee,
             delay_lclkr => delay_lclkr(2),
             mpw1_b      => mpw1_b(2),
             mpw2_b      => mpw2_b(0),
             thold_b => thold_0_b,
             sg      => sg_0,
             vd       => vdd,
             gd       => gnd,
             scin    => ex2_perr_si(0 to 23),
             scout   => ex2_perr_so(0 to 23),
             din( 0 to  5)  => ex1_instr_frs(0 to 5)   ,
             din( 6 to 11)  => ex1_instr_fra(0 to 5)   ,
             din(12 to 17)  => ex1_instr_frb(0 to 5)   ,
             din(18 to 23)  => ex1_instr_frc(0 to 5)   ,
             dout( 0 to  5) => ex2_instr_frs(0 to 5)   ,
             dout( 6 to 11) => ex2_instr_fra(0 to 5)   ,
             dout(12 to 17) => ex2_instr_frb(0 to 5)   ,
             dout(18 to 23) => ex2_instr_frc(0 to 5)   
             );


   ex2_sto_perr(0 to 3) <= (0 to 3 => f_sto_ex2_s_parity_check and ex2_str_v and not ex2_frs_byp) and ex2_ldst_v(0 to 3);

   ex2_abc_perr(0 to 3) <= (0 to 3 => (f_mad_ex2_a_parity_check and ex2_fra_v) or
                                     (f_mad_ex2_b_parity_check and ex2_frb_v) or
                                     (f_mad_ex2_c_parity_check and ex2_frc_v) ) and ex2_instr_v(0 to 3);
 
   ex2_fpr_perr(0 to 3) <= (ex2_sto_perr(0 to 3) or ex2_abc_perr(0 to 3)) and not xu_ex2_flush(0 to 3) and (0 to 3 => msr_fp_act);

   ex2_regfile_err_det  <= or_reduce((ex2_sto_perr(0 to 3) or ex2_abc_perr(0 to 3)) and not xu_ex2_flush(0 to 3)) and msr_fp_act;

   ex2_f0a_perr         <= f_mad_ex2_a_parity_check and  ex2_fra_v ;
   ex2_f0c_perr         <= f_mad_ex2_c_parity_check and (ex2_frc_v or (perr_sm_l2(1) and ex2_perr_sm_instr_v) );
   ex2_f1b_perr         <= f_mad_ex2_b_parity_check and (ex2_frb_v or (perr_sm_l2(1) and ex2_perr_sm_instr_v) );
   ex2_f1s_perr         <= f_sto_ex2_s_parity_check and  ex2_str_v ;

   ex2_instr_valid(0 to 3)        <= ex2_instr_v(0 to 3)     and not xu_ex2_flush(0 to 3);

   fu_xu_ex2_store_data_val       <= ex2_store_valid; 

   fu_xu_ex2_ifar_val(0 to 3)     <= ex2_ifar_val(0 to 3);
   fu_xu_ex2_ifar_issued(0 to 3)  <= ex2_instr_iss(0 to 3);

   fu_xu_ex2_instr_type(0 to 11)  <= tilo_out & tilo_out & tihi_out &
                                     tilo_out & tilo_out & tihi_out &
                                     tilo_out & tilo_out & tihi_out &
                                     tilo_out & tilo_out & tihi_out ;

   fu_xu_ex2_instr_match(0 to 3)  <= (0 to 3 => ex2_instr_match);
   fu_xu_ex2_is_ucode(0 to 3)     <= (0 to 3 => ex2_is_ucode);

   fu_xu_ex2_async_block(0 to 3) <= ex2_async_block(0 to 3);

   ex2_fu_or_ldst_v(0 to 3) <= (ex2_instr_v(0 to 3) or ex2_ldst_v(0 to 3))  and not xu_ex2_flush(0 to 3);

   ex2_iu_n_flush(0 to 3)      <= iu_fu_ex2_n_flush(0 to 3) and ex2_fu_or_ldst_v(0 to 3);

   ex2_n_flush(0 to 3)      <= (ex2_instr_valid(0 to 3)  and (0 to 3 => f_ex2_b_den_flush)) or
                                ex2_iu_n_flush(0 to 3) ;

   ex2_axu_v                   <= or_reduce(ex2_instr_v(0 to 3) or ex2_ldst_v(0 to 3));

   ex2_flush2ucode(0 to 3)  <= ex2_instr_v(0 to 3) and (0 to 3 => f_ex2_b_den_flush) and not ex2_iu_n_flush(0 to 3)  and not xu_ex2_flush(0 to 3);



   ex3_ctlng: tri_rlmreg_p
   generic map (init => 0, expand_type => expand_type, width => 16)
   port map (nclk     => nclk,
             act      => tihi,
             forcee => forcee,
             delay_lclkr => delay_lclkr(3),
             mpw1_b      => mpw1_b(3),
             mpw2_b      => mpw2_b(0),
             thold_b  => thold_0_b,
             sg       => sg_0,
             vd       => vdd,
             gd       => gnd,
             scin     => ex3_ctlng_si(0 to 15),
             scout    => ex3_ctlng_so(0 to 15),
             din( 0 to  3)  => ex2_instr_valid(0 to 3),
             din( 4 to  7)  => ex2_n_flush(0 to 3),
             din( 8 to 11)  => ex2_flush2ucode(0 to 3),
             din(12 to 15)  => ex2_fpr_perr(0 to 3),
             dout( 0 to  3) => ex3_instr_v(0 to 3),
             dout( 4 to  7) => ex3_n_flush(0 to 3),
             dout( 8 to 11) => ex3_flush2ucode(0 to 3),
             dout(12 to 15) => ex3_regfile_err_det(0 to 3)
             );

   ex3_ctl: tri_rlmreg_p
   generic map (init => 0, expand_type => expand_type, width => 13)
   port map (nclk     => nclk,
             act      => ex2_axu_v,
             forcee => forcee,
             delay_lclkr => delay_lclkr(3),
             mpw1_b      => mpw1_b(3),
             mpw2_b      => mpw2_b(0),
             thold_b  => thold_0_b,
             sg       => sg_0,
             vd       => vdd,
             gd       => gnd,
             scin     => ex3_ctl_si(0 to 12),
             scout    => ex3_ctl_so(0 to 12),
             din(0 to 5)    => ex2_instr_frt(0 to 5),
             din(6)        => ex2_cr_val,
             din(7)        => ex2_record,
             din(8)        => f_ex2_b_den_flush,
             din(9)        => ex2_kill_wen,
             din(10)        => ex2_mcrfs,
             din(11)        => ex2_instr_match,
             din(12)        => ex2_is_ucode,
             dout(0 to 5)   => ex3_instr_frt(0 to 5),
             dout(6)       => ex3_cr_val,
             dout(7)       => ex3_record,
             dout(8)       => ex3_b_den_flush,
             dout(9)       => ex3_kill_wen,
             dout(10)       => ex3_mcrfs,
             dout(11)       => ex3_instr_match,
             dout(12)       => ex3_is_ucode
             );


   ex3_instr_valid(0 to 3)  <= ex3_instr_v(0 to 3) and not xu_ex3_flush(0 to 3) and (0 to 3 => msr_fp_act);



   fu_xu_ex3_n_flush(0 to 3)      <= ex3_n_flush(0 to 3) ;


   fu_xu_ex3_np1_flush(0 to 3)     <= tilo_out & tilo_out & tilo_out & tilo_out;
   fu_xu_ex3_ap_int_req(0 to 3)    <= tilo_out & tilo_out & tilo_out & tilo_out;

   fu_xu_ex3_flush2ucode(0 to 3)  <= ex3_flush2ucode;


   fu_xu_ex3_trap(0 to 3)         <= (f_scr_ex7_fx_thread0(1) & f_scr_ex7_fx_thread1(1) &
                                      f_scr_ex7_fx_thread2(1) & f_scr_ex7_fx_thread3(1) ) ;

   fu_xu_ex3_regfile_err_det(0 to 3)  <= ex3_regfile_err_det(0 to 3);


   ex4_ctl_lat: tri_rlmreg_p   generic map (init => 0, expand_type => expand_type, width => 16)   port map (
             nclk     => nclk,
             act      => tihi,
             forcee => forcee,
             delay_lclkr => delay_lclkr(4),
             mpw1_b      => mpw1_b(4),
             mpw2_b      => mpw2_b(0),
             thold_b  => thold_0_b,
             sg       => sg_0,
             vd       => vdd,
             gd       => gnd,
             scin     => ex4_ctl_si,
             scout    => ex4_ctl_so,
             din(0 to 3)    => ex3_instr_valid(0 to 3),
             din(4 to 9)    => ex3_instr_frt(0 to 5),
             din(10)        => ex3_cr_val,
             din(11)        => ex3_cr_val, 
             din(12)        => ex3_record,
             din(13)        => ex3_kill_wen,
             din(14)        => ex3_mcrfs,
             din(15)        => ex3_is_ucode,
             dout(0 to 3)   => ex4_instr_v(0 to 3),
             dout(4 to 9)   => ex4_instr_frt(0 to 5),
             dout(10)       => ex4_cr_val,
             dout(11)       => ex4_cr_val_cp, 
             dout(12)       => ex4_record,
             dout(13)       => ex4_kill_wen,
             dout(14)       => ex4_mcrfs,
             dout(15)       => ex4_is_ucode
             );



   ex4_cr_val_cp_b <= not( ex4_cr_val_cp) ;

   u_cr_o1:  ex7_cr_fld_x_b(0 to 3) <= not( f_scr_ex7_cr_fld (0 to 3) and (0 to 3 => ex4_cr_val_cp_b) );
   u_cr_o2:  ex4_fpcc_x_b(0 to 3)   <= not( f_add_ex4_fpcc_iu(0 to 3) and (0 to 3 => ex4_cr_val_cp)   );
   u_cr_o:   fu_xu_ex4_cr(0 to 3)   <= not( ex4_fpcc_x_b(0 to 3) and  ex7_cr_fld_x_b(0 to 3)          );




   ex4_instr_valid(0 to 3)    <= ex4_instr_v(0 to 3) and not xu_ex4_flush(0 to 3);

   fu_xu_ex4_cr_val           <= (ex4_instr_v (0 to 3) and (0 to 3 => ex4_cr_val)) or
                                  ex7_record_v(0 to 3);

   fu_xu_ex4_cr_bf(0 to 2)    <= (ex4_instr_frt(1 to 3) and     (0 to 2 => ex4_cr_val)) or
                                 (ex7_bf(0 to 2)        and not (0 to 2 => ex4_cr_val)) ;

   fu_xu_ex4_cr_noflush(0 to 3)   <= ex7_record_v(0 to 3);
 


   ex5_record_din              <= ex4_record and or_reduce(ex4_instr_valid(0 to 3));
   ex5_mcrfs_din               <= ex4_mcrfs  and or_reduce(ex4_instr_valid(0 to 3));
   ex5_cr_val_din              <= ex4_cr_val and or_reduce(ex4_instr_valid(0 to 3));

   ex4_instr_tid(0)   <= ex4_instr_v(2) or ex4_instr_v(3);
   ex4_instr_tid(1)   <= ex4_instr_v(1) or ex4_instr_v(3);

   ex5_kill_wen_din   <= ex4_kill_wen or (ex4_uc_special and ex4_is_ucode);


   ex5_instr_valid_din(0)     <= ex4_instr_valid(0);
   ex5_instr_valid_din(1)     <= ex4_instr_valid(1);
   ex5_instr_valid_din(2)     <= ex4_instr_valid(2);
   ex5_instr_valid_din(3)     <= ex4_instr_valid(3);

   ex5_instr_frt_din(0 to 5)  <= (ex4_instr_frt(0 to 5) and not (0 to 5 => perr_sm_l2(2))) or
                                 (perr_addr_l2 (0 to 5) and     (0 to 5 => perr_sm_l2(2))) ;


   ex5_ctl: tri_rlmreg_p
   generic map (init => 0, expand_type => expand_type, width => 15)
   port map (nclk     => nclk,
             act      => tihi,
             forcee => forcee,
             delay_lclkr => delay_lclkr(5),
             mpw1_b      => mpw1_b(5),
             mpw2_b      => mpw2_b(1),
             thold_b  => thold_0_b,
             sg       => sg_0,
             vd       => vdd,
             gd       => gnd,
             scin     => ex5_ctl_si(0 to 14),
             scout    => ex5_ctl_so(0 to 14),
             din(0 to 3)    => ex5_instr_valid_din(0 to 3),
             din(4 to 9)    => ex5_instr_frt_din(0 to 5),
             din(10)        => ex5_record_din,
             din(11)        => ex5_mcrfs_din,
             din(12)        => ex4_is_ucode,
             din(13)        => ex5_cr_val_din,
             din(14)        => ex5_kill_wen_din,
             dout(0 to 3)   => ex5_instr_v(0 to 3),
             dout(4 to 9)   => ex5_instr_frt(0 to 5),
             dout(10)       => ex5_record,
             dout(11)       => ex5_mcrfs,
             dout(12)       => ex5_is_ucode,
             dout(13)       => ex5_cr_val,
             dout(14)       => ex5_kill_wen
             );

   ex5_instr_tid(0) <= ex5_instr_v(2) or ex5_instr_v(3);
   ex5_instr_tid(1) <= ex5_instr_v(1) or ex5_instr_v(3);




ex5_reload_val_b(0) <= not (xu_fu_ex5_load_val(0) and xu_fu_ex5_reload_val);
ex5_reload_val_b(1) <= not (xu_fu_ex5_load_val(1) and xu_fu_ex5_reload_val);
ex5_reload_val_b(2) <= not (xu_fu_ex5_load_val(2) and xu_fu_ex5_reload_val);
ex5_reload_val_b(3) <= not (xu_fu_ex5_load_val(3) and xu_fu_ex5_reload_val);


   u5_iflsh_int0b: ex5_iflush_int_b(0) <= not( xu_ex5_flush(0) and ex5_reload_val_b(0) );
   u5_iflsh_int1b: ex5_iflush_int_b(1) <= not( xu_ex5_flush(1) and ex5_reload_val_b(1) );
   u5_iflsh_int2b: ex5_iflush_int_b(2) <= not( xu_ex5_flush(2) and ex5_reload_val_b(2) );
   u5_iflsh_int3b: ex5_iflush_int_b(3) <= not( xu_ex5_flush(3) and ex5_reload_val_b(3) );

   u5_iflsh_int0: xu_ex5_flush_int(0) <= not( ex5_iflush_int_b(0) );
   u5_iflsh_int1: xu_ex5_flush_int(1) <= not( ex5_iflush_int_b(1) );
   u5_iflsh_int2: xu_ex5_flush_int(2) <= not( ex5_iflush_int_b(2) );
   u5_iflsh_int3: xu_ex5_flush_int(3) <= not( ex5_iflush_int_b(3) );

f_dcd_ex5_flush_int <=    xu_ex5_flush_int(0 to 3) ;



   u5_iflsh0: ex5_iflush_b(0) <= not( xu_ex5_flush(0) and ex5_instr_v(0) );
   u5_iflsh1: ex5_iflush_b(1) <= not( xu_ex5_flush(1) and ex5_instr_v(1) );
   u5_iflsh2: ex5_iflush_b(2) <= not( xu_ex5_flush(2) and ex5_instr_v(2) );
   u5_iflsh3: ex5_iflush_b(3) <= not( xu_ex5_flush(3) and ex5_instr_v(3) );

   u5_iflsh_01: ex5_iflush_01   <= not( ex5_iflush_b(0) and ex5_iflush_b(1) );
   u5_iflsh_23: ex5_iflush_23   <= not( ex5_iflush_b(2) and ex5_iflush_b(3) ); 

   u5_iflsh_b: ex5_instr_flush_b <= not( ex5_iflush_01 or ex5_iflush_23 ) ;

   u5_iflsh: ex5_instr_flush <= not ex5_instr_flush_b ;





  ex5_instr_valid(0)    <= ex5_instr_v(0) and not xu_ex5_flush(0);  
  ex5_instr_valid(1)    <= ex5_instr_v(1) and not xu_ex5_flush(1);
  ex5_instr_valid(2)    <= ex5_instr_v(2) and not xu_ex5_flush(2);
  ex5_instr_valid(3)    <= ex5_instr_v(3) and not xu_ex5_flush(3);

  ex6_instr_valid_din(0)     <= ex5_instr_valid(0) or (perr_sm_l2(2) and ex5_perr_sm_instr_v and perr_tid_enc(0 to 1)="00");
  ex6_instr_valid_din(1)     <= ex5_instr_valid(1) or (perr_sm_l2(2) and ex5_perr_sm_instr_v and perr_tid_enc(0 to 1)="01");
  ex6_instr_valid_din(2)     <= ex5_instr_valid(2) or (perr_sm_l2(2) and ex5_perr_sm_instr_v and perr_tid_enc(0 to 1)="10");
  ex6_instr_valid_din(3)     <= ex5_instr_valid(3) or (perr_sm_l2(2) and ex5_perr_sm_instr_v and perr_tid_enc(0 to 1)="11");

  ex6_kill_wen_din <= (ex5_kill_wen or not f_pic_ex5_fpr_wr_dis_b) and not (perr_sm_l2(2) and ex5_perr_sm_instr_v);

  
   ex5_instr_bypval(0)    <= ex5_instr_v(0) and f_pic_ex5_fpr_wr_dis_b  and not ex5_kill_wen;
   ex5_instr_bypval(1)    <= ex5_instr_v(1) and f_pic_ex5_fpr_wr_dis_b  and not ex5_kill_wen;
   ex5_instr_bypval(2)    <= ex5_instr_v(2) and f_pic_ex5_fpr_wr_dis_b  and not ex5_kill_wen;
   ex5_instr_bypval(3)    <= ex5_instr_v(3) and f_pic_ex5_fpr_wr_dis_b  and not ex5_kill_wen;


   f_dcd_ex5_frt_tid(0 to 1)  <= ex5_instr_tid(0 to 1);

   ex6_record_din     <= ex5_record  and not ex5_instr_flush; 
   ex6_mcrfs_din      <= ex5_mcrfs   and not ex5_instr_flush;
   ex6_cr_val_din     <= ex5_cr_val  and not ex5_instr_flush;

   

   ex6_ctl: tri_rlmreg_p
   generic map (init => 0, expand_type => expand_type, width => 16)
   port map (nclk     => nclk,
             act      => tihi,
             forcee => forcee,
             delay_lclkr => delay_lclkr(6),
             mpw1_b      => mpw1_b(6),
             mpw2_b      => mpw2_b(1),
             thold_b  => thold_0_b,
             sg       => sg_0,
             vd       => vdd,
             gd       => gnd,
             scin     => ex6_ctl_si(0 to 15),
             scout    => ex6_ctl_so(0 to 15),
             din(0 to 3)    => ex6_instr_valid_din(0 to 3),
             din(4 to 9)    => ex5_instr_frt(0 to 5),
             din(10)        => ex6_record_din,
             din(11)        => ex6_mcrfs_din,
             din(12)        => ex5_is_ucode,
             din(13)        => ex6_cr_val_din,
             din(14)        => ex6_kill_wen_din,
             din(15)        => ex5_perr_sm_instr_v,
             dout(0 to 3)   => ex6_instr_v(0 to 3),
             dout(4 to 9)   => ex6_instr_frt(0 to 5),
             dout(10)       => ex6_record,
             dout(11)       => ex6_mcrfs,
             dout(12)       => ex6_is_ucode,
             dout(13)       => ex6_cr_val,
             dout(14)       => ex6_kill_wen,
             dout(15)       => ex6_is_fixperr
             );

   ex6_instr_tid(0) <= ex6_instr_v(2) or ex6_instr_v(3);
   ex6_instr_tid(1) <= ex6_instr_v(1) or ex6_instr_v(3);

   ex6_instr_valid             <= or_reduce(ex6_instr_v(0 to 3)) ;

   f_dcd_ex6_frt_addr(0 to 5)  <= ex6_instr_frt(0 to 5);
   f_dcd_ex6_frt_tid(0 to 1)   <= ex6_instr_tid(0 to 1);
   f_dcd_ex6_frt_wen           <= ex6_instr_valid and not ex6_kill_wen;

   f_dcd_ex6_cancel            <= not ex6_instr_valid;

      ex6_record_v(0)             <= ex6_instr_v(0) and (ex6_record or ex6_mcrfs);
      ex6_record_v(1)             <= ex6_instr_v(1) and (ex6_record or ex6_mcrfs);
      ex6_record_v(2)             <= ex6_instr_v(2) and (ex6_record or ex6_mcrfs);
      ex6_record_v(3)             <= ex6_instr_v(3) and (ex6_record or ex6_mcrfs);
   

   ex6_bf(0 to 2)       <= (ex6_instr_frt(1 to 3) and     (1 to 3 => ex6_mcrfs)) or
                           ( "001"                and not (1 to 3 => ex6_mcrfs));



   ex7_ctl: tri_rlmreg_p
   generic map (init => 0, expand_type => expand_type, width => 7)
   port map (nclk     => nclk,
             act      => tihi,
             forcee => forcee,
             delay_lclkr => delay_lclkr(7),
             mpw1_b      => mpw1_b(7),
             mpw2_b      => mpw2_b(1),
             thold_b  => thold_0_b,
             sg       => sg_0,
             vd       => vdd,
             gd       => gnd,
             scin     => ex7_ctl_si(0 to 6),
             scout    => ex7_ctl_so(0 to 6),
             din(0 to 3)    => ex6_record_v(0 to 3),
             din(4 to 6)    => ex6_bf(0 to 2),
             dout(0 to 3)   => ex7_record_v(0 to 3),
             dout(4 to 6)   => ex7_bf(0 to 2)
             );


   perr_sm: tri_rlmreg_p
   generic map (init => 4, expand_type => expand_type, width => 3)
   port map (nclk    => nclk,
             act     => tihi,
             forcee => forcee,
             delay_lclkr => delay_lclkr(9),
             mpw1_b      => mpw1_b(9),
             mpw2_b      => mpw2_b(1),
             thold_b => thold_0_b,
             sg      => sg_0,
             vd       => vdd,
             gd       => gnd,
             scin    => perr_sm_si(0 to 2),
             scout   => perr_sm_so(0 to 2),
             din( 0 to  2)  => perr_sm_din(0 to 2)       ,
             dout( 0 to  2) => perr_sm_l2(0 to 2)        
             );
   perr_ctl: tri_rlmreg_p
   generic map (init => 0, expand_type => expand_type, width => 25)
   port map (nclk    => nclk,
             act     => msr_fp_act,
             forcee => forcee,
             delay_lclkr => delay_lclkr(9),
             mpw1_b      => mpw1_b(9),
             mpw2_b      => mpw2_b(1),
             thold_b => thold_0_b,
             sg      => sg_0,
             vd       => vdd,
             gd       => gnd,
             scin    => perr_ctl_si(0 to 24),
             scout   => perr_ctl_so(0 to 24),
             din( 0 to  5)  => perr_addr_din(0 to 5),
             din( 6 to  9)  => perr_tid_din(0 to 3),
             din(10)        => perr_move_f0_to_f1,
             din(11)        => perr_move_f1_to_f0,
             din(12)        => rf0_perr_force_c,
             din(13)        => rf1_perr_force_c,
             din(14)        => new_perr_sm_instr_v,
             din(15)        => rf0_perr_sm_instr_v,
             din(16)        => rf1_perr_sm_instr_v,
             din(17)        => ex1_perr_sm_instr_v,
             din(18)        => ex2_perr_sm_instr_v,
             din(19)        => ex3_perr_sm_instr_v,
             din(20)        => ex4_perr_sm_instr_v,
             din(21)        => xu_fu_regfile_seq_beg,
             din(22)        =>       regfile_seq_end,
             din(23)        => rf0_regfile_ue,
             din(24)        => rf0_regfile_ce,
             dout( 0 to  5) => perr_addr_l2(0 to 5) ,
             dout( 6 to  9) => perr_tid_l2(0 to 3),
             dout(10)       => perr_move_f0_to_f1_l2,
             dout(11)       => perr_move_f1_to_f0_l2,
             dout(12)       => rf1_perr_force_c,
             dout(13)       => ex1_perr_force_c,
             dout(14)       => rf0_perr_sm_instr_v,     
             dout(15)       => rf1_perr_sm_instr_v,
             dout(16)       => ex1_perr_sm_instr_v,       
             dout(17)       => ex2_perr_sm_instr_v,       
             dout(18)       => ex3_perr_sm_instr_v,       
             dout(19)       => ex4_perr_sm_instr_v,
             dout(20)       => ex5_perr_sm_instr_v,
             dout(21)       =>       regfile_seq_beg,
             dout(22)       => fu_xu_regfile_seq_end,
             dout(23)       => rf1_regfile_ue,
             dout(24)       => rf1_regfile_ce
             );

   rf0_perr_sm_instr_v_b  <= not rf0_perr_sm_instr_v;

   perr_tid_enc(0) <= perr_tid_l2(2) or perr_tid_l2(3);
   perr_tid_enc(1) <= perr_tid_l2(1) or perr_tid_l2(3);


         perr_sm_running <= not perr_sm_l2(0);
   f_dcd_perr_sm_running <= perr_sm_running;

   perr_sm_ns(0)  <=  (perr_sm_l2(2) and rf0_regfile_ue) or (perr_sm_l2(2) and ex5_perr_sm_instr_v);
   regfile_seq_end <= perr_sm_ns(0) ;

   perr_sm_ns(1)  <=  perr_sm_l2(0) and regfile_seq_beg;

   perr_sm_ns(2)  <=  perr_sm_l2(1) and ex5_perr_sm_instr_v;

   perr_move_f0_to_f1 <= ex2_f1b_perr when  (perr_sm_l2(1) and ex2_perr_sm_instr_v) = '1' else 
                         perr_move_f0_to_f1_l2 ;
   perr_move_f1_to_f0 <= ex2_f0c_perr when  (perr_sm_l2(1) and ex2_perr_sm_instr_v) = '1' else 
                         perr_move_f1_to_f0_l2 ;

     
   rf0_perr_move_f0_to_f1 <= perr_move_f0_to_f1_l2 and (perr_sm_l2(2) and rf0_perr_sm_instr_v);
   rf0_perr_move_f1_to_f0 <= perr_move_f1_to_f0_l2 and (perr_sm_l2(2) and rf0_perr_sm_instr_v);

   rf0_perr_force_c       <= rf0_perr_move_f0_to_f1 and not rf0_perr_move_f1_to_f0;

   f_dcd_ex1_perr_force_c <= ex1_perr_force_c;
   f_dcd_ex1_perr_fsel_ovrd <= ex1_perr_sm_instr_v and perr_sm_l2(2);

   perr_sm_din(0 to 2)  <= ("100" and (0 to 2 => perr_sm_ns(0))) or
                           ("010" and (0 to 2 => perr_sm_ns(1))) or
                           ("001" and (0 to 2 => perr_sm_ns(2))) or
                           (perr_sm_l2 and (0 to 2 => not (or_reduce(perr_sm_ns(0 to 2)))));

   new_perr_sm_instr_v   <= perr_sm_ns(1) or perr_sm_ns(2);


   perr_addr_din(0 to 5)   <=  ex2_instr_fra(0 to 5) when (ex2_f0a_perr and ex2_regfile_err_det and perr_sm_l2(0)) = '1' else 
                               ex2_instr_frb(0 to 5) when (ex2_f1b_perr and ex2_regfile_err_det and perr_sm_l2(0)) = '1' else 
                               ex2_instr_frc(0 to 5) when (ex2_f0c_perr and ex2_regfile_err_det and perr_sm_l2(0)) = '1' else 
                               ex2_instr_frs(0 to 5) when (ex2_f1s_perr and ex2_regfile_err_det and perr_sm_l2(0)) = '1' else 
                               perr_addr_l2(0 to 5);


   perr_tid_din(0 to 3)         <= (ex2_fpr_perr(0 to 3)    and (0 to 3 => ex2_regfile_err_det and perr_sm_l2(0))) or
                                   (perr_tid_l2(0 to 3) and not (0 to 3 => ex2_regfile_err_det and perr_sm_l2(0)));

   u_pc_o1:  rf0_frc_perr_x_b(0 to 5) <= not( perr_addr_l2    (0 to 5) and (0 to 5 => rf0_perr_sm_instr_v  ) );
   u_pc_o2:  rf0_frc_iu_x_b(0 to 5)   <= not( rf0_instr_frc   (0 to 5) and (0 to 5 => rf0_perr_sm_instr_v_b) );
   u_pc_o:   f_dcd_rf0_frc(0 to 5)    <= not( rf0_frc_perr_x_b(0 to 5) and  rf0_frc_iu_x_b(0 to 5)          );

   u_pb_o1:  rf0_frb_perr_x_b(0 to 5) <= not( perr_addr_l2    (0 to 5) and (0 to 5 => rf0_perr_sm_instr_v  ) );
   u_pb_o2:  rf0_frb_iu_x_b(0 to 5)   <= not( rf0_instr_frb   (0 to 5) and (0 to 5 => rf0_perr_sm_instr_v_b) );
   u_pb_o:   f_dcd_rf0_frb(0 to 5)    <= not( rf0_frb_perr_x_b(0 to 5) and  rf0_frb_iu_x_b(0 to 5)          );

   u_pt_o1:  rf0_tid_perr_x_b(0 to 1) <= not( perr_tid_enc    (0 to 1) and (0 to 1 => rf0_perr_sm_instr_v  ) );
   u_pt_o2:  rf0_tid_iu_x_b(0 to 1)   <= not( rf0_tid         (0 to 1) and (0 to 1 => rf0_perr_sm_instr_v_b) );
   u_pt_o:   f_dcd_rf0_tid(0 to 1)    <= not( rf0_tid_perr_x_b(0 to 1) and  rf0_tid_iu_x_b(0 to 1)          );

   rf0_regfile_ce     <= (rf0_perr_move_f0_to_f1 or  rf0_perr_move_f1_to_f0) and not (rf0_perr_move_f0_to_f1 and rf0_perr_move_f1_to_f0);
   rf0_regfile_ue     <=  rf0_perr_move_f0_to_f1 and rf0_perr_move_f1_to_f0;

   err_regfile_parity(0 to 3) <= perr_tid_l2(0 to 3) and (0 to 3 => rf1_regfile_ce);
   err_regfile_ue(0 to 3)     <= perr_tid_l2(0 to 3) and (0 to 3 => rf1_regfile_ue);


   fu_err_rpt : entity tri.tri_direct_err_rpt(tri_direct_err_rpt) 
     generic map (width => 8, expand_type => expand_type)
     port map (vd => vdd, gd => gnd,
               err_in(0)  => err_regfile_parity(0),
               err_in(1)  => err_regfile_parity(1),
               err_in(2)  => err_regfile_parity(2),
               err_in(3)  => err_regfile_parity(3),
               err_in(4)  => err_regfile_ue(0),
               err_in(5)  => err_regfile_ue(1),
               err_in(6)  => err_regfile_ue(2),
               err_in(7)  => err_regfile_ue(3),
               err_out(0) => fu_pc_err_regfile_parity(0),
               err_out(1) => fu_pc_err_regfile_parity(1),
               err_out(2) => fu_pc_err_regfile_parity(2),
               err_out(3) => fu_pc_err_regfile_parity(3),
               err_out(4) => fu_pc_err_regfile_ue(0),
               err_out(5) => fu_pc_err_regfile_ue(1),
               err_out(6) => fu_pc_err_regfile_ue(2),
               err_out(7) => fu_pc_err_regfile_ue(3) );




 ucode_hooks : entity work.fuq_dcd_uc_hooks
 generic map(expand_type         => expand_type)
 port map(
         nclk                               =>   nclk,
         thold_0_b                          =>   thold_0_b,                     
         sg_0                               =>   sg_0,                    
         f_ucode_si                         =>   f_ucode_si,
         forcee => forcee,            
         delay_lclkr                        =>   delay_lclkr(9),
         mpw1_b                             =>   mpw1_b(9),
         mpw2_b                             =>   mpw2_b(1),               
         vdd                                =>   vdd,                  
         gnd                                =>   gnd,
         msr_fp_act                         =>   msr_fp_act,
         perr_sm_running                    =>   perr_sm_running,       
         iu_fu_rf0_instr_v                  =>   iu_fu_rf0_instr_v,               
         iu_fu_rf0_instr                    =>   iu_fu_rf0_instr,               
         ucode_mode_rf0                     =>   iu_fu_rf0_is_ucode,
         iu_fu_rf0_ucfmul                   =>   iu_fu_rf0_ucfmul,
         f_mad_ex3_uc_round_mode            =>   f_mad_ex3_uc_round_mode,             
         rf0_instr_fra                      =>   rf0_instr_fra,               
         f_dcd_rf0_fra                      =>   f_dcd_rf0_fra,               
         iu_fu_rf0_ifar                     =>   iu_fu_rf0_ifar(58 to 61),               
         thread_id_rf0                      =>   thread_id_rf0,
         xu_rf0_flush                       =>   xu_rf0_flush,                
         xu_rf1_flush                       =>   xu_rf1_flush,
         xu_ex1_flush                       =>   xu_ex1_flush,
         xu_ex2_flush                       =>   xu_ex2_flush,
         xu_ex3_flush                       =>   xu_ex3_flush,
         xu_ex4_flush                       =>   xu_ex4_flush,
         xu_ex5_flush                       =>   xu_ex5_flush,
         f_mad_ex3_uc_res_sign              =>   f_mad_ex3_uc_res_sign,           
         f_mad_ex6_uc_sign                  =>   f_mad_ex6_uc_sign,              
         f_mad_ex6_uc_zero                  =>   f_mad_ex6_uc_zero,
         f_mad_ex3_uc_special               =>   f_mad_ex3_uc_special,
         f_mad_ex3_uc_vxsnan                =>   f_mad_ex3_uc_vxsnan,
         f_mad_ex3_uc_zx                    =>   f_mad_ex3_uc_zx,        
         f_mad_ex3_uc_vxidi                 =>   f_mad_ex3_uc_vxidi,        
         f_mad_ex3_uc_vxzdz                 =>   f_mad_ex3_uc_vxzdz,        
         f_mad_ex3_uc_vxsqrt                =>   f_mad_ex3_uc_vxsqrt,        
         f_dcd_rf1_div_beg                  =>         rf1_div_beg,              
         f_dcd_rf1_sqrt_beg                 =>         rf1_sqrt_beg,
         f_dcd_rf1_uc_mid                   =>   f_dcd_rf1_uc_mid,
         f_dcd_rf1_uc_end                   =>         rf1_uc_end,
         ex4_uc_special                     =>         ex4_uc_special,
         f_dcd_rf1_uc_special               =>   f_dcd_rf1_uc_special,
         f_dcd_rf1_uc_ft_pos                =>   f_dcd_rf1_uc_ft_pos,              
         f_dcd_rf1_uc_ft_neg                =>   f_dcd_rf1_uc_ft_neg,              
         f_dcd_rf1_uc_fa_pos                =>   f_dcd_rf1_uc_fa_pos,              
         f_dcd_rf1_uc_fc_pos                =>   f_dcd_rf1_uc_fc_pos,              
         f_dcd_rf1_uc_fb_pos                =>   f_dcd_rf1_uc_fb_pos,              
         f_dcd_rf1_uc_fc_hulp               =>   f_dcd_rf1_uc_fc_hulp,              
         f_dcd_rf1_uc_fc_0_5                =>   f_dcd_rf1_uc_fc_0_5,              
         f_dcd_rf1_uc_fc_1_0                =>   f_dcd_rf1_uc_fc_1_0,              
         f_dcd_rf1_uc_fc_1_minus            =>   f_dcd_rf1_uc_fc_1_minus,             
         f_dcd_rf1_uc_fb_1_0                =>   f_dcd_rf1_uc_fb_1_0,             
         f_dcd_rf1_uc_fb_0_75               =>   f_dcd_rf1_uc_fb_0_75,             
         f_dcd_rf1_uc_fb_0_5                =>   f_dcd_rf1_uc_fb_0_5 ,
         f_dcd_rf1_uc_fa_dis_par            =>   f_dcd_rf1_uc_fa_dis_par,
         f_dcd_rf1_uc_fb_dis_par            =>   f_dcd_rf1_uc_fb_dis_par,
         f_dcd_rf1_uc_fc_dis_par            =>   f_dcd_rf1_uc_fc_dis_par,
         uc_op_rnd_v_rf1                    =>         rf1_uc_op_rnd_v,             
         uc_op_rnd_rf1                      =>         rf1_uc_op_rnd,             
         f_dcd_ex2_uc_inc_lsb               => f_dcd_ex2_uc_inc_lsb,             
         f_dcd_ex2_uc_gs_v                  => f_dcd_ex2_uc_gs_v              ,
         f_dcd_ex2_uc_gs                    => f_dcd_ex2_uc_gs                ,
         f_dcd_ex2_uc_vxsnan                => f_dcd_ex2_uc_vxsnan,
         f_dcd_ex2_uc_zx                    => f_dcd_ex2_uc_zx                ,
         f_dcd_ex2_uc_vxidi                 => f_dcd_ex2_uc_vxidi             ,
         f_dcd_ex2_uc_vxzdz                 => f_dcd_ex2_uc_vxzdz             ,
         f_dcd_ex2_uc_vxsqrt                => f_dcd_ex2_uc_vxsqrt            ,
         uc_hooks_rc_rf0                    => uc_hooks_rc_rf0,
         evnt_div_sqrt_ip                   => evnt_div_sqrt_ip,
         uc_hooks_debug                     => uc_hooks_debug,
         f_ucode_so                         =>   f_ucode_so                  
 );

   rf1_divsqrt_beg    <= rf1_div_beg or rf1_sqrt_beg;

   f_dcd_rf1_div_beg  <= rf1_div_beg;
   f_dcd_rf1_sqrt_beg <= rf1_sqrt_beg;
   f_dcd_rf1_uc_end   <= rf1_uc_end;

   fu_iu_uc_special(0 to 3) <= (0 to 3 => tilo);


   spr_ctl: tri_rlmreg_p
   generic map (init => 0, expand_type => expand_type, width => 15)
   port map (nclk     => nclk,
             act      => tihi,
             forcee => forcee,
             delay_lclkr => delay_lclkr(9),
             mpw1_b      => mpw1_b(9),
             mpw2_b      => mpw2_b(1),
             thold_b  => thold_0_b,
             sg       => sg_0,
             vd       => vdd,
             gd       => gnd,
             scin     => spr_ctl_si(0 to 14),
             scout    => spr_ctl_so(0 to 14),
             din(0)         => slowspr_in_val,
             din(1)         => slowspr_in_rw,
             din(2 to 3)    => slowspr_in_etid(0 to 1),
             din(4 to 13)   => slowspr_in_addr(0 to 9),
             din(14)        => slowspr_in_done,
             dout(0)        => slowspr_out_val,
             dout(1)        => slowspr_out_rw,
             dout(2 to 3)   => slowspr_out_etid(0 to 1),
             dout(4 to 13)  => slowspr_out_addr(0 to 9),
             dout(14)       => slowspr_out_done
             );
   spr_data: tri_rlmreg_p
   generic map (init => 0, expand_type => expand_type, width => 2**regmode)
   port map (nclk     => nclk,
             act      => tihi,
             forcee => forcee,
             delay_lclkr => delay_lclkr(9),
             mpw1_b      => mpw1_b(9),
             mpw2_b      => mpw2_b(1),
             thold_b  => thold_0_b,
             sg       => sg_0,
             vd       => vdd,
             gd       => gnd,
             scin     => spr_data_si(64-(2**regmode) to 63),
             scout    => spr_data_so(64-(2**regmode) to 63),
             din   => slowspr_in_data,
             dout  => slowspr_out_data
             );

   axucr0_lat: tri_rlmreg_p
   generic map (init => 0, expand_type => expand_type, width => 3)
   port map (nclk     => nclk,
             act      => tihi,
             forcee => cfg_sl_force,
             delay_lclkr => delay_lclkr(9),
             mpw1_b      => mpw1_b(9),
             mpw2_b      => mpw2_b(1),
             thold_b  => cfg_sl_thold_0_b,
             sg       => sg_0,
             vd       => vdd,
             gd       => gnd,
             scin     => axucr0_lat_si(0 to 2),
             scout    => axucr0_lat_so(0 to 2),
             din(0 to 2)  => axucr0_din(61 to 63),
             dout(0 to 2) => axucr0_q(61 to 63)
             );
   lcbs_cfg: tri_lcbs
     generic map (expand_type => expand_type )
     port map (
      vd          => vdd,
      gd          => gnd,
      delay_lclkr => delay_lclkr(9),
      nclk        => nclk,
      forcee => cfg_sl_force,
      thold_b     => cfg_sl_thold_0_b,
      dclk        => cfg_slat_d2clk,
      lclk        => cfg_slat_lclk );

   cfg_stg: tri_slat_scan  
      generic map (width => 2, init => "00", expand_type => expand_type)
      port map ( vd    => vdd,
              gd    => gnd,
              dclk  => cfg_slat_d2clk,
              lclk  => cfg_slat_lclk,
              scan_in(0)   => ccfg_scan_in,
              scan_in(1)   => bcfg_scan_in,
              scan_out(0)  => ccfg_scan_out,
              scan_out(1)  => bcfg_scan_out );


      f_dcd_rf1_force_excp_dis  <= axucr0_q(61);
      f_dcd_rf1_nj_deni         <= axucr0_q(62);
      f_dcd_rf1_nj_deno         <= axucr0_q(63);

      slowspr_in_val              <= slowspr_val_in  ;
      slowspr_in_rw               <= slowspr_rw_in   ;
      slowspr_in_etid             <= slowspr_etid_in ;
      slowspr_in_addr             <= slowspr_addr_in ;
      slowspr_in_data             <= slowspr_data_in ;
      slowspr_in_done             <= slowspr_done_in ;

      axucr0_dec                  <= slowspr_out_addr(0 to 9) = "1111010000";
      axucr0_rd                   <= slowspr_out_val and axucr0_dec and     slowspr_out_rw;
      axucr0_wr                   <= slowspr_out_val and axucr0_dec and not slowspr_out_rw;

      axucr0_din(61 to 63)        <= (slowspr_out_data(61 to 63) and (61 to 63 => axucr0_wr)) or
                                     (axucr0_q(61 to 63)     and not (61 to 63 => axucr0_wr));

      slowspr_data_out(64-(2**regmode) to 60) <=  slowspr_out_data(64-(2**regmode) to 60);

      slowspr_data_out(61 to 63)       <= (axucr0_q(61 to 63)         and     (61 to 63 => axucr0_rd)) or
                                      (slowspr_out_data(61 to 63) and not (61 to 63 => axucr0_rd));

      slowspr_val_out           <= slowspr_out_val    ;
      slowspr_rw_out            <= slowspr_out_rw     ;
      slowspr_etid_out          <= slowspr_out_etid   ;
      slowspr_addr_out          <= slowspr_out_addr   ;
      slowspr_done_out          <= slowspr_out_done or axucr0_rd or axucr0_wr ;



   ex6_ram_sign            <= f_rnd_ex6_res_sign;
   ex6_ram_frac(0 to 52)   <= f_rnd_ex6_res_frac(0 to 52);
   ex6_ram_expo(3 to 13)   <= f_rnd_ex6_res_expo(3 to 13);

   ex6_ram_done <= pc_fu_ram_mode and ex6_instr_valid and (pc_fu_ram_thread(0 to 1) = ex6_instr_tid(0 to 1))
                                  and not ex6_is_ucode    
                                  and not ex6_is_fixperr;

   ex7_ram_lat: tri_rlmreg_p
   generic map (init => 0, expand_type => expand_type, width => 65)
   port map (nclk     => nclk,
             act      => ex6_instr_valid,
             forcee => forcee,
             delay_lclkr => delay_lclkr(9),
             mpw1_b      => mpw1_b(9),
             mpw2_b      => mpw2_b(1),
             thold_b  => thold_0_b,
             sg       => sg_0,
             vd       => vdd,
             gd       => gnd,
             scin     => ram_data_si(0 to 64),
             scout    => ram_data_so(0 to 64),
             din(0)         => ex6_ram_sign,
             din(1  to 11)  => ex6_ram_expo(3 to 13),
             din(12 to 64)  => ex6_ram_frac(0 to 52),
             dout(0)        => ex7_ram_sign,
             dout(1  to 11) => ex7_ram_expo(3 to 13),
             dout(12 to 64) => ex7_ram_frac(0 to 52)
             );
   ex7_ramv_lat: tri_rlmreg_p
   generic map (init => 0, expand_type => expand_type, width => 1)
   port map (nclk     => nclk,
             act      => tihi,
             forcee => forcee,
             delay_lclkr => delay_lclkr(9),
             mpw1_b      => mpw1_b(9),
             mpw2_b      => mpw2_b(1),
             thold_b  => thold_0_b,
             sg       => sg_0,
             vd       => vdd,
             gd       => gnd,
             scin(0)  => ram_datav_si(0),
             scout(0) => ram_datav_so(0),
             din(0)        => ex6_ram_done,
             dout(0)       => ex7_ram_done
             );

   ex7_ram_data( 0)         <= ex7_ram_sign;
   ex7_ram_data( 1 to 11)   <= ex7_ram_expo(3 to 13) and (3 to 13 => ex7_ram_frac(0));
   ex7_ram_data(12 to 63)   <= ex7_ram_frac(1 to 52);

   fu_pc_ram_done           <= ex7_ram_done;
   fu_pc_ram_data(0 to 63)  <= ex7_ram_data(0 to 63);


   evnt_axu_instr_cmt(0) <=  ex6_instr_valid and (ex6_instr_tid(0 to 1) = "00") and not ex6_is_ucode and not ex6_is_fixperr;
   evnt_axu_instr_cmt(1) <=  ex6_instr_valid and (ex6_instr_tid(0 to 1) = "01") and not ex6_is_ucode and not ex6_is_fixperr;
   evnt_axu_instr_cmt(2) <=  ex6_instr_valid and (ex6_instr_tid(0 to 1) = "10") and not ex6_is_ucode and not ex6_is_fixperr;
   evnt_axu_instr_cmt(3) <=  ex6_instr_valid and (ex6_instr_tid(0 to 1) = "11") and not ex6_is_ucode and not ex6_is_fixperr;

   evnt_axu_cr_cmt(0) <=  ex6_instr_valid and (ex6_instr_tid(0 to 1) = "00") and (ex6_cr_val or ex6_record or ex6_mcrfs);
   evnt_axu_cr_cmt(1) <=  ex6_instr_valid and (ex6_instr_tid(0 to 1) = "01") and (ex6_cr_val or ex6_record or ex6_mcrfs);
   evnt_axu_cr_cmt(2) <=  ex6_instr_valid and (ex6_instr_tid(0 to 1) = "10") and (ex6_cr_val or ex6_record or ex6_mcrfs);
   evnt_axu_cr_cmt(3) <=  ex6_instr_valid and (ex6_instr_tid(0 to 1) = "11") and (ex6_cr_val or ex6_record or ex6_mcrfs);

   evnt_axu_idle(0) <=    (ex6_instr_tid(0 to 1) = "00") and not (ex6_instr_valid or ex6_cr_val or ex6_record or ex6_mcrfs); 
   evnt_axu_idle(1) <=    (ex6_instr_tid(0 to 1) = "01") and not (ex6_instr_valid or ex6_cr_val or ex6_record or ex6_mcrfs); 
   evnt_axu_idle(2) <=    (ex6_instr_tid(0 to 1) = "10") and not (ex6_instr_valid or ex6_cr_val or ex6_record or ex6_mcrfs); 
   evnt_axu_idle(3) <=    (ex6_instr_tid(0 to 1) = "11") and not (ex6_instr_valid or ex6_cr_val or ex6_record or ex6_mcrfs); 

   evnt_denrm_flush(0)   <= (ex4_instr_tid(0 to 1) = "00") and ex4_b_den_flush;
   evnt_denrm_flush(1)   <= (ex4_instr_tid(0 to 1) = "01") and ex4_b_den_flush;
   evnt_denrm_flush(2)   <= (ex4_instr_tid(0 to 1) = "10") and ex4_b_den_flush;
   evnt_denrm_flush(3)   <= (ex4_instr_tid(0 to 1) = "11") and ex4_b_den_flush;

   evnt_uc_instr_cmt(0) <=  ex6_instr_valid and (ex6_instr_tid(0 to 1) = "00") and ex6_is_ucode;
   evnt_uc_instr_cmt(1) <=  ex6_instr_valid and (ex6_instr_tid(0 to 1) = "01") and ex6_is_ucode;
   evnt_uc_instr_cmt(2) <=  ex6_instr_valid and (ex6_instr_tid(0 to 1) = "10") and ex6_is_ucode;
   evnt_uc_instr_cmt(3) <=  ex6_instr_valid and (ex6_instr_tid(0 to 1) = "11") and ex6_is_ucode;

   evnt_fpu_fx(0 to 3)   <=  f_scr_ex7_fx_thread0(0) & f_scr_ex7_fx_thread1(0) & f_scr_ex7_fx_thread2(0) & f_scr_ex7_fx_thread3(0) ;
   evnt_fpu_fex(0 to 3)  <=  f_scr_ex7_fx_thread0(1) & f_scr_ex7_fx_thread1(1) & f_scr_ex7_fx_thread2(1) & f_scr_ex7_fx_thread3(1) ;

   t0_events_in(0 to 7) <= evnt_axu_instr_cmt(0) & evnt_axu_cr_cmt(0)   & evnt_axu_idle(0) & evnt_div_sqrt_ip(0) &
                           evnt_denrm_flush(0)   & evnt_uc_instr_cmt(0) & evnt_fpu_fx(0)   & evnt_fpu_fex(0);
   t1_events_in(0 to 7) <= evnt_axu_instr_cmt(1) & evnt_axu_cr_cmt(1)   & evnt_axu_idle(1) & evnt_div_sqrt_ip(1) &
                           evnt_denrm_flush(1)   & evnt_uc_instr_cmt(1) & evnt_fpu_fx(1)   & evnt_fpu_fex(1);
   t2_events_in(0 to 7) <= evnt_axu_instr_cmt(2) & evnt_axu_cr_cmt(2)   & evnt_axu_idle(2) & evnt_div_sqrt_ip(2) &
                           evnt_denrm_flush(2)   & evnt_uc_instr_cmt(2) & evnt_fpu_fx(2)   & evnt_fpu_fex(2);
   t3_events_in(0 to 7) <= evnt_axu_instr_cmt(3) & evnt_axu_cr_cmt(3)   & evnt_axu_idle(3) & evnt_div_sqrt_ip(3) &
                           evnt_denrm_flush(3)   & evnt_uc_instr_cmt(3) & evnt_fpu_fx(3)   & evnt_fpu_fex(3);

   event_en_d  <= (    msr_pr_q and                  (0 to 3=> event_count_mode_q(0))) or 
                  (not msr_pr_q and     msr_gs_q and (0 to 3=> event_count_mode_q(1))) or 
                  (not msr_pr_q and not msr_gs_q and (0 to 3=> event_count_mode_q(2)));   

   t0_events      <= t0_events_in and (0 to 7 =>event_en_q(0));
   t1_events      <= t1_events_in and (0 to 7 =>event_en_q(1));
   t2_events      <= t2_events_in and (0 to 7 =>event_en_q(2));
   t3_events      <= t3_events_in and (0 to 7 =>event_en_q(3));


   event_mux: entity clib.c_event_mux
     generic map ( events_in => 32 )
     port map(
      vd                             => vdd                            ,
      gd                             => gnd                            ,
           t0_events            => t0_events,
           t1_events            => t1_events,
           t2_events            => t2_events,
           t3_events            => t3_events,

           select_bits          => pc_fu_event_mux_ctrls,
           event_bits           => event_data_d
   );

   perf_data: tri_rlmreg_p
   generic map (init => 0, expand_type => expand_type, width => 39)
   port map (nclk     => nclk,
             act      => event_act,
             forcee => func_slp_sl_force,
             delay_lclkr => delay_lclkr(9),
             mpw1_b      => mpw1_b(9),
             mpw2_b      => mpw2_b(1),
             thold_b  => func_slp_sl_thold_0_b,
             sg       => sg_0,
             vd       => vdd,
             gd       => gnd,
             scin     => perf_data_si(0 to 38),
             scout    => perf_data_so(0 to 38),
             din( 0 to  7)  => event_data_d(0 to 7),
             din( 8 to 11)  => event_en_d(0 to 3),
             din(12)        => ex4_b_den_flush_din,
             din(13 to 15)  => pc_fu_event_count_mode(0 to 2),
             din(16 to 19)  => xu_fu_msr_pr(0 to 3),
             din(20 to 23)  => xu_fu_msr_gs(0 to 3),
             din(24)        => pc_fu_instr_trace_mode,
             din(25 to 26)  => pc_fu_instr_trace_tid(0 to 1),
             din(27 to 30)  => rf0_instr_tid_1hot(0 to 3),
             din(31 to 34)  => rf1_instr_iss(0 to 3),
             din(35 to 38)  => ex1_instr_iss(0 to 3),

             dout( 0 to  7) => event_data_q(0 to 7),
             dout( 8 to 11) => event_en_q(0 to 3),
             dout(12)       => ex4_b_den_flush,
             dout(13 to 15) => event_count_mode_q(0 to 2),
             dout(16 to 19) => msr_pr_q(0 to 3),
             dout(20 to 23) => msr_gs_q(0 to 3),
             dout(24)       => instr_trace_mode_q,
             dout(25 to 26) => instr_trace_tid_q(0 to 1),
             dout(27 to 30) => rf1_instr_iss(0 to 3),
             dout(31 to 34) => ex1_instr_iss(0 to 3),
             dout(35 to 38) => ex2_instr_iss(0 to 3)
             );



   trace_data_in(0 to 87)   <= debug_data_in(0 to 87);
   trigger_data_in(0 to 11) <= trace_triggers_in(0 to 11);

   dbg_group0  ( 0 to 63)     <=  ex7_ram_data(0 to 63);
   dbg_group0  (64 to 87)     <=  ex7_ram_expo(3 to 13) & ex7_ram_frac(0) & ex7_ram_done & (0 to 10 => '0');

   dbg_group1  (0 to 87)      <=  uc_hooks_debug(0 to 55) & (56 to 87 => '0');

   dbg_group2  (0 to 31)      <=  rf1_instr(0 to 31) and not (0 to 31 => instr_trace_mode_q and (instr_trace_tid_q(0 to 1) /= rf1_tid(0 to 1))); 

   dbg_group2  (32 to 35)     <=  (f_scr_ex7_fx_thread0(0 to 3) and not (0 to 3 => instr_trace_mode_q));
   dbg_group2  (36 to 39)     <=  (f_scr_ex7_fx_thread1(0 to 3) and not (0 to 3 => instr_trace_mode_q)) or ("1010" and (0 to 3 => instr_trace_mode_q)); 
   dbg_group2  (40 to 43)     <=  (f_scr_ex7_fx_thread2(0 to 3) and not (0 to 3 => instr_trace_mode_q)) or ("1011" and (0 to 3 => instr_trace_mode_q)); 
   dbg_group2  (44 to 47)     <=  (f_scr_ex7_fx_thread3(0 to 3) and not (0 to 3 => instr_trace_mode_q)) or ("1100" and (0 to 3 => instr_trace_mode_q)); 
   dbg_group2  (48 to 51)     <=  (ex4_eff_addr(59 to 62)       and not (0 to 3 => instr_trace_mode_q)) or ("1101" and (0 to 3 => instr_trace_mode_q)); 
   dbg_group2  (52 to 55)     <=  ((ex4_eff_addr(63) &perr_sm_l2(0 to 2)) and not (0 to 3 => instr_trace_mode_q)) or ("1110" and (0 to 3 => instr_trace_mode_q)); 
   dbg_group2  (56 to 61)     <=  perr_addr_l2(0 to 5)     and not (0 to 5 => instr_trace_mode_q); 
   dbg_group2  (62 to 65)     <=  perr_tid_l2(0 to 3)      and not (0 to 3 => instr_trace_mode_q); 
   dbg_group2  (66)           <=  rf0_perr_move_f0_to_f1   and not            instr_trace_mode_q ; 
   dbg_group2  (67)           <=  rf0_perr_move_f1_to_f0   and not            instr_trace_mode_q ; 
   dbg_group2  (68)           <=  rf1_regfile_ce           and not            instr_trace_mode_q ; 
   dbg_group2  (69)           <=  rf1_regfile_ue           and not            instr_trace_mode_q ; 
   dbg_group2  (70 to 87)     <=  (70 to 87=> tilo);

   dbg_group3  (0)            <=  rf1_regfile_ce;
   dbg_group3  (1)            <=  rf1_regfile_ue;
   dbg_group3  (2)            <=  rf1_bypsel_a_res0;
   dbg_group3  (3)            <=  rf1_bypsel_c_res0;
   dbg_group3  (4)            <=  rf1_bypsel_b_res0;
   dbg_group3  (5)            <=  rf1_bypsel_a_res1;
   dbg_group3  (6)            <=  rf1_bypsel_c_res1;
   dbg_group3  (7)            <=  rf1_bypsel_b_res1;
   dbg_group3  (8)            <=  rf1_bypsel_a_load0;
   dbg_group3  (9)            <=  rf1_bypsel_c_load0;
   dbg_group3  (10)           <=  rf1_bypsel_b_load0;
   dbg_group3  (11)           <=  rf1_bypsel_a_load1;
   dbg_group3  (12)           <=  rf1_bypsel_c_load1;
   dbg_group3  (13)           <=  rf1_bypsel_b_load1;
   dbg_group3  (14)           <=  rf1_frs_byp;
   dbg_group3  (15)           <=  rf1_v;
   dbg_group3  (16 to 31)     <=  (16 to 31 => '0');
   dbg_group3  (32 to 63)     <=  t0_events(0 to 7) & t1_events(0 to 7) & t2_events(0 to 7) & t3_events(0 to 7) ;
   dbg_group3  (64 to 87)     <=  (64 to 87=> tilo);

   trg_group0 ( 0 to  3)       <=  evnt_fpu_fx(0 to 3);
   trg_group0 ( 4 to  7)       <=  evnt_fpu_fex(0 to 3);
   trg_group0 ( 8)             <=  ex6_instr_valid;
   trg_group0 ( 9)             <=  ex6_is_ucode;
   trg_group0 (10 to 11)       <=  ex6_instr_tid(0 to 1);

   trg_group1 ( 0 to  2)       <=  perr_sm_l2(0 to 2);
   trg_group1 ( 3)             <=  rf1_regfile_ce;
   trg_group1 ( 4)             <=  rf1_regfile_ue;
   trg_group1 ( 5)             <=  ex6_instr_valid;
   trg_group1 ( 6 to  7)       <=  ex6_instr_tid(0 to 1);
   trg_group1 ( 8)             <=  ex3_instr_match;
   trg_group1 ( 9)             <=  ex6_record;
   trg_group1 (10)             <=  ex6_mcrfs;
   trg_group1 (11)             <=  ex4_b_den_flush;

   trg_group2 ( 0 to 11)       <=  uc_hooks_debug( 0 to 11); 
   trg_group3 ( 0 to 11)       <=  uc_hooks_debug(16 to 27); 


   debug_mux_ctrls_muxed(0 to 15) <= debug_mux_ctrls_q(0 to 15) when instr_trace_mode_q = '0' else
                                     ("10" & "000" & "00" & "1111" & "00" & '0' & "11");

   dbgmux: entity clib.c_debug_mux4
     port map(
      vd                             => vdd                            ,
      gd                             => gnd                            ,
      select_bits                    => debug_mux_ctrls_muxed          ,
      trace_data_in                  => trace_data_in                  ,
      trigger_data_in                => trigger_data_in                ,
      dbg_group0                     => dbg_group0                     ,
      dbg_group1                     => dbg_group1                     ,
      dbg_group2                     => dbg_group2                     ,
      dbg_group3                     => dbg_group3                     ,
      trg_group0                     => trg_group0                     ,
      trg_group1                     => trg_group1                     ,
      trg_group2                     => trg_group2                     ,
      trg_group3                     => trg_group3                     ,
      trace_data_out                 => trace_data_out                 ,
      trigger_data_out               => trigger_data_out               );



   debug_data_d(0 to 87) <= trace_data_out(0 to 87);
   debug_trig_d(0 to 11) <= trigger_data_out(0 to 11);
   ex4_b_den_flush_din   <= ex3_b_den_flush and or_reduce(ex3_instr_v(0 to 3));

   dbg0_data: tri_rlmreg_p
   generic map (init => 0, expand_type => expand_type, width => 116)
   port map (nclk     => nclk,
             act      => dbg0_act,
             forcee => func_slp_sl_force,
             delay_lclkr => delay_lclkr(9),
             mpw1_b      => mpw1_b(9),
             mpw2_b      => mpw2_b(1),
             thold_b  => func_slp_sl_thold_0_b,
             sg       => sg_0,
             vd       => vdd,
             gd       => gnd,
             scin     => dbg0_data_si(0 to 115),
             scout    => dbg0_data_so(0 to 115),
             din(0  to 87)  => debug_data_d(0 to 87),
             din(88 to 99) => debug_trig_d(0 to 11),
             din(100 to 115) => pc_fu_debug_mux_ctrls(0 to 15),
             dout( 0 to 87) => debug_data_q(0 to 87),
             dout(88 to 99) => debug_trig_q(0 to 11),
             dout(100 to 115) => debug_mux_ctrls_q(0 to 15)
             );
   dbg1_data: tri_rlmreg_p
   generic map (init => 0, expand_type => expand_type, width => 5)
   port map (nclk     => nclk,
             act      => tihi,
             forcee => forcee,
             delay_lclkr => delay_lclkr(9),
             mpw1_b      => mpw1_b(9),
             mpw2_b      => mpw2_b(1),
             thold_b  => thold_0_b,
             sg       => sg_0,
             vd       => vdd,
             gd       => gnd,
             scin     => dbg1_data_si(0 to 4),
             scout    => dbg1_data_so(0 to 4),
             din( 0 to  4)  => xu_fu_ex3_eff_addr(59 to 63),
             dout( 0 to  4) => ex4_eff_addr(59 to 63)
             );

      debug_data_out(0 to 87)     <= debug_data_q(0 to 87);    
      trace_triggers_out(0 to 11) <= debug_trig_q(0 to 11);    
      fu_pc_event_data(0 to 7)    <= event_data_q(0 to 7);  



   spare_lat: tri_rlmreg_p
   generic map (init => 0, expand_type => expand_type, width => 24)
   port map (nclk    => nclk,
             act     => tihi,
             forcee => forcee,
             delay_lclkr => delay_lclkr(9),
             mpw1_b      => mpw1_b(9),
             mpw2_b      => mpw2_b(1),
             thold_b => thold_0_b,
             sg      => sg_0,
             vd       => vdd,
             gd       => gnd,
             scin    => spare_si(0 to 23),
             scout   => spare_so(0 to 23),
             din( 0 to  23)  => SPARE_L2(0 to 23) ,
             dout( 0 to  23) => SPARE_L2(0 to 23)        
             );


      spare_unused( 0)       <= iu_fu_rf0_ldst_tag(2);
      spare_unused( 1)       <= iu_fu_rf0_frt(0);
      spare_unused( 2)       <= iu_fu_rf0_fra(0);
      spare_unused( 3)       <= iu_fu_rf0_frb(0);
      spare_unused( 4)       <= iu_fu_rf0_frc(0);
      spare_unused( 5 to  8) <= xu_is2_flush(0 to 3);
      spare_unused( 9 to 10) <= f_rnd_ex6_res_expo(1 to 2);
      
      
      rf1_iu_si    (0 to 14) <= rf1_iu_so    (1 to 14)  & f_dcd_si;
      act_lat_si   (0 to 2)  <= act_lat_so   (1 to 2)   & rf1_iu_so  (0);
      rf0_thread_si(0 to 3)  <= rf0_thread_so(1 to 3)   & act_lat_so (0);
      rf1_frt_si   (0 to 31) <= rf1_frt_so   (1 to 31)  & rf0_thread_so(0);
      rf1_ifr_si   (62-eff_ifar to 61) <= rf1_ifr_so(63-eff_ifar to 61)  & rf1_frt_so (0);
      rf1_instl_si (0 to 31) <= rf1_instl_so (1 to 31)  & rf1_ifr_so (62-eff_ifar);
      rf1_byp_si   (0 to 11) <= rf1_byp_so   (1 to 11)  & rf1_instl_so(0);
      ex1_ctl_si   (0 to 7)  <= ex1_ctl_so   (1 to 7)   & rf1_byp_so (0);
      ex1_frt_si   (0 to 17) <= ex1_frt_so   (1 to 17)   & ex1_ctl_so (0);
      ex1_perr_si  (0 to 23) <= ex1_perr_so  (1 to 23)  & ex1_frt_so (0);
      ex1_ifar_si  (62-eff_ifar to 61) <= ex1_ifar_so(63-eff_ifar to 61)  & ex1_perr_so (0);
      ex2_ctl_si   (0 to 15) <= ex2_ctl_so   (1 to 15)  & ex1_ifar_so(62-eff_ifar);
      ex2_ctlng_si (0 to 16) <= ex2_ctlng_so (1 to 16)  & ex2_ctl_so (0);
      ex2_perr_si  (0 to 23) <= ex2_perr_so  (1 to 23)  & ex2_ctlng_so(0);
      ex2_stdv_si            <=                           ex2_perr_so (0) ;  
      ex3_ctlng_si (0 to 15)  <= ex3_ctlng_so(1 to 15)   & ex2_stdv_so;
      ex3_ctl_si   (0 to 12) <= ex3_ctl_so   (1 to 12)  & ex3_ctlng_so(0);
      ex4_ctl_si   (0 to 15) <= ex4_ctl_so   (1 to 15)  & ex3_ctl_so (0);  
      ex5_ctl_si   (0 to 14) <= ex5_ctl_so   (1 to 14)  & ex4_ctl_so (0);
      ex6_ctl_si   (0 to 15) <= ex6_ctl_so   (1 to 15)  & ex5_ctl_so (0);
      ex7_ctl_si   (0 to 6)  <= ex7_ctl_so   (1 to 6)   & ex6_ctl_so (0);
      perr_sm_si   (0 to 2)  <= perr_sm_so   (1 to 2)   & ex7_ctl_so (0);
      perr_ctl_si  (0 to 24) <= perr_ctl_so  (1 to 24)  & perr_sm_so (0);
      spr_ctl_si   (0 to 14) <= spr_ctl_so   (1 to 14)  & perr_ctl_so(0);
      spr_data_si  (64-(2**regmode) to 63) <= spr_data_so(65-(2**regmode) to 63)  & spr_ctl_so (0);
      ram_data_si  (0 to 64) <= ram_data_so  (1 to 64)  & spr_data_so(64-(2**regmode));
      ram_datav_si(0)        <= ram_data_so(0);
      perf_data_si (0 to 38)  <= perf_data_so(1 to 38)   & ram_datav_so(0);
      dbg0_data_si (0 to 115) <= dbg0_data_so(1 to 115)  & perf_data_so(0);
      dbg1_data_si (0 to 4)   <= dbg1_data_so(1 to 4)    & dbg0_data_so(0);
      f_ucode_si              <=                           dbg1_data_so(0);
      spare_si     (0 to 23)  <= spare_so(1 to 23)       & f_ucode_so;
      f_dcd_so                <=                           spare_so(0);

      axucr0_lat_si(0 to 2)   <= axucr0_lat_so(1 to 2) & dcfg_scan_in;
      dcfg_scan_out           <= axucr0_lat_so(0);

end architecture fuq_dcd;

