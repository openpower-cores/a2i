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

--  Description:  XU LSU L1 Data Cache Control
--

library ibm, ieee, work, tri, support;
use ibm.std_ulogic_support.all;
use ibm.std_ulogic_function_support.all;
use ibm.std_ulogic_unsigned.all;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use tri.tri_latches_pkg.all;
use support.power_logic_pkg.all;

-- ##########################################################################################
-- VHDL Contents
-- 1) 1 32Byte input (suppose to reflect reading 8 ways of L1 D$, Selection taken place in EX2)
-- 2) 32 Byte Reload Bus
-- 4) 32 Byte Unaligned Rotator
-- 5) Little Endian Support for 2,4,8,16,32 Byte Operations
-- 6) Contains Fixed Point Unit (FXU) 8 Byte Load Path
-- 7) Contains Auxilary Unit (AXU) 32 Byte Load Path
-- 8) Contains Unalignment Error Check
-- ##########################################################################################

entity xuq_lsu_dc_cntrl is
generic(expand_type     : integer := 2;     -- 0 = ibm (Umbra), 1 = non-ibm, 2 = ibm (MPG)
        regmode         : integer := 6;     -- 5 = 32bit mode, 6 = 64bit mode
        dc_size         : natural := 14;    -- 2^14 = 16384 Bytes L1 D$
        parBits         : natural := 4;     -- Number of Parity Bits
        real_data_add   : integer := 42);   -- 42 bit real address
