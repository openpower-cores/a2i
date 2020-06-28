-- © IBM Corp. 2020
-- This softcore is licensed under and subject to the terms of the CC-BY 4.0
-- license (https://creativecommons.org/licenses/by/4.0/legalcode). 
-- Additional rights, including the right to physically implement a softcore 
-- that is compliant with the required sections of the Power ISA 
-- Specification, will be available at no cost via the OpenPOWER Foundation. 
-- This README will be updated with additional information when OpenPOWER's 
-- license is available.


library ibm, ieee, work, tri, support;
use ibm.std_ulogic_support.all;
use ibm.std_ulogic_function_support.all;
use ibm.std_ulogic_unsigned.all;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use tri.tri_latches_pkg.all;
use support.power_logic_pkg.all;

entity xuq_lsu_dir is
generic(expand_type     : integer := 2;         
        l_endian_m      : integer := 1;         
        regmode         : integer := 6;
        lmq_entries     : integer := 8;
        dc_size         : natural := 14;        
        cl_size         : natural := 6;         
        wayDataSize     : natural := 35;        
	real_data_add	: integer := 42);	
port(

     xu_lsu_rf0_act             :in  std_ulogic;
     xu_lsu_rf1_cmd_act         :in  std_ulogic;
     xu_lsu_rf1_axu_op_val      :in  std_ulogic;                        
     xu_lsu_rf1_axu_ldst_falign :in  std_ulogic;
     xu_lsu_rf1_axu_ldst_fexcpt :in  std_ulogic;                        
     xu_lsu_rf1_cache_acc       :in  std_ulogic;                        
     xu_lsu_rf1_thrd_id         :in  std_ulogic_vector(0 to 3);         
     xu_lsu_rf1_optype1         :in  std_ulogic;                        
     xu_lsu_rf1_optype2         :in  std_ulogic;                        
     xu_lsu_rf1_optype4         :in  std_ulogic;                        
     xu_lsu_rf1_optype8         :in  std_ulogic;                        
     xu_lsu_rf1_optype16        :in  std_ulogic;                        
     xu_lsu_rf1_optype32        :in  std_ulogic;                        
     xu_lsu_rf1_target_gpr      :in  std_ulogic_vector(0 to 8);         
     xu_lsu_rf1_mtspr_trace     :in  std_ulogic;                        
     xu_lsu_rf1_load_instr      :in  std_ulogic;                        
     xu_lsu_rf1_store_instr     :in  std_ulogic;                        
     xu_lsu_rf1_dcbf_instr      :in  std_ulogic;                        
     xu_lsu_rf1_sync_instr      :in  std_ulogic;                        
     xu_lsu_rf1_l_fld           :in  std_ulogic_vector(0 to 1);         
     xu_lsu_rf1_dcbi_instr      :in  std_ulogic;                        
     xu_lsu_rf1_dcbz_instr      :in  std_ulogic;                        
     xu_lsu_rf1_dcbt_instr      :in  std_ulogic;                        
     xu_lsu_rf1_dcbtst_instr    :in  std_ulogic;                        
     xu_lsu_rf1_th_fld          :in  std_ulogic_vector(0 to 4);         
     xu_lsu_rf1_dcbtls_instr    :in  std_ulogic;
     xu_lsu_rf1_dcbtstls_instr  :in  std_ulogic;
     xu_lsu_rf1_dcblc_instr     :in  std_ulogic;
     xu_lsu_rf1_dcbst_instr     :in  std_ulogic;
     xu_lsu_rf1_icbi_instr      :in  std_ulogic;
     xu_lsu_rf1_icblc_instr     :in  std_ulogic;
     xu_lsu_rf1_icbt_instr      :in  std_ulogic;
     xu_lsu_rf1_icbtls_instr    :in  std_ulogic;
     xu_lsu_rf1_icswx_instr     :in  std_ulogic;
     xu_lsu_rf1_icswx_dot_instr :in  std_ulogic;
     xu_lsu_rf1_icswx_epid      :in  std_ulogic;
     xu_lsu_rf1_tlbsync_instr   :in  std_ulogic;
     xu_lsu_rf1_ldawx_instr     :in  std_ulogic;
     xu_lsu_rf1_wclr_instr      :in  std_ulogic;
     xu_lsu_rf1_wchk_instr      :in  std_ulogic;
     xu_lsu_rf1_lock_instr      :in  std_ulogic;
     xu_lsu_rf1_mutex_hint      :in  std_ulogic;                        
     xu_lsu_rf1_mbar_instr      :in  std_ulogic;
     xu_lsu_rf1_is_msgsnd       :in  std_ulogic;
     xu_lsu_rf1_dci_instr       :in  std_ulogic;                        
     xu_lsu_rf1_ici_instr       :in  std_ulogic;                        
     xu_lsu_rf1_algebraic       :in  std_ulogic;                        
     xu_lsu_rf1_byte_rev        :in  std_ulogic;                        
     xu_lsu_rf1_src_gpr         :in  std_ulogic;                        
     xu_lsu_rf1_src_axu         :in  std_ulogic;                        
     xu_lsu_rf1_src_dp          :in  std_ulogic;                        
     xu_lsu_rf1_targ_gpr        :in  std_ulogic;                        
     xu_lsu_rf1_targ_axu        :in  std_ulogic;                        
     xu_lsu_rf1_targ_dp         :in  std_ulogic;
     xu_lsu_ex4_val             :in  std_ulogic_vector(0 to 3);         
     xu_lsu_ex1_add_src0        :in  std_ulogic_vector(64-(2**REGMODE) to 63);
     xu_lsu_ex1_add_src1        :in  std_ulogic_vector(64-(2**REGMODE) to 63);

     xu_lsu_rf1_src0_vld        :in  std_ulogic;                        
     xu_lsu_rf1_src0_reg        :in  std_ulogic_vector(0 to 7);         
     xu_lsu_rf1_src1_vld        :in  std_ulogic;                        
     xu_lsu_rf1_src1_reg        :in  std_ulogic_vector(0 to 7);         
     xu_lsu_rf1_targ_vld        :in  std_ulogic;                        
     xu_lsu_rf1_targ_reg        :in  std_ulogic_vector(0 to 7);         

     pc_xu_inj_dcachedir_parity :in  std_ulogic;
     pc_xu_inj_dcachedir_multihit :in  std_ulogic;

     ex3_wimge_w_bit            :in  std_ulogic;                        
     ex3_wimge_i_bit            :in  std_ulogic;                        
     ex3_wimge_e_bit            :in  std_ulogic;                        
     ex3_p_addr                 :in  std_ulogic_vector(64-real_data_add to 51);
     derat_xu_ex3_noop_touch    :in  std_ulogic_vector(0 to 3);
     ex3_ld_queue_full          :in  std_ulogic;                        
     ex3_stq_flush              :in  std_ulogic;                        
     ex3_ig_flush               :in  std_ulogic;                        

     ex2_lm_dep_hit             :in  std_ulogic;

     ex3_way_cmp_a              :in  std_ulogic;
     ex3_way_cmp_b              :in  std_ulogic;
     ex3_way_cmp_c              :in  std_ulogic;
     ex3_way_cmp_d              :in  std_ulogic;
     ex3_way_cmp_e              :in  std_ulogic;
     ex3_way_cmp_f              :in  std_ulogic;
     ex3_way_cmp_g              :in  std_ulogic;
     ex3_way_cmp_h              :in  std_ulogic;

     ex3_wayA_tag               :in  std_ulogic_vector(64-real_data_add to 63-(dc_size-3));
     ex3_wayB_tag               :in  std_ulogic_vector(64-real_data_add to 63-(dc_size-3));
     ex3_wayC_tag               :in  std_ulogic_vector(64-real_data_add to 63-(dc_size-3));
     ex3_wayD_tag               :in  std_ulogic_vector(64-real_data_add to 63-(dc_size-3));
     ex3_wayE_tag               :in  std_ulogic_vector(64-real_data_add to 63-(dc_size-3));
     ex3_wayF_tag               :in  std_ulogic_vector(64-real_data_add to 63-(dc_size-3));
     ex3_wayG_tag               :in  std_ulogic_vector(64-real_data_add to 63-(dc_size-3));
     ex3_wayH_tag               :in  std_ulogic_vector(64-real_data_add to 63-(dc_size-3));

     xu_lsu_mtspr_trace_en      :in  std_ulogic_vector(0 to 3);
     spr_xucr0_clkg_ctl_b1      :in  std_ulogic;
     xu_lsu_spr_xucr0_aflsta    :in  std_ulogic;
     xu_lsu_spr_xucr0_flsta     :in  std_ulogic;
     xu_lsu_spr_xucr0_l2siw     :in  std_ulogic;                        
     xu_lsu_spr_xucr0_dcdis     :in  std_ulogic;
     xu_lsu_spr_xucr0_wlk       :in  std_ulogic;
     xu_lsu_spr_ccr2_dfrat      :in  std_ulogic;
     xu_lsu_spr_xucr0_clfc      :in  std_ulogic;
     xu_lsu_spr_xucr0_flh2l2    :in  std_ulogic;
     xu_lsu_spr_xucr0_cls       :in  std_ulogic;                        
     xu_lsu_spr_msr_cm          :in  std_ulogic_vector(0 to 3);         

     xu_lsu_msr_gs              :in  std_ulogic_vector(0 to 3);         
     xu_lsu_msr_pr              :in  std_ulogic_vector(0 to 3);         

     an_ac_flh2l2_gate          :in  std_ulogic;                        

     ldq_rel1_early_v           :in  std_ulogic;
     ldq_rel1_val               :in  std_ulogic;
     ldq_rel_mid_val            :in  std_ulogic;                        
     ldq_rel_retry_val          :in  std_ulogic;                        
     ldq_rel3_early_v           :in  std_ulogic;
     ldq_rel3_val               :in  std_ulogic;
     ldq_rel_back_invalidated   :in  std_ulogic;
     ldq_rel_data_val_early     :in  std_ulogic;                        
     rel_data_val               :in  std_ulogic;
     ldq_rel_tag                :in  std_ulogic_vector(1 to 3);
     ldq_rel_tag_early          :in  std_ulogic_vector(1 to 3);
     ldq_rel_set_val            :in  std_ulogic;
     ldq_rel_ecc_err            :in  std_ulogic;
     ldq_rel_classid            :in  std_ulogic_vector(0 to 1);
     ldq_rel_lock_en            :in  std_ulogic;
     ldq_rel_l1dump_cslc        :in  std_ulogic;
     ldq_rel3_l1dump_val        :in  std_ulogic;
     ldq_rel_watch_en           :in  std_ulogic;
     ldq_rel_addr               :in  std_ulogic_vector(64-real_data_add to 52);
     ldq_rel_addr_early         :in  std_ulogic_vector(64-real_data_add to 63-cl_size);
     ldq_recirc_rel_val         :out std_ulogic;

     xu_lsu_dci                 :in  std_ulogic;                        

     is2_l2_inv_val             :in  std_ulogic;                        

     ex6_ld_par_err             :in  std_ulogic;                        

     xu_lsu_rf1_flush           :in  std_ulogic_vector(0 to 3);
     xu_lsu_ex1_flush           :in  std_ulogic_vector(0 to 3);
     xu_lsu_ex2_flush           :in  std_ulogic_vector(0 to 3);
     xu_lsu_ex3_flush           :in  std_ulogic_vector(0 to 3);
     xu_lsu_ex4_flush           :in  std_ulogic_vector(0 to 3);
     xu_lsu_ex5_flush           :in  std_ulogic_vector(0 to 3);

     xu_lsu_slowspr_val         :in  std_ulogic;
     xu_lsu_slowspr_rw          :in  std_ulogic;
     xu_lsu_slowspr_etid        :in  std_ulogic_vector(0 to 1);
     xu_lsu_slowspr_addr        :in  std_ulogic_vector(0 to 9);
     xu_lsu_slowspr_data        :in  std_ulogic_vector(64-(2**REGMODE) to 63);
     xu_lsu_slowspr_done        :in  std_ulogic;
     slowspr_val_out            :out std_ulogic;
     slowspr_rw_out             :out std_ulogic;
     slowspr_etid_out           :out std_ulogic_vector(0 to 1);
     slowspr_addr_out           :out std_ulogic_vector(0 to 9);
     slowspr_data_out           :out std_ulogic_vector(64-(2**REGMODE) to 63);
     slowspr_done_out           :out std_ulogic;

     ldq_rel_axu_val            :in  std_ulogic;                        
     ldq_rel_thrd_id            :in  std_ulogic_vector(0 to 3);         
     ldq_rel_ta_gpr             :in  std_ulogic_vector(0 to 8);
     ldq_rel_upd_gpr            :in  std_ulogic;
     ldq_rel_ci                 :in  std_ulogic;          

     dir_arr_rd_addr_01         :out std_ulogic_vector(64-(dc_size-3) to 63-cl_size);
     dir_arr_rd_addr_23         :out std_ulogic_vector(64-(dc_size-3) to 63-cl_size);
     dir_arr_rd_addr_45         :out std_ulogic_vector(64-(dc_size-3) to 63-cl_size);
     dir_arr_rd_addr_67         :out std_ulogic_vector(64-(dc_size-3) to 63-cl_size);
     dir_arr_rd_data            :in  std_ulogic_vector(0 to 8*wayDataSize-1);

     dir_wr_enable              :out std_ulogic_vector(0 to 3);
     dir_wr_way                 :out std_ulogic_vector(0 to 7);
     dir_arr_wr_addr            :out std_ulogic_vector(64-(dc_size-3) to 63-cl_size);
     dir_arr_wr_data            :out std_ulogic_vector(64-real_data_add to 64-real_data_add+wayDataSize-1);

     ex1_src0_vld               :out std_ulogic;                        
     ex1_src0_reg               :out std_ulogic_vector(0 to 7);         
     ex1_src1_vld               :out std_ulogic;                        
     ex1_src1_reg               :out std_ulogic_vector(0 to 7);         
     ex1_targ_vld               :out std_ulogic;                        
     ex1_targ_reg               :out std_ulogic_vector(0 to 7);
     ex1_check_watch            :out std_ulogic_vector(0 to 3);         

     ex3_cache_acc              :out std_ulogic;
     ex1_optype1                :out std_ulogic;
     ex1_optype2                :out std_ulogic;
     ex1_optype4                :out std_ulogic;
     ex1_optype8                :out std_ulogic;
     ex1_optype16               :out std_ulogic;
     ex1_optype32               :out std_ulogic;
     ex1_saxu_instr             :out std_ulogic;
     ex1_sdp_instr              :out std_ulogic;
     ex1_stgpr_instr            :out std_ulogic;
     ex1_store_instr            :out std_ulogic;
     ex1_axu_op_val             :out std_ulogic;

     lsu_xu_ex3_align           :out std_ulogic_vector(0 to 3);         
     lsu_xu_ex3_dsi             :out std_ulogic_vector(0 to 3);         
     lsu_xu_ex3_inval_align_2ucode :out std_ulogic;                        

     ex3_stg_flush              :out std_ulogic;
     ex4_stg_flush              :out std_ulogic;                        
     lsu_xu_ex3_n_flush_req     :out std_ulogic;
     lsu_xu_ex4_ldq_full_flush  :out std_ulogic;
     lsu_xu_ex3_dep_flush       :out std_ulogic;

     xu_derat_ex1_epn_arr       :out std_ulogic_vector(64-(2**regmode) to 51);
     xu_derat_ex1_epn_nonarr    :out std_ulogic_vector(64-(2**regmode) to 51);
     snoop_addr                 :in  std_ulogic_vector(64-(2**regmode) to 51);
     snoop_addr_sel             :in  std_ulogic;
     xu_derat_rf1_binv_val      :out std_ulogic;
     ex3_req_thrd_id            :out std_ulogic_vector(0 to 3);
     ex3_target_gpr             :out std_ulogic_vector(0 to 8);
     ex3_dcbt_instr             :out std_ulogic;
     ex3_dcbtst_instr           :out std_ulogic;
     ex3_th_fld_l2              :out std_ulogic;
     ex3_dcbst_instr            :out std_ulogic;
     ex3_dcbf_instr             :out std_ulogic;
     ex3_sync_instr             :out std_ulogic;
     ex3_mtspr_trace            :out std_ulogic;
     ex3_byte_en                :out std_ulogic_vector(0 to 31);
     ex3_l_fld                  :out std_ulogic_vector(0 to 1);
     ex3_dcbi_instr             :out std_ulogic;
     ex3_dcbz_instr             :out std_ulogic;
     ex3_icbi_instr             :out std_ulogic;
     ex3_icswx_instr            :out std_ulogic;
     ex3_icswx_dot              :out std_ulogic;
     ex3_icswx_epid             :out std_ulogic;
     ex3_mbar_instr             :out std_ulogic;
     ex3_msgsnd_instr           :out std_ulogic;
     ex3_dci_instr              :out std_ulogic;
     ex3_ici_instr              :out std_ulogic;
     ex3_load_instr             :out std_ulogic;
     ex3_store_instr            :out std_ulogic;
     ex3_axu_op_val             :out std_ulogic;
     ex3_algebraic              :out std_ulogic;
     ex3_dcbtls_instr           :out std_ulogic;
     ex3_dcbtstls_instr         :out std_ulogic;
     ex3_dcblc_instr            :out std_ulogic;
     ex3_icblc_instr            :out std_ulogic;
     ex3_icbt_instr             :out std_ulogic;
     ex3_icbtls_instr           :out std_ulogic;
     ex3_tlbsync_instr          :out std_ulogic;
     ex3_local_dcbf             :out std_ulogic;
     ex3_lock_en                :out std_ulogic;
     ex4_drop_rel               :out std_ulogic;
     ex3_load_l1hit             :out std_ulogic;
     ex3_rotate_sel             :out std_ulogic_vector(0 to 4);
     ex3_watch_en               :out std_ulogic;
     ex3_data_swap              :out std_ulogic;
     ex3_blkable_touch          :out std_ulogic;
     ex7_targ_match             :out std_ulogic;                
     ex8_targ_match             :out std_ulogic;                
     ex4_ld_entry               :out std_ulogic_vector(0 to 67);

     ex3_cache_inh              :out std_ulogic;
     ex3_l_s_q_val              :out std_ulogic;
     ex3_drop_ld_req            :out std_ulogic;
     ex3_drop_touch             :out std_ulogic;
     ex3_stx_instr              :out std_ulogic;
     ex3_larx_instr             :out std_ulogic;
     ex3_mutex_hint             :out std_ulogic;
     ex3_opsize                 :out std_ulogic_vector(0 to 5);
     ex4_dir_perr_det           :out std_ulogic;
     ex4_dir_multihit_det       :out std_ulogic;
     ex4_n_lsu_ddmh_flush       :out std_ulogic_vector(0 to 3);         

     ex2_p_addr_lwr             :out std_ulogic_vector(52 to 57);
     ex3_p_addr_lwr             :out std_ulogic_vector(58 to 63);
     dcpar_err_flush            :out std_ulogic;
     pe_recov_begin             :out std_ulogic;

     lsu_xu_ex3_ddir_par_err    :out std_ulogic;
     ex3_cClass_collision       :in  std_ulogic;

     ex3_cClass_upd_way_a       :out std_ulogic;
     ex3_cClass_upd_way_b       :out std_ulogic;
     ex3_cClass_upd_way_c       :out std_ulogic;
     ex3_cClass_upd_way_d       :out std_ulogic;
     ex3_cClass_upd_way_e       :out std_ulogic;
     ex3_cClass_upd_way_f       :out std_ulogic; 
     ex3_cClass_upd_way_g       :out std_ulogic;
     ex3_cClass_upd_way_h       :out std_ulogic;

     ex2_wayA_tag               :out std_ulogic_vector(64-real_data_add to 63-(dc_size-3));
     ex2_wayB_tag               :out std_ulogic_vector(64-real_data_add to 63-(dc_size-3));
     ex2_wayC_tag               :out std_ulogic_vector(64-real_data_add to 63-(dc_size-3));
     ex2_wayD_tag               :out std_ulogic_vector(64-real_data_add to 63-(dc_size-3));
     ex2_wayE_tag               :out std_ulogic_vector(64-real_data_add to 63-(dc_size-3));
     ex2_wayF_tag               :out std_ulogic_vector(64-real_data_add to 63-(dc_size-3));
     ex2_wayG_tag               :out std_ulogic_vector(64-real_data_add to 63-(dc_size-3));
     ex2_wayH_tag               :out std_ulogic_vector(64-real_data_add to 63-(dc_size-3));      

     rel_upd_dcarr_val          :out std_ulogic;

     lsu_xu_ex4_cr_upd          :out std_ulogic;
     lsu_xu_ex5_cr_rslt         :out std_ulogic;
     lsu_xu_ex5_wren            :out std_ulogic;
     lsu_xu_rel_wren            :out std_ulogic;
     lsu_xu_rel_ta_gpr          :out std_ulogic_vector(0 to 7);
     lsu_xu_perf_events         :out std_ulogic_vector(0 to 37);
     lsu_xu_need_hole           :out std_ulogic;
     xu_fu_ex5_reload_val       :out std_ulogic;
     xu_fu_ex5_load_val         :out std_ulogic_vector(0 to 3);
     xu_fu_ex5_load_tag         :out std_ulogic_vector(0 to 8);

     xu_iu_ex6_icbi_val         :out std_ulogic_vector(0 to 3);
     xu_iu_ex6_icbi_addr        :out std_ulogic_vector(64-real_data_add to 57);    

     dcarr_up_way_addr          :out std_ulogic_vector(0 to 2);

     xu_derat_epsc_wr           :out std_ulogic_vector(0 to 3);
     xu_derat_eplc_wr           :out std_ulogic_vector(0 to 3);
     xu_derat_eplc0_epr         :out std_ulogic;
     xu_derat_eplc0_eas         :out std_ulogic;
     xu_derat_eplc0_egs         :out std_ulogic;
     xu_derat_eplc0_elpid       :out std_ulogic_vector(40 to 47);
     xu_derat_eplc0_epid        :out std_ulogic_vector(50 to 63);
     xu_derat_eplc1_epr         :out std_ulogic;
     xu_derat_eplc1_eas         :out std_ulogic;
     xu_derat_eplc1_egs         :out std_ulogic;
     xu_derat_eplc1_elpid       :out std_ulogic_vector(40 to 47);
     xu_derat_eplc1_epid        :out std_ulogic_vector(50 to 63);
     xu_derat_eplc2_epr         :out std_ulogic;
     xu_derat_eplc2_eas         :out std_ulogic;
     xu_derat_eplc2_egs         :out std_ulogic;
     xu_derat_eplc2_elpid       :out std_ulogic_vector(40 to 47);
     xu_derat_eplc2_epid        :out std_ulogic_vector(50 to 63);
     xu_derat_eplc3_epr         :out std_ulogic;
     xu_derat_eplc3_eas         :out std_ulogic;
     xu_derat_eplc3_egs         :out std_ulogic;
     xu_derat_eplc3_elpid       :out std_ulogic_vector(40 to 47);
     xu_derat_eplc3_epid        :out std_ulogic_vector(50 to 63);
     xu_derat_epsc0_epr         :out std_ulogic;
     xu_derat_epsc0_eas         :out std_ulogic;
     xu_derat_epsc0_egs         :out std_ulogic;
     xu_derat_epsc0_elpid       :out std_ulogic_vector(40 to 47);
     xu_derat_epsc0_epid        :out std_ulogic_vector(50 to 63);
     xu_derat_epsc1_epr         :out std_ulogic;
     xu_derat_epsc1_eas         :out std_ulogic;
     xu_derat_epsc1_egs         :out std_ulogic;
     xu_derat_epsc1_elpid       :out std_ulogic_vector(40 to 47);
     xu_derat_epsc1_epid        :out std_ulogic_vector(50 to 63);
     xu_derat_epsc2_epr         :out std_ulogic;
     xu_derat_epsc2_eas         :out std_ulogic;
     xu_derat_epsc2_egs         :out std_ulogic;
     xu_derat_epsc2_elpid       :out std_ulogic_vector(40 to 47);
     xu_derat_epsc2_epid        :out std_ulogic_vector(50 to 63);
     xu_derat_epsc3_epr         :out std_ulogic;
     xu_derat_epsc3_eas         :out std_ulogic;
     xu_derat_epsc3_egs         :out std_ulogic;
     xu_derat_epsc3_elpid       :out std_ulogic_vector(40 to 47);
     xu_derat_epsc3_epid        :out std_ulogic_vector(50 to 63);

     ex1_stg_act                :out std_ulogic;
     ex2_stg_act                :out std_ulogic;
     ex3_stg_act                :out std_ulogic;
     ex4_stg_act                :out std_ulogic;
     binv1_stg_act              :out std_ulogic;
     binv2_stg_act              :out std_ulogic;

     lsu_xu_spr_xucr0_cslc_xuop :out std_ulogic;                        
     lsu_xu_spr_xucr0_cslc_binv :out std_ulogic;                        
     lsu_xu_spr_xucr0_clo       :out std_ulogic;                        
     lsu_xu_spr_xucr0_cul       :out std_ulogic;                        
     spr_xucr0_cls              :out std_ulogic;                        

     dir_arr_rd_is2_val         :out std_ulogic;
     dir_arr_rd_congr_cl        :out std_ulogic_vector(0 to 4);

     ex4_load_op_hit            :out std_ulogic;
     ex4_store_hit              :out std_ulogic;
     ex4_axu_op_val             :out std_ulogic;
     spr_dvc1_act               :out std_ulogic;
     spr_dvc2_act               :out std_ulogic;
     spr_dvc1_dbg               :out std_ulogic_vector(64-(2**regmode) to 63);
     spr_dvc2_dbg               :out std_ulogic_vector(64-(2**regmode) to 63);

     pc_xu_trace_bus_enable     :in  std_ulogic;
     dc_fgen_dbg_data           :out std_ulogic_vector(0 to 1);
     dc_cntrl_dbg_data          :out std_ulogic_vector(0 to 66);
     dc_val_dbg_data            :out std_ulogic_vector(0 to 293);
     dc_lru_dbg_data            :out std_ulogic_vector(0 to 81);
     dc_dir_dbg_data            :out std_ulogic_vector(0 to 35);
     dir_arr_dbg_data           :out std_ulogic_vector(0 to 60);

     vdd                        :inout power_logic;
     gnd                        :inout power_logic;
     nclk                       :in  clk_logic;
     sg_0                       :in  std_ulogic;
     func_sl_thold_0_b          :in  std_ulogic;
     func_sl_force              :in  std_ulogic;
     func_slp_sl_thold_0_b      :in  std_ulogic;
     func_slp_sl_force          :in  std_ulogic;
     func_nsl_thold_0_b         :in  std_ulogic;
     func_nsl_force             :in  std_ulogic;
     func_slp_nsl_thold_0_b     :in  std_ulogic;
     func_slp_nsl_force         :in  std_ulogic;
     d_mode_dc                  :in  std_ulogic;
     delay_lclkr_dc             :in  std_ulogic;
     mpw1_dc_b                  :in  std_ulogic;
     mpw2_dc_b                  :in  std_ulogic;
     scan_in                    :in  std_ulogic_vector(0 to 3);
     scan_out                   :out std_ulogic_vector(0 to 3)     
);
-- synopsys translate_off
-- synopsys translate_on
end xuq_lsu_dir;
architecture xuq_lsu_dir of xuq_lsu_dir is


constant uprCClassBit                   :natural := 64-(dc_size-3);
constant lwrCClassBit                   :natural := 63-cl_size;
constant uprTagBit                      :natural := 64-real_data_add;
constant lwrTagBit                      :natural := 63-(dc_size-3);
constant tagSize                        :natural := lwrTagBit-uprTagBit+1;
constant parExtCalc                     :natural := 8 - (tagSize mod 8);
constant parBits                        :natural := (tagSize+parExtCalc) / 8;

constant lwr_p_addr_offset              :natural := 0;
constant ldq_rel1_val_stg_offset        :natural := lwr_p_addr_offset + 12;
constant ldq_rel_mid_stg_offset         :natural := ldq_rel1_val_stg_offset + 1;
constant ldq_rel3_val_stg_offset        :natural := ldq_rel_mid_stg_offset + 1;
constant spr_xucr0_dcdis_offset         :natural := ldq_rel3_val_stg_offset + 1;
constant ex4_dir_perr_det_offset        :natural := spr_xucr0_dcdis_offset + 1;
constant recirc_rel_val_offset          :natural := ex4_dir_perr_det_offset + 1;
constant trace_bus_enable_offset        :natural := recirc_rel_val_offset + 1;
constant scan_right                     :natural := trace_bus_enable_offset + 1 - 1;

signal ex1_p_addr               :std_ulogic_vector(64-(dc_size-3) to 63-cl_size);
signal lwr_p_addr_d             :std_ulogic_vector(52 to 63);
signal lwr_p_addr_q             :std_ulogic_vector(52 to 63);
signal rel1_val                 :std_ulogic;
signal rel_mid_val              :std_ulogic;
signal rel3_val                 :std_ulogic;
signal ldq_rel_stg24_val_d      :std_ulogic;
signal ldq_rel_stg24_val_q      :std_ulogic;
signal rel_st_tag               :std_ulogic_vector(1 to 3);
signal rel_st_tag_early         :std_ulogic_vector(1 to 3);
signal rel24_addr_d             :std_ulogic_vector(64-real_data_add to 52);
signal rel24_addr_q             :std_ulogic_vector(64-real_data_add to 52);
signal rel_way_val_a            :std_ulogic;
signal rel_way_val_b            :std_ulogic;
signal rel_way_val_c            :std_ulogic;
signal rel_way_val_d            :std_ulogic;
signal rel_way_val_e            :std_ulogic;
signal rel_way_val_f            :std_ulogic;
signal rel_way_val_g            :std_ulogic;
signal rel_way_val_h            :std_ulogic;
signal rel_way_lock_a           :std_ulogic;
signal rel_way_lock_b           :std_ulogic;
signal rel_way_lock_c           :std_ulogic;
signal rel_way_lock_d           :std_ulogic;
signal rel_way_lock_e           :std_ulogic;
signal rel_way_lock_f           :std_ulogic;
signal rel_way_lock_g           :std_ulogic;
signal rel_way_lock_h           :std_ulogic;
signal ex2_is_inval_op          :std_ulogic;
signal ex2_lock_set             :std_ulogic;
signal ex2_lock_clr             :std_ulogic;
signal rel_wayA_wen             :std_ulogic;
signal rel_wayB_wen             :std_ulogic;
signal rel_wayC_wen             :std_ulogic;
signal rel_wayD_wen             :std_ulogic;
signal rel_wayE_wen             :std_ulogic;
signal rel_wayF_wen             :std_ulogic;
signal rel_wayG_wen             :std_ulogic;
signal rel_wayH_wen             :std_ulogic;
signal ex3_l1hit                :std_ulogic;
signal ex4_l1miss               :std_ulogic;
signal ex4_way_a_hit            :std_ulogic;
signal ex4_way_b_hit            :std_ulogic;
signal ex4_way_c_hit            :std_ulogic;
signal ex4_way_d_hit            :std_ulogic;
signal ex4_way_e_hit            :std_ulogic;
signal ex4_way_f_hit            :std_ulogic;
signal ex4_way_g_hit            :std_ulogic;
signal ex4_way_h_hit            :std_ulogic;
signal ex4_way_a_dir            :std_ulogic_vector(0 to 5);
signal ex4_way_b_dir            :std_ulogic_vector(0 to 5);
signal ex4_way_c_dir            :std_ulogic_vector(0 to 5);
signal ex4_way_d_dir            :std_ulogic_vector(0 to 5);
signal ex4_way_e_dir            :std_ulogic_vector(0 to 5);
signal ex4_way_f_dir            :std_ulogic_vector(0 to 5);
signal ex4_way_g_dir            :std_ulogic_vector(0 to 5);
signal ex4_way_h_dir            :std_ulogic_vector(0 to 5);
signal rel_way_upd_a            :std_ulogic;
signal rel_way_upd_b            :std_ulogic;
signal rel_way_upd_c            :std_ulogic;
signal rel_way_upd_d            :std_ulogic;
signal rel_way_upd_e            :std_ulogic;
signal rel_way_upd_f            :std_ulogic;
signal rel_way_upd_g            :std_ulogic;
signal rel_way_upd_h            :std_ulogic;
signal rel_way_clr_a            :std_ulogic;
signal rel_way_clr_b            :std_ulogic;
signal rel_way_clr_c            :std_ulogic;
signal rel_way_clr_d            :std_ulogic;
signal rel_way_clr_e            :std_ulogic;
signal rel_way_clr_f            :std_ulogic;
signal rel_way_clr_g            :std_ulogic;
signal rel_way_clr_h            :std_ulogic;
signal rel4_set_val             :std_ulogic;
signal stg_ex2_flush            :std_ulogic;
signal stg_ex3_flush            :std_ulogic;
signal stg_ex4_flush            :std_ulogic;
signal stg_ex5_flush            :std_ulogic;
signal ex2_no_lru_upd           :std_ulogic;
signal ex3_tag_way_perr         :std_ulogic_vector(0 to 7);
signal ex3_cache_en             :std_ulogic;
signal rel_lock_en              :std_ulogic;
signal rel_l1dump_cslc          :std_ulogic;
signal rel3_l1dump_val          :std_ulogic;
signal rel1_classid             :std_ulogic_vector(0 to 1);
signal dcbtstls_instr_ex3       :std_ulogic;
signal dcbtls_instr_ex3         :std_ulogic;
signal ex1_frc_align2           :std_ulogic;
signal ex1_frc_align4           :std_ulogic;
signal ex1_frc_align8           :std_ulogic;
signal ex1_frc_align16          :std_ulogic;
signal ex1_frc_align32          :std_ulogic;
signal spr_xucr2_rmt            :std_ulogic_vector(0 to 31);
signal spr_xucr0_wlck           :std_ulogic;
signal ex5_load_op_hit          :std_ulogic;
signal ex2_ddir_acc_instr       :std_ulogic;
signal ex3_dir_perr_det         :std_ulogic;
signal ex4_ldq_full_flush       :std_ulogic;
signal rel_up_way_addr_b        :std_ulogic_vector(0 to 2);         
signal rel_dcarr_addr_en        :std_ulogic;                        
signal rel_dcarr_val_upd        :std_ulogic;
signal spr_xucr0_dcdis_d        :std_ulogic;
signal spr_xucr0_dcdis_q        :std_ulogic;
signal ex2_p_addr_lwr_int       :std_ulogic_vector(52 to 63);
signal ex1_thrd_id              :std_ulogic_vector(0 to 3);
signal ex2_ldawx_instr          :std_ulogic;
signal ex2_wclr_instr           :std_ulogic;
signal ex2_wchk_val             :std_ulogic;
signal ex2_l_fld                :std_ulogic_vector(0 to 1);
signal store_instr_ex2          :std_ulogic;
signal rel_watch_en             :std_ulogic;
signal rel_thrd_id              :std_ulogic_vector(0 to 3);
signal ex1_l2_inv_val           :std_ulogic;
signal ex1_l2_inv_val_b         :std_ulogic;
signal ex2_frc_align_d          :std_ulogic_vector(59 to 63);
signal ex2_frc_align_q          :std_ulogic_vector(59 to 63);
signal ex1_lsu_64bit_agen       :std_ulogic;
signal ex1_agen_addr            :std_ulogic_vector(64-(2**regmode) to 51);
signal ex1_dir01_addr           :std_ulogic_vector(64-(dc_size-3) to 63-cl_size);
signal ex1_dir23_addr           :std_ulogic_vector(64-(dc_size-3) to 63-cl_size);
signal ex1_dir45_addr           :std_ulogic_vector(64-(dc_size-3) to 63-cl_size);
signal ex1_dir67_addr           :std_ulogic_vector(64-(dc_size-3) to 63-cl_size);
signal ex1_eff_addr             :std_ulogic_vector(64-(2**regmode)  to 63);
signal ex4_dir_perr_det_d       :std_ulogic;
signal ex4_dir_perr_det_q       :std_ulogic;
signal recirc_rel_val           :std_ulogic;
signal recirc_rel_val_d         :std_ulogic;
signal recirc_rel_val_q         :std_ulogic;
signal ex1_dir_acc_val          :std_ulogic;
signal ex1_dir_acc_val_b        :std_ulogic;
signal rf1_l2_inv_val           :std_ulogic;
signal ex1_agen_binv_val        :std_ulogic;
signal dir_wr_enable_int        :std_ulogic_vector(0 to 3);
signal dir_arr_wr_addr_int      :std_ulogic_vector(64-(dc_size-3) to 63-cl_size);
signal dir_wr_way_int           :std_ulogic_vector(0 to 7);
signal dir_arr_wr_data_int      :std_ulogic_vector(64-real_data_add to 64-real_data_add+wayDataSize-1);
signal ex1_stg_act_int          :std_ulogic;
signal ex2_stg_act_int          :std_ulogic;
signal ex3_stg_act_int          :std_ulogic;
signal ex4_stg_act_int          :std_ulogic;
signal ex5_stg_act_int          :std_ulogic;
signal binv1_stg_act_int        :std_ulogic;
signal binv2_stg_act_int        :std_ulogic;
signal binv3_stg_act_int        :std_ulogic;
signal binv4_stg_act_int        :std_ulogic;
signal binv5_stg_act_int        :std_ulogic;
signal rel1_stg_act_int         :std_ulogic;
signal rel2_stg_act_int         :std_ulogic;
signal rel3_stg_act_int         :std_ulogic;
signal binv1_ex1_stg_act        :std_ulogic;
signal ex2_lockwatchSet_rel_coll :std_ulogic;
signal ex3_wclr_all_flush       :std_ulogic;
signal spr_xucr0_cls_int        :std_ulogic;
signal agen_xucr0_cls           :std_ulogic;
signal agen_xucr0_cls_b         :std_ulogic;
signal tag_scan_out             :std_ulogic;
signal lru_scan_out             :std_ulogic;
signal dir_scan_out             :std_ulogic;
signal ex3_way_tag_par_a        :std_ulogic_vector(0 to parBits-1);
signal ex3_way_tag_par_b        :std_ulogic_vector(0 to parBits-1);
signal ex3_way_tag_par_c        :std_ulogic_vector(0 to parBits-1);
signal ex3_way_tag_par_d        :std_ulogic_vector(0 to parBits-1);
signal ex3_way_tag_par_e        :std_ulogic_vector(0 to parBits-1);
signal ex3_way_tag_par_f        :std_ulogic_vector(0 to parBits-1);
signal ex3_way_tag_par_g        :std_ulogic_vector(0 to parBits-1);
signal ex3_way_tag_par_h        :std_ulogic_vector(0 to parBits-1);
signal ex4_dir_lru              :std_ulogic_vector(0 to 6);
signal ex3_load_val             :std_ulogic;
signal ex3_l2_request           :std_ulogic;
signal ex3_ldq_potential_flush  :std_ulogic;
signal ex4_snd_ld_l2            :std_ulogic;
signal ldq_rel1_val_stg_d       :std_ulogic;
signal ldq_rel1_val_stg_q       :std_ulogic;
signal ldq_rel_mid_stg_d        :std_ulogic;
signal ldq_rel_mid_stg_q        :std_ulogic;
signal ldq_rel3_val_stg_d       :std_ulogic;
signal ldq_rel3_val_stg_q       :std_ulogic;
signal ldq_rel_data_stg_d       :std_ulogic;
signal ldq_rel_data_stg_q       :std_ulogic;
signal ldq_rel_set_stg_d        :std_ulogic;
signal ldq_rel_set_stg_q        :std_ulogic;
signal trace_bus_enable_q       :std_ulogic;
signal dir_arr_dbg_data_d       :std_ulogic_vector(0 to 60);
signal dir_arr_dbg_data_q       :std_ulogic_vector(0 to 60);
signal ex3_cache_acc_int        :std_ulogic;

signal tiup                     :std_ulogic;
signal siv                      :std_ulogic_vector(0 to scan_right);
signal sov                      :std_ulogic_vector(0 to scan_right);
begin


tiup <= '1';

ex2_frc_align_d(59) <= not ex1_frc_align32;
ex2_frc_align_d(60) <= not (ex1_frc_align32 or ex1_frc_align16);
ex2_frc_align_d(61) <= not (ex1_frc_align32 or ex1_frc_align16 or ex1_frc_align8);
ex2_frc_align_d(62) <= not (ex1_frc_align32 or ex1_frc_align16 or ex1_frc_align8 or ex1_frc_align4);
ex2_frc_align_d(63) <= not (ex1_frc_align32 or ex1_frc_align16 or ex1_frc_align8 or ex1_frc_align4 or ex1_frc_align2);

spr_xucr0_dcdis_d   <= xu_lsu_spr_xucr0_dcdis;
ldq_rel_stg24_val_d <= ldq_rel1_val or ldq_rel3_val or ldq_rel_ci or rel_data_val or ldq_rel_mid_val;

ldq_rel1_val_stg_d <= ldq_rel1_val;
ldq_rel_mid_stg_d  <= ldq_rel_mid_val;
ldq_rel3_val_stg_d <= ldq_rel3_val;
ldq_rel_data_stg_d <= rel_data_val;
ldq_rel_set_stg_d  <= ldq_rel_set_val;
rel1_val           <= ldq_rel1_val and not spr_xucr0_dcdis_q;
rel_st_tag         <= ldq_rel_tag;
rel_st_tag_early   <= ldq_rel_tag_early;
rel24_addr_d       <= ldq_rel_addr;
rel4_set_val       <= ldq_rel_set_val;
rel_lock_en        <= ldq_rel_lock_en;
rel_l1dump_cslc    <= ldq_rel_l1dump_cslc and not spr_xucr0_dcdis_q;
rel3_l1dump_val    <= ldq_rel3_l1dump_val and not spr_xucr0_dcdis_q;
rel_watch_en       <= ldq_rel_watch_en;
rel_thrd_id        <= ldq_rel_thrd_id;
rel1_classid       <= ldq_rel_classid;
rel3_val           <= ldq_rel3_val and not spr_xucr0_dcdis_q;
rel_mid_val        <= ldq_rel_mid_val and not spr_xucr0_dcdis_q;
ex2_p_addr_lwr_int <= lwr_p_addr_q(52 to 58) & (lwr_p_addr_q(59 to 63) and ex2_frc_align_q);
binv1_ex1_stg_act  <= binv1_stg_act_int or ex1_stg_act_int;



agen_xucr0_cls_b  <= not agen_xucr0_cls;
ex1_dir_acc_val_b <= not ex1_dir_acc_val;
ex1_l2_inv_val_b  <= not ex1_l2_inv_val;

Mode32b : if regmode = 5 generate begin
  ex1_eff_addr     <= std_ulogic_vector(unsigned(xu_lsu_ex1_add_src0) + unsigned(xu_lsu_ex1_add_src1));
  ex1_agen_addr    <= ex1_eff_addr(64-(2**regmode) to 51);
  lwr_p_addr_d     <= ex1_eff_addr(52 to 63);
  ex1_p_addr       <= ex1_eff_addr(64-(dc_size-3) to 63-cl_size);
  ex1_dir01_addr(64-(dc_size-3) to 63-cl_size-1) <= ex1_eff_addr(64-(dc_size-3) to 63-cl_size-1);
  ex1_dir01_addr(63-cl_size)                     <= ex1_eff_addr(63-cl_size) or agen_xucr0_cls;
  ex1_dir23_addr(64-(dc_size-3) to 63-cl_size-1) <= ex1_eff_addr(64-(dc_size-3) to 63-cl_size-1);
  ex1_dir23_addr(63-cl_size)                     <= ex1_eff_addr(63-cl_size) or agen_xucr0_cls;
  ex1_dir45_addr(64-(dc_size-3) to 63-cl_size-1) <= ex1_eff_addr(64-(dc_size-3) to 63-cl_size-1);
  ex1_dir45_addr(63-cl_size)                     <= ex1_eff_addr(63-cl_size) or agen_xucr0_cls;
  ex1_dir67_addr(64-(dc_size-3) to 63-cl_size-1) <= ex1_eff_addr(64-(dc_size-3) to 63-cl_size-1);
  ex1_dir67_addr(63-cl_size)                     <= ex1_eff_addr(63-cl_size) or agen_xucr0_cls;
end generate Mode32b;

Mode64b : if regmode = 6 generate begin
  lsuagen : entity work.xuq_agen(xuq_agen)
  port map(
       x                => xu_lsu_ex1_add_src0,
       y                => xu_lsu_ex1_add_src1,
       mode64           => ex1_lsu_64bit_agen,
       dir_ig_57_b      => agen_xucr0_cls_b,
       snoop_addr       => snoop_addr(0 to 51),
       snoop_sel        => snoop_addr_sel,
       binv_val         => ex1_agen_binv_val,
       sum_non_erat     => ex1_eff_addr,
       sum              => ex1_agen_addr(0 to 51),
       sum_arr_dir01    => ex1_dir01_addr,
       sum_arr_dir23    => ex1_dir23_addr,
       sum_arr_dir45    => ex1_dir45_addr,
       sum_arr_dir67    => ex1_dir67_addr,
       z                => dir_arr_wr_addr_int,
       way              => dir_wr_way_int,
       inv1_val_b       => ex1_l2_inv_val_b,
       ex1_cache_acc_b  => ex1_dir_acc_val_b,
       rel3_val         => rel3_val,
       ary_write_act_01 => dir_wr_enable(0),
       ary_write_act_23 => dir_wr_enable(1),
       ary_write_act_45 => dir_wr_enable(2),
       ary_write_act_67 => dir_wr_enable(3),
       ary_write_act    => dir_wr_enable_int,
       match_oth        => recirc_rel_val,
       vdd              => vdd,
       gnd              => gnd
  );

  lwr_p_addr_d     <= ex1_eff_addr(52 to 63);
  ex1_p_addr       <= ex1_eff_addr(64-(dc_size-3) to 63-cl_size);
end generate Mode64b;

recirc_rel_val_d <= recirc_rel_val and rel3_val;


lsudc : entity work.xuq_lsu_dc(xuq_lsu_dc)
generic map(expand_type         => expand_type,
            l_endian_m          => l_endian_m,
            regmode             => regmode,
            dc_size             => dc_size,
            parBits             => parBits,
            real_data_add       => real_data_add)
port map(

     xu_lsu_rf0_act             => xu_lsu_rf0_act,
     xu_lsu_rf1_cmd_act         => xu_lsu_rf1_cmd_act,
     xu_lsu_rf1_axu_op_val      => xu_lsu_rf1_axu_op_val,
     xu_lsu_rf1_axu_ldst_falign => xu_lsu_rf1_axu_ldst_falign,
     xu_lsu_rf1_axu_ldst_fexcpt => xu_lsu_rf1_axu_ldst_fexcpt,
     xu_lsu_rf1_cache_acc       => xu_lsu_rf1_cache_acc,
     xu_lsu_rf1_thrd_id         => xu_lsu_rf1_thrd_id,
     xu_lsu_rf1_optype1         => xu_lsu_rf1_optype1,
     xu_lsu_rf1_optype2         => xu_lsu_rf1_optype2,
     xu_lsu_rf1_optype4         => xu_lsu_rf1_optype4,
     xu_lsu_rf1_optype8         => xu_lsu_rf1_optype8,
     xu_lsu_rf1_optype16        => xu_lsu_rf1_optype16,
     xu_lsu_rf1_optype32        => xu_lsu_rf1_optype32,
     xu_lsu_rf1_target_gpr      => xu_lsu_rf1_target_gpr,
     xu_lsu_rf1_mtspr_trace     => xu_lsu_rf1_mtspr_trace,
     xu_lsu_rf1_load_instr      => xu_lsu_rf1_load_instr,
     xu_lsu_rf1_store_instr     => xu_lsu_rf1_store_instr,
     xu_lsu_rf1_dcbf_instr      => xu_lsu_rf1_dcbf_instr,
     xu_lsu_rf1_sync_instr      => xu_lsu_rf1_sync_instr,
     xu_lsu_rf1_l_fld           => xu_lsu_rf1_l_fld,
     xu_lsu_rf1_dcbi_instr      => xu_lsu_rf1_dcbi_instr,
     xu_lsu_rf1_dcbz_instr      => xu_lsu_rf1_dcbz_instr,
     xu_lsu_rf1_dcbt_instr      => xu_lsu_rf1_dcbt_instr,
     xu_lsu_rf1_dcbtst_instr    => xu_lsu_rf1_dcbtst_instr,
     xu_lsu_rf1_th_fld          => xu_lsu_rf1_th_fld,
     xu_lsu_rf1_dcbtls_instr    => xu_lsu_rf1_dcbtls_instr,
     xu_lsu_rf1_dcbtstls_instr  => xu_lsu_rf1_dcbtstls_instr,
     xu_lsu_rf1_dcblc_instr     => xu_lsu_rf1_dcblc_instr,
     xu_lsu_rf1_dcbst_instr     => xu_lsu_rf1_dcbst_instr,
     xu_lsu_rf1_icbi_instr      => xu_lsu_rf1_icbi_instr,
     xu_lsu_rf1_icblc_instr     => xu_lsu_rf1_icblc_instr,
     xu_lsu_rf1_icbt_instr      => xu_lsu_rf1_icbt_instr,
     xu_lsu_rf1_icbtls_instr    => xu_lsu_rf1_icbtls_instr,
     xu_lsu_rf1_icswx_instr     => xu_lsu_rf1_icswx_instr,
     xu_lsu_rf1_icswx_dot_instr => xu_lsu_rf1_icswx_dot_instr,
     xu_lsu_rf1_icswx_epid      => xu_lsu_rf1_icswx_epid,
     xu_lsu_rf1_tlbsync_instr   => xu_lsu_rf1_tlbsync_instr,
     xu_lsu_rf1_ldawx_instr     => xu_lsu_rf1_ldawx_instr,
     xu_lsu_rf1_wclr_instr      => xu_lsu_rf1_wclr_instr,
     xu_lsu_rf1_wchk_instr      => xu_lsu_rf1_wchk_instr,
     xu_lsu_rf1_lock_instr      => xu_lsu_rf1_lock_instr,
     xu_lsu_rf1_mutex_hint      => xu_lsu_rf1_mutex_hint,
     xu_lsu_rf1_mbar_instr      => xu_lsu_rf1_mbar_instr,
     xu_lsu_rf1_is_msgsnd       => xu_lsu_rf1_is_msgsnd,
     xu_lsu_rf1_dci_instr       => xu_lsu_rf1_dci_instr,
     xu_lsu_rf1_ici_instr       => xu_lsu_rf1_ici_instr,
     xu_lsu_rf1_algebraic       => xu_lsu_rf1_algebraic,
     xu_lsu_rf1_byte_rev        => xu_lsu_rf1_byte_rev,
     xu_lsu_rf1_src_gpr         => xu_lsu_rf1_src_gpr,
     xu_lsu_rf1_src_axu         => xu_lsu_rf1_src_axu,
     xu_lsu_rf1_src_dp          => xu_lsu_rf1_src_dp,
     xu_lsu_rf1_targ_gpr        => xu_lsu_rf1_targ_gpr,
     xu_lsu_rf1_targ_axu        => xu_lsu_rf1_targ_axu,
     xu_lsu_rf1_targ_dp         => xu_lsu_rf1_targ_dp,
     xu_lsu_ex4_val             => xu_lsu_ex4_val,

     xu_lsu_rf1_src0_vld        => xu_lsu_rf1_src0_vld,
     xu_lsu_rf1_src0_reg        => xu_lsu_rf1_src0_reg,
     xu_lsu_rf1_src1_vld        => xu_lsu_rf1_src1_vld,
     xu_lsu_rf1_src1_reg        => xu_lsu_rf1_src1_reg,
     xu_lsu_rf1_targ_vld        => xu_lsu_rf1_targ_vld,
     xu_lsu_rf1_targ_reg        => xu_lsu_rf1_targ_reg,

     ex2_p_addr_lwr             => ex2_p_addr_lwr_int,
     ex3_wimge_w_bit            => ex3_wimge_w_bit,
     ex3_wimge_i_bit            => ex3_wimge_i_bit,
     ex3_wimge_e_bit            => ex3_wimge_e_bit,
     ex2_lm_dep_hit             => ex2_lm_dep_hit,

     ex3_p_addr                 => ex3_p_addr,
     ex3_ld_queue_full          => ex3_ld_queue_full,
     ex3_stq_flush              => ex3_stq_flush,
     ex3_ig_flush               => ex3_ig_flush,
     ex3_hit                    => ex3_l1hit,
     ex4_miss                   => ex4_l1miss,
     ex4_snd_ld_l2              => ex4_snd_ld_l2,
     derat_xu_ex3_noop_touch    => derat_xu_ex3_noop_touch,
     ex3_cClass_collision       => ex3_cClass_collision,
     ex2_lockwatchSet_rel_coll  => ex2_lockwatchSet_rel_coll,
     ex3_wclr_all_flush         => ex3_wclr_all_flush,

     rel_dcarr_val_upd          => rel_dcarr_val_upd,

     xu_lsu_mtspr_trace_en      => xu_lsu_mtspr_trace_en,
     spr_xucr0_clkg_ctl_b1      => spr_xucr0_clkg_ctl_b1,
     xu_lsu_spr_xucr0_aflsta    => xu_lsu_spr_xucr0_aflsta,
     xu_lsu_spr_xucr0_flsta     => xu_lsu_spr_xucr0_flsta,
     xu_lsu_spr_xucr0_l2siw     => xu_lsu_spr_xucr0_l2siw,
     xu_lsu_spr_xucr0_dcdis     => xu_lsu_spr_xucr0_dcdis,
     xu_lsu_spr_xucr0_wlk       => xu_lsu_spr_xucr0_wlk,
     xu_lsu_spr_ccr2_dfrat      => xu_lsu_spr_ccr2_dfrat,
     xu_lsu_spr_xucr0_flh2l2    => xu_lsu_spr_xucr0_flh2l2,
     xu_lsu_spr_xucr0_cls       => xu_lsu_spr_xucr0_cls,
     xu_lsu_spr_msr_cm          => xu_lsu_spr_msr_cm,

     xu_lsu_msr_gs              => xu_lsu_msr_gs,
     xu_lsu_msr_pr              => xu_lsu_msr_pr,

     an_ac_flh2l2_gate          => an_ac_flh2l2_gate,

     xu_lsu_rf1_flush           => xu_lsu_rf1_flush,
     xu_lsu_ex1_flush           => xu_lsu_ex1_flush,
     xu_lsu_ex2_flush           => xu_lsu_ex2_flush,
     xu_lsu_ex3_flush           => xu_lsu_ex3_flush,
     xu_lsu_ex4_flush           => xu_lsu_ex4_flush,
     xu_lsu_ex5_flush           => xu_lsu_ex5_flush,

     xu_lsu_slowspr_val         => xu_lsu_slowspr_val,
     xu_lsu_slowspr_rw          => xu_lsu_slowspr_rw,
     xu_lsu_slowspr_etid        => xu_lsu_slowspr_etid,
     xu_lsu_slowspr_addr        => xu_lsu_slowspr_addr,
     xu_lsu_slowspr_data        => xu_lsu_slowspr_data,
     xu_lsu_slowspr_done        => xu_lsu_slowspr_done,
     slowspr_val_out            => slowspr_val_out,
     slowspr_rw_out             => slowspr_rw_out,
     slowspr_etid_out           => slowspr_etid_out,
     slowspr_addr_out           => slowspr_addr_out,
     slowspr_data_out           => slowspr_data_out,
     slowspr_done_out           => slowspr_done_out,

     ldq_rel_data_val_early     => ldq_rel_data_val_early,
     ldq_rel_stg24_val          => ldq_rel_stg24_val_q,
     ldq_rel_axu_val            => ldq_rel_axu_val,
     ldq_rel_thrd_id            => ldq_rel_thrd_id,
     ldq_rel_ta_gpr             => ldq_rel_ta_gpr,
     ldq_rel_upd_gpr            => ldq_rel_upd_gpr,
     ldq_rel_ci                 => ldq_rel_ci,
     is2_l2_inv_val             => is2_l2_inv_val,

     ex3_wayA_tag               => ex3_wayA_tag,
     ex3_wayB_tag               => ex3_wayB_tag,
     ex3_wayC_tag               => ex3_wayC_tag,
     ex3_wayD_tag               => ex3_wayD_tag,
     ex3_wayE_tag               => ex3_wayE_tag,
     ex3_wayF_tag               => ex3_wayF_tag,
     ex3_wayG_tag               => ex3_wayG_tag,
     ex3_wayH_tag               => ex3_wayH_tag,
     ex3_way_tag_par_a          => ex3_way_tag_par_a,
     ex3_way_tag_par_b          => ex3_way_tag_par_b,
     ex3_way_tag_par_c          => ex3_way_tag_par_c,
     ex3_way_tag_par_d          => ex3_way_tag_par_d,
     ex3_way_tag_par_e          => ex3_way_tag_par_e,
     ex3_way_tag_par_f          => ex3_way_tag_par_f,
     ex3_way_tag_par_g          => ex3_way_tag_par_g,
     ex3_way_tag_par_h          => ex3_way_tag_par_h,
     ex4_way_a_dir              => ex4_way_a_dir,
     ex4_way_b_dir              => ex4_way_b_dir,
     ex4_way_c_dir              => ex4_way_c_dir,
     ex4_way_d_dir              => ex4_way_d_dir,
     ex4_way_e_dir              => ex4_way_e_dir,
     ex4_way_f_dir              => ex4_way_f_dir,
     ex4_way_g_dir              => ex4_way_g_dir,
     ex4_way_h_dir              => ex4_way_h_dir,
     ex4_dir_lru                => ex4_dir_lru,

     ex1_src0_vld               => ex1_src0_vld,
     ex1_src0_reg               => ex1_src0_reg,
     ex1_src1_vld               => ex1_src1_vld,
     ex1_src1_reg               => ex1_src1_reg,
     ex1_targ_vld               => ex1_targ_vld,
     ex1_targ_reg               => ex1_targ_reg,
     ex1_check_watch            => ex1_check_watch,

     ex1_dir_acc_val            => ex1_dir_acc_val,
     ex3_cache_acc              => ex3_cache_acc_int,
     ex1_lsu_64bit_agen         => ex1_lsu_64bit_agen,
     ex1_frc_align2             => ex1_frc_align2,
     ex1_frc_align4             => ex1_frc_align4,
     ex1_frc_align8             => ex1_frc_align8,
     ex1_frc_align16            => ex1_frc_align16,
     ex1_frc_align32            => ex1_frc_align32,
     ex1_optype1                => ex1_optype1,
     ex1_optype2                => ex1_optype2,
     ex1_optype4                => ex1_optype4,
     ex1_optype8                => ex1_optype8,
     ex1_optype16               => ex1_optype16,
     ex1_optype32               => ex1_optype32,
     ex1_saxu_instr             => ex1_saxu_instr,
     ex1_sdp_instr              => ex1_sdp_instr,
     ex1_stgpr_instr            => ex1_stgpr_instr,
     ex1_store_instr            => ex1_store_instr,
     ex1_axu_op_val             => ex1_axu_op_val,
     ex2_no_lru_upd             => ex2_no_lru_upd,
     ex2_is_inval_op            => ex2_is_inval_op,
     ex2_lock_set               => ex2_lock_set,
     ex2_lock_clr               => ex2_lock_clr,
     ex2_ddir_acc_instr         => ex2_ddir_acc_instr,

     ex3_p_addr_lwr             => ex3_p_addr_lwr,
     ex3_req_thrd_id            => ex3_req_thrd_id,
     ex3_target_gpr             => ex3_target_gpr,
     ex3_dcbt_instr             => ex3_dcbt_instr,
     ex3_dcbtst_instr           => ex3_dcbtst_instr,
     ex3_th_fld_l2              => ex3_th_fld_l2,
     ex3_dcbst_instr            => ex3_dcbst_instr,
     ex3_dcbf_instr             => ex3_dcbf_instr,
     ex3_sync_instr             => ex3_sync_instr,
     ex3_mtspr_trace            => ex3_mtspr_trace,
     ex3_byte_en                => ex3_byte_en,
     ex2_l_fld                  => ex2_l_fld,
     ex3_l_fld                  => ex3_l_fld,
     ex3_dcbi_instr             => ex3_dcbi_instr,
     ex3_dcbz_instr             => ex3_dcbz_instr,
     ex3_icbi_instr             => ex3_icbi_instr,
     ex3_icswx_instr            => ex3_icswx_instr,
     ex3_icswx_dot              => ex3_icswx_dot,
     ex3_icswx_epid             => ex3_icswx_epid,
     ex3_mbar_instr             => ex3_mbar_instr,
     ex3_msgsnd_instr           => ex3_msgsnd_instr,
     ex3_dci_instr              => ex3_dci_instr,
     ex3_ici_instr              => ex3_ici_instr,
     ex3_load_instr             => ex3_load_instr,
     ex2_store_instr            => store_instr_ex2,
     ex3_store_instr            => ex3_store_instr,
     ex3_axu_op_val             => ex3_axu_op_val,
     ex3_algebraic              => ex3_algebraic,
     ex3_dcbtls_instr           => dcbtls_instr_ex3,
     ex3_dcbtstls_instr         => dcbtstls_instr_ex3,
     ex3_dcblc_instr            => ex3_dcblc_instr,
     ex3_icblc_instr            => ex3_icblc_instr,
     ex3_icbt_instr             => ex3_icbt_instr,
     ex3_icbtls_instr           => ex3_icbtls_instr,
     ex3_tlbsync_instr          => ex3_tlbsync_instr,
     ex3_local_dcbf             => ex3_local_dcbf,
     ex4_drop_rel               => ex4_drop_rel,
     ex3_load_l1hit             => ex3_load_l1hit,
     ex3_rotate_sel             => ex3_rotate_sel,
     ex1_thrd_id                => ex1_thrd_id,
     ex2_ldawx_instr            => ex2_ldawx_instr,
     ex2_wclr_instr             => ex2_wclr_instr,
     ex2_wchk_val               => ex2_wchk_val,
     ex3_watch_en               => ex3_watch_en,
     ex3_data_swap              => ex3_data_swap,
     ex3_load_val               => ex3_load_val,
     ex3_blkable_touch          => ex3_blkable_touch,
     ex3_l2_request             => ex3_l2_request,
     ex3_ldq_potential_flush    => ex3_ldq_potential_flush,
     ex7_targ_match             => ex7_targ_match,
     ex8_targ_match             => ex8_targ_match,
     ex4_ld_entry               => ex4_ld_entry,

     ex3_lock_en                => ex3_lock_en,
     ex3_cache_en               => ex3_cache_en,
     ex3_cache_inh              => ex3_cache_inh,
     ex3_l_s_q_val              => ex3_l_s_q_val,
     ex3_drop_ld_req            => ex3_drop_ld_req,
     ex3_drop_touch             => ex3_drop_touch,
     ex3_stx_instr              => ex3_stx_instr,
     ex3_larx_instr             => ex3_larx_instr,
     ex3_mutex_hint             => ex3_mutex_hint,
     ex3_opsize                 => ex3_opsize,
     ex4_store_hit              => ex4_store_hit,

     spr_xucr2_rmt              => spr_xucr2_rmt,
     spr_xucr0_wlck             => spr_xucr0_wlck,
     ex4_load_op_hit            => ex4_load_op_hit,
     ex5_load_op_hit            => ex5_load_op_hit,
     ex4_axu_op_val             => ex4_axu_op_val,
     spr_dvc1_act               => spr_dvc1_act,
     spr_dvc2_act               => spr_dvc2_act,
     spr_dvc1_dbg               => spr_dvc1_dbg,
     spr_dvc2_dbg               => spr_dvc2_dbg,

     lsu_xu_spr_xucr0_cul       => lsu_xu_spr_xucr0_cul,
     spr_xucr0_cls              => spr_xucr0_cls_int,
     agen_xucr0_cls             => agen_xucr0_cls,

     dir_arr_rd_is2_val         => dir_arr_rd_is2_val,
     dir_arr_rd_congr_cl        => dir_arr_rd_congr_cl,

     lsu_xu_ex3_align           => lsu_xu_ex3_align,
     lsu_xu_ex3_dsi             => lsu_xu_ex3_dsi,
     lsu_xu_ex3_inval_align_2ucode => lsu_xu_ex3_inval_align_2ucode,

     ex2_stg_flush              => stg_ex2_flush,
     ex3_stg_flush              => stg_ex3_flush,
     ex4_stg_flush              => stg_ex4_flush,
     ex5_stg_flush              => stg_ex5_flush,
     lsu_xu_ex3_n_flush_req     => lsu_xu_ex3_n_flush_req,
     lsu_xu_ex3_dep_flush       => lsu_xu_ex3_dep_flush,

     rf1_l2_inv_val             => rf1_l2_inv_val,
     ex1_agen_binv_val          => ex1_agen_binv_val,
     ex1_l2_inv_val             => ex1_l2_inv_val,

     rel_upd_dcarr_val          => rel_upd_dcarr_val,

     lsu_xu_ex4_cr_upd          => lsu_xu_ex4_cr_upd,
     lsu_xu_ex5_wren            => lsu_xu_ex5_wren,
     lsu_xu_rel_wren            => lsu_xu_rel_wren,
     lsu_xu_rel_ta_gpr          => lsu_xu_rel_ta_gpr,
     lsu_xu_perf_events         => lsu_xu_perf_events(0 to 20),
     lsu_xu_need_hole           => lsu_xu_need_hole,

     xu_fu_ex5_reload_val       => xu_fu_ex5_reload_val,
     xu_fu_ex5_load_val         => xu_fu_ex5_load_val,
     xu_fu_ex5_load_tag         => xu_fu_ex5_load_tag,

     xu_iu_ex6_icbi_val         => xu_iu_ex6_icbi_val,
     xu_iu_ex6_icbi_addr        => xu_iu_ex6_icbi_addr,

     xu_derat_epsc_wr           => xu_derat_epsc_wr,
     xu_derat_eplc_wr           => xu_derat_eplc_wr,
     xu_derat_eplc0_epr         => xu_derat_eplc0_epr,
     xu_derat_eplc0_eas         => xu_derat_eplc0_eas,
     xu_derat_eplc0_egs         => xu_derat_eplc0_egs,
     xu_derat_eplc0_elpid       => xu_derat_eplc0_elpid,
     xu_derat_eplc0_epid        => xu_derat_eplc0_epid,
     xu_derat_eplc1_epr         => xu_derat_eplc1_epr,
     xu_derat_eplc1_eas         => xu_derat_eplc1_eas,
     xu_derat_eplc1_egs         => xu_derat_eplc1_egs,
     xu_derat_eplc1_elpid       => xu_derat_eplc1_elpid,
     xu_derat_eplc1_epid        => xu_derat_eplc1_epid,
     xu_derat_eplc2_epr         => xu_derat_eplc2_epr,
     xu_derat_eplc2_eas         => xu_derat_eplc2_eas,
     xu_derat_eplc2_egs         => xu_derat_eplc2_egs,
     xu_derat_eplc2_elpid       => xu_derat_eplc2_elpid,
     xu_derat_eplc2_epid        => xu_derat_eplc2_epid,
     xu_derat_eplc3_epr         => xu_derat_eplc3_epr,
     xu_derat_eplc3_eas         => xu_derat_eplc3_eas,
     xu_derat_eplc3_egs         => xu_derat_eplc3_egs,
     xu_derat_eplc3_elpid       => xu_derat_eplc3_elpid,
     xu_derat_eplc3_epid        => xu_derat_eplc3_epid,
     xu_derat_epsc0_epr         => xu_derat_epsc0_epr,
     xu_derat_epsc0_eas         => xu_derat_epsc0_eas,
     xu_derat_epsc0_egs         => xu_derat_epsc0_egs,
     xu_derat_epsc0_elpid       => xu_derat_epsc0_elpid,
     xu_derat_epsc0_epid        => xu_derat_epsc0_epid,
     xu_derat_epsc1_epr         => xu_derat_epsc1_epr,
     xu_derat_epsc1_eas         => xu_derat_epsc1_eas,
     xu_derat_epsc1_egs         => xu_derat_epsc1_egs,
     xu_derat_epsc1_elpid       => xu_derat_epsc1_elpid,
     xu_derat_epsc1_epid        => xu_derat_epsc1_epid,
     xu_derat_epsc2_epr         => xu_derat_epsc2_epr,
     xu_derat_epsc2_eas         => xu_derat_epsc2_eas,
     xu_derat_epsc2_egs         => xu_derat_epsc2_egs,
     xu_derat_epsc2_elpid       => xu_derat_epsc2_elpid,
     xu_derat_epsc2_epid        => xu_derat_epsc2_epid,
     xu_derat_epsc3_epr         => xu_derat_epsc3_epr,
     xu_derat_epsc3_eas         => xu_derat_epsc3_eas,
     xu_derat_epsc3_egs         => xu_derat_epsc3_egs,
     xu_derat_epsc3_elpid       => xu_derat_epsc3_elpid,
     xu_derat_epsc3_epid        => xu_derat_epsc3_epid,

     dc_fgen_dbg_data           => dc_fgen_dbg_data,
     dc_cntrl_dbg_data          => dc_cntrl_dbg_data,

     ex1_stg_act                => ex1_stg_act_int,
     ex2_stg_act                => ex2_stg_act_int,
     ex3_stg_act                => ex3_stg_act_int,
     ex4_stg_act                => ex4_stg_act_int,
     ex5_stg_act                => ex5_stg_act_int,
     binv1_stg_act              => binv1_stg_act_int,
     binv2_stg_act              => binv2_stg_act_int,
     binv3_stg_act              => binv3_stg_act_int,
     binv4_stg_act              => binv4_stg_act_int,
     binv5_stg_act              => binv5_stg_act_int,
     rel1_stg_act               => rel1_stg_act_int,
     rel2_stg_act               => rel2_stg_act_int,
     rel3_stg_act               => rel3_stg_act_int,

     vdd                        => vdd,
     gnd                        => gnd,
     nclk                       => nclk,
     sg_0                       => sg_0,
     func_sl_thold_0_b          => func_sl_thold_0_b,
     func_sl_force => func_sl_force,
     func_slp_sl_thold_0_b      => func_slp_sl_thold_0_b,
     func_slp_sl_force => func_slp_sl_force,
     func_nsl_thold_0_b         => func_nsl_thold_0_b,
     func_nsl_force => func_nsl_force,
     func_slp_nsl_thold_0_b     => func_slp_nsl_thold_0_b,
     func_slp_nsl_force => func_slp_nsl_force,
     d_mode_dc                  => d_mode_dc,
     delay_lclkr_dc             => delay_lclkr_dc,
     mpw1_dc_b                  => mpw1_dc_b,
     mpw2_dc_b                  => mpw2_dc_b,
     scan_in                    => scan_in(0),
     scan_out                   => scan_out(0)
);
dir16k : if (2**dc_size) = 16384 generate begin

l1dcdv: entity work.xuq_lsu_dir_val16(xuq_lsu_dir_val16)
GENERIC MAP(expand_type         => expand_type,
            dc_size             => dc_size,
            cl_size             => cl_size)         
PORT MAP (

     ex1_stg_act                => ex1_stg_act_int,
     ex2_stg_act                => ex2_stg_act_int,
     ex3_stg_act                => ex3_stg_act_int,
     ex4_stg_act                => ex4_stg_act_int,
     ex5_stg_act                => ex5_stg_act_int,
     binv1_stg_act              => binv1_stg_act_int,
     binv2_stg_act              => binv2_stg_act_int,
     binv3_stg_act              => binv3_stg_act_int,
     binv4_stg_act              => binv4_stg_act_int,
     binv5_stg_act              => binv5_stg_act_int,
     rel1_stg_act               => rel1_stg_act_int,
     rel2_stg_act               => rel2_stg_act_int,

     ldq_rel1_early_v           => ldq_rel1_early_v,
     rel1_val                   => rel1_val,
     rel_addr_early             => ldq_rel_addr_early(64-(dc_size-3) to 63-cl_size),
     rel_lock_en                => rel_lock_en,
     rel_l1dump_cslc            => rel_l1dump_cslc,
     rel3_l1dump_val            => rel3_l1dump_val,
     rel_watch_en               => rel_watch_en,
     rel_thrd_id                => rel_thrd_id,
     rel_way_clr_a              => rel_way_clr_a,
     rel_way_clr_b              => rel_way_clr_b,
     rel_way_clr_c              => rel_way_clr_c,
     rel_way_clr_d              => rel_way_clr_d,
     rel_way_clr_e              => rel_way_clr_e,
     rel_way_clr_f              => rel_way_clr_f,
     rel_way_clr_g              => rel_way_clr_g,
     rel_way_clr_h              => rel_way_clr_h,

     ldq_rel3_early_v           => ldq_rel3_early_v,
     rel3_val                   => rel3_val,
     rel_back_inval             => ldq_rel_back_invalidated,
     rel4_set_val               => rel4_set_val,
     rel4_recirc_val            => recirc_rel_val_q,
     rel4_ecc_err               => ldq_rel_ecc_err,
     rel_way_wen_a              => rel_wayA_wen,
     rel_way_wen_b              => rel_wayB_wen,
     rel_way_wen_c              => rel_wayC_wen,
     rel_way_wen_d              => rel_wayD_wen,
     rel_way_wen_e              => rel_wayE_wen,
     rel_way_wen_f              => rel_wayF_wen,
     rel_way_wen_g              => rel_wayG_wen,
     rel_way_wen_h              => rel_wayH_wen,
     rel_up_way_addr_b          => rel_up_way_addr_b,
     rel_dcarr_addr_en          => rel_dcarr_addr_en,

     xu_lsu_dci                 => xu_lsu_dci,
     xu_lsu_spr_xucr0_clfc      => xu_lsu_spr_xucr0_clfc,
     spr_xucr0_dcdis            => spr_xucr0_dcdis_q,
     spr_xucr0_cls              => spr_xucr0_cls_int,

     ex1_thrd_id                => ex1_thrd_id,
     ex1_p_addr                 => ex1_p_addr,
     ex2_is_inval_op            => ex2_is_inval_op,
     ex2_lock_set               => ex2_lock_set,
     ex2_lock_clr               => ex2_lock_clr,
     ex3_cache_en               => ex3_cache_en,
     ex3_cache_acc              => ex3_cache_acc_int,
     ex3_tag_way_perr           => ex3_tag_way_perr,
     ex5_load_op_hit            => ex5_load_op_hit,
     ex6_ld_par_err             => ex6_ld_par_err,
     ex2_ldawx_instr            => ex2_ldawx_instr,
     ex2_wclr_instr             => ex2_wclr_instr,
     ex2_wchk_val               => ex2_wchk_val,
     ex2_l_fld                  => ex2_l_fld,
     ex2_store_instr            => store_instr_ex2,
     ex3_load_val               => ex3_load_val,
     ex3_wimge_i_bit            => ex3_wimge_i_bit,
     ex3_l2_request             => ex3_l2_request,
     ex3_ldq_potential_flush    => ex3_ldq_potential_flush,

     inv1_val                   => ex1_l2_inv_val,

     ex3_way_cmp_a              => ex3_way_cmp_a,
     ex3_way_cmp_b              => ex3_way_cmp_b,
     ex3_way_cmp_c              => ex3_way_cmp_c,
     ex3_way_cmp_d              => ex3_way_cmp_d,
     ex3_way_cmp_e              => ex3_way_cmp_e,
     ex3_way_cmp_f              => ex3_way_cmp_f,
     ex3_way_cmp_g              => ex3_way_cmp_g,
     ex3_way_cmp_h              => ex3_way_cmp_h,

     ex2_stg_flush              => stg_ex2_flush,
     ex3_stg_flush              => stg_ex3_flush,
     ex4_stg_flush              => stg_ex4_flush,
     ex5_stg_flush              => stg_ex5_flush,

     pc_xu_inj_dcachedir_multihit => pc_xu_inj_dcachedir_multihit,

     ex4_way_a_dir              => ex4_way_a_dir,
     ex4_way_b_dir              => ex4_way_b_dir,
     ex4_way_c_dir              => ex4_way_c_dir,
     ex4_way_d_dir              => ex4_way_d_dir,
     ex4_way_e_dir              => ex4_way_e_dir,
     ex4_way_f_dir              => ex4_way_f_dir,
     ex4_way_g_dir              => ex4_way_g_dir,
     ex4_way_h_dir              => ex4_way_h_dir,

     ex4_way_a_hit              => ex4_way_a_hit,
     ex4_way_b_hit              => ex4_way_b_hit,
     ex4_way_c_hit              => ex4_way_c_hit,
     ex4_way_d_hit              => ex4_way_d_hit,
     ex4_way_e_hit              => ex4_way_e_hit,
     ex4_way_f_hit              => ex4_way_f_hit,
     ex4_way_g_hit              => ex4_way_g_hit,
     ex4_way_h_hit              => ex4_way_h_hit,

     ex2_lockwatchSet_rel_coll  => ex2_lockwatchSet_rel_coll,
     ex3_wclr_all_flush         => ex3_wclr_all_flush,

     ex3_cClass_upd_way_a       => ex3_cClass_upd_way_a,
     ex3_cClass_upd_way_b       => ex3_cClass_upd_way_b,
     ex3_cClass_upd_way_c       => ex3_cClass_upd_way_c,
     ex3_cClass_upd_way_d       => ex3_cClass_upd_way_d,
     ex3_cClass_upd_way_e       => ex3_cClass_upd_way_e,
     ex3_cClass_upd_way_f       => ex3_cClass_upd_way_f,
     ex3_cClass_upd_way_g       => ex3_cClass_upd_way_g,
     ex3_cClass_upd_way_h       => ex3_cClass_upd_way_h,

     ex3_hit                    => ex3_l1hit,
     ex3_dir_perr_det           => ex3_dir_perr_det,
     ex4_dir_multihit_det       => ex4_dir_multihit_det,
     ex4_n_lsu_ddmh_flush       => ex4_n_lsu_ddmh_flush,
     ex4_ldq_full_flush         => ex4_ldq_full_flush,
     ex4_miss                   => ex4_l1miss,
     ex4_snd_ld_l2              => ex4_snd_ld_l2,
     dcpar_err_flush            => dcpar_err_flush,
     pe_recov_begin             => pe_recov_begin,

     lsu_xu_ex5_cr_rslt         => lsu_xu_ex5_cr_rslt,

     rel_way_val_a              => rel_way_val_a,
     rel_way_val_b              => rel_way_val_b,
     rel_way_val_c              => rel_way_val_c,
     rel_way_val_d              => rel_way_val_d,
     rel_way_val_e              => rel_way_val_e,
     rel_way_val_f              => rel_way_val_f,
     rel_way_val_g              => rel_way_val_g,
     rel_way_val_h              => rel_way_val_h,

     rel_way_lock_a             => rel_way_lock_a,
     rel_way_lock_b             => rel_way_lock_b,
     rel_way_lock_c             => rel_way_lock_c,
     rel_way_lock_d             => rel_way_lock_d,
     rel_way_lock_e             => rel_way_lock_e,
     rel_way_lock_f             => rel_way_lock_f,
     rel_way_lock_g             => rel_way_lock_g,
     rel_way_lock_h             => rel_way_lock_h,

     dcarr_up_way_addr          => dcarr_up_way_addr,

     lsu_xu_perf_events         => lsu_xu_perf_events(21 to 37),

     lsu_xu_spr_xucr0_cslc_xuop => lsu_xu_spr_xucr0_cslc_xuop,
     lsu_xu_spr_xucr0_cslc_binv => lsu_xu_spr_xucr0_cslc_binv,

     dc_val_dbg_data            => dc_val_dbg_data,

     vdd                        => vdd,
     gnd                        => gnd,
     nclk                       => nclk,
     sg_0                       => sg_0,
     func_sl_thold_0_b          => func_sl_thold_0_b,
     func_sl_force => func_sl_force,
     func_slp_sl_thold_0_b      => func_slp_sl_thold_0_b,
     func_slp_sl_force => func_slp_sl_force,
     func_nsl_thold_0_b         => func_nsl_thold_0_b,
     func_nsl_force => func_nsl_force,
     func_slp_nsl_thold_0_b     => func_slp_nsl_thold_0_b,
     func_slp_nsl_force => func_slp_nsl_force,
     d_mode_dc                  => d_mode_dc,
     delay_lclkr_dc             => delay_lclkr_dc,
     mpw1_dc_b                  => mpw1_dc_b,
     mpw2_dc_b                  => mpw2_dc_b,
     scan_in                    => scan_in(1 to 3),
     scan_out(0 to 1)           => scan_out(1 to 2),
     scan_out(2)                => dir_scan_out
);

ex4_dir_perr_det_d <= ex3_dir_perr_det;

l1dcdl : entity work.xuq_lsu_dir_lru16(xuq_lsu_dir_lru16)
GENERIC MAP(expand_type         => expand_type,
            dc_size             => dc_size,
            lmq_entries         => lmq_entries,
            cl_size             => cl_size)         
PORT MAP(

     ex1_stg_act                => ex1_stg_act_int,
     ex2_stg_act                => ex2_stg_act_int,
     ex3_stg_act                => ex3_stg_act_int,
     ex4_stg_act                => ex4_stg_act_int,
     ex5_stg_act                => ex5_stg_act_int,
     rel1_stg_act               => rel1_stg_act_int,
     rel2_stg_act               => rel2_stg_act_int,
     rel3_stg_act               => rel3_stg_act_int,

     rel1_val                   => rel1_val,
     rel1_classid               => rel1_classid,
     rel_mid_val                => rel_mid_val,
     rel_retry_val              => ldq_rel_retry_val,
     rel3_val                   => rel3_val,
     rel_st_tag                 => rel_st_tag,
     rel_st_tag_early           => rel_st_tag_early,
     rel_addr_early             => ldq_rel_addr_early(64-(dc_size-3) to 63-cl_size),
     rel_lock_en                => rel_lock_en,
     rel4_recirc_val            => recirc_rel_val_q,
     rel4_ecc_err               => ldq_rel_ecc_err,

     rel_way_val_a              => rel_way_val_a,
     rel_way_val_b              => rel_way_val_b,
     rel_way_val_c              => rel_way_val_c,
     rel_way_val_d              => rel_way_val_d,
     rel_way_val_e              => rel_way_val_e,
     rel_way_val_f              => rel_way_val_f,
     rel_way_val_g              => rel_way_val_g,
     rel_way_val_h              => rel_way_val_h,

     rel_way_lock_a             => rel_way_lock_a,
     rel_way_lock_b             => rel_way_lock_b,
     rel_way_lock_c             => rel_way_lock_c,
     rel_way_lock_d             => rel_way_lock_d,
     rel_way_lock_e             => rel_way_lock_e,
     rel_way_lock_f             => rel_way_lock_f,
     rel_way_lock_g             => rel_way_lock_g,
     rel_way_lock_h             => rel_way_lock_h,

     ex1_p_addr                 => ex1_p_addr,
     ex2_no_lru_upd             => ex2_no_lru_upd,
     ex3_cache_en               => ex3_cache_en,

     ex4_way_a_hit              => ex4_way_a_hit,
     ex4_way_b_hit              => ex4_way_b_hit,
     ex4_way_c_hit              => ex4_way_c_hit,
     ex4_way_d_hit              => ex4_way_d_hit,
     ex4_way_e_hit              => ex4_way_e_hit,
     ex4_way_f_hit              => ex4_way_f_hit,
     ex4_way_g_hit              => ex4_way_g_hit,
     ex4_way_h_hit              => ex4_way_h_hit,
     ex3_hit                    => ex3_l1hit,

     ex3_stg_flush              => stg_ex3_flush,
     ex4_stg_flush              => stg_ex4_flush,
     ex5_stg_flush              => stg_ex5_flush,

     spr_xucr2_rmt              => spr_xucr2_rmt,
     spr_xucr0_wlck             => spr_xucr0_wlck,
     spr_xucr0_dcdis            => spr_xucr0_dcdis_q,
     spr_xucr0_cls              => spr_xucr0_cls_int,

     rel_way_upd_a              => rel_way_upd_a,
     rel_way_upd_b              => rel_way_upd_b,
     rel_way_upd_c              => rel_way_upd_c,
     rel_way_upd_d              => rel_way_upd_d,
     rel_way_upd_e              => rel_way_upd_e,
     rel_way_upd_f              => rel_way_upd_f,
     rel_way_upd_g              => rel_way_upd_g,
     rel_way_upd_h              => rel_way_upd_h,

     rel_way_wen_a              => rel_wayA_wen,
     rel_way_wen_b              => rel_wayB_wen,
     rel_way_wen_c              => rel_wayC_wen,
     rel_way_wen_d              => rel_wayD_wen,
     rel_way_wen_e              => rel_wayE_wen,
     rel_way_wen_f              => rel_wayF_wen,
     rel_way_wen_g              => rel_wayG_wen,
     rel_way_wen_h              => rel_wayH_wen,

     rel_way_clr_a              => rel_way_clr_a,
     rel_way_clr_b              => rel_way_clr_b,
     rel_way_clr_c              => rel_way_clr_c,
     rel_way_clr_d              => rel_way_clr_d,
     rel_way_clr_e              => rel_way_clr_e,
     rel_way_clr_f              => rel_way_clr_f,
     rel_way_clr_g              => rel_way_clr_g,
     rel_way_clr_h              => rel_way_clr_h,
     rel_dcarr_val_upd          => rel_dcarr_val_upd,
     rel_up_way_addr_b          => rel_up_way_addr_b,
     rel_dcarr_addr_en          => rel_dcarr_addr_en,

     lsu_xu_spr_xucr0_clo       => lsu_xu_spr_xucr0_clo,
     ex4_dir_lru                => ex4_dir_lru,
     dc_lru_dbg_data            => dc_lru_dbg_data,

     vdd                        => vdd,
     gnd                        => gnd,
     nclk                       => nclk,
     sg_0                       => sg_0,
     func_sl_thold_0_b          => func_sl_thold_0_b,
     func_sl_force => func_sl_force,
     func_nsl_thold_0_b         => func_nsl_thold_0_b,
     func_nsl_force => func_nsl_force,
     d_mode_dc                  => d_mode_dc,
     delay_lclkr_dc             => delay_lclkr_dc,
     mpw1_dc_b                  => mpw1_dc_b,
     mpw2_dc_b                  => mpw2_dc_b,
     scan_in                    => dir_scan_out,
     scan_out                   => lru_scan_out
   );
end generate dir16k;

dir32k : if (2**dc_size) = 32768 generate begin

l1dcdv: entity work.xuq_lsu_dir_val32(xuq_lsu_dir_val32)
GENERIC MAP(expand_type         => expand_type,
            dc_size             => dc_size,
            cl_size             => cl_size)         
PORT MAP (

     ex1_stg_act                => ex1_stg_act_int,
     ex2_stg_act                => ex2_stg_act_int,
     ex3_stg_act                => ex3_stg_act_int,
     ex4_stg_act                => ex4_stg_act_int,
     ex5_stg_act                => ex5_stg_act_int,
     binv1_stg_act              => binv1_stg_act_int,
     binv2_stg_act              => binv2_stg_act_int,
     binv3_stg_act              => binv3_stg_act_int,
     binv4_stg_act              => binv4_stg_act_int,
     binv5_stg_act              => binv5_stg_act_int,
     rel1_stg_act               => rel1_stg_act_int,
     rel2_stg_act               => rel2_stg_act_int,

     ldq_rel1_early_v           => ldq_rel1_early_v,
     rel1_val                   => rel1_val,
     rel_addr_early             => ldq_rel_addr_early(64-(dc_size-3) to 63-cl_size),
     rel_lock_en                => rel_lock_en,
     rel_l1dump_cslc            => rel_l1dump_cslc,
     rel3_l1dump_val            => rel3_l1dump_val,
     rel_watch_en               => rel_watch_en,
     rel_thrd_id                => rel_thrd_id,
     rel_way_clr_a              => rel_way_clr_a,
     rel_way_clr_b              => rel_way_clr_b,
     rel_way_clr_c              => rel_way_clr_c,
     rel_way_clr_d              => rel_way_clr_d,
     rel_way_clr_e              => rel_way_clr_e,
     rel_way_clr_f              => rel_way_clr_f,
     rel_way_clr_g              => rel_way_clr_g,
     rel_way_clr_h              => rel_way_clr_h,

     ldq_rel3_early_v           => ldq_rel3_early_v,
     rel3_val                   => rel3_val,
     rel_back_inval             => ldq_rel_back_invalidated,
     rel4_set_val               => rel4_set_val,
     rel4_recirc_val            => recirc_rel_val_q,
     rel4_ecc_err               => ldq_rel_ecc_err,
     rel_way_wen_a              => rel_wayA_wen,
     rel_way_wen_b              => rel_wayB_wen,
     rel_way_wen_c              => rel_wayC_wen,
     rel_way_wen_d              => rel_wayD_wen,
     rel_way_wen_e              => rel_wayE_wen,
     rel_way_wen_f              => rel_wayF_wen,
     rel_way_wen_g              => rel_wayG_wen,
     rel_way_wen_h              => rel_wayH_wen,
     rel_up_way_addr_b          => rel_up_way_addr_b,
     rel_dcarr_addr_en          => rel_dcarr_addr_en,

     xu_lsu_dci                 => xu_lsu_dci,
     xu_lsu_spr_xucr0_clfc      => xu_lsu_spr_xucr0_clfc,
     spr_xucr0_dcdis            => spr_xucr0_dcdis_q,
     spr_xucr0_cls              => spr_xucr0_cls_int,

     ex1_thrd_id                => ex1_thrd_id,
     ex1_p_addr                 => ex1_p_addr,
     ex2_is_inval_op            => ex2_is_inval_op,
     ex2_lock_set               => ex2_lock_set,
     ex2_lock_clr               => ex2_lock_clr,
     ex3_cache_en               => ex3_cache_en,
     ex3_cache_acc              => ex3_cache_acc_int,
     ex3_tag_way_perr           => ex3_tag_way_perr,
     ex5_load_op_hit            => ex5_load_op_hit,
     ex6_ld_par_err             => ex6_ld_par_err,
     ex2_ldawx_instr            => ex2_ldawx_instr,
     ex2_wclr_instr             => ex2_wclr_instr,
     ex2_wchk_val               => ex2_wchk_val,
     ex2_l_fld                  => ex2_l_fld,
     ex2_store_instr            => store_instr_ex2,
     ex3_load_val               => ex3_load_val,
     ex3_wimge_i_bit            => ex3_wimge_i_bit,
     ex3_l2_request             => ex3_l2_request,
     ex3_ldq_potential_flush    => ex3_ldq_potential_flush,

     inv1_val                   => ex1_l2_inv_val,

     ex3_way_cmp_a              => ex3_way_cmp_a,
     ex3_way_cmp_b              => ex3_way_cmp_b,
     ex3_way_cmp_c              => ex3_way_cmp_c,
     ex3_way_cmp_d              => ex3_way_cmp_d,
     ex3_way_cmp_e              => ex3_way_cmp_e,
     ex3_way_cmp_f              => ex3_way_cmp_f,
     ex3_way_cmp_g              => ex3_way_cmp_g,
     ex3_way_cmp_h              => ex3_way_cmp_h,

     ex2_stg_flush              => stg_ex2_flush,
     ex3_stg_flush              => stg_ex3_flush,
     ex4_stg_flush              => stg_ex4_flush,
     ex5_stg_flush              => stg_ex5_flush,

     pc_xu_inj_dcachedir_multihit => pc_xu_inj_dcachedir_multihit,

     ex4_way_a_dir              => ex4_way_a_dir,
     ex4_way_b_dir              => ex4_way_b_dir,
     ex4_way_c_dir              => ex4_way_c_dir,
     ex4_way_d_dir              => ex4_way_d_dir,
     ex4_way_e_dir              => ex4_way_e_dir,
     ex4_way_f_dir              => ex4_way_f_dir,
     ex4_way_g_dir              => ex4_way_g_dir,
     ex4_way_h_dir              => ex4_way_h_dir,

     ex4_way_a_hit              => ex4_way_a_hit,
     ex4_way_b_hit              => ex4_way_b_hit,
     ex4_way_c_hit              => ex4_way_c_hit,
     ex4_way_d_hit              => ex4_way_d_hit,
     ex4_way_e_hit              => ex4_way_e_hit,
     ex4_way_f_hit              => ex4_way_f_hit,
     ex4_way_g_hit              => ex4_way_g_hit,
     ex4_way_h_hit              => ex4_way_h_hit,

     ex2_lockwatchSet_rel_coll  => ex2_lockwatchSet_rel_coll,
     ex3_wclr_all_flush         => ex3_wclr_all_flush,

     ex3_cClass_upd_way_a       => ex3_cClass_upd_way_a,
     ex3_cClass_upd_way_b       => ex3_cClass_upd_way_b,
     ex3_cClass_upd_way_c       => ex3_cClass_upd_way_c,
     ex3_cClass_upd_way_d       => ex3_cClass_upd_way_d,
     ex3_cClass_upd_way_e       => ex3_cClass_upd_way_e,
     ex3_cClass_upd_way_f       => ex3_cClass_upd_way_f,
     ex3_cClass_upd_way_g       => ex3_cClass_upd_way_g,
     ex3_cClass_upd_way_h       => ex3_cClass_upd_way_h,

     ex3_hit                    => ex3_l1hit,
     ex3_dir_perr_det           => ex3_dir_perr_det,
     ex4_dir_multihit_det       => ex4_dir_multihit_det,
     ex4_n_lsu_ddmh_flush       => ex4_n_lsu_ddmh_flush,
     ex4_ldq_full_flush         => ex4_ldq_full_flush,
     ex4_miss                   => ex4_l1miss,
     ex4_snd_ld_l2              => ex4_snd_ld_l2,
     dcpar_err_flush            => dcpar_err_flush,
     pe_recov_begin             => pe_recov_begin,

     lsu_xu_ex5_cr_rslt         => lsu_xu_ex5_cr_rslt,

     rel_way_val_a              => rel_way_val_a,
     rel_way_val_b              => rel_way_val_b,
     rel_way_val_c              => rel_way_val_c,
     rel_way_val_d              => rel_way_val_d,
     rel_way_val_e              => rel_way_val_e,
     rel_way_val_f              => rel_way_val_f,
     rel_way_val_g              => rel_way_val_g,
     rel_way_val_h              => rel_way_val_h,

     rel_way_lock_a             => rel_way_lock_a,
     rel_way_lock_b             => rel_way_lock_b,
     rel_way_lock_c             => rel_way_lock_c,
     rel_way_lock_d             => rel_way_lock_d,
     rel_way_lock_e             => rel_way_lock_e,
     rel_way_lock_f             => rel_way_lock_f,
     rel_way_lock_g             => rel_way_lock_g,
     rel_way_lock_h             => rel_way_lock_h,

     dcarr_up_way_addr          => dcarr_up_way_addr,

     lsu_xu_perf_events         => lsu_xu_perf_events(21 to 37),

     lsu_xu_spr_xucr0_cslc_xuop => lsu_xu_spr_xucr0_cslc_xuop,
     lsu_xu_spr_xucr0_cslc_binv => lsu_xu_spr_xucr0_cslc_binv,

     dc_val_dbg_data            => dc_val_dbg_data,

     vdd                        => vdd,
     gnd                        => gnd,
     nclk                       => nclk,
     sg_0                       => sg_0,
     func_sl_thold_0_b          => func_sl_thold_0_b,
     func_sl_force => func_sl_force,
     func_slp_sl_thold_0_b      => func_slp_sl_thold_0_b,
     func_slp_sl_force => func_slp_sl_force,
     func_nsl_thold_0_b         => func_nsl_thold_0_b,
     func_nsl_force => func_nsl_force,
     func_slp_nsl_thold_0_b     => func_slp_nsl_thold_0_b,
     func_slp_nsl_force => func_slp_nsl_force,
     d_mode_dc                  => d_mode_dc,
     delay_lclkr_dc             => delay_lclkr_dc,
     mpw1_dc_b                  => mpw1_dc_b,
     mpw2_dc_b                  => mpw2_dc_b,
     scan_in                    => scan_in(1 to 3),
     scan_out(0 to 1)           => scan_out(1 to 2),
     scan_out(2)                => dir_scan_out
);

ex4_dir_perr_det_d <= ex3_dir_perr_det;

l1dcdl : entity work.xuq_lsu_dir_lru32(xuq_lsu_dir_lru32)
GENERIC MAP(expand_type         => expand_type,
            dc_size             => dc_size,
            lmq_entries         => lmq_entries,
            cl_size             => cl_size)         
PORT MAP(

     ex1_stg_act                => ex1_stg_act_int,
     ex2_stg_act                => ex2_stg_act_int,
     ex3_stg_act                => ex3_stg_act_int,
     ex4_stg_act                => ex4_stg_act_int,
     ex5_stg_act                => ex5_stg_act_int,
     rel1_stg_act               => rel1_stg_act_int,
     rel2_stg_act               => rel2_stg_act_int,
     rel3_stg_act               => rel3_stg_act_int,

     rel1_val                   => rel1_val,
     rel1_classid               => rel1_classid,
     rel_mid_val                => rel_mid_val,
     rel_retry_val              => ldq_rel_retry_val,
     rel3_val                   => rel3_val,
     rel_st_tag                 => rel_st_tag,
     rel_st_tag_early           => rel_st_tag_early,
     rel_addr_early             => ldq_rel_addr_early(64-(dc_size-3) to 63-cl_size),
     rel_lock_en                => rel_lock_en,
     rel4_recirc_val            => recirc_rel_val_q,
     rel4_ecc_err               => ldq_rel_ecc_err,

     rel_way_val_a              => rel_way_val_a,
     rel_way_val_b              => rel_way_val_b,
     rel_way_val_c              => rel_way_val_c,
     rel_way_val_d              => rel_way_val_d,
     rel_way_val_e              => rel_way_val_e,
     rel_way_val_f              => rel_way_val_f,
     rel_way_val_g              => rel_way_val_g,
     rel_way_val_h              => rel_way_val_h,

     rel_way_lock_a             => rel_way_lock_a,
     rel_way_lock_b             => rel_way_lock_b,
     rel_way_lock_c             => rel_way_lock_c,
     rel_way_lock_d             => rel_way_lock_d,
     rel_way_lock_e             => rel_way_lock_e,
     rel_way_lock_f             => rel_way_lock_f,
     rel_way_lock_g             => rel_way_lock_g,
     rel_way_lock_h             => rel_way_lock_h,

     ex1_p_addr                 => ex1_p_addr,
     ex2_no_lru_upd             => ex2_no_lru_upd,
     ex3_cache_en               => ex3_cache_en,

     ex4_way_a_hit              => ex4_way_a_hit,
     ex4_way_b_hit              => ex4_way_b_hit,
     ex4_way_c_hit              => ex4_way_c_hit,
     ex4_way_d_hit              => ex4_way_d_hit,
     ex4_way_e_hit              => ex4_way_e_hit,
     ex4_way_f_hit              => ex4_way_f_hit,
     ex4_way_g_hit              => ex4_way_g_hit,
     ex4_way_h_hit              => ex4_way_h_hit,
     ex3_hit                    => ex3_l1hit,

     ex3_stg_flush              => stg_ex3_flush,
     ex4_stg_flush              => stg_ex4_flush,
     ex5_stg_flush              => stg_ex5_flush,

     spr_xucr2_rmt              => spr_xucr2_rmt,
     spr_xucr0_wlck             => spr_xucr0_wlck,
     spr_xucr0_dcdis            => spr_xucr0_dcdis_q,
     spr_xucr0_cls              => spr_xucr0_cls_int,

     rel_way_upd_a              => rel_way_upd_a,
     rel_way_upd_b              => rel_way_upd_b,
     rel_way_upd_c              => rel_way_upd_c,
     rel_way_upd_d              => rel_way_upd_d,
     rel_way_upd_e              => rel_way_upd_e,
     rel_way_upd_f              => rel_way_upd_f,
     rel_way_upd_g              => rel_way_upd_g,
     rel_way_upd_h              => rel_way_upd_h,

     rel_way_wen_a              => rel_wayA_wen,
     rel_way_wen_b              => rel_wayB_wen,
     rel_way_wen_c              => rel_wayC_wen,
     rel_way_wen_d              => rel_wayD_wen,
     rel_way_wen_e              => rel_wayE_wen,
     rel_way_wen_f              => rel_wayF_wen,
     rel_way_wen_g              => rel_wayG_wen,
     rel_way_wen_h              => rel_wayH_wen,

     rel_way_clr_a              => rel_way_clr_a,
     rel_way_clr_b              => rel_way_clr_b,
     rel_way_clr_c              => rel_way_clr_c,
     rel_way_clr_d              => rel_way_clr_d,
     rel_way_clr_e              => rel_way_clr_e,
     rel_way_clr_f              => rel_way_clr_f,
     rel_way_clr_g              => rel_way_clr_g,
     rel_way_clr_h              => rel_way_clr_h,
     rel_dcarr_val_upd          => rel_dcarr_val_upd,
     rel_up_way_addr_b          => rel_up_way_addr_b,
     rel_dcarr_addr_en          => rel_dcarr_addr_en,

     lsu_xu_spr_xucr0_clo       => lsu_xu_spr_xucr0_clo,
     ex4_dir_lru                => ex4_dir_lru,
     dc_lru_dbg_data            => dc_lru_dbg_data,

     vdd                        => vdd,
     gnd                        => gnd,
     nclk                       => nclk,
     sg_0                       => sg_0,
     func_sl_thold_0_b          => func_sl_thold_0_b,
     func_sl_force => func_sl_force,
     func_nsl_thold_0_b         => func_nsl_thold_0_b,
     func_nsl_force => func_nsl_force,
     d_mode_dc                  => d_mode_dc,
     delay_lclkr_dc             => delay_lclkr_dc,
     mpw1_dc_b                  => mpw1_dc_b,
     mpw2_dc_b                  => mpw2_dc_b,
     scan_in                    => dir_scan_out,
     scan_out                   => lru_scan_out
   );
end generate dir32k;

l1dcdt : entity work.xuq_lsu_dir_tag(xuq_lsu_dir_tag)
GENERIC MAP(expand_type         => expand_type,
            dc_size             => dc_size,
            cl_size             => cl_size,
            wayDataSize         => wayDataSize,
            parBits             => parBits,
            real_data_add       => real_data_add)       
PORT MAP (

     ex2_stg_act                => ex2_stg_act_int,
     binv2_stg_act              => binv2_stg_act_int,

     rel_addr_early             => ldq_rel_addr_early,
     rel_way_upd_a              => rel_way_upd_a,
     rel_way_upd_b              => rel_way_upd_b,
     rel_way_upd_c              => rel_way_upd_c,
     rel_way_upd_d              => rel_way_upd_d,
     rel_way_upd_e              => rel_way_upd_e,
     rel_way_upd_f              => rel_way_upd_f,
     rel_way_upd_g              => rel_way_upd_g,
     rel_way_upd_h              => rel_way_upd_h,

     inv1_val                   => ex1_l2_inv_val,

     xu_lsu_spr_xucr0_dcdis     => xu_lsu_spr_xucr0_dcdis,

     ex1_p_addr_01              => ex1_dir01_addr,
     ex1_p_addr_23              => ex1_dir23_addr,
     ex1_p_addr_45              => ex1_dir45_addr,
     ex1_p_addr_67              => ex1_dir67_addr,
     ex2_ddir_acc_instr         => ex2_ddir_acc_instr,

     pc_xu_inj_dcachedir_parity => pc_xu_inj_dcachedir_parity,

     dir_arr_rd_addr_01         => dir_arr_rd_addr_01,
     dir_arr_rd_addr_23         => dir_arr_rd_addr_23,
     dir_arr_rd_addr_45         => dir_arr_rd_addr_45,
     dir_arr_rd_addr_67         => dir_arr_rd_addr_67,
     dir_arr_rd_data            => dir_arr_rd_data,

     dir_wr_way                 => dir_wr_way_int,
     dir_arr_wr_addr            => dir_arr_wr_addr_int,
     dir_arr_wr_data            => dir_arr_wr_data_int,

     ex2_wayA_tag               => ex2_wayA_tag,
     ex2_wayB_tag               => ex2_wayB_tag,
     ex2_wayC_tag               => ex2_wayC_tag,
     ex2_wayD_tag               => ex2_wayD_tag,
     ex2_wayE_tag               => ex2_wayE_tag,
     ex2_wayF_tag               => ex2_wayF_tag,
     ex2_wayG_tag               => ex2_wayG_tag,
     ex2_wayH_tag               => ex2_wayH_tag,

     ex3_way_tag_par_a          => ex3_way_tag_par_a,
     ex3_way_tag_par_b          => ex3_way_tag_par_b,
     ex3_way_tag_par_c          => ex3_way_tag_par_c,
     ex3_way_tag_par_d          => ex3_way_tag_par_d,
     ex3_way_tag_par_e          => ex3_way_tag_par_e,
     ex3_way_tag_par_f          => ex3_way_tag_par_f,
     ex3_way_tag_par_g          => ex3_way_tag_par_g,
     ex3_way_tag_par_h          => ex3_way_tag_par_h,

     ex3_tag_way_perr           => ex3_tag_way_perr,

     vdd                        => vdd,
     gnd                        => gnd,
     nclk                       => nclk,
     sg_0                       => sg_0,
     func_sl_thold_0_b          => func_sl_thold_0_b,
     func_sl_force => func_sl_force,
     func_slp_sl_thold_0_b      => func_slp_sl_thold_0_b,
     func_slp_sl_force => func_slp_sl_force,
     d_mode_dc                  => d_mode_dc,
     delay_lclkr_dc             => delay_lclkr_dc,
     mpw1_dc_b                  => mpw1_dc_b,
     mpw2_dc_b                  => mpw2_dc_b,
     scan_in                    => lru_scan_out,
     scan_out                   => tag_scan_out  
   );


dir_arr_dbg_data_d <= dir_wr_enable_int & dir_wr_way_int & dir_arr_wr_addr_int & dir_arr_wr_data_int &
                      ex1_dir_acc_val   & ex1_l2_inv_val & binv1_ex1_stg_act   & recirc_rel_val_q    &
                      lwr_p_addr_q(53 to 57);

dir_arr_dbg_data   <= dir_arr_dbg_data_q;

dc_dir_dbg_data    <= ldq_rel1_val_stg_q & ldq_rel_mid_stg_q & ldq_rel3_val_stg_q & ldq_rel_data_stg_q &
                      ldq_rel_set_stg_q  & rel24_addr_q;

xu_derat_ex1_epn_arr     <= ex1_agen_addr(64-(2**regmode) to 51);
xu_derat_ex1_epn_nonarr  <= ex1_eff_addr(64-(2**regmode) to 51);
ex3_dcbtls_instr         <= dcbtls_instr_ex3;
ex3_dcbtstls_instr       <= dcbtstls_instr_ex3;
ex3_stg_flush            <= stg_ex3_flush;
ex4_stg_flush            <= stg_ex4_flush;
lsu_xu_ex3_ddir_par_err  <= ex3_dir_perr_det;
lsu_xu_ex4_ldq_full_flush <= ex4_ldq_full_flush;
ex4_dir_perr_det         <= ex4_dir_perr_det_q;
spr_xucr0_cls            <= spr_xucr0_cls_int;
ldq_recirc_rel_val       <= recirc_rel_val_q;
xu_derat_rf1_binv_val    <= rf1_l2_inv_val;
dir_arr_wr_addr          <= dir_arr_wr_addr_int;
dir_arr_wr_data          <= dir_arr_wr_data_int;
dir_wr_way               <= dir_wr_way_int;
ex2_p_addr_lwr           <= ex2_p_addr_lwr_int(52 to 57);
ex3_cache_acc            <= ex3_cache_acc_int;

ex1_stg_act   <= ex1_stg_act_int;
ex2_stg_act   <= ex2_stg_act_int;
ex3_stg_act   <= ex3_stg_act_int;
ex4_stg_act   <= ex4_stg_act_int;
binv1_stg_act <= binv1_stg_act_int;
binv2_stg_act <= binv2_stg_act_int;

lwr_p_addr_reg: tri_rlmreg_p
generic map (width => 12, init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => binv1_ex1_stg_act,
            forcee => func_slp_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_slp_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(lwr_p_addr_offset to lwr_p_addr_offset + lwr_p_addr_d'length-1),
            scout   => sov(lwr_p_addr_offset to lwr_p_addr_offset + lwr_p_addr_d'length-1),
            din     => lwr_p_addr_d,
            dout    => lwr_p_addr_q);
ldq_rel1_val_stg_reg: tri_rlmlatch_p
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
            scin    => siv(ldq_rel1_val_stg_offset),
            scout   => sov(ldq_rel1_val_stg_offset),
            din     => ldq_rel1_val_stg_d,
            dout    => ldq_rel1_val_stg_q);
ldq_rel_mid_stg_reg: tri_rlmlatch_p
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
            scin    => siv(ldq_rel_mid_stg_offset),
            scout   => sov(ldq_rel_mid_stg_offset),
            din     => ldq_rel_mid_stg_d,
            dout    => ldq_rel_mid_stg_q);
ldq_rel3_val_stg_reg: tri_rlmlatch_p
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
            scin    => siv(ldq_rel3_val_stg_offset),
            scout   => sov(ldq_rel3_val_stg_offset),
            din     => ldq_rel3_val_stg_d,
            dout    => ldq_rel3_val_stg_q);
