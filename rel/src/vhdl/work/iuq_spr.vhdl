-- © IBM Corp. 2020
-- This softcore is licensed under and subject to the terms of the CC-BY 4.0
-- license (https://creativecommons.org/licenses/by/4.0/legalcode). 
-- Additional rights, including the right to physically implement a softcore 
-- that is compliant with the required sections of the Power ISA 
-- Specification, will be available at no cost via the OpenPOWER Foundation. 
-- This README will be updated with additional information when OpenPOWER's 
-- license is available.



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

entity iuq_spr is
generic(regmode     : integer := 6;
        a2mode      : integer := 1;
        expand_type : integer := 2 ); 
port(
     vdd                                        : inout power_logic;
     gnd                                        : inout power_logic;

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


     xu_iu_run_thread           : in  std_ulogic_vector(0 to 3);

     xu_iu_ex6_pri              : in std_ulogic_vector(0 to 2);
     xu_iu_ex6_pri_val          : in std_ulogic_vector(0 to 3);

     xu_iu_raise_iss_pri        : in std_ulogic_vector(0 to 3);
     xu_iu_msr_gs               : in std_ulogic_vector(0 to 3);
     xu_iu_msr_pr               : in std_ulogic_vector(0 to 3);

     nclk                       : in  clk_logic;
     pc_iu_sg_2                 : in  std_ulogic;
     pc_iu_func_sl_thold_2      : in  std_ulogic;
     pc_iu_cfg_sl_thold_2       : in  std_ulogic;
     clkoff_b                   : in  std_ulogic;
     act_dis                    : in  std_ulogic;
     tc_ac_ccflush_dc           : in  std_ulogic;
     d_mode                     : in  std_ulogic;
     delay_lclkr                : in  std_ulogic;
     mpw1_b                     : in  std_ulogic;
     mpw2_b                     : in  std_ulogic;
     ccfg_scan_in               : in  std_ulogic;
     ccfg_scan_out              : out std_ulogic;
     bcfg_scan_in               : in  std_ulogic;
     bcfg_scan_out              : out std_ulogic;
     dcfg_scan_in               : in  std_ulogic;
     dcfg_scan_out              : out std_ulogic;
     scan_in                    : in  std_ulogic;
     scan_out                   : out std_ulogic
);

-- synopsys translate_off


-- synopsys translate_on

end iuq_spr;
architecture iuq_spr of iuq_spr is



constant ll_trig_rnd_offset             : natural := 0;
constant ll_trig_cnt_offset             : natural := ll_trig_rnd_offset + 14;
constant ll_hold_cnt_offset             : natural := ll_trig_cnt_offset + 18;
constant xu_iu_run_thread_offset        : natural := ll_hold_cnt_offset + 10;
constant xu_iu_ex6_pri_offset           : natural := xu_iu_run_thread_offset + 4;
constant xu_iu_ex6_pri_val_offset       : natural := xu_iu_ex6_pri_offset + 3;
constant xu_iu_raise_iss_pri_offset     : natural := xu_iu_ex6_pri_val_offset + 4;
constant xu_iu_msr_gs_offset            : natural := xu_iu_raise_iss_pri_offset + 4;
constant xu_iu_msr_pr_offset            : natural := xu_iu_msr_gs_offset + 4;
constant slowspr_val_offset             : natural := xu_iu_msr_pr_offset + 4;
constant slowspr_rw_offset              : natural := slowspr_val_offset + 1;
constant slowspr_etid_offset            : natural := slowspr_rw_offset + 1;
constant slowspr_addr_offset            : natural := slowspr_etid_offset + 2;
constant slowspr_data_offset            : natural := slowspr_addr_offset + 10;
constant slowspr_done_offset            : natural := slowspr_data_offset + 2**regmode;
constant iu_slowspr_val_offset          : natural := slowspr_done_offset + 1;
constant iu_slowspr_rw_offset           : natural := iu_slowspr_val_offset + 1;
constant iu_slowspr_etid_offset         : natural := iu_slowspr_rw_offset + 1;
constant iu_slowspr_addr_offset         : natural := iu_slowspr_etid_offset + 2;
constant iu_slowspr_data_offset         : natural := iu_slowspr_addr_offset + 10;
constant iu_slowspr_done_offset         : natural := iu_slowspr_data_offset + 2**regmode;
constant immr0_offset                   : natural := iu_slowspr_done_offset + 1;
constant imr0_offset                    : natural := immr0_offset + 32;
constant iulfsr_offset                  : natural := imr0_offset + 32;
constant iudbg0_offset                  : natural := iulfsr_offset + 32;
constant iudbg1_offset                  : natural := iudbg0_offset + 8;
constant iudbg2_offset                  : natural := iudbg1_offset + 11;
constant iudbg0_exec_offset             : natural := iudbg2_offset + 30;
constant iudbg0_done_offset             : natural := iudbg0_exec_offset + 1;
constant spare_offset                   : natural := iudbg0_done_offset + 1;
constant scan_right                     : natural := spare_offset + 4 - 1;

constant iullcr_offset                  : natural := 0;
constant iucr0_offset                   : natural := iullcr_offset + 18;
constant iucr1_t0_offset                : natural := iucr0_offset + 16;
constant iucr1_t1_offset                : natural := iucr1_t0_offset + 14;
constant iucr1_t2_offset                : natural := iucr1_t1_offset + 14;
constant iucr1_t3_offset                : natural := iucr1_t2_offset + 14;
constant iucr2_t0_offset                : natural := iucr1_t3_offset + 14;
constant iucr2_t1_offset                : natural := iucr2_t0_offset + 8;
constant iucr2_t2_offset                : natural := iucr2_t1_offset + 8;
constant iucr2_t3_offset                : natural := iucr2_t2_offset + 8;
constant ppr32_t0_offset                : natural := iucr2_t3_offset + 8;
constant ppr32_t1_offset                : natural := ppr32_t0_offset + 3;
constant ppr32_t2_offset                : natural := ppr32_t1_offset + 3;
constant ppr32_t3_offset                : natural := ppr32_t2_offset + 3;
constant ccfg_spare_offset              : natural := ppr32_t3_offset + 3;
constant ccfg_scan_right                : natural := ccfg_spare_offset + 8 - 1;



constant IMMR0_MASK                     : std_ulogic_vector(32 to 63) := "11111111111111111111111111111111";
constant IMR0_MASK                      : std_ulogic_vector(32 to 63) := "11111111111111111111111111111111";
constant IULFSR_MASK                    : std_ulogic_vector(32 to 63) := "11111111111111111111111111111111";
constant IUDBG0_MASK                    : std_ulogic_vector(32 to 63) := "00000000000000000011111111000011";
constant IUDBG1_MASK                    : std_ulogic_vector(32 to 63) := "00000000000000000000011111111001";
constant IUDBG2_MASK                    : std_ulogic_vector(32 to 63) := "00111111111111111111111111111111";
constant IULLCR_MASK                    : std_ulogic_vector(32 to 63) := "00000000000000111100001111110001";
constant IUCR0_MASK                     : std_ulogic_vector(32 to 63) := "00000000000000001111111111111111";
constant IUCR1_MASK                     : std_ulogic_vector(32 to 63) := "00000000000000000011000000111111";
constant IUCR2_MASK                     : std_ulogic_vector(32 to 63) := "11111111000000000000000000000000";
constant PPR32_MASK                     : std_ulogic_vector(32 to 63) := "00000000000111000000000000000000";


signal spare_l2                 : std_ulogic_vector(0 to 3);
signal ccfg_spare_l2            : std_ulogic_vector(0 to 7);

signal xu_iu_run_thread_d       : std_ulogic_vector(0 to 3);
signal xu_iu_run_thread_l2      : std_ulogic_vector(0 to 3);
signal xu_iu_ex6_pri_d          : std_ulogic_vector(0 to 2);
signal xu_iu_ex6_pri_l2         : std_ulogic_vector(0 to 2);
signal xu_iu_ex6_pri_val_d      : std_ulogic_vector(0 to 3);
signal xu_iu_ex6_pri_val_l2     : std_ulogic_vector(0 to 3);
signal xu_iu_raise_iss_pri_d    : std_ulogic_vector(0 to 3);
signal xu_iu_raise_iss_pri_l2   : std_ulogic_vector(0 to 3);
signal xu_iu_msr_gs_d           : std_ulogic_vector(0 to 3);
signal xu_iu_msr_gs_l2          : std_ulogic_vector(0 to 3);
signal xu_iu_msr_pr_d           : std_ulogic_vector(0 to 3);
signal xu_iu_msr_pr_l2          : std_ulogic_vector(0 to 3);

signal slowspr_val_d    : std_ulogic;
signal slowspr_val_l2   : std_ulogic;
signal slowspr_rw_d     : std_ulogic;
signal slowspr_rw_l2    : std_ulogic;
signal slowspr_etid_d   : std_ulogic_vector(0 to 1);
signal slowspr_etid_l2  : std_ulogic_vector(0 to 1);
signal slowspr_addr_d   : std_ulogic_vector(0 to 9);
signal slowspr_addr_l2  : std_ulogic_vector(0 to 9);
signal slowspr_data_d   : std_ulogic_vector(64-(2**regmode) to 63);
signal slowspr_data_l2  : std_ulogic_vector(64-(2**regmode) to 63);
signal slowspr_done_d   : std_ulogic;
signal slowspr_done_l2  : std_ulogic;

signal iu_slowspr_val_d    : std_ulogic;
signal iu_slowspr_val_l2   : std_ulogic;
signal iu_slowspr_rw_d     : std_ulogic;
signal iu_slowspr_rw_l2    : std_ulogic;
signal iu_slowspr_etid_d   : std_ulogic_vector(0 to 1);
signal iu_slowspr_etid_l2  : std_ulogic_vector(0 to 1);
signal iu_slowspr_addr_d   : std_ulogic_vector(0 to 9);
signal iu_slowspr_addr_l2  : std_ulogic_vector(0 to 9);
signal iu_slowspr_data_d   : std_ulogic_vector(64-(2**regmode) to 63);
signal iu_slowspr_data_l2  : std_ulogic_vector(64-(2**regmode) to 63);
signal iu_slowspr_done_d   : std_ulogic;
signal iu_slowspr_done_l2  : std_ulogic;

signal iu_slowspr_done  : std_ulogic;
signal iu_slowspr_data  : std_ulogic_vector(64-(2**regmode) to 63);

signal immr0_sel        : std_ulogic;
signal immr0_wren       : std_ulogic;
signal immr0_rden       : std_ulogic;
signal immr0_d          : std_ulogic_vector(32 to 63);
signal immr0_l2         : std_ulogic_vector(32 to 63);

signal imr0_sel         : std_ulogic;
signal imr0_wren        : std_ulogic;
signal imr0_rden        : std_ulogic;
signal imr0_d           : std_ulogic_vector(32 to 63);
signal imr0_l2          : std_ulogic_vector(32 to 63);

signal iulfsr_sel       : std_ulogic;
signal iulfsr_wren      : std_ulogic;
signal iulfsr_rden      : std_ulogic;
signal iulfsr_d         : std_ulogic_vector(32 to 63);
signal iulfsr_l2        : std_ulogic_vector(32 to 63);
signal iulfsr           : std_ulogic_vector(1 to 28);
signal iulfsr_act       : std_ulogic;

signal iudbg0_sel        : std_ulogic;
signal iudbg0_wren       : std_ulogic;
signal iudbg0_rden       : std_ulogic;
signal iudbg0_d          : std_ulogic_vector(50 to 57);
signal iudbg0_l2         : std_ulogic_vector(50 to 57);
signal iudbg0            : std_ulogic_vector(32 to 63);

signal iudbg0_exec_wren  : std_ulogic;
signal iudbg0_exec_d     : std_ulogic;
signal iudbg0_exec_l2    : std_ulogic;
signal iudbg0_done_wren  : std_ulogic;
signal iudbg0_done_d     : std_ulogic;
signal iudbg0_done_l2    : std_ulogic;

signal iudbg1_sel        : std_ulogic;
signal iudbg1_wren       : std_ulogic;
signal iudbg1_rden       : std_ulogic;
signal iudbg1_d          : std_ulogic_vector(53 to 63);
signal iudbg1_l2         : std_ulogic_vector(53 to 63);
signal iudbg1            : std_ulogic_vector(32 to 63);

signal iudbg2_sel        : std_ulogic;
signal iudbg2_wren       : std_ulogic;
signal iudbg2_rden       : std_ulogic;
signal iudbg2_d          : std_ulogic_vector(34 to 63);
signal iudbg2_l2         : std_ulogic_vector(34 to 63);
signal iudbg2            : std_ulogic_vector(32 to 63);

signal iullcr_sel        : std_ulogic;
signal iullcr_wren       : std_ulogic;
signal iullcr_rden       : std_ulogic;
signal iullcr_d          : std_ulogic_vector(46 to 63);
signal iullcr_l2         : std_ulogic_vector(46 to 63);
signal iullcr            : std_ulogic_vector(32 to 63);

signal iucr0_sel        : std_ulogic;
signal iucr0_wren       : std_ulogic;
signal iucr0_rden       : std_ulogic;
signal iucr0_d          : std_ulogic_vector(48 to 63);
signal iucr0_l2         : std_ulogic_vector(48 to 63);
signal iucr0            : std_ulogic_vector(32 to 63);

signal iucr1_t0_sel     : std_ulogic;
signal iucr1_t0_wren    : std_ulogic;
signal iucr1_t0_rden    : std_ulogic;
signal iucr1_t0_d       : std_ulogic_vector(50 to 63);
signal iucr1_t0_l2      : std_ulogic_vector(50 to 63);
signal iucr1_t0         : std_ulogic_vector(32 to 63);

signal iucr1_t1_sel     : std_ulogic;
signal iucr1_t1_wren    : std_ulogic;
signal iucr1_t1_rden    : std_ulogic;
signal iucr1_t1_d       : std_ulogic_vector(50 to 63);
signal iucr1_t1_l2      : std_ulogic_vector(50 to 63);
signal iucr1_t1         : std_ulogic_vector(32 to 63);

signal iucr1_t2_sel     : std_ulogic;
signal iucr1_t2_wren    : std_ulogic;
signal iucr1_t2_rden    : std_ulogic;
signal iucr1_t2_d       : std_ulogic_vector(50 to 63);
signal iucr1_t2_l2      : std_ulogic_vector(50 to 63);
signal iucr1_t2         : std_ulogic_vector(32 to 63);

signal iucr1_t3_sel     : std_ulogic;
signal iucr1_t3_wren    : std_ulogic;
signal iucr1_t3_rden    : std_ulogic;
signal iucr1_t3_d       : std_ulogic_vector(50 to 63);
signal iucr1_t3_l2      : std_ulogic_vector(50 to 63);
signal iucr1_t3         : std_ulogic_vector(32 to 63);

signal iucr2_t0_sel     : std_ulogic;
signal iucr2_t0_wren    : std_ulogic;
signal iucr2_t0_rden    : std_ulogic;
signal iucr2_t0_d       : std_ulogic_vector(32 to 39);
signal iucr2_t0_l2      : std_ulogic_vector(32 to 39);
signal iucr2_t0         : std_ulogic_vector(32 to 63);

signal iucr2_t1_sel     : std_ulogic;
signal iucr2_t1_wren    : std_ulogic;
signal iucr2_t1_rden    : std_ulogic;
signal iucr2_t1_d       : std_ulogic_vector(32 to 39);
signal iucr2_t1_l2      : std_ulogic_vector(32 to 39);
signal iucr2_t1         : std_ulogic_vector(32 to 63);

signal iucr2_t2_sel     : std_ulogic;
signal iucr2_t2_wren    : std_ulogic;
signal iucr2_t2_rden    : std_ulogic;
signal iucr2_t2_d       : std_ulogic_vector(32 to 39);
signal iucr2_t2_l2      : std_ulogic_vector(32 to 39);
signal iucr2_t2         : std_ulogic_vector(32 to 63);

signal iucr2_t3_sel     : std_ulogic;
signal iucr2_t3_wren    : std_ulogic;
signal iucr2_t3_rden    : std_ulogic;
signal iucr2_t3_d       : std_ulogic_vector(32 to 39);
signal iucr2_t3_l2      : std_ulogic_vector(32 to 39);
signal iucr2_t3         : std_ulogic_vector(32 to 63);

signal ppr32_t0_sel     : std_ulogic;
signal ppr32_t0_wren    : std_ulogic;
signal ppr32_t0_rden    : std_ulogic;
signal ppr32_t0_d       : std_ulogic_vector(43 to 45);
signal ppr32_t0_l2      : std_ulogic_vector(43 to 45);
signal ppr32_t0         : std_ulogic_vector(32 to 63);

signal ppr32_t1_sel     : std_ulogic;
signal ppr32_t1_wren    : std_ulogic;
signal ppr32_t1_rden    : std_ulogic;
signal ppr32_t1_d       : std_ulogic_vector(43 to 45);
signal ppr32_t1_l2      : std_ulogic_vector(43 to 45);
signal ppr32_t1         : std_ulogic_vector(32 to 63);

signal ppr32_t2_sel     : std_ulogic;
signal ppr32_t2_wren    : std_ulogic;
signal ppr32_t2_rden    : std_ulogic;
signal ppr32_t2_d       : std_ulogic_vector(43 to 45);
signal ppr32_t2_l2      : std_ulogic_vector(43 to 45);
signal ppr32_t2         : std_ulogic_vector(32 to 63);

signal ppr32_t3_sel     : std_ulogic;
signal ppr32_t3_wren    : std_ulogic;
signal ppr32_t3_rden    : std_ulogic;
signal ppr32_t3_d       : std_ulogic_vector(43 to 45);
signal ppr32_t3_l2      : std_ulogic_vector(43 to 45);
signal ppr32_t3         : std_ulogic_vector(32 to 63);





signal lo_pri           : std_ulogic_vector(0 to 3);
signal hi_pri           : std_ulogic_vector(0 to 3);


signal priv_mode        : std_ulogic_vector(0 to 3);
signal hypv_mode        : std_ulogic_vector(0 to 3);

 
signal hi_pri_level_t0  : std_ulogic_vector(0 to 1);
signal hi_pri_level_t1  : std_ulogic_vector(0 to 1);
signal hi_pri_level_t2  : std_ulogic_vector(0 to 1);
signal hi_pri_level_t3  : std_ulogic_vector(0 to 1);


signal iull_en          : std_ulogic;
signal ll_trig_dly      : std_ulogic_vector(0 to 17);
signal ll_hold_dly      : std_ulogic_vector(0 to 9);

signal ll_trig_rnd_act  : std_ulogic;
signal ll_trig_rnd_d    : std_ulogic_vector(4 to 17);
signal ll_trig_rnd_l2   : std_ulogic_vector(4 to 17);

signal ll_trig_cnt_act  : std_ulogic;
signal ll_trig_cnt_d    : std_ulogic_vector(0 to 17);
signal ll_trig_cnt_l2   : std_ulogic_vector(0 to 17);

signal ll_hold_cnt_act  : std_ulogic;
signal ll_hold_cnt_d    : std_ulogic_vector(0 to 9);
signal ll_hold_cnt_l2   : std_ulogic_vector(0 to 9);

signal ll_rand          : std_ulogic;
signal ll_trig          : std_ulogic;
signal ll_hold          : std_ulogic;


signal tiup                     : std_ulogic;

signal pc_iu_cfg_sl_thold_1     : std_ulogic;
signal pc_iu_cfg_sl_thold_0     : std_ulogic;
signal pc_iu_cfg_sl_thold_0_b   : std_ulogic;
signal pc_iu_func_sl_thold_1    : std_ulogic;
signal pc_iu_func_sl_thold_0    : std_ulogic;
signal pc_iu_func_sl_thold_0_b  : std_ulogic;
signal pc_iu_sg_1               : std_ulogic;
signal pc_iu_sg_0               : std_ulogic;
signal forcee                   : std_ulogic;
signal cfg_force                : std_ulogic;
signal dclk                     : std_ulogic;
signal lclk                     : clk_logic;

signal siv                      : std_ulogic_vector(0 to scan_right);
signal sov                      : std_ulogic_vector(0 to scan_right);

signal ccfg_siv                 : std_ulogic_vector(0 to ccfg_scan_right);
signal ccfg_sov                 : std_ulogic_vector(0 to ccfg_scan_right);

begin


tiup    <= '1';



ll_trig_rnd_reg: tri_rlmreg_p
  generic map (width => ll_trig_rnd_l2'length, init => 0, expand_type => expand_type) 
  port map (vd      => vdd,
            gd      => gnd,
            nclk        => nclk,
            act         => ll_trig_rnd_act,
            thold_b     => pc_iu_func_sl_thold_0_b,
            sg          => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin        => siv(ll_trig_rnd_offset to ll_trig_rnd_offset + ll_trig_rnd_l2'length-1),
            scout       => sov(ll_trig_rnd_offset to ll_trig_rnd_offset + ll_trig_rnd_l2'length-1),
            din         => ll_trig_rnd_d,
            dout        => ll_trig_rnd_l2);

ll_trig_cnt_reg: tri_rlmreg_p
  generic map (width => ll_trig_cnt_l2'length, init => 0, expand_type => expand_type) 
  port map (vd      => vdd,
            gd      => gnd,
            nclk        => nclk,
            act         => ll_trig_cnt_act,
            thold_b     => pc_iu_func_sl_thold_0_b,
            sg          => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin        => siv(ll_trig_cnt_offset to ll_trig_cnt_offset + ll_trig_cnt_l2'length-1),
            scout       => sov(ll_trig_cnt_offset to ll_trig_cnt_offset + ll_trig_cnt_l2'length-1),
            din         => ll_trig_cnt_d,
            dout        => ll_trig_cnt_l2);

ll_hold_cnt_reg: tri_rlmreg_p
  generic map (width => ll_hold_cnt_l2'length, init => 0, expand_type => expand_type) 
  port map (vd      => vdd,
            gd      => gnd,
            nclk        => nclk,
            act         => ll_hold_cnt_act,
            thold_b     => pc_iu_func_sl_thold_0_b,
            sg          => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin        => siv(ll_hold_cnt_offset to ll_hold_cnt_offset + ll_hold_cnt_l2'length-1),
            scout       => sov(ll_hold_cnt_offset to ll_hold_cnt_offset + ll_hold_cnt_l2'length-1),
            din         => ll_hold_cnt_d,
            dout        => ll_hold_cnt_l2);

xu_iu_run_thread_reg: tri_rlmreg_p
  generic map (width => xu_iu_run_thread_l2'length, init => 0, expand_type => expand_type) 
  port map (vd      => vdd,
            gd      => gnd,
            nclk        => nclk,
            act         => tiup,
            thold_b     => pc_iu_func_sl_thold_0_b,
            sg          => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin        => siv(xu_iu_run_thread_offset to xu_iu_run_thread_offset + xu_iu_run_thread_l2'length-1),
            scout       => sov(xu_iu_run_thread_offset to xu_iu_run_thread_offset + xu_iu_run_thread_l2'length-1),
            din         => xu_iu_run_thread_d,
            dout        => xu_iu_run_thread_l2);

xu_iu_ex6_pri_reg: tri_rlmreg_p
  generic map (width => xu_iu_ex6_pri_l2'length, init => 0, expand_type => expand_type) 
  port map (vd      => vdd,
            gd      => gnd,
            nclk        => nclk,
            act         => tiup,
            thold_b     => pc_iu_func_sl_thold_0_b,
            sg          => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin        => siv(xu_iu_ex6_pri_offset to xu_iu_ex6_pri_offset + xu_iu_ex6_pri_l2'length-1),
            scout       => sov(xu_iu_ex6_pri_offset to xu_iu_ex6_pri_offset + xu_iu_ex6_pri_l2'length-1),
            din         => xu_iu_ex6_pri_d,
            dout        => xu_iu_ex6_pri_l2);

xu_iu_ex6_pri_val_reg: tri_rlmreg_p
  generic map (width => xu_iu_ex6_pri_val_l2'length, init => 0, expand_type => expand_type) 
  port map (vd      => vdd,
            gd      => gnd,
            nclk        => nclk,
            act         => tiup,
            thold_b     => pc_iu_func_sl_thold_0_b,
            sg          => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin        => siv(xu_iu_ex6_pri_val_offset to xu_iu_ex6_pri_val_offset + xu_iu_ex6_pri_val_l2'length-1),
            scout       => sov(xu_iu_ex6_pri_val_offset to xu_iu_ex6_pri_val_offset + xu_iu_ex6_pri_val_l2'length-1),
            din         => xu_iu_ex6_pri_val_d,
            dout        => xu_iu_ex6_pri_val_l2);

xu_iu_raise_iss_pri_reg: tri_rlmreg_p
  generic map (width => xu_iu_raise_iss_pri_l2'length, init => 0, expand_type => expand_type) 
  port map (vd      => vdd,
            gd      => gnd,
            nclk        => nclk,
            act         => tiup,
            thold_b     => pc_iu_func_sl_thold_0_b,
            sg          => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin        => siv(xu_iu_raise_iss_pri_offset to xu_iu_raise_iss_pri_offset + xu_iu_raise_iss_pri_l2'length-1),
            scout       => sov(xu_iu_raise_iss_pri_offset to xu_iu_raise_iss_pri_offset + xu_iu_raise_iss_pri_l2'length-1),
            din         => xu_iu_raise_iss_pri_d,
            dout        => xu_iu_raise_iss_pri_l2);

xu_iu_msr_gs_reg: tri_rlmreg_p
  generic map (width => xu_iu_msr_gs_l2'length, init => 0, expand_type => expand_type) 
  port map (vd      => vdd,
            gd      => gnd,
            nclk        => nclk,
            act         => tiup,
            thold_b     => pc_iu_func_sl_thold_0_b,
            sg          => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin        => siv(xu_iu_msr_gs_offset to xu_iu_msr_gs_offset + xu_iu_msr_gs_l2'length-1),
            scout       => sov(xu_iu_msr_gs_offset to xu_iu_msr_gs_offset + xu_iu_msr_gs_l2'length-1),
            din         => xu_iu_msr_gs_d,
            dout        => xu_iu_msr_gs_l2);

xu_iu_msr_pr_reg: tri_rlmreg_p
  generic map (width => xu_iu_msr_pr_l2'length, init => 0, expand_type => expand_type) 
  port map (vd      => vdd,
            gd      => gnd,
            nclk        => nclk,
            act         => tiup,
            thold_b     => pc_iu_func_sl_thold_0_b,
            sg          => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin        => siv(xu_iu_msr_pr_offset to xu_iu_msr_pr_offset + xu_iu_msr_pr_l2'length-1),
            scout       => sov(xu_iu_msr_pr_offset to xu_iu_msr_pr_offset + xu_iu_msr_pr_l2'length-1),
            din         => xu_iu_msr_pr_d,
            dout        => xu_iu_msr_pr_l2);  

slowspr_val_reg: tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk        => nclk,
            act         => tiup,
            thold_b     => pc_iu_func_sl_thold_0_b,
            sg          => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin        => siv(slowspr_val_offset),
            scout       => sov(slowspr_val_offset),
            din         => slowspr_val_d,
            dout        => slowspr_val_l2);

slowspr_rw_reg: tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk        => nclk,
            act         => tiup,
            thold_b     => pc_iu_func_sl_thold_0_b,
            sg          => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin        => siv(slowspr_rw_offset),
            scout       => sov(slowspr_rw_offset),
            din         => slowspr_rw_d,
            dout        => slowspr_rw_l2);

slowspr_etid_reg: tri_rlmreg_p
  generic map (width => slowspr_etid_l2'length, init => 0, expand_type => expand_type) 
  port map (vd      => vdd,
            gd      => gnd,
            nclk        => nclk,
            act         => tiup,
            thold_b     => pc_iu_func_sl_thold_0_b,
            sg          => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin        => siv(slowspr_etid_offset to slowspr_etid_offset + slowspr_etid_l2'length-1),
            scout       => sov(slowspr_etid_offset to slowspr_etid_offset + slowspr_etid_l2'length-1),
            din         => slowspr_etid_d,
            dout        => slowspr_etid_l2);

slowspr_addr_reg: tri_rlmreg_p
  generic map (width => slowspr_addr_l2'length, init => 0, expand_type => expand_type) 
  port map (vd      => vdd,
            gd      => gnd,
            nclk        => nclk,
            act         => tiup,
            thold_b     => pc_iu_func_sl_thold_0_b,
            sg          => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin        => siv(slowspr_addr_offset to slowspr_addr_offset + slowspr_addr_l2'length-1),
            scout       => sov(slowspr_addr_offset to slowspr_addr_offset + slowspr_addr_l2'length-1),
            din         => slowspr_addr_d,
            dout        => slowspr_addr_l2);

slowspr_data_reg: tri_rlmreg_p
  generic map (width => slowspr_data_l2'length, init => 0, expand_type => expand_type) 
  port map (vd      => vdd,
            gd      => gnd,
            nclk        => nclk,
            act         => tiup,
            thold_b     => pc_iu_func_sl_thold_0_b,
            sg          => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin        => siv(slowspr_data_offset to slowspr_data_offset + slowspr_data_l2'length-1),
            scout       => sov(slowspr_data_offset to slowspr_data_offset + slowspr_data_l2'length-1),
            din         => slowspr_data_d,
            dout        => slowspr_data_l2);

slowspr_done_reg: tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk        => nclk,
            act         => tiup,
            thold_b     => pc_iu_func_sl_thold_0_b,
            sg          => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin        => siv(slowspr_done_offset),
            scout       => sov(slowspr_done_offset),
            din         => slowspr_done_d,
            dout        => slowspr_done_l2);

iu_slowspr_val_reg: tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk        => nclk,
            act         => tiup,
            thold_b     => pc_iu_func_sl_thold_0_b,
            sg          => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin        => siv(iu_slowspr_val_offset),
            scout       => sov(iu_slowspr_val_offset),
            din         => iu_slowspr_val_d,
            dout        => iu_slowspr_val_l2);

iu_slowspr_rw_reg: tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk        => nclk,
            act         => iu_slowspr_val_d,
            thold_b     => pc_iu_func_sl_thold_0_b,
            sg          => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin        => siv(iu_slowspr_rw_offset),
            scout       => sov(iu_slowspr_rw_offset),
            din         => iu_slowspr_rw_d,
            dout        => iu_slowspr_rw_l2);

iu_slowspr_etid_reg: tri_rlmreg_p
  generic map (width => iu_slowspr_etid_l2'length, init => 0, expand_type => expand_type) 
  port map (vd      => vdd,
            gd      => gnd,
            nclk        => nclk,
            act         => iu_slowspr_val_d,
            thold_b     => pc_iu_func_sl_thold_0_b,
            sg          => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin        => siv(iu_slowspr_etid_offset to iu_slowspr_etid_offset + iu_slowspr_etid_l2'length-1),
            scout       => sov(iu_slowspr_etid_offset to iu_slowspr_etid_offset + iu_slowspr_etid_l2'length-1),
            din         => iu_slowspr_etid_d,
            dout        => iu_slowspr_etid_l2);

iu_slowspr_addr_reg: tri_rlmreg_p
  generic map (width => iu_slowspr_addr_l2'length, init => 0, expand_type => expand_type) 
  port map (vd      => vdd,
            gd      => gnd,
            nclk        => nclk,
            act         => iu_slowspr_val_d,
            thold_b     => pc_iu_func_sl_thold_0_b,
            sg          => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin        => siv(iu_slowspr_addr_offset to iu_slowspr_addr_offset + iu_slowspr_addr_l2'length-1),
            scout       => sov(iu_slowspr_addr_offset to iu_slowspr_addr_offset + iu_slowspr_addr_l2'length-1),
            din         => iu_slowspr_addr_d,
            dout        => iu_slowspr_addr_l2);

iu_slowspr_data_reg: tri_rlmreg_p
  generic map (width => iu_slowspr_data_l2'length, init => 0, expand_type => expand_type) 
  port map (vd      => vdd,
            gd      => gnd,
            nclk        => nclk,
            act         => iu_slowspr_val_d,
            thold_b     => pc_iu_func_sl_thold_0_b,
            sg          => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin        => siv(iu_slowspr_data_offset to iu_slowspr_data_offset + iu_slowspr_data_l2'length-1),
            scout       => sov(iu_slowspr_data_offset to iu_slowspr_data_offset + iu_slowspr_data_l2'length-1),
            din         => iu_slowspr_data_d,
            dout        => iu_slowspr_data_l2);

iu_slowspr_done_reg: tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk        => nclk,
            act         => iu_slowspr_val_d,
            thold_b     => pc_iu_func_sl_thold_0_b,
            sg          => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin        => siv(iu_slowspr_done_offset),
            scout       => sov(iu_slowspr_done_offset),
            din         => iu_slowspr_done_d,
            dout        => iu_slowspr_done_l2);

immr0a_reg: tri_ser_rlmreg_p
  generic map (width => 16, init => 65535, expand_type => expand_type) 
  port map (vd      => vdd,
            gd      => gnd,
            nclk        => nclk,
            act         => immr0_wren,
            thold_b     => pc_iu_func_sl_thold_0_b,
            sg          => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin        => siv(immr0_offset to immr0_offset + 16-1),
            scout       => sov(immr0_offset to immr0_offset + 16-1),
            din         => immr0_d(32 to 47),
            dout        => immr0_l2(32 to 47));

immr0b_reg: tri_ser_rlmreg_p
  generic map (width => 16, init => 65535, expand_type => expand_type) 
  port map (vd      => vdd,
            gd      => gnd,
            nclk        => nclk,
            act         => immr0_wren,
            thold_b     => pc_iu_func_sl_thold_0_b,
            sg          => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin        => siv(immr0_offset + 16 to immr0_offset + immr0_l2'length-1),
            scout       => sov(immr0_offset + 16 to immr0_offset + immr0_l2'length-1),
            din         => immr0_d(48 to 63),
            dout        => immr0_l2(48 to 63));

imr0_reg: tri_ser_rlmreg_p
  generic map (width => imr0_l2'length, init => 0, expand_type => expand_type) 
  port map (vd      => vdd,
            gd      => gnd,
            nclk        => nclk,
            act         => imr0_wren,
            thold_b     => pc_iu_func_sl_thold_0_b,
            sg          => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin        => siv(imr0_offset to imr0_offset + imr0_l2'length-1),
            scout       => sov(imr0_offset to imr0_offset + imr0_l2'length-1),
            din         => imr0_d,
            dout        => imr0_l2);

iulfsr_reg: tri_ser_rlmreg_p
  generic map (width => iulfsr_l2'length, init => 26, expand_type => expand_type) 
  port map (vd      => vdd,
            gd      => gnd,
            nclk        => nclk,
            act         => iulfsr_act,
            thold_b     => pc_iu_func_sl_thold_0_b,
            sg          => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin        => siv(iulfsr_offset to iulfsr_offset + iulfsr_l2'length-1),
            scout       => sov(iulfsr_offset to iulfsr_offset + iulfsr_l2'length-1),
            din         => iulfsr_d,
            dout        => iulfsr_l2);

iudbg0_reg: tri_ser_rlmreg_p
  generic map (width => iudbg0_l2'length, init => 0, expand_type => expand_type) 
  port map (vd      => vdd,
            gd      => gnd,
            nclk        => nclk,
            act         => iudbg0_wren,
            thold_b     => pc_iu_func_sl_thold_0_b,
            sg          => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin        => siv(iudbg0_offset to iudbg0_offset + iudbg0_l2'length-1),
            scout       => sov(iudbg0_offset to iudbg0_offset + iudbg0_l2'length-1),
            din         => iudbg0_d,
            dout        => iudbg0_l2);

iudbg0_done_reg: tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk        => nclk,
            act         => iudbg0_done_wren,
            thold_b     => pc_iu_func_sl_thold_0_b,
            sg          => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin        => siv(iudbg0_done_offset),
            scout       => sov(iudbg0_done_offset),
            din         => iudbg0_done_d,
            dout        => iudbg0_done_l2);

iudbg0_exec_reg: tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk        => nclk,
            act         => iudbg0_exec_wren,
            thold_b     => pc_iu_func_sl_thold_0_b,
            sg          => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin        => siv(iudbg0_exec_offset),
            scout       => sov(iudbg0_exec_offset),
            din         => iudbg0_exec_d,
            dout        => iudbg0_exec_l2);

iudbg1_reg: tri_ser_rlmreg_p
  generic map (width => iudbg1_l2'length, init => 0, expand_type => expand_type) 
  port map (vd      => vdd,
            gd      => gnd,
            nclk        => nclk,
            act         => iudbg1_wren,
            thold_b     => pc_iu_func_sl_thold_0_b,
            sg          => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin        => siv(iudbg1_offset to iudbg1_offset + iudbg1_l2'length-1),
            scout       => sov(iudbg1_offset to iudbg1_offset + iudbg1_l2'length-1),
            din         => iudbg1_d,
            dout        => iudbg1_l2);

iudbg2_reg: tri_ser_rlmreg_p
  generic map (width => iudbg2_l2'length, init => 0, expand_type => expand_type) 
  port map (vd      => vdd,
            gd      => gnd,
            nclk        => nclk,
            act         => iudbg2_wren,
            thold_b     => pc_iu_func_sl_thold_0_b,
            sg          => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin        => siv(iudbg2_offset to iudbg2_offset + iudbg2_l2'length-1),
            scout       => sov(iudbg2_offset to iudbg2_offset + iudbg2_l2'length-1),
            din         => iudbg2_d,
            dout        => iudbg2_l2);

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


iullcr_reg: tri_ser_rlmreg_p 
  generic map (width => iullcr_l2'length, init => 131136, expand_type => expand_type) 
  port map (vd      => vdd,
            gd      => gnd,
            nclk        => nclk,
            act         => iullcr_wren,
            thold_b     => pc_iu_cfg_sl_thold_0_b,
            sg          => pc_iu_sg_0,
            forcee => cfg_force,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin        => ccfg_siv(iullcr_offset to iullcr_offset + iullcr_l2'length-1),
            scout       => ccfg_sov(iullcr_offset to iullcr_offset + iullcr_l2'length-1),
            din         => iullcr_d,
            dout        => iullcr_l2);

iucr0_reg: tri_ser_rlmreg_p 
  generic map (width => iucr0_l2'length, init => 4346, expand_type => expand_type) 
  port map (vd      => vdd,
            gd      => gnd,
            nclk        => nclk,
            act         => iucr0_wren,
            thold_b     => pc_iu_cfg_sl_thold_0_b,
            sg          => pc_iu_sg_0,
            forcee => cfg_force,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin        => ccfg_siv(iucr0_offset to iucr0_offset + iucr0_l2'length-1),
            scout       => ccfg_sov(iucr0_offset to iucr0_offset + iucr0_l2'length-1),
            din         => iucr0_d,
            dout        => iucr0_l2);

iucr1_t0_reg: tri_ser_rlmreg_p 
  generic map (width => iucr1_t0_l2'length, init => 4096, expand_type => expand_type) 
  port map (vd      => vdd,
            gd      => gnd,
            nclk        => nclk,
            act         => iucr1_t0_wren,
            thold_b     => pc_iu_cfg_sl_thold_0_b,
            sg          => pc_iu_sg_0,
            forcee => cfg_force,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin        => ccfg_siv(iucr1_t0_offset to iucr1_t0_offset + iucr1_t0_l2'length-1),
            scout       => ccfg_sov(iucr1_t0_offset to iucr1_t0_offset + iucr1_t0_l2'length-1),
            din         => iucr1_t0_d,
            dout        => iucr1_t0_l2);

iucr1_t1_reg: tri_ser_rlmreg_p 
  generic map (width => iucr1_t1_l2'length, init => 4096, expand_type => expand_type) 
  port map (vd      => vdd,
            gd      => gnd,
            nclk        => nclk,
            act         => iucr1_t1_wren,
            thold_b     => pc_iu_cfg_sl_thold_0_b,
            sg          => pc_iu_sg_0,
            forcee => cfg_force,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin        => ccfg_siv(iucr1_t1_offset to iucr1_t1_offset + iucr1_t1_l2'length-1),
            scout       => ccfg_sov(iucr1_t1_offset to iucr1_t1_offset + iucr1_t1_l2'length-1),
            din         => iucr1_t1_d,
            dout        => iucr1_t1_l2);

iucr1_t2_reg: tri_ser_rlmreg_p 
  generic map (width => iucr1_t2_l2'length, init => 4096, expand_type => expand_type) 
  port map (vd      => vdd,
            gd      => gnd,
            nclk        => nclk,
            act         => iucr1_t2_wren,
            thold_b     => pc_iu_cfg_sl_thold_0_b,
            sg          => pc_iu_sg_0,
            forcee => cfg_force,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin        => ccfg_siv(iucr1_t2_offset to iucr1_t2_offset + iucr1_t2_l2'length-1),
            scout       => ccfg_sov(iucr1_t2_offset to iucr1_t2_offset + iucr1_t2_l2'length-1),
            din         => iucr1_t2_d,
            dout        => iucr1_t2_l2);

iucr1_t3_reg: tri_ser_rlmreg_p 
  generic map (width => iucr1_t3_l2'length, init => 4096, expand_type => expand_type) 
  port map (vd      => vdd,
            gd      => gnd,
            nclk        => nclk,
            act         => iucr1_t3_wren,
            thold_b     => pc_iu_cfg_sl_thold_0_b,
            sg          => pc_iu_sg_0,
            forcee => cfg_force,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin        => ccfg_siv(iucr1_t3_offset to iucr1_t3_offset + iucr1_t3_l2'length-1),
            scout       => ccfg_sov(iucr1_t3_offset to iucr1_t3_offset + iucr1_t3_l2'length-1),
            din         => iucr1_t3_d,
            dout        => iucr1_t3_l2);

iucr2_t0_reg: tri_ser_rlmreg_p 
  generic map (width => iucr2_t0_l2'length, init => 0, expand_type => expand_type) 
  port map (vd      => vdd,
            gd      => gnd,
            nclk        => nclk,
            act         => iucr2_t0_wren,
            thold_b     => pc_iu_cfg_sl_thold_0_b,
            sg          => pc_iu_sg_0,
            forcee => cfg_force,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin        => ccfg_siv(iucr2_t0_offset to iucr2_t0_offset + iucr2_t0_l2'length-1),
            scout       => ccfg_sov(iucr2_t0_offset to iucr2_t0_offset + iucr2_t0_l2'length-1),
            din         => iucr2_t0_d,
            dout        => iucr2_t0_l2);

iucr2_t1_reg: tri_ser_rlmreg_p 
  generic map (width => iucr2_t1_l2'length, init => 0, expand_type => expand_type) 
  port map (vd      => vdd,
            gd      => gnd,
            nclk        => nclk,
            act         => iucr2_t1_wren,
            thold_b     => pc_iu_cfg_sl_thold_0_b,
            sg          => pc_iu_sg_0,
            forcee => cfg_force,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin        => ccfg_siv(iucr2_t1_offset to iucr2_t1_offset + iucr2_t1_l2'length-1),
            scout       => ccfg_sov(iucr2_t1_offset to iucr2_t1_offset + iucr2_t1_l2'length-1),
            din         => iucr2_t1_d,
            dout        => iucr2_t1_l2);

iucr2_t2_reg: tri_ser_rlmreg_p 
  generic map (width => iucr2_t2_l2'length, init => 0, expand_type => expand_type) 
  port map (vd      => vdd,
            gd      => gnd,
            nclk        => nclk,
            act         => iucr2_t2_wren,
            thold_b     => pc_iu_cfg_sl_thold_0_b,
            sg          => pc_iu_sg_0,
            forcee => cfg_force,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin        => ccfg_siv(iucr2_t2_offset to iucr2_t2_offset + iucr2_t2_l2'length-1),
            scout       => ccfg_sov(iucr2_t2_offset to iucr2_t2_offset + iucr2_t2_l2'length-1),
            din         => iucr2_t2_d,
            dout        => iucr2_t2_l2);

iucr2_t3_reg: tri_ser_rlmreg_p 
  generic map (width => iucr2_t3_l2'length, init => 0, expand_type => expand_type) 
  port map (vd      => vdd,
            gd      => gnd,
            nclk        => nclk,
            act         => iucr2_t3_wren,
            thold_b     => pc_iu_cfg_sl_thold_0_b,
            sg          => pc_iu_sg_0,
            forcee => cfg_force,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin        => ccfg_siv(iucr2_t3_offset to iucr2_t3_offset + iucr2_t3_l2'length-1),
            scout       => ccfg_sov(iucr2_t3_offset to iucr2_t3_offset + iucr2_t3_l2'length-1),
            din         => iucr2_t3_d,
            dout        => iucr2_t3_l2);

ppr32_t0_reg: tri_ser_rlmreg_p 
  generic map (width => ppr32_t0_l2'length, init => 3, expand_type => expand_type) 
  port map (vd      => vdd,
            gd      => gnd,
            nclk        => nclk,
            act         => ppr32_t0_wren,
            thold_b     => pc_iu_cfg_sl_thold_0_b,
            sg          => pc_iu_sg_0,
            forcee => cfg_force,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin        => ccfg_siv(ppr32_t0_offset to ppr32_t0_offset + ppr32_t0_l2'length-1),
            scout       => ccfg_sov(ppr32_t0_offset to ppr32_t0_offset + ppr32_t0_l2'length-1),
            din         => ppr32_t0_d,
            dout        => ppr32_t0_l2);

ppr32_t1_reg: tri_ser_rlmreg_p 
  generic map (width => ppr32_t1_l2'length, init => 3, expand_type => expand_type) 
  port map (vd      => vdd,
            gd      => gnd,
            nclk        => nclk,
            act         => ppr32_t1_wren,
            thold_b     => pc_iu_cfg_sl_thold_0_b,
            sg          => pc_iu_sg_0,
            forcee => cfg_force,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin        => ccfg_siv(ppr32_t1_offset to ppr32_t1_offset + ppr32_t1_l2'length-1),
            scout       => ccfg_sov(ppr32_t1_offset to ppr32_t1_offset + ppr32_t1_l2'length-1),
            din         => ppr32_t1_d,
            dout        => ppr32_t1_l2);

ppr32_t2_reg: tri_ser_rlmreg_p 
  generic map (width => ppr32_t2_l2'length, init => 3, expand_type => expand_type) 
  port map (vd      => vdd,
            gd      => gnd,
            nclk        => nclk,
            act         => ppr32_t2_wren,
            thold_b     => pc_iu_cfg_sl_thold_0_b,
            sg          => pc_iu_sg_0,
            forcee => cfg_force,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin        => ccfg_siv(ppr32_t2_offset to ppr32_t2_offset + ppr32_t2_l2'length-1),
            scout       => ccfg_sov(ppr32_t2_offset to ppr32_t2_offset + ppr32_t2_l2'length-1),
            din         => ppr32_t2_d,
            dout        => ppr32_t2_l2);

ppr32_t3_reg: tri_ser_rlmreg_p 
  generic map (width => ppr32_t3_l2'length, init => 3, expand_type => expand_type) 
  port map (vd      => vdd,
            gd      => gnd,
            nclk        => nclk,
            act         => ppr32_t3_wren,
            thold_b     => pc_iu_cfg_sl_thold_0_b,
            sg          => pc_iu_sg_0,
            forcee => cfg_force,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin        => ccfg_siv(ppr32_t3_offset to ppr32_t3_offset + ppr32_t3_l2'length-1),
            scout       => ccfg_sov(ppr32_t3_offset to ppr32_t3_offset + ppr32_t3_l2'length-1),
            din         => ppr32_t3_d,
            dout        => ppr32_t3_l2);

ccfg_spare_latch: tri_rlmreg_p
  generic map (width => ccfg_spare_l2'length, init => 0, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => tiup,
            thold_b => pc_iu_cfg_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => cfg_force,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => ccfg_siv(ccfg_spare_offset to ccfg_spare_offset + ccfg_spare_l2'length-1),
            scout   => ccfg_sov(ccfg_spare_offset to ccfg_spare_offset + ccfg_spare_l2'length-1),
            din     => ccfg_spare_l2,
            dout    => ccfg_spare_l2);


xu_iu_run_thread_d      <= xu_iu_run_thread;
xu_iu_ex6_pri_d         <= xu_iu_ex6_pri;
xu_iu_ex6_pri_val_d     <= xu_iu_ex6_pri_val;
xu_iu_raise_iss_pri_d   <= xu_iu_raise_iss_pri;
xu_iu_msr_gs_d          <= xu_iu_msr_gs;
xu_iu_msr_pr_d          <= xu_iu_msr_pr;

slowspr_val_d           <= slowspr_val_in;
slowspr_rw_d            <= slowspr_rw_in;
slowspr_etid_d          <= slowspr_etid_in;
slowspr_addr_d          <= slowspr_addr_in;
slowspr_data_d          <= slowspr_data_in;
slowspr_done_d          <= slowspr_done_in;

iu_slowspr_val_d        <= slowspr_val_l2;
iu_slowspr_rw_d         <= slowspr_rw_l2;
iu_slowspr_etid_d       <= slowspr_etid_l2;
iu_slowspr_addr_d       <= slowspr_addr_l2;
iu_slowspr_data_d       <= slowspr_data_l2 or iu_slowspr_data;
iu_slowspr_done_d       <= slowspr_done_l2 or iu_slowspr_done;

slowspr_val_out         <= iu_slowspr_val_l2;
slowspr_rw_out          <= iu_slowspr_rw_l2;
slowspr_etid_out        <= iu_slowspr_etid_l2;
slowspr_addr_out        <= iu_slowspr_addr_l2;
slowspr_data_out        <= iu_slowspr_data_l2;
slowspr_done_out        <= iu_slowspr_done_l2;


spr_dec_mask(0 to 31)   <= immr0_l2(32 to 63);
spr_dec_match(0 to 31)  <= imr0_l2(32 to 63);

spr_ic_pri_rand         <= iulfsr_l2(58) & iulfsr_l2(51) & iulfsr_l2(45) & iulfsr_l2(40) & iulfsr_l2(36);
spr_ic_pri_rand_flush   <= iulfsr_l2(60);
spr_ic_pri_rand_always  <= iulfsr_l2(61);

spr_fiss_pri_rand       <= iulfsr_l2(32) & iulfsr_l2(35) & iulfsr_l2(39) & iulfsr_l2(44) & iulfsr_l2(50);
spr_fiss_pri_rand_flush <= iulfsr_l2(62);
spr_fiss_pri_rand_always<= iulfsr_l2(63) or ll_hold;


spr_ic_clockgate_dis    <= iucr0_l2(48 to 49);
spr_ic_cls              <= iucr0_l2(50);
spr_ic_icbi_ack_en      <= iucr0_l2(51);

spr_bp_gshare_mask      <= "0000" when iucr0_l2(52 to 55) = "0000" else
                           "1000" when iucr0_l2(52 to 55) = "0001" else
                           "1100" when iucr0_l2(52 to 55) = "0010" else
                           "1110" when iucr0_l2(52 to 55) = "0011" else
                           "1111" ;

spr_ic_bp_config        <= iucr0_l2(56 to 59);
spr_bp_config           <= iucr0_l2(60 to 63);

iu_au_config_iucr_t0    <= iucr2_t0_l2(32 to 39);
iu_au_config_iucr_t1    <= iucr2_t1_l2(32 to 39);
iu_au_config_iucr_t2    <= iucr2_t2_l2(32 to 39);
iu_au_config_iucr_t3    <= iucr2_t3_l2(32 to 39);

spr_issue_high_mask(0 to 3)     <=     hi_pri(0 to 3);
spr_issue_med_mask(0 to 3)      <= not hi_pri(0 to 3) and not lo_pri(0 to 3);

spr_fiss_count0_max     <= iucr1_t0_l2(58 to 63);
spr_fiss_count1_max     <= iucr1_t1_l2(58 to 63);
spr_fiss_count2_max     <= iucr1_t2_l2(58 to 63);
spr_fiss_count3_max     <= iucr1_t3_l2(58 to 63);

hi_pri_level_t0         <= iucr1_t0_l2(50 to 51);
hi_pri_level_t1         <= iucr1_t1_l2(50 to 51);
hi_pri_level_t2         <= iucr1_t2_l2(50 to 51);
hi_pri_level_t3         <= iucr1_t3_l2(50 to 51);

spr_ic_idir_read        <= iudbg0_exec_l2;
spr_ic_idir_way         <= iudbg0_l2(50 to 51);
spr_ic_idir_row         <= iudbg0_l2(52 to 57);

iull_en                 <= iullcr_l2(63);

ll_trig_dly(0 to 3)     <= "0001" when iullcr_l2(46 to 49) = "0000" else iullcr_l2(46 to 49);
ll_trig_dly(4 to 17)    <= ll_trig_rnd_l2(4 to 17);

ll_hold_dly(0 to 5)     <= iullcr_l2(54 to 59);
ll_hold_dly(6 to 9)     <= "0000";

ll_trig_rnd_act         <= iull_en and ll_rand;
ll_trig_rnd_d(4 to 17)  <= iulfsr_l2(32) & iulfsr_l2(33) & iulfsr_l2(35) & iulfsr_l2(36) &
                           iulfsr_l2(38) & iulfsr_l2(39) & iulfsr_l2(41) & iulfsr_l2(42) &
                           iulfsr_l2(44) & iulfsr_l2(45) & iulfsr_l2(47) & iulfsr_l2(48) &
                           iulfsr_l2(50) & iulfsr_l2(51);

ll_trig_cnt_act         <= iull_en and not ll_hold;
ll_trig_cnt_d(0 to 17)  <= "000000000000000000" when ll_trig_cnt_l2(0 to 17) = ll_trig_dly(0 to 17)     else ll_trig_cnt_l2(0 to 17) + 1;
ll_trig                 <= ll_trig_cnt_l2(0 to 17) = ll_trig_dly(0 to 17);
ll_rand                 <= ll_trig_cnt_l2(0 to 3) /= ll_trig_dly(0 to 3);

ll_hold_cnt_act         <= iull_en and (ll_hold or ll_trig);
ll_hold_cnt_d(0 to 9)   <= "0000000000"         when ll_hold_cnt_l2(0 to 9)  = ll_hold_dly(0 to 9)      else ll_hold_cnt_l2(0 to 9)  + 1;
ll_hold                 <= iull_en and or_reduce(ll_hold_cnt_l2(0 to 9));

spr_fdep_ll_hold        <= ll_hold;


immr0_sel       <= slowspr_val_l2 and slowspr_addr_l2 = "1101110001";      
imr0_sel        <= slowspr_val_l2 and slowspr_addr_l2 = "1101110000";      
iulfsr_sel      <= slowspr_val_l2 and slowspr_addr_l2 = "1101111011";      
iudbg0_sel      <= slowspr_val_l2 and slowspr_addr_l2 = "1101111000";      
iudbg1_sel      <= slowspr_val_l2 and slowspr_addr_l2 = "1101111001";      
iudbg2_sel      <= slowspr_val_l2 and slowspr_addr_l2 = "1101111010";      
iullcr_sel      <= slowspr_val_l2 and slowspr_addr_l2 = "1101111100";      
iucr0_sel       <= slowspr_val_l2 and slowspr_addr_l2 = "1111110011";      
iucr1_t0_sel    <= slowspr_val_l2 and slowspr_addr_l2 = "1101110011" and slowspr_etid_l2 = "00";      
iucr1_t1_sel    <= slowspr_val_l2 and slowspr_addr_l2 = "1101110011" and slowspr_etid_l2 = "01";      
iucr1_t2_sel    <= slowspr_val_l2 and slowspr_addr_l2 = "1101110011" and slowspr_etid_l2 = "10";      
iucr1_t3_sel    <= slowspr_val_l2 and slowspr_addr_l2 = "1101110011" and slowspr_etid_l2 = "11";      
iucr2_t0_sel    <= slowspr_val_l2 and slowspr_addr_l2 = "1101110100" and slowspr_etid_l2 = "00";      
iucr2_t1_sel    <= slowspr_val_l2 and slowspr_addr_l2 = "1101110100" and slowspr_etid_l2 = "01";      
iucr2_t2_sel    <= slowspr_val_l2 and slowspr_addr_l2 = "1101110100" and slowspr_etid_l2 = "10";      
iucr2_t3_sel    <= slowspr_val_l2 and slowspr_addr_l2 = "1101110100" and slowspr_etid_l2 = "11";      
ppr32_t0_sel    <= slowspr_val_l2 and slowspr_addr_l2 = "1110000010" and slowspr_etid_l2 = "00";      
ppr32_t1_sel    <= slowspr_val_l2 and slowspr_addr_l2 = "1110000010" and slowspr_etid_l2 = "01";      
ppr32_t2_sel    <= slowspr_val_l2 and slowspr_addr_l2 = "1110000010" and slowspr_etid_l2 = "10";      
ppr32_t3_sel    <= slowspr_val_l2 and slowspr_addr_l2 = "1110000010" and slowspr_etid_l2 = "11";      

iu_slowspr_done         <= immr0_sel or imr0_sel or iulfsr_sel or iullcr_sel or iucr0_sel or
                           iudbg0_sel or iudbg1_sel or iudbg2_sel or
                           iucr1_t0_sel or iucr1_t1_sel or iucr1_t2_sel or iucr1_t3_sel or
                           iucr2_t0_sel or iucr2_t1_sel or iucr2_t2_sel or iucr2_t3_sel or
                           ppr32_t0_sel or ppr32_t1_sel or ppr32_t2_sel or ppr32_t3_sel; 



priv_mode(0 to 3)       <= not xu_iu_msr_pr_l2(0 to 3);
hypv_mode(0 to 3)       <= not xu_iu_msr_pr_l2(0 to 3) and not xu_iu_msr_gs_l2(0 to 3);



lo_pri(0)       <= not xu_iu_raise_iss_pri_l2(0) and
                  (ppr32_t0_l2(43 to 45) = "000" or 
                   ppr32_t0_l2(43 to 45) = "001" or
                   ppr32_t0_l2(43 to 45) = "010" );

lo_pri(1)       <= not xu_iu_raise_iss_pri_l2(1) and
                  (ppr32_t1_l2(43 to 45) = "000" or 
                   ppr32_t1_l2(43 to 45) = "001" or
                   ppr32_t1_l2(43 to 45) = "010" );

lo_pri(2)       <= not xu_iu_raise_iss_pri_l2(2) and
                  (ppr32_t2_l2(43 to 45) = "000" or 
                   ppr32_t2_l2(43 to 45) = "001" or
                   ppr32_t2_l2(43 to 45) = "010" );

lo_pri(3)       <= not xu_iu_raise_iss_pri_l2(3) and
                  (ppr32_t3_l2(43 to 45) = "000" or 
                   ppr32_t3_l2(43 to 45) = "001" or
                   ppr32_t3_l2(43 to 45) = "010" );


hi_pri(0)       <=(ppr32_t0_l2(43 to 45) = "100" and  hi_pri_level_t0(0 to 1)  = "00") or
                  (ppr32_t0_l2(43 to 45) = "101" and (hi_pri_level_t0(0 to 1)  = "00"  or hi_pri_level_t0(0 to 1)  = "01")) or
                  (ppr32_t0_l2(43 to 45) = "110" and (hi_pri_level_t0(0 to 1)  = "00"  or hi_pri_level_t0(0 to 1)  = "01"   or hi_pri_level_t0(0 to 1)  = "10")) or
                   ppr32_t0_l2(43 to 45) = "111" ;

hi_pri(1)       <=(ppr32_t1_l2(43 to 45) = "100" and  hi_pri_level_t1(0 to 1)  = "00") or
                  (ppr32_t1_l2(43 to 45) = "101" and (hi_pri_level_t1(0 to 1)  = "00"  or hi_pri_level_t1(0 to 1)  = "01")) or
                  (ppr32_t1_l2(43 to 45) = "110" and (hi_pri_level_t1(0 to 1)  = "00"  or hi_pri_level_t1(0 to 1)  = "01"   or hi_pri_level_t1(0 to 1)  = "10")) or
                   ppr32_t1_l2(43 to 45) = "111" ;

hi_pri(2)       <=(ppr32_t2_l2(43 to 45) = "100" and  hi_pri_level_t2(0 to 1)  = "00") or
                  (ppr32_t2_l2(43 to 45) = "101" and (hi_pri_level_t2(0 to 1)  = "00"  or hi_pri_level_t2(0 to 1)  = "01")) or
                  (ppr32_t2_l2(43 to 45) = "110" and (hi_pri_level_t2(0 to 1)  = "00"  or hi_pri_level_t2(0 to 1)  = "01"   or hi_pri_level_t2(0 to 1)  = "10")) or
                   ppr32_t2_l2(43 to 45) = "111" ;

hi_pri(3)       <=(ppr32_t3_l2(43 to 45) = "100" and  hi_pri_level_t3(0 to 1)  = "00") or
                  (ppr32_t3_l2(43 to 45) = "101" and (hi_pri_level_t3(0 to 1)  = "00"  or hi_pri_level_t3(0 to 1)  = "01")) or
                  (ppr32_t3_l2(43 to 45) = "110" and (hi_pri_level_t3(0 to 1)  = "00"  or hi_pri_level_t3(0 to 1)  = "01"   or hi_pri_level_t3(0 to 1)  = "10")) or
                   ppr32_t3_l2(43 to 45) = "111" ;





iudbg0_exec_wren <=  iudbg0_wren or iudbg0_exec_L2;
iudbg0_done_wren <=  iudbg0_wren or ic_spr_idir_done;

iudbg1_wren     <=  ic_spr_idir_done;
iudbg2_wren     <=  ic_spr_idir_done;

immr0_wren      <=  immr0_sel    and slowspr_rw_l2 = '0';
imr0_wren       <=  imr0_sel     and slowspr_rw_l2 = '0';
iulfsr_wren     <=  iulfsr_sel   and slowspr_rw_l2 = '0';
iudbg0_wren     <=  iudbg0_sel   and slowspr_rw_l2 = '0';
iullcr_wren     <=  iullcr_sel   and slowspr_rw_l2 = '0';
iucr0_wren      <=  iucr0_sel    and slowspr_rw_l2 = '0';
iucr1_t0_wren   <=  iucr1_t0_sel and slowspr_rw_l2 = '0';
iucr1_t1_wren   <=  iucr1_t1_sel and slowspr_rw_l2 = '0';
iucr1_t2_wren   <=  iucr1_t2_sel and slowspr_rw_l2 = '0';
iucr1_t3_wren   <=  iucr1_t3_sel and slowspr_rw_l2 = '0';
iucr2_t0_wren   <=  iucr2_t0_sel and slowspr_rw_l2 = '0';
iucr2_t1_wren   <=  iucr2_t1_sel and slowspr_rw_l2 = '0';
iucr2_t2_wren   <=  iucr2_t2_sel and slowspr_rw_l2 = '0';
iucr2_t3_wren   <=  iucr2_t3_sel and slowspr_rw_l2 = '0';



ppr32_t0_wren   <= ((ppr32_t0_sel and slowspr_rw_l2 = '0') or xu_iu_ex6_pri_val_l2(0)) and
                   ((ppr32_t0_d(43 to 45) = "001" and priv_mode(0)) or
                    (ppr32_t0_d(43 to 45) = "010"                 ) or
                    (ppr32_t0_d(43 to 45) = "011"                 ) or
                    (ppr32_t0_d(43 to 45) = "100"                 ) or
                    (ppr32_t0_d(43 to 45) = "101" and priv_mode(0)) or
                    (ppr32_t0_d(43 to 45) = "110" and priv_mode(0)) or
                    (ppr32_t0_d(43 to 45) = "111" and hypv_mode(0)) );

ppr32_t1_wren   <= ((ppr32_t1_sel and slowspr_rw_l2 = '0') or xu_iu_ex6_pri_val_l2(1)) and
                   ((ppr32_t1_d(43 to 45) = "001" and priv_mode(1)) or
                    (ppr32_t1_d(43 to 45) = "010"                 ) or
                    (ppr32_t1_d(43 to 45) = "011"                 ) or
                    (ppr32_t1_d(43 to 45) = "100"                 ) or
                    (ppr32_t1_d(43 to 45) = "101" and priv_mode(1)) or
                    (ppr32_t1_d(43 to 45) = "110" and priv_mode(1)) or
                    (ppr32_t1_d(43 to 45) = "111" and hypv_mode(1)) );

ppr32_t2_wren   <= ((ppr32_t2_sel and slowspr_rw_l2 = '0') or xu_iu_ex6_pri_val_l2(2)) and
                   ((ppr32_t2_d(43 to 45) = "001" and priv_mode(2)) or
                    (ppr32_t2_d(43 to 45) = "010"                 ) or
                    (ppr32_t2_d(43 to 45) = "011"                 ) or
                    (ppr32_t2_d(43 to 45) = "100"                 ) or
                    (ppr32_t2_d(43 to 45) = "101" and priv_mode(2)) or
                    (ppr32_t2_d(43 to 45) = "110" and priv_mode(2)) or
                    (ppr32_t2_d(43 to 45) = "111" and hypv_mode(2)) );

ppr32_t3_wren   <= ((ppr32_t3_sel and slowspr_rw_l2 = '0') or xu_iu_ex6_pri_val_l2(3)) and
                   ((ppr32_t3_d(43 to 45) = "001" and priv_mode(3)) or
                    (ppr32_t3_d(43 to 45) = "010"                 ) or
                    (ppr32_t3_d(43 to 45) = "011"                 ) or
                    (ppr32_t3_d(43 to 45) = "100"                 ) or
                    (ppr32_t3_d(43 to 45) = "101" and priv_mode(3)) or
                    (ppr32_t3_d(43 to 45) = "110" and priv_mode(3)) or
                    (ppr32_t3_d(43 to 45) = "111" and hypv_mode(3)) );




iudbg0_exec_d   <= IUDBG0_MASK(62) and slowspr_data_l2(62) when iudbg0_wren = '1' else '0';
iudbg0_done_d   <= IUDBG0_MASK(63) and slowspr_data_l2(63) when iudbg0_wren = '1' else ic_spr_idir_done;

iudbg1_d        <= IUDBG1_MASK(53 to 63) and (ic_spr_idir_lru(0 to 2) & ic_spr_idir_parity(0 to 3) & ic_spr_idir_endian & "00" & ic_spr_idir_valid);
iudbg2_d        <= IUDBG2_MASK(34 to 63) and  ic_spr_idir_tag(0 to 29);

immr0_d         <= IMMR0_MASK and slowspr_data_l2(32 to 63);
imr0_d          <= IMR0_MASK  and slowspr_data_l2(32 to 63);


iulfsr(1 to 28) <= iulfsr_l2(32 to 59);
iulfsr_d        <= IULFSR_MASK and slowspr_data_l2(32 to 63) when iulfsr_wren = '1' else
                   (iulfsr(28) xor iulfsr(27) xor iulfsr(26) xor iulfsr(25) xor iulfsr(24) xor iulfsr(8)) & iulfsr(1 to 27) & iulfsr_l2(60 to 63);
iulfsr_act      <= iulfsr_wren or or_reduce(xu_iu_run_thread_l2(0 to 3));

iudbg0_d        <= IUDBG0_MASK(50 to 57) and slowspr_data_l2(50 to 57);
iullcr_d        <= IULLCR_MASK(46 to 63) and slowspr_data_l2(46 to 63);
iucr0_d         <= IUCR0_MASK(48 to 63) and (slowspr_data_l2(48 to 49) & iucr0_L2(50) & slowspr_data_l2(51 to 63));

iucr1_t0_d      <= IUCR1_MASK(50 to 63) and slowspr_data_l2(50 to 63);
iucr1_t1_d      <= IUCR1_MASK(50 to 63) and slowspr_data_l2(50 to 63);
iucr1_t2_d      <= IUCR1_MASK(50 to 63) and slowspr_data_l2(50 to 63);
iucr1_t3_d      <= IUCR1_MASK(50 to 63) and slowspr_data_l2(50 to 63);

iucr2_t0_d      <= IUCR2_MASK(32 to 39) and slowspr_data_l2(32 to 39);
iucr2_t1_d      <= IUCR2_MASK(32 to 39) and slowspr_data_l2(32 to 39);
iucr2_t2_d      <= IUCR2_MASK(32 to 39) and slowspr_data_l2(32 to 39);
iucr2_t3_d      <= IUCR2_MASK(32 to 39) and slowspr_data_l2(32 to 39);



ppr32_t0_d      <= PPR32_MASK(43 to 45) and xu_iu_ex6_pri_l2(0 to 2)    when  xu_iu_ex6_pri_val_l2(0)             = '1' else
                   PPR32_MASK(43 to 45) and slowspr_data_l2(43 to 45);
ppr32_t1_d      <= PPR32_MASK(43 to 45) and xu_iu_ex6_pri_l2(0 to 2)    when  xu_iu_ex6_pri_val_l2(1)             = '1' else
                   PPR32_MASK(43 to 45) and slowspr_data_l2(43 to 45);
ppr32_t2_d      <= PPR32_MASK(43 to 45) and xu_iu_ex6_pri_l2(0 to 2)    when  xu_iu_ex6_pri_val_l2(2)             = '1' else
                   PPR32_MASK(43 to 45) and slowspr_data_l2(43 to 45);
ppr32_t3_d      <= PPR32_MASK(43 to 45) and xu_iu_ex6_pri_l2(0 to 2)    when  xu_iu_ex6_pri_val_l2(3)             = '1' else
                   PPR32_MASK(43 to 45) and slowspr_data_l2(43 to 45);




immr0_rden      <= immr0_sel    and slowspr_rw_l2 = '1';
imr0_rden       <= imr0_sel     and slowspr_rw_l2 = '1';
iulfsr_rden     <= iulfsr_sel   and slowspr_rw_l2 = '1';
iudbg0_rden     <= iudbg0_sel   and slowspr_rw_l2 = '1';
iudbg1_rden     <= iudbg1_sel   and slowspr_rw_l2 = '1';
iudbg2_rden     <= iudbg2_sel   and slowspr_rw_l2 = '1';
iullcr_rden     <= iullcr_sel   and slowspr_rw_l2 = '1';
iucr0_rden      <= iucr0_sel    and slowspr_rw_l2 = '1';
iucr1_t0_rden   <= iucr1_t0_sel and slowspr_rw_l2 = '1';
iucr1_t1_rden   <= iucr1_t1_sel and slowspr_rw_l2 = '1';
iucr1_t2_rden   <= iucr1_t2_sel and slowspr_rw_l2 = '1';
iucr1_t3_rden   <= iucr1_t3_sel and slowspr_rw_l2 = '1';
iucr2_t0_rden   <= iucr2_t0_sel and slowspr_rw_l2 = '1';
iucr2_t1_rden   <= iucr2_t1_sel and slowspr_rw_l2 = '1';
iucr2_t2_rden   <= iucr2_t2_sel and slowspr_rw_l2 = '1';
iucr2_t3_rden   <= iucr2_t3_sel and slowspr_rw_l2 = '1';
ppr32_t0_rden   <= ppr32_t0_sel and slowspr_rw_l2 = '1';
ppr32_t1_rden   <= ppr32_t1_sel and slowspr_rw_l2 = '1';
ppr32_t2_rden   <= ppr32_t2_sel and slowspr_rw_l2 = '1';
ppr32_t3_rden   <= ppr32_t3_sel and slowspr_rw_l2 = '1';

r64: if (regmode > 5) generate begin
iu_slowspr_data(0 to 31)        <= (others => '0');
end generate;
iu_slowspr_data(32 to 63)       <= immr0_L2     when immr0_rden         = '1' else
                                   imr0_L2      when imr0_rden          = '1' else
                                   iulfsr_L2    when iulfsr_rden        = '1' else
                                   iudbg0       when iudbg0_rden        = '1' else
                                   iudbg1       when iudbg1_rden        = '1' else
                                   iudbg2       when iudbg2_rden        = '1' else
                                   iullcr       when iullcr_rden        = '1' else
                                   iucr0        when iucr0_rden         = '1' else
                                   iucr1_t0     when iucr1_t0_rden      = '1' else
                                   iucr1_t1     when iucr1_t1_rden      = '1' else
                                   iucr1_t2     when iucr1_t2_rden      = '1' else
                                   iucr1_t3     when iucr1_t3_rden      = '1' else
                                   iucr2_t0     when iucr2_t0_rden      = '1' else
                                   iucr2_t1     when iucr2_t1_rden      = '1' else
                                   iucr2_t2     when iucr2_t2_rden      = '1' else
                                   iucr2_t3     when iucr2_t3_rden      = '1' else
                                   ppr32_t0     when ppr32_t0_rden      = '1' else
                                   ppr32_t1     when ppr32_t1_rden      = '1' else
                                   ppr32_t2     when ppr32_t2_rden      = '1' else
                                   ppr32_t3     when ppr32_t3_rden      = '1' else
                                   (others => '0');


iudbg0(32 to 63)                <= IUDBG0_MASK(32 to 49) & iudbg0_L2(50 to 57) & IUDBG0_MASK(58 to 61) & iudbg0_exec_L2 & iudbg0_done_L2;
iudbg1(32 to 63)                <= IUDBG1_MASK(32 to 52) & iudbg1_L2(53 to 63);
iudbg2(32 to 63)                <= IUDBG2_MASK(32 to 33) & iudbg2_L2(34 to 63);

iullcr(32 to 63)                <= IULLCR_MASK(32 to 45) & iullcr_L2(46 to 63);
iucr0(32 to 63)                 <= IUCR0_MASK(32 to 47) & iucr0_L2(48 to 63);

iucr1_t0(32 to 63)              <= IUCR1_MASK(32 to 49) & iucr1_t0_L2(50 to 63);
iucr1_t1(32 to 63)              <= IUCR1_MASK(32 to 49) & iucr1_t1_L2(50 to 63);
iucr1_t2(32 to 63)              <= IUCR1_MASK(32 to 49) & iucr1_t2_L2(50 to 63);
iucr1_t3(32 to 63)              <= IUCR1_MASK(32 to 49) & iucr1_t3_L2(50 to 63);

iucr2_t0(32 to 63)              <= iucr2_t0_L2(32 to 39) & IUCR2_MASK(40 to 63);
iucr2_t1(32 to 63)              <= iucr2_t1_L2(32 to 39) & IUCR2_MASK(40 to 63);
iucr2_t2(32 to 63)              <= iucr2_t2_L2(32 to 39) & IUCR2_MASK(40 to 63);
iucr2_t3(32 to 63)              <= iucr2_t3_L2(32 to 39) & IUCR2_MASK(40 to 63);

ppr32_t0(32 to 63)              <= PPR32_MASK(32 to 42) & ppr32_t0_L2(43 to 45) & PPR32_MASK(46 to 63);
ppr32_t1(32 to 63)              <= PPR32_MASK(32 to 42) & ppr32_t1_L2(43 to 45) & PPR32_MASK(46 to 63);
ppr32_t2(32 to 63)              <= PPR32_MASK(32 to 42) & ppr32_t2_L2(43 to 45) & PPR32_MASK(46 to 63);
ppr32_t3(32 to 63)              <= PPR32_MASK(32 to 42) & ppr32_t3_L2(43 to 45) & PPR32_MASK(46 to 63);


                 


perv_2to1_reg: tri_plat
  generic map (width => 3, expand_type => expand_type)
  port map (vd          => vdd,
            gd          => gnd,
            nclk        => nclk,
            flush       => tc_ac_ccflush_dc,
            din(0)      => pc_iu_func_sl_thold_2,
            din(1)      => pc_iu_sg_2,
            din(2)      => pc_iu_cfg_sl_thold_2,
            q(0)        => pc_iu_func_sl_thold_1,
            q(1)        => pc_iu_sg_1,
            q(2)        => pc_iu_cfg_sl_thold_1);

perv_1to0_reg: tri_plat
  generic map (width => 3, expand_type => expand_type)
  port map (vd          => vdd,
            gd          => gnd,
            nclk        => nclk,
            flush       => tc_ac_ccflush_dc,
            din(0)      => pc_iu_func_sl_thold_1,
            din(1)      => pc_iu_sg_1,
            din(2)      => pc_iu_cfg_sl_thold_1,
            q(0)        => pc_iu_func_sl_thold_0,
            q(1)        => pc_iu_sg_0,
            q(2)        => pc_iu_cfg_sl_thold_0);

perv_lcbor: tri_lcbor
  generic map (expand_type => expand_type)
  port map (clkoff_b    => clkoff_b,
            thold       => pc_iu_func_sl_thold_0,
            sg          => pc_iu_sg_0,
            act_dis     => act_dis,
            forcee => forcee,
            thold_b     => pc_iu_func_sl_thold_0_b);

cfg_perv_lcbor: tri_lcbor
  generic map (expand_type => expand_type)
  port map (clkoff_b    => clkoff_b,
            thold       => pc_iu_cfg_sl_thold_0,
            sg          => pc_iu_sg_0,
            act_dis     => act_dis,
            forcee => cfg_force,
            thold_b     => pc_iu_cfg_sl_thold_0_b);



slat_lcb: tri_lcbs
  generic map (expand_type => expand_type)
  port map (vd          => vdd,
            gd          => gnd, 
            delay_lclkr => delay_lclkr,
            nclk        => nclk,
            forcee => cfg_force,
            thold_b     => pc_iu_cfg_sl_thold_0_b,
            dclk        => dclk,
            lclk        => lclk  );

repower_latch: tri_slat_scan
  generic map (width => 2, init => "00", expand_type => expand_type)
  port map (vd          => vdd,
            gd          => gnd, 
            dclk        => dclk,
            lclk        => lclk,
            scan_in(0)  => bcfg_scan_in,
            scan_in(1)  => dcfg_scan_in,
            scan_out(0) => bcfg_scan_out,
            scan_out(1) => dcfg_scan_out,
            q           => open,
            q_b         => open);






siv(0 to scan_right)    <= scan_in & sov(0 to scan_right-1);
scan_out                <= sov(scan_right);

ccfg_siv(0 to ccfg_scan_right)  <= ccfg_scan_in & ccfg_sov(0 to ccfg_scan_right-1);
ccfg_scan_out                   <= ccfg_sov(ccfg_scan_right);

end iuq_spr;
