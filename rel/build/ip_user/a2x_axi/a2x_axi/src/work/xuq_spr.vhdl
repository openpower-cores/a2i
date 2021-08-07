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

library ieee,ibm,support,work,tri,clib; 
use ieee.std_logic_1164.all;
use support.power_logic_pkg.all;
use ibm.std_ulogic_function_support.all;
use tri.tri_latches_pkg.all;

entity xuq_spr is
generic(
   hvmode                           :     integer := 1;
   a2mode                           :     integer := 1;
   expand_type                      :     integer := 2;
   threads                          :     integer := 4;
   regsize                          :     integer := 64;
   eff_ifar                         :     integer := 62;
   spr_xucr0_init_mod               :     integer := 0);
port(
   nclk                             : in  clk_logic;
   
   an_ac_coreid                     : in  std_ulogic_vector(54 to 61);
   spr_pvr_version_dc               : in  std_ulogic_vector(8 to 15);
   spr_pvr_revision_dc              : in  std_ulogic_vector(12 to 15);
   an_ac_ext_interrupt              : in  std_ulogic_vector(0 to threads-1);
   an_ac_crit_interrupt             : in  std_ulogic_vector(0 to threads-1);
   an_ac_perf_interrupt             : in  std_ulogic_vector(0 to threads-1);
   an_ac_reservation_vld            : in  std_ulogic_vector(0 to threads-1);
   an_ac_tb_update_pulse            : in  std_ulogic;
   an_ac_tb_update_enable           : in  std_ulogic;
   an_ac_sleep_en                   : in  std_ulogic_vector(0 to threads-1);
   an_ac_hang_pulse                 : in  std_ulogic_vector(0 to threads-1);
   ac_tc_machine_check              : out std_ulogic_vector(0 to threads-1);
   an_ac_external_mchk              : in  std_ulogic_vector(0 to threads-1);
   pc_xu_instr_trace_mode           : in  std_ulogic;
   pc_xu_instr_trace_tid            : in  std_ulogic_vector(0 to 1);

   an_ac_scan_dis_dc_b              : in  std_ulogic;
   an_ac_scan_diag_dc               : in  std_ulogic;
   pc_xu_ccflush_dc                 : in  std_ulogic;
   clkoff_dc_b                      : in  std_ulogic;
   d_mode_dc                        : in  std_ulogic;
   delay_lclkr_dc                   : in  std_ulogic;
   mpw1_dc_b                        : in  std_ulogic;
   mpw2_dc_b                        : in  std_ulogic;
   func_sl_thold_2                  : in  std_ulogic;
   func_slp_sl_thold_2              : in  std_ulogic;
   func_nsl_thold_2                 : in  std_ulogic;
   func_slp_nsl_thold_2             : in  std_ulogic;
   cfg_sl_thold_2                   : in  std_ulogic;
   cfg_slp_sl_thold_2               : in  std_ulogic;
   ary_nsl_thold_2                  : in  std_ulogic;
   time_sl_thold_2                  : in  std_ulogic;
   abst_sl_thold_2                  : in  std_ulogic;
   repr_sl_thold_2                  : in  std_ulogic;
   gptr_sl_thold_2                  : in  std_ulogic;
   bolt_sl_thold_2                  : in  std_ulogic;
   sg_2                             : in  std_ulogic;
   fce_2                            : in  std_ulogic;
   func_scan_in                     : in  std_ulogic_vector(0 to threads+1);
   func_scan_out                    : out std_ulogic_vector(0 to threads+1);
   bcfg_scan_in                     : in  std_ulogic;
   bcfg_scan_out                    : out std_ulogic;
   ccfg_scan_in                     : in  std_ulogic;
   ccfg_scan_out                    : out std_ulogic;
   dcfg_scan_in                     : in  std_ulogic;
   dcfg_scan_out                    : out std_ulogic;
   time_scan_in                     : in  std_ulogic;
   time_scan_out                    : out std_ulogic;
   abst_scan_in                     : in  std_ulogic;
   abst_scan_out                    : out std_ulogic;
   repr_scan_in                     : in  std_ulogic;
   repr_scan_out                    : out std_ulogic;
   gptr_scan_in                     : in  std_ulogic;
   gptr_scan_out                    : out std_ulogic;

   dec_spr_rf0_tid                  : in  std_ulogic_vector(0 to threads-1);
   dec_spr_rf0_instr                : in  std_ulogic_vector(0 to 31);
   dec_spr_rf1_val                  : in  std_ulogic_vector(0 to threads-1);
   dec_spr_ex1_epid_instr           : in  std_ulogic;
   dec_spr_ex4_val                  : in  std_ulogic_vector(0 to threads-1);

   spr_byp_ex3_spr_rt               : out std_ulogic_vector(64-regsize to 63);

   fxu_spr_ex1_rs2                  : in  std_ulogic_vector(42 to 55);

   fxu_spr_ex1_rs0                  : in  std_ulogic_vector(52 to 63);
   fxu_spr_ex1_rs1                  : in  std_ulogic_vector(54 to 63);
   mux_spr_ex2_rt                   : in  std_ulogic_vector(64-regsize to 63);

   cpl_spr_ex5_act                  : in  std_ulogic_vector(0 to threads-1);
   cpl_spr_ex5_int                  : in  std_ulogic_vector(0 to threads-1);
   cpl_spr_ex5_gint                 : in  std_ulogic_vector(0 to threads-1);
   cpl_spr_ex5_cint                 : in  std_ulogic_vector(0 to threads-1);
   cpl_spr_ex5_mcint                : in  std_ulogic_vector(0 to threads-1);
   cpl_spr_ex5_nia                  : in  std_ulogic_vector(0 to eff_ifar*threads-1);
   cpl_spr_ex5_esr                  : in  std_ulogic_vector(0 to 17*threads-1);
   cpl_spr_ex5_mcsr                 : in  std_ulogic_vector(0 to 15*threads-1);
   cpl_spr_ex5_dbsr                 : in  std_ulogic_vector(0 to 19*threads-1);
   cpl_spr_ex5_dear_update          : in  std_ulogic_vector(0 to threads-1);
   cpl_spr_ex5_dear_update_saved    : in  std_ulogic_vector(0 to threads-1);
   cpl_spr_ex5_dear_save            : in  std_ulogic_vector(0 to threads-1);
   cpl_spr_ex5_dbsr_update          : in  std_ulogic_vector(0 to threads-1);
   cpl_spr_ex5_esr_update           : in  std_ulogic_vector(0 to threads-1);
   cpl_spr_ex5_srr0_dec             : in  std_ulogic_vector(0 to threads-1);
   cpl_spr_ex5_force_gsrr           : in  std_ulogic_vector(0 to threads-1);
   cpl_spr_ex5_dbsr_ide             : in  std_ulogic_vector(0 to threads-1);
   spr_cpl_dbsr_ide                 : out std_ulogic_vector(0 to threads-1);
   
   spr_cpl_external_mchk            : out std_ulogic_vector(0 to threads-1);
   spr_cpl_ext_interrupt            : out std_ulogic_vector(0 to threads-1);
   spr_cpl_dec_interrupt            : out std_ulogic_vector(0 to threads-1);
   spr_cpl_udec_interrupt           : out std_ulogic_vector(0 to threads-1);
   spr_cpl_perf_interrupt           : out std_ulogic_vector(0 to threads-1);
   spr_cpl_fit_interrupt            : out std_ulogic_vector(0 to threads-1);
   spr_cpl_crit_interrupt           : out std_ulogic_vector(0 to threads-1);
   spr_cpl_wdog_interrupt           : out std_ulogic_vector(0 to threads-1);   
   spr_cpl_dbell_interrupt          : out std_ulogic_vector(0 to threads-1);
   spr_cpl_cdbell_interrupt         : out std_ulogic_vector(0 to threads-1);
   spr_cpl_gdbell_interrupt         : out std_ulogic_vector(0 to threads-1);
   spr_cpl_gcdbell_interrupt        : out std_ulogic_vector(0 to threads-1);
   spr_cpl_gmcdbell_interrupt       : out std_ulogic_vector(0 to threads-1);
   cpl_spr_ex5_dbell_taken          : in  std_ulogic_vector(0 to threads-1);
   cpl_spr_ex5_cdbell_taken         : in  std_ulogic_vector(0 to threads-1);
   cpl_spr_ex5_gdbell_taken         : in  std_ulogic_vector(0 to threads-1);
   cpl_spr_ex5_gcdbell_taken        : in  std_ulogic_vector(0 to threads-1);
   cpl_spr_ex5_gmcdbell_taken       : in  std_ulogic_vector(0 to threads-1);

   lsu_xu_dbell_val                 : in  std_ulogic;
   lsu_xu_dbell_type                : in  std_ulogic_vector(0 to 4);
   lsu_xu_dbell_brdcast             : in  std_ulogic;
   lsu_xu_dbell_lpid_match          : in  std_ulogic;
   lsu_xu_dbell_pirtag              : in  std_ulogic_vector(50 to 63);

   xu_lsu_slowspr_val              : out std_ulogic;
   xu_lsu_slowspr_rw               : out std_ulogic;
   xu_lsu_slowspr_etid             : out std_ulogic_vector(0 to 1);
   xu_lsu_slowspr_addr             : out std_ulogic_vector(11 to 20);
   xu_lsu_slowspr_data             : out std_ulogic_vector(64-regsize to 63);

   ac_an_dcr_act                    : out std_ulogic;
   ac_an_dcr_val                    : out std_ulogic;
   ac_an_dcr_read                   : out std_ulogic;
   ac_an_dcr_user                   : out std_ulogic;
   ac_an_dcr_etid                   : out std_ulogic_vector(0 to 1);
   ac_an_dcr_addr                   : out std_ulogic_vector(11 to 20);
   ac_an_dcr_data                   : out std_ulogic_vector(64-regsize to 63);

   xu_ex4_flush                     : in  std_ulogic_vector(0 to threads-1);
   xu_ex5_flush                     : in  std_ulogic_vector(0 to threads-1);

   spr_cpl_fp_precise               : out std_ulogic_vector(0 to threads-1);
   spr_cpl_ex3_spr_hypv             : out std_ulogic;
   spr_cpl_ex3_spr_illeg            : out std_ulogic;
   spr_cpl_ex3_spr_priv             : out std_ulogic;
   spr_cpl_ex3_ct_le                : out std_ulogic_vector(0 to threads-1);
   spr_cpl_ex3_ct_be                : out std_ulogic_vector(0 to threads-1);
   
   cpl_spr_stop                     : in  std_ulogic_vector(0 to threads-1);
   xu_pc_running                    : out std_ulogic_vector(0 to threads-1);
   xu_iu_run_thread                 : out std_ulogic_vector(0 to threads-1);
   xu_iu_single_instr_mode          : out std_ulogic_vector(0 to threads-1);
   xu_iu_raise_iss_pri              : out std_ulogic_vector(0 to threads-1);
   spr_cpl_ex2_run_ctl_flush        : out std_ulogic_vector(0 to threads-1);
   xu_pc_spr_ccr0_we                : out std_ulogic_vector(0 to threads-1);

   iu_xu_quiesce                    : in std_ulogic_vector(0 to threads-1);
   lsu_xu_quiesce                   : in std_ulogic_vector(0 to threads-1);
   mm_xu_quiesce                    : in std_ulogic_vector(0 to threads-1);
   bx_xu_quiesce                    : in std_ulogic_vector(0 to threads-1);
   cpl_spr_quiesce                  : in std_ulogic_vector(0 to threads-1);
   spr_cpl_quiesce                  : out std_ulogic_vector(0 to threads-1);

   pc_xu_extirpts_dis_on_stop       : in  std_ulogic;
   pc_xu_timebase_dis_on_stop       : in  std_ulogic;
   pc_xu_decrem_dis_on_stop         : in  std_ulogic;

   pc_xu_ram_mode                   : in  std_ulogic;
   pc_xu_ram_thread                 : in  std_ulogic_vector(0 to 1);
   pc_xu_msrovride_enab             : in  std_ulogic;
   pc_xu_msrovride_pr               : in  std_ulogic;
   pc_xu_msrovride_gs               : in  std_ulogic;  
   pc_xu_msrovride_de               : in  std_ulogic;  
   
   cpl_spr_ex5_instr_cpl            : in  std_ulogic_vector(0 to threads-1);
   xu_pc_err_llbust_attempt         : out std_ulogic_vector(0 to threads-1);
   xu_pc_err_llbust_failed          : out std_ulogic_vector(0 to threads-1);   

   spr_byp_ex4_is_mtxer             : out std_ulogic_vector(0 to threads-1);
   spr_byp_ex4_is_mfxer             : out std_ulogic_vector(0 to threads-1);   

   pc_xu_reset_wd_complete          : in  std_ulogic;
   pc_xu_reset_1_complete           : in  std_ulogic;
   pc_xu_reset_2_complete           : in  std_ulogic;
   pc_xu_reset_3_complete           : in  std_ulogic;
   ac_tc_reset_1_request            : out std_ulogic;
   ac_tc_reset_2_request            : out std_ulogic;
   ac_tc_reset_3_request            : out std_ulogic;
   ac_tc_reset_wd_request           : out std_ulogic;
   
   pc_xu_inj_llbust_attempt         : in  std_ulogic_vector(0 to threads-1);
   pc_xu_inj_llbust_failed          : in  std_ulogic_vector(0 to threads-1);
   pc_xu_inj_wdt_reset              : in  std_ulogic_vector(0 to threads-1);
   xu_pc_err_wdt_reset              : out std_ulogic_vector(0 to threads-1);

   spr_cpl_ex3_sprg_ce              : out std_ulogic;
   spr_cpl_ex3_sprg_ue              : out std_ulogic;
   pc_xu_inj_sprg_ecc               : in  std_ulogic_vector(0 to threads-1);
   xu_pc_err_sprg_ecc               : out std_ulogic_vector(0 to threads-1);

   spr_perf_tx_events               : out std_ulogic_vector(0 to 8*threads-1);
   xu_lsu_mtspr_trace_en            : out std_ulogic_vector(0 to threads-1);

   cpl_spr_dbcr0_edm                : in  std_ulogic_vector(0 to threads-1);
   spr_bit_act                      : out std_ulogic;
   spr_xucr0_clkg_ctl               : out std_ulogic_vector(0 to 3);
   spr_cpl_iac1_en                  : out std_ulogic_vector(0 to threads-1);
   spr_cpl_iac2_en                  : out std_ulogic_vector(0 to threads-1);
   spr_cpl_iac3_en                  : out std_ulogic_vector(0 to threads-1);
   spr_cpl_iac4_en                  : out std_ulogic_vector(0 to threads-1);
   lsu_xu_spr_xucr0_cslc_xuop       : in  std_ulogic;
   lsu_xu_spr_xucr0_cslc_binv       : in  std_ulogic;
   lsu_xu_spr_xucr0_clo             : in  std_ulogic;
   lsu_xu_spr_xucr0_cul             : in  std_ulogic;
   lsu_xu_spr_epsc_egs              : in  std_ulogic_vector(0 to threads-1);
   lsu_xu_spr_epsc_epr              : in  std_ulogic_vector(0 to threads-1);
   spr_epcr_extgs                   : out std_ulogic_vector(0 to threads-1);
   spr_msr_de                       : out std_ulogic_vector(0 to threads-1);
   spr_msr_pr                       : out std_ulogic_vector(0 to threads-1);
   spr_msr_is                       : out std_ulogic_vector(0 to threads-1);
   spr_msr_cm                       : out std_ulogic_vector(0 to threads-1);
   spr_msr_gs                       : out std_ulogic_vector(0 to threads-1);
   spr_msr_ee                       : out std_ulogic_vector(0 to threads-1);
   spr_msr_ce                       : out std_ulogic_vector(0 to threads-1);
   spr_msr_me                       : out std_ulogic_vector(0 to threads-1);
   xu_lsu_spr_xucr0_clfc            : out std_ulogic;
	xu_pc_spr_ccr0_pme               : out std_ulogic_vector(0 to 1);
	spr_ccr2_en_dcr                  : out std_ulogic;
	spr_ccr2_en_pc                   : out std_ulogic;
	xu_iu_spr_ccr2_ifratsc           : out std_ulogic_vector(0 to 8);
	xu_iu_spr_ccr2_ifrat             : out std_ulogic;
	xu_lsu_spr_ccr2_dfratsc          : out std_ulogic_vector(0 to 8);
	xu_lsu_spr_ccr2_dfrat            : out std_ulogic;
	spr_ccr2_ucode_dis               : out std_ulogic;
	spr_ccr2_ap                      : out std_ulogic_vector(0 to 3);
	spr_ccr2_en_attn                 : out std_ulogic;
	spr_ccr2_en_ditc                 : out std_ulogic;
	spr_ccr2_en_icswx                : out std_ulogic;
	spr_ccr2_notlb                   : out std_ulogic;
	xu_lsu_spr_xucr0_mbar_ack        : out std_ulogic;
	xu_lsu_spr_xucr0_tlbsync         : out std_ulogic;
	spr_dec_spr_xucr0_ssdly          : out std_ulogic_vector(0 to 4);
	spr_xucr0_cls                    : out std_ulogic;
	xu_lsu_spr_xucr0_aflsta          : out std_ulogic;
	spr_xucr0_mddp                   : out std_ulogic;
	xu_lsu_spr_xucr0_cred            : out std_ulogic;
	xu_lsu_spr_xucr0_rel             : out std_ulogic;
	spr_xucr0_mdcp                   : out std_ulogic;
	xu_lsu_spr_xucr0_flsta           : out std_ulogic;
	xu_lsu_spr_xucr0_l2siw           : out std_ulogic;
	xu_lsu_spr_xucr0_flh2l2          : out std_ulogic;
	xu_lsu_spr_xucr0_dcdis           : out std_ulogic;
	xu_lsu_spr_xucr0_wlk             : out std_ulogic;
	spr_dbcr0_idm                    : out std_ulogic_vector(0 to threads-1);
	spr_dbcr0_icmp                   : out std_ulogic_vector(0 to threads-1);
	spr_dbcr0_brt                    : out std_ulogic_vector(0 to threads-1);
	spr_dbcr0_irpt                   : out std_ulogic_vector(0 to threads-1);
	spr_dbcr0_trap                   : out std_ulogic_vector(0 to threads-1);
	spr_dbcr0_dac1                   : out std_ulogic_vector(0 to 2*threads-1);
	spr_dbcr0_dac2                   : out std_ulogic_vector(0 to 2*threads-1);
	spr_dbcr0_ret                    : out std_ulogic_vector(0 to threads-1);
	spr_dbcr0_dac3                   : out std_ulogic_vector(0 to 2*threads-1);
	spr_dbcr0_dac4                   : out std_ulogic_vector(0 to 2*threads-1);
	spr_dbcr1_iac12m                 : out std_ulogic_vector(0 to threads-1);
	spr_dbcr1_iac34m                 : out std_ulogic_vector(0 to threads-1);
	spr_epcr_dtlbgs                  : out std_ulogic_vector(0 to threads-1);
	spr_epcr_itlbgs                  : out std_ulogic_vector(0 to threads-1);
	spr_epcr_dsigs                   : out std_ulogic_vector(0 to threads-1);
	spr_epcr_isigs                   : out std_ulogic_vector(0 to threads-1);
	spr_epcr_duvd                    : out std_ulogic_vector(0 to threads-1);
	spr_epcr_dgtmi                   : out std_ulogic_vector(0 to threads-1);
	xu_mm_spr_epcr_dmiuh             : out std_ulogic_vector(0 to threads-1);
	spr_msr_ucle                     : out std_ulogic_vector(0 to threads-1);
	spr_msr_spv                      : out std_ulogic_vector(0 to threads-1);
	spr_msr_fp                       : out std_ulogic_vector(0 to threads-1);
	spr_msr_ds                       : out std_ulogic_vector(0 to threads-1);
	spr_msrp_uclep                   : out std_ulogic_vector(0 to threads-1);

   bo_enable_2                      : in  std_ulogic; 
   pc_xu_bo_reset                   : in  std_ulogic; 
   pc_xu_bo_unload                  : in  std_ulogic; 
   pc_xu_bo_repair                  : in  std_ulogic; 
   pc_xu_bo_shdata                  : in  std_ulogic; 
   pc_xu_bo_select                  : in  std_ulogic; 
   xu_pc_bo_fail                    : out std_ulogic; 
   xu_pc_bo_diagout                 : out std_ulogic;
   an_ac_lbist_ary_wrt_thru_dc      : in  std_ulogic;
   pc_xu_abist_ena_dc               : in  std_ulogic;
   pc_xu_abist_g8t_wenb             : in  std_ulogic;
   pc_xu_abist_waddr_0              : in  std_ulogic_vector(4 to 9);
   pc_xu_abist_di_0                 : in  std_ulogic_vector(0 to 3);
   pc_xu_abist_g8t1p_renb_0         : in  std_ulogic;
   pc_xu_abist_raddr_0              : in  std_ulogic_vector(4 to 9);
   pc_xu_abist_wl32_comp_ena        : in  std_ulogic;
   pc_xu_abist_raw_dc_b             : in  std_ulogic;
   pc_xu_abist_g8t_dcomp            : in  std_ulogic_vector(0 to 3);
   pc_xu_abist_g8t_bw_1             : in  std_ulogic;
   pc_xu_abist_g8t_bw_0             : in  std_ulogic;
   
   lsu_xu_cmd_debug                 : in  std_ulogic_vector(0 to 175);
   pc_xu_trace_bus_enable           : in  std_ulogic;
   spr_debug_mux_ctrls              : in  std_ulogic_vector(0 to 15);
   spr_debug_data_in                : in  std_ulogic_vector(0 to 87);
   spr_debug_data_out               : out std_ulogic_vector(0 to 87);  
   spr_trigger_data_in              : in  std_ulogic_vector(0 to 11);
   spr_trigger_data_out             : out std_ulogic_vector(0 to 11);
   
   vcs                              : inout power_logic;
   vdd                              : inout power_logic;
   gnd                              : inout power_logic
);

