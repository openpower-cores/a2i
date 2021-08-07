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

			

library ieee, ibm;
use ieee.std_logic_1164.all;
use ibm.std_ulogic_support.all;
use ibm.std_ulogic_function_support.all;
library support;
use support.power_logic_pkg.all;
library tri;
use tri.tri_latches_pkg.all;
library work;
use work.iuq_pkg.all;

entity iuq_fxu_dep is
  generic(expand_type           : integer := 2; 
          regmode               : integer := 6;
          lmq_entries           : integer := 8); 
port(
     vdd                                : inout power_logic;
     gnd                                : inout power_logic;
     nclk                               : in  clk_logic;                        
      
     pc_iu_func_sl_thold_0_b            : in std_ulogic;
     pc_iu_sg_0                         : in std_ulogic;
     forcee : in std_ulogic;
     d_mode                             : in std_ulogic;
     delay_lclkr                        : in std_ulogic;
     mpw1_b                             : in std_ulogic;
     mpw2_b                             : in std_ulogic;
     scan_in                            : in std_ulogic;
     scan_out                           : out std_ulogic;

     pc_iu_trace_bus_enable             : in  std_ulogic;
     pc_iu_event_bus_enable             : in  std_ulogic;
     fdep_dbg_data                      : out std_ulogic_vector(0 to 21);
     fdep_perf_event                    : out std_ulogic_vector(0 to 11);



     fdec_fdep_is1_vld                  : in std_ulogic;
     fdec_fdep_is1_instr                : in std_ulogic_vector(0 to 31);
     fdec_fdep_is1_ta_vld               : in std_ulogic;
     fdec_fdep_is1_ta                   : in std_ulogic_vector(0 to 5);
     fdec_fdep_is1_s1_vld               : in std_ulogic;
     fdec_fdep_is1_s1                   : in std_ulogic_vector(0 to 5);
     fdec_fdep_is1_s2_vld               : in std_ulogic;
     fdec_fdep_is1_s2                   : in std_ulogic_vector(0 to 5);
     fdec_fdep_is1_s3_vld               : in std_ulogic;
     fdec_fdep_is1_s3                   : in std_ulogic_vector(0 to 5);
     fdec_fdep_is1_pred_update          : in std_ulogic;
     fdec_fdep_is1_pred_taken_cnt       : in std_ulogic_vector(0 to 1);
     fdec_fdep_is1_gshare               : in std_ulogic_vector(0 to 3);
     fdec_fdep_is1_UpdatesLR            : in std_ulogic;
     fdec_fdep_is1_UpdatesCR            : in std_ulogic;
     fdec_fdep_is1_UpdatesCTR           : in std_ulogic;
     fdec_fdep_is1_UpdatesXER           : in std_ulogic;
     fdec_fdep_is1_UpdatesMSR           : in std_ulogic;
     fdec_fdep_is1_UpdatesSPR           : in std_ulogic;
     fdec_fdep_is1_UsesLR               : in std_ulogic;
     fdec_fdep_is1_UsesCR               : in std_ulogic;
     fdec_fdep_is1_UsesCTR              : in std_ulogic;
     fdec_fdep_is1_UsesXER              : in std_ulogic;
     fdec_fdep_is1_UsesMSR              : in std_ulogic;
     fdec_fdep_is1_UsesSPR              : in std_ulogic;
     fdec_fdep_is1_hole_delay           : in std_ulogic_vector(0 to 2);
     fdec_fdep_is1_ld_vld               : in std_ulogic;
     fdec_fdep_is1_to_ucode             : in std_ulogic;
     fdec_fdep_is1_is_ucode             : in std_ulogic;
     fdec_fdep_is1_ifar                 : in EFF_IFAR;
     fdec_fdep_is1_error                : in std_ulogic_vector(0 to 2);
     fdec_fdep_is1_complete             : in std_ulogic_vector(0 to 4);

     fdec_fdep_is1_axu_ld_or_st         : in std_ulogic;
     fdec_fdep_is1_axu_store            : in std_ulogic;
     fdec_fdep_is1_axu_ldst_indexed     : in std_ulogic;
     fdec_fdep_is1_axu_ldst_tag         : in std_ulogic_vector(0 to 8);
     fdec_fdep_is1_axu_ldst_size        : in std_ulogic_vector(0 to 5);
     fdec_fdep_is1_axu_ldst_update      : in std_ulogic;
     fdec_fdep_is1_axu_ldst_extpid      : in std_ulogic;
     fdec_fdep_is1_axu_ldst_forcealign  : in std_ulogic;
     fdec_fdep_is1_axu_ldst_forceexcept : in std_ulogic;
     fdec_fdep_is1_axu_mftgpr           : in std_ulogic;
     fdec_fdep_is1_axu_mffgpr           : in std_ulogic;
     fdec_fdep_is1_axu_movedp          : in std_ulogic;
     fdec_fdep_is1_axu_instr_type       : in std_ulogic_vector(0 to 2);
     fdec_fdep_is1_match                : in std_ulogic;
     fdec_fdep_is1_force_ram            : in std_ulogic;
     fdec_fdep_is1_2ucode               : in std_ulogic;
     fdec_fdep_is1_2ucode_type          : in std_ulogic;


     fdep_fiss_is2_instr                : out std_ulogic_vector(0 to 31);
     fdep_fiss_is2_ta_vld               : out std_ulogic;
     fdep_fiss_is2_ta                   : out std_ulogic_vector(0 to 5);
     fdep_fiss_is2_s1_vld               : out std_ulogic;
     fdep_fiss_is2_s1                   : out std_ulogic_vector(0 to 5);
     fdep_fiss_is2_s2_vld               : out std_ulogic;
     fdep_fiss_is2_s2                   : out std_ulogic_vector(0 to 5);
     fdep_fiss_is2_s3_vld               : out std_ulogic;
     fdep_fiss_is2_s3                   : out std_ulogic_vector(0 to 5);
     fdep_fiss_is2_pred_update          : out std_ulogic;
     fdep_fiss_is2_pred_taken_cnt       : out std_ulogic_vector(0 to 1);
     fdep_fiss_is2_gshare               : out std_ulogic_vector(0 to 3);
     fdep_fiss_is2_ifar                 : out EFF_IFAR;
     fdep_fiss_is2_error                : out std_ulogic_vector(0 to 2);
     fdep_fiss_is2_axu_ld_or_st         : out std_ulogic;
     fdep_fiss_is2_axu_store            : out std_ulogic;
     fdep_fiss_is2_axu_ldst_indexed     : out std_ulogic;
     fdep_fiss_is2_axu_ldst_tag         : out std_ulogic_vector(0 to 8);
     fdep_fiss_is2_axu_ldst_size        : out std_ulogic_vector(0 to 5);
     fdep_fiss_is2_axu_ldst_update      : out std_ulogic;
     fdep_fiss_is2_axu_ldst_extpid      : out std_ulogic;
     fdep_fiss_is2_axu_ldst_forcealign  : out std_ulogic;
     fdep_fiss_is2_axu_ldst_forceexcept : out std_ulogic;
     fdep_fiss_is2_axu_mftgpr           : out std_ulogic;
     fdep_fiss_is2_axu_mffgpr           : out std_ulogic;
     fdep_fiss_is2_axu_movedp          : out std_ulogic;
     fdep_fiss_is2_axu_instr_type       : out std_ulogic_vector(0 to 2);
     fdep_fiss_is2_match                : out std_ulogic;
     fdep_fiss_is2_2ucode               : out std_ulogic;
     fdep_fiss_is2_2ucode_type          : out std_ulogic;
     fdep_fiss_is2_hole_delay           : out std_ulogic_vector(0 to 2);
     fdep_fiss_is2_to_ucode             : out std_ulogic;
     fdep_fiss_is2_is_ucode             : out std_ulogic;
     fdep_fiss_is2early_vld             : out std_ulogic;
     fdep_fiss_is1_xu_dep_hit_b         : out std_ulogic;
     fiss_fdep_is2_take                 : in std_ulogic;

     i_afd_is1_instr_v                  : in std_ulogic;
     au_iu_issue_stall                  : in std_ulogic;
     iu_au_is2_stall                    : out std_ulogic;
     au_iu_is1_dep_hit                  : in std_ulogic;
     au_iu_is1_dep_hit_b                : in std_ulogic;  
     au_iu_is2_axubusy                  : in std_ulogic;   
     iu_au_is1_hold                     : out std_ulogic;
     iu_au_is1_stall                    : out std_ulogic;
     fdep_fdec_buff_stall               : out std_ulogic;
     fdep_fdec_weak_stall               : out std_ulogic;

     xu_iu_slowspr_done                 : in std_ulogic;
     xu_iu_multdiv_done                 : in std_ulogic;
     xu_iu_loadmiss_vld			: in std_ulogic;                         
     xu_iu_loadmiss_qentry		: in std_ulogic_vector(0 to lmq_entries-1);
     xu_iu_loadmiss_target		: in std_ulogic_vector(0 to 5);
     xu_iu_loadmiss_target_type		: in std_ulogic;
     xu_iu_complete_vld                 : in std_ulogic;
     xu_iu_complete_qentry              : in std_ulogic_vector(0 to lmq_entries-1);
     xu_iu_complete_target_type         : in std_ulogic;
     xu_iu_single_instr_mode            : in std_ulogic;

     ic_fdep_load_quiesce               : in  std_ulogic;
     iu_xu_quiesce                      : out std_ulogic;

     xu_iu_membar_tid                   : in  std_ulogic;
     xu_iu_set_barr_tid                 : in  std_ulogic;
     xu_iu_larx_done_tid                : in  std_ulogic;
     an_ac_sync_ack                     : in  std_ulogic;
     ic_fdep_icbi_ack                   : in  std_ulogic;
     an_ac_stcx_complete                : in  std_ulogic;
     mm_iu_barrier_done                 : in  std_ulogic;

     spr_fdep_ll_hold                   : in  std_ulogic;
     xu_iu_spr_ccr2_en_dcr              : in  std_ulogic;
      
     xu_iu_is1_flush                    : in std_ulogic;
     xu_iu_is2_flush			: in std_ulogic;
     xu_iu_rf0_flush			: in std_ulogic;
     xu_iu_rf1_flush			: in std_ulogic;
     xu_iu_ex1_flush                    : in std_ulogic;
     xu_iu_ex2_flush                    : in std_ulogic;
     xu_iu_ex3_flush                    : in std_ulogic;
     xu_iu_ex4_flush                    : in std_ulogic;
     xu_iu_ex5_flush                    : in std_ulogic
);
end iuq_fxu_dep;
ARCHITECTURE IUQ_FXU_DEP
          OF IUQ_FXU_DEP
          IS
