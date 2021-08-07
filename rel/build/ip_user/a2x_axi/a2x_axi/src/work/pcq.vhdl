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

library ieee;
use ieee.std_logic_1164.all;
library ibm,clib;
use ibm.std_ulogic_support.all;
use ibm.std_ulogic_function_support.all;
library support;
use support.power_logic_pkg.all;
library tri;
use tri.tri_latches_pkg.all;


entity pcq is
generic(expand_type             : integer := 2;     
        regmode                 : integer := 6      
);         
port(
     vdd                        : inout power_logic;
     gnd                        : inout power_logic;
     nclk                       : in  clk_logic;

    an_ac_scom_sat_id           : in    std_ulogic_vector(0 to 3);
    an_ac_scom_dch              : in    std_ulogic;
    an_ac_scom_cch              : in    std_ulogic;
    ac_an_scom_dch              : out   std_ulogic;
    ac_an_scom_cch              : out   std_ulogic;
    slowspr_val_in              : in    std_ulogic;
    slowspr_rw_in               : in    std_ulogic;
    slowspr_etid_in             : in    std_ulogic_vector(0 to 1);
    slowspr_addr_in             : in    std_ulogic_vector(0 to 9);
    slowspr_data_in             : in    std_ulogic_vector(64-(2**regmode) to 63);
    slowspr_done_in             : in    std_ulogic;
    slowspr_val_out             : out   std_ulogic;
    slowspr_rw_out              : out   std_ulogic;
    slowspr_etid_out            : out   std_ulogic_vector(0 to 1);
    slowspr_addr_out            : out   std_ulogic_vector(0 to 9);
    slowspr_data_out            : out   std_ulogic_vector(64-(2**regmode) to 63);
    slowspr_done_out            : out   std_ulogic;

    ac_an_special_attn           : out   std_ulogic_vector(0 to 3);
    ac_an_checkstop              : out   std_ulogic_vector(0 to 2);
    ac_an_local_checkstop        : out   std_ulogic_vector(0 to 2);
    ac_an_recov_err              : out   std_ulogic_vector(0 to 2);
    ac_an_trace_error            : out   std_ulogic;
    an_ac_checkstop              : in    std_ulogic;
    an_ac_malf_alert             : in    std_ulogic;
    iu_pc_err_icache_parity      : in    std_ulogic;
    iu_pc_err_icachedir_parity   : in    std_ulogic;
    iu_pc_err_icachedir_multihit : in   std_ulogic;
    iu_pc_err_ucode_illegal      : in    std_ulogic_vector(0 to 3);
    xu_pc_err_dcache_parity      : in    std_ulogic;
    xu_pc_err_dcachedir_parity   : in    std_ulogic;
    xu_pc_err_dcachedir_multihit : in   std_ulogic;
    xu_pc_err_mcsr_summary       : in   std_ulogic_vector(0 to 3);
    xu_pc_err_ierat_parity       : in   std_ulogic;
    xu_pc_err_derat_parity       : in   std_ulogic;
    xu_pc_err_tlb_parity         : in   std_ulogic;
    xu_pc_err_tlb_lru_parity     : in   std_ulogic;
    xu_pc_err_ierat_multihit     : in   std_ulogic;
    xu_pc_err_derat_multihit     : in   std_ulogic;
    xu_pc_err_tlb_multihit       : in   std_ulogic;
    xu_pc_err_ext_mchk           : in   std_ulogic;
    xu_pc_err_ditc_overrun       : in   std_ulogic;
    xu_pc_err_local_snoop_reject : in   std_ulogic;
    xu_pc_err_sprg_ecc          : in    std_ulogic_vector(0 to 3);
    xu_pc_err_sprg_ue           : in    std_ulogic_vector(0 to 3);
    xu_pc_err_regfile_parity    : in    std_ulogic_vector(0 to 3);
    xu_pc_err_regfile_ue        : in    std_ulogic_vector(0 to 3);
    xu_pc_err_llbust_attempt    : in    std_ulogic_vector(0 to 3);
    xu_pc_err_llbust_failed     : in    std_ulogic_vector(0 to 3);
    xu_pc_err_l2intrf_ecc       : in    std_ulogic;
    xu_pc_err_l2intrf_ue        : in    std_ulogic;
    xu_pc_err_l2credit_overrun  : in    std_ulogic;
    xu_pc_err_wdt_reset         : in    std_ulogic_vector(0 to 3);
    xu_pc_err_attention_instr   : in    std_ulogic_vector(0 to 3);
    xu_pc_err_debug_event       : in    std_ulogic_vector(0 to 3);
    xu_pc_err_nia_miscmpr       : in    std_ulogic_vector(0 to 3);
    xu_pc_err_invld_reld        : in    std_ulogic;
    xu_pc_err_mchk_disabled     : in    std_ulogic;
    bx_pc_err_inbox_ecc         : in    std_ulogic;
    bx_pc_err_inbox_ue          : in    std_ulogic;
    bx_pc_err_outbox_ecc        : in    std_ulogic;
    bx_pc_err_outbox_ue         : in    std_ulogic;
    fu_pc_err_regfile_parity    : in    std_ulogic_vector(0 to 3);
    fu_pc_err_regfile_ue        : in    std_ulogic_vector(0 to 3);
    pc_iu_inj_icache_parity     : out   std_ulogic;
    pc_iu_inj_icachedir_parity  : out   std_ulogic;
    pc_xu_inj_dcache_parity     : out   std_ulogic;
    pc_xu_inj_dcachedir_parity  : out   std_ulogic;
    pc_xu_inj_sprg_ecc          : out   std_ulogic_vector(0 to 3);
    pc_xu_inj_regfile_parity    : out   std_ulogic_vector(0 to 3);
    pc_fu_inj_regfile_parity    : out   std_ulogic_vector(0 to 3);
    pc_bx_inj_inbox_ecc         : out   std_ulogic;
    pc_bx_inj_outbox_ecc        : out   std_ulogic;
    pc_xu_inj_llbust_attempt    : out   std_ulogic_vector(0 to 3);
    pc_xu_inj_llbust_failed     : out   std_ulogic_vector(0 to 3);
    pc_xu_inj_wdt_reset         : out   std_ulogic_vector(0 to 3);
    pc_iu_inj_icachedir_multihit : out  std_ulogic;
    pc_xu_inj_dcachedir_multihit : out  std_ulogic;

    pc_iu_ram_instr             : out   std_ulogic_vector(0 to 31);
    pc_iu_ram_instr_ext         : out   std_ulogic_vector(0 to 3);
    pc_iu_ram_mode              : out   std_ulogic;
    pc_iu_ram_thread            : out   std_ulogic_vector(0 to 1);
    pc_xu_ram_execute           : out   std_ulogic;
    pc_xu_ram_mode              : out   std_ulogic;
    pc_xu_ram_thread            : out   std_ulogic_vector(0 to 1);
    xu_pc_ram_interrupt         : in    std_ulogic;
    xu_pc_ram_done              : in    std_ulogic;
    xu_pc_ram_data              : in    std_ulogic_vector(64-(2**regmode) to 63);
    pc_fu_ram_mode              : out   std_ulogic;
    pc_fu_ram_thread            : out   std_ulogic_vector(0 to 1);
    fu_pc_ram_done              : in    std_ulogic;
    fu_pc_ram_data              : in    std_ulogic_vector(0 to 63);
    pc_xu_msrovride_enab        : out   std_ulogic;
    pc_xu_msrovride_pr          : out   std_ulogic;
    pc_xu_msrovride_gs          : out   std_ulogic;
    pc_xu_msrovride_de          : out   std_ulogic;
    pc_iu_ram_force_cmplt       : out   std_ulogic;
    pc_xu_ram_flush_thread      : out   std_ulogic;
    xu_pc_running               : in    std_ulogic_vector(0 to 3);  
    xu_pc_stop_dbg_event        : in    std_ulogic_vector(0 to 3);  
    xu_pc_step_done             : in    std_ulogic_vector(0 to 3);  
    pc_xu_stop                  : out   std_ulogic_vector(0 to 3);  
    pc_xu_step                  : out   std_ulogic_vector(0 to 3);  
    pc_xu_force_ude             : out   std_ulogic_vector(0 to 3);
    pc_xu_extirpts_dis_on_stop  : out   std_ulogic;
    pc_xu_timebase_dis_on_stop  : out   std_ulogic;
    pc_xu_decrem_dis_on_stop    : out   std_ulogic;
    an_ac_debug_stop            : in    std_ulogic;
    pc_xu_dbg_action            : out   std_ulogic_vector(0 to 11); 

    debug_bus_out               : out   std_ulogic_vector(0 to 87);
    trace_triggers_out          : out   std_ulogic_vector(0 to 11);
    debug_bus_in                : in    std_ulogic_vector(0 to 87);
    trace_triggers_in           : in    std_ulogic_vector(0 to 11);
    pc_fu_trace_bus_enable      : out   std_ulogic;
    pc_bx_trace_bus_enable      : out   std_ulogic;
    pc_iu_trace_bus_enable      : out   std_ulogic;
    pc_mm_trace_bus_enable      : out   std_ulogic;
    pc_xu_trace_bus_enable      : out   std_ulogic;
    pc_fu_debug_mux1_ctrls      : out   std_ulogic_vector(0 to 15);
    pc_bx_debug_mux1_ctrls      : out   std_ulogic_vector(0 to 15);
    pc_iu_debug_mux1_ctrls      : out   std_ulogic_vector(0 to 15);
    pc_iu_debug_mux2_ctrls      : out   std_ulogic_vector(0 to 15);
    pc_mm_debug_mux1_ctrls      : out   std_ulogic_vector(0 to 15);
    pc_xu_debug_mux1_ctrls      : out   std_ulogic_vector(0 to 15);
    pc_xu_debug_mux2_ctrls      : out   std_ulogic_vector(0 to 15);
    pc_xu_debug_mux3_ctrls      : out   std_ulogic_vector(0 to 15);
    pc_xu_debug_mux4_ctrls      : out   std_ulogic_vector(0 to 15);

    ac_an_event_bus             : out   std_ulogic_vector(0 to 7);
    ac_an_fu_bypass_events      : out   std_ulogic_vector(0 to 7);
    ac_an_iu_bypass_events      : out   std_ulogic_vector(0 to 7);
    ac_an_mm_bypass_events      : out   std_ulogic_vector(0 to 7);
    ac_an_lsu_bypass_events     : out   std_ulogic_vector(0 to 7);
    fu_pc_event_data            : in    std_ulogic_vector(0 to 7);
    iu_pc_event_data            : in    std_ulogic_vector(0 to 7);
    mm_pc_event_data            : in    std_ulogic_vector(0 to 7);
    xu_pc_event_data            : in    std_ulogic_vector(0 to 7);
    lsu_pc_event_data           : in    std_ulogic_vector(0 to 7);
    ac_pc_trace_to_perfcntr     : in    std_ulogic_vector(0 to 7);
    pc_xu_cache_par_err_event   : out   std_ulogic;
    pc_fu_instr_trace_mode      : out   std_ulogic;
    pc_fu_instr_trace_tid       : out   std_ulogic_vector(0 to 1);
    pc_xu_instr_trace_mode      : out   std_ulogic;
    pc_xu_instr_trace_tid       : out   std_ulogic_vector(0 to 1);
    pc_fu_event_count_mode      : out   std_ulogic_vector(0 to 2);
    pc_iu_event_count_mode      : out   std_ulogic_vector(0 to 2);
    pc_mm_event_count_mode      : out   std_ulogic_vector(0 to 2);
    pc_xu_event_count_mode      : out   std_ulogic_vector(0 to 2);
    pc_fu_event_mux_ctrls       : out   std_ulogic_vector(0 to 31);
    pc_iu_event_mux_ctrls       : out   std_ulogic_vector(0 to 47); 
    pc_mm_event_mux_ctrls       : out   std_ulogic_vector(0 to 39);
    pc_xu_event_mux_ctrls       : out   std_ulogic_vector(0 to 47);
    pc_xu_lsu_event_mux_ctrls   : out   std_ulogic_vector(0 to 47);
    pc_fu_event_bus_enable      : out   std_ulogic;
    pc_iu_event_bus_enable      : out   std_ulogic;
    pc_rp_event_bus_enable      : out   std_ulogic;
    pc_xu_event_bus_enable      : out   std_ulogic;

    an_ac_reset_1_complete      : in    std_ulogic;
    an_ac_reset_2_complete      : in    std_ulogic;
    an_ac_reset_3_complete      : in    std_ulogic;
    an_ac_reset_wd_complete     : in    std_ulogic;
    pc_xu_reset_1_cmplt         : out   std_ulogic; 
    pc_xu_reset_2_cmplt         : out   std_ulogic; 
    pc_xu_reset_3_cmplt         : out   std_ulogic; 
    pc_xu_reset_wd_cmplt        : out   std_ulogic; 
    pc_xu_init_reset            : out   std_ulogic;  
    pc_iu_init_reset            : out   std_ulogic;  
 
    ac_an_pm_thread_running     : out   std_ulogic_vector(0 to 3);
    an_ac_pm_thread_stop        : in    std_ulogic_vector(0 to 3); 
    ac_an_power_managed         : out   std_ulogic;
    ac_an_rvwinkle_mode         : out   std_ulogic;
    xu_pc_spr_ccr0_pme          : in    std_ulogic_vector(0 to 1);
    xu_pc_spr_ccr0_we           : in    std_ulogic_vector(0 to 3);

    an_ac_gsd_test_enable_dc    : in    std_ulogic;
    an_ac_gsd_test_acmode_dc    : in    std_ulogic;
    an_ac_ccflush_dc            : in    std_ulogic;
    an_ac_ccenable_dc           : in    std_ulogic;
    an_ac_lbist_en_dc           : in    std_ulogic;     
    an_ac_lbist_ip_dc           : in    std_ulogic;  
    an_ac_lbist_ac_mode_dc      : in    std_ulogic;
    an_ac_abist_mode_dc         : in    std_ulogic;
    an_ac_abist_start_test      : in    std_ulogic;
    an_ac_scan_diag_dc          : in    std_ulogic;
    an_ac_scan_dis_dc_b         : in    std_ulogic;
    an_ac_scan_diag_dc_opc      : out   std_ulogic;
    an_ac_scan_dis_dc_b_opc     : out   std_ulogic;
    an_ac_rtim_sl_thold_6       : in    std_ulogic;
    an_ac_func_sl_thold_6       : in    std_ulogic;
    an_ac_func_nsl_thold_6      : in    std_ulogic;
    an_ac_ary_nsl_thold_6       : in    std_ulogic;
    an_ac_sg_6                  : in    std_ulogic;
    an_ac_fce_6                 : in    std_ulogic;
    an_ac_scan_type_dc          : in    std_ulogic_vector(0 to 8);
    pc_xu_ccflush_dc            : out   std_ulogic;
    pc_xu_gptr_sl_thold_3       : out   std_ulogic;
    pc_xu_time_sl_thold_3       : out   std_ulogic;
    pc_xu_repr_sl_thold_3       : out   std_ulogic;
    pc_xu_abst_sl_thold_3       : out   std_ulogic;
    pc_xu_abst_slp_sl_thold_3   : out   std_ulogic;
    pc_xu_bolt_sl_thold_3       : out   std_ulogic;
    pc_xu_regf_sl_thold_3       : out   std_ulogic;
    pc_xu_regf_slp_sl_thold_3   : out   std_ulogic;
    pc_xu_func_sl_thold_3       : out   std_ulogic_vector(0 to 4);
    pc_xu_func_slp_sl_thold_3   : out   std_ulogic_vector(0 to 4);
    pc_xu_cfg_sl_thold_3        : out   std_ulogic;
    pc_xu_cfg_slp_sl_thold_3    : out   std_ulogic;
    pc_xu_func_nsl_thold_3      : out   std_ulogic;
    pc_xu_func_slp_nsl_thold_3  : out   std_ulogic;
    pc_xu_ary_nsl_thold_3       : out   std_ulogic;
    pc_xu_ary_slp_nsl_thold_3   : out   std_ulogic;
    pc_xu_sg_3                  : out   std_ulogic_vector(0 to 4);
    pc_xu_fce_3                 : out   std_ulogic_vector(0 to 1);
    pc_bx_ccflush_dc            : out   std_ulogic;
    pc_bx_func_sl_thold_3       : out   std_ulogic;
    pc_bx_func_slp_sl_thold_3   : out   std_ulogic;
    pc_bx_gptr_sl_thold_3       : out   std_ulogic;
    pc_bx_time_sl_thold_3       : out   std_ulogic;
    pc_bx_repr_sl_thold_3       : out   std_ulogic;
    pc_bx_abst_sl_thold_3       : out   std_ulogic;
    pc_bx_bolt_sl_thold_3       : out   std_ulogic;
    pc_bx_ary_nsl_thold_3       : out   std_ulogic;
    pc_bx_ary_slp_nsl_thold_3   : out   std_ulogic;
    pc_bx_sg_3                  : out   std_ulogic;
    pc_mm_ccflush_dc            : out   std_ulogic;
    pc_iu_ccflush_dc            : out   std_ulogic;
    pc_iu_gptr_sl_thold_4       : out   std_ulogic;
    pc_iu_time_sl_thold_4       : out   std_ulogic;
    pc_iu_repr_sl_thold_4       : out   std_ulogic;
    pc_iu_abst_sl_thold_4       : out   std_ulogic;
    pc_iu_abst_slp_sl_thold_4   : out   std_ulogic;
    pc_iu_bolt_sl_thold_4       : out   std_ulogic;
    pc_iu_regf_slp_sl_thold_4   : out   std_ulogic;
    pc_iu_func_sl_thold_4       : out   std_ulogic;
    pc_iu_func_slp_sl_thold_4   : out   std_ulogic;
    pc_iu_cfg_sl_thold_4        : out   std_ulogic;
    pc_iu_cfg_slp_sl_thold_4    : out   std_ulogic;
    pc_iu_func_nsl_thold_4      : out   std_ulogic;
    pc_iu_func_slp_nsl_thold_4  : out   std_ulogic;
    pc_iu_ary_nsl_thold_4       : out   std_ulogic;
    pc_iu_ary_slp_nsl_thold_4   : out   std_ulogic;
    pc_iu_sg_4                  : out   std_ulogic;
    pc_iu_fce_4                 : out   std_ulogic;
    pc_fu_ccflush_dc            : out   std_ulogic;
    pc_fu_gptr_sl_thold_3       : out   std_ulogic;
    pc_fu_time_sl_thold_3       : out   std_ulogic;
    pc_fu_repr_sl_thold_3       : out   std_ulogic;
    pc_fu_abst_sl_thold_3       : out   std_ulogic;
    pc_fu_abst_slp_sl_thold_3   : out   std_ulogic;
    pc_fu_bolt_sl_thold_3       : out   std_ulogic;
    pc_fu_func_sl_thold_3       : out   std_ulogic_vector(0 to 1);
    pc_fu_func_slp_sl_thold_3   : out   std_ulogic_vector(0 to 1);
    pc_fu_cfg_sl_thold_3        : out   std_ulogic;
    pc_fu_cfg_slp_sl_thold_3    : out   std_ulogic;
    pc_fu_func_nsl_thold_3      : out   std_ulogic;
    pc_fu_func_slp_nsl_thold_3  : out   std_ulogic;
    pc_fu_ary_nsl_thold_3       : out   std_ulogic;
    pc_fu_ary_slp_nsl_thold_3   : out   std_ulogic;
    pc_fu_sg_3                  : out   std_ulogic_vector(0 to 1);
    pc_fu_fce_3                 : out   std_ulogic;

    an_ac_psro_enable_dc           : in    std_ulogic_vector(0 to 2);
    ac_an_psro_ringsig             : out   std_ulogic;

    ac_an_abist_done_dc            : out   std_ulogic;
    pc_bx_abist_di_0               : Out   std_ulogic_vector(0 to 3);
    pc_bx_abist_ena_dc             : Out   std_ulogic;
    pc_bx_abist_g8t1p_renb_0       : Out   std_ulogic;
    pc_bx_abist_g8t_bw_0           : Out   std_ulogic;
    pc_bx_abist_g8t_bw_1           : Out   std_ulogic;
    pc_bx_abist_g8t_dcomp          : Out   std_ulogic_vector(0 to 3);
    pc_bx_abist_g8t_wenb           : Out   std_ulogic;
    pc_bx_abist_raddr_0            : Out   std_ulogic_vector(0 to 9);
    pc_bx_abist_raw_dc_b           : Out   std_ulogic;
    pc_bx_abist_waddr_0            : Out   std_ulogic_vector(0 to 9);
    pc_bx_abist_wl64_g8t_comp_ena  : Out   std_ulogic;
    pc_fu_abist_di_0               : Out   std_ulogic_vector(0 to 3);
    pc_fu_abist_di_1               : Out   std_ulogic_vector(0 to 3);
    pc_fu_abist_ena_dc             : Out   std_ulogic;
    pc_fu_abist_grf_renb_0         : Out   std_ulogic;
    pc_fu_abist_grf_renb_1         : Out   std_ulogic;
    pc_fu_abist_grf_wenb_0         : Out   std_ulogic;      
    pc_fu_abist_grf_wenb_1         : Out   std_ulogic;      
    pc_fu_abist_raddr_0            : Out   std_ulogic_vector(0 to 9);
    pc_fu_abist_raddr_1            : Out   std_ulogic_vector(0 to 9);
    pc_fu_abist_raw_dc_b           : Out   std_ulogic;
    pc_fu_abist_waddr_0            : Out   std_ulogic_vector(0 to 9);
    pc_fu_abist_waddr_1            : Out   std_ulogic_vector(0 to 9);
    pc_fu_abist_wl144_comp_ena     : Out   std_ulogic;
    pc_iu_abist_dcomp_g6t_2r       : Out   std_ulogic_vector(0 to 3);
    pc_iu_abist_di_0               : Out   std_ulogic_vector(0 to 3);
    pc_iu_abist_di_g6t_2r          : Out   std_ulogic_vector(0 to 3);
    pc_iu_abist_ena_dc             : Out   std_ulogic;
    pc_iu_abist_g6t_bw             : Out   std_ulogic_vector(0 to 1);
    pc_iu_abist_g6t_r_wb           : Out   std_ulogic;
    pc_iu_abist_g8t1p_renb_0       : Out   std_ulogic;
    pc_iu_abist_g8t_bw_0           : Out   std_ulogic;
    pc_iu_abist_g8t_bw_1           : Out   std_ulogic;
    pc_iu_abist_g8t_dcomp          : Out   std_ulogic_vector(0 to 3);
    pc_iu_abist_g8t_wenb           : Out   std_ulogic;
    pc_iu_abist_raddr_0            : Out   std_ulogic_vector(0 to 9);
    pc_iu_abist_raw_dc_b           : Out   std_ulogic;
    pc_iu_abist_waddr_0            : Out   std_ulogic_vector(0 to 9);
    pc_iu_abist_wl128_g8t_comp_ena : Out   std_ulogic;
    pc_iu_abist_wl256_comp_ena     : Out   std_ulogic;
    pc_iu_abist_wl64_g8t_comp_ena  : Out   std_ulogic;
    pc_mm_abist_dcomp_g6t_2r       : Out   std_ulogic_vector(0 to 3);
    pc_mm_abist_di_0               : Out   std_ulogic_vector(0 to 3);
    pc_mm_abist_di_g6t_2r          : Out   std_ulogic_vector(0 to 3);
    pc_mm_abist_ena_dc             : Out   std_ulogic;
    pc_mm_abist_g6t_r_wb           : Out   std_ulogic;
    pc_mm_abist_g8t1p_renb_0       : Out   std_ulogic;
    pc_mm_abist_g8t_bw_0           : Out   std_ulogic;
    pc_mm_abist_g8t_bw_1           : Out   std_ulogic;
    pc_mm_abist_g8t_dcomp          : Out   std_ulogic_vector(0 to 3);
    pc_mm_abist_g8t_wenb           : Out   std_ulogic;
    pc_mm_abist_raddr_0            : Out   std_ulogic_vector(0 to 9);
    pc_mm_abist_raw_dc_b           : Out   std_ulogic;
    pc_mm_abist_waddr_0            : Out   std_ulogic_vector(0 to 9);
    pc_mm_abist_wl128_g8t_comp_ena : Out   std_ulogic;
    pc_xu_abist_dcomp_g6t_2r       : Out   std_ulogic_vector(0 to 3);
    pc_xu_abist_di_0               : Out   std_ulogic_vector(0 to 3);
    pc_xu_abist_di_1               : Out   std_ulogic_vector(0 to 3);
    pc_xu_abist_di_g6t_2r          : Out   std_ulogic_vector(0 to 3);
    pc_xu_abist_ena_dc             : Out   std_ulogic;
    pc_xu_abist_g6t_bw             : Out   std_ulogic_vector(0 to 1);
    pc_xu_abist_g6t_r_wb           : Out   std_ulogic;
    pc_xu_abist_g8t1p_renb_0       : Out   std_ulogic;
    pc_xu_abist_g8t_bw_0           : Out   std_ulogic;
    pc_xu_abist_g8t_bw_1           : Out   std_ulogic;
    pc_xu_abist_g8t_dcomp          : Out   std_ulogic_vector(0 to 3);
    pc_xu_abist_g8t_wenb           : Out   std_ulogic;
    pc_xu_abist_grf_renb_0         : Out   std_ulogic;
    pc_xu_abist_grf_renb_1         : Out   std_ulogic;
    pc_xu_abist_grf_wenb_0         : Out   std_ulogic;      
    pc_xu_abist_grf_wenb_1         : Out   std_ulogic;
    pc_xu_abist_raddr_0            : Out   std_ulogic_vector(0 to 9);
    pc_xu_abist_raddr_1            : Out   std_ulogic_vector(0 to 9);
    pc_xu_abist_raw_dc_b           : Out   std_ulogic;
    pc_xu_abist_waddr_0            : Out   std_ulogic_vector(0 to 9);
    pc_xu_abist_waddr_1            : Out   std_ulogic_vector(0 to 9);
    pc_xu_abist_wl144_comp_ena     : Out   std_ulogic;
    pc_xu_abist_wl32_g8t_comp_ena  : Out   std_ulogic;
    pc_xu_abist_wl512_comp_ena     : Out   std_ulogic;

    an_ac_bo_enable             : in  std_ulogic;
    an_ac_bo_go                 : in  std_ulogic;
    an_ac_bo_cntlclk            : in  std_ulogic;
    an_ac_bo_ccflush            : in  std_ulogic;
    an_ac_bo_reset              : in  std_ulogic;
    an_ac_bo_data               : in  std_ulogic;
    an_ac_bo_shcntl             : in  std_ulogic;
    an_ac_bo_shdata             : in  std_ulogic;
    an_ac_bo_sysrepair          : in  std_ulogic;
    an_ac_bo_exe                : in  std_ulogic;
    an_ac_bo_donein             : in  std_ulogic;
    an_ac_bo_sdin               : in  std_ulogic;
    an_ac_bo_waitin             : in  std_ulogic;
    an_ac_bo_failin             : in  std_ulogic;
    an_ac_bo_fcshdata           : in  std_ulogic;
    an_ac_bo_fcreset            : in  std_ulogic;
    ac_an_bo_doneout            : out std_ulogic;
    ac_an_bo_sdout              : out std_ulogic;
    ac_an_bo_diagloopout        : out std_ulogic;
    ac_an_bo_waitout            : out std_ulogic;
    ac_an_bo_failout            : out std_ulogic;
    pc_bx_bo_enable_3           : out std_ulogic;
    pc_bx_bo_unload             : out std_ulogic;
    pc_bx_bo_repair             : out std_ulogic;
    pc_bx_bo_reset              : out std_ulogic;
    pc_bx_bo_shdata             : out std_ulogic;
    pc_bx_bo_select             : out std_ulogic_vector(0 to 3);
    bx_pc_bo_fail               : in  std_ulogic_vector(0 to 3);
    bx_pc_bo_diagout            : in  std_ulogic_vector(0 to 3);
    pc_fu_bo_enable_3           : out std_ulogic;
    pc_fu_bo_unload             : out std_ulogic;
    pc_fu_bo_load               : out std_ulogic;
    pc_fu_bo_reset              : out std_ulogic;
    pc_fu_bo_shdata             : out std_ulogic;
    pc_fu_bo_select             : out std_ulogic_vector(0 to 1);
    fu_pc_bo_fail               : in  std_ulogic_vector(0 to 1);
    fu_pc_bo_diagout            : in  std_ulogic_vector(0 to 1);
    pc_iu_bo_enable_4           : out std_ulogic;
    pc_iu_bo_unload             : out std_ulogic;
    pc_iu_bo_repair             : out std_ulogic;
    pc_iu_bo_reset              : out std_ulogic;
    pc_iu_bo_shdata             : out std_ulogic;
    pc_iu_bo_select             : out std_ulogic_vector(0 to 4);
    iu_pc_bo_fail               : in  std_ulogic_vector(0 to 4);
    iu_pc_bo_diagout            : in  std_ulogic_vector(0 to 4);
    pc_mm_bo_enable_4           : out std_ulogic;
    pc_mm_bo_unload             : out std_ulogic;
    pc_mm_bo_repair             : out std_ulogic;
    pc_mm_bo_reset              : out std_ulogic;
    pc_mm_bo_shdata             : out std_ulogic;
    pc_mm_bo_select             : out std_ulogic_vector(0 to 4);
    mm_pc_bo_fail               : in  std_ulogic_vector(0 to 4);
    mm_pc_bo_diagout            : in  std_ulogic_vector(0 to 4);
    pc_xu_bo_enable_3           : out std_ulogic;
    pc_xu_bo_unload             : out std_ulogic;
    pc_xu_bo_load               : out std_ulogic;
    pc_xu_bo_repair             : out std_ulogic;
    pc_xu_bo_reset              : out std_ulogic;
    pc_xu_bo_shdata             : out std_ulogic;
    pc_xu_bo_select             : out std_ulogic_vector(0 to 8);
    xu_pc_bo_fail               : in  std_ulogic_vector(0 to 8);
    xu_pc_bo_diagout            : in  std_ulogic_vector(0 to 8);

    gptr_scan_in                : in   std_ulogic;
    ccfg_scan_in                : in   std_ulogic;
    bcfg_scan_in                : in   std_ulogic;
    dcfg_scan_in                : in   std_ulogic;
    abst_scan_in                : in   std_ulogic;
    func_scan_in                : in   std_ulogic_vector(0 to 1);
    gptr_scan_out               : out  std_ulogic;
    ccfg_scan_out               : out  std_ulogic;
    bcfg_scan_out               : out  std_ulogic;
    dcfg_scan_out               : out  std_ulogic;
    abst_scan_out               : out  std_ulogic;
    func_scan_out               : out  std_ulogic_vector(0 to 1)
);
-- synopsys translate_off




