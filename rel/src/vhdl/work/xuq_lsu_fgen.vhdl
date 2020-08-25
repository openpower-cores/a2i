-- © IBM Corp. 2020
-- This softcore is licensed under and subject to the terms of the CC-BY 4.0
-- license (https://creativecommons.org/licenses/by/4.0/legalcode). 
-- Additional rights, including the right to physically implement a softcore 
-- that is compliant with the required sections of the Power ISA 
-- Specification, will be available at no cost via the OpenPOWER Foundation. 
-- This README will be updated with additional information when OpenPOWER's 
-- license is available.

--  Description:  XU LSU Flush Generation
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
-- 1) Reload Flush generation
-- 2) Back-Invalidate Flush generation
-- 4) Instruction Flush Handling
-- ##########################################################################################

entity xuq_lsu_fgen is
generic(expand_type     : integer := 2;		-- 0 = ibm (Umbra), 1 = non-ibm, 2 = ibm (MPG)
	real_data_add	: integer := 42);	-- 42 bit real address
port(

     -- Execution Pipe
     ex2_cache_acc              :in  std_ulogic;                        -- Cache Access is Valid in EX2
     ex2_ldst_fexcpt            :in  std_ulogic;                        -- Force Exception on misaligned AXU access
     ex2_mv_reg_op              :in  std_ulogic;
     ex2_axu_op                 :in  std_ulogic;                        -- EX2 AXU operation is valid
     rf1_thrd_id                :in  std_ulogic_vector(0 to 3);         -- Thread Id in EX1
     ex1_thrd_id                :in  std_ulogic_vector(0 to 3);         -- Thread Id in EX1
     ex2_thrd_id                :in  std_ulogic_vector(0 to 3);         -- Thread Id in EX2
     ex3_thrd_id                :in  std_ulogic_vector(0 to 3);         -- Thread Id in EX3
     ex4_thrd_id                :in  std_ulogic_vector(0 to 3);         -- Thread Id in EX4
     ex5_thrd_id                :in  std_ulogic_vector(0 to 3);         -- Thread Id in EX5
     ex2_optype32               :in  std_ulogic;                        -- Operation is 32 Byte Access
     ex2_optype16               :in  std_ulogic;                        -- Operation is 16 Byte Access
     ex2_optype8                :in  std_ulogic;                        -- Operation is 8 Byte Access
     ex2_optype4                :in  std_ulogic;                        -- Operation is 4 Byte Access
     ex2_optype2                :in  std_ulogic;                        -- Operation is 2 Byte Access
     -- Physical Address in EX2
     ex2_p_addr_lwr             :in  std_ulogic_vector(57 to 63);
     ex2_icswx_type             :in  std_ulogic; 
     ex2_store_instr            :in  std_ulogic;                        -- STORE instruction is valid in EX2
     ex2_load_instr             :in  std_ulogic;                        -- LOAD instruction is valid in EX2
     ex2_dcbz_instr             :in  std_ulogic;                        -- DCBZ instruction is valid in EX2
     ex2_lock_instr             :in  std_ulogic;                        -- lwarx, ldarx, stwcx, and stdcx operations
     ex2_ldawx_instr            :in  std_ulogic;                        -- ldawx operation
     ex2_lm_dep_hit             :in  std_ulogic;                        -- Sources for Op match target in loadmiss queue
     ex3_lsq_flush              :in  std_ulogic;                        -- Store Q full or I=G=1 Flush
     derat_xu_ex3_noop_touch    :in  std_ulogic_vector(0 to 3);
     ex3_wimge_w_bit            :in  std_ulogic;                        -- WIMG bits in EX3
     ex3_wimge_i_bit            :in  std_ulogic;                        -- WIMG bits in EX3
     ex3_targ_match_b1          :in  std_ulogic;                        -- Ex4 Target matched with a load in EX3
     ex2_targ_match_b2          :in  std_ulogic;                        -- Ex5 Target matched with a load in EX3

     -- D$ Parity Error Detected
     ex3_cClass_collision       :in  std_ulogic;                        -- Thread Collision with same Congruence Class and Way
     ex2_lockwatchSet_rel_coll  :in  std_ulogic;                        -- DCBT[ST]LS or WatchSet instruction collided with Reload Clear Stage
     ex3_wclr_all_flush         :in  std_ulogic;                        -- Watch clear all in pipe flushing other threads in pipe

     xu_lsu_spr_xucr0_aflsta    :in  std_ulogic;
     xu_lsu_spr_xucr0_flsta     :in  std_ulogic;
     xu_lsu_spr_xucr0_l2siw     :in  std_ulogic;

     -- L2 Operation Flush
     ldq_rel_ci                 :in  std_ulogic;                        -- Cache-Inhibited Reload is Valid
     ldq_rel_axu_val            :in  std_ulogic;                        -- Reload is for a Vector Register
     
     -- Instruction Flush
     xu_lsu_rf1_flush           :in  std_ulogic_vector(0 to 3);
     xu_lsu_ex1_flush           :in  std_ulogic_vector(0 to 3);
     xu_lsu_ex2_flush           :in  std_ulogic_vector(0 to 3);
     xu_lsu_ex3_flush           :in  std_ulogic_vector(0 to 3);
     xu_lsu_ex4_flush           :in  std_ulogic_vector(0 to 3);
     xu_lsu_ex5_flush           :in  std_ulogic_vector(0 to 3);

     -- Flush Pipe Outputs
     rf1_stg_flush              :out std_ulogic;                        -- Flush Instructions in RF1
     ex1_stg_flush              :out std_ulogic;                        -- Flush Instructions in EX1
     ex2_stg_flush              :out std_ulogic;                        -- Flush Instructions in EX2
     ex3_stg_flush              :out std_ulogic;                        -- Flush Instructions in EX3
     ex4_stg_flush              :out std_ulogic;                        -- Flush Instructions in EX4
     ex5_stg_flush              :out std_ulogic;                        -- Flush Instructions in EX5
     ex3_excp_det               :out std_ulogic;                        -- Any Exception was detected
     lsu_xu_ex3_dep_flush       :out std_ulogic;                        -- RAW/WAW Dependency Flush
     lsu_xu_ex3_n_flush_req     :out std_ulogic;                        -- Data Cache Instruction Flush in EX3

     -- Performance Events
     lsu_xu_perf_events         :out std_ulogic_vector(0 to 3);

     -- Interrupt Generation
     lsu_xu_ex3_align           :out std_ulogic_vector(0 to 3);         
     lsu_xu_ex3_dsi             :out std_ulogic_vector(0 to 3);         
     lsu_xu_ex3_inval_align_2ucode :out std_ulogic;

     -- Debug Data
     dc_fgen_dbg_data           :out std_ulogic_vector(0 to 1);
           
     --pervasive
     vdd                        :inout power_logic;
     gnd                        :inout power_logic;
     nclk                       :in  clk_logic;
     sg_0                       :in  std_ulogic;
     func_sl_thold_0_b          :in  std_ulogic;
     func_sl_force              :in  std_ulogic;
     func_nsl_thold_0_b         :in  std_ulogic;
     func_nsl_force             :in  std_ulogic;
     d_mode_dc                  :in  std_ulogic;
     delay_lclkr_dc             :in  std_ulogic;
     mpw1_dc_b                  :in  std_ulogic;
     mpw2_dc_b                  :in  std_ulogic;
     scan_in                    :in  std_ulogic;
     scan_out                   :out std_ulogic
);
-- synopsys translate_off
-- synopsys translate_on
end xuq_lsu_fgen;
----
architecture xuq_lsu_fgen of xuq_lsu_fgen is