-- synopsys translate_off

-- synopsys translate_on
end xuq_spr;
architecture xuq_spr of xuq_spr is


signal reset_1_request_q, reset_1_request_d  : std_ulogic;
signal reset_2_request_q, reset_2_request_d  : std_ulogic;
signal reset_3_request_q, reset_3_request_d  : std_ulogic;
signal reset_wd_request_q,reset_wd_request_d : std_ulogic;
signal trace_bus_enable_q                                     : std_ulogic;                  
signal debug_mux_ctrls_q                                      : std_ulogic_vector(0 to 15);  
signal debug_data_out_q,          debug_data_out_d            : std_ulogic_vector(0 to 87);  
signal trigger_data_out_q,        trigger_data_out_d          : std_ulogic_vector(0 to 11);  
constant trace_bus_enable_offset             : integer := 0;
constant debug_mux_ctrls_offset              : integer := trace_bus_enable_offset        + 1;
constant debug_data_out_offset               : integer := debug_mux_ctrls_offset         + debug_mux_ctrls_q'length;
constant trigger_data_out_offset             : integer := debug_data_out_offset          + debug_data_out_q'length;
constant xu_spr_cspr_offset                  : integer := trigger_data_out_offset        + trigger_data_out_q'length;
constant scan_right                          : integer := xu_spr_cspr_offset             + 1;
signal siv                                   : std_ulogic_vector(0 to scan_right-1);
signal sov                                   : std_ulogic_vector(0 to scan_right-1);
signal abist_g8t_wenb_q                      : std_ulogic;                        
signal abist_waddr_0_q                       : std_ulogic_vector(4 to 9);         
signal abist_di_0_q                          : std_ulogic_vector(0 to 3);         
signal abist_g8t1p_renb_0_q                  : std_ulogic;                        
signal abist_raddr_0_q                       : std_ulogic_vector(4 to 9);         
signal abist_wl32_comp_ena_q                 : std_ulogic;                        
signal abist_g8t_dcomp_q                     : std_ulogic_vector(0 to 3);         
signal abist_g8t_bw_1_q                      : std_ulogic;                        
signal abist_g8t_bw_0_q                      : std_ulogic;                        
constant xu_spr_aspr_offset_abst             : integer := 1;
constant abist_g8t_wenb_offset_abst          : integer := xu_spr_aspr_offset_abst             + 1;
constant abist_waddr_0_offset_abst           : integer := abist_g8t_wenb_offset_abst          + 1;
constant abist_di_0_offset_abst              : integer := abist_waddr_0_offset_abst           + abist_waddr_0_q'length;
constant abist_g8t1p_renb_0_offset_abst      : integer := abist_di_0_offset_abst              + abist_di_0_q'length;
constant abist_raddr_0_offset_abst           : integer := abist_g8t1p_renb_0_offset_abst      + 1;
constant abist_wl32_comp_ena_offset_abst     : integer := abist_raddr_0_offset_abst           + abist_raddr_0_q'length;
constant abist_g8t_dcomp_offset_abst         : integer := abist_wl32_comp_ena_offset_abst     + 1;
constant abist_g8t_bw_1_offset_abst          : integer := abist_g8t_dcomp_offset_abst         + abist_g8t_dcomp_q'length;
constant abist_g8t_bw_0_offset_abst          : integer := abist_g8t_bw_1_offset_abst          + 1;
constant scan_right_abst                     : integer := abist_g8t_bw_0_offset_abst          + 2;
signal siv_abst                        : std_ulogic_vector(0 to scan_right_abst-1);
signal sov_abst                        : std_ulogic_vector(0 to scan_right_abst-1);
signal siv_bcfg                        : std_ulogic_vector(0 to 2);
signal sov_bcfg                        : std_ulogic_vector(0 to 2);
signal siv_ccfg                        : std_ulogic_vector(0 to threads+2);
signal sov_ccfg                        : std_ulogic_vector(0 to threads+2);
signal siv_dcfg                        : std_ulogic_vector(0 to threads+1);
signal sov_dcfg                        : std_ulogic_vector(0 to threads+1);
signal siv_time                        : std_ulogic_vector(0 to 2);
signal sov_time                        : std_ulogic_vector(0 to 2);
signal siv_gptr                        : std_ulogic_vector(0 to 2);
signal sov_gptr                        : std_ulogic_vector(0 to 2);
signal siv_repr                        : std_ulogic_vector(0 to 2);
signal sov_repr                        : std_ulogic_vector(0 to 2);
signal func_scan_rpwr_in               : std_ulogic_vector(0 to threads+1);
signal func_scan_rpwr_out              : std_ulogic_vector(0 to threads+1);
signal func_scan_gate_out              : std_ulogic_vector(0 to threads+1);
signal g8t_clkoff_dc_b                 : std_ulogic;
signal g8t_d_mode_dc                   : std_ulogic;
signal g8t_mpw1_dc_b                   : std_ulogic_vector(0 to 4);
signal g8t_mpw2_dc_b                   : std_ulogic;
signal g8t_delay_lclkr_dc              : std_ulogic_vector(0 to 4);
signal func_slp_nsl_thold_1            : std_ulogic;
signal func_nsl_thold_1                : std_ulogic;
signal func_slp_sl_thold_1             : std_ulogic;
signal func_sl_thold_1                 : std_ulogic;
signal time_sl_thold_1                 : std_ulogic;
signal abst_sl_thold_1                 : std_ulogic;
signal repr_sl_thold_1                 : std_ulogic;
signal gptr_sl_thold_1                 : std_ulogic;
signal bolt_sl_thold_1                 : std_ulogic;
signal ary_nsl_thold_1                 : std_ulogic;
signal cfg_sl_thold_1                  : std_ulogic;
signal cfg_slp_sl_thold_1              : std_ulogic;
signal fce_1                           : std_ulogic;
signal sg_1                            : std_ulogic;
signal func_slp_nsl_thold_0            : std_ulogic;
signal func_nsl_thold_0                : std_ulogic_vector(0 to threads);
signal func_slp_sl_thold_0             : std_ulogic_vector(0 to threads);
signal func_sl_thold_0                 : std_ulogic_vector(0 to threads);
signal cfg_sl_thold_0                  : std_ulogic_vector(0 to threads);
signal cfg_slp_sl_thold_0              : std_ulogic;
signal fce_0                           : std_ulogic_vector(0 to threads);
signal sg_0                            : std_ulogic_vector(0 to threads);
signal cfg_slp_sl_force                : std_ulogic;
signal cfg_slp_sl_thold_0_b            : std_ulogic;
signal bcfg_slp_sl_force               : std_ulogic;
signal bcfg_slp_sl_thold_0_b           : std_ulogic;
signal cfg_sl_force                    : std_ulogic_vector(0 to threads);
signal cfg_sl_thold_0_b                : std_ulogic_vector(0 to threads);
signal bcfg_sl_force                   : std_ulogic_vector(0 to 0);
signal bcfg_sl_thold_0_b               : std_ulogic_vector(0 to 0);
signal ccfg_sl_force                   : std_ulogic_vector(0 to threads);
signal ccfg_sl_thold_0_b               : std_ulogic_vector(0 to threads);
signal dcfg_sl_force                   : std_ulogic_vector(1 to threads);
signal dcfg_sl_thold_0_b               : std_ulogic_vector(1 to threads);
signal func_sl_force                   : std_ulogic_vector(0 to threads);
signal func_sl_thold_0_b               : std_ulogic_vector(0 to threads);
signal func_slp_sl_force               : std_ulogic_vector(0 to threads);
signal func_slp_sl_thold_0_b           : std_ulogic_vector(0 to threads);
signal func_nsl_force                  : std_ulogic_vector(0 to threads);
signal func_nsl_thold_0_b              : std_ulogic_vector(0 to threads);
signal func_slp_nsl_force              : std_ulogic;
signal func_slp_nsl_thold_0_b          : std_ulogic;
signal repr_sl_thold_0                 : std_ulogic;
signal gptr_sl_thold_0                 : std_ulogic;
signal bolt_sl_thold_0                 : std_ulogic;
signal time_sl_thold_0                 : std_ulogic;
signal abst_sl_force                   : std_ulogic;
signal abst_sl_thold_0                 : std_ulogic;
signal abst_sl_thold_0_b               : std_ulogic;
signal ary_nsl_thold_0                 : std_ulogic;
signal      so_force                   : std_ulogic;
signal abst_so_thold_0_b               : std_ulogic;
signal bcfg_so_thold_0_b               : std_ulogic;
signal ccfg_so_thold_0_b               : std_ulogic;
signal dcfg_so_thold_0_b               : std_ulogic;
signal time_so_thold_0_b               : std_ulogic;
signal repr_so_thold_0_b               : std_ulogic;
signal gptr_so_thold_0_b               : std_ulogic;
signal func_so_thold_0_b               : std_ulogic;
signal cspr_tspr_ex1_instr             : std_ulogic_vector(0 to 31);
signal cspr_tspr_ex2_tid               : std_ulogic_vector(0 to threads-1);
signal cspr_tspr_ex5_is_mtmsr          : std_ulogic;
signal cspr_tspr_ex5_is_mtspr          : std_ulogic;
signal cspr_tspr_ex5_instr             : std_ulogic_vector(11 to 20);
signal cspr_tspr_ex5_is_wrtee          : std_ulogic;
signal cspr_tspr_ex5_is_wrteei         : std_ulogic;
signal cspr_tspr_timebase_taps         : std_ulogic_vector(0 to 9);
signal tspr_cspr_ex3_tspr_rt           : std_ulogic_vector(0 to regsize*threads-1);
signal tspr_cspr_illeg_mtspr_b         : std_ulogic_vector(0 to threads-1);
signal tspr_cspr_illeg_mfspr_b         : std_ulogic_vector(0 to threads-1);
signal tspr_cspr_hypv_mtspr            : std_ulogic_vector(0 to threads-1);
signal tspr_cspr_hypv_mfspr            : std_ulogic_vector(0 to threads-1);
signal tspr_cspr_freeze_timers         : std_ulogic_vector(0 to threads-1);
signal cspr_aspr_ex5_we                : std_ulogic;
signal cspr_aspr_ex5_waddr             : std_ulogic_vector(0 to 5);
signal cspr_aspr_rf1_re                : std_ulogic;
signal cspr_aspr_rf1_raddr             : std_ulogic_vector(0 to 5);
signal aspr_cspr_ex1_rdata             : std_ulogic_vector(64-regsize to 72-(64/regsize));
signal cspr_tspr_msrovride_en          : std_ulogic_vector(0 to threads-1);
signal cspr_tspr_ram_mode              : std_ulogic_vector(0 to threads-1);
signal tspr_epcr_extgs                 : std_ulogic_vector(0 to threads-1);
signal tspr_msr_de                     : std_ulogic_vector(0 to threads-1);
signal tspr_msr_pr                     : std_ulogic_vector(0 to threads-1);
signal tspr_msr_is                     : std_ulogic_vector(0 to threads-1);
signal tspr_msr_cm                     : std_ulogic_vector(0 to threads-1);
signal tspr_msr_gs                     : std_ulogic_vector(0 to threads-1);
signal tspr_msr_ee                     : std_ulogic_vector(0 to threads-1);
signal tspr_msr_ce                     : std_ulogic_vector(0 to threads-1);
signal tspr_msr_me                     : std_ulogic_vector(0 to threads-1);
signal tspr_fp_precise                 : std_ulogic_vector(0 to threads-1);
signal cspr_tspr_llen                  : std_ulogic_vector(0 to threads-1);
signal cspr_tspr_llpri                 : std_ulogic_vector(0 to threads-1);
signal tspr_cspr_lldet                 : std_ulogic_vector(0 to threads-1);
signal tspr_cspr_llpulse               : std_ulogic_vector(0 to threads-1);
signal cspr_tspr_dec_dbg_dis           : std_ulogic_vector(0 to threads-1);
signal reset_1_request                 : std_ulogic_vector(0 to threads-1);
signal reset_2_request                 : std_ulogic_vector(0 to threads-1);
signal reset_3_request                 : std_ulogic_vector(0 to threads-1);
signal reset_wd_request                : std_ulogic_vector(0 to threads-1);
signal cspr_tspr_crit_mask             : std_ulogic_vector(0 to threads-1);
signal cspr_tspr_ext_mask              : std_ulogic_vector(0 to threads-1);
signal cspr_tspr_dec_mask              : std_ulogic_vector(0 to threads-1);
signal cspr_tspr_fit_mask              : std_ulogic_vector(0 to threads-1);
signal cspr_tspr_wdog_mask             : std_ulogic_vector(0 to threads-1);
signal cspr_tspr_udec_mask             : std_ulogic_vector(0 to threads-1);
signal cspr_tspr_perf_mask             : std_ulogic_vector(0 to threads-1);
signal tspr_cspr_pm_wake_up            : std_ulogic_vector(0 to threads-1);
signal tspr_cspr_async_int             : std_ulogic_vector(0 to 3*threads-1);
signal reset_wd_complete               : std_ulogic;
signal reset_1_complete                : std_ulogic;
signal reset_2_complete                : std_ulogic;
signal reset_3_complete                : std_ulogic;
signal timer_update                    : std_ulogic;
signal cspr_tspr_dbell_pirtag          : std_ulogic_vector(50 to 63);
signal tspr_cspr_gpir_match            : std_ulogic_vector(0 to threads-1);
signal ex5_spr_wd                      : std_ulogic_vector(64-regsize to 64+8-(64/regsize));
signal cspr_tspr_rf1_act               : std_ulogic;
signal cspr_xucr0_clkg_ctl             : std_ulogic_vector(0 to 4);
signal instr_trace_mode                : std_ulogic_vector(0 to threads-1);
signal tspr_debug                      : std_ulogic_vector(0 to 12*threads-1);
signal cspr_debug0                     : std_ulogic_vector(0 to 39);
signal cspr_debug1                     : std_ulogic_vector(0 to 87);
signal dbg_group0, dbg_group1          : std_ulogic_vector(0 to 87); 
signal dbg_group2, dbg_group3          : std_ulogic_vector(0 to 87);
signal trg_group0, trg_group1          : std_ulogic_vector(0 to 11);
signal trg_group2, trg_group3          : std_ulogic_vector(0 to 11);
signal tidn, tiup                      : std_ulogic;