-- synopsys translate_on
end pcq;

architecture pcq of pcq is
signal ct_db_func_scan_out              : std_ulogic; 
signal db_ss_func_scan_out              : std_ulogic;
signal lcbctrl_gptr_scan_out            : std_ulogic;
signal ct_rg_power_managed              : std_ulogic_vector(0 to 3);
signal ct_ck_pm_raise_tholds            : std_ulogic;
signal ct_ck_pm_ccflush_disable         : std_ulogic;
signal ct_rg_pm_thread_stop             : std_ulogic_vector(0 to 3);    
signal rg_ct_dis_pwr_savings            : std_ulogic;
signal rg_ck_fast_xstop                 : std_ulogic;
signal sp_db_event_mux_ctrls            : std_ulogic_vector(0 to 23);
signal sp_db_event_bus_enable           : std_ulogic;
signal ct_rg_hold_during_init           : std_ulogic;
signal d_mode_dc                        : std_ulogic;  
signal clkoff_dc_b                      : std_ulogic;  
signal act_dis_dc                       : std_ulogic;  
signal delay_lclkr_dc                   : std_ulogic_vector(0 to 4);
signal mpw1_dc_b                        : std_ulogic_vector(0 to 4);
signal mpw2_dc_b                        : std_ulogic;
signal pc_pc_ccflush_dc                 : std_ulogic;
signal pc_pc_gptr_sl_thold_0            : std_ulogic;
signal pc_pc_abst_sl_thold_0            : std_ulogic;
signal pc_pc_func_sl_thold_0            : std_ulogic;
signal pc_pc_func_slp_sl_thold_0        : std_ulogic;
signal pc_pc_cfg_sl_thold_0             : std_ulogic;
signal pc_pc_cfg_slp_sl_thold_0         : std_ulogic;
signal pc_pc_sg_0                       : std_ulogic;
signal sp_rg_trace_bus_enable           : std_ulogic;
signal rg_db_trace_bus_enable           : std_ulogic;
signal rg_db_debug_mux_ctrls            : std_ulogic_vector(0 to 15);
signal ck_db_dbg_clks_ctrls             : std_ulogic_vector(0 to 13);
signal rg_db_dbg_scom_rdata             : std_ulogic_vector(0 to 63);
signal rg_db_dbg_scom_wdata             : std_ulogic_vector(0 to 63);
signal rg_db_dbg_scom_decaddr           : std_ulogic_vector(0 to 63);
signal rg_db_dbg_scom_misc              : std_ulogic_vector(0 to 8);
signal rg_db_dbg_ram_thrctl             : std_ulogic_vector(0 to 20);
signal rg_db_dbg_fir0_err               : std_ulogic_vector(0 to 31);
signal rg_db_dbg_fir1_err               : std_ulogic_vector(0 to 30);
signal rg_db_dbg_fir2_err               : std_ulogic_vector(0 to 21);
signal rg_db_dbg_fir_misc               : std_ulogic_vector(0 to 35);
signal ct_db_dbg_ctrls                  : std_ulogic_vector(0 to 36);
signal rg_db_dbg_spr                    : std_ulogic_vector(0 to 46);
signal pc_bo_unload_out                 : std_ulogic;
signal pc_bo_load_out                   : std_ulogic;
signal pc_bo_repair_out                 : std_ulogic;
signal pc_bo_reset_out                  : std_ulogic;
signal pc_bo_shdata_out                 : std_ulogic;
signal pc_bo_select_out                 : std_ulogic_vector(0 to 39);
signal pc_bo_fail_in                    : std_ulogic_vector(0 to 39);
signal pc_bo_diagout_in                 : std_ulogic_vector(0 to 39);
signal abist_done_int                   : std_ulogic;
signal abst_eng_si                      : std_ulogic;
signal abst_scan_out_int                : std_ulogic;
signal an_ac_abist_start_test_int       : std_ulogic;
signal an_ac_abist_mode_dc_int          : std_ulogic;
signal bo_pc_abst_sl_thold_6            : std_ulogic;
signal bo_pc_pc_abst_sl_thold_6         : std_ulogic;
signal bo_pc_ary_nsl_thold_6            : std_ulogic;
signal bo_pc_func_sl_thold_6            : std_ulogic;
signal bo_pc_time_sl_thold_6            : std_ulogic;
signal bo_pc_repr_sl_thold_6            : std_ulogic;
signal bo_pc_sg_6                       : std_ulogic;
signal pc_pc_bo_go_0                    : std_ulogic;
signal pc_pc_bo_enable_0                : std_ulogic;
signal pc_pc_bo_cntlclk_0               : std_ulogic;
signal pc_pc_bo_reset_0                 : std_ulogic;
signal pc_pc_bo_fcshdata_0              : std_ulogic;
signal pc_pc_bo_fcreset_0               : std_ulogic;
signal pc_pc_bolt_sl_thold_6            : std_ulogic;
signal pc_pc_bolt_sl_thold_0            : std_ulogic;
signal unused_signals                   : std_ulogic;