----------------------------
-- components
----------------------------

----------------------------
-- constants
----------------------------

constant ex3_flush_cond_offset          :natural := 0;
constant ex3_valid_lock_offset          :natural := ex3_flush_cond_offset + 1;
constant ex3_prealign_int_offset        :natural := ex3_valid_lock_offset + 1;
constant ex3_prealign_int_ld_offset     :natural := ex3_prealign_int_offset + 1;
constant ex3_preflush_2ucode_offset     :natural := ex3_prealign_int_ld_offset + 1;
constant ex3_preflush_2ucode_ld_offset  :natural := ex3_preflush_2ucode_offset + 1;
constant rel_is_ci_offset               :natural := ex3_preflush_2ucode_ld_offset + 1;
constant rel_is_axu_offset              :natural := rel_is_ci_offset + 1;
constant ex3_is_dcbz_offset             :natural := rel_is_axu_offset + 1;
constant ex5_misalign_flush_offset      :natural := ex3_is_dcbz_offset + 1;
constant spr_xucr0_aflsta_offset        :natural := ex5_misalign_flush_offset + 1;
constant spr_xucr0_flsta_offset         :natural := spr_xucr0_aflsta_offset + 1;
constant spr_xucr0_l2siw_offset         :natural := spr_xucr0_flsta_offset + 1;
constant ex3_dep_flush_offset           :natural := spr_xucr0_l2siw_offset + 1;
constant ex5_dep_flush_offset           :natural := ex3_dep_flush_offset + 1;
constant ex3_rel_collision_offset       :natural := ex5_dep_flush_offset + 1;
constant ex5_rel_collision_offset       :natural := ex3_rel_collision_offset + 1;
constant ex5_cClass_collision_offset    :natural := ex5_rel_collision_offset + 1;
constant scan_right                     :natural := ex5_cClass_collision_offset + 1 - 1;