begin

tidn <= '0';
tiup <= '1';


spr_epcr_extgs             <= tspr_epcr_extgs;
spr_msr_de                 <= tspr_msr_de;
spr_msr_pr                 <= tspr_msr_pr;
spr_msr_is                 <= tspr_msr_is;
spr_msr_cm                 <= tspr_msr_cm;
spr_msr_gs                 <= tspr_msr_gs;
spr_msr_ee                 <= tspr_msr_ee;
spr_msr_ce                 <= tspr_msr_ce;
spr_msr_me                 <= tspr_msr_me;
spr_cpl_fp_precise         <= tspr_fp_precise;
reset_1_request_d          <= or_reduce(reset_1_request);
reset_2_request_d          <= or_reduce(reset_2_request);
reset_3_request_d          <= or_reduce(reset_3_request);
reset_wd_request_d         <= or_reduce(reset_wd_request);
ac_tc_reset_1_request      <= reset_1_request_q;
ac_tc_reset_2_request      <= reset_2_request_q;
ac_tc_reset_3_request      <= reset_3_request_q;
ac_tc_reset_wd_request     <= reset_wd_request_q;
spr_xucr0_clkg_ctl         <= cspr_xucr0_clkg_ctl(0 to 3);


xu_spr_cspr : entity work.xuq_spr_cspr(xuq_spr_cspr)
generic map(
   hvmode                           => hvmode,
   a2mode                           => a2mode,
   expand_type                      => expand_type,
   threads                          => threads,
   regsize                          => regsize,
   eff_ifar                         => eff_ifar,
   spr_xucr0_init_mod               => spr_xucr0_init_mod)