SIGNAL BARRIER_PT                        : STD_ULOGIC_VECTOR(1 TO 24)  := 
(OTHERS=> 'U');
SIGNAL SLOWSPR_TABLE_PT                  : STD_ULOGIC_VECTOR(1 TO 20)  := 
(OTHERS=> 'U');
SIGNAL is_bar                            : STD_ULOGIC  := 
'U';
SIGNAL is_slowspr                        : STD_ULOGIC  := 
'U';
constant is2_vld_offset                 : natural := 0;
constant is2_instr_offset               : natural := is2_vld_offset + 1;
constant is2_ta_vld_offset              : natural := is2_instr_offset + 32;
constant is2_ta_offset                  : natural := is2_ta_vld_offset + 1;
constant is2_s1_vld_offset              : natural := is2_ta_offset + 6;
constant is2_s1_offset                  : natural := is2_s1_vld_offset + 1;
constant is2_s2_vld_offset              : natural := is2_s1_offset + 6;
constant is2_s2_offset                  : natural := is2_s2_vld_offset + 1;
constant is2_s3_vld_offset              : natural := is2_s2_offset + 6;
constant is2_s3_offset                  : natural := is2_s3_vld_offset + 1;
constant is2_is_barrier_offset          : natural := is2_s3_offset + 6;
constant is2_is_slowspr_offset          : natural := is2_is_barrier_offset + 1;
constant is2_pred_update_offset         : natural := is2_is_slowspr_offset + 1;
constant is2_pred_taken_cnt_offset      : natural := is2_pred_update_offset + 1;
constant is2_gshare_offset              : natural := is2_pred_taken_cnt_offset + 2;
constant is2_hole_delay_offset          : natural := is2_gshare_offset + 4;
constant is2_to_ucode_offset            : natural := is2_hole_delay_offset +3;
constant is2_is_ucode_offset            : natural := is2_to_ucode_offset + 1;
constant is2_ifar_offset                : natural := is2_is_ucode_offset + 1;
constant is2_error_offset               : natural := is2_ifar_offset + EFF_IFAR'length;
constant is2_axu_ld_or_st_offset        : natural := is2_error_offset + 3;
constant is2_axu_store_offset           : natural := is2_axu_ld_or_st_offset + 1;
constant is2_axu_ldst_indexed_offset    : natural := is2_axu_store_offset + 1;
constant is2_axu_ldst_tag_offset        : natural := is2_axu_ldst_indexed_offset + 1;
constant is2_axu_ldst_size_offset       : natural := is2_axu_ldst_tag_offset + 9;
constant is2_axu_ldst_update_offset     : natural := is2_axu_ldst_size_offset + 6;
constant is2_axu_ldst_extpid_offset     : natural := is2_axu_ldst_update_offset + 1;
constant is2_axu_ldst_forcealign_offset : natural := is2_axu_ldst_extpid_offset + 1;
constant is2_axu_ldst_forceexcept_offset: natural := is2_axu_ldst_forcealign_offset + 1;
constant is2_axu_mftgpr_offset          : natural := is2_axu_ldst_forceexcept_offset + 1;
constant is2_axu_mffgpr_offset          : natural := is2_axu_mftgpr_offset + 1;
constant is2_axu_movedp_offset         : natural := is2_axu_mffgpr_offset + 1;
constant is2_axu_instr_type_offset      : natural := is2_axu_movedp_offset + 1;
constant is2_match_offset               : natural := is2_axu_instr_type_offset + 3;
constant is2_2ucode_offset              : natural := is2_match_offset + 1;
constant is2_2ucode_type_offset         : natural := is2_2ucode_offset + 1;
constant sp_ex3_i_nobyp_vld_offset      : natural := is2_2ucode_type_offset + 1;
constant sp_ex3_barrier_offset          : natural := sp_ex3_i_nobyp_vld_offset + 1;
constant sp_ex4_i_nobyp_vld_offset      : natural := sp_ex3_barrier_offset + 1;
constant sp_ex4_barrier_offset          : natural := sp_ex4_i_nobyp_vld_offset + 1;
constant sp_ex5_i_nobyp_vld_offset      : natural := sp_ex4_barrier_offset + 1;
constant sp_ex5_barrier_offset          : natural := sp_ex5_i_nobyp_vld_offset + 1;
constant sp_is2_offset                  : natural := sp_ex5_barrier_offset + 1;
constant sp_rf0_offset                  : natural := sp_is2_offset +21;
constant sp_rf1_offset                  : natural := sp_rf0_offset +21;
constant sp_ex1_offset                  : natural := sp_rf1_offset +21;
constant sp_ex2_offset                  : natural := sp_ex1_offset +21;
constant sp_lm_offset                   : natural := sp_ex2_offset +21;
constant barrier_offset                 : natural := sp_lm_offset +7*lmq_entries;
constant xu_barrier_offset              : natural := barrier_offset +1;
constant mult_hole_barrier_offset       : natural := xu_barrier_offset +1;
constant single_instr_mode_offset       : natural := mult_hole_barrier_offset +6;
constant quiesce_offset                 : natural := single_instr_mode_offset +1;
constant perf_event_offset              : natural := quiesce_offset +1;
constant perf_early_offset              : natural := perf_event_offset +12;
constant fdep_dbg_data_offset           : natural := perf_early_offset +12;
constant an_ac_sync_ack_offset          : natural := fdep_dbg_data_offset +22;
constant xu_iu_membar_tid_offset        : natural := an_ac_sync_ack_offset +1;
constant xu_iu_multdiv_done_offset      : natural := xu_iu_membar_tid_offset +1;
constant mm_iu_barrier_done_offset      : natural := xu_iu_multdiv_done_offset +1;
constant spr_fdep_ll_hold_offset        : natural := mm_iu_barrier_done_offset +1;
constant en_dcr_offset                  : natural := spr_fdep_ll_hold_offset +1;
constant spare_offset                   : natural := en_dcr_offset +1;
constant trace_bus_enable_offset        : natural := spare_offset + 6;
constant event_bus_enable_offset        : natural := trace_bus_enable_offset + 1;
constant scan_right                     : natural := event_bus_enable_offset + 1 - 1;
signal spare_l2                 : std_ulogic_vector(0 to 5);
signal trace_bus_enable_d                   : std_ulogic;
signal trace_bus_enable_q                   : std_ulogic;
signal event_bus_enable_d                   : std_ulogic;
signal event_bus_enable_q                   : std_ulogic;
signal siv                      : std_ulogic_vector(0 to scan_right);
signal sov                      : std_ulogic_vector(0 to scan_right);
signal tiup                     : std_ulogic;
signal tidn                     : std_ulogic;
signal unused                   : std_ulogic_vector(0 to 4);
-- synopsys translate_off
-- synopsys translate_on
signal single_instr_mode_d      : std_ulogic;
signal single_instr_mode_l2     : std_ulogic;
signal is2_vld_d                : std_ulogic;
signal is2_instr_d              : std_ulogic_vector(0 to 31);
signal is2_ta_vld_d             : std_ulogic;
signal is2_ta_d                 : std_ulogic_vector(0 to 5);
signal is2_s1_vld_d             : std_ulogic;
signal is2_s1_d                 : std_ulogic_vector(0 to 5);
signal is2_s2_vld_d             : std_ulogic;
signal is2_s2_d                 : std_ulogic_vector(0 to 5);
signal is2_s3_vld_d             : std_ulogic;
signal is2_s3_d                 : std_ulogic_vector(0 to 5);
signal is2_is_barrier_d         : std_ulogic;
signal is2_is_slowspr_d         : std_ulogic;
signal is2_pred_update_d        : std_ulogic;
signal is2_pred_taken_cnt_d     : std_ulogic_vector(0 to 1);
signal is2_gshare_d             : std_ulogic_vector(0 to 3);
signal is2_hole_delay_d         : std_ulogic_vector(0 to 2);
signal is2_to_ucode_d           : std_ulogic;
signal is2_is_ucode_d           : std_ulogic;
signal is2_ifar_d               : EFF_IFAR;
signal is2_error_d              : std_ulogic_vector(0 to 2);
signal is2_axu_ld_or_st_d       : std_ulogic;
signal is2_axu_store_d          : std_ulogic;
signal is2_axu_ldst_indexed_d   : std_ulogic;
signal is2_axu_ldst_tag_d       : std_ulogic_vector(0 to 8);
signal is2_axu_ldst_size_d      : std_ulogic_vector(0 to 5);
signal is2_axu_ldst_update_d    : std_ulogic;
signal is2_axu_ldst_extpid_d    : std_ulogic;
signal is2_axu_ldst_forcealign_d        : std_ulogic;
signal is2_axu_ldst_forceexcept_d       : std_ulogic;
signal is2_axu_mftgpr_d         : std_ulogic;
signal is2_axu_mffgpr_d         : std_ulogic;
signal is2_axu_movedp_d        : std_ulogic;
signal is2_axu_instr_type_d     : std_ulogic_vector(0 to 2);
signal is2_match_d              : std_ulogic;
signal is2_2ucode_d             : std_ulogic;
signal is2_2ucode_type_d        : std_ulogic;
signal is2_vld_L2               : std_ulogic;
signal is2_instr_L2             : std_ulogic_vector(0 to 31);
signal is2_ta_vld_L2            : std_ulogic;
signal is2_ta_L2                : std_ulogic_vector(0 to 5);
signal is2_s1_vld_L2            : std_ulogic;
signal is2_s1_L2                : std_ulogic_vector(0 to 5);
signal is2_s2_vld_L2            : std_ulogic;
signal is2_s2_L2                : std_ulogic_vector(0 to 5);
signal is2_s3_vld_L2            : std_ulogic;
signal is2_s3_L2                : std_ulogic_vector(0 to 5);
signal is2_is_barrier_L2        : std_ulogic;
signal is2_is_slowspr_L2        : std_ulogic;
signal is2_pred_update_L2       : std_ulogic;
signal is2_pred_taken_cnt_L2    : std_ulogic_vector(0 to 1);
signal is2_gshare_L2            : std_ulogic_vector(0 to 3);
signal is2_hole_delay_L2        : std_ulogic_vector(0 to 2);
signal is2_to_ucode_L2          : std_ulogic;
signal is2_is_ucode_L2          : std_ulogic;
signal is2_ifar_L2              : EFF_IFAR;
signal is2_error_L2             : std_ulogic_vector(0 to 2);
signal is2_axu_ld_or_st_L2      : std_ulogic;
signal is2_axu_store_L2         : std_ulogic;
signal is2_axu_ldst_indexed_L2  : std_ulogic;
signal is2_axu_ldst_tag_L2      : std_ulogic_vector(0 to 8);
signal is2_axu_ldst_size_L2     : std_ulogic_vector(0 to 5);
signal is2_axu_ldst_update_L2   : std_ulogic;
signal is2_axu_ldst_extpid_L2   : std_ulogic;
signal is2_axu_ldst_forcealign_L2       : std_ulogic;
signal is2_axu_ldst_forceexcept_L2      : std_ulogic;
signal is2_axu_mftgpr_L2        : std_ulogic;
signal is2_axu_mffgpr_L2        : std_ulogic;
signal is2_axu_movedp_L2       : std_ulogic;
signal is2_axu_instr_type_L2    : std_ulogic_vector(0 to 2);
signal is2_match_L2             : std_ulogic;
signal is2_2ucode_L2            : std_ulogic;
signal is2_2ucode_type_L2       : std_ulogic;
signal is1_instr_is_isync       : std_ulogic;
signal is1_instr_is_sync        : std_ulogic;
signal is1_instr_is_tlbsync     : std_ulogic;
signal RAW_dep_hit              : std_ulogic;
signal RAW_s1_hit_b             : std_ulogic;
signal RAW_s2_hit_b             : std_ulogic;
signal RAW_s3_hit_b             : std_ulogic;
signal lr_dep_hit               : std_ulogic;
signal cr_dep_hit               : std_ulogic;
signal ctr_dep_hit              : std_ulogic;
signal xer_dep_hit              : std_ulogic;
signal msr_dep_hit              : std_ulogic;
signal spr_dep_hit              : std_ulogic;
signal br_sprs_dep_hit          : std_ulogic;
signal WAW_LMQ_dep_hit          : std_ulogic;
signal WAW_LMQ_dep_hit_b        : std_ulogic;
signal single_instr_dep_hit     : std_ulogic;
signal internal_is2_stall       : std_ulogic;
signal dep_hit                  : std_ulogic;
signal dep_hit_no_stall         : std_ulogic;
signal xu_dep_hit               : std_ulogic;
signal is2_instr_is_barrier     : std_ulogic;
signal act_nonvalid             : std_ulogic;
signal sp_IS2_d                 : std_ulogic_vector(0 to 20);
signal sp_IS2_l2                : std_ulogic_vector(0 to 20);
signal sp_RF0_d                 : std_ulogic_vector(0 to 20);
signal sp_RF0_l2                : std_ulogic_vector(0 to 20);
signal sp_RF1_d                 : std_ulogic_vector(0 to 20);
signal sp_RF1_l2                : std_ulogic_vector(0 to 20);
signal sp_EX1_d                 : std_ulogic_vector(0 to 20);
signal sp_EX1_l2                : std_ulogic_vector(0 to 20);
signal sp_EX2_d                 : std_ulogic_vector(0 to 20);
signal sp_EX2_l2                : std_ulogic_vector(0 to 20);
signal sp_IS2_act               : std_ulogic;
signal sp_RF0_act               : std_ulogic;
signal sp_RF1_act               : std_ulogic;
signal sp_EX1_act               : std_ulogic;
signal sp_EX2_act               : std_ulogic;
signal sp_EX3_act               : std_ulogic;
signal sp_EX4_act               : std_ulogic;
signal sp_EX5_act               : std_ulogic;
signal sp_LM_d                  : std_ulogic_vector(0 to 7*lmq_entries-1);
signal sp_LM_l2                 : std_ulogic_vector(0 to 7*lmq_entries-1);
signal lm_shadow_pipe_vld       : std_ulogic_vector(0 to lmq_entries-1);
signal fdep_dbg_data_d          : std_ulogic_vector(0 to 21);
signal fdep_dbg_data_l2         : std_ulogic_vector(0 to 21);
signal perf_event_d             : std_ulogic_vector(0 to 11);
signal perf_event_l2            : std_ulogic_vector(0 to 11);
signal perf_early_d             : std_ulogic_vector(0 to 11);
signal perf_early_l2            : std_ulogic_vector(0 to 11);
signal perf_dep_hit             : std_ulogic;
signal perf_fdec_fdep_is1_vld   : std_ulogic;
signal perf_internal_is2_stall  : std_ulogic;
signal perf_i_afd_is1_instr_v   : std_ulogic;
signal perf_au_iu_is1_dep_hit   : std_ulogic;
signal perf_barrier_in_progress : std_ulogic;
signal perf_is2_is_slowspr_L2   : std_ulogic;
signal perf_RAW_dep_hit         : std_ulogic;
signal perf_WAW_LMQ_dep_hit     : std_ulogic;
signal perf_sync_dep_hit        : std_ulogic;
signal perf_xu_dep_hit          : std_ulogic;
signal perf_br_sprs_dep_hit     : std_ulogic;
signal isMFSPR                  : std_ulogic;
signal isMTSPR                  : std_ulogic;
signal is1_is_slowspr           : std_ulogic;
signal is1_is_barrier           : std_ulogic;
signal an_ac_sync_ack_d         : std_ulogic;
signal an_ac_sync_ack_l2        : std_ulogic;
signal xu_iu_membar_tid_d       : std_ulogic;
signal xu_iu_membar_tid_l2      : std_ulogic;
signal xu_iu_multdiv_done_d     : std_ulogic;
signal xu_iu_multdiv_done_l2    : std_ulogic;
signal mm_iu_barrier_done_d     : std_ulogic;
signal mm_iu_barrier_done_l2    : std_ulogic;
signal spr_fdep_ll_hold_d       : std_ulogic;
signal spr_fdep_ll_hold_l2      : std_ulogic;
signal is2_mult_hole_barrier    : std_ulogic;
signal mult_hole_barrier_d      : std_ulogic_vector(0 to 5);
signal mult_hole_barrier_l2     : std_ulogic_vector(0 to 5);
signal mult_hole_barrier_act    : std_ulogic;
signal xu_barrier_d             : std_ulogic;
signal xu_barrier_l2            : std_ulogic;
signal en_dcr_d                 : std_ulogic;
signal en_dcr_l2                : std_ulogic;
type PIPE_STAGE is record
  i_nobyp_vld   : std_ulogic;                                 
  i_vld         : std_ulogic;                                 
  ta_vld	: std_ulogic;                                 
  ta		: std_ulogic_vector(0 to 5);                  
  UpdatesLR     : std_ulogic;                                 
  UpdatesCR     : std_ulogic;                                 
  UPdatesCTR    : std_ulogic;                                 
  UpdatesXER    : std_ulogic;                                 
  UpdatesMSR    : std_ulogic;                                 
  UPdatesSPR    : std_ulogic;                                 
  complete      : std_ulogic_vector(0 to 4);                  
  barrier       : std_ulogic;
end record;
type SHADOW_PIPE_STAGES is (IS2, RF0, RF1, EX1, EX2);
type MACHINE is array (SHADOW_PIPE_STAGES'left to SHADOW_PIPE_STAGES'right) of PIPE_STAGE;
signal sp_d 						   : MACHINE;
signal sp_L2						   : MACHINE;
signal sp_barrier_clr               : std_ulogic;
signal sp_EX3_i_nobyp_vld_d     : std_ulogic;
signal sp_EX3_i_nobyp_vld_l2    : std_ulogic;
signal sp_EX3_barrier_d         : std_ulogic;
signal sp_EX3_barrier_l2        : std_ulogic;
signal sp_EX4_i_nobyp_vld_d     : std_ulogic;
signal sp_EX4_i_nobyp_vld_l2    : std_ulogic;
signal sp_EX4_barrier_d         : std_ulogic;
signal sp_EX4_barrier_l2        : std_ulogic;
signal sp_EX5_i_nobyp_vld_d     : std_ulogic;
signal sp_EX5_i_nobyp_vld_l2    : std_ulogic;
signal sp_EX5_barrier_d         : std_ulogic;
signal sp_EX5_barrier_l2        : std_ulogic;
type PIPE_STAGE_LM is record
  ta_vld	: std_ulogic;                                 
  ta		: std_ulogic_vector(0 to 5);                  
end record;
type MACHINE_LM is array (0 to lmq_entries-1) of PIPE_STAGE_LM;
signal sp_d_LM 						   : MACHINE_LM;
signal sp_L2_LM						   : MACHINE_LM;
signal loadmiss_qentry		: std_ulogic_vector(0 to lmq_entries-1);
signal loadmiss_target          : std_ulogic_vector(0 to 5);
signal loadmiss_complete	: std_ulogic_vector(0 to lmq_entries-1);
signal shadow_pipe_vld           : std_ulogic;
signal sync_dep_hit              : std_ulogic;
signal set_barrier               : std_ulogic;
signal clr_barrier               : std_ulogic;
signal barrier_d                 : std_ulogic;
signal barrier_L2                : std_ulogic;
signal barrier_in_progress       : std_ulogic;
signal quiesce_barrier           : std_ulogic;
subtype s2 is std_ulogic_vector(0 to 1);
subtype s15 is std_ulogic_vector(0 to 14);
signal quiesce_d                : std_ulogic;
signal quiesce_l2               : std_ulogic;
signal core64                   : std_ulogic;
signal is1_force_ram_b                  : std_ulogic;
signal is1_valid                        : std_ulogic;
signal is1_dep                          : std_ulogic;
signal is1_dep0_b                       : std_ulogic;
signal is1_dep1_b                       : std_ulogic;
signal is1_stall_b                      : std_ulogic;
signal is2_stall_b                      : std_ulogic;
signal fxu_dep0_b                       : std_ulogic;
signal fxu_dep1_b                       : std_ulogic;
signal fxu_dep_hit                      : std_ulogic;
signal fxu_dep_hit_b                    : std_ulogic;
signal is2_vld_b                        : std_ulogic;
signal fxu_iss_stall                    : std_ulogic;
signal is2_iss_stall_b                  : std_ulogic;
  BEGIN 

tiup  <=  '1';
tidn  <=  '0';
c64: if (regmode = 6) generate
begin
core64                   <=  '1';
end generate;
c32: if (regmode = 5) generate
begin
core64                   <=  '0';
end generate;
en_dcr_d                 <=  xu_iu_spr_ccr2_en_dcr;
is1_instr_is_ISYNC       <=  (fdec_fdep_is1_instr(0 to 5) = "010011") and (fdec_fdep_is1_instr(21 to 30) = "0010010110");
is1_instr_is_SYNC        <=  (fdec_fdep_is1_instr(0 to 5) = "011111") and (fdec_fdep_is1_instr(21 to 30) = "1001010110");
is1_instr_is_TLBSYNC     <=  (fdec_fdep_is1_instr(0 to 5) = "011111") and (fdec_fdep_is1_instr(21 to 30) = "1000110110");

raw_s1_cmp: entity work.iuq_fxu_dep_cmp(iuq_fxu_dep_cmp) 
port map (
     is1_v      => fdec_fdep_is1_s1_vld,

     is2_v      => sp_L2(IS2).ta_vld,
     rf0_v      => sp_L2(RF0).ta_vld,
     rf1_v      => sp_L2(RF1).ta_vld,
     ex1_v      => sp_L2(EX1).ta_vld,
     ex2_v      => sp_L2(EX2).ta_vld,
     lm0_v      => sp_L2_LM(0).ta_vld,
     lm1_v      => sp_L2_LM(1).ta_vld,
     lm2_v      => sp_L2_LM(2).ta_vld,
     lm3_v      => sp_L2_LM(3).ta_vld,
     lm4_v      => sp_L2_LM(4).ta_vld,
     lm5_v      => sp_L2_LM(5).ta_vld,
     lm6_v      => sp_L2_LM(6).ta_vld,
     lm7_v      => sp_L2_LM(7).ta_vld,

     is1_ad     => fdec_fdep_is1_s1,

     is2_ad     => sp_L2(IS2).ta,
     rf0_ad     => sp_L2(RF0).ta,
     rf1_ad     => sp_L2(RF1).ta,
     ex1_ad     => sp_L2(EX1).ta,
     ex2_ad     => sp_L2(EX2).ta,
     lm0_ad     => sp_L2_LM(0).ta,
     lm1_ad     => sp_L2_LM(1).ta,
     lm2_ad     => sp_L2_LM(2).ta,
     lm3_ad     => sp_L2_LM(3).ta,
     lm4_ad     => sp_L2_LM(4).ta,
     lm5_ad     => sp_L2_LM(5).ta,
     lm6_ad     => sp_L2_LM(6).ta,
     lm7_ad     => sp_L2_LM(7).ta,

     ad_hit_b   => RAW_s1_hit_b
);


raw_s2_cmp: entity work.iuq_fxu_dep_cmp(iuq_fxu_dep_cmp) 
port map (
     is1_v      => fdec_fdep_is1_s2_vld,

     is2_v      => sp_L2(IS2).ta_vld,
     rf0_v      => sp_L2(RF0).ta_vld,
     rf1_v      => sp_L2(RF1).ta_vld,
     ex1_v      => sp_L2(EX1).ta_vld,
     ex2_v      => sp_L2(EX2).ta_vld,
     lm0_v      => sp_L2_LM(0).ta_vld,
     lm1_v      => sp_L2_LM(1).ta_vld,
     lm2_v      => sp_L2_LM(2).ta_vld,
     lm3_v      => sp_L2_LM(3).ta_vld,
     lm4_v      => sp_L2_LM(4).ta_vld,
     lm5_v      => sp_L2_LM(5).ta_vld,
     lm6_v      => sp_L2_LM(6).ta_vld,
     lm7_v      => sp_L2_LM(7).ta_vld,

     is1_ad     => fdec_fdep_is1_s2,

     is2_ad     => sp_L2(IS2).ta,
     rf0_ad     => sp_L2(RF0).ta,
     rf1_ad     => sp_L2(RF1).ta,
     ex1_ad     => sp_L2(EX1).ta,
     ex2_ad     => sp_L2(EX2).ta,
     lm0_ad     => sp_L2_LM(0).ta,
     lm1_ad     => sp_L2_LM(1).ta,
     lm2_ad     => sp_L2_LM(2).ta,
     lm3_ad     => sp_L2_LM(3).ta,
     lm4_ad     => sp_L2_LM(4).ta,
     lm5_ad     => sp_L2_LM(5).ta,
     lm6_ad     => sp_L2_LM(6).ta,
     lm7_ad     => sp_L2_LM(7).ta,

     ad_hit_b   => RAW_s2_hit_b
);


raw_s3_cmp: entity work.iuq_fxu_dep_cmp(iuq_fxu_dep_cmp) 
port map (
     is1_v      => fdec_fdep_is1_s3_vld,

     is2_v      => sp_L2(IS2).ta_vld,
     rf0_v      => sp_L2(RF0).ta_vld,
     rf1_v      => sp_L2(RF1).ta_vld,
     ex1_v      => sp_L2(EX1).ta_vld,
     ex2_v      => sp_L2(EX2).ta_vld,
     lm0_v      => sp_L2_LM(0).ta_vld,
     lm1_v      => sp_L2_LM(1).ta_vld,
     lm2_v      => sp_L2_LM(2).ta_vld,
     lm3_v      => sp_L2_LM(3).ta_vld,
     lm4_v      => sp_L2_LM(4).ta_vld,
     lm5_v      => sp_L2_LM(5).ta_vld,
     lm6_v      => sp_L2_LM(6).ta_vld,
     lm7_v      => sp_L2_LM(7).ta_vld,

     is1_ad     => fdec_fdep_is1_s3,

     is2_ad     => sp_L2(IS2).ta,
     rf0_ad     => sp_L2(RF0).ta,
     rf1_ad     => sp_L2(RF1).ta,
     ex1_ad     => sp_L2(EX1).ta,
     ex2_ad     => sp_L2(EX2).ta,
     lm0_ad     => sp_L2_LM(0).ta,
     lm1_ad     => sp_L2_LM(1).ta,
     lm2_ad     => sp_L2_LM(2).ta,
     lm3_ad     => sp_L2_LM(3).ta,
     lm4_ad     => sp_L2_LM(4).ta,
     lm5_ad     => sp_L2_LM(5).ta,
     lm6_ad     => sp_L2_LM(6).ta,
     lm7_ad     => sp_L2_LM(7).ta,

     ad_hit_b   => RAW_s3_hit_b
);
raw_dep_nand3:  RAW_dep_hit  <=  not(RAW_s1_hit_b and RAW_s2_hit_b and RAW_s3_hit_b);
lr_dep_hit  <=   (sp_L2(IS2).i_vld and fdec_fdep_is1_UsesLR  and sp_L2(IS2).UpdatesLR) or   
               (sp_L2(RF0).i_vld and fdec_fdep_is1_UsesLR  and sp_L2(RF0).UpdatesLR) or               
               (sp_L2(RF1).i_vld and fdec_fdep_is1_UsesLR  and sp_L2(RF1).UpdatesLR) or               
               (sp_L2(EX1).i_vld and fdec_fdep_is1_UsesLR  and sp_L2(EX1).UpdatesLR) or               
               (sp_L2(EX2).i_vld and fdec_fdep_is1_UsesLR  and sp_L2(EX2).UpdatesLR);
