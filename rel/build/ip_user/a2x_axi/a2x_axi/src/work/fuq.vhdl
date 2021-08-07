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

entity fuq is
generic(
     expand_type                    : integer := 2 ;  
     eff_ifar                       : integer := 62;
     regmode                        : integer := 6);  
port( 
      
     pc_fu_ccflush_dc               : in  std_ulogic;
     an_ac_scan_dis_dc_b            : in  std_ulogic;
     an_ac_scan_diag_dc             : in  std_ulogic;

     pc_fu_gptr_sl_thold_3          : in  std_ulogic;
     pc_fu_time_sl_thold_3          : in  std_ulogic;
     pc_fu_repr_sl_thold_3          : in  std_ulogic;
     pc_fu_abst_sl_thold_3          : in  std_ulogic;
     pc_fu_abst_slp_sl_thold_3      : in  std_ulogic;
     pc_fu_func_sl_thold_3          : in  std_ulogic_vector(0 to 1);
     pc_fu_func_slp_sl_thold_3      : in  std_ulogic_vector(0 to 1);
     pc_fu_cfg_sl_thold_3           : in  std_ulogic;
     pc_fu_cfg_slp_sl_thold_3       : in  std_ulogic;
     pc_fu_func_nsl_thold_3         : in  std_ulogic;
     pc_fu_func_slp_nsl_thold_3     : in  std_ulogic;
     pc_fu_ary_nsl_thold_3          : in  std_ulogic;
     pc_fu_ary_slp_nsl_thold_3      : in  std_ulogic;
     pc_fu_sg_3                     : in  std_ulogic_vector(0 to 1);
     pc_fu_fce_3                    : in  std_ulogic;
     an_ac_lbist_en_dc              : in  std_ulogic;
     an_ac_abist_mode_dc            : in  std_ulogic;
     an_ac_lbist_ary_wrt_thru_dc    : in  std_ulogic;

     pc_fu_bolt_sl_thold_3          : in  std_ulogic;
     pc_fu_bo_enable_3              : in  std_ulogic;
     pc_fu_bo_unload                : in  std_ulogic;
     pc_fu_bo_load                  : in  std_ulogic;
     pc_fu_bo_reset                 : in  std_ulogic;
     pc_fu_bo_shdata                : in  std_ulogic;
     pc_fu_bo_select                : in  std_ulogic_vector(0 to 1);
     fu_pc_bo_fail                  : out std_ulogic_vector(0 to 1);
     fu_pc_bo_diagout               : out std_ulogic_vector(0 to 1);

     nclk                           : in  clk_logic;
     vdd                            : inout power_logic;
     gnd                            : inout power_logic;

     gptr_scan_in             : in  std_ulogic;                 
     time_scan_in             : in  std_ulogic;                 
     repr_scan_in             : in  std_ulogic;                 
     abst_scan_in             : in  std_ulogic;                 
     func_scan_in             : in  std_ulogic_vector(0 to 3);  
     ccfg_scan_in             : in  std_ulogic;                 
     bcfg_scan_in             : in  std_ulogic;                 
     dcfg_scan_in             : in  std_ulogic;                 

     gptr_scan_out            : out std_ulogic;
     time_scan_out            : out std_ulogic;
     repr_scan_out            : out std_ulogic;
     abst_scan_out            : out std_ulogic;
     func_scan_out            : out std_ulogic_vector(0 to 3);
     ccfg_scan_out            : out std_ulogic;
     bcfg_scan_out            : out std_ulogic;
     dcfg_scan_out            : out std_ulogic;


     bx_fu_rp_abst_scan_out   : in  std_ulogic;
     bx_rp_abst_scan_out      : out std_ulogic;

     rp_bx_abst_scan_in       : in  std_ulogic;
     rp_fu_bx_abst_scan_in    : out std_ulogic;

     rp_bx_func_scan_in       : in  std_ulogic_vector(0 to 1);
     rp_fu_bx_func_scan_in    : out std_ulogic_vector(0 to 1);

     bx_fu_rp_func_scan_out   : in  std_ulogic_vector(0 to 1);
     bx_rp_func_scan_out      : out std_ulogic_vector(0 to 1);

	 bx_pc_err_inbox_ue_ifu	          : in std_ulogic;
	 bx_pc_err_outbox_ue_ifu	      : in std_ulogic;
	 bx_pc_err_inbox_ecc_ifu	      : in std_ulogic;
	 bx_pc_err_outbox_ecc_ifu	      : in std_ulogic;
	 pc_bx_bolt_sl_thold_3_ifu	      : in std_ulogic;
	 pc_bx_bo_enable_3_ifu		      : in std_ulogic;
	 pc_bx_bo_unload_ifu	 	      : in std_ulogic;
	 pc_bx_bo_repair_ifu	 	      : in std_ulogic;
	 pc_bx_bo_reset_ifu	  	          : in std_ulogic;
	 pc_bx_bo_shdata_ifu	 	      : in std_ulogic;
	 pc_bx_bo_select_ifu	 	      : in std_ulogic_vector(0 to 3);
	 bx_pc_bo_fail_ifu			      : in std_ulogic_vector(0 to 3);
	 bx_pc_bo_diagout_ifu		      : in std_ulogic_vector(0 to 3);
	 pc_bx_abist_di_0_ifu		      : in std_ulogic_vector(0 to 3);
	 pc_bx_abist_ena_dc_ifu	          : in std_ulogic;
	 pc_bx_abist_g8t1p_renb_0_ifu	  : in std_ulogic;
	 pc_bx_abist_g8t_bw_0_ifu		  : in std_ulogic; 
	 pc_bx_abist_g8t_bw_1_ifu		  : in std_ulogic; 
	 pc_bx_abist_g8t_dcomp_ifu		  : in std_ulogic_vector(0 to 3); 
	 pc_bx_abist_g8t_wenb_ifu		  : in std_ulogic; 
	 pc_bx_abist_raddr_0_ifu		  : in std_ulogic_vector(4 to 9); 
	 pc_bx_abist_raw_dc_b_ifu		  : in std_ulogic; 
	 pc_bx_abist_waddr_0_ifu		  : in std_ulogic_vector(4 to 9); 
	 pc_bx_abist_wl64_comp_ena_ifu	  : in std_ulogic;
	 pc_bx_trace_bus_enable_ifu	      : in std_ulogic;
	 pc_bx_debug_mux1_ctrls_ifu	      : in std_ulogic_vector(0 to 15);
	 pc_bx_inj_inbox_ecc_ifu		  : in std_ulogic; 
	 pc_bx_inj_outbox_ecc_ifu		  : in std_ulogic; 
	 pc_bx_ccflush_dc_ifu		      : in std_ulogic;
	 pc_bx_sg_3_ifu			          : in std_ulogic;
	 pc_bx_func_sl_thold_3_ifu		  : in std_ulogic; 
	 pc_bx_func_slp_sl_thold_3_ifu	  : in std_ulogic;
	 pc_bx_gptr_sl_thold_3_ifu		  : in std_ulogic; 
	 pc_bx_time_sl_thold_3_ifu		  : in std_ulogic; 
	 pc_bx_repr_sl_thold_3_ifu		  : in std_ulogic; 
	 pc_bx_abst_sl_thold_3_ifu		  : in std_ulogic; 
	 pc_bx_ary_nsl_thold_3_ifu		  : in std_ulogic; 
	 pc_bx_ary_slp_nsl_thold_3_ifu	  : in std_ulogic;  

	 xu_pc_err_mcsr_summary_ifu             : in std_ulogic_vector(0 to 3);
     xu_pc_err_ierat_parity_ifu             : in std_ulogic;
     xu_pc_err_derat_parity_ifu             : in std_ulogic;
     xu_pc_err_tlb_parity_ifu               : in std_ulogic;
     xu_pc_err_tlb_lru_parity_ifu           : in std_ulogic;
     xu_pc_err_ierat_multihit_ifu           : in std_ulogic;
     xu_pc_err_derat_multihit_ifu           : in std_ulogic;
     xu_pc_err_tlb_multihit_ifu             : in std_ulogic;
     xu_pc_err_ext_mchk_ifu                 : in std_ulogic;
     xu_pc_err_mchk_disabled_ifu            : in std_ulogic;
     xu_pc_err_ditc_overrun_ifu             : in std_ulogic;
     xu_pc_err_local_snoop_reject_ifu       : in std_ulogic;
     xu_pc_err_attention_instr_ifu          : in std_ulogic_vector(0 to 3);
     xu_pc_err_dcache_parity_ifu            : in std_ulogic;
     xu_pc_err_dcachedir_parity_ifu         : in std_ulogic;
     xu_pc_err_dcachedir_multihit_ifu       : in std_ulogic;
     xu_pc_err_debug_event_ifu              : in std_ulogic_vector(0 to 3);
     xu_pc_err_invld_reld_ifu               : in std_ulogic;
     xu_pc_err_l2intrf_ecc_ifu              : in std_ulogic;
     xu_pc_err_l2intrf_ue_ifu               : in std_ulogic;
     xu_pc_err_l2credit_overrun_ifu         : in std_ulogic;
     xu_pc_err_llbust_attempt_ifu           : in std_ulogic_vector(0 to 3);
     xu_pc_err_llbust_failed_ifu            : in std_ulogic_vector(0 to 3);
     xu_pc_err_nia_miscmpr_ifu              : in std_ulogic_vector(0 to 3);
     xu_pc_err_regfile_parity_ifu           : in std_ulogic_vector(0 to 3);
     xu_pc_err_regfile_ue_ifu               : in std_ulogic_vector(0 to 3);
     xu_pc_err_sprg_ecc_ifu                 : in std_ulogic_vector(0 to 3);
     xu_pc_err_sprg_ue_ifu                  : in std_ulogic_vector(0 to 3);
     xu_pc_err_wdt_reset_ifu                : in std_ulogic_vector(0 to 3);
     xu_pc_event_data_ifu                   : in std_ulogic_vector(0 to 7);
     xu_pc_ram_data_ifu                     : in std_ulogic_vector(64-(2**regmode) to 63);
     xu_pc_ram_done_ifu                     : in std_ulogic;
     xu_pc_ram_interrupt_ifu                : in std_ulogic;
     xu_pc_running_ifu                      : in std_ulogic_vector(0 to 3);
     xu_pc_spr_ccr0_pme_ifu                 : in std_ulogic_vector(0 to 1);
     xu_pc_spr_ccr0_we_ifu                  : in std_ulogic_vector(0 to 3);
     xu_pc_step_done_ifu                    : in std_ulogic_vector(0 to 3);
     xu_pc_stop_dbg_event_ifu               : in std_ulogic_vector(0 to 3);
     xu_pc_lsu_event_data_ifu               : in std_ulogic_vector(0 to 7);
     pc_xu_bolt_sl_thold_3_ifu              : in std_ulogic;
     pc_xu_bo_enable_3_ifu                  : in std_ulogic;
     pc_xu_bo_unload_ifu                    : in std_ulogic;
     pc_xu_bo_load_ifu                      : in std_ulogic;
     pc_xu_bo_repair_ifu                    : in std_ulogic;
     pc_xu_bo_reset_ifu                     : in std_ulogic;
     pc_xu_bo_shdata_ifu                    : in std_ulogic;
     pc_xu_bo_select_ifu                    : in std_ulogic_vector(0 to 8);
     xu_pc_bo_fail_ifu                      : in std_ulogic_vector(0 to 8);
     xu_pc_bo_diagout_ifu                   : in std_ulogic_vector(0 to 8);
     pc_xu_abist_dcomp_g6t_2r_ifu           : in std_ulogic_vector(0 to 3);
     pc_xu_abist_di_0_ifu                   : in std_ulogic_vector(0 to 3);
     pc_xu_abist_di_1_ifu                   : in std_ulogic_vector(0 to 3);
     pc_xu_abist_di_g6t_2r_ifu              : in std_ulogic_vector(0 to 3);
     pc_xu_abist_ena_dc_ifu                 : in std_ulogic;
     pc_xu_abist_g6t_bw_ifu                 : in std_ulogic_vector(0 to 1);
     pc_xu_abist_g6t_r_wb_ifu               : in std_ulogic;
     pc_xu_abist_g8t1p_renb_0_ifu           : in std_ulogic;
     pc_xu_abist_g8t_bw_0_ifu               : in std_ulogic;
     pc_xu_abist_g8t_bw_1_ifu               : in std_ulogic;
     pc_xu_abist_g8t_dcomp_ifu              : in std_ulogic_vector(0 to 3);
     pc_xu_abist_g8t_wenb_ifu               : in std_ulogic;
     pc_xu_abist_grf_renb_0_ifu             : in std_ulogic;
     pc_xu_abist_grf_renb_1_ifu             : in std_ulogic;
     pc_xu_abist_grf_wenb_0_ifu             : in std_ulogic;
     pc_xu_abist_grf_wenb_1_ifu             : in std_ulogic;
     pc_xu_abist_raddr_0_ifu                : in std_ulogic_vector(0 to 9);
     pc_xu_abist_raddr_1_ifu                : in std_ulogic_vector(0 to 9);
     pc_xu_abist_raw_dc_b_ifu               : in std_ulogic;
     pc_xu_abist_waddr_0_ifu                : in std_ulogic_vector(0 to 9);
     pc_xu_abist_waddr_1_ifu                : in std_ulogic_vector(0 to 9);
     pc_xu_abist_wl144_comp_ena_ifu         : in std_ulogic;
     pc_xu_abist_wl32_comp_ena_ifu          : in std_ulogic;
     pc_xu_abist_wl512_comp_ena_ifu         : in std_ulogic;
     pc_xu_event_mux_ctrls_ifu              : in std_ulogic_vector(0 to 47);
     pc_xu_lsu_event_mux_ctrls_ifu          : in std_ulogic_vector(0 to 47);
     pc_xu_event_bus_enable_ifu             : in std_ulogic;
     pc_xu_abst_sl_thold_3_ifu              : in std_ulogic;
     pc_xu_abst_slp_sl_thold_3_ifu          : in std_ulogic;
     pc_xu_regf_sl_thold_3_ifu              : in std_ulogic;
     pc_xu_regf_slp_sl_thold_3_ifu          : in std_ulogic;
     pc_xu_ary_nsl_thold_3_ifu              : in std_ulogic;
     pc_xu_ary_slp_nsl_thold_3_ifu          : in std_ulogic;
     pc_xu_cache_par_err_event_ifu          : in std_ulogic;
     pc_xu_ccflush_dc_ifu                   : in std_ulogic;
     pc_xu_cfg_sl_thold_3_ifu               : in std_ulogic;
     pc_xu_cfg_slp_sl_thold_3_ifu           : in std_ulogic;
     pc_xu_dbg_action_ifu                   : in std_ulogic_vector(0 to 11);
     pc_xu_debug_mux1_ctrls_ifu             : in std_ulogic_vector(0 to 15);
     pc_xu_debug_mux2_ctrls_ifu             : in std_ulogic_vector(0 to 15);
     pc_xu_debug_mux3_ctrls_ifu             : in std_ulogic_vector(0 to 15);
     pc_xu_debug_mux4_ctrls_ifu             : in std_ulogic_vector(0 to 15);
     pc_xu_decrem_dis_on_stop_ifu           : in std_ulogic;
     pc_xu_event_count_mode_ifu             : in std_ulogic_vector(0 to 2);
     pc_xu_extirpts_dis_on_stop_ifu         : in std_ulogic;
     pc_xu_fce_3_ifu                        : in std_ulogic_vector(0 to 1);
     pc_xu_force_ude_ifu                    : in std_ulogic_vector(0 to 3);
     pc_xu_func_nsl_thold_3_ifu             : in std_ulogic;
     pc_xu_func_sl_thold_3_ifu              : in std_ulogic_vector(0 to 4);
     pc_xu_func_slp_nsl_thold_3_ifu         : in std_ulogic;
     pc_xu_func_slp_sl_thold_3_ifu          : in std_ulogic_vector(0 to 4);
     pc_xu_gptr_sl_thold_3_ifu              : in std_ulogic;
     pc_xu_init_reset_ifu                   : in std_ulogic;
     pc_xu_inj_dcache_parity_ifu            : in std_ulogic;
     pc_xu_inj_dcachedir_parity_ifu         : in std_ulogic;
     pc_xu_inj_llbust_attempt_ifu           : in std_ulogic_vector(0 to 3);
     pc_xu_inj_llbust_failed_ifu            : in std_ulogic_vector(0 to 3);
     pc_xu_inj_sprg_ecc_ifu                 : in std_ulogic_vector(0 to 3);
     pc_xu_inj_regfile_parity_ifu           : in std_ulogic_vector(0 to 3);
     pc_xu_inj_wdt_reset_ifu                : in std_ulogic_vector(0 to 3);
     pc_xu_inj_dcachedir_multihit_ifu       : in std_ulogic;
     pc_xu_instr_trace_mode_ifu             : in std_ulogic;
     pc_xu_instr_trace_tid_ifu              : in std_ulogic_vector(0 to 1);
     pc_xu_msrovride_enab_ifu               : in std_ulogic;
     pc_xu_msrovride_gs_ifu                 : in std_ulogic;
     pc_xu_msrovride_pr_ifu                 : in std_ulogic;
     pc_xu_ram_execute_ifu                  : in std_ulogic;
     pc_xu_ram_flush_thread_ifu             : in std_ulogic;
     pc_xu_ram_mode_ifu                     : in std_ulogic;
     pc_xu_ram_thread_ifu                   : in std_ulogic_vector(0 to 1);
     pc_xu_repr_sl_thold_3_ifu              : in std_ulogic;
     pc_xu_reset_1_cmplt_ifu                : in std_ulogic;
     pc_xu_reset_2_cmplt_ifu                : in std_ulogic;
     pc_xu_reset_3_cmplt_ifu                : in std_ulogic;
     pc_xu_reset_wd_cmplt_ifu               : in std_ulogic;
     pc_xu_sg_3_ifu                         : in std_ulogic_vector(0 to 4);
     pc_xu_step_ifu                         : in std_ulogic_vector(0 to 3);
     pc_xu_stop_ifu                         : in std_ulogic_vector(0 to 3);
     pc_xu_time_sl_thold_3_ifu              : in std_ulogic;
     pc_xu_timebase_dis_on_stop_ifu         : in std_ulogic;
     pc_xu_trace_bus_enable_ifu             : in std_ulogic;

	 bx_pc_err_inbox_ue_ofu	          : out std_ulogic;
	 bx_pc_err_outbox_ue_ofu	      : out std_ulogic;
	 bx_pc_err_inbox_ecc_ofu	      : out std_ulogic;
	 bx_pc_err_outbox_ecc_ofu	      : out std_ulogic;
	 pc_bx_bolt_sl_thold_3_ofu	      : out std_ulogic;
	 pc_bx_bo_enable_3_ofu		      : out std_ulogic;
	 pc_bx_bo_unload_ofu	 	      : out std_ulogic;
	 pc_bx_bo_repair_ofu	 	      : out std_ulogic;
	 pc_bx_bo_reset_ofu	  	          : out std_ulogic;
	 pc_bx_bo_shdata_ofu	 	      : out std_ulogic;
	 pc_bx_bo_select_ofu	 	      : out std_ulogic_vector(0 to 3);
	 bx_pc_bo_fail_ofu			      : out std_ulogic_vector(0 to 3);
	 bx_pc_bo_diagout_ofu		      : out std_ulogic_vector(0 to 3);
	 pc_bx_abist_di_0_ofu		      : out std_ulogic_vector(0 to 3);
	 pc_bx_abist_ena_dc_ofu	          : out std_ulogic;
	 pc_bx_abist_g8t1p_renb_0_ofu	  : out std_ulogic;
	 pc_bx_abist_g8t_bw_0_ofu		  : out std_ulogic; 
	 pc_bx_abist_g8t_bw_1_ofu		  : out std_ulogic; 
	 pc_bx_abist_g8t_dcomp_ofu		  : out std_ulogic_vector(0 to 3); 
	 pc_bx_abist_g8t_wenb_ofu		  : out std_ulogic; 
	 pc_bx_abist_raddr_0_ofu		  : out std_ulogic_vector(4 to 9); 
	 pc_bx_abist_raw_dc_b_ofu		  : out std_ulogic; 
	 pc_bx_abist_waddr_0_ofu		  : out std_ulogic_vector(4 to 9); 
	 pc_bx_abist_wl64_comp_ena_ofu	  : out std_ulogic;
	 pc_bx_trace_bus_enable_ofu	      : out std_ulogic;
	 pc_bx_debug_mux1_ctrls_ofu	      : out std_ulogic_vector(0 to 15);
	 pc_bx_inj_inbox_ecc_ofu		  : out std_ulogic; 
	 pc_bx_inj_outbox_ecc_ofu		  : out std_ulogic; 
	 pc_bx_ccflush_dc_ofu		      : out std_ulogic;
	 pc_bx_sg_3_ofu			          : out std_ulogic;
	 pc_bx_func_sl_thold_3_ofu		  : out std_ulogic; 
	 pc_bx_func_slp_sl_thold_3_ofu	  : out std_ulogic;
	 pc_bx_gptr_sl_thold_3_ofu		  : out std_ulogic; 
	 pc_bx_time_sl_thold_3_ofu		  : out std_ulogic; 
	 pc_bx_repr_sl_thold_3_ofu		  : out std_ulogic; 
	 pc_bx_abst_sl_thold_3_ofu		  : out std_ulogic; 
	 pc_bx_ary_nsl_thold_3_ofu		  : out std_ulogic; 
	 pc_bx_ary_slp_nsl_thold_3_ofu	  : out std_ulogic;  

	 xu_pc_err_mcsr_summary_ofu             : out std_ulogic_vector(0 to 3);
     xu_pc_err_ierat_parity_ofu             : out std_ulogic;
     xu_pc_err_derat_parity_ofu             : out std_ulogic;
     xu_pc_err_tlb_parity_ofu               : out std_ulogic;
     xu_pc_err_tlb_lru_parity_ofu           : out std_ulogic;
     xu_pc_err_ierat_multihit_ofu           : out std_ulogic;
     xu_pc_err_derat_multihit_ofu           : out std_ulogic;
     xu_pc_err_tlb_multihit_ofu             : out std_ulogic;
     xu_pc_err_ext_mchk_ofu                 : out std_ulogic;
     xu_pc_err_mchk_disabled_ofu            : out std_ulogic;
     xu_pc_err_ditc_overrun_ofu             : out std_ulogic;
     xu_pc_err_local_snoop_reject_ofu       : out std_ulogic;
     xu_pc_err_attention_instr_ofu          : out std_ulogic_vector(0 to 3);
     xu_pc_err_dcache_parity_ofu            : out std_ulogic;
     xu_pc_err_dcachedir_parity_ofu         : out std_ulogic;
     xu_pc_err_dcachedir_multihit_ofu       : out std_ulogic;
     xu_pc_err_debug_event_ofu              : out std_ulogic_vector(0 to 3);
     xu_pc_err_invld_reld_ofu               : out std_ulogic;
     xu_pc_err_l2intrf_ecc_ofu              : out std_ulogic;
     xu_pc_err_l2intrf_ue_ofu               : out std_ulogic;
     xu_pc_err_l2credit_overrun_ofu         : out std_ulogic;
     xu_pc_err_llbust_attempt_ofu           : out std_ulogic_vector(0 to 3);
     xu_pc_err_llbust_failed_ofu            : out std_ulogic_vector(0 to 3);
     xu_pc_err_nia_miscmpr_ofu              : out std_ulogic_vector(0 to 3);
     xu_pc_err_regfile_parity_ofu           : out std_ulogic_vector(0 to 3);
     xu_pc_err_regfile_ue_ofu               : out std_ulogic_vector(0 to 3);
     xu_pc_err_sprg_ecc_ofu                 : out std_ulogic_vector(0 to 3);
     xu_pc_err_sprg_ue_ofu                  : out std_ulogic_vector(0 to 3);
     xu_pc_err_wdt_reset_ofu                : out std_ulogic_vector(0 to 3);
     xu_pc_event_data_ofu                   : out std_ulogic_vector(0 to 7);
     xu_pc_ram_data_ofu                     : out std_ulogic_vector(64-(2**regmode) to 63);
     xu_pc_ram_done_ofu                     : out std_ulogic;
     xu_pc_ram_interrupt_ofu                : out std_ulogic;
     xu_pc_running_ofu                      : out std_ulogic_vector(0 to 3);
     xu_pc_spr_ccr0_pme_ofu                 : out std_ulogic_vector(0 to 1);
     xu_pc_spr_ccr0_we_ofu                  : out std_ulogic_vector(0 to 3);
     xu_pc_step_done_ofu                    : out std_ulogic_vector(0 to 3);
     xu_pc_stop_dbg_event_ofu               : out std_ulogic_vector(0 to 3);
     xu_pc_lsu_event_data_ofu               : out std_ulogic_vector(0 to 7);
     pc_xu_bolt_sl_thold_3_ofu              : out std_ulogic;
     pc_xu_bo_enable_3_ofu                  : out std_ulogic;
     pc_xu_bo_unload_ofu                    : out std_ulogic;
     pc_xu_bo_load_ofu                      : out std_ulogic;
     pc_xu_bo_repair_ofu                    : out std_ulogic;
     pc_xu_bo_reset_ofu                     : out std_ulogic;
     pc_xu_bo_shdata_ofu                    : out std_ulogic;
     pc_xu_bo_select_ofu                    : out std_ulogic_vector(0 to 8);
     xu_pc_bo_fail_ofu                      : out std_ulogic_vector(0 to 8);
     xu_pc_bo_diagout_ofu                   : out std_ulogic_vector(0 to 8);
     pc_xu_abist_dcomp_g6t_2r_ofu           : out std_ulogic_vector(0 to 3);
     pc_xu_abist_di_0_ofu                   : out std_ulogic_vector(0 to 3);
     pc_xu_abist_di_1_ofu                   : out std_ulogic_vector(0 to 3);
     pc_xu_abist_di_g6t_2r_ofu              : out std_ulogic_vector(0 to 3);
     pc_xu_abist_ena_dc_ofu                 : out std_ulogic;
     pc_xu_abist_g6t_bw_ofu                 : out std_ulogic_vector(0 to 1);
     pc_xu_abist_g6t_r_wb_ofu               : out std_ulogic;
     pc_xu_abist_g8t1p_renb_0_ofu           : out std_ulogic;
     pc_xu_abist_g8t_bw_0_ofu               : out std_ulogic;
     pc_xu_abist_g8t_bw_1_ofu               : out std_ulogic;
     pc_xu_abist_g8t_dcomp_ofu              : out std_ulogic_vector(0 to 3);
     pc_xu_abist_g8t_wenb_ofu               : out std_ulogic;
     pc_xu_abist_grf_renb_0_ofu             : out std_ulogic;
     pc_xu_abist_grf_renb_1_ofu             : out std_ulogic;
     pc_xu_abist_grf_wenb_0_ofu             : out std_ulogic;
     pc_xu_abist_grf_wenb_1_ofu             : out std_ulogic;
     pc_xu_abist_raddr_0_ofu                : out std_ulogic_vector(0 to 9);
     pc_xu_abist_raddr_1_ofu                : out std_ulogic_vector(0 to 9);
     pc_xu_abist_raw_dc_b_ofu               : out std_ulogic;
     pc_xu_abist_waddr_0_ofu                : out std_ulogic_vector(0 to 9);
     pc_xu_abist_waddr_1_ofu                : out std_ulogic_vector(0 to 9);
     pc_xu_abist_wl144_comp_ena_ofu         : out std_ulogic;
     pc_xu_abist_wl32_comp_ena_ofu          : out std_ulogic;
     pc_xu_abist_wl512_comp_ena_ofu         : out std_ulogic;
     pc_xu_event_mux_ctrls_ofu              : out std_ulogic_vector(0 to 47);
     pc_xu_lsu_event_mux_ctrls_ofu          : out std_ulogic_vector(0 to 47);
     pc_xu_event_bus_enable_ofu             : out std_ulogic;
     pc_xu_abst_sl_thold_3_ofu              : out std_ulogic;
     pc_xu_abst_slp_sl_thold_3_ofu          : out std_ulogic;
     pc_xu_regf_sl_thold_3_ofu              : out std_ulogic;
     pc_xu_regf_slp_sl_thold_3_ofu          : out std_ulogic;
     pc_xu_ary_nsl_thold_3_ofu              : out std_ulogic;
     pc_xu_ary_slp_nsl_thold_3_ofu          : out std_ulogic;
     pc_xu_cache_par_err_event_ofu          : out std_ulogic;
     pc_xu_ccflush_dc_ofu                   : out std_ulogic;
     pc_xu_cfg_sl_thold_3_ofu               : out std_ulogic;
     pc_xu_cfg_slp_sl_thold_3_ofu           : out std_ulogic;
     pc_xu_dbg_action_ofu                   : out std_ulogic_vector(0 to 11);
     pc_xu_debug_mux1_ctrls_ofu             : out std_ulogic_vector(0 to 15);
     pc_xu_debug_mux2_ctrls_ofu             : out std_ulogic_vector(0 to 15);
     pc_xu_debug_mux3_ctrls_ofu             : out std_ulogic_vector(0 to 15);
     pc_xu_debug_mux4_ctrls_ofu             : out std_ulogic_vector(0 to 15);
     pc_xu_decrem_dis_on_stop_ofu           : out std_ulogic;
     pc_xu_event_count_mode_ofu             : out std_ulogic_vector(0 to 2);
     pc_xu_extirpts_dis_on_stop_ofu         : out std_ulogic;
     pc_xu_fce_3_ofu                        : out std_ulogic_vector(0 to 1);
     pc_xu_force_ude_ofu                    : out std_ulogic_vector(0 to 3);
     pc_xu_func_nsl_thold_3_ofu             : out std_ulogic;
     pc_xu_func_sl_thold_3_ofu              : out std_ulogic_vector(0 to 4);
     pc_xu_func_slp_nsl_thold_3_ofu         : out std_ulogic;
     pc_xu_func_slp_sl_thold_3_ofu          : out std_ulogic_vector(0 to 4);
     pc_xu_gptr_sl_thold_3_ofu              : out std_ulogic;
     pc_xu_init_reset_ofu                   : out std_ulogic;
     pc_xu_inj_dcache_parity_ofu            : out std_ulogic;
     pc_xu_inj_dcachedir_parity_ofu         : out std_ulogic;
     pc_xu_inj_llbust_attempt_ofu           : out std_ulogic_vector(0 to 3);
     pc_xu_inj_llbust_failed_ofu            : out std_ulogic_vector(0 to 3);
     pc_xu_inj_sprg_ecc_ofu                 : out std_ulogic_vector(0 to 3);
     pc_xu_inj_regfile_parity_ofu           : out std_ulogic_vector(0 to 3);
     pc_xu_inj_wdt_reset_ofu                : out std_ulogic_vector(0 to 3);
     pc_xu_inj_dcachedir_multihit_ofu       : out std_ulogic;
     pc_xu_instr_trace_mode_ofu             : out std_ulogic;
     pc_xu_instr_trace_tid_ofu              : out std_ulogic_vector(0 to 1);
     pc_xu_msrovride_enab_ofu               : out std_ulogic;
     pc_xu_msrovride_gs_ofu                 : out std_ulogic;
     pc_xu_msrovride_pr_ofu                 : out std_ulogic;
     pc_xu_ram_execute_ofu                  : out std_ulogic;
     pc_xu_ram_flush_thread_ofu             : out std_ulogic;
     pc_xu_ram_mode_ofu                     : out std_ulogic;
     pc_xu_ram_thread_ofu                   : out std_ulogic_vector(0 to 1);
     pc_xu_repr_sl_thold_3_ofu              : out std_ulogic;
     pc_xu_reset_1_cmplt_ofu                : out std_ulogic;
     pc_xu_reset_2_cmplt_ofu                : out std_ulogic;
     pc_xu_reset_3_cmplt_ofu                : out std_ulogic;
     pc_xu_reset_wd_cmplt_ofu               : out std_ulogic;
     pc_xu_sg_3_ofu                         : out std_ulogic_vector(0 to 4);
     pc_xu_step_ofu                         : out std_ulogic_vector(0 to 3);
     pc_xu_stop_ofu                         : out std_ulogic_vector(0 to 3);
     pc_xu_time_sl_thold_3_ofu              : out std_ulogic;
     pc_xu_timebase_dis_on_stop_ofu         : out std_ulogic;
     pc_xu_trace_bus_enable_ofu             : out std_ulogic;
     an_ac_scan_dis_dc_b_ofu                : out std_ulogic;
     an_ac_scan_diag_dc_ofu                 : out std_ulogic;
     xu_ex2_flush_ofu                       : out std_ulogic_vector(0 to 3);
     xu_ex3_flush_ofu                       : out std_ulogic_vector(0 to 3);
     xu_ex4_flush_ofu                       : out std_ulogic_vector(0 to 3);
     xu_ex5_flush_ofu                       : out std_ulogic_vector(0 to 3);
     an_ac_lbist_ary_wrt_thru_dc_ofu        : out std_ulogic;

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
     xu_is2_flush                   : in  std_ulogic_vector(0 to 3);
     xu_rf0_flush                   : in  std_ulogic_vector(0 to 3);
     xu_rf1_flush                   : in  std_ulogic_vector(0 to 3);
     xu_ex1_flush                   : in  std_ulogic_vector(0 to 3);
     xu_ex2_flush                   : in  std_ulogic_vector(0 to 3);
     xu_ex3_flush                   : in  std_ulogic_vector(0 to 3);
     xu_ex4_flush                   : in  std_ulogic_vector(0 to 3);
     xu_ex5_flush                   : in  std_ulogic_vector(0 to 3);
     xu_fu_ex3_eff_addr             : in  std_ulogic_vector(59 to 63);
     fu_xu_ex2_ifar_val             : out std_ulogic_vector(0 to 3);
     fu_xu_ex2_ifar_issued          : out std_ulogic_vector(0 to 3);
     fu_xu_ex1_ifar                 : out std_ulogic_vector(62-eff_ifar to 61);
     fu_xu_ex3_n_flush              : out std_ulogic_vector(0 to 3);
     fu_xu_ex3_np1_flush            : out std_ulogic_vector(0 to 3);
     fu_xu_ex3_flush2ucode          : out std_ulogic_vector(0 to 3);
     fu_xu_ex2_instr_type           : out std_ulogic_vector(0 to 11);
     fu_xu_ex2_instr_match          : out std_ulogic_vector(0 to 3);
     fu_xu_ex2_is_ucode             : out std_ulogic_vector(0 to 3);
     fu_xu_ex3_trap                 : out std_ulogic_vector(0 to 3);
     fu_xu_ex3_ap_int_req           : out std_ulogic_vector(0 to 3);
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
     pc_fu_ram_mode                 : in  std_ulogic;
     pc_fu_ram_thread               : in  std_ulogic_vector(0 to 1);
     fu_pc_ram_done                 : out std_ulogic;
     fu_pc_ram_data                 : out std_ulogic_vector(0 to 63);
     pc_fu_trace_bus_enable         : in  std_ulogic;
     pc_fu_event_bus_enable         : in  std_ulogic;
     pc_fu_instr_trace_mode         : in  std_ulogic;
     pc_fu_instr_trace_tid          : in  std_ulogic_vector(0 to 1);
     pc_fu_debug_mux_ctrls          : in  std_ulogic_vector(0 to 15);
     pc_fu_event_count_mode         : in  std_ulogic_vector(0 to 2);
     pc_fu_event_mux_ctrls          : in  std_ulogic_vector(0 to 31);
     debug_data_in                  : in  std_ulogic_vector(0 to 87);
     debug_data_out                 : out std_ulogic_vector(0 to 87);
     trace_triggers_in              : in  std_ulogic_vector(0 to 11);
     trace_triggers_out             : out std_ulogic_vector(0 to 11);
     fu_pc_event_data               : out std_ulogic_vector(0 to 7);
     pc_fu_abist_di_0               : in  std_ulogic_vector(0 to 3);
     pc_fu_abist_di_1               : in  std_ulogic_vector(0 to 3);
     pc_fu_abist_ena_dc             : in  std_ulogic;
     pc_fu_abist_grf_renb_0         : in  std_ulogic;
     pc_fu_abist_grf_renb_1         : in  std_ulogic;
     pc_fu_abist_grf_wenb_0         : in  std_ulogic;      
     pc_fu_abist_grf_wenb_1         : in  std_ulogic;      
     pc_fu_abist_raddr_0            : in  std_ulogic_vector(0 to 9);
     pc_fu_abist_raddr_1            : in  std_ulogic_vector(0 to 9);
     pc_fu_abist_raw_dc_b           : in  std_ulogic;
     pc_fu_abist_waddr_0            : in  std_ulogic_vector(0 to 9);
     pc_fu_abist_waddr_1            : in  std_ulogic_vector(0 to 9);
     pc_fu_abist_wl144_comp_ena     : in  std_ulogic;
     fu_pc_err_regfile_parity       : out std_ulogic_vector(0 to 3);
     fu_pc_err_regfile_ue           : out std_ulogic_vector(0 to 3);
     pc_fu_inj_regfile_parity       : in  std_ulogic_vector(0 to 3);
     fu_xu_ex3_regfile_err_det      : out std_ulogic_vector(0 to 3);
     xu_fu_regfile_seq_beg          : in  std_ulogic;
     fu_xu_regfile_seq_end          : out std_ulogic;

     fu_xu_ex2_store_data           : out std_ulogic_vector(0 to 63);
     fu_xu_ex2_store_data_val       : out std_ulogic;
     xu_fu_ex5_load_val             : in  std_ulogic_vector(0 to 3);
     xu_fu_ex5_load_tag             : in  std_ulogic_vector(0 to 8);
     xu_fu_ex5_load_le              : in  std_ulogic;
     xu_fu_ex5_reload_val           : in  std_ulogic;
     xu_fu_ex6_load_data            : in  std_ulogic_vector(192 to 255);
     fu_xu_rf1_act                  : out std_ulogic_vector(0 to 3);
     fu_xu_ex2_async_block          : out std_ulogic_vector(0 to 3);
     xu_fu_msr_fp                   : in  std_ulogic_vector(0 to 3);
     xu_fu_msr_pr                   : in  std_ulogic_vector(0 to 3);
     xu_fu_msr_gs                   : in  std_ulogic_vector(0 to 3);
     fu_iu_uc_special               : out std_ulogic_vector(0 to 3);
     fu_xu_ex4_cr_val               : out std_ulogic_vector(0 to 3);               
     fu_xu_ex4_cr_noflush           : out std_ulogic_vector(0 to 3);               
     fu_xu_ex4_cr_bf                : out std_ulogic_vector(0 to 2);
     fu_xu_ex4_cr                   : out std_ulogic_vector(0 to 3)
);
     -- synopsys translate_off
     -- synopsys translate_on

