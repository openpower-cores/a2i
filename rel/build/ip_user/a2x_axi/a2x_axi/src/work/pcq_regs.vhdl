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
use ibm.std_ulogic_unsigned.all;
library support;
use support.power_logic_pkg.all;
library tri;
use tri.tri_latches_pkg.all;

entity pcq_regs is
generic(expand_type             : integer := 2;       
        regmode                 : integer := 6        
);         
port(
    vdd                         : inout power_logic;
    gnd                         : inout power_logic;
    nclk                        : in    clk_logic;
    scan_dis_dc_b               : in    std_ulogic;
    lcb_clkoff_dc_b             : in    std_ulogic;
    lcb_d_mode_dc               : in    std_ulogic;
    lcb_mpw1_dc_b               : in    std_ulogic;
    lcb_mpw2_dc_b               : in    std_ulogic;
    lcb_delay_lclkr_dc          : in    std_ulogic;
    lcb_act_dis_dc              : in    std_ulogic;
    lcb_func_slp_sl_thold_0     : in    std_ulogic;
    lcb_cfg_sl_thold_0          : in    std_ulogic; 
    lcb_cfg_slp_sl_thold_0      : in    std_ulogic;
    lcb_sg_0                    : in    std_ulogic;
    ccfg_scan_in                : in    std_ulogic;
    bcfg_scan_in                : in    std_ulogic;
    dcfg_scan_in                : in    std_ulogic;
    func_scan_in                : in    std_ulogic;
    ccfg_scan_out               : out   std_ulogic;
    bcfg_scan_out               : out   std_ulogic;
    dcfg_scan_out               : out   std_ulogic;
    func_scan_out               : out   std_ulogic;
    an_ac_scom_sat_id           : in    std_ulogic_vector(0 to 3);
    an_ac_scom_dch              : in    std_ulogic;
    an_ac_scom_cch              : in    std_ulogic;
    ac_an_scom_dch              : out   std_ulogic;
    ac_an_scom_cch              : out   std_ulogic;
    ac_an_special_attn           : out   std_ulogic_vector(0 to 3);
    ac_an_checkstop              : out   std_ulogic_vector(0 to 2);
    ac_an_local_checkstop        : out   std_ulogic_vector(0 to 2);
    ac_an_recov_err              : out   std_ulogic_vector(0 to 2);
    ac_an_trace_error            : out   std_ulogic;
    an_ac_checkstop              : in    std_ulogic;
    an_ac_malf_alert             : in    std_ulogic;
    rg_ck_fast_xstop             : out   std_ulogic;
    iu_pc_err_icache_parity      : in    std_ulogic;
    iu_pc_err_icachedir_parity   : in    std_ulogic;
    iu_pc_err_icachedir_multihit : in    std_ulogic;
    iu_pc_err_ucode_illegal      : in    std_ulogic_vector(0 to 3);
    xu_pc_err_dcache_parity      : in    std_ulogic;
    xu_pc_err_dcachedir_parity   : in    std_ulogic;
    xu_pc_err_dcachedir_multihit : in    std_ulogic;
    xu_pc_err_mcsr_summary       : in    std_ulogic_vector(0 to 3);
    xu_pc_err_ierat_parity       : in    std_ulogic;
    xu_pc_err_derat_parity       : in    std_ulogic;
    xu_pc_err_tlb_parity         : in    std_ulogic;
    xu_pc_err_tlb_lru_parity     : in    std_ulogic;
    xu_pc_err_ierat_multihit     : in    std_ulogic;
    xu_pc_err_derat_multihit     : in    std_ulogic;
    xu_pc_err_tlb_multihit       : in    std_ulogic;
    xu_pc_err_ext_mchk           : in    std_ulogic;
    xu_pc_err_ditc_overrun       : in    std_ulogic;
    xu_pc_err_local_snoop_reject : in    std_ulogic;
    xu_pc_err_sprg_ecc           : in    std_ulogic_vector(0 to 3);
    xu_pc_err_sprg_ue            : in    std_ulogic_vector(0 to 3);
    xu_pc_err_regfile_parity     : in    std_ulogic_vector(0 to 3);
    xu_pc_err_regfile_ue         : in    std_ulogic_vector(0 to 3);
    xu_pc_err_llbust_attempt     : in    std_ulogic_vector(0 to 3);
    xu_pc_err_llbust_failed      : in    std_ulogic_vector(0 to 3);
    xu_pc_err_l2intrf_ecc        : in    std_ulogic;
    xu_pc_err_l2intrf_ue         : in    std_ulogic;
    xu_pc_err_l2credit_overrun   : in    std_ulogic;
    xu_pc_err_wdt_reset          : in    std_ulogic_vector(0 to 3);
    xu_pc_err_attention_instr    : in    std_ulogic_vector(0 to 3);
    xu_pc_err_debug_event        : in    std_ulogic_vector(0 to 3);
    xu_pc_err_nia_miscmpr        : in    std_ulogic_vector(0 to 3);
    xu_pc_err_invld_reld         : in    std_ulogic;
    xu_pc_err_mchk_disabled      : in    std_ulogic;
    bx_pc_err_inbox_ecc          : in    std_ulogic;
    bx_pc_err_inbox_ue           : in    std_ulogic;
    bx_pc_err_outbox_ecc         : in    std_ulogic;
    bx_pc_err_outbox_ue          : in    std_ulogic;
    fu_pc_err_regfile_parity     : in    std_ulogic_vector(0 to 3);
    fu_pc_err_regfile_ue         : in    std_ulogic_vector(0 to 3);
    pc_iu_inj_icache_parity      : out   std_ulogic;
    pc_iu_inj_icachedir_parity   : out   std_ulogic;
    pc_xu_inj_dcache_parity      : out   std_ulogic;
    pc_xu_inj_dcachedir_parity   : out   std_ulogic;
    pc_xu_inj_sprg_ecc           : out   std_ulogic_vector(0 to 3);
    pc_xu_inj_regfile_parity     : out   std_ulogic_vector(0 to 3);
    pc_fu_inj_regfile_parity     : out   std_ulogic_vector(0 to 3);
    pc_bx_inj_inbox_ecc          : out   std_ulogic;
    pc_bx_inj_outbox_ecc         : out   std_ulogic;
    pc_xu_inj_llbust_attempt     : out   std_ulogic_vector(0 to 3);
    pc_xu_inj_llbust_failed      : out   std_ulogic_vector(0 to 3);
    pc_xu_inj_wdt_reset          : out   std_ulogic_vector(0 to 3);
    pc_iu_inj_icachedir_multihit : out  std_ulogic;
    pc_xu_inj_dcachedir_multihit : out  std_ulogic;
    pc_xu_cache_par_err_event    : out   std_ulogic;
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
    pc_xu_stop                  : out   std_ulogic_vector(0 to 3); 
    pc_xu_step                  : out   std_ulogic_vector(0 to 3); 
    pc_xu_force_ude             : out   std_ulogic_vector(0 to 3);
    pc_xu_dbg_action            : out   std_ulogic_vector(0 to 11); 
    xu_pc_running               : in    std_ulogic_vector(0 to 3);  
    xu_pc_stop_dbg_event        : in    std_ulogic_vector(0 to 3);  
    xu_pc_step_done             : in    std_ulogic_vector(0 to 3);  
    ct_rg_power_managed         : in    std_ulogic_vector(0 to 3);
    ct_rg_pm_thread_stop        : in    std_ulogic_vector(0 to 3);
    ac_an_pm_thread_running     : out   std_ulogic_vector(0 to 3);
    an_ac_debug_stop            : in    std_ulogic;
    pc_xu_extirpts_dis_on_stop  : out   std_ulogic;
    pc_xu_timebase_dis_on_stop  : out   std_ulogic;
    pc_xu_decrem_dis_on_stop    : out   std_ulogic;
    ct_rg_hold_during_init      : in    std_ulogic;
    rg_ct_dis_pwr_savings       : out   std_ulogic;
    sp_rg_trace_bus_enable      : in    std_ulogic;
    rg_db_trace_bus_enable      : out   std_ulogic;
    pc_fu_trace_bus_enable      : out   std_ulogic;
    pc_bx_trace_bus_enable      : out   std_ulogic;
    pc_iu_trace_bus_enable      : out   std_ulogic;
    pc_mm_trace_bus_enable      : out   std_ulogic;
    pc_xu_trace_bus_enable      : out   std_ulogic;
    rg_db_debug_mux_ctrls       : out   std_ulogic_vector(0 to 15);
    pc_fu_debug_mux1_ctrls      : out   std_ulogic_vector(0 to 15);
    pc_bx_debug_mux1_ctrls      : out   std_ulogic_vector(0 to 15);
    pc_iu_debug_mux1_ctrls      : out   std_ulogic_vector(0 to 15);
    pc_iu_debug_mux2_ctrls      : out   std_ulogic_vector(0 to 15);
    pc_mm_debug_mux1_ctrls      : out   std_ulogic_vector(0 to 15);
    pc_xu_debug_mux1_ctrls      : out   std_ulogic_vector(0 to 15);
    pc_xu_debug_mux2_ctrls      : out   std_ulogic_vector(0 to 15);
    pc_xu_debug_mux3_ctrls      : out   std_ulogic_vector(0 to 15);
    pc_xu_debug_mux4_ctrls      : out   std_ulogic_vector(0 to 15);
    dbg_scom_rdata              : out   std_ulogic_vector(0 to 63);
    dbg_scom_wdata              : out   std_ulogic_vector(0 to 63);
    dbg_scom_decaddr            : out   std_ulogic_vector(0 to 63);
    dbg_scom_misc               : out   std_ulogic_vector(0 to 8);
    dbg_ram_thrctl              : out   std_ulogic_vector(0 to 20);
    dbg_fir0_err                : out   std_ulogic_vector(0 to 31);
    dbg_fir1_err                : out   std_ulogic_vector(0 to 30);
    dbg_fir2_err                : out   std_ulogic_vector(0 to 21);
    dbg_fir_misc                : out   std_ulogic_vector(0 to 35)
);

-- synopsys translate_off


-- synopsys translate_on
end pcq_regs;

architecture pcq_regs of pcq_regs is

