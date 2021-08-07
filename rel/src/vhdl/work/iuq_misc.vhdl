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



library ieee;
use ieee.std_logic_1164.all;

library ibm;
use ibm.std_ulogic_support.all;
use ibm.std_ulogic_function_support.all;
use ibm.std_ulogic_unsigned.all;

library support;
use support.power_logic_pkg.all;

library tri;
use tri.tri_latches_pkg.all;

library work;
use work.iuq_pkg.all;

entity iuq_misc is
generic(regmode     : integer := 6;
        a2mode      : integer := 1;
        expand_type : integer := 2 ); -- 0 = ibm umbra, 1 = xilinx, 2 = ibm mpg
port(
     vdd                        : inout power_logic;
     gnd                        : inout power_logic;
     vcs                        : inout power_logic;
     nclk                       : in  clk_logic;
     pc_iu_sg_3                 : in  std_ulogic_vector(0 to 3);
     pc_iu_func_sl_thold_3      : in  std_ulogic_vector(0 to 3);
     pc_iu_func_slp_sl_thold_3  : in  std_ulogic;
     pc_iu_gptr_sl_thold_3      : in  std_ulogic;
     pc_iu_time_sl_thold_3      : in  std_ulogic;
     pc_iu_repr_sl_thold_3      : in  std_ulogic;
     pc_iu_abst_sl_thold_3      : in  std_ulogic;
     pc_iu_abst_slp_sl_thold_3  : in  std_ulogic;
     pc_iu_cfg_sl_thold_3       : in  std_ulogic;
     pc_iu_cfg_slp_sl_thold_3   : in  std_ulogic;
     pc_iu_regf_slp_sl_thold_3  : in  std_ulogic;
     pc_iu_ary_nsl_thold_3      : in  std_ulogic;
     pc_iu_ary_slp_nsl_thold_3  : in  std_ulogic;
     pc_iu_func_slp_nsl_thold_3 : in  std_ulogic;
     pc_iu_bolt_sl_thold_3      : in std_ulogic;
     pc_iu_fce_3                : in  std_ulogic;
     tc_ac_ccflush_dc           : in  std_ulogic;
     scan_diag_dc               : in  std_ulogic;
     pc_iu_sg_2                 : out std_ulogic_vector(0 to 3);
     pc_iu_func_sl_thold_2      : out std_ulogic_vector(0 to 3);
     pc_iu_func_slp_sl_thold_2  : out std_ulogic;
     pc_iu_time_sl_thold_2      : out std_ulogic;
     pc_iu_repr_sl_thold_2      : out std_ulogic;
     pc_iu_abst_sl_thold_2      : out std_ulogic;
     pc_iu_abst_slp_sl_thold_2  : out std_ulogic;
     pc_iu_cfg_slp_sl_thold_2   : out std_ulogic;
     pc_iu_regf_slp_sl_thold_2  : out std_ulogic;
     pc_iu_ary_nsl_thold_2      : out std_ulogic;
     pc_iu_ary_slp_nsl_thold_2  : out std_ulogic;
     pc_iu_func_slp_nsl_thold_2 : out std_ulogic;
     pc_iu_bolt_sl_thold_2      : out std_ulogic;
     pc_iu_fce_2                : out std_ulogic;

     clkoff_b                   : out std_ulogic_vector(0 to 2);
     delay_lclkr                : out std_ulogic_vector(1 to 14);
     mpw1_b                     : out std_ulogic_vector(1 to 14);

     g8t_clkoff_b               : out std_ulogic;
     g8t_d_mode                 : out std_ulogic;
     g8t_delay_lclkr            : out std_ulogic_vector(0 to 4);
     g8t_mpw1_b                 : out std_ulogic_vector(0 to 4);
     g8t_mpw2_b                 : out std_ulogic;

     g6t_clkoff_b               : out std_ulogic;
     g6t_d_mode                 : out std_ulogic;
     g6t_delay_lclkr            : out std_ulogic_vector(0 to 3);
     g6t_mpw1_b                 : out std_ulogic_vector(0 to 4);
     g6t_mpw2_b                 : out std_ulogic;

     cam_clkoff_b               : out std_ulogic;
     cam_d_mode                 : out std_ulogic;
     cam_delay_lclkr            : out std_ulogic_vector(0 to 4);
     cam_mpw1_b                 : out std_ulogic_vector(0 to 4);
     cam_mpw2_b                 : out std_ulogic;

     an_ac_scan_dis_dc_b        : in  std_ulogic;
     func_scan_in               : in  std_ulogic_vector(0 to 1);
     gptr_scan_in               : in  std_ulogic;
     time_scan_in               : in  std_ulogic;
     abst_scan_in               : in  std_ulogic;
     repr_scan_in               : in  std_ulogic;
     ccfg_scan_in               : in  std_ulogic;
     bcfg_scan_in               : in  std_ulogic;
     dcfg_scan_in               : in  std_ulogic;
     func_scan_out              : out std_ulogic_vector(0 to 1);
     gptr_scan_out              : out std_ulogic;
     time_scan_out              : out std_ulogic;
     abst_scan_out              : out std_ulogic;
     repr_scan_out              : out std_ulogic;
     ccfg_scan_out              : out std_ulogic;
     bcfg_scan_out              : out std_ulogic;
     dcfg_scan_out              : out std_ulogic;

     pc_iu_abist_di_0           : in  std_ulogic_vector(0 to 3);
     pc_iu_abist_g8t_bw_1       : in  std_ulogic;
     pc_iu_abist_g8t_bw_0       : in  std_ulogic;
     pc_iu_abist_waddr_0        : in  std_ulogic_vector(3 to 9);
     pc_iu_abist_g8t_wenb       : in  std_ulogic;
     pc_iu_abist_raddr_0        : in  std_ulogic_vector(3 to 9);
     pc_iu_abist_g8t1p_renb_0   : in  std_ulogic;
     an_ac_lbist_ary_wrt_thru_dc: in  std_ulogic;
     pc_iu_abist_ena_dc         : in  std_ulogic;
     pc_iu_abist_wl128_comp_ena : in  std_ulogic;
     pc_iu_abist_raw_dc_b       : in  std_ulogic;
     pc_iu_abist_g8t_dcomp      : in  std_ulogic_vector(0 to 3);

     pc_iu_bo_enable_3          : in std_ulogic;
     pc_iu_bo_reset             : in std_ulogic;
     pc_iu_bo_unload            : in std_ulogic;
     pc_iu_bo_repair            : in std_ulogic;
     pc_iu_bo_shdata            : in std_ulogic;
     pc_iu_bo_select            : in std_ulogic;
     iu_pc_bo_fail              : out std_ulogic;
     iu_pc_bo_diagout           : out std_ulogic;

     -- bht
     r_act                      : in  std_ulogic;
     w_act                      : in  std_ulogic_vector(0 to 3);
     r_addr                     : in  std_ulogic_vector(0 to 7);
     w_addr                     : in  std_ulogic_vector(0 to 7);
     data_in                    : in  std_ulogic_vector(0 to 1);
     data_out0                  : out std_ulogic_vector(0 to 1);
     data_out1                  : out std_ulogic_vector(0 to 1);
     data_out2                  : out std_ulogic_vector(0 to 1);
     data_out3                  : out std_ulogic_vector(0 to 1);

     pc_iu_ram_instr            : in  std_ulogic_vector(0 to 31);
     pc_iu_ram_instr_ext        : in  std_ulogic_vector(0 to 3);
     pc_iu_ram_force_cmplt      : in  std_ulogic;
     xu_iu_ram_issue            : in  std_ulogic_vector(0 to 3);
     rm_ib_iu4_val              : out std_ulogic_vector(0 to 3);
     rm_ib_iu4_force_ram        : out std_ulogic;
     rm_ib_iu4_instr            : out std_ulogic_vector(0 to 35);

     -- spr
     slowspr_val_in             : in std_ulogic;
     slowspr_rw_in              : in std_ulogic;
     slowspr_etid_in            : in std_ulogic_vector(0 to 1);
     slowspr_addr_in            : in std_ulogic_vector(0 to 9);
     slowspr_data_in            : in std_ulogic_vector(64-(2**regmode) to 63);
     slowspr_done_in            : in std_ulogic;
     slowspr_val_out            : out std_ulogic;
     slowspr_rw_out             : out std_ulogic;
     slowspr_etid_out           : out std_ulogic_vector(0 to 1);
     slowspr_addr_out           : out std_ulogic_vector(0 to 9);
     slowspr_data_out           : out std_ulogic_vector(64-(2**regmode) to 63);
     slowspr_done_out           : out std_ulogic;
     spr_ic_idir_read           : out std_ulogic;
     spr_ic_idir_way            : out std_ulogic_vector(0 to 1);
     spr_ic_idir_row            : out std_ulogic_vector(52 to 57);
     ic_spr_idir_done           : in  std_ulogic;
     ic_spr_idir_lru            : in  std_ulogic_vector(0 to 2);
     ic_spr_idir_parity         : in  std_ulogic_vector(0 to 3);
     ic_spr_idir_endian         : in  std_ulogic;
     ic_spr_idir_valid          : in  std_ulogic;
     ic_spr_idir_tag            : in  std_ulogic_vector(0 to 29);
     spr_ic_icbi_ack_en         : out std_ulogic;
     spr_ic_cls                 : out std_ulogic;
     spr_ic_clockgate_dis       : out std_ulogic_vector(0 to 1);
     spr_ic_bp_config           : out std_ulogic_vector(0 to 3);
     spr_bp_config              : out std_ulogic_vector(0 to 3);
     spr_bp_gshare_mask         : out std_ulogic_vector(0 to 3);
     spr_dec_mask               : out std_ulogic_vector(0 to 31);
     spr_dec_match              : out std_ulogic_vector(0 to 31);
     iu_au_config_iucr_t0       : out std_ulogic_vector(0 to 7);
     iu_au_config_iucr_t1       : out std_ulogic_vector(0 to 7);
     iu_au_config_iucr_t2       : out std_ulogic_vector(0 to 7);
     iu_au_config_iucr_t3       : out std_ulogic_vector(0 to 7);
     spr_issue_high_mask        : out std_ulogic_vector(0 to 3);
     spr_issue_med_mask         : out std_ulogic_vector(0 to 3);
     spr_fiss_count0_max        : out std_ulogic_vector(0 to 5);
     spr_fiss_count1_max        : out std_ulogic_vector(0 to 5);
     spr_fiss_count2_max        : out std_ulogic_vector(0 to 5);
     spr_fiss_count3_max        : out std_ulogic_vector(0 to 5);
     spr_ic_pri_rand            : out std_ulogic_vector(0 to 4);
     spr_ic_pri_rand_always     : out std_ulogic;
     spr_ic_pri_rand_flush      : out std_ulogic;
     spr_fiss_pri_rand          : out std_ulogic_vector(0 to 4);
     spr_fiss_pri_rand_always   : out std_ulogic;
     spr_fiss_pri_rand_flush    : out std_ulogic;
     spr_fdep_ll_hold           : out std_ulogic;
     xu_iu_run_thread           : in std_ulogic_vector(0 to 3);
     xu_iu_ex6_pri              : in std_ulogic_vector(0 to 2);
     xu_iu_ex6_pri_val          : in std_ulogic_vector(0 to 3);
     xu_iu_raise_iss_pri        : in std_ulogic_vector(0 to 3);
     xu_iu_msr_gs               : in std_ulogic_vector(0 to 3);
     xu_iu_msr_pr               : in std_ulogic_vector(0 to 3);

     --dbg
     pc_iu_trace_bus_enable     : in  std_ulogic;
     pc_iu_debug_mux_ctrls      : in  std_ulogic_vector(0 to 15);
     debug_data_in              : in  std_ulogic_vector(0 to 87);
     trace_triggers_in          : in  std_ulogic_vector(0 to 11);
     debug_data_out             : out std_ulogic_vector(0 to 87);
     trace_triggers_out         : out std_ulogic_vector(0 to 11);

     fiss_dbg_data              : in std_ulogic_vector(0 to 87);
     fdep_dbg_data              : in std_ulogic_vector(0 to 87);
     ib_dbg_data                : in std_ulogic_vector(0 to 63);
     bp_dbg_data0               : in std_ulogic_vector(0 to 87);
     bp_dbg_data1               : in std_ulogic_vector(0 to 87);
     fu_iss_dbg_data            : in std_ulogic_vector(0 to 23);
     axu_dbg_data_t0            : in std_ulogic_vector(0 to 37);
     axu_dbg_data_t1            : in std_ulogic_vector(0 to 37);
     axu_dbg_data_t2            : in std_ulogic_vector(0 to 37);
     axu_dbg_data_t3            : in std_ulogic_vector(0 to 37);


     --perf
     ic_perf_event_t0           : in std_ulogic_vector(0 to 6);
     ic_perf_event_t1           : in std_ulogic_vector(0 to 6);
     ic_perf_event_t2           : in std_ulogic_vector(0 to 6);
     ic_perf_event_t3           : in std_ulogic_vector(0 to 6);
     ic_perf_event              : in std_ulogic_vector(0 to 1);
     ib_perf_event_t0           : in std_ulogic_vector(0 to 1);
     ib_perf_event_t1           : in std_ulogic_vector(0 to 1);
     ib_perf_event_t2           : in std_ulogic_vector(0 to 1);
     ib_perf_event_t3           : in std_ulogic_vector(0 to 1);
     fdep_perf_event_t0         : in std_ulogic_vector(0 to 11);
     fdep_perf_event_t1         : in std_ulogic_vector(0 to 11);
     fdep_perf_event_t2         : in std_ulogic_vector(0 to 11);
     fdep_perf_event_t3         : in std_ulogic_vector(0 to 11);
     fiss_perf_event_t0         : in std_ulogic_vector(0 to 7);
     fiss_perf_event_t1         : in std_ulogic_vector(0 to 7);
     fiss_perf_event_t2         : in std_ulogic_vector(0 to 7);
     fiss_perf_event_t3         : in std_ulogic_vector(0 to 7);
     pc_iu_event_mux_ctrls      : in std_ulogic_vector(0 to 47);
     pc_iu_event_count_mode     : in std_ulogic_vector(0 to 2);
     pc_iu_event_bus_enable     : in  std_ulogic;
     iu_pc_event_data           : out std_ulogic_vector(0 to 7)
);