cr_dep_hit  <=   (sp_L2(IS2).i_vld and fdec_fdep_is1_UsesCR  and sp_L2(IS2).UpdatesCR) or
               (sp_L2(RF0).i_vld and fdec_fdep_is1_UsesCR  and sp_L2(RF0).UpdatesCR) or
               (sp_L2(RF1).i_vld and fdec_fdep_is1_UsesCR  and sp_L2(RF1).UpdatesCR) or
               (sp_L2(EX1).i_vld and fdec_fdep_is1_UsesCR  and sp_L2(EX1).UpdatesCR) or
               (sp_L2(EX2).i_vld and fdec_fdep_is1_UsesCR  and sp_L2(EX2).UpdatesCR);
ctr_dep_hit  <=  (sp_L2(IS2).i_vld and fdec_fdep_is1_UsesCTR and sp_L2(IS2).UpdatesCTR) or
               (sp_L2(RF0).i_vld and fdec_fdep_is1_UsesCTR and sp_L2(RF0).UpdatesCTR) or
               (sp_L2(RF1).i_vld and fdec_fdep_is1_UsesCTR and sp_L2(RF1).UpdatesCTR) or
               (sp_L2(EX1).i_vld and fdec_fdep_is1_UsesCTR and sp_L2(EX1).UpdatesCTR) or
               (sp_L2(EX2).i_vld and fdec_fdep_is1_UsesCTR and sp_L2(EX2).UpdatesCTR);
xer_dep_hit  <=  (sp_L2(IS2).i_vld and fdec_fdep_is1_UsesXER  and sp_L2(IS2).UpdatesXER) or   
               (sp_L2(RF0).i_vld and fdec_fdep_is1_UsesXER  and sp_L2(RF0).UpdatesXER) or               
               (sp_L2(RF1).i_vld and fdec_fdep_is1_UsesXER  and sp_L2(RF1).UpdatesXER) or               
               (sp_L2(EX1).i_vld and fdec_fdep_is1_UsesXER  and sp_L2(EX1).UpdatesXER) or               
               (sp_L2(EX2).i_vld and fdec_fdep_is1_UsesXER  and sp_L2(EX2).UpdatesXER);
msr_dep_hit  <=  (sp_L2(IS2).i_vld and fdec_fdep_is1_UsesMSR  and sp_L2(IS2).UpdatesMSR) or   
               (sp_L2(RF0).i_vld and fdec_fdep_is1_UsesMSR  and sp_L2(RF0).UpdatesMSR) or               
               (sp_L2(RF1).i_vld and fdec_fdep_is1_UsesMSR  and sp_L2(RF1).UpdatesMSR) or               
               (sp_L2(EX1).i_vld and fdec_fdep_is1_UsesMSR  and sp_L2(EX1).UpdatesMSR) or               
               (sp_L2(EX2).i_vld and fdec_fdep_is1_UsesMSR  and sp_L2(EX2).UpdatesMSR);
spr_dep_hit  <=  (sp_L2(IS2).i_vld and fdec_fdep_is1_UsesSPR  and sp_L2(IS2).UpdatesSPR) or   
               (sp_L2(RF0).i_vld and fdec_fdep_is1_UsesSPR  and sp_L2(RF0).UpdatesSPR) or               
               (sp_L2(RF1).i_vld and fdec_fdep_is1_UsesSPR  and sp_L2(RF1).UpdatesSPR) or               
               (sp_L2(EX1).i_vld and fdec_fdep_is1_UsesSPR  and sp_L2(EX1).UpdatesSPR) or               
               (sp_L2(EX2).i_vld and fdec_fdep_is1_UsesSPR  and sp_L2(EX2).UpdatesSPR);
br_sprs_dep_hit  <=  lr_dep_hit or cr_dep_hit or ctr_dep_hit or xer_dep_hit or msr_dep_hit or spr_dep_hit;


waw_cmp: entity work.iuq_fxu_dep_cmp(iuq_fxu_dep_cmp) 
port map (
     is1_v      => fdec_fdep_is1_ld_vld,

     is2_v      => tidn,
     rf0_v      => tidn,
     rf1_v      => tidn,
     ex1_v      => tidn,
     ex2_v      => tidn,
     lm0_v      => sp_L2_LM(0).ta_vld,
     lm1_v      => sp_L2_LM(1).ta_vld,
     lm2_v      => sp_L2_LM(2).ta_vld,
     lm3_v      => sp_L2_LM(3).ta_vld,
     lm4_v      => sp_L2_LM(4).ta_vld,
     lm5_v      => sp_L2_LM(5).ta_vld,
     lm6_v      => sp_L2_LM(6).ta_vld,
     lm7_v      => sp_L2_LM(7).ta_vld,

     is1_ad     => fdec_fdep_is1_ta,

     is2_ad     => sp_L2(IS2).ta,
     rf0_ad     => sp_L2(RF0).ta,
     rf1_ad     => sp_L2(RF1).ta,
     ex1_ad     => sp_L2(EX1).ta,
     ex2_ad     => sp_L2(EX2).ta,
     lm0_ad     => sp_L2_LM(0).ta,
     lm1_ad     => sp_L2_LM(1).ta,
     lm2_ad     => sp_L2_LM(2).ta,
     lm3_ad     => sp_L2_LM(3).ta,
     lm4_ad     => sp_L2_LM(4).ta,
     lm5_ad     => sp_L2_LM(5).ta,
     lm6_ad     => sp_L2_LM(6).ta,
     lm7_ad     => sp_L2_LM(7).ta,

     ad_hit_b   => WAW_LMQ_dep_hit_b
);
WAW_LMQ_dep_hit  <=  not WAW_LMQ_dep_hit_b;
single_instr_mode_d      <=  xu_iu_single_instr_mode;
single_instr_dep_hit     <=  ((shadow_pipe_vld or au_iu_is2_axubusy) and single_instr_mode_l2);
dep_hit  <=  (not fdec_fdep_is1_force_ram and (RAW_dep_hit or WAW_LMQ_dep_hit or sync_dep_hit or single_instr_dep_hit or br_sprs_dep_hit or barrier_in_progress)) or au_iu_is1_dep_hit or internal_is2_stall;
dep_hit_no_stall  <=  (not fdec_fdep_is1_force_ram and (RAW_dep_hit or WAW_LMQ_dep_hit or sync_dep_hit or single_instr_dep_hit or br_sprs_dep_hit or barrier_in_progress)) or au_iu_is1_dep_hit;
is1_force_ram_b                          <=  not fdec_fdep_is1_force_ram;
is1_valid                                <=  fdec_fdep_is1_vld or i_afd_is1_instr_v;
is1_dep0_nor2:          is1_dep0_b       <=  not (RAW_dep_hit or br_sprs_dep_hit);
is1_dep1_nor3:          is1_dep1_b       <=  not (sync_dep_hit or single_instr_dep_hit or barrier_in_progress);
is1_dep_nand3:          is1_dep          <=  not (WAW_LMQ_dep_hit_b and is1_dep0_b and is1_dep1_b);
is1_stall_nand2:        is1_stall_b      <=  not (is1_dep and fdec_fdep_is1_vld and is1_force_ram_b);
is2_stall_nand2:        is2_stall_b      <=  not (internal_is2_stall and is1_valid);
fxu_stall_nand3:        iu_au_is1_stall  <=  not (au_iu_is1_dep_hit_b and is1_stall_b and is2_stall_b);
buf_stall_nand3:        fdep_fdec_buff_stall  <=  not (au_iu_is1_dep_hit_b and is1_stall_b and is2_stall_b);
fxu_dep0_nor2:          fxu_dep0_b       <=  not (RAW_dep_hit or br_sprs_dep_hit);
fxu_dep1_nor3:          fxu_dep1_b       <=  not (sync_dep_hit or single_instr_dep_hit or barrier_in_progress);
fxu_dep_nand3:          fxu_dep_hit      <=  not (WAW_LMQ_dep_hit_b and fxu_dep0_b and fxu_dep1_b);
fxu_dep_nand2:          fxu_dep_hit_b    <=  not (fxu_dep_hit and is1_force_ram_b);
xu_dep_hit                               <=  not fxu_dep_hit_b;
fdep_fdec_weak_stall  <=  (sync_dep_hit or single_instr_dep_hit or barrier_in_progress) and fdec_fdep_is1_vld and is1_force_ram_b;
loadmiss_qentry		 <=  gate_and(not xu_iu_ex5_flush and xu_iu_loadmiss_vld and xu_iu_loadmiss_target_type, xu_iu_loadmiss_qentry);
loadmiss_target  	 <=  gate_and(not xu_iu_ex5_flush and xu_iu_loadmiss_vld and xu_iu_loadmiss_target_type, xu_iu_loadmiss_target);
loadmiss_complete	 <=  gate_and(                        xu_iu_complete_vld and xu_iu_complete_target_type, xu_iu_complete_qentry);
shadow_pipe_vld  <=  sp_L2(IS2).i_nobyp_vld or
                   sp_L2(RF0).i_nobyp_vld or
                   sp_L2(RF1).i_nobyp_vld or
                   sp_L2(EX1).i_nobyp_vld or
                   sp_L2(EX2).i_nobyp_vld or
                   sp_EX3_i_nobyp_vld_L2  or 
                   sp_EX4_i_nobyp_vld_L2  or 
                   sp_EX5_i_nobyp_vld_L2  or 
                   or_reduce(lm_shadow_pipe_vld);
lm_shadow_pipe_vld_g: for i in 0 to lmq_entries-1 generate
lm_shadow_pipe_vld(i) <=  sp_L2_LM(i).ta_vld;
end generate;



sp_d_proc : process(
xu_iu_is2_flush,
xu_iu_rf0_flush,
xu_iu_rf1_flush,
xu_iu_ex1_flush,
xu_iu_ex2_flush,
xu_iu_ex3_flush,
xu_iu_ex4_flush,
internal_is2_stall,
sp_L2(IS2).i_nobyp_vld, sp_L2(IS2).i_vld, sp_L2(IS2).ta_vld, 
sp_L2(IS2).ta, sp_L2(IS2).UpdatesLR, sp_L2(IS2).UpdatesCR, sp_L2(IS2).UPdatesCTR,
sp_L2(IS2).UpdatesXER, sp_L2(IS2).UpdatesMSR, sp_L2(IS2).UPdatesSPR, sp_L2(IS2).complete, sp_L2(IS2).barrier,
sp_L2(RF0).i_nobyp_vld, sp_L2(RF0).i_vld, sp_L2(RF0).ta_vld, 
sp_L2(RF0).ta, sp_L2(RF0).UpdatesLR, sp_L2(RF0).UpdatesCR, sp_L2(RF0).UPdatesCTR,
sp_L2(RF0).UpdatesXER, sp_L2(RF0).UpdatesMSR, sp_L2(RF0).UPdatesSPR, sp_L2(RF0).complete, sp_L2(RF0).barrier,
sp_L2(RF1).i_nobyp_vld, sp_L2(RF1).i_vld, sp_L2(RF1).ta_vld, 
sp_L2(RF1).ta, sp_L2(RF1).UpdatesLR, sp_L2(RF1).UpdatesCR, sp_L2(RF1).UPdatesCTR,
sp_L2(RF1).UpdatesXER, sp_L2(RF1).UpdatesMSR, sp_L2(RF1).UPdatesSPR, sp_L2(RF1).complete, sp_L2(RF1).barrier,
sp_L2(EX1).i_nobyp_vld, sp_L2(EX1).i_vld, sp_L2(EX1).ta_vld, 
sp_L2(EX1).ta, sp_L2(EX1).UpdatesLR, sp_L2(EX1).UpdatesCR, sp_L2(EX1).UPdatesCTR,
sp_L2(EX1).UpdatesXER, sp_L2(EX1).UpdatesMSR, sp_L2(EX1).UPdatesSPR, sp_L2(EX1).complete, sp_L2(EX1).barrier,

sp_L2(EX2).i_nobyp_vld, sp_L2(EX2).barrier,

sp_EX3_i_nobyp_vld_l2,
sp_EX4_i_nobyp_vld_l2,
sp_EX3_barrier_l2,
sp_EX4_barrier_l2,
sp_LM_l2,

fdec_fdep_is1_vld,
fdec_fdep_is1_ta_vld,

fdec_fdep_is1_ta,
fdec_fdep_is1_UpdatesLR,
fdec_fdep_is1_UpdatesCR,
fdec_fdep_is1_UpdatesCTR,
fdec_fdep_is1_UpdatesXER,
fdec_fdep_is1_UpdatesMSR,
fdec_fdep_is1_UpdatesSPR,
fdec_fdep_is1_complete,
xu_iu_is1_flush,
loadmiss_qentry,
loadmiss_target,
loadmiss_complete,
is2_instr_is_barrier,
dep_hit_no_stall
) begin



sp_d(IS2).i_nobyp_vld       <= fdec_fdep_is1_vld                          and not dep_hit_no_stall;
sp_d(IS2).i_vld             <= fdec_fdep_is1_vld                          and not dep_hit_no_stall and not fdec_fdep_is1_complete(0);
sp_d(IS2).ta_vld            <= fdec_fdep_is1_vld and fdec_fdep_is1_ta_vld and not dep_hit_no_stall and not fdec_fdep_is1_complete(0);
sp_d(IS2).ta                <= fdec_fdep_is1_ta;
sp_d(IS2).UpdatesLR         <= fdec_fdep_is1_UpdatesLR;
sp_d(IS2).UpdatesCR         <= fdec_fdep_is1_UpdatesCR;
sp_d(IS2).UpdatesCTR        <= fdec_fdep_is1_UpdatesCTR;
sp_d(IS2).UpdatesXER        <= fdec_fdep_is1_UpdatesXER;
sp_d(IS2).UpdatesMSR        <= fdec_fdep_is1_UpdatesMSR;
sp_d(IS2).UpdatesSPR        <= fdec_fdep_is1_UpdatesSPR;
sp_d(IS2).complete          <= fdec_fdep_is1_complete;
sp_d(IS2).barrier           <= '0';
if ib(internal_is2_stall) then
sp_d(IS2) <=  sp_L2(IS2);
end if;
if ib(xu_iu_is1_flush) then
sp_d(IS2).i_nobyp_vld   <= '0';
sp_d(IS2).i_vld         <= '0';
sp_d(IS2).ta_vld        <= '0';
end if;
sp_d(RF0) <= sp_L2(IS2);
sp_d(RF0).i_vld             <=sp_L2(IS2).i_vld and not sp_L2(IS2).complete(1);
sp_d(RF0).ta_vld            <=sp_L2(IS2).ta_vld and not sp_L2(IS2).complete(1);
sp_d(RF0).barrier           <=is2_instr_is_barrier;
if ib(xu_iu_is2_flush) or ib(internal_is2_stall) then
sp_d(RF0).ta_vld          <= '0';
sp_d(RF0).i_nobyp_vld     <= '0';
sp_d(RF0).i_vld           <= '0';
sp_d(RF0).barrier         <= '0';
end if;
sp_d(RF1) <= sp_L2(RF0);
sp_d(RF1).i_vld             <=sp_L2(RF0).i_vld and not sp_L2(RF0).complete(2);
sp_d(RF1).ta_vld            <=sp_L2(RF0).ta_vld and not sp_L2(RF0).complete(2);
if ib(xu_iu_rf0_flush) then
sp_d(RF1).ta_vld          <= '0';
sp_d(RF1).i_nobyp_vld     <= '0';
sp_d(RF1).i_vld           <= '0';
sp_d(RF1).barrier         <= '0';
end if;
sp_d(EX1) <= sp_L2(RF1);
sp_d(EX1).i_vld             <=sp_L2(RF1).i_vld and not sp_L2(RF1).complete(3);
sp_d(EX1).ta_vld            <=sp_L2(RF1).ta_vld and not sp_L2(RF1).complete(3);
if ib(xu_iu_rf1_flush) then
sp_d(EX1).ta_vld          <= '0';
sp_d(EX1).i_nobyp_vld     <= '0';
sp_d(EX1).i_vld           <= '0';
sp_d(EX1).barrier         <= '0';
end if;
sp_d(EX2) <= sp_L2(EX1);
sp_d(EX2).i_vld             <=sp_L2(EX1).i_vld and not sp_L2(EX1).complete(4);
sp_d(EX2).ta_vld            <=sp_L2(EX1).ta_vld and not sp_L2(EX1).complete(4);
if ib(xu_iu_ex1_flush) then
sp_d(EX2).ta_vld          <= '0';
sp_d(EX2).i_nobyp_vld     <= '0';
sp_d(EX2).i_vld           <= '0';
sp_d(EX2).barrier         <= '0';
end if;
sp_EX3_i_nobyp_vld_d             <=  sp_L2(EX2).i_nobyp_vld;
sp_EX3_barrier_d                 <=  sp_L2(EX2).barrier;
if ib(xu_iu_ex2_flush) then
sp_EX3_i_nobyp_vld_d          <=  '0';
sp_EX3_barrier_d              <=  '0';
end if;
sp_EX4_i_nobyp_vld_d             <=  sp_EX3_i_nobyp_vld_l2;
sp_EX4_barrier_d                 <=  sp_EX3_barrier_l2;
if ib(xu_iu_ex3_flush) then
sp_EX4_i_nobyp_vld_d          <=  '0';
sp_EX4_barrier_d              <=  '0';
end if;
sp_EX5_i_nobyp_vld_d             <=  sp_EX4_i_nobyp_vld_l2;
sp_EX5_barrier_d                 <=  sp_EX4_barrier_l2;
if ib(xu_iu_ex4_flush) then
sp_EX5_i_nobyp_vld_d          <=  '0';
sp_EX5_barrier_d              <=  '0';
end if;
lm_loop: for i in 0 to lmq_entries-1 loop
sp_d_LM(i).ta_vld      <= sp_LM_l2(0+7*i);
sp_d_LM(i).ta          <= sp_LM_l2(1+7*i to 6+7*i);
if ib(loadmiss_qentry(i)) then
sp_d_LM(i).ta_vld         <='1';
sp_d_LM(i).ta             <= loadmiss_target;
elsif ib(loadmiss_complete(i)) then
sp_d_LM(i).ta_vld         <= '0';
end if;
end loop;

      
end process sp_d_proc;
unused(0 TO 4) <=  sp_L2(EX2).complete(0 to 4);