port(

     -- Execution Pipe Inputs
     xu_lsu_rf0_act             :in  std_ulogic;
     xu_lsu_rf1_cmd_act         :in  std_ulogic;
     xu_lsu_rf1_axu_op_val      :in  std_ulogic;                        -- Operation is from the AXU
     xu_lsu_rf1_axu_ldst_falign :in  std_ulogic;                        -- AXU force alignment indicator
     xu_lsu_rf1_axu_ldst_fexcpt :in  std_ulogic;                        -- AXU force alignment exception on misaligned access
     xu_lsu_rf1_cache_acc       :in  std_ulogic;                        -- Cache Access is Valid, Op that touches directory
     xu_lsu_rf1_thrd_id         :in  std_ulogic_vector(0 to 3);         -- Thread ID
     xu_lsu_rf1_optype1         :in  std_ulogic;                        -- 1 Byte Load/Store
     xu_lsu_rf1_optype2         :in  std_ulogic;                        -- 2 Byte Load/Store
     xu_lsu_rf1_optype4         :in  std_ulogic;                        -- 4 Byte Load/Store
     xu_lsu_rf1_optype8         :in  std_ulogic;                        -- 8 Byte Load/Store
     xu_lsu_rf1_optype16        :in  std_ulogic;                        -- 16 Byte Load/Store
     xu_lsu_rf1_optype32        :in  std_ulogic;                        -- 32 Byte Load/Store
     xu_lsu_rf1_target_gpr      :in  std_ulogic_vector(0 to 8);         -- Target GPR, needed for reloads
     xu_lsu_rf1_mtspr_trace     :in  std_ulogic;                        -- Operation is a mtspr trace instruction
     xu_lsu_rf1_load_instr      :in  std_ulogic;                        -- Operation is a Load instruction
     xu_lsu_rf1_store_instr     :in  std_ulogic;                        -- Operation is a Store instruction
     xu_lsu_rf1_dcbf_instr      :in  std_ulogic;                        -- Operation is a DCBF instruction
     xu_lsu_rf1_sync_instr      :in  std_ulogic;                        -- Operation is a SYNC instruction
     xu_lsu_rf1_l_fld           :in  std_ulogic_vector(0 to 1);         -- DCBF/SYNC L Field
     xu_lsu_rf1_dcbi_instr      :in  std_ulogic;                        -- Operation is a DCBI instruction
     xu_lsu_rf1_dcbz_instr      :in  std_ulogic;                        -- Operation is a DCBZ instruction
     xu_lsu_rf1_dcbt_instr      :in  std_ulogic;                        -- Operation is a DCBT instruction
     xu_lsu_rf1_dcbtst_instr    :in  std_ulogic;                        -- Operation is a DCBTST instruction
     xu_lsu_rf1_th_fld          :in  std_ulogic_vector(0 to 4);         -- TH/CT Field for Cache Management instructions
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
     xu_lsu_rf1_lock_instr      :in  std_ulogic;                        -- Operation is a LOCK instruction
     xu_lsu_rf1_mutex_hint      :in  std_ulogic;                        -- Mutex Hint For larx instructions
     xu_lsu_rf1_mbar_instr      :in  std_ulogic;                        -- Operation is an MBAR instruction
     xu_lsu_rf1_is_msgsnd       :in  std_ulogic;
     xu_lsu_rf1_dci_instr       :in  std_ulogic;                        -- DCI instruction is valid
     xu_lsu_rf1_ici_instr       :in  std_ulogic;                        -- ICI instruction is valid
     xu_lsu_rf1_algebraic       :in  std_ulogic;                        -- Operation is an Algebraic Load instruction
     xu_lsu_rf1_byte_rev        :in  std_ulogic;                        -- Operation is a Byte Reversal Load/Store instruction
     xu_lsu_rf1_src_gpr         :in  std_ulogic;                        -- Source is the GPR's for mfloat and mDCR ops
     xu_lsu_rf1_src_axu         :in  std_ulogic;                        -- Source is the AXU's for mfloat and mDCR ops
     xu_lsu_rf1_src_dp          :in  std_ulogic;                        -- Source is the BOX's for mfloat and mDCR ops
     xu_lsu_rf1_targ_gpr        :in  std_ulogic;                        -- Target is the GPR's for mfloat and mDCR ops
     xu_lsu_rf1_targ_axu        :in  std_ulogic;                        -- Target is the AXU's for mfloat and mDCR ops
     xu_lsu_rf1_targ_dp         :in  std_ulogic;                        -- Target is the BOX's for mfloat and mDCR ops
     xu_lsu_ex4_val             :in  std_ulogic_vector(0 to 3);         -- There is a valid Instruction in EX4

     -- Dependency Checking on loadmisses
     xu_lsu_rf1_src0_vld        :in  std_ulogic;                        -- Source0 is Valid
     xu_lsu_rf1_src0_reg        :in  std_ulogic_vector(0 to 7);         -- Source0 Register
     xu_lsu_rf1_src1_vld        :in  std_ulogic;                        -- Source1 is Valid
     xu_lsu_rf1_src1_reg        :in  std_ulogic_vector(0 to 7);         -- Source1 Register
     xu_lsu_rf1_targ_vld        :in  std_ulogic;                        -- Target is Valid
     xu_lsu_rf1_targ_reg        :in  std_ulogic_vector(0 to 7);         -- Target Register

     -- Back-Invalidate
     is2_l2_inv_val             :in  std_ulogic;                        -- L2 Back-Invalidate is Valid

     ex3_wayA_tag               :in  std_ulogic_vector(64-real_data_add to 63-(dc_size-3));
     ex3_wayB_tag               :in  std_ulogic_vector(64-real_data_add to 63-(dc_size-3));
     ex3_wayC_tag               :in  std_ulogic_vector(64-real_data_add to 63-(dc_size-3));
     ex3_wayD_tag               :in  std_ulogic_vector(64-real_data_add to 63-(dc_size-3));
     ex3_wayE_tag               :in  std_ulogic_vector(64-real_data_add to 63-(dc_size-3));
     ex3_wayF_tag               :in  std_ulogic_vector(64-real_data_add to 63-(dc_size-3));
     ex3_wayG_tag               :in  std_ulogic_vector(64-real_data_add to 63-(dc_size-3));
     ex3_wayH_tag               :in  std_ulogic_vector(64-real_data_add to 63-(dc_size-3));
     ex3_way_tag_par_a          :in  std_ulogic_vector(0 to parBits-1);
     ex3_way_tag_par_b          :in  std_ulogic_vector(0 to parBits-1);
     ex3_way_tag_par_c          :in  std_ulogic_vector(0 to parBits-1);
     ex3_way_tag_par_d          :in  std_ulogic_vector(0 to parBits-1);
     ex3_way_tag_par_e          :in  std_ulogic_vector(0 to parBits-1);
     ex3_way_tag_par_f          :in  std_ulogic_vector(0 to parBits-1);
     ex3_way_tag_par_g          :in  std_ulogic_vector(0 to parBits-1);
     ex3_way_tag_par_h          :in  std_ulogic_vector(0 to parBits-1);
     ex4_way_a_dir              :in  std_ulogic_vector(0 to 5);
     ex4_way_b_dir              :in  std_ulogic_vector(0 to 5);
     ex4_way_c_dir              :in  std_ulogic_vector(0 to 5);
     ex4_way_d_dir              :in  std_ulogic_vector(0 to 5);
     ex4_way_e_dir              :in  std_ulogic_vector(0 to 5);
     ex4_way_f_dir              :in  std_ulogic_vector(0 to 5);
     ex4_way_g_dir              :in  std_ulogic_vector(0 to 5);
     ex4_way_h_dir              :in  std_ulogic_vector(0 to 5);
     ex4_dir_lru                :in  std_ulogic_vector(0 to 6);

     ex2_p_addr_lwr             :in  std_ulogic_vector(52 to 63);
     ex3_wimge_i_bit            :in  std_ulogic;                        -- Memory Attribute Bits from ERAT
     ex3_wimge_e_bit            :in  std_ulogic;                        -- Memory Attribute Bits from ERAT

     ex3_p_addr                 :in  std_ulogic_vector(64-real_data_add to 51);
     ex3_ld_queue_full          :in  std_ulogic;                        -- LSQ load queue full
     ex3_stq_flush              :in  std_ulogic;                        -- LSQ store queue full
     ex3_ig_flush               :in  std_ulogic;                        -- LSQ I=G=1 flush
     ex3_hit                    :in  std_ulogic;                        -- EX3 Load/Store Hit
     ex4_miss                   :in  std_ulogic;                        -- EX4 Load/Store Miss
     ex4_snd_ld_l2              :in  std_ulogic;                        -- Request is being sent to the L2
     ex3_excp_det               :in  std_ulogic;                        -- Any Exception was detected

     -- Stage Flush
     rf1_stg_flush              :in  std_ulogic;                        -- RF1 Stage Flush
     ex1_stg_flush              :in  std_ulogic;                        -- EX1 Stage Flush
     ex2_stg_flush              :in  std_ulogic;                        -- EX2 Stage Flush
     ex3_stg_flush              :in  std_ulogic;                        -- EX3 Stage Flush
     ex4_stg_flush              :in  std_ulogic;                        -- EX4 Stage Flush
     ex5_stg_flush              :in  std_ulogic;                        -- EX5 Stage Flush

     rel_dcarr_val_upd          :in  std_ulogic;                        -- Reload Data Array Update Valid

     -- Data Cache Config
     xu_lsu_mtspr_trace_en      :in  std_ulogic_vector(0 to 3);
     spr_xucr0_clkg_ctl_b1      :in  std_ulogic;                        -- Clock Gating Override
     xu_lsu_spr_xucr0_wlk       :in  std_ulogic;                        -- Data Cache Way Locking Enable
     xu_lsu_spr_ccr2_dfrat      :in  std_ulogic;                        -- Force Real Address Translation
     xu_lsu_spr_xucr0_flh2l2    :in  std_ulogic;                        -- Force L1 load hits to L2
     xu_lsu_spr_xucr0_cls       :in  std_ulogic;                        -- Cacheline Size = 1 => 128Byte size, 0 => 64Byte size
     xu_lsu_spr_xucr0_dcdis     :in  std_ulogic;                        -- Data Cache Disable
     xu_lsu_spr_msr_cm          :in  std_ulogic_vector(0 to 3);         -- 64bit mode enable

     -- MSR[GS,PR] bits, indicates which state we are running in
     xu_lsu_msr_gs              :in  std_ulogic_vector(0 to 3);         -- Guest State
     xu_lsu_msr_pr              :in  std_ulogic_vector(0 to 3);         -- Problem State

     an_ac_flh2l2_gate          :in  std_ulogic;                        -- Gate L1 Hit forwarding SPR config bit

     -- Slow SPR Bus
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

     ldq_rel_data_val_early     :in  std_ulogic;                        -- Reload Interface ACT
     ldq_rel_stg24_val          :in  std_ulogic;                        -- Reload Stages 2 and 4 are valid
     ldq_rel_axu_val            :in  std_ulogic;                        -- Reload is for a Vector Register
     ldq_rel_thrd_id            :in  std_ulogic_vector(0 to 3);         -- Thread ID of the reload
     ldq_rel_ta_gpr             :in  std_ulogic_vector(0 to 8);
     ldq_rel_upd_gpr            :in  std_ulogic;                        -- Reload data should be written to GPR (DCB ops don't write to GPRs)

     -- Dependency Checking on loadmisses
     ex1_src0_vld               :out std_ulogic;                        -- Source0 is Valid
     ex1_src0_reg               :out std_ulogic_vector(0 to 7);         -- Source0 Register
     ex1_src1_vld               :out std_ulogic;                        -- Source1 is Valid
     ex1_src1_reg               :out std_ulogic_vector(0 to 7);         -- Source1 Register
     ex1_targ_vld               :out std_ulogic;                        -- Target is Valid
     ex1_targ_reg               :out std_ulogic_vector(0 to 7);         -- Target Register
     ex1_check_watch            :out std_ulogic_vector(0 to 3);         -- Instructions that need to wait for ldawx to complete in loadmiss queue

     -- Execution Pipe Outputs
     ex1_lsu_64bit_agen         :out std_ulogic;
     ex1_frc_align2             :out std_ulogic;
     ex1_frc_align4             :out std_ulogic;
     ex1_frc_align8             :out std_ulogic;
     ex1_frc_align16            :out std_ulogic;
     ex1_frc_align32            :out std_ulogic;
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

     ex2_optype2                :out std_ulogic;
     ex2_optype4                :out std_ulogic;
     ex2_optype8                :out std_ulogic;
     ex2_optype16               :out std_ulogic;
     ex2_optype32               :out std_ulogic;
     ex2_icswx_type             :out std_ulogic; 
     ex2_store_instr            :out std_ulogic;
     ex1_dir_acc_val            :out std_ulogic;
     ex2_cache_acc              :out std_ulogic;
     ex3_cache_acc              :out std_ulogic;
     ex2_ldst_fexcpt            :out std_ulogic;
     ex2_axu_op                 :out std_ulogic;
     ex2_mv_reg_op              :out std_ulogic;
     ex1_thrd_id                :out std_ulogic_vector(0 to 3);
     ex2_thrd_id                :out std_ulogic_vector(0 to 3);
     ex3_thrd_id                :out std_ulogic_vector(0 to 3);
     ex4_thrd_id                :out std_ulogic_vector(0 to 3);
     ex5_thrd_id                :out std_ulogic_vector(0 to 3);
     ex3_req_thrd_id            :out std_ulogic_vector(0 to 3);
     ex3_targ_match_b1          :out std_ulogic;
     ex2_targ_match_b2          :out std_ulogic;
     ex3_target_gpr             :out std_ulogic_vector(0 to 8);
     ex2_load_instr             :out std_ulogic;
     ex3_dcbt_instr             :out std_ulogic;
     ex3_dcbtst_instr           :out std_ulogic;
     ex3_th_fld_l2              :out std_ulogic;
     ex3_dcbst_instr            :out std_ulogic;
     ex3_dcbf_instr             :out std_ulogic;
     ex3_sync_instr             :out std_ulogic;
     ex3_mtspr_trace            :out std_ulogic;
     ex3_byte_en                :out std_ulogic_vector(0 to 31);
     ex2_l_fld                  :out std_ulogic_vector(0 to 1);
     ex3_l_fld                  :out std_ulogic_vector(0 to 1);
     ex3_dcbi_instr             :out std_ulogic;
     ex2_dcbz_instr             :out std_ulogic;
     ex3_dcbz_instr             :out std_ulogic;
     ex3_icbi_instr             :out std_ulogic;
     ex3_icswx_instr            :out std_ulogic;
     ex3_icswx_dot              :out std_ulogic;
     ex3_icswx_epid             :out std_ulogic;
     ex3_mbar_instr             :out std_ulogic;
     ex3_msgsnd_instr           :out std_ulogic;
     ex3_dci_instr              :out std_ulogic;
     ex3_ici_instr              :out std_ulogic;
     ex2_lock_instr             :out std_ulogic;
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
     ex4_drop_rel               :out std_ulogic;
     ex3_load_l1hit             :out std_ulogic;
     ex3_rotate_sel             :out std_ulogic_vector(0 to 4);
     ex2_ldawx_instr            :out std_ulogic;
     ex2_wclr_instr             :out std_ulogic;
     ex2_wchk_val               :out std_ulogic;
     ex3_watch_en               :out std_ulogic;
     ex3_data_swap              :out std_ulogic;
     ex3_load_val               :out std_ulogic;
     ex3_blkable_touch          :out std_ulogic;
     ex3_l2_request             :out std_ulogic;
     ex3_ldq_potential_flush    :out std_ulogic;
     ex7_targ_match             :out std_ulogic;                -- EX6vsEX5 matched
     ex8_targ_match             :out std_ulogic;                -- EX7vsEX6 or EX7vsEX5 matched
     ex4_ld_entry               :out std_ulogic_vector(0 to 67);

     ex2_no_lru_upd             :out std_ulogic;
     ex2_is_inval_op            :out std_ulogic;
     ex2_lock_set               :out std_ulogic;
     ex2_lock_clr               :out std_ulogic;
     ex2_ddir_acc_instr         :out std_ulogic;

     ex3_lsq_flush              :out std_ulogic;
     ex3_p_addr_lwr             :out std_ulogic_vector(58 to 63);
     ex3_lock_en                :out std_ulogic;
     ex3_cache_en               :out std_ulogic;
     ex3_cache_inh              :out std_ulogic;
     ex3_l_s_q_val              :out std_ulogic;
     ex3_drop_ld_req            :out std_ulogic;
     ex3_drop_touch             :out std_ulogic;
     ex3_stx_instr              :out std_ulogic;
     ex3_larx_instr             :out std_ulogic;
     ex3_mutex_hint             :out std_ulogic;
     ex3_opsize                 :out std_ulogic_vector(0 to 5);
     ex4_store_hit              :out std_ulogic;
     ex4_load_op_hit            :out std_ulogic;
     ex5_load_op_hit            :out std_ulogic;
     ex4_axu_op_val             :out std_ulogic;

     -- SPR's
     spr_xucr2_rmt              :out std_ulogic_vector(0 to 31);
     spr_xucr0_wlck             :out std_ulogic;
     spr_dvc1_act               :out std_ulogic;
     spr_dvc2_act               :out std_ulogic;
     spr_dvc1_dbg               :out std_ulogic_vector(64-(2**regmode) to 63);
     spr_dvc2_dbg               :out std_ulogic_vector(64-(2**regmode) to 63);

     -- SPR status
     lsu_xu_spr_xucr0_cul       :out std_ulogic;                        -- Cache Lock unable to lock
     spr_xucr0_cls              :out std_ulogic;                        -- Cacheline Size
     agen_xucr0_cls             :out std_ulogic;

     -- Directory Read interface
     dir_arr_rd_is2_val         :out std_ulogic;
     dir_arr_rd_congr_cl        :out std_ulogic_vector(0 to 4);

     -- Back-invalidate
     rf1_l2_inv_val             :out std_ulogic;
     ex1_agen_binv_val          :out std_ulogic;
     ex1_l2_inv_val             :out std_ulogic;

     -- Update Data Array Valid
     rel_upd_dcarr_val          :out std_ulogic;

     lsu_xu_ex4_cr_upd          :out std_ulogic;
     lsu_xu_ex5_wren            :out std_ulogic;
     lsu_xu_rel_wren            :out std_ulogic;
     lsu_xu_rel_ta_gpr          :out std_ulogic_vector(0 to 7);
     lsu_xu_perf_events         :out std_ulogic_vector(0 to 16);
     lsu_xu_need_hole           :out std_ulogic;

     xu_fu_ex5_reload_val       :out std_ulogic;
     xu_fu_ex5_load_val         :out std_ulogic_vector(0 to 3);
     xu_fu_ex5_load_tag         :out std_ulogic_vector(0 to 8);

     -- ICBI Interface
     xu_iu_ex6_icbi_val         :out std_ulogic_vector(0 to 3);
     xu_iu_ex6_icbi_addr        :out std_ulogic_vector(64-real_data_add to 57);

     -- DERAT SlowSPR Regs
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

     -- Debug Data
     dc_cntrl_dbg_data          :out std_ulogic_vector(0 to 66);

     -- ACT signals
     ex1_stg_act                :out std_ulogic;
     ex2_stg_act                :out std_ulogic;
     ex3_stg_act                :out std_ulogic;
     ex4_stg_act                :out std_ulogic;
     ex5_stg_act                :out std_ulogic;
     binv1_stg_act              :out std_ulogic;
     binv2_stg_act              :out std_ulogic;
     binv3_stg_act              :out std_ulogic;
     binv4_stg_act              :out std_ulogic;
     binv5_stg_act              :out std_ulogic;
     rel1_stg_act               :out std_ulogic;
     rel2_stg_act               :out std_ulogic;
     rel3_stg_act               :out std_ulogic;
     
     -- Pervasive
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
     scan_in                    :in  std_ulogic;
     scan_out                   :out std_ulogic
);
-- synopsys translate_off
-- synopsys translate_on
end xuq_lsu_dc_cntrl;
----
architecture xuq_lsu_dc_cntrl of xuq_lsu_dc_cntrl is

----------------------------
-- components
----------------------------

----------------------------
-- constants
----------------------------
constant tagSize                        :natural := (63-(dc_size-3))-(64-real_data_add)+1;
constant rot_max_size                   :std_ulogic_vector(0 to 5) := "100000";

constant ex1_optype1_offset             :natural := 0;
constant ex1_optype2_offset             :natural := ex1_optype1_offset + 1;
constant ex1_optype4_offset             :natural := ex1_optype2_offset + 1;
constant ex1_optype8_offset             :natural := ex1_optype4_offset + 1;
constant ex1_optype16_offset            :natural := ex1_optype8_offset + 1;
constant ex1_optype32_offset            :natural := ex1_optype16_offset + 1;
constant ex1_dir_acc_val_offset         :natural := ex1_optype32_offset + 1;
constant cache_acc_ex1_offset           :natural := ex1_dir_acc_val_offset + 1;
constant cache_acc_ex2_offset           :natural := cache_acc_ex1_offset + 1;
constant cache_acc_ex3_offset           :natural := cache_acc_ex2_offset + 1;
constant cache_acc_ex4_offset           :natural := cache_acc_ex3_offset + 1;
constant cache_acc_ex5_offset           :natural := cache_acc_ex4_offset + 1;
constant ex2_cacc_offset                :natural := cache_acc_ex5_offset + 1;
constant ex3_cacc_offset                :natural := ex2_cacc_offset + 1;
constant ex1_thrd_id_offset             :natural := ex3_cacc_offset + 1;
constant ex3_thrd_id_offset             :natural := ex1_thrd_id_offset + 4;
constant ex5_thrd_id_offset             :natural := ex3_thrd_id_offset + 4;
constant ex1_target_gpr_offset          :natural := ex5_thrd_id_offset + 4;
constant ex3_target_gpr_offset          :natural := ex1_target_gpr_offset + 9;
constant ex1_dcbt_instr_offset          :natural := ex3_target_gpr_offset + 9;
constant ex3_dcbt_instr_offset          :natural := ex1_dcbt_instr_offset + 1;
constant ex1_dcbtst_instr_offset        :natural := ex3_dcbt_instr_offset + 1;
constant ex3_dcbtst_instr_offset        :natural := ex1_dcbtst_instr_offset + 1;
constant ex1_dcbst_instr_offset         :natural := ex3_dcbtst_instr_offset + 1;
constant ex3_dcbst_instr_offset         :natural := ex1_dcbst_instr_offset + 1;
constant ex1_dcbf_instr_offset          :natural := ex3_dcbst_instr_offset + 1;
constant ex3_dcbf_instr_offset          :natural := ex1_dcbf_instr_offset + 1;
constant ex1_sync_instr_offset          :natural := ex3_dcbf_instr_offset + 1;
constant ex2_sync_instr_offset          :natural := ex1_sync_instr_offset + 1;
constant ex3_sync_instr_offset          :natural := ex2_sync_instr_offset + 1;
constant ex1_l_fld_offset               :natural := ex3_sync_instr_offset + 1;
constant ex3_l_fld_offset               :natural := ex1_l_fld_offset + 2;
constant ex1_dcbi_instr_offset          :natural := ex3_l_fld_offset + 2;
constant ex3_dcbi_instr_offset          :natural := ex1_dcbi_instr_offset + 1;
constant ex1_dcbz_instr_offset          :natural := ex3_dcbi_instr_offset + 1;
constant ex3_dcbz_instr_offset          :natural := ex1_dcbz_instr_offset + 1;
constant ex1_icbi_instr_offset          :natural := ex3_dcbz_instr_offset + 1;
constant ex3_icbi_instr_offset          :natural := ex1_icbi_instr_offset + 1;
constant ex5_icbi_instr_offset          :natural := ex3_icbi_instr_offset + 1;
constant ex1_mbar_instr_offset          :natural := ex5_icbi_instr_offset + 1;
constant ex2_mbar_instr_offset          :natural := ex1_mbar_instr_offset + 1;
constant ex3_mbar_instr_offset          :natural := ex2_mbar_instr_offset + 1;
constant ex1_algebraic_offset           :natural := ex3_mbar_instr_offset + 1;
constant ex3_algebraic_offset           :natural := ex1_algebraic_offset + 1;
constant ex1_byte_rev_offset            :natural := ex3_algebraic_offset + 1;
constant ex3_byte_rev_offset            :natural := ex1_byte_rev_offset + 1;
constant ex1_lock_instr_offset          :natural := ex3_byte_rev_offset + 1;
constant ex3_lock_instr_offset          :natural := ex1_lock_instr_offset + 1;
constant ex5_lock_instr_offset          :natural := ex3_lock_instr_offset + 1;
constant ex1_mutex_hint_offset          :natural := ex5_lock_instr_offset + 1;
constant ex3_mutex_hint_offset          :natural := ex1_mutex_hint_offset + 1;
constant ex1_load_instr_offset          :natural := ex3_mutex_hint_offset + 1;
constant ex3_load_instr_offset          :natural := ex1_load_instr_offset + 1;
constant ex5_load_instr_offset          :natural := ex3_load_instr_offset + 1;
constant ex1_store_instr_offset         :natural := ex5_load_instr_offset + 1;
constant ex3_store_instr_offset         :natural := ex1_store_instr_offset + 1;
constant ex3_l2_op_offset               :natural := ex3_store_instr_offset + 1;
constant ex5_cache_inh_offset           :natural := ex3_l2_op_offset + 1;
constant ex3_opsize_offset              :natural := ex5_cache_inh_offset + 1;
constant ex1_axu_op_val_offset          :natural := ex3_opsize_offset + 6;
constant ex3_axu_op_val_offset          :natural := ex1_axu_op_val_offset + 1;
constant ex5_axu_op_val_offset          :natural := ex3_axu_op_val_offset + 1;
constant rel_upd_gpr_offset             :natural := ex5_axu_op_val_offset + 1;
constant rel_axu_op_val_offset          :natural := rel_upd_gpr_offset + 1;
constant rel_thrd_id_offset             :natural := rel_axu_op_val_offset + 1;
constant rel_ta_gpr_offset              :natural := rel_thrd_id_offset + 4;
constant ex4_load_commit_offset         :natural := rel_ta_gpr_offset + 9;
constant ex5_load_hit_offset            :natural := ex4_load_commit_offset + 1;
constant ex5_axu_rel_val_stg1_offset    :natural := ex5_load_hit_offset + 1;
constant ex5_axu_rel_val_stg2_offset    :natural := ex5_axu_rel_val_stg1_offset + 1;
constant ex5_axu_wren_offset            :natural := ex5_axu_rel_val_stg2_offset + 1;
constant ex5_axu_ta_gpr_offset          :natural := ex5_axu_wren_offset + 4;
constant rel_xu_ta_gpr_offset           :natural := ex5_axu_ta_gpr_offset + 9;
constant lsu_slowspr_val_offset         :natural := rel_xu_ta_gpr_offset + 8;
constant lsu_slowspr_rw_offset          :natural := lsu_slowspr_val_offset + 1;
constant lsu_slowspr_etid_offset        :natural := lsu_slowspr_rw_offset + 1;
constant lsu_slowspr_addr_offset        :natural := lsu_slowspr_etid_offset + 2;
constant lsu_slowspr_data_offset        :natural := lsu_slowspr_addr_offset + 10;
constant lsu_slowspr_done_offset        :natural := lsu_slowspr_data_offset + 2**REGMODE;
constant mm_slowspr_val_offset          :natural := lsu_slowspr_done_offset + 1;
constant mm_slowspr_rw_offset           :natural := mm_slowspr_val_offset + 1;
constant mm_slowspr_etid_offset         :natural := mm_slowspr_rw_offset + 1;
constant mm_slowspr_addr_offset         :natural := mm_slowspr_etid_offset + 2;
constant mm_slowspr_data_offset         :natural := mm_slowspr_addr_offset + 10;
constant mm_slowspr_done_offset         :natural := mm_slowspr_data_offset + 2**REGMODE;
constant ex1_th_fld_c_offset            :natural := mm_slowspr_done_offset + 1;
constant ex3_th_fld_c_offset            :natural := ex1_th_fld_c_offset + 1;
constant ex1_th_fld_l2_offset           :natural := ex3_th_fld_c_offset + 1;
constant ex3_th_fld_l2_offset           :natural := ex1_th_fld_l2_offset + 1;
constant ex1_dcbtls_instr_offset        :natural := ex3_th_fld_l2_offset + 1;
constant ex3_dcbtls_instr_offset        :natural := ex1_dcbtls_instr_offset + 1;
constant ex3_l2_request_offset          :natural := ex3_dcbtls_instr_offset + 1;
constant ex1_dcbtstls_instr_offset      :natural := ex3_l2_request_offset + 1;
constant ex3_dcbtstls_instr_offset      :natural := ex1_dcbtstls_instr_offset + 1;
constant ex1_dcblc_instr_offset         :natural := ex3_dcbtstls_instr_offset + 1;
constant ex3_dcblc_instr_offset         :natural := ex1_dcblc_instr_offset + 1;
constant ex1_icblc_l2_instr_offset      :natural := ex3_dcblc_instr_offset + 1;
constant ex3_icblc_l2_instr_offset      :natural := ex1_icblc_l2_instr_offset + 1;
constant ex1_icbt_l2_instr_offset       :natural := ex3_icblc_l2_instr_offset + 1;
constant ex3_icbt_l2_instr_offset       :natural := ex1_icbt_l2_instr_offset + 1;
constant ex1_icbtls_l2_instr_offset     :natural := ex3_icbt_l2_instr_offset + 1;
constant ex3_icbtls_l2_instr_offset     :natural := ex1_icbtls_l2_instr_offset + 1;
constant ex1_tlbsync_instr_offset       :natural := ex3_icbtls_l2_instr_offset + 1;
constant ex2_tlbsync_instr_offset       :natural := ex1_tlbsync_instr_offset + 1;
constant ex3_tlbsync_instr_offset       :natural := ex2_tlbsync_instr_offset + 1;
constant ex1_src0_vld_offset            :natural := ex3_tlbsync_instr_offset + 1;
constant ex1_src0_reg_offset            :natural := ex1_src0_vld_offset + 1;
constant ex1_src1_vld_offset            :natural := ex1_src0_reg_offset + 8;
constant ex1_src1_reg_offset            :natural := ex1_src1_vld_offset + 1;
constant ex1_targ_vld_offset            :natural := ex1_src1_reg_offset + 8;
constant ex1_targ_reg_offset            :natural := ex1_targ_vld_offset + 1;
constant ex5_instr_val_offset           :natural := ex1_targ_reg_offset + 8;
constant ex2_targ_match_b1_offset       :natural := ex5_instr_val_offset + 1;
constant ex3_targ_match_b1_offset       :natural := ex2_targ_match_b1_offset + 1;
constant ex4_targ_match_b1_offset       :natural := ex3_targ_match_b1_offset + 1;
constant ex5_targ_match_b1_offset       :natural := ex4_targ_match_b1_offset + 1;
constant ex6_targ_match_b1_offset       :natural := ex5_targ_match_b1_offset + 1;
constant ex2_targ_match_b2_offset       :natural := ex6_targ_match_b1_offset + 1;
constant ex3_targ_match_b2_offset       :natural := ex2_targ_match_b2_offset + 1;
constant ex4_targ_match_b2_offset       :natural := ex3_targ_match_b2_offset + 1;
constant ex5_targ_match_b2_offset       :natural := ex4_targ_match_b2_offset + 1;
constant ex7_targ_match_offset          :natural := ex5_targ_match_b2_offset + 1;
constant ex8_targ_match_offset          :natural := ex7_targ_match_offset + 1;
constant ex1_ldst_falign_offset         :natural := ex8_targ_match_offset + 1;
constant ex1_ldst_fexcpt_offset         :natural := ex1_ldst_falign_offset + 1;
constant ex5_load_miss_offset           :natural := ex1_ldst_fexcpt_offset + 1;
constant xucr2_reg_a_offset             :natural := ex5_load_miss_offset + 1;
constant xucr2_reg_b_offset             :natural := xucr2_reg_a_offset + 16;
constant dvc1_act_offset                :natural := xucr2_reg_b_offset + 16;
constant dvc2_act_offset                :natural := dvc1_act_offset + 1;
constant dvc1_reg_offset                :natural := dvc2_act_offset + 1;
constant dvc2_reg_offset                :natural := dvc1_reg_offset + 2**REGMODE;
constant xudbg0_reg_offset              :natural := dvc2_reg_offset + 2**REGMODE;
constant xudbg0_done_reg_offset         :natural := xudbg0_reg_offset + 8;
constant xudbg1_dir_reg_offset          :natural := xudbg0_done_reg_offset + 1;
constant xudbg1_parity_reg_offset       :natural := xudbg1_dir_reg_offset + 13;
constant xudbg2_reg_offset              :natural := xudbg1_parity_reg_offset + parBits;
constant ex4_store_commit_offset        :natural := xudbg2_reg_offset + 31;
constant ex1_sgpr_instr_offset          :natural := ex4_store_commit_offset + 1;
constant ex1_saxu_instr_offset          :natural := ex1_sgpr_instr_offset + 1;
constant ex1_sdp_instr_offset           :natural := ex1_saxu_instr_offset + 1;
constant ex1_tgpr_instr_offset          :natural := ex1_sdp_instr_offset + 1;
constant ex1_taxu_instr_offset          :natural := ex1_tgpr_instr_offset + 1;
constant ex1_tdp_instr_offset           :natural := ex1_taxu_instr_offset + 1;
constant ex2_tgpr_instr_offset          :natural := ex1_tdp_instr_offset + 1;
constant ex2_taxu_instr_offset          :natural := ex2_tgpr_instr_offset + 1;
constant ex2_tdp_instr_offset           :natural := ex2_taxu_instr_offset + 1;
constant ex3_tgpr_instr_offset          :natural := ex2_tdp_instr_offset + 1;
constant ex3_taxu_instr_offset          :natural := ex3_tgpr_instr_offset + 1;
constant ex4_tgpr_instr_offset          :natural := ex3_taxu_instr_offset + 1;
constant ex4_taxu_instr_offset          :natural := ex4_tgpr_instr_offset + 1;
constant ex3_blkable_touch_offset       :natural := ex4_taxu_instr_offset + 1;
constant ex3_p_addr_lwr_offset          :natural := ex3_blkable_touch_offset + 1;
constant ex5_p_addr_offset              :natural := ex3_p_addr_lwr_offset + 12;
constant eplc_wr_offset                 :natural := ex5_p_addr_offset + real_data_add-6;
constant epsc_wr_offset                 :natural := eplc_wr_offset + 4;
constant eplc_t0_reg_a_offset           :natural := epsc_wr_offset + 4;
constant eplc_t0_reg_b_offset           :natural := eplc_t0_reg_a_offset + 2;
constant eplc_t0_reg_c_offset           :natural := eplc_t0_reg_b_offset + 9;
constant eplc_t1_reg_a_offset           :natural := eplc_t0_reg_c_offset + 14;
constant eplc_t1_reg_b_offset           :natural := eplc_t1_reg_a_offset + 2;
constant eplc_t1_reg_c_offset           :natural := eplc_t1_reg_b_offset + 9;
constant eplc_t2_reg_a_offset           :natural := eplc_t1_reg_c_offset + 14;
constant eplc_t2_reg_b_offset           :natural := eplc_t2_reg_a_offset + 2;
constant eplc_t2_reg_c_offset           :natural := eplc_t2_reg_b_offset + 9;
constant eplc_t3_reg_a_offset           :natural := eplc_t2_reg_c_offset + 14;
constant eplc_t3_reg_b_offset           :natural := eplc_t3_reg_a_offset + 2;
constant eplc_t3_reg_c_offset           :natural := eplc_t3_reg_b_offset + 9;
constant epsc_t0_reg_a_offset           :natural := eplc_t3_reg_c_offset + 14;
constant epsc_t0_reg_b_offset           :natural := epsc_t0_reg_a_offset + 2;
constant epsc_t0_reg_c_offset           :natural := epsc_t0_reg_b_offset + 9;
constant epsc_t1_reg_a_offset           :natural := epsc_t0_reg_c_offset + 14;
constant epsc_t1_reg_b_offset           :natural := epsc_t1_reg_a_offset + 2;
constant epsc_t1_reg_c_offset           :natural := epsc_t1_reg_b_offset + 9;
constant epsc_t2_reg_a_offset           :natural := epsc_t1_reg_c_offset + 14;
constant epsc_t2_reg_b_offset           :natural := epsc_t2_reg_a_offset + 2;
constant epsc_t2_reg_c_offset           :natural := epsc_t2_reg_b_offset + 9;
constant epsc_t3_reg_a_offset           :natural := epsc_t2_reg_c_offset + 14;
constant epsc_t3_reg_b_offset           :natural := epsc_t3_reg_a_offset + 2;
constant epsc_t3_reg_c_offset           :natural := epsc_t3_reg_b_offset + 9;
constant ex2_undef_lockset_offset       :natural := epsc_t3_reg_c_offset + 14;
constant ex3_undef_lockset_offset       :natural := ex2_undef_lockset_offset + 1;
constant ex4_unable_2lock_offset        :natural := ex3_undef_lockset_offset + 1;
constant ex5_unable_2lock_offset        :natural := ex4_unable_2lock_offset + 1;
constant ex3_ldstq_instr_offset         :natural := ex5_unable_2lock_offset + 1;
constant ex5_store_instr_offset         :natural := ex3_ldstq_instr_offset + 1;
constant ex5_store_miss_offset          :natural := ex5_store_instr_offset + 1;
constant ex5_perf_dcbt_offset           :natural := ex5_store_miss_offset + 1;
constant perf_lsu_events_offset         :natural := ex5_perf_dcbt_offset + 1;
constant clkg_ctl_override_offset       :natural := perf_lsu_events_offset + 17;
constant spr_xucr0_wlck_offset          :natural := clkg_ctl_override_offset + 1;
constant spr_xucr0_wlck_cpy_offset      :natural := spr_xucr0_wlck_offset + 1;
constant spr_xucr0_flh2l2_offset        :natural := spr_xucr0_wlck_cpy_offset + 1;
constant ex3_spr_xucr0_flh2l2_offset    :natural := spr_xucr0_flh2l2_offset + 1;
constant spr_xucr0_dcdis_offset         :natural := ex3_spr_xucr0_flh2l2_offset + 1;
constant spr_xucr0_cls_offset           :natural := spr_xucr0_dcdis_offset + 1;
constant agen_xucr0_cls_dly_offset      :natural := spr_xucr0_cls_offset + 1;
constant agen_xucr0_cls_offset          :natural := agen_xucr0_cls_dly_offset + 1;
constant mtspr_trace_en_offset          :natural := agen_xucr0_cls_offset + 1;
constant ex3_local_dcbf_offset          :natural := mtspr_trace_en_offset + 4;
constant ex1_msgsnd_instr_offset        :natural := ex3_local_dcbf_offset + 1;
constant ex2_msgsnd_instr_offset        :natural := ex1_msgsnd_instr_offset + 1;
constant ex3_msgsnd_instr_offset        :natural := ex2_msgsnd_instr_offset + 1;
constant ex1_dci_instr_offset           :natural := ex3_msgsnd_instr_offset + 1;
constant ex2_dci_instr_offset           :natural := ex1_dci_instr_offset + 1;
constant ex3_dci_instr_offset           :natural := ex2_dci_instr_offset + 1;
constant ex1_ici_instr_offset           :natural := ex3_dci_instr_offset + 1;
constant ex2_ici_instr_offset           :natural := ex1_ici_instr_offset + 1;
constant ex3_ici_instr_offset           :natural := ex2_ici_instr_offset + 1;
constant ex3_load_type_offset           :natural := ex3_ici_instr_offset + 1;
constant ex3_l2load_type_offset         :natural := ex3_load_type_offset + 1;
constant flh2l2_gate_offset             :natural := ex3_l2load_type_offset + 1;
constant rel_upd_dcarr_offset           :natural := flh2l2_gate_offset + 1;
constant ex5_xu_wren_offset             :natural := rel_upd_dcarr_offset + 1;
constant ex1_ldawx_instr_offset         :natural := ex5_xu_wren_offset + 1;
constant ex3_watch_en_offset            :natural := ex1_ldawx_instr_offset + 1;
constant ex5_watch_en_offset            :natural := ex3_watch_en_offset + 1;
constant ex1_wclr_instr_offset          :natural := ex5_watch_en_offset + 1;
constant ex3_wclr_instr_offset          :natural := ex1_wclr_instr_offset + 1;
constant ex5_wclr_instr_offset          :natural := ex3_wclr_instr_offset + 1;
constant ex5_wclr_set_offset            :natural := ex5_wclr_instr_offset + 1;
constant ex1_wchk_instr_offset          :natural := ex5_wclr_set_offset + 1;
constant ex4_cacheable_linelock_offset  :natural := ex1_wchk_instr_offset + 1;
constant ex1_icswx_instr_offset         :natural := ex4_cacheable_linelock_offset + 1;
constant ex3_icswx_instr_offset         :natural := ex1_icswx_instr_offset + 1;
constant ex1_icswx_dot_instr_offset     :natural := ex3_icswx_instr_offset + 1;
constant ex3_icswx_dot_instr_offset     :natural := ex1_icswx_dot_instr_offset + 1;
constant ex1_icswx_epid_offset          :natural := ex3_icswx_dot_instr_offset + 1;
constant ex3_icswx_epid_offset          :natural := ex1_icswx_epid_offset + 1;
constant ex3_c_inh_drop_op_offset       :natural := ex3_icswx_epid_offset + 1;
constant axu_rel_wren_offset            :natural := ex3_c_inh_drop_op_offset + 1;
constant axu_rel_wren_stg1_offset       :natural := axu_rel_wren_offset + 1;
constant rel_axu_tid_offset             :natural := axu_rel_wren_stg1_offset + 1;
constant rel_axu_tid_stg1_offset        :natural := rel_axu_tid_offset + 4;
constant rel_axu_ta_gpr_offset          :natural := rel_axu_tid_stg1_offset + 4;
constant rel_axu_ta_gpr_stg1_offset     :natural := rel_axu_ta_gpr_offset + 9;
constant rf0_l2_inv_val_offset          :natural := rel_axu_ta_gpr_stg1_offset + 9;
constant rf1_l2_inv_val_offset          :natural := rf0_l2_inv_val_offset + 1;
constant ex1_agen_binv_val_offset       :natural := rf1_l2_inv_val_offset + 1;
constant ex1_l2_inv_val_offset          :natural := ex1_agen_binv_val_offset + 1;
constant lsu_msr_gs_offset              :natural := ex1_l2_inv_val_offset + 1;
constant lsu_msr_pr_offset              :natural := lsu_msr_gs_offset + 4;
constant lsu_msr_cm_offset              :natural := lsu_msr_pr_offset + 4;
constant ex1_lsu_64bit_agen_offset      :natural := lsu_msr_cm_offset + 4;
constant ex6_icbi_val_offset            :natural := ex1_lsu_64bit_agen_offset + 1;
constant ex1_mtspr_trace_offset         :natural := ex6_icbi_val_offset + 4;
constant ex2_mtspr_trace_offset         :natural := ex1_mtspr_trace_offset + 1;
constant ex3_mtspr_trace_offset         :natural := ex2_mtspr_trace_offset + 1;
constant ex3_byte_en_offset             :natural := ex3_mtspr_trace_offset + 1;
constant ex3_rot_sel_le_offset          :natural := ex3_byte_en_offset + 32;
constant ex3_rot_sel_be_offset          :natural := ex3_rot_sel_le_offset + 5;
constant dir_arr_rd_val_offset          :natural := ex3_rot_sel_be_offset + 5;
constant dir_arr_rd_is0_val_offset      :natural := dir_arr_rd_val_offset + 1;
constant dir_arr_rd_is1_val_offset      :natural := dir_arr_rd_is0_val_offset + 1;
constant dir_arr_rd_is2_val_offset      :natural := dir_arr_rd_is1_val_offset + 1;
constant dir_arr_rd_rf0_val_offset      :natural := dir_arr_rd_is2_val_offset + 1;
constant dir_arr_rd_rf1_val_offset      :natural := dir_arr_rd_rf0_val_offset + 1;
constant dir_arr_rd_rf0_done_offset     :natural := dir_arr_rd_rf1_val_offset + 1;
constant dir_arr_rd_rf1_done_offset     :natural := dir_arr_rd_rf0_done_offset + 1;
constant dir_arr_rd_ex1_done_offset     :natural := dir_arr_rd_rf1_done_offset + 1;
constant dir_arr_rd_ex2_done_offset     :natural := dir_arr_rd_ex1_done_offset + 1;
constant dir_arr_rd_ex3_done_offset     :natural := dir_arr_rd_ex2_done_offset + 1;
constant dir_arr_rd_ex4_done_offset     :natural := dir_arr_rd_ex3_done_offset + 1;
constant my_spare0_latches_offset       :natural := dir_arr_rd_ex4_done_offset + 1;
constant my_spare1_latches_offset       :natural := my_spare0_latches_offset + 3;
constant rf1_stg_act_offset             :natural := my_spare1_latches_offset + 20;
constant ex1_stg_act_offset      	:natural := rf1_stg_act_offset + 1;
constant ex3_stg_act_offset      	:natural := ex1_stg_act_offset + 1;
constant ex5_stg_act_offset     	:natural := ex3_stg_act_offset + 1;
constant binv1_stg_act_offset           :natural := ex5_stg_act_offset + 1;
constant binv3_stg_act_offset           :natural := binv1_stg_act_offset + 1;
constant binv5_stg_act_offset           :natural := binv3_stg_act_offset + 1;
constant rel1_stg_act_offset            :natural := binv5_stg_act_offset + 1;
constant rel3_stg_act_offset            :natural := rel1_stg_act_offset + 1;
constant scan_right                     :natural := rel3_stg_act_offset + 1 - 1;

-- SlowSPR addresses
constant XUCR2_ADDR                     :std_ulogic_vector(0 to 9) := "11" & x"F8";
constant XUDBG0_ADDR                    :std_ulogic_vector(0 to 9) := "11" & x"75";
constant XUDBG1_ADDR                    :std_ulogic_vector(0 to 9) := "11" & x"76";
constant XUDBG2_ADDR                    :std_ulogic_vector(0 to 9) := "11" & x"77";
constant DVC1_ADDR                      :std_ulogic_vector(0 to 9) := "01" & x"3E";
constant DVC2_ADDR                      :std_ulogic_vector(0 to 9) := "01" & x"3F";
constant EPLC_ADDR                      :std_ulogic_vector(0 to 9) := "11" & x"B3";
constant EPSC_ADDR                      :std_ulogic_vector(0 to 9) := "11" & x"B4";

----------------------------
-- signals
----------------------------
signal ex1_optype1_d            :std_ulogic;
signal ex2_optype1_d            :std_ulogic;
signal ex1_optype2_d            :std_ulogic;
signal ex2_optype2_d            :std_ulogic;
signal ex1_optype4_d            :std_ulogic;
signal ex2_optype4_d            :std_ulogic;
signal ex1_optype8_d            :std_ulogic;
signal ex2_optype8_d            :std_ulogic;
signal ex1_optype16_d           :std_ulogic;
signal ex2_optype16_d           :std_ulogic;
signal ex1_optype32_d           :std_ulogic;
signal ex2_optype32_d           :std_ulogic;
signal ex1_dir_acc_val_d        :std_ulogic;
signal ex1_dir_acc_val_q        :std_ulogic;
signal cache_acc_ex1_d          :std_ulogic;
signal cache_acc_ex2_d          :std_ulogic;
signal cache_acc_ex3_d          :std_ulogic;
signal cache_acc_ex4_d          :std_ulogic;
signal cache_acc_ex5_d          :std_ulogic;
signal ex2_cacc_d               :std_ulogic;
signal ex2_cacc_q               :std_ulogic;
signal ex3_cacc_d               :std_ulogic;
signal ex3_cacc_q               :std_ulogic;
signal ex1_thrd_id_d            :std_ulogic_vector(0 to 3);
signal ex2_thrd_id_d            :std_ulogic_vector(0 to 3);
signal ex3_thrd_id_d            :std_ulogic_vector(0 to 3);
signal ex4_thrd_id_d            :std_ulogic_vector(0 to 3);
signal ex5_thrd_id_d            :std_ulogic_vector(0 to 3);
signal ex1_target_gpr_d         :std_ulogic_vector(0 to 8);
signal ex2_target_gpr_d         :std_ulogic_vector(0 to 8);
signal ex3_target_gpr_d         :std_ulogic_vector(0 to 8);
signal ex4_target_gpr_d         :std_ulogic_vector(0 to 8);
signal ex1_dcbt_instr_d         :std_ulogic;
signal ex2_dcbt_instr_d         :std_ulogic;
signal ex3_dcbt_instr_d         :std_ulogic;
signal ex1_dcbtst_instr_d       :std_ulogic;
signal ex2_dcbtst_instr_d       :std_ulogic;
signal ex3_dcbtst_instr_d       :std_ulogic;
signal ex1_dcbst_instr_d        :std_ulogic;
signal ex2_dcbst_instr_d        :std_ulogic;
signal ex3_dcbst_instr_d        :std_ulogic;
signal ex1_dcbf_instr_d         :std_ulogic;
signal ex2_dcbf_instr_d         :std_ulogic;
signal ex3_dcbf_instr_d         :std_ulogic;
signal ex1_sync_instr_d         :std_ulogic;
signal ex2_sync_instr_d         :std_ulogic;
signal ex3_sync_instr_d         :std_ulogic;
signal ex1_l_fld_d              :std_ulogic_vector(0 to 1);
signal ex2_l_fld_d              :std_ulogic_vector(0 to 1);
signal ex3_l_fld_d              :std_ulogic_vector(0 to 1);
signal ex1_dcbi_instr_d         :std_ulogic;
signal ex2_dcbi_instr_d         :std_ulogic;
signal ex3_dcbi_instr_d         :std_ulogic;
signal ex1_dcbz_instr_d         :std_ulogic;
signal ex2_dcbz_instr_d         :std_ulogic;
signal ex3_dcbz_instr_d         :std_ulogic;
signal ex1_icbi_instr_d         :std_ulogic;
signal ex2_icbi_instr_d         :std_ulogic;
signal ex3_icbi_instr_d         :std_ulogic;
signal ex4_icbi_instr_d         :std_ulogic;
signal ex5_icbi_instr_d         :std_ulogic;
signal ex1_mbar_instr_d         :std_ulogic;
signal ex2_mbar_instr_d         :std_ulogic;
signal ex3_mbar_instr_d         :std_ulogic;
signal ex1_lock_instr_d         :std_ulogic;
signal ex2_lock_instr_d         :std_ulogic;
signal ex3_lock_instr_d         :std_ulogic;
signal ex4_lock_instr_d         :std_ulogic;
signal ex5_lock_instr_d         :std_ulogic;
signal ex1_load_instr_d         :std_ulogic;
signal ex2_load_instr_d         :std_ulogic;
signal ex3_load_instr_d         :std_ulogic;
signal ex4_load_instr_d         :std_ulogic;
signal ex5_load_instr_d         :std_ulogic;
signal ex3_load_type_d          :std_ulogic;
signal ex3_load_type_q          :std_ulogic;
signal ex4_load_type_d          :std_ulogic;
signal ex4_load_type_q          :std_ulogic;
signal ex1_store_instr_d        :std_ulogic;
signal ex2_store_instr_d        :std_ulogic;
signal ex3_store_instr_d        :std_ulogic;
signal ex1_optype1_q            :std_ulogic;
signal ex2_optype1_q            :std_ulogic;
signal ex1_optype2_q            :std_ulogic;
signal ex2_optype2_q            :std_ulogic;
signal ex1_optype4_q            :std_ulogic;
signal ex2_optype4_q            :std_ulogic;
signal ex1_optype8_q            :std_ulogic;
signal ex2_optype8_q            :std_ulogic;
signal ex1_optype16_q           :std_ulogic;
signal ex2_optype16_q           :std_ulogic;
signal ex1_optype32_q           :std_ulogic;
signal ex2_optype32_q           :std_ulogic;
signal cache_acc_ex1_q          :std_ulogic;
signal cache_acc_ex2_q          :std_ulogic;
signal cache_acc_ex3_q          :std_ulogic;
signal cache_acc_ex4_q          :std_ulogic;
signal cache_acc_ex5_q          :std_ulogic;
signal ex1_thrd_id_q            :std_ulogic_vector(0 to 3);
signal ex2_thrd_id_q            :std_ulogic_vector(0 to 3);
signal ex3_thrd_id_q            :std_ulogic_vector(0 to 3);
signal ex4_thrd_id_q            :std_ulogic_vector(0 to 3);
signal ex5_thrd_id_q            :std_ulogic_vector(0 to 3);
signal ex1_target_gpr_q         :std_ulogic_vector(0 to 8);
signal ex2_target_gpr_q         :std_ulogic_vector(0 to 8);
signal ex3_target_gpr_q         :std_ulogic_vector(0 to 8);
signal ex4_target_gpr_q         :std_ulogic_vector(0 to 8);
signal ex1_dcbt_instr_q         :std_ulogic;
signal ex2_dcbt_instr_q         :std_ulogic;
signal ex3_dcbt_instr_q         :std_ulogic;
signal ex1_dcbtst_instr_q       :std_ulogic;
signal ex2_dcbtst_instr_q       :std_ulogic;
signal ex3_dcbtst_instr_q       :std_ulogic;
signal ex1_dcbst_instr_q        :std_ulogic;
signal ex2_dcbst_instr_q        :std_ulogic;
signal ex3_dcbst_instr_q        :std_ulogic;
signal ex1_dcbf_instr_q         :std_ulogic;
signal ex2_dcbf_instr_q         :std_ulogic;
signal ex3_dcbf_instr_q         :std_ulogic;
signal ex1_sync_instr_q         :std_ulogic;
signal ex2_sync_instr_q         :std_ulogic;
signal ex3_sync_instr_q         :std_ulogic;
signal ex1_l_fld_q              :std_ulogic_vector(0 to 1);
signal ex2_l_fld_q              :std_ulogic_vector(0 to 1);
signal ex3_l_fld_q              :std_ulogic_vector(0 to 1);
signal ex1_dcbi_instr_q         :std_ulogic;
signal ex2_dcbi_instr_q         :std_ulogic;
signal ex3_dcbi_instr_q         :std_ulogic;
signal ex1_dcbz_instr_q         :std_ulogic;
signal ex2_dcbz_instr_q         :std_ulogic;
signal ex3_dcbz_instr_q         :std_ulogic;
signal ex1_icbi_instr_q         :std_ulogic;
signal ex2_icbi_instr_q         :std_ulogic;
signal ex3_icbi_instr_q         :std_ulogic;
signal ex4_icbi_instr_q         :std_ulogic;
signal ex5_icbi_instr_q         :std_ulogic;
signal ex5_icbi_instr           :std_ulogic;
signal ex1_mbar_instr_q         :std_ulogic;
signal ex2_mbar_instr_q         :std_ulogic;
signal ex3_mbar_instr_q         :std_ulogic;
signal ex1_lock_instr_q         :std_ulogic;
signal ex2_lock_instr_q         :std_ulogic;
signal ex3_lock_instr_q         :std_ulogic;
signal ex4_lock_instr_q         :std_ulogic;
signal ex5_lock_instr_q         :std_ulogic;
signal ex1_load_instr_q         :std_ulogic;
signal ex2_load_instr_q         :std_ulogic;
signal ex3_load_instr_q         :std_ulogic;
signal ex4_load_instr_q         :std_ulogic;
signal ex5_load_instr_q         :std_ulogic;
signal ex1_store_instr_q        :std_ulogic;
signal ex2_store_instr_q        :std_ulogic;
signal ex3_store_instr_q        :std_ulogic;
signal ex4_cache_inh_d          :std_ulogic;
signal ex4_cache_inh_q          :std_ulogic;
signal ex5_cache_inh_d          :std_ulogic;
signal ex5_cache_inh_q          :std_ulogic;
signal l_s_q_val                :std_ulogic;
signal stx_instr                :std_ulogic;
signal larx_instr               :std_ulogic;
signal is_mem_bar_op            :std_ulogic;
signal is_inval_op              :std_ulogic;
signal is_lock_set              :std_ulogic;
signal ex3_l2_lock_set          :std_ulogic;
signal ex3_c_dcbtls             :std_ulogic;
signal ex3_c_dcbtstls           :std_ulogic;
signal ex3_c_icbtls             :std_ulogic;
signal ex3_l2_dcbtls            :std_ulogic;
signal ex3_l2_dcbtstls          :std_ulogic;
signal ex3_l2_icbtls            :std_ulogic;
signal is_lock_clr              :std_ulogic;
signal no_lru_upd               :std_ulogic;
signal l2_ctype                 :std_ulogic;
signal reg_upd_thrd_id          :std_ulogic_vector(0 to 3);
signal reg_upd_ta_gpr           :std_ulogic_vector(0 to 8);
signal xu_wren                  :std_ulogic;
signal ex5_xu_wren_d            :std_ulogic;
signal ex5_xu_wren_q            :std_ulogic;
signal axu_wren                 :std_ulogic;
signal axu_rel_wren_d           :std_ulogic;
signal axu_rel_wren_q           :std_ulogic;
signal axu_rel_wren_stg1_d      :std_ulogic;
signal axu_rel_wren_stg1_q      :std_ulogic;
signal rel_thrd_id_d            :std_ulogic_vector(0 to 3);
signal rel_thrd_id_q            :std_ulogic_vector(0 to 3);
signal rel_ta_gpr_d             :std_ulogic_vector(0 to 8);
signal rel_ta_gpr_q             :std_ulogic_vector(0 to 8);
signal rel_upd_gpr_d            :std_ulogic;
signal rel_upd_gpr_q            :std_ulogic;
signal rel_axu_op_val_d         :std_ulogic;
signal rel_axu_op_val_q         :std_ulogic;
signal ex4_load_miss            :std_ulogic;
signal ex5_load_miss_d          :std_ulogic;
signal ex5_load_miss_q          :std_ulogic;
signal ex3_l2_op_d              :std_ulogic;
signal ex3_l2_op_q              :std_ulogic;
signal ex4_load_hit             :std_ulogic;
signal ex4_load_commit_d        :std_ulogic;
signal ex4_load_commit_q        :std_ulogic;
signal ex5_load_hit_d           :std_ulogic;
signal ex5_load_hit_q           :std_ulogic;
signal ex1_axu_op_val_d         :std_ulogic;
signal ex1_axu_op_val_q         :std_ulogic;
signal ex2_axu_op_val_d         :std_ulogic;
signal ex2_axu_op_val_q         :std_ulogic;
signal ex3_axu_op_val_d         :std_ulogic;
signal ex3_axu_op_val_q         :std_ulogic;
signal ex4_axu_op_val_d         :std_ulogic;
signal ex4_axu_op_val_q         :std_ulogic;
signal ex5_axu_op_val_d         :std_ulogic;
signal ex5_axu_op_val_q         :std_ulogic;
signal ex2_op_sel               :std_ulogic_vector(0 to 15);
signal ex2_opsize               :std_ulogic_vector(0 to 5);
signal ex3_opsize_d             :std_ulogic_vector(0 to 5);
signal ex3_opsize_q             :std_ulogic_vector(0 to 5);
signal ex5_axu_wren_d           :std_ulogic_vector(0 to 3);
signal ex5_axu_wren_q           :std_ulogic_vector(0 to 3);
signal ex5_axu_wren_val         :std_ulogic;
signal ex5_axu_ta_gpr_d         :std_ulogic_vector(0 to 8);
signal ex5_axu_ta_gpr_q         :std_ulogic_vector(0 to 8);
signal rel_xu_ta_gpr_d          :std_ulogic_vector(0 to 7);
signal rel_xu_ta_gpr_q          :std_ulogic_vector(0 to 7);
signal ex1_algebraic_d          :std_ulogic;
signal ex1_algebraic_q          :std_ulogic;
signal ex2_algebraic_d          :std_ulogic;
signal ex2_algebraic_q          :std_ulogic;
signal ex3_algebraic_d          :std_ulogic;
signal ex3_algebraic_q          :std_ulogic;
signal ex1_byte_rev_d           :std_ulogic;
signal ex1_byte_rev_q           :std_ulogic;
signal ex2_byte_rev_d           :std_ulogic;
signal ex2_byte_rev_q           :std_ulogic;
signal ex3_byte_rev_d           :std_ulogic;
signal ex3_byte_rev_q           :std_ulogic;
signal lsu_slowspr_val_d        :std_ulogic;
signal lsu_slowspr_rw_d         :std_ulogic;
signal lsu_slowspr_etid_d       :std_ulogic_vector(0 to 1);
signal lsu_slowspr_addr_d       :std_ulogic_vector(0 to 9);
signal lsu_slowspr_data_d       :std_ulogic_vector(64-(2**REGMODE) to 63);
signal lsu_slowspr_done_d       :std_ulogic;
signal lsu_slowspr_val_q        :std_ulogic;
signal lsu_slowspr_rw_q         :std_ulogic;
signal lsu_slowspr_etid_q       :std_ulogic_vector(0 to 1);
signal lsu_slowspr_addr_q       :std_ulogic_vector(0 to 9);
signal lsu_slowspr_data_q       :std_ulogic_vector(64-(2**REGMODE) to 63);
signal lsu_slowspr_done_q       :std_ulogic;
signal mm_slowspr_val_d         :std_ulogic;
signal mm_slowspr_rw_d          :std_ulogic;
signal mm_slowspr_etid_d        :std_ulogic_vector(0 to 1);
signal mm_slowspr_addr_d        :std_ulogic_vector(0 to 9);
signal mm_slowspr_data_d        :std_ulogic_vector(64-(2**REGMODE) to 63);
signal mm_slowspr_done_d        :std_ulogic;
signal mm_slowspr_val_q         :std_ulogic;
signal mm_slowspr_rw_q          :std_ulogic;
signal mm_slowspr_etid_q        :std_ulogic_vector(0 to 1);
signal mm_slowspr_addr_q        :std_ulogic_vector(0 to 9);
signal mm_slowspr_data_q        :std_ulogic_vector(64-(2**REGMODE) to 63);
signal mm_slowspr_done_q        :std_ulogic;
signal ex3_nogpr_upd            :std_ulogic;
signal rf1_th_b0                :std_ulogic;
signal ex1_th_fld_c_d           :std_ulogic;
signal ex1_th_fld_c_q           :std_ulogic;
signal ex2_th_fld_c_d           :std_ulogic;
signal ex2_th_fld_c_q           :std_ulogic;
signal ex3_th_fld_c_d           :std_ulogic;
signal ex3_th_fld_c_q           :std_ulogic;
signal ex1_th_fld_l2_d          :std_ulogic;
signal ex1_th_fld_l2_q          :std_ulogic;
signal ex2_th_fld_l2_d          :std_ulogic;
signal ex2_th_fld_l2_q          :std_ulogic;
signal ex3_th_fld_l2_d          :std_ulogic;
signal ex3_th_fld_l2_q          :std_ulogic;
signal ex1_undef_touch          :std_ulogic;
signal ex1_dcbtls_instr_d       :std_ulogic;
signal ex1_dcbtls_instr_q       :std_ulogic;
signal ex2_dcbtls_instr_d       :std_ulogic;
signal ex2_dcbtls_instr_q       :std_ulogic;
signal ex3_dcbtls_instr_d       :std_ulogic;
signal ex3_dcbtls_instr_q       :std_ulogic;
signal ex1_dcbtstls_instr_d     :std_ulogic;
signal ex1_dcbtstls_instr_q     :std_ulogic;
signal ex2_dcbtstls_instr_d     :std_ulogic;
signal ex2_dcbtstls_instr_q     :std_ulogic;
signal ex3_dcbtstls_instr_d     :std_ulogic;
signal ex3_dcbtstls_instr_q     :std_ulogic;
signal ex1_dcblc_instr_d        :std_ulogic;
signal ex1_dcblc_instr_q        :std_ulogic;
signal ex2_dcblc_instr_d        :std_ulogic;
signal ex2_dcblc_instr_q        :std_ulogic;
signal ex3_dcblc_instr_d        :std_ulogic;
signal ex3_dcblc_instr_q        :std_ulogic;
signal ex1_icblc_l2_instr_d     :std_ulogic;
signal ex1_icblc_l2_instr_q     :std_ulogic;
signal ex2_icblc_l2_instr_d     :std_ulogic;
signal ex2_icblc_l2_instr_q     :std_ulogic;
signal ex3_icblc_l2_instr_d     :std_ulogic;
signal ex3_icblc_l2_instr_q     :std_ulogic;
signal ex1_icbt_l2_instr_d      :std_ulogic;
signal ex1_icbt_l2_instr_q      :std_ulogic;
signal ex2_icbt_l2_instr_d      :std_ulogic;
signal ex2_icbt_l2_instr_q      :std_ulogic;
signal ex3_icbt_l2_instr_d      :std_ulogic;
signal ex3_icbt_l2_instr_q      :std_ulogic;
signal ex1_icbtls_l2_instr_d    :std_ulogic;
signal ex1_icbtls_l2_instr_q    :std_ulogic;
signal ex2_icbtls_l2_instr_d    :std_ulogic;
signal ex2_icbtls_l2_instr_q    :std_ulogic;
signal ex3_icbtls_l2_instr_d    :std_ulogic;
signal ex3_icbtls_l2_instr_q    :std_ulogic;
signal ex1_tlbsync_instr_d      :std_ulogic;
signal ex1_tlbsync_instr_q      :std_ulogic;
signal ex2_tlbsync_instr_d      :std_ulogic;
signal ex2_tlbsync_instr_q      :std_ulogic;
signal ex3_tlbsync_instr_d      :std_ulogic;
signal ex3_tlbsync_instr_q      :std_ulogic;
signal ex1_src0_vld_d           :std_ulogic;
signal ex1_src0_vld_q           :std_ulogic;
signal ex1_src0_reg_d           :std_ulogic_vector(0 to 7);
signal ex1_src0_reg_q           :std_ulogic_vector(0 to 7);
signal ex1_src1_vld_d           :std_ulogic;
signal ex1_src1_vld_q           :std_ulogic;
signal ex1_src1_reg_d           :std_ulogic_vector(0 to 7);
signal ex1_src1_reg_q           :std_ulogic_vector(0 to 7);
signal ex1_targ_vld_d           :std_ulogic;
signal ex1_targ_vld_q           :std_ulogic;
signal ex1_targ_reg_d           :std_ulogic_vector(0 to 7);
signal ex1_targ_reg_q           :std_ulogic_vector(0 to 7);
signal ex5_instr_val_d          :std_ulogic;
signal ex5_instr_val_q          :std_ulogic;
signal ex2_targ_match_b1_d      :std_ulogic;
signal ex2_targ_match_b1_q      :std_ulogic;
signal ex3_targ_match_b1_d      :std_ulogic;
signal ex3_targ_match_b1_q      :std_ulogic;
signal ex4_targ_match_b1_d      :std_ulogic;
signal ex4_targ_match_b1_q      :std_ulogic;
signal ex5_targ_match_b1_d      :std_ulogic;
signal ex5_targ_match_b1_q      :std_ulogic;
signal ex6_targ_match_b1_d      :std_ulogic;
signal ex6_targ_match_b1_q      :std_ulogic;
signal ex2_targ_match_b2_d      :std_ulogic;
signal ex2_targ_match_b2_q      :std_ulogic;
signal ex3_targ_match_b2_d      :std_ulogic;
signal ex3_targ_match_b2_q      :std_ulogic;
signal ex4_targ_match_b2_d      :std_ulogic;
signal ex4_targ_match_b2_q      :std_ulogic;
signal ex5_targ_match_b2_d      :std_ulogic;
signal ex5_targ_match_b2_q      :std_ulogic;
signal ex7_targ_match_d         :std_ulogic;
signal ex7_targ_match_q         :std_ulogic;
signal ex8_targ_match_d         :std_ulogic;
signal ex8_targ_match_q         :std_ulogic;
signal ex3_l2_request_d         :std_ulogic;
signal ex3_l2_request_q         :std_ulogic;
signal ex1_ldst_falign_d        :std_ulogic;
signal ex1_ldst_falign_q        :std_ulogic;
signal ex1_ldst_fexcpt_d        :std_ulogic;
signal ex1_ldst_fexcpt_q        :std_ulogic;
signal ex2_ldst_fexcpt_d        :std_ulogic;
signal ex2_ldst_fexcpt_q        :std_ulogic;
signal xucr2_sel                :std_ulogic;
signal dvc1_sel                 :std_ulogic;
signal dvc2_sel                 :std_ulogic;
signal eplc_sel                 :std_ulogic;
signal epsc_sel                 :std_ulogic;
signal xudbg0_sel               :std_ulogic;
signal xudbg1_sel               :std_ulogic;
signal xudbg2_sel               :std_ulogic;
signal xucr2_wen                :std_ulogic;
signal dvc1_wen                 :std_ulogic;
signal dvc1_act_d               :std_ulogic;
signal dvc1_act_q               :std_ulogic;
signal dvc2_wen                 :std_ulogic;
signal dvc2_act_d               :std_ulogic;
signal dvc2_act_q               :std_ulogic;
signal xudbg0_wen               :std_ulogic;
signal eplc_t0_wen              :std_ulogic;
signal eplc_t0_hyp_wen          :std_ulogic;
signal eplc_t1_wen              :std_ulogic;
signal eplc_t1_hyp_wen          :std_ulogic;
signal eplc_t2_wen              :std_ulogic;
signal eplc_t2_hyp_wen          :std_ulogic;
signal eplc_t3_wen              :std_ulogic;
signal eplc_t3_hyp_wen          :std_ulogic;
signal epsc_t0_wen              :std_ulogic;
signal epsc_t0_hyp_wen          :std_ulogic;
signal epsc_t1_wen              :std_ulogic;
signal epsc_t1_hyp_wen          :std_ulogic;
signal epsc_t2_wen              :std_ulogic;
signal epsc_t2_hyp_wen          :std_ulogic;
signal epsc_t3_wen              :std_ulogic;
signal epsc_t3_hyp_wen          :std_ulogic;
signal xucr2_reg                :std_ulogic_vector((64-(2**REGMODE)) to 63);
signal xucr2_reg_d              :std_ulogic_vector(0 to 31);
signal xucr2_reg_q              :std_ulogic_vector(0 to 31);
signal dvc1_reg                 :std_ulogic_vector((64-(2**REGMODE)) to 63);
signal dvc1_reg_d               :std_ulogic_vector((64-(2**REGMODE)) to 63);
signal dvc1_reg_q               :std_ulogic_vector((64-(2**REGMODE)) to 63);
signal dvc2_reg                 :std_ulogic_vector((64-(2**REGMODE)) to 63);
signal dvc2_reg_d               :std_ulogic_vector((64-(2**REGMODE)) to 63);
signal dvc2_reg_q               :std_ulogic_vector((64-(2**REGMODE)) to 63);
signal xudbg0_reg               :std_ulogic_vector((64-(2**REGMODE)) to 63);
signal xudbg0_reg_d             :std_ulogic_vector(0 to 7);
signal xudbg0_reg_q             :std_ulogic_vector(0 to 7);
signal xudbg0_done_reg_d        :std_ulogic;
signal xudbg0_done_reg_q        :std_ulogic;
signal xudbg1_reg               :std_ulogic_vector((64-(2**REGMODE)) to 63);
signal xudbg1_dir_reg_d         :std_ulogic_vector(0 to 12);
signal xudbg1_dir_reg_q         :std_ulogic_vector(0 to 12);
signal xudbg1_parity_reg_d      :std_ulogic_vector(0 to parBits-1);
signal xudbg1_parity_reg_q      :std_ulogic_vector(0 to parBits-1);
signal xudbg2_reg               :std_ulogic_vector((64-(2**REGMODE)) to 63);
signal xudbg2_reg_d             :std_ulogic_vector(64-real_data_add to 63-(dc_size-3));
signal xudbg2_reg_q             :std_ulogic_vector(64-real_data_add to 63-(dc_size-3));
signal eplc_t0_reg              :std_ulogic_vector(0 to 24);
signal eplc_t0_reg_d            :std_ulogic_vector(0 to 24);
signal eplc_t0_reg_q            :std_ulogic_vector(0 to 24);
signal eplc_t1_reg              :std_ulogic_vector(0 to 24);
signal eplc_t1_reg_d            :std_ulogic_vector(0 to 24);
signal eplc_t1_reg_q            :std_ulogic_vector(0 to 24);
signal eplc_t2_reg              :std_ulogic_vector(0 to 24);
signal eplc_t2_reg_d            :std_ulogic_vector(0 to 24);
signal eplc_t2_reg_q            :std_ulogic_vector(0 to 24);
signal eplc_t3_reg              :std_ulogic_vector(0 to 24);
signal eplc_t3_reg_d            :std_ulogic_vector(0 to 24);
signal eplc_t3_reg_q            :std_ulogic_vector(0 to 24);
signal epsc_t0_reg              :std_ulogic_vector(0 to 24);
signal epsc_t0_reg_d            :std_ulogic_vector(0 to 24);
signal epsc_t0_reg_q            :std_ulogic_vector(0 to 24);
signal epsc_t1_reg              :std_ulogic_vector(0 to 24);
signal epsc_t1_reg_d            :std_ulogic_vector(0 to 24);
signal epsc_t1_reg_q            :std_ulogic_vector(0 to 24);
signal epsc_t2_reg              :std_ulogic_vector(0 to 24);
signal epsc_t2_reg_d            :std_ulogic_vector(0 to 24);
signal epsc_t2_reg_q            :std_ulogic_vector(0 to 24);
signal epsc_t3_reg              :std_ulogic_vector(0 to 24);
signal epsc_t3_reg_d            :std_ulogic_vector(0 to 24);
signal epsc_t3_reg_q            :std_ulogic_vector(0 to 24);
signal eplc_thrd_reg            :std_ulogic_vector(0 to 24);
signal epsc_thrd_reg            :std_ulogic_vector(0 to 24);
signal eplc_reg                 :std_ulogic_vector((64-(2**REGMODE)) to 63);
signal epsc_reg                 :std_ulogic_vector((64-(2**REGMODE)) to 63);
signal eplc_wrt_data            :std_ulogic_vector(0 to 24);
signal epsc_wrt_data            :std_ulogic_vector(0 to 24);
signal spr_l1dc_rd_val          :std_ulogic;
signal spr_l1dc_reg             :std_ulogic_vector((64-(2**REGMODE)) to 63);
signal way_lck_rmt              :std_ulogic_vector(0 to 31);
signal clkg_ctl_override_d      :std_ulogic;
signal clkg_ctl_override_q      :std_ulogic;
signal spr_xucr0_wlck_d         :std_ulogic;
signal spr_xucr0_wlck_q         :std_ulogic;
signal spr_xucr0_wlck_cpy_d     :std_ulogic;
signal spr_xucr0_wlck_cpy_q     :std_ulogic;
signal spr_xucr0_flh2l2_d       :std_ulogic;
signal spr_xucr0_flh2l2_q       :std_ulogic;
signal ex2_spr_xucr0_flh2l2     :std_ulogic;
signal ex3_spr_xucr0_flh2l2_d   :std_ulogic;
signal ex3_spr_xucr0_flh2l2_q   :std_ulogic;
signal spr_xucr0_dcdis_d        :std_ulogic;
signal spr_xucr0_dcdis_q        :std_ulogic;
signal spr_xucr0_cls_d          :std_ulogic;
signal spr_xucr0_cls_q          :std_ulogic;
signal agen_xucr0_cls_d         :std_ulogic;
signal agen_xucr0_cls_q         :std_ulogic;
signal agen_xucr0_cls_dly_d     :std_ulogic;
signal agen_xucr0_cls_dly_q     :std_ulogic;
signal ex4_store_commit_d       :std_ulogic;
signal ex4_store_commit_q       :std_ulogic;
signal ex1_sgpr_instr_d         :std_ulogic;
signal ex1_sgpr_instr_q         :std_ulogic;
signal ex1_saxu_instr_d         :std_ulogic;
signal ex1_saxu_instr_q         :std_ulogic;
signal ex1_sdp_instr_d          :std_ulogic;
signal ex1_sdp_instr_q          :std_ulogic;
signal ex1_tgpr_instr_d         :std_ulogic;
signal ex1_tgpr_instr_q         :std_ulogic;
signal ex1_taxu_instr_d         :std_ulogic;
signal ex1_taxu_instr_q         :std_ulogic;
signal ex1_tdp_instr_d          :std_ulogic;
signal ex1_tdp_instr_q          :std_ulogic;
signal ex2_tgpr_instr_d         :std_ulogic;
signal ex2_tgpr_instr_q         :std_ulogic;
signal ex2_taxu_instr_d         :std_ulogic;
signal ex2_taxu_instr_q         :std_ulogic;
signal ex2_tdp_instr_d          :std_ulogic;
signal ex2_tdp_instr_q          :std_ulogic;
signal ex3_tgpr_instr_d         :std_ulogic;
signal ex3_tgpr_instr_q         :std_ulogic;
signal ex3_taxu_instr_d         :std_ulogic;
signal ex3_taxu_instr_q         :std_ulogic;
signal ex4_tgpr_instr_d         :std_ulogic;
signal ex4_tgpr_instr_q         :std_ulogic;
signal ex4_taxu_instr_d         :std_ulogic;
signal ex4_taxu_instr_q         :std_ulogic;
signal ex4_tgpr_instr           :std_ulogic;
signal ex4_taxu_instr           :std_ulogic;
signal ex2_dcblc_l1             :std_ulogic;
signal data_touch_op            :std_ulogic;
signal inst_touch_op            :std_ulogic;
signal all_touch_op             :std_ulogic;
signal ddir_acc_instr           :std_ulogic;
signal ex2_blkable_touch_d      :std_ulogic;
signal ex2_blkable_touch_q      :std_ulogic;
signal ex3_blkable_touch_d      :std_ulogic;
signal ex3_blkable_touch_q      :std_ulogic;
signal ex3_blk_touch            :std_ulogic;
signal ex2_l2_dcbf              :std_ulogic;
signal ex2_local_dcbf           :std_ulogic;
signal ex1_mutex_hint_d         :std_ulogic;
signal ex1_mutex_hint_q         :std_ulogic;
signal ex2_mutex_hint_d         :std_ulogic;
signal ex2_mutex_hint_q         :std_ulogic;
signal ex3_mutex_hint_d         :std_ulogic;
signal ex3_mutex_hint_q         :std_ulogic;
signal ex3_p_addr_lwr_d         :std_ulogic_vector(52 to 63);
signal ex3_p_addr_lwr_q         :std_ulogic_vector(52 to 63);
signal ex4_p_addr_d             :std_ulogic_vector(64-real_data_add to 63);
signal ex4_p_addr_q             :std_ulogic_vector(64-real_data_add to 63);
signal ex5_p_addr_d             :std_ulogic_vector(64-real_data_add to 57);
signal ex5_p_addr_q             :std_ulogic_vector(64-real_data_add to 57);
signal ex6_p_addr_d             :std_ulogic_vector(64-real_data_add to 57);
signal ex6_p_addr_q             :std_ulogic_vector(64-real_data_add to 57);
signal eplc_wr_d                :std_ulogic_vector(0 to 3);
signal eplc_wr_q                :std_ulogic_vector(0 to 3);
signal epsc_wr_d                :std_ulogic_vector(0 to 3);
signal epsc_wr_q                :std_ulogic_vector(0 to 3);
signal ex1_lockset_instr        :std_ulogic;
signal ex2_undef_lockset_d      :std_ulogic;
signal ex2_undef_lockset_q      :std_ulogic;
signal ex3_undef_lockset_d      :std_ulogic;
signal ex3_undef_lockset_q      :std_ulogic;
signal ex3_cinh_lockset         :std_ulogic;
signal ex3_l1dcdis_lockset      :std_ulogic;
signal ex4_unable_2lock_d       :std_ulogic;
signal ex4_unable_2lock_q       :std_ulogic;
signal ex5_unable_2lock_d       :std_ulogic;
signal ex5_unable_2lock_q       :std_ulogic;
signal ex3_ldstq_instr_d        :std_ulogic;
signal ex3_ldstq_instr_q        :std_ulogic;
signal ex4_store_instr_d        :std_ulogic;
signal ex4_store_instr_q        :std_ulogic;
signal ex5_store_instr_d        :std_ulogic;
signal ex5_store_instr_q        :std_ulogic;
signal ex4_store_miss           :std_ulogic;
signal ex5_store_miss_d         :std_ulogic;
signal ex5_store_miss_q         :std_ulogic;
signal ex4_perf_dcbt_d          :std_ulogic;
signal ex4_perf_dcbt_q          :std_ulogic;
signal ex5_perf_dcbt_d          :std_ulogic;
signal ex5_perf_dcbt_q          :std_ulogic;
signal perf_com_stores          :std_ulogic;
signal perf_com_store_miss      :std_ulogic;
signal perf_com_stcx_exec       :std_ulogic;
signal perf_com_loadmiss        :std_ulogic;
signal perf_com_cinh_loads      :std_ulogic;
signal perf_com_loads           :std_ulogic;
signal perf_com_dcbt_sent       :std_ulogic;
signal perf_com_dcbt_hit        :std_ulogic;
signal perf_com_axu_load        :std_ulogic;
signal perf_com_axu_store       :std_ulogic;
signal perf_com_watch_clr       :std_ulogic;
signal perf_com_wclr_lfld       :std_ulogic;
signal perf_com_watch_set       :std_ulogic;
signal perf_lsu_events_d        :std_ulogic_vector(0 to 16);
signal perf_lsu_events_q        :std_ulogic_vector(0 to 16);
signal ex3_local_dcbf_d         :std_ulogic;
signal ex3_local_dcbf_q         :std_ulogic;
signal ex1_msgsnd_instr_d       :std_ulogic;
signal ex1_msgsnd_instr_q       :std_ulogic;
signal ex2_msgsnd_instr_d       :std_ulogic;
signal ex2_msgsnd_instr_q       :std_ulogic;
signal ex3_msgsnd_instr_d       :std_ulogic;
signal ex3_msgsnd_instr_q       :std_ulogic;
signal ex1_dci_instr_d          :std_ulogic;
signal ex1_dci_instr_q          :std_ulogic;
signal ex2_dci_instr_d          :std_ulogic;
signal ex2_dci_instr_q          :std_ulogic;
signal ex3_dci_instr_d          :std_ulogic;
signal ex3_dci_instr_q          :std_ulogic;
signal ex1_ici_instr_d          :std_ulogic;
signal ex1_ici_instr_q          :std_ulogic;
signal ex2_ici_instr_d          :std_ulogic;
signal ex2_ici_instr_q          :std_ulogic;
signal ex3_ici_instr_d          :std_ulogic;
signal ex3_ici_instr_q          :std_ulogic;
signal ex3_l2load_type_d        :std_ulogic;
signal ex3_l2load_type_q        :std_ulogic;
signal flh2l2_gate_d            :std_ulogic;
signal flh2l2_gate_q            :std_ulogic;
signal rel_upd_dcarr_d          :std_ulogic;
signal rel_upd_dcarr_q          :std_ulogic;
signal ex1_ldawx_instr_d        :std_ulogic;
signal ex1_ldawx_instr_q        :std_ulogic;
signal ex2_ldawx_instr_d        :std_ulogic;
signal ex2_ldawx_instr_q        :std_ulogic;
signal ex3_watch_en_d           :std_ulogic;
signal ex3_watch_en_q           :std_ulogic;
signal ex4_watch_en_d           :std_ulogic;
signal ex4_watch_en_q           :std_ulogic;
signal ex5_watch_en_d           :std_ulogic;
signal ex5_watch_en_q           :std_ulogic;
signal ex1_wclr_instr_d         :std_ulogic;
signal ex1_wclr_instr_q         :std_ulogic;
signal ex2_wclr_instr_d         :std_ulogic;
signal ex2_wclr_instr_q         :std_ulogic;
signal ex3_wclr_instr_d         :std_ulogic;
signal ex3_wclr_instr_q         :std_ulogic;
signal ex4_wclr_instr_d         :std_ulogic;
signal ex4_wclr_instr_q         :std_ulogic;
signal ex5_wclr_instr_d         :std_ulogic;
signal ex5_wclr_instr_q         :std_ulogic;
signal ex4_wclr_set_d           :std_ulogic;
signal ex4_wclr_set_q           :std_ulogic;
signal ex5_wclr_set_d           :std_ulogic;
signal ex5_wclr_set_q           :std_ulogic;
signal ex1_wchk_instr_d         :std_ulogic;
signal ex1_wchk_instr_q         :std_ulogic;
signal ex2_wchk_instr_d         :std_ulogic;
signal ex2_wchk_instr_q         :std_ulogic;
signal ex3_stq_full_flush       :std_ulogic;
signal ex3_lsq_ig_flush         :std_ulogic;
signal ex4_cacheable_linelock_d :std_ulogic;
signal ex4_cacheable_linelock_q :std_ulogic;
signal ex1_icswx_instr_d        :std_ulogic;
signal ex1_icswx_instr_q        :std_ulogic;
signal ex2_icswx_instr_d        :std_ulogic;
signal ex2_icswx_instr_q        :std_ulogic;
signal ex3_icswx_instr_d        :std_ulogic;
signal ex3_icswx_instr_q        :std_ulogic;
signal ex1_icswx_dot_instr_d    :std_ulogic;
signal ex1_icswx_dot_instr_q    :std_ulogic;
signal ex2_icswx_dot_instr_d    :std_ulogic;
signal ex2_icswx_dot_instr_q    :std_ulogic;
signal ex3_icswx_dot_instr_d    :std_ulogic;
signal ex3_icswx_dot_instr_q    :std_ulogic;
signal ex1_icswx_epid_d         :std_ulogic;
signal ex1_icswx_epid_q         :std_ulogic;
signal ex2_icswx_epid_d         :std_ulogic;
signal ex2_icswx_epid_q         :std_ulogic;
signal ex3_icswx_epid_d         :std_ulogic;
signal ex3_icswx_epid_q         :std_ulogic;
signal ex3_c_inh_drop_op_d      :std_ulogic;
signal ex3_c_inh_drop_op_q      :std_ulogic;
signal ex3_drop_ld_req_b        :std_ulogic;
signal ex3_drop_touch_int       :std_ulogic;
signal ex3_drop_ld              :std_ulogic;
signal ex3_drop_cacheable       :std_ulogic;
signal ex3_drop_cacheable_b     :std_ulogic;
signal ex3_cache_enabled        :std_ulogic;
signal ex3_cache_inhibited      :std_ulogic;
signal ex5_axu_rel_val_stg1_d   :std_ulogic;
signal ex5_axu_rel_val_stg1_q   :std_ulogic;
signal ex5_axu_rel_val_stg2_d   :std_ulogic;
signal ex5_axu_rel_val_stg2_q   :std_ulogic;
signal rel_axu_tid_d            :std_ulogic_vector(0 to 3);
signal rel_axu_tid_q            :std_ulogic_vector(0 to 3);
signal rel_axu_tid_stg1_d       :std_ulogic_vector(0 to 3);
signal rel_axu_tid_stg1_q       :std_ulogic_vector(0 to 3);
signal rel_axu_ta_gpr_d         :std_ulogic_vector(0 to 8);
signal rel_axu_ta_gpr_q         :std_ulogic_vector(0 to 8);
signal rel_axu_ta_gpr_stg1_d    :std_ulogic_vector(0 to 8);
signal rel_axu_ta_gpr_stg1_q    :std_ulogic_vector(0 to 8);
signal rf0_l2_inv_val_d         :std_ulogic;
signal rf0_l2_inv_val_q         :std_ulogic;
signal rf1_l2_inv_val_d         :std_ulogic;
signal rf1_l2_inv_val_q         :std_ulogic;
signal ex1_agen_binv_val_d      :std_ulogic;
signal ex1_agen_binv_val_q      :std_ulogic;
signal ex1_l2_inv_val_d         :std_ulogic;
signal ex1_l2_inv_val_q         :std_ulogic;
signal lsu_msr_gs_d             :std_ulogic_vector(0 to 3);
signal lsu_msr_gs_q             :std_ulogic_vector(0 to 3);
signal lsu_msr_pr_d             :std_ulogic_vector(0 to 3);
signal lsu_msr_pr_q             :std_ulogic_vector(0 to 3);
signal hypervisor_state         :std_ulogic_vector(0 to 3);
signal lsu_msr_cm_d             :std_ulogic_vector(0 to 3);
signal lsu_msr_cm_q             :std_ulogic_vector(0 to 3);
signal rf1_lsu_64bit_mode       :std_ulogic;
signal ex1_lsu_64bit_agen_d     :std_ulogic;
signal ex1_lsu_64bit_agen_q     :std_ulogic;
signal ex6_icbi_val_d           :std_ulogic_vector(0 to 3);
signal ex6_icbi_val_q           :std_ulogic_vector(0 to 3);
signal ex1_mtspr_trace_d        :std_ulogic;
signal ex1_mtspr_trace_q        :std_ulogic;
signal ex2_mtspr_trace_d        :std_ulogic;
signal ex2_mtspr_trace_q        :std_ulogic;
signal ex3_mtspr_trace_d        :std_ulogic;
signal ex3_mtspr_trace_q        :std_ulogic;
signal rf1_stg_act_d            :std_ulogic;
signal rf1_stg_act_q            :std_ulogic;
signal ex1_stg_act_d    	:std_ulogic;
signal ex1_stg_act_q     	:std_ulogic;
signal ex2_stg_act_d     	:std_ulogic;
signal ex2_stg_act_q     	:std_ulogic;
signal ex3_stg_act_d     	:std_ulogic;
signal ex3_stg_act_q     	:std_ulogic;
signal ex4_stg_act_d     	:std_ulogic;
signal ex4_stg_act_q     	:std_ulogic;
signal ex5_stg_act_d     	:std_ulogic;
signal ex5_stg_act_q     	:std_ulogic;
signal binv1_stg_act_d          :std_ulogic;
signal binv1_stg_act_q          :std_ulogic;
signal binv2_stg_act_d          :std_ulogic;
signal binv2_stg_act_q          :std_ulogic;
signal binv3_stg_act_d          :std_ulogic;
signal binv3_stg_act_q          :std_ulogic;
signal binv4_stg_act_d          :std_ulogic;
signal binv4_stg_act_q          :std_ulogic;
signal binv5_stg_act_d          :std_ulogic;
signal binv5_stg_act_q          :std_ulogic;
signal rel1_stg_act_d           :std_ulogic;
signal rel1_stg_act_q           :std_ulogic;
signal rel3_stg_act_d           :std_ulogic;
signal rel3_stg_act_q           :std_ulogic;
signal rel4_stg_act_d           :std_ulogic;
signal rel4_stg_act_q           :std_ulogic;
signal rel4_ex4_stg_act         :std_ulogic;
signal binv2_ex2_stg_act        :std_ulogic;
signal mtspr_trace_en_d         :std_ulogic_vector(0 to 3);
signal mtspr_trace_en_q         :std_ulogic_vector(0 to 3);
signal ex2_be10_en              :std_ulogic_vector(0 to 31);
signal ex2_beC840_en            :std_ulogic_vector(0 to 31);
signal ex2_be3210_en            :std_ulogic_vector(0 to 31);
signal ex2_byte_en              :std_ulogic_vector(0 to 31);
signal ex3_byte_en_d            :std_ulogic_vector(0 to 31);
signal ex3_byte_en_q            :std_ulogic_vector(0 to 31);
signal ex3_data_swap_val        :std_ulogic;
signal ex2_rot_sel_be           :std_ulogic_vector(0 to 5);
signal ex2_rot_sel_le           :std_ulogic_vector(0 to 5);
signal ex3_rot_sel_le_d         :std_ulogic_vector(1 to 5);
signal ex3_rot_sel_le_q         :std_ulogic_vector(1 to 5);
signal ex3_rot_sel_be_d         :std_ulogic_vector(1 to 5);
signal ex3_rot_sel_be_q         :std_ulogic_vector(1 to 5);
signal ex3_rot_sel              :std_ulogic_vector(0 to 4);
signal ex1_watch_clr_all        :std_ulogic;
signal ex2_watch_clr_entry      :std_ulogic;
signal dir_arr_rd_done          :std_ulogic;
signal dir_arr_rd_cntrl         :std_ulogic_vector(0 to 1);
signal dir_arr_rd_val_d         :std_ulogic;
signal dir_arr_rd_val_q         :std_ulogic;
signal dir_arr_rd_is0_val_d     :std_ulogic;
signal dir_arr_rd_is0_val_q     :std_ulogic;
signal dir_arr_rd_is1_val_d     :std_ulogic;
signal dir_arr_rd_is1_val_q     :std_ulogic;
signal dir_arr_rd_is2_val_d     :std_ulogic;
signal dir_arr_rd_is2_val_q     :std_ulogic;
signal dir_arr_rd_rf0_val_d     :std_ulogic;
signal dir_arr_rd_rf0_val_q     :std_ulogic;
signal dir_arr_rd_rf1_val_d     :std_ulogic;
signal dir_arr_rd_rf1_val_q     :std_ulogic;
signal dir_arr_rd_rf0_done_d    :std_ulogic;
signal dir_arr_rd_rf0_done_q    :std_ulogic;
signal dir_arr_rd_rf1_done_d    :std_ulogic;
signal dir_arr_rd_rf1_done_q    :std_ulogic;
signal dir_arr_rd_ex1_done_d    :std_ulogic;
signal dir_arr_rd_ex1_done_q    :std_ulogic;
signal dir_arr_rd_ex2_done_d    :std_ulogic;
signal dir_arr_rd_ex2_done_q    :std_ulogic;
signal dir_arr_rd_ex3_done_d    :std_ulogic;
signal dir_arr_rd_ex3_done_q    :std_ulogic;
signal dir_arr_rd_ex4_done_d    :std_ulogic;
signal dir_arr_rd_ex4_done_q    :std_ulogic;
signal dir_arr_rd_tag           :std_ulogic_vector(64-real_data_add to 63-(dc_size-3));
signal dir_arr_rd_directory     :std_ulogic_vector(0 to 5);
signal dir_arr_rd_parity        :std_ulogic_vector(0 to parBits-1);
signal dir_arr_rd_lru           :std_ulogic_vector(0 to 6);
signal ex2_flh2l2_load          :std_ulogic;
signal ex2_l2_lock_clr          :std_ulogic;
signal ex4_thrd_enc             :std_ulogic_vector(0 to 1);
signal my_spare0_lclk           :clk_logic;
signal my_spare0_d1clk          :std_ulogic;
signal my_spare0_d2clk          :std_ulogic;
signal my_spare0_latches_d      :std_ulogic_vector(0 to 2);
signal my_spare0_latches_q      :std_ulogic_vector(0 to 2);
signal my_spare1_lclk           :clk_logic;
signal my_spare1_d1clk          :std_ulogic;
signal my_spare1_d2clk          :std_ulogic;
signal my_spare1_latches_d      :std_ulogic_vector(0 to 19);
signal my_spare1_latches_q      :std_ulogic_vector(0 to 19);
signal ex4_c_inh_d              :std_ulogic;
signal ex4_c_inh_q              :std_ulogic;
signal ex4_opsize_d             :std_ulogic_vector(0 to 5);
signal ex4_opsize_q             :std_ulogic_vector(0 to 5);
signal ex4_rot_sel_d            :std_ulogic_vector(0 to 4);
signal ex4_rot_sel_q            :std_ulogic_vector(0 to 4);
signal ex4_data_swap_val_d      :std_ulogic;
signal ex4_data_swap_val_q      :std_ulogic;
signal ex4_algebraic_d          :std_ulogic;
signal ex4_algebraic_q          :std_ulogic;
signal ex4_lock_en_d            :std_ulogic;
signal ex4_lock_en_q            :std_ulogic;

signal tiup                     :std_ulogic;
signal siv                      :std_ulogic_vector(0 to scan_right);
signal sov                      :std_ulogic_vector(0 to scan_right);



begin

tiup <= '1';

-- XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
-- Act Signals going to all Latches
-- XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

rf1_stg_act_d <= xu_lsu_rf0_act or clkg_ctl_override_q;
ex1_stg_act_d <= xu_lsu_rf1_cmd_act or dir_arr_rd_rf1_val_q or clkg_ctl_override_q;
ex2_stg_act_d <= ex1_stg_act_q;
ex3_stg_act_d <= ex2_stg_act_q;
ex4_stg_act_d <= ex3_stg_act_q;
ex5_stg_act_d <= ex4_stg_act_q;

binv1_stg_act_d <= rf1_l2_inv_val_q or clkg_ctl_override_q;
binv2_stg_act_d <= binv1_stg_act_q;
binv3_stg_act_d <= binv2_stg_act_q;
binv4_stg_act_d <= binv3_stg_act_q;
binv5_stg_act_d <= binv4_stg_act_q;

rel1_stg_act_d   <= ldq_rel_data_val_early or clkg_ctl_override_q;
rel3_stg_act_d   <= ldq_rel_stg24_val or clkg_ctl_override_q;
rel4_stg_act_d   <= rel3_stg_act_q;

rel4_ex4_stg_act  <= ex4_stg_act_q or rel4_stg_act_q;
binv2_ex2_stg_act <= binv2_stg_act_q or ex2_stg_act_q;

-- XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
-- XU Config Bits
-- XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

flh2l2_gate_d <= an_ac_flh2l2_gate;

-- Clock Gating Override
clkg_ctl_override_d <= spr_xucr0_clkg_ctl_b1;

-- XUCR0[WLK]
-- 1 => Way Locking Enabled
-- 0 => Way Locking Disabled
spr_xucr0_wlck_d <= xu_lsu_spr_xucr0_wlk and not xu_lsu_spr_ccr2_dfrat;
spr_xucr0_wlck_cpy_d <= spr_xucr0_wlck_q;

-- XUCR0[FHL2L2]
-- 1 => Send Load L1hit to L2
-- 0 => Do not send Load L1hit to L2
spr_xucr0_flh2l2_d     <= xu_lsu_spr_xucr0_flh2l2 and flh2l2_gate_q;
ex2_spr_xucr0_flh2l2   <= spr_xucr0_flh2l2_q;
ex3_spr_xucr0_flh2l2_d <= ex2_spr_xucr0_flh2l2;

-- XUCR0[DC_DIS]
-- 1 => L1 Data Cache Disabled
-- 0 => L1 Data Cache Enabled
spr_xucr0_dcdis_d <= xu_lsu_spr_xucr0_dcdis;

-- XUCR0[CLS]
-- 1 => 128 Byte Cacheline
-- 0 => 64 Byte Cacheline
spr_xucr0_cls_d      <= xu_lsu_spr_xucr0_cls;
agen_xucr0_cls_dly_d <= spr_xucr0_cls_q;
agen_xucr0_cls_d     <= agen_xucr0_cls_dly_q;

-- MTSPR TRACE Enabled
mtspr_trace_en_d <= xu_lsu_mtspr_trace_en;

-- Determine threads in hypervisor state
lsu_msr_gs_d <= xu_lsu_msr_gs;
lsu_msr_pr_d <= xu_lsu_msr_pr;
hypervisor_state <= lsu_msr_gs_q nor lsu_msr_pr_q;

-- 64Bit mode Select
lsu_msr_cm_d         <= xu_lsu_spr_msr_cm;
rf1_lsu_64bit_mode   <= (xu_lsu_rf1_thrd_id(0) and lsu_msr_cm_q(0)) or (xu_lsu_rf1_thrd_id(1) and lsu_msr_cm_q(1)) or
                        (xu_lsu_rf1_thrd_id(2) and lsu_msr_cm_q(2)) or (xu_lsu_rf1_thrd_id(3) and lsu_msr_cm_q(3));
ex1_lsu_64bit_agen_d <= rf1_lsu_64bit_mode or rf1_l2_inv_val_q;

-- XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
-- Back-Invalidate Pipe
-- XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

-- Back-Invalidate Address comes from ALU
-- it is provided in IS2 and muxed into bypass in RF1
-- it is then added with 0 and bypasses the erat translation
rf0_l2_inv_val_d    <= is2_l2_inv_val;
rf1_l2_inv_val_d    <= rf0_l2_inv_val_q;
ex1_agen_binv_val_d <= rf1_l2_inv_val_q;
ex1_l2_inv_val_d    <= rf1_l2_inv_val_q;

-- XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
-- Execution Pipe Inputs
-- XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
ex1_optype1_d <= xu_lsu_rf1_optype1;
ex2_optype1_d <= ex1_optype1_q;

ex1_optype2_d <= xu_lsu_rf1_optype2;
ex2_optype2_d <= ex1_optype2_q;

ex1_optype4_d <= xu_lsu_rf1_optype4;
ex2_optype4_d <= ex1_optype4_q;

ex1_optype8_d <= xu_lsu_rf1_optype8;
ex2_optype8_d <= ex1_optype8_q;

ex1_optype16_d <= xu_lsu_rf1_optype16;
ex2_optype16_d <= ex1_optype16_q;

ex1_optype32_d <= xu_lsu_rf1_optype32;
ex2_optype32_d <= ex1_optype32_q;

ex3_p_addr_lwr_d <= ex2_p_addr_lwr;
ex4_p_addr_d     <= ex3_p_addr & ex3_p_addr_lwr_q(52 to 63);
ex5_p_addr_d     <= ex4_p_addr_q(64-real_data_add to 57);
ex6_p_addr_d     <= ex5_p_addr_q;

-- Directory Access is Valid indicator, used to reject reload write if accessing
-- same congruence class
ex1_dir_acc_val_d <= dir_arr_rd_rf1_done_q or (xu_lsu_rf1_cache_acc and not rf1_stg_flush);

cache_acc_ex1_d <= xu_lsu_rf1_cache_acc and not rf1_stg_flush;
cache_acc_ex2_d <= cache_acc_ex1_q and not (ex1_undef_touch or ex1_stg_flush);
cache_acc_ex3_d <= cache_acc_ex2_q and not ex2_stg_flush;
cache_acc_ex4_d <= cache_acc_ex3_q and not ex3_stg_flush;
cache_acc_ex5_d <= cache_acc_ex4_q and not ex4_stg_flush;
ex2_cacc_d      <= cache_acc_ex1_q;
ex3_cacc_d      <= ex2_cacc_q;

ex1_thrd_id_d <= xu_lsu_rf1_thrd_id;
ex2_thrd_id_d <= ex1_thrd_id_q;
ex3_thrd_id_d <= ex2_thrd_id_q;
ex4_thrd_id_d <= ex3_thrd_id_q;
ex5_thrd_id_d <= ex4_thrd_id_q;

with ex4_thrd_id_q select
    ex4_thrd_enc <= "01" when "0100",
                    "10" when "0010",
                    "11" when "0001",
                    "00" when others;

ex1_target_gpr_d <= xu_lsu_rf1_target_gpr;
ex2_target_gpr_d <= ex1_target_gpr_q;
ex3_target_gpr_d <= ex2_target_gpr_q;
ex4_target_gpr_d <= ex3_target_gpr_q;

ex1_dcbt_instr_d <= xu_lsu_rf1_dcbt_instr;
ex2_dcbt_instr_d <= ex1_dcbt_instr_q and (ex1_th_fld_c_q or ex1_th_fld_l2_q);
ex3_dcbt_instr_d <= ex2_dcbt_instr_q;

ex1_dcbtst_instr_d <= xu_lsu_rf1_dcbtst_instr;
ex2_dcbtst_instr_d <= ex1_dcbtst_instr_q and (ex1_th_fld_c_q or ex1_th_fld_l2_q);
ex3_dcbtst_instr_d <= ex2_dcbtst_instr_q;

ex4_perf_dcbt_d <= (ex3_th_fld_l2_q or ex3_th_fld_c_q) and (ex3_dcbtst_instr_q or ex3_dcbt_instr_q or ex3_dcbtstls_instr_q or ex3_dcbtls_instr_q) and not ex3_blk_touch;
ex5_perf_dcbt_d <= ex4_perf_dcbt_q;

rf1_th_b0      <= xu_lsu_rf1_th_fld(0) and (xu_lsu_rf1_dcbt_instr or xu_lsu_rf1_dcbtst_instr);
ex1_th_fld_c_d <= not rf1_th_b0 and (xu_lsu_rf1_th_fld(1 to 4) = "0000");
ex2_th_fld_c_d <= ex1_th_fld_c_q;
ex3_th_fld_c_d <= ex2_th_fld_c_q;

ex1_th_fld_l2_d <= not rf1_th_b0 and (xu_lsu_rf1_th_fld(1 to 4) = "0010");
ex2_th_fld_l2_d <= ex1_th_fld_l2_q;
ex3_th_fld_l2_d <= ex2_th_fld_l2_q;

-- Need to check the L1 and send to the L2      when th=00000
-- Need to not check the L1 and send to the L2  when th=00010
ex1_dcbtls_instr_d <= xu_lsu_rf1_dcbtls_instr;
ex2_dcbtls_instr_d <= ex1_dcbtls_instr_q and (ex1_th_fld_c_q or ex1_th_fld_l2_q);
ex3_dcbtls_instr_d <= ex2_dcbtls_instr_q;

-- Need to check the L1 and send to the L2      when th=00000
-- Need to not check the L1 and send to the L2  when th=00010
ex1_dcbtstls_instr_d <= xu_lsu_rf1_dcbtstls_instr;
ex2_dcbtstls_instr_d <= ex1_dcbtstls_instr_q and (ex1_th_fld_c_q or ex1_th_fld_l2_q);
ex3_dcbtstls_instr_d <= ex2_dcbtstls_instr_q;

-- Need to check the L1 and not send to the L2  when th=00000
-- Need to not check the L1 and send to the L2  when th=00010
ex1_dcblc_instr_d <= xu_lsu_rf1_dcblc_instr;
ex2_dcblc_instr_d <= ex1_dcblc_instr_q and (ex1_th_fld_c_q or ex1_th_fld_l2_q);
ex3_dcblc_instr_d <= ex2_dcblc_instr_q;

-- Need to not check the L1 and not send to the L2  when th=00000
-- Need to not check the L1 and send to the L2      when th=00010
ex1_icblc_l2_instr_d <= xu_lsu_rf1_icblc_instr;
ex2_icblc_l2_instr_d <= ex1_icblc_l2_instr_q and (ex1_th_fld_c_q or ex1_th_fld_l2_q);
ex3_icblc_l2_instr_d <= ex2_icblc_l2_instr_q;

-- Need to not check the L1 and send to the L2
ex1_icbt_l2_instr_d <= xu_lsu_rf1_icbt_instr;
ex2_icbt_l2_instr_d <= ex1_icbt_l2_instr_q and (ex1_th_fld_c_q or ex1_th_fld_l2_q);
ex3_icbt_l2_instr_d <= ex2_icbt_l2_instr_q;

-- Need to not check the L1 and send to the L2
ex1_icbtls_l2_instr_d <= xu_lsu_rf1_icbtls_instr;
ex2_icbtls_l2_instr_d <= ex1_icbtls_l2_instr_q and (ex1_th_fld_c_q or ex1_th_fld_l2_q);
ex3_icbtls_l2_instr_d <= ex2_icbtls_l2_instr_q;

ex1_tlbsync_instr_d <= xu_lsu_rf1_tlbsync_instr and not rf1_stg_flush;
ex2_tlbsync_instr_d <= ex1_tlbsync_instr_q and not ex1_stg_flush;
ex3_tlbsync_instr_d <= ex2_tlbsync_instr_q and not ex2_stg_flush;

-- Load Double and Set Watch Bit
ex1_ldawx_instr_d <= xu_lsu_rf1_ldawx_instr;
ex2_ldawx_instr_d <= ex1_ldawx_instr_q;
ex3_watch_en_d    <= ex2_ldawx_instr_q;
ex4_watch_en_d    <= ex3_watch_en_q;
ex5_watch_en_d    <= ex4_watch_en_q;

-- ICSWX Non-Record Form Instruction
ex1_icswx_instr_d <= xu_lsu_rf1_icswx_instr;
ex2_icswx_instr_d <= ex1_icswx_instr_q;
ex3_icswx_instr_d <= ex2_icswx_instr_q;

-- ICSWX Record Form Instruction
ex1_icswx_dot_instr_d <= xu_lsu_rf1_icswx_dot_instr;
ex2_icswx_dot_instr_d <= ex1_icswx_dot_instr_q;
ex3_icswx_dot_instr_d <= ex2_icswx_dot_instr_q;

-- ICSWX External PID Form Instruction
ex1_icswx_epid_d <= xu_lsu_rf1_icswx_epid;
ex2_icswx_epid_d <= ex1_icswx_epid_q;
ex3_icswx_epid_d <= ex2_icswx_epid_q;

-- Watch Clear
ex1_wclr_instr_d <= xu_lsu_rf1_wclr_instr;
ex2_wclr_instr_d <= ex1_wclr_instr_q;
ex3_wclr_instr_d <= ex2_wclr_instr_q;
ex4_wclr_instr_d <= ex3_wclr_instr_q;
ex5_wclr_instr_d <= ex4_wclr_instr_q;
ex4_wclr_set_d   <= ex3_l_fld_q = "01";
ex5_wclr_set_d   <= ex4_wclr_set_q;

ex1_watch_clr_all <= ex1_wclr_instr_q and not ex1_l_fld_q(0);

-- Watch Check
ex1_wchk_instr_d <= xu_lsu_rf1_wchk_instr and not rf1_stg_flush;
ex2_wchk_instr_d <= ex1_wchk_instr_q and not ex1_stg_flush;

ex1_dcbst_instr_d <= xu_lsu_rf1_dcbst_instr;
ex2_dcbst_instr_d <= ex1_dcbst_instr_q;
ex3_dcbst_instr_d <= ex2_dcbst_instr_q;

ex1_dcbf_instr_d <= xu_lsu_rf1_dcbf_instr;
ex2_dcbf_instr_d <= ex1_dcbf_instr_q;
ex2_l2_dcbf      <= ex2_dcbf_instr_q and not (ex2_l_fld_q = "11");
ex2_local_dcbf   <= ex2_dcbf_instr_q and (ex2_l_fld_q = "11");
ex3_dcbf_instr_d <= ex2_dcbf_instr_q;

ex1_mtspr_trace_d <= xu_lsu_rf1_mtspr_trace and not rf1_stg_flush;
ex2_mtspr_trace_d <= ex1_mtspr_trace_q and (or_reduce(mtspr_trace_en_q and ex1_thrd_id_q)) and not ex1_stg_flush;
ex3_mtspr_trace_d <= ex2_mtspr_trace_q and not ex2_stg_flush;

ex1_sync_instr_d <= xu_lsu_rf1_sync_instr and not rf1_stg_flush;
ex2_sync_instr_d <= ex1_sync_instr_q and not ex1_stg_flush;
ex3_sync_instr_d <= ex2_sync_instr_q and not ex2_stg_flush;

ex1_l_fld_d <= xu_lsu_rf1_l_fld;
ex2_l_fld_d <= ex1_l_fld_q;
ex3_l_fld_d <= ex2_l_fld_q;

ex1_dcbi_instr_d <= xu_lsu_rf1_dcbi_instr;
ex2_dcbi_instr_d <= ex1_dcbi_instr_q;
ex3_dcbi_instr_d <= ex2_dcbi_instr_q;

ex1_dcbz_instr_d <= xu_lsu_rf1_dcbz_instr;
ex2_dcbz_instr_d <= ex1_dcbz_instr_q;
ex3_dcbz_instr_d <= ex2_dcbz_instr_q;

ex1_icbi_instr_d <= xu_lsu_rf1_icbi_instr;
ex2_icbi_instr_d <= ex1_icbi_instr_q;
ex3_icbi_instr_d <= ex2_icbi_instr_q;
ex4_icbi_instr_d <= ex3_icbi_instr_q;
ex5_icbi_instr_d <= ex4_icbi_instr_q;
ex5_icbi_instr   <= ex5_icbi_instr_q and cache_acc_ex5_q and not ex5_stg_flush;
ex6_icbi_val_d   <= gate(ex5_thrd_id_q, ex5_icbi_instr);

ex1_mbar_instr_d <= xu_lsu_rf1_mbar_instr and not rf1_stg_flush;
ex2_mbar_instr_d <= ex1_mbar_instr_q and not ex1_stg_flush;
ex3_mbar_instr_d <= ex2_mbar_instr_q and not ex2_stg_flush;

ex1_msgsnd_instr_d <= xu_lsu_rf1_is_msgsnd and not rf1_stg_flush;
ex2_msgsnd_instr_d <= ex1_msgsnd_instr_q and not ex1_stg_flush;
ex3_msgsnd_instr_d <= ex2_msgsnd_instr_q and not ex2_stg_flush;

-- DCI with CT=0    -> invalidate L1 only
-- DCI with CT=2    -> invalidate L1 and send to L2
-- DCI with CT!=0,2 -> No-Op
ex1_dci_instr_d    <= xu_lsu_rf1_dci_instr and not rf1_stg_flush;
ex2_dci_instr_d    <= ex1_dci_instr_q and ex1_th_fld_l2_q and not ex1_stg_flush;
ex3_dci_instr_d    <= ex2_dci_instr_q and not ex2_stg_flush;

-- ICI with CT=0    -> invalidate L1 only
-- ICI with CT=2    -> invalidate L1 and send to L2
-- ICI with CT!=0,2 -> No-Op
ex1_ici_instr_d    <= xu_lsu_rf1_ici_instr and not rf1_stg_flush;
ex2_ici_instr_d    <= ex1_ici_instr_q and ex1_th_fld_l2_q and not ex1_stg_flush;
ex3_ici_instr_d    <= ex2_ici_instr_q and not ex2_stg_flush;

ex1_algebraic_d <= xu_lsu_rf1_algebraic;
ex2_algebraic_d <= ex1_algebraic_q;
ex3_algebraic_d <= ex2_algebraic_q;

ex1_byte_rev_d <= xu_lsu_rf1_byte_rev;
ex2_byte_rev_d <= ex1_byte_rev_q;
ex3_byte_rev_d <= ex2_byte_rev_q;

ex1_lock_instr_d <= xu_lsu_rf1_lock_instr;
ex2_lock_instr_d <= ex1_lock_instr_q;
ex3_lock_instr_d <= ex2_lock_instr_q;
ex4_lock_instr_d <= ex3_lock_instr_q;
ex5_lock_instr_d <= ex4_lock_instr_q;

ex1_mutex_hint_d <= xu_lsu_rf1_mutex_hint;
ex2_mutex_hint_d <= ex1_mutex_hint_q;
ex3_mutex_hint_d <= ex2_mutex_hint_q;

ex1_load_instr_d  <= xu_lsu_rf1_load_instr;
ex2_load_instr_d  <= ex1_load_instr_q;
ex3_load_instr_d  <= ex2_load_instr_q;
ex4_load_instr_d  <= ex3_load_instr_q;
ex5_load_instr_d  <= ex4_load_instr_q;
ex3_load_type_d   <= ex2_load_instr_q or ex2_dcbt_instr_q or ex2_dcbtst_instr_q or ex2_dcbtls_instr_q or ex2_dcbtstls_instr_q;
ex4_load_type_d   <= ex3_load_type_q;
ex3_l2load_type_d <= ex3_load_type_d or ex2_icbt_l2_instr_q or ex2_icbtls_l2_instr_q;

ex1_store_instr_d <= xu_lsu_rf1_store_instr;
ex2_store_instr_d <= ex1_store_instr_q;
ex3_store_instr_d <= ex2_store_instr_q;
ex4_store_instr_d <= ex3_store_instr_q;
ex5_store_instr_d <= ex4_store_instr_q;

ex1_axu_op_val_d <= xu_lsu_rf1_axu_op_val;
ex2_axu_op_val_d <= ex1_axu_op_val_q;
ex3_axu_op_val_d <= ex2_axu_op_val_q;
ex4_axu_op_val_d <= ex3_axu_op_val_q;
ex5_axu_op_val_d <= ex4_axu_op_val_q;

ex1_src0_vld_d <= xu_lsu_rf1_src0_vld and not rf1_stg_flush;
ex1_src0_reg_d <= xu_lsu_rf1_src0_reg;
ex1_src1_vld_d <= xu_lsu_rf1_src1_vld and not rf1_stg_flush;
ex1_src1_reg_d <= xu_lsu_rf1_src1_reg;
ex1_targ_vld_d <= xu_lsu_rf1_targ_vld and not rf1_stg_flush;
ex1_targ_reg_d <= xu_lsu_rf1_targ_reg;

ex1_sgpr_instr_d <= xu_lsu_rf1_src_gpr and not rf1_stg_flush;
ex1_saxu_instr_d <= xu_lsu_rf1_src_axu and not rf1_stg_flush;
ex1_sdp_instr_d  <= xu_lsu_rf1_src_dp and not rf1_stg_flush;
ex1_tgpr_instr_d <= xu_lsu_rf1_targ_gpr and not rf1_stg_flush;
ex1_taxu_instr_d <= xu_lsu_rf1_targ_axu and not rf1_stg_flush;
ex1_tdp_instr_d  <= xu_lsu_rf1_targ_dp and not rf1_stg_flush;

ex2_tgpr_instr_d <= ex1_tgpr_instr_q and not ex1_stg_flush;
ex2_taxu_instr_d <= ex1_taxu_instr_q and not ex1_stg_flush;
ex2_tdp_instr_d  <= ex1_tdp_instr_q and not ex1_stg_flush;

ex3_tgpr_instr_d <= ex2_tgpr_instr_q and not ex2_stg_flush;
ex3_taxu_instr_d <= ex2_taxu_instr_q and not ex2_stg_flush;

ex4_tgpr_instr_d <= ex3_tgpr_instr_q and not ex3_stg_flush;
ex4_taxu_instr_d <= ex3_taxu_instr_q and not ex3_stg_flush;
ex4_tgpr_instr   <= ex4_tgpr_instr_q and not ex4_stg_flush;
ex4_taxu_instr   <= ex4_taxu_instr_q and not ex4_stg_flush;

ex1_ldst_falign_d <= xu_lsu_rf1_axu_ldst_falign;
ex1_ldst_fexcpt_d <= xu_lsu_rf1_axu_ldst_fexcpt;
ex2_ldst_fexcpt_d <= ex1_ldst_fexcpt_q;

rel_upd_dcarr_d <= rel_dcarr_val_upd;

-- XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
-- Byte Enable Generation
-- XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

-- OpSize
ex2_opsize   <= ex2_optype32_q & ex2_optype16_q & ex2_optype8_q & ex2_optype4_q & ex2_optype2_q & ex2_optype1_q;
ex3_opsize_d <= ex2_opsize;

-- Need to generate byte enables for the type of operation
-- size1  => 0x8000
-- size2  => 0xC000
-- size4  => 0xF000
-- size8  => 0xFF00
-- size16 => 0xFFFF
ex2_op_sel(0) <= ex2_opsize(1) or ex2_opsize(2) or ex2_opsize(3) or ex2_opsize(4) or ex2_opsize(5);
ex2_op_sel(1) <= ex2_opsize(1) or ex2_opsize(2) or ex2_opsize(3) or ex2_opsize(4);
ex2_op_sel(2) <= ex2_opsize(1) or ex2_opsize(2) or ex2_opsize(3);
ex2_op_sel(3) <= ex2_opsize(1) or ex2_opsize(2) or ex2_opsize(3);
ex2_op_sel(4) <= ex2_opsize(1) or ex2_opsize(2);
ex2_op_sel(5) <= ex2_opsize(1) or ex2_opsize(2);
ex2_op_sel(6) <= ex2_opsize(1) or ex2_opsize(2);
ex2_op_sel(7) <= ex2_opsize(1) or ex2_opsize(2);
ex2_op_sel(8) <= ex2_opsize(1);
ex2_op_sel(9) <= ex2_opsize(1);
ex2_op_sel(10) <= ex2_opsize(1);
ex2_op_sel(11) <= ex2_opsize(1);
ex2_op_sel(12) <= ex2_opsize(1);
ex2_op_sel(13) <= ex2_opsize(1);
ex2_op_sel(14) <= ex2_opsize(1);
ex2_op_sel(15) <= ex2_opsize(1);

-- 32 Bit Rotator
-- Need to Rotate optype generated byte enables
with ex2_p_addr_lwr(59) select
    ex2_be10_en <= ex2_op_sel(0 to 15) & x"0000" when '0',
                   x"0000" & ex2_op_sel(0 to 15) when others;

-- Selects between Data rotated by 0, 4, 8, or 12 bits
with ex2_p_addr_lwr(60 to 61) select
    ex2_beC840_en <=          ex2_be10_en(0 to 31) when "00",
                     x"0"   & ex2_be10_en(0 to 27) when "01",
                     x"00"  & ex2_be10_en(0 to 23) when "10",
                     x"000" & ex2_be10_en(0 to 19) when others;

-- Selects between Data rotated by 0, 1, 2, or 3 bits
with ex2_p_addr_lwr(62 to 63) select
    ex2_be3210_en <=         ex2_beC840_en(0 to 31) when "00",
                     '0'   & ex2_beC840_en(0 to 30) when "01",
                     "00"  & ex2_beC840_en(0 to 29) when "10",
                     "000" & ex2_beC840_en(0 to 28) when others;

-- Byte Enables Generated using the opsize and physical_addr(60 to 63)
ben_gen : for t in 0 to 31 generate begin
      ex2_byte_en(t) <= ex2_opsize(0) or ex2_be3210_en(t);
end generate ben_gen;

ex3_byte_en_d <= ex2_byte_en;

-- XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
-- Reload Rotate Control Logic
-- XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

-- RELOAD PATH LITTLE ENDIAN ROTATOR SELECT CALCULATION
-- rel_rot_size = rot_addr + op_size
-- rel_rot_sel_le = (rot_max_size or le_op_size) - rel_rot_size
-- rel_rot_sel = rel_rot_sel_le  => le_mode = 1
--             = rel_rot_size    => le_mode = 0
ex2_rot_sel_be   <= std_ulogic_vector(unsigned(ex2_p_addr_lwr(58 to 63)) + unsigned(ex2_opsize));
ex2_rot_sel_le   <= std_ulogic_vector(unsigned(rot_max_size) - unsigned(ex2_p_addr_lwr(58 to 63)));
ex3_rot_sel_le_d <= ex2_rot_sel_le(1 to 5);
ex3_rot_sel_be_d <= ex2_rot_sel_be(1 to 5);

-- Rotate Control Select for Reloads
with ex3_data_swap_val select
    ex3_rot_sel <= ex3_rot_sel_le_q when '1',
                   ex3_rot_sel_be_q when others;

-- XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
-- L1 D-Cache Control Logic
-- XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

-- Touch Ops with unsupported TH fields are no-ops
ex1_undef_touch  <= (ex1_dcbt_instr_q    or ex1_dcblc_instr_q    or ex1_dcbtls_instr_q or ex1_dcbtstls_instr_q or ex1_dcbtst_instr_q or
                     ex1_icbt_l2_instr_q or ex1_icblc_l2_instr_q or ex1_icbtls_l2_instr_q) and not (ex1_th_fld_c_q or ex1_th_fld_l2_q);

-- Cache Unable to Lock Detection
ex1_lockset_instr    <= ex1_dcbtls_instr_q or ex1_dcbtstls_instr_q or ex1_dcblc_instr_q or ex1_icbtls_l2_instr_q or ex1_icblc_l2_instr_q;
ex2_undef_lockset_d  <= (ex1_lockset_instr and cache_acc_ex1_q and not (ex1_th_fld_c_q or ex1_th_fld_l2_q)) and not ex1_stg_flush;
ex3_undef_lockset_d  <= ex2_undef_lockset_q and not ex2_stg_flush;
ex3_cinh_lockset     <= (ex3_dcbtls_instr_q or ex3_dcbtstls_instr_q or ex3_dcblc_instr_q or ex3_icbtls_l2_instr_q or ex3_icblc_l2_instr_q) and ex3_cache_inhibited;
ex3_l1dcdis_lockset  <= (ex3_dcbtls_instr_q or ex3_dcbtstls_instr_q or ex3_dcblc_instr_q) and ex3_th_fld_c_q and spr_xucr0_dcdis_q and ex3_cache_enabled;
ex4_unable_2lock_d   <= (ex3_undef_lockset_q or ex3_cinh_lockset or ex3_l1dcdis_lockset) and not ex3_stg_flush;
ex5_unable_2lock_d   <= ex4_unable_2lock_q and not ex4_stg_flush;

-- Type of Hit
ex4_store_commit_d <= ex3_store_instr_q and ex3_cache_enabled and not (ex3_stg_flush or ex3_lock_instr_q or ex3_spr_xucr0_flh2l2_q or spr_xucr0_dcdis_q);
ex4_load_commit_d  <= ex3_load_type_q and ex3_cache_enabled and not (ex3_stg_flush or ex3_nogpr_upd or spr_xucr0_dcdis_q);
ex4_load_hit       <= ex4_load_commit_q and not ex4_miss and cache_acc_ex4_q and not ex4_stg_flush;
ex5_load_hit_d     <= ex4_load_type_q and not ex4_miss and cache_acc_ex4_q and not ex4_cache_inh_q and not ex4_stg_flush;

-- Type of Miss
ex4_store_miss   <= ex4_store_instr_q and ex4_miss and cache_acc_ex4_q and not ex4_cache_inh_q;
ex5_store_miss_d <= ex4_store_miss;
ex4_load_miss    <= ex4_load_type_q and ex4_miss and cache_acc_ex4_q and not ex4_cache_inh_q;
ex5_load_miss_d  <= ex4_load_miss;

-- Determine if Reload needs to be dropped
ex4_cacheable_linelock_d <= (ex3_dcbtls_instr_q or ex3_dcbtstls_instr_q) and ex3_cache_enabled;
ex4_cache_inh_d <= ex3_wimge_i_bit;
ex5_cache_inh_d <= ex4_cache_inh_q;

ex3_cache_enabled   <= cache_acc_ex3_q and not ex3_wimge_i_bit;
ex3_cache_inhibited <= cache_acc_ex3_q and ex3_wimge_i_bit;

-- Data Swap Valid
ex3_data_swap_val <= ex3_wimge_e_bit xor ex3_byte_rev_q;

-- Directory Access Instructions
ex2_dcblc_l1   <= ex2_dcblc_instr_q and ex2_th_fld_c_q;
ddir_acc_instr <= ex2_load_instr_q or ex2_store_instr_q or data_touch_op or ex2_dcblc_l1 or is_inval_op;

-- Check for load register target match and previous command target match
-- Need to flush if equal and loadmiss

ex2_targ_match_b1_d <= (ex2_target_gpr_q(1 to 8) = ex1_targ_reg_q) and ex1_targ_vld_q and cache_acc_ex2_q and ex2_load_instr_q and not (ex1_stg_flush or ex2_axu_op_val_q);
ex3_targ_match_b1_d <= ex2_targ_match_b1_q and not ex2_stg_flush;
ex2_targ_match_b2_d <= (ex3_target_gpr_q(1 to 8) = ex1_targ_reg_q) and ex1_targ_vld_q and cache_acc_ex3_q and ex3_load_instr_q and not (ex1_stg_flush or ex3_axu_op_val_q);

-- Piping down WAW compares for Data Cache Parity Error Recovery
ex5_instr_val_d     <= or_reduce(xu_lsu_ex4_val)               and not ex4_stg_flush;
ex4_targ_match_b1_d <= ex3_targ_match_b1_q                     and not ex3_stg_flush;
ex5_targ_match_b1_d <= ex4_targ_match_b1_q                     and not ex4_stg_flush;
ex6_targ_match_b1_d <= ex5_targ_match_b1_q and ex5_instr_val_q and not ex5_stg_flush;
ex3_targ_match_b2_d <= ex2_targ_match_b2_q                     and not ex2_stg_flush;
ex4_targ_match_b2_d <= ex3_targ_match_b2_q                     and not ex3_stg_flush;
ex5_targ_match_b2_d <= ex4_targ_match_b2_q                     and not ex4_stg_flush;

-- load_is_in_stage <= WAW_detected_instruction_in_stage
ex7_targ_match_d <= ex5_targ_match_b1_q and ex5_instr_val_q and not ex5_stg_flush;                              -- latched version  of (EX6vsEX5) WAW hazard
ex8_targ_match_d <= ex6_targ_match_b1_q or (ex5_targ_match_b2_q and ex5_instr_val_q and not ex5_stg_flush);     -- latched versions of (EX7vsEX6 and EX7vsEX5) WAW hazard

-- EX2 Data touch ops, DCBT/DCBTST/DCBTLS/DCBTSTLS
data_touch_op <= ex2_dcbt_instr_q or ex2_dcbtst_instr_q or ex2_dcbtls_instr_q or ex2_dcbtstls_instr_q;
-- EX2 Instruction touch ops, ICBT/ICBTLS
inst_touch_op <= ex2_icbt_l2_instr_q or ex2_icbtls_l2_instr_q;
-- Ops that should not update the LRU if a miss or hit
no_lru_upd <= all_touch_op or is_inval_op or ex2_icbi_instr_q or ex2_dcbst_instr_q or ex2_wclr_instr_q or ex2_icblc_l2_instr_q or ex2_dcblc_instr_q;

-- All requests that go to the L2 no matter if hit
ex3_l2_request_d <= ((ex2_dcbtls_instr_q or ex2_dcbtstls_instr_q) and ex2_th_fld_l2_q) or ex2_icbt_l2_instr_q or ex2_icbtls_l2_instr_q or ex2_lock_instr_q;
ex3_l2_request   <= ex3_l2_request_q or ex3_cache_inhibited;

-- Ops that should not execute if translated to cache-inh
all_touch_op    <= data_touch_op or inst_touch_op;
ex2_l2_lock_clr <= (ex2_icblc_l2_instr_q or ex2_dcblc_instr_q) and ex2_th_fld_l2_q;

-- EX2 HSYNC/LWSYNC/MBAR/TLBSYNC
is_mem_bar_op <= ex2_sync_instr_q or ex2_mbar_instr_q or ex2_tlbsync_instr_q;

-- EX2 DCBF/DCBI/LWARX/STWCX/DCBZ/FLH2L2_STORE instruction that should invalidate the L1 Directory if there is a Hit
is_inval_op <= ex2_dcbf_instr_q or ex2_dcbi_instr_q or ex2_lock_instr_q or ex2_dcbz_instr_q or (ex2_spr_xucr0_flh2l2 and ex2_store_instr_q) or ex2_icswx_dot_instr_q or ex2_icswx_instr_q or
               ex2_icswx_epid_q;

-- EX2 DCBTLS/DCBTSTLS instruction that should set the Lock bit for the cacheline
is_lock_set     <= (ex2_dcbtstls_instr_q or ex2_dcbtls_instr_q) and ex2_th_fld_c_q;
ex3_l2_lock_set <= (ex3_dcbtstls_instr_q or ex3_dcbtls_instr_q) and ex3_th_fld_l2_q;
ex3_c_dcbtls    <= ex3_dcbtls_instr_q    and ex3_th_fld_c_q;
ex3_c_dcbtstls  <= ex3_dcbtstls_instr_q  and ex3_th_fld_c_q;
ex3_c_icbtls    <= ex3_icbtls_l2_instr_q and ex3_th_fld_c_q;
ex3_l2_dcbtls   <= ex3_dcbtls_instr_q    and ex3_th_fld_l2_q;
ex3_l2_dcbtstls <= ex3_dcbtstls_instr_q  and ex3_th_fld_l2_q;
ex3_l2_icbtls   <= ex3_icbtls_l2_instr_q and ex3_th_fld_l2_q;

-- EX2 DCBLC/DCBF/DCBI/LWARX/STWCX/DCBZ instruction that should clear the Lock bit for the cacheline
is_lock_clr <= (ex2_dcblc_instr_q and ex2_th_fld_c_q) or is_inval_op;

l2_ctype <= (ex2_store_instr_q or ex2_l2_dcbf or ex2_dcbi_instr_q or ex2_dcbz_instr_q or ex2_dcbst_instr_q or ex2_icbi_instr_q or ex2_icswx_instr_q or
             ex2_icswx_dot_instr_q or ex2_icswx_epid_q or ex2_lock_instr_q or all_touch_op or ex2_l2_lock_clr or ex2_load_instr_q) and cache_acc_ex2_q;
ex3_c_inh_drop_op_d <= (all_touch_op or ex2_l2_lock_clr or ex2_local_dcbf) and cache_acc_ex2_q and not ex2_stg_flush;

ex3_l2_op_d <= (l2_ctype or is_mem_bar_op or ex2_msgsnd_instr_q or ex2_mtspr_trace_q or ex2_dci_instr_q or ex2_ici_instr_q) and not ex2_stg_flush;

-- Watch Clear if real address matches
ex2_watch_clr_entry <= ex2_wclr_instr_q and ex2_l_fld_q(0);

-- EX3 local dcbf is special, need to check against loadmiss queue,
-- but dont want to send request to the L2, since this signal does not set
-- ex3_l_s_q_val, need to do an OR statement for setbarr_tid and ex3_n_flush_req
-- in case it hits against the loadmiss queue
ex3_local_dcbf_d    <= (ex2_local_dcbf or ex2_watch_clr_entry) and cache_acc_ex2_q and not ex2_stg_flush;

-- Ops that flow down the Store Queue
-- Load is added since load hits go to the L2 if xucr0[FLH2L2] = 1
--ex3_stq_instr_d <= (((ex2_store_instr_q or ex2_l2_dcbf or ex2_dcbi_instr_q or ex2_dcbz_instr_q or ex2_dcbst_instr_q or ex2_icbi_instr_q or ex2_icswx_instr_q or ex2_icswx_dot_instr_q or
--                      ex2_icswx_epid_q or ex2_icblc_l2_instr_q or ex2_dcblc_instr_q) and cache_acc_ex2_q) or
--                    is_mem_bar_op or ex2_msgsnd_instr_q or ex2_mtspr_trace_q or ex2_dci_instr_q or ex2_ici_instr_q) and not ex2_stg_flush;

ex2_flh2l2_load   <= ex2_load_instr_q and ex2_spr_xucr0_flh2l2;

ex3_ldstq_instr_d <= (((ex2_store_instr_q or ex2_l2_dcbf or ex2_dcbi_instr_q or ex2_dcbz_instr_q or ex2_dcbst_instr_q or ex2_icbi_instr_q or ex2_icswx_instr_q or ex2_icswx_dot_instr_q or
                        ex2_icswx_epid_q or ex2_l2_lock_clr or ex2_flh2l2_load) and cache_acc_ex2_q) or
                      is_mem_bar_op or ex2_msgsnd_instr_q or ex2_mtspr_trace_q or ex2_dci_instr_q or ex2_ici_instr_q) and not ex2_stg_flush;

-- These instructions should not update the register file but are treated as loads
ex3_nogpr_upd <= ex3_dcbt_instr_q or ex3_dcbtst_instr_q or ex3_lock_instr_q or ex3_dcbtls_instr_q or ex3_dcbtstls_instr_q;

-- Blockable Touches
ex2_blkable_touch_d <= ex1_dcbt_instr_q or ex1_dcbtst_instr_q or ex1_icbt_l2_instr_q or ex1_undef_touch;
ex3_blkable_touch_d <= ex2_blkable_touch_q;
ex3_blk_touch       <= ex3_blkable_touch_q and ex3_excp_det;

-- Inputs to Load/Store Queue
l_s_q_val            <= ex3_l2_op_q;
stx_instr            <= ex3_store_instr_q and ex3_lock_instr_q;
larx_instr           <= ex3_load_instr_q and ex3_lock_instr_q;
ex3_drop_ld          <= ex3_load_type_q and not (ex3_l2_lock_set or ex3_lock_instr_q or spr_xucr0_dcdis_q);
ex3_drop_touch_int   <= ex3_l2_op_q and (ex3_blk_touch or (ex3_cache_inhibited and ex3_c_inh_drop_op_q));

ex3DropCacheB : ex3_drop_cacheable_b <= not (ex3_drop_ld and ex3_cache_enabled);
ex3DropCache  : ex3_drop_cacheable   <= not ex3_drop_cacheable_b;
ex3DropLd     : ex3_drop_ld_req_b    <= not ((ex3_hit and ex3_drop_cacheable) or ex3_drop_touch_int);

-- LoadMiss Store Queue Flushes
-- Removing blockable touch for timing, this should rarely happen,
-- Will be getting a flush if the load_queue_full and its a touch op
-- that will get dropped next time around
--ex3_ldq_potential_flush <= ex3_ld_queue_full and ex3_l2load_type_q and cache_acc_ex3_q and not ex3_blk_touch;
ex3_ldq_potential_flush <= ex3_ld_queue_full and ex3_l2load_type_q and cache_acc_ex3_q;
ex3_stq_full_flush      <= ex3_stq_flush and ex3_ldstq_instr_q;
ex3_lsq_ig_flush        <= ex3_ig_flush and cache_acc_ex3_q;
ex3_lsq_flush           <= ex3_stq_full_flush or ex3_lsq_ig_flush;

-- Way Locking
with spr_xucr0_wlck_q select
    way_lck_rmt <= x"FFFFFFFF" when '0',
                   xucr2_reg_q when others;

-- Parity Error Recovery
-- bit(0 )     = cache_inhibit
-- bit(1:6 )   = opsize(0 to 5 )
-- bit(7:11 )  = rot_sel(0 to 4 )
-- bit(12:20 ) = target_gpr(0 to 8 )
-- bit(21 )    = axu_op_val
-- bit(22 )    = little endian mode
-- bit(23 )    = algebraic op
-- bit(24 )    = way lock
-- bit(25 )    = watch enable
-- bit(26:67 ) = ex4_p_addr(22 to 63 )

ex4_c_inh_d         <= ex3_cache_inhibited;
ex4_opsize_d        <= ex3_opsize_q(0 to 5);
ex4_rot_sel_d       <= ex3_rot_sel(0 to 4);
ex4_data_swap_val_d <= ex3_data_swap_val;
ex4_algebraic_d     <= ex3_algebraic_q;
ex4_lock_en_d       <= ex3_dcbtls_instr_q or ex3_dcbtstls_instr_q;

ex4_ld_entry <= ex4_c_inh_q & ex4_opsize_q & ex4_rot_sel_q & ex4_target_gpr_q & ex4_axu_op_val_q & ex4_data_swap_val_q & ex4_algebraic_q & ex4_lock_en_q & ex4_watch_en_q & ex4_p_addr_q;

-- XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
-- Directory Read Control
-- XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

dir_arr_rd_cntrl <= xudbg0_wen & dir_arr_rd_done;

with dir_arr_rd_cntrl select
    dir_arr_rd_val_d <= lsu_slowspr_data_q(62) when "10",
                                           '0' when "01",
                              dir_arr_rd_val_q when others;

-- Piping Down Directory Read indicator to match up with need hole request
dir_arr_rd_is0_val_d <= dir_arr_rd_val_q;
dir_arr_rd_is1_val_d <= dir_arr_rd_is0_val_q;
dir_arr_rd_is2_val_d <= dir_arr_rd_is1_val_q;
dir_arr_rd_rf0_val_d <= dir_arr_rd_is2_val_q;
dir_arr_rd_rf1_val_d <= dir_arr_rd_rf0_val_q;

-- Directory Read is done when there isnt a back-invalidate in same stage
-- Creating a Pulse, dont want to set done indicator for multiple cycles
dir_arr_rd_done       <= dir_arr_rd_is2_val_q and not (is2_l2_inv_val        or dir_arr_rd_rf0_done_q or dir_arr_rd_rf1_done_q or
                                                       dir_arr_rd_ex1_done_q or dir_arr_rd_ex2_done_q);

-- Piping Down Done indicator to capture directory contents
dir_arr_rd_rf0_done_d <= dir_arr_rd_done;
dir_arr_rd_rf1_done_d <= dir_arr_rd_rf0_done_q;
dir_arr_rd_ex1_done_d <= dir_arr_rd_rf1_done_q;
dir_arr_rd_ex2_done_d <= dir_arr_rd_ex1_done_q;
dir_arr_rd_ex3_done_d <= dir_arr_rd_ex2_done_q;
dir_arr_rd_ex4_done_d <= dir_arr_rd_ex3_done_q;

-- Done Bit Control
with dir_arr_rd_cntrl select
    xudbg0_done_reg_d <= lsu_slowspr_data_q(63) when "10",
                                            '1' when "01",
                              xudbg0_done_reg_q when others;

-- Select Tag
with xudbg0_reg_q(0 to 2) select
    dir_arr_rd_tag <= ex3_wayA_tag when "000",
                      ex3_wayB_tag when "001",
                      ex3_wayC_tag when "010",
                      ex3_wayD_tag when "011",
                      ex3_wayE_tag when "100",
                      ex3_wayF_tag when "101",
                      ex3_wayG_tag when "110",
                      ex3_wayH_tag when others;

-- Select Directory Contents
 with xudbg0_reg_q(0 to 2) select
    dir_arr_rd_directory <= ex4_way_a_dir when "000",
                            ex4_way_b_dir when "001",
                            ex4_way_c_dir when "010",
                            ex4_way_d_dir when "011",
                            ex4_way_e_dir when "100",
                            ex4_way_f_dir when "101",
                            ex4_way_g_dir when "110",
                            ex4_way_h_dir when others;

-- Select Directory Tag Parity
 with xudbg0_reg_q(0 to 2) select
    dir_arr_rd_parity <= ex3_way_tag_par_a when "000",
                         ex3_way_tag_par_b when "001",
                         ex3_way_tag_par_c when "010",
                         ex3_way_tag_par_d when "011",
                         ex3_way_tag_par_e when "100",
                         ex3_way_tag_par_f when "101",
                         ex3_way_tag_par_g when "110",
                         ex3_way_tag_par_h when others;

dir_arr_rd_lru <= ex4_dir_lru;

-- XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
-- Slow SPR's
-- XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

lsu_slowspr_val_d  <= xu_lsu_slowspr_val;
lsu_slowspr_rw_d   <= xu_lsu_slowspr_rw;
lsu_slowspr_etid_d <= xu_lsu_slowspr_etid;
lsu_slowspr_addr_d <= xu_lsu_slowspr_addr;
lsu_slowspr_data_d <= xu_lsu_slowspr_data;
lsu_slowspr_done_d <= xu_lsu_slowspr_done;

mm_slowspr_val_d  <= lsu_slowspr_val_q;
mm_slowspr_rw_d   <= lsu_slowspr_rw_q;
mm_slowspr_etid_d <= lsu_slowspr_etid_q;
mm_slowspr_addr_d <= lsu_slowspr_addr_q;

xucr2_sel  <= (lsu_slowspr_addr_q = XUCR2_ADDR);
dvc1_sel   <= (lsu_slowspr_addr_q = DVC1_ADDR);
dvc2_sel   <= (lsu_slowspr_addr_q = DVC2_ADDR);
eplc_sel   <= (lsu_slowspr_addr_q = EPLC_ADDR);
epsc_sel   <= (lsu_slowspr_addr_q = EPSC_ADDR);
xudbg0_sel <= (lsu_slowspr_addr_q = XUDBG0_ADDR);
xudbg1_sel <= (lsu_slowspr_addr_q = XUDBG1_ADDR);
xudbg2_sel <= (lsu_slowspr_addr_q = XUDBG2_ADDR);

-- SLOWSPR Writes

-- XUCR2 Register
xucr2_wen   <= lsu_slowspr_val_q and xucr2_sel and not lsu_slowspr_rw_q;
xucr2_reg_d <= lsu_slowspr_data_q(32 to 63);

xucr2_reg(32 to 63) <= xucr2_reg_q;

-- DVC1 Register
dvc1_wen   <= lsu_slowspr_val_q and dvc1_sel and not lsu_slowspr_rw_q;
dvc1_act_d <= dvc1_wen;
dvc1_reg_d <= lsu_slowspr_data_q;

dvc1_reg  <= dvc1_reg_q;

-- DVC2 Register
dvc2_wen   <= lsu_slowspr_val_q and dvc2_sel and not lsu_slowspr_rw_q;
dvc2_act_d <= dvc2_wen;
dvc2_reg_d <= lsu_slowspr_data_q;

dvc2_reg  <= dvc2_reg_q;

-- XUDBG0 Register
xudbg0_wen        <= lsu_slowspr_val_q and xudbg0_sel and not (lsu_slowspr_rw_q or dir_arr_rd_val_q);
xudbg0_reg_d      <= lsu_slowspr_data_q(49 to 51) & lsu_slowspr_data_q(53 to 57);

xudbg0_reg(64-(2**regmode) to 48) <= (others=>'0');
xudbg0_reg(49 to 63)              <= xudbg0_reg_q(0 to 2) & '0' & xudbg0_reg_q(3 to 7) & "00000" & xudbg0_done_reg_q;

-- XUDBG1 Register
xudbg1_dir_reg_d    <= dir_arr_rd_directory & dir_arr_rd_lru;
xudbg1_parity_reg_d <= dir_arr_rd_parity;

xudbg1_reg(64-(2**regmode) to 44) <= (others=>'0');
xudbg1_reg(45 to 63)              <= xudbg1_dir_reg_q(2 to 12) & xudbg1_parity_reg_q & "00" & xudbg1_dir_reg_q(1) & xudbg1_dir_reg_q(0);

-- XUDBG2 Register
xudbg2_reg_d <= dir_arr_rd_tag;

xudbg2_reg(32 to 63) <= '0' & xudbg2_reg_q;

eplc_wrt_data <= lsu_slowspr_data_q(32 to 34) & lsu_slowspr_data_q(40 to 47) & lsu_slowspr_data_q(50 to 63);
epsc_wrt_data <= lsu_slowspr_data_q(32 to 34) & lsu_slowspr_data_q(40 to 47) & lsu_slowspr_data_q(50 to 63);
-- Thread 0 SlowSPR Registers
-- EPLC Register
eplc_t0_wen     <= lsu_slowspr_val_q and eplc_sel and not lsu_slowspr_rw_q and (lsu_slowspr_etid_q = "00");
eplc_t0_hyp_wen <= eplc_t0_wen and hypervisor_state(0);

eplc_t0_reg_d(0 to 1)   <= eplc_wrt_data(0 to 1);
eplc_t0_reg_d(2 to 10)  <= eplc_wrt_data(2 to 10);
eplc_t0_reg_d(11 to 24) <= eplc_wrt_data(11 to 24);

eplc_t0_reg  <= eplc_t0_reg_q;

-- EPSC Register
epsc_t0_wen     <= lsu_slowspr_val_q and epsc_sel and not lsu_slowspr_rw_q and (lsu_slowspr_etid_q = "00");
epsc_t0_hyp_wen <= epsc_t0_wen and hypervisor_state(0);

epsc_t0_reg_d(0 to 1)   <= epsc_wrt_data(0 to 1);
epsc_t0_reg_d(2 to 10)  <= epsc_wrt_data(2 to 10);
epsc_t0_reg_d(11 to 24) <= epsc_wrt_data(11 to 24);

epsc_t0_reg  <= epsc_t0_reg_q;

-- Thread 1 SlowSPR Registers
-- EPLC Register
eplc_t1_wen     <= lsu_slowspr_val_q and eplc_sel and not lsu_slowspr_rw_q and (lsu_slowspr_etid_q = "01");
eplc_t1_hyp_wen <= eplc_t1_wen and hypervisor_state(1);

eplc_t1_reg_d(0 to 1)   <= eplc_wrt_data(0 to 1);
eplc_t1_reg_d(2 to 10)  <= eplc_wrt_data(2 to 10);
eplc_t1_reg_d(11 to 24) <= eplc_wrt_data(11 to 24);

eplc_t1_reg  <= eplc_t1_reg_q;

-- EPSC Register
epsc_t1_wen     <= lsu_slowspr_val_q and epsc_sel and not lsu_slowspr_rw_q and (lsu_slowspr_etid_q = "01");
epsc_t1_hyp_wen <= epsc_t1_wen and hypervisor_state(1);

epsc_t1_reg_d(0 to 1)   <= epsc_wrt_data(0 to 1);
epsc_t1_reg_d(2 to 10)  <= epsc_wrt_data(2 to 10);
epsc_t1_reg_d(11 to 24) <= epsc_wrt_data(11 to 24);

epsc_t1_reg  <= epsc_t1_reg_q;

-- Thread 2 SlowSPR Registers
-- EPLC Register
eplc_t2_wen     <= lsu_slowspr_val_q and eplc_sel and not lsu_slowspr_rw_q and (lsu_slowspr_etid_q = "10");
eplc_t2_hyp_wen <= eplc_t2_wen and hypervisor_state(2);

eplc_t2_reg_d(0 to 1)   <= eplc_wrt_data(0 to 1);
eplc_t2_reg_d(2 to 10)  <= eplc_wrt_data(2 to 10);
eplc_t2_reg_d(11 to 24) <= eplc_wrt_data(11 to 24);

eplc_t2_reg  <= eplc_t2_reg_q;

-- EPSC Register
epsc_t2_wen     <= lsu_slowspr_val_q and epsc_sel and not lsu_slowspr_rw_q and (lsu_slowspr_etid_q = "10");
epsc_t2_hyp_wen <= epsc_t2_wen and hypervisor_state(2);

epsc_t2_reg_d(0 to 1)   <= epsc_wrt_data(0 to 1);
epsc_t2_reg_d(2 to 10)  <= epsc_wrt_data(2 to 10);
epsc_t2_reg_d(11 to 24) <= epsc_wrt_data(11 to 24);

epsc_t2_reg  <= epsc_t2_reg_q;

-- Thread 3 SlowSPR Registers
-- EPLC Register
eplc_t3_wen     <= lsu_slowspr_val_q and eplc_sel and not lsu_slowspr_rw_q and (lsu_slowspr_etid_q = "11");
eplc_t3_hyp_wen <= eplc_t3_wen and hypervisor_state(3);

eplc_t3_reg_d(0 to 1)   <= eplc_wrt_data(0 to 1);
eplc_t3_reg_d(2 to 10)  <= eplc_wrt_data(2 to 10);
eplc_t3_reg_d(11 to 24) <= eplc_wrt_data(11 to 24);

eplc_t3_reg  <= eplc_t3_reg_q;

-- EPSC Register
epsc_t3_wen     <= lsu_slowspr_val_q and epsc_sel and not lsu_slowspr_rw_q and (lsu_slowspr_etid_q = "11");
epsc_t3_hyp_wen <= epsc_t3_wen and hypervisor_state(3);

epsc_t3_reg_d(0 to 1)   <= epsc_wrt_data(0 to 1);
epsc_t3_reg_d(2 to 10)  <= epsc_wrt_data(2 to 10);
epsc_t3_reg_d(11 to 24) <= epsc_wrt_data(11 to 24);

epsc_t3_reg  <= epsc_t3_reg_q;

eplc_wr_d(0 to 3) <= eplc_t0_wen & eplc_t1_wen & eplc_t2_wen & eplc_t3_wen;
epsc_wr_d(0 to 3) <= epsc_t0_wen & epsc_t1_wen & epsc_t2_wen & epsc_t3_wen;

-- SLOWSPR Read
-- Thread Register Selection
with lsu_slowspr_etid_q select
    eplc_thrd_reg <= eplc_t0_reg when "00",
                     eplc_t1_reg when "01",
                     eplc_t2_reg when "10",
                     eplc_t3_reg when others;

eplc_reg(32 to 63) <= eplc_thrd_reg(0 to 2) & "00000" & eplc_thrd_reg(3 to 10) & "00" & eplc_thrd_reg(11 to 24);

with lsu_slowspr_etid_q select
    epsc_thrd_reg <= epsc_t0_reg when "00",
                     epsc_t1_reg when "01",
                     epsc_t2_reg when "10",
                     epsc_t3_reg when others;

epsc_reg(32 to 63) <= epsc_thrd_reg(0 to 2) & "00000" & epsc_thrd_reg(3 to 10) & "00" & epsc_thrd_reg(11 to 24);

gen64mode : if (2**regmode = 64) generate begin
      xudbg2_reg(64-(2**REGMODE)  to 31) <= (others=>'0');
      eplc_reg(64-(2**REGMODE)  to 31)   <= (others=>'0');
      epsc_reg(64-(2**REGMODE)  to 31)   <= (others=>'0');
      xucr2_reg(64-(2**REGMODE) to 31)   <= (others=>'0');
end generate gen64mode;

-- SlowSPR Selection
spr_l1dc_rd_val <= (xucr2_sel or dvc1_sel or dvc2_sel or eplc_sel or epsc_sel or xudbg0_sel or xudbg1_sel or xudbg2_sel) and lsu_slowspr_val_q and lsu_slowspr_rw_q;
spr_l1dc_reg    <= gate(xucr2_reg, xucr2_sel)   or gate(dvc1_reg, dvc1_sel)     or gate(dvc2_reg, dvc2_sel)     or
                   gate(eplc_reg, eplc_sel)     or gate(epsc_reg, epsc_sel)     or gate(xudbg0_reg, xudbg0_sel) or
                   gate(xudbg1_reg, xudbg1_sel) or gate(xudbg2_reg, xudbg2_sel);

with spr_l1dc_rd_val select
    mm_slowspr_data_d <=        spr_l1dc_reg when '1',
                          lsu_slowspr_data_q when others;

-- Operation Complete
mm_slowspr_done_d <= xucr2_wen or dvc1_wen or dvc2_wen or xudbg0_wen or spr_l1dc_rd_val or lsu_slowspr_done_q;

-- XXXXXXXXXXXXXXXXXX
-- Register File updates
-- XXXXXXXXXXXXXXXXXX

rel_upd_gpr_d    <= ldq_rel_upd_gpr;
rel_axu_op_val_d <= ldq_rel_axu_val;
rel_thrd_id_d    <= ldq_rel_thrd_id;
rel_ta_gpr_d     <= ldq_rel_ta_gpr;

axu_rel_wren_d        <= rel_axu_op_val_q;
axu_rel_wren_stg1_d   <= axu_rel_wren_q and rel_upd_gpr_q;
rel_axu_tid_d         <= rel_thrd_id_q;
rel_axu_tid_stg1_d    <= rel_axu_tid_q;
rel_axu_ta_gpr_d      <= rel_ta_gpr_q;
rel_axu_ta_gpr_stg1_d <= rel_axu_ta_gpr_q;

with axu_rel_wren_stg1_q select
    reg_upd_thrd_id <= rel_axu_tid_stg1_q when '1',
                            ex4_thrd_id_q when others;

with axu_rel_wren_stg1_q select
    reg_upd_ta_gpr <= rel_axu_ta_gpr_stg1_q when '1',
                           ex4_target_gpr_q when others;

xu_wren  <= (ex4_load_hit and not ex4_axu_op_val_q) or ex4_tgpr_instr;
axu_wren <= axu_rel_wren_stg1_q or (ex4_load_hit and ex4_axu_op_val_q) or ex4_taxu_instr;

ex5_xu_wren_d   <= xu_wren;
rel_xu_ta_gpr_d <= rel_ta_gpr_q(1 to 8);

ex5_axu_rel_val_stg1_d <= axu_rel_wren_q and rel_upd_gpr_q;
ex5_axu_rel_val_stg2_d <= ex5_axu_rel_val_stg1_q;
ex5_axu_wren_d         <= gate(reg_upd_thrd_id,axu_wren);
ex5_axu_wren_val       <= or_reduce(ex5_axu_wren_q);
ex5_axu_ta_gpr_d       <= reg_upd_ta_gpr;

-- XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
-- Performance Events
-- XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

perf_com_loadmiss   <= cache_acc_ex5_q and ex5_load_instr_q  and      ex5_load_miss_q  and not ex5_stg_flush;
perf_com_loads      <= cache_acc_ex5_q and ex5_load_instr_q  and not  ex5_cache_inh_q  and not ex5_stg_flush;
perf_com_cinh_loads <= cache_acc_ex5_q and ex5_load_instr_q  and      ex5_cache_inh_q  and not ex5_stg_flush;
perf_com_dcbt_hit   <= cache_acc_ex5_q and ex5_perf_dcbt_q   and       ex5_load_hit_q  and not ex5_stg_flush;
perf_com_dcbt_sent  <= cache_acc_ex5_q and ex5_perf_dcbt_q   and      ex5_load_miss_q  and not ex5_stg_flush;
perf_com_axu_load   <= cache_acc_ex5_q and ex5_axu_op_val_q  and      ex5_load_instr_q and not ex5_stg_flush;
perf_com_stores     <= cache_acc_ex5_q and ex5_store_instr_q                           and not ex5_stg_flush;
perf_com_store_miss <= cache_acc_ex5_q and ex5_store_miss_q                            and not ex5_stg_flush;
perf_com_stcx_exec  <= cache_acc_ex5_q and ex5_store_instr_q and      ex5_lock_instr_q and not ex5_stg_flush;
perf_com_axu_store  <= cache_acc_ex5_q and ex5_axu_op_val_q  and     ex5_store_instr_q and not ex5_stg_flush;
perf_com_watch_clr  <= cache_acc_ex5_q and ex5_wclr_instr_q                            and not ex5_stg_flush;
perf_com_wclr_lfld  <= cache_acc_ex5_q and ex5_wclr_instr_q  and        ex5_wclr_set_q and not ex5_stg_flush;
perf_com_watch_set  <= cache_acc_ex5_q and ex5_watch_en_q                              and not ex5_stg_flush;

perf_lsu_events_d   <= ex5_thrd_id_q & perf_com_stores     & perf_com_store_miss & perf_com_loadmiss  & perf_com_cinh_loads &
                                       perf_com_loads      & perf_com_dcbt_sent  & perf_com_dcbt_hit  & perf_com_axu_load   &
                                       perf_com_axu_store  & perf_com_stcx_exec  & perf_com_watch_clr & perf_com_wclr_lfld  &
                                       perf_com_watch_set;

-- XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
-- Spare Latches
-- XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
my_spare0_latches_d <= not my_spare0_latches_q;
my_spare1_latches_d <= not my_spare1_latches_q;

-- XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
-- Execution Pipe Outputs
-- XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

-- Dependency Loadmiss Checking
ex1_src0_vld       <= ex1_src0_vld_q and not ex1_stg_flush;
ex1_src0_reg       <= ex1_src0_reg_q;
ex1_src1_vld       <= ex1_src1_vld_q and not ex1_stg_flush;
ex1_src1_reg       <= ex1_src1_reg_q;
ex1_targ_vld       <= ex1_targ_vld_q and not ex1_stg_flush;
ex1_targ_reg       <= ex1_targ_reg_q;
ex1_check_watch    <= gate((ex1_thrd_id_q), (ex1_watch_clr_all or ex1_wchk_instr_q));

ex1_lsu_64bit_agen <= ex1_lsu_64bit_agen_q;
ex1_frc_align32    <= ex1_ldst_falign_q and ex1_optype32_q;
ex1_frc_align16    <= ex1_ldst_falign_q and ex1_optype16_q;
ex1_frc_align8     <= ex1_ldst_falign_q and ex1_optype8_q;
ex1_frc_align4     <= ex1_ldst_falign_q and ex1_optype4_q;
ex1_frc_align2     <= ex1_ldst_falign_q and ex1_optype2_q;
ex1_optype1        <= ex1_optype1_q;
ex1_optype2        <= ex1_optype2_q;
ex1_optype4        <= ex1_optype4_q;
ex1_optype8        <= ex1_optype8_q;
ex1_optype16       <= ex1_optype16_q;
ex1_optype32       <= ex1_optype32_q;
ex1_saxu_instr     <= ex1_saxu_instr_q;
ex1_sdp_instr      <= ex1_sdp_instr_q;
ex1_stgpr_instr    <= ex1_sgpr_instr_q or ex1_tgpr_instr_q;
ex1_store_instr    <= ex1_store_instr_q;
ex1_axu_op_val     <= ex1_axu_op_val_q;
ex2_optype2        <= ex2_optype2_q;
ex2_optype4        <= ex2_optype4_q;
ex2_optype8        <= ex2_optype8_q;
ex2_optype16       <= ex2_optype16_q;
ex2_optype32       <= ex2_optype32_q;
ex2_icswx_type     <= ex2_icswx_instr_q or ex2_icswx_dot_instr_q or ex2_icswx_epid_q;
ex2_store_instr    <= ex2_store_instr_q and cache_acc_ex2_q;
ex1_dir_acc_val    <= ex1_dir_acc_val_q;
ex2_cache_acc      <= cache_acc_ex2_q;
ex3_cache_acc      <= cache_acc_ex3_q;
ex2_ldst_fexcpt    <= ex2_ldst_fexcpt_q;
ex2_axu_op         <= ex2_axu_op_val_q;
ex2_mv_reg_op      <= ex2_tgpr_instr_q or ex2_taxu_instr_q or ex2_tdp_instr_q;
ex1_thrd_id        <= ex1_thrd_id_q;
ex2_thrd_id        <= ex2_thrd_id_q;
ex3_thrd_id        <= ex3_thrd_id_q;
ex4_thrd_id        <= ex4_thrd_id_q;
ex5_thrd_id        <= ex5_thrd_id_q;
ex3_targ_match_b1  <= (ex3_targ_match_b1_q and ex4_snd_ld_l2);
ex2_targ_match_b2  <= (ex2_targ_match_b2_q and ex4_snd_ld_l2);
ex2_load_instr     <= ex2_load_instr_q;
ex3_dcbt_instr     <= ex3_dcbt_instr_q or ex3_c_dcbtls;
ex3_dcbtst_instr   <= ex3_dcbtst_instr_q or ex3_c_dcbtstls;
ex3_th_fld_l2      <= ex3_th_fld_l2_q;
ex3_dcbst_instr    <= ex3_dcbst_instr_q;
ex3_dcbf_instr     <= ex3_dcbf_instr_q;
ex3_sync_instr     <= ex3_sync_instr_q;
ex3_mtspr_trace    <= ex3_mtspr_trace_q;
ex3_byte_en        <= ex3_byte_en_q;
ex2_l_fld          <= ex2_l_fld_q;
ex3_l_fld          <= ex3_l_fld_q;
ex3_dcbi_instr     <= ex3_dcbi_instr_q;
ex2_dcbz_instr     <= ex2_dcbz_instr_q;
ex3_dcbz_instr     <= ex3_dcbz_instr_q;
ex3_icbi_instr     <= ex3_icbi_instr_q;
ex3_icswx_instr    <= ex3_icswx_instr_q;
ex3_icswx_dot      <= ex3_icswx_dot_instr_q;
ex3_icswx_epid     <= ex3_icswx_epid_q;
ex3_mbar_instr     <= ex3_mbar_instr_q;
ex3_msgsnd_instr   <= ex3_msgsnd_instr_q;
ex3_dci_instr      <= ex3_dci_instr_q;
ex3_ici_instr      <= ex3_ici_instr_q;
ex2_lock_instr     <= ex2_lock_instr_q and cache_acc_ex2_q;
ex3_load_instr     <= ex3_l2load_type_q;
ex3_store_instr    <= ex3_store_instr_q;
ex3_dcbtls_instr   <= ex3_l2_dcbtls;
ex3_dcbtstls_instr <= ex3_l2_dcbtstls;
ex3_dcblc_instr    <= ex3_dcblc_instr_q;
ex3_icblc_instr    <= ex3_icblc_l2_instr_q;
ex3_icbt_instr     <= ex3_icbt_l2_instr_q or ex3_c_icbtls;
ex3_icbtls_instr   <= ex3_l2_icbtls;
ex3_tlbsync_instr  <= ex3_tlbsync_instr_q;
ex3_local_dcbf     <= ex3_local_dcbf_q;
ex2_no_lru_upd     <= no_lru_upd;
ex2_is_inval_op    <= is_inval_op and cache_acc_ex2_q;
ex2_lock_set       <= is_lock_set and cache_acc_ex2_q;
ex2_lock_clr       <= is_lock_clr and cache_acc_ex2_q;
ex2_ddir_acc_instr <= ddir_acc_instr and cache_acc_ex2_q and not ex2_stg_flush;
ex3_cache_inh      <= ex3_cache_inhibited;
ex3_cache_en       <= ex3_cache_enabled;
ex4_store_hit      <= ex4_store_commit_q and not ex4_miss;
ex4_load_op_hit    <= ex4_load_commit_q and not ex4_miss;
ex5_load_op_hit    <= ex5_load_hit_q;
ex4_axu_op_val     <= ex4_axu_op_val_q;
ex4_drop_rel       <= ex4_cacheable_linelock_q and not ex4_miss;
ex3_load_l1hit     <= ex3_load_instr_q and ex3_spr_xucr0_flh2l2_q and ex3_cache_enabled;
ex3_lock_en        <= ex3_dcbtls_instr_q or ex3_dcbtstls_instr_q;
ex3_req_thrd_id    <= ex3_thrd_id_q;
ex3_target_gpr     <= ex3_target_gpr_q;
ex3_axu_op_val     <= ex3_axu_op_val_q;
ex3_algebraic      <= ex3_algebraic_q;
ex3_p_addr_lwr     <= ex3_p_addr_lwr_q(58 to 63);
ex3_opsize         <= ex3_opsize_q;
ex3_rotate_sel     <= ex3_rot_sel;
ex2_ldawx_instr    <= ex2_ldawx_instr_q and cache_acc_ex2_q;
ex2_wclr_instr     <= ex2_wclr_instr_q and cache_acc_ex2_q;
ex2_wchk_val       <= ex2_wchk_instr_q;
ex3_watch_en       <= ex3_watch_en_q;
ex3_data_swap      <= ex3_data_swap_val;
ex3_load_val       <= ex3_load_instr_q and cache_acc_ex3_q;
ex3_blkable_touch  <= ex3_blkable_touch_q and ex3_cacc_q;
ex7_targ_match     <= ex7_targ_match_q;
ex8_targ_match     <= ex8_targ_match_q;

rel_upd_dcarr_val  <= rel_upd_dcarr_q;

lsu_xu_need_hole   <= dir_arr_rd_val_q;

spr_dvc1_act       <= dvc1_act_q;
spr_dvc2_act       <= dvc2_act_q;
spr_dvc1_dbg       <= dvc1_reg_q;
spr_dvc2_dbg       <= dvc2_reg_q;
spr_xucr2_rmt      <= way_lck_rmt;
spr_xucr0_wlck     <= spr_xucr0_wlck_cpy_q;

ex3_l_s_q_val      <= l_s_q_val;
ex3_drop_ld_req    <= not ex3_drop_ld_req_b;
ex3_drop_touch     <= ex3_drop_touch_int;
ex3_stx_instr      <= stx_instr;
ex3_larx_instr     <= larx_instr;
ex3_mutex_hint     <= ex3_mutex_hint_q;

lsu_xu_ex4_cr_upd  <= cache_acc_ex4_q and ex4_watch_en_q;
lsu_xu_ex5_wren    <= ex5_xu_wren_q;
lsu_xu_rel_wren    <= rel_upd_gpr_q and not axu_rel_wren_q;
lsu_xu_rel_ta_gpr  <= rel_xu_ta_gpr_q;
lsu_xu_perf_events <= perf_lsu_events_q;

slowspr_val_out   <= mm_slowspr_val_q;
slowspr_rw_out    <= mm_slowspr_rw_q;
slowspr_etid_out  <= mm_slowspr_etid_q;
slowspr_addr_out  <= mm_slowspr_addr_q;
slowspr_data_out  <= mm_slowspr_data_q;
slowspr_done_out  <= mm_slowspr_done_q;

-- Back-Invalidate
rf1_l2_inv_val       <= rf1_l2_inv_val_q or dir_arr_rd_rf1_val_q;
ex1_agen_binv_val    <= ex1_agen_binv_val_q;
ex1_l2_inv_val       <= ex1_l2_inv_val_q;

xu_derat_epsc_wr     <= epsc_wr_q;
xu_derat_eplc_wr     <= eplc_wr_q;
xu_derat_eplc0_epr   <= eplc_t0_reg_q(0);
xu_derat_eplc0_eas   <= eplc_t0_reg_q(1);
xu_derat_eplc0_egs   <= eplc_t0_reg_q(2);
xu_derat_eplc0_elpid <= eplc_t0_reg_q(3 to 10);
xu_derat_eplc0_epid  <= eplc_t0_reg_q(11 to 24);
xu_derat_eplc1_epr   <= eplc_t1_reg_q(0);
xu_derat_eplc1_eas   <= eplc_t1_reg_q(1);
xu_derat_eplc1_egs   <= eplc_t1_reg_q(2);
xu_derat_eplc1_elpid <= eplc_t1_reg_q(3 to 10);
xu_derat_eplc1_epid  <= eplc_t1_reg_q(11 to 24);
xu_derat_eplc2_epr   <= eplc_t2_reg_q(0);
xu_derat_eplc2_eas   <= eplc_t2_reg_q(1);
xu_derat_eplc2_egs   <= eplc_t2_reg_q(2);
xu_derat_eplc2_elpid <= eplc_t2_reg_q(3 to 10);
xu_derat_eplc2_epid  <= eplc_t2_reg_q(11 to 24);
xu_derat_eplc3_epr   <= eplc_t3_reg_q(0);
xu_derat_eplc3_eas   <= eplc_t3_reg_q(1);
xu_derat_eplc3_egs   <= eplc_t3_reg_q(2);
xu_derat_eplc3_elpid <= eplc_t3_reg_q(3 to 10);
xu_derat_eplc3_epid  <= eplc_t3_reg_q(11 to 24);
xu_derat_epsc0_epr   <= epsc_t0_reg_q(0);
xu_derat_epsc0_eas   <= epsc_t0_reg_q(1);
xu_derat_epsc0_egs   <= epsc_t0_reg_q(2);
xu_derat_epsc0_elpid <= epsc_t0_reg_q(3 to 10);
xu_derat_epsc0_epid  <= epsc_t0_reg_q(11 to 24);
xu_derat_epsc1_epr   <= epsc_t1_reg_q(0);
xu_derat_epsc1_eas   <= epsc_t1_reg_q(1);
xu_derat_epsc1_egs   <= epsc_t1_reg_q(2);
xu_derat_epsc1_elpid <= epsc_t1_reg_q(3 to 10);
xu_derat_epsc1_epid  <= epsc_t1_reg_q(11 to 24);
xu_derat_epsc2_epr   <= epsc_t2_reg_q(0);
xu_derat_epsc2_eas   <= epsc_t2_reg_q(1);
xu_derat_epsc2_egs   <= epsc_t2_reg_q(2);
xu_derat_epsc2_elpid <= epsc_t2_reg_q(3 to 10);
xu_derat_epsc2_epid  <= epsc_t2_reg_q(11 to 24);
xu_derat_epsc3_epr   <= epsc_t3_reg_q(0);
xu_derat_epsc3_eas   <= epsc_t3_reg_q(1);
xu_derat_epsc3_egs   <= epsc_t3_reg_q(2);
xu_derat_epsc3_elpid <= epsc_t3_reg_q(3 to 10);
xu_derat_epsc3_epid  <= epsc_t3_reg_q(11 to 24);

-- Debug Data
dc_cntrl_dbg_data    <= rel_upd_gpr_q     & rel_ta_gpr_q      & rel_axu_op_val_q & spr_xucr0_dcdis_q &  --(0:11)
                        ex4_miss          & ex5_axu_ta_gpr_q  & is_mem_bar_op    & ex3_l2_op_q       &  --(12:23)
                        ex1_ldst_falign_q & ex1_ldst_fexcpt_q & ex5_cache_inh_q  & ex3_data_swap_val &  --(24:27)
                        ex5_xu_wren_q     & ex5_axu_wren_val  & ex4_p_addr_q(64-real_data_add to 52) &  --(28:60)
                        ex4_p_addr_q(58 to 61) & ex4_thrd_enc;                                          --(61:66)

ex1_stg_act   <= ex1_stg_act_q;
ex2_stg_act   <= ex2_stg_act_q;
ex3_stg_act   <= ex3_stg_act_q;
ex4_stg_act   <= ex4_stg_act_q;
ex5_stg_act   <= ex5_stg_act_q;
binv1_stg_act <= binv1_stg_act_q;
binv2_stg_act <= binv2_stg_act_q;
binv3_stg_act <= binv3_stg_act_q;
binv4_stg_act <= binv4_stg_act_q;
binv5_stg_act <= binv5_stg_act_q;
rel1_stg_act  <= rel1_stg_act_q;
rel2_stg_act  <= ldq_rel_stg24_val;
rel3_stg_act  <= rel3_stg_act_q;

-- ###############################
-- SPR Outputs
-- ###############################
lsu_xu_spr_xucr0_cul <= ex5_unable_2lock_q;
spr_xucr0_cls        <= spr_xucr0_cls_q;
agen_xucr0_cls       <= agen_xucr0_cls_q;
dir_arr_rd_is2_val   <= dir_arr_rd_is2_val_q;
dir_arr_rd_congr_cl  <= xudbg0_reg_q(3 to 7);

-- ###############################
-- AXU Outputs
-- ###############################
xu_fu_ex5_reload_val <= ex5_axu_rel_val_stg2_q;
xu_fu_ex5_load_val   <= ex5_axu_wren_q;
xu_fu_ex5_load_tag   <= ex5_axu_ta_gpr_q;

-- ###############################
-- ICBI Outputs
-- ###############################
xu_iu_ex6_icbi_val  <= ex6_icbi_val_q;
xu_iu_ex6_icbi_addr <= ex6_p_addr_q;

-- XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
-- Registers
-- XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
ex1_optype1_reg: tri_rlmlatch_p
generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => rf1_stg_act_q,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex1_optype1_offset),
            scout   => sov(ex1_optype1_offset),
            din     => ex1_optype1_d,
            dout    => ex1_optype1_q);

