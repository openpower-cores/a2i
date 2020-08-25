-- © IBM Corp. 2020
-- This softcore is licensed under and subject to the terms of the CC-BY 4.0
-- license (https://creativecommons.org/licenses/by/4.0/legalcode). 
-- Additional rights, including the right to physically implement a softcore 
-- that is compliant with the required sections of the Power ISA 
-- Specification, will be available at no cost via the OpenPOWER Foundation. 
-- This README will be updated with additional information when OpenPOWER's 
-- license is available.

--  Description:  XU LSU L1 Data Directory and L2 Command Queue Wrapper
library ibm, ieee, work, tri, support;
use ibm.std_ulogic_support.all;
use ibm.std_ulogic_function_support.all;
use ibm.std_ulogic_unsigned.all;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use tri.tri_latches_pkg.all;
use support.power_logic_pkg.all;
use work.xuq_pkg.mark_unused;

-- ##########################################################################################
-- VHDL Contents
-- 1) L2 Command Queue
-- 2) Valid Register Array
-- 3) LRU Register Array
-- 4) Data Cache Control
-- 5) Flush Generation
-- 6) 8 way tag compare
-- 7) Parity Check
-- 8) Reload Update
-- ##########################################################################################
entity xuq_lsu_cmd is
generic(expand_type      : integer := 2;
        lmq_entries      : integer := 8;
        l_endian_m       : integer := 1;         
        regmode          : integer := 6;
        dc_size          : natural := 14;       -- 2^14 = 16384 Bytes L1 D$
        cl_size          : natural := 6;        -- 2^6 = 64 Bytes CacheLines
	real_data_add	 : integer := 42;
        a2mode           : integer := 1;
        load_credits     : integer := 4;
        store_credits    : integer := 20;
        st_data_32B_mode : integer := 1;       -- 0 = 16B store data to L2, 1 = 32B data
        bcfg_epn_0to15     : integer := 0;
        bcfg_epn_16to31    : integer := 0;
        bcfg_epn_32to47    : integer := (2**16)-1;  
        bcfg_epn_48to51    : integer := (2**4)-1; 
        bcfg_rpn_22to31    : integer := (2**10)-1;
        bcfg_rpn_32to47    : integer := (2**16)-1;  
        bcfg_rpn_48to51    : integer := (2**4)-1); 
port(
     xu_lsu_rf0_act             :in  std_ulogic;
     xu_lsu_rf1_cmd_act         :in  std_ulogic;
     xu_lsu_rf1_axu_op_val      :in  std_ulogic;                        
     xu_lsu_rf1_axu_ldst_falign :in  std_ulogic;
     xu_lsu_rf1_axu_ldst_fexcpt :in  std_ulogic;                        -- AXU force alignment exception on misaligned access
     xu_lsu_rf1_cache_acc       :in  std_ulogic;                        
     xu_lsu_rf1_thrd_id         :in  std_ulogic_vector(0 to 3);         
     xu_lsu_rf1_optype1         :in  std_ulogic;                        
     xu_lsu_rf1_optype2         :in  std_ulogic;                        
     xu_lsu_rf1_optype4         :in  std_ulogic;                        
     xu_lsu_rf1_optype8         :in  std_ulogic;                        
     xu_lsu_rf1_optype16        :in  std_ulogic;                        
     xu_lsu_rf1_optype32        :in  std_ulogic;                        
     xu_lsu_rf1_target_gpr      :in  std_ulogic_vector(0 to 8);
     xu_lsu_rf1_mtspr_trace     :in  std_ulogic;                        -- Operation is a mtspr trace instruction
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
     xu_lsu_rf1_mutex_hint      :in  std_ulogic;                        -- Mutex Hint For larx instructions
     xu_lsu_rf1_mbar_instr      :in  std_ulogic;
     xu_lsu_rf1_is_msgsnd       :in  std_ulogic;
     xu_lsu_rf1_dci_instr       :in  std_ulogic;                        -- DCI instruction is valid
     xu_lsu_rf1_ici_instr       :in  std_ulogic;                        -- ICI instruction is valid
     xu_lsu_rf1_algebraic       :in  std_ulogic;                        
     xu_lsu_rf1_byte_rev        :in  std_ulogic;                        
     xu_lsu_rf1_src_gpr         :in  std_ulogic;                        
     xu_lsu_rf1_src_axu         :in  std_ulogic;                        
     xu_lsu_rf1_src_dp          :in  std_ulogic;                        
     xu_lsu_rf1_targ_gpr        :in  std_ulogic;                        
     xu_lsu_rf1_targ_axu        :in  std_ulogic;                        
     xu_lsu_rf1_targ_dp         :in  std_ulogic;
     xu_lsu_ex4_val             :in  std_ulogic_vector(0 to 3);         -- There is a valid Instruction in EX4
     xu_lsu_ex1_add_src0        :in  std_ulogic_vector(64-(2**REGMODE) to 63);
     xu_lsu_ex1_add_src1        :in  std_ulogic_vector(64-(2**REGMODE) to 63);
     xu_lsu_ex2_instr_trace_val :in  std_ulogic;

     xu_lsu_rf1_src0_vld        :in  std_ulogic;                        
     xu_lsu_rf1_src0_reg        :in  std_ulogic_vector(0 to 7);         
     xu_lsu_rf1_src1_vld        :in  std_ulogic;                        
     xu_lsu_rf1_src1_reg        :in  std_ulogic_vector(0 to 7);         
     xu_lsu_rf1_targ_vld        :in  std_ulogic;                        
     xu_lsu_rf1_targ_reg        :in  std_ulogic_vector(0 to 7);         

     -- Error Inject
     pc_xu_inj_dcachedir_parity :in  std_ulogic;
     pc_xu_inj_dcachedir_multihit :in  std_ulogic;

     ex4_256st_data             :in  std_ulogic_vector(0 to 255);
     xu_lsu_ex4_dvc1_en         :in  std_ulogic;
     xu_lsu_ex4_dvc2_en         :in  std_ulogic;

     xu_lsu_mtspr_trace_en      :in  std_ulogic_vector(0 to 3);
     spr_xucr0_clkg_ctl_b1      :in  std_ulogic;
     spr_xucr0_clkg_ctl_b3      :in  std_ulogic;
     spr_xucr4_mmu_mchk         :in  std_ulogic;
     xu_lsu_spr_xucr0_aflsta    :in  std_ulogic;
     xu_lsu_spr_xucr0_flsta     :in  std_ulogic;
     xu_lsu_spr_xucr0_l2siw     :in  std_ulogic;
     xu_lsu_spr_xucr0_dcdis     :in  std_ulogic;
     xu_lsu_spr_xucr0_wlk       :in  std_ulogic;
     xu_lsu_spr_xucr0_clfc      :in  std_ulogic;
     xu_lsu_spr_xucr0_flh2l2    :in  std_ulogic;
     xu_lsu_spr_xucr0_cred      :in  std_ulogic;
     xu_lsu_spr_xucr0_rel       :in  std_ulogic;
     xu_lsu_spr_xucr0_mbar_ack  :in  std_ulogic;
     xu_lsu_spr_xucr0_tlbsync   :in  std_ulogic;                        -- use sync_ack from L2 for tlbsync when 1
     xu_lsu_spr_xucr0_cls       :in  std_ulogic;                        -- Cacheline Size = 1 => 128Byte size, 0 => 64Byte size
     xu_lsu_spr_ccr2_dfrat      :in  std_ulogic;
     xu_lsu_spr_ccr2_dfratsc    :in  std_ulogic_vector(0 to 8);

     an_ac_flh2l2_gate          :in  std_ulogic;                        -- Gate L1 Hit forwarding SPR config bit

     xu_lsu_dci                 :in  std_ulogic;

     -- ERAT Operations
     xu_lsu_rf0_derat_val       :in  std_ulogic_vector(0 to 3);         -- TLB Valid Operation
     xu_lsu_rf1_derat_act       :in  std_ulogic;                        -- Derat Operation is Valid
     xu_lsu_rf1_derat_ra_eq_ea  :in  std_ulogic;                        -- Bypass Erats on specific operations
     xu_lsu_rf1_derat_is_load   :in  std_ulogic;                        -- Cache access should be treated as a load
     xu_lsu_rf1_derat_is_store  :in  std_ulogic;                        -- Cache access should be treated as a store
     xu_lsu_rf0_derat_is_extload  :in  std_ulogic;                      -- Cache access should be treated as an external load
     xu_lsu_rf0_derat_is_extstore :in  std_ulogic;                      -- Cache access should be treated as an external store
     xu_lsu_rf1_is_eratre       :in  std_ulogic;                        -- erat Read Operation
     xu_lsu_rf1_is_eratwe       :in  std_ulogic;                        -- erat Write Operation
     xu_lsu_rf1_is_eratsx       :in  std_ulogic;                        -- erat Search Operation
     xu_lsu_rf1_is_eratilx      :in  std_ulogic;                        -- erat Invalidate Local Operation
     xu_lsu_ex1_is_isync        :in  std_ulogic;                        -- instr. synch decode
     xu_lsu_ex1_is_csync        :in  std_ulogic;                        -- context synch decode
     xu_lsu_rf1_is_touch        :in  std_ulogic;                        -- Instruction is a Touch operation
     xu_lsu_rf1_ws              :in  std_ulogic_vector(0 to 1);         -- ERAT WS Field
     xu_lsu_rf1_t               :in  std_ulogic_vector(0 to 2);         -- ERAT T Field
     xu_lsu_ex1_rs_is           :in  std_ulogic_vector(0 to 8);         -- ERAT invalidate select
     xu_lsu_ex1_ra_entry        :in  std_ulogic_vector(0 to 4);         -- ERAT Entry Number
     xu_lsu_ex4_rs_data         :in  std_ulogic_vector(64-(2**REGMODE) to 63);        -- ERAT Update Data
     xu_lsu_msr_gs              :in  std_ulogic_vector(0 to 3);         -- (MSR.HV)
     xu_lsu_msr_pr              :in  std_ulogic_vector(0 to 3);         -- Problem State (MSR.PR)
     xu_lsu_msr_ds              :in  std_ulogic_vector(0 to 3);         -- Addr Space (MSR.DS)
     xu_lsu_msr_cm              :in  std_ulogic_vector(0 to 3);         -- Comput Mode
     xu_lsu_hid_mmu_mode        :in  std_ulogic;                        -- MMU mode
     ex6_ld_par_err             :in  std_ulogic;                        

     xu_lsu_rf0_flush           :in  std_ulogic_vector(0 to 3);
     xu_lsu_rf1_flush           :in  std_ulogic_vector(0 to 3);
     xu_lsu_ex1_flush           :in  std_ulogic_vector(0 to 3);
     xu_lsu_ex2_flush           :in  std_ulogic_vector(0 to 3);
     xu_lsu_ex3_flush           :in  std_ulogic_vector(0 to 3);
     xu_lsu_ex4_flush           :in  std_ulogic_vector(0 to 3);
     xu_lsu_ex5_flush           :in  std_ulogic_vector(0 to 3);

     lsu_xu_ex4_tlb_data        :out std_ulogic_vector(64-(2**REGMODE) to 63);
     xu_mm_derat_req            :out std_ulogic;
     xu_mm_derat_thdid          :out std_ulogic_vector(0 to 3);
     xu_mm_derat_state          :out std_ulogic_vector(0 to 3);
     xu_mm_derat_tid            :out std_ulogic_vector(0 to 13);
     xu_mm_derat_lpid           :out std_ulogic_vector(0 to 7);
     xu_mm_derat_ttype          :out std_ulogic_vector(0 to 1);
     mm_xu_derat_rel_val        :in  std_ulogic_vector(0 to 4);
     mm_xu_derat_rel_data       :in  std_ulogic_vector(0 to 131);
     mm_xu_derat_pid0           :in  std_ulogic_vector(0 to 13);         -- Thread0 PID Number
     mm_xu_derat_pid1           :in  std_ulogic_vector(0 to 13);         -- Thread1 PID Number
     mm_xu_derat_pid2           :in  std_ulogic_vector(0 to 13);         -- Thread2 PID Number
     mm_xu_derat_pid3           :in  std_ulogic_vector(0 to 13);         -- Thread3 PID Number
     mm_xu_derat_mmucr0_0       :in  std_ulogic_vector(0 to 19);
     mm_xu_derat_mmucr0_1       :in  std_ulogic_vector(0 to 19);
     mm_xu_derat_mmucr0_2       :in  std_ulogic_vector(0 to 19);
     mm_xu_derat_mmucr0_3       :in  std_ulogic_vector(0 to 19);
     xu_mm_derat_mmucr0         :out std_ulogic_vector(0 to 17);
     xu_mm_derat_mmucr0_we      :out std_ulogic_vector(0 to 3);
     mm_xu_derat_mmucr1         :in  std_ulogic_vector(0 to 9);
     xu_mm_derat_mmucr1         :out std_ulogic_vector(0 to 4);
     xu_mm_derat_mmucr1_we      :out std_ulogic;
     mm_xu_derat_snoop_coming   :in  std_ulogic;
     mm_xu_derat_snoop_val      :in  std_ulogic;
     mm_xu_derat_snoop_attr     :in  std_ulogic_vector(0 to 25);
     mm_xu_derat_snoop_vpn      :in  std_ulogic_vector(64-(2**REGMODE) to 51);
     xu_mm_derat_snoop_ack      :out std_ulogic;

     xu_lsu_slowspr_val         :in  std_ulogic;
     xu_lsu_slowspr_rw          :in  std_ulogic;
     xu_lsu_slowspr_etid        :in  std_ulogic_vector(0 to 1);
     xu_lsu_slowspr_addr        :in  std_ulogic_vector(0 to 9);
     xu_lsu_slowspr_data        :in  std_ulogic_vector(64-(2**REGMODE) to 63);
     xu_lsu_slowspr_done        :in  std_ulogic;
     slowspr_val_out          :out std_ulogic;
     slowspr_rw_out           :out std_ulogic;
     slowspr_etid_out         :out std_ulogic_vector(0 to 1);
     slowspr_addr_out         :out std_ulogic_vector(0 to 9);
     slowspr_data_out         :out std_ulogic_vector(64-(2**REGMODE) to 63);
     slowspr_done_out         :out std_ulogic;

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
     lsu_xu_ex3_attr            :out std_ulogic_vector(0 to 8);        -- Page Attribute Bits
     lsu_xu_ex3_derat_vf        :out std_ulogic;

     lsu_xu_ex3_n_flush_req     :out std_ulogic;
     lsu_xu_datc_perr_recovery  :out std_ulogic;
     lsu_xu_l2_ecc_err_flush    :out std_ulogic_vector(0 to 3);
     lsu_xu_ex4_ldq_full_flush  :out std_ulogic;
     lsu_xu_ex3_ldq_hit_flush   :out std_ulogic;
     lsu_xu_ex3_dep_flush       :out std_ulogic;
     lsu_xu_ex3_l2_uc_ecc_err   :out std_ulogic_vector(0 to 3);
     lsu_xu_ex3_derat_par_err   :out std_ulogic_vector(0 to 3);         -- D-ERAT had a Parity Error
     lsu_xu_ex3_derat_multihit_err :out std_ulogic_vector(0 to 3);      -- D-ERAT had multiple hits
     lsu_xu_ex4_derat_par_err   :out std_ulogic_vector(0 to 3);         -- D-ERAT had a Parity Error
     derat_xu_ex3_miss          :out std_ulogic_vector(0 to 3);         -- D-ERAT detected an erat miss
     derat_xu_ex3_dsi           :out std_ulogic_vector(0 to 3);         -- D-ERAT detected a data storage interrupt
     derat_xu_ex3_n_flush_req   :out std_ulogic_vector(0 to 3);         -- D-ERAT needs an ex3 flush request

     ex3_algebraic              :out std_ulogic;
     ex3_data_swap              :out std_ulogic;
     ex3_thrd_id                :out std_ulogic_vector(0 to 3);
     xu_fu_ex3_eff_addr         :out std_ulogic_vector(59 to 63);

     lsu_xu_ex3_ddir_par_err    :out std_ulogic;
     lsu_xu_ex4_n_lsu_ddmh_flush :out std_ulogic_vector(0 to 3);

     -- back invalidate
     lsu_xu_is2_back_inv        :out std_ulogic;
     lsu_xu_is2_back_inv_addr   :out std_ulogic_vector(64-real_data_add to 63-cl_size);

     -- Update Data Array Valid
     rel_upd_dcarr_val          :out std_ulogic;
                        
     lsu_xu_ex4_cr_upd          :out std_ulogic;
     lsu_xu_ex5_cr_rslt         :out std_ulogic;
     lsu_xu_ex5_wren            :out std_ulogic;
     lsu_xu_rel_wren            :out std_ulogic;
     lsu_xu_rel_ta_gpr          :out std_ulogic_vector(0 to 7);
     lsu_xu_need_hole           :out std_ulogic;
     xu_fu_ex5_reload_val       :out std_ulogic;
     xu_fu_ex5_load_val         :out std_ulogic_vector(0 to 3);
     xu_fu_ex5_load_tag         :out std_ulogic_vector(0 to 8);

     -- Data Array Controls
     dcarr_up_way_addr          :out std_ulogic_vector(0 to 2);

     -- SPR status
     lsu_xu_spr_xucr0_cslc_xuop :out std_ulogic;                        -- Invalidate type instruction invalidated lock
     lsu_xu_spr_xucr0_cslc_binv :out std_ulogic;                        -- Back-Invalidate invalidated lock
     lsu_xu_spr_xucr0_clo       :out std_ulogic;                        -- Cache Lock instruction caused an overlock
     lsu_xu_spr_xucr0_cul       :out std_ulogic;                        -- Cache Lock unable to lock
     lsu_xu_spr_epsc_epr        :out std_ulogic_vector(0 to 3);
     lsu_xu_spr_epsc_egs        :out std_ulogic_vector(0 to 3);

     -- Debug Data Compare
     ex4_load_op_hit            :out std_ulogic;
     ex4_store_hit              :out std_ulogic;
     ex4_axu_op_val             :out std_ulogic;
     spr_dvc1_act               :out std_ulogic;
     spr_dvc2_act               :out std_ulogic;
     spr_dvc1_dbg               :out std_ulogic_vector(64-(2**regmode) to 63);
     spr_dvc2_dbg               :out std_ulogic_vector(64-(2**regmode) to 63);

     -- Inputs from L2
     an_ac_req_ld_pop           :in  std_ulogic;
     an_ac_req_st_pop           :in  std_ulogic;
     an_ac_req_st_gather        :in  std_ulogic;
     an_ac_req_st_pop_thrd      :in  std_ulogic_vector(0 to 2);   -- decrement outbox credit count

     an_ac_reld_data_val        :in  std_ulogic;
     an_ac_reld_core_tag        :in  std_ulogic_vector(0 to 4);
     an_ac_reld_qw              :in  std_ulogic_vector(57 to 59);
     an_ac_reld_data            :in  std_ulogic_vector(0 to 127);
     an_ac_reld_data_coming     :in  std_ulogic;
     an_ac_reld_ditc            :in  std_ulogic;
     an_ac_reld_crit_qw         :in  std_ulogic;
     an_ac_reld_l1_dump         :in  std_ulogic;

     an_ac_reld_ecc_err         :in  std_ulogic;
     an_ac_reld_ecc_err_ue      :in  std_ulogic;

     an_ac_back_inv             :in  std_ulogic;
     an_ac_back_inv_addr        :in  std_ulogic_vector(64-real_data_add to 63);
     an_ac_back_inv_target_bit1 :in  std_ulogic;
     an_ac_back_inv_target_bit4 :in  std_ulogic;
     an_ac_req_spare_ctrl_a1    :in  std_ulogic_vector(0 to 3);
                                     
     an_ac_stcx_complete        :in  std_ulogic_vector(0 to 3);
     xu_iu_stcx_complete        : out   std_ulogic_vector(0 to 3);
     xu_iu_reld_core_tag_clone     :out     std_ulogic_vector(1 to 4);
     xu_iu_reld_data_coming_clone  :out     std_ulogic;
     xu_iu_reld_data_vld_clone     :out     std_ulogic;
     xu_iu_reld_ditc_clone         :out     std_ulogic;

-- redrive to boxes logic
     lsu_reld_data_vld        :out    std_ulogic;                      -- reload data is coming in 2 cycles
     lsu_reld_core_tag        :out    std_ulogic_vector(3 to 4);       -- reload data destinatoin tag (thread)
     lsu_reld_qw              :out    std_ulogic_vector(58 to 59);     -- reload data destinatoin tag (thread)
     lsu_reld_ecc_err         :out    std_ulogic;                      -- reload data has ecc error
     lsu_reld_ditc            :out    std_ulogic;                      -- reload data is for ditc (inbox)
     lsu_reld_data            :out    std_ulogic_vector(0 to 127);     -- reload data

     lsu_req_st_pop           :out    std_ulogic;                  -- decrement outbox credit count
     lsu_req_st_pop_thrd      :out    std_ulogic_vector(0 to 2);   -- decrement outbox credit count

     -- Instruction Fetches
     i_x_ra                     :in  std_ulogic_vector(64-real_data_add to 59);
     i_x_request                :in  std_ulogic;
     i_x_wimge                  :in  std_ulogic_vector(0 to 4);
     i_x_thread                 :in  std_ulogic_vector(0 to 3);
     i_x_userdef                :in  std_ulogic_vector(0 to 3);

     -- MMU instruction interface
     mm_xu_lsu_req              :in  std_ulogic_vector(0 to 3);
     mm_xu_lsu_ttype            :in  std_ulogic_vector(0 to 1);
     mm_xu_lsu_wimge            :in  std_ulogic_vector(0 to 4);
     mm_xu_lsu_u                :in  std_ulogic_vector(0 to 3);
     mm_xu_lsu_addr             :in  std_ulogic_vector(64-real_data_add to 63);
     mm_xu_lsu_lpid             :in  std_ulogic_vector(0 to 7); 
     mm_xu_lsu_lpidr            :in  std_ulogic_vector(0 to 7); 
     mm_xu_lsu_gs               :in  std_ulogic;
     mm_xu_lsu_ind              :in  std_ulogic;
     mm_xu_lsu_lbit             :in  std_ulogic;                   -- "L" bit, for large vs. small
     xu_mm_lsu_token            :out std_ulogic;
     lsu_xu_ldq_barr_done       :out std_ulogic_vector(0 to 3);
     lsu_xu_barr_done           :out std_ulogic_vector(0 to 3);

     -- Boxes interface
     bx_lsu_ob_pwr_tok          :in     std_ulogic;
     bx_lsu_ob_req_val          :in     std_ulogic;                  -- message buffer data is ready to send
     bx_lsu_ob_ditc_val         :in     std_ulogic;                  -- send dtic command
     bx_lsu_ob_thrd             :in     std_ulogic_vector(0 to 1);   -- source thread
     bx_lsu_ob_qw               :in     std_ulogic_vector(58 to 59); -- QW address
     bx_lsu_ob_dest             :in     std_ulogic_vector(0 to 14);  -- destination for the packet
     bx_lsu_ob_data             :in     std_ulogic_vector(0 to 127); -- 16B of data from the outbox
     bx_lsu_ob_addr             :in     std_ulogic_vector(64-real_data_add to 57); -- address for boxes message
     lsu_bx_cmd_avail           :out    std_ulogic;
     lsu_bx_cmd_sent            :out    std_ulogic;
     lsu_bx_cmd_stall           :out    std_ulogic;

     -- *** Reload operation Outputs ***
     ldq_rel_data_val_early     :out std_ulogic;
     ldq_rel_op_size            :out std_ulogic_vector(0 to 5);
     ldq_rel_addr               :out std_ulogic_vector(64-(dc_size-3) to 58);
     ldq_rel_data_val           :out std_ulogic;
     ldq_rel_rot_sel            :out std_ulogic_vector(0 to 4);
     ldq_rel_axu_val            :out std_ulogic;
     ldq_rel_ci                 :out std_ulogic;
     ldq_rel_thrd_id            :out std_ulogic_vector(0 to 3);
     ldq_rel_le_mode            :out std_ulogic;
     ldq_rel_algebraic          :out std_ulogic;
     ldq_rel_256_data           :out std_ulogic_vector(0 to 255);

     ldq_rel_dvc1_en            :out std_ulogic;
     ldq_rel_dvc2_en            :out std_ulogic;
     ldq_rel_beat_crit_qw       :out std_ulogic;
     ldq_rel_beat_crit_qw_block :out std_ulogic;

     xu_iu_ex4_loadmiss_qentry  :out std_ulogic_vector(0 to lmq_entries-1);
     xu_iu_ex4_loadmiss_target  :out std_ulogic_vector(0 to 8);
     xu_iu_ex4_loadmiss_target_type :out std_ulogic_vector(0 to 1);
     xu_iu_ex4_loadmiss_tid     :out std_ulogic_vector(0 to 3);
     xu_iu_ex5_loadmiss_qentry  :out std_ulogic_vector(0 to lmq_entries-1);
     xu_iu_ex5_loadmiss_target  :out std_ulogic_vector(0 to 8);
     xu_iu_ex5_loadmiss_target_type :out std_ulogic_vector(0 to 1);
     xu_iu_ex5_loadmiss_tid     :out std_ulogic_vector(0 to 3);
     xu_iu_complete_qentry      :out std_ulogic_vector(0 to lmq_entries-1);
     xu_iu_complete_tid         :out std_ulogic_vector(0 to 3);
     xu_iu_complete_target_type :out std_ulogic_vector(0 to 1);

     -- ICBI Interface
     xu_iu_ex6_icbi_val         :out std_ulogic_vector(0 to 3);
     xu_iu_ex6_icbi_addr        :out std_ulogic_vector(64-real_data_add to 57);     

     xu_lsu_ex5_set_barr         :in  std_ulogic_vector(0 to 3);
     xu_iu_larx_done_tid        :out std_ulogic_vector(0 to 3);
     xu_mm_lmq_stq_empty        :out std_ulogic;
     lsu_xu_quiesce             :out std_ulogic_vector(0 to 3);
     lsu_xu_dbell_val           :out std_ulogic;
     lsu_xu_dbell_type          :out std_ulogic_vector(0 to 4);
     lsu_xu_dbell_brdcast       :out std_ulogic;
     lsu_xu_dbell_lpid_match    :out std_ulogic;
     lsu_xu_dbell_pirtag        :out std_ulogic_vector(50 to 63);

     ac_an_req_pwr_token        :out std_ulogic;
     ac_an_req                  :out std_ulogic;
     ac_an_req_ra               :out std_ulogic_vector(64-real_data_add to 63);
     ac_an_req_ttype            :out std_ulogic_vector(0 to 5);
     ac_an_req_thread           :out std_ulogic_vector(0 to 2);
     ac_an_req_wimg_w           :out std_ulogic;
     ac_an_req_wimg_i           :out std_ulogic;
     ac_an_req_wimg_m           :out std_ulogic;
     ac_an_req_wimg_g           :out std_ulogic;
     ac_an_req_endian           :out std_ulogic;
     ac_an_req_user_defined     :out std_ulogic_vector(0 to 3);
     ac_an_req_spare_ctrl_a0    :out std_ulogic_vector(0 to 3);
     ac_an_req_ld_core_tag      :out std_ulogic_vector(0 to 4);
     ac_an_req_ld_xfr_len       :out std_ulogic_vector(0 to 2);
     ac_an_st_byte_enbl         :out std_ulogic_vector(0 to 15+(st_data_32B_mode*16));
     ac_an_st_data              :out std_ulogic_vector(0 to 127+(st_data_32B_mode*128));
     ac_an_st_data_pwr_token    :out std_ulogic;

     ac_an_reld_ditc_pop_int    : in  std_ulogic_vector(0 to 3);
     ac_an_reld_ditc_pop_q      : out std_ulogic_vector(0 to 3);
     bx_ib_empty_int            : in  std_ulogic_vector(0 to 3);
     bx_ib_empty_q              : out std_ulogic_vector(0 to 3);
    
     --pervasive
     xu_pc_err_dcachedir_parity :out std_ulogic;
     xu_pc_err_dcachedir_multihit :out std_ulogic;
     xu_pc_err_l2intrf_ecc      :out std_ulogic;
     xu_pc_err_l2intrf_ue       :out std_ulogic;
     xu_pc_err_invld_reld       :out std_ulogic;
     xu_pc_err_l2credit_overrun :out std_ulogic;
     pc_xu_init_reset           :in  std_ulogic;

     -- Performance Counters
     pc_xu_event_bus_enable     :in  std_ulogic;
     pc_xu_event_count_mode     :in  std_ulogic_vector(0 to 2);
     pc_xu_lsu_event_mux_ctrls  :in  std_ulogic_vector(0 to 47);
     pc_xu_cache_par_err_event  :in  std_ulogic;
     xu_pc_lsu_event_data       :out std_ulogic_vector(0 to 7);

     -- Debug Trace Bus
     pc_xu_trace_bus_enable     :in  std_ulogic;
     lsu_debug_mux_ctrls        :in  std_ulogic_vector(0 to 15);
     trigger_data_in            :in  std_ulogic_vector(0 to 11);
     debug_data_in              :in  std_ulogic_vector(0 to 87);
     trigger_data_out           :out std_ulogic_vector(0 to 11);
     debug_data_out             :out std_ulogic_vector(0 to 87);
     lsu_xu_cmd_debug           :out std_ulogic_vector(0 to 175);

     -- G8T ABIST Control
     an_ac_lbist_ary_wrt_thru_dc :in  std_ulogic;
     pc_xu_abist_g8t_wenb       :in  std_ulogic;
     pc_xu_abist_g8t1p_renb_0   :in  std_ulogic;
     pc_xu_abist_di_0           :in  std_ulogic_vector(0 to 3);
     pc_xu_abist_g8t_bw_1       :in  std_ulogic;
     pc_xu_abist_g8t_bw_0       :in  std_ulogic;
     pc_xu_abist_waddr_0        :in  std_ulogic_vector(5 to 9);
     pc_xu_abist_raddr_0        :in  std_ulogic_vector(5 to 9);
     pc_xu_abist_ena_dc         :in  std_ulogic;
     pc_xu_abist_wl32_comp_ena  :in  std_ulogic;
     pc_xu_abist_raw_dc_b       :in  std_ulogic;
     pc_xu_abist_g8t_dcomp      :in  std_ulogic_vector(0 to 3);
     pc_xu_bo_unload            :in  std_ulogic;
     pc_xu_bo_repair            :in  std_ulogic;
     pc_xu_bo_reset             :in  std_ulogic;
     pc_xu_bo_shdata            :in  std_ulogic;
     pc_xu_bo_select            :in  std_ulogic_vector(1 to 4);
     xu_pc_bo_fail              :out std_ulogic_vector(1 to 4);
     xu_pc_bo_diagout           :out std_ulogic_vector(1 to 4);

     vcs                        :inout power_logic;
     vdd                        :inout power_logic;
     gnd                        :inout power_logic;
     nclk                       :in  clk_logic;
     an_ac_grffence_en_dc       :in  std_ulogic;
     an_ac_coreid               :in  std_ulogic_vector(6 to 7);
     pc_xu_ccflush_dc           :in  std_ulogic;
     an_ac_scan_dis_dc_b        :in  std_ulogic;
     an_ac_atpg_en_dc           :in  std_ulogic;
     an_ac_scan_diag_dc         :in  std_ulogic;
     an_ac_lbist_en_dc          :in  std_ulogic;
     clkoff_dc_b                :in  std_ulogic;
     sg_2                       :in  std_ulogic_vector(2 to 3);
     fce_2                      :in  std_ulogic;
     func_sl_thold_2            :in  std_ulogic_vector(2 to 3);
     func_nsl_thold_2           :in  std_ulogic;
     func_slp_sl_thold_2        :in  std_ulogic;
     func_slp_nsl_thold_2       :in  std_ulogic;
     cfg_slp_sl_thold_2         :in  std_ulogic;
     regf_slp_sl_thold_2        :in  std_ulogic;
     abst_slp_sl_thold_2        :in  std_ulogic;
     time_sl_thold_2            :in  std_ulogic;
     ary_slp_nsl_thold_2        :in  std_ulogic;
     repr_sl_thold_2            :in  std_ulogic;
     bolt_sl_thold_2            :in  std_ulogic;
     bo_enable_2                :in  std_ulogic;
     d_mode_dc                  :in  std_ulogic;
     delay_lclkr_dc             :in  std_ulogic_vector(5 to 9);
     mpw1_dc_b                  :in  std_ulogic_vector(5 to 9);
     mpw2_dc_b                  :in  std_ulogic;
     g8t_clkoff_dc_b            :in  std_ulogic;
     g8t_d_mode_dc              :in  std_ulogic;
     g8t_delay_lclkr_dc         :in  std_ulogic_vector(0 to 4);
     g8t_mpw1_dc_b              :in  std_ulogic_vector(0 to 4);
     g8t_mpw2_dc_b              :in  std_ulogic;
     cam_clkoff_dc_b            :in  std_ulogic;
     cam_d_mode_dc              :in  std_ulogic;
     cam_act_dis_dc             :in  std_ulogic;
     cam_delay_lclkr_dc         :in  std_ulogic_vector(0 to 4);
     cam_mpw1_dc_b              :in  std_ulogic_vector(0 to 4);
     cam_mpw2_dc_b              :in  std_ulogic;
     bcfg_scan_in               :in  std_ulogic;
     bcfg_scan_out              :out std_ulogic;
     ccfg_scan_in               :in  std_ulogic;
     ccfg_scan_out              :out std_ulogic;
     dcfg_scan_in               :in  std_ulogic;
     dcfg_scan_out              :out std_ulogic;
     regf_scan_in               :in  std_ulogic_vector(0 to 6);
     regf_scan_out              :out std_ulogic_vector(0 to 6); 
     abst_scan_in               :in  std_ulogic;
     abst_scan_out              :out std_ulogic;
     time_scan_in               :in  std_ulogic;
     time_scan_out              :out std_ulogic;
     repr_scan_in               :in  std_ulogic;
     repr_scan_out              :out std_ulogic;
     func_scan_in               :in  std_ulogic_vector(41 to 49);
     func_scan_out              :out std_ulogic_vector(41 to 49)     
);
-- synopsys translate_off
-- synopsys translate_on
end xuq_lsu_cmd;
----
architecture xuq_lsu_cmd of xuq_lsu_cmd is

