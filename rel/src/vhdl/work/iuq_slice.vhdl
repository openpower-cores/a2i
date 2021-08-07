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

			

--********************************************************************
--*
--* TITLE: Instruction Unit
--*
--* NAME: iuq_slice.vhdl
--*
--*********************************************************************
library ieee;
use ieee.std_logic_1164.all;
library ibm;
use ibm.std_ulogic_support.all;
use ibm.std_ulogic_function_support.all;
use ibm.std_ulogic_unsigned.all;
library support;
use support.power_logic_pkg.all;
library work;
use work.iuq_pkg.all;
library tri;
use tri.tri_latches_pkg.all;

entity iuq_slice is
  generic(expand_type           : integer := 2; 
          regmode               : integer := 6;
          a2mode                : integer := 1;
          lmq_entries           : integer := 8);
port(
     slice_id                           : in std_ulogic_vector(0 to 1);
     vdd                                : inout power_logic;
     gnd                                : inout power_logic;
     nclk                               : in clk_logic;
     pc_iu_sg_2                         : in std_ulogic;
     pc_iu_func_sl_thold_2              : in std_ulogic;
     clkoff_b                           : in std_ulogic;
     an_ac_scan_dis_dc_b                : in  std_ulogic;
     tc_ac_ccflush_dc                   : in std_ulogic;
     delay_lclkr                        : in std_ulogic;
     mpw1_b                             : in std_ulogic;
     scan_in                            : in std_ulogic;
     scan_out                           : out std_ulogic;


     pc_iu_trace_bus_enable             : in  std_ulogic;
     pc_iu_event_bus_enable             : in  std_ulogic;
     fdep_dbg_data                      : out std_ulogic_vector(0 to 21);
     fdep_perf_event                    : out std_ulogic_vector(0 to 11);

     pc_iu_ram_mode                     : in  std_ulogic;
     pc_iu_ram_thread                   : in  std_ulogic_vector(0 to 1);

     spr_dec_mask                       : in std_ulogic_vector(0 to 31);
     spr_dec_match                      : in std_ulogic_vector(0 to 31);
     iu_au_config_iucr                  : in std_ulogic_vector(0 to 7);
     iu_au_config_iucr_pt               : out std_ulogic_vector(2 to 4);
     spr_fdep_ll_hold                   : in  std_ulogic;


     uc_flush                           : in std_ulogic;
     xu_iu_flush                        : in std_ulogic;
     xu_iu_rf1_flush                    : in std_ulogic;
     xu_iu_ex1_flush                    : in std_ulogic;
     xu_iu_ex2_flush                    : in std_ulogic;
     xu_iu_ex3_flush                    : in std_ulogic;
     xu_iu_ex4_flush                    : in std_ulogic;
     xu_iu_ex5_flush                    : in std_ulogic;

     iu_au_ib1_instr_vld                : in std_ulogic;
     iu_au_ib1_ifar                     : in EFF_IFAR;
     iu_au_ib1_data                     : in std_ulogic_vector(0 to 49);


     fdec_ibuf_stall                    : out std_ulogic;


xu_iu_ucode_restart                : in std_ulogic;
xu_iu_slowspr_done                 : in std_ulogic;
xu_iu_multdiv_done                 : in std_ulogic;
xu_iu_ex4_loadmiss_vld             : in std_ulogic;
xu_iu_ex4_loadmiss_qentry          : in std_ulogic_vector(0 to lmq_entries-1);
xu_iu_ex4_loadmiss_target          : in std_ulogic_vector(0 to 8);
xu_iu_ex4_loadmiss_target_type     : in std_ulogic_vector(0 to 1);
xu_iu_ex5_loadmiss_vld             : in std_ulogic;
xu_iu_ex5_loadmiss_qentry          : in std_ulogic_vector(0 to lmq_entries-1);
xu_iu_ex5_loadmiss_target          : in std_ulogic_vector(1 to 6);
xu_iu_ex5_loadmiss_target_type     : in std_ulogic_vector(0 to 0);
xu_iu_complete_vld                 : in std_ulogic;
xu_iu_complete_qentry              : in std_ulogic_vector(0 to lmq_entries-1);
xu_iu_complete_target_type         : in std_ulogic_vector(0 to 1);
xu_iu_single_instr_mode            : in std_ulogic;
ic_fdep_load_quiesce               : in  std_ulogic;
iu_xu_quiesce                      : out std_ulogic;
xu_iu_membar_tid                   : in  std_ulogic;
xu_iu_set_barr_tid                 : in  std_ulogic;
xu_iu_larx_done_tid                : in  std_ulogic;
an_ac_sync_ack                     : in  std_ulogic;
an_ac_stcx_complete         	: in  std_ulogic;
ic_fdep_icbi_ack                   : in  std_ulogic;
mm_iu_barrier_done                 : in  std_ulogic;
xu_iu_spr_ccr2_en_dcr              : in  std_ulogic;
fiss_fdep_is2_take                 : in std_ulogic;
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
fdep_fiss_is2_ifar                 : out eff_ifar;
fdep_fiss_is2_error                : out std_ulogic_vector(0 to 2);
fdep_fiss_is2_axu_ld_or_st         : out std_ulogic;
fdep_fiss_is2_axu_store            : out std_ulogic;
fdep_fiss_is2_axu_ldst_indexed     : out std_ulogic;
fdep_fiss_is2_axu_ldst_tag         : out std_ulogic_vector(0 to 8);
fdep_fiss_is2_axu_ldst_size        : out std_ulogic_vector(0 to 5);
fdep_fiss_is2_axu_ldst_update      : out std_ulogic;
fdep_fiss_is2_axu_ldst_extpid      : out std_ulogic;
fdep_fiss_is2_axu_ldst_forcealign  : out std_ulogic;
fdep_fiss_is2_axu_ldst_forceexcept  : out std_ulogic;
fdep_fiss_is2_axu_mftgpr        : out std_ulogic;
fdep_fiss_is2_axu_mffgpr        : out std_ulogic;
fdep_fiss_is2_axu_movedp        : out std_ulogic;
fdep_fiss_is2_axu_instr_type        : out std_ulogic_vector(0 to 2);
fdep_fiss_is2_match                : out std_ulogic;
fdep_fiss_is2_2ucode                : out std_ulogic;
fdep_fiss_is2_2ucode_type                : out std_ulogic;
fdep_fiss_is2early_vld             : out std_ulogic;
fdep_fiss_is1_xu_dep_hit_b         : out std_ulogic;
fdep_fiss_is2_hole_delay           : out std_ulogic_vector(0 to 2);
fdep_fiss_is2_to_ucode             : out std_ulogic;
fdep_fiss_is2_is_ucode             : out std_ulogic;
fu_iu_uc_special                   : in std_ulogic;
iu_fu_ex2_n_flush                  : out std_ulogic;
i_afi_is2_take                     : in std_ulogic;
i_axu_is1_early_v                  : out std_ulogic;
i_axu_is1_dep_hit_b                : out std_ulogic;
i_axu_is2_instr_match              : out std_ulogic;
i_axu_is2_instr_v                  : out std_ulogic;
i_axu_is2_fra                      : out std_ulogic_vector(0 to 6);
i_axu_is2_frb                      : out std_ulogic_vector(0 to 6);
i_axu_is2_frc                      : out std_ulogic_vector(0 to 6);
i_axu_is2_frt                      : out std_ulogic_vector(0 to 6);
i_axu_is2_fra_v                    : out std_ulogic;
i_axu_is2_frb_v                    : out std_ulogic;
i_axu_is2_frc_v                    : out std_ulogic;
i_afd_is2_is_ucode                 : out std_ulogic;
i_afd_ignore_flush_is2             : out std_ulogic;
i_afd_in_ucode_mode_or1d_b         : out std_ulogic;
ifdp_is2_est_bubble3               : out std_ulogic;
ifdp_is2_bypsel                    : out std_ulogic_vector(0 to 5);
axu_dbg_data                       : out std_ulogic_vector(00 to 37)
 );