ex1_optype2_reg: tri_rlmlatch_p
generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => rf1_stg_act_q,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex1_optype2_offset),
            scout   => sov(ex1_optype2_offset),
            din     => ex1_optype2_d,
            dout    => ex1_optype2_q);

ex1_optype4_reg: tri_rlmlatch_p
generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => rf1_stg_act_q,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex1_optype4_offset),
            scout   => sov(ex1_optype4_offset),
            din     => ex1_optype4_d,
            dout    => ex1_optype4_q);

ex1_optype8_reg: tri_rlmlatch_p
generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => rf1_stg_act_q,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex1_optype8_offset),
            scout   => sov(ex1_optype8_offset),
            din     => ex1_optype8_d,
            dout    => ex1_optype8_q);

ex1_optype16_reg: tri_rlmlatch_p
generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => rf1_stg_act_q,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex1_optype16_offset),
            scout   => sov(ex1_optype16_offset),
            din     => ex1_optype16_d,
            dout    => ex1_optype16_q);

ex1_optype32_reg: tri_rlmlatch_p
generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => rf1_stg_act_q,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex1_optype32_offset),
            scout   => sov(ex1_optype32_offset),
            din     => ex1_optype32_d,
            dout    => ex1_optype32_q);