-- synopsys translate_off


-- synopsys translate_on

end iuq_misc;
----
architecture iuq_misc of iuq_misc is

signal iuq_pv_gptr_scan_in      : std_ulogic;
signal iuq_pv_gptr_scan_out     : std_ulogic;

signal iuq_bh_scan_in           : std_ulogic;
signal iuq_bh_scan_out          : std_ulogic;
signal iuq_rm_scan_in           : std_ulogic;
signal iuq_rm_scan_out          : std_ulogic;
signal iuq_sp_scan_in           : std_ulogic;
signal iuq_sp_scan_out          : std_ulogic;
signal iuq_pf_scan_in           : std_ulogic;
signal iuq_pf_scan_out          : std_ulogic;
signal iuq_db_scan_in           : std_ulogic;
signal iuq_db_scan_out          : std_ulogic;

signal iuq_bh_repr_scan_in      : std_ulogic;
signal iuq_bh_repr_scan_out     : std_ulogic;
signal iuq_bh_time_scan_in      : std_ulogic;
signal iuq_bh_time_scan_out     : std_ulogic;
signal iuq_bh_abst_scan_in      : std_ulogic;
signal iuq_bh_abst_scan_out     : std_ulogic;

signal iuq_sp_ccfg_scan_in      : std_ulogic;
signal iuq_sp_ccfg_scan_out     : std_ulogic;
signal iuq_sp_bcfg_scan_in      : std_ulogic;
signal iuq_sp_bcfg_scan_out     : std_ulogic;
signal iuq_sp_dcfg_scan_in      : std_ulogic;
signal iuq_sp_dcfg_scan_out     : std_ulogic;