-- synopsys translate_off
-- synopsys translate_on
end iuq_slice;
architecture iuq_slice of iuq_slice is
constant ibuff_data_width               : integer := 42;
-- scan chain 0
constant scan_dec                       : natural := 0;
constant scan_dep                       : natural := 1;
constant scan_axu_dec                   : natural := 2;
constant scan_axu_dep                   : natural := 3;
constant scan_right                     : natural := 3;
signal au_iu_is0_to_ucode               : std_ulogic;
signal au_iu_is0_ucode_only             : std_ulogic;
-- flush
signal ib1_flush                        : std_ulogic;
signal is1_flush                        : std_ulogic;
signal is2_flush                        : std_ulogic;
signal rf0_flush                        : std_ulogic;
-- ib signals
signal iu_au_ib1_instr0                 : std_ulogic_vector(0 to 31);
signal iu_au_ib1_instr0_pred_vld        : std_ulogic;
signal iu_au_ib1_instr0_ucode_ext       : std_ulogic_vector(0 to 3);
signal iu_au_ib1_instr0_pred_taken_cnt  : std_ulogic_vector(0 to 1);
signal iu_au_ib1_instr0_error           : std_ulogic_vector(0 to 2);
signal iu_au_ib1_instr0_is_ucode        : std_ulogic;
signal iu_au_ib1_instr0_2ucode          : std_ulogic;
signal iu_au_ib1_instr0_2ucode_type     : std_ulogic;
signal iu_au_ib1_instr0_force_ram       : std_ulogic;
signal iu_au_ib1_instr0_gshare          : std_ulogic_vector(0 to 3);
-- is signals
signal iu_au_is1_cr_user_v              : std_ulogic;
signal iu_au_is0_cr_setter              : std_ulogic;
signal i_afd_is1_cr_setter              : std_ulogic;
-- fdec signals
signal fdec_fdep_is1_vld                : std_ulogic;
signal fdec_fdep_is1_instr              : std_ulogic_vector(0 to 31);
signal fdec_fdep_is1_ta_vld             : std_ulogic;
signal fdec_fdep_is1_ta                 : std_ulogic_vector(0 to 5);
signal fdec_fdep_is1_s1_vld             : std_ulogic;
signal fdec_fdep_is1_s1                 : std_ulogic_vector(0 to 5);
signal fdec_fdep_is1_s2_vld             : std_ulogic;
signal fdec_fdep_is1_s2                 : std_ulogic_vector(0 to 5);
signal fdec_fdep_is1_s3_vld             : std_ulogic;
signal fdec_fdep_is1_s3                 : std_ulogic_vector(0 to 5);
signal fdec_fdep_is1_pred_update        : std_ulogic;
signal fdec_fdep_is1_pred_taken_cnt     : std_ulogic_vector(0 to 1);
signal fdec_fdep_is1_gshare             : std_ulogic_vector(0 to 3);
signal fdec_fdep_is1_UpdatesLR          : std_ulogic;
signal fdec_fdep_is1_UpdatesCR          : std_ulogic;
signal fdec_fdep_is1_UpdatesCTR         : std_ulogic;
signal fdec_fdep_is1_UpdatesXER         : std_ulogic;
signal fdec_fdep_is1_UpdatesMSR         : std_ulogic;
signal fdec_fdep_is1_UpdatesSPR         : std_ulogic;
signal fdec_fdep_is1_UsesLR             : std_ulogic;
signal fdec_fdep_is1_UsesCR             : std_ulogic;
signal fdec_fdep_is1_UsesCTR            : std_ulogic;
signal fdec_fdep_is1_UsesXER            : std_ulogic;
signal fdec_fdep_is1_UsesMSR            : std_ulogic;
signal fdec_fdep_is1_UsesSPR            : std_ulogic;
signal fdec_fdep_is1_hole_delay         : std_ulogic_vector(0 to 2);
signal fdec_fdep_is1_ld_vld              : std_ulogic;
signal fdec_fdep_is1_to_ucode           : std_ulogic;
signal fdec_fdep_is1_is_ucode           : std_ulogic;
signal fdec_fdep_is1_ifar               : EFF_IFAR;
signal fdec_fdep_is1_error              : std_ulogic_vector(0 to 2);
signal fdec_fdep_is1_complete           : std_ulogic_vector(0 to 4);
signal fdec_fdep_is1_axu_ld_or_st       : std_ulogic;
signal fdec_fdep_is1_axu_store          : std_ulogic;
signal fdec_fdep_is1_axu_ldst_indexed   : std_ulogic;
signal fdec_fdep_is1_axu_ldst_tag       : std_ulogic_vector(0 to 8);
signal fdec_fdep_is1_axu_ldst_size      : std_ulogic_vector(0 to 5);
signal fdec_fdep_is1_axu_ldst_update    : std_ulogic;
signal fdec_fdep_is1_axu_ldst_extpid    : std_ulogic;
signal fdec_fdep_is1_axu_ldst_forcealign: std_ulogic;
signal fdec_fdep_is1_axu_ldst_forceexcept: std_ulogic;
signal fdec_fdep_is1_axu_mftgpr      : std_ulogic;
signal fdec_fdep_is1_axu_mffgpr      : std_ulogic;
signal fdec_fdep_is1_axu_movedp      : std_ulogic;
signal fdec_fdep_is1_axu_instr_type      : std_ulogic_vector(0 to 2);
signal fdec_fdep_is1_match              : std_ulogic;
signal fdec_fdep_is1_2ucode              : std_ulogic;
signal fdec_fdep_is1_2ucode_type              : std_ulogic;
signal fdec_fdep_is1_force_ram              : std_ulogic;
signal iu_au_is2_stall                  : std_ulogic;
signal iu_au_is1_stall_int              : std_ulogic;
-- This is a barrier operation that will stop axu issue
signal iu_au_is1_hold                   : std_ulogic;
signal fdep_fdec_buff_stall             : std_ulogic;
signal fdep_fdec_weak_stall             : std_ulogic;
-- axu dec signals
signal au_iu_ib1_store                  : std_ulogic;
signal au_iu_ib1_ldst_size              : std_ulogic_vector(0 to 5);
signal au_iu_ib1_ldst_tag               : std_ulogic_vector(0 to 8);
signal au_iu_ib1_ldst_ra_v              : std_ulogic;
signal au_iu_ib1_ldst_ra                : std_ulogic_vector(0 to 6);
signal au_iu_ib1_ldst_rb_v              : std_ulogic;
signal au_iu_ib1_ldst_rb                : std_ulogic_vector(0 to 6);
signal au_iu_ib1_ldst_dimm              : std_ulogic_vector(0 to 15);
signal au_iu_ib1_ldst_indexed           : std_ulogic;
signal au_iu_ib1_ldst_update            : std_ulogic;
signal au_iu_ib1_ldst_extpid            : std_ulogic;
signal au_iu_ib1_ldst_forcealign        : std_ulogic;
signal au_iu_ib1_ldst_forceexcept        : std_ulogic;
signal au_iu_ib1_mftgpr              : std_ulogic;
signal au_iu_ib1_mffgpr              : std_ulogic;
signal au_iu_ib1_movedp              : std_ulogic;
signal au_iu_ib1_instr_type              : std_ulogic_vector(0 to 2);
signal au_iu_ib1_ldst                   : std_ulogic;
signal au_iu_ib1_ldst_v               : std_ulogic;
signal au_iu_i_dec_b                    : std_ulogic;
signal i_afd_is1_fra_v                  : std_ulogic;
signal i_afd_is1_frb_v                  : std_ulogic;
signal i_afd_is1_frc_v                  : std_ulogic;
signal i_afd_is1_frt_v                  : std_ulogic;
signal i_afd_is1_prebubble1             : std_ulogic;
signal i_afd_is1_est_bubble3            : std_ulogic;
signal i_afd_is1_cr_writer              : std_ulogic;
signal i_afd_is1_fra                    : std_ulogic_vector(0 to 6);
signal i_afd_is1_frb                    : std_ulogic_vector(0 to 6);
signal i_afd_is1_frc                    : std_ulogic_vector(0 to 6);
signal i_afd_is1_frt                    : std_ulogic_vector(0 to 6);
signal i_afd_is1_instr_v                : std_ulogic;
signal i_afd_is1_instr_ldst_v           : std_ulogic;
signal i_afd_is1_instr_ld_v             : std_ulogic;
signal i_afd_is1_is_ucode               : std_ulogic;
signal i_afd_is1_to_ucode               : std_ulogic;
signal i_afd_ignore_flush_is1_int       : std_ulogic;
signal i_afd_config_iucr                : std_ulogic_vector(1 to 7);
signal i_afd_in_ucode_mode_or1d         : std_ulogic;
signal i_afd_is1_fra_buf                : std_ulogic_vector(1 to 6);
signal i_afd_is1_frb_buf                : std_ulogic_vector(1 to 6);
signal i_afd_is1_frc_buf                : std_ulogic_vector(1 to 6);
signal i_afd_is1_frt_buf                : std_ulogic_vector(1 to 6);
signal i_afd_is1_divsqrt                : std_ulogic;
signal i_afd_is1_stall_rep              : std_ulogic;
signal i_afd_is1_instr_sto_v            : std_ulogic;
-- axu dep signals
signal au_iu_is1_dep_hit                : std_ulogic;
signal au_iu_is1_dep_hit_b                : std_ulogic;
signal au_iu_is2_axubusy                : std_ulogic;
signal au_iu_issue_stall                : std_ulogic;
signal ifdp_ex5_fmul_uc_complete        : std_ulogic;
signal i_afd_fmul_uc_is1                : std_ulogic;
signal pc_au_ram_mode                   : std_ulogic;
signal pc_au_ram_thread_v               : std_ulogic;
signal fu_dec_debug :  std_ulogic_vector(0 to 13);
signal fu_dep_debug :  std_ulogic_vector(0 to 23);
-- scan signals
signal siv                              : std_ulogic_vector(0 to scan_right);
signal sov                              : std_ulogic_vector(0 to scan_right);
signal pc_iu_func_sl_thold_1    : std_ulogic;
signal pc_iu_func_sl_thold_0    : std_ulogic;
signal pc_iu_func_sl_thold_0_b  : std_ulogic;
signal pc_iu_sg_1               : std_ulogic;
signal pc_iu_sg_0               : std_ulogic;
signal forcee                    : std_ulogic;
signal act_dis                          : std_ulogic;
signal d_mode                           : std_ulogic;
signal mpw2_b                           : std_ulogic;
begin
act_dis <= '0';
d_mode  <= '0';
mpw2_b  <= '1';
--pass through
iu_au_config_iucr_pt(2 to 4) <= iu_au_config_iucr(2 to 3) & iu_au_config_iucr(5);
----------------------------------------
-- ibuff instruction source muxing
----------------------------------------
iu_au_ib1_instr0(0 to 31)               <= iu_au_ib1_data(0 to 31);
iu_au_ib1_instr0_ucode_ext(0 to 3)      <= iu_au_ib1_data(32 to 35);
iu_au_ib1_instr0_pred_taken_cnt(0 to 1) <= iu_au_ib1_data(36 to 37);
iu_au_ib1_instr0_pred_vld               <= iu_au_ib1_data(38);
iu_au_ib1_instr0_error                  <= iu_au_ib1_data(39 to 41);
iu_au_ib1_instr0_is_ucode               <= iu_au_ib1_data(42);
iu_au_ib1_instr0_2ucode                 <= iu_au_ib1_data(43);
iu_au_ib1_instr0_2ucode_type            <= iu_au_ib1_data(44);
iu_au_ib1_instr0_force_ram              <= iu_au_ib1_data(45);
iu_au_ib1_instr0_gshare                 <= iu_au_ib1_data(46 to 49);
ib1_flush <= xu_iu_flush or uc_flush;
is1_flush <= xu_iu_flush or uc_flush;
is2_flush <= xu_iu_flush or uc_flush;
rf0_flush <= xu_iu_flush or uc_flush;
i_axu_is1_dep_hit_b <= au_iu_is1_dep_hit_b;
pc_au_ram_mode          <= pc_iu_ram_mode;
pc_au_ram_thread_v                      <= pc_iu_ram_thread(0 to 1) = slice_id(0 to 1);
iu_fxu_decode0 : entity work.iuq_fxu_decode
generic map(a2mode              => a2mode,
            regmode             => regmode,
            expand_type         => expand_type)