ex2_optype1_reg: tri_regk
generic map (width => 1, init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => ex1_stg_act_q,
            forcee => func_nsl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_nsl_thold_0_b,
            din(0)  => ex2_optype1_d,
            dout(0) => ex2_optype1_q);

ex2_optype2_reg: tri_regk
generic map (width => 1, init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => ex1_stg_act_q,
            forcee => func_nsl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_nsl_thold_0_b,
            din(0)  => ex2_optype2_d,
            dout(0) => ex2_optype2_q);

ex2_optype4_reg: tri_regk
generic map (width => 1, init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => ex1_stg_act_q,
            forcee => func_nsl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_nsl_thold_0_b,
            din(0)  => ex2_optype4_d,
            dout(0) => ex2_optype4_q);

ex2_optype8_reg: tri_regk
generic map (width => 1, init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => ex1_stg_act_q,
            forcee => func_nsl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_nsl_thold_0_b,
            din(0)  => ex2_optype8_d,
            dout(0) => ex2_optype8_q);

ex2_optype16_reg: tri_regk
generic map (width => 1, init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => ex1_stg_act_q,
            forcee => func_nsl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_nsl_thold_0_b,
            din(0)  => ex2_optype16_d,
            dout(0) => ex2_optype16_q);

ex2_optype32_reg: tri_regk
generic map (width => 1, init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => ex1_stg_act_q,
            forcee => func_nsl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_nsl_thold_0_b,
            din(0)  => ex2_optype32_d,
            dout(0) => ex2_optype32_q);