port map(
   nclk                             => nclk,
   an_ac_sleep_en                   => an_ac_sleep_en,
   an_ac_reservation_vld            => an_ac_reservation_vld,
   an_ac_tb_update_enable           => an_ac_tb_update_enable,
   an_ac_tb_update_pulse            => an_ac_tb_update_pulse,
   an_ac_coreid                     => an_ac_coreid,
   pc_xu_instr_trace_mode           => pc_xu_instr_trace_mode,
   pc_xu_instr_trace_tid            => pc_xu_instr_trace_tid,
   instr_trace_mode                 => instr_trace_mode,
   spr_pvr_version_dc               => spr_pvr_version_dc,
   spr_pvr_revision_dc              => spr_pvr_revision_dc,
   d_mode_dc                        => d_mode_dc,
   delay_lclkr_dc(0)                => delay_lclkr_dc,
   mpw1_dc_b(0)                     => mpw1_dc_b,
   mpw2_dc_b                        => mpw2_dc_b,
   bcfg_sl_force => bcfg_sl_force(0),
   bcfg_sl_thold_0_b                => bcfg_sl_thold_0_b(0),
   bcfg_slp_sl_force => bcfg_slp_sl_force,
   bcfg_slp_sl_thold_0_b            => bcfg_slp_sl_thold_0_b,
   ccfg_sl_force => ccfg_sl_force(0),
   ccfg_sl_thold_0_b                => ccfg_sl_thold_0_b(0),
   func_sl_force => func_sl_force(0),
   func_sl_thold_0_b                => func_sl_thold_0_b(0),
   func_slp_sl_force => func_slp_sl_force(0),
   func_slp_sl_thold_0_b            => func_slp_sl_thold_0_b(0),

   func_nsl_force => func_nsl_force(0),
   func_nsl_thold_0_b               => func_nsl_thold_0_b(0),
   func_slp_nsl_force => func_slp_nsl_force,
   func_slp_nsl_thold_0_b           => func_slp_nsl_thold_0_b,

   sg_0                             => sg_0(0),
   scan_in(0)                       => func_scan_rpwr_in(threads),
   scan_in(1)                       => siv(xu_spr_cspr_offset),
   scan_out(0)                      => func_scan_rpwr_out(threads),
   scan_out(1)                      => sov(xu_spr_cspr_offset),
   bcfg_scan_in                     => siv_bcfg(1),
   bcfg_scan_out                    => sov_bcfg(1),
   ccfg_scan_in                     => siv_ccfg(1),
   ccfg_scan_out                    => sov_ccfg(1),
   cspr_tspr_rf1_act                => cspr_tspr_rf1_act,
   dec_spr_rf0_tid                  => dec_spr_rf0_tid,
   dec_spr_rf0_instr                => dec_spr_rf0_instr,
   dec_spr_rf1_val                  => dec_spr_rf1_val,
   dec_spr_ex4_val                  => dec_spr_ex4_val,
   tspr_cspr_ex3_tspr_rt            => tspr_cspr_ex3_tspr_rt,
   spr_byp_ex3_spr_rt               => spr_byp_ex3_spr_rt,
   mux_spr_ex2_rt                   => mux_spr_ex2_rt,
   fxu_spr_ex1_rs0                  => fxu_spr_ex1_rs0,
   fxu_spr_ex1_rs1                  => fxu_spr_ex1_rs1,
   ex5_spr_wd                       => ex5_spr_wd,
   cspr_tspr_ex1_instr              => cspr_tspr_ex1_instr,
   cspr_tspr_ex2_tid                => cspr_tspr_ex2_tid,
   cspr_tspr_ex5_is_mtmsr           => cspr_tspr_ex5_is_mtmsr,
   cspr_tspr_ex5_is_mtspr           => cspr_tspr_ex5_is_mtspr,
   cspr_tspr_ex5_is_wrtee           => cspr_tspr_ex5_is_wrtee,
   cspr_tspr_ex5_is_wrteei          => cspr_tspr_ex5_is_wrteei,
   cspr_tspr_ex5_instr              => cspr_tspr_ex5_instr,
   cspr_tspr_timebase_taps          => cspr_tspr_timebase_taps,
   timer_update                     => timer_update,
   cspr_tspr_dec_dbg_dis            => cspr_tspr_dec_dbg_dis,
   tspr_cspr_illeg_mtspr_b          => tspr_cspr_illeg_mtspr_b,
   tspr_cspr_illeg_mfspr_b          => tspr_cspr_illeg_mfspr_b,
   tspr_cspr_hypv_mtspr             => tspr_cspr_hypv_mtspr,
   tspr_cspr_hypv_mfspr             => tspr_cspr_hypv_mfspr,
   cspr_aspr_ex5_we                 => cspr_aspr_ex5_we,
   cspr_aspr_ex5_waddr              => cspr_aspr_ex5_waddr,
   cspr_aspr_rf1_re                 => cspr_aspr_rf1_re,
   cspr_aspr_rf1_raddr              => cspr_aspr_rf1_raddr,
   aspr_cspr_ex1_rdata              => aspr_cspr_ex1_rdata(64-regsize to 72-(64/regsize)),
   xu_lsu_slowspr_val               => xu_lsu_slowspr_val,
   xu_lsu_slowspr_rw                => xu_lsu_slowspr_rw,
   xu_lsu_slowspr_etid              => xu_lsu_slowspr_etid,
   xu_lsu_slowspr_addr              => xu_lsu_slowspr_addr,
   xu_lsu_slowspr_data              => xu_lsu_slowspr_data,
   ac_an_dcr_act                    => ac_an_dcr_act,
   ac_an_dcr_val                    => ac_an_dcr_val,
   ac_an_dcr_read                   => ac_an_dcr_read,
   ac_an_dcr_user                   => ac_an_dcr_user,
   ac_an_dcr_etid                   => ac_an_dcr_etid,
   ac_an_dcr_addr                   => ac_an_dcr_addr,
   ac_an_dcr_data                   => ac_an_dcr_data,
   xu_ex4_flush                     => xu_ex4_flush,
   xu_ex5_flush                     => xu_ex5_flush,
   spr_cpl_ex3_spr_hypv             => spr_cpl_ex3_spr_hypv,
   spr_cpl_ex3_spr_illeg            => spr_cpl_ex3_spr_illeg,
   spr_cpl_ex3_spr_priv             => spr_cpl_ex3_spr_priv,
   cpl_spr_stop                     => cpl_spr_stop,
   xu_iu_run_thread                 => xu_iu_run_thread,
   spr_cpl_ex2_run_ctl_flush        => spr_cpl_ex2_run_ctl_flush,
   xu_pc_spr_ccr0_we                => xu_pc_spr_ccr0_we,
   iu_xu_quiesce                    => iu_xu_quiesce,
   lsu_xu_quiesce                   => lsu_xu_quiesce,
   mm_xu_quiesce                    => mm_xu_quiesce,
   bx_xu_quiesce                    => bx_xu_quiesce,
   cpl_spr_quiesce                  => cpl_spr_quiesce,
   xu_pc_running                    => xu_pc_running,
   spr_cpl_quiesce                  => spr_cpl_quiesce,
   pc_xu_extirpts_dis_on_stop       => pc_xu_extirpts_dis_on_stop,
   pc_xu_timebase_dis_on_stop       => pc_xu_timebase_dis_on_stop,
   pc_xu_decrem_dis_on_stop         => pc_xu_decrem_dis_on_stop,
   pc_xu_ram_mode                   => pc_xu_ram_mode,
   pc_xu_ram_thread                 => pc_xu_ram_thread,
   pc_xu_msrovride_enab             => pc_xu_msrovride_enab,
   cspr_tspr_msrovride_en           => cspr_tspr_msrovride_en,
   cspr_tspr_ram_mode               => cspr_tspr_ram_mode,
   cspr_tspr_llen                   => cspr_tspr_llen,
   cspr_tspr_llpri                  => cspr_tspr_llpri,
   tspr_cspr_lldet                  => tspr_cspr_lldet,
   tspr_cspr_llpulse                => tspr_cspr_llpulse,
   pc_xu_reset_wd_complete          => pc_xu_reset_wd_complete,
   pc_xu_reset_1_complete           => pc_xu_reset_1_complete,
   pc_xu_reset_2_complete           => pc_xu_reset_2_complete,
   pc_xu_reset_3_complete           => pc_xu_reset_3_complete,
   reset_wd_complete                => reset_wd_complete,
   reset_1_complete                 => reset_1_complete,
   reset_2_complete                 => reset_2_complete,
   reset_3_complete                 => reset_3_complete,
   cspr_tspr_crit_mask              => cspr_tspr_crit_mask,
   cspr_tspr_ext_mask               => cspr_tspr_ext_mask,
   cspr_tspr_dec_mask               => cspr_tspr_dec_mask,
   cspr_tspr_fit_mask               => cspr_tspr_fit_mask,
   cspr_tspr_wdog_mask              => cspr_tspr_wdog_mask,
   cspr_tspr_udec_mask              => cspr_tspr_udec_mask,
   cspr_tspr_perf_mask              => cspr_tspr_perf_mask,
   tspr_cspr_pm_wake_up             => tspr_cspr_pm_wake_up,
   spr_cpl_dbell_interrupt          => spr_cpl_dbell_interrupt,
   spr_cpl_cdbell_interrupt         => spr_cpl_cdbell_interrupt,
   spr_cpl_gdbell_interrupt         => spr_cpl_gdbell_interrupt,
   spr_cpl_gcdbell_interrupt        => spr_cpl_gcdbell_interrupt,
   spr_cpl_gmcdbell_interrupt       => spr_cpl_gmcdbell_interrupt,
   cpl_spr_ex5_dbell_taken          => cpl_spr_ex5_dbell_taken,
   cpl_spr_ex5_cdbell_taken         => cpl_spr_ex5_cdbell_taken,
   cpl_spr_ex5_gdbell_taken         => cpl_spr_ex5_gdbell_taken,
   cpl_spr_ex5_gcdbell_taken        => cpl_spr_ex5_gcdbell_taken,
   cpl_spr_ex5_gmcdbell_taken       => cpl_spr_ex5_gmcdbell_taken,
   cspr_tspr_dbell_pirtag           => cspr_tspr_dbell_pirtag,
   tspr_cspr_gpir_match             => tspr_cspr_gpir_match,
   lsu_xu_dbell_val                 => lsu_xu_dbell_val,
   lsu_xu_dbell_type                => lsu_xu_dbell_type,
   lsu_xu_dbell_brdcast             => lsu_xu_dbell_brdcast,
   lsu_xu_dbell_lpid_match          => lsu_xu_dbell_lpid_match,
   lsu_xu_dbell_pirtag              => lsu_xu_dbell_pirtag,
   spr_cpl_ex3_sprg_ce              => spr_cpl_ex3_sprg_ce,
   spr_cpl_ex3_sprg_ue              => spr_cpl_ex3_sprg_ue,
   pc_xu_inj_sprg_ecc               => pc_xu_inj_sprg_ecc,
   xu_pc_err_sprg_ecc               => xu_pc_err_sprg_ecc,
   tspr_cspr_freeze_timers          => tspr_cspr_freeze_timers,
   tspr_cspr_async_int              => tspr_cspr_async_int,
   spr_perf_tx_events               => spr_perf_tx_events,
   xu_lsu_mtspr_trace_en            => xu_lsu_mtspr_trace_en,
   lsu_xu_spr_xucr0_cslc_xuop       => lsu_xu_spr_xucr0_cslc_xuop,
   lsu_xu_spr_xucr0_cslc_binv       => lsu_xu_spr_xucr0_cslc_binv,
   lsu_xu_spr_xucr0_clo             => lsu_xu_spr_xucr0_clo,
   lsu_xu_spr_xucr0_cul             => lsu_xu_spr_xucr0_cul,
   tspr_msr_gs                      => tspr_msr_gs,
   tspr_msr_pr                      => tspr_msr_pr,
   tspr_msr_ee                      => tspr_msr_ee,
   tspr_msr_ce                      => tspr_msr_ce,
   tspr_msr_me                      => tspr_msr_me,
   cspr_xucr0_clkg_ctl              => cspr_xucr0_clkg_ctl,
   xu_lsu_spr_xucr0_clfc            => xu_lsu_spr_xucr0_clfc,
   spr_bit_act                      => spr_bit_act,
	xu_pc_spr_ccr0_pme               => xu_pc_spr_ccr0_pme,
	spr_ccr2_en_dcr                  => spr_ccr2_en_dcr,
	spr_ccr2_en_pc                   => spr_ccr2_en_pc,
	xu_iu_spr_ccr2_ifratsc           => xu_iu_spr_ccr2_ifratsc,
	xu_iu_spr_ccr2_ifrat             => xu_iu_spr_ccr2_ifrat,
	xu_lsu_spr_ccr2_dfratsc          => xu_lsu_spr_ccr2_dfratsc,
	xu_lsu_spr_ccr2_dfrat            => xu_lsu_spr_ccr2_dfrat,
	spr_ccr2_ucode_dis               => spr_ccr2_ucode_dis,
	spr_ccr2_ap                      => spr_ccr2_ap,
	spr_ccr2_en_attn                 => spr_ccr2_en_attn,
	spr_ccr2_en_ditc                 => spr_ccr2_en_ditc,
	spr_ccr2_en_icswx                => spr_ccr2_en_icswx,
	spr_ccr2_notlb                   => spr_ccr2_notlb,
	xu_lsu_spr_xucr0_mbar_ack        => xu_lsu_spr_xucr0_mbar_ack,
	xu_lsu_spr_xucr0_tlbsync         => xu_lsu_spr_xucr0_tlbsync,
	spr_dec_spr_xucr0_ssdly          => spr_dec_spr_xucr0_ssdly,
	spr_xucr0_cls                    => spr_xucr0_cls,
	xu_lsu_spr_xucr0_aflsta          => xu_lsu_spr_xucr0_aflsta,
	spr_xucr0_mddp                   => spr_xucr0_mddp,
	xu_lsu_spr_xucr0_cred            => xu_lsu_spr_xucr0_cred,
	xu_lsu_spr_xucr0_rel             => xu_lsu_spr_xucr0_rel,
	spr_xucr0_mdcp                   => spr_xucr0_mdcp,
	xu_lsu_spr_xucr0_flsta           => xu_lsu_spr_xucr0_flsta,
	xu_lsu_spr_xucr0_l2siw           => xu_lsu_spr_xucr0_l2siw,
	xu_lsu_spr_xucr0_flh2l2          => xu_lsu_spr_xucr0_flh2l2,
	xu_lsu_spr_xucr0_dcdis           => xu_lsu_spr_xucr0_dcdis,
	xu_lsu_spr_xucr0_wlk             => xu_lsu_spr_xucr0_wlk,
   cspr_debug0                      => cspr_debug0,
   cspr_debug1                      => cspr_debug1,
   vdd                              => vdd,
   gnd                              => gnd
);