end fuq;

architecture fuq of fuq is





signal         f_dcd_msr_fp_act           : std_ulogic;

signal         f_dcd_ex6_frt_addr         : std_ulogic_vector(0 to 5);
signal         f_dcd_ex6_frt_tid          : std_ulogic_vector(0 to 1);
signal         f_dcd_ex6_frt_wen          : std_ulogic;
signal         f_dcd_ex5_frt_tid          : std_ulogic_vector(0 to 1);


signal         f_dcd_rf1_mad_act         :  std_ulogic;
signal         f_dcd_rf1_sto_act         :  std_ulogic;
signal         f_dcd_ex6_cancel          :  std_ulogic;
signal         f_dcd_rf1_bypsel_a_res0   :   std_ulogic;
signal         f_dcd_rf1_bypsel_a_load0  :   std_ulogic;
signal         f_dcd_rf1_bypsel_b_res0   :   std_ulogic;
signal         f_dcd_rf1_bypsel_b_load0  :   std_ulogic;
signal         f_dcd_rf1_bypsel_c_res0   :   std_ulogic;
signal         f_dcd_rf1_bypsel_c_load0  :   std_ulogic;
signal         f_dcd_rf1_bypsel_a_res1   :   std_ulogic;
signal         f_dcd_rf1_bypsel_a_load1  :   std_ulogic;
signal         f_dcd_rf1_bypsel_b_res1   :   std_ulogic;
signal         f_dcd_rf1_bypsel_b_load1  :   std_ulogic;
signal         f_dcd_rf1_bypsel_c_res1   :   std_ulogic;
signal         f_dcd_rf1_bypsel_c_load1  :   std_ulogic;
signal         f_dcd_rf0_bypsel_a_res1   :   std_ulogic;
signal         f_dcd_rf0_bypsel_a_load1  :   std_ulogic;
signal         f_dcd_rf0_bypsel_b_res1   :   std_ulogic;
signal         f_dcd_rf0_bypsel_b_load1  :   std_ulogic;
signal         f_dcd_rf0_bypsel_c_res1   :   std_ulogic;
signal         f_dcd_rf0_bypsel_c_load1  :   std_ulogic;
signal         f_dcd_rf0_bypsel_s_res1   :   std_ulogic;
signal         f_dcd_rf0_bypsel_s_load1  :   std_ulogic;