----------------------------
-- signals
----------------------------
signal optype32                 :std_ulogic;
signal optype16                 :std_ulogic;
signal optype8                  :std_ulogic;
signal optype4                  :std_ulogic;
signal optype2                  :std_ulogic;
signal ex2_32Bop32_unal         :std_ulogic;
signal ex2_32Bop16_unal         :std_ulogic;
signal ex2_32Bop8_unal          :std_ulogic;
signal ex2_32Bop4_unal          :std_ulogic;
signal ex2_32Bop2_unal          :std_ulogic;
signal ex2_32Bunal_op           :std_ulogic;
signal ex2_32Bop16_unal_ld      :std_ulogic;
signal ex2_32Bop8_unal_ld       :std_ulogic;
signal ex2_32Bop4_unal_ld       :std_ulogic;
signal ex2_32Bop2_unal_ld       :std_ulogic;
signal ex2_unal_ld_op           :std_ulogic;
signal ex2_is_store             :std_ulogic;
signal ex2_is_load              :std_ulogic;
signal ex2_phy_addr             :std_ulogic_vector(57 to 63);
signal rf1_th_id                :std_ulogic_vector(0 to 3);
signal ex1_th_id                :std_ulogic_vector(0 to 3);
signal ex2_th_id                :std_ulogic_vector(0 to 3);
signal ex3_th_id                :std_ulogic_vector(0 to 3);
signal ex4_th_id                :std_ulogic_vector(0 to 3);
signal ex5_th_id                :std_ulogic_vector(0 to 3);
signal ex2_is_lock              :std_ulogic;
signal wt_ci_trans              :std_ulogic;
signal ex2_valid_lock           :std_ulogic;
signal rf1_if_flush_val         :std_ulogic;
signal ex1_if_flush_val         :std_ulogic;
signal ex2_if_flush_val         :std_ulogic;
signal ex3_if_flush_val         :std_ulogic;
signal ex4_if_flush_val         :std_ulogic;
signal ex5_if_flush_val         :std_ulogic;
signal ex3_flush_cond_d         :std_ulogic;
signal ex3_flush_cond_q         :std_ulogic;
signal ex2_rel_val_flush        :std_ulogic;
signal ex2_rel_collision        :std_ulogic;
signal ex3_rel_collision_d      :std_ulogic;
signal ex3_rel_collision_q      :std_ulogic;
signal ex4_rel_collision_d      :std_ulogic;
signal ex4_rel_collision_q      :std_ulogic;
signal ex5_rel_collision_d      :std_ulogic;
signal ex5_rel_collision_q      :std_ulogic;
signal ex6_rel_collision_d      :std_ulogic;
signal ex6_rel_collision_q      :std_ulogic;
signal ex2_is_dcbz              :std_ulogic;
signal ex3_valid_lock_d         :std_ulogic;
signal ex3_valid_lock_q         :std_ulogic;
signal ex3_prealign_int_d       :std_ulogic;
signal ex3_prealign_int_q       :std_ulogic;
signal ex3_prealign_int_ld_d    :std_ulogic;
signal ex3_prealign_int_ld_q    :std_ulogic;
signal force_align_int          :std_ulogic;
signal ex3_flush_2ucode         :std_ulogic;
signal ex3_preflush_2ucode_d    :std_ulogic;
signal ex3_preflush_2ucode_q    :std_ulogic;
signal ex3_preflush_2ucode_ld_d :std_ulogic;
signal ex3_preflush_2ucode_ld_q :std_ulogic;
signal interface_16B            :std_ulogic;
signal ex2_waw_haz              :std_ulogic;
signal ex2_raw_haz              :std_ulogic;
signal force_align_int_a        :std_ulogic;
signal force_align_int_x        :std_ulogic;
signal ex2_op32_unal            :std_ulogic;
signal ex2_op16_unal            :std_ulogic;
signal ex2_op8_unal             :std_ulogic;
signal ex2_op4_unal             :std_ulogic;
signal ex2_op2_unal             :std_ulogic;
signal ex2_unal_op              :std_ulogic;
signal ex3_resrc_collision      :std_ulogic;
signal ex3_dir_collision        :std_ulogic;
signal rel_is_ci_d              :std_ulogic;
signal rel_is_ci_q              :std_ulogic;
signal rel_is_axu_d             :std_ulogic;
signal rel_is_axu_q             :std_ulogic;
signal rel_ci_st_collision      :std_ulogic;
signal rel_ci_ld_collision      :std_ulogic;
signal ex4_misalign_flush_d     :std_ulogic;
signal ex4_misalign_flush_q     :std_ulogic;
signal ex5_misalign_flush_d     :std_ulogic;
signal ex5_misalign_flush_q     :std_ulogic;
signal ex6_misalign_flush_d     :std_ulogic;
signal ex6_misalign_flush_q     :std_ulogic;
signal spr_xucr0_aflsta_d       :std_ulogic;
signal spr_xucr0_aflsta_q       :std_ulogic;
signal spr_xucr0_flsta_d        :std_ulogic;
signal spr_xucr0_flsta_q        :std_ulogic;
signal spr_xucr0_l2siw_d        :std_ulogic;
signal spr_xucr0_l2siw_q        :std_ulogic;
signal ex3_noop_touch           :std_ulogic;
signal ex3_dep_flush            :std_ulogic;
signal ex3_dep_flush_d          :std_ulogic;
signal ex3_dep_flush_q          :std_ulogic;
signal ex4_dep_flush_d          :std_ulogic;
signal ex4_dep_flush_q          :std_ulogic;
signal ex5_dep_flush_d          :std_ulogic;
signal ex5_dep_flush_q          :std_ulogic;
signal ex6_dep_flush_d          :std_ulogic;
signal ex6_dep_flush_q          :std_ulogic;
signal ex3_n_flush_rq_b         :std_ulogic;
signal ex3_n_flush_rq           :std_ulogic;
signal ex4_n_flush_rq_d         :std_ulogic;
signal ex4_n_flush_rq_q         :std_ulogic;
signal ex2_icswx_unal           :std_ulogic;
signal ex3_is_dcbz_d            :std_ulogic;
signal ex3_is_dcbz_q            :std_ulogic;
signal ex3_dsi_int              :std_ulogic;
signal ex3_align_int            :std_ulogic;
signal ex3_dcbz_err             :std_ulogic;
signal ex2_store_cross          :std_ulogic;
signal ex4_cClass_collision_d   :std_ulogic;
signal ex4_cClass_collision_q   :std_ulogic;
signal ex5_cClass_collision_d   :std_ulogic;
signal ex5_cClass_collision_q   :std_ulogic;
signal ex6_cClass_collision_d   :std_ulogic;
signal ex6_cClass_collision_q   :std_ulogic;
signal ex3_n_flush_oth1_b       :std_ulogic;
signal ex3_n_flush_oth1         :std_ulogic;