thread : for t in 0 to threads-1 generate
xu_spr_tspr : entity work.xuq_spr_tspr(xuq_spr_tspr)
generic map(
   hvmode                           => hvmode,
   a2mode                           => a2mode,
   expand_type                      => expand_type,
   regsize                          => regsize,
   eff_ifar                         => eff_ifar)
port map(
   nclk                             => nclk,
   an_ac_ext_interrupt              => an_ac_ext_interrupt(t),
   an_ac_crit_interrupt             => an_ac_crit_interrupt(t),
   an_ac_perf_interrupt             => an_ac_perf_interrupt(t),
   an_ac_hang_pulse                 => an_ac_hang_pulse(t),
   ac_tc_machine_check              => ac_tc_machine_check(t),
   an_ac_external_mchk              => an_ac_external_mchk(t),
   instr_trace_mode                 => instr_trace_mode(t),
   d_mode_dc                        => d_mode_dc,
   delay_lclkr_dc(0)                => delay_lclkr_dc,
   mpw1_dc_b(0)                     => mpw1_dc_b,
   mpw2_dc_b                        => mpw2_dc_b,
   func_sl_force => func_sl_force(1+t),
   func_sl_thold_0_b                => func_sl_thold_0_b(1+t),
   func_nsl_force => func_nsl_force(1+t),
   func_nsl_thold_0_b               => func_nsl_thold_0_b(1+t),
   func_slp_sl_force => func_slp_sl_force(1+t),
   func_slp_sl_thold_0_b            => func_slp_sl_thold_0_b(1+t),
   ccfg_sl_force => ccfg_sl_force(1+t),
   ccfg_sl_thold_0_b                => ccfg_sl_thold_0_b(1+t),
   dcfg_sl_force => dcfg_sl_force(1+t),
   dcfg_sl_thold_0_b                => dcfg_sl_thold_0_b(1+t),
   sg_0                             => sg_0(1+t),
   scan_in                          => func_scan_rpwr_in(t),
   scan_out                         => func_scan_rpwr_out(t),
   ccfg_scan_in                     => siv_ccfg(2+t),
   ccfg_scan_out                    => sov_ccfg(2+t),
   dcfg_scan_in                     => siv_dcfg(1+t),
   dcfg_scan_out                    => sov_dcfg(1+t),
   cspr_tspr_rf1_act                => cspr_tspr_rf1_act,
   cspr_tspr_ex1_instr              => cspr_tspr_ex1_instr,
   cspr_tspr_ex2_tid                => cspr_tspr_ex2_tid(t),
   tspr_cspr_ex3_tspr_rt            => tspr_cspr_ex3_tspr_rt(regsize*t to regsize*(t+1)-1),
   dec_spr_ex4_val                  => dec_spr_ex4_val(t),
   cspr_tspr_ex5_is_mtmsr           => cspr_tspr_ex5_is_mtmsr,
   cspr_tspr_ex5_is_mtspr           => cspr_tspr_ex5_is_mtspr,
   cspr_tspr_ex5_is_wrtee           => cspr_tspr_ex5_is_wrtee,
   cspr_tspr_ex5_is_wrteei          => cspr_tspr_ex5_is_wrteei,
   cspr_tspr_ex5_instr              => cspr_tspr_ex5_instr,
   ex5_spr_wd                       => ex5_spr_wd(64-regsize to 63),
   cspr_tspr_dec_dbg_dis            => cspr_tspr_dec_dbg_dis(t),
   tspr_cspr_illeg_mtspr_b          => tspr_cspr_illeg_mtspr_b(t),
   tspr_cspr_illeg_mfspr_b          => tspr_cspr_illeg_mfspr_b(t),
   tspr_cspr_hypv_mtspr             => tspr_cspr_hypv_mtspr(t),
   tspr_cspr_hypv_mfspr             => tspr_cspr_hypv_mfspr(t),
   cpl_spr_ex5_act                  => cpl_spr_ex5_act(t),
   cpl_spr_ex5_int                  => cpl_spr_ex5_int(t),
   cpl_spr_ex5_gint                 => cpl_spr_ex5_gint(t),
   cpl_spr_ex5_cint                 => cpl_spr_ex5_cint(t),
   cpl_spr_ex5_mcint                => cpl_spr_ex5_mcint(t),
   cpl_spr_ex5_nia                  => cpl_spr_ex5_nia(eff_ifar*t to eff_ifar*(t+1)-1),
   cpl_spr_ex5_esr                  => cpl_spr_ex5_esr(17*t to 17*(t+1)-1),
   cpl_spr_ex5_mcsr                 => cpl_spr_ex5_mcsr(15*t to 15*(t+1)-1),
   cpl_spr_ex5_dbsr                 => cpl_spr_ex5_dbsr(19*t to 19*(t+1)-1),
   cpl_spr_ex5_dear_update          => cpl_spr_ex5_dear_update(t),
   cpl_spr_ex5_dear_update_saved    => cpl_spr_ex5_dear_update_saved(t),
   cpl_spr_ex5_dear_save            => cpl_spr_ex5_dear_save(t),
   cpl_spr_ex5_dbsr_update          => cpl_spr_ex5_dbsr_update(t),
   cpl_spr_ex5_esr_update           => cpl_spr_ex5_esr_update(t),
   cpl_spr_ex5_srr0_dec             => cpl_spr_ex5_srr0_dec(t),
   cpl_spr_ex5_force_gsrr           => cpl_spr_ex5_force_gsrr(t),
   cpl_spr_ex5_dbsr_ide             => cpl_spr_ex5_dbsr_ide(t),
   spr_cpl_dbsr_ide                 => spr_cpl_dbsr_ide(t),
   spr_cpl_external_mchk            => spr_cpl_external_mchk(t),
   spr_cpl_ext_interrupt            => spr_cpl_ext_interrupt(t),
   spr_cpl_dec_interrupt            => spr_cpl_dec_interrupt(t),
   spr_cpl_udec_interrupt           => spr_cpl_udec_interrupt(t),
   spr_cpl_perf_interrupt           => spr_cpl_perf_interrupt(t),
   spr_cpl_fit_interrupt            => spr_cpl_fit_interrupt(t),
   spr_cpl_crit_interrupt           => spr_cpl_crit_interrupt(t),
   spr_cpl_wdog_interrupt           => spr_cpl_wdog_interrupt(t),
   cspr_tspr_crit_mask              => cspr_tspr_crit_mask(t),
   cspr_tspr_ext_mask               => cspr_tspr_ext_mask(t),
   cspr_tspr_dec_mask               => cspr_tspr_dec_mask(t),
   cspr_tspr_fit_mask               => cspr_tspr_fit_mask(t),
   cspr_tspr_wdog_mask              => cspr_tspr_wdog_mask(t),
   cspr_tspr_udec_mask              => cspr_tspr_udec_mask(t),
   cspr_tspr_perf_mask              => cspr_tspr_perf_mask(t),
   tspr_cspr_pm_wake_up             => tspr_cspr_pm_wake_up(t),
   tspr_cspr_async_int              => tspr_cspr_async_int(3*t to 3*(t+1)-1),
   dec_spr_ex1_epid_instr           => dec_spr_ex1_epid_instr,
   fxu_spr_ex1_rs2                  => fxu_spr_ex1_rs2,
   spr_cpl_ex3_ct_be                => spr_cpl_ex3_ct_be(t),   
   spr_cpl_ex3_ct_le                => spr_cpl_ex3_ct_le(t),
   cspr_tspr_dbell_pirtag           => cspr_tspr_dbell_pirtag,
   tspr_cspr_gpir_match             => tspr_cspr_gpir_match(t),
   cspr_tspr_timebase_taps          => cspr_tspr_timebase_taps,
   timer_update                     => timer_update,
   spr_cpl_iac1_en                  => spr_cpl_iac1_en(t),
   spr_cpl_iac2_en                  => spr_cpl_iac2_en(t),
   spr_cpl_iac3_en                  => spr_cpl_iac3_en(t),
   spr_cpl_iac4_en                  => spr_cpl_iac4_en(t),
   tspr_cspr_freeze_timers          => tspr_cspr_freeze_timers(t),
   xu_ex4_flush                     => xu_ex4_flush(t),
   xu_ex5_flush                     => xu_ex5_flush(t),
   xu_iu_single_instr_mode          => xu_iu_single_instr_mode(t),
   xu_iu_raise_iss_pri              => xu_iu_raise_iss_pri(t),
   cpl_spr_ex5_instr_cpl            => cpl_spr_ex5_instr_cpl(t),
   cspr_tspr_llen                   => cspr_tspr_llen(t),
   cspr_tspr_llpri                  => cspr_tspr_llpri(t),
   tspr_cspr_lldet                  => tspr_cspr_lldet(t),
   tspr_cspr_llpulse                => tspr_cspr_llpulse(t),
   xu_pc_err_llbust_attempt         => xu_pc_err_llbust_attempt(t),
   xu_pc_err_llbust_failed          => xu_pc_err_llbust_failed(t),
   pc_xu_inj_llbust_attempt         => pc_xu_inj_llbust_attempt(t),
   pc_xu_inj_llbust_failed          => pc_xu_inj_llbust_failed(t),
   pc_xu_inj_wdt_reset              => pc_xu_inj_wdt_reset(t),
   spr_byp_ex4_is_mtxer             => spr_byp_ex4_is_mtxer(t),
   spr_byp_ex4_is_mfxer             => spr_byp_ex4_is_mfxer(t),
   reset_wd_complete                => reset_wd_complete,
   reset_1_complete                 => reset_1_complete,
   reset_2_complete                 => reset_2_complete,
   reset_3_complete                 => reset_3_complete,
   reset_1_request                  => reset_1_request(t),
   reset_2_request                  => reset_2_request(t),
   reset_3_request                  => reset_3_request(t),
   reset_wd_request                 => reset_wd_request(t),
   xu_pc_err_wdt_reset              => xu_pc_err_wdt_reset(t),
   cspr_tspr_ram_mode               => cspr_tspr_ram_mode(t),
   cspr_tspr_msrovride_en           => cspr_tspr_msrovride_en(t),
   pc_xu_msrovride_pr               => pc_xu_msrovride_pr,
   pc_xu_msrovride_gs               => pc_xu_msrovride_gs,
   pc_xu_msrovride_de               => pc_xu_msrovride_de,
   cpl_spr_dbcr0_edm                => cpl_spr_dbcr0_edm(t),
   lsu_xu_spr_epsc_egs              => lsu_xu_spr_epsc_egs(t),
   lsu_xu_spr_epsc_epr              => lsu_xu_spr_epsc_epr(t),
   tspr_epcr_extgs                  => tspr_epcr_extgs(t),
   tspr_fp_precise                  => tspr_fp_precise(t),
   tspr_msr_de                      => tspr_msr_de(t),
   tspr_msr_pr                      => tspr_msr_pr(t),
   tspr_msr_is                      => tspr_msr_is(t),
   tspr_msr_cm                      => tspr_msr_cm(t),
   tspr_msr_gs                      => tspr_msr_gs(t),
   tspr_msr_ee                      => tspr_msr_ee(t),
   tspr_msr_ce                      => tspr_msr_ce(t),
   tspr_msr_me                      => tspr_msr_me(t),
   cspr_xucr0_clkg_ctl              => cspr_xucr0_clkg_ctl(4 to 4),
	spr_dbcr0_idm                    => spr_dbcr0_idm(t),
	spr_dbcr0_icmp                   => spr_dbcr0_icmp(t),
	spr_dbcr0_brt                    => spr_dbcr0_brt(t),
	spr_dbcr0_irpt                   => spr_dbcr0_irpt(t),
	spr_dbcr0_trap                   => spr_dbcr0_trap(t),
	spr_dbcr0_dac1                   => spr_dbcr0_dac1(2*t to 2*(t+1)-1),
	spr_dbcr0_dac2                   => spr_dbcr0_dac2(2*t to 2*(t+1)-1),
	spr_dbcr0_ret                    => spr_dbcr0_ret(t),
	spr_dbcr0_dac3                   => spr_dbcr0_dac3(2*t to 2*(t+1)-1),
	spr_dbcr0_dac4                   => spr_dbcr0_dac4(2*t to 2*(t+1)-1),
	spr_dbcr1_iac12m                 => spr_dbcr1_iac12m(t),
	spr_dbcr1_iac34m                 => spr_dbcr1_iac34m(t),
	spr_epcr_dtlbgs                  => spr_epcr_dtlbgs(t),
	spr_epcr_itlbgs                  => spr_epcr_itlbgs(t),
	spr_epcr_dsigs                   => spr_epcr_dsigs(t),
	spr_epcr_isigs                   => spr_epcr_isigs(t),
	spr_epcr_duvd                    => spr_epcr_duvd(t),
	spr_epcr_dgtmi                   => spr_epcr_dgtmi(t),
	xu_mm_spr_epcr_dmiuh             => xu_mm_spr_epcr_dmiuh(t),
	spr_msr_ucle                     => spr_msr_ucle(t),
	spr_msr_spv                      => spr_msr_spv(t),
	spr_msr_fp                       => spr_msr_fp(t),
	spr_msr_ds                       => spr_msr_ds(t),
	spr_msrp_uclep                   => spr_msrp_uclep(t),
   tspr_debug                       => tspr_debug(12*t to 12*(t+1)-1),
   vdd                              => vdd,
   gnd                              => gnd
);
end generate;