port map(
     vdd                                => vdd,
     gnd                                => gnd,
     nclk                               => nclk,
     pc_iu_func_sl_thold_0_b            => pc_iu_func_sl_thold_0_b,
     pc_iu_sg_0                         => pc_iu_sg_0,
     forcee => forcee,
     d_mode                             => d_mode,
     delay_lclkr                        => delay_lclkr,
     mpw1_b                             => mpw1_b,
     mpw2_b                             => mpw2_b,
     scan_in                            => siv(scan_dec),
     scan_out                           => sov(scan_dec),
     pc_au_ram_mode                     => pc_au_ram_mode,
     pc_au_ram_thread_v                 => pc_au_ram_thread_v,
     spr_dec_mask                       => spr_dec_mask,
     spr_dec_match                      => spr_dec_match,
     fdep_fdec_buff_stall               => fdep_fdec_buff_stall,
     fdep_fdec_weak_stall               => fdep_fdec_weak_stall,
     au_iu_i_dec_b                      => au_iu_i_dec_b,
     iu_au_is1_cr_user_v                => iu_au_is1_cr_user_v,
     iu_au_is0_cr_setter                => iu_au_is0_cr_setter,
     au_iu_ib1_ldst                     => au_iu_ib1_ldst,          
     au_iu_ib1_ldst_v                   => au_iu_ib1_ldst_v,
     au_iu_ib1_store                    => au_iu_ib1_store,             
     au_iu_ib1_ldst_size                => au_iu_ib1_ldst_size,
     au_iu_ib1_ldst_tag                 => au_iu_ib1_ldst_tag,
     au_iu_ib1_ldst_ra                  => au_iu_ib1_ldst_ra,
     au_iu_ib1_ldst_ra_v                => au_iu_ib1_ldst_ra_v,
     au_iu_ib1_ldst_rb                  => au_iu_ib1_ldst_rb,
     au_iu_ib1_ldst_rb_v                => au_iu_ib1_ldst_rb_v,
     au_iu_ib1_ldst_dimm                => au_iu_ib1_ldst_dimm,
     au_iu_ib1_ldst_indexed             => au_iu_ib1_ldst_indexed,
     au_iu_ib1_ldst_update              => au_iu_ib1_ldst_update,
     au_iu_ib1_ldst_extpid              => au_iu_ib1_ldst_extpid,
     au_iu_ib1_ldst_forcealign          => au_iu_ib1_ldst_forcealign,
     au_iu_ib1_ldst_forceexcept          => au_iu_ib1_ldst_forceexcept,
     au_iu_ib1_mftgpr                => au_iu_ib1_mftgpr,
     au_iu_ib1_mffgpr                => au_iu_ib1_mffgpr,
     au_iu_ib1_movedp                => au_iu_ib1_movedp,
     au_iu_ib1_instr_type                => au_iu_ib1_instr_type,
     iu_au_ib1_instr_vld                => iu_au_ib1_instr_vld,
     iu_au_ib1_ifar                     => iu_au_ib1_ifar,
     iu_au_ib1_instr                    => iu_au_ib1_instr0,
     iu_au_ib1_instr_ucode_ext          => iu_au_ib1_instr0_ucode_ext,
     iu_au_ib1_instr_pred_vld           => iu_au_ib1_instr0_pred_vld,
     iu_au_ib1_instr_pred_taken_cnt     => iu_au_ib1_instr0_pred_taken_cnt,
     iu_au_ib1_instr_gshare             => iu_au_ib1_instr0_gshare,
     iu_au_ib1_instr_error              => iu_au_ib1_instr0_error,
     iu_au_ib1_instr_is_ucode           => iu_au_ib1_instr0_is_ucode,
     iu_au_ib1_instr_2ucode             => iu_au_ib1_instr0_2ucode,
     iu_au_ib1_instr_2ucode_type        => iu_au_ib1_instr0_2ucode_type,
     iu_au_ib1_instr_force_ram          => iu_au_ib1_instr0_force_ram,
     au_iu_is0_to_ucode                 => au_iu_is0_to_ucode,
     au_iu_is0_ucode_only               => au_iu_is0_ucode_only,
     iu_au_is1_stall                    => iu_au_is1_stall_int,
     xu_iu_ib1_flush                    => ib1_flush,
     fdec_ibuf_stall                    => fdec_ibuf_stall,
     fdec_fdep_is1_vld                  => fdec_fdep_is1_vld,
     fdec_fdep_is1_instr                => fdec_fdep_is1_instr,
     fdec_fdep_is1_ta_vld               => fdec_fdep_is1_ta_vld,
     fdec_fdep_is1_ta                   => fdec_fdep_is1_ta,
     fdec_fdep_is1_s1_vld               => fdec_fdep_is1_s1_vld,
     fdec_fdep_is1_s1                   => fdec_fdep_is1_s1,
     fdec_fdep_is1_s2_vld               => fdec_fdep_is1_s2_vld,
     fdec_fdep_is1_s2                   => fdec_fdep_is1_s2,
     fdec_fdep_is1_s3_vld               => fdec_fdep_is1_s3_vld,
     fdec_fdep_is1_s3                   => fdec_fdep_is1_s3,
     fdec_fdep_is1_pred_update          => fdec_fdep_is1_pred_update,
     fdec_fdep_is1_pred_taken_cnt       => fdec_fdep_is1_pred_taken_cnt,
     fdec_fdep_is1_gshare               => fdec_fdep_is1_gshare,
     fdec_fdep_is1_UpdatesLR            => fdec_fdep_is1_UpdatesLR,
     fdec_fdep_is1_UpdatesCR            => fdec_fdep_is1_UpdatesCR,
     fdec_fdep_is1_UpdatesCTR           => fdec_fdep_is1_UpdatesCTR,
     fdec_fdep_is1_UpdatesXER           => fdec_fdep_is1_UpdatesXER,
     fdec_fdep_is1_UpdatesMSR           => fdec_fdep_is1_UpdatesMSR,
     fdec_fdep_is1_UpdatesSPR           => fdec_fdep_is1_UpdatesSPR,
     fdec_fdep_is1_UsesLR               => fdec_fdep_is1_UsesLR,
     fdec_fdep_is1_UsesCR               => fdec_fdep_is1_UsesCR,
     fdec_fdep_is1_UsesCTR              => fdec_fdep_is1_UsesCTR,
     fdec_fdep_is1_UsesXER              => fdec_fdep_is1_UsesXER,
     fdec_fdep_is1_UsesMSR              => fdec_fdep_is1_UsesMSR,
     fdec_fdep_is1_UsesSPR              => fdec_fdep_is1_UsesSPR,
     fdec_fdep_is1_hole_delay           => fdec_fdep_is1_hole_delay,
     fdec_fdep_is1_ld_vld                => fdec_fdep_is1_ld_vld,
     fdec_fdep_is1_to_ucode             => fdec_fdep_is1_to_ucode,
     fdec_fdep_is1_is_ucode             => fdec_fdep_is1_is_ucode,
     fdec_fdep_is1_ifar                 => fdec_fdep_is1_ifar,
     fdec_fdep_is1_error                => fdec_fdep_is1_error,
     fdec_fdep_is1_complete             => fdec_fdep_is1_complete,
     fdec_fdep_is1_axu_ld_or_st         => fdec_fdep_is1_axu_ld_or_st,
     fdec_fdep_is1_axu_store            => fdec_fdep_is1_axu_store,
     fdec_fdep_is1_axu_ldst_size        => fdec_fdep_is1_axu_ldst_size,
     fdec_fdep_is1_axu_ldst_tag         => fdec_fdep_is1_axu_ldst_tag,

fdec_fdep_is1_axu_ldst_indexed     => fdec_fdep_is1_axu_ldst_indexed,
     fdec_fdep_is1_axu_ldst_update      => fdec_fdep_is1_axu_ldst_update,
     fdec_fdep_is1_axu_ldst_extpid      => fdec_fdep_is1_axu_ldst_extpid,
     fdec_fdep_is1_axu_ldst_forcealign  => fdec_fdep_is1_axu_ldst_forcealign,
     fdec_fdep_is1_axu_ldst_forceexcept  => fdec_fdep_is1_axu_ldst_forceexcept,
     fdec_fdep_is1_axu_mftgpr        => fdec_fdep_is1_axu_mftgpr,
     fdec_fdep_is1_axu_mffgpr        => fdec_fdep_is1_axu_mffgpr,
     fdec_fdep_is1_axu_movedp        => fdec_fdep_is1_axu_movedp,
     fdec_fdep_is1_axu_instr_type        => fdec_fdep_is1_axu_instr_type,
     fdec_fdep_is1_2ucode                => fdec_fdep_is1_2ucode,
     fdec_fdep_is1_2ucode_type                => fdec_fdep_is1_2ucode_type,
     fdec_fdep_is1_force_ram                => fdec_fdep_is1_force_ram,
     fdec_fdep_is1_match                => fdec_fdep_is1_match
);
iu_fxu_dep0 : entity work.iuq_fxu_dep
generic map(expand_type                 => expand_type,
            regmode                     => regmode,
            lmq_entries                 => lmq_entries)