constant uprTagBit              :natural := 64-real_data_add;
constant lwrTagBit              :natural := 63-(dc_size-3);
constant tagSize                :natural := lwrTagBit-uprTagBit+1;
constant parExtCalc             :natural := 8 - (tagSize mod 8);
constant parBits                :natural := (tagSize+parExtCalc) / 8;
constant wayDataSize            :natural := tagSize+parBits;

signal ex3_req_thrd_id          :std_ulogic_vector(0 to 3);
signal ex3_l_s_q_val            :std_ulogic;
signal ex3_drop_ld_req          :std_ulogic;
signal ex3_drop_touch           :std_ulogic;
signal ex3_cache_inh            :std_ulogic;
signal ex3_load_instr           :std_ulogic;
signal ex3_store_instr          :std_ulogic;
signal ex3_cache_acc            :std_ulogic;
signal ex2_p_addr_lwr           :std_ulogic_vector(52 to 57);
signal ex3_p_addr_lwr           :std_ulogic_vector(58 to 63);
signal ex3_opsize               :std_ulogic_vector(0 to 5);
signal ex3_target_gpr           :std_ulogic_vector(0 to 8);
signal ex3_axu_op_val           :std_ulogic;
signal ex3_larx_instr           :std_ulogic;
signal ex3_mutex_hint           :std_ulogic;
signal ex3_stx_instr            :std_ulogic;
signal ex3_dcbt_instr           :std_ulogic;
signal ex3_dcbf_instr           :std_ulogic;
signal ex3_dcbtst_instr         :std_ulogic;
signal ex3_dcbst_instr          :std_ulogic;
signal ex3_dcbz_instr           :std_ulogic;
signal ex3_dcbi_instr           :std_ulogic;
signal ex3_icbi_instr           :std_ulogic;
signal ex3_icswx_instr          :std_ulogic;
signal ex3_icswx_dot            :std_ulogic;
signal ex3_icswx_epid           :std_ulogic;
signal ex3_sync_instr           :std_ulogic;
signal ex3_mtspr_trace          :std_ulogic;
signal ex3_byte_en              :std_ulogic_vector(0 to 31);
signal ex3_l_fld                :std_ulogic_vector(0 to 1);
signal ex3_mbar_instr           :std_ulogic;
signal ex3_msgsnd_instr         :std_ulogic;
signal ex3_dci_instr            :std_ulogic;
signal ex3_ici_instr            :std_ulogic;
signal ex3_flush_stg            :std_ulogic;
signal ex4_flush_stg            :std_ulogic;
signal ex3_algebraic_op         :std_ulogic;
signal ex3_dcbtls_instr         :std_ulogic;
signal ex3_dcbtstls_instr       :std_ulogic;
signal ex3_dcblc_instr          :std_ulogic;
signal ex3_icblc_instr          :std_ulogic;
signal ex3_icbt_instr           :std_ulogic;
signal ex3_icbtls_instr         :std_ulogic;
signal ex3_tlbsync_instr        :std_ulogic;
signal ex3_local_dcbf           :std_ulogic;
signal ex4_drop_rel             :std_ulogic;
signal ex3_load_l1hit           :std_ulogic;
signal ex3_rotate_sel           :std_ulogic_vector(0 to 4);
signal ex3_lock_en              :std_ulogic;
signal ex3_th_fld_l2            :std_ulogic;
signal cmp_flush                :std_ulogic;
signal cmp_ldq_fnd_b            :std_ulogic;
signal cmp_ldq_fnd              :std_ulogic;
signal ex1_src0_vld             :std_ulogic;
signal ex1_src0_reg             :std_ulogic_vector(0 to 7);
signal ex1_src1_vld             :std_ulogic;
signal ex1_src1_reg             :std_ulogic_vector(0 to 7);
signal ex1_targ_vld             :std_ulogic;
signal ex1_targ_reg             :std_ulogic_vector(0 to 7);
signal ex1_check_watch          :std_ulogic_vector(0 to 3);
signal ex2_lm_dep_hit           :std_ulogic;
signal ldq_rel1_val             :std_ulogic;
signal ldq_rel1_early_v         :std_ulogic;
signal ldq_rel_mid_val          :std_ulogic;
signal ldq_rel_retry_val        :std_ulogic;
signal ldq_rel3_val             :std_ulogic;
signal ldq_rel3_early_v         :std_ulogic;
signal ldq_rel_tag              :std_ulogic_vector(1 to 3);
signal ldq_rel_tag_early        :std_ulogic_vector(1 to 3);
signal ldq_rel_set_val          :std_ulogic;
signal ldq_rel_ecc_err          :std_ulogic;
signal ldq_rel_classid          :std_ulogic_vector(0 to 1);
signal ldq_rel_lock_en          :std_ulogic;
signal ldq_rel_watch_en         :std_ulogic;
signal rel_ldq_thrd_id          :std_ulogic_vector(0 to 3);         
signal ldq_rel_ta_gpr           :std_ulogic_vector(0 to 8);
signal ldq_rel_addr_early       :std_ulogic_vector(64-real_data_add to 63-cl_size);
signal ldq_rel_back_invalidated :std_ulogic;
signal ldq_recirc_rel_val       :std_ulogic;
signal ldq_rel_l1dump_cslc      :std_ulogic;
signal ldq_rel3_l1dump_val      :std_ulogic;
signal rel_ldq_ci               :std_ulogic;          
signal rel_ldq_upd_gpr          :std_ulogic;
signal rel_ldq_addr             :std_ulogic_vector(64-real_data_add to 58);
signal rel_ldq_axu_val          :std_ulogic;                        
signal is2_l2_inv_val           :std_ulogic;                        
signal is2_l2_inv_p_addr        :std_ulogic_vector(64-real_data_add to 63-cl_size);
signal l2_data_ecc_err_ue       :std_ulogic_vector(0 to 3);
signal gpr_ecc_err_flush_tid    :std_ulogic_vector(0 to 3);
signal dcpar_err_flush          :std_ulogic;
signal ex4_dir_perr_det         :std_ulogic_vector(0 to 0);
signal ex4_dir_multihit_det     :std_ulogic_vector(0 to 0);
signal ex4_n_lsu_ddmh_flush     :std_ulogic_vector(0 to 3);
signal dcachedir_parity         :std_ulogic_vector(0 to 0);
signal dcachedir_multihit       :std_ulogic_vector(0 to 0);
signal ex3_watch_en             :std_ulogic;
signal ex3_ld_queue_full        :std_ulogic;
signal ex3_stq_flush            :std_ulogic;
signal ex3_ig_flush             :std_ulogic;
signal ex3_cClass_collision     :std_ulogic;
signal ex3_cClass_collision_b   :std_ulogic;
signal derat_xu_ex2_vf          :std_ulogic;
signal derat_xu_ex2_miss        :std_ulogic_vector(0 to 3);
signal derat_xu_ex2_attr        :std_ulogic_vector(0 to 5); 
signal derat_xu_ex4_data        :std_ulogic_vector(64-(2**REGMODE) to 63);
signal derat_iu_barrier_done    :std_ulogic_vector(0 to 3);
signal derat_fir_par_err        :std_ulogic_vector(0 to 3);
signal derat_fir_multihit       :std_ulogic_vector(0 to 3);
signal xu_derat_epsc_wr         :std_ulogic_vector(0 to 3);
signal xu_derat_eplc_wr         :std_ulogic_vector(0 to 3);
signal xu_derat_eplc0_epr       :std_ulogic;
signal xu_derat_eplc0_eas       :std_ulogic;
signal xu_derat_eplc0_egs       :std_ulogic;
signal xu_derat_eplc0_elpid     :std_ulogic_vector(40 to 47);
signal xu_derat_eplc0_epid      :std_ulogic_vector(50 to 63);
signal xu_derat_eplc1_epr       :std_ulogic;
signal xu_derat_eplc1_eas       :std_ulogic;
signal xu_derat_eplc1_egs       :std_ulogic;
signal xu_derat_eplc1_elpid     :std_ulogic_vector(40 to 47);
signal xu_derat_eplc1_epid      :std_ulogic_vector(50 to 63);
signal xu_derat_eplc2_epr       :std_ulogic;
signal xu_derat_eplc2_eas       :std_ulogic;
signal xu_derat_eplc2_egs       :std_ulogic;
signal xu_derat_eplc2_elpid     :std_ulogic_vector(40 to 47);
signal xu_derat_eplc2_epid      :std_ulogic_vector(50 to 63);
signal xu_derat_eplc3_epr       :std_ulogic;
signal xu_derat_eplc3_eas       :std_ulogic;
signal xu_derat_eplc3_egs       :std_ulogic;
signal xu_derat_eplc3_elpid     :std_ulogic_vector(40 to 47);
signal xu_derat_eplc3_epid      :std_ulogic_vector(50 to 63);
signal xu_derat_epsc0_epr       :std_ulogic;
signal xu_derat_epsc0_eas       :std_ulogic;
signal xu_derat_epsc0_egs       :std_ulogic;
signal xu_derat_epsc0_elpid     :std_ulogic_vector(40 to 47);
signal xu_derat_epsc0_epid      :std_ulogic_vector(50 to 63);
signal xu_derat_epsc1_epr       :std_ulogic;
signal xu_derat_epsc1_eas       :std_ulogic;
signal xu_derat_epsc1_egs       :std_ulogic;
signal xu_derat_epsc1_elpid     :std_ulogic_vector(40 to 47);
signal xu_derat_epsc1_epid      :std_ulogic_vector(50 to 63);
signal xu_derat_epsc2_epr       :std_ulogic;
signal xu_derat_epsc2_eas       :std_ulogic;
signal xu_derat_epsc2_egs       :std_ulogic;
signal xu_derat_epsc2_elpid     :std_ulogic_vector(40 to 47);
signal xu_derat_epsc2_epid      :std_ulogic_vector(50 to 63);
signal xu_derat_epsc3_epr       :std_ulogic;
signal xu_derat_epsc3_eas       :std_ulogic;
signal xu_derat_epsc3_egs       :std_ulogic;
signal xu_derat_epsc3_elpid     :std_ulogic_vector(40 to 47);
signal xu_derat_epsc3_epid      :std_ulogic_vector(50 to 63);
signal derat_xu_ex2_rpn         :std_ulogic_vector(22 to 51); -- derat 32x143 update to 42b RA
signal derat_xu_ex2_wimge       :std_ulogic_vector(0 to 4);
signal derat_xu_ex2_u           :std_ulogic_vector(0 to 3);
signal derat_xu_ex2_wlc         :std_ulogic_vector(0 to 1);
signal xu_derat_ex1_epn_arr     :std_ulogic_vector(64-(2**regmode) to 51);
signal xu_derat_ex1_epn_nonarr  :std_ulogic_vector(64-(2**regmode) to 51);
signal snoop_addr               :std_ulogic_vector(64-(2**regmode) to 51);
signal snoop_addr_sel           :std_ulogic;
signal lsu_perf_events          :std_ulogic_vector(0 to 46);
signal ex1_stg_act              :std_ulogic;
signal ex2_stg_act              :std_ulogic;
signal ex3_stg_act              :std_ulogic;
signal ex4_stg_act              :std_ulogic;
signal binv1_stg_act            :std_ulogic;
signal binv2_stg_act            :std_ulogic;
signal binv2_ex2_stg_act        :std_ulogic;
signal lsu_xu_sync_barr_done    :std_ulogic_vector(0 to 3);
signal bcfg_scan_out_int        :std_ulogic;
signal ccfg_scan_out_int        :std_ulogic;
signal dcfg_scan_out_int        :std_ulogic;
signal abist_siv                :std_ulogic_vector(0 to 23);
signal abist_sov                :std_ulogic_vector(0 to 23);
signal rel_data_val             :std_ulogic;
signal rel_data_val_early       :std_ulogic;
signal dir_arr_rd_addr_01       :std_ulogic_vector(64-(dc_size-3) to 63-cl_size);
signal dir_arr_rd_addr_23       :std_ulogic_vector(64-(dc_size-3) to 63-cl_size);
signal dir_arr_rd_addr_45       :std_ulogic_vector(64-(dc_size-3) to 63-cl_size);
signal dir_arr_rd_addr_67       :std_ulogic_vector(64-(dc_size-3) to 63-cl_size);
signal dir_arr_rd_data          :std_ulogic_vector(0 to 8*wayDataSize-1);
signal dir_wr_enable            :std_ulogic_vector(0 to 3);
signal dir_wr_way               :std_ulogic_vector(0 to 7);
signal dir_arr_wr_addr          :std_ulogic_vector(64-(dc_size-3) to 63-cl_size);
signal dir_arr_wr_data          :std_ulogic_vector(64-real_data_add to 64-real_data_add+wayDataSize-1);
signal abst_slp_sl_thold_1      :std_ulogic;
signal time_sl_thold_1          :std_ulogic;
signal ary_slp_nsl_thold_1      :std_ulogic;
signal repr_sl_thold_1          :std_ulogic;
signal regf_slp_sl_thold_1      :std_ulogic;
signal func_slp_nsl_thold_1     :std_ulogic;
signal abst_slp_sl_thold_0      :std_ulogic;
signal time_sl_thold_0          :std_ulogic;
signal ary_slp_nsl_thold_0      :std_ulogic;
signal repr_sl_thold_0          :std_ulogic;
signal regf_slp_sl_thold_0      :std_ulogic;
signal func_slp_nsl_thold_0     :std_ulogic;
signal abst_slp_sl_thold_0_b    :std_ulogic;
signal abst_slp_sl_force        :std_ulogic;
signal abst_scan_in_q           :std_ulogic;
signal abst_scan_out_int        :std_ulogic;
signal abst_scan_out_q          :std_ulogic;
signal time_scan_in_q           :std_ulogic;
signal time_scan_out_int        :std_ulogic_vector(0 to 1);
signal time_scan_out_q          :std_ulogic;
signal repr_scan_in_q           :std_ulogic;
signal repr_scan_out_int        :std_ulogic;
signal repr_scan_out_q          :std_ulogic;
signal func_scan_in_q           :std_ulogic_vector(41 to 49);
signal func_scan_out_int        :std_ulogic_vector(41 to 49);
signal func_scan_out_q          :std_ulogic_vector(41 to 49);
signal regf_scan_in_q           :std_ulogic_vector(0 to 6);
signal regf_scan_out_int        :std_ulogic_vector(0 to 6);
signal regf_scan_out_q          :std_ulogic_vector(0 to 6);
signal derat_scan_out           :std_ulogic_vector(0 to 1);
signal dir_scan_out             :std_ulogic_vector(0 to 1);
signal cmp_scan_out             :std_ulogic;
signal l2cmdq_scan_out          :std_ulogic;
signal tidn                     :std_ulogic;
signal func_slp_sl_thold_1      :std_ulogic;
signal func_sl_thold_1          :std_ulogic;
signal func_nsl_thold_1         :std_ulogic;
signal cfg_slp_sl_thold_1       :std_ulogic;
signal sg_1                     :std_ulogic;
signal fce_1                    :std_ulogic;
signal bolt_sl_thold_1          :std_ulogic;
signal func_slp_sl_thold_0      :std_ulogic;
signal func_sl_thold_0          :std_ulogic;
signal func_nsl_thold_0         :std_ulogic;
signal cfg_slp_sl_thold_0       :std_ulogic;
signal sg_0                     :std_ulogic;
signal fce_0                    :std_ulogic;
signal bolt_sl_thold_0          :std_ulogic;
signal func_sl_force            :std_ulogic;
signal func_sl_thold_0_b        :std_ulogic;
signal func_nsl_force           :std_ulogic;
signal func_nsl_thold_0_b       :std_ulogic;
signal cfg_slp_sl_force         :std_ulogic;
signal cfg_slp_sl_thold_0_b     :std_ulogic;
signal func_slp_sl_force        :std_ulogic;
signal func_slp_sl_thold_0_b    :std_ulogic;
signal func_slp_nsl_force       :std_ulogic;
signal func_slp_nsl_thold_0_b   :std_ulogic;
signal pc_xu_abist_g8t_wenb_q   :std_ulogic;
signal pc_xu_abist_g8t1p_renb_0_q :std_ulogic;
signal pc_xu_abist_di_0_q       :std_ulogic_vector(0 to 3);
signal pc_xu_abist_g8t_bw_1_q   :std_ulogic;
signal pc_xu_abist_g8t_bw_0_q   :std_ulogic;
signal pc_xu_abist_waddr_0_q    :std_ulogic_vector(0 to 4);
signal pc_xu_abist_raddr_0_q    :std_ulogic_vector(0 to 4);
signal pc_xu_abist_wl32_comp_ena_q :std_ulogic;
signal pc_xu_abist_g8t_dcomp_q  :std_ulogic_vector(0 to 3);
signal slat_force               :std_ulogic;
signal abst_slat_thold_b        :std_ulogic;
signal abst_slat_d2clk          :std_ulogic;
signal abst_slat_lclk           :clk_logic;
signal time_slat_thold_b        :std_ulogic;
signal time_slat_d2clk          :std_ulogic;
signal time_slat_lclk           :clk_logic;
signal repr_slat_thold_b        :std_ulogic;
signal repr_slat_d2clk          :std_ulogic;
signal repr_slat_lclk           :clk_logic;
signal func_slat_thold_b        :std_ulogic;
signal func_slat_d2clk          :std_ulogic;
signal func_slat_lclk           :clk_logic;
signal regf_slat_thold_b        :std_ulogic;
signal regf_slat_d2clk          :std_ulogic;
signal regf_slat_lclk           :clk_logic;
signal lmq_pe_recov_state       :std_ulogic;
signal lmq_dbg_dcache_pe        :std_ulogic_vector(1 to 60);
signal lmq_dbg_l2req            :std_ulogic_vector(0 to 212);
signal lmq_dbg_rel              :std_ulogic_vector(0 to 140);
signal lmq_dbg_binv             :std_ulogic_vector(0 to 44);
signal lmq_dbg_pops             :std_ulogic_vector(0 to 5);
signal lmq_dbg_grp0             :std_ulogic_vector(0 to 81);
signal lmq_dbg_grp1             :std_ulogic_vector(0 to 81);
signal lmq_dbg_grp2             :std_ulogic_vector(0 to 87);
signal lmq_dbg_grp3             :std_ulogic_vector(0 to 87);
signal lmq_dbg_grp4             :std_ulogic_vector(0 to 87);
signal lmq_dbg_grp5             :std_ulogic_vector(0 to 87);
signal lmq_dbg_grp6             :std_ulogic_vector(0 to 87);