signal pcq_psro_ringsig_out             : std_ulogic; 
signal pcq_psro_ringsig_i               : std_ulogic; 





begin

unused_signals <= or_reduce(pc_bo_select_out(25 TO 39));

an_ac_scan_diag_dc_opc   <=  an_ac_scan_diag_dc;
an_ac_scan_dis_dc_b_opc  <=  an_ac_scan_dis_dc_b;
ac_an_abist_done_dc      <=  abist_done_int;



pcq_regs : entity work.pcq_regs
generic map(expand_type         => expand_type,
            regmode             => regmode )
port map(
    vdd                         => vdd,
    gnd                         => gnd,
    nclk                        => nclk,
    scan_dis_dc_b               => an_ac_scan_dis_dc_b,
    lcb_clkoff_dc_b             => clkoff_dc_b,
    lcb_d_mode_dc               => d_mode_dc,
    lcb_mpw1_dc_b               => mpw1_dc_b(0),
    lcb_mpw2_dc_b               => mpw2_dc_b,
    lcb_delay_lclkr_dc          => delay_lclkr_dc(0),
    lcb_act_dis_dc              => act_dis_dc,
    lcb_func_slp_sl_thold_0     => pc_pc_func_slp_sl_thold_0,
    lcb_cfg_sl_thold_0          => pc_pc_cfg_sl_thold_0, 
    lcb_cfg_slp_sl_thold_0      => pc_pc_cfg_slp_sl_thold_0, 
    lcb_sg_0                    => pc_pc_sg_0,               
    ccfg_scan_in                => ccfg_scan_in,
    bcfg_scan_in                => bcfg_scan_in,
    dcfg_scan_in                => dcfg_scan_in,
    func_scan_in                => func_scan_in(0),
    ccfg_scan_out               => ccfg_scan_out,
    bcfg_scan_out               => bcfg_scan_out,
    dcfg_scan_out               => dcfg_scan_out,
    func_scan_out               => func_scan_out(0),
    an_ac_scom_sat_id           => an_ac_scom_sat_id,        
    an_ac_scom_dch              => an_ac_scom_dch,         
    an_ac_scom_cch              => an_ac_scom_cch,         
    ac_an_scom_dch              => ac_an_scom_dch,        
    ac_an_scom_cch              => ac_an_scom_cch,        
    ac_an_special_attn          => ac_an_special_attn,         
    ac_an_checkstop             => ac_an_checkstop,
    ac_an_local_checkstop       => ac_an_local_checkstop,
    ac_an_recov_err             => ac_an_recov_err,            
    ac_an_trace_error           => ac_an_trace_error,
    an_ac_checkstop             => an_ac_checkstop,        
    an_ac_malf_alert            => an_ac_malf_alert,        
    rg_ck_fast_xstop            => rg_ck_fast_xstop,
    iu_pc_err_icache_parity     => iu_pc_err_icache_parity,    
    iu_pc_err_icachedir_parity  => iu_pc_err_icachedir_parity,
    iu_pc_err_icachedir_multihit => iu_pc_err_icachedir_multihit,
    iu_pc_err_ucode_illegal     => iu_pc_err_ucode_illegal,
    xu_pc_err_dcache_parity     => xu_pc_err_dcache_parity,    
    xu_pc_err_dcachedir_parity  => xu_pc_err_dcachedir_parity, 
    xu_pc_err_dcachedir_multihit => xu_pc_err_dcachedir_multihit,
    xu_pc_err_mcsr_summary       => xu_pc_err_mcsr_summary,
    xu_pc_err_ierat_parity       => xu_pc_err_ierat_parity,     
    xu_pc_err_derat_parity       => xu_pc_err_derat_parity,     
    xu_pc_err_tlb_parity         => xu_pc_err_tlb_parity,       
    xu_pc_err_tlb_lru_parity     => xu_pc_err_tlb_lru_parity,   
    xu_pc_err_ierat_multihit     => xu_pc_err_ierat_multihit,   
    xu_pc_err_derat_multihit     => xu_pc_err_derat_multihit,   
    xu_pc_err_tlb_multihit       => xu_pc_err_tlb_multihit,
    xu_pc_err_ext_mchk           => xu_pc_err_ext_mchk,        
    xu_pc_err_ditc_overrun       => xu_pc_err_ditc_overrun,
    xu_pc_err_local_snoop_reject => xu_pc_err_local_snoop_reject,
    xu_pc_err_sprg_ecc          => xu_pc_err_sprg_ecc,      
    xu_pc_err_sprg_ue           => xu_pc_err_sprg_ue,      
    xu_pc_err_regfile_parity    => xu_pc_err_regfile_parity,   
    xu_pc_err_regfile_ue        => xu_pc_err_regfile_ue,   
    xu_pc_err_llbust_attempt    => xu_pc_err_llbust_attempt,   
    xu_pc_err_llbust_failed     => xu_pc_err_llbust_failed,    
    xu_pc_err_l2intrf_ecc       => xu_pc_err_l2intrf_ecc,       
    xu_pc_err_l2intrf_ue        => xu_pc_err_l2intrf_ue,       
    xu_pc_err_l2credit_overrun  =>  xu_pc_err_l2credit_overrun,
    xu_pc_err_wdt_reset         => xu_pc_err_wdt_reset,        
    xu_pc_err_attention_instr   => xu_pc_err_attention_instr,  
    xu_pc_err_debug_event       => xu_pc_err_debug_event,      
    xu_pc_err_nia_miscmpr       => xu_pc_err_nia_miscmpr,      
    xu_pc_err_invld_reld        => xu_pc_err_invld_reld,
    xu_pc_err_mchk_disabled     => xu_pc_err_mchk_disabled,
    bx_pc_err_inbox_ecc         => bx_pc_err_inbox_ecc,
    bx_pc_err_inbox_ue          => bx_pc_err_inbox_ue,
    bx_pc_err_outbox_ecc        => bx_pc_err_outbox_ecc,
    bx_pc_err_outbox_ue         => bx_pc_err_outbox_ue,
    fu_pc_err_regfile_parity    => fu_pc_err_regfile_parity,   
    fu_pc_err_regfile_ue        => fu_pc_err_regfile_ue,   
    pc_iu_inj_icache_parity     => pc_iu_inj_icache_parity,  
    pc_iu_inj_icachedir_parity  => pc_iu_inj_icachedir_parity,
    pc_xu_inj_dcache_parity     => pc_xu_inj_dcache_parity,   
    pc_xu_inj_dcachedir_parity  => pc_xu_inj_dcachedir_parity,
    pc_xu_inj_sprg_ecc          => pc_xu_inj_sprg_ecc,      
    pc_xu_inj_regfile_parity    => pc_xu_inj_regfile_parity,
    pc_fu_inj_regfile_parity    => pc_fu_inj_regfile_parity,
    pc_bx_inj_inbox_ecc         => pc_bx_inj_inbox_ecc,     
    pc_bx_inj_outbox_ecc        => pc_bx_inj_outbox_ecc,    
    pc_xu_inj_llbust_attempt    => pc_xu_inj_llbust_attempt,  
    pc_xu_inj_llbust_failed     => pc_xu_inj_llbust_failed,   
    pc_xu_inj_wdt_reset         => pc_xu_inj_wdt_reset,       
    pc_iu_inj_icachedir_multihit =>  pc_iu_inj_icachedir_multihit,
    pc_xu_inj_dcachedir_multihit =>  pc_xu_inj_dcachedir_multihit,
    pc_xu_cache_par_err_event   => pc_xu_cache_par_err_event,
    pc_iu_ram_instr             => pc_iu_ram_instr,       
    pc_iu_ram_instr_ext         => pc_iu_ram_instr_ext,   
    pc_iu_ram_mode              => pc_iu_ram_mode,        
    pc_iu_ram_thread            => pc_iu_ram_thread,      
    pc_xu_ram_execute           => pc_xu_ram_execute,     
    pc_xu_ram_mode              => pc_xu_ram_mode,        
    pc_xu_ram_thread            => pc_xu_ram_thread,      
    xu_pc_ram_interrupt         => xu_pc_ram_interrupt,       
    xu_pc_ram_done              => xu_pc_ram_done,        
    xu_pc_ram_data              => xu_pc_ram_data,        
    pc_fu_ram_mode              => pc_fu_ram_mode,        
    pc_fu_ram_thread            => pc_fu_ram_thread,      
    fu_pc_ram_done              => fu_pc_ram_done,        
    fu_pc_ram_data              => fu_pc_ram_data,        
    pc_xu_msrovride_enab        => pc_xu_msrovride_enab,
    pc_xu_msrovride_pr          => pc_xu_msrovride_pr,  
    pc_xu_msrovride_gs          => pc_xu_msrovride_gs,  
    pc_xu_msrovride_de          => pc_xu_msrovride_de,  
    pc_iu_ram_force_cmplt       => pc_iu_ram_force_cmplt,
    pc_xu_ram_flush_thread      => pc_xu_ram_flush_thread,
    xu_pc_running               => xu_pc_running,      
    xu_pc_stop_dbg_event        => xu_pc_stop_dbg_event,  
    xu_pc_step_done             => xu_pc_step_done,  
    pc_xu_stop                  => pc_xu_stop,           
    pc_xu_step                  => pc_xu_step,         
    pc_xu_force_ude             => pc_xu_force_ude,         
    ct_rg_power_managed         => ct_rg_power_managed,       
    ct_rg_pm_thread_stop        => ct_rg_pm_thread_stop,     
    ac_an_pm_thread_running     => ac_an_pm_thread_running,     
    pc_xu_extirpts_dis_on_stop  => pc_xu_extirpts_dis_on_stop,
    pc_xu_timebase_dis_on_stop  => pc_xu_timebase_dis_on_stop,
    pc_xu_decrem_dis_on_stop    => pc_xu_decrem_dis_on_stop,
    ct_rg_hold_during_init      => ct_rg_hold_during_init,
    an_ac_debug_stop            => an_ac_debug_stop,
    pc_xu_dbg_action            => pc_xu_dbg_action,   
    rg_ct_dis_pwr_savings       => rg_ct_dis_pwr_savings,
    sp_rg_trace_bus_enable      => sp_rg_trace_bus_enable,
    rg_db_trace_bus_enable      => rg_db_trace_bus_enable,
    pc_fu_trace_bus_enable      => pc_fu_trace_bus_enable,
    pc_bx_trace_bus_enable      => pc_bx_trace_bus_enable,
    pc_iu_trace_bus_enable      => pc_iu_trace_bus_enable,
    pc_mm_trace_bus_enable      => pc_mm_trace_bus_enable,
    pc_xu_trace_bus_enable      => pc_xu_trace_bus_enable,
    rg_db_debug_mux_ctrls       => rg_db_debug_mux_ctrls,
    pc_fu_debug_mux1_ctrls      => pc_fu_debug_mux1_ctrls,
    pc_bx_debug_mux1_ctrls      => pc_bx_debug_mux1_ctrls,
    pc_iu_debug_mux1_ctrls      => pc_iu_debug_mux1_ctrls,
    pc_iu_debug_mux2_ctrls      => pc_iu_debug_mux2_ctrls,
    pc_mm_debug_mux1_ctrls      => pc_mm_debug_mux1_ctrls,
    pc_xu_debug_mux1_ctrls      => pc_xu_debug_mux1_ctrls,
    pc_xu_debug_mux2_ctrls      => pc_xu_debug_mux2_ctrls,
    pc_xu_debug_mux3_ctrls      => pc_xu_debug_mux3_ctrls,
    pc_xu_debug_mux4_ctrls      => pc_xu_debug_mux4_ctrls,
    dbg_scom_rdata              => rg_db_dbg_scom_rdata,  
    dbg_scom_wdata              => rg_db_dbg_scom_wdata,  
    dbg_scom_decaddr            => rg_db_dbg_scom_decaddr,
    dbg_scom_misc               => rg_db_dbg_scom_misc,   
    dbg_ram_thrctl              => rg_db_dbg_ram_thrctl,  
    dbg_fir0_err                => rg_db_dbg_fir0_err,
    dbg_fir1_err                => rg_db_dbg_fir1_err,
    dbg_fir2_err                => rg_db_dbg_fir2_err,
    dbg_fir_misc                => rg_db_dbg_fir_misc    
);