port map(vdd                            => vdd,
         gnd                            => gnd,
         nclk                           => nclk,
         pc_iu_func_sl_thold_0_b        => pc_iu_func_sl_thold_0_b,
         pc_iu_sg_0                     => pc_iu_sg_0,
         forcee => forcee,
         d_mode                         => d_mode,
         delay_lclkr                    => delay_lclkr,
         mpw1_b                         => mpw1_b,
         mpw2_b                         => mpw2_b,
         scan_in                        => siv(scan_dep),
         scan_out                       => sov(scan_dep),
         pc_iu_trace_bus_enable         => pc_iu_trace_bus_enable,
         pc_iu_event_bus_enable         => pc_iu_event_bus_enable,
         fdep_dbg_data                  => fdep_dbg_data,
         fdep_perf_event                => fdep_perf_event,
         fdep_fdec_buff_stall           => fdep_fdec_buff_stall,
         fdep_fdec_weak_stall           => fdep_fdec_weak_stall,
         fdec_fdep_is1_vld              => fdec_fdep_is1_vld,
         fdec_fdep_is1_instr            => fdec_fdep_is1_instr,
         fdec_fdep_is1_ta_vld           => fdec_fdep_is1_ta_vld,
         fdec_fdep_is1_ta               => fdec_fdep_is1_ta,
         fdec_fdep_is1_s1_vld           => fdec_fdep_is1_s1_vld,
         fdec_fdep_is1_s1               => fdec_fdep_is1_s1,
         fdec_fdep_is1_s2_vld           => fdec_fdep_is1_s2_vld,
         fdec_fdep_is1_s2               => fdec_fdep_is1_s2,
         fdec_fdep_is1_s3_vld           => fdec_fdep_is1_s3_vld,
         fdec_fdep_is1_s3               => fdec_fdep_is1_s3,
         fdec_fdep_is1_pred_update      => fdec_fdep_is1_pred_update,
         fdec_fdep_is1_pred_taken_cnt   => fdec_fdep_is1_pred_taken_cnt,
         fdec_fdep_is1_gshare           => fdec_fdep_is1_gshare,
         fdec_fdep_is1_UpdatesLR        => fdec_fdep_is1_UpdatesLR,
         fdec_fdep_is1_UpdatesCR        => fdec_fdep_is1_UpdatesCR,
         fdec_fdep_is1_UpdatesCTR       => fdec_fdep_is1_UpdatesCTR,
         fdec_fdep_is1_UpdatesXER       => fdec_fdep_is1_UpdatesXER,
         fdec_fdep_is1_UpdatesMSR       => fdec_fdep_is1_UpdatesMSR,
         fdec_fdep_is1_UpdatesSPR       => fdec_fdep_is1_UpdatesSPR,
         fdec_fdep_is1_UsesLR           => fdec_fdep_is1_UsesLR,
         fdec_fdep_is1_UsesCR           => fdec_fdep_is1_UsesCR,
         fdec_fdep_is1_UsesCTR          => fdec_fdep_is1_UsesCTR,
         fdec_fdep_is1_UsesXER          => fdec_fdep_is1_UsesXER,
         fdec_fdep_is1_UsesMSR          => fdec_fdep_is1_UsesMSR,
         fdec_fdep_is1_UsesSPR          => fdec_fdep_is1_UsesSPR,
         fdec_fdep_is1_hole_delay       => fdec_fdep_is1_hole_delay,
         fdec_fdep_is1_ld_vld            => fdec_fdep_is1_ld_vld,
         fdec_fdep_is1_to_ucode         => fdec_fdep_is1_to_ucode,
         fdec_fdep_is1_is_ucode         => fdec_fdep_is1_is_ucode,
         fdec_fdep_is1_ifar             => fdec_fdep_is1_ifar,
         fdec_fdep_is1_error            => fdec_fdep_is1_error,
         fdec_fdep_is1_complete         => fdec_fdep_is1_complete,
         fdec_fdep_is1_axu_ld_or_st     => fdec_fdep_is1_axu_ld_or_st,
         fdec_fdep_is1_axu_store        => fdec_fdep_is1_axu_store,
         fdec_fdep_is1_axu_ldst_size    => fdec_fdep_is1_axu_ldst_size,
         fdec_fdep_is1_axu_ldst_tag     => fdec_fdep_is1_axu_ldst_tag,

fdec_fdep_is1_axu_ldst_indexed => fdec_fdep_is1_axu_ldst_indexed,
         fdec_fdep_is1_axu_ldst_update  => fdec_fdep_is1_axu_ldst_update,
         fdec_fdep_is1_axu_ldst_extpid  => fdec_fdep_is1_axu_ldst_extpid,
         fdec_fdep_is1_axu_ldst_forcealign  => fdec_fdep_is1_axu_ldst_forcealign,
         fdec_fdep_is1_axu_ldst_forceexcept  => fdec_fdep_is1_axu_ldst_forceexcept,
         fdec_fdep_is1_axu_mftgpr    => fdec_fdep_is1_axu_mftgpr,
         fdec_fdep_is1_axu_mffgpr    => fdec_fdep_is1_axu_mffgpr,
         fdec_fdep_is1_axu_movedp    => fdec_fdep_is1_axu_movedp,
         fdec_fdep_is1_axu_instr_type    => fdec_fdep_is1_axu_instr_type,
         fdec_fdep_is1_match            => fdec_fdep_is1_match,
         fdec_fdep_is1_2ucode            => fdec_fdep_is1_2ucode,
         fdec_fdep_is1_2ucode_type            => fdec_fdep_is1_2ucode_type,
         fdec_fdep_is1_force_ram        => fdec_fdep_is1_force_ram,
         fdep_fiss_is2_instr            => fdep_fiss_is2_instr,
         fdep_fiss_is2_ta_vld           => fdep_fiss_is2_ta_vld,
         fdep_fiss_is2_ta               => fdep_fiss_is2_ta,
         fdep_fiss_is2_s1_vld           => fdep_fiss_is2_s1_vld,
         fdep_fiss_is2_s1               => fdep_fiss_is2_s1,
         fdep_fiss_is2_s2_vld           => fdep_fiss_is2_s2_vld,
         fdep_fiss_is2_s2               => fdep_fiss_is2_s2,
         fdep_fiss_is2_s3_vld           => fdep_fiss_is2_s3_vld,
         fdep_fiss_is2_s3               => fdep_fiss_is2_s3,
         fdep_fiss_is2_pred_update      => fdep_fiss_is2_pred_update,
         fdep_fiss_is2_pred_taken_cnt   => fdep_fiss_is2_pred_taken_cnt,
         fdep_fiss_is2_gshare           => fdep_fiss_is2_gshare,
         fdep_fiss_is2_ifar             => fdep_fiss_is2_ifar,
         fdep_fiss_is2_error            => fdep_fiss_is2_error,
         fdep_fiss_is2_axu_ld_or_st     => fdep_fiss_is2_axu_ld_or_st,
         fdep_fiss_is2_axu_store        => fdep_fiss_is2_axu_store,
         fdep_fiss_is2_axu_ldst_size    => fdep_fiss_is2_axu_ldst_size,
         fdep_fiss_is2_axu_ldst_tag     => fdep_fiss_is2_axu_ldst_tag,

fdep_fiss_is2_axu_ldst_indexed => fdep_fiss_is2_axu_ldst_indexed,
         fdep_fiss_is2_axu_ldst_update  => fdep_fiss_is2_axu_ldst_update,
         fdep_fiss_is2_axu_ldst_extpid  => fdep_fiss_is2_axu_ldst_extpid,
         fdep_fiss_is2_axu_ldst_forcealign => fdep_fiss_is2_axu_ldst_forcealign,
         fdep_fiss_is2_axu_ldst_forceexcept => fdep_fiss_is2_axu_ldst_forceexcept,
         fdep_fiss_is2_axu_mftgpr    => fdep_fiss_is2_axu_mftgpr,
         fdep_fiss_is2_axu_mffgpr    => fdep_fiss_is2_axu_mffgpr,
         fdep_fiss_is2_axu_movedp    => fdep_fiss_is2_axu_movedp,
         fdep_fiss_is2_axu_instr_type    => fdep_fiss_is2_axu_instr_type,
         fdep_fiss_is2_match            => fdep_fiss_is2_match,
         fdep_fiss_is2_2ucode            => fdep_fiss_is2_2ucode,
         fdep_fiss_is2_2ucode_type            => fdep_fiss_is2_2ucode_type,
         fdep_fiss_is2early_vld         => fdep_fiss_is2early_vld,
         fdep_fiss_is1_xu_dep_hit_b     => fdep_fiss_is1_xu_dep_hit_b,
         fdep_fiss_is2_hole_delay       => fdep_fiss_is2_hole_delay,
         fdep_fiss_is2_to_ucode         => fdep_fiss_is2_to_ucode,
         fdep_fiss_is2_is_ucode         => fdep_fiss_is2_is_ucode,
         fiss_fdep_is2_take             => fiss_fdep_is2_take,
         i_afd_is1_instr_v              => i_afd_is1_instr_v,
         au_iu_issue_stall              => au_iu_issue_stall,
         iu_au_is2_stall                => iu_au_is2_stall,
         au_iu_is1_dep_hit              => au_iu_is1_dep_hit,
         au_iu_is1_dep_hit_b              => au_iu_is1_dep_hit_b,
         au_iu_is2_axubusy              => au_iu_is2_axubusy,
         iu_au_is1_hold                 => iu_au_is1_hold,
         iu_au_is1_stall                => iu_au_is1_stall_int,
         xu_iu_slowspr_done		=> xu_iu_slowspr_done,	
         xu_iu_multdiv_done		=> xu_iu_multdiv_done,	
         xu_iu_loadmiss_vld		=> xu_iu_ex5_loadmiss_vld,	
         xu_iu_loadmiss_qentry          => xu_iu_ex5_loadmiss_qentry,
         xu_iu_loadmiss_target          => xu_iu_ex5_loadmiss_target(1 to 6),
         xu_iu_loadmiss_target_type	=> xu_iu_ex5_loadmiss_target_type(0),
         xu_iu_complete_vld             => xu_iu_complete_vld,
         xu_iu_complete_qentry          => xu_iu_complete_qentry,
         xu_iu_complete_target_type     => xu_iu_complete_target_type(0),
         ic_fdep_load_quiesce           => ic_fdep_load_quiesce,
         iu_xu_quiesce                  => iu_xu_quiesce,
         xu_iu_membar_tid               => xu_iu_membar_tid,
         xu_iu_set_barr_tid             => xu_iu_set_barr_tid,
         xu_iu_larx_done_tid            => xu_iu_larx_done_tid,
         an_ac_sync_ack                 => an_ac_sync_ack,
         ic_fdep_icbi_ack               => ic_fdep_icbi_ack,
         an_ac_stcx_complete            => an_ac_stcx_complete,
         mm_iu_barrier_done             => mm_iu_barrier_done,
         spr_fdep_ll_hold               => spr_fdep_ll_hold,
         xu_iu_spr_ccr2_en_dcr          => xu_iu_spr_ccr2_en_dcr,
         xu_iu_is1_flush                => is1_flush,
         xu_iu_is2_flush                => is2_flush,
         xu_iu_rf0_flush                => rf0_flush,
         xu_iu_rf1_flush                => xu_iu_rf1_flush,
         xu_iu_ex1_flush                => xu_iu_ex1_flush,
         xu_iu_ex2_flush                => xu_iu_ex2_flush,
         xu_iu_ex3_flush                => xu_iu_ex3_flush,
         xu_iu_ex4_flush                => xu_iu_ex4_flush,
         xu_iu_ex5_flush                => xu_iu_ex5_flush,
         xu_iu_single_instr_mode        => xu_iu_single_instr_mode);