signal int_pc_iu_sg_2                 : std_ulogic_vector(0 to 3);
signal int_pc_iu_func_sl_thold_2      : std_ulogic_vector(0 to 3);
signal int_pc_iu_func_slp_sl_thold_2  : std_ulogic;
signal int_pc_iu_time_sl_thold_2      : std_ulogic;
signal int_pc_iu_repr_sl_thold_2      : std_ulogic;
signal int_pc_iu_abst_sl_thold_2      : std_ulogic;
signal int_pc_iu_cfg_sl_thold_2       : std_ulogic;
signal int_pc_iu_cfg_slp_sl_thold_2   : std_ulogic;
signal int_pc_iu_regf_slp_sl_thold_2  : std_ulogic;
signal int_pc_iu_ary_nsl_thold_2      : std_ulogic;
signal int_pc_iu_bolt_sl_thold_2      : std_ulogic;
signal pc_iu_bo_enable_2              : std_ulogic;
signal int_clkoff_b                   : std_ulogic_vector(0 to 2);
signal int_act_dis                    : std_ulogic_vector(0 to 2);
signal int_d_mode                     : std_ulogic_vector(0 to 2);
signal int_delay_lclkr                : std_ulogic_vector(0 to 14);
signal int_mpw1_b                     : std_ulogic_vector(0 to 14);
signal int_mpw2_b                     : std_ulogic_vector(0 to 2);
signal bht_g8t_clkoff_b               : std_ulogic;
signal bht_g8t_d_mode                 : std_ulogic;
signal bht_g8t_delay_lclkr            : std_ulogic_vector(0 to 4);
signal bht_g8t_mpw1_b                 : std_ulogic_vector(0 to 4);
signal bht_g8t_mpw2_b                 : std_ulogic;