signal spr_xucr0_cls            :std_ulogic;
signal ex3_data_swap_int        :std_ulogic;
signal ex3_blkable_touch        :std_ulogic;
signal ex7_targ_match           :std_ulogic;
signal ex8_targ_match           :std_ulogic;
signal ex4_ld_entry             :std_ulogic_vector(0 to 67);
signal ex2_wayA_tag             :std_ulogic_vector(64-real_data_add to 63-(dc_size-3));
signal ex2_wayB_tag             :std_ulogic_vector(64-real_data_add to 63-(dc_size-3));
signal ex2_wayC_tag             :std_ulogic_vector(64-real_data_add to 63-(dc_size-3));
signal ex2_wayD_tag             :std_ulogic_vector(64-real_data_add to 63-(dc_size-3));
signal ex2_wayE_tag             :std_ulogic_vector(64-real_data_add to 63-(dc_size-3));
signal ex2_wayF_tag             :std_ulogic_vector(64-real_data_add to 63-(dc_size-3));
signal ex2_wayG_tag             :std_ulogic_vector(64-real_data_add to 63-(dc_size-3));
signal ex2_wayH_tag             :std_ulogic_vector(64-real_data_add to 63-(dc_size-3));
signal ex3_cClass_upd_way_a     :std_ulogic;
signal ex3_cClass_upd_way_b     :std_ulogic;
signal ex3_cClass_upd_way_c     :std_ulogic;
signal ex3_cClass_upd_way_d     :std_ulogic;
signal ex3_cClass_upd_way_e     :std_ulogic;
signal ex3_cClass_upd_way_f     :std_ulogic; 
signal ex3_cClass_upd_way_g     :std_ulogic;
signal ex3_cClass_upd_way_h     :std_ulogic;
signal ex3_way_cmp_a            :std_ulogic;
signal ex3_way_cmp_b            :std_ulogic;
signal ex3_way_cmp_c            :std_ulogic;
signal ex3_way_cmp_d            :std_ulogic;
signal ex3_way_cmp_e            :std_ulogic;
signal ex3_way_cmp_f            :std_ulogic;
signal ex3_way_cmp_g            :std_ulogic;
signal ex3_way_cmp_h            :std_ulogic;
signal cmp_lmq_entry_act        :std_ulogic; -- act for lmq entries
signal cmp_ldq_comp_val         :std_ulogic_vector(0 to 7); -- enable compares against lmq
signal cmp_ldq_match            :std_ulogic_vector(0 to 7); -- compare result (without enable)
signal cmp_l_q_wrt_en           :std_ulogic_vector(0 to 7);   -- load entry, (hold when not loading)
signal cmp_ld_ex7_recov         :std_ulogic;
signal cmp_ex3_p_addr_o         :std_ulogic_vector(22 to 57);
signal cmp_ex7_ld_recov_addr    :std_ulogic_vector(64-real_data_add to 57); 
signal cmp_ex4_loadmiss_qentry  :std_ulogic_vector(0 to 7);   -- mux 3 select
signal cmp_ex4_ld_addr          :std_ulogic_vector(64-real_data_add to 57); -- mux 3
signal cmp_l_q_rd_en            :std_ulogic_vector(0 to 7);   -- mux 2 select
signal cmp_l_miss_entry_addr    :std_ulogic_vector(64-real_data_add to 57); -- mux 2
signal cmp_rel_tag_1hot         :std_ulogic_vector(0 to 7);   -- mux 1 select
signal cmp_rel_addr             :std_ulogic_vector(64-real_data_add to 57); -- mux 1
signal cmp_back_inv_addr        :std_ulogic_vector(64-real_data_add to 57); -- compare to each ldq entry
signal cmp_back_inv_cmp_val     :std_ulogic_vector(0 to 7);   --
signal cmp_back_inv_addr_hit    :std_ulogic_vector(0 to 7);   --
signal cmp_s_m_queue0_addr      :std_ulogic_vector(64-real_data_add to 57); --
signal cmp_st_entry0_val        :std_ulogic                 ; --
signal cmp_ex3addr_hit_stq      :std_ulogic                 ; --
signal cmp_ex4_st_entry_addr    :std_ulogic_vector(64-real_data_add to 57); --
signal cmp_ex4_st_val           :std_ulogic                 ; --
signal cmp_ex3addr_hit_ex4st    :std_ulogic                 ; --
signal dir_rd_stg_act           :std_ulogic;
signal xu_derat_rf1_binv_val    :std_ulogic;
signal derat_xu_ex3_rpn         :std_ulogic_vector(64-real_data_add to 51);
signal derat_xu_ex3_wimge       :std_ulogic_vector(0 to 4);
signal derat_xu_ex3_u           :std_ulogic_vector(0 to 3);
signal derat_xu_ex3_wlc         :std_ulogic_vector(0 to 1);
signal derat_xu_ex3_attr        :std_ulogic_vector(0 to 5);
signal derat_xu_ex3_vf          :std_ulogic;
signal derat_xu_ex3_noop_touch  :std_ulogic_vector(0 to 3);
signal dir_arr_rd_is2_val       :std_ulogic;
signal dir_arr_rd_congr_cl      :std_ulogic_vector(0 to 4);
signal is2_back_inv_addr        :std_ulogic_vector(64-real_data_add to 63-cl_size);
signal ex3_wayA_tag             :std_ulogic_vector(64-real_data_add to 63-(dc_size-3)); -- Way Tag
signal ex3_wayB_tag             :std_ulogic_vector(64-real_data_add to 63-(dc_size-3)); -- Way Tag
signal ex3_wayC_tag             :std_ulogic_vector(64-real_data_add to 63-(dc_size-3)); -- Way Tag
signal ex3_wayD_tag             :std_ulogic_vector(64-real_data_add to 63-(dc_size-3)); -- Way Tag
signal ex3_wayE_tag             :std_ulogic_vector(64-real_data_add to 63-(dc_size-3)); -- Way Tag
signal ex3_wayF_tag             :std_ulogic_vector(64-real_data_add to 63-(dc_size-3)); -- Way Tag
signal ex3_wayG_tag             :std_ulogic_vector(64-real_data_add to 63-(dc_size-3)); -- Way Tag
signal ex3_wayH_tag             :std_ulogic_vector(64-real_data_add to 63-(dc_size-3)); -- Way Tag
signal dc_fgen_dbg_data         :std_ulogic_vector(0 to 1);
signal dc_cntrl_dbg_data        :std_ulogic_vector(0 to 66);
signal dc_val_dbg_data          :std_ulogic_vector(0 to 293);
signal dc_lru_dbg_data          :std_ulogic_vector(0 to 81);
signal dc_dir_dbg_data          :std_ulogic_vector(0 to 35);
signal dir_arr_dbg_data         :std_ulogic_vector(0 to 60);
signal pe_recov_begin           :std_ulogic;
signal derat_xu_debug_group0    :std_ulogic_vector(0 to 87);
signal derat_xu_debug_group1    :std_ulogic_vector(0 to 87);