is2_instr_proc : process (
fdec_fdep_is1_vld,

fdec_fdep_is1_instr,
fdec_fdep_is1_ta_vld,
fdec_fdep_is1_ta,
fdec_fdep_is1_s1_vld,
fdec_fdep_is1_s1,
fdec_fdep_is1_s2_vld,
fdec_fdep_is1_s2,
fdec_fdep_is1_s3_vld,
fdec_fdep_is1_s3,
fdec_fdep_is1_pred_update,
fdec_fdep_is1_pred_taken_cnt,
fdec_fdep_is1_gshare,

fdec_fdep_is1_hole_delay,

fdec_fdep_is1_to_ucode,
fdec_fdep_is1_is_ucode,
fdec_fdep_is1_ifar,
fdec_fdep_is1_error,
is1_is_barrier,
is1_is_slowspr,
is2_vld_l2,
is2_instr_l2,
is2_ta_vld_l2,
is2_ta_l2,
is2_s1_vld_l2,
is2_s1_l2,
is2_s2_vld_l2,
is2_s2_l2,
is2_s3_vld_l2,
is2_s3_l2,
is2_is_barrier_l2,
is2_is_slowspr_l2,
is2_pred_update_l2,
is2_pred_taken_cnt_l2,
is2_gshare_l2,

is2_hole_delay_l2,

is2_to_ucode_l2,
is2_is_ucode_l2,
is2_error_l2,
is2_ifar_l2,
is2_axu_ld_or_st_l2,
is2_axu_store_l2,
is2_axu_ldst_indexed_l2,
is2_axu_ldst_tag_l2,
is2_axu_ldst_size_l2,
is2_axu_ldst_update_l2,
is2_axu_ldst_extpid_l2,
is2_axu_ldst_forcealign_l2,
is2_axu_ldst_forceexcept_l2,
is2_axu_mftgpr_l2,
is2_axu_mffgpr_l2,
is2_axu_movedp_l2,
is2_axu_instr_type_l2,
is2_match_l2,
is2_2ucode_l2,
is2_2ucode_type_l2,
dep_hit_no_stall,
xu_iu_is1_flush,
internal_is2_stall,
fdec_fdep_is1_axu_ld_or_st,
fdec_fdep_is1_axu_store,
fdec_fdep_is1_axu_ldst_indexed,
fdec_fdep_is1_axu_ldst_tag,
fdec_fdep_is1_axu_ldst_size,
fdec_fdep_is1_axu_ldst_update,
fdec_fdep_is1_axu_ldst_extpid,
fdec_fdep_is1_axu_ldst_forcealign,
fdec_fdep_is1_axu_ldst_forceexcept,
fdec_fdep_is1_axu_mftgpr,
fdec_fdep_is1_axu_mffgpr,
fdec_fdep_is1_axu_movedp,
fdec_fdep_is1_axu_instr_type,
fdec_fdep_is1_match,
fdec_fdep_is1_2ucode,
fdec_fdep_is1_2ucode_type
) begin

    is2_vld_d                    <=  fdec_fdep_is1_vld and not dep_hit_no_stall;
is2_instr_d                  <=  fdec_fdep_is1_instr;
is2_ta_vld_d                 <=  fdec_fdep_is1_ta_vld;
is2_ta_d                     <=  fdec_fdep_is1_ta;
is2_s1_vld_d                 <=  fdec_fdep_is1_s1_vld;
is2_s1_d                     <=  fdec_fdep_is1_s1;
is2_s2_vld_d                 <=  fdec_fdep_is1_s2_vld;
is2_s2_d                     <=  fdec_fdep_is1_s2;
is2_s3_vld_d                 <=  fdec_fdep_is1_s3_vld;
is2_s3_d                     <=  fdec_fdep_is1_s3;
is2_is_barrier_d             <=  is1_is_barrier;
is2_is_slowspr_d             <=  is1_is_slowspr;
is2_pred_update_d            <=  fdec_fdep_is1_pred_update;
is2_pred_taken_cnt_d         <=  fdec_fdep_is1_pred_taken_cnt;
is2_gshare_d                 <=  fdec_fdep_is1_gshare;
is2_hole_delay_d             <=  fdec_fdep_is1_hole_delay;
is2_to_ucode_d               <=  fdec_fdep_is1_to_ucode;
is2_is_ucode_d               <=  fdec_fdep_is1_is_ucode;
is2_ifar_d                   <=  fdec_fdep_is1_ifar;
is2_error_d                  <=  fdec_fdep_is1_error;
is2_axu_ld_or_st_d           <=  fdec_fdep_is1_axu_ld_or_st;
is2_axu_store_d              <=  fdec_fdep_is1_axu_store;
is2_axu_ldst_indexed_d       <=  fdec_fdep_is1_axu_ldst_indexed;
is2_axu_ldst_tag_d           <=  fdec_fdep_is1_axu_ldst_tag;
is2_axu_ldst_size_d          <=  fdec_fdep_is1_axu_ldst_size;
is2_axu_ldst_update_d        <=  fdec_fdep_is1_axu_ldst_update;
is2_axu_ldst_extpid_d        <=  fdec_fdep_is1_axu_ldst_extpid;
is2_axu_ldst_forcealign_d    <=  fdec_fdep_is1_axu_ldst_forcealign;
is2_axu_ldst_forceexcept_d   <=  fdec_fdep_is1_axu_ldst_forceexcept;
is2_axu_mftgpr_d             <=  fdec_fdep_is1_axu_mftgpr;
is2_axu_mffgpr_d             <=  fdec_fdep_is1_axu_mffgpr;
is2_axu_movedp_d            <=  fdec_fdep_is1_axu_movedp;
is2_axu_instr_type_d         <=  fdec_fdep_is1_axu_instr_type;
is2_match_d                  <=  fdec_fdep_is1_match;
is2_2ucode_d                 <=  fdec_fdep_is1_2ucode;
is2_2ucode_type_d            <=  fdec_fdep_is1_2ucode_type;
if (internal_is2_stall = '1') then
is2_vld_d                    <=  is2_vld_l2;
is2_instr_d                  <=  is2_instr_l2;
is2_ta_vld_d                 <=  is2_ta_vld_l2;
is2_ta_d                     <=  is2_ta_l2;
is2_s1_vld_d                 <=  is2_s1_vld_l2;
is2_s1_d                     <=  is2_s1_l2;
is2_s2_vld_d                 <=  is2_s2_vld_l2;
is2_s2_d                     <=  is2_s2_l2;
is2_s3_vld_d                 <=  is2_s3_vld_l2;
is2_s3_d                     <=  is2_s3_l2;
is2_is_barrier_d             <=  is2_is_barrier_l2;
is2_is_slowspr_d             <=  is2_is_slowspr_l2;
is2_pred_update_d            <=  is2_pred_update_l2;
is2_pred_taken_cnt_d         <=  is2_pred_taken_cnt_l2;
is2_gshare_d                 <=  is2_gshare_l2;
is2_hole_delay_d             <=  is2_hole_delay_l2;
is2_to_ucode_d               <=  is2_to_ucode_l2;
is2_is_ucode_d               <=  is2_is_ucode_l2;
is2_ifar_d                   <=  is2_ifar_l2;
is2_error_d                  <=  is2_error_l2;
is2_axu_ld_or_st_d           <=  is2_axu_ld_or_st_l2;
is2_axu_store_d              <=  is2_axu_store_l2;
is2_axu_ldst_indexed_d       <=  is2_axu_ldst_indexed_l2;
is2_axu_ldst_tag_d           <=  is2_axu_ldst_tag_l2;
is2_axu_ldst_size_d          <=  is2_axu_ldst_size_l2;
is2_axu_ldst_update_d        <=  is2_axu_ldst_update_l2;
is2_axu_ldst_extpid_d        <=  is2_axu_ldst_extpid_l2;
is2_axu_ldst_forcealign_d    <=  is2_axu_ldst_forcealign_l2;
is2_axu_ldst_forceexcept_d   <=  is2_axu_ldst_forceexcept_l2;
is2_axu_mftgpr_d             <=  is2_axu_mftgpr_l2;
is2_axu_mffgpr_d             <=  is2_axu_mffgpr_l2;
is2_axu_movedp_d            <=  is2_axu_movedp_l2;
is2_axu_instr_type_d         <=  is2_axu_instr_type_l2;
is2_match_d                  <=  is2_match_l2;
is2_2ucode_d                 <=  is2_2ucode_l2;
is2_2ucode_type_d            <=  is2_2ucode_type_l2;
end if;
if (xu_iu_is1_flush = '1') then
is2_vld_d              <=  '0';
end if;