ex1_dir_acc_val_reg: tri_rlmlatch_p
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
            scin    => siv(ex1_dir_acc_val_offset),
            scout   => sov(ex1_dir_acc_val_offset),
            din     => ex1_dir_acc_val_d,
            dout    => ex1_dir_acc_val_q);

cache_acc_ex1_reg: tri_rlmlatch_p
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
            scin    => siv(cache_acc_ex1_offset),
            scout   => sov(cache_acc_ex1_offset),
            din     => cache_acc_ex1_d,
            dout    => cache_acc_ex1_q);

cache_acc_ex2_reg: tri_rlmlatch_p
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
            scin    => siv(cache_acc_ex2_offset),
            scout   => sov(cache_acc_ex2_offset),
            din     => cache_acc_ex2_d,
            dout    => cache_acc_ex2_q);

cache_acc_ex3_reg: tri_rlmlatch_p
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
            scin    => siv(cache_acc_ex3_offset),
            scout   => sov(cache_acc_ex3_offset),
            din     => cache_acc_ex3_d,
            dout    => cache_acc_ex3_q);

cache_acc_ex4_reg: tri_rlmlatch_p
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
            scin    => siv(cache_acc_ex4_offset),
            scout   => sov(cache_acc_ex4_offset),
            din     => cache_acc_ex4_d,
            dout    => cache_acc_ex4_q);