signal tiup                     :std_ulogic;
signal siv                      :std_ulogic_vector(0 to scan_right);
signal sov                      :std_ulogic_vector(0 to scan_right);



begin

-- #############################################
-- Inputs
-- #############################################
tiup <= '1';

ex3_noop_touch <= or_reduce(derat_xu_ex3_noop_touch);
ex2_phy_addr   <= ex2_p_addr_lwr;

optype32 <= ex2_optype32;
optype16 <= ex2_optype16;
optype8  <= ex2_optype8;
optype4  <= ex2_optype4;
optype2  <= ex2_optype2;

ex2_is_load   <= ex2_load_instr;
ex2_is_store  <= ex2_store_instr;
ex2_is_dcbz   <= ex2_dcbz_instr;
ex2_is_lock   <= ex2_lock_instr;
ex3_is_dcbz_d <= ex2_is_dcbz and ex2_cache_acc and not ex2_if_flush_val;

rf1_th_id <= rf1_thrd_id;
ex1_th_id <= ex1_thrd_id;
ex2_th_id <= ex2_thrd_id;
ex3_th_id <= ex3_thrd_id;
ex4_th_id <= ex4_thrd_id;
ex5_th_id <= ex5_thrd_id;

ex2_waw_haz <= ex2_targ_match_b2;
ex2_raw_haz <= ex2_lm_dep_hit;

rel_is_ci_d          <= ldq_rel_ci;
rel_is_axu_d         <= ldq_rel_axu_val;
rel_ci_st_collision  <= rel_is_ci_q and (((ex2_is_store or ex2_icswx_type) and ex2_cache_acc) or ex2_mv_reg_op);
rel_ci_ld_collision  <= rel_is_ci_q and rel_is_axu_q and ex2_is_load and ex2_axu_op and ex2_cache_acc;

spr_xucr0_aflsta_d <= xu_lsu_spr_xucr0_aflsta;
spr_xucr0_flsta_d  <= xu_lsu_spr_xucr0_flsta;
spr_xucr0_l2siw_d  <= xu_lsu_spr_xucr0_l2siw;

-- XUCR[FLSTA] = '0' =>  Flush to ucode
-- XUCR[FLSTA] = '1' =>  Flush to Alignment Interrupt
-- XUCR[AFLSTA] = '0' =>  Flush to ucode (AXUop)
-- XUCR[AFLSTA] = '1' =>  Flush to Alignment Interrupt (AXUop)
force_align_int_a <= ex2_cache_acc and     ex2_axu_op and (spr_xucr0_aflsta_q or ex2_ldst_fexcpt);
force_align_int_x <= ex2_cache_acc and not ex2_axu_op and spr_xucr0_flsta_q;
force_align_int   <= force_align_int_x or force_align_int_a or ex2_is_lock or ex2_ldawx_instr;

-- This needs to be tied to XUCR[L2SIW] <<<<temp
-- XUCR[L2SIW] = '0' => 16B L2 interface
-- XUCR[L2SIW] = '1' => 32B L2 interface
interface_16B <= not spr_xucr0_l2siw_q;

-- XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
-- Exception Calculations
-- XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

-- Operation translated to either Write-Through or Cache-Inhibited
wt_ci_trans <= ex3_wimge_w_bit or ex3_wimge_i_bit;

-- ################################################################################################################
-- Alignment Interrupt
-- 1) Operand of a floating-point Load/Store is not word-aligned or crosses a virtual page boundary
-- 2) lq,stq,lmw,stmw,lwarx,ldarx,stwcx,stdcx,eciwx, or ecowx is not aligned
-- 3) load/store is not aligned and in Little-Endian mode
-- 4) lq,stq,lmw,stmw,lswi,lswx,stswi or stswx translates to write through required, cache-inhibited, or in Little Endian
-- 5) load/store crosses a segment boundary or crosses a boundary between virtual pages that have different storage control attributes
-- 6) load/store is not aligned and translates to write through or cache-inhibit
-- 7) dcbz,lwarx,ldarx,stwcx, or stdcx translates to write through required or cache-inhibit
-- ################################################################################################################

