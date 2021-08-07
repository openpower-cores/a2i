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

--  Description:  XU Exception Handler
--
library ieee,ibm,support,work,tri;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use support.power_logic_pkg.all;
use ibm.std_ulogic_support.all;
use ibm.std_ulogic_function_support.all;
use tri.tri_latches_pkg.all;
use work.xuq_pkg.all;

entity xuq_fxua_data is
generic(expand_type     : integer := 2;                 -- 0 = ibm (Umbra), 1 = non-ibm, 2 = ibm (MPG)
        regmode         : integer := 6;                 -- Register Mode 5 = 32bit, 6 = 64bit
        dc_size         : natural := 14;                -- 2^14 = 16384 Bytes L1 D$
        cl_size         : natural := 6;                 -- 2^6 = 64 Bytes CacheLines
        l_endian_m      : integer := 1;
        threads         : integer := 4;
        eff_ifar        : integer := 62;
        regsize         : integer := 64;
        a2mode          : integer := 1;
        hvmode          : integer := 1;
        real_data_add   : integer := 42); 
port(

        ---------------------------------------------------------------------
        -- Pervasive
        ---------------------------------------------------------------------
        pc_xu_abist_raddr_0                 : in     std_ulogic_vector(1 to 9);
        pc_xu_abist_raddr_1                 : in     std_ulogic_vector(2 to 9);
        pc_xu_abist_grf_renb_0              : in     std_ulogic;
        pc_xu_abist_grf_renb_1              : in     std_ulogic;
        pc_xu_abist_ena_dc                  : in     std_ulogic;
        pc_xu_abist_waddr_0                 : in     std_ulogic_vector(2 to 9);
        pc_xu_abist_waddr_1                 : in     std_ulogic_vector(2 to 9);
        pc_xu_abist_grf_wenb_0              : in     std_ulogic;
        pc_xu_abist_grf_wenb_1              : in     std_ulogic;
        pc_xu_abist_di_0                    : in     std_ulogic_vector(0 to 3);
        pc_xu_abist_di_1                    : in     std_ulogic_vector(0 to 3);
        pc_xu_abist_wl144_comp_ena          : in     std_ulogic;
        pc_xu_abist_raw_dc_b                : in     std_ulogic;
        pc_xu_ccflush_dc                    : in     std_ulogic;
        clkoff_dc_b                         : in     std_ulogic;
        d_mode_dc                           : in     std_ulogic;
        delay_lclkr_dc                      : in     std_ulogic_vector(4 to 4);
        mpw1_dc_b                           : in     std_ulogic_vector(4 to 4);
        mpw2_dc_b                           : in     std_ulogic;
        g6t_clkoff_dc_b                     : in     std_ulogic;
        g6t_d_mode_dc                       : in     std_ulogic;
        g6t_delay_lclkr_dc                  : in     std_ulogic_vector(0 to 4);
        g6t_mpw1_dc_b                       : in     std_ulogic_vector(0 to 4);
        g6t_mpw2_dc_b                       : in     std_ulogic;
        an_ac_scan_diag_dc                  : in     std_ulogic;
        an_ac_lbist_ary_wrt_thru_dc         : in     std_ulogic;
        sg_2                                : in     std_ulogic_vector(0 to 2);
        fce_2                               : in     std_ulogic_vector(0 to 0);
        func_sl_thold_2                     : in     std_ulogic_vector(0 to 3);
        func_nsl_thold_2                    : in     std_ulogic;
        abst_sl_thold_2                     : in     std_ulogic;
        time_sl_thold_2                     : in     std_ulogic;
        ary_nsl_thold_2                     : in     std_ulogic;
        repr_sl_thold_2                     : in     std_ulogic;
        gptr_sl_thold_2                     : in     std_ulogic;
        bolt_sl_thold_2                     : in     std_ulogic;
        bo_enable_2                         : in     std_ulogic;
        pc_xu_bo_unload                     : in     std_ulogic;
        pc_xu_bo_load                       : in     std_ulogic;
        pc_xu_bo_repair                     : in     std_ulogic;
        pc_xu_bo_reset                      : in     std_ulogic;
        pc_xu_bo_shdata                     : in     std_ulogic;
        pc_xu_bo_select                     : in     std_ulogic_vector(5 to 8);
        xu_pc_bo_fail                       : out    std_ulogic_vector(5 to 8);
        xu_pc_bo_diagout                    : out    std_ulogic_vector(5 to 8);

        ---------------------------------------------------------------------
        -- Interface with IU
        ---------------------------------------------------------------------
        iu_xu_is2_vld                       : in  std_ulogic;
        iu_xu_is2_ifar                      : in  std_ulogic_vector(62-eff_ifar to 61);
        iu_xu_is2_tid                       : in  std_ulogic_vector(0 to threads-1);
        iu_xu_is2_instr                     : in  std_ulogic_vector(0 to 31);
        iu_xu_is2_ta_vld                    : in  std_ulogic;
        iu_xu_is2_ta                        : in  std_ulogic_vector(0 to 5);
        iu_xu_is2_s1_vld                    : in  std_ulogic;
        iu_xu_is2_s1                        : in  std_ulogic_vector(0 to 5);
        iu_xu_is2_s2_vld                    : in  std_ulogic;
        iu_xu_is2_s2                        : in  std_ulogic_vector(0 to 5);
        iu_xu_is2_s3_vld                    : in  std_ulogic;
        iu_xu_is2_s3                        : in  std_ulogic_vector(0 to 5);
        iu_xu_is2_axu_ld_or_st              : in  std_ulogic;
        iu_xu_is2_axu_store                 : in  std_ulogic;
        iu_xu_is2_axu_ldst_size             : in  std_ulogic_vector(0 to 5);
        iu_xu_is2_axu_ldst_update           : in  std_ulogic;
        iu_xu_is2_axu_ldst_forcealign       : in  std_ulogic;
        iu_xu_is2_axu_ldst_forceexcept      : in  std_ulogic;
        iu_xu_is2_axu_ldst_extpid           : in  std_ulogic;
        iu_xu_is2_axu_ldst_indexed          : in  std_ulogic;
        iu_xu_is2_axu_ldst_tag              : in  std_ulogic_vector(0 to 8);
        iu_xu_is2_axu_mftgpr                : in  std_ulogic;
        iu_xu_is2_axu_mffgpr                : in  std_ulogic;
        iu_xu_is2_axu_movedp                : in  std_ulogic;
        iu_xu_is2_axu_instr_type            : in  std_ulogic_vector(0 to 2);
        iu_xu_is2_pred_update               : in  std_ulogic;
        iu_xu_is2_pred_taken_cnt            : in  std_ulogic_vector(0 to 1);
        iu_xu_is2_error                     : in  std_ulogic_vector(0 to 2);
        iu_xu_is2_match                     : in  std_ulogic;
        iu_xu_is2_is_ucode                  : in  std_ulogic;
        iu_xu_is2_ucode_vld                 : in  std_ulogic;
        iu_xu_is2_gshare                    : in  std_ulogic_vector(0 to 3);
        xu_iu_multdiv_done                  : out std_ulogic_vector(0 to threads-1);
        xu_iu_membar_tid                    : out std_ulogic_vector(0 to threads-1);

        ---------------------------------------------------------------------
        -- Interface with LSU
        ---------------------------------------------------------------------
        lsu_xu_ldq_barr_done                : in  std_ulogic_vector(0 to threads-1);
        lsu_xu_barr_done                    : in  std_ulogic_vector(0 to threads-1);

        ---------------------------------------------------------------------
        -- Interface with FXU B
        ---------------------------------------------------------------------
        fxa_fxb_rf0_val                     : out std_ulogic_vector(0 to threads-1);
        fxa_fxb_rf0_issued                  : out std_ulogic_vector(0 to threads-1);
        fxa_fxb_rf0_ucode_val               : out std_ulogic_vector(0 to threads-1);
        fxa_fxb_rf0_act                     : out std_ulogic;
        fxa_fxb_ex1_hold_ctr_flush          : out std_ulogic;
        fxa_fxb_rf0_instr                   : out std_ulogic_vector(0 to 31);
        fxa_fxb_rf0_tid                     : out std_ulogic_vector(0 to threads-1);
        fxa_fxb_rf0_ta_vld                  : out std_ulogic;
        fxa_fxb_rf0_ta                      : out std_ulogic_vector(0 to 7);
        fxa_fxb_rf0_error                   : out std_ulogic_vector(0 to 2);
        fxa_fxb_rf0_match                   : out std_ulogic;
        fxa_fxb_rf0_is_ucode                : out std_ulogic;
        fxa_fxb_rf0_gshare                  : out std_ulogic_vector(0 to 3);
        fxa_fxb_rf0_ifar                    : out std_ulogic_vector(62-eff_ifar to 61);
        fxa_fxb_rf0_s1_vld                  : out std_ulogic;
        fxa_fxb_rf0_s1                      : out std_ulogic_vector(0 to 7);
        fxa_fxb_rf0_s2_vld                  : out std_ulogic;
        fxa_fxb_rf0_s2                      : out std_ulogic_vector(0 to 7);
        fxa_fxb_rf0_s3_vld                  : out std_ulogic;
        fxa_fxb_rf0_s3                      : out std_ulogic_vector(0 to 7);
        fxa_fxb_rf0_axu_instr_type          : out std_ulogic_vector(0 to 2);
        fxa_fxb_rf0_axu_ld_or_st            : out std_ulogic;
        fxa_fxb_rf0_axu_store               : out std_ulogic;
        fxa_fxb_rf0_axu_mftgpr              : out std_ulogic;
        fxa_fxb_rf0_axu_mffgpr              : out std_ulogic;
        fxa_fxb_rf0_axu_movedp              : out std_ulogic;
        fxa_fxb_rf0_axu_ldst_size           : out std_ulogic_vector(0 to 5);
        fxa_fxb_rf0_axu_ldst_update         : out std_ulogic;
        fxa_fxb_rf0_axu_ldst_forcealign     : out std_ulogic;
        fxa_fxb_rf0_axu_ldst_forceexcept    : out std_ulogic;
        fxa_fxb_rf0_axu_ldst_indexed        : out std_ulogic;
        fxa_fxb_rf0_axu_ldst_tag            : out std_ulogic_vector(0 to 8);
        fxa_fxb_rf0_pred_update             : out std_ulogic;
        fxa_fxb_rf0_pred_taken_cnt          : out std_ulogic_vector(0 to 1);
        fxa_fxb_rf0_mc_dep_chk_val          : out std_ulogic_vector(0 to threads-1);
        fxa_fxb_rf1_mul_val                 : out std_ulogic;
        fxa_fxb_rf1_muldiv_coll             : out std_ulogic;
        fxa_fxb_rf1_div_val                 : out std_ulogic;
        fxa_fxb_rf1_div_ctr                 : out std_ulogic_vector(0 to 7);
        fxa_fxb_rf0_xu_epid_instr           : out std_ulogic;
        fxa_fxb_rf0_axu_is_extload          : out std_ulogic;
        fxa_fxb_rf0_axu_is_extstore         : out std_ulogic;
        fxa_fxb_rf0_spr_tid                 : out std_ulogic_vector(0 to threads-1);
        fxa_fxb_rf0_cpl_tid                 : out std_ulogic_vector(0 to threads-1);
        fxa_fxb_rf0_cpl_act                 : out std_ulogic;
        fxa_fxb_rf0_is_mfocrf               : out std_ulogic;
        fxa_fxb_rf0_3src_instr              : out std_ulogic;
        fxa_fxb_rf0_gpr0_zero               : out std_ulogic;
        fxa_fxb_rf0_use_imm                 : out std_ulogic;
        dec_cpl_ex3_mc_dep_chk_val          : out std_ulogic_vector(0 to threads-1);
        fxb_fxa_ex7_we0                     : in  std_ulogic;
        fxb_fxa_ex7_wa0                     : in  std_ulogic_vector(0 to 7);
        fxb_fxa_ex7_wd0                     : in  std_ulogic_vector(64-regsize to 63);
        fxa_fxb_rf1_do0                     : out std_ulogic_vector(64-regsize to 63);
        fxa_fxb_rf1_do1                     : out std_ulogic_vector(64-regsize to 63);
        fxa_fxb_rf1_do2                     : out std_ulogic_vector(64-regsize to 63);
        fxb_fxa_ex6_clear_barrier           : in  std_ulogic_vector(0 to threads-1);
        fxa_perf_muldiv_in_use              : out std_ulogic;

        ---------------------------------------------------------------------
        -- Flushes
        ---------------------------------------------------------------------
        xu_is2_flush                        : in  std_ulogic_vector(0 to threads-1);
        xu_rf0_flush                        : in  std_ulogic_vector(0 to threads-1);
        xu_rf1_flush                        : in  std_ulogic_vector(0 to threads-1);
        xu_ex1_flush                        : in  std_ulogic_vector(0 to threads-1);
        xu_ex2_flush                        : in  std_ulogic_vector(0 to threads-1);
        xu_ex3_flush                        : in  std_ulogic_vector(0 to threads-1);
        xu_ex4_flush                        : in  std_ulogic_vector(0 to threads-1);
        xu_ex5_flush                        : in  std_ulogic_vector(0 to threads-1);
        fxa_cpl_ex2_div_coll                : out std_ulogic_vector(0 to threads-1);
        cpl_fxa_ex5_set_barr                : in  std_ulogic_vector(0 to threads-1);
        fxa_iu_set_barr_tid                 : out std_ulogic_vector(0 to threads-1);
        spr_xucr4_div_barr_thres            : in  std_ulogic_vector(0 to 7);

        ---------------------------------------------------------------------
        -- ICSWX
        ---------------------------------------------------------------------
        an_ac_back_inv                      : in  std_ulogic;
        an_ac_back_inv_addr                 : in  std_ulogic_vector(62 to 63);
        an_ac_back_inv_target_bit3          : in  std_ulogic;

        ---------------------------------------------------------------------
        -- Interface with SPR
        ---------------------------------------------------------------------
        dec_spr_rf0_instr                   : out std_ulogic_vector(0 to 31);

        ---------------------------------------------------------------------
        -- Parity
        ---------------------------------------------------------------------
        pc_xu_inj_regfile_parity            : in std_ulogic_vector(0 to 3);
        xu_pc_err_regfile_parity            : out std_ulogic_vector(0 to threads-1);
        xu_pc_err_regfile_ue                : out std_ulogic_vector(0 to 3);
        gpr_cpl_ex3_regfile_err_det         : out std_ulogic;
        cpl_gpr_regfile_seq_beg             : in  std_ulogic;
        gpr_cpl_regfile_seq_end             : out std_ulogic;

        ---------------------------------------------------------------------
        -- Interface with LSU
        ---------------------------------------------------------------------
        xu_lsu_rf0_derat_is_extload         : out std_ulogic;
        xu_lsu_rf0_derat_is_extstore        : out std_ulogic;
        xu_lsu_rf0_derat_val                : out std_ulogic_vector(0 to threads-1);
        lsu_xu_rel_wren                     : in  std_ulogic;
        lsu_xu_rel_ta_gpr                   : in  std_ulogic_vector(0 to 7);
        fxa_cpl_debug                       : out std_ulogic_vector(0 to 272);

        -- Execution Pipe
        xu_lsu_rf1_data_act        :in  std_ulogic;
        xu_lsu_rf1_axu_ldst_falign :in  std_ulogic;
        xu_lsu_ex1_store_data      :in  std_ulogic_vector(64-(2**REGMODE) to 63);
        xu_lsu_ex1_eff_addr        :in  std_ulogic_vector(64-(dc_size-3) to 63);
        xu_lsu_ex1_rotsel_ovrd     :in  std_ulogic_vector(0 to 4);
        ex1_optype32               :in  std_ulogic;
        ex1_optype16               :in  std_ulogic;
        ex1_optype8                :in  std_ulogic;
        ex1_optype4                :in  std_ulogic;
        ex1_optype2                :in  std_ulogic;
        ex1_optype1                :in  std_ulogic;
        ex1_store_instr            :in  std_ulogic;
        ex1_axu_op_val             :in  std_ulogic;     
        ex1_saxu_instr             :in  std_ulogic;
        ex1_sdp_instr              :in  std_ulogic;
        ex1_stgpr_instr            :in  std_ulogic;

        fu_xu_ex2_store_data_val   :in  std_ulogic;                        -- EX2 AXU Data is Valid
        fu_xu_ex2_store_data       :in  std_ulogic_vector(0 to 255);       -- EX2 AXU Data
        
        ex3_algebraic              :in  std_ulogic;                        -- EX3 Instruction is a Load Algebraic
        ex3_data_swap              :in  std_ulogic;                        -- EX3 little-endian or byte reversal valid
        ex3_thrd_id                :in  std_ulogic_vector(0 to 3);         -- EX3 Thread ID
        bx_xu_ex5_dp_data          :in  std_ulogic_vector(0 to 127);       -- EX5 dp data

        -- Debug Data Compare
        ex4_load_op_hit            :in  std_ulogic;
        ex4_store_hit              :in  std_ulogic;
        ex4_axu_op_val             :in  std_ulogic;
        spr_dvc1_act               :in  std_ulogic;
        spr_dvc2_act               :in  std_ulogic;
        spr_dvc1_dbg               :in  std_ulogic_vector(64-(2**regmode) to 63);
        spr_dvc2_dbg               :in  std_ulogic_vector(64-(2**regmode) to 63);

        -- Update Data Array Valid
        rel_upd_dcarr_val          :in  std_ulogic;

        -- Instruction Flush
        xu_lsu_ex4_flush_local     :in  std_ulogic_vector(0 to 3);         -- EX4 Local Flush Stage

        -- Error Inject
        xu_pc_err_dcache_parity    :out std_ulogic;
        pc_xu_inj_dcache_parity    :in  std_ulogic;

        -- Config Bits
        xu_lsu_spr_xucr0_dcdis     :in  std_ulogic;
        spr_xucr0_clkg_ctl_b0      :in  std_ulogic;

        -- Reload Pipe
        ldq_rel_data_val_early     :in  std_ulogic;
        ldq_rel_algebraic          :in  std_ulogic;                        -- Reload requires sign extension
        ldq_rel_data_val           :in  std_ulogic;                        -- Reload Data is Valid
        ldq_rel_ci                 :in  std_ulogic;                        -- Reload Data is for a cache-inhibited request
        ldq_rel_thrd_id            :in  std_ulogic_vector(0 to 3);         -- Reload Thread ID for DVC
        ldq_rel_axu_val            :in  std_ulogic;                        -- Reload Data is the correct Quadword
        ldq_rel_256_data           :in  std_ulogic_vector(0 to 255);       -- Reload Data
        ldq_rel_rot_sel            :in  std_ulogic_vector(0 to 4);         -- Rotator Select
        ldq_rel_op_size            :in  std_ulogic_vector(0 to 5);         -- Reload Size of Original Request
        ldq_rel_le_mode            :in  std_ulogic;                        -- Reload requires Little Endian Swap
        ldq_rel_dvc1_en            :in  std_ulogic;                        -- Debug Data Value Compare1 Enable
        ldq_rel_dvc2_en            :in  std_ulogic;                        -- Debug Data Value Compare2 Enable
        ldq_rel_beat_crit_qw       :in  std_ulogic;                        -- Reload Data is the correct Quadword
        ldq_rel_beat_crit_qw_block :in  std_ulogic;                        -- Reload Data had an ecc error
        ldq_rel_addr               :in  std_ulogic_vector(64-(dc_size-3) to 58);   -- Reload Array Address

        -- Data Cache Update
        dcarr_up_way_addr          :in  std_ulogic_vector(0 to 2);         -- Upper Address of Data Cache

        -- Execution Pipe Outputs
        ex4_256st_data             :out std_ulogic_vector(0 to 255);       -- EX4 Store Data
        ex6_ld_par_err             :out std_ulogic;                        -- EX6 Parity Error Detected on the Load Data
        lsu_xu_ex6_datc_par_err    :out std_ulogic;                             -- EX6 Parity Error Detected

        --Rotated Data
        ex6_xu_ld_data_b           :out std_ulogic_vector(64-(2**regmode) to 63);
        rel_xu_ld_data             :out std_ulogic_vector(64-(2**regmode) to 63);
        xu_fu_ex6_load_data        :out std_ulogic_vector(0 to 255);
        xu_fu_ex5_load_le          :out std_ulogic;                        -- AXU load/reload was little endian swapped

        -- Debug Data Compare
        lsu_xu_rel_dvc_thrd_id     :out std_ulogic_vector(0 to 3);         -- DVC compared to a Threads Reload
        lsu_xu_ex2_dvc1_st_cmp     :out std_ulogic_vector(0 to ((2**regmode)/8)-1);
        lsu_xu_ex8_dvc1_ld_cmp     :out std_ulogic_vector(0 to ((2**regmode)/8)-1);
        lsu_xu_rel_dvc1_en         :out std_ulogic;
        lsu_xu_rel_dvc1_cmp        :out std_ulogic_vector(0 to ((2**regmode)/8)-1);
        lsu_xu_ex2_dvc2_st_cmp     :out std_ulogic_vector(0 to ((2**regmode)/8)-1);
        lsu_xu_ex8_dvc2_ld_cmp     :out std_ulogic_vector(0 to ((2**regmode)/8)-1);
        lsu_xu_rel_dvc2_en         :out std_ulogic;
        lsu_xu_rel_dvc2_cmp        :out std_ulogic_vector(0 to ((2**regmode)/8)-1);

        -- Debug Bus IO
        pc_xu_trace_bus_enable     :in  std_ulogic;
        lsudat_debug_mux_ctrls     :in  std_ulogic_vector(0 to 1);
        lsu_xu_data_debug0         :out std_ulogic_vector(0 to 87);
        lsu_xu_data_debug1         :out std_ulogic_vector(0 to 87);
        lsu_xu_data_debug2         :out std_ulogic_vector(0 to 87);

        --pervasive
        vdd                        :inout power_logic;
        gnd                        :inout power_logic;
        vcs                        :inout power_logic;
        nclk                       :in  clk_logic;
        an_ac_scan_dis_dc_b        :in  std_ulogic;

        -- G6T ABIST Control
        pc_xu_abist_g6t_bw         :in  std_ulogic_vector(0 to 1);
        pc_xu_abist_di_g6t_2r      :in  std_ulogic_vector(0 to 3);
        pc_xu_abist_wl512_comp_ena :in  std_ulogic;
        pc_xu_abist_dcomp_g6t_2r   :in  std_ulogic_vector(0 to 3);
        pc_xu_abist_g6t_r_wb       :in  std_ulogic;

        -- SCAN Ports
        abst_scan_in               :in  std_ulogic_vector(0 to 1);
        repr_scan_in               :in  std_ulogic;
        gptr_scan_in               :in  std_ulogic;
        time_scan_in               :in  std_ulogic;
        func_scan_in               :in  std_ulogic_vector(0 to 3);
        abst_scan_out              :out std_ulogic_vector(0 to 1);
        repr_scan_out              :out std_ulogic;
        time_scan_out              :out std_ulogic;
        gptr_scan_out              :out std_ulogic;
        func_scan_out              :out std_ulogic_vector(0 to 3)
);