dec0: entity work.iuq_axu_fu_dec
generic map(expand_type => expand_type) 
port map(
         vdd                            => vdd,
         gnd                            => gnd,
         nclk                           => nclk,
         i_dec_si                       => siv(scan_axu_dec),
         i_dec_so                       => sov(scan_axu_dec),
         pc_iu_func_sl_thold_0_b        => pc_iu_func_sl_thold_0_b,
         pc_iu_sg_0                     => pc_iu_sg_0,             
         forcee => forcee,
         d_mode                         => d_mode,
         delay_lclkr                    => delay_lclkr,
         mpw1_b                         => mpw1_b,
         mpw2_b                         => mpw2_b,
         pc_au_ram_mode                 => pc_au_ram_mode,
         pc_au_ram_thread_v             => pc_au_ram_thread_v,
         iu_au_ucode_restart            => xu_iu_ucode_restart,
         ifdp_ex5_fmul_uc_complete      => ifdp_ex5_fmul_uc_complete,
         i_afd_fmul_uc_is1              => i_afd_fmul_uc_is1,
         iu_au_config_iucr              => iu_au_config_iucr,
         iu_au_is0_instr_v              => iu_au_ib1_instr_vld,   
         iu_au_is0_instr                => iu_au_ib1_instr0,             
         iu_au_is0_ucode_ext            => iu_au_ib1_instr0_ucode_ext,             
         iu_au_is0_cr_setter            => iu_au_is0_cr_setter,
         iu_au_is1_stall                => iu_au_is1_stall_int,           
         iu_au_is0_flush                => ib1_flush,
         iu_au_is1_flush                => is1_flush, 
         au_iu_is0_i_dec_b              => au_iu_i_dec_b,
         au_iu_is0_to_ucode             => au_iu_is0_to_ucode,
         au_iu_is0_ucode_only           => au_iu_is0_ucode_only,
         iu_au_is0_is_ucode             => iu_au_ib1_instr0_is_ucode,
         iu_au_is0_2ucode               => iu_au_ib1_instr0_2ucode,
         au_iu_is0_ldst                 => au_iu_ib1_ldst,          
         au_iu_is0_ldst_v               => au_iu_ib1_ldst_v,          
         au_iu_is0_st_v                 => au_iu_ib1_store,             
         au_iu_is0_ldst_size            => au_iu_ib1_ldst_size,
         au_iu_is0_ldst_tag             => au_iu_ib1_ldst_tag,
         au_iu_is0_ldst_ra              => au_iu_ib1_ldst_ra,
         au_iu_is0_ldst_ra_v            => au_iu_ib1_ldst_ra_v,
         au_iu_is0_ldst_rb              => au_iu_ib1_ldst_rb,
         au_iu_is0_ldst_rb_v            => au_iu_ib1_ldst_rb_v,
         au_iu_is0_ldst_dimm            => au_iu_ib1_ldst_dimm,
         au_iu_is0_ldst_indexed         => au_iu_ib1_ldst_indexed,         
         au_iu_is0_ldst_update          => au_iu_ib1_ldst_update,
         au_iu_is0_ldst_extpid          => au_iu_ib1_ldst_extpid,
         au_iu_is0_ldst_forcealign      => au_iu_ib1_ldst_forcealign,
         au_iu_is0_ldst_forceexcept      => au_iu_ib1_ldst_forceexcept,
         au_iu_is0_mftgpr            => au_iu_ib1_mftgpr,
         au_iu_is0_mffgpr            => au_iu_ib1_mffgpr,
         au_iu_is0_movedp            => au_iu_ib1_movedp,
         au_iu_is0_instr_type            => au_iu_ib1_instr_type,
         i_afd_is1_cr_setter            => i_afd_is1_cr_setter,
         i_afd_is1_is_ucode             => i_afd_is1_is_ucode,
         i_afd_is1_to_ucode             => i_afd_is1_to_ucode,
         i_afd_is1_fra_v                => i_afd_is1_fra_v,           
         i_afd_is1_frb_v                => i_afd_is1_frb_v,             
         i_afd_is1_frc_v                => i_afd_is1_frc_v,             
         i_afd_is1_frt_v                => i_afd_is1_frt_v,             
         i_afd_is1_prebubble1           => i_afd_is1_prebubble1,
         i_afd_is1_est_bubble3          => i_afd_is1_est_bubble3,                          
         i_afd_is1_cr_writer            => i_afd_is1_cr_writer,                        
         i_afd_is1_fra                  => i_afd_is1_fra,               
         i_afd_is1_frb                  => i_afd_is1_frb,              
         i_afd_is1_frc                  => i_afd_is1_frc,              
         i_afd_is1_frt                  => i_afd_is1_frt,    
         i_afd_is1_instr_v              => i_afd_is1_instr_v,            
         i_afd_is1_instr_ldst_v         => i_afd_is1_instr_ldst_v,                    
         i_afd_is1_instr_ld_v           => i_afd_is1_instr_ld_v,                          
         i_afd_ignore_flush_is1         => i_afd_ignore_flush_is1_int,
         i_afd_in_ucode_mode_or1d       => i_afd_in_ucode_mode_or1d,
         i_afd_is1_fra_buf              => i_afd_is1_fra_buf,
         i_afd_is1_frb_buf              => i_afd_is1_frb_buf,
         i_afd_is1_frc_buf              => i_afd_is1_frc_buf,
         i_afd_is1_frt_buf              => i_afd_is1_frt_buf,
         i_afd_is1_divsqrt              => i_afd_is1_divsqrt,
         i_afd_is1_stall_rep            => i_afd_is1_stall_rep,
         i_afd_is1_instr_sto_v          => i_afd_is1_instr_sto_v,
         i_afd_config_iucr              => i_afd_config_iucr,
         fu_dec_debug                   => fu_dec_debug
         );
