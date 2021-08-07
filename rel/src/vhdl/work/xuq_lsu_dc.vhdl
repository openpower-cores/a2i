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

--  Description:  XU LSU L1 Data Cache
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
-- 1) Staging Latches
-- 2) Exception Handling
-- 3) Flush Generation
-- ##########################################################################################

entity xuq_lsu_dc is
generic(expand_type     : integer := 2;		-- 0 = ibm (Umbra), 1 = non-ibm, 2 = ibm (MPG)
        l_endian_m      : integer := 1;         -- 1 = little endian mode enabled, 0 = little endian mode disabled
        regmode         : integer := 6;         -- Register Mode 5 = 32bit, 6 = 64bit
        dc_size         : natural := 14;        -- 2^14 = 16384 Bytes L1 D$
        parBits         : natural := 4;         -- Number of Parity Bits
	real_data_add	: integer := 42);	-- 42 bit real address
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

     -- Physical Address in EX2
     ex2_p_addr_lwr             :in  std_ulogic_vector(52 to 63);
     ex2_lm_dep_hit             :in  std_ulogic;                        -- Sources for Op match target in loadmiss queue

     ex3_wimge_w_bit            :in  std_ulogic;                        -- WIMGE bits in EX3
     ex3_wimge_i_bit            :in  std_ulogic;                        -- WIMGE bits in EX3
     ex3_wimge_e_bit            :in  std_ulogic;                        -- WIMGE bits in EX3
     ex3_p_addr                 :in  std_ulogic_vector(64-real_data_add to 51);
     ex3_ld_queue_full          :in  std_ulogic;                        -- LSQ load queue full
     ex3_stq_flush              :in  std_ulogic;                        -- LSQ store queue full
     ex3_ig_flush               :in  std_ulogic;                        -- LSQ I=G=1 flush
     ex3_hit                    :in  std_ulogic;                        -- EX3 Load/Store Hit
     ex4_miss                   :in  std_ulogic;                        -- EX4 Load/Store Miss
     ex4_snd_ld_l2              :in  std_ulogic;                        -- Request is being sent to the L2
     derat_xu_ex3_noop_touch    :in  std_ulogic_vector(0 to 3);
     ex3_cClass_collision       :in  std_ulogic;                        -- Thread Collision with same Congruence Class and Way
     ex2_lockwatchSet_rel_coll  :in  std_ulogic;                        -- DCBT[ST]LS or WatchSet instruction collided with Reload Clear Stage
     ex3_wclr_all_flush         :in  std_ulogic;                        -- Watch clear all in pipe flushing other threads in pipe
     rel_dcarr_val_upd          :in  std_ulogic;                        -- Reload Data Array Update Valid

     -- Data Cache Config Bits
     xu_lsu_mtspr_trace_en      :in  std_ulogic_vector(0 to 3);
     spr_xucr0_clkg_ctl_b1      :in  std_ulogic;                        -- Override Clock Gating
     xu_lsu_spr_xucr0_aflsta    :in  std_ulogic;                        -- Force load/store Alignment Exception (AXU)
     xu_lsu_spr_xucr0_flsta     :in  std_ulogic;                        -- Force load/store Alignment Exception (XU)
     xu_lsu_spr_xucr0_l2siw     :in  std_ulogic;                        -- L2 store interface width
     xu_lsu_spr_xucr0_dcdis     :in  std_ulogic;                        -- Data Cache Disable
     xu_lsu_spr_xucr0_wlk       :in  std_ulogic;                        -- Data Cache Way Locking Enable
     xu_lsu_spr_ccr2_dfrat      :in  std_ulogic;                        -- Force Real Address Translation
     xu_lsu_spr_xucr0_flh2l2    :in  std_ulogic;                        -- Force L1 load hits to L2
     xu_lsu_spr_xucr0_cls       :in  std_ulogic;                        -- Cacheline Size = 1 => 128Byte size, 0 => 64Byte size
     xu_lsu_spr_msr_cm          :in  std_ulogic_vector(0 to 3);         -- 64bit mode enable

     -- MSR[GS,PR] bits, indicates which state we are running in
     xu_lsu_msr_gs              :in  std_ulogic_vector(0 to 3);         -- Guest State
     xu_lsu_msr_pr              :in  std_ulogic_vector(0 to 3);         -- Problem State

     an_ac_flh2l2_gate          :in  std_ulogic;                        -- Gate L1 Hit forwarding SPR config bit

     -- Stage Flush from Instruction Flush Unit
     xu_lsu_rf1_flush           :in  std_ulogic_vector(0 to 3);
     xu_lsu_ex1_flush           :in  std_ulogic_vector(0 to 3);
     xu_lsu_ex2_flush           :in  std_ulogic_vector(0 to 3);
     xu_lsu_ex3_flush           :in  std_ulogic_vector(0 to 3);
     xu_lsu_ex4_flush           :in  std_ulogic_vector(0 to 3);
     xu_lsu_ex5_flush           :in  std_ulogic_vector(0 to 3);

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

     -- L2 Operation Flush
     ldq_rel_data_val_early     :in  std_ulogic;                        -- Reload Interface ACT
     ldq_rel_stg24_val          :in  std_ulogic;                        -- Reload Stages 2 and 4 are valid
     ldq_rel_axu_val            :in  std_ulogic;                        -- Reload is for a Vector Register
     ldq_rel_thrd_id            :in  std_ulogic_vector(0 to 3);         -- Thread ID of the reload
     ldq_rel_ta_gpr             :in  std_ulogic_vector(0 to 8);
     ldq_rel_upd_gpr            :in  std_ulogic;                        -- Reload data should be written to GPR (DCB ops don't write to GPRs)
     ldq_rel_ci                 :in  std_ulogic;                        -- Cache-Inhibited Reload is Valid
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
     ex1_dir_acc_val            :out std_ulogic;
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
     ex2_no_lru_upd             :out std_ulogic;
     ex2_is_inval_op            :out std_ulogic;
     ex2_lock_set               :out std_ulogic;
     ex2_lock_clr               :out std_ulogic;
     ex2_ddir_acc_instr         :out std_ulogic;

     ex3_p_addr_lwr             :out std_ulogic_vector(58 to 63);
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
     ex2_l_fld                  :out std_ulogic_vector(0 to 1);
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
     ex2_store_instr            :out std_ulogic;
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
     ex1_thrd_id                :out std_ulogic_vector(0 to 3);
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

     -- Physical Address in EX3
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

     -- Interrupt Generation
     lsu_xu_ex3_align           :out std_ulogic_vector(0 to 3);         
     lsu_xu_ex3_dsi             :out std_ulogic_vector(0 to 3);         
     lsu_xu_ex3_inval_align_2ucode :out std_ulogic;                        

     -- Flush Pipe Outputs
     ex2_stg_flush              :out std_ulogic;                        -- Flush Instructions in EX2
     ex3_stg_flush              :out std_ulogic;                        -- Flush Instructions in EX3
     ex4_stg_flush              :out std_ulogic;                        -- Flush Instructions in EX4
     ex5_stg_flush              :out std_ulogic;                        -- Flush Instructions in EX5
     lsu_xu_ex3_n_flush_req     :out std_ulogic;                        -- Data Cache Instruction Flush in EX3
     lsu_xu_ex3_dep_flush       :out std_ulogic;                        -- RAW/WAW Dependency Flush

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

     lsu_xu_perf_events         :out std_ulogic_vector(0 to 20);
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
     dc_fgen_dbg_data           :out std_ulogic_vector(0 to 1);
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
end xuq_lsu_dc;
----
architecture xuq_lsu_dc of xuq_lsu_dc is

----------------------------
-- components
----------------------------

----------------------------
-- constants
----------------------------
constant dccntrl_offset         :natural := 0;
constant dcfgen_offset          :natural := dccntrl_offset + 1;
constant scan_right             :natural := dcfgen_offset + 1 - 1;

----------------------------
-- signals
----------------------------
signal stg_flush_rf1            :std_ulogic;
signal stg_flush_ex1            :std_ulogic;
signal stg_flush_ex2            :std_ulogic;
signal stg_flush_ex3            :std_ulogic;
signal stg_flush_ex4            :std_ulogic;
signal stg_flush_ex5            :std_ulogic;
signal ex1_thrd_id_int          :std_ulogic_vector(0 to 3);
signal ex2_thrd_id              :std_ulogic_vector(0 to 3);
signal ex3_thrd_id              :std_ulogic_vector(0 to 3);
signal ex4_thrd_id              :std_ulogic_vector(0 to 3);
signal ex5_thrd_id              :std_ulogic_vector(0 to 3);
signal ex2_cache_acc            :std_ulogic;
signal ex2_icswx_type           :std_ulogic; 
signal ex2_store_instr_int      :std_ulogic;
signal ex2_load_instr           :std_ulogic;
signal ex2_dcbz_instr           :std_ulogic;
signal ex2_lock_instr           :std_ulogic;
signal ex2_ldawx_instr_int      :std_ulogic;
signal ex3_targ_match_b1        :std_ulogic;
signal ex2_targ_match_b2        :std_ulogic;
signal ex2_mv_reg_op            :std_ulogic;
signal ex2_axu_op               :std_ulogic;
signal ex3_excp_det             :std_ulogic;
signal ex2_optype2              :std_ulogic;
signal ex2_optype4              :std_ulogic;
signal ex2_optype8              :std_ulogic;
signal ex2_optype16             :std_ulogic;
signal ex2_optype32             :std_ulogic;
signal ex2_ldst_fexcpt          :std_ulogic;
signal ex3_lsq_flush            :std_ulogic;

signal siv                      :std_ulogic_vector(0 to scan_right);
signal sov                      :std_ulogic_vector(0 to scan_right);

begin

-- XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
-- Inputs
-- XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

-- XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
-- Data Cache Staging Latches and Control
-- XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
l1dccntrl : entity work.xuq_lsu_dc_cntrl(xuq_lsu_dc_cntrl)
generic map(expand_type         => expand_type,
            regmode             => regmode,
            dc_size             => dc_size,
            parBits             => parBits,
            real_data_add	=> real_data_add)
port map(

     -- Execution Pipe Inputs
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

     -- Dependency Checking on loadmisses
     xu_lsu_rf1_src0_vld        => xu_lsu_rf1_src0_vld,
     xu_lsu_rf1_src0_reg        => xu_lsu_rf1_src0_reg,
     xu_lsu_rf1_src1_vld        => xu_lsu_rf1_src1_vld,
     xu_lsu_rf1_src1_reg        => xu_lsu_rf1_src1_reg,
     xu_lsu_rf1_targ_vld        => xu_lsu_rf1_targ_vld,
     xu_lsu_rf1_targ_reg        => xu_lsu_rf1_targ_reg,

     -- Back-Invalidate
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

     ex2_p_addr_lwr             => ex2_p_addr_lwr,
     ex3_wimge_i_bit            => ex3_wimge_i_bit,
     ex3_wimge_e_bit            => ex3_wimge_e_bit,

     ex3_p_addr                 => ex3_p_addr,
     ex3_ld_queue_full          => ex3_ld_queue_full,
     ex3_stq_flush              => ex3_stq_flush,
     ex3_ig_flush               => ex3_ig_flush,
     ex3_hit                    => ex3_hit,
     ex4_miss                   => ex4_miss,
     ex4_snd_ld_l2              => ex4_snd_ld_l2,
     ex3_excp_det               => ex3_excp_det,

     -- Stage Flush
     rf1_stg_flush              => stg_flush_rf1,
     ex1_stg_flush              => stg_flush_ex1,
     ex2_stg_flush              => stg_flush_ex2,
     ex3_stg_flush              => stg_flush_ex3,
     ex4_stg_flush              => stg_flush_ex4,
     ex5_stg_flush              => stg_flush_ex5,

     -- Data Cache Config
     xu_lsu_mtspr_trace_en      => xu_lsu_mtspr_trace_en,
     spr_xucr0_clkg_ctl_b1      => spr_xucr0_clkg_ctl_b1,
     xu_lsu_spr_xucr0_wlk       => xu_lsu_spr_xucr0_wlk,
     xu_lsu_spr_ccr2_dfrat      => xu_lsu_spr_ccr2_dfrat,
     xu_lsu_spr_xucr0_dcdis     => xu_lsu_spr_xucr0_dcdis,
     xu_lsu_spr_xucr0_flh2l2    => xu_lsu_spr_xucr0_flh2l2,
     xu_lsu_spr_xucr0_cls       => xu_lsu_spr_xucr0_cls,
     xu_lsu_spr_msr_cm          => xu_lsu_spr_msr_cm,

     xu_lsu_msr_gs              => xu_lsu_msr_gs,
     xu_lsu_msr_pr              => xu_lsu_msr_pr,

     an_ac_flh2l2_gate          => an_ac_flh2l2_gate,

     -- Slow SPR Bus
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
     ldq_rel_stg24_val          => ldq_rel_stg24_val,
     ldq_rel_axu_val            => ldq_rel_axu_val,
     ldq_rel_thrd_id            => ldq_rel_thrd_id,
     ldq_rel_ta_gpr             => ldq_rel_ta_gpr,
     ldq_rel_upd_gpr            => ldq_rel_upd_gpr,

     -- Dependency Checking on loadmisses
     ex1_src0_vld               => ex1_src0_vld,
     ex1_src0_reg               => ex1_src0_reg,
     ex1_src1_vld               => ex1_src1_vld,
     ex1_src1_reg               => ex1_src1_reg,
     ex1_targ_vld               => ex1_targ_vld,
     ex1_targ_reg               => ex1_targ_reg,
     ex1_check_watch            => ex1_check_watch,

     -- Execution Pipe Outputs
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
     ex2_optype2                => ex2_optype2,
     ex2_optype4                => ex2_optype4,
     ex2_optype8                => ex2_optype8,
     ex2_optype16               => ex2_optype16,
     ex2_optype32               => ex2_optype32,
     ex2_icswx_type             => ex2_icswx_type,
     ex2_store_instr            => ex2_store_instr_int,
     ex1_dir_acc_val            => ex1_dir_acc_val,
     ex2_cache_acc              => ex2_cache_acc,
     ex3_cache_acc              => ex3_cache_acc,
     ex2_ldst_fexcpt            => ex2_ldst_fexcpt,
     ex2_axu_op                 => ex2_axu_op,
     ex2_mv_reg_op              => ex2_mv_reg_op,
     ex1_thrd_id                => ex1_thrd_id_int,
     ex2_thrd_id                => ex2_thrd_id,
     ex3_thrd_id                => ex3_thrd_id,
     ex4_thrd_id                => ex4_thrd_id,
     ex5_thrd_id                => ex5_thrd_id,
     ex3_req_thrd_id            => ex3_req_thrd_id,
     ex3_targ_match_b1          => ex3_targ_match_b1,
     ex2_targ_match_b2          => ex2_targ_match_b2,
     ex3_target_gpr             => ex3_target_gpr,
     ex2_load_instr             => ex2_load_instr,
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
     ex2_dcbz_instr             => ex2_dcbz_instr,
     ex3_dcbz_instr             => ex3_dcbz_instr,
     ex3_icbi_instr             => ex3_icbi_instr,
     ex3_icswx_instr            => ex3_icswx_instr,
     ex3_icswx_dot              => ex3_icswx_dot,
     ex3_icswx_epid             => ex3_icswx_epid,
     ex3_mbar_instr             => ex3_mbar_instr,
     ex3_msgsnd_instr           => ex3_msgsnd_instr,
     ex3_dci_instr              => ex3_dci_instr,
     ex3_ici_instr              => ex3_ici_instr,
     ex2_lock_instr             => ex2_lock_instr,
     ex3_load_instr             => ex3_load_instr,
     ex3_store_instr            => ex3_store_instr,
     ex3_axu_op_val             => ex3_axu_op_val,
     ex4_drop_rel               => ex4_drop_rel,
     ex3_load_l1hit             => ex3_load_l1hit,
     ex3_rotate_sel             => ex3_rotate_sel,
     ex2_ldawx_instr            => ex2_ldawx_instr_int,
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
     ex3_algebraic              => ex3_algebraic,
     ex3_dcbtls_instr           => ex3_dcbtls_instr,
     ex3_dcbtstls_instr         => ex3_dcbtstls_instr,
     ex3_dcblc_instr            => ex3_dcblc_instr,
     ex3_icblc_instr            => ex3_icblc_instr,
     ex3_icbt_instr             => ex3_icbt_instr,
     ex3_icbtls_instr           => ex3_icbtls_instr,
     ex3_tlbsync_instr          => ex3_tlbsync_instr,
     ex3_local_dcbf             => ex3_local_dcbf,
     rel_dcarr_val_upd          => rel_dcarr_val_upd,

     ex2_no_lru_upd             => ex2_no_lru_upd,
     ex2_is_inval_op            => ex2_is_inval_op,
     ex2_lock_set               => ex2_lock_set,
     ex2_lock_clr               => ex2_lock_clr,
     ex2_ddir_acc_instr         => ex2_ddir_acc_instr,

     ex3_lsq_flush              => ex3_lsq_flush,
     ex3_p_addr_lwr             => ex3_p_addr_lwr,
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
     ex4_load_op_hit            => ex4_load_op_hit,
     ex5_load_op_hit            => ex5_load_op_hit,
     ex4_axu_op_val             => ex4_axu_op_val,

     spr_xucr2_rmt              => spr_xucr2_rmt,
     spr_xucr0_wlck             => spr_xucr0_wlck,
     spr_dvc1_act               => spr_dvc1_act,
     spr_dvc2_act               => spr_dvc2_act,
     spr_dvc1_dbg               => spr_dvc1_dbg,
     spr_dvc2_dbg               => spr_dvc2_dbg,

     -- SPR status
     lsu_xu_spr_xucr0_cul       => lsu_xu_spr_xucr0_cul,
     spr_xucr0_cls              => spr_xucr0_cls,
     agen_xucr0_cls             => agen_xucr0_cls,

     -- Directory Read interface
     dir_arr_rd_is2_val         => dir_arr_rd_is2_val,
     dir_arr_rd_congr_cl        => dir_arr_rd_congr_cl,

     -- Back-invalidate
     rf1_l2_inv_val             => rf1_l2_inv_val,
     ex1_agen_binv_val          => ex1_agen_binv_val,
     ex1_l2_inv_val             => ex1_l2_inv_val,

     -- Update Data Array Valid
     rel_upd_dcarr_val          => rel_upd_dcarr_val,

     lsu_xu_ex4_cr_upd          => lsu_xu_ex4_cr_upd,
     lsu_xu_ex5_wren            => lsu_xu_ex5_wren,
     lsu_xu_rel_wren            => lsu_xu_rel_wren,
     lsu_xu_rel_ta_gpr          => lsu_xu_rel_ta_gpr,
     lsu_xu_perf_events         => lsu_xu_perf_events(0 to 16),
     lsu_xu_need_hole           => lsu_xu_need_hole,

     xu_fu_ex5_reload_val       => xu_fu_ex5_reload_val,
     xu_fu_ex5_load_val         => xu_fu_ex5_load_val,
     xu_fu_ex5_load_tag         => xu_fu_ex5_load_tag,

     -- ICBI Interface
     xu_iu_ex6_icbi_val         => xu_iu_ex6_icbi_val,
     xu_iu_ex6_icbi_addr        => xu_iu_ex6_icbi_addr,

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

     dc_cntrl_dbg_data          => dc_cntrl_dbg_data,

     -- ACT signals
     ex1_stg_act                => ex1_stg_act,
     ex2_stg_act                => ex2_stg_act,
     ex3_stg_act                => ex3_stg_act,
     ex4_stg_act                => ex4_stg_act,
     ex5_stg_act                => ex5_stg_act,
     binv1_stg_act              => binv1_stg_act,
     binv2_stg_act              => binv2_stg_act,
     binv3_stg_act              => binv3_stg_act,
     binv4_stg_act              => binv4_stg_act,
     binv5_stg_act              => binv5_stg_act,
     rel1_stg_act               => rel1_stg_act,
     rel2_stg_act               => rel2_stg_act,
     rel3_stg_act               => rel3_stg_act,

     -- Pervasive
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
     scan_in                    => siv(dccntrl_offset),
     scan_out                   => sov(dccntrl_offset)
);


-- XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
-- Flush Generation
-- XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

lsufgen : entity work.xuq_lsu_fgen(xuq_lsu_fgen)
generic map(expand_type         => expand_type,
	    real_data_add	=> real_data_add)
port map(
     ex2_cache_acc              => ex2_cache_acc,
     ex2_ldst_fexcpt            => ex2_ldst_fexcpt,
     ex2_mv_reg_op              => ex2_mv_reg_op,
     ex2_axu_op                 => ex2_axu_op,
     rf1_thrd_id                => xu_lsu_rf1_thrd_id,
     ex1_thrd_id                => ex1_thrd_id_int,
     ex2_thrd_id                => ex2_thrd_id,
     ex3_thrd_id                => ex3_thrd_id,
     ex4_thrd_id                => ex4_thrd_id,
     ex5_thrd_id                => ex5_thrd_id,
     ex2_optype2                => ex2_optype2,
     ex2_optype4                => ex2_optype4,
     ex2_optype8                => ex2_optype8,
     ex2_optype16               => ex2_optype16,
     ex2_optype32               => ex2_optype32,
     ex2_p_addr_lwr             => ex2_p_addr_lwr(57 to 63),
     ex2_icswx_type             => ex2_icswx_type,
     ex2_store_instr            => ex2_store_instr_int,
     ex2_load_instr             => ex2_load_instr,
     ex2_dcbz_instr             => ex2_dcbz_instr,
     ex2_lock_instr             => ex2_lock_instr,
     ex2_ldawx_instr            => ex2_ldawx_instr_int,
     ex2_lm_dep_hit             => ex2_lm_dep_hit,
     ex3_lsq_flush              => ex3_lsq_flush,
     derat_xu_ex3_noop_touch    => derat_xu_ex3_noop_touch,
     ex3_cClass_collision       => ex3_cClass_collision,
     ex2_lockwatchSet_rel_coll  => ex2_lockwatchSet_rel_coll,
     ex3_wclr_all_flush         => ex3_wclr_all_flush,
     ex3_wimge_w_bit            => ex3_wimge_w_bit,
     ex3_wimge_i_bit            => ex3_wimge_i_bit,
     ex3_targ_match_b1          => ex3_targ_match_b1,
     ex2_targ_match_b2          => ex2_targ_match_b2,
     xu_lsu_spr_xucr0_aflsta    => xu_lsu_spr_xucr0_aflsta,
     xu_lsu_spr_xucr0_flsta     => xu_lsu_spr_xucr0_flsta,
     xu_lsu_spr_xucr0_l2siw     => xu_lsu_spr_xucr0_l2siw,
     ldq_rel_ci                 => ldq_rel_ci,
     ldq_rel_axu_val            => ldq_rel_axu_val,
     xu_lsu_rf1_flush           => xu_lsu_rf1_flush,
     xu_lsu_ex1_flush           => xu_lsu_ex1_flush,
     xu_lsu_ex2_flush           => xu_lsu_ex2_flush,
     xu_lsu_ex3_flush           => xu_lsu_ex3_flush,
     xu_lsu_ex4_flush           => xu_lsu_ex4_flush,
     xu_lsu_ex5_flush           => xu_lsu_ex5_flush,
     rf1_stg_flush              => stg_flush_rf1,
     ex1_stg_flush              => stg_flush_ex1,
     ex2_stg_flush              => stg_flush_ex2,
     ex3_stg_flush              => stg_flush_ex3,
     ex4_stg_flush              => stg_flush_ex4,
     ex5_stg_flush              => stg_flush_ex5,
     lsu_xu_ex3_n_flush_req     => lsu_xu_ex3_n_flush_req,
     lsu_xu_ex3_dep_flush       => lsu_xu_ex3_dep_flush,
     ex3_excp_det               => ex3_excp_det,
     lsu_xu_perf_events         => lsu_xu_perf_events(17 to 20),
     lsu_xu_ex3_align           => lsu_xu_ex3_align,
     lsu_xu_ex3_dsi             => lsu_xu_ex3_dsi,
     lsu_xu_ex3_inval_align_2ucode => lsu_xu_ex3_inval_align_2ucode,
     dc_fgen_dbg_data           => dc_fgen_dbg_data,
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
     scan_in                    => siv(dcfgen_offset),
     scan_out                   => sov(dcfgen_offset)
);

-- XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
-- Outputs
-- XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
ex2_stg_flush             <= stg_flush_ex2;
ex3_stg_flush             <= stg_flush_ex3;
ex4_stg_flush             <= stg_flush_ex4;
ex5_stg_flush             <= stg_flush_ex5;

ex2_store_instr <= ex2_store_instr_int;
ex2_ldawx_instr <= ex2_ldawx_instr_int;
ex1_thrd_id     <= ex1_thrd_id_int;

siv(0 to scan_right) <= sov(1 to scan_right) & scan_in;
scan_out <= sov(0);

end xuq_lsu_dc;