pcq_ctrl : entity work.pcq_ctrl
generic map(expand_type         => expand_type)
port map(
    vdd                         => vdd,
    gnd                         => gnd,
    nclk                        => nclk,
    scan_dis_dc_b               => an_ac_scan_dis_dc_b,
    lcb_clkoff_dc_b             => clkoff_dc_b,
    lcb_mpw1_dc_b               => mpw1_dc_b(1),
    lcb_mpw2_dc_b               => mpw2_dc_b,
    lcb_delay_lclkr_dc          => delay_lclkr_dc(1),
    lcb_act_dis_dc              => act_dis_dc,
    pc_pc_func_slp_sl_thold_0   => pc_pc_func_slp_sl_thold_0,
    pc_pc_sg_0                  => pc_pc_sg_0,
    func_scan_in                => func_scan_in(1),
    func_scan_out               => ct_db_func_scan_out,
    an_ac_reset_1_complete      => an_ac_reset_1_complete,     
    an_ac_reset_2_complete      => an_ac_reset_2_complete,        
    an_ac_reset_3_complete      => an_ac_reset_3_complete,      
    an_ac_reset_wd_complete     => an_ac_reset_wd_complete,      
    pc_xu_reset_1_cmplt         => pc_xu_reset_1_cmplt,      
    pc_xu_reset_2_cmplt         => pc_xu_reset_2_cmplt,      
    pc_xu_reset_3_cmplt         => pc_xu_reset_3_cmplt,       
    pc_xu_reset_wd_cmplt        => pc_xu_reset_wd_cmplt,       
    pc_xu_init_reset            => pc_xu_init_reset,     
    pc_iu_init_reset            => pc_iu_init_reset,     
    ct_rg_hold_during_init      => ct_rg_hold_during_init,
    ct_rg_power_managed         => ct_rg_power_managed,       
    ct_rg_pm_thread_stop        => ct_rg_pm_thread_stop,     
    an_ac_pm_thread_stop        => an_ac_pm_thread_stop, 
    ac_an_power_managed         => ac_an_power_managed,
    ac_an_rvwinkle_mode         => ac_an_rvwinkle_mode,
    ct_ck_pm_ccflush_disable    => ct_ck_pm_ccflush_disable,
    ct_ck_pm_raise_tholds       => ct_ck_pm_raise_tholds,       
    rg_ct_dis_pwr_savings       => rg_ct_dis_pwr_savings,
    xu_pc_spr_ccr0_pme          => xu_pc_spr_ccr0_pme,
    xu_pc_spr_ccr0_we           => xu_pc_spr_ccr0_we,
    dbg_ctrls                   => ct_db_dbg_ctrls
);