signal bht_dbg_data             : std_ulogic_vector(0 to 31);
signal data_out0_int            : std_ulogic_vector(0 to 1);
signal data_out1_int            : std_ulogic_vector(0 to 1);
signal data_out2_int            : std_ulogic_vector(0 to 1);
signal data_out3_int            : std_ulogic_vector(0 to 1);


-- synopsys translate_off
-- synopsys translate_on


begin



pc_iu_sg_2               <= int_pc_iu_sg_2;
pc_iu_func_sl_thold_2    <= int_pc_iu_func_sl_thold_2;
pc_iu_func_slp_sl_thold_2<= int_pc_iu_func_slp_sl_thold_2;
pc_iu_time_sl_thold_2    <= int_pc_iu_time_sl_thold_2;
pc_iu_repr_sl_thold_2    <= int_pc_iu_repr_sl_thold_2;
pc_iu_abst_sl_thold_2    <= int_pc_iu_abst_sl_thold_2;
pc_iu_cfg_slp_sl_thold_2 <= int_pc_iu_cfg_slp_sl_thold_2;
pc_iu_regf_slp_sl_thold_2 <= int_pc_iu_regf_slp_sl_thold_2;
pc_iu_ary_nsl_thold_2    <= int_pc_iu_ary_nsl_thold_2;
pc_iu_bolt_sl_thold_2    <= int_pc_iu_bolt_sl_thold_2;
clkoff_b                 <= int_clkoff_b;
delay_lclkr(1 to 14)     <= int_delay_lclkr(1 to 14);
mpw1_b(1 to 14)          <= int_mpw1_b(1 to 14);