end process is2_instr_proc;
mult_hole_barrier_d(0) <=  not xu_iu_is2_flush and (                                         mult_hole_barrier_L2(1));
mult_hole_barrier_d(1) <=  not xu_iu_is2_flush and (                                         mult_hole_barrier_L2(2));
mult_hole_barrier_d(2) <=  not xu_iu_is2_flush and (                                         mult_hole_barrier_L2(3));
mult_hole_barrier_d(3) <=  not xu_iu_is2_flush and ((is2_vld_l2 and is2_hole_delay_L2(0)) or mult_hole_barrier_L2(4));
mult_hole_barrier_d(4) <=  not xu_iu_is2_flush and ((is2_vld_l2 and is2_hole_delay_L2(1)) or mult_hole_barrier_L2(5));
mult_hole_barrier_d(5) <=  not xu_iu_is2_flush and ((is2_vld_l2 and is2_hole_delay_L2(2))                           );
is2_mult_hole_barrier            <=  (is2_vld_l2 and or_reduce(is2_hole_delay_L2(0 to 2))) or or_reduce(mult_hole_barrier_L2(0 to 5));
mult_hole_barrier_act            <=  is2_mult_hole_barrier;
is1_is_slowspr           <=  is_slowspr and (isMTSPR or isMFSPR);
is1_is_barrier           <=  is_bar or is1_is_slowspr or fdec_fdep_is1_to_ucode;
is2_instr_is_barrier     <=  is2_vld_l2 and is2_is_barrier_L2;
MQQ1:BARRIER_PT(1) <=
    Eq(( FDEC_FDEP_IS1_INSTR(0) & FDEC_FDEP_IS1_INSTR(1) & 
    FDEC_FDEP_IS1_INSTR(2) & FDEC_FDEP_IS1_INSTR(3) & 
    FDEC_FDEP_IS1_INSTR(4) & FDEC_FDEP_IS1_INSTR(5) & 
    FDEC_FDEP_IS1_INSTR(21) & FDEC_FDEP_IS1_INSTR(22) & 
    FDEC_FDEP_IS1_INSTR(24) & FDEC_FDEP_IS1_INSTR(25) & 
    FDEC_FDEP_IS1_INSTR(26) & FDEC_FDEP_IS1_INSTR(27) & 
    FDEC_FDEP_IS1_INSTR(29) & FDEC_FDEP_IS1_INSTR(30) & 
    FDEC_FDEP_IS1_INSTR(31) ) , STD_ULOGIC_VECTOR'("011111111010101"));
MQQ2:BARRIER_PT(2) <=
    Eq(( FDEC_FDEP_IS1_INSTR(0) & FDEC_FDEP_IS1_INSTR(1) & 
    FDEC_FDEP_IS1_INSTR(2) & FDEC_FDEP_IS1_INSTR(3) & 
    FDEC_FDEP_IS1_INSTR(4) & FDEC_FDEP_IS1_INSTR(5) & 
    FDEC_FDEP_IS1_INSTR(21) & FDEC_FDEP_IS1_INSTR(22) & 
    FDEC_FDEP_IS1_INSTR(23) & FDEC_FDEP_IS1_INSTR(24) & 
    FDEC_FDEP_IS1_INSTR(25) & FDEC_FDEP_IS1_INSTR(26) & 
    FDEC_FDEP_IS1_INSTR(27) & FDEC_FDEP_IS1_INSTR(29) & 
    FDEC_FDEP_IS1_INSTR(30) ) , STD_ULOGIC_VECTOR'("011111111101010"));
MQQ3:BARRIER_PT(3) <=
    Eq(( FDEC_FDEP_IS1_INSTR(0) & FDEC_FDEP_IS1_INSTR(1) & 
    FDEC_FDEP_IS1_INSTR(2) & FDEC_FDEP_IS1_INSTR(3) & 
    FDEC_FDEP_IS1_INSTR(4) & FDEC_FDEP_IS1_INSTR(5) & 
    FDEC_FDEP_IS1_INSTR(21) & FDEC_FDEP_IS1_INSTR(22) & 
    FDEC_FDEP_IS1_INSTR(23) & FDEC_FDEP_IS1_INSTR(25) & 
    FDEC_FDEP_IS1_INSTR(26) & FDEC_FDEP_IS1_INSTR(27) & 
    FDEC_FDEP_IS1_INSTR(28) & FDEC_FDEP_IS1_INSTR(29) & 
    FDEC_FDEP_IS1_INSTR(30) ) , STD_ULOGIC_VECTOR'("010011000100110"));
MQQ4:BARRIER_PT(4) <=
    Eq(( CORE64 & FDEC_FDEP_IS1_INSTR(0) & 
    FDEC_FDEP_IS1_INSTR(1) & FDEC_FDEP_IS1_INSTR(2) & 
    FDEC_FDEP_IS1_INSTR(3) & FDEC_FDEP_IS1_INSTR(4) & 
    FDEC_FDEP_IS1_INSTR(5) & FDEC_FDEP_IS1_INSTR(21) & 
    FDEC_FDEP_IS1_INSTR(22) & FDEC_FDEP_IS1_INSTR(23) & 
    FDEC_FDEP_IS1_INSTR(25) & FDEC_FDEP_IS1_INSTR(26) & 
    FDEC_FDEP_IS1_INSTR(27) & FDEC_FDEP_IS1_INSTR(28) & 
    FDEC_FDEP_IS1_INSTR(29) & FDEC_FDEP_IS1_INSTR(30)
     ) , STD_ULOGIC_VECTOR'("1011111000010100"));
MQQ5:BARRIER_PT(5) <=
    Eq(( FDEC_FDEP_IS1_INSTR(0) & FDEC_FDEP_IS1_INSTR(1) & 
    FDEC_FDEP_IS1_INSTR(2) & FDEC_FDEP_IS1_INSTR(3) & 
    FDEC_FDEP_IS1_INSTR(4) & FDEC_FDEP_IS1_INSTR(5) & 
    FDEC_FDEP_IS1_INSTR(21) & FDEC_FDEP_IS1_INSTR(22) & 
    FDEC_FDEP_IS1_INSTR(23) & FDEC_FDEP_IS1_INSTR(24) & 
    FDEC_FDEP_IS1_INSTR(25) & FDEC_FDEP_IS1_INSTR(26) & 
    FDEC_FDEP_IS1_INSTR(27) & FDEC_FDEP_IS1_INSTR(28) & 
    FDEC_FDEP_IS1_INSTR(29) ) , STD_ULOGIC_VECTOR'("010011000011001"));
MQQ6:BARRIER_PT(6) <=
    Eq(( FDEC_FDEP_IS1_INSTR(0) & FDEC_FDEP_IS1_INSTR(1) & 
    FDEC_FDEP_IS1_INSTR(2) & FDEC_FDEP_IS1_INSTR(3) & 
    FDEC_FDEP_IS1_INSTR(4) & FDEC_FDEP_IS1_INSTR(5) & 
    FDEC_FDEP_IS1_INSTR(21) & FDEC_FDEP_IS1_INSTR(22) & 
    FDEC_FDEP_IS1_INSTR(23) & FDEC_FDEP_IS1_INSTR(24) & 
    FDEC_FDEP_IS1_INSTR(25) & FDEC_FDEP_IS1_INSTR(26) & 
    FDEC_FDEP_IS1_INSTR(27) & FDEC_FDEP_IS1_INSTR(28) & 
    FDEC_FDEP_IS1_INSTR(29) & FDEC_FDEP_IS1_INSTR(30)
     ) , STD_ULOGIC_VECTOR'("0100110010010110"));
MQQ7:BARRIER_PT(7) <=
    Eq(( CORE64 & FDEC_FDEP_IS1_INSTR(0) & 
    FDEC_FDEP_IS1_INSTR(1) & FDEC_FDEP_IS1_INSTR(2) & 
    FDEC_FDEP_IS1_INSTR(3) & FDEC_FDEP_IS1_INSTR(4) & 
    FDEC_FDEP_IS1_INSTR(5) & FDEC_FDEP_IS1_INSTR(21) & 
    FDEC_FDEP_IS1_INSTR(22) & FDEC_FDEP_IS1_INSTR(23) & 
    FDEC_FDEP_IS1_INSTR(25) & FDEC_FDEP_IS1_INSTR(26) & 
    FDEC_FDEP_IS1_INSTR(27) & FDEC_FDEP_IS1_INSTR(28) & 
    FDEC_FDEP_IS1_INSTR(29) & FDEC_FDEP_IS1_INSTR(30) & 
    FDEC_FDEP_IS1_INSTR(31) ) , STD_ULOGIC_VECTOR'("10111110010101101"));
MQQ8:BARRIER_PT(8) <=
    Eq(( FDEC_FDEP_IS1_INSTR(0) & FDEC_FDEP_IS1_INSTR(1) & 
    FDEC_FDEP_IS1_INSTR(2) & FDEC_FDEP_IS1_INSTR(3) & 
    FDEC_FDEP_IS1_INSTR(4) & FDEC_FDEP_IS1_INSTR(5) & 
    FDEC_FDEP_IS1_INSTR(21) & FDEC_FDEP_IS1_INSTR(22) & 
    FDEC_FDEP_IS1_INSTR(23) & FDEC_FDEP_IS1_INSTR(24) & 
    FDEC_FDEP_IS1_INSTR(25) & FDEC_FDEP_IS1_INSTR(26) & 
    FDEC_FDEP_IS1_INSTR(27) & FDEC_FDEP_IS1_INSTR(28) & 
    FDEC_FDEP_IS1_INSTR(29) & FDEC_FDEP_IS1_INSTR(30)
     ) , STD_ULOGIC_VECTOR'("0111110000010100"));
MQQ9:BARRIER_PT(9) <=
    Eq(( FDEC_FDEP_IS1_INSTR(0) & FDEC_FDEP_IS1_INSTR(1) & 
    FDEC_FDEP_IS1_INSTR(2) & FDEC_FDEP_IS1_INSTR(3) & 
    FDEC_FDEP_IS1_INSTR(4) & FDEC_FDEP_IS1_INSTR(5) & 
    FDEC_FDEP_IS1_INSTR(21) & FDEC_FDEP_IS1_INSTR(23) & 
    FDEC_FDEP_IS1_INSTR(24) & FDEC_FDEP_IS1_INSTR(25) & 
    FDEC_FDEP_IS1_INSTR(26) & FDEC_FDEP_IS1_INSTR(27) & 
    FDEC_FDEP_IS1_INSTR(28) & FDEC_FDEP_IS1_INSTR(29) & 
    FDEC_FDEP_IS1_INSTR(30) ) , STD_ULOGIC_VECTOR'("011111101010110"));
MQQ10:BARRIER_PT(10) <=
    Eq(( CORE64 & FDEC_FDEP_IS1_INSTR(0) & 
    FDEC_FDEP_IS1_INSTR(1) & FDEC_FDEP_IS1_INSTR(2) & 
    FDEC_FDEP_IS1_INSTR(3) & FDEC_FDEP_IS1_INSTR(4) & 
    FDEC_FDEP_IS1_INSTR(5) & FDEC_FDEP_IS1_INSTR(22) & 
    FDEC_FDEP_IS1_INSTR(23) & FDEC_FDEP_IS1_INSTR(26) & 
    FDEC_FDEP_IS1_INSTR(27) & FDEC_FDEP_IS1_INSTR(28) & 
    FDEC_FDEP_IS1_INSTR(30) ) , STD_ULOGIC_VECTOR'("1011111110101"));
MQQ11:BARRIER_PT(11) <=
    Eq(( FDEC_FDEP_IS1_INSTR(0) & FDEC_FDEP_IS1_INSTR(1) & 
    FDEC_FDEP_IS1_INSTR(2) & FDEC_FDEP_IS1_INSTR(3) & 
    FDEC_FDEP_IS1_INSTR(4) & FDEC_FDEP_IS1_INSTR(5) & 
    FDEC_FDEP_IS1_INSTR(21) & FDEC_FDEP_IS1_INSTR(22) & 
    FDEC_FDEP_IS1_INSTR(23) & FDEC_FDEP_IS1_INSTR(24) & 
    FDEC_FDEP_IS1_INSTR(25) & FDEC_FDEP_IS1_INSTR(26) & 
    FDEC_FDEP_IS1_INSTR(27) & FDEC_FDEP_IS1_INSTR(28) & 
    FDEC_FDEP_IS1_INSTR(29) & FDEC_FDEP_IS1_INSTR(30)
     ) , STD_ULOGIC_VECTOR'("0111111000110110"));
MQQ12:BARRIER_PT(12) <=
    Eq(( FDEC_FDEP_IS1_INSTR(0) & FDEC_FDEP_IS1_INSTR(1) & 
    FDEC_FDEP_IS1_INSTR(2) & FDEC_FDEP_IS1_INSTR(3) & 
    FDEC_FDEP_IS1_INSTR(4) & FDEC_FDEP_IS1_INSTR(5) & 
    FDEC_FDEP_IS1_INSTR(21) & FDEC_FDEP_IS1_INSTR(23) & 
    FDEC_FDEP_IS1_INSTR(24) & FDEC_FDEP_IS1_INSTR(25) & 
    FDEC_FDEP_IS1_INSTR(26) & FDEC_FDEP_IS1_INSTR(27) & 
    FDEC_FDEP_IS1_INSTR(28) & FDEC_FDEP_IS1_INSTR(29) & 
    FDEC_FDEP_IS1_INSTR(30) & FDEC_FDEP_IS1_INSTR(31)
     ) , STD_ULOGIC_VECTOR'("0111110100101101"));
MQQ13:BARRIER_PT(13) <=
    Eq(( FDEC_FDEP_IS1_INSTR(0) & FDEC_FDEP_IS1_INSTR(1) & 
    FDEC_FDEP_IS1_INSTR(2) & FDEC_FDEP_IS1_INSTR(3) & 
    FDEC_FDEP_IS1_INSTR(4) & FDEC_FDEP_IS1_INSTR(5) & 
    FDEC_FDEP_IS1_INSTR(21) & FDEC_FDEP_IS1_INSTR(22) & 
    FDEC_FDEP_IS1_INSTR(23) & FDEC_FDEP_IS1_INSTR(24) & 
    FDEC_FDEP_IS1_INSTR(25) & FDEC_FDEP_IS1_INSTR(26) & 
    FDEC_FDEP_IS1_INSTR(27) & FDEC_FDEP_IS1_INSTR(29) & 
    FDEC_FDEP_IS1_INSTR(30) & FDEC_FDEP_IS1_INSTR(31)
     ) , STD_ULOGIC_VECTOR'("0111111110110101"));
MQQ14:BARRIER_PT(14) <=
    Eq(( FDEC_FDEP_IS1_INSTR(0) & FDEC_FDEP_IS1_INSTR(1) & 
    FDEC_FDEP_IS1_INSTR(2) & FDEC_FDEP_IS1_INSTR(3) & 
    FDEC_FDEP_IS1_INSTR(4) & FDEC_FDEP_IS1_INSTR(5) & 
    FDEC_FDEP_IS1_INSTR(21) & FDEC_FDEP_IS1_INSTR(22) & 
    FDEC_FDEP_IS1_INSTR(24) & FDEC_FDEP_IS1_INSTR(25) & 
    FDEC_FDEP_IS1_INSTR(26) & FDEC_FDEP_IS1_INSTR(27) & 
    FDEC_FDEP_IS1_INSTR(28) & FDEC_FDEP_IS1_INSTR(29) & 
    FDEC_FDEP_IS1_INSTR(30) ) , STD_ULOGIC_VECTOR'("011111000010010"));
MQQ15:BARRIER_PT(15) <=
    Eq(( EN_DCR_L2 & FDEC_FDEP_IS1_INSTR(0) & 
    FDEC_FDEP_IS1_INSTR(1) & FDEC_FDEP_IS1_INSTR(2) & 
    FDEC_FDEP_IS1_INSTR(3) & FDEC_FDEP_IS1_INSTR(4) & 
    FDEC_FDEP_IS1_INSTR(5) & FDEC_FDEP_IS1_INSTR(21) & 
    FDEC_FDEP_IS1_INSTR(22) & FDEC_FDEP_IS1_INSTR(25) & 
    FDEC_FDEP_IS1_INSTR(26) & FDEC_FDEP_IS1_INSTR(27) & 
    FDEC_FDEP_IS1_INSTR(28) & FDEC_FDEP_IS1_INSTR(29) & 
    FDEC_FDEP_IS1_INSTR(30) ) , STD_ULOGIC_VECTOR'("101111101000011"));
MQQ16:BARRIER_PT(16) <=
    Eq(( EN_DCR_L2 & FDEC_FDEP_IS1_INSTR(0) & 
    FDEC_FDEP_IS1_INSTR(1) & FDEC_FDEP_IS1_INSTR(2) & 
    FDEC_FDEP_IS1_INSTR(3) & FDEC_FDEP_IS1_INSTR(4) & 
    FDEC_FDEP_IS1_INSTR(5) & FDEC_FDEP_IS1_INSTR(21) & 
    FDEC_FDEP_IS1_INSTR(22) & FDEC_FDEP_IS1_INSTR(24) & 
    FDEC_FDEP_IS1_INSTR(26) & FDEC_FDEP_IS1_INSTR(27) & 
    FDEC_FDEP_IS1_INSTR(28) & FDEC_FDEP_IS1_INSTR(29) & 
    FDEC_FDEP_IS1_INSTR(30) ) , STD_ULOGIC_VECTOR'("101111101000011"));
MQQ17:BARRIER_PT(17) <=
    Eq(( FDEC_FDEP_IS1_INSTR(0) & FDEC_FDEP_IS1_INSTR(1) & 
    FDEC_FDEP_IS1_INSTR(2) & FDEC_FDEP_IS1_INSTR(3) & 
    FDEC_FDEP_IS1_INSTR(4) & FDEC_FDEP_IS1_INSTR(5) & 
    FDEC_FDEP_IS1_INSTR(21) & FDEC_FDEP_IS1_INSTR(22) & 
    FDEC_FDEP_IS1_INSTR(24) & FDEC_FDEP_IS1_INSTR(25) & 
    FDEC_FDEP_IS1_INSTR(26) & FDEC_FDEP_IS1_INSTR(27) & 
    FDEC_FDEP_IS1_INSTR(28) & FDEC_FDEP_IS1_INSTR(29) & 
    FDEC_FDEP_IS1_INSTR(30) ) , STD_ULOGIC_VECTOR'("011111000110011"));
MQQ18:BARRIER_PT(18) <=
    Eq(( FDEC_FDEP_IS1_INSTR(0) & FDEC_FDEP_IS1_INSTR(1) & 
    FDEC_FDEP_IS1_INSTR(2) & FDEC_FDEP_IS1_INSTR(3) & 
    FDEC_FDEP_IS1_INSTR(4) & FDEC_FDEP_IS1_INSTR(5) & 
    FDEC_FDEP_IS1_INSTR(21) & FDEC_FDEP_IS1_INSTR(22) & 
    FDEC_FDEP_IS1_INSTR(23) & FDEC_FDEP_IS1_INSTR(24) & 
    FDEC_FDEP_IS1_INSTR(25) & FDEC_FDEP_IS1_INSTR(26) & 
    FDEC_FDEP_IS1_INSTR(27) & FDEC_FDEP_IS1_INSTR(28) & 
    FDEC_FDEP_IS1_INSTR(29) & FDEC_FDEP_IS1_INSTR(30)
     ) , STD_ULOGIC_VECTOR'("0111110100001110"));
MQQ19:BARRIER_PT(19) <=
    Eq(( FDEC_FDEP_IS1_INSTR(0) & FDEC_FDEP_IS1_INSTR(1) & 
    FDEC_FDEP_IS1_INSTR(2) & FDEC_FDEP_IS1_INSTR(3) & 
    FDEC_FDEP_IS1_INSTR(4) & FDEC_FDEP_IS1_INSTR(5) & 
    FDEC_FDEP_IS1_INSTR(22) & FDEC_FDEP_IS1_INSTR(23) & 
    FDEC_FDEP_IS1_INSTR(26) & FDEC_FDEP_IS1_INSTR(27) & 
    FDEC_FDEP_IS1_INSTR(28) & FDEC_FDEP_IS1_INSTR(29) & 
    FDEC_FDEP_IS1_INSTR(30) ) , STD_ULOGIC_VECTOR'("0111111101011"));
MQQ20:BARRIER_PT(20) <=
    Eq(( FDEC_FDEP_IS1_INSTR(0) & FDEC_FDEP_IS1_INSTR(1) & 
    FDEC_FDEP_IS1_INSTR(2) & FDEC_FDEP_IS1_INSTR(3) & 
    FDEC_FDEP_IS1_INSTR(4) & FDEC_FDEP_IS1_INSTR(5) & 
    FDEC_FDEP_IS1_INSTR(21) & FDEC_FDEP_IS1_INSTR(22) & 
    FDEC_FDEP_IS1_INSTR(24) & FDEC_FDEP_IS1_INSTR(25) & 
    FDEC_FDEP_IS1_INSTR(26) & FDEC_FDEP_IS1_INSTR(27) & 
    FDEC_FDEP_IS1_INSTR(28) & FDEC_FDEP_IS1_INSTR(29) & 
    FDEC_FDEP_IS1_INSTR(30) ) , STD_ULOGIC_VECTOR'("011111110010010"));
MQQ21:BARRIER_PT(21) <=
    Eq(( FDEC_FDEP_IS1_INSTR(0) & FDEC_FDEP_IS1_INSTR(1) & 
    FDEC_FDEP_IS1_INSTR(2) & FDEC_FDEP_IS1_INSTR(3) & 
    FDEC_FDEP_IS1_INSTR(4) & FDEC_FDEP_IS1_INSTR(5) & 
    FDEC_FDEP_IS1_INSTR(21) & FDEC_FDEP_IS1_INSTR(22) & 
    FDEC_FDEP_IS1_INSTR(23) & FDEC_FDEP_IS1_INSTR(24) & 
    FDEC_FDEP_IS1_INSTR(25) & FDEC_FDEP_IS1_INSTR(26) & 
    FDEC_FDEP_IS1_INSTR(27) & FDEC_FDEP_IS1_INSTR(28) & 
    FDEC_FDEP_IS1_INSTR(29) & FDEC_FDEP_IS1_INSTR(30)
     ) , STD_ULOGIC_VECTOR'("0111111111011111"));
MQQ22:BARRIER_PT(22) <=
    Eq(( FDEC_FDEP_IS1_INSTR(0) & FDEC_FDEP_IS1_INSTR(1) & 
    FDEC_FDEP_IS1_INSTR(2) & FDEC_FDEP_IS1_INSTR(3) & 
    FDEC_FDEP_IS1_INSTR(4) & FDEC_FDEP_IS1_INSTR(5) & 
    FDEC_FDEP_IS1_INSTR(21) & FDEC_FDEP_IS1_INSTR(22) & 
    FDEC_FDEP_IS1_INSTR(23) & FDEC_FDEP_IS1_INSTR(24) & 
    FDEC_FDEP_IS1_INSTR(25) & FDEC_FDEP_IS1_INSTR(26) & 
    FDEC_FDEP_IS1_INSTR(27) & FDEC_FDEP_IS1_INSTR(28) & 
    FDEC_FDEP_IS1_INSTR(29) & FDEC_FDEP_IS1_INSTR(30)
     ) , STD_ULOGIC_VECTOR'("0111111100110011"));
MQQ23:BARRIER_PT(23) <=
    Eq(( FDEC_FDEP_IS1_INSTR(0) & FDEC_FDEP_IS1_INSTR(1) & 
    FDEC_FDEP_IS1_INSTR(2) & FDEC_FDEP_IS1_INSTR(3) & 
    FDEC_FDEP_IS1_INSTR(4) & FDEC_FDEP_IS1_INSTR(5) & 
    FDEC_FDEP_IS1_INSTR(21) & FDEC_FDEP_IS1_INSTR(22) & 
    FDEC_FDEP_IS1_INSTR(23) & FDEC_FDEP_IS1_INSTR(24) & 
    FDEC_FDEP_IS1_INSTR(26) & FDEC_FDEP_IS1_INSTR(27) & 
    FDEC_FDEP_IS1_INSTR(28) & FDEC_FDEP_IS1_INSTR(29) & 
    FDEC_FDEP_IS1_INSTR(30) ) , STD_ULOGIC_VECTOR'("011111111010010"));
MQQ24:BARRIER_PT(24) <=
    Eq(( FDEC_FDEP_IS1_INSTR(0) & FDEC_FDEP_IS1_INSTR(1) & 
    FDEC_FDEP_IS1_INSTR(2) & FDEC_FDEP_IS1_INSTR(3) & 
    FDEC_FDEP_IS1_INSTR(4) & FDEC_FDEP_IS1_INSTR(5) & 
    FDEC_FDEP_IS1_INSTR(30) ) , STD_ULOGIC_VECTOR'("0100011"));
MQQ25:IS_BAR <= 
    (BARRIER_PT(1) OR BARRIER_PT(2)
     OR BARRIER_PT(3) OR BARRIER_PT(4)
     OR BARRIER_PT(5) OR BARRIER_PT(6)
     OR BARRIER_PT(7) OR BARRIER_PT(8)
     OR BARRIER_PT(9) OR BARRIER_PT(10)
     OR BARRIER_PT(11) OR BARRIER_PT(12)
     OR BARRIER_PT(13) OR BARRIER_PT(14)
     OR BARRIER_PT(15) OR BARRIER_PT(16)
     OR BARRIER_PT(17) OR BARRIER_PT(18)
     OR BARRIER_PT(19) OR BARRIER_PT(20)
     OR BARRIER_PT(21) OR BARRIER_PT(22)
     OR BARRIER_PT(23) OR BARRIER_PT(24)
    );

isMFSPR  <=  (fdec_fdep_is1_instr(0 to 5) = "011111") and (fdec_fdep_is1_instr(21 to 30) = "0101010011");
isMTSPR  <=  (fdec_fdep_is1_instr(0 to 5) = "011111") and (fdec_fdep_is1_instr(21 to 30) = "0111010011");
MQQ26:SLOWSPR_TABLE_PT(1) <=
    Eq(( FDEC_FDEP_IS1_INSTR(16) & FDEC_FDEP_IS1_INSTR(17) & 
    FDEC_FDEP_IS1_INSTR(18) & FDEC_FDEP_IS1_INSTR(19) & 
    FDEC_FDEP_IS1_INSTR(20) & FDEC_FDEP_IS1_INSTR(11) & 
    FDEC_FDEP_IS1_INSTR(12) & FDEC_FDEP_IS1_INSTR(13) & 
    FDEC_FDEP_IS1_INSTR(15) ) , STD_ULOGIC_VECTOR'("010101110"));
MQQ27:SLOWSPR_TABLE_PT(2) <=
    Eq(( FDEC_FDEP_IS1_INSTR(16) & FDEC_FDEP_IS1_INSTR(17) & 
    FDEC_FDEP_IS1_INSTR(18) & FDEC_FDEP_IS1_INSTR(19) & 
    FDEC_FDEP_IS1_INSTR(20) & FDEC_FDEP_IS1_INSTR(11) & 
    FDEC_FDEP_IS1_INSTR(13) & FDEC_FDEP_IS1_INSTR(14) & 
    FDEC_FDEP_IS1_INSTR(15) ) , STD_ULOGIC_VECTOR'("010101101"));
MQQ28:SLOWSPR_TABLE_PT(3) <=
    Eq(( FDEC_FDEP_IS1_INSTR(16) & FDEC_FDEP_IS1_INSTR(17) & 
    FDEC_FDEP_IS1_INSTR(18) & FDEC_FDEP_IS1_INSTR(11) & 
    FDEC_FDEP_IS1_INSTR(12) & FDEC_FDEP_IS1_INSTR(13) & 
    FDEC_FDEP_IS1_INSTR(14) & FDEC_FDEP_IS1_INSTR(15)
     ) , STD_ULOGIC_VECTOR'("11110100"));
MQQ29:SLOWSPR_TABLE_PT(4) <=
    Eq(( FDEC_FDEP_IS1_INSTR(16) & FDEC_FDEP_IS1_INSTR(17) & 
    FDEC_FDEP_IS1_INSTR(18) & FDEC_FDEP_IS1_INSTR(19) & 
    FDEC_FDEP_IS1_INSTR(20) & FDEC_FDEP_IS1_INSTR(11) & 
    FDEC_FDEP_IS1_INSTR(12) & FDEC_FDEP_IS1_INSTR(14)
     ) , STD_ULOGIC_VECTOR'("10011101"));
MQQ30:SLOWSPR_TABLE_PT(5) <=
    Eq(( FDEC_FDEP_IS1_INSTR(16) & FDEC_FDEP_IS1_INSTR(17) & 
    FDEC_FDEP_IS1_INSTR(19) & FDEC_FDEP_IS1_INSTR(20) & 
    FDEC_FDEP_IS1_INSTR(11) & FDEC_FDEP_IS1_INSTR(12) & 
    FDEC_FDEP_IS1_INSTR(14) & FDEC_FDEP_IS1_INSTR(15)
     ) , STD_ULOGIC_VECTOR'("11111100"));
MQQ31:SLOWSPR_TABLE_PT(6) <=
    Eq(( FDEC_FDEP_IS1_INSTR(16) & FDEC_FDEP_IS1_INSTR(17) & 
    FDEC_FDEP_IS1_INSTR(19) & FDEC_FDEP_IS1_INSTR(20) & 
    FDEC_FDEP_IS1_INSTR(11) & FDEC_FDEP_IS1_INSTR(12) & 
    FDEC_FDEP_IS1_INSTR(14) & FDEC_FDEP_IS1_INSTR(15)
     ) , STD_ULOGIC_VECTOR'("11111011"));
MQQ32:SLOWSPR_TABLE_PT(7) <=
    Eq(( FDEC_FDEP_IS1_INSTR(16) & FDEC_FDEP_IS1_INSTR(18) & 
    FDEC_FDEP_IS1_INSTR(19) & FDEC_FDEP_IS1_INSTR(20) & 
    FDEC_FDEP_IS1_INSTR(11) & FDEC_FDEP_IS1_INSTR(12) & 
    FDEC_FDEP_IS1_INSTR(13) & FDEC_FDEP_IS1_INSTR(14)
     ) , STD_ULOGIC_VECTOR'("10111000"));
MQQ33:SLOWSPR_TABLE_PT(8) <=
    Eq(( FDEC_FDEP_IS1_INSTR(16) & FDEC_FDEP_IS1_INSTR(18) & 
    FDEC_FDEP_IS1_INSTR(19) & FDEC_FDEP_IS1_INSTR(20) & 
    FDEC_FDEP_IS1_INSTR(11) & FDEC_FDEP_IS1_INSTR(12) & 
    FDEC_FDEP_IS1_INSTR(13) & FDEC_FDEP_IS1_INSTR(15)
     ) , STD_ULOGIC_VECTOR'("10111010"));
MQQ34:SLOWSPR_TABLE_PT(9) <=
    Eq(( FDEC_FDEP_IS1_INSTR(16) & FDEC_FDEP_IS1_INSTR(17) & 
    FDEC_FDEP_IS1_INSTR(18) & FDEC_FDEP_IS1_INSTR(19) & 
    FDEC_FDEP_IS1_INSTR(20) & FDEC_FDEP_IS1_INSTR(12) & 
    FDEC_FDEP_IS1_INSTR(13) & FDEC_FDEP_IS1_INSTR(14) & 
    FDEC_FDEP_IS1_INSTR(15) ) , STD_ULOGIC_VECTOR'("111000010"));
MQQ35:SLOWSPR_TABLE_PT(10) <=
    Eq(( FDEC_FDEP_IS1_INSTR(16) & FDEC_FDEP_IS1_INSTR(17) & 
    FDEC_FDEP_IS1_INSTR(18) & FDEC_FDEP_IS1_INSTR(19) & 
    FDEC_FDEP_IS1_INSTR(20) & FDEC_FDEP_IS1_INSTR(11) & 
    FDEC_FDEP_IS1_INSTR(12) & FDEC_FDEP_IS1_INSTR(13) & 
    FDEC_FDEP_IS1_INSTR(14) ) , STD_ULOGIC_VECTOR'("000011100"));
MQQ36:SLOWSPR_TABLE_PT(11) <=
    Eq(( FDEC_FDEP_IS1_INSTR(16) & FDEC_FDEP_IS1_INSTR(18) & 
    FDEC_FDEP_IS1_INSTR(19) & FDEC_FDEP_IS1_INSTR(20) & 
    FDEC_FDEP_IS1_INSTR(11) & FDEC_FDEP_IS1_INSTR(12) & 
    FDEC_FDEP_IS1_INSTR(13) & FDEC_FDEP_IS1_INSTR(14) & 
    FDEC_FDEP_IS1_INSTR(15) ) , STD_ULOGIC_VECTOR'("110110000"));
MQQ37:SLOWSPR_TABLE_PT(12) <=
    Eq(( FDEC_FDEP_IS1_INSTR(16) & FDEC_FDEP_IS1_INSTR(17) & 
    FDEC_FDEP_IS1_INSTR(18) & FDEC_FDEP_IS1_INSTR(19) & 
    FDEC_FDEP_IS1_INSTR(20) & FDEC_FDEP_IS1_INSTR(11) & 
    FDEC_FDEP_IS1_INSTR(13) & FDEC_FDEP_IS1_INSTR(14) & 
    FDEC_FDEP_IS1_INSTR(15) ) , STD_ULOGIC_VECTOR'("000011000"));
MQQ38:SLOWSPR_TABLE_PT(13) <=
    Eq(( FDEC_FDEP_IS1_INSTR(16) & FDEC_FDEP_IS1_INSTR(17) & 
    FDEC_FDEP_IS1_INSTR(18) & FDEC_FDEP_IS1_INSTR(19) & 
    FDEC_FDEP_IS1_INSTR(20) & FDEC_FDEP_IS1_INSTR(11) & 
    FDEC_FDEP_IS1_INSTR(12) & FDEC_FDEP_IS1_INSTR(13) & 
    FDEC_FDEP_IS1_INSTR(14) ) , STD_ULOGIC_VECTOR'("010011111"));
MQQ39:SLOWSPR_TABLE_PT(14) <=
    Eq(( FDEC_FDEP_IS1_INSTR(16) & FDEC_FDEP_IS1_INSTR(17) & 
    FDEC_FDEP_IS1_INSTR(18) & FDEC_FDEP_IS1_INSTR(11) & 
    FDEC_FDEP_IS1_INSTR(12) & FDEC_FDEP_IS1_INSTR(13) & 
    FDEC_FDEP_IS1_INSTR(14) & FDEC_FDEP_IS1_INSTR(15)
     ) , STD_ULOGIC_VECTOR'("11110011"));
MQQ40:SLOWSPR_TABLE_PT(15) <=
    Eq(( FDEC_FDEP_IS1_INSTR(16) & FDEC_FDEP_IS1_INSTR(17) & 
    FDEC_FDEP_IS1_INSTR(18) & FDEC_FDEP_IS1_INSTR(19) & 
    FDEC_FDEP_IS1_INSTR(20) & FDEC_FDEP_IS1_INSTR(11) & 
    FDEC_FDEP_IS1_INSTR(12) & FDEC_FDEP_IS1_INSTR(14) & 
    FDEC_FDEP_IS1_INSTR(15) ) , STD_ULOGIC_VECTOR'("010101100"));
MQQ41:SLOWSPR_TABLE_PT(16) <=
    Eq(( FDEC_FDEP_IS1_INSTR(16) & FDEC_FDEP_IS1_INSTR(17) & 
    FDEC_FDEP_IS1_INSTR(18) & FDEC_FDEP_IS1_INSTR(19) & 
    FDEC_FDEP_IS1_INSTR(20) & FDEC_FDEP_IS1_INSTR(11) & 
    FDEC_FDEP_IS1_INSTR(12) & FDEC_FDEP_IS1_INSTR(14)
     ) , STD_ULOGIC_VECTOR'("01010101"));
MQQ42:SLOWSPR_TABLE_PT(17) <=
    Eq(( FDEC_FDEP_IS1_INSTR(16) & FDEC_FDEP_IS1_INSTR(17) & 
    FDEC_FDEP_IS1_INSTR(18) & FDEC_FDEP_IS1_INSTR(19) & 
    FDEC_FDEP_IS1_INSTR(11) & FDEC_FDEP_IS1_INSTR(12) & 
    FDEC_FDEP_IS1_INSTR(13) ) , STD_ULOGIC_VECTOR'("1111111"));
MQQ43:SLOWSPR_TABLE_PT(18) <=
    Eq(( FDEC_FDEP_IS1_INSTR(16) & FDEC_FDEP_IS1_INSTR(17) & 
    FDEC_FDEP_IS1_INSTR(18) & FDEC_FDEP_IS1_INSTR(19) & 
    FDEC_FDEP_IS1_INSTR(20) & FDEC_FDEP_IS1_INSTR(11) & 
    FDEC_FDEP_IS1_INSTR(12) & FDEC_FDEP_IS1_INSTR(13)
     ) , STD_ULOGIC_VECTOR'("11011110"));
MQQ44:SLOWSPR_TABLE_PT(19) <=
    Eq(( FDEC_FDEP_IS1_INSTR(17) & FDEC_FDEP_IS1_INSTR(18) & 
    FDEC_FDEP_IS1_INSTR(19) & FDEC_FDEP_IS1_INSTR(20) & 
    FDEC_FDEP_IS1_INSTR(11) & FDEC_FDEP_IS1_INSTR(12) & 
    FDEC_FDEP_IS1_INSTR(13) & FDEC_FDEP_IS1_INSTR(14)
     ) , STD_ULOGIC_VECTOR'("10111010"));
MQQ45:SLOWSPR_TABLE_PT(20) <=
    Eq(( FDEC_FDEP_IS1_INSTR(16) & FDEC_FDEP_IS1_INSTR(17) & 
    FDEC_FDEP_IS1_INSTR(18) & FDEC_FDEP_IS1_INSTR(20) & 
    FDEC_FDEP_IS1_INSTR(11) ) , STD_ULOGIC_VECTOR'("11101"));
MQQ46:IS_SLOWSPR <= 
    (SLOWSPR_TABLE_PT(1) OR SLOWSPR_TABLE_PT(2)
     OR SLOWSPR_TABLE_PT(3) OR SLOWSPR_TABLE_PT(4)
     OR SLOWSPR_TABLE_PT(5) OR SLOWSPR_TABLE_PT(6)
     OR SLOWSPR_TABLE_PT(7) OR SLOWSPR_TABLE_PT(8)
     OR SLOWSPR_TABLE_PT(9) OR SLOWSPR_TABLE_PT(10)
     OR SLOWSPR_TABLE_PT(11) OR SLOWSPR_TABLE_PT(12)
     OR SLOWSPR_TABLE_PT(13) OR SLOWSPR_TABLE_PT(14)
     OR SLOWSPR_TABLE_PT(15) OR SLOWSPR_TABLE_PT(16)
     OR SLOWSPR_TABLE_PT(17) OR SLOWSPR_TABLE_PT(18)
     OR SLOWSPR_TABLE_PT(19) OR SLOWSPR_TABLE_PT(20)
    );

iu_au_is1_hold  <=  (barrier_in_progress or single_instr_dep_hit);
is2_vld_b                                <=  not is2_vld_L2;
fxu_iss_stall_nor2:     fxu_iss_stall    <=  not (fiss_fdep_is2_take or is2_vld_b);
is2_iss_stall_nor2:     is2_iss_stall_b  <=  not (fxu_iss_stall or au_iu_issue_stall);
internal_is2_stall                       <=  not is2_iss_stall_b;
iu_au_is2_stall          <=  internal_is2_stall;
sync_dep_hit  <=  (is1_instr_is_ISYNC or is1_instr_is_SYNC or is1_instr_is_TLBSYNC) and (shadow_pipe_vld or au_iu_is2_axubusy);
sp_barrier_clr       <=  (xu_iu_rf0_flush and sp_L2(RF0).barrier) or
                       (xu_iu_rf1_flush and sp_L2(RF1).barrier) or
                       (xu_iu_ex1_flush and sp_L2(EX1).barrier) or
                       (xu_iu_ex2_flush and sp_L2(EX2).barrier) or
                       (xu_iu_ex3_flush and sp_EX3_barrier_L2) or
                       (xu_iu_ex4_flush and sp_EX4_barrier_L2) or
                       (xu_iu_ex5_flush and sp_EX5_barrier_L2) ;
an_ac_sync_ack_d         <=  an_ac_sync_ack;
xu_iu_membar_tid_d       <=  xu_iu_membar_tid;
xu_iu_multdiv_done_d     <=  xu_iu_multdiv_done;
mm_iu_barrier_done_d     <=  mm_iu_barrier_done;
spr_fdep_ll_hold_d       <=  spr_fdep_ll_hold;
clr_barrier  <=  xu_iu_larx_done_tid or an_ac_sync_ack_l2 or ic_fdep_icbi_ack or an_ac_stcx_complete or sp_barrier_clr or xu_iu_slowspr_done or xu_iu_multdiv_done_l2 or mm_iu_barrier_done_l2;
set_barrier  <=  (not xu_iu_is2_flush and not barrier_L2 and is2_instr_is_barrier and not internal_is2_stall);
barrier_d_proc : process(barrier_L2, clr_barrier, set_barrier)
begin
barrier_d  <=  barrier_L2;
if ib(set_barrier) then
barrier_d  <=  '1';
elsif ib(clr_barrier) then
barrier_d  <=  '0';
end if;
end process barrier_d_proc;
xu_barrier_d_proc : process(xu_barrier_L2, xu_iu_membar_tid_l2, xu_iu_set_barr_tid)
begin
xu_barrier_d  <=  xu_barrier_L2;
if ib(xu_iu_set_barr_tid) then
xu_barrier_d  <=  '1';
elsif ib(xu_iu_membar_tid_l2) then
xu_barrier_d  <=  '0';
end if;
end process xu_barrier_d_proc;
barrier_in_progress  <=  barrier_L2 or is2_instr_is_barrier or is2_mult_hole_barrier or xu_barrier_L2 or spr_fdep_ll_hold_L2;
quiesce_barrier      <=  barrier_L2 or is2_instr_is_barrier or is2_mult_hole_barrier or xu_barrier_L2;
quiesce_d        <=  ic_fdep_load_quiesce and not quiesce_barrier and not au_iu_is2_axubusy;
iu_xu_quiesce    <=  quiesce_L2;
perf_early_d(0) <=  dep_hit;
perf_early_d(1) <=  fdec_fdep_is1_vld;
perf_early_d(2) <=  internal_is2_stall;
perf_early_d(3) <=  i_afd_is1_instr_v;
perf_early_d(4) <=  au_iu_is1_dep_hit;
perf_early_d(5) <=  barrier_in_progress;
perf_early_d(6) <=  is2_is_slowspr_L2;
perf_early_d(7) <=  RAW_dep_hit;
perf_early_d(8) <=  WAW_LMQ_dep_hit;
perf_early_d(9) <=  sync_dep_hit;
perf_early_d(10) <=  xu_dep_hit;
perf_early_d(11) <=  br_sprs_dep_hit;
perf_dep_hit                     <=  perf_early_l2(0);
perf_fdec_fdep_is1_vld           <=  perf_early_l2(1);
perf_internal_is2_stall          <=  perf_early_l2(2);
perf_i_afd_is1_instr_v           <=  perf_early_l2(3);
perf_au_iu_is1_dep_hit           <=  perf_early_l2(4);
perf_barrier_in_progress         <=  perf_early_l2(5);
perf_is2_is_slowspr_L2           <=  perf_early_l2(6);
perf_RAW_dep_hit                 <=  perf_early_l2(7);
perf_WAW_LMQ_dep_hit             <=  perf_early_l2(8);
perf_sync_dep_hit                <=  perf_early_l2(9);
perf_xu_dep_hit                  <=  perf_early_l2(10);
perf_br_sprs_dep_hit             <=  perf_early_l2(11);
perf_event_d(0) <=  (perf_dep_hit and perf_fdec_fdep_is1_vld) or             
                   (perf_internal_is2_stall and perf_i_afd_is1_instr_v) or 
                   (perf_au_iu_is1_dep_hit);
perf_event_d(1) <=  perf_internal_is2_stall and (perf_fdec_fdep_is1_vld or perf_i_afd_is1_instr_v);
perf_event_d(2) <=  perf_barrier_in_progress and perf_fdec_fdep_is1_vld;
perf_event_d(3) <=  perf_barrier_in_progress and perf_is2_is_slowspr_L2 and perf_fdec_fdep_is1_vld;
perf_event_d(4) <=  perf_RAW_dep_hit and perf_fdec_fdep_is1_vld;
perf_event_d(5) <=  perf_WAW_LMQ_dep_hit and perf_fdec_fdep_is1_vld;
perf_event_d(6) <=  perf_sync_dep_hit and perf_fdec_fdep_is1_vld;
perf_event_d(7) <=  perf_br_sprs_dep_hit and perf_fdec_fdep_is1_vld;
perf_event_d(8) <=  perf_au_iu_is1_dep_hit;
perf_event_d(9) <=  perf_xu_dep_hit and perf_fdec_fdep_is1_vld;
perf_event_d(10) <=  (perf_xu_dep_hit and perf_fdec_fdep_is1_vld) or perf_au_iu_is1_dep_hit;
perf_event_d(11) <=  '0';
fdep_perf_event(0 TO 11) <=  perf_event_l2(0 to 11);
fdep_dbg_data_d(0) <=  barrier_l2;
fdep_dbg_data_d(1) <=  is2_instr_is_barrier;
fdep_dbg_data_d(2) <=  is2_mult_hole_barrier;
fdep_dbg_data_d(3) <=  xu_barrier_L2;
fdep_dbg_data_d(4) <=  xu_iu_larx_done_tid;
fdep_dbg_data_d(5) <=  an_ac_sync_ack;
fdep_dbg_data_d(6) <=  an_ac_stcx_complete;
fdep_dbg_data_d(7) <=  ic_fdep_icbi_ack;
fdep_dbg_data_d(8) <=  sp_barrier_clr;
fdep_dbg_data_d(9) <=  xu_iu_slowspr_done;
fdep_dbg_data_d(10) <=  xu_iu_multdiv_done;
fdep_dbg_data_d(11) <=  mm_iu_barrier_done;
fdep_dbg_data_d(12) <=  xu_iu_set_barr_tid;
fdep_dbg_data_d(13) <=  xu_iu_membar_tid;
fdep_dbg_data_d(14) <=  fdec_fdep_is1_vld;
fdep_dbg_data_d(15) <=  internal_is2_stall;
fdep_dbg_data_d(16) <=  RAW_dep_hit;
fdep_dbg_data_d(17) <=  br_sprs_dep_hit;
fdep_dbg_data_d(18) <=  sync_dep_hit;
fdep_dbg_data_d(19) <=  single_instr_dep_hit;
fdep_dbg_data_d(20) <=  WAW_LMQ_dep_hit;
fdep_dbg_data_d(21) <=  fdec_fdep_is1_force_ram;
fdep_dbg_data(0 TO 21) <=  fdep_dbg_data_l2(0 to 21);
act_nonvalid  <=  fdec_fdep_is1_vld or i_afd_is1_instr_v;
is2_vld: tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type)
  port map (vd          => vdd,
            gd          => gnd,
            nclk    => nclk,
            act     => tiup,
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(is2_vld_offset),
            scout   => sov(is2_vld_offset),
            din     => is2_vld_d,
            dout    => is2_vld_l2);


is2_instr: tri_rlmreg_p
  generic map (width => is2_instr_l2'length, init => 0, expand_type => expand_type)
  port map (vd          => vdd,
            gd          => gnd,
            nclk    => nclk,
            act     => act_nonvalid,
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(is2_instr_offset to is2_instr_offset + is2_instr_l2'length-1),
            scout   => sov(is2_instr_offset to is2_instr_offset + is2_instr_l2'length-1),
            din     => is2_instr_d,
            dout    => is2_instr_l2);


is2_ta_vld: tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type)
  port map (vd          => vdd,
            gd          => gnd,
            nclk    => nclk,
            act     => act_nonvalid,
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(is2_ta_vld_offset),
            scout   => sov(is2_ta_vld_offset),
            din     => is2_ta_vld_d,
            dout    => is2_ta_vld_l2);


is2_ta: tri_rlmreg_p
  generic map (width => is2_ta_l2'length, init => 0, expand_type => expand_type)
  port map (vd          => vdd,
            gd          => gnd,
            nclk    => nclk,
            act     => act_nonvalid,
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(is2_ta_offset to is2_ta_offset + is2_ta_l2'length-1),
            scout   => sov(is2_ta_offset to is2_ta_offset + is2_ta_l2'length-1),
            din     => is2_ta_d,
            dout    => is2_ta_l2);




is2_s1_vld:   tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type)
  port map (vd          => vdd,
            gd          => gnd,
            nclk    => nclk,
            act     => act_nonvalid,
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(is2_s1_vld_offset),
            scout   => sov(is2_s1_vld_offset),
            din     => is2_s1_vld_d,
            dout    => is2_s1_vld_l2);


is2_s1:   tri_rlmreg_p
  generic map (width => is2_s1_l2'length,   init => 0, expand_type => expand_type)
  port map (vd          => vdd,
            gd          => gnd,
            nclk    => nclk,
            act     => act_nonvalid,
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(is2_s1_offset   to is2_s1_offset   + is2_s1_l2'length-1),
            scout   => sov(is2_s1_offset   to is2_s1_offset   + is2_s1_l2'length-1),
            din     => is2_s1_d,
            dout    => is2_s1_l2);



is2_s2_vld:   tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type)
  port map (vd          => vdd,
            gd          => gnd,
            nclk    => nclk,
            act     => act_nonvalid,
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(is2_s2_vld_offset),
            scout   => sov(is2_s2_vld_offset),
            din     => is2_s2_vld_d,
            dout    => is2_s2_vld_l2);


is2_s2:   tri_rlmreg_p
  generic map (width => is2_s2_l2'length,   init => 0, expand_type => expand_type)
  port map (vd          => vdd,
            gd          => gnd,
            nclk    => nclk,
            act     => act_nonvalid,
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(is2_s2_offset   to is2_s2_offset   + is2_s2_l2'length-1),
            scout   => sov(is2_s2_offset   to is2_s2_offset   + is2_s2_l2'length-1),
            din     => is2_s2_d,
            dout    => is2_s2_l2);



is2_s3_vld:   tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type)
  port map (vd          => vdd,
            gd          => gnd,
            nclk    => nclk,
            act     => act_nonvalid,
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(is2_s3_vld_offset),
            scout   => sov(is2_s3_vld_offset),
            din     => is2_s3_vld_d,
            dout    => is2_s3_vld_l2);


is2_s3:   tri_rlmreg_p
  generic map (width => is2_s3_l2'length,   init => 0, expand_type => expand_type)
  port map (vd          => vdd,
            gd          => gnd,
            nclk    => nclk,
            act     => act_nonvalid,
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(is2_s3_offset   to is2_s3_offset   + is2_s3_l2'length-1),
            scout   => sov(is2_s3_offset   to is2_s3_offset   + is2_s3_l2'length-1),
            din     => is2_s3_d,
            dout    => is2_s3_l2);





is2_is_slowspr: tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type)
  port map (vd          => vdd,
            gd          => gnd,
            nclk    => nclk,
            act     => act_nonvalid,
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(is2_is_slowspr_offset),
            scout   => sov(is2_is_slowspr_offset),
            din     => is2_is_slowspr_d,
            dout    => is2_is_slowspr_l2);


is2_is_barrier: tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type)
  port map (vd          => vdd,
            gd          => gnd,
            nclk    => nclk,
            act     => act_nonvalid,
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(is2_is_barrier_offset),
            scout   => sov(is2_is_barrier_offset),
            din     => is2_is_barrier_d,
            dout    => is2_is_barrier_l2);


is2_pred_update: tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type)
  port map (vd          => vdd,
            gd          => gnd,
            nclk    => nclk,
            act     => act_nonvalid,
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(is2_pred_update_offset),
            scout   => sov(is2_pred_update_offset),
            din     => is2_pred_update_d,
            dout    => is2_pred_update_l2);


is2_pred_taken_cnt: tri_rlmreg_p
  generic map (width => is2_pred_taken_cnt_l2'length, init => 0, expand_type => expand_type)
  port map (vd          => vdd,
            gd          => gnd,
            nclk    => nclk,
            act     => act_nonvalid,
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(is2_pred_taken_cnt_offset to is2_pred_taken_cnt_offset + is2_pred_taken_cnt_l2'length-1),
            scout   => sov(is2_pred_taken_cnt_offset to is2_pred_taken_cnt_offset + is2_pred_taken_cnt_l2'length-1),
            din     => is2_pred_taken_cnt_d,
            dout    => is2_pred_taken_cnt_l2);


is2_gshare: tri_rlmreg_p
  generic map (width => is2_gshare_l2'length, init => 0, expand_type => expand_type)
  port map (vd          => vdd,
            gd          => gnd,
            nclk    => nclk,
            act     => act_nonvalid,
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(is2_gshare_offset to is2_gshare_offset + is2_gshare_l2'length-1),
            scout   => sov(is2_gshare_offset to is2_gshare_offset + is2_gshare_l2'length-1),
            din     => is2_gshare_d,
            dout    => is2_gshare_l2);


is2_hole_delay: tri_rlmreg_p
  generic map (width => is2_hole_delay_l2'length, init => 0, expand_type => expand_type)
  port map (vd          => vdd,
            gd          => gnd,
            nclk    => nclk,
            act     => act_nonvalid,
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(is2_hole_delay_offset to is2_hole_delay_offset + is2_hole_delay_l2'length-1),
            scout   => sov(is2_hole_delay_offset to is2_hole_delay_offset + is2_hole_delay_l2'length-1),
            din     => is2_hole_delay_d,
            dout    => is2_hole_delay_l2);

is2_is_ucode: tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type)
  port map (vd          => vdd,
            gd          => gnd,
            nclk    => nclk,
            act     => act_nonvalid,
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(is2_is_ucode_offset),
            scout   => sov(is2_is_ucode_offset),
            din     => is2_is_ucode_d,
            dout    => is2_is_ucode_l2);


is2_to_ucode: tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type)
  port map (vd          => vdd,
            gd          => gnd,
            nclk    => nclk,
            act     => act_nonvalid,
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(is2_to_ucode_offset),
            scout   => sov(is2_to_ucode_offset),
            din     => is2_to_ucode_d,
            dout    => is2_to_ucode_l2);


is2_ifar: tri_rlmreg_p
  generic map (width => is2_ifar_l2'length, init => 0, expand_type => expand_type)
  port map (vd          => vdd,
            gd          => gnd,
            nclk    => nclk,
            act     => act_nonvalid,
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(is2_ifar_offset to is2_ifar_offset + is2_ifar_l2'length-1),
            scout   => sov(is2_ifar_offset to is2_ifar_offset + is2_ifar_l2'length-1),
            din     => is2_ifar_d,
            dout    => is2_ifar_l2);


is2_error: tri_rlmreg_p
  generic map (width => is2_error_l2'length, init => 0, expand_type => expand_type)
  port map (vd          => vdd,
            gd          => gnd,
            nclk    => nclk,
            act     => act_nonvalid,
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(is2_error_offset to is2_error_offset + is2_error_l2'length-1),
            scout   => sov(is2_error_offset to is2_error_offset + is2_error_l2'length-1),
            din     => is2_error_d,
            dout    => is2_error_l2);
sp_IS2_d                 <=  sp_d(IS2).i_nobyp_vld & sp_d(IS2).i_vld & sp_d(IS2).ta_vld & sp_d(IS2).ta &
                           sp_d(IS2).UpdatesLR & sp_d(IS2).UpdatesCR & sp_d(IS2).UpdatesCTR & sp_d(IS2).UpdatesXER & sp_d(IS2).UpdatesMSR & sp_d(IS2).UpdatesSPR &
                           sp_d(IS2).complete & sp_d(IS2).barrier;
sp_l2(IS2).i_nobyp_vld  <= sp_IS2_l2(0);
sp_l2(IS2).i_vld        <= sp_IS2_l2(1);
sp_l2(IS2).ta_vld       <= sp_IS2_l2(2);
sp_l2(IS2).ta           <= sp_IS2_l2(3 to 8);
sp_l2(IS2).updateslr    <= sp_IS2_l2(9);
sp_l2(IS2).updatescr    <= sp_IS2_l2(10);
sp_l2(IS2).updatesctr   <= sp_IS2_l2(11);
sp_l2(IS2).updatesxer   <= sp_IS2_l2(12);
sp_l2(IS2).updatesmsr   <= sp_IS2_l2(13);
sp_l2(IS2).updatesspr   <= sp_IS2_l2(14);
sp_l2(IS2).complete     <= sp_IS2_l2(15 to 19);
sp_l2(IS2).barrier      <= sp_IS2_l2(20);



sp_IS2: tri_rlmreg_p
  generic map (width => 21, init => 0, expand_type => expand_type)
  port map (vd          => vdd,
            gd          => gnd,
            nclk    => nclk,
            act     => sp_IS2_act,
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(sp_IS2_offset to sp_IS2_offset + 21-1),
            scout   => sov(sp_IS2_offset to sp_IS2_offset + 21-1),
            din     => sp_IS2_d,
            dout    => sp_IS2_l2);
sp_RF0_d                 <=  sp_d(RF0).i_nobyp_vld & sp_d(RF0).i_vld & sp_d(RF0).ta_vld & sp_d(RF0).ta &
                           sp_d(RF0).UpdatesLR & sp_d(RF0).UpdatesCR & sp_d(RF0).UpdatesCTR & sp_d(RF0).UpdatesXER & sp_d(RF0).UpdatesMSR & sp_d(RF0).UpdatesSPR &
                           sp_d(RF0).complete & sp_d(RF0).barrier;
sp_l2(RF0).i_nobyp_vld  <= sp_RF0_l2(0);
sp_l2(RF0).i_vld        <= sp_RF0_l2(1);
sp_l2(RF0).ta_vld       <= sp_RF0_l2(2);
sp_l2(RF0).ta           <= sp_RF0_l2(3 to 8);
sp_l2(RF0).updateslr    <= sp_RF0_l2(9);
sp_l2(RF0).updatescr    <= sp_RF0_l2(10);
sp_l2(RF0).updatesctr   <= sp_RF0_l2(11);
sp_l2(RF0).updatesxer   <= sp_RF0_l2(12);
sp_l2(RF0).updatesmsr   <= sp_RF0_l2(13);
sp_l2(RF0).updatesspr   <= sp_RF0_l2(14);
sp_l2(RF0).complete     <= sp_RF0_l2(15 to 19);
sp_l2(RF0).barrier      <= sp_RF0_l2(20);



sp_RF0: tri_rlmreg_p
  generic map (width => 21, init => 0, expand_type => expand_type)
  port map (vd          => vdd,
            gd          => gnd,
            nclk    => nclk,
            act     => sp_RF0_act,
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(sp_RF0_offset to sp_RF0_offset + 21-1),
            scout   => sov(sp_RF0_offset to sp_RF0_offset + 21-1),
            din     => sp_RF0_d,
            dout    => sp_RF0_l2);
sp_RF1_d                 <=  sp_d(RF1).i_nobyp_vld & sp_d(RF1).i_vld & sp_d(RF1).ta_vld & sp_d(RF1).ta &
                           sp_d(RF1).UpdatesLR & sp_d(RF1).UpdatesCR & sp_d(RF1).UpdatesCTR & sp_d(RF1).UpdatesXER & sp_d(RF1).UpdatesMSR & sp_d(RF1).UpdatesSPR &
                           sp_d(RF1).complete & sp_d(RF1).barrier;
sp_l2(RF1).i_nobyp_vld  <= sp_RF1_l2(0);
sp_l2(RF1).i_vld        <= sp_RF1_l2(1);
sp_l2(RF1).ta_vld       <= sp_RF1_l2(2);
sp_l2(RF1).ta           <= sp_RF1_l2(3 to 8);
sp_l2(RF1).updateslr    <= sp_RF1_l2(9);
sp_l2(RF1).updatescr    <= sp_RF1_l2(10);
sp_l2(RF1).updatesctr   <= sp_RF1_l2(11);
sp_l2(RF1).updatesxer   <= sp_RF1_l2(12);
sp_l2(RF1).updatesmsr   <= sp_RF1_l2(13);
sp_l2(RF1).updatesspr   <= sp_RF1_l2(14);
sp_l2(RF1).complete     <= sp_RF1_l2(15 to 19);
sp_l2(RF1).barrier      <= sp_RF1_l2(20);



sp_RF1: tri_rlmreg_p
  generic map (width => 21, init => 0, expand_type => expand_type)
  port map (vd          => vdd,
            gd          => gnd,
            nclk    => nclk,
            act     => sp_RF1_act,
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(sp_RF1_offset to sp_RF1_offset + 21-1),
            scout   => sov(sp_RF1_offset to sp_RF1_offset + 21-1),
            din     => sp_RF1_d,
            dout    => sp_RF1_l2);
sp_EX1_d                 <=  sp_d(EX1).i_nobyp_vld & sp_d(EX1).i_vld & sp_d(EX1).ta_vld & sp_d(EX1).ta &
                           sp_d(EX1).UpdatesLR & sp_d(EX1).UpdatesCR & sp_d(EX1).UpdatesCTR & sp_d(EX1).UpdatesXER & sp_d(EX1).UpdatesMSR & sp_d(EX1).UpdatesSPR &
                           sp_d(EX1).complete & sp_d(EX1).barrier;
sp_l2(EX1).i_nobyp_vld  <= sp_EX1_l2(0);
sp_l2(EX1).i_vld        <= sp_EX1_l2(1);
sp_l2(EX1).ta_vld       <= sp_EX1_l2(2);
sp_l2(EX1).ta           <= sp_EX1_l2(3 to 8);
sp_l2(EX1).updateslr    <= sp_EX1_l2(9);
sp_l2(EX1).updatescr    <= sp_EX1_l2(10);
sp_l2(EX1).updatesctr   <= sp_EX1_l2(11);
sp_l2(EX1).updatesxer   <= sp_EX1_l2(12);
sp_l2(EX1).updatesmsr   <= sp_EX1_l2(13);
sp_l2(EX1).updatesspr   <= sp_EX1_l2(14);
sp_l2(EX1).complete     <= sp_EX1_l2(15 to 19);
sp_l2(EX1).barrier      <= sp_EX1_l2(20);



sp_EX1: tri_rlmreg_p
  generic map (width => 21, init => 0, expand_type => expand_type)
  port map (vd          => vdd,
            gd          => gnd,
            nclk    => nclk,
            act     => sp_EX1_act,
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(sp_EX1_offset to sp_EX1_offset + 21-1),
            scout   => sov(sp_EX1_offset to sp_EX1_offset + 21-1),
            din     => sp_EX1_d,
            dout    => sp_EX1_l2);
sp_EX2_d                 <=  sp_d(EX2).i_nobyp_vld & sp_d(EX2).i_vld & sp_d(EX2).ta_vld & sp_d(EX2).ta &
                           sp_d(EX2).UpdatesLR & sp_d(EX2).UpdatesCR & sp_d(EX2).UpdatesCTR & sp_d(EX2).UpdatesXER & sp_d(EX2).UpdatesMSR & sp_d(EX2).UpdatesSPR &
                           sp_d(EX2).complete & sp_d(EX2).barrier;
sp_l2(EX2).i_nobyp_vld  <= sp_EX2_l2(0);
sp_l2(EX2).i_vld        <= sp_EX2_l2(1);
sp_l2(EX2).ta_vld       <= sp_EX2_l2(2);
sp_l2(EX2).ta           <= sp_EX2_l2(3 to 8);
sp_l2(EX2).updateslr    <= sp_EX2_l2(9);
sp_l2(EX2).updatescr    <= sp_EX2_l2(10);
sp_l2(EX2).updatesctr   <= sp_EX2_l2(11);
sp_l2(EX2).updatesxer   <= sp_EX2_l2(12);
sp_l2(EX2).updatesmsr   <= sp_EX2_l2(13);
sp_l2(EX2).updatesspr   <= sp_EX2_l2(14);
sp_l2(EX2).complete     <= sp_EX2_l2(15 to 19);
sp_l2(EX2).barrier      <= sp_EX2_l2(20);



sp_EX2: tri_rlmreg_p
  generic map (width => 21, init => 0, expand_type => expand_type)
  port map (vd          => vdd,
            gd          => gnd,
            nclk    => nclk,
            act     => sp_EX2_act,
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(sp_EX2_offset to sp_EX2_offset + 21-1),
            scout   => sov(sp_EX2_offset to sp_EX2_offset + 21-1),
            din     => sp_EX2_d,
            dout    => sp_EX2_l2);
sp_IS2_act       <=  sp_l2(IS2).i_nobyp_vld or fdec_fdep_is1_vld;
sp_RF0_act       <=  sp_l2(RF0).i_nobyp_vld or sp_l2(IS2).i_nobyp_vld;
sp_RF1_act       <=  sp_l2(RF1).i_nobyp_vld or sp_l2(RF0).i_nobyp_vld;
sp_EX1_act       <=  sp_l2(EX1).i_nobyp_vld or sp_l2(RF1).i_nobyp_vld;
sp_EX2_act       <=  sp_l2(EX2).i_nobyp_vld or sp_l2(EX1).i_nobyp_vld;
sp_EX3_act       <=  sp_ex3_i_nobyp_vld_l2  or sp_l2(EX2).i_nobyp_vld;
sp_EX4_act       <=  sp_ex4_i_nobyp_vld_l2  or sp_ex3_i_nobyp_vld_l2;
sp_EX5_act       <=  sp_ex5_i_nobyp_vld_l2  or sp_ex4_i_nobyp_vld_l2;


sp_ex3_i_nobyp_vld: tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type)
  port map (vd          => vdd,
            gd          => gnd,
            nclk    => nclk,
            act     => sp_EX3_act,
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(sp_ex3_i_nobyp_vld_offset),
            scout   => sov(sp_ex3_i_nobyp_vld_offset),
            din     => sp_ex3_i_nobyp_vld_d,
            dout    => sp_ex3_i_nobyp_vld_l2);


sp_ex3_barrier: tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type)
  port map (vd          => vdd,
            gd          => gnd,
            nclk    => nclk,
            act     => sp_EX3_act,
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(sp_ex3_barrier_offset),
            scout   => sov(sp_ex3_barrier_offset),
            din     => sp_ex3_barrier_d,
            dout    => sp_ex3_barrier_l2);


sp_ex4_i_nobyp_vld: tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type)
  port map (vd          => vdd,
            gd          => gnd,
            nclk    => nclk,
            act     => sp_EX4_act,
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(sp_ex4_i_nobyp_vld_offset),
            scout   => sov(sp_ex4_i_nobyp_vld_offset),
            din     => sp_ex4_i_nobyp_vld_d,
            dout    => sp_ex4_i_nobyp_vld_l2);


sp_ex4_barrier: tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type)
  port map (vd          => vdd,
            gd          => gnd,
            nclk    => nclk,
            act     => sp_EX4_act,
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(sp_ex4_barrier_offset),
            scout   => sov(sp_ex4_barrier_offset),
            din     => sp_ex4_barrier_d,
            dout    => sp_ex4_barrier_l2);


sp_ex5_i_nobyp_vld: tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type)
  port map (vd          => vdd,
            gd          => gnd,
            nclk    => nclk,
            act     => sp_EX5_act,
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(sp_ex5_i_nobyp_vld_offset),
            scout   => sov(sp_ex5_i_nobyp_vld_offset),
            din     => sp_ex5_i_nobyp_vld_d,
            dout    => sp_ex5_i_nobyp_vld_l2);


sp_ex5_barrier: tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type)
  port map (vd          => vdd,
            gd          => gnd,
            nclk    => nclk,
            act     => sp_EX5_act,
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(sp_ex5_barrier_offset),
            scout   => sov(sp_ex5_barrier_offset),
            din     => sp_ex5_barrier_d,
            dout    => sp_ex5_barrier_l2);
lm_assign: for i in 0 to lmq_entries-1 generate
sp_LM_d(7*i TO 6+7*i) <=  sp_d_LM(i).ta_vld & sp_d_LM(i).ta;
sp_l2_LM(i).ta_vld      <= sp_LM_l2(0+7*i);
sp_l2_LM(i).ta          <= sp_LM_l2(1+7*i to 6+7*i);
end generate;


sp_LM: tri_rlmreg_p
  generic map (width => 7*lmq_entries, init => 0, expand_type => expand_type)
  port map (vd          => vdd,
            gd          => gnd,
            nclk    => nclk,
            act     => tiup,
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(sp_lm_offset to sp_lm_offset + 7*lmq_entries-1),
            scout   => sov(sp_lm_offset to sp_lm_offset + 7*lmq_entries-1),
            din     => sp_LM_d,
            dout    => sp_LM_l2);



barrier: tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type)
  port map (vd          => vdd,
            gd          => gnd,
            nclk    => nclk,
            act     => tiup,
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(barrier_offset),
            scout   => sov(barrier_offset),
            din     => barrier_d,
            dout    => barrier_l2);


xu_barrier: tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type)
  port map (vd          => vdd,
            gd          => gnd,
            nclk    => nclk,
            act     => tiup,
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(xu_barrier_offset),
            scout   => sov(xu_barrier_offset),
            din     => xu_barrier_d,
            dout    => xu_barrier_l2);


mult_hole_barrier: tri_rlmreg_p
  generic map (width => mult_hole_barrier_l2'length, init => 0, expand_type => expand_type)
  port map (vd          => vdd,
            gd          => gnd,
            nclk    => nclk,
            act     => mult_hole_barrier_act,
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(mult_hole_barrier_offset to mult_hole_barrier_offset + mult_hole_barrier_l2'length-1),
            scout   => sov(mult_hole_barrier_offset to mult_hole_barrier_offset + mult_hole_barrier_l2'length-1),
            din     => mult_hole_barrier_d,
            dout    => mult_hole_barrier_l2);

is2_axu_ld_or_st: tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type)
  port map (vd          => vdd,
            gd          => gnd,
            nclk    => nclk,
            act     => act_nonvalid,
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(is2_axu_ld_or_st_offset),
            scout   => sov(is2_axu_ld_or_st_offset),
            din     => is2_axu_ld_or_st_d,
            dout    => is2_axu_ld_or_st_l2);


is2_axu_store: tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type)
  port map (vd          => vdd,
            gd          => gnd,
            nclk    => nclk,
            act     => act_nonvalid,
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(is2_axu_store_offset),
            scout   => sov(is2_axu_store_offset),
            din     => is2_axu_store_d,
            dout    => is2_axu_store_l2);


is2_axu_ldst_indexed: tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type)
  port map (vd          => vdd,
            gd          => gnd,
            nclk    => nclk,
            act     => act_nonvalid,
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(is2_axu_ldst_indexed_offset),
            scout   => sov(is2_axu_ldst_indexed_offset),
            din     => is2_axu_ldst_indexed_d,
            dout    => is2_axu_ldst_indexed_l2);


is2_axu_ldst_tag: tri_rlmreg_p
  generic map (width => is2_axu_ldst_tag_l2'length, init => 0, expand_type => expand_type)
  port map (vd          => vdd,
            gd          => gnd,
            nclk    => nclk,
            act     => act_nonvalid,
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(is2_axu_ldst_tag_offset to is2_axu_ldst_tag_offset + is2_axu_ldst_tag_l2'length-1),
            scout   => sov(is2_axu_ldst_tag_offset to is2_axu_ldst_tag_offset + is2_axu_ldst_tag_l2'length-1),
            din     => is2_axu_ldst_tag_d,
            dout    => is2_axu_ldst_tag_l2);


is2_axu_ldst_size: tri_rlmreg_p
  generic map (width => is2_axu_ldst_size_l2'length, init => 0, expand_type => expand_type)
  port map (vd          => vdd,
            gd          => gnd,
            nclk    => nclk,
            act     => act_nonvalid,
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(is2_axu_ldst_size_offset to is2_axu_ldst_size_offset + is2_axu_ldst_size_l2'length-1),
            scout   => sov(is2_axu_ldst_size_offset to is2_axu_ldst_size_offset + is2_axu_ldst_size_l2'length-1),
            din     => is2_axu_ldst_size_d,
            dout    => is2_axu_ldst_size_l2);



is2_axu_ldst_update: tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type)
  port map (vd          => vdd,
            gd          => gnd,
            nclk    => nclk,
            act     => act_nonvalid,
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(is2_axu_ldst_update_offset),
            scout   => sov(is2_axu_ldst_update_offset),
            din     => is2_axu_ldst_update_d,
            dout    => is2_axu_ldst_update_l2);


is2_axu_ldst_extpid: tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type)
  port map (vd          => vdd,
            gd          => gnd,
            nclk    => nclk,
            act     => act_nonvalid,
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(is2_axu_ldst_extpid_offset),
            scout   => sov(is2_axu_ldst_extpid_offset),
            din     => is2_axu_ldst_extpid_d,
            dout    => is2_axu_ldst_extpid_l2);


is2_axu_ldst_forcealign: tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type)
  port map (vd          => vdd,
            gd          => gnd,
            nclk    => nclk,
            act     => act_nonvalid,
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(is2_axu_ldst_forcealign_offset),
            scout   => sov(is2_axu_ldst_forcealign_offset),
            din     => is2_axu_ldst_forcealign_d,
            dout    => is2_axu_ldst_forcealign_l2);


is2_axu_ldst_forceexcept: tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type)
  port map (vd          => vdd,
            gd          => gnd,
            nclk    => nclk,
            act     => act_nonvalid,
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(is2_axu_ldst_forceexcept_offset),
            scout   => sov(is2_axu_ldst_forceexcept_offset),
            din     => is2_axu_ldst_forceexcept_d,
            dout    => is2_axu_ldst_forceexcept_l2);


is2_axu_movedp: tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type)
  port map (vd          => vdd,
            gd          => gnd,
            nclk    => nclk,
            act     => act_nonvalid,
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(is2_axu_movedp_offset),
            scout   => sov(is2_axu_movedp_offset),
            din     => is2_axu_movedp_d,
            dout    => is2_axu_movedp_l2);


is2_axu_mffgpr: tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type)
  port map (vd          => vdd,
            gd          => gnd,
            nclk    => nclk,
            act     => act_nonvalid,
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(is2_axu_mffgpr_offset),
            scout   => sov(is2_axu_mffgpr_offset),
            din     => is2_axu_mffgpr_d,
            dout    => is2_axu_mffgpr_l2);


is2_axu_mftgpr: tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type)
  port map (vd          => vdd,
            gd          => gnd,
            nclk    => nclk,
            act     => act_nonvalid,
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(is2_axu_mftgpr_offset),
            scout   => sov(is2_axu_mftgpr_offset),
            din     => is2_axu_mftgpr_d,
            dout    => is2_axu_mftgpr_l2);


is2_axu_instr_type: tri_rlmreg_p
  generic map (width => is2_axu_instr_type_l2'length, init => 0, expand_type => expand_type)
  port map (vd          => vdd,
            gd          => gnd,
            nclk    => nclk,
            act     => act_nonvalid,
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(is2_axu_instr_type_offset to is2_axu_instr_type_offset + is2_axu_instr_type_l2'length-1),
            scout   => sov(is2_axu_instr_type_offset to is2_axu_instr_type_offset + is2_axu_instr_type_l2'length-1),
            din     => is2_axu_instr_type_d,
            dout    => is2_axu_instr_type_l2);


is2_match: tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type)
  port map (vd          => vdd,
            gd          => gnd,
            nclk    => nclk,
            act     => act_nonvalid,
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(is2_match_offset),
            scout   => sov(is2_match_offset),
            din     => is2_match_d,
            dout    => is2_match_l2);


is2_2ucode: tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type)
  port map (vd          => vdd,
            gd          => gnd,
            nclk    => nclk,
            act     => act_nonvalid,
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(is2_2ucode_offset),
            scout   => sov(is2_2ucode_offset),
            din     => is2_2ucode_d,
            dout    => is2_2ucode_l2);


is2_2ucode_type: tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type)
  port map (vd          => vdd,
            gd          => gnd,
            nclk    => nclk,
            act     => act_nonvalid,
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(is2_2ucode_type_offset),
            scout   => sov(is2_2ucode_type_offset),
            din     => is2_2ucode_type_d,
            dout    => is2_2ucode_type_l2);



single_instr_mode: tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type)
  port map (vd          => vdd,
            gd          => gnd,
            nclk    => nclk,
            act     => tiup,
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(single_instr_mode_offset),
            scout   => sov(single_instr_mode_offset),
            din     => single_instr_mode_d,
            dout    => single_instr_mode_l2);
event_bus_enable_d  <=  pc_iu_event_bus_enable;


event_enable_reg: tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => tiup,
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(event_bus_enable_offset),
            scout   => sov(event_bus_enable_offset),
            din     => event_bus_enable_d,
            dout    => event_bus_enable_q);
trace_bus_enable_d  <=  pc_iu_trace_bus_enable;


trace_enable_reg: tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => tiup,
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(trace_bus_enable_offset),
            scout   => sov(trace_bus_enable_offset),
            din     => trace_bus_enable_d,
            dout    => trace_bus_enable_q);


perf_early: tri_rlmreg_p
  generic map (width => perf_early_l2'length, init => 0, expand_type => expand_type)
  port map (vd          => vdd,
            gd          => gnd,
            nclk    => nclk,
            act     => event_bus_enable_q,
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(perf_early_offset to perf_early_offset + perf_early_l2'length-1),
            scout   => sov(perf_early_offset to perf_early_offset + perf_early_l2'length-1),
            din     => perf_early_d,
            dout    => perf_early_l2);


perf_event: tri_rlmreg_p
  generic map (width => perf_event_l2'length, init => 0, expand_type => expand_type)
  port map (vd          => vdd,
            gd          => gnd,
            nclk    => nclk,
            act     => event_bus_enable_q,
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(perf_event_offset to perf_event_offset + perf_event_l2'length-1),
            scout   => sov(perf_event_offset to perf_event_offset + perf_event_l2'length-1),
            din     => perf_event_d,
            dout    => perf_event_l2);


fdep_dbg_data_reg: tri_rlmreg_p
  generic map (width => fdep_dbg_data_l2'length, init => 0, expand_type => expand_type)
  port map (vd          => vdd,
            gd          => gnd,
            nclk    => nclk,
            act     => trace_bus_enable_q,
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(fdep_dbg_data_offset to fdep_dbg_data_offset + fdep_dbg_data_l2'length-1),
            scout   => sov(fdep_dbg_data_offset to fdep_dbg_data_offset + fdep_dbg_data_l2'length-1),
            din     => fdep_dbg_data_d,
            dout    => fdep_dbg_data_l2);

quiesce: tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type)
  port map (vd          => vdd,
            gd          => gnd,
            nclk    => nclk,
            act     => tiup,
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,

            scin    => siv(quiesce_offset),
            scout   => sov(quiesce_offset),
            din     => quiesce_d,
            dout    => quiesce_l2);

an_ac_sync_ack_latch: tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type)
  port map (vd          => vdd,
            gd          => gnd,
            nclk    => nclk,
            act     => tiup,
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(an_ac_sync_ack_offset),
            scout   => sov(an_ac_sync_ack_offset),
            din     => an_ac_sync_ack_d,
            dout    => an_ac_sync_ack_l2);


xu_iu_membar_tid_latch: tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type)
  port map (vd          => vdd,
            gd          => gnd,
            nclk    => nclk,
            act     => tiup,
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(xu_iu_membar_tid_offset),
            scout   => sov(xu_iu_membar_tid_offset),
            din     => xu_iu_membar_tid_d,
            dout    => xu_iu_membar_tid_l2);


xu_iu_multdiv_done_latch: tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type)
  port map (vd          => vdd,
            gd          => gnd,
            nclk    => nclk,
            act     => tiup,
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(xu_iu_multdiv_done_offset),
            scout   => sov(xu_iu_multdiv_done_offset),
            din     => xu_iu_multdiv_done_d,
            dout    => xu_iu_multdiv_done_l2);


mm_iu_barrier_done_latch: tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type)
  port map (vd          => vdd,
            gd          => gnd,
            nclk    => nclk,
            act     => tiup,
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(mm_iu_barrier_done_offset),
            scout   => sov(mm_iu_barrier_done_offset),
            din     => mm_iu_barrier_done_d,
            dout    => mm_iu_barrier_done_l2);


spr_fdep_ll_hold_latch: tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type)
  port map (vd          => vdd,
            gd          => gnd,
            nclk    => nclk,
            act     => tiup,
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(spr_fdep_ll_hold_offset),
            scout   => sov(spr_fdep_ll_hold_offset),
            din     => spr_fdep_ll_hold_d,
            dout    => spr_fdep_ll_hold_l2);


en_dcr_latch: tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type)
  port map (vd          => vdd,
            gd          => gnd,
            nclk    => nclk,
            act     => tiup,
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(en_dcr_offset),
            scout   => sov(en_dcr_offset),
            din     => en_dcr_d,
            dout    => en_dcr_l2);


spare_latch: tri_rlmreg_p
  generic map (width => spare_l2'length, init => 0, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => tiup,
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(spare_offset to spare_offset + spare_l2'length-1),
            scout   => sov(spare_offset to spare_offset + spare_l2'length-1),
            din     => spare_l2,
            dout    => spare_l2);
fdep_fiss_is2_instr              <=  is2_instr_l2;
fdep_fiss_is2_ta_vld             <=  is2_ta_vld_l2;
fdep_fiss_is2_ta                 <=  is2_ta_l2;
fdep_fiss_is2_s1_vld             <=  is2_s1_vld_l2;
fdep_fiss_is2_s1                 <=  is2_s1_l2;
fdep_fiss_is2_s2_vld             <=  is2_s2_vld_l2;
fdep_fiss_is2_s2                 <=  is2_s2_l2;
fdep_fiss_is2_s3_vld             <=  is2_s3_vld_l2;
fdep_fiss_is2_s3                 <=  is2_s3_l2;
fdep_fiss_is2_pred_update        <=  is2_pred_update_l2;
fdep_fiss_is2_pred_taken_cnt     <=  is2_pred_taken_cnt_l2;
fdep_fiss_is2_gshare             <=  is2_gshare_l2;
fdep_fiss_is2_ifar               <=  is2_ifar_l2;
fdep_fiss_is2_error              <=  is2_error_l2;
fdep_fiss_is2_axu_ld_or_st       <=  is2_axu_ld_or_st_L2;
fdep_fiss_is2_axu_store          <=  is2_axu_store_L2;
fdep_fiss_is2_axu_ldst_indexed   <=  is2_axu_ldst_indexed_L2;
fdep_fiss_is2_axu_ldst_tag       <=  is2_axu_ldst_tag_L2;
fdep_fiss_is2_axu_ldst_size      <=  is2_axu_ldst_size_L2;
fdep_fiss_is2_axu_ldst_update      <=  is2_axu_ldst_update_L2;
fdep_fiss_is2_axu_ldst_extpid      <=  is2_axu_ldst_extpid_L2;
fdep_fiss_is2_axu_ldst_forcealign  <=  is2_axu_ldst_forcealign_L2;
fdep_fiss_is2_axu_ldst_forceexcept <=  is2_axu_ldst_forceexcept_L2;
fdep_fiss_is2_axu_mftgpr         <=  is2_axu_mftgpr_L2;
fdep_fiss_is2_axu_mffgpr         <=  is2_axu_mffgpr_L2;
fdep_fiss_is2_axu_movedp        <=  is2_axu_movedp_L2;
fdep_fiss_is2_axu_instr_type     <=  is2_axu_instr_type_L2;
fdep_fiss_is2_match              <=  is2_match_L2;
fdep_fiss_is2_2ucode             <=  is2_2ucode_L2;
fdep_fiss_is2_2ucode_type        <=  is2_2ucode_type_L2;
fdep_fiss_is2_hole_delay         <=  is2_hole_delay_L2;
fdep_fiss_is2_to_ucode           <=  is2_to_ucode_L2;
fdep_fiss_is2_is_ucode           <=  is2_is_ucode_L2;
fdep_fiss_is2early_vld           <=  fdec_fdep_is1_vld;
fdep_fiss_is1_xu_dep_hit_b       <=  fxu_dep_hit_b;
siv(0 TO scan_right) <=  sov(1 to scan_right) & scan_in;
scan_out  <=  sov(0);
END IUQ_FXU_DEP;