pcq_dbg : entity work.pcq_dbg
generic map(expand_type         => expand_type)
port map(
    vdd                         => vdd,
    gnd                         => gnd,
    nclk                        => nclk,
    scan_dis_dc_b               => an_ac_scan_dis_dc_b,
    lcb_clkoff_dc_b             => clkoff_dc_b,
    lcb_mpw1_dc_b               => mpw1_dc_b(2),
    lcb_mpw2_dc_b               => mpw2_dc_b,
    lcb_delay_lclkr_dc          => delay_lclkr_dc(2),
    lcb_act_dis_dc              => act_dis_dc,
    pc_pc_func_slp_sl_thold_0   => pc_pc_func_slp_sl_thold_0,    
    pc_pc_sg_0                  => pc_pc_sg_0,               
    func_scan_in                => ct_db_func_scan_out,
    func_scan_out               => db_ss_func_scan_out,
    debug_bus_out               => debug_bus_out,        
    trace_triggers_out          => trace_triggers_out,   
    debug_bus_in                => debug_bus_in,       
    trace_triggers_in           => trace_triggers_in,
    rg_db_trace_bus_enable      => rg_db_trace_bus_enable,
    rg_db_debug_mux_ctrls       => rg_db_debug_mux_ctrls,
    ck_db_dbg_clks_ctrls        => ck_db_dbg_clks_ctrls,
    rg_db_dbg_scom_rdata        => rg_db_dbg_scom_rdata,  
    rg_db_dbg_scom_wdata        => rg_db_dbg_scom_wdata,  
    rg_db_dbg_scom_decaddr      => rg_db_dbg_scom_decaddr,
    rg_db_dbg_scom_misc         => rg_db_dbg_scom_misc,   
    rg_db_dbg_ram_thrctl        => rg_db_dbg_ram_thrctl,  
    rg_db_dbg_fir0_err          => rg_db_dbg_fir0_err, 
    rg_db_dbg_fir1_err          => rg_db_dbg_fir1_err,
    rg_db_dbg_fir2_err          => rg_db_dbg_fir2_err,
    rg_db_dbg_fir_misc          => rg_db_dbg_fir_misc,     
    ct_db_dbg_ctrls             => ct_db_dbg_ctrls, 
    rg_db_dbg_spr               => rg_db_dbg_spr,
    ac_an_event_bus             => ac_an_event_bus,        
    ac_an_fu_bypass_events      => ac_an_fu_bypass_events,
    ac_an_iu_bypass_events      => ac_an_iu_bypass_events,
    ac_an_mm_bypass_events      => ac_an_mm_bypass_events,
    ac_an_lsu_bypass_events     => ac_an_lsu_bypass_events,
    rg_db_event_bus_enable      => sp_db_event_bus_enable,
    rg_db_event_mux_ctrls       => sp_db_event_mux_ctrls,
    fu_pc_event_data            => fu_pc_event_data,       
    iu_pc_event_data            => iu_pc_event_data,       
    mm_pc_event_data            => mm_pc_event_data,       
    xu_pc_event_data            => xu_pc_event_data,       
    lsu_pc_event_data           => lsu_pc_event_data,       
    ac_pc_trace_to_perfcntr     => ac_pc_trace_to_perfcntr       
);