signal         f_fpr_ex7_load_sign        :  std_ulogic;
signal         f_fpr_ex7_load_expo        :  std_ulogic_vector(3 to 13);
signal         f_fpr_ex7_load_frac        :  std_ulogic_vector(0 to 52);
signal         f_fpr_ex7_load_addr        :  std_ulogic_vector(0 to 7);
signal         f_fpr_ex7_load_v           :  std_ulogic;
signal         f_fpr_rf1_a_sign           :  std_ulogic;
signal         f_fpr_rf1_a_expo           :  std_ulogic_vector(1 to 13) ;
signal         f_fpr_rf1_a_frac           :  std_ulogic_vector(0 to 52) ;
signal         f_fpr_rf1_c_sign           :  std_ulogic;
signal         f_fpr_rf1_c_expo           :  std_ulogic_vector(1 to 13) ;
signal         f_fpr_rf1_c_frac           :  std_ulogic_vector(0 to 52) ;
signal         f_fpr_rf1_b_sign           :  std_ulogic;
signal         f_fpr_rf1_b_expo           :  std_ulogic_vector(1 to 13) ;
signal         f_fpr_rf1_b_frac           :  std_ulogic_vector(0 to 52) ;
signal         f_fpr_ex7_frt_sign         :  std_ulogic;
signal         f_fpr_ex7_frt_expo         :  std_ulogic_vector(1 to 13);
signal         f_fpr_ex7_frt_frac         :  std_ulogic_vector(0 to 52);
signal         f_fpr_ex8_load_sign        :  std_ulogic;
signal         f_fpr_ex8_load_expo        :  std_ulogic_vector(3 to 13);
signal         f_fpr_ex8_load_frac        :  std_ulogic_vector(0 to 52);
signal         f_dcd_rf1_aop_valid        :  std_ulogic;
signal         f_dcd_rf1_cop_valid        :  std_ulogic;
signal         f_dcd_rf1_bop_valid        :  std_ulogic;
signal         f_dcd_rf1_sp               :  std_ulogic; 
signal         f_dcd_rf1_emin_dp          :  std_ulogic;                 
signal         f_dcd_rf1_emin_sp          :  std_ulogic;                 
signal         f_dcd_rf1_force_pass_b     :  std_ulogic;                 
signal         f_dcd_rf1_fsel_b           :  std_ulogic;                 
signal         f_dcd_rf1_from_integer_b   :  std_ulogic;                 
signal         f_dcd_rf1_to_integer_b     :  std_ulogic;                 
signal         f_dcd_rf1_rnd_to_int_b     :  std_ulogic;                 
signal         f_dcd_rf1_math_b           :  std_ulogic;                 
signal         f_dcd_rf1_est_recip_b      :  std_ulogic;                 
signal         f_dcd_rf1_est_rsqrt_b      :  std_ulogic;                 
signal         f_dcd_rf1_move_b           :  std_ulogic;                 
signal         f_dcd_rf1_prenorm_b        :  std_ulogic;                 
signal         f_dcd_rf1_frsp_b           :  std_ulogic;                 
signal         f_dcd_rf1_compare_b        :  std_ulogic;                 
signal         f_dcd_rf1_ordered_b        :  std_ulogic;                 
signal         f_dcd_rf1_div_beg          :  std_ulogic;                 
signal         f_dcd_rf1_sqrt_beg         :  std_ulogic;                 
signal         f_dcd_rf1_force_excp_dis   :  std_ulogic;                 
signal         f_dcd_rf1_nj_deni          :  std_ulogic;                 
signal         f_dcd_rf1_nj_deno          :  std_ulogic;                 
signal         f_dcd_rf1_sp_conv_b        :  std_ulogic;                 
signal         f_dcd_rf1_word_b           :  std_ulogic;                 
signal         f_dcd_rf1_uns_b            :  std_ulogic;                 
signal         f_dcd_rf1_sub_op_b         :  std_ulogic;                 
signal         f_dcd_rf1_op_rnd_v_b       :  std_ulogic;                 
signal         f_dcd_rf1_op_rnd_b         :  std_ulogic_vector(0 to 1);  
signal         f_dcd_rf1_inv_sign_b       :  std_ulogic;                 
signal         f_dcd_rf1_sign_ctl_b       :  std_ulogic_vector(0 to 1);  
signal         f_dcd_rf1_sgncpy_b         :  std_ulogic;                 
signal         f_dcd_rf1_fpscr_bit_data_b :  std_ulogic_vector(0 to 3);  
signal         f_dcd_rf1_fpscr_bit_mask_b :  std_ulogic_vector(0 to 3);  
signal         f_dcd_rf1_fpscr_nib_mask_b :  std_ulogic_vector(0 to 8);  
signal         f_dcd_rf1_mv_to_scr_b      :  std_ulogic;                 
signal         f_dcd_rf1_mv_from_scr_b    :  std_ulogic;                 
signal         f_dcd_rf1_mtfsbx_b         :  std_ulogic;                 
signal         f_dcd_rf1_mcrfs_b          :  std_ulogic;                 
signal         f_dcd_rf1_mtfsf_b          :  std_ulogic;                 
signal         f_dcd_rf1_mtfsfi_b         :  std_ulogic;                 
signal         f_scr_ex7_cr_fld           :  std_ulogic_vector (0 to 3)     ;
signal         f_add_ex4_fpcc_iu          :  std_ulogic_vector (0 to 3)     ;
signal         f_rnd_ex6_res_expo         :  std_ulogic_vector (1 to 13)    ;
signal         f_rnd_ex6_res_frac         :  std_ulogic_vector (0 to 52)    ;
signal         f_rnd_ex6_res_sign         :  std_ulogic                     ;
signal         f_dcd_rf1_thread_b         :  std_ulogic_vector(0 to 3)      ;
signal         f_dcd_rf1_sto_dp           :  std_ulogic                     ;
signal         f_dcd_rf1_sto_sp           :  std_ulogic                     ;
signal         f_dcd_rf1_sto_wd           :  std_ulogic                     ;
signal         f_dcd_rf1_log2e_b          :  std_ulogic                     ;
signal         f_dcd_rf1_pow2e_b          :  std_ulogic                     ;
signal         f_dcd_rf1_ftdiv            :  std_ulogic                     ;
signal         f_dcd_rf1_ftsqrt           :  std_ulogic                     ;
signal         f_ex2_b_den_flush          :  std_ulogic                     ;
signal         f_scr_ex7_fx_thread0       : std_ulogic_vector (0 to 3)     ;
signal         f_scr_ex7_fx_thread1       : std_ulogic_vector (0 to 3)     ;
signal         f_scr_ex7_fx_thread2       : std_ulogic_vector (0 to 3)     ;
signal         f_scr_ex7_fx_thread3       : std_ulogic_vector (0 to 3)     ;
signal         f_dcd_rf0_tid              :  std_ulogic_vector(0 to 1)     ;
signal         f_dcd_rf0_fra              :  std_ulogic_vector(0 to 5);
signal         f_dcd_rf0_frb              :  std_ulogic_vector(0 to 5);
signal         f_dcd_rf0_frc              :  std_ulogic_vector(0 to 5);
signal         f_dcd_rf1_uc_ft_pos        :  std_ulogic;
signal         f_dcd_rf1_uc_ft_neg        :  std_ulogic;
signal         f_dcd_rf1_uc_fa_pos        :  std_ulogic;
signal         f_dcd_rf1_uc_fc_pos        :  std_ulogic;
signal         f_dcd_rf1_uc_fb_pos        :  std_ulogic;
signal         f_dcd_rf1_uc_fc_hulp       :  std_ulogic;
signal         f_dcd_rf1_uc_fc_0_5        :  std_ulogic;
signal         f_dcd_rf1_uc_fc_1_0        :  std_ulogic;
signal         f_dcd_rf1_uc_fc_1_minus    :  std_ulogic;
signal         f_dcd_rf1_uc_fb_1_0        :  std_ulogic;
signal         f_dcd_rf1_uc_fb_0_75       :  std_ulogic;
signal         f_dcd_rf1_uc_fb_0_5        :  std_ulogic;
signal         f_dcd_ex2_uc_inc_lsb       :  std_ulogic;
signal         f_dcd_ex2_uc_gs_v          :  std_ulogic;
signal         f_dcd_ex2_uc_gs            :  std_ulogic_vector(0 to 1);
signal         f_dcd_perr_sm_running      :  std_ulogic;
signal      f_dcd_ex1_perr_force_c         :  std_ulogic;
signal      f_dcd_ex1_perr_fsel_ovrd       :  std_ulogic;