begin

tidn <= '0';

-- XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
-- L1 Data ERAT's
-- Data Erat/uTLB (Memory Management)
-- 1) Contains a Cam of Memory Management Entries
-- 2) Includes an MMU mode and a TLB mode
-- 3) Translates Effective Address to a Real Address
-- 3) Outputs a Real Address, Memory Attribute Bits, and User Defined Bits
-- XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
lsuderat : entity work.xuq_lsu_derat(xuq_lsu_derat)
generic map( expand_type        => expand_type,
             rs_data_width      => (2**regmode),
             data_out_width     => (2**regmode),
             epn_width          => (2**regmode)-12,
             bcfg_epn_0to15     => bcfg_epn_0to15,
             bcfg_epn_16to31    => bcfg_epn_16to31,
             bcfg_epn_32to47    => bcfg_epn_32to47,
             bcfg_epn_48to51    => bcfg_epn_48to51,
             bcfg_rpn_22to31    => bcfg_rpn_22to31,
             bcfg_rpn_32to47    => bcfg_rpn_32to47,
             bcfg_rpn_48to51    => bcfg_rpn_48to51)
port map(
     vdd                        => vdd,
     gnd                        => gnd,
     vcs                        => vcs,
     nclk                       => nclk,
     pc_xu_init_reset           => pc_xu_init_reset,
     pc_xu_ccflush_dc           => pc_xu_ccflush_dc,
     tc_scan_dis_dc_b           => an_ac_scan_dis_dc_b,
     tc_scan_diag_dc            => an_ac_scan_diag_dc,
     tc_lbist_en_dc             => an_ac_lbist_en_dc,
     an_ac_atpg_en_dc           => an_ac_atpg_en_dc,
     an_ac_grffence_en_dc       => an_ac_grffence_en_dc,
     
     lcb_d_mode_dc              => d_mode_dc,
     lcb_clkoff_dc_b            => clkoff_dc_b,
     lcb_act_dis_dc             => tidn,
     lcb_mpw1_dc_b              => mpw1_dc_b,
     lcb_mpw2_dc_b              => mpw2_dc_b,
     lcb_delay_lclkr_dc         => delay_lclkr_dc,
     
     pc_func_sl_thold_2         => func_sl_thold_2(2),
     pc_func_slp_sl_thold_2     => func_slp_sl_thold_2,
     pc_func_slp_nsl_thold_2    => func_slp_nsl_thold_2,
     pc_cfg_slp_sl_thold_2      => cfg_slp_sl_thold_2,
     pc_regf_slp_sl_thold_2     => regf_slp_sl_thold_2,
     pc_time_sl_thold_2         => time_sl_thold_2,
     pc_sg_2                    => sg_2(2),
     pc_fce_2                   => fce_2,

     cam_clkoff_dc_b            => cam_clkoff_dc_b,
     cam_act_dis_dc             => cam_act_dis_dc,
     cam_d_mode_dc              => cam_d_mode_dc,
     cam_delay_lclkr_dc         => cam_delay_lclkr_dc,
     cam_mpw1_dc_b              => cam_mpw1_dc_b,
     cam_mpw2_dc_b              => cam_mpw2_dc_b,
     

     ac_func_scan_in            => func_scan_in_q(41 to 42),    -- use func_scan_in_q(1) for expansion
     ac_func_scan_out           => derat_scan_out,
     ac_ccfg_scan_in            => ccfg_scan_in,
     ac_ccfg_scan_out           => ccfg_scan_out_int,
     time_scan_in               => time_scan_out_int(0),
     time_scan_out              => time_scan_out_int(1),

     regf_scan_in               => regf_scan_in_q,
     regf_scan_out              => regf_scan_out_int,

     spr_xucr4_mmu_mchk         => spr_xucr4_mmu_mchk,  
     spr_xucr0_clkg_ctl_b1      => spr_xucr0_clkg_ctl_b1,
     xu_derat_rf0_val           => xu_lsu_rf0_derat_val,
     xu_derat_rf1_act           => xu_lsu_rf1_derat_act,
     xu_derat_rf1_ra_eq_ea      => xu_lsu_rf1_derat_ra_eq_ea,
     xu_derat_rf1_is_load       => xu_lsu_rf1_derat_is_load,
     xu_derat_rf1_is_store      => xu_lsu_rf1_derat_is_store,
     xu_derat_rf1_is_eratre     => xu_lsu_rf1_is_eratre,
     xu_derat_rf1_is_eratwe     => xu_lsu_rf1_is_eratwe,
     xu_derat_rf1_is_eratsx     => xu_lsu_rf1_is_eratsx,
     xu_derat_rf1_is_eratilx    => xu_lsu_rf1_is_eratilx,
     xu_derat_ex1_is_isync      => xu_lsu_ex1_is_isync,
     xu_derat_ex1_is_csync      => xu_lsu_ex1_is_csync,
     xu_derat_rf1_is_touch      => xu_lsu_rf1_is_touch,
     xu_derat_rf1_icbtls_instr  => xu_lsu_rf1_icbtls_instr,
     xu_derat_rf1_icblc_instr   => xu_lsu_rf1_icblc_instr,
     xu_derat_rf0_is_extload    => xu_lsu_rf0_derat_is_extload,
     xu_derat_rf0_is_extstore   => xu_lsu_rf0_derat_is_extstore,
     xu_derat_rf1_ws            => xu_lsu_rf1_ws,
     xu_derat_rf1_t             => xu_lsu_rf1_t,
     xu_derat_rf1_binv_val      => xu_derat_rf1_binv_val,
     xu_derat_ex1_rs_is         => xu_lsu_ex1_rs_is,
     xu_derat_ex1_ra_entry      => xu_lsu_ex1_ra_entry,
     xu_derat_ex1_epn_arr       => xu_derat_ex1_epn_arr,
     xu_derat_ex1_epn_nonarr    => xu_derat_ex1_epn_nonarr,
     snoop_addr                 => snoop_addr,
     snoop_addr_sel             => snoop_addr_sel,
     xu_derat_rf0_n_flush       => xu_lsu_rf0_flush,
     xu_derat_rf1_n_flush       => xu_lsu_rf1_flush,
     xu_derat_ex1_n_flush       => xu_lsu_ex1_flush,
     xu_derat_ex2_n_flush       => xu_lsu_ex2_flush,
     xu_derat_ex3_n_flush       => xu_lsu_ex3_flush,
     xu_derat_ex4_n_flush       => xu_lsu_ex4_flush,
     xu_derat_ex5_n_flush       => xu_lsu_ex5_flush,
     xu_derat_ex4_rs_data       => xu_lsu_ex4_rs_data,
     xu_derat_msr_hv            => xu_lsu_msr_gs,
     xu_derat_msr_pr            => xu_lsu_msr_pr,
     xu_derat_msr_ds            => xu_lsu_msr_ds,
     xu_derat_msr_cm            => xu_lsu_msr_cm,
     xu_derat_hid_mmu_mode      => xu_lsu_hid_mmu_mode,
     xu_derat_spr_ccr2_dfrat    => xu_lsu_spr_ccr2_dfrat,
     xu_derat_spr_ccr2_dfratsc  => xu_lsu_spr_ccr2_dfratsc,

     derat_xu_ex2_miss          => derat_xu_ex2_miss,
     derat_xu_ex2_rpn           => derat_xu_ex2_rpn,
     derat_xu_ex2_wimge         => derat_xu_ex2_wimge,
     derat_xu_ex2_u             => derat_xu_ex2_u,
     derat_xu_ex2_wlc           => derat_xu_ex2_wlc,
     derat_xu_ex2_attr          => derat_xu_ex2_attr,
     derat_xu_ex2_vf            => derat_xu_ex2_vf,

     derat_xu_ex3_rpn           => derat_xu_ex3_rpn,
     derat_xu_ex3_wimge         => derat_xu_ex3_wimge,
     derat_xu_ex3_u             => derat_xu_ex3_u,
     derat_xu_ex3_wlc           => derat_xu_ex3_wlc,
     derat_xu_ex3_attr          => derat_xu_ex3_attr,
     derat_xu_ex3_vf            => derat_xu_ex3_vf,
     derat_xu_ex3_miss          => derat_xu_ex3_miss,
     derat_xu_ex3_dsi           => derat_xu_ex3_dsi,
     derat_xu_ex3_multihit_err  => lsu_xu_ex3_derat_multihit_err,
     derat_xu_ex3_noop_touch    => derat_xu_ex3_noop_touch,
     derat_xu_ex3_par_err       => lsu_xu_ex3_derat_par_err,

     derat_xu_ex3_n_flush_req   => derat_xu_ex3_n_flush_req,
     derat_xu_ex4_data          => derat_xu_ex4_data,
     derat_xu_ex4_par_err       => lsu_xu_ex4_derat_par_err,
     derat_iu_barrier_done      => derat_iu_barrier_done,
     derat_fir_par_err          => derat_fir_par_err,
     derat_fir_multihit         => derat_fir_multihit,
                                
     -- DERAT SlowSPR Regs
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

     xu_mm_derat_req            => xu_mm_derat_req,
     xu_mm_derat_thdid          => xu_mm_derat_thdid,
     xu_mm_derat_state          => xu_mm_derat_state,
     xu_mm_derat_tid            => xu_mm_derat_tid,
     xu_mm_derat_ttype          => xu_mm_derat_ttype,
     xu_mm_derat_lpid           => xu_mm_derat_lpid,

     mm_xu_derat_rel_val        => mm_xu_derat_rel_val,
     mm_xu_derat_rel_data       => mm_xu_derat_rel_data,

     mm_xu_derat_pid0           => mm_xu_derat_pid0,
     mm_xu_derat_pid1           => mm_xu_derat_pid1,
     mm_xu_derat_pid2           => mm_xu_derat_pid2,
     mm_xu_derat_pid3           => mm_xu_derat_pid3,

     mm_xu_derat_mmucr0_0       => mm_xu_derat_mmucr0_0,
     mm_xu_derat_mmucr0_1       => mm_xu_derat_mmucr0_1,
     mm_xu_derat_mmucr0_2       => mm_xu_derat_mmucr0_2,
     mm_xu_derat_mmucr0_3       => mm_xu_derat_mmucr0_3,
     xu_mm_derat_mmucr0         => xu_mm_derat_mmucr0,
     xu_mm_derat_mmucr0_we      => xu_mm_derat_mmucr0_we,
     mm_xu_derat_mmucr1         => mm_xu_derat_mmucr1,
     xu_mm_derat_mmucr1         => xu_mm_derat_mmucr1,
     xu_mm_derat_mmucr1_we      => xu_mm_derat_mmucr1_we,

     mm_xu_derat_snoop_coming   => mm_xu_derat_snoop_coming,
     mm_xu_derat_snoop_val      => mm_xu_derat_snoop_val,
     mm_xu_derat_snoop_attr     => mm_xu_derat_snoop_attr,
     mm_xu_derat_snoop_vpn      => mm_xu_derat_snoop_vpn,
     xu_mm_derat_snoop_ack      => xu_mm_derat_snoop_ack,
     
     pc_xu_trace_bus_enable     => pc_xu_trace_bus_enable,
     derat_xu_debug_group0      => derat_xu_debug_group0,
     derat_xu_debug_group1      => derat_xu_debug_group1,
     derat_xu_debug_group2      => lsu_xu_cmd_debug(0 to 87),
     derat_xu_debug_group3      => lsu_xu_cmd_debug(88 to 175)
);

lsu_xu_ex4_tlb_data <= derat_xu_ex4_data(64-(2**REGMODE) to 63);

-- XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
-- L1 Data Directory
-- XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
lsudir : entity work.xuq_lsu_dir(xuq_lsu_dir)
generic map(expand_type     => expand_type,
            l_endian_m      => l_endian_m,
            regmode         => regmode,
            lmq_entries     => lmq_entries,
            dc_size         => dc_size,
            cl_size         => cl_size,
            wayDataSize     => wayDataSize,
            real_data_add   => real_data_add)	
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
     xu_lsu_ex1_add_src0        => xu_lsu_ex1_add_src0,
     xu_lsu_ex1_add_src1        => xu_lsu_ex1_add_src1,
                                
     xu_lsu_rf1_src0_vld        => xu_lsu_rf1_src0_vld,
     xu_lsu_rf1_src0_reg        => xu_lsu_rf1_src0_reg,
     xu_lsu_rf1_src1_vld        => xu_lsu_rf1_src1_vld,
     xu_lsu_rf1_src1_reg        => xu_lsu_rf1_src1_reg,
     xu_lsu_rf1_targ_vld        => xu_lsu_rf1_targ_vld,
     xu_lsu_rf1_targ_reg        => xu_lsu_rf1_targ_reg,

     -- Error Inject
     pc_xu_inj_dcachedir_parity => pc_xu_inj_dcachedir_parity,
     pc_xu_inj_dcachedir_multihit => pc_xu_inj_dcachedir_multihit,

     ex3_wimge_w_bit            => derat_xu_ex3_wimge(0),
     ex3_wimge_i_bit            => derat_xu_ex3_wimge(1),
     ex3_wimge_e_bit            => derat_xu_ex3_wimge(4),
     ex3_p_addr                 => cmp_ex3_p_addr_o(64-real_data_add to 51),
     derat_xu_ex3_noop_touch    => derat_xu_ex3_noop_touch,
     ex3_ld_queue_full          => ex3_ld_queue_full,
     ex3_stq_flush              => ex3_stq_flush,
     ex3_ig_flush               => ex3_ig_flush,

     ex2_lm_dep_hit             => ex2_lm_dep_hit,

     ex3_way_cmp_a              => ex3_way_cmp_a,
     ex3_way_cmp_b              => ex3_way_cmp_b,
     ex3_way_cmp_c              => ex3_way_cmp_c,
     ex3_way_cmp_d              => ex3_way_cmp_d,
     ex3_way_cmp_e              => ex3_way_cmp_e,
     ex3_way_cmp_f              => ex3_way_cmp_f,
     ex3_way_cmp_g              => ex3_way_cmp_g,
     ex3_way_cmp_h              => ex3_way_cmp_h,

     ex3_wayA_tag               => ex3_wayA_tag,
     ex3_wayB_tag               => ex3_wayB_tag,
     ex3_wayC_tag               => ex3_wayC_tag,
     ex3_wayD_tag               => ex3_wayD_tag,
     ex3_wayE_tag               => ex3_wayE_tag,
     ex3_wayF_tag               => ex3_wayF_tag,
     ex3_wayG_tag               => ex3_wayG_tag,
     ex3_wayH_tag               => ex3_wayH_tag,

     xu_lsu_mtspr_trace_en      => xu_lsu_mtspr_trace_en,
     spr_xucr0_clkg_ctl_b1      => spr_xucr0_clkg_ctl_b1,
     xu_lsu_spr_xucr0_aflsta    => xu_lsu_spr_xucr0_aflsta,
     xu_lsu_spr_xucr0_flsta     => xu_lsu_spr_xucr0_flsta,
     xu_lsu_spr_xucr0_l2siw     => xu_lsu_spr_xucr0_l2siw,
     xu_lsu_spr_xucr0_dcdis     => xu_lsu_spr_xucr0_dcdis,
     xu_lsu_spr_xucr0_wlk       => xu_lsu_spr_xucr0_wlk,
     xu_lsu_spr_ccr2_dfrat      => xu_lsu_spr_ccr2_dfrat,
     xu_lsu_spr_xucr0_clfc      => xu_lsu_spr_xucr0_clfc,
     xu_lsu_spr_xucr0_flh2l2    => xu_lsu_spr_xucr0_flh2l2,
     xu_lsu_spr_xucr0_cls       => xu_lsu_spr_xucr0_cls,
     xu_lsu_spr_msr_cm          => xu_lsu_msr_cm,
     xu_lsu_msr_gs              => xu_lsu_msr_gs,
     xu_lsu_msr_pr              => xu_lsu_msr_pr,

     an_ac_flh2l2_gate          => an_ac_flh2l2_gate,

     ldq_rel1_early_v           => ldq_rel1_early_v,
     ldq_rel1_val               => ldq_rel1_val,
     ldq_rel_mid_val            => ldq_rel_mid_val,
     ldq_rel_retry_val          => ldq_rel_retry_val,
     ldq_rel3_early_v           => ldq_rel3_early_v,
     ldq_rel3_val               => ldq_rel3_val,
     ldq_rel_back_invalidated   => ldq_rel_back_invalidated,
     ldq_rel_data_val_early     => rel_data_val_early,
     rel_data_val               => rel_data_val,
     ldq_rel_tag                => ldq_rel_tag,
     ldq_rel_tag_early          => ldq_rel_tag_early,
     ldq_rel_set_val            => ldq_rel_set_val,
     ldq_rel_ecc_err            => ldq_rel_ecc_err,
     ldq_rel_classid            => ldq_rel_classid,
     ldq_rel_lock_en            => ldq_rel_lock_en,
     ldq_rel_l1dump_cslc        => ldq_rel_l1dump_cslc,
     ldq_rel3_l1dump_val        => ldq_rel3_l1dump_val,
     ldq_rel_watch_en           => ldq_rel_watch_en,
     ldq_rel_addr               => rel_ldq_addr(64-real_data_add to 52),
     ldq_rel_addr_early         => ldq_rel_addr_early,
     ldq_rel_axu_val            => rel_ldq_axu_val,
     ldq_rel_thrd_id            => rel_ldq_thrd_id,
     ldq_rel_ta_gpr             => ldq_rel_ta_gpr,
     ldq_rel_upd_gpr            => rel_ldq_upd_gpr,
     ldq_rel_ci                 => rel_ldq_ci,
     ldq_recirc_rel_val         => ldq_recirc_rel_val,
                                
     xu_lsu_dci                 => xu_lsu_dci,
                                
     is2_l2_inv_val             => is2_l2_inv_val,

     ex6_ld_par_err             => ex6_ld_par_err,

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
                                
     dir_arr_rd_addr_01         => dir_arr_rd_addr_01,
     dir_arr_rd_addr_23         => dir_arr_rd_addr_23,
     dir_arr_rd_addr_45         => dir_arr_rd_addr_45,
     dir_arr_rd_addr_67         => dir_arr_rd_addr_67,
     dir_arr_rd_data            => dir_arr_rd_data,
                                
     dir_wr_enable              => dir_wr_enable,
     dir_wr_way                 => dir_wr_way,
     dir_arr_wr_addr            => dir_arr_wr_addr,
     dir_arr_wr_data            => dir_arr_wr_data,
                                
     ex1_src0_vld               => ex1_src0_vld,
     ex1_src0_reg               => ex1_src0_reg,
     ex1_src1_vld               => ex1_src1_vld,
     ex1_src1_reg               => ex1_src1_reg,
     ex1_targ_vld               => ex1_targ_vld,
     ex1_targ_reg               => ex1_targ_reg,
     ex1_check_watch            => ex1_check_watch,

     xu_derat_ex1_epn_arr       => xu_derat_ex1_epn_arr,
     xu_derat_ex1_epn_nonarr    => xu_derat_ex1_epn_nonarr,
     snoop_addr                 => snoop_addr,
     snoop_addr_sel             => snoop_addr_sel,
     xu_derat_rf1_binv_val      => xu_derat_rf1_binv_val,
     ex3_cache_acc              => ex3_cache_acc,
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

     lsu_xu_ex3_align           => lsu_xu_ex3_align,
     lsu_xu_ex3_dsi             => lsu_xu_ex3_dsi,
     lsu_xu_ex3_inval_align_2ucode => lsu_xu_ex3_inval_align_2ucode,

     ex3_stg_flush              => ex3_flush_stg,
     ex4_stg_flush              => ex4_flush_stg,
     lsu_xu_ex3_n_flush_req     => lsu_xu_ex3_n_flush_req,
     lsu_xu_ex4_ldq_full_flush  => lsu_xu_ex4_ldq_full_flush,
     lsu_xu_ex3_dep_flush       => lsu_xu_ex3_dep_flush,

     ex2_p_addr_lwr             => ex2_p_addr_lwr,
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
     ex3_store_instr            => ex3_store_instr,
     ex3_axu_op_val             => ex3_axu_op_val,
     ex3_algebraic              => ex3_algebraic_op,
     ex3_dcbtls_instr           => ex3_dcbtls_instr,
     ex3_dcbtstls_instr         => ex3_dcbtstls_instr,
     ex3_dcblc_instr            => ex3_dcblc_instr,
     ex3_icblc_instr            => ex3_icblc_instr,
     ex3_icbt_instr             => ex3_icbt_instr,
     ex3_icbtls_instr           => ex3_icbtls_instr,
     ex3_tlbsync_instr          => ex3_tlbsync_instr,
     ex3_local_dcbf             => ex3_local_dcbf,
     ex3_lock_en                => ex3_lock_en,
     ex4_drop_rel               => ex4_drop_rel,
     ex3_load_l1hit             => ex3_load_l1hit,
     ex3_rotate_sel             => ex3_rotate_sel,
     ex3_watch_en               => ex3_watch_en,
     ex3_data_swap              => ex3_data_swap_int,
     ex3_blkable_touch          => ex3_blkable_touch,
     ex7_targ_match             => ex7_targ_match,
     ex8_targ_match             => ex8_targ_match,
     ex4_ld_entry               => ex4_ld_entry,
                                
     ex3_cache_inh              => ex3_cache_inh,
     ex3_l_s_q_val              => ex3_l_s_q_val,
     ex3_drop_ld_req            => ex3_drop_ld_req,
     ex3_drop_touch             => ex3_drop_touch,
     ex3_stx_instr              => ex3_stx_instr,
     ex3_larx_instr             => ex3_larx_instr,
     ex3_mutex_hint             => ex3_mutex_hint,
     ex3_opsize                 => ex3_opsize,
     ex4_dir_perr_det           => ex4_dir_perr_det(0),
     ex4_dir_multihit_det       => ex4_dir_multihit_det(0),
     ex4_n_lsu_ddmh_flush       => ex4_n_lsu_ddmh_flush,
                          
     dcpar_err_flush            => dcpar_err_flush,
     pe_recov_begin             => pe_recov_begin,

     lsu_xu_ex3_ddir_par_err    => lsu_xu_ex3_ddir_par_err,
     ex3_cClass_collision       => ex3_cClass_collision,

     ex3_cClass_upd_way_a       => ex3_cClass_upd_way_a,
     ex3_cClass_upd_way_b       => ex3_cClass_upd_way_b,
     ex3_cClass_upd_way_c       => ex3_cClass_upd_way_c,
     ex3_cClass_upd_way_d       => ex3_cClass_upd_way_d,
     ex3_cClass_upd_way_e       => ex3_cClass_upd_way_e,
     ex3_cClass_upd_way_f       => ex3_cClass_upd_way_f,
     ex3_cClass_upd_way_g       => ex3_cClass_upd_way_g,
     ex3_cClass_upd_way_h       => ex3_cClass_upd_way_h,

     -- Directory Read Data
     ex2_wayA_tag               => ex2_wayA_tag,
     ex2_wayB_tag               => ex2_wayB_tag,
     ex2_wayC_tag               => ex2_wayC_tag,
     ex2_wayD_tag               => ex2_wayD_tag,
     ex2_wayE_tag               => ex2_wayE_tag,
     ex2_wayF_tag               => ex2_wayF_tag,
     ex2_wayG_tag               => ex2_wayG_tag,
     ex2_wayH_tag               => ex2_wayH_tag,
                                
     -- Update Data Array Valid
     rel_upd_dcarr_val          => rel_upd_dcarr_val,

     lsu_xu_ex4_cr_upd          => lsu_xu_ex4_cr_upd,
     lsu_xu_ex5_cr_rslt         => lsu_xu_ex5_cr_rslt,                                
     lsu_xu_ex5_wren            => lsu_xu_ex5_wren,
     lsu_xu_rel_wren            => lsu_xu_rel_wren,
     lsu_xu_rel_ta_gpr          => lsu_xu_rel_ta_gpr,
     lsu_xu_perf_events         => lsu_perf_events(0 to 37),
     lsu_xu_need_hole           => lsu_xu_need_hole,
     xu_fu_ex5_reload_val       => xu_fu_ex5_reload_val,
     xu_fu_ex5_load_val         => xu_fu_ex5_load_val,
     xu_fu_ex5_load_tag         => xu_fu_ex5_load_tag,

     -- ICBI Interface
     xu_iu_ex6_icbi_val         => xu_iu_ex6_icbi_val,
     xu_iu_ex6_icbi_addr        => xu_iu_ex6_icbi_addr,

     dcarr_up_way_addr          => dcarr_up_way_addr,

     -- DERAT SlowSPR Regs
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

     -- ACT signals
     ex1_stg_act                => ex1_stg_act,
     ex2_stg_act                => ex2_stg_act,
     ex3_stg_act                => ex3_stg_act,
     ex4_stg_act                => ex4_stg_act,
     binv1_stg_act              => binv1_stg_act,
     binv2_stg_act              => binv2_stg_act,
                                
     -- SPR status
     lsu_xu_spr_xucr0_cslc_xuop => lsu_xu_spr_xucr0_cslc_xuop,
     lsu_xu_spr_xucr0_cslc_binv => lsu_xu_spr_xucr0_cslc_binv,
     lsu_xu_spr_xucr0_clo       => lsu_xu_spr_xucr0_clo,
     lsu_xu_spr_xucr0_cul       => lsu_xu_spr_xucr0_cul,
     spr_xucr0_cls              => spr_xucr0_cls,

     -- Directory Read interface
     dir_arr_rd_is2_val         => dir_arr_rd_is2_val,
     dir_arr_rd_congr_cl        => dir_arr_rd_congr_cl,
                                
     ex4_load_op_hit            => ex4_load_op_hit,
     ex4_store_hit              => ex4_store_hit,
     ex4_axu_op_val             => ex4_axu_op_val,
     spr_dvc1_act               => spr_dvc1_act,
     spr_dvc2_act               => spr_dvc2_act,
     spr_dvc1_dbg               => spr_dvc1_dbg,
     spr_dvc2_dbg               => spr_dvc2_dbg,

     -- Debug Data
     pc_xu_trace_bus_enable     => pc_xu_trace_bus_enable,
     dc_fgen_dbg_data           => dc_fgen_dbg_data,
     dc_cntrl_dbg_data          => dc_cntrl_dbg_data,
     dc_val_dbg_data            => dc_val_dbg_data,
     dc_lru_dbg_data            => dc_lru_dbg_data,
     dc_dir_dbg_data            => dc_dir_dbg_data,
     dir_arr_dbg_data           => dir_arr_dbg_data,

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
     delay_lclkr_dc             => delay_lclkr_dc(5),
     mpw1_dc_b                  => mpw1_dc_b(5),
     mpw2_dc_b                  => mpw2_dc_b,
     scan_in                    => func_scan_in_q(43 to 46),       -- use func_scan_in_q(4 to 5) for expansion
     scan_out(0 to 1)           => func_scan_out_int(43 to 44),
     scan_out(2 to 3)           => dir_scan_out
);

-- XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
-- Address Compares
-- XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

binv2_ex2_stg_act <= binv2_stg_act or ex2_stg_act;

 lsucmp: entity work.xuq_lsu_cmp(xuq_lsu_cmp)
generic map(expand_type     => expand_type)	
 port map(               
       vdd                                   => vdd                            ,--b--@--xuq_lsu_cmp(lsucmp)
       gnd                                   => gnd                            ,--b--@--xuq_lsu_cmp(lsucmp)
       nclk                                  => nclk                           ,--i--@--xuq_lsu_cmp(lsucmp)
       --------- seperate perv for sections located large distance apart ----------------------------------
       delay_lclkr (0)                       => delay_lclkr_dc(5)              ,--i--@--xuq_lsu_cmp(lsucmp)  for ERAT
       delay_lclkr (1)                       => delay_lclkr_dc(5)              ,--i--@--xuq_lsu_cmp(lsucmp)  for DIR
       delay_lclkr (2)                       => delay_lclkr_dc(5)              ,--i--@--xuq_lsu_cmp(lsucmp)  for LoadQ
       mpw1_b      (0)                       => mpw1_dc_b(5)                   ,--i--@--xuq_lsu_cmp(lsucmp)  for ERAT
       mpw1_b      (1)                       => mpw1_dc_b(5)                   ,--i--@--xuq_lsu_cmp(lsucmp)  for DIR
       mpw1_b      (2)                       => mpw1_dc_b(5)                   ,--i--@--xuq_lsu_cmp(lsucmp)  for LoadQ
       mpw2_b      (0)                       => mpw2_dc_b                      ,--i--@--xuq_lsu_cmp(lsucmp)  for ERAT
       mpw2_b      (1)                       => mpw2_dc_b                      ,--i--@--xuq_lsu_cmp(lsucmp)  for DIR
       mpw2_b      (2)                       => mpw2_dc_b                      ,--i--@--xuq_lsu_cmp(lsucmp)  for LoadQ
       forcee       (0)                       => func_slp_sl_force              ,--i--@--xuq_lsu_cmp(lsucmp)  for ERAT
       forcee       (1)                       => func_slp_sl_force              ,--i--@--xuq_lsu_cmp(lsucmp)  for DIR
       forcee       (2)                       => func_sl_force                  ,--i--@--xuq_lsu_cmp(lsucmp)  for LoadQ
       sg_0        (0)                       => sg_0                           ,--i--@--xuq_lsu_cmp(lsucmp)  for ERAT
       sg_0        (1)                       => sg_0                           ,--i--@--xuq_lsu_cmp(lsucmp)  for DIR
       sg_0        (2)                       => sg_0                           ,--i--@--xuq_lsu_cmp(lsucmp)  for LoadQ
       thold_0_b   (0)                       => func_slp_sl_thold_0_b          ,--i--@--xuq_lsu_cmp(lsucmp)  for ERAT
       thold_0_b   (1)                       => func_slp_sl_thold_0_b          ,--i--@--xuq_lsu_cmp(lsucmp)  for DIR
       thold_0_b   (2)                       => func_sl_thold_0_b              ,--i--@--xuq_lsu_cmp(lsucmp)  for LoadQ
       scan_in     (0)                       => derat_scan_out(0)              ,--i--@--xuq_lsu_cmp(lsucmp)  for ERAT
       scan_in     (1)                       => dir_scan_out(1)                ,--i--@--xuq_lsu_cmp(lsucmp)  for DIR
       scan_in     (2)                       => l2cmdq_scan_out                ,--i--@--xuq_lsu_cmp(lsucmp)  for LoadQ
       scan_out    (0)                       => func_scan_out_int(41)          ,--o--@--xuq_lsu_cmp(lsucmp)  for ERAT  (36) latches
       scan_out    (1)                       => cmp_scan_out                   ,--o--@--xuq_lsu_cmp(lsucmp)  for DIR   (30 * 8) latches
       scan_out    (2)                       => func_scan_out_int(47)          ,--o--@--xuq_lsu_cmp(lsucmp)  for LoadQ (36 * 8) latches
       -------------------------------------------------------------------------
       enable_lsb_lmq_b                      => spr_xucr0_cls,
       enable_lsb_oth_b                      => spr_xucr0_cls,
       enable_lsb_bi_b                       => spr_xucr0_cls,
       ex2_erat_act                          => binv2_ex2_stg_act              ,--i--@--xuq_lsu_cmp(lsucmp)  for LoadQ (6) latches
       binv2_ex2_stg_act                     => binv2_ex2_stg_act              ,--i--@--xuq_lsu_cmp(lsucmp)  for LoadQ (36 * 8) latches
       lmq_entry_act                         => cmp_lmq_entry_act              ,--i--@--xuq_lsu_cmp(lsucmp)  for LoadQ (36 * 8) latches
       ex3_p_addr                            => derat_xu_ex3_rpn               ,--i--@--xuq_lsu_cmp(lsucmp)
       ex2_p_addr_lwr                        => ex2_p_addr_lwr(52 to 57)       ,--i--@--xuq_lsu_cmp(lsucmp)
       ex3_p_addr_o                          => cmp_ex3_p_addr_o(22 to 57)     ,--i--@--xuq_lsu_cmp(lsucmp)
       ex2_wayA_tag(22 to 52)                => ex2_wayA_tag(22 to 52)         ,--i--@--xuq_lsu_cmp(lsucmp)
       ex2_wayB_tag(22 to 52)                => ex2_wayB_tag(22 to 52)         ,--i--@--xuq_lsu_cmp(lsucmp)
       ex2_wayC_tag(22 to 52)                => ex2_wayC_tag(22 to 52)         ,--i--@--xuq_lsu_cmp(lsucmp)
       ex2_wayD_tag(22 to 52)                => ex2_wayD_tag(22 to 52)         ,--i--@--xuq_lsu_cmp(lsucmp)
       ex2_wayE_tag(22 to 52)                => ex2_wayE_tag(22 to 52)         ,--i--@--xuq_lsu_cmp(lsucmp)
       ex2_wayF_tag(22 to 52)                => ex2_wayF_tag(22 to 52)         ,--i--@--xuq_lsu_cmp(lsucmp)
       ex2_wayG_tag(22 to 52)                => ex2_wayG_tag(22 to 52)         ,--i--@--xuq_lsu_cmp(lsucmp)
       ex2_wayH_tag(22 to 52)                => ex2_wayH_tag(22 to 52)         ,--i--@--xuq_lsu_cmp(lsucmp)
       ex3_cClass_upd_way_a                  => ex3_cClass_upd_way_a           ,--i--@--xuq_lsu_cmp(lsucmp)
       ex3_cClass_upd_way_b                  => ex3_cClass_upd_way_b           ,--i--@--xuq_lsu_cmp(lsucmp)
       ex3_cClass_upd_way_c                  => ex3_cClass_upd_way_c           ,--i--@--xuq_lsu_cmp(lsucmp)
       ex3_cClass_upd_way_d                  => ex3_cClass_upd_way_d           ,--i--@--xuq_lsu_cmp(lsucmp)
       ex3_cClass_upd_way_e                  => ex3_cClass_upd_way_e           ,--i--@--xuq_lsu_cmp(lsucmp)
       ex3_cClass_upd_way_f                  => ex3_cClass_upd_way_f           ,--i--@--xuq_lsu_cmp(lsucmp)
       ex3_cClass_upd_way_g                  => ex3_cClass_upd_way_g           ,--i--@--xuq_lsu_cmp(lsucmp)
       ex3_cClass_upd_way_h                  => ex3_cClass_upd_way_h           ,--i--@--xuq_lsu_cmp(lsucmp)
       ex3_way_cmp_a                         => ex3_way_cmp_a                  ,--o--@--xuq_lsu_cmp(lsucmp)
       ex3_way_cmp_b                         => ex3_way_cmp_b                  ,--o--@--xuq_lsu_cmp(lsucmp)
       ex3_way_cmp_c                         => ex3_way_cmp_c                  ,--o--@--xuq_lsu_cmp(lsucmp)
       ex3_way_cmp_d                         => ex3_way_cmp_d                  ,--o--@--xuq_lsu_cmp(lsucmp)
       ex3_way_cmp_e                         => ex3_way_cmp_e                  ,--o--@--xuq_lsu_cmp(lsucmp)
       ex3_way_cmp_f                         => ex3_way_cmp_f                  ,--o--@--xuq_lsu_cmp(lsucmp)
       ex3_way_cmp_g                         => ex3_way_cmp_g                  ,--o--@--xuq_lsu_cmp(lsucmp)
       ex3_way_cmp_h                         => ex3_way_cmp_h                  ,--o--@--xuq_lsu_cmp(lsucmp)
       ex3_wayA_tag                          => ex3_wayA_tag,
       ex3_wayB_tag                          => ex3_wayB_tag,
       ex3_wayC_tag                          => ex3_wayC_tag,
       ex3_wayD_tag                          => ex3_wayD_tag,
       ex3_wayE_tag                          => ex3_wayE_tag,
       ex3_wayF_tag                          => ex3_wayF_tag,
       ex3_wayG_tag                          => ex3_wayG_tag,
       ex3_wayH_tag                          => ex3_wayH_tag,

       ldq_comp_val(0 to 7)                  => cmp_ldq_comp_val(0 to 7)           ,--i--@--xuq_lsu_cmp(lsucmp)
       ldq_match(0 to 7)                     => cmp_ldq_match(0 to 7)              ,--o--@--xuq_lsu_cmp(lsucmp)
       ldq_fnd_b                             => cmp_ldq_fnd_b                      ,--o--@--xuq_lsu_cmp(lsucmp)
       cmp_flush                             => cmp_flush                      ,--o--@--xuq_lsu_cmp(lsucmp)
       dir_eq_v_or_b                         => ex3_cClass_collision_b           ,--o--@--xuq_lsu_cmp(lsucmp)
       l_q_wrt_en(0 to 7)                    => cmp_l_q_wrt_en(0 to 7)             ,--i--@--xuq_lsu_cmp(lsucmp)
       ld_ex7_recov                          => cmp_ld_ex7_recov       ,
       ex7_ld_recov_addr                     => cmp_ex7_ld_recov_addr  ,
       ex4_loadmiss_qentry(0 to 7)           => cmp_ex4_loadmiss_qentry(0 to 7)    ,--i--@--xuq_lsu_cmp(lsucmp)
       ex4_ld_addr(22 to 57)                 => cmp_ex4_ld_addr(22 to 57)          ,--o--@--xuq_lsu_cmp(lsucmp)
       l_q_rd_en(0 to 7)                     => cmp_l_q_rd_en(0 to 7)              ,--i--@--xuq_lsu_cmp(lsucmp)
       l_miss_entry_addr(22 to 57)           => cmp_l_miss_entry_addr(22 to 57)    ,--o--@--xuq_lsu_cmp(lsucmp)
       rel_tag_1hot(0 to 7)                  => cmp_rel_tag_1hot(0 to 7)           ,--i--@--xuq_lsu_cmp(lsucmp)
       rel_addr                              => cmp_rel_addr                       ,--o--@--xuq_lsu_cmp(lsucmp)
       back_inv_addr                         => cmp_back_inv_addr                  ,--i--@--xuq_lsu_cmp(lsucmp)
       back_inv_cmp_val(0 to 7)              => cmp_back_inv_cmp_val(0 to 7)       ,--i--@--xuq_lsu_cmp(lsucmp)
       back_inv_addr_hit(0 to 7)             => cmp_back_inv_addr_hit(0 to 7)      ,--o--@--xuq_lsu_cmp(lsucmp)
       s_m_queue0_addr(22 to 57)             => cmp_s_m_queue0_addr(22 to 57)      ,--i--@--xuq_lsu_cmp(lsucmp)
       st_entry0_val                         => cmp_st_entry0_val                  ,--i--@--xuq_lsu_cmp(lsucmp)
       ex3addr_hit_stq                       => cmp_ex3addr_hit_stq                ,--o--@--xuq_lsu_cmp(lsucmp)
       ex4_st_entry_addr(22 to 57)           => cmp_ex4_st_entry_addr(22 to 57)    ,--i--@--xuq_lsu_cmp(lsucmp)
       ex4_st_val                            => cmp_ex4_st_val                     ,--i--@--xuq_lsu_cmp(lsucmp)
       ex3addr_hit_ex4st                     => cmp_ex3addr_hit_ex4st               --o--@--xuq_lsu_cmp(lsucmp)
);