dep0: entity work.iuq_axu_fu_dep 
generic map(expand_type => expand_type,
            lmq_entries => lmq_entries)
port map (
         vdd                            => vdd,
         gnd                            => gnd,
         nclk                           => nclk,
         i_dep_si                       => siv(scan_axu_dep),
         i_dep_so                       => sov(scan_axu_dep),
         pc_iu_func_sl_thold_0_b        => pc_iu_func_sl_thold_0_b,
         pc_iu_sg_0                     => pc_iu_sg_0,             
         forcee => forcee,
         d_mode                         => d_mode,
         delay_lclkr                    => delay_lclkr,
         mpw1_b                         => mpw1_b,
         mpw2_b                         => mpw2_b,
         ifdp_ex5_fmul_uc_complete      => ifdp_ex5_fmul_uc_complete,
         i_afd_fmul_uc_is1              => i_afd_fmul_uc_is1,
         iu_fu_ex2_n_flush              => iu_fu_ex2_n_flush,
         fu_iu_uc_special               => fu_iu_uc_special,
         i_afd_is1_cr_setter            => i_afd_is1_cr_setter,
         i_afd_is1_is_ucode             => i_afd_is1_is_ucode,
         i_afd_is1_to_ucode             => i_afd_is1_to_ucode,
         i_afd_is2_is_ucode             => i_afd_is2_is_ucode,
         i_afd_is1_instr_v              => i_afd_is1_instr_v,
         i_afd_is1_instr                => fdec_fdep_is1_instr(26 to 31),
         i_afd_is1_fra_v                => i_afd_is1_fra_v,             
         i_afd_is1_frb_v                => i_afd_is1_frb_v,             
         i_afd_is1_frc_v                => i_afd_is1_frc_v,             
         i_afd_is1_frt_v                => i_afd_is1_frt_v,                                                    
         i_afd_is1_prebubble1           => i_afd_is1_prebubble1,
         i_afd_is1_est_bubble3          => i_afd_is1_est_bubble3,                     
         iu_au_is1_cr_user_v            => iu_au_is1_cr_user_v,
         i_afd_is1_cr_writer            => i_afd_is1_cr_writer,                                                   
         i_afd_is1_fra                  => i_afd_is1_fra,             
         i_afd_is1_frb                  => i_afd_is1_frb,                 
         i_afd_is1_frc                  => i_afd_is1_frc,             
         i_afd_is1_frt                  => i_afd_is1_frt,             
         i_afd_is1_ifar                 => fdec_fdep_is1_ifar(56 to 61),
         i_afd_is1_instr_ldst_v         => i_afd_is1_instr_ldst_v,                    
         i_afd_is1_instr_ld_v           => i_afd_is1_instr_ld_v,                             
         i_afi_is2_take                 => i_afi_is2_take,   
         xu_au_loadmiss_vld             => xu_iu_ex4_loadmiss_vld,  
         xu_au_loadmiss_qentry          => xu_iu_ex4_loadmiss_qentry,
         xu_au_loadmiss_target          => xu_iu_ex4_loadmiss_target,
         xu_au_loadmiss_target_type     => xu_iu_ex4_loadmiss_target_type,
         xu_au_loadmiss_complete_vld    => xu_iu_complete_vld,
         xu_au_loadmiss_complete_qentry => xu_iu_complete_qentry,                   
         xu_au_loadmiss_complete_type   => xu_iu_complete_target_type,
         iu_au_is1_hold                 => iu_au_is1_hold,
         iu_au_is1_instr_match          => fdec_fdep_is1_match,
         iu_au_is2_stall                => iu_au_is2_stall,
         xu_iu_is2_flush                => xu_iu_flush,  
         iu_au_is1_flush                => is1_flush, 
         iu_au_is2_flush                => is2_flush,                    
         iu_au_rf0_flush                => xu_iu_flush,                    
         iu_au_rf1_flush                => xu_iu_rf1_flush,                    
         iu_au_ex1_flush                => xu_iu_ex1_flush,                    
         iu_au_ex2_flush                => xu_iu_ex2_flush,                    
         iu_au_ex3_flush                => xu_iu_ex3_flush,                    
         iu_au_ex4_flush                => xu_iu_ex4_flush, 
         iu_au_ex5_flush                => xu_iu_ex5_flush,                   
         au_iu_is1_dep_hit              => au_iu_is1_dep_hit,           
         au_iu_is2_issue_stall          => au_iu_issue_stall,
         i_axu_is2_instr_v              => i_axu_is2_instr_v,
         i_axu_is1_early_v              => i_axu_is1_early_v,
         au_iu_is1_dep_hit_b            => au_iu_is1_dep_hit_b,
         i_axu_is2_instr_match          => i_axu_is2_instr_match,

         i_axu_is2_fra                  => i_axu_is2_fra,             
         i_axu_is2_frb                  => i_axu_is2_frb,                 
         i_axu_is2_frc                  => i_axu_is2_frc,             
         i_axu_is2_frt                  => i_axu_is2_frt,             
         i_axu_is2_fra_v                => i_axu_is2_fra_v,             
         i_axu_is2_frb_v                => i_axu_is2_frb_v,                 
         i_axu_is2_frc_v                => i_axu_is2_frc_v,             
         ifdp_is2_est_bubble3           => ifdp_is2_est_bubble3,
         ifdp_is2_bypsel                => ifdp_is2_bypsel,
         i_afd_ignore_flush_is1         => i_afd_ignore_flush_is1_int,
         i_afd_ignore_flush_is2         => i_afd_ignore_flush_is2,
         au_iu_is2_axubusy              => au_iu_is2_axubusy,
         i_afd_in_ucode_mode_or1d       => i_afd_in_ucode_mode_or1d,
         i_afd_in_ucode_mode_or1d_b     => i_afd_in_ucode_mode_or1d_b,
         i_afd_is1_fra_buf              => i_afd_is1_fra_buf,
         i_afd_is1_frb_buf              => i_afd_is1_frb_buf,
         i_afd_is1_frc_buf              => i_afd_is1_frc_buf,
         i_afd_is1_frt_buf              => i_afd_is1_frt_buf,
         i_afd_is1_divsqrt              => i_afd_is1_divsqrt,
         i_afd_is1_stall_rep            => i_afd_is1_stall_rep,
         i_afd_is1_instr_sto_v          => i_afd_is1_instr_sto_v,
         i_afd_config_iucr              => i_afd_config_iucr,
         fu_dep_debug                   => fu_dep_debug  
       );