pcq_spr : entity work.pcq_spr 
generic map(expand_type         => expand_type,
            regmode             => regmode )
port map(
    vdd                         => vdd,
    gnd                         => gnd,
    nclk                        => nclk,
    scan_dis_dc_b               => an_ac_scan_dis_dc_b,
    lcb_clkoff_dc_b             => clkoff_dc_b,
    lcb_mpw1_dc_b               => mpw1_dc_b(0),
    lcb_mpw2_dc_b               => mpw2_dc_b,
    lcb_delay_lclkr_dc          => delay_lclkr_dc(0),
    lcb_act_dis_dc              => act_dis_dc,
    pc_pc_func_sl_thold_0       => pc_pc_func_sl_thold_0,    
    pc_pc_sg_0                  => pc_pc_sg_0,               
    func_scan_in                => db_ss_func_scan_out,
    func_scan_out               => func_scan_out(1),
    slowspr_val_in              => slowspr_val_in,
    slowspr_rw_in               => slowspr_rw_in,
    slowspr_etid_in             => slowspr_etid_in,
    slowspr_addr_in             => slowspr_addr_in,
    slowspr_data_in             => slowspr_data_in(64-(2**regmode) to 63),
    slowspr_done_in             => slowspr_done_in,

    slowspr_val_out             => slowspr_val_out,
    slowspr_rw_out              => slowspr_rw_out,
    slowspr_etid_out            => slowspr_etid_out,
    slowspr_addr_out            => slowspr_addr_out,
    slowspr_data_out            => slowspr_data_out(64-(2**regmode) to 63),
    slowspr_done_out            => slowspr_done_out,
    sp_rg_trace_bus_enable      => sp_rg_trace_bus_enable,
    pc_fu_instr_trace_mode      => pc_fu_instr_trace_mode,
    pc_fu_instr_trace_tid       => pc_fu_instr_trace_tid,
    pc_xu_instr_trace_mode      => pc_xu_instr_trace_mode,
    pc_xu_instr_trace_tid       => pc_xu_instr_trace_tid, 
    pc_fu_event_count_mode      => pc_fu_event_count_mode, 
    pc_iu_event_count_mode      => pc_iu_event_count_mode, 
    pc_mm_event_count_mode      => pc_mm_event_count_mode, 
    pc_xu_event_count_mode      => pc_xu_event_count_mode, 
    pc_fu_event_mux_ctrls       => pc_fu_event_mux_ctrls,    
    pc_iu_event_mux_ctrls       => pc_iu_event_mux_ctrls,    
    pc_mm_event_mux_ctrls       => pc_mm_event_mux_ctrls,    
    pc_xu_event_mux_ctrls       => pc_xu_event_mux_ctrls,    
    pc_xu_lsu_event_mux_ctrls   => pc_xu_lsu_event_mux_ctrls,
    sp_db_event_mux_ctrls       => sp_db_event_mux_ctrls,
    pc_fu_event_bus_enable      => pc_fu_event_bus_enable,
    pc_iu_event_bus_enable      => pc_iu_event_bus_enable,
    pc_rp_event_bus_enable      => pc_rp_event_bus_enable,
    pc_xu_event_bus_enable      => pc_xu_event_bus_enable,
    sp_db_event_bus_enable      => sp_db_event_bus_enable,
    dbg_spr                     => rg_db_dbg_spr
);


pcq_clks : entity work.pcq_clks
generic map(expand_type         => expand_type)
port map(
    vdd                         => vdd,
    gnd                         => gnd,
    nclk                        => nclk,
    rtim_sl_thold_6             => an_ac_rtim_sl_thold_6,      
    func_sl_thold_6             => an_ac_func_sl_thold_6,      
    func_nsl_thold_6            => an_ac_func_nsl_thold_6,     
    ary_nsl_thold_6             => an_ac_ary_nsl_thold_6,      
    sg_6                        => an_ac_sg_6,                 
    fce_6                       => an_ac_fce_6,                
    gsd_test_enable_dc          => an_ac_gsd_test_enable_dc,
    gsd_test_acmode_dc          => an_ac_gsd_test_acmode_dc,
    ccflush_dc                  => an_ac_ccflush_dc,
    ccenable_dc                 => an_ac_ccenable_dc,
    scan_type_dc                => an_ac_scan_type_dc,         
    lbist_en_dc                 => an_ac_lbist_en_dc,     
    lbist_ip_dc                 => an_ac_lbist_ip_dc,    
    rg_ck_fast_xstop            => rg_ck_fast_xstop,
    ct_ck_pm_ccflush_disable    => ct_ck_pm_ccflush_disable,
    ct_ck_pm_raise_tholds       => ct_ck_pm_raise_tholds,       
    bolton_enable_dc            => an_ac_bo_enable,
    bolton_enable_sync          => pc_pc_bo_enable_0,
    bolton_ccflush              => an_ac_bo_ccflush,
    bc_cntlclk_sync             => pc_pc_bo_cntlclk_0,
    bolton_fcshdata             => pc_pc_bo_fcshdata_0,
    bolton_fcreset              => pc_pc_bo_fcreset_0,
    bo_pc_abst_sl_thold_6       => bo_pc_abst_sl_thold_6,
    bo_pc_pc_abst_sl_thold_6    => bo_pc_pc_abst_sl_thold_6,
    bo_pc_ary_nsl_thold_6       => bo_pc_ary_nsl_thold_6,
    bo_pc_func_sl_thold_6       => bo_pc_func_sl_thold_6,
    bo_pc_time_sl_thold_6       => bo_pc_time_sl_thold_6,
    bo_pc_repr_sl_thold_6       => bo_pc_repr_sl_thold_6,
    bo_pc_sg_6                  => bo_pc_sg_6,
    pc_xu_ccflush_dc            =>  pc_xu_ccflush_dc,          
    pc_xu_gptr_sl_thold_3       =>  pc_xu_gptr_sl_thold_3,     
    pc_xu_time_sl_thold_3       =>  pc_xu_time_sl_thold_3,     
    pc_xu_repr_sl_thold_3       =>  pc_xu_repr_sl_thold_3,     
    pc_xu_abst_sl_thold_3       =>  pc_xu_abst_sl_thold_3,     
    pc_xu_abst_slp_sl_thold_3   =>  pc_xu_abst_slp_sl_thold_3, 
    pc_xu_bolt_sl_thold_3       =>  pc_xu_bolt_sl_thold_3,
    pc_xu_regf_sl_thold_3       =>  pc_xu_regf_sl_thold_3,     
    pc_xu_regf_slp_sl_thold_3   =>  pc_xu_regf_slp_sl_thold_3, 
    pc_xu_func_sl_thold_3       =>  pc_xu_func_sl_thold_3,     
    pc_xu_func_slp_sl_thold_3   =>  pc_xu_func_slp_sl_thold_3, 
    pc_xu_cfg_sl_thold_3        =>  pc_xu_cfg_sl_thold_3,      
    pc_xu_cfg_slp_sl_thold_3    =>  pc_xu_cfg_slp_sl_thold_3,  
    pc_xu_func_nsl_thold_3      =>  pc_xu_func_nsl_thold_3,    
    pc_xu_func_slp_nsl_thold_3  =>  pc_xu_func_slp_nsl_thold_3,
    pc_xu_ary_nsl_thold_3       =>  pc_xu_ary_nsl_thold_3,     
    pc_xu_ary_slp_nsl_thold_3   =>  pc_xu_ary_slp_nsl_thold_3, 
    pc_xu_sg_3                  =>  pc_xu_sg_3,                
    pc_xu_fce_3                 =>  pc_xu_fce_3,               
    pc_bx_ccflush_dc            =>  pc_bx_ccflush_dc,      
    pc_bx_func_sl_thold_3       =>  pc_bx_func_sl_thold_3, 
    pc_bx_func_slp_sl_thold_3   =>  pc_bx_func_slp_sl_thold_3,
    pc_bx_gptr_sl_thold_3       =>  pc_bx_gptr_sl_thold_3, 
    pc_bx_time_sl_thold_3       =>  pc_bx_time_sl_thold_3, 
    pc_bx_repr_sl_thold_3       =>  pc_bx_repr_sl_thold_3, 
    pc_bx_abst_sl_thold_3       =>  pc_bx_abst_sl_thold_3, 
    pc_bx_bolt_sl_thold_3       =>  pc_bx_bolt_sl_thold_3,
    pc_bx_ary_nsl_thold_3       =>  pc_bx_ary_nsl_thold_3, 
    pc_bx_ary_slp_nsl_thold_3   =>  pc_bx_ary_slp_nsl_thold_3,    
    pc_bx_sg_3                  =>  pc_bx_sg_3,            
    pc_mm_ccflush_dc            =>  pc_mm_ccflush_dc,          
    pc_iu_ccflush_dc            =>  pc_iu_ccflush_dc,          
    pc_iu_gptr_sl_thold_4       =>  pc_iu_gptr_sl_thold_4,     
    pc_iu_time_sl_thold_4       =>  pc_iu_time_sl_thold_4,     
    pc_iu_repr_sl_thold_4       =>  pc_iu_repr_sl_thold_4,     
    pc_iu_abst_sl_thold_4       =>  pc_iu_abst_sl_thold_4,     
    pc_iu_abst_slp_sl_thold_4   =>  pc_iu_abst_slp_sl_thold_4, 
    pc_iu_bolt_sl_thold_4       =>  pc_iu_bolt_sl_thold_4,
    pc_iu_regf_slp_sl_thold_4   =>  pc_iu_regf_slp_sl_thold_4, 
    pc_iu_func_sl_thold_4       =>  pc_iu_func_sl_thold_4,     
    pc_iu_func_slp_sl_thold_4   =>  pc_iu_func_slp_sl_thold_4, 
    pc_iu_cfg_sl_thold_4        =>  pc_iu_cfg_sl_thold_4,      
    pc_iu_cfg_slp_sl_thold_4    =>  pc_iu_cfg_slp_sl_thold_4,  
    pc_iu_func_nsl_thold_4      =>  pc_iu_func_nsl_thold_4,    
    pc_iu_func_slp_nsl_thold_4  =>  pc_iu_func_slp_nsl_thold_4,
    pc_iu_ary_nsl_thold_4       =>  pc_iu_ary_nsl_thold_4,     
    pc_iu_ary_slp_nsl_thold_4   =>  pc_iu_ary_slp_nsl_thold_4, 
    pc_iu_sg_4                  =>  pc_iu_sg_4,                
    pc_iu_fce_4                 =>  pc_iu_fce_4,               
    pc_fu_ccflush_dc            =>  pc_fu_ccflush_dc,          
    pc_fu_gptr_sl_thold_3       =>  pc_fu_gptr_sl_thold_3,     
    pc_fu_time_sl_thold_3       =>  pc_fu_time_sl_thold_3,     
    pc_fu_repr_sl_thold_3       =>  pc_fu_repr_sl_thold_3,     
    pc_fu_abst_sl_thold_3       =>  pc_fu_abst_sl_thold_3,     
    pc_fu_abst_slp_sl_thold_3   =>  pc_fu_abst_slp_sl_thold_3, 
    pc_fu_bolt_sl_thold_3       =>  pc_fu_bolt_sl_thold_3,
    pc_fu_func_sl_thold_3       =>  pc_fu_func_sl_thold_3,     
    pc_fu_func_slp_sl_thold_3   =>  pc_fu_func_slp_sl_thold_3, 
    pc_fu_cfg_sl_thold_3        =>  pc_fu_cfg_sl_thold_3,      
    pc_fu_cfg_slp_sl_thold_3    =>  pc_fu_cfg_slp_sl_thold_3,  
    pc_fu_func_nsl_thold_3      =>  pc_fu_func_nsl_thold_3,    
    pc_fu_func_slp_nsl_thold_3  =>  pc_fu_func_slp_nsl_thold_3,
    pc_fu_ary_nsl_thold_3       =>  pc_fu_ary_nsl_thold_3,     
    pc_fu_ary_slp_nsl_thold_3   =>  pc_fu_ary_slp_nsl_thold_3, 
    pc_fu_sg_3                  =>  pc_fu_sg_3,                
    pc_fu_fce_3                 =>  pc_fu_fce_3,               
    pc_pc_ccflush_dc            =>  pc_pc_ccflush_dc,
    pc_pc_gptr_sl_thold_0       =>  pc_pc_gptr_sl_thold_0,     
    pc_pc_abst_sl_thold_0       =>  pc_pc_abst_sl_thold_0, 
    pc_pc_bolt_sl_thold_6       =>  pc_pc_bolt_sl_thold_6,
    pc_pc_bolt_sl_thold_0       =>  pc_pc_bolt_sl_thold_0,
    pc_pc_func_sl_thold_0       =>  pc_pc_func_sl_thold_0,     
    pc_pc_func_slp_sl_thold_0   =>  pc_pc_func_slp_sl_thold_0, 
    pc_pc_cfg_sl_thold_0        =>  pc_pc_cfg_sl_thold_0,     
    pc_pc_cfg_slp_sl_thold_0    =>  pc_pc_cfg_slp_sl_thold_0, 
    pc_pc_sg_0                  =>  pc_pc_sg_0,               
    dbg_clks_ctrls              =>  ck_db_dbg_clks_ctrls               
);



