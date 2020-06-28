-- © IBM Corp. 2020
-- This softcore is licensed under and subject to the terms of the CC-BY 4.0
-- license (https://creativecommons.org/licenses/by/4.0/legalcode). 
-- Additional rights, including the right to physically implement a softcore 
-- that is compliant with the required sections of the Power ISA 
-- Specification, will be available at no cost via the OpenPOWER Foundation. 
-- This README will be updated with additional information when OpenPOWER's 
-- license is available.

library ieee,ibm,support,work;
use ieee.std_logic_1164.all;
use support.power_logic_pkg.all;
use work.xuq_pkg.mark_unused;

library tri;
use tri.tri_latches_pkg.all;
entity xuq is
    generic (
        expand_type                     : integer := 2;
        threads                         : integer := 4;
        eff_ifar                        : integer := 62;
         uc_ifar                        : integer := 21;
        l_endian_m                      : integer := 1;
        real_data_add                   : integer := 42;
        lmq_entries                     : integer := 8;
        regmode                         : integer := 6;
        hvmode                          : integer := 1;
        a2mode                          : integer := 1;
        dc_size                         : natural := 14;       
        cl_size                         : natural := 6;        
        load_credits                    : integer := 4;
        store_credits                   : integer := 20;
        st_data_32B_mode                : integer := 1;
        bcfg_epn_0to15                  : integer := 0;
        bcfg_epn_16to31                 : integer := 0;
        bcfg_epn_32to47                 : integer := (2**16)-1;
        bcfg_epn_48to51                 : integer := (2**4)-1;
        bcfg_rpn_22to31                 : integer := (2**10)-1;
        bcfg_rpn_32to47                 : integer := (2**16)-1;
        bcfg_rpn_48to51                 : integer := (2**4)-1;
        spr_xucr0_init_mod              : integer := 0);
    port (

        an_ac_coreid                    : in  std_ulogic_vector(54 to 61);
        spr_pvr_version_dc              : in  std_ulogic_vector(8 to 15);
        spr_pvr_revision_dc             : in  std_ulogic_vector(12 to 15);
        an_ac_ext_interrupt             : in  std_ulogic_vector(0 to threads-1);
        an_ac_crit_interrupt            : in  std_ulogic_vector(0 to threads-1);
        an_ac_perf_interrupt            : in  std_ulogic_vector(0 to threads-1);
        an_ac_tb_update_enable          : in  std_ulogic;
        an_ac_tb_update_pulse           : in  std_ulogic;
        an_ac_hang_pulse                : in  std_ulogic_vector(0 to threads-1);
        an_ac_sleep_en                  : in  std_ulogic_vector(0 to threads-1);
        ac_tc_debug_trigger             : out std_ulogic_vector(0 to threads-1);
        an_ac_external_mchk             : in  std_ulogic_vector(0 to threads-1);
        ac_tc_machine_check             : out std_ulogic_vector(0 to threads-1);
        an_ac_reservation_vld           : in  std_ulogic_vector(0 to threads-1);
        an_ac_grffence_en_dc            : in  std_ulogic;

        iu_xu_is2_vld                   : in  std_ulogic;
        iu_xu_is2_instr                 : in  std_ulogic_vector(0 to 31);
        iu_xu_is2_match                 : in  std_ulogic;
        iu_xu_is2_ta                    : in  std_ulogic_vector(0 to 5);
        iu_xu_is2_ta_vld                : in  std_ulogic;
        iu_xu_is2_s1                    : in  std_ulogic_vector(0 to 5);
        iu_xu_is2_s1_vld                : in  std_ulogic;
        iu_xu_is2_s2                    : in  std_ulogic_vector(0 to 5);
        iu_xu_is2_s2_vld                : in  std_ulogic;
        iu_xu_is2_s3                    : in  std_ulogic_vector(0 to 5);
        iu_xu_is2_s3_vld                : in  std_ulogic;
        iu_xu_is2_pred_update           : in  std_ulogic;
        iu_xu_is2_pred_taken_cnt        : in  std_ulogic_vector(0 to 1);
        iu_xu_is2_error                 : in  std_ulogic_vector(0 to 2);
        iu_xu_is2_tid                   : in  std_ulogic_vector(0 to 3);
        iu_xu_is2_ifar                  : in  std_ulogic_vector(62-eff_ifar to 61);
        iu_xu_is2_is_ucode              : in  std_ulogic;
        iu_xu_is2_gshare                : in  std_ulogic_vector(0 to 3);
        iu_xu_is2_axu_ld_or_st          : in  std_ulogic;
        iu_xu_is2_axu_store             : in  std_ulogic;
        iu_xu_is2_axu_ldst_size         : in  std_ulogic_vector(0 to 5);
        iu_xu_is2_axu_ldst_update       : in  std_ulogic;
        iu_xu_is2_axu_mftgpr            : in  std_ulogic;
        iu_xu_is2_axu_mffgpr            : in  std_ulogic;
        iu_xu_is2_axu_movedp            : in  std_ulogic;
        iu_xu_is2_axu_instr_type        : in  std_ulogic_vector(0 to 2);
        iu_xu_is2_axu_ldst_extpid       : in  std_ulogic;
        iu_xu_is2_axu_ldst_tag          : in  std_ulogic_vector(0 to 8);
        iu_xu_is2_axu_ldst_indexed      : in  std_ulogic;
        iu_xu_is2_axu_ldst_forcealign   : in  std_ulogic;
        iu_xu_is2_axu_ldst_forceexcept  : in  std_ulogic;
        iu_xu_is2_ucode_vld             : in  std_ulogic;

        iu_xu_request                   : in  std_ulogic;
        iu_xu_thread                    : in  std_ulogic_vector(0 to 3);
        iu_xu_ra                        : in  std_ulogic_vector(64-real_data_add to 59);
        iu_xu_wimge                     : in  std_ulogic_vector(0 to 4);
        iu_xu_userdef                   : in  std_ulogic_vector(0 to 3);

        an_ac_reld_data_vld             : in  std_ulogic;
        an_ac_reld_core_tag             : in  std_ulogic_vector(0 to 4);
        an_ac_reld_data                 : in  std_ulogic_vector(0 to 127);
        an_ac_reld_qw                   : in  std_ulogic_vector(57 to 59);
        an_ac_reld_ecc_err              : in  std_ulogic;
        an_ac_reld_ecc_err_ue           : in  std_ulogic;
        an_ac_reld_data_coming          : in  std_ulogic;
        an_ac_reld_ditc                 : in  std_ulogic;
        an_ac_reld_crit_qw              : in  std_ulogic;
        an_ac_reld_l1_dump              : in  std_ulogic;

        an_ac_req_ld_pop                : in  std_ulogic;
        an_ac_req_st_pop                : in  std_ulogic;
        an_ac_req_st_pop_thrd           : in  std_ulogic_vector(0 to 2);
        an_ac_req_st_gather             : in  std_ulogic;

        an_ac_req_spare_ctrl_a1         : in  std_ulogic_vector(0 to 3);
        an_ac_flh2l2_gate               : in  std_ulogic;                        

        lsu_reld_data_vld               : out std_ulogic;                      
        lsu_reld_core_tag               : out std_ulogic_vector(3 to 4);       
        lsu_reld_qw                     : out std_ulogic_vector(58 to 59);     
        lsu_reld_ditc                   : out std_ulogic;                      
        lsu_reld_ecc_err                : out std_ulogic;                      
        lsu_reld_data                   : out std_ulogic_vector(0 to 127);     

        lsu_req_st_pop                  : out std_ulogic;               
        lsu_req_st_pop_thrd             : out std_ulogic_vector(0 to 2);

        mm_xu_cr0_eq_valid              : in  std_ulogic_vector(0 to 3);
        mm_xu_cr0_eq                    : in  std_ulogic_vector(0 to 3);
        mm_xu_lsu_req                   : in  std_ulogic_vector(0 to 3);
        mm_xu_lsu_ttype                 : in  std_ulogic_vector(0 to 1);
        mm_xu_lsu_wimge                 : in  std_ulogic_vector(0 to 4);
        mm_xu_lsu_u                     : in  std_ulogic_vector(0 to 3);
        mm_xu_lsu_addr                  : in  std_ulogic_vector(64-real_data_add to 63);
        mm_xu_lsu_lpid                  : in  std_ulogic_vector(0 to 7);
        mm_xu_lsu_lpidr                 : in  std_ulogic_vector(0 to 7);
        mm_xu_lsu_gs                    : in  std_ulogic;
        mm_xu_lsu_ind                   : in  std_ulogic;
        mm_xu_lsu_lbit                  : in  std_ulogic;                   
        xu_mm_lsu_token                 : out std_ulogic;

        ac_an_reld_ditc_pop_int    : in  std_ulogic_vector(0 to 3);
        ac_an_reld_ditc_pop_q      : out std_ulogic_vector(0 to 3);
        bx_ib_empty_int            : in  std_ulogic_vector(0 to 3);
        bx_ib_empty_q              : out std_ulogic_vector(0 to 3);

        an_ac_back_inv                  : in  std_ulogic;
        an_ac_back_inv_addr             : in  std_ulogic_vector(64-real_data_add to 63);
        an_ac_back_inv_target_bit1      : in  std_ulogic;
        an_ac_back_inv_target_bit3      : in  std_ulogic;
        an_ac_back_inv_target_bit4      : in  std_ulogic;

        an_ac_stcx_complete             : in  std_ulogic_vector(0 to 3);
        an_ac_stcx_pass                 : in  std_ulogic_vector(0 to 3);
        xu_iu_stcx_complete             : out   std_ulogic_vector(0 to 3);

        xu_iu_ex4_loadmiss_target_type  : out std_ulogic_vector(0 to 1);
        xu_iu_ex4_loadmiss_tid          : out std_ulogic_vector(0 to 3);
        xu_iu_ex4_loadmiss_qentry       : out std_ulogic_vector(0 to lmq_entries-1);
        xu_iu_ex4_loadmiss_target       : out std_ulogic_vector(0 to 8);
        xu_iu_ex5_loadmiss_target_type  : out std_ulogic_vector(0 to 1);
        xu_iu_ex5_loadmiss_tid          : out std_ulogic_vector(0 to 3);
        xu_iu_ex5_loadmiss_qentry       : out std_ulogic_vector(0 to lmq_entries-1);
        xu_iu_ex5_loadmiss_target       : out std_ulogic_vector(0 to 8);
        xu_iu_complete_target_type      : out std_ulogic_vector(0 to 1);
        xu_iu_complete_tid              : out std_ulogic_vector(0 to 3);
        xu_iu_complete_qentry           : out std_ulogic_vector(0 to lmq_entries-1);
        xu_iu_larx_done_tid             : out std_ulogic_vector(0 to 3);
        xu_iu_set_barr_tid              : out std_ulogic_vector(0 to 3);
        xu_iu_ex6_icbi_val              : out std_ulogic_vector(0 to 3);
        xu_iu_ex6_icbi_addr             : out std_ulogic_vector(64-real_data_add to 57);

        xu_iu_membar_tid                : out std_ulogic_vector(0 to 3);

        xu_n_is2_flush                  : out std_ulogic_vector(0 to threads-1);
        xu_n_rf0_flush                  : out std_ulogic_vector(0 to threads-1);
        xu_n_rf1_flush                  : out std_ulogic_vector(0 to threads-1);
        xu_n_ex1_flush                  : out std_ulogic_vector(0 to threads-1);
        xu_n_ex2_flush                  : out std_ulogic_vector(0 to threads-1);
        xu_n_ex3_flush                  : out std_ulogic_vector(0 to threads-1);
        xu_n_ex4_flush                  : out std_ulogic_vector(0 to threads-1);
        xu_n_ex5_flush                  : out std_ulogic_vector(0 to threads-1);

        xu_s_rf1_flush                  : out std_ulogic_vector(0 to threads-1);
        xu_s_ex1_flush                  : out std_ulogic_vector(0 to threads-1);
        xu_s_ex2_flush                  : out std_ulogic_vector(0 to threads-1);
        xu_s_ex3_flush                  : out std_ulogic_vector(0 to threads-1);
        xu_s_ex4_flush                  : out std_ulogic_vector(0 to threads-1);
        xu_s_ex5_flush                  : out std_ulogic_vector(0 to threads-1);

        xu_wu_rf1_flush                 : out std_ulogic_vector(0 to threads-1);
        xu_wu_ex1_flush                 : out std_ulogic_vector(0 to threads-1);
        xu_wu_ex2_flush                 : out std_ulogic_vector(0 to threads-1);
        xu_wu_ex3_flush                 : out std_ulogic_vector(0 to threads-1);
        xu_wu_ex4_flush                 : out std_ulogic_vector(0 to threads-1);
        xu_wu_ex5_flush                 : out std_ulogic_vector(0 to threads-1);

        xu_wl_rf1_flush                 : out std_ulogic_vector(0 to threads-1);
        xu_wl_ex1_flush                 : out std_ulogic_vector(0 to threads-1);
        xu_wl_ex2_flush                 : out std_ulogic_vector(0 to threads-1);
        xu_wl_ex3_flush                 : out std_ulogic_vector(0 to threads-1);
        xu_wl_ex4_flush                 : out std_ulogic_vector(0 to threads-1);
        xu_wl_ex5_flush                 : out std_ulogic_vector(0 to threads-1);
        
        xu_mm_ex4_flush                 : out std_ulogic_vector(0 to threads-1);
        xu_mm_ex5_flush                 : out std_ulogic_vector(0 to threads-1);
        xu_mm_ierat_flush               : out std_ulogic_vector(0 to threads-1);
        xu_mm_ierat_miss                : out std_ulogic_vector(0 to threads-1);
        xu_mm_ex5_perf_itlb             : out std_ulogic_vector(0 to threads-1);
        xu_mm_ex5_perf_dtlb             : out std_ulogic_vector(0 to threads-1);

        xu_iu_run_thread                : out std_ulogic_vector(0 to 3);
        xu_iu_u_flush                   : out std_ulogic_vector(0 to 3);
        xu_iu_l_flush                   : out std_ulogic_vector(0 to 3);
        xu_iu_flush_2ucode              : out std_ulogic_vector(0 to 3);
        xu_iu_flush_2ucode_type         : out std_ulogic_vector(0 to 3);
        xu_iu_ucode_restart             : out std_ulogic_vector(0 to 3);
        xu_iu_ex5_ppc_cpl               : out std_ulogic_vector(0 to threads-1);
        xu_iu_iu0_flush_ifar0           : out std_ulogic_vector(62-eff_ifar to 61);
        xu_iu_iu0_flush_ifar1           : out std_ulogic_vector(62-eff_ifar to 61);
        xu_iu_iu0_flush_ifar2           : out std_ulogic_vector(62-eff_ifar to 61);
        xu_iu_iu0_flush_ifar3           : out std_ulogic_vector(62-eff_ifar to 61);
        xu_iu_uc_flush_ifar0            : out std_ulogic_vector(62-uc_ifar to 61);
        xu_iu_uc_flush_ifar1            : out std_ulogic_vector(62-uc_ifar to 61);
        xu_iu_uc_flush_ifar2            : out std_ulogic_vector(62-uc_ifar to 61);
        xu_iu_uc_flush_ifar3            : out std_ulogic_vector(62-uc_ifar to 61);

        xu_iu_ici                       : out std_ulogic;
        
        xu_iu_ex5_ifar                  : out std_ulogic_vector(62-eff_ifar to 61);
        xu_iu_ex5_val                   : out std_ulogic;
        xu_iu_ex5_tid                   : out std_ulogic_vector(0 to threads-1);
        xu_iu_ex5_br_update             : out std_ulogic;
        xu_iu_ex5_br_hist               : out std_ulogic_vector(0 to 1);
        xu_iu_ex5_br_taken              : out std_ulogic;
        xu_iu_ex5_bclr                  : out std_ulogic;
        xu_iu_ex5_lk                    : out std_ulogic;
        xu_iu_ex5_bh                    : out std_ulogic_vector(0 to 1);

        iu_xu_quiesce                   : in  std_ulogic_vector(0 to threads-1);
        xu_iu_ex6_pri                   : out std_ulogic_vector(0 to 2);
        xu_iu_ex6_pri_val               : out std_ulogic_vector(0 to 3);
        xu_iu_single_instr_mode         : out std_ulogic_vector(0 to threads-1);
        xu_iu_raise_iss_pri             : out std_ulogic_vector(0 to threads-1);
        xu_iu_multdiv_done              : out std_ulogic_vector(0 to threads-1);
        xu_iu_slowspr_done              : out std_ulogic_vector(0 to 3);
        xu_iu_need_hole                 : out std_ulogic;
        xu_iu_ex5_gshare                : out std_ulogic_vector(0 to 3);
        xu_iu_ex5_getNIA                : out std_ulogic;

        fu_xu_rf1_act                   : in  std_ulogic_vector(0 to threads-1);
        fu_xu_ex2_ifar_val              : in  std_ulogic_vector(0 to threads-1);
        fu_xu_ex2_ifar_issued           : in  std_ulogic_vector(0 to threads-1);
        fu_xu_ex1_ifar0                 : in  std_ulogic_vector(62-eff_ifar to 61);
        fu_xu_ex1_ifar1                 : in  std_ulogic_vector(62-eff_ifar to 61);
        fu_xu_ex1_ifar2                 : in  std_ulogic_vector(62-eff_ifar to 61);
        fu_xu_ex1_ifar3                 : in  std_ulogic_vector(62-eff_ifar to 61);
        fu_xu_ex2_instr_type            : in  std_ulogic_vector(0 to 3*threads-1);
        fu_xu_ex2_instr_match           : in  std_ulogic_vector(0 to threads-1);
        fu_xu_ex2_is_ucode              : in  std_ulogic_vector(0 to threads-1);
        fu_xu_ex3_trap                  : in  std_ulogic_vector(0 to threads-1);
        fu_xu_ex3_ap_int_req            : in  std_ulogic_vector(0 to threads-1);
        fu_xu_ex3_n_flush               : in  std_ulogic_vector(0 to threads-1);
        fu_xu_ex3_np1_flush             : in  std_ulogic_vector(0 to threads-1);
        fu_xu_ex3_flush2ucode           : in  std_ulogic_vector(0 to threads-1);
        fu_xu_ex2_async_block           : in  std_ulogic_vector(0 to threads-1);

        fu_xu_ex4_cr_val                : in  std_ulogic_vector(0 to threads-1);
        fu_xu_ex4_cr_noflush            : in  std_ulogic_vector(0 to threads-1);
        fu_xu_ex4_cr0                   : in  std_ulogic_vector(0 to 3);
        fu_xu_ex4_cr0_bf                : in  std_ulogic_vector(0 to 2);
        fu_xu_ex4_cr1                   : in  std_ulogic_vector(0 to 3);
        fu_xu_ex4_cr1_bf                : in  std_ulogic_vector(0 to 2);
        fu_xu_ex4_cr2                   : in  std_ulogic_vector(0 to 3);
        fu_xu_ex4_cr2_bf                : in  std_ulogic_vector(0 to 2);
        fu_xu_ex4_cr3                   : in  std_ulogic_vector(0 to 3);
        fu_xu_ex4_cr3_bf                : in  std_ulogic_vector(0 to 2);

        xu_fu_ex3_eff_addr              : out std_ulogic_vector(59 to 63);
        xu_fu_ex5_reload_val            : out std_ulogic;
        xu_fu_ex5_load_le               : out std_ulogic;
        xu_fu_ex5_load_val              : out std_ulogic_vector(0 to threads-1);
        xu_fu_ex5_load_tag              : out std_ulogic_vector(0 to 8);
        xu_fu_ex6_load_data             : out std_ulogic_vector(0 to 255);

        fu_xu_ex2_store_data_val        : in  std_ulogic;
        fu_xu_ex2_store_data            : in  std_ulogic_vector(0 to 255);

        ac_an_req_pwr_token             : out std_ulogic;
        ac_an_req                       : out std_ulogic;
        ac_an_req_ra                    : out std_ulogic_vector(64-real_data_add to 63);
        ac_an_req_ttype                 : out std_ulogic_vector(0 to 5);
        ac_an_req_thread                : out std_ulogic_vector(0 to 2);
        ac_an_req_wimg_w                : out std_ulogic;
        ac_an_req_wimg_i                : out std_ulogic;
        ac_an_req_wimg_m                : out std_ulogic;
        ac_an_req_wimg_g                : out std_ulogic;
        ac_an_req_user_defined          : out std_ulogic_vector(0 to 3);
        ac_an_req_spare_ctrl_a0         : out std_ulogic_vector(0 to 3);
        ac_an_req_ld_core_tag           : out std_ulogic_vector(0 to 4);
        ac_an_req_ld_xfr_len            : out std_ulogic_vector(0 to 2);
        ac_an_st_byte_enbl              : out std_ulogic_vector(0 to 15+(st_data_32B_mode*16));
        ac_an_st_data                   : out std_ulogic_vector(0 to 127+(st_data_32B_mode*128));
        ac_an_req_endian                : out std_ulogic;
        ac_an_st_data_pwr_token         : out std_ulogic;

        xu_mm_rf1_val                   : out std_ulogic_vector(0 to 3);
        xu_mm_rf1_is_tlbre              : out std_ulogic;
        xu_mm_rf1_is_tlbwe              : out std_ulogic;
        xu_mm_rf1_is_tlbsx              : out std_ulogic;
        xu_mm_rf1_is_tlbsrx             : out std_ulogic;
        xu_mm_rf1_is_tlbivax            : out std_ulogic;
        xu_mm_rf1_is_tlbilx             : out std_ulogic;
        xu_mm_rf1_is_erativax           : out std_ulogic;
        xu_mm_rf1_is_eratilx            : out std_ulogic;
        xu_mm_ex1_is_isync              : out std_ulogic;
        xu_mm_ex1_is_csync              : out std_ulogic;
        xu_mm_rf1_t                     : out std_ulogic_vector(0 to 2);
        xu_mm_ex1_rs_is                 : out std_ulogic_vector(0 to 8);
        xu_mm_ex2_eff_addr              : out std_ulogic_vector(64-(2**regmode) to 63);

        xu_iu_rf1_val                   : out std_ulogic_vector(0 to 3);
        xu_iu_rf1_is_eratre             : out std_ulogic;
        xu_iu_rf1_is_eratwe             : out std_ulogic;
        xu_iu_rf1_is_eratsx             : out std_ulogic;
        xu_iu_rf1_is_eratilx            : out std_ulogic;
        xu_iu_ex1_is_isync              : out std_ulogic;
        xu_iu_ex1_is_csync              : out std_ulogic;
        xu_iu_rf1_ws                    : out std_ulogic_vector(0 to 1);
        xu_iu_rf1_t                     : out std_ulogic_vector(0 to 2);
        xu_iu_ex1_rs_is                 : out std_ulogic_vector(0 to 8);
        xu_iu_ex1_ra_entry              : out std_ulogic_vector(8 to 11);
        xu_iu_ex1_rb                    : out std_ulogic_vector(64-(2**regmode) to 51);
        xu_iu_ex4_rs_data               : out std_ulogic_vector(64-(2**regmode) to 63);
        iu_xu_ex4_tlb_data              : in  std_ulogic_vector(64-(2**regmode) to 63);

        mm_xu_illeg_instr               : in  std_ulogic_vector(0 to threads-1);

        mm_xu_tlb_miss                  : in  std_ulogic_vector(0 to threads-1);
        mm_xu_eratmiss_done             : in  std_ulogic_vector(0 to threads-1);

        mm_xu_hold_req                  : in  std_ulogic_vector(0 to threads-1);
        mm_xu_hold_done                 : in  std_ulogic_vector(0 to threads-1);
        xu_mm_hold_ack                  : out std_ulogic_vector(0 to threads-1);

        mm_xu_pt_fault                  : in  std_ulogic_vector(0 to threads-1);
        mm_xu_tlb_inelig                : in  std_ulogic_vector(0 to threads-1);
        mm_xu_lrat_miss                 : in  std_ulogic_vector(0 to threads-1);
        mm_xu_hv_priv                   : in  std_ulogic_vector(0 to threads-1);
        mm_xu_esr_pt                    : in  std_ulogic_vector(0 to threads-1);
        mm_xu_esr_data                  : in  std_ulogic_vector(0 to threads-1);
        mm_xu_esr_epid                  : in  std_ulogic_vector(0 to threads-1);
        mm_xu_esr_st                    : in  std_ulogic_vector(0 to threads-1);
        mm_xu_ex3_flush_req             : in  std_ulogic_vector(0 to threads-1);
        xu_mm_rf1_is_tlbsxr             : out std_ulogic;

        xu_mm_lmq_stq_empty             : out std_ulogic;
        mm_xu_quiesce                   : in  std_ulogic_vector(0 to threads-1);

        xu_mm_derat_req                 : out std_ulogic;
        xu_mm_derat_epn                 : out std_ulogic_vector(62-eff_ifar to 51);
        xu_mm_derat_thdid               : out std_ulogic_vector(0 to 3);
        xu_mm_derat_state               : out std_ulogic_vector(0 to 3);
        xu_mm_derat_ttype               : out std_ulogic_vector(0 to 1);
        xu_mm_derat_tid                 : out std_ulogic_vector(0 to 13);
        xu_mm_derat_lpid                : out std_ulogic_vector(0 to 7);

        mm_xu_local_snoop_reject        : in  std_ulogic_vector(0 to threads-1);
        mm_xu_lru_par_err               : in  std_ulogic_vector(0 to threads-1);
        mm_xu_tlb_par_err               : in  std_ulogic_vector(0 to threads-1);
        mm_xu_tlb_multihit_err          : in  std_ulogic_vector(0 to threads-1);

        mm_xu_derat_rel_val             : in  std_ulogic_vector(0 to 4);
        mm_xu_derat_rel_data            : in  std_ulogic_vector(0 to 131);

        mm_xu_derat_snoop_coming        : in  std_ulogic;
        mm_xu_derat_snoop_val           : in  std_ulogic;
        mm_xu_derat_snoop_attr          : in  std_ulogic_vector(0 to 25);
        mm_xu_derat_snoop_vpn           : in  std_ulogic_vector(64-(2**REGMODE) to 51);
        xu_mm_derat_snoop_ack           : out std_ulogic;

        mm_xu_derat_pid0                : in  std_ulogic_vector(0 to 13);
        mm_xu_derat_pid1                : in  std_ulogic_vector(0 to 13);
        mm_xu_derat_pid2                : in  std_ulogic_vector(0 to 13);
        mm_xu_derat_pid3                : in  std_ulogic_vector(0 to 13);
        mm_xu_derat_mmucr0_0            : in  std_ulogic_vector(0 to 19);
        mm_xu_derat_mmucr0_1            : in  std_ulogic_vector(0 to 19);
        mm_xu_derat_mmucr0_2            : in  std_ulogic_vector(0 to 19);
        mm_xu_derat_mmucr0_3            : in  std_ulogic_vector(0 to 19);
        xu_mm_derat_mmucr0              : out std_ulogic_vector(0 to 17);
        xu_mm_derat_mmucr0_we           : out std_ulogic_vector(0 to 3);
        mm_xu_derat_mmucr1              : in  std_ulogic_vector(0 to 9);
        xu_mm_derat_mmucr1              : out std_ulogic_vector(0 to 4);
        xu_mm_derat_mmucr1_we           : out std_ulogic;

        xu_mm_spr_epcr_dmiuh            : out std_ulogic_vector(0 to threads-1);
        xu_mm_spr_epcr_dgtmi            : out std_ulogic_vector(0 to threads-1);
        xu_iu_spr_ccr2_ifratsc          : out std_ulogic_vector(0 to 8);
        xu_iu_spr_ccr2_ifrat            : out std_ulogic;
        xu_bx_ccr2_en_ditc              : out std_ulogic;
        xu_iu_spr_xer0                  : out std_ulogic_vector(57 to 63);
        xu_iu_spr_xer1                  : out std_ulogic_vector(57 to 63);
        xu_iu_spr_xer2                  : out std_ulogic_vector(57 to 63);
        xu_iu_spr_xer3                  : out std_ulogic_vector(57 to 63);
        xu_iu_msr_gs                    : out std_ulogic_vector(0 to threads-1);
        xu_iu_msr_hv                    : out std_ulogic_vector(0 to threads-1);
        xu_iu_msr_pr                    : out std_ulogic_vector(0 to threads-1);
        xu_iu_msr_is                    : out std_ulogic_vector(0 to threads-1);
        xu_iu_msr_cm                    : out std_ulogic_vector(0 to threads-1);
        xu_iu_hid_mmu_mode              : out std_ulogic;
        xu_iu_xucr0_rel                 : out std_ulogic;
        xu_mm_msr_gs                    : out std_ulogic_vector(0 to threads-1);
        xu_mm_msr_pr                    : out std_ulogic_vector(0 to threads-1);
        xu_mm_msr_is                    : out std_ulogic_vector(0 to threads-1);
        xu_mm_msr_ds                    : out std_ulogic_vector(0 to threads-1);
        xu_mm_msr_cm                    : out std_ulogic_vector(0 to threads-1);
        xu_mm_hid_mmu_mode              : out std_ulogic;
        xu_fu_msr_pr                    : out std_ulogic_vector(0 to threads-1);
        xu_fu_msr_gs                    : out std_ulogic_vector(0 to threads-1);
        xu_fu_msr_fp                    : out std_ulogic_vector(0 to threads-1);
        xu_fu_msr_spv                   : out std_ulogic_vector(0 to threads-1);
        xu_fu_ccr2_ap                   : out std_ulogic_vector(0 to threads-1);
        xu_iu_xucr4_mmu_mchk            : out std_ulogic;
        xu_mm_xucr4_mmu_mchk            : out std_ulogic;

        slowspr_val_out                 : out std_ulogic;
        slowspr_rw_out                  : out std_ulogic;
        slowspr_etid_out                : out std_ulogic_vector(0 to 1);
        slowspr_addr_out                : out std_ulogic_vector(0 to 9);
        slowspr_data_out                : out std_ulogic_vector(64-(2**regmode) to 63);
        slowspr_done_out                : out std_ulogic;
        slowspr_val_in                  : in  std_ulogic;
        slowspr_rw_in                   : in  std_ulogic;
        slowspr_etid_in                 : in  std_ulogic_vector(0 to 1);
        slowspr_addr_in                 : in  std_ulogic_vector(0 to 9);
        slowspr_data_in                 : in  std_ulogic_vector(64-(2**regmode) to 63);
        slowspr_done_in                 : in  std_ulogic;

        xu_iu_spr_ccr2_en_dcr           : out std_ulogic;

        xu_bx_ex1_mtdp_val              : out std_ulogic;                  
        xu_bx_ex1_mfdp_val              : out std_ulogic;                  
        xu_bx_ex1_ipc_thrd              : out std_ulogic_vector(0 to 1);   
        xu_bx_ex2_ipc_ba                : out std_ulogic_vector(0 to 4);   
        xu_bx_ex2_ipc_sz                : out std_ulogic_vector(0 to 1);   
        xu_bx_ex4_256st_data            : out std_ulogic_vector(128 to 255); 
        bx_xu_ex4_mtdp_cr_status        : in  std_ulogic;                  
        bx_xu_ex4_mfdp_cr_status        : in  std_ulogic;                  
        bx_xu_ex5_dp_data               : in  std_ulogic_vector(0 to 127); 
        bx_xu_quiesce                   : in  std_ulogic_vector(0 to 3);   
        bx_lsu_ob_pwr_tok               : in  std_ulogic;
        bx_lsu_ob_req_val               : in  std_ulogic;                  
        bx_lsu_ob_ditc_val              : in  std_ulogic;                  
        bx_lsu_ob_thrd                  : in  std_ulogic_vector(0 to 1);   
        bx_lsu_ob_qw                    : in  std_ulogic_vector(58 to 59); 
        bx_lsu_ob_dest                  : in  std_ulogic_vector(0 to 14);  
        bx_lsu_ob_data                  : in  std_ulogic_vector(0 to 127); 
        bx_lsu_ob_addr                  : in  std_ulogic_vector(64-real_data_add to 57); 
        lsu_bx_cmd_avail                : out std_ulogic;
        lsu_bx_cmd_sent    : out std_ulogic;
        lsu_bx_cmd_stall                : out std_ulogic;

        xu_iu_reld_core_tag           :out     std_ulogic_vector(0 to 4);
        xu_iu_reld_core_tag_clone     :out     std_ulogic_vector(1 to 4);
        xu_iu_reld_data               :out     std_ulogic_vector(0 to 127);
        xu_iu_reld_data_coming_clone  :out     std_ulogic;
        xu_iu_reld_data_vld           :out     std_ulogic;
        xu_iu_reld_data_vld_clone     :out     std_ulogic;
        xu_iu_reld_ditc_clone         :out     std_ulogic;
        xu_iu_reld_ecc_err            :out     std_ulogic;
        xu_iu_reld_ecc_err_ue         :out     std_ulogic;
        xu_iu_reld_qw                 :out     std_ulogic_vector(57 to 59);


        xu_pc_err_mcsr_summary          : out std_ulogic_vector(0 to threads-1);
        xu_pc_err_local_snoop_reject    : out std_ulogic;
        xu_pc_err_tlb_lru_parity        : out std_ulogic;
        xu_pc_err_ext_mchk              : out std_ulogic;
        xu_pc_err_ierat_multihit        : out std_ulogic;
        xu_pc_err_derat_multihit        : out std_ulogic;
        xu_pc_err_tlb_multihit          : out std_ulogic;
        xu_pc_err_ierat_parity          : out std_ulogic;
        xu_pc_err_derat_parity          : out std_ulogic;
        xu_pc_err_tlb_parity            : out std_ulogic;
        xu_pc_err_mchk_disabled         : out std_ulogic;
        xu_pc_err_ditc_overrun          : out std_ulogic;
        xu_pc_err_dcache_parity         : out std_ulogic;
        xu_pc_err_dcachedir_parity      : out std_ulogic;
        xu_pc_err_dcachedir_multihit    : out std_ulogic;
        xu_pc_err_sprg_ecc              : out std_ulogic_vector(0 to threads-1);
        xu_pc_err_regfile_parity        : out std_ulogic_vector(0 to threads-1);
        xu_pc_err_llbust_attempt        : out std_ulogic_vector(0 to threads-1);
        xu_pc_err_llbust_failed         : out std_ulogic_vector(0 to threads-1);
        xu_pc_err_l2intrf_ecc           : out std_ulogic;
        xu_pc_err_l2intrf_ue            : out std_ulogic;
        xu_pc_err_attention_instr       : out std_ulogic_vector(0 to threads-1);
        xu_pc_err_nia_miscmpr           : out std_ulogic_vector(0 to threads-1);
        xu_pc_err_wdt_reset             : out std_ulogic_vector(0 to threads-1);
        xu_pc_err_debug_event           : out std_ulogic_vector(0 to threads-1);
        xu_pc_err_invld_reld            : out std_ulogic;
        xu_pc_err_l2credit_overrun      : out std_ulogic;

        pc_xu_inj_dcache_parity         : in  std_ulogic;
        pc_xu_inj_dcachedir_parity      : in  std_ulogic;
        pc_xu_inj_dcachedir_multihit    : in  std_ulogic;
        pc_xu_inj_llbust_attempt        : in  std_ulogic_vector(0 to threads-1);
        pc_xu_inj_llbust_failed         : in  std_ulogic_vector(0 to threads-1);
        pc_xu_inj_wdt_reset             : in  std_ulogic_vector(0 to threads-1);

        pc_xu_ram_mode                  : in  std_ulogic;
        pc_xu_ram_thread                : in  std_ulogic_vector(0 to 1);
        pc_xu_ram_execute               : in  std_ulogic;
        pc_xu_ram_flush_thread          : in  std_ulogic;
        xu_iu_ram_issue                 : out std_ulogic_vector(0 to threads-1);
        xu_pc_ram_interrupt             : out std_ulogic;
        xu_pc_ram_done                  : out std_ulogic;
        xu_pc_ram_data                  : out std_ulogic_vector(64-(2**regmode) to 63);

        pc_xu_stop                      : in  std_ulogic_vector(0 to 3);  
        pc_xu_step                      : in  std_ulogic_vector(0 to 3);  
        pc_xu_dbg_action                : in  std_ulogic_vector(0 to 11);
        pc_xu_force_ude                 : in  std_ulogic_vector(0 to threads-1);
        xu_pc_step_done                 : out std_ulogic_vector(0 to threads-1);
        xu_pc_running                   : out std_ulogic_vector(0 to 3);  
        xu_pc_spr_ccr0_we               : out std_ulogic_vector(0 to threads-1);
        xu_pc_stop_dbg_event            : out std_ulogic_vector(0 to threads-1);
        xu_pc_spr_ccr0_pme              : out std_ulogic_vector(0 to 1);
        pc_xu_msrovride_enab            : in  std_ulogic;
        pc_xu_msrovride_pr              : in  std_ulogic;
        pc_xu_msrovride_gs              : in  std_ulogic;
        pc_xu_msrovride_de              : in  std_ulogic;

        pc_xu_extirpts_dis_on_stop      : in  std_ulogic;
        pc_xu_timebase_dis_on_stop      : in  std_ulogic;
        pc_xu_decrem_dis_on_stop        : in  std_ulogic;

        pc_xu_trace_bus_enable          : in  std_ulogic;
        pc_xu_debug_mux1_ctrls          : in  std_ulogic_vector(0 to 15);
        pc_xu_debug_mux2_ctrls          : in  std_ulogic_vector(0 to 15);
        pc_xu_debug_mux3_ctrls          : in  std_ulogic_vector(0 to 15);
        pc_xu_debug_mux4_ctrls          : in  std_ulogic_vector(0 to 15);
        trigger_data_in                 : in  std_ulogic_vector(0 to 11);
        debug_data_in                   : in  std_ulogic_vector(0 to 87);
        trigger_data_out                : out std_ulogic_vector(0 to 11);
        debug_data_out                  : out std_ulogic_vector(0 to 87);

        pc_xu_event_bus_enable          : in  std_ulogic;
        xu_pc_lsu_event_data            : out std_ulogic_vector(0 to 7);
        xu_pc_event_data                : out std_ulogic_vector(0 to 7);
        pc_xu_event_mux_ctrls           : in  std_ulogic_vector(0 to 47);
        pc_xu_lsu_event_mux_ctrls       : in  std_ulogic_vector(0 to 47);
        pc_xu_cache_par_err_event       : in  std_ulogic;

        pc_xu_instr_trace_mode          : in  std_ulogic;
        pc_xu_instr_trace_tid           : in  std_ulogic_vector(0 to 1);
        pc_xu_event_count_mode          : in  std_ulogic_vector(0 to 2);

        ac_tc_reset_1_request           : out std_ulogic;
        ac_tc_reset_2_request           : out std_ulogic;
        ac_tc_reset_3_request           : out std_ulogic;
        ac_tc_reset_wd_request          : out std_ulogic;

        pc_xu_ccflush_dc                : in  std_ulogic;
        an_ac_scan_diag_dc              : in  std_ulogic;
        an_ac_scan_dis_dc_b             : in  std_ulogic;
        an_ac_atpg_en_dc                : in  std_ulogic;
        
        pc_xu_gptr_sl_thold_3           : in  std_ulogic;
        pc_xu_time_sl_thold_3           : in  std_ulogic;
        pc_xu_repr_sl_thold_3           : in  std_ulogic;
        pc_xu_abst_sl_thold_3           : in  std_ulogic;
        pc_xu_abst_slp_sl_thold_3       : in  std_ulogic;
        pc_xu_regf_sl_thold_3           : in  std_ulogic;
        pc_xu_regf_slp_sl_thold_3       : in  std_ulogic;
        pc_xu_func_sl_thold_3           : in  std_ulogic_vector(0 to 4);
        pc_xu_func_slp_sl_thold_3       : in  std_ulogic_vector(0 to 4);
        pc_xu_cfg_sl_thold_3            : in  std_ulogic;
        pc_xu_cfg_slp_sl_thold_3        : in  std_ulogic;
        pc_xu_func_nsl_thold_3          : in  std_ulogic;
        pc_xu_func_slp_nsl_thold_3      : in  std_ulogic;
        pc_xu_ary_nsl_thold_3           : in  std_ulogic;
        pc_xu_ary_slp_nsl_thold_3       : in  std_ulogic;
        pc_xu_sg_3                      : in  std_ulogic_vector(0 to 4);
        pc_xu_fce_3                     : in  std_ulogic_vector(0 to 1);
        pc_xu_bolt_sl_thold_3           : in  std_ulogic;

        gptr_scan_in                    : in  std_ulogic;
        time_scan_in                    : in  std_ulogic;
        repr_scan_in                    : in  std_ulogic;
        abst_scan_in                    : in  std_ulogic_vector(0 to 2);
        func_scan_in                    : in  std_ulogic_vector(31 to 58);
        bcfg_scan_in                    : in  std_ulogic;
        ccfg_scan_in                    : in  std_ulogic;
        dcfg_scan_in                    : in  std_ulogic;
        regf_scan_in                    : in  std_ulogic_vector(0 to 6); 

        gptr_scan_out                   : out std_ulogic;
        time_scan_out                   : out std_ulogic;
        repr_scan_out                   : out std_ulogic;
        abst_scan_out                   : out std_ulogic_vector(0 to 2);
        func_scan_out                   : out std_ulogic_vector(31 to 58);
        bcfg_scan_out                   : out std_ulogic;
        ccfg_scan_out                   : out std_ulogic;
        dcfg_scan_out                   : out std_ulogic;
        regf_scan_out                   : out std_ulogic_vector(0 to 6);

        pc_xu_init_reset                : in  std_ulogic;
        pc_xu_reset_wd_complete         : in  std_ulogic;
        pc_xu_reset_1_complete          : in  std_ulogic;
        pc_xu_reset_2_complete          : in  std_ulogic;
        pc_xu_reset_3_complete          : in  std_ulogic;

        xu_pc_err_sprg_ue               : out std_ulogic_vector(0 to 3);
        xu_pc_err_regfile_ue            : out std_ulogic_vector(0 to 3);

        iu_xu_ierat_ex2_flush_req       : in  std_ulogic_vector(0 to threads-1);
        iu_xu_ierat_ex3_par_err         : in  std_ulogic_vector(0 to threads-1);
        iu_xu_ierat_ex4_par_err         : in  std_ulogic_vector(0 to threads-1);
        pc_xu_inj_sprg_ecc              : in  std_ulogic_vector(0 to 3);
        pc_xu_inj_regfile_parity        : in  std_ulogic_vector(0 to 3);
        fu_xu_ex3_regfile_err_det       : in  std_ulogic_vector(0 to threads-1);
        xu_fu_regfile_seq_beg           : out std_ulogic;
        fu_xu_regfile_seq_end           : in  std_ulogic;

        nclk                            : in clk_logic;
        vdd                             : inout power_logic;
        gnd                             : inout power_logic;
        vcs                             : inout power_logic;

        an_ac_lbist_ary_wrt_thru_dc     : in  std_ulogic;
        xu_fu_lbist_ary_wrt_thru_dc     : out std_ulogic;
        pc_xu_abist_dcomp_g6t_2r        : in  std_ulogic_vector(0 to 3);
        pc_xu_abist_di_g6t_2r           : in  std_ulogic_vector(0 to 3);
        pc_xu_abist_g6t_bw              : in  std_ulogic_vector(0 to 1);
        pc_xu_abist_g6t_r_wb            : in  std_ulogic;
        pc_xu_abist_g8t1p_renb_0        : in  std_ulogic;
        pc_xu_abist_g8t_bw_0            : in  std_ulogic;
        pc_xu_abist_g8t_bw_1            : in  std_ulogic;
        pc_xu_abist_g8t_dcomp           : in  std_ulogic_vector(0 to 3);
        pc_xu_abist_g8t_wenb            : in  std_ulogic;
        pc_xu_abist_wl32_comp_ena       : in  std_ulogic;
        pc_xu_abist_wl512_comp_ena      : in  std_ulogic;
        an_ac_lbist_en_dc               : in  std_ulogic;
        xu_fu_lbist_en_dc               : out std_ulogic;
        pc_xu_abist_raddr_0             : in  std_ulogic_vector(0 to 9);
        pc_xu_abist_raddr_1             : in  std_ulogic_vector(0 to 9);
        pc_xu_abist_grf_renb_0          : in  std_ulogic;
        pc_xu_abist_grf_renb_1          : in  std_ulogic;
        pc_xu_abist_ena_dc              : in  std_ulogic;
        pc_xu_abist_waddr_0             : in  std_ulogic_vector(0 to 9);
        pc_xu_abist_waddr_1             : in  std_ulogic_vector(0 to 9);
        pc_xu_abist_grf_wenb_0          : in  std_ulogic;
        pc_xu_abist_grf_wenb_1          : in  std_ulogic;
        pc_xu_abist_di_0                : in  std_ulogic_vector(0 to 3);
        pc_xu_abist_di_1                : in  std_ulogic_vector(0 to 3);
        pc_xu_abist_wl144_comp_ena      : in  std_ulogic;
        pc_xu_abist_raw_dc_b            : in  std_ulogic;
        
        pc_xu_bo_enable_3               : in std_ulogic;
        pc_xu_bo_unload                 : in std_ulogic;
        pc_xu_bo_load                   : in std_ulogic;
        pc_xu_bo_repair                 : in std_ulogic;
        pc_xu_bo_reset                  : in std_ulogic;
        pc_xu_bo_shdata                 : in std_ulogic;
        pc_xu_bo_select                 : in std_ulogic_vector(0 to 8);
        xu_pc_bo_fail                   : out std_ulogic_vector(0 to 8);
        xu_pc_bo_diagout                : out std_ulogic_vector(0 to 8)
        
    );
--  synopsys translate_off
--  synopsys translate_on
end xuq;

architecture xuq of xuq is

constant tidn                           : std_ulogic_vector(0 to 63) := (others=>'0');
constant regsize                        : integer :=  2**regmode;

signal xu_lsu_ex1_store_data            :std_ulogic_vector(64-(2**regmode) to 63);
signal xu_lsu_ex1_eff_addr              :std_ulogic_vector(64-(dc_size-3) to 63);
signal lsu_xu_rel_ta_gpr                :std_ulogic_vector(0 to 7);
signal lsu_xu_rot_ex6_data_b            :std_ulogic_vector(64-(2**regmode) to 63);
signal lsu_xu_rel_wren                  :std_ulogic;
signal lsu_xu_rot_rel_data              :std_ulogic_vector(64-(2**regmode) to 63);
signal is2_flush                        :std_ulogic_vector(0 to threads-1);
signal rf0_flush                        :std_ulogic_vector(0 to threads-1);
signal rf1_flush                        :std_ulogic_vector(0 to threads-1);
signal ex1_flush                        :std_ulogic_vector(0 to threads-1);
signal ex2_flush                        :std_ulogic_vector(0 to threads-1);
signal ex3_flush                        :std_ulogic_vector(0 to threads-1);
signal ex4_flush                        :std_ulogic_vector(0 to threads-1);
signal ex5_flush                        :std_ulogic_vector(0 to threads-1);
signal xu_lsu_ex4_flush_local           :std_ulogic_vector(0 to threads-1);
signal xu_iu_iu0_flush_ifar             :std_ulogic_vector(0 to eff_ifar*threads-1);
signal xu_iu_uc_flush_ifar              :std_ulogic_vector(0 to uc_ifar*threads-1);
signal xu_lsu_rf0_derat_val             :std_ulogic_vector(0 to threads-1);
signal xu_lsu_rf1_data_act              :std_ulogic;
signal xu_lsu_rf0_derat_is_extload      :std_ulogic;
signal xu_lsu_rf0_derat_is_extstore     :std_ulogic;
signal xu_rf1_val                       :std_ulogic_vector(0 to 3);
signal xu_rf1_is_eratilx                :std_ulogic;
signal xu_ex1_is_isync                  :std_ulogic;
signal xu_ex1_is_csync                  :std_ulogic;
signal xu_rf1_ws                        :std_ulogic_vector(0 to 1);
signal xu_rf1_t                         :std_ulogic_vector(0 to 2);
signal xu_ex1_rs_is                     :std_ulogic_vector(0 to 8);
signal xu_ex1_ra_entry                  :std_ulogic_vector(8 to 11);
signal xu_ex4_rs_data                   :std_ulogic_vector(64-(2**regmode) to 63);
signal xu_msr_gs                        :std_ulogic_vector(0 to threads-1);
signal xu_msr_pr                        :std_ulogic_vector(0 to threads-1);
signal xu_msr_is                        :std_ulogic_vector(0 to threads-1);
signal xu_msr_ds                        :std_ulogic_vector(0 to threads-1);
signal cpl_msr_gs                       :std_ulogic_vector(0 to threads-1);
signal cpl_msr_pr                       :std_ulogic_vector(0 to threads-1);
signal cpl_msr_fp                       :std_ulogic_vector(0 to threads-1);
signal cpl_msr_spv                      :std_ulogic_vector(0 to threads-1);
signal cpl_ccr2_ap                      :std_ulogic_vector(0 to threads-1);
signal xu_msr_cm                        :std_ulogic_vector(0 to threads-1);
signal xu_lsu_hid_mmu_mode              :std_ulogic;
signal xu_iu_spr_xer                    :std_ulogic_vector(0 to 7*threads-1);
signal xu_lsu_rf1_axu_ldst_falign       :std_ulogic;
signal fu_xu_ex1_ifar                   :std_ulogic_vector(0 to eff_ifar*threads-1);
signal xu_lsu_ex1_rotsel_ovrd           :std_ulogic_vector(0 to 4);
signal xu_lsu_ici                       :std_ulogic;
signal lsu_xu_ldq_barr_done             :std_ulogic_vector(0 to threads-1);
signal lsu_xu_barr_done                 :std_ulogic_vector(0 to threads-1);
signal lsu_xu_rel_dvc_thrd_id           :std_ulogic_vector(0 to 3);
signal lsu_xu_ex2_dvc1_st_cmp           :std_ulogic_vector(0 to ((2**regmode)/8)-1);
signal lsu_xu_ex8_dvc1_ld_cmp           :std_ulogic_vector(0 to ((2**regmode)/8)-1);
signal lsu_xu_rel_dvc1_en               :std_ulogic;
signal lsu_xu_rel_dvc1_cmp              :std_ulogic_vector(0 to ((2**regmode)/8)-1);
signal lsu_xu_ex2_dvc2_st_cmp           :std_ulogic_vector(0 to ((2**regmode)/8)-1);
signal lsu_xu_ex8_dvc2_ld_cmp           :std_ulogic_vector(0 to ((2**regmode)/8)-1);
signal lsu_xu_rel_dvc2_en               :std_ulogic;
signal lsu_xu_rel_dvc2_cmp              :std_ulogic_vector(0 to ((2**regmode)/8)-1);
signal xu_ex2_eff_addr                  :std_ulogic_vector(64-(2**regmode) to 63);
signal spr_debug_mux_ctrls              :std_ulogic_vector(0 to 15);
signal cpl_debug_mux_ctrls              :std_ulogic_vector(0 to 15);
signal fxu_debug_mux_ctrls              :std_ulogic_vector(0 to 15);
signal lsu_debug_mux_ctrls              :std_ulogic_vector(0 to 15);
signal lsudat_debug_mux_ctrls           :std_ulogic_vector(0 to 1);
signal lsu_xu_data_debug0               :std_ulogic_vector(0 to 87);
signal lsu_xu_data_debug1               :std_ulogic_vector(0 to 87);
signal lsu_xu_data_debug2               :std_ulogic_vector(0 to 87);
signal sg_2                             :std_ulogic_vector(0 to 3);
signal func_sl_thold_2                  :std_ulogic_vector(0 to 3);
signal func_nsl_thold_2                 :std_ulogic;
signal func_slp_sl_thold_2              :std_ulogic_vector(0 to 1);
signal ary_nsl_thold_2                  :std_ulogic;
signal time_sl_thold_2                  :std_ulogic;
signal abst_sl_thold_2                  :std_ulogic;
signal repr_sl_thold_2                  :std_ulogic;
signal gptr_sl_thold_2                  :std_ulogic;
signal cfg_sl_thold_2                   :std_ulogic;
signal cfg_slp_sl_thold_2               :std_ulogic;
signal regf_slp_sl_thold_2              :std_ulogic;
signal fce_2                            :std_ulogic_vector(0 to 1);
signal clkoff_dc_b                      :std_ulogic;
signal d_mode_dc                        :std_ulogic;
signal delay_lclkr_dc                   :std_ulogic_vector(0 to 4);
signal mpw1_dc_b                        :std_ulogic_vector(0 to 4);
signal mpw2_dc_b                        :std_ulogic;
signal g6t_clkoff_dc_b                  :std_ulogic;
signal g6t_d_mode_dc                    :std_ulogic;
signal g6t_delay_lclkr_dc               :std_ulogic_vector(0 to 4);
signal g6t_mpw1_dc_b                    :std_ulogic_vector(0 to 4);
signal g6t_mpw2_dc_b                    :std_ulogic;

signal fxa_fxb_rf0_val                          :std_ulogic_vector(0 to threads-1);
signal fxa_fxb_rf0_issued                       :std_ulogic_vector(0 to threads-1);
signal fxa_fxb_rf0_ucode_val                    :std_ulogic_vector(0 to threads-1);
signal fxa_fxb_rf0_act                          :std_ulogic;
signal fxa_fxb_ex1_hold_ctr_flush               :std_ulogic;
signal fxa_fxb_rf0_instr                        :std_ulogic_vector(0 to 31);
signal fxa_fxb_rf0_tid                          :std_ulogic_vector(0 to threads-1);
signal fxa_fxb_rf0_ta_vld                       :std_ulogic;
signal fxa_fxb_rf0_ta                           :std_ulogic_vector(0 to 7);
signal fxa_fxb_rf0_error                        :std_ulogic_vector(0 to 2);
signal fxa_fxb_rf0_match                        :std_ulogic;
signal fxa_fxb_rf0_is_ucode                     :std_ulogic;
signal fxa_fxb_rf0_gshare                       :std_ulogic_vector(0 to 3);
signal fxa_fxb_rf0_ifar                         :std_ulogic_vector(62-eff_ifar to 61);
signal fxa_fxb_rf0_s1_vld                       :std_ulogic;
signal fxa_fxb_rf0_s1                           :std_ulogic_vector(0 to 7);
signal fxa_fxb_rf0_s2_vld                       :std_ulogic;
signal fxa_fxb_rf0_s2                           :std_ulogic_vector(0 to 7);
signal fxa_fxb_rf0_s3_vld                       :std_ulogic;
signal fxa_fxb_rf0_s3                           :std_ulogic_vector(0 to 7);
signal fxa_fxb_rf0_axu_instr_type               :std_ulogic_vector(0 to 2);
signal fxa_fxb_rf0_axu_ld_or_st                 :std_ulogic;
signal fxa_fxb_rf0_axu_store                    :std_ulogic;
signal fxa_fxb_rf0_axu_ldst_forcealign          :std_ulogic;
signal fxa_fxb_rf0_axu_ldst_forceexcept         :std_ulogic;
signal fxa_fxb_rf0_axu_ldst_indexed             :std_ulogic;
signal fxa_fxb_rf0_axu_ldst_tag                 :std_ulogic_vector(0 to 8);
signal fxa_fxb_rf0_axu_mftgpr                   :std_ulogic;
signal fxa_fxb_rf0_axu_mffgpr                   :std_ulogic;
signal fxa_fxb_rf0_axu_movedp                   :std_ulogic;
signal fxa_fxb_rf0_axu_ldst_size                :std_ulogic_vector(0 to 5);
signal fxa_fxb_rf0_axu_ldst_update              :std_ulogic;
signal fxa_fxb_rf0_pred_update                  :std_ulogic;
signal fxa_fxb_rf0_pred_taken_cnt               :std_ulogic_vector(0 to 1);
signal fxa_fxb_rf0_mc_dep_chk_val               :std_ulogic_vector(0 to threads-1);
signal fxa_fxb_rf1_mul_val                      :std_ulogic;
signal fxa_fxb_rf1_div_val                      :std_ulogic;
signal fxa_fxb_rf1_div_ctr                      :std_ulogic_vector(0 to 7);
signal fxa_fxb_rf0_xu_epid_instr                :std_ulogic;
signal fxa_fxb_rf0_axu_is_extload               :std_ulogic;
signal fxa_fxb_rf0_axu_is_extstore              :std_ulogic;
signal fxa_fxb_rf0_is_mfocrf                    :std_ulogic;
signal fxa_fxb_rf0_3src_instr                   :std_ulogic;
signal fxa_fxb_rf0_gpr0_zero                    :std_ulogic;
signal fxa_fxb_rf0_use_imm                      :std_ulogic;
signal fxa_fxb_rf1_muldiv_coll                  :std_ulogic;
signal fxa_cpl_ex2_div_coll                     :std_ulogic_vector(0 to threads-1);
signal fxb_fxa_ex7_we0                          :std_ulogic;
signal fxb_fxa_ex7_wa0                          :std_ulogic_vector(0 to 7);
signal fxb_fxa_ex7_wd0                          :std_ulogic_vector(64-regsize to 63);
signal fxa_fxb_rf1_do0                          :std_ulogic_vector(64-regsize to 63);
signal fxa_fxb_rf1_do1                          :std_ulogic_vector(64-regsize to 63);
signal fxa_fxb_rf1_do2                          :std_ulogic_vector(64-regsize to 63);
signal fxb_fxa_ex6_clear_barrier                :std_ulogic_vector(0 to threads-1);
signal dec_cpl_ex3_mc_dep_chk_val               :std_ulogic_vector(0 to threads-1);
signal spr_ccr2_notlb                           :std_ulogic;
signal fxa_fxb_rf0_spr_tid                      :std_ulogic_vector(0 to threads-1);
signal fxa_fxb_rf0_cpl_tid                      :std_ulogic_vector(0 to threads-1);
signal fxa_fxb_rf0_cpl_act                      :std_ulogic;
signal gpr_cpl_ex3_regfile_err_det              :std_ulogic;
signal cpl_gpr_regfile_seq_beg                  :std_ulogic;
signal gpr_cpl_regfile_seq_end                  :std_ulogic;
signal fxa_cpl_debug                            :std_ulogic_vector(0 to 272);
signal cpl_fxa_ex5_set_barr                     :std_ulogic_vector(0 to threads-1);
signal fxa_iu_set_barr_tid                      :std_ulogic_vector(0 to threads-1);
signal cpl_iu_set_barr_tid                      :std_ulogic_vector(0 to threads-1);
signal spr_xucr4_div_barr_thres                 :std_ulogic_vector(0 to 7);
signal ex4_256st_data                           :std_ulogic_vector(0 to 255);
signal ex6_ld_par_err                           :std_ulogic;
signal lsu_xu_ex6_datc_par_err                  :std_ulogic;
signal ex1_optype1                              :std_ulogic;
signal ex1_optype2                              :std_ulogic;
signal ex1_optype4                              :std_ulogic;
signal ex1_optype8                              :std_ulogic;
signal ex1_optype16                             :std_ulogic;
signal ex1_optype32                             :std_ulogic;
signal ex1_saxu_instr                           :std_ulogic;
signal ex1_sdp_instr                            :std_ulogic;
signal ex1_stgpr_instr                          :std_ulogic;
signal ex1_store_instr                          :std_ulogic;
signal ex1_axu_op_val                           :std_ulogic;
signal ex3_algebraic                            :std_ulogic;
signal ex3_data_swap                            :std_ulogic;
signal ex3_thrd_id                              :std_ulogic_vector(0 to 3);
signal rel_upd_dcarr_val                        :std_ulogic;
signal dcarr_up_way_addr                        :std_ulogic_vector(0 to 2);
signal ex4_load_op_hit                          :std_ulogic;
signal ex4_store_hit                            :std_ulogic;
signal ex4_axu_op_val                           :std_ulogic;
signal spr_dvc1_act                             :std_ulogic;
signal spr_dvc2_act                             :std_ulogic;
signal spr_dvc1_dbg                             :std_ulogic_vector(64-(2**regmode) to 63);
signal spr_dvc2_dbg                             :std_ulogic_vector(64-(2**regmode) to 63);
signal ldq_rel_data_val_early                   :std_ulogic;
signal ldq_rel_op_size                          :std_ulogic_vector(0 to 5);
signal ldq_rel_addr                             :std_ulogic_vector(64-(dc_size-3) to 58);
signal ldq_rel_data_val                         :std_ulogic;
signal ldq_rel_rot_sel                          :std_ulogic_vector(0 to 4);
signal ldq_rel_axu_val                          :std_ulogic;
signal ldq_rel_ci                               :std_ulogic;
signal ldq_rel_thrd_id                          :std_ulogic_vector(0 to 3);
signal ldq_rel_le_mode                          :std_ulogic;
signal ldq_rel_algebraic                        :std_ulogic;
signal ldq_rel_256_data                         :std_ulogic_vector(0 to 255);
signal ldq_rel_dvc1_en                          :std_ulogic;
signal ldq_rel_dvc2_en                          :std_ulogic;
signal ldq_rel_beat_crit_qw                     :std_ulogic;
signal ldq_rel_beat_crit_qw_block               :std_ulogic;
signal dec_spr_rf0_instr                        :std_ulogic_vector(0 to 31);
signal ctlspr_time_scan_in                      :std_ulogic;
signal ctlspr_time_scan_out                     :std_ulogic;
signal ctlspr_repr_scan_in                      :std_ulogic;
signal ctlspr_repr_scan_out                     :std_ulogic;
signal ctlspr_gptr_scan_in                      :std_ulogic;
signal ctlspr_gptr_scan_out                     :std_ulogic;
signal fxadat_time_scan_in                      :std_ulogic;
signal fxadat_time_scan_out                     :std_ulogic;
signal fxadat_repr_scan_in                      :std_ulogic;
signal fxadat_repr_scan_out                     :std_ulogic;
signal fxadat_gptr_scan_in                      :std_ulogic;
signal fxadat_gptr_scan_out                     :std_ulogic;
signal xu_lsu_spr_xucr0_dcdis                   :std_ulogic;
signal spr_xucr0_clkg_ctl_b0                    :std_ulogic;
signal fxa_perf_muldiv_in_use                   :std_ulogic;
signal bolt_sl_thold_2                          :std_ulogic;
signal bo_enable_2                              :std_ulogic;
signal abst_scan_2                              :std_ulogic;
signal xu_w_rf1_flush                           :std_ulogic_vector(0 to threads-1);
signal xu_w_ex1_flush                           :std_ulogic_vector(0 to threads-1);
signal xu_w_ex2_flush                           :std_ulogic_vector(0 to threads-1);
signal xu_w_ex3_flush                           :std_ulogic_vector(0 to threads-1);
signal xu_w_ex4_flush                           :std_ulogic_vector(0 to threads-1);
signal xu_w_ex5_flush                           :std_ulogic_vector(0 to threads-1);
signal xu_iu_flush                              :std_ulogic_vector(0 to 3);
signal spr_xucr4_mmu_mchk                       :std_ulogic;

begin


fu_xu_ex1_ifar                  <= fu_xu_ex1_ifar0 & fu_xu_ex1_ifar1 & fu_xu_ex1_ifar2 & fu_xu_ex1_ifar3;
xu_iu_ici                       <= xu_lsu_ici;

xu_mm_rf1_val                   <= xu_rf1_val;
xu_mm_rf1_is_eratilx            <= xu_rf1_is_eratilx;
xu_mm_ex1_is_isync              <= xu_ex1_is_isync;
xu_mm_ex1_is_csync              <= xu_ex1_is_csync;
xu_mm_rf1_t                     <= xu_rf1_t;
xu_mm_ex1_rs_is                 <= xu_ex1_rs_is;
xu_mm_ex2_eff_addr              <= xu_ex2_eff_addr;

xu_iu_rf1_is_eratilx            <= xu_rf1_is_eratilx;
xu_iu_ex1_is_isync              <= xu_ex1_is_isync;
xu_iu_ex1_is_csync              <= xu_ex1_is_csync;
xu_iu_rf1_ws                    <= xu_rf1_ws;
xu_iu_rf1_t                     <= xu_rf1_t;
xu_iu_ex1_rs_is                 <= xu_ex1_rs_is;
xu_iu_ex1_ra_entry              <= xu_ex1_ra_entry(8 to 11);
xu_iu_ex4_rs_data               <= xu_ex4_rs_data;

xu_lsu_hid_mmu_mode             <= spr_ccr2_notlb;
xu_iu_msr_gs                    <= xu_msr_gs;
xu_iu_msr_hv                    <= xu_msr_gs;
xu_iu_msr_pr                    <= xu_msr_pr;
xu_iu_msr_is                    <= xu_msr_is;
xu_iu_msr_cm                    <= xu_msr_cm;
xu_iu_hid_mmu_mode              <= spr_ccr2_notlb;
xu_mm_msr_gs                    <= xu_msr_gs;
xu_mm_msr_pr                    <= xu_msr_pr;
xu_mm_msr_is                    <= xu_msr_is;
xu_mm_msr_ds                    <= xu_msr_ds;
xu_mm_msr_cm                    <= xu_msr_cm;
xu_mm_hid_mmu_mode              <= spr_ccr2_notlb;
xu_fu_msr_gs                    <= cpl_msr_gs;
xu_fu_msr_pr                    <= cpl_msr_pr;
xu_fu_msr_fp                    <= cpl_msr_fp; 
xu_fu_msr_spv                   <= cpl_msr_spv;
xu_fu_ccr2_ap                   <= cpl_ccr2_ap;

xu_iu_xucr4_mmu_mchk            <= spr_xucr4_mmu_mchk;
xu_mm_xucr4_mmu_mchk            <= spr_xucr4_mmu_mchk;
 
xu_n_is2_flush                  <= is2_flush;
xu_n_rf0_flush                  <= rf0_flush;
xu_n_rf1_flush                  <= rf1_flush;
xu_n_ex1_flush                  <= ex1_flush;
xu_n_ex2_flush                  <= ex2_flush;
xu_n_ex3_flush                  <= ex3_flush;
xu_n_ex4_flush                  <= ex4_flush;
xu_n_ex5_flush                  <= ex5_flush;

xu_wu_rf1_flush                 <= xu_w_rf1_flush;
xu_wu_ex1_flush                 <= xu_w_ex1_flush;
xu_wu_ex2_flush                 <= xu_w_ex2_flush;
xu_wu_ex3_flush                 <= xu_w_ex3_flush;
xu_wu_ex4_flush                 <= xu_w_ex4_flush;
xu_wu_ex5_flush                 <= xu_w_ex5_flush;

xu_wl_rf1_flush                 <= xu_w_rf1_flush;
xu_wl_ex1_flush                 <= xu_w_ex1_flush;
xu_wl_ex2_flush                 <= xu_w_ex2_flush;
xu_wl_ex3_flush                 <= xu_w_ex3_flush;
xu_wl_ex4_flush                 <= xu_w_ex4_flush;
xu_wl_ex5_flush                 <= xu_w_ex5_flush;

xu_iu_u_flush                   <= xu_iu_flush;
xu_iu_l_flush                   <= xu_iu_flush;

xu_iu_iu0_flush_ifar0           <= xu_iu_iu0_flush_ifar(0          to 1*eff_ifar-1);
xu_iu_iu0_flush_ifar1           <= xu_iu_iu0_flush_ifar(1*eff_ifar to 2*eff_ifar-1);
xu_iu_iu0_flush_ifar2           <= xu_iu_iu0_flush_ifar(2*eff_ifar to 3*eff_ifar-1);
xu_iu_iu0_flush_ifar3           <= xu_iu_iu0_flush_ifar(3*eff_ifar to 4*eff_ifar-1);
xu_iu_uc_flush_ifar0            <= xu_iu_uc_flush_ifar(0         to 1*uc_ifar-1);
xu_iu_uc_flush_ifar1            <= xu_iu_uc_flush_ifar(1*uc_ifar to 2*uc_ifar-1);
xu_iu_uc_flush_ifar2            <= xu_iu_uc_flush_ifar(2*uc_ifar to 3*uc_ifar-1);
xu_iu_uc_flush_ifar3            <= xu_iu_uc_flush_ifar(3*uc_ifar to 4*uc_ifar-1);
xu_iu_spr_xer0                  <= xu_iu_spr_xer(0 to 6);
xu_iu_spr_xer1                  <= xu_iu_spr_xer(7 to 13);
xu_iu_spr_xer2                  <= xu_iu_spr_xer(14 to 20);
xu_iu_spr_xer3                  <= xu_iu_spr_xer(21 to 27);

xu_iu_set_barr_tid              <= cpl_iu_set_barr_tid or fxa_iu_set_barr_tid;

xu_iu_reld_core_tag           <= an_ac_reld_core_tag(0 to 4);
xu_iu_reld_data               <= an_ac_reld_data(0 to 127);
xu_iu_reld_data_vld           <= an_ac_reld_data_vld;
xu_iu_reld_ecc_err            <= an_ac_reld_ecc_err;
xu_iu_reld_ecc_err_ue         <= an_ac_reld_ecc_err_ue;
xu_iu_reld_qw                 <= an_ac_reld_qw(57 to 59);


xu_fu_lbist_ary_wrt_thru_dc   <= an_ac_lbist_ary_wrt_thru_dc;
xu_fu_lbist_en_dc             <= an_ac_lbist_en_dc;

fxu_debug_mux_ctrls             <= pc_xu_debug_mux1_ctrls;
cpl_debug_mux_ctrls             <= pc_xu_debug_mux2_ctrls;
lsu_debug_mux_ctrls             <= pc_xu_debug_mux3_ctrls;
lsudat_debug_mux_ctrls          <= pc_xu_debug_mux4_ctrls(2 to 3);
spr_debug_mux_ctrls             <= pc_xu_debug_mux4_ctrls;






ctlspr : entity work.xuq_ctrl_spr(xuq_ctrl_spr)
generic map(
        expand_type             => expand_type,
        threads                 => threads,
        eff_ifar                => eff_ifar,
        uc_ifar                 => uc_ifar,
        regsize                 => regsize,
        hvmode                  => hvmode,
        regmode                 => regmode,
        dc_size                 => dc_size,
        cl_size                 => cl_size,
        real_data_add           => real_data_add,
        a2mode                  => a2mode,
        lmq_entries             => lmq_entries,
        l_endian_m              => l_endian_m,
        load_credits            => load_credits,
        store_credits           => store_credits,
        st_data_32B_mode        => st_data_32B_mode,
        spr_xucr0_init_mod      => spr_xucr0_init_mod,
        bcfg_epn_0to15          => bcfg_epn_0to15,
        bcfg_epn_16to31         => bcfg_epn_16to31,
        bcfg_epn_32to47         => bcfg_epn_32to47,
        bcfg_epn_48to51         => bcfg_epn_48to51,
        bcfg_rpn_22to31         => bcfg_rpn_22to31,
        bcfg_rpn_32to47         => bcfg_rpn_32to47,
        bcfg_rpn_48to51         => bcfg_rpn_48to51)
port map(

        an_ac_scan_dis_dc_b                     => an_ac_scan_dis_dc_b,
        an_ac_lbist_en_dc                       => an_ac_lbist_en_dc,
        pc_xu_abist_raddr_0                     => pc_xu_abist_raddr_0(4 to 9),
        pc_xu_abist_ena_dc                      => pc_xu_abist_ena_dc,
        pc_xu_abist_waddr_0                     => pc_xu_abist_waddr_0(4 to 9),
        pc_xu_abist_di_0                        => pc_xu_abist_di_0,
        pc_xu_abist_raw_dc_b                    => pc_xu_abist_raw_dc_b,
        pc_xu_ccflush_dc                        => pc_xu_ccflush_dc,
        clkoff_dc_b                             => clkoff_dc_b,
        d_mode_dc                               => d_mode_dc,
        delay_lclkr_dc                          => delay_lclkr_dc,
        mpw1_dc_b                               => mpw1_dc_b,
        mpw2_dc_b                               => mpw2_dc_b,
        g6t_clkoff_dc_b                         => g6t_clkoff_dc_b,
        g6t_d_mode_dc                           => g6t_d_mode_dc,
        g6t_delay_lclkr_dc                      => g6t_delay_lclkr_dc,
        g6t_mpw1_dc_b                           => g6t_mpw1_dc_b,
        g6t_mpw2_dc_b                           => g6t_mpw2_dc_b,
        pc_xu_sg_3                              => pc_xu_sg_3,
        pc_xu_func_sl_thold_3                   => pc_xu_func_sl_thold_3,
        pc_xu_func_slp_sl_thold_3               => pc_xu_func_slp_sl_thold_3,
        pc_xu_func_nsl_thold_3                  => pc_xu_func_nsl_thold_3,
        pc_xu_func_slp_nsl_thold_3              => pc_xu_func_slp_nsl_thold_3,
        pc_xu_gptr_sl_thold_3                   => pc_xu_gptr_sl_thold_3,
        pc_xu_abst_sl_thold_3                   => pc_xu_abst_sl_thold_3,
        pc_xu_abst_slp_sl_thold_3               => pc_xu_abst_slp_sl_thold_3,
        pc_xu_regf_sl_thold_3                   => pc_xu_regf_sl_thold_3,
        pc_xu_regf_slp_sl_thold_3               => pc_xu_regf_slp_sl_thold_3,
        pc_xu_time_sl_thold_3                   => pc_xu_time_sl_thold_3,
        pc_xu_cfg_sl_thold_3                    => pc_xu_cfg_sl_thold_3,
        pc_xu_cfg_slp_sl_thold_3                => pc_xu_cfg_slp_sl_thold_3,
        pc_xu_ary_nsl_thold_3                   => pc_xu_ary_nsl_thold_3,
        pc_xu_ary_slp_nsl_thold_3               => pc_xu_ary_slp_nsl_thold_3,
        pc_xu_repr_sl_thold_3                   => pc_xu_repr_sl_thold_3,
        pc_xu_fce_3                             => pc_xu_fce_3,
        an_ac_scan_diag_dc                      => an_ac_scan_diag_dc,
        sg_2                                    => sg_2,
        fce_2                                   => fce_2,
        func_sl_thold_2                         => func_sl_thold_2,
        func_slp_sl_thold_2                     => func_slp_sl_thold_2,
        func_nsl_thold_2                        => func_nsl_thold_2,
        abst_sl_thold_2                         => abst_sl_thold_2,
        time_sl_thold_2                         => time_sl_thold_2,
        ary_nsl_thold_2                         => ary_nsl_thold_2,
        repr_sl_thold_2                         => repr_sl_thold_2,
        gptr_sl_thold_2                         => gptr_sl_thold_2,
        cfg_sl_thold_2                          => cfg_sl_thold_2,
        cfg_slp_sl_thold_2                      => cfg_slp_sl_thold_2,
        regf_slp_sl_thold_2                     => regf_slp_sl_thold_2,
        pc_xu_bolt_sl_thold_3                   => pc_xu_bolt_sl_thold_3,
        pc_xu_bo_enable_3                       => pc_xu_bo_enable_3,
        bolt_sl_thold_2                         => bolt_sl_thold_2,
        bo_enable_2                             => bo_enable_2,
        pc_xu_bo_unload                         => pc_xu_bo_unload,
        pc_xu_bo_repair                         => pc_xu_bo_repair,
        pc_xu_bo_reset                          => pc_xu_bo_reset,
        pc_xu_bo_shdata                         => pc_xu_bo_shdata,
        pc_xu_bo_select                         => pc_xu_bo_select(0 to 4),
        xu_pc_bo_fail                           => xu_pc_bo_fail(0 to 4),
        xu_pc_bo_diagout                        => xu_pc_bo_diagout(0 to 4),

        fxa_fxb_rf0_val                         => fxa_fxb_rf0_val,
        fxa_fxb_rf0_issued                      => fxa_fxb_rf0_issued,
        fxa_fxb_rf0_ucode_val                   => fxa_fxb_rf0_ucode_val,
        fxa_fxb_rf0_act                         => fxa_fxb_rf0_act,
        fxa_fxb_ex1_hold_ctr_flush              => fxa_fxb_ex1_hold_ctr_flush,
        fxa_fxb_rf0_instr                       => fxa_fxb_rf0_instr,
        fxa_fxb_rf0_tid                         => fxa_fxb_rf0_tid,
        fxa_fxb_rf0_ta_vld                      => fxa_fxb_rf0_ta_vld,
        fxa_fxb_rf0_ta                          => fxa_fxb_rf0_ta,
        fxa_fxb_rf0_error                       => fxa_fxb_rf0_error,
        fxa_fxb_rf0_match                       => fxa_fxb_rf0_match,
        fxa_fxb_rf0_is_ucode                    => fxa_fxb_rf0_is_ucode,
        fxa_fxb_rf0_gshare                      => fxa_fxb_rf0_gshare,
        fxa_fxb_rf0_ifar                        => fxa_fxb_rf0_ifar,
        fxa_fxb_rf0_s1_vld                      => fxa_fxb_rf0_s1_vld,
        fxa_fxb_rf0_s1                          => fxa_fxb_rf0_s1,
        fxa_fxb_rf0_s2_vld                      => fxa_fxb_rf0_s2_vld,
        fxa_fxb_rf0_s2                          => fxa_fxb_rf0_s2,
        fxa_fxb_rf0_s3_vld                      => fxa_fxb_rf0_s3_vld,
        fxa_fxb_rf0_s3                          => fxa_fxb_rf0_s3,
        fxa_fxb_rf0_axu_instr_type              => fxa_fxb_rf0_axu_instr_type,
        fxa_fxb_rf0_axu_ld_or_st                => fxa_fxb_rf0_axu_ld_or_st,
        fxa_fxb_rf0_axu_store                   => fxa_fxb_rf0_axu_store,
        fxa_fxb_rf0_axu_ldst_forcealign         => fxa_fxb_rf0_axu_ldst_forcealign,
        fxa_fxb_rf0_axu_ldst_forceexcept        => fxa_fxb_rf0_axu_ldst_forceexcept,
        fxa_fxb_rf0_axu_ldst_indexed            => fxa_fxb_rf0_axu_ldst_indexed,
        fxa_fxb_rf0_axu_ldst_tag                => fxa_fxb_rf0_axu_ldst_tag,
        fxa_fxb_rf0_axu_mftgpr                  => fxa_fxb_rf0_axu_mftgpr,
        fxa_fxb_rf0_axu_mffgpr                  => fxa_fxb_rf0_axu_mffgpr,
        fxa_fxb_rf0_axu_movedp                  => fxa_fxb_rf0_axu_movedp,
        fxa_fxb_rf0_axu_ldst_size               => fxa_fxb_rf0_axu_ldst_size,
        fxa_fxb_rf0_axu_ldst_update             => fxa_fxb_rf0_axu_ldst_update,
        fxa_fxb_rf0_pred_update                 => fxa_fxb_rf0_pred_update,
        fxa_fxb_rf0_pred_taken_cnt              => fxa_fxb_rf0_pred_taken_cnt,
        fxa_fxb_rf0_mc_dep_chk_val              => fxa_fxb_rf0_mc_dep_chk_val,
        fxa_fxb_rf1_mul_val                     => fxa_fxb_rf1_mul_val,
        fxa_fxb_rf1_div_val                     => fxa_fxb_rf1_div_val,
        fxa_fxb_rf1_div_ctr                     => fxa_fxb_rf1_div_ctr,
        fxa_fxb_rf0_xu_epid_instr               => fxa_fxb_rf0_xu_epid_instr,
        fxa_fxb_rf0_axu_is_extload              => fxa_fxb_rf0_axu_is_extload,
        fxa_fxb_rf0_axu_is_extstore             => fxa_fxb_rf0_axu_is_extstore,
        fxa_fxb_rf0_is_mfocrf                   => fxa_fxb_rf0_is_mfocrf,
        fxa_fxb_rf0_3src_instr                  => fxa_fxb_rf0_3src_instr,
        fxa_fxb_rf0_gpr0_zero                   => fxa_fxb_rf0_gpr0_zero,
        fxa_fxb_rf0_use_imm                     => fxa_fxb_rf0_use_imm,
        fxa_fxb_rf1_muldiv_coll                 => fxa_fxb_rf1_muldiv_coll,
        fxa_cpl_ex2_div_coll                    => fxa_cpl_ex2_div_coll,
        fxb_fxa_ex7_we0                         => fxb_fxa_ex7_we0,
        fxb_fxa_ex7_wa0                         => fxb_fxa_ex7_wa0,
        fxb_fxa_ex7_wd0                         => fxb_fxa_ex7_wd0,
        fxa_fxb_rf1_do0                         => fxa_fxb_rf1_do0,
        fxa_fxb_rf1_do1                         => fxa_fxb_rf1_do1,
        fxa_fxb_rf1_do2                         => fxa_fxb_rf1_do2,

        xu_bx_ex1_mtdp_val                      => xu_bx_ex1_mtdp_val,
        xu_bx_ex1_mfdp_val                      => xu_bx_ex1_mfdp_val,
        xu_bx_ex1_ipc_thrd                      => xu_bx_ex1_ipc_thrd,
        xu_bx_ex2_ipc_ba                        => xu_bx_ex2_ipc_ba,
        xu_bx_ex2_ipc_sz                        => xu_bx_ex2_ipc_sz,

        xu_mm_derat_epn                         => xu_mm_derat_epn,

        xu_mm_rf1_is_tlbsxr                     => xu_mm_rf1_is_tlbsxr,
        mm_xu_cr0_eq_valid                      => mm_xu_cr0_eq_valid,
        mm_xu_cr0_eq                            => mm_xu_cr0_eq,

        fu_xu_ex4_cr_val                        => fu_xu_ex4_cr_val,
        fu_xu_ex4_cr_noflush                    => fu_xu_ex4_cr_noflush,
        fu_xu_ex4_cr0                           => fu_xu_ex4_cr0,
        fu_xu_ex4_cr0_bf                        => fu_xu_ex4_cr0_bf,
        fu_xu_ex4_cr1                           => fu_xu_ex4_cr1,
        fu_xu_ex4_cr1_bf                        => fu_xu_ex4_cr1_bf,
        fu_xu_ex4_cr2                           => fu_xu_ex4_cr2,
        fu_xu_ex4_cr2_bf                        => fu_xu_ex4_cr2_bf,
        fu_xu_ex4_cr3                           => fu_xu_ex4_cr3,
        fu_xu_ex4_cr3_bf                        => fu_xu_ex4_cr3_bf,

        pc_xu_ram_mode                          => pc_xu_ram_mode,
        pc_xu_ram_thread                        => pc_xu_ram_thread,
        pc_xu_ram_execute                       => pc_xu_ram_execute,
        pc_xu_ram_flush_thread                  => pc_xu_ram_flush_thread,
        xu_iu_ram_issue                         => xu_iu_ram_issue,
        xu_pc_ram_interrupt                     => xu_pc_ram_interrupt,
        xu_pc_ram_done                          => xu_pc_ram_done,
        xu_pc_ram_data                          => xu_pc_ram_data,

        pc_xu_msrovride_enab                    => pc_xu_msrovride_enab,
        pc_xu_msrovride_gs                      => pc_xu_msrovride_gs,
        pc_xu_msrovride_de                      => pc_xu_msrovride_de,

        xu_iu_ex5_val                           => xu_iu_ex5_val,
        xu_iu_ex5_tid                           => xu_iu_ex5_tid,
        xu_iu_ex5_br_update                     => xu_iu_ex5_br_update,
        xu_iu_ex5_br_hist                       => xu_iu_ex5_br_hist,
        xu_iu_ex5_bclr                          => xu_iu_ex5_bclr,
        xu_iu_ex5_lk                            => xu_iu_ex5_lk,
        xu_iu_ex5_bh                            => xu_iu_ex5_bh,
        xu_iu_ex6_pri                           => xu_iu_ex6_pri,
        xu_iu_ex6_pri_val                       => xu_iu_ex6_pri_val,
        xu_iu_spr_xer                           => xu_iu_spr_xer,
        xu_iu_slowspr_done                      => xu_iu_slowspr_done,
        xu_iu_need_hole                         => xu_iu_need_hole,
        fxb_fxa_ex6_clear_barrier               => fxb_fxa_ex6_clear_barrier,
        xu_iu_ex5_gshare                        => xu_iu_ex5_gshare,
        xu_iu_ex5_getNIA                        => xu_iu_ex5_getNIA,

        an_ac_stcx_complete                     => an_ac_stcx_complete,
        an_ac_stcx_pass                         => an_ac_stcx_pass,
        xu_iu_stcx_complete                     => xu_iu_stcx_complete,                   
        xu_iu_reld_core_tag_clone    => xu_iu_reld_core_tag_clone,
        xu_iu_reld_data_coming_clone => xu_iu_reld_data_coming_clone,
        xu_iu_reld_data_vld_clone    => xu_iu_reld_data_vld_clone,
        xu_iu_reld_ditc_clone        => xu_iu_reld_ditc_clone,

        slowspr_val_in                          => slowspr_val_in,
        slowspr_rw_in                           => slowspr_rw_in,
        slowspr_etid_in                         => slowspr_etid_in,
        slowspr_addr_in                         => slowspr_addr_in,
        slowspr_data_in                         => slowspr_data_in,
        slowspr_done_in                         => slowspr_done_in,
        slowspr_val_out                         => slowspr_val_out,
        slowspr_rw_out                          => slowspr_rw_out,
        slowspr_etid_out                        => slowspr_etid_out,
        slowspr_addr_out                        => slowspr_addr_out,
        slowspr_data_out                        => slowspr_data_out,
        slowspr_done_out                        => slowspr_done_out,

        an_ac_dcr_act                           => tidn(0),       
        an_ac_dcr_val                           => tidn(0),       
        an_ac_dcr_read                          => tidn(0),       
        an_ac_dcr_etid                          => tidn(0 to 1),  
        an_ac_dcr_data                          => tidn(64-(2**regmode) to 63),       
        an_ac_dcr_done                          => tidn(0),       
        
        lsu_xu_ex4_mtdp_cr_status               => bx_xu_ex4_mtdp_cr_status,
        lsu_xu_ex4_mfdp_cr_status               => bx_xu_ex4_mfdp_cr_status,
        dec_cpl_ex3_mc_dep_chk_val              => dec_cpl_ex3_mc_dep_chk_val,

        fxa_perf_muldiv_in_use                  => fxa_perf_muldiv_in_use,
        xu_pc_event_data                        => xu_pc_event_data,

        pc_xu_event_count_mode                  => pc_xu_event_count_mode,
        pc_xu_event_mux_ctrls                   => pc_xu_event_mux_ctrls,

        spr_debug_mux_ctrls                     => spr_debug_mux_ctrls,
        fxu_debug_mux_ctrls                     => fxu_debug_mux_ctrls,
        cpl_debug_mux_ctrls                     => cpl_debug_mux_ctrls,
        lsu_debug_mux_ctrls                     => lsu_debug_mux_ctrls,
        trigger_data_in                         => trigger_data_in,
        trigger_data_out                        => trigger_data_out,
        debug_data_in                           => debug_data_in,
        debug_data_out                          => debug_data_out,
        lsu_xu_data_debug0                      => lsu_xu_data_debug0,
        lsu_xu_data_debug1                      => lsu_xu_data_debug1,
        lsu_xu_data_debug2                      => lsu_xu_data_debug2,
        fxa_cpl_debug                           => fxa_cpl_debug,

        ac_tc_debug_trigger                     => ac_tc_debug_trigger,

        dec_cpl_rf0_act                         => fxa_fxb_rf0_cpl_act,
        dec_cpl_rf0_tid                         => fxa_fxb_rf0_cpl_tid,

        fu_xu_rf1_act                           => fu_xu_rf1_act,
        fu_xu_ex1_ifar                          => fu_xu_ex1_ifar,
        fu_xu_ex2_ifar_val                      => fu_xu_ex2_ifar_val,
        fu_xu_ex2_ifar_issued                   => fu_xu_ex2_ifar_issued,
        fu_xu_ex2_instr_type                    => fu_xu_ex2_instr_type,
        fu_xu_ex2_instr_match                   => fu_xu_ex2_instr_match,
        fu_xu_ex2_is_ucode                      => fu_xu_ex2_is_ucode,

        pc_xu_stop                              => pc_xu_stop,
        pc_xu_step                              => pc_xu_step,
        pc_xu_dbg_action                        => pc_xu_dbg_action,
        pc_xu_force_ude                         => pc_xu_force_ude,
        xu_pc_step_done                         => xu_pc_step_done,
        pc_xu_init_reset                        => pc_xu_init_reset,

        mm_xu_local_snoop_reject                => mm_xu_local_snoop_reject,
        mm_xu_lru_par_err                       => mm_xu_lru_par_err,
        mm_xu_tlb_par_err                       => mm_xu_tlb_par_err,
        mm_xu_tlb_multihit_err                  => mm_xu_tlb_multihit_err,
        an_ac_external_mchk                     => an_ac_external_mchk,

        xu_pc_err_attention_instr               => xu_pc_err_attention_instr,
        xu_pc_err_nia_miscmpr                   => xu_pc_err_nia_miscmpr,
        xu_pc_err_debug_event                   => xu_pc_err_debug_event,

        xu_pc_stop_dbg_event                    => xu_pc_stop_dbg_event,

        mm_xu_illeg_instr                       => mm_xu_illeg_instr,
        mm_xu_tlb_miss                          => mm_xu_tlb_miss,
        mm_xu_pt_fault                          => mm_xu_pt_fault,
        mm_xu_tlb_inelig                        => mm_xu_tlb_inelig,
        mm_xu_lrat_miss                         => mm_xu_lrat_miss,
        mm_xu_hv_priv                           => mm_xu_hv_priv,
        mm_xu_esr_pt                            => mm_xu_esr_pt,
        mm_xu_esr_data                          => mm_xu_esr_data,
        mm_xu_esr_epid                          => mm_xu_esr_epid,
        mm_xu_esr_st                            => mm_xu_esr_st,
        mm_xu_hold_req                          => mm_xu_hold_req,
        mm_xu_hold_done                         => mm_xu_hold_done,
        xu_mm_hold_ack                          => xu_mm_hold_ack,
        mm_xu_eratmiss_done                     => mm_xu_eratmiss_done,
        mm_xu_ex3_flush_req                     => mm_xu_ex3_flush_req,

        fu_xu_ex3_ap_int_req                    => fu_xu_ex3_ap_int_req,
        fu_xu_ex3_trap                          => fu_xu_ex3_trap,
        fu_xu_ex3_n_flush                       => fu_xu_ex3_n_flush,
        fu_xu_ex3_np1_flush                     => fu_xu_ex3_np1_flush,
        fu_xu_ex3_flush2ucode                   => fu_xu_ex3_flush2ucode,
        fu_xu_ex2_async_block                   => fu_xu_ex2_async_block,

        xu_iu_ex5_br_taken                      => xu_iu_ex5_br_taken,
        xu_iu_ex5_ifar                          => xu_iu_ex5_ifar,
        xu_iu_flush                             => xu_iu_flush,
        xu_iu_iu0_flush_ifar                    => xu_iu_iu0_flush_ifar,
        xu_iu_uc_flush_ifar                     => xu_iu_uc_flush_ifar,
        xu_iu_flush_2ucode                      => xu_iu_flush_2ucode,
        xu_iu_flush_2ucode_type                 => xu_iu_flush_2ucode_type,
        xu_iu_ucode_restart                     => xu_iu_ucode_restart,
        xu_iu_ex5_ppc_cpl                       => xu_iu_ex5_ppc_cpl,

        xu_n_is2_flush                          => is2_flush,
        xu_n_rf0_flush                          => rf0_flush,
        xu_n_rf1_flush                          => rf1_flush,
        xu_n_ex1_flush                          => ex1_flush,
        xu_n_ex2_flush                          => ex2_flush,
        xu_n_ex3_flush                          => ex3_flush,
        xu_n_ex4_flush                          => ex4_flush,
        xu_n_ex5_flush                          => ex5_flush,

        xu_s_rf1_flush                          => xu_s_rf1_flush,
        xu_s_ex1_flush                          => xu_s_ex1_flush,
        xu_s_ex2_flush                          => xu_s_ex2_flush,
        xu_s_ex3_flush                          => xu_s_ex3_flush,
        xu_s_ex4_flush                          => xu_s_ex4_flush,
        xu_s_ex5_flush                          => xu_s_ex5_flush,

        xu_w_rf1_flush                          => xu_w_rf1_flush,
        xu_w_ex1_flush                          => xu_w_ex1_flush,
        xu_w_ex2_flush                          => xu_w_ex2_flush,
        xu_w_ex3_flush                          => xu_w_ex3_flush,
        xu_w_ex4_flush                          => xu_w_ex4_flush,
        xu_w_ex5_flush                          => xu_w_ex5_flush,

        xu_lsu_ex4_flush_local                  => xu_lsu_ex4_flush_local,
        xu_mm_ex4_flush                         => xu_mm_ex4_flush,
        xu_mm_ex5_flush                         => xu_mm_ex5_flush,
        xu_mm_ierat_flush                       => xu_mm_ierat_flush,
        xu_mm_ierat_miss                        => xu_mm_ierat_miss,
        xu_mm_ex5_perf_itlb                     => xu_mm_ex5_perf_itlb,
        xu_mm_ex5_perf_dtlb                     => xu_mm_ex5_perf_dtlb,

        spr_xucr4_div_barr_thres                => spr_xucr4_div_barr_thres,

        iu_xu_ierat_ex2_flush_req               => iu_xu_ierat_ex2_flush_req,
        iu_xu_ierat_ex3_par_err                 => iu_xu_ierat_ex3_par_err,
        iu_xu_ierat_ex4_par_err                 => iu_xu_ierat_ex4_par_err,

        fu_xu_ex3_regfile_err_det               => fu_xu_ex3_regfile_err_det,
        xu_fu_regfile_seq_beg                   => xu_fu_regfile_seq_beg,
        fu_xu_regfile_seq_end                   => fu_xu_regfile_seq_end,
        gpr_cpl_ex3_regfile_err_det             => gpr_cpl_ex3_regfile_err_det,
        cpl_gpr_regfile_seq_beg                 => cpl_gpr_regfile_seq_beg,
        gpr_cpl_regfile_seq_end                 => gpr_cpl_regfile_seq_end,
        xu_pc_err_mcsr_summary                  => xu_pc_err_mcsr_summary,
        xu_pc_err_ditc_overrun                  => xu_pc_err_ditc_overrun,
        xu_pc_err_local_snoop_reject            => xu_pc_err_local_snoop_reject,
        xu_pc_err_tlb_lru_parity                => xu_pc_err_tlb_lru_parity,
        xu_pc_err_ext_mchk                      => xu_pc_err_ext_mchk,
        xu_pc_err_ierat_multihit                => xu_pc_err_ierat_multihit,
        xu_pc_err_derat_multihit                => xu_pc_err_derat_multihit,
        xu_pc_err_tlb_multihit                  => xu_pc_err_tlb_multihit,
        xu_pc_err_ierat_parity                  => xu_pc_err_ierat_parity,
        xu_pc_err_derat_parity                  => xu_pc_err_derat_parity,
        xu_pc_err_tlb_parity                    => xu_pc_err_tlb_parity,
        xu_pc_err_mchk_disabled                 => xu_pc_err_mchk_disabled,

        xu_iu_rf1_val                           => xu_iu_rf1_val,
        xu_rf1_val                              => xu_rf1_val,
        xu_rf1_is_tlbre                         => xu_mm_rf1_is_tlbre,
        xu_rf1_is_tlbwe                         => xu_mm_rf1_is_tlbwe,
        xu_rf1_is_tlbsx                         => xu_mm_rf1_is_tlbsx,
        xu_rf1_is_tlbsrx                        => xu_mm_rf1_is_tlbsrx,
        xu_rf1_is_tlbilx                        => xu_mm_rf1_is_tlbilx,
        xu_rf1_is_tlbivax                       => xu_mm_rf1_is_tlbivax,
        xu_rf1_is_eratre                        => xu_iu_rf1_is_eratre,
        xu_rf1_is_eratwe                        => xu_iu_rf1_is_eratwe,
        xu_rf1_is_eratsx                        => xu_iu_rf1_is_eratsx,
        xu_rf1_is_eratilx                       => xu_rf1_is_eratilx,
        xu_rf1_is_erativax                      => xu_mm_rf1_is_erativax,
        xu_ex1_is_isync                         => xu_ex1_is_isync,
        xu_ex1_is_csync                         => xu_ex1_is_csync,
        xu_rf1_ws                               => xu_rf1_ws,
        xu_rf1_t                                => xu_rf1_t,
        xu_ex1_rs_is                            => xu_ex1_rs_is,
        xu_ex1_ra_entry                         => xu_ex1_ra_entry,
        xu_ex4_rs_data                          => xu_ex4_rs_data,

        xu_lsu_rf1_data_act                     => xu_lsu_rf1_data_act,
        xu_lsu_rf1_axu_ldst_falign              => xu_lsu_rf1_axu_ldst_falign,
        xu_lsu_ex1_store_data                   => xu_lsu_ex1_store_data,
        xu_lsu_ex1_rotsel_ovrd                  => xu_lsu_ex1_rotsel_ovrd,
        xu_lsu_ex1_eff_addr                     => xu_lsu_ex1_eff_addr,

        cpl_fxa_ex5_set_barr                    => cpl_fxa_ex5_set_barr,
        cpl_iu_set_barr_tid                      => cpl_iu_set_barr_tid,

        lsu_xu_ex6_datc_par_err                 => lsu_xu_ex6_datc_par_err,
                                                     
        lsu_xu_rel_dvc1_en                      => lsu_xu_rel_dvc1_en,
        lsu_xu_rel_dvc2_en                      => lsu_xu_rel_dvc2_en,
        lsu_xu_ex2_dvc1_st_cmp                  => lsu_xu_ex2_dvc1_st_cmp,
        lsu_xu_ex2_dvc2_st_cmp                  => lsu_xu_ex2_dvc2_st_cmp,
        lsu_xu_ex8_dvc1_ld_cmp                  => lsu_xu_ex8_dvc1_ld_cmp,
        lsu_xu_ex8_dvc2_ld_cmp                  => lsu_xu_ex8_dvc2_ld_cmp,
        lsu_xu_rel_dvc_thrd_id                  => lsu_xu_rel_dvc_thrd_id,
        lsu_xu_rel_dvc1_cmp                     => lsu_xu_rel_dvc1_cmp,
        lsu_xu_rel_dvc2_cmp                     => lsu_xu_rel_dvc2_cmp,

        lsu_xu_rot_ex6_data_b                   => lsu_xu_rot_ex6_data_b,
        lsu_xu_rot_rel_data                     => lsu_xu_rot_rel_data,
        pc_xu_trace_bus_enable                  => pc_xu_trace_bus_enable,
        pc_xu_instr_trace_mode                  => pc_xu_instr_trace_mode,
        pc_xu_instr_trace_tid                   => pc_xu_instr_trace_tid,
        iu_xu_ex4_tlb_data                      => iu_xu_ex4_tlb_data,

        pc_xu_inj_dcachedir_parity              => pc_xu_inj_dcachedir_parity,
        pc_xu_inj_dcachedir_multihit            => pc_xu_inj_dcachedir_multihit,

        ex4_256st_data                          => ex4_256st_data,
        an_ac_flh2l2_gate                       => an_ac_flh2l2_gate,
        
        xu_lsu_rf0_derat_val                    => xu_lsu_rf0_derat_val,
        xu_lsu_rf0_derat_is_extload             => xu_lsu_rf0_derat_is_extload,
        xu_lsu_rf0_derat_is_extstore            => xu_lsu_rf0_derat_is_extstore,
        xu_lsu_hid_mmu_mode                     => xu_lsu_hid_mmu_mode,
        ex6_ld_par_err                          => ex6_ld_par_err,
        
        xu_mm_derat_req                         => xu_mm_derat_req,
        xu_mm_derat_thdid                       => xu_mm_derat_thdid,
        xu_mm_derat_state                       => xu_mm_derat_state,
        xu_mm_derat_tid                         => xu_mm_derat_tid,
        xu_mm_derat_lpid                        => xu_mm_derat_lpid,
        xu_mm_derat_ttype                       => xu_mm_derat_ttype,
        mm_xu_derat_rel_val                     => mm_xu_derat_rel_val,
        mm_xu_derat_rel_data                    => mm_xu_derat_rel_data,
        mm_xu_derat_pid0                        => mm_xu_derat_pid0,
        mm_xu_derat_pid1                        => mm_xu_derat_pid1,
        mm_xu_derat_pid2                        => mm_xu_derat_pid2,
        mm_xu_derat_pid3                        => mm_xu_derat_pid3,
        mm_xu_derat_mmucr0_0                    => mm_xu_derat_mmucr0_0,
        mm_xu_derat_mmucr0_1                    => mm_xu_derat_mmucr0_1,
        mm_xu_derat_mmucr0_2                    => mm_xu_derat_mmucr0_2,
        mm_xu_derat_mmucr0_3                    => mm_xu_derat_mmucr0_3,
        xu_mm_derat_mmucr0                      => xu_mm_derat_mmucr0,
        xu_mm_derat_mmucr0_we                   => xu_mm_derat_mmucr0_we,
        mm_xu_derat_mmucr1                      => mm_xu_derat_mmucr1,
        xu_mm_derat_mmucr1                      => xu_mm_derat_mmucr1,
        xu_mm_derat_mmucr1_we                   => xu_mm_derat_mmucr1_we,
        mm_xu_derat_snoop_coming                => mm_xu_derat_snoop_coming,
        mm_xu_derat_snoop_val                   => mm_xu_derat_snoop_val,
        mm_xu_derat_snoop_attr                  => mm_xu_derat_snoop_attr,
        mm_xu_derat_snoop_vpn                   => mm_xu_derat_snoop_vpn,
        xu_mm_derat_snoop_ack                   => xu_mm_derat_snoop_ack,
        
        ex1_optype1                             => ex1_optype1,
        ex1_optype2                             => ex1_optype2,
        ex1_optype4                             => ex1_optype4,
        ex1_optype8                             => ex1_optype8,
        ex1_optype16                            => ex1_optype16,
        ex1_optype32                            => ex1_optype32,
        ex1_saxu_instr                          => ex1_saxu_instr,
        ex1_sdp_instr                           => ex1_sdp_instr,
        ex1_stgpr_instr                         => ex1_stgpr_instr,
        ex1_store_instr                         => ex1_store_instr,
        ex1_axu_op_val                          => ex1_axu_op_val,
        
        ex3_algebraic                           => ex3_algebraic,
        ex3_data_swap                           => ex3_data_swap,
        ex3_thrd_id                             => ex3_thrd_id,
        xu_fu_ex3_eff_addr                      => xu_fu_ex3_eff_addr,
        xu_lsu_ici                              => xu_lsu_ici,
        
        rel_upd_dcarr_val                       => rel_upd_dcarr_val,
                           
        xu_fu_ex5_reload_val                    => xu_fu_ex5_reload_val,
        xu_fu_ex5_load_val                      => xu_fu_ex5_load_val,
        xu_fu_ex5_load_tag                      => xu_fu_ex5_load_tag,
        
        dcarr_up_way_addr                       => dcarr_up_way_addr,
        
        ex4_load_op_hit                         => ex4_load_op_hit,
        ex4_store_hit                           => ex4_store_hit,
        ex4_axu_op_val                          => ex4_axu_op_val,
        spr_dvc1_act                            => spr_dvc1_act,
        spr_dvc2_act                            => spr_dvc2_act,
        spr_dvc1_dbg                            => spr_dvc1_dbg,
        spr_dvc2_dbg                            => spr_dvc2_dbg,
        
        an_ac_req_ld_pop                        => an_ac_req_ld_pop,
        an_ac_req_st_pop                        => an_ac_req_st_pop,
        an_ac_req_st_gather                     => an_ac_req_st_gather,
        an_ac_req_st_pop_thrd                   => an_ac_req_st_pop_thrd,
        an_ac_reld_data_vld                     => an_ac_reld_data_vld,
        an_ac_reld_core_tag                     => an_ac_reld_core_tag,
        an_ac_reld_qw                           => an_ac_reld_qw,
        an_ac_reld_data                         => an_ac_reld_data,
        an_ac_reld_data_coming                  => an_ac_reld_data_coming,
        an_ac_reld_ditc                         => an_ac_reld_ditc,
        an_ac_reld_crit_qw                      => an_ac_reld_crit_qw,
        an_ac_reld_l1_dump                      => an_ac_reld_l1_dump,
        an_ac_reld_ecc_err                      => an_ac_reld_ecc_err,
        an_ac_reld_ecc_err_ue                   => an_ac_reld_ecc_err_ue,
        an_ac_back_inv                          => an_ac_back_inv,
        an_ac_back_inv_addr                     => an_ac_back_inv_addr,
        an_ac_back_inv_target_bit1              => an_ac_back_inv_target_bit1,
        an_ac_back_inv_target_bit3              => an_ac_back_inv_target_bit3,
        an_ac_back_inv_target_bit4              => an_ac_back_inv_target_bit4,
        an_ac_req_spare_ctrl_a1                 => an_ac_req_spare_ctrl_a1,

        lsu_reld_data_vld                       => lsu_reld_data_vld,
        lsu_reld_core_tag                       => lsu_reld_core_tag,
        lsu_reld_qw                             => lsu_reld_qw,
        lsu_reld_ditc                           => lsu_reld_ditc,
        lsu_reld_ecc_err                        => lsu_reld_ecc_err,
        lsu_reld_data                           => lsu_reld_data,

        lsu_req_st_pop                          => lsu_req_st_pop,
        lsu_req_st_pop_thrd                     => lsu_req_st_pop_thrd,

        ac_an_reld_ditc_pop_int    => ac_an_reld_ditc_pop_int,
        ac_an_reld_ditc_pop_q      => ac_an_reld_ditc_pop_q  ,
        bx_ib_empty_int            => bx_ib_empty_int        ,
        bx_ib_empty_q              => bx_ib_empty_q          ,
                                                  
        iu_xu_ra                                => iu_xu_ra,
        iu_xu_request                           => iu_xu_request,
        iu_xu_wimge                             => iu_xu_wimge,
        iu_xu_thread                            => iu_xu_thread,
        iu_xu_userdef                           => iu_xu_userdef,
                                                  
        mm_xu_lsu_req                           => mm_xu_lsu_req,
        mm_xu_lsu_ttype                         => mm_xu_lsu_ttype,
        mm_xu_lsu_wimge                         => mm_xu_lsu_wimge,
        mm_xu_lsu_u                             => mm_xu_lsu_u,
        mm_xu_lsu_addr                          => mm_xu_lsu_addr,
        mm_xu_lsu_lpid                          => mm_xu_lsu_lpid,
        mm_xu_lsu_lpidr                         => mm_xu_lsu_lpidr,
        mm_xu_lsu_gs                            => mm_xu_lsu_gs,
        mm_xu_lsu_ind                           => mm_xu_lsu_ind,
        mm_xu_lsu_lbit                          => mm_xu_lsu_lbit,
        xu_mm_lsu_token                         => xu_mm_lsu_token,
                                                  
        bx_lsu_ob_pwr_tok                       => bx_lsu_ob_pwr_tok,
        bx_lsu_ob_req_val                       => bx_lsu_ob_req_val,
        bx_lsu_ob_ditc_val                      => bx_lsu_ob_ditc_val,
        bx_lsu_ob_thrd                          => bx_lsu_ob_thrd,
        bx_lsu_ob_qw                            => bx_lsu_ob_qw,
        bx_lsu_ob_dest                          => bx_lsu_ob_dest,
        bx_lsu_ob_data                          => bx_lsu_ob_data,
        bx_lsu_ob_addr                          => bx_lsu_ob_addr,
        lsu_bx_cmd_avail                        => lsu_bx_cmd_avail,
        lsu_bx_cmd_sent                         => lsu_bx_cmd_sent,
        lsu_bx_cmd_stall                        => lsu_bx_cmd_stall,

        lsu_xu_ldq_barr_done                    => lsu_xu_ldq_barr_done,
        lsu_xu_barr_done                        => lsu_xu_barr_done,
                                                  
        ldq_rel_data_val_early                  => ldq_rel_data_val_early,
        ldq_rel_op_size                         => ldq_rel_op_size,
        ldq_rel_addr                            => ldq_rel_addr,
        ldq_rel_data_val                        => ldq_rel_data_val,
        ldq_rel_rot_sel                         => ldq_rel_rot_sel,
        ldq_rel_axu_val                         => ldq_rel_axu_val,
        ldq_rel_ci                              => ldq_rel_ci,
        ldq_rel_thrd_id                         => ldq_rel_thrd_id,
        ldq_rel_le_mode                         => ldq_rel_le_mode,
        ldq_rel_algebraic                       => ldq_rel_algebraic,
        ldq_rel_256_data                        => ldq_rel_256_data,
        ldq_rel_dvc1_en                         => ldq_rel_dvc1_en,
        ldq_rel_dvc2_en                         => ldq_rel_dvc2_en,
        ldq_rel_beat_crit_qw                    => ldq_rel_beat_crit_qw,
        ldq_rel_beat_crit_qw_block              => ldq_rel_beat_crit_qw_block,
        lsu_xu_rel_wren                         => lsu_xu_rel_wren,
        lsu_xu_rel_ta_gpr                       => lsu_xu_rel_ta_gpr,

        xu_iu_ex4_loadmiss_qentry               => xu_iu_ex4_loadmiss_qentry,
        xu_iu_ex4_loadmiss_target               => xu_iu_ex4_loadmiss_target,
        xu_iu_ex4_loadmiss_target_type          => xu_iu_ex4_loadmiss_target_type,
        xu_iu_ex4_loadmiss_tid                  => xu_iu_ex4_loadmiss_tid,
        xu_iu_ex5_loadmiss_qentry               => xu_iu_ex5_loadmiss_qentry,
        xu_iu_ex5_loadmiss_target               => xu_iu_ex5_loadmiss_target,
        xu_iu_ex5_loadmiss_target_type          => xu_iu_ex5_loadmiss_target_type,
        xu_iu_ex5_loadmiss_tid                  => xu_iu_ex5_loadmiss_tid,
        xu_iu_complete_qentry                   => xu_iu_complete_qentry,
        xu_iu_complete_tid                      => xu_iu_complete_tid,
        xu_iu_complete_target_type              => xu_iu_complete_target_type,
                                                  
        xu_iu_ex6_icbi_val                      => xu_iu_ex6_icbi_val,
        xu_iu_ex6_icbi_addr                     => xu_iu_ex6_icbi_addr,

        xu_iu_larx_done_tid                     => xu_iu_larx_done_tid,
        xu_mm_lmq_stq_empty                     => xu_mm_lmq_stq_empty,
                                                  
        xu_ex1_rb                               => xu_iu_ex1_rb,
        xu_ex2_eff_addr                         => xu_ex2_eff_addr,
                                                  
        ac_an_req_pwr_token                     => ac_an_req_pwr_token,
        ac_an_req                               => ac_an_req,
        ac_an_req_ra                            => ac_an_req_ra,
        ac_an_req_ttype                         => ac_an_req_ttype,
        ac_an_req_thread                        => ac_an_req_thread,
        ac_an_req_wimg_w                        => ac_an_req_wimg_w,
        ac_an_req_wimg_i                        => ac_an_req_wimg_i,
        ac_an_req_wimg_m                        => ac_an_req_wimg_m,
        ac_an_req_wimg_g                        => ac_an_req_wimg_g,
        ac_an_req_endian                        => ac_an_req_endian,
        ac_an_req_user_defined                  => ac_an_req_user_defined,
        ac_an_req_spare_ctrl_a0                 => ac_an_req_spare_ctrl_a0,
        ac_an_req_ld_core_tag                   => ac_an_req_ld_core_tag,
        ac_an_req_ld_xfr_len                    => ac_an_req_ld_xfr_len,
        ac_an_st_byte_enbl                      => ac_an_st_byte_enbl,
        ac_an_st_data                           => ac_an_st_data,
        ac_an_st_data_pwr_token                 => ac_an_st_data_pwr_token,
                                                  
        xu_pc_err_dcachedir_parity              => xu_pc_err_dcachedir_parity,
        xu_pc_err_dcachedir_multihit            => xu_pc_err_dcachedir_multihit,
        xu_pc_err_l2intrf_ecc                   => xu_pc_err_l2intrf_ecc,
        xu_pc_err_l2intrf_ue                    => xu_pc_err_l2intrf_ue,
        xu_pc_err_invld_reld                    => xu_pc_err_invld_reld,
        xu_pc_err_l2credit_overrun              => xu_pc_err_l2credit_overrun,
                                                  
        pc_xu_event_bus_enable                  => pc_xu_event_bus_enable,
        pc_xu_lsu_event_mux_ctrls               => pc_xu_lsu_event_mux_ctrls,
        pc_xu_cache_par_err_event               => pc_xu_cache_par_err_event,
        xu_pc_lsu_event_data                    => xu_pc_lsu_event_data,


        dec_spr_rf0_tid                         => fxa_fxb_rf0_spr_tid,
        dec_spr_rf0_instr                       => dec_spr_rf0_instr,

        ac_an_dcr_act                           => open, 
        ac_an_dcr_val                           => open, 
        ac_an_dcr_read                          => open, 
        ac_an_dcr_user                          => open, 
        ac_an_dcr_etid                          => open, 
        ac_an_dcr_addr                          => open, 
        ac_an_dcr_data                          => open, 

        xu_pc_running                           => xu_pc_running,
        xu_iu_run_thread                        => xu_iu_run_thread,
        xu_iu_single_instr_mode                 => xu_iu_single_instr_mode,
        xu_iu_raise_iss_pri                     => xu_iu_raise_iss_pri,
        xu_pc_spr_ccr0_we                       => xu_pc_spr_ccr0_we,

        iu_xu_quiesce                           => iu_xu_quiesce,
        mm_xu_quiesce                           => mm_xu_quiesce,
        bx_xu_quiesce                           => bx_xu_quiesce,

        pc_xu_extirpts_dis_on_stop              => pc_xu_extirpts_dis_on_stop,
        pc_xu_timebase_dis_on_stop              => pc_xu_timebase_dis_on_stop,
        pc_xu_decrem_dis_on_stop                => pc_xu_decrem_dis_on_stop,

        pc_xu_msrovride_pr                      => pc_xu_msrovride_pr,

        xu_pc_err_llbust_attempt                => xu_pc_err_llbust_attempt,
        xu_pc_err_llbust_failed                 => xu_pc_err_llbust_failed,

        pc_xu_reset_wd_complete                 => pc_xu_reset_wd_complete,
        pc_xu_reset_1_complete                  => pc_xu_reset_1_complete,
        pc_xu_reset_2_complete                  => pc_xu_reset_2_complete,
        pc_xu_reset_3_complete                  => pc_xu_reset_3_complete,
        ac_tc_reset_1_request                   => ac_tc_reset_1_request,
        ac_tc_reset_2_request                   => ac_tc_reset_2_request,
        ac_tc_reset_3_request                   => ac_tc_reset_3_request,
        ac_tc_reset_wd_request                  => ac_tc_reset_wd_request,

        pc_xu_inj_llbust_attempt                => pc_xu_inj_llbust_attempt,
        pc_xu_inj_llbust_failed                 => pc_xu_inj_llbust_failed,
        pc_xu_inj_wdt_reset                     => pc_xu_inj_wdt_reset,
        xu_pc_err_wdt_reset                     => xu_pc_err_wdt_reset,

        pc_xu_inj_sprg_ecc                      => pc_xu_inj_sprg_ecc,
        xu_pc_err_sprg_ecc                      => xu_pc_err_sprg_ecc,
        xu_pc_err_sprg_ue                       => xu_pc_err_sprg_ue,

        spr_msr_cm                              => xu_msr_cm,
        spr_msr_gs                              => xu_msr_gs,
        spr_msr_pr                              => xu_msr_pr,
        spr_msr_is                              => xu_msr_is,
        spr_msr_ds                              => xu_msr_ds,
        spr_ccr2_en_dcr                         => xu_iu_spr_ccr2_en_dcr,
        spr_ccr2_notlb                          => spr_ccr2_notlb,
        spr_ccr2_en_ditc                        => xu_bx_ccr2_en_ditc,
        xu_lsu_spr_xucr0_dcdis                  => xu_lsu_spr_xucr0_dcdis,
        xu_lsu_spr_xucr0_rel                    => xu_iu_xucr0_rel,
        xu_pc_spr_ccr0_pme                      => xu_pc_spr_ccr0_pme,
        xu_iu_spr_ccr2_ifratsc                  => xu_iu_spr_ccr2_ifratsc,
        xu_iu_spr_ccr2_ifrat                    => xu_iu_spr_ccr2_ifrat,
        spr_xucr0_clkg_ctl_b0                   => spr_xucr0_clkg_ctl_b0,
        xu_mm_spr_epcr_dmiuh                    => xu_mm_spr_epcr_dmiuh,
        xu_mm_spr_epcr_dgtmi                    => xu_mm_spr_epcr_dgtmi,
        cpl_msr_gs                              => cpl_msr_gs,
        cpl_msr_pr                              => cpl_msr_pr,
        cpl_msr_fp                              => cpl_msr_fp,
        cpl_msr_spv                             => cpl_msr_spv,
        cpl_ccr2_ap                             => cpl_ccr2_ap,
        spr_xucr4_mmu_mchk                      => spr_xucr4_mmu_mchk,
                                                                                                  
        an_ac_lbist_ary_wrt_thru_dc             => an_ac_lbist_ary_wrt_thru_dc,
        ac_tc_machine_check                     => ac_tc_machine_check,
        pc_xu_abist_g8t_wenb                    => pc_xu_abist_g8t_wenb,
        pc_xu_abist_g8t1p_renb_0                => pc_xu_abist_g8t1p_renb_0,
        pc_xu_abist_g8t_bw_1                    => pc_xu_abist_g8t_bw_1,
        pc_xu_abist_g8t_bw_0                    => pc_xu_abist_g8t_bw_0,
        pc_xu_abist_wl32_comp_ena               => pc_xu_abist_wl32_comp_ena,
        pc_xu_abist_g8t_dcomp                   => pc_xu_abist_g8t_dcomp,
                                                  
        vcs                                     => vcs,
        vdd                                     => vdd,
        gnd                                     => gnd,
        nclk                                    => nclk,
        an_ac_coreid                            => an_ac_coreid,
        spr_pvr_version_dc                      => spr_pvr_version_dc,
        spr_pvr_revision_dc                     => spr_pvr_revision_dc,
        an_ac_atpg_en_dc                        => an_ac_atpg_en_dc,
        an_ac_ext_interrupt                     => an_ac_ext_interrupt,
        an_ac_crit_interrupt                    => an_ac_crit_interrupt,
        an_ac_perf_interrupt                    => an_ac_perf_interrupt,
        an_ac_reservation_vld                   => an_ac_reservation_vld,
        an_ac_tb_update_pulse                   => an_ac_tb_update_pulse,
        an_ac_hang_pulse                        => an_ac_hang_pulse,
        an_ac_tb_update_enable                  => an_ac_tb_update_enable,
        an_ac_sleep_en                          => an_ac_sleep_en,
        an_ac_grffence_en_dc                    => an_ac_grffence_en_dc,
                                                  
        func_scan_in                            => func_scan_in(35 to 58),
        func_scan_out                           => func_scan_out(35 to 58),
        gptr_scan_in                            => ctlspr_gptr_scan_in,
        gptr_scan_out                           => ctlspr_gptr_scan_out,
        bcfg_scan_in                            => bcfg_scan_in,
        bcfg_scan_out                           => bcfg_scan_out,
        dcfg_scan_in                            => dcfg_scan_in,
        dcfg_scan_out                           => dcfg_scan_out,
        ccfg_scan_in                            => ccfg_scan_in,
        ccfg_scan_out                           => ccfg_scan_out,
        regf_scan_in                            => regf_scan_in,
        regf_scan_out                           => regf_scan_out,
        time_scan_in                            => ctlspr_time_scan_in,
        time_scan_out                           => ctlspr_time_scan_out,
        abst_scan_in(0)                         => abst_scan_in(0),
        abst_scan_in(1)                         => abst_scan_in(2),
        abst_scan_out(0)                        => abst_scan_out(0),
        abst_scan_out(1)                        => abst_scan_2,
        repr_scan_in                            => ctlspr_repr_scan_in,
        repr_scan_out                           => ctlspr_repr_scan_out
);      


fxadat : entity work.xuq_fxua_data(xuq_fxua_data)
generic map(
        expand_type             => expand_type,
        regmode                 => regmode,
        dc_size                 => dc_size,
        cl_size                 => cl_size,
        l_endian_m              => l_endian_m,
        threads                 => threads,
        eff_ifar                => eff_ifar,
        regsize                 => regsize,
        a2mode                  => a2mode,
        hvmode                  => hvmode,
        real_data_add           => real_data_add)
port map(

        pc_xu_abist_raddr_0                     => pc_xu_abist_raddr_0(1 to 9),
        pc_xu_abist_raddr_1                     => pc_xu_abist_raddr_1(2 to 9),
        pc_xu_abist_grf_renb_0                  => pc_xu_abist_grf_renb_0,
        pc_xu_abist_grf_renb_1                  => pc_xu_abist_grf_renb_1,
        pc_xu_abist_ena_dc                      => pc_xu_abist_ena_dc,
        pc_xu_abist_waddr_0                     => pc_xu_abist_waddr_0(2 to 9),
        pc_xu_abist_waddr_1                     => pc_xu_abist_waddr_1(2 to 9),
        pc_xu_abist_grf_wenb_0                  => pc_xu_abist_grf_wenb_0,
        pc_xu_abist_grf_wenb_1                  => pc_xu_abist_grf_wenb_1,
        pc_xu_abist_di_0                        => pc_xu_abist_di_0,
        pc_xu_abist_di_1                        => pc_xu_abist_di_1,
        pc_xu_abist_wl144_comp_ena              => pc_xu_abist_wl144_comp_ena,
        pc_xu_abist_raw_dc_b                    => pc_xu_abist_raw_dc_b,
        pc_xu_ccflush_dc                        => pc_xu_ccflush_dc,
        clkoff_dc_b                             => clkoff_dc_b,
        d_mode_dc                               => d_mode_dc,
        delay_lclkr_dc                          => delay_lclkr_dc(4 to 4),
        mpw1_dc_b                               => mpw1_dc_b(4 to 4),
        mpw2_dc_b                               => mpw2_dc_b,
        g6t_clkoff_dc_b                         => g6t_clkoff_dc_b,
        g6t_d_mode_dc                           => g6t_d_mode_dc,
        g6t_delay_lclkr_dc                      => g6t_delay_lclkr_dc,
        g6t_mpw1_dc_b                           => g6t_mpw1_dc_b,
        g6t_mpw2_dc_b                           => g6t_mpw2_dc_b,
        an_ac_scan_diag_dc                      => an_ac_scan_diag_dc,
        an_ac_lbist_ary_wrt_thru_dc             => an_ac_lbist_ary_wrt_thru_dc,
        sg_2                                    => sg_2(0 to 2),
        fce_2                                   => fce_2(0 to 0),
        func_sl_thold_2                         => func_sl_thold_2,
        func_nsl_thold_2                        => func_nsl_thold_2,
        abst_sl_thold_2                         => abst_sl_thold_2,
        time_sl_thold_2                         => time_sl_thold_2,
        ary_nsl_thold_2                         => ary_nsl_thold_2,
        repr_sl_thold_2                         => repr_sl_thold_2,
        gptr_sl_thold_2                         => gptr_sl_thold_2,
        bolt_sl_thold_2                         => bolt_sl_thold_2,
        bo_enable_2                             => bo_enable_2,
        pc_xu_bo_unload                         => pc_xu_bo_unload,
        pc_xu_bo_load                           => pc_xu_bo_load,
        pc_xu_bo_repair                         => pc_xu_bo_repair,
        pc_xu_bo_reset                          => pc_xu_bo_reset,
        pc_xu_bo_shdata                         => pc_xu_bo_shdata,
        pc_xu_bo_select                         => pc_xu_bo_select(5 to 8),
        xu_pc_bo_fail                           => xu_pc_bo_fail(5 to 8),
        xu_pc_bo_diagout                        => xu_pc_bo_diagout(5 to 8),

        iu_xu_is2_vld                           => iu_xu_is2_vld,
        iu_xu_is2_ifar                          => iu_xu_is2_ifar,
        iu_xu_is2_tid                           => iu_xu_is2_tid,
        iu_xu_is2_instr                         => iu_xu_is2_instr,
        iu_xu_is2_ta_vld                        => iu_xu_is2_ta_vld,
        iu_xu_is2_ta                            => iu_xu_is2_ta,
        iu_xu_is2_s1_vld                        => iu_xu_is2_s1_vld,
        iu_xu_is2_s1                            => iu_xu_is2_s1,
        iu_xu_is2_s2_vld                        => iu_xu_is2_s2_vld,
        iu_xu_is2_s2                            => iu_xu_is2_s2,
        iu_xu_is2_s3_vld                        => iu_xu_is2_s3_vld,
        iu_xu_is2_s3                            => iu_xu_is2_s3,
        iu_xu_is2_axu_ld_or_st                  => iu_xu_is2_axu_ld_or_st,
        iu_xu_is2_axu_store                     => iu_xu_is2_axu_store,
        iu_xu_is2_axu_ldst_size                 => iu_xu_is2_axu_ldst_size,
        iu_xu_is2_axu_ldst_update               => iu_xu_is2_axu_ldst_update,
        iu_xu_is2_axu_ldst_forcealign           => iu_xu_is2_axu_ldst_forcealign,
        iu_xu_is2_axu_ldst_forceexcept          => iu_xu_is2_axu_ldst_forceexcept,
        iu_xu_is2_axu_ldst_extpid               => iu_xu_is2_axu_ldst_extpid,
        iu_xu_is2_axu_ldst_indexed              => iu_xu_is2_axu_ldst_indexed,
        iu_xu_is2_axu_ldst_tag                  => iu_xu_is2_axu_ldst_tag,
        iu_xu_is2_axu_mftgpr                    => iu_xu_is2_axu_mftgpr,
        iu_xu_is2_axu_mffgpr                    => iu_xu_is2_axu_mffgpr,
        iu_xu_is2_axu_movedp                    => iu_xu_is2_axu_movedp,
        iu_xu_is2_axu_instr_type                => iu_xu_is2_axu_instr_type,
        iu_xu_is2_pred_update                   => iu_xu_is2_pred_update,
        iu_xu_is2_pred_taken_cnt                => iu_xu_is2_pred_taken_cnt,
        iu_xu_is2_error                         => iu_xu_is2_error,
        iu_xu_is2_match                         => iu_xu_is2_match,
        iu_xu_is2_is_ucode                      => iu_xu_is2_is_ucode,
        iu_xu_is2_ucode_vld                     => iu_xu_is2_ucode_vld,
        iu_xu_is2_gshare                        => iu_xu_is2_gshare,
        xu_iu_multdiv_done                      => xu_iu_multdiv_done,
        xu_iu_membar_tid                        => xu_iu_membar_tid,

        lsu_xu_ldq_barr_done                    => lsu_xu_ldq_barr_done,
        lsu_xu_barr_done                        => lsu_xu_barr_done,

        fxa_fxb_rf0_val                         => fxa_fxb_rf0_val,
        fxa_fxb_rf0_issued                      => fxa_fxb_rf0_issued,
        fxa_fxb_rf0_ucode_val                   => fxa_fxb_rf0_ucode_val,
        fxa_fxb_rf0_act                         => fxa_fxb_rf0_act,
        fxa_fxb_ex1_hold_ctr_flush              => fxa_fxb_ex1_hold_ctr_flush,
        fxa_fxb_rf0_instr                       => fxa_fxb_rf0_instr,
        fxa_fxb_rf0_tid                         => fxa_fxb_rf0_tid,
        fxa_fxb_rf0_ta_vld                      => fxa_fxb_rf0_ta_vld,
        fxa_fxb_rf0_ta                          => fxa_fxb_rf0_ta,
        fxa_fxb_rf0_error                       => fxa_fxb_rf0_error,
        fxa_fxb_rf0_match                       => fxa_fxb_rf0_match,
        fxa_fxb_rf0_is_ucode                    => fxa_fxb_rf0_is_ucode,
        fxa_fxb_rf0_gshare                      => fxa_fxb_rf0_gshare,
        fxa_fxb_rf0_ifar                        => fxa_fxb_rf0_ifar,
        fxa_fxb_rf0_s1_vld                      => fxa_fxb_rf0_s1_vld,
        fxa_fxb_rf0_s1                          => fxa_fxb_rf0_s1,
        fxa_fxb_rf0_s2_vld                      => fxa_fxb_rf0_s2_vld,
        fxa_fxb_rf0_s2                          => fxa_fxb_rf0_s2,
        fxa_fxb_rf0_s3_vld                      => fxa_fxb_rf0_s3_vld,
        fxa_fxb_rf0_s3                          => fxa_fxb_rf0_s3,
        fxa_fxb_rf0_axu_instr_type              => fxa_fxb_rf0_axu_instr_type,
        fxa_fxb_rf0_axu_ld_or_st                => fxa_fxb_rf0_axu_ld_or_st,
        fxa_fxb_rf0_axu_store                   => fxa_fxb_rf0_axu_store,
        fxa_fxb_rf0_axu_mftgpr                  => fxa_fxb_rf0_axu_mftgpr,
        fxa_fxb_rf0_axu_mffgpr                  => fxa_fxb_rf0_axu_mffgpr,
        fxa_fxb_rf0_axu_movedp                  => fxa_fxb_rf0_axu_movedp,
        fxa_fxb_rf0_axu_ldst_size               => fxa_fxb_rf0_axu_ldst_size,
        fxa_fxb_rf0_axu_ldst_update             => fxa_fxb_rf0_axu_ldst_update,
        fxa_fxb_rf0_axu_ldst_forcealign         => fxa_fxb_rf0_axu_ldst_forcealign,
        fxa_fxb_rf0_axu_ldst_forceexcept        => fxa_fxb_rf0_axu_ldst_forceexcept,
        fxa_fxb_rf0_axu_ldst_indexed            => fxa_fxb_rf0_axu_ldst_indexed,
        fxa_fxb_rf0_axu_ldst_tag                => fxa_fxb_rf0_axu_ldst_tag,
        fxa_fxb_rf0_pred_update                 => fxa_fxb_rf0_pred_update,
        fxa_fxb_rf0_pred_taken_cnt              => fxa_fxb_rf0_pred_taken_cnt,
        fxa_fxb_rf0_mc_dep_chk_val              => fxa_fxb_rf0_mc_dep_chk_val,
        fxa_fxb_rf1_mul_val                     => fxa_fxb_rf1_mul_val,
        fxa_fxb_rf1_muldiv_coll                 => fxa_fxb_rf1_muldiv_coll,
        fxa_fxb_rf1_div_val                     => fxa_fxb_rf1_div_val,
        fxa_fxb_rf1_div_ctr                     => fxa_fxb_rf1_div_ctr,
        fxa_fxb_rf0_xu_epid_instr               => fxa_fxb_rf0_xu_epid_instr,
        fxa_fxb_rf0_axu_is_extload              => fxa_fxb_rf0_axu_is_extload,
        fxa_fxb_rf0_axu_is_extstore             => fxa_fxb_rf0_axu_is_extstore,
        fxa_fxb_rf0_spr_tid                     => fxa_fxb_rf0_spr_tid,
        fxa_fxb_rf0_cpl_tid                     => fxa_fxb_rf0_cpl_tid,
        fxa_fxb_rf0_cpl_act                     => fxa_fxb_rf0_cpl_act,
        fxa_fxb_rf0_is_mfocrf                   => fxa_fxb_rf0_is_mfocrf,
        fxa_fxb_rf0_3src_instr                  => fxa_fxb_rf0_3src_instr,
        fxa_fxb_rf0_gpr0_zero                   => fxa_fxb_rf0_gpr0_zero,
        fxa_fxb_rf0_use_imm                     => fxa_fxb_rf0_use_imm,
        dec_cpl_ex3_mc_dep_chk_val              => dec_cpl_ex3_mc_dep_chk_val,
        fxb_fxa_ex7_we0                         => fxb_fxa_ex7_we0,
        fxb_fxa_ex7_wa0                         => fxb_fxa_ex7_wa0,
        fxb_fxa_ex7_wd0                         => fxb_fxa_ex7_wd0,
        fxa_fxb_rf1_do0                         => fxa_fxb_rf1_do0,
        fxa_fxb_rf1_do1                         => fxa_fxb_rf1_do1,
        fxa_fxb_rf1_do2                         => fxa_fxb_rf1_do2,
        fxb_fxa_ex6_clear_barrier               => fxb_fxa_ex6_clear_barrier,
        fxa_perf_muldiv_in_use                  => fxa_perf_muldiv_in_use,

        xu_is2_flush                            => is2_flush,
        xu_rf0_flush                            => rf0_flush,
        xu_rf1_flush                            => rf1_flush,
        xu_ex1_flush                            => ex1_flush,
        xu_ex2_flush                            => ex2_flush,
        xu_ex3_flush                            => ex3_flush,
        xu_ex4_flush                            => ex4_flush,
        xu_ex5_flush                            => ex5_flush,
        fxa_cpl_ex2_div_coll                    => fxa_cpl_ex2_div_coll,
        cpl_fxa_ex5_set_barr                    => cpl_fxa_ex5_set_barr,
        fxa_iu_set_barr_tid                     => fxa_iu_set_barr_tid,
        spr_xucr4_div_barr_thres                => spr_xucr4_div_barr_thres,

        an_ac_back_inv                          => an_ac_back_inv,
        an_ac_back_inv_addr                     => an_ac_back_inv_addr(62 to 63),
        an_ac_back_inv_target_bit3              => an_ac_back_inv_target_bit3,

        dec_spr_rf0_instr                       => dec_spr_rf0_instr,

        pc_xu_inj_regfile_parity                => pc_xu_inj_regfile_parity,
        xu_pc_err_regfile_parity                => xu_pc_err_regfile_parity,
        xu_pc_err_regfile_ue                    => xu_pc_err_regfile_ue,
        gpr_cpl_ex3_regfile_err_det             => gpr_cpl_ex3_regfile_err_det,
        cpl_gpr_regfile_seq_beg                 => cpl_gpr_regfile_seq_beg,
        gpr_cpl_regfile_seq_end                 => gpr_cpl_regfile_seq_end,

        xu_lsu_rf0_derat_val                    => xu_lsu_rf0_derat_val,
        xu_lsu_rf0_derat_is_extload             => xu_lsu_rf0_derat_is_extload,
        xu_lsu_rf0_derat_is_extstore            => xu_lsu_rf0_derat_is_extstore,
        lsu_xu_rel_wren                         => lsu_xu_rel_wren,
        lsu_xu_rel_ta_gpr                       => lsu_xu_rel_ta_gpr,
        fxa_cpl_debug                           => fxa_cpl_debug,

        xu_lsu_rf1_data_act                     => xu_lsu_rf1_data_act,
        xu_lsu_rf1_axu_ldst_falign              => xu_lsu_rf1_axu_ldst_falign,
        xu_lsu_ex1_store_data                   => xu_lsu_ex1_store_data,
        xu_lsu_ex1_eff_addr                     => xu_lsu_ex1_eff_addr,
        xu_lsu_ex1_rotsel_ovrd                  => xu_lsu_ex1_rotsel_ovrd,
        ex1_optype1                             => ex1_optype1,
        ex1_optype2                             => ex1_optype2,
        ex1_optype4                             => ex1_optype4,
        ex1_optype8                             => ex1_optype8,
        ex1_optype16                            => ex1_optype16,
        ex1_optype32                            => ex1_optype32,
        ex1_saxu_instr                          => ex1_saxu_instr,
        ex1_sdp_instr                           => ex1_sdp_instr,
        ex1_stgpr_instr                         => ex1_stgpr_instr,
        ex1_store_instr                         => ex1_store_instr,
        ex1_axu_op_val                          => ex1_axu_op_val,

        fu_xu_ex2_store_data_val                => fu_xu_ex2_store_data_val,
        fu_xu_ex2_store_data                    => fu_xu_ex2_store_data,
        
        ex3_algebraic                           => ex3_algebraic,
        ex3_data_swap                           => ex3_data_swap,
        ex3_thrd_id                             => ex3_thrd_id,
        bx_xu_ex5_dp_data                       => bx_xu_ex5_dp_data,

        ex4_load_op_hit                         => ex4_load_op_hit,
        ex4_store_hit                           => ex4_store_hit,
        ex4_axu_op_val                          => ex4_axu_op_val,
        spr_dvc1_act                            => spr_dvc1_act,
        spr_dvc2_act                            => spr_dvc2_act,
        spr_dvc1_dbg                            => spr_dvc1_dbg,
        spr_dvc2_dbg                            => spr_dvc2_dbg,

        rel_upd_dcarr_val                       => rel_upd_dcarr_val,

        xu_lsu_ex4_flush_local                  => xu_lsu_ex4_flush_local,

        xu_pc_err_dcache_parity                 => xu_pc_err_dcache_parity,
        pc_xu_inj_dcache_parity                 => pc_xu_inj_dcache_parity,

        xu_lsu_spr_xucr0_dcdis                  => xu_lsu_spr_xucr0_dcdis,
        spr_xucr0_clkg_ctl_b0                   => spr_xucr0_clkg_ctl_b0,

        ldq_rel_data_val_early                  => ldq_rel_data_val_early,
        ldq_rel_op_size                         => ldq_rel_op_size,
        ldq_rel_addr                            => ldq_rel_addr,
        ldq_rel_data_val                        => ldq_rel_data_val,
        ldq_rel_rot_sel                         => ldq_rel_rot_sel,
        ldq_rel_axu_val                         => ldq_rel_axu_val,
        ldq_rel_ci                              => ldq_rel_ci,
        ldq_rel_thrd_id                         => ldq_rel_thrd_id,
        ldq_rel_le_mode                         => ldq_rel_le_mode,
        ldq_rel_algebraic                       => ldq_rel_algebraic,
        ldq_rel_256_data                        => ldq_rel_256_data,
        ldq_rel_dvc1_en                         => ldq_rel_dvc1_en,
        ldq_rel_dvc2_en                         => ldq_rel_dvc2_en,
        ldq_rel_beat_crit_qw                    => ldq_rel_beat_crit_qw,
        ldq_rel_beat_crit_qw_block              => ldq_rel_beat_crit_qw_block,

        dcarr_up_way_addr                       => dcarr_up_way_addr,

        ex4_256st_data                          => ex4_256st_data,
        ex6_ld_par_err                          => ex6_ld_par_err,
        lsu_xu_ex6_datc_par_err                 => lsu_xu_ex6_datc_par_err,

        ex6_xu_ld_data_b                        => lsu_xu_rot_ex6_data_b,
        rel_xu_ld_data                          => lsu_xu_rot_rel_data,
        xu_fu_ex6_load_data                     => xu_fu_ex6_load_data,
        xu_fu_ex5_load_le                       => xu_fu_ex5_load_le,

        lsu_xu_ex2_dvc1_st_cmp                  => lsu_xu_ex2_dvc1_st_cmp,
        lsu_xu_ex2_dvc2_st_cmp                  => lsu_xu_ex2_dvc2_st_cmp,
        lsu_xu_ex8_dvc1_ld_cmp                  => lsu_xu_ex8_dvc1_ld_cmp,
        lsu_xu_ex8_dvc2_ld_cmp                  => lsu_xu_ex8_dvc2_ld_cmp,
        lsu_xu_rel_dvc_thrd_id                  => lsu_xu_rel_dvc_thrd_id,
        lsu_xu_rel_dvc1_en                      => lsu_xu_rel_dvc1_en,
        lsu_xu_rel_dvc1_cmp                     => lsu_xu_rel_dvc1_cmp,
        lsu_xu_rel_dvc2_en                      => lsu_xu_rel_dvc2_en,
        lsu_xu_rel_dvc2_cmp                     => lsu_xu_rel_dvc2_cmp,

        pc_xu_trace_bus_enable                  => pc_xu_trace_bus_enable,
        lsudat_debug_mux_ctrls                  => lsudat_debug_mux_ctrls,
        lsu_xu_data_debug0                      => lsu_xu_data_debug0,
        lsu_xu_data_debug1                      => lsu_xu_data_debug1,
        lsu_xu_data_debug2                      => lsu_xu_data_debug2,

        vdd                                     => vdd,
        gnd                                     => gnd,
        vcs                                     => vcs,
        nclk                                    => nclk,
        an_ac_scan_dis_dc_b                     => an_ac_scan_dis_dc_b,

        pc_xu_abist_g6t_bw                      => pc_xu_abist_g6t_bw,
        pc_xu_abist_di_g6t_2r                   => pc_xu_abist_di_g6t_2r,
        pc_xu_abist_wl512_comp_ena              => pc_xu_abist_wl512_comp_ena,
        pc_xu_abist_dcomp_g6t_2r                => pc_xu_abist_dcomp_g6t_2r,
        pc_xu_abist_g6t_r_wb                    => pc_xu_abist_g6t_r_wb,

        gptr_scan_in                            => fxadat_gptr_scan_in,
        gptr_scan_out                           => fxadat_gptr_scan_out,
        abst_scan_in(0)                         => abst_scan_in(1),
        abst_scan_in(1)                         => abst_scan_2,
        abst_scan_out(0)                        => abst_scan_out(1),
        abst_scan_out(1)                        => abst_scan_out(2),
        repr_scan_in                            => fxadat_repr_scan_in,
        time_scan_in                            => fxadat_time_scan_in,
        func_scan_in                            => func_scan_in(31 to 34),
        repr_scan_out                           => fxadat_repr_scan_out,
        time_scan_out                           => fxadat_time_scan_out,
        func_scan_out                           => func_scan_out(31 to 34)
);


ctlspr_time_scan_in  <= fxadat_time_scan_out;
ctlspr_repr_scan_in  <= fxadat_repr_scan_out;
ctlspr_gptr_scan_in  <= fxadat_gptr_scan_out;
fxadat_time_scan_in  <= time_scan_in;
fxadat_repr_scan_in  <= repr_scan_in;
fxadat_gptr_scan_in  <= gptr_scan_in;
time_scan_out        <= ctlspr_time_scan_out;
repr_scan_out        <= ctlspr_repr_scan_out;
gptr_scan_out        <= ctlspr_gptr_scan_out;
xu_bx_ex4_256st_data <= ex4_256st_data(128 to 255);

mark_unused(delay_lclkr_dc(0 to 3));
mark_unused(mpw1_dc_b(0 to 3));
mark_unused(sg_2(3));
mark_unused(fce_2(1));
mark_unused(func_slp_sl_thold_2);
mark_unused(cfg_sl_thold_2);
mark_unused(cfg_slp_sl_thold_2);
mark_unused(regf_slp_sl_thold_2);
mark_unused(pc_xu_abist_raddr_1(0 to 1));
mark_unused(pc_xu_abist_waddr_1(0 to 1));
mark_unused(pc_xu_abist_raddr_0(0));
mark_unused(pc_xu_abist_waddr_0(0 to 1));


end xuq;