cmp_ldq_fnd          <= not cmp_ldq_fnd_b;
ex3_cClass_collision <= not ex3_cClass_collision_b;

-- XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
-- Data Cache Directory Array
-- XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

dir_rd_stg_act <= ex1_stg_act or binv1_stg_act;

dc16Kdir64B : if (2**dc_size) = 16384 and (2**cl_size) = 64 generate begin
  tridirarr: entity tri.tri_32x35_8w_1r1w(tri_32x35_8w_1r1w)
    GENERIC MAP (addressable_ports  => 32,                  -- number of addressable register in this array
                 addressbus_width   => 5,                   -- width of the bus to address all ports (2^portadrbus_width >= addressable_ports)
                 port_bitwidth      => wayDataSize,         -- bitwidth of ports
                 ways               => 8,                   -- number of ways
                 expand_type        => expand_type)         -- 0 = ibm (Umbra), 1 = non-ibm, 2 = ibm (MPG)
    PORT MAP(
             -- POWER PINS
             vcs                      => vcs,
             vdd                      => vdd,
             gnd                      => gnd,

             -- CLOCK AND CLOCKCONTROL PORTS
             nclk                     => nclk,
             rd0_act                  => dir_rd_stg_act,
             sg_0                     => sg_0,
             ary_slp_nsl_thold_0      => ary_slp_nsl_thold_0,
             abst_slp_sl_thold_0      => abst_slp_sl_thold_0,
             time_sl_thold_0          => time_sl_thold_0,
             repr_sl_thold_0          => repr_sl_thold_0,
             clkoff_dc_b              => g8t_clkoff_dc_b,
             ccflush_dc               => pc_xu_ccflush_dc,
             scan_dis_dc_b            => an_ac_scan_dis_dc_b,
             scan_diag_dc             => an_ac_scan_diag_dc,
             d_mode_dc                => g8t_d_mode_dc,
             mpw1_dc_b                => g8t_mpw1_dc_b,
             mpw2_dc_b                => g8t_mpw2_dc_b,
             delay_lclkr_dc           => g8t_delay_lclkr_dc,

             -- ABIST
             wr_abst_act              => pc_xu_abist_g8t_wenb_q,
             rd0_abst_act             => pc_xu_abist_g8t1p_renb_0_q,
             abist_di                 => pc_xu_abist_di_0_q,
             abist_bw_odd             => pc_xu_abist_g8t_bw_1_q,
             abist_bw_even            => pc_xu_abist_g8t_bw_0_q,
             abist_wr_adr             => pc_xu_abist_waddr_0_q,
             abist_rd0_adr            => pc_xu_abist_raddr_0_q,
             tc_lbist_ary_wrt_thru_dc => an_ac_lbist_ary_wrt_thru_dc,
             abist_ena_1              => pc_xu_abist_ena_dc,
             abist_g8t_rd0_comp_ena   => pc_xu_abist_wl32_comp_ena_q,
             abist_raw_dc_b           => pc_xu_abist_raw_dc_b,
             obs0_abist_cmp           => pc_xu_abist_g8t_dcomp_q,

             -- SCAN PORTS
             abst_scan_in             => abist_siv(0),
             time_scan_in             => time_scan_in_q,
             repr_scan_in             => repr_scan_in_q,
             abst_scan_out            => abist_sov(0),
             time_scan_out            => time_scan_out_int(0),
             repr_scan_out            => repr_scan_out_int,

             -- BOLT-ON
             lcb_bolt_sl_thold_0      => bolt_sl_thold_0,
             pc_bo_enable_2           => bo_enable_2,
             pc_bo_reset              => pc_xu_bo_reset,
             pc_bo_unload             => pc_xu_bo_unload,
             pc_bo_repair             => pc_xu_bo_repair,
             pc_bo_shdata             => pc_xu_bo_shdata,
             pc_bo_select             => pc_xu_bo_select,
             bo_pc_failout            => xu_pc_bo_fail,
             bo_pc_diagloop           => xu_pc_bo_diagout,
             tri_lcb_mpw1_dc_b        => mpw1_dc_b(5),
             tri_lcb_mpw2_dc_b        => mpw2_dc_b,
             tri_lcb_delay_lclkr_dc   => delay_lclkr_dc(5),
             tri_lcb_clkoff_dc_b      => clkoff_dc_b,
             tri_lcb_act_dis_dc       => tidn,

             -- PORTS
             write_enable             => dir_wr_enable,
             way                      => dir_wr_way,
             addr_wr                  => dir_arr_wr_addr,
             data_in                  => dir_arr_wr_data,
             -- Read Ports
             addr_rd_01               => dir_arr_rd_addr_01,
             addr_rd_23               => dir_arr_rd_addr_23,
             addr_rd_45               => dir_arr_rd_addr_45,
             addr_rd_67               => dir_arr_rd_addr_67,
             data_out                 => dir_arr_rd_data
   );
end generate dc16Kdir64B;

dc32Kdir64B : if (2**dc_size) = 32768 and (2**cl_size) = 64 generate begin
  tridirarr: entity tri.tri_32x35_8w_1r1w(tri_32x35_8w_1r1w)
    GENERIC MAP (addressable_ports  => 64,                  -- number of addressable register in this array
                 addressbus_width   => 6,                   -- width of the bus to address all ports (2^portadrbus_width >= addressable_ports)
                 port_bitwidth      => wayDataSize,         -- bitwidth of ports
                 ways               => 8,                   -- number of ways
                 expand_type        => expand_type)         -- 0 = ibm (Umbra), 1 = non-ibm, 2 = ibm (MPG)
    PORT MAP(
             -- POWER PINS
             vcs                      => vcs,
             vdd                      => vdd,
             gnd                      => gnd,

             -- CLOCK AND CLOCKCONTROL PORTS
             nclk                     => nclk,
             rd0_act                  => dir_rd_stg_act,
             sg_0                     => sg_0,
             ary_slp_nsl_thold_0      => ary_slp_nsl_thold_0,
             abst_slp_sl_thold_0      => abst_slp_sl_thold_0,
             time_sl_thold_0          => time_sl_thold_0,
             repr_sl_thold_0          => repr_sl_thold_0,
             clkoff_dc_b              => g8t_clkoff_dc_b,
             ccflush_dc               => pc_xu_ccflush_dc,
             scan_dis_dc_b            => an_ac_scan_dis_dc_b,
             scan_diag_dc             => an_ac_scan_diag_dc,
             d_mode_dc                => g8t_d_mode_dc,
             mpw1_dc_b                => g8t_mpw1_dc_b,
             mpw2_dc_b                => g8t_mpw2_dc_b,
             delay_lclkr_dc           => g8t_delay_lclkr_dc,

             -- ABIST
             wr_abst_act              => pc_xu_abist_g8t_wenb_q,
             rd0_abst_act             => pc_xu_abist_g8t1p_renb_0_q,
             abist_di                 => pc_xu_abist_di_0_q,
             abist_bw_odd             => pc_xu_abist_g8t_bw_1_q,
             abist_bw_even            => pc_xu_abist_g8t_bw_0_q,
             abist_wr_adr             => pc_xu_abist_waddr_0_q,
             abist_rd0_adr            => pc_xu_abist_raddr_0_q,
             tc_lbist_ary_wrt_thru_dc => an_ac_lbist_ary_wrt_thru_dc,
             abist_ena_1              => pc_xu_abist_ena_dc,
             abist_g8t_rd0_comp_ena   => pc_xu_abist_wl32_comp_ena_q,
             abist_raw_dc_b           => pc_xu_abist_raw_dc_b,
             obs0_abist_cmp           => pc_xu_abist_g8t_dcomp_q,

             -- SCAN PORTS
             abst_scan_in             => abist_siv(0),
             time_scan_in             => time_scan_in_q,
             repr_scan_in             => repr_scan_in_q,
             abst_scan_out            => abist_sov(0),
             time_scan_out            => time_scan_out_int(0),
             repr_scan_out            => repr_scan_out_int,

             -- BOLT-ON
             lcb_bolt_sl_thold_0      => bolt_sl_thold_0,
             pc_bo_enable_2           => bo_enable_2,
             pc_bo_reset              => pc_xu_bo_reset,
             pc_bo_unload             => pc_xu_bo_unload,
             pc_bo_repair             => pc_xu_bo_repair,
             pc_bo_shdata             => pc_xu_bo_shdata,
             pc_bo_select             => pc_xu_bo_select,
             bo_pc_failout            => xu_pc_bo_fail,
             bo_pc_diagloop           => xu_pc_bo_diagout,
             tri_lcb_mpw1_dc_b        => mpw1_dc_b(5),
             tri_lcb_mpw2_dc_b        => mpw2_dc_b,
             tri_lcb_delay_lclkr_dc   => delay_lclkr_dc(5),
             tri_lcb_clkoff_dc_b      => clkoff_dc_b,
             tri_lcb_act_dis_dc       => tidn,

             -- PORTS
             write_enable             => dir_wr_enable,
             way                      => dir_wr_way,
             addr_wr                  => dir_arr_wr_addr,
             data_in                  => dir_arr_wr_data,
             -- Read Ports
             addr_rd_01               => dir_arr_rd_addr_01,
             addr_rd_23               => dir_arr_rd_addr_23,
             addr_rd_45               => dir_arr_rd_addr_45,
             addr_rd_67               => dir_arr_rd_addr_67,
             data_out                 => dir_arr_rd_data
   );
end generate dc32Kdir64B;

-- XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
-- Load/Store Q
-- XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

-- LWARX
-- 1) Treated as a Load
-- 2) Should bypass the L1D$ and not load from the L1D$
-- 3) If hit in the L1 D$, L1 D$ should invalidate locally
-- 4) Should Reload into the L1D$
-- 5) Should update GPR when data is returned

-- STWCX
-- 1) Treated as a Store
-- 2) STWCX should bypass the L1D$ and not write to the L1D$
-- 3) If hit in the L1 D$, L1D$ should invalidate locally

-- DCBZ
-- 1) Treated as a Store
-- 2) Needs to Invalidate the L1 D$ if hit
-- 3) L2 will zero out the data in L2 Cache

-- DCBT
-- 1) Treated as a load
-- 2) Use the load command type
-- 3) Should Reload into the L1D$
-- 4) GPR should not be updated

-- DCBTST
-- 1) Treated as a load
-- 2) Acts like DCBT, but L2 behaves differently
-- 3) Use a DCBTST command type
-- 4) Should Reload into the L1D$
-- 5) GPR should not be updated

-- DCBF(l=0,1,2)
-- 1) If hit in the L1 D$, L1 D$ should invalidate locally
-- 2) l=0 => global dcbf, sent to the L2, L2 broadcasts to all cores if found in L2
--    a) Treated as a Store
--    b) Should not return data
-- 3) l=1 => local dcbf, FLush Cores L1, send to the L2, L2 does not back-invalidate other cores
--    a) Treated as a Store
--    b) Should not return data
-- 4) l=2 => local dcbf, not sent to the L2

-- DCBST
-- 1) Treated as a Store
-- 2) Dont do anything in the L1 D$, just send it down
-- 3) L2 will not back invalidate any cores

-- ICBI
-- 1) Treated as a Store
-- 2) Prism L2 treats it as a noop, Corona L2 will back-invalidate I$

-- PTE Update
-- 1) Treated as a Store
-- 2) Comes from the MMU

-- HW_SYNC (SYNC L=0)
-- 1) Treated as a Store
-- 2) will come down the pipe, if there is a outstanding load for that thread,
--    should flush sync hold flush until all the outstanding loads have returned
-- 3) L2 will send ACK back to IU

-- LW_SYNC (SYNC L=1)
-- 1) Treated as a Store
-- 2) will come down the pipe, if there is a outstanding load for that thread,
--    should flush sync and hold flush until all the outstanding loads have returned
-- 3) L2 will not send ACK back to IU, LD/STQ will ACK once sent to L2

-- EIEIO
-- 1) Treated as a Store
-- 2) will come down the pipe, if there is a outstanding load for that thread,
--    should flush eieio and hold flush until all the outstanding loads have returned
-- 3) L2 will not send ACK back to IU, LD/STQ will ACK once sent to L2

-- PTE_SYNC (SYNC L=2)
-- 1) Treated as a Store
-- 2) will act like a HW_SYNC
-- 3) L2 will acknowledge the PTE_SYNC

-- I=1 Load
-- 1) there can be many oustanding I=1 loads per thread if G=0
-- 2) need to flush other I=1 G=1 loads for that thread if one is outstanding in the loadmiss queue with I=1 G=1
-- 3) need to flush any command that hits the loadmiss queue and its an I=1 load

-- Signals that need to be driven
-- rel_type     | ldq_rel_val | ldq_rel_data_val | ldq_rel_upd_gpr
-- -------------|-------------|------------------|-----------------
-- dcbt/dcbtst  |     X       |        X         |
-- ci_load      |             |                  |        X
-- ce_load      |     X       |        X         |        X
-- lwarx        |     X       |        X         |        X

l2cmdq : entity work.xuq_lsu_l2cmdq(xuq_lsu_l2cmdq)
generic map(expand_type      => expand_type,
            lmq_entries      => lmq_entries,
            dc_size          => dc_size,
            cl_size          => cl_size,
            real_data_add    => real_data_add,
            a2mode           => a2mode,
            load_credits     => load_credits,
            store_credits    => store_credits,
            st_data_32B_mode => st_data_32B_mode)