-- ########################
-- Unaligned Operation crossing the operand's size
-- ########################
-- Crossing the Operand Size boundary, only used to determine alignment interrupt if FLSTA = 1 or is_lock_instruction
ex2_op32_unal <= optype32 and (ex2_phy_addr(59) or ex2_phy_addr(60) or ex2_phy_addr(61) or ex2_phy_addr(62) or ex2_phy_addr(63));
ex2_op16_unal <= optype16 and (ex2_phy_addr(60) or ex2_phy_addr(61) or ex2_phy_addr(62) or ex2_phy_addr(63));
ex2_op8_unal  <= optype8  and (ex2_phy_addr(61) or ex2_phy_addr(62) or ex2_phy_addr(63));
ex2_op4_unal  <= optype4  and (ex2_phy_addr(62) or ex2_phy_addr(63));
ex2_op2_unal  <= optype2  and  ex2_phy_addr(63);
ex2_unal_op   <= ex2_op32_unal or ex2_op16_unal or ex2_op8_unal or ex2_op4_unal or ex2_op2_unal;
-- ########################

-- ########################
-- Unaligned ICSWX crossing the 64Byte boundary
-- ########################
-- icswx crossing the 128 byte boundary
ex2_icswx_unal <= ex2_icswx_type and or_reduce(ex2_phy_addr);

-- ########################
-- Unaligned Store crossing a 16 Byte boundary in 16B L2 interface mode or cache-inhibited load
-- ########################
ex2_store_cross <= interface_16B and ex2_is_store;

-- ########################
-- Unaligned Operation crossing a 32 Byte boundary
-- ########################
ex2_32Bop32_unal <= optype32 and                    (ex2_phy_addr(59)    or ex2_phy_addr(60)  or  ex2_phy_addr(61)  or  ex2_phy_addr(62)  or ex2_phy_addr(63));
ex2_32Bop16_unal <= optype16 and (ex2_store_cross or ex2_phy_addr(59)) and (ex2_phy_addr(60)  or  ex2_phy_addr(61)  or  ex2_phy_addr(62)  or ex2_phy_addr(63));
ex2_32Bop8_unal  <= optype8  and (ex2_store_cross or ex2_phy_addr(59)) and  ex2_phy_addr(60) and (ex2_phy_addr(61)  or  ex2_phy_addr(62)  or ex2_phy_addr(63));
ex2_32Bop4_unal  <= optype4  and (ex2_store_cross or ex2_phy_addr(59)) and  ex2_phy_addr(60) and  ex2_phy_addr(61) and (ex2_phy_addr(62)  or ex2_phy_addr(63));
ex2_32Bop2_unal  <= optype2  and (ex2_store_cross or ex2_phy_addr(59)) and  ex2_phy_addr(60) and  ex2_phy_addr(61) and  ex2_phy_addr(62) and ex2_phy_addr(63);
ex2_32Bunal_op   <= ex2_32Bop32_unal or ex2_32Bop16_unal or ex2_32Bop8_unal or ex2_32Bop4_unal or ex2_32Bop2_unal;

-- Potential Unaligned Cache-Inhibited Load Crossing the 16Byte boundary
ex2_32Bop16_unal_ld <= optype16 and ex2_is_load and (ex2_phy_addr(60)  or  ex2_phy_addr(61)  or  ex2_phy_addr(62)  or ex2_phy_addr(63));
ex2_32Bop8_unal_ld  <= optype8  and ex2_is_load and  ex2_phy_addr(60) and (ex2_phy_addr(61)  or  ex2_phy_addr(62)  or ex2_phy_addr(63));
ex2_32Bop4_unal_ld  <= optype4  and ex2_is_load and  ex2_phy_addr(60) and  ex2_phy_addr(61) and (ex2_phy_addr(62)  or ex2_phy_addr(63));
ex2_32Bop2_unal_ld  <= optype2  and ex2_is_load and  ex2_phy_addr(60) and  ex2_phy_addr(61) and  ex2_phy_addr(62) and ex2_phy_addr(63);
ex2_unal_ld_op      <= ex2_32Bop16_unal_ld or ex2_32Bop8_unal_ld or ex2_32Bop4_unal_ld or ex2_32Bop2_unal_ld;

-- Flush to uCode if ucode supports unalignment
ex3_preflush_2ucode_d    <= (not (ex2_is_lock or ex2_ldawx_instr or ex2_icswx_type)) and ex2_32Bunal_op and ex2_cache_acc and not ex2_if_flush_val;
ex3_preflush_2ucode_ld_d <= (not (ex2_is_lock or ex2_ldawx_instr or ex2_icswx_type)) and ex2_unal_ld_op and ex2_cache_acc and not ex2_if_flush_val;
ex3_flush_2ucode         <= ex3_preflush_2ucode_q or (ex3_preflush_2ucode_ld_q and ex3_wimge_i_bit);

-- Alignment Interrupt Collected
ex3_prealign_int_d    <= (ex2_icswx_unal or (force_align_int and (ex2_unal_op or ex2_32Bunal_op))) and ex2_cache_acc and not ex2_if_flush_val;
ex3_prealign_int_ld_d <= force_align_int and ex2_unal_ld_op and ex2_cache_acc and not ex2_if_flush_val;

-- DCBZ translated to Write-Through or Cache-Inhibited.
ex3_dcbz_err  <= ex3_is_dcbz_q and wt_ci_trans;
ex3_align_int <= ex3_prealign_int_q or (ex3_prealign_int_ld_q and ex3_wimge_i_bit) or ex3_dcbz_err;
-- ########################