cache_acc_ex5_reg: tri_rlmlatch_p
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
            scin    => siv(cache_acc_ex5_offset),
            scout   => sov(cache_acc_ex5_offset),
            din     => cache_acc_ex5_d,
            dout    => cache_acc_ex5_q);

ex2_cacc_reg: tri_rlmlatch_p
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
            scin    => siv(ex2_cacc_offset),
            scout   => sov(ex2_cacc_offset),
            din     => ex2_cacc_d,
            dout    => ex2_cacc_q);

ex3_cacc_reg: tri_rlmlatch_p
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
            scin    => siv(ex3_cacc_offset),
            scout   => sov(ex3_cacc_offset),
            din     => ex3_cacc_d,
            dout    => ex3_cacc_q);

ex1_thrd_id_reg: tri_rlmreg_p
generic map (width => 4, init => 0, expand_type => expand_type, needs_sreset => 1)
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
            scin    => siv(ex1_thrd_id_offset to ex1_thrd_id_offset + ex1_thrd_id_d'length-1),
            scout   => sov(ex1_thrd_id_offset to ex1_thrd_id_offset + ex1_thrd_id_d'length-1),
            din     => ex1_thrd_id_d,
            dout    => ex1_thrd_id_q);

ex2_thrd_id_reg: tri_regk
generic map (width => 4, init => 0, expand_type => expand_type, needs_sreset => 1)
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
            din     => ex2_thrd_id_d,
            dout    => ex2_thrd_id_q);

ex3_thrd_id_reg: tri_rlmreg_p
generic map (width => 4, init => 0, expand_type => expand_type, needs_sreset => 1)
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
            scin    => siv(ex3_thrd_id_offset to ex3_thrd_id_offset + ex3_thrd_id_d'length-1),
            scout   => sov(ex3_thrd_id_offset to ex3_thrd_id_offset + ex3_thrd_id_d'length-1),
            din     => ex3_thrd_id_d,
            dout    => ex3_thrd_id_q);

ex4_thrd_id_reg: tri_regk
generic map (width => 4, init => 0, expand_type => expand_type, needs_sreset => 1)
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
            din     => ex4_thrd_id_d,
            dout    => ex4_thrd_id_q);

ex5_thrd_id_reg: tri_rlmreg_p
generic map (width => 4, init => 0, expand_type => expand_type, needs_sreset => 1)
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
            scin    => siv(ex5_thrd_id_offset to ex5_thrd_id_offset + ex5_thrd_id_d'length-1),
            scout   => sov(ex5_thrd_id_offset to ex5_thrd_id_offset + ex5_thrd_id_d'length-1),
            din     => ex5_thrd_id_d,
            dout    => ex5_thrd_id_q);

ex1_target_gpr_reg: tri_rlmreg_p
generic map (width => 9, init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => rf1_stg_act_q,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex1_target_gpr_offset to ex1_target_gpr_offset + ex1_target_gpr_d'length-1),
            scout   => sov(ex1_target_gpr_offset to ex1_target_gpr_offset + ex1_target_gpr_d'length-1),
            din     => ex1_target_gpr_d,
            dout    => ex1_target_gpr_q);

ex2_target_gpr_reg: tri_regk
generic map (width => 9, init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => ex1_stg_act_q,
            forcee => func_nsl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_nsl_thold_0_b,
            din     => ex2_target_gpr_d,
            dout    => ex2_target_gpr_q);

ex3_target_gpr_reg: tri_rlmreg_p
generic map (width => 9, init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => ex2_stg_act_q,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex3_target_gpr_offset to ex3_target_gpr_offset + ex3_target_gpr_d'length-1),
            scout   => sov(ex3_target_gpr_offset to ex3_target_gpr_offset + ex3_target_gpr_d'length-1),
            din     => ex3_target_gpr_d,
            dout    => ex3_target_gpr_q);

ex4_target_gpr_reg: tri_regk
generic map (width => 9, init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => ex3_stg_act_q,
            forcee => func_nsl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_nsl_thold_0_b,
            din     => ex4_target_gpr_d,
            dout    => ex4_target_gpr_q);

ex1_dcbt_instr_reg: tri_rlmlatch_p
generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => rf1_stg_act_q,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex1_dcbt_instr_offset),
            scout   => sov(ex1_dcbt_instr_offset),
            din     => ex1_dcbt_instr_d,
            dout    => ex1_dcbt_instr_q);

ex2_dcbt_instr_reg: tri_regk
generic map (width => 1, init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => ex1_stg_act_q,
            forcee => func_nsl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_nsl_thold_0_b,
            din(0)  => ex2_dcbt_instr_d,
            dout(0) => ex2_dcbt_instr_q);

ex3_dcbt_instr_reg: tri_rlmlatch_p
generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => ex2_stg_act_q,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex3_dcbt_instr_offset),
            scout   => sov(ex3_dcbt_instr_offset),
            din     => ex3_dcbt_instr_d,
            dout    => ex3_dcbt_instr_q);

ex1_dcbtst_instr_reg: tri_rlmlatch_p
generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => rf1_stg_act_q,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex1_dcbtst_instr_offset),
            scout   => sov(ex1_dcbtst_instr_offset),
            din     => ex1_dcbtst_instr_d,
            dout    => ex1_dcbtst_instr_q);

ex2_dcbtst_instr_reg: tri_regk
generic map (width => 1, init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => ex1_stg_act_q,
            forcee => func_nsl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_nsl_thold_0_b,
            din(0)  => ex2_dcbtst_instr_d,
            dout(0) => ex2_dcbtst_instr_q);

ex3_dcbtst_instr_reg: tri_rlmlatch_p
generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => ex2_stg_act_q,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex3_dcbtst_instr_offset),
            scout   => sov(ex3_dcbtst_instr_offset),
            din     => ex3_dcbtst_instr_d,
            dout    => ex3_dcbtst_instr_q);

ex1_dcbst_instr_reg: tri_rlmlatch_p
generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => rf1_stg_act_q,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex1_dcbst_instr_offset),
            scout   => sov(ex1_dcbst_instr_offset),
            din     => ex1_dcbst_instr_d,
            dout    => ex1_dcbst_instr_q);

ex2_dcbst_instr_reg: tri_regk
generic map (width => 1, init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => ex1_stg_act_q,
            forcee => func_nsl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_nsl_thold_0_b,
            din(0)  => ex2_dcbst_instr_d,
            dout(0) => ex2_dcbst_instr_q);

ex3_dcbst_instr_reg: tri_rlmlatch_p
generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => ex2_stg_act_q,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex3_dcbst_instr_offset),
            scout   => sov(ex3_dcbst_instr_offset),
            din     => ex3_dcbst_instr_d,
            dout    => ex3_dcbst_instr_q);

ex1_dcbf_instr_reg: tri_rlmlatch_p
generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => rf1_stg_act_q,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex1_dcbf_instr_offset),
            scout   => sov(ex1_dcbf_instr_offset),
            din     => ex1_dcbf_instr_d,
            dout    => ex1_dcbf_instr_q);

ex2_dcbf_instr_reg: tri_regk
generic map (width => 1, init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => ex1_stg_act_q,
            forcee => func_nsl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_nsl_thold_0_b,
            din(0)  => ex2_dcbf_instr_d,
            dout(0) => ex2_dcbf_instr_q);

ex3_dcbf_instr_reg: tri_rlmlatch_p
generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => ex2_stg_act_q,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex3_dcbf_instr_offset),
            scout   => sov(ex3_dcbf_instr_offset),
            din     => ex3_dcbf_instr_d,
            dout    => ex3_dcbf_instr_q);

ex1_sync_instr_reg: tri_rlmlatch_p
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
            scin    => siv(ex1_sync_instr_offset),
            scout   => sov(ex1_sync_instr_offset),
            din     => ex1_sync_instr_d,
            dout    => ex1_sync_instr_q);

ex2_sync_instr_reg: tri_rlmlatch_p
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
            scin    => siv(ex2_sync_instr_offset),
            scout   => sov(ex2_sync_instr_offset),
            din     => ex2_sync_instr_d,
            dout    => ex2_sync_instr_q);

ex3_sync_instr_reg: tri_rlmlatch_p
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
            scin    => siv(ex3_sync_instr_offset),
            scout   => sov(ex3_sync_instr_offset),
            din     => ex3_sync_instr_d,
            dout    => ex3_sync_instr_q);

ex1_l_fld_reg: tri_rlmreg_p
generic map (width => 2, init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => rf1_stg_act_q,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex1_l_fld_offset to ex1_l_fld_offset + ex1_l_fld_d'length-1),
            scout   => sov(ex1_l_fld_offset to ex1_l_fld_offset + ex1_l_fld_d'length-1),
            din     => ex1_l_fld_d,
            dout    => ex1_l_fld_q);

ex2_l_fld_reg: tri_regk
generic map (width => 2, init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => ex1_stg_act_q,
            forcee => func_nsl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_nsl_thold_0_b,
            din     => ex2_l_fld_d,
            dout    => ex2_l_fld_q);

ex3_l_fld_reg: tri_rlmreg_p
generic map (width => 2, init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => ex2_stg_act_q,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex3_l_fld_offset to ex3_l_fld_offset + ex3_l_fld_d'length-1),
            scout   => sov(ex3_l_fld_offset to ex3_l_fld_offset + ex3_l_fld_d'length-1),
            din     => ex3_l_fld_d,
            dout    => ex3_l_fld_q);

ex1_dcbi_instr_reg: tri_rlmlatch_p
generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => rf1_stg_act_q,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex1_dcbi_instr_offset),
            scout   => sov(ex1_dcbi_instr_offset),
            din     => ex1_dcbi_instr_d,
            dout    => ex1_dcbi_instr_q);

ex2_dcbi_instr_reg: tri_regk
generic map (width => 1, init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => ex1_stg_act_q,
            forcee => func_nsl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_nsl_thold_0_b,
            din(0)  => ex2_dcbi_instr_d,
            dout(0) => ex2_dcbi_instr_q);

ex3_dcbi_instr_reg: tri_rlmlatch_p
generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => ex2_stg_act_q,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex3_dcbi_instr_offset),
            scout   => sov(ex3_dcbi_instr_offset),
            din     => ex3_dcbi_instr_d,
            dout    => ex3_dcbi_instr_q);

ex1_dcbz_instr_reg: tri_rlmlatch_p
generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => rf1_stg_act_q,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex1_dcbz_instr_offset),
            scout   => sov(ex1_dcbz_instr_offset),
            din     => ex1_dcbz_instr_d,
            dout    => ex1_dcbz_instr_q);

ex2_dcbz_instr_reg: tri_regk
generic map (width => 1, init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => ex1_stg_act_q,
            forcee => func_nsl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_nsl_thold_0_b,
            din(0)  => ex2_dcbz_instr_d,
            dout(0) => ex2_dcbz_instr_q);

ex3_dcbz_instr_reg: tri_rlmlatch_p
generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => ex2_stg_act_q,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex3_dcbz_instr_offset),
            scout   => sov(ex3_dcbz_instr_offset),
            din     => ex3_dcbz_instr_d,
            dout    => ex3_dcbz_instr_q);

ex1_icbi_instr_reg: tri_rlmlatch_p
generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => rf1_stg_act_q,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex1_icbi_instr_offset),
            scout   => sov(ex1_icbi_instr_offset),
            din     => ex1_icbi_instr_d,
            dout    => ex1_icbi_instr_q);

ex2_icbi_instr_reg: tri_regk
generic map (width => 1, init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => ex1_stg_act_q,
            forcee => func_nsl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_nsl_thold_0_b,
            din(0)  => ex2_icbi_instr_d,
            dout(0) => ex2_icbi_instr_q);

ex3_icbi_instr_reg: tri_rlmlatch_p
generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => ex2_stg_act_q,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex3_icbi_instr_offset),
            scout   => sov(ex3_icbi_instr_offset),
            din     => ex3_icbi_instr_d,
            dout    => ex3_icbi_instr_q);

ex4_icbi_instr_reg: tri_regk
generic map (width => 1, init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => ex3_stg_act_q,
            forcee => func_nsl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_nsl_thold_0_b,
            din(0)  => ex4_icbi_instr_d,
            dout(0) => ex4_icbi_instr_q);

ex5_icbi_instr_reg: tri_rlmlatch_p
generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => ex4_stg_act_q,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex5_icbi_instr_offset),
            scout   => sov(ex5_icbi_instr_offset),
            din     => ex5_icbi_instr_d,
            dout    => ex5_icbi_instr_q);

ex1_mbar_instr_reg: tri_rlmlatch_p
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
            scin    => siv(ex1_mbar_instr_offset),
            scout   => sov(ex1_mbar_instr_offset),
            din     => ex1_mbar_instr_d,
            dout    => ex1_mbar_instr_q);

ex2_mbar_instr_reg: tri_rlmlatch_p
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
            scin    => siv(ex2_mbar_instr_offset),
            scout   => sov(ex2_mbar_instr_offset),
            din     => ex2_mbar_instr_d,
            dout    => ex2_mbar_instr_q);

ex3_mbar_instr_reg: tri_rlmlatch_p
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
            scin    => siv(ex3_mbar_instr_offset),
            scout   => sov(ex3_mbar_instr_offset),
            din     => ex3_mbar_instr_d,
            dout    => ex3_mbar_instr_q);

ex1_algebraic_reg: tri_rlmlatch_p
generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => rf1_stg_act_q,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex1_algebraic_offset),
            scout   => sov(ex1_algebraic_offset),
            din     => ex1_algebraic_d,
            dout    => ex1_algebraic_q);

ex2_algebraic_reg: tri_regk
generic map (width => 1, init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => ex1_stg_act_q,
            forcee => func_nsl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_nsl_thold_0_b,
            din(0)  => ex2_algebraic_d,
            dout(0) => ex2_algebraic_q);

ex3_algebraic_reg: tri_rlmlatch_p
generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => ex2_stg_act_q,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex3_algebraic_offset),
            scout   => sov(ex3_algebraic_offset),
            din     => ex3_algebraic_d,
            dout    => ex3_algebraic_q);

ex1_byte_rev_reg: tri_rlmlatch_p
generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => rf1_stg_act_q,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex1_byte_rev_offset),
            scout   => sov(ex1_byte_rev_offset),
            din     => ex1_byte_rev_d,
            dout    => ex1_byte_rev_q);

ex2_byte_rev_reg: tri_regk
generic map (width => 1, init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => ex1_stg_act_q,
            forcee => func_nsl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_nsl_thold_0_b,
            din(0)  => ex2_byte_rev_d,
            dout(0) => ex2_byte_rev_q);

ex3_byte_rev_reg: tri_rlmlatch_p
generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => ex2_stg_act_q,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex3_byte_rev_offset),
            scout   => sov(ex3_byte_rev_offset),
            din     => ex3_byte_rev_d,
            dout    => ex3_byte_rev_q);

ex1_lock_instr_reg: tri_rlmlatch_p
generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => rf1_stg_act_q,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex1_lock_instr_offset),
            scout   => sov(ex1_lock_instr_offset),
            din     => ex1_lock_instr_d,
            dout    => ex1_lock_instr_q);

ex2_lock_instr_reg: tri_regk
generic map (width => 1, init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => ex1_stg_act_q,
            forcee => func_nsl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_nsl_thold_0_b,
            din(0)  => ex2_lock_instr_d,
            dout(0) => ex2_lock_instr_q);

ex3_lock_instr_reg: tri_rlmlatch_p
generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => ex2_stg_act_q,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex3_lock_instr_offset),
            scout   => sov(ex3_lock_instr_offset),
            din     => ex3_lock_instr_d,
            dout    => ex3_lock_instr_q);

ex4_lock_instr_reg: tri_regk
generic map (width => 1, init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => ex3_stg_act_q,
            forcee => func_nsl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_nsl_thold_0_b,
            din(0)  => ex4_lock_instr_d,
            dout(0) => ex4_lock_instr_q);

ex5_lock_instr_reg: tri_rlmlatch_p
generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => ex4_stg_act_q,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex5_lock_instr_offset),
            scout   => sov(ex5_lock_instr_offset),
            din     => ex5_lock_instr_d,
            dout    => ex5_lock_instr_q);

ex1_mutex_hint_reg: tri_rlmlatch_p
generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => rf1_stg_act_q,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex1_mutex_hint_offset),
            scout   => sov(ex1_mutex_hint_offset),
            din     => ex1_mutex_hint_d,
            dout    => ex1_mutex_hint_q);

ex2_mutex_hint_reg: tri_regk
generic map (width => 1, init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => ex1_stg_act_q,
            forcee => func_nsl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_nsl_thold_0_b,
            din(0)  => ex2_mutex_hint_d,
            dout(0) => ex2_mutex_hint_q);

ex3_mutex_hint_reg: tri_rlmlatch_p
generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => ex2_stg_act_q,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex3_mutex_hint_offset),
            scout   => sov(ex3_mutex_hint_offset),
            din     => ex3_mutex_hint_d,
            dout    => ex3_mutex_hint_q);

ex1_load_instr_reg: tri_rlmlatch_p
generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => rf1_stg_act_q,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex1_load_instr_offset),
            scout   => sov(ex1_load_instr_offset),
            din     => ex1_load_instr_d,
            dout    => ex1_load_instr_q);

ex2_load_instr_reg: tri_regk
generic map (width => 1, init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => ex1_stg_act_q,
            forcee => func_nsl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_nsl_thold_0_b,
            din(0)  => ex2_load_instr_d,
            dout(0) => ex2_load_instr_q);

ex3_load_instr_reg: tri_rlmlatch_p
generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => ex2_stg_act_q,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex3_load_instr_offset),
            scout   => sov(ex3_load_instr_offset),
            din     => ex3_load_instr_d,
            dout    => ex3_load_instr_q);

ex4_load_instr_reg: tri_regk
generic map (width => 1, init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => ex3_stg_act_q,
            forcee => func_nsl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_nsl_thold_0_b,
            din(0)  => ex4_load_instr_d,
            dout(0) => ex4_load_instr_q);

ex5_load_instr_reg: tri_rlmlatch_p
generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => ex4_stg_act_q,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex5_load_instr_offset),
            scout   => sov(ex5_load_instr_offset),
            din     => ex5_load_instr_d,
            dout    => ex5_load_instr_q);

ex1_store_instr_reg: tri_rlmlatch_p
generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => rf1_stg_act_q,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex1_store_instr_offset),
            scout   => sov(ex1_store_instr_offset),
            din     => ex1_store_instr_d,
            dout    => ex1_store_instr_q);

ex2_store_instr_reg: tri_regk
generic map (width => 1, init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => ex1_stg_act_q,
            forcee => func_nsl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_nsl_thold_0_b,
            din(0)  => ex2_store_instr_d,
            dout(0) => ex2_store_instr_q);

ex3_store_instr_reg: tri_rlmlatch_p
generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => ex2_stg_act_q,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex3_store_instr_offset),
            scout   => sov(ex3_store_instr_offset),
            din     => ex3_store_instr_d,
            dout    => ex3_store_instr_q);

ex3_l2_op_reg: tri_rlmlatch_p
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
            scin    => siv(ex3_l2_op_offset),
            scout   => sov(ex3_l2_op_offset),
            din     => ex3_l2_op_d,
            dout    => ex3_l2_op_q);

ex4_cache_inh_reg: tri_regk
generic map (width => 1, init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => ex3_stg_act_q,
            forcee => func_nsl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_nsl_thold_0_b,
            din(0)  => ex4_cache_inh_d,
            dout(0) => ex4_cache_inh_q);

ex5_cache_inh_reg: tri_rlmlatch_p
generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => ex4_stg_act_q,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex5_cache_inh_offset),
            scout   => sov(ex5_cache_inh_offset),
            din     => ex5_cache_inh_d,
            dout    => ex5_cache_inh_q);

ex3_opsize_reg: tri_rlmreg_p
generic map (width => 6, init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => ex2_stg_act_q,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex3_opsize_offset to ex3_opsize_offset + ex3_opsize_d'length-1),
            scout   => sov(ex3_opsize_offset to ex3_opsize_offset + ex3_opsize_d'length-1),
            din     => ex3_opsize_d,
            dout    => ex3_opsize_q);

ex1_axu_op_val_reg: tri_rlmlatch_p
generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => rf1_stg_act_q,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex1_axu_op_val_offset),
            scout   => sov(ex1_axu_op_val_offset),
            din     => ex1_axu_op_val_d,
            dout    => ex1_axu_op_val_q);

ex2_axu_op_val_reg: tri_regk
generic map (width => 1, init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => ex1_stg_act_q,
            forcee => func_nsl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_nsl_thold_0_b,
            din(0)  => ex2_axu_op_val_d,
            dout(0) => ex2_axu_op_val_q);

ex3_axu_op_val_reg: tri_rlmlatch_p
generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => ex2_stg_act_q,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex3_axu_op_val_offset),
            scout   => sov(ex3_axu_op_val_offset),
            din     => ex3_axu_op_val_d,
            dout    => ex3_axu_op_val_q);

ex4_axu_op_val_reg: tri_regk
generic map (width => 1, init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => ex3_stg_act_q,
            forcee => func_nsl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_nsl_thold_0_b,
            din(0)  => ex4_axu_op_val_d,
            dout(0) => ex4_axu_op_val_q);

ex5_axu_op_val_reg: tri_rlmlatch_p
generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => ex4_stg_act_q,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex5_axu_op_val_offset),
            scout   => sov(ex5_axu_op_val_offset),
            din     => ex5_axu_op_val_d,
            dout    => ex5_axu_op_val_q);

rel_upd_gpr_reg: tri_rlmlatch_p
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
            scin    => siv(rel_upd_gpr_offset),
            scout   => sov(rel_upd_gpr_offset),
            din     => rel_upd_gpr_d,
            dout    => rel_upd_gpr_q);

rel_axu_op_val_reg: tri_rlmlatch_p
generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => rel1_stg_act_q,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(rel_axu_op_val_offset),
            scout   => sov(rel_axu_op_val_offset),
            din     => rel_axu_op_val_d,
            dout    => rel_axu_op_val_q);

rel_thrd_id_reg: tri_rlmreg_p
generic map (width => 4, init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => rel1_stg_act_q,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(rel_thrd_id_offset to rel_thrd_id_offset + rel_thrd_id_d'length-1),
            scout   => sov(rel_thrd_id_offset to rel_thrd_id_offset + rel_thrd_id_d'length-1),
            din     => rel_thrd_id_d,
            dout    => rel_thrd_id_q);

rel_ta_gpr_reg: tri_rlmreg_p
generic map (width => 9, init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => rel1_stg_act_q,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(rel_ta_gpr_offset to rel_ta_gpr_offset + rel_ta_gpr_d'length-1),
            scout   => sov(rel_ta_gpr_offset to rel_ta_gpr_offset + rel_ta_gpr_d'length-1),
            din     => rel_ta_gpr_d,
            dout    => rel_ta_gpr_q);

ex4_load_commit_reg: tri_rlmlatch_p
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
            scin    => siv(ex4_load_commit_offset),
            scout   => sov(ex4_load_commit_offset),
            din     => ex4_load_commit_d,
            dout    => ex4_load_commit_q);

ex5_load_hit_reg: tri_rlmlatch_p
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
            scin    => siv(ex5_load_hit_offset),
            scout   => sov(ex5_load_hit_offset),
            din     => ex5_load_hit_d,
            dout    => ex5_load_hit_q);

ex5_axu_rel_val_stg1_reg: tri_rlmlatch_p
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
            scin    => siv(ex5_axu_rel_val_stg1_offset),
            scout   => sov(ex5_axu_rel_val_stg1_offset),
            din     => ex5_axu_rel_val_stg1_d,
            dout    => ex5_axu_rel_val_stg1_q);

ex5_axu_rel_val_stg2_reg: tri_rlmlatch_p
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
            scin    => siv(ex5_axu_rel_val_stg2_offset),
            scout   => sov(ex5_axu_rel_val_stg2_offset),
            din     => ex5_axu_rel_val_stg2_d,
            dout    => ex5_axu_rel_val_stg2_q);

ex5_axu_wren_reg: tri_rlmreg_p
generic map (width => 4, init => 0, expand_type => expand_type, needs_sreset => 1)
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
            scin    => siv(ex5_axu_wren_offset to ex5_axu_wren_offset + ex5_axu_wren_d'length-1),
            scout   => sov(ex5_axu_wren_offset to ex5_axu_wren_offset + ex5_axu_wren_d'length-1),
            din     => ex5_axu_wren_d,
            dout    => ex5_axu_wren_q);

ex5_axu_ta_gpr_reg: tri_rlmreg_p
generic map (width => 9, init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => rel4_ex4_stg_act,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex5_axu_ta_gpr_offset to ex5_axu_ta_gpr_offset + ex5_axu_ta_gpr_d'length-1),
            scout   => sov(ex5_axu_ta_gpr_offset to ex5_axu_ta_gpr_offset + ex5_axu_ta_gpr_d'length-1),
            din     => ex5_axu_ta_gpr_d,
            dout    => ex5_axu_ta_gpr_q);

rel_xu_ta_gpr_reg: tri_rlmreg_p
generic map (width => 8, init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => ldq_rel_stg24_val,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(rel_xu_ta_gpr_offset to rel_xu_ta_gpr_offset + rel_xu_ta_gpr_d'length-1),
            scout   => sov(rel_xu_ta_gpr_offset to rel_xu_ta_gpr_offset + rel_xu_ta_gpr_d'length-1),
            din     => rel_xu_ta_gpr_d,
            dout    => rel_xu_ta_gpr_q);

lsu_slowspr_val_reg: tri_rlmlatch_p
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
            scin    => siv(lsu_slowspr_val_offset),
            scout   => sov(lsu_slowspr_val_offset),
            din     => lsu_slowspr_val_d,
            dout    => lsu_slowspr_val_q);

lsu_slowspr_rw_reg: tri_rlmlatch_p
generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => xu_lsu_slowspr_val,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(lsu_slowspr_rw_offset),
            scout   => sov(lsu_slowspr_rw_offset),
            din     => lsu_slowspr_rw_d,
            dout    => lsu_slowspr_rw_q);

lsu_slowspr_etid_reg: tri_rlmreg_p
generic map (width => 2, init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => xu_lsu_slowspr_val,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(lsu_slowspr_etid_offset to lsu_slowspr_etid_offset + lsu_slowspr_etid_d'length-1),
            scout   => sov(lsu_slowspr_etid_offset to lsu_slowspr_etid_offset + lsu_slowspr_etid_d'length-1),
            din     => lsu_slowspr_etid_d,
            dout    => lsu_slowspr_etid_q);

lsu_slowspr_addr_reg: tri_rlmreg_p
generic map (width => 10, init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => xu_lsu_slowspr_val,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(lsu_slowspr_addr_offset to lsu_slowspr_addr_offset + lsu_slowspr_addr_d'length-1),
            scout   => sov(lsu_slowspr_addr_offset to lsu_slowspr_addr_offset + lsu_slowspr_addr_d'length-1),
            din     => lsu_slowspr_addr_d,
            dout    => lsu_slowspr_addr_q);

lsu_slowspr_data_reg: tri_rlmreg_p
generic map (width => 2**REGMODE, init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => xu_lsu_slowspr_val,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(lsu_slowspr_data_offset to lsu_slowspr_data_offset + lsu_slowspr_data_d'length-1),
            scout   => sov(lsu_slowspr_data_offset to lsu_slowspr_data_offset + lsu_slowspr_data_d'length-1),
            din     => lsu_slowspr_data_d,
            dout    => lsu_slowspr_data_q);

lsu_slowspr_done_reg: tri_rlmlatch_p
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
            scin    => siv(lsu_slowspr_done_offset),
            scout   => sov(lsu_slowspr_done_offset),
            din     => lsu_slowspr_done_d,
            dout    => lsu_slowspr_done_q);

mm_slowspr_val_reg: tri_rlmlatch_p
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
            scin    => siv(mm_slowspr_val_offset),
            scout   => sov(mm_slowspr_val_offset),
            din     => mm_slowspr_val_d,
            dout    => mm_slowspr_val_q);

mm_slowspr_rw_reg: tri_rlmlatch_p
generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => lsu_slowspr_val_q,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(mm_slowspr_rw_offset),
            scout   => sov(mm_slowspr_rw_offset),
            din     => mm_slowspr_rw_d,
            dout    => mm_slowspr_rw_q);

mm_slowspr_etid_reg: tri_rlmreg_p
generic map (width => 2, init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => lsu_slowspr_val_q,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(mm_slowspr_etid_offset to mm_slowspr_etid_offset + mm_slowspr_etid_d'length-1),
            scout   => sov(mm_slowspr_etid_offset to mm_slowspr_etid_offset + mm_slowspr_etid_d'length-1),
            din     => mm_slowspr_etid_d,
            dout    => mm_slowspr_etid_q);

mm_slowspr_addr_reg: tri_rlmreg_p
generic map (width => 10, init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => lsu_slowspr_val_q,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(mm_slowspr_addr_offset to mm_slowspr_addr_offset + mm_slowspr_addr_d'length-1),
            scout   => sov(mm_slowspr_addr_offset to mm_slowspr_addr_offset + mm_slowspr_addr_d'length-1),
            din     => mm_slowspr_addr_d,
            dout    => mm_slowspr_addr_q);

mm_slowspr_data_reg: tri_rlmreg_p
generic map (width => 2**REGMODE, init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => lsu_slowspr_val_q,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(mm_slowspr_data_offset to mm_slowspr_data_offset + mm_slowspr_data_d'length-1),
            scout   => sov(mm_slowspr_data_offset to mm_slowspr_data_offset + mm_slowspr_data_d'length-1),
            din     => mm_slowspr_data_d,
            dout    => mm_slowspr_data_q);

mm_slowspr_done_reg: tri_rlmlatch_p
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
            scin    => siv(mm_slowspr_done_offset),
            scout   => sov(mm_slowspr_done_offset),
            din     => mm_slowspr_done_d,
            dout    => mm_slowspr_done_q);

ex1_th_fld_c_reg: tri_rlmlatch_p
generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => rf1_stg_act_q,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex1_th_fld_c_offset),
            scout   => sov(ex1_th_fld_c_offset),
            din     => ex1_th_fld_c_d,
            dout    => ex1_th_fld_c_q);

ex2_th_fld_c_reg: tri_regk
generic map (width => 1, init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => ex1_stg_act_q,
            forcee => func_nsl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_nsl_thold_0_b,
            din(0)  => ex2_th_fld_c_d,
            dout(0) => ex2_th_fld_c_q);

ex3_th_fld_c_reg: tri_rlmlatch_p
generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => ex2_stg_act_q,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex3_th_fld_c_offset),
            scout   => sov(ex3_th_fld_c_offset),
            din     => ex3_th_fld_c_d,
            dout    => ex3_th_fld_c_q);

ex1_th_fld_l2_reg: tri_rlmlatch_p
generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => rf1_stg_act_q,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex1_th_fld_l2_offset),
            scout   => sov(ex1_th_fld_l2_offset),
            din     => ex1_th_fld_l2_d,
            dout    => ex1_th_fld_l2_q);

ex2_th_fld_l2_reg: tri_regk
generic map (width => 1, init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => ex1_stg_act_q,
            forcee => func_nsl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_nsl_thold_0_b,
            din(0)  => ex2_th_fld_l2_d,
            dout(0) => ex2_th_fld_l2_q);

ex3_th_fld_l2_reg: tri_rlmlatch_p
generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => ex2_stg_act_q,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex3_th_fld_l2_offset),
            scout   => sov(ex3_th_fld_l2_offset),
            din     => ex3_th_fld_l2_d,
            dout    => ex3_th_fld_l2_q);

ex1_dcbtls_instr_reg: tri_rlmlatch_p
generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => rf1_stg_act_q,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex1_dcbtls_instr_offset),
            scout   => sov(ex1_dcbtls_instr_offset),
            din     => ex1_dcbtls_instr_d,
            dout    => ex1_dcbtls_instr_q);

ex2_dcbtls_instr_reg: tri_regk
generic map (width => 1, init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => ex1_stg_act_q,
            forcee => func_nsl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_nsl_thold_0_b,
            din(0)  => ex2_dcbtls_instr_d,
            dout(0) => ex2_dcbtls_instr_q);

ex3_dcbtls_instr_reg: tri_rlmlatch_p
generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => ex2_stg_act_q,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex3_dcbtls_instr_offset),
            scout   => sov(ex3_dcbtls_instr_offset),
            din     => ex3_dcbtls_instr_d,
            dout    => ex3_dcbtls_instr_q);

ex3_l2_request_reg: tri_rlmlatch_p
generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => ex2_stg_act_q,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex3_l2_request_offset),
            scout   => sov(ex3_l2_request_offset),
            din     => ex3_l2_request_d,
            dout    => ex3_l2_request_q);

ex1_dcbtstls_instr_reg: tri_rlmlatch_p
generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => rf1_stg_act_q,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex1_dcbtstls_instr_offset),
            scout   => sov(ex1_dcbtstls_instr_offset),
            din     => ex1_dcbtstls_instr_d,
            dout    => ex1_dcbtstls_instr_q);