iuq_perv0 : entity work.iuq_perv
generic map (expand_type        => expand_type)
port map (
          vdd                      => vdd,
          gnd                      => gnd,
          nclk                     => nclk,
          pc_iu_sg_3               => pc_iu_sg_3,
          pc_iu_func_sl_thold_3    => pc_iu_func_sl_thold_3,
          pc_iu_func_slp_sl_thold_3 => pc_iu_func_slp_sl_thold_3,
          pc_iu_gptr_sl_thold_3    => pc_iu_gptr_sl_thold_3,
          pc_iu_time_sl_thold_3    => pc_iu_time_sl_thold_3,
          pc_iu_repr_sl_thold_3    => pc_iu_repr_sl_thold_3,
          pc_iu_abst_sl_thold_3    => pc_iu_abst_sl_thold_3,
          pc_iu_abst_slp_sl_thold_3 => pc_iu_abst_slp_sl_thold_3,
          pc_iu_cfg_sl_thold_3     => pc_iu_cfg_sl_thold_3,
          pc_iu_cfg_slp_sl_thold_3 => pc_iu_cfg_slp_sl_thold_3,
          pc_iu_regf_slp_sl_thold_3 => pc_iu_regf_slp_sl_thold_3,
          pc_iu_ary_nsl_thold_3    => pc_iu_ary_nsl_thold_3,
          pc_iu_ary_slp_nsl_thold_3 => pc_iu_ary_slp_nsl_thold_3,
          pc_iu_func_slp_nsl_thold_3   => pc_iu_func_slp_nsl_thold_3,
          pc_iu_bolt_sl_thold_3    => pc_iu_bolt_sl_thold_3,
          pc_iu_bo_enable_3        => pc_iu_bo_enable_3,
          pc_iu_fce_3              => pc_iu_fce_3,
          tc_ac_ccflush_dc         => tc_ac_ccflush_dc,
          scan_diag_dc             => scan_diag_dc,
          pc_iu_sg_2               => int_pc_iu_sg_2,
          pc_iu_func_sl_thold_2    => int_pc_iu_func_sl_thold_2,
          pc_iu_func_slp_sl_thold_2=> int_pc_iu_func_slp_sl_thold_2,
          pc_iu_time_sl_thold_2    => int_pc_iu_time_sl_thold_2,
          pc_iu_repr_sl_thold_2    => int_pc_iu_repr_sl_thold_2,
          pc_iu_abst_sl_thold_2    => int_pc_iu_abst_sl_thold_2,
          pc_iu_abst_slp_sl_thold_2 => pc_iu_abst_slp_sl_thold_2,
          pc_iu_cfg_sl_thold_2     => int_pc_iu_cfg_sl_thold_2,
          pc_iu_cfg_slp_sl_thold_2 => int_pc_iu_cfg_slp_sl_thold_2,
          pc_iu_regf_slp_sl_thold_2 => int_pc_iu_regf_slp_sl_thold_2,
          pc_iu_ary_nsl_thold_2    => int_pc_iu_ary_nsl_thold_2,
          pc_iu_ary_slp_nsl_thold_2 => pc_iu_ary_slp_nsl_thold_2,
          pc_iu_func_slp_nsl_thold_2  => pc_iu_func_slp_nsl_thold_2,
          pc_iu_bolt_sl_thold_2    => int_pc_iu_bolt_sl_thold_2,
          pc_iu_bo_enable_2        => pc_iu_bo_enable_2,
          pc_iu_fce_2              => pc_iu_fce_2,      
          clkoff_b                 => int_clkoff_b,
          act_dis                  => int_act_dis,
          d_mode                   => int_d_mode,
          delay_lclkr              => int_delay_lclkr,
          mpw1_b                   => int_mpw1_b,
          mpw2_b                   => int_mpw2_b,
          bht_g8t_clkoff_b         => bht_g8t_clkoff_b,
          bht_g8t_d_mode           => bht_g8t_d_mode,
          bht_g8t_delay_lclkr      => bht_g8t_delay_lclkr,
          bht_g8t_mpw1_b           => bht_g8t_mpw1_b,
          bht_g8t_mpw2_b           => bht_g8t_mpw2_b,
          g8t_clkoff_b             => g8t_clkoff_b,
          g8t_d_mode               => g8t_d_mode,
          g8t_delay_lclkr          => g8t_delay_lclkr,
          g8t_mpw1_b               => g8t_mpw1_b,
          g8t_mpw2_b               => g8t_mpw2_b,
          g6t_clkoff_b             => g6t_clkoff_b,
          g6t_d_mode               => g6t_d_mode,
          g6t_delay_lclkr          => g6t_delay_lclkr,
          g6t_mpw1_b               => g6t_mpw1_b,
          g6t_mpw2_b               => g6t_mpw2_b,
          cam_clkoff_b             => cam_clkoff_b,
          cam_d_mode               => cam_d_mode,
          cam_delay_lclkr          => cam_delay_lclkr,
          cam_mpw1_b               => cam_mpw1_b,
          cam_mpw2_b               => cam_mpw2_b,
          gptr_scan_in             => iuq_pv_gptr_scan_in,
          gptr_scan_out            => iuq_pv_gptr_scan_out);