ldq_rel_data_stg_reg: tri_regk
generic map (width => 1, init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => tiup,
            forcee => func_nsl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_nsl_thold_0_b,
            din(0)  => ldq_rel_data_stg_d,
            dout(0) => ldq_rel_data_stg_q);
ldq_rel_set_stg_reg: tri_regk
generic map (width => 1, init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => tiup,
            forcee => func_nsl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_nsl_thold_0_b,
            din(0)  => ldq_rel_set_stg_d,
            dout(0) => ldq_rel_set_stg_q);
rel24_addr_reg: tri_regk
generic map (width => real_data_add-11, init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => rel1_stg_act_int,
            forcee => func_nsl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_nsl_thold_0_b,
            din     => rel24_addr_d,
            dout    => rel24_addr_q);
spr_xucr0_dcdis_reg: tri_rlmlatch_p
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
            scin    => siv(spr_xucr0_dcdis_offset),
            scout   => sov(spr_xucr0_dcdis_offset),
            din     => spr_xucr0_dcdis_d,
            dout    => spr_xucr0_dcdis_q);
ex2_frc_align_reg: tri_regk
generic map (width => 5, init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => ex1_stg_act_int,
            forcee => func_nsl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_nsl_thold_0_b,
            din     => ex2_frc_align_d,
            dout    => ex2_frc_align_q);