-------------------------------------------------
-- debug bus
-------------------------------------------------
axu_dbg_data(0 to 37) <= fu_dec_debug(0 to 13) & fu_dep_debug(0 to 23);
-------------------------------------------------
-- pervasive
-------------------------------------------------
perv_2to1_reg: tri_plat
  generic map (width => 2, expand_type => expand_type)
  port map (vd          => vdd,
            gd          => gnd,
            nclk        => nclk,
            flush       => tc_ac_ccflush_dc,
            din(0)      => pc_iu_func_sl_thold_2,
            din(1)      => pc_iu_sg_2,
            q(0)        => pc_iu_func_sl_thold_1,
            q(1)        => pc_iu_sg_1);
perv_1to0_reg: tri_plat
  generic map (width => 2, expand_type => expand_type)
  port map (vd          => vdd,
            gd          => gnd,
            nclk        => nclk,
            flush       => tc_ac_ccflush_dc,
            din(0)      => pc_iu_func_sl_thold_1,
            din(1)      => pc_iu_sg_1,
            q(0)        => pc_iu_func_sl_thold_0,
            q(1)        => pc_iu_sg_0);
perv_lcbor: tri_lcbor
  generic map (expand_type => expand_type)
  port map (clkoff_b    => clkoff_b,
            thold       => pc_iu_func_sl_thold_0,
            sg          => pc_iu_sg_0,
            act_dis     => act_dis,
            forcee => forcee,
            thold_b     => pc_iu_func_sl_thold_0_b);
siv <= scan_in & sov(0 to scan_right-1);
scan_out <= sov(scan_right) and an_ac_scan_dis_dc_b;
end iuq_slice;