bht: entity tri.tri_bht 
  generic map ( expand_type => expand_type )
  port map(
           gnd                          => gnd,
           vdd                          => vdd,
           vcs                          => vcs,
           nclk                         => nclk,
           pc_iu_func_sl_thold_2        => int_pc_iu_func_sl_thold_2(0),
           pc_iu_sg_2                   => int_pc_iu_sg_2(3),
           pc_iu_time_sl_thold_2        => int_pc_iu_time_sl_thold_2,
           pc_iu_abst_sl_thold_2        => int_pc_iu_abst_sl_thold_2,
           pc_iu_ary_nsl_thold_2        => int_pc_iu_ary_nsl_thold_2,
           pc_iu_repr_sl_thold_2        => int_pc_iu_repr_sl_thold_2,
           pc_iu_bolt_sl_thold_2        => int_pc_iu_bolt_sl_thold_2,
           tc_ac_ccflush_dc             => tc_ac_ccflush_dc,
           tc_ac_scan_dis_dc_b          => an_ac_scan_dis_dc_b,
           clkoff_b                     => int_clkoff_b(0),
           scan_diag_dc                 => scan_diag_dc,
           act_dis                      => int_act_dis(0),
           d_mode                       => int_d_mode(0),
           delay_lclkr                  => int_delay_lclkr(0),
           mpw1_b                       => int_mpw1_b(0),
           mpw2_b                       => int_mpw2_b(0),
           g8t_clkoff_b                 => bht_g8t_clkoff_b,
           g8t_d_mode                   => bht_g8t_d_mode,
           g8t_delay_lclkr              => bht_g8t_delay_lclkr,
           g8t_mpw1_b                   => bht_g8t_mpw1_b,
           g8t_mpw2_b                   => bht_g8t_mpw2_b,
           func_scan_in                 => iuq_bh_scan_in,
           time_scan_in                 => iuq_bh_time_scan_in,
           abst_scan_in                 => iuq_bh_abst_scan_in,
           repr_scan_in                 => iuq_bh_repr_scan_in,
           func_scan_out                => iuq_bh_scan_out,
           time_scan_out                => iuq_bh_time_scan_out,
           abst_scan_out                => iuq_bh_abst_scan_out,
           repr_scan_out                => iuq_bh_repr_scan_out,
           pc_iu_abist_di_0             => pc_iu_abist_di_0,           
           pc_iu_abist_g8t_bw_1         => pc_iu_abist_g8t_bw_1,       
           pc_iu_abist_g8t_bw_0         => pc_iu_abist_g8t_bw_0,       
           pc_iu_abist_waddr_0          => pc_iu_abist_waddr_0(3 to 9),        
           pc_iu_abist_g8t_wenb         => pc_iu_abist_g8t_wenb,       
           pc_iu_abist_raddr_0          => pc_iu_abist_raddr_0(3 to 9),        
           pc_iu_abist_g8t1p_renb_0     => pc_iu_abist_g8t1p_renb_0,   
           an_ac_lbist_ary_wrt_thru_dc  => an_ac_lbist_ary_wrt_thru_dc,
           pc_iu_abist_ena_dc           => pc_iu_abist_ena_dc,         
           pc_iu_abist_wl128_comp_ena   => pc_iu_abist_wl128_comp_ena, 
           pc_iu_abist_raw_dc_b         => pc_iu_abist_raw_dc_b,       
           pc_iu_abist_g8t_dcomp        => pc_iu_abist_g8t_dcomp,      
           pc_iu_bo_enable_2            => pc_iu_bo_enable_2,
           pc_iu_bo_reset               => pc_iu_bo_reset,
           pc_iu_bo_unload              => pc_iu_bo_unload,
           pc_iu_bo_repair              => pc_iu_bo_repair,
           pc_iu_bo_shdata              => pc_iu_bo_shdata,
           pc_iu_bo_select              => pc_iu_bo_select,
           iu_pc_bo_fail                => iu_pc_bo_fail,
           iu_pc_bo_diagout             => iu_pc_bo_diagout,
           r_act                        => r_act,      
           w_act                        => w_act,      
           r_addr                       => r_addr,     
           w_addr                       => w_addr,     
           data_in                      => data_in,    
           data_out0                    => data_out0_int,  
           data_out1                    => data_out1_int,  
           data_out2                    => data_out2_int,  
           data_out3                    => data_out3_int  
);

data_out0 <= data_out0_int;
data_out1 <= data_out1_int;
data_out2 <= data_out2_int;
data_out3 <= data_out3_int;

iuq_ram0 : entity work.iuq_ram
generic map ( expand_type => expand_type )
port map(
     vdd                                => vdd,
     gnd                                => gnd,
     nclk                               => nclk,
     pc_iu_func_sl_thold_2              => int_pc_iu_func_sl_thold_2(0),
     pc_iu_sg_2                         => int_pc_iu_sg_2(3),
     clkoff_b                           => int_clkoff_b(0),
     act_dis                            => int_act_dis(0),
     tc_ac_ccflush_dc                   => tc_ac_ccflush_dc,
     d_mode                             => int_d_mode(0),
     delay_lclkr                        => int_delay_lclkr(0),
     mpw1_b                             => int_mpw1_b(0),
     mpw2_b                             => int_mpw2_b(0),
     scan_in                            => iuq_rm_scan_in, --siv(3),
     scan_out                           => iuq_rm_scan_out, --sov(3),
     pc_iu_ram_instr                    => pc_iu_ram_instr,    
     pc_iu_ram_instr_ext                => pc_iu_ram_instr_ext,
     pc_iu_ram_force_cmplt              => pc_iu_ram_force_cmplt,
     xu_iu_ram_issue                    => xu_iu_ram_issue,
     rm_ib_iu4_val                      => rm_ib_iu4_val,      
     rm_ib_iu4_force_ram                => rm_ib_iu4_force_ram,      
     rm_ib_iu4_instr                    => rm_ib_iu4_instr
);    

iuq_spr : entity work.iuq_spr
generic map(regmode => regmode,
            a2mode => a2mode,
            expand_type => expand_type)