pcq_abist : entity work.pcq_abist
generic map(expand_type            => expand_type)
port map(
        vdd                        => vdd,
        gnd                        => gnd,
        nclk                       => nclk,
        scan_dis_dc_b              => an_ac_scan_dis_dc_b,
        lcb_clkoff_dc_b            => clkoff_dc_b,
        lcb_mpw1_dc_b              => mpw1_dc_b(3),
        lcb_mpw2_dc_b              => mpw2_dc_b,
        lcb_delay_lclkr_dc         => delay_lclkr_dc(3),
        lcb_delay_lclkr_np_dc      => delay_lclkr_dc(4),
        lcb_act_dis_dc             => act_dis_dc,
        lcb_d_mode_dc              => d_mode_dc,
        gptr_thold                 => pc_pc_gptr_sl_thold_0,
        gptr_scan_in               => lcbctrl_gptr_scan_out,
        gptr_scan_out              => gptr_scan_out,
        abist_thold                => pc_pc_abst_sl_thold_0, 
        abist_sg                   => pc_pc_sg_0,
        abist_scan_in              => abst_scan_in,
        abist_scan_out             => abst_scan_out_int,
        bo_enable                  => pc_pc_bo_enable_0,
        bo_abist_eng_si            => abst_eng_si,
        abist_done_in_dc           => '1', 
        abist_done_out_dc          => abist_done_int,
        abist_mode_dc              => an_ac_abist_mode_dc_int,   
        abist_start_test           => an_ac_abist_start_test_int,  
        lbist_mode_dc              => an_ac_lbist_en_dc,
        lbist_ac_mode_dc           => an_ac_lbist_ac_mode_dc,  
        pc_bx_abist_di_0               => pc_bx_abist_di_0(0 to 3),
        pc_bx_abist_ena_dc             => pc_bx_abist_ena_dc,       
        pc_bx_abist_g8t1p_renb_0       => pc_bx_abist_g8t1p_renb_0, 
        pc_bx_abist_g8t_bw_0           => pc_bx_abist_g8t_bw_0,     
        pc_bx_abist_g8t_bw_1           => pc_bx_abist_g8t_bw_1,     
        pc_bx_abist_g8t_dcomp          => pc_bx_abist_g8t_dcomp(0 to 3),
        pc_bx_abist_g8t_wenb           => pc_bx_abist_g8t_wenb,     
        pc_bx_abist_raddr_0            => pc_bx_abist_raddr_0(0 to 9),
        pc_bx_abist_raw_dc_b           => pc_bx_abist_raw_dc_b,     
        pc_bx_abist_waddr_0            => pc_bx_abist_waddr_0(0 to 9),
        pc_bx_abist_wl64_g8t_comp_ena  => pc_bx_abist_wl64_g8t_comp_ena,
        pc_fu_abist_di_0               => pc_fu_abist_di_0(0 to 3),
        pc_fu_abist_di_1               => pc_fu_abist_di_1(0 to 3),
        pc_fu_abist_ena_dc             => pc_fu_abist_ena_dc,        
        pc_fu_abist_grf_renb_0         => pc_fu_abist_grf_renb_0,    
        pc_fu_abist_grf_renb_1         => pc_fu_abist_grf_renb_1,    
        pc_fu_abist_grf_wenb_0         => pc_fu_abist_grf_wenb_0,          
        pc_fu_abist_grf_wenb_1         => pc_fu_abist_grf_wenb_1,          
        pc_fu_abist_raddr_0            => pc_fu_abist_raddr_0(0 to 9),
        pc_fu_abist_raddr_1            => pc_fu_abist_raddr_1(0 to 9),
        pc_fu_abist_raw_dc_b           => pc_fu_abist_raw_dc_b,      
        pc_fu_abist_waddr_0            => pc_fu_abist_waddr_0(0 to 9),
        pc_fu_abist_waddr_1            => pc_fu_abist_waddr_1(0 to 9),
        pc_fu_abist_wl144_comp_ena     => pc_fu_abist_wl144_comp_ena,
        pc_iu_abist_dcomp_g6t_2r       => pc_iu_abist_dcomp_g6t_2r(0 to 3),
        pc_iu_abist_di_0               => pc_iu_abist_di_0(0 to 3),
        pc_iu_abist_di_g6t_2r          => pc_iu_abist_di_g6t_2r(0 to 3),
        pc_iu_abist_ena_dc             => pc_iu_abist_ena_dc,        
        pc_iu_abist_g6t_bw             => pc_iu_abist_g6t_bw(0 to 1),
        pc_iu_abist_g6t_r_wb           => pc_iu_abist_g6t_r_wb,      
        pc_iu_abist_g8t1p_renb_0       => pc_iu_abist_g8t1p_renb_0, 
        pc_iu_abist_g8t_bw_0           => pc_iu_abist_g8t_bw_0,      
        pc_iu_abist_g8t_bw_1           => pc_iu_abist_g8t_bw_1,      
        pc_iu_abist_g8t_dcomp          => pc_iu_abist_g8t_dcomp(0 to 3),
        pc_iu_abist_g8t_wenb           => pc_iu_abist_g8t_wenb,      
        pc_iu_abist_raddr_0            => pc_iu_abist_raddr_0(0 to 9),
        pc_iu_abist_raw_dc_b           => pc_iu_abist_raw_dc_b,      
        pc_iu_abist_waddr_0            => pc_iu_abist_waddr_0(0 to 9),
        pc_iu_abist_wl128_g8t_comp_ena => pc_iu_abist_wl128_g8t_comp_ena,
        pc_iu_abist_wl256_comp_ena     => pc_iu_abist_wl256_comp_ena,
        pc_iu_abist_wl64_g8t_comp_ena  => pc_iu_abist_wl64_g8t_comp_ena, 
        pc_mm_abist_dcomp_g6t_2r       => pc_mm_abist_dcomp_g6t_2r(0 to 3),
        pc_mm_abist_di_0               => pc_mm_abist_di_0(0 to 3),
        pc_mm_abist_di_g6t_2r          => pc_mm_abist_di_g6t_2r(0 to 3),
        pc_mm_abist_ena_dc             => pc_mm_abist_ena_dc,        
        pc_mm_abist_g6t_r_wb           => pc_mm_abist_g6t_r_wb,      
        pc_mm_abist_g8t1p_renb_0       => pc_mm_abist_g8t1p_renb_0,  
        pc_mm_abist_g8t_bw_0           => pc_mm_abist_g8t_bw_0,      
        pc_mm_abist_g8t_bw_1           => pc_mm_abist_g8t_bw_1,      
        pc_mm_abist_g8t_dcomp          => pc_mm_abist_g8t_dcomp(0 to 3),
        pc_mm_abist_g8t_wenb           => pc_mm_abist_g8t_wenb,      
        pc_mm_abist_raddr_0            => pc_mm_abist_raddr_0(0 to 9),
        pc_mm_abist_raw_dc_b           => pc_mm_abist_raw_dc_b,      
        pc_mm_abist_waddr_0            => pc_mm_abist_waddr_0(0 to 9),
        pc_mm_abist_wl128_g8t_comp_ena => pc_mm_abist_wl128_g8t_comp_ena,
        pc_xu_abist_dcomp_g6t_2r       => pc_xu_abist_dcomp_g6t_2r(0 to 3),
        pc_xu_abist_di_0               => pc_xu_abist_di_0(0 to 3),
        pc_xu_abist_di_1               => pc_xu_abist_di_1(0 to 3),
        pc_xu_abist_di_g6t_2r          => pc_xu_abist_di_g6t_2r(0 to 3),
        pc_xu_abist_ena_dc             => pc_xu_abist_ena_dc,        
        pc_xu_abist_g6t_bw             => pc_xu_abist_g6t_bw(0 to 1),
        pc_xu_abist_g6t_r_wb           => pc_xu_abist_g6t_r_wb,      
        pc_xu_abist_g8t1p_renb_0       => pc_xu_abist_g8t1p_renb_0,  
        pc_xu_abist_g8t_bw_0           => pc_xu_abist_g8t_bw_0,      
        pc_xu_abist_g8t_bw_1           => pc_xu_abist_g8t_bw_1,      
        pc_xu_abist_g8t_dcomp          => pc_xu_abist_g8t_dcomp(0 to 3),
        pc_xu_abist_g8t_wenb           => pc_xu_abist_g8t_wenb,      
        pc_xu_abist_grf_renb_0         => pc_xu_abist_grf_renb_0,    
        pc_xu_abist_grf_renb_1         => pc_xu_abist_grf_renb_1,    
        pc_xu_abist_grf_wenb_0         => pc_xu_abist_grf_wenb_0,          
        pc_xu_abist_grf_wenb_1         => pc_xu_abist_grf_wenb_1,    
        pc_xu_abist_raddr_0            => pc_xu_abist_raddr_0(0 to 9),
        pc_xu_abist_raddr_1            => pc_xu_abist_raddr_1(0 to 9),
        pc_xu_abist_raw_dc_b           => pc_xu_abist_raw_dc_b,      
        pc_xu_abist_waddr_0            => pc_xu_abist_waddr_0(0 to 9),
        pc_xu_abist_waddr_1            => pc_xu_abist_waddr_1(0 to 9),
        pc_xu_abist_wl144_comp_ena     => pc_xu_abist_wl144_comp_ena,
        pc_xu_abist_wl32_g8t_comp_ena  => pc_xu_abist_wl32_g8t_comp_ena, 
        pc_xu_abist_wl512_comp_ena     => pc_xu_abist_wl512_comp_ena
);