constant rami_size              : positive := 32;
constant ramc_size              : positive := 20;
constant ramd_size              : positive := 64;
constant thrctl1_size           : positive := 16;
constant thrctl2_size           : positive := 12;
constant pccr0_size             : positive := 24;
constant recerrcntr_size        : positive := 4;
constant spattn_size            : positive := 4;
constant abdsr_size             : positive := 32;
constant idsr_size              : positive := 32;
constant mpdsr_size             : positive := 32;
constant xdsr1_size             : positive := 32;
constant xdsr2_size             : positive := 32;
constant errinj_size            : positive := 19;
constant parity_size            : positive := 1;
constant scom_misc_size         : positive := 6;
constant dcfg_stage1_size       : positive := 5;
constant bcfg_stage1_size       : positive := 13;
constant bcfg_stage2_size       : positive := 15;
constant func_stage1_size       : positive := 2;
constant func_stage2_size       : positive := 32;
constant func_stage3_size       : positive := 11;
constant fu_ram_din_size        : positive := 64;
constant xu_ram_din_size        : positive := 2**regmode+1;
constant abdsr_offset       : natural := 0;
constant abdsr_par_offset   : natural := abdsr_offset + abdsr_size;
constant idsr_offset        : natural := abdsr_par_offset + parity_size;
constant idsr_par_offset    : natural := idsr_offset + idsr_size;
constant mpdsr_offset       : natural := idsr_par_offset + parity_size;
constant mpdsr_par_offset   : natural := mpdsr_offset + mpdsr_size;
constant xdsr1_offset       : natural := mpdsr_par_offset + parity_size;
constant xdsr1_par_offset   : natural := xdsr1_offset + xdsr1_size;
constant xdsr2_offset       : natural := xdsr1_par_offset + parity_size;
constant xdsr2_par_offset   : natural := xdsr2_offset + xdsr2_size;
constant pccr0_offset       : natural := xdsr2_par_offset + parity_size;
constant recerrcntr_offset  : natural := pccr0_offset + pccr0_size;
constant pccr0_par_offset   : natural := recerrcntr_offset + recerrcntr_size;
constant dcfg_stage1_offset : natural := pccr0_par_offset + parity_size;
constant dcfg_right         : natural := dcfg_stage1_offset + dcfg_stage1_size - 1;
constant scommode_offset    : natural := 0;
constant thrctl1_offset     : natural := scommode_offset + 2;
constant thrctl2_offset     : natural := thrctl1_offset + thrctl1_size;
constant spattn1_offset     : natural := thrctl2_offset + thrctl2_size;
constant spattn2_offset     : natural := spattn1_offset + spattn_size;
constant spattn_par_offset  : natural := spattn2_offset + spattn_size;
constant bcfg_stage1_offset : natural := spattn_par_offset + parity_size;
constant bcfg_stage2_offset : natural := bcfg_stage1_offset + bcfg_stage1_size;
constant bcfg_right         : natural := bcfg_stage2_offset + bcfg_stage2_size - 1;
constant rami_offset        : natural := 0;
constant ramc_offset        : natural := rami_offset + rami_size;
constant ramd_offset        : natural := ramc_offset + ramc_size;
constant fu_ram_din_offset  : natural := ramd_offset + ramd_size;
constant xu_ram_din_offset  : natural := fu_ram_din_offset + fu_ram_din_size;
constant errinj_offset      : natural := xu_ram_din_offset + xu_ram_din_size;
constant sc_misc_offset     : natural := errinj_offset + errinj_size;
constant scaddr_dec_offset  : natural := sc_misc_offset + scom_misc_size;
constant func_stage1_offset : natural := scaddr_dec_offset + 64;
constant func_stage2_offset : natural := func_stage1_offset + func_stage1_size;
constant func_stage3_offset : natural := func_stage2_offset + func_stage2_size;
constant scomfunc_offset    : natural := func_stage3_offset + func_stage3_size;
constant func_right         : natural := scomfunc_offset + 177 - 1;

constant scom_width        : positive := 64;
constant use_addr        : std_ulogic_vector := "1111111111111110111111111011100000000000111111111111111110011111";
constant addr_is_rdable  : std_ulogic_vector := "1001111001100110100110011010000000000000111001111001001000011111";
constant addr_is_wrable  : std_ulogic_vector := "1111101111111110111011111011100000000000111111111111111110011111";
 
signal tidn, tiup                       : std_ulogic;
signal tidn_32                          : std_ulogic_vector(0 to 31);
signal bcfg_siv, bcfg_sov               : std_ulogic_vector(0 to bcfg_right);
signal dcfg_siv, dcfg_sov               : std_ulogic_vector(0 to dcfg_right);
signal func_siv, func_sov               : std_ulogic_vector(0 to func_right);
signal lcb_func_slp_sl_thold_0_b        : std_ulogic;
signal lcb_cfg_slp_sl_thold_0_b         : std_ulogic;
signal force_cfgslp                     : std_ulogic;
signal force_funcslp                    : std_ulogic;
signal cfgslp_d1clk                     : std_ulogic;
signal cfgslp_d2clk                     : std_ulogic;
signal cfgslp_lclk                      : clk_logic;
signal cfg_slat_force                   : std_ulogic;
signal cfg_slat_d2clk                   : std_ulogic;
signal cfg_slat_lclk                    : clk_logic;
signal cfg_slat_thold_b                 : std_ulogic;
signal scom_cch_q, scom_dch_q           : std_ulogic;
signal scom_act, scom_local_act         : std_ulogic;
signal sc_r_nw                          : std_ulogic;
signal sc_ack                           : std_ulogic;
signal sc_rdata, sc_wdata               : std_ulogic_vector(0 to 63);
signal sc_ack_info                      : std_ulogic_vector(0 to 1);
signal sc_wparity_out                   : std_ulogic;
signal sc_wparity                       : std_ulogic;
signal scom_fsm_err                     : std_ulogic;
signal scom_ack_err                     : std_ulogic;
signal scaddr_predecode                 : std_ulogic_vector(0 to 5); 
signal scaddr_dec_d                     : std_ulogic_vector(0 to 63);
signal scaddr_v                         : std_ulogic_vector(0 to 63);
signal andmask_ones                     : std_ulogic_vector(0 to 63);
signal sc_req_d, sc_req_q               : std_ulogic;
signal sc_wr_d, sc_wr_q                 : std_ulogic;
signal scaddr_v_d, scaddr_v_q           : std_ulogic_vector(0 to 63);
signal scaddr_nvld_d, scaddr_nvld_q     : std_ulogic;
signal sc_wr_nvld_d, sc_wr_nvld_q       : std_ulogic;
signal sc_rd_nvld_d, sc_rd_nvld_q       : std_ulogic;
signal ramc_instr_in                    : std_ulogic_vector(0 to 3);
signal ramc_mode_in                     : std_ulogic_vector(0 to 2);
signal ramc_force_cmplt_in              : std_ulogic;
signal ramc_force_flush_in              : std_ulogic;
signal ramc_msr_de_ovrid_in             : std_ulogic;
signal ramc_spare_in                    : std_ulogic_vector(0 to 2);
signal ramc_msr_ovrid_in                : std_ulogic_vector(0 to 2);
signal ramc_execute_in                  : std_ulogic;
signal ramc_status_in                   : std_ulogic_vector(0 to 2);
signal or_ramc_load                     : std_ulogic;
signal and_ramc_ones                    : std_ulogic;
signal and_ramc_load                    : std_ulogic;
signal or_ramc                          : std_ulogic_vector(0 to 63);
signal and_ramc                         : std_ulogic_vector(0 to 63);
signal rami_d, rami_q                   : std_ulogic_vector(0 to rami_size-1);
signal rami_out                         : std_ulogic_vector(0 to 63);
signal ramc_d, ramc_q                   : std_ulogic_vector(0 to ramc_size-1);
signal ramc_out                         : std_ulogic_vector(0 to 63);
signal ramic_out                        : std_ulogic_vector(0 to 63);
signal ramd_d, ramd_q                   : std_ulogic_vector(0 to ramd_size-1);
signal ramdh_out, ramdl_out             : std_ulogic_vector(0 to 63);
signal rg_rg_ram_mode                   : std_ulogic;
signal ramd_xu_load_zeros               : std_ulogic_vector(0 to 64-(2**regmode));
signal xu_ramd_load_data_d              : std_ulogic_vector(0 to 64);
signal xu_ramd_load_data_q              : std_ulogic_vector(0 to 64);
signal xu_ramd_load_data                : std_ulogic_vector(0 to 63);
signal fu_ramd_load_data_d              : std_ulogic_vector(0 to 63);
signal fu_ramd_load_data_q              : std_ulogic_vector(0 to 63);
signal xu_ram_done_q                    : std_ulogic;
signal fu_ram_done_q                    : std_ulogic;
signal ram_mode_d, ram_mode_q           : std_ulogic;
signal ram_execute_d, ram_execute_q     : std_ulogic;
signal ram_thread_d, ram_thread_q       : std_ulogic_vector(0 to 1);
signal ram_msrovren_d, ram_msrovren_q   : std_ulogic;
signal ram_msrovrpr_d, ram_msrovrpr_q   : std_ulogic;
signal ram_msrovrgs_d, ram_msrovrgs_q   : std_ulogic;
signal ram_msrovrde_d, ram_msrovrde_q   : std_ulogic;
signal ram_force_d, ram_force_q         : std_ulogic;
signal ram_flush_d, ram_flush_q         : std_ulogic;
signal or_thrctl_load                   : std_ulogic;
signal and_thrctl_ones                  : std_ulogic;
signal and_thrctl_load                  : std_ulogic;
signal or_thrctl                        : std_ulogic_vector(0 to 63);
signal and_thrctl                       : std_ulogic_vector(0 to 63);
signal thrctl_out                       : std_ulogic_vector(0 to 63);
signal thrctl1_d, thrctl1_q             : std_ulogic_vector(0 to thrctl1_size-1);
signal thrctl2_d, thrctl2_q             : std_ulogic_vector(0 to thrctl2_size-1);
signal thrctl_stop_in                   : std_ulogic_vector(0 to 3);
signal thrctl_step_in                   : std_ulogic_vector(0 to 3);
signal thrctl_run_in                    : std_ulogic_vector(0 to 3);
signal thrctl_pm_in                     : std_ulogic_vector(0 to 3);
signal thrctl_misc_dbg_in               : std_ulogic_vector(0 to 6);
signal thrctl_spare_in                  : std_ulogic_vector(0 to 4);
signal tx_stop_d, tx_stop_q             : std_ulogic_vector(0 to 3);
signal tx_step_d, tx_step_q             : std_ulogic_vector(0 to 3);
signal tx_ude_d, tx_ude_q               : std_ulogic_vector(0 to 3);
signal ude_dly_d, ude_dly_q             : std_ulogic_vector(0 to 3);
signal force_ude_pulse                  : std_ulogic_vector(0 to 3);
signal extirpts_dis_d, extirpts_dis_q   : std_ulogic;
signal timebase_dis_d, timebase_dis_q   : std_ulogic;
signal decrem_dis_d, decrem_dis_q       : std_ulogic;
signal ext_debug_stop_q                 : std_ulogic;
signal external_debug_stop              : std_ulogic_vector(0 to 3);
signal stop_dbg_event_q                 : std_ulogic_vector(0 to 3);  
signal step_done_q                      : std_ulogic_vector(0 to 3);  
signal or_pccr0_load                    : std_ulogic;
signal and_pccr0_ones                   : std_ulogic;
signal and_pccr0_load                   : std_ulogic;
signal or_pccr0                         : std_ulogic_vector(0 to 63);
signal and_pccr0                        : std_ulogic_vector(0 to 63);
signal pccr0_out                        : std_ulogic_vector(0 to 63);
signal pccr0_par_err                    : std_ulogic;
signal pccr0_par_in                     : std_ulogic_vector(0 to pccr0_size+4-1);
signal pccr0_d, pccr0_q                 : std_ulogic_vector(0 to pccr0_size-1);
signal pccr0_par_d, pccr0_par_q         : std_ulogic_vector(0 to 0);
signal debug_mode_d, debug_mode_q       : std_ulogic;
signal debug_mode_act                   : std_ulogic;
signal trace_bus_enable_d               : std_ulogic;
signal trace_bus_enable_q               : std_ulogic;
signal ram_enab_d, ram_enab_q           : std_ulogic;
signal ram_enab_act                     : std_ulogic;
signal ram_enab_scom_act                : std_ulogic;
signal errinj_enab_d, errinj_enab_q     : std_ulogic;
signal errinj_enab_act                  : std_ulogic;
signal errinj_enab_scom_act             : std_ulogic;
signal rg_rg_xstop_report_ovride        : std_ulogic;
signal rg_rg_fast_xstop_enable          : std_ulogic;
signal rg_rg_maxRecErrCntrValue         : std_ulogic;
signal rg_rg_gateRecErrCntr             : std_ulogic;
signal recErrCntr_pargen                : std_ulogic;
signal incr_recErrCntr                  : std_ulogic_vector(0 to 3);
signal recErrCntr_in                    : std_ulogic_vector(0 to 3);
signal recErrCntr_q                     : std_ulogic_vector(0 to 3);
signal pccr0_pervModes_in               : std_ulogic_vector(0 to 6);
signal pccr0_spare_in                   : std_ulogic_vector(0 to 4);
signal pccr0_dbgActSel_in               : std_ulogic_vector(0 to 11);
signal or_spattn_load                   : std_ulogic;
signal and_spattn_ones                  : std_ulogic;
signal and_spattn_load                  : std_ulogic;
signal or_spattn                        : std_ulogic_vector(0 to 63);
signal and_spattn                       : std_ulogic_vector(0 to 63);
signal spattn_out                       : std_ulogic_vector(0 to 63);
signal spattn_par_err                   : std_ulogic;
signal spattn_par_d, spattn_par_q       : std_ulogic_vector(0 to 0);
signal spattn_data_d, spattn_data_q     : std_ulogic_vector(0 to spattn_size-1);
signal spattn_mask_d, spattn_mask_q     : std_ulogic_vector(0 to spattn_size-1);
signal spattn_unused                    : std_ulogic_vector(spattn_size to 15);
signal spattn_attn_instr_in             : std_ulogic_vector(0 to 3);
signal spattn_out_masked                : std_ulogic_vector(0 to spattn_size-1);
signal abdsr_data_in                    : std_ulogic_vector(0 to abdsr_size-1);
signal abdsr_out                        : std_ulogic_vector(0 to 63);
signal abdsr_par_err                    : std_ulogic;
signal abdsr_d, abdsr_q                 : std_ulogic_vector(0 to abdsr_size-1);
signal abdsr_par_d, abdsr_par_q         : std_ulogic_vector(0 to 0);
signal idsr_data_in                     : std_ulogic_vector(0 to idsr_size-1);
signal idsr_out                         : std_ulogic_vector(0 to 63);
signal idsr_par_err                     : std_ulogic;
signal idsr_d, idsr_q                   : std_ulogic_vector(0 to idsr_size-1);
signal idsr_par_d, idsr_par_q           : std_ulogic_vector(0 to 0);
signal mpdsr_data_in                    : std_ulogic_vector(0 to mpdsr_size-1);
signal mpdsr_out                        : std_ulogic_vector(0 to 63);
signal mpdsr_par_err                    : std_ulogic;
signal mpdsr_d, mpdsr_q                 : std_ulogic_vector(0 to mpdsr_size-1);
signal mpdsr_par_d, mpdsr_par_q         : std_ulogic_vector(0 to 0);
signal xdsr1_data_in                    : std_ulogic_vector(0 to xdsr1_size-1);
signal xdsr1_out                        : std_ulogic_vector(0 to 63);
signal xdsr1_par_err_d                  : std_ulogic;
signal xdsr1_par_err_q                  : std_ulogic;
signal xdsr1_d, xdsr1_q                 : std_ulogic_vector(0 to xdsr1_size-1);
signal xdsr1_par_d, xdsr1_par_q         : std_ulogic_vector(0 to 0);
signal xdsr2_data_in                    : std_ulogic_vector(0 to xdsr2_size-1);
signal xdsr2_out                        : std_ulogic_vector(0 to 63);
signal xdsr2_par_err                    : std_ulogic;
signal xdsr2_d, xdsr2_q                 : std_ulogic_vector(0 to xdsr2_size-1);
signal xdsr2_par_d, xdsr2_par_q         : std_ulogic_vector(0 to 0);
signal errinj_out                       : std_ulogic_vector(0 to 63);
signal errinj_thread_in                 : std_ulogic_vector(0 to 3);
signal errinj_errtype_in                : std_ulogic_vector(0 to 14);
signal errinj_d, errinj_q               : std_ulogic_vector(0 to errinj_size-1);
signal attn_instr_int                   : std_ulogic_vector(0 to 3);
signal rg_rg_ram_mode_xstop             : std_ulogic;
signal rg_rg_xstop_err                  : std_ulogic_vector(0 to 3);
signal rg_rg_any_fir_xstop              : std_ulogic;
signal scom_reg_par_checks              : std_ulogic_vector(0 to 6);
signal scaddr_fir                       : std_ulogic;
signal fir_func_si, fir_func_so         : std_ulogic;
signal fir_mode_si, fir_mode_so         : std_ulogic;
signal fir_data_out                     : std_ulogic_vector(0 to 63);
signal rg_rg_errinj_shutoff             : std_ulogic_vector(0 to 14);
signal sc_parity_error_inject           : std_ulogic;
signal inj_icache_parity_d              : std_ulogic;
signal inj_icache_parity_q              : std_ulogic;
signal inj_icachedir_parity_d           : std_ulogic;
signal inj_icachedir_parity_q           : std_ulogic;
signal inj_dcache_parity_d              : std_ulogic;
signal inj_dcache_parity_q              : std_ulogic;
signal inj_dcachedir_parity_d           : std_ulogic;
signal inj_dcachedir_parity_q           : std_ulogic;
signal inj_xuregfile_parity_d           : std_ulogic_vector(0 to 3);
signal inj_xuregfile_parity_q           : std_ulogic_vector(0 to 3);
signal inj_furegfile_parity_d           : std_ulogic_vector(0 to 3);
signal inj_furegfile_parity_q           : std_ulogic_vector(0 to 3);
signal inj_icachedir_multihit_d         : std_ulogic;
signal inj_icachedir_multihit_q         : std_ulogic;
signal inj_dcachedir_multihit_d         : std_ulogic;
signal inj_dcachedir_multihit_q         : std_ulogic;
signal inj_sprg_ecc_d                   : std_ulogic_vector(0 to 3);
signal inj_sprg_ecc_q                   : std_ulogic_vector(0 to 3);
signal inj_inbox_ecc_d                  : std_ulogic;
signal inj_inbox_ecc_q                  : std_ulogic;
signal inj_outbox_ecc_d                 : std_ulogic;
signal inj_outbox_ecc_q                 : std_ulogic;
signal inj_llbust_attempt_d             : std_ulogic_vector(0 to 3);
signal inj_llbust_attempt_q             : std_ulogic_vector(0 to 3);
signal inj_llbust_failed_d              : std_ulogic_vector(0 to 3);
signal inj_llbust_failed_q              : std_ulogic_vector(0 to 3);
signal inj_wdt_reset_d                  : std_ulogic_vector(0 to 3);
signal inj_wdt_reset_q                  : std_ulogic_vector(0 to 3);
signal unused_signals                   : std_ulogic;




