-- © IBM Corp. 2020
-- This softcore is licensed under and subject to the terms of the CC-BY 4.0
-- license (https://creativecommons.org/licenses/by/4.0/legalcode). 
-- Additional rights, including the right to physically implement a softcore 
-- that is compliant with the required sections of the Power ISA 
-- Specification, will be available at no cost via the OpenPOWER Foundation. 
-- This README will be updated with additional information when OpenPOWER's 
-- license is available.

			

--********************************************************************
--*
--* TITLE: Instruction Cache Directory
--*
--* NAME: iuq_ic_dir.vhdl
--*
--*********************************************************************
library ieee,ibm,support,tri,work;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ibm.std_ulogic_unsigned.all;
use ibm.std_ulogic_support.all;
use ibm.std_ulogic_function_support.all;
use support.power_logic_pkg.all;
use tri.tri_latches_pkg.all;
use work.iuq_pkg.all;

entity iuq_ic_dir is
generic(expand_type     : integer := 2);
port(
     vcs                        : inout power_logic;
     vdd                        : inout power_logic;
     gnd                        : inout power_logic;
     nclk                       : in clk_logic;
     pc_iu_func_sl_thold_0_b    : in std_ulogic;
     pc_iu_func_slp_sl_thold_0_b: in std_ulogic;
     pc_iu_time_sl_thold_0      : in std_ulogic;
     pc_iu_repr_sl_thold_0      : in std_ulogic;
     pc_iu_abst_sl_thold_0      : in std_ulogic;
     pc_iu_abst_sl_thold_0_b    : in std_ulogic;
     pc_iu_abst_slp_sl_thold_0  : in std_ulogic;
     pc_iu_ary_nsl_thold_0      : in std_ulogic;
     pc_iu_ary_slp_nsl_thold_0  : in std_ulogic;
     pc_iu_bolt_sl_thold_0      : in std_ulogic;
     pc_iu_sg_0                 : in std_ulogic;
     pc_iu_sg_1                 : in std_ulogic;        
     forcee : in std_ulogic;
     funcslp_force : in std_ulogic;
     abst_force : in std_ulogic;

     d_mode                     : in std_ulogic;
     delay_lclkr                : in std_ulogic;
     mpw1_b                     : in std_ulogic;
     mpw2_b                     : in std_ulogic;
     clkoff_b                   : in std_ulogic;  
     act_dis                    : in std_ulogic;  

     g8t_clkoff_b               : in std_ulogic;
     g8t_d_mode                 : in std_ulogic;
     g8t_delay_lclkr            : in std_ulogic_vector(0 to 4);
     g8t_mpw1_b                 : in std_ulogic_vector(0 to 4);
     g8t_mpw2_b                 : in std_ulogic;

     g6t_clkoff_b               : in std_ulogic;
     g6t_act_dis                : in std_ulogic;
     g6t_d_mode                 : in std_ulogic;
     g6t_delay_lclkr            : in std_ulogic_vector(0 to 3);
     g6t_mpw1_b                 : in std_ulogic_vector(0 to 4);
     g6t_mpw2_b                 : in std_ulogic;

     tc_ac_ccflush_dc           : in std_ulogic;
     an_ac_scan_dis_dc_b        : in std_ulogic;
     an_ac_scan_diag_dc         : in std_ulogic;
     func_scan_in               : in std_ulogic_vector(0 to 1);
     time_scan_in               : in std_ulogic;
     repr_scan_in               : in std_ulogic;
     abst_scan_in               : in std_ulogic_vector(0 to 2);
     func_scan_out              : out std_ulogic_vector(0 to 1);
     time_scan_out              : out std_ulogic;
     repr_scan_out              : out std_ulogic;
     abst_scan_out              : out std_ulogic_vector(0 to 2);

     spr_ic_cls                 : in std_ulogic;        
     spr_ic_clockgate_dis       : in std_ulogic;

     spr_ic_idir_way            : in std_ulogic_vector(0 to 1);
     ic_spr_idir_done           : out std_ulogic;
     ic_spr_idir_lru            : out std_ulogic_vector(0 to 2);
     ic_spr_idir_parity         : out std_ulogic_vector(0 to 3);
     ic_spr_idir_endian         : out std_ulogic;
     ic_spr_idir_valid          : out std_ulogic;
     ic_spr_idir_tag            : out std_ulogic_vector(0 to 29);

     ic_perf_event_t0           : out std_ulogic_vector(4 to 6);
     ic_perf_event_t1           : out std_ulogic_vector(4 to 6);
     ic_perf_event_t2           : out std_ulogic_vector(4 to 6);
     ic_perf_event_t3           : out std_ulogic_vector(4 to 6);
     ic_perf_event              : out std_ulogic_vector(0 to 1);

     iu_pc_err_icache_parity    : out std_ulogic;
     iu_pc_err_icachedir_parity : out std_ulogic;
     iu_pc_err_icachedir_multihit : out std_ulogic;

     pc_iu_inj_icache_parity    : in  std_ulogic;
     pc_iu_inj_icachedir_parity : in  std_ulogic;
     pc_iu_inj_icachedir_multihit : in  std_ulogic;

     pc_iu_abist_g8t_wenb       : in std_ulogic;
     pc_iu_abist_g8t1p_renb_0   : in std_ulogic;
     pc_iu_abist_di_0           : in std_ulogic_vector(0 to 3);
     pc_iu_abist_g8t_bw_1       : in std_ulogic;
     pc_iu_abist_g8t_bw_0       : in std_ulogic;
     pc_iu_abist_waddr_0        : in std_ulogic_vector(4 to 9);
     pc_iu_abist_raddr_0        : in std_ulogic_vector(2 to 9);
     pc_iu_abist_ena_dc         : in std_ulogic;
     pc_iu_abist_wl64_comp_ena  : in std_ulogic;
     pc_iu_abist_raw_dc_b       : in std_ulogic;
     pc_iu_abist_g8t_dcomp      : in std_ulogic_vector(0 to 3);
     pc_iu_abist_g6t_bw         : in std_ulogic_vector(0 to 1);
     pc_iu_abist_di_g6t_2r      : in std_ulogic_vector(0 to 3);
     pc_iu_abist_wl256_comp_ena : in std_ulogic;
     pc_iu_abist_dcomp_g6t_2r   : in std_ulogic_vector(0 to 3);
     pc_iu_abist_g6t_r_wb       : in std_ulogic;
     an_ac_lbist_ary_wrt_thru_dc: in std_ulogic;

     pc_iu_bo_enable_2          : in std_ulogic; 
     pc_iu_bo_reset             : in std_ulogic;
     pc_iu_bo_unload            : in std_ulogic;
     pc_iu_bo_repair            : in std_ulogic;
     pc_iu_bo_shdata            : in std_ulogic;
     pc_iu_bo_select            : in std_ulogic_vector(0 to 3);
     iu_pc_bo_fail              : out std_ulogic_vector(0 to 3);
     iu_pc_bo_diagout           : out std_ulogic_vector(0 to 3);

     xu_iu_ici                  : in  std_ulogic;

     iu_mm_ierat_epn            : out std_ulogic_vector(0 to 51);

     iu_ierat_iu1_back_inv      : out std_ulogic;

     ierat_iu_iu2_rpn           : in std_ulogic_vector(REAL_IFAR'left to 51);
     ierat_iu_iu2_wimge         : in std_ulogic_vector(0 to 4);
     ierat_iu_iu2_u             : in std_ulogic_vector(0 to 3);
     ierat_iu_iu2_error         : in std_ulogic_vector(0 to 2);
     ierat_iu_iu2_miss          : in std_ulogic;
     ierat_iu_iu2_multihit      : in std_ulogic;
     ierat_iu_iu2_isi           : in std_ulogic;

     ics_icd_dir_rd_act         : in std_ulogic;
     ics_icd_data_rd_act        : in std_ulogic;
     ics_icd_iu0_valid          : in std_ulogic;
     ics_icd_iu0_tid            : in std_ulogic_vector(0 to 3);
     ics_icd_iu0_ifar           : in EFF_IFAR;
     ics_icd_iu0_inval          : in std_ulogic;
     ics_icd_iu0_2ucode         : in std_ulogic;
     ics_icd_iu0_2ucode_type    : in std_ulogic;
     ics_icd_iu0_spr_idir_read  : in std_ulogic;

     icd_ics_iu1_valid          : out std_ulogic;
     icd_ics_iu1_tid            : out std_ulogic_vector(0 to 3);
     icd_ics_iu1_ifar           : out EFF_IFAR;
     icd_ics_iu1_2ucode         : out std_ulogic;
     icd_ics_iu1_2ucode_type    : out std_ulogic;

     ics_icd_all_flush_prev     : in std_ulogic_vector(0 to 3);
     ics_icd_iu1_flush_tid      : in std_ulogic_vector(0 to 3);
     ics_icd_iu2_flush_tid      : in std_ulogic_vector(0 to 3);
     icd_ics_iu2_miss_flush_prev: out std_ulogic_vector(0 to 3); 
     icd_ics_iu2_ifar_eff       : out EFF_IFAR;
     icd_ics_iu2_2ucode         : out std_ulogic;
     icd_ics_iu2_2ucode_type    : out std_ulogic;
     icd_ics_iu3_parity_flush   : out std_ulogic_vector(0 to 3);
     icd_ics_iu3_ifar           : out EFF_IFAR;
     icd_ics_iu3_2ucode         : out std_ulogic;
     icd_ics_iu3_2ucode_type    : out std_ulogic;

     icm_icd_lru_addr           : in std_ulogic_vector(52 to 57);
     icm_icd_dir_inval          : in std_ulogic;
     icm_icd_dir_val            : in std_ulogic;
     icm_icd_data_write         : in std_ulogic;
     icm_icd_reload_addr        : in std_ulogic_vector(52 to 59);
     icm_icd_reload_data        : in std_ulogic_vector(0 to 161);
     icm_icd_reload_way         : in std_ulogic_vector(0 to 3);
     icm_icd_load_tid           : in std_ulogic_vector(0 to 3);
     icm_icd_load_addr          : in EFF_IFAR;
     icm_icd_load_2ucode        : in std_ulogic;
     icm_icd_load_2ucode_type   : in std_ulogic;
     icm_icd_dir_write          : in std_ulogic;
     icm_icd_dir_write_addr     : in std_ulogic_vector(REAL_IFAR'left to 57);
     icm_icd_dir_write_endian   : in std_ulogic;
     icm_icd_dir_write_way      : in std_ulogic_vector(0 to 3);
     icm_icd_lru_write          : in std_ulogic;
     icm_icd_lru_write_addr     : in std_ulogic_vector(52 to 57);
     icm_icd_lru_write_way      : in std_ulogic_vector(0 to 3);
     icm_icd_ecc_inval          : in std_ulogic;
     icm_icd_ecc_addr           : in std_ulogic_vector(52 to 57);
     icm_icd_ecc_way            : in std_ulogic_vector(0 to 3);
     icm_icd_iu3_ecc_fp_cancel  : in std_ulogic;
     icm_icd_iu3_ecc_err        : in std_ulogic;
     icm_icd_any_reld_r2        : in std_ulogic;
     icm_icd_any_checkecc       : in std_ulogic;

     icd_icm_miss               : out std_ulogic;
     icd_icm_tid                : out std_ulogic_vector(0 to 3);
     icd_icm_addr_real          : out REAL_IFAR;
     icd_icm_addr_eff           : out std_ulogic_vector(EFF_IFAR'left to 51);
     icd_icm_wimge              : out std_ulogic_vector(0 to 4); 
     icd_icm_userdef            : out std_ulogic_vector(0 to 3);
     icd_icm_2ucode             : out std_ulogic;
     icd_icm_2ucode_type        : out std_ulogic;
     icd_icm_iu3_erat_err       : out std_ulogic;
     icd_icm_iu2_inval          : out std_ulogic;
     icd_icm_ici                : out std_ulogic;
     icd_icm_any_iu2_valid      : out std_ulogic;

     icd_icm_row_lru            : out std_ulogic_vector(0 to 2);
     icd_icm_row_val            : out std_ulogic_vector(0 to 3);

     ic_bp_iu3_val              : out std_ulogic_vector(0 to 3);
     ic_bp_iu3_tid              : out std_ulogic_vector(0 to 3);
     ic_bp_iu3_ifar             : out EFF_IFAR;
     ic_bp_iu3_2ucode           : out std_ulogic;
     ic_bp_iu3_2ucode_type      : out std_ulogic;
     ic_bp_iu3_error            : out std_ulogic_vector(0 to 2);
     ic_bp_iu3_flush            : out std_ulogic;

     ic_bp_iu3_0_instr          : out std_ulogic_vector(0 to 35);
     ic_bp_iu3_1_instr          : out std_ulogic_vector(0 to 35);
     ic_bp_iu3_2_instr          : out std_ulogic_vector(0 to 35);
     ic_bp_iu3_3_instr          : out std_ulogic_vector(0 to 35);

     event_bus_enable           : in std_ulogic;

     trace_bus_enable           : in std_ulogic;
     dir_dbg_data0              : out std_ulogic_vector(0 to 87);
     dir_dbg_data1              : out std_ulogic_vector(0 to 87);
     dir_dbg_data2              : out std_ulogic_vector(0 to 43);
     dir_dbg_trigger0           : out std_ulogic_vector(0 to 7);
     dir_dbg_trigger1           : out std_ulogic_vector(0 to 11)
);
-- synopsys translate_off
-- synopsys translate_on
end iuq_ic_dir;
ARCHITECTURE IUQ_IC_DIR
          OF IUQ_IC_DIR
          IS
constant ways                   : natural := 4;
constant dir_ext_bits           : natural := 8 - ((52-REAL_IFAR'left+1) mod 8);
constant dir_parity_width       : natural := (52-REAL_IFAR'left+1+dir_ext_bits)/8;
constant dir_array_way_width    : natural := 36;
constant dir_way_width          : natural := 52-REAL_IFAR'left+1+dir_parity_width;
-- Chain 0
constant dbg_dir_write_offset           : natural := 0;
constant dbg_dir_rd_act_offset          : natural := dbg_dir_write_offset + 1;
constant dbg_iu2_lru_rd_update_offset   : natural := dbg_dir_rd_act_offset + 1;
constant dbg_iu2_rd_way_tag_hit_offset  : natural := dbg_iu2_lru_rd_update_offset + 1;
constant dbg_iu2_rd_way_hit_offset      : natural := dbg_iu2_rd_way_tag_hit_offset + 4;
constant dbg_load_iu2_offset            : natural := dbg_iu2_rd_way_hit_offset + 4;
constant iu1_valid_offset               : natural := dbg_load_iu2_offset + 1;
constant spare_a_offset                 : natural := iu1_valid_offset + 1;
constant iu1_tid_offset                 : natural := spare_a_offset + 8;
constant iu1_ifar_offset                : natural := iu1_tid_offset + 4;
constant iu1_inval_offset               : natural := iu1_ifar_offset + EFF_IFAR'length;
constant iu1_2ucode_offset              : natural := iu1_inval_offset + 1;
constant iu1_2ucode_type_offset         : natural := iu1_2ucode_offset + 1;
constant iu2_valid_offset               : natural := iu1_2ucode_type_offset + 1;
constant iu2_tid_offset                 : natural := iu2_valid_offset + 1;
constant iu2_ifar_eff_offset            : natural := iu2_tid_offset + 4;
constant iu2_2ucode_offset              : natural := iu2_ifar_eff_offset + EFF_IFAR'length;
constant iu2_2ucode_type_offset         : natural := iu2_2ucode_offset + 1;
constant iu2_inval_offset               : natural := iu2_2ucode_type_offset + 1;
constant iu2_dir_rd_val_offset          : natural := iu2_inval_offset + 1;
constant iu3_instr_valid_offset         : natural := iu2_dir_rd_val_offset + 4;
constant iu3_tid_offset                 : natural := iu3_instr_valid_offset + 4;
constant iu3_ifar_offset                : natural := iu3_tid_offset + 4;
constant iu3_ifar_dec_offset            : natural := iu3_ifar_offset + EFF_IFAR'length;
constant iu3_2ucode_offset              : natural := iu3_ifar_dec_offset + 4;
constant iu3_2ucode_type_offset         : natural := iu3_2ucode_offset + 1;
constant iu3_erat_err_offset            : natural := iu3_2ucode_type_offset + 1;
constant iu3_instr_offset               : natural := iu3_erat_err_offset + 3;
constant iu3_dir_parity_err_way_offset  : natural := iu3_instr_offset + 1;
constant iu3_data_parity_err_way_offset : natural := iu3_dir_parity_err_way_offset + 4;
constant iu3_parity_needs_flush_offset  : natural := iu3_data_parity_err_way_offset + 4;
constant iu3_rd_parity_err_offset       : natural := iu3_parity_needs_flush_offset + 4;
constant iu3_rd_miss_offset             : natural := iu3_rd_parity_err_offset + 1;
constant err_icache_parity_offset       : natural := iu3_rd_miss_offset + 1;
constant err_icachedir_parity_offset    : natural := err_icache_parity_offset + 1;
constant iu3_multihit_err_way_offset    : natural := err_icachedir_parity_offset + 1;
constant iu3_multihit_flush_offset      : natural := iu3_multihit_err_way_offset + 4;
constant iu3_parity_tag_offset          : natural := iu3_multihit_flush_offset + 1;
constant spare_slp_offset               : natural := iu3_parity_tag_offset + 6;
constant perf_instr_count_t0_offset     : natural := spare_slp_offset + 16;
constant perf_instr_count_t1_offset     : natural := perf_instr_count_t0_offset + 2;
constant perf_instr_count_t2_offset     : natural := perf_instr_count_t1_offset + 2;
constant perf_instr_count_t3_offset     : natural := perf_instr_count_t2_offset + 2;
constant perf_event_t0_offset           : natural := perf_instr_count_t3_offset + 2;
constant perf_event_t1_offset           : natural := perf_event_t0_offset + 3;
constant perf_event_t2_offset           : natural := perf_event_t1_offset + 3;
constant perf_event_t3_offset           : natural := perf_event_t2_offset + 3;
constant perf_event_offset              : natural := perf_event_t3_offset + 3;
constant spr_ic_cls_offset              : natural := perf_event_offset + 2;
constant spr_ic_idir_way_offset         : natural := spr_ic_cls_offset + 1;
constant spare_b_offset                 : natural := spr_ic_idir_way_offset + 2;
constant iu1_spr_idir_read_offset       : natural := spare_b_offset + 8;
constant iu2_spr_idir_read_offset       : natural := iu1_spr_idir_read_offset + 1;
constant iu2_spr_idir_lru_offset        : natural := iu2_spr_idir_read_offset + 1;
constant scan0_right            : natural := iu2_spr_idir_lru_offset + 3 - 1;
-- Chain 1
constant scan1_left                     : natural := scan0_right + 1;
constant iu2_dir_dataout_offset         : natural := scan1_left;
constant iu2_dir_dataout_0_par_offset   : natural := iu2_dir_dataout_offset + 1;
constant iu2_dir_dataout_1_par_offset   : natural := iu2_dir_dataout_0_par_offset + dir_parity_width;
constant iu2_dir_dataout_2_par_offset   : natural := iu2_dir_dataout_1_par_offset + dir_parity_width;
constant iu2_dir_dataout_3_par_offset   : natural := iu2_dir_dataout_2_par_offset + dir_parity_width;
constant iu2_data_dataout_offset        : natural := iu2_dir_dataout_3_par_offset + dir_parity_width;
constant xu_iu_ici_offset               : natural := iu2_data_dataout_offset + 162*ways;
constant dir_row0_val_offset            : natural := xu_iu_ici_offset + 1;
constant dir_row1_val_offset            : natural := dir_row0_val_offset     + 4;
constant dir_row2_val_offset            : natural := dir_row1_val_offset     + 4;
constant dir_row3_val_offset            : natural := dir_row2_val_offset     + 4;
constant dir_row4_val_offset            : natural := dir_row3_val_offset     + 4;
constant dir_row5_val_offset            : natural := dir_row4_val_offset     + 4;
constant dir_row6_val_offset            : natural := dir_row5_val_offset     + 4;
constant dir_row7_val_offset            : natural := dir_row6_val_offset     + 4;
constant dir_row8_val_offset            : natural := dir_row7_val_offset     + 4;
constant dir_row9_val_offset            : natural := dir_row8_val_offset     + 4;
constant dir_row10_val_offset           : natural := dir_row9_val_offset     + 4;
constant dir_row11_val_offset           : natural := dir_row10_val_offset    + 4;
constant dir_row12_val_offset           : natural := dir_row11_val_offset    + 4;
constant dir_row13_val_offset           : natural := dir_row12_val_offset    + 4;
constant dir_row14_val_offset           : natural := dir_row13_val_offset    + 4;
constant dir_row15_val_offset           : natural := dir_row14_val_offset    + 4;
constant dir_row16_val_offset           : natural := dir_row15_val_offset    + 4;
constant dir_row17_val_offset           : natural := dir_row16_val_offset    + 4;
constant dir_row18_val_offset           : natural := dir_row17_val_offset    + 4;
constant dir_row19_val_offset           : natural := dir_row18_val_offset    + 4;
constant dir_row20_val_offset           : natural := dir_row19_val_offset    + 4;
constant dir_row21_val_offset           : natural := dir_row20_val_offset    + 4;
constant dir_row22_val_offset           : natural := dir_row21_val_offset    + 4;
constant dir_row23_val_offset           : natural := dir_row22_val_offset    + 4;
constant dir_row24_val_offset           : natural := dir_row23_val_offset    + 4;
constant dir_row25_val_offset           : natural := dir_row24_val_offset    + 4;
constant dir_row26_val_offset           : natural := dir_row25_val_offset    + 4;
constant dir_row27_val_offset           : natural := dir_row26_val_offset    + 4;
constant dir_row28_val_offset           : natural := dir_row27_val_offset    + 4;
constant dir_row29_val_offset           : natural := dir_row28_val_offset    + 4;
constant dir_row30_val_offset           : natural := dir_row29_val_offset    + 4;
constant dir_row31_val_offset           : natural := dir_row30_val_offset    + 4;
constant dir_row32_val_offset           : natural := dir_row31_val_offset    + 4;
constant dir_row33_val_offset           : natural := dir_row32_val_offset    + 4;
constant dir_row34_val_offset           : natural := dir_row33_val_offset    + 4;
constant dir_row35_val_offset           : natural := dir_row34_val_offset    + 4;
constant dir_row36_val_offset           : natural := dir_row35_val_offset    + 4;
constant dir_row37_val_offset           : natural := dir_row36_val_offset    + 4;
constant dir_row38_val_offset           : natural := dir_row37_val_offset    + 4;
constant dir_row39_val_offset           : natural := dir_row38_val_offset    + 4;
constant dir_row40_val_offset           : natural := dir_row39_val_offset    + 4;
constant dir_row41_val_offset           : natural := dir_row40_val_offset    + 4;
constant dir_row42_val_offset           : natural := dir_row41_val_offset    + 4;
constant dir_row43_val_offset           : natural := dir_row42_val_offset    + 4;
constant dir_row44_val_offset           : natural := dir_row43_val_offset    + 4;
constant dir_row45_val_offset           : natural := dir_row44_val_offset    + 4;
constant dir_row46_val_offset           : natural := dir_row45_val_offset    + 4;
constant dir_row47_val_offset           : natural := dir_row46_val_offset    + 4;
constant dir_row48_val_offset           : natural := dir_row47_val_offset    + 4;
constant dir_row49_val_offset           : natural := dir_row48_val_offset    + 4;
constant dir_row50_val_offset           : natural := dir_row49_val_offset    + 4;
constant dir_row51_val_offset           : natural := dir_row50_val_offset    + 4;
constant dir_row52_val_offset           : natural := dir_row51_val_offset    + 4;
constant dir_row53_val_offset           : natural := dir_row52_val_offset    + 4;
constant dir_row54_val_offset           : natural := dir_row53_val_offset    + 4;
constant dir_row55_val_offset           : natural := dir_row54_val_offset    + 4;
constant dir_row56_val_offset           : natural := dir_row55_val_offset    + 4;
constant dir_row57_val_offset           : natural := dir_row56_val_offset    + 4;
constant dir_row58_val_offset           : natural := dir_row57_val_offset    + 4;
constant dir_row59_val_offset           : natural := dir_row58_val_offset    + 4;
constant dir_row60_val_offset           : natural := dir_row59_val_offset    + 4;
constant dir_row61_val_offset           : natural := dir_row60_val_offset    + 4;
constant dir_row62_val_offset           : natural := dir_row61_val_offset    + 4;
constant dir_row63_val_offset           : natural := dir_row62_val_offset    + 4;
constant dir_row0_lru_offset            : natural := dir_row63_val_offset + 4;
constant dir_row1_lru_offset            : natural := dir_row0_lru_offset     + 3;
constant dir_row2_lru_offset            : natural := dir_row1_lru_offset     + 3;
constant dir_row3_lru_offset            : natural := dir_row2_lru_offset     + 3;
constant dir_row4_lru_offset            : natural := dir_row3_lru_offset     + 3;
constant dir_row5_lru_offset            : natural := dir_row4_lru_offset     + 3;
constant dir_row6_lru_offset            : natural := dir_row5_lru_offset     + 3;
constant dir_row7_lru_offset            : natural := dir_row6_lru_offset     + 3;
constant dir_row8_lru_offset            : natural := dir_row7_lru_offset     + 3;
constant dir_row9_lru_offset            : natural := dir_row8_lru_offset     + 3;
constant dir_row10_lru_offset           : natural := dir_row9_lru_offset     + 3;
constant dir_row11_lru_offset           : natural := dir_row10_lru_offset    + 3;
constant dir_row12_lru_offset           : natural := dir_row11_lru_offset    + 3;
constant dir_row13_lru_offset           : natural := dir_row12_lru_offset    + 3;
constant dir_row14_lru_offset           : natural := dir_row13_lru_offset    + 3;
constant dir_row15_lru_offset           : natural := dir_row14_lru_offset    + 3;
constant dir_row16_lru_offset           : natural := dir_row15_lru_offset    + 3;
constant dir_row17_lru_offset           : natural := dir_row16_lru_offset    + 3;
constant dir_row18_lru_offset           : natural := dir_row17_lru_offset    + 3;
constant dir_row19_lru_offset           : natural := dir_row18_lru_offset    + 3;
constant dir_row20_lru_offset           : natural := dir_row19_lru_offset    + 3;
constant dir_row21_lru_offset           : natural := dir_row20_lru_offset    + 3;
constant dir_row22_lru_offset           : natural := dir_row21_lru_offset    + 3;
constant dir_row23_lru_offset           : natural := dir_row22_lru_offset    + 3;
constant dir_row24_lru_offset           : natural := dir_row23_lru_offset    + 3;
constant dir_row25_lru_offset           : natural := dir_row24_lru_offset    + 3;
constant dir_row26_lru_offset           : natural := dir_row25_lru_offset    + 3;
constant dir_row27_lru_offset           : natural := dir_row26_lru_offset    + 3;
constant dir_row28_lru_offset           : natural := dir_row27_lru_offset    + 3;
constant dir_row29_lru_offset           : natural := dir_row28_lru_offset    + 3;
constant dir_row30_lru_offset           : natural := dir_row29_lru_offset    + 3;
constant dir_row31_lru_offset           : natural := dir_row30_lru_offset    + 3;
constant dir_row32_lru_offset           : natural := dir_row31_lru_offset    + 3;
constant dir_row33_lru_offset           : natural := dir_row32_lru_offset    + 3;
constant dir_row34_lru_offset           : natural := dir_row33_lru_offset    + 3;
constant dir_row35_lru_offset           : natural := dir_row34_lru_offset    + 3;
constant dir_row36_lru_offset           : natural := dir_row35_lru_offset    + 3;
constant dir_row37_lru_offset           : natural := dir_row36_lru_offset    + 3;
constant dir_row38_lru_offset           : natural := dir_row37_lru_offset    + 3;
constant dir_row39_lru_offset           : natural := dir_row38_lru_offset    + 3;
constant dir_row40_lru_offset           : natural := dir_row39_lru_offset    + 3;
constant dir_row41_lru_offset           : natural := dir_row40_lru_offset    + 3;
constant dir_row42_lru_offset           : natural := dir_row41_lru_offset    + 3;
constant dir_row43_lru_offset           : natural := dir_row42_lru_offset    + 3;
constant dir_row44_lru_offset           : natural := dir_row43_lru_offset    + 3;
constant dir_row45_lru_offset           : natural := dir_row44_lru_offset    + 3;
constant dir_row46_lru_offset           : natural := dir_row45_lru_offset    + 3;
constant dir_row47_lru_offset           : natural := dir_row46_lru_offset    + 3;
constant dir_row48_lru_offset           : natural := dir_row47_lru_offset    + 3;
constant dir_row49_lru_offset           : natural := dir_row48_lru_offset    + 3;
constant dir_row50_lru_offset           : natural := dir_row49_lru_offset    + 3;
constant dir_row51_lru_offset           : natural := dir_row50_lru_offset    + 3;
constant dir_row52_lru_offset           : natural := dir_row51_lru_offset    + 3;
constant dir_row53_lru_offset           : natural := dir_row52_lru_offset    + 3;
constant dir_row54_lru_offset           : natural := dir_row53_lru_offset    + 3;
constant dir_row55_lru_offset           : natural := dir_row54_lru_offset    + 3;
constant dir_row56_lru_offset           : natural := dir_row55_lru_offset    + 3;
constant dir_row57_lru_offset           : natural := dir_row56_lru_offset    + 3;
constant dir_row58_lru_offset           : natural := dir_row57_lru_offset    + 3;
constant dir_row59_lru_offset           : natural := dir_row58_lru_offset    + 3;
constant dir_row60_lru_offset           : natural := dir_row59_lru_offset    + 3;
constant dir_row61_lru_offset           : natural := dir_row60_lru_offset    + 3;
constant dir_row62_lru_offset           : natural := dir_row61_lru_offset    + 3;
constant dir_row63_lru_offset           : natural := dir_row62_lru_offset    + 3;
constant scan_right             : natural := dir_row63_lru_offset + 3 - 1;
subtype s2 is std_ulogic_vector(0 to 1);
subtype s3 is std_ulogic_vector(0 to 2);
subtype s6 is std_ulogic_vector(0 to 5);
subtype s11 is std_ulogic_vector(0 to 10);
signal ZEROS                    : std_ulogic_vector(6 to 35);
signal tidn                     : std_ulogic;
signal tiup                     : std_ulogic;
-- Latch inputs
-- IU1 pipeline
signal iu1_valid_d              : std_ulogic;
signal iu1_valid_l2             : std_ulogic;
signal iu1_tid_d                : std_ulogic_vector(0 to 3);
signal iu1_tid_l2               : std_ulogic_vector(0 to 3);
signal iu1_ifar_d               : EFF_IFAR;
signal iu1_ifar_l2              : EFF_IFAR;
signal iu1_inval_d              : std_ulogic;
signal iu1_inval_l2             : std_ulogic;
signal iu1_2ucode_d             : std_ulogic;
signal iu1_2ucode_l2            : std_ulogic;
signal iu1_2ucode_type_d        : std_ulogic;
signal iu1_2ucode_type_l2       : std_ulogic;
-- IU2 pipeline
signal iu2_valid_d              : std_ulogic;
signal iu2_valid_l2             : std_ulogic;
signal iu2_tid_d                : std_ulogic_vector(0 to 3);
signal iu2_tid_l2               : std_ulogic_vector(0 to 3);
signal iu2_ifar_eff_d           : EFF_IFAR;
signal iu2_ifar_eff_l2          : EFF_IFAR;
signal iu2_2ucode_d             : std_ulogic;
signal iu2_2ucode_l2            : std_ulogic;
signal iu2_2ucode_type_d        : std_ulogic;
signal iu2_2ucode_type_l2       : std_ulogic;
signal iu2_inval_d              : std_ulogic;
signal iu2_inval_l2             : std_ulogic;
signal iu2_dir_rd_val_d         : std_ulogic_vector(0 to 3);
signal iu2_dir_rd_val_l2        : std_ulogic_vector(0 to 3);
signal iu2_dir_dataout_0_d      : std_ulogic_vector(22 to 52);
signal iu2_dir_dataout_0_noncmp : std_ulogic_vector(22 to 52);
signal iu2_dir_dataout_1_d      : std_ulogic_vector(22 to 52);
signal iu2_dir_dataout_1_noncmp : std_ulogic_vector(22 to 52);
signal iu2_dir_dataout_2_d      : std_ulogic_vector(22 to 52);
signal iu2_dir_dataout_2_noncmp : std_ulogic_vector(22 to 52);
signal iu2_dir_dataout_3_d      : std_ulogic_vector(22 to 52);
signal iu2_dir_dataout_3_noncmp : std_ulogic_vector(22 to 52);
signal iu2_dir_dataout_0_par_d  : std_ulogic_vector(0 to dir_parity_width-1);
signal iu2_dir_dataout_0_par_l2 : std_ulogic_vector(0 to dir_parity_width-1);
signal iu2_dir_dataout_1_par_d  : std_ulogic_vector(0 to dir_parity_width-1);
signal iu2_dir_dataout_1_par_l2 : std_ulogic_vector(0 to dir_parity_width-1);
signal iu2_dir_dataout_2_par_d  : std_ulogic_vector(0 to dir_parity_width-1);
signal iu2_dir_dataout_2_par_l2 : std_ulogic_vector(0 to dir_parity_width-1);
signal iu2_dir_dataout_3_par_d  : std_ulogic_vector(0 to dir_parity_width-1);
signal iu2_dir_dataout_3_par_l2 : std_ulogic_vector(0 to dir_parity_width-1);
signal iu2_data_dataout_d       : std_ulogic_vector(0 to 162*ways-1);
signal iu2_data_dataout_l2      : std_ulogic_vector(0 to 162*ways-1);
signal xu_iu_ici_d              : std_ulogic;
signal xu_iu_ici_l2             : std_ulogic;
-- Dir val & LRU
signal dir_row0_val_d           : std_ulogic_vector(0 to 3);
signal dir_row0_val_l2          : std_ulogic_vector(0 to 3);
signal dir_row0_lru_d           : std_ulogic_vector(0 to 2);
signal dir_row0_lru_l2          : std_ulogic_vector(0 to 2);
signal dir_row1_val_d           : std_ulogic_vector(0 to 3);
signal dir_row1_val_l2          : std_ulogic_vector(0 to 3);
signal dir_row1_lru_d           : std_ulogic_vector(0 to 2);
signal dir_row1_lru_l2          : std_ulogic_vector(0 to 2);
signal dir_row2_val_d           : std_ulogic_vector(0 to 3);
signal dir_row2_val_l2          : std_ulogic_vector(0 to 3);
signal dir_row2_lru_d           : std_ulogic_vector(0 to 2);
signal dir_row2_lru_l2          : std_ulogic_vector(0 to 2);
signal dir_row3_val_d           : std_ulogic_vector(0 to 3);
signal dir_row3_val_l2          : std_ulogic_vector(0 to 3);
signal dir_row3_lru_d           : std_ulogic_vector(0 to 2);
signal dir_row3_lru_l2          : std_ulogic_vector(0 to 2);
signal dir_row4_val_d           : std_ulogic_vector(0 to 3);
signal dir_row4_val_l2          : std_ulogic_vector(0 to 3);
signal dir_row4_lru_d           : std_ulogic_vector(0 to 2);
signal dir_row4_lru_l2          : std_ulogic_vector(0 to 2);
signal dir_row5_val_d           : std_ulogic_vector(0 to 3);
signal dir_row5_val_l2          : std_ulogic_vector(0 to 3);
signal dir_row5_lru_d           : std_ulogic_vector(0 to 2);
signal dir_row5_lru_l2          : std_ulogic_vector(0 to 2);
signal dir_row6_val_d           : std_ulogic_vector(0 to 3);
signal dir_row6_val_l2          : std_ulogic_vector(0 to 3);
signal dir_row6_lru_d           : std_ulogic_vector(0 to 2);
signal dir_row6_lru_l2          : std_ulogic_vector(0 to 2);
signal dir_row7_val_d           : std_ulogic_vector(0 to 3);
signal dir_row7_val_l2          : std_ulogic_vector(0 to 3);
signal dir_row7_lru_d           : std_ulogic_vector(0 to 2);
signal dir_row7_lru_l2          : std_ulogic_vector(0 to 2);
signal dir_row8_val_d           : std_ulogic_vector(0 to 3);
signal dir_row8_val_l2          : std_ulogic_vector(0 to 3);
signal dir_row8_lru_d           : std_ulogic_vector(0 to 2);
signal dir_row8_lru_l2          : std_ulogic_vector(0 to 2);
signal dir_row9_val_d           : std_ulogic_vector(0 to 3);
signal dir_row9_val_l2          : std_ulogic_vector(0 to 3);
signal dir_row9_lru_d           : std_ulogic_vector(0 to 2);
signal dir_row9_lru_l2          : std_ulogic_vector(0 to 2);
signal dir_row10_val_d          : std_ulogic_vector(0 to 3);
signal dir_row10_val_l2         : std_ulogic_vector(0 to 3);
signal dir_row10_lru_d          : std_ulogic_vector(0 to 2);
signal dir_row10_lru_l2         : std_ulogic_vector(0 to 2);
signal dir_row11_val_d          : std_ulogic_vector(0 to 3);
signal dir_row11_val_l2         : std_ulogic_vector(0 to 3);
signal dir_row11_lru_d          : std_ulogic_vector(0 to 2);
signal dir_row11_lru_l2         : std_ulogic_vector(0 to 2);
signal dir_row12_val_d          : std_ulogic_vector(0 to 3);
signal dir_row12_val_l2         : std_ulogic_vector(0 to 3);
signal dir_row12_lru_d          : std_ulogic_vector(0 to 2);
signal dir_row12_lru_l2         : std_ulogic_vector(0 to 2);
signal dir_row13_val_d          : std_ulogic_vector(0 to 3);
signal dir_row13_val_l2         : std_ulogic_vector(0 to 3);
signal dir_row13_lru_d          : std_ulogic_vector(0 to 2);
signal dir_row13_lru_l2         : std_ulogic_vector(0 to 2);
signal dir_row14_val_d          : std_ulogic_vector(0 to 3);
signal dir_row14_val_l2         : std_ulogic_vector(0 to 3);
signal dir_row14_lru_d          : std_ulogic_vector(0 to 2);
signal dir_row14_lru_l2         : std_ulogic_vector(0 to 2);
signal dir_row15_val_d          : std_ulogic_vector(0 to 3);
signal dir_row15_val_l2         : std_ulogic_vector(0 to 3);
signal dir_row15_lru_d          : std_ulogic_vector(0 to 2);
signal dir_row15_lru_l2         : std_ulogic_vector(0 to 2);
signal dir_row16_val_d          : std_ulogic_vector(0 to 3);
signal dir_row16_val_l2         : std_ulogic_vector(0 to 3);
signal dir_row16_lru_d          : std_ulogic_vector(0 to 2);
signal dir_row16_lru_l2         : std_ulogic_vector(0 to 2);
signal dir_row17_val_d          : std_ulogic_vector(0 to 3);
signal dir_row17_val_l2         : std_ulogic_vector(0 to 3);
signal dir_row17_lru_d          : std_ulogic_vector(0 to 2);
signal dir_row17_lru_l2         : std_ulogic_vector(0 to 2);
signal dir_row18_val_d          : std_ulogic_vector(0 to 3);
signal dir_row18_val_l2         : std_ulogic_vector(0 to 3);
signal dir_row18_lru_d          : std_ulogic_vector(0 to 2);
signal dir_row18_lru_l2         : std_ulogic_vector(0 to 2);
signal dir_row19_val_d          : std_ulogic_vector(0 to 3);
signal dir_row19_val_l2         : std_ulogic_vector(0 to 3);
signal dir_row19_lru_d          : std_ulogic_vector(0 to 2);
signal dir_row19_lru_l2         : std_ulogic_vector(0 to 2);
signal dir_row20_val_d          : std_ulogic_vector(0 to 3);
signal dir_row20_val_l2         : std_ulogic_vector(0 to 3);
signal dir_row20_lru_d          : std_ulogic_vector(0 to 2);
signal dir_row20_lru_l2         : std_ulogic_vector(0 to 2);
signal dir_row21_val_d          : std_ulogic_vector(0 to 3);
signal dir_row21_val_l2         : std_ulogic_vector(0 to 3);
signal dir_row21_lru_d          : std_ulogic_vector(0 to 2);
signal dir_row21_lru_l2         : std_ulogic_vector(0 to 2);
signal dir_row22_val_d          : std_ulogic_vector(0 to 3);
signal dir_row22_val_l2         : std_ulogic_vector(0 to 3);
signal dir_row22_lru_d          : std_ulogic_vector(0 to 2);
signal dir_row22_lru_l2         : std_ulogic_vector(0 to 2);
signal dir_row23_val_d          : std_ulogic_vector(0 to 3);
signal dir_row23_val_l2         : std_ulogic_vector(0 to 3);
signal dir_row23_lru_d          : std_ulogic_vector(0 to 2);
signal dir_row23_lru_l2         : std_ulogic_vector(0 to 2);
signal dir_row24_val_d          : std_ulogic_vector(0 to 3);
signal dir_row24_val_l2         : std_ulogic_vector(0 to 3);
signal dir_row24_lru_d          : std_ulogic_vector(0 to 2);
signal dir_row24_lru_l2         : std_ulogic_vector(0 to 2);
signal dir_row25_val_d          : std_ulogic_vector(0 to 3);
signal dir_row25_val_l2         : std_ulogic_vector(0 to 3);
signal dir_row25_lru_d          : std_ulogic_vector(0 to 2);
signal dir_row25_lru_l2         : std_ulogic_vector(0 to 2);
signal dir_row26_val_d          : std_ulogic_vector(0 to 3);
signal dir_row26_val_l2         : std_ulogic_vector(0 to 3);
signal dir_row26_lru_d          : std_ulogic_vector(0 to 2);
signal dir_row26_lru_l2         : std_ulogic_vector(0 to 2);
signal dir_row27_val_d          : std_ulogic_vector(0 to 3);
signal dir_row27_val_l2         : std_ulogic_vector(0 to 3);
signal dir_row27_lru_d          : std_ulogic_vector(0 to 2);
signal dir_row27_lru_l2         : std_ulogic_vector(0 to 2);
signal dir_row28_val_d          : std_ulogic_vector(0 to 3);
signal dir_row28_val_l2         : std_ulogic_vector(0 to 3);
signal dir_row28_lru_d          : std_ulogic_vector(0 to 2);
signal dir_row28_lru_l2         : std_ulogic_vector(0 to 2);
signal dir_row29_val_d          : std_ulogic_vector(0 to 3);
signal dir_row29_val_l2         : std_ulogic_vector(0 to 3);
signal dir_row29_lru_d          : std_ulogic_vector(0 to 2);
signal dir_row29_lru_l2         : std_ulogic_vector(0 to 2);
signal dir_row30_val_d          : std_ulogic_vector(0 to 3);
signal dir_row30_val_l2         : std_ulogic_vector(0 to 3);
signal dir_row30_lru_d          : std_ulogic_vector(0 to 2);
signal dir_row30_lru_l2         : std_ulogic_vector(0 to 2);
signal dir_row31_val_d          : std_ulogic_vector(0 to 3);
signal dir_row31_val_l2         : std_ulogic_vector(0 to 3);
signal dir_row31_lru_d          : std_ulogic_vector(0 to 2);
signal dir_row31_lru_l2         : std_ulogic_vector(0 to 2);
signal dir_row32_val_d          : std_ulogic_vector(0 to 3);
signal dir_row32_val_l2         : std_ulogic_vector(0 to 3);
signal dir_row32_lru_d          : std_ulogic_vector(0 to 2);
signal dir_row32_lru_l2         : std_ulogic_vector(0 to 2);
signal dir_row33_val_d          : std_ulogic_vector(0 to 3);
signal dir_row33_val_l2         : std_ulogic_vector(0 to 3);
signal dir_row33_lru_d          : std_ulogic_vector(0 to 2);
signal dir_row33_lru_l2         : std_ulogic_vector(0 to 2);
signal dir_row34_val_d          : std_ulogic_vector(0 to 3);
signal dir_row34_val_l2         : std_ulogic_vector(0 to 3);
signal dir_row34_lru_d          : std_ulogic_vector(0 to 2);
signal dir_row34_lru_l2         : std_ulogic_vector(0 to 2);
signal dir_row35_val_d          : std_ulogic_vector(0 to 3);
signal dir_row35_val_l2         : std_ulogic_vector(0 to 3);
signal dir_row35_lru_d          : std_ulogic_vector(0 to 2);
signal dir_row35_lru_l2         : std_ulogic_vector(0 to 2);
signal dir_row36_val_d          : std_ulogic_vector(0 to 3);
signal dir_row36_val_l2         : std_ulogic_vector(0 to 3);
signal dir_row36_lru_d          : std_ulogic_vector(0 to 2);
signal dir_row36_lru_l2         : std_ulogic_vector(0 to 2);
signal dir_row37_val_d          : std_ulogic_vector(0 to 3);
signal dir_row37_val_l2         : std_ulogic_vector(0 to 3);
signal dir_row37_lru_d          : std_ulogic_vector(0 to 2);
signal dir_row37_lru_l2         : std_ulogic_vector(0 to 2);
signal dir_row38_val_d          : std_ulogic_vector(0 to 3);
signal dir_row38_val_l2         : std_ulogic_vector(0 to 3);
signal dir_row38_lru_d          : std_ulogic_vector(0 to 2);
signal dir_row38_lru_l2         : std_ulogic_vector(0 to 2);
signal dir_row39_val_d          : std_ulogic_vector(0 to 3);
signal dir_row39_val_l2         : std_ulogic_vector(0 to 3);
signal dir_row39_lru_d          : std_ulogic_vector(0 to 2);
signal dir_row39_lru_l2         : std_ulogic_vector(0 to 2);
signal dir_row40_val_d          : std_ulogic_vector(0 to 3);
signal dir_row40_val_l2         : std_ulogic_vector(0 to 3);
signal dir_row40_lru_d          : std_ulogic_vector(0 to 2);
signal dir_row40_lru_l2         : std_ulogic_vector(0 to 2);
signal dir_row41_val_d          : std_ulogic_vector(0 to 3);
signal dir_row41_val_l2         : std_ulogic_vector(0 to 3);
signal dir_row41_lru_d          : std_ulogic_vector(0 to 2);
signal dir_row41_lru_l2         : std_ulogic_vector(0 to 2);
signal dir_row42_val_d          : std_ulogic_vector(0 to 3);
signal dir_row42_val_l2         : std_ulogic_vector(0 to 3);
signal dir_row42_lru_d          : std_ulogic_vector(0 to 2);
signal dir_row42_lru_l2         : std_ulogic_vector(0 to 2);
signal dir_row43_val_d          : std_ulogic_vector(0 to 3);
signal dir_row43_val_l2         : std_ulogic_vector(0 to 3);
signal dir_row43_lru_d          : std_ulogic_vector(0 to 2);
signal dir_row43_lru_l2         : std_ulogic_vector(0 to 2);
signal dir_row44_val_d          : std_ulogic_vector(0 to 3);
signal dir_row44_val_l2         : std_ulogic_vector(0 to 3);
signal dir_row44_lru_d          : std_ulogic_vector(0 to 2);
signal dir_row44_lru_l2         : std_ulogic_vector(0 to 2);
signal dir_row45_val_d          : std_ulogic_vector(0 to 3);
signal dir_row45_val_l2         : std_ulogic_vector(0 to 3);
signal dir_row45_lru_d          : std_ulogic_vector(0 to 2);
signal dir_row45_lru_l2         : std_ulogic_vector(0 to 2);
signal dir_row46_val_d          : std_ulogic_vector(0 to 3);
signal dir_row46_val_l2         : std_ulogic_vector(0 to 3);
signal dir_row46_lru_d          : std_ulogic_vector(0 to 2);
signal dir_row46_lru_l2         : std_ulogic_vector(0 to 2);
signal dir_row47_val_d          : std_ulogic_vector(0 to 3);
signal dir_row47_val_l2         : std_ulogic_vector(0 to 3);
signal dir_row47_lru_d          : std_ulogic_vector(0 to 2);
signal dir_row47_lru_l2         : std_ulogic_vector(0 to 2);
signal dir_row48_val_d          : std_ulogic_vector(0 to 3);
signal dir_row48_val_l2         : std_ulogic_vector(0 to 3);
signal dir_row48_lru_d          : std_ulogic_vector(0 to 2);
signal dir_row48_lru_l2         : std_ulogic_vector(0 to 2);
signal dir_row49_val_d          : std_ulogic_vector(0 to 3);
signal dir_row49_val_l2         : std_ulogic_vector(0 to 3);
signal dir_row49_lru_d          : std_ulogic_vector(0 to 2);
signal dir_row49_lru_l2         : std_ulogic_vector(0 to 2);
signal dir_row50_val_d          : std_ulogic_vector(0 to 3);
signal dir_row50_val_l2         : std_ulogic_vector(0 to 3);
signal dir_row50_lru_d          : std_ulogic_vector(0 to 2);
signal dir_row50_lru_l2         : std_ulogic_vector(0 to 2);
signal dir_row51_val_d          : std_ulogic_vector(0 to 3);
signal dir_row51_val_l2         : std_ulogic_vector(0 to 3);
signal dir_row51_lru_d          : std_ulogic_vector(0 to 2);
signal dir_row51_lru_l2         : std_ulogic_vector(0 to 2);
signal dir_row52_val_d          : std_ulogic_vector(0 to 3);
signal dir_row52_val_l2         : std_ulogic_vector(0 to 3);
signal dir_row52_lru_d          : std_ulogic_vector(0 to 2);
signal dir_row52_lru_l2         : std_ulogic_vector(0 to 2);
signal dir_row53_val_d          : std_ulogic_vector(0 to 3);
signal dir_row53_val_l2         : std_ulogic_vector(0 to 3);
signal dir_row53_lru_d          : std_ulogic_vector(0 to 2);
signal dir_row53_lru_l2         : std_ulogic_vector(0 to 2);
signal dir_row54_val_d          : std_ulogic_vector(0 to 3);
signal dir_row54_val_l2         : std_ulogic_vector(0 to 3);
signal dir_row54_lru_d          : std_ulogic_vector(0 to 2);
signal dir_row54_lru_l2         : std_ulogic_vector(0 to 2);
signal dir_row55_val_d          : std_ulogic_vector(0 to 3);
signal dir_row55_val_l2         : std_ulogic_vector(0 to 3);
signal dir_row55_lru_d          : std_ulogic_vector(0 to 2);
signal dir_row55_lru_l2         : std_ulogic_vector(0 to 2);
signal dir_row56_val_d          : std_ulogic_vector(0 to 3);
signal dir_row56_val_l2         : std_ulogic_vector(0 to 3);
signal dir_row56_lru_d          : std_ulogic_vector(0 to 2);
signal dir_row56_lru_l2         : std_ulogic_vector(0 to 2);
signal dir_row57_val_d          : std_ulogic_vector(0 to 3);
signal dir_row57_val_l2         : std_ulogic_vector(0 to 3);
signal dir_row57_lru_d          : std_ulogic_vector(0 to 2);
signal dir_row57_lru_l2         : std_ulogic_vector(0 to 2);
signal dir_row58_val_d          : std_ulogic_vector(0 to 3);
signal dir_row58_val_l2         : std_ulogic_vector(0 to 3);
signal dir_row58_lru_d          : std_ulogic_vector(0 to 2);
signal dir_row58_lru_l2         : std_ulogic_vector(0 to 2);
signal dir_row59_val_d          : std_ulogic_vector(0 to 3);
signal dir_row59_val_l2         : std_ulogic_vector(0 to 3);
signal dir_row59_lru_d          : std_ulogic_vector(0 to 2);
signal dir_row59_lru_l2         : std_ulogic_vector(0 to 2);
signal dir_row60_val_d          : std_ulogic_vector(0 to 3);
signal dir_row60_val_l2         : std_ulogic_vector(0 to 3);
signal dir_row60_lru_d          : std_ulogic_vector(0 to 2);
signal dir_row60_lru_l2         : std_ulogic_vector(0 to 2);
signal dir_row61_val_d          : std_ulogic_vector(0 to 3);
signal dir_row61_val_l2         : std_ulogic_vector(0 to 3);
signal dir_row61_lru_d          : std_ulogic_vector(0 to 2);
signal dir_row61_lru_l2         : std_ulogic_vector(0 to 2);
signal dir_row62_val_d          : std_ulogic_vector(0 to 3);
signal dir_row62_val_l2         : std_ulogic_vector(0 to 3);
signal dir_row62_lru_d          : std_ulogic_vector(0 to 2);
signal dir_row62_lru_l2         : std_ulogic_vector(0 to 2);
signal dir_row63_val_d          : std_ulogic_vector(0 to 3);
signal dir_row63_val_l2         : std_ulogic_vector(0 to 3);
signal dir_row63_lru_d          : std_ulogic_vector(0 to 2);
signal dir_row63_lru_l2         : std_ulogic_vector(0 to 2);
-- IU3 pipeline
signal iu3_instr_valid_d        : std_ulogic_vector(0 to 3);
signal iu3_instr_valid_l2       : std_ulogic_vector(0 to 3);
signal iu3_tid_d                : std_ulogic_vector(0 to 3);
signal iu3_tid_l2               : std_ulogic_vector(0 to 3);
signal iu3_ifar_d               : EFF_IFAR;
signal iu3_ifar_l2              : EFF_IFAR;
signal iu3_ifar_dec_d           : std_ulogic_vector(0 to 3);
signal iu3_ifar_dec_l2          : std_ulogic_vector(0 to 3);
signal iu3_2ucode_d             : std_ulogic;
signal iu3_2ucode_l2            : std_ulogic;
signal iu3_2ucode_type_d        : std_ulogic;
signal iu3_2ucode_type_l2       : std_ulogic;
signal iu3_erat_err_d           : std_ulogic_vector(0 to 2);
signal iu3_erat_err_l2          : std_ulogic_vector(0 to 2);
signal iu3_dir_parity_err_way_d  : std_ulogic_vector(0 to 3);
signal iu3_dir_parity_err_way_l2 : std_ulogic_vector(0 to 3);
signal iu3_data_parity_err_way_d : std_ulogic_vector(0 to 3);
signal iu3_data_parity_err_way_l2: std_ulogic_vector(0 to 3);
signal iu3_parity_tag_d         : std_ulogic_vector(52 to 57);
signal iu3_parity_tag_l2        : std_ulogic_vector(52 to 57);
signal iu3_parity_needs_flush_d         : std_ulogic_vector(0 to 3);
signal iu3_parity_needs_flush_l2        : std_ulogic_vector(0 to 3);
signal iu3_parity_needs_flush           : std_ulogic;
signal iu3_parity_flush_tid             : std_ulogic_vector(0 to 3);
signal iu3_parity_flush                 : std_ulogic;
signal iu3_rd_parity_err_d              : std_ulogic;
signal iu3_rd_parity_err_l2             : std_ulogic;
signal iu3_rd_miss_d                    : std_ulogic;
signal iu3_rd_miss_l2                   : std_ulogic;
signal err_icache_parity_d              : std_ulogic;
signal err_icache_parity_l2             : std_ulogic;
signal err_icachedir_parity_d           : std_ulogic;
signal err_icachedir_parity_l2          : std_ulogic;
signal iu3_multihit_err_way_d           : std_ulogic_vector(0 to 3);
signal iu3_multihit_err_way_l2          : std_ulogic_vector(0 to 3);
signal iu3_multihit_flush_d             : std_ulogic;
signal iu3_multihit_flush_l2            : std_ulogic;
signal perf_instr_count_t0_d            : std_ulogic_vector(0 to 1);
signal perf_instr_count_t0_l2           : std_ulogic_vector(0 to 1);
signal perf_instr_count_t1_d            : std_ulogic_vector(0 to 1);
signal perf_instr_count_t1_l2           : std_ulogic_vector(0 to 1);
signal perf_instr_count_t2_d            : std_ulogic_vector(0 to 1);
signal perf_instr_count_t2_l2           : std_ulogic_vector(0 to 1);
signal perf_instr_count_t3_d            : std_ulogic_vector(0 to 1);
signal perf_instr_count_t3_l2           : std_ulogic_vector(0 to 1);
signal perf_event_t0_d                  : std_ulogic_vector(4 to 6);
signal perf_event_t0_l2                 : std_ulogic_vector(4 to 6);
signal perf_event_t1_d                  : std_ulogic_vector(4 to 6);
signal perf_event_t1_l2                 : std_ulogic_vector(4 to 6);
signal perf_event_t2_d                  : std_ulogic_vector(4 to 6);
signal perf_event_t2_l2                 : std_ulogic_vector(4 to 6);
signal perf_event_t3_d                  : std_ulogic_vector(4 to 6);
signal perf_event_t3_l2                 : std_ulogic_vector(4 to 6);
signal perf_event_d                     : std_ulogic_vector(0 to 1);
signal perf_event_l2                    : std_ulogic_vector(0 to 1);
signal spr_ic_cls_d                     : std_ulogic;
signal spr_ic_cls_l2                    : std_ulogic;
signal spr_ic_idir_way_d                : std_ulogic_vector(0 to 1);
signal spr_ic_idir_way_l2               : std_ulogic_vector(0 to 1);
signal iu1_spr_idir_read_d              : std_ulogic;
signal iu1_spr_idir_read_l2             : std_ulogic;
signal iu2_spr_idir_read_d              : std_ulogic;
signal iu2_spr_idir_read_l2             : std_ulogic;
signal iu2_spr_idir_lru_d               : std_ulogic_vector(0 to 2);
signal iu2_spr_idir_lru_l2              : std_ulogic_vector(0 to 2);
signal dbg_dir_write_d                  : std_ulogic;
signal dbg_dir_write_l2                 : std_ulogic;
signal dbg_dir_rd_act_d                 : std_ulogic;
signal dbg_dir_rd_act_l2                : std_ulogic;
signal dbg_iu2_lru_rd_update_d          : std_ulogic;
signal dbg_iu2_lru_rd_update_l2         : std_ulogic;
signal dbg_iu2_rd_way_tag_hit_d         : std_ulogic_vector(0 to 3);
signal dbg_iu2_rd_way_tag_hit_l2        : std_ulogic_vector(0 to 3);
signal dbg_iu2_rd_way_hit_d             : std_ulogic_vector(0 to 3);
signal dbg_iu2_rd_way_hit_l2            : std_ulogic_vector(0 to 3);
signal dbg_load_iu2_d                   : std_ulogic;
signal dbg_load_iu2_l2                  : std_ulogic;
signal spare_slp_l2                     : std_ulogic_vector(0 to 15);
signal spare_l2                         : std_ulogic_vector(0 to 15);
-- IFAR
signal iu2_ci                   : std_ulogic;
signal iu2_endian               : std_ulogic;
-- IDIR
signal dir_rd_act               : std_ulogic;
signal dir_write                : std_ulogic;
signal dir_way                  : std_ulogic_vector(0 to ways-1);
signal dir_wr_addr              : std_ulogic_vector(0 to 5);
signal dir_rd_addr              : std_ulogic_vector(0 to 5);
signal ext_dir_datain           : std_ulogic_vector(0 to dir_parity_width*8-1);
signal dir_parity_in            : std_ulogic_vector(0 to dir_parity_width-1);
signal way_datain               : std_ulogic_vector(0 to dir_array_way_width-1);
signal way_datain_rev           : std_ulogic_vector(0 to dir_array_way_width-1);
signal dir_datain_rev           : std_ulogic_vector(0 to dir_array_way_width*ways-1);
signal dir_dataout_rev          : std_ulogic_vector(0 to dir_array_way_width*ways-1);
signal dir_dataout              : std_ulogic_vector(0 to dir_array_way_width*ways-1);
signal dir_dataout_act          : std_ulogic;
signal iu1_ifar_cacheline       : std_ulogic_vector(0 to 5);
signal dir_rd_val               : std_ulogic_vector(0 to 3);
-- IDATA
signal data_write               : std_ulogic;
signal data_way                 : std_ulogic_vector(0 to ways-1);
signal data_addr                : std_ulogic_vector(0 to 7);
signal data_parity_in           : std_ulogic_vector(0 to 17);
signal data_datain              : std_ulogic_vector(0 to 161);
signal data_dataout             : std_ulogic_vector(0 to 162*ways-1);
signal data_dataout_inj         : std_ulogic_vector(0 to 162*ways-1);
-- Compare
signal ierat_iu_iu2_rpn_noncmp  : std_ulogic_vector(22 to 51);
signal iu2_rd_way_tag_hit       : std_ulogic_vector(0 to 3);
signal iu2_rd_way_hit           : std_ulogic_vector(0 to 3);
signal iu2_rd_way_hit_insmux_b  : std_ulogic_vector(0 to 3);
signal iu2_dir_miss             : std_ulogic;
signal iu2_valid                : std_ulogic;
signal dir_row_lru_even_act     : std_ulogic;
signal dir_row_lru_odd_act      : std_ulogic;
signal iu2_erat_err_lite        : std_ulogic;
signal iu2_lru_rd_update        : std_ulogic;
signal dir_row0_lru_read        : std_ulogic_vector(0 to 2);
signal dir_row0_lru_write       : std_ulogic_vector(0 to 2);
signal dir_row1_lru_read        : std_ulogic_vector(0 to 2);
signal dir_row1_lru_write       : std_ulogic_vector(0 to 2);
signal dir_row2_lru_read        : std_ulogic_vector(0 to 2);
signal dir_row2_lru_write       : std_ulogic_vector(0 to 2);
signal dir_row3_lru_read        : std_ulogic_vector(0 to 2);
signal dir_row3_lru_write       : std_ulogic_vector(0 to 2);
signal dir_row4_lru_read        : std_ulogic_vector(0 to 2);
signal dir_row4_lru_write       : std_ulogic_vector(0 to 2);
signal dir_row5_lru_read        : std_ulogic_vector(0 to 2);
signal dir_row5_lru_write       : std_ulogic_vector(0 to 2);
signal dir_row6_lru_read        : std_ulogic_vector(0 to 2);
signal dir_row6_lru_write       : std_ulogic_vector(0 to 2);
signal dir_row7_lru_read        : std_ulogic_vector(0 to 2);
signal dir_row7_lru_write       : std_ulogic_vector(0 to 2);
signal dir_row8_lru_read        : std_ulogic_vector(0 to 2);
signal dir_row8_lru_write       : std_ulogic_vector(0 to 2);
signal dir_row9_lru_read        : std_ulogic_vector(0 to 2);
signal dir_row9_lru_write       : std_ulogic_vector(0 to 2);
signal dir_row10_lru_read       : std_ulogic_vector(0 to 2);
signal dir_row10_lru_write      : std_ulogic_vector(0 to 2);
signal dir_row11_lru_read       : std_ulogic_vector(0 to 2);
signal dir_row11_lru_write      : std_ulogic_vector(0 to 2);
signal dir_row12_lru_read       : std_ulogic_vector(0 to 2);
signal dir_row12_lru_write      : std_ulogic_vector(0 to 2);
signal dir_row13_lru_read       : std_ulogic_vector(0 to 2);
signal dir_row13_lru_write      : std_ulogic_vector(0 to 2);
signal dir_row14_lru_read       : std_ulogic_vector(0 to 2);
signal dir_row14_lru_write      : std_ulogic_vector(0 to 2);
signal dir_row15_lru_read       : std_ulogic_vector(0 to 2);
signal dir_row15_lru_write      : std_ulogic_vector(0 to 2);
signal dir_row16_lru_read       : std_ulogic_vector(0 to 2);
signal dir_row16_lru_write      : std_ulogic_vector(0 to 2);
signal dir_row17_lru_read       : std_ulogic_vector(0 to 2);
signal dir_row17_lru_write      : std_ulogic_vector(0 to 2);
signal dir_row18_lru_read       : std_ulogic_vector(0 to 2);
signal dir_row18_lru_write      : std_ulogic_vector(0 to 2);
signal dir_row19_lru_read       : std_ulogic_vector(0 to 2);
signal dir_row19_lru_write      : std_ulogic_vector(0 to 2);
signal dir_row20_lru_read       : std_ulogic_vector(0 to 2);
signal dir_row20_lru_write      : std_ulogic_vector(0 to 2);
signal dir_row21_lru_read       : std_ulogic_vector(0 to 2);
signal dir_row21_lru_write      : std_ulogic_vector(0 to 2);
signal dir_row22_lru_read       : std_ulogic_vector(0 to 2);
signal dir_row22_lru_write      : std_ulogic_vector(0 to 2);
signal dir_row23_lru_read       : std_ulogic_vector(0 to 2);
signal dir_row23_lru_write      : std_ulogic_vector(0 to 2);
signal dir_row24_lru_read       : std_ulogic_vector(0 to 2);
signal dir_row24_lru_write      : std_ulogic_vector(0 to 2);
signal dir_row25_lru_read       : std_ulogic_vector(0 to 2);
signal dir_row25_lru_write      : std_ulogic_vector(0 to 2);
signal dir_row26_lru_read       : std_ulogic_vector(0 to 2);
signal dir_row26_lru_write      : std_ulogic_vector(0 to 2);
signal dir_row27_lru_read       : std_ulogic_vector(0 to 2);
signal dir_row27_lru_write      : std_ulogic_vector(0 to 2);
signal dir_row28_lru_read       : std_ulogic_vector(0 to 2);
signal dir_row28_lru_write      : std_ulogic_vector(0 to 2);
signal dir_row29_lru_read       : std_ulogic_vector(0 to 2);
signal dir_row29_lru_write      : std_ulogic_vector(0 to 2);
signal dir_row30_lru_read       : std_ulogic_vector(0 to 2);
signal dir_row30_lru_write      : std_ulogic_vector(0 to 2);
signal dir_row31_lru_read       : std_ulogic_vector(0 to 2);
signal dir_row31_lru_write      : std_ulogic_vector(0 to 2);
signal dir_row32_lru_read       : std_ulogic_vector(0 to 2);
signal dir_row32_lru_write      : std_ulogic_vector(0 to 2);
signal dir_row33_lru_read       : std_ulogic_vector(0 to 2);
signal dir_row33_lru_write      : std_ulogic_vector(0 to 2);
signal dir_row34_lru_read       : std_ulogic_vector(0 to 2);
signal dir_row34_lru_write      : std_ulogic_vector(0 to 2);
signal dir_row35_lru_read       : std_ulogic_vector(0 to 2);
signal dir_row35_lru_write      : std_ulogic_vector(0 to 2);
signal dir_row36_lru_read       : std_ulogic_vector(0 to 2);
signal dir_row36_lru_write      : std_ulogic_vector(0 to 2);
signal dir_row37_lru_read       : std_ulogic_vector(0 to 2);
signal dir_row37_lru_write      : std_ulogic_vector(0 to 2);
signal dir_row38_lru_read       : std_ulogic_vector(0 to 2);
signal dir_row38_lru_write      : std_ulogic_vector(0 to 2);
signal dir_row39_lru_read       : std_ulogic_vector(0 to 2);
signal dir_row39_lru_write      : std_ulogic_vector(0 to 2);
signal dir_row40_lru_read       : std_ulogic_vector(0 to 2);
signal dir_row40_lru_write      : std_ulogic_vector(0 to 2);
signal dir_row41_lru_read       : std_ulogic_vector(0 to 2);
signal dir_row41_lru_write      : std_ulogic_vector(0 to 2);
signal dir_row42_lru_read       : std_ulogic_vector(0 to 2);
signal dir_row42_lru_write      : std_ulogic_vector(0 to 2);
signal dir_row43_lru_read       : std_ulogic_vector(0 to 2);
signal dir_row43_lru_write      : std_ulogic_vector(0 to 2);
signal dir_row44_lru_read       : std_ulogic_vector(0 to 2);
signal dir_row44_lru_write      : std_ulogic_vector(0 to 2);
signal dir_row45_lru_read       : std_ulogic_vector(0 to 2);
signal dir_row45_lru_write      : std_ulogic_vector(0 to 2);
signal dir_row46_lru_read       : std_ulogic_vector(0 to 2);
signal dir_row46_lru_write      : std_ulogic_vector(0 to 2);
signal dir_row47_lru_read       : std_ulogic_vector(0 to 2);
signal dir_row47_lru_write      : std_ulogic_vector(0 to 2);
signal dir_row48_lru_read       : std_ulogic_vector(0 to 2);
signal dir_row48_lru_write      : std_ulogic_vector(0 to 2);
signal dir_row49_lru_read       : std_ulogic_vector(0 to 2);
signal dir_row49_lru_write      : std_ulogic_vector(0 to 2);
signal dir_row50_lru_read       : std_ulogic_vector(0 to 2);
signal dir_row50_lru_write      : std_ulogic_vector(0 to 2);
signal dir_row51_lru_read       : std_ulogic_vector(0 to 2);
signal dir_row51_lru_write      : std_ulogic_vector(0 to 2);
signal dir_row52_lru_read       : std_ulogic_vector(0 to 2);
signal dir_row52_lru_write      : std_ulogic_vector(0 to 2);
signal dir_row53_lru_read       : std_ulogic_vector(0 to 2);
signal dir_row53_lru_write      : std_ulogic_vector(0 to 2);
signal dir_row54_lru_read       : std_ulogic_vector(0 to 2);
signal dir_row54_lru_write      : std_ulogic_vector(0 to 2);
signal dir_row55_lru_read       : std_ulogic_vector(0 to 2);
signal dir_row55_lru_write      : std_ulogic_vector(0 to 2);
signal dir_row56_lru_read       : std_ulogic_vector(0 to 2);
signal dir_row56_lru_write      : std_ulogic_vector(0 to 2);
signal dir_row57_lru_read       : std_ulogic_vector(0 to 2);
signal dir_row57_lru_write      : std_ulogic_vector(0 to 2);
signal dir_row58_lru_read       : std_ulogic_vector(0 to 2);
signal dir_row58_lru_write      : std_ulogic_vector(0 to 2);
signal dir_row59_lru_read       : std_ulogic_vector(0 to 2);
signal dir_row59_lru_write      : std_ulogic_vector(0 to 2);
signal dir_row60_lru_read       : std_ulogic_vector(0 to 2);
signal dir_row60_lru_write      : std_ulogic_vector(0 to 2);
signal dir_row61_lru_read       : std_ulogic_vector(0 to 2);
signal dir_row61_lru_write      : std_ulogic_vector(0 to 2);
signal dir_row62_lru_read       : std_ulogic_vector(0 to 2);
signal dir_row62_lru_write      : std_ulogic_vector(0 to 2);
signal dir_row63_lru_read       : std_ulogic_vector(0 to 2);
signal dir_row63_lru_write      : std_ulogic_vector(0 to 2);
signal iu2_ifar_eff_cacheline   : std_ulogic_vector(0 to 5);
signal iu3_parity_tag_cacheline : std_ulogic_vector(0 to 5);
signal reload_cacheline         : std_ulogic_vector(0 to 5);
signal ecc_inval_cacheline      : std_ulogic_vector(0 to 5);
signal lru_write_cacheline      : std_ulogic_vector(0 to 5);
signal iu3_any_parity_err_way   : std_ulogic_vector(0 to 3);
signal dir_row0_val_d_part1     : std_ulogic_vector(0 to 3);
signal dir_row0_val_d_part2a    : std_ulogic_vector(0 to 3);
signal dir_row0_val_d_part2_b   : std_ulogic_vector(0 to 3);
signal dir_row1_val_d_part1     : std_ulogic_vector(0 to 3);
signal dir_row1_val_d_part2a    : std_ulogic_vector(0 to 3);
signal dir_row1_val_d_part2_b   : std_ulogic_vector(0 to 3);
signal dir_row2_val_d_part1     : std_ulogic_vector(0 to 3);
signal dir_row2_val_d_part2a    : std_ulogic_vector(0 to 3);
signal dir_row2_val_d_part2_b   : std_ulogic_vector(0 to 3);
signal dir_row3_val_d_part1     : std_ulogic_vector(0 to 3);
signal dir_row3_val_d_part2a    : std_ulogic_vector(0 to 3);
signal dir_row3_val_d_part2_b   : std_ulogic_vector(0 to 3);
signal dir_row4_val_d_part1     : std_ulogic_vector(0 to 3);
signal dir_row4_val_d_part2a    : std_ulogic_vector(0 to 3);
signal dir_row4_val_d_part2_b   : std_ulogic_vector(0 to 3);
signal dir_row5_val_d_part1     : std_ulogic_vector(0 to 3);
signal dir_row5_val_d_part2a    : std_ulogic_vector(0 to 3);
signal dir_row5_val_d_part2_b   : std_ulogic_vector(0 to 3);
signal dir_row6_val_d_part1     : std_ulogic_vector(0 to 3);
signal dir_row6_val_d_part2a    : std_ulogic_vector(0 to 3);
signal dir_row6_val_d_part2_b   : std_ulogic_vector(0 to 3);
signal dir_row7_val_d_part1     : std_ulogic_vector(0 to 3);
signal dir_row7_val_d_part2a    : std_ulogic_vector(0 to 3);
signal dir_row7_val_d_part2_b   : std_ulogic_vector(0 to 3);
signal dir_row8_val_d_part1     : std_ulogic_vector(0 to 3);
signal dir_row8_val_d_part2a    : std_ulogic_vector(0 to 3);
signal dir_row8_val_d_part2_b   : std_ulogic_vector(0 to 3);
signal dir_row9_val_d_part1     : std_ulogic_vector(0 to 3);
signal dir_row9_val_d_part2a    : std_ulogic_vector(0 to 3);
signal dir_row9_val_d_part2_b   : std_ulogic_vector(0 to 3);
signal dir_row10_val_d_part1    : std_ulogic_vector(0 to 3);
signal dir_row10_val_d_part2a   : std_ulogic_vector(0 to 3);
signal dir_row10_val_d_part2_b  : std_ulogic_vector(0 to 3);
signal dir_row11_val_d_part1    : std_ulogic_vector(0 to 3);
signal dir_row11_val_d_part2a   : std_ulogic_vector(0 to 3);
signal dir_row11_val_d_part2_b  : std_ulogic_vector(0 to 3);
signal dir_row12_val_d_part1    : std_ulogic_vector(0 to 3);
signal dir_row12_val_d_part2a   : std_ulogic_vector(0 to 3);
signal dir_row12_val_d_part2_b  : std_ulogic_vector(0 to 3);
signal dir_row13_val_d_part1    : std_ulogic_vector(0 to 3);
signal dir_row13_val_d_part2a   : std_ulogic_vector(0 to 3);
signal dir_row13_val_d_part2_b  : std_ulogic_vector(0 to 3);
signal dir_row14_val_d_part1    : std_ulogic_vector(0 to 3);
signal dir_row14_val_d_part2a   : std_ulogic_vector(0 to 3);
signal dir_row14_val_d_part2_b  : std_ulogic_vector(0 to 3);
signal dir_row15_val_d_part1    : std_ulogic_vector(0 to 3);
signal dir_row15_val_d_part2a   : std_ulogic_vector(0 to 3);
signal dir_row15_val_d_part2_b  : std_ulogic_vector(0 to 3);
signal dir_row16_val_d_part1    : std_ulogic_vector(0 to 3);
signal dir_row16_val_d_part2a   : std_ulogic_vector(0 to 3);
signal dir_row16_val_d_part2_b  : std_ulogic_vector(0 to 3);
signal dir_row17_val_d_part1    : std_ulogic_vector(0 to 3);
signal dir_row17_val_d_part2a   : std_ulogic_vector(0 to 3);
signal dir_row17_val_d_part2_b  : std_ulogic_vector(0 to 3);
signal dir_row18_val_d_part1    : std_ulogic_vector(0 to 3);
signal dir_row18_val_d_part2a   : std_ulogic_vector(0 to 3);
signal dir_row18_val_d_part2_b  : std_ulogic_vector(0 to 3);
signal dir_row19_val_d_part1    : std_ulogic_vector(0 to 3);
signal dir_row19_val_d_part2a   : std_ulogic_vector(0 to 3);
signal dir_row19_val_d_part2_b  : std_ulogic_vector(0 to 3);
signal dir_row20_val_d_part1    : std_ulogic_vector(0 to 3);
signal dir_row20_val_d_part2a   : std_ulogic_vector(0 to 3);
signal dir_row20_val_d_part2_b  : std_ulogic_vector(0 to 3);
signal dir_row21_val_d_part1    : std_ulogic_vector(0 to 3);
signal dir_row21_val_d_part2a   : std_ulogic_vector(0 to 3);
signal dir_row21_val_d_part2_b  : std_ulogic_vector(0 to 3);
signal dir_row22_val_d_part1    : std_ulogic_vector(0 to 3);
signal dir_row22_val_d_part2a   : std_ulogic_vector(0 to 3);
signal dir_row22_val_d_part2_b  : std_ulogic_vector(0 to 3);
signal dir_row23_val_d_part1    : std_ulogic_vector(0 to 3);
signal dir_row23_val_d_part2a   : std_ulogic_vector(0 to 3);
signal dir_row23_val_d_part2_b  : std_ulogic_vector(0 to 3);
signal dir_row24_val_d_part1    : std_ulogic_vector(0 to 3);
signal dir_row24_val_d_part2a   : std_ulogic_vector(0 to 3);
signal dir_row24_val_d_part2_b  : std_ulogic_vector(0 to 3);
signal dir_row25_val_d_part1    : std_ulogic_vector(0 to 3);
signal dir_row25_val_d_part2a   : std_ulogic_vector(0 to 3);
signal dir_row25_val_d_part2_b  : std_ulogic_vector(0 to 3);
signal dir_row26_val_d_part1    : std_ulogic_vector(0 to 3);
signal dir_row26_val_d_part2a   : std_ulogic_vector(0 to 3);
signal dir_row26_val_d_part2_b  : std_ulogic_vector(0 to 3);
signal dir_row27_val_d_part1    : std_ulogic_vector(0 to 3);
signal dir_row27_val_d_part2a   : std_ulogic_vector(0 to 3);
signal dir_row27_val_d_part2_b  : std_ulogic_vector(0 to 3);
signal dir_row28_val_d_part1    : std_ulogic_vector(0 to 3);
signal dir_row28_val_d_part2a   : std_ulogic_vector(0 to 3);
signal dir_row28_val_d_part2_b  : std_ulogic_vector(0 to 3);
signal dir_row29_val_d_part1    : std_ulogic_vector(0 to 3);
signal dir_row29_val_d_part2a   : std_ulogic_vector(0 to 3);
signal dir_row29_val_d_part2_b  : std_ulogic_vector(0 to 3);
signal dir_row30_val_d_part1    : std_ulogic_vector(0 to 3);
signal dir_row30_val_d_part2a   : std_ulogic_vector(0 to 3);
signal dir_row30_val_d_part2_b  : std_ulogic_vector(0 to 3);
signal dir_row31_val_d_part1    : std_ulogic_vector(0 to 3);
signal dir_row31_val_d_part2a   : std_ulogic_vector(0 to 3);
signal dir_row31_val_d_part2_b  : std_ulogic_vector(0 to 3);
signal dir_row32_val_d_part1    : std_ulogic_vector(0 to 3);
signal dir_row32_val_d_part2a   : std_ulogic_vector(0 to 3);
signal dir_row32_val_d_part2_b  : std_ulogic_vector(0 to 3);
signal dir_row33_val_d_part1    : std_ulogic_vector(0 to 3);
signal dir_row33_val_d_part2a   : std_ulogic_vector(0 to 3);
signal dir_row33_val_d_part2_b  : std_ulogic_vector(0 to 3);
signal dir_row34_val_d_part1    : std_ulogic_vector(0 to 3);
signal dir_row34_val_d_part2a   : std_ulogic_vector(0 to 3);
signal dir_row34_val_d_part2_b  : std_ulogic_vector(0 to 3);
signal dir_row35_val_d_part1    : std_ulogic_vector(0 to 3);
signal dir_row35_val_d_part2a   : std_ulogic_vector(0 to 3);
signal dir_row35_val_d_part2_b  : std_ulogic_vector(0 to 3);
signal dir_row36_val_d_part1    : std_ulogic_vector(0 to 3);
signal dir_row36_val_d_part2a   : std_ulogic_vector(0 to 3);
signal dir_row36_val_d_part2_b  : std_ulogic_vector(0 to 3);
signal dir_row37_val_d_part1    : std_ulogic_vector(0 to 3);
signal dir_row37_val_d_part2a   : std_ulogic_vector(0 to 3);
signal dir_row37_val_d_part2_b  : std_ulogic_vector(0 to 3);
signal dir_row38_val_d_part1    : std_ulogic_vector(0 to 3);
signal dir_row38_val_d_part2a   : std_ulogic_vector(0 to 3);
signal dir_row38_val_d_part2_b  : std_ulogic_vector(0 to 3);
signal dir_row39_val_d_part1    : std_ulogic_vector(0 to 3);
signal dir_row39_val_d_part2a   : std_ulogic_vector(0 to 3);
signal dir_row39_val_d_part2_b  : std_ulogic_vector(0 to 3);
signal dir_row40_val_d_part1    : std_ulogic_vector(0 to 3);
signal dir_row40_val_d_part2a   : std_ulogic_vector(0 to 3);
signal dir_row40_val_d_part2_b  : std_ulogic_vector(0 to 3);
signal dir_row41_val_d_part1    : std_ulogic_vector(0 to 3);
signal dir_row41_val_d_part2a   : std_ulogic_vector(0 to 3);
signal dir_row41_val_d_part2_b  : std_ulogic_vector(0 to 3);
signal dir_row42_val_d_part1    : std_ulogic_vector(0 to 3);
signal dir_row42_val_d_part2a   : std_ulogic_vector(0 to 3);
signal dir_row42_val_d_part2_b  : std_ulogic_vector(0 to 3);
signal dir_row43_val_d_part1    : std_ulogic_vector(0 to 3);
signal dir_row43_val_d_part2a   : std_ulogic_vector(0 to 3);
signal dir_row43_val_d_part2_b  : std_ulogic_vector(0 to 3);
signal dir_row44_val_d_part1    : std_ulogic_vector(0 to 3);
signal dir_row44_val_d_part2a   : std_ulogic_vector(0 to 3);
signal dir_row44_val_d_part2_b  : std_ulogic_vector(0 to 3);
signal dir_row45_val_d_part1    : std_ulogic_vector(0 to 3);
signal dir_row45_val_d_part2a   : std_ulogic_vector(0 to 3);
signal dir_row45_val_d_part2_b  : std_ulogic_vector(0 to 3);
signal dir_row46_val_d_part1    : std_ulogic_vector(0 to 3);
signal dir_row46_val_d_part2a   : std_ulogic_vector(0 to 3);
signal dir_row46_val_d_part2_b  : std_ulogic_vector(0 to 3);
signal dir_row47_val_d_part1    : std_ulogic_vector(0 to 3);
signal dir_row47_val_d_part2a   : std_ulogic_vector(0 to 3);
signal dir_row47_val_d_part2_b  : std_ulogic_vector(0 to 3);
signal dir_row48_val_d_part1    : std_ulogic_vector(0 to 3);
signal dir_row48_val_d_part2a   : std_ulogic_vector(0 to 3);
signal dir_row48_val_d_part2_b  : std_ulogic_vector(0 to 3);
signal dir_row49_val_d_part1    : std_ulogic_vector(0 to 3);
signal dir_row49_val_d_part2a   : std_ulogic_vector(0 to 3);
signal dir_row49_val_d_part2_b  : std_ulogic_vector(0 to 3);
signal dir_row50_val_d_part1    : std_ulogic_vector(0 to 3);
signal dir_row50_val_d_part2a   : std_ulogic_vector(0 to 3);
signal dir_row50_val_d_part2_b  : std_ulogic_vector(0 to 3);
signal dir_row51_val_d_part1    : std_ulogic_vector(0 to 3);
signal dir_row51_val_d_part2a   : std_ulogic_vector(0 to 3);
signal dir_row51_val_d_part2_b  : std_ulogic_vector(0 to 3);
signal dir_row52_val_d_part1    : std_ulogic_vector(0 to 3);
signal dir_row52_val_d_part2a   : std_ulogic_vector(0 to 3);
signal dir_row52_val_d_part2_b  : std_ulogic_vector(0 to 3);
signal dir_row53_val_d_part1    : std_ulogic_vector(0 to 3);
signal dir_row53_val_d_part2a   : std_ulogic_vector(0 to 3);
signal dir_row53_val_d_part2_b  : std_ulogic_vector(0 to 3);
signal dir_row54_val_d_part1    : std_ulogic_vector(0 to 3);
signal dir_row54_val_d_part2a   : std_ulogic_vector(0 to 3);
signal dir_row54_val_d_part2_b  : std_ulogic_vector(0 to 3);
signal dir_row55_val_d_part1    : std_ulogic_vector(0 to 3);
signal dir_row55_val_d_part2a   : std_ulogic_vector(0 to 3);
signal dir_row55_val_d_part2_b  : std_ulogic_vector(0 to 3);
signal dir_row56_val_d_part1    : std_ulogic_vector(0 to 3);
signal dir_row56_val_d_part2a   : std_ulogic_vector(0 to 3);
signal dir_row56_val_d_part2_b  : std_ulogic_vector(0 to 3);
signal dir_row57_val_d_part1    : std_ulogic_vector(0 to 3);
signal dir_row57_val_d_part2a   : std_ulogic_vector(0 to 3);
signal dir_row57_val_d_part2_b  : std_ulogic_vector(0 to 3);
signal dir_row58_val_d_part1    : std_ulogic_vector(0 to 3);
signal dir_row58_val_d_part2a   : std_ulogic_vector(0 to 3);
signal dir_row58_val_d_part2_b  : std_ulogic_vector(0 to 3);
signal dir_row59_val_d_part1    : std_ulogic_vector(0 to 3);
signal dir_row59_val_d_part2a   : std_ulogic_vector(0 to 3);
signal dir_row59_val_d_part2_b  : std_ulogic_vector(0 to 3);
signal dir_row60_val_d_part1    : std_ulogic_vector(0 to 3);
signal dir_row60_val_d_part2a   : std_ulogic_vector(0 to 3);
signal dir_row60_val_d_part2_b  : std_ulogic_vector(0 to 3);
signal dir_row61_val_d_part1    : std_ulogic_vector(0 to 3);
signal dir_row61_val_d_part2a   : std_ulogic_vector(0 to 3);
signal dir_row61_val_d_part2_b  : std_ulogic_vector(0 to 3);
signal dir_row62_val_d_part1    : std_ulogic_vector(0 to 3);
signal dir_row62_val_d_part2a   : std_ulogic_vector(0 to 3);
signal dir_row62_val_d_part2_b  : std_ulogic_vector(0 to 3);
signal dir_row63_val_d_part1    : std_ulogic_vector(0 to 3);
signal dir_row63_val_d_part2a   : std_ulogic_vector(0 to 3);
signal dir_row63_val_d_part2_b  : std_ulogic_vector(0 to 3);
-- synopsys translate_off
-- synopsys translate_on
signal dir_row_val_even_act         : std_ulogic;
signal dir_row_val_odd_act          : std_ulogic;
-- Check multihit
signal iu2_multihit_err         : std_ulogic;
signal iu3_multihit_err         : std_ulogic;
signal iu2_pc_inj_icachedir_multihit : std_ulogic;
-- Check parity
signal ext_dir_dataout0         : std_ulogic_vector(0 to dir_parity_width*8-1);
signal gen_dir_parity_out0      : std_ulogic_vector(0 to dir_parity_width-1);
signal dir_parity_err_byte0     : std_ulogic_vector(0 to dir_parity_width-1);
signal ext_dir_dataout1         : std_ulogic_vector(0 to dir_parity_width*8-1);
signal gen_dir_parity_out1      : std_ulogic_vector(0 to dir_parity_width-1);
signal dir_parity_err_byte1     : std_ulogic_vector(0 to dir_parity_width-1);
signal ext_dir_dataout2         : std_ulogic_vector(0 to dir_parity_width*8-1);
signal gen_dir_parity_out2      : std_ulogic_vector(0 to dir_parity_width-1);
signal dir_parity_err_byte2     : std_ulogic_vector(0 to dir_parity_width-1);
signal ext_dir_dataout3         : std_ulogic_vector(0 to dir_parity_width*8-1);
signal gen_dir_parity_out3      : std_ulogic_vector(0 to dir_parity_width-1);
signal dir_parity_err_byte3     : std_ulogic_vector(0 to dir_parity_width-1);
signal dir_parity_err_way       : std_ulogic_vector(0 to 3);
signal dir_parity_err           : std_ulogic;
signal iu2_rd_parity_err        : std_ulogic;
signal data_parity_out0         : std_ulogic_vector(0 to 17);
signal gen_data_parity_out0     : std_ulogic_vector(0 to 17);
signal data_parity_err_byte0    : std_ulogic_vector(0 to 17);
signal data_parity_out1         : std_ulogic_vector(0 to 17);
signal gen_data_parity_out1     : std_ulogic_vector(0 to 17);
signal data_parity_err_byte1    : std_ulogic_vector(0 to 17);
signal data_parity_out2         : std_ulogic_vector(0 to 17);
signal gen_data_parity_out2     : std_ulogic_vector(0 to 17);
signal data_parity_err_byte2    : std_ulogic_vector(0 to 17);
signal data_parity_out3         : std_ulogic_vector(0 to 17);
signal gen_data_parity_out3     : std_ulogic_vector(0 to 17);
signal data_parity_err_byte3    : std_ulogic_vector(0 to 17);
signal data_parity_err          : std_ulogic;
signal iu3_parity_act           : std_ulogic;
-- Update Valid Bit
signal lru_select               : std_ulogic_vector(0 to 5);
signal return_lru               : std_ulogic_vector(0 to 2);
signal return_val               : std_ulogic_vector(0 to 3);
-- IU2
signal iu2_rd_miss              : std_ulogic;
signal iu3_rd_miss              : std_ulogic;
signal iu2_miss_flush_prev      : std_ulogic_vector(0 to 3);
signal load_iu2                 : std_ulogic;
signal iu3_act                  : std_ulogic;
signal iu3_valid_next           : std_ulogic;
signal iu2_erat_err             : std_ulogic_vector(0 to 2);
signal iu2_data_dataout_0       : std_ulogic_vector(0 to 143);
signal iu2_data_dataout_1       : std_ulogic_vector(0 to 143);
signal iu2_data_dataout_2       : std_ulogic_vector(0 to 143);
signal iu2_data_dataout_3       : std_ulogic_vector(0 to 143);
signal iu3_instr0_buf           : std_ulogic_vector(0 to 35);
signal iu3_instr1_buf           : std_ulogic_vector(0 to 35);
signal iu3_instr2_buf           : std_ulogic_vector(0 to 35);
signal iu3_instr3_buf           : std_ulogic_vector(0 to 35);
signal iu2_ifar_dec             : std_ulogic_vector(0 to 3);
-- IU3
signal uc_illegal               : std_ulogic;
signal xnop                     : std_ulogic_vector(0 to 35);
signal int_ic_bp_iu3_error      : std_ulogic_vector(0 to 2);
signal iu3_0_instr_rot          : std_ulogic_vector(0 to 35);
signal iu3_1_instr_rot          : std_ulogic_vector(0 to 35);
signal iu3_2_instr_rot          : std_ulogic_vector(0 to 35);
signal iu3_3_instr_rot          : std_ulogic_vector(0 to 35);
signal int_ic_bp_iu3_flush      : std_ulogic;
-- Performance Events
signal iu2_instr_count          : std_ulogic_vector(0 to 2);
signal perf_instr_count_t0_new:   std_ulogic_vector(0 to 2);
signal perf_instr_count_t1_new:   std_ulogic_vector(0 to 2);
signal perf_instr_count_t2_new:   std_ulogic_vector(0 to 2);
signal perf_instr_count_t3_new:   std_ulogic_vector(0 to 2);
-- abist
signal stage_abist_g8t_wenb       : std_ulogic;
signal stage_abist_g8t1p_renb_0   : std_ulogic;
signal stage_abist_di_0           : std_ulogic_vector(0 to 3);
signal stage_abist_g8t_bw_1       : std_ulogic;
signal stage_abist_g8t_bw_0       : std_ulogic;
signal stage_abist_waddr_0        : std_ulogic_vector(4 to 9);
signal stage_abist_raddr_0        : std_ulogic_vector(2 to 9);
signal stage_abist_wl64_comp_ena  : std_ulogic;
signal stage_abist_g8t_dcomp      : std_ulogic_vector(0 to 3);
signal stage_abist_g6t_bw         : std_ulogic_vector(0 to 1);
signal stage_abist_di_g6t_2r      : std_ulogic_vector(0 to 3);
signal stage_abist_wl256_comp_ena : std_ulogic;
signal stage_abist_dcomp_g6t_2r   : std_ulogic_vector(0 to 3);
signal stage_abist_g6t_r_wb       : std_ulogic;
-- scan
signal siv                      : std_ulogic_vector(0 to scan_right);
signal sov                      : std_ulogic_vector(0 to scan_right);
signal abst_siv                 : std_ulogic_vector(0 to 42);
signal abst_sov                 : std_ulogic_vector(0 to 42);
signal time_siv                 : std_ulogic_vector(0 to 2);
signal time_sov                 : std_ulogic_vector(0 to 2);
signal repr_siv                 : std_ulogic_vector(0 to 2);
signal repr_sov                 : std_ulogic_vector(0 to 2);
signal repr_slat_sl_thold_0_b   : std_ulogic;
signal time_slat_sl_thold_0_b   : std_ulogic;
-- synopsys translate_off
-- synopsys translate_on
  BEGIN --@@ START OF EXECUTABLE CODE FOR IUQ_IC_DIR

tidn  <=  '0';
tiup  <=  '1';
ZEROS  <=  (others => '0');
spr_ic_cls_d  <=  spr_ic_cls;
spr_ic_idir_way_d  <=  spr_ic_idir_way;
xu_iu_ici_d  <=  xu_iu_ici;
-----------------------------------------------------------------------
-- IU1 Latches
-----------------------------------------------------------------------
iu1_valid_d  <=  ics_icd_iu0_valid;
iu1_tid_d    <=  ics_icd_iu0_tid;
iu1_ifar_d   <=  ics_icd_iu0_ifar;
iu1_inval_d  <=  ics_icd_iu0_inval;
iu1_2ucode_d  <=  ics_icd_iu0_2ucode;
iu1_2ucode_type_d  <=  ics_icd_iu0_2ucode_type;
iu1_spr_idir_read_d  <=  ics_icd_iu0_spr_idir_read;
icd_ics_iu1_valid  <=  iu1_valid_l2;
icd_ics_iu1_tid    <=  iu1_tid_l2;
icd_ics_iu1_ifar   <=  iu1_ifar_l2;
icd_ics_iu1_2ucode  <=  iu1_2ucode_l2;
icd_ics_iu1_2ucode_type  <=  iu1_2ucode_type_l2;
iu_ierat_iu1_back_inv  <=  iu1_inval_l2;
-----------------------------------------------------------------------
-- ERAT Output
-----------------------------------------------------------------------
iu2_ci  <=  ierat_iu_iu2_wimge(1);
iu2_endian  <=  ierat_iu_iu2_wimge(4);
iu2_ifar_eff_d  <=  iu1_ifar_l2;
-----------------------------------------------------------------------
-- Access IDIR, Valid, & LRU
-----------------------------------------------------------------------
dir_rd_act  <=  ics_icd_dir_rd_act;
dir_write  <=  icm_icd_dir_write;
dir_way  <=  icm_icd_dir_write_way;
dir_wr_addr  <=  icm_icd_dir_write_addr(52 to 56) & (icm_icd_dir_write_addr(57) and not spr_ic_cls_l2);
dir_rd_addr  <=  ics_icd_iu0_ifar(52 to 56) &
              (ics_icd_iu0_ifar(57) and not (spr_ic_cls_l2 and not ics_icd_iu0_spr_idir_read));
calc_ext_dir_data: for i in ext_dir_datain'range generate
begin
  R0:if(i <  52-REAL_IFAR'left) generate begin ext_dir_datain(i) <= icm_icd_dir_write_addr(REAL_IFAR'left+i);
end generate;
R1:if(i =  52-REAL_IFAR'left) generate
begin ext_dir_datain(i) <=  icm_icd_dir_write_endian;
end generate;
R2:if(i > 52-REAL_IFAR'left) generate
begin ext_dir_datain(i) <=  '0';
end generate;
end generate;
gen_dir_parity: for i in dir_parity_in'range generate
begin
   dir_parity_in(i) <=  xor_reduce( ext_dir_datain(i*8 to i*8+7) );
end generate;
way_datain(0 TO 52-REAL_IFAR'left-1) <=  icm_icd_dir_write_addr(REAL_IFAR'left to 51);
way_datain(52-REAL_IFAR'left) <=  icm_icd_dir_write_endian;
way_datain(52-REAL_IFAR'left+1 TO 52-REAL_IFAR'left+1+dir_parity_width-1) <=  dir_parity_in;
ext: if (dir_way_width < way_datain'length) generate
way_datain(52-REAL_IFAR'left+1+dir_parity_width TO way_datain'right) <=  (others => '0');
end generate;
-- Reverse bit ordering to get rid of wiring bowtie
way_datain_rev  <=  reverse(way_datain);
dir_datain_rev  <=  way_datain_rev & way_datain_rev & way_datain_rev & way_datain_rev;
-- Only need 35 bits per way - array has extra bits
-- 0:29 - tag, 30 - endianness, 31:34 - parity
idir: entity tri.tri_64x36_4w_1r1w(tri_64x36_4w_1r1w)
  generic map ( expand_type => expand_type )
  port map(
    gnd               => gnd,
    vdd               => vdd,
    vcs               => vcs,
    nclk              => nclk,
    rd_act            => dir_rd_act,
    wr_act            => dir_write,
    sg_0              => pc_iu_sg_0,
    abst_sl_thold_0   => pc_iu_abst_slp_sl_thold_0,
    ary_nsl_thold_0   => pc_iu_ary_slp_nsl_thold_0,
    time_sl_thold_0   => pc_iu_time_sl_thold_0,
    repr_sl_thold_0   => pc_iu_repr_sl_thold_0,
    clkoff_dc_b       => g8t_clkoff_b,
    ccflush_dc        => tc_ac_ccflush_dc,
    scan_dis_dc_b     => an_ac_scan_dis_dc_b,
    scan_diag_dc      => an_ac_scan_diag_dc,
    d_mode_dc         => g8t_d_mode,
    mpw1_dc_b         => g8t_mpw1_b,
    mpw2_dc_b         => g8t_mpw2_b,
    delay_lclkr_dc    => g8t_delay_lclkr,
    wr_abst_act       => stage_abist_g8t_wenb,
    rd0_abst_act      => stage_abist_g8t1p_renb_0,
    abist_di          => stage_abist_di_0,
    abist_bw_odd      => stage_abist_g8t_bw_1,
    abist_bw_even     => stage_abist_g8t_bw_0,
    abist_wr_adr      => stage_abist_waddr_0(4 to 9),
    abist_rd0_adr     => stage_abist_raddr_0(4 to 9),
    tc_lbist_ary_wrt_thru_dc    => an_ac_lbist_ary_wrt_thru_dc,
    abist_ena_1                 => pc_iu_abist_ena_dc,
    abist_g8t_rd0_comp_ena      => stage_abist_wl64_comp_ena,
    abist_raw_dc_b              => pc_iu_abist_raw_dc_b,
    obs0_abist_cmp              => stage_abist_g8t_dcomp,
    abst_scan_in(0)   => abst_siv(0),
    abst_scan_in(1)   => abst_siv(2),
    time_scan_in      => time_siv(0),
    repr_scan_in      => repr_siv(0),
    abst_scan_out(0)  => abst_sov(0),
    abst_scan_out(1)  => abst_sov(2),
    time_scan_out     => time_sov(0),
    repr_scan_out     => repr_sov(0),
    lcb_bolt_sl_thold_0         => pc_iu_bolt_sl_thold_0,
    pc_bo_enable_2              => pc_iu_bo_enable_2,
    pc_bo_reset                 => pc_iu_bo_reset,
    pc_bo_unload                => pc_iu_bo_unload,
    pc_bo_repair                => pc_iu_bo_repair,
    pc_bo_shdata                => pc_iu_bo_shdata,
    pc_bo_select                => pc_iu_bo_select(0 to 1),
    bo_pc_failout               => iu_pc_bo_fail(0 to 1),
    bo_pc_diagloop              => iu_pc_bo_diagout(0 to 1),
    tri_lcb_mpw1_dc_b           => mpw1_b,
    tri_lcb_mpw2_dc_b           => mpw2_b,
    tri_lcb_delay_lclkr_dc      => delay_lclkr,
    tri_lcb_clkoff_dc_b         => clkoff_b,
    tri_lcb_act_dis_dc          => act_dis,
    wr_way            => dir_way,
    wr_addr           => dir_wr_addr,
    data_in           => dir_datain_rev,
    rd_addr           => dir_rd_addr,
    data_out          => dir_dataout_rev
);
dir_dataout(0 TO dir_array_way_width-1) <=  reverse(dir_dataout_rev(                    0 to   dir_array_way_width-1));
dir_dataout(dir_array_way_width TO 2*dir_array_way_width-1) <=  reverse(dir_dataout_rev(  dir_array_way_width to 2*dir_array_way_width-1));
dir_dataout(2*dir_array_way_width TO 3*dir_array_way_width-1) <=  reverse(dir_dataout_rev(2*dir_array_way_width to 3*dir_array_way_width-1));
dir_dataout(3*dir_array_way_width TO 4*dir_array_way_width-1) <=  reverse(dir_dataout_rev(3*dir_array_way_width to 4*dir_array_way_width-1));
dir_dataout_act  <=  iu1_valid_l2 or iu1_inval_l2 or iu1_spr_idir_read_l2;
iu2_dir_dataout_0_d(REAL_IFAR'left) <=  dir_dataout(0) xor pc_iu_inj_icachedir_parity;
iu2_dir_dataout_0_d(REAL_IFAR'left+1 TO iu2_dir_dataout_0_d'right) <=  dir_dataout(                    1 to                       dir_way_width-dir_parity_width-1);
iu2_dir_dataout_1_d(REAL_IFAR'left TO iu2_dir_dataout_1_d'right) <=  dir_dataout(  dir_array_way_width to   dir_array_way_width+dir_way_width-dir_parity_width-1);
iu2_dir_dataout_2_d(REAL_IFAR'left TO iu2_dir_dataout_1_d'right) <=  dir_dataout(2*dir_array_way_width to 2*dir_array_way_width+dir_way_width-dir_parity_width-1);
iu2_dir_dataout_3_d(REAL_IFAR'left TO iu2_dir_dataout_1_d'right) <=  dir_dataout(3*dir_array_way_width to 3*dir_array_way_width+dir_way_width-dir_parity_width-1);
ext_iu2_dir_dataout: if (REAL_IFAR'left > 22) generate
begin
  iu2_dir_dataout_0_d(22 TO REAL_IFAR'left-1) <=  (others => '0');
iu2_dir_dataout_1_d(22 TO REAL_IFAR'left-1) <=  (others => '0');
iu2_dir_dataout_2_d(22 TO REAL_IFAR'left-1) <=  (others => '0');
iu2_dir_dataout_3_d(22 TO REAL_IFAR'left-1) <=  (others => '0');
end generate;
-- Parity
iu2_dir_dataout_0_par_d  <=  dir_dataout(                      dir_way_width-dir_parity_width to                       dir_way_width-1);
iu2_dir_dataout_1_par_d  <=  dir_dataout(  dir_array_way_width+dir_way_width-dir_parity_width to   dir_array_way_width+dir_way_width-1);
iu2_dir_dataout_2_par_d  <=  dir_dataout(2*dir_array_way_width+dir_way_width-dir_parity_width to 2*dir_array_way_width+dir_way_width-1);
iu2_dir_dataout_3_par_d  <=  dir_dataout(3*dir_array_way_width+dir_way_width-dir_parity_width to 3*dir_array_way_width+dir_way_width-1);
-- Muxing the val for directory access
iu1_ifar_cacheline  <=  iu1_ifar_l2(52 to 56) &
                     (iu1_ifar_l2(57) and not (spr_ic_cls_l2 and not iu1_spr_idir_read_l2));
with iu1_ifar_cacheline select
dir_rd_val  <=  dir_row0_val_l2 when "000000",
              dir_row1_val_l2 when "000001",
              dir_row2_val_l2   when "000010",
              dir_row3_val_l2   when "000011",
              dir_row4_val_l2   when "000100",
              dir_row5_val_l2   when "000101",
              dir_row6_val_l2   when "000110",
              dir_row7_val_l2   when "000111",
              dir_row8_val_l2   when "001000",
              dir_row9_val_l2   when "001001",
              dir_row10_val_l2  when "001010",
              dir_row11_val_l2  when "001011",
              dir_row12_val_l2  when "001100",
              dir_row13_val_l2  when "001101",
              dir_row14_val_l2  when "001110",
              dir_row15_val_l2  when "001111",
              dir_row16_val_l2  when "010000",
              dir_row17_val_l2  when "010001",
              dir_row18_val_l2  when "010010",
              dir_row19_val_l2  when "010011",
              dir_row20_val_l2  when "010100",
              dir_row21_val_l2  when "010101",
              dir_row22_val_l2  when "010110",
              dir_row23_val_l2  when "010111",
              dir_row24_val_l2  when "011000",
              dir_row25_val_l2  when "011001",
              dir_row26_val_l2  when "011010",
              dir_row27_val_l2  when "011011",
              dir_row28_val_l2  when "011100",
              dir_row29_val_l2  when "011101",
              dir_row30_val_l2  when "011110",
              dir_row31_val_l2  when "011111",
              dir_row32_val_l2  when "100000",
              dir_row33_val_l2  when "100001",
              dir_row34_val_l2  when "100010",
              dir_row35_val_l2  when "100011",
              dir_row36_val_l2  when "100100",
              dir_row37_val_l2  when "100101",
              dir_row38_val_l2  when "100110",
              dir_row39_val_l2  when "100111",
              dir_row40_val_l2  when "101000",
              dir_row41_val_l2  when "101001",
              dir_row42_val_l2  when "101010",
              dir_row43_val_l2  when "101011",
              dir_row44_val_l2  when "101100",
              dir_row45_val_l2  when "101101",
              dir_row46_val_l2  when "101110",
              dir_row47_val_l2  when "101111",
              dir_row48_val_l2  when "110000",
              dir_row49_val_l2  when "110001",
              dir_row50_val_l2  when "110010",
              dir_row51_val_l2  when "110011",
              dir_row52_val_l2  when "110100",
              dir_row53_val_l2  when "110101",
              dir_row54_val_l2  when "110110",
              dir_row55_val_l2  when "110111",
              dir_row56_val_l2  when "111000",
              dir_row57_val_l2  when "111001",
              dir_row58_val_l2  when "111010",
              dir_row59_val_l2  when "111011",
              dir_row60_val_l2  when "111100",
              dir_row61_val_l2  when "111101",
              dir_row62_val_l2  when "111110",
              dir_row63_val_l2  when "111111",
              "0000" when others;
iu2_dir_rd_val_d  <=  dir_rd_val;
with spr_ic_idir_way_l2 select
ic_spr_idir_valid  <=  iu2_dir_rd_val_l2(0) when "00",
                     iu2_dir_rd_val_l2(1) when "01",
                     iu2_dir_rd_val_l2(2) when "10",
                     iu2_dir_rd_val_l2(3) when others;
 WITH s6'(iu1_ifar_l2(52 to 57))  SELECT iu2_spr_idir_lru_d  <=  dir_row0_lru_l2  when "000000",
                      dir_row1_lru_l2    when "000001",
                      dir_row2_lru_l2    when "000010",
                      dir_row3_lru_l2    when "000011",
                      dir_row4_lru_l2    when "000100",
                      dir_row5_lru_l2    when "000101",
                      dir_row6_lru_l2    when "000110",
                      dir_row7_lru_l2    when "000111",
                      dir_row8_lru_l2    when "001000",
                      dir_row9_lru_l2    when "001001",
                      dir_row10_lru_l2   when "001010",
                      dir_row11_lru_l2   when "001011",
                      dir_row12_lru_l2   when "001100",
                      dir_row13_lru_l2   when "001101",
                      dir_row14_lru_l2   when "001110",
                      dir_row15_lru_l2   when "001111",
                      dir_row16_lru_l2   when "010000",
                      dir_row17_lru_l2   when "010001",
                      dir_row18_lru_l2   when "010010",
                      dir_row19_lru_l2   when "010011",
                      dir_row20_lru_l2   when "010100",
                      dir_row21_lru_l2   when "010101",
                      dir_row22_lru_l2   when "010110",
                      dir_row23_lru_l2   when "010111",
                      dir_row24_lru_l2   when "011000",
                      dir_row25_lru_l2   when "011001",
                      dir_row26_lru_l2   when "011010",
                      dir_row27_lru_l2   when "011011",
                      dir_row28_lru_l2   when "011100",
                      dir_row29_lru_l2   when "011101",
                      dir_row30_lru_l2   when "011110",
                      dir_row31_lru_l2   when "011111",
                      dir_row32_lru_l2   when "100000",
                      dir_row33_lru_l2   when "100001",
                      dir_row34_lru_l2   when "100010",
                      dir_row35_lru_l2   when "100011",
                      dir_row36_lru_l2   when "100100",
                      dir_row37_lru_l2   when "100101",
                      dir_row38_lru_l2   when "100110",
                      dir_row39_lru_l2   when "100111",
                      dir_row40_lru_l2   when "101000",
                      dir_row41_lru_l2   when "101001",
                      dir_row42_lru_l2   when "101010",
                      dir_row43_lru_l2   when "101011",
                      dir_row44_lru_l2   when "101100",
                      dir_row45_lru_l2   when "101101",
                      dir_row46_lru_l2   when "101110",
                      dir_row47_lru_l2   when "101111",
                      dir_row48_lru_l2   when "110000",
                      dir_row49_lru_l2   when "110001",
                      dir_row50_lru_l2   when "110010",
                      dir_row51_lru_l2   when "110011",
                      dir_row52_lru_l2   when "110100",
                      dir_row53_lru_l2   when "110101",
                      dir_row54_lru_l2   when "110110",
                      dir_row55_lru_l2   when "110111",
                      dir_row56_lru_l2   when "111000",
                      dir_row57_lru_l2   when "111001",
                      dir_row58_lru_l2   when "111010",
                      dir_row59_lru_l2   when "111011",
                      dir_row60_lru_l2   when "111100",
                      dir_row61_lru_l2   when "111101",
                      dir_row62_lru_l2   when "111110",
                      dir_row63_lru_l2 when others;
ic_spr_idir_lru  <=  iu2_spr_idir_lru_l2;
with spr_ic_idir_way_l2 select
ic_spr_idir_tag  <=  iu2_dir_dataout_0_noncmp(22 to 51)   when "00",
                   iu2_dir_dataout_1_noncmp(22 to 51)   when "01",
                   iu2_dir_dataout_2_noncmp(22 to 51)   when "10",
                   iu2_dir_dataout_3_noncmp(22 to 51)   when others;
with spr_ic_idir_way_l2 select
ic_spr_idir_endian  <=  iu2_dir_dataout_0_noncmp(52)   when "00",
                      iu2_dir_dataout_1_noncmp(52)   when "01",
                      iu2_dir_dataout_2_noncmp(52)   when "10",
                      iu2_dir_dataout_3_noncmp(52)   when others;
with spr_ic_idir_way_l2 select
ic_spr_idir_parity(0 to dir_parity_width-1)  <=  iu2_dir_dataout_0_par_l2  when "00",
                                               iu2_dir_dataout_1_par_l2  when "01",
                                               iu2_dir_dataout_2_par_l2  when "10",
                                               iu2_dir_dataout_3_par_l2  when others;
ext_spr_parity: if (dir_parity_width < 4) generate
begin ic_spr_idir_parity(dir_parity_width TO 3) <=  (others => '0');
end generate;
ic_spr_idir_done  <=  iu2_spr_idir_read_l2;
-----------------------------------------------------------------------
-- Access IData
-----------------------------------------------------------------------
data_write  <=  icm_icd_data_write;
data_way  <=  icm_icd_reload_way;
data_addr  <=  icm_icd_reload_addr(52 to 59) when data_write = '1'
          else ics_icd_iu0_ifar(52 to 59);
data_parity_in   <=  icm_icd_reload_data(144 to 161);
data_datain      <=  icm_icd_reload_data(0 to 143) & data_parity_in;
idata: entity tri.tri_256x162_4w_0(tri_256x162_4w_0)
  generic map ( expand_type => expand_type )
  port map(
    gnd                         => gnd,
    vdd                         => vdd,
    vcs                         => vcs,
    nclk                        => nclk,
    ccflush_dc                  => tc_ac_ccflush_dc,
    lcb_clkoff_dc_b             => g6t_clkoff_b,
    lcb_d_mode_dc               => g6t_d_mode,
    lcb_act_dis_dc              => g6t_act_dis,
    lcb_ary_nsl_thold_0         => pc_iu_ary_nsl_thold_0,
    lcb_sg_1                    => pc_iu_sg_1,
    lcb_abst_sl_thold_0         => pc_iu_abst_sl_thold_0,
    scan_diag_dc                => an_ac_scan_diag_dc,
    scan_dis_dc_b               => an_ac_scan_dis_dc_b,
    abst_scan_in(0)             => abst_siv(1),
    abst_scan_in(1)             => abst_siv(3),
    abst_scan_out(0)            => abst_sov(1),
    abst_scan_out(1)            => abst_sov(3),
    lcb_delay_lclkr_np_dc       => g6t_delay_lclkr(0),
    ctrl_lcb_delay_lclkr_np_dc  => g6t_delay_lclkr(1),
    dibw_lcb_delay_lclkr_np_dc  => g6t_delay_lclkr(2),
    ctrl_lcb_mpw1_np_dc_b       => g6t_mpw1_b(0),
    dibw_lcb_mpw1_np_dc_b       => g6t_mpw1_b(1),
    lcb_mpw1_pp_dc_b            => g6t_mpw1_b(2),
    lcb_mpw1_2_pp_dc_b          => g6t_mpw1_b(3),
    aodo_lcb_delay_lclkr_dc     => g6t_delay_lclkr(3),
    aodo_lcb_mpw1_dc_b          => g6t_mpw1_b(4),
    aodo_lcb_mpw2_dc_b          => g6t_mpw2_b,
    lcb_time_sg_0               => pc_iu_sg_0,
    lcb_time_sl_thold_0         => pc_iu_time_sl_thold_0,
    time_scan_in                => time_siv(1),
    time_scan_out               => time_sov(1),
    bitw_abist                  => stage_abist_g6t_bw,
    lcb_repr_sl_thold_0         => pc_iu_repr_sl_thold_0,
    lcb_repr_sg_0               => pc_iu_sg_0,
    repr_scan_in                => repr_siv(1),
    repr_scan_out               => repr_sov(1),
    tc_lbist_ary_wrt_thru_dc    => an_ac_lbist_ary_wrt_thru_dc,
    abist_en_1                  => pc_iu_abist_ena_dc,
    din_abist                   => stage_abist_di_g6t_2r,
    abist_cmp_en                => stage_abist_wl256_comp_ena,
    abist_raw_b_dc              => pc_iu_abist_raw_dc_b,
    data_cmp_abist              => stage_abist_dcomp_g6t_2r,
    addr_abist                  => stage_abist_raddr_0(2 to 9),
    r_wb_abist                  => stage_abist_g6t_r_wb,
    write_thru_en_dc            => tidn,
    lcb_bolt_sl_thold_0         => pc_iu_bolt_sl_thold_0,
    pc_bo_enable_2              => pc_iu_bo_enable_2,
    pc_bo_reset                 => pc_iu_bo_reset,
    pc_bo_unload                => pc_iu_bo_unload,
    pc_bo_repair                => pc_iu_bo_repair,
    pc_bo_shdata                => pc_iu_bo_shdata,
    pc_bo_select                => pc_iu_bo_select(2 to 3),
    bo_pc_failout               => iu_pc_bo_fail(2 to 3),
    bo_pc_diagloop              => iu_pc_bo_diagout(2 to 3),
    tri_lcb_mpw1_dc_b           => mpw1_b,
    tri_lcb_mpw2_dc_b           => mpw2_b,
    tri_lcb_delay_lclkr_dc      => delay_lclkr,
    tri_lcb_clkoff_dc_b         => clkoff_b,
    tri_lcb_act_dis_dc          => act_dis,
    read_act          => ics_icd_data_rd_act,
    write_enable      => data_write,
    write_way         => data_way,
    addr              => data_addr,
    data_in           => data_datain,
    data_out          => data_dataout
);
iu2_data_dataout_d  <=  data_dataout;
data_dataout_inj(0) <=  iu2_data_dataout_l2(0) xor pc_iu_inj_icache_parity;
data_dataout_inj(1 TO data_dataout'right) <=  iu2_data_dataout_l2(1 to data_dataout'right);
dircmp: entity work.iuq_ic_dir_cmp(iuq_ic_dir_cmp)
  generic map ( expand_type => expand_type )
  port map(       
       vdd                                => vdd,
       gnd                                => gnd,
       nclk                               => nclk,
       delay_lclkr                        => delay_lclkr,
       mpw1_b                             => mpw1_b,
       mpw2_b                             => mpw2_b,
       forcee => funcslp_force,
       sg_0                               => pc_iu_sg_0,
       thold_0_b                          => pc_iu_func_slp_sl_thold_0_b,
       scan_in                            => siv(iu2_dir_dataout_offset),
       scan_out                           => sov(iu2_dir_dataout_offset),
       dir_dataout_act                    => dir_dataout_act                    ,
       iu2_endian                         => iu2_endian                         ,
       ierat_iu_iu2_rpn(22 to 51)         => ierat_iu_iu2_rpn(22 to 51)         ,
       iu2_dir_dataout_0_d(22 to 52)      => iu2_dir_dataout_0_d(22 to 52)      ,
       iu2_dir_dataout_1_d(22 to 52)      => iu2_dir_dataout_1_d(22 to 52)      ,
       iu2_dir_dataout_2_d(22 to 52)      => iu2_dir_dataout_2_d(22 to 52)      ,
       iu2_dir_dataout_3_d(22 to 52)      => iu2_dir_dataout_3_d(22 to 52)      ,
       ierat_iu_iu2_rpn_noncmp(22 to 51)  => ierat_iu_iu2_rpn_noncmp(22 to 51)  ,
       iu2_dir_dataout_0_noncmp(22 to 52) => iu2_dir_dataout_0_noncmp(22 to 52) ,
       iu2_dir_dataout_1_noncmp(22 to 52) => iu2_dir_dataout_1_noncmp(22 to 52) ,
       iu2_dir_dataout_2_noncmp(22 to 52) => iu2_dir_dataout_2_noncmp(22 to 52) ,
       iu2_dir_dataout_3_noncmp(22 to 52) => iu2_dir_dataout_3_noncmp(22 to 52) ,
       iu2_dir_rd_val(0 to 3)             => iu2_dir_rd_val_l2(0 to 3)          ,
       iu2_rd_way_tag_hit(0 to 3)         => iu2_rd_way_tag_hit(0 to 3)         ,
       iu2_rd_way_hit(0 to 3)             => iu2_rd_way_hit(0 to 3)             ,
       iu2_rd_way_hit_insmux_b(0 to 3)    => iu2_rd_way_hit_insmux_b(0 to 3)   );
iu2_dir_miss  <=  not or_reduce(iu2_rd_way_hit);
iu2_valid_d  <=  iu1_valid_l2 and or_reduce(iu1_tid_l2 and not ics_icd_iu1_flush_tid and not ics_icd_all_flush_prev);
iu2_valid  <=  iu2_valid_l2 and or_reduce(iu2_tid_l2 and not ics_icd_all_flush_prev and not iu2_miss_flush_prev);
iu2_tid_d  <=  iu1_tid_l2;
iu2_2ucode_d  <=  iu1_2ucode_l2;
iu2_2ucode_type_d  <=  iu1_2ucode_type_l2;
iu2_inval_d  <=  iu1_inval_l2;
iu2_spr_idir_read_d  <=  iu1_spr_idir_read_l2;
-----------------------------------------------------------------------
-- Check Multihit
-----------------------------------------------------------------------
-- Set if more than 1 way matches (not 0000, 0001, 0010, 0100, 1000)
iu2_multihit_err  <=  (iu2_valid or iu2_inval_l2 or iu2_spr_idir_read_l2) and     
                    not (( iu2_rd_way_hit(0 to 2) = "000") or
                         ((iu2_rd_way_hit(0 to 1) & iu2_rd_way_hit(3)) = "000") or
                         ((iu2_rd_way_hit(0) & iu2_rd_way_hit(2 to 3)) = "000") or
                         ( iu2_rd_way_hit(1 to 3) = "000"));
iu2_pc_inj_icachedir_multihit  <=  (iu2_valid or iu2_inval_l2 or iu2_spr_idir_read_l2) and pc_iu_inj_icachedir_multihit and not iu2_dir_miss;
iu3_multihit_err_way_d  <=  gate_and(iu2_multihit_err, iu2_rd_way_hit) or
        (iu2_pc_inj_icachedir_multihit & iu2_pc_inj_icachedir_multihit & iu2_pc_inj_icachedir_multihit & iu2_pc_inj_icachedir_multihit);
iu3_multihit_err  <=  or_reduce(iu3_multihit_err_way_l2);
iu3_multihit_flush_d  <=  (iu2_multihit_err or (pc_iu_inj_icachedir_multihit and not iu2_dir_miss)) and (iu2_valid and or_reduce(iu2_tid_l2 and not ics_icd_iu2_flush_tid) and not iu2_ci);
err_icachedir_multihit: tri_direct_err_rpt
  generic map (width => 1, expand_type => expand_type)
  port map (
            vd          => vdd,
            gd          => gnd,
            err_in(0)   => iu3_multihit_err,
            err_out(0)  => iu_pc_err_icachedir_multihit
            );
-----------------------------------------------------------------------
-- Check Parity
-----------------------------------------------------------------------
calc_ext_dir_dataout0:   for i in ext_dir_datain'range generate
begin
    R0:if(i <  52-REAL_IFAR'left+1) generate begin ext_dir_dataout0(i)   <= iu2_dir_dataout_0_noncmp(REAL_IFAR'left+i);
end generate;
R1:if(i >= 52-REAL_IFAR'left+1) generate
begin ext_dir_dataout0(i) <=  '0';
end generate;
end generate;
chk_dir_parity0:   for i in dir_parity_in'range generate
begin
    gen_dir_parity_out0(i) <=  xor_reduce( ext_dir_dataout0(i*8   to i*8+7) );
end generate;
dir_parity_err_byte0    <=  iu2_dir_dataout_0_par_l2   xor gen_dir_parity_out0;
dir_parity_err_way(0) <=  or_reduce(dir_parity_err_byte0)   and iu2_dir_rd_val_l2(0)   and (iu2_valid or iu2_inval_l2 or iu2_spr_idir_read_l2);
calc_ext_dir_dataout1:   for i in ext_dir_datain'range generate
begin
    R0:if(i <  52-REAL_IFAR'left+1) generate begin ext_dir_dataout1(i)   <= iu2_dir_dataout_1_noncmp(REAL_IFAR'left+i);
end generate;
R1:if(i >= 52-REAL_IFAR'left+1) generate
begin ext_dir_dataout1(i) <=  '0';
end generate;
end generate;
chk_dir_parity1:   for i in dir_parity_in'range generate
begin
    gen_dir_parity_out1(i) <=  xor_reduce( ext_dir_dataout1(i*8   to i*8+7) );
end generate;
dir_parity_err_byte1    <=  iu2_dir_dataout_1_par_l2   xor gen_dir_parity_out1;
dir_parity_err_way(1) <=  or_reduce(dir_parity_err_byte1)   and iu2_dir_rd_val_l2(1)   and (iu2_valid or iu2_inval_l2 or iu2_spr_idir_read_l2);
calc_ext_dir_dataout2:   for i in ext_dir_datain'range generate
begin
    R0:if(i <  52-REAL_IFAR'left+1) generate begin ext_dir_dataout2(i)   <= iu2_dir_dataout_2_noncmp(REAL_IFAR'left+i);
end generate;
R1:if(i >= 52-REAL_IFAR'left+1) generate
begin ext_dir_dataout2(i) <=  '0';
end generate;
end generate;
chk_dir_parity2:   for i in dir_parity_in'range generate
begin
    gen_dir_parity_out2(i) <=  xor_reduce( ext_dir_dataout2(i*8   to i*8+7) );
end generate;
dir_parity_err_byte2    <=  iu2_dir_dataout_2_par_l2   xor gen_dir_parity_out2;
dir_parity_err_way(2) <=  or_reduce(dir_parity_err_byte2)   and iu2_dir_rd_val_l2(2)   and (iu2_valid or iu2_inval_l2 or iu2_spr_idir_read_l2);
calc_ext_dir_dataout3:   for i in ext_dir_datain'range generate
begin
    R0:if(i <  52-REAL_IFAR'left+1) generate begin ext_dir_dataout3(i)   <= iu2_dir_dataout_3_noncmp(REAL_IFAR'left+i);
end generate;
R1:if(i >= 52-REAL_IFAR'left+1) generate
begin ext_dir_dataout3(i) <=  '0';
end generate;
end generate;
chk_dir_parity3:   for i in dir_parity_in'range generate
begin
    gen_dir_parity_out3(i) <=  xor_reduce( ext_dir_dataout3(i*8   to i*8+7) );
end generate;
dir_parity_err_byte3    <=  iu2_dir_dataout_3_par_l2   xor gen_dir_parity_out3;
dir_parity_err_way(3) <=  or_reduce(dir_parity_err_byte3)   and iu2_dir_rd_val_l2(3)   and (iu2_valid or iu2_inval_l2 or iu2_spr_idir_read_l2);
iu3_dir_parity_err_way_d  <=  dir_parity_err_way;
dir_parity_err  <=  or_reduce(dir_parity_err_way);
iu2_rd_parity_err  <=  or_reduce(dir_parity_err_way and iu2_rd_way_hit);
err_icachedir_parity_d  <=  dir_parity_err;
err_icachedir_parity: tri_direct_err_rpt
  generic map (width => 1, expand_type => expand_type)
  port map (
            vd          => vdd,
            gd          => gnd,
            err_in(0)   => err_icachedir_parity_l2,
            err_out(0)  => iu_pc_err_icachedir_parity
            );
--Data
data_parity_out0    <=  data_dataout_inj(144         to 144+data_parity_in'length-1);
chk_data_parity0:   for i in data_parity_in'range generate
begin
    gen_data_parity_out0(i) <=  xor_reduce( data_dataout_inj(0+i*8       to 0+i*8+7)       );
end generate;
data_parity_err_byte0    <=  data_parity_out0   xor gen_data_parity_out0;
iu3_data_parity_err_way_d(0) <=  or_reduce(data_parity_err_byte0)   and iu2_dir_rd_val_l2(0)   and iu2_valid_l2;
data_parity_out1    <=  data_dataout_inj(306         to 306+data_parity_in'length-1);
chk_data_parity1:   for i in data_parity_in'range generate
begin
    gen_data_parity_out1(i) <=  xor_reduce( data_dataout_inj(162+i*8     to 162+i*8+7)     );
end generate;
data_parity_err_byte1    <=  data_parity_out1   xor gen_data_parity_out1;
iu3_data_parity_err_way_d(1) <=  or_reduce(data_parity_err_byte1)   and iu2_dir_rd_val_l2(1)   and iu2_valid_l2;
data_parity_out2    <=  data_dataout_inj(468         to 468+data_parity_in'length-1);
chk_data_parity2:   for i in data_parity_in'range generate
begin
    gen_data_parity_out2(i) <=  xor_reduce( data_dataout_inj(324+i*8     to 324+i*8+7)     );
end generate;
data_parity_err_byte2    <=  data_parity_out2   xor gen_data_parity_out2;
iu3_data_parity_err_way_d(2) <=  or_reduce(data_parity_err_byte2)   and iu2_dir_rd_val_l2(2)   and iu2_valid_l2;
data_parity_out3    <=  data_dataout_inj(630         to 630+data_parity_in'length-1);
chk_data_parity3:   for i in data_parity_in'range generate
begin
    gen_data_parity_out3(i) <=  xor_reduce( data_dataout_inj(486+i*8     to 486+i*8+7)     );
end generate;
data_parity_err_byte3    <=  data_parity_out3   xor gen_data_parity_out3;
iu3_data_parity_err_way_d(3) <=  or_reduce(data_parity_err_byte3)   and iu2_dir_rd_val_l2(3)   and iu2_valid_l2;
data_parity_err  <=  or_reduce(iu3_data_parity_err_way_l2);
err_icache_parity_d  <=  data_parity_err;
err_icache_parity: tri_direct_err_rpt
  generic map (width => 1, expand_type => expand_type)
  port map (
            vd          => vdd,
            gd          => gnd,
            err_in(0)   => err_icache_parity_l2,
            err_out(0)  => iu_pc_err_icache_parity
            );
iu3_parity_needs_flush_d  <=  gate_and(iu2_valid and or_reduce(iu2_tid_l2 and not ics_icd_iu2_flush_tid) and not iu2_ci, iu2_rd_way_hit);
iu3_parity_needs_flush    <=  or_reduce(iu3_data_parity_err_way_l2 and iu3_parity_needs_flush_l2);
iu3_parity_flush_tid(0) <=  iu3_tid_l2(0)   and not ics_icd_all_flush_prev(0)   and not iu3_erat_err_l2(0);
iu3_parity_flush_tid(1) <=  iu3_tid_l2(1)   and not ics_icd_all_flush_prev(1)   and not iu3_erat_err_l2(0);
iu3_parity_flush_tid(2) <=  iu3_tid_l2(2)   and not ics_icd_all_flush_prev(2)   and not iu3_erat_err_l2(0);
iu3_parity_flush_tid(3) <=  iu3_tid_l2(3)   and not ics_icd_all_flush_prev(3)   and not iu3_erat_err_l2(0);
iu3_parity_flush  <=  (iu3_parity_needs_flush or iu3_rd_parity_err_l2 or iu3_multihit_flush_l2);
icd_ics_iu3_parity_flush  <=  gate_and(iu3_parity_flush, iu3_parity_flush_tid);
iu3_parity_tag_d  <=  iu2_ifar_eff_l2(52 to 57);
iu3_parity_act  <=  spr_ic_clockgate_dis or
    (iu2_valid or iu2_inval_l2 or iu2_spr_idir_read_l2) or or_reduce(iu3_any_parity_err_way);
-----------------------------------------------------------------------
-- Update LRU
-----------------------------------------------------------------------
-- update LRU in IU2 on read hit or icm_icd_lru_write
dir_row0_lru_d    <=  dir_row0_lru_write   when (icm_icd_lru_write and (lru_write_cacheline(0 to 5) = "000000"))   = '1'
               else dir_row0_lru_read    when (iu2_lru_rd_update and iu2_ifar_eff_cacheline(0 to 5) = "000000")   = '1'
               else dir_row0_lru_l2;
dir_row1_lru_d    <=  dir_row1_lru_write   when (icm_icd_lru_write and (lru_write_cacheline(0 to 5) = "000001"))   = '1'
               else dir_row1_lru_read    when (iu2_lru_rd_update and iu2_ifar_eff_cacheline(0 to 5) = "000001")   = '1'
               else dir_row1_lru_l2;
dir_row2_lru_d    <=  dir_row2_lru_write   when (icm_icd_lru_write and (lru_write_cacheline(0 to 5) = "000010"))   = '1'
               else dir_row2_lru_read    when (iu2_lru_rd_update and iu2_ifar_eff_cacheline(0 to 5) = "000010")   = '1'
               else dir_row2_lru_l2;
dir_row3_lru_d    <=  dir_row3_lru_write   when (icm_icd_lru_write and (lru_write_cacheline(0 to 5) = "000011"))   = '1'
               else dir_row3_lru_read    when (iu2_lru_rd_update and iu2_ifar_eff_cacheline(0 to 5) = "000011")   = '1'
               else dir_row3_lru_l2;
dir_row4_lru_d    <=  dir_row4_lru_write   when (icm_icd_lru_write and (lru_write_cacheline(0 to 5) = "000100"))   = '1'
               else dir_row4_lru_read    when (iu2_lru_rd_update and iu2_ifar_eff_cacheline(0 to 5) = "000100")   = '1'
               else dir_row4_lru_l2;
dir_row5_lru_d    <=  dir_row5_lru_write   when (icm_icd_lru_write and (lru_write_cacheline(0 to 5) = "000101"))   = '1'
               else dir_row5_lru_read    when (iu2_lru_rd_update and iu2_ifar_eff_cacheline(0 to 5) = "000101")   = '1'
               else dir_row5_lru_l2;
dir_row6_lru_d    <=  dir_row6_lru_write   when (icm_icd_lru_write and (lru_write_cacheline(0 to 5) = "000110"))   = '1'
               else dir_row6_lru_read    when (iu2_lru_rd_update and iu2_ifar_eff_cacheline(0 to 5) = "000110")   = '1'
               else dir_row6_lru_l2;
dir_row7_lru_d    <=  dir_row7_lru_write   when (icm_icd_lru_write and (lru_write_cacheline(0 to 5) = "000111"))   = '1'
               else dir_row7_lru_read    when (iu2_lru_rd_update and iu2_ifar_eff_cacheline(0 to 5) = "000111")   = '1'
               else dir_row7_lru_l2;
dir_row8_lru_d    <=  dir_row8_lru_write   when (icm_icd_lru_write and (lru_write_cacheline(0 to 5) = "001000"))   = '1'
               else dir_row8_lru_read    when (iu2_lru_rd_update and iu2_ifar_eff_cacheline(0 to 5) = "001000")   = '1'
               else dir_row8_lru_l2;
dir_row9_lru_d    <=  dir_row9_lru_write   when (icm_icd_lru_write and (lru_write_cacheline(0 to 5) = "001001"))   = '1'
               else dir_row9_lru_read    when (iu2_lru_rd_update and iu2_ifar_eff_cacheline(0 to 5) = "001001")   = '1'
               else dir_row9_lru_l2;
dir_row10_lru_d   <=  dir_row10_lru_write  when (icm_icd_lru_write and (lru_write_cacheline(0 to 5) = "001010"))  = '1'
               else dir_row10_lru_read   when (iu2_lru_rd_update and iu2_ifar_eff_cacheline(0 to 5) = "001010")  = '1'
               else dir_row10_lru_l2;
dir_row11_lru_d   <=  dir_row11_lru_write  when (icm_icd_lru_write and (lru_write_cacheline(0 to 5) = "001011"))  = '1'
               else dir_row11_lru_read   when (iu2_lru_rd_update and iu2_ifar_eff_cacheline(0 to 5) = "001011")  = '1'
               else dir_row11_lru_l2;
dir_row12_lru_d   <=  dir_row12_lru_write  when (icm_icd_lru_write and (lru_write_cacheline(0 to 5) = "001100"))  = '1'
               else dir_row12_lru_read   when (iu2_lru_rd_update and iu2_ifar_eff_cacheline(0 to 5) = "001100")  = '1'
               else dir_row12_lru_l2;
dir_row13_lru_d   <=  dir_row13_lru_write  when (icm_icd_lru_write and (lru_write_cacheline(0 to 5) = "001101"))  = '1'
               else dir_row13_lru_read   when (iu2_lru_rd_update and iu2_ifar_eff_cacheline(0 to 5) = "001101")  = '1'
               else dir_row13_lru_l2;
dir_row14_lru_d   <=  dir_row14_lru_write  when (icm_icd_lru_write and (lru_write_cacheline(0 to 5) = "001110"))  = '1'
               else dir_row14_lru_read   when (iu2_lru_rd_update and iu2_ifar_eff_cacheline(0 to 5) = "001110")  = '1'
               else dir_row14_lru_l2;
dir_row15_lru_d   <=  dir_row15_lru_write  when (icm_icd_lru_write and (lru_write_cacheline(0 to 5) = "001111"))  = '1'
               else dir_row15_lru_read   when (iu2_lru_rd_update and iu2_ifar_eff_cacheline(0 to 5) = "001111")  = '1'
               else dir_row15_lru_l2;
dir_row16_lru_d   <=  dir_row16_lru_write  when (icm_icd_lru_write and (lru_write_cacheline(0 to 5) = "010000"))  = '1'
               else dir_row16_lru_read   when (iu2_lru_rd_update and iu2_ifar_eff_cacheline(0 to 5) = "010000")  = '1'
               else dir_row16_lru_l2;
dir_row17_lru_d   <=  dir_row17_lru_write  when (icm_icd_lru_write and (lru_write_cacheline(0 to 5) = "010001"))  = '1'
               else dir_row17_lru_read   when (iu2_lru_rd_update and iu2_ifar_eff_cacheline(0 to 5) = "010001")  = '1'
               else dir_row17_lru_l2;
dir_row18_lru_d   <=  dir_row18_lru_write  when (icm_icd_lru_write and (lru_write_cacheline(0 to 5) = "010010"))  = '1'
               else dir_row18_lru_read   when (iu2_lru_rd_update and iu2_ifar_eff_cacheline(0 to 5) = "010010")  = '1'
               else dir_row18_lru_l2;
dir_row19_lru_d   <=  dir_row19_lru_write  when (icm_icd_lru_write and (lru_write_cacheline(0 to 5) = "010011"))  = '1'
               else dir_row19_lru_read   when (iu2_lru_rd_update and iu2_ifar_eff_cacheline(0 to 5) = "010011")  = '1'
               else dir_row19_lru_l2;
dir_row20_lru_d   <=  dir_row20_lru_write  when (icm_icd_lru_write and (lru_write_cacheline(0 to 5) = "010100"))  = '1'
               else dir_row20_lru_read   when (iu2_lru_rd_update and iu2_ifar_eff_cacheline(0 to 5) = "010100")  = '1'
               else dir_row20_lru_l2;
dir_row21_lru_d   <=  dir_row21_lru_write  when (icm_icd_lru_write and (lru_write_cacheline(0 to 5) = "010101"))  = '1'
               else dir_row21_lru_read   when (iu2_lru_rd_update and iu2_ifar_eff_cacheline(0 to 5) = "010101")  = '1'
               else dir_row21_lru_l2;
dir_row22_lru_d   <=  dir_row22_lru_write  when (icm_icd_lru_write and (lru_write_cacheline(0 to 5) = "010110"))  = '1'
               else dir_row22_lru_read   when (iu2_lru_rd_update and iu2_ifar_eff_cacheline(0 to 5) = "010110")  = '1'
               else dir_row22_lru_l2;
dir_row23_lru_d   <=  dir_row23_lru_write  when (icm_icd_lru_write and (lru_write_cacheline(0 to 5) = "010111"))  = '1'
               else dir_row23_lru_read   when (iu2_lru_rd_update and iu2_ifar_eff_cacheline(0 to 5) = "010111")  = '1'
               else dir_row23_lru_l2;
dir_row24_lru_d   <=  dir_row24_lru_write  when (icm_icd_lru_write and (lru_write_cacheline(0 to 5) = "011000"))  = '1'
               else dir_row24_lru_read   when (iu2_lru_rd_update and iu2_ifar_eff_cacheline(0 to 5) = "011000")  = '1'
               else dir_row24_lru_l2;
dir_row25_lru_d   <=  dir_row25_lru_write  when (icm_icd_lru_write and (lru_write_cacheline(0 to 5) = "011001"))  = '1'
               else dir_row25_lru_read   when (iu2_lru_rd_update and iu2_ifar_eff_cacheline(0 to 5) = "011001")  = '1'
               else dir_row25_lru_l2;
dir_row26_lru_d   <=  dir_row26_lru_write  when (icm_icd_lru_write and (lru_write_cacheline(0 to 5) = "011010"))  = '1'
               else dir_row26_lru_read   when (iu2_lru_rd_update and iu2_ifar_eff_cacheline(0 to 5) = "011010")  = '1'
               else dir_row26_lru_l2;
dir_row27_lru_d   <=  dir_row27_lru_write  when (icm_icd_lru_write and (lru_write_cacheline(0 to 5) = "011011"))  = '1'
               else dir_row27_lru_read   when (iu2_lru_rd_update and iu2_ifar_eff_cacheline(0 to 5) = "011011")  = '1'
               else dir_row27_lru_l2;
dir_row28_lru_d   <=  dir_row28_lru_write  when (icm_icd_lru_write and (lru_write_cacheline(0 to 5) = "011100"))  = '1'
               else dir_row28_lru_read   when (iu2_lru_rd_update and iu2_ifar_eff_cacheline(0 to 5) = "011100")  = '1'
               else dir_row28_lru_l2;
dir_row29_lru_d   <=  dir_row29_lru_write  when (icm_icd_lru_write and (lru_write_cacheline(0 to 5) = "011101"))  = '1'
               else dir_row29_lru_read   when (iu2_lru_rd_update and iu2_ifar_eff_cacheline(0 to 5) = "011101")  = '1'
               else dir_row29_lru_l2;
dir_row30_lru_d   <=  dir_row30_lru_write  when (icm_icd_lru_write and (lru_write_cacheline(0 to 5) = "011110"))  = '1'
               else dir_row30_lru_read   when (iu2_lru_rd_update and iu2_ifar_eff_cacheline(0 to 5) = "011110")  = '1'
               else dir_row30_lru_l2;
dir_row31_lru_d   <=  dir_row31_lru_write  when (icm_icd_lru_write and (lru_write_cacheline(0 to 5) = "011111"))  = '1'
               else dir_row31_lru_read   when (iu2_lru_rd_update and iu2_ifar_eff_cacheline(0 to 5) = "011111")  = '1'
               else dir_row31_lru_l2;
dir_row32_lru_d   <=  dir_row32_lru_write  when (icm_icd_lru_write and (lru_write_cacheline(0 to 5) = "100000"))  = '1'
               else dir_row32_lru_read   when (iu2_lru_rd_update and iu2_ifar_eff_cacheline(0 to 5) = "100000")  = '1'
               else dir_row32_lru_l2;
dir_row33_lru_d   <=  dir_row33_lru_write  when (icm_icd_lru_write and (lru_write_cacheline(0 to 5) = "100001"))  = '1'
               else dir_row33_lru_read   when (iu2_lru_rd_update and iu2_ifar_eff_cacheline(0 to 5) = "100001")  = '1'
               else dir_row33_lru_l2;
dir_row34_lru_d   <=  dir_row34_lru_write  when (icm_icd_lru_write and (lru_write_cacheline(0 to 5) = "100010"))  = '1'
               else dir_row34_lru_read   when (iu2_lru_rd_update and iu2_ifar_eff_cacheline(0 to 5) = "100010")  = '1'
               else dir_row34_lru_l2;
dir_row35_lru_d   <=  dir_row35_lru_write  when (icm_icd_lru_write and (lru_write_cacheline(0 to 5) = "100011"))  = '1'
               else dir_row35_lru_read   when (iu2_lru_rd_update and iu2_ifar_eff_cacheline(0 to 5) = "100011")  = '1'
               else dir_row35_lru_l2;
dir_row36_lru_d   <=  dir_row36_lru_write  when (icm_icd_lru_write and (lru_write_cacheline(0 to 5) = "100100"))  = '1'
               else dir_row36_lru_read   when (iu2_lru_rd_update and iu2_ifar_eff_cacheline(0 to 5) = "100100")  = '1'
               else dir_row36_lru_l2;
dir_row37_lru_d   <=  dir_row37_lru_write  when (icm_icd_lru_write and (lru_write_cacheline(0 to 5) = "100101"))  = '1'
               else dir_row37_lru_read   when (iu2_lru_rd_update and iu2_ifar_eff_cacheline(0 to 5) = "100101")  = '1'
               else dir_row37_lru_l2;
dir_row38_lru_d   <=  dir_row38_lru_write  when (icm_icd_lru_write and (lru_write_cacheline(0 to 5) = "100110"))  = '1'
               else dir_row38_lru_read   when (iu2_lru_rd_update and iu2_ifar_eff_cacheline(0 to 5) = "100110")  = '1'
               else dir_row38_lru_l2;
dir_row39_lru_d   <=  dir_row39_lru_write  when (icm_icd_lru_write and (lru_write_cacheline(0 to 5) = "100111"))  = '1'
               else dir_row39_lru_read   when (iu2_lru_rd_update and iu2_ifar_eff_cacheline(0 to 5) = "100111")  = '1'
               else dir_row39_lru_l2;
dir_row40_lru_d   <=  dir_row40_lru_write  when (icm_icd_lru_write and (lru_write_cacheline(0 to 5) = "101000"))  = '1'
               else dir_row40_lru_read   when (iu2_lru_rd_update and iu2_ifar_eff_cacheline(0 to 5) = "101000")  = '1'
               else dir_row40_lru_l2;
dir_row41_lru_d   <=  dir_row41_lru_write  when (icm_icd_lru_write and (lru_write_cacheline(0 to 5) = "101001"))  = '1'
               else dir_row41_lru_read   when (iu2_lru_rd_update and iu2_ifar_eff_cacheline(0 to 5) = "101001")  = '1'
               else dir_row41_lru_l2;
dir_row42_lru_d   <=  dir_row42_lru_write  when (icm_icd_lru_write and (lru_write_cacheline(0 to 5) = "101010"))  = '1'
               else dir_row42_lru_read   when (iu2_lru_rd_update and iu2_ifar_eff_cacheline(0 to 5) = "101010")  = '1'
               else dir_row42_lru_l2;
dir_row43_lru_d   <=  dir_row43_lru_write  when (icm_icd_lru_write and (lru_write_cacheline(0 to 5) = "101011"))  = '1'
               else dir_row43_lru_read   when (iu2_lru_rd_update and iu2_ifar_eff_cacheline(0 to 5) = "101011")  = '1'
               else dir_row43_lru_l2;
dir_row44_lru_d   <=  dir_row44_lru_write  when (icm_icd_lru_write and (lru_write_cacheline(0 to 5) = "101100"))  = '1'
               else dir_row44_lru_read   when (iu2_lru_rd_update and iu2_ifar_eff_cacheline(0 to 5) = "101100")  = '1'
               else dir_row44_lru_l2;
dir_row45_lru_d   <=  dir_row45_lru_write  when (icm_icd_lru_write and (lru_write_cacheline(0 to 5) = "101101"))  = '1'
               else dir_row45_lru_read   when (iu2_lru_rd_update and iu2_ifar_eff_cacheline(0 to 5) = "101101")  = '1'
               else dir_row45_lru_l2;
dir_row46_lru_d   <=  dir_row46_lru_write  when (icm_icd_lru_write and (lru_write_cacheline(0 to 5) = "101110"))  = '1'
               else dir_row46_lru_read   when (iu2_lru_rd_update and iu2_ifar_eff_cacheline(0 to 5) = "101110")  = '1'
               else dir_row46_lru_l2;
dir_row47_lru_d   <=  dir_row47_lru_write  when (icm_icd_lru_write and (lru_write_cacheline(0 to 5) = "101111"))  = '1'
               else dir_row47_lru_read   when (iu2_lru_rd_update and iu2_ifar_eff_cacheline(0 to 5) = "101111")  = '1'
               else dir_row47_lru_l2;
dir_row48_lru_d   <=  dir_row48_lru_write  when (icm_icd_lru_write and (lru_write_cacheline(0 to 5) = "110000"))  = '1'
               else dir_row48_lru_read   when (iu2_lru_rd_update and iu2_ifar_eff_cacheline(0 to 5) = "110000")  = '1'
               else dir_row48_lru_l2;
dir_row49_lru_d   <=  dir_row49_lru_write  when (icm_icd_lru_write and (lru_write_cacheline(0 to 5) = "110001"))  = '1'
               else dir_row49_lru_read   when (iu2_lru_rd_update and iu2_ifar_eff_cacheline(0 to 5) = "110001")  = '1'
               else dir_row49_lru_l2;
dir_row50_lru_d   <=  dir_row50_lru_write  when (icm_icd_lru_write and (lru_write_cacheline(0 to 5) = "110010"))  = '1'
               else dir_row50_lru_read   when (iu2_lru_rd_update and iu2_ifar_eff_cacheline(0 to 5) = "110010")  = '1'
               else dir_row50_lru_l2;
dir_row51_lru_d   <=  dir_row51_lru_write  when (icm_icd_lru_write and (lru_write_cacheline(0 to 5) = "110011"))  = '1'
               else dir_row51_lru_read   when (iu2_lru_rd_update and iu2_ifar_eff_cacheline(0 to 5) = "110011")  = '1'
               else dir_row51_lru_l2;
dir_row52_lru_d   <=  dir_row52_lru_write  when (icm_icd_lru_write and (lru_write_cacheline(0 to 5) = "110100"))  = '1'
               else dir_row52_lru_read   when (iu2_lru_rd_update and iu2_ifar_eff_cacheline(0 to 5) = "110100")  = '1'
               else dir_row52_lru_l2;
dir_row53_lru_d   <=  dir_row53_lru_write  when (icm_icd_lru_write and (lru_write_cacheline(0 to 5) = "110101"))  = '1'
               else dir_row53_lru_read   when (iu2_lru_rd_update and iu2_ifar_eff_cacheline(0 to 5) = "110101")  = '1'
               else dir_row53_lru_l2;
dir_row54_lru_d   <=  dir_row54_lru_write  when (icm_icd_lru_write and (lru_write_cacheline(0 to 5) = "110110"))  = '1'
               else dir_row54_lru_read   when (iu2_lru_rd_update and iu2_ifar_eff_cacheline(0 to 5) = "110110")  = '1'
               else dir_row54_lru_l2;
dir_row55_lru_d   <=  dir_row55_lru_write  when (icm_icd_lru_write and (lru_write_cacheline(0 to 5) = "110111"))  = '1'
               else dir_row55_lru_read   when (iu2_lru_rd_update and iu2_ifar_eff_cacheline(0 to 5) = "110111")  = '1'
               else dir_row55_lru_l2;
dir_row56_lru_d   <=  dir_row56_lru_write  when (icm_icd_lru_write and (lru_write_cacheline(0 to 5) = "111000"))  = '1'
               else dir_row56_lru_read   when (iu2_lru_rd_update and iu2_ifar_eff_cacheline(0 to 5) = "111000")  = '1'
               else dir_row56_lru_l2;
dir_row57_lru_d   <=  dir_row57_lru_write  when (icm_icd_lru_write and (lru_write_cacheline(0 to 5) = "111001"))  = '1'
               else dir_row57_lru_read   when (iu2_lru_rd_update and iu2_ifar_eff_cacheline(0 to 5) = "111001")  = '1'
               else dir_row57_lru_l2;
dir_row58_lru_d   <=  dir_row58_lru_write  when (icm_icd_lru_write and (lru_write_cacheline(0 to 5) = "111010"))  = '1'
               else dir_row58_lru_read   when (iu2_lru_rd_update and iu2_ifar_eff_cacheline(0 to 5) = "111010")  = '1'
               else dir_row58_lru_l2;
dir_row59_lru_d   <=  dir_row59_lru_write  when (icm_icd_lru_write and (lru_write_cacheline(0 to 5) = "111011"))  = '1'
               else dir_row59_lru_read   when (iu2_lru_rd_update and iu2_ifar_eff_cacheline(0 to 5) = "111011")  = '1'
               else dir_row59_lru_l2;
dir_row60_lru_d   <=  dir_row60_lru_write  when (icm_icd_lru_write and (lru_write_cacheline(0 to 5) = "111100"))  = '1'
               else dir_row60_lru_read   when (iu2_lru_rd_update and iu2_ifar_eff_cacheline(0 to 5) = "111100")  = '1'
               else dir_row60_lru_l2;
dir_row61_lru_d   <=  dir_row61_lru_write  when (icm_icd_lru_write and (lru_write_cacheline(0 to 5) = "111101"))  = '1'
               else dir_row61_lru_read   when (iu2_lru_rd_update and iu2_ifar_eff_cacheline(0 to 5) = "111101")  = '1'
               else dir_row61_lru_l2;
dir_row62_lru_d   <=  dir_row62_lru_write  when (icm_icd_lru_write and (lru_write_cacheline(0 to 5) = "111110"))  = '1'
               else dir_row62_lru_read   when (iu2_lru_rd_update and iu2_ifar_eff_cacheline(0 to 5) = "111110")  = '1'
               else dir_row62_lru_l2;
dir_row63_lru_d   <=  dir_row63_lru_write  when (icm_icd_lru_write and (lru_write_cacheline(0 to 5) = "111111"))  = '1'
               else dir_row63_lru_read   when (iu2_lru_rd_update and iu2_ifar_eff_cacheline(0 to 5) = "111111")  = '1'
               else dir_row63_lru_l2;
dir_row_lru_even_act  <=  (icm_icd_lru_write and lru_write_cacheline(5) = '0') or
                        (iu2_valid_l2 and iu2_ifar_eff_cacheline(5) = '0');
dir_row_lru_odd_act   <=  (icm_icd_lru_write and lru_write_cacheline(5) = '1') or
                        (iu2_valid_l2 and iu2_ifar_eff_cacheline(5) = '1');
-- All erat errors except for erat parity error, for timing
iu2_erat_err_lite  <=  ierat_iu_iu2_miss or ierat_iu_iu2_multihit or ierat_iu_iu2_isi;
iu2_lru_rd_update  <=  iu2_valid and not iu2_erat_err_lite and or_reduce(iu2_rd_way_hit(0 to 3));
dir_row0_lru_read    <=  gate_and(iu2_rd_way_hit(0), ("11" & dir_row0_lru_l2(2)))   or
                       gate_and(iu2_rd_way_hit(1), ("10" & dir_row0_lru_l2(2)))   or
                       gate_and(iu2_rd_way_hit(2), ('0' & dir_row0_lru_l2(1)   & '1')) or
                       gate_and(iu2_rd_way_hit(3), ('0' & dir_row0_lru_l2(1)   & '0'));
dir_row1_lru_read    <=  gate_and(iu2_rd_way_hit(0), ("11" & dir_row1_lru_l2(2)))   or
                       gate_and(iu2_rd_way_hit(1), ("10" & dir_row1_lru_l2(2)))   or
                       gate_and(iu2_rd_way_hit(2), ('0' & dir_row1_lru_l2(1)   & '1')) or
                       gate_and(iu2_rd_way_hit(3), ('0' & dir_row1_lru_l2(1)   & '0'));
dir_row2_lru_read    <=  gate_and(iu2_rd_way_hit(0), ("11" & dir_row2_lru_l2(2)))   or
                       gate_and(iu2_rd_way_hit(1), ("10" & dir_row2_lru_l2(2)))   or
                       gate_and(iu2_rd_way_hit(2), ('0' & dir_row2_lru_l2(1)   & '1')) or
                       gate_and(iu2_rd_way_hit(3), ('0' & dir_row2_lru_l2(1)   & '0'));
dir_row3_lru_read    <=  gate_and(iu2_rd_way_hit(0), ("11" & dir_row3_lru_l2(2)))   or
                       gate_and(iu2_rd_way_hit(1), ("10" & dir_row3_lru_l2(2)))   or
                       gate_and(iu2_rd_way_hit(2), ('0' & dir_row3_lru_l2(1)   & '1')) or
                       gate_and(iu2_rd_way_hit(3), ('0' & dir_row3_lru_l2(1)   & '0'));
dir_row4_lru_read    <=  gate_and(iu2_rd_way_hit(0), ("11" & dir_row4_lru_l2(2)))   or
                       gate_and(iu2_rd_way_hit(1), ("10" & dir_row4_lru_l2(2)))   or
                       gate_and(iu2_rd_way_hit(2), ('0' & dir_row4_lru_l2(1)   & '1')) or
                       gate_and(iu2_rd_way_hit(3), ('0' & dir_row4_lru_l2(1)   & '0'));
dir_row5_lru_read    <=  gate_and(iu2_rd_way_hit(0), ("11" & dir_row5_lru_l2(2)))   or
                       gate_and(iu2_rd_way_hit(1), ("10" & dir_row5_lru_l2(2)))   or
                       gate_and(iu2_rd_way_hit(2), ('0' & dir_row5_lru_l2(1)   & '1')) or
                       gate_and(iu2_rd_way_hit(3), ('0' & dir_row5_lru_l2(1)   & '0'));
dir_row6_lru_read    <=  gate_and(iu2_rd_way_hit(0), ("11" & dir_row6_lru_l2(2)))   or
                       gate_and(iu2_rd_way_hit(1), ("10" & dir_row6_lru_l2(2)))   or
                       gate_and(iu2_rd_way_hit(2), ('0' & dir_row6_lru_l2(1)   & '1')) or
                       gate_and(iu2_rd_way_hit(3), ('0' & dir_row6_lru_l2(1)   & '0'));
dir_row7_lru_read    <=  gate_and(iu2_rd_way_hit(0), ("11" & dir_row7_lru_l2(2)))   or
                       gate_and(iu2_rd_way_hit(1), ("10" & dir_row7_lru_l2(2)))   or
                       gate_and(iu2_rd_way_hit(2), ('0' & dir_row7_lru_l2(1)   & '1')) or
                       gate_and(iu2_rd_way_hit(3), ('0' & dir_row7_lru_l2(1)   & '0'));
dir_row8_lru_read    <=  gate_and(iu2_rd_way_hit(0), ("11" & dir_row8_lru_l2(2)))   or
                       gate_and(iu2_rd_way_hit(1), ("10" & dir_row8_lru_l2(2)))   or
                       gate_and(iu2_rd_way_hit(2), ('0' & dir_row8_lru_l2(1)   & '1')) or
                       gate_and(iu2_rd_way_hit(3), ('0' & dir_row8_lru_l2(1)   & '0'));
dir_row9_lru_read    <=  gate_and(iu2_rd_way_hit(0), ("11" & dir_row9_lru_l2(2)))   or
                       gate_and(iu2_rd_way_hit(1), ("10" & dir_row9_lru_l2(2)))   or
                       gate_and(iu2_rd_way_hit(2), ('0' & dir_row9_lru_l2(1)   & '1')) or
                       gate_and(iu2_rd_way_hit(3), ('0' & dir_row9_lru_l2(1)   & '0'));
dir_row10_lru_read   <=  gate_and(iu2_rd_way_hit(0), ("11" & dir_row10_lru_l2(2)))  or
                       gate_and(iu2_rd_way_hit(1), ("10" & dir_row10_lru_l2(2)))  or
                       gate_and(iu2_rd_way_hit(2), ('0' & dir_row10_lru_l2(1)  & '1')) or
                       gate_and(iu2_rd_way_hit(3), ('0' & dir_row10_lru_l2(1)  & '0'));
dir_row11_lru_read   <=  gate_and(iu2_rd_way_hit(0), ("11" & dir_row11_lru_l2(2)))  or
                       gate_and(iu2_rd_way_hit(1), ("10" & dir_row11_lru_l2(2)))  or
                       gate_and(iu2_rd_way_hit(2), ('0' & dir_row11_lru_l2(1)  & '1')) or
                       gate_and(iu2_rd_way_hit(3), ('0' & dir_row11_lru_l2(1)  & '0'));
dir_row12_lru_read   <=  gate_and(iu2_rd_way_hit(0), ("11" & dir_row12_lru_l2(2)))  or
                       gate_and(iu2_rd_way_hit(1), ("10" & dir_row12_lru_l2(2)))  or
                       gate_and(iu2_rd_way_hit(2), ('0' & dir_row12_lru_l2(1)  & '1')) or
                       gate_and(iu2_rd_way_hit(3), ('0' & dir_row12_lru_l2(1)  & '0'));
dir_row13_lru_read   <=  gate_and(iu2_rd_way_hit(0), ("11" & dir_row13_lru_l2(2)))  or
                       gate_and(iu2_rd_way_hit(1), ("10" & dir_row13_lru_l2(2)))  or
                       gate_and(iu2_rd_way_hit(2), ('0' & dir_row13_lru_l2(1)  & '1')) or
                       gate_and(iu2_rd_way_hit(3), ('0' & dir_row13_lru_l2(1)  & '0'));
dir_row14_lru_read   <=  gate_and(iu2_rd_way_hit(0), ("11" & dir_row14_lru_l2(2)))  or
                       gate_and(iu2_rd_way_hit(1), ("10" & dir_row14_lru_l2(2)))  or
                       gate_and(iu2_rd_way_hit(2), ('0' & dir_row14_lru_l2(1)  & '1')) or
                       gate_and(iu2_rd_way_hit(3), ('0' & dir_row14_lru_l2(1)  & '0'));
dir_row15_lru_read   <=  gate_and(iu2_rd_way_hit(0), ("11" & dir_row15_lru_l2(2)))  or
                       gate_and(iu2_rd_way_hit(1), ("10" & dir_row15_lru_l2(2)))  or
                       gate_and(iu2_rd_way_hit(2), ('0' & dir_row15_lru_l2(1)  & '1')) or
                       gate_and(iu2_rd_way_hit(3), ('0' & dir_row15_lru_l2(1)  & '0'));
dir_row16_lru_read   <=  gate_and(iu2_rd_way_hit(0), ("11" & dir_row16_lru_l2(2)))  or
                       gate_and(iu2_rd_way_hit(1), ("10" & dir_row16_lru_l2(2)))  or
                       gate_and(iu2_rd_way_hit(2), ('0' & dir_row16_lru_l2(1)  & '1')) or
                       gate_and(iu2_rd_way_hit(3), ('0' & dir_row16_lru_l2(1)  & '0'));
dir_row17_lru_read   <=  gate_and(iu2_rd_way_hit(0), ("11" & dir_row17_lru_l2(2)))  or
                       gate_and(iu2_rd_way_hit(1), ("10" & dir_row17_lru_l2(2)))  or
                       gate_and(iu2_rd_way_hit(2), ('0' & dir_row17_lru_l2(1)  & '1')) or
                       gate_and(iu2_rd_way_hit(3), ('0' & dir_row17_lru_l2(1)  & '0'));
dir_row18_lru_read   <=  gate_and(iu2_rd_way_hit(0), ("11" & dir_row18_lru_l2(2)))  or
                       gate_and(iu2_rd_way_hit(1), ("10" & dir_row18_lru_l2(2)))  or
                       gate_and(iu2_rd_way_hit(2), ('0' & dir_row18_lru_l2(1)  & '1')) or
                       gate_and(iu2_rd_way_hit(3), ('0' & dir_row18_lru_l2(1)  & '0'));
dir_row19_lru_read   <=  gate_and(iu2_rd_way_hit(0), ("11" & dir_row19_lru_l2(2)))  or
                       gate_and(iu2_rd_way_hit(1), ("10" & dir_row19_lru_l2(2)))  or
                       gate_and(iu2_rd_way_hit(2), ('0' & dir_row19_lru_l2(1)  & '1')) or
                       gate_and(iu2_rd_way_hit(3), ('0' & dir_row19_lru_l2(1)  & '0'));
dir_row20_lru_read   <=  gate_and(iu2_rd_way_hit(0), ("11" & dir_row20_lru_l2(2)))  or
                       gate_and(iu2_rd_way_hit(1), ("10" & dir_row20_lru_l2(2)))  or
                       gate_and(iu2_rd_way_hit(2), ('0' & dir_row20_lru_l2(1)  & '1')) or
                       gate_and(iu2_rd_way_hit(3), ('0' & dir_row20_lru_l2(1)  & '0'));
dir_row21_lru_read   <=  gate_and(iu2_rd_way_hit(0), ("11" & dir_row21_lru_l2(2)))  or
                       gate_and(iu2_rd_way_hit(1), ("10" & dir_row21_lru_l2(2)))  or
                       gate_and(iu2_rd_way_hit(2), ('0' & dir_row21_lru_l2(1)  & '1')) or
                       gate_and(iu2_rd_way_hit(3), ('0' & dir_row21_lru_l2(1)  & '0'));
dir_row22_lru_read   <=  gate_and(iu2_rd_way_hit(0), ("11" & dir_row22_lru_l2(2)))  or
                       gate_and(iu2_rd_way_hit(1), ("10" & dir_row22_lru_l2(2)))  or
                       gate_and(iu2_rd_way_hit(2), ('0' & dir_row22_lru_l2(1)  & '1')) or
                       gate_and(iu2_rd_way_hit(3), ('0' & dir_row22_lru_l2(1)  & '0'));
dir_row23_lru_read   <=  gate_and(iu2_rd_way_hit(0), ("11" & dir_row23_lru_l2(2)))  or
                       gate_and(iu2_rd_way_hit(1), ("10" & dir_row23_lru_l2(2)))  or
                       gate_and(iu2_rd_way_hit(2), ('0' & dir_row23_lru_l2(1)  & '1')) or
                       gate_and(iu2_rd_way_hit(3), ('0' & dir_row23_lru_l2(1)  & '0'));
dir_row24_lru_read   <=  gate_and(iu2_rd_way_hit(0), ("11" & dir_row24_lru_l2(2)))  or
                       gate_and(iu2_rd_way_hit(1), ("10" & dir_row24_lru_l2(2)))  or
                       gate_and(iu2_rd_way_hit(2), ('0' & dir_row24_lru_l2(1)  & '1')) or
                       gate_and(iu2_rd_way_hit(3), ('0' & dir_row24_lru_l2(1)  & '0'));
dir_row25_lru_read   <=  gate_and(iu2_rd_way_hit(0), ("11" & dir_row25_lru_l2(2)))  or
                       gate_and(iu2_rd_way_hit(1), ("10" & dir_row25_lru_l2(2)))  or
                       gate_and(iu2_rd_way_hit(2), ('0' & dir_row25_lru_l2(1)  & '1')) or
                       gate_and(iu2_rd_way_hit(3), ('0' & dir_row25_lru_l2(1)  & '0'));
dir_row26_lru_read   <=  gate_and(iu2_rd_way_hit(0), ("11" & dir_row26_lru_l2(2)))  or
                       gate_and(iu2_rd_way_hit(1), ("10" & dir_row26_lru_l2(2)))  or
                       gate_and(iu2_rd_way_hit(2), ('0' & dir_row26_lru_l2(1)  & '1')) or
                       gate_and(iu2_rd_way_hit(3), ('0' & dir_row26_lru_l2(1)  & '0'));
dir_row27_lru_read   <=  gate_and(iu2_rd_way_hit(0), ("11" & dir_row27_lru_l2(2)))  or
                       gate_and(iu2_rd_way_hit(1), ("10" & dir_row27_lru_l2(2)))  or
                       gate_and(iu2_rd_way_hit(2), ('0' & dir_row27_lru_l2(1)  & '1')) or
                       gate_and(iu2_rd_way_hit(3), ('0' & dir_row27_lru_l2(1)  & '0'));
dir_row28_lru_read   <=  gate_and(iu2_rd_way_hit(0), ("11" & dir_row28_lru_l2(2)))  or
                       gate_and(iu2_rd_way_hit(1), ("10" & dir_row28_lru_l2(2)))  or
                       gate_and(iu2_rd_way_hit(2), ('0' & dir_row28_lru_l2(1)  & '1')) or
                       gate_and(iu2_rd_way_hit(3), ('0' & dir_row28_lru_l2(1)  & '0'));
dir_row29_lru_read   <=  gate_and(iu2_rd_way_hit(0), ("11" & dir_row29_lru_l2(2)))  or
                       gate_and(iu2_rd_way_hit(1), ("10" & dir_row29_lru_l2(2)))  or
                       gate_and(iu2_rd_way_hit(2), ('0' & dir_row29_lru_l2(1)  & '1')) or
                       gate_and(iu2_rd_way_hit(3), ('0' & dir_row29_lru_l2(1)  & '0'));
dir_row30_lru_read   <=  gate_and(iu2_rd_way_hit(0), ("11" & dir_row30_lru_l2(2)))  or
                       gate_and(iu2_rd_way_hit(1), ("10" & dir_row30_lru_l2(2)))  or
                       gate_and(iu2_rd_way_hit(2), ('0' & dir_row30_lru_l2(1)  & '1')) or
                       gate_and(iu2_rd_way_hit(3), ('0' & dir_row30_lru_l2(1)  & '0'));
dir_row31_lru_read   <=  gate_and(iu2_rd_way_hit(0), ("11" & dir_row31_lru_l2(2)))  or
                       gate_and(iu2_rd_way_hit(1), ("10" & dir_row31_lru_l2(2)))  or
                       gate_and(iu2_rd_way_hit(2), ('0' & dir_row31_lru_l2(1)  & '1')) or
                       gate_and(iu2_rd_way_hit(3), ('0' & dir_row31_lru_l2(1)  & '0'));
dir_row32_lru_read   <=  gate_and(iu2_rd_way_hit(0), ("11" & dir_row32_lru_l2(2)))  or
                       gate_and(iu2_rd_way_hit(1), ("10" & dir_row32_lru_l2(2)))  or
                       gate_and(iu2_rd_way_hit(2), ('0' & dir_row32_lru_l2(1)  & '1')) or
                       gate_and(iu2_rd_way_hit(3), ('0' & dir_row32_lru_l2(1)  & '0'));
dir_row33_lru_read   <=  gate_and(iu2_rd_way_hit(0), ("11" & dir_row33_lru_l2(2)))  or
                       gate_and(iu2_rd_way_hit(1), ("10" & dir_row33_lru_l2(2)))  or
                       gate_and(iu2_rd_way_hit(2), ('0' & dir_row33_lru_l2(1)  & '1')) or
                       gate_and(iu2_rd_way_hit(3), ('0' & dir_row33_lru_l2(1)  & '0'));
dir_row34_lru_read   <=  gate_and(iu2_rd_way_hit(0), ("11" & dir_row34_lru_l2(2)))  or
                       gate_and(iu2_rd_way_hit(1), ("10" & dir_row34_lru_l2(2)))  or
                       gate_and(iu2_rd_way_hit(2), ('0' & dir_row34_lru_l2(1)  & '1')) or
                       gate_and(iu2_rd_way_hit(3), ('0' & dir_row34_lru_l2(1)  & '0'));
dir_row35_lru_read   <=  gate_and(iu2_rd_way_hit(0), ("11" & dir_row35_lru_l2(2)))  or
                       gate_and(iu2_rd_way_hit(1), ("10" & dir_row35_lru_l2(2)))  or
                       gate_and(iu2_rd_way_hit(2), ('0' & dir_row35_lru_l2(1)  & '1')) or
                       gate_and(iu2_rd_way_hit(3), ('0' & dir_row35_lru_l2(1)  & '0'));
dir_row36_lru_read   <=  gate_and(iu2_rd_way_hit(0), ("11" & dir_row36_lru_l2(2)))  or
                       gate_and(iu2_rd_way_hit(1), ("10" & dir_row36_lru_l2(2)))  or
                       gate_and(iu2_rd_way_hit(2), ('0' & dir_row36_lru_l2(1)  & '1')) or
                       gate_and(iu2_rd_way_hit(3), ('0' & dir_row36_lru_l2(1)  & '0'));
dir_row37_lru_read   <=  gate_and(iu2_rd_way_hit(0), ("11" & dir_row37_lru_l2(2)))  or
                       gate_and(iu2_rd_way_hit(1), ("10" & dir_row37_lru_l2(2)))  or
                       gate_and(iu2_rd_way_hit(2), ('0' & dir_row37_lru_l2(1)  & '1')) or
                       gate_and(iu2_rd_way_hit(3), ('0' & dir_row37_lru_l2(1)  & '0'));
dir_row38_lru_read   <=  gate_and(iu2_rd_way_hit(0), ("11" & dir_row38_lru_l2(2)))  or
                       gate_and(iu2_rd_way_hit(1), ("10" & dir_row38_lru_l2(2)))  or
                       gate_and(iu2_rd_way_hit(2), ('0' & dir_row38_lru_l2(1)  & '1')) or
                       gate_and(iu2_rd_way_hit(3), ('0' & dir_row38_lru_l2(1)  & '0'));
dir_row39_lru_read   <=  gate_and(iu2_rd_way_hit(0), ("11" & dir_row39_lru_l2(2)))  or
                       gate_and(iu2_rd_way_hit(1), ("10" & dir_row39_lru_l2(2)))  or
                       gate_and(iu2_rd_way_hit(2), ('0' & dir_row39_lru_l2(1)  & '1')) or
                       gate_and(iu2_rd_way_hit(3), ('0' & dir_row39_lru_l2(1)  & '0'));
dir_row40_lru_read   <=  gate_and(iu2_rd_way_hit(0), ("11" & dir_row40_lru_l2(2)))  or
                       gate_and(iu2_rd_way_hit(1), ("10" & dir_row40_lru_l2(2)))  or
                       gate_and(iu2_rd_way_hit(2), ('0' & dir_row40_lru_l2(1)  & '1')) or
                       gate_and(iu2_rd_way_hit(3), ('0' & dir_row40_lru_l2(1)  & '0'));
dir_row41_lru_read   <=  gate_and(iu2_rd_way_hit(0), ("11" & dir_row41_lru_l2(2)))  or
                       gate_and(iu2_rd_way_hit(1), ("10" & dir_row41_lru_l2(2)))  or
                       gate_and(iu2_rd_way_hit(2), ('0' & dir_row41_lru_l2(1)  & '1')) or
                       gate_and(iu2_rd_way_hit(3), ('0' & dir_row41_lru_l2(1)  & '0'));
dir_row42_lru_read   <=  gate_and(iu2_rd_way_hit(0), ("11" & dir_row42_lru_l2(2)))  or
                       gate_and(iu2_rd_way_hit(1), ("10" & dir_row42_lru_l2(2)))  or
                       gate_and(iu2_rd_way_hit(2), ('0' & dir_row42_lru_l2(1)  & '1')) or
                       gate_and(iu2_rd_way_hit(3), ('0' & dir_row42_lru_l2(1)  & '0'));
dir_row43_lru_read   <=  gate_and(iu2_rd_way_hit(0), ("11" & dir_row43_lru_l2(2)))  or
                       gate_and(iu2_rd_way_hit(1), ("10" & dir_row43_lru_l2(2)))  or
                       gate_and(iu2_rd_way_hit(2), ('0' & dir_row43_lru_l2(1)  & '1')) or
                       gate_and(iu2_rd_way_hit(3), ('0' & dir_row43_lru_l2(1)  & '0'));
dir_row44_lru_read   <=  gate_and(iu2_rd_way_hit(0), ("11" & dir_row44_lru_l2(2)))  or
                       gate_and(iu2_rd_way_hit(1), ("10" & dir_row44_lru_l2(2)))  or
                       gate_and(iu2_rd_way_hit(2), ('0' & dir_row44_lru_l2(1)  & '1')) or
                       gate_and(iu2_rd_way_hit(3), ('0' & dir_row44_lru_l2(1)  & '0'));
dir_row45_lru_read   <=  gate_and(iu2_rd_way_hit(0), ("11" & dir_row45_lru_l2(2)))  or
                       gate_and(iu2_rd_way_hit(1), ("10" & dir_row45_lru_l2(2)))  or
                       gate_and(iu2_rd_way_hit(2), ('0' & dir_row45_lru_l2(1)  & '1')) or
                       gate_and(iu2_rd_way_hit(3), ('0' & dir_row45_lru_l2(1)  & '0'));
dir_row46_lru_read   <=  gate_and(iu2_rd_way_hit(0), ("11" & dir_row46_lru_l2(2)))  or
                       gate_and(iu2_rd_way_hit(1), ("10" & dir_row46_lru_l2(2)))  or
                       gate_and(iu2_rd_way_hit(2), ('0' & dir_row46_lru_l2(1)  & '1')) or
                       gate_and(iu2_rd_way_hit(3), ('0' & dir_row46_lru_l2(1)  & '0'));
dir_row47_lru_read   <=  gate_and(iu2_rd_way_hit(0), ("11" & dir_row47_lru_l2(2)))  or
                       gate_and(iu2_rd_way_hit(1), ("10" & dir_row47_lru_l2(2)))  or
                       gate_and(iu2_rd_way_hit(2), ('0' & dir_row47_lru_l2(1)  & '1')) or
                       gate_and(iu2_rd_way_hit(3), ('0' & dir_row47_lru_l2(1)  & '0'));
dir_row48_lru_read   <=  gate_and(iu2_rd_way_hit(0), ("11" & dir_row48_lru_l2(2)))  or
                       gate_and(iu2_rd_way_hit(1), ("10" & dir_row48_lru_l2(2)))  or
                       gate_and(iu2_rd_way_hit(2), ('0' & dir_row48_lru_l2(1)  & '1')) or
                       gate_and(iu2_rd_way_hit(3), ('0' & dir_row48_lru_l2(1)  & '0'));
dir_row49_lru_read   <=  gate_and(iu2_rd_way_hit(0), ("11" & dir_row49_lru_l2(2)))  or
                       gate_and(iu2_rd_way_hit(1), ("10" & dir_row49_lru_l2(2)))  or
                       gate_and(iu2_rd_way_hit(2), ('0' & dir_row49_lru_l2(1)  & '1')) or
                       gate_and(iu2_rd_way_hit(3), ('0' & dir_row49_lru_l2(1)  & '0'));
dir_row50_lru_read   <=  gate_and(iu2_rd_way_hit(0), ("11" & dir_row50_lru_l2(2)))  or
                       gate_and(iu2_rd_way_hit(1), ("10" & dir_row50_lru_l2(2)))  or
                       gate_and(iu2_rd_way_hit(2), ('0' & dir_row50_lru_l2(1)  & '1')) or
                       gate_and(iu2_rd_way_hit(3), ('0' & dir_row50_lru_l2(1)  & '0'));
dir_row51_lru_read   <=  gate_and(iu2_rd_way_hit(0), ("11" & dir_row51_lru_l2(2)))  or
                       gate_and(iu2_rd_way_hit(1), ("10" & dir_row51_lru_l2(2)))  or
                       gate_and(iu2_rd_way_hit(2), ('0' & dir_row51_lru_l2(1)  & '1')) or
                       gate_and(iu2_rd_way_hit(3), ('0' & dir_row51_lru_l2(1)  & '0'));
dir_row52_lru_read   <=  gate_and(iu2_rd_way_hit(0), ("11" & dir_row52_lru_l2(2)))  or
                       gate_and(iu2_rd_way_hit(1), ("10" & dir_row52_lru_l2(2)))  or
                       gate_and(iu2_rd_way_hit(2), ('0' & dir_row52_lru_l2(1)  & '1')) or
                       gate_and(iu2_rd_way_hit(3), ('0' & dir_row52_lru_l2(1)  & '0'));
dir_row53_lru_read   <=  gate_and(iu2_rd_way_hit(0), ("11" & dir_row53_lru_l2(2)))  or
                       gate_and(iu2_rd_way_hit(1), ("10" & dir_row53_lru_l2(2)))  or
                       gate_and(iu2_rd_way_hit(2), ('0' & dir_row53_lru_l2(1)  & '1')) or
                       gate_and(iu2_rd_way_hit(3), ('0' & dir_row53_lru_l2(1)  & '0'));
dir_row54_lru_read   <=  gate_and(iu2_rd_way_hit(0), ("11" & dir_row54_lru_l2(2)))  or
                       gate_and(iu2_rd_way_hit(1), ("10" & dir_row54_lru_l2(2)))  or
                       gate_and(iu2_rd_way_hit(2), ('0' & dir_row54_lru_l2(1)  & '1')) or
                       gate_and(iu2_rd_way_hit(3), ('0' & dir_row54_lru_l2(1)  & '0'));
dir_row55_lru_read   <=  gate_and(iu2_rd_way_hit(0), ("11" & dir_row55_lru_l2(2)))  or
                       gate_and(iu2_rd_way_hit(1), ("10" & dir_row55_lru_l2(2)))  or
                       gate_and(iu2_rd_way_hit(2), ('0' & dir_row55_lru_l2(1)  & '1')) or
                       gate_and(iu2_rd_way_hit(3), ('0' & dir_row55_lru_l2(1)  & '0'));
dir_row56_lru_read   <=  gate_and(iu2_rd_way_hit(0), ("11" & dir_row56_lru_l2(2)))  or
                       gate_and(iu2_rd_way_hit(1), ("10" & dir_row56_lru_l2(2)))  or
                       gate_and(iu2_rd_way_hit(2), ('0' & dir_row56_lru_l2(1)  & '1')) or
                       gate_and(iu2_rd_way_hit(3), ('0' & dir_row56_lru_l2(1)  & '0'));
dir_row57_lru_read   <=  gate_and(iu2_rd_way_hit(0), ("11" & dir_row57_lru_l2(2)))  or
                       gate_and(iu2_rd_way_hit(1), ("10" & dir_row57_lru_l2(2)))  or
                       gate_and(iu2_rd_way_hit(2), ('0' & dir_row57_lru_l2(1)  & '1')) or
                       gate_and(iu2_rd_way_hit(3), ('0' & dir_row57_lru_l2(1)  & '0'));
dir_row58_lru_read   <=  gate_and(iu2_rd_way_hit(0), ("11" & dir_row58_lru_l2(2)))  or
                       gate_and(iu2_rd_way_hit(1), ("10" & dir_row58_lru_l2(2)))  or
                       gate_and(iu2_rd_way_hit(2), ('0' & dir_row58_lru_l2(1)  & '1')) or
                       gate_and(iu2_rd_way_hit(3), ('0' & dir_row58_lru_l2(1)  & '0'));
dir_row59_lru_read   <=  gate_and(iu2_rd_way_hit(0), ("11" & dir_row59_lru_l2(2)))  or
                       gate_and(iu2_rd_way_hit(1), ("10" & dir_row59_lru_l2(2)))  or
                       gate_and(iu2_rd_way_hit(2), ('0' & dir_row59_lru_l2(1)  & '1')) or
                       gate_and(iu2_rd_way_hit(3), ('0' & dir_row59_lru_l2(1)  & '0'));
dir_row60_lru_read   <=  gate_and(iu2_rd_way_hit(0), ("11" & dir_row60_lru_l2(2)))  or
                       gate_and(iu2_rd_way_hit(1), ("10" & dir_row60_lru_l2(2)))  or
                       gate_and(iu2_rd_way_hit(2), ('0' & dir_row60_lru_l2(1)  & '1')) or
                       gate_and(iu2_rd_way_hit(3), ('0' & dir_row60_lru_l2(1)  & '0'));
dir_row61_lru_read   <=  gate_and(iu2_rd_way_hit(0), ("11" & dir_row61_lru_l2(2)))  or
                       gate_and(iu2_rd_way_hit(1), ("10" & dir_row61_lru_l2(2)))  or
                       gate_and(iu2_rd_way_hit(2), ('0' & dir_row61_lru_l2(1)  & '1')) or
                       gate_and(iu2_rd_way_hit(3), ('0' & dir_row61_lru_l2(1)  & '0'));
dir_row62_lru_read   <=  gate_and(iu2_rd_way_hit(0), ("11" & dir_row62_lru_l2(2)))  or
                       gate_and(iu2_rd_way_hit(1), ("10" & dir_row62_lru_l2(2)))  or
                       gate_and(iu2_rd_way_hit(2), ('0' & dir_row62_lru_l2(1)  & '1')) or
                       gate_and(iu2_rd_way_hit(3), ('0' & dir_row62_lru_l2(1)  & '0'));
dir_row63_lru_read   <=  gate_and(iu2_rd_way_hit(0), ("11" & dir_row63_lru_l2(2)))  or
                       gate_and(iu2_rd_way_hit(1), ("10" & dir_row63_lru_l2(2)))  or
                       gate_and(iu2_rd_way_hit(2), ('0' & dir_row63_lru_l2(1)  & '1')) or
                       gate_and(iu2_rd_way_hit(3), ('0' & dir_row63_lru_l2(1)  & '0'));
dir_row0_lru_write    <=  gate_and(icm_icd_lru_write_way(0), ("11" & dir_row0_lru_l2(2)))   or
                        gate_and(icm_icd_lru_write_way(1), ("10" & dir_row0_lru_l2(2)))   or
                        gate_and(icm_icd_lru_write_way(2), ('0' & dir_row0_lru_l2(1)   & '1')) or
                        gate_and(icm_icd_lru_write_way(3), ('0' & dir_row0_lru_l2(1)   & '0'));
dir_row1_lru_write    <=  gate_and(icm_icd_lru_write_way(0), ("11" & dir_row1_lru_l2(2)))   or
                        gate_and(icm_icd_lru_write_way(1), ("10" & dir_row1_lru_l2(2)))   or
                        gate_and(icm_icd_lru_write_way(2), ('0' & dir_row1_lru_l2(1)   & '1')) or
                        gate_and(icm_icd_lru_write_way(3), ('0' & dir_row1_lru_l2(1)   & '0'));
dir_row2_lru_write    <=  gate_and(icm_icd_lru_write_way(0), ("11" & dir_row2_lru_l2(2)))   or
                        gate_and(icm_icd_lru_write_way(1), ("10" & dir_row2_lru_l2(2)))   or
                        gate_and(icm_icd_lru_write_way(2), ('0' & dir_row2_lru_l2(1)   & '1')) or
                        gate_and(icm_icd_lru_write_way(3), ('0' & dir_row2_lru_l2(1)   & '0'));
dir_row3_lru_write    <=  gate_and(icm_icd_lru_write_way(0), ("11" & dir_row3_lru_l2(2)))   or
                        gate_and(icm_icd_lru_write_way(1), ("10" & dir_row3_lru_l2(2)))   or
                        gate_and(icm_icd_lru_write_way(2), ('0' & dir_row3_lru_l2(1)   & '1')) or
                        gate_and(icm_icd_lru_write_way(3), ('0' & dir_row3_lru_l2(1)   & '0'));
dir_row4_lru_write    <=  gate_and(icm_icd_lru_write_way(0), ("11" & dir_row4_lru_l2(2)))   or
                        gate_and(icm_icd_lru_write_way(1), ("10" & dir_row4_lru_l2(2)))   or
                        gate_and(icm_icd_lru_write_way(2), ('0' & dir_row4_lru_l2(1)   & '1')) or
                        gate_and(icm_icd_lru_write_way(3), ('0' & dir_row4_lru_l2(1)   & '0'));
dir_row5_lru_write    <=  gate_and(icm_icd_lru_write_way(0), ("11" & dir_row5_lru_l2(2)))   or
                        gate_and(icm_icd_lru_write_way(1), ("10" & dir_row5_lru_l2(2)))   or
                        gate_and(icm_icd_lru_write_way(2), ('0' & dir_row5_lru_l2(1)   & '1')) or
                        gate_and(icm_icd_lru_write_way(3), ('0' & dir_row5_lru_l2(1)   & '0'));
dir_row6_lru_write    <=  gate_and(icm_icd_lru_write_way(0), ("11" & dir_row6_lru_l2(2)))   or
                        gate_and(icm_icd_lru_write_way(1), ("10" & dir_row6_lru_l2(2)))   or
                        gate_and(icm_icd_lru_write_way(2), ('0' & dir_row6_lru_l2(1)   & '1')) or
                        gate_and(icm_icd_lru_write_way(3), ('0' & dir_row6_lru_l2(1)   & '0'));
dir_row7_lru_write    <=  gate_and(icm_icd_lru_write_way(0), ("11" & dir_row7_lru_l2(2)))   or
                        gate_and(icm_icd_lru_write_way(1), ("10" & dir_row7_lru_l2(2)))   or
                        gate_and(icm_icd_lru_write_way(2), ('0' & dir_row7_lru_l2(1)   & '1')) or
                        gate_and(icm_icd_lru_write_way(3), ('0' & dir_row7_lru_l2(1)   & '0'));
dir_row8_lru_write    <=  gate_and(icm_icd_lru_write_way(0), ("11" & dir_row8_lru_l2(2)))   or
                        gate_and(icm_icd_lru_write_way(1), ("10" & dir_row8_lru_l2(2)))   or
                        gate_and(icm_icd_lru_write_way(2), ('0' & dir_row8_lru_l2(1)   & '1')) or
                        gate_and(icm_icd_lru_write_way(3), ('0' & dir_row8_lru_l2(1)   & '0'));
dir_row9_lru_write    <=  gate_and(icm_icd_lru_write_way(0), ("11" & dir_row9_lru_l2(2)))   or
                        gate_and(icm_icd_lru_write_way(1), ("10" & dir_row9_lru_l2(2)))   or
                        gate_and(icm_icd_lru_write_way(2), ('0' & dir_row9_lru_l2(1)   & '1')) or
                        gate_and(icm_icd_lru_write_way(3), ('0' & dir_row9_lru_l2(1)   & '0'));
dir_row10_lru_write   <=  gate_and(icm_icd_lru_write_way(0), ("11" & dir_row10_lru_l2(2)))  or
                        gate_and(icm_icd_lru_write_way(1), ("10" & dir_row10_lru_l2(2)))  or
                        gate_and(icm_icd_lru_write_way(2), ('0' & dir_row10_lru_l2(1)  & '1')) or
                        gate_and(icm_icd_lru_write_way(3), ('0' & dir_row10_lru_l2(1)  & '0'));
dir_row11_lru_write   <=  gate_and(icm_icd_lru_write_way(0), ("11" & dir_row11_lru_l2(2)))  or
                        gate_and(icm_icd_lru_write_way(1), ("10" & dir_row11_lru_l2(2)))  or
                        gate_and(icm_icd_lru_write_way(2), ('0' & dir_row11_lru_l2(1)  & '1')) or
                        gate_and(icm_icd_lru_write_way(3), ('0' & dir_row11_lru_l2(1)  & '0'));
dir_row12_lru_write   <=  gate_and(icm_icd_lru_write_way(0), ("11" & dir_row12_lru_l2(2)))  or
                        gate_and(icm_icd_lru_write_way(1), ("10" & dir_row12_lru_l2(2)))  or
                        gate_and(icm_icd_lru_write_way(2), ('0' & dir_row12_lru_l2(1)  & '1')) or
                        gate_and(icm_icd_lru_write_way(3), ('0' & dir_row12_lru_l2(1)  & '0'));
dir_row13_lru_write   <=  gate_and(icm_icd_lru_write_way(0), ("11" & dir_row13_lru_l2(2)))  or
                        gate_and(icm_icd_lru_write_way(1), ("10" & dir_row13_lru_l2(2)))  or
                        gate_and(icm_icd_lru_write_way(2), ('0' & dir_row13_lru_l2(1)  & '1')) or
                        gate_and(icm_icd_lru_write_way(3), ('0' & dir_row13_lru_l2(1)  & '0'));
dir_row14_lru_write   <=  gate_and(icm_icd_lru_write_way(0), ("11" & dir_row14_lru_l2(2)))  or
                        gate_and(icm_icd_lru_write_way(1), ("10" & dir_row14_lru_l2(2)))  or
                        gate_and(icm_icd_lru_write_way(2), ('0' & dir_row14_lru_l2(1)  & '1')) or
                        gate_and(icm_icd_lru_write_way(3), ('0' & dir_row14_lru_l2(1)  & '0'));
dir_row15_lru_write   <=  gate_and(icm_icd_lru_write_way(0), ("11" & dir_row15_lru_l2(2)))  or
                        gate_and(icm_icd_lru_write_way(1), ("10" & dir_row15_lru_l2(2)))  or
                        gate_and(icm_icd_lru_write_way(2), ('0' & dir_row15_lru_l2(1)  & '1')) or
                        gate_and(icm_icd_lru_write_way(3), ('0' & dir_row15_lru_l2(1)  & '0'));
dir_row16_lru_write   <=  gate_and(icm_icd_lru_write_way(0), ("11" & dir_row16_lru_l2(2)))  or
                        gate_and(icm_icd_lru_write_way(1), ("10" & dir_row16_lru_l2(2)))  or
                        gate_and(icm_icd_lru_write_way(2), ('0' & dir_row16_lru_l2(1)  & '1')) or
                        gate_and(icm_icd_lru_write_way(3), ('0' & dir_row16_lru_l2(1)  & '0'));
dir_row17_lru_write   <=  gate_and(icm_icd_lru_write_way(0), ("11" & dir_row17_lru_l2(2)))  or
                        gate_and(icm_icd_lru_write_way(1), ("10" & dir_row17_lru_l2(2)))  or
                        gate_and(icm_icd_lru_write_way(2), ('0' & dir_row17_lru_l2(1)  & '1')) or
                        gate_and(icm_icd_lru_write_way(3), ('0' & dir_row17_lru_l2(1)  & '0'));
dir_row18_lru_write   <=  gate_and(icm_icd_lru_write_way(0), ("11" & dir_row18_lru_l2(2)))  or
                        gate_and(icm_icd_lru_write_way(1), ("10" & dir_row18_lru_l2(2)))  or
                        gate_and(icm_icd_lru_write_way(2), ('0' & dir_row18_lru_l2(1)  & '1')) or
                        gate_and(icm_icd_lru_write_way(3), ('0' & dir_row18_lru_l2(1)  & '0'));
dir_row19_lru_write   <=  gate_and(icm_icd_lru_write_way(0), ("11" & dir_row19_lru_l2(2)))  or
                        gate_and(icm_icd_lru_write_way(1), ("10" & dir_row19_lru_l2(2)))  or
                        gate_and(icm_icd_lru_write_way(2), ('0' & dir_row19_lru_l2(1)  & '1')) or
                        gate_and(icm_icd_lru_write_way(3), ('0' & dir_row19_lru_l2(1)  & '0'));
dir_row20_lru_write   <=  gate_and(icm_icd_lru_write_way(0), ("11" & dir_row20_lru_l2(2)))  or
                        gate_and(icm_icd_lru_write_way(1), ("10" & dir_row20_lru_l2(2)))  or
                        gate_and(icm_icd_lru_write_way(2), ('0' & dir_row20_lru_l2(1)  & '1')) or
                        gate_and(icm_icd_lru_write_way(3), ('0' & dir_row20_lru_l2(1)  & '0'));
dir_row21_lru_write   <=  gate_and(icm_icd_lru_write_way(0), ("11" & dir_row21_lru_l2(2)))  or
                        gate_and(icm_icd_lru_write_way(1), ("10" & dir_row21_lru_l2(2)))  or
                        gate_and(icm_icd_lru_write_way(2), ('0' & dir_row21_lru_l2(1)  & '1')) or
                        gate_and(icm_icd_lru_write_way(3), ('0' & dir_row21_lru_l2(1)  & '0'));
dir_row22_lru_write   <=  gate_and(icm_icd_lru_write_way(0), ("11" & dir_row22_lru_l2(2)))  or
                        gate_and(icm_icd_lru_write_way(1), ("10" & dir_row22_lru_l2(2)))  or
                        gate_and(icm_icd_lru_write_way(2), ('0' & dir_row22_lru_l2(1)  & '1')) or
                        gate_and(icm_icd_lru_write_way(3), ('0' & dir_row22_lru_l2(1)  & '0'));
dir_row23_lru_write   <=  gate_and(icm_icd_lru_write_way(0), ("11" & dir_row23_lru_l2(2)))  or
                        gate_and(icm_icd_lru_write_way(1), ("10" & dir_row23_lru_l2(2)))  or
                        gate_and(icm_icd_lru_write_way(2), ('0' & dir_row23_lru_l2(1)  & '1')) or
                        gate_and(icm_icd_lru_write_way(3), ('0' & dir_row23_lru_l2(1)  & '0'));
dir_row24_lru_write   <=  gate_and(icm_icd_lru_write_way(0), ("11" & dir_row24_lru_l2(2)))  or
                        gate_and(icm_icd_lru_write_way(1), ("10" & dir_row24_lru_l2(2)))  or
                        gate_and(icm_icd_lru_write_way(2), ('0' & dir_row24_lru_l2(1)  & '1')) or
                        gate_and(icm_icd_lru_write_way(3), ('0' & dir_row24_lru_l2(1)  & '0'));
dir_row25_lru_write   <=  gate_and(icm_icd_lru_write_way(0), ("11" & dir_row25_lru_l2(2)))  or
                        gate_and(icm_icd_lru_write_way(1), ("10" & dir_row25_lru_l2(2)))  or
                        gate_and(icm_icd_lru_write_way(2), ('0' & dir_row25_lru_l2(1)  & '1')) or
                        gate_and(icm_icd_lru_write_way(3), ('0' & dir_row25_lru_l2(1)  & '0'));
dir_row26_lru_write   <=  gate_and(icm_icd_lru_write_way(0), ("11" & dir_row26_lru_l2(2)))  or
                        gate_and(icm_icd_lru_write_way(1), ("10" & dir_row26_lru_l2(2)))  or
                        gate_and(icm_icd_lru_write_way(2), ('0' & dir_row26_lru_l2(1)  & '1')) or
                        gate_and(icm_icd_lru_write_way(3), ('0' & dir_row26_lru_l2(1)  & '0'));
dir_row27_lru_write   <=  gate_and(icm_icd_lru_write_way(0), ("11" & dir_row27_lru_l2(2)))  or
                        gate_and(icm_icd_lru_write_way(1), ("10" & dir_row27_lru_l2(2)))  or
                        gate_and(icm_icd_lru_write_way(2), ('0' & dir_row27_lru_l2(1)  & '1')) or
                        gate_and(icm_icd_lru_write_way(3), ('0' & dir_row27_lru_l2(1)  & '0'));
dir_row28_lru_write   <=  gate_and(icm_icd_lru_write_way(0), ("11" & dir_row28_lru_l2(2)))  or
                        gate_and(icm_icd_lru_write_way(1), ("10" & dir_row28_lru_l2(2)))  or
                        gate_and(icm_icd_lru_write_way(2), ('0' & dir_row28_lru_l2(1)  & '1')) or
                        gate_and(icm_icd_lru_write_way(3), ('0' & dir_row28_lru_l2(1)  & '0'));
dir_row29_lru_write   <=  gate_and(icm_icd_lru_write_way(0), ("11" & dir_row29_lru_l2(2)))  or
                        gate_and(icm_icd_lru_write_way(1), ("10" & dir_row29_lru_l2(2)))  or
                        gate_and(icm_icd_lru_write_way(2), ('0' & dir_row29_lru_l2(1)  & '1')) or
                        gate_and(icm_icd_lru_write_way(3), ('0' & dir_row29_lru_l2(1)  & '0'));
dir_row30_lru_write   <=  gate_and(icm_icd_lru_write_way(0), ("11" & dir_row30_lru_l2(2)))  or
                        gate_and(icm_icd_lru_write_way(1), ("10" & dir_row30_lru_l2(2)))  or
                        gate_and(icm_icd_lru_write_way(2), ('0' & dir_row30_lru_l2(1)  & '1')) or
                        gate_and(icm_icd_lru_write_way(3), ('0' & dir_row30_lru_l2(1)  & '0'));
dir_row31_lru_write   <=  gate_and(icm_icd_lru_write_way(0), ("11" & dir_row31_lru_l2(2)))  or
                        gate_and(icm_icd_lru_write_way(1), ("10" & dir_row31_lru_l2(2)))  or
                        gate_and(icm_icd_lru_write_way(2), ('0' & dir_row31_lru_l2(1)  & '1')) or
                        gate_and(icm_icd_lru_write_way(3), ('0' & dir_row31_lru_l2(1)  & '0'));
dir_row32_lru_write   <=  gate_and(icm_icd_lru_write_way(0), ("11" & dir_row32_lru_l2(2)))  or
                        gate_and(icm_icd_lru_write_way(1), ("10" & dir_row32_lru_l2(2)))  or
                        gate_and(icm_icd_lru_write_way(2), ('0' & dir_row32_lru_l2(1)  & '1')) or
                        gate_and(icm_icd_lru_write_way(3), ('0' & dir_row32_lru_l2(1)  & '0'));
dir_row33_lru_write   <=  gate_and(icm_icd_lru_write_way(0), ("11" & dir_row33_lru_l2(2)))  or
                        gate_and(icm_icd_lru_write_way(1), ("10" & dir_row33_lru_l2(2)))  or
                        gate_and(icm_icd_lru_write_way(2), ('0' & dir_row33_lru_l2(1)  & '1')) or
                        gate_and(icm_icd_lru_write_way(3), ('0' & dir_row33_lru_l2(1)  & '0'));
dir_row34_lru_write   <=  gate_and(icm_icd_lru_write_way(0), ("11" & dir_row34_lru_l2(2)))  or
                        gate_and(icm_icd_lru_write_way(1), ("10" & dir_row34_lru_l2(2)))  or
                        gate_and(icm_icd_lru_write_way(2), ('0' & dir_row34_lru_l2(1)  & '1')) or
                        gate_and(icm_icd_lru_write_way(3), ('0' & dir_row34_lru_l2(1)  & '0'));
dir_row35_lru_write   <=  gate_and(icm_icd_lru_write_way(0), ("11" & dir_row35_lru_l2(2)))  or
                        gate_and(icm_icd_lru_write_way(1), ("10" & dir_row35_lru_l2(2)))  or
                        gate_and(icm_icd_lru_write_way(2), ('0' & dir_row35_lru_l2(1)  & '1')) or
                        gate_and(icm_icd_lru_write_way(3), ('0' & dir_row35_lru_l2(1)  & '0'));
dir_row36_lru_write   <=  gate_and(icm_icd_lru_write_way(0), ("11" & dir_row36_lru_l2(2)))  or
                        gate_and(icm_icd_lru_write_way(1), ("10" & dir_row36_lru_l2(2)))  or
                        gate_and(icm_icd_lru_write_way(2), ('0' & dir_row36_lru_l2(1)  & '1')) or
                        gate_and(icm_icd_lru_write_way(3), ('0' & dir_row36_lru_l2(1)  & '0'));
dir_row37_lru_write   <=  gate_and(icm_icd_lru_write_way(0), ("11" & dir_row37_lru_l2(2)))  or
                        gate_and(icm_icd_lru_write_way(1), ("10" & dir_row37_lru_l2(2)))  or
                        gate_and(icm_icd_lru_write_way(2), ('0' & dir_row37_lru_l2(1)  & '1')) or
                        gate_and(icm_icd_lru_write_way(3), ('0' & dir_row37_lru_l2(1)  & '0'));
dir_row38_lru_write   <=  gate_and(icm_icd_lru_write_way(0), ("11" & dir_row38_lru_l2(2)))  or
                        gate_and(icm_icd_lru_write_way(1), ("10" & dir_row38_lru_l2(2)))  or
                        gate_and(icm_icd_lru_write_way(2), ('0' & dir_row38_lru_l2(1)  & '1')) or
                        gate_and(icm_icd_lru_write_way(3), ('0' & dir_row38_lru_l2(1)  & '0'));
dir_row39_lru_write   <=  gate_and(icm_icd_lru_write_way(0), ("11" & dir_row39_lru_l2(2)))  or
                        gate_and(icm_icd_lru_write_way(1), ("10" & dir_row39_lru_l2(2)))  or
                        gate_and(icm_icd_lru_write_way(2), ('0' & dir_row39_lru_l2(1)  & '1')) or
                        gate_and(icm_icd_lru_write_way(3), ('0' & dir_row39_lru_l2(1)  & '0'));
dir_row40_lru_write   <=  gate_and(icm_icd_lru_write_way(0), ("11" & dir_row40_lru_l2(2)))  or
                        gate_and(icm_icd_lru_write_way(1), ("10" & dir_row40_lru_l2(2)))  or
                        gate_and(icm_icd_lru_write_way(2), ('0' & dir_row40_lru_l2(1)  & '1')) or
                        gate_and(icm_icd_lru_write_way(3), ('0' & dir_row40_lru_l2(1)  & '0'));
dir_row41_lru_write   <=  gate_and(icm_icd_lru_write_way(0), ("11" & dir_row41_lru_l2(2)))  or
                        gate_and(icm_icd_lru_write_way(1), ("10" & dir_row41_lru_l2(2)))  or
                        gate_and(icm_icd_lru_write_way(2), ('0' & dir_row41_lru_l2(1)  & '1')) or
                        gate_and(icm_icd_lru_write_way(3), ('0' & dir_row41_lru_l2(1)  & '0'));
dir_row42_lru_write   <=  gate_and(icm_icd_lru_write_way(0), ("11" & dir_row42_lru_l2(2)))  or
                        gate_and(icm_icd_lru_write_way(1), ("10" & dir_row42_lru_l2(2)))  or
                        gate_and(icm_icd_lru_write_way(2), ('0' & dir_row42_lru_l2(1)  & '1')) or
                        gate_and(icm_icd_lru_write_way(3), ('0' & dir_row42_lru_l2(1)  & '0'));
dir_row43_lru_write   <=  gate_and(icm_icd_lru_write_way(0), ("11" & dir_row43_lru_l2(2)))  or
                        gate_and(icm_icd_lru_write_way(1), ("10" & dir_row43_lru_l2(2)))  or
                        gate_and(icm_icd_lru_write_way(2), ('0' & dir_row43_lru_l2(1)  & '1')) or
                        gate_and(icm_icd_lru_write_way(3), ('0' & dir_row43_lru_l2(1)  & '0'));
dir_row44_lru_write   <=  gate_and(icm_icd_lru_write_way(0), ("11" & dir_row44_lru_l2(2)))  or
                        gate_and(icm_icd_lru_write_way(1), ("10" & dir_row44_lru_l2(2)))  or
                        gate_and(icm_icd_lru_write_way(2), ('0' & dir_row44_lru_l2(1)  & '1')) or
                        gate_and(icm_icd_lru_write_way(3), ('0' & dir_row44_lru_l2(1)  & '0'));
dir_row45_lru_write   <=  gate_and(icm_icd_lru_write_way(0), ("11" & dir_row45_lru_l2(2)))  or
                        gate_and(icm_icd_lru_write_way(1), ("10" & dir_row45_lru_l2(2)))  or
                        gate_and(icm_icd_lru_write_way(2), ('0' & dir_row45_lru_l2(1)  & '1')) or
                        gate_and(icm_icd_lru_write_way(3), ('0' & dir_row45_lru_l2(1)  & '0'));
dir_row46_lru_write   <=  gate_and(icm_icd_lru_write_way(0), ("11" & dir_row46_lru_l2(2)))  or
                        gate_and(icm_icd_lru_write_way(1), ("10" & dir_row46_lru_l2(2)))  or
                        gate_and(icm_icd_lru_write_way(2), ('0' & dir_row46_lru_l2(1)  & '1')) or
                        gate_and(icm_icd_lru_write_way(3), ('0' & dir_row46_lru_l2(1)  & '0'));
dir_row47_lru_write   <=  gate_and(icm_icd_lru_write_way(0), ("11" & dir_row47_lru_l2(2)))  or
                        gate_and(icm_icd_lru_write_way(1), ("10" & dir_row47_lru_l2(2)))  or
                        gate_and(icm_icd_lru_write_way(2), ('0' & dir_row47_lru_l2(1)  & '1')) or
                        gate_and(icm_icd_lru_write_way(3), ('0' & dir_row47_lru_l2(1)  & '0'));
dir_row48_lru_write   <=  gate_and(icm_icd_lru_write_way(0), ("11" & dir_row48_lru_l2(2)))  or
                        gate_and(icm_icd_lru_write_way(1), ("10" & dir_row48_lru_l2(2)))  or
                        gate_and(icm_icd_lru_write_way(2), ('0' & dir_row48_lru_l2(1)  & '1')) or
                        gate_and(icm_icd_lru_write_way(3), ('0' & dir_row48_lru_l2(1)  & '0'));
dir_row49_lru_write   <=  gate_and(icm_icd_lru_write_way(0), ("11" & dir_row49_lru_l2(2)))  or
                        gate_and(icm_icd_lru_write_way(1), ("10" & dir_row49_lru_l2(2)))  or
                        gate_and(icm_icd_lru_write_way(2), ('0' & dir_row49_lru_l2(1)  & '1')) or
                        gate_and(icm_icd_lru_write_way(3), ('0' & dir_row49_lru_l2(1)  & '0'));
dir_row50_lru_write   <=  gate_and(icm_icd_lru_write_way(0), ("11" & dir_row50_lru_l2(2)))  or
                        gate_and(icm_icd_lru_write_way(1), ("10" & dir_row50_lru_l2(2)))  or
                        gate_and(icm_icd_lru_write_way(2), ('0' & dir_row50_lru_l2(1)  & '1')) or
                        gate_and(icm_icd_lru_write_way(3), ('0' & dir_row50_lru_l2(1)  & '0'));
dir_row51_lru_write   <=  gate_and(icm_icd_lru_write_way(0), ("11" & dir_row51_lru_l2(2)))  or
                        gate_and(icm_icd_lru_write_way(1), ("10" & dir_row51_lru_l2(2)))  or
                        gate_and(icm_icd_lru_write_way(2), ('0' & dir_row51_lru_l2(1)  & '1')) or
                        gate_and(icm_icd_lru_write_way(3), ('0' & dir_row51_lru_l2(1)  & '0'));
dir_row52_lru_write   <=  gate_and(icm_icd_lru_write_way(0), ("11" & dir_row52_lru_l2(2)))  or
                        gate_and(icm_icd_lru_write_way(1), ("10" & dir_row52_lru_l2(2)))  or
                        gate_and(icm_icd_lru_write_way(2), ('0' & dir_row52_lru_l2(1)  & '1')) or
                        gate_and(icm_icd_lru_write_way(3), ('0' & dir_row52_lru_l2(1)  & '0'));
dir_row53_lru_write   <=  gate_and(icm_icd_lru_write_way(0), ("11" & dir_row53_lru_l2(2)))  or
                        gate_and(icm_icd_lru_write_way(1), ("10" & dir_row53_lru_l2(2)))  or
                        gate_and(icm_icd_lru_write_way(2), ('0' & dir_row53_lru_l2(1)  & '1')) or
                        gate_and(icm_icd_lru_write_way(3), ('0' & dir_row53_lru_l2(1)  & '0'));
dir_row54_lru_write   <=  gate_and(icm_icd_lru_write_way(0), ("11" & dir_row54_lru_l2(2)))  or
                        gate_and(icm_icd_lru_write_way(1), ("10" & dir_row54_lru_l2(2)))  or
                        gate_and(icm_icd_lru_write_way(2), ('0' & dir_row54_lru_l2(1)  & '1')) or
                        gate_and(icm_icd_lru_write_way(3), ('0' & dir_row54_lru_l2(1)  & '0'));
dir_row55_lru_write   <=  gate_and(icm_icd_lru_write_way(0), ("11" & dir_row55_lru_l2(2)))  or
                        gate_and(icm_icd_lru_write_way(1), ("10" & dir_row55_lru_l2(2)))  or
                        gate_and(icm_icd_lru_write_way(2), ('0' & dir_row55_lru_l2(1)  & '1')) or
                        gate_and(icm_icd_lru_write_way(3), ('0' & dir_row55_lru_l2(1)  & '0'));
dir_row56_lru_write   <=  gate_and(icm_icd_lru_write_way(0), ("11" & dir_row56_lru_l2(2)))  or
                        gate_and(icm_icd_lru_write_way(1), ("10" & dir_row56_lru_l2(2)))  or
                        gate_and(icm_icd_lru_write_way(2), ('0' & dir_row56_lru_l2(1)  & '1')) or
                        gate_and(icm_icd_lru_write_way(3), ('0' & dir_row56_lru_l2(1)  & '0'));
dir_row57_lru_write   <=  gate_and(icm_icd_lru_write_way(0), ("11" & dir_row57_lru_l2(2)))  or
                        gate_and(icm_icd_lru_write_way(1), ("10" & dir_row57_lru_l2(2)))  or
                        gate_and(icm_icd_lru_write_way(2), ('0' & dir_row57_lru_l2(1)  & '1')) or
                        gate_and(icm_icd_lru_write_way(3), ('0' & dir_row57_lru_l2(1)  & '0'));
dir_row58_lru_write   <=  gate_and(icm_icd_lru_write_way(0), ("11" & dir_row58_lru_l2(2)))  or
                        gate_and(icm_icd_lru_write_way(1), ("10" & dir_row58_lru_l2(2)))  or
                        gate_and(icm_icd_lru_write_way(2), ('0' & dir_row58_lru_l2(1)  & '1')) or
                        gate_and(icm_icd_lru_write_way(3), ('0' & dir_row58_lru_l2(1)  & '0'));
dir_row59_lru_write   <=  gate_and(icm_icd_lru_write_way(0), ("11" & dir_row59_lru_l2(2)))  or
                        gate_and(icm_icd_lru_write_way(1), ("10" & dir_row59_lru_l2(2)))  or
                        gate_and(icm_icd_lru_write_way(2), ('0' & dir_row59_lru_l2(1)  & '1')) or
                        gate_and(icm_icd_lru_write_way(3), ('0' & dir_row59_lru_l2(1)  & '0'));
dir_row60_lru_write   <=  gate_and(icm_icd_lru_write_way(0), ("11" & dir_row60_lru_l2(2)))  or
                        gate_and(icm_icd_lru_write_way(1), ("10" & dir_row60_lru_l2(2)))  or
                        gate_and(icm_icd_lru_write_way(2), ('0' & dir_row60_lru_l2(1)  & '1')) or
                        gate_and(icm_icd_lru_write_way(3), ('0' & dir_row60_lru_l2(1)  & '0'));
dir_row61_lru_write   <=  gate_and(icm_icd_lru_write_way(0), ("11" & dir_row61_lru_l2(2)))  or
                        gate_and(icm_icd_lru_write_way(1), ("10" & dir_row61_lru_l2(2)))  or
                        gate_and(icm_icd_lru_write_way(2), ('0' & dir_row61_lru_l2(1)  & '1')) or
                        gate_and(icm_icd_lru_write_way(3), ('0' & dir_row61_lru_l2(1)  & '0'));
dir_row62_lru_write   <=  gate_and(icm_icd_lru_write_way(0), ("11" & dir_row62_lru_l2(2)))  or
                        gate_and(icm_icd_lru_write_way(1), ("10" & dir_row62_lru_l2(2)))  or
                        gate_and(icm_icd_lru_write_way(2), ('0' & dir_row62_lru_l2(1)  & '1')) or
                        gate_and(icm_icd_lru_write_way(3), ('0' & dir_row62_lru_l2(1)  & '0'));
dir_row63_lru_write   <=  gate_and(icm_icd_lru_write_way(0), ("11" & dir_row63_lru_l2(2)))  or
                        gate_and(icm_icd_lru_write_way(1), ("10" & dir_row63_lru_l2(2)))  or
                        gate_and(icm_icd_lru_write_way(2), ('0' & dir_row63_lru_l2(1)  & '1')) or
                        gate_and(icm_icd_lru_write_way(3), ('0' & dir_row63_lru_l2(1)  & '0'));
-----------------------------------------------------------------------
-- Update Valid Bits
-----------------------------------------------------------------------
-- For 128B cacheline mode, use even dir rows
iu2_ifar_eff_cacheline  <=  iu2_ifar_eff_l2(52 to 56) &
                         (iu2_ifar_eff_l2(57) and not (spr_ic_cls_l2 and not iu2_spr_idir_read_l2));
iu3_parity_tag_cacheline  <=  iu3_parity_tag_l2(52 to 56) & (iu3_parity_tag_l2(57) and not spr_ic_cls_l2);
reload_cacheline  <=  icm_icd_reload_addr(52 to 56) & (icm_icd_reload_addr(57) and not spr_ic_cls_l2);
ecc_inval_cacheline  <=  icm_icd_ecc_addr(52 to 56) & (icm_icd_ecc_addr(57) and not spr_ic_cls_l2);
lru_write_cacheline  <=  icm_icd_lru_write_addr(52 to 56) & (icm_icd_lru_write_addr(57) and not spr_ic_cls_l2);
iu3_any_parity_err_way  <=  iu3_dir_parity_err_way_l2 or iu3_multihit_err_way_l2 or iu3_data_parity_err_way_l2;
dir_row0_val_d_part1    <= 
    ((dir_row0_val_l2
         and not (gate_and((iu3_parity_tag_cacheline = "000000"),   iu3_any_parity_err_way)) )  
     or (gate_and((icm_icd_dir_val and reload_cacheline = "000000"),   icm_icd_reload_way)))       
 and not (gate_and((icm_icd_dir_inval and reload_cacheline = "000000"),   icm_icd_reload_way))    
 and not (gate_and((icm_icd_ecc_inval and ecc_inval_cacheline = "000000"),   icm_icd_ecc_way))       
 and not (xu_iu_ici_l2 & xu_iu_ici_l2 & xu_iu_ici_l2 & xu_iu_ici_l2);
dir_row0_val_d_part2a    <=  gate_and(iu2_inval_l2 and (iu2_ifar_eff_cacheline = "000000"),   dir_row0_val_l2);
dir_row0_val_d_part2_b    <=  not(dir_row0_val_d_part2a   and iu2_rd_way_tag_hit);
dir_row0_val_d    <=  dir_row0_val_d_part1   and dir_row0_val_d_part2_b;
dir_row1_val_d_part1    <= 
    ((dir_row1_val_l2
         and not (gate_and((iu3_parity_tag_cacheline = "000001"),   iu3_any_parity_err_way)) )  
     or (gate_and((icm_icd_dir_val and reload_cacheline = "000001"),   icm_icd_reload_way)))       
 and not (gate_and((icm_icd_dir_inval and reload_cacheline = "000001"),   icm_icd_reload_way))    
 and not (gate_and((icm_icd_ecc_inval and ecc_inval_cacheline = "000001"),   icm_icd_ecc_way))       
 and not (xu_iu_ici_l2 & xu_iu_ici_l2 & xu_iu_ici_l2 & xu_iu_ici_l2);
dir_row1_val_d_part2a    <=  gate_and(iu2_inval_l2 and (iu2_ifar_eff_cacheline = "000001"),   dir_row1_val_l2);
dir_row1_val_d_part2_b    <=  not(dir_row1_val_d_part2a   and iu2_rd_way_tag_hit);
dir_row1_val_d    <=  dir_row1_val_d_part1   and dir_row1_val_d_part2_b;
dir_row2_val_d_part1    <= 
    ((dir_row2_val_l2
         and not (gate_and((iu3_parity_tag_cacheline = "000010"),   iu3_any_parity_err_way)) )  
     or (gate_and((icm_icd_dir_val and reload_cacheline = "000010"),   icm_icd_reload_way)))       
 and not (gate_and((icm_icd_dir_inval and reload_cacheline = "000010"),   icm_icd_reload_way))    
 and not (gate_and((icm_icd_ecc_inval and ecc_inval_cacheline = "000010"),   icm_icd_ecc_way))       
 and not (xu_iu_ici_l2 & xu_iu_ici_l2 & xu_iu_ici_l2 & xu_iu_ici_l2);
dir_row2_val_d_part2a    <=  gate_and(iu2_inval_l2 and (iu2_ifar_eff_cacheline = "000010"),   dir_row2_val_l2);
dir_row2_val_d_part2_b    <=  not(dir_row2_val_d_part2a   and iu2_rd_way_tag_hit);
dir_row2_val_d    <=  dir_row2_val_d_part1   and dir_row2_val_d_part2_b;
dir_row3_val_d_part1    <= 
    ((dir_row3_val_l2
         and not (gate_and((iu3_parity_tag_cacheline = "000011"),   iu3_any_parity_err_way)) )  
     or (gate_and((icm_icd_dir_val and reload_cacheline = "000011"),   icm_icd_reload_way)))       
 and not (gate_and((icm_icd_dir_inval and reload_cacheline = "000011"),   icm_icd_reload_way))    
 and not (gate_and((icm_icd_ecc_inval and ecc_inval_cacheline = "000011"),   icm_icd_ecc_way))       
 and not (xu_iu_ici_l2 & xu_iu_ici_l2 & xu_iu_ici_l2 & xu_iu_ici_l2);
dir_row3_val_d_part2a    <=  gate_and(iu2_inval_l2 and (iu2_ifar_eff_cacheline = "000011"),   dir_row3_val_l2);
dir_row3_val_d_part2_b    <=  not(dir_row3_val_d_part2a   and iu2_rd_way_tag_hit);
dir_row3_val_d    <=  dir_row3_val_d_part1   and dir_row3_val_d_part2_b;
dir_row4_val_d_part1    <= 
    ((dir_row4_val_l2
         and not (gate_and((iu3_parity_tag_cacheline = "000100"),   iu3_any_parity_err_way)) )  
     or (gate_and((icm_icd_dir_val and reload_cacheline = "000100"),   icm_icd_reload_way)))       
 and not (gate_and((icm_icd_dir_inval and reload_cacheline = "000100"),   icm_icd_reload_way))    
 and not (gate_and((icm_icd_ecc_inval and ecc_inval_cacheline = "000100"),   icm_icd_ecc_way))       
 and not (xu_iu_ici_l2 & xu_iu_ici_l2 & xu_iu_ici_l2 & xu_iu_ici_l2);
dir_row4_val_d_part2a    <=  gate_and(iu2_inval_l2 and (iu2_ifar_eff_cacheline = "000100"),   dir_row4_val_l2);
dir_row4_val_d_part2_b    <=  not(dir_row4_val_d_part2a   and iu2_rd_way_tag_hit);
dir_row4_val_d    <=  dir_row4_val_d_part1   and dir_row4_val_d_part2_b;
dir_row5_val_d_part1    <= 
    ((dir_row5_val_l2
         and not (gate_and((iu3_parity_tag_cacheline = "000101"),   iu3_any_parity_err_way)) )  
     or (gate_and((icm_icd_dir_val and reload_cacheline = "000101"),   icm_icd_reload_way)))       
 and not (gate_and((icm_icd_dir_inval and reload_cacheline = "000101"),   icm_icd_reload_way))    
 and not (gate_and((icm_icd_ecc_inval and ecc_inval_cacheline = "000101"),   icm_icd_ecc_way))       
 and not (xu_iu_ici_l2 & xu_iu_ici_l2 & xu_iu_ici_l2 & xu_iu_ici_l2);
dir_row5_val_d_part2a    <=  gate_and(iu2_inval_l2 and (iu2_ifar_eff_cacheline = "000101"),   dir_row5_val_l2);
dir_row5_val_d_part2_b    <=  not(dir_row5_val_d_part2a   and iu2_rd_way_tag_hit);
dir_row5_val_d    <=  dir_row5_val_d_part1   and dir_row5_val_d_part2_b;
dir_row6_val_d_part1    <= 
    ((dir_row6_val_l2
         and not (gate_and((iu3_parity_tag_cacheline = "000110"),   iu3_any_parity_err_way)) )  
     or (gate_and((icm_icd_dir_val and reload_cacheline = "000110"),   icm_icd_reload_way)))       
 and not (gate_and((icm_icd_dir_inval and reload_cacheline = "000110"),   icm_icd_reload_way))    
 and not (gate_and((icm_icd_ecc_inval and ecc_inval_cacheline = "000110"),   icm_icd_ecc_way))       
 and not (xu_iu_ici_l2 & xu_iu_ici_l2 & xu_iu_ici_l2 & xu_iu_ici_l2);
dir_row6_val_d_part2a    <=  gate_and(iu2_inval_l2 and (iu2_ifar_eff_cacheline = "000110"),   dir_row6_val_l2);
dir_row6_val_d_part2_b    <=  not(dir_row6_val_d_part2a   and iu2_rd_way_tag_hit);
dir_row6_val_d    <=  dir_row6_val_d_part1   and dir_row6_val_d_part2_b;
dir_row7_val_d_part1    <= 
    ((dir_row7_val_l2
         and not (gate_and((iu3_parity_tag_cacheline = "000111"),   iu3_any_parity_err_way)) )  
     or (gate_and((icm_icd_dir_val and reload_cacheline = "000111"),   icm_icd_reload_way)))       
 and not (gate_and((icm_icd_dir_inval and reload_cacheline = "000111"),   icm_icd_reload_way))    
 and not (gate_and((icm_icd_ecc_inval and ecc_inval_cacheline = "000111"),   icm_icd_ecc_way))       
 and not (xu_iu_ici_l2 & xu_iu_ici_l2 & xu_iu_ici_l2 & xu_iu_ici_l2);
dir_row7_val_d_part2a    <=  gate_and(iu2_inval_l2 and (iu2_ifar_eff_cacheline = "000111"),   dir_row7_val_l2);
dir_row7_val_d_part2_b    <=  not(dir_row7_val_d_part2a   and iu2_rd_way_tag_hit);
dir_row7_val_d    <=  dir_row7_val_d_part1   and dir_row7_val_d_part2_b;
dir_row8_val_d_part1    <= 
    ((dir_row8_val_l2
         and not (gate_and((iu3_parity_tag_cacheline = "001000"),   iu3_any_parity_err_way)) )  
     or (gate_and((icm_icd_dir_val and reload_cacheline = "001000"),   icm_icd_reload_way)))       
 and not (gate_and((icm_icd_dir_inval and reload_cacheline = "001000"),   icm_icd_reload_way))    
 and not (gate_and((icm_icd_ecc_inval and ecc_inval_cacheline = "001000"),   icm_icd_ecc_way))       
 and not (xu_iu_ici_l2 & xu_iu_ici_l2 & xu_iu_ici_l2 & xu_iu_ici_l2);
dir_row8_val_d_part2a    <=  gate_and(iu2_inval_l2 and (iu2_ifar_eff_cacheline = "001000"),   dir_row8_val_l2);
dir_row8_val_d_part2_b    <=  not(dir_row8_val_d_part2a   and iu2_rd_way_tag_hit);
dir_row8_val_d    <=  dir_row8_val_d_part1   and dir_row8_val_d_part2_b;
dir_row9_val_d_part1    <= 
    ((dir_row9_val_l2
         and not (gate_and((iu3_parity_tag_cacheline = "001001"),   iu3_any_parity_err_way)) )  
     or (gate_and((icm_icd_dir_val and reload_cacheline = "001001"),   icm_icd_reload_way)))       
 and not (gate_and((icm_icd_dir_inval and reload_cacheline = "001001"),   icm_icd_reload_way))    
 and not (gate_and((icm_icd_ecc_inval and ecc_inval_cacheline = "001001"),   icm_icd_ecc_way))       
 and not (xu_iu_ici_l2 & xu_iu_ici_l2 & xu_iu_ici_l2 & xu_iu_ici_l2);
dir_row9_val_d_part2a    <=  gate_and(iu2_inval_l2 and (iu2_ifar_eff_cacheline = "001001"),   dir_row9_val_l2);
dir_row9_val_d_part2_b    <=  not(dir_row9_val_d_part2a   and iu2_rd_way_tag_hit);
dir_row9_val_d    <=  dir_row9_val_d_part1   and dir_row9_val_d_part2_b;
dir_row10_val_d_part1   <= 
    ((dir_row10_val_l2
         and not (gate_and((iu3_parity_tag_cacheline = "001010"),  iu3_any_parity_err_way)) )  
     or (gate_and((icm_icd_dir_val and reload_cacheline = "001010"),  icm_icd_reload_way)))       
 and not (gate_and((icm_icd_dir_inval and reload_cacheline = "001010"),  icm_icd_reload_way))    
 and not (gate_and((icm_icd_ecc_inval and ecc_inval_cacheline = "001010"),  icm_icd_ecc_way))       
 and not (xu_iu_ici_l2 & xu_iu_ici_l2 & xu_iu_ici_l2 & xu_iu_ici_l2);
dir_row10_val_d_part2a   <=  gate_and(iu2_inval_l2 and (iu2_ifar_eff_cacheline = "001010"),  dir_row10_val_l2);
dir_row10_val_d_part2_b   <=  not(dir_row10_val_d_part2a  and iu2_rd_way_tag_hit);
dir_row10_val_d   <=  dir_row10_val_d_part1  and dir_row10_val_d_part2_b;
dir_row11_val_d_part1   <= 
    ((dir_row11_val_l2
         and not (gate_and((iu3_parity_tag_cacheline = "001011"),  iu3_any_parity_err_way)) )  
     or (gate_and((icm_icd_dir_val and reload_cacheline = "001011"),  icm_icd_reload_way)))       
 and not (gate_and((icm_icd_dir_inval and reload_cacheline = "001011"),  icm_icd_reload_way))    
 and not (gate_and((icm_icd_ecc_inval and ecc_inval_cacheline = "001011"),  icm_icd_ecc_way))       
 and not (xu_iu_ici_l2 & xu_iu_ici_l2 & xu_iu_ici_l2 & xu_iu_ici_l2);
dir_row11_val_d_part2a   <=  gate_and(iu2_inval_l2 and (iu2_ifar_eff_cacheline = "001011"),  dir_row11_val_l2);
dir_row11_val_d_part2_b   <=  not(dir_row11_val_d_part2a  and iu2_rd_way_tag_hit);
dir_row11_val_d   <=  dir_row11_val_d_part1  and dir_row11_val_d_part2_b;
dir_row12_val_d_part1   <= 
    ((dir_row12_val_l2
         and not (gate_and((iu3_parity_tag_cacheline = "001100"),  iu3_any_parity_err_way)) )  
     or (gate_and((icm_icd_dir_val and reload_cacheline = "001100"),  icm_icd_reload_way)))       
 and not (gate_and((icm_icd_dir_inval and reload_cacheline = "001100"),  icm_icd_reload_way))    
 and not (gate_and((icm_icd_ecc_inval and ecc_inval_cacheline = "001100"),  icm_icd_ecc_way))       
 and not (xu_iu_ici_l2 & xu_iu_ici_l2 & xu_iu_ici_l2 & xu_iu_ici_l2);
dir_row12_val_d_part2a   <=  gate_and(iu2_inval_l2 and (iu2_ifar_eff_cacheline = "001100"),  dir_row12_val_l2);
dir_row12_val_d_part2_b   <=  not(dir_row12_val_d_part2a  and iu2_rd_way_tag_hit);
dir_row12_val_d   <=  dir_row12_val_d_part1  and dir_row12_val_d_part2_b;
dir_row13_val_d_part1   <= 
    ((dir_row13_val_l2
         and not (gate_and((iu3_parity_tag_cacheline = "001101"),  iu3_any_parity_err_way)) )  
     or (gate_and((icm_icd_dir_val and reload_cacheline = "001101"),  icm_icd_reload_way)))       
 and not (gate_and((icm_icd_dir_inval and reload_cacheline = "001101"),  icm_icd_reload_way))    
 and not (gate_and((icm_icd_ecc_inval and ecc_inval_cacheline = "001101"),  icm_icd_ecc_way))       
 and not (xu_iu_ici_l2 & xu_iu_ici_l2 & xu_iu_ici_l2 & xu_iu_ici_l2);
dir_row13_val_d_part2a   <=  gate_and(iu2_inval_l2 and (iu2_ifar_eff_cacheline = "001101"),  dir_row13_val_l2);
dir_row13_val_d_part2_b   <=  not(dir_row13_val_d_part2a  and iu2_rd_way_tag_hit);
dir_row13_val_d   <=  dir_row13_val_d_part1  and dir_row13_val_d_part2_b;
dir_row14_val_d_part1   <= 
    ((dir_row14_val_l2
         and not (gate_and((iu3_parity_tag_cacheline = "001110"),  iu3_any_parity_err_way)) )  
     or (gate_and((icm_icd_dir_val and reload_cacheline = "001110"),  icm_icd_reload_way)))       
 and not (gate_and((icm_icd_dir_inval and reload_cacheline = "001110"),  icm_icd_reload_way))    
 and not (gate_and((icm_icd_ecc_inval and ecc_inval_cacheline = "001110"),  icm_icd_ecc_way))       
 and not (xu_iu_ici_l2 & xu_iu_ici_l2 & xu_iu_ici_l2 & xu_iu_ici_l2);
dir_row14_val_d_part2a   <=  gate_and(iu2_inval_l2 and (iu2_ifar_eff_cacheline = "001110"),  dir_row14_val_l2);
dir_row14_val_d_part2_b   <=  not(dir_row14_val_d_part2a  and iu2_rd_way_tag_hit);
dir_row14_val_d   <=  dir_row14_val_d_part1  and dir_row14_val_d_part2_b;
dir_row15_val_d_part1   <= 
    ((dir_row15_val_l2
         and not (gate_and((iu3_parity_tag_cacheline = "001111"),  iu3_any_parity_err_way)) )  
     or (gate_and((icm_icd_dir_val and reload_cacheline = "001111"),  icm_icd_reload_way)))       
 and not (gate_and((icm_icd_dir_inval and reload_cacheline = "001111"),  icm_icd_reload_way))    
 and not (gate_and((icm_icd_ecc_inval and ecc_inval_cacheline = "001111"),  icm_icd_ecc_way))       
 and not (xu_iu_ici_l2 & xu_iu_ici_l2 & xu_iu_ici_l2 & xu_iu_ici_l2);
dir_row15_val_d_part2a   <=  gate_and(iu2_inval_l2 and (iu2_ifar_eff_cacheline = "001111"),  dir_row15_val_l2);
dir_row15_val_d_part2_b   <=  not(dir_row15_val_d_part2a  and iu2_rd_way_tag_hit);
dir_row15_val_d   <=  dir_row15_val_d_part1  and dir_row15_val_d_part2_b;
dir_row16_val_d_part1   <= 
    ((dir_row16_val_l2
         and not (gate_and((iu3_parity_tag_cacheline = "010000"),  iu3_any_parity_err_way)) )  
     or (gate_and((icm_icd_dir_val and reload_cacheline = "010000"),  icm_icd_reload_way)))       
 and not (gate_and((icm_icd_dir_inval and reload_cacheline = "010000"),  icm_icd_reload_way))    
 and not (gate_and((icm_icd_ecc_inval and ecc_inval_cacheline = "010000"),  icm_icd_ecc_way))       
 and not (xu_iu_ici_l2 & xu_iu_ici_l2 & xu_iu_ici_l2 & xu_iu_ici_l2);
dir_row16_val_d_part2a   <=  gate_and(iu2_inval_l2 and (iu2_ifar_eff_cacheline = "010000"),  dir_row16_val_l2);
dir_row16_val_d_part2_b   <=  not(dir_row16_val_d_part2a  and iu2_rd_way_tag_hit);
dir_row16_val_d   <=  dir_row16_val_d_part1  and dir_row16_val_d_part2_b;
dir_row17_val_d_part1   <= 
    ((dir_row17_val_l2
         and not (gate_and((iu3_parity_tag_cacheline = "010001"),  iu3_any_parity_err_way)) )  
     or (gate_and((icm_icd_dir_val and reload_cacheline = "010001"),  icm_icd_reload_way)))       
 and not (gate_and((icm_icd_dir_inval and reload_cacheline = "010001"),  icm_icd_reload_way))    
 and not (gate_and((icm_icd_ecc_inval and ecc_inval_cacheline = "010001"),  icm_icd_ecc_way))       
 and not (xu_iu_ici_l2 & xu_iu_ici_l2 & xu_iu_ici_l2 & xu_iu_ici_l2);
dir_row17_val_d_part2a   <=  gate_and(iu2_inval_l2 and (iu2_ifar_eff_cacheline = "010001"),  dir_row17_val_l2);
dir_row17_val_d_part2_b   <=  not(dir_row17_val_d_part2a  and iu2_rd_way_tag_hit);
dir_row17_val_d   <=  dir_row17_val_d_part1  and dir_row17_val_d_part2_b;
dir_row18_val_d_part1   <= 
    ((dir_row18_val_l2
         and not (gate_and((iu3_parity_tag_cacheline = "010010"),  iu3_any_parity_err_way)) )  
     or (gate_and((icm_icd_dir_val and reload_cacheline = "010010"),  icm_icd_reload_way)))       
 and not (gate_and((icm_icd_dir_inval and reload_cacheline = "010010"),  icm_icd_reload_way))    
 and not (gate_and((icm_icd_ecc_inval and ecc_inval_cacheline = "010010"),  icm_icd_ecc_way))       
 and not (xu_iu_ici_l2 & xu_iu_ici_l2 & xu_iu_ici_l2 & xu_iu_ici_l2);
dir_row18_val_d_part2a   <=  gate_and(iu2_inval_l2 and (iu2_ifar_eff_cacheline = "010010"),  dir_row18_val_l2);
dir_row18_val_d_part2_b   <=  not(dir_row18_val_d_part2a  and iu2_rd_way_tag_hit);
dir_row18_val_d   <=  dir_row18_val_d_part1  and dir_row18_val_d_part2_b;
dir_row19_val_d_part1   <= 
    ((dir_row19_val_l2
         and not (gate_and((iu3_parity_tag_cacheline = "010011"),  iu3_any_parity_err_way)) )  
     or (gate_and((icm_icd_dir_val and reload_cacheline = "010011"),  icm_icd_reload_way)))       
 and not (gate_and((icm_icd_dir_inval and reload_cacheline = "010011"),  icm_icd_reload_way))    
 and not (gate_and((icm_icd_ecc_inval and ecc_inval_cacheline = "010011"),  icm_icd_ecc_way))       
 and not (xu_iu_ici_l2 & xu_iu_ici_l2 & xu_iu_ici_l2 & xu_iu_ici_l2);
dir_row19_val_d_part2a   <=  gate_and(iu2_inval_l2 and (iu2_ifar_eff_cacheline = "010011"),  dir_row19_val_l2);
dir_row19_val_d_part2_b   <=  not(dir_row19_val_d_part2a  and iu2_rd_way_tag_hit);
dir_row19_val_d   <=  dir_row19_val_d_part1  and dir_row19_val_d_part2_b;
dir_row20_val_d_part1   <= 
    ((dir_row20_val_l2
         and not (gate_and((iu3_parity_tag_cacheline = "010100"),  iu3_any_parity_err_way)) )  
     or (gate_and((icm_icd_dir_val and reload_cacheline = "010100"),  icm_icd_reload_way)))       
 and not (gate_and((icm_icd_dir_inval and reload_cacheline = "010100"),  icm_icd_reload_way))    
 and not (gate_and((icm_icd_ecc_inval and ecc_inval_cacheline = "010100"),  icm_icd_ecc_way))       
 and not (xu_iu_ici_l2 & xu_iu_ici_l2 & xu_iu_ici_l2 & xu_iu_ici_l2);
dir_row20_val_d_part2a   <=  gate_and(iu2_inval_l2 and (iu2_ifar_eff_cacheline = "010100"),  dir_row20_val_l2);
dir_row20_val_d_part2_b   <=  not(dir_row20_val_d_part2a  and iu2_rd_way_tag_hit);
dir_row20_val_d   <=  dir_row20_val_d_part1  and dir_row20_val_d_part2_b;
dir_row21_val_d_part1   <= 
    ((dir_row21_val_l2
         and not (gate_and((iu3_parity_tag_cacheline = "010101"),  iu3_any_parity_err_way)) )  
     or (gate_and((icm_icd_dir_val and reload_cacheline = "010101"),  icm_icd_reload_way)))       
 and not (gate_and((icm_icd_dir_inval and reload_cacheline = "010101"),  icm_icd_reload_way))    
 and not (gate_and((icm_icd_ecc_inval and ecc_inval_cacheline = "010101"),  icm_icd_ecc_way))       
 and not (xu_iu_ici_l2 & xu_iu_ici_l2 & xu_iu_ici_l2 & xu_iu_ici_l2);
dir_row21_val_d_part2a   <=  gate_and(iu2_inval_l2 and (iu2_ifar_eff_cacheline = "010101"),  dir_row21_val_l2);
dir_row21_val_d_part2_b   <=  not(dir_row21_val_d_part2a  and iu2_rd_way_tag_hit);
dir_row21_val_d   <=  dir_row21_val_d_part1  and dir_row21_val_d_part2_b;
dir_row22_val_d_part1   <= 
    ((dir_row22_val_l2
         and not (gate_and((iu3_parity_tag_cacheline = "010110"),  iu3_any_parity_err_way)) )  
     or (gate_and((icm_icd_dir_val and reload_cacheline = "010110"),  icm_icd_reload_way)))       
 and not (gate_and((icm_icd_dir_inval and reload_cacheline = "010110"),  icm_icd_reload_way))    
 and not (gate_and((icm_icd_ecc_inval and ecc_inval_cacheline = "010110"),  icm_icd_ecc_way))       
 and not (xu_iu_ici_l2 & xu_iu_ici_l2 & xu_iu_ici_l2 & xu_iu_ici_l2);
dir_row22_val_d_part2a   <=  gate_and(iu2_inval_l2 and (iu2_ifar_eff_cacheline = "010110"),  dir_row22_val_l2);
dir_row22_val_d_part2_b   <=  not(dir_row22_val_d_part2a  and iu2_rd_way_tag_hit);
dir_row22_val_d   <=  dir_row22_val_d_part1  and dir_row22_val_d_part2_b;
dir_row23_val_d_part1   <= 
    ((dir_row23_val_l2
         and not (gate_and((iu3_parity_tag_cacheline = "010111"),  iu3_any_parity_err_way)) )  
     or (gate_and((icm_icd_dir_val and reload_cacheline = "010111"),  icm_icd_reload_way)))       
 and not (gate_and((icm_icd_dir_inval and reload_cacheline = "010111"),  icm_icd_reload_way))    
 and not (gate_and((icm_icd_ecc_inval and ecc_inval_cacheline = "010111"),  icm_icd_ecc_way))       
 and not (xu_iu_ici_l2 & xu_iu_ici_l2 & xu_iu_ici_l2 & xu_iu_ici_l2);
dir_row23_val_d_part2a   <=  gate_and(iu2_inval_l2 and (iu2_ifar_eff_cacheline = "010111"),  dir_row23_val_l2);
dir_row23_val_d_part2_b   <=  not(dir_row23_val_d_part2a  and iu2_rd_way_tag_hit);
dir_row23_val_d   <=  dir_row23_val_d_part1  and dir_row23_val_d_part2_b;
dir_row24_val_d_part1   <= 
    ((dir_row24_val_l2
         and not (gate_and((iu3_parity_tag_cacheline = "011000"),  iu3_any_parity_err_way)) )  
     or (gate_and((icm_icd_dir_val and reload_cacheline = "011000"),  icm_icd_reload_way)))       
 and not (gate_and((icm_icd_dir_inval and reload_cacheline = "011000"),  icm_icd_reload_way))    
 and not (gate_and((icm_icd_ecc_inval and ecc_inval_cacheline = "011000"),  icm_icd_ecc_way))       
 and not (xu_iu_ici_l2 & xu_iu_ici_l2 & xu_iu_ici_l2 & xu_iu_ici_l2);
dir_row24_val_d_part2a   <=  gate_and(iu2_inval_l2 and (iu2_ifar_eff_cacheline = "011000"),  dir_row24_val_l2);
dir_row24_val_d_part2_b   <=  not(dir_row24_val_d_part2a  and iu2_rd_way_tag_hit);
dir_row24_val_d   <=  dir_row24_val_d_part1  and dir_row24_val_d_part2_b;
dir_row25_val_d_part1   <= 
    ((dir_row25_val_l2
         and not (gate_and((iu3_parity_tag_cacheline = "011001"),  iu3_any_parity_err_way)) )  
     or (gate_and((icm_icd_dir_val and reload_cacheline = "011001"),  icm_icd_reload_way)))       
 and not (gate_and((icm_icd_dir_inval and reload_cacheline = "011001"),  icm_icd_reload_way))    
 and not (gate_and((icm_icd_ecc_inval and ecc_inval_cacheline = "011001"),  icm_icd_ecc_way))       
 and not (xu_iu_ici_l2 & xu_iu_ici_l2 & xu_iu_ici_l2 & xu_iu_ici_l2);
dir_row25_val_d_part2a   <=  gate_and(iu2_inval_l2 and (iu2_ifar_eff_cacheline = "011001"),  dir_row25_val_l2);
dir_row25_val_d_part2_b   <=  not(dir_row25_val_d_part2a  and iu2_rd_way_tag_hit);
dir_row25_val_d   <=  dir_row25_val_d_part1  and dir_row25_val_d_part2_b;
dir_row26_val_d_part1   <= 
    ((dir_row26_val_l2
         and not (gate_and((iu3_parity_tag_cacheline = "011010"),  iu3_any_parity_err_way)) )  
     or (gate_and((icm_icd_dir_val and reload_cacheline = "011010"),  icm_icd_reload_way)))       
 and not (gate_and((icm_icd_dir_inval and reload_cacheline = "011010"),  icm_icd_reload_way))    
 and not (gate_and((icm_icd_ecc_inval and ecc_inval_cacheline = "011010"),  icm_icd_ecc_way))       
 and not (xu_iu_ici_l2 & xu_iu_ici_l2 & xu_iu_ici_l2 & xu_iu_ici_l2);
dir_row26_val_d_part2a   <=  gate_and(iu2_inval_l2 and (iu2_ifar_eff_cacheline = "011010"),  dir_row26_val_l2);
dir_row26_val_d_part2_b   <=  not(dir_row26_val_d_part2a  and iu2_rd_way_tag_hit);
dir_row26_val_d   <=  dir_row26_val_d_part1  and dir_row26_val_d_part2_b;
dir_row27_val_d_part1   <= 
    ((dir_row27_val_l2
         and not (gate_and((iu3_parity_tag_cacheline = "011011"),  iu3_any_parity_err_way)) )  
     or (gate_and((icm_icd_dir_val and reload_cacheline = "011011"),  icm_icd_reload_way)))       
 and not (gate_and((icm_icd_dir_inval and reload_cacheline = "011011"),  icm_icd_reload_way))    
 and not (gate_and((icm_icd_ecc_inval and ecc_inval_cacheline = "011011"),  icm_icd_ecc_way))       
 and not (xu_iu_ici_l2 & xu_iu_ici_l2 & xu_iu_ici_l2 & xu_iu_ici_l2);
dir_row27_val_d_part2a   <=  gate_and(iu2_inval_l2 and (iu2_ifar_eff_cacheline = "011011"),  dir_row27_val_l2);
dir_row27_val_d_part2_b   <=  not(dir_row27_val_d_part2a  and iu2_rd_way_tag_hit);
dir_row27_val_d   <=  dir_row27_val_d_part1  and dir_row27_val_d_part2_b;
dir_row28_val_d_part1   <= 
    ((dir_row28_val_l2
         and not (gate_and((iu3_parity_tag_cacheline = "011100"),  iu3_any_parity_err_way)) )  
     or (gate_and((icm_icd_dir_val and reload_cacheline = "011100"),  icm_icd_reload_way)))       
 and not (gate_and((icm_icd_dir_inval and reload_cacheline = "011100"),  icm_icd_reload_way))    
 and not (gate_and((icm_icd_ecc_inval and ecc_inval_cacheline = "011100"),  icm_icd_ecc_way))       
 and not (xu_iu_ici_l2 & xu_iu_ici_l2 & xu_iu_ici_l2 & xu_iu_ici_l2);
dir_row28_val_d_part2a   <=  gate_and(iu2_inval_l2 and (iu2_ifar_eff_cacheline = "011100"),  dir_row28_val_l2);
dir_row28_val_d_part2_b   <=  not(dir_row28_val_d_part2a  and iu2_rd_way_tag_hit);
dir_row28_val_d   <=  dir_row28_val_d_part1  and dir_row28_val_d_part2_b;
dir_row29_val_d_part1   <= 
    ((dir_row29_val_l2
         and not (gate_and((iu3_parity_tag_cacheline = "011101"),  iu3_any_parity_err_way)) )  
     or (gate_and((icm_icd_dir_val and reload_cacheline = "011101"),  icm_icd_reload_way)))       
 and not (gate_and((icm_icd_dir_inval and reload_cacheline = "011101"),  icm_icd_reload_way))    
 and not (gate_and((icm_icd_ecc_inval and ecc_inval_cacheline = "011101"),  icm_icd_ecc_way))       
 and not (xu_iu_ici_l2 & xu_iu_ici_l2 & xu_iu_ici_l2 & xu_iu_ici_l2);
dir_row29_val_d_part2a   <=  gate_and(iu2_inval_l2 and (iu2_ifar_eff_cacheline = "011101"),  dir_row29_val_l2);
dir_row29_val_d_part2_b   <=  not(dir_row29_val_d_part2a  and iu2_rd_way_tag_hit);
dir_row29_val_d   <=  dir_row29_val_d_part1  and dir_row29_val_d_part2_b;
dir_row30_val_d_part1   <= 
    ((dir_row30_val_l2
         and not (gate_and((iu3_parity_tag_cacheline = "011110"),  iu3_any_parity_err_way)) )  
     or (gate_and((icm_icd_dir_val and reload_cacheline = "011110"),  icm_icd_reload_way)))       
 and not (gate_and((icm_icd_dir_inval and reload_cacheline = "011110"),  icm_icd_reload_way))    
 and not (gate_and((icm_icd_ecc_inval and ecc_inval_cacheline = "011110"),  icm_icd_ecc_way))       
 and not (xu_iu_ici_l2 & xu_iu_ici_l2 & xu_iu_ici_l2 & xu_iu_ici_l2);
dir_row30_val_d_part2a   <=  gate_and(iu2_inval_l2 and (iu2_ifar_eff_cacheline = "011110"),  dir_row30_val_l2);
dir_row30_val_d_part2_b   <=  not(dir_row30_val_d_part2a  and iu2_rd_way_tag_hit);
dir_row30_val_d   <=  dir_row30_val_d_part1  and dir_row30_val_d_part2_b;
dir_row31_val_d_part1   <= 
    ((dir_row31_val_l2
         and not (gate_and((iu3_parity_tag_cacheline = "011111"),  iu3_any_parity_err_way)) )  
     or (gate_and((icm_icd_dir_val and reload_cacheline = "011111"),  icm_icd_reload_way)))       
 and not (gate_and((icm_icd_dir_inval and reload_cacheline = "011111"),  icm_icd_reload_way))    
 and not (gate_and((icm_icd_ecc_inval and ecc_inval_cacheline = "011111"),  icm_icd_ecc_way))       
 and not (xu_iu_ici_l2 & xu_iu_ici_l2 & xu_iu_ici_l2 & xu_iu_ici_l2);
dir_row31_val_d_part2a   <=  gate_and(iu2_inval_l2 and (iu2_ifar_eff_cacheline = "011111"),  dir_row31_val_l2);
dir_row31_val_d_part2_b   <=  not(dir_row31_val_d_part2a  and iu2_rd_way_tag_hit);
dir_row31_val_d   <=  dir_row31_val_d_part1  and dir_row31_val_d_part2_b;
dir_row32_val_d_part1   <= 
    ((dir_row32_val_l2
         and not (gate_and((iu3_parity_tag_cacheline = "100000"),  iu3_any_parity_err_way)) )  
     or (gate_and((icm_icd_dir_val and reload_cacheline = "100000"),  icm_icd_reload_way)))       
 and not (gate_and((icm_icd_dir_inval and reload_cacheline = "100000"),  icm_icd_reload_way))    
 and not (gate_and((icm_icd_ecc_inval and ecc_inval_cacheline = "100000"),  icm_icd_ecc_way))       
 and not (xu_iu_ici_l2 & xu_iu_ici_l2 & xu_iu_ici_l2 & xu_iu_ici_l2);
dir_row32_val_d_part2a   <=  gate_and(iu2_inval_l2 and (iu2_ifar_eff_cacheline = "100000"),  dir_row32_val_l2);
dir_row32_val_d_part2_b   <=  not(dir_row32_val_d_part2a  and iu2_rd_way_tag_hit);
dir_row32_val_d   <=  dir_row32_val_d_part1  and dir_row32_val_d_part2_b;
dir_row33_val_d_part1   <= 
    ((dir_row33_val_l2
         and not (gate_and((iu3_parity_tag_cacheline = "100001"),  iu3_any_parity_err_way)) )  
     or (gate_and((icm_icd_dir_val and reload_cacheline = "100001"),  icm_icd_reload_way)))       
 and not (gate_and((icm_icd_dir_inval and reload_cacheline = "100001"),  icm_icd_reload_way))    
 and not (gate_and((icm_icd_ecc_inval and ecc_inval_cacheline = "100001"),  icm_icd_ecc_way))       
 and not (xu_iu_ici_l2 & xu_iu_ici_l2 & xu_iu_ici_l2 & xu_iu_ici_l2);
dir_row33_val_d_part2a   <=  gate_and(iu2_inval_l2 and (iu2_ifar_eff_cacheline = "100001"),  dir_row33_val_l2);
dir_row33_val_d_part2_b   <=  not(dir_row33_val_d_part2a  and iu2_rd_way_tag_hit);
dir_row33_val_d   <=  dir_row33_val_d_part1  and dir_row33_val_d_part2_b;
dir_row34_val_d_part1   <= 
    ((dir_row34_val_l2
         and not (gate_and((iu3_parity_tag_cacheline = "100010"),  iu3_any_parity_err_way)) )  
     or (gate_and((icm_icd_dir_val and reload_cacheline = "100010"),  icm_icd_reload_way)))       
 and not (gate_and((icm_icd_dir_inval and reload_cacheline = "100010"),  icm_icd_reload_way))    
 and not (gate_and((icm_icd_ecc_inval and ecc_inval_cacheline = "100010"),  icm_icd_ecc_way))       
 and not (xu_iu_ici_l2 & xu_iu_ici_l2 & xu_iu_ici_l2 & xu_iu_ici_l2);
dir_row34_val_d_part2a   <=  gate_and(iu2_inval_l2 and (iu2_ifar_eff_cacheline = "100010"),  dir_row34_val_l2);
dir_row34_val_d_part2_b   <=  not(dir_row34_val_d_part2a  and iu2_rd_way_tag_hit);
dir_row34_val_d   <=  dir_row34_val_d_part1  and dir_row34_val_d_part2_b;
dir_row35_val_d_part1   <= 
    ((dir_row35_val_l2
         and not (gate_and((iu3_parity_tag_cacheline = "100011"),  iu3_any_parity_err_way)) )  
     or (gate_and((icm_icd_dir_val and reload_cacheline = "100011"),  icm_icd_reload_way)))       
 and not (gate_and((icm_icd_dir_inval and reload_cacheline = "100011"),  icm_icd_reload_way))    
 and not (gate_and((icm_icd_ecc_inval and ecc_inval_cacheline = "100011"),  icm_icd_ecc_way))       
 and not (xu_iu_ici_l2 & xu_iu_ici_l2 & xu_iu_ici_l2 & xu_iu_ici_l2);
dir_row35_val_d_part2a   <=  gate_and(iu2_inval_l2 and (iu2_ifar_eff_cacheline = "100011"),  dir_row35_val_l2);
dir_row35_val_d_part2_b   <=  not(dir_row35_val_d_part2a  and iu2_rd_way_tag_hit);
dir_row35_val_d   <=  dir_row35_val_d_part1  and dir_row35_val_d_part2_b;
dir_row36_val_d_part1   <= 
    ((dir_row36_val_l2
         and not (gate_and((iu3_parity_tag_cacheline = "100100"),  iu3_any_parity_err_way)) )  
     or (gate_and((icm_icd_dir_val and reload_cacheline = "100100"),  icm_icd_reload_way)))       
 and not (gate_and((icm_icd_dir_inval and reload_cacheline = "100100"),  icm_icd_reload_way))    
 and not (gate_and((icm_icd_ecc_inval and ecc_inval_cacheline = "100100"),  icm_icd_ecc_way))       
 and not (xu_iu_ici_l2 & xu_iu_ici_l2 & xu_iu_ici_l2 & xu_iu_ici_l2);
dir_row36_val_d_part2a   <=  gate_and(iu2_inval_l2 and (iu2_ifar_eff_cacheline = "100100"),  dir_row36_val_l2);
dir_row36_val_d_part2_b   <=  not(dir_row36_val_d_part2a  and iu2_rd_way_tag_hit);
dir_row36_val_d   <=  dir_row36_val_d_part1  and dir_row36_val_d_part2_b;
dir_row37_val_d_part1   <= 
    ((dir_row37_val_l2
         and not (gate_and((iu3_parity_tag_cacheline = "100101"),  iu3_any_parity_err_way)) )  
     or (gate_and((icm_icd_dir_val and reload_cacheline = "100101"),  icm_icd_reload_way)))       
 and not (gate_and((icm_icd_dir_inval and reload_cacheline = "100101"),  icm_icd_reload_way))    
 and not (gate_and((icm_icd_ecc_inval and ecc_inval_cacheline = "100101"),  icm_icd_ecc_way))       
 and not (xu_iu_ici_l2 & xu_iu_ici_l2 & xu_iu_ici_l2 & xu_iu_ici_l2);
dir_row37_val_d_part2a   <=  gate_and(iu2_inval_l2 and (iu2_ifar_eff_cacheline = "100101"),  dir_row37_val_l2);
dir_row37_val_d_part2_b   <=  not(dir_row37_val_d_part2a  and iu2_rd_way_tag_hit);
dir_row37_val_d   <=  dir_row37_val_d_part1  and dir_row37_val_d_part2_b;
dir_row38_val_d_part1   <= 
    ((dir_row38_val_l2
         and not (gate_and((iu3_parity_tag_cacheline = "100110"),  iu3_any_parity_err_way)) )  
     or (gate_and((icm_icd_dir_val and reload_cacheline = "100110"),  icm_icd_reload_way)))       
 and not (gate_and((icm_icd_dir_inval and reload_cacheline = "100110"),  icm_icd_reload_way))    
 and not (gate_and((icm_icd_ecc_inval and ecc_inval_cacheline = "100110"),  icm_icd_ecc_way))       
 and not (xu_iu_ici_l2 & xu_iu_ici_l2 & xu_iu_ici_l2 & xu_iu_ici_l2);
dir_row38_val_d_part2a   <=  gate_and(iu2_inval_l2 and (iu2_ifar_eff_cacheline = "100110"),  dir_row38_val_l2);
dir_row38_val_d_part2_b   <=  not(dir_row38_val_d_part2a  and iu2_rd_way_tag_hit);
dir_row38_val_d   <=  dir_row38_val_d_part1  and dir_row38_val_d_part2_b;
dir_row39_val_d_part1   <= 
    ((dir_row39_val_l2
         and not (gate_and((iu3_parity_tag_cacheline = "100111"),  iu3_any_parity_err_way)) )  
     or (gate_and((icm_icd_dir_val and reload_cacheline = "100111"),  icm_icd_reload_way)))       
 and not (gate_and((icm_icd_dir_inval and reload_cacheline = "100111"),  icm_icd_reload_way))    
 and not (gate_and((icm_icd_ecc_inval and ecc_inval_cacheline = "100111"),  icm_icd_ecc_way))       
 and not (xu_iu_ici_l2 & xu_iu_ici_l2 & xu_iu_ici_l2 & xu_iu_ici_l2);
dir_row39_val_d_part2a   <=  gate_and(iu2_inval_l2 and (iu2_ifar_eff_cacheline = "100111"),  dir_row39_val_l2);
dir_row39_val_d_part2_b   <=  not(dir_row39_val_d_part2a  and iu2_rd_way_tag_hit);
dir_row39_val_d   <=  dir_row39_val_d_part1  and dir_row39_val_d_part2_b;
dir_row40_val_d_part1   <= 
    ((dir_row40_val_l2
         and not (gate_and((iu3_parity_tag_cacheline = "101000"),  iu3_any_parity_err_way)) )  
     or (gate_and((icm_icd_dir_val and reload_cacheline = "101000"),  icm_icd_reload_way)))       
 and not (gate_and((icm_icd_dir_inval and reload_cacheline = "101000"),  icm_icd_reload_way))    
 and not (gate_and((icm_icd_ecc_inval and ecc_inval_cacheline = "101000"),  icm_icd_ecc_way))       
 and not (xu_iu_ici_l2 & xu_iu_ici_l2 & xu_iu_ici_l2 & xu_iu_ici_l2);
dir_row40_val_d_part2a   <=  gate_and(iu2_inval_l2 and (iu2_ifar_eff_cacheline = "101000"),  dir_row40_val_l2);
dir_row40_val_d_part2_b   <=  not(dir_row40_val_d_part2a  and iu2_rd_way_tag_hit);
dir_row40_val_d   <=  dir_row40_val_d_part1  and dir_row40_val_d_part2_b;
dir_row41_val_d_part1   <= 
    ((dir_row41_val_l2
         and not (gate_and((iu3_parity_tag_cacheline = "101001"),  iu3_any_parity_err_way)) )  
     or (gate_and((icm_icd_dir_val and reload_cacheline = "101001"),  icm_icd_reload_way)))       
 and not (gate_and((icm_icd_dir_inval and reload_cacheline = "101001"),  icm_icd_reload_way))    
 and not (gate_and((icm_icd_ecc_inval and ecc_inval_cacheline = "101001"),  icm_icd_ecc_way))       
 and not (xu_iu_ici_l2 & xu_iu_ici_l2 & xu_iu_ici_l2 & xu_iu_ici_l2);
dir_row41_val_d_part2a   <=  gate_and(iu2_inval_l2 and (iu2_ifar_eff_cacheline = "101001"),  dir_row41_val_l2);
dir_row41_val_d_part2_b   <=  not(dir_row41_val_d_part2a  and iu2_rd_way_tag_hit);
dir_row41_val_d   <=  dir_row41_val_d_part1  and dir_row41_val_d_part2_b;
dir_row42_val_d_part1   <= 
    ((dir_row42_val_l2
         and not (gate_and((iu3_parity_tag_cacheline = "101010"),  iu3_any_parity_err_way)) )  
     or (gate_and((icm_icd_dir_val and reload_cacheline = "101010"),  icm_icd_reload_way)))       
 and not (gate_and((icm_icd_dir_inval and reload_cacheline = "101010"),  icm_icd_reload_way))    
 and not (gate_and((icm_icd_ecc_inval and ecc_inval_cacheline = "101010"),  icm_icd_ecc_way))       
 and not (xu_iu_ici_l2 & xu_iu_ici_l2 & xu_iu_ici_l2 & xu_iu_ici_l2);
dir_row42_val_d_part2a   <=  gate_and(iu2_inval_l2 and (iu2_ifar_eff_cacheline = "101010"),  dir_row42_val_l2);
dir_row42_val_d_part2_b   <=  not(dir_row42_val_d_part2a  and iu2_rd_way_tag_hit);
dir_row42_val_d   <=  dir_row42_val_d_part1  and dir_row42_val_d_part2_b;
dir_row43_val_d_part1   <= 
    ((dir_row43_val_l2
         and not (gate_and((iu3_parity_tag_cacheline = "101011"),  iu3_any_parity_err_way)) )  
     or (gate_and((icm_icd_dir_val and reload_cacheline = "101011"),  icm_icd_reload_way)))       
 and not (gate_and((icm_icd_dir_inval and reload_cacheline = "101011"),  icm_icd_reload_way))    
 and not (gate_and((icm_icd_ecc_inval and ecc_inval_cacheline = "101011"),  icm_icd_ecc_way))       
 and not (xu_iu_ici_l2 & xu_iu_ici_l2 & xu_iu_ici_l2 & xu_iu_ici_l2);
dir_row43_val_d_part2a   <=  gate_and(iu2_inval_l2 and (iu2_ifar_eff_cacheline = "101011"),  dir_row43_val_l2);
dir_row43_val_d_part2_b   <=  not(dir_row43_val_d_part2a  and iu2_rd_way_tag_hit);
dir_row43_val_d   <=  dir_row43_val_d_part1  and dir_row43_val_d_part2_b;
dir_row44_val_d_part1   <= 
    ((dir_row44_val_l2
         and not (gate_and((iu3_parity_tag_cacheline = "101100"),  iu3_any_parity_err_way)) )  
     or (gate_and((icm_icd_dir_val and reload_cacheline = "101100"),  icm_icd_reload_way)))       
 and not (gate_and((icm_icd_dir_inval and reload_cacheline = "101100"),  icm_icd_reload_way))    
 and not (gate_and((icm_icd_ecc_inval and ecc_inval_cacheline = "101100"),  icm_icd_ecc_way))       
 and not (xu_iu_ici_l2 & xu_iu_ici_l2 & xu_iu_ici_l2 & xu_iu_ici_l2);
dir_row44_val_d_part2a   <=  gate_and(iu2_inval_l2 and (iu2_ifar_eff_cacheline = "101100"),  dir_row44_val_l2);
dir_row44_val_d_part2_b   <=  not(dir_row44_val_d_part2a  and iu2_rd_way_tag_hit);
dir_row44_val_d   <=  dir_row44_val_d_part1  and dir_row44_val_d_part2_b;
dir_row45_val_d_part1   <= 
    ((dir_row45_val_l2
         and not (gate_and((iu3_parity_tag_cacheline = "101101"),  iu3_any_parity_err_way)) )  
     or (gate_and((icm_icd_dir_val and reload_cacheline = "101101"),  icm_icd_reload_way)))       
 and not (gate_and((icm_icd_dir_inval and reload_cacheline = "101101"),  icm_icd_reload_way))    
 and not (gate_and((icm_icd_ecc_inval and ecc_inval_cacheline = "101101"),  icm_icd_ecc_way))       
 and not (xu_iu_ici_l2 & xu_iu_ici_l2 & xu_iu_ici_l2 & xu_iu_ici_l2);
dir_row45_val_d_part2a   <=  gate_and(iu2_inval_l2 and (iu2_ifar_eff_cacheline = "101101"),  dir_row45_val_l2);
dir_row45_val_d_part2_b   <=  not(dir_row45_val_d_part2a  and iu2_rd_way_tag_hit);
dir_row45_val_d   <=  dir_row45_val_d_part1  and dir_row45_val_d_part2_b;
dir_row46_val_d_part1   <= 
    ((dir_row46_val_l2
         and not (gate_and((iu3_parity_tag_cacheline = "101110"),  iu3_any_parity_err_way)) )  
     or (gate_and((icm_icd_dir_val and reload_cacheline = "101110"),  icm_icd_reload_way)))       
 and not (gate_and((icm_icd_dir_inval and reload_cacheline = "101110"),  icm_icd_reload_way))    
 and not (gate_and((icm_icd_ecc_inval and ecc_inval_cacheline = "101110"),  icm_icd_ecc_way))       
 and not (xu_iu_ici_l2 & xu_iu_ici_l2 & xu_iu_ici_l2 & xu_iu_ici_l2);
dir_row46_val_d_part2a   <=  gate_and(iu2_inval_l2 and (iu2_ifar_eff_cacheline = "101110"),  dir_row46_val_l2);
dir_row46_val_d_part2_b   <=  not(dir_row46_val_d_part2a  and iu2_rd_way_tag_hit);
dir_row46_val_d   <=  dir_row46_val_d_part1  and dir_row46_val_d_part2_b;
dir_row47_val_d_part1   <= 
    ((dir_row47_val_l2
         and not (gate_and((iu3_parity_tag_cacheline = "101111"),  iu3_any_parity_err_way)) )  
     or (gate_and((icm_icd_dir_val and reload_cacheline = "101111"),  icm_icd_reload_way)))       
 and not (gate_and((icm_icd_dir_inval and reload_cacheline = "101111"),  icm_icd_reload_way))    
 and not (gate_and((icm_icd_ecc_inval and ecc_inval_cacheline = "101111"),  icm_icd_ecc_way))       
 and not (xu_iu_ici_l2 & xu_iu_ici_l2 & xu_iu_ici_l2 & xu_iu_ici_l2);
dir_row47_val_d_part2a   <=  gate_and(iu2_inval_l2 and (iu2_ifar_eff_cacheline = "101111"),  dir_row47_val_l2);
dir_row47_val_d_part2_b   <=  not(dir_row47_val_d_part2a  and iu2_rd_way_tag_hit);
dir_row47_val_d   <=  dir_row47_val_d_part1  and dir_row47_val_d_part2_b;
dir_row48_val_d_part1   <= 
    ((dir_row48_val_l2
         and not (gate_and((iu3_parity_tag_cacheline = "110000"),  iu3_any_parity_err_way)) )  
     or (gate_and((icm_icd_dir_val and reload_cacheline = "110000"),  icm_icd_reload_way)))       
 and not (gate_and((icm_icd_dir_inval and reload_cacheline = "110000"),  icm_icd_reload_way))    
 and not (gate_and((icm_icd_ecc_inval and ecc_inval_cacheline = "110000"),  icm_icd_ecc_way))       
 and not (xu_iu_ici_l2 & xu_iu_ici_l2 & xu_iu_ici_l2 & xu_iu_ici_l2);
dir_row48_val_d_part2a   <=  gate_and(iu2_inval_l2 and (iu2_ifar_eff_cacheline = "110000"),  dir_row48_val_l2);
dir_row48_val_d_part2_b   <=  not(dir_row48_val_d_part2a  and iu2_rd_way_tag_hit);
dir_row48_val_d   <=  dir_row48_val_d_part1  and dir_row48_val_d_part2_b;
dir_row49_val_d_part1   <= 
    ((dir_row49_val_l2
         and not (gate_and((iu3_parity_tag_cacheline = "110001"),  iu3_any_parity_err_way)) )  
     or (gate_and((icm_icd_dir_val and reload_cacheline = "110001"),  icm_icd_reload_way)))       
 and not (gate_and((icm_icd_dir_inval and reload_cacheline = "110001"),  icm_icd_reload_way))    
 and not (gate_and((icm_icd_ecc_inval and ecc_inval_cacheline = "110001"),  icm_icd_ecc_way))       
 and not (xu_iu_ici_l2 & xu_iu_ici_l2 & xu_iu_ici_l2 & xu_iu_ici_l2);
dir_row49_val_d_part2a   <=  gate_and(iu2_inval_l2 and (iu2_ifar_eff_cacheline = "110001"),  dir_row49_val_l2);
dir_row49_val_d_part2_b   <=  not(dir_row49_val_d_part2a  and iu2_rd_way_tag_hit);
dir_row49_val_d   <=  dir_row49_val_d_part1  and dir_row49_val_d_part2_b;
dir_row50_val_d_part1   <= 
    ((dir_row50_val_l2
         and not (gate_and((iu3_parity_tag_cacheline = "110010"),  iu3_any_parity_err_way)) )  
     or (gate_and((icm_icd_dir_val and reload_cacheline = "110010"),  icm_icd_reload_way)))       
 and not (gate_and((icm_icd_dir_inval and reload_cacheline = "110010"),  icm_icd_reload_way))    
 and not (gate_and((icm_icd_ecc_inval and ecc_inval_cacheline = "110010"),  icm_icd_ecc_way))       
 and not (xu_iu_ici_l2 & xu_iu_ici_l2 & xu_iu_ici_l2 & xu_iu_ici_l2);
dir_row50_val_d_part2a   <=  gate_and(iu2_inval_l2 and (iu2_ifar_eff_cacheline = "110010"),  dir_row50_val_l2);
dir_row50_val_d_part2_b   <=  not(dir_row50_val_d_part2a  and iu2_rd_way_tag_hit);
dir_row50_val_d   <=  dir_row50_val_d_part1  and dir_row50_val_d_part2_b;
dir_row51_val_d_part1   <= 
    ((dir_row51_val_l2
         and not (gate_and((iu3_parity_tag_cacheline = "110011"),  iu3_any_parity_err_way)) )  
     or (gate_and((icm_icd_dir_val and reload_cacheline = "110011"),  icm_icd_reload_way)))       
 and not (gate_and((icm_icd_dir_inval and reload_cacheline = "110011"),  icm_icd_reload_way))    
 and not (gate_and((icm_icd_ecc_inval and ecc_inval_cacheline = "110011"),  icm_icd_ecc_way))       
 and not (xu_iu_ici_l2 & xu_iu_ici_l2 & xu_iu_ici_l2 & xu_iu_ici_l2);
dir_row51_val_d_part2a   <=  gate_and(iu2_inval_l2 and (iu2_ifar_eff_cacheline = "110011"),  dir_row51_val_l2);
dir_row51_val_d_part2_b   <=  not(dir_row51_val_d_part2a  and iu2_rd_way_tag_hit);
dir_row51_val_d   <=  dir_row51_val_d_part1  and dir_row51_val_d_part2_b;
dir_row52_val_d_part1   <= 
    ((dir_row52_val_l2
         and not (gate_and((iu3_parity_tag_cacheline = "110100"),  iu3_any_parity_err_way)) )  
     or (gate_and((icm_icd_dir_val and reload_cacheline = "110100"),  icm_icd_reload_way)))       
 and not (gate_and((icm_icd_dir_inval and reload_cacheline = "110100"),  icm_icd_reload_way))    
 and not (gate_and((icm_icd_ecc_inval and ecc_inval_cacheline = "110100"),  icm_icd_ecc_way))       
 and not (xu_iu_ici_l2 & xu_iu_ici_l2 & xu_iu_ici_l2 & xu_iu_ici_l2);
dir_row52_val_d_part2a   <=  gate_and(iu2_inval_l2 and (iu2_ifar_eff_cacheline = "110100"),  dir_row52_val_l2);
dir_row52_val_d_part2_b   <=  not(dir_row52_val_d_part2a  and iu2_rd_way_tag_hit);
dir_row52_val_d   <=  dir_row52_val_d_part1  and dir_row52_val_d_part2_b;
dir_row53_val_d_part1   <= 
    ((dir_row53_val_l2
         and not (gate_and((iu3_parity_tag_cacheline = "110101"),  iu3_any_parity_err_way)) )  
     or (gate_and((icm_icd_dir_val and reload_cacheline = "110101"),  icm_icd_reload_way)))       
 and not (gate_and((icm_icd_dir_inval and reload_cacheline = "110101"),  icm_icd_reload_way))    
 and not (gate_and((icm_icd_ecc_inval and ecc_inval_cacheline = "110101"),  icm_icd_ecc_way))       
 and not (xu_iu_ici_l2 & xu_iu_ici_l2 & xu_iu_ici_l2 & xu_iu_ici_l2);
dir_row53_val_d_part2a   <=  gate_and(iu2_inval_l2 and (iu2_ifar_eff_cacheline = "110101"),  dir_row53_val_l2);
dir_row53_val_d_part2_b   <=  not(dir_row53_val_d_part2a  and iu2_rd_way_tag_hit);
dir_row53_val_d   <=  dir_row53_val_d_part1  and dir_row53_val_d_part2_b;
dir_row54_val_d_part1   <= 
    ((dir_row54_val_l2
         and not (gate_and((iu3_parity_tag_cacheline = "110110"),  iu3_any_parity_err_way)) )  
     or (gate_and((icm_icd_dir_val and reload_cacheline = "110110"),  icm_icd_reload_way)))       
 and not (gate_and((icm_icd_dir_inval and reload_cacheline = "110110"),  icm_icd_reload_way))    
 and not (gate_and((icm_icd_ecc_inval and ecc_inval_cacheline = "110110"),  icm_icd_ecc_way))       
 and not (xu_iu_ici_l2 & xu_iu_ici_l2 & xu_iu_ici_l2 & xu_iu_ici_l2);
dir_row54_val_d_part2a   <=  gate_and(iu2_inval_l2 and (iu2_ifar_eff_cacheline = "110110"),  dir_row54_val_l2);
dir_row54_val_d_part2_b   <=  not(dir_row54_val_d_part2a  and iu2_rd_way_tag_hit);
dir_row54_val_d   <=  dir_row54_val_d_part1  and dir_row54_val_d_part2_b;
dir_row55_val_d_part1   <= 
    ((dir_row55_val_l2
         and not (gate_and((iu3_parity_tag_cacheline = "110111"),  iu3_any_parity_err_way)) )  
     or (gate_and((icm_icd_dir_val and reload_cacheline = "110111"),  icm_icd_reload_way)))       
 and not (gate_and((icm_icd_dir_inval and reload_cacheline = "110111"),  icm_icd_reload_way))    
 and not (gate_and((icm_icd_ecc_inval and ecc_inval_cacheline = "110111"),  icm_icd_ecc_way))       
 and not (xu_iu_ici_l2 & xu_iu_ici_l2 & xu_iu_ici_l2 & xu_iu_ici_l2);
dir_row55_val_d_part2a   <=  gate_and(iu2_inval_l2 and (iu2_ifar_eff_cacheline = "110111"),  dir_row55_val_l2);
dir_row55_val_d_part2_b   <=  not(dir_row55_val_d_part2a  and iu2_rd_way_tag_hit);
dir_row55_val_d   <=  dir_row55_val_d_part1  and dir_row55_val_d_part2_b;
dir_row56_val_d_part1   <= 
    ((dir_row56_val_l2
         and not (gate_and((iu3_parity_tag_cacheline = "111000"),  iu3_any_parity_err_way)) )  
     or (gate_and((icm_icd_dir_val and reload_cacheline = "111000"),  icm_icd_reload_way)))       
 and not (gate_and((icm_icd_dir_inval and reload_cacheline = "111000"),  icm_icd_reload_way))    
 and not (gate_and((icm_icd_ecc_inval and ecc_inval_cacheline = "111000"),  icm_icd_ecc_way))       
 and not (xu_iu_ici_l2 & xu_iu_ici_l2 & xu_iu_ici_l2 & xu_iu_ici_l2);
dir_row56_val_d_part2a   <=  gate_and(iu2_inval_l2 and (iu2_ifar_eff_cacheline = "111000"),  dir_row56_val_l2);
dir_row56_val_d_part2_b   <=  not(dir_row56_val_d_part2a  and iu2_rd_way_tag_hit);
dir_row56_val_d   <=  dir_row56_val_d_part1  and dir_row56_val_d_part2_b;
dir_row57_val_d_part1   <= 
    ((dir_row57_val_l2
         and not (gate_and((iu3_parity_tag_cacheline = "111001"),  iu3_any_parity_err_way)) )  
     or (gate_and((icm_icd_dir_val and reload_cacheline = "111001"),  icm_icd_reload_way)))       
 and not (gate_and((icm_icd_dir_inval and reload_cacheline = "111001"),  icm_icd_reload_way))    
 and not (gate_and((icm_icd_ecc_inval and ecc_inval_cacheline = "111001"),  icm_icd_ecc_way))       
 and not (xu_iu_ici_l2 & xu_iu_ici_l2 & xu_iu_ici_l2 & xu_iu_ici_l2);
dir_row57_val_d_part2a   <=  gate_and(iu2_inval_l2 and (iu2_ifar_eff_cacheline = "111001"),  dir_row57_val_l2);
dir_row57_val_d_part2_b   <=  not(dir_row57_val_d_part2a  and iu2_rd_way_tag_hit);
dir_row57_val_d   <=  dir_row57_val_d_part1  and dir_row57_val_d_part2_b;
dir_row58_val_d_part1   <= 
    ((dir_row58_val_l2
         and not (gate_and((iu3_parity_tag_cacheline = "111010"),  iu3_any_parity_err_way)) )  
     or (gate_and((icm_icd_dir_val and reload_cacheline = "111010"),  icm_icd_reload_way)))       
 and not (gate_and((icm_icd_dir_inval and reload_cacheline = "111010"),  icm_icd_reload_way))    
 and not (gate_and((icm_icd_ecc_inval and ecc_inval_cacheline = "111010"),  icm_icd_ecc_way))       
 and not (xu_iu_ici_l2 & xu_iu_ici_l2 & xu_iu_ici_l2 & xu_iu_ici_l2);
dir_row58_val_d_part2a   <=  gate_and(iu2_inval_l2 and (iu2_ifar_eff_cacheline = "111010"),  dir_row58_val_l2);
dir_row58_val_d_part2_b   <=  not(dir_row58_val_d_part2a  and iu2_rd_way_tag_hit);
dir_row58_val_d   <=  dir_row58_val_d_part1  and dir_row58_val_d_part2_b;
dir_row59_val_d_part1   <= 
    ((dir_row59_val_l2
         and not (gate_and((iu3_parity_tag_cacheline = "111011"),  iu3_any_parity_err_way)) )  
     or (gate_and((icm_icd_dir_val and reload_cacheline = "111011"),  icm_icd_reload_way)))       
 and not (gate_and((icm_icd_dir_inval and reload_cacheline = "111011"),  icm_icd_reload_way))    
 and not (gate_and((icm_icd_ecc_inval and ecc_inval_cacheline = "111011"),  icm_icd_ecc_way))       
 and not (xu_iu_ici_l2 & xu_iu_ici_l2 & xu_iu_ici_l2 & xu_iu_ici_l2);
dir_row59_val_d_part2a   <=  gate_and(iu2_inval_l2 and (iu2_ifar_eff_cacheline = "111011"),  dir_row59_val_l2);
dir_row59_val_d_part2_b   <=  not(dir_row59_val_d_part2a  and iu2_rd_way_tag_hit);
dir_row59_val_d   <=  dir_row59_val_d_part1  and dir_row59_val_d_part2_b;
dir_row60_val_d_part1   <= 
    ((dir_row60_val_l2
         and not (gate_and((iu3_parity_tag_cacheline = "111100"),  iu3_any_parity_err_way)) )  
     or (gate_and((icm_icd_dir_val and reload_cacheline = "111100"),  icm_icd_reload_way)))       
 and not (gate_and((icm_icd_dir_inval and reload_cacheline = "111100"),  icm_icd_reload_way))    
 and not (gate_and((icm_icd_ecc_inval and ecc_inval_cacheline = "111100"),  icm_icd_ecc_way))       
 and not (xu_iu_ici_l2 & xu_iu_ici_l2 & xu_iu_ici_l2 & xu_iu_ici_l2);
dir_row60_val_d_part2a   <=  gate_and(iu2_inval_l2 and (iu2_ifar_eff_cacheline = "111100"),  dir_row60_val_l2);
dir_row60_val_d_part2_b   <=  not(dir_row60_val_d_part2a  and iu2_rd_way_tag_hit);
dir_row60_val_d   <=  dir_row60_val_d_part1  and dir_row60_val_d_part2_b;
dir_row61_val_d_part1   <= 
    ((dir_row61_val_l2
         and not (gate_and((iu3_parity_tag_cacheline = "111101"),  iu3_any_parity_err_way)) )  
     or (gate_and((icm_icd_dir_val and reload_cacheline = "111101"),  icm_icd_reload_way)))       
 and not (gate_and((icm_icd_dir_inval and reload_cacheline = "111101"),  icm_icd_reload_way))    
 and not (gate_and((icm_icd_ecc_inval and ecc_inval_cacheline = "111101"),  icm_icd_ecc_way))       
 and not (xu_iu_ici_l2 & xu_iu_ici_l2 & xu_iu_ici_l2 & xu_iu_ici_l2);
dir_row61_val_d_part2a   <=  gate_and(iu2_inval_l2 and (iu2_ifar_eff_cacheline = "111101"),  dir_row61_val_l2);
dir_row61_val_d_part2_b   <=  not(dir_row61_val_d_part2a  and iu2_rd_way_tag_hit);
dir_row61_val_d   <=  dir_row61_val_d_part1  and dir_row61_val_d_part2_b;
dir_row62_val_d_part1   <= 
    ((dir_row62_val_l2
         and not (gate_and((iu3_parity_tag_cacheline = "111110"),  iu3_any_parity_err_way)) )  
     or (gate_and((icm_icd_dir_val and reload_cacheline = "111110"),  icm_icd_reload_way)))       
 and not (gate_and((icm_icd_dir_inval and reload_cacheline = "111110"),  icm_icd_reload_way))    
 and not (gate_and((icm_icd_ecc_inval and ecc_inval_cacheline = "111110"),  icm_icd_ecc_way))       
 and not (xu_iu_ici_l2 & xu_iu_ici_l2 & xu_iu_ici_l2 & xu_iu_ici_l2);
dir_row62_val_d_part2a   <=  gate_and(iu2_inval_l2 and (iu2_ifar_eff_cacheline = "111110"),  dir_row62_val_l2);
dir_row62_val_d_part2_b   <=  not(dir_row62_val_d_part2a  and iu2_rd_way_tag_hit);
dir_row62_val_d   <=  dir_row62_val_d_part1  and dir_row62_val_d_part2_b;
dir_row63_val_d_part1   <= 
    ((dir_row63_val_l2
         and not (gate_and((iu3_parity_tag_cacheline = "111111"),  iu3_any_parity_err_way)) )  
     or (gate_and((icm_icd_dir_val and reload_cacheline = "111111"),  icm_icd_reload_way)))       
 and not (gate_and((icm_icd_dir_inval and reload_cacheline = "111111"),  icm_icd_reload_way))    
 and not (gate_and((icm_icd_ecc_inval and ecc_inval_cacheline = "111111"),  icm_icd_ecc_way))       
 and not (xu_iu_ici_l2 & xu_iu_ici_l2 & xu_iu_ici_l2 & xu_iu_ici_l2);
dir_row63_val_d_part2a   <=  gate_and(iu2_inval_l2 and (iu2_ifar_eff_cacheline = "111111"),  dir_row63_val_l2);
dir_row63_val_d_part2_b   <=  not(dir_row63_val_d_part2a  and iu2_rd_way_tag_hit);
dir_row63_val_d   <=  dir_row63_val_d_part1  and dir_row63_val_d_part2_b;
dir_row_val_even_act  <=  xu_iu_ici_l2 or
                       (or_reduce(iu3_any_parity_err_way) and (iu3_parity_tag_cacheline(5) = '0')) or
                       (icm_icd_any_reld_r2 and (reload_cacheline(5) = '0')) or
                       (icm_icd_any_checkecc and (ecc_inval_cacheline(5) = '0')) or
                       (iu2_inval_l2 and (iu2_ifar_eff_cacheline(5) = '0'));
dir_row_val_odd_act   <=  xu_iu_ici_l2 or
                       (or_reduce(iu3_any_parity_err_way) and (iu3_parity_tag_cacheline(5) = '1')) or
                       (icm_icd_any_reld_r2 and (reload_cacheline(5) = '1')) or
                       (icm_icd_any_checkecc and (ecc_inval_cacheline(5) = '1')) or
                       (iu2_inval_l2 and (iu2_ifar_eff_cacheline(5) = '1'));
lru_select  <=  icm_icd_lru_addr(52 to 56) & (icm_icd_lru_addr(57) and not spr_ic_cls_l2);
-- ic miss latches the location for data write to prevent data from moving around in Data cache
with lru_select select
return_lru  <=  dir_row0_lru_l2  when "000000",
              dir_row1_lru_l2    when "000001",
              dir_row2_lru_l2    when "000010",
              dir_row3_lru_l2    when "000011",
              dir_row4_lru_l2    when "000100",
              dir_row5_lru_l2    when "000101",
              dir_row6_lru_l2    when "000110",
              dir_row7_lru_l2    when "000111",
              dir_row8_lru_l2    when "001000",
              dir_row9_lru_l2    when "001001",
              dir_row10_lru_l2   when "001010",
              dir_row11_lru_l2   when "001011",
              dir_row12_lru_l2   when "001100",
              dir_row13_lru_l2   when "001101",
              dir_row14_lru_l2   when "001110",
              dir_row15_lru_l2   when "001111",
              dir_row16_lru_l2   when "010000",
              dir_row17_lru_l2   when "010001",
              dir_row18_lru_l2   when "010010",
              dir_row19_lru_l2   when "010011",
              dir_row20_lru_l2   when "010100",
              dir_row21_lru_l2   when "010101",
              dir_row22_lru_l2   when "010110",
              dir_row23_lru_l2   when "010111",
              dir_row24_lru_l2   when "011000",
              dir_row25_lru_l2   when "011001",
              dir_row26_lru_l2   when "011010",
              dir_row27_lru_l2   when "011011",
              dir_row28_lru_l2   when "011100",
              dir_row29_lru_l2   when "011101",
              dir_row30_lru_l2   when "011110",
              dir_row31_lru_l2   when "011111",
              dir_row32_lru_l2   when "100000",
              dir_row33_lru_l2   when "100001",
              dir_row34_lru_l2   when "100010",
              dir_row35_lru_l2   when "100011",
              dir_row36_lru_l2   when "100100",
              dir_row37_lru_l2   when "100101",
              dir_row38_lru_l2   when "100110",
              dir_row39_lru_l2   when "100111",
              dir_row40_lru_l2   when "101000",
              dir_row41_lru_l2   when "101001",
              dir_row42_lru_l2   when "101010",
              dir_row43_lru_l2   when "101011",
              dir_row44_lru_l2   when "101100",
              dir_row45_lru_l2   when "101101",
              dir_row46_lru_l2   when "101110",
              dir_row47_lru_l2   when "101111",
              dir_row48_lru_l2   when "110000",
              dir_row49_lru_l2   when "110001",
              dir_row50_lru_l2   when "110010",
              dir_row51_lru_l2   when "110011",
              dir_row52_lru_l2   when "110100",
              dir_row53_lru_l2   when "110101",
              dir_row54_lru_l2   when "110110",
              dir_row55_lru_l2   when "110111",
              dir_row56_lru_l2   when "111000",
              dir_row57_lru_l2   when "111001",
              dir_row58_lru_l2   when "111010",
              dir_row59_lru_l2   when "111011",
              dir_row60_lru_l2   when "111100",
              dir_row61_lru_l2   when "111101",
              dir_row62_lru_l2   when "111110",
              dir_row63_lru_l2 when others;
icd_icm_row_lru  <=  return_lru;
with lru_select select
return_val  <=  dir_row0_val_l2  when "000000",
              dir_row1_val_l2    when "000001",
              dir_row2_val_l2    when "000010",
              dir_row3_val_l2    when "000011",
              dir_row4_val_l2    when "000100",
              dir_row5_val_l2    when "000101",
              dir_row6_val_l2    when "000110",
              dir_row7_val_l2    when "000111",
              dir_row8_val_l2    when "001000",
              dir_row9_val_l2    when "001001",
              dir_row10_val_l2   when "001010",
              dir_row11_val_l2   when "001011",
              dir_row12_val_l2   when "001100",
              dir_row13_val_l2   when "001101",
              dir_row14_val_l2   when "001110",
              dir_row15_val_l2   when "001111",
              dir_row16_val_l2   when "010000",
              dir_row17_val_l2   when "010001",
              dir_row18_val_l2   when "010010",
              dir_row19_val_l2   when "010011",
              dir_row20_val_l2   when "010100",
              dir_row21_val_l2   when "010101",
              dir_row22_val_l2   when "010110",
              dir_row23_val_l2   when "010111",
              dir_row24_val_l2   when "011000",
              dir_row25_val_l2   when "011001",
              dir_row26_val_l2   when "011010",
              dir_row27_val_l2   when "011011",
              dir_row28_val_l2   when "011100",
              dir_row29_val_l2   when "011101",
              dir_row30_val_l2   when "011110",
              dir_row31_val_l2   when "011111",
              dir_row32_val_l2   when "100000",
              dir_row33_val_l2   when "100001",
              dir_row34_val_l2   when "100010",
              dir_row35_val_l2   when "100011",
              dir_row36_val_l2   when "100100",
              dir_row37_val_l2   when "100101",
              dir_row38_val_l2   when "100110",
              dir_row39_val_l2   when "100111",
              dir_row40_val_l2   when "101000",
              dir_row41_val_l2   when "101001",
              dir_row42_val_l2   when "101010",
              dir_row43_val_l2   when "101011",
              dir_row44_val_l2   when "101100",
              dir_row45_val_l2   when "101101",
              dir_row46_val_l2   when "101110",
              dir_row47_val_l2   when "101111",
              dir_row48_val_l2   when "110000",
              dir_row49_val_l2   when "110001",
              dir_row50_val_l2   when "110010",
              dir_row51_val_l2   when "110011",
              dir_row52_val_l2   when "110100",
              dir_row53_val_l2   when "110101",
              dir_row54_val_l2   when "110110",
              dir_row55_val_l2   when "110111",
              dir_row56_val_l2   when "111000",
              dir_row57_val_l2   when "111001",
              dir_row58_val_l2   when "111010",
              dir_row59_val_l2   when "111011",
              dir_row60_val_l2   when "111100",
              dir_row61_val_l2   when "111101",
              dir_row62_val_l2   when "111110",
              dir_row63_val_l2 when others;
icd_icm_row_val  <=  return_val;
-----------------------------------------------------------------------
-- IU2
-----------------------------------------------------------------------
-- IU2 Output
mm_epn: for i in 0 to 51 generate
begin
  R0:if(i <  EFF_IFAR'left) generate begin iu_mm_ierat_epn(i) <= '0';
end generate;
R1:if(i >= EFF_IFAR'left) generate
begin iu_mm_ierat_epn(i) <=  iu2_ifar_eff_l2(i);
end generate;
end generate;
-- Handle Miss
iu2_rd_miss  <=  iu2_valid and (iu2_dir_miss or iu2_ci);
iu3_rd_parity_err_d  <=  iu2_valid and iu2_rd_parity_err and or_reduce(iu2_tid_l2 and not ics_icd_iu2_flush_tid) and not iu2_ci;
iu3_rd_miss_d  <=  iu2_rd_miss and not or_reduce(iu2_tid_l2 and ics_icd_iu2_flush_tid);
iu3_rd_miss  <=  iu3_rd_miss_l2 and not iu3_erat_err_l2(0);
iu2_miss_flush_prev  <=  gate_and(iu3_rd_miss, iu3_tid_l2) and not ics_icd_all_flush_prev;
icd_icm_miss  <=  iu2_rd_miss;
icd_icm_tid   <=  iu2_tid_l2;
icd_icm_addr_real  <=  ierat_iu_iu2_rpn_noncmp(REAL_IFAR'left to 51) & iu2_ifar_eff_l2(52 to 61);
icd_icm_addr_eff   <=  iu2_ifar_eff_l2(EFF_IFAR'left to 51);
icd_icm_wimge  <=  ierat_iu_iu2_wimge;
icd_icm_userdef  <=  ierat_iu_iu2_u;
icd_icm_2ucode  <=  iu2_2ucode_l2;
icd_icm_2ucode_type  <=  iu2_2ucode_type_l2;
icd_icm_iu2_inval  <=  iu2_inval_l2;
icd_icm_ici  <=  xu_iu_ici_l2;
icd_icm_any_iu2_valid  <=  iu2_valid;
icd_ics_iu2_miss_flush_prev  <=  iu2_miss_flush_prev;
icd_ics_iu2_ifar_eff  <=  iu2_ifar_eff_l2;
icd_ics_iu2_2ucode  <=  iu2_2ucode_l2;
icd_ics_iu2_2ucode_type  <=  iu2_2ucode_type_l2;
load_iu2  <=  or_reduce(icm_icd_load_tid);
iu3_act  <=  iu2_valid or load_iu2;
iu3_valid_next  <=  (iu2_valid and or_reduce(iu2_tid_l2 and not ics_icd_iu2_flush_tid)) or  
             or_reduce(icm_icd_load_tid);
 WITH s3'(iu3_valid_next & iu3_ifar_d(60 to 61))  SELECT iu3_instr_valid_d(0 TO 3) <=  "1111" when "100",
                                   "1110" when "101",
                                   "1100" when "110",
                                   "1000" when "111",
                                   "0000" when others;
with load_iu2 select
iu3_tid_d  <=  iu2_tid_l2 when '0',
             icm_icd_load_tid when others;
with load_iu2 select
iu3_ifar_d  <=  iu2_ifar_eff_l2 when '0',
              icm_icd_load_addr when others;
iu3_2ucode_d  <=  icm_icd_load_2ucode when load_iu2 = '1'
           else iu2_2ucode_l2;
with load_iu2 select
iu3_2ucode_type_d  <=  iu2_2ucode_type_l2 when '0',
                     icm_icd_load_2ucode_type when others;
iu2_erat_err  <=  (ierat_iu_iu2_error(0) and not load_iu2) &
                (ierat_iu_iu2_error(1) and not load_iu2) &
                (ierat_iu_iu2_error(2) and not load_iu2);
iu3_erat_err_d  <=  iu2_erat_err;
-- Mux data from cache
iu2_data_dataout_0  <=  iu2_data_dataout_l2(  0 to 143);
iu2_data_dataout_1  <=  iu2_data_dataout_l2(162 to 305);
iu2_data_dataout_2  <=  iu2_data_dataout_l2(324 to 467);
iu2_data_dataout_3  <=  iu2_data_dataout_l2(486 to 629);
insmux : entity work.iuq_ic_insmux
  generic map( expand_type=> expand_type)
  port map(
       vdd                                       => vdd,
       gnd                                       => gnd,
       nclk                                      => nclk,
       delay_lclkr                               => delay_lclkr,
       mpw1_b                                    => mpw1_b,
       mpw2_b                                    => mpw2_b,
       forcee => forcee,
       sg_0                                      => pc_iu_sg_0,
       thold_0_b                                 => pc_iu_func_sl_thold_0_b,
       scan_in                                   => siv(iu3_instr_offset),
       scan_out                                  => sov(iu3_instr_offset),
       inslat_act                                => iu3_act,
       iu2_rd_way_hit_b                          => iu2_rd_way_hit_insmux_b,
       load_iu2                                  => load_iu2,
       icm_icd_reload_data                       => icm_icd_reload_data(0 to 143),
       iu2_data_dataout_0                        => iu2_data_dataout_0,
       iu2_data_dataout_1                        => iu2_data_dataout_1,
       iu2_data_dataout_2                        => iu2_data_dataout_2,
       iu2_data_dataout_3                        => iu2_data_dataout_3,
       iu3_instr0_buf                            => iu3_instr0_buf,
       iu3_instr1_buf                            => iu3_instr1_buf,
       iu3_instr2_buf                            => iu3_instr2_buf,
       iu3_instr3_buf                            => iu3_instr3_buf
);
 WITH s3'(iu2_erat_err(0) & iu3_ifar_d(60 to 61))  SELECT iu2_ifar_dec(0 TO 3) <=  "1000" when "000",
                                   "0100" when "001",
                                   "0010" when "010",
                                   "0001" when "011",
                                   "0000" when others;
iu3_ifar_dec_d  <=  iu2_ifar_dec;
-----------------------------------------------------------------------
-- IU3
-----------------------------------------------------------------------
-- Force 2ucode to 0 if branch instructions or no-op.  No other
-- instructions are legal when dynamically changing code.
-- Note: This signal does not include all non-ucode ops - just the ones
-- that will cause problems with flush_2ucode.
uc_illegal  <=  iu3_0_instr_rot(32) or
              (iu3_0_instr_rot(0 to 5) = "011000");
ic_bp_iu3_val  <=  iu3_instr_valid_l2;
ic_bp_iu3_tid  <=  iu3_tid_l2;
ic_bp_iu3_ifar  <=  iu3_ifar_l2;
ic_bp_iu3_2ucode  <=  iu3_2ucode_l2 and not uc_illegal and not iu3_erat_err_l2(0);
ic_bp_iu3_2ucode_type  <=  iu3_2ucode_type_l2;
int_ic_bp_iu3_error(0) <=  iu3_erat_err_l2(0);
int_ic_bp_iu3_error(1) <=  iu3_erat_err_l2(1) or (icm_icd_iu3_ecc_err and not iu3_erat_err_l2(0));
int_ic_bp_iu3_error(2) <=  iu3_erat_err_l2(2);
ic_bp_iu3_error  <=  int_ic_bp_iu3_error;
icd_icm_iu3_erat_err  <=  iu3_erat_err_l2(0);
xnop  <=  "011010" & ZEROS(6 to 35);
iu3_0_instr_rot    <=  gate(xnop, iu3_erat_err_l2(0)) or
                     gate(iu3_instr0_buf, iu3_ifar_dec_l2(0)) or
                     gate(iu3_instr1_buf, iu3_ifar_dec_l2(1)) or
                     gate(iu3_instr2_buf, iu3_ifar_dec_l2(2)) or
                     gate(iu3_instr3_buf, iu3_ifar_dec_l2(3)) ;
iu3_1_instr_rot    <=  gate(xnop, iu3_erat_err_l2(0)) or
                     gate(iu3_instr1_buf, iu3_ifar_dec_l2(0)) or
                     gate(iu3_instr2_buf, iu3_ifar_dec_l2(1)) or
                     gate(iu3_instr3_buf, iu3_ifar_dec_l2(2)) ;
iu3_2_instr_rot    <=  gate(xnop, iu3_erat_err_l2(0)) or
                     gate(iu3_instr2_buf, iu3_ifar_dec_l2(0)) or
                     gate(iu3_instr3_buf, iu3_ifar_dec_l2(1)) ;
iu3_3_instr_rot    <=  xnop       when iu3_erat_err_l2(0) = '1'
                else iu3_instr3_buf;
ic_bp_iu3_0_instr  <=  iu3_0_instr_rot;
ic_bp_iu3_1_instr  <=  iu3_1_instr_rot;
ic_bp_iu3_2_instr  <=  iu3_2_instr_rot;
ic_bp_iu3_3_instr  <=  iu3_3_instr_rot;
int_ic_bp_iu3_flush  <=  icm_icd_iu3_ecc_fp_cancel or (iu3_parity_flush and not iu3_erat_err_l2(0)) or
                       iu3_rd_miss or  or_reduce(iu3_tid_l2 and ics_icd_all_flush_prev);
ic_bp_iu3_flush  <=  int_ic_bp_iu3_flush;
icd_ics_iu3_ifar  <=  iu3_ifar_l2;
icd_ics_iu3_2ucode  <=  iu3_2ucode_l2;
icd_ics_iu3_2ucode_type  <=  iu3_2ucode_type_l2;
-----------------------------------------------------------------------
-- Performance Events
-----------------------------------------------------------------------
-- IERAT Miss
--      - IU2 ierat miss
perf_event_t0_d(4) <=  iu2_valid and iu2_tid_l2(0)   and ierat_iu_iu2_miss;
perf_event_t1_d(4) <=  iu2_valid and iu2_tid_l2(1)   and ierat_iu_iu2_miss;
perf_event_t2_d(4) <=  iu2_valid and iu2_tid_l2(2)   and ierat_iu_iu2_miss;
perf_event_t3_d(4) <=  iu2_valid and iu2_tid_l2(3)   and ierat_iu_iu2_miss;
-- I-Cache Fetch
--      - Number of times ICache is read for instruction
perf_event_t0_d(5) <=  iu2_valid and iu2_tid_l2(0);
perf_event_t1_d(5) <=  iu2_valid and iu2_tid_l2(1);
perf_event_t2_d(5) <=  iu2_valid and iu2_tid_l2(2);
perf_event_t3_d(5) <=  iu2_valid and iu2_tid_l2(3);
-- Instructions Fetched
--      - Number of instructions fetched, divided by 4.
 WITH s2'(iu2_ifar_eff_l2(60 to 61))  SELECT iu2_instr_count  <=  "100" when "00",
                   "011" when "01",
                   "010" when "10",
                   "001" when others;
perf_instr_count_t0_new(0 TO 2) <=  std_ulogic_vector(
           unsigned('0' & perf_instr_count_t0_l2)   + unsigned(iu2_instr_count) );
perf_instr_count_t0_d(0 TO 1) <=  perf_instr_count_t0_new(1   to 2) when (iu2_valid and iu2_tid_l2(0))   = '1'
                              else perf_instr_count_t0_l2;
perf_event_t0_d(6) <=  iu2_valid and iu2_tid_l2(0)   and perf_instr_count_t0_new(0);
perf_instr_count_t1_new(0 TO 2) <=  std_ulogic_vector(
           unsigned('0' & perf_instr_count_t1_l2)   + unsigned(iu2_instr_count) );
perf_instr_count_t1_d(0 TO 1) <=  perf_instr_count_t1_new(1   to 2) when (iu2_valid and iu2_tid_l2(1))   = '1'
                              else perf_instr_count_t1_l2;
perf_event_t1_d(6) <=  iu2_valid and iu2_tid_l2(1)   and perf_instr_count_t1_new(0);
perf_instr_count_t2_new(0 TO 2) <=  std_ulogic_vector(
           unsigned('0' & perf_instr_count_t2_l2)   + unsigned(iu2_instr_count) );
perf_instr_count_t2_d(0 TO 1) <=  perf_instr_count_t2_new(1   to 2) when (iu2_valid and iu2_tid_l2(2))   = '1'
                              else perf_instr_count_t2_l2;
perf_event_t2_d(6) <=  iu2_valid and iu2_tid_l2(2)   and perf_instr_count_t2_new(0);
perf_instr_count_t3_new(0 TO 2) <=  std_ulogic_vector(
           unsigned('0' & perf_instr_count_t3_l2)   + unsigned(iu2_instr_count) );
perf_instr_count_t3_d(0 TO 1) <=  perf_instr_count_t3_new(1   to 2) when (iu2_valid and iu2_tid_l2(3))   = '1'
                              else perf_instr_count_t3_l2;
perf_event_t3_d(6) <=  iu2_valid and iu2_tid_l2(3)   and perf_instr_count_t3_new(0);
-- Events not per thread
-- L2 Back Invalidates I-Cache
perf_event_d(0) <=  iu2_inval_l2;
-- L2 Back Invalidates I-Cache - Hits
perf_event_d(1) <=  iu2_inval_l2 and or_reduce(iu2_rd_way_tag_hit and iu2_dir_rd_val_l2);
ic_perf_event_t0    <=  perf_event_t0_l2;
ic_perf_event_t1    <=  perf_event_t1_l2;
ic_perf_event_t2    <=  perf_event_t2_l2;
ic_perf_event_t3    <=  perf_event_t3_l2;
ic_perf_event  <=  perf_event_l2;
-----------------------------------------------------------------------
-- Debug Bus
-----------------------------------------------------------------------
dbg_dir_write_d  <=  dir_write;
dbg_dir_rd_act_d  <=  dir_rd_act;
dbg_iu2_lru_rd_update_d  <=  iu2_lru_rd_update;
dbg_iu2_rd_way_tag_hit_d  <=  iu2_rd_way_tag_hit;
dbg_iu2_rd_way_hit_d  <=  iu2_rd_way_hit;
dbg_load_iu2_d  <=  load_iu2;
dir_dbg_data0(0 TO 10) <=  data_datain(21 to 31);
dir_dbg_data0(11 TO 21) <=  iu2_data_dataout_l2(21 to 31);
dir_dbg_data0(22) <=  dbg_dir_write_l2;
dir_dbg_data0(23) <=  data_write;
dir_dbg_data0(24 TO 31) <=  icm_icd_reload_addr(52 to 59);
dir_dbg_data0(32 TO 35) <=  icm_icd_reload_way(0 to 3);
dir_dbg_data0(36) <=  dbg_dir_rd_act_l2;
dir_dbg_data0(37) <=  icm_icd_dir_write_endian;
dir_dbg_data0(38 TO 43) <=  iu2_ifar_eff_l2(52 to 57);
dir_dbg_data0(44 TO 47) <=  iu2_dir_rd_val_l2;
dir_dbg_data0(48 TO 51) <=  dbg_iu2_rd_way_tag_hit_l2;
dir_dbg_data0(52 TO 55) <=  iu3_dir_parity_err_way_l2;
dir_dbg_data0(56 TO 59) <=  iu3_multihit_err_way_l2;
dir_dbg_data0(60 TO 63) <=  iu3_data_parity_err_way_l2;
dir_dbg_data0(64) <=  xu_iu_ici_l2;
dir_dbg_data0(65) <=  iu2_inval_l2;
dir_dbg_data0(66) <=  icm_icd_dir_val;
dir_dbg_data0(67) <=  icm_icd_dir_inval;
dir_dbg_data0(68) <=  icm_icd_ecc_inval;
dir_dbg_data0(69) <=  icm_icd_lru_write;
dir_dbg_data0(70) <=  dbg_iu2_lru_rd_update_l2;
dir_dbg_data0(71 TO 73) <=  iu2_spr_idir_lru_l2;
dir_dbg_data0(74 TO 79) <=  icm_icd_lru_write_addr(52 to 57);
dir_dbg_data0(80 TO 83) <=  icm_icd_lru_write_way;
dir_dbg_data0(84) <=  perf_event_t0_d(5);
dir_dbg_data0(85) <=  perf_event_t1_d(5);
dir_dbg_data0(86) <=  perf_event_t2_d(5);
dir_dbg_data0(87) <=  perf_event_t3_d(5);
dbg1: if (EFF_IFAR'left > 0 )generate
begin dir_dbg_data1(0 TO EFF_IFAR'left-1) <=  (others => '0');
end generate;
dir_dbg_data1(EFF_IFAR'left TO 61) <=  iu3_ifar_l2;
dir_dbg_data1(62 TO 67) <=  iu3_0_instr_rot(0 to 5);
dir_dbg_data1(68 TO 71) <=  iu3_instr_valid_l2;
dir_dbg_data1(72 TO 75) <=  iu3_tid_l2;
dir_dbg_data1(76) <=  int_ic_bp_iu3_flush;
dir_dbg_data1(77 TO 79) <=  int_ic_bp_iu3_error;
dir_dbg_data1(80 TO 83) <=  ics_icd_all_flush_prev;
dir_dbg_data1(84) <=  dbg_load_iu2_l2;
dir_dbg_data1(85) <=  uc_illegal;
dir_dbg_data1(86) <=  iu3_2ucode_l2;
dir_dbg_data1(87) <=  iu3_2ucode_type_l2;
dir_dbg_data2(0) <=  iu2_valid;
dir_dbg_data2(1 TO 3) <=  iu3_erat_err_l2;
dir_dbg_data2(4 TO 7) <=  iu2_tid_l2;
dir_dbg_data2(8 TO 11) <=  dbg_iu2_rd_way_hit_l2;
dir_dbg_data2(12) <=  iu2_ci;
dir_dbg_data2(13) <=  iu2_endian;
dir_dbg_data2(14 TO 43) <=  ierat_iu_iu2_rpn_noncmp;
dir_dbg_trigger0(0) <=  iu1_valid_l2;
dir_dbg_trigger0(1) <=  iu1_inval_l2;
dir_dbg_trigger0(2 TO 5) <=  iu1_tid_l2;
dir_dbg_trigger0(6) <=  iu3_rd_miss_l2;
dir_dbg_trigger0(7) <=  iu3_instr_valid_l2(0);
dir_dbg_trigger1(0 TO 9) <=  iu2_ifar_eff_l2(52 to 61);
dir_dbg_trigger1(10) <=  iu2_valid_l2;
dir_dbg_trigger1(11) <=  iu2_inval_l2;
-----------------------------------------------------------------------
-- Latches
-----------------------------------------------------------------------
-- IU1
iu1_valid_latch: tri_rlmlatch_p
  generic map (init => 0, needs_sreset => 1, expand_type => expand_type)
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
            scin    => siv(iu1_valid_offset),
            scout   => sov(iu1_valid_offset),
            din     => iu1_valid_d,
            dout    => iu1_valid_l2);
iu1_tid_latch: tri_rlmreg_p
  generic map (width => iu1_tid_l2'length, init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => dir_rd_act,
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(iu1_tid_offset to iu1_tid_offset + iu1_tid_l2'length-1),
            scout   => sov(iu1_tid_offset to iu1_tid_offset + iu1_tid_l2'length-1),
            din     => iu1_tid_d,
            dout    => iu1_tid_l2);
-- Note: Technically, only need REAL_IFAR range during sleep mode
iu1_ifar_latch: tri_rlmreg_p
  generic map (width => iu1_ifar_l2'length, init => 0, needs_sreset => 0, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => dir_rd_act,
            thold_b => pc_iu_func_slp_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => funcslp_force,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(iu1_ifar_offset to iu1_ifar_offset + iu1_ifar_l2'length-1),
            scout   => sov(iu1_ifar_offset to iu1_ifar_offset + iu1_ifar_l2'length-1),
            din     => iu1_ifar_d,
            dout    => iu1_ifar_l2);
iu1_inval_latch: tri_rlmlatch_p
  generic map (init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => tiup,
            thold_b => pc_iu_func_slp_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => funcslp_force,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(iu1_inval_offset),
            scout   => sov(iu1_inval_offset),
            din     => iu1_inval_d,
            dout    => iu1_inval_l2);
iu1_2ucode_latch: tri_rlmlatch_p
  generic map (init => 0, needs_sreset => 0, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => dir_rd_act,
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(iu1_2ucode_offset),
            scout   => sov(iu1_2ucode_offset),
            din     => iu1_2ucode_d,
            dout    => iu1_2ucode_l2);
iu1_2ucode_type_latch: tri_rlmlatch_p
  generic map (init => 0, needs_sreset => 0, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => dir_rd_act,
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(iu1_2ucode_type_offset),
            scout   => sov(iu1_2ucode_type_offset),
            din     => iu1_2ucode_type_d,
            dout    => iu1_2ucode_type_l2);
-- IU2
iu2_valid_latch: tri_rlmlatch_p
  generic map (init => 0, needs_sreset => 1, expand_type => expand_type)
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
            scin    => siv(iu2_valid_offset),
            scout   => sov(iu2_valid_offset),
            din     => iu2_valid_d,
            dout    => iu2_valid_l2);
iu2_tid_latch: tri_rlmreg_p
  generic map (width => iu2_tid_l2'length, init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => iu1_valid_l2,
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(iu2_tid_offset to iu2_tid_offset + iu2_tid_l2'length-1),
            scout   => sov(iu2_tid_offset to iu2_tid_offset + iu2_tid_l2'length-1),
            din     => iu2_tid_d,
            dout    => iu2_tid_l2);
iu2_ifar_eff_latch: tri_rlmreg_p
  generic map (width => 52-EFF_IFAR'left, init => 0, needs_sreset => 0, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => dir_dataout_act,
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(iu2_ifar_eff_offset to iu2_ifar_eff_offset + 52-EFF_IFAR'left-1),
            scout   => sov(iu2_ifar_eff_offset to iu2_ifar_eff_offset + 52-EFF_IFAR'left-1),
            din     => iu2_ifar_eff_d(EFF_IFAR'left to 51),
            dout    => iu2_ifar_eff_l2(EFF_IFAR'left to 51));
-- Only need 52:57 in sleep mode
iu2_ifar_eff_slp_latch: tri_rlmreg_p
  generic map (width => 10, init => 0, needs_sreset => 0, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => dir_dataout_act,
            thold_b => pc_iu_func_slp_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => funcslp_force,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(iu2_ifar_eff_offset+52 to iu2_ifar_eff_offset + iu2_ifar_eff_l2'length-1),
            scout   => sov(iu2_ifar_eff_offset+52 to iu2_ifar_eff_offset + iu2_ifar_eff_l2'length-1),
            din     => iu2_ifar_eff_d(52 to 61),
            dout    => iu2_ifar_eff_l2(52 to 61));
iu2_2ucode_latch: tri_rlmlatch_p
  generic map (init => 0, needs_sreset => 0, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => iu1_valid_l2,
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(iu2_2ucode_offset),
            scout   => sov(iu2_2ucode_offset),
            din     => iu2_2ucode_d,
            dout    => iu2_2ucode_l2);
iu2_2ucode_type_latch: tri_rlmlatch_p
  generic map (init => 0, needs_sreset => 0, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => iu1_valid_l2,
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(iu2_2ucode_type_offset),
            scout   => sov(iu2_2ucode_type_offset),
            din     => iu2_2ucode_type_d,
            dout    => iu2_2ucode_type_l2);
iu2_inval_latch: tri_rlmlatch_p
  generic map (init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => tiup,
            thold_b => pc_iu_func_slp_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => funcslp_force,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(iu2_inval_offset),
            scout   => sov(iu2_inval_offset),
            din     => iu2_inval_d,
            dout    => iu2_inval_l2);
iu2_dir_rd_val_latch: tri_rlmreg_p
  generic map (width => iu2_dir_rd_val_l2'length, init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => dir_dataout_act,
            thold_b => pc_iu_func_slp_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => funcslp_force,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(iu2_dir_rd_val_offset to iu2_dir_rd_val_offset + iu2_dir_rd_val_l2'length-1),
            scout   => sov(iu2_dir_rd_val_offset to iu2_dir_rd_val_offset + iu2_dir_rd_val_l2'length-1),
            din     => iu2_dir_rd_val_d,
            dout    => iu2_dir_rd_val_l2);
iu2_dir_dataout_0_par_latch:   tri_rlmreg_p
  generic map (width => iu2_dir_dataout_0_par_l2'length,   init => 0, needs_sreset => 0, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => dir_dataout_act,
            thold_b => pc_iu_func_slp_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => funcslp_force,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(iu2_dir_dataout_0_par_offset   to iu2_dir_dataout_0_par_offset   + iu2_dir_dataout_0_par_l2'length-1),
            scout   => sov(iu2_dir_dataout_0_par_offset   to iu2_dir_dataout_0_par_offset   + iu2_dir_dataout_0_par_l2'length-1),
            din     => iu2_dir_dataout_0_par_d,
            dout    => iu2_dir_dataout_0_par_l2);
iu2_dir_dataout_1_par_latch:   tri_rlmreg_p
  generic map (width => iu2_dir_dataout_1_par_l2'length,   init => 0, needs_sreset => 0, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => dir_dataout_act,
            thold_b => pc_iu_func_slp_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => funcslp_force,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(iu2_dir_dataout_1_par_offset   to iu2_dir_dataout_1_par_offset   + iu2_dir_dataout_1_par_l2'length-1),
            scout   => sov(iu2_dir_dataout_1_par_offset   to iu2_dir_dataout_1_par_offset   + iu2_dir_dataout_1_par_l2'length-1),
            din     => iu2_dir_dataout_1_par_d,
            dout    => iu2_dir_dataout_1_par_l2);
iu2_dir_dataout_2_par_latch:   tri_rlmreg_p
  generic map (width => iu2_dir_dataout_2_par_l2'length,   init => 0, needs_sreset => 0, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => dir_dataout_act,
            thold_b => pc_iu_func_slp_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => funcslp_force,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(iu2_dir_dataout_2_par_offset   to iu2_dir_dataout_2_par_offset   + iu2_dir_dataout_2_par_l2'length-1),
            scout   => sov(iu2_dir_dataout_2_par_offset   to iu2_dir_dataout_2_par_offset   + iu2_dir_dataout_2_par_l2'length-1),
            din     => iu2_dir_dataout_2_par_d,
            dout    => iu2_dir_dataout_2_par_l2);
iu2_dir_dataout_3_par_latch:   tri_rlmreg_p
  generic map (width => iu2_dir_dataout_3_par_l2'length,   init => 0, needs_sreset => 0, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => dir_dataout_act,
            thold_b => pc_iu_func_slp_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => funcslp_force,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(iu2_dir_dataout_3_par_offset   to iu2_dir_dataout_3_par_offset   + iu2_dir_dataout_3_par_l2'length-1),
            scout   => sov(iu2_dir_dataout_3_par_offset   to iu2_dir_dataout_3_par_offset   + iu2_dir_dataout_3_par_l2'length-1),
            din     => iu2_dir_dataout_3_par_d,
            dout    => iu2_dir_dataout_3_par_l2);
iu2_data_dataout_latch: tri_rlmreg_p
  generic map (width => iu2_data_dataout_l2'length, init => 0, needs_sreset => 0, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => iu1_valid_l2,
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(iu2_data_dataout_offset to iu2_data_dataout_offset + iu2_data_dataout_l2'length-1),
            scout   => sov(iu2_data_dataout_offset to iu2_data_dataout_offset + iu2_data_dataout_l2'length-1),
            din     => iu2_data_dataout_d,
            dout    => iu2_data_dataout_l2);
xu_iu_ici_latch: tri_rlmlatch_p
  generic map (init => 0, needs_sreset => 1, expand_type => expand_type)
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
            scin    => siv(xu_iu_ici_offset),
            scout   => sov(xu_iu_ici_offset),
            din     => xu_iu_ici_d,
            dout    => xu_iu_ici_l2);
-- Dir
-- even & odd rows use separate acts for power savings in 128B cacheline mode
dir_row0_val_latch:   tri_rlmreg_p
  generic map (width => dir_row0_val_l2'length,   init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => dir_row_val_even_act,
            thold_b => pc_iu_func_slp_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => funcslp_force,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(dir_row0_val_offset   to dir_row0_val_offset   + dir_row0_val_l2'length-1),
            scout   => sov(dir_row0_val_offset   to dir_row0_val_offset   + dir_row0_val_l2'length-1),
            din     => dir_row0_val_d,
            dout    => dir_row0_val_l2);
dir_row2_val_latch:   tri_rlmreg_p
  generic map (width => dir_row2_val_l2'length,   init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => dir_row_val_even_act,
            thold_b => pc_iu_func_slp_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => funcslp_force,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(dir_row2_val_offset   to dir_row2_val_offset   + dir_row2_val_l2'length-1),
            scout   => sov(dir_row2_val_offset   to dir_row2_val_offset   + dir_row2_val_l2'length-1),
            din     => dir_row2_val_d,
            dout    => dir_row2_val_l2);
dir_row4_val_latch:   tri_rlmreg_p
  generic map (width => dir_row4_val_l2'length,   init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => dir_row_val_even_act,
            thold_b => pc_iu_func_slp_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => funcslp_force,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(dir_row4_val_offset   to dir_row4_val_offset   + dir_row4_val_l2'length-1),
            scout   => sov(dir_row4_val_offset   to dir_row4_val_offset   + dir_row4_val_l2'length-1),
            din     => dir_row4_val_d,
            dout    => dir_row4_val_l2);
dir_row6_val_latch:   tri_rlmreg_p
  generic map (width => dir_row6_val_l2'length,   init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => dir_row_val_even_act,
            thold_b => pc_iu_func_slp_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => funcslp_force,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(dir_row6_val_offset   to dir_row6_val_offset   + dir_row6_val_l2'length-1),
            scout   => sov(dir_row6_val_offset   to dir_row6_val_offset   + dir_row6_val_l2'length-1),
            din     => dir_row6_val_d,
            dout    => dir_row6_val_l2);
dir_row8_val_latch:   tri_rlmreg_p
  generic map (width => dir_row8_val_l2'length,   init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => dir_row_val_even_act,
            thold_b => pc_iu_func_slp_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => funcslp_force,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(dir_row8_val_offset   to dir_row8_val_offset   + dir_row8_val_l2'length-1),
            scout   => sov(dir_row8_val_offset   to dir_row8_val_offset   + dir_row8_val_l2'length-1),
            din     => dir_row8_val_d,
            dout    => dir_row8_val_l2);
dir_row10_val_latch:  tri_rlmreg_p
  generic map (width => dir_row10_val_l2'length,  init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => dir_row_val_even_act,
            thold_b => pc_iu_func_slp_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => funcslp_force,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(dir_row10_val_offset  to dir_row10_val_offset  + dir_row10_val_l2'length-1),
            scout   => sov(dir_row10_val_offset  to dir_row10_val_offset  + dir_row10_val_l2'length-1),
            din     => dir_row10_val_d,
            dout    => dir_row10_val_l2);
dir_row12_val_latch:  tri_rlmreg_p
  generic map (width => dir_row12_val_l2'length,  init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => dir_row_val_even_act,
            thold_b => pc_iu_func_slp_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => funcslp_force,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(dir_row12_val_offset  to dir_row12_val_offset  + dir_row12_val_l2'length-1),
            scout   => sov(dir_row12_val_offset  to dir_row12_val_offset  + dir_row12_val_l2'length-1),
            din     => dir_row12_val_d,
            dout    => dir_row12_val_l2);
dir_row14_val_latch:  tri_rlmreg_p
  generic map (width => dir_row14_val_l2'length,  init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => dir_row_val_even_act,
            thold_b => pc_iu_func_slp_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => funcslp_force,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(dir_row14_val_offset  to dir_row14_val_offset  + dir_row14_val_l2'length-1),
            scout   => sov(dir_row14_val_offset  to dir_row14_val_offset  + dir_row14_val_l2'length-1),
            din     => dir_row14_val_d,
            dout    => dir_row14_val_l2);
dir_row16_val_latch:  tri_rlmreg_p
  generic map (width => dir_row16_val_l2'length,  init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => dir_row_val_even_act,
            thold_b => pc_iu_func_slp_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => funcslp_force,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(dir_row16_val_offset  to dir_row16_val_offset  + dir_row16_val_l2'length-1),
            scout   => sov(dir_row16_val_offset  to dir_row16_val_offset  + dir_row16_val_l2'length-1),
            din     => dir_row16_val_d,
            dout    => dir_row16_val_l2);
dir_row18_val_latch:  tri_rlmreg_p
  generic map (width => dir_row18_val_l2'length,  init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => dir_row_val_even_act,
            thold_b => pc_iu_func_slp_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => funcslp_force,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(dir_row18_val_offset  to dir_row18_val_offset  + dir_row18_val_l2'length-1),
            scout   => sov(dir_row18_val_offset  to dir_row18_val_offset  + dir_row18_val_l2'length-1),
            din     => dir_row18_val_d,
            dout    => dir_row18_val_l2);
dir_row20_val_latch:  tri_rlmreg_p
  generic map (width => dir_row20_val_l2'length,  init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => dir_row_val_even_act,
            thold_b => pc_iu_func_slp_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => funcslp_force,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(dir_row20_val_offset  to dir_row20_val_offset  + dir_row20_val_l2'length-1),
            scout   => sov(dir_row20_val_offset  to dir_row20_val_offset  + dir_row20_val_l2'length-1),
            din     => dir_row20_val_d,
            dout    => dir_row20_val_l2);
dir_row22_val_latch:  tri_rlmreg_p
  generic map (width => dir_row22_val_l2'length,  init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => dir_row_val_even_act,
            thold_b => pc_iu_func_slp_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => funcslp_force,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(dir_row22_val_offset  to dir_row22_val_offset  + dir_row22_val_l2'length-1),
            scout   => sov(dir_row22_val_offset  to dir_row22_val_offset  + dir_row22_val_l2'length-1),
            din     => dir_row22_val_d,
            dout    => dir_row22_val_l2);
dir_row24_val_latch:  tri_rlmreg_p
  generic map (width => dir_row24_val_l2'length,  init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => dir_row_val_even_act,
            thold_b => pc_iu_func_slp_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => funcslp_force,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(dir_row24_val_offset  to dir_row24_val_offset  + dir_row24_val_l2'length-1),
            scout   => sov(dir_row24_val_offset  to dir_row24_val_offset  + dir_row24_val_l2'length-1),
            din     => dir_row24_val_d,
            dout    => dir_row24_val_l2);
dir_row26_val_latch:  tri_rlmreg_p
  generic map (width => dir_row26_val_l2'length,  init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => dir_row_val_even_act,
            thold_b => pc_iu_func_slp_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => funcslp_force,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(dir_row26_val_offset  to dir_row26_val_offset  + dir_row26_val_l2'length-1),
            scout   => sov(dir_row26_val_offset  to dir_row26_val_offset  + dir_row26_val_l2'length-1),
            din     => dir_row26_val_d,
            dout    => dir_row26_val_l2);
dir_row28_val_latch:  tri_rlmreg_p
  generic map (width => dir_row28_val_l2'length,  init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => dir_row_val_even_act,
            thold_b => pc_iu_func_slp_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => funcslp_force,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(dir_row28_val_offset  to dir_row28_val_offset  + dir_row28_val_l2'length-1),
            scout   => sov(dir_row28_val_offset  to dir_row28_val_offset  + dir_row28_val_l2'length-1),
            din     => dir_row28_val_d,
            dout    => dir_row28_val_l2);
dir_row30_val_latch:  tri_rlmreg_p
  generic map (width => dir_row30_val_l2'length,  init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => dir_row_val_even_act,
            thold_b => pc_iu_func_slp_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => funcslp_force,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(dir_row30_val_offset  to dir_row30_val_offset  + dir_row30_val_l2'length-1),
            scout   => sov(dir_row30_val_offset  to dir_row30_val_offset  + dir_row30_val_l2'length-1),
            din     => dir_row30_val_d,
            dout    => dir_row30_val_l2);
dir_row32_val_latch:  tri_rlmreg_p
  generic map (width => dir_row32_val_l2'length,  init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => dir_row_val_even_act,
            thold_b => pc_iu_func_slp_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => funcslp_force,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(dir_row32_val_offset  to dir_row32_val_offset  + dir_row32_val_l2'length-1),
            scout   => sov(dir_row32_val_offset  to dir_row32_val_offset  + dir_row32_val_l2'length-1),
            din     => dir_row32_val_d,
            dout    => dir_row32_val_l2);
dir_row34_val_latch:  tri_rlmreg_p
  generic map (width => dir_row34_val_l2'length,  init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => dir_row_val_even_act,
            thold_b => pc_iu_func_slp_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => funcslp_force,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(dir_row34_val_offset  to dir_row34_val_offset  + dir_row34_val_l2'length-1),
            scout   => sov(dir_row34_val_offset  to dir_row34_val_offset  + dir_row34_val_l2'length-1),
            din     => dir_row34_val_d,
            dout    => dir_row34_val_l2);
dir_row36_val_latch:  tri_rlmreg_p
  generic map (width => dir_row36_val_l2'length,  init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => dir_row_val_even_act,
            thold_b => pc_iu_func_slp_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => funcslp_force,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(dir_row36_val_offset  to dir_row36_val_offset  + dir_row36_val_l2'length-1),
            scout   => sov(dir_row36_val_offset  to dir_row36_val_offset  + dir_row36_val_l2'length-1),
            din     => dir_row36_val_d,
            dout    => dir_row36_val_l2);
dir_row38_val_latch:  tri_rlmreg_p
  generic map (width => dir_row38_val_l2'length,  init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => dir_row_val_even_act,
            thold_b => pc_iu_func_slp_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => funcslp_force,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(dir_row38_val_offset  to dir_row38_val_offset  + dir_row38_val_l2'length-1),
            scout   => sov(dir_row38_val_offset  to dir_row38_val_offset  + dir_row38_val_l2'length-1),
            din     => dir_row38_val_d,
            dout    => dir_row38_val_l2);
dir_row40_val_latch:  tri_rlmreg_p
  generic map (width => dir_row40_val_l2'length,  init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => dir_row_val_even_act,
            thold_b => pc_iu_func_slp_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => funcslp_force,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(dir_row40_val_offset  to dir_row40_val_offset  + dir_row40_val_l2'length-1),
            scout   => sov(dir_row40_val_offset  to dir_row40_val_offset  + dir_row40_val_l2'length-1),
            din     => dir_row40_val_d,
            dout    => dir_row40_val_l2);
dir_row42_val_latch:  tri_rlmreg_p
  generic map (width => dir_row42_val_l2'length,  init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => dir_row_val_even_act,
            thold_b => pc_iu_func_slp_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => funcslp_force,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(dir_row42_val_offset  to dir_row42_val_offset  + dir_row42_val_l2'length-1),
            scout   => sov(dir_row42_val_offset  to dir_row42_val_offset  + dir_row42_val_l2'length-1),
            din     => dir_row42_val_d,
            dout    => dir_row42_val_l2);
dir_row44_val_latch:  tri_rlmreg_p
  generic map (width => dir_row44_val_l2'length,  init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => dir_row_val_even_act,
            thold_b => pc_iu_func_slp_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => funcslp_force,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(dir_row44_val_offset  to dir_row44_val_offset  + dir_row44_val_l2'length-1),
            scout   => sov(dir_row44_val_offset  to dir_row44_val_offset  + dir_row44_val_l2'length-1),
            din     => dir_row44_val_d,
            dout    => dir_row44_val_l2);
dir_row46_val_latch:  tri_rlmreg_p
  generic map (width => dir_row46_val_l2'length,  init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => dir_row_val_even_act,
            thold_b => pc_iu_func_slp_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => funcslp_force,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(dir_row46_val_offset  to dir_row46_val_offset  + dir_row46_val_l2'length-1),
            scout   => sov(dir_row46_val_offset  to dir_row46_val_offset  + dir_row46_val_l2'length-1),
            din     => dir_row46_val_d,
            dout    => dir_row46_val_l2);
dir_row48_val_latch:  tri_rlmreg_p
  generic map (width => dir_row48_val_l2'length,  init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => dir_row_val_even_act,
            thold_b => pc_iu_func_slp_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => funcslp_force,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(dir_row48_val_offset  to dir_row48_val_offset  + dir_row48_val_l2'length-1),
            scout   => sov(dir_row48_val_offset  to dir_row48_val_offset  + dir_row48_val_l2'length-1),
            din     => dir_row48_val_d,
            dout    => dir_row48_val_l2);
dir_row50_val_latch:  tri_rlmreg_p
  generic map (width => dir_row50_val_l2'length,  init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => dir_row_val_even_act,
            thold_b => pc_iu_func_slp_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => funcslp_force,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(dir_row50_val_offset  to dir_row50_val_offset  + dir_row50_val_l2'length-1),
            scout   => sov(dir_row50_val_offset  to dir_row50_val_offset  + dir_row50_val_l2'length-1),
            din     => dir_row50_val_d,
            dout    => dir_row50_val_l2);
dir_row52_val_latch:  tri_rlmreg_p
  generic map (width => dir_row52_val_l2'length,  init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => dir_row_val_even_act,
            thold_b => pc_iu_func_slp_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => funcslp_force,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(dir_row52_val_offset  to dir_row52_val_offset  + dir_row52_val_l2'length-1),
            scout   => sov(dir_row52_val_offset  to dir_row52_val_offset  + dir_row52_val_l2'length-1),
            din     => dir_row52_val_d,
            dout    => dir_row52_val_l2);
dir_row54_val_latch:  tri_rlmreg_p
  generic map (width => dir_row54_val_l2'length,  init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => dir_row_val_even_act,
            thold_b => pc_iu_func_slp_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => funcslp_force,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(dir_row54_val_offset  to dir_row54_val_offset  + dir_row54_val_l2'length-1),
            scout   => sov(dir_row54_val_offset  to dir_row54_val_offset  + dir_row54_val_l2'length-1),
            din     => dir_row54_val_d,
            dout    => dir_row54_val_l2);
dir_row56_val_latch:  tri_rlmreg_p
  generic map (width => dir_row56_val_l2'length,  init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => dir_row_val_even_act,
            thold_b => pc_iu_func_slp_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => funcslp_force,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(dir_row56_val_offset  to dir_row56_val_offset  + dir_row56_val_l2'length-1),
            scout   => sov(dir_row56_val_offset  to dir_row56_val_offset  + dir_row56_val_l2'length-1),
            din     => dir_row56_val_d,
            dout    => dir_row56_val_l2);
dir_row58_val_latch:  tri_rlmreg_p
  generic map (width => dir_row58_val_l2'length,  init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => dir_row_val_even_act,
            thold_b => pc_iu_func_slp_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => funcslp_force,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(dir_row58_val_offset  to dir_row58_val_offset  + dir_row58_val_l2'length-1),
            scout   => sov(dir_row58_val_offset  to dir_row58_val_offset  + dir_row58_val_l2'length-1),
            din     => dir_row58_val_d,
            dout    => dir_row58_val_l2);
dir_row60_val_latch:  tri_rlmreg_p
  generic map (width => dir_row60_val_l2'length,  init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => dir_row_val_even_act,
            thold_b => pc_iu_func_slp_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => funcslp_force,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(dir_row60_val_offset  to dir_row60_val_offset  + dir_row60_val_l2'length-1),
            scout   => sov(dir_row60_val_offset  to dir_row60_val_offset  + dir_row60_val_l2'length-1),
            din     => dir_row60_val_d,
            dout    => dir_row60_val_l2);
dir_row62_val_latch:  tri_rlmreg_p
  generic map (width => dir_row62_val_l2'length,  init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => dir_row_val_even_act,
            thold_b => pc_iu_func_slp_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => funcslp_force,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(dir_row62_val_offset  to dir_row62_val_offset  + dir_row62_val_l2'length-1),
            scout   => sov(dir_row62_val_offset  to dir_row62_val_offset  + dir_row62_val_l2'length-1),
            din     => dir_row62_val_d,
            dout    => dir_row62_val_l2);
dir_row0_lru_latch:   tri_rlmreg_p
  generic map (width => dir_row0_lru_l2'length,   init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => dir_row_lru_even_act,
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(dir_row0_lru_offset   to dir_row0_lru_offset   + dir_row0_lru_l2'length-1),
            scout   => sov(dir_row0_lru_offset   to dir_row0_lru_offset   + dir_row0_lru_l2'length-1),
            din     => dir_row0_lru_d,
            dout    => dir_row0_lru_l2);
dir_row2_lru_latch:   tri_rlmreg_p
  generic map (width => dir_row2_lru_l2'length,   init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => dir_row_lru_even_act,
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(dir_row2_lru_offset   to dir_row2_lru_offset   + dir_row2_lru_l2'length-1),
            scout   => sov(dir_row2_lru_offset   to dir_row2_lru_offset   + dir_row2_lru_l2'length-1),
            din     => dir_row2_lru_d,
            dout    => dir_row2_lru_l2);
dir_row4_lru_latch:   tri_rlmreg_p
  generic map (width => dir_row4_lru_l2'length,   init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => dir_row_lru_even_act,
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(dir_row4_lru_offset   to dir_row4_lru_offset   + dir_row4_lru_l2'length-1),
            scout   => sov(dir_row4_lru_offset   to dir_row4_lru_offset   + dir_row4_lru_l2'length-1),
            din     => dir_row4_lru_d,
            dout    => dir_row4_lru_l2);
dir_row6_lru_latch:   tri_rlmreg_p
  generic map (width => dir_row6_lru_l2'length,   init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => dir_row_lru_even_act,
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(dir_row6_lru_offset   to dir_row6_lru_offset   + dir_row6_lru_l2'length-1),
            scout   => sov(dir_row6_lru_offset   to dir_row6_lru_offset   + dir_row6_lru_l2'length-1),
            din     => dir_row6_lru_d,
            dout    => dir_row6_lru_l2);
dir_row8_lru_latch:   tri_rlmreg_p
  generic map (width => dir_row8_lru_l2'length,   init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => dir_row_lru_even_act,
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(dir_row8_lru_offset   to dir_row8_lru_offset   + dir_row8_lru_l2'length-1),
            scout   => sov(dir_row8_lru_offset   to dir_row8_lru_offset   + dir_row8_lru_l2'length-1),
            din     => dir_row8_lru_d,
            dout    => dir_row8_lru_l2);
dir_row10_lru_latch:  tri_rlmreg_p
  generic map (width => dir_row10_lru_l2'length,  init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => dir_row_lru_even_act,
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(dir_row10_lru_offset  to dir_row10_lru_offset  + dir_row10_lru_l2'length-1),
            scout   => sov(dir_row10_lru_offset  to dir_row10_lru_offset  + dir_row10_lru_l2'length-1),
            din     => dir_row10_lru_d,
            dout    => dir_row10_lru_l2);
dir_row12_lru_latch:  tri_rlmreg_p
  generic map (width => dir_row12_lru_l2'length,  init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => dir_row_lru_even_act,
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(dir_row12_lru_offset  to dir_row12_lru_offset  + dir_row12_lru_l2'length-1),
            scout   => sov(dir_row12_lru_offset  to dir_row12_lru_offset  + dir_row12_lru_l2'length-1),
            din     => dir_row12_lru_d,
            dout    => dir_row12_lru_l2);
dir_row14_lru_latch:  tri_rlmreg_p
  generic map (width => dir_row14_lru_l2'length,  init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => dir_row_lru_even_act,
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(dir_row14_lru_offset  to dir_row14_lru_offset  + dir_row14_lru_l2'length-1),
            scout   => sov(dir_row14_lru_offset  to dir_row14_lru_offset  + dir_row14_lru_l2'length-1),
            din     => dir_row14_lru_d,
            dout    => dir_row14_lru_l2);
dir_row16_lru_latch:  tri_rlmreg_p
  generic map (width => dir_row16_lru_l2'length,  init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => dir_row_lru_even_act,
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(dir_row16_lru_offset  to dir_row16_lru_offset  + dir_row16_lru_l2'length-1),
            scout   => sov(dir_row16_lru_offset  to dir_row16_lru_offset  + dir_row16_lru_l2'length-1),
            din     => dir_row16_lru_d,
            dout    => dir_row16_lru_l2);
dir_row18_lru_latch:  tri_rlmreg_p
  generic map (width => dir_row18_lru_l2'length,  init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => dir_row_lru_even_act,
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(dir_row18_lru_offset  to dir_row18_lru_offset  + dir_row18_lru_l2'length-1),
            scout   => sov(dir_row18_lru_offset  to dir_row18_lru_offset  + dir_row18_lru_l2'length-1),
            din     => dir_row18_lru_d,
            dout    => dir_row18_lru_l2);
dir_row20_lru_latch:  tri_rlmreg_p
  generic map (width => dir_row20_lru_l2'length,  init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => dir_row_lru_even_act,
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(dir_row20_lru_offset  to dir_row20_lru_offset  + dir_row20_lru_l2'length-1),
            scout   => sov(dir_row20_lru_offset  to dir_row20_lru_offset  + dir_row20_lru_l2'length-1),
            din     => dir_row20_lru_d,
            dout    => dir_row20_lru_l2);
dir_row22_lru_latch:  tri_rlmreg_p
  generic map (width => dir_row22_lru_l2'length,  init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => dir_row_lru_even_act,
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(dir_row22_lru_offset  to dir_row22_lru_offset  + dir_row22_lru_l2'length-1),
            scout   => sov(dir_row22_lru_offset  to dir_row22_lru_offset  + dir_row22_lru_l2'length-1),
            din     => dir_row22_lru_d,
            dout    => dir_row22_lru_l2);
dir_row24_lru_latch:  tri_rlmreg_p
  generic map (width => dir_row24_lru_l2'length,  init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => dir_row_lru_even_act,
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(dir_row24_lru_offset  to dir_row24_lru_offset  + dir_row24_lru_l2'length-1),
            scout   => sov(dir_row24_lru_offset  to dir_row24_lru_offset  + dir_row24_lru_l2'length-1),
            din     => dir_row24_lru_d,
            dout    => dir_row24_lru_l2);
dir_row26_lru_latch:  tri_rlmreg_p
  generic map (width => dir_row26_lru_l2'length,  init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => dir_row_lru_even_act,
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(dir_row26_lru_offset  to dir_row26_lru_offset  + dir_row26_lru_l2'length-1),
            scout   => sov(dir_row26_lru_offset  to dir_row26_lru_offset  + dir_row26_lru_l2'length-1),
            din     => dir_row26_lru_d,
            dout    => dir_row26_lru_l2);
dir_row28_lru_latch:  tri_rlmreg_p
  generic map (width => dir_row28_lru_l2'length,  init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => dir_row_lru_even_act,
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(dir_row28_lru_offset  to dir_row28_lru_offset  + dir_row28_lru_l2'length-1),
            scout   => sov(dir_row28_lru_offset  to dir_row28_lru_offset  + dir_row28_lru_l2'length-1),
            din     => dir_row28_lru_d,
            dout    => dir_row28_lru_l2);
dir_row30_lru_latch:  tri_rlmreg_p
  generic map (width => dir_row30_lru_l2'length,  init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => dir_row_lru_even_act,
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(dir_row30_lru_offset  to dir_row30_lru_offset  + dir_row30_lru_l2'length-1),
            scout   => sov(dir_row30_lru_offset  to dir_row30_lru_offset  + dir_row30_lru_l2'length-1),
            din     => dir_row30_lru_d,
            dout    => dir_row30_lru_l2);
dir_row32_lru_latch:  tri_rlmreg_p
  generic map (width => dir_row32_lru_l2'length,  init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => dir_row_lru_even_act,
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(dir_row32_lru_offset  to dir_row32_lru_offset  + dir_row32_lru_l2'length-1),
            scout   => sov(dir_row32_lru_offset  to dir_row32_lru_offset  + dir_row32_lru_l2'length-1),
            din     => dir_row32_lru_d,
            dout    => dir_row32_lru_l2);
dir_row34_lru_latch:  tri_rlmreg_p
  generic map (width => dir_row34_lru_l2'length,  init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => dir_row_lru_even_act,
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(dir_row34_lru_offset  to dir_row34_lru_offset  + dir_row34_lru_l2'length-1),
            scout   => sov(dir_row34_lru_offset  to dir_row34_lru_offset  + dir_row34_lru_l2'length-1),
            din     => dir_row34_lru_d,
            dout    => dir_row34_lru_l2);
dir_row36_lru_latch:  tri_rlmreg_p
  generic map (width => dir_row36_lru_l2'length,  init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => dir_row_lru_even_act,
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(dir_row36_lru_offset  to dir_row36_lru_offset  + dir_row36_lru_l2'length-1),
            scout   => sov(dir_row36_lru_offset  to dir_row36_lru_offset  + dir_row36_lru_l2'length-1),
            din     => dir_row36_lru_d,
            dout    => dir_row36_lru_l2);
dir_row38_lru_latch:  tri_rlmreg_p
  generic map (width => dir_row38_lru_l2'length,  init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => dir_row_lru_even_act,
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(dir_row38_lru_offset  to dir_row38_lru_offset  + dir_row38_lru_l2'length-1),
            scout   => sov(dir_row38_lru_offset  to dir_row38_lru_offset  + dir_row38_lru_l2'length-1),
            din     => dir_row38_lru_d,
            dout    => dir_row38_lru_l2);
dir_row40_lru_latch:  tri_rlmreg_p
  generic map (width => dir_row40_lru_l2'length,  init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => dir_row_lru_even_act,
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(dir_row40_lru_offset  to dir_row40_lru_offset  + dir_row40_lru_l2'length-1),
            scout   => sov(dir_row40_lru_offset  to dir_row40_lru_offset  + dir_row40_lru_l2'length-1),
            din     => dir_row40_lru_d,
            dout    => dir_row40_lru_l2);
dir_row42_lru_latch:  tri_rlmreg_p
  generic map (width => dir_row42_lru_l2'length,  init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => dir_row_lru_even_act,
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(dir_row42_lru_offset  to dir_row42_lru_offset  + dir_row42_lru_l2'length-1),
            scout   => sov(dir_row42_lru_offset  to dir_row42_lru_offset  + dir_row42_lru_l2'length-1),
            din     => dir_row42_lru_d,
            dout    => dir_row42_lru_l2);
dir_row44_lru_latch:  tri_rlmreg_p
  generic map (width => dir_row44_lru_l2'length,  init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => dir_row_lru_even_act,
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(dir_row44_lru_offset  to dir_row44_lru_offset  + dir_row44_lru_l2'length-1),
            scout   => sov(dir_row44_lru_offset  to dir_row44_lru_offset  + dir_row44_lru_l2'length-1),
            din     => dir_row44_lru_d,
            dout    => dir_row44_lru_l2);
dir_row46_lru_latch:  tri_rlmreg_p
  generic map (width => dir_row46_lru_l2'length,  init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => dir_row_lru_even_act,
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(dir_row46_lru_offset  to dir_row46_lru_offset  + dir_row46_lru_l2'length-1),
            scout   => sov(dir_row46_lru_offset  to dir_row46_lru_offset  + dir_row46_lru_l2'length-1),
            din     => dir_row46_lru_d,
            dout    => dir_row46_lru_l2);
dir_row48_lru_latch:  tri_rlmreg_p
  generic map (width => dir_row48_lru_l2'length,  init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => dir_row_lru_even_act,
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(dir_row48_lru_offset  to dir_row48_lru_offset  + dir_row48_lru_l2'length-1),
            scout   => sov(dir_row48_lru_offset  to dir_row48_lru_offset  + dir_row48_lru_l2'length-1),
            din     => dir_row48_lru_d,
            dout    => dir_row48_lru_l2);
dir_row50_lru_latch:  tri_rlmreg_p
  generic map (width => dir_row50_lru_l2'length,  init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => dir_row_lru_even_act,
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(dir_row50_lru_offset  to dir_row50_lru_offset  + dir_row50_lru_l2'length-1),
            scout   => sov(dir_row50_lru_offset  to dir_row50_lru_offset  + dir_row50_lru_l2'length-1),
            din     => dir_row50_lru_d,
            dout    => dir_row50_lru_l2);
dir_row52_lru_latch:  tri_rlmreg_p
  generic map (width => dir_row52_lru_l2'length,  init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => dir_row_lru_even_act,
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(dir_row52_lru_offset  to dir_row52_lru_offset  + dir_row52_lru_l2'length-1),
            scout   => sov(dir_row52_lru_offset  to dir_row52_lru_offset  + dir_row52_lru_l2'length-1),
            din     => dir_row52_lru_d,
            dout    => dir_row52_lru_l2);
dir_row54_lru_latch:  tri_rlmreg_p
  generic map (width => dir_row54_lru_l2'length,  init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => dir_row_lru_even_act,
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(dir_row54_lru_offset  to dir_row54_lru_offset  + dir_row54_lru_l2'length-1),
            scout   => sov(dir_row54_lru_offset  to dir_row54_lru_offset  + dir_row54_lru_l2'length-1),
            din     => dir_row54_lru_d,
            dout    => dir_row54_lru_l2);
dir_row56_lru_latch:  tri_rlmreg_p
  generic map (width => dir_row56_lru_l2'length,  init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => dir_row_lru_even_act,
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(dir_row56_lru_offset  to dir_row56_lru_offset  + dir_row56_lru_l2'length-1),
            scout   => sov(dir_row56_lru_offset  to dir_row56_lru_offset  + dir_row56_lru_l2'length-1),
            din     => dir_row56_lru_d,
            dout    => dir_row56_lru_l2);
dir_row58_lru_latch:  tri_rlmreg_p
  generic map (width => dir_row58_lru_l2'length,  init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => dir_row_lru_even_act,
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(dir_row58_lru_offset  to dir_row58_lru_offset  + dir_row58_lru_l2'length-1),
            scout   => sov(dir_row58_lru_offset  to dir_row58_lru_offset  + dir_row58_lru_l2'length-1),
            din     => dir_row58_lru_d,
            dout    => dir_row58_lru_l2);
dir_row60_lru_latch:  tri_rlmreg_p
  generic map (width => dir_row60_lru_l2'length,  init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => dir_row_lru_even_act,
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(dir_row60_lru_offset  to dir_row60_lru_offset  + dir_row60_lru_l2'length-1),
            scout   => sov(dir_row60_lru_offset  to dir_row60_lru_offset  + dir_row60_lru_l2'length-1),
            din     => dir_row60_lru_d,
            dout    => dir_row60_lru_l2);
dir_row62_lru_latch:  tri_rlmreg_p
  generic map (width => dir_row62_lru_l2'length,  init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => dir_row_lru_even_act,
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(dir_row62_lru_offset  to dir_row62_lru_offset  + dir_row62_lru_l2'length-1),
            scout   => sov(dir_row62_lru_offset  to dir_row62_lru_offset  + dir_row62_lru_l2'length-1),
            din     => dir_row62_lru_d,
            dout    => dir_row62_lru_l2);
dir_row1_val_latch:   tri_rlmreg_p
  generic map (width => dir_row1_val_l2'length,   init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => dir_row_val_odd_act,
            thold_b => pc_iu_func_slp_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => funcslp_force,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(dir_row1_val_offset   to dir_row1_val_offset   + dir_row1_val_l2'length-1),
            scout   => sov(dir_row1_val_offset   to dir_row1_val_offset   + dir_row1_val_l2'length-1),
            din     => dir_row1_val_d,
            dout    => dir_row1_val_l2);
dir_row3_val_latch:   tri_rlmreg_p
  generic map (width => dir_row3_val_l2'length,   init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => dir_row_val_odd_act,
            thold_b => pc_iu_func_slp_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => funcslp_force,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(dir_row3_val_offset   to dir_row3_val_offset   + dir_row3_val_l2'length-1),
            scout   => sov(dir_row3_val_offset   to dir_row3_val_offset   + dir_row3_val_l2'length-1),
            din     => dir_row3_val_d,
            dout    => dir_row3_val_l2);
dir_row5_val_latch:   tri_rlmreg_p
  generic map (width => dir_row5_val_l2'length,   init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => dir_row_val_odd_act,
            thold_b => pc_iu_func_slp_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => funcslp_force,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(dir_row5_val_offset   to dir_row5_val_offset   + dir_row5_val_l2'length-1),
            scout   => sov(dir_row5_val_offset   to dir_row5_val_offset   + dir_row5_val_l2'length-1),
            din     => dir_row5_val_d,
            dout    => dir_row5_val_l2);
dir_row7_val_latch:   tri_rlmreg_p
  generic map (width => dir_row7_val_l2'length,   init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => dir_row_val_odd_act,
            thold_b => pc_iu_func_slp_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => funcslp_force,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(dir_row7_val_offset   to dir_row7_val_offset   + dir_row7_val_l2'length-1),
            scout   => sov(dir_row7_val_offset   to dir_row7_val_offset   + dir_row7_val_l2'length-1),
            din     => dir_row7_val_d,
            dout    => dir_row7_val_l2);
dir_row9_val_latch:   tri_rlmreg_p
  generic map (width => dir_row9_val_l2'length,   init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => dir_row_val_odd_act,
            thold_b => pc_iu_func_slp_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => funcslp_force,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(dir_row9_val_offset   to dir_row9_val_offset   + dir_row9_val_l2'length-1),
            scout   => sov(dir_row9_val_offset   to dir_row9_val_offset   + dir_row9_val_l2'length-1),
            din     => dir_row9_val_d,
            dout    => dir_row9_val_l2);
dir_row11_val_latch:  tri_rlmreg_p
  generic map (width => dir_row11_val_l2'length,  init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => dir_row_val_odd_act,
            thold_b => pc_iu_func_slp_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => funcslp_force,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(dir_row11_val_offset  to dir_row11_val_offset  + dir_row11_val_l2'length-1),
            scout   => sov(dir_row11_val_offset  to dir_row11_val_offset  + dir_row11_val_l2'length-1),
            din     => dir_row11_val_d,
            dout    => dir_row11_val_l2);
dir_row13_val_latch:  tri_rlmreg_p
  generic map (width => dir_row13_val_l2'length,  init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => dir_row_val_odd_act,
            thold_b => pc_iu_func_slp_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => funcslp_force,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(dir_row13_val_offset  to dir_row13_val_offset  + dir_row13_val_l2'length-1),
            scout   => sov(dir_row13_val_offset  to dir_row13_val_offset  + dir_row13_val_l2'length-1),
            din     => dir_row13_val_d,
            dout    => dir_row13_val_l2);
dir_row15_val_latch:  tri_rlmreg_p
  generic map (width => dir_row15_val_l2'length,  init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => dir_row_val_odd_act,
            thold_b => pc_iu_func_slp_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => funcslp_force,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(dir_row15_val_offset  to dir_row15_val_offset  + dir_row15_val_l2'length-1),
            scout   => sov(dir_row15_val_offset  to dir_row15_val_offset  + dir_row15_val_l2'length-1),
            din     => dir_row15_val_d,
            dout    => dir_row15_val_l2);
dir_row17_val_latch:  tri_rlmreg_p
  generic map (width => dir_row17_val_l2'length,  init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => dir_row_val_odd_act,
            thold_b => pc_iu_func_slp_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => funcslp_force,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(dir_row17_val_offset  to dir_row17_val_offset  + dir_row17_val_l2'length-1),
            scout   => sov(dir_row17_val_offset  to dir_row17_val_offset  + dir_row17_val_l2'length-1),
            din     => dir_row17_val_d,
            dout    => dir_row17_val_l2);
dir_row19_val_latch:  tri_rlmreg_p
  generic map (width => dir_row19_val_l2'length,  init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => dir_row_val_odd_act,
            thold_b => pc_iu_func_slp_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => funcslp_force,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(dir_row19_val_offset  to dir_row19_val_offset  + dir_row19_val_l2'length-1),
            scout   => sov(dir_row19_val_offset  to dir_row19_val_offset  + dir_row19_val_l2'length-1),
            din     => dir_row19_val_d,
            dout    => dir_row19_val_l2);
dir_row21_val_latch:  tri_rlmreg_p
  generic map (width => dir_row21_val_l2'length,  init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => dir_row_val_odd_act,
            thold_b => pc_iu_func_slp_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => funcslp_force,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(dir_row21_val_offset  to dir_row21_val_offset  + dir_row21_val_l2'length-1),
            scout   => sov(dir_row21_val_offset  to dir_row21_val_offset  + dir_row21_val_l2'length-1),
            din     => dir_row21_val_d,
            dout    => dir_row21_val_l2);
dir_row23_val_latch:  tri_rlmreg_p
  generic map (width => dir_row23_val_l2'length,  init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => dir_row_val_odd_act,
            thold_b => pc_iu_func_slp_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => funcslp_force,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(dir_row23_val_offset  to dir_row23_val_offset  + dir_row23_val_l2'length-1),
            scout   => sov(dir_row23_val_offset  to dir_row23_val_offset  + dir_row23_val_l2'length-1),
            din     => dir_row23_val_d,
            dout    => dir_row23_val_l2);
dir_row25_val_latch:  tri_rlmreg_p
  generic map (width => dir_row25_val_l2'length,  init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => dir_row_val_odd_act,
            thold_b => pc_iu_func_slp_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => funcslp_force,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(dir_row25_val_offset  to dir_row25_val_offset  + dir_row25_val_l2'length-1),
            scout   => sov(dir_row25_val_offset  to dir_row25_val_offset  + dir_row25_val_l2'length-1),
            din     => dir_row25_val_d,
            dout    => dir_row25_val_l2);
dir_row27_val_latch:  tri_rlmreg_p
  generic map (width => dir_row27_val_l2'length,  init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => dir_row_val_odd_act,
            thold_b => pc_iu_func_slp_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => funcslp_force,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(dir_row27_val_offset  to dir_row27_val_offset  + dir_row27_val_l2'length-1),
            scout   => sov(dir_row27_val_offset  to dir_row27_val_offset  + dir_row27_val_l2'length-1),
            din     => dir_row27_val_d,
            dout    => dir_row27_val_l2);
dir_row29_val_latch:  tri_rlmreg_p
  generic map (width => dir_row29_val_l2'length,  init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => dir_row_val_odd_act,
            thold_b => pc_iu_func_slp_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => funcslp_force,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(dir_row29_val_offset  to dir_row29_val_offset  + dir_row29_val_l2'length-1),
            scout   => sov(dir_row29_val_offset  to dir_row29_val_offset  + dir_row29_val_l2'length-1),
            din     => dir_row29_val_d,
            dout    => dir_row29_val_l2);
dir_row31_val_latch:  tri_rlmreg_p
  generic map (width => dir_row31_val_l2'length,  init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => dir_row_val_odd_act,
            thold_b => pc_iu_func_slp_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => funcslp_force,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(dir_row31_val_offset  to dir_row31_val_offset  + dir_row31_val_l2'length-1),
            scout   => sov(dir_row31_val_offset  to dir_row31_val_offset  + dir_row31_val_l2'length-1),
            din     => dir_row31_val_d,
            dout    => dir_row31_val_l2);
dir_row33_val_latch:  tri_rlmreg_p
  generic map (width => dir_row33_val_l2'length,  init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => dir_row_val_odd_act,
            thold_b => pc_iu_func_slp_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => funcslp_force,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(dir_row33_val_offset  to dir_row33_val_offset  + dir_row33_val_l2'length-1),
            scout   => sov(dir_row33_val_offset  to dir_row33_val_offset  + dir_row33_val_l2'length-1),
            din     => dir_row33_val_d,
            dout    => dir_row33_val_l2);
dir_row35_val_latch:  tri_rlmreg_p
  generic map (width => dir_row35_val_l2'length,  init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => dir_row_val_odd_act,
            thold_b => pc_iu_func_slp_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => funcslp_force,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(dir_row35_val_offset  to dir_row35_val_offset  + dir_row35_val_l2'length-1),
            scout   => sov(dir_row35_val_offset  to dir_row35_val_offset  + dir_row35_val_l2'length-1),
            din     => dir_row35_val_d,
            dout    => dir_row35_val_l2);
dir_row37_val_latch:  tri_rlmreg_p
  generic map (width => dir_row37_val_l2'length,  init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => dir_row_val_odd_act,
            thold_b => pc_iu_func_slp_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => funcslp_force,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(dir_row37_val_offset  to dir_row37_val_offset  + dir_row37_val_l2'length-1),
            scout   => sov(dir_row37_val_offset  to dir_row37_val_offset  + dir_row37_val_l2'length-1),
            din     => dir_row37_val_d,
            dout    => dir_row37_val_l2);
dir_row39_val_latch:  tri_rlmreg_p
  generic map (width => dir_row39_val_l2'length,  init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => dir_row_val_odd_act,
            thold_b => pc_iu_func_slp_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => funcslp_force,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(dir_row39_val_offset  to dir_row39_val_offset  + dir_row39_val_l2'length-1),
            scout   => sov(dir_row39_val_offset  to dir_row39_val_offset  + dir_row39_val_l2'length-1),
            din     => dir_row39_val_d,
            dout    => dir_row39_val_l2);
dir_row41_val_latch:  tri_rlmreg_p
  generic map (width => dir_row41_val_l2'length,  init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => dir_row_val_odd_act,
            thold_b => pc_iu_func_slp_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => funcslp_force,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(dir_row41_val_offset  to dir_row41_val_offset  + dir_row41_val_l2'length-1),
            scout   => sov(dir_row41_val_offset  to dir_row41_val_offset  + dir_row41_val_l2'length-1),
            din     => dir_row41_val_d,
            dout    => dir_row41_val_l2);
dir_row43_val_latch:  tri_rlmreg_p
  generic map (width => dir_row43_val_l2'length,  init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => dir_row_val_odd_act,
            thold_b => pc_iu_func_slp_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => funcslp_force,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(dir_row43_val_offset  to dir_row43_val_offset  + dir_row43_val_l2'length-1),
            scout   => sov(dir_row43_val_offset  to dir_row43_val_offset  + dir_row43_val_l2'length-1),
            din     => dir_row43_val_d,
            dout    => dir_row43_val_l2);
dir_row45_val_latch:  tri_rlmreg_p
  generic map (width => dir_row45_val_l2'length,  init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => dir_row_val_odd_act,
            thold_b => pc_iu_func_slp_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => funcslp_force,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(dir_row45_val_offset  to dir_row45_val_offset  + dir_row45_val_l2'length-1),
            scout   => sov(dir_row45_val_offset  to dir_row45_val_offset  + dir_row45_val_l2'length-1),
            din     => dir_row45_val_d,
            dout    => dir_row45_val_l2);
dir_row47_val_latch:  tri_rlmreg_p
  generic map (width => dir_row47_val_l2'length,  init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => dir_row_val_odd_act,
            thold_b => pc_iu_func_slp_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => funcslp_force,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(dir_row47_val_offset  to dir_row47_val_offset  + dir_row47_val_l2'length-1),
            scout   => sov(dir_row47_val_offset  to dir_row47_val_offset  + dir_row47_val_l2'length-1),
            din     => dir_row47_val_d,
            dout    => dir_row47_val_l2);
dir_row49_val_latch:  tri_rlmreg_p
  generic map (width => dir_row49_val_l2'length,  init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => dir_row_val_odd_act,
            thold_b => pc_iu_func_slp_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => funcslp_force,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(dir_row49_val_offset  to dir_row49_val_offset  + dir_row49_val_l2'length-1),
            scout   => sov(dir_row49_val_offset  to dir_row49_val_offset  + dir_row49_val_l2'length-1),
            din     => dir_row49_val_d,
            dout    => dir_row49_val_l2);
dir_row51_val_latch:  tri_rlmreg_p
  generic map (width => dir_row51_val_l2'length,  init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => dir_row_val_odd_act,
            thold_b => pc_iu_func_slp_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => funcslp_force,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(dir_row51_val_offset  to dir_row51_val_offset  + dir_row51_val_l2'length-1),
            scout   => sov(dir_row51_val_offset  to dir_row51_val_offset  + dir_row51_val_l2'length-1),
            din     => dir_row51_val_d,
            dout    => dir_row51_val_l2);
dir_row53_val_latch:  tri_rlmreg_p
  generic map (width => dir_row53_val_l2'length,  init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => dir_row_val_odd_act,
            thold_b => pc_iu_func_slp_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => funcslp_force,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(dir_row53_val_offset  to dir_row53_val_offset  + dir_row53_val_l2'length-1),
            scout   => sov(dir_row53_val_offset  to dir_row53_val_offset  + dir_row53_val_l2'length-1),
            din     => dir_row53_val_d,
            dout    => dir_row53_val_l2);
dir_row55_val_latch:  tri_rlmreg_p
  generic map (width => dir_row55_val_l2'length,  init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => dir_row_val_odd_act,
            thold_b => pc_iu_func_slp_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => funcslp_force,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(dir_row55_val_offset  to dir_row55_val_offset  + dir_row55_val_l2'length-1),
            scout   => sov(dir_row55_val_offset  to dir_row55_val_offset  + dir_row55_val_l2'length-1),
            din     => dir_row55_val_d,
            dout    => dir_row55_val_l2);
dir_row57_val_latch:  tri_rlmreg_p
  generic map (width => dir_row57_val_l2'length,  init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => dir_row_val_odd_act,
            thold_b => pc_iu_func_slp_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => funcslp_force,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(dir_row57_val_offset  to dir_row57_val_offset  + dir_row57_val_l2'length-1),
            scout   => sov(dir_row57_val_offset  to dir_row57_val_offset  + dir_row57_val_l2'length-1),
            din     => dir_row57_val_d,
            dout    => dir_row57_val_l2);
dir_row59_val_latch:  tri_rlmreg_p
  generic map (width => dir_row59_val_l2'length,  init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => dir_row_val_odd_act,
            thold_b => pc_iu_func_slp_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => funcslp_force,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(dir_row59_val_offset  to dir_row59_val_offset  + dir_row59_val_l2'length-1),
            scout   => sov(dir_row59_val_offset  to dir_row59_val_offset  + dir_row59_val_l2'length-1),
            din     => dir_row59_val_d,
            dout    => dir_row59_val_l2);
dir_row61_val_latch:  tri_rlmreg_p
  generic map (width => dir_row61_val_l2'length,  init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => dir_row_val_odd_act,
            thold_b => pc_iu_func_slp_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => funcslp_force,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(dir_row61_val_offset  to dir_row61_val_offset  + dir_row61_val_l2'length-1),
            scout   => sov(dir_row61_val_offset  to dir_row61_val_offset  + dir_row61_val_l2'length-1),
            din     => dir_row61_val_d,
            dout    => dir_row61_val_l2);
dir_row63_val_latch:  tri_rlmreg_p
  generic map (width => dir_row63_val_l2'length,  init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => dir_row_val_odd_act,
            thold_b => pc_iu_func_slp_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => funcslp_force,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(dir_row63_val_offset  to dir_row63_val_offset  + dir_row63_val_l2'length-1),
            scout   => sov(dir_row63_val_offset  to dir_row63_val_offset  + dir_row63_val_l2'length-1),
            din     => dir_row63_val_d,
            dout    => dir_row63_val_l2);
dir_row1_lru_latch:   tri_rlmreg_p
  generic map (width => dir_row1_lru_l2'length,   init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => dir_row_lru_odd_act,
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(dir_row1_lru_offset   to dir_row1_lru_offset   + dir_row1_lru_l2'length-1),
            scout   => sov(dir_row1_lru_offset   to dir_row1_lru_offset   + dir_row1_lru_l2'length-1),
            din     => dir_row1_lru_d,
            dout    => dir_row1_lru_l2);
dir_row3_lru_latch:   tri_rlmreg_p
  generic map (width => dir_row3_lru_l2'length,   init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => dir_row_lru_odd_act,
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(dir_row3_lru_offset   to dir_row3_lru_offset   + dir_row3_lru_l2'length-1),
            scout   => sov(dir_row3_lru_offset   to dir_row3_lru_offset   + dir_row3_lru_l2'length-1),
            din     => dir_row3_lru_d,
            dout    => dir_row3_lru_l2);
dir_row5_lru_latch:   tri_rlmreg_p
  generic map (width => dir_row5_lru_l2'length,   init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => dir_row_lru_odd_act,
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(dir_row5_lru_offset   to dir_row5_lru_offset   + dir_row5_lru_l2'length-1),
            scout   => sov(dir_row5_lru_offset   to dir_row5_lru_offset   + dir_row5_lru_l2'length-1),
            din     => dir_row5_lru_d,
            dout    => dir_row5_lru_l2);
dir_row7_lru_latch:   tri_rlmreg_p
  generic map (width => dir_row7_lru_l2'length,   init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => dir_row_lru_odd_act,
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(dir_row7_lru_offset   to dir_row7_lru_offset   + dir_row7_lru_l2'length-1),
            scout   => sov(dir_row7_lru_offset   to dir_row7_lru_offset   + dir_row7_lru_l2'length-1),
            din     => dir_row7_lru_d,
            dout    => dir_row7_lru_l2);
dir_row9_lru_latch:   tri_rlmreg_p
  generic map (width => dir_row9_lru_l2'length,   init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => dir_row_lru_odd_act,
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(dir_row9_lru_offset   to dir_row9_lru_offset   + dir_row9_lru_l2'length-1),
            scout   => sov(dir_row9_lru_offset   to dir_row9_lru_offset   + dir_row9_lru_l2'length-1),
            din     => dir_row9_lru_d,
            dout    => dir_row9_lru_l2);
dir_row11_lru_latch:  tri_rlmreg_p
  generic map (width => dir_row11_lru_l2'length,  init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => dir_row_lru_odd_act,
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(dir_row11_lru_offset  to dir_row11_lru_offset  + dir_row11_lru_l2'length-1),
            scout   => sov(dir_row11_lru_offset  to dir_row11_lru_offset  + dir_row11_lru_l2'length-1),
            din     => dir_row11_lru_d,
            dout    => dir_row11_lru_l2);
dir_row13_lru_latch:  tri_rlmreg_p
  generic map (width => dir_row13_lru_l2'length,  init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => dir_row_lru_odd_act,
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(dir_row13_lru_offset  to dir_row13_lru_offset  + dir_row13_lru_l2'length-1),
            scout   => sov(dir_row13_lru_offset  to dir_row13_lru_offset  + dir_row13_lru_l2'length-1),
            din     => dir_row13_lru_d,
            dout    => dir_row13_lru_l2);
dir_row15_lru_latch:  tri_rlmreg_p
  generic map (width => dir_row15_lru_l2'length,  init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => dir_row_lru_odd_act,
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(dir_row15_lru_offset  to dir_row15_lru_offset  + dir_row15_lru_l2'length-1),
            scout   => sov(dir_row15_lru_offset  to dir_row15_lru_offset  + dir_row15_lru_l2'length-1),
            din     => dir_row15_lru_d,
            dout    => dir_row15_lru_l2);
dir_row17_lru_latch:  tri_rlmreg_p
  generic map (width => dir_row17_lru_l2'length,  init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => dir_row_lru_odd_act,
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(dir_row17_lru_offset  to dir_row17_lru_offset  + dir_row17_lru_l2'length-1),
            scout   => sov(dir_row17_lru_offset  to dir_row17_lru_offset  + dir_row17_lru_l2'length-1),
            din     => dir_row17_lru_d,
            dout    => dir_row17_lru_l2);
dir_row19_lru_latch:  tri_rlmreg_p
  generic map (width => dir_row19_lru_l2'length,  init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => dir_row_lru_odd_act,
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(dir_row19_lru_offset  to dir_row19_lru_offset  + dir_row19_lru_l2'length-1),
            scout   => sov(dir_row19_lru_offset  to dir_row19_lru_offset  + dir_row19_lru_l2'length-1),
            din     => dir_row19_lru_d,
            dout    => dir_row19_lru_l2);
dir_row21_lru_latch:  tri_rlmreg_p
  generic map (width => dir_row21_lru_l2'length,  init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => dir_row_lru_odd_act,
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(dir_row21_lru_offset  to dir_row21_lru_offset  + dir_row21_lru_l2'length-1),
            scout   => sov(dir_row21_lru_offset  to dir_row21_lru_offset  + dir_row21_lru_l2'length-1),
            din     => dir_row21_lru_d,
            dout    => dir_row21_lru_l2);
dir_row23_lru_latch:  tri_rlmreg_p
  generic map (width => dir_row23_lru_l2'length,  init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => dir_row_lru_odd_act,
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(dir_row23_lru_offset  to dir_row23_lru_offset  + dir_row23_lru_l2'length-1),
            scout   => sov(dir_row23_lru_offset  to dir_row23_lru_offset  + dir_row23_lru_l2'length-1),
            din     => dir_row23_lru_d,
            dout    => dir_row23_lru_l2);
dir_row25_lru_latch:  tri_rlmreg_p
  generic map (width => dir_row25_lru_l2'length,  init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => dir_row_lru_odd_act,
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(dir_row25_lru_offset  to dir_row25_lru_offset  + dir_row25_lru_l2'length-1),
            scout   => sov(dir_row25_lru_offset  to dir_row25_lru_offset  + dir_row25_lru_l2'length-1),
            din     => dir_row25_lru_d,
            dout    => dir_row25_lru_l2);
dir_row27_lru_latch:  tri_rlmreg_p
  generic map (width => dir_row27_lru_l2'length,  init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => dir_row_lru_odd_act,
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(dir_row27_lru_offset  to dir_row27_lru_offset  + dir_row27_lru_l2'length-1),
            scout   => sov(dir_row27_lru_offset  to dir_row27_lru_offset  + dir_row27_lru_l2'length-1),
            din     => dir_row27_lru_d,
            dout    => dir_row27_lru_l2);
dir_row29_lru_latch:  tri_rlmreg_p
  generic map (width => dir_row29_lru_l2'length,  init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => dir_row_lru_odd_act,
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(dir_row29_lru_offset  to dir_row29_lru_offset  + dir_row29_lru_l2'length-1),
            scout   => sov(dir_row29_lru_offset  to dir_row29_lru_offset  + dir_row29_lru_l2'length-1),
            din     => dir_row29_lru_d,
            dout    => dir_row29_lru_l2);
dir_row31_lru_latch:  tri_rlmreg_p
  generic map (width => dir_row31_lru_l2'length,  init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => dir_row_lru_odd_act,
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(dir_row31_lru_offset  to dir_row31_lru_offset  + dir_row31_lru_l2'length-1),
            scout   => sov(dir_row31_lru_offset  to dir_row31_lru_offset  + dir_row31_lru_l2'length-1),
            din     => dir_row31_lru_d,
            dout    => dir_row31_lru_l2);
dir_row33_lru_latch:  tri_rlmreg_p
  generic map (width => dir_row33_lru_l2'length,  init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => dir_row_lru_odd_act,
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(dir_row33_lru_offset  to dir_row33_lru_offset  + dir_row33_lru_l2'length-1),
            scout   => sov(dir_row33_lru_offset  to dir_row33_lru_offset  + dir_row33_lru_l2'length-1),
            din     => dir_row33_lru_d,
            dout    => dir_row33_lru_l2);
dir_row35_lru_latch:  tri_rlmreg_p
  generic map (width => dir_row35_lru_l2'length,  init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => dir_row_lru_odd_act,
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(dir_row35_lru_offset  to dir_row35_lru_offset  + dir_row35_lru_l2'length-1),
            scout   => sov(dir_row35_lru_offset  to dir_row35_lru_offset  + dir_row35_lru_l2'length-1),
            din     => dir_row35_lru_d,
            dout    => dir_row35_lru_l2);
dir_row37_lru_latch:  tri_rlmreg_p
  generic map (width => dir_row37_lru_l2'length,  init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => dir_row_lru_odd_act,
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(dir_row37_lru_offset  to dir_row37_lru_offset  + dir_row37_lru_l2'length-1),
            scout   => sov(dir_row37_lru_offset  to dir_row37_lru_offset  + dir_row37_lru_l2'length-1),
            din     => dir_row37_lru_d,
            dout    => dir_row37_lru_l2);
dir_row39_lru_latch:  tri_rlmreg_p
  generic map (width => dir_row39_lru_l2'length,  init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => dir_row_lru_odd_act,
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(dir_row39_lru_offset  to dir_row39_lru_offset  + dir_row39_lru_l2'length-1),
            scout   => sov(dir_row39_lru_offset  to dir_row39_lru_offset  + dir_row39_lru_l2'length-1),
            din     => dir_row39_lru_d,
            dout    => dir_row39_lru_l2);
dir_row41_lru_latch:  tri_rlmreg_p
  generic map (width => dir_row41_lru_l2'length,  init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => dir_row_lru_odd_act,
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(dir_row41_lru_offset  to dir_row41_lru_offset  + dir_row41_lru_l2'length-1),
            scout   => sov(dir_row41_lru_offset  to dir_row41_lru_offset  + dir_row41_lru_l2'length-1),
            din     => dir_row41_lru_d,
            dout    => dir_row41_lru_l2);
dir_row43_lru_latch:  tri_rlmreg_p
  generic map (width => dir_row43_lru_l2'length,  init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => dir_row_lru_odd_act,
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(dir_row43_lru_offset  to dir_row43_lru_offset  + dir_row43_lru_l2'length-1),
            scout   => sov(dir_row43_lru_offset  to dir_row43_lru_offset  + dir_row43_lru_l2'length-1),
            din     => dir_row43_lru_d,
            dout    => dir_row43_lru_l2);
dir_row45_lru_latch:  tri_rlmreg_p
  generic map (width => dir_row45_lru_l2'length,  init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => dir_row_lru_odd_act,
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(dir_row45_lru_offset  to dir_row45_lru_offset  + dir_row45_lru_l2'length-1),
            scout   => sov(dir_row45_lru_offset  to dir_row45_lru_offset  + dir_row45_lru_l2'length-1),
            din     => dir_row45_lru_d,
            dout    => dir_row45_lru_l2);
dir_row47_lru_latch:  tri_rlmreg_p
  generic map (width => dir_row47_lru_l2'length,  init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => dir_row_lru_odd_act,
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(dir_row47_lru_offset  to dir_row47_lru_offset  + dir_row47_lru_l2'length-1),
            scout   => sov(dir_row47_lru_offset  to dir_row47_lru_offset  + dir_row47_lru_l2'length-1),
            din     => dir_row47_lru_d,
            dout    => dir_row47_lru_l2);
dir_row49_lru_latch:  tri_rlmreg_p
  generic map (width => dir_row49_lru_l2'length,  init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => dir_row_lru_odd_act,
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(dir_row49_lru_offset  to dir_row49_lru_offset  + dir_row49_lru_l2'length-1),
            scout   => sov(dir_row49_lru_offset  to dir_row49_lru_offset  + dir_row49_lru_l2'length-1),
            din     => dir_row49_lru_d,
            dout    => dir_row49_lru_l2);
dir_row51_lru_latch:  tri_rlmreg_p
  generic map (width => dir_row51_lru_l2'length,  init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => dir_row_lru_odd_act,
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(dir_row51_lru_offset  to dir_row51_lru_offset  + dir_row51_lru_l2'length-1),
            scout   => sov(dir_row51_lru_offset  to dir_row51_lru_offset  + dir_row51_lru_l2'length-1),
            din     => dir_row51_lru_d,
            dout    => dir_row51_lru_l2);
dir_row53_lru_latch:  tri_rlmreg_p
  generic map (width => dir_row53_lru_l2'length,  init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => dir_row_lru_odd_act,
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(dir_row53_lru_offset  to dir_row53_lru_offset  + dir_row53_lru_l2'length-1),
            scout   => sov(dir_row53_lru_offset  to dir_row53_lru_offset  + dir_row53_lru_l2'length-1),
            din     => dir_row53_lru_d,
            dout    => dir_row53_lru_l2);
dir_row55_lru_latch:  tri_rlmreg_p
  generic map (width => dir_row55_lru_l2'length,  init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => dir_row_lru_odd_act,
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(dir_row55_lru_offset  to dir_row55_lru_offset  + dir_row55_lru_l2'length-1),
            scout   => sov(dir_row55_lru_offset  to dir_row55_lru_offset  + dir_row55_lru_l2'length-1),
            din     => dir_row55_lru_d,
            dout    => dir_row55_lru_l2);
dir_row57_lru_latch:  tri_rlmreg_p
  generic map (width => dir_row57_lru_l2'length,  init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => dir_row_lru_odd_act,
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(dir_row57_lru_offset  to dir_row57_lru_offset  + dir_row57_lru_l2'length-1),
            scout   => sov(dir_row57_lru_offset  to dir_row57_lru_offset  + dir_row57_lru_l2'length-1),
            din     => dir_row57_lru_d,
            dout    => dir_row57_lru_l2);
dir_row59_lru_latch:  tri_rlmreg_p
  generic map (width => dir_row59_lru_l2'length,  init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => dir_row_lru_odd_act,
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(dir_row59_lru_offset  to dir_row59_lru_offset  + dir_row59_lru_l2'length-1),
            scout   => sov(dir_row59_lru_offset  to dir_row59_lru_offset  + dir_row59_lru_l2'length-1),
            din     => dir_row59_lru_d,
            dout    => dir_row59_lru_l2);
dir_row61_lru_latch:  tri_rlmreg_p
  generic map (width => dir_row61_lru_l2'length,  init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => dir_row_lru_odd_act,
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(dir_row61_lru_offset  to dir_row61_lru_offset  + dir_row61_lru_l2'length-1),
            scout   => sov(dir_row61_lru_offset  to dir_row61_lru_offset  + dir_row61_lru_l2'length-1),
            din     => dir_row61_lru_d,
            dout    => dir_row61_lru_l2);
dir_row63_lru_latch:  tri_rlmreg_p
  generic map (width => dir_row63_lru_l2'length,  init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => dir_row_lru_odd_act,
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(dir_row63_lru_offset  to dir_row63_lru_offset  + dir_row63_lru_l2'length-1),
            scout   => sov(dir_row63_lru_offset  to dir_row63_lru_offset  + dir_row63_lru_l2'length-1),
            din     => dir_row63_lru_d,
            dout    => dir_row63_lru_l2);
-- IU3
iu3_instr_valid_latch: tri_rlmreg_p
  generic map (width => iu3_instr_valid_l2'length, init => 0, needs_sreset => 1, expand_type => expand_type)
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
            scin    => siv(iu3_instr_valid_offset to iu3_instr_valid_offset + iu3_instr_valid_l2'length-1),
            scout   => sov(iu3_instr_valid_offset to iu3_instr_valid_offset + iu3_instr_valid_l2'length-1),
            din     => iu3_instr_valid_d,
            dout    => iu3_instr_valid_l2);
iu3_tid_latch: tri_rlmreg_p
  generic map (width => iu3_tid_l2'length, init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => iu3_act,
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(iu3_tid_offset to iu3_tid_offset + iu3_tid_l2'length-1),
            scout   => sov(iu3_tid_offset to iu3_tid_offset + iu3_tid_l2'length-1),
            din     => iu3_tid_d,
            dout    => iu3_tid_l2);
iu3_ifar_latch: tri_rlmreg_p
  generic map (width => iu3_ifar_l2'length, init => 0, needs_sreset => 0, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => iu3_act,
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(iu3_ifar_offset to iu3_ifar_offset + iu3_ifar_l2'length-1),
            scout   => sov(iu3_ifar_offset to iu3_ifar_offset + iu3_ifar_l2'length-1),
            din     => iu3_ifar_d,
            dout    => iu3_ifar_l2);
iu3_ifar_dec_latch: tri_rlmreg_p
  generic map (width => iu3_ifar_dec_l2'length, init => 0, needs_sreset => 0, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => iu3_act,
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(iu3_ifar_dec_offset to iu3_ifar_dec_offset + iu3_ifar_dec_l2'length-1),
            scout   => sov(iu3_ifar_dec_offset to iu3_ifar_dec_offset + iu3_ifar_dec_l2'length-1),
            din     => iu3_ifar_dec_d,
            dout    => iu3_ifar_dec_l2);
iu3_2ucode_latch: tri_rlmlatch_p
  generic map (init => 0, needs_sreset => 0, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => iu3_act,
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(iu3_2ucode_offset),
            scout   => sov(iu3_2ucode_offset),
            din     => iu3_2ucode_d,
            dout    => iu3_2ucode_l2);
iu3_2ucode_type_latch: tri_rlmlatch_p
  generic map (init => 0, needs_sreset => 0, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => iu3_act,
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(iu3_2ucode_type_offset),
            scout   => sov(iu3_2ucode_type_offset),
            din     => iu3_2ucode_type_d,
            dout    => iu3_2ucode_type_l2);
iu3_erat_err_latch: tri_rlmreg_p
  generic map (width => iu3_erat_err_l2'length, init => 0, needs_sreset => 1, expand_type => expand_type)
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
            scin    => siv(iu3_erat_err_offset to iu3_erat_err_offset + iu3_erat_err_l2'length-1),
            scout   => sov(iu3_erat_err_offset to iu3_erat_err_offset + iu3_erat_err_l2'length-1),
            din     => iu3_erat_err_d,
            dout    => iu3_erat_err_l2);
iu3_dir_parity_err_way_latch: tri_rlmreg_p
  generic map (width => iu3_dir_parity_err_way_l2'length, init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => iu3_parity_act,
            thold_b => pc_iu_func_slp_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => funcslp_force,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(iu3_dir_parity_err_way_offset to iu3_dir_parity_err_way_offset + iu3_dir_parity_err_way_l2'length-1),
            scout   => sov(iu3_dir_parity_err_way_offset to iu3_dir_parity_err_way_offset + iu3_dir_parity_err_way_l2'length-1),
            din     => iu3_dir_parity_err_way_d,
            dout    => iu3_dir_parity_err_way_l2);
iu3_data_parity_err_way_latch: tri_rlmreg_p
  generic map (width => iu3_data_parity_err_way_l2'length, init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => iu3_parity_act,
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(iu3_data_parity_err_way_offset to iu3_data_parity_err_way_offset + iu3_data_parity_err_way_l2'length-1),
            scout   => sov(iu3_data_parity_err_way_offset to iu3_data_parity_err_way_offset + iu3_data_parity_err_way_l2'length-1),
            din     => iu3_data_parity_err_way_d,
            dout    => iu3_data_parity_err_way_l2);
iu3_parity_needs_flush_latch: tri_rlmreg_p
  generic map (width => iu3_parity_needs_flush_l2'length, init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => iu3_parity_act,
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(iu3_parity_needs_flush_offset to iu3_parity_needs_flush_offset + iu3_parity_needs_flush_l2'length-1),
            scout   => sov(iu3_parity_needs_flush_offset to iu3_parity_needs_flush_offset + iu3_parity_needs_flush_l2'length-1),
            din     => iu3_parity_needs_flush_d,
            dout    => iu3_parity_needs_flush_l2);
iu3_parity_tag_latch: tri_rlmreg_p
  generic map (width => iu3_parity_tag_l2'length, init => 0, needs_sreset => 0, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => iu3_parity_act,
            thold_b => pc_iu_func_slp_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => funcslp_force,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(iu3_parity_tag_offset to iu3_parity_tag_offset + iu3_parity_tag_l2'length-1),
            scout   => sov(iu3_parity_tag_offset to iu3_parity_tag_offset + iu3_parity_tag_l2'length-1),
            din     => iu3_parity_tag_d,
            dout    => iu3_parity_tag_l2);
iu3_rd_parity_err_latch: tri_rlmlatch_p
  generic map (init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => iu3_parity_act,
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(iu3_rd_parity_err_offset),
            scout   => sov(iu3_rd_parity_err_offset),
            din     => iu3_rd_parity_err_d,
            dout    => iu3_rd_parity_err_l2);
iu3_rd_miss_latch: tri_rlmlatch_p
  generic map (init => 0, needs_sreset => 1, expand_type => expand_type)
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
            scin    => siv(iu3_rd_miss_offset),
            scout   => sov(iu3_rd_miss_offset),
            din     => iu3_rd_miss_d,
            dout    => iu3_rd_miss_l2);
err_icache_parity_latch: tri_rlmlatch_p
  generic map (init => 0, needs_sreset => 1, expand_type => expand_type)
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
            scin    => siv(err_icache_parity_offset),
            scout   => sov(err_icache_parity_offset),
            din     => err_icache_parity_d,
            dout    => err_icache_parity_l2);
err_icachedir_parity_latch: tri_rlmlatch_p
  generic map (init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => iu3_parity_act,
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(err_icachedir_parity_offset),
            scout   => sov(err_icachedir_parity_offset),
            din     => err_icachedir_parity_d,
            dout    => err_icachedir_parity_l2);
iu3_multihit_err_way_latch: tri_rlmreg_p
  generic map (width => iu3_multihit_err_way_l2'length, init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => iu3_parity_act,
            thold_b => pc_iu_func_slp_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => funcslp_force,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(iu3_multihit_err_way_offset to iu3_multihit_err_way_offset + iu3_multihit_err_way_l2'length-1),
            scout   => sov(iu3_multihit_err_way_offset to iu3_multihit_err_way_offset + iu3_multihit_err_way_l2'length-1),
            din     => iu3_multihit_err_way_d,
            dout    => iu3_multihit_err_way_l2);
iu3_multihit_flush_latch: tri_rlmlatch_p
  generic map (init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => iu3_parity_act,
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(iu3_multihit_flush_offset),
            scout   => sov(iu3_multihit_flush_offset),
            din     => iu3_multihit_flush_d,
            dout    => iu3_multihit_flush_l2);
perf_instr_count_t0_latch:   tri_rlmreg_p
  generic map (width => perf_instr_count_t0_l2'length,   init => 0, needs_sreset => 0, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => iu3_act,
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(perf_instr_count_t0_offset   to perf_instr_count_t0_offset   + perf_instr_count_t0_l2'length-1),
            scout   => sov(perf_instr_count_t0_offset   to perf_instr_count_t0_offset   + perf_instr_count_t0_l2'length-1),
            din     => perf_instr_count_t0_d,
            dout    => perf_instr_count_t0_l2);
perf_instr_count_t1_latch:   tri_rlmreg_p
  generic map (width => perf_instr_count_t1_l2'length,   init => 0, needs_sreset => 0, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => iu3_act,
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(perf_instr_count_t1_offset   to perf_instr_count_t1_offset   + perf_instr_count_t1_l2'length-1),
            scout   => sov(perf_instr_count_t1_offset   to perf_instr_count_t1_offset   + perf_instr_count_t1_l2'length-1),
            din     => perf_instr_count_t1_d,
            dout    => perf_instr_count_t1_l2);
perf_instr_count_t2_latch:   tri_rlmreg_p
  generic map (width => perf_instr_count_t2_l2'length,   init => 0, needs_sreset => 0, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => iu3_act,
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(perf_instr_count_t2_offset   to perf_instr_count_t2_offset   + perf_instr_count_t2_l2'length-1),
            scout   => sov(perf_instr_count_t2_offset   to perf_instr_count_t2_offset   + perf_instr_count_t2_l2'length-1),
            din     => perf_instr_count_t2_d,
            dout    => perf_instr_count_t2_l2);
perf_instr_count_t3_latch:   tri_rlmreg_p
  generic map (width => perf_instr_count_t3_l2'length,   init => 0, needs_sreset => 0, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => iu3_act,
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(perf_instr_count_t3_offset   to perf_instr_count_t3_offset   + perf_instr_count_t3_l2'length-1),
            scout   => sov(perf_instr_count_t3_offset   to perf_instr_count_t3_offset   + perf_instr_count_t3_l2'length-1),
            din     => perf_instr_count_t3_d,
            dout    => perf_instr_count_t3_l2);
perf_event_t0_latch:   tri_rlmreg_p
  generic map (width => perf_event_t0_l2'length,   init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => event_bus_enable,
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(perf_event_t0_offset   to perf_event_t0_offset   + perf_event_t0_l2'length-1),
            scout   => sov(perf_event_t0_offset   to perf_event_t0_offset   + perf_event_t0_l2'length-1),
            din     => perf_event_t0_d,
            dout    => perf_event_t0_l2);
perf_event_t1_latch:   tri_rlmreg_p
  generic map (width => perf_event_t1_l2'length,   init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => event_bus_enable,
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(perf_event_t1_offset   to perf_event_t1_offset   + perf_event_t1_l2'length-1),
            scout   => sov(perf_event_t1_offset   to perf_event_t1_offset   + perf_event_t1_l2'length-1),
            din     => perf_event_t1_d,
            dout    => perf_event_t1_l2);
perf_event_t2_latch:   tri_rlmreg_p
  generic map (width => perf_event_t2_l2'length,   init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => event_bus_enable,
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(perf_event_t2_offset   to perf_event_t2_offset   + perf_event_t2_l2'length-1),
            scout   => sov(perf_event_t2_offset   to perf_event_t2_offset   + perf_event_t2_l2'length-1),
            din     => perf_event_t2_d,
            dout    => perf_event_t2_l2);
perf_event_t3_latch:   tri_rlmreg_p
  generic map (width => perf_event_t3_l2'length,   init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => event_bus_enable,
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(perf_event_t3_offset   to perf_event_t3_offset   + perf_event_t3_l2'length-1),
            scout   => sov(perf_event_t3_offset   to perf_event_t3_offset   + perf_event_t3_l2'length-1),
            din     => perf_event_t3_d,
            dout    => perf_event_t3_l2);
perf_event_latch: tri_rlmreg_p
  generic map (width => perf_event_l2'length, init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => event_bus_enable,
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
spr_ic_cls_latch: tri_rlmlatch_p
  generic map (init => 0, needs_sreset => 1, expand_type => expand_type)
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
            scin    => siv(spr_ic_cls_offset),
            scout   => sov(spr_ic_cls_offset),
            din     => spr_ic_cls_d,
            dout    => spr_ic_cls_l2);
spr_ic_idir_way_latch: tri_rlmreg_p
  generic map (width => spr_ic_idir_way_l2'length, init => 0, needs_sreset => 0, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => dir_dataout_act,
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(spr_ic_idir_way_offset to spr_ic_idir_way_offset + spr_ic_idir_way_l2'length-1),
            scout   => sov(spr_ic_idir_way_offset to spr_ic_idir_way_offset + spr_ic_idir_way_l2'length-1),
            din     => spr_ic_idir_way_d,
            dout    => spr_ic_idir_way_l2);
iu1_spr_idir_read_latch: tri_rlmlatch_p
  generic map (init => 0, needs_sreset => 1, expand_type => expand_type)
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
            scin    => siv(iu1_spr_idir_read_offset),
            scout   => sov(iu1_spr_idir_read_offset),
            din     => iu1_spr_idir_read_d,
            dout    => iu1_spr_idir_read_l2);
iu2_spr_idir_read_latch: tri_rlmlatch_p
  generic map (init => 0, needs_sreset => 1, expand_type => expand_type)
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
            scin    => siv(iu2_spr_idir_read_offset),
            scout   => sov(iu2_spr_idir_read_offset),
            din     => iu2_spr_idir_read_d,
            dout    => iu2_spr_idir_read_l2);
iu2_spr_idir_lru_latch: tri_rlmreg_p
  generic map (width => iu2_spr_idir_lru_l2'length, init => 0, needs_sreset => 0, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => dir_dataout_act,
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(iu2_spr_idir_lru_offset to iu2_spr_idir_lru_offset + iu2_spr_idir_lru_l2'length-1),
            scout   => sov(iu2_spr_idir_lru_offset to iu2_spr_idir_lru_offset + iu2_spr_idir_lru_l2'length-1),
            din     => iu2_spr_idir_lru_d,
            dout    => iu2_spr_idir_lru_l2);
dbg_dir_write_latch: tri_rlmlatch_p
  generic map (init => 0, needs_sreset => 0, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => trace_bus_enable,
            thold_b => pc_iu_func_slp_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => funcslp_force,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(dbg_dir_write_offset),
            scout   => sov(dbg_dir_write_offset),
            din     => dbg_dir_write_d,
            dout    => dbg_dir_write_l2);
dbg_dir_rd_act_latch: tri_rlmlatch_p
  generic map (init => 0, needs_sreset => 0, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => trace_bus_enable,
            thold_b => pc_iu_func_slp_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => funcslp_force,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(dbg_dir_rd_act_offset),
            scout   => sov(dbg_dir_rd_act_offset),
            din     => dbg_dir_rd_act_d,
            dout    => dbg_dir_rd_act_l2);
dbg_iu2_lru_rd_update_latch: tri_rlmlatch_p
  generic map (init => 0, needs_sreset => 0, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => trace_bus_enable,
            thold_b => pc_iu_func_slp_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => funcslp_force,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(dbg_iu2_lru_rd_update_offset),
            scout   => sov(dbg_iu2_lru_rd_update_offset),
            din     => dbg_iu2_lru_rd_update_d,
            dout    => dbg_iu2_lru_rd_update_l2);
dbg_iu2_rd_way_tag_hit_latch: tri_rlmreg_p
  generic map (width => dbg_iu2_rd_way_tag_hit_l2'length, init => 0, needs_sreset => 0, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => trace_bus_enable,
            thold_b => pc_iu_func_slp_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => funcslp_force,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(dbg_iu2_rd_way_tag_hit_offset to dbg_iu2_rd_way_tag_hit_offset + dbg_iu2_rd_way_tag_hit_l2'length-1),
            scout   => sov(dbg_iu2_rd_way_tag_hit_offset to dbg_iu2_rd_way_tag_hit_offset + dbg_iu2_rd_way_tag_hit_l2'length-1),
            din     => dbg_iu2_rd_way_tag_hit_d,
            dout    => dbg_iu2_rd_way_tag_hit_l2);
dbg_iu2_rd_way_hit_latch: tri_rlmreg_p
  generic map (width => dbg_iu2_rd_way_hit_l2'length, init => 0, needs_sreset => 0, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => trace_bus_enable,
            thold_b => pc_iu_func_slp_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => funcslp_force,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(dbg_iu2_rd_way_hit_offset to dbg_iu2_rd_way_hit_offset + dbg_iu2_rd_way_hit_l2'length-1),
            scout   => sov(dbg_iu2_rd_way_hit_offset to dbg_iu2_rd_way_hit_offset + dbg_iu2_rd_way_hit_l2'length-1),
            din     => dbg_iu2_rd_way_hit_d,
            dout    => dbg_iu2_rd_way_hit_l2);
dbg_load_iu2_latch: tri_rlmlatch_p
  generic map (init => 0, needs_sreset => 0, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => trace_bus_enable,
            thold_b => pc_iu_func_slp_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => funcslp_force,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(dbg_load_iu2_offset),
            scout   => sov(dbg_load_iu2_offset),
            din     => dbg_load_iu2_d,
            dout    => dbg_load_iu2_l2);
spare_slp_latch: tri_rlmreg_p
  generic map (width => spare_slp_l2'length, init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => tiup,
            thold_b => pc_iu_func_slp_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => funcslp_force,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(spare_slp_offset to spare_slp_offset + spare_slp_l2'length-1),
            scout   => sov(spare_slp_offset to spare_slp_offset + spare_slp_l2'length-1),
            din     => spare_slp_l2,
            dout    => spare_slp_l2);
spare_a_latch: tri_rlmreg_p
  generic map (width => 8, init => 0, needs_sreset => 1, expand_type => expand_type)
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
            scin    => siv(spare_a_offset to spare_a_offset + 7),
            scout   => sov(spare_a_offset to spare_a_offset + 7),
            din     => spare_l2(0 to 7),
            dout    => spare_l2(0 to 7));
spare_b_latch: tri_rlmreg_p
  generic map (width => 8, init => 0, needs_sreset => 1, expand_type => expand_type)
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
            scin    => siv(spare_b_offset to spare_b_offset + 7),
            scout   => sov(spare_b_offset to spare_b_offset + 7),
            din     => spare_l2(8 to 15),
            dout    => spare_l2(8 to 15));
-----------------------------------------------------------------------
-- abist latches
-----------------------------------------------------------------------
ab_reg: tri_rlmreg_p
  generic map (init => 0, expand_type => expand_type, width => 39, needs_sreset => 0)
  port map (vd                  => vdd,
            gd                  => gnd,
            nclk                => nclk,
            act                 => pc_iu_abist_ena_dc,
            thold_b             => pc_iu_abst_sl_thold_0_b,
            sg                  => pc_iu_sg_0,
            forcee => abst_force,
            delay_lclkr         => delay_lclkr,
            mpw1_b              => mpw1_b,
            mpw2_b              => mpw2_b,
            d_mode              => d_mode,
            scin                => abst_siv(4 to 42),
            scout               => abst_sov(4 to 42),
            din ( 0      )      => pc_iu_abist_g8t_wenb,
            din ( 1      )      => pc_iu_abist_g8t1p_renb_0,
            din ( 2 to  5)      => pc_iu_abist_di_0,
            din ( 6      )      => pc_iu_abist_g8t_bw_1,
            din ( 7      )      => pc_iu_abist_g8t_bw_0,
            din ( 8 to 13)      => pc_iu_abist_waddr_0,
            din (14      )      => pc_iu_abist_wl64_comp_ena,
            din (15 to 18)      => pc_iu_abist_g8t_dcomp,
            din (19 to 26)      => pc_iu_abist_raddr_0,
            din (27 to 28)      => pc_iu_abist_g6t_bw,
            din (29 to 32)      => pc_iu_abist_di_g6t_2r,
            din (33      )      => pc_iu_abist_wl256_comp_ena,
            din (34 to 37)      => pc_iu_abist_dcomp_g6t_2r,
            din (38      )      => pc_iu_abist_g6t_r_wb,
            dout( 0      )      => stage_abist_g8t_wenb,
            dout( 1      )      => stage_abist_g8t1p_renb_0,
            dout( 2 to 5 )      => stage_abist_di_0,
            dout( 6      )      => stage_abist_g8t_bw_1,
            dout( 7      )      => stage_abist_g8t_bw_0,
            dout( 8 to 13)      => stage_abist_waddr_0,
            dout(14      )      => stage_abist_wl64_comp_ena,
            dout(15 to 18)      => stage_abist_g8t_dcomp,
            dout(19 to 26)      => stage_abist_raddr_0,
            dout(27 to 28)      => stage_abist_g6t_bw,
            dout(29 to 32)      => stage_abist_di_g6t_2r,
            dout(33      )      => stage_abist_wl256_comp_ena,
            dout(34 to 37)      => stage_abist_dcomp_g6t_2r,
            dout(38      )      => stage_abist_g6t_r_wb);
-----------------------------------------------------------------------
-- Scan
-----------------------------------------------------------------------
repr_slat_sl_thold_0_b  <=  not pc_iu_repr_sl_thold_0;
time_slat_sl_thold_0_b  <=  not pc_iu_time_sl_thold_0;
repr_scan_latch: entity tri.tri_regs
  generic map (width => 2, init => 0, needs_sreset => 0, expand_type => expand_type)
  port map (vd          => vdd,
            gd          => gnd,
            nclk        => nclk,
            forcee => pc_iu_sg_0,
            thold_b     => repr_slat_sl_thold_0_b,
            delay_lclkr => delay_lclkr,
            scin(0)     => repr_scan_in,
            scin(1)     => repr_siv(2),
            scout(0)    => repr_siv(0),
            scout(1)    => repr_sov(2),
            dout        => open );
time_scan_latch: entity tri.tri_regs
  generic map (width => 1, init => 0, needs_sreset => 0, expand_type => expand_type)
  port map (vd          => vdd,
            gd          => gnd,
            nclk        => nclk,
            forcee => pc_iu_sg_0,
            thold_b     => time_slat_sl_thold_0_b,
            delay_lclkr => delay_lclkr,
            scin(0)     => time_siv(2),
            scout(0)    => time_sov(2),
            dout        => open );
siv(0 TO scan0_right) <=  sov(1 to scan0_right) & func_scan_in(0);
func_scan_out(0) <=  sov(0) and an_ac_scan_dis_dc_b;
siv(scan1_left TO scan_right) <=  sov(scan1_left+1 to scan_right) & func_scan_in(1);
func_scan_out(1) <=  sov(scan1_left) and an_ac_scan_dis_dc_b;
-- Chain 0: WAY01 IDIR & IDATA
abst_siv(0 TO 1) <=  abst_sov(1) & abst_scan_in(0);
abst_scan_out(0) <=  abst_sov(0) and an_ac_scan_dis_dc_b;
-- Chain 1: WAY23 IDIR & IDATA
abst_siv(2 TO 3) <=  abst_sov(3) & abst_scan_in(1);
abst_scan_out(1) <=  abst_sov(2) and an_ac_scan_dis_dc_b;
-- Chain 2: AB_REG - tack on to BHT's scan chain
abst_siv(4 TO abst_siv'right) <=  abst_sov(5 to abst_sov'right) & abst_scan_in(2);
abst_scan_out(2) <=  abst_sov(4) and an_ac_scan_dis_dc_b;
time_siv  <=  time_scan_in & time_sov(0 to 1);
time_scan_out  <=  time_sov(2) and an_ac_scan_dis_dc_b;
repr_siv(1 TO 2) <=  repr_sov(0 to 1);
repr_scan_out  <=  repr_sov(2) and an_ac_scan_dis_dc_b;
END IUQ_IC_DIR;