pcq_bolton : entity work.pcq_abist_bolton_frontend
generic map (  expand_type      => expand_type,
               num_backends     => 40 )
port map( 
        vdd                       => vdd,
        gnd                       => gnd,
        nclk                      => nclk,
        bcreset                   => pc_pc_bo_reset_0,
        bcdata                    => an_ac_bo_data,
        bcshcntl                  => an_ac_bo_shcntl,
        bcshdata                  => an_ac_bo_shdata,
        bcexe                     => an_ac_bo_exe,
        bcsysrepair               => an_ac_bo_sysrepair,
        bo_enable                 => pc_pc_bo_enable_0,
        bo_go                     => pc_pc_bo_go_0,
        donein                    => an_ac_bo_donein,
        sdin                      => an_ac_bo_sdin,
        doneout                   => ac_an_bo_doneout,
        sdout                     => ac_an_bo_sdout,
        diagloop_out              => ac_an_bo_diagloopout,
        waitin                    => an_ac_bo_waitin,
        failin                    => an_ac_bo_failin,
        waitout                   => ac_an_bo_waitout,
        failout                   => ac_an_bo_failout,
        abist_done                => abist_done_int,
        abist_si                  => abst_eng_si,
        abist_start_test_int      => an_ac_abist_start_test_int,
        abist_start_test          => an_ac_abist_start_test,
        abist_mode_dc             => an_ac_abist_mode_dc,
        abist_mode_dc_int         => an_ac_abist_mode_dc_int,
        bo_unload                 => pc_bo_unload_out,
        bo_load                   => pc_bo_load_out,
        bo_repair                 => pc_bo_repair_out,
        bo_reset                  => pc_bo_reset_out,
        bo_shdata                 => pc_bo_shdata_out,
        bo_select                 => pc_bo_select_out,
        bo_fail                   => pc_bo_fail_in,
        bo_diagout                => pc_bo_diagout_in,
        lbist_ac_mode_dc          => an_ac_lbist_ac_mode_dc,
        ck_bo_sl_thold_6          => pc_pc_bolt_sl_thold_6,
        ck_bo_sl_thold_0          => pc_pc_bolt_sl_thold_0,
        ck_bo_sg_0                => pc_pc_sg_0,
        lcb_clkoff_dc_b           => clkoff_dc_b,
        lcb_mpw1_dc_b             => mpw1_dc_b(4),
        lcb_mpw2_dc_b             => mpw2_dc_b,
        lcb_delay_lclkr_dc        => delay_lclkr_dc(4),
        lcb_act_dis_dc            => act_dis_dc,
        scan_in                   => abst_scan_out_int,
        scan_out                  => abst_scan_out,
        bo_pc_abst_sl_thold_6     => bo_pc_abst_sl_thold_6,
        bo_pc_pc_abst_sl_thold_6  => bo_pc_pc_abst_sl_thold_6,
        bo_pc_ary_nsl_thold_6     => bo_pc_ary_nsl_thold_6,
        bo_pc_func_sl_thold_6     => bo_pc_func_sl_thold_6,
        bo_pc_time_sl_thold_6     => bo_pc_time_sl_thold_6,
        bo_pc_repr_sl_thold_6     => bo_pc_repr_sl_thold_6,
        bo_pc_sg_6                => bo_pc_sg_6
);


pcq_bolton_stg : entity work.pcq_abist_bolton_stg
generic map( expand_type        => expand_type)
port map(
        vdd                     => vdd,
        gnd                     => gnd,
        nclk                    => nclk,
        pc_pc_ccflush_dc        => pc_pc_ccflush_dc,

        pu_pc_bo_enable         => an_ac_bo_enable,
        pu_pc_bo_go             => an_ac_bo_go,
        pu_pc_bo_cntlclk        => an_ac_bo_cntlclk,
        pu_pc_bo_reset          => an_ac_bo_reset,
        pu_pc_bo_fcshdata       => an_ac_bo_fcshdata,
        pu_pc_bo_fcreset        => an_ac_bo_fcreset,

        pc_bx_bo_enable_3       => pc_bx_bo_enable_3, 
        pc_fu_bo_enable_3       => pc_fu_bo_enable_3, 
        pc_iu_bo_enable_4       => pc_iu_bo_enable_4, 
        pc_mm_bo_enable_4       => pc_mm_bo_enable_4, 
        pc_xu_bo_enable_3       => pc_xu_bo_enable_3, 
        pc_pc_bo_go_0           => pc_pc_bo_go_0,
        pc_pc_bo_enable_0       => pc_pc_bo_enable_0,
        pc_pc_bo_cntlclk_0      => pc_pc_bo_cntlclk_0,
        pc_pc_bo_reset_0        => pc_pc_bo_reset_0,
        pc_pc_bo_fcshdata_0     => pc_pc_bo_fcshdata_0,
        pc_pc_bo_fcreset_0      => pc_pc_bo_fcreset_0
);


pc_bx_bo_unload   <=  pc_bo_unload_out; 
pc_fu_bo_unload   <=  pc_bo_unload_out;              
pc_iu_bo_unload   <=  pc_bo_unload_out;  
pc_mm_bo_unload   <=  pc_bo_unload_out;  
pc_xu_bo_unload   <=  pc_bo_unload_out;   

pc_fu_bo_load     <=  pc_bo_load_out;  
pc_xu_bo_load     <=  pc_bo_load_out;  

pc_bx_bo_repair   <=  pc_bo_repair_out;
pc_iu_bo_repair   <=  pc_bo_repair_out;
pc_mm_bo_repair   <=  pc_bo_repair_out; 
pc_xu_bo_repair   <=  pc_bo_repair_out;

pc_bx_bo_reset    <=  pc_bo_reset_out; 
pc_fu_bo_reset    <=  pc_bo_reset_out; 
pc_iu_bo_reset    <=  pc_bo_reset_out; 
pc_mm_bo_reset    <=  pc_bo_reset_out;
pc_xu_bo_reset    <=  pc_bo_reset_out; 

pc_bx_bo_shdata   <=  pc_bo_shdata_out;
pc_fu_bo_shdata   <=  pc_bo_shdata_out;
pc_iu_bo_shdata   <=  pc_bo_shdata_out;
pc_mm_bo_shdata   <=  pc_bo_shdata_out;
pc_xu_bo_shdata   <=  pc_bo_shdata_out;

pc_bx_bo_select(0 to 3)    <=  pc_bo_select_out(0 to 3);
pc_fu_bo_select(0 to 1)    <=  pc_bo_select_out(4 to 5);
pc_iu_bo_select(0 to 4)    <=  pc_bo_select_out(6 to 10);
pc_mm_bo_select(0 to 4)    <=  pc_bo_select_out(11 to 15);
pc_xu_bo_select(0 to 8)    <=  pc_bo_select_out(16 to 24); 

pc_bo_fail_in(0 to 39)     <=  bx_pc_bo_fail(0 to 3)  &  fu_pc_bo_fail(0 to 1) &
                               iu_pc_bo_fail(0 to 4)  &  mm_pc_bo_fail(0 to 4) &
                               xu_pc_bo_fail(0 to 8)  &  x"000" & "000";

pc_bo_diagout_in(0 to 39)  <=  bx_pc_bo_diagout(0 to 3)  &  fu_pc_bo_diagout(0 to 1) &
                               iu_pc_bo_diagout(0 to 4)  &  mm_pc_bo_diagout(0 to 4) &
                               xu_pc_bo_diagout(0 to 8)  &  x"000" & "000"  ;


pcq_psro : entity work.pcq_psro_soft
port map(
        vdd                  => vdd,
        gnd                  => gnd,
        pcq_psro_enable      => an_ac_psro_enable_dc(0 to 2),
        psro_pcq_ringsig     => pcq_psro_ringsig_out
);

u_pcq_psro_rsig_i:   pcq_psro_ringsig_i  <= not( pcq_psro_ringsig_out );
u_pcq_psro_rsig_ii:  ac_an_psro_ringsig  <= not( pcq_psro_ringsig_i );


lcbctrl : entity tri.tri_lcbcntl_mac
  generic map( expand_type => expand_type )
  port map(
        vdd            => vdd,
        gnd            => gnd,
        sg             => pc_pc_sg_0,
        nclk           => nclk,
        scan_in        => gptr_scan_in,
        scan_diag_dc   => an_ac_scan_diag_dc,
        thold          => pc_pc_gptr_sl_thold_0,
        clkoff_dc_b    => clkoff_dc_b,
        delay_lclkr_dc => delay_lclkr_dc(0 to 4),
        act_dis_dc     => open,
        d_mode_dc      => d_mode_dc,
        mpw1_dc_b      => mpw1_dc_b(0 to 4),
        mpw2_dc_b      => mpw2_dc_b,
        scan_out       => lcbctrl_gptr_scan_out
       );

  act_dis_dc <= '0';


end pcq;