begin


  tidn <= '0';
  tidn_32 <= (others => '0');
  tiup <= '1';

unused_signals  <= or_reduce(or_ramc(0 to 31)    & or_ramc(36 to 43)    & or_ramc(56 to 60)    & 
                             and_ramc(0 to 31)   & and_ramc(36 to 43)   & and_ramc(47)         &
                             and_ramc(52)        & and_ramc(56 to 60)   &
                             or_thrctl(0 to 31)  & or_thrctl(40 to 47)  & or_thrctl(60 to 63)  &
                             and_thrctl(0 to 31) & and_thrctl(40 to 47) & and_thrctl(60 to 63) & 
                             or_pccr0(0 to 31)   & or_pccr0(44 to 51)   &
                             and_pccr0(0 to 31)  & and_pccr0(44 to 51)  & 
                             or_spattn(0 to 31)  & or_spattn(36 to 47)  & or_spattn(52 to 63)  &
                             and_spattn(0 to 31) & and_spattn(36 to 47) & and_spattn(52 to 63) &
                             xu_ramd_load_data_q(0));
                               


  scomsat: entity tri.tri_serial_scom2
      generic map(width                 => scom_width,
                  internal_addr_decode  => false,
                  pipeline_paritychk    => false,
                  expand_type           => expand_type )
      port map( 
                nclk                    => nclk
              , vd                      => vdd
              , gd                      => gnd
              , scom_func_thold         => lcb_func_slp_sl_thold_0
              , sg                      => lcb_sg_0
              , act_dis_dc              => lcb_act_dis_dc
              , clkoff_dc_b             => lcb_clkoff_dc_b
              , mpw1_dc_b               => lcb_mpw1_dc_b
              , mpw2_dc_b               => lcb_mpw2_dc_b
              , d_mode_dc               => lcb_d_mode_dc
              , delay_lclkr_dc          => lcb_delay_lclkr_dc
              , func_scan_in  => func_siv(scomfunc_offset to scomfunc_offset + scom_width+2*((scom_width-1)/16+1)+104)
              , func_scan_out => func_sov(scomfunc_offset to scomfunc_offset + scom_width+2*((scom_width-1)/16+1)+104)
              , dcfg_scan_dclk          => cfg_slat_d2clk
              , dcfg_scan_lclk          => cfg_slat_lclk
              , dcfg_d1clk              => cfgslp_d1clk
              , dcfg_d2clk              => cfgslp_d2clk
              , dcfg_lclk               => cfgslp_lclk
              , dcfg_scan_in            => bcfg_siv(scommode_offset to scommode_offset + 1)
              , dcfg_scan_out           => bcfg_sov(scommode_offset to scommode_offset + 1)
              , scom_local_act          => scom_local_act
              , sat_id                  => an_ac_scom_sat_id
              , scom_dch_in             => scom_dch_q
              , scom_cch_in             => scom_cch_q 
              , scom_dch_out            => ac_an_scom_dch
              , scom_cch_out            => ac_an_scom_cch
              , sc_req                  => sc_req_d          
              , sc_ack                  => sc_ack   
              , sc_ack_info             => sc_ack_info
              , sc_r_nw                 => sc_r_nw           
              , sc_addr                 => scaddr_predecode
              , sc_rdata                => sc_rdata
              , sc_wdata                => sc_wdata
              , sc_wparity              => sc_wparity_out
              , scom_err                => scom_fsm_err
              , fsm_reset               => tidn
              );


   scaddr:  entity clib.c_scom_addr_decode
      generic map( use_addr       => use_addr
                 , addr_is_rdable => addr_is_rdable
                 , addr_is_wrable => addr_is_wrable
                 )
      port map( sc_addr     => scaddr_predecode 
              , scaddr_dec  => scaddr_dec_d     
              , sc_req      => sc_req_d         
              , sc_r_nw     => sc_r_nw          
              , scaddr_nvld => scaddr_nvld_d    
              , sc_wr_nvld  => sc_wr_nvld_d     
              , sc_rd_nvld  => sc_rd_nvld_d     
              , vd          => vdd
              , gd          => gnd
              );

  scom_act     <= sc_req_d or sc_req_q or scom_local_act;

  sc_wr_d      <= not sc_r_nw;

  scaddr_v_d   <= gate_and(sc_req_d, scaddr_dec_d);
  scaddr_v     <= scaddr_v_q;

  sc_ack       <= (sc_req_d and not sc_r_nw) or (sc_req_q and sc_r_nw);

  sc_ack_info  <= gate_and(not sc_r_nw, (sc_wr_nvld_d or sc_rd_nvld_d) & scaddr_nvld_d) or
                  gate_and(sc_r_nw,     (sc_wr_nvld_q or sc_rd_nvld_q) & scaddr_nvld_q) ;

  scom_ack_err <= or_reduce(sc_ack_info);

  sc_wparity   <= sc_wparity_out xor sc_parity_error_inject;

  
   andmask_ones  <= (others => '1');


   rami_d(0 to 31)  <= sc_wdata(0 to 31)  when (scaddr_v(40) and sc_wr_q) = '1' else
                       sc_wdata(32 to 63) when (scaddr_v(41) and sc_wr_q) = '1' else
                       rami_q(0 to 31);

   rami_out  <= tidn_32 & rami_q(0 to 31);

   ramic_out <= rami_out(32 to 63) & ramc_out(32 to 63);



   or_ramc_load  <=      (scaddr_v(40) or scaddr_v(42) or scaddr_v(44)) and sc_wr_q;
   and_ramc_ones <=  not((scaddr_v(40) or scaddr_v(42) or scaddr_v(43)) and sc_wr_q);
   and_ramc_load <=                                       scaddr_v(43)  and sc_wr_q;

   or_ramc  <= gate_and(or_ramc_load, sc_wdata);
   and_ramc <= gate_and(and_ramc_load, sc_wdata) or gate_and(and_ramc_ones, andmask_ones);


   ramc_instr_in <= or_ramc(32 to 35) or (ramc_out(32 to 35) and and_ramc(32 to 35));

   ramc_mode_in <= or_ramc(44 to 46) or (ramc_out(44 to 46) and and_ramc(44 to 46));

   ramc_execute_in <= or_ramc(47);

   ramc_msr_ovrid_in <= or_ramc(48 to 50) or (ramc_out(48 to 50) and and_ramc(48 to 50));

   ramc_force_cmplt_in <= or_ramc(51) or (ramc_out(51) and and_ramc(51));

   ramc_force_flush_in <= or_ramc(52);

   ramc_msr_de_ovrid_in <= or_ramc(53) or (ramc_out(53) and and_ramc(53));

   ramc_spare_in <= or_ramc(54 to 56) or (ramc_out(54 to 56) and and_ramc(54 to 56));

   ramc_status_in(0) <= xu_pc_ram_interrupt or or_ramc(61) or (ramc_out(61) and and_ramc(61));

   ramc_status_in(1) <= rg_rg_ram_mode_xstop or or_ramc(62) or (ramc_out(62) and and_ramc(62));

   ramc_status_in(2) <= xu_ram_done_q or fu_ram_done_q or or_ramc(63) or
                        (ramc_out(63) and and_ramc(63) and not ramc_out(47));


   ramc_d   <= ramc_instr_in & ramc_mode_in & ramc_execute_in & ramc_msr_ovrid_in & ramc_force_cmplt_in & 
               ramc_force_flush_in & ramc_msr_de_ovrid_in & ramc_spare_in & ramc_status_in;

   ramc_out <= tidn_32 & ramc_q(0 to 3) & x"00" & ramc_q(4 to 7) & ramc_q(8 to 13) &
               ramc_q(14 to 16) & "0000" & ramc_q(17 to 19);




   fu_ramd_load_data_d  <=  fu_pc_ram_data(0 to 63);

   ramd_xu_load_zeros(0 to 64-(2**regmode)) <= (others => '0');
   xu_ramd_load_data_d(0 to 64) <= ramd_xu_load_zeros & xu_pc_ram_data(64-(2**regmode) to 63);
   xu_ramd_load_data(0 to 63)   <= xu_ramd_load_data_q(1 to 64);

   ramd_d(0 to 31)  <= sc_wdata(0 to 31)            when (scaddr_v(45) and sc_wr_q) = '1' else
                       sc_wdata(32 to 63)           when (scaddr_v(46) and sc_wr_q) = '1' else
                       fu_ramd_load_data_q(0 to 31) when  fu_ram_done_q = '1'             else
                       xu_ramd_load_data(0 to 31)   when  xu_ram_done_q = '1'             else
                       ramd_q(0 to 31);

   ramd_d(32 to 63) <= sc_wdata(32 to 63)            when (scaddr_v(45) and sc_wr_q) = '1' else
                       sc_wdata(32 to 63)            when (scaddr_v(47) and sc_wr_q) = '1' else
                       fu_ramd_load_data_q(32 to 63) when fu_ram_done_q = '1'              else
                       xu_ramd_load_data(32 to 63)   when xu_ram_done_q = '1'              else
                       ramd_q(32 to 63);

   ramdh_out  <= tidn_32 & ramd_q(0 to 31);

   ramdl_out  <= tidn_32 & ramd_q(32 to 63);



   or_thrctl_load  <=      (scaddr_v(48) or scaddr_v(50)) and sc_wr_q;
   and_thrctl_ones <=  not((scaddr_v(48) or scaddr_v(49)) and sc_wr_q);
   and_thrctl_load <=                       scaddr_v(49)  and sc_wr_q;

   or_thrctl  <= gate_and(or_thrctl_load, sc_wdata);
   and_thrctl <= gate_and(and_thrctl_load, sc_wdata) or gate_and(and_thrctl_ones, andmask_ones);


   thrctl_stop_in  <= stop_dbg_event_q(0 to 3)  or  attn_instr_int(0 to 3)  or 
                      rg_rg_xstop_err(0 to 3)   or    
                      or_thrctl(32 to 35) or (thrctl_out(32 to 35) and and_thrctl(32 to 35)) ;

   thrctl_step_in  <= or_thrctl(36 to 39) or
                      (thrctl_out(36 to 39) and and_thrctl(36 to 39) and not step_done_q(0 to 3));

   thrctl_run_in  <= xu_pc_running(0 to 3);

   thrctl_pm_in  <= ct_rg_power_managed(0 to 3) or ct_rg_pm_thread_stop(0 to 3);

   thrctl_misc_dbg_in  <= or_thrctl(48 to 54) or (thrctl_out(48 to 54) and and_thrctl(48 to 54));

   thrctl_spare_in  <= or_thrctl(55 to 59) or (thrctl_out(55 to 59) and and_thrctl(55 to 59));


   thrctl1_d  <= thrctl_stop_in & thrctl_step_in & thrctl_run_in & thrctl_pm_in;
   thrctl2_d  <= thrctl_misc_dbg_in & thrctl_spare_in;
 
   thrctl_out <= tidn_32 & thrctl1_q(0 to 3) & thrctl1_q(4 to 7) & thrctl1_q(8 to 11) &   
                 thrctl1_q(12 to 15) & thrctl2_q(0 to 6) & thrctl2_q(7 to 11) & x"0";



   or_pccr0_load  <=      (scaddr_v(51) or scaddr_v(53)) and sc_wr_q;
   and_pccr0_ones <=  not((scaddr_v(51) or scaddr_v(52)) and sc_wr_q);
   and_pccr0_load <=                       scaddr_v(52)  and sc_wr_q;

   or_pccr0  <= gate_and(or_pccr0_load, sc_wdata);
   and_pccr0 <= gate_and(and_pccr0_load, sc_wdata) or gate_and(and_pccr0_ones, andmask_ones);


   pccr0_pervModes_in  <= or_pccr0(32 to 38) or (pccr0_out(32 to 38) and and_pccr0(32 to 38));

   pccr0_spare_in  <= or_pccr0(39 to 43) or (pccr0_out(39 to 43) and and_pccr0(39 to 43));


   incr_recErrCntr     <=  recErrCntr_q(0 to 3) + "0001";
   recErrCntr_pargen   <=  xor_reduce(incr_recErrCntr & pccr0_out(32 to 43) & pccr0_out(52 to 63));

   recErrCntr_in       <=  sc_wdata(48 to 51) when (scaddr_v(51) and sc_wr_q) = '1' else
                           incr_recErrCntr    when  rg_rg_gateRecErrCntr = '1'      else
                           recErrCntr_q(0 to 3);
 

   pccr0_dbgActSel_in  <= or_pccr0(52 to 63) or (pccr0_out(52 to 63) and and_pccr0(52 to 63));


   pccr0_d      <=  pccr0_pervModes_in & pccr0_spare_in & pccr0_dbgActSel_in;

   pccr0_out    <=  tidn_32 & pccr0_q(0 to 11) & x"0" & recErrCntr_q & pccr0_q(12 to pccr0_size-1);

   pccr0_par_in   <= pccr0_d & recErrCntr_in(0 to 3);
   pccr0_par_d(0) <= parity_gen_even(pccr0_par_in) when (gate_and(sc_wr_q, or_reduce(scaddr_v(51 to 53))))='1' else
                     recErrCntr_pargen   when  rg_rg_gateRecErrCntr = '1'      else
                     pccr0_par_q(0);

   pccr0_par_err  <= (xor_reduce(pccr0_out) xor pccr0_par_q(0))  or
                     (sc_wr_q and or_reduce(scaddr_v(51 to 53)) and sc_parity_error_inject);




   or_spattn_load  <=      (scaddr_v(54) or scaddr_v(56)) and sc_wr_q;
   and_spattn_ones <=  not((scaddr_v(54) or scaddr_v(55)) and sc_wr_q);
   and_spattn_load <=                       scaddr_v(55)  and sc_wr_q;

   or_spattn  <= gate_and(or_spattn_load, sc_wdata);
   and_spattn <= gate_and(and_spattn_load, sc_wdata) or gate_and(and_spattn_ones, andmask_ones);

   spattn_unused    <= (others => '0');


   spattn_attn_instr_in  <= attn_instr_int(0 to 3)  or  or_spattn(32 to 35)  or 
                            (spattn_out(32 to 35)  and  and_spattn(32 to 35)) ;



   spattn_data_d   <= spattn_attn_instr_in;


   spattn_mask_d <= or_spattn(48 to (48 + spattn_size-1))   or
                   (spattn_out(48 to (48 + spattn_size-1)) and and_spattn(48 to (48 + spattn_size-1)));
 
   spattn_out <= tidn_32 & spattn_data_q & spattn_unused & spattn_mask_q & spattn_unused ;    


   spattn_par_d(0) <= parity_gen_even(spattn_mask_d) when (gate_and(sc_wr_q, or_reduce(scaddr_v(54 to 56))))='1' else
                      spattn_par_q(0);

   spattn_par_err  <= (xor_reduce(spattn_mask_q) xor spattn_par_q(0))  or
                      (sc_wr_q and or_reduce(scaddr_v(54 to 56)) and sc_parity_error_inject);



   abdsr_data_in <= sc_wdata(32 to 63) when (scaddr_v(59) and sc_wr_q) = '1' else abdsr_out(32 to 63);
   abdsr_d       <= abdsr_data_in;
   abdsr_out <= tidn_32 & abdsr_q(0 to 31);
   abdsr_par_d(0) <= sc_wparity when (scaddr_v(59) and sc_wr_q) = '1' else  abdsr_par_q(0);
   abdsr_par_err  <= xor_reduce(abdsr_q) xor abdsr_par_q(0);


   idsr_data_in <= sc_wdata(32 to 63) when (scaddr_v(60) and sc_wr_q) = '1' else idsr_out(32 to 63);
   idsr_d       <= idsr_data_in;
   idsr_out <= tidn_32 & idsr_q(0 to 31);
   idsr_par_d(0) <= sc_wparity when (scaddr_v(60) and sc_wr_q) = '1' else  idsr_par_q(0);
   idsr_par_err  <= xor_reduce(idsr_q) xor idsr_par_q(0);


   mpdsr_data_in <= sc_wdata(32 to 63) when (scaddr_v(61) and sc_wr_q) = '1' else mpdsr_out(32 to 63);
   mpdsr_d       <= mpdsr_data_in;
   mpdsr_out <= tidn_32 & mpdsr_q(0 to 31);
   mpdsr_par_d(0) <= sc_wparity when (scaddr_v(61) and sc_wr_q) = '1' else  mpdsr_par_q(0);
   mpdsr_par_err  <= xor_reduce(mpdsr_q) xor mpdsr_par_q(0);


   xdsr1_data_in <= sc_wdata(32 to 63) when (scaddr_v(62) and sc_wr_q) = '1' else xdsr1_out(32 to 63);
   xdsr1_d       <= xdsr1_data_in;
   xdsr1_out <= tidn_32 & xdsr1_q(0 to 31);
   xdsr1_par_d(0)  <= sc_wparity when (scaddr_v(62) and sc_wr_q) = '1' else  xdsr1_par_q(0);
   xdsr1_par_err_d <= xor_reduce(xdsr1_q) xor xdsr1_par_q(0);


   xdsr2_data_in <= sc_wdata(32 to 63) when (scaddr_v(63) and sc_wr_q) = '1' else xdsr2_out(32 to 63);
   xdsr2_d       <= xdsr2_data_in;
   xdsr2_out <= tidn_32 & xdsr2_q(0 to 31);
   xdsr2_par_d(0) <= sc_wparity when (scaddr_v(63) and sc_wr_q) = '1' else  xdsr2_par_q(0);
   xdsr2_par_err  <= xor_reduce(xdsr2_q) xor xdsr2_par_q(0);


   errinj_thread_in  <=  sc_wdata(32 to 35) when (scaddr_v(9) and sc_wr_q) = '1' else
                         errinj_out(32 to 35);

   errinj_errtype_in <=  sc_wdata(40 to 54)  when (scaddr_v(9) and sc_wr_q) = '1' else 
                         (errinj_out(40 to 54) and not rg_rg_errinj_shutoff);

   errinj_d <= errinj_thread_in & errinj_errtype_in;

   errinj_out <= tidn_32 & errinj_q(0 to 3) & "0000" & errinj_q(4 to 18) & (55 to 63 => '0');


   scaddr_fir <= scaddr_v(0)  or scaddr_v(3)  or scaddr_v(4)  or scaddr_v(6)  or
                 scaddr_v(5)  or scaddr_v(19) or    
                 scaddr_v(10) or scaddr_v(13) or scaddr_v(14) or scaddr_v(16) or
                 scaddr_v(20) or scaddr_v(23) or scaddr_v(24) or scaddr_v(26);

   sc_rdata <=  gate_and(scaddr_v(40), ramic_out)        or
                gate_and(scaddr_v(41), rami_out)         or
                gate_and(scaddr_v(42), ramc_out)         or
                gate_and(scaddr_v(45), ramd_q(0 to 63))  or 
                gate_and(scaddr_v(46), ramdh_out)        or 
                gate_and(scaddr_v(47), ramdl_out)        or 
                gate_and(scaddr_v(48), thrctl_out)       or
                gate_and(scaddr_v(51), pccr0_out)        or 
                gate_and(scaddr_v(54), spattn_out)       or 
                gate_and(scaddr_v(59), abdsr_out)        or
                gate_and(scaddr_v(60), idsr_out)         or
                gate_and(scaddr_v(61), mpdsr_out)        or
                gate_and(scaddr_v(62), xdsr1_out)        or
                gate_and(scaddr_v(63), xdsr2_out)        or
                gate_and(scaddr_v(9),  errinj_out)       or 
                gate_and(scaddr_fir,   fir_data_out)     ;
                


   ram_mode_d     <= ram_enab_d and ramc_out(44);
   ram_execute_d  <= ram_mode_d and ramc_out(47);
   ram_thread_d   <= ramc_out(45 to 46);

   pc_iu_ram_instr     <= rami_out(32 to 63);
   pc_iu_ram_instr_ext <= ramc_out(32 to 35);
   pc_iu_ram_mode      <= ram_mode_q;
   pc_iu_ram_thread    <= ram_thread_q(0 to 1);

   pc_xu_ram_mode      <= ram_mode_q;
   pc_xu_ram_thread    <= ram_thread_q(0 to 1);
   pc_xu_ram_execute   <= ram_execute_q;

   pc_fu_ram_mode      <= ram_mode_q;
   pc_fu_ram_thread    <= ram_thread_q(0 to 1);

   rg_rg_ram_mode      <= ram_mode_q;


   ram_msrovren_d         <= ram_mode_d and ramc_out(48);
   pc_xu_msrovride_enab   <= ram_msrovren_q;

   ram_msrovrpr_d         <= ram_mode_d and ramc_out(49);
   pc_xu_msrovride_pr     <= ram_msrovrpr_q;

   ram_msrovrgs_d         <= ram_mode_d and ramc_out(50);
   pc_xu_msrovride_gs     <= ram_msrovrgs_q;

   ram_force_d            <= ram_mode_d and ramc_out(51);
   pc_iu_ram_force_cmplt  <= ram_force_q;

   ram_flush_d            <= ram_enab_d and ramc_out(52);
   pc_xu_ram_flush_thread <= ram_flush_q;

   ram_msrovrde_d         <= ram_mode_d and ramc_out(53);
   pc_xu_msrovride_de     <= ram_msrovrde_q;

   external_debug_stop <= gate_and(pccr0_out(35), (0 to 3=> ext_debug_stop_q));

   tx_stop_d   <= ct_rg_pm_thread_stop  or  external_debug_stop  or 
                  (0 to 3 => ct_rg_hold_during_init)  or
                  (thrctl_out(32 to 35) and not tx_step_d(0 to 3));
   pc_xu_stop  <= tx_stop_q(0 to 3);

   tx_step_d   <= gate_and(debug_mode_d,  thrctl_out(36 to 39));
   pc_xu_step  <= tx_step_q(0 to 3);

   ac_an_pm_thread_running     <= thrctl_out(40 to 43);

   ude_dly_d(0 to 3)           <= thrctl_out(48 to 51);
   force_ude_pulse(0 to 3)     <= thrctl_out(48 to 51) and not ude_dly_q(0 to 3); 
   tx_ude_d                    <= gate_and(debug_mode_d, force_ude_pulse(0 to 3));
   pc_xu_force_ude             <= tx_ude_q(0 to 3);       

   extirpts_dis_d              <= debug_mode_d and thrctl_out(52);
   pc_xu_extirpts_dis_on_stop  <= extirpts_dis_q;

   timebase_dis_d              <= debug_mode_d and thrctl_out(53);
   pc_xu_timebase_dis_on_stop  <= timebase_dis_q;

   decrem_dis_d                <= debug_mode_d and thrctl_out(54);
   pc_xu_decrem_dis_on_stop    <= decrem_dis_q;

   trace_bus_enable_d      <= pccr0_out(32) or sp_rg_trace_bus_enable;

   pc_fu_trace_bus_enable  <= trace_bus_enable_q;      
   pc_bx_trace_bus_enable  <= trace_bus_enable_q;      
   pc_iu_trace_bus_enable  <= trace_bus_enable_q;
   pc_mm_trace_bus_enable  <= trace_bus_enable_q;
   pc_xu_trace_bus_enable  <= trace_bus_enable_q;
   rg_db_trace_bus_enable  <= trace_bus_enable_q;

   debug_mode_d         <= pccr0_out(32);
   debug_mode_act       <= debug_mode_d or debug_mode_q; 

   ram_enab_d           <= pccr0_out(33);
   ram_enab_act         <= ram_enab_d or ram_enab_q;
   ram_enab_scom_act    <= ram_enab_act or scom_act;

   errinj_enab_d        <= pccr0_out(34);
   errinj_enab_act      <= errinj_enab_d or errinj_enab_q;
   errinj_enab_scom_act <= errinj_enab_act or scom_act;

   rg_rg_xstop_report_ovride <= pccr0_out(36);

   rg_rg_fast_xstop_enable   <= debug_mode_d and pccr0_out(37);

   rg_ct_dis_pwr_savings     <= pccr0_out(38);


   rg_rg_maxRecErrCntrValue  <= and_reduce(recErrCntr_q(0 to 3));

   pc_xu_dbg_action <= pccr0_out(52 to 63); 


  spattn_out_masked  <=  spattn_data_q and not spattn_mask_q ;

  ac_an_special_attn(0) <= spattn_out_masked(0);
  ac_an_special_attn(1) <= spattn_out_masked(1);
  ac_an_special_attn(2) <= spattn_out_masked(2);
  ac_an_special_attn(3) <= spattn_out_masked(3);

   pc_fu_debug_mux1_ctrls  <= abdsr_out(32 to 47);
   pc_bx_debug_mux1_ctrls  <= abdsr_out(48 to 63);

   pc_mm_debug_mux1_ctrls  <= mpdsr_out(32 to 47);
   rg_db_debug_mux_ctrls   <= mpdsr_out(48 to 63);

   pc_iu_debug_mux1_ctrls  <= idsr_out(32 to 47);
   pc_iu_debug_mux2_ctrls  <= idsr_out(48 to 63);

   pc_xu_debug_mux1_ctrls  <= xdsr1_out(32 to 47);
   pc_xu_debug_mux2_ctrls  <= xdsr1_out(48 to 63);
   pc_xu_debug_mux3_ctrls  <= xdsr2_out(32 to 47);
   pc_xu_debug_mux4_ctrls  <= xdsr2_out(48 to 63);

   inj_icache_parity_d            <= errinj_enab_d and errinj_out(40);
   inj_icachedir_parity_d         <= errinj_enab_d and errinj_out(41);
   inj_dcache_parity_d            <= errinj_enab_d and errinj_out(42);
   inj_dcachedir_parity_d         <= errinj_enab_d and errinj_out(43);
   inj_xuregfile_parity_d(0 to 3) <= gate_and(errinj_enab_d and errinj_out(44), errinj_out(32 to 35));
   inj_furegfile_parity_d(0 to 3) <= gate_and(errinj_enab_d and errinj_out(45), errinj_out(32 to 35));
   inj_sprg_ecc_d(0 to 3)         <= gate_and(errinj_enab_d and errinj_out(46), errinj_out(32 to 35));
   inj_inbox_ecc_d                <= errinj_enab_d and errinj_out(47);
   inj_outbox_ecc_d               <= errinj_enab_d and errinj_out(48);
   inj_llbust_attempt_d(0 to 3)   <= gate_and(errinj_enab_d and errinj_out(49), errinj_out(32 to 35));
   inj_llbust_failed_d(0 to 3)    <= gate_and(errinj_enab_d and errinj_out(50), errinj_out(32 to 35));
   inj_wdt_reset_d(0 to 3)        <= gate_and(errinj_enab_d and errinj_out(51), errinj_out(32 to 35));
   inj_icachedir_multihit_d       <= errinj_enab_d and errinj_out(53);
   inj_dcachedir_multihit_d       <= errinj_enab_d and errinj_out(54);

   pc_iu_inj_icache_parity          <= inj_icache_parity_q;           
   pc_iu_inj_icachedir_parity       <= inj_icachedir_parity_q;        
   pc_xu_inj_dcache_parity          <= inj_dcache_parity_q;           
   pc_xu_inj_dcachedir_parity       <= inj_dcachedir_parity_q;        
   pc_xu_inj_regfile_parity(0 to 3) <= inj_xuregfile_parity_q(0 to 3);
   pc_fu_inj_regfile_parity(0 to 3) <= inj_furegfile_parity_q(0 to 3);
   pc_xu_inj_sprg_ecc(0 to 3)       <= inj_sprg_ecc_q(0 to 3);        
   pc_bx_inj_inbox_ecc              <= inj_inbox_ecc_q;               
   pc_bx_inj_outbox_ecc             <= inj_outbox_ecc_q;              
   pc_xu_inj_llbust_attempt(0 to 3) <= inj_llbust_attempt_q(0 to 3);  
   pc_xu_inj_llbust_failed(0 to 3)  <= inj_llbust_failed_q(0 to 3);   
   pc_xu_inj_wdt_reset(0 to 3)      <= inj_wdt_reset_q(0 to 3);       
   sc_parity_error_inject           <= errinj_enab_d and errinj_out(52);
   pc_iu_inj_icachedir_multihit     <= inj_icachedir_multihit_q;
   pc_xu_inj_dcachedir_multihit     <= inj_dcachedir_multihit_q;