xu_spr_aspr : entity tri.tri_64x72_1r1w(tri_64x72_1r1w)
generic map(
   expand_type                         => expand_type,
   regsize                             => regsize)
port map (
   vdd                                 => vdd,
   vcs                                 => vcs,
   gnd                                 => gnd,
   nclk                                => nclk,
   sg_0                                => sg_0(0),
   abst_sl_thold_0                     => abst_sl_thold_0,
   ary_nsl_thold_0                     => ary_nsl_thold_0,
   time_sl_thold_0                     => time_sl_thold_0,
   repr_sl_thold_0                     => repr_sl_thold_0,
   rd0_act                             => cspr_aspr_rf1_re,
   rd0_adr                             => cspr_aspr_rf1_raddr,
   do0                                 => aspr_cspr_ex1_rdata,  
   wr_act            					   => cspr_aspr_ex5_we,
   wr_adr            					   => cspr_aspr_ex5_waddr,
   di                				      => ex5_spr_wd,     
   abst_scan_in                        => siv_abst(xu_spr_aspr_offset_abst),
   abst_scan_out                       => sov_abst(xu_spr_aspr_offset_abst),
   time_scan_in                        => siv_time(1),
   time_scan_out                       => sov_time(1),
   repr_scan_in                        => siv_repr(1),
   repr_scan_out                       => sov_repr(1),
   scan_dis_dc_b                       => an_ac_scan_dis_dc_b,
   scan_diag_dc                        => an_ac_scan_diag_dc,
   ccflush_dc                          => pc_xu_ccflush_dc,   
   clkoff_dc_b                         => g8t_clkoff_dc_b,
   d_mode_dc                           => g8t_d_mode_dc,
   mpw1_dc_b                           => g8t_mpw1_dc_b,
   mpw2_dc_b                           => g8t_mpw2_dc_b,
   delay_lclkr_dc                      => g8t_delay_lclkr_dc,
   lcb_bolt_sl_thold_0                 => bolt_sl_thold_0,
   pc_bo_enable_2                      => bo_enable_2,                       
   pc_bo_reset                         => pc_xu_bo_reset,                    
   pc_bo_unload                        => pc_xu_bo_unload,                   
   pc_bo_repair                        => pc_xu_bo_repair,                   
   pc_bo_shdata                        => pc_xu_bo_shdata,                   
   pc_bo_select                        => pc_xu_bo_select,                   
   bo_pc_failout                       => xu_pc_bo_fail,                     
   bo_pc_diagloop                      => xu_pc_bo_diagout, 
   tri_lcb_mpw1_dc_b                   => mpw1_dc_b,
   tri_lcb_mpw2_dc_b                   => mpw2_dc_b,
   tri_lcb_delay_lclkr_dc              => delay_lclkr_dc,
   tri_lcb_clkoff_dc_b                 => clkoff_dc_b,
   tri_lcb_act_dis_dc                  => tidn,
   abist_bw_odd                        => abist_g8t_bw_1_q,
   abist_bw_even                       => abist_g8t_bw_0_q, 
   tc_lbist_ary_wrt_thru_dc            => an_ac_lbist_ary_wrt_thru_dc,
   abist_ena_1                         => pc_xu_abist_ena_dc,
   wr_abst_act                         => abist_g8t_wenb_q,
   abist_wr_adr                        => abist_waddr_0_q,
   abist_di                            => abist_di_0_q,
   rd0_abst_act                        => abist_g8t1p_renb_0_q,
   abist_rd0_adr                       => abist_raddr_0_q,
   abist_g8t_rd0_comp_ena              => abist_wl32_comp_ena_q,
   abist_raw_dc_b                      => pc_xu_abist_raw_dc_b,
   obs0_abist_cmp                      => abist_g8t_dcomp_q
   );

xu_debug_mux : entity clib.c_debug_mux4(c_debug_mux4)
port map(
   vd                => vdd,
   gd                => gnd,
   select_bits       => debug_mux_ctrls_q,
   trace_data_in     => spr_debug_data_in,
   trigger_data_in   => spr_trigger_data_in,
   dbg_group0        => dbg_group0,
   dbg_group1        => dbg_group1,
   dbg_group2        => dbg_group2,
   dbg_group3        => dbg_group3,
   trg_group0        => trg_group0,
   trg_group1        => trg_group1,
   trg_group2        => trg_group2,
   trg_group3        => trg_group3,
   trigger_data_out  => trigger_data_out_d,
   trace_data_out    => debug_data_out_d);