signal         f_pic_ex5_fpr_wr_dis_b     :  std_ulogic                     ;
signal         f_fpr_rf1_s_sign           :  std_ulogic                    ;
signal         f_fpr_rf1_s_expo           :  std_ulogic_vector(1 to 11)    ;
signal         f_fpr_rf1_s_frac           :  std_ulogic_vector(0 to 52)    ;

signal         f_mad_si                   :  std_ulogic_vector(0 to 17) ;
signal         f_mad_so                   :  std_ulogic_vector(0 to 17) ;
signal         f_dcd_si                   :  std_ulogic;
signal         f_dcd_so                   :  std_ulogic;
signal         f_fpr_si                   :  std_ulogic;
signal         f_fpr_so                   :  std_ulogic;
signal         f_sto_si                   :  std_ulogic;
signal         f_sto_so                   :  std_ulogic;
signal         gptr_scan_io               :  std_ulogic;

signal         time_sl_thold_1            :  std_ulogic;
signal         abst_sl_thold_1            :  std_ulogic;
signal         func_sl_thold_1            :  std_ulogic_vector(0 to 1);
signal         ary_nsl_thold_1            :  std_ulogic;
signal         cfg_sl_thold_1             :  std_ulogic;
signal         func_slp_sl_thold_1        :  std_ulogic;
signal         gptr_sl_thold_0            :  std_ulogic;

signal         fce_1                      :  std_ulogic;
signal         sg_1                       :  std_ulogic_vector(0 to 1);
signal         clkoff_dc_b                :  std_ulogic;
signal         act_dis                    :  std_ulogic;
signal         delay_lclkr_dc             :  std_ulogic_vector(0 to 9);
signal         mpw1_dc_b                  :  std_ulogic_vector(0 to 9);
signal         mpw2_dc_b                  :  std_ulogic_vector(0 to 1);

signal         fpu_enable                 :  std_ulogic; 

signal         f_mad_ex6_uc_sign          :std_ulogic;
signal         f_mad_ex6_uc_zero          :std_ulogic;
signal         f_mad_ex3_uc_special       :std_ulogic;
signal         f_mad_ex3_uc_vxsqrt        :std_ulogic;
signal         f_mad_ex3_uc_vxsnan        :std_ulogic;
signal         f_mad_ex3_uc_zx            :std_ulogic;
signal         f_mad_ex3_uc_vxidi         :std_ulogic;
signal         f_mad_ex3_uc_vxzdz         :std_ulogic;
signal         f_mad_ex3_uc_res_sign      :std_ulogic;
signal         f_mad_ex3_uc_round_mode    :std_ulogic_vector(0 to 1);
 signal  f_dcd_rf1_uc_mid           :std_ulogic;
 signal  f_dcd_rf1_uc_end           :std_ulogic;
 signal  f_dcd_rf1_uc_special       :std_ulogic;
 signal  f_dcd_ex2_uc_vxsnan        :std_ulogic;
 signal  f_dcd_ex2_uc_zx            :std_ulogic;
 signal  f_dcd_ex2_uc_vxidi         :std_ulogic;
 signal  f_dcd_ex2_uc_vxzdz         :std_ulogic;
 signal  f_dcd_ex2_uc_vxsqrt        :std_ulogic;
 signal  f_fpr_ex1_a_par            :std_ulogic_vector(0 to 7);
 signal  f_fpr_ex1_b_par            :std_ulogic_vector(0 to 7);
 signal  f_fpr_ex1_c_par            :std_ulogic_vector(0 to 7);
 signal  f_fpr_ex1_s_par            :std_ulogic_vector(0 to 7);
 signal  f_fpr_ex1_s_expo_extra     :std_Ulogic;
 signal  f_sto_ex2_s_parity_check   :std_ulogic;
 signal  f_mad_ex2_a_parity_check   :std_ulogic;
 signal  f_mad_ex2_c_parity_check   :std_ulogic;
 signal  f_mad_ex2_b_parity_check   :std_ulogic;

 signal     f_dcd_ex5_flush_int            :  std_ulogic_vector(0 to 3);
 signal  scan_dis_dc_b              :std_ulogic;
 signal  scan_diag_dc               :std_ulogic;

 signal    spare_unused                    :  std_ulogic_vector(0 to 5);