fir_regs: entity work.pcq_regs_fir
  generic map( expand_type => expand_type )
  port map
   ( vdd                        => vdd                      
   , gnd                        => gnd                      
   , nclk                       => nclk                     
   , lcb_clkoff_dc_b            => lcb_clkoff_dc_b              
   , lcb_mpw1_dc_b              => lcb_mpw1_dc_b                
   , lcb_mpw2_dc_b              => lcb_mpw2_dc_b                
   , lcb_delay_lclkr_dc         => lcb_delay_lclkr_dc           
   , lcb_act_dis_dc             => lcb_act_dis_dc               
   , lcb_sg_0                   => lcb_sg_0               
   , lcb_func_slp_sl_thold_0    => lcb_func_slp_sl_thold_0
   , lcb_cfg_slp_sl_thold_0     => lcb_cfg_slp_sl_thold_0 
   , cfgslp_d1clk               => cfgslp_d1clk
   , cfgslp_d2clk               => cfgslp_d2clk
   , cfgslp_lclk                => cfgslp_lclk
   , cfg_slat_d2clk             => cfg_slat_d2clk  
   , cfg_slat_lclk              => cfg_slat_lclk  
   , bcfg_scan_in               => fir_mode_si             
   , func_scan_in               => fir_func_si             
   , bcfg_scan_out              => fir_mode_so             
   , func_scan_out              => fir_func_so            
   , sc_active                  => scom_act      
   , sc_wr_q                    => sc_wr_q        
   , sc_addr_v                  => scaddr_v      
   , sc_wdata                   => sc_wdata       
   , sc_wparity                 => sc_wparity     
   , sc_rdata                   => fir_data_out     
   , ac_an_special_attn           => attn_instr_int         
   , ac_an_checkstop              => ac_an_checkstop
   , ac_an_local_checkstop        => ac_an_local_checkstop
   , ac_an_recov_err              => ac_an_recov_err            
   , ac_an_trace_error            => ac_an_trace_error
   , an_ac_checkstop              => an_ac_checkstop        
   , an_ac_malf_alert             => an_ac_malf_alert        
   , rg_rg_any_fir_xstop          => rg_rg_any_fir_xstop
   , iu_pc_err_icache_parity      => iu_pc_err_icache_parity    
   , iu_pc_err_icachedir_parity   => iu_pc_err_icachedir_parity 
   , iu_pc_err_icachedir_multihit => iu_pc_err_icachedir_multihit
   , iu_pc_err_ucode_illegal      => iu_pc_err_ucode_illegal
   , xu_pc_err_dcache_parity      => xu_pc_err_dcache_parity    
   , xu_pc_err_dcachedir_parity   => xu_pc_err_dcachedir_parity 
   , xu_pc_err_dcachedir_multihit => xu_pc_err_dcachedir_multihit
   , xu_pc_err_mcsr_summary       => xu_pc_err_mcsr_summary
   , xu_pc_err_ierat_parity       => xu_pc_err_ierat_parity     
   , xu_pc_err_derat_parity       => xu_pc_err_derat_parity     
   , xu_pc_err_tlb_parity         => xu_pc_err_tlb_parity       
   , xu_pc_err_tlb_lru_parity     => xu_pc_err_tlb_lru_parity   
   , xu_pc_err_ierat_multihit     => xu_pc_err_ierat_multihit   
   , xu_pc_err_derat_multihit     => xu_pc_err_derat_multihit   
   , xu_pc_err_tlb_multihit       => xu_pc_err_tlb_multihit
   , xu_pc_err_ext_mchk           => xu_pc_err_ext_mchk        
   , xu_pc_err_ditc_overrun       => xu_pc_err_ditc_overrun
   , xu_pc_err_local_snoop_reject => xu_pc_err_local_snoop_reject
   , xu_pc_err_sprg_ecc           => xu_pc_err_sprg_ecc
   , xu_pc_err_sprg_ue            => xu_pc_err_sprg_ue
   , xu_pc_err_regfile_parity     => xu_pc_err_regfile_parity   
   , xu_pc_err_regfile_ue         => xu_pc_err_regfile_ue
   , xu_pc_err_llbust_attempt     => xu_pc_err_llbust_attempt   
   , xu_pc_err_llbust_failed      => xu_pc_err_llbust_failed    
   , xu_pc_err_l2intrf_ecc        => xu_pc_err_l2intrf_ecc       
   , xu_pc_err_l2intrf_ue         => xu_pc_err_l2intrf_ue       
   , xu_pc_err_l2credit_overrun   => xu_pc_err_l2credit_overrun
   , xu_pc_err_wdt_reset          => xu_pc_err_wdt_reset        
   , xu_pc_err_attention_instr    => xu_pc_err_attention_instr  
   , xu_pc_err_debug_event        => xu_pc_err_debug_event      
   , xu_pc_err_nia_miscmpr        => xu_pc_err_nia_miscmpr      
   , xu_pc_err_invld_reld         => xu_pc_err_invld_reld      
   , xu_pc_err_mchk_disabled      => xu_pc_err_mchk_disabled      
   , bx_pc_err_inbox_ecc          => bx_pc_err_inbox_ecc
   , bx_pc_err_inbox_ue           => bx_pc_err_inbox_ue
   , bx_pc_err_outbox_ecc         => bx_pc_err_outbox_ecc
   , bx_pc_err_outbox_ue          => bx_pc_err_outbox_ue
   , fu_pc_err_regfile_parity     => fu_pc_err_regfile_parity   
   , fu_pc_err_regfile_ue         => fu_pc_err_regfile_ue
   , scom_reg_par_checks          => scom_reg_par_checks
   , scom_sat_fsm_error           => scom_fsm_err
   , scom_ack_error               => scom_ack_err
   , sc_parity_error_inject       => sc_parity_error_inject
   , rg_rg_xstop_report_ovride    => rg_rg_xstop_report_ovride
   , rg_rg_ram_mode               => rg_rg_ram_mode
   , rg_rg_ram_mode_xstop         => rg_rg_ram_mode_xstop
   , rg_rg_xstop_err              => rg_rg_xstop_err
   , rg_rg_errinj_shutoff         => rg_rg_errinj_shutoff
   , rg_rg_maxRecErrCntrValue     => rg_rg_maxRecErrCntrValue
   , rg_rg_gateRecErrCntr         => rg_rg_gateRecErrCntr
   , pc_xu_cache_par_err_event  => pc_xu_cache_par_err_event
   , dbg_fir0_err               => dbg_fir0_err 
   , dbg_fir1_err               => dbg_fir1_err 
   , dbg_fir2_err               => dbg_fir2_err 
   , dbg_fir_misc               => dbg_fir_misc 
  );


  scom_reg_par_checks <= abdsr_par_err    & idsr_par_err   & mpdsr_par_err  &
                         xdsr1_par_err_q  & xdsr2_par_err  & pccr0_par_err  &
                         spattn_par_err   ;


  rg_ck_fast_xstop    <= rg_rg_fast_xstop_enable and rg_rg_any_fir_xstop ;


  dbg_scom_rdata   <=  sc_rdata(0 to 63);

  dbg_scom_wdata   <=  sc_wdata(0 to 63);

  dbg_scom_decaddr <=  scaddr_v_q(0 to 63);

  dbg_scom_misc    <=  scom_act            & 
                       sc_req_q            & 
                       sc_wr_q             & 
                       scaddr_nvld_q       & 
                       sc_wr_nvld_q        & 
                       sc_rd_nvld_q        & 
                       scaddr_fir          & 
                       sc_parity_error_inject  & 
                       sc_wparity          ; 

  dbg_ram_thrctl   <=  ramc_out(47)        & 
                       ramc_out(61)        & 
                       ramc_out(62)        & 
                       ramc_out(63)        & 
                       ramc_out(45 to 46)  & 
                       ram_mode_q          & 
                       xu_ram_done_q       & 
                       fu_ram_done_q       & 
                       tx_stop_q           & 
                       tx_step_q           & 
                       thrctl_out(40 to 43) ; 