dbg_group0  <= cspr_debug0 & tspr_debug;
dbg_group1  <= cspr_debug1;
dbg_group2  <= lsu_xu_cmd_debug(0 to 87);
dbg_group3  <= lsu_xu_cmd_debug(88 to 175);
trg_group0  <= (others=>'0');
trg_group1  <= (others=>'0');
trg_group2  <= (others=>'0');
trg_group3  <= (others=>'0');

spr_trigger_data_out <= trigger_data_out_q;
spr_debug_data_out   <= debug_data_out_q;


reset_1_request_latch : tri_regk
  generic map (width => 1, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup,
            forcee => func_nsl_force(0),
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_nsl_thold_0_b(0),
            din(0)  => reset_1_request_d,
            dout(0) => reset_1_request_q);
reset_2_request_latch : tri_regk
  generic map (width => 1, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup,
            forcee => func_nsl_force(0),
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_nsl_thold_0_b(0),
            din(0)  => reset_2_request_d,
            dout(0) => reset_2_request_q);
reset_3_request_latch : tri_regk
  generic map (width => 1, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup,
            forcee => func_nsl_force(0),
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_nsl_thold_0_b(0),
            din(0)  => reset_3_request_d,
            dout(0) => reset_3_request_q);
reset_wd_request_latch : tri_regk
  generic map (width => 1, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup,
            forcee => func_nsl_force(0),
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_nsl_thold_0_b(0),
            din(0)  => reset_wd_request_d,
            dout(0) => reset_wd_request_q);
trace_bus_enable_latch : tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup                 ,
            forcee => func_slp_sl_force(0),
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_slp_sl_thold_0_b(0),
            sg      => sg_0(0),
            scin    => siv(trace_bus_enable_offset),
            scout   => sov(trace_bus_enable_offset),
            din     => pc_xu_trace_bus_enable     ,
            dout    => trace_bus_enable_q);
