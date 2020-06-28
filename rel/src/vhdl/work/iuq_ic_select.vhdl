-- © IBM Corp. 2020
-- This softcore is licensed under and subject to the terms of the CC-BY 4.0
-- license (https://creativecommons.org/licenses/by/4.0/legalcode). 
-- Additional rights, including the right to physically implement a softcore 
-- that is compliant with the required sections of the Power ISA 
-- Specification, will be available at no cost via the OpenPOWER Foundation. 
-- This README will be updated with additional information when OpenPOWER's 
-- license is available.

			

library ieee,ibm,support,tri,work;
use ieee.std_logic_1164.all;
use ibm.std_ulogic_unsigned.all;
use ibm.std_ulogic_support.all;
use ibm.std_ulogic_function_support.all;
use support.power_logic_pkg.all;
use tri.tri_latches_pkg.all;
use work.iuq_pkg.all;

entity iuq_ic_select is
generic(expand_type     : integer := 2);
port(
     vdd                        : inout power_logic;
     gnd                        : inout power_logic;
     nclk                       : in clk_logic;
     pc_iu_func_sl_thold_0_b    : in std_ulogic;
     pc_iu_func_slp_sl_thold_0_b: in std_ulogic;
     pc_iu_sg_0                 : in std_ulogic;
     forcee : in std_ulogic;
     funcslp_force : in std_ulogic;
     d_mode                     : in std_ulogic;
     delay_lclkr                : in std_ulogic;
     mpw1_b                     : in std_ulogic;
     mpw2_b                     : in std_ulogic;
     an_ac_scan_dis_dc_b        : in std_ulogic;
     func_scan_in               : in std_ulogic;
     func_scan_out              : out std_ulogic;

     ac_an_power_managed        : in std_ulogic;

     xu_iu_run_thread           : in std_ulogic_vector(0 to 3);

     xu_iu_flush                : in std_ulogic_vector(0 to 3);
     xu_iu_iu0_flush_ifar0      : in EFF_IFAR;
     xu_iu_iu0_flush_ifar1      : in EFF_IFAR;
     xu_iu_iu0_flush_ifar2      : in EFF_IFAR;
     xu_iu_iu0_flush_ifar3      : in EFF_IFAR;
     xu_iu_flush_2ucode         : in std_ulogic_vector(0 to 3);
     xu_iu_flush_2ucode_type    : in std_ulogic_vector(0 to 3);

     xu_iu_msr_cm               : in std_ulogic_vector(0 to 3);  

     xu_iu_ex6_icbi_val         : in  std_ulogic_vector(0 to 3);
     xu_iu_ex6_icbi_addr        : in  std_ulogic_vector(REAL_IFAR'left to 57);

     an_ac_back_inv             : in std_ulogic;        
     an_ac_back_inv_addr        : in std_ulogic_vector(REAL_IFAR'left to 57);
     an_ac_back_inv_target      : in std_ulogic;        

     an_ac_icbi_ack             : in std_ulogic;
     an_ac_icbi_ack_thread      : in std_ulogic_vector(0 to 1);

     spr_ic_clockgate_dis       : in std_ulogic;
     spr_ic_icbi_ack_en         : in std_ulogic;        

     spr_ic_idir_read           : in std_ulogic;
     spr_ic_idir_row            : in std_ulogic_vector(52 to 57);

     spr_ic_pri_rand            : in std_ulogic_vector(0 to 4);
     spr_ic_pri_rand_always     : in std_ulogic;
     spr_ic_pri_rand_flush      : in std_ulogic;

     ic_perf_event_t0           : out std_ulogic_vector(2 to 3);
     ic_perf_event_t1           : out std_ulogic_vector(2 to 3);
     ic_perf_event_t2           : out std_ulogic_vector(2 to 3);
     ic_perf_event_t3           : out std_ulogic_vector(2 to 3);

     iu_ierat_iu0_val           : out std_ulogic;
     iu_ierat_iu0_thdid         : out std_ulogic_vector(0 to 3);
     iu_ierat_iu0_ifar          : out std_ulogic_vector(0 to 51);
     iu_ierat_iu0_flush         : out std_ulogic_vector(0 to 3);
     iu_ierat_iu1_flush         : out std_ulogic_vector(0 to 3);
     iu_ierat_ium1_back_inv     : out std_ulogic;  
     ierat_iu_hold_req          : in std_ulogic_vector(0 to 3);
     ierat_iu_iu2_flush_req     : in std_ulogic_vector(0 to 3);
     ierat_iu_iu2_miss          : in std_ulogic;

     icm_ics_iu0_preload_val    : in std_ulogic;
     icm_ics_iu0_preload_tid    : in std_ulogic_vector(0 to 3);
     icm_ics_iu0_preload_ifar   : in std_ulogic_vector(52 to 59);

     icm_ics_hold_thread        : in std_ulogic_vector(0 to 3);
     icm_ics_hold_thread_dbg    : in std_ulogic_vector(0 to 3);
     icm_ics_hold_iu0           : in std_ulogic;
     icm_ics_ecc_block_iu0      : in std_ulogic_vector(0 to 3);
     icm_ics_load_tid           : in std_ulogic_vector(0 to 3);
     icm_ics_iu1_ecc_flush      : in std_ulogic;
     icm_ics_iu2_miss_match_prev: in std_ulogic;

     ics_icm_iu2_flush_tid      : out std_ulogic_vector(0 to 3);
     ics_icm_iu3_flush_tid      : out std_ulogic_vector(0 to 3);

     ics_icm_iu0_ifar0          : out std_ulogic_vector(46 to 52);
     ics_icm_iu0_ifar1          : out std_ulogic_vector(46 to 52);
     ics_icm_iu0_ifar2          : out std_ulogic_vector(46 to 52);
     ics_icm_iu0_ifar3          : out std_ulogic_vector(46 to 52);

     ics_icm_iu0_inval          : out std_ulogic;
     ics_icm_iu0_inval_addr     : out std_ulogic_vector(52 to 57);

     ics_icd_dir_rd_act         : out std_ulogic;
     ics_icd_data_rd_act        : out std_ulogic;
     ics_icd_iu0_valid          : out std_ulogic;
     ics_icd_iu0_tid            : out std_ulogic_vector(0 to 3);
     ics_icd_iu0_ifar           : out EFF_IFAR;
     ics_icd_iu0_inval          : out std_ulogic;
     ics_icd_iu0_2ucode         : out std_ulogic;
     ics_icd_iu0_2ucode_type    : out std_ulogic;
     ics_icd_iu0_spr_idir_read  : out std_ulogic;

     icd_ics_iu1_valid          : in std_ulogic;
     icd_ics_iu1_tid            : in std_ulogic_vector(0 to 3);
     icd_ics_iu1_ifar           : in EFF_IFAR;
     icd_ics_iu1_2ucode         : in std_ulogic;
     icd_ics_iu1_2ucode_type    : in std_ulogic;

     ics_icd_all_flush_prev     : out std_ulogic_vector(0 to 3);
     ics_icd_iu1_flush_tid      : out std_ulogic_vector(0 to 3);
     ics_icd_iu2_flush_tid      : out std_ulogic_vector(0 to 3);
     icd_ics_iu2_miss_flush_prev: in std_ulogic_vector(0 to 3);
     icd_ics_iu2_ifar_eff       : in EFF_IFAR;
     icd_ics_iu2_2ucode         : in std_ulogic;
     icd_ics_iu2_2ucode_type    : in std_ulogic;
     icd_ics_iu3_parity_flush   : in std_ulogic_vector(0 to 3);
     icd_ics_iu3_ifar           : in EFF_IFAR;
     icd_ics_iu3_2ucode         : in std_ulogic;
     icd_ics_iu3_2ucode_type    : in std_ulogic;

     ic_bp_iu1_val              : out std_ulogic;
     ic_bp_iu1_tid              : out std_ulogic_vector(0 to 3);  
     ic_bp_iu1_ifar             : out std_ulogic_vector(52 to 59);

     bp_ib_iu4_ifar             : in EFF_IFAR;

     bp_ic_iu5_hold_tid         : in std_ulogic_vector(0 to 3);
     bp_ic_iu5_redirect_tid     : in std_ulogic_vector(0 to 3);
     bp_ic_iu5_redirect_ifar    : in EFF_IFAR;

     ib_ic_empty                : in std_ulogic_vector(0 to 3);
     ib_ic_below_water          : in std_ulogic_vector(0 to 3);
     ib_ic_iu5_redirect_tid     : in std_ulogic_vector(0 to 3);

     ic_fdep_icbi_ack           : out std_ulogic_vector(0 to 3);

     uc_flush_tid               : in std_ulogic_vector(0 to 3);
     uc_ic_hold_thread          : in std_ulogic_vector(0 to 3);

     event_bus_enable           : in  std_ulogic;       
     sel_dbg_data               : out std_ulogic_vector(0 to 87)
);
-- synopsys translate_off
-- synopsys translate_on
end iuq_ic_select;
ARCHITECTURE IUQ_IC_SELECT
          OF IUQ_IC_SELECT
          IS
constant an_ac_back_inv_offset          : natural := 0;
constant an_ac_back_inv_target_offset   : natural := an_ac_back_inv_offset + 1;
constant an_ac_back_inv_addr_offset     : natural := an_ac_back_inv_target_offset + 1;
constant back_inv_offset                : natural := an_ac_back_inv_addr_offset + REAL_IFAR'length - 4;
constant back_inv_clone_offset          : natural := back_inv_offset + 1;
constant an_ac_icbi_ack_offset          : natural := back_inv_clone_offset + 1;
constant an_ac_icbi_ack_thread_offset   : natural := an_ac_icbi_ack_offset + 1;
constant xu_icbi_buffer0_val_tid_offset : natural := an_ac_icbi_ack_thread_offset + 2;
constant xu_icbi_buffer0_addr_offset    : natural := xu_icbi_buffer0_val_tid_offset + 4;
constant xu_icbi_buffer1_val_tid_offset : natural := xu_icbi_buffer0_addr_offset + REAL_IFAR'length - 4;
constant xu_icbi_buffer1_addr_offset    : natural := xu_icbi_buffer1_val_tid_offset + 4;
constant xu_icbi_buffer2_val_tid_offset : natural := xu_icbi_buffer1_addr_offset + REAL_IFAR'length - 4;
constant xu_icbi_buffer2_addr_offset    : natural := xu_icbi_buffer2_val_tid_offset + 4;
constant xu_icbi_buffer3_val_tid_offset : natural := xu_icbi_buffer2_addr_offset + REAL_IFAR'length - 4;
constant xu_icbi_buffer3_addr_offset    : natural := xu_icbi_buffer3_val_tid_offset + 4;
constant xu_iu_run_thread_offset        : natural := xu_icbi_buffer3_addr_offset + REAL_IFAR'length - 4;
constant all_stages_flush_prev_offset   : natural := xu_iu_run_thread_offset + 4;
constant spare_offset                   : natural := all_stages_flush_prev_offset + 4;
constant iu0_ifar0_offset               : natural := spare_offset + 12;
constant iu0_ifar1_offset               : natural := iu0_ifar0_offset + EFF_IFAR'length;
constant iu0_ifar2_offset               : natural := iu0_ifar1_offset + EFF_IFAR'length;
constant iu0_ifar3_offset               : natural := iu0_ifar2_offset + EFF_IFAR'length;
constant iu0_2ucode_offset              : natural := iu0_ifar3_offset + EFF_IFAR'length;
constant iu0_2ucode_type_offset         : natural := iu0_2ucode_offset + 4;
constant iu0_high_sent1_offset          : natural := iu0_2ucode_type_offset + 4;
constant iu0_high_sent2_offset          : natural := iu0_high_sent1_offset + 4;
constant iu0_high_sent3_offset          : natural := iu0_high_sent2_offset + 4;
constant iu0_high_sent4_offset          : natural := iu0_high_sent3_offset + 4;
constant high_mask_offset               : natural := iu0_high_sent4_offset + 4;
constant iu0_low_sent1_offset           : natural := high_mask_offset + 4;
constant iu0_low_sent2_offset           : natural := iu0_low_sent1_offset + 4;
constant iu0_low_sent3_offset           : natural := iu0_low_sent2_offset + 4;
constant iu0_low_sent4_offset           : natural := iu0_low_sent3_offset + 4;
constant low_mask_offset                : natural := iu0_low_sent4_offset + 4;
constant iu1_bp_val_offset              : natural := low_mask_offset + 4;
constant iu1_bp_ifar_offset             : natural := iu1_bp_val_offset + 1;
constant iu5_ifar_offset                : natural := iu1_bp_ifar_offset + 8;
constant perf_event_t0_offset           : natural := iu5_ifar_offset + EFF_IFAR'length;
constant perf_event_t1_offset           : natural := perf_event_t0_offset + 2;
constant perf_event_t2_offset           : natural := perf_event_t1_offset + 2;
constant perf_event_t3_offset           : natural := perf_event_t2_offset + 2;
constant pri_took_offset                : natural := perf_event_t3_offset + 2;
constant spr_ic_icbi_ack_en_offset      : natural := pri_took_offset + 12;
constant spr_idir_read_offset           : natural := spr_ic_icbi_ack_en_offset + 1;
constant spr_idir_row_offset            : natural := spr_idir_read_offset + 1;
constant xu_iu_flush_offset             : natural := spr_idir_row_offset + 6;
constant scan_right                     : natural := xu_iu_flush_offset + 4 - 1;
subtype s3 is std_ulogic_vector(0 to 2);
signal tiup                     : std_ulogic;
signal an_ac_back_inv_d         : std_ulogic;
signal an_ac_back_inv_l2        : std_ulogic;
signal an_ac_back_inv_target_d  : std_ulogic;
signal an_ac_back_inv_target_l2 : std_ulogic;
signal an_ac_back_inv_addr_d    : std_ulogic_vector(REAL_IFAR'left to 57);
signal an_ac_back_inv_addr_l2   : std_ulogic_vector(REAL_IFAR'left to 57);
signal back_inv_d               : std_ulogic;
signal back_inv_l2              : std_ulogic;
signal back_inv_l2_clone        : std_ulogic;
signal an_ac_icbi_ack_d         : std_ulogic;
signal an_ac_icbi_ack_l2        : std_ulogic;
signal an_ac_icbi_ack_thread_d  : std_ulogic_vector(0 to 1);
signal an_ac_icbi_ack_thread_l2 : std_ulogic_vector(0 to 1);
signal xu_icbi_buffer0_val_tid_d    : std_ulogic_vector(0 to 3);
signal xu_icbi_buffer0_val_tid_l2   : std_ulogic_vector(0 to 3);
signal xu_icbi_buffer1_val_tid_d    : std_ulogic_vector(0 to 3);
signal xu_icbi_buffer1_val_tid_l2   : std_ulogic_vector(0 to 3);
signal xu_icbi_buffer2_val_tid_d    : std_ulogic_vector(0 to 3);
signal xu_icbi_buffer2_val_tid_l2   : std_ulogic_vector(0 to 3);
signal xu_icbi_buffer3_val_tid_d    : std_ulogic_vector(0 to 3);
signal xu_icbi_buffer3_val_tid_l2   : std_ulogic_vector(0 to 3);
signal xu_icbi_buffer0_addr_d    : std_ulogic_vector(REAL_IFAR'left to 57);
signal xu_icbi_buffer0_addr_l2   : std_ulogic_vector(REAL_IFAR'left to 57);
signal xu_icbi_buffer1_addr_d    : std_ulogic_vector(REAL_IFAR'left to 57);
signal xu_icbi_buffer1_addr_l2   : std_ulogic_vector(REAL_IFAR'left to 57);
signal xu_icbi_buffer2_addr_d    : std_ulogic_vector(REAL_IFAR'left to 57);
signal xu_icbi_buffer2_addr_l2   : std_ulogic_vector(REAL_IFAR'left to 57);
signal xu_icbi_buffer3_addr_d    : std_ulogic_vector(REAL_IFAR'left to 57);
signal xu_icbi_buffer3_addr_l2   : std_ulogic_vector(REAL_IFAR'left to 57);
signal xu_iu_run_thread_d       : std_ulogic_vector(0 to 3);
signal xu_iu_run_thread_l2      : std_ulogic_vector(0 to 3);
signal iu5_ifar_d               : EFF_IFAR;
signal iu5_ifar_l2              : EFF_IFAR;
signal all_stages_flush_prev_d  : std_ulogic_vector(0 to 3);
signal all_stages_flush_prev_l2 : std_ulogic_vector(0 to 3);
signal iu0_ifar0_d              : EFF_IFAR;
signal iu0_ifar0_l2             : EFF_IFAR;
signal iu0_ifar1_d              : EFF_IFAR;
signal iu0_ifar1_l2             : EFF_IFAR;
signal iu0_ifar2_d              : EFF_IFAR;
signal iu0_ifar2_l2             : EFF_IFAR;
signal iu0_ifar3_d              : EFF_IFAR;
signal iu0_ifar3_l2             : EFF_IFAR;
signal iu0_2ucode_d             : std_ulogic_vector(0 to 3);
signal iu0_2ucode_l2            : std_ulogic_vector(0 to 3);
signal iu0_2ucode_type_d        : std_ulogic_vector(0 to 3);
signal iu0_2ucode_type_l2       : std_ulogic_vector(0 to 3);
signal iu0_high_sent1_d         : std_ulogic_vector(0 to 3);
signal iu0_high_sent1_l2        : std_ulogic_vector(0 to 3);
signal iu0_low_sent1_d          : std_ulogic_vector(0 to 3);
signal iu0_low_sent1_l2         : std_ulogic_vector(0 to 3);
signal iu0_high_sent2_d         : std_ulogic_vector(0 to 3);
signal iu0_high_sent2_l2        : std_ulogic_vector(0 to 3);
signal iu0_low_sent2_d          : std_ulogic_vector(0 to 3);
signal iu0_low_sent2_l2         : std_ulogic_vector(0 to 3);
signal iu0_high_sent3_d         : std_ulogic_vector(0 to 3);
signal iu0_high_sent3_l2        : std_ulogic_vector(0 to 3);
signal iu0_low_sent3_d          : std_ulogic_vector(0 to 3);
signal iu0_low_sent3_l2         : std_ulogic_vector(0 to 3);
signal iu0_high_sent4_d         : std_ulogic_vector(0 to 3);
signal iu0_high_sent4_l2        : std_ulogic_vector(0 to 3);
signal iu0_low_sent4_d          : std_ulogic_vector(0 to 3);
signal iu0_low_sent4_l2         : std_ulogic_vector(0 to 3);
signal high_mask_d              : std_ulogic_vector(0 to 3);
signal high_mask_l2             : std_ulogic_vector(0 to 3);
signal low_mask_d               : std_ulogic_vector(0 to 3);
signal low_mask_l2              : std_ulogic_vector(0 to 3);
signal iu1_bp_val_d             : std_ulogic;
signal iu1_bp_val_l2            : std_ulogic;
signal iu1_bp_tid_d             : std_ulogic_vector(0 to 3);
signal iu1_bp_ifar_d            : std_ulogic_vector(52 to 59);
signal iu1_bp_ifar_l2           : std_ulogic_vector(52 to 59);
signal perf_event_t0_d          : std_ulogic_vector(2 to 3);
signal perf_event_t0_l2         : std_ulogic_vector(2 to 3);
signal perf_event_t1_d          : std_ulogic_vector(2 to 3);
signal perf_event_t1_l2         : std_ulogic_vector(2 to 3);
signal perf_event_t2_d          : std_ulogic_vector(2 to 3);
signal perf_event_t2_l2         : std_ulogic_vector(2 to 3);
signal perf_event_t3_d          : std_ulogic_vector(2 to 3);
signal perf_event_t3_l2         : std_ulogic_vector(2 to 3);
signal spr_ic_icbi_ack_en_l2    : std_ulogic;
signal spr_idir_read_d          : std_ulogic;
signal spr_idir_read_l2         : std_ulogic;
signal spr_idir_row_d           : std_ulogic_vector(52 to 57);
signal spr_idir_row_l2          : std_ulogic_vector(52 to 57);
signal xu_iu_flush_l2           : std_ulogic_vector(0 to 3);
signal spare_l2                 : std_ulogic_vector(0 to 11);
signal back_inv                 : std_ulogic;
signal iu5_act                  : std_ulogic;
signal iu0_high_act             : std_ulogic;
signal iu0_low_act              : std_ulogic;
signal xu_icbi_buffer0_act      : std_ulogic;
signal xu_icbi_buffer123_act    : std_ulogic;
signal xu_icbi_buffer_val       : std_ulogic_vector(0 to 3);
signal l2_icbi_ack              : std_ulogic_vector(0 to 3);
signal block_spr_idir_read      : std_ulogic;
signal iu0_spr_idir_read        : std_ulogic;
signal iu1_icm_flush_tid        : std_ulogic_vector(0 to 3);
signal hold_iu0_v               : std_ulogic_vector(0 to 3);
signal iu0_hold_ecc             : std_ulogic;
signal iu0_hold_ecc_v           : std_ulogic_vector(0 to 3);
signal all_stages_flush_tid     : std_ulogic_vector(0 to 3);
signal iu0_flush_tid            : std_ulogic_vector(0 to 3);
signal iu1_flush_tid            : std_ulogic_vector(0 to 3);
signal iu2_flush_tid            : std_ulogic_vector(0 to 3);
signal iu3_flush_tid            : std_ulogic_vector(0 to 3);
signal hold_thread_pre_iu0      : std_ulogic_vector(0 to 3);
signal hold_thread_iu0          : std_ulogic_vector(0 to 3);
signal next_high_valid          : std_ulogic;
signal next_low_valid           : std_ulogic;
signal next_tid                 : std_ulogic_vector(0 to 3);
signal iu0_ifar0_early          : EFF_IFAR;
signal iu0_ifar1_early          : EFF_IFAR;
signal iu0_ifar2_early          : EFF_IFAR;
signal iu0_ifar3_early          : EFF_IFAR;
signal iu0_ifar0_pre_cm         : EFF_IFAR;
signal iu0_ifar1_pre_cm         : EFF_IFAR;
signal iu0_ifar2_pre_cm         : EFF_IFAR;
signal iu0_ifar3_pre_cm         : EFF_IFAR;
signal iu0_2ucode_early         : std_ulogic_vector(0 to 3);
signal iu0_2ucode_type_early    : std_ulogic_vector(0 to 3);
signal iu0_early_valid          : std_ulogic;
signal iu0_valid                : std_ulogic;
signal iu0_high_sentall4        : std_ulogic_vector(0 to 3);
signal iu0_low_sentall4         : std_ulogic_vector(0 to 3);
signal back_inv_addr_ext        : std_ulogic_vector(EFF_IFAR'left to 57);
signal xu_icbi_addr_ext         : std_ulogic_vector(EFF_IFAR'left to 57);
signal iu0_inval                : std_ulogic;
signal iu0_ifar0_or_back_inv_addr: EFF_IFAR;
signal select_iu0_ifar0         : std_ulogic;
signal iu0_ifar                 : EFF_IFAR;
signal iu0_2ucode               : std_ulogic;
signal iu0_2ucode_type          : std_ulogic;
signal iu1_bp_act               : std_ulogic;
signal siv                      : std_ulogic_vector(0 to scan_right);
signal sov                      : std_ulogic_vector(0 to scan_right);
-- synopsys translate_off
-- synopsys translate_on
signal hi_did3no0_d   : std_ulogic;
signal hi_did3no1_d   : std_ulogic;
signal hi_did3no2_d   : std_ulogic;
signal hi_did2no0_d   : std_ulogic;
signal hi_did2no1_d   : std_ulogic;
signal hi_did1no0_d   : std_ulogic;
signal md_did3no0_d   : std_ulogic;
signal md_did3no1_d   : std_ulogic;
signal md_did3no2_d   : std_ulogic;
signal md_did2no0_d   : std_ulogic;
signal md_did2no1_d   : std_ulogic;
signal md_did1no0_d   : std_ulogic;
signal hi_n230, hi_n231, hi_n232    : std_ulogic;
signal hi_n220, hi_n221, hi_n210    : std_ulogic;
signal md_n230, md_n231, md_n232    : std_ulogic;
signal md_n220, md_n221, md_n210    : std_ulogic;
signal medpri_v, medpri_v_b, highpri_v, highpri_v_b    : std_ulogic_vector(0 to 3);
signal medpri_v_b0, highpri_v_b0                       : std_ulogic_vector(0 to 3);
signal hi_did0no1, hi_did0no2, hi_did0no3   : std_ulogic;
signal hi_did1no0, hi_did1no2, hi_did1no3   : std_ulogic;
signal hi_did2no1, hi_did2no0, hi_did2no3   : std_ulogic;
signal hi_did3no1, hi_did3no2, hi_did3no0   : std_ulogic;
signal md_did0no1, md_did0no2, md_did0no3   : std_ulogic;
signal md_did1no0, md_did1no2, md_did1no3   : std_ulogic;
signal md_did2no1, md_did2no0, md_did2no3   : std_ulogic;
signal md_did3no1, md_did3no2, md_did3no0   : std_ulogic;
signal hi_sel, hi_sel_b, md_sel, md_sel_b, hi_later, md_later      : std_ulogic_vector(0 to 3);
signal hi_did3no0_din   : std_ulogic;
signal hi_did3no1_din   : std_ulogic;
signal hi_did3no2_din   : std_ulogic;
signal hi_did2no0_din   : std_ulogic;
signal hi_did2no1_din   : std_ulogic;
signal hi_did1no0_din   : std_ulogic;
signal md_did3no0_din   : std_ulogic;
signal md_did3no1_din   : std_ulogic;
signal md_did3no2_din   : std_ulogic;
signal md_did2no0_din   : std_ulogic;
signal md_did2no1_din   : std_ulogic;
signal md_did1no0_din   : std_ulogic;
signal issselhi_b, issselmd_b : std_ulogic_vector(0 to 3);
signal no_hi_v,no_hi_v_n01, no_hi_v_n23 : std_ulogic;
signal hi_l30,  hi_l31,  hi_l32 : std_ulogic;
signal hi_l23,  hi_l20,  hi_l21 : std_ulogic;
signal hi_l12,  hi_l13,  hi_l10 : std_ulogic;
signal hi_l01,  hi_l02,  hi_l03 : std_ulogic;
signal md_l30,  md_l31,  md_l32 : std_ulogic;
signal md_l23,  md_l20,  md_l21 : std_ulogic;
signal md_l12,  md_l13,  md_l10 : std_ulogic;
signal md_l01,  md_l02,  md_l03 : std_ulogic;
signal no_hi_v_b : std_ulogic;
signal pri_rand                 : std_ulogic_vector(0 to 5);
-- synopsys translate_off
-- synopsys translate_on
  BEGIN 

tiup  <=  '1';
xu_iu_run_thread_d  <=  xu_iu_run_thread;
iu5_ifar_d  <=  bp_ib_iu4_ifar;
iu5_act  <=  spr_ic_clockgate_dis or or_reduce(iu0_high_sent4_l2) or or_reduce(iu0_low_sent4_l2);
an_ac_back_inv_d         <=  an_ac_back_inv;
an_ac_back_inv_target_d  <=  an_ac_back_inv_target;
an_ac_back_inv_addr_d    <=  an_ac_back_inv_addr;
back_inv  <=  an_ac_back_inv_l2 and an_ac_back_inv_target_l2;
back_inv_d  <=  back_inv;
iu_ierat_ium1_back_inv  <=  back_inv or (or_reduce(xu_icbi_buffer0_val_tid_d));
an_ac_icbi_ack_d  <=  an_ac_icbi_ack;
an_ac_icbi_ack_thread_d  <=  an_ac_icbi_ack_thread;
iu0_high_act  <=  spr_ic_clockgate_dis or
    or_reduce(high_mask_l2 or iu0_high_sent1_l2 or iu0_high_sent2_l2 or
              iu0_high_sent3_l2 or iu0_high_sent4_l2);
iu0_low_act  <=  spr_ic_clockgate_dis or
    or_reduce((low_mask_l2 and not high_mask_l2) or iu0_low_sent1_l2 or iu0_low_sent2_l2 or
              iu0_low_sent3_l2 or iu0_low_sent4_l2 or icm_ics_load_tid);
xu_icbi_buffer123_act  <=  (xu_icbi_buffer_val(0) and back_inv_l2) or xu_icbi_buffer_val(1);
xu_icbi_buffer0_act  <=  not (xu_icbi_buffer_val(0) and back_inv_l2);
xu_icbi_buffer_val(0) <=  or_reduce(xu_icbi_buffer0_val_tid_l2);
xu_icbi_buffer_val(1) <=  or_reduce(xu_icbi_buffer1_val_tid_l2);
xu_icbi_buffer_val(2) <=  or_reduce(xu_icbi_buffer2_val_tid_l2);
xu_icbi_buffer_val(3) <=  or_reduce(xu_icbi_buffer3_val_tid_l2);
xu_icbi_buffer0_val_tid_d  <=  xu_icbi_buffer0_val_tid_l2   when (xu_icbi_buffer_val(0) and back_inv_l2) = '1'
                        else xu_icbi_buffer1_val_tid_l2   when (xu_icbi_buffer_val(1) and not back_inv_l2) = '1'
                        else xu_iu_ex6_icbi_val;
xu_icbi_buffer1_val_tid_d  <=  xu_iu_ex6_icbi_val           when ((xu_icbi_buffer_val(0) and not xu_icbi_buffer_val(1) and back_inv_l2) or
                                                                (xu_icbi_buffer_val(1) and not xu_icbi_buffer_val(2) and not back_inv_l2)) = '1'
                        else xu_icbi_buffer2_val_tid_l2   when (xu_icbi_buffer_val(2) and not back_inv_l2) = '1'
                        else xu_icbi_buffer1_val_tid_l2;
xu_icbi_buffer2_val_tid_d  <=  xu_iu_ex6_icbi_val           when ((xu_icbi_buffer_val(1) and not xu_icbi_buffer_val(2) and back_inv_l2) or
                                                                (xu_icbi_buffer_val(2) and not xu_icbi_buffer_val(3) and not back_inv_l2)) = '1'
                        else xu_icbi_buffer3_val_tid_l2   when (xu_icbi_buffer_val(3) and not back_inv_l2) = '1'
                        else xu_icbi_buffer2_val_tid_l2;
xu_icbi_buffer3_val_tid_d  <=  xu_iu_ex6_icbi_val           when (xu_icbi_buffer_val(2) and not xu_icbi_buffer_val(3) and back_inv_l2) = '1'
                        else xu_icbi_buffer3_val_tid_l2   when back_inv_l2 = '1'
                        else "0000";
xu_icbi_buffer0_addr_d  <=  
                          xu_icbi_buffer1_addr_l2         when (xu_icbi_buffer_val(1) and not back_inv_l2) = '1'
                     else xu_iu_ex6_icbi_addr;
xu_icbi_buffer1_addr_d  <=  xu_iu_ex6_icbi_addr             when ((xu_icbi_buffer_val(0) and not xu_icbi_buffer_val(1) and back_inv_l2) or
                                                                (xu_icbi_buffer_val(1) and not xu_icbi_buffer_val(2) and not back_inv_l2)) = '1'
                     else xu_icbi_buffer2_addr_l2         when (xu_icbi_buffer_val(2) and not back_inv_l2) = '1'
                     else xu_icbi_buffer1_addr_l2;
xu_icbi_buffer2_addr_d  <=  xu_iu_ex6_icbi_addr             when ((xu_icbi_buffer_val(1) and not xu_icbi_buffer_val(2) and back_inv_l2) or
                                                                (xu_icbi_buffer_val(2) and not xu_icbi_buffer_val(3) and not back_inv_l2)) = '1'
                     else xu_icbi_buffer3_addr_l2         when (xu_icbi_buffer_val(3) and not back_inv_l2) = '1'
                     else xu_icbi_buffer2_addr_l2;
xu_icbi_buffer3_addr_d  <=  xu_iu_ex6_icbi_addr             when (xu_icbi_buffer_val(2) and not xu_icbi_buffer_val(3) and back_inv_l2) = '1'
                     else xu_icbi_buffer3_addr_l2;
 WITH s3'(an_ac_icbi_ack_l2 & an_ac_icbi_ack_thread_l2(0 to 1))  SELECT l2_icbi_ack  <=  "1000"   when "100",
               "0100"   when "101",
               "0010"   when "110",
               "0001"   when "111",
               "0000"   when others;
ic_fdep_icbi_ack  <=  l2_icbi_ack when spr_ic_icbi_ack_en_l2 = '1'
               else "0000"      when back_inv_l2 = '1'
               else xu_icbi_buffer0_val_tid_l2;
block_spr_idir_read  <=  iu0_inval or icm_ics_hold_iu0;
spr_idir_read_d  <=   spr_ic_idir_read or
                   (spr_idir_read_l2 and block_spr_idir_read);
spr_idir_row_d  <=  spr_ic_idir_row;
iu0_spr_idir_read  <=  spr_idir_read_l2 and not block_spr_idir_read;
ics_icd_iu0_spr_idir_read  <=  iu0_spr_idir_read;
iu1_icm_flush_tid  <=  (gate_and( (icd_ics_iu1_valid and icm_ics_iu1_ecc_flush) , icd_ics_iu1_tid)) and not all_stages_flush_prev_l2;
hold_iu0_v  <=  ( 0 to 3 => icm_ics_hold_iu0);
iu0_hold_ecc  <=  icm_ics_iu1_ecc_flush;
iu0_hold_ecc_v  <=  ( 0 to 3 => icm_ics_iu1_ecc_flush);
iu_ierat_iu0_flush  <=  uc_flush_tid or ib_ic_iu5_redirect_tid or bp_ic_iu5_redirect_tid or
                      icd_ics_iu3_parity_flush or icd_ics_iu2_miss_flush_prev or iu1_icm_flush_tid or  
                      hold_thread_iu0 or hold_iu0_v or iu0_hold_ecc_v;
iu_ierat_iu1_flush  <=  uc_flush_tid or ib_ic_iu5_redirect_tid or bp_ic_iu5_redirect_tid or
                      icd_ics_iu3_parity_flush or icd_ics_iu2_miss_flush_prev or iu1_icm_flush_tid;
all_stages_flush_tid  <=  xu_iu_flush or uc_flush_tid or ib_ic_iu5_redirect_tid or bp_ic_iu5_redirect_tid;
all_stages_flush_prev_d  <=  all_stages_flush_tid;
iu0_flush_tid  <=  icd_ics_iu3_parity_flush or ierat_iu_iu2_flush_req or icd_ics_iu2_miss_flush_prev or iu1_icm_flush_tid;
iu1_flush_tid  <=  icd_ics_iu3_parity_flush or ierat_iu_iu2_flush_req or icd_ics_iu2_miss_flush_prev or iu1_icm_flush_tid;
iu2_flush_tid(0) <=  icd_ics_iu3_parity_flush(0)   or (ierat_iu_iu2_flush_req(0)   and not ierat_iu_iu2_miss);
iu2_flush_tid(1) <=  icd_ics_iu3_parity_flush(1)   or (ierat_iu_iu2_flush_req(1)   and not ierat_iu_iu2_miss);
iu2_flush_tid(2) <=  icd_ics_iu3_parity_flush(2)   or (ierat_iu_iu2_flush_req(2)   and not ierat_iu_iu2_miss);
iu2_flush_tid(3) <=  icd_ics_iu3_parity_flush(3)   or (ierat_iu_iu2_flush_req(3)   and not ierat_iu_iu2_miss);
iu3_flush_tid  <=  icd_ics_iu3_parity_flush;
ics_icd_all_flush_prev  <=  all_stages_flush_prev_l2;
ics_icd_iu1_flush_tid  <=  iu1_flush_tid;
ics_icd_iu2_flush_tid  <=  iu2_flush_tid;
ics_icm_iu2_flush_tid  <=  iu2_flush_tid or all_stages_flush_tid;
ics_icm_iu3_flush_tid  <=  all_stages_flush_tid;
hold_thread_pre_iu0(0) <=  uc_ic_hold_thread(0)   or uc_flush_tid(0)   or
                           (bp_ic_iu5_hold_tid(0)   and not xu_iu_flush(0))   or
                            icm_ics_hold_thread(0);
hold_thread_pre_iu0(1) <=  uc_ic_hold_thread(1)   or uc_flush_tid(1)   or
                           (bp_ic_iu5_hold_tid(1)   and not xu_iu_flush(1))   or
                            icm_ics_hold_thread(1);
hold_thread_pre_iu0(2) <=  uc_ic_hold_thread(2)   or uc_flush_tid(2)   or
                           (bp_ic_iu5_hold_tid(2)   and not xu_iu_flush(2))   or
                            icm_ics_hold_thread(2);
hold_thread_pre_iu0(3) <=  uc_ic_hold_thread(3)   or uc_flush_tid(3)   or
                           (bp_ic_iu5_hold_tid(3)   and not xu_iu_flush(3))   or
                            icm_ics_hold_thread(3);
hold_thread_iu0(0) <=  not(xu_iu_run_thread_l2(0))   or ac_an_power_managed or ierat_iu_hold_req(0)   or icm_ics_ecc_block_iu0(0);
hold_thread_iu0(1) <=  not(xu_iu_run_thread_l2(1))   or ac_an_power_managed or ierat_iu_hold_req(1)   or icm_ics_ecc_block_iu0(1);
hold_thread_iu0(2) <=  not(xu_iu_run_thread_l2(2))   or ac_an_power_managed or ierat_iu_hold_req(2)   or icm_ics_ecc_block_iu0(2);
hold_thread_iu0(3) <=  not(xu_iu_run_thread_l2(3))   or ac_an_power_managed or ierat_iu_hold_req(3)   or icm_ics_ecc_block_iu0(3);
high_mask_d(0) <=  ((ib_ic_empty(0)   and not iu0_high_sentall4(0))   or xu_iu_flush(0))
    and not hold_thread_pre_iu0(0)   and not hold_thread_iu0(0)   and not back_inv and not (or_reduce(xu_icbi_buffer0_val_tid_d)) and not spr_idir_read_d;
high_mask_d(1) <=  ((ib_ic_empty(1)   and not iu0_high_sentall4(1))   or xu_iu_flush(1))
    and not hold_thread_pre_iu0(1)   and not hold_thread_iu0(1)   and not back_inv and not (or_reduce(xu_icbi_buffer0_val_tid_d)) and not spr_idir_read_d;
high_mask_d(2) <=  ((ib_ic_empty(2)   and not iu0_high_sentall4(2))   or xu_iu_flush(2))
    and not hold_thread_pre_iu0(2)   and not hold_thread_iu0(2)   and not back_inv and not (or_reduce(xu_icbi_buffer0_val_tid_d)) and not spr_idir_read_d;
high_mask_d(3) <=  ((ib_ic_empty(3)   and not iu0_high_sentall4(3))   or xu_iu_flush(3))
    and not hold_thread_pre_iu0(3)   and not hold_thread_iu0(3)   and not back_inv and not (or_reduce(xu_icbi_buffer0_val_tid_d)) and not spr_idir_read_d;
low_mask_d(0) <=  ib_ic_below_water(0)   and not iu0_low_sentall4(0)   and
    (ib_ic_empty(0)   or not iu0_high_sentall4(0))   and
    not hold_thread_pre_iu0(0)   and not hold_thread_iu0(0)   and not back_inv and not (or_reduce(xu_icbi_buffer0_val_tid_d)) and not spr_idir_read_d;
low_mask_d(1) <=  ib_ic_below_water(1)   and not iu0_low_sentall4(1)   and
    (ib_ic_empty(1)   or not iu0_high_sentall4(1))   and
    not hold_thread_pre_iu0(1)   and not hold_thread_iu0(1)   and not back_inv and not (or_reduce(xu_icbi_buffer0_val_tid_d)) and not spr_idir_read_d;
low_mask_d(2) <=  ib_ic_below_water(2)   and not iu0_low_sentall4(2)   and
    (ib_ic_empty(2)   or not iu0_high_sentall4(2))   and
    not hold_thread_pre_iu0(2)   and not hold_thread_iu0(2)   and not back_inv and not (or_reduce(xu_icbi_buffer0_val_tid_d)) and not spr_idir_read_d;
low_mask_d(3) <=  ib_ic_below_water(3)   and not iu0_low_sentall4(3)   and
    (ib_ic_empty(3)   or not iu0_high_sentall4(3))   and
    not hold_thread_pre_iu0(3)   and not hold_thread_iu0(3)   and not back_inv and not (or_reduce(xu_icbi_buffer0_val_tid_d)) and not spr_idir_read_d;
next_low_valid   <=  or_reduce(low_mask_l2) and not or_reduce(high_mask_l2);
next_high_valid  <=  or_reduce(high_mask_l2);
highpri_v_b0      <=  not high_mask_l2;
medpri_v_b0       <=  not low_mask_l2;
highpri0v_inv:  highpri_v(0) <=  not highpri_v_b0(0);
highpri1v_inv:  highpri_v(1) <=  not highpri_v_b0(1);
highpri2v_inv:  highpri_v(2) <=  not highpri_v_b0(2);
highpri3v_inv:  highpri_v(3) <=  not highpri_v_b0(3);
highpri0vb_inv: highpri_v_b(0) <=  not highpri_v(0);
highpri1vb_inv: highpri_v_b(1) <=  not highpri_v(1);
highpri2vb_inv: highpri_v_b(2) <=  not highpri_v(2);
highpri3vb_inv: highpri_v_b(3) <=  not highpri_v(3);
hi_sel_nor23:   hi_sel(3) <=  not (highpri_v_b(3) or hi_later(3));
hi_sel_nand33:  hi_later(3) <=  not (hi_l30 and hi_l31 and hi_l32);
hi_sel_nand230: hi_l30           <=  not (hi_did3no0 and highpri_v(0));
hi_sel_nand231: hi_l31           <=  not (hi_did3no1 and highpri_v(1));
hi_sel_nand232: hi_l32           <=  not (hi_did3no2 and highpri_v(2));
hi_sel_nor22:   hi_sel(2) <=  not (highpri_v_b(2) or hi_later(2));
hi_sel_nand32:  hi_later(2) <=  not (hi_l23 and hi_l20 and hi_l21);
hi_sel_nand223: hi_l23           <=  not (hi_did2no3 and highpri_v(3));
hi_sel_nand220: hi_l20           <=  not (hi_did2no0 and highpri_v(0));
hi_sel_nand221: hi_l21           <=  not (hi_did2no1 and highpri_v(1));
hi_sel_nor21:   hi_sel(1) <=  not (highpri_v_b(1) or hi_later(1));
hi_sel_nand31:  hi_later(1) <=  not (hi_l12 and hi_l13 and hi_l10);
hi_sel_nand212: hi_l12           <=  not (hi_did1no2 and highpri_v(2));
hi_sel_nand213: hi_l13           <=  not (hi_did1no3 and highpri_v(3));
hi_sel_nand210: hi_l10           <=  not (hi_did1no0 and highpri_v(0));
hi_sel_nor20:   hi_sel(0) <=  not (highpri_v_b(0) or hi_later(0));
hi_sel_nand30:  hi_later(0) <=  not (hi_l01 and hi_l02 and hi_l03);
hi_sel_nand201: hi_l01           <=  not (hi_did0no1 and highpri_v(1));
hi_sel_nand202: hi_l02           <=  not (hi_did0no2 and highpri_v(2));
hi_sel_nand203: hi_l03           <=  not (hi_did0no3 and highpri_v(3));
medpri0v_inv:   medpri_v(0) <=  not medpri_v_b0(0);
medpri1v_inv:   medpri_v(1) <=  not medpri_v_b0(1);
medpri2v_inv:   medpri_v(2) <=  not medpri_v_b0(2);
medpri3v_inv:   medpri_v(3) <=  not medpri_v_b0(3);
medpri0vb_inv:  medpri_v_b(0) <=  not medpri_v(0);
medpri1vb_inv:  medpri_v_b(1) <=  not medpri_v(1);
medpri2vb_inv:  medpri_v_b(2) <=  not medpri_v(2);
medpri3vb_inv:  medpri_v_b(3) <=  not medpri_v(3);
md_sel_nor23:   md_sel(3) <=  not (medpri_v_b(3) or md_later(3));
md_sel_nand33:  md_later(3) <=  not (md_l30 and md_l31 and md_l32);
md_sel_nand230: md_l30           <=  not (md_did3no0 and medpri_v(0));
md_sel_nand231: md_l31           <=  not (md_did3no1 and medpri_v(1));
md_sel_nand232: md_l32           <=  not (md_did3no2 and medpri_v(2));
md_sel_nor22:   md_sel(2) <=  not (medpri_v_b(2) or md_later(2));
md_sel_nand32:  md_later(2) <=  not (md_l23 and md_l20 and md_l21);
md_sel_nand223: md_l23           <=  not (md_did2no3 and medpri_v(3));
md_sel_nand220: md_l20           <=  not (md_did2no0 and medpri_v(0));
md_sel_nand221: md_l21           <=  not (md_did2no1 and medpri_v(1));
md_sel_nor21:   md_sel(1) <=  not (medpri_v_b(1) or md_later(1));
md_sel_nand31:  md_later(1) <=  not (md_l12 and md_l13 and md_l10);
md_sel_nand212: md_l12           <=  not (md_did1no2 and medpri_v(2));
md_sel_nand213: md_l13           <=  not (md_did1no3 and medpri_v(3));
md_sel_nand210: md_l10           <=  not (md_did1no0 and medpri_v(0));
md_sel_nor20:   md_sel(0) <=  not (medpri_v_b(0) or md_later(0));
md_sel_nand30:  md_later(0) <=  not (md_l01 and md_l02 and md_l03);
md_sel_nand201: md_l01           <=  not (md_did0no1 and medpri_v(1));
md_sel_nand202: md_l02           <=  not (md_did0no2 and medpri_v(2));
md_sel_nand203: md_l03           <=  not (md_did0no3 and medpri_v(3));
hi_sel_inv0:            hi_sel_b(0) <=  not hi_sel(0);
hi_sel_inv1:            hi_sel_b(1) <=  not hi_sel(1);
hi_sel_inv2:            hi_sel_b(2) <=  not hi_sel(2);
hi_sel_inv3:            hi_sel_b(3) <=  not hi_sel(3);
hi_reordf_nand230:      hi_did3no0_din   <=  not (hi_sel_b(3) and hi_n230);
hi_reordf_nand231:      hi_did3no1_din   <=  not (hi_sel_b(3) and hi_n231);
hi_reordf_nand232:      hi_did3no2_din   <=  not (hi_sel_b(3) and hi_n232);
hi_reord_nand230:       hi_n230          <=  not (hi_sel_b(0) and hi_did3no0);
hi_reord_nand231:       hi_n231          <=  not (hi_sel_b(1) and hi_did3no1);
hi_reord_nand232:       hi_n232          <=  not (hi_sel_b(2) and hi_did3no2);
hi_reordf_nand220:      hi_did2no0_din   <=  not(hi_sel_b(2) and hi_n220);
hi_reord_nand220:       hi_n220          <=  not(hi_sel_b(0) and hi_did2no0);
hi_reordf_nand221:      hi_did2no1_din   <=  not(hi_sel_b(2) and hi_n221);
hi_reord_nand221:       hi_n221          <=  not(hi_sel_b(1) and hi_did2no1);
hi_reord_inv23:         hi_did2no3       <=  not hi_did3no2;
hi_reordf_nand210:      hi_did1no0_din   <=  not(hi_sel_b(1) and hi_n210);
hi_reord_nand210:       hi_n210          <=  not(hi_sel_b(0) and hi_did1no0);
hi_reord_inv12:         hi_did1no2       <=  not hi_did2no1;
hi_reord_inv13:         hi_did1no3       <=  not hi_did3no1;
hi_reord_inv01:         hi_did0no1       <=  not hi_did1no0;
hi_reord_inv02:         hi_did0no2       <=  not hi_did2no0;
hi_reord_inv03:         hi_did0no3       <=  not hi_did3no0;
md_sel_inv0:            md_sel_b(0) <=  not md_sel(0);
md_sel_inv1:            md_sel_b(1) <=  not md_sel(1);
md_sel_inv2:            md_sel_b(2) <=  not md_sel(2);
md_sel_inv3:            md_sel_b(3) <=  not md_sel(3);
md_reordf_nand230:      md_did3no0_din   <=  not (md_sel_b(3) and md_n230);
md_reordf_nand231:      md_did3no1_din   <=  not (md_sel_b(3) and md_n231);
md_reordf_nand232:      md_did3no2_din   <=  not (md_sel_b(3) and md_n232);
md_reord_nand230:       md_n230          <=  not (md_sel_b(0) and md_did3no0);
md_reord_nand231:       md_n231          <=  not (md_sel_b(1) and md_did3no1);
md_reord_nand232:       md_n232          <=  not (md_sel_b(2) and md_did3no2);
md_reordf_nand220:      md_did2no0_din   <=  not(md_sel_b(2) and md_n220);
md_reord_nand220:       md_n220          <=  not(md_sel_b(0) and md_did2no0);
md_reordf_nand221:      md_did2no1_din   <=  not(md_sel_b(2) and md_n221);
md_reord_nand221:       md_n221          <=  not(md_sel_b(1) and md_did2no1);
md_reord_inv23:         md_did2no3       <=  not md_did3no2;
md_reordf_nand210:      md_did1no0_din   <=  not(md_sel_b(1) and md_n210);
md_reord_nand210:       md_n210          <=  not(md_sel_b(0) and md_did1no0);
md_reord_inv12:         md_did1no2       <=  not md_did2no1;
md_reord_inv13:         md_did1no3       <=  not md_did3no1;
md_reord_inv01:         md_did0no1       <=  not md_did1no0;
md_reord_inv02:         md_did0no2       <=  not md_did2no0;
md_reord_inv03:         md_did0no3       <=  not md_did3no0;
nohi_nor21:     no_hi_v_n01              <=  not (highpri_v(0) or highpri_v(1));
nohi_nor22:     no_hi_v_n23              <=  not (highpri_v(2) or highpri_v(3));
nohi_nand2:     no_hi_v_b                <=  not (no_hi_v_n01 and no_hi_v_n23);
nohi_inv:       no_hi_v                  <=  not (no_hi_v_b);
isssel0_inv:    issselhi_b(0) <=  not (hi_sel(0));
isssel1_inv:    issselhi_b(1) <=  not (hi_sel(1));
isssel2_inv:    issselhi_b(2) <=  not (hi_sel(2));
isssel3_inv:    issselhi_b(3) <=  not (hi_sel(3));
isssel0_bnand2: issselmd_b(0) <=  not (md_sel(0) and no_hi_v);
isssel1_bnand2: issselmd_b(1) <=  not (md_sel(1) and no_hi_v);
isssel2_bnand2: issselmd_b(2) <=  not (md_sel(2) and no_hi_v);
isssel3_bnand2: issselmd_b(3) <=  not (md_sel(3) and no_hi_v);
nexttid0_fnand2: next_tid(0) <=  not (issselhi_b(0) and issselmd_b(0));
nexttid1_fnand2: next_tid(1) <=  not (issselhi_b(1) and issselmd_b(1));
nexttid2_fnand2: next_tid(2) <=  not (issselhi_b(2) and issselmd_b(2));
nexttid3_fnand2: next_tid(3) <=  not (issselhi_b(3) and issselmd_b(3));
iu0_ifar_early_proc: process(
                          ib_ic_iu5_redirect_tid, iu5_ifar_l2,
                          bp_ic_iu5_redirect_tid, bp_ic_iu5_redirect_ifar,
                          icd_ics_iu3_parity_flush, icd_ics_iu3_ifar, icd_ics_iu3_2ucode, icd_ics_iu3_2ucode_type,
                          ierat_iu_iu2_flush_req, icd_ics_iu2_2ucode, icd_ics_iu2_2ucode_type,
                          icd_ics_iu2_miss_flush_prev, icd_ics_iu2_ifar_eff, icm_ics_iu2_miss_match_prev,
                          iu1_icm_flush_tid, icd_ics_iu1_ifar, icd_ics_iu1_2ucode, icd_ics_iu1_2ucode_type,
                          icm_ics_hold_iu0, hold_thread_iu0, iu0_hold_ecc,
                          next_tid, iu0_2ucode_l2, iu0_2ucode_type_l2,
                          iu0_ifar0_l2, iu0_ifar1_l2, iu0_ifar2_l2, iu0_ifar3_l2 )
begin
if (ib_ic_iu5_redirect_tid(0)   = '1') then
iu0_ifar0_early    <=  iu5_ifar_l2;
iu0_2ucode_early(0) <=  '0';
iu0_2ucode_type_early(0) <=  '0';
elsif (bp_ic_iu5_redirect_tid(0)   = '1') then
iu0_ifar0_early    <=  bp_ic_iu5_redirect_ifar;
iu0_2ucode_early(0) <=  '0';
iu0_2ucode_type_early(0) <=  '0';
elsif ((icd_ics_iu3_parity_flush(0)   or
            (icd_ics_iu2_miss_flush_prev(0)   and icm_ics_iu2_miss_match_prev)) = '1') then
iu0_ifar0_early    <=  icd_ics_iu3_ifar;
iu0_2ucode_early(0) <=  icd_ics_iu3_2ucode;
iu0_2ucode_type_early(0) <=  icd_ics_iu3_2ucode_type;
elsif (icd_ics_iu2_miss_flush_prev(0)   = '1') then
iu0_ifar0_early    <=  (icd_ics_iu3_ifar(EFF_IFAR'left to 59) + 1) & "00";
iu0_2ucode_early(0) <=  '0';
iu0_2ucode_type_early(0) <=  '0';
elsif (ierat_iu_iu2_flush_req(0)   = '1') then
iu0_ifar0_early    <=  icd_ics_iu2_ifar_eff;
iu0_2ucode_early(0) <=  icd_ics_iu2_2ucode;
iu0_2ucode_type_early(0) <=  icd_ics_iu2_2ucode_type;
elsif (iu1_icm_flush_tid(0)   = '1') then
iu0_ifar0_early    <=  icd_ics_iu1_ifar;
iu0_2ucode_early(0) <=  icd_ics_iu1_2ucode;
iu0_2ucode_type_early(0) <=  icd_ics_iu1_2ucode_type;
elsif ((next_tid(0)   and not icm_ics_hold_iu0 and not hold_thread_iu0(0)   and not iu0_hold_ecc) = '1') then
iu0_ifar0_early    <=  (iu0_ifar0_l2(EFF_IFAR'left   to 59) + 1) & "00";
iu0_2ucode_early(0) <=  '0';
iu0_2ucode_type_early(0) <=  '0';
else
iu0_ifar0_early    <=  iu0_ifar0_l2;
iu0_2ucode_early(0) <=  iu0_2ucode_l2(0);
iu0_2ucode_type_early(0) <=  iu0_2ucode_type_l2(0);
end if;
if (ib_ic_iu5_redirect_tid(1)   = '1') then
iu0_ifar1_early    <=  iu5_ifar_l2;
iu0_2ucode_early(1) <=  '0';
iu0_2ucode_type_early(1) <=  '0';
elsif (bp_ic_iu5_redirect_tid(1)   = '1') then
iu0_ifar1_early    <=  bp_ic_iu5_redirect_ifar;
iu0_2ucode_early(1) <=  '0';
iu0_2ucode_type_early(1) <=  '0';
elsif ((icd_ics_iu3_parity_flush(1)   or
            (icd_ics_iu2_miss_flush_prev(1)   and icm_ics_iu2_miss_match_prev)) = '1') then
iu0_ifar1_early    <=  icd_ics_iu3_ifar;
iu0_2ucode_early(1) <=  icd_ics_iu3_2ucode;
iu0_2ucode_type_early(1) <=  icd_ics_iu3_2ucode_type;
elsif (icd_ics_iu2_miss_flush_prev(1)   = '1') then
iu0_ifar1_early    <=  (icd_ics_iu3_ifar(EFF_IFAR'left to 59) + 1) & "00";
iu0_2ucode_early(1) <=  '0';
iu0_2ucode_type_early(1) <=  '0';
elsif (ierat_iu_iu2_flush_req(1)   = '1') then
iu0_ifar1_early    <=  icd_ics_iu2_ifar_eff;
iu0_2ucode_early(1) <=  icd_ics_iu2_2ucode;
iu0_2ucode_type_early(1) <=  icd_ics_iu2_2ucode_type;
elsif (iu1_icm_flush_tid(1)   = '1') then
iu0_ifar1_early    <=  icd_ics_iu1_ifar;
iu0_2ucode_early(1) <=  icd_ics_iu1_2ucode;
iu0_2ucode_type_early(1) <=  icd_ics_iu1_2ucode_type;
elsif ((next_tid(1)   and not icm_ics_hold_iu0 and not hold_thread_iu0(1)   and not iu0_hold_ecc) = '1') then
iu0_ifar1_early    <=  (iu0_ifar1_l2(EFF_IFAR'left   to 59) + 1) & "00";
iu0_2ucode_early(1) <=  '0';
iu0_2ucode_type_early(1) <=  '0';
else
iu0_ifar1_early    <=  iu0_ifar1_l2;
iu0_2ucode_early(1) <=  iu0_2ucode_l2(1);
iu0_2ucode_type_early(1) <=  iu0_2ucode_type_l2(1);
end if;
if (ib_ic_iu5_redirect_tid(2)   = '1') then
iu0_ifar2_early    <=  iu5_ifar_l2;
iu0_2ucode_early(2) <=  '0';
iu0_2ucode_type_early(2) <=  '0';
elsif (bp_ic_iu5_redirect_tid(2)   = '1') then
iu0_ifar2_early    <=  bp_ic_iu5_redirect_ifar;
iu0_2ucode_early(2) <=  '0';
iu0_2ucode_type_early(2) <=  '0';
elsif ((icd_ics_iu3_parity_flush(2)   or
            (icd_ics_iu2_miss_flush_prev(2)   and icm_ics_iu2_miss_match_prev)) = '1') then
iu0_ifar2_early    <=  icd_ics_iu3_ifar;
iu0_2ucode_early(2) <=  icd_ics_iu3_2ucode;
iu0_2ucode_type_early(2) <=  icd_ics_iu3_2ucode_type;
elsif (icd_ics_iu2_miss_flush_prev(2)   = '1') then
iu0_ifar2_early    <=  (icd_ics_iu3_ifar(EFF_IFAR'left to 59) + 1) & "00";
iu0_2ucode_early(2) <=  '0';
iu0_2ucode_type_early(2) <=  '0';
elsif (ierat_iu_iu2_flush_req(2)   = '1') then
iu0_ifar2_early    <=  icd_ics_iu2_ifar_eff;
iu0_2ucode_early(2) <=  icd_ics_iu2_2ucode;
iu0_2ucode_type_early(2) <=  icd_ics_iu2_2ucode_type;
elsif (iu1_icm_flush_tid(2)   = '1') then
iu0_ifar2_early    <=  icd_ics_iu1_ifar;
iu0_2ucode_early(2) <=  icd_ics_iu1_2ucode;
iu0_2ucode_type_early(2) <=  icd_ics_iu1_2ucode_type;
elsif ((next_tid(2)   and not icm_ics_hold_iu0 and not hold_thread_iu0(2)   and not iu0_hold_ecc) = '1') then
iu0_ifar2_early    <=  (iu0_ifar2_l2(EFF_IFAR'left   to 59) + 1) & "00";
iu0_2ucode_early(2) <=  '0';
iu0_2ucode_type_early(2) <=  '0';
else
iu0_ifar2_early    <=  iu0_ifar2_l2;
iu0_2ucode_early(2) <=  iu0_2ucode_l2(2);
iu0_2ucode_type_early(2) <=  iu0_2ucode_type_l2(2);
end if;
if (ib_ic_iu5_redirect_tid(3)   = '1') then
iu0_ifar3_early    <=  iu5_ifar_l2;
iu0_2ucode_early(3) <=  '0';
iu0_2ucode_type_early(3) <=  '0';
elsif (bp_ic_iu5_redirect_tid(3)   = '1') then
iu0_ifar3_early    <=  bp_ic_iu5_redirect_ifar;
iu0_2ucode_early(3) <=  '0';
iu0_2ucode_type_early(3) <=  '0';
elsif ((icd_ics_iu3_parity_flush(3)   or
            (icd_ics_iu2_miss_flush_prev(3)   and icm_ics_iu2_miss_match_prev)) = '1') then
iu0_ifar3_early    <=  icd_ics_iu3_ifar;
iu0_2ucode_early(3) <=  icd_ics_iu3_2ucode;
iu0_2ucode_type_early(3) <=  icd_ics_iu3_2ucode_type;
elsif (icd_ics_iu2_miss_flush_prev(3)   = '1') then
iu0_ifar3_early    <=  (icd_ics_iu3_ifar(EFF_IFAR'left to 59) + 1) & "00";
iu0_2ucode_early(3) <=  '0';
iu0_2ucode_type_early(3) <=  '0';
elsif (ierat_iu_iu2_flush_req(3)   = '1') then
iu0_ifar3_early    <=  icd_ics_iu2_ifar_eff;
iu0_2ucode_early(3) <=  icd_ics_iu2_2ucode;
iu0_2ucode_type_early(3) <=  icd_ics_iu2_2ucode_type;
elsif (iu1_icm_flush_tid(3)   = '1') then
iu0_ifar3_early    <=  icd_ics_iu1_ifar;
iu0_2ucode_early(3) <=  icd_ics_iu1_2ucode;
iu0_2ucode_type_early(3) <=  icd_ics_iu1_2ucode_type;
elsif ((next_tid(3)   and not icm_ics_hold_iu0 and not hold_thread_iu0(3)   and not iu0_hold_ecc) = '1') then
iu0_ifar3_early    <=  (iu0_ifar3_l2(EFF_IFAR'left   to 59) + 1) & "00";
iu0_2ucode_early(3) <=  '0';
iu0_2ucode_type_early(3) <=  '0';
else
iu0_ifar3_early    <=  iu0_ifar3_l2;
iu0_2ucode_early(3) <=  iu0_2ucode_l2(3);
iu0_2ucode_type_early(3) <=  iu0_2ucode_type_l2(3);
end if;
end process;
iu0_ifar0_mux:   
iu0_ifar0_pre_cm    <=  xu_iu_iu0_flush_ifar0     when xu_iu_flush(0)   = '1'
                 else iu0_ifar0_early;
iu0_ifar0:   for i in EFF_IFAR'left to EFF_IFAR'right generate
begin
  R0:if(i <  32) generate begin iu0_ifar0_d(i)   <= iu0_ifar0_pre_cm(i)   and xu_iu_msr_cm(0);
end generate;
R1:if(i >= 32) generate
begin iu0_ifar0_d(i) <=  iu0_ifar0_pre_cm(i);
end generate;
end generate;
iu0_2ucode0_mux:
iu0_2ucode_d(0) <=  xu_iu_flush_2ucode(0)    when xu_iu_flush(0)   = '1'
                else iu0_2ucode_early(0);
iu0_2ucode_type0_mux:
iu0_2ucode_type_d(0) <=  xu_iu_flush_2ucode_type(0)    when xu_iu_flush(0)   = '1'
                     else iu0_2ucode_type_early(0);
iu0_ifar1_mux:   
iu0_ifar1_pre_cm    <=  xu_iu_iu0_flush_ifar1     when xu_iu_flush(1)   = '1'
                 else iu0_ifar1_early;
iu0_ifar1:   for i in EFF_IFAR'left to EFF_IFAR'right generate
begin
  R0:if(i <  32) generate begin iu0_ifar1_d(i)   <= iu0_ifar1_pre_cm(i)   and xu_iu_msr_cm(1);
end generate;
R1:if(i >= 32) generate
begin iu0_ifar1_d(i) <=  iu0_ifar1_pre_cm(i);
end generate;
end generate;
iu0_2ucode1_mux:
iu0_2ucode_d(1) <=  xu_iu_flush_2ucode(1)    when xu_iu_flush(1)   = '1'
                else iu0_2ucode_early(1);
iu0_2ucode_type1_mux:
iu0_2ucode_type_d(1) <=  xu_iu_flush_2ucode_type(1)    when xu_iu_flush(1)   = '1'
                     else iu0_2ucode_type_early(1);
iu0_ifar2_mux:   
iu0_ifar2_pre_cm    <=  xu_iu_iu0_flush_ifar2     when xu_iu_flush(2)   = '1'
                 else iu0_ifar2_early;
iu0_ifar2:   for i in EFF_IFAR'left to EFF_IFAR'right generate
begin
  R0:if(i <  32) generate begin iu0_ifar2_d(i)   <= iu0_ifar2_pre_cm(i)   and xu_iu_msr_cm(2);
end generate;
R1:if(i >= 32) generate
begin iu0_ifar2_d(i) <=  iu0_ifar2_pre_cm(i);
end generate;
end generate;
iu0_2ucode2_mux:
iu0_2ucode_d(2) <=  xu_iu_flush_2ucode(2)    when xu_iu_flush(2)   = '1'
                else iu0_2ucode_early(2);
iu0_2ucode_type2_mux:
iu0_2ucode_type_d(2) <=  xu_iu_flush_2ucode_type(2)    when xu_iu_flush(2)   = '1'
                     else iu0_2ucode_type_early(2);
iu0_ifar3_mux:   
iu0_ifar3_pre_cm    <=  xu_iu_iu0_flush_ifar3     when xu_iu_flush(3)   = '1'
                 else iu0_ifar3_early;
iu0_ifar3:   for i in EFF_IFAR'left to EFF_IFAR'right generate
begin
  R0:if(i <  32) generate begin iu0_ifar3_d(i)   <= iu0_ifar3_pre_cm(i)   and xu_iu_msr_cm(3);
end generate;
R1:if(i >= 32) generate
begin iu0_ifar3_d(i) <=  iu0_ifar3_pre_cm(i);
end generate;
end generate;
iu0_2ucode3_mux:
iu0_2ucode_d(3) <=  xu_iu_flush_2ucode(3)    when xu_iu_flush(3)   = '1'
                else iu0_2ucode_early(3);
iu0_2ucode_type3_mux:
iu0_2ucode_type_d(3) <=  xu_iu_flush_2ucode_type(3)    when xu_iu_flush(3)   = '1'
                     else iu0_2ucode_type_early(3);
ics_icm_iu0_ifar0    <=  iu0_ifar0_l2(46   to 52);
ics_icm_iu0_ifar1    <=  iu0_ifar1_l2(46   to 52);
ics_icm_iu0_ifar2    <=  iu0_ifar2_l2(46   to 52);
ics_icm_iu0_ifar3    <=  iu0_ifar3_l2(46   to 52);
iu0_early_valid  <=  next_high_valid or next_low_valid;
iu0_valid  <=  iu0_early_valid and not icm_ics_hold_iu0 and not iu0_hold_ecc and not or_reduce((iu0_flush_tid or hold_thread_iu0) and next_tid);
ics_icd_iu0_valid  <=  iu0_valid;
ics_icd_iu0_tid  <=  next_tid;
last_sent_proc: process(next_high_valid, next_low_valid, next_tid, icm_ics_hold_iu0, hold_thread_iu0,
                        iu0_flush_tid, iu0_hold_ecc )
begin
iu0_high_sent1_d  <=  "0000";
iu0_low_sent1_d  <=  "0000";
if(next_high_valid = '1' and (icm_ics_hold_iu0 = '0' and iu0_hold_ecc = '0' and (or_reduce(hold_thread_iu0 and next_tid)) = '0')) then
iu0_high_sent1_d  <=  next_tid and not iu0_flush_tid;
elsif (next_low_valid = '1' and (icm_ics_hold_iu0 = '0' and iu0_hold_ecc = '0' and (or_reduce(hold_thread_iu0 and next_tid)) = '0')) then
iu0_low_sent1_d  <=  next_tid and not iu0_flush_tid;
end if;
end process;
iu0_high_sent2_d  <=  iu0_high_sent1_l2 and not iu1_flush_tid and not all_stages_flush_prev_l2;
iu0_low_sent2_d  <=  iu0_low_sent1_l2 and not iu1_flush_tid and not all_stages_flush_prev_l2;
iu0_high_sent3_d  <=  iu0_high_sent2_l2 and not iu2_flush_tid and not icd_ics_iu2_miss_flush_prev and not all_stages_flush_prev_l2;
iu0_low_sent3_d  <=  ((iu0_low_sent2_l2 and not iu2_flush_tid and not icd_ics_iu2_miss_flush_prev) or icm_ics_load_tid) and not all_stages_flush_prev_l2;
iu0_high_sent4_d  <=  iu0_high_sent3_l2 and not iu3_flush_tid and not icd_ics_iu2_miss_flush_prev and not all_stages_flush_prev_l2;
iu0_low_sent4_d  <=  iu0_low_sent3_l2 and not iu3_flush_tid and not icd_ics_iu2_miss_flush_prev and not all_stages_flush_prev_l2;
iu0_high_sentall4  <=   not bp_ic_iu5_redirect_tid and not ib_ic_iu5_redirect_tid and
                     (iu0_high_sent1_d or
                      (((iu0_high_sent1_l2 and not iu1_flush_tid) or
                        (iu0_high_sent2_l2 and not (iu2_flush_tid or icd_ics_iu2_miss_flush_prev)) or
                        (iu0_high_sent3_l2 and not (iu3_flush_tid or icd_ics_iu2_miss_flush_prev)) or
                        (iu0_high_sent4_l2)) and not all_stages_flush_prev_l2));
iu0_low_sentall4  <=   not bp_ic_iu5_redirect_tid and not ib_ic_iu5_redirect_tid and
                    (iu0_low_sent1_d or
                     (((iu0_low_sent1_l2 and not iu1_flush_tid) or
                       (iu0_low_sent2_l2 and not (iu2_flush_tid or icd_ics_iu2_miss_flush_prev)) or
                       (icm_ics_load_tid and not iu3_flush_tid) or
                       (iu0_low_sent3_l2 and not (iu3_flush_tid or icd_ics_iu2_miss_flush_prev)) or
                       (iu0_low_sent4_l2)) and not all_stages_flush_prev_l2));
R0: if (EFF_IFAR'left < REAL_IFAR'left) generate
begin
      back_inv_addr_ext(EFF_IFAR'left TO REAL_IFAR'left-1) <=  (others => '0');
end generate;
back_inv_addr_ext(REAL_IFAR'left TO 57) <=  an_ac_back_inv_addr_l2;
R1: if (EFF_IFAR'left < REAL_IFAR'left) generate
begin
      xu_icbi_addr_ext(EFF_IFAR'left TO REAL_IFAR'left-1) <=  (others => '0');
end generate;
xu_icbi_addr_ext(REAL_IFAR'left TO 57) <=  xu_icbi_buffer0_addr_l2;
iu0_inval  <=  back_inv_l2 or xu_icbi_buffer_val(0);
ics_icd_iu0_inval  <=  iu0_inval;
ics_icm_iu0_inval  <=  iu0_inval;
ics_icm_iu0_inval_addr  <=  an_ac_back_inv_addr_l2(52 to 57) when back_inv_l2_clone = '1'
                     else xu_icbi_buffer0_addr_l2(52 to 57);
iu0_ifar0_or_back_inv_addr(EFF_IFAR'left TO 51) <= 
                    back_inv_addr_ext(EFF_IFAR'left to 51)   when back_inv_l2 = '1'
               else xu_icbi_addr_ext(EFF_IFAR'left to 51)    when xu_icbi_buffer_val(0) = '1'
               else iu0_ifar0_l2(EFF_IFAR'left to 51);
iu0_ifar0_or_back_inv_addr(52 TO 57) <= 
                    back_inv_addr_ext(52 to 57)   when back_inv_l2 = '1'
               else xu_icbi_addr_ext(52 to 57)    when xu_icbi_buffer_val(0) = '1'
               else spr_idir_row_l2(52 to 57)     when spr_idir_read_l2 = '1'
               else iu0_ifar0_l2(52 to 57);
iu0_ifar0_or_back_inv_addr(58 TO 61) <=  iu0_ifar0_l2(58 to 61);
select_iu0_ifar0  <=  next_tid(0) or iu0_inval or spr_idir_read_l2;
iu0_ifar  <= 
      gate_and( select_iu0_ifar0, iu0_ifar0_or_back_inv_addr) or
      gate_and( next_tid(1),   iu0_ifar1_l2)   or
      gate_and( next_tid(2),   iu0_ifar2_l2)   or
      gate_and( next_tid(3), iu0_ifar3_l2);
ics_icd_iu0_ifar  <=  iu0_ifar;
iu0_2ucode  <=  or_reduce(next_tid and iu0_2ucode_l2);
iu0_2ucode_type  <=  or_reduce(next_tid and iu0_2ucode_type_l2);
ics_icd_iu0_2ucode  <=  iu0_2ucode;
ics_icd_iu0_2ucode_type  <=  iu0_2ucode_type;
iu1_bp_val_d  <=  icm_ics_iu0_preload_val or iu0_valid;
iu1_bp_tid_d  <=  icm_ics_iu0_preload_tid   when icm_ics_iu0_preload_val = '1'
           else next_tid;
iu1_bp_ifar_d  <=  icm_ics_iu0_preload_ifar when icm_ics_iu0_preload_val = '1'
            else iu0_ifar(52 to 59);
iu1_bp_act  <=  spr_ic_clockgate_dis or
              icm_ics_iu0_preload_val or (iu0_early_valid and not icm_ics_hold_iu0 and not iu0_hold_ecc);
ic_bp_iu1_val  <=  iu1_bp_val_l2;
ic_bp_iu1_tid  <=  iu1_bp_tid_d;
ic_bp_iu1_ifar  <=  iu1_bp_ifar_l2(52 to 59);
iu_ierat_iu0_val  <=  iu0_early_valid;
iu_ierat_iu0_thdid  <=  next_tid;
ierat_ifar: for i in 0 to 51 generate
begin
  R0:if(i <  EFF_IFAR'left) generate begin iu_ierat_iu0_ifar(i) <= '0';
end generate;
R1:if(i >= EFF_IFAR'left) generate
begin iu_ierat_iu0_ifar(i) <=  iu0_ifar(i);
end generate;
end generate;
ics_icd_dir_rd_act  <=  (iu0_early_valid and not icm_ics_hold_iu0 and not iu0_hold_ecc) or back_inv_l2 or xu_icbi_buffer_val(0) or
    spr_idir_read_l2;
ics_icd_data_rd_act  <=  iu0_early_valid;
perf_event_t0_d(2) <=  (high_mask_l2(0)   or low_mask_l2(0))   and icm_ics_hold_iu0;
perf_event_t1_d(2) <=  (high_mask_l2(1)   or low_mask_l2(1))   and icm_ics_hold_iu0;
perf_event_t2_d(2) <=  (high_mask_l2(2)   or low_mask_l2(2))   and icm_ics_hold_iu0;
perf_event_t3_d(2) <=  (high_mask_l2(3)   or low_mask_l2(3))   and icm_ics_hold_iu0;
perf_event_t0_d(3) <=  all_stages_flush_tid(0)   or iu0_flush_tid(0);
perf_event_t1_d(3) <=  all_stages_flush_tid(1)   or iu0_flush_tid(1);
perf_event_t2_d(3) <=  all_stages_flush_tid(2)   or iu0_flush_tid(2);
perf_event_t3_d(3) <=  all_stages_flush_tid(3)   or iu0_flush_tid(3);
ic_perf_event_t0    <=  perf_event_t0_l2;
ic_perf_event_t1    <=  perf_event_t1_l2;
ic_perf_event_t2    <=  perf_event_t2_l2;
ic_perf_event_t3    <=  perf_event_t3_l2;
sel_dbg_data(0 TO 6) <=  xu_iu_flush_l2(0)   & uc_flush_tid(0)   & ib_ic_iu5_redirect_tid(0)   &
    bp_ic_iu5_redirect_tid(0)   & icd_ics_iu3_parity_flush(0)   & icd_ics_iu2_miss_flush_prev(0)   & ierat_iu_iu2_flush_req(0);
sel_dbg_data(8 TO 14) <=  xu_iu_flush_l2(1)   & uc_flush_tid(1)   & ib_ic_iu5_redirect_tid(1)   &
    bp_ic_iu5_redirect_tid(1)   & icd_ics_iu3_parity_flush(1)   & icd_ics_iu2_miss_flush_prev(1)   & ierat_iu_iu2_flush_req(1);
sel_dbg_data(16 TO 22) <=  xu_iu_flush_l2(2)   & uc_flush_tid(2)   & ib_ic_iu5_redirect_tid(2)   &
    bp_ic_iu5_redirect_tid(2)   & icd_ics_iu3_parity_flush(2)   & icd_ics_iu2_miss_flush_prev(2)   & ierat_iu_iu2_flush_req(2);
sel_dbg_data(24 TO 30) <=  xu_iu_flush_l2(3)   & uc_flush_tid(3)   & ib_ic_iu5_redirect_tid(3)   &
    bp_ic_iu5_redirect_tid(3)   & icd_ics_iu3_parity_flush(3)   & icd_ics_iu2_miss_flush_prev(3)   & ierat_iu_iu2_flush_req(3);
sel_dbg_data(7) <=  icm_ics_iu1_ecc_flush;
sel_dbg_data(15) <=  icm_ics_iu2_miss_match_prev;
sel_dbg_data(23) <=  ierat_iu_iu2_miss;
sel_dbg_data(31) <=  icd_ics_iu1_valid;
sel_dbg_data(32 TO 35) <=  icd_ics_iu1_tid;
sel_dbg_data(36 TO 39) <=  ib_ic_empty;
sel_dbg_data(40 TO 43) <=  ib_ic_below_water;
sel_dbg_data(44 TO 49) <=  hi_did3no0 & hi_did3no1 & hi_did3no2 & hi_did2no0 & hi_did2no1 & hi_did1no0;
sel_dbg_data(50 TO 55) <=  md_did3no0 & md_did3no1 & md_did3no2 & md_did2no0 & md_did2no1 & md_did1no0;
sel_dbg_data(56 TO 59) <=  high_mask_l2;
sel_dbg_data(60 TO 63) <=  low_mask_l2;
sel_dbg_data(64) <=  spr_idir_read_l2;
sel_dbg_data(65) <=  xu_icbi_buffer_val(0);
sel_dbg_data(66) <=  back_inv_l2;
sel_dbg_data(67) <=  icm_ics_hold_iu0;
sel_dbg_data(68 TO 72) <=  xu_iu_run_thread_l2(0)   & uc_ic_hold_thread(0)   &
    bp_ic_iu5_hold_tid(0)   & icm_ics_hold_thread_dbg(0)   & ierat_iu_hold_req(0);
sel_dbg_data(73 TO 77) <=  xu_iu_run_thread_l2(1)   & uc_ic_hold_thread(1)   &
    bp_ic_iu5_hold_tid(1)   & icm_ics_hold_thread_dbg(1)   & ierat_iu_hold_req(1);
sel_dbg_data(78 TO 82) <=  xu_iu_run_thread_l2(2)   & uc_ic_hold_thread(2)   &
    bp_ic_iu5_hold_tid(2)   & icm_ics_hold_thread_dbg(2)   & ierat_iu_hold_req(2);
sel_dbg_data(83 TO 87) <=  xu_iu_run_thread_l2(3)   & uc_ic_hold_thread(3)   &
    bp_ic_iu5_hold_tid(3)   & icm_ics_hold_thread_dbg(3)   & ierat_iu_hold_req(3);
an_ac_back_inv_latch: tri_rlmlatch_p
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
            scin    => siv(an_ac_back_inv_offset),
            scout   => sov(an_ac_back_inv_offset),
            din     => an_ac_back_inv_d,
            dout    => an_ac_back_inv_l2);
an_ac_back_inv_target_latch: tri_rlmlatch_p
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
            scin    => siv(an_ac_back_inv_target_offset),
            scout   => sov(an_ac_back_inv_target_offset),
            din     => an_ac_back_inv_target_d,
            dout    => an_ac_back_inv_target_l2);
an_ac_back_inv_addr_latch: tri_rlmreg_p
  generic map (width => an_ac_back_inv_addr_l2'length, init => 0, needs_sreset => 0, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => back_inv,
            thold_b => pc_iu_func_slp_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => funcslp_force,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(an_ac_back_inv_addr_offset to an_ac_back_inv_addr_offset + an_ac_back_inv_addr_l2'length-1),
            scout   => sov(an_ac_back_inv_addr_offset to an_ac_back_inv_addr_offset + an_ac_back_inv_addr_l2'length-1),
            din     => an_ac_back_inv_addr_d,
            dout    => an_ac_back_inv_addr_l2);
back_inv_latch: tri_rlmlatch_p
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
            scin    => siv(back_inv_offset),
            scout   => sov(back_inv_offset),
            din     => back_inv_d,
            dout    => back_inv_l2);
back_inv_clone_latch: tri_rlmlatch_p
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
            scin    => siv(back_inv_clone_offset),
            scout   => sov(back_inv_clone_offset),
            din     => back_inv_d,
            dout    => back_inv_l2_clone);
an_ac_icbi_ack_latch: tri_rlmlatch_p
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
            scin    => siv(an_ac_icbi_ack_offset),
            scout   => sov(an_ac_icbi_ack_offset),
            din     => an_ac_icbi_ack_d,
            dout    => an_ac_icbi_ack_l2);
an_ac_icbi_ack_thread_latch: tri_rlmreg_p
  generic map (width => an_ac_icbi_ack_thread_l2'length, init => 0, needs_sreset => 0, expand_type => expand_type)
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
            scin    => siv(an_ac_icbi_ack_thread_offset to an_ac_icbi_ack_thread_offset + an_ac_icbi_ack_thread_l2'length-1),
            scout   => sov(an_ac_icbi_ack_thread_offset to an_ac_icbi_ack_thread_offset + an_ac_icbi_ack_thread_l2'length-1),
            din     => an_ac_icbi_ack_thread_d,
            dout    => an_ac_icbi_ack_thread_l2);
xu_icbi_buffer0_val_tid_latch: tri_rlmreg_p
  generic map (width => xu_icbi_buffer0_val_tid_l2'length, init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => xu_icbi_buffer0_act,
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(xu_icbi_buffer0_val_tid_offset to xu_icbi_buffer0_val_tid_offset + xu_icbi_buffer0_val_tid_l2'length-1),
            scout   => sov(xu_icbi_buffer0_val_tid_offset to xu_icbi_buffer0_val_tid_offset + xu_icbi_buffer0_val_tid_l2'length-1),
            din     => xu_icbi_buffer0_val_tid_d,
            dout    => xu_icbi_buffer0_val_tid_l2);
xu_icbi_buffer1_val_tid_latch:   tri_rlmreg_p
  generic map (width => xu_icbi_buffer1_val_tid_l2'length,   init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => xu_icbi_buffer123_act,
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(xu_icbi_buffer1_val_tid_offset   to xu_icbi_buffer1_val_tid_offset   + xu_icbi_buffer1_val_tid_l2'length-1),
            scout   => sov(xu_icbi_buffer1_val_tid_offset   to xu_icbi_buffer1_val_tid_offset   + xu_icbi_buffer1_val_tid_l2'length-1),
            din     => xu_icbi_buffer1_val_tid_d,
            dout    => xu_icbi_buffer1_val_tid_l2);
xu_icbi_buffer2_val_tid_latch:   tri_rlmreg_p
  generic map (width => xu_icbi_buffer2_val_tid_l2'length,   init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => xu_icbi_buffer123_act,
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(xu_icbi_buffer2_val_tid_offset   to xu_icbi_buffer2_val_tid_offset   + xu_icbi_buffer2_val_tid_l2'length-1),
            scout   => sov(xu_icbi_buffer2_val_tid_offset   to xu_icbi_buffer2_val_tid_offset   + xu_icbi_buffer2_val_tid_l2'length-1),
            din     => xu_icbi_buffer2_val_tid_d,
            dout    => xu_icbi_buffer2_val_tid_l2);
xu_icbi_buffer3_val_tid_latch:   tri_rlmreg_p
  generic map (width => xu_icbi_buffer3_val_tid_l2'length,   init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => xu_icbi_buffer123_act,
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(xu_icbi_buffer3_val_tid_offset   to xu_icbi_buffer3_val_tid_offset   + xu_icbi_buffer3_val_tid_l2'length-1),
            scout   => sov(xu_icbi_buffer3_val_tid_offset   to xu_icbi_buffer3_val_tid_offset   + xu_icbi_buffer3_val_tid_l2'length-1),
            din     => xu_icbi_buffer3_val_tid_d,
            dout    => xu_icbi_buffer3_val_tid_l2);
xu_icbi_buffer0_addr_latch: tri_rlmreg_p
  generic map (width => xu_icbi_buffer0_addr_l2'length, init => 0, needs_sreset => 0, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => xu_icbi_buffer0_act,
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(xu_icbi_buffer0_addr_offset to xu_icbi_buffer0_addr_offset + xu_icbi_buffer0_addr_l2'length-1),
            scout   => sov(xu_icbi_buffer0_addr_offset to xu_icbi_buffer0_addr_offset + xu_icbi_buffer0_addr_l2'length-1),
            din     => xu_icbi_buffer0_addr_d,
            dout    => xu_icbi_buffer0_addr_l2);
xu_icbi_buffer1_addr_latch:   tri_rlmreg_p
  generic map (width => xu_icbi_buffer1_addr_l2'length,   init => 0, needs_sreset => 0, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => xu_icbi_buffer123_act,
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(xu_icbi_buffer1_addr_offset   to xu_icbi_buffer1_addr_offset   + xu_icbi_buffer1_addr_l2'length-1),
            scout   => sov(xu_icbi_buffer1_addr_offset   to xu_icbi_buffer1_addr_offset   + xu_icbi_buffer1_addr_l2'length-1),
            din     => xu_icbi_buffer1_addr_d,
            dout    => xu_icbi_buffer1_addr_l2);
xu_icbi_buffer2_addr_latch:   tri_rlmreg_p
  generic map (width => xu_icbi_buffer2_addr_l2'length,   init => 0, needs_sreset => 0, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => xu_icbi_buffer123_act,
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(xu_icbi_buffer2_addr_offset   to xu_icbi_buffer2_addr_offset   + xu_icbi_buffer2_addr_l2'length-1),
            scout   => sov(xu_icbi_buffer2_addr_offset   to xu_icbi_buffer2_addr_offset   + xu_icbi_buffer2_addr_l2'length-1),
            din     => xu_icbi_buffer2_addr_d,
            dout    => xu_icbi_buffer2_addr_l2);
xu_icbi_buffer3_addr_latch:   tri_rlmreg_p
  generic map (width => xu_icbi_buffer3_addr_l2'length,   init => 0, needs_sreset => 0, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => xu_icbi_buffer123_act,
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(xu_icbi_buffer3_addr_offset   to xu_icbi_buffer3_addr_offset   + xu_icbi_buffer3_addr_l2'length-1),
            scout   => sov(xu_icbi_buffer3_addr_offset   to xu_icbi_buffer3_addr_offset   + xu_icbi_buffer3_addr_l2'length-1),
            din     => xu_icbi_buffer3_addr_d,
            dout    => xu_icbi_buffer3_addr_l2);
xu_iu_run_thread_latch: tri_rlmreg_p
  generic map (width => xu_iu_run_thread_l2'length, init => 0, needs_sreset => 1, expand_type => expand_type)
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
            scin    => siv(xu_iu_run_thread_offset to xu_iu_run_thread_offset + xu_iu_run_thread_l2'length-1),
            scout   => sov(xu_iu_run_thread_offset to xu_iu_run_thread_offset + xu_iu_run_thread_l2'length-1),
            din     => xu_iu_run_thread_d,
            dout    => xu_iu_run_thread_l2);
all_stages_flush_prev_latch: tri_rlmreg_p
  generic map (width => all_stages_flush_prev_l2'length, init => 0, needs_sreset => 1, expand_type => expand_type)
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
            scin    => siv(all_stages_flush_prev_offset to all_stages_flush_prev_offset + all_stages_flush_prev_l2'length-1),
            scout   => sov(all_stages_flush_prev_offset to all_stages_flush_prev_offset + all_stages_flush_prev_l2'length-1),
            din     => all_stages_flush_prev_d,
            dout    => all_stages_flush_prev_l2);
iu0_ifar0a_latch:   tri_rlmreg_p
  generic map (width => EFF_IFAR'length/2, init => ((2**(EFF_IFAR'length/2 - 1)-1)*2+1), needs_sreset => 1, expand_type => expand_type)
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
            scin    => siv(iu0_ifar0_offset   to iu0_ifar0_offset   + (EFF_IFAR'length/2)-1),
            scout   => sov(iu0_ifar0_offset   to iu0_ifar0_offset   + (EFF_IFAR'length/2)-1),
            din     => iu0_ifar0_d(EFF_IFAR'left   to EFF_IFAR'left+(EFF_IFAR'length/2)-1),
            dout    => iu0_ifar0_l2(EFF_IFAR'left   to EFF_IFAR'left+(EFF_IFAR'length/2)-1));
iu0_ifar0b_latch:   tri_rlmreg_p
  generic map (width => (EFF_IFAR'length - (EFF_IFAR'length/2)), init => ((2**(EFF_IFAR'length-(EFF_IFAR'length/2) - 1)-1)*2+1), needs_sreset => 1, expand_type => expand_type)
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
            scin    => siv(iu0_ifar0_offset   + (EFF_IFAR'length/2) to iu0_ifar0_offset   + iu0_ifar0_l2'length-1),
            scout   => sov(iu0_ifar0_offset   + (EFF_IFAR'length/2) to iu0_ifar0_offset   + iu0_ifar0_l2'length-1),
            din     => iu0_ifar0_d(EFF_IFAR'left+(EFF_IFAR'length/2)   to EFF_IFAR'right),
            dout    => iu0_ifar0_l2(EFF_IFAR'left+(EFF_IFAR'length/2)   to EFF_IFAR'right));
iu0_ifar1a_latch:   tri_rlmreg_p
  generic map (width => EFF_IFAR'length/2, init => ((2**(EFF_IFAR'length/2 - 1)-1)*2+1), needs_sreset => 1, expand_type => expand_type)
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
            scin    => siv(iu0_ifar1_offset   to iu0_ifar1_offset   + (EFF_IFAR'length/2)-1),
            scout   => sov(iu0_ifar1_offset   to iu0_ifar1_offset   + (EFF_IFAR'length/2)-1),
            din     => iu0_ifar1_d(EFF_IFAR'left   to EFF_IFAR'left+(EFF_IFAR'length/2)-1),
            dout    => iu0_ifar1_l2(EFF_IFAR'left   to EFF_IFAR'left+(EFF_IFAR'length/2)-1));
iu0_ifar1b_latch:   tri_rlmreg_p
  generic map (width => (EFF_IFAR'length - (EFF_IFAR'length/2)), init => ((2**(EFF_IFAR'length-(EFF_IFAR'length/2) - 1)-1)*2+1), needs_sreset => 1, expand_type => expand_type)
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
            scin    => siv(iu0_ifar1_offset   + (EFF_IFAR'length/2) to iu0_ifar1_offset   + iu0_ifar1_l2'length-1),
            scout   => sov(iu0_ifar1_offset   + (EFF_IFAR'length/2) to iu0_ifar1_offset   + iu0_ifar1_l2'length-1),
            din     => iu0_ifar1_d(EFF_IFAR'left+(EFF_IFAR'length/2)   to EFF_IFAR'right),
            dout    => iu0_ifar1_l2(EFF_IFAR'left+(EFF_IFAR'length/2)   to EFF_IFAR'right));
iu0_ifar2a_latch:   tri_rlmreg_p
  generic map (width => EFF_IFAR'length/2, init => ((2**(EFF_IFAR'length/2 - 1)-1)*2+1), needs_sreset => 1, expand_type => expand_type)
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
            scin    => siv(iu0_ifar2_offset   to iu0_ifar2_offset   + (EFF_IFAR'length/2)-1),
            scout   => sov(iu0_ifar2_offset   to iu0_ifar2_offset   + (EFF_IFAR'length/2)-1),
            din     => iu0_ifar2_d(EFF_IFAR'left   to EFF_IFAR'left+(EFF_IFAR'length/2)-1),
            dout    => iu0_ifar2_l2(EFF_IFAR'left   to EFF_IFAR'left+(EFF_IFAR'length/2)-1));
iu0_ifar2b_latch:   tri_rlmreg_p
  generic map (width => (EFF_IFAR'length - (EFF_IFAR'length/2)), init => ((2**(EFF_IFAR'length-(EFF_IFAR'length/2) - 1)-1)*2+1), needs_sreset => 1, expand_type => expand_type)
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
            scin    => siv(iu0_ifar2_offset   + (EFF_IFAR'length/2) to iu0_ifar2_offset   + iu0_ifar2_l2'length-1),
            scout   => sov(iu0_ifar2_offset   + (EFF_IFAR'length/2) to iu0_ifar2_offset   + iu0_ifar2_l2'length-1),
            din     => iu0_ifar2_d(EFF_IFAR'left+(EFF_IFAR'length/2)   to EFF_IFAR'right),
            dout    => iu0_ifar2_l2(EFF_IFAR'left+(EFF_IFAR'length/2)   to EFF_IFAR'right));
iu0_ifar3a_latch:   tri_rlmreg_p
  generic map (width => EFF_IFAR'length/2, init => ((2**(EFF_IFAR'length/2 - 1)-1)*2+1), needs_sreset => 1, expand_type => expand_type)
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
            scin    => siv(iu0_ifar3_offset   to iu0_ifar3_offset   + (EFF_IFAR'length/2)-1),
            scout   => sov(iu0_ifar3_offset   to iu0_ifar3_offset   + (EFF_IFAR'length/2)-1),
            din     => iu0_ifar3_d(EFF_IFAR'left   to EFF_IFAR'left+(EFF_IFAR'length/2)-1),
            dout    => iu0_ifar3_l2(EFF_IFAR'left   to EFF_IFAR'left+(EFF_IFAR'length/2)-1));
iu0_ifar3b_latch:   tri_rlmreg_p
  generic map (width => (EFF_IFAR'length - (EFF_IFAR'length/2)), init => ((2**(EFF_IFAR'length-(EFF_IFAR'length/2) - 1)-1)*2+1), needs_sreset => 1, expand_type => expand_type)
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
            scin    => siv(iu0_ifar3_offset   + (EFF_IFAR'length/2) to iu0_ifar3_offset   + iu0_ifar3_l2'length-1),
            scout   => sov(iu0_ifar3_offset   + (EFF_IFAR'length/2) to iu0_ifar3_offset   + iu0_ifar3_l2'length-1),
            din     => iu0_ifar3_d(EFF_IFAR'left+(EFF_IFAR'length/2)   to EFF_IFAR'right),
            dout    => iu0_ifar3_l2(EFF_IFAR'left+(EFF_IFAR'length/2)   to EFF_IFAR'right));
iu0_2ucode_latch: tri_rlmreg_p
  generic map (width => iu0_2ucode_l2'length, init => 0, needs_sreset => 1, expand_type => expand_type)
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
            scin    => siv(iu0_2ucode_offset to iu0_2ucode_offset + iu0_2ucode_l2'length-1),
            scout   => sov(iu0_2ucode_offset to iu0_2ucode_offset + iu0_2ucode_l2'length-1),
            din     => iu0_2ucode_d,
            dout    => iu0_2ucode_l2);
iu0_2ucode_type_latch: tri_rlmreg_p
  generic map (width => iu0_2ucode_type_l2'length, init => 0, needs_sreset => 1, expand_type => expand_type)
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
            scin    => siv(iu0_2ucode_type_offset to iu0_2ucode_type_offset + iu0_2ucode_type_l2'length-1),
            scout   => sov(iu0_2ucode_type_offset to iu0_2ucode_type_offset + iu0_2ucode_type_l2'length-1),
            din     => iu0_2ucode_type_d,
            dout    => iu0_2ucode_type_l2);
iu0_high_sent1_latch:   tri_rlmreg_p
  generic map (width => iu0_high_sent1_l2'length,   init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => iu0_high_act,
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(iu0_high_sent1_offset   to iu0_high_sent1_offset   + iu0_high_sent1_l2'length-1),
            scout   => sov(iu0_high_sent1_offset   to iu0_high_sent1_offset   + iu0_high_sent1_l2'length-1),
            din     => iu0_high_sent1_d,
            dout    => iu0_high_sent1_l2);
iu0_high_sent2_latch:   tri_rlmreg_p
  generic map (width => iu0_high_sent2_l2'length,   init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => iu0_high_act,
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(iu0_high_sent2_offset   to iu0_high_sent2_offset   + iu0_high_sent2_l2'length-1),
            scout   => sov(iu0_high_sent2_offset   to iu0_high_sent2_offset   + iu0_high_sent2_l2'length-1),
            din     => iu0_high_sent2_d,
            dout    => iu0_high_sent2_l2);
iu0_high_sent3_latch:   tri_rlmreg_p
  generic map (width => iu0_high_sent3_l2'length,   init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => iu0_high_act,
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(iu0_high_sent3_offset   to iu0_high_sent3_offset   + iu0_high_sent3_l2'length-1),
            scout   => sov(iu0_high_sent3_offset   to iu0_high_sent3_offset   + iu0_high_sent3_l2'length-1),
            din     => iu0_high_sent3_d,
            dout    => iu0_high_sent3_l2);
iu0_high_sent4_latch:   tri_rlmreg_p
  generic map (width => iu0_high_sent4_l2'length,   init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => iu0_high_act,
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(iu0_high_sent4_offset   to iu0_high_sent4_offset   + iu0_high_sent4_l2'length-1),
            scout   => sov(iu0_high_sent4_offset   to iu0_high_sent4_offset   + iu0_high_sent4_l2'length-1),
            din     => iu0_high_sent4_d,
            dout    => iu0_high_sent4_l2);
iu0_low_sent1_latch:   tri_rlmreg_p
  generic map (width => iu0_low_sent1_l2'length,   init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => iu0_low_act,
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(iu0_low_sent1_offset   to iu0_low_sent1_offset   + iu0_low_sent1_l2'length-1),
            scout   => sov(iu0_low_sent1_offset   to iu0_low_sent1_offset   + iu0_low_sent1_l2'length-1),
            din     => iu0_low_sent1_d,
            dout    => iu0_low_sent1_l2);
iu0_low_sent2_latch:   tri_rlmreg_p
  generic map (width => iu0_low_sent2_l2'length,   init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => iu0_low_act,
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(iu0_low_sent2_offset   to iu0_low_sent2_offset   + iu0_low_sent2_l2'length-1),
            scout   => sov(iu0_low_sent2_offset   to iu0_low_sent2_offset   + iu0_low_sent2_l2'length-1),
            din     => iu0_low_sent2_d,
            dout    => iu0_low_sent2_l2);
iu0_low_sent3_latch:   tri_rlmreg_p
  generic map (width => iu0_low_sent3_l2'length,   init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => iu0_low_act,
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(iu0_low_sent3_offset   to iu0_low_sent3_offset   + iu0_low_sent3_l2'length-1),
            scout   => sov(iu0_low_sent3_offset   to iu0_low_sent3_offset   + iu0_low_sent3_l2'length-1),
            din     => iu0_low_sent3_d,
            dout    => iu0_low_sent3_l2);
iu0_low_sent4_latch:   tri_rlmreg_p
  generic map (width => iu0_low_sent4_l2'length,   init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => iu0_low_act,
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(iu0_low_sent4_offset   to iu0_low_sent4_offset   + iu0_low_sent4_l2'length-1),
            scout   => sov(iu0_low_sent4_offset   to iu0_low_sent4_offset   + iu0_low_sent4_l2'length-1),
            din     => iu0_low_sent4_d,
            dout    => iu0_low_sent4_l2);
high_mask_latch: tri_rlmreg_p
  generic map (width => high_mask_l2'length, init => 0, needs_sreset => 1, expand_type => expand_type)
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
            scin    => siv(high_mask_offset to high_mask_offset + high_mask_l2'length-1),
            scout   => sov(high_mask_offset to high_mask_offset + high_mask_l2'length-1),
            din     => high_mask_d,
            dout    => high_mask_l2);
low_mask_latch: tri_rlmreg_p
  generic map (width => low_mask_l2'length, init => 0, needs_sreset => 1, expand_type => expand_type)
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
            scin    => siv(low_mask_offset to low_mask_offset + low_mask_l2'length-1),
            scout   => sov(low_mask_offset to low_mask_offset + low_mask_l2'length-1),
            din     => low_mask_d,
            dout    => low_mask_l2);
iu1_bp_val_latch: tri_rlmlatch_p
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
            scin    => siv(iu1_bp_val_offset),
            scout   => sov(iu1_bp_val_offset),
            din     => iu1_bp_val_d,
            dout    => iu1_bp_val_l2);
iu1_bp_ifar_latch: tri_rlmreg_p
  generic map (width => iu1_bp_ifar_l2'length, init => 0, needs_sreset => 0, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => iu1_bp_act,
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(iu1_bp_ifar_offset to iu1_bp_ifar_offset + iu1_bp_ifar_l2'length-1),
            scout   => sov(iu1_bp_ifar_offset to iu1_bp_ifar_offset + iu1_bp_ifar_l2'length-1),
            din     => iu1_bp_ifar_d,
            dout    => iu1_bp_ifar_l2);
iu5_ifar_latch: tri_rlmreg_p
  generic map (width => iu5_ifar_l2'length, init => 0, needs_sreset => 0, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => iu5_act,
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(iu5_ifar_offset to iu5_ifar_offset + iu5_ifar_l2'length-1),
            scout   => sov(iu5_ifar_offset to iu5_ifar_offset + iu5_ifar_l2'length-1),
            din     => iu5_ifar_d,
            dout    => iu5_ifar_l2);
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
pri_took_latch:  tri_rlmreg_p 
  generic map (init => 65, expand_type => expand_type, width => 12)
  port map (
            vd       => vdd,
            gd       => gnd,
            nclk     => nclk,
            act      => tiup,
            thold_b  => pc_iu_func_sl_thold_0_b,
            sg       => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin     => siv(pri_took_offset to pri_took_offset + 12-1),
            scout    => sov(pri_took_offset to pri_took_offset + 12-1),
            din(00)  => hi_did3no0_d,
            din(01)  => hi_did3no1_d,
            din(02)  => hi_did3no2_d,
            din(03)  => hi_did2no0_d,
            din(04)  => hi_did2no1_d,
            din(05)  => hi_did1no0_d,
            din(06)  => md_did3no0_d,
            din(07)  => md_did3no1_d,
            din(08)  => md_did3no2_d,
            din(09)  => md_did2no0_d,
            din(10)  => md_did2no1_d,
            din(11)  => md_did1no0_d,                                              
            dout(00) => hi_did3no0,
            dout(01) => hi_did3no1,
            dout(02) => hi_did3no2,
            dout(03) => hi_did2no0,
            dout(04) => hi_did2no1,
            dout(05) => hi_did1no0,
            dout(06) => md_did3no0,
            dout(07) => md_did3no1,
            dout(08) => md_did3no2,
            dout(09) => md_did2no0,
            dout(10) => md_did2no1,
            dout(11) => md_did1no0                                       
            );
hi_did3no0_d     <=  pri_rand(0) when (spr_ic_pri_rand_always or (spr_ic_pri_rand_flush and or_reduce(xu_iu_flush_l2(0 to 3)))) = '1' else hi_did3no0_din;
hi_did3no1_d     <=  pri_rand(1) when (spr_ic_pri_rand_always or (spr_ic_pri_rand_flush and or_reduce(xu_iu_flush_l2(0 to 3)))) = '1' else hi_did3no1_din;
hi_did3no2_d     <=  pri_rand(2) when (spr_ic_pri_rand_always or (spr_ic_pri_rand_flush and or_reduce(xu_iu_flush_l2(0 to 3)))) = '1' else hi_did3no2_din;
hi_did2no0_d     <=  pri_rand(3) when (spr_ic_pri_rand_always or (spr_ic_pri_rand_flush and or_reduce(xu_iu_flush_l2(0 to 3)))) = '1' else hi_did2no0_din;
hi_did2no1_d     <=  pri_rand(4) when (spr_ic_pri_rand_always or (spr_ic_pri_rand_flush and or_reduce(xu_iu_flush_l2(0 to 3)))) = '1' else hi_did2no1_din;
hi_did1no0_d     <=  pri_rand(5) when (spr_ic_pri_rand_always or (spr_ic_pri_rand_flush and or_reduce(xu_iu_flush_l2(0 to 3)))) = '1' else hi_did1no0_din;
md_did3no0_d     <=  pri_rand(0) when (spr_ic_pri_rand_always or (spr_ic_pri_rand_flush and or_reduce(xu_iu_flush_l2(0 to 3)))) = '1' else md_did3no0_din;
md_did3no1_d     <=  pri_rand(1) when (spr_ic_pri_rand_always or (spr_ic_pri_rand_flush and or_reduce(xu_iu_flush_l2(0 to 3)))) = '1' else md_did3no1_din;
md_did3no2_d     <=  pri_rand(2) when (spr_ic_pri_rand_always or (spr_ic_pri_rand_flush and or_reduce(xu_iu_flush_l2(0 to 3)))) = '1' else md_did3no2_din;
md_did2no0_d     <=  pri_rand(3) when (spr_ic_pri_rand_always or (spr_ic_pri_rand_flush and or_reduce(xu_iu_flush_l2(0 to 3)))) = '1' else md_did2no0_din;
md_did2no1_d     <=  pri_rand(4) when (spr_ic_pri_rand_always or (spr_ic_pri_rand_flush and or_reduce(xu_iu_flush_l2(0 to 3)))) = '1' else md_did2no1_din;
md_did1no0_d     <=  pri_rand(5) when (spr_ic_pri_rand_always or (spr_ic_pri_rand_flush and or_reduce(xu_iu_flush_l2(0 to 3)))) = '1' else md_did1no0_din;
pri_rand(0 TO 5) <=  "001000" when spr_ic_pri_rand(0 to 4) = "00000" else  
                    "100111" when spr_ic_pri_rand(0 to 4) = "00001" else  
                    "110111" when spr_ic_pri_rand(0 to 4) = "00010" else  
                    "000001" when spr_ic_pri_rand(0 to 4) = "00011" else  
                    "000110" when spr_ic_pri_rand(0 to 4) = "00100" else  
                    "001001" when spr_ic_pri_rand(0 to 4) = "00101" else  
                    "011000" when spr_ic_pri_rand(0 to 4) = "00110" else  
                    "111101" when spr_ic_pri_rand(0 to 4) = "00111" else  
                    "100101" when spr_ic_pri_rand(0 to 4) = "01000" else  
                    "010110" when spr_ic_pri_rand(0 to 4) = "01001" else  
                    "101101" when spr_ic_pri_rand(0 to 4) = "01010" else  
                    "111110" when spr_ic_pri_rand(0 to 4) = "01011" else  
                    "110110" when spr_ic_pri_rand(0 to 4) = "01100" else  
                    "101001" when spr_ic_pri_rand(0 to 4) = "01101" else  
                    "000000" when spr_ic_pri_rand(0 to 4) = "01110" else  
                    "111010" when spr_ic_pri_rand(0 to 4) = "01111" else  
                    "000111" when spr_ic_pri_rand(0 to 4) = "10000" else  
                    "111001" when spr_ic_pri_rand(0 to 4) = "10001" else  
                    "111000" when spr_ic_pri_rand(0 to 4) = "10010" else  
                    "011010" when spr_ic_pri_rand(0 to 4) = "10011" else  
                    "111111" when spr_ic_pri_rand(0 to 4) = "10100" else  
                    "010010" when spr_ic_pri_rand(0 to 4) = "10101" else  
                    "000010" when spr_ic_pri_rand(0 to 4) = "10110" else  
                    "000101" when spr_ic_pri_rand(0 to 4) = "10111" else  
                    "111111" when spr_ic_pri_rand(0 to 4) = "11000" else  
                    "000000" when spr_ic_pri_rand(0 to 4) = "11001" else  
                    "011010" when spr_ic_pri_rand(0 to 4) = "11010" else  
                    "100101" when spr_ic_pri_rand(0 to 4) = "11011" else  
                    "001001" when spr_ic_pri_rand(0 to 4) = "11100" else  
                    "110110" when spr_ic_pri_rand(0 to 4) = "11101" else  
                    "000111" when spr_ic_pri_rand(0 to 4) = "11110" else  
                    "111000" ;
spr_ic_icbi_ack_en_latch: tri_rlmlatch_p
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
            scin    => siv(spr_ic_icbi_ack_en_offset),
            scout   => sov(spr_ic_icbi_ack_en_offset),
            din     => spr_ic_icbi_ack_en,
            dout    => spr_ic_icbi_ack_en_l2);
spr_idir_read_latch: tri_rlmlatch_p
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
            scin    => siv(spr_idir_read_offset),
            scout   => sov(spr_idir_read_offset),
            din     => spr_idir_read_d,
            dout    => spr_idir_read_l2);
spr_idir_row_latch: tri_rlmreg_p
  generic map (width => spr_idir_row_l2'length, init => 0, needs_sreset => 0, expand_type => expand_type)
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
            scin    => siv(spr_idir_row_offset to spr_idir_row_offset + spr_idir_row_l2'length-1),
            scout   => sov(spr_idir_row_offset to spr_idir_row_offset + spr_idir_row_l2'length-1),
            din     => spr_idir_row_d,
            dout    => spr_idir_row_l2);
xu_iu_flush_latch: tri_rlmreg_p
  generic map (width => xu_iu_flush_l2'length, init => 0, needs_sreset => 1, expand_type => expand_type)
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
            scin    => siv(xu_iu_flush_offset to xu_iu_flush_offset + xu_iu_flush_l2'length-1),
            scout   => sov(xu_iu_flush_offset to xu_iu_flush_offset + xu_iu_flush_l2'length-1),
            din     => xu_iu_flush,
            dout    => xu_iu_flush_l2);
spare_latch: tri_rlmreg_p
  generic map (width => spare_l2'length, init => 0, needs_sreset => 1, expand_type => expand_type)
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
siv(0 TO scan_right) <=  sov(1 to scan_right) & func_scan_in;
func_scan_out  <=  sov(0) and an_ac_scan_dis_dc_b;
END IUQ_IC_SELECT;