PORT map(
     -- Load Miss/Store Operation Signals
     ex3_thrd_id                => ex3_req_thrd_id,
     ex3_l_s_q_val              => ex3_l_s_q_val,
     ex3_drop_ld_req            => ex3_drop_ld_req,
     ex3_drop_touch             => ex3_drop_touch,
     ex3_cache_inh              => ex3_cache_inh,
     ex3_load_instr             => ex3_load_instr,
     ex3_store_instr            => ex3_store_instr,
     ex3_cache_acc              => ex3_cache_acc,
     ex3_p_addr_lwr             => ex3_p_addr_lwr(58 to 63),
     ex3_opsize                 => ex3_opsize,
     ex3_rot_sel                => ex3_rotate_sel,
     ex3_byte_en                => ex3_byte_en,
     ex4_256st_data             => ex4_256st_data,
     ex3_target_gpr             => ex3_target_gpr,
     ex3_axu_op_val             => ex3_axu_op_val,
     ex3_le_mode                => ex3_data_swap_int,
     ex3_larx_instr             => ex3_larx_instr,
     ex3_mutex_hint             => ex3_mutex_hint,
     ex3_stx_instr              => ex3_stx_instr,
     ex3_dcbt_instr             => ex3_dcbt_instr,
     ex3_dcbf_instr             => ex3_dcbf_instr,
     ex3_dcbtst_instr           => ex3_dcbtst_instr,
     ex3_dcbst_instr            => ex3_dcbst_instr,
     ex3_dcbz_instr             => ex3_dcbz_instr,
     ex3_dcbi_instr             => ex3_dcbi_instr,
     ex3_icbi_instr             => ex3_icbi_instr,
     ex3_sync_instr             => ex3_sync_instr,
     ex3_mtspr_trace            => ex3_mtspr_trace,
     ex3_l_fld                  => ex3_l_fld,
     ex3_mbar_instr             => ex3_mbar_instr,
     ex3_wimge_bits             => derat_xu_ex3_wimge,
     ex3_usr_bits               => derat_xu_ex3_u,
     ex3_stg_flush              => ex3_flush_stg,
     ex4_stg_flush              => ex4_flush_stg,
     xu_lsu_ex5_flush           => xu_lsu_ex5_flush,
     ex3_byp_l1                 => '0',
     ex3_algebraic              => ex3_algebraic_op,
     xu_lsu_ex4_dvc1_en         => xu_lsu_ex4_dvc1_en,
     xu_lsu_ex4_dvc2_en         => xu_lsu_ex4_dvc2_en,
     ex3_dcbtls_instr           => ex3_dcbtls_instr,
     ex3_dcbtstls_instr         => ex3_dcbtstls_instr,
     ex3_dcblc_instr            => ex3_dcblc_instr,
     ex3_dci_instr              => ex3_dci_instr,
     ex3_ici_instr              => ex3_ici_instr,
     ex3_icblc_instr            => ex3_icblc_instr,
     ex3_icbt_instr             => ex3_icbt_instr,
     ex3_icbtls_instr           => ex3_icbtls_instr,
     ex3_tlbsync_instr          => ex3_tlbsync_instr,
     ex3_local_dcbf             => ex3_local_dcbf,
     ex3_icswx_instr            => ex3_icswx_instr,
     ex3_icswx_dot              => ex3_icswx_dot,
     ex3_icswx_epid             => ex3_icswx_epid,
     ex3_classid                => derat_xu_ex3_wlc,
     ex3_lock_en                => ex3_lock_en,
     ex3_th_fld_l2              => ex3_th_fld_l2,
     ex4_drop_rel               => ex4_drop_rel,
     ex3_load_l1hit             => ex3_load_l1hit,
     ex3_msgsnd_instr           => ex3_msgsnd_instr,
     ex3_watch_en               => ex3_watch_en,
     ex3_stg_act                => ex3_stg_act,
     ex4_stg_act                => ex4_stg_act,
     ex7_targ_match             => ex7_targ_match,
     ex8_targ_match             => ex8_targ_match,
     ex4_ld_entry               => ex4_ld_entry,

     xu_lsu_ex5_set_barr         => xu_lsu_ex5_set_barr,

     -- Dependency Checking on loadmisses
     ex1_src0_vld               => ex1_src0_vld,
     ex1_src0_reg               => ex1_src0_reg,
     ex1_src1_vld               => ex1_src1_vld,
     ex1_src1_reg               => ex1_src1_reg,
     ex1_targ_vld               => ex1_targ_vld,
     ex1_targ_reg               => ex1_targ_reg,
     ex1_check_watch            => ex1_check_watch,
     ex2_lm_dep_hit             => ex2_lm_dep_hit,
     
     -- load cmd in ex6 had a parity error, need to clear load in ex4
     ex6_ld_par_err             => ex6_ld_par_err,
     pe_recov_begin             => pe_recov_begin,
     
     -- inputs from L2
     an_ac_req_ld_pop           => an_ac_req_ld_pop,
     an_ac_req_st_pop           => an_ac_req_st_pop,
     an_ac_req_st_gather        => an_ac_req_st_gather,
     an_ac_req_st_pop_thrd      => an_ac_req_st_pop_thrd,

     an_ac_reld_data_val        => an_ac_reld_data_val,
     an_ac_reld_core_tag        => an_ac_reld_core_tag,
     an_ac_reld_qw              => an_ac_reld_qw,
     an_ac_reld_data            => an_ac_reld_data,
     an_ac_reld_ecc_err         => an_ac_reld_ecc_err,
     an_ac_reld_ecc_err_ue      => an_ac_reld_ecc_err_ue,
     an_ac_reld_data_coming     => an_ac_reld_data_coming,
     an_ac_reld_ditc            => an_ac_reld_ditc,
     an_ac_reld_crit_qw         => an_ac_reld_crit_qw,
     an_ac_reld_l1_dump         => an_ac_reld_l1_dump,

     an_ac_back_inv             => an_ac_back_inv,
     an_ac_back_inv_addr        => an_ac_back_inv_addr,
     an_ac_back_inv_target_bit1 => an_ac_back_inv_target_bit1,
     an_ac_back_inv_target_bit4 => an_ac_back_inv_target_bit4,
     an_ac_req_spare_ctrl_a1    => an_ac_req_spare_ctrl_a1,
                        
     an_ac_stcx_complete        => an_ac_stcx_complete,
     xu_iu_stcx_complete        => xu_iu_stcx_complete,
     xu_iu_reld_core_tag_clone    => xu_iu_reld_core_tag_clone,
     xu_iu_reld_data_coming_clone => xu_iu_reld_data_coming_clone,
     xu_iu_reld_data_vld_clone    => xu_iu_reld_data_vld_clone,
     xu_iu_reld_ditc_clone        => xu_iu_reld_ditc_clone,

     lsu_reld_data_vld          => lsu_reld_data_vld,
     lsu_reld_core_tag          => lsu_reld_core_tag,
     lsu_reld_qw                => lsu_reld_qw      ,
     lsu_reld_ecc_err           => lsu_reld_ecc_err,
     lsu_reld_ditc              => lsu_reld_ditc,
     lsu_reld_data              => lsu_reld_data,
     lsu_req_st_pop             => lsu_req_st_pop,
     lsu_req_st_pop_thrd        => lsu_req_st_pop_thrd,

     -- Instruction Fetches
     -- Instruction Fetch real address
     i_x_ra                     => i_x_ra,
     i_x_request                => i_x_request,
     i_x_wimge                  => i_x_wimge,
     i_x_thread                 => i_x_thread,
     i_x_userdef                => i_x_userdef,  

     mm_xu_lsu_req              => mm_xu_lsu_req,
     mm_xu_lsu_ttype            => mm_xu_lsu_ttype,
     mm_xu_lsu_wimge            => mm_xu_lsu_wimge,
     mm_xu_lsu_u                => mm_xu_lsu_u,
     mm_xu_lsu_addr             => mm_xu_lsu_addr,
     mm_xu_lsu_lpid             => mm_xu_lsu_lpid, 
     mm_xu_lsu_lpidr            => mm_xu_lsu_lpidr, 
     mm_xu_lsu_gs               => mm_xu_lsu_gs  ,
     mm_xu_lsu_ind              => mm_xu_lsu_ind ,
     mm_xu_lsu_lbit             => mm_xu_lsu_lbit,

     spr_xucr0_clkg_ctl_b3      => spr_xucr0_clkg_ctl_b3,
     xu_lsu_spr_xucr0_rel       => xu_lsu_spr_xucr0_rel,
     xu_lsu_spr_xucr0_l2siw     => xu_lsu_spr_xucr0_l2siw,
     xu_lsu_spr_xucr0_cred      => xu_lsu_spr_xucr0_cred,
     xu_lsu_spr_xucr0_mbar_ack  => xu_lsu_spr_xucr0_mbar_ack,
     xu_lsu_spr_xucr0_tlbsync   => xu_lsu_spr_xucr0_tlbsync,
     xu_lsu_spr_xucr0_cls       => xu_lsu_spr_xucr0_cls,
     xu_mm_lsu_token            => xu_mm_lsu_token,
     lsu_xu_ldq_barr_done       => lsu_xu_ldq_barr_done,
     lsu_xu_sync_barr_done      => lsu_xu_sync_barr_done,

     mm_xu_derat_pid0           => mm_xu_derat_pid0,
     mm_xu_derat_pid1           => mm_xu_derat_pid1,
     mm_xu_derat_pid2           => mm_xu_derat_pid2,
     mm_xu_derat_pid3           => mm_xu_derat_pid3,
     xu_lsu_msr_gs              => xu_lsu_msr_gs,
     xu_lsu_msr_pr              => xu_lsu_msr_pr,
     xu_lsu_msr_ds              => xu_lsu_msr_ds,
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

     bx_lsu_ob_pwr_tok          =>  bx_lsu_ob_pwr_tok ,
     bx_lsu_ob_req_val          =>  bx_lsu_ob_req_val  ,
     bx_lsu_ob_ditc_val         =>  bx_lsu_ob_ditc_val ,
     bx_lsu_ob_thrd             =>  bx_lsu_ob_thrd     ,
     bx_lsu_ob_qw               =>  bx_lsu_ob_qw       ,
     bx_lsu_ob_dest             =>  bx_lsu_ob_dest     ,
     bx_lsu_ob_data             =>  bx_lsu_ob_data     ,
     bx_lsu_ob_addr             =>  bx_lsu_ob_addr     ,
     lsu_bx_cmd_avail           =>  lsu_bx_cmd_avail   ,
     lsu_bx_cmd_sent            =>  lsu_bx_cmd_sent    ,
     lsu_bx_cmd_stall           =>  lsu_bx_cmd_stall   ,
                                 
     -- *** Reload operation Outputs ***
     ldq_rel_op_size            => ldq_rel_op_size,
     ldq_rel_thrd_id            => rel_ldq_thrd_id,
     ldq_rel_addr               => rel_ldq_addr,
     ldq_rel_addr_early         => ldq_rel_addr_early,
     ldq_rel_data_val           => rel_data_val,
     ldq_rel_data_val_early     => rel_data_val_early,
     ldq_rel_tag                => ldq_rel_tag,
     ldq_rel_tag_early          => ldq_rel_tag_early,
     ldq_rel1_val               => ldq_rel1_val,
     ldq_rel1_early_v           => ldq_rel1_early_v,
     ldq_rel_mid_val            => ldq_rel_mid_val,
     ldq_rel_retry_val          => ldq_rel_retry_val,
     ldq_rel3_val               => ldq_rel3_val,
     ldq_rel3_early_v           => ldq_rel3_early_v,
     ldq_rel_ta_gpr             => ldq_rel_ta_gpr,
     ldq_rel_rot_sel            => ldq_rel_rot_sel,
     ldq_rel_axu_val            => rel_ldq_axu_val,
     ldq_rel_upd_gpr            => rel_ldq_upd_gpr,
     ldq_rel_le_mode            => ldq_rel_le_mode,
     ldq_rel_algebraic          => ldq_rel_algebraic,
     ldq_rel_set_val            => ldq_rel_set_val,
     ldq_rel_ecc_err            => ldq_rel_ecc_err,
     ldq_rel_256_data           => ldq_rel_256_data,
     ldq_rel_classid            => ldq_rel_classid,
     ldq_rel_lock_en            => ldq_rel_lock_en,
     ldq_rel_ci                 => rel_ldq_ci,
     ldq_rel_dvc1_en            => ldq_rel_dvc1_en,
     ldq_rel_dvc2_en            => ldq_rel_dvc2_en,
     ldq_rel_watch_en           => ldq_rel_watch_en,
     ldq_rel_back_invalidated   => ldq_rel_back_invalidated,
     ldq_recirc_rel_val         => ldq_recirc_rel_val,
     ldq_rel_beat_crit_qw       => ldq_rel_beat_crit_qw,
     ldq_rel_beat_crit_qw_block => ldq_rel_beat_crit_qw_block,

     l1dump_cslc                => ldq_rel_l1dump_cslc,
     ldq_rel3_l1dump_val        => ldq_rel3_l1dump_val,

     -- Back invalidate signals going to D-Cache
     is2_l2_inv_val             => is2_l2_inv_val,
     is2_l2_inv_p_addr          => is2_l2_inv_p_addr,
     
     -- Flush Signals and signals going to dependency
     ex3_ld_queue_full          => ex3_ld_queue_full,
     ex3_stq_flush              => ex3_stq_flush,
     ex3_ig_flush               => ex3_ig_flush,
     gpr_ecc_err_flush_tid      => gpr_ecc_err_flush_tid,

     xu_iu_ex4_loadmiss_qentry  => xu_iu_ex4_loadmiss_qentry,
     xu_iu_ex4_loadmiss_target  => xu_iu_ex4_loadmiss_target,
     xu_iu_ex4_loadmiss_target_type => xu_iu_ex4_loadmiss_target_type,
     xu_iu_ex4_loadmiss_tid     => xu_iu_ex4_loadmiss_tid,
     xu_iu_ex5_loadmiss_qentry  => xu_iu_ex5_loadmiss_qentry,
     xu_iu_ex5_loadmiss_target  => xu_iu_ex5_loadmiss_target,
     xu_iu_ex5_loadmiss_target_type => xu_iu_ex5_loadmiss_target_type,
     xu_iu_ex5_loadmiss_tid     => xu_iu_ex5_loadmiss_tid,
     xu_iu_complete_qentry      => xu_iu_complete_qentry,
     xu_iu_complete_tid         => xu_iu_complete_tid,
     xu_iu_complete_target_type => xu_iu_complete_target_type,

     xu_iu_larx_done_tid        => xu_iu_larx_done_tid,
     xu_mm_lmq_stq_empty        => xu_mm_lmq_stq_empty,
     lsu_xu_quiesce             => lsu_xu_quiesce,
     lsu_xu_dbell_val           => lsu_xu_dbell_val,
     lsu_xu_dbell_type          => lsu_xu_dbell_type,
     lsu_xu_dbell_brdcast       => lsu_xu_dbell_brdcast,
     lsu_xu_dbell_lpid_match    => lsu_xu_dbell_lpid_match,
     lsu_xu_dbell_pirtag        => lsu_xu_dbell_pirtag,

     ac_an_req_pwr_token        => ac_an_req_pwr_token,
     ac_an_req                  => ac_an_req,
     ac_an_req_ra               => ac_an_req_ra,
     ac_an_req_ttype            => ac_an_req_ttype,
     ac_an_req_thread           => ac_an_req_thread,
     ac_an_req_wimg_w           => ac_an_req_wimg_w,
     ac_an_req_wimg_i           => ac_an_req_wimg_i,
     ac_an_req_wimg_m           => ac_an_req_wimg_m,
     ac_an_req_wimg_g           => ac_an_req_wimg_g,
     ac_an_req_endian           => ac_an_req_endian,
     ac_an_req_user_defined     => ac_an_req_user_defined,
     ac_an_req_spare_ctrl_a0    => ac_an_req_spare_ctrl_a0,
     ac_an_req_ld_core_tag      => ac_an_req_ld_core_tag,
     ac_an_req_ld_xfr_len       => ac_an_req_ld_xfr_len,
     ac_an_st_byte_enbl         => ac_an_st_byte_enbl,
     ac_an_st_data              => ac_an_st_data,
     ac_an_st_data_pwr_token    => ac_an_st_data_pwr_token,

     cmp_lmq_entry_act          => cmp_lmq_entry_act      ,
     cmp_ex3_p_addr_o           => cmp_ex3_p_addr_o       ,
     cmp_ldq_comp_val           => cmp_ldq_comp_val       ,
     cmp_ldq_match              => cmp_ldq_match          ,
     cmp_ldq_fnd                => cmp_ldq_fnd    ,
     cmp_l_q_wrt_en             => cmp_l_q_wrt_en         ,
     cmp_ld_ex7_recov           => cmp_ld_ex7_recov       ,
     cmp_ex7_ld_recov_addr      => cmp_ex7_ld_recov_addr  ,
     cmp_ex4_loadmiss_qentry    => cmp_ex4_loadmiss_qentry,
     cmp_ex4_ld_addr            => cmp_ex4_ld_addr        ,
     cmp_l_q_rd_en              => cmp_l_q_rd_en          ,
     cmp_l_miss_entry_addr      => cmp_l_miss_entry_addr  ,
     cmp_rel_tag_1hot           => cmp_rel_tag_1hot       ,
     cmp_rel_addr               => cmp_rel_addr           ,
     cmp_back_inv_addr          => cmp_back_inv_addr      ,
     cmp_back_inv_cmp_val       => cmp_back_inv_cmp_val   ,
     cmp_back_inv_addr_hit      => cmp_back_inv_addr_hit  ,
     cmp_s_m_queue0_addr        => cmp_s_m_queue0_addr    ,
     cmp_st_entry0_val          => cmp_st_entry0_val      ,
     cmp_ex3addr_hit_stq        => cmp_ex3addr_hit_stq    ,
     cmp_ex4_st_entry_addr      => cmp_ex4_st_entry_addr  ,
     cmp_ex4_st_val             => cmp_ex4_st_val         ,
     cmp_ex3addr_hit_ex4st      => cmp_ex3addr_hit_ex4st  ,

     l2_data_ecc_err_ue         => l2_data_ecc_err_ue,
     xu_pc_err_l2intrf_ecc      => xu_pc_err_l2intrf_ecc,
     xu_pc_err_l2intrf_ue       => xu_pc_err_l2intrf_ue,
     xu_pc_err_invld_reld       => xu_pc_err_invld_reld,
     xu_pc_err_l2credit_overrun => xu_pc_err_l2credit_overrun,
     an_ac_coreid               => an_ac_coreid,
     lsu_xu_perf_events         => lsu_perf_events(38 to 46),

     -- latch and redrive for BXQ
     ac_an_reld_ditc_pop_int    => ac_an_reld_ditc_pop_int,
     ac_an_reld_ditc_pop_q      => ac_an_reld_ditc_pop_q  ,
     bx_ib_empty_int            => bx_ib_empty_int        ,
     bx_ib_empty_q              => bx_ib_empty_q          ,

     lmq_pe_recov_state         => lmq_pe_recov_state,
     lmq_dbg_dcache_pe          => lmq_dbg_dcache_pe,
     lmq_dbg_l2req              => lmq_dbg_l2req,
     lmq_dbg_rel                => lmq_dbg_rel , 
     lmq_dbg_binv               => lmq_dbg_binv, 
     lmq_dbg_pops               => lmq_dbg_pops, 
     lmq_dbg_grp0               => lmq_dbg_grp0, 
     lmq_dbg_grp1               => lmq_dbg_grp1, 
     lmq_dbg_grp2               => lmq_dbg_grp2, 
     lmq_dbg_grp3               => lmq_dbg_grp3, 
     lmq_dbg_grp4               => lmq_dbg_grp4, 
     lmq_dbg_grp5               => lmq_dbg_grp5, 
     lmq_dbg_grp6               => lmq_dbg_grp6, 
            
     vdd                        => vdd,
     gnd                        => gnd,
     nclk                       => nclk,
     sg_0                       => sg_0,
     func_sl_thold_0_b          => func_sl_thold_0_b,
     func_sl_force => func_sl_force,
     func_slp_sl_thold_0_b      => func_slp_sl_thold_0_b,
     func_slp_sl_force => func_slp_sl_force,
     cfg_slp_sl_thold_0_b       => cfg_slp_sl_thold_0_b,
     cfg_slp_sl_force => cfg_slp_sl_force,
     d_mode_dc                  => d_mode_dc,
     delay_lclkr_dc             => delay_lclkr_dc(5),
     mpw1_dc_b                  => mpw1_dc_b(5),
     mpw2_dc_b                  => mpw2_dc_b,
     scan_dis_dc_b              => an_ac_scan_dis_dc_b,
     bcfg_scan_in               => bcfg_scan_in,
     bcfg_scan_out              => bcfg_scan_out_int,
     scan_in                    => func_scan_in_q(47 to 49),
     scan_out(0)                => l2cmdq_scan_out,
     scan_out(1 to 2)           => func_scan_out_int(48 to 49)
);

-- Mux Between Directory Read and Back-Invalidate
is2_back_inv_addr(64-real_data_add to 52) <= is2_l2_inv_p_addr(64-real_data_add to 52);

with is2_l2_inv_val select
    is2_back_inv_addr(53 to 63-cl_size) <= is2_l2_inv_p_addr(53 to 63-cl_size) when '1',
                                                           dir_arr_rd_congr_cl when others;

-- XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
-- Performance Counters
-- XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
lsuperf : entity work.xuq_lsu_perf(xuq_lsu_perf)
generic map(expand_type      => expand_type)
PORT map(

     -- LSU Performance Events
     lsu_perf_events            => lsu_perf_events,

     -- PC Control Interface
     pc_xu_event_bus_enable     => pc_xu_event_bus_enable,
     pc_xu_event_count_mode     => pc_xu_event_count_mode,
     pc_xu_lsu_event_mux_ctrls  => pc_xu_lsu_event_mux_ctrls,
     pc_xu_cache_par_err_event  => pc_xu_cache_par_err_event,

     -- Perf Event Output
     xu_pc_lsu_event_data       => xu_pc_lsu_event_data,

     -- SPR Bits
     spr_msr_gs                 => xu_lsu_msr_gs,
     spr_msr_pr                 => xu_lsu_msr_pr,
                            
     vdd                        => vdd,
     gnd                        => gnd,
     nclk                       => nclk,
     sg_0                       => sg_0,
     func_slp_sl_thold_0_b      => func_slp_sl_thold_0_b,
     func_slp_sl_force => func_slp_sl_force,
     d_mode_dc                  => d_mode_dc,
     delay_lclkr_dc             => delay_lclkr_dc(5),
     mpw1_dc_b                  => mpw1_dc_b(5),
     mpw2_dc_b                  => mpw2_dc_b,
     scan_in                    => cmp_scan_out,
     scan_out                   => func_scan_out_int(46)
);

-- XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
-- Debug Trace Bus
-- XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

lsudbg : entity work.xuq_lsu_debug(xuq_lsu_debug)
generic map(expand_type      => expand_type)
PORT map(

     -- PC Debug Control
     pc_xu_trace_bus_enable     => pc_xu_trace_bus_enable,
     lsu_debug_mux_ctrls        => lsu_debug_mux_ctrls,
     xu_lsu_ex2_instr_trace_val => xu_lsu_ex2_instr_trace_val,

     -- Pass Thru Debug Trace Bus
     trigger_data_in            => trigger_data_in,
     debug_data_in              => debug_data_in,

     -- Debug Data
     dc_fgen_dbg_data           => dc_fgen_dbg_data,
     dc_cntrl_dbg_data          => dc_cntrl_dbg_data,
     dc_val_dbg_data            => dc_val_dbg_data,
     dc_lru_dbg_data            => dc_lru_dbg_data,
     dc_dir_dbg_data            => dc_dir_dbg_data,
     dir_arr_dbg_data           => dir_arr_dbg_data,
     lmq_dbg_dcache_pe          => lmq_dbg_dcache_pe,
     lmq_dbg_l2req              => lmq_dbg_l2req,
     lmq_dbg_rel                => lmq_dbg_rel , 
     lmq_dbg_binv               => lmq_dbg_binv, 
     lmq_dbg_pops               => lmq_dbg_pops, 
     lmq_dbg_grp0               => lmq_dbg_grp0, 
     lmq_dbg_grp1               => lmq_dbg_grp1, 
     lmq_dbg_grp2               => lmq_dbg_grp2, 
     lmq_dbg_grp3               => lmq_dbg_grp3, 
     lmq_dbg_grp4               => lmq_dbg_grp4, 
     lmq_dbg_grp5               => lmq_dbg_grp5, 
     lmq_dbg_grp6               => lmq_dbg_grp6, 
     pe_recov_begin             => pe_recov_begin,
     derat_xu_debug_group0      => derat_xu_debug_group0,
     derat_xu_debug_group1      => derat_xu_debug_group1,

     -- Outputs
     trigger_data_out           => trigger_data_out,
     debug_data_out             => debug_data_out,

     -- Power
     vdd                        => vdd,
     gnd                        => gnd,
     nclk                       => nclk,
     sg_0                       => sg_0,
     func_slp_sl_thold_0_b      => func_slp_sl_thold_0_b,
     func_slp_sl_force => func_slp_sl_force,
     d_mode_dc                  => d_mode_dc,
     delay_lclkr_dc             => delay_lclkr_dc(5),
     mpw1_dc_b                  => mpw1_dc_b(5),
     mpw2_dc_b                  => mpw2_dc_b,
     scan_in                    => dir_scan_out(0),
     scan_out                   => func_scan_out_int(45)
);

-- XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
-- FIR Error Reporting
-- XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

DDPerr: tri_direct_err_rpt
generic map(width => 1, expand_type => expand_type)
port map(
      vd      => vdd,
      gd      => gnd,
      err_in  => ex4_dir_perr_det(0 to 0),
      err_out => dcachedir_parity(0 to 0)
);

DDMulti: tri_direct_err_rpt
generic map(width => 1, expand_type => expand_type)
port map(
      vd      => vdd,
      gd      => gnd,
      err_in  => ex4_dir_multihit_det(0 to 0),
      err_out => dcachedir_multihit(0 to 0)
);

ex3_data_swap                 <= ex3_data_swap_int;
xu_pc_err_dcachedir_parity    <= dcachedir_parity(0);
xu_pc_err_dcachedir_multihit  <= dcachedir_multihit(0);
lsu_xu_ex3_derat_vf           <= derat_xu_ex3_vf and not ex3_blkable_touch;
ldq_rel_addr                  <= rel_ldq_addr(64-(dc_size-3) to 58);
ldq_rel_axu_val               <= rel_ldq_axu_val;
ldq_rel_ci                    <= rel_ldq_ci;
ldq_rel_thrd_id               <= rel_ldq_thrd_id;
xu_fu_ex3_eff_addr            <= ex3_p_addr_lwr(59 to 63);
ex3_algebraic                 <= ex3_algebraic_op;
ex3_thrd_id                   <= ex3_req_thrd_id;
lsu_xu_ex3_attr               <= derat_xu_ex3_u & derat_xu_ex3_wimge;
lsu_xu_ex3_l2_uc_ecc_err      <= l2_data_ecc_err_ue;
lsu_xu_datc_perr_recovery     <= lmq_pe_recov_state or dcpar_err_flush;
lsu_xu_l2_ecc_err_flush       <= gpr_ecc_err_flush_tid;
lsu_xu_ex3_ldq_hit_flush      <= cmp_flush;
lsu_xu_ex4_n_lsu_ddmh_flush   <= ex4_n_lsu_ddmh_flush;
lsu_xu_is2_back_inv           <= is2_l2_inv_val or dir_arr_rd_is2_val;
lsu_xu_is2_back_inv_addr      <= is2_back_inv_addr;
lsu_xu_spr_epsc_epr           <= xu_derat_epsc0_epr & xu_derat_epsc1_epr & xu_derat_epsc2_epr & xu_derat_epsc3_epr;
lsu_xu_spr_epsc_egs           <= xu_derat_epsc0_egs & xu_derat_epsc1_egs & xu_derat_epsc2_egs & xu_derat_epsc3_egs;
bcfg_scan_out                 <= bcfg_scan_out_int and an_ac_scan_dis_dc_b;
ccfg_scan_out                 <= ccfg_scan_out_int and an_ac_scan_dis_dc_b;
abst_scan_out                 <= abst_scan_out_q and an_ac_scan_dis_dc_b;
time_scan_out                 <= time_scan_out_q and an_ac_scan_dis_dc_b;
repr_scan_out                 <= repr_scan_out_q and an_ac_scan_dis_dc_b;
func_scan_out                 <= gate(func_scan_out_q, an_ac_scan_dis_dc_b);
regf_scan_out                 <= gate(regf_scan_out_q, an_ac_scan_dis_dc_b);
-- Not Connected Scan
dcfg_scan_out_int             <= dcfg_scan_in;
dcfg_scan_out                 <= dcfg_scan_out_int and an_ac_scan_dis_dc_b;

lsu_xu_barr_done              <= derat_iu_barrier_done or lsu_xu_sync_barr_done;
ldq_rel_data_val              <= rel_data_val;
ldq_rel_data_val_early        <= rel_data_val_early;

-----------------------------------------------------------------------
-- abist latches
-----------------------------------------------------------------------
abist_reg: tri_rlmreg_p
  generic map (init => 0, expand_type => expand_type, width => 23, needs_sreset => 0)
  port map (vd             => vdd,
            gd             => gnd,
            nclk           => nclk,
            act            => pc_xu_abist_ena_dc,
            thold_b        => abst_slp_sl_thold_0_b,
            sg             => sg_0,
            forcee => abst_slp_sl_force,
            delay_lclkr    => delay_lclkr_dc(5),
            mpw1_b         => mpw1_dc_b(5),
            mpw2_b         => mpw2_dc_b,
            d_mode         => d_mode_dc,
            scin           => abist_siv(1 to 23),
            scout          => abist_sov(1 to 23),
            din (0)        => pc_xu_abist_g8t_wenb,
            din (1)        => pc_xu_abist_g8t1p_renb_0,
            din (2  to  5) => pc_xu_abist_di_0,
            din (6)        => pc_xu_abist_g8t_bw_1,
            din (7)        => pc_xu_abist_g8t_bw_0,
            din (8  to 12) => pc_xu_abist_waddr_0,
            din (13 to 17) => pc_xu_abist_raddr_0,
            din (18)       => pc_xu_abist_wl32_comp_ena,
            din (19 to 22) => pc_xu_abist_g8t_dcomp,
            dout(0)        => pc_xu_abist_g8t_wenb_q,
            dout(1)        => pc_xu_abist_g8t1p_renb_0_q,
            dout(2  to 5)  => pc_xu_abist_di_0_q,
            dout(6)        => pc_xu_abist_g8t_bw_1_q,
            dout(7)        => pc_xu_abist_g8t_bw_0_q,
            dout(8  to 12) => pc_xu_abist_waddr_0_q,
            dout(13 to 17) => pc_xu_abist_raddr_0_q,
            dout(18)       => pc_xu_abist_wl32_comp_ena_q,
            dout(19 to 22) => pc_xu_abist_g8t_dcomp_q);

-------------------------------------------------
-- Pervasive
-------------------------------------------------
perv_2to1_reg: tri_plat
  generic map (width => 13, expand_type => expand_type)
port map (vd          => vdd,
            gd          => gnd,
            nclk        => nclk,
            flush       => pc_xu_ccflush_dc,
            din(0)      => func_slp_sl_thold_2,
            din(1)      => func_sl_thold_2(3),
            din(2)      => func_nsl_thold_2,
            din(3)      => sg_2(3),
            din(4)      => cfg_slp_sl_thold_2,
            din(5)      => ary_slp_nsl_thold_2,
            din(6)      => abst_slp_sl_thold_2,
            din(7)      => time_sl_thold_2,
            din(8)      => repr_sl_thold_2,
            din(9)      => regf_slp_sl_thold_2,
            din(10)     => func_slp_nsl_thold_2,
            din(11)     => fce_2,
            din(12)     => bolt_sl_thold_2,
            q(0)        => func_slp_sl_thold_1,
            q(1)        => func_sl_thold_1,
            q(2)        => func_nsl_thold_1,
            q(3)        => sg_1,
            q(4)        => cfg_slp_sl_thold_1,
            q(5)        => ary_slp_nsl_thold_1,
            q(6)        => abst_slp_sl_thold_1,
            q(7)        => time_sl_thold_1,
            q(8)        => repr_sl_thold_1,
            q(9)        => regf_slp_sl_thold_1,
            q(10)       => func_slp_nsl_thold_1,
            q(11)       => fce_1,
            q(12)       => bolt_sl_thold_1);

perv_1to0_reg: tri_plat
  generic map (width => 13, expand_type => expand_type)
port map (vd          => vdd,
            gd          => gnd,
            nclk        => nclk,
            flush       => pc_xu_ccflush_dc,
            din(0)      => func_slp_sl_thold_1,
            din(1)      => func_sl_thold_1,
            din(2)      => func_nsl_thold_1,
            din(3)      => sg_1,
            din(4)      => cfg_slp_sl_thold_1,
            din(5)      => ary_slp_nsl_thold_1,
            din(6)      => abst_slp_sl_thold_1,
            din(7)      => time_sl_thold_1,
            din(8)      => repr_sl_thold_1,
            din(9)      => regf_slp_sl_thold_1,
            din(10)     => func_slp_nsl_thold_1,
            din(11)     => fce_1,
            din(12)     => bolt_sl_thold_1,
            q(0)        => func_slp_sl_thold_0,
            q(1)        => func_sl_thold_0,
            q(2)        => func_nsl_thold_0,
            q(3)        => sg_0,
            q(4)        => cfg_slp_sl_thold_0,
            q(5)        => ary_slp_nsl_thold_0,
            q(6)        => abst_slp_sl_thold_0,
            q(7)        => time_sl_thold_0,
            q(8)        => repr_sl_thold_0,
            q(9)        => regf_slp_sl_thold_0,
            q(10)       => func_slp_nsl_thold_0,
            q(11)       => fce_0,
            q(12)       => bolt_sl_thold_0);

perv_lcbor_func_sl: tri_lcbor
  generic map (expand_type => expand_type)
port map (clkoff_b    => clkoff_dc_b,
            thold       => func_sl_thold_0,
            sg          => sg_0,
            act_dis     => tidn,
            forcee => func_sl_force,
            thold_b     => func_sl_thold_0_b);

perv_lcbor_func_nsl: tri_lcbor
  generic map (expand_type => expand_type)
port map (clkoff_b    => clkoff_dc_b,
            thold       => func_nsl_thold_0,
            sg          => fce_0,
            act_dis     => tidn,
            forcee => func_nsl_force,
            thold_b     => func_nsl_thold_0_b);

perv_lcbor_func_slp_sl: tri_lcbor
  generic map (expand_type => expand_type)
port map (clkoff_b    => clkoff_dc_b,
            thold       => func_slp_sl_thold_0,
            sg          => sg_0,
            act_dis     => tidn,
            forcee => func_slp_sl_force,
            thold_b     => func_slp_sl_thold_0_b);

perv_lcbor_cfg_slp_sl: tri_lcbor
  generic map (expand_type => expand_type)
port map (clkoff_b    => clkoff_dc_b,
            thold       => cfg_slp_sl_thold_0,
            sg          => sg_0,
            act_dis     => tidn,
            forcee => cfg_slp_sl_force,
            thold_b     => cfg_slp_sl_thold_0_b);

perv_lcbor_abst_sl: tri_lcbor
  generic map (expand_type => expand_type)
  port map (clkoff_b    => clkoff_dc_b,
            thold       => abst_slp_sl_thold_0,
            sg          => sg_0,
            act_dis     => tidn,
            forcee => abst_slp_sl_force,
            thold_b     => abst_slp_sl_thold_0_b);

perv_lcbor_func_slp_nsl: tri_lcbor
  generic map (expand_type => expand_type)
port map (clkoff_b    => clkoff_dc_b,
            thold       => func_slp_nsl_thold_0,
            sg          => fce_0,
            act_dis     => tidn,
            forcee => func_slp_nsl_force,
            thold_b     => func_slp_nsl_thold_0_b);

-- LCBs for scan only staging latches
slat_force        <= sg_0;
abst_slat_thold_b <= NOT abst_slp_sl_thold_0;
time_slat_thold_b <= NOT time_sl_thold_0;
repr_slat_thold_b <= NOT repr_sl_thold_0;
func_slat_thold_b <= NOT func_sl_thold_0;
regf_slat_thold_b <= NOT regf_slp_sl_thold_0;

perv_lcbs_abst: tri_lcbs
  generic map (expand_type => expand_type )
  port map (
      vd          => vdd,
      gd          => gnd,
      delay_lclkr => delay_lclkr_dc(5),
      nclk        => nclk,
      forcee => slat_force,
      thold_b     => abst_slat_thold_b,
      dclk        => abst_slat_d2clk,
      lclk        => abst_slat_lclk );

perv_abst_stg: tri_slat_scan  
   generic map (width => 2, init => "00", expand_type => expand_type)
   port map ( vd          => vdd,
              gd          => gnd,
              dclk        => abst_slat_d2clk,
              lclk        => abst_slat_lclk,
              scan_in(0)  => abst_scan_in,
              scan_in(1)  => abst_scan_out_int,
              scan_out(0) => abst_scan_in_q,
              scan_out(1) => abst_scan_out_q );

perv_lcbs_time: tri_lcbs
  generic map (expand_type => expand_type )
  port map (
      vd          => vdd,
      gd          => gnd,
      delay_lclkr => delay_lclkr_dc(5),
      nclk        => nclk,
      forcee => slat_force,
      thold_b     => time_slat_thold_b,
      dclk        => time_slat_d2clk,
      lclk        => time_slat_lclk );

perv_time_stg: tri_slat_scan  
   generic map (width => 2, init => "00", expand_type => expand_type)
   port map ( vd          => vdd,
              gd          => gnd,
              dclk        => time_slat_d2clk,
              lclk        => time_slat_lclk,
              scan_in(0)  => time_scan_in,
              scan_in(1)  => time_scan_out_int(1),
              scan_out(0) => time_scan_in_q,
              scan_out(1) => time_scan_out_q );

perv_lcbs_repr: tri_lcbs
  generic map (expand_type => expand_type )
  port map (
      vd          => vdd,
      gd          => gnd,
      delay_lclkr => delay_lclkr_dc(5),
      nclk        => nclk,
      forcee => slat_force,
      thold_b     => repr_slat_thold_b,
      dclk        => repr_slat_d2clk,
      lclk        => repr_slat_lclk );

perv_repr_stg: tri_slat_scan  
   generic map (width => 2, init => "00", expand_type => expand_type)
   port map ( vd          => vdd,
              gd          => gnd,
              dclk        => repr_slat_d2clk,
              lclk        => repr_slat_lclk,
              scan_in(0)  => repr_scan_in,
              scan_in(1)  => repr_scan_out_int,
              scan_out(0) => repr_scan_in_q,
              scan_out(1) => repr_scan_out_q );

perv_lcbs_func: tri_lcbs
  generic map (expand_type => expand_type )
  port map (
      vd          => vdd,
      gd          => gnd,
      delay_lclkr => delay_lclkr_dc(5),
      nclk        => nclk,
      forcee => slat_force,
      thold_b     => func_slat_thold_b,
      dclk        => func_slat_d2clk,
      lclk        => func_slat_lclk );

-- pass through un-connected scan rings
func_scan_out_int(42) <= derat_scan_out(1);

perv_func_stg: tri_slat_scan  
   generic map (width => 18, init => "0000000000", expand_type => expand_type)
   port map ( vd               => vdd,
              gd               => gnd,
              dclk             => func_slat_d2clk,
              lclk             => func_slat_lclk,
              scan_in(0 to 8)  => func_scan_in,
              scan_in(9 to 17) => func_scan_out_int,
              scan_out(0 to 8) => func_scan_in_q,
              scan_out(9 to 17) => func_scan_out_q );

perv_lcbs_regf: tri_lcbs
  generic map (expand_type => expand_type )
  port map (
      vd          => vdd,
      gd          => gnd,
      delay_lclkr => delay_lclkr_dc(5),
      nclk        => nclk,
      forcee => slat_force,
      thold_b     => regf_slat_thold_b,
      dclk        => regf_slat_d2clk,
      lclk        => regf_slat_lclk );

perv_regf_stg: tri_slat_scan  
   generic map (width => 14, init => "00000000000000", expand_type => expand_type)
   port map ( vd                => vdd,
              gd                => gnd,
              dclk              => regf_slat_d2clk,
              lclk              => regf_slat_lclk,
              scan_in(0 to 6)   => regf_scan_in,
              scan_in(7 to 13)  => regf_scan_out_int,
              scan_out(0 to 6)  => regf_scan_in_q,
              scan_out(7 to 13) => regf_scan_out_q );

abist_siv         <= abist_sov(1 to abist_sov'right) & abst_scan_in_q;
abst_scan_out_int <= abist_sov(0);

mark_unused(derat_xu_ex2_miss);
mark_unused(derat_xu_ex2_rpn);
mark_unused(derat_xu_ex2_wimge);
mark_unused(derat_xu_ex2_u);
mark_unused(derat_xu_ex2_wlc);
mark_unused(derat_xu_ex2_attr);
mark_unused(derat_xu_ex2_vf);
mark_unused(derat_xu_ex3_attr);
mark_unused(derat_fir_par_err);
mark_unused(derat_fir_multihit);

end xuq_lsu_cmd;