debug_mux_ctrls_latch : tri_rlmreg_p
  generic map (width => debug_mux_ctrls_q'length, init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => trace_bus_enable_q   ,
            forcee => func_slp_sl_force(0),
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_slp_sl_thold_0_b(0),
            sg      => sg_0(0),
            scin    => siv(debug_mux_ctrls_offset to debug_mux_ctrls_offset + debug_mux_ctrls_q'length-1),
            scout   => sov(debug_mux_ctrls_offset to debug_mux_ctrls_offset + debug_mux_ctrls_q'length-1),
            din     => spr_debug_mux_ctrls        ,
            dout    => debug_mux_ctrls_q);
debug_data_out_latch : tri_rlmreg_p
  generic map (width => debug_data_out_q'length, init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => trace_bus_enable_q   ,
            forcee => func_slp_sl_force(0),
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_slp_sl_thold_0_b(0),
            sg      => sg_0(0),
            scin    => siv(debug_data_out_offset to debug_data_out_offset + debug_data_out_q'length-1),
            scout   => sov(debug_data_out_offset to debug_data_out_offset + debug_data_out_q'length-1),
            din     => debug_data_out_d,
            dout    => debug_data_out_q);
trigger_data_out_latch : tri_rlmreg_p
  generic map (width => trigger_data_out_q'length, init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => trace_bus_enable_q   ,
            forcee => func_slp_sl_force(0),
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_slp_sl_thold_0_b(0),
            sg      => sg_0(0),
            scin    => siv(trigger_data_out_offset to trigger_data_out_offset + trigger_data_out_q'length-1),
            scout   => sov(trigger_data_out_offset to trigger_data_out_offset + trigger_data_out_q'length-1),
            din     => trigger_data_out_d,
            dout    => trigger_data_out_q);
abist_g8t_wenb_latch : tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => pc_xu_abist_ena_dc,
            forcee => abst_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => abst_sl_thold_0_b,
            sg      => sg_0(0),
            scin    => siv_abst(abist_g8t_wenb_offset_abst),
            scout   => sov_abst(abist_g8t_wenb_offset_abst),
            din     => pc_xu_abist_g8t_wenb,
            dout    => abist_g8t_wenb_q);
abist_waddr_0_latch : tri_rlmreg_p
  generic map (width => abist_waddr_0_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => pc_xu_abist_ena_dc,
            forcee => abst_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => abst_sl_thold_0_b,
            sg      => sg_0(0),
            scin    => siv_abst(abist_waddr_0_offset_abst to abist_waddr_0_offset_abst + abist_waddr_0_q'length-1),
            scout   => sov_abst(abist_waddr_0_offset_abst to abist_waddr_0_offset_abst + abist_waddr_0_q'length-1),
            din     => pc_xu_abist_waddr_0,
            dout    => abist_waddr_0_q);
abist_di_0_latch : tri_rlmreg_p
  generic map (width => abist_di_0_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => pc_xu_abist_ena_dc,
            forcee => abst_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => abst_sl_thold_0_b,
            sg      => sg_0(0),
            scin    => siv_abst(abist_di_0_offset_abst to abist_di_0_offset_abst + abist_di_0_q'length-1),
            scout   => sov_abst(abist_di_0_offset_abst to abist_di_0_offset_abst + abist_di_0_q'length-1),
            din     => pc_xu_abist_di_0,
            dout    => abist_di_0_q);
abist_g8t1p_renb_0_latch : tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => pc_xu_abist_ena_dc,
            forcee => abst_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => abst_sl_thold_0_b,
            sg      => sg_0(0),
            scin    => siv_abst(abist_g8t1p_renb_0_offset_abst),
            scout   => sov_abst(abist_g8t1p_renb_0_offset_abst),
            din     => pc_xu_abist_g8t1p_renb_0,
            dout    => abist_g8t1p_renb_0_q);
abist_raddr_0_latch : tri_rlmreg_p
  generic map (width => abist_raddr_0_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => pc_xu_abist_ena_dc,
            forcee => abst_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => abst_sl_thold_0_b,
            sg      => sg_0(0),
            scin    => siv_abst(abist_raddr_0_offset_abst to abist_raddr_0_offset_abst + abist_raddr_0_q'length-1),
            scout   => sov_abst(abist_raddr_0_offset_abst to abist_raddr_0_offset_abst + abist_raddr_0_q'length-1),
            din     => pc_xu_abist_raddr_0,
            dout    => abist_raddr_0_q);
abist_wl32_comp_ena_latch : tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => pc_xu_abist_ena_dc,
            forcee => abst_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => abst_sl_thold_0_b,
            sg      => sg_0(0),
            scin    => siv_abst(abist_wl32_comp_ena_offset_abst),
            scout   => sov_abst(abist_wl32_comp_ena_offset_abst),
            din     => pc_xu_abist_wl32_comp_ena,
            dout    => abist_wl32_comp_ena_q);
abist_g8t_dcomp_latch : tri_rlmreg_p
  generic map (width => abist_g8t_dcomp_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => pc_xu_abist_ena_dc,
            forcee => abst_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => abst_sl_thold_0_b,
            sg      => sg_0(0),
            scin    => siv_abst(abist_g8t_dcomp_offset_abst to abist_g8t_dcomp_offset_abst + abist_g8t_dcomp_q'length-1),
            scout   => sov_abst(abist_g8t_dcomp_offset_abst to abist_g8t_dcomp_offset_abst + abist_g8t_dcomp_q'length-1),
            din     => pc_xu_abist_g8t_dcomp,
            dout    => abist_g8t_dcomp_q);
abist_g8t_bw_1_latch : tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => pc_xu_abist_ena_dc,
            forcee => abst_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => abst_sl_thold_0_b,
            sg      => sg_0(0),
            scin    => siv_abst(abist_g8t_bw_1_offset_abst),
            scout   => sov_abst(abist_g8t_bw_1_offset_abst),
            din     => pc_xu_abist_g8t_bw_1,
            dout    => abist_g8t_bw_1_q);
abist_g8t_bw_0_latch : tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => pc_xu_abist_ena_dc,
            forcee => abst_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => abst_sl_thold_0_b,
            sg      => sg_0(0),
            scin    => siv_abst(abist_g8t_bw_0_offset_abst),
            scout   => sov_abst(abist_g8t_bw_0_offset_abst),
            din     => pc_xu_abist_g8t_bw_0,
            dout    => abist_g8t_bw_0_q);
abst_scan_in_latch : tri_regs
  generic map (width => 1, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            forcee => so_force,
            delay_lclkr => delay_lclkr_dc,
            thold_b => abst_so_thold_0_b,
            scin    => siv_abst(siv_abst'left  to siv_abst'left),
            scout   => sov_abst(siv_abst'left  to siv_abst'left),
            dout    => open);
abst_scan_out_latch : tri_regs
  generic map (width => 1, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            forcee => so_force,
            delay_lclkr => delay_lclkr_dc,
            thold_b => abst_so_thold_0_b,
            scin    => siv_abst(siv_abst'right to siv_abst'right),
            scout   => sov_abst(siv_abst'right to siv_abst'right),
            dout    => open);
bcfg_scan_in_latch : tri_regs
  generic map (width => 1, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            forcee => so_force,
            delay_lclkr => delay_lclkr_dc,
            thold_b => bcfg_so_thold_0_b,
            scin    => siv_bcfg(siv_bcfg'left  to siv_bcfg'left),
            scout   => sov_bcfg(siv_bcfg'left  to siv_bcfg'left),
            dout    => open);
bcfg_scan_out_latch : tri_regs
  generic map (width => 1, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            forcee => so_force,
            delay_lclkr => delay_lclkr_dc,
            thold_b => bcfg_so_thold_0_b,
            scin    => siv_bcfg(siv_bcfg'right to siv_bcfg'right),
            scout   => sov_bcfg(siv_bcfg'right to siv_bcfg'right),
            dout    => open);
ccfg_scan_in_latch : tri_regs
  generic map (width => 1, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            forcee => so_force,
            delay_lclkr => delay_lclkr_dc,
            thold_b => ccfg_so_thold_0_b,
            scin    => siv_ccfg(siv_ccfg'left  to siv_ccfg'left),
            scout   => sov_ccfg(siv_ccfg'left  to siv_ccfg'left),
            dout    => open);
ccfg_scan_out_latch : tri_regs
  generic map (width => 1, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            forcee => so_force,
            delay_lclkr => delay_lclkr_dc,
            thold_b => ccfg_so_thold_0_b,
            scin    => siv_ccfg(siv_ccfg'right to siv_ccfg'right),
            scout   => sov_ccfg(siv_ccfg'right to siv_ccfg'right),
            dout    => open);
dcfg_scan_in_latch : tri_regs
  generic map (width => 1, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            forcee => so_force,
            delay_lclkr => delay_lclkr_dc,
            thold_b => dcfg_so_thold_0_b,
            scin    => siv_dcfg(siv_dcfg'left  to siv_dcfg'left),
            scout   => sov_dcfg(siv_dcfg'left  to siv_dcfg'left),
            dout    => open);
dcfg_scan_out_latch : tri_regs
  generic map (width => 1, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            forcee => so_force,
            delay_lclkr => delay_lclkr_dc,
            thold_b => dcfg_so_thold_0_b,
            scin    => siv_dcfg(siv_dcfg'right to siv_dcfg'right),
            scout   => sov_dcfg(siv_dcfg'right to siv_dcfg'right),
            dout    => open);
time_scan_in_latch : tri_regs
  generic map (width => 1, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            forcee => so_force,
            delay_lclkr => delay_lclkr_dc,
            thold_b => time_so_thold_0_b,
            scin    => siv_time(siv_time'left  to siv_time'left),
            scout   => sov_time(siv_time'left  to siv_time'left),
            dout    => open);
time_scan_out_latch : tri_regs
  generic map (width => 1, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            forcee => so_force,
            delay_lclkr => delay_lclkr_dc,
            thold_b => time_so_thold_0_b,
            scin    => siv_time(siv_time'right to siv_time'right),
            scout   => sov_time(siv_time'right to siv_time'right),
            dout    => open);
repr_scan_in_latch : tri_regs
  generic map (width => 1, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            forcee => so_force,
            delay_lclkr => delay_lclkr_dc,
            thold_b => repr_so_thold_0_b,
            scin    => siv_repr(siv_repr'left  to siv_repr'left),
            scout   => sov_repr(siv_repr'left  to siv_repr'left),
            dout    => open);
repr_scan_out_latch : tri_regs
  generic map (width => 1, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            forcee => so_force,
            delay_lclkr => delay_lclkr_dc,
            thold_b => repr_so_thold_0_b,
            scin    => siv_repr(siv_repr'right to siv_repr'right),
            scout   => sov_repr(siv_repr'right to siv_repr'right),
            dout    => open);
gptr_scan_in_latch : tri_regs
  generic map (width => 1, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            forcee => so_force,
            delay_lclkr => tiup,
            thold_b => gptr_so_thold_0_b,
            scin    => siv_gptr(siv_gptr'left  to siv_gptr'left),
            scout   => sov_gptr(siv_gptr'left  to siv_gptr'left),
            dout    => open);
gptr_scan_out_latch : tri_regs
  generic map (width => 1, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            forcee => so_force,
            delay_lclkr => tiup,
            thold_b => gptr_so_thold_0_b,
            scin    => siv_gptr(siv_gptr'right to siv_gptr'right),
            scout   => sov_gptr(siv_gptr'right to siv_gptr'right),
            dout    => open);
func_scan_in_latch : tri_regs
  generic map (width => func_scan_in'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            forcee => so_force,
            delay_lclkr => delay_lclkr_dc,
            thold_b => func_so_thold_0_b,
            scin    => func_scan_in,
            scout   => func_scan_rpwr_in,
            dout    => open);
func_scan_out_latch : tri_regs
  generic map (width => func_scan_rpwr_out'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            forcee => so_force,
            delay_lclkr => delay_lclkr_dc,
            thold_b => func_so_thold_0_b,
            scin    => func_scan_rpwr_out,
            scout   => func_scan_gate_out,
            dout    => open);

lcbctrl_g8t: tri_lcbcntl_array_mac
  generic map (expand_type => expand_type)
port map (
            vdd            => vdd,
            gnd            => gnd,
            sg             => sg_0(0),
            nclk           => nclk,
            scan_in        => siv_gptr(1),
            scan_diag_dc   => an_ac_scan_diag_dc,
            thold          => gptr_sl_thold_0,
            clkoff_dc_b    => g8t_clkoff_dc_b,
            delay_lclkr_dc => g8t_delay_lclkr_dc(0 to 4),
            act_dis_dc     => open,
            d_mode_dc      => g8t_d_mode_dc,
            mpw1_dc_b      => g8t_mpw1_dc_b(0 to 4),
            mpw2_dc_b      => g8t_mpw2_dc_b,
            scan_out       => sov_gptr(1));

perv_2to1_reg: tri_plat
  generic map (width => 14, expand_type => expand_type)
port map (vd          => vdd,
            gd          => gnd,
            nclk        => nclk,
            flush       => pc_xu_ccflush_dc,
            din(0)      => func_slp_sl_thold_2,
            din(1)      => func_sl_thold_2,
            din(2)      => func_slp_nsl_thold_2,
            din(3)      => func_nsl_thold_2,
            din(4)      => time_sl_thold_2,
            din(5)      => repr_sl_thold_2,
            din(6)      => gptr_sl_thold_2,
            din(7)      => bolt_sl_thold_2,            
            din(8)      => abst_sl_thold_2,
            din(9)      => ary_nsl_thold_2,
            din(10)     => cfg_sl_thold_2,
            din(11)     => cfg_slp_sl_thold_2,
            din(12)     => sg_2,
            din(13)     => fce_2,
            q(0)        => func_slp_sl_thold_1,
            q(1)        => func_sl_thold_1,
            q(2)        => func_slp_nsl_thold_1,
            q(3)        => func_nsl_thold_1,
            q(4)        => time_sl_thold_1,
            q(5)        => repr_sl_thold_1,
            q(6)        => gptr_sl_thold_1,
            q(7)        => bolt_sl_thold_1,
            q(8)        => abst_sl_thold_1,
            q(9)        => ary_nsl_thold_1,
            q(10)       => cfg_sl_thold_1,
            q(11)       => cfg_slp_sl_thold_1,
            q(12)       => sg_1,
            q(13)       => fce_1);


perv_1to0_reg_gen : for t in 0 to threads generate
   perv_1to0_reg: tri_plat
     generic map (width => 6, expand_type => expand_type)
   port map (vd          => vdd,
               gd          => gnd,
               nclk        => nclk,
               flush       => pc_xu_ccflush_dc,
               din(0)      => func_slp_sl_thold_1,
               din(1)      => func_sl_thold_1,
               din(2)      => func_nsl_thold_1,
               din(3)      => cfg_sl_thold_1,
               din(4)      => sg_1,
               din(5)      => fce_1,
               q(0)        => func_slp_sl_thold_0(t),
               q(1)        => func_sl_thold_0(t),
               q(2)        => func_nsl_thold_0(t),
               q(3)        => cfg_sl_thold_0(t),
               q(4)        => sg_0(t),
               q(5)        => fce_0(t));

   perv_lcbor_cfg_sl: tri_lcbor
     generic map (expand_type => expand_type)
   port map (clkoff_b    => clkoff_dc_b,
               thold       => cfg_sl_thold_0(t),
               sg          => sg_0(t),
               act_dis     => tidn,
               forcee => cfg_sl_force(t),
               thold_b     => cfg_sl_thold_0_b(t));

   perv_lcbor_func_sl: tri_lcbor
     generic map (expand_type => expand_type)
   port map (clkoff_b    => clkoff_dc_b,
               thold       => func_sl_thold_0(t),
               sg          => sg_0(t),
               act_dis     => tidn,
               forcee => func_sl_force(t),
               thold_b     => func_sl_thold_0_b(t));

   perv_lcbor_func_slp_sl: tri_lcbor
     generic map (expand_type => expand_type)
   port map (clkoff_b    => clkoff_dc_b,
               thold       => func_slp_sl_thold_0(t),
               sg          => sg_0(t),
               act_dis     => tidn,
               forcee => func_slp_sl_force(t),
               thold_b     => func_slp_sl_thold_0_b(t));

    perv_lcbor_func_nsl: tri_lcbor
        generic map (expand_type => expand_type)
        port map (clkoff_b  => clkoff_dc_b,
                  thold     => func_nsl_thold_0(t),
                  sg        => fce_0(t),
                  act_dis   => tidn,
                  forcee => func_nsl_force(t),
                  thold_b   => func_nsl_thold_0_b(t));
end generate;

   ccfg_sl_force              <= cfg_sl_force;
   ccfg_sl_thold_0_b          <= cfg_sl_thold_0_b;
   dcfg_sl_force(1 to 4)      <= cfg_sl_force(1 to 4);
   dcfg_sl_thold_0_b(1 to 4)  <= cfg_sl_thold_0_b(1 to 4);

   bcfg_sl_force(0)           <= cfg_sl_force(0);
   bcfg_sl_thold_0_b(0)       <= cfg_sl_thold_0_b(0);

   bcfg_slp_sl_force          <= cfg_slp_sl_force;
   bcfg_slp_sl_thold_0_b      <= cfg_slp_sl_thold_0_b;

   perv_lcbor_cfg_slp_sl: tri_lcbor
     generic map (expand_type => expand_type)
   port map (clkoff_b    => clkoff_dc_b,
               thold       => cfg_slp_sl_thold_0,
               sg          => sg_0(0),
               act_dis     => tidn,
               forcee => cfg_slp_sl_force,
               thold_b     => cfg_slp_sl_thold_0_b);

    perv_lcbor_func_slp_nsl: tri_lcbor
        generic map (expand_type => expand_type)
        port map (clkoff_b  => clkoff_dc_b,
                  thold     => func_slp_nsl_thold_0,
                  sg        => fce_0(0),
                  act_dis   => tidn,
                  forcee => func_slp_nsl_force,
                  thold_b   => func_slp_nsl_thold_0_b);

perv_1to0_reg: tri_plat
  generic map (width => 8, expand_type => expand_type)
port map (vd          => vdd,
            gd          => gnd,
            nclk        => nclk,
            flush       => pc_xu_ccflush_dc,
            din(0)      => abst_sl_thold_1,
            din(1)      => ary_nsl_thold_1,
            din(2)      => time_sl_thold_1,
            din(3)      => repr_sl_thold_1,
            din(4)      => gptr_sl_thold_1,
            din(5)      => bolt_sl_thold_1,
            din(6)      => func_slp_nsl_thold_1,
            din(7)      => cfg_slp_sl_thold_1,
            q(0)        => abst_sl_thold_0,
            q(1)        => ary_nsl_thold_0,
            q(2)        => time_sl_thold_0,
            q(3)        => repr_sl_thold_0,
            q(4)        => gptr_sl_thold_0,
            q(5)        => bolt_sl_thold_0,
            q(6)        => func_slp_nsl_thold_0,
            q(7)        => cfg_slp_sl_thold_0);

perv_lcbor_abst_sl: tri_lcbor
  generic map (expand_type => expand_type)
port map (clkoff_b    => clkoff_dc_b,
            thold       => abst_sl_thold_0,
            sg          => sg_0(0),
            act_dis     => tidn,
            forcee => abst_sl_force,
            thold_b     => abst_sl_thold_0_b);


     so_force           <= sg_0(0);
abst_so_thold_0_b       <= not abst_sl_thold_0;
bcfg_so_thold_0_b       <= not cfg_sl_thold_0(0);
ccfg_so_thold_0_b       <= not cfg_sl_thold_0(0);
dcfg_so_thold_0_b       <= not cfg_sl_thold_0(0);
time_so_thold_0_b       <= not time_sl_thold_0;
repr_so_thold_0_b       <= not repr_sl_thold_0;
gptr_so_thold_0_b       <= not gptr_sl_thold_0;
func_so_thold_0_b       <= not func_sl_thold_0(0);


func_scan_out                       <= gate(func_scan_gate_out,an_ac_scan_dis_dc_b);

siv(0 to siv'right)                 <= sov(1 to siv'right)  & func_scan_rpwr_in(threads+1);
func_scan_rpwr_out(threads+1)       <= sov(0);

siv_abst(0 to siv_abst'right)       <= sov_abst(1 to sov_abst'right) & abst_scan_in;
abst_scan_out                       <= sov_abst(0) and an_ac_scan_dis_dc_b;

siv_bcfg(0 to siv_bcfg'right)       <= sov_bcfg(1 to siv_bcfg'right) & bcfg_scan_in;
bcfg_scan_out                       <= sov_bcfg(0) and an_ac_scan_dis_dc_b;

siv_ccfg(0 to siv_ccfg'right)       <= sov_ccfg(1 to siv_ccfg'right) & ccfg_scan_in;
ccfg_scan_out                       <= sov_ccfg(0) and an_ac_scan_dis_dc_b;

siv_dcfg(0 to siv_dcfg'right)       <= sov_dcfg(1 to siv_dcfg'right) & dcfg_scan_in;
dcfg_scan_out                       <= sov_dcfg(0) and an_ac_scan_dis_dc_b;

siv_time(0 to siv_time'right)       <= sov_time(1 to siv_time'right) & time_scan_in;
time_scan_out                       <= sov_time(0) and an_ac_scan_dis_dc_b;

siv_repr(0 to siv_repr'right)       <= sov_repr(1 to siv_repr'right) & repr_scan_in;
repr_scan_out                       <= sov_repr(0) and an_ac_scan_dis_dc_b;

siv_gptr(0 to siv_gptr'right)       <= sov_gptr(1 to siv_gptr'right) & gptr_scan_in;
gptr_scan_out                       <= sov_gptr(0) and an_ac_scan_dis_dc_b;

end architecture xuq_spr;