ex4_misalign_flush_d <= ex3_flush_2ucode or ex3_prealign_int_q or (ex3_prealign_int_ld_q and ex3_wimge_i_bit);
ex5_misalign_flush_d <= ex4_misalign_flush_q;
ex6_misalign_flush_d <= ex5_misalign_flush_q;
-- ################################################################################################################

-- ################################################################################################################
-- Data Storage Interrupt
-- 2) lq,stq,lwarx,ldarx,stwcx, or stdcx translate to write through required or cache-inhibit
-- 3) the access violates the storage protection
-- 4) Data Address Compare matches address or Data Address Breakpoint match occurs
-- 5) eciwx or ecowx is not allowed by EAR[E]=0
-- ################################################################################################################

-- ########################
-- Invalid Write-Through or Cache Inhibit Translation
-- ########################

-- lwarx,ldarx,stwcx,stdcx translate to write-through or cache-inhibit
ex2_valid_lock <= ex2_is_lock and ex2_cache_acc and not ex2_if_flush_val;

ex3_valid_lock_d <= ex2_valid_lock;
ex3_dsi_int      <= ex3_valid_lock_q and wt_ci_trans;
-- ################################################################################################################

ex3_dep_flush_d <= (ex2_raw_haz or ex2_waw_haz) and not ex2_if_flush_val;
ex3_dep_flush   <= ex3_dep_flush_q or ex3_targ_match_b1;
ex4_dep_flush_d <= ex3_dep_flush;
ex5_dep_flush_d <= ex4_dep_flush_q;
ex6_dep_flush_d <= ex5_dep_flush_q;

-- Any Exception detected, Need to block Touch Op if an exception was detected
ex3_excp_det <= ex3_noop_touch;

-- #############################################
-- FLUSH CONDITIONS
-- #############################################

-- RF1 Instruction Flush
rf1_if_flush_val <= (xu_lsu_rf1_flush(0) and rf1_th_id(0)) or
                    (xu_lsu_rf1_flush(1) and rf1_th_id(1)) or
                    (xu_lsu_rf1_flush(2) and rf1_th_id(2)) or
                    (xu_lsu_rf1_flush(3) and rf1_th_id(3));

-- EX1 Instruction Flush
ex1_if_flush_val <= (xu_lsu_ex1_flush(0) and ex1_th_id(0)) or
                    (xu_lsu_ex1_flush(1) and ex1_th_id(1)) or
                    (xu_lsu_ex1_flush(2) and ex1_th_id(2)) or
                    (xu_lsu_ex1_flush(3) and ex1_th_id(3));

-- EX2 Instruction Flush
ex2_if_flush_val <= (xu_lsu_ex2_flush(0) and ex2_th_id(0)) or
                    (xu_lsu_ex2_flush(1) and ex2_th_id(1)) or
                    (xu_lsu_ex2_flush(2) and ex2_th_id(2)) or
                    (xu_lsu_ex2_flush(3) and ex2_th_id(3));

-- EX3 Instruction Flush
ex3_if_flush_val <= (xu_lsu_ex3_flush(0) and ex3_th_id(0)) or
                    (xu_lsu_ex3_flush(1) and ex3_th_id(1)) or
                    (xu_lsu_ex3_flush(2) and ex3_th_id(2)) or
                    (xu_lsu_ex3_flush(3) and ex3_th_id(3));

-- EX4 Instruction Flush
ex4_if_flush_val <= (xu_lsu_ex4_flush(0) and ex4_th_id(0)) or
                    (xu_lsu_ex4_flush(1) and ex4_th_id(1)) or
                    (xu_lsu_ex4_flush(2) and ex4_th_id(2)) or
                    (xu_lsu_ex4_flush(3) and ex4_th_id(3));

-- EX5 Instruction Flush
ex5_if_flush_val <= (xu_lsu_ex5_flush(0) and ex5_th_id(0)) or
                    (xu_lsu_ex5_flush(1) and ex5_th_id(1)) or
                    (xu_lsu_ex5_flush(2) and ex5_th_id(2)) or
                    (xu_lsu_ex5_flush(3) and ex5_th_id(3));

--xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
-- Reload Flush Conditions
--xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
ex2_rel_val_flush   <= rel_ci_st_collision or rel_ci_ld_collision or ex2_lockwatchSet_rel_coll;
ex2_rel_collision   <= ex2_rel_val_flush and not ex2_if_flush_val;
ex3_rel_collision_d <= ex2_rel_collision;
ex4_rel_collision_d <= ex3_rel_collision_q;
ex5_rel_collision_d <= ex4_rel_collision_q;
ex6_rel_collision_d <= ex5_rel_collision_q;

--xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
-- Force L1 Load Hits to L2 Flush Conditions
--xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
--ex2_flh2l2_flush   <= (ex3_0stores_left or (ex3_1store_left and ex3_ldstq_instr)) and ex2_is_load and ex2_cache_acc and spr_xucr0_flh2l2;
--ex3_flh2l2_flush_d <= ex2_flh2l2_flush;
--ex4_flh2l2_flush_d <= ex3_flh2l2_flush_q;
--ex5_flh2l2_flush_d <= ex4_flh2l2_flush_q;
--ex6_flh2l2_flush_d <= ex5_flh2l2_flush_q;

--xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
-- RF1 Flush Stage
-- 1) Instruction Flush from FXU
--xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
rf1_stg_flush <= rf1_if_flush_val;

--xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
-- EX1 Flush Stage
-- 1) Instruction Flush from FXU
--xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
ex1_stg_flush <= ex1_if_flush_val;

--xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
-- EX2 Flush Stage
-- 1) Back-Invalidate from L2
-- 2) Reload from L2
-- 3) L1 load hit with FLH2L2 and no credits
-- 4) Instruction Flush from FXU
--xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
ex2_stg_flush <= ex2_if_flush_val;

--xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
-- EX3 Flush Stage takes into account the following
-- L1 D$ -> reload valid and D$ op comes down the pipe
-- L1 D$ -> invalidate valid and D$ op comes down the pipe
-- L1 D$ -> loadmiss queue is full and D$ op comes down the pipe
-- L1 D$ -> store queue is full and D$ op comes down the pipe
-- L1 D$ -> D$ op maps to and entry in the loadmiss queue
-- L1 D$ -> D$ op maps to and entry that will be put into the loadmiss queue
-- FXU   -> BTA miscompare flush needs to flush D$ op in EX3, this is an FXU internal flush
-- IF    -> Instruction Flush
-- WAW   -> loadmiss in EX3 with a target that matches the target of the op in EX2
-- RAW   -> Outstandin loadmiss with a target that matches the sources of the op in EX2
--xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
ex3_flush_cond_d       <= ex2_rel_collision;
ex3_resrc_collision    <= ex3_flush_cond_q;
ex3_dir_collision      <= ex3_cClass_collision or ex3_wclr_all_flush;
ex4_cClass_collision_d <= ex3_dir_collision;
ex5_cClass_collision_d <= ex4_cClass_collision_q;
ex6_cClass_collision_d <= ex5_cClass_collision_q;

ex3NFlushoth1B: ex3_n_flush_oth1_b <= not (ex3_resrc_collision or ex3_lsq_flush);
ex3NFlushoth1:  ex3_n_flush_oth1   <= not ex3_n_flush_oth1_b;
ex3NFlushRqB:   ex3_n_flush_rq_b   <= not (ex3_n_flush_oth1 or ex3_dir_collision);
ex3NFlushRq:    ex3_n_flush_rq     <= not ex3_n_flush_rq_b;

ex4_n_flush_rq_d <= ex3_n_flush_rq;

-- Shouldnt need my own flush generation in the equation
-- Completions ex5 flush should cover everything
ex3_stg_flush <= ex3_if_flush_val;

lsu_xu_ex3_n_flush_req        <= ex3_n_flush_rq;
lsu_xu_ex3_inval_align_2ucode <= ex3_flush_2ucode and not ex3_flush_cond_q;
lsu_xu_ex3_dep_flush          <= ex3_dep_flush;
lsu_xu_ex3_dsi                <= gate(ex3_th_id, ex3_dsi_int);
lsu_xu_ex3_align              <= gate(ex3_th_id, ex3_align_int);

-- Debug Data
dc_fgen_dbg_data              <= rel_is_ci_q & ex4_n_flush_rq_q;

-- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
-- Performance Events
-- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
lsu_xu_perf_events <= ex6_misalign_flush_q   & ex6_rel_collision_q &
                      ex6_cClass_collision_q & ex6_dep_flush_q;

--xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
-- EX4 Flush Stage takes into account the following
-- IF    -> Instruction Flush
--xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
ex4_stg_flush <= ex4_if_flush_val;

--xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
-- EX5 Flush Stage takes into account the following
-- IF    -> Instruction Flush
--xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
ex5_stg_flush <= ex5_if_flush_val;

--xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
-- Registers
--xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx

ex3_flush_cond_reg: tri_rlmlatch_p
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
            scin    => siv(ex3_flush_cond_offset),
            scout   => sov(ex3_flush_cond_offset),
            din     => ex3_flush_cond_d,
            dout    => ex3_flush_cond_q);

ex4_n_flush_rq_reg: tri_regk
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
            din(0)  => ex4_n_flush_rq_d,
            dout(0) => ex4_n_flush_rq_q);

ex3_valid_lock_reg: tri_rlmlatch_p
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
            scin    => siv(ex3_valid_lock_offset),
            scout   => sov(ex3_valid_lock_offset),
            din     => ex3_valid_lock_d,
            dout    => ex3_valid_lock_q);

ex3_prealign_int_reg: tri_rlmlatch_p
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
            scin    => siv(ex3_prealign_int_offset),
            scout   => sov(ex3_prealign_int_offset),
            din     => ex3_prealign_int_d,
            dout    => ex3_prealign_int_q);

ex3_prealign_int_ld_reg: tri_rlmlatch_p
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
            scin    => siv(ex3_prealign_int_ld_offset),
            scout   => sov(ex3_prealign_int_ld_offset),
            din     => ex3_prealign_int_ld_d,
            dout    => ex3_prealign_int_ld_q);