port map(
     slowspr_val_in             => slowspr_val_in,
     slowspr_rw_in              => slowspr_rw_in,
     slowspr_etid_in            => slowspr_etid_in,
     slowspr_addr_in            => slowspr_addr_in,
     slowspr_data_in            => slowspr_data_in,
     slowspr_done_in            => slowspr_done_in,
     slowspr_val_out            => slowspr_val_out,
     slowspr_rw_out             => slowspr_rw_out,
     slowspr_etid_out           => slowspr_etid_out,
     slowspr_addr_out           => slowspr_addr_out,
     slowspr_data_out           => slowspr_data_out,
     slowspr_done_out           => slowspr_done_out,
     spr_ic_idir_read           => spr_ic_idir_read,
     spr_ic_idir_way            => spr_ic_idir_way,
     spr_ic_idir_row            => spr_ic_idir_row,
     ic_spr_idir_done           => ic_spr_idir_done,
     ic_spr_idir_lru            => ic_spr_idir_lru,
     ic_spr_idir_parity         => ic_spr_idir_parity,
     ic_spr_idir_endian         => ic_spr_idir_endian,
     ic_spr_idir_valid          => ic_spr_idir_valid,
     ic_spr_idir_tag            => ic_spr_idir_tag,
     spr_ic_icbi_ack_en         => spr_ic_icbi_ack_en,
     spr_ic_cls                 => spr_ic_cls,
     spr_ic_clockgate_dis       => spr_ic_clockgate_dis,
     spr_ic_bp_config           => spr_ic_bp_config,
     spr_bp_config              => spr_bp_config,
     spr_bp_gshare_mask         => spr_bp_gshare_mask,
     spr_issue_high_mask        => spr_issue_high_mask,
     spr_issue_med_mask         => spr_issue_med_mask,
     spr_fiss_count0_max        => spr_fiss_count0_max,
     spr_fiss_count1_max        => spr_fiss_count1_max,
     spr_fiss_count2_max        => spr_fiss_count2_max,
     spr_fiss_count3_max        => spr_fiss_count3_max,
     spr_ic_pri_rand            => spr_ic_pri_rand,
     spr_ic_pri_rand_always     => spr_ic_pri_rand_always,
     spr_ic_pri_rand_flush      => spr_ic_pri_rand_flush,
     spr_fiss_pri_rand          => spr_fiss_pri_rand,
     spr_fiss_pri_rand_always   => spr_fiss_pri_rand_always,
     spr_fiss_pri_rand_flush    => spr_fiss_pri_rand_flush,
     spr_dec_mask               => spr_dec_mask,
     spr_dec_match              => spr_dec_match,
     spr_fdep_ll_hold           => spr_fdep_ll_hold,
     xu_iu_run_thread           => xu_iu_run_thread,
     iu_au_config_iucr_t0       => iu_au_config_iucr_t0,
     iu_au_config_iucr_t1       => iu_au_config_iucr_t1,
     iu_au_config_iucr_t2       => iu_au_config_iucr_t2,
     iu_au_config_iucr_t3       => iu_au_config_iucr_t3,
     xu_iu_ex6_pri              => xu_iu_ex6_pri,
     xu_iu_ex6_pri_val          => xu_iu_ex6_pri_val,
     xu_iu_raise_iss_pri        => xu_iu_raise_iss_pri,
     xu_iu_msr_gs               => xu_iu_msr_gs,
     xu_iu_msr_pr               => xu_iu_msr_pr,
     vdd                        => vdd,
     gnd                        => gnd,
     nclk                       => nclk,
     pc_iu_sg_2                 => int_pc_iu_sg_2(3),
     pc_iu_func_sl_thold_2      => int_pc_iu_func_sl_thold_2(0),
     pc_iu_cfg_sl_thold_2       => int_pc_iu_cfg_sl_thold_2,
     clkoff_b                   => int_clkoff_b(0),
     act_dis                    => int_act_dis(0),
     tc_ac_ccflush_dc           => tc_ac_ccflush_dc,
     d_mode                     => int_d_mode(0),
     delay_lclkr                => int_delay_lclkr(0),
     mpw1_b                     => int_mpw1_b(0),
     mpw2_b                     => int_mpw2_b(0),
     ccfg_scan_in               => iuq_sp_ccfg_scan_in,
     ccfg_scan_out              => iuq_sp_ccfg_scan_out,
     bcfg_scan_in               => iuq_sp_bcfg_scan_in,
     bcfg_scan_out              => iuq_sp_bcfg_scan_out,
     dcfg_scan_in               => iuq_sp_dcfg_scan_in,
     dcfg_scan_out              => iuq_sp_dcfg_scan_out,
     scan_in                    => iuq_sp_scan_in, --siv(10),
     scan_out                   => iuq_sp_scan_out --sov(10)
);

iuq_perf0 : entity work.iuq_perf
generic map(expand_type           => expand_type)
port map(
     vdd                                => vdd,
     gnd                                => gnd,
     nclk                               => nclk,
     pc_iu_func_sl_thold_2              => int_pc_iu_func_sl_thold_2(0),
     pc_iu_sg_2                         => int_pc_iu_sg_2(3),
     clkoff_b                           => int_clkoff_b(0),
     act_dis                            => int_act_dis(0),
     tc_ac_ccflush_dc                   => tc_ac_ccflush_dc,
     d_mode                             => int_d_mode(0),
     delay_lclkr                        => int_delay_lclkr(0),
     mpw1_b                             => int_mpw1_b(0),
     mpw2_b                             => int_mpw2_b(0),
     scan_in                            => iuq_pf_scan_in, 
     scan_out                           => iuq_pf_scan_out,

     xu_iu_msr_gs                       => xu_iu_msr_gs,
     xu_iu_msr_pr                       => xu_iu_msr_pr,

     ic_perf_event_t0                   => ic_perf_event_t0,
     ic_perf_event_t1                   => ic_perf_event_t1,
     ic_perf_event_t2                   => ic_perf_event_t2,
     ic_perf_event_t3                   => ic_perf_event_t3,
     ic_perf_event                      => ic_perf_event,

     ib_perf_event_t0                   => ib_perf_event_t0,
     ib_perf_event_t1                   => ib_perf_event_t1,
     ib_perf_event_t2                   => ib_perf_event_t2,
     ib_perf_event_t3                   => ib_perf_event_t3,
                                         
     fdep_perf_event_t0                 => fdep_perf_event_t0,
     fdep_perf_event_t1                 => fdep_perf_event_t1,
     fdep_perf_event_t2                 => fdep_perf_event_t2,
     fdep_perf_event_t3                 => fdep_perf_event_t3,
                                         
     fiss_perf_event_t0                 => fiss_perf_event_t0,
     fiss_perf_event_t1                 => fiss_perf_event_t1,
     fiss_perf_event_t2                 => fiss_perf_event_t2,
     fiss_perf_event_t3                 => fiss_perf_event_t3,
                                         
     pc_iu_event_mux_ctrls              => pc_iu_event_mux_ctrls,
     pc_iu_event_count_mode             => pc_iu_event_count_mode,
     pc_iu_event_bus_enable             => pc_iu_event_bus_enable,
                                        
     iu_pc_event_data                   => iu_pc_event_data
);

