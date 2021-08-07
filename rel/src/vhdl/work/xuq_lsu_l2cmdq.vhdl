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

--  Description:  XU LSU L2 Command Queue
--

LIBRARY ieee;
LIBRARY ibm;
USE ieee.std_logic_1164.all ;
use ieee.numeric_std.all;
USE ibm.std_ulogic_support.all ;
USE ibm.std_ulogic_function_support.all;
use ibm.std_ulogic_unsigned.all;

library support;
use support.power_logic_pkg.all;

library tri;
use tri.tri_latches_pkg.all;


ENTITY xuq_lsu_l2cmdq IS
   generic(expand_type      : integer := 2;             -- 0 = ibm (Umbra), 1 = non-ibm, 2 = ibm (MPG)
           lmq_entries      : integer := 8;             -- 8 Loadmiss Queue Entries.
           dc_size          : natural := 14;            -- 2^14 = 16384 Bytes L1 D$
           cl_size          : natural := 6;             -- 2^6 = 64 Bytes CacheLines
	   real_data_add    : integer := 42;  		-- 42 bit real address
           a2mode           : integer := 1;
           load_credits     : integer := 4;
           store_credits    : integer := 20;
           st_data_32B_mode : integer := 1 );           -- 0 = 16B store data to L2, 1 = 32B data
   PORT (
        -- Load Miss/Store Operation Signals
        ex3_thrd_id             :in     std_ulogic_vector(0 to 3);       -- Thread ID
        ex3_l_s_q_val           :in     std_ulogic;                      -- load/store miss valid or store valid
        ex3_drop_ld_req         :in     std_ulogic;                      -- load miss
        ex3_drop_touch          :in     std_ulogic;                      -- drop blockable touch
        ex3_cache_inh           :in     std_ulogic;                      -- Cache Inhibit Mode is on
        ex3_load_instr          :in     std_ulogic;                      -- load operation
        ex3_store_instr         :in     std_ulogic;                      -- store operation
        ex3_cache_acc           :in     std_ulogic;                      -- op in ex2 is a cache access
        ex3_p_addr_lwr          :in     std_ulogic_vector(58 to 63);                  -- physical address of load/store miss
        ex3_opsize              :in     std_ulogic_vector(0 to 5);       -- Load/Store Size
                                                                         -- 100000 = 32 bytes
                                                                         -- 010000 = 16 bytes
                                                                         -- 001000 = 8 bytes
                                                                         -- 000100 = 4 bytes
                                                                         -- 000010 = 2 bytes
                                                                         -- 000001 = 1 byte
        ex3_rot_sel             :in     std_ulogic_vector(0 to 4);       -- rotator select bits for data cache
        ex3_byte_en             :in     std_ulogic_vector(0 to 31);      -- Store Data Byte Enables
        ex4_256st_data          :in     std_ulogic_vector(0 to 255);     -- Store Data
        ex3_target_gpr          :in     std_ulogic_vector(0 to 8);       -- Target GPR, needed for reloads
        ex3_axu_op_val          :in     std_ulogic;                      -- Operation was to an AXU register or from a AXU operation
        ex3_le_mode             :in     std_ulogic;                      -- little endian mode
        ex3_larx_instr          :in     std_ulogic;                      -- Load is a lwarx
        ex3_stx_instr           :in     std_ulogic;                      -- Store is a stwcx
        ex3_dcbt_instr          :in     std_ulogic;                      -- DCBT instruction is valid
        ex3_dcbf_instr          :in     std_ulogic;                      -- DCBF instruction is valid
        ex3_dcbtst_instr        :in     std_ulogic;                      -- DCBTST instruction is valid
        ex3_dcbst_instr         :in     std_ulogic;                      -- DCBST instruction is valid
        ex3_dcbz_instr          :in     std_ulogic;                      -- DCBZ instruction is valid
        ex3_dcbi_instr          :in     std_ulogic;                      -- DCBI instruction is valid
        ex3_icbi_instr          :in     std_ulogic;                      -- ICBI instruction is valid
        ex3_sync_instr          :in     std_ulogic;                      -- SYNC instruction is valid
        ex3_l_fld               :in     std_ulogic_vector(0 to 1);       -- L field of sync: 00=hwsync, 01=lwsync, 10=ptesync
        ex3_mbar_instr          :in     std_ulogic;                      -- mbar instruction is valid
        ex3_wimge_bits          :in     std_ulogic_vector(0 to 4);       -- WIMG bits
        ex3_usr_bits            :in     std_ulogic_vector(0 to 3);       -- WIMG bits
        ex3_stg_flush           :in     std_ulogic;                      -- EX3 Flush instruction
        ex4_stg_flush           :in     std_ulogic;                      -- EX4 Flush instruction
        xu_lsu_ex5_flush        :in  std_ulogic_vector(0 to 3);
        ex3_byp_l1              :in     std_ulogic;                      -- Bypass L1 D$ indication if a loadmiss
        ex3_algebraic           :in     std_ulogic;                      -- command is algebraic type
        xu_lsu_ex4_dvc1_en      :in     std_ulogic;             
        xu_lsu_ex4_dvc2_en      :in     std_ulogic;             

        ex3_dcbtls_instr           :in  std_ulogic;
        ex3_dcbtstls_instr         :in  std_ulogic;
        ex3_dcblc_instr            :in  std_ulogic;
        ex3_dci_instr              :in  std_ulogic;
        ex3_ici_instr              :in  std_ulogic;
        ex3_icblc_instr            :in  std_ulogic;
        ex3_icbt_instr             :in  std_ulogic;
        ex3_icbtls_instr           :in  std_ulogic;
        ex3_tlbsync_instr          :in  std_ulogic;
        ex3_local_dcbf             :in  std_ulogic;                     
        ex3_icswx_instr            :in  std_ulogic;
        ex3_icswx_dot              :in  std_ulogic;
        ex3_icswx_epid             :in  std_ulogic;
        ex3_classid                :in  std_ulogic_vector(0 to 1);
        ex3_lock_en  	           :in  std_ulogic;
        ex3_th_fld_l2              :in  std_ulogic;
        ex4_drop_rel               :in  std_ulogic;                       -- active for dcbtls and dcbtstls when L1 hit (treat as L2 only)
        ex3_load_l1hit             :in  std_ulogic;                       -- used for debug to see L1 hits on bus
        ex3_mutex_hint             :in  std_ulogic;
        ex3_msgsnd_instr           :in  std_ulogic;
        ex3_watch_en               :in  std_ulogic;
        ex3_mtspr_trace            :in  std_ulogic;
        ex3_stg_act                :in  std_ulogic;
        ex4_stg_act                :in  std_ulogic;

        ex4_ld_entry              :in  std_ulogic_vector(0 to (26+(real_data_add-1)));

        -- Dependency Checking on loadmisses
        ex1_src0_vld               :in  std_ulogic;                        -- Source0 is Valid
        ex1_src0_reg               :in  std_ulogic_vector(0 to 7);         -- Source0 Register
        ex1_src1_vld               :in  std_ulogic;                        -- Source1 is Valid
        ex1_src1_reg               :in  std_ulogic_vector(0 to 7);         -- Source1 Register
        ex1_targ_vld               :in  std_ulogic;                        -- Target is Valid
        ex1_targ_reg               :in  std_ulogic_vector(0 to 7);         -- Target Register
        ex1_check_watch            :in  std_ulogic_vector(0 to 3);
        ex2_lm_dep_hit             :out std_ulogic;                        -- dependency hit in lm q

        ex6_ld_par_err             :in  std_ulogic;
        pe_recov_begin             :in  std_ulogic;
        ex7_targ_match             :in  std_ulogic;
        ex8_targ_match             :in  std_ulogic;


        -- inputs from L2
        an_ac_req_ld_pop           :in     std_ulogic;                      -- credit for a load (L2 can take a load command)
        an_ac_req_st_pop           :in     std_ulogic;                      -- credit for a store (L2 can take a store command)
        an_ac_req_st_pop_thrd      :in     std_ulogic_vector(0 to 2);   -- decrement outbox credit count
        an_ac_req_st_gather        :in     std_ulogic;                      -- credit for a store due to L2 gathering of store commands

        an_ac_reld_data_coming       :in     std_ulogic;                      -- reload data is coming in 3 cycles
        an_ac_reld_data_val           :in     std_ulogic;                      -- reload data is coming in 2 cycles
        an_ac_reld_core_tag           :in     std_ulogic_vector(0 to 4);       -- reload data destinatoin tag (which load queue)
        an_ac_reld_qw                 :in     std_ulogic_vector(57 to 59);     -- quadword address of reload data beat
        an_ac_reld_data               :in     std_ulogic_vector(0 to 127);     -- reload data
        an_ac_reld_ditc               :in     std_ulogic;                      -- reload data is for ditc (inbox)
        an_ac_reld_crit_qw            :in     std_ulogic;                      -- the transfer assoicated with data_val is the critical QW
        an_ac_reld_l1_dump            :in     std_ulogic;                      -- the transfer assoicated with data_val is the critical QW

        an_ac_reld_ecc_err            :in     std_ulogic;                      -- correctable ecc error on the data transfer
        an_ac_reld_ecc_err_ue         :in     std_ulogic;                      -- un-correctable ecc error on the data transfer

        an_ac_back_inv                :in     std_ulogic;                                 -- back invalidate (cycle before inv_addr)
        an_ac_back_inv_addr           :in     std_ulogic_vector(64-real_data_add to 63);  -- address for back invalidate
        an_ac_back_inv_target_bit1    :in     std_ulogic;                                 -- target of back invalidate (cycle before inv_addr)
        an_ac_back_inv_target_bit4    :in     std_ulogic;                                 -- XU just gets bits 1 (D side) and 4 (IPI)

        an_ac_req_spare_ctrl_a1    :in     std_ulogic_vector(0 to 3);          -- spare control bits from L2
        an_ac_stcx_complete        :in  std_ulogic_vector(0 to 3);
        xu_iu_stcx_complete        :out   std_ulogic_vector(0 to 3);
        xu_iu_reld_core_tag_clone     :out     std_ulogic_vector(1 to 4);
        xu_iu_reld_data_coming_clone  :out     std_ulogic;
        xu_iu_reld_data_vld_clone     :out     std_ulogic;
        xu_iu_reld_ditc_clone         :out     std_ulogic;

-- redrive to boxes logic
        lsu_reld_data_vld        :out    std_ulogic;                      -- reload data is coming in 2 cycles
        lsu_reld_core_tag        :out    std_ulogic_vector(3 to 4);       -- reload data destinatoin tag (thread)
        lsu_reld_qw              :out    std_ulogic_vector(58 to 59);     -- reload data quadword pointer
        lsu_reld_ditc            :out    std_ulogic;                      -- reload data is for ditc (inbox)
        lsu_reld_ecc_err         :out    std_ulogic;                      -- reload data has ecc error
        lsu_reld_data            :out    std_ulogic_vector(0 to 127);     -- reload data

        lsu_req_st_pop           :out    std_ulogic;                  -- decrement outbox credit count
        lsu_req_st_pop_thrd      :out    std_ulogic_vector(0 to 2);   -- decrement outbox credit count

        -- Instruction Fetches
        -- Instruction Fetch real address
        i_x_ra                  :in     std_ulogic_vector(64-real_data_add to 59);
        i_x_request             :in     std_ulogic;                      -- Instruction Fetch is Valid
        i_x_wimge               :in     std_ulogic_vector(0 to 4);       -- Instruction Fetch WIMG bits
        i_x_thread              :in     std_ulogic_vector(0 to 3);       -- Instruction Fetch Thread ID
        i_x_userdef             :in     std_ulogic_vector(0 to 3);       --

        -- MMU instruction interface
	mm_xu_lsu_req           :in     std_ulogic_vector(0 to 3);    -- will only pulse when mm has at least 1 token (1 bit per thread)
	mm_xu_lsu_ttype         :in     std_ulogic_vector(0 to 1);    -- 0=TLBIVAX, 1=TLBI_COMPLETE, 2=LOAD (tag=01100), 3=LOAD (tag=01101)
	mm_xu_lsu_wimge         :in     std_ulogic_vector(0 to 4);
	mm_xu_lsu_u             :in     std_ulogic_vector(0 to 3);    -- user defined bits
	mm_xu_lsu_addr          :in     std_ulogic_vector(64-real_data_add to 63);  -- address for TLBI (or loads, maybe),
                                                                                    -- TLBI_COMPLETE is address-less
        mm_xu_lsu_lpid          :in     std_ulogic_vector(0 to 7);   -- muxed LPID for the thread of the mmu command
        mm_xu_lsu_gs            :in     std_ulogic;
        mm_xu_lsu_ind           :in     std_ulogic;
        mm_xu_lsu_lbit          :in     std_ulogic;                   -- "L" bit, for large vs. small

        mm_xu_lsu_lpidr         :in     std_ulogic_vector(0 to 7);   -- the LPIDR register
        xu_lsu_msr_gs           :in     std_ulogic_vector(0 to 3);   -- (MSR.HV)
        xu_lsu_msr_pr           :in     std_ulogic_vector(0 to 3);   -- Problem State (MSR.PR)
        xu_lsu_msr_ds           :in     std_ulogic_vector(0 to 3);   -- Addr Space (MSR.DS)
        mm_xu_derat_pid0        :in     std_ulogic_vector(0 to 13);  -- Thread0 PID Number
        mm_xu_derat_pid1        :in     std_ulogic_vector(0 to 13);  -- Thread1 PID Number
        mm_xu_derat_pid2        :in     std_ulogic_vector(0 to 13);  -- Thread2 PID Number
        mm_xu_derat_pid3        :in     std_ulogic_vector(0 to 13);  -- Thread3 PID Number
        xu_derat_epsc0_epr      :in     std_ulogic;
        xu_derat_epsc0_eas      :in     std_ulogic;
        xu_derat_epsc0_egs      :in     std_ulogic;
        xu_derat_epsc0_elpid    :in     std_ulogic_vector(40 to 47);
        xu_derat_epsc0_epid     :in     std_ulogic_vector(50 to 63);
        xu_derat_epsc1_epr      :in     std_ulogic;
        xu_derat_epsc1_eas      :in     std_ulogic;
        xu_derat_epsc1_egs      :in     std_ulogic;
        xu_derat_epsc1_elpid    :in     std_ulogic_vector(40 to 47);
        xu_derat_epsc1_epid     :in     std_ulogic_vector(50 to 63);
        xu_derat_epsc2_epr      :in     std_ulogic;
        xu_derat_epsc2_eas      :in     std_ulogic;
        xu_derat_epsc2_egs      :in     std_ulogic;
        xu_derat_epsc2_elpid    :in     std_ulogic_vector(40 to 47);
        xu_derat_epsc2_epid     :in     std_ulogic_vector(50 to 63);
        xu_derat_epsc3_epr      :in     std_ulogic;
        xu_derat_epsc3_eas      :in     std_ulogic;
        xu_derat_epsc3_egs      :in     std_ulogic;
        xu_derat_epsc3_elpid    :in     std_ulogic_vector(40 to 47);
        xu_derat_epsc3_epid     :in     std_ulogic_vector(50 to 63);


        -- Boxes interface
        bx_lsu_ob_pwr_tok        :in     std_ulogic;                  -- message buffer data is ready to send
        bx_lsu_ob_req_val       :in     std_ulogic;                  -- message buffer data is ready to send
        bx_lsu_ob_ditc_val      :in     std_ulogic;                  -- send dtic command
        bx_lsu_ob_thrd          :in     std_ulogic_vector(0 to 1);   -- source thread
        bx_lsu_ob_qw            :in     std_ulogic_vector(58 to 59); -- QW address
        bx_lsu_ob_dest          :in     std_ulogic_vector(0 to 14);  -- destination node/core/thread for the packet
        bx_lsu_ob_data          :in     std_ulogic_vector(0 to 127); -- 16B of data from the outbox
        bx_lsu_ob_addr          :in     std_ulogic_vector(64-real_data_add to 57); -- address for boxes message
        lsu_bx_cmd_avail        :out    std_ulogic;
        lsu_bx_cmd_sent         :out    std_ulogic;
        lsu_bx_cmd_stall        :out    std_ulogic;

        spr_xucr0_clkg_ctl_b3  :in      std_ulogic;  -- Clock Gating Override
        xu_lsu_spr_xucr0_rel   :in      std_ulogic;  -- L2 Reload Mode Control (0=gaps, 1=back to back)
        xu_lsu_spr_xucr0_l2siw :in      std_ulogic;  -- L2 Store Interface Width (0=16B, 1=32B)
        xu_lsu_spr_xucr0_cred  :in      std_ulogic;  -- L2 credit debug mode (0=normal, 1=need both load and store credit to send anything)
        xu_lsu_spr_xucr0_mbar_ack  :in  std_ulogic;  -- use sync_ack from L2 for lwsync and mbar when 1
        xu_lsu_spr_xucr0_tlbsync :in std_ulogic; -- use sync_ack from L2 for tlbsync when 1
        xu_lsu_spr_xucr0_cls   :in      std_ulogic;  -- cache line size (1=128 byte, 0=64 byte)

	xu_mm_lsu_token         :out    std_ulogic;   -- pulse for 1 clk when mm queue entry has been sent (i.e. mmu can request again)

 
        -- Memory Barrier Complete for lwsync/mbar signals going to IU
        lsu_xu_ldq_barr_done         :out    std_ulogic_vector(0 to 3);       -- Memory Barrier for ldq hit complete thread id, should be on when true
        lsu_xu_sync_barr_done        :out    std_ulogic_vector(0 to 3);       -- Memory Barrier (lwsync/mbar) complete thread id, should be on when true

        -- *** Reload operation Outputs ***
        -- Reload Address
        ldq_rel_op_size         :out    std_ulogic_vector(0 to 5);       -- Reload Size, used to determine the data write in gpr reg file
        ldq_rel_thrd_id         :out    std_ulogic_vector(0 to 3);       -- Thread ID of the reload
                                                                                        -- goes with ldq_rel_val
        ldq_rel_addr_early      :out    std_ulogic_vector(64-real_data_add to 57);        -- 1 cycle before ldq_rel_addr
        ldq_rel_addr            :out    std_ulogic_vector(64-real_data_add to 58);    -- d-cache reload physical address in cycle before data
        ldq_rel_data_val_early  :out    std_ulogic;                      -- 1 cycle before reload data - use for act
        ldq_rel_data_val        :out    std_ulogic;                      -- Reload data is valid, active for 2 32B beats of data
        ldq_rel_tag_early       :out    std_ulogic_vector(2 to 4);       -- tag of the reload, 1 cycle early
        ldq_rel_tag             :out    std_ulogic_vector(2 to 4);       -- tag of the reload
        ldq_rel1_val            :out    std_ulogic;                      -- Reload data is valid for 1st 32B beat
        ldq_rel1_early_v        :out    std_ulogic;
        ldq_rel_mid_val         :out    std_ulogic;                      -- Reload data is valid for middle 32B beat
        ldq_rel_retry_val       :out    std_ulogic;                      -- Reload is recirculated, dont update D$ array
        ldq_rel3_val            :out    std_ulogic;                      -- Reload data is valid for last 32B beat
        ldq_rel3_early_v        :out    std_ulogic;
        ldq_rel_ta_gpr          :out    std_ulogic_vector(0 to 8);       -- Reload Target Register
        ldq_rel_rot_sel         :out    std_ulogic_vector(0 to 4);       -- Reload rotator select
        ldq_rel_axu_val         :out    std_ulogic;                      -- Reload is for a Vector Register
        ldq_rel_upd_gpr         :out    std_ulogic;                      -- Reload data should be written to GPR (DCB ops don't write to GPRs)
        ldq_rel_le_mode         :out    std_ulogic;                      -- Reload data is in little endian mode
        ldq_rel_algebraic       :out    std_ulogic;
        ldq_rel_set_val         :out    std_ulogic;                      -- all 4 data beats have transferred without error, set valid in dir
        ldq_rel_256_data        :out    std_ulogic_vector(0 to 255);     -- 32 bytes of reload data
        ldq_rel_ecc_err         :out    std_ulogic;                      -- all 4 data beats have transferred without error, set valid in dir


        ldq_rel_classid         :out    std_ulogic_vector(0 to 1);
        ldq_rel_lock_en         :out    std_ulogic;
        ldq_rel_ci              :out    std_ulogic;
        ldq_rel_dvc1_en         :out    std_ulogic;
        ldq_rel_dvc2_en         :out    std_ulogic;
        ldq_rel_watch_en        :out    std_ulogic;
        ldq_rel_back_invalidated :out   std_ulogic;

        ldq_recirc_rel_val      :in     std_ulogic;

        ldq_rel_beat_crit_qw        :out    std_ulogic;                      -- critical QW being sent on the reload data
        ldq_rel_beat_crit_qw_block  :out    std_ulogic;                      -- critical QW blocked due to ecc error

        l1dump_cslc                 :out    std_ulogic;
        ldq_rel3_l1dump_val         :out    std_ulogic;                      -- reload had l1dump set

        -- Back invalidate signals going to D-Cache
        is2_l2_inv_val              :out    std_ulogic;                                 
        is2_l2_inv_p_addr           :out    std_ulogic_vector(64-real_data_add to 63-cl_size);  


        -- Flush Signals and signals going to dependency
        ex3_stq_flush           :out    std_ulogic;                      -- Store Queue Full flush
        ex3_ig_flush            :out    std_ulogic;                      -- 2nd load to I=1, G=1 flush
        ex3_ld_queue_full        :out    std_ulogic;                      

        gpr_ecc_err_flush_tid   :out    std_ulogic_vector(0 to 3);      -- all cmds to this thread need to be flushed
                                                                        -- because GPR got bad ecc on a reload
        xu_iu_ex4_loadmiss_qentry     :out    std_ulogic_vector(0 to lmq_entries-1);       -- Load Miss Queue entry
        xu_iu_ex4_loadmiss_target     :out    std_ulogic_vector(0 to 8);       -- target gpr
        xu_iu_ex4_loadmiss_target_type     :out    std_ulogic_vector(0 to 1);
        xu_iu_ex4_loadmiss_tid        :out    std_ulogic_vector(0 to 3);
        xu_iu_ex5_loadmiss_qentry     :out    std_ulogic_vector(0 to lmq_entries-1);       -- Load Miss Queue entry
        xu_iu_ex5_loadmiss_target     :out    std_ulogic_vector(0 to 8);       -- target gpr
        xu_iu_ex5_loadmiss_target_type     :out    std_ulogic_vector(0 to 1);
        xu_iu_ex5_loadmiss_tid        :out    std_ulogic_vector(0 to 3);
        xu_iu_complete_qentry     :out    std_ulogic_vector(0 to lmq_entries-1);       -- Load Miss Complete, Reload came backld_m_rel0_done
        xu_iu_complete_tid        :out    std_ulogic_vector(0 to 3);
        xu_iu_complete_target_type     :out    std_ulogic_vector(0 to 1);

        xu_iu_larx_done_tid           :out    std_ulogic_vector(0 to 3);

        xu_lsu_ex5_set_barr            :in     std_ulogic_vector(0 to 3);

        xu_mm_lmq_stq_empty           :out    std_ulogic;

        lsu_xu_quiesce                :out    std_ulogic_vector(0 to 3);


        lsu_xu_dbell_val              :out    std_ulogic;
        lsu_xu_dbell_type             :out    std_ulogic_vector(0 to 4);
        lsu_xu_dbell_brdcast          :out    std_ulogic;
        lsu_xu_dbell_lpid_match       :out    std_ulogic;
        lsu_xu_dbell_pirtag           :out    std_ulogic_vector(50 to 63);

        ac_an_req_pwr_token       :out    std_ulogic;                              -- power token for command coming next cycle
        ac_an_req                 :out    std_ulogic;                              -- command request valid
        ac_an_req_ra              :out    std_ulogic_vector(64-real_data_add to 63);  -- real address for request
        ac_an_req_ttype           :out    std_ulogic_vector(0 to 5);               -- command (transaction) type
        ac_an_req_thread          :out    std_ulogic_vector(0 to 2);               -- encoded thread ID
        ac_an_req_wimg_w          :out    std_ulogic;                              -- write-through
        ac_an_req_wimg_i          :out    std_ulogic;                              -- cache-inhibited
        ac_an_req_wimg_m          :out    std_ulogic;                              -- memory coherence required
        ac_an_req_wimg_g          :out    std_ulogic;                              -- guarded memory
        ac_an_req_endian          :out    std_ulogic;                              -- endian mode (0=big endian, 1=little endian)
        ac_an_req_user_defined    :out    std_ulogic_vector(0 to 3);               -- user defined bits
        ac_an_req_spare_ctrl_a0   :out    std_ulogic_vector(0 to 3);               -- spare control bits to L2
        ac_an_req_ld_core_tag     :out    std_ulogic_vector(0 to 4);               -- load command tag (which load Q)
        ac_an_req_ld_xfr_len      :out    std_ulogic_vector(0 to 2);               -- transfer length for non-cacheable load
                                                                                   -- 000 = reserved     100 = 4 bytes
                                                                                   -- 001 = 1 byte       101 = 8 bytes
                                                                                   -- 010 = 2 bytes      110 = 16 bytes
                                                                                   -- 011 = 3 bytes      111 = 32 bytes
        ac_an_st_byte_enbl        :out    std_ulogic_vector(0 to 15+(st_data_32B_mode*16));   -- byte enables for store data
        ac_an_st_data             :out    std_ulogic_vector(0 to 127+(st_data_32B_mode*128)); -- store data (Prism uses bits 0 to 127 only)
        ac_an_st_data_pwr_token   :out    std_ulogic;                      -- store data power token

     -- connect to the compare logic

       cmp_lmq_entry_act          :out std_ulogic; -- act for lmq entries
       cmp_ex3_p_addr_o           :in  std_ulogic_vector(64-real_data_add to 57); -- erat array output
       cmp_ldq_comp_val           :out std_ulogic_vector(0 to 7); -- enable compares against lmq
       cmp_ldq_match              :in  std_ulogic_vector(0 to 7); -- compare result (without enable)
       cmp_ldq_fnd                :in  std_ulogic; -- all the enabled compares "OR"ed together

       cmp_l_q_wrt_en             :out std_ulogic_vector(0 to 7);   -- load entry, (hold when not loading)
       cmp_ld_ex7_recov           :out std_ulogic;
       cmp_ex7_ld_recov_addr      :out std_ulogic_vector(64-real_data_add to 57); 

       cmp_ex4_loadmiss_qentry    :out std_ulogic_vector(0 to 7);   -- mux 3 select
       cmp_ex4_ld_addr            :in  std_ulogic_vector(64-real_data_add to 57); -- mux 3

       cmp_l_q_rd_en              :out std_ulogic_vector(0 to 7);   -- mux 2 select
       cmp_l_miss_entry_addr      :in  std_ulogic_vector(64-real_data_add to 57); -- mux 2

       cmp_rel_tag_1hot           :out std_ulogic_vector(0 to 7);   -- mux 1 select
       cmp_rel_addr               :in  std_ulogic_vector(64-real_data_add to 57); -- mux 1

       cmp_back_inv_addr          :out std_ulogic_vector(64-real_data_add to 57); -- compare to each ldq entry
       cmp_back_inv_cmp_val       :out std_ulogic_vector(0 to 7);   
       cmp_back_inv_addr_hit      :in  std_ulogic_vector(0 to 7);   

       cmp_s_m_queue0_addr        :out std_ulogic_vector(64-real_data_add to 57); 
       cmp_st_entry0_val          :out std_ulogic                 ; 
       cmp_ex3addr_hit_stq        :in  std_ulogic                 ; 

       cmp_ex4_st_entry_addr      :out std_ulogic_vector(64-real_data_add to 57); 
       cmp_ex4_st_val             :out std_ulogic                 ; 
       cmp_ex3addr_hit_ex4st      :in  std_ulogic                 ; 

     -- latch and redrive for BXQ
     ac_an_reld_ditc_pop_int    : in  std_ulogic_vector(0 to 3);
     ac_an_reld_ditc_pop_q      : out std_ulogic_vector(0 to 3);
     bx_ib_empty_int            : in  std_ulogic_vector(0 to 3);
     bx_ib_empty_q              : out std_ulogic_vector(0 to 3);



     -- Performance Events
     lsu_xu_perf_events         :out std_ulogic_vector(0 to 8);

     lmq_pe_recov_state        :out std_ulogic;

     -- Debug Data Bus
     lmq_dbg_dcache_pe          :out std_ulogic_vector(1 to 60);
     lmq_dbg_l2req              :out std_ulogic_vector(0 to 212);
     lmq_dbg_rel                :out std_ulogic_vector(0 to 140);
     lmq_dbg_binv               :out std_ulogic_vector(0 to 44);
     lmq_dbg_pops               :out std_ulogic_vector(0 to 5);
     lmq_dbg_grp0               :out std_ulogic_vector(0 to 81);
     lmq_dbg_grp1               :out std_ulogic_vector(0 to 81);
     lmq_dbg_grp2               :out std_ulogic_vector(0 to 87);
     lmq_dbg_grp3               :out std_ulogic_vector(0 to 87);
     lmq_dbg_grp4               :out std_ulogic_vector(0 to 87);
     lmq_dbg_grp5               :out std_ulogic_vector(0 to 87);
     lmq_dbg_grp6               :out std_ulogic_vector(0 to 87);

     -- power
     vdd                        : inout power_logic;
     gnd                        : inout power_logic;

     --pervasive
     l2_data_ecc_err_ue         :out std_ulogic_vector(0 to 3);
     xu_pc_err_l2intrf_ecc      :out std_ulogic;
     xu_pc_err_l2intrf_ue       :out std_ulogic;
     xu_pc_err_invld_reld       :out std_ulogic;
     xu_pc_err_l2credit_overrun :out std_ulogic;

     an_ac_coreid               :in std_ulogic_vector(6 to 7);

     nclk                       :in  clk_logic;
     sg_0                       :in  std_ulogic;
     func_sl_thold_0_b          :in  std_ulogic;
     func_sl_force              :in  std_ulogic;
     func_slp_sl_thold_0_b      :in  std_ulogic;
     func_slp_sl_force          :in  std_ulogic;
     cfg_slp_sl_thold_0_b       :in  std_ulogic;
     cfg_slp_sl_force           :in  std_ulogic;
     d_mode_dc                  :in  std_ulogic;
     delay_lclkr_dc             :in  std_ulogic;
     mpw1_dc_b                  :in  std_ulogic;
     mpw2_dc_b                  :in  std_ulogic;
     scan_dis_dc_b              :in  std_ulogic;
     bcfg_scan_in               :in  std_ulogic;
     bcfg_scan_out              :out std_ulogic;
     scan_in                    :in  std_ulogic_vector(0 to 2);
     scan_out                   :out std_ulogic_vector(0 to 2)
    );




END ;

ARCHITECTURE xuq_lsu_l2cmdq OF xuq_lsu_l2cmdq IS

constant REAL_IFAR_length       : integer := (real_data_add-4);

signal c_inh                    :std_ulogic;
signal ctrl_incr_cmdseq         :std_ulogic;
signal ctrl_decr_cmdseq         :std_ulogic;
signal ctrl_hold_cmdseq         :std_ulogic;
signal cmd_seq_incr             :std_ulogic_vector(0 to 4);
signal cmd_seq_decr             :std_ulogic_vector(0 to 4);
signal cmd_seq_d                :std_ulogic_vector(0 to 4);
signal cmd_seq_l2               :std_ulogic_vector(0 to 4);
signal new_ld_cmd_seq           :std_ulogic_vector(0 to 4);
signal cmd_seq_rd_incr          :std_ulogic_vector(0 to 4);
signal cmd_seq_rd_d             :std_ulogic_vector(0 to 4);
signal cmd_seq_rd_l2            :std_ulogic_vector(0 to 4);
signal ld_q_seq_wrap            :std_ulogic;

signal ld_queue_entry           :std_ulogic_vector(0 to 53);
signal ld_queue_addrlo          :std_ulogic_vector(57 to 63);
signal st_val                   :std_ulogic;
signal st_flush                 :std_ulogic;
signal flush_if_store           :std_ulogic;
signal nxt_st_cred_tkn          :std_ulogic;
signal sync_flush               :std_ulogic;
signal s_m_queue0_d             :std_ulogic_vector(0 to (58+(real_data_add-1)));
signal s_m_queue0               :std_ulogic_vector(0 to (58+(real_data_add-1)));
signal ex3_st_entry             :std_ulogic_vector(0 to (58+(real_data_add-1)));
signal ex4_st_entry_act         :std_ulogic;
signal ex4_st_entry_l2          :std_ulogic_vector(0 to (58+(real_data_add-1)));
signal st_entry0_val_d          :std_ulogic;
signal st_entry0_val_l2         :std_ulogic;
signal st_entry0_val_clone_l2   :std_ulogic;
signal ex4_st_val_d             :std_ulogic;
signal ex4_st_val_l2            :std_ulogic;
signal ex4_st_valid             :std_ulogic;
signal ex5_st_val_l2            :std_ulogic;
signal ex5_st_val_for_flush     :std_ulogic;
signal ex6_st_val_l2            :std_ulogic;
signal ex4_st_addr              :std_ulogic_vector(64-real_data_add to 63);

signal ld_m_val                 :std_ulogic;
signal ex4_ld_m_val             :std_ulogic;
signal ex4_ld_m_val_not_fl      :std_ulogic;
signal ex4_drop_ld_req          :std_ulogic;
signal ex4_drop_touch           :std_ulogic;


signal my_ex4_flush_l2          :std_ulogic;
signal ld_flush                 :std_ulogic;
signal ld_queue_full            :std_ulogic;
signal comp_val                 :std_ulogic_vector(0 to lmq_entries-1);
signal l_m_q_cpy                :std_ulogic_vector(0 to lmq_entries-1);
signal l_m_q_cpy_nofl           :std_ulogic_vector(0 to lmq_entries-1);
signal ex4_lmq_cpy_l2           :std_ulogic_vector(0 to lmq_entries-1);
signal ex5_lmq_cpy_l2           :std_ulogic_vector(0 to lmq_entries-1);
signal l_m_fnd_nofl             :std_ulogic;
signal l_q_wrt_en               :std_ulogic_vector(0 to lmq_entries-1);
signal ld_entry_val_d          :std_ulogic_vector(0 to lmq_entries-1);
signal ld_entry_val_l2         :std_ulogic_vector(0 to lmq_entries-1);

type load_queue_array is array(0 to lmq_entries-1) of std_ulogic_vector(0 to 53);
signal l_m_queue_d              :load_queue_array;
signal l_m_queue                :load_queue_array;
type load_queue_addrlo_array is array(0 to lmq_entries-1) of std_ulogic_vector(57 to 63);
signal l_m_queue_addrlo_d       :load_queue_addrlo_array;
signal l_m_queue_addrlo         :load_queue_addrlo_array;
signal ex4_ld_recov_entry       :std_ulogic_vector(0 to 53);
signal ex4_ld_recov_addrlo      :std_ulogic_vector(58 to 63);
signal ex4_ld_entry_d           :std_ulogic_vector(0 to 14);
signal ex4_ld_entry_l2          :std_ulogic_vector(0 to 14);
signal ex4_classid_l2           :std_ulogic_vector(0 to 1);
signal ex4_ld_recov             :std_ulogic_vector(0 to (54+(real_data_add-1)));
signal ex5_ld_recov_d           :std_ulogic_vector(0 to (54+(real_data_add-1)));
signal ex6_ld_recov_d           :std_ulogic_vector(0 to (54+(real_data_add-1)));
signal ex7_ld_recov_d           :std_ulogic_vector(0 to (54+(real_data_add-1)));
signal ex5_ld_recov_l2          :std_ulogic_vector(0 to (54+(real_data_add-1)));
signal ex6_ld_recov_l2          :std_ulogic_vector(0 to (54+(real_data_add-1)));
signal ex7_ld_recov_l2          :std_ulogic_vector(0 to (54+(real_data_add-1)));
signal ex4_ld_entry_hit_st_d    :std_ulogic;
signal ex4_ld_entry_hit_st_l2   :std_ulogic;
signal ex4_touch                :std_ulogic;
signal ex4_l2only               :std_ulogic;
signal ex4_ld_recov_val_d         :std_ulogic;
signal ex4_ld_recov_val_l2      :std_ulogic;
signal ex5_ld_recov_val_d         :std_ulogic;
signal ex5_ld_recov_val_l2      :std_ulogic;
signal ex5_ld_recov_val_not_fl  :std_ulogic;
signal ex6_ld_recov_val_l2      :std_ulogic;       
signal ex6_ld_recov_val_not_fl  :std_ulogic;
signal ex7_ld_recov_val_l2      :std_ulogic;       
signal ex4_ld_recov_ld_hit_st   :std_ulogic;       
signal ex4_ld_recov_extra       :std_ulogic_vector(0 to 3);       
signal ex5_ld_recov_extra_d     :std_ulogic_vector(0 to 3);       
signal ex6_ld_recov_extra_d     :std_ulogic_vector(0 to 3);       
signal ex7_ld_recov_extra_d     :std_ulogic_vector(0 to 3);       
signal ex5_ld_recov_extra_l2    :std_ulogic_vector(0 to 3);       
signal ex6_ld_recov_extra_l2    :std_ulogic_vector(0 to 3);       
signal ex7_ld_recov_extra_l2    :std_ulogic_vector(0 to 3);       
signal ex8_ld_recov_extra_l2    :std_ulogic_vector(1 to 3);       
signal pe_recov_state_d         :std_ulogic;
signal pe_recov_state_l2        :std_ulogic;
signal pe_recov_state_dly_l2    :std_ulogic;
signal pe_recov_ld_num_d        :std_ulogic_vector(1 to 3);
signal pe_recov_ld_num_l2       :std_ulogic_vector(1 to 3);
signal pe_recov_ld_val_d        :std_ulogic;
signal pe_recov_ld_val_l2       :std_ulogic;
signal pe_recov_stall           :std_ulogic;
signal recov_ignr_flush_d       :std_ulogic;
signal set_st_hit_recov_ld      :std_ulogic;
signal reset_st_hit_recov_ld    :std_ulogic;
signal stq_hit_ex6_recov          :std_ulogic;
signal ex4st_hit_ex6_recov        :std_ulogic;
signal st_hit_recov_ld_d        :std_ulogic;
signal st_hit_recov_ld_l2       :std_ulogic;
signal blk_st_for_pe_recov        :std_ulogic;
signal blk_st_cred_pop            :std_ulogic;



type rel_queue_array is array(0 to lmq_entries-1) of std_ulogic_vector(0 to 33);
signal rel_entry                :rel_queue_array;

signal rel_addr_d               :std_ulogic_vector(64-real_data_add to 58);
signal rel_size_d               :std_ulogic_vector(0 to 5);
signal rel_rot_sel_d            :std_ulogic_vector(0 to 4);
signal rel_th_id_d              :std_ulogic_vector(0 to 3);
signal l_m_rel_c_i_beat0_d    :std_ulogic_vector(0 to lmq_entries-1);
signal l_m_rel_c_i_val         :std_ulogic_vector(0 to lmq_entries-1);
signal l_m_rel_hit_beat0_d     :std_ulogic_vector(0 to lmq_entries-1);
signal l_m_rel_hit_beat1_d     :std_ulogic_vector(0 to lmq_entries-1);
signal l_m_rel_hit_beat2_d     :std_ulogic_vector(0 to lmq_entries-1);
signal l_m_rel_hit_beat3_d     :std_ulogic_vector(0 to lmq_entries-1);
signal l_m_rel_hit_beat4_d     :std_ulogic_vector(0 to lmq_entries-1);
signal l_m_rel_hit_beat5_d     :std_ulogic_vector(0 to lmq_entries-1);
signal l_m_rel_hit_beat6_d     :std_ulogic_vector(0 to lmq_entries-1);
signal l_m_rel_hit_beat7_d     :std_ulogic_vector(0 to lmq_entries-1);
signal l_m_rel_inprog_d        :std_ulogic_vector(0 to lmq_entries-1);
signal l_m_rel_c_i_beat0_l2    :std_ulogic_vector(0 to lmq_entries-1);
signal l_m_rel_hit_beat0_l2    :std_ulogic_vector(0 to lmq_entries-1);
signal l_m_rel_hit_beat1_l2    :std_ulogic_vector(0 to lmq_entries-1);
signal l_m_rel_hit_beat2_l2    :std_ulogic_vector(0 to lmq_entries-1);
signal l_m_rel_hit_beat3_l2    :std_ulogic_vector(0 to lmq_entries-1);
signal l_m_rel_hit_beat4_l2    :std_ulogic_vector(0 to lmq_entries-1);
signal l_m_rel_hit_beat5_l2    :std_ulogic_vector(0 to lmq_entries-1);
signal l_m_rel_hit_beat6_l2    :std_ulogic_vector(0 to lmq_entries-1);
signal l_m_rel_hit_beat7_l2    :std_ulogic_vector(0 to lmq_entries-1);
signal l_m_rel_inprog_l2       :std_ulogic_vector(0 to lmq_entries-1);
signal rel_done_ecc_err           :std_ulogic;
signal ld_m_rel_done_d            :std_ulogic_vector(0 to lmq_entries-1);
signal ld_m_rel_done_l2           :std_ulogic_vector(0 to lmq_entries-1);
signal ld_m_rel_done_no_retry     :std_ulogic_vector(0 to lmq_entries-1);
signal ld_m_rel_done_dly_l2       :std_ulogic_vector(0 to lmq_entries-1);
signal ld_m_rel_done_dly2_l2      :std_ulogic_vector(0 to lmq_entries-1);
signal reset_lmq_entry_rel        :std_ulogic_vector(0 to lmq_entries-1);
signal reset_lmq_entry            :std_ulogic_vector(0 to lmq_entries-1);
signal reset_ldq_hit_barr         :std_ulogic_vector(0 to lmq_entries-1);
signal ldq_retry_d                :std_ulogic_vector(0 to lmq_entries-1);
signal ldq_retry_l2               :std_ulogic_vector(0 to lmq_entries-1);
signal ldq_retry_ready            :std_ulogic_vector(0 to lmq_entries-1);
signal start_ldq_retry            :std_ulogic_vector(0 to lmq_entries-1);
signal retry_started_d            :std_ulogic_vector(0 to lmq_entries-1);
signal retry_started_l2           :std_ulogic_vector(0 to lmq_entries-1);
signal ldq_retry_or               :std_ulogic;

signal any_ld_entry_val         :std_ulogic;
signal selected_ld_entry_val    :std_ulogic;
signal selected_entry_flushed   :std_ulogic;
signal cmd_seq_rd_incr_val      :std_ulogic;
signal ldq_rd_seq_match_next    :std_ulogic_vector(0 to lmq_entries-1);
signal ldq_rd_seq_match_curr    :std_ulogic_vector(0 to lmq_entries-1);
signal ldq_rd_seq_match_d       :std_ulogic_vector(0 to lmq_entries-1);
signal ldq_rd_seq_match_l2      :std_ulogic_vector(0 to lmq_entries-1);
signal l_q_rd_en                :std_ulogic_vector(0 to lmq_entries-1);
signal rd_seq_hit               :std_ulogic_vector(0 to lmq_entries-1);
signal rd_seq_num_exits         :std_ulogic;
signal rd_seq_num_skip          :std_ulogic;
signal blk_ld_for_pe_recov_d    :std_ulogic;
signal blk_ld_for_pe_recov_l2   :std_ulogic;


signal l_miss_entry             :std_ulogic_vector(0 to 53);
signal l_miss_addrlo            :std_ulogic_vector(58 to 63);
signal store_sent               :std_ulogic;
signal ex5_store_sent           :std_ulogic;
signal ex4_sel_st_req           :std_ulogic;
signal cred_pop                 :std_ulogic;
signal ex5_sel_st_req           :std_ulogic;
signal load_sent                :std_ulogic;
signal load_sent_dbglat_l2      :std_ulogic;
signal load_flushed             :std_ulogic;
signal mmu_sent                 :std_ulogic;
signal mmu_sent_l2              :std_ulogic;
signal mmu_ld_sent              :std_ulogic;
signal mmu_st_sent              :std_ulogic;
signal l_m_tag                  :std_ulogic_vector(2 to 4);
signal iu_thrd                  :std_ulogic_vector(0 to 1);
signal ld_tag                   :std_ulogic_vector(1 to 4);


signal l_m_rel_val_c_i_dly       :std_ulogic_vector(0 to lmq_entries-1);

signal rel_addr_l2              :std_ulogic_vector(64-real_data_add to 58);
signal rel_size_l2              :std_ulogic_vector(0 to 5);
signal rel_rot_sel_l2           :std_ulogic_vector(0 to 4);
signal rel_th_id_l2             :std_ulogic_vector(0 to 3);
signal rel_tar_gpr_d            :std_ulogic_vector(0 to 8);
signal rel_tar_gpr_l2           :std_ulogic_vector(0 to 8);


signal rel_cache_inh_d          :std_ulogic;
signal rel_cache_inh_l2         :std_ulogic;
signal rel_le_mode_d            :std_ulogic;
signal rel_vpr_val_d            :std_ulogic;
signal rel_vpr_val_l2           :std_ulogic;
signal dcbt_instr               :std_ulogic;
signal touch_instr              :std_ulogic;
signal l2only_instr             :std_ulogic;
signal rel_dcbt_d               :std_ulogic;
signal rel_dcbt_l2              :std_ulogic;
signal rel_le_mode_l2           :std_ulogic;
signal rel_algebraic_d          :std_ulogic;
signal rel_algebraic_l2         :std_ulogic;
signal rel_lock_en_d            :std_ulogic;
signal rel_lock_en_l2           :std_ulogic;
signal rel_classid_d            :std_ulogic_vector(0 to 1);
signal rel_classid_l2           :std_ulogic_vector(0 to 1);
signal rel_l2only_d             :std_ulogic;
signal rel_l2only_l2            :std_ulogic;
signal rel_l2only_dly_l2        :std_ulogic;
signal rel_dvc1_d               :std_ulogic;
signal rel_dvc1_l2              :std_ulogic;
signal rel_dvc2_d               :std_ulogic;
signal rel_dvc2_l2              :std_ulogic;
signal rel_watch_en_d           :std_ulogic;
signal rel_watch_en_l2          :std_ulogic;
signal lmq_drop_rel_d           :std_ulogic_vector(0 to lmq_entries-1);
signal lmq_drop_rel_l2          :std_ulogic_vector(0 to lmq_entries-1);
signal lmq_dvc1_en_d            :std_ulogic_vector(0 to lmq_entries-1);
signal lmq_dvc2_en_d            :std_ulogic_vector(0 to lmq_entries-1);
signal lmq_dvc1_en_l2           :std_ulogic_vector(0 to lmq_entries-1);
signal lmq_dvc2_en_l2           :std_ulogic_vector(0 to lmq_entries-1);
signal ldq_rel1_val_buf         :std_ulogic;
signal ldq_rel_mid_val_buf      :std_ulogic;
signal ldq_rel3_val_buf         :std_ulogic;
signal ldq_rel_retry_val_buf    :std_ulogic;
signal ldq_rel_data_val_buf     :std_ulogic;
signal ldq_rel_upd_gpr_buf      :std_ulogic;
signal ldq_rel_set_val_buf      :std_ulogic;
signal l2only_from_queue        :std_ulogic;


signal rel_q_entry              :std_ulogic_vector(0 to 33);
signal rel_q_addrlo_58          :std_ulogic;

signal l_m_fnd_stg              :std_ulogic;

signal ld_rel_val_d                     :std_ulogic_vector(0 to lmq_entries-1);
signal ld_rel_val_l2                    :std_ulogic_vector(0 to lmq_entries-1);
signal l_m_q_hit_st_d                   :std_ulogic_vector(0 to lmq_entries-1);
signal l_m_q_hit_st_l2                  :std_ulogic_vector(0 to lmq_entries-1);

signal ex3_new_target_gpr               :std_ulogic_vector(0 to 8);
signal cmd_type_ld                      :std_ulogic_vector(0 to 5);
signal cmd_type_st                      :std_ulogic_vector(0 to 5);
signal load_val                         :std_ulogic;
signal load_l1hit_val                   :std_ulogic;
signal ex4_load_l1hit_val            :std_ulogic;
signal hwsync_val                       :std_ulogic;
signal lwsync_val                       :std_ulogic;
signal mbar_val                         :std_ulogic;
signal ldq_barr_done                 :std_ulogic_vector(0 to 3);
signal ldq_barr_done_l2              :std_ulogic_vector(0 to 3);
signal sync_done_tid                    :std_ulogic_vector(0 to 3);
signal sync_done_tid_l2                 :std_ulogic_vector(0 to 3);
signal lmq_barr_done_tid                :std_ulogic_vector(0 to 3);
signal ldq_barr_active_d                :std_ulogic_vector(0 to 3);
signal ldq_barr_active_l2               :std_ulogic_vector(0 to 3);
signal lmq_collision_t0_d               :std_ulogic_vector(0 to lmq_entries-1);
signal lmq_collision_t0_l2              :std_ulogic_vector(0 to lmq_entries-1);
signal lmq_collision_t1_d               :std_ulogic_vector(0 to lmq_entries-1);
signal lmq_collision_t1_l2              :std_ulogic_vector(0 to lmq_entries-1);
signal lmq_collision_t2_d               :std_ulogic_vector(0 to lmq_entries-1);
signal lmq_collision_t2_l2              :std_ulogic_vector(0 to lmq_entries-1);
signal lmq_collision_t3_d               :std_ulogic_vector(0 to lmq_entries-1);
signal lmq_collision_t3_l2              :std_ulogic_vector(0 to lmq_entries-1);
signal dcbf_l_val                       :std_ulogic;
signal dcbf_g_val                       :std_ulogic;
signal dcbt_l2only_val                  :std_ulogic;
signal dcbt_l1l2_val                    :std_ulogic;
signal dcbtls_l2only_val                :std_ulogic;
signal dcbtls_l1l2_val                  :std_ulogic;
signal dcbtst_l2only_val                :std_ulogic;
signal dcbtst_l1l2_val                  :std_ulogic;
signal dcbtstls_l2only_val              :std_ulogic;
signal dcbtstls_l1l2_val                :std_ulogic;


signal ifetch_req_l2                    :std_ulogic;
signal ifetch_ra_l2                     :std_ulogic_vector(64-real_data_add to 59);
signal ifetch_thread_l2                 :std_ulogic_vector(0 to 3);
signal ifetch_userdef_l2                :std_ulogic_vector(0 to 3);
signal ifetch_wimge_l2                  :std_ulogic_vector(0 to 4);
signal iu_f_tid0_val                    :std_ulogic;
signal iu_f_tid1_val                    :std_ulogic;
signal iu_f_tid2_val                    :std_ulogic;
signal iu_f_tid3_val                    :std_ulogic;
signal iu_seq_rd_incr                   :std_ulogic_vector(0 to 2);
signal iu_seq_rd_d                      :std_ulogic_vector(0 to 2);
signal iu_seq_rd_l2                     :std_ulogic_vector(0 to 2);
signal iu_seq_incr                      :std_ulogic_vector(0 to 2);
signal iu_seq_d                         :std_ulogic_vector(0 to 2);
signal iu_seq_l2                        :std_ulogic_vector(0 to 2);
signal iu_queue_entry                   :std_ulogic_vector(0 to (REAL_IFAR_length+11));
signal iu_f_q0_val_upd                  :std_ulogic_vector(0 to 1);
signal i_f_q0_val_d                     :std_ulogic;
signal i_f_q0_val_l2                    :std_ulogic;
signal i_f_q0_d                         :std_ulogic_vector(0 to (REAL_IFAR_length+11));
signal i_f_q0_l2                        :std_ulogic_vector(0 to (REAL_IFAR_length+11));
signal iu_f_q1_val_upd                  :std_ulogic_vector(0 to 1);
signal i_f_q1_val_d                     :std_ulogic;
signal i_f_q1_val_l2                    :std_ulogic;
signal i_f_q1_d                         :std_ulogic_vector(0 to (REAL_IFAR_length+11));
signal i_f_q1_l2                        :std_ulogic_vector(0 to (REAL_IFAR_length+11));
signal iu_f_q2_val_upd                  :std_ulogic_vector(0 to 1);
signal i_f_q2_val_d                     :std_ulogic;
signal i_f_q2_val_l2                    :std_ulogic;
signal i_f_q2_d                         :std_ulogic_vector(0 to (REAL_IFAR_length+11));
signal i_f_q2_l2                        :std_ulogic_vector(0 to (REAL_IFAR_length+11));
signal iu_f_q3_val_upd                  :std_ulogic_vector(0 to 1);
signal i_f_q3_val_d                     :std_ulogic;
signal i_f_q3_val_l2                    :std_ulogic;
signal i_f_q3_d                         :std_ulogic_vector(0 to (REAL_IFAR_length+11));
signal i_f_q3_l2                        :std_ulogic_vector(0 to (REAL_IFAR_length+11));
signal iu_f_q0_sel                      :std_ulogic;
signal iu_f_q1_sel                      :std_ulogic;
signal iu_f_q2_sel                      :std_ulogic;
signal iu_f_q3_sel                      :std_ulogic;
signal iu_f_q_sel                       :std_ulogic_vector(0 to 1);
signal iu_f_sel_entry                   :std_ulogic_vector(0 to (9+REAL_IFAR_length-1));
signal i_f_q0_sent                      :std_ulogic;
signal i_f_q1_sent                      :std_ulogic;
signal i_f_q2_sent                      :std_ulogic;
signal i_f_q3_sent                      :std_ulogic;
signal iu_val_req                       :std_ulogic;
signal iu_sent_val                      :std_ulogic;
signal sel_if_req                       :std_ulogic;
signal sel_ld_req                       :std_ulogic;
signal sel_mm_req                       :std_ulogic;
signal send_if_req_d                    :std_ulogic;
signal send_if_req_l2                   :std_ulogic;
signal send_ld_req_d                    :std_ulogic;
signal send_ld_req_l2                   :std_ulogic;
signal send_mm_req_d                    :std_ulogic;
signal send_mm_req_l2                   :std_ulogic;
signal iu_f_entry                       :std_ulogic_vector(0 to (real_data_add-1+54));
signal iu_mmu_entry                     :std_ulogic_vector(0 to (real_data_add-1+54));
signal ldmq_entry                       :std_ulogic_vector(0 to (real_data_add-1+54));
signal store_entry                      :std_ulogic_vector(0 to (real_data_add-1+54));
signal st_req                           :std_ulogic_vector(0 to (real_data_add-1+54));
signal ob_store                         :std_ulogic_vector(0 to (real_data_add-1+54));
signal st_recycle_entry                 :std_ulogic_vector(0 to (real_data_add-1+54));
signal st_recycle_d                     :std_ulogic_vector(0 to (real_data_add-1+54));
signal st_recycle_l2                    :std_ulogic_vector(0 to (real_data_add-1+54));
signal st_recycle_act                   :std_ulogic;
signal st_recycle_v_d                   :std_ulogic;
signal st_recycle_v_l2                  :std_ulogic;
signal ld_st_request                    :std_ulogic_vector(0 to (real_data_add-1+54));
signal mmuq_req                         :std_ulogic_vector(0 to (real_data_add-1+54));
signal iu_val                           :std_ulogic;
signal ld_q_val                         :std_ulogic;
signal ld_q_req                         :std_ulogic;
signal state_trans                      :std_ulogic;
signal mmu_q_val                        :std_ulogic;
signal reld_data_vld_l2                 :std_ulogic;
signal reld_data_vld_dplus1_l2          :std_ulogic;

signal load_credit                      :std_ulogic;
signal store_credit                     :std_ulogic;
signal one_st_cred                      :std_ulogic;
signal ld_credit_pre                    :std_ulogic;
signal st_credit_pre                    :std_ulogic;
signal load_credit_used                 :std_ulogic;
signal decr_load_cnt_lcu0               :std_ulogic;
signal dec_by2_ld_cnt_lcu0              :std_ulogic;
signal hold_load_cnt_lcu0               :std_ulogic;
signal incr_load_cnt_lcu1               :std_ulogic;
signal decr_load_cnt_lcu1               :std_ulogic;
signal hold_load_cnt_lcu1               :std_ulogic;
signal load_cmd_count_incr              :std_ulogic_vector(0 to 3);
signal load_cmd_count_decr              :std_ulogic_vector(0 to 3);
signal load_cmd_count_decrby2           :std_ulogic_vector(0 to 3);
signal load_cmd_count_lcu0              :std_ulogic_vector(0 to 3);
signal load_cmd_count_lcu1              :std_ulogic_vector(0 to 3);
signal load_cmd_count_d                 :std_ulogic_vector(0 to 3);
signal load_cmd_count_l2                :std_ulogic_vector(0 to 3);
signal store_cmd_count_incr             :std_ulogic_vector(0 to 5);
signal store_cmd_count_decr             :std_ulogic_vector(0 to 5);
signal store_cmd_count_decby2           :std_ulogic_vector(0 to 5);
signal store_cmd_count_decby3           :std_ulogic_vector(0 to 5);
signal store_cmd_count_d                :std_ulogic_vector(0 to 5);
signal store_cmd_count_l2               :std_ulogic_vector(0 to 5);
signal incr_store_cmd                   :std_ulogic;
signal decr_store_cmd                   :std_ulogic;
signal dec_by2_st_cmd                   :std_ulogic;
signal dec_by3_st_cmd                   :std_ulogic;
signal hold_store_cmd                   :std_ulogic;
signal st_count_ctrl                    :std_ulogic_vector(0 to 3);
signal err_cred_overrun_d               :std_ulogic;
signal err_cred_overrun_l2              :std_ulogic;

signal l2req_resend_d                   :std_ulogic;
signal l2req_resend_l2                  :std_ulogic;
signal l2req_recycle_d                  :std_ulogic;
signal l2req_recycle_l2                 :std_ulogic;
signal l2req_pwr_token                  :std_ulogic;
signal l2req_pwr_token_l2               :std_ulogic;
signal l2req                            :std_ulogic;
signal l2req_gated                      :std_ulogic;
signal l2req_l2                         :std_ulogic;
signal l2req_st_data_ptoken             :std_ulogic;
signal l2req_st_data_ptoken_l2          :std_ulogic;
signal l2req_ra                         :std_ulogic_vector(64-real_data_add to 63);
signal l2req_ra_l2                      :std_ulogic_vector(64-real_data_add to 63);
signal l2req_st_byte_enbl               :std_ulogic_vector(0 to 15+(st_data_32B_mode*16));
signal l2req_st_byte_enbl_l2            :std_ulogic_vector(0 to 15+(st_data_32B_mode*16));
signal l2req_ld_core_tag                :std_ulogic_vector(0 to 4);
signal l2req_ld_core_tag_l2             :std_ulogic_vector(0 to 4);
signal l2req_thread                     :std_ulogic_vector(0 to 2);
signal l2req_thread_l2                  :std_ulogic_vector(0 to 2);
signal l2req_ttype                      :std_ulogic_vector(0 to 5);
signal l2req_ttype_l2                   :std_ulogic_vector(0 to 5);
signal l2req_wimg                       :std_ulogic_vector(0 to 3);
signal l2req_wimg_l2                    :std_ulogic_vector(0 to 3);
signal l2req_ld_xfr_len                 :std_ulogic_vector(0 to 2);
signal l2req_ld_xfr_len_l2              :std_ulogic_vector(0 to 2);
signal l2req_endian                     :std_ulogic;
signal l2req_endian_l2                  :std_ulogic;
signal l2req_user                       :std_ulogic_vector(0 to 3);
signal l2req_user_l2                    :std_ulogic_vector(0 to 3);
signal ex4_st_data_mux                  :std_ulogic_vector(0 to 127+(st_data_32B_mode*128));
signal ex4_st_data_mux2                 :std_ulogic_vector(0 to 127+(st_data_32B_mode*128));
signal ex5_st_data_mux1                 :std_ulogic_vector(0 to 127);
signal ex5_st_data_mux2                 :std_ulogic_vector(0 to 127);
signal ex5_st_data_mux                  :std_ulogic_vector(0 to 127+(st_data_32B_mode*128));
signal ex5_st_data_l2                   :std_ulogic_vector(0 to 127+(st_data_32B_mode*128));
signal ex6_st_data_l2                   :std_ulogic_vector(0 to 127+(st_data_32B_mode*128));

signal sync_done                        :std_ulogic;
signal rel_tag_l2                       :std_ulogic_vector(1 to 4);
signal rel_tag_dplus1_l2                :std_ulogic_vector(1 to 4);
signal rel_data_val                     :std_ulogic_vector(0 to lmq_entries-1);
signal start_rel                        :std_ulogic_vector(0 to lmq_entries-1);
signal rel_data_val_dplus1              :std_ulogic_vector(0 to lmq_entries-1);
signal set_data_ecc_err                 :std_ulogic_vector(0 to lmq_entries-1);
signal data_ecc_err_d                   :std_ulogic_vector(0 to lmq_entries-1);
signal data_ecc_err_l2                  :std_ulogic_vector(0 to lmq_entries-1);
signal set_data_ecc_ue                  :std_ulogic_vector(0 to lmq_entries-1);
signal data_ecc_ue_d                    :std_ulogic_vector(0 to lmq_entries-1);
signal data_ecc_ue_l2                   :std_ulogic_vector(0 to lmq_entries-1);
signal rel_tag_1hot                     :std_ulogic_vector(0 to lmq_entries-1);
signal I1_G1_thrd0                      :std_ulogic;
signal I1_G1_thrd1                      :std_ulogic;
signal I1_G1_thrd2                      :std_ulogic;
signal I1_G1_thrd3                      :std_ulogic;
signal I1_G1_flush                      :std_ulogic;
signal ex4_l2cmdq_flush_d               :std_ulogic_vector(0 to 4);
signal ex4_l2cmdq_flush_l2              :std_ulogic_vector(0 to 4);
signal ex4_st_I1_G1_val                 :std_ulogic;
signal st_entry_I1_G1_val               :std_ulogic;
signal ex3_wimg_g_gated                 :std_ulogic;
signal ecc_err                          :std_ulogic_vector(0 to lmq_entries-1);
signal rel_vpr_compl                    :std_ulogic;
signal rel_compl                        :std_ulogic;
signal update_gpr                       :std_ulogic;
signal update_gpr_l2                    :std_ulogic;
signal set_gpr_updated_prev             :std_ulogic_vector(0 to lmq_entries-1);
signal selectedQ_gpr_update_prev        :std_ulogic;
signal selectedQ_ecc_err                :std_ulogic;
signal rel_beat_crit_qw_block_d         :std_ulogic;
signal gpr_updated_prev_d               :std_ulogic_vector(0 to lmq_entries-1);
signal gpr_updated_prev_l2              :std_ulogic_vector(0 to lmq_entries-1);
signal gpr_updated_dly1_d               :std_ulogic_vector(0 to lmq_entries-1);
signal gpr_updated_dly2_d               :std_ulogic_vector(0 to lmq_entries-1);
signal gpr_updated_dly1_l2              :std_ulogic_vector(0 to lmq_entries-1);
signal gpr_updated_dly2_l2              :std_ulogic_vector(0 to lmq_entries-1);
signal set_gpr_ecc_err                  :std_ulogic_vector(0 to lmq_entries-1);
signal reset_gpr_ecc_err                :std_ulogic_vector(0 to lmq_entries-1);
signal gpr_ecc_err_d                    :std_ulogic_vector(0 to lmq_entries-1);
signal gpr_ecc_err_l2                   :std_ulogic_vector(0 to lmq_entries-1);
signal complete_qentry                  :std_ulogic_vector(0 to lmq_entries-1);
signal even_beat                        :std_ulogic_vector(0 to lmq_entries-1);
signal ldm_complete_qentry              :std_ulogic_vector(0 to lmq_entries-1);
signal ldm_comp_qentry_l2               :std_ulogic_vector(0 to lmq_entries-1);
signal ci_16B_comp_qentry               :std_ulogic_vector(0 to lmq_entries-1);
signal larx_done                        :std_ulogic_vector(0 to lmq_entries-1);
signal complete_tid_d                   :std_ulogic_vector(0 to 3);       
signal larx_done_tid_d                  :std_ulogic_vector(0 to 3);
signal larx_done_tid_l2                 :std_ulogic_vector(0 to 3);       
signal complete_target_type_d           :std_ulogic_vector(0 to 1);       

signal mmq_act                  :std_ulogic;
signal mmu_q_val_d              :std_ulogic;
signal mmu_q_val_l2             :std_ulogic;
signal mm_req_val_d             :std_ulogic;
signal mm_req_val_l2            :std_ulogic;
signal mmu_command              :std_ulogic_vector(0 to (25+real_data_add));
signal mmu_q_entry_d            :std_ulogic_vector(0 to (25+real_data_add));
signal mmu_q_entry_l2           :std_ulogic_vector(0 to (25+real_data_add));

signal my_beat1                :std_ulogic;
signal my_beat1_early          :std_ulogic;
signal my_beat_last_d              :std_ulogic;
signal my_beat_last_l2             :std_ulogic;
signal my_beat_mid                :std_ulogic;
signal my_beat_odd                :std_ulogic;
signal my_noncache_beat        :std_ulogic;
signal my_ldq_retry        :std_ulogic;

signal rel_A_data_d        :std_ulogic_vector(0 to 127);
signal rel_A_data_l2       :std_ulogic_vector(0 to 127);
signal rel_B_data_d        :std_ulogic_vector(0 to 127);
signal rel_B_data_l2       :std_ulogic_vector(0 to 127);
signal set_rel_A_data           :std_ulogic;
signal set_rel_B_data           :std_ulogic;
signal send_rel_A_data_d        :std_ulogic;
signal send_rel_A_data_l2       :std_ulogic;

signal anaclat_data_coming      :std_ulogic;
signal anaclat_reld_crit_qw     :std_ulogic;
signal anaclat_data_val         :std_ulogic;
signal anaclat_ditc             :std_ulogic;
signal anaclat_tag              :std_ulogic_vector(0 to 4);
signal anaclat_qw               :std_ulogic_vector(57 to 59);
signal anaclat_data             :std_ulogic_vector(0 to 127);
signal anaclat_ecc_err          :std_ulogic;
signal anaclat_ecc_err_ue       :std_ulogic;
signal beat_ecc_err             :std_ulogic;
signal ue_mchk_v                :std_ulogic;
signal ue_mchk_valid_d          :std_ulogic_vector(0 to 3);
signal ue_mchk_valid_l2         :std_ulogic_vector(0 to 3);
signal anaclat_l1_dump          :std_ulogic;
signal dminus1_l1_dump          :std_ulogic;
signal dminus1_l1_dump_gated    :std_ulogic;
signal l1_dump                  :std_ulogic;
signal anaclat_back_inv         :std_ulogic;
signal anaclat_back_inv_addr    :std_ulogic_vector(64-real_data_add to 63);
signal anaclat_back_inv_target_1 :std_ulogic;
signal anaclat_back_inv_target_4 :std_ulogic;
signal anaclat_ld_pop           :std_ulogic;
signal anaclat_st_pop           :std_ulogic;
signal anaclat_st_pop_thrd      :std_ulogic_vector(0 to 2);
signal anaclat_st_gather        :std_ulogic;
signal anaclat_coreid           :std_ulogic_vector(6 to 7);
signal data_val_for_rel         :std_ulogic;
signal data_val_dminus2         :std_ulogic;
signal data_val_dminus1_l2      :std_ulogic;
signal ldq_rel_retry_val_l2     :std_ulogic;
signal ldq_rel_retry_val_dly_l2 :std_ulogic;
signal rel_intf_v_dminus1_l2    :std_ulogic;
signal rel_intf_v_l2            :std_ulogic;
signal rel_intf_v_dplus1_l2     :std_ulogic;
signal tag_dminus2              :std_ulogic_vector(1 to 4);
signal ldq_retry_tag            :std_ulogic_vector(1 to 4);
signal tag_dminus1_l2           :std_ulogic_vector(1 to 4);
signal tag_dminus1_cpy_l2       :std_ulogic_vector(2 to 4);
signal tag_dminus1_act          :std_ulogic;
signal tag_dminus1_1hot_d       :std_ulogic_vector(0 to lmq_entries-1);
signal tag_dminus1_1hot_l2      :std_ulogic_vector(0 to lmq_entries-1);
signal qw_dminus1_l2            :std_ulogic_vector(57 to 59);
signal qw_l2                    :std_ulogic_vector(57 to 59);
signal back_inv_val_d           :std_ulogic;
signal back_inv_val_l2          :std_ulogic;
signal dbell_val_d              :std_ulogic;
signal dbell_val_l2             :std_ulogic;
signal lpidr_l2                 :std_ulogic_vector(0 to 7);
signal rel_set_val              :std_ulogic_vector(0 to lmq_entries-1);
signal rel_cacheable            :std_ulogic_vector(0 to lmq_entries-1);
signal rel_set_val_or           :std_ulogic;
signal lmq_back_invalidated_d   :std_ulogic_vector(0 to lmq_entries-1);
signal lmq_back_invalidated_l2  :std_ulogic_vector(0 to lmq_entries-1);

signal ex3_loadmiss_qentry       :std_ulogic_vector(0 to lmq_entries-1);       -- Load Miss Queue entry
signal ex4_loadmiss_qentry       :std_ulogic_vector(0 to lmq_entries-1);       -- Load Miss Queue entry
signal ex5_loadmiss_qentry_d     :std_ulogic_vector(0 to lmq_entries-1);       -- Load Miss Queue entry
signal ex6_loadmiss_qentry_d     :std_ulogic_vector(0 to lmq_entries-1);       -- Load Miss Queue entry
signal ex7_loadmiss_qentry_d     :std_ulogic_vector(0 to lmq_entries-1);       -- Load Miss Queue entry
signal ex5_loadmiss_qentry       :std_ulogic_vector(0 to lmq_entries-1);       -- Load Miss Queue entry
signal ex6_loadmiss_qentry       :std_ulogic_vector(0 to lmq_entries-1);       -- Load Miss Queue entry
signal ex7_loadmiss_qentry       :std_ulogic_vector(0 to lmq_entries-1);       -- Load Miss Queue entry
signal ex3_loadmiss_target       :std_ulogic_vector(0 to 8);       -- target gpr
signal ex3_loadmiss_target_type  :std_ulogic_vector(0 to 1);
signal ex3_loadmiss_tid          :std_ulogic_vector(0 to 3);
signal ex4_loadmiss_tid          :std_ulogic_vector(0 to 3);
signal ex4_loadmiss_target       :std_ulogic_vector(0 to 8);       -- target gpr
signal ex4_loadmiss_target_type  :std_ulogic_vector(0 to 1);
signal ex4_loadmiss_tid_gated1   :std_ulogic_vector(0 to 3);
signal ex4_loadmiss_tid_gated    :std_ulogic_vector(0 to 3);
signal ex5_loadmiss_tid          :std_ulogic_vector(0 to 3);

signal xu_mm_lmq_stq_empty_d     :std_ulogic;
signal lmq_empty                 :std_ulogic;
signal pe_recov_empty_d          :std_ulogic;
signal pe_recov_empty_l2         :std_ulogic;

signal err_l2intrf_ecc_d         :std_ulogic;
signal err_l2intrf_ue_d          :std_ulogic;
signal err_l2intrf_ecc_l2        :std_ulogic;
signal err_l2intrf_ue_l2         :std_ulogic;

signal src0_hit                  :std_ulogic_vector(0 to lmq_entries-1);
signal src1_hit                  :std_ulogic_vector(0 to lmq_entries-1);
signal targ_hit                  :std_ulogic_vector(0 to lmq_entries-1);
signal watch_bit_v_t0            :std_ulogic_vector(0 to lmq_entries-1);
signal watch_bit_v_t1            :std_ulogic_vector(0 to lmq_entries-1);
signal watch_bit_v_t2            :std_ulogic_vector(0 to lmq_entries-1);
signal watch_bit_v_t3            :std_ulogic_vector(0 to lmq_entries-1);
signal ex1_lm_dep_hit            :std_ulogic;
signal ex2_lm_dep_hit_buf        :std_ulogic;
signal watch_hit_t0              :std_ulogic;
signal watch_hit_t1              :std_ulogic;
signal watch_hit_t2              :std_ulogic;
signal watch_hit_t3              :std_ulogic;
signal watch_hit                 :std_ulogic;

signal lq_rd_en_is_ex5           :std_ulogic;
signal lq_rd_en_is_ex6           :std_ulogic;


signal lmq_quiesce               :std_ulogic_vector(0 to 3);
signal mmu_quiesce               :std_ulogic_vector(0 to 3);
signal stq_quiesce               :std_ulogic_vector(0 to 3);
signal quiesce_d                 :std_ulogic_vector(0 to 3);

signal ex3_flush_all             :std_ulogic;
signal ex4_flush_load            :std_ulogic;
signal ex4_flush_load_wo_drop    :std_ulogic;
signal ex4_flush_store           :std_ulogic;
signal ex5_load                  :std_ulogic;
signal ex6_load_sent_l2          :std_ulogic;
signal ex6_store_sent_l2         :std_ulogic;
signal ex5_flush_d                :std_ulogic;
signal ex5_flush_l2               :std_ulogic;
signal my_ex5_flush               :std_ulogic;
signal ex5_flush_load_all        :std_ulogic;
signal ex5_flush_load_local      :std_ulogic;
signal ex4_p_addr_59              :std_ulogic;
signal ex5_stg_flush              :std_ulogic;
signal ex5_flush_store            :std_ulogic;
signal my_ex5_flush_store         :std_ulogic;
signal ex6_flush_l2               :std_ulogic;


signal copy_st_be_for_16B_mode   :std_ulogic;
signal copy_st_data_for_16B_mode :std_ulogic;

signal err_invld_reld_d          :std_ulogic;
signal err_invld_reld_l2         :std_ulogic;

signal ex7_ld_par_err            :std_ulogic;
signal ex8_ld_par_err_l2         :std_ulogic;
signal ex4_ld_queue_full         :std_ulogic;
signal ex4_ld_queue_full_l2      :std_ulogic;
signal ex5_ld_queue_full_d       :std_ulogic;
signal ex5_ld_queue_full_l2      :std_ulogic;
signal ex4_st_queue_full         :std_ulogic;
signal ex4_st_queue_full_l2      :std_ulogic;
signal ex5_st_queue_full_l2      :std_ulogic;
signal ex4_ldhld_sthld_coll      :std_ulogic;
signal ex5_ldhld_sthld_coll_l2   :std_ulogic;
signal ex3_i1_g1_coll            :std_ulogic;
signal ex4_i1_g1_coll_l2         :std_ulogic;
signal ex5_i1_g1_coll_l2         :std_ulogic;
signal ld_miss_latency_d         :std_ulogic;
signal ld_miss_latency_l2        :std_ulogic;
signal lsu_perf_events           :std_ulogic_vector(0 to 3);
signal lsu_perf_events_l2        :std_ulogic_vector(0 to 3);
signal ex3_val_req               :std_ulogic;
signal ex4_val_req               :std_ulogic;
signal ex4_thrd_encode           :std_ulogic_vector(0 to 1);
signal ex4_thrd_id               :std_ulogic_vector(0 to 3);
signal ex5_thrd_id               :std_ulogic_vector(0 to 3);

signal ob_pwr_tok_l2             :std_ulogic;
signal ob_req_val_mux            :std_ulogic;
signal ob_req_val_l2             :std_ulogic;
signal ob_req_val_clone_l2       :std_ulogic;
signal ob_ditc_val_mux           :std_ulogic;
signal ob_ditc_val_l2            :std_ulogic;
signal ob_ditc_val_clone_l2      :std_ulogic;
signal ob_thrd_mux               :std_ulogic_vector(0 to 1);
signal ob_thrd_l2                :std_ulogic_vector(0 to 1);
signal ob_qw_mux                 :std_ulogic_vector(58 to 59);
signal ob_qw_l2                  :std_ulogic_vector(58 to 59);
signal ob_dest_mux               :std_ulogic_vector(0 to 14);
signal ob_dest_l2                :std_ulogic_vector(0 to 14);
signal ob_addr_mux               :std_ulogic_vector(64-real_data_add to 57);
signal ob_addr_l2                :std_ulogic_vector(64-real_data_add to 57);
signal ob_data_mux               :std_ulogic_vector(0 to 127);
signal ob_data_l2                :std_ulogic_vector(0 to 127);
signal bx_cmd_sent_d             :std_ulogic;
signal bx_cmd_sent_l2            :std_ulogic;
signal bx_cmd_stall_d            :std_ulogic;
signal bx_cmd_stall_l2           :std_ulogic;
signal bx_stall_dly_or           :std_ulogic;
signal bx_stall_dly_d            :std_ulogic_vector(0 to 3);
signal bx_stall_dly_l2           :std_ulogic_vector(0 to 3);
signal msr_gs_l2                 :std_ulogic_vector(0 to 3);
signal msr_pr_l2                 :std_ulogic_vector(0 to 3);
signal msr_ds_l2                 :std_ulogic_vector(0 to 3);
signal msr_hv                    :std_ulogic;
signal msr_pr                    :std_ulogic;
signal msr_ds                    :std_ulogic;
signal pid                       :std_ulogic_vector(0 to 13);
signal pid0_l2                   :std_ulogic_vector(0 to 13);
signal pid1_l2                   :std_ulogic_vector(0 to 13);
signal pid2_l2                   :std_ulogic_vector(0 to 13);
signal pid3_l2                   :std_ulogic_vector(0 to 13);
signal ditc_dat                  :std_ulogic_vector(0 to 127);
signal ex4_icswx_extra_data      :std_ulogic_vector(0 to 24);
signal stq_icswx_extra_data_d    :std_ulogic_vector(0 to 24);
signal stq_icswx_extra_data_l2   :std_ulogic_vector(0 to 24);
signal icswx_dat                 :std_ulogic_vector(0 to 127);
signal epsc_epr                  :std_ulogic;
signal epsc_eas                  :std_ulogic;
signal epsc_egs                  :std_ulogic;
signal epsc_elpid                :std_ulogic_vector(40 to 47);
signal epsc_epid                 :std_ulogic_vector(50 to 63);

signal my_xucr0_d                :std_ulogic_vector(0 to 5);
signal my_xucr0_l2               :std_ulogic_vector(0 to 5);
signal my_xucr0_rel              :std_ulogic;
signal my_xucr0_l2siw            :std_ulogic;
signal my_xucr0_cred             :std_ulogic;
signal my_xucr0_mbar_ack         :std_ulogic;
signal my_xucr0_tlbsync          :std_ulogic;
signal my_xucr0_cls              :std_ulogic;

signal ex3_p_addr                :std_ulogic_vector(64-real_data_add to 63);

signal clkg_ctl_override_q       :std_ulogic;
signal ldq_active_d              :std_ulogic;
signal ldq_active_l2             :std_ulogic;
signal ldq_active_dly_d          :std_ulogic;
signal ldq_active_dly_l2         :std_ulogic;
signal ldq_act                   :std_ulogic;
signal stq_active_d              :std_ulogic;
signal stq_active_l2             :std_ulogic;
signal stq_act                   :std_ulogic;
signal lmq_entry_act             :std_ulogic;
signal ifetch_act                :std_ulogic;
signal iuq_act                   :std_ulogic;
signal ob_act                    :std_ulogic;
signal pe_act                    :std_ulogic;
signal dminus1_act               :std_ulogic;
signal dplus1_act                :std_ulogic;
signal rel_data_act              :std_ulogic;
signal bi_act                    :std_ulogic;
signal ex6_ld_recov_act          :std_ulogic;
signal ex7_ld_recov_act          :std_ulogic;
signal ex8_ld_recov_act          :std_ulogic;
signal l2req_act                 :std_ulogic;
signal st_data_act               :std_ulogic;

signal data_val_for_drel         :std_ulogic;
signal data_val_for_recirc       :std_ulogic;

signal spare_0_lclk                  :clk_logic;
signal spare_1_lclk                  :clk_logic;
signal spare_4_lclk                  :clk_logic;
signal spare_0_d1clk                  :std_ulogic;
signal spare_1_d1clk                  :std_ulogic;
signal spare_4_d1clk                  :std_ulogic;
signal spare_0_d2clk                  :std_ulogic;
signal spare_1_d2clk                  :std_ulogic;
signal spare_4_d2clk                  :std_ulogic;
signal spare_0_d                  :std_ulogic_vector(0 to 7);
signal spare_1_d                  :std_ulogic_vector(0 to 4);
signal spare_4_d                  :std_ulogic_vector(0 to 7);
signal spare_0_l2                 :std_ulogic_vector(0 to 7);
signal spare_1_l2                 :std_ulogic_vector(0 to 4);
signal spare_4_l2                 :std_ulogic_vector(0 to 7);

signal dbg_d                     :std_ulogic_vector(0 to 40+lmq_entries-1);
signal dbg_L2                    :std_ulogic_vector(0 to 40+lmq_entries-1);


signal unused                    :std_ulogic_vector(0 to 3);

constant clkg_ctl_override_offset         : natural := 0;
constant ldq_active_offset                : natural :=clkg_ctl_override_offset   + 1;
constant ldq_active_dly_offset            : natural :=ldq_active_offset          + 1;
constant stq_active_offset                : natural :=ldq_active_dly_offset      + 1;
constant ex7_ld_par_err_offset            : natural :=stq_active_offset          + 1;
constant ex8_ld_par_err_offset            : natural :=ex7_ld_par_err_offset      + 1;
constant my_ex4_flush_offset              : natural :=ex8_ld_par_err_offset      + 1;
constant pe_recov_empty_offset            : natural :=my_ex4_flush_offset        + 1;
constant pe_recov_state_offset            : natural :=pe_recov_empty_offset       + 1;

constant pe_recov_state_dly_offset        : natural :=pe_recov_state_offset      + 1;
constant pe_recov_ld_num_offset           : natural :=pe_recov_state_dly_offset  + 1;

constant pe_recov_ld_val_offset           : natural :=pe_recov_ld_num_offset     + pe_recov_ld_num_l2'length;
constant my_xucr0_offset                  : natural :=pe_recov_ld_val_offset     + 1;
constant anac_data_coming_offset          : natural :=my_xucr0_offset            + my_xucr0_l2'length;
constant anac_reld_crit_qw_offset         : natural :=anac_data_coming_offset    + 1;
constant anac_data_val_offset             : natural :=anac_reld_crit_qw_offset    + 1;
constant anac_ditc_offset                 : natural :=anac_data_val_offset       + 1;
constant anac_tag_offset                  : natural :=anac_ditc_offset           + 1;
constant anac_qw_offset                   : natural :=anac_tag_offset            + anaclat_tag'length;
constant anac_data_offset                 : natural :=anac_qw_offset             + anaclat_qw'length;
constant anac_ecc_err_offset              : natural :=anac_data_offset           + anaclat_data'length;
constant anac_ecc_err_ue_offset           : natural :=anac_ecc_err_offset        + 1;
constant ue_mchk_val_offset               : natural := anac_ecc_err_ue_offset    + 1;
constant anac_l1_dump_offset              : natural := ue_mchk_val_offset        + ue_mchk_valid_l2'length;
constant dminus1_l1_dump_offset           : natural := anac_l1_dump_offset       + 1;
constant l1_dump_offset                   : natural := dminus1_l1_dump_offset    + 1;
constant anac_back_inv_offset             : natural := l1_dump_offset            + 1;
constant anac_back_inv_addr_offset        : natural := anac_back_inv_offset      + 1;
constant anac_back_inv_target1_offset     : natural := anac_back_inv_addr_offset + anaclat_back_inv_addr'length;
constant anac_back_inv_target4_offset     : natural :=anac_back_inv_target1_offset + 1;
constant data_val_dminus1_offset          : natural :=anac_back_inv_target4_offset + 1;
constant spare_0_offset                   : natural :=data_val_dminus1_offset      + 1;
constant ldq_rel_retry_val_offset         : natural :=spare_0_offset               + spare_0_l2'length;
constant ldq_rel_retry_val_dly_offset     : natural :=ldq_rel_retry_val_offset     + 1;
constant rel_intf_v_dminus1_offset        : natural :=ldq_rel_retry_val_dly_offset  + 1;
constant rel_intf_v_offset                : natural :=rel_intf_v_dminus1_offset     + 1;
constant rel_intf_v_dplus1_offset         : natural :=rel_intf_v_offset             + 1;
constant retry_started_offset             : natural :=rel_intf_v_dplus1_offset   + 1;

constant tag_dminus1_offset               : natural :=retry_started_offset       + retry_started_l2'length;
constant tag_dminus1_cpy_offset           : natural :=tag_dminus1_offset         + tag_dminus1_l2'length;
constant tag_dminus1_1hot_offset          : natural :=tag_dminus1_cpy_offset     + tag_dminus1_cpy_l2'length;
constant qw_dminus1_offset                : natural :=tag_dminus1_1hot_offset    + tag_dminus1_1hot_l2'length;

constant qw_offset                        : natural :=qw_dminus1_offset          + qw_dminus1_l2'length;
constant back_inv_val_offset              : natural :=qw_offset                  + qw_l2'length;
constant dbell_val_offset                 : natural :=back_inv_val_offset       + 1;
constant anac_ld_pop_offset               : natural :=dbell_val_offset          + 1;
constant anac_st_pop_offset               : natural :=anac_ld_pop_offset        + 1;
constant anac_st_pop_thrd_offset          : natural :=anac_st_pop_offset        + 1;
constant anac_st_gather_offset            : natural :=anac_st_pop_thrd_offset   + anaclat_st_pop_thrd'length;
constant coreid_offset                    : natural :=anac_st_gather_offset     + 1;
constant stcx_complete_offset             : natural :=coreid_offset              + anaclat_coreid'length;
constant xu_iu_reld_core_tag_offset       : natural :=stcx_complete_offset       + xu_iu_stcx_complete'length;
constant xu_iu_reld_data_vld_offset       : natural :=xu_iu_reld_core_tag_offset + xu_iu_reld_core_tag_clone'length;
constant xu_iu_reld_data_coming_offset    : natural :=xu_iu_reld_data_vld_offset    + 1;
constant xu_iu_reld_ditc_offset           : natural :=xu_iu_reld_data_coming_offset + 1;
constant lpidr_offset                     : natural :=xu_iu_reld_ditc_offset     + 1;
constant cmd_seq_offset                   : natural :=lpidr_offset               + lpidr_l2'length;
constant cmd_seq_rd_offset                : natural :=cmd_seq_offset             + cmd_seq_l2'length;
constant ex4_load_l1hit_val_offset        : natural :=cmd_seq_rd_offset          + cmd_seq_rd_l2'length;
constant ex4_st_val_offset                : natural :=ex4_load_l1hit_val_offset  + 1;
constant ex5_st_val_offset                : natural :=ex4_st_val_offset          + 1;
constant ex6_st_val_offset                : natural :=ex5_st_val_offset          + 1;
constant st_entry0_val_offset             : natural :=ex6_st_val_offset          + 1;
constant st_entry0_val_clone_offset       : natural :=st_entry0_val_offset       + 1;
constant ex4_st_entry_offset              : natural :=st_entry0_val_clone_offset + 1;
constant s_m_queue0_offset                : natural :=ex4_st_entry_offset        + ex4_st_entry_l2'length;


constant ex4_ld_m_val_offset              : natural :=s_m_queue0_offset          + s_m_queue0'length;

constant spare_1_offset                    : natural :=ex4_ld_m_val_offset        + 1;
constant ex4_classid_offset                : natural :=spare_1_offset              + spare_1_l2'length;
constant ex4_ld_entry_hit_st_offset        : natural :=ex4_classid_offset          + ex4_classid_l2'length;
constant ex4_drop_ld_req_offset            : natural :=ex4_ld_entry_hit_st_offset  + 1;

constant ex4_drop_touch_offset            : natural :=ex4_drop_ld_req_offset     + 1;
constant lmq_drop_rel_offset              : natural :=ex4_drop_touch_offset      + 1;

constant lmq_dvc1_en_offset               : natural :=lmq_drop_rel_offset        + lmq_drop_rel_l2'length;
constant lmq_dvc2_en_offset               : natural :=lmq_dvc1_en_offset         + lmq_dvc1_en_l2'length;
constant l_m_queue_offset                 : natural :=lmq_dvc2_en_offset         + lmq_dvc2_en_l2'length;
-- scan 1
constant l_m_queue_addrlo_offset          : natural :=l_m_queue_offset           + lmq_entries * l_m_queue(0)'length;
constant ex4_ld_recov_offset              : natural :=l_m_queue_addrlo_offset    + lmq_entries * l_m_queue_addrlo(0)'length;
constant ex4_ld_recov_val_offset          : natural :=ex4_ld_recov_offset        + ex4_ld_entry_l2'length;
constant ex5_ld_recov_offset              : natural :=ex4_ld_recov_val_offset    + 1;
constant ex6_ld_recov_offset              : natural :=ex5_ld_recov_offset        + ex5_ld_recov_l2'length;
constant ex7_ld_recov_offset              : natural :=ex6_ld_recov_offset        + ex6_ld_recov_l2'length;
constant ex5_ld_recov_extra_offset        : natural :=ex7_ld_recov_offset        + ex7_ld_recov_l2'length;
constant ex6_ld_recov_extra_offset        : natural :=ex5_ld_recov_extra_offset  + ex5_ld_recov_extra_l2'length;
constant ex7_ld_recov_extra_offset        : natural :=ex6_ld_recov_extra_offset  + ex6_ld_recov_extra_l2'length;
constant ex8_ld_recov_extra_offset        : natural :=ex7_ld_recov_extra_offset  + ex7_ld_recov_extra_l2'length;
constant ex5_ld_recov_val_offset          : natural :=ex8_ld_recov_extra_offset  + ex8_ld_recov_extra_l2'length;
constant ex6_ld_recov_val_offset          : natural :=ex5_ld_recov_val_offset    + 1;
constant ex7_ld_recov_val_offset          : natural :=ex6_ld_recov_val_offset    + 1;
constant st_hit_recov_ld_offset           : natural :=ex7_ld_recov_val_offset    + 1;
constant l_m_fnd_offset                   : natural :=st_hit_recov_ld_offset   + 1;
constant ex4_lmq_cpy_offset               : natural :=l_m_fnd_offset             + 1;
constant ex5_lmq_cpy_offset               : natural :=ex4_lmq_cpy_offset         + ex4_lmq_cpy_l2'length;
constant lm_dep_hit_offset                : natural :=ex5_lmq_cpy_offset         + ex5_lmq_cpy_l2'length;
constant lmq_back_invalidated_offset      : natural :=lm_dep_hit_offset          + 1;
constant ld_entry_val_offset              : natural :=lmq_back_invalidated_offset + lmq_back_invalidated_l2'length;
constant ld_rel_val_offset                : natural :=ld_entry_val_offset        + ld_entry_val_l2'length;
constant l_m_q_hit_st_offset              : natural :=ld_rel_val_offset          + ld_rel_val_l2'length;
constant ifetch_req_offset                : natural :=l_m_q_hit_st_offset        + l_m_q_hit_st_l2'length;
constant ifetch_ra_offset                 : natural :=ifetch_req_offset          + 1;
constant ifetch_wimge_offset              : natural :=ifetch_ra_offset           + ifetch_ra_l2'length;
constant ifetch_thread_offset             : natural :=ifetch_wimge_offset        + ifetch_wimge_l2'length;
constant ifetch_userdef_offset            : natural :=ifetch_thread_offset       + ifetch_thread_l2'length;
constant iu_seq_offset                    : natural :=ifetch_userdef_offset      + ifetch_userdef_l2'length;
constant iu_seq_rd_offset                 : natural :=iu_seq_offset              + iu_seq_l2'length;
constant i_f_q0_val_offset                : natural :=iu_seq_rd_offset           + iu_seq_rd_l2'length;
constant i_f_q0_offset                    : natural :=i_f_q0_val_offset          + 1;
constant i_f_q1_val_offset                : natural :=i_f_q0_offset              + i_f_q0_l2'length;
constant i_f_q1_offset                    : natural :=i_f_q1_val_offset          + 1;
constant i_f_q2_val_offset                : natural :=i_f_q1_offset              + i_f_q1_l2'length;
constant i_f_q2_offset                    : natural :=i_f_q2_val_offset          + 1;
constant i_f_q3_val_offset                : natural :=i_f_q2_offset              + i_f_q2_l2'length;
constant i_f_q3_offset                    : natural :=i_f_q3_val_offset          + 1;
constant mm_req_val_offset                : natural :=i_f_q3_offset              + i_f_q3_l2'length;
constant mmu_q_val_offset                 : natural :=mm_req_val_offset          + 1;
constant mmu_q_entry_offset               : natural :=mmu_q_val_offset           + 1;
constant cred_overrun_offset              : natural :=mmu_q_entry_offset         + mmu_q_entry_l2'length;
constant reld_ditc_pop_offset             : natural :=cred_overrun_offset        + 1;
constant bx_ib_empty_offset               : natural :=reld_ditc_pop_offset       + ac_an_reld_ditc_pop_q'length;
constant send_if_req_offset               : natural :=bx_ib_empty_offset         + bx_ib_empty_q'length;
constant send_ld_req_offset               : natural :=send_if_req_offset         + 1;
constant send_mm_req_offset               : natural :=send_ld_req_offset         + 1;
constant l_m_rel_hit_beat0_offset         : natural :=send_mm_req_offset         + 1;
constant l_m_rel_hit_beat1_offset         : natural :=l_m_rel_hit_beat0_offset   + l_m_rel_hit_beat0_l2'length;
constant l_m_rel_hit_beat2_offset         : natural :=l_m_rel_hit_beat1_offset   + l_m_rel_hit_beat1_l2'length;
constant l_m_rel_hit_beat3_offset         : natural :=l_m_rel_hit_beat2_offset   + l_m_rel_hit_beat2_l2'length;
constant l_m_rel_hit_beat4_offset         : natural :=l_m_rel_hit_beat3_offset   + l_m_rel_hit_beat3_l2'length;
constant l_m_rel_hit_beat5_offset         : natural :=l_m_rel_hit_beat4_offset   + l_m_rel_hit_beat4_l2'length;
constant l_m_rel_hit_beat6_offset         : natural :=l_m_rel_hit_beat5_offset   + l_m_rel_hit_beat5_l2'length;
constant l_m_rel_hit_beat7_offset         : natural :=l_m_rel_hit_beat6_offset   + l_m_rel_hit_beat6_l2'length;
constant l_m_rel_inprog_offset            : natural :=l_m_rel_hit_beat7_offset   + l_m_rel_hit_beat7_l2'length;
constant l_m_rel_c_i_beat0_offset         : natural :=l_m_rel_inprog_offset        + l_m_rel_inprog_l2'length;
constant l_m_rel_c_i_val_offset           : natural :=l_m_rel_c_i_beat0_offset        + l_m_rel_c_i_beat0_l2'length;
constant rel_addr_offset                  : natural :=l_m_rel_c_i_val_offset     + l_m_rel_val_c_i_dly'length;
constant rel_size_offset                  : natural :=rel_addr_offset            + rel_addr_l2'length;
constant rel_cache_inh_offset             : natural :=rel_size_offset            + rel_size_l2'length;
constant rel_rot_sel_offset               : natural :=rel_cache_inh_offset       + 1;
constant rel_th_id_offset                 : natural :=rel_rot_sel_offset         + rel_rot_sel_l2'length;
constant rel_tar_gpr_offset               : natural :=rel_th_id_offset           + rel_th_id_l2'length;
constant rel_vpr_val_offset               : natural :=rel_tar_gpr_offset         + rel_tar_gpr_l2'length;
constant rel_le_mode_offset               : natural :=rel_vpr_val_offset         + 1;
constant rel_dcbt_offset                  : natural :=rel_le_mode_offset         + 1;
constant rel_algebraic_offset             : natural :=rel_dcbt_offset            + 1;
constant rel_l2only_offset                : natural :=rel_algebraic_offset       + 1;
constant rel_l2only_dly_offset            : natural :=rel_l2only_offset          + 1;
constant rel_lock_en_offset               : natural :=rel_l2only_dly_offset      + 1;
constant rel_classid_offset               : natural :=rel_lock_en_offset         + 1;
constant rel_dvc1_offset                  : natural :=rel_classid_offset         + rel_classid_l2'length; 
constant rel_dvc2_offset                  : natural :=rel_dvc1_offset            + 1; 
constant rel_watch_en_offset              : natural :=rel_dvc2_offset            + 1; 
constant reld_data_vld_offset             : natural :=rel_watch_en_offset        + 1; 
constant rel_tag_offset                   : natural :=reld_data_vld_offset       + 1; 
constant reld_data_vld_dplus1_offset      : natural :=rel_tag_offset             + rel_tag_l2'length;
constant rel_tag_dplus1_offset            : natural :=reld_data_vld_dplus1_offset + 1; 
constant data_ecc_err_offset              : natural :=rel_tag_dplus1_offset      + rel_tag_dplus1_l2'length;
constant data_ecc_ue_offset               : natural :=data_ecc_err_offset        + data_ecc_err_l2'length;
constant ld_m_rel_done_offset             : natural :=data_ecc_ue_offset         + data_ecc_ue_l2'length;
constant ldq_retry_offset                 : natural :=ld_m_rel_done_offset       + ld_m_rel_done_l2'length; 
constant ld_m_rel_done_dly_offset         : natural :=ldq_retry_offset           + ldq_retry_l2'length; 
constant ld_m_rel_done_dly2_offset        : natural :=ld_m_rel_done_dly_offset   + ld_m_rel_done_dly_l2'length;
constant blk_ld_for_pe_recov_offset       : natural :=ld_m_rel_done_dly2_offset  + ld_m_rel_done_dly2_l2'length; 
constant ldq_rd_seq_match_offset          : natural :=blk_ld_for_pe_recov_offset  + 1; 
constant ob_pwr_tok_offset                : natural :=ldq_rd_seq_match_offset    + ldq_rd_seq_match_l2'length; 
constant ob_req_val_offset                : natural :=ob_pwr_tok_offset          + 1; 
constant ob_req_val_clone_offset          : natural :=ob_req_val_offset          + 1; 
constant ob_ditc_val_offset               : natural :=ob_req_val_clone_offset    + 1; 
constant ob_ditc_val_clone_offset         : natural :=ob_ditc_val_offset         + 1; 
constant ob_thrd_offset                   : natural :=ob_ditc_val_clone_offset   + 1; 
constant ob_qw_offset                     : natural :=ob_thrd_offset             + ob_thrd_l2'length; 
constant ob_dest_offset                   : natural :=ob_qw_offset               + ob_qw_l2'length; 
constant ob_addr_offset                   : natural :=ob_dest_offset             + ob_dest_l2'length; 
constant ob_data_offset                   : natural :=ob_addr_offset             + ob_addr_l2'length; 
constant ex5_sel_st_req_offset            : natural :=ob_data_offset             + ob_data_l2'length; 
constant bx_cmd_sent_offset               : natural :=ex5_sel_st_req_offset      + 1; 
constant bx_cmd_stall_offset              : natural :=bx_cmd_sent_offset         + 1; 
constant bx_stall_dly_offset              : natural :=bx_cmd_stall_offset        + 1; 
constant xu_mm_lsu_token_offset           : natural :=bx_stall_dly_offset        + bx_stall_dly_l2'length; 
constant ex4_val_req_offset               : natural :=xu_mm_lsu_token_offset     + 1; 
constant ex4_thrd_id_offset               : natural :=ex4_val_req_offset         + 1; 
constant ex5_thrd_id_offset               : natural :=ex4_thrd_id_offset         + ex4_thrd_id'length; 
constant lmq_collision_t0_offset          : natural :=ex5_thrd_id_offset         + ex5_thrd_id'length; 
constant lmq_collision_t1_offset          : natural :=lmq_collision_t0_offset    + lmq_collision_t0_l2'length; 
constant lmq_collision_t2_offset          : natural :=lmq_collision_t1_offset    + lmq_collision_t1_l2'length; 
constant lmq_collision_t3_offset          : natural :=lmq_collision_t2_offset    + lmq_collision_t2_l2'length; 
constant ldq_barr_active_offset           : natural :=lmq_collision_t3_offset    + lmq_collision_t3_l2'length;
constant l2req_resend_offset              : natural :=ldq_barr_active_offset     + ldq_barr_active_l2'length;
constant l2req_recycle_offset             : natural :=l2req_resend_offset        + 1;
constant l2req_pwr_token_offset           : natural :=l2req_recycle_offset       + 1;
constant l2req_st_data_ptoken_offset      : natural :=l2req_pwr_token_offset     + 1;
constant l2req_ttype_offset                : natural :=l2req_st_data_ptoken_offset+ 1; 
constant l2req_wimg_offset                : natural :=l2req_ttype_offset         + l2req_ttype'length; 
constant l2req_user_offset                : natural :=l2req_wimg_offset          + l2req_wimg'length;
constant l2req_offset                     : natural :=l2req_user_offset          + l2req_user'length; 
constant l2req_ld_core_tag_offset         : natural :=l2req_offset               + 1; 
constant l2req_ra_offset                  : natural :=l2req_ld_core_tag_offset   + l2req_ld_core_tag'length; 
constant l2req_st_byte_enbl_offset        : natural :=l2req_ra_offset            + l2req_ra'length; 
constant l2req_thread_offset              : natural :=l2req_st_byte_enbl_offset  + l2req_st_byte_enbl'length;
constant l2req_endian_offset              : natural :=l2req_thread_offset        + l2req_thread'length;
constant l2req_ld_xfr_len_offset          : natural :=l2req_endian_offset        + 1; 
constant spare_ctrl_a0_offset             : natural :=l2req_ld_xfr_len_offset    + l2req_ld_xfr_len'length; 
constant spare_ctrl_a1_offset             : natural :=spare_ctrl_a0_offset       + ac_an_req_spare_ctrl_a0'length; 
constant st_recycle_offset                : natural :=spare_ctrl_a1_offset       + an_ac_req_spare_ctrl_a1'length; 
constant st_recycle_v_offset              : natural :=st_recycle_offset          + st_recycle_l2'length; 
constant ex6_load_sent_offset             : natural :=st_recycle_v_offset        + 1; 
constant load_sent_dbglat_offset          : natural :=ex6_load_sent_offset       + 1; 
constant ex6_store_sent_offset            : natural :=load_sent_dbglat_offset    + 1; 
constant ex5_flush_offset                 : natural :=ex6_store_sent_offset      + 1; 
constant ex6_flush_offset                 : natural :=ex5_flush_offset           + 1; 
constant msr_gs_offset                    : natural :=ex6_flush_offset           + 1; 
constant msr_pr_offset                    : natural :=msr_gs_offset              + msr_gs_l2'length;
constant msr_ds_offset                    : natural :=msr_pr_offset              + msr_pr_l2'length;
constant pid0_offset                      : natural :=msr_ds_offset              + msr_ds_l2'length;
constant pid1_offset                      : natural :=pid0_offset                + pid0_l2'length;
constant pid2_offset                      : natural :=pid1_offset                + pid1_l2'length;
constant pid3_offset                      : natural :=pid2_offset                + pid2_l2'length;
constant stq_icswx_extra_data_offset      : natural :=pid3_offset                + pid3_l2'length;
constant ex4_p_addr_59_offset             : natural :=stq_icswx_extra_data_offset + stq_icswx_extra_data_l2'length;
constant ex5_st_data_offset               : natural :=ex4_p_addr_59_offset       + 1; 
constant ex6_st_data_offset               : natural :=ex5_st_data_offset         + ex5_st_data_l2'length;
constant ex4_l2cmdq_flush_offset          : natural :=ex6_st_data_offset         + ac_an_st_data'length;
constant my_beat_last_offset              : natural :=ex4_l2cmdq_flush_offset    + ex4_l2cmdq_flush_l2'length;
constant loadmiss_qentry_offset           : natural :=my_beat_last_offset        + 1;
constant ex5_loadmiss_qentry_offset       : natural :=loadmiss_qentry_offset     + ex4_loadmiss_qentry'length;
constant ex6_loadmiss_qentry_offset       : natural :=ex5_loadmiss_qentry_offset + ex5_loadmiss_qentry'length;
constant ex7_loadmiss_qentry_offset       : natural :=ex6_loadmiss_qentry_offset + ex6_loadmiss_qentry'length;
constant ex4_loadmiss_target_offset       : natural :=ex7_loadmiss_qentry_offset + ex7_loadmiss_qentry'length;
constant loadmiss_target_offset           : natural :=ex4_loadmiss_target_offset     + xu_iu_ex5_loadmiss_target'length;
constant ex4_loadmiss_target_type_offset  : natural :=loadmiss_target_offset     + xu_iu_ex5_loadmiss_target'length;
constant loadmiss_target_type_offset      : natural :=ex4_loadmiss_target_type_offset + ex4_loadmiss_target_type'length;
constant ex4_loadmiss_tid_offset          : natural :=loadmiss_target_type_offset + xu_iu_ex5_loadmiss_target_type'length;
constant loadmiss_tid_offset              : natural :=ex4_loadmiss_tid_offset    + ex4_loadmiss_tid'length;
constant ldm_comp_qentry_offset           : natural :=loadmiss_tid_offset        + xu_iu_ex5_loadmiss_tid'length;
constant complete_qentry_offset           : natural :=ldm_comp_qentry_offset     + ldm_comp_qentry_l2'length;
constant complete_tid_offset              : natural :=complete_qentry_offset     + xu_iu_complete_qentry'length;
constant complete_target_type_offset      : natural :=complete_tid_offset        + xu_iu_complete_tid'length;
constant larx_done_tid_offset             : natural :=complete_target_type_offset + xu_iu_complete_target_type'length;
constant update_gpr_offset                : natural :=larx_done_tid_offset       + xu_iu_larx_done_tid'length;
constant rel_beat_crit_qw_offset          : natural :=update_gpr_offset          + 1;
constant rel_beat_crit_qw_block_offset    : natural :=rel_beat_crit_qw_offset    + 1;
constant gpr_updated_prev_offset          : natural :=rel_beat_crit_qw_block_offset + 1;
constant gpr_updated_dly1_offset          : natural :=gpr_updated_prev_offset    + gpr_updated_prev_l2'length;
constant gpr_updated_dly2_offset          : natural :=gpr_updated_dly1_offset    + gpr_updated_dly1_l2'length;
constant gpr_ecc_err_offset               : natural :=gpr_updated_dly2_offset    + gpr_updated_dly2_l2'length;
constant spare_4_offset                    : natural :=gpr_ecc_err_offset         + gpr_ecc_err_l2'length;
constant rel_A_data_offset                : natural :=spare_4_offset              + spare_4_l2'length;
constant rel_B_data_offset                : natural :=rel_A_data_offset          + rel_A_data_l2'length;
constant send_rel_A_data_offset           : natural :=rel_B_data_offset          + rel_B_data_l2'length * a2mode;
constant ldq_barr_done_offset             : natural :=send_rel_A_data_offset     + 1 * a2mode;
constant sync_done_tid_offset             : natural :=ldq_barr_done_offset       + ldq_barr_done'length;
constant lmq_stq_empty_offset             : natural :=sync_done_tid_offset       + sync_done_tid'length;
constant quiesce_offset                   : natural :=lmq_stq_empty_offset       + 1;
constant err_l2intrf_ecc_offset           : natural :=quiesce_offset             + lsu_xu_quiesce'length;
constant err_l2intrf_ue_offset            : natural :=err_l2intrf_ecc_offset     + 1;
constant err_invld_reld_offset            : natural :=err_l2intrf_ue_offset      + 1;
constant ex4_ld_queue_full_offset         : natural :=err_invld_reld_offset      + 1;
constant ex5_ld_queue_full_offset         : natural :=ex4_ld_queue_full_offset   + 1;
constant ex4_st_queue_full_offset         : natural :=ex5_ld_queue_full_offset   + 1;
constant ex5_st_queue_full_offset         : natural :=ex4_st_queue_full_offset   + 1;
constant ex5_ldhld_sthld_coll_offset      : natural :=ex5_st_queue_full_offset   + 1;
constant ex4_i1_g1_coll_offset            : natural :=ex5_ldhld_sthld_coll_offset + 1;
constant ex5_i1_g1_coll_offset            : natural :=ex4_i1_g1_coll_offset       + 1;
constant ld_miss_latency_offset           : natural :=ex5_i1_g1_coll_offset       + 1;
constant lsu_perf_events_offset           : natural :=ld_miss_latency_offset      + 1;
constant dbg_offset                       : natural :=lsu_perf_events_offset      + lsu_perf_events_l2'length;
constant scan_right                       : natural :=dbg_offset                  + dbg_l2'length;

signal siv                                : std_ulogic_vector(0 to scan_right-1);
signal sov                                : std_ulogic_vector(0 to scan_right-1);


constant load_cmd_count_offset            : natural :=0; 
constant store_cmd_count_offset           : natural :=load_cmd_count_offset      + load_cmd_count_l2'length; 
constant bcfg_scan_right                  : natural :=store_cmd_count_offset     + store_cmd_count_l2'length;

signal bcfg_siv                           : std_ulogic_vector(0 to bcfg_scan_right-1);
signal bcfg_sov                           : std_ulogic_vector(0 to bcfg_scan_right-1);


-- Get rid of sinkless net messages
signal unused_signals                   : std_ulogic;

begin

unused_signals <= or_reduce(unused & ex4_ld_recov_entry(48) & ex7_ld_recov_l2(22 to 26) & l_miss_entry(0) & l_miss_entry(13 to 17) & l_miss_entry(22 to 38) & l_miss_entry(47 to 52) & ld_st_request(38) & anaclat_data_coming & anaclat_reld_crit_qw & anaclat_tag(0));

ex3_p_addr <= cmp_ex3_p_addr_o & ex3_p_addr_lwr;

--*************************************************************************************************
-- Load/Store Queue logic act:  power up ldq logic when there is a valid lsu op in ex3 and leave
-- it on until the ldq is empty.  Same for stq except use ex4 store to power up.
--*************************************************************************************************

ldq_active_d <= ex3_stg_act or pe_recov_ld_val_l2 or
                (ldq_active_l2 and not lmq_empty);

latch_clkg_ctl_override : tri_rlmreg_p
  generic map (width => 1, init => 0, expand_type => expand_type)
  port map (nclk    => nclk,
            act     => '1',
            forcee => func_slp_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_slp_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(clkg_ctl_override_offset to clkg_ctl_override_offset),
            scout   => sov(clkg_ctl_override_offset to clkg_ctl_override_offset),
            din(0)  => spr_xucr0_clkg_ctl_b3,
            dout(0) => clkg_ctl_override_q);
-- XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

latch_ldq_active : tri_rlmreg_p
  generic map (width => 1, init => 0, expand_type => expand_type)
  port map (nclk    => nclk,
            act     => ldq_act,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(ldq_active_offset to ldq_active_offset),
            scout   => sov(ldq_active_offset to ldq_active_offset),
            din(0)  => ldq_active_d,
            dout(0) => ldq_active_l2);

ldq_active_dly_d <= ldq_active_l2;

latch_ldq_active_dly : tri_rlmreg_p
  generic map (width => 1, init => 0, expand_type => expand_type)
  port map (nclk    => nclk,
            act     => ldq_act,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(ldq_active_dly_offset to ldq_active_dly_offset),
            scout   => sov(ldq_active_dly_offset to ldq_active_dly_offset),
            din(0)  => ldq_active_dly_d,
            dout(0) => ldq_active_dly_l2);

ldq_act <= ex3_stg_act or pe_recov_ld_val_l2 or ldq_active_l2 or ldq_active_dly_l2 or clkg_ctl_override_q;
-- XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

stq_active_d <= ex4_st_val_l2 or (l2req_recycle_l2 and ex7_ld_par_err) or
                (stq_active_l2 and st_entry0_val_l2);

latch_stq_active : tri_rlmreg_p
  generic map (width => 1, init => 0, expand_type => expand_type)
  port map (nclk    => nclk,
            act     => stq_act,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(stq_active_offset to stq_active_offset),
            scout   => sov(stq_active_offset to stq_active_offset),
            din(0)  => stq_active_d,
            dout(0) => stq_active_l2);

stq_act <= ex4_st_val_l2 or stq_active_l2 or (l2req_recycle_l2 and ex7_ld_par_err) or st_recycle_act or clkg_ctl_override_q;


--******************************************************
-- Inputs
--******************************************************

-- new user defined attribute bit -> Bypass L1 if a loadmiss
c_inh <= ex3_cache_inh or ex3_byp_l1;       

dcbt_instr <= ex3_dcbt_instr or ex3_dcbtst_instr or ex3_dcbtls_instr or ex3_dcbtstls_instr;   -- these touch instructions don't load a GPR

touch_instr <= ex3_dcbt_instr or ex3_dcbtst_instr or ex3_dcbtls_instr or ex3_dcbtstls_instr or -- these touch instructions don't load a GPR
               ex3_icbt_instr or ex3_icbtls_instr;

l2only_instr <= (dcbt_instr and ex3_th_fld_l2) or ex3_icbt_instr or ex3_icbtls_instr; 

latch_ex7_ld_par_err : tri_rlmreg_p
  generic map (width => 1, init => 0, expand_type => expand_type)
  port map (nclk    => nclk,
            act     => '1',
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(ex7_ld_par_err_offset to ex7_ld_par_err_offset),
            scout   => sov(ex7_ld_par_err_offset to ex7_ld_par_err_offset),
            din(0)  => ex6_ld_par_err,
            dout(0) => ex7_ld_par_err);

latch_ex8_ld_par_err : tri_rlmreg_p
  generic map (width => 1, init => 0, expand_type => expand_type)
  port map (nclk    => nclk,
            act     => '1',
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(ex8_ld_par_err_offset to ex8_ld_par_err_offset),
            scout   => sov(ex8_ld_par_err_offset to ex8_ld_par_err_offset),
            din(0)  => ex7_ld_par_err,
            dout(0) => ex8_ld_par_err_l2);

latch_my_ex4_flush : tri_rlmreg_p
  generic map (width => 1, init => 0, expand_type => expand_type)
  port map (nclk    => nclk,
            act     => '1',
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(my_ex4_flush_offset to my_ex4_flush_offset),
            scout   => sov(my_ex4_flush_offset to my_ex4_flush_offset),
            din(0)  => ex3_flush_all,
            dout(0) => my_ex4_flush_l2);


-- track parity error recovery state

pe_recov_empty_d <= lmq_empty and pe_recov_state_l2;

latch_pe_recov_empty : tri_rlmreg_p
  generic map (width => 1, init => 0, expand_type => expand_type)
  port map (nclk    => nclk,
            act     => '1',
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(pe_recov_empty_offset to pe_recov_empty_offset),
            scout   => sov(pe_recov_empty_offset to pe_recov_empty_offset),
            din(0)  => pe_recov_empty_d,
            dout(0) => pe_recov_empty_l2);

pe_recov_state_d <= ex7_ld_par_err or
                    (pe_recov_state_l2 and not (pe_recov_ld_num_l2(3) and lmq_empty and pe_recov_empty_l2 and not pe_recov_ld_val_l2));

latch_pe_recov_state : tri_rlmreg_p
  generic map (width => 1, init => 0, expand_type => expand_type)
  port map (nclk    => nclk,
            act     => '1',
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(pe_recov_state_offset to pe_recov_state_offset),
            scout   => sov(pe_recov_state_offset to pe_recov_state_offset),
            din(0)  => pe_recov_state_d,
            dout(0) => pe_recov_state_l2);

latch_pe_recov_state_dly : tri_rlmreg_p
  generic map (width => 1, init => 0, expand_type => expand_type)
  port map (nclk    => nclk,
            act     => '1',
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(pe_recov_state_dly_offset to pe_recov_state_dly_offset),
            scout   => sov(pe_recov_state_dly_offset to pe_recov_state_dly_offset),
            din(0)  => pe_recov_state_l2,
            dout(0) => pe_recov_state_dly_l2);

lmq_pe_recov_state <= pe_recov_state_l2;

pe_recov_ld_num_d(1) <= (pe_recov_state_l2 and lmq_empty and pe_recov_empty_l2 and (pe_recov_ld_num_l2="000")) or
                        (pe_recov_ld_num_l2(1) and not (lmq_empty and pe_recov_empty_l2));
pe_recov_ld_num_d(2) <= (pe_recov_ld_num_l2(1) and lmq_empty and pe_recov_empty_l2) or
                        (pe_recov_ld_num_l2(2) and not (lmq_empty and pe_recov_empty_l2 and not pe_recov_ld_val_l2));
pe_recov_ld_num_d(3) <= (pe_recov_ld_num_l2(2) and lmq_empty and pe_recov_empty_l2 and not pe_recov_ld_val_l2) or
                        (pe_recov_ld_num_l2(3) and not (lmq_empty and pe_recov_empty_l2 and not pe_recov_ld_val_l2));

pe_act <= pe_recov_state_l2 or clkg_ctl_override_q;

latch_pe_recov_ld_num : tri_rlmreg_p
  generic map (width => pe_recov_ld_num_l2'length, init => 0, expand_type => expand_type)
  port map (nclk    => nclk,
         act     => pe_act,
         forcee => func_sl_force,
         d_mode  => d_mode_dc,
         delay_lclkr => delay_lclkr_dc,
         mpw1_b  => mpw1_dc_b,
         mpw2_b  => mpw2_dc_b,
         thold_b => func_sl_thold_0_b,
         sg      => sg_0,
         vd      => vdd,
         gd      => gnd,
         scin    => siv(pe_recov_ld_num_offset to pe_recov_ld_num_offset + pe_recov_ld_num_l2'length-1),
         scout   => sov(pe_recov_ld_num_offset to pe_recov_ld_num_offset + pe_recov_ld_num_l2'length-1),
         din     => pe_recov_ld_num_d(1 to 3),
         dout    => pe_recov_ld_num_l2(1 to 3));

pe_recov_stall <= (ex7_ld_par_err or pe_recov_state_l2) and not (lmq_empty and pe_recov_empty_l2);


pe_recov_ld_val_d <= pe_recov_state_l2 and lmq_empty and not ld_m_val and
                     (ex7_ld_recov_val_l2 or (ex6_ld_recov_val_l2 and not pe_recov_stall));

latch_pe_recov_ld_val : tri_rlmreg_p
  generic map (width => 1, init => 0, expand_type => expand_type)
  port map (nclk    => nclk,
            act     => '1',
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(pe_recov_ld_val_offset to pe_recov_ld_val_offset),
            scout   => sov(pe_recov_ld_val_offset to pe_recov_ld_val_offset),
            din(0)  => pe_recov_ld_val_d,
            dout(0) => pe_recov_ld_val_l2);


recov_ignr_flush_d <= or_reduce(pe_recov_ld_num_l2);




ex3_flush_all <= ex3_stg_flush or I1_G1_flush; 

ex4_flush_load  <= (ex7_ld_par_err or ex8_ld_par_err_l2 or ex4_drop_ld_req or l_m_fnd_stg or my_ex4_flush_l2) and not recov_ignr_flush_d;

ex4_flush_load_wo_drop  <= ex7_ld_par_err or l_m_fnd_stg or my_ex4_flush_l2 or
                           (ex4_drop_touch and ex4_ld_recov(38));                
ex4_flush_store <= (ex7_ld_par_err or ex8_ld_par_err_l2 or l_m_fnd_stg or (ex4_load_l1hit_val and not ex4_drop_ld_req) or my_ex4_flush_l2) or
                   ((ex4_st_entry_l2(0 to 4) = "10010") and ex4_drop_ld_req);  -- icblc/dcblc and drop due to I=1

ex5_flush_load_all <= my_ex5_flush and not recov_ignr_flush_d;
ex5_flush_load_local <= ex5_flush_l2 and not recov_ignr_flush_d;

my_xucr0_d <= xu_lsu_spr_xucr0_rel & xu_lsu_spr_xucr0_l2siw & xu_lsu_spr_xucr0_cred &
              xu_lsu_spr_xucr0_mbar_ack & xu_lsu_spr_xucr0_tlbsync & xu_lsu_spr_xucr0_cls;

latch_my_xucr0 : tri_rlmreg_p
  generic map (width => my_xucr0_l2'length, init => 0, expand_type => expand_type)
  port map (nclk    => nclk,
            act     => '1',
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(my_xucr0_offset to my_xucr0_offset + my_xucr0_l2'length-1),
            scout   => sov(my_xucr0_offset to my_xucr0_offset + my_xucr0_l2'length-1),
            din     => my_xucr0_d,
            dout    => my_xucr0_l2);

my_xucr0_rel         <= my_xucr0_l2(0);
my_xucr0_l2siw       <= my_xucr0_l2(1);
my_xucr0_cred        <= my_xucr0_l2(2);
my_xucr0_mbar_ack    <= my_xucr0_l2(3);
my_xucr0_tlbsync     <= my_xucr0_l2(4);
my_xucr0_cls         <= my_xucr0_l2(5);

--******************************************************
-- Latch the L2 interface Inputs
--******************************************************


latch_anac_data_coming : tri_rlmreg_p
  generic map (width => 1, init => 0, expand_type => expand_type)
  port map (nclk    => nclk,
            act     => '1',
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(anac_data_coming_offset to anac_data_coming_offset),
            scout   => sov(anac_data_coming_offset to anac_data_coming_offset),
            din(0)  => an_ac_reld_data_coming,
            dout(0) => anaclat_data_coming);

latch_anac_reld_crit_qw : tri_rlmreg_p
  generic map (width => 1, init => 0, expand_type => expand_type)
  port map (nclk    => nclk,
            act     => '1',
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(anac_reld_crit_qw_offset to anac_reld_crit_qw_offset),
            scout   => sov(anac_reld_crit_qw_offset to anac_reld_crit_qw_offset),
            din(0)  => an_ac_reld_crit_qw,
            dout(0) => anaclat_reld_crit_qw);

latch_anac_ditc : tri_rlmreg_p
  generic map (width => 1, init => 0, expand_type => expand_type)
  port map (nclk    => nclk,
            act     => '1',
            forcee => func_slp_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_slp_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(anac_ditc_offset to anac_ditc_offset),
            scout   => sov(anac_ditc_offset to anac_ditc_offset),
            din(0)  => an_ac_reld_ditc,
            dout(0) => anaclat_ditc);

latch_anac_data_val : tri_rlmreg_p
  generic map (width => 1, init => 0, expand_type => expand_type)
  port map (nclk    => nclk,
            act     => '1',
            forcee => func_slp_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_slp_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(anac_data_val_offset to anac_data_val_offset),
            scout   => sov(anac_data_val_offset to anac_data_val_offset),
            din(0)  => an_ac_reld_data_val,
            dout(0) => anaclat_data_val);

ldqretry:  process (ldq_retry_l2, retry_started_l2)
   variable b: std_ulogic;
begin
      b := '0';
      for i in 0 to lmq_entries-1 loop
         b := (ldq_retry_l2(i) and not retry_started_l2(i)) or b;
      end loop;
      ldq_retry_or <= b;
end process;

data_val_for_rel    <= anaclat_data_val and not anaclat_ditc;
data_val_dminus2    <= data_val_for_rel or ldq_retry_or;
data_val_for_drel   <= anaclat_data_val and not (anaclat_ditc or anaclat_tag(1));
data_val_for_recirc <= ldq_retry_or and not data_val_for_drel;

latch_data_val_dminus1 : tri_rlmreg_p
  generic map (width => 1, init => 0, expand_type => expand_type)
  port map (nclk    => nclk,
            act     => '1',
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(data_val_dminus1_offset to data_val_dminus1_offset),
            scout   => sov(data_val_dminus1_offset to data_val_dminus1_offset),
            din(0)  => data_val_dminus2,
            dout(0) => data_val_dminus1_l2);

latch_ldq_rel_retry_val : tri_rlmreg_p
  generic map (width => 1, init => 0, expand_type => expand_type)
  port map (nclk    => nclk,
            act     => '1',
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(ldq_rel_retry_val_offset to ldq_rel_retry_val_offset),
            scout   => sov(ldq_rel_retry_val_offset to ldq_rel_retry_val_offset),
            din(0)  => data_val_for_recirc,
            dout(0) => ldq_rel_retry_val_l2);

latch_ldq_rel_retry_val_dly : tri_rlmreg_p
  generic map (width => 1, init => 0, expand_type => expand_type)
  port map (nclk    => nclk,
            act     => '1',
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(ldq_rel_retry_val_dly_offset to ldq_rel_retry_val_dly_offset),
            scout   => sov(ldq_rel_retry_val_dly_offset to ldq_rel_retry_val_dly_offset),
            din(0)  => ldq_rel_retry_val_l2,
            dout(0) => ldq_rel_retry_val_dly_l2);

latch_rel_intf_v_dminus1 : tri_rlmreg_p
  generic map (width => 1, init => 0, expand_type => expand_type)
  port map (nclk    => nclk,
            act     => '1',
            forcee => func_slp_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_slp_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(rel_intf_v_dminus1_offset to rel_intf_v_dminus1_offset),
            scout   => sov(rel_intf_v_dminus1_offset to rel_intf_v_dminus1_offset),
            din(0)  => anaclat_data_val,
            dout(0) => rel_intf_v_dminus1_l2);
latch_rel_intf_v : tri_rlmreg_p
  generic map (width => 1, init => 0, expand_type => expand_type)
  port map (nclk    => nclk,
            act     => '1',
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(rel_intf_v_offset to rel_intf_v_offset),
            scout   => sov(rel_intf_v_offset to rel_intf_v_offset),
            din(0)  => rel_intf_v_dminus1_l2,
            dout(0) => rel_intf_v_l2);
latch_rel_intf_v_dplus1 : tri_rlmreg_p
  generic map (width => 1, init => 0, expand_type => expand_type)
  port map (nclk    => nclk,
            act     => '1',
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(rel_intf_v_dplus1_offset to rel_intf_v_dplus1_offset),
            scout   => sov(rel_intf_v_dplus1_offset to rel_intf_v_dplus1_offset),
            din(0)  => rel_intf_v_l2,
            dout(0) => rel_intf_v_dplus1_l2);

latch_anac_tag : tri_rlmreg_p
  generic map (width => anaclat_tag'length, init => 0, expand_type => expand_type)
  port map (nclk    => nclk,
            act     => '1',
            forcee => func_slp_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_slp_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(anac_tag_offset to anac_tag_offset + anaclat_tag'length-1),
            scout   => sov(anac_tag_offset to anac_tag_offset + anaclat_tag'length-1),
            din     => an_ac_reld_core_tag,
            dout    => anaclat_tag);

ldq_retry_tag(1) <= '0';

ldq_retry_tag4: if lmq_entries=4 generate begin
   ldq_retry_tag(2 to 4) <= "000"   when ldq_retry_ready(0)='1' else
                            "001"   when ldq_retry_ready(1)='1' else
                            "010"   when ldq_retry_ready(2)='1' else
                            "011"; --  when ldq_retry_ready(3)='1'
end generate;

ldq_retry_tag8: if lmq_entries=8 generate begin
   ldq_retry_tag(2 to 4) <= "000"   when ldq_retry_ready(0)='1' else
                            "001"   when ldq_retry_ready(1)='1' else
                            "010"   when ldq_retry_ready(2)='1' else
                            "011"   when ldq_retry_ready(3)='1' else
                            "100"   when ldq_retry_ready(4)='1' else
                            "101"   when ldq_retry_ready(5)='1' else
                            "110"   when ldq_retry_ready(6)='1' else
                            "111"; --  when ldq_retry_ready(7)='1'
end generate;

ldq_retry_ready(0) <= ldq_retry_l2(0) and not retry_started_l2(0);
start_ldq_retry(0) <= ldq_retry_ready(0) and not data_val_for_rel;
retry_started_d(0) <= start_ldq_retry(0) or
                      (retry_started_l2(0) and not ld_m_rel_done_l2(0));
start_ldq_retry(1) <= ldq_retry_ready(1) and not data_val_for_rel and not ldq_retry_ready(0);

retry_started: for i in 1 to lmq_entries-1 generate begin
   ldq_retry_ready(i) <= ldq_retry_l2(i) and not retry_started_l2(i);
   igt1: if i > 1 generate begin 
      start_ldq_retry(i) <= ldq_retry_ready(i) and not data_val_for_rel and
                            not or_reduce(ldq_retry_ready(0 to i-1));
   end generate;
   retry_started_d(i) <= start_ldq_retry(i) or
                         (retry_started_l2(i) and not ld_m_rel_done_l2(i));
end generate;

latch_retry_started : tri_rlmreg_p
  generic map (width => retry_started_l2'length, init => 0, expand_type => expand_type)
  port map (nclk    => nclk,
            act     => ldq_act,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(retry_started_offset to retry_started_offset + retry_started_l2'length-1),
            scout   => sov(retry_started_offset to retry_started_offset + retry_started_l2'length-1),
            din     => retry_started_d(0 to lmq_entries-1),
            dout    => retry_started_l2(0 to lmq_entries-1));

tag_dminus2 <= ldq_retry_tag     when (ldq_retry_or and not data_val_for_rel)='1'  else
               anaclat_tag(1 to 4);

tag_dminus1_act <= anaclat_data_val or ldq_retry_or or clkg_ctl_override_q;

tag_dminus1_1hot_n8gen: if lmq_entries /= 8 generate begin
      tag_dminus1_1hot_gen : for i in 0 to lmq_entries-1 generate begin
            tag_dminus1_1hot_d(i) <= (tag_dminus2(1 to 4) = tconv(i, 4));
      end generate tag_dminus1_1hot_gen;
end generate tag_dminus1_1hot_n8gen;

tag_dminus1_1hot_8gen: if lmq_entries=8 generate begin
   tag_dminus1_1hot_d(0) <= not tag_dminus2(1) and not tag_dminus2(2) and not tag_dminus2(3) and not tag_dminus2(4);
   tag_dminus1_1hot_d(1) <= not tag_dminus2(1) and not tag_dminus2(2) and not tag_dminus2(3) and     tag_dminus2(4);
   tag_dminus1_1hot_d(2) <= not tag_dminus2(1) and not tag_dminus2(2) and     tag_dminus2(3) and not tag_dminus2(4);
   tag_dminus1_1hot_d(3) <= not tag_dminus2(1) and not tag_dminus2(2) and     tag_dminus2(3) and     tag_dminus2(4);
   tag_dminus1_1hot_d(4) <= not tag_dminus2(1) and     tag_dminus2(2) and not tag_dminus2(3) and not tag_dminus2(4);
   tag_dminus1_1hot_d(5) <= not tag_dminus2(1) and     tag_dminus2(2) and not tag_dminus2(3) and     tag_dminus2(4);
   tag_dminus1_1hot_d(6) <= not tag_dminus2(1) and     tag_dminus2(2) and     tag_dminus2(3) and not tag_dminus2(4);
   tag_dminus1_1hot_d(7) <= not tag_dminus2(1) and     tag_dminus2(2) and     tag_dminus2(3) and     tag_dminus2(4);
end generate tag_dminus1_1hot_8gen;


latch_tag_dminus1 : tri_rlmreg_p
  generic map (width => tag_dminus1_l2'length, init => 0, expand_type => expand_type)
  port map (nclk    => nclk,
            act     => tag_dminus1_act,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(tag_dminus1_offset to tag_dminus1_offset + tag_dminus1_l2'length-1),
            scout   => sov(tag_dminus1_offset to tag_dminus1_offset + tag_dminus1_l2'length-1),
            din     => tag_dminus2,
            dout    => tag_dminus1_l2);

latch_tag_dminus1_cpy : tri_rlmreg_p
  generic map (width => tag_dminus1_cpy_l2'length, init => 0, expand_type => expand_type)
  port map (nclk    => nclk,
            act     => tag_dminus1_act,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(tag_dminus1_cpy_offset to tag_dminus1_cpy_offset + tag_dminus1_cpy_l2'length-1),
            scout   => sov(tag_dminus1_cpy_offset to tag_dminus1_cpy_offset + tag_dminus1_cpy_l2'length-1),
            din     => tag_dminus2(2 to 4),
            dout    => tag_dminus1_cpy_l2);
latch_tag_dminus1_1hot : tri_rlmreg_p
  generic map (width => tag_dminus1_1hot_l2'length, init => 0, expand_type => expand_type)
  port map (nclk    => nclk,
            act     => tag_dminus1_act,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(tag_dminus1_1hot_offset to tag_dminus1_1hot_offset + tag_dminus1_1hot_l2'length-1),
            scout   => sov(tag_dminus1_1hot_offset to tag_dminus1_1hot_offset + tag_dminus1_1hot_l2'length-1),
            din     => tag_dminus1_1hot_d,
            dout    => tag_dminus1_1hot_l2);

latch_anac_qw : tri_rlmreg_p
  generic map (width => anaclat_qw'length, init => 0, expand_type => expand_type)
  port map (nclk    => nclk,
            act     => '1',
            forcee => func_slp_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_slp_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(anac_qw_offset to anac_qw_offset + anaclat_qw'length-1),
            scout   => sov(anac_qw_offset to anac_qw_offset + anaclat_qw'length-1),
            din     => an_ac_reld_qw,
            dout    => anaclat_qw);

latch_qw_dminus1 : tri_rlmreg_p
  generic map (width => qw_dminus1_l2'length, init => 0, expand_type => expand_type)
  port map (nclk    => nclk,
            act     => tag_dminus1_act,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(qw_dminus1_offset to qw_dminus1_offset + qw_dminus1_l2'length-1),
            scout   => sov(qw_dminus1_offset to qw_dminus1_offset + qw_dminus1_l2'length-1),
            din     => anaclat_qw,
            dout    => qw_dminus1_l2);

dminus1_act <= data_val_dminus1_l2 or clkg_ctl_override_q;

latch_qw : tri_rlmreg_p
  generic map (width => qw_l2'length, init => 0, expand_type => expand_type)
  port map (nclk    => nclk,
            act     => dminus1_act,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(qw_offset to qw_offset + qw_l2'length-1),
            scout   => sov(qw_offset to qw_offset + qw_l2'length-1),
            din     => qw_dminus1_l2,
            dout    => qw_l2);

rel_data_act <= rel_intf_v_dminus1_l2 or clkg_ctl_override_q;

latch_anac_data : tri_rlmreg_p
  generic map (width => anaclat_data'length, init => 0, expand_type => expand_type)
  port map (nclk    => nclk,
            act     => rel_data_act,
            forcee => func_slp_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_slp_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(anac_data_offset to anac_data_offset + anaclat_data'length-1),
            scout   => sov(anac_data_offset to anac_data_offset + anaclat_data'length-1),
            din     => an_ac_reld_data,
            dout    => anaclat_data);

latch_anac_ecc_err : tri_rlmreg_p
  generic map (width => 1, init => 0, expand_type => expand_type)
  port map (nclk    => nclk,
            act     => '1',
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(anac_ecc_err_offset to anac_ecc_err_offset),
            scout   => sov(anac_ecc_err_offset to anac_ecc_err_offset),
            din(0)  => an_ac_reld_ecc_err,
            dout(0) => anaclat_ecc_err);

latch_anac_ecc_err_ue : tri_rlmreg_p
  generic map (width => 1, init => 0, expand_type => expand_type)
  port map (nclk    => nclk,
            act     => '1',
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(anac_ecc_err_ue_offset to anac_ecc_err_ue_offset),
            scout   => sov(anac_ecc_err_ue_offset to anac_ecc_err_ue_offset),
            din(0)  => an_ac_reld_ecc_err_ue,
            dout(0) => anaclat_ecc_err_ue);


beat_ecc_err <= anaclat_ecc_err and rel_intf_v_dplus1_l2;

ue_mchk_v <= (rel_addr_l2(58) = qw_l2(58)) and reld_data_vld_l2 and not ldq_rel_retry_val_dly_l2 and not rel_tag_l2(1) and
              ((rel_addr_l2(57) = qw_l2(57)) or not my_xucr0_cls);

ue_mchk_valid_d(0 to 3) <= gate_and(ue_mchk_v, rel_th_id_l2(0 to 3));

l2_data_ecc_err_ue <= gate_and((anaclat_ecc_err_ue and rel_intf_v_dplus1_l2), ue_mchk_valid_l2(0 to 3));

latch_ue_mchk_val : tri_rlmreg_p
  generic map (width => ue_mchk_valid_l2'length, init => 0, expand_type => expand_type)
  port map (nclk    => nclk,
            act     => ldq_act,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(ue_mchk_val_offset to ue_mchk_val_offset + ue_mchk_valid_l2'length-1),
            scout   => sov(ue_mchk_val_offset to ue_mchk_val_offset + ue_mchk_valid_l2'length-1),
            din     => ue_mchk_valid_d,
            dout    => ue_mchk_valid_l2);

latch_anac_l1_dump : tri_rlmreg_p
  generic map (width => 1, init => 0, expand_type => expand_type)
  port map (nclk    => nclk,
            act     => ldq_act,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(anac_l1_dump_offset to anac_l1_dump_offset),
            scout   => sov(anac_l1_dump_offset to anac_l1_dump_offset),
            din(0)  => an_ac_reld_l1_dump,
            dout(0) => anaclat_l1_dump);
latch_dminus1_l1_dump : tri_rlmreg_p
  generic map (width => 1, init => 0, expand_type => expand_type)
  port map (nclk    => nclk,
            act     => tag_dminus1_act,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(dminus1_l1_dump_offset to dminus1_l1_dump_offset),
            scout   => sov(dminus1_l1_dump_offset to dminus1_l1_dump_offset),
            din(0)  => anaclat_l1_dump,
            dout(0) => dminus1_l1_dump);

dminus1_l1_dump_gated <= dminus1_l1_dump and rel_intf_v_dminus1_l2;

latch_l1_dump : tri_rlmreg_p
  generic map (width => 1, init => 0, expand_type => expand_type)
  port map (nclk    => nclk,
            act     => dminus1_act,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(l1_dump_offset to l1_dump_offset),
            scout   => sov(l1_dump_offset to l1_dump_offset),
            din(0)  => dminus1_l1_dump_gated,
            dout(0) => l1_dump);

latch_anac_back_inv : tri_rlmreg_p
  generic map (width => 1, init => 0, expand_type => expand_type)
  port map (nclk    => nclk,
            act     => '1',
            forcee => func_slp_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_slp_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(anac_back_inv_offset to anac_back_inv_offset),
            scout   => sov(anac_back_inv_offset to anac_back_inv_offset),
            din(0)  => an_ac_back_inv,
            dout(0) => anaclat_back_inv);

bi_act <= anaclat_back_inv or clkg_ctl_override_q;

latch_anac_back_inv_addr : tri_rlmreg_p
  generic map (width => anaclat_back_inv_addr'length, init => 0, expand_type => expand_type)
  port map (nclk    => nclk,
            act     => bi_act,
            forcee => func_slp_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_slp_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(anac_back_inv_addr_offset to anac_back_inv_addr_offset + anaclat_back_inv_addr'length-1),
            scout   => sov(anac_back_inv_addr_offset to anac_back_inv_addr_offset + anaclat_back_inv_addr'length-1),
            din     => an_ac_back_inv_addr,
            dout    => anaclat_back_inv_addr);

latch_anac_back_inv_target1 : tri_rlmreg_p
  generic map (width => 1, init => 0, expand_type => expand_type)
  port map (nclk    => nclk,
            act     => '1',
            forcee => func_slp_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_slp_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(anac_back_inv_target1_offset to anac_back_inv_target1_offset),
            scout   => sov(anac_back_inv_target1_offset to anac_back_inv_target1_offset),
            din(0)  => an_ac_back_inv_target_bit1,
            dout(0) => anaclat_back_inv_target_1);

latch_anac_back_inv_target4 : tri_rlmreg_p
  generic map (width => 1, init => 0, expand_type => expand_type)
  port map (nclk    => nclk,
            act     => '1',
            forcee => func_slp_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_slp_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(anac_back_inv_target4_offset to anac_back_inv_target4_offset),
            scout   => sov(anac_back_inv_target4_offset to anac_back_inv_target4_offset),
            din(0)  => an_ac_back_inv_target_bit4,
            dout(0) => anaclat_back_inv_target_4);

back_inv_val_d <= anaclat_back_inv and anaclat_back_inv_target_1;
dbell_val_d <= anaclat_back_inv and anaclat_back_inv_target_4;

latch_back_inv_val : tri_rlmreg_p
  generic map (width => 1, init => 0, expand_type => expand_type)
  port map (nclk    => nclk,
            act     => '1',
            forcee => func_slp_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_slp_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(back_inv_val_offset to back_inv_val_offset),
            scout   => sov(back_inv_val_offset to back_inv_val_offset),
            din(0)  => back_inv_val_d,
            dout(0) => back_inv_val_l2);

latch_dbell_val : tri_rlmreg_p
  generic map (width => 1, init => 0, expand_type => expand_type)
  port map (nclk    => nclk,
            act     => '1',
            forcee => func_slp_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_slp_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(dbell_val_offset to dbell_val_offset),
            scout   => sov(dbell_val_offset to dbell_val_offset),
            din(0)  => dbell_val_d,
            dout(0) => dbell_val_l2);

latch_anac_ld_pop : tri_rlmreg_p
  generic map (width => 1, init => 0, expand_type => expand_type)
  port map (nclk    => nclk,
            act     => '1',
            forcee => func_slp_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_slp_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(anac_ld_pop_offset to anac_ld_pop_offset),
            scout   => sov(anac_ld_pop_offset to anac_ld_pop_offset),
            din(0)  => an_ac_req_ld_pop,
            dout(0) => anaclat_ld_pop);
latch_anac_st_pop : tri_rlmreg_p
  generic map (width => 1, init => 0, expand_type => expand_type)
  port map (nclk    => nclk,
            act     => '1',
            forcee => func_slp_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_slp_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(anac_st_pop_offset to anac_st_pop_offset),
            scout   => sov(anac_st_pop_offset to anac_st_pop_offset),
            din(0)  => an_ac_req_st_pop,
            dout(0) => anaclat_st_pop);
latch_anac_st_pop_thrd : tri_rlmreg_p
  generic map (width => anaclat_st_pop_thrd'length, init => 0, expand_type => expand_type)
  port map (nclk    => nclk,
            act     => '1',
            forcee => func_slp_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_slp_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(anac_st_pop_thrd_offset to anac_st_pop_thrd_offset + anaclat_st_pop_thrd'length-1),
            scout   => sov(anac_st_pop_thrd_offset to anac_st_pop_thrd_offset + anaclat_st_pop_thrd'length-1),
            din     => an_ac_req_st_pop_thrd,
            dout    => anaclat_st_pop_thrd);
latch_anac_st_gather : tri_rlmreg_p
  generic map (width => 1, init => 0, expand_type => expand_type)
  port map (nclk    => nclk,
            act     => '1',
            forcee => func_slp_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_slp_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(anac_st_gather_offset to anac_st_gather_offset),
            scout   => sov(anac_st_gather_offset to anac_st_gather_offset),
            din(0)  => an_ac_req_st_gather,
            dout(0) => anaclat_st_gather);

latch_coreid : tri_rlmreg_p
  generic map (width => anaclat_coreid'length, init => 0, expand_type => expand_type)
  port map (nclk    => nclk,
            act     => '1',
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(coreid_offset to coreid_offset + anaclat_coreid'length-1),
            scout   => sov(coreid_offset to coreid_offset + anaclat_coreid'length-1),
            din     => an_ac_coreid,
            dout    => anaclat_coreid);

latch_stcx_complete : tri_rlmreg_p
  generic map (width => xu_iu_stcx_complete'length, init => 0, expand_type => expand_type)
  port map (nclk    => nclk,
            act     => '1',
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(stcx_complete_offset to stcx_complete_offset + xu_iu_stcx_complete'length-1),
            scout   => sov(stcx_complete_offset to stcx_complete_offset + xu_iu_stcx_complete'length-1),
            din     => an_ac_stcx_complete,
            dout    => xu_iu_stcx_complete);

latch_xu_iu_reld_core_tag : tri_rlmreg_p
  generic map (width => xu_iu_reld_core_tag_clone'length, init => 0, expand_type => expand_type)
  port map (nclk    => nclk,
            act     => '1',
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(xu_iu_reld_core_tag_offset to xu_iu_reld_core_tag_offset + xu_iu_reld_core_tag_clone'length-1),
            scout   => sov(xu_iu_reld_core_tag_offset to xu_iu_reld_core_tag_offset + xu_iu_reld_core_tag_clone'length-1),
            din     => an_ac_reld_core_tag(1 to 4),
            dout    => xu_iu_reld_core_tag_clone);
latch_xu_iu_reld_data_vld : tri_rlmreg_p
  generic map (width => 1, init => 0, expand_type => expand_type)
  port map (nclk    => nclk,
            act     => '1',
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(xu_iu_reld_data_vld_offset to xu_iu_reld_data_vld_offset),
            scout   => sov(xu_iu_reld_data_vld_offset to xu_iu_reld_data_vld_offset),
            din(0)  => an_ac_reld_data_val,
            dout(0) => xu_iu_reld_data_vld_clone);
latch_xu_iu_reld_data_coming : tri_rlmreg_p
  generic map (width => 1, init => 0, expand_type => expand_type)
  port map (nclk    => nclk,
            act     => '1',
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(xu_iu_reld_data_coming_offset to xu_iu_reld_data_coming_offset),
            scout   => sov(xu_iu_reld_data_coming_offset to xu_iu_reld_data_coming_offset),
            din(0)  => an_ac_reld_data_coming,
            dout(0) => xu_iu_reld_data_coming_clone);
latch_xu_iu_reld_ditc : tri_rlmreg_p
  generic map (width => 1, init => 0, expand_type => expand_type)
  port map (nclk    => nclk,
            act     => '1',
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(xu_iu_reld_ditc_offset to xu_iu_reld_ditc_offset),
            scout   => sov(xu_iu_reld_ditc_offset to xu_iu_reld_ditc_offset),
            din(0)  => an_ac_reld_ditc,
            dout(0) => xu_iu_reld_ditc_clone);


-- redrive latch outputs to boxes logic

     lsu_reld_data_vld     <= anaclat_data_val;
     lsu_reld_core_tag     <= anaclat_tag(3 to 4);
     lsu_reld_qw           <= anaclat_qw(58 to 59);
     lsu_reld_ditc         <= anaclat_ditc;
     lsu_reld_data         <= anaclat_data;
     lsu_req_st_pop        <= anaclat_st_pop;
     lsu_req_st_pop_thrd   <= anaclat_st_pop_thrd;
     lsu_reld_ecc_err      <= anaclat_ecc_err or anaclat_ecc_err_ue;

--******************************************************
-- Send DBell info to xu
--******************************************************

latch_lpidr : tri_rlmreg_p
  generic map (width => lpidr_l2'length, init => 0, expand_type => expand_type)
  port map (nclk    => nclk,
            act     => '1',
            forcee => func_slp_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_slp_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(lpidr_offset to lpidr_offset + lpidr_l2'length-1),
            scout   => sov(lpidr_offset to lpidr_offset + lpidr_l2'length-1),
            din     => mm_xu_lsu_lpidr(0 to 7),
            dout    => lpidr_l2(0 to 7));

lsu_xu_dbell_val               <= dbell_val_l2;
lsu_xu_dbell_type(0 to 4)      <= anaclat_back_inv_addr(32 to 36);
lsu_xu_dbell_brdcast           <= anaclat_back_inv_addr(37);
lsu_xu_dbell_lpid_match        <= (anaclat_back_inv_addr(42 to 49) = lpidr_l2(0 to 7)) or
                                  (anaclat_back_inv_addr(42 to 49) = x"00");
lsu_xu_dbell_pirtag(50 to 63)  <= anaclat_back_inv_addr(50 to 63); 

--******************************************************
-- Command Sequence Write
--******************************************************

cmd_seq_incr(0 to 4) <= std_ulogic_vector(unsigned(cmd_seq_l2) + 1);
cmd_seq_decr(0 to 4) <= std_ulogic_vector(unsigned(cmd_seq_l2) - 1);

ctrl_incr_cmdseq <=      ld_m_val and not (ex4_flush_load and ex4_ld_m_val);
ctrl_decr_cmdseq <= (not ld_m_val and     (ex4_flush_load and ex4_ld_m_val));
ctrl_hold_cmdseq <= (    ld_m_val and     (ex4_flush_load and ex4_ld_m_val)) or 
                    (not ld_m_val and not (ex4_flush_load and ex4_ld_m_val));


cmd_seq_d(0 to 4) <= gate_and(ctrl_incr_cmdseq , cmd_seq_incr(0 to 4)) or
                     gate_and(ctrl_decr_cmdseq , cmd_seq_decr(0 to 4)) or
                     gate_and(ctrl_hold_cmdseq , cmd_seq_l2(0 to 4));

latch_cmd_seq : tri_rlmreg_p
  generic map (width => cmd_seq_l2'length, init => 0, expand_type => expand_type)
  port map (nclk    => nclk,
            act     => ldq_act,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(cmd_seq_offset to cmd_seq_offset + cmd_seq_l2'length-1),
            scout   => sov(cmd_seq_offset to cmd_seq_offset + cmd_seq_l2'length-1),
            din     => cmd_seq_d(0 to 4),
            dout    => cmd_seq_l2(0 to 4));

new_ld_cmd_seq(0 to 4) <= cmd_seq_decr(0 to 4)   when (ld_m_val and ex4_flush_load and ex4_ld_m_val) = '1'  else
                          cmd_seq_l2(0 to 4);


ld_q_seq_wrap <= (cmd_seq_l2 = cmd_seq_rd_l2) and or_reduce(ld_entry_val_l2);

--******************************************************
-- Command Sequence Read
--******************************************************

cmd_seq_rd_incr(0 to 4) <= std_ulogic_vector(unsigned(cmd_seq_rd_l2) + 1);

cmd_seq_rd_d(0 to 4) <= cmd_seq_rd_incr(0 to 4)   when (load_sent or selected_entry_flushed or rd_seq_num_skip)='1'   else 
                        cmd_seq_rd_l2(0 to 4);

latch_cmd_seq_rd : tri_rlmreg_p
  generic map (width => cmd_seq_rd_l2'length, init => 0, expand_type => expand_type)
  port map (nclk    => nclk,
            act     => ldq_act,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(cmd_seq_rd_offset to cmd_seq_rd_offset + cmd_seq_rd_l2'length-1),
            scout   => sov(cmd_seq_rd_offset to cmd_seq_rd_offset + cmd_seq_rd_l2'length-1),
            din     => cmd_seq_rd_d(0 to 4),
            dout    => cmd_seq_rd_l2(0 to 4));

--******************************************************
-- Queue Entry
--******************************************************

ex3_new_target_gpr <= ex3_target_gpr or (0 to  8 => touch_instr);

-- bit(0) = c_inh
-- bit(1:6) = encoded command type(0 to 5)
-- bit(7:12) = opsize(0 to 5)
-- bit(13:17) = rot_sel(0 to 4)
-- bit(18:21) = th_id(0 to 3)
-- bit(22:26) = cmd_seq_l2(0 to 4)
-- bit(27:35) = target_gpr(0 to 8)
-- bit(36) = axu_op_val
-- bit(37) = little endian mode
-- bit(38) = dcbt is valid
-- bit(39:42) = wimg bits
-- bit(43:46) = user defined bits
-- bit(47) = algebraic op
-- bit(48) = L2 only touch (do not write reload data to cache)
-- bit(49) = way lock
-- bit(50:51) = way lock bits table select bit (classid)
-- bit(52) = watch enable
-- bit(53) = litle endian bit (from erat)
-- bit(53:xx) = ex3_p_addr(22 to 63)
ld_queue_entry <= c_inh & cmd_type_ld(0 to 5) & ex3_opsize(0 to 5) & ex3_rot_sel(0 to 4) &
                     ex3_thrd_id(0 to 3) & new_ld_cmd_seq(0 to 4) & ex3_new_target_gpr(0 to 8) &
                     ex3_axu_op_val & ex3_le_mode & touch_instr &
                     ex3_wimge_bits(0 to 3) & ex3_usr_bits(0 to 3) & ex3_algebraic & l2only_instr &
                     ex3_lock_en & ex3_classid & ex3_watch_en & ex3_wimge_bits(4)         when pe_recov_ld_val_l2='0' else 
                  ex7_ld_recov_l2(0 to 21) & new_ld_cmd_seq(0 to 4) &
                     ex7_ld_recov_l2(27 to 53);

ld_queue_addrlo <= ex3_p_addr(57 to 63)                                          when pe_recov_ld_val_l2='0' else
                   ex7_ld_recov_l2((54+real_data_add-6-1) to (54+real_data_add-1));

cmp_ld_ex7_recov <= pe_recov_ld_val_l2;

load_val <= ex3_load_instr and not (ex3_dcbt_instr or ex3_dcbtst_instr or
                                    ex3_dcbtls_instr or ex3_dcbtstls_instr or 
                                    ex3_larx_instr or ex3_icbt_instr or ex3_icbtls_instr); 

load_l1hit_val <= ex3_load_l1hit and not ex3_larx_instr;

latch_ex4_load_l1hit_val : tri_rlmreg_p
  generic map (width => 1, init => 0, expand_type => expand_type)
  port map (nclk    => nclk,
            act     => '1',
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(ex4_load_l1hit_val_offset to ex4_load_l1hit_val_offset),
            scout   => sov(ex4_load_l1hit_val_offset to ex4_load_l1hit_val_offset),
            din(0)  => load_l1hit_val,
            dout(0) => ex4_load_l1hit_val);

dcbf_l_val <= ex3_dcbf_instr and (ex3_l_fld="01");
dcbf_g_val <= ex3_dcbf_instr and ((ex3_l_fld="00") or (ex3_l_fld="10"));
hwsync_val <= (ex3_sync_instr and ((ex3_l_fld /= "01") or my_xucr0_mbar_ack) ) or
              (ex3_mbar_instr and my_xucr0_mbar_ack);
lwsync_val <= ex3_sync_instr and (ex3_l_fld = "01") and not my_xucr0_mbar_ack;
mbar_val   <= ex3_mbar_instr and not my_xucr0_mbar_ack;

dcbt_l2only_val     <= ex3_dcbt_instr     and     ex3_th_fld_l2;
dcbt_l1l2_val       <= ex3_dcbt_instr     and not ex3_th_fld_l2;
dcbtls_l2only_val   <= ex3_dcbtls_instr   and     ex3_th_fld_l2;
dcbtls_l1l2_val     <= ex3_dcbtls_instr   and not ex3_th_fld_l2;
dcbtst_l2only_val   <= ex3_dcbtst_instr   and     ex3_th_fld_l2;
dcbtst_l1l2_val     <= ex3_dcbtst_instr   and not ex3_th_fld_l2;
dcbtstls_l2only_val <= ex3_dcbtstls_instr and     ex3_th_fld_l2;
dcbtstls_l1l2_val   <= ex3_dcbtstls_instr and not ex3_th_fld_l2;


cmd_type_ld(0 to 5) <= gate_and( load_val           , "001000") or
                       gate_and( ex3_larx_instr     , ("0010" & ex3_mutex_hint  & "1") ) or
                       gate_and( dcbt_l1l2_val      , "001111") or
                       gate_and( dcbt_l2only_val    , "000111") or
                       gate_and( dcbtls_l1l2_val    , "011111") or
                       gate_and( dcbtls_l2only_val  , "010111") or
                       gate_and( dcbtst_l1l2_val    , "001101") or
                       gate_and( dcbtst_l2only_val  , "000101") or
                       gate_and( dcbtstls_l1l2_val  , "011101") or
                       gate_and( dcbtstls_l2only_val, "010101") or
                       gate_and( ex3_icbt_instr     , "000100") or
                       gate_and( ex3_icbtls_instr   , "010100");

cmd_type_st(0 to 5) <= gate_and( ex3_store_instr    , "100000") or
                       gate_and( ex3_stx_instr      , "101001") or
                       gate_and( ex3_icbi_instr     , "111110") or
                       gate_and( dcbf_l_val         , "110110") or
                       gate_and( dcbf_g_val         , "110111") or
                       gate_and( ex3_dcbi_instr     , "111111") or
                       gate_and( ex3_dcbz_instr     , "100001") or
                       gate_and( ex3_dcbst_instr    , "110101") or
                       gate_and( hwsync_val         , "101011") or
                       gate_and( mbar_val           , "110010") or
                       gate_and( lwsync_val         , "101010") or
                       gate_and( ex3_tlbsync_instr  , "111010") or
                       gate_and( ex3_icblc_instr    , "100100") or
                       gate_and( ex3_dcblc_instr    , "100101") or 
                       gate_and( ex3_dci_instr      , "101111") or 
                       gate_and( ex3_ici_instr      , "101110") or
                       gate_and( ex3_msgsnd_instr   , "101101") or
                       gate_and( ex3_icswx_instr    , "100110") or
                       gate_and( ex3_icswx_dot      , "100111") or
                       gate_and( ex3_mtspr_trace    , "101100") or
                       gate_and( load_l1hit_val     , "110100");

                 
ex3_st_entry <= cmd_type_st(0 to 5) &             -- bit(0:5) = encoded command type(0 to 5)
                ex3_byte_en(0 to 31) &            -- bit(6:37) = byte enables(0 to 15)
                ex3_thrd_id(0 to 3) &             -- bit(38:41) = th_id(0 to 3)
                ex3_wimge_bits(4) &               -- bit(42) = little endian
                ex3_wimge_bits(0 to 3) &           -- bit(43:46) = wimg bits
                ex3_usr_bits(0 to 3) &            -- bit(47:50) = user defined bits
                ex3_opsize(0 to 5) &              -- bit(51:56) = transfer length
                ex3_icswx_epid &                  -- bit 57 = icswx is for external pid
                ex3_p_addr;                       -- bit(58:xx) = ex3_p_addr(0 to 63)

ex4_thrd_encode(0) <= ex4_thrd_id(2) or ex4_thrd_id(3);
ex4_thrd_encode(1) <= ex4_thrd_id(1) or ex4_thrd_id(3);

ex4_st_addr <= ex4_st_entry_l2(58 to (58+real_data_add-1)) when ex4_st_entry_l2(0 to 5)/="101100" else -- /mtspr_trace
               (0 to real_data_add-35 => '0') &                                -- zeros
                 anaclat_coreid(6 to 7) &                                      -- 30:31 core ID
                 ex4_thrd_encode(0 to 1) &                                     -- 32:33 thread ID
                 ex4_st_entry_l2(58+real_data_add-14 to 58+real_data_add-5) &  -- 34:43 mark type (from 50:59)
                 '0' &                                                         -- 44
                 ex4_st_entry_l2(58+real_data_add-4) &                         -- 45    mark valid (from 60)
                 ex4_st_entry_l2(58+real_data_add-1) &                         -- 46    start trig (from 63)
                 ex4_st_entry_l2(58+real_data_add-2) &                         -- 47    stop trig  (from 62)
                 ex4_st_entry_l2(58+real_data_add-3) &                         -- 48    pause trig (from 61)
                 "000000000000000";                                            -- 49:63
  
  
s_m_queue0_d <= s_m_queue0                 when (st_entry0_val_l2 and (not (store_credit and ex5_sel_st_req) or
                                                                       st_recycle_V_l2 or
                                                                      (l2req_recycle_l2 and ex7_ld_par_err)))='1'   else 
                ex4_st_entry_l2(0 to 57) & ex4_st_addr;

--************************************************************************************************************
--************************************************************************************************************
-- STORE QUEUE LOGIC
-- Store Miss Queue Entry - 4 store miss entries
--************************************************************************************************************
--************************************************************************************************************

st_val <= (((ex3_l_s_q_val and not ex3_load_instr) or load_l1hit_val) and -- not ex3_sync_instr and not ex3_eieio_instr and
              not flush_if_store and not ex3_stg_flush and not I1_G1_flush); -- or ex3_dci_instr or ex3_ici_instr;


thrd_hit_p:  process (l_m_queue(0)(18 to 21), l_m_queue(1)(18 to 21), l_m_queue(2)(18 to 21), l_m_queue(3)(18 to 21), l_m_queue(4)(18 to 21), l_m_queue(5)(18 to 21), l_m_queue(6)(18 to 21), l_m_queue(7)(18 to 21), ld_rel_val_l2, ex3_thrd_id, ex3_sync_instr, ex3_mbar_instr, ex3_tlbsync_instr)
   variable b0, b1, b2, b3: std_ulogic;
begin
      b0 := '0';
      b1 := '0';
      b2 := '0';
      b3 := '0';
      for i in 0 to lmq_entries-1 loop
         b0 := (l_m_queue(i)(18) and ld_rel_val_l2(i)) or b0;  -- thread 0 and entry is valid
         b1 := (l_m_queue(i)(19) and ld_rel_val_l2(i)) or b1;  -- thread 1 and entry is valid
         b2 := (l_m_queue(i)(20) and ld_rel_val_l2(i)) or b2;  -- thread 2 and entry is valid
         b3 := (l_m_queue(i)(21) and ld_rel_val_l2(i)) or b3;  -- thread 3 and entry is valid
      end loop;
   sync_flush <= ((ex3_thrd_id(0) and b0) or
                  (ex3_thrd_id(1) and b1) or
                  (ex3_thrd_id(2) and b2) or
                  (ex3_thrd_id(3) and b3)) and 
                 (ex3_sync_instr or ex3_mbar_instr or ex3_tlbsync_instr);
end process;



-- since this eq does not include xu_lsu_ex5_flush, it might be wrong and cause a new store to be flushed (if
-- there is only 1 st credit left)
nxt_st_cred_tkn <= (st_entry0_val_l2 and not (ex5_flush_store and ex5_st_val_l2)) or ob_req_val_l2 or ob_ditc_val_l2 or
                   (mmu_q_val and not mmu_q_entry_l2(0));
flush_if_store <= (one_st_cred      and  nxt_st_cred_tkn and  ex4_st_val_l2) or
                  (not store_credit and (st_entry0_val_l2 or  ex4_st_val_l2)) or
                  (my_xucr0_cred    and (st_entry0_val_l2 or  ex4_st_val_l2));

st_flush <= (not ex3_load_instr and flush_if_store) or sync_flush;

st_entry0_val_d <= (ex4_st_val_l2 and not ex4_flush_store) or
                   (st_entry0_val_l2 and not (store_credit and ex5_sel_st_req) and not (my_ex5_flush_store and ex5_st_val_l2 and not ex8_ld_par_err_l2)) or
                   (((l2req_recycle_l2 and ex7_ld_par_err and not (my_ex5_flush_store and ex5_st_val_l2)) or st_recycle_V_l2) and
                         st_entry0_val_l2 and not (my_ex5_flush_store and ex5_st_val_l2 and not ex8_ld_par_err_l2));
ex4_st_val_d <= st_val;



latch_ex4_st_val : tri_rlmreg_p
  generic map (width => 1, init => 0, expand_type => expand_type)
  port map (nclk    => nclk,
            act     => '1',
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(ex4_st_val_offset to ex4_st_val_offset),
            scout   => sov(ex4_st_val_offset to ex4_st_val_offset),
            din(0)  => ex4_st_val_d,
            dout(0) => ex4_st_val_l2);

ex4_st_valid <= ex4_st_val_l2 and not ex4_flush_store;

latch_ex5_st_val : tri_rlmreg_p
  generic map (width => 1, init => 0, expand_type => expand_type)
  port map (nclk    => nclk,
            act     => '1',
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(ex5_st_val_offset to ex5_st_val_offset),
            scout   => sov(ex5_st_val_offset to ex5_st_val_offset),
            din(0)  => ex4_st_valid,
            dout(0) => ex5_st_val_l2);

latch_ex6_st_val : tri_rlmreg_p
  generic map (width => 1, init => 0, expand_type => expand_type)
  port map (nclk    => nclk,
            act     => '1',
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(ex6_st_val_offset to ex6_st_val_offset),
            scout   => sov(ex6_st_val_offset to ex6_st_val_offset),
            din(0)  => ex5_st_val_l2,
            dout(0) => ex6_st_val_l2);

latch_s_m_queue0_val : tri_rlmreg_p
  generic map (width => 1, init => 0, expand_type => expand_type)
  port map (nclk    => nclk,
            act     => '1',
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(st_entry0_val_offset to st_entry0_val_offset),
            scout   => sov(st_entry0_val_offset to st_entry0_val_offset),
            din(0)  => st_entry0_val_d,
            dout(0) => st_entry0_val_l2);

latch_s_m_queue0_val_clone : tri_rlmreg_p
  generic map (width => 1, init => 0, expand_type => expand_type)
  port map (nclk    => nclk,
            act     => '1',
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(st_entry0_val_clone_offset to st_entry0_val_clone_offset),
            scout   => sov(st_entry0_val_clone_offset to st_entry0_val_clone_offset),
            din(0)  => st_entry0_val_d,
            dout(0) => st_entry0_val_clone_l2);

ex4_st_entry_act <= ex3_stg_act or ex3_dci_instr or ex3_ici_instr or clkg_ctl_override_q;

latch_ex4_st_entry : tri_rlmreg_p
  generic map (width => ex4_st_entry_l2'length, init => 0, expand_type => expand_type)
  port map (nclk    => nclk,
            act     => ex4_st_entry_act,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(ex4_st_entry_offset to ex4_st_entry_offset + ex4_st_entry_l2'length-1),
            scout   => sov(ex4_st_entry_offset to ex4_st_entry_offset + ex4_st_entry_l2'length-1),
            din     => ex3_st_entry,
            dout    => ex4_st_entry_l2);

latch_s_m_queue0 : tri_rlmreg_p
  generic map (width => s_m_queue0'length, init => 0, expand_type => expand_type)
  port map (nclk    => nclk,
            act     => stq_act,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(s_m_queue0_offset to s_m_queue0_offset + s_m_queue0'length-1),
            scout   => sov(s_m_queue0_offset to s_m_queue0_offset + s_m_queue0'length-1),
            din     => s_m_queue0_d,
            dout    => s_m_queue0);


--************************************************************************************************************
--************************************************************************************************************
-- END: STORE QUEUE LOGIC
--************************************************************************************************************
--************************************************************************************************************

--************************************************************************************************************
--************************************************************************************************************
-- LOAD QUEUE LOGIC
-- Load Miss Queue Entry - 4 load miss entries
--************************************************************************************************************
--************************************************************************************************************
ld_m_val <= (ex3_l_s_q_val and ex3_load_instr and not ld_queue_full and not ld_q_seq_wrap) or
            pe_recov_ld_val_l2;

ld_flush <= ex3_load_instr and (ld_queue_full or ld_q_seq_wrap);
ex4_ld_queue_full <= ld_flush and ex3_l_s_q_val;
ex4_st_queue_full <= st_flush and ex3_l_s_q_val;
ex4_ldhld_sthld_coll <=  l_m_fnd_stg and ex4_val_req;
ex3_i1_g1_coll <= I1_G1_flush and ex3_l_s_q_val;

ld_miss_latency_d <= (ld_entry_val_l2(0) and ex6_loadmiss_qentry(0) and not ex6_flush_l2) or
                     (ld_miss_latency_l2 and ld_entry_val_l2(0));


lsu_perf_events      <= ex5_ld_queue_full_l2 & ex5_st_queue_full_l2 & ex5_ldhld_sthld_coll_l2 & ex5_i1_g1_coll_l2;
lsu_xu_perf_events   <= lsu_perf_events_l2 & larx_done_tid_l2 & ld_miss_latency_l2;





latch_ex4_ld_m_val : tri_rlmreg_p
  generic map (width => 1, init => 0, expand_type => expand_type)
  port map (nclk    => nclk,
            act     => '1',
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(ex4_ld_m_val_offset to ex4_ld_m_val_offset),
            scout   => sov(ex4_ld_m_val_offset to ex4_ld_m_val_offset),
            din(0)  => ld_m_val,
            dout(0) => ex4_ld_m_val);

ex4_ld_m_val_not_fl <= ex4_ld_m_val and not ex4_flush_load;


latch_ex4_drop_ld_req : tri_rlmreg_p
  generic map (width => 1, init => 0, expand_type => expand_type)
  port map (nclk    => nclk,
            act     => '1',
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(ex4_drop_ld_req_offset to ex4_drop_ld_req_offset),
            scout   => sov(ex4_drop_ld_req_offset to ex4_drop_ld_req_offset),
            din(0)  => ex3_drop_ld_req,
            dout(0) => ex4_drop_ld_req);

latch_ex4_drop_touch : tri_rlmreg_p
  generic map (width => 1, init => 0, expand_type => expand_type)
  port map (nclk    => nclk,
            act     => '1',
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(ex4_drop_touch_offset to ex4_drop_touch_offset),
            scout   => sov(ex4_drop_touch_offset to ex4_drop_touch_offset),
            din(0)  => ex3_drop_touch,
            dout(0) => ex4_drop_touch);



latch_ex4_ld_queue_full : tri_rlmreg_p
  generic map (width => 1, init => 0, expand_type => expand_type)
  port map (nclk    => nclk,
            act     => '1',
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(ex4_ld_queue_full_offset to ex4_ld_queue_full_offset),
            scout   => sov(ex4_ld_queue_full_offset to ex4_ld_queue_full_offset),
            din(0)  => ex4_ld_queue_full,
            dout(0) => ex4_ld_queue_full_l2);

ex5_ld_queue_full_d <= ex4_ld_queue_full_l2 and not ex4_drop_ld_req;

latch_ex5_ld_queue_full : tri_rlmreg_p
  generic map (width => 1, init => 0, expand_type => expand_type)
  port map (nclk    => nclk,
            act     => '1',
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(ex5_ld_queue_full_offset to ex5_ld_queue_full_offset),
            scout   => sov(ex5_ld_queue_full_offset to ex5_ld_queue_full_offset),
            din(0)  => ex5_ld_queue_full_d,
            dout(0) => ex5_ld_queue_full_l2);

latch_ex4_st_queue_full : tri_rlmreg_p
  generic map (width => 1, init => 0, expand_type => expand_type)
  port map (nclk    => nclk,
            act     => '1',
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(ex4_st_queue_full_offset to ex4_st_queue_full_offset),
            scout   => sov(ex4_st_queue_full_offset to ex4_st_queue_full_offset),
            din(0)  => ex4_st_queue_full,
            dout(0) => ex4_st_queue_full_l2);

latch_ex5_st_queue_full : tri_rlmreg_p
  generic map (width => 1, init => 0, expand_type => expand_type)
  port map (nclk    => nclk,
            act     => '1',
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(ex5_st_queue_full_offset to ex5_st_queue_full_offset),
            scout   => sov(ex5_st_queue_full_offset to ex5_st_queue_full_offset),
            din(0)  => ex4_st_queue_full_l2,
            dout(0) => ex5_st_queue_full_l2);

latch_ex5_ldhld_sthld_coll : tri_rlmreg_p
  generic map (width => 1, init => 0, expand_type => expand_type)
  port map (nclk    => nclk,
            act     => '1',
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(ex5_ldhld_sthld_coll_offset to ex5_ldhld_sthld_coll_offset),
            scout   => sov(ex5_ldhld_sthld_coll_offset to ex5_ldhld_sthld_coll_offset),
            din(0)  => ex4_ldhld_sthld_coll,
            dout(0) => ex5_ldhld_sthld_coll_l2);

latch_ex4_i1_g1_coll : tri_rlmreg_p
  generic map (width => 1, init => 0, expand_type => expand_type)
  port map (nclk    => nclk,
            act     => '1',
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(ex4_i1_g1_coll_offset to ex4_i1_g1_coll_offset),
            scout   => sov(ex4_i1_g1_coll_offset to ex4_i1_g1_coll_offset),
            din(0)  => ex3_i1_g1_coll,
            dout(0) => ex4_i1_g1_coll_l2);

latch_ex5_i1_g1_coll : tri_rlmreg_p
  generic map (width => 1, init => 0, expand_type => expand_type)
  port map (nclk    => nclk,
            act     => '1',
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(ex5_i1_g1_coll_offset to ex5_i1_g1_coll_offset),
            scout   => sov(ex5_i1_g1_coll_offset to ex5_i1_g1_coll_offset),
            din(0)  => ex4_i1_g1_coll_l2,
            dout(0) => ex5_i1_g1_coll_l2);

latch_ld_miss_latency : tri_rlmreg_p
  generic map (width => 1, init => 0, expand_type => expand_type)
  port map (nclk    => nclk,
            act     => '1',
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(ld_miss_latency_offset to ld_miss_latency_offset),
            scout   => sov(ld_miss_latency_offset to ld_miss_latency_offset),
            din(0)  => ld_miss_latency_d,
            dout(0) => ld_miss_latency_l2);

latch_lsu_perf_events : tri_rlmreg_p
  generic map (width => lsu_perf_events_l2'length, init => 0, expand_type => expand_type)
  port map (nclk    => nclk,
            act     => '1',
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(lsu_perf_events_offset to lsu_perf_events_offset + lsu_perf_events_l2'length-1),
            scout   => sov(lsu_perf_events_offset to lsu_perf_events_offset + lsu_perf_events_l2'length-1),
            din     => lsu_perf_events,
            dout    => lsu_perf_events_l2);

ldqfull:  process (ld_rel_val_l2)
   variable b: std_ulogic;
begin
      b := '1';
      for i in 0 to lmq_entries-1 loop
         b := ld_rel_val_l2(i) and b;
      end loop;
      ld_queue_full <= b;
end process;

ex3_ld_queue_full <= ld_queue_full or ld_q_seq_wrap;

-- *****************************************************
--  Need to flush if command is I=1, G=1 load and there already is one in the load Q for that thread

ex4_st_I1_G1_val <= ex4_st_entry_l2(44) and ex4_st_entry_l2(46) and ex4_st_val_l2;
st_entry_I1_G1_val <= s_m_queue0(44) and s_m_queue0(46) and st_entry0_val_l2;

I1_G1_p:  process (l_m_queue(0)(18 to 21), l_m_queue(1)(18 to 21), l_m_queue(2)(18 to 21), l_m_queue(3)(18 to 21), l_m_queue(4)(18 to 21), l_m_queue(5)(18 to 21), l_m_queue(6)(18 to 21), l_m_queue(7)(18 to 21), l_m_queue(0)(40), l_m_queue(1)(40), l_m_queue(2)(40), l_m_queue(3)(40), l_m_queue(4)(40), l_m_queue(5)(40), l_m_queue(6)(40), l_m_queue(7)(40), l_m_queue(0)(42), l_m_queue(1)(42), l_m_queue(2)(42), l_m_queue(3)(42), l_m_queue(4)(42), l_m_queue(5)(42), l_m_queue(6)(42), l_m_queue(7)(42), ld_rel_val_l2, st_entry_I1_G1_val, s_m_queue0(38 to 41), ex4_st_I1_G1_val,  ex4_st_entry_l2(38 to 41))
   variable b0, b1, b2, b3: std_ulogic;
begin
      b0 := '0';
      b1 := '0';
      b2 := '0';
      b3 := '0';
      for i in 0 to lmq_entries-1 loop
         b0 := (l_m_queue(i)(40) and l_m_queue(i)(42) and l_m_queue(i)(18) and ld_rel_val_l2(i)) or b0;  -- I=1, G=1 for thread 0 and entry is valid
         b1 := (l_m_queue(i)(40) and l_m_queue(i)(42) and l_m_queue(i)(19) and ld_rel_val_l2(i)) or b1;  -- I=1, G=1 for thread 1 and entry is valid
         b2 := (l_m_queue(i)(40) and l_m_queue(i)(42) and l_m_queue(i)(20) and ld_rel_val_l2(i)) or b2;  -- I=1, G=1 for thread 2 and entry is valid
         b3 := (l_m_queue(i)(40) and l_m_queue(i)(42) and l_m_queue(i)(21) and ld_rel_val_l2(i)) or b3;  -- I=1, G=1 for thread 3 and entry is valid
      end loop;
      I1_G1_thrd0 <= b0 or (ex4_st_I1_G1_val and ex4_st_entry_l2(38)) or (st_entry_I1_G1_val and s_m_queue0(38));
      I1_G1_thrd1 <= b1 or (ex4_st_I1_G1_val and ex4_st_entry_l2(39)) or (st_entry_I1_G1_val and s_m_queue0(39));
      I1_G1_thrd2 <= b2 or (ex4_st_I1_G1_val and ex4_st_entry_l2(40)) or (st_entry_I1_G1_val and s_m_queue0(40));
      I1_G1_thrd3 <= b3 or (ex4_st_I1_G1_val and ex4_st_entry_l2(41)) or (st_entry_I1_G1_val and s_m_queue0(41));
end process;

ex3_wimg_g_gated <= ex3_wimge_bits(3) and not (ex3_msgsnd_instr or ex3_dci_instr or ex3_ici_instr or ex3_mtspr_trace or
                                               ex3_sync_instr or ex3_mbar_instr or ex3_tlbsync_instr);

I1_G1_flush <= (ex3_wimge_bits(1) and ex3_wimg_g_gated and ex3_thrd_id(0) and I1_G1_thrd0) or
               (ex3_wimge_bits(1) and ex3_wimg_g_gated and ex3_thrd_id(1) and I1_G1_thrd1) or
               (ex3_wimge_bits(1) and ex3_wimg_g_gated and ex3_thrd_id(2) and I1_G1_thrd2) or
               (ex3_wimge_bits(1) and ex3_wimg_g_gated and ex3_thrd_id(3) and I1_G1_thrd3);   


--******************************************************
-- Check to see if command is already in the load/store miss CAM
--******************************************************
-- Want to flush if we have a cacheable load op accessing the same cacheline as an op
-- already in the load miss queue or if we have a store going to the same cacheline and
-- a load op is waiting for data to be returned

addr_comp:  for i in 0 to lmq_entries-1 generate begin
   comp_val(i) <= ld_rel_val_l2(i) and ex3_cache_acc and not(ex4_drop_ld_req and ex4_loadmiss_qentry(i)) and not(my_ex4_flush_l2 and ex4_loadmiss_qentry(i));
   cmp_ldq_comp_val(i) <= comp_val(i);
   l_m_q_cpy(i) <= cmp_ldq_match(i);
   l_m_q_cpy_nofl(i) <= l_m_q_cpy(i) and comp_val(i) and not ex3_stg_flush;
end generate;





l_m_fnd_nofl <= cmp_ldq_fnd and not ex3_stg_flush;

entry_found_latch : tri_rlmreg_p
  generic map (width => 1, init => 0, expand_type => expand_type)
  port map (nclk    => nclk,
            act     => ldq_act,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(l_m_fnd_offset to l_m_fnd_offset),
            scout   => sov(l_m_fnd_offset to l_m_fnd_offset),
            din(0)  => l_m_fnd_nofl,
            dout(0) => l_m_fnd_stg);


latch_ex4_lmq_cpy : tri_rlmreg_p
  generic map (width => ex4_lmq_cpy_l2'length, init => 0, expand_type => expand_type)
  port map (nclk    => nclk,
            act     => ldq_act,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(ex4_lmq_cpy_offset to ex4_lmq_cpy_offset + ex4_lmq_cpy_l2'length-1),
            scout   => sov(ex4_lmq_cpy_offset to ex4_lmq_cpy_offset + ex4_lmq_cpy_l2'length-1),
            din     => l_m_q_cpy_nofl(0 to lmq_entries-1),
            dout    => ex4_lmq_cpy_l2(0 to lmq_entries-1));
latch_ex5_lmq_cpy : tri_rlmreg_p
  generic map (width => ex5_lmq_cpy_l2'length, init => 0, expand_type => expand_type)
  port map (nclk    => nclk,
            act     => ldq_act,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(ex5_lmq_cpy_offset to ex5_lmq_cpy_offset + ex5_lmq_cpy_l2'length-1),
            scout   => sov(ex5_lmq_cpy_offset to ex5_lmq_cpy_offset + ex5_lmq_cpy_l2'length-1),
            din     => ex4_lmq_cpy_l2(0 to lmq_entries-1),
            dout    => ex5_lmq_cpy_l2(0 to lmq_entries-1));


-- *************************************************************************
-- check gpr source for new ops to look for dependency on loadmiss target

targetgpr_comp:  for i in 0 to lmq_entries-1 generate begin
   src0_hit(i) <= (ex1_src0_reg(0 to 7) = l_m_queue(i)(28 to 35)) and ld_rel_val_l2(i) and not (ex4_drop_ld_req and ex4_loadmiss_qentry(i)) and
                     not l_m_queue(i)(36) and not l_m_queue(i)(38) and not gpr_updated_dly2_l2(i);
   src1_hit(i) <= (ex1_src1_reg(0 to 7) = l_m_queue(i)(28 to 35)) and ld_rel_val_l2(i) and not (ex4_drop_ld_req and ex4_loadmiss_qentry(i)) and
                     not l_m_queue(i)(36) and not l_m_queue(i)(38) and not gpr_updated_dly2_l2(i);
   targ_hit(i) <= (ex1_targ_reg(0 to 7) = l_m_queue(i)(28 to 35)) and ld_rel_val_l2(i) and not (ex4_drop_ld_req and ex4_loadmiss_qentry(i)) and
                     not l_m_queue(i)(36) and not l_m_queue(i)(38) and not gpr_updated_dly2_l2(i);

   watch_bit_v_t0(i) <= ld_rel_val_l2(i) and l_m_queue(i)(52) and l_m_queue(i)(18);
   watch_bit_v_t1(i) <= ld_rel_val_l2(i) and l_m_queue(i)(52) and l_m_queue(i)(19);
   watch_bit_v_t2(i) <= ld_rel_val_l2(i) and l_m_queue(i)(52) and l_m_queue(i)(20);
   watch_bit_v_t3(i) <= ld_rel_val_l2(i) and l_m_queue(i)(52) and l_m_queue(i)(21);
end generate;

watch_hit_t0 <= or_reduce(watch_bit_v_t0) and ex1_check_watch(0);
watch_hit_t1 <= or_reduce(watch_bit_v_t1) and ex1_check_watch(1);
watch_hit_t2 <= or_reduce(watch_bit_v_t2) and ex1_check_watch(2);
watch_hit_t3 <= or_reduce(watch_bit_v_t3) and ex1_check_watch(3);

watch_hit <= watch_hit_t0 or watch_hit_t1 or watch_hit_t2 or watch_hit_t3;

lm_dep_hit_or:  process (src0_hit, src1_hit, targ_hit, ex1_src0_vld, ex1_src1_vld, ex1_targ_vld, watch_hit)
   variable src0_hit_or: std_ulogic;
   variable src1_hit_or: std_ulogic;
   variable targ_hit_or: std_ulogic;
begin
      src0_hit_or := '0';
      src1_hit_or := '0';
      targ_hit_or := '0';
      for i in 0 to lmq_entries-1 loop
         src0_hit_or := src0_hit(i) or src0_hit_or;
         src1_hit_or := src1_hit(i) or src1_hit_or;
         targ_hit_or := targ_hit(i) or targ_hit_or;
      end loop;
      ex1_lm_dep_hit <= (src0_hit_or and ex1_src0_vld) or
                        (src1_hit_or and ex1_src1_vld) or
                        (targ_hit_or and ex1_targ_vld) or watch_hit;
end process;

lm_dep_hit_latch : tri_rlmreg_p
  generic map (width => 1, init => 0, expand_type => expand_type)
  port map (nclk    => nclk,
            act     => ldq_act,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(lm_dep_hit_offset to lm_dep_hit_offset),
            scout   => sov(lm_dep_hit_offset to lm_dep_hit_offset),
            din(0)  => ex1_lm_dep_hit,
            dout(0) => ex2_lm_dep_hit_buf);

ex2_lm_dep_hit <= ex2_lm_dep_hit_buf;

-- *************************************************************************
-- Compare back invalidate address to each entry in the load miss queue and
-- set a bit to remember that this address has been invalidated and cannot
-- be written valid in the directory when the reload in finished.

cmp_back_inv_addr <= anaclat_back_inv_addr(64-real_data_add to 57);

back_inv_addr_comp:  for i in 0 to lmq_entries-1 generate begin
cmp_back_inv_cmp_val(i) <= back_inv_val_l2 and                            
                           ld_rel_val_l2(i) and not ld_entry_val_l2(i) and not ex4_loadmiss_qentry(i);   

lmq_back_invalidated_d(i) <= (cmp_back_inv_addr_hit(i)   and not reset_lmq_entry(i) ) or
                             (lmq_back_invalidated_l2(i) and not reset_lmq_entry(i) );

end generate;

latch_lmq_back_invalidated : tri_rlmreg_p
  generic map (width => lmq_back_invalidated_l2'length, init => 0, expand_type => expand_type)
  port map (nclk    => nclk,
            act     => ldq_act,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(lmq_back_invalidated_offset to lmq_back_invalidated_offset + lmq_back_invalidated_l2'length-1),
            scout   => sov(lmq_back_invalidated_offset to lmq_back_invalidated_offset + lmq_back_invalidated_l2'length-1),
            din     => lmq_back_invalidated_d(0 to lmq_entries-1),
            dout    => lmq_back_invalidated_l2(0 to lmq_entries-1));



--******************************************************
-- Use a first slot open method for the load
-- Override a Reload Queue entry when the reload has returned
--******************************************************
-- Select which ld miss entry to write to
--l_q0_wrt_en <= not ld_entry0_val_l2 and ld_m_val;
--l_q1_wrt_en <= ld_entry0_val_l2 and not ld_entry1_val_l2 and ld_m_val;
--l_q2_wrt_en <= ld_entry0_val_l2 and ld_entry1_val_l2 and not ld_entry2_val_l2 and ld_m_val;
--l_q3_wrt_en <= ld_entry0_val_l2 and ld_entry1_val_l2 and ld_entry2_val_l2 and not ld_entry3_val_l2 and ld_m_val;

-- Select which ld miss entry to write to
--l_q0_wrt_en <= not ld_rel0_val_l2 and ld_m_val;
--l_q1_wrt_en <= ld_rel0_val_l2 and not ld_rel1_val_l2 and ld_m_val;
--l_q2_wrt_en <= ld_rel0_val_l2 and ld_rel1_val_l2 and not ld_rel2_val_l2 and ld_m_val;
--l_q3_wrt_en <= ld_rel0_val_l2 and ld_rel1_val_l2 and ld_rel2_val_l2 and not ld_rel3_val_l2 and ld_m_val;

-- see above commented out logic to see what this is building:

l_q_wrt_en(0) <= ld_m_val and ((not ld_rel_val_l2(0)   and not pe_recov_ld_val_l2) or
                               (ex7_loadmiss_qentry(0) and     pe_recov_ld_val_l2));

wrten: for i in 1 to lmq_entries-1 generate begin
   wrten_p:  process (ld_rel_val_l2(0 to i), ld_m_val, ex7_loadmiss_qentry(i), pe_recov_ld_val_l2)
      variable b: std_ulogic;
   begin
         b := '1';
         for j in 0 to i-1 loop
            b := ld_rel_val_l2(j) and b;
         end loop;
         l_q_wrt_en(i) <= ld_m_val and ((not ld_rel_val_l2(i) and b and not pe_recov_ld_val_l2) or
                                        (ex7_loadmiss_qentry(i)     and     pe_recov_ld_val_l2));
   end process;
end generate;
cmp_l_q_wrt_en <= l_q_wrt_en;

--******************************************************
-- Load Miss Queue entry0
--******************************************************


rel_done_ecc_err_p:  process (ld_m_rel_done_l2, data_ecc_err_l2)
   variable b: std_ulogic;
begin
      b := '0';
      for i in 0 to lmq_entries-1 loop
         b := (ld_m_rel_done_l2(i) and data_ecc_err_l2(i)) or b;
      end loop;
      rel_done_ecc_err <= b;
end process;


cmp_s_m_queue0_addr <= s_m_queue0(58 to (58+real_data_add-6-1));
cmp_st_entry0_val <= st_entry0_val_l2;
cmp_ex4_st_entry_addr <= ex4_st_entry_l2(58 to (58+real_data_add-6-1));
cmp_ex4_st_val <= ex4_st_val_l2;

lmq_entry_act <= ex3_stg_act or pe_recov_ld_val_l2 or clkg_ctl_override_q;
cmp_lmq_entry_act <= lmq_entry_act;

ldqueue: for i in 0 to lmq_entries-1 generate begin



   ld_entry_val_d(i) <= (ex4_loadmiss_qentry(i) and not ex4_flush_load) or
                        (ld_entry_val_l2(i) and not (load_sent and l_q_rd_en(i)) and
                              not(ex5_loadmiss_qentry(i) and (ex7_ld_par_err or ex5_flush_load_local)) and
                              not(ex6_loadmiss_qentry(i) and (ex7_ld_par_err or ex6_flush_l2)));



-- Want to update ld_rel_valid_l2 when either of the following conditions are met
-- 1) When its the next queue entry to update
-- 2) When the reload is done for that queue entry
-- 3) When this load queue entry has been sent to the L2/BFM and its a lock instruction and caused a hit in the L1
-- 4) When this load queue entry has been sent to the L2/BFM and its encoded command type bit0 was high
--      encoded_cmd_type(0) <= indicates command is a dcbf or dcbi or icbi and is not expecting a reload

-- all lock instr are cache miss now and all instr that do not get a reload go to the store Q

   reset_lmq_entry(i) <= reset_lmq_entry_rel(i) or
                         (ex4_loadmiss_qentry(i) and ex4_flush_load) or
                         (ex5_loadmiss_qentry(i) and ex5_flush_load_local) or 
                         (ex5_loadmiss_qentry(i) and pe_recov_stall and ex6_flush_l2) or 
                         (ex5_loadmiss_qentry(i) and ex7_ld_par_err) or 
                         (ex6_loadmiss_qentry(i) and ex7_ld_par_err) or 
                         (ex6_loadmiss_qentry(i) and not ex4_loadmiss_qentry(i) and ex6_flush_l2);  -- don't reset on an ex6 flush if the entry has already been reloaded

   reset_ldq_hit_barr(i) <= ld_m_rel_done_no_retry(i) or ld_m_rel_done_dly_l2(i) or reset_lmq_entry(i);


   ld_rel_val_d(i) <= l_q_wrt_en(i) or
                      (ld_rel_val_l2(i) and not reset_lmq_entry(i));


   with l_q_wrt_en(i) select
       l_m_queue_d(i) <= ld_queue_entry   when '1',
                         l_m_queue(i)     when others;

   with l_q_wrt_en(i) select
       l_m_queue_addrlo_d(i) <= ld_queue_addrlo(57 to 63)    when '1',
                                l_m_queue_addrlo(i)          when others;


   latch_l_m_queue : tri_rlmreg_p
     generic map (width => l_m_queue(i)'length, init => 0, expand_type => expand_type)
     port map (nclk    => nclk,
               act     => lmq_entry_act,
               forcee => func_sl_force,
               d_mode  => d_mode_dc,
               delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b,
               mpw2_b  => mpw2_dc_b,
               thold_b => func_sl_thold_0_b,
               sg      => sg_0,
               vd      => vdd,
               gd      => gnd,
               scin    => siv(l_m_queue_offset+(i*l_m_queue(i)'length) to l_m_queue_offset+(i*l_m_queue(i)'length) + l_m_queue(i)'length-1),
               scout   => sov(l_m_queue_offset+(i*l_m_queue(i)'length) to l_m_queue_offset+(i*l_m_queue(i)'length) + l_m_queue(i)'length-1),
               din     => l_m_queue_d(i),
               dout    => l_m_queue(i));

   latch_l_m_queue_addrlo : tri_rlmreg_p
     generic map (width => l_m_queue_addrlo(i)'length, init => 0, expand_type => expand_type)
     port map (nclk    => nclk,
               act     => lmq_entry_act,
               forcee => func_sl_force,
               d_mode  => d_mode_dc,
               delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b,
               mpw2_b  => mpw2_dc_b,
               thold_b => func_sl_thold_0_b,
               sg      => sg_0,
               vd      => vdd,
               gd      => gnd,
               scin    => siv(l_m_queue_addrlo_offset+(i*l_m_queue_addrlo(i)'length) to l_m_queue_addrlo_offset+(i*l_m_queue_addrlo(i)'length) + l_m_queue_addrlo(i)'length-1),
               scout   => sov(l_m_queue_addrlo_offset+(i*l_m_queue_addrlo(i)'length) to l_m_queue_addrlo_offset+(i*l_m_queue_addrlo(i)'length) + l_m_queue_addrlo(i)'length-1),
               din     => l_m_queue_addrlo_d(i),
               dout    => l_m_queue_addrlo(i));


   l_m_q_hit_st_d(i) <= (cmp_ex3addr_hit_stq and l_q_wrt_en(i) and not store_sent and not pe_recov_ld_val_l2) or
                        (cmp_ex3addr_hit_ex4st and l_q_wrt_en(i) and not pe_recov_ld_val_l2) or
                        (ex7_ld_recov_extra_l2(0) and not store_sent and l_q_wrt_en(i) and pe_recov_ld_val_l2) or 
                        (l_m_q_hit_st_l2(i) and (not store_sent and st_entry0_val_l2) and not reset_lmq_entry(i));

   lmq_drop_rel_d(i) <= (ex4_drop_rel             and (ex4_loadmiss_qentry(i) and not pe_recov_state_l2)) or
                        (ex8_ld_recov_extra_l2(1) and (ex4_loadmiss_qentry(i) and     pe_recov_state_l2)) or 
                        (lmq_drop_rel_l2(i)       and not ex4_loadmiss_qentry(i));

   lmq_dvc1_en_d(i) <= (xu_lsu_ex4_dvc1_en        and (ex4_loadmiss_qentry(i) and not pe_recov_state_l2)) or
                        (ex8_ld_recov_extra_l2(2) and (ex4_loadmiss_qentry(i) and     pe_recov_state_l2)) or 
                       (lmq_dvc1_en_l2(i)         and not ex4_loadmiss_qentry(i));

   lmq_dvc2_en_d(i) <= (xu_lsu_ex4_dvc2_en        and (ex4_loadmiss_qentry(i) and not pe_recov_state_l2)) or
                        (ex8_ld_recov_extra_l2(3) and (ex4_loadmiss_qentry(i) and     pe_recov_state_l2)) or 
                       (lmq_dvc2_en_l2(i)         and not ex4_loadmiss_qentry(i));

end generate;

latch_l_m_entry_val : tri_rlmreg_p
  generic map (width => ld_entry_val_l2'length, init => 0, expand_type => expand_type)
  port map (nclk    => nclk,
            act     => ldq_act,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(ld_entry_val_offset to ld_entry_val_offset + ld_entry_val_l2'length-1),
            scout   => sov(ld_entry_val_offset to ld_entry_val_offset + ld_entry_val_l2'length-1),
            din     => ld_entry_val_d,
            dout    => ld_entry_val_l2);
latch_l_m_rel_val : tri_rlmreg_p
  generic map (width => ld_rel_val_l2'length, init => 0, expand_type => expand_type)
  port map (nclk    => nclk,
            act     => ldq_act,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(ld_rel_val_offset to ld_rel_val_offset + ld_rel_val_l2'length-1),
            scout   => sov(ld_rel_val_offset to ld_rel_val_offset + ld_rel_val_l2'length-1),
            din     => ld_rel_val_d,
            dout    => ld_rel_val_l2);
latch_l_m_q_hit_st : tri_rlmreg_p
  generic map (width => l_m_q_hit_st_l2'length, init => 0, expand_type => expand_type)
  port map (nclk    => nclk,
            act     => '1',
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(l_m_q_hit_st_offset to l_m_q_hit_st_offset + l_m_q_hit_st_l2'length-1),
            scout   => sov(l_m_q_hit_st_offset to l_m_q_hit_st_offset + l_m_q_hit_st_l2'length-1),
            din     => l_m_q_hit_st_d,
            dout    => l_m_q_hit_st_l2);

latch_lmq_drop_rel : tri_rlmreg_p
  generic map (width => lmq_drop_rel_l2'length, init => 0, expand_type => expand_type)
  port map (nclk    => nclk,
            act     => ldq_act,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(lmq_drop_rel_offset to lmq_drop_rel_offset + lmq_drop_rel_l2'length-1),
            scout   => sov(lmq_drop_rel_offset to lmq_drop_rel_offset + lmq_drop_rel_l2'length-1),
            din     => lmq_drop_rel_d,
            dout    => lmq_drop_rel_l2);

latch_lmq_dvc1_en : tri_rlmreg_p
  generic map (width => lmq_dvc1_en_l2'length, init => 0, expand_type => expand_type)
  port map (nclk    => nclk,
            act     => ldq_act,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(lmq_dvc1_en_offset to lmq_dvc1_en_offset + lmq_dvc1_en_l2'length-1),
            scout   => sov(lmq_dvc1_en_offset to lmq_dvc1_en_offset + lmq_dvc1_en_l2'length-1),
            din     => lmq_dvc1_en_d,
            dout    => lmq_dvc1_en_l2);

latch_lmq_dvc2_en : tri_rlmreg_p
  generic map (width => lmq_dvc2_en_l2'length, init => 0, expand_type => expand_type)
  port map (nclk    => nclk,
            act     => ldq_act,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(lmq_dvc2_en_offset to lmq_dvc2_en_offset + lmq_dvc2_en_l2'length-1),
            scout   => sov(lmq_dvc2_en_offset to lmq_dvc2_en_offset + lmq_dvc2_en_l2'length-1),
            din     => lmq_dvc2_en_d,
            dout    => lmq_dvc2_en_l2);

--************************************************************************************************************
-- Load parity error recovery pipe - load commands are kept unitl ex7 so that if the load got a parity error
--                                   it can be re-inserted into the load queue from this pipe.  The load
--                                   command behind it (ex6) must also be re-inserted into the load queue
--                                   in order behind the ex7 load.  The rest of the loads (ex4 and ex5) will
--                                   be flushed.
--************************************************************************************************************

ex4_ld_entry_d <= cmd_type_ld(0 to 5) &
                  ex3_wimge_bits(0 to 4) &
                  ex3_usr_bits(0 to 3);

latch_ex4_ld_recov : tri_rlmreg_p
  generic map (width => ex4_ld_entry_l2'length, init => 0, expand_type => expand_type)
  port map (nclk    => nclk,
            act     => lmq_entry_act,
         forcee => func_sl_force,
         d_mode  => d_mode_dc,
         delay_lclkr => delay_lclkr_dc,
         mpw1_b  => mpw1_dc_b,
         mpw2_b  => mpw2_dc_b,
         thold_b => func_sl_thold_0_b,
         sg      => sg_0,
         vd      => vdd,
         gd      => gnd,
         scin    => siv(ex4_ld_recov_offset to ex4_ld_recov_offset + ex4_ld_entry_l2'length-1),
         scout   => sov(ex4_ld_recov_offset to ex4_ld_recov_offset + ex4_ld_entry_l2'length-1),
         din     => ex4_ld_entry_d,
         dout    => ex4_ld_entry_l2);

latch_ex4_classid : tri_rlmreg_p
  generic map (width => ex4_classid_l2'length, init => 0, expand_type => expand_type)
  port map (nclk    => nclk,
            act     => lmq_entry_act,
         forcee => func_sl_force,
         d_mode  => d_mode_dc,
         delay_lclkr => delay_lclkr_dc,
         mpw1_b  => mpw1_dc_b,
         mpw2_b  => mpw2_dc_b,
         thold_b => func_sl_thold_0_b,
         sg      => sg_0,
         vd      => vdd,
         gd      => gnd,
         scin    => siv(ex4_classid_offset to ex4_classid_offset + ex4_classid_l2'length-1),
         scout   => sov(ex4_classid_offset to ex4_classid_offset + ex4_classid_l2'length-1),
         din     => ex3_classid(0 to 1),
         dout    => ex4_classid_l2);

ex4_ld_recov_val_d <= ex3_l_s_q_val and ex3_load_instr;

latch_ex4_ld_recov_val : tri_rlmreg_p
  generic map (width => 1, init => 0, expand_type => expand_type)
  port map (nclk    => nclk,
            act     => '1',
         forcee => func_sl_force,
         d_mode  => d_mode_dc,
         delay_lclkr => delay_lclkr_dc,
         mpw1_b  => mpw1_dc_b,
         mpw2_b  => mpw2_dc_b,
         thold_b => func_sl_thold_0_b,
         sg      => sg_0,
         vd      => vdd,
         gd      => gnd,
         scin    => siv(ex4_ld_recov_val_offset to ex4_ld_recov_val_offset),
         scout   => sov(ex4_ld_recov_val_offset to ex4_ld_recov_val_offset),
         din(0)  => ex4_ld_recov_val_d,
         dout(0) => ex4_ld_recov_val_l2);

ex4_ld_entry_hit_st_d <= (cmp_ex3addr_hit_stq and not store_sent and not pe_recov_ld_val_l2) or
                         (cmp_ex3addr_hit_ex4st and not pe_recov_ld_val_l2);

latch_ex4_ld_entry_hit_st : tri_rlmreg_p
  generic map (width => 1, init => 0, expand_type => expand_type)
  port map (nclk    => nclk,
            act     => '1',
         forcee => func_sl_force,
         d_mode  => d_mode_dc,
         delay_lclkr => delay_lclkr_dc,
         mpw1_b  => mpw1_dc_b,
         mpw2_b  => mpw2_dc_b,
         thold_b => func_sl_thold_0_b,
         sg      => sg_0,
         vd      => vdd,
         gd      => gnd,
         scin    => siv(ex4_ld_entry_hit_st_offset to ex4_ld_entry_hit_st_offset),
         scout   => sov(ex4_ld_entry_hit_st_offset to ex4_ld_entry_hit_st_offset),
         din(0)  => ex4_ld_entry_hit_st_d,
         dout(0) => ex4_ld_entry_hit_st_l2);

ex4_ld_recov_mux: process(ex4_loadmiss_qentry, l_m_queue, l_m_queue_addrlo(0)(58 to 63), l_m_queue_addrlo(1)(58 to 63), l_m_queue_addrlo(2)(58 to 63), l_m_queue_addrlo(3)(58 to 63), l_m_queue_addrlo(4)(58 to 63), l_m_queue_addrlo(5)(58 to 63), l_m_queue_addrlo(6)(58 to 63), l_m_queue_addrlo(7)(58 to 63), l_m_q_hit_st_l2)
   variable b: std_ulogic_vector(0 to 53);
   variable c: std_ulogic;
   variable d: std_ulogic_vector(58 to 63);
begin
      b := (others => '0') ;
      d := (others => '0') ;
      c := '0';
      for i in 0 to lmq_entries-1 loop
         b := gate_and(ex4_loadmiss_qentry(i), l_m_queue(i)) or b;
         d := gate_and(ex4_loadmiss_qentry(i), l_m_queue_addrlo(i)(58 to 63)) or d;
         c := (ex4_loadmiss_qentry(i) and l_m_q_hit_st_l2(i)) or c;
     end loop;
      ex4_ld_recov_entry <= b;
      ex4_ld_recov_addrlo <= d;
      ex4_ld_recov_ld_hit_st <= c;
end process;

ex4_touch <= ( ex4_ld_entry_l2(0 to 5) = "001111") or    -- dcbt
             ( ex4_ld_entry_l2(0 to 5) = "000111") or    -- dcbt_l2only
             ( ex4_ld_entry_l2(0 to 5) = "011111") or    -- dcbtls_l1l2
             ( ex4_ld_entry_l2(0 to 5) = "010111") or    -- dcbtls_l2only
             ( ex4_ld_entry_l2(0 to 5) = "001101") or    -- dcbtst_l1l2
             ( ex4_ld_entry_l2(0 to 5) = "000101") or    -- dcbtst_l2only
             ( ex4_ld_entry_l2(0 to 5) = "011101") or    -- dcbtstls_l1l2
             ( ex4_ld_entry_l2(0 to 5) = "010101") or    -- dcbtstls_l2only
             ( ex4_ld_entry_l2(0 to 5) = "000100") or    -- icbt
             ( ex4_ld_entry_l2(0 to 5) = "010100");      -- icbtls

ex4_l2only <=( ex4_ld_entry_l2(0 to 5) = "000111") or    -- dcbt_l2only
             ( ex4_ld_entry_l2(0 to 5) = "010111") or    -- dcbtls_l2only
             ( ex4_ld_entry_l2(0 to 5) = "000101") or    -- dcbtst_l2only
             ( ex4_ld_entry_l2(0 to 5) = "010101") or    -- dcbtstls_l2only
             ( ex4_ld_entry_l2(0 to 5) = "000100") or    -- icbt
             ( ex4_ld_entry_l2(0 to 5) = "010100");      -- icbtls

ex4_ld_recov <= ex4_ld_recov_entry(0 to 53) & cmp_ex4_ld_addr & ex4_ld_recov_addrlo(58 to 63)  when ex4_ld_m_val='1' else
                ex4_ld_entry(0) &                 -- cache inhibit
                ex4_ld_entry_l2(0 to 5) &         -- ttype
                ex4_ld_entry(1 to 6) &            -- opsize
                ex4_ld_entry(7 to 11) &           -- rot sel
                ex4_thrd_id(0 to 3) &
                cmd_seq_l2(0 to 4) &
                ex4_ld_entry(12 to 20) &           -- target gpr
                ex4_ld_entry(21) &                 -- axu op
                ex4_ld_entry(22) &                 -- little endian mode
                ex4_touch &                        -- dcbt is valid
                ex4_ld_entry_l2(6 to 9) &          -- wimg bits
                ex4_ld_entry_l2(11 to 14) &        -- user defined bits
                ex4_ld_entry(23) &                 -- algebraic
                ex4_l2only &                       -- L2 only
                ex4_ld_entry(24) &                 -- way lock
                ex4_classid_l2(0 to 1) &           -- way lock bits table select bit (classid)
                ex4_ld_entry(25) &                 -- watch enable
                ex4_ld_entry_l2(10) &              -- le bit from erat
                ex4_ld_entry(26 to (26+(real_data_add-1)));             -- p_addr
                

ex5_ld_recov_d <= ex4_ld_recov   when pe_recov_stall='0' else
                  ex5_ld_recov_l2;

latch_ex5_ld_recov : tri_rlmreg_p
  generic map (width => ex5_ld_recov_l2'length, init => 0, expand_type => expand_type)
  port map (nclk    => nclk,
            act     => ex4_stg_act,
         forcee => func_sl_force,
         d_mode  => d_mode_dc,
         delay_lclkr => delay_lclkr_dc,
         mpw1_b  => mpw1_dc_b,
         mpw2_b  => mpw2_dc_b,
         thold_b => func_sl_thold_0_b,
         sg      => sg_0,
         vd      => vdd,
         gd      => gnd,
         scin    => siv(ex5_ld_recov_offset to ex5_ld_recov_offset + ex5_ld_recov_l2'length-1),
         scout   => sov(ex5_ld_recov_offset to ex5_ld_recov_offset + ex5_ld_recov_l2'length-1),
         din     => ex5_ld_recov_d,
         dout    => ex5_ld_recov_l2);


ex6_ld_recov_d <= ex5_ld_recov_l2   when pe_recov_stall='0' else
                  ex6_ld_recov_l2(0 to 37) & '1' & ex6_ld_recov_l2(39 to (54+(real_data_add-1))) when (pe_recov_state_l2 and not pe_recov_state_dly_l2 and ex7_targ_match)='1' else 
                  ex6_ld_recov_l2;

ex6_ld_recov_act <= ex5_ld_recov_val_l2 or clkg_ctl_override_q or ex6_ld_recov_val_l2;

latch_ex6_ld_recov : tri_rlmreg_p
  generic map (width => ex6_ld_recov_l2'length, init => 0, expand_type => expand_type)
  port map (nclk    => nclk,
            act     => ex6_ld_recov_act,
         forcee => func_sl_force,
         d_mode  => d_mode_dc,
         delay_lclkr => delay_lclkr_dc,
         mpw1_b  => mpw1_dc_b,
         mpw2_b  => mpw2_dc_b,
         thold_b => func_sl_thold_0_b,
         sg      => sg_0,
         vd      => vdd,
         gd      => gnd,
         scin    => siv(ex6_ld_recov_offset to ex6_ld_recov_offset + ex6_ld_recov_l2'length-1),
         scout   => sov(ex6_ld_recov_offset to ex6_ld_recov_offset + ex6_ld_recov_l2'length-1),
         din     => ex6_ld_recov_d,
         dout    => ex6_ld_recov_l2);


ex7_ld_recov_d <= ex6_ld_recov_l2   when pe_recov_stall='0' else
                  ex7_ld_recov_l2(0 to 37) & '1' & ex7_ld_recov_l2(39 to (54+(real_data_add-1))) when (pe_recov_state_l2 and not pe_recov_state_dly_l2 and ex8_targ_match)='1' else 
                  ex7_ld_recov_l2;

ex7_ld_recov_act <= ex6_ld_recov_val_l2 or clkg_ctl_override_q or ex7_ld_recov_val_l2;

latch_ex7_ld_recov : tri_rlmreg_p
  generic map (width => ex7_ld_recov_l2'length, init => 0, expand_type => expand_type)
  port map (nclk    => nclk,
            act     => ex7_ld_recov_act,
         forcee => func_sl_force,
         d_mode  => d_mode_dc,
         delay_lclkr => delay_lclkr_dc,
         mpw1_b  => mpw1_dc_b,
         mpw2_b  => mpw2_dc_b,
         thold_b => func_sl_thold_0_b,
         sg      => sg_0,
         vd      => vdd,
         gd      => gnd,
         scin    => siv(ex7_ld_recov_offset to ex7_ld_recov_offset + ex7_ld_recov_l2'length-1),
         scout   => sov(ex7_ld_recov_offset to ex7_ld_recov_offset + ex7_ld_recov_l2'length-1),
         din     => ex7_ld_recov_d,
         dout    => ex7_ld_recov_l2);

cmp_ex7_ld_recov_addr <= ex7_ld_recov_l2((54) to (54+real_data_add-6-1));

ex4_ld_recov_extra(0) <= ex4_ld_recov_ld_hit_st  when ex4_ld_m_val='1' else
                         ex4_ld_entry_hit_st_l2;

ex4_ld_recov_extra(1) <= '0';
ex4_ld_recov_extra(2) <= xu_lsu_ex4_dvc1_en;
ex4_ld_recov_extra(3) <= xu_lsu_ex4_dvc2_en;

ex5_ld_recov_extra_d(0) <= ex4_ld_recov_extra(0) and (not store_sent and st_entry0_val_l2)         when pe_recov_stall='0' else
                           (ex5_ld_recov_extra_l2(0) and (not store_sent and st_entry0_val_l2)) or
-- when the 1st pe is detected, ex5 will have the last op that needs to be executed.  By setting this bit, it ensures that
-- any stores are done before it executes so that it will be the last op and remain in order
                           (ex7_ld_par_err and not pe_recov_state_l2);

ex5_ld_recov_extra_d(1 to 3) <= ex4_ld_recov_extra(1 to 3)                 when pe_recov_stall='0' else
                                ex5_ld_recov_extra_l2(1 to 3);

latch_ex5_ld_recov_extra : tri_rlmreg_p
  generic map (width => ex5_ld_recov_extra_l2'length, init => 0, expand_type => expand_type)
  port map (nclk    => nclk,
            act     => ex4_stg_act,
         forcee => func_sl_force,
         d_mode  => d_mode_dc,
         delay_lclkr => delay_lclkr_dc,
         mpw1_b  => mpw1_dc_b,
         mpw2_b  => mpw2_dc_b,
         thold_b => func_sl_thold_0_b,
         sg      => sg_0,
         vd      => vdd,
         gd      => gnd,
         scin    => siv(ex5_ld_recov_extra_offset to ex5_ld_recov_extra_offset + ex5_ld_recov_extra_l2'length-1),
         scout   => sov(ex5_ld_recov_extra_offset to ex5_ld_recov_extra_offset + ex5_ld_recov_extra_l2'length-1),
         din     => ex5_ld_recov_extra_d,
         dout    => ex5_ld_recov_extra_l2);

ex6_ld_recov_extra_d(0) <= ex5_ld_recov_extra_l2(0) and (not store_sent and st_entry0_val_l2)     when pe_recov_stall='0' else
                           ex6_ld_recov_extra_l2(0) and (not store_sent and st_entry0_val_l2);

ex6_ld_recov_extra_d(1 to 3) <= ex5_ld_recov_extra_l2(1 to 3)              when pe_recov_stall='0' else
                                ex6_ld_recov_extra_l2(1 to 3);

latch_ex6_ld_recov_extra : tri_rlmreg_p
  generic map (width => ex6_ld_recov_extra_l2'length, init => 0, expand_type => expand_type)
  port map (nclk    => nclk,
            act     => ex6_ld_recov_act,
         forcee => func_sl_force,
         d_mode  => d_mode_dc,
         delay_lclkr => delay_lclkr_dc,
         mpw1_b  => mpw1_dc_b,
         mpw2_b  => mpw2_dc_b,
         thold_b => func_sl_thold_0_b,
         sg      => sg_0,
         vd      => vdd,
         gd      => gnd,
         scin    => siv(ex6_ld_recov_extra_offset to ex6_ld_recov_extra_offset + ex6_ld_recov_extra_l2'length-1),
         scout   => sov(ex6_ld_recov_extra_offset to ex6_ld_recov_extra_offset + ex6_ld_recov_extra_l2'length-1),
         din     => ex6_ld_recov_extra_d,
         dout    => ex6_ld_recov_extra_l2);

ex7_ld_recov_extra_d(0) <= ex6_ld_recov_extra_l2(0) and (not store_sent and st_entry0_val_l2)     when pe_recov_stall='0' else
                           ex7_ld_recov_extra_l2(0) and (not store_sent and st_entry0_val_l2);

ex7_ld_recov_extra_d(1 to 3) <= ex6_ld_recov_extra_l2(1 to 3)              when pe_recov_stall='0' else
                                ex7_ld_recov_extra_l2(1 to 3);

latch_ex7_ld_recov_extra : tri_rlmreg_p
  generic map (width => ex7_ld_recov_extra_l2'length, init => 0, expand_type => expand_type)
  port map (nclk    => nclk,
            act     => ex7_ld_recov_act,
         forcee => func_sl_force,
         d_mode  => d_mode_dc,
         delay_lclkr => delay_lclkr_dc,
         mpw1_b  => mpw1_dc_b,
         mpw2_b  => mpw2_dc_b,
         thold_b => func_sl_thold_0_b,
         sg      => sg_0,
         vd      => vdd,
         gd      => gnd,
         scin    => siv(ex7_ld_recov_extra_offset to ex7_ld_recov_extra_offset + ex7_ld_recov_extra_l2'length-1),
         scout   => sov(ex7_ld_recov_extra_offset to ex7_ld_recov_extra_offset + ex7_ld_recov_extra_l2'length-1),
         din     => ex7_ld_recov_extra_d,
         dout    => ex7_ld_recov_extra_l2);

ex8_ld_recov_act <= ex7_ld_recov_val_l2 or clkg_ctl_override_q;

latch_ex8_ld_recov_extra : tri_rlmreg_p
  generic map (width => ex8_ld_recov_extra_l2'length, init => 0, expand_type => expand_type)
  port map (nclk    => nclk,
            act     => ex8_ld_recov_act,
         forcee => func_sl_force,
         d_mode  => d_mode_dc,
         delay_lclkr => delay_lclkr_dc,
         mpw1_b  => mpw1_dc_b,
         mpw2_b  => mpw2_dc_b,
         thold_b => func_sl_thold_0_b,
         sg      => sg_0,
         vd      => vdd,
         gd      => gnd,
         scin    => siv(ex8_ld_recov_extra_offset to ex8_ld_recov_extra_offset + ex8_ld_recov_extra_l2'length-1),
         scout   => sov(ex8_ld_recov_extra_offset to ex8_ld_recov_extra_offset + ex8_ld_recov_extra_l2'length-1),
         din     => ex7_ld_recov_extra_l2(1 to 3),
         dout    => ex8_ld_recov_extra_l2);




ex5_ld_recov_val_d <= ((ex4_ld_m_val or ex4_ld_recov_val_l2) and not ex4_flush_load_wo_drop and not pe_recov_stall) or
                    (ex5_ld_recov_val_l2 and pe_recov_stall and pe_recov_state_l2 and not ex6_flush_l2) or 
                    (ex5_ld_recov_val_l2 and pe_recov_stall and ex7_ld_par_err and not pe_recov_state_l2 and not ex5_flush_load_local);

latch_ex5_ld_recov_val : tri_rlmreg_p
  generic map (width => 1, init => 0, expand_type => expand_type)
  port map (nclk    => nclk,
            act     => '1',
         forcee => func_sl_force,
         d_mode  => d_mode_dc,
         delay_lclkr => delay_lclkr_dc,
         mpw1_b  => mpw1_dc_b,
         mpw2_b  => mpw2_dc_b,
         thold_b => func_sl_thold_0_b,
         sg      => sg_0,
         vd      => vdd,
         gd      => gnd,
         scin    => siv(ex5_ld_recov_val_offset to ex5_ld_recov_val_offset),
         scout   => sov(ex5_ld_recov_val_offset to ex5_ld_recov_val_offset),
         din(0)  => ex5_ld_recov_val_d,
         dout(0) => ex5_ld_recov_val_l2);

ex5_ld_recov_val_not_fl <= (ex5_ld_recov_val_l2 and not ex5_flush_load_local and not ex7_ld_par_err and not pe_recov_state_l2) or
                           (ex5_ld_recov_val_l2 and not pe_recov_stall and pe_recov_state_l2) or
                           (ex6_ld_recov_val_l2 and pe_recov_stall and not (ex6_flush_l2 and not pe_recov_state_l2));

latch_ex6_ld_recov_val : tri_rlmreg_p
  generic map (width => 1, init => 0, expand_type => expand_type)
  port map (nclk    => nclk,
            act     => '1',
         forcee => func_sl_force,
         d_mode  => d_mode_dc,
         delay_lclkr => delay_lclkr_dc,
         mpw1_b  => mpw1_dc_b,
         mpw2_b  => mpw2_dc_b,
         thold_b => func_sl_thold_0_b,
         sg      => sg_0,
         vd      => vdd,
         gd      => gnd,
         scin    => siv(ex6_ld_recov_val_offset to ex6_ld_recov_val_offset),
         scout   => sov(ex6_ld_recov_val_offset to ex6_ld_recov_val_offset),
         din(0)  => ex5_ld_recov_val_not_fl,
         dout(0) => ex6_ld_recov_val_l2);

ex6_ld_recov_val_not_fl <= (ex6_ld_recov_val_l2 and not ex6_flush_l2 and not ex7_ld_par_err and not pe_recov_state_l2) or
                           (ex6_ld_recov_val_l2 and not pe_recov_stall and pe_recov_state_l2) or
                           (ex7_ld_recov_val_l2 and pe_recov_stall);


latch_ex7_ld_recov_val : tri_rlmreg_p
  generic map (width => 1, init => 0, expand_type => expand_type)
  port map (nclk    => nclk,
            act     => '1',
         forcee => func_sl_force,
         d_mode  => d_mode_dc,
         delay_lclkr => delay_lclkr_dc,
         mpw1_b  => mpw1_dc_b,
         mpw2_b  => mpw2_dc_b,
         thold_b => func_sl_thold_0_b,
         sg      => sg_0,
         vd      => vdd,
         gd      => gnd,
         scin    => siv(ex7_ld_recov_val_offset to ex7_ld_recov_val_offset),
         scout   => sov(ex7_ld_recov_val_offset to ex7_ld_recov_val_offset),
         din(0)  => ex6_ld_recov_val_not_fl,
         dout(0) => ex7_ld_recov_val_l2);


-- Compare store queue to the ex6 recovery load and if they match and ex6 load has ld_hit_st=0, then
-- the load was 1st and will neeed to set a bit to block the store until the ld queue is empty when
-- in parity error recovery.  If ex6 ld_hit_st=1, then the store was 1st and does not need to be blocked.
-- The load will wait in the load queue because of the ld_hit_st bit.

stq_hit_ex6_recov <= (ex6_ld_recov_l2((54) to (54+real_data_add-7-1)) = s_m_queue0(58 to (58+real_data_add-7-1))) and
                     ((ex6_ld_recov_l2(54+real_data_add-6-1) = s_m_queue0(58+real_data_add-6-1)) or my_xucr0_cls) and 
                      st_entry0_val_l2 and ex6_ld_recov_val_not_fl;

ex4st_hit_ex6_recov <= (ex6_ld_recov_l2((54) to (54+real_data_add-7-1)) = ex4_st_entry_l2(58 to (58+real_data_add-7-1))) and
                       ((ex6_ld_recov_l2(54+real_data_add-6-1) = ex4_st_entry_l2(58+real_data_add-6-1)) or my_xucr0_cls) and 
                        ex4_st_val_l2 and ex6_ld_recov_val_not_fl;

set_st_hit_recov_ld <= stq_hit_ex6_recov or ex4st_hit_ex6_recov;

reset_st_hit_recov_ld <= not (pe_recov_state_l2 or ex7_ld_par_err) or
                           (pe_recov_ld_num_l2(1) and lmq_empty and not ex7_ld_recov_val_l2) or 
                           ((pe_recov_ld_num_l2(1) or pe_recov_ld_num_l2(2)) and lmq_empty and ex7_ld_recov_val_l2 and ex7_ld_recov_extra_l2(0));  -- next load is v and will wait for st

st_hit_recov_ld_d <= (set_st_hit_recov_ld and not ex6_ld_recov_extra_l2(0)) or
                     (st_recycle_v_l2 and st_entry0_val_l2 and store_sent) or 
                       (st_hit_recov_ld_l2 and not reset_st_hit_recov_ld);

blk_st_for_pe_recov <= ex7_ld_par_err or (pe_recov_state_l2 and st_hit_recov_ld_l2);

blk_st_cred_pop <= blk_st_for_pe_recov and not pe_recov_state_d;

latch_st_hit_recov_ld : tri_rlmreg_p
  generic map (width => 1, init => 0, expand_type => expand_type)
  port map (nclk    => nclk,
            act     => '1',
         forcee => func_sl_force,
         d_mode  => d_mode_dc,
         delay_lclkr => delay_lclkr_dc,
         mpw1_b  => mpw1_dc_b,
         mpw2_b  => mpw2_dc_b,
         thold_b => func_sl_thold_0_b,
         sg      => sg_0,
         vd      => vdd,
         gd      => gnd,
         scin    => siv(st_hit_recov_ld_offset to st_hit_recov_ld_offset),
         scout   => sov(st_hit_recov_ld_offset to st_hit_recov_ld_offset),
         din(0)  => st_hit_recov_ld_d,
         dout(0) => st_hit_recov_ld_l2);

--************************************************************************************************************
--************************************************************************************************************
-- END: LOAD QUEUE LOGIC
--************************************************************************************************************
--************************************************************************************************************

--************************************************************************************************************
--************************************************************************************************************
-- INSTRUCTION FETCH QUEUE LOGIC
-- Instruction Fetch Queue Entry - 4 entries, 1 per thread
--************************************************************************************************************
--************************************************************************************************************

ifetch_act <= i_x_request or clkg_ctl_override_q;

latch_ifetch_req : tri_rlmreg_p
  generic map (width => 1, init => 0, expand_type => expand_type)
  port map (nclk    => nclk,
            act     => '1',
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(ifetch_req_offset to ifetch_req_offset),
            scout   => sov(ifetch_req_offset to ifetch_req_offset),
            din(0)  => i_x_request,
            dout(0) => ifetch_req_l2);

latch_ifetch_ra : tri_rlmreg_p
  generic map (width => ifetch_ra_l2'length, init => 0, expand_type => expand_type)
  port map (nclk    => nclk,
            act     => ifetch_act,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(ifetch_ra_offset to ifetch_ra_offset + ifetch_ra_l2'length-1),
            scout   => sov(ifetch_ra_offset to ifetch_ra_offset + ifetch_ra_l2'length-1),
            din     => i_x_ra,
            dout    => ifetch_ra_l2);

latch_ifetch_wimge : tri_rlmreg_p
  generic map (width => ifetch_wimge_l2'length, init => 0, expand_type => expand_type)
  port map (nclk    => nclk,
            act     => ifetch_act,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(ifetch_wimge_offset to ifetch_wimge_offset + ifetch_wimge_l2'length-1),
            scout   => sov(ifetch_wimge_offset to ifetch_wimge_offset + ifetch_wimge_l2'length-1),
            din     => i_x_wimge,
            dout    => ifetch_wimge_l2);

latch_ifetch_thread : tri_rlmreg_p
  generic map (width => ifetch_thread_l2'length, init => 0, expand_type => expand_type)
  port map (nclk    => nclk,
            act     => ifetch_act,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(ifetch_thread_offset to ifetch_thread_offset + ifetch_thread_l2'length-1),
            scout   => sov(ifetch_thread_offset to ifetch_thread_offset + ifetch_thread_l2'length-1),
            din     => i_x_thread,
            dout    => ifetch_thread_l2);

latch_ifetch_userdef : tri_rlmreg_p
  generic map (width => ifetch_userdef_l2'length, init => 0, expand_type => expand_type)
  port map (nclk    => nclk,
            act     => ifetch_act,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(ifetch_userdef_offset to ifetch_userdef_offset + ifetch_userdef_l2'length-1),
            scout   => sov(ifetch_userdef_offset to ifetch_userdef_offset + ifetch_userdef_l2'length-1),
            din     => i_x_userdef,
            dout    => ifetch_userdef_l2);

iu_f_tid0_val <= ifetch_req_l2 and ifetch_thread_l2(0);
iu_f_tid1_val <= ifetch_req_l2 and ifetch_thread_l2(1);
iu_f_tid2_val <= ifetch_req_l2 and ifetch_thread_l2(2);
iu_f_tid3_val <= ifetch_req_l2 and ifetch_thread_l2(3);

--******************************************************
-- Instruction Fetch Sequence Write
--******************************************************
iu_seq_incr <= std_ulogic_vector(unsigned(iu_seq_l2) + 1);

iu_seq_d <= iu_seq_incr   when ifetch_req_l2   = '1'   else 
            iu_seq_l2;

latch_iu_seq : tri_rlmreg_p
  generic map (width => iu_seq_l2'length, init => 0, expand_type => expand_type)
  port map (nclk    => nclk,
            act     => iuq_act,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(iu_seq_offset to iu_seq_offset + iu_seq_l2'length-1),
            scout   => sov(iu_seq_offset to iu_seq_offset + iu_seq_l2'length-1),
            din     => iu_seq_d(0 to 2),
            dout    => iu_seq_l2(0 to 2));

--******************************************************
-- Instruction Fetch Sequence Read
--******************************************************
iu_seq_rd_incr <= std_ulogic_vector(unsigned(iu_seq_rd_l2) + 1);

iu_seq_rd_d <= iu_seq_rd_incr when iu_sent_val = '1'   else 
               iu_seq_rd_l2;

latch_iu_seq_rd : tri_rlmreg_p
  generic map (width => iu_seq_rd_l2'length, init => 0, expand_type => expand_type)
  port map (nclk    => nclk,
            act     => iuq_act,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(iu_seq_rd_offset to iu_seq_rd_offset + iu_seq_rd_l2'length-1),
            scout   => sov(iu_seq_rd_offset to iu_seq_rd_offset + iu_seq_rd_l2'length-1),
            din     => iu_seq_rd_d,
            dout    => iu_seq_rd_l2);

-- Instruction Fetch Queue Entry - 4 Queue Entries
-- bit(0:4)    = wimge
-- bit(5:xx) = real address
-- bit(xx:xx+3) = instruction fetch sequence number

iu_queue_entry <= ifetch_wimge_l2(0 to 4) & ifetch_userdef_l2(0 to 3) & ifetch_ra_l2 & iu_seq_l2;

--******************************************************
-- Instruction Fetch Queue0 -TID0
--******************************************************

iuq_act <= ifetch_req_l2 or iu_val_req or clkg_ctl_override_q;

iu_f_q0_val_upd <= iu_f_tid0_val & i_f_q0_sent;

with iu_f_q0_val_upd select
    i_f_q0_val_d <=               '1' when "10",
                                  '0' when "01",
                        i_f_q0_val_l2 when others;

with iu_f_tid0_val select
    i_f_q0_d <= iu_queue_entry when '1',
                     i_f_q0_l2 when others;

latch_iu_q0_val : tri_rlmreg_p
  generic map (width => 1, init => 0, expand_type => expand_type)
  port map (nclk    => nclk,
            act     => iuq_act,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(i_f_q0_val_offset to i_f_q0_val_offset),
            scout   => sov(i_f_q0_val_offset to i_f_q0_val_offset),
            din(0)  => i_f_q0_val_d,
            dout(0) => i_f_q0_val_l2);

latch_iu_q0 : tri_rlmreg_p
  generic map (width => i_f_q0_l2'length, init => 0, expand_type => expand_type)
  port map (nclk    => nclk,
            act     => iuq_act,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(i_f_q0_offset to i_f_q0_offset + i_f_q0_l2'length-1),
            scout   => sov(i_f_q0_offset to i_f_q0_offset + i_f_q0_l2'length-1),
            din     => i_f_q0_d,
            dout    => i_f_q0_l2);

--******************************************************
-- Instruction Fetch Queue1 -TID1
--******************************************************

iu_f_q1_val_upd <= iu_f_tid1_val & i_f_q1_sent;

with iu_f_q1_val_upd select
    i_f_q1_val_d <=               '1' when "10",
                                  '0' when "01",
                        i_f_q1_val_l2 when others;

with iu_f_tid1_val select
    i_f_q1_d <= iu_queue_entry when '1',
                     i_f_q1_l2 when others;

latch_iu_q1_val : tri_rlmreg_p
  generic map (width => 1, init => 0, expand_type => expand_type)
  port map (nclk    => nclk,
            act     => iuq_act,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(i_f_q1_val_offset to i_f_q1_val_offset),
            scout   => sov(i_f_q1_val_offset to i_f_q1_val_offset),
            din(0)  => i_f_q1_val_d,
            dout(0) => i_f_q1_val_l2);

latch_iu_q1 : tri_rlmreg_p
  generic map (width => i_f_q1_l2'length, init => 0, expand_type => expand_type)
  port map (nclk    => nclk,
            act     => iuq_act,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(i_f_q1_offset to i_f_q1_offset + i_f_q1_l2'length-1),
            scout   => sov(i_f_q1_offset to i_f_q1_offset + i_f_q1_l2'length-1),
            din     => i_f_q1_d,
            dout    => i_f_q1_l2);

--******************************************************
-- Instruction Fetch Queue2 -TID2
--******************************************************

iu_f_q2_val_upd <= iu_f_tid2_val & i_f_q2_sent;

with iu_f_q2_val_upd select
    i_f_q2_val_d <=               '1' when "10",
                                  '0' when "01",
                        i_f_q2_val_l2 when others;

with iu_f_tid2_val select
    i_f_q2_d <= iu_queue_entry when '1',
                     i_f_q2_l2 when others;

latch_iu_q2_val : tri_rlmreg_p
  generic map (width => 1, init => 0, expand_type => expand_type)
  port map (nclk    => nclk,
            act     => iuq_act,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(i_f_q2_val_offset to i_f_q2_val_offset),
            scout   => sov(i_f_q2_val_offset to i_f_q2_val_offset),
            din(0)  => i_f_q2_val_d,
            dout(0) => i_f_q2_val_l2);

latch_iu_q2 : tri_rlmreg_p
  generic map (width => i_f_q2_l2'length, init => 0, expand_type => expand_type)
  port map (nclk    => nclk,
            act     => iuq_act,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(i_f_q2_offset to i_f_q2_offset + i_f_q2_l2'length-1),
            scout   => sov(i_f_q2_offset to i_f_q2_offset + i_f_q2_l2'length-1),
            din     => i_f_q2_d,
            dout    => i_f_q2_l2);

--******************************************************
-- Instruction Fetch Queue3 -TID3
--******************************************************

iu_f_q3_val_upd <= iu_f_tid3_val & i_f_q3_sent;

with iu_f_q3_val_upd select
    i_f_q3_val_d <=               '1' when "10",
                                  '0' when "01",
                        i_f_q3_val_l2 when others;

with iu_f_tid3_val select
    i_f_q3_d <= iu_queue_entry when '1',
                     i_f_q3_l2 when others;

latch_iu_q3_val : tri_rlmreg_p
  generic map (width => 1, init => 0, expand_type => expand_type)
  port map (nclk    => nclk,
            act     => iuq_act,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(i_f_q3_val_offset to i_f_q3_val_offset),
            scout   => sov(i_f_q3_val_offset to i_f_q3_val_offset),
            din(0)  => i_f_q3_val_d,
            dout(0) => i_f_q3_val_l2);

latch_iu_q3 : tri_rlmreg_p
  generic map (width => i_f_q3_l2'length, init => 0, expand_type => expand_type)
  port map (nclk    => nclk,
            act     => iuq_act,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(i_f_q3_offset to i_f_q3_offset + i_f_q3_l2'length-1),
            scout   => sov(i_f_q3_offset to i_f_q3_offset + i_f_q3_l2'length-1),
            din     => i_f_q3_d,
            dout    => i_f_q3_l2);

--************************************************************************************************************
--************************************************************************************************************
-- END: INSTRUCTION FETCH QUEUE LOGIC
--************************************************************************************************************
--************************************************************************************************************

--************************************************************************************************************
-- MMU QUEUE
--************************************************************************************************************

mm_req_val_d <= not (mm_xu_lsu_req(0 to 3) = "0000");

mmq_act <= mm_req_val_d or clkg_ctl_override_q;

mmu_q_val_d <= (not (mm_xu_lsu_req(0 to 3) = "0000")) or
               (not mmu_sent and mmu_q_val_l2);

mmu_command <= mm_xu_lsu_ttype(0 to 1) &                 -- (0:1) command type
               mm_xu_lsu_req(0 to 3) &                   -- (2:5) thread ID
               mm_xu_lsu_wimge(0 to 4) &                 -- (6:10) wimg and endian bits
               mm_xu_lsu_u(0 to 3) &                     -- (11:14) user defined bits
               mm_xu_lsu_lpid(0 to 7) &                  -- (15:22) lpid
               mm_xu_lsu_ind &                           -- (23) ind
               mm_xu_lsu_gs &                            -- (24) gs
               mm_xu_lsu_lbit &                          -- (25) "L" bit, for large vs. small)
               mm_xu_lsu_addr(64-real_data_add to 63);   -- (26:??) address field for command

mmu_q_entry_d <= mmu_command         when mmu_q_val_l2 = '0'  else
                 mmu_q_entry_l2;

latch_mm_req_val : tri_rlmreg_p
  generic map (width => 1, init => 0, expand_type => expand_type)
  port map (nclk    => nclk,
            act     => '1',
            forcee => func_slp_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_slp_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(mm_req_val_offset to mm_req_val_offset),
            scout   => sov(mm_req_val_offset to mm_req_val_offset),
            din(0)  => mm_req_val_d,
            dout(0) => mm_req_val_l2);

latch_mmu_q_val : tri_rlmreg_p
  generic map (width => 1, init => 0, expand_type => expand_type)
  port map (nclk    => nclk,
            act     => '1',
            forcee => func_slp_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_slp_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(mmu_q_val_offset to mmu_q_val_offset),
            scout   => sov(mmu_q_val_offset to mmu_q_val_offset),
            din(0)  => mmu_q_val_d,
            dout(0) => mmu_q_val_l2);

latch_mmu_q_entry : tri_rlmreg_p
  generic map (width => mmu_q_entry_l2'length, init => 0, expand_type => expand_type)
  port map (nclk    => nclk,
            act     => mmq_act,
            forcee => func_slp_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_slp_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(mmu_q_entry_offset to mmu_q_entry_offset + mmu_q_entry_l2'length-1),
            scout   => sov(mmu_q_entry_offset to mmu_q_entry_offset + mmu_q_entry_l2'length-1),
            din     => mmu_q_entry_d,
            dout    => mmu_q_entry_l2);





--************************************************************************************************************
--************************************************************************************************************
-- LOAD QUEUE COMMAND COUNT (used to determine credits)
--************************************************************************************************************
--************************************************************************************************************
load_cmd_count_incr(0 to 3) <= std_ulogic_vector(unsigned(load_cmd_count_l2) + 1);
load_cmd_count_decr(0 to 3) <= std_ulogic_vector(unsigned(load_cmd_count_l2) - 1);
load_cmd_count_decrby2(0 to 3) <= std_ulogic_vector(unsigned(load_cmd_count_l2) - 2);

load_credit_used <= load_sent or iu_sent_val or mmu_ld_sent;


-- break apart mux control to fix timing
decr_load_cnt_lcu0  <= (    anaclat_ld_pop and not (ex6_load_sent_l2 and (ex6_flush_l2 or ex7_ld_par_err))) or  -- when load_credit_used=0
                       (not anaclat_ld_pop and     (ex6_load_sent_l2 and (ex6_flush_l2 or ex7_ld_par_err)));
dec_by2_ld_cnt_lcu0 <=      anaclat_ld_pop and     (ex6_load_sent_l2 and (ex6_flush_l2 or ex7_ld_par_err));
hold_load_cnt_lcu0  <= (not anaclat_ld_pop and not (ex6_load_sent_l2 and (ex6_flush_l2 or ex7_ld_par_err)));

incr_load_cnt_lcu1 <=   not anaclat_ld_pop and not (ex6_load_sent_l2 and (ex6_flush_l2 or ex7_ld_par_err));     -- when load_credit_used=1
decr_load_cnt_lcu1 <=  (    anaclat_ld_pop and     (ex6_load_sent_l2 and (ex6_flush_l2 or ex7_ld_par_err)));
hold_load_cnt_lcu1 <=  (not anaclat_ld_pop and     (ex6_load_sent_l2 and (ex6_flush_l2 or ex7_ld_par_err))) or
                       (    anaclat_ld_pop and not (ex6_load_sent_l2 and (ex6_flush_l2 or ex7_ld_par_err)));


load_cmd_count_lcu0(0 to 3) <= gate_and(decr_load_cnt_lcu0,  load_cmd_count_decr(0 to 3)) or      -- when load_credit_used=0
                               gate_and(dec_by2_ld_cnt_lcu0, load_cmd_count_decrby2(0 to 3)) or 
                               gate_and(hold_load_cnt_lcu0,  load_cmd_count_l2);
load_cmd_count_lcu1(0 to 3) <= gate_and(incr_load_cnt_lcu1,  load_cmd_count_incr(0 to 3)) or      -- when load_credit_used=1
                               gate_and(decr_load_cnt_lcu1,  load_cmd_count_decr(0 to 3)) or 
                               gate_and(hold_load_cnt_lcu1,  load_cmd_count_l2);

load_cmd_count_d(0 to 3) <= gate_and(not load_credit_used,  load_cmd_count_lcu0) or
                            gate_and(    load_credit_used,  load_cmd_count_lcu1);

latch_load_cmd_count : tri_rlmreg_p
  generic map (width => load_cmd_count_l2'length, init => 6, expand_type => expand_type)  -- init to 4 to leave 4 credits left
  port map (nclk    => nclk,
            act     => '1',
            forcee => cfg_slp_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => cfg_slp_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => bcfg_siv(load_cmd_count_offset to load_cmd_count_offset + load_cmd_count_l2'length-1),
            scout   => bcfg_sov(load_cmd_count_offset to load_cmd_count_offset + load_cmd_count_l2'length-1),
            din     => load_cmd_count_d(0 to 3),
            dout    => load_cmd_count_l2(0 to 3) );

ld_credit_pre <= not load_cmd_count_l2(0);   -- when cmd count gets to 8, there are no load credits left

load_credit <= ld_credit_pre and not (my_xucr0_cred and not st_credit_pre);


--************************************************************************************************************
--************************************************************************************************************
-- STORE QUEUE COMMAND COUNT (used to determine credits)
--************************************************************************************************************
--************************************************************************************************************
store_cmd_count_incr(0 to 5) <= std_ulogic_vector(unsigned(store_cmd_count_l2) + 1);
store_cmd_count_decr(0 to 5) <= std_ulogic_vector(unsigned(store_cmd_count_l2) - 1);
store_cmd_count_decby2(0 to 5) <= std_ulogic_vector(unsigned(store_cmd_count_l2) - 2);
store_cmd_count_decby3(0 to 5) <= std_ulogic_vector(unsigned(store_cmd_count_l2) - 3);


st_count_ctrl(0) <= store_sent or mmu_st_sent;              -- +1
st_count_ctrl(1) <= anaclat_st_pop;                         -- -1
st_count_ctrl(2) <= anaclat_st_gather;                      -- -1
st_count_ctrl(3) <= (ex6_store_sent_l2 and ex6_flush_l2) or 
                    (l2req_recycle_l2 and ex7_ld_par_err);  -- -1

incr_store_cmd <=  st_count_ctrl="1000";

decr_store_cmd <= (st_count_ctrl="0001") or
                  (st_count_ctrl="0010") or
                  (st_count_ctrl="0100") or
                  (st_count_ctrl="1011") or
                  (st_count_ctrl="1101") or
                  (st_count_ctrl="1110");

dec_by2_st_cmd <= (st_count_ctrl="0011") or
                  (st_count_ctrl="0101") or
                  (st_count_ctrl="0110") or
                  (st_count_ctrl="1111");

dec_by3_st_cmd <= (st_count_ctrl="0111");

hold_store_cmd <= (st_count_ctrl="0000") or
                  (st_count_ctrl="1001") or
                  (st_count_ctrl="1100") or
                  (st_count_ctrl="1010");


store_cmd_count_d(0 to 5) <= gate_and(incr_store_cmd,  store_cmd_count_incr(0 to 5)) or
                             gate_and(decr_store_cmd,  store_cmd_count_decr(0 to 5)) or
                             gate_and(dec_by2_st_cmd,  store_cmd_count_decby2(0 to 5)) or
                             gate_and(dec_by3_st_cmd,  store_cmd_count_decby3(0 to 5)) or
                             gate_and(hold_store_cmd,  store_cmd_count_l2(0 to 5));

latch_store_cmd_count : tri_rlmreg_p
  generic map (width => store_cmd_count_l2'length, init => 28, expand_type => expand_type)
  port map (nclk    => nclk,
            act     => '1',
            forcee => cfg_slp_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => cfg_slp_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => bcfg_siv(store_cmd_count_offset to store_cmd_count_offset + store_cmd_count_l2'length-1),
            scout   => bcfg_sov(store_cmd_count_offset to store_cmd_count_offset + store_cmd_count_l2'length-1),
            din     => store_cmd_count_d(0 to 5),
            dout    => store_cmd_count_l2(0 to 5) );


st_credit_pre <= not store_cmd_count_l2(0);   -- When cmd count gets to 32, there are no store credits left.

store_credit <= st_credit_pre and not (my_xucr0_cred and not ld_credit_pre ) and not blk_st_for_pe_recov;
one_st_cred <= store_cmd_count_l2="011111";

--************************************************************************************************************
--************************************************************************************************************
-- INSTRUCTION FETCH QUEUE SELECT LOGIC
--************************************************************************************************************
--************************************************************************************************************
iu_f_q0_sel <= (iu_seq_rd_l2 = i_f_q0_l2((REAL_IFAR_length+9) to (REAL_IFAR_length+11))) and i_f_q0_val_l2;
iu_f_q1_sel <= (iu_seq_rd_l2 = i_f_q1_l2((REAL_IFAR_length+9) to (REAL_IFAR_length+11))) and i_f_q1_val_l2;
iu_f_q2_sel <= (iu_seq_rd_l2 = i_f_q2_l2((REAL_IFAR_length+9) to (REAL_IFAR_length+11))) and i_f_q2_val_l2;
iu_f_q3_sel <= (iu_seq_rd_l2 = i_f_q3_l2((REAL_IFAR_length+9) to (REAL_IFAR_length+11))) and i_f_q3_val_l2;

iu_f_q_sel(0) <= (not iu_f_q0_sel and not iu_f_q1_sel and not iu_f_q2_sel and iu_f_q3_sel) or
                 (not iu_f_q0_sel and not iu_f_q1_sel and iu_f_q2_sel and not iu_f_q3_sel);

iu_f_q_sel(1) <= (not iu_f_q0_sel and not iu_f_q1_sel and not iu_f_q2_sel and iu_f_q3_sel) or
                 (not iu_f_q0_sel and iu_f_q1_sel and not iu_f_q2_sel and not iu_f_q3_sel);

with iu_f_q_sel select
    iu_f_sel_entry <= i_f_q3_l2(0 to (9+REAL_IFAR_length-1)) when "11",
                      i_f_q2_l2(0 to (9+REAL_IFAR_length-1)) when "10",
                      i_f_q1_l2(0 to (9+REAL_IFAR_length-1)) when "01",
                      i_f_q0_l2(0 to (9+REAL_IFAR_length-1)) when others;

i_f_q0_sent <= iu_f_q0_sel and load_credit and send_if_req_l2 and not (ex5_sel_st_req or ((ob_req_val_l2 or ob_ditc_val_l2 or st_recycle_v_l2) and store_credit)) and
               not (l2req_resend_l2 and ex7_ld_par_err); 
i_f_q1_sent <= iu_f_q1_sel and load_credit and send_if_req_l2 and not (ex5_sel_st_req or ((ob_req_val_l2 or ob_ditc_val_l2 or st_recycle_v_l2) and store_credit)) and
               not (l2req_resend_l2 and ex7_ld_par_err); 
i_f_q2_sent <= iu_f_q2_sel and load_credit and send_if_req_l2 and not (ex5_sel_st_req or ((ob_req_val_l2 or ob_ditc_val_l2 or st_recycle_v_l2) and store_credit)) and
               not (l2req_resend_l2 and ex7_ld_par_err); 
i_f_q3_sent <= iu_f_q3_sel and load_credit and send_if_req_l2 and not (ex5_sel_st_req or ((ob_req_val_l2 or ob_ditc_val_l2 or st_recycle_v_l2) and store_credit)) and
               not (l2req_resend_l2 and ex7_ld_par_err); 

-- valid IU request is in the Instruction Fetch Queue
iu_val_req <= i_f_q0_val_l2 or i_f_q1_val_l2 or i_f_q2_val_l2 or i_f_q3_val_l2;

iu_sent_val <= iu_val_req and load_credit and send_if_req_l2 and
               not (ex5_sel_st_req or ((ob_req_val_l2 or ob_ditc_val_l2 or st_recycle_v_l2) and store_credit)) and
               not (l2req_resend_l2 and ex7_ld_par_err); 

iu_val <= iu_val_req or ifetch_req_l2;
ld_q_val <= ex4_ld_m_val_not_fl or 
            (selected_ld_entry_val and not (lq_rd_en_is_ex5 and ex5_flush_load_local) and not (lq_rd_en_is_ex6 and ex6_flush_l2) );

ld_q_req <= ex4_ld_m_val_not_fl;

mmu_q_val <= mmu_q_val_l2 and not mm_req_val_l2;

-- Round Robin State Machine
-- Want to update Request Selection when
-- 1) there are no requests in LDQ, MMUQ or IUQ and received a IU/LD/MMU request
-- 2) when a Request is sent
state_trans <= ((ifetch_req_l2 or ld_q_req or mm_req_val_l2) and not (iu_val_req or selected_ld_entry_val or mmu_q_val_l2)) or
               (load_sent or load_flushed or iu_sent_val or mmu_sent) or
               (send_if_req_l2 and not iu_val) or (send_ld_req_l2 and not ld_q_val) or (send_mm_req_l2 and not mmu_q_val_l2);


-- select the next state based on this table:
--
-- request val  | prev state:   | prev state:  | prev state:   |
--   I  L  M    |   sel I       |   sel L      |   sel M       |
-- =============|===============|==============|===============|
--   0  0  0    |      I        |      L       |       M       |
--   0  0  1    |      M        |      M       |       M       |
--   0  1  0    |      L        |      L       |       L       |
--   0  1  1    |      L        |      M       |       L       |
--   1  0  0    |      I        |      I       |       I       |
--   1  0  1    |      M        |      M       |       I       |
--   1  1  0    |      L        |      I       |       I       |
--   1  1  1    |      L        |      M       |       I       |
--
-- these next state bits should always be 1-hot (init to I=1, L=0, M=0)

sel_if_req <= (    iu_val and not ld_q_val and not mmu_q_val_l2                   ) or
              (    iu_val and not ld_q_val and     mmu_q_val_l2 and send_mm_req_l2) or
              (    iu_val and     ld_q_val and not mmu_q_val_l2 and send_ld_req_l2) or
              (    iu_val and     ld_q_val and not mmu_q_val_l2 and send_mm_req_l2) or
              (    iu_val and     ld_q_val and     mmu_q_val_l2 and send_mm_req_l2) or 
              (not iu_val and not ld_q_val and not mmu_q_val_l2 and send_if_req_l2);

sel_ld_req <= (not iu_val and     ld_q_val and not mmu_q_val_l2                   ) or
              (not iu_val and     ld_q_val and     mmu_q_val_l2 and send_if_req_l2) or
              (not iu_val and     ld_q_val and     mmu_q_val_l2 and send_mm_req_l2) or
              (    iu_val and     ld_q_val and not mmu_q_val_l2 and send_if_req_l2) or
              (    iu_val and     ld_q_val and     mmu_q_val_l2 and send_if_req_l2) or 
              (not iu_val and not ld_q_val and not mmu_q_val_l2 and send_ld_req_l2);

sel_mm_req <= (not iu_val and not ld_q_val and     mmu_q_val_l2                   ) or
              (not iu_val and     ld_q_val and     mmu_q_val_l2 and send_ld_req_l2) or
              (    iu_val and not ld_q_val and     mmu_q_val_l2 and send_if_req_l2) or
              (    iu_val and not ld_q_val and     mmu_q_val_l2 and send_ld_req_l2) or
              (    iu_val and     ld_q_val and     mmu_q_val_l2 and send_ld_req_l2) or 
              (not iu_val and not ld_q_val and not mmu_q_val_l2 and send_mm_req_l2);


with state_trans select
    send_if_req_d <=     sel_if_req when '1',
                     send_if_req_l2 when others;

with state_trans select
    send_ld_req_d <=     sel_ld_req when '1',
                     send_ld_req_l2 when others;

with state_trans select
    send_mm_req_d <=     sel_mm_req when '1',
                     send_mm_req_l2 when others;

latch_send_if_req : tri_rlmreg_p
  generic map (width => 1, init => 1, expand_type => expand_type)
  port map (nclk    => nclk,
            act     => '1',
            forcee => func_slp_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_slp_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(send_if_req_offset to send_if_req_offset),
            scout   => sov(send_if_req_offset to send_if_req_offset),
            din(0)  => send_if_req_d,
            dout(0) => send_if_req_l2);

latch_send_ld_req : tri_rlmreg_p
  generic map (width => 1, init => 0, expand_type => expand_type)
  port map (nclk    => nclk,
            act     => '1',
            forcee => func_slp_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_slp_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(send_ld_req_offset to send_ld_req_offset),
            scout   => sov(send_ld_req_offset to send_ld_req_offset),
            din(0)  => send_ld_req_d,
            dout(0) => send_ld_req_l2);

latch_send_mm_req : tri_rlmreg_p
  generic map (width => 1, init => 0, expand_type => expand_type)
  port map (nclk    => nclk,
            act     => '1',
            forcee => func_slp_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_slp_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(send_mm_req_offset to send_mm_req_offset),
            scout   => sov(send_mm_req_offset to send_mm_req_offset),
            din(0)  => send_mm_req_d,
            dout(0) => send_mm_req_l2);

--************************************************************************************************************
--************************************************************************************************************
-- END: INSTRUCTION FETCH QUEUE SELECT LOGIC
--************************************************************************************************************
--************************************************************************************************************

--************************************************************************************************************
--************************************************************************************************************
-- Reload Operation
--************************************************************************************************************
--************************************************************************************************************
-- reload is complete when all the data has been stored into the cache array
-- different number of beats of data are given depending if cache inhibit or
-- cache enabled
--
-- ex. cache inhibit load
--                __    __    __    __    __    __    __    __    __    __    __    __    __
-- clk           |  |__|  |__|  |__|  |__|  |__|  |__|  |__|  |__|  |__|  |__|  |__|  |__|  |
--
-- rel_val        ____________________________________________________________________________
--
-- rel_data_val   ____________________________________________________________________________
--                             _____
-- rel_upd_gpr    ____________|     |_________________________________________________________
--
-- rel_data       XXXXXXXXXXXX|Beat0|XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
--
-- ex. cache enabled load
--                __    __    __    __    __    __    __    __    __    __    __    __    __
-- clk           |  |__|  |__|  |__|  |__|  |__|  |__|  |__|  |__|  |__|  |__|  |__|  |__|  |
--                       _____
-- rel_val        ______|     |_______________________________________________________________
--                             _______________________
-- rel_data_val   ____________|                       |_______________________________________
--                             _____
-- rel_upd_gpr    ____________|     |_________________________________________________________
--
-- rel_data       XXXXXXXXXXXX|Beat0|Beat1|Beat2|Beat3|XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
--
-- ex. cache enabled DCBT/DCBTST
--                __    __    __    __    __    __    __    __    __    __    __    __    __
-- clk           |  |__|  |__|  |__|  |__|  |__|  |__|  |__|  |__|  |__|  |__|  |__|  |__|  |
--                       _____
-- rel_val        ______|     |_______________________________________________________________
--                             _______________________
-- rel_data_val   ____________|                       |_______________________________________
--
-- rel_upd_gpr    ____________________________________________________________________________
--
-- rel_data       XXXXXXXXXXXX|Beat0|Beat1|Beat2|Beat3|XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

--******************************************************
-- Reload Operation
--******************************************************

-- latch reload valid and tag to be active the cycle of the data

latch_reld_data_vld : tri_rlmreg_p
  generic map (width => 1, init => 0, expand_type => expand_type)
  port map (nclk    => nclk,
            act     => '1',
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(reld_data_vld_offset to reld_data_vld_offset),
            scout   => sov(reld_data_vld_offset to reld_data_vld_offset),
            din(0)  => data_val_dminus1_l2,
            dout(0) => reld_data_vld_l2);

latch_rel_tag : tri_rlmreg_p
  generic map (width => rel_tag_l2'length, init => 0, expand_type => expand_type)
  port map (nclk    => nclk,
            act     => dminus1_act,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(rel_tag_offset to rel_tag_offset + rel_tag_l2'length-1),
            scout   => sov(rel_tag_offset to rel_tag_offset + rel_tag_l2'length-1),
            din     => tag_dminus1_l2,
            dout    => rel_tag_l2 );


-- latch reload valid and tag to be active the cycle after the data (when ecc errors are signaled)

latch_reld_data_vld_dplus1 : tri_rlmreg_p
  generic map (width => 1, init => 0, expand_type => expand_type)
  port map (nclk    => nclk,
            act     => '1',
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(reld_data_vld_dplus1_offset to reld_data_vld_dplus1_offset),
            scout   => sov(reld_data_vld_dplus1_offset to reld_data_vld_dplus1_offset),
            din(0)  => reld_data_vld_l2,
            dout(0) => reld_data_vld_dplus1_l2);

dplus1_act <= reld_data_vld_l2 or clkg_ctl_override_q;

latch_rel_tag_dplus1 : tri_rlmreg_p
  generic map (width => rel_tag_dplus1_l2'length, init => 0, expand_type => expand_type)
  port map (nclk    => nclk,
            act     => dplus1_act,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(rel_tag_dplus1_offset to rel_tag_dplus1_offset + rel_tag_dplus1_l2'length-1),
            scout   => sov(rel_tag_dplus1_offset to rel_tag_dplus1_offset + rel_tag_dplus1_l2'length-1),
            din     => rel_tag_l2,
            dout    => rel_tag_dplus1_l2);



rel_entry_gen: for i in 0 to lmq_entries-1 generate begin
   rel_entry(i) <= l_m_queue(i)(0) &                                                      -- (0) cache inhibit
                   l_m_queue(i)(7 to 12) &                                                -- (1:6) op_size
                   l_m_queue(i)(13 to 17) &                                               -- (7:11) rot_sel
                   l_m_queue(i)(18 to 21) &                                               -- (12:15) thread id
                   l_m_queue(i)(27 to 35) &                                               -- (16:24) target_gpr
                   l_m_queue(i)(36) &                                                     -- (25) ex3_axu_op_val
                   l_m_queue(i)(37) &                                                     -- (26) le_mode
                   l_m_queue(i)(38) &                                                     -- (27) upd_gpr(dcbt)
                   l_m_queue(i)(47) &                                                     -- (28) algebraic op
                  (l_m_queue(i)(48) or lmq_drop_rel_l2(i)) &                              -- (29) L2 only mode
                   l_m_queue(i)(49) &                                                     -- (30) way lock enable
                   l_m_queue(i)(50 to 51) &                                               -- (31) way lock table select bit
--                   l_m_queue(i)(52) &                                                     -- (33) dvc1
--                   l_m_queue(i)(53) &                                                     -- (34) dvc2
                   l_m_queue(i)(52);                                                      -- (33) watch enable
--                   l_m_queue(i)((54) to (54+real_data_add-4-1));                          -- (34:xx) real address

   rel_tag_1hot(i) <= tag_dminus1_1hot_l2(i);

   cmp_rel_tag_1hot(i) <= rel_tag_1hot(i);

   rel_data_val(i) <= data_val_dminus1_l2 and rel_tag_1hot(i);

   start_rel(i) <= rel_data_val(i) and not l_m_rel_inprog_l2(i);




 


   rel_data_val_dplus1(i) <= reld_data_vld_dplus1_l2 and (rel_tag_dplus1_l2(1 to 4) = tconv(i, 4)) and rel_intf_v_dplus1_l2;

   set_data_ecc_err(i)  <= beat_ecc_err and rel_data_val_dplus1(i); 

   data_ecc_err_d(i) <= set_data_ecc_err(i) or
                        (not ld_m_rel_done_dly2_l2(i) and data_ecc_err_l2(i) );

   set_data_ecc_ue(i)  <= anaclat_ecc_err_ue and rel_data_val_dplus1(i); 

   data_ecc_ue_d(i) <= set_data_ecc_ue(i) or
                       (not ld_m_rel_done_dly2_l2(i) and data_ecc_ue_l2(i) );

end generate;


latch_data_ecc_err : tri_rlmreg_p
  generic map (width => data_ecc_err_l2'length, init => 0, expand_type => expand_type)
  port map (nclk    => nclk,
            act     => ldq_act,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(data_ecc_err_offset to data_ecc_err_offset + data_ecc_err_l2'length-1),
            scout   => sov(data_ecc_err_offset to data_ecc_err_offset + data_ecc_err_l2'length-1),
            din     => data_ecc_err_d,
            dout    => data_ecc_err_l2 );

latch_data_ecc_ue : tri_rlmreg_p
  generic map (width => data_ecc_ue_l2'length, init => 0, expand_type => expand_type)
  port map (nclk    => nclk,
            act     => ldq_act,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(data_ecc_ue_offset to data_ecc_ue_offset + data_ecc_ue_l2'length-1),
            scout   => sov(data_ecc_ue_offset to data_ecc_ue_offset + data_ecc_ue_l2'length-1),
            din     => data_ecc_ue_d,
            dout    => data_ecc_ue_l2 );





q4: if lmq_entries=4 generate begin 
   with tag_dminus1_l2(1 to 4) select
       rel_q_entry <= rel_entry(0)     when "0000",
                      rel_entry(1)     when "0001",
                      rel_entry(2)     when "0010",
                      rel_entry(3)     when "0011",
                      (others => '0')  when others;
   with tag_dminus1_l2(1 to 4) select
       rel_q_addrlo_58 <= l_m_queue_addrlo(0)(58)     when "0000",
                          l_m_queue_addrlo(1)(58)     when "0001",
                          l_m_queue_addrlo(2)(58)     when "0010",
                          l_m_queue_addrlo(3)(58)     when "0011",
                          '0'                         when others;

   with tag_dminus1_l2(1 to 4) select
       rel_dvc1_d <= lmq_dvc1_en_l2(0)     when "0000",
                     lmq_dvc1_en_l2(1)     when "0001",
                     lmq_dvc1_en_l2(2)     when "0010",
                     lmq_dvc1_en_l2(3)     when "0011",
                     '0'                   when others;

   with tag_dminus1_l2(1 to 4) select
       rel_dvc2_d <= lmq_dvc2_en_l2(0)     when "0000",
                     lmq_dvc2_en_l2(1)     when "0001",
                     lmq_dvc2_en_l2(2)     when "0010",
                     lmq_dvc2_en_l2(3)     when "0011",
                     '0'                   when others;

end generate;

q8: if lmq_entries=8 generate begin 
   with tag_dminus1_l2(1 to 4) select
       rel_q_entry <= rel_entry(0)     when "0000",
                      rel_entry(1)     when "0001",
                      rel_entry(2)     when "0010",
                      rel_entry(3)     when "0011",
                      rel_entry(4)     when "0100",
                      rel_entry(5)     when "0101",
                      rel_entry(6)     when "0110",
                      rel_entry(7)     when "0111",
                      (others => '0')  when others;
   with tag_dminus1_l2(1 to 4) select
       rel_q_addrlo_58 <= l_m_queue_addrlo(0)(58)     when "0000",
                          l_m_queue_addrlo(1)(58)     when "0001",
                          l_m_queue_addrlo(2)(58)     when "0010",
                          l_m_queue_addrlo(3)(58)     when "0011",
                          l_m_queue_addrlo(4)(58)     when "0100",
                          l_m_queue_addrlo(5)(58)     when "0101",
                          l_m_queue_addrlo(6)(58)     when "0110",
                          l_m_queue_addrlo(7)(58)     when "0111",
                          '0'                         when others;

   with tag_dminus1_l2(1 to 4) select
       rel_dvc1_d <= lmq_dvc1_en_l2(0)     when "0000",
                     lmq_dvc1_en_l2(1)     when "0001",
                     lmq_dvc1_en_l2(2)     when "0010",
                     lmq_dvc1_en_l2(3)     when "0011",
                     lmq_dvc1_en_l2(4)     when "0100",
                     lmq_dvc1_en_l2(5)     when "0101",
                     lmq_dvc1_en_l2(6)     when "0110",
                     lmq_dvc1_en_l2(7)     when "0111",
                     '0'                   when others;

   with tag_dminus1_l2(1 to 4) select
       rel_dvc2_d <= lmq_dvc2_en_l2(0)     when "0000",
                     lmq_dvc2_en_l2(1)     when "0001",
                     lmq_dvc2_en_l2(2)     when "0010",
                     lmq_dvc2_en_l2(3)     when "0011",
                     lmq_dvc2_en_l2(4)     when "0100",
                     lmq_dvc2_en_l2(5)     when "0101",
                     lmq_dvc2_en_l2(6)     when "0110",
                     lmq_dvc2_en_l2(7)     when "0111",
                     '0'                   when others;

end generate;

rel_cache_inh_d <= rel_q_entry(0) and data_val_dminus1_l2 and not tag_dminus1_l2(1);
rel_size_d(0 to 5) <= rel_q_entry(1 to 6);
rel_rot_sel_d(0 to 4) <= rel_q_entry(7 to 11);
rel_th_id_d(0 to 3) <= rel_q_entry(12 to 15);
rel_tar_gpr_d(0 to 8) <= rel_q_entry(16 to 24);
rel_vpr_val_d <= rel_q_entry(25);
rel_le_mode_d <= rel_q_entry(26);
rel_dcbt_d <= rel_q_entry(27);
rel_algebraic_d <= rel_q_entry(28);
rel_l2only_d <= rel_q_entry(29) or (dminus1_l1_dump and rel_intf_v_dminus1_l2);
rel_lock_en_d <= rel_q_entry(30);
rel_classid_d <= rel_q_entry(31 to 32);
rel_watch_en_d <= rel_q_entry(33);
rel_addr_d <= cmp_rel_addr & rel_q_addrlo_58;




rel_beats_gen: for i in 0 to lmq_entries-1 generate begin

   l_m_rel_c_i_beat0_d(i) <= (start_rel(i) and rel_cache_inh_d and rel_size_d(0))  or    -- start cache inh 32B reload
                             (l_m_rel_c_i_beat0_l2(i) and not rel_data_val(i));          -- reset on next data valid

   l_m_rel_c_i_val(i) <= (start_rel(i) and rel_cache_inh_d and not rel_size_d(0))  or    -- start cache inh non 32B reload
                         (l_m_rel_c_i_beat0_l2(i) and rel_data_val(i) );                 -- 2nd beat for 32B reloads




   l_m_rel_hit_beat0_d(i) <= (start_rel(i) and not rel_cache_inh_d )  or (l_m_rel_hit_beat0_l2(i) and not rel_data_val(i));
   l_m_rel_hit_beat1_d(i) <= (l_m_rel_hit_beat0_l2(i) and rel_data_val(i) ) or (l_m_rel_hit_beat1_l2(i) and not rel_data_val(i) );
   l_m_rel_hit_beat2_d(i) <= (l_m_rel_hit_beat1_l2(i) and rel_data_val(i) ) or (l_m_rel_hit_beat2_l2(i) and not rel_data_val(i) ) or
                             (ld_m_rel_done_l2(i) and ldq_recirc_rel_val and not ecc_err(i) and not my_xucr0_cls);
   l_m_rel_hit_beat3_d(i) <= (l_m_rel_hit_beat2_l2(i) and rel_data_val(i) ) or (l_m_rel_hit_beat3_l2(i) and not rel_data_val(i) and my_xucr0_cls);
   l_m_rel_hit_beat4_d(i) <= (l_m_rel_hit_beat3_l2(i) and rel_data_val(i) and my_xucr0_cls) or (l_m_rel_hit_beat4_l2(i) and not rel_data_val(i) );
   l_m_rel_hit_beat5_d(i) <= (l_m_rel_hit_beat4_l2(i) and rel_data_val(i) ) or (l_m_rel_hit_beat5_l2(i) and not rel_data_val(i) );
   l_m_rel_hit_beat6_d(i) <= (l_m_rel_hit_beat5_l2(i) and rel_data_val(i) ) or (l_m_rel_hit_beat6_l2(i) and not rel_data_val(i) ) or 
                             (ld_m_rel_done_l2(i) and ldq_recirc_rel_val and not ecc_err(i) and my_xucr0_cls);
   l_m_rel_hit_beat7_d(i) <= (l_m_rel_hit_beat6_l2(i) and rel_data_val(i) );
   l_m_rel_inprog_d(i) <= l_m_rel_hit_beat0_d(i) or l_m_rel_c_i_beat0_d(i) or 
                          (ld_m_rel_done_l2(i) and ldq_recirc_rel_val and not ecc_err(i)) or 
                          (l_m_rel_inprog_l2(i) and not (l_m_rel_hit_beat3_l2(i) and not my_xucr0_cls) and 
                                                    not (l_m_rel_hit_beat7_l2(i) and     my_xucr0_cls) and
                                                    not l_m_rel_val_c_i_dly(i)); -- active through beats 0, 1, 2, and 3

end generate;

latch_rel_hit_beat0 : tri_rlmreg_p
  generic map (width => l_m_rel_hit_beat0_l2'length, init => 0, expand_type => expand_type)
  port map (nclk    => nclk,
            act     => ldq_act,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(l_m_rel_hit_beat0_offset to l_m_rel_hit_beat0_offset + l_m_rel_hit_beat0_l2'length-1),
            scout   => sov(l_m_rel_hit_beat0_offset to l_m_rel_hit_beat0_offset + l_m_rel_hit_beat0_l2'length-1),
            din     => l_m_rel_hit_beat0_d,
            dout    => l_m_rel_hit_beat0_l2);
latch_rel_hit_beat1 : tri_rlmreg_p
  generic map (width => l_m_rel_hit_beat1_l2'length, init => 0, expand_type => expand_type)
  port map (nclk    => nclk,
            act     => ldq_act,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(l_m_rel_hit_beat1_offset to l_m_rel_hit_beat1_offset + l_m_rel_hit_beat1_l2'length-1),
            scout   => sov(l_m_rel_hit_beat1_offset to l_m_rel_hit_beat1_offset + l_m_rel_hit_beat1_l2'length-1),
            din     => l_m_rel_hit_beat1_d,
            dout    => l_m_rel_hit_beat1_l2);
latch_rel_hit_beat2 : tri_rlmreg_p
  generic map (width => l_m_rel_hit_beat2_l2'length, init => 0, expand_type => expand_type)
  port map (nclk    => nclk,
            act     => ldq_act,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(l_m_rel_hit_beat2_offset to l_m_rel_hit_beat2_offset + l_m_rel_hit_beat2_l2'length-1),
            scout   => sov(l_m_rel_hit_beat2_offset to l_m_rel_hit_beat2_offset + l_m_rel_hit_beat2_l2'length-1),
            din     => l_m_rel_hit_beat2_d,
            dout    => l_m_rel_hit_beat2_l2);
latch_rel_hit_beat3 : tri_rlmreg_p
  generic map (width => l_m_rel_hit_beat3_l2'length, init => 0, expand_type => expand_type)
  port map (nclk    => nclk,
            act     => ldq_act,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(l_m_rel_hit_beat3_offset to l_m_rel_hit_beat3_offset + l_m_rel_hit_beat3_l2'length-1),
            scout   => sov(l_m_rel_hit_beat3_offset to l_m_rel_hit_beat3_offset + l_m_rel_hit_beat3_l2'length-1),
            din     => l_m_rel_hit_beat3_d,
            dout    => l_m_rel_hit_beat3_l2);

   latch_rel_hit_beat4 : tri_rlmreg_p
     generic map (width => l_m_rel_hit_beat4_l2'length, init => 0, expand_type => expand_type)
     port map (nclk    => nclk,
               act     => ldq_act,
               forcee => func_sl_force,
               d_mode  => d_mode_dc,
               delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b,
               mpw2_b  => mpw2_dc_b,
               thold_b => func_sl_thold_0_b,
               sg      => sg_0,
               vd      => vdd,
               gd      => gnd,
               scin    => siv(l_m_rel_hit_beat4_offset to l_m_rel_hit_beat4_offset + l_m_rel_hit_beat4_l2'length-1),
               scout   => sov(l_m_rel_hit_beat4_offset to l_m_rel_hit_beat4_offset + l_m_rel_hit_beat4_l2'length-1),
               din     => l_m_rel_hit_beat4_d,
               dout    => l_m_rel_hit_beat4_l2);
   latch_rel_hit_beat5 : tri_rlmreg_p
     generic map (width => l_m_rel_hit_beat5_l2'length, init => 0, expand_type => expand_type)
     port map (nclk    => nclk,
               act     => ldq_act,
               forcee => func_sl_force,
               d_mode  => d_mode_dc,
               delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b,
               mpw2_b  => mpw2_dc_b,
               thold_b => func_sl_thold_0_b,
               sg      => sg_0,
               vd      => vdd,
               gd      => gnd,
               scin    => siv(l_m_rel_hit_beat5_offset to l_m_rel_hit_beat5_offset + l_m_rel_hit_beat5_l2'length-1),
               scout   => sov(l_m_rel_hit_beat5_offset to l_m_rel_hit_beat5_offset + l_m_rel_hit_beat5_l2'length-1),
               din     => l_m_rel_hit_beat5_d,
               dout    => l_m_rel_hit_beat5_l2);
   latch_rel_hit_beat6 : tri_rlmreg_p
     generic map (width => l_m_rel_hit_beat6_l2'length, init => 0, expand_type => expand_type)
     port map (nclk    => nclk,
               act     => ldq_act,
               forcee => func_sl_force,
               d_mode  => d_mode_dc,
               delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b,
               mpw2_b  => mpw2_dc_b,
               thold_b => func_sl_thold_0_b,
               sg      => sg_0,
               vd      => vdd,
               gd      => gnd,
               scin    => siv(l_m_rel_hit_beat6_offset to l_m_rel_hit_beat6_offset + l_m_rel_hit_beat6_l2'length-1),
               scout   => sov(l_m_rel_hit_beat6_offset to l_m_rel_hit_beat6_offset + l_m_rel_hit_beat6_l2'length-1),
               din     => l_m_rel_hit_beat6_d,
               dout    => l_m_rel_hit_beat6_l2);
   latch_rel_hit_beat7 : tri_rlmreg_p
     generic map (width => l_m_rel_hit_beat7_l2'length, init => 0, expand_type => expand_type)
     port map (nclk    => nclk,
               act     => ldq_act,
               forcee => func_sl_force,
               d_mode  => d_mode_dc,
               delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b,
               mpw2_b  => mpw2_dc_b,
               thold_b => func_sl_thold_0_b,
               sg      => sg_0,
               vd      => vdd,
               gd      => gnd,
               scin    => siv(l_m_rel_hit_beat7_offset to l_m_rel_hit_beat7_offset + l_m_rel_hit_beat7_l2'length-1),
               scout   => sov(l_m_rel_hit_beat7_offset to l_m_rel_hit_beat7_offset + l_m_rel_hit_beat7_l2'length-1),
               din     => l_m_rel_hit_beat7_d,
               dout    => l_m_rel_hit_beat7_l2);

latch_rel_inprog : tri_rlmreg_p
  generic map (width => l_m_rel_inprog_l2'length, init => 0, expand_type => expand_type)
  port map (nclk    => nclk,
            act     => ldq_act,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(l_m_rel_inprog_offset to l_m_rel_inprog_offset + l_m_rel_inprog_l2'length-1),
            scout   => sov(l_m_rel_inprog_offset to l_m_rel_inprog_offset + l_m_rel_inprog_l2'length-1),
            din     => l_m_rel_inprog_d,
            dout    => l_m_rel_inprog_l2);

latch_rel_c_i_beat0 : tri_rlmreg_p
  generic map (width => l_m_rel_c_i_beat0_l2'length, init => 0, expand_type => expand_type)
  port map (nclk    => nclk,
            act     => ldq_act,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(l_m_rel_c_i_beat0_offset to l_m_rel_c_i_beat0_offset + l_m_rel_c_i_beat0_l2'length-1),
            scout   => sov(l_m_rel_c_i_beat0_offset to l_m_rel_c_i_beat0_offset + l_m_rel_c_i_beat0_l2'length-1),
            din     => l_m_rel_c_i_beat0_d,
            dout    => l_m_rel_c_i_beat0_l2);

latch_rel_c_i_val : tri_rlmreg_p
  generic map (width => l_m_rel_val_c_i_dly'length, init => 0, expand_type => expand_type)
  port map (nclk    => nclk,
            act     => ldq_act,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(l_m_rel_c_i_val_offset to l_m_rel_c_i_val_offset + l_m_rel_val_c_i_dly'length-1),
            scout   => sov(l_m_rel_c_i_val_offset to l_m_rel_c_i_val_offset + l_m_rel_val_c_i_dly'length-1),
            din     => l_m_rel_c_i_val,
            dout    => l_m_rel_val_c_i_dly);



latch_rel_addr : tri_rlmreg_p
  generic map (width => rel_addr_l2'length, init => 0, expand_type => expand_type)
  port map (nclk    => nclk,
            act     => dminus1_act,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(rel_addr_offset to rel_addr_offset + rel_addr_l2'length-1),
            scout   => sov(rel_addr_offset to rel_addr_offset + rel_addr_l2'length-1),
            din     => rel_addr_d,
            dout    => rel_addr_l2);
latch_rel_cache_inh : tri_rlmreg_p
  generic map (width => 1, init => 0, expand_type => expand_type)
  port map (nclk    => nclk,
            act     => ldq_act,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(rel_cache_inh_offset to rel_cache_inh_offset),
            scout   => sov(rel_cache_inh_offset to rel_cache_inh_offset),
            din(0)  => rel_cache_inh_d,
            dout(0) => rel_cache_inh_l2);
latch_rel_size : tri_rlmreg_p
  generic map (width => rel_size_l2'length, init => 0, expand_type => expand_type)
  port map (nclk    => nclk,
            act     => dminus1_act,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(rel_size_offset to rel_size_offset + rel_size_l2'length-1),
            scout   => sov(rel_size_offset to rel_size_offset + rel_size_l2'length-1),
            din     => rel_size_d,
            dout    => rel_size_l2);
latch_rel_rot_sel : tri_rlmreg_p
  generic map (width => rel_rot_sel_l2'length, init => 0, expand_type => expand_type)
  port map (nclk    => nclk,
            act     => dminus1_act,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(rel_rot_sel_offset to rel_rot_sel_offset + rel_rot_sel_l2'length-1),
            scout   => sov(rel_rot_sel_offset to rel_rot_sel_offset + rel_rot_sel_l2'length-1),
            din     => rel_rot_sel_d,
            dout    => rel_rot_sel_l2);
latch_rel_th_id : tri_rlmreg_p
  generic map (width => rel_th_id_l2'length, init => 0, expand_type => expand_type)
  port map (nclk    => nclk,
            act     => dminus1_act,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(rel_th_id_offset to rel_th_id_offset + rel_th_id_l2'length-1),
            scout   => sov(rel_th_id_offset to rel_th_id_offset + rel_th_id_l2'length-1),
            din     => rel_th_id_d,
            dout    => rel_th_id_l2);
latch_rel_tar_gpr : tri_rlmreg_p
  generic map (width => rel_tar_gpr_l2'length, init => 0, expand_type => expand_type)
  port map (nclk    => nclk,
            act     => dminus1_act,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(rel_tar_gpr_offset to rel_tar_gpr_offset + rel_tar_gpr_l2'length-1),
            scout   => sov(rel_tar_gpr_offset to rel_tar_gpr_offset + rel_tar_gpr_l2'length-1),
            din     => rel_tar_gpr_d,
            dout    => rel_tar_gpr_l2);
latch_rel_vpr_val : tri_rlmreg_p
  generic map (width => 1, init => 0, expand_type => expand_type)
  port map (nclk    => nclk,
            act     => dminus1_act,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(rel_vpr_val_offset to rel_vpr_val_offset),
            scout   => sov(rel_vpr_val_offset to rel_vpr_val_offset),
            din(0)  => rel_vpr_val_d,
            dout(0) => rel_vpr_val_l2);
latch_rel_le_mode : tri_rlmreg_p
  generic map (width => 1, init => 0, expand_type => expand_type)
  port map (nclk    => nclk,
            act     => '1',
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(rel_le_mode_offset to rel_le_mode_offset),
            scout   => sov(rel_le_mode_offset to rel_le_mode_offset),
            din(0)  => rel_le_mode_d,
            dout(0) => rel_le_mode_l2);
latch_rel_dcbt : tri_rlmreg_p
  generic map (width => 1, init => 0, expand_type => expand_type)
  port map (nclk    => nclk,
            act     => dminus1_act,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(rel_dcbt_offset to rel_dcbt_offset),
            scout   => sov(rel_dcbt_offset to rel_dcbt_offset),
            din(0)  => rel_dcbt_d,
            dout(0) => rel_dcbt_l2);
latch_rel_algebraic : tri_rlmreg_p
  generic map (width => 1, init => 0, expand_type => expand_type)
  port map (nclk    => nclk,
            act     => dminus1_act,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(rel_algebraic_offset to rel_algebraic_offset),
            scout   => sov(rel_algebraic_offset to rel_algebraic_offset),
            din(0)  => rel_algebraic_d,
            dout(0) => rel_algebraic_l2);
latch_rel_l2only : tri_rlmreg_p
  generic map (width => 1, init => 0, expand_type => expand_type)
  port map (nclk    => nclk,
            act     => dminus1_act,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(rel_l2only_offset to rel_l2only_offset),
            scout   => sov(rel_l2only_offset to rel_l2only_offset),
            din(0)  => rel_l2only_d,
            dout(0) => rel_l2only_l2);
latch_rel_l2only_dly : tri_rlmreg_p
  generic map (width => 1, init => 0, expand_type => expand_type)
  port map (nclk    => nclk,
            act     => ldq_act,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(rel_l2only_dly_offset to rel_l2only_dly_offset),
            scout   => sov(rel_l2only_dly_offset to rel_l2only_dly_offset),
            din(0)  => rel_l2only_l2,
            dout(0) => rel_l2only_dly_l2);
latch_rel_lock_en : tri_rlmreg_p
  generic map (width => 1, init => 0, expand_type => expand_type)
  port map (nclk    => nclk,
            act     => dminus1_act,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(rel_lock_en_offset to rel_lock_en_offset),
            scout   => sov(rel_lock_en_offset to rel_lock_en_offset),
            din(0)  => rel_lock_en_d,
            dout(0) => rel_lock_en_l2);
latch_rel_classid : tri_rlmreg_p
  generic map (width => rel_classid_l2'length, init => 0, expand_type => expand_type)
  port map (nclk    => nclk,
            act     => dminus1_act,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(rel_classid_offset to rel_classid_offset + rel_classid_l2'length-1),
            scout   => sov(rel_classid_offset to rel_classid_offset + rel_classid_l2'length-1),
            din     => rel_classid_d,
            dout    => rel_classid_l2);
latch_rel_dvc1 : tri_rlmreg_p
  generic map (width => 1, init => 0, expand_type => expand_type)
  port map (nclk    => nclk,
            act     => dminus1_act,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(rel_dvc1_offset to rel_dvc1_offset),
            scout   => sov(rel_dvc1_offset to rel_dvc1_offset),
            din(0)  => rel_dvc1_d,
            dout(0) => rel_dvc1_l2);
latch_rel_dvc2 : tri_rlmreg_p
  generic map (width => 1, init => 0, expand_type => expand_type)
  port map (nclk    => nclk,
            act     => dminus1_act,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(rel_dvc2_offset to rel_dvc2_offset),
            scout   => sov(rel_dvc2_offset to rel_dvc2_offset),
            din(0)  => rel_dvc2_d,
            dout(0) => rel_dvc2_l2);
latch_rel_watch_en : tri_rlmreg_p
  generic map (width => 1, init => 0, expand_type => expand_type)
  port map (nclk    => nclk,
            act     => dminus1_act,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(rel_watch_en_offset to rel_watch_en_offset),
            scout   => sov(rel_watch_en_offset to rel_watch_en_offset),
            din(0)  => rel_watch_en_d,
            dout(0) => rel_watch_en_l2);

----------------------------------------------
---- Reload Complete pulse
----------------------------------------------
---- Reload is complete
---- 1) cacheable reload is complete
---- 2) uncacheable reload is complete
---- Reload Complete pulse

rel_done_g: for i in 0 to lmq_entries-1 generate begin
   ld_m_rel_done_d(i) <= (l_m_rel_hit_beat3_l2(i) and not my_xucr0_cls) or
                         (l_m_rel_hit_beat7_l2(i) and     my_xucr0_cls) or
                         l_m_rel_val_c_i_dly(i);

   ldq_retry_d(i) <= (ld_m_rel_done_l2(i) and ldq_recirc_rel_val and not ecc_err(i)) or
                     (ldq_retry_l2(i) and not ld_m_rel_done_l2(i));
end generate;


latch_ld_m_rel_done : tri_rlmreg_p
  generic map (width => ld_m_rel_done_l2'length, init => 0, expand_type => expand_type)
  port map (nclk    => nclk,
            act     => ldq_act,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(ld_m_rel_done_offset to ld_m_rel_done_offset + ld_m_rel_done_l2'length-1),
            scout   => sov(ld_m_rel_done_offset to ld_m_rel_done_offset + ld_m_rel_done_l2'length-1),
            din     => ld_m_rel_done_d(0 to lmq_entries-1),
            dout    => ld_m_rel_done_l2(0 to lmq_entries-1));

ld_m_rel_done_no_retry <= not gate_and(ldq_recirc_rel_val, not ecc_err) and ld_m_rel_done_l2;

latch_ldq_retry : tri_rlmreg_p
  generic map (width => ldq_retry_l2'length, init => 0, expand_type => expand_type)
  port map (nclk    => nclk,
            act     => ldq_act,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(ldq_retry_offset to ldq_retry_offset + ldq_retry_l2'length-1),
            scout   => sov(ldq_retry_offset to ldq_retry_offset + ldq_retry_l2'length-1),
            din     => ldq_retry_d(0 to lmq_entries-1),
            dout    => ldq_retry_l2(0 to lmq_entries-1));

latch_ld_m_rel_done_dly : tri_rlmreg_p
  generic map (width => ld_m_rel_done_dly_l2'length, init => 0, expand_type => expand_type)
  port map (nclk    => nclk,
            act     => ldq_act,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(ld_m_rel_done_dly_offset to ld_m_rel_done_dly_offset + ld_m_rel_done_dly_l2'length-1),
            scout   => sov(ld_m_rel_done_dly_offset to ld_m_rel_done_dly_offset + ld_m_rel_done_dly_l2'length-1),
            din     => ld_m_rel_done_no_retry(0 to lmq_entries-1),
            dout    => ld_m_rel_done_dly_l2(0 to lmq_entries-1));

latch_ld_m_rel_done_dly2 : tri_rlmreg_p
  generic map (width => ld_m_rel_done_dly2_l2'length, init => 0, expand_type => expand_type)
  port map (nclk    => nclk,
            act     => ldq_act,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(ld_m_rel_done_dly2_offset to ld_m_rel_done_dly2_offset + ld_m_rel_done_dly2_l2'length-1),
            scout   => sov(ld_m_rel_done_dly2_offset to ld_m_rel_done_dly2_offset + ld_m_rel_done_dly2_l2'length-1),
            din     => ld_m_rel_done_dly_l2(0 to lmq_entries-1),
            dout    => ld_m_rel_done_dly2_l2(0 to lmq_entries-1));

reset_lmq_gen: for i in 0 to lmq_entries-1 generate begin
   reset_lmq_entry_rel(i) <= ld_m_rel_done_dly2_l2(i)  and not data_ecc_err_l2(i);  
end generate;

--************************************************************************************************************
--************************************************************************************************************
-- END: Reload Operation
--************************************************************************************************************
--************************************************************************************************************


any_ld_val_p:  process (ld_entry_val_l2)
   variable b: std_ulogic;
begin
      b := '0';
      for i in 0 to lmq_entries-1 loop
         b := ld_entry_val_l2(i) or b;
      end loop;
      any_ld_entry_val <= b;
end process;
	   



blk_ld_for_pe_recov_d <= ex7_ld_par_err or
                         (blk_ld_for_pe_recov_l2 and not pe_recov_begin);
latch_blk_ld_for_pe_recov : tri_rlmreg_p
  generic map (width => 1, init => 0, expand_type => expand_type)
  port map (nclk    => nclk,
            act     => '1',
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(blk_ld_for_pe_recov_offset to blk_ld_for_pe_recov_offset),
            scout   => sov(blk_ld_for_pe_recov_offset to blk_ld_for_pe_recov_offset),
            din(0)  => blk_ld_for_pe_recov_d,
            dout(0) => blk_ld_for_pe_recov_l2 );

lq_rd_en_gen: for i in 0 to lmq_entries-1 generate begin

   ldq_rd_seq_match_curr(i) <= l_m_queue(i)(22 to 26) = cmd_seq_rd_l2(0 to 4);
   ldq_rd_seq_match_next(i) <= l_m_queue(i)(22 to 26) = cmd_seq_rd_incr(0 to 4);

   l_q_rd_en(i) <= ldq_rd_seq_match_l2(i) and ld_entry_val_l2(i) and not l_m_q_hit_st_l2(i) and not ex7_ld_par_err and not blk_ld_for_pe_recov_l2;
   rd_seq_hit(i) <= ldq_rd_seq_match_l2(i) and ld_entry_val_l2(i);
end generate;

cmp_l_q_rd_en <= l_q_rd_en;

cmd_seq_rd_incr_val <= load_sent or selected_entry_flushed or rd_seq_num_skip;

with cmd_seq_rd_incr_val select
    ldq_rd_seq_match_d <= ldq_rd_seq_match_next when '1',
                          ldq_rd_seq_match_curr when others;

latch_ldq_rd_seq_match : tri_rlmreg_p
  generic map (width => ldq_rd_seq_match_l2'length, init => 0, expand_type => expand_type)
  port map (nclk    => nclk,
            act     => ldq_act,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(ldq_rd_seq_match_offset to ldq_rd_seq_match_offset + ldq_rd_seq_match_l2'length-1),
            scout   => sov(ldq_rd_seq_match_offset to ldq_rd_seq_match_offset + ldq_rd_seq_match_l2'length-1),
            din     => ldq_rd_seq_match_d(0 to lmq_entries-1),
            dout    => ldq_rd_seq_match_l2(0 to lmq_entries-1));

selected_ld_val_p:  process (l_q_rd_en, rd_seq_hit)
   variable b,c : std_ulogic;
begin
      b := '0';
      c := '0';
      for i in 0 to lmq_entries-1 loop
         b := l_q_rd_en(i) or b;
         c := rd_seq_hit(i) or c;
      end loop;
      selected_ld_entry_val <= b;
      rd_seq_num_exits <= c;
end process;

rd_seq_num_skip <= any_ld_entry_val and not rd_seq_num_exits;



q4_lmentry: if lmq_entries=4 generate begin 
    l_miss_entry <= gate_and(l_q_rd_en(0), l_m_queue(0)) or 
                    gate_and(l_q_rd_en(1), l_m_queue(1)) or
                    gate_and(l_q_rd_en(2), l_m_queue(2)) or
                    gate_and(l_q_rd_en(3), l_m_queue(3));
    l_miss_addrlo <= gate_and(l_q_rd_en(0), l_m_queue_addrlo(0)(58 to 63)) or 
                     gate_and(l_q_rd_en(1), l_m_queue_addrlo(1)(58 to 63)) or
                     gate_and(l_q_rd_en(2), l_m_queue_addrlo(2)(58 to 63)) or
                     gate_and(l_q_rd_en(3), l_m_queue_addrlo(3)(58 to 63));

   lq_rd_en_is_ex5        <= (rd_seq_hit(0) and ex5_loadmiss_qentry(0)) or
                             (rd_seq_hit(1) and ex5_loadmiss_qentry(1)) or 
                             (rd_seq_hit(2) and ex5_loadmiss_qentry(2)) or 
                             (rd_seq_hit(3) and ex5_loadmiss_qentry(3));
   lq_rd_en_is_ex6        <= (rd_seq_hit(0) and ex6_loadmiss_qentry(0)) or
                             (rd_seq_hit(1) and ex6_loadmiss_qentry(1)) or 
                             (rd_seq_hit(2) and ex6_loadmiss_qentry(2)) or 
                             (rd_seq_hit(3) and ex6_loadmiss_qentry(3));
end generate;

q8_lmentry: if lmq_entries=8 generate begin 
    l_miss_entry <= gate_and(l_q_rd_en(0), l_m_queue(0)) or 
                    gate_and(l_q_rd_en(1), l_m_queue(1)) or
                    gate_and(l_q_rd_en(2), l_m_queue(2)) or
                    gate_and(l_q_rd_en(3), l_m_queue(3)) or 
                    gate_and(l_q_rd_en(4), l_m_queue(4)) or 
                    gate_and(l_q_rd_en(5), l_m_queue(5)) or
                    gate_and(l_q_rd_en(6), l_m_queue(6)) or
                    gate_and(l_q_rd_en(7), l_m_queue(7));
    l_miss_addrlo <= gate_and(l_q_rd_en(0), l_m_queue_addrlo(0)(58 to 63)) or 
                     gate_and(l_q_rd_en(1), l_m_queue_addrlo(1)(58 to 63)) or
                     gate_and(l_q_rd_en(2), l_m_queue_addrlo(2)(58 to 63)) or
                     gate_and(l_q_rd_en(3), l_m_queue_addrlo(3)(58 to 63)) or 
                     gate_and(l_q_rd_en(4), l_m_queue_addrlo(4)(58 to 63)) or 
                     gate_and(l_q_rd_en(5), l_m_queue_addrlo(5)(58 to 63)) or
                     gate_and(l_q_rd_en(6), l_m_queue_addrlo(6)(58 to 63)) or
                     gate_and(l_q_rd_en(7), l_m_queue_addrlo(7)(58 to 63));

   lq_rd_en_is_ex5        <= (rd_seq_hit(0) and ex5_loadmiss_qentry(0)) or
                             (rd_seq_hit(1) and ex5_loadmiss_qentry(1)) or 
                             (rd_seq_hit(2) and ex5_loadmiss_qentry(2)) or 
                             (rd_seq_hit(3) and ex5_loadmiss_qentry(3)) or 
                             (rd_seq_hit(4) and ex5_loadmiss_qentry(4)) or 
                             (rd_seq_hit(5) and ex5_loadmiss_qentry(5)) or 
                             (rd_seq_hit(6) and ex5_loadmiss_qentry(6)) or 
                             (rd_seq_hit(7) and ex5_loadmiss_qentry(7));
   lq_rd_en_is_ex6        <= (rd_seq_hit(0) and ex6_loadmiss_qentry(0)) or
                             (rd_seq_hit(1) and ex6_loadmiss_qentry(1)) or 
                             (rd_seq_hit(2) and ex6_loadmiss_qentry(2)) or 
                             (rd_seq_hit(3) and ex6_loadmiss_qentry(3)) or 
                             (rd_seq_hit(4) and ex6_loadmiss_qentry(4)) or 
                             (rd_seq_hit(5) and ex6_loadmiss_qentry(5)) or 
                             (rd_seq_hit(6) and ex6_loadmiss_qentry(6)) or 
                             (rd_seq_hit(7) and ex6_loadmiss_qentry(7));
end generate;

-- above logic could be replaced with this process if you want a more general and elegant (but harder to read) version
--lmentry_p:  process (l_q_rd_en, l_m_queue)
--   variable b: std_ulogic_vector(0 to (69+(real_data_add-1)));
--begin
--      b := (others => '0');
--      for i in 0 to lmq_entries-1 loop
--         b := gate_and(l_q_rd_en(i), l_m_queue(i)) or b;
--      end loop;
--      l_miss_entry <= b;
--end process;
	   

--******************************************************
-- Setting up Instruction Fetch
--******************************************************
-- Need to match ld/st Q entry that is sent to L2
iu_f_entry(0 to 5) <= "000000";                                                      -- ctype
iu_f_entry(6 to 37) <= x"00000000";                                                  -- byte enables
iu_f_entry(38 to 41) <= iu_f_q0_sel & iu_f_q1_sel & iu_f_q2_sel & iu_f_q3_sel;       -- thread_id
iu_f_entry(42 to 46) <= iu_f_sel_entry(0 to 4);                                      -- wimge
iu_f_entry(47 to 49) <= "110";                                                       -- transfer length

iu_f_entry(50 to 53) <= iu_f_sel_entry(5 to 8);                                                 -- user defined bits
iu_f_entry(54 to (54+real_data_add-1)) <= iu_f_sel_entry(9 to (9+REAL_IFAR_length-1)) & "0000"; -- real address

iu_thrd(0) <= iu_f_q2_sel or iu_f_q3_sel;
iu_thrd(1) <= iu_f_q1_sel or iu_f_q3_sel;

--******************************************************
-- Setting up ld request
--******************************************************
ldmq_entry(0 to 5) <= l_miss_entry(1 to 6);                                 -- ctype
ldmq_entry(6 to 37) <= x"00000000";                                         -- byte enables
ldmq_entry(38 to 41) <= l_miss_entry(18 to 21);                             -- thread_id
ldmq_entry(42 to 45) <= l_miss_entry(39 to 42);                             -- wimg
ldmq_entry(46) <= l_miss_entry(53);                                         -- Little Endian
--ldmq_entry(47 to 49) <= "011"   when l_miss_entry(0)  = '0'   else          -- transfer length:  full cache line
ldmq_entry(47 to 49) <= "001"   when l_miss_entry(12) = '1'   else          --                   1 byte
                        "010"   when l_miss_entry(11) = '1'   else          --                   2 bytes
                        "100"   when l_miss_entry(10) = '1'   else          --                   4 bytes
                        "101"   when l_miss_entry(9)  = '1'   else          --                   8 bytes
                        "110"   when l_miss_entry(8)  = '1'   else          --                  16 bytes
                        "111"   when l_miss_entry(7)  = '1'   else          --                  32 bytes
                        "000";
ldmq_entry(50 to 53) <= l_miss_entry(43 to 46);                             -- user defined bits
--ldmq_entry(54 to (54+real_data_add-1)) <= l_miss_entry(54 to (54+real_data_add-1));  -- real address
ldmq_entry(54 to (54+real_data_add-1)) <= cmp_l_miss_entry_addr & l_miss_addrlo;  -- real address

--******************************************************
-- Setting up mmu request
--******************************************************
with mmu_q_entry_l2(0 to 1) select                                       -- ctype
   mmuq_req(0 to 5) <=  "111100"  when "00",                                -- TLBIVAX
                        "111011"  when "01",                                -- TBLI Complete
                        "000010"  when "10",                                -- mmu load (tag=01100)
                        "000010"  when others;                              -- mmu load (tag=01101)
                        
mmuq_req(6 to 37) <= x"00000000";                                           -- byte enables
mmuq_req(38 to 41) <= mmu_q_entry_l2(2 to 5);                               -- thread_id
mmuq_req(42 to 45) <= mmu_q_entry_l2(6 to 9);                               -- wimg
mmuq_req(46) <= mmu_q_entry_l2(10);                                         -- Little Endian
mmuq_req(47 to 49) <= "000";                                                -- transfer length
mmuq_req(50 to 53) <= mmu_q_entry_l2(11 to 14);                             -- user defined bits
mmuq_req(54 to (54+real_data_add-1)) <= mmu_q_entry_l2(26 to (26+real_data_add-1));  -- real address


iu_mmu_entry <= gate_and(send_if_req_l2, iu_f_entry) or
                gate_and(send_mm_req_l2, mmuq_req);

ld_tag(1 to 4) <= gate_and(send_if_req_l2, "10" & iu_thrd) or 
                  gate_and(send_ld_req_l2, '0'  & l_m_tag) or 
                  gate_and(send_mm_req_l2, "110" & mmu_q_entry_l2(1) );

--******************************************************
-- Setting up store request
--******************************************************
store_entry(0 to 5) <= s_m_queue0(0 to 5);                                      -- ctype
store_entry(6 to 37) <= s_m_queue0(6 to 37);                                    -- byte enables
store_entry(38 to 41) <= s_m_queue0(38 to 41);                                  -- thread_id
store_entry(42 to 45) <= s_m_queue0(43 to 46);                                  -- wimg
store_entry(46) <= s_m_queue0(42);                                              -- Little Endian
store_entry(47 to 49) <= "001"   when s_m_queue0(56) = '1'   else               -- transfer length   1 byte
                         "010"   when s_m_queue0(55) = '1'   else               --                   2 bytes
                         "100"   when s_m_queue0(54) = '1'   else               --                   4 bytes
                         "101"   when s_m_queue0(53) = '1'   else               --                   8 bytes
                         "110"   when s_m_queue0(52) = '1'   else               --                  16 bytes
                         "111"   when s_m_queue0(51) = '1'   else               --                  32 bytes
                         "000";
store_entry(50 to 53) <= s_m_queue0(47 to 50);                                  -- user defined bits
store_entry(54 to (54+real_data_add-1)) <= s_m_queue0(58 to (58+real_data_add-1));  -- real address


--******************************************************
-- Store requests from Boxes
--******************************************************
latch_ob_pwr_tok : tri_rlmreg_p
  generic map (width => 1, init => 0, expand_type => expand_type)
  port map (nclk    => nclk,
            act     => '1',
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(ob_pwr_tok_offset to ob_pwr_tok_offset),
            scout   => sov(ob_pwr_tok_offset to ob_pwr_tok_offset),
            din(0)  => bx_lsu_ob_pwr_tok,
            dout(0) => ob_pwr_tok_l2 );

ob_act <= ob_pwr_tok_l2 or ob_req_val_l2 or ob_ditc_val_l2 or clkg_ctl_override_q;

ob_req_val_mux <= ob_req_val_l2                             when bx_cmd_stall_d='1'  else
                  bx_lsu_ob_req_val and not bx_stall_dly_or;
latch_ob_req_val : tri_rlmreg_p
  generic map (width => 1, init => 0, expand_type => expand_type)
  port map (nclk    => nclk,
            act     => ob_act,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(ob_req_val_offset to ob_req_val_offset),
            scout   => sov(ob_req_val_offset to ob_req_val_offset),
            din(0)  => ob_req_val_mux,
            dout(0) => ob_req_val_l2 );
latch_ob_req_val_clone : tri_rlmreg_p
  generic map (width => 1, init => 0, expand_type => expand_type)
  port map (nclk    => nclk,
            act     => ob_act,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(ob_req_val_clone_offset to ob_req_val_clone_offset),
            scout   => sov(ob_req_val_clone_offset to ob_req_val_clone_offset),
            din(0)  => ob_req_val_mux,
            dout(0) => ob_req_val_clone_l2 );

ob_ditc_val_mux <= ob_ditc_val_l2                            when bx_cmd_stall_d='1'  else
                   bx_lsu_ob_ditc_val and not bx_stall_dly_or;
latch_ob_ditc_val : tri_rlmreg_p
  generic map (width => 1, init => 0, expand_type => expand_type)
  port map (nclk    => nclk,
            act     => ob_act,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(ob_ditc_val_offset to ob_ditc_val_offset),
            scout   => sov(ob_ditc_val_offset to ob_ditc_val_offset),
            din(0)  => ob_ditc_val_mux,
            dout(0) => ob_ditc_val_l2 );
latch_ob_ditc_val_clone : tri_rlmreg_p
  generic map (width => 1, init => 0, expand_type => expand_type)
  port map (nclk    => nclk,
            act     => ob_act,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(ob_ditc_val_clone_offset to ob_ditc_val_clone_offset),
            scout   => sov(ob_ditc_val_clone_offset to ob_ditc_val_clone_offset),
            din(0)  => ob_ditc_val_mux,
            dout(0) => ob_ditc_val_clone_l2 );

lsu_bx_cmd_avail <= not (ob_req_val_l2 or ob_ditc_val_l2);

ob_thrd_mux <= ob_thrd_l2   when bx_cmd_stall_d='1'  else
               bx_lsu_ob_thrd;
latch_ob_thrd : tri_rlmreg_p
  generic map (width => ob_thrd_l2'length, init => 0, expand_type => expand_type)
  port map (nclk    => nclk,
            act     => ob_act,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(ob_thrd_offset to ob_thrd_offset + ob_thrd_l2'length-1),
            scout   => sov(ob_thrd_offset to ob_thrd_offset + ob_thrd_l2'length-1),
            din     => ob_thrd_mux,
            dout    => ob_thrd_l2 );

ob_qw_mux <= ob_qw_l2   when bx_cmd_stall_d='1'  else
             bx_lsu_ob_qw;
latch_ob_qw : tri_rlmreg_p
  generic map (width => ob_qw_l2'length, init => 0, expand_type => expand_type)
  port map (nclk    => nclk,
            act     => ob_act,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(ob_qw_offset to ob_qw_offset + ob_qw_l2'length-1),
            scout   => sov(ob_qw_offset to ob_qw_offset + ob_qw_l2'length-1),
            din     => ob_qw_mux,
            dout    => ob_qw_l2 );

ob_dest_mux <= ob_dest_l2   when bx_cmd_stall_d='1'  else
               bx_lsu_ob_dest;
latch_ob_dest : tri_rlmreg_p
  generic map (width => ob_dest_l2'length, init => 0, expand_type => expand_type)
  port map (nclk    => nclk,
            act     => ob_act,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(ob_dest_offset to ob_dest_offset + ob_dest_l2'length-1),
            scout   => sov(ob_dest_offset to ob_dest_offset + ob_dest_l2'length-1),
            din     => ob_dest_mux,
            dout    => ob_dest_l2 );

ob_addr_mux <= ob_addr_l2   when bx_cmd_stall_d='1'  else
               bx_lsu_ob_addr;
latch_ob_addr : tri_rlmreg_p
  generic map (width => ob_addr_l2'length, init => 0, expand_type => expand_type)
  port map (nclk    => nclk,
            act     => ob_act,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(ob_addr_offset to ob_addr_offset + ob_addr_l2'length-1),
            scout   => sov(ob_addr_offset to ob_addr_offset + ob_addr_l2'length-1),
            din     => ob_addr_mux,
            dout    => ob_addr_l2 );

ob_data_mux <= ob_data_l2   when bx_cmd_stall_d='1'  else
               bx_lsu_ob_data;
latch_ob_data : tri_rlmreg_p
  generic map (width => ob_data_l2'length, init => 0, expand_type => expand_type)
  port map (nclk    => nclk,
            act     => ob_act,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(ob_data_offset to ob_data_offset + ob_data_l2'length-1),
            scout   => sov(ob_data_offset to ob_data_offset + ob_data_l2'length-1),
            din     => ob_data_mux,
            dout    => ob_data_l2 );

ob_store(0 to 5) <= "100000"        when ob_req_val_l2='1'  else  -- ctype for store
                    "100010";                                     -- ctype for ditc

ob_store(6 to 37) <= x"00000000"    when ob_ditc_val_l2='1' else  -- byte enables
                     x"FFFF0000"    when ob_qw_l2(59)='0'   else 
                     x"0000FFFF";
ob_store(38) <= ob_thrd_l2(0 to 1)="00";                          -- thread_id
ob_store(39) <= ob_thrd_l2(0 to 1)="01";                          -- thread_id
ob_store(40) <= ob_thrd_l2(0 to 1)="10";                          -- thread_id
ob_store(41) <= ob_thrd_l2(0 to 1)="11";                          -- thread_id
ob_store(42 to 45) <= "1010";                                     -- wimg
ob_store(46) <= '0';                                              -- Little Endian
ob_store(47 to 49) <= "110";                                      -- len = 16 bytes
ob_store(50 to 53) <= "0000";                                     -- user defined bits
ob_store(54 to (54+real_data_add-7)) <= ob_addr_l2;               -- real address
ob_store((54+real_data_add-6) to (54+real_data_add-5)) <= ob_qw_l2(58 to 59);
ob_store((54+real_data_add-4) to (54+real_data_add-1)) <= "0000";


st_req <= st_recycle_l2        when st_recycle_v_l2='1'  else 
          store_entry          when st_entry0_val_l2='1' else
          ob_store;

ld_st_request <= st_req        when (ex5_sel_st_req or ((ob_req_val_l2 or ob_ditc_val_l2 or st_recycle_v_l2) and store_credit)) = '1'   else
                 ldmq_entry    when send_ld_req_l2 = '1' else 
                 iu_mmu_entry;


cred_pop <= anaclat_st_pop or anaclat_st_gather or (my_xucr0_cred and anaclat_ld_pop) or blk_st_cred_pop;
ex4_sel_st_req <= ( ( (ex4_st_val_l2 and not ex4_flush_store) and
                      ( (store_credit and not one_st_cred ) or 
                        (one_st_cred and not nxt_st_cred_tkn) or
                        (one_st_cred and     nxt_st_cred_tkn and cred_pop) or
                        (not store_credit and not st_entry0_val_l2 and cred_pop) )  )  or
                    (st_entry0_val_l2 and not (ex5_flush_store and ex5_st_val_l2) and (store_credit or cred_pop))  ); 

latch_ex5_sel_st_req : tri_rlmreg_p
  generic map (width => 1, init => 0, expand_type => expand_type)
  port map (nclk    => nclk,
            act     => stq_act,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(ex5_sel_st_req_offset to ex5_sel_st_req_offset),
            scout   => sov(ex5_sel_st_req_offset to ex5_sel_st_req_offset),
            din(0)  => ex4_sel_st_req,
            dout(0) => ex5_sel_st_req );


store_sent <= (st_entry0_val_l2 and store_credit and not (ex5_flush_store and ex5_st_val_l2) and ex5_sel_st_req) or
              ((ob_req_val_l2 or ob_ditc_val_l2) and store_credit and not st_entry0_val_l2 and not st_recycle_v_l2 and not (l2req_resend_l2 and ex7_ld_par_err)) or
              (st_recycle_v_l2 and store_credit);


load_sent <= not ex5_sel_st_req and send_ld_req_l2 and load_credit and selected_ld_entry_val and
             not (lq_rd_en_is_ex5 and ex5_flush_load_local) and 
             not (lq_rd_en_is_ex6 and ex6_flush_l2) and
             not ((ob_req_val_l2 or ob_ditc_val_l2 or st_recycle_v_l2) and store_credit); 

load_flushed <= send_ld_req_l2 and selected_ld_entry_val and
                ((lq_rd_en_is_ex5 and ex5_flush_load_local) or (lq_rd_en_is_ex6 and ex6_flush_l2));

selected_entry_flushed <= selected_ld_entry_val and
                          ((lq_rd_en_is_ex5 and ex5_flush_load_local) or (lq_rd_en_is_ex6 and ex6_flush_l2));

mmu_st_sent <= store_credit and not st_entry0_val_l2 and not ob_req_val_l2 and not ob_ditc_val_l2 and
               send_mm_req_l2 and mmu_q_val and not mmu_q_entry_l2(0) and not (l2req_resend_l2 and ex7_ld_par_err) and
               not ex5_sel_st_req and not st_recycle_v_l2;


mmu_ld_sent <= load_credit and not ex5_sel_st_req and send_mm_req_l2 and mmu_q_val and mmu_q_entry_l2(0) and
               not (l2req_resend_l2 and ex7_ld_par_err) and
               not ((ob_req_val_l2 or ob_ditc_val_l2 or st_recycle_v_l2) and store_credit);
mmu_sent <= mmu_st_sent or mmu_ld_sent or (l2req_resend_l2 and ex7_ld_par_err and mmu_sent_l2);

-- resend or recycle the L2 request if it will be blocked by a load data parity error (resend goes back on the L2
-- interface the next cycle and recycle will go back to the store queue).

l2req_resend_d <= mmu_sent or bx_cmd_sent_d or iu_sent_val or
                  (load_sent and not lq_rd_en_is_ex5 and not (ex5_flush_load_all and lq_rd_en_is_ex5)) or
                  (l2req_resend_l2 and ex7_ld_par_err);
l2req_recycle_d <= store_sent and not (ob_req_val_l2 or ob_ditc_val_l2);



bx_cmd_sent_d <= (ob_req_val_l2 or ob_ditc_val_l2) and store_credit and
                 not (st_entry0_val_l2 ) and not st_recycle_v_l2 and 
                 not (l2req_resend_l2 and ex7_ld_par_err);


bx_cmd_stall_d <= (ob_req_val_l2 or ob_ditc_val_l2) and
                  (not store_credit or (st_entry0_val_l2 ) or st_recycle_v_l2 or 
                       (l2req_resend_l2 and ex7_ld_par_err));

latch_bx_cmd_sent : tri_rlmreg_p
  generic map (width => 1, init => 0, expand_type => expand_type)
  port map (nclk    => nclk,
            act     => '1',
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(bx_cmd_sent_offset to bx_cmd_sent_offset),
            scout   => sov(bx_cmd_sent_offset to bx_cmd_sent_offset),
            din(0)  => bx_cmd_sent_d,
            dout(0) => bx_cmd_sent_l2 );

lsu_bx_cmd_sent <= bx_cmd_sent_l2;

latch_bx_cmd_stall : tri_rlmreg_p
  generic map (width => 1, init => 0, expand_type => expand_type)
  port map (nclk    => nclk,
            act     => '1',
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(bx_cmd_stall_offset to bx_cmd_stall_offset),
            scout   => sov(bx_cmd_stall_offset to bx_cmd_stall_offset),
            din(0)  => bx_cmd_stall_d,
            dout(0) => bx_cmd_stall_l2 );

lsu_bx_cmd_stall <= bx_cmd_stall_l2;

bx_stall_dly_d(0) <= bx_cmd_stall_l2;
bx_stall_dly_d(1) <= bx_stall_dly_l2(0);
bx_stall_dly_d(2) <= bx_stall_dly_l2(1);
bx_stall_dly_d(3) <= bx_stall_dly_l2(3);

bx_stall_dly_or   <= not(bx_stall_dly_l2(0 to 2)="000") or bx_cmd_stall_l2;

latch_bx_stall_dly : tri_rlmreg_p
  generic map (width => bx_stall_dly_l2'length, init => 0, expand_type => expand_type)
  port map (nclk    => nclk,
            act     => '1',
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(bx_stall_dly_offset to bx_stall_dly_offset + bx_stall_dly_l2'length-1),
            scout   => sov(bx_stall_dly_offset to bx_stall_dly_offset + bx_stall_dly_l2'length-1),
            din     => bx_stall_dly_d(0 to 3),
            dout    => bx_stall_dly_l2(0 to 3) );

latch_xu_mm_lsu_token : tri_rlmreg_p
  generic map (width => 1, init => 0, expand_type => expand_type)
  port map (nclk    => nclk,
            act     => '1',
            forcee => func_slp_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_slp_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(xu_mm_lsu_token_offset to xu_mm_lsu_token_offset),
            scout   => sov(xu_mm_lsu_token_offset to xu_mm_lsu_token_offset),
            din(0)  => mmu_sent,
            dout(0) => mmu_sent_l2 );

xu_mm_lsu_token <= mmu_sent_l2 and not ex7_ld_par_err;

-- set bit to indicate that an op was flushed due to a lmq address hit (use to set and release barrior to IU)


ex3_val_req <= (ex3_local_dcbf or ex3_l_s_q_val) and not ex3_stg_flush;

-- latch into ex4
latch_ex4_val_req : tri_rlmreg_p
  generic map (width => 1, init => 0, expand_type => expand_type)
  port map (nclk    => nclk,
            act     => '1',
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(ex4_val_req_offset to ex4_val_req_offset),
            scout   => sov(ex4_val_req_offset to ex4_val_req_offset),
            din(0)  => ex3_val_req,
            dout(0) => ex4_val_req );
latch_ex4_thrd_id : tri_rlmreg_p
  generic map (width => ex4_thrd_id'length, init => 0, expand_type => expand_type)
  port map (nclk    => nclk,
            act     => ex4_st_entry_act,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(ex4_thrd_id_offset to ex4_thrd_id_offset + ex4_thrd_id'length-1),
            scout   => sov(ex4_thrd_id_offset to ex4_thrd_id_offset + ex4_thrd_id'length-1),
            din     => ex3_thrd_id(0 to 3),
            dout    => ex4_thrd_id(0 to 3) );
latch_ex5_thrd_id : tri_rlmreg_p
  generic map (width => ex5_thrd_id'length, init => 0, expand_type => expand_type)
  port map (nclk    => nclk,
            act     => '1',
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(ex5_thrd_id_offset to ex5_thrd_id_offset + ex5_thrd_id'length-1),
            scout   => sov(ex5_thrd_id_offset to ex5_thrd_id_offset + ex5_thrd_id'length-1),
            din     => ex4_thrd_id(0 to 3),
            dout    => ex5_thrd_id(0 to 3) );




lmq_collision: for i in 0 to lmq_entries-1 generate begin
   lmq_collision_t0_d(i) <= ( (ex5_lmq_cpy_l2(i) and ld_rel_val_l2(i) and not ex4_loadmiss_qentry(i) and xu_lsu_ex5_set_barr(0)) or 
                                 lmq_collision_t0_l2(i)) and not reset_ldq_hit_barr(i);
   lmq_collision_t1_d(i) <= ( (ex5_lmq_cpy_l2(i) and ld_rel_val_l2(i) and not ex4_loadmiss_qentry(i) and xu_lsu_ex5_set_barr(1)) or 
                                 lmq_collision_t1_l2(i)) and not reset_ldq_hit_barr(i);
   lmq_collision_t2_d(i) <= ( (ex5_lmq_cpy_l2(i) and ld_rel_val_l2(i) and not ex4_loadmiss_qentry(i) and xu_lsu_ex5_set_barr(2)) or 
                                 lmq_collision_t2_l2(i)) and not reset_ldq_hit_barr(i);
   lmq_collision_t3_d(i) <= ( (ex5_lmq_cpy_l2(i) and ld_rel_val_l2(i) and not ex4_loadmiss_qentry(i) and xu_lsu_ex5_set_barr(3)) or 
                                 lmq_collision_t3_l2(i)) and not reset_ldq_hit_barr(i);
end generate;


lmq_barr_done_p:  process (reset_ldq_hit_barr, lmq_collision_t0_l2, lmq_collision_t1_l2, lmq_collision_t2_l2, lmq_collision_t3_l2, ex5_lmq_cpy_l2, xu_lsu_ex5_set_barr, ld_rel_val_l2, ex4_loadmiss_qentry )
   variable b: std_ulogic_vector(0 to 3);
begin
      b := "0000";
      for i in 0 to lmq_entries-1 loop
         b(0) := (reset_ldq_hit_barr(i) and lmq_collision_t0_l2(i)) or
                 (ex5_lmq_cpy_l2(i) and xu_lsu_ex5_set_barr(0) and (not ld_rel_val_l2(i) or reset_ldq_hit_barr(i) or (ld_rel_val_l2(i) and ex4_loadmiss_qentry(i)))) or b(0);
         b(1) := (reset_ldq_hit_barr(i) and lmq_collision_t1_l2(i)) or
                 (ex5_lmq_cpy_l2(i) and xu_lsu_ex5_set_barr(1) and (not ld_rel_val_l2(i) or reset_ldq_hit_barr(i) or (ld_rel_val_l2(i) and ex4_loadmiss_qentry(i)))) or b(1);
         b(2) := (reset_ldq_hit_barr(i) and lmq_collision_t2_l2(i)) or
                 (ex5_lmq_cpy_l2(i) and xu_lsu_ex5_set_barr(2) and (not ld_rel_val_l2(i) or reset_ldq_hit_barr(i) or (ld_rel_val_l2(i) and ex4_loadmiss_qentry(i)))) or b(2);
         b(3) := (reset_ldq_hit_barr(i) and lmq_collision_t3_l2(i)) or
                 (ex5_lmq_cpy_l2(i) and xu_lsu_ex5_set_barr(3) and (not ld_rel_val_l2(i) or reset_ldq_hit_barr(i) or (ld_rel_val_l2(i) and ex4_loadmiss_qentry(i)))) or b(3);
      end loop;
      lmq_barr_done_tid(0 to 3) <= b;
end process;


latch_lmq_collision_t0 : tri_rlmreg_p
  generic map (width => lmq_collision_t0_l2'length, init => 0, expand_type => expand_type)
  port map (nclk    => nclk,
            act     => ldq_act,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(lmq_collision_t0_offset to lmq_collision_t0_offset + lmq_collision_t0_l2'length-1),
            scout   => sov(lmq_collision_t0_offset to lmq_collision_t0_offset + lmq_collision_t0_l2'length-1),
            din     => lmq_collision_t0_d,
            dout    => lmq_collision_t0_l2 );

latch_lmq_collision_t1 : tri_rlmreg_p
  generic map (width => lmq_collision_t1_l2'length, init => 0, expand_type => expand_type)
  port map (nclk    => nclk,
            act     => ldq_act,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(lmq_collision_t1_offset to lmq_collision_t1_offset + lmq_collision_t1_l2'length-1),
            scout   => sov(lmq_collision_t1_offset to lmq_collision_t1_offset + lmq_collision_t1_l2'length-1),
            din     => lmq_collision_t1_d,
            dout    => lmq_collision_t1_l2 );

latch_lmq_collision_t2 : tri_rlmreg_p
  generic map (width => lmq_collision_t2_l2'length, init => 0, expand_type => expand_type)
  port map (nclk    => nclk,
            act     => ldq_act,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(lmq_collision_t2_offset to lmq_collision_t2_offset + lmq_collision_t2_l2'length-1),
            scout   => sov(lmq_collision_t2_offset to lmq_collision_t2_offset + lmq_collision_t2_l2'length-1),
            din     => lmq_collision_t2_d,
            dout    => lmq_collision_t2_l2 );

latch_lmq_collision_t3 : tri_rlmreg_p
  generic map (width => lmq_collision_t3_l2'length, init => 0, expand_type => expand_type)
  port map (nclk    => nclk,
            act     => ldq_act,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(lmq_collision_t3_offset to lmq_collision_t3_offset + lmq_collision_t3_l2'length-1),
            scout   => sov(lmq_collision_t3_offset to lmq_collision_t3_offset + lmq_collision_t3_l2'length-1),
            din     => lmq_collision_t3_d,
            dout    => lmq_collision_t3_l2 );

ldq_barr_active_d(0 to 3) <= (xu_lsu_ex5_set_barr(0 to 3) and not lmq_barr_done_tid(0 to 3)) or
                             (ldq_barr_active_l2(0 to 3) and not lmq_barr_done_tid(0 to 3));

latch_ldq_barr_active : tri_rlmreg_p
  generic map (width => ldq_barr_active_l2'length, init => 0, expand_type => expand_type)
  port map (nclk    => nclk,
            act     => ldq_act,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(ldq_barr_active_offset to ldq_barr_active_offset + ldq_barr_active_l2'length-1),
            scout   => sov(ldq_barr_active_offset to ldq_barr_active_offset + ldq_barr_active_l2'length-1),
            din     => ldq_barr_active_d(0 to 3),
            dout    => ldq_barr_active_l2(0 to 3) );

sync_done <= store_sent and ( ((s_m_queue0(0 to 5) = "110010") or (s_m_queue0(0 to 5) = "101010")) or   -- mbar,lwsync
                              (not my_xucr0_tlbsync  and ( s_m_queue0(0 to 5) = "111010"))) and         -- tlbsync
             not (ex5_stg_flush and ex5_st_val_for_flush) and st_entry0_val_l2;


sync_done_tid <= gate_and(sync_done, s_m_queue0(38 to 41));
ldq_barr_done <= lmq_barr_done_tid(0 to 3) and (ldq_barr_active_l2(0 to 3) or xu_lsu_ex5_set_barr(0 to 3));


-- Signals Going to IU, Need to flag when the L2 has acknowledged an lwsync or eieio
latch_ldq_barr_done : tri_rlmreg_p
  generic map (width => ldq_barr_done'length, init => 0, expand_type => expand_type)
  port map (nclk    => nclk,
            act     => '1',
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(ldq_barr_done_offset to ldq_barr_done_offset + ldq_barr_done'length-1),
            scout   => sov(ldq_barr_done_offset to ldq_barr_done_offset + ldq_barr_done'length-1),
            din     => ldq_barr_done(0 to 3),
            dout    => ldq_barr_done_l2(0 to 3) );

lsu_xu_ldq_barr_done <= ldq_barr_done_l2;

latch_sync_done_tid : tri_rlmreg_p
  generic map (width => sync_done_tid'length, init => 0, expand_type => expand_type)
  port map (nclk    => nclk,
            act     => '1',
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(sync_done_tid_offset to sync_done_tid_offset + sync_done_tid'length-1),
            scout   => sov(sync_done_tid_offset to sync_done_tid_offset + sync_done_tid'length-1),
            din     => sync_done_tid(0 to 3),
            dout    => sync_done_tid_l2(0 to 3) );

lsu_xu_sync_barr_done <= sync_done_tid_l2;


q4_tag: if lmq_entries=4 generate begin 
   l_m_tag(2) <= '0';
   l_m_tag(3) <= l_q_rd_en(2) or l_q_rd_en(3);
   l_m_tag(4) <= l_q_rd_en(1) or l_q_rd_en(3);
end generate;

q8_tag: if lmq_entries=8 generate begin 
   l_m_tag(2) <= l_q_rd_en(4) or l_q_rd_en(5) or l_q_rd_en(6) or l_q_rd_en(7);
   l_m_tag(3) <= l_q_rd_en(2) or l_q_rd_en(3) or l_q_rd_en(6) or l_q_rd_en(7);
   l_m_tag(4) <= l_q_rd_en(1) or l_q_rd_en(3) or l_q_rd_en(5) or l_q_rd_en(7);
end generate;



   
--******************************************************
-- Outputs
--******************************************************

-- bit(0:5) => ctype
-- bit(6:21) => byte enables
-- bit(22:25) => thread_id
-- bit(26:29) => wimg
-- bit(30) => little endian
-- bit(31:33) => transfer length
-- bit(34:62) => real address

-- ***************************************************************************************************
-- Signals Going to L2

l2req_pwr_token <= iu_val or any_ld_entry_val or st_entry0_val_l2 or ex4_ld_m_val or ex4_st_val_l2 or 
                   mmu_q_val_l2 or
                   ob_req_val_l2 or ob_ditc_val_l2 or ob_pwr_tok_l2 or l2req_resend_d or st_recycle_v_l2 or (l2req_recycle_l2 and ex7_ld_par_err);


ex5_st_val_for_flush <= ex5_st_val_l2; 

l2req <= (load_sent and not (lq_rd_en_is_ex5 and ex5_flush_load_all) ) or
         (store_sent  and not (ex5_stg_flush and ex5_st_val_for_flush)) or
         iu_sent_val or mmu_sent                                         when (l2req_resend_l2 and ex7_ld_par_err) = '0' else
         '1';

l2req_gated <= l2req and not ex6_ld_par_err;

l2req_st_data_ptoken <= (ex4_st_val_l2 and not ex4_flush_store and
                            ((ex4_st_entry_l2(0 to 5)="100000") or (ex4_st_entry_l2(0 to 4)="10011") or (ex4_st_entry_l2(0 to 5)="101001"))) or
                        (st_entry0_val_l2 and ((s_m_queue0(0 to 5)="100000") or (s_m_queue0(0 to 4)="10011") or (s_m_queue0(0 to 5)="101001"))) or 
                        ob_req_val_l2 or ob_ditc_val_l2 or ob_pwr_tok_l2 or mmu_st_sent or bx_cmd_sent_d or 
                        (mmu_q_val_l2 and (mmu_q_entry_l2(0 to 1)="00")) or st_recycle_v_l2 or
                        ((l2req_resend_l2 or l2req_recycle_l2) and ex7_ld_par_err);

l2req_ld_core_tag(0) <= '0';
l2req_ld_core_tag(1 to 4) <= ld_tag(1 to 4)  when (l2req_resend_l2 and ex7_ld_par_err) = '0' else
                             l2req_ld_core_tag_l2(1 to 4);

l2req_ra <= ld_st_request(54 to (54+real_data_add-1))  when (l2req_resend_l2 and ex7_ld_par_err) = '0' else
            l2req_ra_l2;

std_be_16: if st_data_32B_mode=0 generate begin
   l2req_st_byte_enbl <= l2req_st_byte_enbl_l2     when (l2req_resend_l2 and ex7_ld_par_err) = '1' else
                         ld_st_request(6 to 21)    when st_req(54+real_data_add-1-4) = '0'  else 
                         ld_st_request(22 to 37);

   st_recycle_entry(6 to 37)  <= l2req_st_byte_enbl_l2(0 to 15) & l2req_st_byte_enbl_l2(0 to 15);

end generate;

copy_st_be_for_16B_mode <= st_req(54+real_data_add-1-4) and not my_xucr0_l2siw;

std_be_32: if st_data_32B_mode=1 generate begin
   l2req_st_byte_enbl(0 to 15) <= l2req_st_byte_enbl_l2(0 to 15)   when (l2req_resend_l2 and ex7_ld_par_err) = '1' else
                                  ld_st_request(6 to 21)           when copy_st_be_for_16B_mode = '0'  else 
                                  ld_st_request(22 to 37); 
   l2req_st_byte_enbl(16 to 31) <= l2req_st_byte_enbl_l2(16 to 31) when (l2req_resend_l2 and ex7_ld_par_err) = '1' else
                                   ld_st_request(22 to 37);

   st_recycle_entry(6 to 37)  <= l2req_st_byte_enbl_l2(0 to 31);
end generate;

-- encode thread ID that is 1-hot in 38:41
l2req_thread(0) <= ld_st_request(40) or ld_st_request(41) when (l2req_resend_l2 and ex7_ld_par_err) = '0' else
                   l2req_thread_l2(0);  
l2req_thread(1) <= ld_st_request(39) or ld_st_request(41) when (l2req_resend_l2 and ex7_ld_par_err) = '0' else
                   l2req_thread_l2(1);

l2req_thread(2) <= not st_entry0_val_l2 and (ob_req_val_l2 or ob_ditc_val_l2) and store_credit when (l2req_resend_l2 and ex7_ld_par_err) = '0' else
                   l2req_thread_l2(2);
l2req_ttype(0 to 5) <= ld_st_request(0 to 5) when (l2req_resend_l2 and ex7_ld_par_err) = '0' else
                       l2req_ttype_l2(0 to 5);
l2req_wimg <= ld_st_request(42 to 45) when (l2req_resend_l2 and ex7_ld_par_err) = '0' else
              l2req_wimg_l2;
l2req_user <= ld_st_request(50 to 53) when (l2req_resend_l2 and ex7_ld_par_err) = '0' else
              l2req_user_l2;
l2req_endian <= ld_st_request(46) when (l2req_resend_l2 and ex7_ld_par_err) = '0' else
                l2req_endian_l2;
l2req_ld_xfr_len <= ld_st_request(47 to 49) when (l2req_resend_l2 and ex7_ld_par_err) = '0' else
                    l2req_ld_xfr_len_l2;



latch_l2req_resend : tri_rlmreg_p
  generic map (width => 1, init => 0, expand_type => expand_type)
  port map (nclk    => nclk,
            act     => '1',
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(l2req_resend_offset to l2req_resend_offset),
            scout   => sov(l2req_resend_offset to l2req_resend_offset),
            din(0)  => l2req_resend_d,
            dout(0) => l2req_resend_l2);

latch_l2req_recycle : tri_rlmreg_p
  generic map (width => 1, init => 0, expand_type => expand_type)
  port map (nclk    => nclk,
            act     => '1',
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(l2req_recycle_offset to l2req_recycle_offset),
            scout   => sov(l2req_recycle_offset to l2req_recycle_offset),
            din(0)  => l2req_recycle_d,
            dout(0) => l2req_recycle_l2);

latch_l2req_pwr_token : tri_rlmreg_p
  generic map (width => 1, init => 0, expand_type => expand_type)
  port map (nclk    => nclk,
            act     => '1',
            forcee => func_slp_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_slp_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(l2req_pwr_token_offset to l2req_pwr_token_offset),
            scout   => sov(l2req_pwr_token_offset to l2req_pwr_token_offset),
            din(0)  => l2req_pwr_token,
            dout(0) => l2req_pwr_token_l2 );

ac_an_req_pwr_token <= l2req_pwr_token_l2;

latch_l2req_st_data_ptoken : tri_rlmreg_p
  generic map (width => 1, init => 0, expand_type => expand_type)
  port map (nclk    => nclk,
            act     => '1',
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(l2req_st_data_ptoken_offset to l2req_st_data_ptoken_offset),
            scout   => sov(l2req_st_data_ptoken_offset to l2req_st_data_ptoken_offset),
            din(0)  => l2req_st_data_ptoken,
            dout(0) => l2req_st_data_ptoken_l2 );

ac_an_st_data_pwr_token <= l2req_st_data_ptoken_l2;

latch_l2req : tri_rlmreg_p
  generic map (width => 1, init => 0, expand_type => expand_type)
  port map (nclk    => nclk,
            act     => '1',
            forcee => func_slp_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_slp_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(l2req_offset to l2req_offset),
            scout   => sov(l2req_offset to l2req_offset),
            din(0)  => l2req_gated,
            dout(0) => l2req_l2  );
ac_an_req <= l2req_l2;

l2req_act <= l2req_pwr_token_l2 or clkg_ctl_override_q;

latch_l2req_ld_core_tag : tri_rlmreg_p
  generic map (width => l2req_ld_core_tag'length, init => 0, expand_type => expand_type)
  port map (nclk    => nclk,
            act     => l2req_act,
            forcee => func_slp_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_slp_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(l2req_ld_core_tag_offset to l2req_ld_core_tag_offset + l2req_ld_core_tag'length-1),
            scout   => sov(l2req_ld_core_tag_offset to l2req_ld_core_tag_offset + l2req_ld_core_tag'length-1),
            din     => l2req_ld_core_tag,
            dout    => l2req_ld_core_tag_l2 );
ac_an_req_ld_core_tag <= l2req_ld_core_tag_l2;

latch_l2req_ra : tri_rlmreg_p
  generic map (width => l2req_ra'length, init => 0, expand_type => expand_type)
  port map (nclk    => nclk,
            act     => l2req_act,
            forcee => func_slp_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_slp_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(l2req_ra_offset to l2req_ra_offset + l2req_ra'length-1),
            scout   => sov(l2req_ra_offset to l2req_ra_offset + l2req_ra'length-1),
            din     => l2req_ra,
            dout    => l2req_ra_l2 );
ac_an_req_ra <= l2req_ra_l2;

latch_l2req_st_byte_enbl : tri_rlmreg_p
  generic map (width => l2req_st_byte_enbl'length, init => 0, expand_type => expand_type)
  port map (nclk    => nclk,
            act     => l2req_act,
            forcee => func_slp_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_slp_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(l2req_st_byte_enbl_offset to l2req_st_byte_enbl_offset + l2req_st_byte_enbl'length-1),
            scout   => sov(l2req_st_byte_enbl_offset to l2req_st_byte_enbl_offset + l2req_st_byte_enbl'length-1),
            din     => l2req_st_byte_enbl,
            dout    => l2req_st_byte_enbl_l2 );
ac_an_st_byte_enbl <= l2req_st_byte_enbl_l2;

latch_l2req_thread : tri_rlmreg_p
  generic map (width => l2req_thread'length, init => 0, expand_type => expand_type)
  port map (nclk    => nclk,
            act     => l2req_act,
            forcee => func_slp_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_slp_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(l2req_thread_offset to l2req_thread_offset + l2req_thread'length-1),
            scout   => sov(l2req_thread_offset to l2req_thread_offset + l2req_thread'length-1),
            din     => l2req_thread(0 to 2),
            dout    => l2req_thread_l2(0 to 2) );
ac_an_req_thread(0 to 2) <= l2req_thread_l2(0 to 2);

latch_l2req_ttype : tri_rlmreg_p
  generic map (width => l2req_ttype'length, init => 0, expand_type => expand_type)
  port map (nclk    => nclk,
            act     => l2req_act,
            forcee => func_slp_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_slp_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(l2req_ttype_offset to l2req_ttype_offset + l2req_ttype'length-1),
            scout   => sov(l2req_ttype_offset to l2req_ttype_offset + l2req_ttype'length-1),
            din     => l2req_ttype(0 to 5),
            dout    => l2req_ttype_l2(0 to 5) );
ac_an_req_ttype <= l2req_ttype_l2;

latch_l2req_wimg : tri_rlmreg_p
  generic map (width => l2req_wimg'length, init => 0, expand_type => expand_type)
  port map (nclk    => nclk,
            act     => l2req_act,
            forcee => func_slp_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_slp_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(l2req_wimg_offset to l2req_wimg_offset + l2req_wimg'length-1),
            scout   => sov(l2req_wimg_offset to l2req_wimg_offset + l2req_wimg'length-1),
            din     => l2req_wimg(0 to 3),
            dout    => l2req_wimg_l2(0 to 3) );
ac_an_req_wimg_w <= l2req_wimg_l2(0);
ac_an_req_wimg_i <= l2req_wimg_l2(1);
ac_an_req_wimg_m <= l2req_wimg_l2(2);
ac_an_req_wimg_g <= l2req_wimg_l2(3);


latch_l2req_endian : tri_rlmreg_p
  generic map (width => 1, init => 0, expand_type => expand_type)
  port map (nclk    => nclk,
            act     => l2req_act,
            forcee => func_slp_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_slp_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(l2req_endian_offset to l2req_endian_offset),
            scout   => sov(l2req_endian_offset to l2req_endian_offset),
            din(0)  => l2req_endian,
            dout(0) => l2req_endian_l2 );
ac_an_req_endian <= l2req_endian_l2;


latch_l2req_user : tri_rlmreg_p
  generic map (width => l2req_user'length, init => 0, expand_type => expand_type)
  port map (nclk    => nclk,
            act     => l2req_act,
            forcee => func_slp_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_slp_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(l2req_user_offset to l2req_user_offset + l2req_user'length-1),
            scout   => sov(l2req_user_offset to l2req_user_offset + l2req_user'length-1),
            din     => l2req_user(0 to 3),
            dout    => l2req_user_l2(0 to 3) );
ac_an_req_user_defined <= l2req_user_l2;

latch_l2req_ld_xfr_len : tri_rlmreg_p
  generic map (width => l2req_ld_xfr_len'length, init => 0, expand_type => expand_type)
  port map (nclk    => nclk,
            act     => l2req_act,
            forcee => func_slp_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_slp_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(l2req_ld_xfr_len_offset to l2req_ld_xfr_len_offset + l2req_ld_xfr_len'length-1),
            scout   => sov(l2req_ld_xfr_len_offset to l2req_ld_xfr_len_offset + l2req_ld_xfr_len'length-1),
            din     => l2req_ld_xfr_len(0 to 2),
            dout    => l2req_ld_xfr_len_l2 );
ac_an_req_ld_xfr_len <= l2req_ld_xfr_len_l2;

latch_spare_ctrl_a0 : tri_rlmreg_p
  generic map (width => ac_an_req_spare_ctrl_a0'length, init => 0, expand_type => expand_type)
  port map (nclk    => nclk,
            act     => '0',
            forcee => func_slp_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_slp_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(spare_ctrl_a0_offset to spare_ctrl_a0_offset + ac_an_req_spare_ctrl_a0'length-1),
            scout   => sov(spare_ctrl_a0_offset to spare_ctrl_a0_offset + ac_an_req_spare_ctrl_a0'length-1),
            din     => "0000",
            dout    => ac_an_req_spare_ctrl_a0 );

latch_spare_ctrl_a1 : tri_rlmreg_p
  generic map (width => an_ac_req_spare_ctrl_a1'length, init => 0, expand_type => expand_type)
  port map (nclk    => nclk,
            act     => '0',
            forcee => func_slp_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_slp_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(spare_ctrl_a1_offset to spare_ctrl_a1_offset + an_ac_req_spare_ctrl_a1'length-1),
            scout   => sov(spare_ctrl_a1_offset to spare_ctrl_a1_offset + an_ac_req_spare_ctrl_a1'length-1),
            din     => an_ac_req_spare_ctrl_a1,
            dout    => unused(0 to 3) );



-- format l2 request back into a store entry for recycling after a dcache parity error
st_recycle_entry(0 to 5)   <= l2req_ttype_l2;

-- byte enables set above

st_recycle_entry(38)       <= l2req_thread_l2(0 to 1) = "00";
st_recycle_entry(39)       <= l2req_thread_l2(0 to 1) = "01";
st_recycle_entry(40)       <= l2req_thread_l2(0 to 1) = "10";
st_recycle_entry(41)       <= l2req_thread_l2(0 to 1) = "11";
st_recycle_entry(42 to 45) <= l2req_wimg_l2;
st_recycle_entry(46)       <= l2req_endian_l2;
st_recycle_entry(47 to 49) <= l2req_ld_xfr_len_l2;
st_recycle_entry(50 to 53) <= l2req_user_l2;
st_recycle_entry(54 to (54+real_data_add-1)) <= l2req_ra_l2;

st_recycle_d <= st_recycle_entry when st_recycle_v_l2='0' else
                st_recycle_l2;

st_recycle_act <= l2req_l2 or st_recycle_v_l2 or ex7_ld_par_err or clkg_ctl_override_q;

latch_st_recycle : tri_rlmreg_p
  generic map (width => st_recycle_l2'length, init => 0, expand_type => expand_type)
  port map (nclk    => nclk,
            act     => st_recycle_act,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(st_recycle_offset to st_recycle_offset + st_recycle_l2'length-1),
            scout   => sov(st_recycle_offset to st_recycle_offset + st_recycle_l2'length-1),
            din     => st_recycle_d,
            dout    => st_recycle_l2 );

st_recycle_v_d <= (l2req_recycle_l2 and ex7_ld_par_err and not (ex6_flush_l2 and ex6_st_val_l2)) or
                  (st_recycle_v_l2 and not store_sent);

latch_st_recycle_v : tri_rlmreg_p
  generic map (width => 1, init => 0, expand_type => expand_type)
  port map (nclk    => nclk,
            act     => st_recycle_act,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(st_recycle_v_offset to st_recycle_v_offset),
            scout   => sov(st_recycle_v_offset to st_recycle_v_offset),
            din(0)  => st_recycle_v_d,
            dout(0) => st_recycle_v_l2 );

-- *************************************************************************
-- latch info about late ex5 flush into ex6

ex5_load <= load_sent and lq_rd_en_is_ex5;

latch_ex6_load_sent : tri_rlmreg_p
  generic map (width => 1, init => 0, expand_type => expand_type)
  port map (nclk    => nclk,
            act     => ldq_act,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(ex6_load_sent_offset to ex6_load_sent_offset),
            scout   => sov(ex6_load_sent_offset to ex6_load_sent_offset),
            din(0)  => ex5_load,
            dout(0) => ex6_load_sent_l2 );

latch_load_sent_dbglat : tri_rlmreg_p
  generic map (width => 1, init => 0, expand_type => expand_type)
  port map (nclk    => nclk,
            act     => ldq_act,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(load_sent_dbglat_offset to load_sent_dbglat_offset),
            scout   => sov(load_sent_dbglat_offset to load_sent_dbglat_offset),
            din(0)  => load_sent,
            dout(0) => load_sent_dbglat_l2 );

ex5_store_sent <= store_sent and ex5_st_val_for_flush;

latch_ex6_store_sent : tri_rlmreg_p
  generic map (width => 1, init => 0, expand_type => expand_type)
  port map (nclk    => nclk,
            act     => stq_act,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(ex6_store_sent_offset to ex6_store_sent_offset),
            scout   => sov(ex6_store_sent_offset to ex6_store_sent_offset),
            din(0)  => ex5_store_sent,
            dout(0) => ex6_store_sent_l2 );


ex5_flush_d <= ex4_stg_flush;

latch_ex5_flush : tri_rlmreg_p
  generic map (width => 1, init => 0, expand_type => expand_type)
  port map (nclk    => nclk,
            act     => '1',
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(ex5_flush_offset to ex5_flush_offset),
            scout   => sov(ex5_flush_offset to ex5_flush_offset),
            din(0)  => ex5_flush_d,
            dout(0) => ex5_flush_l2 );

ex5_stg_flush <= ((xu_lsu_ex5_flush(0) and ex5_thrd_id(0)) or   -- thread 0 flush
                  (xu_lsu_ex5_flush(1) and ex5_thrd_id(1)) or   -- thread 1 flush
                  (xu_lsu_ex5_flush(2) and ex5_thrd_id(2)) or   -- thread 2 flush
                  (xu_lsu_ex5_flush(3) and ex5_thrd_id(3))) and -- thread 3 flush
                 not pe_recov_state_l2;
-- XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

my_ex5_flush <= ex5_stg_flush or ex5_flush_l2;

ex5_flush_store <= ex5_flush_l2; -- and not (s_m_queue0(0 to 4) = "10111");  -- dci & ici aren't flushed
my_ex5_flush_store <= (ex5_stg_flush or ex5_flush_l2); -- and not (s_m_queue0(0 to 4) = "10111");  -- dci & ici aren't flushed

latch_ex6_flush : tri_rlmreg_p
  generic map (width => 1, init => 0, expand_type => expand_type)
  port map (nclk    => nclk,
            act     => '1',
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(ex6_flush_offset to ex6_flush_offset),
            scout   => sov(ex6_flush_offset to ex6_flush_offset),
            din(0)  => ex5_stg_flush,
            dout(0) => ex6_flush_l2 );


-- *************************************************************************
-- latch msr and pid inputs

latch_msr_gs : tri_rlmreg_p
  generic map (width => msr_gs_l2'length, init => 0, expand_type => expand_type)
  port map (nclk    => nclk,
            act     => ex4_st_entry_act,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(msr_gs_offset to msr_gs_offset + msr_gs_l2'length-1),
            scout   => sov(msr_gs_offset to msr_gs_offset + msr_gs_l2'length-1),
            din     => xu_lsu_msr_gs(0 to 3),
            dout    => msr_gs_l2 );

latch_msr_pr : tri_rlmreg_p
  generic map (width => msr_pr_l2'length, init => 0, expand_type => expand_type)
  port map (nclk    => nclk,
            act     => ex4_st_entry_act,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(msr_pr_offset to msr_pr_offset + msr_pr_l2'length-1),
            scout   => sov(msr_pr_offset to msr_pr_offset + msr_pr_l2'length-1),
            din     => xu_lsu_msr_pr(0 to 3),
            dout    => msr_pr_l2 );

latch_msr_ds : tri_rlmreg_p
  generic map (width => msr_ds_l2'length, init => 0, expand_type => expand_type)
  port map (nclk    => nclk,
            act     => ex4_st_entry_act,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(msr_ds_offset to msr_ds_offset + msr_ds_l2'length-1),
            scout   => sov(msr_ds_offset to msr_ds_offset + msr_ds_l2'length-1),
            din     => xu_lsu_msr_ds(0 to 3),
            dout    => msr_ds_l2 );

latch_pid0 : tri_rlmreg_p
  generic map (width => pid0_l2'length, init => 0, expand_type => expand_type)
  port map (nclk    => nclk,
            act     => ex4_st_entry_act,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(pid0_offset to pid0_offset + pid0_l2'length-1),
            scout   => sov(pid0_offset to pid0_offset + pid0_l2'length-1),
            din     => mm_xu_derat_pid0(0 to 13),
            dout    => pid0_l2 );

latch_pid1 : tri_rlmreg_p
  generic map (width => pid1_l2'length, init => 0, expand_type => expand_type)
  port map (nclk    => nclk,
            act     => ex4_st_entry_act,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(pid1_offset to pid1_offset + pid1_l2'length-1),
            scout   => sov(pid1_offset to pid1_offset + pid1_l2'length-1),
            din     => mm_xu_derat_pid1(0 to 13),
            dout    => pid1_l2 );

latch_pid2 : tri_rlmreg_p
  generic map (width => pid2_l2'length, init => 0, expand_type => expand_type)
  port map (nclk    => nclk,
            act     => ex4_st_entry_act,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(pid2_offset to pid2_offset + pid2_l2'length-1),
            scout   => sov(pid2_offset to pid2_offset + pid2_l2'length-1),
            din     => mm_xu_derat_pid2(0 to 13),
            dout    => pid2_l2 );

latch_pid3 : tri_rlmreg_p
  generic map (width => pid3_l2'length, init => 0, expand_type => expand_type)
  port map (nclk    => nclk,
            act     => ex4_st_entry_act,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(pid3_offset to pid3_offset + pid3_l2'length-1),
            scout   => sov(pid3_offset to pid3_offset + pid3_l2'length-1),
            din     => mm_xu_derat_pid3(0 to 13),
            dout    => pid3_l2 );

-- *************************************************************************
-- STORE DATA

msr_hv <= or_reduce(not msr_gs_l2(0 to 3) and ex4_st_entry_l2(38 to 41));   -- use thread of req to select msr bit
msr_pr <= or_reduce(msr_pr_l2(0 to 3) and ex4_st_entry_l2(38 to 41));   -- use thread of req to select msr bit
msr_ds <= or_reduce(msr_ds_l2(0 to 3) and ex4_st_entry_l2(38 to 41));   -- use thread of req to select msr bit
pid(0 to 13) <= gate_and(ex4_st_entry_l2(38) , pid0_l2(0 to 13)) or
                gate_and(ex4_st_entry_l2(39) , pid1_l2(0 to 13)) or
                gate_and(ex4_st_entry_l2(40) , pid2_l2(0 to 13)) or
                gate_and(ex4_st_entry_l2(41) , pid3_l2(0 to 13));

ditc_dat <= "00000000" &                                         -- MSR byte
            "00" &                                               -- reserved
            "000001" &                                           -- CT=1 for DITC
            ob_dest_l2(0 to 14) & '0' &                          -- dest
            "00000000" &                                         -- LPID
            "0000000000000000" &                                 -- PID
            x"000000000000000000";

epsc_epr <= (xu_derat_epsc0_epr and ex4_st_entry_l2(38)) or
            (xu_derat_epsc1_epr and ex4_st_entry_l2(39)) or
            (xu_derat_epsc2_epr and ex4_st_entry_l2(40)) or
            (xu_derat_epsc3_epr and ex4_st_entry_l2(41));

epsc_eas <= (xu_derat_epsc0_eas and ex4_st_entry_l2(38)) or
            (xu_derat_epsc1_eas and ex4_st_entry_l2(39)) or
            (xu_derat_epsc2_eas and ex4_st_entry_l2(40)) or
            (xu_derat_epsc3_eas and ex4_st_entry_l2(41));

epsc_egs <= (xu_derat_epsc0_egs and ex4_st_entry_l2(38)) or
            (xu_derat_epsc1_egs and ex4_st_entry_l2(39)) or
            (xu_derat_epsc2_egs and ex4_st_entry_l2(40)) or
            (xu_derat_epsc3_egs and ex4_st_entry_l2(41));

epsc_elpid <= (gate_and(ex4_st_entry_l2(38), xu_derat_epsc0_elpid)) or
              (gate_and(ex4_st_entry_l2(39), xu_derat_epsc1_elpid)) or 
              (gate_and(ex4_st_entry_l2(40), xu_derat_epsc2_elpid)) or 
              (gate_and(ex4_st_entry_l2(41), xu_derat_epsc3_elpid));

epsc_epid <= (gate_and(ex4_st_entry_l2(38), xu_derat_epsc0_epid)) or
             (gate_and(ex4_st_entry_l2(39), xu_derat_epsc1_epid)) or 
             (gate_and(ex4_st_entry_l2(40), xu_derat_epsc2_epid)) or 
             (gate_and(ex4_st_entry_l2(41), xu_derat_epsc3_epid));

ex4_icswx_extra_data(0 to 2) <= not epsc_egs & epsc_epr & epsc_eas   when ex4_st_entry_l2(57)='1'  else   -- for icswepx
                                msr_hv & msr_pr & msr_ds;

ex4_icswx_extra_data(3 to 24)  <= epsc_elpid & epsc_epid             when ex4_st_entry_l2(57)='1'  else   -- for icswepx
                                  lpidr_l2(0 to 7) & pid(0 to 13);

stq_icswx_extra_data_d <= stq_icswx_extra_data_l2   when (st_entry0_val_l2 and not (store_credit and ex5_sel_st_req))='1'   else
                          ex4_icswx_extra_data;

latch_stq_icswx_extra_data : tri_rlmreg_p
  generic map (width => stq_icswx_extra_data_l2'length, init => 0, expand_type => expand_type)
  port map (nclk    => nclk,
            act     => stq_act,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(stq_icswx_extra_data_offset to stq_icswx_extra_data_offset + stq_icswx_extra_data_l2'length-1),
            scout   => sov(stq_icswx_extra_data_offset to stq_icswx_extra_data_offset + stq_icswx_extra_data_l2'length-1),
            din     => stq_icswx_extra_data_d,
            dout    => stq_icswx_extra_data_l2 );

icswx_dat(0 to 31) <= stq_icswx_extra_data_l2(0 to 2) & "0000000" & ex5_st_data_l2(10 to 31);

icswx_dat(32 to 55)  <= stq_icswx_extra_data_l2(3 to 10) & "00" & stq_icswx_extra_data_l2(11 to 24);

icswx_dat(56 to 127) <= ex5_st_data_l2(56 to 127);

latch_ex4_p_addr_59 : tri_rlmreg_p
  generic map (width => 1, init => 0, expand_type => expand_type)
  port map (nclk    => nclk,
            act     => ex3_stg_act,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(ex4_p_addr_59_offset to ex4_p_addr_59_offset),
            scout   => sov(ex4_p_addr_59_offset to ex4_p_addr_59_offset),
            din(0)  => ex3_p_addr(59),
            dout(0) => ex4_p_addr_59 );

std16B: if st_data_32B_mode=0 generate begin

   ex4_st_data_mux(0 to 127) <= 
                                ex4_256st_data(0 to 127)      when ex4_p_addr_59 = '0'  else
                                ex4_256st_data(128 to 255);
end generate;

copy_st_data_for_16B_mode <= ex4_p_addr_59 and not my_xucr0_l2siw;

std32B: if st_data_32B_mode=1 generate begin
   ex4_st_data_mux(0 to 127) <= ex4_256st_data(0 to 127)      when copy_st_data_for_16B_mode = '0'  else  
                                ex4_256st_data(128 to 255);
   ex4_st_data_mux(128 to 255) <= ex4_256st_data(128 to 255);

   ex5_st_data_mux(128 to 255) <= ex6_st_data_l2(128 to 255)  when (((l2req_resend_l2 or l2req_recycle_l2) and ex7_ld_par_err) or
                                                                    st_recycle_v_l2) = '1'    else
                                  ex5_st_data_l2(128 to 255)  when st_entry0_val_clone_l2='1' else
                                  ob_data_l2(0 to 127);      -- when ob_req_val_l2='1'
                                  
end generate;



ex4_st_data_mux2 <= ex5_st_data_l2   when ((l2req_recycle_l2 and ex7_ld_par_err) or st_recycle_v_l2) = '1' else
                    ex4_st_data_mux  when (st_entry0_val_l2 and not (store_credit and ex5_sel_st_req))='0' else
                    ex5_st_data_l2;

latch_ex5_st_data : tri_rlmreg_p
  generic map (width => ex5_st_data_l2'length, init => 0, expand_type => expand_type)
  port map (nclk    => nclk,
            act     => stq_act,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(ex5_st_data_offset to ex5_st_data_offset + ex5_st_data_l2'length-1),
            scout   => sov(ex5_st_data_offset to ex5_st_data_offset + ex5_st_data_l2'length-1),
            din     => ex4_st_data_mux2,
            dout    => ex5_st_data_l2 );


ex5_st_data_mux1(0 to 127) <= icswx_dat(0 to 127)         when s_m_queue0(0 to 4)="10011" else
                              ex5_st_data_l2(0 to 127);

ex5_st_data_mux2(0 to 127) <= ob_data_l2(0 to 127)        when ob_req_val_clone_l2='1'    else
                              ditc_dat(0 to 127)          when ob_ditc_val_clone_l2='1'   else
                              ex5_st_data_l2(0 to 31) &
                                mmu_q_entry_l2(15 to 22) &    -- lpid
                                "00000" &                     -- reserved
                                mmu_q_entry_l2(23 to 25) &    -- IND,GS,L
                                ex5_st_data_l2(48 to 127);

ex5_st_data_mux(0 to 127) <= ex6_st_data_l2(0 to 127)  when (((l2req_resend_l2 or l2req_recycle_l2) and ex7_ld_par_err) or
                                                              st_recycle_v_l2) = '1'    else
                             ex5_st_data_mux1          when st_entry0_val_clone_l2='1'  else
                             ex5_st_data_mux2;

st_data_act <= l2req_st_data_ptoken_l2 or clkg_ctl_override_q;

latch_ex6_st_data : tri_rlmreg_p
  generic map (width => ac_an_st_data'length, init => 0, expand_type => expand_type)
  port map (nclk    => nclk,
            act     => st_data_act,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(ex6_st_data_offset to ex6_st_data_offset + ac_an_st_data'length-1),
            scout   => sov(ex6_st_data_offset to ex6_st_data_offset + ac_an_st_data'length-1),
            din     => ex5_st_data_mux,
            dout    => ex6_st_data_l2 );
ac_an_st_data <= ex6_st_data_l2;

-- ***************************************************************************************************
-- Flush Conditions
ex3_stq_flush <= flush_if_store or sync_flush;
ex3_ig_flush <= I1_G1_flush;
ex4_l2cmdq_flush_d <= I1_G1_flush & flush_if_store & sync_flush & ld_queue_full & ld_q_seq_wrap;
latch_ex4_l2cmdq_flush : tri_rlmreg_p
  generic map (width => ex4_l2cmdq_flush_l2'length, init => 0, expand_type => expand_type)
  port map (nclk    => nclk,
            act     => ldq_act,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(ex4_l2cmdq_flush_offset to ex4_l2cmdq_flush_offset + ex4_l2cmdq_flush_l2'length-1),
            scout   => sov(ex4_l2cmdq_flush_offset to ex4_l2cmdq_flush_offset + ex4_l2cmdq_flush_l2'length-1),
            din     => ex4_l2cmdq_flush_d,
            dout    => ex4_l2cmdq_flush_l2 );


-- ***************************************************************************************************
-- Reload outputs
ldq_rel_op_size(0 to 5) <= rel_size_l2(0 to 5);
ldq_rel_thrd_id(0 to 3) <= rel_th_id_l2(0 to 3);
ldq_rel_ci              <= rel_cache_inh_l2;



my_beat1_p:  process (l_m_rel_hit_beat0_l2, l_m_rel_hit_beat1_l2, rel_tag_l2, rel_data_val)
   variable b: std_ulogic;
   variable c: std_ulogic;
begin
      b := '0';
      c := '0';
      for i in 0 to lmq_entries-1 loop
         b := (l_m_rel_hit_beat1_l2(i) and (rel_tag_l2(1 to 4) = tconv(i, 4)) ) or b;
         c := (l_m_rel_hit_beat0_l2(i) and rel_data_val(i)) or c;
      end loop;
      my_beat1 <= b;
      my_beat1_early <= c;
end process;



my_beat_mid_p:  process (l_m_rel_hit_beat3_l2, l_m_rel_hit_beat5_l2, rel_tag_l2, my_xucr0_cls)
   variable b: std_ulogic;
begin
      b := '0';
      for i in 0 to lmq_entries-1 loop
         b := ((l_m_rel_hit_beat3_l2(i) or l_m_rel_hit_beat5_l2(i)) and
                  (rel_tag_l2(1 to 4) = tconv(i, 4)) and my_xucr0_cls ) or b;
      end loop;
      my_beat_mid <= b;
end process;

my_beat_last_p:  process (l_m_rel_hit_beat2_l2, l_m_rel_hit_beat6_l2, rel_data_val,  my_xucr0_cls, rel_tag_l2, ldq_retry_l2)
   variable b: std_ulogic;
   variable c: std_ulogic;
begin
      b := '0';
      c := '0';
      for i in 0 to lmq_entries-1 loop
         b := (((l_m_rel_hit_beat2_l2(i) and rel_data_val(i) and not my_xucr0_cls) or (l_m_rel_hit_beat6_l2(i) and rel_data_val(i) and my_xucr0_cls))  ) or b;
         c := (ldq_retry_l2(i) and (rel_tag_l2(1 to 4) = tconv(i, 4))) or c;
      end loop;
      my_beat_last_d <= b;
      my_ldq_retry <= c;
end process;

latch_my_beat_last : tri_rlmreg_p
  generic map (width => 1, init => 0, expand_type => expand_type)
  port map (nclk    => nclk,
            act     => ldq_act,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(my_beat_last_offset to my_beat_last_offset),
            scout   => sov(my_beat_last_offset to my_beat_last_offset),
            din(0)  => my_beat_last_d,
            dout(0) => my_beat_last_l2 );

my_beat_odd_p:  process (l_m_rel_hit_beat1_l2, l_m_rel_hit_beat3_l2, l_m_rel_hit_beat5_l2, l_m_rel_hit_beat7_l2, rel_tag_l2)
   variable b: std_ulogic;
begin
      b := '0';
      for i in 0 to lmq_entries-1 loop
         b := ((l_m_rel_hit_beat1_l2(i) or l_m_rel_hit_beat3_l2(i) or l_m_rel_hit_beat5_l2(i) or l_m_rel_hit_beat7_l2(i)) and
               (rel_tag_l2(1 to 4) = tconv(i, 4)) ) or b;
      end loop;
      my_beat_odd <= b;
end process;

ldq_rel1_val_buf <= reld_data_vld_l2 and not rel_cache_inh_l2 and not rel_l2only_l2 and
                not rel_tag_l2(1) and my_beat1;
ldq_rel1_val <= ldq_rel1_val_buf;

ldq_rel1_early_v <= my_beat1_early;

ldq_rel_mid_val_buf <= reld_data_vld_l2 and not rel_cache_inh_l2 and not rel_l2only_l2 and
                not rel_tag_l2(1) and my_beat_mid;
ldq_rel_mid_val <= ldq_rel_mid_val_buf;

ldq_rel3_val_buf <= reld_data_vld_l2 and not rel_cache_inh_l2 and not rel_l2only_l2 and
                not rel_tag_l2(1) and my_beat_last_l2;
ldq_rel3_val <= ldq_rel3_val_buf;

ldq_rel3_early_v <= my_beat_last_d;

l2only_from_queue_p:  process (l_m_queue(0)(48), l_m_queue(1)(48), l_m_queue(2)(48), l_m_queue(3)(48), l_m_queue(4)(48), l_m_queue(5)(48), l_m_queue(6)(48), l_m_queue(7)(48), rel_tag_l2)
   variable b: std_ulogic;
begin
      b := '0';
      for i in 0 to lmq_entries-1 loop
         b := (l_m_queue(i)(48) and (rel_tag_l2(1 to 4) = tconv(i, 4)) ) or b;
      end loop;
      l2only_from_queue <= b;
end process;
 
l1dump_cslc <= reld_data_vld_l2 and not rel_cache_inh_l2 and not rel_tag_l2(1) and my_beat_last_l2 and
               l1_dump and rel_lock_en_l2 and not l2only_from_queue;

ldq_rel3_l1dump_val <= reld_data_vld_l2 and not rel_cache_inh_l2 and not rel_tag_l2(1) and my_beat_last_l2 and l1_dump;



ldq_rel_data_val_buf <= reld_data_vld_l2 and not rel_cache_inh_l2 and not (rel_l2only_l2 and not (l1_dump and rel_intf_v_l2)) and
                    my_beat_odd and not my_ldq_retry;
ldq_rel_data_val <= ldq_rel_data_val_buf;

ldq_rel_data_val_early <= data_val_dminus1_l2;

ldq_rel_retry_val_buf <= ldq_rel_retry_val_dly_l2 and not rel_cache_inh_l2 and not rel_l2only_l2 and
                     not rel_tag_l2(1) and my_beat_last_l2;
ldq_rel_retry_val <= ldq_rel_retry_val_buf;



ldq_rel_ta_gpr(0 to 8) <= rel_tar_gpr_l2(0 to 8);

ex3_loadmiss_qentry(0 to lmq_entries-1) <= l_q_wrt_en(0 to lmq_entries-1);
ex3_loadmiss_target(0 to 8) <= ex3_new_target_gpr(0 to 8);
ex3_loadmiss_target_type(0 to 1) <= "01"  when (ld_m_val and ex3_axu_op_val) = '1' else
                                    "10"  when ld_m_val = '1'                      else
                                    "00";
ex3_loadmiss_tid(0 to 3) <= gate_and(ld_m_val, ex3_thrd_id(0 to 3));


latch_loadmiss_qentry : tri_rlmreg_p
  generic map (width => ex4_loadmiss_qentry'length, init => 0, expand_type => expand_type)
  port map (nclk    => nclk,
            act     => ldq_act,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(loadmiss_qentry_offset to loadmiss_qentry_offset + ex4_loadmiss_qentry'length-1),
            scout   => sov(loadmiss_qentry_offset to loadmiss_qentry_offset + ex4_loadmiss_qentry'length-1),
            din     => ex3_loadmiss_qentry(0 to lmq_entries-1),
            dout    => ex4_loadmiss_qentry(0 to lmq_entries-1) );

cmp_ex4_loadmiss_qentry <= ex4_loadmiss_qentry;
xu_iu_ex4_loadmiss_qentry(0 to lmq_entries-1) <= gate_and(not ex4_drop_ld_req, ex4_loadmiss_qentry(0 to lmq_entries-1));  

ex5_loadmiss_qentry_d <= ex4_loadmiss_qentry  when pe_recov_stall='0' else
                         ex5_loadmiss_qentry;

latch_ex5_loadmiss_qentry : tri_rlmreg_p
  generic map (width => ex5_loadmiss_qentry'length, init => 0, expand_type => expand_type)
  port map (nclk    => nclk,
            act     => ldq_act,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(ex5_loadmiss_qentry_offset to ex5_loadmiss_qentry_offset + ex5_loadmiss_qentry'length-1),
            scout   => sov(ex5_loadmiss_qentry_offset to ex5_loadmiss_qentry_offset + ex5_loadmiss_qentry'length-1),
            din     => ex5_loadmiss_qentry_d(0 to lmq_entries-1),
            dout    => ex5_loadmiss_qentry(0 to lmq_entries-1) );

xu_iu_ex5_loadmiss_qentry(0 to lmq_entries-1) <= ex5_loadmiss_qentry(0 to lmq_entries-1);  

ex6_loadmiss_qentry_d <= ex5_loadmiss_qentry  when pe_recov_stall='0' else
                         ex6_loadmiss_qentry;

latch_ex6_loadmiss_qentry : tri_rlmreg_p
  generic map (width => ex6_loadmiss_qentry'length, init => 0, expand_type => expand_type)
  port map (nclk    => nclk,
            act     => ldq_act,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(ex6_loadmiss_qentry_offset to ex6_loadmiss_qentry_offset + ex6_loadmiss_qentry'length-1),
            scout   => sov(ex6_loadmiss_qentry_offset to ex6_loadmiss_qentry_offset + ex6_loadmiss_qentry'length-1),
            din     => ex6_loadmiss_qentry_d(0 to lmq_entries-1),
            dout    => ex6_loadmiss_qentry(0 to lmq_entries-1) );

ex7_loadmiss_qentry_d <= "10000000"           when (ex6_loadmiss_qentry="00000000") and (pe_recov_stall='0') else
                         ex6_loadmiss_qentry  when pe_recov_stall='0' else
                         ex7_loadmiss_qentry;

latch_ex7_loadmiss_qentry : tri_rlmreg_p
  generic map (width => ex7_loadmiss_qentry'length, init => 0, expand_type => expand_type)
  port map (nclk    => nclk,
            act     => ldq_act,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(ex7_loadmiss_qentry_offset to ex7_loadmiss_qentry_offset + ex7_loadmiss_qentry'length-1),
            scout   => sov(ex7_loadmiss_qentry_offset to ex7_loadmiss_qentry_offset + ex7_loadmiss_qentry'length-1),
            din     => ex7_loadmiss_qentry_d(0 to lmq_entries-1),
            dout    => ex7_loadmiss_qentry(0 to lmq_entries-1) );

latch_ex4_loadmiss_target : tri_rlmreg_p
  generic map (width => ex4_loadmiss_target'length, init => 0, expand_type => expand_type)
  port map (nclk    => nclk,
            act     => ldq_act,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(ex4_loadmiss_target_offset to ex4_loadmiss_target_offset + ex4_loadmiss_target'length-1),
            scout   => sov(ex4_loadmiss_target_offset to ex4_loadmiss_target_offset + ex4_loadmiss_target'length-1),
            din     => ex3_loadmiss_target(0 to 8),
            dout    => ex4_loadmiss_target(0 to 8) );

xu_iu_ex4_loadmiss_target(0 to 8) <= ex4_loadmiss_target(0 to 8);  

latch_loadmiss_target : tri_rlmreg_p
  generic map (width => xu_iu_ex5_loadmiss_target'length, init => 0, expand_type => expand_type)
  port map (nclk    => nclk,
            act     => ldq_act,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(loadmiss_target_offset to loadmiss_target_offset + xu_iu_ex5_loadmiss_target'length-1),
            scout   => sov(loadmiss_target_offset to loadmiss_target_offset + xu_iu_ex5_loadmiss_target'length-1),
            din     => ex4_loadmiss_target(0 to 8),
            dout    => xu_iu_ex5_loadmiss_target(0 to 8) );

latch_ex4_loadmiss_target_type : tri_rlmreg_p
  generic map (width => ex4_loadmiss_target_type'length, init => 0, expand_type => expand_type)
  port map (nclk    => nclk,
            act     => ldq_act,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(ex4_loadmiss_target_type_offset to ex4_loadmiss_target_type_offset + ex4_loadmiss_target_type'length-1),
            scout   => sov(ex4_loadmiss_target_type_offset to ex4_loadmiss_target_type_offset + ex4_loadmiss_target_type'length-1),
            din     => ex3_loadmiss_target_type(0 to 1),
            dout    => ex4_loadmiss_target_type(0 to 1) );

xu_iu_ex4_loadmiss_target_type(0 to 1) <= ex4_loadmiss_target_type(0 to 1);  

latch_loadmiss_target_type : tri_rlmreg_p
  generic map (width => xu_iu_ex5_loadmiss_target_type'length, init => 0, expand_type => expand_type)
  port map (nclk    => nclk,
            act     => ldq_act,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(loadmiss_target_type_offset to loadmiss_target_type_offset + xu_iu_ex5_loadmiss_target_type'length-1),
            scout   => sov(loadmiss_target_type_offset to loadmiss_target_type_offset + xu_iu_ex5_loadmiss_target_type'length-1),
            din     => ex4_loadmiss_target_type(0 to 1),
            dout    => xu_iu_ex5_loadmiss_target_type(0 to 1) );

latch_ex4_loadmiss_tid : tri_rlmreg_p
  generic map (width => ex4_loadmiss_tid'length, init => 0, expand_type => expand_type)
  port map (nclk    => nclk,
            act     => ldq_act,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(ex4_loadmiss_tid_offset to ex4_loadmiss_tid_offset + ex4_loadmiss_tid'length-1),
            scout   => sov(ex4_loadmiss_tid_offset to ex4_loadmiss_tid_offset + ex4_loadmiss_tid'length-1),
            din     => ex3_loadmiss_tid(0 to 3),
            dout    => ex4_loadmiss_tid(0 to 3) );


xu_iu_ex4_loadmiss_tid(0 to 3) <= gate_and(not ex4_drop_ld_req, ex4_loadmiss_tid(0 to 3));             

ex4_loadmiss_tid_gated1(0 to 3) <= gate_and(not ex4_flush_load, ex4_loadmiss_tid(0 to 3));
ex4_loadmiss_tid_gated(0 to 3) <= gate_and(not ex4_stg_flush, ex4_loadmiss_tid_gated1(0 to 3));

latch_loadmiss_tid : tri_rlmreg_p
  generic map (width => xu_iu_ex5_loadmiss_tid'length, init => 0, expand_type => expand_type)
  port map (nclk    => nclk,
            act     => ldq_act,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(loadmiss_tid_offset to loadmiss_tid_offset + xu_iu_ex5_loadmiss_tid'length-1),
            scout   => sov(loadmiss_tid_offset to loadmiss_tid_offset + xu_iu_ex5_loadmiss_tid'length-1),
            din     => ex4_loadmiss_tid_gated(0 to 3),
            dout    => ex5_loadmiss_tid(0 to 3) );

xu_iu_ex5_loadmiss_tid(0 to 3) <= ex5_loadmiss_tid(0 to 3);

-- ****************************************************************************************************
-- Signal command completion to the IU
-- ****************************************************************************************************




complete_q:  for i in 0 to lmq_entries-1 generate begin
   ecc_err(i) <= beat_ecc_err or data_ecc_err_l2(i);


   ci_16B_comp_qentry(i) <= data_val_for_rel and (anaclat_tag(1 to 4) = tconv(i, 4)) and l_m_queue(i)(0) and not l_m_queue(i)(7) and not gpr_ecc_err_l2(i);

   even_beat(i) <= l_m_rel_hit_beat0_l2(i) or l_m_rel_hit_beat2_l2(i) or l_m_rel_c_i_beat0_l2(i) or
                   l_m_rel_hit_beat4_l2(i) or l_m_rel_hit_beat6_l2(i);

   ldm_complete_qentry(i) <= (data_val_dminus1_l2 and (tag_dminus1_l2(1 to 4) = tconv(i, 4))) and
                             not even_beat(i) and 
                             (l_m_queue_addrlo(i)(58) = qw_dminus1_l2(58)) and 
                             ((l_m_queue_addrlo(i)(57) = qw_dminus1_l2(57)) or not my_xucr0_cls) and 
                             not gpr_updated_prev_l2(i) and not gpr_ecc_err_l2(i) and
                             not (l_m_queue(i)(0) and not l_m_queue(i)(7));                             -- not 16B I=1 ld


   larx_done(i) <= (l_m_queue(i)(1 to 4) = "0010") and l_m_queue(i)(6) and                    -- Q entry is for larx
                   ld_m_rel_done_no_retry(i) and not ecc_err(i);


   complete_qentry(i) <= (ldm_complete_qentry(i) and     my_xucr0_rel) or         -- L2 reload in back 2 back mode
                         (ldm_comp_qentry_l2(i)  and not my_xucr0_rel) or         -- L2 reload in gap mode
                         ci_16B_comp_qentry(i);

end generate;


latch_ldm_comp_qentry : tri_rlmreg_p
  generic map (width => ldm_comp_qentry_l2'length, init => 0, expand_type => expand_type)
  port map (nclk    => nclk,
            act     => ldq_act,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(ldm_comp_qentry_offset to ldm_comp_qentry_offset + ldm_comp_qentry_l2'length-1),
            scout   => sov(ldm_comp_qentry_offset to ldm_comp_qentry_offset + ldm_comp_qentry_l2'length-1),
            din     => ldm_complete_qentry(0 to lmq_entries-1),
            dout    => ldm_comp_qentry_l2(0 to lmq_entries-1) );


compl_tid_q4: if lmq_entries=4 generate begin
    complete_tid_d(0 to 3) <= gate_and(complete_qentry(0), rel_entry(0)(12 to 15)) or
                              gate_and(complete_qentry(1), rel_entry(1)(12 to 15)) or
                              gate_and(complete_qentry(2), rel_entry(2)(12 to 15)) or
                              gate_and(complete_qentry(3), rel_entry(3)(12 to 15));

    larx_done_tid_d(0 to 3) <= gate_and(larx_done(0), rel_entry(0)(12 to 15)) or
                               gate_and(larx_done(1), rel_entry(1)(12 to 15)) or
                               gate_and(larx_done(2), rel_entry(2)(12 to 15)) or
                               gate_and(larx_done(3), rel_entry(3)(12 to 15));

   rel_vpr_compl <= (complete_qentry(0) and  rel_entry(0)(25)) or
                    (complete_qentry(1) and  rel_entry(1)(25)) or
                    (complete_qentry(2) and  rel_entry(2)(25)) or
                    (complete_qentry(3) and  rel_entry(3)(25));

   rel_compl <= complete_qentry(0) or complete_qentry(1) or complete_qentry(2) or complete_qentry(3);

end generate;

compl_tid_q8: if lmq_entries=8 generate begin
    complete_tid_d(0 to 3) <= gate_and(complete_qentry(0), rel_entry(0)(12 to 15)) or
                              gate_and(complete_qentry(1), rel_entry(1)(12 to 15)) or
                              gate_and(complete_qentry(2), rel_entry(2)(12 to 15)) or
                              gate_and(complete_qentry(3), rel_entry(3)(12 to 15)) or
                              gate_and(complete_qentry(4), rel_entry(4)(12 to 15)) or
                              gate_and(complete_qentry(5), rel_entry(5)(12 to 15)) or
                              gate_and(complete_qentry(6), rel_entry(6)(12 to 15)) or
                              gate_and(complete_qentry(7), rel_entry(7)(12 to 15));

    larx_done_tid_d(0 to 3) <= gate_and(larx_done(0), rel_entry(0)(12 to 15)) or
                               gate_and(larx_done(1), rel_entry(1)(12 to 15)) or
                               gate_and(larx_done(2), rel_entry(2)(12 to 15)) or
                               gate_and(larx_done(3), rel_entry(3)(12 to 15)) or
                               gate_and(larx_done(4), rel_entry(4)(12 to 15)) or
                               gate_and(larx_done(5), rel_entry(5)(12 to 15)) or
                               gate_and(larx_done(6), rel_entry(6)(12 to 15)) or
                               gate_and(larx_done(7), rel_entry(7)(12 to 15));

   rel_vpr_compl <= (complete_qentry(0) and  rel_entry(0)(25)) or
                    (complete_qentry(1) and  rel_entry(1)(25)) or
                    (complete_qentry(2) and  rel_entry(2)(25)) or
                    (complete_qentry(3) and  rel_entry(3)(25)) or
                    (complete_qentry(4) and  rel_entry(4)(25)) or
                    (complete_qentry(5) and  rel_entry(5)(25)) or
                    (complete_qentry(6) and  rel_entry(6)(25)) or
                    (complete_qentry(7) and  rel_entry(7)(25));

   rel_compl <= complete_qentry(0) or complete_qentry(1) or complete_qentry(2) or complete_qentry(3) or
                complete_qentry(4) or complete_qentry(5) or complete_qentry(6) or complete_qentry(7);

end generate;

complete_target_type_d(0 to 1) <= "01" when rel_vpr_compl = '1'    else
                                  "10" when rel_compl = '1'        else
                                  "00";

latch_complete_qentry : tri_rlmreg_p
  generic map (width => xu_iu_complete_qentry'length, init => 0, expand_type => expand_type)
  port map (nclk    => nclk,
            act     => ldq_act,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(complete_qentry_offset to complete_qentry_offset + xu_iu_complete_qentry'length-1),
            scout   => sov(complete_qentry_offset to complete_qentry_offset + xu_iu_complete_qentry'length-1),
            din     => complete_qentry(0 to lmq_entries-1),
            dout    => xu_iu_complete_qentry(0 to lmq_entries-1) );

latch_complete_tid : tri_rlmreg_p
  generic map (width => xu_iu_complete_tid'length, init => 0, expand_type => expand_type)
  port map (nclk    => nclk,
            act     => ldq_act,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(complete_tid_offset to complete_tid_offset + xu_iu_complete_tid'length-1),
            scout   => sov(complete_tid_offset to complete_tid_offset + xu_iu_complete_tid'length-1),
            din     => complete_tid_d(0 to 3),
            dout    => xu_iu_complete_tid(0 to 3) );

latch_complete_target_type : tri_rlmreg_p
  generic map (width => xu_iu_complete_target_type'length, init => 0, expand_type => expand_type)
  port map (nclk    => nclk,
            act     => ldq_act,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(complete_target_type_offset to complete_target_type_offset + xu_iu_complete_target_type'length-1),
            scout   => sov(complete_target_type_offset to complete_target_type_offset + xu_iu_complete_target_type'length-1),
            din     => complete_target_type_d(0 to 1),
            dout    => xu_iu_complete_target_type(0 to 1) );

latch_larx_done_tid : tri_rlmreg_p
  generic map (width => xu_iu_larx_done_tid'length, init => 0, expand_type => expand_type)
  port map (nclk    => nclk,
            act     => ldq_act,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(larx_done_tid_offset to larx_done_tid_offset + xu_iu_larx_done_tid'length-1),
            scout   => sov(larx_done_tid_offset to larx_done_tid_offset + xu_iu_larx_done_tid'length-1),
            din     => larx_done_tid_d(0 to 3),
            dout    => larx_done_tid_l2(0 to 3) );

xu_iu_larx_done_tid <= larx_done_tid_l2;

-- ****************************************************************************************************
-- Reload interface to the L1 D-Cache
-- ****************************************************************************************************



ldq_rel_addr_early(64-real_data_add to 57) <= rel_addr_d(64-real_data_add to 57);

ldq_rel_addr(64-real_data_add to 57) <= rel_addr_l2(64-real_data_add to 57);                              
ldq_rel_addr(58) <= qw_l2(58);


ldq_rel_tag_early(2 to 4) <= tag_dminus1_cpy_l2(2 to 4);
ldq_rel_tag(2 to 4) <= rel_tag_l2(2 to 4);

ldq_rel_axu_val <= rel_vpr_val_l2;


my_noncache_beat_p:  process (l_m_rel_val_c_i_dly, rel_tag_l2)
   variable b: std_ulogic;
begin
      b := '0';
      for i in 0 to lmq_entries-1 loop
         b := (l_m_rel_val_c_i_dly(i)  and (rel_tag_l2(1 to 4) = tconv(i, 4)) )  or b;
      end loop;
      my_noncache_beat <= b;
end process;

update_gpr <= not rel_dcbt_l2 and (rel_addr_l2(58) = qw_l2(58)) and reld_data_vld_l2 and not ldq_rel_retry_val_dly_l2 and not rel_tag_l2(1) and
              (my_beat1 or my_beat_last_l2 or my_beat_mid or my_noncache_beat) and
              ((rel_addr_l2(57) = qw_l2(57)) or not my_xucr0_cls);

-- latch update_gpr into the next cycle so that ecc error can be checked
latch_update_gpr : tri_rlmreg_p
  generic map (width => 1, init => 0, expand_type => expand_type)
  port map (nclk    => nclk,
            act     => ldq_act,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(update_gpr_offset to update_gpr_offset),
            scout   => sov(update_gpr_offset to update_gpr_offset),
            din(0)  => update_gpr,
            dout(0) => update_gpr_l2 );
latch_rel_beat_crit_qw : tri_rlmreg_p
  generic map (width => 1, init => 0, expand_type => expand_type)
  port map (nclk    => nclk,
            act     => ldq_act,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(rel_beat_crit_qw_offset to rel_beat_crit_qw_offset),
            scout   => sov(rel_beat_crit_qw_offset to rel_beat_crit_qw_offset),
            din(0)  => update_gpr,
            dout(0) => ldq_rel_beat_crit_qw );

gpr_updated:  for i in 0 to lmq_entries-1 generate begin
   set_gpr_updated_prev(i) <= update_gpr_l2 and not ecc_err(i) and
                              (rel_tag_dplus1_l2(1 to 4) = tconv(i, 4)) and
                              not (ld_m_rel_done_l2(i) and not rel_done_ecc_err);    -- don't set if in last cycle of data xfer
                                                                                     -- and no previous ecc errors

   gpr_updated_prev_d(i) <= set_gpr_updated_prev(i) or
                            (gpr_updated_prev_l2(i) and not reset_lmq_entry(i) );

   gpr_updated_dly1_d(i) <= gpr_updated_prev_l2(i) and not reset_lmq_entry(i);

   gpr_updated_dly2_d(i) <= gpr_updated_dly1_l2(i) and not reset_lmq_entry(i);


   set_gpr_ecc_err(i) <= update_gpr_l2 and ecc_err(i) and
                         (rel_tag_dplus1_l2(1 to 4) = tconv(i, 4));

   reset_gpr_ecc_err(i) <= update_gpr_l2 and (not ecc_err(i) or ld_m_rel_done_dly2_l2(i)) and
                           (rel_tag_dplus1_l2(1 to 4) = tconv(i, 4));

   gpr_ecc_err_d(i) <= (set_gpr_ecc_err(i) and not reset_gpr_ecc_err(i)) or
                       (not reset_gpr_ecc_err(i) and gpr_ecc_err_l2(i));

end generate;

-- set a latch to remember that the gpr has been updated previously
latch_gpr_updated_prev : tri_rlmreg_p
  generic map (width => gpr_updated_prev_l2'length, init => 0, expand_type => expand_type)
  port map (nclk    => nclk,
            act     => ldq_act,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(gpr_updated_prev_offset to gpr_updated_prev_offset + gpr_updated_prev_l2'length-1),
            scout   => sov(gpr_updated_prev_offset to gpr_updated_prev_offset + gpr_updated_prev_l2'length-1),
            din     => gpr_updated_prev_d(0 to lmq_entries-1),
            dout    => gpr_updated_prev_l2(0 to lmq_entries-1) );

latch_gpr_updated_dly1 : tri_rlmreg_p
  generic map (width => gpr_updated_dly1_l2'length, init => 0, expand_type => expand_type)
  port map (nclk    => nclk,
            act     => ldq_act,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(gpr_updated_dly1_offset to gpr_updated_dly1_offset + gpr_updated_dly1_l2'length-1),
            scout   => sov(gpr_updated_dly1_offset to gpr_updated_dly1_offset + gpr_updated_dly1_l2'length-1),
            din     => gpr_updated_dly1_d(0 to lmq_entries-1),
            dout    => gpr_updated_dly1_l2(0 to lmq_entries-1) );

latch_gpr_updated_dly2 : tri_rlmreg_p
  generic map (width => gpr_updated_dly2_l2'length, init => 0, expand_type => expand_type)
  port map (nclk    => nclk,
            act     => ldq_act,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(gpr_updated_dly2_offset to gpr_updated_dly2_offset + gpr_updated_dly2_l2'length-1),
            scout   => sov(gpr_updated_dly2_offset to gpr_updated_dly2_offset + gpr_updated_dly2_l2'length-1),
            din     => gpr_updated_dly2_d(0 to lmq_entries-1),
            dout    => gpr_updated_dly2_l2(0 to lmq_entries-1) );

latch_gpr_ecc_err : tri_rlmreg_p
  generic map (width => gpr_ecc_err_l2'length, init => 0, expand_type => expand_type)
  port map (nclk    => nclk,
            act     => ldq_act,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(gpr_ecc_err_offset to gpr_ecc_err_offset + gpr_ecc_err_l2'length-1),
            scout   => sov(gpr_ecc_err_offset to gpr_ecc_err_offset + gpr_ecc_err_l2'length-1),
            din     => gpr_ecc_err_d(0 to lmq_entries-1),
            dout    => gpr_ecc_err_l2(0 to lmq_entries-1) );


sel_gpr_upd_q4: if lmq_entries=4 generate begin
   selectedQ_gpr_update_prev <= (gpr_updated_prev_l2(0) and (rel_tag_dplus1_l2(1 to 4) = "0000")) or
                                (gpr_updated_prev_l2(1) and (rel_tag_dplus1_l2(1 to 4) = "0001")) or 
                                (gpr_updated_prev_l2(2) and (rel_tag_dplus1_l2(1 to 4) = "0010")) or 
                                (gpr_updated_prev_l2(3) and (rel_tag_dplus1_l2(1 to 4) = "0011"));

   selectedQ_ecc_err         <= (data_ecc_err_l2(0) and not ld_m_rel_done_dly2_l2(0) and (rel_tag_dplus1_l2(1 to 4) = "0000")) or
                                (data_ecc_err_l2(1) and not ld_m_rel_done_dly2_l2(1) and (rel_tag_dplus1_l2(1 to 4) = "0001")) or 
                                (data_ecc_err_l2(2) and not ld_m_rel_done_dly2_l2(2) and (rel_tag_dplus1_l2(1 to 4) = "0010")) or 
                                (data_ecc_err_l2(3) and not ld_m_rel_done_dly2_l2(3)  and (rel_tag_dplus1_l2(1 to 4) = "0011"));
end generate;

sel_gpr_upd_q8: if lmq_entries=8 generate begin
   selectedQ_gpr_update_prev <= (gpr_updated_prev_l2(0) and (rel_tag_dplus1_l2(1 to 4) = "0000")) or
                                (gpr_updated_prev_l2(1) and (rel_tag_dplus1_l2(1 to 4) = "0001")) or 
                                (gpr_updated_prev_l2(2) and (rel_tag_dplus1_l2(1 to 4) = "0010")) or 
                                (gpr_updated_prev_l2(3) and (rel_tag_dplus1_l2(1 to 4) = "0011")) or 
                                (gpr_updated_prev_l2(4) and (rel_tag_dplus1_l2(1 to 4) = "0100")) or 
                                (gpr_updated_prev_l2(5) and (rel_tag_dplus1_l2(1 to 4) = "0101")) or 
                                (gpr_updated_prev_l2(6) and (rel_tag_dplus1_l2(1 to 4) = "0110")) or 
                                (gpr_updated_prev_l2(7) and (rel_tag_dplus1_l2(1 to 4) = "0111"));

   selectedQ_ecc_err         <= (data_ecc_err_l2(0) and not ld_m_rel_done_dly2_l2(0) and (rel_tag_dplus1_l2(1 to 4) = "0000")) or
                                (data_ecc_err_l2(1) and not ld_m_rel_done_dly2_l2(1) and (rel_tag_dplus1_l2(1 to 4) = "0001")) or 
                                (data_ecc_err_l2(2) and not ld_m_rel_done_dly2_l2(2) and (rel_tag_dplus1_l2(1 to 4) = "0010")) or 
                                (data_ecc_err_l2(3) and not ld_m_rel_done_dly2_l2(3) and (rel_tag_dplus1_l2(1 to 4) = "0011")) or
                                (data_ecc_err_l2(4) and not ld_m_rel_done_dly2_l2(4) and (rel_tag_dplus1_l2(1 to 4) = "0100")) or
                                (data_ecc_err_l2(5) and not ld_m_rel_done_dly2_l2(5) and (rel_tag_dplus1_l2(1 to 4) = "0101")) or 
                                (data_ecc_err_l2(6) and not ld_m_rel_done_dly2_l2(6) and (rel_tag_dplus1_l2(1 to 4) = "0110")) or 
                                (data_ecc_err_l2(7) and not ld_m_rel_done_dly2_l2(7) and (rel_tag_dplus1_l2(1 to 4) = "0111"));
end generate;

ldq_rel_upd_gpr_buf <= update_gpr_l2 and not beat_ecc_err and 
                   not selectedQ_ecc_err and 
                   not selectedQ_gpr_update_prev;
ldq_rel_upd_gpr <= ldq_rel_upd_gpr_buf;

ldq_rel_ecc_err <= beat_ecc_err or rel_done_ecc_err;

rel_beat_crit_qw_block_d <= beat_ecc_err or selectedQ_ecc_err or selectedQ_gpr_update_prev;
latch_rel_beat_crit_qw_block : tri_rlmreg_p
  generic map (width => 1, init => 0, expand_type => expand_type)
  port map (nclk    => nclk,
            act     => ldq_act,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(rel_beat_crit_qw_block_offset to rel_beat_crit_qw_block_offset),
            scout   => sov(rel_beat_crit_qw_block_offset to rel_beat_crit_qw_block_offset),
            din(0)  => rel_beat_crit_qw_block_d,
            dout(0) => ldq_rel_beat_crit_qw_block );

flush_gpr_ecc_err: process(gpr_ecc_err_l2, l_m_queue(0)(18 to 21), l_m_queue(1)(18 to 21), l_m_queue(2)(18 to 21), l_m_queue(3)(18 to 21), l_m_queue(4)(18 to 21), l_m_queue(5)(18 to 21), l_m_queue(6)(18 to 21), l_m_queue(7)(18 to 21))
   variable b: std_ulogic_vector(0 to 3);
begin
      b := "0000";
      for i in 0 to lmq_entries-1 loop
         b := gate_and(gpr_ecc_err_l2(i), l_m_queue(i)(18 to 21)) or b;
     end loop;
      gpr_ecc_err_flush_tid(0 to 3) <= b;
end process;




rel_cacheable_p:  for i in 0 to lmq_entries-1 generate begin
   rel_cacheable(i) <= not rel_entry(i)(0) and not rel_entry(i)(29) and not lmq_back_invalidated_l2(i);

   rel_set_val(i) <= ld_m_rel_done_l2(i) and                                           -- reload is done
                     not data_ecc_err_l2(i) and not data_ecc_ue_l2(i) and         -- no previous ecc errors
                     rel_cacheable(i);                                            -- entry is for cacheable data
end generate;

rel_set_val_or_p:  process (rel_set_val)
   variable b: std_ulogic;
begin
      b := '0';
      for i in 0 to lmq_entries-1 loop
         b := rel_set_val(i) or b;
      end loop;
      rel_set_val_or <= b;
end process;


ldq_rel_set_val_buf <= rel_set_val_or and                                  -- reload is done
                   not beat_ecc_err and not (anaclat_ecc_err_ue and rel_intf_v_dplus1_l2) and  -- no ecc errors on last transfer
                   not rel_l2only_dly_l2 and not pe_recov_state_l2;

ldq_rel_set_val <= ldq_rel_set_val_buf;

ldq_rel_le_mode <= rel_le_mode_l2;
ldq_rel_rot_sel <= rel_rot_sel_l2;
ldq_rel_algebraic <= rel_algebraic_l2;
ldq_rel_lock_en <= rel_lock_en_l2;
ldq_rel_classid <= rel_classid_l2;
ldq_rel_dvc1_en <= rel_dvc1_l2;
ldq_rel_dvc2_en <= rel_dvc2_l2;
ldq_rel_watch_en <= rel_watch_en_l2;



rel_bi_p:  process (lmq_back_invalidated_l2, rel_tag_l2)
   variable b: std_ulogic;
begin
      b := '0';
      for i in 0 to lmq_entries-1 loop
         b := (lmq_back_invalidated_l2(i) and (rel_tag_l2(1 to 4) = tconv(i, 4)) ) or b;
      end loop;
      ldq_rel_back_invalidated <= b;
end process;






-- *****************************************************************
-- gather 16 byte reload data to give 32 bytes to the L1 D-cache

rel_data_a2mode: if a2mode=1 generate begin 
   set_rel_A_data <= reld_data_vld_l2 and     send_rel_A_data_l2;
   set_rel_B_data <= reld_data_vld_l2 and not send_rel_A_data_l2;

   rel_A_data_d(0 to 127) <= anaclat_data(0 to 127)       when set_rel_A_data = '1'  else
                             rel_A_data_l2(0 to 127);
   
   rel_B_data_d(0 to 127) <= anaclat_data(0 to 127)       when set_rel_B_data = '1'  else
                             rel_B_data_l2(0 to 127);
end generate;

rel_data_nota2mode: if a2mode=0 generate begin
   rel_A_data_d(0 to 127) <= anaclat_data(0 to 127);

   -- tie unused signals
   set_rel_A_data <= '0';
   set_rel_B_data <= '0';
   rel_B_data_d(0 to 127) <= (others=>'0');
   rel_B_data_l2(0 to 127) <= (others=>'0');

end generate;

latch_rel_A_data : tri_rlmreg_p
  generic map (width => rel_A_data_l2'length, init => 0, expand_type => expand_type)
  port map (nclk    => nclk,
            act     => dplus1_act,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(rel_A_data_offset to rel_A_data_offset + rel_A_data_l2'length-1),
            scout   => sov(rel_A_data_offset to rel_A_data_offset + rel_A_data_l2'length-1),
            din     => rel_A_data_d(0 to 127),
            dout    => rel_A_data_l2(0 to 127) );

rel_B_data_a2mode: if a2mode=1 generate begin 
   latch_rel_B_data : tri_rlmreg_p
     generic map (width => rel_B_data_l2'length, init => 0, expand_type => expand_type)
     port map (nclk    => nclk,
               act     => dplus1_act,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
               thold_b => func_sl_thold_0_b,
               sg      => sg_0,
               vd      => vdd,
               gd      => gnd,
               scin    => siv(rel_B_data_offset to rel_B_data_offset + rel_B_data_l2'length-1),
               scout   => sov(rel_B_data_offset to rel_B_data_offset + rel_B_data_l2'length-1),
               din     => rel_B_data_d(0 to 127),
               dout    => rel_B_data_l2(0 to 127) );
end generate;

rel_data_256_a2mode: if a2mode=1 generate begin 
   send_rel_A_data_d <= not send_rel_A_data_l2 or my_xucr0_rel;    -- always use rel_A when in back to back l2 mode
                                                                           -- otherwise toggle between A and B

   latch_send_rel_A_data : tri_rlmreg_p
     generic map (width => 1, init => 0, expand_type => expand_type)
     port map (nclk    => nclk,
               act     => '1',
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
               thold_b => func_sl_thold_0_b,
               sg      => sg_0,
               vd      => vdd,
               gd      => gnd,
               scin    => siv(send_rel_A_data_offset to send_rel_A_data_offset),
               scout   => sov(send_rel_A_data_offset to send_rel_A_data_offset),
               din(0)  => send_rel_A_data_d,
               dout(0) => send_rel_A_data_l2 );

   ldq_rel_256_data(0 to 127) <= anaclat_data(0 to 127)              when qw_l2(59) = '0'           else
                                 rel_A_data_l2(0 to 127)             when send_rel_A_data_l2 = '1'  else 
                                 rel_B_data_l2(0 to 127);
   
   ldq_rel_256_data(128 to 255) <= anaclat_data(0 to 127)            when qw_l2(59) = '1'           else 
                                   rel_A_data_l2(0 to 127)           when send_rel_A_data_l2 = '1'  else 
                                   rel_B_data_l2(0 to 127);
end generate;


rel_data_256_nota2mode: if a2mode=0 generate begin
   send_rel_A_data_d  <= '0';  -- tie unused signals
   send_rel_A_data_l2 <= '0';  -- tie unused signals

   ldq_rel_256_data(0 to 127) <= anaclat_data(0 to 127)              when qw_l2(59) = '0'       else
                                 rel_A_data_l2(0 to 127);
   
   ldq_rel_256_data(128 to 255) <= rel_A_data_l2(0 to 127)           when qw_l2(59) = '0'       else
                                   anaclat_data(0 to 127);
end generate;

-- signal to MMU when the load miss queue is empty

lmq_empty <= ld_rel_val_l2(0 to lmq_entries-1) = (0 to lmq_entries-1 => '0');

xu_mm_lmq_stq_empty_d <= lmq_empty and not st_entry0_val_l2 and not ex4_st_val_l2 and not pe_recov_state_l2;

latch_lmq_stq_empty : tri_rlmreg_p
  generic map (width => 1, init => 0, expand_type => expand_type)
  port map (nclk    => nclk,
            act     => '1',
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(lmq_stq_empty_offset to lmq_stq_empty_offset),
            scout   => sov(lmq_stq_empty_offset to lmq_stq_empty_offset),
            din(0)  => xu_mm_lmq_stq_empty_d,
            dout(0) => xu_mm_lmq_stq_empty );

-- signal when each thread is quiesced

lmq_q:  process(ld_rel_val_l2, l_m_queue(0)(18 to 21), l_m_queue(1)(18 to 21), l_m_queue(2)(18 to 21), l_m_queue(3)(18 to 21), l_m_queue(4)(18 to 21), l_m_queue(5)(18 to 21), l_m_queue(6)(18 to 21), l_m_queue(7)(18 to 21))
   variable b: std_ulogic_vector(0 to 3);
begin
      b := "1111";
      for i in 0 to lmq_entries-1 loop
         b := not (gate_and(ld_rel_val_l2(i), l_m_queue(i)(18 to 21)) ) and b;
     end loop;
      lmq_quiesce(0 to 3) <= b;
end process;

mmu_quiesce(0 to 3) <= not (gate_and(mmu_q_val_l2, mmu_q_entry_l2(2 to 5)) ); 

stq_quiesce(0 to 3) <= not (gate_and(st_entry0_val_l2, s_m_queue0(38 to 41)) ); 

quiesce_d(0 to 3) <= gate_and(not pe_recov_state_l2, stq_quiesce(0 to 3) and lmq_quiesce(0 to 3) and mmu_quiesce(0 to 3));

latch_quiesce : tri_rlmreg_p
  generic map (width => lsu_xu_quiesce'length, init => 0, expand_type => expand_type)
  port map (nclk    => nclk,
            act     => '1',
            forcee => func_slp_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_slp_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(quiesce_offset to quiesce_offset + lsu_xu_quiesce'length-1),
            scout   => sov(quiesce_offset to quiesce_offset + lsu_xu_quiesce'length-1),
            din     => quiesce_d(0 to 3),
            dout    => lsu_xu_quiesce(0 to 3) );

-- send back invalidates to the D-Cache

is2_l2_inv_val <= back_inv_val_l2;

is2_l2_inv_p_addr <= anaclat_back_inv_addr(64-real_data_add to 63-cl_size);


-- ********************************************************************************8
-- send L2 ecc errors to pervasive:


err_l2intrf_ecc_d <= beat_ecc_err and rel_intf_v_dplus1_l2;

err_l2intrf_ue_d <= anaclat_ecc_err_ue and rel_intf_v_dplus1_l2;

latch_err_l2intrf_ecc : tri_rlmreg_p
  generic map (width => 1, init => 0, expand_type => expand_type)
  port map (nclk    => nclk,
            act     => '1',
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(err_l2intrf_ecc_offset to err_l2intrf_ecc_offset),
            scout   => sov(err_l2intrf_ecc_offset to err_l2intrf_ecc_offset),
            din(0)  => err_l2intrf_ecc_d,
            dout(0) => err_l2intrf_ecc_l2 );

latch_err_l2intrf_ue : tri_rlmreg_p
  generic map (width => 1, init => 0, expand_type => expand_type)
  port map (nclk    => nclk,
            act     => '1',
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(err_l2intrf_ue_offset to err_l2intrf_ue_offset),
            scout   => sov(err_l2intrf_ue_offset to err_l2intrf_ue_offset),
            din(0)  => err_l2intrf_ue_d,
            dout(0) => err_l2intrf_ue_l2 );

invld_reld: process(ld_rel_val_l2, tag_dminus1_l2, data_val_dminus1_l2)
   variable b: std_ulogic;
begin
      b := '0';
      for i in 0 to lmq_entries-1 loop
         b :=  (data_val_dminus1_l2 and (tag_dminus1_l2(1 to 4)=tconv(i,4)) and not ld_rel_val_l2(i))  or b;
     end loop;
      err_invld_reld_d <= b;
end process;

latch_err_invld_reld : tri_rlmreg_p
  generic map (width => 1, init => 0, expand_type => expand_type)
  port map (nclk    => nclk,
            act     => '1',
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(err_invld_reld_offset to err_invld_reld_offset),
            scout   => sov(err_invld_reld_offset to err_invld_reld_offset),
            din(0)  => err_invld_reld_d,
            dout(0) => err_invld_reld_l2 );

-- create error signal we get too many load or store credit pops

err_cred_overrun_d <= store_cmd_count_l2(0 to 1)="11" or load_cmd_count_l2(0 to 1)="11";

latch_cred_overrun : tri_rlmreg_p
  generic map (width => 1, init => 0, expand_type => expand_type)
  port map (nclk    => nclk,
            act     => '1',
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(cred_overrun_offset to cred_overrun_offset),
            scout   => sov(cred_overrun_offset to cred_overrun_offset),
            din(0)  => err_cred_overrun_d,
            dout(0) => err_cred_overrun_l2);


err_rpt :  tri_direct_err_rpt
  generic map (width => 4)
  port map (vd      => vdd,
            gd      => gnd,
            err_in(0)  => err_l2intrf_ecc_l2,
            err_in(1)  => err_l2intrf_ue_l2,
            err_in(2)  => err_invld_reld_l2,
            err_in(3)  => err_cred_overrun_l2,
            err_out(0) => xu_pc_err_l2intrf_ecc,
            err_out(1) => xu_pc_err_l2intrf_ue,
            err_out(2) => xu_pc_err_invld_reld,
            err_out(3) => xu_pc_err_l2credit_overrun);


-- *********************************************************************************
-- Repower Latches for BXQ

latch_reld_ditc_pop : tri_rlmreg_p
  generic map (width => ac_an_reld_ditc_pop_q'length, init => 0, expand_type => expand_type)
  port map (nclk    => nclk,
            act     => '1',
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(reld_ditc_pop_offset to reld_ditc_pop_offset + ac_an_reld_ditc_pop_q'length-1),
            scout   => sov(reld_ditc_pop_offset to reld_ditc_pop_offset + ac_an_reld_ditc_pop_q'length-1),
            din     => ac_an_reld_ditc_pop_int(0 to 3),
            dout    => ac_an_reld_ditc_pop_q(0 to 3) );

latch_bx_ib_empty : tri_rlmreg_p
  generic map (width => bx_ib_empty_q'length, init => 0, expand_type => expand_type)
  port map (nclk    => nclk,
            act     => '1',
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(bx_ib_empty_offset to bx_ib_empty_offset + bx_ib_empty_q'length-1),
            scout   => sov(bx_ib_empty_offset to bx_ib_empty_offset + bx_ib_empty_q'length-1),
            din     => bx_ib_empty_int(0 to 3),
            dout    => bx_ib_empty_q(0 to 3) );



-- *********************************************************************************
-- Spare latches

spare_0_lcb: entity tri.tri_lcbnd(tri_lcbnd)
   port map(vd          => vdd,
            gd          => gnd,
            act         => '0',
            nclk        => nclk,
            forcee => func_sl_force,
            thold_b     => func_sl_thold_0_b,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b      => mpw1_dc_b,
            mpw2_b      => mpw2_dc_b,
            sg          => sg_0,
            lclk        => spare_0_lclk,
            d1clk       => spare_0_d1clk,
            d2clk       => spare_0_d2clk);
spare_0_latch : entity tri.tri_inv_nlats(tri_inv_nlats)
  generic map (width => spare_0_l2'length, expand_type => expand_type, btr => "NLI0001_X2_A12TH", init=>(spare_0_l2'range=>'0'))
  port map (vd => vdd, gd => gnd,
            LCLK    => spare_0_lclk,
            D1CLK   => spare_0_d1clk,
            D2CLK   => spare_0_d2clk,
            SCANIN  => siv(spare_0_offset to spare_0_offset + spare_0_l2'length-1),
            SCANOUT => sov(spare_0_offset to spare_0_offset + spare_0_l2'length-1),
            D       => spare_0_d,
            QB      => spare_0_l2);
spare_0_d  <= not spare_0_l2;

spare_1_lcb: entity tri.tri_lcbnd(tri_lcbnd)
   port map(vd          => vdd,
            gd          => gnd,
            act         => '0',
            nclk        => nclk,
            forcee => func_sl_force,
            thold_b     => func_sl_thold_0_b,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b      => mpw1_dc_b,
            mpw2_b      => mpw2_dc_b,
            sg          => sg_0,
            lclk        => spare_1_lclk,
            d1clk       => spare_1_d1clk,
            d2clk       => spare_1_d2clk);
spare_1_latch : entity tri.tri_inv_nlats(tri_inv_nlats)
  generic map (width => spare_1_l2'length, expand_type => expand_type, btr => "NLI0001_X2_A12TH", init=>(spare_1_l2'range=>'0'))
  port map (vd => vdd, gd => gnd,
            LCLK    => spare_1_lclk,
            D1CLK   => spare_1_d1clk,
            D2CLK   => spare_1_d2clk,
            SCANIN  => siv(spare_1_offset to spare_1_offset + spare_1_l2'length-1),
            SCANOUT => sov(spare_1_offset to spare_1_offset + spare_1_l2'length-1),
            D       => spare_1_d,
            QB      => spare_1_l2);
spare_1_d   <= not spare_1_l2;


spare_4_lcb: entity tri.tri_lcbnd(tri_lcbnd)
   port map(vd          => vdd,
            gd          => gnd,
            act         => '0',
            nclk        => nclk,
            forcee => func_sl_force,
            thold_b     => func_sl_thold_0_b,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b      => mpw1_dc_b,
            mpw2_b      => mpw2_dc_b,
            sg          => sg_0,
            lclk        => spare_4_lclk,
            d1clk       => spare_4_d1clk,
            d2clk       => spare_4_d2clk);
spare_4_latch : entity tri.tri_inv_nlats(tri_inv_nlats)
  generic map (width => spare_4_l2'length, expand_type => expand_type, btr => "NLI0001_X2_A12TH", init=>(spare_4_l2'range=>'0'))
  port map (vd => vdd, gd => gnd,
            LCLK    => spare_4_lclk,
            D1CLK   => spare_4_d1clk,
            D2CLK   => spare_4_d2clk,
            SCANIN  => siv(spare_4_offset to spare_4_offset + spare_4_l2'length-1),
            SCANOUT => sov(spare_4_offset to spare_4_offset + spare_4_l2'length-1),
            D       => spare_4_d,
            QB      => spare_4_l2);
spare_4_d   <= not spare_4_l2;



-- *********************************************************************************
-- Debug signals

dbg_d(0 to 7) <= l_q_rd_en;
dbg_d(8 to 11) <= ex4st_hit_ex6_recov &
                  stq_hit_ex6_recov &
                  blk_st_for_pe_recov &
                  blk_st_cred_pop;
dbg_d(12 to 13) <= lq_rd_en_is_ex5 & lq_rd_en_is_ex6;
dbg_d(14) <= selected_entry_flushed;
dbg_d(15 to 26) <= cmd_type_st(0 to 5) & cmd_type_ld(0 to 5);
dbg_d(27) <= load_flushed;
dbg_d(28) <= rd_seq_num_skip;
dbg_d(29) <= nxt_st_cred_tkn;
dbg_d(30) <= cred_pop;
dbg_d(31) <= store_sent;
dbg_d(32) <= ex4_flush_store;
dbg_d(33) <= mmu_st_sent;
dbg_d(34 to 37) <= i_f_q0_sent & i_f_q1_sent & i_f_q2_sent & i_f_q3_sent;
dbg_d(38) <= iu_sent_val;
dbg_d(39) <= mmu_sent;
dbg_d(40 to 40+lmq_entries-1) <= complete_qentry;

latch_dbg : tri_rlmreg_p
  generic map (width => dbg_l2'length, init => 0, expand_type => expand_type)
  port map (nclk    => nclk,
            act     => '1',
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(dbg_offset to dbg_offset + dbg_l2'length-1),
            scout   => sov(dbg_offset to dbg_offset + dbg_l2'length-1),
            din     => dbg_d,
            dout    => dbg_l2 );

lmq_dbg_l2req <= l2req_l2 &                             --(0)
                 l2req_ld_core_tag_l2 &                 --(1:5)
                 l2req_ra_l2 &                          --(6:47)
                 l2req_st_byte_enbl_l2(0 to 15) &       --(48:63)
                 l2req_thread_l2 &                      --(64:66)
                 l2req_ttype_l2 &                       --(67:72)
                 l2req_wimg_l2 &                        --(73:76)
                 l2req_endian_l2 &                      --(77)
                 l2req_user_l2 &                        --(78:81)
                 l2req_ld_xfr_len_l2 &                  --(82:84)
                 ex6_st_data_l2(0 to 127);              --(85:212)

lmq_dbg_rel  <= anaclat_data_coming &           --(0)
                anaclat_data_val &              --(1)
                anaclat_reld_crit_qw &          --(2)
                anaclat_ditc &                  --(3)
                anaclat_l1_dump &               --(4)
                anaclat_tag(1 to 4) &           --(5:8)
                anaclat_qw(58 to 59) &          --(9:10)
                anaclat_ecc_err &               --(11)
                anaclat_ecc_err_ue &            --(12)
                anaclat_data(0 to 127);         --(13:140)

lmq_dbg_binv <= anaclat_back_inv &              --(0)
                anaclat_back_inv_addr &         --(1:42)
                anaclat_back_inv_target_1 &     --(43)
                anaclat_back_inv_target_4;      --(44)

lmq_dbg_pops <= anaclat_ld_pop &                --(0)
                anaclat_st_gather &             --(1)
                anaclat_st_pop &                --(2)
                anaclat_st_pop_thrd;            --(3:5)

lmq_dbg_dcache_pe <= l2req_resend_l2 &                                  -- 1
                     l2req_recycle_l2 &                                 -- 2
                     ex6_ld_recov_val_l2 &                              -- 3
                     ex6_ld_recov_extra_l2(0) &                         -- 4
                     ex7_ld_recov_val_l2 &                              -- 5
                     ex7_ld_recov_extra_l2(0) &                         -- 6
                     ex7_ld_recov_l2(1 to 6) &                          -- 7:12
                     ex7_ld_recov_l2(18 to 21) &                        -- 13:16
                     ex7_ld_recov_l2(53 to (53+(real_data_add-2))) &    -- 17:57
                     st_hit_recov_ld_l2 &                               -- 58
                     pe_recov_state_l2 &                                -- 59
                     blk_ld_for_pe_recov_l2;                            -- 60

lmq_dbg_grp0 <= l_m_rel_hit_beat0_l2 &                              --(0:7)
                l_m_rel_hit_beat1_l2 &                              --(8:15)
                l_m_rel_hit_beat2_l2 &                              --(16:23)
                l_m_rel_hit_beat3_l2 &                              --(24:31)
                l_m_rel_val_c_i_dly &                               --(32:39)
                lmq_back_invalidated_l2(0 to lmq_entries-1) &       --(40:47)
                dbg_l2(40 to 40+lmq_entries-1) &                    --(48:55)
                ldq_retry_l2(0 to lmq_entries-1) &                  --(56:63)
                retry_started_l2(0 to lmq_entries-1) &              --(64:71)
                gpr_ecc_err_l2(0 to lmq_entries-1) &                --(78:85)
                "00";                                               --(86:87)

lmq_dbg_grp1 <= l_m_rel_hit_beat0_l2 &                              --(0:7)
                l_m_rel_hit_beat1_l2 &                              --(8:15)
                l_m_rel_hit_beat2_l2 &                              --(16:23)
                l_m_rel_hit_beat3_l2 &                              --(24:31)
                l_m_rel_val_c_i_dly &                               --(32:39)
                gpr_ecc_err_l2(0 to lmq_entries-1) &                --(40:47)
                data_ecc_err_l2(0 to lmq_entries-1) &               --(48:55)
                data_ecc_ue_l2(0 to lmq_entries-1) &                --(56:63)
                gpr_updated_prev_l2(0 to lmq_entries-1) &           --(64:71)
                anaclat_data_val &                                  --(78)
                anaclat_reld_crit_qw &                              --(79)
                anaclat_tag(1 to 4) &                               --(80:83)
                anaclat_qw(58 to 59) &                              --(84:85)
                anaclat_ecc_err &                                   --(86)
                anaclat_ecc_err_ue;                                 --(87)

lmq_dbg_grp2 <= ex4_l2cmdq_flush_l2(0) &                             --(0)
                ex4_l2cmdq_flush_l2(3) &                             --(1)
                ex4_drop_ld_req &                                   --(2)
                ex5_flush_l2 &                                      --(3)
                ex5_stg_flush &                                     --(4)
                dbg_l2(21 to 26) &                                  --(5:10)
                ex4_loadmiss_qentry(0 to lmq_entries-1) &           --(11:18)
                ld_entry_val_l2(0 to lmq_entries-1) &               --(19:26)
                ld_rel_val_l2(0 to lmq_entries-1) &                 --(27:34)
                ex4_lmq_cpy_l2(0 to lmq_entries-1) &                --(35:42)
                send_if_req_l2 &                                    --(43)
                send_ld_req_l2 &                                    --(44)
                send_mm_req_l2 &                                    --(45)
                load_cmd_count_l2 &                                 --(46:49)
                load_sent_dbglat_l2 &                               --(50)
                dbg_l2(27) &                                        --(51)
                dbg_l2(14) &                                        --(52)
                ex6_load_sent_l2 &                                  --(53)
                ex6_flush_l2 &                                      --(54)
                cmd_seq_l2 &                                        --(55:59)
                dbg_l2(0 to 7) &                                    --(60:67)  l_q_rd_en
                dbg_l2(28) &                                        --(68)
                dbg_l2(12) &                                        --(69)
                dbg_l2(13) &                                        --(70)
                l_m_q_hit_st_l2(0 to lmq_entries-1) &               --(71:78)
                lmq_drop_rel_l2(0 to lmq_entries-1) &               --(79:86)
                ex4_l2cmdq_flush_l2(4);                             --(87)

lmq_dbg_grp3 <= ex4_l2cmdq_flush_l2(2) &                            --(0)
                ex4_l2cmdq_flush_l2(1) &                            --(1)
                ex4_l2cmdq_flush_l2(0) &                            --(2)
                l_m_fnd_stg &                                      --(3)
                ex5_flush_l2 &                                     --(4)
                ex5_stg_flush &                                    --(5)
                ex4_st_val_l2 &                                    --(6)
                st_entry0_val_l2 &                                 --(7)
                s_m_queue0(0 to 5) &                               --(8:13)
                s_m_queue0(58 to (58+real_data_add-6-1)) &         --(14:49)
                store_cmd_count_l2 &                               --(50:55)
                dbg_l2(29) &                                       --(56)
                dbg_l2(30) &                                       --(57)
                ex5_sel_st_req &                                   --(58)
                dbg_l2(31) &                                       --(59)
                dbg_l2(32) &                                       --(60)
                ex5_flush_store &                                  --(61)
                ex6_store_sent_l2 &                                --(62)
                ex6_flush_l2 &                                     --(63)
               	l2req_l2 &                                         --(64)
             	l2req_thread_l2 &                                  --(65:67)
                l2req_ttype_l2 &                                   --(68:73)
                ob_req_val_l2 &                                    --(74)
                ob_ditc_val_l2 &                                   --(75)
                bx_cmd_stall_l2 &                                  --(76)
                bx_cmd_sent_l2 &                                   --(77)
                dbg_l2(8 to 11) &
                st_recycle_v_l2 &                                  --(82)
                l2req_resend_l2 &                                  --(83)
                l2req_recycle_l2 &                                 --(84)
                dbg_l2(33) &                                       --(85)
                mmu_q_val &                                        --(86)
                mmu_q_entry_l2(0);                                 --(87)

lmq_dbg_grp4 <= ifetch_req_l2 &                                    --(0)
                ifetch_ra_l2 &                                     --(1:38)
                ifetch_thread_l2 &                                 --(39:42)
                i_f_q0_val_l2 &                                    --(43)
                i_f_q1_val_l2 &                                    --(44)
                i_f_q2_val_l2 &                                    --(45)
                i_f_q3_val_l2 &                                    --(46)
                send_if_req_l2 &                                   --(47)
                send_ld_req_l2 &                                   --(48)
                send_mm_req_l2 &                                   --(49)
                dbg_l2(34 to 37) &                                 --(50:53)
                dbg_l2(38) &                                       --(54)
               	l2req_l2 &                                         --(55)
             	l2req_thread_l2 &                                  --(56:58)
                l2req_ttype_l2 &                                   --(59:64)
                l2req_ld_core_tag_l2 &                             --(65:69)
                l2req_wimg_l2 &                                    --(70:73)
                anaclat_data_val &                                 --(74)
                anaclat_reld_crit_qw &                             --(75)
                anaclat_tag(1 to 4) &                              --(76:79)
                anaclat_qw(58 to 59) &                             --(80:81)
                anaclat_ecc_err &                                  --(82)
                anaclat_ecc_err_ue &                               --(83)
                load_credit &                                      --(84)
                store_credit &                                     --(85)
                ex5_sel_st_req &                                   --(86)
                '0' ;                                              --(87)

lmq_dbg_grp5 <= mm_req_val_l2 &                                    --(0)
                mmu_q_val_l2 &                                     --(1)
                mmu_q_entry_l2 &                                   --(2:69)
                send_if_req_l2 &                                   --(70)
                send_ld_req_l2 &                                   --(71)
                send_mm_req_l2 &                                   --(72)
                dbg_l2(39) &                                       --(73)
               	l2req_l2 &                                         --(74)
             	l2req_thread_l2 &                                  --(75:77)
                l2req_ttype_l2 &                                   --(78:83)
                "0000";

lmq_dbg_grp6 <= ex3_stg_flush &                                    --(0)
                ex4_l2cmdq_flush_l2(0) &                            --(1)
                ex4_l2cmdq_flush_l2(2) &                            --(2)
                ex4_l2cmdq_flush_l2(1) &                            --(3)
                ex4_l2cmdq_flush_l2(3) &                            --(4)
                ex4_drop_ld_req &                                  --(5)
                l_m_fnd_stg &                                      --(6)
                ex4_stg_flush &                                    --(7)
                my_ex4_flush_l2 &                                  --(8)
                ex5_stg_flush &                                    --(9)
                ex2_lm_dep_hit_buf &                               --(10)
                ex3_thrd_id(0 to 3) &                              --(11:14)
                 dbg_l2(15 to 20) &                                --(15:20)
                 dbg_l2(21 to 26) &                                --(21:26)
                ex4_lmq_cpy_l2(0 to lmq_entries-1) &               --(27:34)
                lmq_collision_t0_l2(0 to lmq_entries-1) &          --(35:42)
                lmq_collision_t1_l2(0 to lmq_entries-1) &          --(43:50)
                lmq_collision_t2_l2(0 to lmq_entries-1) &          --(51:58)
                lmq_collision_t3_l2(0 to lmq_entries-1) &          --(59:66)
                ldq_barr_active_l2(0 to 3) &                       --(67:70)
                ldq_barr_done_l2(0 to 3) &                         --(71:74)
                sync_done_tid_l2(0 to 3) &                         --(75:78)
                ld_rel_val_l2 &                                    --(79:86)
                st_entry0_val_l2;                                  --(87)


-- scan in and scan out connections

siv(0 to l_m_queue_addrlo_offset-1) <= sov(1 to l_m_queue_addrlo_offset-1) & scan_in(0);
scan_out(0) <= sov(0) and scan_dis_dc_b;


siv(l_m_queue_addrlo_offset to l2req_ld_core_tag_offset-1) <= sov(l_m_queue_addrlo_offset+1 to l2req_ld_core_tag_offset-1) & scan_in(1);
scan_out(1) <= sov(l_m_queue_addrlo_offset) and scan_dis_dc_b;


siv(l2req_ld_core_tag_offset to siv'right) <= sov(l2req_ld_core_tag_offset+1 to siv'right) & scan_in(2);
scan_out(2) <= sov(l2req_ld_core_tag_offset) and scan_dis_dc_b;

bcfg_siv(0 to bcfg_siv'right) <= bcfg_sov(1 to bcfg_siv'right) & bcfg_scan_in;
bcfg_scan_out <= bcfg_sov(0) and scan_dis_dc_b;

end xuq_lsu_l2cmdq;