-- synopsys translate_off


-- synopsys translate_on
end xuq_fxua_data;
architecture xuq_fxua_data of xuq_fxua_data is

signal rel_xu_ld_data_int               :std_ulogic_vector(64-(2**regmode) to 64+((2**regmode)/8)-1);
signal dat_abst_scan_in                 :std_ulogic;
signal dat_time_scan_in                 :std_ulogic;

begin

    xuq_fxu_a : entity work.xuq_fxu_a(xuq_fxu_a)
    generic map(
        expand_type                         => expand_type,
        threads                             => threads,
        eff_ifar                            => eff_ifar,
        regmode                             => regmode,
        regsize                             => regsize,
        a2mode                              => a2mode,
        hvmode                              => hvmode,
        real_data_add                       => real_data_add)
    port map(
        nclk                                => nclk,
        vdd                                 => vdd,
        gnd                                 => gnd,
        vcs                                 => vcs,
        an_ac_scan_dis_dc_b                 => an_ac_scan_dis_dc_b,
        func_scan_in                        => func_scan_in(0 to 0),
        func_scan_out                       => func_scan_out(0 to 0),
        abst_scan_in                        => abst_scan_in(0),
        abst_scan_out                       => abst_scan_out(0),
        an_ac_lbist_ary_wrt_thru_dc         => an_ac_lbist_ary_wrt_thru_dc,
        pc_xu_abist_raddr_0                 => pc_xu_abist_raddr_0(2 to 9),
        pc_xu_abist_raddr_1                 => pc_xu_abist_raddr_1(2 to 9),
        pc_xu_abist_grf_renb_0              => pc_xu_abist_grf_renb_0,
        pc_xu_abist_grf_renb_1              => pc_xu_abist_grf_renb_1,
        pc_xu_abist_ena_dc                  => pc_xu_abist_ena_dc,
        pc_xu_abist_waddr_0                 => pc_xu_abist_waddr_0(2 to 9),
        pc_xu_abist_waddr_1                 => pc_xu_abist_waddr_1(2 to 9),
        pc_xu_abist_grf_wenb_0              => pc_xu_abist_grf_wenb_0,
        pc_xu_abist_grf_wenb_1              => pc_xu_abist_grf_wenb_1,
        pc_xu_abist_di_0                    => pc_xu_abist_di_0,
        pc_xu_abist_di_1                    => pc_xu_abist_di_1,
        pc_xu_abist_wl144_comp_ena          => pc_xu_abist_wl144_comp_ena,
        pc_xu_abist_raw_dc_b                => pc_xu_abist_raw_dc_b,
        pc_xu_ccflush_dc                    => pc_xu_ccflush_dc,
        clkoff_dc_b                         => clkoff_dc_b,
        d_mode_dc                           => d_mode_dc,
        delay_lclkr_dc                      => delay_lclkr_dc(4 to 4),
        mpw1_dc_b                           => mpw1_dc_b(4 to 4),
        mpw2_dc_b                           => mpw2_dc_b,
        bolt_sl_thold_2                     => bolt_sl_thold_2,
        bo_enable_2                         => bo_enable_2,
        pc_xu_bo_unload                     => pc_xu_bo_unload,
        pc_xu_bo_load                       => pc_xu_bo_load,
        pc_xu_bo_reset                      => pc_xu_bo_reset,
        pc_xu_bo_shdata                     => pc_xu_bo_shdata,
        pc_xu_bo_select                     => pc_xu_bo_select(7 to 8),
        xu_pc_bo_fail                       => xu_pc_bo_fail(7 to 8),
        xu_pc_bo_diagout                    => xu_pc_bo_diagout(7 to 8),
        an_ac_scan_diag_dc                  => an_ac_scan_diag_dc,
        scan_dis_dc_b                       => an_ac_scan_dis_dc_b,
        sg_2                                => sg_2(0 to 0),
        fce_2                               => fce_2(0 to 0),
        func_sl_thold_2                     => func_sl_thold_2(0 to 0),
        func_nsl_thold_2                    => func_nsl_thold_2,
        abst_sl_thold_2                     => abst_sl_thold_2,
        time_sl_thold_2                     => time_sl_thold_2,
        ary_nsl_thold_2                     => ary_nsl_thold_2,
        gptr_sl_thold_2                     => gptr_sl_thold_2,
        time_scan_in                        => time_scan_in,
        time_scan_out                       => dat_time_scan_in,
        gptr_scan_in                        => gptr_scan_in,
        gptr_scan_out                       => gptr_scan_out,
        iu_xu_is2_vld                       => iu_xu_is2_vld,
        iu_xu_is2_ifar                      => iu_xu_is2_ifar,
        iu_xu_is2_tid                       => iu_xu_is2_tid,
        iu_xu_is2_instr                     => iu_xu_is2_instr,
        iu_xu_is2_ta_vld                    => iu_xu_is2_ta_vld,
        iu_xu_is2_ta                        => iu_xu_is2_ta,
        iu_xu_is2_s1_vld                    => iu_xu_is2_s1_vld,
        iu_xu_is2_s1                        => iu_xu_is2_s1,
        iu_xu_is2_s2_vld                    => iu_xu_is2_s2_vld,
        iu_xu_is2_s2                        => iu_xu_is2_s2,
        iu_xu_is2_s3_vld                    => iu_xu_is2_s3_vld,
        iu_xu_is2_s3                        => iu_xu_is2_s3,
        iu_xu_is2_axu_ld_or_st              => iu_xu_is2_axu_ld_or_st,
        iu_xu_is2_axu_store                 => iu_xu_is2_axu_store,
        iu_xu_is2_axu_ldst_size             => iu_xu_is2_axu_ldst_size,
        iu_xu_is2_axu_ldst_update           => iu_xu_is2_axu_ldst_update,
        iu_xu_is2_axu_ldst_forcealign       => iu_xu_is2_axu_ldst_forcealign,
        iu_xu_is2_axu_ldst_forceexcept      => iu_xu_is2_axu_ldst_forceexcept,
        iu_xu_is2_axu_ldst_extpid           => iu_xu_is2_axu_ldst_extpid,
        iu_xu_is2_axu_ldst_indexed          => iu_xu_is2_axu_ldst_indexed,
        iu_xu_is2_axu_ldst_tag              => iu_xu_is2_axu_ldst_tag,
        iu_xu_is2_axu_mftgpr                => iu_xu_is2_axu_mftgpr,
        iu_xu_is2_axu_mffgpr                => iu_xu_is2_axu_mffgpr,
        iu_xu_is2_axu_movedp                => iu_xu_is2_axu_movedp,
        iu_xu_is2_axu_instr_type            => iu_xu_is2_axu_instr_type,
        iu_xu_is2_pred_update               => iu_xu_is2_pred_update,
        iu_xu_is2_pred_taken_cnt            => iu_xu_is2_pred_taken_cnt,
        iu_xu_is2_error                     => iu_xu_is2_error,
        iu_xu_is2_match                     => iu_xu_is2_match,
        iu_xu_is2_is_ucode                  => iu_xu_is2_is_ucode,
        iu_xu_is2_ucode_vld                 => iu_xu_is2_ucode_vld,
        iu_xu_is2_gshare                    => iu_xu_is2_gshare,
        xu_iu_multdiv_done                  => xu_iu_multdiv_done,
        xu_iu_membar_tid                    => xu_iu_membar_tid,
        lsu_xu_ldq_barr_done                => lsu_xu_ldq_barr_done,
        lsu_xu_barr_done                    => lsu_xu_barr_done,
        fxa_fxb_rf0_val                     => fxa_fxb_rf0_val,
        fxa_fxb_rf0_issued                  => fxa_fxb_rf0_issued,
        fxa_fxb_rf0_ucode_val               => fxa_fxb_rf0_ucode_val,
        fxa_fxb_rf0_act                     => fxa_fxb_rf0_act,
        fxa_fxb_ex1_hold_ctr_flush          => fxa_fxb_ex1_hold_ctr_flush,
        fxa_fxb_rf0_instr                   => fxa_fxb_rf0_instr,
        fxa_fxb_rf0_tid                     => fxa_fxb_rf0_tid,
        fxa_fxb_rf0_ta_vld                  => fxa_fxb_rf0_ta_vld,
        fxa_fxb_rf0_ta                      => fxa_fxb_rf0_ta,
        fxa_fxb_rf0_error                   => fxa_fxb_rf0_error,
        fxa_fxb_rf0_match                   => fxa_fxb_rf0_match,
        fxa_fxb_rf0_is_ucode                => fxa_fxb_rf0_is_ucode,
        fxa_fxb_rf0_gshare                  => fxa_fxb_rf0_gshare,
        fxa_fxb_rf0_ifar                    => fxa_fxb_rf0_ifar,
        fxa_fxb_rf0_s1_vld                  => fxa_fxb_rf0_s1_vld,
        fxa_fxb_rf0_s1                      => fxa_fxb_rf0_s1,
        fxa_fxb_rf0_s2_vld                  => fxa_fxb_rf0_s2_vld,
        fxa_fxb_rf0_s2                      => fxa_fxb_rf0_s2,
        fxa_fxb_rf0_s3_vld                  => fxa_fxb_rf0_s3_vld,
        fxa_fxb_rf0_s3                      => fxa_fxb_rf0_s3,
        fxa_fxb_rf0_axu_instr_type          => fxa_fxb_rf0_axu_instr_type,
        fxa_fxb_rf0_axu_ld_or_st            => fxa_fxb_rf0_axu_ld_or_st,
        fxa_fxb_rf0_axu_store               => fxa_fxb_rf0_axu_store,
        fxa_fxb_rf0_axu_mftgpr              => fxa_fxb_rf0_axu_mftgpr,
        fxa_fxb_rf0_axu_mffgpr              => fxa_fxb_rf0_axu_mffgpr,
        fxa_fxb_rf0_axu_movedp              => fxa_fxb_rf0_axu_movedp,
        fxa_fxb_rf0_axu_ldst_size           => fxa_fxb_rf0_axu_ldst_size,
        fxa_fxb_rf0_axu_ldst_update         => fxa_fxb_rf0_axu_ldst_update,
        fxa_fxb_rf0_axu_ldst_forcealign     => fxa_fxb_rf0_axu_ldst_forcealign,
        fxa_fxb_rf0_axu_ldst_forceexcept    => fxa_fxb_rf0_axu_ldst_forceexcept,
        fxa_fxb_rf0_axu_ldst_indexed        => fxa_fxb_rf0_axu_ldst_indexed,
        fxa_fxb_rf0_axu_ldst_tag            => fxa_fxb_rf0_axu_ldst_tag,
        fxa_fxb_rf0_pred_update             => fxa_fxb_rf0_pred_update,
        fxa_fxb_rf0_pred_taken_cnt          => fxa_fxb_rf0_pred_taken_cnt,
        fxa_fxb_rf0_mc_dep_chk_val          => fxa_fxb_rf0_mc_dep_chk_val,
        fxa_fxb_rf1_mul_val                 => fxa_fxb_rf1_mul_val,
        fxa_fxb_rf1_muldiv_coll             => fxa_fxb_rf1_muldiv_coll,
        fxa_fxb_rf1_div_val                 => fxa_fxb_rf1_div_val,
        fxa_fxb_rf1_div_ctr                 => fxa_fxb_rf1_div_ctr,
        fxa_fxb_rf0_xu_epid_instr           => fxa_fxb_rf0_xu_epid_instr,
        fxa_fxb_rf0_axu_is_extload          => fxa_fxb_rf0_axu_is_extload,
        fxa_fxb_rf0_axu_is_extstore         => fxa_fxb_rf0_axu_is_extstore,
        fxa_fxb_rf0_is_mfocrf               => fxa_fxb_rf0_is_mfocrf,
        fxa_fxb_rf0_3src_instr              => fxa_fxb_rf0_3src_instr,
        fxa_fxb_rf0_gpr0_zero               => fxa_fxb_rf0_gpr0_zero,
        fxa_fxb_rf0_use_imm                 => fxa_fxb_rf0_use_imm,
        fxb_fxa_ex7_we0                     => fxb_fxa_ex7_we0,
        fxb_fxa_ex7_wa0                     => fxb_fxa_ex7_wa0,
        fxb_fxa_ex7_wd0                     => fxb_fxa_ex7_wd0,
        fxa_fxb_rf1_do0                     => fxa_fxb_rf1_do0,
        fxa_fxb_rf1_do1                     => fxa_fxb_rf1_do1,
        fxa_fxb_rf1_do2                     => fxa_fxb_rf1_do2,
        fxb_fxa_ex6_clear_barrier           => fxb_fxa_ex6_clear_barrier,
        fxa_perf_muldiv_in_use              => fxa_perf_muldiv_in_use,
        dec_cpl_ex3_mc_dep_chk_val          => dec_cpl_ex3_mc_dep_chk_val,
        xu_is2_flush                        => xu_is2_flush,
        xu_rf0_flush                        => xu_rf0_flush,
        xu_rf1_flush                        => xu_rf1_flush,
        xu_ex1_flush                        => xu_ex1_flush,
        xu_ex2_flush                        => xu_ex2_flush,
        xu_ex3_flush                        => xu_ex3_flush,
        xu_ex4_flush                        => xu_ex4_flush,
        xu_ex5_flush                        => xu_ex5_flush,
        fxa_cpl_ex2_div_coll                => fxa_cpl_ex2_div_coll,
        cpl_fxa_ex5_set_barr                => cpl_fxa_ex5_set_barr,
        fxa_iu_set_barr_tid                 => fxa_iu_set_barr_tid,
        spr_xucr4_div_barr_thres            => spr_xucr4_div_barr_thres,
        an_ac_back_inv                      => an_ac_back_inv,
        an_ac_back_inv_addr                 => an_ac_back_inv_addr(62 to 63),
        an_ac_back_inv_target_bit3          => an_ac_back_inv_target_bit3,
        dec_spr_rf0_instr                   => dec_spr_rf0_instr,
        pc_xu_inj_regfile_parity            => pc_xu_inj_regfile_parity,
        xu_pc_err_regfile_parity            => xu_pc_err_regfile_parity,
        xu_pc_err_regfile_ue                => xu_pc_err_regfile_ue,
        gpr_cpl_ex3_regfile_err_det         => gpr_cpl_ex3_regfile_err_det,
        cpl_gpr_regfile_seq_beg             => cpl_gpr_regfile_seq_beg,
        gpr_cpl_regfile_seq_end             => gpr_cpl_regfile_seq_end,
        xu_lsu_rf0_derat_is_extload         => xu_lsu_rf0_derat_is_extload,
        xu_lsu_rf0_derat_is_extstore        => xu_lsu_rf0_derat_is_extstore,
        xu_lsu_rf0_derat_val                => xu_lsu_rf0_derat_val,
        lsu_xu_rel_wren                     => lsu_xu_rel_wren,
        lsu_xu_rel_ta_gpr                   => lsu_xu_rel_ta_gpr,
        lsu_xu_rot_rel_data                 => rel_xu_ld_data_int,
        fxa_fxb_rf0_spr_tid                 => fxa_fxb_rf0_spr_tid,
        fxa_fxb_rf0_cpl_tid                 => fxa_fxb_rf0_cpl_tid,
        fxa_fxb_rf0_cpl_act                 => fxa_fxb_rf0_cpl_act,
        fxa_cpl_debug                       => fxa_cpl_debug,
        spr_xucr0_clkg_ctl_b0               => spr_xucr0_clkg_ctl_b0
    );