bht_dbg_data(0 to 7)    <= r_addr(0 to 7);
bht_dbg_data(8 to 15)   <= data_out0_int(0 to 1) & data_out1_int(0 to 1) & data_out2_int(0 to 1) & data_out3_int(0 to 1);
bht_dbg_data(16 to 23)  <= w_addr(0 to 7);
bht_dbg_data(24 to 25)  <= data_in(0 to 1);
bht_dbg_data(26 to 27)  <= '0' & r_act;
bht_dbg_data(28 to 31)  <= w_act(0 to 3);


iuq_dbg0 : entity work.iuq_dbg
generic map(expand_type           => expand_type)
port map(
     vdd                                => vdd,
     gnd                                => gnd,
     nclk                               => nclk,
     pc_iu_func_slp_sl_thold_2          => int_pc_iu_func_slp_sl_thold_2,
     pc_iu_sg_2                         => int_pc_iu_sg_2(3),
     clkoff_b                           => int_clkoff_b(0),
     act_dis                            => int_act_dis(0),
     tc_ac_ccflush_dc                   => tc_ac_ccflush_dc,
     d_mode                             => int_d_mode(0),
     delay_lclkr                        => int_delay_lclkr(0),
     mpw1_b                             => int_mpw1_b(0),
     mpw2_b                             => int_mpw2_b(0),
     scan_in                            => iuq_db_scan_in, 
     scan_out                           => iuq_db_scan_out,
     fiss_dbg_data                      => fiss_dbg_data,  
     fdep_dbg_data                      => fdep_dbg_data,  
     ib_dbg_data                        => ib_dbg_data,    
     bp_dbg_data0                       => bp_dbg_data0,   
     bp_dbg_data1                       => bp_dbg_data1,   
     fu_iss_dbg_data                    => fu_iss_dbg_data,
     axu_dbg_data_t0                    => axu_dbg_data_t0,
     axu_dbg_data_t1                    => axu_dbg_data_t1,
     axu_dbg_data_t2                    => axu_dbg_data_t2,
     axu_dbg_data_t3                    => axu_dbg_data_t3,
     bht_dbg_data                       => bht_dbg_data,
     pc_iu_trace_bus_enable		=> pc_iu_trace_bus_enable,
     pc_iu_debug_mux_ctrls              => pc_iu_debug_mux_ctrls,
     debug_data_in                      => debug_data_in,
     trace_triggers_in                  => trace_triggers_in,
     debug_data_out                     => debug_data_out,
     trace_triggers_out                 => trace_triggers_out
);




-------------------------------------------------
-- scan
-------------------------------------------------

iuq_pf_scan_in          <= func_scan_in(0);
iuq_sp_scan_in          <= iuq_pf_scan_out;            
iuq_bh_scan_in          <= iuq_sp_scan_out;             
func_scan_out(0)        <= iuq_bh_scan_out and an_ac_scan_dis_dc_b;

iuq_db_scan_in          <= func_scan_in(1);
iuq_rm_scan_in          <= iuq_db_scan_out;
func_scan_out(1)        <= iuq_rm_scan_out and an_ac_scan_dis_dc_b;

iuq_bh_time_scan_in     <= time_scan_in;
time_scan_out           <= iuq_bh_time_scan_out and an_ac_scan_dis_dc_b;

iuq_sp_ccfg_scan_in     <= ccfg_scan_in;
iuq_sp_bcfg_scan_in     <= bcfg_scan_in;
iuq_sp_dcfg_scan_in     <= dcfg_scan_in;
iuq_pv_gptr_scan_in     <= gptr_scan_in;
iuq_bh_abst_scan_in     <= abst_scan_in;        
iuq_bh_repr_scan_in     <= repr_scan_in;         

ccfg_scan_out           <= iuq_sp_ccfg_scan_out and an_ac_scan_dis_dc_b;
bcfg_scan_out           <= iuq_sp_bcfg_scan_out and an_ac_scan_dis_dc_b;
dcfg_scan_out           <= iuq_sp_dcfg_scan_out and an_ac_scan_dis_dc_b;
gptr_scan_out           <= iuq_pv_gptr_scan_out and an_ac_scan_dis_dc_b;
abst_scan_out           <= iuq_bh_abst_scan_out and an_ac_scan_dis_dc_b;        
repr_scan_out           <= iuq_bh_repr_scan_out and an_ac_scan_dis_dc_b;         
           


end iuq_misc;