ldq_rel_stg24_val_reg: tri_regk
generic map (width => 1, init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => tiup,
            forcee => func_nsl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_nsl_thold_0_b,
            din(0)  => ldq_rel_stg24_val_d,
            dout(0) => ldq_rel_stg24_val_q);

ex4_dir_perr_det_reg: tri_rlmlatch_p
generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => tiup,
            forcee => func_slp_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_slp_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex4_dir_perr_det_offset),
            scout   => sov(ex4_dir_perr_det_offset),
            din     => ex4_dir_perr_det_d,
            dout    => ex4_dir_perr_det_q);

recirc_rel_val_reg: tri_rlmlatch_p
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
            scin    => siv(recirc_rel_val_offset),
            scout   => sov(recirc_rel_val_offset),
            din     => recirc_rel_val_d,
            dout    => recirc_rel_val_q);

trace_bus_enable_reg: tri_rlmlatch_p
generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => tiup,
            forcee => func_slp_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_slp_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(trace_bus_enable_offset),
            scout   => sov(trace_bus_enable_offset),
            din     => pc_xu_trace_bus_enable,
            dout    => trace_bus_enable_q);

dir_arr_dbg_data_reg: tri_regk
generic map (width => 61, init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => trace_bus_enable_q,
            forcee => func_nsl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_nsl_thold_0_b,
            din     => dir_arr_dbg_data_d,
            dout    => dir_arr_dbg_data_q);

siv(0 to scan_right) <= sov(1 to scan_right) & tag_scan_out;
scan_out(3) <= sov(0);
end xuq_lsu_dir;