lsudata : entity work.xuq_lsu_data(xuq_lsu_data)
generic map(expand_type     => expand_type,
            regmode         => regmode,
            dc_size         => dc_size,
            l_endian_m      => l_endian_m)
port map(

     -- Execution Pipe
     xu_lsu_rf1_data_act        => xu_lsu_rf1_data_act,
     xu_lsu_rf1_axu_ldst_falign => xu_lsu_rf1_axu_ldst_falign,
     xu_lsu_ex1_store_data      => xu_lsu_ex1_store_data,
     xu_lsu_ex1_eff_addr        => xu_lsu_ex1_eff_addr,
     xu_lsu_ex1_rotsel_ovrd     => xu_lsu_ex1_rotsel_ovrd,
     ex1_optype32               => ex1_optype32,
     ex1_optype16               => ex1_optype16,
     ex1_optype8                => ex1_optype8,
     ex1_optype4                => ex1_optype4,
     ex1_optype2                => ex1_optype2,
     ex1_optype1                => ex1_optype1,
     ex1_store_instr            => ex1_store_instr,
     ex1_axu_op_val             => ex1_axu_op_val,
     ex1_saxu_instr             => ex1_saxu_instr,
     ex1_sdp_instr              => ex1_sdp_instr,
     ex1_stgpr_instr            => ex1_stgpr_instr,
     fu_xu_ex2_store_data_val   => fu_xu_ex2_store_data_val,
     fu_xu_ex2_store_data       => fu_xu_ex2_store_data,

     ex3_algebraic              => ex3_algebraic,
     ex3_data_swap              => ex3_data_swap,
     ex3_thrd_id                => ex3_thrd_id,
     ex5_dp_data                => bx_xu_ex5_dp_data,

     -- Debug Data Compare
     ex4_load_op_hit            => ex4_load_op_hit,
     ex4_store_hit              => ex4_store_hit,
     ex4_axu_op_val             => ex4_axu_op_val,
     spr_dvc1_act               => spr_dvc1_act,
     spr_dvc2_act               => spr_dvc2_act,
     spr_dvc1_dbg               => spr_dvc1_dbg,
     spr_dvc2_dbg               => spr_dvc2_dbg,

     -- Update Data Array Valid
     rel_upd_dcarr_val          => rel_upd_dcarr_val,

     -- Instruction Flush
     xu_lsu_ex4_flush           => xu_ex4_flush,
     xu_lsu_ex4_flush_local     => xu_lsu_ex4_flush_local,
     xu_lsu_ex5_flush           => xu_ex5_flush,

     -- Error Inject
     xu_pc_err_dcache_parity    => xu_pc_err_dcache_parity,
     pc_xu_inj_dcache_parity    => pc_xu_inj_dcache_parity,

     -- Config Bits
     xu_lsu_spr_xucr0_dcdis     => xu_lsu_spr_xucr0_dcdis,
     spr_xucr0_clkg_ctl_b0      => spr_xucr0_clkg_ctl_b0,

     -- Reload Pipe
     ldq_rel_data_val_early     => ldq_rel_data_val_early,
     ldq_rel_algebraic          => ldq_rel_algebraic,
     ldq_rel_data_val           => ldq_rel_data_val,
     ldq_rel_ci                 => ldq_rel_ci,
     ldq_rel_thrd_id            => ldq_rel_thrd_id,
     ldq_rel_axu_val            => ldq_rel_axu_val,
     ldq_rel_data               => ldq_rel_256_data,
     ldq_rel_rot_sel            => ldq_rel_rot_sel,
     ldq_rel_op_size            => ldq_rel_op_size,
     ldq_rel_le_mode            => ldq_rel_le_mode,
     ldq_rel_dvc1_en            => ldq_rel_dvc1_en,
     ldq_rel_dvc2_en            => ldq_rel_dvc2_en,
     ldq_rel_beat_crit_qw       => ldq_rel_beat_crit_qw,
     ldq_rel_beat_crit_qw_block => ldq_rel_beat_crit_qw_block,
     ldq_rel_addr               => ldq_rel_addr,

     -- Data Cache Update
     dcarr_up_way_addr          => dcarr_up_way_addr,

     -- Execution Pipe Outputs
     ex4_256st_data             => ex4_256st_data,
     ex6_ld_par_err             => ex6_ld_par_err,
     lsu_xu_ex6_datc_par_err    => lsu_xu_ex6_datc_par_err,

     --Rotated Data
     ex6_xu_ld_data_b           => ex6_xu_ld_data_b,
     rel_xu_ld_data             => rel_xu_ld_data_int,
     xu_fu_ex6_load_data        => xu_fu_ex6_load_data,
     xu_fu_ex5_load_le          => xu_fu_ex5_load_le,

     -- Debug Data Compare
     lsu_xu_rel_dvc_thrd_id     => lsu_xu_rel_dvc_thrd_id,
     lsu_xu_ex2_dvc1_st_cmp     => lsu_xu_ex2_dvc1_st_cmp,
     lsu_xu_ex8_dvc1_ld_cmp     => lsu_xu_ex8_dvc1_ld_cmp,
     lsu_xu_rel_dvc1_en         => lsu_xu_rel_dvc1_en,
     lsu_xu_rel_dvc1_cmp        => lsu_xu_rel_dvc1_cmp,
     lsu_xu_ex2_dvc2_st_cmp     => lsu_xu_ex2_dvc2_st_cmp,
     lsu_xu_ex8_dvc2_ld_cmp     => lsu_xu_ex8_dvc2_ld_cmp,
     lsu_xu_rel_dvc2_en         => lsu_xu_rel_dvc2_en,
     lsu_xu_rel_dvc2_cmp        => lsu_xu_rel_dvc2_cmp,

     -- Debug Bus IO
     pc_xu_trace_bus_enable     => pc_xu_trace_bus_enable,
     lsudat_debug_mux_ctrls     => lsudat_debug_mux_ctrls,
     lsu_xu_data_debug0         => lsu_xu_data_debug0,
     lsu_xu_data_debug1         => lsu_xu_data_debug1,
     lsu_xu_data_debug2         => lsu_xu_data_debug2,

     --pervasive
     vdd                        => vdd,
     gnd                        => gnd,
     vcs                        => vcs,
     nclk                       => nclk,
     pc_xu_ccflush_dc           => pc_xu_ccflush_dc,
     clkoff_dc_b                => clkoff_dc_b,
     d_mode_dc                  => d_mode_dc,
     delay_lclkr_dc             => delay_lclkr_dc(4 to 4),
     mpw1_dc_b                  => mpw1_dc_b(4 to 4),
     mpw2_dc_b                  => mpw2_dc_b,
     g6t_clkoff_dc_b            => g6t_clkoff_dc_b,
     g6t_d_mode_dc              => g6t_d_mode_dc,
     g6t_delay_lclkr_dc         => g6t_delay_lclkr_dc,
     g6t_mpw1_dc_b              => g6t_mpw1_dc_b,
     g6t_mpw2_dc_b              => g6t_mpw2_dc_b,
     sg_2                       => sg_2(2),
     fce_2                      => fce_2(0),
     func_sl_thold_2            => func_sl_thold_2(3),
     func_nsl_thold_2           => func_nsl_thold_2,
     abst_sl_thold_2            => abst_sl_thold_2,
     time_sl_thold_2            => time_sl_thold_2,
     ary_nsl_thold_2            => ary_nsl_thold_2,
     repr_sl_thold_2            => repr_sl_thold_2,
     bolt_sl_thold_2            => bolt_sl_thold_2,
     bo_enable_2                => bo_enable_2,
     an_ac_scan_dis_dc_b        => an_ac_scan_dis_dc_b,
     an_ac_scan_diag_dc         => an_ac_scan_diag_dc,

     -- G6T ABIST Control
     an_ac_lbist_ary_wrt_thru_dc => an_ac_lbist_ary_wrt_thru_dc,
     pc_xu_abist_ena_dc         => pc_xu_abist_ena_dc,
     pc_xu_abist_g6t_bw         => pc_xu_abist_g6t_bw,
     pc_xu_abist_di_g6t_2r      => pc_xu_abist_di_g6t_2r,
     pc_xu_abist_wl512_comp_ena => pc_xu_abist_wl512_comp_ena,
     pc_xu_abist_raw_dc_b       => pc_xu_abist_raw_dc_b,
     pc_xu_abist_dcomp_g6t_2r   => pc_xu_abist_dcomp_g6t_2r,
     pc_xu_abist_raddr_0        => pc_xu_abist_raddr_0(1 to 9),
     pc_xu_abist_g6t_r_wb       => pc_xu_abist_g6t_r_wb,
     pc_xu_bo_unload            => pc_xu_bo_unload,
     pc_xu_bo_repair            => pc_xu_bo_repair,
     pc_xu_bo_reset             => pc_xu_bo_reset,
     pc_xu_bo_shdata            => pc_xu_bo_shdata,
     pc_xu_bo_select            => pc_xu_bo_select(5 to 6),
     xu_pc_bo_fail              => xu_pc_bo_fail(5 to 6),
     xu_pc_bo_diagout           => xu_pc_bo_diagout(5 to 6),

     -- SCAN PORTS
     abst_scan_in(0)            => abst_scan_in(1),
     abst_scan_in(1)            => dat_abst_scan_in,
     abst_scan_out(0)           => dat_abst_scan_in,
     abst_scan_out(1)           => abst_scan_out(1),

     time_scan_in               => dat_time_scan_in,
     repr_scan_in               => repr_scan_in,
     time_scan_out              => time_scan_out,
     repr_scan_out              => repr_scan_out,
     func_scan_in               => func_scan_in(1 to 3),
     func_scan_out              => func_scan_out(1 to 3)
);

rel_xu_ld_data <= rel_xu_ld_data_int(64-(2**regmode) to 63);

mark_unused(sg_2(1));
mark_unused(func_sl_thold_2(1 to 2));

end xuq_fxua_data;