axbx_dbgsel_reg: tri_rlmreg_p  
  generic map (width => abdsr_q'length, init => 0, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => scom_act,
            thold_b => lcb_cfg_slp_sl_thold_0_b,
            sg      => lcb_sg_0,
            forcee => force_cfgslp,
            delay_lclkr => lcb_delay_lclkr_dc,
            mpw1_b  => lcb_mpw1_dc_b,
            mpw2_b  => lcb_mpw2_dc_b,
            scin    => dcfg_siv(abdsr_offset to abdsr_offset + abdsr_q'length-1),
            scout   => dcfg_sov(abdsr_offset to abdsr_offset + abdsr_q'length-1),
            din     => abdsr_d,
            dout    => abdsr_q );

axbx_dbgsel_par: tri_rlmreg_p  
  generic map (width => 1, init => 0, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => scom_act,
            thold_b => lcb_cfg_slp_sl_thold_0_b,
            sg      => lcb_sg_0,
            forcee => force_cfgslp,
            delay_lclkr => lcb_delay_lclkr_dc,
            mpw1_b  => lcb_mpw1_dc_b,
            mpw2_b  => lcb_mpw2_dc_b,
            scin    => dcfg_siv(abdsr_par_offset to abdsr_par_offset),
            scout   => dcfg_sov(abdsr_par_offset to abdsr_par_offset),
            din     => abdsr_par_d,
            dout    => abdsr_par_q );

iu_dbgsel_reg: tri_rlmreg_p  
  generic map (width => idsr_q'length, init => 0, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => scom_act,
            thold_b => lcb_cfg_slp_sl_thold_0_b,
            sg      => lcb_sg_0,
            forcee => force_cfgslp,
            delay_lclkr => lcb_delay_lclkr_dc,
            mpw1_b  => lcb_mpw1_dc_b,
            mpw2_b  => lcb_mpw2_dc_b,
            scin    => dcfg_siv(idsr_offset to idsr_offset + idsr_q'length-1),
            scout   => dcfg_sov(idsr_offset to idsr_offset + idsr_q'length-1),
            din     => idsr_d,
            dout    => idsr_q );

iu_dbgsel_par: tri_rlmreg_p  
  generic map (width => 1, init => 0, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => scom_act,
            thold_b => lcb_cfg_slp_sl_thold_0_b,
            sg      => lcb_sg_0,
            forcee => force_cfgslp,
            delay_lclkr => lcb_delay_lclkr_dc,
            mpw1_b  => lcb_mpw1_dc_b,
            mpw2_b  => lcb_mpw2_dc_b,
            scin    => dcfg_siv(idsr_par_offset to idsr_par_offset),
            scout   => dcfg_sov(idsr_par_offset to idsr_par_offset),
            din     => idsr_par_d,
            dout    => idsr_par_q );

mmpc_dbgsel_reg: tri_rlmreg_p  
  generic map (width => mpdsr_q'length, init => 0, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => scom_act,
            thold_b => lcb_cfg_slp_sl_thold_0_b,
            sg      => lcb_sg_0,
            forcee => force_cfgslp,
            delay_lclkr => lcb_delay_lclkr_dc,
            mpw1_b  => lcb_mpw1_dc_b,
            mpw2_b  => lcb_mpw2_dc_b,
            scin    => dcfg_siv(mpdsr_offset to mpdsr_offset + mpdsr_q'length-1),
            scout   => dcfg_sov(mpdsr_offset to mpdsr_offset + mpdsr_q'length-1),
            din     => mpdsr_d,
            dout    => mpdsr_q );

mmpc_dbgsel_par: tri_rlmreg_p  
  generic map (width => 1, init => 0, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => scom_act,
            thold_b => lcb_cfg_slp_sl_thold_0_b,
            sg      => lcb_sg_0,
            forcee => force_cfgslp,
            delay_lclkr => lcb_delay_lclkr_dc,
            mpw1_b  => lcb_mpw1_dc_b,
            mpw2_b  => lcb_mpw2_dc_b,
            scin    => dcfg_siv(mpdsr_par_offset to mpdsr_par_offset),
            scout   => dcfg_sov(mpdsr_par_offset to mpdsr_par_offset),
            din     => mpdsr_par_d,
            dout    => mpdsr_par_q );

xu_dbgsel1_reg: tri_rlmreg_p  
  generic map (width => xdsr1_q'length, init => 0, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => scom_act,
            thold_b => lcb_cfg_slp_sl_thold_0_b,
            sg      => lcb_sg_0,
            forcee => force_cfgslp,
            delay_lclkr => lcb_delay_lclkr_dc,
            mpw1_b  => lcb_mpw1_dc_b,
            mpw2_b  => lcb_mpw2_dc_b,
            scin    => dcfg_siv(xdsr1_offset to xdsr1_offset + xdsr1_q'length-1),
            scout   => dcfg_sov(xdsr1_offset to xdsr1_offset + xdsr1_q'length-1),
            din     => xdsr1_d,
            dout    => xdsr1_q );

xu_dbgsel1_par: tri_rlmreg_p  
  generic map (width => 1, init => 0, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => scom_act,
            thold_b => lcb_cfg_slp_sl_thold_0_b,
            sg      => lcb_sg_0,
            forcee => force_cfgslp,
            delay_lclkr => lcb_delay_lclkr_dc,
            mpw1_b  => lcb_mpw1_dc_b,
            mpw2_b  => lcb_mpw2_dc_b,
            scin    => dcfg_siv(xdsr1_par_offset to xdsr1_par_offset),
            scout   => dcfg_sov(xdsr1_par_offset to xdsr1_par_offset),
            din     => xdsr1_par_d,
            dout    => xdsr1_par_q );

xu_dbgsel2_reg: tri_rlmreg_p  
  generic map (width => xdsr2_q'length, init => 0, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => scom_act,
            thold_b => lcb_cfg_slp_sl_thold_0_b,
            sg      => lcb_sg_0,
            forcee => force_cfgslp,
            delay_lclkr => lcb_delay_lclkr_dc,
            mpw1_b  => lcb_mpw1_dc_b,
            mpw2_b  => lcb_mpw2_dc_b,
            scin    => dcfg_siv(xdsr2_offset to xdsr2_offset + xdsr2_q'length-1),
            scout   => dcfg_sov(xdsr2_offset to xdsr2_offset + xdsr2_q'length-1),
            din     => xdsr2_d,
            dout    => xdsr2_q );

xu_dbgsel2_par: tri_rlmreg_p  
  generic map (width => 1, init => 0, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => scom_act,
            thold_b => lcb_cfg_slp_sl_thold_0_b,
            sg      => lcb_sg_0,
            forcee => force_cfgslp,
            delay_lclkr => lcb_delay_lclkr_dc,
            mpw1_b  => lcb_mpw1_dc_b,
            mpw2_b  => lcb_mpw2_dc_b,
            scin    => dcfg_siv(xdsr2_par_offset to xdsr2_par_offset),
            scout   => dcfg_sov(xdsr2_par_offset to xdsr2_par_offset),
            din     => xdsr2_par_d,
            dout    => xdsr2_par_q );

pccr0_reg: tri_rlmreg_p  
  generic map (width => pccr0_size, init => 0, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => scom_act,
            thold_b => lcb_cfg_slp_sl_thold_0_b,
            sg      => lcb_sg_0,
            forcee => force_cfgslp,
            delay_lclkr => lcb_delay_lclkr_dc,
            mpw1_b  => lcb_mpw1_dc_b,
            mpw2_b  => lcb_mpw2_dc_b,
            scin    => dcfg_siv(pccr0_offset to pccr0_offset + pccr0_size-1),
            scout   => dcfg_sov(pccr0_offset to pccr0_offset + pccr0_size-1),
            din     => pccr0_d,
            dout    => pccr0_q );

rec_err_cntr: tri_rlmreg_p  
  generic map (width => recerrcntr_size, init => 0, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => tiup,
            thold_b => lcb_cfg_slp_sl_thold_0_b,
            sg      => lcb_sg_0,
            forcee => force_cfgslp,
            delay_lclkr => lcb_delay_lclkr_dc,
            mpw1_b  => lcb_mpw1_dc_b,
            mpw2_b  => lcb_mpw2_dc_b,
            scin    => dcfg_siv(recerrcntr_offset to recerrcntr_offset + recerrcntr_size-1),
            scout   => dcfg_sov(recerrcntr_offset to recerrcntr_offset + recerrcntr_size-1),
            din     => recErrCntr_in,
            dout    => recErrCntr_q );

pccr0_par: tri_rlmreg_p  
  generic map (width => 1, init => 0, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => tiup,
            thold_b => lcb_cfg_slp_sl_thold_0_b,
            sg      => lcb_sg_0,
            forcee => force_cfgslp,
            delay_lclkr => lcb_delay_lclkr_dc,
            mpw1_b  => lcb_mpw1_dc_b,
            mpw2_b  => lcb_mpw2_dc_b,
            scin    => dcfg_siv(pccr0_par_offset to pccr0_par_offset),
            scout   => dcfg_sov(pccr0_par_offset to pccr0_par_offset),
            din     => pccr0_par_d,
            dout    => pccr0_par_q );

dcfg_stage1: tri_rlmreg_p 
  generic map (width => dcfg_stage1_size, init => 0, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => tiup,
            thold_b => lcb_cfg_slp_sl_thold_0_b,
            sg      => lcb_sg_0,
            forcee => force_cfgslp,
            delay_lclkr => lcb_delay_lclkr_dc,
            mpw1_b  => lcb_mpw1_dc_b,
            mpw2_b  => lcb_mpw2_dc_b,
            scin    => dcfg_siv(dcfg_stage1_offset to dcfg_stage1_offset + dcfg_stage1_size-1),
            scout   => dcfg_sov(dcfg_stage1_offset to dcfg_stage1_offset + dcfg_stage1_size-1),
            din(0)    => debug_mode_d,
            din(1)    => ram_enab_d,
            din(2)    => errinj_enab_d,
            din(3)    => trace_bus_enable_d,
            din(4)    => xdsr1_par_err_d,
            dout(0)   => debug_mode_q,
            dout(1)   => ram_enab_q,
            dout(2)   => errinj_enab_q,
            dout(3)   => trace_bus_enable_q,
            dout(4)   => xdsr1_par_err_q );
thrctl1_reg: tri_rlmreg_p
  generic map (width => thrctl1_size, init => 0, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => tiup,
            thold_b => lcb_cfg_slp_sl_thold_0_b,
            sg      => lcb_sg_0,
            forcee => force_cfgslp,
            delay_lclkr => lcb_delay_lclkr_dc,
            mpw1_b  => lcb_mpw1_dc_b,
            mpw2_b  => lcb_mpw2_dc_b,
            scin    => bcfg_siv(thrctl1_offset to thrctl1_offset + thrctl1_size-1),
            scout   => bcfg_sov(thrctl1_offset to thrctl1_offset + thrctl1_size-1),
            din     => thrctl1_d,
            dout    => thrctl1_q );

thrctl2_reg: tri_rlmreg_p  
  generic map (width => thrctl2_size, init => 0, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => scom_act,
            thold_b => lcb_cfg_slp_sl_thold_0_b,
            sg      => lcb_sg_0,
            forcee => force_cfgslp,
            delay_lclkr => lcb_delay_lclkr_dc,
            mpw1_b  => lcb_mpw1_dc_b,
            mpw2_b  => lcb_mpw2_dc_b,
            scin    => bcfg_siv(thrctl2_offset to thrctl2_offset + thrctl2_size-1),
            scout   => bcfg_sov(thrctl2_offset to thrctl2_offset + thrctl2_size-1),
            din     => thrctl2_d,
            dout    => thrctl2_q );

spattn_data_reg: tri_rlmreg_p
  generic map (width => spattn_size, init => 0, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => tiup,
            thold_b => lcb_cfg_slp_sl_thold_0_b,
            sg      => lcb_sg_0,
            forcee => force_cfgslp,
            delay_lclkr => lcb_delay_lclkr_dc,
            mpw1_b  => lcb_mpw1_dc_b,
            mpw2_b  => lcb_mpw2_dc_b,
            scin    => bcfg_siv(spattn1_offset to spattn1_offset + spattn_size-1),
            scout   => bcfg_sov(spattn1_offset to spattn1_offset + spattn_size-1),
            din     => spattn_data_d,
            dout    => spattn_data_q );

spattn_mask_reg: tri_rlmreg_p
  generic map (width => spattn_size, init => 15, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => scom_act,
            thold_b => lcb_cfg_slp_sl_thold_0_b,
            sg      => lcb_sg_0,
            forcee => force_cfgslp,
            delay_lclkr => lcb_delay_lclkr_dc,
            mpw1_b  => lcb_mpw1_dc_b,
            mpw2_b  => lcb_mpw2_dc_b,
            scin    => bcfg_siv(spattn2_offset to spattn2_offset + spattn_size-1),
            scout   => bcfg_sov(spattn2_offset to spattn2_offset + spattn_size-1),
            din     => spattn_mask_d,
            dout    => spattn_mask_q );

spattn_par: tri_rlmreg_p  
  generic map (width => 1, init => 0, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => scom_act,
            thold_b => lcb_cfg_slp_sl_thold_0_b,
            sg      => lcb_sg_0,
            forcee => force_cfgslp,
            delay_lclkr => lcb_delay_lclkr_dc,
            mpw1_b  => lcb_mpw1_dc_b,
            mpw2_b  => lcb_mpw2_dc_b,
            scin    => bcfg_siv(spattn_par_offset to spattn_par_offset),
            scout   => bcfg_sov(spattn_par_offset to spattn_par_offset),
            din     => spattn_par_d,
            dout    => spattn_par_q );

bcfg_stage1: tri_rlmreg_p 
  generic map (width => bcfg_stage1_size, init => 0, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => tiup,
            thold_b => lcb_cfg_slp_sl_thold_0_b,
            sg      => lcb_sg_0,
            forcee => force_cfgslp,
            delay_lclkr => lcb_delay_lclkr_dc,
            mpw1_b  => lcb_mpw1_dc_b,
            mpw2_b  => lcb_mpw2_dc_b,
            scin    => bcfg_siv(bcfg_stage1_offset to bcfg_stage1_offset + bcfg_stage1_size-1),
            scout   => bcfg_sov(bcfg_stage1_offset to bcfg_stage1_offset + bcfg_stage1_size-1),
            din(0 to 3)    => tx_stop_d,
            din(4)         => an_ac_debug_stop,
            din(5 to 8)    => xu_pc_stop_dbg_event,
            din(9 to 12)   => xu_pc_step_done,
            dout(0 to 3)   => tx_stop_q,
            dout(4)        => ext_debug_stop_q,   
            dout(5 to 8)   => stop_dbg_event_q,
            dout(9 to 12)  => step_done_q );

bcfg_stage2: tri_ser_rlmreg_p 
  generic map (width => bcfg_stage2_size, init => 0, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => debug_mode_act,
            thold_b => lcb_cfg_slp_sl_thold_0_b,
            sg      => lcb_sg_0,
            forcee => force_cfgslp,
            delay_lclkr => lcb_delay_lclkr_dc,
            mpw1_b  => lcb_mpw1_dc_b,
            mpw2_b  => lcb_mpw2_dc_b,
            scin    => bcfg_siv(bcfg_stage2_offset to bcfg_stage2_offset + bcfg_stage2_size-1),
            scout   => bcfg_sov(bcfg_stage2_offset to bcfg_stage2_offset + bcfg_stage2_size-1),
            din(0 to 3)    => tx_step_d,
            din(4)         => extirpts_dis_d,
            din(5)         => timebase_dis_d,
            din(6)         => decrem_dis_d,
            din(7 to 10)   => ude_dly_d,
            din(11 to 14)  => tx_ude_d,
            dout(0 to 3)   => tx_step_q,   
            dout(4)        => extirpts_dis_q,   
            dout(5)        => timebase_dis_q,   
            dout(6)        => decrem_dis_q,   
            dout(7 to 10)  => ude_dly_q,
            dout(11 to 14) => tx_ude_q );
ccfg_repwr: tri_slat_scan  
   generic map (width => 1, init => "0", expand_type => expand_type)
   port map ( vd    => vdd,
              gd    => gnd,
              dclk  => cfg_slat_d2clk,
              lclk  => cfg_slat_lclk,
              scan_in(0)  => ccfg_scan_in,
              scan_out(0) => ccfg_scan_out );
rami_reg: tri_rlmreg_p  
  generic map (width => rami_q'length, init => 0, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => ram_enab_scom_act,
            thold_b => lcb_func_slp_sl_thold_0_b,
            sg      => lcb_sg_0,
            forcee => force_funcslp,
            delay_lclkr => lcb_delay_lclkr_dc,
            mpw1_b  => lcb_mpw1_dc_b,
            mpw2_b  => lcb_mpw2_dc_b,
            scin    => func_siv(rami_offset to rami_offset + rami_q'length-1),
            scout   => func_sov(rami_offset to rami_offset + rami_q'length-1),
            din     => rami_d,
            dout    => rami_q );

ramc_reg: tri_rlmreg_p  
  generic map (width => ramc_q'length, init => 0, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => ram_enab_scom_act,
            thold_b => lcb_func_slp_sl_thold_0_b,
            sg      => lcb_sg_0,
            forcee => force_funcslp,
            delay_lclkr => lcb_delay_lclkr_dc,
            mpw1_b  => lcb_mpw1_dc_b,
            mpw2_b  => lcb_mpw2_dc_b,
            scin    => func_siv(ramc_offset to ramc_offset + ramc_q'length-1),
            scout   => func_sov(ramc_offset to ramc_offset + ramc_q'length-1),
            din     => ramc_d,
            dout    => ramc_q );

ramd_reg: tri_rlmreg_p  
  generic map (width => ramd_q'length, init => 0, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => ram_enab_scom_act,
            thold_b => lcb_func_slp_sl_thold_0_b,
            sg      => lcb_sg_0,
            forcee => force_funcslp,
            delay_lclkr => lcb_delay_lclkr_dc,
            mpw1_b  => lcb_mpw1_dc_b,
            mpw2_b  => lcb_mpw2_dc_b,
            scin    => func_siv(ramd_offset to ramd_offset + ramd_q'length-1),
            scout   => func_sov(ramd_offset to ramd_offset + ramd_q'length-1),
            din     => ramd_d,
            dout    => ramd_q );

fu_ram_din: tri_rlmreg_p  
  generic map (width => fu_ram_din_size, init => 0, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => ram_enab_act,
            thold_b => lcb_func_slp_sl_thold_0_b,
            sg      => lcb_sg_0,
            forcee => force_funcslp,
            delay_lclkr => lcb_delay_lclkr_dc,
            mpw1_b  => lcb_mpw1_dc_b,
            mpw2_b  => lcb_mpw2_dc_b,
            scin    => func_siv(fu_ram_din_offset to fu_ram_din_offset + fu_ram_din_size-1),
            scout   => func_sov(fu_ram_din_offset to fu_ram_din_offset + fu_ram_din_size-1),
            din     => fu_ramd_load_data_d,
            dout    => fu_ramd_load_data_q );

xu_ram_din: tri_rlmreg_p  
  generic map (width => xu_ram_din_size, init => 0, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => ram_enab_act,
            thold_b => lcb_func_slp_sl_thold_0_b,
            sg      => lcb_sg_0,
            forcee => force_funcslp,
            delay_lclkr => lcb_delay_lclkr_dc,
            mpw1_b  => lcb_mpw1_dc_b,
            mpw2_b  => lcb_mpw2_dc_b,
            scin    => func_siv(xu_ram_din_offset to xu_ram_din_offset + xu_ram_din_size-1),
            scout   => func_sov(xu_ram_din_offset to xu_ram_din_offset + xu_ram_din_size-1),
            din     => xu_ramd_load_data_d,
            dout    => xu_ramd_load_data_q );

errinj_reg: tri_rlmreg_p  
  generic map (width => errinj_size, init => 0, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => errinj_enab_scom_act,
            thold_b => lcb_func_slp_sl_thold_0_b,
            sg      => lcb_sg_0,
            forcee => force_funcslp,
            delay_lclkr => lcb_delay_lclkr_dc,
            mpw1_b  => lcb_mpw1_dc_b,
            mpw2_b  => lcb_mpw2_dc_b,
            scin    => func_siv(errinj_offset to errinj_offset + errinj_size-1),
            scout   => func_sov(errinj_offset to errinj_offset + errinj_size-1),
            din     => errinj_d,
            dout    => errinj_q );

sc_misc: tri_ser_rlmreg_p  
  generic map (width => scom_misc_size, init => 0, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => scom_act,
            thold_b => lcb_func_slp_sl_thold_0_b,
            sg      => lcb_sg_0,
            forcee => force_funcslp,
            delay_lclkr => lcb_delay_lclkr_dc,
            mpw1_b  => lcb_mpw1_dc_b,
            mpw2_b  => lcb_mpw2_dc_b,
            scin    => func_siv(sc_misc_offset to sc_misc_offset + scom_misc_size-1),
            scout   => func_sov(sc_misc_offset to sc_misc_offset + scom_misc_size-1),
            din(0)  => sc_req_d,
            din(1)  => scaddr_nvld_d,
            din(2)  => sc_wr_nvld_d,
            din(3)  => sc_rd_nvld_d,
            din(4)  => sc_wr_d,
            din(5)  => ram_flush_d,
            dout(0) => sc_req_q,
            dout(1) => scaddr_nvld_q,
            dout(2) => sc_wr_nvld_q,
            dout(3) => sc_rd_nvld_q,
            dout(4) => sc_wr_q,
            dout(5) => ram_flush_q);


scaddr_dec: tri_rlmreg_p 
  generic map (width => scaddr_v_q'length, init => 0, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => scom_act,
            thold_b => lcb_func_slp_sl_thold_0_b,
            sg      => lcb_sg_0,
            forcee => force_funcslp,
            delay_lclkr => lcb_delay_lclkr_dc,
            mpw1_b  => lcb_mpw1_dc_b,
            mpw2_b  => lcb_mpw2_dc_b,
            scin    => func_siv(scaddr_dec_offset to scaddr_dec_offset + scaddr_v_q'length-1),
            scout   => func_sov(scaddr_dec_offset to scaddr_dec_offset + scaddr_v_q'length-1),
            din     => scaddr_v_d,
            dout    => scaddr_v_q );

func_stage1: tri_rlmreg_p 
  generic map (width => func_stage1_size, init => 0, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => tiup,
            thold_b => lcb_func_slp_sl_thold_0_b,
            sg      => lcb_sg_0,
            forcee => force_funcslp,
            delay_lclkr => lcb_delay_lclkr_dc,
            mpw1_b  => lcb_mpw1_dc_b,
            mpw2_b  => lcb_mpw2_dc_b,
            scin    => func_siv(func_stage1_offset to func_stage1_offset + func_stage1_size-1),
            scout   => func_sov(func_stage1_offset to func_stage1_offset + func_stage1_size-1),
            din(0)         => an_ac_scom_cch,
            din(1)         => an_ac_scom_dch,
            dout(0)        => scom_cch_q,
            dout(1)        => scom_dch_q );


func_stage2: tri_ser_rlmreg_p 
  generic map (width => func_stage2_size, init => 0, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => errinj_enab_act,
            thold_b => lcb_func_slp_sl_thold_0_b,
            sg      => lcb_sg_0,
            forcee => force_funcslp,
            delay_lclkr => lcb_delay_lclkr_dc,
            mpw1_b  => lcb_mpw1_dc_b,
            mpw2_b  => lcb_mpw2_dc_b,
            scin    => func_siv(func_stage2_offset to func_stage2_offset + func_stage2_size-1),
            scout   => func_sov(func_stage2_offset to func_stage2_offset + func_stage2_size-1),
            din(0)         => inj_icache_parity_d,
            din(1)         => inj_icachedir_parity_d,
            din(2)         => inj_dcache_parity_d,
            din(3)         => inj_dcachedir_parity_d,
            din(4 to 7)    => inj_xuregfile_parity_d(0 to 3),
            din(8 to 11)   => inj_furegfile_parity_d(0 to 3),
            din(12 to 15)  => inj_sprg_ecc_d(0 to 3),
            din(16)        => inj_inbox_ecc_d,
            din(17)        => inj_outbox_ecc_d,
            din(18 to 21)  => inj_llbust_attempt_d(0 to 3),
            din(22 to 25)  => inj_llbust_failed_d(0 to 3),
            din(26 to 29)  => inj_wdt_reset_d(0 to 3),
            din(30)        => inj_icachedir_multihit_d,
            din(31)        => inj_dcachedir_multihit_d,
            dout(0)        => inj_icache_parity_q,   
            dout(1)        => inj_icachedir_parity_q,  
            dout(2)        => inj_dcache_parity_q,    
            dout(3)        => inj_dcachedir_parity_q,  
            dout(4 to 7)   => inj_xuregfile_parity_q(0 to 3),
            dout(8 to 11)  => inj_furegfile_parity_q(0 to 3),
            dout(12 to 15) => inj_sprg_ecc_q(0 to 3),
            dout(16)       => inj_inbox_ecc_q,  
            dout(17)       => inj_outbox_ecc_q, 
            dout(18 to 21) => inj_llbust_attempt_q(0 to 3),
            dout(22 to 25) => inj_llbust_failed_q(0 to 3),
            dout(26 to 29) => inj_wdt_reset_q(0 to 3),
            dout(30)       => inj_icachedir_multihit_q,
            dout(31)       => inj_dcachedir_multihit_q );

func_stage3: tri_ser_rlmreg_p 
  generic map (width => func_stage3_size, init => 0, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => ram_enab_act,
            thold_b => lcb_func_slp_sl_thold_0_b,
            sg      => lcb_sg_0,
            forcee => force_funcslp,
            delay_lclkr => lcb_delay_lclkr_dc,
            mpw1_b  => lcb_mpw1_dc_b,
            mpw2_b  => lcb_mpw2_dc_b,
            scin    => func_siv(func_stage3_offset to func_stage3_offset + func_stage3_size-1),
            scout   => func_sov(func_stage3_offset to func_stage3_offset + func_stage3_size-1),
            din(0)         => ram_mode_d,
            din(1)         => ram_execute_d,
            din(2)         => ram_msrovren_d,
            din(3)         => ram_msrovrpr_d,
            din(4)         => ram_msrovrgs_d,
            din(5)         => ram_msrovrde_d,
            din(6)         => ram_force_d,
            din(7)         => xu_pc_ram_done,
            din(8)         => fu_pc_ram_done,
            din(9 to 10)   => ram_thread_d(0 to 1),
            dout(0)        => ram_mode_q,  
            dout(1)        => ram_execute_q,  
            dout(2)        => ram_msrovren_q,  
            dout(3)        => ram_msrovrpr_q,  
            dout(4)        => ram_msrovrgs_q,  
            dout(5)        => ram_msrovrde_q,  
            dout(6)        => ram_force_q,  
            dout(7)        => xu_ram_done_q,
            dout(8)        => fu_ram_done_q,
            dout(9 to 10)  => ram_thread_q(0 to 1) );

cfg_slat_thold_b <= NOT lcb_cfg_sl_thold_0;
cfg_slat_force   <= lcb_sg_0;

lcbs_cfg: tri_lcbs
  generic map (expand_type => expand_type )
  port map (
      vd          => vdd,
      gd          => gnd,
      delay_lclkr => lcb_delay_lclkr_dc,
      nclk        => nclk,
      forcee => cfg_slat_force,
      thold_b     => cfg_slat_thold_b,
      dclk        => cfg_slat_d2clk,
      lclk        => cfg_slat_lclk );


lcbor_cfgslp: tri_lcbor
generic map (expand_type => expand_type )
port map (
    clkoff_b => lcb_clkoff_dc_b,
    thold    => lcb_cfg_slp_sl_thold_0,
    sg       => lcb_sg_0,
    act_dis  => lcb_act_dis_dc,
    forcee => force_cfgslp,
    thold_b  => lcb_cfg_slp_sl_thold_0_b );

lcbn_cfgslp: tri_lcbnd
generic map (expand_type => expand_type )
port map (
    vd          => vdd,
    gd          => gnd,
    act         => tiup,
    delay_lclkr => lcb_delay_lclkr_dc,
    mpw1_b      => lcb_mpw1_dc_b,
    mpw2_b      => lcb_mpw2_dc_b,
    nclk        => nclk,
    forcee => force_cfgslp,
    sg          => lcb_sg_0,
    thold_b     => lcb_cfg_slp_sl_thold_0_b,
    d1clk       => cfgslp_d1clk,
    d2clk       => cfgslp_d2clk,
    lclk        => cfgslp_lclk );


lcbor_funcslp: tri_lcbor
generic map (expand_type => expand_type )
port map (
    clkoff_b => lcb_clkoff_dc_b,
    thold    => lcb_func_slp_sl_thold_0,
    sg       => lcb_sg_0,
    act_dis  => lcb_act_dis_dc,
    forcee => force_funcslp,
    thold_b  => lcb_func_slp_sl_thold_0_b );



bcfg_siv(0 TO bcfg_right) <=  bcfg_scan_in & bcfg_sov(0 to bcfg_right-1);
fir_mode_si <=  bcfg_sov(bcfg_right);
bcfg_scan_out  <=  fir_mode_so and scan_dis_dc_b;

func_siv(0 TO func_right) <=  func_scan_in & func_sov(0 to func_right-1);
fir_func_si  <=  func_sov(func_right);
func_scan_out  <=  fir_func_so and scan_dis_dc_b;

dcfg_siv(0 TO dcfg_right) <=  dcfg_scan_in & dcfg_sov(0 to dcfg_right-1);
dcfg_scan_out  <=  dcfg_sov(dcfg_right) and scan_dis_dc_b;


end pcq_regs;