ex3_preflush_2ucode_reg: tri_rlmlatch_p
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
            scin    => siv(ex3_preflush_2ucode_offset),
            scout   => sov(ex3_preflush_2ucode_offset),
            din     => ex3_preflush_2ucode_d,
            dout    => ex3_preflush_2ucode_q);

ex3_preflush_2ucode_ld_reg: tri_rlmlatch_p
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
            scin    => siv(ex3_preflush_2ucode_ld_offset),
            scout   => sov(ex3_preflush_2ucode_ld_offset),
            din     => ex3_preflush_2ucode_ld_d,
            dout    => ex3_preflush_2ucode_ld_q);

rel_is_ci_reg: tri_rlmlatch_p
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
            scin    => siv(rel_is_ci_offset),
            scout   => sov(rel_is_ci_offset),
            din     => rel_is_ci_d,
            dout    => rel_is_ci_q);

rel_is_axu_reg: tri_rlmlatch_p
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
            scin    => siv(rel_is_axu_offset),
            scout   => sov(rel_is_axu_offset),
            din     => rel_is_axu_d,
            dout    => rel_is_axu_q);

ex3_is_dcbz_reg: tri_rlmlatch_p
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
            scin    => siv(ex3_is_dcbz_offset),
            scout   => sov(ex3_is_dcbz_offset),
            din     => ex3_is_dcbz_d,
            dout    => ex3_is_dcbz_q);

ex4_misalign_flush_reg: tri_regk
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
            din(0)  => ex4_misalign_flush_d,
            dout(0) => ex4_misalign_flush_q);

ex5_misalign_flush_reg: tri_rlmlatch_p
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
            scin    => siv(ex5_misalign_flush_offset),
            scout   => sov(ex5_misalign_flush_offset),
            din     => ex5_misalign_flush_d,
            dout    => ex5_misalign_flush_q);

ex6_misalign_flush_reg: tri_regk
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
            din(0)  => ex6_misalign_flush_d,
            dout(0) => ex6_misalign_flush_q);

spr_xucr0_aflsta_reg: tri_rlmlatch_p
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
            scin    => siv(spr_xucr0_aflsta_offset),
            scout   => sov(spr_xucr0_aflsta_offset),
            din     => spr_xucr0_aflsta_d,
            dout    => spr_xucr0_aflsta_q);

spr_xucr0_flsta_reg: tri_rlmlatch_p
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
            scin    => siv(spr_xucr0_flsta_offset),
            scout   => sov(spr_xucr0_flsta_offset),
            din     => spr_xucr0_flsta_d,
            dout    => spr_xucr0_flsta_q);

spr_xucr0_l2siw_reg: tri_rlmlatch_p
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
            scin    => siv(spr_xucr0_l2siw_offset),
            scout   => sov(spr_xucr0_l2siw_offset),
            din     => spr_xucr0_l2siw_d,
            dout    => spr_xucr0_l2siw_q);

ex3_dep_flush_reg: tri_rlmlatch_p
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
            scin    => siv(ex3_dep_flush_offset),
            scout   => sov(ex3_dep_flush_offset),
            din     => ex3_dep_flush_d,
            dout    => ex3_dep_flush_q);

ex4_dep_flush_reg: tri_regk
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
            din(0)  => ex4_dep_flush_d,
            dout(0) => ex4_dep_flush_q);

ex5_dep_flush_reg: tri_rlmlatch_p
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
            scin    => siv(ex5_dep_flush_offset),
            scout   => sov(ex5_dep_flush_offset),
            din     => ex5_dep_flush_d,
            dout    => ex5_dep_flush_q);

ex6_dep_flush_reg: tri_regk
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
            din(0)  => ex6_dep_flush_d,
            dout(0) => ex6_dep_flush_q);

ex3_rel_collision_reg: tri_rlmlatch_p
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
            scin    => siv(ex3_rel_collision_offset),
            scout   => sov(ex3_rel_collision_offset),
            din     => ex3_rel_collision_d,
            dout    => ex3_rel_collision_q);

ex4_rel_collision_reg: tri_regk
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
            din(0)  => ex4_rel_collision_d,
            dout(0) => ex4_rel_collision_q);

ex5_rel_collision_reg: tri_rlmlatch_p
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
            scin    => siv(ex5_rel_collision_offset),
            scout   => sov(ex5_rel_collision_offset),
            din     => ex5_rel_collision_d,
            dout    => ex5_rel_collision_q);

ex6_rel_collision_reg: tri_regk
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
            din(0)  => ex6_rel_collision_d,
            dout(0) => ex6_rel_collision_q);

ex4_cClass_collision_reg: tri_regk
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
            din(0)  => ex4_cClass_collision_d,
            dout(0) => ex4_cClass_collision_q);

ex5_cClass_collision_reg: tri_rlmlatch_p
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
            scin    => siv(ex5_cClass_collision_offset),
            scout   => sov(ex5_cClass_collision_offset),
            din     => ex5_cClass_collision_d,
            dout    => ex5_cClass_collision_q);

ex6_cClass_collision_reg: tri_regk
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
            din(0)  => ex6_cClass_collision_d,
            dout(0) => ex6_cClass_collision_q);

siv(0 to scan_right) <= sov(1 to scan_right) & scan_in;
scan_out <= sov(0);

end xuq_lsu_fgen;