begin






    scan_dis_dc_b <= an_ac_scan_dis_dc_b;
    scan_diag_dc  <= an_ac_scan_diag_dc;

   prv: entity work.fuq_perv(fuq_perv)
   generic map( 
      expand_type                    => expand_type)
   port map(
      vdd                            => vdd                            ,
      gnd                            => gnd                            ,
      nclk                           => nclk                           ,
      pc_fu_sg_3                     => pc_fu_sg_3                     ,
      pc_fu_abst_sl_thold_3          => pc_fu_abst_sl_thold_3          ,
      pc_fu_func_sl_thold_3          => pc_fu_func_sl_thold_3          ,
      pc_fu_func_slp_sl_thold_3      => pc_fu_func_slp_sl_thold_3      ,
      pc_fu_gptr_sl_thold_3          => pc_fu_gptr_sl_thold_3          ,
      pc_fu_time_sl_thold_3          => pc_fu_time_sl_thold_3          ,
      pc_fu_ary_nsl_thold_3          => pc_fu_ary_nsl_thold_3          ,
      pc_fu_cfg_sl_thold_3           => pc_fu_cfg_sl_thold_3           ,
      pc_fu_repr_sl_thold_3          => pc_fu_repr_sl_thold_3          ,
      pc_fu_fce_3                    => pc_fu_fce_3                    ,
      tc_ac_ccflush_dc               => pc_fu_ccflush_dc               ,
      tc_ac_scan_diag_dc             => scan_diag_dc                   ,
      abst_sl_thold_1                => abst_sl_thold_1                ,
      func_sl_thold_1                => func_sl_thold_1                ,
      time_sl_thold_1                => time_sl_thold_1                ,
      ary_nsl_thold_1                => ary_nsl_thold_1                ,
      cfg_sl_thold_1                 => cfg_sl_thold_1                 ,
      func_slp_sl_thold_1            => func_slp_sl_thold_1            ,
      gptr_sl_thold_0                => gptr_sl_thold_0                ,
      fce_1                          => fce_1                          ,
      sg_1                           => sg_1                           ,
      clkoff_dc_b                    => clkoff_dc_b                    ,
      act_dis                        => act_dis                        ,
      delay_lclkr_dc                 => delay_lclkr_dc                 ,
      mpw1_dc_b                      => mpw1_dc_b                      ,
      mpw2_dc_b                      => mpw2_dc_b                      ,
      repr_scan_in                   => repr_scan_in                   ,
      repr_scan_out                  => repr_scan_out                  ,
      gptr_scan_in                   => gptr_scan_in                   ,
      gptr_scan_out                  => gptr_scan_io                  );


   fpr: entity work.fuq_fpr(fuq_fpr)
   generic map( 
      expand_type                    => expand_type)
   port map(
      nclk                           => nclk                           ,
      clkoff_b                       => clkoff_dc_b                    ,
      act_dis                        => act_dis                        ,
      flush                          => pc_fu_ccflush_dc               ,
      delay_lclkra(0 to 1)            => delay_lclkr_dc(0 to 1)         ,
      delay_lclkrb(6 to 7)            => delay_lclkr_dc(6 to 7)         ,
      mpw1_ba(0 to 1)                 => mpw1_dc_b(0 to 1)              ,
      mpw1_bb(6 to 7)                 => mpw1_dc_b(6 to 7)              ,
      mpw2_b                         => mpw2_dc_b                      ,
      sg_1                           => sg_1(1)                        ,
      abst_sl_thold_1                => abst_sl_thold_1                ,
      time_sl_thold_1                => time_sl_thold_1                ,
      ary_nsl_thold_1                => ary_nsl_thold_1                ,
      gptr_sl_thold_0                => gptr_sl_thold_0                ,
      fce_1                          => fce_1                          ,
      thold_1                        => func_sl_thold_1(1)             ,
      scan_dis_dc_b                  => scan_dis_dc_b                  ,   
      scan_diag_dc                   => scan_diag_dc                   ,
      lbist_en_dc                    => an_ac_lbist_en_dc              ,
      an_ac_abist_mode_dc            => an_ac_abist_mode_dc            ,
      an_ac_lbist_ary_wrt_thru_dc    => an_ac_lbist_ary_wrt_thru_dc    ,
      f_dcd_msr_fp_act               => f_dcd_msr_fp_act               ,

      bx_fu_rp_abst_scan_out         => bx_fu_rp_abst_scan_out         ,
      bx_rp_abst_scan_out            => bx_rp_abst_scan_out            ,
      rp_bx_abst_scan_in             => rp_bx_abst_scan_in             ,
      rp_fu_bx_abst_scan_in          => rp_fu_bx_abst_scan_in          ,
      rp_bx_func_scan_in             => rp_bx_func_scan_in             ,
      rp_fu_bx_func_scan_in          => rp_fu_bx_func_scan_in          ,
      bx_fu_rp_func_scan_out         => bx_fu_rp_func_scan_out         ,
      bx_rp_func_scan_out            => bx_rp_func_scan_out            ,

      pc_fu_bolt_sl_thold_3          => pc_fu_bolt_sl_thold_3          ,
      pc_fu_bo_enable_3              => pc_fu_bo_enable_3              ,
      pc_fu_bo_unload                => pc_fu_bo_unload                ,  
      pc_fu_bo_load                  => pc_fu_bo_load                  ,    
      pc_fu_bo_reset                 => pc_fu_bo_reset                 ,   
      pc_fu_bo_shdata                => pc_fu_bo_shdata                ,  
      pc_fu_bo_select                => pc_fu_bo_select                ,  
      fu_pc_bo_fail                  => fu_pc_bo_fail                  ,    
      fu_pc_bo_diagout               => fu_pc_bo_diagout               ,

      iu_fu_rf0_fra_v                => iu_fu_rf0_fra_v                ,
      iu_fu_rf0_frb_v                => iu_fu_rf0_frb_v                ,
      iu_fu_rf0_frc_v                => iu_fu_rf0_frc_v                ,
      iu_fu_rf0_str_v                => iu_fu_rf0_str_val              ,
      f_dcd_perr_sm_running          => f_dcd_perr_sm_running          ,

      f_fpr_si                       => f_fpr_si                       ,
      f_fpr_so                       => f_fpr_so                       ,
      f_fpr_ab_si                    => abst_scan_in                   ,
      f_fpr_ab_so                    => abst_scan_out                  ,
      time_scan_in                   => time_scan_in                   ,
      time_scan_out                  => time_scan_out                  ,
      gptr_scan_in                   => gptr_scan_io                   ,
      gptr_scan_out                  => gptr_scan_out                  ,
      vdd                            => vdd                            ,
      gnd                            => gnd                            ,
      pc_fu_abist_di_0               => pc_fu_abist_di_0               ,
      pc_fu_abist_di_1               => pc_fu_abist_di_1               ,
      pc_fu_abist_ena_dc             => pc_fu_abist_ena_dc             ,
      pc_fu_abist_grf_renb_0         => pc_fu_abist_grf_renb_0         ,
      pc_fu_abist_grf_renb_1         => pc_fu_abist_grf_renb_1         ,
      pc_fu_abist_grf_wenb_0         => pc_fu_abist_grf_wenb_0         ,
      pc_fu_abist_grf_wenb_1         => pc_fu_abist_grf_wenb_1         ,
      pc_fu_abist_raddr_0            => pc_fu_abist_raddr_0            ,
      pc_fu_abist_raddr_1            => pc_fu_abist_raddr_1            ,
      pc_fu_abist_raw_dc_b           => pc_fu_abist_raw_dc_b           ,
      pc_fu_abist_waddr_0            => pc_fu_abist_waddr_0            ,
      pc_fu_abist_waddr_1            => pc_fu_abist_waddr_1            ,
      pc_fu_abist_wl144_comp_ena     => pc_fu_abist_wl144_comp_ena     ,
      pc_fu_inj_regfile_parity       => pc_fu_inj_regfile_parity       ,
      f_dcd_rf0_tid                  => f_dcd_rf0_tid                  ,
      f_dcd_rf0_fra                  => f_dcd_rf0_fra                  , 
      f_dcd_rf0_frb                  => f_dcd_rf0_frb                  , 
      f_dcd_rf0_frc                  => f_dcd_rf0_frc                  ,
      iu_fu_rf0_ldst_tid             => iu_fu_rf0_ldst_tid             ,
      iu_fu_rf0_ldst_tag             => iu_fu_rf0_ldst_tag             ,
      f_dcd_rf0_bypsel_a_res1        => f_dcd_rf0_bypsel_a_res1        ,
      f_dcd_rf0_bypsel_a_load1       => f_dcd_rf0_bypsel_a_load1       ,
      f_dcd_rf0_bypsel_b_res1        => f_dcd_rf0_bypsel_b_res1        ,
      f_dcd_rf0_bypsel_b_load1       => f_dcd_rf0_bypsel_b_load1       ,
      f_dcd_rf0_bypsel_c_res1        => f_dcd_rf0_bypsel_c_res1        ,
      f_dcd_rf0_bypsel_c_load1       => f_dcd_rf0_bypsel_c_load1       ,
      f_dcd_rf0_bypsel_s_res1        => f_dcd_rf0_bypsel_s_res1        ,
      f_dcd_rf0_bypsel_s_load1       => f_dcd_rf0_bypsel_s_load1       ,
      f_dcd_ex6_frt_addr             => f_dcd_ex6_frt_addr             ,
      f_dcd_ex5_frt_tid              => f_dcd_ex5_frt_tid              ,
      f_dcd_ex6_frt_tid              => f_dcd_ex6_frt_tid              ,
      f_dcd_ex6_frt_wen              => f_dcd_ex6_frt_wen              ,
      f_rnd_ex6_res_expo             => f_rnd_ex6_res_expo             ,
      f_rnd_ex6_res_frac             => f_rnd_ex6_res_frac             ,
      f_rnd_ex6_res_sign             => f_rnd_ex6_res_sign             ,
      f_dcd_ex5_flush_int            => f_dcd_ex5_flush_int            ,       
      xu_fu_ex5_load_tag             => xu_fu_ex5_load_tag             ,
      xu_fu_ex5_load_val             => xu_fu_ex5_load_val             ,   
      xu_fu_ex6_load_data            => xu_fu_ex6_load_data            ,
      f_fpr_ex7_load_addr            => f_fpr_ex7_load_addr            ,
      f_fpr_ex7_load_v               => f_fpr_ex7_load_v               ,
      f_fpr_ex7_load_sign            => f_fpr_ex7_load_sign            ,
      f_fpr_ex7_load_expo            => f_fpr_ex7_load_expo            ,
      f_fpr_ex7_load_frac            => f_fpr_ex7_load_frac            ,
      f_fpr_rf1_s_sign               => f_fpr_rf1_s_sign               ,
      f_fpr_rf1_s_expo               => f_fpr_rf1_s_expo               ,
      f_fpr_rf1_s_frac               => f_fpr_rf1_s_frac               ,
      f_fpr_rf1_a_sign               => f_fpr_rf1_a_sign               ,
      f_fpr_rf1_a_expo               => f_fpr_rf1_a_expo               ,
      f_fpr_rf1_a_frac               => f_fpr_rf1_a_frac               ,
      f_fpr_rf1_c_sign               => f_fpr_rf1_c_sign               ,
      f_fpr_rf1_c_expo               => f_fpr_rf1_c_expo               ,
      f_fpr_rf1_c_frac               => f_fpr_rf1_c_frac               ,
      f_fpr_rf1_b_sign               => f_fpr_rf1_b_sign               ,
      f_fpr_rf1_b_expo               => f_fpr_rf1_b_expo               ,
      f_fpr_rf1_b_frac               => f_fpr_rf1_b_frac               ,
      f_fpr_ex1_s_expo_extra         => f_fpr_ex1_s_expo_extra         ,
      f_fpr_ex1_s_par                => f_fpr_ex1_s_par                ,
      f_fpr_ex1_a_par                => f_fpr_ex1_a_par                ,
      f_fpr_ex1_b_par                => f_fpr_ex1_b_par                ,
      f_fpr_ex1_c_par                => f_fpr_ex1_c_par                );



   sto: entity work.fuq_sto(fuq_sto)
   generic map( 
      expand_type                    => expand_type)
   port map(
      vdd                            => vdd                            ,
      gnd                            => gnd                            ,
      clkoff_b                       => clkoff_dc_b                    ,
      act_dis                        => act_dis                        ,
      flush                          => pc_fu_ccflush_dc               ,
      delay_lclkr                    => delay_lclkr_dc(1 to 2)         ,
      mpw1_b                         => mpw1_dc_b(1 to 2)              ,
      mpw2_b                         => mpw2_dc_b(0 to 0)              ,
      sg_1                           => sg_1(1)                        ,
      thold_1                        => func_sl_thold_1(1)             ,
      fpu_enable                     => fpu_enable                     ,
      nclk                           => nclk                           ,
      f_sto_si                       => f_sto_si                       ,
      f_sto_so                       => f_sto_so                       ,
      f_dcd_rf1_sto_act              => f_dcd_rf1_sto_act              ,

      f_fpr_ex1_s_expo_extra         => f_fpr_ex1_s_expo_extra         ,
      f_fpr_ex1_s_par                => f_fpr_ex1_s_par                ,
      f_sto_ex2_s_parity_check       => f_sto_ex2_s_parity_check       ,
      f_dcd_rf1_sto_dp               => f_dcd_rf1_sto_dp               ,
      f_dcd_rf1_sto_sp               => f_dcd_rf1_sto_sp               ,
      f_dcd_rf1_sto_wd               => f_dcd_rf1_sto_wd               ,
      f_byp_rf1_s_sign               => f_fpr_rf1_s_sign               ,
      f_byp_rf1_s_expo               => f_fpr_rf1_s_expo               ,
      f_byp_rf1_s_frac               => f_fpr_rf1_s_frac               ,
      f_sto_ex2_sto_data             => fu_xu_ex2_store_data           );




 
   fpu_enable   <= f_dcd_msr_fp_act;

   f_dcd_rf1_bypsel_a_res1   <= '0' ;
   f_dcd_rf1_bypsel_a_load1  <= '0' ;
   f_dcd_rf1_bypsel_b_res1   <= '0' ;
   f_dcd_rf1_bypsel_b_load1  <= '0' ;
   f_dcd_rf1_bypsel_c_res1   <= '0' ;
   f_dcd_rf1_bypsel_c_load1  <= '0' ;
   f_fpr_ex8_load_sign           <=  '0';
   f_fpr_ex8_load_expo(3 to 13)  <= (others => '0');
   f_fpr_ex8_load_frac(0 to 52)  <= (others => '0');

   f_fpr_ex7_frt_sign           <=  '0' ;
   f_fpr_ex7_frt_expo(1 to 13)  <=  (others => '0');
   f_fpr_ex7_frt_frac(0 to 52)  <=  (others => '0');


   mad: entity work.fuq_mad(fuq_mad)
   generic map( 
      expand_type                    => expand_type)
   port map(
      f_dcd_ex6_cancel               => f_dcd_ex6_cancel               ,
      f_dcd_rf1_bypsel_a_res0        => f_dcd_rf1_bypsel_a_res0        ,
      f_dcd_rf1_bypsel_a_res1        => f_dcd_rf1_bypsel_a_res1        ,
      f_dcd_rf1_bypsel_a_load0       => f_dcd_rf1_bypsel_a_load0       ,
      f_dcd_rf1_bypsel_a_load1       => f_dcd_rf1_bypsel_a_load1       ,
      f_dcd_rf1_bypsel_b_res0        => f_dcd_rf1_bypsel_b_res0        ,
      f_dcd_rf1_bypsel_b_res1        => f_dcd_rf1_bypsel_b_res1        ,
      f_dcd_rf1_bypsel_b_load0       => f_dcd_rf1_bypsel_b_load0       ,
      f_dcd_rf1_bypsel_b_load1       => f_dcd_rf1_bypsel_b_load1       ,
      f_dcd_rf1_bypsel_c_res0        => f_dcd_rf1_bypsel_c_res0        ,
      f_dcd_rf1_bypsel_c_res1        => f_dcd_rf1_bypsel_c_res1        ,
      f_dcd_rf1_bypsel_c_load0       => f_dcd_rf1_bypsel_c_load0       ,
      f_dcd_rf1_bypsel_c_load1       => f_dcd_rf1_bypsel_c_load1       ,
      f_dcd_rf1_force_excp_dis       => f_dcd_rf1_force_excp_dis       ,
      f_fpr_ex7_frt_sign             => f_fpr_ex7_frt_sign             ,
      f_fpr_ex7_frt_expo(1 to 13)    => f_fpr_ex7_frt_expo(1 to 13)    ,
      f_fpr_ex7_frt_frac(0 to 52)    => f_fpr_ex7_frt_frac(0 to 52)    ,
      f_fpr_ex7_load_sign            => f_fpr_ex8_load_sign            ,
      f_fpr_ex7_load_expo(3 to 13)   => f_fpr_ex8_load_expo(3 to 13)   ,
      f_fpr_ex7_load_frac(0 to 52)   => f_fpr_ex8_load_frac(0 to 52)   ,
      f_fpr_ex6_load_sign            => f_fpr_ex7_load_sign            ,
      f_fpr_ex6_load_expo            => f_fpr_ex7_load_expo            ,
      f_fpr_ex6_load_frac            => f_fpr_ex7_load_frac            ,
      f_fpr_rf1_a_sign               => f_fpr_rf1_a_sign               ,
      f_fpr_rf1_a_expo               => f_fpr_rf1_a_expo               ,
      f_fpr_rf1_a_frac               => f_fpr_rf1_a_frac               ,
      f_fpr_rf1_c_sign               => f_fpr_rf1_c_sign               ,
      f_fpr_rf1_c_expo               => f_fpr_rf1_c_expo               ,
      f_fpr_rf1_c_frac               => f_fpr_rf1_c_frac               ,
      f_fpr_rf1_b_sign               => f_fpr_rf1_b_sign               ,
      f_fpr_rf1_b_expo               => f_fpr_rf1_b_expo               ,
      f_fpr_rf1_b_frac               => f_fpr_rf1_b_frac               ,
      f_dcd_rf1_aop_valid            => f_dcd_rf1_aop_valid            ,
      f_dcd_rf1_cop_valid            => f_dcd_rf1_cop_valid            ,
      f_dcd_rf1_bop_valid            => f_dcd_rf1_bop_valid            ,
      f_dcd_rf1_sp                   => f_dcd_rf1_sp                   ,
      f_dcd_rf1_emin_dp              => f_dcd_rf1_emin_dp              ,
      f_dcd_rf1_emin_sp              => f_dcd_rf1_emin_sp              ,
      f_dcd_rf1_force_pass_b         => f_dcd_rf1_force_pass_b         ,
      f_dcd_rf1_fsel_b               => f_dcd_rf1_fsel_b               ,
      f_dcd_rf1_from_integer_b       => f_dcd_rf1_from_integer_b       ,
      f_dcd_rf1_to_integer_b         => f_dcd_rf1_to_integer_b         ,
      f_dcd_rf1_rnd_to_int_b         => f_dcd_rf1_rnd_to_int_b         ,
      f_dcd_rf1_math_b               => f_dcd_rf1_math_b               ,
      f_dcd_rf1_est_recip_b          => f_dcd_rf1_est_recip_b          ,
      f_dcd_rf1_est_rsqrt_b          => f_dcd_rf1_est_rsqrt_b          ,
      f_dcd_rf1_move_b               => f_dcd_rf1_move_b               ,
      f_dcd_rf1_prenorm_b            => f_dcd_rf1_prenorm_b            ,
      f_dcd_rf1_frsp_b               => f_dcd_rf1_frsp_b               ,
      f_dcd_rf1_compare_b            => f_dcd_rf1_compare_b            ,
      f_dcd_rf1_ordered_b            => f_dcd_rf1_ordered_b            ,
      f_dcd_rf1_nj_deni              => f_dcd_rf1_nj_deni              ,
      f_dcd_rf1_nj_deno              => f_dcd_rf1_nj_deno              ,
      f_dcd_rf1_sp_conv_b            => f_dcd_rf1_sp_conv_b            ,
      f_dcd_rf1_word_b               => f_dcd_rf1_word_b               ,
      f_dcd_rf1_uns_b                => f_dcd_rf1_uns_b                ,
      f_dcd_rf1_sub_op_b             => f_dcd_rf1_sub_op_b             ,
      f_dcd_rf1_op_rnd_v_b           => f_dcd_rf1_op_rnd_v_b           ,
      f_dcd_rf1_op_rnd_b             => f_dcd_rf1_op_rnd_b             ,
      f_dcd_rf1_inv_sign_b           => f_dcd_rf1_inv_sign_b           ,
      f_dcd_rf1_sign_ctl_b           => f_dcd_rf1_sign_ctl_b           ,
      f_dcd_rf1_sgncpy_b             => f_dcd_rf1_sgncpy_b             ,
      f_dcd_rf1_fpscr_bit_data_b     => f_dcd_rf1_fpscr_bit_data_b     ,
      f_dcd_rf1_fpscr_bit_mask_b     => f_dcd_rf1_fpscr_bit_mask_b     ,
      f_dcd_rf1_fpscr_nib_mask_b     => f_dcd_rf1_fpscr_nib_mask_b     ,
      f_dcd_rf1_mv_to_scr_b          => f_dcd_rf1_mv_to_scr_b          ,
      f_dcd_rf1_mv_from_scr_b        => f_dcd_rf1_mv_from_scr_b        ,
      f_dcd_rf1_mtfsbx_b             => f_dcd_rf1_mtfsbx_b             ,
      f_dcd_rf1_mcrfs_b              => f_dcd_rf1_mcrfs_b              ,
      f_dcd_rf1_mtfsf_b              => f_dcd_rf1_mtfsf_b              ,
      f_dcd_rf1_mtfsfi_b             => f_dcd_rf1_mtfsfi_b             ,
      f_dcd_rf1_log2e_b              => f_dcd_rf1_log2e_b              ,
      f_dcd_rf1_pow2e_b              => f_dcd_rf1_pow2e_b              ,
      f_dcd_rf1_ftdiv                => f_dcd_rf1_ftdiv                ,
      f_dcd_rf1_ftsqrt               => f_dcd_rf1_ftsqrt               ,
      f_dcd_ex1_perr_force_c         => f_dcd_ex1_perr_force_c         ,
      f_dcd_ex1_perr_fsel_ovrd       => f_dcd_ex1_perr_fsel_ovrd       ,
      f_add_ex4_fpcc_iu              => f_add_ex4_fpcc_iu              ,
      f_pic_ex5_fpr_wr_dis_b         => f_pic_ex5_fpr_wr_dis_b         ,
      f_scr_ex7_cr_fld               => f_scr_ex7_cr_fld               ,
      f_rnd_ex6_res_expo             => f_rnd_ex6_res_expo             ,
      f_rnd_ex6_res_frac             => f_rnd_ex6_res_frac             ,
      f_rnd_ex6_res_sign             => f_rnd_ex6_res_sign             ,
      f_ex2_b_den_flush              => f_ex2_b_den_flush              ,
      f_scr_ex7_fx_thread0           => f_scr_ex7_fx_thread0           ,
      f_scr_ex7_fx_thread1           => f_scr_ex7_fx_thread1           ,
      f_scr_ex7_fx_thread2           => f_scr_ex7_fx_thread2           ,
      f_scr_ex7_fx_thread3           => f_scr_ex7_fx_thread3           ,

      f_dcd_rf1_uc_ft_pos            => f_dcd_rf1_uc_ft_pos            ,
      f_dcd_rf1_uc_ft_neg            => f_dcd_rf1_uc_ft_neg            ,
      f_dcd_rf1_uc_fa_pos            => f_dcd_rf1_uc_fa_pos            ,
      f_dcd_rf1_uc_fc_pos            => f_dcd_rf1_uc_fc_pos            ,
      f_dcd_rf1_uc_fb_pos            => f_dcd_rf1_uc_fb_pos            ,
      f_dcd_rf1_uc_fc_hulp           => f_dcd_rf1_uc_fc_hulp           ,
      f_dcd_rf1_uc_fc_0_5            => f_dcd_rf1_uc_fc_0_5            ,
      f_dcd_rf1_uc_fc_1_0            => f_dcd_rf1_uc_fc_1_0            ,
      f_dcd_rf1_uc_fc_1_minus        => f_dcd_rf1_uc_fc_1_minus        ,
      f_dcd_rf1_uc_fb_1_0            => f_dcd_rf1_uc_fb_1_0            ,
      f_dcd_rf1_uc_fb_0_75           => f_dcd_rf1_uc_fb_0_75           ,
      f_dcd_rf1_uc_fb_0_5            => f_dcd_rf1_uc_fb_0_5            ,
      f_dcd_ex2_uc_inc_lsb           => f_dcd_ex2_uc_inc_lsb           ,
      f_dcd_ex2_uc_gs_v              => f_dcd_ex2_uc_gs_v              ,
      f_dcd_ex2_uc_gs                => f_dcd_ex2_uc_gs                ,
      f_dcd_rf1_div_beg              => f_dcd_rf1_div_beg              ,
      f_dcd_rf1_sqrt_beg             => f_dcd_rf1_sqrt_beg             ,
      f_dcd_rf1_uc_mid               => f_dcd_rf1_uc_mid                  ,
      f_dcd_rf1_uc_end               => f_dcd_rf1_uc_end                  ,
      f_dcd_rf1_uc_special           => f_dcd_rf1_uc_special              ,
      f_dcd_ex2_uc_vxsnan            => f_dcd_ex2_uc_vxsnan            , 
      f_dcd_ex2_uc_zx                => f_dcd_ex2_uc_zx                   ,
      f_dcd_ex2_uc_vxidi             => f_dcd_ex2_uc_vxidi                ,
      f_dcd_ex2_uc_vxzdz             => f_dcd_ex2_uc_vxzdz                ,
      f_dcd_ex2_uc_vxsqrt            => f_dcd_ex2_uc_vxsqrt               ,
      f_mad_ex6_uc_sign                 => f_mad_ex6_uc_sign                 ,
      f_mad_ex6_uc_zero                 => f_mad_ex6_uc_zero                 ,
      f_mad_ex3_uc_special              => f_mad_ex3_uc_special              ,
      f_mad_ex3_uc_vxsnan               => f_mad_ex3_uc_vxsnan            ,
      f_mad_ex3_uc_zx                   => f_mad_ex3_uc_zx                   ,
      f_mad_ex3_uc_vxsqrt               => f_mad_ex3_uc_vxsqrt               ,
      f_mad_ex3_uc_vxidi                => f_mad_ex3_uc_vxidi                ,
      f_mad_ex3_uc_vxzdz                => f_mad_ex3_uc_vxzdz                ,
      f_mad_ex3_uc_res_sign             => f_mad_ex3_uc_res_sign             ,
      f_mad_ex3_uc_round_mode(0 to 1)   => f_mad_ex3_uc_round_mode(0 to 1)   ,
      f_fpr_ex1_a_par                   => f_fpr_ex1_a_par                   ,
      f_fpr_ex1_b_par                   => f_fpr_ex1_b_par                   ,
      f_fpr_ex1_c_par                   => f_fpr_ex1_c_par                   ,
      f_mad_ex2_a_parity_check          => f_mad_ex2_a_parity_check ,
      f_mad_ex2_c_parity_check          => f_mad_ex2_c_parity_check ,
      f_mad_ex2_b_parity_check          => f_mad_ex2_b_parity_check ,

      rf1_thread_b                   => f_dcd_rf1_thread_b             ,
      vdd                            => vdd                            ,
      gnd                            => gnd                            ,
      scan_in                        => f_mad_si(0 to 17)              ,
      scan_out                       => f_mad_so(0 to 17)              ,
      clkoff_b                       => clkoff_dc_b                    ,
      act_dis                        => act_dis                        ,
      flush                          => pc_fu_ccflush_dc               ,
      delay_lclkr                    => delay_lclkr_dc(1 to 7)         ,
      mpw1_b                         => mpw1_dc_b(1 to 7)              ,
      mpw2_b                         => mpw2_dc_b                      ,
      sg_1                           => sg_1(0)                        ,
      thold_1                        => func_sl_thold_1(0)             ,
      fpu_enable                     => fpu_enable                     ,
      f_dcd_rf1_act                  => f_dcd_rf1_mad_act              ,
      nclk                           => nclk                           );





   dcd: entity work.fuq_dcd(fuq_dcd)
   generic map( 
      expand_type                    => expand_type                    ,
      eff_ifar                       => eff_ifar                       ,
      regmode                        => regmode                        )
   port map(
      nclk                           => nclk                           ,
      clkoff_b                       => clkoff_dc_b                    ,
      act_dis                        => act_dis                        ,
      flush                          => pc_fu_ccflush_dc               ,
      delay_lclkr                    => delay_lclkr_dc                 ,
      mpw1_b                         => mpw1_dc_b                      ,
      mpw2_b                         => mpw2_dc_b                      ,
      sg_1                           => sg_1(1)                        ,
      thold_1                        => func_sl_thold_1(1)             ,
      cfg_sl_thold_1                 => cfg_sl_thold_1                 ,
      func_slp_sl_thold_1            => func_slp_sl_thold_1            ,
      f_dcd_si                       => f_dcd_si                       ,
      f_dcd_so                       => f_dcd_so                       ,
      dcfg_scan_in                   => dcfg_scan_in                   ,
      dcfg_scan_out                  => dcfg_scan_out                  ,
      bcfg_scan_in                   => bcfg_scan_in                   ,
      bcfg_scan_out                  => bcfg_scan_out                  ,
      ccfg_scan_in                   => ccfg_scan_in                   ,
      ccfg_scan_out                  => ccfg_scan_out                  ,
      vdd                            => vdd                            ,
      gnd                            => gnd                            ,
      f_dcd_msr_fp_act               => f_dcd_msr_fp_act               ,
      fu_xu_rf1_act                  => fu_xu_rf1_act                  ,
      fu_xu_ex2_async_block          => fu_xu_ex2_async_block          ,
      iu_fu_rf0_instr_v              => iu_fu_rf0_instr_v              ,
      iu_fu_rf0_instr                => iu_fu_rf0_instr                ,
      iu_fu_rf0_fra_v                => iu_fu_rf0_fra_v                ,
      iu_fu_rf0_frb_v                => iu_fu_rf0_frb_v                ,
      iu_fu_rf0_frc_v                => iu_fu_rf0_frc_v                ,
      iu_fu_rf0_fra                  => iu_fu_rf0_fra                  ,
      iu_fu_rf0_frb                  => iu_fu_rf0_frb                  ,
      iu_fu_rf0_frc                  => iu_fu_rf0_frc                  ,
      iu_fu_rf0_tid                  => iu_fu_rf0_tid                  ,
      iu_fu_rf0_frt                  => iu_fu_rf0_frt                  ,
      iu_fu_rf0_ifar                 => iu_fu_rf0_ifar                 ,
      iu_fu_rf0_str_val              => iu_fu_rf0_str_val              ,
      iu_fu_rf0_ldst_val             => iu_fu_rf0_ldst_val             ,
      iu_fu_rf0_ldst_tid             => iu_fu_rf0_ldst_tid             ,
      iu_fu_rf0_ldst_tag             => iu_fu_rf0_ldst_tag             ,
      iu_fu_rf0_bypsel               => iu_fu_rf0_bypsel               ,
      iu_fu_rf0_instr_match          => iu_fu_rf0_instr_match          ,
      iu_fu_rf0_is_ucode             => iu_fu_rf0_is_ucode             ,
      iu_fu_rf0_ucfmul               => iu_fu_rf0_ucfmul               ,
      iu_fu_is2_tid_decode           => iu_fu_is2_tid_decode           ,
      iu_fu_ex2_n_flush              => iu_fu_ex2_n_flush              ,
      f_fpr_ex7_load_addr            => f_fpr_ex7_load_addr            ,
      f_fpr_ex7_load_v               => f_fpr_ex7_load_v               ,
      xu_is2_flush                   => xu_is2_flush                   ,
      xu_rf0_flush                   => xu_rf0_flush                   ,
      xu_rf1_flush                   => xu_rf1_flush                   ,
      xu_ex1_flush                   => xu_ex1_flush                   ,
      xu_ex2_flush                   => xu_ex2_flush                   ,
      xu_ex3_flush                   => xu_ex3_flush                   ,
      xu_ex4_flush                   => xu_ex4_flush                   ,
      xu_ex5_flush                   => xu_ex5_flush                   ,
      f_dcd_ex5_flush_int            => f_dcd_ex5_flush_int            ,        
      xu_fu_ex5_reload_val           => xu_fu_ex5_reload_val           ,
      xu_fu_ex5_load_val             => xu_fu_ex5_load_val             ,
      f_ex2_b_den_flush              => f_ex2_b_den_flush              ,
      f_scr_ex7_fx_thread0           => f_scr_ex7_fx_thread0           ,
      f_scr_ex7_fx_thread1           => f_scr_ex7_fx_thread1           ,
      f_scr_ex7_fx_thread2           => f_scr_ex7_fx_thread2           ,
      f_scr_ex7_fx_thread3           => f_scr_ex7_fx_thread3           ,
      f_dcd_ex1_perr_force_c         => f_dcd_ex1_perr_force_c         ,
      f_dcd_ex1_perr_fsel_ovrd       => f_dcd_ex1_perr_fsel_ovrd       ,
      f_dcd_perr_sm_running          => f_dcd_perr_sm_running          ,
      f_add_ex4_fpcc_iu              => f_add_ex4_fpcc_iu              ,
      f_pic_ex5_fpr_wr_dis_b         => f_pic_ex5_fpr_wr_dis_b         ,
      f_scr_ex7_cr_fld               => f_scr_ex7_cr_fld               ,
      f_dcd_rf1_aop_valid            => f_dcd_rf1_aop_valid            ,
      f_dcd_rf1_cop_valid            => f_dcd_rf1_cop_valid            ,
      f_dcd_rf1_bop_valid            => f_dcd_rf1_bop_valid            ,
      f_dcd_rf1_sp                   => f_dcd_rf1_sp                   ,
      f_dcd_rf1_emin_dp              => f_dcd_rf1_emin_dp              ,
      f_dcd_rf1_emin_sp              => f_dcd_rf1_emin_sp              ,
      f_dcd_rf1_force_pass_b         => f_dcd_rf1_force_pass_b         ,
      f_dcd_rf1_fsel_b               => f_dcd_rf1_fsel_b               ,
      f_dcd_rf1_from_integer_b       => f_dcd_rf1_from_integer_b       ,
      f_dcd_rf1_to_integer_b         => f_dcd_rf1_to_integer_b         ,
      f_dcd_rf1_rnd_to_int_b         => f_dcd_rf1_rnd_to_int_b         ,
      f_dcd_rf1_math_b               => f_dcd_rf1_math_b               ,
      f_dcd_rf1_est_recip_b          => f_dcd_rf1_est_recip_b          ,
      f_dcd_rf1_est_rsqrt_b          => f_dcd_rf1_est_rsqrt_b          ,
      f_dcd_rf1_move_b               => f_dcd_rf1_move_b               ,
      f_dcd_rf1_prenorm_b            => f_dcd_rf1_prenorm_b            ,
      f_dcd_rf1_frsp_b               => f_dcd_rf1_frsp_b               ,
      f_dcd_rf1_compare_b            => f_dcd_rf1_compare_b            ,
      f_dcd_rf1_ordered_b            => f_dcd_rf1_ordered_b            ,
      f_dcd_rf1_force_excp_dis       => f_dcd_rf1_force_excp_dis       ,
      f_dcd_rf1_nj_deni              => f_dcd_rf1_nj_deni              ,
      f_dcd_rf1_nj_deno              => f_dcd_rf1_nj_deno              ,
      f_dcd_rf1_sp_conv_b            => f_dcd_rf1_sp_conv_b            ,
      f_dcd_rf1_uns_b                => f_dcd_rf1_uns_b                ,
      f_dcd_rf1_word_b               => f_dcd_rf1_word_b               ,
      f_dcd_rf1_sub_op_b             => f_dcd_rf1_sub_op_b             ,
      f_dcd_rf1_op_rnd_v_b           => f_dcd_rf1_op_rnd_v_b           ,
      f_dcd_rf1_op_rnd_b             => f_dcd_rf1_op_rnd_b             ,
      f_dcd_rf1_inv_sign_b           => f_dcd_rf1_inv_sign_b           ,
      f_dcd_rf1_sign_ctl_b           => f_dcd_rf1_sign_ctl_b           ,
      f_dcd_rf1_sgncpy_b             => f_dcd_rf1_sgncpy_b             ,
      f_dcd_rf1_fpscr_bit_data_b     => f_dcd_rf1_fpscr_bit_data_b     ,
      f_dcd_rf1_fpscr_bit_mask_b     => f_dcd_rf1_fpscr_bit_mask_b     ,
      f_dcd_rf1_fpscr_nib_mask_b     => f_dcd_rf1_fpscr_nib_mask_b     ,
      f_dcd_rf1_mv_to_scr_b          => f_dcd_rf1_mv_to_scr_b          ,
      f_dcd_rf1_mv_from_scr_b        => f_dcd_rf1_mv_from_scr_b        ,
      f_dcd_rf1_mtfsbx_b             => f_dcd_rf1_mtfsbx_b             ,
      f_dcd_rf1_mcrfs_b              => f_dcd_rf1_mcrfs_b              ,
      f_dcd_rf1_mtfsf_b              => f_dcd_rf1_mtfsf_b              ,
      f_dcd_rf1_mtfsfi_b             => f_dcd_rf1_mtfsfi_b             ,
      f_dcd_rf1_thread_b             => f_dcd_rf1_thread_b             ,
      f_dcd_rf1_sto_dp               => f_dcd_rf1_sto_dp               ,
      f_dcd_rf1_sto_sp               => f_dcd_rf1_sto_sp               ,
      f_dcd_rf1_sto_wd               => f_dcd_rf1_sto_wd               ,
      f_dcd_rf1_log2e_b              => f_dcd_rf1_log2e_b              ,
      f_dcd_rf1_pow2e_b              => f_dcd_rf1_pow2e_b              ,
      f_dcd_rf1_ftdiv                => f_dcd_rf1_ftdiv                ,
      f_dcd_rf1_ftsqrt               => f_dcd_rf1_ftsqrt               ,
      f_dcd_ex6_cancel               => f_dcd_ex6_cancel               ,
      f_dcd_rf1_mad_act              => f_dcd_rf1_mad_act              ,
      f_dcd_rf1_sto_act              => f_dcd_rf1_sto_act              ,
      f_dcd_rf1_bypsel_a_res0        => f_dcd_rf1_bypsel_a_res0        ,
      f_dcd_rf1_bypsel_a_load0       => f_dcd_rf1_bypsel_a_load0       ,
      f_dcd_rf1_bypsel_b_res0        => f_dcd_rf1_bypsel_b_res0        ,
      f_dcd_rf1_bypsel_b_load0       => f_dcd_rf1_bypsel_b_load0       ,
      f_dcd_rf1_bypsel_c_res0        => f_dcd_rf1_bypsel_c_res0        ,
      f_dcd_rf1_bypsel_c_load0       => f_dcd_rf1_bypsel_c_load0       ,
      f_dcd_rf0_bypsel_a_res1        => f_dcd_rf0_bypsel_a_res1        ,
      f_dcd_rf0_bypsel_a_load1       => f_dcd_rf0_bypsel_a_load1       ,
      f_dcd_rf0_bypsel_b_res1        => f_dcd_rf0_bypsel_b_res1        ,
      f_dcd_rf0_bypsel_b_load1       => f_dcd_rf0_bypsel_b_load1       ,
      f_dcd_rf0_bypsel_c_res1        => f_dcd_rf0_bypsel_c_res1        ,
      f_dcd_rf0_bypsel_c_load1       => f_dcd_rf0_bypsel_c_load1       ,
      f_dcd_rf0_bypsel_s_res1        => f_dcd_rf0_bypsel_s_res1        ,
      f_dcd_rf0_bypsel_s_load1       => f_dcd_rf0_bypsel_s_load1       ,
      f_dcd_rf0_tid                  => f_dcd_rf0_tid                  ,
      f_dcd_rf0_fra                  => f_dcd_rf0_fra                  ,
      f_dcd_rf0_frb                  => f_dcd_rf0_frb                  ,
      f_dcd_rf0_frc                  => f_dcd_rf0_frc                  ,
      f_dcd_rf1_div_beg              => f_dcd_rf1_div_beg              ,
      f_dcd_rf1_sqrt_beg             => f_dcd_rf1_sqrt_beg             ,
      f_dcd_rf1_uc_ft_pos            => f_dcd_rf1_uc_ft_pos            ,
      f_dcd_rf1_uc_ft_neg            => f_dcd_rf1_uc_ft_neg            ,
      f_dcd_rf1_uc_fa_pos            => f_dcd_rf1_uc_fa_pos            ,
      f_dcd_rf1_uc_fc_pos            => f_dcd_rf1_uc_fc_pos            ,
      f_dcd_rf1_uc_fb_pos            => f_dcd_rf1_uc_fb_pos            ,
      f_dcd_rf1_uc_fc_hulp           => f_dcd_rf1_uc_fc_hulp           ,
      f_dcd_rf1_uc_fc_0_5            => f_dcd_rf1_uc_fc_0_5            ,
      f_dcd_rf1_uc_fc_1_0            => f_dcd_rf1_uc_fc_1_0            ,
      f_dcd_rf1_uc_fc_1_minus        => f_dcd_rf1_uc_fc_1_minus        ,
      f_dcd_rf1_uc_fb_1_0            => f_dcd_rf1_uc_fb_1_0            ,
      f_dcd_rf1_uc_fb_0_75           => f_dcd_rf1_uc_fb_0_75           ,
      f_dcd_rf1_uc_fb_0_5            => f_dcd_rf1_uc_fb_0_5            ,
      f_dcd_ex2_uc_inc_lsb           => f_dcd_ex2_uc_inc_lsb           ,
      f_dcd_rf1_uc_mid               => f_dcd_rf1_uc_mid               ,
      f_dcd_rf1_uc_end               => f_dcd_rf1_uc_end               ,
      fu_iu_uc_special               => fu_iu_uc_special               ,
      f_dcd_rf1_uc_special           => f_dcd_rf1_uc_special           ,
      f_dcd_ex2_uc_gs_v              => f_dcd_ex2_uc_gs_v              ,
      f_dcd_ex2_uc_gs                => f_dcd_ex2_uc_gs                ,
      f_dcd_ex2_uc_vxsnan            => f_dcd_ex2_uc_vxsnan            , 
      f_dcd_ex2_uc_zx                => f_dcd_ex2_uc_zx                ,
      f_dcd_ex2_uc_vxidi             => f_dcd_ex2_uc_vxidi             ,
      f_dcd_ex2_uc_vxzdz             => f_dcd_ex2_uc_vxzdz             ,
      f_dcd_ex2_uc_vxsqrt            => f_dcd_ex2_uc_vxsqrt            ,
      f_mad_ex6_uc_sign              => f_mad_ex6_uc_sign              ,
      f_mad_ex6_uc_zero              => f_mad_ex6_uc_zero              ,
      f_mad_ex3_uc_special           => f_mad_ex3_uc_special           ,
      f_mad_ex3_uc_vxsnan            => f_mad_ex3_uc_vxsnan            ,
      f_mad_ex3_uc_zx                => f_mad_ex3_uc_zx                ,
      f_mad_ex3_uc_vxidi             => f_mad_ex3_uc_vxidi             ,
      f_mad_ex3_uc_vxzdz             => f_mad_ex3_uc_vxzdz             ,
      f_mad_ex3_uc_vxsqrt            => f_mad_ex3_uc_vxsqrt            ,
      f_mad_ex3_uc_res_sign          => f_mad_ex3_uc_res_sign          ,
      f_mad_ex3_uc_round_mode        => f_mad_ex3_uc_round_mode        ,
      slowspr_val_in                 => slowspr_val_in                 ,
      slowspr_rw_in                  => slowspr_rw_in                  ,
      slowspr_etid_in                => slowspr_etid_in                ,
      slowspr_addr_in                => slowspr_addr_in                ,
      slowspr_data_in                => slowspr_data_in                ,
      slowspr_done_in                => slowspr_done_in                ,
      slowspr_val_out                => slowspr_val_out                ,
      slowspr_rw_out                 => slowspr_rw_out                 ,
      slowspr_etid_out               => slowspr_etid_out               ,
      slowspr_addr_out               => slowspr_addr_out               ,
      slowspr_data_out               => slowspr_data_out               ,
      slowspr_done_out               => slowspr_done_out               ,
      pc_fu_trace_bus_enable         => pc_fu_trace_bus_enable         ,
      pc_fu_event_bus_enable         => pc_fu_event_bus_enable         ,
      pc_fu_debug_mux_ctrls          => pc_fu_debug_mux_ctrls          ,
      pc_fu_event_count_mode         => pc_fu_event_count_mode         ,
      pc_fu_event_mux_ctrls          => pc_fu_event_mux_ctrls          ,
      debug_data_in                  => debug_data_in                  ,
      debug_data_out                 => debug_data_out                 ,
      trace_triggers_in              => trace_triggers_in              ,
      trace_triggers_out             => trace_triggers_out             ,
      fu_pc_event_data               => fu_pc_event_data               ,

      xu_fu_msr_fp                   => xu_fu_msr_fp                   ,
      xu_fu_msr_pr                   => xu_fu_msr_pr                   ,
      xu_fu_msr_gs                   => xu_fu_msr_gs                   ,
      pc_fu_instr_trace_mode         => pc_fu_instr_trace_mode         ,
      pc_fu_instr_trace_tid          => pc_fu_instr_trace_tid          ,

      f_rnd_ex6_res_expo             => f_rnd_ex6_res_expo             ,
      f_rnd_ex6_res_frac             => f_rnd_ex6_res_frac             ,
      f_rnd_ex6_res_sign             => f_rnd_ex6_res_sign             ,
      pc_fu_ram_mode                 => pc_fu_ram_mode                 ,
      pc_fu_ram_thread               => pc_fu_ram_thread               ,
      fu_pc_ram_done                 => fu_pc_ram_done                 ,
      fu_pc_ram_data                 => fu_pc_ram_data                 ,
      f_sto_ex2_s_parity_check       => f_sto_ex2_s_parity_check       ,
      f_mad_ex2_a_parity_check       => f_mad_ex2_a_parity_check       ,
      f_mad_ex2_b_parity_check       => f_mad_ex2_b_parity_check       ,
      f_mad_ex2_c_parity_check       => f_mad_ex2_c_parity_check       ,
      fu_pc_err_regfile_parity       => fu_pc_err_regfile_parity       ,
      fu_pc_err_regfile_ue           => fu_pc_err_regfile_ue           ,
      fu_xu_ex3_regfile_err_det      => fu_xu_ex3_regfile_err_det      ,
      xu_fu_regfile_seq_beg          => xu_fu_regfile_seq_beg          ,
      fu_xu_regfile_seq_end          => fu_xu_regfile_seq_end          ,
      f_dcd_ex6_frt_addr             => f_dcd_ex6_frt_addr             ,
      f_dcd_ex5_frt_tid              => f_dcd_ex5_frt_tid              ,
      f_dcd_ex6_frt_tid              => f_dcd_ex6_frt_tid              ,
      f_dcd_ex6_frt_wen              => f_dcd_ex6_frt_wen              ,
      fu_xu_ex2_store_data_val       => fu_xu_ex2_store_data_val       ,
      fu_xu_ex4_cr                   => fu_xu_ex4_cr                   ,
      fu_xu_ex4_cr_val               => fu_xu_ex4_cr_val               ,
      fu_xu_ex4_cr_bf                => fu_xu_ex4_cr_bf                ,
      fu_xu_ex4_cr_noflush           => fu_xu_ex4_cr_noflush           ,
      xu_fu_ex3_eff_addr             => xu_fu_ex3_eff_addr             ,
      fu_xu_ex3_n_flush              => fu_xu_ex3_n_flush              ,
      fu_xu_ex3_np1_flush            => fu_xu_ex3_np1_flush            ,
      fu_xu_ex3_ap_int_req           => fu_xu_ex3_ap_int_req           ,
      fu_xu_ex3_flush2ucode          => fu_xu_ex3_flush2ucode          ,
      fu_xu_ex2_instr_type           => fu_xu_ex2_instr_type           ,
      fu_xu_ex2_instr_match          => fu_xu_ex2_instr_match          ,
      fu_xu_ex2_is_ucode             => fu_xu_ex2_is_ucode             ,
      fu_xu_ex3_trap                 => fu_xu_ex3_trap                 ,
      fu_xu_ex2_ifar_val             => fu_xu_ex2_ifar_val             ,
      fu_xu_ex2_ifar_issued          => fu_xu_ex2_ifar_issued          ,
      fu_xu_ex1_ifar                 => fu_xu_ex1_ifar                 );



   spare_unused(0)      <= pc_fu_abst_slp_sl_thold_3;
   spare_unused(1)      <= pc_fu_cfg_slp_sl_thold_3;
   spare_unused(2)      <= pc_fu_func_nsl_thold_3;
   spare_unused(3)      <= pc_fu_func_slp_nsl_thold_3;
   spare_unused(4)      <= pc_fu_ary_slp_nsl_thold_3;
   spare_unused(5)      <= xu_fu_ex5_load_le;
      



   f_fpr_si     <= func_scan_in(0);
   f_sto_si     <= f_fpr_so;
   f_dcd_si     <= f_sto_so;
   func_scan_out(0) <= scan_dis_dc_b and f_dcd_so;


   f_mad_si(0)            <= func_scan_in(1);
   f_mad_si(1)            <= f_mad_so(0);
   f_mad_si(2)            <= f_mad_so(1);
   f_mad_si(3)            <= f_mad_so(2);
   f_mad_si(4)            <= f_mad_so(3);
   f_mad_si(5)            <= f_mad_so(4);
   func_scan_out(1) <= scan_dis_dc_b and f_mad_so(5);

   f_mad_si(6)            <= func_scan_in(2);  
   f_mad_si(7)            <= f_mad_so(6);
   f_mad_si(8)            <= f_mad_so(7);
   f_mad_si(9)            <= f_mad_so(8);
   f_mad_si(10)           <= f_mad_so(9);
   f_mad_si(11)           <= f_mad_so(10);
   func_scan_out(2) <= scan_dis_dc_b and f_mad_so(11); 

   f_mad_si(12)           <= func_scan_in(3); 
   f_mad_si(13)           <= f_mad_so(12);
   f_mad_si(14)           <= f_mad_so(13);
   f_mad_si(15)           <= f_mad_so(14);
   f_mad_si(16)           <= f_mad_so(15);
   f_mad_si(17)           <= f_mad_so(16);
   func_scan_out(3) <= scan_dis_dc_b and f_mad_so(17);

   
   	 bx_pc_err_inbox_ue_ofu	                <=  bx_pc_err_inbox_ue_ifu             ;
	 bx_pc_err_outbox_ue_ofu	            <=  bx_pc_err_outbox_ue_ifu            ;
	 bx_pc_err_inbox_ecc_ofu	            <=  bx_pc_err_inbox_ecc_ifu            ;
	 bx_pc_err_outbox_ecc_ofu	            <=  bx_pc_err_outbox_ecc_ifu           ;
	 pc_bx_bolt_sl_thold_3_ofu	            <=  pc_bx_bolt_sl_thold_3_ifu          ;
	 pc_bx_bo_enable_3_ofu		            <=  pc_bx_bo_enable_3_ifu              ;
	 pc_bx_bo_unload_ofu	 	            <=  pc_bx_bo_unload_ifu                ;
	 pc_bx_bo_repair_ofu	 	            <=  pc_bx_bo_repair_ifu                ;
	 pc_bx_bo_reset_ofu	  	                <=  pc_bx_bo_reset_ifu                 ;
	 pc_bx_bo_shdata_ofu	 	            <=  pc_bx_bo_shdata_ifu                ;
	 pc_bx_bo_select_ofu	 	            <=  pc_bx_bo_select_ifu                ;
	 bx_pc_bo_fail_ofu			            <=  bx_pc_bo_fail_ifu                  ;
	 bx_pc_bo_diagout_ofu		            <=  bx_pc_bo_diagout_ifu               ;
	 pc_bx_abist_di_0_ofu		            <=  pc_bx_abist_di_0_ifu               ;
	 pc_bx_abist_ena_dc_ofu	                <=  pc_bx_abist_ena_dc_ifu             ;
	 pc_bx_abist_g8t1p_renb_0_ofu	        <=  pc_bx_abist_g8t1p_renb_0_ifu       ;
	 pc_bx_abist_g8t_bw_0_ofu		        <=  pc_bx_abist_g8t_bw_0_ifu           ;
	 pc_bx_abist_g8t_bw_1_ofu		        <=  pc_bx_abist_g8t_bw_1_ifu           ;
	 pc_bx_abist_g8t_dcomp_ofu		        <=  pc_bx_abist_g8t_dcomp_ifu          ;
	 pc_bx_abist_g8t_wenb_ofu		        <=  pc_bx_abist_g8t_wenb_ifu           ;
	 pc_bx_abist_raddr_0_ofu		        <=  pc_bx_abist_raddr_0_ifu            ;
	 pc_bx_abist_raw_dc_b_ofu		        <=  pc_bx_abist_raw_dc_b_ifu           ;
	 pc_bx_abist_waddr_0_ofu		        <=  pc_bx_abist_waddr_0_ifu            ;
	 pc_bx_abist_wl64_comp_ena_ofu	        <=  pc_bx_abist_wl64_comp_ena_ifu      ;
	 pc_bx_trace_bus_enable_ofu	            <=  pc_bx_trace_bus_enable_ifu         ;
	 pc_bx_debug_mux1_ctrls_ofu	            <=  pc_bx_debug_mux1_ctrls_ifu         ;
	 pc_bx_inj_inbox_ecc_ofu		        <=  pc_bx_inj_inbox_ecc_ifu            ;
	 pc_bx_inj_outbox_ecc_ofu		        <=  pc_bx_inj_outbox_ecc_ifu           ;
	 pc_bx_ccflush_dc_ofu		            <=  pc_bx_ccflush_dc_ifu               ;
	 pc_bx_sg_3_ofu			                <=  pc_bx_sg_3_ifu                     ;
	 pc_bx_func_sl_thold_3_ofu		        <=  pc_bx_func_sl_thold_3_ifu          ;
	 pc_bx_func_slp_sl_thold_3_ofu	        <=  pc_bx_func_slp_sl_thold_3_ifu      ;
	 pc_bx_gptr_sl_thold_3_ofu		        <=  pc_bx_gptr_sl_thold_3_ifu          ;
	 pc_bx_time_sl_thold_3_ofu		        <=  pc_bx_time_sl_thold_3_ifu          ;
	 pc_bx_repr_sl_thold_3_ofu		        <=  pc_bx_repr_sl_thold_3_ifu          ;
	 pc_bx_abst_sl_thold_3_ofu		        <=  pc_bx_abst_sl_thold_3_ifu          ;
	 pc_bx_ary_nsl_thold_3_ofu		        <=  pc_bx_ary_nsl_thold_3_ifu          ;
	 pc_bx_ary_slp_nsl_thold_3_ofu	        <=  pc_bx_ary_slp_nsl_thold_3_ifu      ;
     
	 xu_pc_err_mcsr_summary_ofu             <=  xu_pc_err_mcsr_summary_ifu         ;
     xu_pc_err_ierat_parity_ofu             <=  xu_pc_err_ierat_parity_ifu         ;
     xu_pc_err_derat_parity_ofu             <=  xu_pc_err_derat_parity_ifu         ;
     xu_pc_err_tlb_parity_ofu               <=  xu_pc_err_tlb_parity_ifu           ;
     xu_pc_err_tlb_lru_parity_ofu           <=  xu_pc_err_tlb_lru_parity_ifu       ;
     xu_pc_err_ierat_multihit_ofu           <=  xu_pc_err_ierat_multihit_ifu       ;
     xu_pc_err_derat_multihit_ofu           <=  xu_pc_err_derat_multihit_ifu       ;
     xu_pc_err_tlb_multihit_ofu             <=  xu_pc_err_tlb_multihit_ifu         ;
     xu_pc_err_ext_mchk_ofu                 <=  xu_pc_err_ext_mchk_ifu             ;
     xu_pc_err_mchk_disabled_ofu            <=  xu_pc_err_mchk_disabled_ifu        ;
     xu_pc_err_ditc_overrun_ofu             <=  xu_pc_err_ditc_overrun_ifu         ;
     xu_pc_err_local_snoop_reject_ofu       <=  xu_pc_err_local_snoop_reject_ifu   ;
     xu_pc_err_attention_instr_ofu          <=  xu_pc_err_attention_instr_ifu      ;
     xu_pc_err_dcache_parity_ofu            <=  xu_pc_err_dcache_parity_ifu        ;
     xu_pc_err_dcachedir_parity_ofu         <=  xu_pc_err_dcachedir_parity_ifu     ;
     xu_pc_err_dcachedir_multihit_ofu       <=  xu_pc_err_dcachedir_multihit_ifu   ;
     xu_pc_err_debug_event_ofu              <=  xu_pc_err_debug_event_ifu          ;
     xu_pc_err_invld_reld_ofu               <=  xu_pc_err_invld_reld_ifu           ;
     xu_pc_err_l2intrf_ecc_ofu              <=  xu_pc_err_l2intrf_ecc_ifu          ;
     xu_pc_err_l2intrf_ue_ofu               <=  xu_pc_err_l2intrf_ue_ifu           ;
     xu_pc_err_l2credit_overrun_ofu         <=  xu_pc_err_l2credit_overrun_ifu     ;
     xu_pc_err_llbust_attempt_ofu           <=  xu_pc_err_llbust_attempt_ifu       ;
     xu_pc_err_llbust_failed_ofu            <=  xu_pc_err_llbust_failed_ifu        ;
     xu_pc_err_nia_miscmpr_ofu              <=  xu_pc_err_nia_miscmpr_ifu          ;
     xu_pc_err_regfile_parity_ofu           <=  xu_pc_err_regfile_parity_ifu       ;
     xu_pc_err_regfile_ue_ofu               <=  xu_pc_err_regfile_ue_ifu           ;
     xu_pc_err_sprg_ecc_ofu                 <=  xu_pc_err_sprg_ecc_ifu             ;
     xu_pc_err_sprg_ue_ofu                  <=  xu_pc_err_sprg_ue_ifu              ;
     xu_pc_err_wdt_reset_ofu                <=  xu_pc_err_wdt_reset_ifu            ;
     xu_pc_event_data_ofu                   <=  xu_pc_event_data_ifu               ;
     xu_pc_ram_data_ofu                     <=  xu_pc_ram_data_ifu                 ;
     xu_pc_ram_done_ofu                     <=  xu_pc_ram_done_ifu                 ;
     xu_pc_ram_interrupt_ofu                <=  xu_pc_ram_interrupt_ifu            ;
     xu_pc_running_ofu                      <=  xu_pc_running_ifu                  ;
     xu_pc_spr_ccr0_pme_ofu                 <=  xu_pc_spr_ccr0_pme_ifu             ;
     xu_pc_spr_ccr0_we_ofu                  <=  xu_pc_spr_ccr0_we_ifu              ;
     xu_pc_step_done_ofu                    <=  xu_pc_step_done_ifu                ;
     xu_pc_stop_dbg_event_ofu               <=  xu_pc_stop_dbg_event_ifu           ;
     xu_pc_lsu_event_data_ofu               <=  xu_pc_lsu_event_data_ifu           ;
     pc_xu_bolt_sl_thold_3_ofu              <=  pc_xu_bolt_sl_thold_3_ifu          ;
     pc_xu_bo_enable_3_ofu                  <=  pc_xu_bo_enable_3_ifu              ;
     pc_xu_bo_unload_ofu                    <=  pc_xu_bo_unload_ifu                ;
     pc_xu_bo_load_ofu                      <=  pc_xu_bo_load_ifu                  ;
     pc_xu_bo_repair_ofu                    <=  pc_xu_bo_repair_ifu                ;
     pc_xu_bo_reset_ofu                     <=  pc_xu_bo_reset_ifu                 ;
     pc_xu_bo_shdata_ofu                    <=  pc_xu_bo_shdata_ifu                ;
     pc_xu_bo_select_ofu                    <=  pc_xu_bo_select_ifu                ;
     xu_pc_bo_fail_ofu                      <=  xu_pc_bo_fail_ifu                  ;
     xu_pc_bo_diagout_ofu                   <=  xu_pc_bo_diagout_ifu               ;
     pc_xu_abist_dcomp_g6t_2r_ofu           <=  pc_xu_abist_dcomp_g6t_2r_ifu       ;
     pc_xu_abist_di_0_ofu                   <=  pc_xu_abist_di_0_ifu               ;
     pc_xu_abist_di_1_ofu                   <=  pc_xu_abist_di_1_ifu               ;
     pc_xu_abist_di_g6t_2r_ofu              <=  pc_xu_abist_di_g6t_2r_ifu          ;
     pc_xu_abist_ena_dc_ofu                 <=  pc_xu_abist_ena_dc_ifu             ;
     pc_xu_abist_g6t_bw_ofu                 <=  pc_xu_abist_g6t_bw_ifu             ;
     pc_xu_abist_g6t_r_wb_ofu               <=  pc_xu_abist_g6t_r_wb_ifu           ;
     pc_xu_abist_g8t1p_renb_0_ofu           <=  pc_xu_abist_g8t1p_renb_0_ifu       ;
     pc_xu_abist_g8t_bw_0_ofu               <=  pc_xu_abist_g8t_bw_0_ifu           ;
     pc_xu_abist_g8t_bw_1_ofu               <=  pc_xu_abist_g8t_bw_1_ifu           ;
     pc_xu_abist_g8t_dcomp_ofu              <=  pc_xu_abist_g8t_dcomp_ifu          ;
     pc_xu_abist_g8t_wenb_ofu               <=  pc_xu_abist_g8t_wenb_ifu           ;
     pc_xu_abist_grf_renb_0_ofu             <=  pc_xu_abist_grf_renb_0_ifu         ;
     pc_xu_abist_grf_renb_1_ofu             <=  pc_xu_abist_grf_renb_1_ifu         ;
     pc_xu_abist_grf_wenb_0_ofu             <=  pc_xu_abist_grf_wenb_0_ifu         ;
     pc_xu_abist_grf_wenb_1_ofu             <=  pc_xu_abist_grf_wenb_1_ifu         ;
     pc_xu_abist_raddr_0_ofu                <=  pc_xu_abist_raddr_0_ifu            ;
     pc_xu_abist_raddr_1_ofu                <=  pc_xu_abist_raddr_1_ifu            ;
     pc_xu_abist_raw_dc_b_ofu               <=  pc_xu_abist_raw_dc_b_ifu           ;
     pc_xu_abist_waddr_0_ofu                <=  pc_xu_abist_waddr_0_ifu            ;
     pc_xu_abist_waddr_1_ofu                <=  pc_xu_abist_waddr_1_ifu            ;
     pc_xu_abist_wl144_comp_ena_ofu         <=  pc_xu_abist_wl144_comp_ena_ifu     ;
     pc_xu_abist_wl32_comp_ena_ofu          <=  pc_xu_abist_wl32_comp_ena_ifu      ;
     pc_xu_abist_wl512_comp_ena_ofu         <=  pc_xu_abist_wl512_comp_ena_ifu     ;
     pc_xu_event_mux_ctrls_ofu              <=  pc_xu_event_mux_ctrls_ifu          ;
     pc_xu_lsu_event_mux_ctrls_ofu          <=  pc_xu_lsu_event_mux_ctrls_ifu      ;
     pc_xu_event_bus_enable_ofu             <=  pc_xu_event_bus_enable_ifu         ;
     pc_xu_abst_sl_thold_3_ofu              <=  pc_xu_abst_sl_thold_3_ifu          ;
     pc_xu_abst_slp_sl_thold_3_ofu          <=  pc_xu_abst_slp_sl_thold_3_ifu      ;
     pc_xu_regf_sl_thold_3_ofu              <=  pc_xu_regf_sl_thold_3_ifu          ;
     pc_xu_regf_slp_sl_thold_3_ofu          <=  pc_xu_regf_slp_sl_thold_3_ifu      ;
     pc_xu_ary_nsl_thold_3_ofu              <=  pc_xu_ary_nsl_thold_3_ifu          ;
     pc_xu_ary_slp_nsl_thold_3_ofu          <=  pc_xu_ary_slp_nsl_thold_3_ifu      ;
     pc_xu_cache_par_err_event_ofu          <=  pc_xu_cache_par_err_event_ifu      ;
     pc_xu_ccflush_dc_ofu                   <=  pc_xu_ccflush_dc_ifu               ;
     pc_xu_cfg_sl_thold_3_ofu               <=  pc_xu_cfg_sl_thold_3_ifu           ;
     pc_xu_cfg_slp_sl_thold_3_ofu           <=  pc_xu_cfg_slp_sl_thold_3_ifu       ;
     pc_xu_dbg_action_ofu                   <=  pc_xu_dbg_action_ifu               ;
     pc_xu_debug_mux1_ctrls_ofu             <=  pc_xu_debug_mux1_ctrls_ifu         ;
     pc_xu_debug_mux2_ctrls_ofu             <=  pc_xu_debug_mux2_ctrls_ifu         ;
     pc_xu_debug_mux3_ctrls_ofu             <=  pc_xu_debug_mux3_ctrls_ifu         ;
     pc_xu_debug_mux4_ctrls_ofu             <=  pc_xu_debug_mux4_ctrls_ifu         ;
     pc_xu_decrem_dis_on_stop_ofu           <=  pc_xu_decrem_dis_on_stop_ifu       ;
     pc_xu_event_count_mode_ofu             <=  pc_xu_event_count_mode_ifu         ;
     pc_xu_extirpts_dis_on_stop_ofu         <=  pc_xu_extirpts_dis_on_stop_ifu     ;
     pc_xu_fce_3_ofu                        <=  pc_xu_fce_3_ifu                    ;
     pc_xu_force_ude_ofu                    <=  pc_xu_force_ude_ifu                ;
     pc_xu_func_nsl_thold_3_ofu             <=  pc_xu_func_nsl_thold_3_ifu         ;
     pc_xu_func_sl_thold_3_ofu              <=  pc_xu_func_sl_thold_3_ifu          ;
     pc_xu_func_slp_nsl_thold_3_ofu         <=  pc_xu_func_slp_nsl_thold_3_ifu     ;
     pc_xu_func_slp_sl_thold_3_ofu          <=  pc_xu_func_slp_sl_thold_3_ifu      ;
     pc_xu_gptr_sl_thold_3_ofu              <=  pc_xu_gptr_sl_thold_3_ifu          ;
     pc_xu_init_reset_ofu                   <=  pc_xu_init_reset_ifu               ;
     pc_xu_inj_dcache_parity_ofu            <=  pc_xu_inj_dcache_parity_ifu        ;
     pc_xu_inj_dcachedir_parity_ofu         <=  pc_xu_inj_dcachedir_parity_ifu     ;
     pc_xu_inj_llbust_attempt_ofu           <=  pc_xu_inj_llbust_attempt_ifu       ;
     pc_xu_inj_llbust_failed_ofu            <=  pc_xu_inj_llbust_failed_ifu        ;
     pc_xu_inj_sprg_ecc_ofu                 <=  pc_xu_inj_sprg_ecc_ifu             ;
     pc_xu_inj_regfile_parity_ofu           <=  pc_xu_inj_regfile_parity_ifu       ;
     pc_xu_inj_wdt_reset_ofu                <=  pc_xu_inj_wdt_reset_ifu            ;
     pc_xu_inj_dcachedir_multihit_ofu       <=  pc_xu_inj_dcachedir_multihit_ifu   ;
     pc_xu_instr_trace_mode_ofu             <=  pc_xu_instr_trace_mode_ifu         ;
     pc_xu_instr_trace_tid_ofu              <=  pc_xu_instr_trace_tid_ifu          ;
     pc_xu_msrovride_enab_ofu               <=  pc_xu_msrovride_enab_ifu           ;
     pc_xu_msrovride_gs_ofu                 <=  pc_xu_msrovride_gs_ifu             ;
     pc_xu_msrovride_pr_ofu                 <=  pc_xu_msrovride_pr_ifu             ;
     pc_xu_ram_execute_ofu                  <=  pc_xu_ram_execute_ifu              ;
     pc_xu_ram_flush_thread_ofu             <=  pc_xu_ram_flush_thread_ifu         ;
     pc_xu_ram_mode_ofu                     <=  pc_xu_ram_mode_ifu                 ;
     pc_xu_ram_thread_ofu                   <=  pc_xu_ram_thread_ifu               ;
     pc_xu_repr_sl_thold_3_ofu              <=  pc_xu_repr_sl_thold_3_ifu          ;
     pc_xu_reset_1_cmplt_ofu                <=  pc_xu_reset_1_cmplt_ifu            ;
     pc_xu_reset_2_cmplt_ofu                <=  pc_xu_reset_2_cmplt_ifu            ;
     pc_xu_reset_3_cmplt_ofu                <=  pc_xu_reset_3_cmplt_ifu            ;
     pc_xu_reset_wd_cmplt_ofu               <=  pc_xu_reset_wd_cmplt_ifu           ;
     pc_xu_sg_3_ofu                         <=  pc_xu_sg_3_ifu                     ;
     pc_xu_step_ofu                         <=  pc_xu_step_ifu                     ;
     pc_xu_stop_ofu                         <=  pc_xu_stop_ifu                     ;
     pc_xu_time_sl_thold_3_ofu              <=  pc_xu_time_sl_thold_3_ifu          ;
     pc_xu_timebase_dis_on_stop_ofu         <=  pc_xu_timebase_dis_on_stop_ifu     ;
     pc_xu_trace_bus_enable_ofu             <=  pc_xu_trace_bus_enable_ifu         ;

     an_ac_scan_dis_dc_b_ofu                <=  scan_dis_dc_b                      ;
     an_ac_scan_diag_dc_ofu                 <=  scan_diag_dc                       ;

     xu_ex2_flush_ofu                       <=  xu_ex2_flush                       ;
     xu_ex3_flush_ofu                       <=  xu_ex3_flush                       ;
     xu_ex4_flush_ofu                       <=  xu_ex4_flush                       ;
     xu_ex5_flush_ofu                       <=  xu_ex5_flush                       ;
     an_ac_lbist_ary_wrt_thru_dc_ofu        <=  an_ac_lbist_ary_wrt_thru_dc        ;


end architecture fuq;