ex2_dcbtstls_instr_reg: tri_regk
generic map (width => 1, init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => ex1_stg_act_q,
            forcee => func_nsl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_nsl_thold_0_b,
            din(0)  => ex2_dcbtstls_instr_d,
            dout(0) => ex2_dcbtstls_instr_q);

ex3_dcbtstls_instr_reg: tri_rlmlatch_p
generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => ex2_stg_act_q,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex3_dcbtstls_instr_offset),
            scout   => sov(ex3_dcbtstls_instr_offset),
            din     => ex3_dcbtstls_instr_d,
            dout    => ex3_dcbtstls_instr_q);

ex1_dcblc_instr_reg: tri_rlmlatch_p
generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => rf1_stg_act_q,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex1_dcblc_instr_offset),
            scout   => sov(ex1_dcblc_instr_offset),
            din     => ex1_dcblc_instr_d,
            dout    => ex1_dcblc_instr_q);

ex2_dcblc_instr_reg: tri_regk
generic map (width => 1, init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => ex1_stg_act_q,
            forcee => func_nsl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_nsl_thold_0_b,
            din(0)  => ex2_dcblc_instr_d,
            dout(0) => ex2_dcblc_instr_q);

ex3_dcblc_instr_reg: tri_rlmlatch_p
generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => ex2_stg_act_q,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex3_dcblc_instr_offset),
            scout   => sov(ex3_dcblc_instr_offset),
            din     => ex3_dcblc_instr_d,
            dout    => ex3_dcblc_instr_q);

ex1_icblc_l2_instr_reg: tri_rlmlatch_p
generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => rf1_stg_act_q,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex1_icblc_l2_instr_offset),
            scout   => sov(ex1_icblc_l2_instr_offset),
            din     => ex1_icblc_l2_instr_d,
            dout    => ex1_icblc_l2_instr_q);

ex2_icblc_l2_instr_reg: tri_regk
generic map (width => 1, init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => ex1_stg_act_q,
            forcee => func_nsl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_nsl_thold_0_b,
            din(0)  => ex2_icblc_l2_instr_d,
            dout(0) => ex2_icblc_l2_instr_q);

ex3_icblc_l2_instr_reg: tri_rlmlatch_p
generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => ex2_stg_act_q,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex3_icblc_l2_instr_offset),
            scout   => sov(ex3_icblc_l2_instr_offset),
            din     => ex3_icblc_l2_instr_d,
            dout    => ex3_icblc_l2_instr_q);

ex1_icbt_l2_instr_reg: tri_rlmlatch_p
generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => rf1_stg_act_q,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex1_icbt_l2_instr_offset),
            scout   => sov(ex1_icbt_l2_instr_offset),
            din     => ex1_icbt_l2_instr_d,
            dout    => ex1_icbt_l2_instr_q);

ex2_icbt_l2_instr_reg: tri_regk
generic map (width => 1, init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => ex1_stg_act_q,
            forcee => func_nsl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_nsl_thold_0_b,
            din(0)  => ex2_icbt_l2_instr_d,
            dout(0) => ex2_icbt_l2_instr_q);

ex3_icbt_l2_instr_reg: tri_rlmlatch_p
generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => ex2_stg_act_q,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex3_icbt_l2_instr_offset),
            scout   => sov(ex3_icbt_l2_instr_offset),
            din     => ex3_icbt_l2_instr_d,
            dout    => ex3_icbt_l2_instr_q);

ex1_icbtls_l2_instr_reg: tri_rlmlatch_p
generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => rf1_stg_act_q,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex1_icbtls_l2_instr_offset),
            scout   => sov(ex1_icbtls_l2_instr_offset),
            din     => ex1_icbtls_l2_instr_d,
            dout    => ex1_icbtls_l2_instr_q);

ex2_icbtls_l2_instr_reg: tri_regk
generic map (width => 1, init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => ex1_stg_act_q,
            forcee => func_nsl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_nsl_thold_0_b,
            din(0)  => ex2_icbtls_l2_instr_d,
            dout(0) => ex2_icbtls_l2_instr_q);

ex3_icbtls_l2_instr_reg: tri_rlmlatch_p
generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => ex2_stg_act_q,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex3_icbtls_l2_instr_offset),
            scout   => sov(ex3_icbtls_l2_instr_offset),
            din     => ex3_icbtls_l2_instr_d,
            dout    => ex3_icbtls_l2_instr_q);

ex1_tlbsync_instr_reg: tri_rlmlatch_p
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
            scin    => siv(ex1_tlbsync_instr_offset),
            scout   => sov(ex1_tlbsync_instr_offset),
            din     => ex1_tlbsync_instr_d,
            dout    => ex1_tlbsync_instr_q);

ex2_tlbsync_instr_reg: tri_rlmlatch_p
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
            scin    => siv(ex2_tlbsync_instr_offset),
            scout   => sov(ex2_tlbsync_instr_offset),
            din     => ex2_tlbsync_instr_d,
            dout    => ex2_tlbsync_instr_q);

ex3_tlbsync_instr_reg: tri_rlmlatch_p
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
            scin    => siv(ex3_tlbsync_instr_offset),
            scout   => sov(ex3_tlbsync_instr_offset),
            din     => ex3_tlbsync_instr_d,
            dout    => ex3_tlbsync_instr_q);

ex1_src0_vld_reg: tri_rlmlatch_p
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
            scin    => siv(ex1_src0_vld_offset),
            scout   => sov(ex1_src0_vld_offset),
            din     => ex1_src0_vld_d,
            dout    => ex1_src0_vld_q);

ex1_src0_reg_reg: tri_rlmreg_p
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
            scin    => siv(ex1_src0_reg_offset to ex1_src0_reg_offset + ex1_src0_reg_d'length-1),
            scout   => sov(ex1_src0_reg_offset to ex1_src0_reg_offset + ex1_src0_reg_d'length-1),
            din     => ex1_src0_reg_d,
            dout    => ex1_src0_reg_q);

ex1_src1_vld_reg: tri_rlmlatch_p
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
            scin    => siv(ex1_src1_vld_offset),
            scout   => sov(ex1_src1_vld_offset),
            din     => ex1_src1_vld_d,
            dout    => ex1_src1_vld_q);

ex1_src1_reg_reg: tri_rlmreg_p
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
            scin    => siv(ex1_src1_reg_offset to ex1_src1_reg_offset + ex1_src1_reg_d'length-1),
            scout   => sov(ex1_src1_reg_offset to ex1_src1_reg_offset + ex1_src1_reg_d'length-1),
            din     => ex1_src1_reg_d,
            dout    => ex1_src1_reg_q);

ex1_targ_vld_reg: tri_rlmlatch_p
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
            scin    => siv(ex1_targ_vld_offset),
            scout   => sov(ex1_targ_vld_offset),
            din     => ex1_targ_vld_d,
            dout    => ex1_targ_vld_q);

ex1_targ_reg_reg: tri_rlmreg_p
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
            scin    => siv(ex1_targ_reg_offset to ex1_targ_reg_offset + ex1_targ_reg_d'length-1),
            scout   => sov(ex1_targ_reg_offset to ex1_targ_reg_offset + ex1_targ_reg_d'length-1),
            din     => ex1_targ_reg_d,
            dout    => ex1_targ_reg_q);

ex5_instr_val_reg: tri_rlmlatch_p
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
            scin    => siv(ex5_instr_val_offset),
            scout   => sov(ex5_instr_val_offset),
            din     => ex5_instr_val_d,
            dout    => ex5_instr_val_q);

ex2_targ_match_b1_reg: tri_rlmlatch_p
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
            scin    => siv(ex2_targ_match_b1_offset),
            scout   => sov(ex2_targ_match_b1_offset),
            din     => ex2_targ_match_b1_d,
            dout    => ex2_targ_match_b1_q);

ex3_targ_match_b1_reg: tri_rlmlatch_p
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
            scin    => siv(ex3_targ_match_b1_offset),
            scout   => sov(ex3_targ_match_b1_offset),
            din     => ex3_targ_match_b1_d,
            dout    => ex3_targ_match_b1_q);

ex4_targ_match_b1_reg: tri_rlmlatch_p
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
            scin    => siv(ex4_targ_match_b1_offset),
            scout   => sov(ex4_targ_match_b1_offset),
            din     => ex4_targ_match_b1_d,
            dout    => ex4_targ_match_b1_q);

ex5_targ_match_b1_reg: tri_rlmlatch_p
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
            scin    => siv(ex5_targ_match_b1_offset),
            scout   => sov(ex5_targ_match_b1_offset),
            din     => ex5_targ_match_b1_d,
            dout    => ex5_targ_match_b1_q);

ex6_targ_match_b1_reg: tri_rlmlatch_p
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
            scin    => siv(ex6_targ_match_b1_offset),
            scout   => sov(ex6_targ_match_b1_offset),
            din     => ex6_targ_match_b1_d,
            dout    => ex6_targ_match_b1_q);

ex2_targ_match_b2_reg: tri_rlmlatch_p
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
            scin    => siv(ex2_targ_match_b2_offset),
            scout   => sov(ex2_targ_match_b2_offset),
            din     => ex2_targ_match_b2_d,
            dout    => ex2_targ_match_b2_q);

ex3_targ_match_b2_reg: tri_rlmlatch_p
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
            scin    => siv(ex3_targ_match_b2_offset),
            scout   => sov(ex3_targ_match_b2_offset),
            din     => ex3_targ_match_b2_d,
            dout    => ex3_targ_match_b2_q);

ex4_targ_match_b2_reg: tri_rlmlatch_p
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
            scin    => siv(ex4_targ_match_b2_offset),
            scout   => sov(ex4_targ_match_b2_offset),
            din     => ex4_targ_match_b2_d,
            dout    => ex4_targ_match_b2_q);

ex5_targ_match_b2_reg: tri_rlmlatch_p
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
            scin    => siv(ex5_targ_match_b2_offset),
            scout   => sov(ex5_targ_match_b2_offset),
            din     => ex5_targ_match_b2_d,
            dout    => ex5_targ_match_b2_q);

ex7_targ_match_reg: tri_rlmlatch_p
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
            scin    => siv(ex7_targ_match_offset),
            scout   => sov(ex7_targ_match_offset),
            din     => ex7_targ_match_d,
            dout    => ex7_targ_match_q);

ex8_targ_match_reg: tri_rlmlatch_p
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
            scin    => siv(ex8_targ_match_offset),
            scout   => sov(ex8_targ_match_offset),
            din     => ex8_targ_match_d,
            dout    => ex8_targ_match_q);

ex1_ldst_falign_reg: tri_rlmlatch_p
generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => rf1_stg_act_q,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex1_ldst_falign_offset),
            scout   => sov(ex1_ldst_falign_offset),
            din     => ex1_ldst_falign_d,
            dout    => ex1_ldst_falign_q);

ex1_ldst_fexcpt_reg: tri_rlmlatch_p
generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => rf1_stg_act_q,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex1_ldst_fexcpt_offset),
            scout   => sov(ex1_ldst_fexcpt_offset),
            din     => ex1_ldst_fexcpt_d,
            dout    => ex1_ldst_fexcpt_q);

ex2_ldst_fexcpt_reg: tri_regk
generic map (width => 1, init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => ex1_stg_act_q,
            forcee => func_nsl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_nsl_thold_0_b,
            din(0)  => ex2_ldst_fexcpt_d,
            dout(0) => ex2_ldst_fexcpt_q);

ex5_load_miss_reg: tri_rlmlatch_p
generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => ex4_stg_act_q,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex5_load_miss_offset),
            scout   => sov(ex5_load_miss_offset),
            din     => ex5_load_miss_d,
            dout    => ex5_load_miss_q);

xucr2_reg_a_reg : tri_ser_rlmreg_p
generic map (width => 16, init => 65535, expand_type => expand_type, needs_sreset => 1)
port map(vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => xucr2_wen,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(xucr2_reg_a_offset to xucr2_reg_a_offset + ((xucr2_reg_d'length)/2)-1),
            scout   => sov(xucr2_reg_a_offset to xucr2_reg_a_offset + ((xucr2_reg_d'length)/2)-1),
            din     => xucr2_reg_d(0 to 15),
            dout    => xucr2_reg_q(0 to 15));

xucr2_reg_b_reg: tri_ser_rlmreg_p
generic map (width => 16, init => 65535, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => xucr2_wen,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(xucr2_reg_b_offset to xucr2_reg_b_offset + ((xucr2_reg_d'length)/2)-1),
            scout   => sov(xucr2_reg_b_offset to xucr2_reg_b_offset + ((xucr2_reg_d'length)/2)-1),
            din     => xucr2_reg_d(16 to 31),
            dout    => xucr2_reg_q(16 to 31));

dvc1_act_reg: tri_rlmlatch_p
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
            scin    => siv(dvc1_act_offset),
            scout   => sov(dvc1_act_offset),
            din     => dvc1_act_d,
            dout    => dvc1_act_q);

dvc2_act_reg: tri_rlmlatch_p
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
            scin    => siv(dvc2_act_offset),
            scout   => sov(dvc2_act_offset),
            din     => dvc2_act_d,
            dout    => dvc2_act_q);

dvc1_reg_reg: tri_ser_rlmreg_p
generic map (width => (2**REGMODE), init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => dvc1_wen,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(dvc1_reg_offset to dvc1_reg_offset + dvc1_reg_d'length-1),
            scout   => sov(dvc1_reg_offset to dvc1_reg_offset + dvc1_reg_d'length-1),
            din     => dvc1_reg_d,
            dout    => dvc1_reg_q);

dvc2_reg_reg: tri_ser_rlmreg_p
generic map (width => (2**REGMODE), init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => dvc2_wen,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(dvc2_reg_offset to dvc2_reg_offset + dvc2_reg_d'length-1),
            scout   => sov(dvc2_reg_offset to dvc2_reg_offset + dvc2_reg_d'length-1),
            din     => dvc2_reg_d,
            dout    => dvc2_reg_q);

xudbg0_reg_reg: tri_ser_rlmreg_p
generic map (width => 8, init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => xudbg0_wen,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(xudbg0_reg_offset to xudbg0_reg_offset + xudbg0_reg_d'length-1),
            scout   => sov(xudbg0_reg_offset to xudbg0_reg_offset + xudbg0_reg_d'length-1),
            din     => xudbg0_reg_d,
            dout    => xudbg0_reg_q);

xudbg0_done_reg_reg: tri_rlmlatch_p
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
            scin    => siv(xudbg0_done_reg_offset),
            scout   => sov(xudbg0_done_reg_offset),
            din     => xudbg0_done_reg_d,
            dout    => xudbg0_done_reg_q);

xudbg1_dir_reg_reg: tri_ser_rlmreg_p
generic map (width => 13, init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => dir_arr_rd_ex4_done_q,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(xudbg1_dir_reg_offset to xudbg1_dir_reg_offset + xudbg1_dir_reg_d'length-1),
            scout   => sov(xudbg1_dir_reg_offset to xudbg1_dir_reg_offset + xudbg1_dir_reg_d'length-1),
            din     => xudbg1_dir_reg_d,
            dout    => xudbg1_dir_reg_q);

xudbg1_parity_reg_reg: tri_ser_rlmreg_p
generic map (width => parBits, init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => dir_arr_rd_ex3_done_q,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(xudbg1_parity_reg_offset to xudbg1_parity_reg_offset + xudbg1_parity_reg_d'length-1),
            scout   => sov(xudbg1_parity_reg_offset to xudbg1_parity_reg_offset + xudbg1_parity_reg_d'length-1),
            din     => xudbg1_parity_reg_d,
            dout    => xudbg1_parity_reg_q);

xudbg2_reg_reg: tri_ser_rlmreg_p
generic map (width => 31, init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => dir_arr_rd_ex3_done_q,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(xudbg2_reg_offset to xudbg2_reg_offset + xudbg2_reg_d'length-1),
            scout   => sov(xudbg2_reg_offset to xudbg2_reg_offset + xudbg2_reg_d'length-1),
            din     => xudbg2_reg_d,
            dout    => xudbg2_reg_q);

ex4_store_commit_reg: tri_rlmlatch_p
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
            scin    => siv(ex4_store_commit_offset),
            scout   => sov(ex4_store_commit_offset),
            din     => ex4_store_commit_d,
            dout    => ex4_store_commit_q);

ex1_sgpr_instr_reg: tri_rlmlatch_p
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
            scin    => siv(ex1_sgpr_instr_offset),
            scout   => sov(ex1_sgpr_instr_offset),
            din     => ex1_sgpr_instr_d,
            dout    => ex1_sgpr_instr_q);

ex1_saxu_instr_reg: tri_rlmlatch_p
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
            scin    => siv(ex1_saxu_instr_offset),
            scout   => sov(ex1_saxu_instr_offset),
            din     => ex1_saxu_instr_d,
            dout    => ex1_saxu_instr_q);

ex1_sdp_instr_reg: tri_rlmlatch_p
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
            scin    => siv(ex1_sdp_instr_offset),
            scout   => sov(ex1_sdp_instr_offset),
            din     => ex1_sdp_instr_d,
            dout    => ex1_sdp_instr_q);

ex1_tgpr_instr_reg: tri_rlmlatch_p
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
            scin    => siv(ex1_tgpr_instr_offset),
            scout   => sov(ex1_tgpr_instr_offset),
            din     => ex1_tgpr_instr_d,
            dout    => ex1_tgpr_instr_q);

ex1_taxu_instr_reg: tri_rlmlatch_p
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
            scin    => siv(ex1_taxu_instr_offset),
            scout   => sov(ex1_taxu_instr_offset),
            din     => ex1_taxu_instr_d,
            dout    => ex1_taxu_instr_q);

ex1_tdp_instr_reg: tri_rlmlatch_p
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
            scin    => siv(ex1_tdp_instr_offset),
            scout   => sov(ex1_tdp_instr_offset),
            din     => ex1_tdp_instr_d,
            dout    => ex1_tdp_instr_q);

ex2_tgpr_instr_reg: tri_rlmlatch_p
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
            scin    => siv(ex2_tgpr_instr_offset),
            scout   => sov(ex2_tgpr_instr_offset),
            din     => ex2_tgpr_instr_d,
            dout    => ex2_tgpr_instr_q);

ex2_taxu_instr_reg: tri_rlmlatch_p
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
            scin    => siv(ex2_taxu_instr_offset),
            scout   => sov(ex2_taxu_instr_offset),
            din     => ex2_taxu_instr_d,
            dout    => ex2_taxu_instr_q);

ex2_tdp_instr_reg: tri_rlmlatch_p
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
            scin    => siv(ex2_tdp_instr_offset),
            scout   => sov(ex2_tdp_instr_offset),
            din     => ex2_tdp_instr_d,
            dout    => ex2_tdp_instr_q);

ex3_tgpr_instr_reg: tri_rlmlatch_p
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
            scin    => siv(ex3_tgpr_instr_offset),
            scout   => sov(ex3_tgpr_instr_offset),
            din     => ex3_tgpr_instr_d,
            dout    => ex3_tgpr_instr_q);

ex3_taxu_instr_reg: tri_rlmlatch_p
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
            scin    => siv(ex3_taxu_instr_offset),
            scout   => sov(ex3_taxu_instr_offset),
            din     => ex3_taxu_instr_d,
            dout    => ex3_taxu_instr_q);

ex4_tgpr_instr_reg: tri_rlmlatch_p
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
            scin    => siv(ex4_tgpr_instr_offset),
            scout   => sov(ex4_tgpr_instr_offset),
            din     => ex4_tgpr_instr_d,
            dout    => ex4_tgpr_instr_q);

ex4_taxu_instr_reg: tri_rlmlatch_p
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
            scin    => siv(ex4_taxu_instr_offset),
            scout   => sov(ex4_taxu_instr_offset),
            din     => ex4_taxu_instr_d,
            dout    => ex4_taxu_instr_q);

ex2_blkable_touch_reg: tri_regk
generic map (width => 1,init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => ex1_stg_act_q,
            forcee => func_nsl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_nsl_thold_0_b,
            din(0)  => ex2_blkable_touch_d,
            dout(0) => ex2_blkable_touch_q);

ex3_blkable_touch_reg: tri_rlmlatch_p
generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => ex2_stg_act_q,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex3_blkable_touch_offset),
            scout   => sov(ex3_blkable_touch_offset),
            din     => ex3_blkable_touch_d,
            dout    => ex3_blkable_touch_q);

ex3_p_addr_lwr_reg: tri_rlmreg_p
generic map (width => 12, init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => binv2_ex2_stg_act,
            forcee => func_slp_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_slp_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex3_p_addr_lwr_offset to ex3_p_addr_lwr_offset + ex3_p_addr_lwr_d'length-1),
            scout   => sov(ex3_p_addr_lwr_offset to ex3_p_addr_lwr_offset + ex3_p_addr_lwr_d'length-1),
            din     => ex3_p_addr_lwr_d,
            dout    => ex3_p_addr_lwr_q);

ex4_p_addr_reg: tri_regk
generic map (width => real_data_add, init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => ex3_stg_act_q,
            forcee => func_slp_nsl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_slp_nsl_thold_0_b,
            din     => ex4_p_addr_d,
            dout    => ex4_p_addr_q);

ex5_p_addr_reg: tri_rlmreg_p
generic map (width => real_data_add-6, init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => ex4_stg_act_q,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex5_p_addr_offset to ex5_p_addr_offset + ex5_p_addr_d'length-1),
            scout   => sov(ex5_p_addr_offset to ex5_p_addr_offset + ex5_p_addr_d'length-1),
            din     => ex5_p_addr_d,
            dout    => ex5_p_addr_q);

ex6_p_addr_reg: tri_regk
generic map (width => real_data_add-6, init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => ex5_stg_act_q,
            forcee => func_nsl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_nsl_thold_0_b,
            din     => ex6_p_addr_d,
            dout    => ex6_p_addr_q);

ex4_c_inh_reg: tri_regk
generic map (width => 1, init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => ex3_stg_act_q,
            forcee => func_nsl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_nsl_thold_0_b,
            din(0)  => ex4_c_inh_d,
            dout(0) => ex4_c_inh_q);

ex4_opsize_reg: tri_regk
generic map (width => ex4_opsize_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => ex3_stg_act_q,
            forcee => func_nsl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_nsl_thold_0_b,
            din     => ex4_opsize_d,
            dout    => ex4_opsize_q);

ex4_rot_sel_reg: tri_regk
generic map (width => ex4_rot_sel_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => ex3_stg_act_q,
            forcee => func_nsl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_nsl_thold_0_b,
            din     => ex4_rot_sel_d,
            dout    => ex4_rot_sel_q);

ex4_data_swap_val_reg: tri_regk
generic map (width => 1, init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => ex3_stg_act_q,
            forcee => func_nsl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_nsl_thold_0_b,
            din(0)  => ex4_data_swap_val_d,
            dout(0) => ex4_data_swap_val_q);

ex4_algebraic_reg: tri_regk
generic map (width => 1, init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => ex3_stg_act_q,
            forcee => func_nsl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_nsl_thold_0_b,
            din(0)  => ex4_algebraic_d,
            dout(0) => ex4_algebraic_q);

ex4_lock_en_reg: tri_regk
generic map (width => 1, init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => ex3_stg_act_q,
            forcee => func_nsl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_nsl_thold_0_b,
            din(0)  => ex4_lock_en_d,
            dout(0) => ex4_lock_en_q);

eplc_wr_reg: tri_rlmreg_p
generic map (width => 4, init => 0, expand_type => expand_type, needs_sreset => 1)
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
            scin    => siv(eplc_wr_offset to eplc_wr_offset + eplc_wr_d'length-1),
            scout   => sov(eplc_wr_offset to eplc_wr_offset + eplc_wr_d'length-1),
            din     => eplc_wr_d,
            dout    => eplc_wr_q);

epsc_wr_reg: tri_rlmreg_p
generic map (width => 4, init => 0, expand_type => expand_type, needs_sreset => 1)
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
            scin    => siv(epsc_wr_offset to epsc_wr_offset + epsc_wr_d'length-1),
            scout   => sov(epsc_wr_offset to epsc_wr_offset + epsc_wr_d'length-1),
            din     => epsc_wr_d,
            dout    => epsc_wr_q);

eplc_t0_reg_a_reg: tri_ser_rlmreg_p
generic map (width => 2, init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => eplc_t0_wen,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(eplc_t0_reg_a_offset to eplc_t0_reg_a_offset + (eplc_t0_reg_d'length-23)-1),
            scout   => sov(eplc_t0_reg_a_offset to eplc_t0_reg_a_offset + (eplc_t0_reg_d'length-23)-1),
            din     => eplc_t0_reg_d(0 to 1),
            dout    => eplc_t0_reg_q(0 to 1));

eplc_t0_reg_b_reg: tri_ser_rlmreg_p
generic map (width => 9, init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => eplc_t0_hyp_wen,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(eplc_t0_reg_b_offset to eplc_t0_reg_b_offset + (eplc_t0_reg_d'length-16)-1),
            scout   => sov(eplc_t0_reg_b_offset to eplc_t0_reg_b_offset + (eplc_t0_reg_d'length-16)-1),
            din     => eplc_t0_reg_d(2 to 10),
            dout    => eplc_t0_reg_q(2 to 10));

eplc_t0_reg_c_reg: tri_ser_rlmreg_p
generic map (width => 14, init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => eplc_t0_wen,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(eplc_t0_reg_c_offset to eplc_t0_reg_c_offset + (eplc_t0_reg_d'length-11)-1),
            scout   => sov(eplc_t0_reg_c_offset to eplc_t0_reg_c_offset + (eplc_t0_reg_d'length-11)-1),
            din     => eplc_t0_reg_d(11 to 24),
            dout    => eplc_t0_reg_q(11 to 24));

eplc_t1_reg_a_reg: tri_ser_rlmreg_p
generic map (width => 2, init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => eplc_t1_wen,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(eplc_t1_reg_a_offset to eplc_t1_reg_a_offset + (eplc_t1_reg_d'length-23)-1),
            scout   => sov(eplc_t1_reg_a_offset to eplc_t1_reg_a_offset + (eplc_t1_reg_d'length-23)-1),
            din     => eplc_t1_reg_d(0 to 1),
            dout    => eplc_t1_reg_q(0 to 1));

eplc_t1_reg_b_reg: tri_ser_rlmreg_p
generic map (width => 9, init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => eplc_t1_hyp_wen,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(eplc_t1_reg_b_offset to eplc_t1_reg_b_offset + (eplc_t1_reg_d'length-16)-1),
            scout   => sov(eplc_t1_reg_b_offset to eplc_t1_reg_b_offset + (eplc_t1_reg_d'length-16)-1),
            din     => eplc_t1_reg_d(2 to 10),
            dout    => eplc_t1_reg_q(2 to 10));

eplc_t1_reg_c_reg: tri_ser_rlmreg_p
generic map (width => 14, init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => eplc_t1_wen,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(eplc_t1_reg_c_offset to eplc_t1_reg_c_offset + (eplc_t1_reg_d'length-11)-1),
            scout   => sov(eplc_t1_reg_c_offset to eplc_t1_reg_c_offset + (eplc_t1_reg_d'length-11)-1),
            din     => eplc_t1_reg_d(11 to 24),
            dout    => eplc_t1_reg_q(11 to 24));

eplc_t2_reg_a_reg: tri_ser_rlmreg_p
generic map (width => 2, init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => eplc_t2_wen,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(eplc_t2_reg_a_offset to eplc_t2_reg_a_offset + (eplc_t2_reg_d'length-23)-1),
            scout   => sov(eplc_t2_reg_a_offset to eplc_t2_reg_a_offset + (eplc_t2_reg_d'length-23)-1),
            din     => eplc_t2_reg_d(0 to 1),
            dout    => eplc_t2_reg_q(0 to 1));

eplc_t2_reg_b_reg: tri_ser_rlmreg_p
generic map (width => 9, init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => eplc_t2_hyp_wen,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(eplc_t2_reg_b_offset to eplc_t2_reg_b_offset + (eplc_t2_reg_d'length-16)-1),
            scout   => sov(eplc_t2_reg_b_offset to eplc_t2_reg_b_offset + (eplc_t2_reg_d'length-16)-1),
            din     => eplc_t2_reg_d(2 to 10),
            dout    => eplc_t2_reg_q(2 to 10));

eplc_t2_reg_c_reg: tri_ser_rlmreg_p
generic map (width => 14, init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => eplc_t2_wen,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(eplc_t2_reg_c_offset to eplc_t2_reg_c_offset + (eplc_t2_reg_d'length-11)-1),
            scout   => sov(eplc_t2_reg_c_offset to eplc_t2_reg_c_offset + (eplc_t2_reg_d'length-11)-1),
            din     => eplc_t2_reg_d(11 to 24),
            dout    => eplc_t2_reg_q(11 to 24));

eplc_t3_reg_a_reg: tri_ser_rlmreg_p
generic map (width => 2, init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => eplc_t3_wen,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(eplc_t3_reg_a_offset to eplc_t3_reg_a_offset + (eplc_t3_reg_d'length-23)-1),
            scout   => sov(eplc_t3_reg_a_offset to eplc_t3_reg_a_offset + (eplc_t3_reg_d'length-23)-1),
            din     => eplc_t3_reg_d(0 to 1),
            dout    => eplc_t3_reg_q(0 to 1));

eplc_t3_reg_b_reg: tri_ser_rlmreg_p
generic map (width => 9, init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => eplc_t3_hyp_wen,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(eplc_t3_reg_b_offset to eplc_t3_reg_b_offset + (eplc_t3_reg_d'length-16)-1),
            scout   => sov(eplc_t3_reg_b_offset to eplc_t3_reg_b_offset + (eplc_t3_reg_d'length-16)-1),
            din     => eplc_t3_reg_d(2 to 10),
            dout    => eplc_t3_reg_q(2 to 10));

eplc_t3_reg_c_reg: tri_ser_rlmreg_p
generic map (width => 14, init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => eplc_t3_wen,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(eplc_t3_reg_c_offset to eplc_t3_reg_c_offset + (eplc_t3_reg_d'length-11)-1),
            scout   => sov(eplc_t3_reg_c_offset to eplc_t3_reg_c_offset + (eplc_t3_reg_d'length-11)-1),
            din     => eplc_t3_reg_d(11 to 24),
            dout    => eplc_t3_reg_q(11 to 24));

epsc_t0_reg_a_reg: tri_ser_rlmreg_p
generic map (width => 2, init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => epsc_t0_wen,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(epsc_t0_reg_a_offset to epsc_t0_reg_a_offset + (epsc_t0_reg_d'length-23)-1),
            scout   => sov(epsc_t0_reg_a_offset to epsc_t0_reg_a_offset + (epsc_t0_reg_d'length-23)-1),
            din     => epsc_t0_reg_d(0 to 1),
            dout    => epsc_t0_reg_q(0 to 1));

epsc_t0_reg_b_reg: tri_ser_rlmreg_p
generic map (width => 9, init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => epsc_t0_hyp_wen,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(epsc_t0_reg_b_offset to epsc_t0_reg_b_offset + (epsc_t0_reg_d'length-16)-1),
            scout   => sov(epsc_t0_reg_b_offset to epsc_t0_reg_b_offset + (epsc_t0_reg_d'length-16)-1),
            din     => epsc_t0_reg_d(2 to 10),
            dout    => epsc_t0_reg_q(2 to 10));

epsc_t0_reg_c_reg: tri_ser_rlmreg_p
generic map (width => 14, init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => epsc_t0_wen,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(epsc_t0_reg_c_offset to epsc_t0_reg_c_offset + (epsc_t0_reg_d'length-11)-1),
            scout   => sov(epsc_t0_reg_c_offset to epsc_t0_reg_c_offset + (epsc_t0_reg_d'length-11)-1),
            din     => epsc_t0_reg_d(11 to 24),
            dout    => epsc_t0_reg_q(11 to 24));

epsc_t1_reg_a_reg: tri_ser_rlmreg_p
generic map (width => 2, init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => epsc_t1_wen,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(epsc_t1_reg_a_offset to epsc_t1_reg_a_offset + (epsc_t1_reg_d'length-23)-1),
            scout   => sov(epsc_t1_reg_a_offset to epsc_t1_reg_a_offset + (epsc_t1_reg_d'length-23)-1),
            din     => epsc_t1_reg_d(0 to 1),
            dout    => epsc_t1_reg_q(0 to 1));

epsc_t1_reg_b_reg: tri_ser_rlmreg_p
generic map (width => 9, init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => epsc_t1_hyp_wen,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(epsc_t1_reg_b_offset to epsc_t1_reg_b_offset + (epsc_t1_reg_d'length-16)-1),
            scout   => sov(epsc_t1_reg_b_offset to epsc_t1_reg_b_offset + (epsc_t1_reg_d'length-16)-1),
            din     => epsc_t1_reg_d(2 to 10),
            dout    => epsc_t1_reg_q(2 to 10));

epsc_t1_reg_c_reg: tri_ser_rlmreg_p
generic map (width => 14, init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => epsc_t1_wen,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(epsc_t1_reg_c_offset to epsc_t1_reg_c_offset + (epsc_t1_reg_d'length-11)-1),
            scout   => sov(epsc_t1_reg_c_offset to epsc_t1_reg_c_offset + (epsc_t1_reg_d'length-11)-1),
            din     => epsc_t1_reg_d(11 to 24),
            dout    => epsc_t1_reg_q(11 to 24));

epsc_t2_reg_a_reg: tri_ser_rlmreg_p
generic map (width => 2, init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => epsc_t2_wen,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(epsc_t2_reg_a_offset to epsc_t2_reg_a_offset + (epsc_t2_reg_d'length-23)-1),
            scout   => sov(epsc_t2_reg_a_offset to epsc_t2_reg_a_offset + (epsc_t2_reg_d'length-23)-1),
            din     => epsc_t2_reg_d(0 to 1),
            dout    => epsc_t2_reg_q(0 to 1));

epsc_t2_reg_b_reg: tri_ser_rlmreg_p
generic map (width => 9, init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => epsc_t2_hyp_wen,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(epsc_t2_reg_b_offset to epsc_t2_reg_b_offset + (epsc_t2_reg_d'length-16)-1),
            scout   => sov(epsc_t2_reg_b_offset to epsc_t2_reg_b_offset + (epsc_t2_reg_d'length-16)-1),
            din     => epsc_t2_reg_d(2 to 10),
            dout    => epsc_t2_reg_q(2 to 10));

epsc_t2_reg_c_reg: tri_ser_rlmreg_p
generic map (width => 14, init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => epsc_t2_wen,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(epsc_t2_reg_c_offset to epsc_t2_reg_c_offset + (epsc_t2_reg_d'length-11)-1),
            scout   => sov(epsc_t2_reg_c_offset to epsc_t2_reg_c_offset + (epsc_t2_reg_d'length-11)-1),
            din     => epsc_t2_reg_d(11 to 24),
            dout    => epsc_t2_reg_q(11 to 24));

epsc_t3_reg_a_reg: tri_ser_rlmreg_p
generic map (width => 2, init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => epsc_t3_wen,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(epsc_t3_reg_a_offset to epsc_t3_reg_a_offset + (epsc_t3_reg_d'length-23)-1),
            scout   => sov(epsc_t3_reg_a_offset to epsc_t3_reg_a_offset + (epsc_t3_reg_d'length-23)-1),
            din     => epsc_t3_reg_d(0 to 1),
            dout    => epsc_t3_reg_q(0 to 1));

epsc_t3_reg_b_reg: tri_ser_rlmreg_p
generic map (width => 9, init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => epsc_t3_hyp_wen,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(epsc_t3_reg_b_offset to epsc_t3_reg_b_offset + (epsc_t3_reg_d'length-16)-1),
            scout   => sov(epsc_t3_reg_b_offset to epsc_t3_reg_b_offset + (epsc_t3_reg_d'length-16)-1),
            din     => epsc_t3_reg_d(2 to 10),
            dout    => epsc_t3_reg_q(2 to 10));

epsc_t3_reg_c_reg: tri_ser_rlmreg_p
generic map (width => 14, init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => epsc_t3_wen,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(epsc_t3_reg_c_offset to epsc_t3_reg_c_offset + (epsc_t3_reg_d'length-11)-1),
            scout   => sov(epsc_t3_reg_c_offset to epsc_t3_reg_c_offset + (epsc_t3_reg_d'length-11)-1),
            din     => epsc_t3_reg_d(11 to 24),
            dout    => epsc_t3_reg_q(11 to 24));

ex2_undef_lockset_reg: tri_rlmlatch_p
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
            scin    => siv(ex2_undef_lockset_offset),
            scout   => sov(ex2_undef_lockset_offset),
            din     => ex2_undef_lockset_d,
            dout    => ex2_undef_lockset_q);

ex3_undef_lockset_reg: tri_rlmlatch_p
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
            scin    => siv(ex3_undef_lockset_offset),
            scout   => sov(ex3_undef_lockset_offset),
            din     => ex3_undef_lockset_d,
            dout    => ex3_undef_lockset_q);

ex4_unable_2lock_reg: tri_rlmlatch_p
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
            scin    => siv(ex4_unable_2lock_offset),
            scout   => sov(ex4_unable_2lock_offset),
            din     => ex4_unable_2lock_d,
            dout    => ex4_unable_2lock_q);

ex5_unable_2lock_reg: tri_rlmlatch_p
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
            scin    => siv(ex5_unable_2lock_offset),
            scout   => sov(ex5_unable_2lock_offset),
            din     => ex5_unable_2lock_d,
            dout    => ex5_unable_2lock_q);

ex3_ldstq_instr_reg: tri_rlmlatch_p
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
            scin    => siv(ex3_ldstq_instr_offset),
            scout   => sov(ex3_ldstq_instr_offset),
            din     => ex3_ldstq_instr_d,
            dout    => ex3_ldstq_instr_q);

ex4_store_instr_reg: tri_regk
generic map (width => 1, init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => ex3_stg_act_q,
            forcee => func_nsl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_nsl_thold_0_b,
            din(0)  => ex4_store_instr_d,
            dout(0) => ex4_store_instr_q);

ex5_store_instr_reg: tri_rlmlatch_p
generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => ex4_stg_act_q,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex5_store_instr_offset),
            scout   => sov(ex5_store_instr_offset),
            din     => ex5_store_instr_d,
            dout    => ex5_store_instr_q);

ex5_store_miss_reg: tri_rlmlatch_p
generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => ex4_stg_act_q,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex5_store_miss_offset),
            scout   => sov(ex5_store_miss_offset),
            din     => ex5_store_miss_d,
            dout    => ex5_store_miss_q);

ex4_perf_dcbt_reg: tri_regk
generic map (width => 1, init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => ex3_stg_act_q,
            forcee => func_nsl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_nsl_thold_0_b,
            din(0)  => ex4_perf_dcbt_d,
            dout(0) => ex4_perf_dcbt_q);

ex5_perf_dcbt_reg: tri_rlmlatch_p
generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => ex4_stg_act_q,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex5_perf_dcbt_offset),
            scout   => sov(ex5_perf_dcbt_offset),
            din     => ex5_perf_dcbt_d,
            dout    => ex5_perf_dcbt_q);

perf_lsu_events_reg: tri_rlmreg_p
generic map (width => 17, init => 0, expand_type => expand_type, needs_sreset => 1)
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
            scin    => siv(perf_lsu_events_offset to perf_lsu_events_offset + perf_lsu_events_d'length-1),
            scout   => sov(perf_lsu_events_offset to perf_lsu_events_offset + perf_lsu_events_d'length-1),
            din     => perf_lsu_events_d,
            dout    => perf_lsu_events_q);

clkg_ctl_override_reg: tri_rlmlatch_p
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
            scin    => siv(clkg_ctl_override_offset),
            scout   => sov(clkg_ctl_override_offset),
            din     => clkg_ctl_override_d,
            dout    => clkg_ctl_override_q);

spr_xucr0_wlck_reg: tri_rlmlatch_p
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
            scin    => siv(spr_xucr0_wlck_offset),
            scout   => sov(spr_xucr0_wlck_offset),
            din     => spr_xucr0_wlck_d,
            dout    => spr_xucr0_wlck_q);

spr_xucr0_wlck_cpy_reg: tri_rlmlatch_p
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
            scin    => siv(spr_xucr0_wlck_cpy_offset),
            scout   => sov(spr_xucr0_wlck_cpy_offset),
            din     => spr_xucr0_wlck_cpy_d,
            dout    => spr_xucr0_wlck_cpy_q);

spr_xucr0_flh2l2_reg: tri_rlmlatch_p
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
            scin    => siv(spr_xucr0_flh2l2_offset),
            scout   => sov(spr_xucr0_flh2l2_offset),
            din     => spr_xucr0_flh2l2_d,
            dout    => spr_xucr0_flh2l2_q);

ex3_spr_xucr0_flh2l2_reg: tri_rlmlatch_p
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
            scin    => siv(ex3_spr_xucr0_flh2l2_offset),
            scout   => sov(ex3_spr_xucr0_flh2l2_offset),
            din     => ex3_spr_xucr0_flh2l2_d,
            dout    => ex3_spr_xucr0_flh2l2_q);

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

spr_xucr0_cls_reg: tri_rlmlatch_p
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
            scin    => siv(spr_xucr0_cls_offset),
            scout   => sov(spr_xucr0_cls_offset),
            din     => spr_xucr0_cls_d,
            dout    => spr_xucr0_cls_q);

agen_xucr0_cls_dly_reg: tri_rlmlatch_p
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
            scin    => siv(agen_xucr0_cls_dly_offset),
            scout   => sov(agen_xucr0_cls_dly_offset),
            din     => agen_xucr0_cls_dly_d,
            dout    => agen_xucr0_cls_dly_q);

agen_xucr0_cls_reg: tri_rlmlatch_p
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
            scin    => siv(agen_xucr0_cls_offset),
            scout   => sov(agen_xucr0_cls_offset),
            din     => agen_xucr0_cls_d,
            dout    => agen_xucr0_cls_q);

mtspr_trace_en_reg: tri_rlmreg_p
generic map (width => 4, init => 0, expand_type => expand_type, needs_sreset => 1)
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
            scin    => siv(mtspr_trace_en_offset to mtspr_trace_en_offset + mtspr_trace_en_d'length-1),
            scout   => sov(mtspr_trace_en_offset to mtspr_trace_en_offset + mtspr_trace_en_d'length-1),
            din     => mtspr_trace_en_d,
            dout    => mtspr_trace_en_q);

ex3_local_dcbf_reg: tri_rlmlatch_p
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
            scin    => siv(ex3_local_dcbf_offset),
            scout   => sov(ex3_local_dcbf_offset),
            din     => ex3_local_dcbf_d,
            dout    => ex3_local_dcbf_q);

ex1_msgsnd_instr_reg: tri_rlmlatch_p
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
            scin    => siv(ex1_msgsnd_instr_offset),
            scout   => sov(ex1_msgsnd_instr_offset),
            din     => ex1_msgsnd_instr_d,
            dout    => ex1_msgsnd_instr_q);

ex2_msgsnd_instr_reg: tri_rlmlatch_p
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
            scin    => siv(ex2_msgsnd_instr_offset),
            scout   => sov(ex2_msgsnd_instr_offset),
            din     => ex2_msgsnd_instr_d,
            dout    => ex2_msgsnd_instr_q);

ex3_msgsnd_instr_reg: tri_rlmlatch_p
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
            scin    => siv(ex3_msgsnd_instr_offset),
            scout   => sov(ex3_msgsnd_instr_offset),
            din     => ex3_msgsnd_instr_d,
            dout    => ex3_msgsnd_instr_q);

ex1_dci_instr_reg: tri_rlmlatch_p
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
            scin    => siv(ex1_dci_instr_offset),
            scout   => sov(ex1_dci_instr_offset),
            din     => ex1_dci_instr_d,
            dout    => ex1_dci_instr_q);

ex2_dci_instr_reg: tri_rlmlatch_p
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
            scin    => siv(ex2_dci_instr_offset),
            scout   => sov(ex2_dci_instr_offset),
            din     => ex2_dci_instr_d,
            dout    => ex2_dci_instr_q);

ex3_dci_instr_reg: tri_rlmlatch_p
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
            scin    => siv(ex3_dci_instr_offset),
            scout   => sov(ex3_dci_instr_offset),
            din     => ex3_dci_instr_d,
            dout    => ex3_dci_instr_q);

ex1_ici_instr_reg: tri_rlmlatch_p
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
            scin    => siv(ex1_ici_instr_offset),
            scout   => sov(ex1_ici_instr_offset),
            din     => ex1_ici_instr_d,
            dout    => ex1_ici_instr_q);

ex2_ici_instr_reg: tri_rlmlatch_p
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
            scin    => siv(ex2_ici_instr_offset),
            scout   => sov(ex2_ici_instr_offset),
            din     => ex2_ici_instr_d,
            dout    => ex2_ici_instr_q);

ex3_ici_instr_reg: tri_rlmlatch_p
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
            scin    => siv(ex3_ici_instr_offset),
            scout   => sov(ex3_ici_instr_offset),
            din     => ex3_ici_instr_d,
            dout    => ex3_ici_instr_q);

ex3_load_type_reg: tri_rlmlatch_p
generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => ex2_stg_act_q,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex3_load_type_offset),
            scout   => sov(ex3_load_type_offset),
            din     => ex3_load_type_d,
            dout    => ex3_load_type_q);

ex4_load_type_reg: tri_regk
generic map (width => 1, init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => ex3_stg_act_q,
            forcee => func_nsl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_nsl_thold_0_b,
            din(0)  => ex4_load_type_d,
            dout(0) => ex4_load_type_q);

ex3_l2load_type_reg: tri_rlmlatch_p
generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => ex2_stg_act_q,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex3_l2load_type_offset),
            scout   => sov(ex3_l2load_type_offset),
            din     => ex3_l2load_type_d,
            dout    => ex3_l2load_type_q);

flh2l2_gate_reg: tri_rlmlatch_p
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
            scin    => siv(flh2l2_gate_offset),
            scout   => sov(flh2l2_gate_offset),
            din     => flh2l2_gate_d,
            dout    => flh2l2_gate_q);

rel_upd_dcarr_reg: tri_rlmlatch_p
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
            scin    => siv(rel_upd_dcarr_offset),
            scout   => sov(rel_upd_dcarr_offset),
            din     => rel_upd_dcarr_d,
            dout    => rel_upd_dcarr_q);

ex5_xu_wren_reg: tri_rlmlatch_p
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
            scin    => siv(ex5_xu_wren_offset),
            scout   => sov(ex5_xu_wren_offset),
            din     => ex5_xu_wren_d,
            dout    => ex5_xu_wren_q);

ex1_ldawx_instr_reg: tri_rlmlatch_p
generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => rf1_stg_act_q,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex1_ldawx_instr_offset),
            scout   => sov(ex1_ldawx_instr_offset),
            din     => ex1_ldawx_instr_d,
            dout    => ex1_ldawx_instr_q);

ex2_ldawx_instr_reg: tri_regk
generic map (width => 1, init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => ex1_stg_act_q,
            forcee => func_nsl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_nsl_thold_0_b,
            din(0)  => ex2_ldawx_instr_d,
            dout(0) => ex2_ldawx_instr_q);

ex3_watch_en_reg: tri_rlmlatch_p
generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => ex2_stg_act_q,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex3_watch_en_offset),
            scout   => sov(ex3_watch_en_offset),
            din     => ex3_watch_en_d,
            dout    => ex3_watch_en_q);

ex4_watch_en_reg: tri_regk
generic map (width => 1, init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => ex3_stg_act_q,
            forcee => func_nsl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_nsl_thold_0_b,
            din(0)  => ex4_watch_en_d,
            dout(0) => ex4_watch_en_q);

ex5_watch_en_reg: tri_rlmlatch_p
generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => ex4_stg_act_q,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex5_watch_en_offset),
            scout   => sov(ex5_watch_en_offset),
            din     => ex5_watch_en_d,
            dout    => ex5_watch_en_q);

ex1_wclr_instr_reg: tri_rlmlatch_p
generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => rf1_stg_act_q,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex1_wclr_instr_offset),
            scout   => sov(ex1_wclr_instr_offset),
            din     => ex1_wclr_instr_d,
            dout    => ex1_wclr_instr_q);

ex2_wclr_instr_reg: tri_regk
generic map (width => 1, init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => ex1_stg_act_q,
            forcee => func_nsl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_nsl_thold_0_b,
            din(0)  => ex2_wclr_instr_d,
            dout(0) => ex2_wclr_instr_q);

ex3_wclr_instr_reg: tri_rlmlatch_p
generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => ex2_stg_act_q,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex3_wclr_instr_offset),
            scout   => sov(ex3_wclr_instr_offset),
            din     => ex3_wclr_instr_d,
            dout    => ex3_wclr_instr_q);

ex4_wclr_instr_reg: tri_regk
generic map (width => 1, init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => ex3_stg_act_q,
            forcee => func_nsl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_nsl_thold_0_b,
            din(0)  => ex4_wclr_instr_d,
            dout(0) => ex4_wclr_instr_q);

ex5_wclr_instr_reg: tri_rlmlatch_p
generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => ex4_stg_act_q,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex5_wclr_instr_offset),
            scout   => sov(ex5_wclr_instr_offset),
            din     => ex5_wclr_instr_d,
            dout    => ex5_wclr_instr_q);

ex4_wclr_set_reg: tri_regk
generic map (width => 1, init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => ex3_stg_act_q,
            forcee => func_nsl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_nsl_thold_0_b,
            din(0)  => ex4_wclr_set_d,
            dout(0) => ex4_wclr_set_q);

ex5_wclr_set_reg: tri_rlmlatch_p
generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => ex4_stg_act_q,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex5_wclr_set_offset),
            scout   => sov(ex5_wclr_set_offset),
            din     => ex5_wclr_set_d,
            dout    => ex5_wclr_set_q);

ex1_wchk_instr_reg: tri_rlmlatch_p
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
            scin    => siv(ex1_wchk_instr_offset),
            scout   => sov(ex1_wchk_instr_offset),
            din     => ex1_wchk_instr_d,
            dout    => ex1_wchk_instr_q);

ex2_wchk_instr_reg: tri_regk
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
            din(0)  => ex2_wchk_instr_d,
            dout(0) => ex2_wchk_instr_q);

ex4_cacheable_linelock_reg: tri_rlmlatch_p
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
            scin    => siv(ex4_cacheable_linelock_offset),
            scout   => sov(ex4_cacheable_linelock_offset),
            din     => ex4_cacheable_linelock_d,
            dout    => ex4_cacheable_linelock_q);

ex1_icswx_instr_reg: tri_rlmlatch_p
generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => rf1_stg_act_q,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex1_icswx_instr_offset),
            scout   => sov(ex1_icswx_instr_offset),
            din     => ex1_icswx_instr_d,
            dout    => ex1_icswx_instr_q);

ex2_icswx_instr_reg: tri_regk
generic map (width => 1, init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => ex1_stg_act_q,
            forcee => func_nsl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_nsl_thold_0_b,
            din(0)  => ex2_icswx_instr_d,
            dout(0) => ex2_icswx_instr_q);

ex3_icswx_instr_reg: tri_rlmlatch_p
generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => ex2_stg_act_q,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex3_icswx_instr_offset),
            scout   => sov(ex3_icswx_instr_offset),
            din     => ex3_icswx_instr_d,
            dout    => ex3_icswx_instr_q);

ex1_icswx_dot_instr_reg: tri_rlmlatch_p
generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => rf1_stg_act_q,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex1_icswx_dot_instr_offset),
            scout   => sov(ex1_icswx_dot_instr_offset),
            din     => ex1_icswx_dot_instr_d,
            dout    => ex1_icswx_dot_instr_q);

ex2_icswx_dot_instr_reg: tri_regk
generic map (width => 1, init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => ex1_stg_act_q,
            forcee => func_nsl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_nsl_thold_0_b,
            din(0)  => ex2_icswx_dot_instr_d,
            dout(0) => ex2_icswx_dot_instr_q);

ex3_icswx_dot_instr_reg: tri_rlmlatch_p
generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => ex2_stg_act_q,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex3_icswx_dot_instr_offset),
            scout   => sov(ex3_icswx_dot_instr_offset),
            din     => ex3_icswx_dot_instr_d,
            dout    => ex3_icswx_dot_instr_q);

ex1_icswx_epid_reg: tri_rlmlatch_p
generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => rf1_stg_act_q,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex1_icswx_epid_offset),
            scout   => sov(ex1_icswx_epid_offset),
            din     => ex1_icswx_epid_d,
            dout    => ex1_icswx_epid_q);

ex2_icswx_epid_reg: tri_regk
generic map (width => 1, init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => ex1_stg_act_q,
            forcee => func_nsl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_nsl_thold_0_b,
            din(0)  => ex2_icswx_epid_d,
            dout(0) => ex2_icswx_epid_q);

ex3_icswx_epid_reg: tri_rlmlatch_p
generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => ex2_stg_act_q,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex3_icswx_epid_offset),
            scout   => sov(ex3_icswx_epid_offset),
            din     => ex3_icswx_epid_d,
            dout    => ex3_icswx_epid_q);

ex3_c_inh_drop_op_reg: tri_rlmlatch_p
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
            scin    => siv(ex3_c_inh_drop_op_offset),
            scout   => sov(ex3_c_inh_drop_op_offset),
            din     => ex3_c_inh_drop_op_d,
            dout    => ex3_c_inh_drop_op_q);

axu_rel_wren_reg: tri_rlmlatch_p
generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => ldq_rel_stg24_val,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(axu_rel_wren_offset),
            scout   => sov(axu_rel_wren_offset),
            din     => axu_rel_wren_d,
            dout    => axu_rel_wren_q);

axu_rel_wren_stg1_reg: tri_rlmlatch_p
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
            scin    => siv(axu_rel_wren_stg1_offset),
            scout   => sov(axu_rel_wren_stg1_offset),
            din     => axu_rel_wren_stg1_d,
            dout    => axu_rel_wren_stg1_q);

rel_axu_tid_reg: tri_rlmreg_p
generic map (width => 4, init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => ldq_rel_stg24_val,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(rel_axu_tid_offset to  rel_axu_tid_offset + rel_axu_tid_d'length-1),
            scout   => sov(rel_axu_tid_offset to  rel_axu_tid_offset + rel_axu_tid_d'length-1),
            din     => rel_axu_tid_d,
            dout    => rel_axu_tid_q);

rel_axu_tid_stg1_reg: tri_rlmreg_p
generic map (width => 4, init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => rel3_stg_act_q,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(rel_axu_tid_stg1_offset to  rel_axu_tid_stg1_offset + rel_axu_tid_stg1_d'length-1),
            scout   => sov(rel_axu_tid_stg1_offset to  rel_axu_tid_stg1_offset + rel_axu_tid_stg1_d'length-1),
            din     => rel_axu_tid_stg1_d,
            dout    => rel_axu_tid_stg1_q);

rel_axu_ta_gpr_reg: tri_rlmreg_p
generic map (width => 9, init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => ldq_rel_stg24_val,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(rel_axu_ta_gpr_offset to  rel_axu_ta_gpr_offset + rel_axu_ta_gpr_d'length-1),
            scout   => sov(rel_axu_ta_gpr_offset to  rel_axu_ta_gpr_offset + rel_axu_ta_gpr_d'length-1),
            din     => rel_axu_ta_gpr_d,
            dout    => rel_axu_ta_gpr_q);

rel_axu_ta_gpr_stg1_reg: tri_rlmreg_p
generic map (width => 9, init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => rel3_stg_act_q,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(rel_axu_ta_gpr_stg1_offset to  rel_axu_ta_gpr_stg1_offset + rel_axu_ta_gpr_stg1_d'length-1),
            scout   => sov(rel_axu_ta_gpr_stg1_offset to  rel_axu_ta_gpr_stg1_offset + rel_axu_ta_gpr_stg1_d'length-1),
            din     => rel_axu_ta_gpr_stg1_d,
            dout    => rel_axu_ta_gpr_stg1_q);

rf0_l2_inv_val_reg: tri_rlmlatch_p
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
            scin    => siv(rf0_l2_inv_val_offset),
            scout   => sov(rf0_l2_inv_val_offset),
            din     => rf0_l2_inv_val_d,
            dout    => rf0_l2_inv_val_q);

rf1_l2_inv_val_reg: tri_rlmlatch_p
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
            scin    => siv(rf1_l2_inv_val_offset),
            scout   => sov(rf1_l2_inv_val_offset),
            din     => rf1_l2_inv_val_d,
            dout    => rf1_l2_inv_val_q);

ex1_agen_binv_val_reg: tri_rlmlatch_p
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
            scin    => siv(ex1_agen_binv_val_offset),
            scout   => sov(ex1_agen_binv_val_offset),
            din     => ex1_agen_binv_val_d,
            dout    => ex1_agen_binv_val_q);

ex1_l2_inv_val_reg: tri_rlmlatch_p
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
            scin    => siv(ex1_l2_inv_val_offset),
            scout   => sov(ex1_l2_inv_val_offset),
            din     => ex1_l2_inv_val_d,
            dout    => ex1_l2_inv_val_q);

lsu_msr_gs_reg: tri_rlmreg_p
generic map (width => 4, init => 0, expand_type => expand_type, needs_sreset => 1)
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
            scin    => siv(lsu_msr_gs_offset to  lsu_msr_gs_offset + lsu_msr_gs_d'length-1),
            scout   => sov(lsu_msr_gs_offset to  lsu_msr_gs_offset + lsu_msr_gs_d'length-1),
            din     => lsu_msr_gs_d,
            dout    => lsu_msr_gs_q);

lsu_msr_pr_reg: tri_rlmreg_p
generic map (width => 4, init => 0, expand_type => expand_type, needs_sreset => 1)
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
            scin    => siv(lsu_msr_pr_offset to  lsu_msr_pr_offset + lsu_msr_pr_d'length-1),
            scout   => sov(lsu_msr_pr_offset to  lsu_msr_pr_offset + lsu_msr_pr_d'length-1),
            din     => lsu_msr_pr_d,
            dout    => lsu_msr_pr_q);

lsu_msr_cm_reg: tri_rlmreg_p
generic map (width => 4, init => 0, expand_type => expand_type, needs_sreset => 1)
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
            scin    => siv(lsu_msr_cm_offset to  lsu_msr_cm_offset + lsu_msr_cm_d'length-1),
            scout   => sov(lsu_msr_cm_offset to  lsu_msr_cm_offset + lsu_msr_cm_d'length-1),
            din     => lsu_msr_cm_d,
            dout    => lsu_msr_cm_q);

ex1_lsu_64bit_agen_reg: tri_rlmlatch_p
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
            scin    => siv(ex1_lsu_64bit_agen_offset),
            scout   => sov(ex1_lsu_64bit_agen_offset),
            din     => ex1_lsu_64bit_agen_d,
            dout    => ex1_lsu_64bit_agen_q);

ex6_icbi_val_reg: tri_rlmreg_p
generic map (width => 4, init => 0, expand_type => expand_type, needs_sreset => 1)
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
            scin    => siv(ex6_icbi_val_offset to ex6_icbi_val_offset + ex6_icbi_val_d'length-1),
            scout   => sov(ex6_icbi_val_offset to ex6_icbi_val_offset + ex6_icbi_val_d'length-1),
            din     => ex6_icbi_val_d,
            dout    => ex6_icbi_val_q);

ex1_mtspr_trace_reg: tri_rlmlatch_p
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
            scin    => siv(ex1_mtspr_trace_offset),
            scout   => sov(ex1_mtspr_trace_offset),
            din     => ex1_mtspr_trace_d,
            dout    => ex1_mtspr_trace_q);

ex2_mtspr_trace_reg: tri_rlmlatch_p
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
            scin    => siv(ex2_mtspr_trace_offset),
            scout   => sov(ex2_mtspr_trace_offset),
            din     => ex2_mtspr_trace_d,
            dout    => ex2_mtspr_trace_q);

ex3_mtspr_trace_reg: tri_rlmlatch_p
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
            scin    => siv(ex3_mtspr_trace_offset),
            scout   => sov(ex3_mtspr_trace_offset),
            din     => ex3_mtspr_trace_d,
            dout    => ex3_mtspr_trace_q);

ex3_byte_en_reg: tri_rlmreg_p
generic map (width => 32, init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => ex2_stg_act_q,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex3_byte_en_offset to  ex3_byte_en_offset + ex3_byte_en_d'length-1),
            scout   => sov(ex3_byte_en_offset to  ex3_byte_en_offset + ex3_byte_en_d'length-1),
            din     => ex3_byte_en_d,
            dout    => ex3_byte_en_q);

ex3_rot_sel_le_reg: tri_rlmreg_p
generic map (width => 5, init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => ex2_stg_act_q,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex3_rot_sel_le_offset to  ex3_rot_sel_le_offset + ex3_rot_sel_le_d'length-1),
            scout   => sov(ex3_rot_sel_le_offset to  ex3_rot_sel_le_offset + ex3_rot_sel_le_d'length-1),
            din     => ex3_rot_sel_le_d,
            dout    => ex3_rot_sel_le_q);

ex3_rot_sel_be_reg: tri_rlmreg_p
generic map (width => 5, init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => ex2_stg_act_q,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex3_rot_sel_be_offset to  ex3_rot_sel_be_offset + ex3_rot_sel_be_d'length-1),
            scout   => sov(ex3_rot_sel_be_offset to  ex3_rot_sel_be_offset + ex3_rot_sel_be_d'length-1),
            din     => ex3_rot_sel_be_d,
            dout    => ex3_rot_sel_be_q);

dir_arr_rd_val_reg: tri_rlmlatch_p
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
            scin    => siv(dir_arr_rd_val_offset),
            scout   => sov(dir_arr_rd_val_offset),
            din     => dir_arr_rd_val_d,
            dout    => dir_arr_rd_val_q);

dir_arr_rd_is0_val_reg: tri_rlmlatch_p
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
            scin    => siv(dir_arr_rd_is0_val_offset),
            scout   => sov(dir_arr_rd_is0_val_offset),
            din     => dir_arr_rd_is0_val_d,
            dout    => dir_arr_rd_is0_val_q);

dir_arr_rd_is1_val_reg: tri_rlmlatch_p
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
            scin    => siv(dir_arr_rd_is1_val_offset),
            scout   => sov(dir_arr_rd_is1_val_offset),
            din     => dir_arr_rd_is1_val_d,
            dout    => dir_arr_rd_is1_val_q);

dir_arr_rd_is2_val_reg: tri_rlmlatch_p
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
            scin    => siv(dir_arr_rd_is2_val_offset),
            scout   => sov(dir_arr_rd_is2_val_offset),
            din     => dir_arr_rd_is2_val_d,
            dout    => dir_arr_rd_is2_val_q);

dir_arr_rd_rf0_val_reg: tri_rlmlatch_p
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
            scin    => siv(dir_arr_rd_rf0_val_offset),
            scout   => sov(dir_arr_rd_rf0_val_offset),
            din     => dir_arr_rd_rf0_val_d,
            dout    => dir_arr_rd_rf0_val_q);

dir_arr_rd_rf1_val_reg: tri_rlmlatch_p
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
            scin    => siv(dir_arr_rd_rf1_val_offset),
            scout   => sov(dir_arr_rd_rf1_val_offset),
            din     => dir_arr_rd_rf1_val_d,
            dout    => dir_arr_rd_rf1_val_q);

dir_arr_rd_rf0_done_reg: tri_rlmlatch_p
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
            scin    => siv(dir_arr_rd_rf0_done_offset),
            scout   => sov(dir_arr_rd_rf0_done_offset),
            din     => dir_arr_rd_rf0_done_d,
            dout    => dir_arr_rd_rf0_done_q);

dir_arr_rd_rf1_done_reg: tri_rlmlatch_p
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
            scin    => siv(dir_arr_rd_rf1_done_offset),
            scout   => sov(dir_arr_rd_rf1_done_offset),
            din     => dir_arr_rd_rf1_done_d,
            dout    => dir_arr_rd_rf1_done_q);

dir_arr_rd_ex1_done_reg: tri_rlmlatch_p
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
            scin    => siv(dir_arr_rd_ex1_done_offset),
            scout   => sov(dir_arr_rd_ex1_done_offset),
            din     => dir_arr_rd_ex1_done_d,
            dout    => dir_arr_rd_ex1_done_q);

dir_arr_rd_ex2_done_reg: tri_rlmlatch_p
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
            scin    => siv(dir_arr_rd_ex2_done_offset),
            scout   => sov(dir_arr_rd_ex2_done_offset),
            din     => dir_arr_rd_ex2_done_d,
            dout    => dir_arr_rd_ex2_done_q);

dir_arr_rd_ex3_done_reg: tri_rlmlatch_p
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
            scin    => siv(dir_arr_rd_ex3_done_offset),
            scout   => sov(dir_arr_rd_ex3_done_offset),
            din     => dir_arr_rd_ex3_done_d,
            dout    => dir_arr_rd_ex3_done_q);

dir_arr_rd_ex4_done_reg: tri_rlmlatch_p
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
            scin    => siv(dir_arr_rd_ex4_done_offset),
            scout   => sov(dir_arr_rd_ex4_done_offset),
            din     => dir_arr_rd_ex4_done_d,
            dout    => dir_arr_rd_ex4_done_q);

my_spare0_lcb : entity tri.tri_lcbnd(tri_lcbnd)
generic map (expand_type => expand_type)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => tiup,
            forcee => func_slp_sl_force,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_slp_sl_thold_0_b,
            sg      => sg_0,
            d1clk   => my_spare0_d1clk,
            d2clk   => my_spare0_d2clk,
            lclk    => my_spare0_lclk);
my_spare0_latches_reg: entity tri.tri_inv_nlats(tri_inv_nlats)
generic map (width => 3, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            lclk    => my_spare0_lclk,
            d1clk   => my_spare0_d1clk,
            d2clk   => my_spare0_d2clk,
            scanin  => siv(my_spare0_latches_offset to  my_spare0_latches_offset + my_spare0_latches_d'length-1),
            scanout => sov(my_spare0_latches_offset to  my_spare0_latches_offset + my_spare0_latches_d'length-1),
            d       => my_spare0_latches_d,
            qb      => my_spare0_latches_q);

my_spare1_lcb : entity tri.tri_lcbnd(tri_lcbnd)
generic map (expand_type => expand_type)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => tiup,
            forcee => func_slp_sl_force,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_slp_sl_thold_0_b,
            sg      => sg_0,
            d1clk   => my_spare1_d1clk,
            d2clk   => my_spare1_d2clk,
            lclk    => my_spare1_lclk);
my_spare1_latches_reg: entity tri.tri_inv_nlats(tri_inv_nlats)
generic map (width => 20, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            lclk    => my_spare1_lclk,
            d1clk   => my_spare1_d1clk,
            d2clk   => my_spare1_d2clk,
            scanin  => siv(my_spare1_latches_offset to  my_spare1_latches_offset + my_spare1_latches_d'length-1),
            scanout => sov(my_spare1_latches_offset to  my_spare1_latches_offset + my_spare1_latches_d'length-1),
            d       => my_spare1_latches_d,
            qb      => my_spare1_latches_q);

rf1_stg_act_reg: tri_rlmlatch_p
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
            scin    => siv(rf1_stg_act_offset),
            scout   => sov(rf1_stg_act_offset),
            din     => rf1_stg_act_d,
            dout    => rf1_stg_act_q);

ex1_stg_act_reg: tri_rlmlatch_p
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
            scin    => siv(ex1_stg_act_offset),
            scout   => sov(ex1_stg_act_offset),
            din     => ex1_stg_act_d,
            dout    => ex1_stg_act_q);

ex2_stg_act_reg: tri_regk
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
            din(0)  => ex2_stg_act_d,
            dout(0) => ex2_stg_act_q);

ex3_stg_act_reg: tri_rlmlatch_p
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
            scin    => siv(ex3_stg_act_offset),
            scout   => sov(ex3_stg_act_offset),
            din     => ex3_stg_act_d,
            dout    => ex3_stg_act_q);

ex4_stg_act_reg: tri_regk
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
            din(0)  => ex4_stg_act_d,
            dout(0) => ex4_stg_act_q);

ex5_stg_act_reg: tri_rlmlatch_p
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
            scin    => siv(ex5_stg_act_offset),
            scout   => sov(ex5_stg_act_offset),
            din     => ex5_stg_act_d,
            dout    => ex5_stg_act_q);

binv1_stg_act_reg: tri_rlmlatch_p
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
            scin    => siv(binv1_stg_act_offset),
            scout   => sov(binv1_stg_act_offset),
            din     => binv1_stg_act_d,
            dout    => binv1_stg_act_q);

binv2_stg_act_reg: tri_regk
generic map (width => 1, init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => tiup,
            forcee => func_slp_nsl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_slp_nsl_thold_0_b,
            din(0)  => binv2_stg_act_d,
            dout(0) => binv2_stg_act_q);

binv3_stg_act_reg: tri_rlmlatch_p
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
            scin    => siv(binv3_stg_act_offset),
            scout   => sov(binv3_stg_act_offset),
            din     => binv3_stg_act_d,
            dout    => binv3_stg_act_q);

binv4_stg_act_reg: tri_regk
generic map (width => 1, init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => tiup,
            forcee => func_slp_nsl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_slp_nsl_thold_0_b,
            din(0)  => binv4_stg_act_d,
            dout(0) => binv4_stg_act_q);

binv5_stg_act_reg: tri_rlmlatch_p
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
            scin    => siv(binv5_stg_act_offset),
            scout   => sov(binv5_stg_act_offset),
            din     => binv5_stg_act_d,
            dout    => binv5_stg_act_q);

rel1_stg_act_reg: tri_rlmlatch_p
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
            scin    => siv(rel1_stg_act_offset),
            scout   => sov(rel1_stg_act_offset),
            din     => rel1_stg_act_d,
            dout    => rel1_stg_act_q);

rel3_stg_act_reg: tri_rlmlatch_p
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
            scin    => siv(rel3_stg_act_offset),
            scout   => sov(rel3_stg_act_offset),
            din     => rel3_stg_act_d,
            dout    => rel3_stg_act_q);

rel4_stg_act_reg: tri_regk
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
            din(0)  => rel4_stg_act_d,
            dout(0) => rel4_stg_act_q);

siv(0 to scan_right) <= sov(1 to scan_right) & scan_in;
scan_out <= sov(0);


end xuq_lsu_dc_cntrl;
