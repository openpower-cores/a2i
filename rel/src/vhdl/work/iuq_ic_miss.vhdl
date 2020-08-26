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
--* TITLE:
--*
--* NAME: iuq_ic_miss.vhdl
--*
--*********************************************************************

library ieee,ibm,support,tri,work;
use ieee.std_logic_1164.all;
use ibm.std_ulogic_unsigned.all;
use ibm.std_ulogic_support.all;
use ibm.std_ulogic_function_support.all;
use support.power_logic_pkg.all;
use tri.tri_latches_pkg.all;
use work.iuq_pkg.all;
entity iuq_ic_miss is
  generic(expand_type           : integer := 2);
port(
      vdd                       : inout power_logic;
      gnd                       : inout power_logic;
      nclk                      : in clk_logic;
      pc_iu_func_sl_thold_0_b   : in std_ulogic;
      pc_iu_sg_0                : in std_ulogic;
      forcee : in std_ulogic;
      d_mode                    : in std_ulogic;
      delay_lclkr               : in std_ulogic;
      mpw1_b                    : in std_ulogic;
      mpw2_b                    : in std_ulogic;
      scan_in                   : in std_ulogic;
      scan_out                  : out std_ulogic;

      xu_iu_flush               : in std_ulogic_vector(0 to 3);
      bp_ic_iu5_redirect_tid    : in std_ulogic_vector(0 to 3);

      ics_icm_iu0_ifar0         : in std_ulogic_vector(46 to 52);
      ics_icm_iu0_ifar1         : in std_ulogic_vector(46 to 52);
      ics_icm_iu0_ifar2         : in std_ulogic_vector(46 to 52);
      ics_icm_iu0_ifar3         : in std_ulogic_vector(46 to 52);

      ics_icm_iu0_inval         : in std_ulogic;
      ics_icm_iu0_inval_addr    : in std_ulogic_vector(52 to 57);

      ics_icm_iu2_flush_tid     : in std_ulogic_vector(0 to 3);
      ics_icm_iu3_flush_tid     : in std_ulogic_vector(0 to 3);
      icm_ics_hold_thread       : out std_ulogic_vector(0 to 3);
      icm_ics_hold_thread_dbg   : out std_ulogic_vector(0 to 3);  
      icm_ics_hold_iu0          : out std_ulogic;
      icm_ics_ecc_block_iu0     : out std_ulogic_vector(0 to 3);
      icm_ics_load_tid          : out std_ulogic_vector(0 to 3);
      icm_ics_iu1_ecc_flush     : out std_ulogic;
      icm_ics_iu2_miss_match_prev : out std_ulogic;     

      icm_ics_iu0_preload_val   : out std_ulogic;
      icm_ics_iu0_preload_tid   : out std_ulogic_vector(0 to 3);
      icm_ics_iu0_preload_ifar  : out std_ulogic_vector(52 to 59);

      icm_icd_lru_addr          : out std_ulogic_vector(52 to 57);
      icm_icd_dir_inval         : out std_ulogic;
      icm_icd_dir_val           : out std_ulogic;
      icm_icd_data_write        : out std_ulogic;
      icm_icd_reload_addr       : out std_ulogic_vector(52 to 59);
      icm_icd_reload_data       : out std_ulogic_vector(0 to 161);
      icm_icd_reload_way        : out std_ulogic_vector(0 to 3);
      icm_icd_load_tid          : out std_ulogic_vector(0 to 3);
      icm_icd_load_addr         : out EFF_IFAR;
      icm_icd_load_2ucode       : out std_ulogic;
      icm_icd_load_2ucode_type  : out std_ulogic;
      icm_icd_dir_write         : out std_ulogic;
      icm_icd_dir_write_addr    : out std_ulogic_vector(REAL_IFAR'left to 57);
      icm_icd_dir_write_endian  : out std_ulogic;
      icm_icd_dir_write_way     : out std_ulogic_vector(0 to 3);
      icm_icd_lru_write         : out std_ulogic;
      icm_icd_lru_write_addr    : out std_ulogic_vector(52 to 57);
      icm_icd_lru_write_way     : out std_ulogic_vector(0 to 3);
      icm_icd_ecc_inval         : out std_ulogic;
      icm_icd_ecc_addr          : out std_ulogic_vector(52 to 57);
      icm_icd_ecc_way           : out std_ulogic_vector(0 to 3);
      icm_icd_iu3_ecc_fp_cancel : out std_ulogic;
      icm_icd_iu3_ecc_err       : out std_ulogic;
      icm_icd_any_reld_r2       : out std_ulogic;
      icm_icd_any_checkecc      : out std_ulogic;

      icd_icm_miss              : in std_ulogic;        
      icd_icm_tid               : in std_ulogic_vector(0 to 3);
      icd_icm_addr_real         : in REAL_IFAR;
      icd_icm_addr_eff          : in std_ulogic_vector(EFF_IFAR'left to 51);    
      icd_icm_wimge             : in std_ulogic_vector(0 to 4); 
      icd_icm_userdef           : in std_ulogic_vector(0 to 3);
      icd_icm_2ucode            : in std_ulogic;
      icd_icm_2ucode_type       : in std_ulogic;
      icd_icm_iu3_erat_err      : in std_ulogic;
      icd_icm_iu2_inval         : in std_ulogic;
      icd_icm_ici               : in std_ulogic;
      icd_icm_any_iu2_valid     : in std_ulogic;

      icd_icm_row_lru           : in std_ulogic_vector(0 to 2);
      icd_icm_row_val           : in std_ulogic_vector(0 to 3);

      ic_fdep_load_quiesce      : out std_ulogic_vector(0 to 3);

      iu_mm_lmq_empty           : out std_ulogic;                       

      ic_perf_event_t0          : out std_ulogic_vector(0 to 1);
      ic_perf_event_t1          : out std_ulogic_vector(0 to 1);
      ic_perf_event_t2          : out std_ulogic_vector(0 to 1);
      ic_perf_event_t3          : out std_ulogic_vector(0 to 1);

      an_ac_reld_data_vld       : in std_ulogic;                        
      an_ac_reld_core_tag       : in std_ulogic_vector(0 to 4);         
      an_ac_reld_qw             : in std_ulogic_vector(57 to 59);       
      an_ac_reld_data           : in std_ulogic_vector(0 to 127);       
      an_ac_reld_ecc_err        : in std_ulogic;                        
      an_ac_reld_ecc_err_ue     : in std_ulogic;                        

      spr_ic_cls                : in std_ulogic;                        
      spr_ic_clockgate_dis      : in std_ulogic;
      spr_ic_bp_config          : in std_ulogic_vector(0 to 3);         

      iu_xu_request             : out std_ulogic;
      iu_xu_thread              : out std_ulogic_vector(0 to 3);
      iu_xu_ra                  : out std_ulogic_vector(REAL_IFAR'left to 59);
      iu_xu_wimge               : out std_ulogic_vector(0 to 4);
      iu_xu_userdef             : out std_ulogic_vector(0 to 3);

      event_bus_enable          : in std_ulogic;        
      trace_bus_enable          : in std_ulogic;        
      miss_dbg_data0            : out std_ulogic_vector(0 to 87);
      miss_dbg_data1            : out std_ulogic_vector(0 to 87);
      miss_dbg_data2            : out std_ulogic_vector(0 to 43);
      miss_dbg_trigger          : out std_ulogic_vector(0 to 11)
);
-- synopsys translate_off
-- synopsys translate_on
end iuq_ic_miss;
ARCHITECTURE IUQ_IC_MISS
          OF IUQ_IC_MISS
          IS
--@@  Signal Declarations
SIGNAL IU2_SM_0_PT                       : STD_ULOGIC_VECTOR(1 TO 49)  := 
(OTHERS=> 'U');
SIGNAL IU2_SM_1_PT                       : STD_ULOGIC_VECTOR(1 TO 49)  := 
(OTHERS=> 'U');
SIGNAL IU2_SM_2_PT                       : STD_ULOGIC_VECTOR(1 TO 49)  := 
(OTHERS=> 'U');
SIGNAL IU2_SM_3_PT                       : STD_ULOGIC_VECTOR(1 TO 49)  := 
(OTHERS=> 'U');
SIGNAL SELECT_LRU_WAY_PT                 : STD_ULOGIC_VECTOR(1 TO 24)  := 
(OTHERS=> 'U');
component iuq_bd is
port(
     instruction                : in  std_ulogic_vector(0 to 31);
     branch_decode              : out std_ulogic_vector(0 to 3);

     bp_bc_en                   : in  std_ulogic;
     bp_bclr_en                 : in  std_ulogic;
     bp_bcctr_en                : in  std_ulogic;
     bp_sw_en                   : in  std_ulogic
);
end component;
constant spr_ic_cls_offset              : natural := 0;
constant bp_config_offset               : natural := spr_ic_cls_offset + 1;
constant spare_offset                   : natural := bp_config_offset + 4;
constant an_ac_reld_data_vld_offset     : natural := spare_offset + 16;
constant an_ac_reld_core_tag_offset     : natural := an_ac_reld_data_vld_offset + 1;
constant an_ac_reld_qw_offset           : natural := an_ac_reld_core_tag_offset + 5;
constant an_ac_reld_data_offset         : natural := an_ac_reld_qw_offset + 3;
constant an_ac_reld_ecc_err_offset      : natural := an_ac_reld_data_offset + 128;
constant an_ac_reld_ecc_err_ue_offset   : natural := an_ac_reld_ecc_err_offset + 1;
constant reld_r1_tid_offset             : natural := an_ac_reld_ecc_err_ue_offset + 1;
constant reld_r1_qw_offset              : natural := reld_r1_tid_offset + 4;
constant reld_r2_tid_offset             : natural := reld_r1_qw_offset + 3;
constant reld_r2_qw_offset              : natural := reld_r2_tid_offset + 4;
constant r2_crit_qw_offset              : natural := reld_r2_qw_offset + 3;
constant reld_r3_tid_offset             : natural := r2_crit_qw_offset + 1;
constant r3_loaded_offset               : natural := reld_r3_tid_offset + 4;
constant r3_need_back_inval_offset      : natural := r3_loaded_offset + 1;
constant row_lru_offset                 : natural := r3_need_back_inval_offset + 1;
constant row_val_offset                 : natural := row_lru_offset + 3;
constant request_offset                 : natural := row_val_offset + 4;
constant req_thread_offset              : natural := request_offset + 1;
constant req_ra_offset                  : natural := req_thread_offset + 4;
constant req_wimge_offset               : natural := req_ra_offset + 60-REAL_IFAR'left;
constant req_userdef_offset             : natural := req_wimge_offset + 5;
constant iu3_miss_match_offset          : natural := req_userdef_offset + 4;
constant miss_tid0_sm_offset            : natural := iu3_miss_match_offset + 1;
constant miss_flush_occurred0_offset    : natural := miss_tid0_sm_offset + 20;
constant miss_flushed0_offset           : natural := miss_flush_occurred0_offset + 1;
constant miss_inval0_offset             : natural := miss_flushed0_offset + 1;
constant miss_block_fp0_offset          : natural := miss_inval0_offset + 1;
constant miss_ecc_err0_offset           : natural := miss_block_fp0_offset + 1;
constant miss_ecc_err_ue0_offset        : natural := miss_ecc_err0_offset + 1;
constant miss_wrote_dir0_offset         : natural := miss_ecc_err_ue0_offset + 1;
constant miss_need_hold0_offset         : natural := miss_wrote_dir0_offset + 1;
constant miss_addr0_real_offset         : natural := miss_need_hold0_offset + 1;
constant miss_addr0_eff_offset          : natural := miss_addr0_real_offset + REAL_IFAR'length;
constant miss_ci0_offset                : natural := miss_addr0_eff_offset + EFF_IFAR'length - 10;
constant miss_endian0_offset            : natural := miss_ci0_offset + 1;
constant miss_2ucode0_offset            : natural := miss_endian0_offset + 1;
constant miss_2ucode0_type_offset       : natural := miss_2ucode0_offset + 1;
constant miss_way0_offset               : natural := miss_2ucode0_type_offset + 1;
constant perf_event_t0_offset           : natural := miss_way0_offset + 4;
constant miss_tid1_sm_offset            : natural := perf_event_t0_offset     + 2;
constant miss_flush_occurred1_offset    : natural := miss_tid1_sm_offset   + 20;
constant miss_flushed1_offset           : natural := miss_flush_occurred1_offset   + 1;
constant miss_inval1_offset             : natural := miss_flushed1_offset   + 1;
constant miss_block_fp1_offset          : natural := miss_inval1_offset   + 1;
constant miss_ecc_err1_offset           : natural := miss_block_fp1_offset   + 1;
constant miss_ecc_err_ue1_offset        : natural := miss_ecc_err1_offset   + 1;
constant miss_wrote_dir1_offset         : natural := miss_ecc_err_ue1_offset   + 1;
constant miss_need_hold1_offset         : natural := miss_wrote_dir1_offset   + 1;
constant miss_addr1_real_offset         : natural := miss_need_hold1_offset   + 1;
constant miss_addr1_eff_offset          : natural := miss_addr1_real_offset   + REAL_IFAR'length;
constant miss_ci1_offset                : natural := miss_addr1_eff_offset   + EFF_IFAR'length - 10;
constant miss_endian1_offset            : natural := miss_ci1_offset   + 1;
constant miss_2ucode1_offset            : natural := miss_endian1_offset   + 1;
constant miss_2ucode1_type_offset       : natural := miss_2ucode1_offset   + 1;
constant miss_way1_offset               : natural := miss_2ucode1_type_offset   + 1;
constant perf_event_t1_offset           : natural := miss_way1_offset   + 4;
constant miss_tid2_sm_offset            : natural := perf_event_t1_offset     + 2;
constant miss_flush_occurred2_offset    : natural := miss_tid2_sm_offset   + 20;
constant miss_flushed2_offset           : natural := miss_flush_occurred2_offset   + 1;
constant miss_inval2_offset             : natural := miss_flushed2_offset   + 1;
constant miss_block_fp2_offset          : natural := miss_inval2_offset   + 1;
constant miss_ecc_err2_offset           : natural := miss_block_fp2_offset   + 1;
constant miss_ecc_err_ue2_offset        : natural := miss_ecc_err2_offset   + 1;
constant miss_wrote_dir2_offset         : natural := miss_ecc_err_ue2_offset   + 1;
constant miss_need_hold2_offset         : natural := miss_wrote_dir2_offset   + 1;
constant miss_addr2_real_offset         : natural := miss_need_hold2_offset   + 1;
constant miss_addr2_eff_offset          : natural := miss_addr2_real_offset   + REAL_IFAR'length;
constant miss_ci2_offset                : natural := miss_addr2_eff_offset   + EFF_IFAR'length - 10;
constant miss_endian2_offset            : natural := miss_ci2_offset   + 1;
constant miss_2ucode2_offset            : natural := miss_endian2_offset   + 1;
constant miss_2ucode2_type_offset       : natural := miss_2ucode2_offset   + 1;
constant miss_way2_offset               : natural := miss_2ucode2_type_offset   + 1;
constant perf_event_t2_offset           : natural := miss_way2_offset   + 4;
constant miss_tid3_sm_offset            : natural := perf_event_t2_offset     + 2;
constant miss_flush_occurred3_offset    : natural := miss_tid3_sm_offset   + 20;
constant miss_flushed3_offset           : natural := miss_flush_occurred3_offset   + 1;
constant miss_inval3_offset             : natural := miss_flushed3_offset   + 1;
constant miss_block_fp3_offset          : natural := miss_inval3_offset   + 1;
constant miss_ecc_err3_offset           : natural := miss_block_fp3_offset   + 1;
constant miss_ecc_err_ue3_offset        : natural := miss_ecc_err3_offset   + 1;
constant miss_wrote_dir3_offset         : natural := miss_ecc_err_ue3_offset   + 1;
constant miss_need_hold3_offset         : natural := miss_wrote_dir3_offset   + 1;
constant miss_addr3_real_offset         : natural := miss_need_hold3_offset   + 1;
constant miss_addr3_eff_offset          : natural := miss_addr3_real_offset   + REAL_IFAR'length;
constant miss_ci3_offset                : natural := miss_addr3_eff_offset   + EFF_IFAR'length - 10;
constant miss_endian3_offset            : natural := miss_ci3_offset   + 1;
constant miss_2ucode3_offset            : natural := miss_endian3_offset   + 1;
constant miss_2ucode3_type_offset       : natural := miss_2ucode3_offset   + 1;
constant miss_way3_offset               : natural := miss_2ucode3_type_offset   + 1;
constant perf_event_t3_offset           : natural := miss_way3_offset   + 4;
constant lru_write_next_cycle_offset    : natural := perf_event_t3_offset + 2;
constant lru_write_offset               : natural := lru_write_next_cycle_offset + 4;
constant miss_dbg_data1_offset          : natural := lru_write_offset + 4;
constant scan_right                     : natural := miss_dbg_data1_offset + 9 - 1;
subtype s2 is std_ulogic_vector(0 to 1);
subtype s5 is std_ulogic_vector(0 to 4);
-- Latch definition begin
signal spr_ic_cls_d                 : std_ulogic;
signal bp_config_d                  : std_ulogic_vector(0 to 3);
signal an_ac_reld_data_vld_d        : std_ulogic;
signal an_ac_reld_core_tag_d        : std_ulogic_vector(0 to 4);
signal an_ac_reld_qw_d              : std_ulogic_vector(57 to 59);
signal an_ac_reld_data_d            : std_ulogic_vector(0 to 127);
signal an_ac_reld_ecc_err_d         : std_ulogic;
signal an_ac_reld_ecc_err_ue_d      : std_ulogic;
signal reld_r1_tid_d                : std_ulogic_vector(0 to 3);
signal reld_r1_qw_d                 : std_ulogic_vector(0 to 2);
signal reld_r2_tid_d                : std_ulogic_vector(0 to 3);
signal reld_r2_qw_d                 : std_ulogic_vector(0 to 2);
signal r2_crit_qw_d                 : std_ulogic;
signal reld_r3_tid_d                : std_ulogic_vector(0 to 3);
signal r3_loaded_d                  : std_ulogic;
signal r3_need_back_inval_d         : std_ulogic;
signal row_lru_d                    : std_ulogic_vector(0 to 2);
signal row_val_d                    : std_ulogic_vector(0 to 3);
signal request_d                    : std_ulogic;
signal req_thread_d                 : std_ulogic_vector(0 to 3);
signal req_ra_d                     : std_ulogic_vector(REAL_IFAR'left to 59);
signal req_wimge_d                  : std_ulogic_vector(0 to 4);
signal req_userdef_d                : std_ulogic_vector(0 to 3);
signal iu3_miss_match_d                    : std_ulogic;
signal miss_tid0_sm_d       : std_ulogic_vector(0 to 19);
signal miss_flush_occurred0_d     : std_ulogic;
signal miss_flushed0_d      : std_ulogic;
signal miss_inval0_d        : std_ulogic;
signal miss_block_fp0_d     : std_ulogic;
signal miss_ecc_err0_d      : std_ulogic;
signal miss_ecc_err_ue0_d     : std_ulogic;
signal miss_wrote_dir0_d      : std_ulogic;
signal miss_need_hold0_d      : std_ulogic;
signal miss_addr0_real_d      : REAL_IFAR;
signal miss_addr0_eff_d       : std_ulogic_vector(EFF_IFAR'left to 51);
signal miss_ci0_d           : std_ulogic;
signal miss_endian0_d       : std_ulogic;
signal miss_2ucode0_d       : std_ulogic;
signal miss_2ucode0_type_d     : std_ulogic;
signal miss_way0_d          : std_ulogic_vector(0 to 3);
signal perf_event_t0_d      : std_ulogic_vector(0 to 1);
signal miss_tid1_sm_d       : std_ulogic_vector(0 to 19);
signal miss_flush_occurred1_d     : std_ulogic;
signal miss_flushed1_d      : std_ulogic;
signal miss_inval1_d        : std_ulogic;
signal miss_block_fp1_d     : std_ulogic;
signal miss_ecc_err1_d      : std_ulogic;
signal miss_ecc_err_ue1_d     : std_ulogic;
signal miss_wrote_dir1_d      : std_ulogic;
signal miss_need_hold1_d      : std_ulogic;
signal miss_addr1_real_d      : REAL_IFAR;
signal miss_addr1_eff_d       : std_ulogic_vector(EFF_IFAR'left to 51);
signal miss_ci1_d           : std_ulogic;
signal miss_endian1_d       : std_ulogic;
signal miss_2ucode1_d       : std_ulogic;
signal miss_2ucode1_type_d     : std_ulogic;
signal miss_way1_d          : std_ulogic_vector(0 to 3);
signal perf_event_t1_d      : std_ulogic_vector(0 to 1);
signal miss_tid2_sm_d       : std_ulogic_vector(0 to 19);
signal miss_flush_occurred2_d     : std_ulogic;
signal miss_flushed2_d      : std_ulogic;
signal miss_inval2_d        : std_ulogic;
signal miss_block_fp2_d     : std_ulogic;
signal miss_ecc_err2_d      : std_ulogic;
signal miss_ecc_err_ue2_d     : std_ulogic;
signal miss_wrote_dir2_d      : std_ulogic;
signal miss_need_hold2_d      : std_ulogic;
signal miss_addr2_real_d      : REAL_IFAR;
signal miss_addr2_eff_d       : std_ulogic_vector(EFF_IFAR'left to 51);
signal miss_ci2_d           : std_ulogic;
signal miss_endian2_d       : std_ulogic;
signal miss_2ucode2_d       : std_ulogic;
signal miss_2ucode2_type_d     : std_ulogic;
signal miss_way2_d          : std_ulogic_vector(0 to 3);
signal perf_event_t2_d      : std_ulogic_vector(0 to 1);
signal miss_tid3_sm_d       : std_ulogic_vector(0 to 19);
signal miss_flush_occurred3_d     : std_ulogic;
signal miss_flushed3_d      : std_ulogic;
signal miss_inval3_d        : std_ulogic;
signal miss_block_fp3_d     : std_ulogic;
signal miss_ecc_err3_d      : std_ulogic;
signal miss_ecc_err_ue3_d     : std_ulogic;
signal miss_wrote_dir3_d      : std_ulogic;
signal miss_need_hold3_d      : std_ulogic;
signal miss_addr3_real_d      : REAL_IFAR;
signal miss_addr3_eff_d       : std_ulogic_vector(EFF_IFAR'left to 51);
signal miss_ci3_d           : std_ulogic;
signal miss_endian3_d       : std_ulogic;
signal miss_2ucode3_d       : std_ulogic;
signal miss_2ucode3_type_d     : std_ulogic;
signal miss_way3_d          : std_ulogic_vector(0 to 3);
signal perf_event_t3_d      : std_ulogic_vector(0 to 1);
signal lru_write_next_cycle_d               : std_ulogic_vector(0 to 3);
signal lru_write_d                          : std_ulogic_vector(0 to 3);
signal spr_ic_cls_l2                : std_ulogic;
signal bp_config_l2                 : std_ulogic_vector(0 to 3);
signal an_ac_reld_data_vld_l2       : std_ulogic;
signal an_ac_reld_core_tag_l2       : std_ulogic_vector(0 to 4);
signal an_ac_reld_qw_l2             : std_ulogic_vector(57 to 59);
signal an_ac_reld_data_l2           : std_ulogic_vector(0 to 127);
signal an_ac_reld_ecc_err_l2        : std_ulogic;
signal an_ac_reld_ecc_err_ue_l2     : std_ulogic;
signal reld_r1_tid_l2               : std_ulogic_vector(0 to 3);
signal reld_r1_qw_l2                : std_ulogic_vector(0 to 2);
signal reld_r2_tid_l2               : std_ulogic_vector(0 to 3);
signal reld_r2_qw_l2                : std_ulogic_vector(0 to 2);
signal r2_crit_qw_l2                : std_ulogic;
signal reld_r3_tid_l2               : std_ulogic_vector(0 to 3);
signal r3_loaded_l2                 : std_ulogic;
signal r3_need_back_inval_l2        : std_ulogic;
signal row_lru_l2                   : std_ulogic_vector(0 to 2);
signal row_val_l2                   : std_ulogic_vector(0 to 3);
signal request_l2                   : std_ulogic;
signal req_thread_l2                : std_ulogic_vector(0 to 3);
signal req_ra_l2                    : std_ulogic_vector(REAL_IFAR'left to 59);
signal req_wimge_l2                 : std_ulogic_vector(0 to 4);
signal req_userdef_l2               : std_ulogic_vector(0 to 3);
signal iu3_miss_match_l2                   : std_ulogic;
signal miss_tid0_sm_l2      : std_ulogic_vector(0 to 19);
signal miss_flush_occurred0_l2    : std_ulogic;
signal miss_flushed0_l2     : std_ulogic;
signal miss_inval0_l2       : std_ulogic;
signal miss_block_fp0_l2    : std_ulogic;
signal miss_ecc_err0_l2     : std_ulogic;
signal miss_ecc_err_ue0_l2    : std_ulogic;
signal miss_wrote_dir0_l2     : std_ulogic;
signal miss_need_hold0_l2     : std_ulogic;
signal miss_addr0_real_l2     : REAL_IFAR;
signal miss_addr0_eff_l2      : std_ulogic_vector(EFF_IFAR'left to 51);
signal miss_ci0_l2          : std_ulogic;
signal miss_endian0_l2      : std_ulogic;
signal miss_2ucode0_l2      : std_ulogic;
signal miss_2ucode0_type_l2    : std_ulogic;
signal miss_way0_l2         : std_ulogic_vector(0 to 3);
signal perf_event_t0_l2     : std_ulogic_vector(0 to 1);
signal miss_tid1_sm_l2      : std_ulogic_vector(0 to 19);
signal miss_flush_occurred1_l2    : std_ulogic;
signal miss_flushed1_l2     : std_ulogic;
signal miss_inval1_l2       : std_ulogic;
signal miss_block_fp1_l2    : std_ulogic;
signal miss_ecc_err1_l2     : std_ulogic;
signal miss_ecc_err_ue1_l2    : std_ulogic;
signal miss_wrote_dir1_l2     : std_ulogic;
signal miss_need_hold1_l2     : std_ulogic;
signal miss_addr1_real_l2     : REAL_IFAR;
signal miss_addr1_eff_l2      : std_ulogic_vector(EFF_IFAR'left to 51);
signal miss_ci1_l2          : std_ulogic;
signal miss_endian1_l2      : std_ulogic;
signal miss_2ucode1_l2      : std_ulogic;
signal miss_2ucode1_type_l2    : std_ulogic;
signal miss_way1_l2         : std_ulogic_vector(0 to 3);
signal perf_event_t1_l2     : std_ulogic_vector(0 to 1);
signal miss_tid2_sm_l2      : std_ulogic_vector(0 to 19);
signal miss_flush_occurred2_l2    : std_ulogic;
signal miss_flushed2_l2     : std_ulogic;
signal miss_inval2_l2       : std_ulogic;
signal miss_block_fp2_l2    : std_ulogic;
signal miss_ecc_err2_l2     : std_ulogic;
signal miss_ecc_err_ue2_l2    : std_ulogic;
signal miss_wrote_dir2_l2     : std_ulogic;
signal miss_need_hold2_l2     : std_ulogic;
signal miss_addr2_real_l2     : REAL_IFAR;
signal miss_addr2_eff_l2      : std_ulogic_vector(EFF_IFAR'left to 51);
signal miss_ci2_l2          : std_ulogic;
signal miss_endian2_l2      : std_ulogic;
signal miss_2ucode2_l2      : std_ulogic;
signal miss_2ucode2_type_l2    : std_ulogic;
signal miss_way2_l2         : std_ulogic_vector(0 to 3);
signal perf_event_t2_l2     : std_ulogic_vector(0 to 1);
signal miss_tid3_sm_l2      : std_ulogic_vector(0 to 19);
signal miss_flush_occurred3_l2    : std_ulogic;
signal miss_flushed3_l2     : std_ulogic;
signal miss_inval3_l2       : std_ulogic;
signal miss_block_fp3_l2    : std_ulogic;
signal miss_ecc_err3_l2     : std_ulogic;
signal miss_ecc_err_ue3_l2    : std_ulogic;
signal miss_wrote_dir3_l2     : std_ulogic;
signal miss_need_hold3_l2     : std_ulogic;
signal miss_addr3_real_l2     : REAL_IFAR;
signal miss_addr3_eff_l2      : std_ulogic_vector(EFF_IFAR'left to 51);
signal miss_ci3_l2          : std_ulogic;
signal miss_endian3_l2      : std_ulogic;
signal miss_2ucode3_l2      : std_ulogic;
signal miss_2ucode3_type_l2    : std_ulogic;
signal miss_way3_l2         : std_ulogic_vector(0 to 3);
signal perf_event_t3_l2     : std_ulogic_vector(0 to 1);
signal lru_write_next_cycle_l2              : std_ulogic_vector(0 to 3);
signal lru_write_l2                         : std_ulogic_vector(0 to 3);
signal spare_l2                 : std_ulogic_vector(0 to 15);
signal miss_dbg_data1_d         : std_ulogic_vector(51 to 59);
signal miss_dbg_data1_l2        : std_ulogic_vector(51 to 59);
-- Latch definition end
-- Act control; only needed for power reduction
signal default_reld_act : std_ulogic;
signal reld_r2_act      : std_ulogic;
signal miss_act         : std_ulogic_vector(0 to 3);
-- reload pipeline
signal reld_r0_vld      : std_ulogic;
signal reld_r0_tid_plain: std_ulogic_vector(0 to 3);
signal reld_r1_vld      : std_ulogic;
signal load_quiesce     : std_ulogic_vector(0 to 3);
signal set_flush_occurred       : std_ulogic_vector(0 to 3);
signal flush_addr_outside_range : std_ulogic_vector(0 to 3);
-- this signal sets the miss_flushed state bit
signal set_flushed      : std_ulogic_vector(0 to 3);
signal inval_equal      : std_ulogic_vector(0 to 3);
signal set_invalidated  : std_ulogic_vector(0 to 3);
signal reset_state      : std_ulogic_vector(0 to 3);
signal sent_fp          : std_ulogic_vector(0 to 3);
signal set_block_fp     : std_ulogic_vector(0 to 3);
-- this signal will check incoming addr against current valid addresses
signal addr_equal       : std_ulogic_vector(0 to 3);
signal addr_match       : std_ulogic;
signal miss_thread_is_idle : std_ulogic;
signal release_sm       : std_ulogic;
signal release_sm_hold  : std_ulogic_vector(0 to 3);
-- IU0 inval
signal iu0_inval_match  : std_ulogic_vector(0 to 3);
signal miss_wrote_dir_v : std_ulogic_vector(0 to 3);
-- or these together to get iu_xu_request
signal request_tid      : std_ulogic_vector(0 to 3);
signal erat_err         : std_ulogic_vector(0 to 3);
-- fastpath
signal preload_r0_tid   : std_ulogic_vector(0 to 3);
signal preload_hold_iu0 : std_ulogic;
signal load_tid         : std_ulogic_vector(0 to 3);
signal r2_load_addr     : EFF_IFAR;
signal r2_load_2ucode   : std_ulogic;
signal r2_load_2ucode_type : std_ulogic;
signal load_tid_no_block: std_ulogic_vector(0 to 3);
-- this signal indicates critical quadword is in r0, r1
signal r0_crit_qw       : std_ulogic_vector(0 to 3);
signal r1_crit_qw       : std_ulogic_vector(0 to 3);
-- lru
signal lru_write_hit    : std_ulogic;
signal hit_lru          : std_ulogic_vector(0 to 2);
signal select_lru       : std_ulogic_vector(0 to 3);
signal r0_addr          : std_ulogic_vector(52 to 59);
signal lru_valid        : std_ulogic_vector(0 to 3);
signal r1_addr          : std_ulogic_vector(52 to 57);
signal row_match        : std_ulogic_vector(0 to 3);
signal row_match_way    : std_ulogic_vector(0 to 3);
signal val_or_match     : std_ulogic_vector(0 to 3);
signal next_lru_way     : std_ulogic_vector(0 to 3);
signal next_way         : std_ulogic_vector(0 to 3);
-- this signal is set by each state machine and or them together to final holds
signal hold_tid         : std_ulogic_vector(0 to 3);
signal hold_iu0         : std_ulogic;
signal dir_inval        : std_ulogic;
-- or these together to get icm_icd_*
signal write_dir_inval  : std_ulogic_vector(0 to 3);
signal write_dir_val    : std_ulogic_vector(0 to 3);
signal data_write       : std_ulogic_vector(0 to 3);
signal dir_write        : std_ulogic_vector(0 to 3);
signal dir_write_no_block : std_ulogic_vector(0 to 3);
--signal reload_addr      : std_ulogic_vector(52 to 57);
signal reload_way       : std_ulogic_vector(0 to 3);
signal reload_endian    : std_ulogic;
signal swap_endian_data : std_ulogic_vector(0 to 127);
signal branch_decode0   : std_ulogic_vector(0 to 3);
signal swap_branch_decode0   : std_ulogic_vector(0 to 3);
signal branch_decode1   : std_ulogic_vector(0 to 3);
signal swap_branch_decode1   : std_ulogic_vector(0 to 3);
signal branch_decode2   : std_ulogic_vector(0 to 3);
signal swap_branch_decode2   : std_ulogic_vector(0 to 3);
signal branch_decode3   : std_ulogic_vector(0 to 3);
signal swap_branch_decode3   : std_ulogic_vector(0 to 3);
signal instr_data       : std_ulogic_vector(0 to 143);
signal swap_data        : std_ulogic_vector(0 to 143);
signal data_parity_in   : std_ulogic_vector(0 to 17);
signal swap_parity_in   : std_ulogic_vector(0 to 17);
signal r2_real_addr     : std_ulogic_vector(REAL_IFAR'left to 57);
signal lru_write        : std_ulogic_vector(0 to 3);
signal lru_write_addr   : std_ulogic_vector(52 to 57);
signal lru_write_way    : std_ulogic_vector(0 to 3);
signal r3_addr          : std_ulogic_vector(52 to 57);
signal r3_way           : std_ulogic_vector(0 to 3);
-- ECC Error handling
signal new_ecc_err      : std_ulogic_vector(0 to 3);
signal new_ecc_err_ue   : std_ulogic_vector(0 to 3);
signal ecc_err          : std_ulogic_vector(0 to 3);
signal ecc_err_ue       : std_ulogic_vector(0 to 3);
signal ecc_inval        : std_ulogic_vector(0 to 3);
signal ecc_block_iu0    : std_ulogic_vector(0 to 3);
signal ecc_fp           : std_ulogic;
signal siv              : std_ulogic_vector(0 to scan_right);
signal sov              : std_ulogic_vector(0 to scan_right);
signal tiup             : std_ulogic;
  BEGIN --@@ START OF EXECUTABLE CODE FOR IUQ_IC_MISS

tiup  <=  '1';
-----------------------------------------------------------------------
-- Latch Inputs, Reload pipeline
-----------------------------------------------------------------------
default_reld_act  <=  spr_ic_clockgate_dis or
    not miss_tid0_sm_l2(0) or not miss_tid1_sm_l2(0) or not miss_tid2_sm_l2(0) or not miss_tid3_sm_l2(0);
reld_r2_act  <=  spr_ic_clockgate_dis or reld_r1_vld;
bp_config_d  <=  spr_ic_bp_config;
spr_ic_cls_d  <=  spr_ic_cls;
-- d-2 (r0)
an_ac_reld_data_vld_d  <=  an_ac_reld_data_vld;
an_ac_reld_core_tag_d  <=  an_ac_reld_core_tag;
an_ac_reld_qw_d  <=  an_ac_reld_qw;
-- d-1 (r1)
-- Core_tag(0:2) specifies unit (IU is  010 ); Core_tag(3:4) is encoded Thread ID
reld_r0_vld  <=  an_ac_reld_data_vld_l2 and (an_ac_reld_core_tag_l2(0 to 2) = "010");
 WITH s2'(an_ac_reld_core_tag_l2(3 to 4))  SELECT reld_r0_tid_plain  <=  "1000" when "00",
                     "0100" when "01",
                     "0010" when "10",
                     "0001" when others;
reld_r1_tid_d  <=  gate_and(reld_r0_vld, reld_r0_tid_plain);
reld_r1_qw_d  <=  an_ac_reld_qw_l2;
reld_r1_vld  <=  or_reduce(reld_r1_tid_l2);
-- d (r2)
-- Use reld_r1_vld as act to gate clock
an_ac_reld_data_d  <=  an_ac_reld_data;
reld_r2_tid_d  <=  reld_r1_tid_l2;
reld_r2_qw_d  <=  reld_r1_qw_l2;
-- d+1 (r3)
reld_r3_tid_d  <=  reld_r2_tid_l2;
an_ac_reld_ecc_err_d  <=  an_ac_reld_ecc_err;
an_ac_reld_ecc_err_ue_d  <=  an_ac_reld_ecc_err_ue;
-----------------------------------------------------------------------
-- State Machine
-----------------------------------------------------------------------
-- Example State Ordering for cacheable reloads
--  64B Cacheline, No Gaps    :  (1)(3)(4)(5)(6)(11)            - Wait 0, Data0, Data1, Data2, Data3, CheckECC
--  64B Cacheline, Always Gaps:  (1)(3)(8)(4)(9)(5)(10)(6)(11)  - Wait 0, Data0, Wait1, Data1, Wait2, Data2, Wait3, Data3, CheckECC
-- 128B Cacheline, No Gaps    :  (1)(3)(4)(5)(12)(13)(14)(15)(6)(11)    - Wait 0, Data0, Data1, Data2, Data3_128B, Data4_128B, Data5_128B, Data6_128B, Data3/7, CheckECC
-- 128B Cacheline, Always Gaps:  (1)(3)(8)(4)(9)(5)(16)(12)(17)(13)(18)(14)(19)(15)(10)(6)(11)
--          - Wait 0, Data0, Wait1, Data1, Wait2, Data2, Wait3_128B, Data3_128B, Wait4_128B, Data4_128B, Wait5_128B, Data5_128B, Wait6_128B, Data6_128B, Data3/7, CheckECC
--
-- Final Table Listing
--      *INPUTS*================================================*OUTPUTS*======================================================*
--      |                                                       |                                                              |
--      | icd_icm_miss                                          |  miss_tid0_sm_d                                              |
--      | | icd_icm_tid(0)                                      |  |                                                           |
--      | | | icd_icm_wimge(1)                                  |  |                    reset_state(0)                         | -- WIMGE(1): Cache Inhibit
--      | | | | erat_err(0)                                     |  |                    |                                      |
--      | | | | | miss_ci0_l2                                   |  |                    |  request_tid(0)                      |
--      | | | | | | reld_r1_tid_l2(0)                           |  |                    |  | write_dir_inval(0)                |
--      | | | | | | | r2_crit_qw_l2                             |  |                    |  | | write_dir_val(0)                |
--      | | | | | | | | ecc_err(0)                              |  |                    |  | | |                               |
--      | | | | | | | | | ecc_err_ue(0)                         |  |                    |  | | |                               |
--      | | | | | | | | | |                                     |  |                    |  | | |                               |
--      | | | | | | | | | |   spr_ic_cls_l2                     |  |                    |  | | |                               |
--      | | | | | | | | | |   | addr_match                      |  |                    |  | | |                               |
--      | | | | | | | | | |   | | ics_icm_iu2_flush_tid(0)      |  |                    |  | | | hold_tid(0)                   | -- this hold 1 tid and gates iu2
--      | | | | | | | | | |   | | | release_sm                  |  |                    |  | | | |                             |
--      | | | | | | | | | |   | | | | miss_flushed0_l2          |  |                    |  | | | |                             |
--      | | | | | | | | | |   | | | | | miss_inval0_l2          |  |                    |  | | | |                             |
--      | | | | | | | | | |   | | | | | | miss_tid0_sm_l2       |  |                    |  | | | |                             |
--      | | | | | | | | | |   | | | | | | |                     |  |                    |  | | | |                             |
--      | | | | | | | | | |   | | | | | | |                     |  |                    |  | | | |   data_write(0)             |
--      | | | | | | | | | |   | | | | | | |                     |  |                    |  | | | |   | dir_write(0)            |
--      | | | | | | | | | |   | | | | | | |                     |  |                    |  | | | |   | |                       |
--      | | | | | | | | | |   | | | | | | |                     |  |                    |  | | | |   | | load_tid(0)           |
--      | | | | | | | | | |   | | | | | | |                     |  |                    |  | | | |   | | |                     |
--      | | | | | | | | | |   | | | | | | |                     |  |                    |  | | | |   | | | release_sm_hold(0)|
--      | | | | | | | | | |   | | | | | | |                     |  |                    |  | | | |   | | | |                   |
--      | | | | | | | | | |   | | | | | | |                     |  |                    |  | | | |   | | | |                   |
--      | | | | | | | | | |   | | | | | | |         1111111111  |  |         1111111111 |  | | | |   | | | |                   |
--      | | | | | | | | | |   | | | | | | 01234567890123456789  |  01234567890123456789 |  | | | |   | | | |                   |
--      *TYPE*==================================================+==============================================================+
--      | P P P P P P P P P   P P P P P P PPPPPPPPPPPPPPPPPPPP  |  PPPPPPPPPPPPPPPPPPPP P  P P P P   P P P P                   |
--      *POLARITY*--------------------------------------------->|  ++++++++++++++++++++ +  + + + +   + + + +                   |
--      *PHASE*------------------------------------------------>|  TTTTTTTTTTTTTTTTTTTT T  T T T T   T T T T                   |
--      *OPTIMIZE*--------------------------------------------->|   AAAAAAAAAAAAAAAAAAAA A  A A A B   A A A A                    |
--      *TERMS*=================================================+==============================================================+
--    1 | - - - - - - - - -   - - 1 - - - -0-00000000000000000  |  1................... .  . . . .   . . . .                   |
--    2 | - - - - - - - - -   - - - - - - 000000--000000000000  |  ...........1........ .  . . . .   . . . 1                   |
--    3 | - - - - - 0 - - -   - - - - - - 0000-0000-0000000000  |  .........1.......... .  . . . .   . . . .                   |
--    4 | - - - - - 1 - - -   - - - - - - 0000-0-00-0000000000  |  .....1.............. .  . . . .   . . . .                   |
--    5 | - - - - - - - - -   - - - - 0 0 000---000000----0000  |  .................... .  . . . .   1 1 . .                   |
--    6 | - - - - - - 1 - -   - - - - 0 - 000-----0000----0000  |  .................... .  . . . .   . . 1 .                   |
--    7 | - - - - - 0 - - -   - - - - - - 000000000000-0000-00  |  .................1.. .  . . . .   . . . .                   |
--    8 | - - - - - 1 - - -   - - - - - - 000000-00000-0000-00  |  .............1...... .  . . . .   . . . .                   |
--    9 | - - - - - 0 - - -   - - - - - - 00000000000000-0000-  |  ...................1 .  . . . .   . . . .                   |
--   10 | - - - - - 1 - - -   - - - - - - 000000-0000000-0000-  |  ...............1.... .  . . . .   . . . .                   |
--   11 | - - - - - - - - -   - - - - - - ------------------1-  |  ..............1..... .  . . . .   . . . .                   |
--   12 | - - - - - - - - -   - - - - - - ----------------1---  |  ............1....... .  . . . .   . . . .                   |
--   13 | - - - - - 0 - - -   - - - - - - ---------------1----  |  ..........1......... .  . . . .   . . . .                   |
--   14 | - - - - - 1 - - -   - - - - - - ---------------1----  |  ......1............. .  . . . .   . . . .                   |
--   15 | - - - - - 0 - - -   - - - - - - -------------1------  |  ..................1. .  . . . .   . . . .                   |
--   16 | - - - - - 1 - - -   - - - - - - -------------1------  |  ..............1..... .  . . . .   . . . .                   |
--   17 | - - - - - - - - -   - - - - - - 000---00---0--------  |  .................... .  . . . 1   . . . .                   |
--   18 | - - - 0 - - - - -   - - - - - - 0-----00---0--------  |  .................... .  . . . 1   . . . .                   |
--   19 | - - - - - - - 0 -   - - - - - - -----------1--------  |  1................... 1  . . . .   . . . 1                   |
--   20 | - - - - - - - 1 -   - - - - - - -----------1--------  |  .1.................. .  . . . .   . . . .                   |
--   21 | - - - - - - - - -   - - - - - - ----------1---------  |  ......1............. .  . . . .   . . . .                   |
--   22 | - - - - - - - - -   - - - - - - --------1-----------  |  ....1............... .  . . . .   . . . .                   |
--   23 | - - - - - - - 1 -   - - - - - - 000----0------------  |  .................... .  . . . 1   . . . .                   |
--   24 | - - - - - - - - -   - - - - 0 - -------1------------  |  .................... .  . . . .   . . 1 .                   |
--   25 | - - - - - - - 0 0   - - - - 0 0 ------1-------------  |  .................... .  . . 1 .   . . . .                   |
--   26 | - - - - - - - - -   - - - - 0 0 ------1-------------  |  .................... .  . . . .   1 . . .                   |
--   27 | - - - - - - - - -   - - - - - 1 ------1-------------  |  .................... .  . . . 1   . . . .                   |
--   28 | - - - - - - - - -   - - - - 1 - ------1-------------  |  .................... .  . . . 1   . . . .                   |
--   29 | - - - - - - - - 1   - - - - - - ------1-------------  |  .................... .  . . . 1   . . . .                   |
--   30 | - - - - - 0 - - -   0 - - - - - -----1--------------  |  ..........1......... .  . . . .   . . . .                   |
--   31 | - - - - - 1 - - -   0 - - - - - -----1--------------  |  ......1............. .  . . . .   . . . .                   |
--   32 | - - - - - 0 - - -   1 - - - - - -----1--------------  |  ................1... .  . . . .   . . . .                   |
--   33 | - - - - - 1 - - -   1 - - - - - -----1--------------  |  ............1....... .  . . . .   . . . .                   |
--   34 | - - - - - - - - -   - - - - 0 0 ---1----------------  |  .................... .  . 1 . .   . . . .                   |
--   35 | - - - - - 0 - - -   - - - - - - ---1----------------  |  ........1........... .  . . . .   . . . .                   |
--   36 | - - - - - 1 - - -   - - - - - - ---1----------------  |  ....1............... .  . . . .   . . . .                   |
--   37 | - - - 0 - - - - -   - - 0 0 - - --1-----------------  |  ..1................. .  . . . .   . . . .                   |
--   38 | - - - - - - - - -   - - - 1 - - --1-----------------  |  1................... .  . . . .   . . . .                   |
--   39 | - - - 1 - - - - -   - - - - - - --1-----------------  |  1................... .  . . . .   . . . .                   |
--   40 | - - - 0 - 0 - - -   - - - - - - -1------------------  |  .1.................. .  . . . .   . . . .                   |
--   41 | - - - 0 0 1 - - -   - - - - - - -1------------------  |  ...1................ .  . . . .   . . . .                   |
--   42 | - - - 0 1 1 - - -   - - - - - - -1------------------  |  .......1............ .  . . . .   . . . .                   |
--   43 | - - - 1 - - - - -   - - - - - - -1------------------  |  1................... 1  . . . .   . . . 1                   |
--   44 | 1 1 0 - - - - - -   - 1 0 0 - - 1-------------------  |  ..1................. .  . . . .   . . . .                   |
--   45 | - - 0 - - - - - -   - 1 - 1 - - 1-------------------  |  1................... .  . . . .   . . . .                   |
--   46 | 1 1 - - - - - - -   - 0 0 - - - 1-------------------  |  .1.................. .  1 . . .   . . . .                   |
--   47 | 1 1 1 - - - - - -   - - 0 - - - 1-------------------  |  .1.................. .  1 . . .   . . . .                   |
--   48 | - 0 - - - - - - -   - - - - - - 1-------------------  |  1................... .  . . . .   . . . .                   |
--   49 | 0 - - - - - - - -   - - - - - - 1-------------------  |  1................... .  . . . .   . . . .                   |
--      *======================================================================================================================*
--
-- Table IU2_SM_0 Signal Assignments for Product Terms
MQQ1:IU2_SM_0_PT(1) <=
    Eq(( ICS_ICM_IU2_FLUSH_TID(0) & MISS_TID0_SM_L2(1) & 
    MISS_TID0_SM_L2(3) & MISS_TID0_SM_L2(4) & 
    MISS_TID0_SM_L2(5) & MISS_TID0_SM_L2(6) & 
    MISS_TID0_SM_L2(7) & MISS_TID0_SM_L2(8) & 
    MISS_TID0_SM_L2(9) & MISS_TID0_SM_L2(10) & 
    MISS_TID0_SM_L2(11) & MISS_TID0_SM_L2(12) & 
    MISS_TID0_SM_L2(13) & MISS_TID0_SM_L2(14) & 
    MISS_TID0_SM_L2(15) & MISS_TID0_SM_L2(16) & 
    MISS_TID0_SM_L2(17) & MISS_TID0_SM_L2(18) & 
    MISS_TID0_SM_L2(19) ) , STD_ULOGIC_VECTOR'("1000000000000000000"));
MQQ2:IU2_SM_0_PT(2) <=
    Eq(( MISS_TID0_SM_L2(0) & MISS_TID0_SM_L2(1) & 
    MISS_TID0_SM_L2(2) & MISS_TID0_SM_L2(3) & 
    MISS_TID0_SM_L2(4) & MISS_TID0_SM_L2(5) & 
    MISS_TID0_SM_L2(8) & MISS_TID0_SM_L2(9) & 
    MISS_TID0_SM_L2(10) & MISS_TID0_SM_L2(11) & 
    MISS_TID0_SM_L2(12) & MISS_TID0_SM_L2(13) & 
    MISS_TID0_SM_L2(14) & MISS_TID0_SM_L2(15) & 
    MISS_TID0_SM_L2(16) & MISS_TID0_SM_L2(17) & 
    MISS_TID0_SM_L2(18) & MISS_TID0_SM_L2(19)
     ) , STD_ULOGIC_VECTOR'("000000000000000000"));
MQQ3:IU2_SM_0_PT(3) <=
    Eq(( RELD_R1_TID_L2(0) & MISS_TID0_SM_L2(0) & 
    MISS_TID0_SM_L2(1) & MISS_TID0_SM_L2(2) & 
    MISS_TID0_SM_L2(3) & MISS_TID0_SM_L2(5) & 
    MISS_TID0_SM_L2(6) & MISS_TID0_SM_L2(7) & 
    MISS_TID0_SM_L2(8) & MISS_TID0_SM_L2(10) & 
    MISS_TID0_SM_L2(11) & MISS_TID0_SM_L2(12) & 
    MISS_TID0_SM_L2(13) & MISS_TID0_SM_L2(14) & 
    MISS_TID0_SM_L2(15) & MISS_TID0_SM_L2(16) & 
    MISS_TID0_SM_L2(17) & MISS_TID0_SM_L2(18) & 
    MISS_TID0_SM_L2(19) ) , STD_ULOGIC_VECTOR'("0000000000000000000"));
MQQ4:IU2_SM_0_PT(4) <=
    Eq(( RELD_R1_TID_L2(0) & MISS_TID0_SM_L2(0) & 
    MISS_TID0_SM_L2(1) & MISS_TID0_SM_L2(2) & 
    MISS_TID0_SM_L2(3) & MISS_TID0_SM_L2(5) & 
    MISS_TID0_SM_L2(7) & MISS_TID0_SM_L2(8) & 
    MISS_TID0_SM_L2(10) & MISS_TID0_SM_L2(11) & 
    MISS_TID0_SM_L2(12) & MISS_TID0_SM_L2(13) & 
    MISS_TID0_SM_L2(14) & MISS_TID0_SM_L2(15) & 
    MISS_TID0_SM_L2(16) & MISS_TID0_SM_L2(17) & 
    MISS_TID0_SM_L2(18) & MISS_TID0_SM_L2(19)
     ) , STD_ULOGIC_VECTOR'("100000000000000000"));
MQQ5:IU2_SM_0_PT(5) <=
    Eq(( MISS_FLUSHED0_L2 & MISS_INVAL0_L2 & 
    MISS_TID0_SM_L2(0) & MISS_TID0_SM_L2(1) & 
    MISS_TID0_SM_L2(2) & MISS_TID0_SM_L2(6) & 
    MISS_TID0_SM_L2(7) & MISS_TID0_SM_L2(8) & 
    MISS_TID0_SM_L2(9) & MISS_TID0_SM_L2(10) & 
    MISS_TID0_SM_L2(11) & MISS_TID0_SM_L2(16) & 
    MISS_TID0_SM_L2(17) & MISS_TID0_SM_L2(18) & 
    MISS_TID0_SM_L2(19) ) , STD_ULOGIC_VECTOR'("000000000000000"));
MQQ6:IU2_SM_0_PT(6) <=
    Eq(( R2_CRIT_QW_L2 & MISS_FLUSHED0_L2 & 
    MISS_TID0_SM_L2(0) & MISS_TID0_SM_L2(1) & 
    MISS_TID0_SM_L2(2) & MISS_TID0_SM_L2(8) & 
    MISS_TID0_SM_L2(9) & MISS_TID0_SM_L2(10) & 
    MISS_TID0_SM_L2(11) & MISS_TID0_SM_L2(16) & 
    MISS_TID0_SM_L2(17) & MISS_TID0_SM_L2(18) & 
    MISS_TID0_SM_L2(19) ) , STD_ULOGIC_VECTOR'("1000000000000"));
MQQ7:IU2_SM_0_PT(7) <=
    Eq(( RELD_R1_TID_L2(0) & MISS_TID0_SM_L2(0) & 
    MISS_TID0_SM_L2(1) & MISS_TID0_SM_L2(2) & 
    MISS_TID0_SM_L2(3) & MISS_TID0_SM_L2(4) & 
    MISS_TID0_SM_L2(5) & MISS_TID0_SM_L2(6) & 
    MISS_TID0_SM_L2(7) & MISS_TID0_SM_L2(8) & 
    MISS_TID0_SM_L2(9) & MISS_TID0_SM_L2(10) & 
    MISS_TID0_SM_L2(11) & MISS_TID0_SM_L2(13) & 
    MISS_TID0_SM_L2(14) & MISS_TID0_SM_L2(15) & 
    MISS_TID0_SM_L2(16) & MISS_TID0_SM_L2(18) & 
    MISS_TID0_SM_L2(19) ) , STD_ULOGIC_VECTOR'("0000000000000000000"));
MQQ8:IU2_SM_0_PT(8) <=
    Eq(( RELD_R1_TID_L2(0) & MISS_TID0_SM_L2(0) & 
    MISS_TID0_SM_L2(1) & MISS_TID0_SM_L2(2) & 
    MISS_TID0_SM_L2(3) & MISS_TID0_SM_L2(4) & 
    MISS_TID0_SM_L2(5) & MISS_TID0_SM_L2(7) & 
    MISS_TID0_SM_L2(8) & MISS_TID0_SM_L2(9) & 
    MISS_TID0_SM_L2(10) & MISS_TID0_SM_L2(11) & 
    MISS_TID0_SM_L2(13) & MISS_TID0_SM_L2(14) & 
    MISS_TID0_SM_L2(15) & MISS_TID0_SM_L2(16) & 
    MISS_TID0_SM_L2(18) & MISS_TID0_SM_L2(19)
     ) , STD_ULOGIC_VECTOR'("100000000000000000"));
MQQ9:IU2_SM_0_PT(9) <=
    Eq(( RELD_R1_TID_L2(0) & MISS_TID0_SM_L2(0) & 
    MISS_TID0_SM_L2(1) & MISS_TID0_SM_L2(2) & 
    MISS_TID0_SM_L2(3) & MISS_TID0_SM_L2(4) & 
    MISS_TID0_SM_L2(5) & MISS_TID0_SM_L2(6) & 
    MISS_TID0_SM_L2(7) & MISS_TID0_SM_L2(8) & 
    MISS_TID0_SM_L2(9) & MISS_TID0_SM_L2(10) & 
    MISS_TID0_SM_L2(11) & MISS_TID0_SM_L2(12) & 
    MISS_TID0_SM_L2(13) & MISS_TID0_SM_L2(15) & 
    MISS_TID0_SM_L2(16) & MISS_TID0_SM_L2(17) & 
    MISS_TID0_SM_L2(18) ) , STD_ULOGIC_VECTOR'("0000000000000000000"));
MQQ10:IU2_SM_0_PT(10) <=
    Eq(( RELD_R1_TID_L2(0) & MISS_TID0_SM_L2(0) & 
    MISS_TID0_SM_L2(1) & MISS_TID0_SM_L2(2) & 
    MISS_TID0_SM_L2(3) & MISS_TID0_SM_L2(4) & 
    MISS_TID0_SM_L2(5) & MISS_TID0_SM_L2(7) & 
    MISS_TID0_SM_L2(8) & MISS_TID0_SM_L2(9) & 
    MISS_TID0_SM_L2(10) & MISS_TID0_SM_L2(11) & 
    MISS_TID0_SM_L2(12) & MISS_TID0_SM_L2(13) & 
    MISS_TID0_SM_L2(15) & MISS_TID0_SM_L2(16) & 
    MISS_TID0_SM_L2(17) & MISS_TID0_SM_L2(18)
     ) , STD_ULOGIC_VECTOR'("100000000000000000"));
MQQ11:IU2_SM_0_PT(11) <=
    Eq(( MISS_TID0_SM_L2(18) ) , STD_ULOGIC'('1'));
MQQ12:IU2_SM_0_PT(12) <=
    Eq(( MISS_TID0_SM_L2(16) ) , STD_ULOGIC'('1'));
MQQ13:IU2_SM_0_PT(13) <=
    Eq(( RELD_R1_TID_L2(0) & MISS_TID0_SM_L2(15)
     ) , STD_ULOGIC_VECTOR'("01"));
MQQ14:IU2_SM_0_PT(14) <=
    Eq(( RELD_R1_TID_L2(0) & MISS_TID0_SM_L2(15)
     ) , STD_ULOGIC_VECTOR'("11"));
MQQ15:IU2_SM_0_PT(15) <=
    Eq(( RELD_R1_TID_L2(0) & MISS_TID0_SM_L2(13)
     ) , STD_ULOGIC_VECTOR'("01"));
MQQ16:IU2_SM_0_PT(16) <=
    Eq(( RELD_R1_TID_L2(0) & MISS_TID0_SM_L2(13)
     ) , STD_ULOGIC_VECTOR'("11"));
MQQ17:IU2_SM_0_PT(17) <=
    Eq(( MISS_TID0_SM_L2(0) & MISS_TID0_SM_L2(1) & 
    MISS_TID0_SM_L2(2) & MISS_TID0_SM_L2(6) & 
    MISS_TID0_SM_L2(7) & MISS_TID0_SM_L2(11)
     ) , STD_ULOGIC_VECTOR'("000000"));
MQQ18:IU2_SM_0_PT(18) <=
    Eq(( ERAT_ERR(0) & MISS_TID0_SM_L2(0) & 
    MISS_TID0_SM_L2(6) & MISS_TID0_SM_L2(7) & 
    MISS_TID0_SM_L2(11) ) , STD_ULOGIC_VECTOR'("00000"));
MQQ19:IU2_SM_0_PT(19) <=
    Eq(( ECC_ERR(0) & MISS_TID0_SM_L2(11)
     ) , STD_ULOGIC_VECTOR'("01"));
MQQ20:IU2_SM_0_PT(20) <=
    Eq(( ECC_ERR(0) & MISS_TID0_SM_L2(11)
     ) , STD_ULOGIC_VECTOR'("11"));
MQQ21:IU2_SM_0_PT(21) <=
    Eq(( MISS_TID0_SM_L2(10) ) , STD_ULOGIC'('1'));
MQQ22:IU2_SM_0_PT(22) <=
    Eq(( MISS_TID0_SM_L2(8) ) , STD_ULOGIC'('1'));
MQQ23:IU2_SM_0_PT(23) <=
    Eq(( ECC_ERR(0) & MISS_TID0_SM_L2(0) & 
    MISS_TID0_SM_L2(1) & MISS_TID0_SM_L2(2) & 
    MISS_TID0_SM_L2(7) ) , STD_ULOGIC_VECTOR'("10000"));
MQQ24:IU2_SM_0_PT(24) <=
    Eq(( MISS_FLUSHED0_L2 & MISS_TID0_SM_L2(7)
     ) , STD_ULOGIC_VECTOR'("01"));
MQQ25:IU2_SM_0_PT(25) <=
    Eq(( ECC_ERR(0) & ECC_ERR_UE(0) & 
    MISS_FLUSHED0_L2 & MISS_INVAL0_L2 & 
    MISS_TID0_SM_L2(6) ) , STD_ULOGIC_VECTOR'("00001"));
MQQ26:IU2_SM_0_PT(26) <=
    Eq(( MISS_FLUSHED0_L2 & MISS_INVAL0_L2 & 
    MISS_TID0_SM_L2(6) ) , STD_ULOGIC_VECTOR'("001"));
MQQ27:IU2_SM_0_PT(27) <=
    Eq(( MISS_INVAL0_L2 & MISS_TID0_SM_L2(6)
     ) , STD_ULOGIC_VECTOR'("11"));
MQQ28:IU2_SM_0_PT(28) <=
    Eq(( MISS_FLUSHED0_L2 & MISS_TID0_SM_L2(6)
     ) , STD_ULOGIC_VECTOR'("11"));
MQQ29:IU2_SM_0_PT(29) <=
    Eq(( ECC_ERR_UE(0) & MISS_TID0_SM_L2(6)
     ) , STD_ULOGIC_VECTOR'("11"));
MQQ30:IU2_SM_0_PT(30) <=
    Eq(( RELD_R1_TID_L2(0) & SPR_IC_CLS_L2 & 
    MISS_TID0_SM_L2(5) ) , STD_ULOGIC_VECTOR'("001"));
MQQ31:IU2_SM_0_PT(31) <=
    Eq(( RELD_R1_TID_L2(0) & SPR_IC_CLS_L2 & 
    MISS_TID0_SM_L2(5) ) , STD_ULOGIC_VECTOR'("101"));
MQQ32:IU2_SM_0_PT(32) <=
    Eq(( RELD_R1_TID_L2(0) & SPR_IC_CLS_L2 & 
    MISS_TID0_SM_L2(5) ) , STD_ULOGIC_VECTOR'("011"));
MQQ33:IU2_SM_0_PT(33) <=
    Eq(( RELD_R1_TID_L2(0) & SPR_IC_CLS_L2 & 
    MISS_TID0_SM_L2(5) ) , STD_ULOGIC_VECTOR'("111"));
MQQ34:IU2_SM_0_PT(34) <=
    Eq(( MISS_FLUSHED0_L2 & MISS_INVAL0_L2 & 
    MISS_TID0_SM_L2(3) ) , STD_ULOGIC_VECTOR'("001"));
MQQ35:IU2_SM_0_PT(35) <=
    Eq(( RELD_R1_TID_L2(0) & MISS_TID0_SM_L2(3)
     ) , STD_ULOGIC_VECTOR'("01"));
MQQ36:IU2_SM_0_PT(36) <=
    Eq(( RELD_R1_TID_L2(0) & MISS_TID0_SM_L2(3)
     ) , STD_ULOGIC_VECTOR'("11"));
MQQ37:IU2_SM_0_PT(37) <=
    Eq(( ERAT_ERR(0) & ICS_ICM_IU2_FLUSH_TID(0) & 
    RELEASE_SM & MISS_TID0_SM_L2(2)
     ) , STD_ULOGIC_VECTOR'("0001"));
MQQ38:IU2_SM_0_PT(38) <=
    Eq(( RELEASE_SM & MISS_TID0_SM_L2(2)
     ) , STD_ULOGIC_VECTOR'("11"));
MQQ39:IU2_SM_0_PT(39) <=
    Eq(( ERAT_ERR(0) & MISS_TID0_SM_L2(2)
     ) , STD_ULOGIC_VECTOR'("11"));
MQQ40:IU2_SM_0_PT(40) <=
    Eq(( ERAT_ERR(0) & RELD_R1_TID_L2(0) & 
    MISS_TID0_SM_L2(1) ) , STD_ULOGIC_VECTOR'("001"));
MQQ41:IU2_SM_0_PT(41) <=
    Eq(( ERAT_ERR(0) & MISS_CI0_L2 & 
    RELD_R1_TID_L2(0) & MISS_TID0_SM_L2(1)
     ) , STD_ULOGIC_VECTOR'("0011"));
MQQ42:IU2_SM_0_PT(42) <=
    Eq(( ERAT_ERR(0) & MISS_CI0_L2 & 
    RELD_R1_TID_L2(0) & MISS_TID0_SM_L2(1)
     ) , STD_ULOGIC_VECTOR'("0111"));
MQQ43:IU2_SM_0_PT(43) <=
    Eq(( ERAT_ERR(0) & MISS_TID0_SM_L2(1)
     ) , STD_ULOGIC_VECTOR'("11"));
MQQ44:IU2_SM_0_PT(44) <=
    Eq(( ICD_ICM_MISS & ICD_ICM_TID(0) & 
    ICD_ICM_WIMGE(1) & ADDR_MATCH & 
    ICS_ICM_IU2_FLUSH_TID(0) & RELEASE_SM & 
    MISS_TID0_SM_L2(0) ) , STD_ULOGIC_VECTOR'("1101001"));
MQQ45:IU2_SM_0_PT(45) <=
    Eq(( ICD_ICM_WIMGE(1) & ADDR_MATCH & 
    RELEASE_SM & MISS_TID0_SM_L2(0)
     ) , STD_ULOGIC_VECTOR'("0111"));
MQQ46:IU2_SM_0_PT(46) <=
    Eq(( ICD_ICM_MISS & ICD_ICM_TID(0) & 
    ADDR_MATCH & ICS_ICM_IU2_FLUSH_TID(0) & 
    MISS_TID0_SM_L2(0) ) , STD_ULOGIC_VECTOR'("11001"));
MQQ47:IU2_SM_0_PT(47) <=
    Eq(( ICD_ICM_MISS & ICD_ICM_TID(0) & 
    ICD_ICM_WIMGE(1) & ICS_ICM_IU2_FLUSH_TID(0) & 
    MISS_TID0_SM_L2(0) ) , STD_ULOGIC_VECTOR'("11101"));
MQQ48:IU2_SM_0_PT(48) <=
    Eq(( ICD_ICM_TID(0) & MISS_TID0_SM_L2(0)
     ) , STD_ULOGIC_VECTOR'("01"));
MQQ49:IU2_SM_0_PT(49) <=
    Eq(( ICD_ICM_MISS & MISS_TID0_SM_L2(0)
     ) , STD_ULOGIC_VECTOR'("01"));
-- Table IU2_SM_0 Signal Assignments for Outputs
MQQ50:MISS_TID0_SM_D(0) <= 
    (IU2_SM_0_PT(1) OR IU2_SM_0_PT(19)
     OR IU2_SM_0_PT(38) OR IU2_SM_0_PT(39)
     OR IU2_SM_0_PT(43) OR IU2_SM_0_PT(45)
     OR IU2_SM_0_PT(48) OR IU2_SM_0_PT(49)
    );
MQQ51:MISS_TID0_SM_D(1) <= 
    (IU2_SM_0_PT(20) OR IU2_SM_0_PT(40)
     OR IU2_SM_0_PT(46) OR IU2_SM_0_PT(47)
    );
MQQ52:MISS_TID0_SM_D(2) <= 
    (IU2_SM_0_PT(37) OR IU2_SM_0_PT(44)
    );
MQQ53:MISS_TID0_SM_D(3) <= 
    (IU2_SM_0_PT(41));
MQQ54:MISS_TID0_SM_D(4) <= 
    (IU2_SM_0_PT(22) OR IU2_SM_0_PT(36)
    );
MQQ55:MISS_TID0_SM_D(5) <= 
    (IU2_SM_0_PT(4));
MQQ56:MISS_TID0_SM_D(6) <= 
    (IU2_SM_0_PT(14) OR IU2_SM_0_PT(21)
     OR IU2_SM_0_PT(31));
MQQ57:MISS_TID0_SM_D(7) <= 
    (IU2_SM_0_PT(42));
MQQ58:MISS_TID0_SM_D(8) <= 
    (IU2_SM_0_PT(35));
MQQ59:MISS_TID0_SM_D(9) <= 
    (IU2_SM_0_PT(3));
MQQ60:MISS_TID0_SM_D(10) <= 
    (IU2_SM_0_PT(13) OR IU2_SM_0_PT(30)
    );
MQQ61:MISS_TID0_SM_D(11) <= 
    (IU2_SM_0_PT(2));
MQQ62:MISS_TID0_SM_D(12) <= 
    (IU2_SM_0_PT(12) OR IU2_SM_0_PT(33)
    );
MQQ63:MISS_TID0_SM_D(13) <= 
    (IU2_SM_0_PT(8));
MQQ64:MISS_TID0_SM_D(14) <= 
    (IU2_SM_0_PT(11) OR IU2_SM_0_PT(16)
    );
MQQ65:MISS_TID0_SM_D(15) <= 
    (IU2_SM_0_PT(10));
MQQ66:MISS_TID0_SM_D(16) <= 
    (IU2_SM_0_PT(32));
MQQ67:MISS_TID0_SM_D(17) <= 
    (IU2_SM_0_PT(7));
MQQ68:MISS_TID0_SM_D(18) <= 
    (IU2_SM_0_PT(15));
MQQ69:MISS_TID0_SM_D(19) <= 
    (IU2_SM_0_PT(9));
MQQ70:RESET_STATE(0) <= 
    (IU2_SM_0_PT(19) OR IU2_SM_0_PT(43)
    );
MQQ71:REQUEST_TID(0) <= 
    (IU2_SM_0_PT(46) OR IU2_SM_0_PT(47)
    );

MQQ72:WRITE_DIR_INVAL(0) <= 
    (IU2_SM_0_PT(34));
MQQ73:WRITE_DIR_VAL(0) <= 
    (IU2_SM_0_PT(25));
MQQ74:HOLD_TID(0) <= 
    (IU2_SM_0_PT(17) OR IU2_SM_0_PT(18)
     OR IU2_SM_0_PT(23) OR IU2_SM_0_PT(27)
     OR IU2_SM_0_PT(28) OR IU2_SM_0_PT(29)
    );
MQQ75:DATA_WRITE(0) <= 
    (IU2_SM_0_PT(5) OR IU2_SM_0_PT(26)
    );
MQQ76:DIR_WRITE(0) <= 
    (IU2_SM_0_PT(5));
MQQ77:LOAD_TID(0) <= 
    (IU2_SM_0_PT(6) OR IU2_SM_0_PT(24)
    );
MQQ78:RELEASE_SM_HOLD(0) <= 
    (IU2_SM_0_PT(2) OR IU2_SM_0_PT(19)
     OR IU2_SM_0_PT(43));

--
-- Final Table Listing
--      *INPUTS*================================================*OUTPUTS*======================================================*
--      |                                                       |                                                              |
--      | icd_icm_miss                                          |  miss_tid1_sm_d                                              |
--      | | icd_icm_tid(1)                                      |  |                                                           |
--      | | | icd_icm_wimge(1)                                  |  |                    reset_state(1)                         | -- WIMGE(1): Cache Inhibit
--      | | | | erat_err(1)                                     |  |                    |                                      |
--      | | | | | miss_ci1_l2                                   |  |                    |  request_tid(1)                      |
--      | | | | | | reld_r1_tid_l2(1)                           |  |                    |  | write_dir_inval(1)                |
--      | | | | | | | r2_crit_qw_l2                             |  |                    |  | | write_dir_val(1)                |
--      | | | | | | | | ecc_err(1)                              |  |                    |  | | |                               |
--      | | | | | | | | | ecc_err_ue(1)                         |  |                    |  | | |                               |
--      | | | | | | | | | |                                     |  |                    |  | | |                               |
--      | | | | | | | | | |   spr_ic_cls_l2                     |  |                    |  | | |                               |
--      | | | | | | | | | |   | addr_match                      |  |                    |  | | |                               |
--      | | | | | | | | | |   | | ics_icm_iu2_flush_tid(1)      |  |                    |  | | | hold_tid(1)                   | -- this hold 1 tid and gates iu2
--      | | | | | | | | | |   | | | release_sm                  |  |                    |  | | | |                             |
--      | | | | | | | | | |   | | | | miss_flushed1_l2          |  |                    |  | | | |                             |
--      | | | | | | | | | |   | | | | | miss_inval1_l2          |  |                    |  | | | |                             |
--      | | | | | | | | | |   | | | | | | miss_tid1_sm_l2       |  |                    |  | | | |                             |
--      | | | | | | | | | |   | | | | | | |                     |  |                    |  | | | |                             |
--      | | | | | | | | | |   | | | | | | |                     |  |                    |  | | | |   data_write(1)             |
--      | | | | | | | | | |   | | | | | | |                     |  |                    |  | | | |   | dir_write(1)            |
--      | | | | | | | | | |   | | | | | | |                     |  |                    |  | | | |   | |                       |
--      | | | | | | | | | |   | | | | | | |                     |  |                    |  | | | |   | | load_tid(1)           |
--      | | | | | | | | | |   | | | | | | |                     |  |                    |  | | | |   | | |                     |
--      | | | | | | | | | |   | | | | | | |                     |  |                    |  | | | |   | | | release_sm_hold(1)|
--      | | | | | | | | | |   | | | | | | |                     |  |                    |  | | | |   | | | |                   |
--      | | | | | | | | | |   | | | | | | |                     |  |                    |  | | | |   | | | |                   |
--      | | | | | | | | | |   | | | | | | |         1111111111  |  |         1111111111 |  | | | |   | | | |                   |
--      | | | | | | | | | |   | | | | | | 01234567890123456789  |  01234567890123456789 |  | | | |   | | | |                   |
--      *TYPE*==================================================+==============================================================+
--      | P P P P P P P P P   P P P P P P PPPPPPPPPPPPPPPPPPPP  |  PPPPPPPPPPPPPPPPPPPP P  P P P P   P P P P                   |
--      *POLARITY*--------------------------------------------->|  ++++++++++++++++++++ +  + + + +   + + + +                   |
--      *PHASE*------------------------------------------------>|  TTTTTTTTTTTTTTTTTTTT T  T T T T   T T T T                   |
--      *OPTIMIZE*--------------------------------------------->|   AAAAAAAAAAAAAAAAAAAA A  A A A B   A A A A                    |
--      *TERMS*=================================================+==============================================================+
--    1 | - - - - - - - - -   - - 1 - - - -0-00000000000000000  |  1................... .  . . . .   . . . .                   |
--    2 | - - - - - - - - -   - - - - - - 000000--000000000000  |  ...........1........ .  . . . .   . . . 1                   |
--    3 | - - - - - 0 - - -   - - - - - - 0000-0000-0000000000  |  .........1.......... .  . . . .   . . . .                   |
--    4 | - - - - - 1 - - -   - - - - - - 0000-0-00-0000000000  |  .....1.............. .  . . . .   . . . .                   |
--    5 | - - - - - - - - -   - - - - 0 0 000---000000----0000  |  .................... .  . . . .   1 1 . .                   |
--    6 | - - - - - - 1 - -   - - - - 0 - 000-----0000----0000  |  .................... .  . . . .   . . 1 .                   |
--    7 | - - - - - 0 - - -   - - - - - - 000000000000-0000-00  |  .................1.. .  . . . .   . . . .                   |
--    8 | - - - - - 1 - - -   - - - - - - 000000-00000-0000-00  |  .............1...... .  . . . .   . . . .                   |
--    9 | - - - - - 0 - - -   - - - - - - 00000000000000-0000-  |  ...................1 .  . . . .   . . . .                   |
--   10 | - - - - - 1 - - -   - - - - - - 000000-0000000-0000-  |  ...............1.... .  . . . .   . . . .                   |
--   11 | - - - - - - - - -   - - - - - - ------------------1-  |  ..............1..... .  . . . .   . . . .                   |
--   12 | - - - - - - - - -   - - - - - - ----------------1---  |  ............1....... .  . . . .   . . . .                   |
--   13 | - - - - - 0 - - -   - - - - - - ---------------1----  |  ..........1......... .  . . . .   . . . .                   |
--   14 | - - - - - 1 - - -   - - - - - - ---------------1----  |  ......1............. .  . . . .   . . . .                   |
--   15 | - - - - - 0 - - -   - - - - - - -------------1------  |  ..................1. .  . . . .   . . . .                   |
--   16 | - - - - - 1 - - -   - - - - - - -------------1------  |  ..............1..... .  . . . .   . . . .                   |
--   17 | - - - - - - - - -   - - - - - - 000---00---0--------  |  .................... .  . . . 1   . . . .                   |
--   18 | - - - 0 - - - - -   - - - - - - 0-----00---0--------  |  .................... .  . . . 1   . . . .                   |
--   19 | - - - - - - - 0 -   - - - - - - -----------1--------  |  1................... 1  . . . .   . . . 1                   |
--   20 | - - - - - - - 1 -   - - - - - - -----------1--------  |  .1.................. .  . . . .   . . . .                   |
--   21 | - - - - - - - - -   - - - - - - ----------1---------  |  ......1............. .  . . . .   . . . .                   |
--   22 | - - - - - - - - -   - - - - - - --------1-----------  |  ....1............... .  . . . .   . . . .                   |
--   23 | - - - - - - - 1 -   - - - - - - 000----0------------  |  .................... .  . . . 1   . . . .                   |
--   24 | - - - - - - - - -   - - - - 0 - -------1------------  |  .................... .  . . . .   . . 1 .                   |
--   25 | - - - - - - - 0 0   - - - - 0 0 ------1-------------  |  .................... .  . . 1 .   . . . .                   |
--   26 | - - - - - - - - -   - - - - 0 0 ------1-------------  |  .................... .  . . . .   1 . . .                   |
--   27 | - - - - - - - - -   - - - - - 1 ------1-------------  |  .................... .  . . . 1   . . . .                   |
--   28 | - - - - - - - - -   - - - - 1 - ------1-------------  |  .................... .  . . . 1   . . . .                   |
--   29 | - - - - - - - - 1   - - - - - - ------1-------------  |  .................... .  . . . 1   . . . .                   |
--   30 | - - - - - 0 - - -   0 - - - - - -----1--------------  |  ..........1......... .  . . . .   . . . .                   |
--   31 | - - - - - 1 - - -   0 - - - - - -----1--------------  |  ......1............. .  . . . .   . . . .                   |
--   32 | - - - - - 0 - - -   1 - - - - - -----1--------------  |  ................1... .  . . . .   . . . .                   |
--   33 | - - - - - 1 - - -   1 - - - - - -----1--------------  |  ............1....... .  . . . .   . . . .                   |
--   34 | - - - - - - - - -   - - - - 0 0 ---1----------------  |  .................... .  . 1 . .   . . . .                   |
--   35 | - - - - - 0 - - -   - - - - - - ---1----------------  |  ........1........... .  . . . .   . . . .                   |
--   36 | - - - - - 1 - - -   - - - - - - ---1----------------  |  ....1............... .  . . . .   . . . .                   |
--   37 | - - - 0 - - - - -   - - 0 0 - - --1-----------------  |  ..1................. .  . . . .   . . . .                   |
--   38 | - - - - - - - - -   - - - 1 - - --1-----------------  |  1................... .  . . . .   . . . .                   |
--   39 | - - - 1 - - - - -   - - - - - - --1-----------------  |  1................... .  . . . .   . . . .                   |
--   40 | - - - 0 - 0 - - -   - - - - - - -1------------------  |  .1.................. .  . . . .   . . . .                   |
--   41 | - - - 0 0 1 - - -   - - - - - - -1------------------  |  ...1................ .  . . . .   . . . .                   |
--   42 | - - - 0 1 1 - - -   - - - - - - -1------------------  |  .......1............ .  . . . .   . . . .                   |
--   43 | - - - 1 - - - - -   - - - - - - -1------------------  |  1................... 1  . . . .   . . . 1                   |
--   44 | 1 1 0 - - - - - -   - 1 0 0 - - 1-------------------  |  ..1................. .  . . . .   . . . .                   |
--   45 | - - 0 - - - - - -   - 1 - 1 - - 1-------------------  |  1................... .  . . . .   . . . .                   |
--   46 | 1 1 - - - - - - -   - 0 0 - - - 1-------------------  |  .1.................. .  1 . . .   . . . .                   |
--   47 | 1 1 1 - - - - - -   - - 0 - - - 1-------------------  |  .1.................. .  1 . . .   . . . .                   |
--   48 | - 0 - - - - - - -   - - - - - - 1-------------------  |  1................... .  . . . .   . . . .                   |
--   49 | 0 - - - - - - - -   - - - - - - 1-------------------  |  1................... .  . . . .   . . . .                   |
--      *======================================================================================================================*
--
-- Table IU2_SM_1 Signal Assignments for Product Terms
MQQ79:IU2_SM_1_PT(1) <=
    Eq(( ICS_ICM_IU2_FLUSH_TID(1) & MISS_TID1_SM_L2(1) & 
    MISS_TID1_SM_L2(3) & MISS_TID1_SM_L2(4) & 
    MISS_TID1_SM_L2(5) & MISS_TID1_SM_L2(6) & 
    MISS_TID1_SM_L2(7) & MISS_TID1_SM_L2(8) & 
    MISS_TID1_SM_L2(9) & MISS_TID1_SM_L2(10) & 
    MISS_TID1_SM_L2(11) & MISS_TID1_SM_L2(12) & 
    MISS_TID1_SM_L2(13) & MISS_TID1_SM_L2(14) & 
    MISS_TID1_SM_L2(15) & MISS_TID1_SM_L2(16) & 
    MISS_TID1_SM_L2(17) & MISS_TID1_SM_L2(18) & 
    MISS_TID1_SM_L2(19) ) , STD_ULOGIC_VECTOR'("1000000000000000000"));
MQQ80:IU2_SM_1_PT(2) <=
    Eq(( MISS_TID1_SM_L2(0) & MISS_TID1_SM_L2(1) & 
    MISS_TID1_SM_L2(2) & MISS_TID1_SM_L2(3) & 
    MISS_TID1_SM_L2(4) & MISS_TID1_SM_L2(5) & 
    MISS_TID1_SM_L2(8) & MISS_TID1_SM_L2(9) & 
    MISS_TID1_SM_L2(10) & MISS_TID1_SM_L2(11) & 
    MISS_TID1_SM_L2(12) & MISS_TID1_SM_L2(13) & 
    MISS_TID1_SM_L2(14) & MISS_TID1_SM_L2(15) & 
    MISS_TID1_SM_L2(16) & MISS_TID1_SM_L2(17) & 
    MISS_TID1_SM_L2(18) & MISS_TID1_SM_L2(19)
     ) , STD_ULOGIC_VECTOR'("000000000000000000"));
MQQ81:IU2_SM_1_PT(3) <=
    Eq(( RELD_R1_TID_L2(1) & MISS_TID1_SM_L2(0) & 
    MISS_TID1_SM_L2(1) & MISS_TID1_SM_L2(2) & 
    MISS_TID1_SM_L2(3) & MISS_TID1_SM_L2(5) & 
    MISS_TID1_SM_L2(6) & MISS_TID1_SM_L2(7) & 
    MISS_TID1_SM_L2(8) & MISS_TID1_SM_L2(10) & 
    MISS_TID1_SM_L2(11) & MISS_TID1_SM_L2(12) & 
    MISS_TID1_SM_L2(13) & MISS_TID1_SM_L2(14) & 
    MISS_TID1_SM_L2(15) & MISS_TID1_SM_L2(16) & 
    MISS_TID1_SM_L2(17) & MISS_TID1_SM_L2(18) & 
    MISS_TID1_SM_L2(19) ) , STD_ULOGIC_VECTOR'("0000000000000000000"));
MQQ82:IU2_SM_1_PT(4) <=
    Eq(( RELD_R1_TID_L2(1) & MISS_TID1_SM_L2(0) & 
    MISS_TID1_SM_L2(1) & MISS_TID1_SM_L2(2) & 
    MISS_TID1_SM_L2(3) & MISS_TID1_SM_L2(5) & 
    MISS_TID1_SM_L2(7) & MISS_TID1_SM_L2(8) & 
    MISS_TID1_SM_L2(10) & MISS_TID1_SM_L2(11) & 
    MISS_TID1_SM_L2(12) & MISS_TID1_SM_L2(13) & 
    MISS_TID1_SM_L2(14) & MISS_TID1_SM_L2(15) & 
    MISS_TID1_SM_L2(16) & MISS_TID1_SM_L2(17) & 
    MISS_TID1_SM_L2(18) & MISS_TID1_SM_L2(19)
     ) , STD_ULOGIC_VECTOR'("100000000000000000"));
MQQ83:IU2_SM_1_PT(5) <=
    Eq(( MISS_FLUSHED1_L2 & MISS_INVAL1_L2 & 
    MISS_TID1_SM_L2(0) & MISS_TID1_SM_L2(1) & 
    MISS_TID1_SM_L2(2) & MISS_TID1_SM_L2(6) & 
    MISS_TID1_SM_L2(7) & MISS_TID1_SM_L2(8) & 
    MISS_TID1_SM_L2(9) & MISS_TID1_SM_L2(10) & 
    MISS_TID1_SM_L2(11) & MISS_TID1_SM_L2(16) & 
    MISS_TID1_SM_L2(17) & MISS_TID1_SM_L2(18) & 
    MISS_TID1_SM_L2(19) ) , STD_ULOGIC_VECTOR'("000000000000000"));
MQQ84:IU2_SM_1_PT(6) <=
    Eq(( R2_CRIT_QW_L2 & MISS_FLUSHED1_L2 & 
    MISS_TID1_SM_L2(0) & MISS_TID1_SM_L2(1) & 
    MISS_TID1_SM_L2(2) & MISS_TID1_SM_L2(8) & 
    MISS_TID1_SM_L2(9) & MISS_TID1_SM_L2(10) & 
    MISS_TID1_SM_L2(11) & MISS_TID1_SM_L2(16) & 
    MISS_TID1_SM_L2(17) & MISS_TID1_SM_L2(18) & 
    MISS_TID1_SM_L2(19) ) , STD_ULOGIC_VECTOR'("1000000000000"));
MQQ85:IU2_SM_1_PT(7) <=
    Eq(( RELD_R1_TID_L2(1) & MISS_TID1_SM_L2(0) & 
    MISS_TID1_SM_L2(1) & MISS_TID1_SM_L2(2) & 
    MISS_TID1_SM_L2(3) & MISS_TID1_SM_L2(4) & 
    MISS_TID1_SM_L2(5) & MISS_TID1_SM_L2(6) & 
    MISS_TID1_SM_L2(7) & MISS_TID1_SM_L2(8) & 
    MISS_TID1_SM_L2(9) & MISS_TID1_SM_L2(10) & 
    MISS_TID1_SM_L2(11) & MISS_TID1_SM_L2(13) & 
    MISS_TID1_SM_L2(14) & MISS_TID1_SM_L2(15) & 
    MISS_TID1_SM_L2(16) & MISS_TID1_SM_L2(18) & 
    MISS_TID1_SM_L2(19) ) , STD_ULOGIC_VECTOR'("0000000000000000000"));
MQQ86:IU2_SM_1_PT(8) <=
    Eq(( RELD_R1_TID_L2(1) & MISS_TID1_SM_L2(0) & 
    MISS_TID1_SM_L2(1) & MISS_TID1_SM_L2(2) & 
    MISS_TID1_SM_L2(3) & MISS_TID1_SM_L2(4) & 
    MISS_TID1_SM_L2(5) & MISS_TID1_SM_L2(7) & 
    MISS_TID1_SM_L2(8) & MISS_TID1_SM_L2(9) & 
    MISS_TID1_SM_L2(10) & MISS_TID1_SM_L2(11) & 
    MISS_TID1_SM_L2(13) & MISS_TID1_SM_L2(14) & 
    MISS_TID1_SM_L2(15) & MISS_TID1_SM_L2(16) & 
    MISS_TID1_SM_L2(18) & MISS_TID1_SM_L2(19)
     ) , STD_ULOGIC_VECTOR'("100000000000000000"));
MQQ87:IU2_SM_1_PT(9) <=
    Eq(( RELD_R1_TID_L2(1) & MISS_TID1_SM_L2(0) & 
    MISS_TID1_SM_L2(1) & MISS_TID1_SM_L2(2) & 
    MISS_TID1_SM_L2(3) & MISS_TID1_SM_L2(4) & 
    MISS_TID1_SM_L2(5) & MISS_TID1_SM_L2(6) & 
    MISS_TID1_SM_L2(7) & MISS_TID1_SM_L2(8) & 
    MISS_TID1_SM_L2(9) & MISS_TID1_SM_L2(10) & 
    MISS_TID1_SM_L2(11) & MISS_TID1_SM_L2(12) & 
    MISS_TID1_SM_L2(13) & MISS_TID1_SM_L2(15) & 
    MISS_TID1_SM_L2(16) & MISS_TID1_SM_L2(17) & 
    MISS_TID1_SM_L2(18) ) , STD_ULOGIC_VECTOR'("0000000000000000000"));
MQQ88:IU2_SM_1_PT(10) <=
    Eq(( RELD_R1_TID_L2(1) & MISS_TID1_SM_L2(0) & 
    MISS_TID1_SM_L2(1) & MISS_TID1_SM_L2(2) & 
    MISS_TID1_SM_L2(3) & MISS_TID1_SM_L2(4) & 
    MISS_TID1_SM_L2(5) & MISS_TID1_SM_L2(7) & 
    MISS_TID1_SM_L2(8) & MISS_TID1_SM_L2(9) & 
    MISS_TID1_SM_L2(10) & MISS_TID1_SM_L2(11) & 
    MISS_TID1_SM_L2(12) & MISS_TID1_SM_L2(13) & 
    MISS_TID1_SM_L2(15) & MISS_TID1_SM_L2(16) & 
    MISS_TID1_SM_L2(17) & MISS_TID1_SM_L2(18)
     ) , STD_ULOGIC_VECTOR'("100000000000000000"));
MQQ89:IU2_SM_1_PT(11) <=
    Eq(( MISS_TID1_SM_L2(18) ) , STD_ULOGIC'('1'));
MQQ90:IU2_SM_1_PT(12) <=
    Eq(( MISS_TID1_SM_L2(16) ) , STD_ULOGIC'('1'));
MQQ91:IU2_SM_1_PT(13) <=
    Eq(( RELD_R1_TID_L2(1) & MISS_TID1_SM_L2(15)
     ) , STD_ULOGIC_VECTOR'("01"));
MQQ92:IU2_SM_1_PT(14) <=
    Eq(( RELD_R1_TID_L2(1) & MISS_TID1_SM_L2(15)
     ) , STD_ULOGIC_VECTOR'("11"));
MQQ93:IU2_SM_1_PT(15) <=
    Eq(( RELD_R1_TID_L2(1) & MISS_TID1_SM_L2(13)
     ) , STD_ULOGIC_VECTOR'("01"));
MQQ94:IU2_SM_1_PT(16) <=
    Eq(( RELD_R1_TID_L2(1) & MISS_TID1_SM_L2(13)
     ) , STD_ULOGIC_VECTOR'("11"));
MQQ95:IU2_SM_1_PT(17) <=
    Eq(( MISS_TID1_SM_L2(0) & MISS_TID1_SM_L2(1) & 
    MISS_TID1_SM_L2(2) & MISS_TID1_SM_L2(6) & 
    MISS_TID1_SM_L2(7) & MISS_TID1_SM_L2(11)
     ) , STD_ULOGIC_VECTOR'("000000"));
MQQ96:IU2_SM_1_PT(18) <=
    Eq(( ERAT_ERR(1) & MISS_TID1_SM_L2(0) & 
    MISS_TID1_SM_L2(6) & MISS_TID1_SM_L2(7) & 
    MISS_TID1_SM_L2(11) ) , STD_ULOGIC_VECTOR'("00000"));
MQQ97:IU2_SM_1_PT(19) <=
    Eq(( ECC_ERR(1) & MISS_TID1_SM_L2(11)
     ) , STD_ULOGIC_VECTOR'("01"));
MQQ98:IU2_SM_1_PT(20) <=
    Eq(( ECC_ERR(1) & MISS_TID1_SM_L2(11)
     ) , STD_ULOGIC_VECTOR'("11"));
MQQ99:IU2_SM_1_PT(21) <=
    Eq(( MISS_TID1_SM_L2(10) ) , STD_ULOGIC'('1'));
MQQ100:IU2_SM_1_PT(22) <=
    Eq(( MISS_TID1_SM_L2(8) ) , STD_ULOGIC'('1'));
MQQ101:IU2_SM_1_PT(23) <=
    Eq(( ECC_ERR(1) & MISS_TID1_SM_L2(0) & 
    MISS_TID1_SM_L2(1) & MISS_TID1_SM_L2(2) & 
    MISS_TID1_SM_L2(7) ) , STD_ULOGIC_VECTOR'("10000"));
MQQ102:IU2_SM_1_PT(24) <=
    Eq(( MISS_FLUSHED1_L2 & MISS_TID1_SM_L2(7)
     ) , STD_ULOGIC_VECTOR'("01"));
MQQ103:IU2_SM_1_PT(25) <=
    Eq(( ECC_ERR(1) & ECC_ERR_UE(1) & 
    MISS_FLUSHED1_L2 & MISS_INVAL1_L2 & 
    MISS_TID1_SM_L2(6) ) , STD_ULOGIC_VECTOR'("00001"));
MQQ104:IU2_SM_1_PT(26) <=
    Eq(( MISS_FLUSHED1_L2 & MISS_INVAL1_L2 & 
    MISS_TID1_SM_L2(6) ) , STD_ULOGIC_VECTOR'("001"));
MQQ105:IU2_SM_1_PT(27) <=
    Eq(( MISS_INVAL1_L2 & MISS_TID1_SM_L2(6)
     ) , STD_ULOGIC_VECTOR'("11"));
MQQ106:IU2_SM_1_PT(28) <=
    Eq(( MISS_FLUSHED1_L2 & MISS_TID1_SM_L2(6)
     ) , STD_ULOGIC_VECTOR'("11"));
MQQ107:IU2_SM_1_PT(29) <=
    Eq(( ECC_ERR_UE(1) & MISS_TID1_SM_L2(6)
     ) , STD_ULOGIC_VECTOR'("11"));
MQQ108:IU2_SM_1_PT(30) <=
    Eq(( RELD_R1_TID_L2(1) & SPR_IC_CLS_L2 & 
    MISS_TID1_SM_L2(5) ) , STD_ULOGIC_VECTOR'("001"));
MQQ109:IU2_SM_1_PT(31) <=
    Eq(( RELD_R1_TID_L2(1) & SPR_IC_CLS_L2 & 
    MISS_TID1_SM_L2(5) ) , STD_ULOGIC_VECTOR'("101"));
MQQ110:IU2_SM_1_PT(32) <=
    Eq(( RELD_R1_TID_L2(1) & SPR_IC_CLS_L2 & 
    MISS_TID1_SM_L2(5) ) , STD_ULOGIC_VECTOR'("011"));
MQQ111:IU2_SM_1_PT(33) <=
    Eq(( RELD_R1_TID_L2(1) & SPR_IC_CLS_L2 & 
    MISS_TID1_SM_L2(5) ) , STD_ULOGIC_VECTOR'("111"));
MQQ112:IU2_SM_1_PT(34) <=
    Eq(( MISS_FLUSHED1_L2 & MISS_INVAL1_L2 & 
    MISS_TID1_SM_L2(3) ) , STD_ULOGIC_VECTOR'("001"));
MQQ113:IU2_SM_1_PT(35) <=
    Eq(( RELD_R1_TID_L2(1) & MISS_TID1_SM_L2(3)
     ) , STD_ULOGIC_VECTOR'("01"));
MQQ114:IU2_SM_1_PT(36) <=
    Eq(( RELD_R1_TID_L2(1) & MISS_TID1_SM_L2(3)
     ) , STD_ULOGIC_VECTOR'("11"));
MQQ115:IU2_SM_1_PT(37) <=
    Eq(( ERAT_ERR(1) & ICS_ICM_IU2_FLUSH_TID(1) & 
    RELEASE_SM & MISS_TID1_SM_L2(2)
     ) , STD_ULOGIC_VECTOR'("0001"));
MQQ116:IU2_SM_1_PT(38) <=
    Eq(( RELEASE_SM & MISS_TID1_SM_L2(2)
     ) , STD_ULOGIC_VECTOR'("11"));
MQQ117:IU2_SM_1_PT(39) <=
    Eq(( ERAT_ERR(1) & MISS_TID1_SM_L2(2)
     ) , STD_ULOGIC_VECTOR'("11"));
MQQ118:IU2_SM_1_PT(40) <=
    Eq(( ERAT_ERR(1) & RELD_R1_TID_L2(1) & 
    MISS_TID1_SM_L2(1) ) , STD_ULOGIC_VECTOR'("001"));
MQQ119:IU2_SM_1_PT(41) <=
    Eq(( ERAT_ERR(1) & MISS_CI1_L2 & 
    RELD_R1_TID_L2(1) & MISS_TID1_SM_L2(1)
     ) , STD_ULOGIC_VECTOR'("0011"));
MQQ120:IU2_SM_1_PT(42) <=
    Eq(( ERAT_ERR(1) & MISS_CI1_L2 & 
    RELD_R1_TID_L2(1) & MISS_TID1_SM_L2(1)
     ) , STD_ULOGIC_VECTOR'("0111"));
MQQ121:IU2_SM_1_PT(43) <=
    Eq(( ERAT_ERR(1) & MISS_TID1_SM_L2(1)
     ) , STD_ULOGIC_VECTOR'("11"));
MQQ122:IU2_SM_1_PT(44) <=
    Eq(( ICD_ICM_MISS & ICD_ICM_TID(1) & 
    ICD_ICM_WIMGE(1) & ADDR_MATCH & 
    ICS_ICM_IU2_FLUSH_TID(1) & RELEASE_SM & 
    MISS_TID1_SM_L2(0) ) , STD_ULOGIC_VECTOR'("1101001"));
MQQ123:IU2_SM_1_PT(45) <=
    Eq(( ICD_ICM_WIMGE(1) & ADDR_MATCH & 
    RELEASE_SM & MISS_TID1_SM_L2(0)
     ) , STD_ULOGIC_VECTOR'("0111"));
MQQ124:IU2_SM_1_PT(46) <=
    Eq(( ICD_ICM_MISS & ICD_ICM_TID(1) & 
    ADDR_MATCH & ICS_ICM_IU2_FLUSH_TID(1) & 
    MISS_TID1_SM_L2(0) ) , STD_ULOGIC_VECTOR'("11001"));
MQQ125:IU2_SM_1_PT(47) <=
    Eq(( ICD_ICM_MISS & ICD_ICM_TID(1) & 
    ICD_ICM_WIMGE(1) & ICS_ICM_IU2_FLUSH_TID(1) & 
    MISS_TID1_SM_L2(0) ) , STD_ULOGIC_VECTOR'("11101"));
MQQ126:IU2_SM_1_PT(48) <=
    Eq(( ICD_ICM_TID(1) & MISS_TID1_SM_L2(0)
     ) , STD_ULOGIC_VECTOR'("01"));
MQQ127:IU2_SM_1_PT(49) <=
    Eq(( ICD_ICM_MISS & MISS_TID1_SM_L2(0)
     ) , STD_ULOGIC_VECTOR'("01"));
-- Table IU2_SM_1 Signal Assignments for Outputs
MQQ128:MISS_TID1_SM_D(0) <= 
    (IU2_SM_1_PT(1) OR IU2_SM_1_PT(19)
     OR IU2_SM_1_PT(38) OR IU2_SM_1_PT(39)
     OR IU2_SM_1_PT(43) OR IU2_SM_1_PT(45)
     OR IU2_SM_1_PT(48) OR IU2_SM_1_PT(49)
    );
MQQ129:MISS_TID1_SM_D(1) <= 
    (IU2_SM_1_PT(20) OR IU2_SM_1_PT(40)
     OR IU2_SM_1_PT(46) OR IU2_SM_1_PT(47)
    );
MQQ130:MISS_TID1_SM_D(2) <= 
    (IU2_SM_1_PT(37) OR IU2_SM_1_PT(44)
    );
MQQ131:MISS_TID1_SM_D(3) <= 
    (IU2_SM_1_PT(41));
MQQ132:MISS_TID1_SM_D(4) <= 
    (IU2_SM_1_PT(22) OR IU2_SM_1_PT(36)
    );
MQQ133:MISS_TID1_SM_D(5) <= 
    (IU2_SM_1_PT(4));
MQQ134:MISS_TID1_SM_D(6) <= 
    (IU2_SM_1_PT(14) OR IU2_SM_1_PT(21)
     OR IU2_SM_1_PT(31));
MQQ135:MISS_TID1_SM_D(7) <= 
    (IU2_SM_1_PT(42));
MQQ136:MISS_TID1_SM_D(8) <= 
    (IU2_SM_1_PT(35));
MQQ137:MISS_TID1_SM_D(9) <= 
    (IU2_SM_1_PT(3));
MQQ138:MISS_TID1_SM_D(10) <= 
    (IU2_SM_1_PT(13) OR IU2_SM_1_PT(30)
    );
MQQ139:MISS_TID1_SM_D(11) <= 
    (IU2_SM_1_PT(2));
MQQ140:MISS_TID1_SM_D(12) <= 
    (IU2_SM_1_PT(12) OR IU2_SM_1_PT(33)
    );
MQQ141:MISS_TID1_SM_D(13) <= 
    (IU2_SM_1_PT(8));
MQQ142:MISS_TID1_SM_D(14) <= 
    (IU2_SM_1_PT(11) OR IU2_SM_1_PT(16)
    );
MQQ143:MISS_TID1_SM_D(15) <= 
    (IU2_SM_1_PT(10));
MQQ144:MISS_TID1_SM_D(16) <= 
    (IU2_SM_1_PT(32));
MQQ145:MISS_TID1_SM_D(17) <= 
    (IU2_SM_1_PT(7));
MQQ146:MISS_TID1_SM_D(18) <= 
    (IU2_SM_1_PT(15));
MQQ147:MISS_TID1_SM_D(19) <= 
    (IU2_SM_1_PT(9));
MQQ148:RESET_STATE(1) <= 
    (IU2_SM_1_PT(19) OR IU2_SM_1_PT(43)
    );
MQQ149:REQUEST_TID(1) <= 
    (IU2_SM_1_PT(46) OR IU2_SM_1_PT(47)
    );
MQQ150:WRITE_DIR_INVAL(1) <= 
    (IU2_SM_1_PT(34));
MQQ151:WRITE_DIR_VAL(1) <= 
    (IU2_SM_1_PT(25));
MQQ152:HOLD_TID(1) <= 
    (IU2_SM_1_PT(17) OR IU2_SM_1_PT(18)
     OR IU2_SM_1_PT(23) OR IU2_SM_1_PT(27)
     OR IU2_SM_1_PT(28) OR IU2_SM_1_PT(29)
    );
MQQ153:DATA_WRITE(1) <= 
    (IU2_SM_1_PT(5) OR IU2_SM_1_PT(26)
    );
MQQ154:DIR_WRITE(1) <= 
    (IU2_SM_1_PT(5));
MQQ155:LOAD_TID(1) <= 
    (IU2_SM_1_PT(6) OR IU2_SM_1_PT(24)
    );
MQQ156:RELEASE_SM_HOLD(1) <= 
    (IU2_SM_1_PT(2) OR IU2_SM_1_PT(19)
     OR IU2_SM_1_PT(43));

--
-- Final Table Listing
--      *INPUTS*================================================*OUTPUTS*======================================================*
--      |                                                       |                                                              |
--      | icd_icm_miss                                          |  miss_tid2_sm_d                                              |
--      | | icd_icm_tid(2)                                      |  |                                                           |
--      | | | icd_icm_wimge(1)                                  |  |                    reset_state(2)                         | -- WIMGE(1): Cache Inhibit
--      | | | | erat_err(2)                                     |  |                    |                                      |
--      | | | | | miss_ci2_l2                                   |  |                    |  request_tid(2)                      |
--      | | | | | | reld_r1_tid_l2(2)                           |  |                    |  | write_dir_inval(2)                |
--      | | | | | | | r2_crit_qw_l2                             |  |                    |  | | write_dir_val(2)                |
--      | | | | | | | | ecc_err(2)                              |  |                    |  | | |                               |
--      | | | | | | | | | ecc_err_ue(2)                         |  |                    |  | | |                               |
--      | | | | | | | | | |                                     |  |                    |  | | |                               |
--      | | | | | | | | | |   spr_ic_cls_l2                     |  |                    |  | | |                               |
--      | | | | | | | | | |   | addr_match                      |  |                    |  | | |                               |
--      | | | | | | | | | |   | | ics_icm_iu2_flush_tid(2)      |  |                    |  | | | hold_tid(2)                   | -- this hold 1 tid and gates iu2
--      | | | | | | | | | |   | | | release_sm                  |  |                    |  | | | |                             |
--      | | | | | | | | | |   | | | | miss_flushed2_l2          |  |                    |  | | | |                             |
--      | | | | | | | | | |   | | | | | miss_inval2_l2          |  |                    |  | | | |                             |
--      | | | | | | | | | |   | | | | | | miss_tid2_sm_l2       |  |                    |  | | | |                             |
--      | | | | | | | | | |   | | | | | | |                     |  |                    |  | | | |                             |
--      | | | | | | | | | |   | | | | | | |                     |  |                    |  | | | |   data_write(2)             |
--      | | | | | | | | | |   | | | | | | |                     |  |                    |  | | | |   | dir_write(2)            |
--      | | | | | | | | | |   | | | | | | |                     |  |                    |  | | | |   | |                       |
--      | | | | | | | | | |   | | | | | | |                     |  |                    |  | | | |   | | load_tid(2)           |
--      | | | | | | | | | |   | | | | | | |                     |  |                    |  | | | |   | | |                     |
--      | | | | | | | | | |   | | | | | | |                     |  |                    |  | | | |   | | | release_sm_hold(2)|
--      | | | | | | | | | |   | | | | | | |                     |  |                    |  | | | |   | | | |                   |
--      | | | | | | | | | |   | | | | | | |                     |  |                    |  | | | |   | | | |                   |
--      | | | | | | | | | |   | | | | | | |         1111111111  |  |         1111111111 |  | | | |   | | | |                   |
--      | | | | | | | | | |   | | | | | | 01234567890123456789  |  01234567890123456789 |  | | | |   | | | |                   |
--      *TYPE*==================================================+==============================================================+
--      | P P P P P P P P P   P P P P P P PPPPPPPPPPPPPPPPPPPP  |  PPPPPPPPPPPPPPPPPPPP P  P P P P   P P P P                   |
--      *POLARITY*--------------------------------------------->|  ++++++++++++++++++++ +  + + + +   + + + +                   |
--      *PHASE*------------------------------------------------>|  TTTTTTTTTTTTTTTTTTTT T  T T T T   T T T T                   |
--      *OPTIMIZE*--------------------------------------------->|   AAAAAAAAAAAAAAAAAAAA A  A A A B   A A A A                    |
--      *TERMS*=================================================+==============================================================+
--    1 | - - - - - - - - -   - - 1 - - - -0-00000000000000000  |  1................... .  . . . .   . . . .                   |
--    2 | - - - - - - - - -   - - - - - - 000000--000000000000  |  ...........1........ .  . . . .   . . . 1                   |
--    3 | - - - - - 0 - - -   - - - - - - 0000-0000-0000000000  |  .........1.......... .  . . . .   . . . .                   |
--    4 | - - - - - 1 - - -   - - - - - - 0000-0-00-0000000000  |  .....1.............. .  . . . .   . . . .                   |
--    5 | - - - - - - - - -   - - - - 0 0 000---000000----0000  |  .................... .  . . . .   1 1 . .                   |
--    6 | - - - - - - 1 - -   - - - - 0 - 000-----0000----0000  |  .................... .  . . . .   . . 1 .                   |
--    7 | - - - - - 0 - - -   - - - - - - 000000000000-0000-00  |  .................1.. .  . . . .   . . . .                   |
--    8 | - - - - - 1 - - -   - - - - - - 000000-00000-0000-00  |  .............1...... .  . . . .   . . . .                   |
--    9 | - - - - - 0 - - -   - - - - - - 00000000000000-0000-  |  ...................1 .  . . . .   . . . .                   |
--   10 | - - - - - 1 - - -   - - - - - - 000000-0000000-0000-  |  ...............1.... .  . . . .   . . . .                   |
--   11 | - - - - - - - - -   - - - - - - ------------------1-  |  ..............1..... .  . . . .   . . . .                   |
--   12 | - - - - - - - - -   - - - - - - ----------------1---  |  ............1....... .  . . . .   . . . .                   |
--   13 | - - - - - 0 - - -   - - - - - - ---------------1----  |  ..........1......... .  . . . .   . . . .                   |
--   14 | - - - - - 1 - - -   - - - - - - ---------------1----  |  ......1............. .  . . . .   . . . .                   |
--   15 | - - - - - 0 - - -   - - - - - - -------------1------  |  ..................1. .  . . . .   . . . .                   |
--   16 | - - - - - 1 - - -   - - - - - - -------------1------  |  ..............1..... .  . . . .   . . . .                   |
--   17 | - - - - - - - - -   - - - - - - 000---00---0--------  |  .................... .  . . . 1   . . . .                   |
--   18 | - - - 0 - - - - -   - - - - - - 0-----00---0--------  |  .................... .  . . . 1   . . . .                   |
--   19 | - - - - - - - 0 -   - - - - - - -----------1--------  |  1................... 1  . . . .   . . . 1                   |
--   20 | - - - - - - - 1 -   - - - - - - -----------1--------  |  .1.................. .  . . . .   . . . .                   |
--   21 | - - - - - - - - -   - - - - - - ----------1---------  |  ......1............. .  . . . .   . . . .                   |
--   22 | - - - - - - - - -   - - - - - - --------1-----------  |  ....1............... .  . . . .   . . . .                   |
--   23 | - - - - - - - 1 -   - - - - - - 000----0------------  |  .................... .  . . . 1   . . . .                   |
--   24 | - - - - - - - - -   - - - - 0 - -------1------------  |  .................... .  . . . .   . . 1 .                   |
--   25 | - - - - - - - 0 0   - - - - 0 0 ------1-------------  |  .................... .  . . 1 .   . . . .                   |
--   26 | - - - - - - - - -   - - - - 0 0 ------1-------------  |  .................... .  . . . .   1 . . .                   |
--   27 | - - - - - - - - -   - - - - - 1 ------1-------------  |  .................... .  . . . 1   . . . .                   |
--   28 | - - - - - - - - -   - - - - 1 - ------1-------------  |  .................... .  . . . 1   . . . .                   |
--   29 | - - - - - - - - 1   - - - - - - ------1-------------  |  .................... .  . . . 1   . . . .                   |
--   30 | - - - - - 0 - - -   0 - - - - - -----1--------------  |  ..........1......... .  . . . .   . . . .                   |
--   31 | - - - - - 1 - - -   0 - - - - - -----1--------------  |  ......1............. .  . . . .   . . . .                   |
--   32 | - - - - - 0 - - -   1 - - - - - -----1--------------  |  ................1... .  . . . .   . . . .                   |
--   33 | - - - - - 1 - - -   1 - - - - - -----1--------------  |  ............1....... .  . . . .   . . . .                   |
--   34 | - - - - - - - - -   - - - - 0 0 ---1----------------  |  .................... .  . 1 . .   . . . .                   |
--   35 | - - - - - 0 - - -   - - - - - - ---1----------------  |  ........1........... .  . . . .   . . . .                   |
--   36 | - - - - - 1 - - -   - - - - - - ---1----------------  |  ....1............... .  . . . .   . . . .                   |
--   37 | - - - 0 - - - - -   - - 0 0 - - --1-----------------  |  ..1................. .  . . . .   . . . .                   |
--   38 | - - - - - - - - -   - - - 1 - - --1-----------------  |  1................... .  . . . .   . . . .                   |
--   39 | - - - 1 - - - - -   - - - - - - --1-----------------  |  1................... .  . . . .   . . . .                   |
--   40 | - - - 0 - 0 - - -   - - - - - - -1------------------  |  .1.................. .  . . . .   . . . .                   |
--   41 | - - - 0 0 1 - - -   - - - - - - -1------------------  |  ...1................ .  . . . .   . . . .                   |
--   42 | - - - 0 1 1 - - -   - - - - - - -1------------------  |  .......1............ .  . . . .   . . . .                   |
--   43 | - - - 1 - - - - -   - - - - - - -1------------------  |  1................... 1  . . . .   . . . 1                   |
--   44 | 1 1 0 - - - - - -   - 1 0 0 - - 1-------------------  |  ..1................. .  . . . .   . . . .                   |
--   45 | - - 0 - - - - - -   - 1 - 1 - - 1-------------------  |  1................... .  . . . .   . . . .                   |
--   46 | 1 1 - - - - - - -   - 0 0 - - - 1-------------------  |  .1.................. .  1 . . .   . . . .                   |
--   47 | 1 1 1 - - - - - -   - - 0 - - - 1-------------------  |  .1.................. .  1 . . .   . . . .                   |
--   48 | - 0 - - - - - - -   - - - - - - 1-------------------  |  1................... .  . . . .   . . . .                   |
--   49 | 0 - - - - - - - -   - - - - - - 1-------------------  |  1................... .  . . . .   . . . .                   |
--      *======================================================================================================================*
--
-- Table IU2_SM_2 Signal Assignments for Product Terms
MQQ157:IU2_SM_2_PT(1) <=
    Eq(( ICS_ICM_IU2_FLUSH_TID(2) & MISS_TID2_SM_L2(1) & 
    MISS_TID2_SM_L2(3) & MISS_TID2_SM_L2(4) & 
    MISS_TID2_SM_L2(5) & MISS_TID2_SM_L2(6) & 
    MISS_TID2_SM_L2(7) & MISS_TID2_SM_L2(8) & 
    MISS_TID2_SM_L2(9) & MISS_TID2_SM_L2(10) & 
    MISS_TID2_SM_L2(11) & MISS_TID2_SM_L2(12) & 
    MISS_TID2_SM_L2(13) & MISS_TID2_SM_L2(14) & 
    MISS_TID2_SM_L2(15) & MISS_TID2_SM_L2(16) & 
    MISS_TID2_SM_L2(17) & MISS_TID2_SM_L2(18) & 
    MISS_TID2_SM_L2(19) ) , STD_ULOGIC_VECTOR'("1000000000000000000"));
MQQ158:IU2_SM_2_PT(2) <=
    Eq(( MISS_TID2_SM_L2(0) & MISS_TID2_SM_L2(1) & 
    MISS_TID2_SM_L2(2) & MISS_TID2_SM_L2(3) & 
    MISS_TID2_SM_L2(4) & MISS_TID2_SM_L2(5) & 
    MISS_TID2_SM_L2(8) & MISS_TID2_SM_L2(9) & 
    MISS_TID2_SM_L2(10) & MISS_TID2_SM_L2(11) & 
    MISS_TID2_SM_L2(12) & MISS_TID2_SM_L2(13) & 
    MISS_TID2_SM_L2(14) & MISS_TID2_SM_L2(15) & 
    MISS_TID2_SM_L2(16) & MISS_TID2_SM_L2(17) & 
    MISS_TID2_SM_L2(18) & MISS_TID2_SM_L2(19)
     ) , STD_ULOGIC_VECTOR'("000000000000000000"));
MQQ159:IU2_SM_2_PT(3) <=
    Eq(( RELD_R1_TID_L2(2) & MISS_TID2_SM_L2(0) & 
    MISS_TID2_SM_L2(1) & MISS_TID2_SM_L2(2) & 
    MISS_TID2_SM_L2(3) & MISS_TID2_SM_L2(5) & 
    MISS_TID2_SM_L2(6) & MISS_TID2_SM_L2(7) & 
    MISS_TID2_SM_L2(8) & MISS_TID2_SM_L2(10) & 
    MISS_TID2_SM_L2(11) & MISS_TID2_SM_L2(12) & 
    MISS_TID2_SM_L2(13) & MISS_TID2_SM_L2(14) & 
    MISS_TID2_SM_L2(15) & MISS_TID2_SM_L2(16) & 
    MISS_TID2_SM_L2(17) & MISS_TID2_SM_L2(18) & 
    MISS_TID2_SM_L2(19) ) , STD_ULOGIC_VECTOR'("0000000000000000000"));
MQQ160:IU2_SM_2_PT(4) <=
    Eq(( RELD_R1_TID_L2(2) & MISS_TID2_SM_L2(0) & 
    MISS_TID2_SM_L2(1) & MISS_TID2_SM_L2(2) & 
    MISS_TID2_SM_L2(3) & MISS_TID2_SM_L2(5) & 
    MISS_TID2_SM_L2(7) & MISS_TID2_SM_L2(8) & 
    MISS_TID2_SM_L2(10) & MISS_TID2_SM_L2(11) & 
    MISS_TID2_SM_L2(12) & MISS_TID2_SM_L2(13) & 
    MISS_TID2_SM_L2(14) & MISS_TID2_SM_L2(15) & 
    MISS_TID2_SM_L2(16) & MISS_TID2_SM_L2(17) & 
    MISS_TID2_SM_L2(18) & MISS_TID2_SM_L2(19)
     ) , STD_ULOGIC_VECTOR'("100000000000000000"));
MQQ161:IU2_SM_2_PT(5) <=
    Eq(( MISS_FLUSHED2_L2 & MISS_INVAL2_L2 & 
    MISS_TID2_SM_L2(0) & MISS_TID2_SM_L2(1) & 
    MISS_TID2_SM_L2(2) & MISS_TID2_SM_L2(6) & 
    MISS_TID2_SM_L2(7) & MISS_TID2_SM_L2(8) & 
    MISS_TID2_SM_L2(9) & MISS_TID2_SM_L2(10) & 
    MISS_TID2_SM_L2(11) & MISS_TID2_SM_L2(16) & 
    MISS_TID2_SM_L2(17) & MISS_TID2_SM_L2(18) & 
    MISS_TID2_SM_L2(19) ) , STD_ULOGIC_VECTOR'("000000000000000"));
MQQ162:IU2_SM_2_PT(6) <=
    Eq(( R2_CRIT_QW_L2 & MISS_FLUSHED2_L2 & 
    MISS_TID2_SM_L2(0) & MISS_TID2_SM_L2(1) & 
    MISS_TID2_SM_L2(2) & MISS_TID2_SM_L2(8) & 
    MISS_TID2_SM_L2(9) & MISS_TID2_SM_L2(10) & 
    MISS_TID2_SM_L2(11) & MISS_TID2_SM_L2(16) & 
    MISS_TID2_SM_L2(17) & MISS_TID2_SM_L2(18) & 
    MISS_TID2_SM_L2(19) ) , STD_ULOGIC_VECTOR'("1000000000000"));
MQQ163:IU2_SM_2_PT(7) <=
    Eq(( RELD_R1_TID_L2(2) & MISS_TID2_SM_L2(0) & 
    MISS_TID2_SM_L2(1) & MISS_TID2_SM_L2(2) & 
    MISS_TID2_SM_L2(3) & MISS_TID2_SM_L2(4) & 
    MISS_TID2_SM_L2(5) & MISS_TID2_SM_L2(6) & 
    MISS_TID2_SM_L2(7) & MISS_TID2_SM_L2(8) & 
    MISS_TID2_SM_L2(9) & MISS_TID2_SM_L2(10) & 
    MISS_TID2_SM_L2(11) & MISS_TID2_SM_L2(13) & 
    MISS_TID2_SM_L2(14) & MISS_TID2_SM_L2(15) & 
    MISS_TID2_SM_L2(16) & MISS_TID2_SM_L2(18) & 
    MISS_TID2_SM_L2(19) ) , STD_ULOGIC_VECTOR'("0000000000000000000"));
MQQ164:IU2_SM_2_PT(8) <=
    Eq(( RELD_R1_TID_L2(2) & MISS_TID2_SM_L2(0) & 
    MISS_TID2_SM_L2(1) & MISS_TID2_SM_L2(2) & 
    MISS_TID2_SM_L2(3) & MISS_TID2_SM_L2(4) & 
    MISS_TID2_SM_L2(5) & MISS_TID2_SM_L2(7) & 
    MISS_TID2_SM_L2(8) & MISS_TID2_SM_L2(9) & 
    MISS_TID2_SM_L2(10) & MISS_TID2_SM_L2(11) & 
    MISS_TID2_SM_L2(13) & MISS_TID2_SM_L2(14) & 
    MISS_TID2_SM_L2(15) & MISS_TID2_SM_L2(16) & 
    MISS_TID2_SM_L2(18) & MISS_TID2_SM_L2(19)
     ) , STD_ULOGIC_VECTOR'("100000000000000000"));
MQQ165:IU2_SM_2_PT(9) <=
    Eq(( RELD_R1_TID_L2(2) & MISS_TID2_SM_L2(0) & 
    MISS_TID2_SM_L2(1) & MISS_TID2_SM_L2(2) & 
    MISS_TID2_SM_L2(3) & MISS_TID2_SM_L2(4) & 
    MISS_TID2_SM_L2(5) & MISS_TID2_SM_L2(6) & 
    MISS_TID2_SM_L2(7) & MISS_TID2_SM_L2(8) & 
    MISS_TID2_SM_L2(9) & MISS_TID2_SM_L2(10) & 
    MISS_TID2_SM_L2(11) & MISS_TID2_SM_L2(12) & 
    MISS_TID2_SM_L2(13) & MISS_TID2_SM_L2(15) & 
    MISS_TID2_SM_L2(16) & MISS_TID2_SM_L2(17) & 
    MISS_TID2_SM_L2(18) ) , STD_ULOGIC_VECTOR'("0000000000000000000"));
MQQ166:IU2_SM_2_PT(10) <=
    Eq(( RELD_R1_TID_L2(2) & MISS_TID2_SM_L2(0) & 
    MISS_TID2_SM_L2(1) & MISS_TID2_SM_L2(2) & 
    MISS_TID2_SM_L2(3) & MISS_TID2_SM_L2(4) & 
    MISS_TID2_SM_L2(5) & MISS_TID2_SM_L2(7) & 
    MISS_TID2_SM_L2(8) & MISS_TID2_SM_L2(9) & 
    MISS_TID2_SM_L2(10) & MISS_TID2_SM_L2(11) & 
    MISS_TID2_SM_L2(12) & MISS_TID2_SM_L2(13) & 
    MISS_TID2_SM_L2(15) & MISS_TID2_SM_L2(16) & 
    MISS_TID2_SM_L2(17) & MISS_TID2_SM_L2(18)
     ) , STD_ULOGIC_VECTOR'("100000000000000000"));
MQQ167:IU2_SM_2_PT(11) <=
    Eq(( MISS_TID2_SM_L2(18) ) , STD_ULOGIC'('1'));
MQQ168:IU2_SM_2_PT(12) <=
    Eq(( MISS_TID2_SM_L2(16) ) , STD_ULOGIC'('1'));
MQQ169:IU2_SM_2_PT(13) <=
    Eq(( RELD_R1_TID_L2(2) & MISS_TID2_SM_L2(15)
     ) , STD_ULOGIC_VECTOR'("01"));
MQQ170:IU2_SM_2_PT(14) <=
    Eq(( RELD_R1_TID_L2(2) & MISS_TID2_SM_L2(15)
     ) , STD_ULOGIC_VECTOR'("11"));
MQQ171:IU2_SM_2_PT(15) <=
    Eq(( RELD_R1_TID_L2(2) & MISS_TID2_SM_L2(13)
     ) , STD_ULOGIC_VECTOR'("01"));
MQQ172:IU2_SM_2_PT(16) <=
    Eq(( RELD_R1_TID_L2(2) & MISS_TID2_SM_L2(13)
     ) , STD_ULOGIC_VECTOR'("11"));
MQQ173:IU2_SM_2_PT(17) <=
    Eq(( MISS_TID2_SM_L2(0) & MISS_TID2_SM_L2(1) & 
    MISS_TID2_SM_L2(2) & MISS_TID2_SM_L2(6) & 
    MISS_TID2_SM_L2(7) & MISS_TID2_SM_L2(11)
     ) , STD_ULOGIC_VECTOR'("000000"));
MQQ174:IU2_SM_2_PT(18) <=
    Eq(( ERAT_ERR(2) & MISS_TID2_SM_L2(0) & 
    MISS_TID2_SM_L2(6) & MISS_TID2_SM_L2(7) & 
    MISS_TID2_SM_L2(11) ) , STD_ULOGIC_VECTOR'("00000"));
MQQ175:IU2_SM_2_PT(19) <=
    Eq(( ECC_ERR(2) & MISS_TID2_SM_L2(11)
     ) , STD_ULOGIC_VECTOR'("01"));
MQQ176:IU2_SM_2_PT(20) <=
    Eq(( ECC_ERR(2) & MISS_TID2_SM_L2(11)
     ) , STD_ULOGIC_VECTOR'("11"));
MQQ177:IU2_SM_2_PT(21) <=
    Eq(( MISS_TID2_SM_L2(10) ) , STD_ULOGIC'('1'));
MQQ178:IU2_SM_2_PT(22) <=
    Eq(( MISS_TID2_SM_L2(8) ) , STD_ULOGIC'('1'));
MQQ179:IU2_SM_2_PT(23) <=
    Eq(( ECC_ERR(2) & MISS_TID2_SM_L2(0) & 
    MISS_TID2_SM_L2(1) & MISS_TID2_SM_L2(2) & 
    MISS_TID2_SM_L2(7) ) , STD_ULOGIC_VECTOR'("10000"));
MQQ180:IU2_SM_2_PT(24) <=
    Eq(( MISS_FLUSHED2_L2 & MISS_TID2_SM_L2(7)
     ) , STD_ULOGIC_VECTOR'("01"));
MQQ181:IU2_SM_2_PT(25) <=
    Eq(( ECC_ERR(2) & ECC_ERR_UE(2) & 
    MISS_FLUSHED2_L2 & MISS_INVAL2_L2 & 
    MISS_TID2_SM_L2(6) ) , STD_ULOGIC_VECTOR'("00001"));
MQQ182:IU2_SM_2_PT(26) <=
    Eq(( MISS_FLUSHED2_L2 & MISS_INVAL2_L2 & 
    MISS_TID2_SM_L2(6) ) , STD_ULOGIC_VECTOR'("001"));
MQQ183:IU2_SM_2_PT(27) <=
    Eq(( MISS_INVAL2_L2 & MISS_TID2_SM_L2(6)
     ) , STD_ULOGIC_VECTOR'("11"));
MQQ184:IU2_SM_2_PT(28) <=
    Eq(( MISS_FLUSHED2_L2 & MISS_TID2_SM_L2(6)
     ) , STD_ULOGIC_VECTOR'("11"));
MQQ185:IU2_SM_2_PT(29) <=
    Eq(( ECC_ERR_UE(2) & MISS_TID2_SM_L2(6)
     ) , STD_ULOGIC_VECTOR'("11"));
MQQ186:IU2_SM_2_PT(30) <=
    Eq(( RELD_R1_TID_L2(2) & SPR_IC_CLS_L2 & 
    MISS_TID2_SM_L2(5) ) , STD_ULOGIC_VECTOR'("001"));
MQQ187:IU2_SM_2_PT(31) <=
    Eq(( RELD_R1_TID_L2(2) & SPR_IC_CLS_L2 & 
    MISS_TID2_SM_L2(5) ) , STD_ULOGIC_VECTOR'("101"));
MQQ188:IU2_SM_2_PT(32) <=
    Eq(( RELD_R1_TID_L2(2) & SPR_IC_CLS_L2 & 
    MISS_TID2_SM_L2(5) ) , STD_ULOGIC_VECTOR'("011"));
MQQ189:IU2_SM_2_PT(33) <=
    Eq(( RELD_R1_TID_L2(2) & SPR_IC_CLS_L2 & 
    MISS_TID2_SM_L2(5) ) , STD_ULOGIC_VECTOR'("111"));
MQQ190:IU2_SM_2_PT(34) <=
    Eq(( MISS_FLUSHED2_L2 & MISS_INVAL2_L2 & 
    MISS_TID2_SM_L2(3) ) , STD_ULOGIC_VECTOR'("001"));
MQQ191:IU2_SM_2_PT(35) <=
    Eq(( RELD_R1_TID_L2(2) & MISS_TID2_SM_L2(3)
     ) , STD_ULOGIC_VECTOR'("01"));
MQQ192:IU2_SM_2_PT(36) <=
    Eq(( RELD_R1_TID_L2(2) & MISS_TID2_SM_L2(3)
     ) , STD_ULOGIC_VECTOR'("11"));
MQQ193:IU2_SM_2_PT(37) <=
    Eq(( ERAT_ERR(2) & ICS_ICM_IU2_FLUSH_TID(2) & 
    RELEASE_SM & MISS_TID2_SM_L2(2)
     ) , STD_ULOGIC_VECTOR'("0001"));
MQQ194:IU2_SM_2_PT(38) <=
    Eq(( RELEASE_SM & MISS_TID2_SM_L2(2)
     ) , STD_ULOGIC_VECTOR'("11"));
MQQ195:IU2_SM_2_PT(39) <=
    Eq(( ERAT_ERR(2) & MISS_TID2_SM_L2(2)
     ) , STD_ULOGIC_VECTOR'("11"));
MQQ196:IU2_SM_2_PT(40) <=
    Eq(( ERAT_ERR(2) & RELD_R1_TID_L2(2) & 
    MISS_TID2_SM_L2(1) ) , STD_ULOGIC_VECTOR'("001"));
MQQ197:IU2_SM_2_PT(41) <=
    Eq(( ERAT_ERR(2) & MISS_CI2_L2 & 
    RELD_R1_TID_L2(2) & MISS_TID2_SM_L2(1)
     ) , STD_ULOGIC_VECTOR'("0011"));
MQQ198:IU2_SM_2_PT(42) <=
    Eq(( ERAT_ERR(2) & MISS_CI2_L2 & 
    RELD_R1_TID_L2(2) & MISS_TID2_SM_L2(1)
     ) , STD_ULOGIC_VECTOR'("0111"));
MQQ199:IU2_SM_2_PT(43) <=
    Eq(( ERAT_ERR(2) & MISS_TID2_SM_L2(1)
     ) , STD_ULOGIC_VECTOR'("11"));
MQQ200:IU2_SM_2_PT(44) <=
    Eq(( ICD_ICM_MISS & ICD_ICM_TID(2) & 
    ICD_ICM_WIMGE(1) & ADDR_MATCH & 
    ICS_ICM_IU2_FLUSH_TID(2) & RELEASE_SM & 
    MISS_TID2_SM_L2(0) ) , STD_ULOGIC_VECTOR'("1101001"));
MQQ201:IU2_SM_2_PT(45) <=
    Eq(( ICD_ICM_WIMGE(1) & ADDR_MATCH & 
    RELEASE_SM & MISS_TID2_SM_L2(0)
     ) , STD_ULOGIC_VECTOR'("0111"));
MQQ202:IU2_SM_2_PT(46) <=
    Eq(( ICD_ICM_MISS & ICD_ICM_TID(2) & 
    ADDR_MATCH & ICS_ICM_IU2_FLUSH_TID(2) & 
    MISS_TID2_SM_L2(0) ) , STD_ULOGIC_VECTOR'("11001"));
MQQ203:IU2_SM_2_PT(47) <=
    Eq(( ICD_ICM_MISS & ICD_ICM_TID(2) & 
    ICD_ICM_WIMGE(1) & ICS_ICM_IU2_FLUSH_TID(2) & 
    MISS_TID2_SM_L2(0) ) , STD_ULOGIC_VECTOR'("11101"));
MQQ204:IU2_SM_2_PT(48) <=
    Eq(( ICD_ICM_TID(2) & MISS_TID2_SM_L2(0)
     ) , STD_ULOGIC_VECTOR'("01"));
MQQ205:IU2_SM_2_PT(49) <=
    Eq(( ICD_ICM_MISS & MISS_TID2_SM_L2(0)
     ) , STD_ULOGIC_VECTOR'("01"));
-- Table IU2_SM_2 Signal Assignments for Outputs
MQQ206:MISS_TID2_SM_D(0) <= 
    (IU2_SM_2_PT(1) OR IU2_SM_2_PT(19)
     OR IU2_SM_2_PT(38) OR IU2_SM_2_PT(39)
     OR IU2_SM_2_PT(43) OR IU2_SM_2_PT(45)
     OR IU2_SM_2_PT(48) OR IU2_SM_2_PT(49)
    );
MQQ207:MISS_TID2_SM_D(1) <= 
    (IU2_SM_2_PT(20) OR IU2_SM_2_PT(40)
     OR IU2_SM_2_PT(46) OR IU2_SM_2_PT(47)
    );
MQQ208:MISS_TID2_SM_D(2) <= 
    (IU2_SM_2_PT(37) OR IU2_SM_2_PT(44)
    );
MQQ209:MISS_TID2_SM_D(3) <= 
    (IU2_SM_2_PT(41));
MQQ210:MISS_TID2_SM_D(4) <= 
    (IU2_SM_2_PT(22) OR IU2_SM_2_PT(36)
    );
MQQ211:MISS_TID2_SM_D(5) <= 
    (IU2_SM_2_PT(4));
MQQ212:MISS_TID2_SM_D(6) <= 
    (IU2_SM_2_PT(14) OR IU2_SM_2_PT(21)
     OR IU2_SM_2_PT(31));
MQQ213:MISS_TID2_SM_D(7) <= 
    (IU2_SM_2_PT(42));
MQQ214:MISS_TID2_SM_D(8) <= 
    (IU2_SM_2_PT(35));
MQQ215:MISS_TID2_SM_D(9) <= 
    (IU2_SM_2_PT(3));
MQQ216:MISS_TID2_SM_D(10) <= 
    (IU2_SM_2_PT(13) OR IU2_SM_2_PT(30)
    );
MQQ217:MISS_TID2_SM_D(11) <= 
    (IU2_SM_2_PT(2));
MQQ218:MISS_TID2_SM_D(12) <= 
    (IU2_SM_2_PT(12) OR IU2_SM_2_PT(33)
    );
MQQ219:MISS_TID2_SM_D(13) <= 
    (IU2_SM_2_PT(8));
MQQ220:MISS_TID2_SM_D(14) <= 
    (IU2_SM_2_PT(11) OR IU2_SM_2_PT(16)
    );
MQQ221:MISS_TID2_SM_D(15) <= 
    (IU2_SM_2_PT(10));
MQQ222:MISS_TID2_SM_D(16) <= 
    (IU2_SM_2_PT(32));
MQQ223:MISS_TID2_SM_D(17) <= 
    (IU2_SM_2_PT(7));
MQQ224:MISS_TID2_SM_D(18) <= 
    (IU2_SM_2_PT(15));
MQQ225:MISS_TID2_SM_D(19) <= 
    (IU2_SM_2_PT(9));
MQQ226:RESET_STATE(2) <= 
    (IU2_SM_2_PT(19) OR IU2_SM_2_PT(43)
    );
MQQ227:REQUEST_TID(2) <= 
    (IU2_SM_2_PT(46) OR IU2_SM_2_PT(47)
    );
MQQ228:WRITE_DIR_INVAL(2) <= 
    (IU2_SM_2_PT(34));
MQQ229:WRITE_DIR_VAL(2) <= 
    (IU2_SM_2_PT(25));
MQQ230:HOLD_TID(2) <= 
    (IU2_SM_2_PT(17) OR IU2_SM_2_PT(18)
     OR IU2_SM_2_PT(23) OR IU2_SM_2_PT(27)
     OR IU2_SM_2_PT(28) OR IU2_SM_2_PT(29)
    );
MQQ231:DATA_WRITE(2) <= 
    (IU2_SM_2_PT(5) OR IU2_SM_2_PT(26)
    );
MQQ232:DIR_WRITE(2) <= 
    (IU2_SM_2_PT(5));
MQQ233:LOAD_TID(2) <= 
    (IU2_SM_2_PT(6) OR IU2_SM_2_PT(24)
    );
MQQ234:RELEASE_SM_HOLD(2) <= 
    (IU2_SM_2_PT(2) OR IU2_SM_2_PT(19)
     OR IU2_SM_2_PT(43));

--
-- Final Table Listing
--      *INPUTS*================================================*OUTPUTS*======================================================*
--      |                                                       |                                                              |
--      | icd_icm_miss                                          |  miss_tid3_sm_d                                              |
--      | | icd_icm_tid(3)                                      |  |                                                           |
--      | | | icd_icm_wimge(1)                                  |  |                    reset_state(3)                         | -- WIMGE(1): Cache Inhibit
--      | | | | erat_err(3)                                     |  |                    |                                      |
--      | | | | | miss_ci3_l2                                   |  |                    |  request_tid(3)                      |
--      | | | | | | reld_r1_tid_l2(3)                           |  |                    |  | write_dir_inval(3)                |
--      | | | | | | | r2_crit_qw_l2                             |  |                    |  | | write_dir_val(3)                |
--      | | | | | | | | ecc_err(3)                              |  |                    |  | | |                               |
--      | | | | | | | | | ecc_err_ue(3)                         |  |                    |  | | |                               |
--      | | | | | | | | | |                                     |  |                    |  | | |                               |
--      | | | | | | | | | |   spr_ic_cls_l2                     |  |                    |  | | |                               |
--      | | | | | | | | | |   | addr_match                      |  |                    |  | | |                               |
--      | | | | | | | | | |   | | ics_icm_iu2_flush_tid(3)      |  |                    |  | | | hold_tid(3)                   | -- this hold 1 tid and gates iu2
--      | | | | | | | | | |   | | | release_sm                  |  |                    |  | | | |                             |
--      | | | | | | | | | |   | | | | miss_flushed3_l2          |  |                    |  | | | |                             |
--      | | | | | | | | | |   | | | | | miss_inval3_l2          |  |                    |  | | | |                             |
--      | | | | | | | | | |   | | | | | | miss_tid3_sm_l2       |  |                    |  | | | |                             |
--      | | | | | | | | | |   | | | | | | |                     |  |                    |  | | | |                             |
--      | | | | | | | | | |   | | | | | | |                     |  |                    |  | | | |   data_write(3)             |
--      | | | | | | | | | |   | | | | | | |                     |  |                    |  | | | |   | dir_write(3)            |
--      | | | | | | | | | |   | | | | | | |                     |  |                    |  | | | |   | |                       |
--      | | | | | | | | | |   | | | | | | |                     |  |                    |  | | | |   | | load_tid(3)           |
--      | | | | | | | | | |   | | | | | | |                     |  |                    |  | | | |   | | |                     |
--      | | | | | | | | | |   | | | | | | |                     |  |                    |  | | | |   | | | release_sm_hold(3)|
--      | | | | | | | | | |   | | | | | | |                     |  |                    |  | | | |   | | | |                   |
--      | | | | | | | | | |   | | | | | | |                     |  |                    |  | | | |   | | | |                   |
--      | | | | | | | | | |   | | | | | | |         1111111111  |  |         1111111111 |  | | | |   | | | |                   |
--      | | | | | | | | | |   | | | | | | 01234567890123456789  |  01234567890123456789 |  | | | |   | | | |                   |
--      *TYPE*==================================================+==============================================================+
--      | P P P P P P P P P   P P P P P P PPPPPPPPPPPPPPPPPPPP  |  PPPPPPPPPPPPPPPPPPPP P  P P P P   P P P P                   |
--      *POLARITY*--------------------------------------------->|  ++++++++++++++++++++ +  + + + +   + + + +                   |
--      *PHASE*------------------------------------------------>|  TTTTTTTTTTTTTTTTTTTT T  T T T T   T T T T                   |
--      *OPTIMIZE*--------------------------------------------->|   AAAAAAAAAAAAAAAAAAAA A  A A A B   A A A A                    |
--      *TERMS*=================================================+==============================================================+
--    1 | - - - - - - - - -   - - 1 - - - -0-00000000000000000  |  1................... .  . . . .   . . . .                   |
--    2 | - - - - - - - - -   - - - - - - 000000--000000000000  |  ...........1........ .  . . . .   . . . 1                   |
--    3 | - - - - - 0 - - -   - - - - - - 0000-0000-0000000000  |  .........1.......... .  . . . .   . . . .                   |
--    4 | - - - - - 1 - - -   - - - - - - 0000-0-00-0000000000  |  .....1.............. .  . . . .   . . . .                   |
--    5 | - - - - - - - - -   - - - - 0 0 000---000000----0000  |  .................... .  . . . .   1 1 . .                   |
--    6 | - - - - - - 1 - -   - - - - 0 - 000-----0000----0000  |  .................... .  . . . .   . . 1 .                   |
--    7 | - - - - - 0 - - -   - - - - - - 000000000000-0000-00  |  .................1.. .  . . . .   . . . .                   |
--    8 | - - - - - 1 - - -   - - - - - - 000000-00000-0000-00  |  .............1...... .  . . . .   . . . .                   |
--    9 | - - - - - 0 - - -   - - - - - - 00000000000000-0000-  |  ...................1 .  . . . .   . . . .                   |
--   10 | - - - - - 1 - - -   - - - - - - 000000-0000000-0000-  |  ...............1.... .  . . . .   . . . .                   |
--   11 | - - - - - - - - -   - - - - - - ------------------1-  |  ..............1..... .  . . . .   . . . .                   |
--   12 | - - - - - - - - -   - - - - - - ----------------1---  |  ............1....... .  . . . .   . . . .                   |
--   13 | - - - - - 0 - - -   - - - - - - ---------------1----  |  ..........1......... .  . . . .   . . . .                   |
--   14 | - - - - - 1 - - -   - - - - - - ---------------1----  |  ......1............. .  . . . .   . . . .                   |
--   15 | - - - - - 0 - - -   - - - - - - -------------1------  |  ..................1. .  . . . .   . . . .                   |
--   16 | - - - - - 1 - - -   - - - - - - -------------1------  |  ..............1..... .  . . . .   . . . .                   |
--   17 | - - - - - - - - -   - - - - - - 000---00---0--------  |  .................... .  . . . 1   . . . .                   |
--   18 | - - - 0 - - - - -   - - - - - - 0-----00---0--------  |  .................... .  . . . 1   . . . .                   |
--   19 | - - - - - - - 0 -   - - - - - - -----------1--------  |  1................... 1  . . . .   . . . 1                   |
--   20 | - - - - - - - 1 -   - - - - - - -----------1--------  |  .1.................. .  . . . .   . . . .                   |
--   21 | - - - - - - - - -   - - - - - - ----------1---------  |  ......1............. .  . . . .   . . . .                   |
--   22 | - - - - - - - - -   - - - - - - --------1-----------  |  ....1............... .  . . . .   . . . .                   |
--   23 | - - - - - - - 1 -   - - - - - - 000----0------------  |  .................... .  . . . 1   . . . .                   |
--   24 | - - - - - - - - -   - - - - 0 - -------1------------  |  .................... .  . . . .   . . 1 .                   |
--   25 | - - - - - - - 0 0   - - - - 0 0 ------1-------------  |  .................... .  . . 1 .   . . . .                   |
--   26 | - - - - - - - - -   - - - - 0 0 ------1-------------  |  .................... .  . . . .   1 . . .                   |
--   27 | - - - - - - - - -   - - - - - 1 ------1-------------  |  .................... .  . . . 1   . . . .                   |
--   28 | - - - - - - - - -   - - - - 1 - ------1-------------  |  .................... .  . . . 1   . . . .                   |
--   29 | - - - - - - - - 1   - - - - - - ------1-------------  |  .................... .  . . . 1   . . . .                   |
--   30 | - - - - - 0 - - -   0 - - - - - -----1--------------  |  ..........1......... .  . . . .   . . . .                   |
--   31 | - - - - - 1 - - -   0 - - - - - -----1--------------  |  ......1............. .  . . . .   . . . .                   |
--   32 | - - - - - 0 - - -   1 - - - - - -----1--------------  |  ................1... .  . . . .   . . . .                   |
--   33 | - - - - - 1 - - -   1 - - - - - -----1--------------  |  ............1....... .  . . . .   . . . .                   |
--   34 | - - - - - - - - -   - - - - 0 0 ---1----------------  |  .................... .  . 1 . .   . . . .                   |
--   35 | - - - - - 0 - - -   - - - - - - ---1----------------  |  ........1........... .  . . . .   . . . .                   |
--   36 | - - - - - 1 - - -   - - - - - - ---1----------------  |  ....1............... .  . . . .   . . . .                   |
--   37 | - - - 0 - - - - -   - - 0 0 - - --1-----------------  |  ..1................. .  . . . .   . . . .                   |
--   38 | - - - - - - - - -   - - - 1 - - --1-----------------  |  1................... .  . . . .   . . . .                   |
--   39 | - - - 1 - - - - -   - - - - - - --1-----------------  |  1................... .  . . . .   . . . .                   |
--   40 | - - - 0 - 0 - - -   - - - - - - -1------------------  |  .1.................. .  . . . .   . . . .                   |
--   41 | - - - 0 0 1 - - -   - - - - - - -1------------------  |  ...1................ .  . . . .   . . . .                   |
--   42 | - - - 0 1 1 - - -   - - - - - - -1------------------  |  .......1............ .  . . . .   . . . .                   |
--   43 | - - - 1 - - - - -   - - - - - - -1------------------  |  1................... 1  . . . .   . . . 1                   |
--   44 | 1 1 0 - - - - - -   - 1 0 0 - - 1-------------------  |  ..1................. .  . . . .   . . . .                   |
--   45 | - - 0 - - - - - -   - 1 - 1 - - 1-------------------  |  1................... .  . . . .   . . . .                   |
--   46 | 1 1 - - - - - - -   - 0 0 - - - 1-------------------  |  .1.................. .  1 . . .   . . . .                   |
--   47 | 1 1 1 - - - - - -   - - 0 - - - 1-------------------  |  .1.................. .  1 . . .   . . . .                   |
--   48 | - 0 - - - - - - -   - - - - - - 1-------------------  |  1................... .  . . . .   . . . .                   |
--   49 | 0 - - - - - - - -   - - - - - - 1-------------------  |  1................... .  . . . .   . . . .                   |
--      *======================================================================================================================*
--
-- Table IU2_SM_3 Signal Assignments for Product Terms
MQQ235:IU2_SM_3_PT(1) <=
    Eq(( ICS_ICM_IU2_FLUSH_TID(3) & MISS_TID3_SM_L2(1) & 
    MISS_TID3_SM_L2(3) & MISS_TID3_SM_L2(4) & 
    MISS_TID3_SM_L2(5) & MISS_TID3_SM_L2(6) & 
    MISS_TID3_SM_L2(7) & MISS_TID3_SM_L2(8) & 
    MISS_TID3_SM_L2(9) & MISS_TID3_SM_L2(10) & 
    MISS_TID3_SM_L2(11) & MISS_TID3_SM_L2(12) & 
    MISS_TID3_SM_L2(13) & MISS_TID3_SM_L2(14) & 
    MISS_TID3_SM_L2(15) & MISS_TID3_SM_L2(16) & 
    MISS_TID3_SM_L2(17) & MISS_TID3_SM_L2(18) & 
    MISS_TID3_SM_L2(19) ) , STD_ULOGIC_VECTOR'("1000000000000000000"));
MQQ236:IU2_SM_3_PT(2) <=
    Eq(( MISS_TID3_SM_L2(0) & MISS_TID3_SM_L2(1) & 
    MISS_TID3_SM_L2(2) & MISS_TID3_SM_L2(3) & 
    MISS_TID3_SM_L2(4) & MISS_TID3_SM_L2(5) & 
    MISS_TID3_SM_L2(8) & MISS_TID3_SM_L2(9) & 
    MISS_TID3_SM_L2(10) & MISS_TID3_SM_L2(11) & 
    MISS_TID3_SM_L2(12) & MISS_TID3_SM_L2(13) & 
    MISS_TID3_SM_L2(14) & MISS_TID3_SM_L2(15) & 
    MISS_TID3_SM_L2(16) & MISS_TID3_SM_L2(17) & 
    MISS_TID3_SM_L2(18) & MISS_TID3_SM_L2(19)
     ) , STD_ULOGIC_VECTOR'("000000000000000000"));
MQQ237:IU2_SM_3_PT(3) <=
    Eq(( RELD_R1_TID_L2(3) & MISS_TID3_SM_L2(0) & 
    MISS_TID3_SM_L2(1) & MISS_TID3_SM_L2(2) & 
    MISS_TID3_SM_L2(3) & MISS_TID3_SM_L2(5) & 
    MISS_TID3_SM_L2(6) & MISS_TID3_SM_L2(7) & 
    MISS_TID3_SM_L2(8) & MISS_TID3_SM_L2(10) & 
    MISS_TID3_SM_L2(11) & MISS_TID3_SM_L2(12) & 
    MISS_TID3_SM_L2(13) & MISS_TID3_SM_L2(14) & 
    MISS_TID3_SM_L2(15) & MISS_TID3_SM_L2(16) & 
    MISS_TID3_SM_L2(17) & MISS_TID3_SM_L2(18) & 
    MISS_TID3_SM_L2(19) ) , STD_ULOGIC_VECTOR'("0000000000000000000"));
MQQ238:IU2_SM_3_PT(4) <=
    Eq(( RELD_R1_TID_L2(3) & MISS_TID3_SM_L2(0) & 
    MISS_TID3_SM_L2(1) & MISS_TID3_SM_L2(2) & 
    MISS_TID3_SM_L2(3) & MISS_TID3_SM_L2(5) & 
    MISS_TID3_SM_L2(7) & MISS_TID3_SM_L2(8) & 
    MISS_TID3_SM_L2(10) & MISS_TID3_SM_L2(11) & 
    MISS_TID3_SM_L2(12) & MISS_TID3_SM_L2(13) & 
    MISS_TID3_SM_L2(14) & MISS_TID3_SM_L2(15) & 
    MISS_TID3_SM_L2(16) & MISS_TID3_SM_L2(17) & 
    MISS_TID3_SM_L2(18) & MISS_TID3_SM_L2(19)
     ) , STD_ULOGIC_VECTOR'("100000000000000000"));
MQQ239:IU2_SM_3_PT(5) <=
    Eq(( MISS_FLUSHED3_L2 & MISS_INVAL3_L2 & 
    MISS_TID3_SM_L2(0) & MISS_TID3_SM_L2(1) & 
    MISS_TID3_SM_L2(2) & MISS_TID3_SM_L2(6) & 
    MISS_TID3_SM_L2(7) & MISS_TID3_SM_L2(8) & 
    MISS_TID3_SM_L2(9) & MISS_TID3_SM_L2(10) & 
    MISS_TID3_SM_L2(11) & MISS_TID3_SM_L2(16) & 
    MISS_TID3_SM_L2(17) & MISS_TID3_SM_L2(18) & 
    MISS_TID3_SM_L2(19) ) , STD_ULOGIC_VECTOR'("000000000000000"));
MQQ240:IU2_SM_3_PT(6) <=
    Eq(( R2_CRIT_QW_L2 & MISS_FLUSHED3_L2 & 
    MISS_TID3_SM_L2(0) & MISS_TID3_SM_L2(1) & 
    MISS_TID3_SM_L2(2) & MISS_TID3_SM_L2(8) & 
    MISS_TID3_SM_L2(9) & MISS_TID3_SM_L2(10) & 
    MISS_TID3_SM_L2(11) & MISS_TID3_SM_L2(16) & 
    MISS_TID3_SM_L2(17) & MISS_TID3_SM_L2(18) & 
    MISS_TID3_SM_L2(19) ) , STD_ULOGIC_VECTOR'("1000000000000"));
MQQ241:IU2_SM_3_PT(7) <=
    Eq(( RELD_R1_TID_L2(3) & MISS_TID3_SM_L2(0) & 
    MISS_TID3_SM_L2(1) & MISS_TID3_SM_L2(2) & 
    MISS_TID3_SM_L2(3) & MISS_TID3_SM_L2(4) & 
    MISS_TID3_SM_L2(5) & MISS_TID3_SM_L2(6) & 
    MISS_TID3_SM_L2(7) & MISS_TID3_SM_L2(8) & 
    MISS_TID3_SM_L2(9) & MISS_TID3_SM_L2(10) & 
    MISS_TID3_SM_L2(11) & MISS_TID3_SM_L2(13) & 
    MISS_TID3_SM_L2(14) & MISS_TID3_SM_L2(15) & 
    MISS_TID3_SM_L2(16) & MISS_TID3_SM_L2(18) & 
    MISS_TID3_SM_L2(19) ) , STD_ULOGIC_VECTOR'("0000000000000000000"));
MQQ242:IU2_SM_3_PT(8) <=
    Eq(( RELD_R1_TID_L2(3) & MISS_TID3_SM_L2(0) & 
    MISS_TID3_SM_L2(1) & MISS_TID3_SM_L2(2) & 
    MISS_TID3_SM_L2(3) & MISS_TID3_SM_L2(4) & 
    MISS_TID3_SM_L2(5) & MISS_TID3_SM_L2(7) & 
    MISS_TID3_SM_L2(8) & MISS_TID3_SM_L2(9) & 
    MISS_TID3_SM_L2(10) & MISS_TID3_SM_L2(11) & 
    MISS_TID3_SM_L2(13) & MISS_TID3_SM_L2(14) & 
    MISS_TID3_SM_L2(15) & MISS_TID3_SM_L2(16) & 
    MISS_TID3_SM_L2(18) & MISS_TID3_SM_L2(19)
     ) , STD_ULOGIC_VECTOR'("100000000000000000"));
MQQ243:IU2_SM_3_PT(9) <=
    Eq(( RELD_R1_TID_L2(3) & MISS_TID3_SM_L2(0) & 
    MISS_TID3_SM_L2(1) & MISS_TID3_SM_L2(2) & 
    MISS_TID3_SM_L2(3) & MISS_TID3_SM_L2(4) & 
    MISS_TID3_SM_L2(5) & MISS_TID3_SM_L2(6) & 
    MISS_TID3_SM_L2(7) & MISS_TID3_SM_L2(8) & 
    MISS_TID3_SM_L2(9) & MISS_TID3_SM_L2(10) & 
    MISS_TID3_SM_L2(11) & MISS_TID3_SM_L2(12) & 
    MISS_TID3_SM_L2(13) & MISS_TID3_SM_L2(15) & 
    MISS_TID3_SM_L2(16) & MISS_TID3_SM_L2(17) & 
    MISS_TID3_SM_L2(18) ) , STD_ULOGIC_VECTOR'("0000000000000000000"));
MQQ244:IU2_SM_3_PT(10) <=
    Eq(( RELD_R1_TID_L2(3) & MISS_TID3_SM_L2(0) & 
    MISS_TID3_SM_L2(1) & MISS_TID3_SM_L2(2) & 
    MISS_TID3_SM_L2(3) & MISS_TID3_SM_L2(4) & 
    MISS_TID3_SM_L2(5) & MISS_TID3_SM_L2(7) & 
    MISS_TID3_SM_L2(8) & MISS_TID3_SM_L2(9) & 
    MISS_TID3_SM_L2(10) & MISS_TID3_SM_L2(11) & 
    MISS_TID3_SM_L2(12) & MISS_TID3_SM_L2(13) & 
    MISS_TID3_SM_L2(15) & MISS_TID3_SM_L2(16) & 
    MISS_TID3_SM_L2(17) & MISS_TID3_SM_L2(18)
     ) , STD_ULOGIC_VECTOR'("100000000000000000"));
MQQ245:IU2_SM_3_PT(11) <=
    Eq(( MISS_TID3_SM_L2(18) ) , STD_ULOGIC'('1'));
MQQ246:IU2_SM_3_PT(12) <=
    Eq(( MISS_TID3_SM_L2(16) ) , STD_ULOGIC'('1'));
MQQ247:IU2_SM_3_PT(13) <=
    Eq(( RELD_R1_TID_L2(3) & MISS_TID3_SM_L2(15)
     ) , STD_ULOGIC_VECTOR'("01"));
MQQ248:IU2_SM_3_PT(14) <=
    Eq(( RELD_R1_TID_L2(3) & MISS_TID3_SM_L2(15)
     ) , STD_ULOGIC_VECTOR'("11"));
MQQ249:IU2_SM_3_PT(15) <=
    Eq(( RELD_R1_TID_L2(3) & MISS_TID3_SM_L2(13)
     ) , STD_ULOGIC_VECTOR'("01"));
MQQ250:IU2_SM_3_PT(16) <=
    Eq(( RELD_R1_TID_L2(3) & MISS_TID3_SM_L2(13)
     ) , STD_ULOGIC_VECTOR'("11"));
MQQ251:IU2_SM_3_PT(17) <=
    Eq(( MISS_TID3_SM_L2(0) & MISS_TID3_SM_L2(1) & 
    MISS_TID3_SM_L2(2) & MISS_TID3_SM_L2(6) & 
    MISS_TID3_SM_L2(7) & MISS_TID3_SM_L2(11)
     ) , STD_ULOGIC_VECTOR'("000000"));
MQQ252:IU2_SM_3_PT(18) <=
    Eq(( ERAT_ERR(3) & MISS_TID3_SM_L2(0) & 
    MISS_TID3_SM_L2(6) & MISS_TID3_SM_L2(7) & 
    MISS_TID3_SM_L2(11) ) , STD_ULOGIC_VECTOR'("00000"));
MQQ253:IU2_SM_3_PT(19) <=
    Eq(( ECC_ERR(3) & MISS_TID3_SM_L2(11)
     ) , STD_ULOGIC_VECTOR'("01"));
MQQ254:IU2_SM_3_PT(20) <=
    Eq(( ECC_ERR(3) & MISS_TID3_SM_L2(11)
     ) , STD_ULOGIC_VECTOR'("11"));
MQQ255:IU2_SM_3_PT(21) <=
    Eq(( MISS_TID3_SM_L2(10) ) , STD_ULOGIC'('1'));
MQQ256:IU2_SM_3_PT(22) <=
    Eq(( MISS_TID3_SM_L2(8) ) , STD_ULOGIC'('1'));
MQQ257:IU2_SM_3_PT(23) <=
    Eq(( ECC_ERR(3) & MISS_TID3_SM_L2(0) & 
    MISS_TID3_SM_L2(1) & MISS_TID3_SM_L2(2) & 
    MISS_TID3_SM_L2(7) ) , STD_ULOGIC_VECTOR'("10000"));
MQQ258:IU2_SM_3_PT(24) <=
    Eq(( MISS_FLUSHED3_L2 & MISS_TID3_SM_L2(7)
     ) , STD_ULOGIC_VECTOR'("01"));
MQQ259:IU2_SM_3_PT(25) <=
    Eq(( ECC_ERR(3) & ECC_ERR_UE(3) & 
    MISS_FLUSHED3_L2 & MISS_INVAL3_L2 & 
    MISS_TID3_SM_L2(6) ) , STD_ULOGIC_VECTOR'("00001"));
MQQ260:IU2_SM_3_PT(26) <=
    Eq(( MISS_FLUSHED3_L2 & MISS_INVAL3_L2 & 
    MISS_TID3_SM_L2(6) ) , STD_ULOGIC_VECTOR'("001"));
MQQ261:IU2_SM_3_PT(27) <=
    Eq(( MISS_INVAL3_L2 & MISS_TID3_SM_L2(6)
     ) , STD_ULOGIC_VECTOR'("11"));
MQQ262:IU2_SM_3_PT(28) <=
    Eq(( MISS_FLUSHED3_L2 & MISS_TID3_SM_L2(6)
     ) , STD_ULOGIC_VECTOR'("11"));
MQQ263:IU2_SM_3_PT(29) <=
    Eq(( ECC_ERR_UE(3) & MISS_TID3_SM_L2(6)
     ) , STD_ULOGIC_VECTOR'("11"));
MQQ264:IU2_SM_3_PT(30) <=
    Eq(( RELD_R1_TID_L2(3) & SPR_IC_CLS_L2 & 
    MISS_TID3_SM_L2(5) ) , STD_ULOGIC_VECTOR'("001"));
MQQ265:IU2_SM_3_PT(31) <=
    Eq(( RELD_R1_TID_L2(3) & SPR_IC_CLS_L2 & 
    MISS_TID3_SM_L2(5) ) , STD_ULOGIC_VECTOR'("101"));
MQQ266:IU2_SM_3_PT(32) <=
    Eq(( RELD_R1_TID_L2(3) & SPR_IC_CLS_L2 & 
    MISS_TID3_SM_L2(5) ) , STD_ULOGIC_VECTOR'("011"));
MQQ267:IU2_SM_3_PT(33) <=
    Eq(( RELD_R1_TID_L2(3) & SPR_IC_CLS_L2 & 
    MISS_TID3_SM_L2(5) ) , STD_ULOGIC_VECTOR'("111"));
MQQ268:IU2_SM_3_PT(34) <=
    Eq(( MISS_FLUSHED3_L2 & MISS_INVAL3_L2 & 
    MISS_TID3_SM_L2(3) ) , STD_ULOGIC_VECTOR'("001"));
MQQ269:IU2_SM_3_PT(35) <=
    Eq(( RELD_R1_TID_L2(3) & MISS_TID3_SM_L2(3)
     ) , STD_ULOGIC_VECTOR'("01"));
MQQ270:IU2_SM_3_PT(36) <=
    Eq(( RELD_R1_TID_L2(3) & MISS_TID3_SM_L2(3)
     ) , STD_ULOGIC_VECTOR'("11"));
MQQ271:IU2_SM_3_PT(37) <=
    Eq(( ERAT_ERR(3) & ICS_ICM_IU2_FLUSH_TID(3) & 
    RELEASE_SM & MISS_TID3_SM_L2(2)
     ) , STD_ULOGIC_VECTOR'("0001"));
MQQ272:IU2_SM_3_PT(38) <=
    Eq(( RELEASE_SM & MISS_TID3_SM_L2(2)
     ) , STD_ULOGIC_VECTOR'("11"));
MQQ273:IU2_SM_3_PT(39) <=
    Eq(( ERAT_ERR(3) & MISS_TID3_SM_L2(2)
     ) , STD_ULOGIC_VECTOR'("11"));
MQQ274:IU2_SM_3_PT(40) <=
    Eq(( ERAT_ERR(3) & RELD_R1_TID_L2(3) & 
    MISS_TID3_SM_L2(1) ) , STD_ULOGIC_VECTOR'("001"));
MQQ275:IU2_SM_3_PT(41) <=
    Eq(( ERAT_ERR(3) & MISS_CI3_L2 & 
    RELD_R1_TID_L2(3) & MISS_TID3_SM_L2(1)
     ) , STD_ULOGIC_VECTOR'("0011"));
MQQ276:IU2_SM_3_PT(42) <=
    Eq(( ERAT_ERR(3) & MISS_CI3_L2 & 
    RELD_R1_TID_L2(3) & MISS_TID3_SM_L2(1)
     ) , STD_ULOGIC_VECTOR'("0111"));
MQQ277:IU2_SM_3_PT(43) <=
    Eq(( ERAT_ERR(3) & MISS_TID3_SM_L2(1)
     ) , STD_ULOGIC_VECTOR'("11"));
MQQ278:IU2_SM_3_PT(44) <=
    Eq(( ICD_ICM_MISS & ICD_ICM_TID(3) & 
    ICD_ICM_WIMGE(1) & ADDR_MATCH & 
    ICS_ICM_IU2_FLUSH_TID(3) & RELEASE_SM & 
    MISS_TID3_SM_L2(0) ) , STD_ULOGIC_VECTOR'("1101001"));
MQQ279:IU2_SM_3_PT(45) <=
    Eq(( ICD_ICM_WIMGE(1) & ADDR_MATCH & 
    RELEASE_SM & MISS_TID3_SM_L2(0)
     ) , STD_ULOGIC_VECTOR'("0111"));
MQQ280:IU2_SM_3_PT(46) <=
    Eq(( ICD_ICM_MISS & ICD_ICM_TID(3) & 
    ADDR_MATCH & ICS_ICM_IU2_FLUSH_TID(3) & 
    MISS_TID3_SM_L2(0) ) , STD_ULOGIC_VECTOR'("11001"));
MQQ281:IU2_SM_3_PT(47) <=
    Eq(( ICD_ICM_MISS & ICD_ICM_TID(3) & 
    ICD_ICM_WIMGE(1) & ICS_ICM_IU2_FLUSH_TID(3) & 
    MISS_TID3_SM_L2(0) ) , STD_ULOGIC_VECTOR'("11101"));
MQQ282:IU2_SM_3_PT(48) <=
    Eq(( ICD_ICM_TID(3) & MISS_TID3_SM_L2(0)
     ) , STD_ULOGIC_VECTOR'("01"));
MQQ283:IU2_SM_3_PT(49) <=
    Eq(( ICD_ICM_MISS & MISS_TID3_SM_L2(0)
     ) , STD_ULOGIC_VECTOR'("01"));
-- Table IU2_SM_3 Signal Assignments for Outputs
MQQ284:MISS_TID3_SM_D(0) <= 
    (IU2_SM_3_PT(1) OR IU2_SM_3_PT(19)
     OR IU2_SM_3_PT(38) OR IU2_SM_3_PT(39)
     OR IU2_SM_3_PT(43) OR IU2_SM_3_PT(45)
     OR IU2_SM_3_PT(48) OR IU2_SM_3_PT(49)
    );
MQQ285:MISS_TID3_SM_D(1) <= 
    (IU2_SM_3_PT(20) OR IU2_SM_3_PT(40)
     OR IU2_SM_3_PT(46) OR IU2_SM_3_PT(47)
    );
MQQ286:MISS_TID3_SM_D(2) <= 
    (IU2_SM_3_PT(37) OR IU2_SM_3_PT(44)
    );
MQQ287:MISS_TID3_SM_D(3) <= 
    (IU2_SM_3_PT(41));
MQQ288:MISS_TID3_SM_D(4) <= 
    (IU2_SM_3_PT(22) OR IU2_SM_3_PT(36)
    );
MQQ289:MISS_TID3_SM_D(5) <= 
    (IU2_SM_3_PT(4));
MQQ290:MISS_TID3_SM_D(6) <= 
    (IU2_SM_3_PT(14) OR IU2_SM_3_PT(21)
     OR IU2_SM_3_PT(31));
MQQ291:MISS_TID3_SM_D(7) <= 
    (IU2_SM_3_PT(42));
MQQ292:MISS_TID3_SM_D(8) <= 
    (IU2_SM_3_PT(35));
MQQ293:MISS_TID3_SM_D(9) <= 
    (IU2_SM_3_PT(3));
MQQ294:MISS_TID3_SM_D(10) <= 
    (IU2_SM_3_PT(13) OR IU2_SM_3_PT(30)
    );
MQQ295:MISS_TID3_SM_D(11) <= 
    (IU2_SM_3_PT(2));
MQQ296:MISS_TID3_SM_D(12) <= 
    (IU2_SM_3_PT(12) OR IU2_SM_3_PT(33)
    );
MQQ297:MISS_TID3_SM_D(13) <= 
    (IU2_SM_3_PT(8));
MQQ298:MISS_TID3_SM_D(14) <= 
    (IU2_SM_3_PT(11) OR IU2_SM_3_PT(16)
    );
MQQ299:MISS_TID3_SM_D(15) <= 
    (IU2_SM_3_PT(10));
MQQ300:MISS_TID3_SM_D(16) <= 
    (IU2_SM_3_PT(32));
MQQ301:MISS_TID3_SM_D(17) <= 
    (IU2_SM_3_PT(7));
MQQ302:MISS_TID3_SM_D(18) <= 
    (IU2_SM_3_PT(15));
MQQ303:MISS_TID3_SM_D(19) <= 
    (IU2_SM_3_PT(9));
MQQ304:RESET_STATE(3) <= 
    (IU2_SM_3_PT(19) OR IU2_SM_3_PT(43)
    );
MQQ305:REQUEST_TID(3) <= 
    (IU2_SM_3_PT(46) OR IU2_SM_3_PT(47)
    );
MQQ306:WRITE_DIR_INVAL(3) <= 
    (IU2_SM_3_PT(34));
MQQ307:WRITE_DIR_VAL(3) <= 
    (IU2_SM_3_PT(25));
MQQ308:HOLD_TID(3) <= 
    (IU2_SM_3_PT(17) OR IU2_SM_3_PT(18)
     OR IU2_SM_3_PT(23) OR IU2_SM_3_PT(27)
     OR IU2_SM_3_PT(28) OR IU2_SM_3_PT(29)
    );
MQQ309:DATA_WRITE(3) <= 
    (IU2_SM_3_PT(5) OR IU2_SM_3_PT(26)
    );
MQQ310:DIR_WRITE(3) <= 
    (IU2_SM_3_PT(5));
MQQ311:LOAD_TID(3) <= 
    (IU2_SM_3_PT(6) OR IU2_SM_3_PT(24)
    );
MQQ312:RELEASE_SM_HOLD(3) <= 
    (IU2_SM_3_PT(2) OR IU2_SM_3_PT(19)
     OR IU2_SM_3_PT(43));

load_quiesce(0) <=  miss_tid0_sm_l2(0);
load_quiesce(1) <=  miss_tid1_sm_l2(0);
load_quiesce(2) <=  miss_tid2_sm_l2(0);
load_quiesce(3) <=  miss_tid3_sm_l2(0);
ic_fdep_load_quiesce  <=  load_quiesce;
iu_mm_lmq_empty  <=  and_reduce(load_quiesce);
miss_act(0) <=  miss_tid0_sm_l2(0)   and icd_icm_any_iu2_valid and icd_icm_tid(0);
miss_addr0_real_d    <=  icd_icm_addr_real;
miss_addr0_eff_d    <=  icd_icm_addr_eff;
miss_ci0_d    <=  icd_icm_wimge(1);
miss_endian0_d    <=  icd_icm_wimge(4);
miss_2ucode0_d    <=  icd_icm_2ucode;
miss_2ucode0_type_d    <=  icd_icm_2ucode_type;
-- State-related latches
-- Any XU or BP flush occurred
set_flush_occurred(0) <=  (xu_iu_flush(0)   or bp_ic_iu5_redirect_tid(0))   and not miss_tid0_sm_l2(0)   and not miss_tid0_sm_l2(2);
miss_flush_occurred0_d    <=  '0' when reset_state(0)   = '1'   
                       else '1' when set_flush_occurred(0)   = '1' 
                       else miss_flush_occurred0_l2;
-- Flushed before entering Data0 - don't load ICache if flushed outside range
flush_addr_outside_range(0) <=  ics_icm_iu0_ifar0   /= (miss_addr0_eff_l2(46   to 51) & miss_addr0_real_l2(52));
set_flushed(0) <=  miss_flush_occurred0_l2   and flush_addr_outside_range(0)   and reld_r1_tid_l2(0)   and (miss_tid0_sm_l2(1)   or miss_tid0_sm_l2(11));
miss_flushed0_d    <=  '0' when reset_state(0)   = '1'    
                else '1' when set_flushed(0)   = '1'    
                else miss_flushed0_l2;
inval_equal(0) <=  icd_icm_iu2_inval and addr_equal(0);
set_invalidated(0) <=  (inval_equal(0)   or icd_icm_ici) and not miss_tid0_sm_l2(0)   and not miss_tid0_sm_l2(2)   and not miss_ci0_l2;
miss_inval0_d    <=  '0' when reset_state(0)   = '1' 
              else '1' when set_invalidated(0)   = '1'  
              else miss_inval0_l2;
sent_fp(0) <=  reld_r3_tid_l2(0)   and r3_loaded_l2 and not (an_ac_reld_ecc_err_l2 and not an_ac_reld_ecc_err_ue_l2);
set_block_fp(0) <=  sent_fp(0)   or 
                     (ics_icm_iu3_flush_tid(0)   and not (miss_tid0_sm_l2(0)   or miss_tid0_sm_l2(2)));
miss_block_fp0_d    <=  '0' when reset_state(0)   = '1' 
                 else '1' when set_block_fp(0)   = '1'  
                 else miss_block_fp0_l2;
miss_ecc_err0_d    <=  '0' when (reset_state(0)   or miss_tid0_sm_d(3)   or miss_tid0_sm_d(7))   = '1'       
                else '1' when (new_ecc_err(0)   and not miss_tid0_sm_l2(3)   and not miss_tid0_sm_l2(7))=   '1'
                else miss_ecc_err0_l2;
miss_ecc_err_ue0_d    <=  '0' when (reset_state(0)   or miss_tid0_sm_d(3)   or miss_tid0_sm_d(7))   = '1'       
                   else an_ac_reld_ecc_err_ue_l2 when new_ecc_err_ue(0)   = '1'
                   else miss_ecc_err_ue0_l2;
miss_act(1) <=  miss_tid1_sm_l2(0)   and icd_icm_any_iu2_valid and icd_icm_tid(1);
miss_addr1_real_d    <=  icd_icm_addr_real;
miss_addr1_eff_d    <=  icd_icm_addr_eff;
miss_ci1_d    <=  icd_icm_wimge(1);
miss_endian1_d    <=  icd_icm_wimge(4);
miss_2ucode1_d    <=  icd_icm_2ucode;
miss_2ucode1_type_d    <=  icd_icm_2ucode_type;
-- State-related latches
-- Any XU or BP flush occurred
set_flush_occurred(1) <=  (xu_iu_flush(1)   or bp_ic_iu5_redirect_tid(1))   and not miss_tid1_sm_l2(0)   and not miss_tid1_sm_l2(2);
miss_flush_occurred1_d    <=  '0' when reset_state(1)   = '1'   
                       else '1' when set_flush_occurred(1)   = '1' 
                       else miss_flush_occurred1_l2;
-- Flushed before entering Data0 - don't load ICache if flushed outside range
flush_addr_outside_range(1) <=  ics_icm_iu0_ifar1   /= (miss_addr1_eff_l2(46   to 51) & miss_addr1_real_l2(52));
set_flushed(1) <=  miss_flush_occurred1_l2   and flush_addr_outside_range(1)   and reld_r1_tid_l2(1)   and (miss_tid1_sm_l2(1)   or miss_tid1_sm_l2(11));
miss_flushed1_d    <=  '0' when reset_state(1)   = '1'    
                else '1' when set_flushed(1)   = '1'    
                else miss_flushed1_l2;
inval_equal(1) <=  icd_icm_iu2_inval and addr_equal(1);
set_invalidated(1) <=  (inval_equal(1)   or icd_icm_ici) and not miss_tid1_sm_l2(0)   and not miss_tid1_sm_l2(2)   and not miss_ci1_l2;
miss_inval1_d    <=  '0' when reset_state(1)   = '1' 
              else '1' when set_invalidated(1)   = '1'  
              else miss_inval1_l2;
sent_fp(1) <=  reld_r3_tid_l2(1)   and r3_loaded_l2 and not (an_ac_reld_ecc_err_l2 and not an_ac_reld_ecc_err_ue_l2);
set_block_fp(1) <=  sent_fp(1)   or 
                     (ics_icm_iu3_flush_tid(1)   and not (miss_tid1_sm_l2(0)   or miss_tid1_sm_l2(2)));
miss_block_fp1_d    <=  '0' when reset_state(1)   = '1' 
                 else '1' when set_block_fp(1)   = '1'  
                 else miss_block_fp1_l2;
miss_ecc_err1_d    <=  '0' when (reset_state(1)   or miss_tid1_sm_d(3)   or miss_tid1_sm_d(7))   = '1'       
                else '1' when (new_ecc_err(1)   and not miss_tid1_sm_l2(3)   and not miss_tid1_sm_l2(7))=   '1'
                else miss_ecc_err1_l2;
miss_ecc_err_ue1_d    <=  '0' when (reset_state(1)   or miss_tid1_sm_d(3)   or miss_tid1_sm_d(7))   = '1'       
                   else an_ac_reld_ecc_err_ue_l2 when new_ecc_err_ue(1)   = '1'
                   else miss_ecc_err_ue1_l2;
miss_act(2) <=  miss_tid2_sm_l2(0)   and icd_icm_any_iu2_valid and icd_icm_tid(2);
miss_addr2_real_d    <=  icd_icm_addr_real;
miss_addr2_eff_d    <=  icd_icm_addr_eff;
miss_ci2_d    <=  icd_icm_wimge(1);
miss_endian2_d    <=  icd_icm_wimge(4);
miss_2ucode2_d    <=  icd_icm_2ucode;
miss_2ucode2_type_d    <=  icd_icm_2ucode_type;
-- State-related latches
-- Any XU or BP flush occurred
set_flush_occurred(2) <=  (xu_iu_flush(2)   or bp_ic_iu5_redirect_tid(2))   and not miss_tid2_sm_l2(0)   and not miss_tid2_sm_l2(2);
miss_flush_occurred2_d    <=  '0' when reset_state(2)   = '1'   
                       else '1' when set_flush_occurred(2)   = '1' 
                       else miss_flush_occurred2_l2;
-- Flushed before entering Data0 - don't load ICache if flushed outside range
flush_addr_outside_range(2) <=  ics_icm_iu0_ifar2   /= (miss_addr2_eff_l2(46   to 51) & miss_addr2_real_l2(52));
set_flushed(2) <=  miss_flush_occurred2_l2   and flush_addr_outside_range(2)   and reld_r1_tid_l2(2)   and (miss_tid2_sm_l2(1)   or miss_tid2_sm_l2(11));
miss_flushed2_d    <=  '0' when reset_state(2)   = '1'    
                else '1' when set_flushed(2)   = '1'    
                else miss_flushed2_l2;
inval_equal(2) <=  icd_icm_iu2_inval and addr_equal(2);
set_invalidated(2) <=  (inval_equal(2)   or icd_icm_ici) and not miss_tid2_sm_l2(0)   and not miss_tid2_sm_l2(2)   and not miss_ci2_l2;
miss_inval2_d    <=  '0' when reset_state(2)   = '1' 
              else '1' when set_invalidated(2)   = '1'  
              else miss_inval2_l2;
sent_fp(2) <=  reld_r3_tid_l2(2)   and r3_loaded_l2 and not (an_ac_reld_ecc_err_l2 and not an_ac_reld_ecc_err_ue_l2);
set_block_fp(2) <=  sent_fp(2)   or 
                     (ics_icm_iu3_flush_tid(2)   and not (miss_tid2_sm_l2(0)   or miss_tid2_sm_l2(2)));
miss_block_fp2_d    <=  '0' when reset_state(2)   = '1' 
                 else '1' when set_block_fp(2)   = '1'  
                 else miss_block_fp2_l2;
miss_ecc_err2_d    <=  '0' when (reset_state(2)   or miss_tid2_sm_d(3)   or miss_tid2_sm_d(7))   = '1'       
                else '1' when (new_ecc_err(2)   and not miss_tid2_sm_l2(3)   and not miss_tid2_sm_l2(7))=   '1'
                else miss_ecc_err2_l2;
miss_ecc_err_ue2_d    <=  '0' when (reset_state(2)   or miss_tid2_sm_d(3)   or miss_tid2_sm_d(7))   = '1'       
                   else an_ac_reld_ecc_err_ue_l2 when new_ecc_err_ue(2)   = '1'
                   else miss_ecc_err_ue2_l2;
miss_act(3) <=  miss_tid3_sm_l2(0)   and icd_icm_any_iu2_valid and icd_icm_tid(3);
miss_addr3_real_d    <=  icd_icm_addr_real;
miss_addr3_eff_d    <=  icd_icm_addr_eff;
miss_ci3_d    <=  icd_icm_wimge(1);
miss_endian3_d    <=  icd_icm_wimge(4);
miss_2ucode3_d    <=  icd_icm_2ucode;
miss_2ucode3_type_d    <=  icd_icm_2ucode_type;
-- State-related latches
-- Any XU or BP flush occurred
set_flush_occurred(3) <=  (xu_iu_flush(3)   or bp_ic_iu5_redirect_tid(3))   and not miss_tid3_sm_l2(0)   and not miss_tid3_sm_l2(2);
miss_flush_occurred3_d    <=  '0' when reset_state(3)   = '1'   
                       else '1' when set_flush_occurred(3)   = '1' 
                       else miss_flush_occurred3_l2;
-- Flushed before entering Data0 - don't load ICache if flushed outside range
flush_addr_outside_range(3) <=  ics_icm_iu0_ifar3   /= (miss_addr3_eff_l2(46   to 51) & miss_addr3_real_l2(52));
set_flushed(3) <=  miss_flush_occurred3_l2   and flush_addr_outside_range(3)   and reld_r1_tid_l2(3)   and (miss_tid3_sm_l2(1)   or miss_tid3_sm_l2(11));
miss_flushed3_d    <=  '0' when reset_state(3)   = '1'    
                else '1' when set_flushed(3)   = '1'    
                else miss_flushed3_l2;
inval_equal(3) <=  icd_icm_iu2_inval and addr_equal(3);
set_invalidated(3) <=  (inval_equal(3)   or icd_icm_ici) and not miss_tid3_sm_l2(0)   and not miss_tid3_sm_l2(2)   and not miss_ci3_l2;
miss_inval3_d    <=  '0' when reset_state(3)   = '1' 
              else '1' when set_invalidated(3)   = '1'  
              else miss_inval3_l2;
sent_fp(3) <=  reld_r3_tid_l2(3)   and r3_loaded_l2 and not (an_ac_reld_ecc_err_l2 and not an_ac_reld_ecc_err_ue_l2);
set_block_fp(3) <=  sent_fp(3)   or 
                     (ics_icm_iu3_flush_tid(3)   and not (miss_tid3_sm_l2(0)   or miss_tid3_sm_l2(2)));
miss_block_fp3_d    <=  '0' when reset_state(3)   = '1' 
                 else '1' when set_block_fp(3)   = '1'  
                 else miss_block_fp3_l2;
miss_ecc_err3_d    <=  '0' when (reset_state(3)   or miss_tid3_sm_d(3)   or miss_tid3_sm_d(7))   = '1'       
                else '1' when (new_ecc_err(3)   and not miss_tid3_sm_l2(3)   and not miss_tid3_sm_l2(7))=   '1'
                else miss_ecc_err3_l2;
miss_ecc_err_ue3_d    <=  '0' when (reset_state(3)   or miss_tid3_sm_d(3)   or miss_tid3_sm_d(7))   = '1'       
                   else an_ac_reld_ecc_err_ue_l2 when new_ecc_err_ue(3)   = '1'
                   else miss_ecc_err_ue3_l2;
addr_equal(0) <=  (icd_icm_addr_real(REAL_IFAR'left to 56) = miss_addr0_real_l2(REAL_IFAR'left   to 56)) and
                   (spr_ic_cls_l2 or (icd_icm_addr_real(57) = miss_addr0_real_l2(57)));
addr_equal(1) <=  (icd_icm_addr_real(REAL_IFAR'left to 56) = miss_addr1_real_l2(REAL_IFAR'left   to 56)) and
                   (spr_ic_cls_l2 or (icd_icm_addr_real(57) = miss_addr1_real_l2(57)));
addr_equal(2) <=  (icd_icm_addr_real(REAL_IFAR'left to 56) = miss_addr2_real_l2(REAL_IFAR'left   to 56)) and
                   (spr_ic_cls_l2 or (icd_icm_addr_real(57) = miss_addr2_real_l2(57)));
addr_equal(3) <=  (icd_icm_addr_real(REAL_IFAR'left to 56) = miss_addr3_real_l2(REAL_IFAR'left   to 56)) and
                   (spr_ic_cls_l2 or (icd_icm_addr_real(57) = miss_addr3_real_l2(57)));
addr_match  <= 
  (addr_equal(0)   and not miss_tid0_sm_l2(0)   and not miss_ci0_l2)   or
  (addr_equal(1)   and not miss_tid1_sm_l2(0)   and not miss_ci1_l2)   or
  (addr_equal(2)   and not miss_tid2_sm_l2(0)   and not miss_ci2_l2)   or
  (addr_equal(3)   and not miss_tid3_sm_l2(0)   and not miss_ci3_l2);
miss_thread_is_idle  <=  (miss_tid0_sm_l2(0) and icd_icm_tid(0)) or      
                       (miss_tid1_sm_l2(0) and icd_icm_tid(1)) or
                       (miss_tid2_sm_l2(0) and icd_icm_tid(2)) or
                       (miss_tid3_sm_l2(0) and icd_icm_tid(3)) ;
-- When '1', flushes go back to current miss ifar
iu3_miss_match_d  <=  (addr_match and not icd_icm_wimge(1)) when miss_thread_is_idle = '1'  
               else (not miss_thread_is_idle);
icm_ics_iu2_miss_match_prev  <=  iu3_miss_match_l2;
release_sm  <=  or_reduce( release_sm_hold(0 to 3) );
-- Detect write through collision with invalidate read
iu0_inval_match(0) <=  ics_icm_iu0_inval and (ics_icm_iu0_inval_addr(52 to 56) = miss_addr0_real_l2(52   to 56)) and
                        (spr_ic_cls_l2 or (ics_icm_iu0_inval_addr(57) = miss_addr0_real_l2(57)));
miss_wrote_dir0_d    <=  '0' when reset_state(0)   = '1' 
                  else (dir_write_no_block(0)   or miss_wrote_dir0_l2);
miss_wrote_dir_v(0) <=  miss_wrote_dir0_l2;
iu0_inval_match(1) <=  ics_icm_iu0_inval and (ics_icm_iu0_inval_addr(52 to 56) = miss_addr1_real_l2(52   to 56)) and
                        (spr_ic_cls_l2 or (ics_icm_iu0_inval_addr(57) = miss_addr1_real_l2(57)));
miss_wrote_dir1_d    <=  '0' when reset_state(1)   = '1' 
                  else (dir_write_no_block(1)   or miss_wrote_dir1_l2);
miss_wrote_dir_v(1) <=  miss_wrote_dir1_l2;
iu0_inval_match(2) <=  ics_icm_iu0_inval and (ics_icm_iu0_inval_addr(52 to 56) = miss_addr2_real_l2(52   to 56)) and
                        (spr_ic_cls_l2 or (ics_icm_iu0_inval_addr(57) = miss_addr2_real_l2(57)));
miss_wrote_dir2_d    <=  '0' when reset_state(2)   = '1' 
                  else (dir_write_no_block(2)   or miss_wrote_dir2_l2);
miss_wrote_dir_v(2) <=  miss_wrote_dir2_l2;
iu0_inval_match(3) <=  ics_icm_iu0_inval and (ics_icm_iu0_inval_addr(52 to 56) = miss_addr3_real_l2(52   to 56)) and
                        (spr_ic_cls_l2 or (ics_icm_iu0_inval_addr(57) = miss_addr3_real_l2(57)));
miss_wrote_dir3_d    <=  '0' when reset_state(3)   = '1' 
                  else (dir_write_no_block(3)   or miss_wrote_dir3_l2);
miss_wrote_dir_v(3) <=  miss_wrote_dir3_l2;
miss_need_hold0_d    <=  '0' when ics_icm_iu3_flush_tid(0)   = '1'
                  else '1' when (icd_icm_miss and icd_icm_tid(0))   = '1'
                  else miss_need_hold0_l2;
miss_need_hold1_d    <=  '0' when ics_icm_iu3_flush_tid(1)   = '1'
                  else '1' when (icd_icm_miss and icd_icm_tid(1))   = '1'
                  else miss_need_hold1_l2;
miss_need_hold2_d    <=  '0' when ics_icm_iu3_flush_tid(2)   = '1'
                  else '1' when (icd_icm_miss and icd_icm_tid(2))   = '1'
                  else miss_need_hold2_l2;
miss_need_hold3_d    <=  '0' when ics_icm_iu3_flush_tid(3)   = '1'
                  else '1' when (icd_icm_miss and icd_icm_tid(3))   = '1'
                  else miss_need_hold3_l2;
-----------------------------------------------------------------------
-- Send request
-----------------------------------------------------------------------
request_d  <=  or_reduce( request_tid(0 to 3) );
req_thread_d  <=  icd_icm_tid;
req_ra_d  <=  icd_icm_addr_real(REAL_IFAR'left to 59);
req_wimge_d  <=  icd_icm_wimge;
req_userdef_d  <=  icd_icm_userdef;
iu_xu_request  <=  request_l2 and not icd_icm_iu3_erat_err;
iu_xu_thread   <=  req_thread_l2;
iu_xu_ra       <=  req_ra_l2;
iu_xu_wimge    <=  req_wimge_l2;
iu_xu_userdef  <=  req_userdef_l2;
erat_err  <=  gate_and( (request_l2 and icd_icm_iu3_erat_err), req_thread_l2 );
-----------------------------------------------------------------------
-- fastpath-related signals
-----------------------------------------------------------------------
-- for first beat of data: create hole in IU0 so we can fastpath data into IU2
preload_r0_tid(0) <=  r0_crit_qw(0)   and reld_r0_tid_plain(0)   and not miss_block_fp0_l2;
preload_r0_tid(1) <=  r0_crit_qw(1)   and reld_r0_tid_plain(1)   and not miss_block_fp1_l2;
preload_r0_tid(2) <=  r0_crit_qw(2)   and reld_r0_tid_plain(2)   and not miss_block_fp2_l2;
preload_r0_tid(3) <=  r0_crit_qw(3)   and reld_r0_tid_plain(3)   and not miss_block_fp3_l2;
preload_hold_iu0  <=  reld_r0_vld and or_reduce(preload_r0_tid);
-- Used for BP & LRU
r0_addr  <= 
            gate_and(reld_r0_tid_plain(0),   miss_addr0_real_l2(52   to 59)) or
            gate_and(reld_r0_tid_plain(1),   miss_addr1_real_l2(52   to 59)) or
            gate_and(reld_r0_tid_plain(2),   miss_addr2_real_l2(52   to 59)) or
            gate_and(reld_r0_tid_plain(3),   miss_addr3_real_l2(52   to 59));
icm_ics_iu0_preload_val  <=  preload_hold_iu0;
icm_ics_iu0_preload_tid  <=  reld_r0_tid_plain;
icm_ics_iu0_preload_ifar  <=  r0_addr(52 to 59);
-- load_tid only happens in r2, so can use reld_r2_tid_l2 to select address instead of load_tid
r2_load_addr  <= 
gate_and(reld_r2_tid_l2(0),(miss_addr0_eff_l2   & miss_addr0_real_l2(52   to 61))) or       
gate_and(reld_r2_tid_l2(1),(miss_addr1_eff_l2   & miss_addr1_real_l2(52   to 61))) or       
gate_and(reld_r2_tid_l2(2),(miss_addr2_eff_l2   & miss_addr2_real_l2(52   to 61))) or       
gate_and(reld_r2_tid_l2(3),(miss_addr3_eff_l2   & miss_addr3_real_l2(52   to 61)));
r2_load_2ucode  <= 
(reld_r2_tid_l2(0)   and miss_2ucode0_l2)   or
(reld_r2_tid_l2(1)   and miss_2ucode1_l2)   or
(reld_r2_tid_l2(2)   and miss_2ucode2_l2)   or
(reld_r2_tid_l2(3)   and miss_2ucode3_l2);
r2_load_2ucode_type  <= 
(reld_r2_tid_l2(0)   and miss_2ucode0_type_l2)   or
(reld_r2_tid_l2(1)   and miss_2ucode1_type_l2)   or
(reld_r2_tid_l2(2)   and miss_2ucode2_type_l2)   or
(reld_r2_tid_l2(3)   and miss_2ucode3_type_l2);
load_tid_no_block(0) <=  load_tid(0)   and not miss_block_fp0_l2;
load_tid_no_block(1) <=  load_tid(1)   and not miss_block_fp1_l2;
load_tid_no_block(2) <=  load_tid(2)   and not miss_block_fp2_l2;
load_tid_no_block(3) <=  load_tid(3)   and not miss_block_fp3_l2;
icm_ics_load_tid  <=  load_tid_no_block;
icm_icd_load_tid  <=  load_tid_no_block;
icm_icd_load_addr  <=  r2_load_addr;
icm_icd_load_2ucode  <=  r2_load_2ucode;
icm_icd_load_2ucode_type  <=  r2_load_2ucode_type;
r3_loaded_d  <=  or_reduce( load_tid_no_block );
-----------------------------------------------------------------------
-- Critical Quadword
-----------------------------------------------------------------------
-- Note: Could latch reld_crit_qw signal from L2, but we need addr (60:61), so might as well keep whole address
r0_crit_qw(0) <=  an_ac_reld_qw_l2(58 to 59) = miss_addr0_real_l2(58   to 59)  when spr_ic_cls_l2 = '0'
              else an_ac_reld_qw_l2(57 to 59) = miss_addr0_real_l2(57   to 59);
r1_crit_qw(0) <=  reld_r1_qw_l2(1 to 2) = miss_addr0_real_l2(58   to 59)       when spr_ic_cls_l2 = '0'
              else reld_r1_qw_l2(0 to 2) = miss_addr0_real_l2(57   to 59);
r0_crit_qw(1) <=  an_ac_reld_qw_l2(58 to 59) = miss_addr1_real_l2(58   to 59)  when spr_ic_cls_l2 = '0'
              else an_ac_reld_qw_l2(57 to 59) = miss_addr1_real_l2(57   to 59);
r1_crit_qw(1) <=  reld_r1_qw_l2(1 to 2) = miss_addr1_real_l2(58   to 59)       when spr_ic_cls_l2 = '0'
              else reld_r1_qw_l2(0 to 2) = miss_addr1_real_l2(57   to 59);
r0_crit_qw(2) <=  an_ac_reld_qw_l2(58 to 59) = miss_addr2_real_l2(58   to 59)  when spr_ic_cls_l2 = '0'
              else an_ac_reld_qw_l2(57 to 59) = miss_addr2_real_l2(57   to 59);
r1_crit_qw(2) <=  reld_r1_qw_l2(1 to 2) = miss_addr2_real_l2(58   to 59)       when spr_ic_cls_l2 = '0'
              else reld_r1_qw_l2(0 to 2) = miss_addr2_real_l2(57   to 59);
r0_crit_qw(3) <=  an_ac_reld_qw_l2(58 to 59) = miss_addr3_real_l2(58   to 59)  when spr_ic_cls_l2 = '0'
              else an_ac_reld_qw_l2(57 to 59) = miss_addr3_real_l2(57   to 59);
r1_crit_qw(3) <=  reld_r1_qw_l2(1 to 2) = miss_addr3_real_l2(58   to 59)       when spr_ic_cls_l2 = '0'
              else reld_r1_qw_l2(0 to 2) = miss_addr3_real_l2(57   to 59);
r2_crit_qw_d  <=  or_reduce(r1_crit_qw and reld_r1_tid_l2);
-----------------------------------------------------------------------
-- Get LRU
-----------------------------------------------------------------------
-- read lru in r0 for timing, and use in r1
icm_icd_lru_addr  <=  r0_addr(52 to 57);
lru_write_hit  <=  or_reduce(lru_write) and (r0_addr(52 to 56) = lru_write_addr(52 to 56)) and
                 (spr_ic_cls_l2 or (r0_addr(57) = lru_write_addr(57)));
row_val_d  <=  icd_icm_row_val;
hit_lru  <=  gate_and(lru_write_way(0), ("11" & icd_icm_row_lru(2))) or
           gate_and(lru_write_way(1), ("10" & icd_icm_row_lru(2))) or
           gate_and(lru_write_way(2), ('0' & icd_icm_row_lru(1) & '1')) or
           gate_and(lru_write_way(3), ('0' & icd_icm_row_lru(1) & '0'));
row_lru_d  <=  icd_icm_row_lru    when lru_write_hit = '0'
        else hit_lru;
-- Select_lru in r1, read lru out of dir in r0 & latch
select_lru(0) <=  not miss_ci0_l2   and reld_r1_tid_l2(0)   and miss_tid0_sm_l2(1);
select_lru(1) <=  not miss_ci1_l2   and reld_r1_tid_l2(1)   and miss_tid1_sm_l2(1);
select_lru(2) <=  not miss_ci2_l2   and reld_r1_tid_l2(2)   and miss_tid2_sm_l2(1);
select_lru(3) <=  not miss_ci3_l2   and reld_r1_tid_l2(3)   and miss_tid3_sm_l2(1);
-- lru/way is valid in Data0-3, Wait1-3, CheckECC
lru_valid(0) <=  not (miss_tid0_sm_l2(0)   or miss_tid0_sm_l2(1)   or miss_tid0_sm_l2(2)   or miss_flushed0_l2   or miss_inval0_l2   or miss_ci0_l2);
lru_valid(1) <=  not (miss_tid1_sm_l2(0)   or miss_tid1_sm_l2(1)   or miss_tid1_sm_l2(2)   or miss_flushed1_l2   or miss_inval1_l2   or miss_ci1_l2);
lru_valid(2) <=  not (miss_tid2_sm_l2(0)   or miss_tid2_sm_l2(1)   or miss_tid2_sm_l2(2)   or miss_flushed2_l2   or miss_inval2_l2   or miss_ci2_l2);
lru_valid(3) <=  not (miss_tid3_sm_l2(0)   or miss_tid3_sm_l2(1)   or miss_tid3_sm_l2(2)   or miss_flushed3_l2   or miss_inval3_l2   or miss_ci3_l2);
r1_addr  <= 
           gate_and(reld_r1_tid_l2(0),   miss_addr0_real_l2(52   to 57)) or
           gate_and(reld_r1_tid_l2(1),   miss_addr1_real_l2(52   to 57)) or
           gate_and(reld_r1_tid_l2(2),   miss_addr2_real_l2(52   to 57)) or
           gate_and(reld_r1_tid_l2(3),   miss_addr3_real_l2(52   to 57));
-- check if any other thread is writing into this spot in the cache
row_match(0) <=  lru_valid(0)   and (r1_addr(52 to 56) = miss_addr0_real_l2(52   to 56)) and
                  (spr_ic_cls_l2 or (r1_addr(57) = miss_addr0_real_l2(57)));
row_match(1) <=  lru_valid(1)   and (r1_addr(52 to 56) = miss_addr1_real_l2(52   to 56)) and
                  (spr_ic_cls_l2 or (r1_addr(57) = miss_addr1_real_l2(57)));
row_match(2) <=  lru_valid(2)   and (r1_addr(52 to 56) = miss_addr2_real_l2(52   to 56)) and
                  (spr_ic_cls_l2 or (r1_addr(57) = miss_addr2_real_l2(57)));
row_match(3) <=  lru_valid(3)   and (r1_addr(52 to 56) = miss_addr3_real_l2(52   to 56)) and
                  (spr_ic_cls_l2 or (r1_addr(57) = miss_addr3_real_l2(57)));
row_match_way  <= 
    gate_and(row_match(0),   miss_way0_l2)   or
    gate_and(row_match(1),   miss_way1_l2)   or
    gate_and(row_match(2),   miss_way2_l2)   or
    gate_and(row_match(3),   miss_way3_l2);
val_or_match  <=  row_val_l2 or row_match_way;
-- Could have all 4 threads going to same row
--
-- Final Table Listing
--      *INPUTS*=================*OUTPUTS*======*
--      |                        |              |
--      | row_lru_l2             |              |
--      | |    row_match_way     |              |
--      | |    |                 | next_lru_way |
--      | |    |                 | |            |
--      | |    |                 | |            |
--      | 012  0123              | 0123         |
--      *TYPE*===================+==============+
--      | PPP  PPPP              | PPPP         |
--      *POLARITY*-------------->| ++++         |
--      *PHASE*----------------->| TTTT         |
--      *TERMS*==================+==============+
--    1 | 0-1  01-1              | 1...         |
--    2 | 0-0  011-              | 1...         |
--    3 | 0-1  10-1              | .1..         |
--    4 | 0-0  101-              | .1..         |
--    5 | 11-  -101              | ..1.         |
--    6 | 10-  1-01              | ..1.         |
--    7 | 11-  -110              | ...1         |
--    8 | 10-  1-10              | ...1         |
--    9 | 11-  -111              | 1...         |
--   10 | 10-  1-11              | .1..         |
--   11 | 0-1  11-1              | ..1.         |
--   12 | 0-0  111-              | ...1         |
--   13 | -01  0--1              | 1...         |
--   14 | -00  0-1-              | 1...         |
--   15 | -11  -0-1              | .1..         |
--   16 | -10  -01-              | .1..         |
--   17 | -10  -10-              | ..1.         |
--   18 | -00  1-0-              | ..1.         |
--   19 | -11  -1-0              | ...1         |
--   20 | -01  1--0              | ...1         |
--   21 | 00-  0---              | 1...         |
--   22 | 01-  -0--              | .1..         |
--   23 | 1-0  --0-              | ..1.         |
--   24 | 1-1  ---0              | ...1         |
--      *=======================================*
--
-- Table SELECT_LRU_WAY Signal Assignments for Product Terms
MQQ313:SELECT_LRU_WAY_PT(1) <=
    Eq(( ROW_LRU_L2(0) & ROW_LRU_L2(2) & 
    ROW_MATCH_WAY(0) & ROW_MATCH_WAY(1) & 
    ROW_MATCH_WAY(3) ) , STD_ULOGIC_VECTOR'("01011"));
MQQ314:SELECT_LRU_WAY_PT(2) <=
    Eq(( ROW_LRU_L2(0) & ROW_LRU_L2(2) & 
    ROW_MATCH_WAY(0) & ROW_MATCH_WAY(1) & 
    ROW_MATCH_WAY(2) ) , STD_ULOGIC_VECTOR'("00011"));
MQQ315:SELECT_LRU_WAY_PT(3) <=
    Eq(( ROW_LRU_L2(0) & ROW_LRU_L2(2) & 
    ROW_MATCH_WAY(0) & ROW_MATCH_WAY(1) & 
    ROW_MATCH_WAY(3) ) , STD_ULOGIC_VECTOR'("01101"));
MQQ316:SELECT_LRU_WAY_PT(4) <=
    Eq(( ROW_LRU_L2(0) & ROW_LRU_L2(2) & 
    ROW_MATCH_WAY(0) & ROW_MATCH_WAY(1) & 
    ROW_MATCH_WAY(2) ) , STD_ULOGIC_VECTOR'("00101"));
MQQ317:SELECT_LRU_WAY_PT(5) <=
    Eq(( ROW_LRU_L2(0) & ROW_LRU_L2(1) & 
    ROW_MATCH_WAY(1) & ROW_MATCH_WAY(2) & 
    ROW_MATCH_WAY(3) ) , STD_ULOGIC_VECTOR'("11101"));
MQQ318:SELECT_LRU_WAY_PT(6) <=
    Eq(( ROW_LRU_L2(0) & ROW_LRU_L2(1) & 
    ROW_MATCH_WAY(0) & ROW_MATCH_WAY(2) & 
    ROW_MATCH_WAY(3) ) , STD_ULOGIC_VECTOR'("10101"));
MQQ319:SELECT_LRU_WAY_PT(7) <=
    Eq(( ROW_LRU_L2(0) & ROW_LRU_L2(1) & 
    ROW_MATCH_WAY(1) & ROW_MATCH_WAY(2) & 
    ROW_MATCH_WAY(3) ) , STD_ULOGIC_VECTOR'("11110"));
MQQ320:SELECT_LRU_WAY_PT(8) <=
    Eq(( ROW_LRU_L2(0) & ROW_LRU_L2(1) & 
    ROW_MATCH_WAY(0) & ROW_MATCH_WAY(2) & 
    ROW_MATCH_WAY(3) ) , STD_ULOGIC_VECTOR'("10110"));
MQQ321:SELECT_LRU_WAY_PT(9) <=
    Eq(( ROW_LRU_L2(0) & ROW_LRU_L2(1) & 
    ROW_MATCH_WAY(1) & ROW_MATCH_WAY(2) & 
    ROW_MATCH_WAY(3) ) , STD_ULOGIC_VECTOR'("11111"));
MQQ322:SELECT_LRU_WAY_PT(10) <=
    Eq(( ROW_LRU_L2(0) & ROW_LRU_L2(1) & 
    ROW_MATCH_WAY(0) & ROW_MATCH_WAY(2) & 
    ROW_MATCH_WAY(3) ) , STD_ULOGIC_VECTOR'("10111"));
MQQ323:SELECT_LRU_WAY_PT(11) <=
    Eq(( ROW_LRU_L2(0) & ROW_LRU_L2(2) & 
    ROW_MATCH_WAY(0) & ROW_MATCH_WAY(1) & 
    ROW_MATCH_WAY(3) ) , STD_ULOGIC_VECTOR'("01111"));
MQQ324:SELECT_LRU_WAY_PT(12) <=
    Eq(( ROW_LRU_L2(0) & ROW_LRU_L2(2) & 
    ROW_MATCH_WAY(0) & ROW_MATCH_WAY(1) & 
    ROW_MATCH_WAY(2) ) , STD_ULOGIC_VECTOR'("00111"));
MQQ325:SELECT_LRU_WAY_PT(13) <=
    Eq(( ROW_LRU_L2(1) & ROW_LRU_L2(2) & 
    ROW_MATCH_WAY(0) & ROW_MATCH_WAY(3)
     ) , STD_ULOGIC_VECTOR'("0101"));
MQQ326:SELECT_LRU_WAY_PT(14) <=
    Eq(( ROW_LRU_L2(1) & ROW_LRU_L2(2) & 
    ROW_MATCH_WAY(0) & ROW_MATCH_WAY(2)
     ) , STD_ULOGIC_VECTOR'("0001"));
MQQ327:SELECT_LRU_WAY_PT(15) <=
    Eq(( ROW_LRU_L2(1) & ROW_LRU_L2(2) & 
    ROW_MATCH_WAY(1) & ROW_MATCH_WAY(3)
     ) , STD_ULOGIC_VECTOR'("1101"));
MQQ328:SELECT_LRU_WAY_PT(16) <=
    Eq(( ROW_LRU_L2(1) & ROW_LRU_L2(2) & 
    ROW_MATCH_WAY(1) & ROW_MATCH_WAY(2)
     ) , STD_ULOGIC_VECTOR'("1001"));
MQQ329:SELECT_LRU_WAY_PT(17) <=
    Eq(( ROW_LRU_L2(1) & ROW_LRU_L2(2) & 
    ROW_MATCH_WAY(1) & ROW_MATCH_WAY(2)
     ) , STD_ULOGIC_VECTOR'("1010"));
MQQ330:SELECT_LRU_WAY_PT(18) <=
    Eq(( ROW_LRU_L2(1) & ROW_LRU_L2(2) & 
    ROW_MATCH_WAY(0) & ROW_MATCH_WAY(2)
     ) , STD_ULOGIC_VECTOR'("0010"));
MQQ331:SELECT_LRU_WAY_PT(19) <=
    Eq(( ROW_LRU_L2(1) & ROW_LRU_L2(2) & 
    ROW_MATCH_WAY(1) & ROW_MATCH_WAY(3)
     ) , STD_ULOGIC_VECTOR'("1110"));
MQQ332:SELECT_LRU_WAY_PT(20) <=
    Eq(( ROW_LRU_L2(1) & ROW_LRU_L2(2) & 
    ROW_MATCH_WAY(0) & ROW_MATCH_WAY(3)
     ) , STD_ULOGIC_VECTOR'("0110"));
MQQ333:SELECT_LRU_WAY_PT(21) <=
    Eq(( ROW_LRU_L2(0) & ROW_LRU_L2(1) & 
    ROW_MATCH_WAY(0) ) , STD_ULOGIC_VECTOR'("000"));
MQQ334:SELECT_LRU_WAY_PT(22) <=
    Eq(( ROW_LRU_L2(0) & ROW_LRU_L2(1) & 
    ROW_MATCH_WAY(1) ) , STD_ULOGIC_VECTOR'("010"));
MQQ335:SELECT_LRU_WAY_PT(23) <=
    Eq(( ROW_LRU_L2(0) & ROW_LRU_L2(2) & 
    ROW_MATCH_WAY(2) ) , STD_ULOGIC_VECTOR'("100"));
MQQ336:SELECT_LRU_WAY_PT(24) <=
    Eq(( ROW_LRU_L2(0) & ROW_LRU_L2(2) & 
    ROW_MATCH_WAY(3) ) , STD_ULOGIC_VECTOR'("110"));
-- Table SELECT_LRU_WAY Signal Assignments for Outputs
MQQ337:NEXT_LRU_WAY(0) <= 
    (SELECT_LRU_WAY_PT(1) OR SELECT_LRU_WAY_PT(2)
     OR SELECT_LRU_WAY_PT(9) OR SELECT_LRU_WAY_PT(13)
     OR SELECT_LRU_WAY_PT(14) OR SELECT_LRU_WAY_PT(21)
    );
MQQ338:NEXT_LRU_WAY(1) <= 
    (SELECT_LRU_WAY_PT(3) OR SELECT_LRU_WAY_PT(4)
     OR SELECT_LRU_WAY_PT(10) OR SELECT_LRU_WAY_PT(15)
     OR SELECT_LRU_WAY_PT(16) OR SELECT_LRU_WAY_PT(22)
    );
MQQ339:NEXT_LRU_WAY(2) <= 
    (SELECT_LRU_WAY_PT(5) OR SELECT_LRU_WAY_PT(6)
     OR SELECT_LRU_WAY_PT(11) OR SELECT_LRU_WAY_PT(17)
     OR SELECT_LRU_WAY_PT(18) OR SELECT_LRU_WAY_PT(23)
    );
MQQ340:NEXT_LRU_WAY(3) <= 
    (SELECT_LRU_WAY_PT(7) OR SELECT_LRU_WAY_PT(8)
     OR SELECT_LRU_WAY_PT(12) OR SELECT_LRU_WAY_PT(19)
     OR SELECT_LRU_WAY_PT(20) OR SELECT_LRU_WAY_PT(24)
    );

next_way(0) <=  (val_or_match(0) = '0')         or (next_lru_way(0) and (val_or_match(0 to 3) = "1111"));
next_way(1) <=  (val_or_match(0 to 1) = "10")   or (next_lru_way(1) and (val_or_match(0 to 3) = "1111"));
next_way(2) <=  (val_or_match(0 to 2) = "110")  or (next_lru_way(2) and (val_or_match(0 to 3) = "1111"));
next_way(3) <=  (val_or_match(0 to 3) = "1110") or (next_lru_way(3) and (val_or_match(0 to 3) = "1111"));
miss_way0_d    <=  next_way       when select_lru(0)   = '1'
            else miss_way0_l2;
miss_way1_d    <=  next_way       when select_lru(1)   = '1'
            else miss_way1_l2;
miss_way2_d    <=  next_way       when select_lru(2)   = '1'
            else miss_way2_l2;
miss_way3_d    <=  next_way       when select_lru(3)   = '1'
            else miss_way3_l2;
-----------------------------------------------------------------------
-- setting output signals
-----------------------------------------------------------------------
icm_ics_hold_thread(0) <=  hold_tid(0)   and miss_need_hold0_l2   and not ics_icm_iu3_flush_tid(0);
icm_ics_hold_thread_dbg(0) <=  hold_tid(0)   and miss_need_hold0_l2;
icm_ics_hold_thread(1) <=  hold_tid(1)   and miss_need_hold1_l2   and not ics_icm_iu3_flush_tid(1);
icm_ics_hold_thread_dbg(1) <=  hold_tid(1)   and miss_need_hold1_l2;
icm_ics_hold_thread(2) <=  hold_tid(2)   and miss_need_hold2_l2   and not ics_icm_iu3_flush_tid(2);
icm_ics_hold_thread_dbg(2) <=  hold_tid(2)   and miss_need_hold2_l2;
icm_ics_hold_thread(3) <=  hold_tid(3)   and miss_need_hold3_l2   and not ics_icm_iu3_flush_tid(3);
icm_ics_hold_thread_dbg(3) <=  hold_tid(3)   and miss_need_hold3_l2;
-- Use miss_flushed<a>_d, since we don't set until r1
hold_iu0  <=  or_reduce( data_write(0 to 3) ) or
            preload_hold_iu0;
icm_ics_hold_iu0  <=  hold_iu0;
icm_icd_data_write  <=  or_reduce( data_write(0 to 3) );
dir_inval  <=  or_reduce( write_dir_inval(0 to 3) );
icm_icd_dir_inval  <=  dir_inval;
icm_icd_dir_val  <=  or_reduce( (write_dir_val(0 to 3) and miss_wrote_dir_v) );
r3_need_back_inval_d  <=  or_reduce(inval_equal and write_dir_val and miss_wrote_dir_v);
icm_icd_reload_addr  <=  (r2_load_addr(52 to 57) & reld_r2_qw_l2(1 to 2)) when spr_ic_cls_l2 = '0'
                  else (r2_load_addr(52 to 56) & reld_r2_qw_l2(0 to 2));
reload_way  <=                  gate_and(reld_r2_tid_l2(0),   miss_way0_l2)   or
                gate_and(reld_r2_tid_l2(1),   miss_way1_l2)   or
                gate_and(reld_r2_tid_l2(2),   miss_way2_l2)   or
                gate_and(reld_r2_tid_l2(3),   miss_way3_l2);
icm_icd_reload_way  <=  reload_way;
-- Check which endian
reload_endian  <=                     (reld_r2_tid_l2(0)   and miss_endian0_l2)   or
                   (reld_r2_tid_l2(1)   and miss_endian1_l2)   or
                   (reld_r2_tid_l2(2)   and miss_endian2_l2)   or
                   (reld_r2_tid_l2(3)   and miss_endian3_l2);
swap_endian_data  <= 
    an_ac_reld_data_l2(24        to 31)        & an_ac_reld_data_l2(16        to 23)        & an_ac_reld_data_l2(8        to 15)        & an_ac_reld_data_l2(0      to 7)        &
    an_ac_reld_data_l2(56        to 63)        & an_ac_reld_data_l2(48        to 55)        & an_ac_reld_data_l2(40       to 47)        & an_ac_reld_data_l2(32     to 39)       &
    an_ac_reld_data_l2(88        to 95)        & an_ac_reld_data_l2(80        to 87)        & an_ac_reld_data_l2(72       to 79)        & an_ac_reld_data_l2(64     to 71)       &
    an_ac_reld_data_l2(120       to 127)       & an_ac_reld_data_l2(112       to 119)       & an_ac_reld_data_l2(104      to 111)       & an_ac_reld_data_l2(96     to 103);
-- Branch Decode
br_decode0   : iuq_bd
  port map(
     instruction                => an_ac_reld_data_l2(0      to 31),
     branch_decode              => branch_decode0(0   to 3),
     bp_bc_en                   => bp_config_l2(0),
     bp_bclr_en                 => bp_config_l2(1),
     bp_bcctr_en                => bp_config_l2(2),
     bp_sw_en                   => bp_config_l2(3)
  );
br_decode1   : iuq_bd
  port map(
     instruction                => an_ac_reld_data_l2(32     to 63),
     branch_decode              => branch_decode1(0   to 3),
     bp_bc_en                   => bp_config_l2(0),
     bp_bclr_en                 => bp_config_l2(1),
     bp_bcctr_en                => bp_config_l2(2),
     bp_sw_en                   => bp_config_l2(3)
  );
br_decode2   : iuq_bd
  port map(
     instruction                => an_ac_reld_data_l2(64     to 95),
     branch_decode              => branch_decode2(0   to 3),
     bp_bc_en                   => bp_config_l2(0),
     bp_bclr_en                 => bp_config_l2(1),
     bp_bcctr_en                => bp_config_l2(2),
     bp_sw_en                   => bp_config_l2(3)
  );
br_decode3   : iuq_bd
  port map(
     instruction                => an_ac_reld_data_l2(96     to 127),
     branch_decode              => branch_decode3(0   to 3),
     bp_bc_en                   => bp_config_l2(0),
     bp_bclr_en                 => bp_config_l2(1),
     bp_bcctr_en                => bp_config_l2(2),
     bp_sw_en                   => bp_config_l2(3)
  );
swap_br_decode0   : iuq_bd
  port map(
     instruction                => swap_endian_data(0      to 31),
     branch_decode              => swap_branch_decode0(0   to 3),
     bp_bc_en                   => bp_config_l2(0),
     bp_bclr_en                 => bp_config_l2(1),
     bp_bcctr_en                => bp_config_l2(2),
     bp_sw_en                   => bp_config_l2(3)
  );
swap_br_decode1   : iuq_bd
  port map(
     instruction                => swap_endian_data(32     to 63),
     branch_decode              => swap_branch_decode1(0   to 3),
     bp_bc_en                   => bp_config_l2(0),
     bp_bclr_en                 => bp_config_l2(1),
     bp_bcctr_en                => bp_config_l2(2),
     bp_sw_en                   => bp_config_l2(3)
  );
swap_br_decode2   : iuq_bd
  port map(
     instruction                => swap_endian_data(64     to 95),
     branch_decode              => swap_branch_decode2(0   to 3),
     bp_bc_en                   => bp_config_l2(0),
     bp_bclr_en                 => bp_config_l2(1),
     bp_bcctr_en                => bp_config_l2(2),
     bp_sw_en                   => bp_config_l2(3)
  );
swap_br_decode3   : iuq_bd
  port map(
     instruction                => swap_endian_data(96     to 127),
     branch_decode              => swap_branch_decode3(0   to 3),
     bp_bc_en                   => bp_config_l2(0),
     bp_bclr_en                 => bp_config_l2(1),
     bp_bcctr_en                => bp_config_l2(2),
     bp_sw_en                   => bp_config_l2(3)
  );
instr_data  <=  an_ac_reld_data_l2(  0 to  31) & branch_decode0(0 to 3) &
              an_ac_reld_data_l2( 32 to  63) & branch_decode1(0 to 3) &
              an_ac_reld_data_l2( 64 to  95) & branch_decode2(0 to 3) &
              an_ac_reld_data_l2( 96 to 127) & branch_decode3(0 to 3);
swap_data   <=  swap_endian_data(  0 to  31) & swap_branch_decode0(0 to 3) &
              swap_endian_data( 32 to  63) & swap_branch_decode1(0 to 3) &
              swap_endian_data( 64 to  95) & swap_branch_decode2(0 to 3) &
              swap_endian_data( 96 to 127) & swap_branch_decode3(0 to 3);
gen_data_parity: for i in 0 to 17 generate
begin
  data_parity_in(i) <=  xor_reduce( instr_data(i*8 to i*8+7) );
swap_parity_in(i) <=  xor_reduce( swap_data(i*8 to i*8+7) );
end generate;
with reload_endian select
icm_icd_reload_data  <=  instr_data & data_parity_in when '0',
                       swap_data  & swap_parity_in when others;
dir_write_no_block  <=  dir_write and not iu0_inval_match;
icm_icd_dir_write  <=  or_reduce(dir_write_no_block);
icm_icd_dir_write_addr  <=  r2_real_addr;
icm_icd_dir_write_endian  <=  reload_endian;
icm_icd_dir_write_way  <=  reload_way;
-- Dir Write moved to r2
r2_real_addr  <= 
           gate_and(reld_r2_tid_l2(0),   miss_addr0_real_l2(REAL_IFAR'left   to 57)) or
           gate_and(reld_r2_tid_l2(1),   miss_addr1_real_l2(REAL_IFAR'left   to 57)) or
           gate_and(reld_r2_tid_l2(2),   miss_addr2_real_l2(REAL_IFAR'left   to 57)) or
           gate_and(reld_r2_tid_l2(3),   miss_addr3_real_l2(REAL_IFAR'left   to 57));
-- LRU Write: Occurs 2 cycles after Data 2 data_write (64B mode) or Data6 (128B mode)
lru_write_next_cycle_d(0) <=  data_write(0)   and ((miss_tid0_sm_l2(5)    and spr_ic_cls_l2 = '0') or     
                                                    (miss_tid0_sm_l2(15)   and spr_ic_cls_l2 = '1'));
lru_write_d(0) <=  lru_write_next_cycle_l2(0);
lru_write(0) <=  lru_write_l2(0)   and not miss_inval0_l2   and (miss_tid0_sm_l2(6)   or miss_tid0_sm_l2(11));
lru_write_next_cycle_d(1) <=  data_write(1)   and ((miss_tid1_sm_l2(5)    and spr_ic_cls_l2 = '0') or     
                                                    (miss_tid1_sm_l2(15)   and spr_ic_cls_l2 = '1'));
lru_write_d(1) <=  lru_write_next_cycle_l2(1);
lru_write(1) <=  lru_write_l2(1)   and not miss_inval1_l2   and (miss_tid1_sm_l2(6)   or miss_tid1_sm_l2(11));
lru_write_next_cycle_d(2) <=  data_write(2)   and ((miss_tid2_sm_l2(5)    and spr_ic_cls_l2 = '0') or     
                                                    (miss_tid2_sm_l2(15)   and spr_ic_cls_l2 = '1'));
lru_write_d(2) <=  lru_write_next_cycle_l2(2);
lru_write(2) <=  lru_write_l2(2)   and not miss_inval2_l2   and (miss_tid2_sm_l2(6)   or miss_tid2_sm_l2(11));
lru_write_next_cycle_d(3) <=  data_write(3)   and ((miss_tid3_sm_l2(5)    and spr_ic_cls_l2 = '0') or     
                                                    (miss_tid3_sm_l2(15)   and spr_ic_cls_l2 = '1'));
lru_write_d(3) <=  lru_write_next_cycle_l2(3);
lru_write(3) <=  lru_write_l2(3)   and not miss_inval3_l2   and (miss_tid3_sm_l2(6)   or miss_tid3_sm_l2(11));
icm_icd_lru_write  <=  or_reduce( lru_write );
lru_write_addr  <=                       gate_and(lru_write_l2(0),   miss_addr0_real_l2(52   to 57)) or
                     gate_and(lru_write_l2(1),   miss_addr1_real_l2(52   to 57)) or
                     gate_and(lru_write_l2(2),   miss_addr2_real_l2(52   to 57)) or
                     gate_and(lru_write_l2(3),   miss_addr3_real_l2(52   to 57));
lru_write_way  <=                     gate_and(lru_write_l2(0),   miss_way0_l2)   or
                   gate_and(lru_write_l2(1),   miss_way1_l2)   or
                   gate_and(lru_write_l2(2),   miss_way2_l2)   or
                   gate_and(lru_write_l2(3),   miss_way3_l2);
icm_icd_lru_write_addr  <=  lru_write_addr;
icm_icd_lru_write_way  <=  lru_write_way;
-- For act's in idir
icm_icd_any_reld_r2  <=  or_reduce(reld_r2_tid_l2);
icm_icd_any_checkecc  <=  miss_tid0_sm_l2(11) or miss_tid1_sm_l2(11) or miss_tid2_sm_l2(11) or miss_tid3_sm_l2(11);
-----------------------------------------------------------------------
-- ECC Error handling
-----------------------------------------------------------------------
new_ecc_err  <=  gate_and(an_ac_reld_ecc_err_l2, reld_r3_tid_l2);
new_ecc_err_ue  <=  gate_and(an_ac_reld_ecc_err_ue_l2, reld_r3_tid_l2);
ecc_err(0) <=  new_ecc_err(0)   or miss_ecc_err0_l2;
ecc_err_ue(0) <=  new_ecc_err_ue(0)   or miss_ecc_err_ue0_l2;
ecc_inval(0) <=  (an_ac_reld_ecc_err_l2 or an_ac_reld_ecc_err_ue_l2) and
                  miss_tid0_sm_l2(11)   and not miss_ci0_l2   and not miss_flushed0_l2   and not miss_inval0_l2;
ecc_block_iu0(0) <=  an_ac_reld_ecc_err_l2 and miss_tid0_sm_l2(11)   and miss_need_hold0_l2;
ecc_err(1) <=  new_ecc_err(1)   or miss_ecc_err1_l2;
ecc_err_ue(1) <=  new_ecc_err_ue(1)   or miss_ecc_err_ue1_l2;
ecc_inval(1) <=  (an_ac_reld_ecc_err_l2 or an_ac_reld_ecc_err_ue_l2) and
                  miss_tid1_sm_l2(11)   and not miss_ci1_l2   and not miss_flushed1_l2   and not miss_inval1_l2;
ecc_block_iu0(1) <=  an_ac_reld_ecc_err_l2 and miss_tid1_sm_l2(11)   and miss_need_hold1_l2;
ecc_err(2) <=  new_ecc_err(2)   or miss_ecc_err2_l2;
ecc_err_ue(2) <=  new_ecc_err_ue(2)   or miss_ecc_err_ue2_l2;
ecc_inval(2) <=  (an_ac_reld_ecc_err_l2 or an_ac_reld_ecc_err_ue_l2) and
                  miss_tid2_sm_l2(11)   and not miss_ci2_l2   and not miss_flushed2_l2   and not miss_inval2_l2;
ecc_block_iu0(2) <=  an_ac_reld_ecc_err_l2 and miss_tid2_sm_l2(11)   and miss_need_hold2_l2;
ecc_err(3) <=  new_ecc_err(3)   or miss_ecc_err3_l2;
ecc_err_ue(3) <=  new_ecc_err_ue(3)   or miss_ecc_err_ue3_l2;
ecc_inval(3) <=  (an_ac_reld_ecc_err_l2 or an_ac_reld_ecc_err_ue_l2) and
                  miss_tid3_sm_l2(11)   and not miss_ci3_l2   and not miss_flushed3_l2   and not miss_inval3_l2;
ecc_block_iu0(3) <=  an_ac_reld_ecc_err_l2 and miss_tid3_sm_l2(11)   and miss_need_hold3_l2;
icm_ics_ecc_block_iu0  <=  ecc_block_iu0;
-- CheckECC stage
-- Non-CI: If last beat of data has bad ECC, invalidate cache & flush IU1
-- Back inval in Check ECC state
icm_icd_ecc_inval  <=  or_reduce(ecc_inval) or r3_need_back_inval_l2;
r3_addr  <= 
           gate_and(reld_r3_tid_l2(0),   miss_addr0_real_l2(52   to 57)) or
           gate_and(reld_r3_tid_l2(1),   miss_addr1_real_l2(52   to 57)) or
           gate_and(reld_r3_tid_l2(2),   miss_addr2_real_l2(52   to 57)) or
           gate_and(reld_r3_tid_l2(3),   miss_addr3_real_l2(52   to 57));
icm_icd_ecc_addr  <=  r3_addr(52 to 57);
r3_way  <=             gate_and(reld_r3_tid_l2(0),   miss_way0_l2)   or
           gate_and(reld_r3_tid_l2(1),   miss_way1_l2)   or
           gate_and(reld_r3_tid_l2(2),   miss_way2_l2)   or
           gate_and(reld_r3_tid_l2(3),   miss_way3_l2);
icm_icd_ecc_way  <=  r3_way;
-- Flush everything in iu1 to prevent using bad data
icm_ics_iu1_ecc_flush  <=  or_reduce(ecc_inval);
-- CI/Critical QW: Invalidate IU3 or set error bit
ecc_fp  <=  r3_loaded_l2 and an_ac_reld_ecc_err_l2;
icm_icd_iu3_ecc_fp_cancel  <=  ecc_fp and not an_ac_reld_ecc_err_ue_l2;
icm_icd_iu3_ecc_err  <=  r3_loaded_l2 and an_ac_reld_ecc_err_ue_l2;
-----------------------------------------------------------------------
-- Performance Events
-----------------------------------------------------------------------
-- IL1 Miss Cycles
--      - not CI, not Idle, not WaitMiss, & not (CheckECC & done)
perf_event_t0_d(0) <=  not miss_ci0_l2   and not miss_tid0_sm_l2(0)   and not miss_tid0_sm_l2(2)   and
                      not (miss_tid0_sm_l2(11)   and (ecc_err_ue(0)   or not ecc_err(0)))   and
                      not erat_err(0);
perf_event_t1_d(0) <=  not miss_ci1_l2   and not miss_tid1_sm_l2(0)   and not miss_tid1_sm_l2(2)   and
                      not (miss_tid1_sm_l2(11)   and (ecc_err_ue(1)   or not ecc_err(1)))   and
                      not erat_err(1);
perf_event_t2_d(0) <=  not miss_ci2_l2   and not miss_tid2_sm_l2(0)   and not miss_tid2_sm_l2(2)   and
                      not (miss_tid2_sm_l2(11)   and (ecc_err_ue(2)   or not ecc_err(2)))   and
                      not erat_err(2);
perf_event_t3_d(0) <=  not miss_ci3_l2   and not miss_tid3_sm_l2(0)   and not miss_tid3_sm_l2(2)   and
                      not (miss_tid3_sm_l2(11)   and (ecc_err_ue(3)   or not ecc_err(3)))   and
                      not erat_err(3);
-- IL1 Reload Dropped
--      - not CI, flushed, & returning to Idle  (release_sm_hold and not miss_tid_sm<a>_d(11) is a more timing-friendly way of saying this)
perf_event_t0_d(1) <=  not miss_ci0_l2   and miss_flushed0_l2   and (release_sm_hold(0)   and not miss_tid0_sm_d(11));
perf_event_t1_d(1) <=  not miss_ci1_l2   and miss_flushed1_l2   and (release_sm_hold(1)   and not miss_tid1_sm_d(11));
perf_event_t2_d(1) <=  not miss_ci2_l2   and miss_flushed2_l2   and (release_sm_hold(2)   and not miss_tid2_sm_d(11));
perf_event_t3_d(1) <=  not miss_ci3_l2   and miss_flushed3_l2   and (release_sm_hold(3)   and not miss_tid3_sm_d(11));
ic_perf_event_t0    <=  perf_event_t0_l2;
ic_perf_event_t1    <=  perf_event_t1_l2;
ic_perf_event_t2    <=  perf_event_t2_l2;
ic_perf_event_t3    <=  perf_event_t3_l2;
-----------------------------------------------------------------------
-- Debug Bus
-----------------------------------------------------------------------
miss_dbg_data0(0 TO 21) <=  miss_tid0_sm_l2(0   to 11) &
                                       miss_flush_occurred0_l2   & miss_flushed0_l2   & miss_inval0_l2   & miss_block_fp0_l2   &
                                       miss_ecc_err0_l2   & miss_ecc_err_ue0_l2   & miss_wrote_dir0_l2   & miss_need_hold0_l2   &
                                       reld_r2_tid_l2(0)   & load_tid_no_block(0);
miss_dbg_data0(22 TO 43) <=  miss_tid1_sm_l2(0   to 11) &
                                       miss_flush_occurred1_l2   & miss_flushed1_l2   & miss_inval1_l2   & miss_block_fp1_l2   &
                                       miss_ecc_err1_l2   & miss_ecc_err_ue1_l2   & miss_wrote_dir1_l2   & miss_need_hold1_l2   &
                                       reld_r2_tid_l2(1)   & load_tid_no_block(1);
miss_dbg_data0(44 TO 65) <=  miss_tid2_sm_l2(0   to 11) &
                                       miss_flush_occurred2_l2   & miss_flushed2_l2   & miss_inval2_l2   & miss_block_fp2_l2   &
                                       miss_ecc_err2_l2   & miss_ecc_err_ue2_l2   & miss_wrote_dir2_l2   & miss_need_hold2_l2   &
                                       reld_r2_tid_l2(2)   & load_tid_no_block(2);
miss_dbg_data0(66 TO 87) <=  miss_tid3_sm_l2(0   to 11) &
                                       miss_flush_occurred3_l2   & miss_flushed3_l2   & miss_inval3_l2   & miss_block_fp3_l2   &
                                       miss_ecc_err3_l2   & miss_ecc_err_ue3_l2   & miss_wrote_dir3_l2   & miss_need_hold3_l2   &
                                       reld_r2_tid_l2(3)   & load_tid_no_block(3);
miss_dbg_data1(0 TO 11) <=  miss_tid0_sm_l2(0 to 11);
miss_dbg_data1(12 TO 23) <=  miss_tid1_sm_l2(0 to 11);
miss_dbg_data1(24) <=  miss_tid2_sm_l2(0);
miss_dbg_data1(25) <=  miss_tid3_sm_l2(0);
miss_dbg_data1(26 TO 35) <=  r2_load_addr(52 to 61);
miss_dbg_data1(36 TO 39) <=  row_val_l2;
miss_dbg_data1_d(51) <=  lru_write_hit;
miss_dbg_data1(40) <=  miss_dbg_data1_l2(51);
miss_dbg_data1(41 TO 43) <=  row_lru_l2;
miss_dbg_data1(44 TO 47) <=  select_lru;
miss_dbg_data1(48 TO 51) <=  lru_valid;
miss_dbg_data1_d(52 TO 55) <=  row_match_way;
miss_dbg_data1_d(56 TO 59) <=  next_way;
miss_dbg_data1(52 TO 59) <=  miss_dbg_data1_l2(52 to 59);
miss_dbg_data1(60 TO 63) <=  perf_event_t0_l2(1) & perf_event_t1_l2(1) & perf_event_t2_l2(1) & perf_event_t3_l2(1);
miss_dbg_data1(64 TO 67) <=  data_write;
miss_dbg_data1(68 TO 71) <=  miss_inval0_l2 & miss_inval1_l2 & miss_inval2_l2 & miss_inval3_l2;
miss_dbg_data1(72) <=  icd_icm_iu2_inval;
miss_dbg_data1(73) <=  r2_load_2ucode;
miss_dbg_data1(74) <=  dir_inval;
miss_dbg_data1(75) <=  r3_need_back_inval_l2;
miss_dbg_data1(76 TO 79) <=  write_dir_val;
miss_dbg_data1(80 TO 83) <=  load_tid_no_block;
miss_dbg_data1(84 TO 87) <=  reld_r2_tid_l2;
miss_dbg_data2(0 TO 9) <=  icd_icm_addr_real(52 to 61);
miss_dbg_data2(10 TO 13) <=  miss_tid0_sm_l2(0) & miss_tid1_sm_l2(0) & miss_tid2_sm_l2(0) & miss_tid3_sm_l2(0);
miss_dbg_data2(14 TO 17) <=  req_thread_l2;
miss_dbg_data2(18) <=  request_l2;
miss_dbg_data2(19 TO 27) <=  req_wimge_l2 & req_userdef_l2;
miss_dbg_data2(28) <=  iu3_miss_match_l2;
miss_dbg_data2(29) <=  preload_hold_iu0;
miss_dbg_data2(30) <=  dir_inval;
miss_dbg_data2(31) <=  r3_need_back_inval_l2;
miss_dbg_data2(32 TO 35) <=  write_dir_val;
miss_dbg_data2(36 TO 39) <=  load_tid_no_block;
miss_dbg_data2(40 TO 43) <=  reld_r2_tid_l2;
miss_dbg_trigger(0 TO 5) <=  req_ra_l2(52 to 57);
miss_dbg_trigger(6) <=  request_l2;
miss_dbg_trigger(7) <=  reld_r0_vld;
miss_dbg_trigger(8 TO 9) <=  an_ac_reld_core_tag_l2(3 to 4);
miss_dbg_trigger(10) <=  an_ac_reld_ecc_err_l2;
miss_dbg_trigger(11) <=  an_ac_reld_ecc_err_ue_l2;
-----------------------------------------------------------------------
-- Latches
-----------------------------------------------------------------------
spr_ic_cls_latch: tri_rlmlatch_p
  generic map (init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => default_reld_act,
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
bp_config_latch: tri_rlmreg_p
  generic map (width => bp_config_l2'length, init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => default_reld_act,        
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(bp_config_offset to bp_config_offset + bp_config_l2'length-1),
            scout   => sov(bp_config_offset to bp_config_offset + bp_config_l2'length-1),
            din     => bp_config_d,
            dout    => bp_config_l2 );
an_ac_reld_data_vld_latch: tri_rlmlatch_p
  generic map (init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => default_reld_act,
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(an_ac_reld_data_vld_offset),
            scout   => sov(an_ac_reld_data_vld_offset),
            din     => an_ac_reld_data_vld_d,
            dout    => an_ac_reld_data_vld_l2   );
an_ac_reld_core_tag_latch: tri_rlmreg_p
  generic map (width => an_ac_reld_core_tag_l2'length, init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => default_reld_act, 
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(an_ac_reld_core_tag_offset to an_ac_reld_core_tag_offset + an_ac_reld_core_tag_l2'length-1),
            scout   => sov(an_ac_reld_core_tag_offset to an_ac_reld_core_tag_offset + an_ac_reld_core_tag_l2'length-1),
            din     => an_ac_reld_core_tag_d,
            dout    => an_ac_reld_core_tag_l2);
an_ac_reld_qw_latch: tri_rlmreg_p
  generic map (width => an_ac_reld_qw_l2'length, init => 0, needs_sreset => 0, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => default_reld_act, 
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(an_ac_reld_qw_offset to an_ac_reld_qw_offset + an_ac_reld_qw_l2'length-1),
            scout   => sov(an_ac_reld_qw_offset to an_ac_reld_qw_offset + an_ac_reld_qw_l2'length-1),
            din     => an_ac_reld_qw_d,
            dout    => an_ac_reld_qw_l2);
reld_r1_tid_latch: tri_rlmreg_p
  generic map (width => reld_r1_tid_l2'length, init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => default_reld_act,
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(reld_r1_tid_offset to reld_r1_tid_offset + reld_r1_tid_l2'length-1),
            scout   => sov(reld_r1_tid_offset to reld_r1_tid_offset + reld_r1_tid_l2'length-1),
            din     => reld_r1_tid_d,
            dout    => reld_r1_tid_l2);
reld_r1_qw_latch: tri_rlmreg_p
  generic map (width => reld_r1_qw_l2'length, init => 0, needs_sreset => 0, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => default_reld_act,
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(reld_r1_qw_offset to reld_r1_qw_offset + reld_r1_qw_l2'length-1),
            scout   => sov(reld_r1_qw_offset to reld_r1_qw_offset + reld_r1_qw_l2'length-1),
            din     => reld_r1_qw_d,
            dout    => reld_r1_qw_l2);
an_ac_reld_data_latch: tri_rlmreg_p
  generic map (width => an_ac_reld_data_l2'length, init => 0, needs_sreset => 0, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => reld_r2_act,     
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(an_ac_reld_data_offset to an_ac_reld_data_offset + an_ac_reld_data_l2'length-1),
            scout   => sov(an_ac_reld_data_offset to an_ac_reld_data_offset + an_ac_reld_data_l2'length-1),
            din     => an_ac_reld_data_d,
            dout    => an_ac_reld_data_l2);
reld_r2_tid_latch: tri_rlmreg_p
  generic map (width => reld_r2_tid_l2'length, init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => default_reld_act,
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(reld_r2_tid_offset to reld_r2_tid_offset + reld_r2_tid_l2'length-1),
            scout   => sov(reld_r2_tid_offset to reld_r2_tid_offset + reld_r2_tid_l2'length-1),
            din     => reld_r2_tid_d,
            dout    => reld_r2_tid_l2);
reld_r2_qw_latch: tri_rlmreg_p
  generic map (width => reld_r2_qw_l2'length, init => 0, needs_sreset => 0, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => reld_r2_act,     
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(reld_r2_qw_offset to reld_r2_qw_offset + reld_r2_qw_l2'length-1),
            scout   => sov(reld_r2_qw_offset to reld_r2_qw_offset + reld_r2_qw_l2'length-1),
            din     => reld_r2_qw_d,
            dout    => reld_r2_qw_l2);
r2_crit_qw_latch: tri_rlmlatch_p
  generic map (init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => default_reld_act,
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(r2_crit_qw_offset),
            scout   => sov(r2_crit_qw_offset),
            din     => r2_crit_qw_d,
            dout    => r2_crit_qw_l2   );
reld_r3_tid_latch: tri_rlmreg_p
  generic map (width => reld_r3_tid_l2'length, init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => default_reld_act,
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(reld_r3_tid_offset to reld_r3_tid_offset + reld_r3_tid_l2'length-1),
            scout   => sov(reld_r3_tid_offset to reld_r3_tid_offset + reld_r3_tid_l2'length-1),
            din     => reld_r3_tid_d,
            dout    => reld_r3_tid_l2);
r3_loaded_latch: tri_rlmlatch_p
  generic map (init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => default_reld_act,
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(r3_loaded_offset),
            scout   => sov(r3_loaded_offset),
            din     => r3_loaded_d,
            dout    => r3_loaded_l2   );
r3_need_back_inval_latch: tri_rlmlatch_p
  generic map (init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => default_reld_act,
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(r3_need_back_inval_offset),
            scout   => sov(r3_need_back_inval_offset),
            din     => r3_need_back_inval_d,
            dout    => r3_need_back_inval_l2   );
row_lru_latch: tri_rlmreg_p
  generic map (width => row_lru_l2'length, init => 0, needs_sreset => 0, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => default_reld_act,
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(row_lru_offset to row_lru_offset + row_lru_l2'length-1),
            scout   => sov(row_lru_offset to row_lru_offset + row_lru_l2'length-1),
            din     => row_lru_d,
            dout    => row_lru_l2);
row_val_latch: tri_rlmreg_p
  generic map (width => row_val_l2'length, init => 0, needs_sreset => 0, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => default_reld_act,
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(row_val_offset to row_val_offset + row_val_l2'length-1),
            scout   => sov(row_val_offset to row_val_offset + row_val_l2'length-1),
            din     => row_val_d,
            dout    => row_val_l2);
an_ac_reld_ecc_err_latch: tri_rlmlatch_p
  generic map (init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => default_reld_act,
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(an_ac_reld_ecc_err_offset),
            scout   => sov(an_ac_reld_ecc_err_offset),
            din     => an_ac_reld_ecc_err_d,
            dout    => an_ac_reld_ecc_err_l2   );
an_ac_reld_ecc_err_ue_latch: tri_rlmlatch_p
  generic map (init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => default_reld_act,
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(an_ac_reld_ecc_err_ue_offset),
            scout   => sov(an_ac_reld_ecc_err_ue_offset),
            din     => an_ac_reld_ecc_err_ue_d,
            dout    => an_ac_reld_ecc_err_ue_l2   );
request_latch: tri_rlmlatch_p
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
            scin    => siv(request_offset),
            scout   => sov(request_offset),
            din     => request_d,
            dout    => request_l2   );
req_thread_latch: tri_rlmreg_p
  generic map (width => req_thread_l2'length, init => 0, needs_sreset => 0, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => icd_icm_any_iu2_valid,    
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(req_thread_offset to req_thread_offset + req_thread_l2'length-1),
            scout   => sov(req_thread_offset to req_thread_offset + req_thread_l2'length-1),
            din     => req_thread_d,
            dout    => req_thread_l2);
req_ra_latch: tri_rlmreg_p
  generic map (width => req_ra_l2'length, init => 0, needs_sreset => 0, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => icd_icm_any_iu2_valid,    
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(req_ra_offset to req_ra_offset + req_ra_l2'length-1),
            scout   => sov(req_ra_offset to req_ra_offset + req_ra_l2'length-1),
            din     => req_ra_d,
            dout    => req_ra_l2);
req_wimge_latch: tri_rlmreg_p
  generic map (width => req_wimge_l2'length, init => 0, needs_sreset => 0, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => icd_icm_any_iu2_valid,    
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(req_wimge_offset to req_wimge_offset + req_wimge_l2'length-1),
            scout   => sov(req_wimge_offset to req_wimge_offset + req_wimge_l2'length-1),
            din     => req_wimge_d,
            dout    => req_wimge_l2);
req_userdef_latch: tri_rlmreg_p
  generic map (width => req_userdef_l2'length, init => 0, needs_sreset => 0, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => icd_icm_any_iu2_valid,    
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(req_userdef_offset to req_userdef_offset + req_userdef_l2'length-1),
            scout   => sov(req_userdef_offset to req_userdef_offset + req_userdef_l2'length-1),
            din     => req_userdef_d,
            dout    => req_userdef_l2);
iu3_miss_match_latch: tri_rlmlatch_p
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
            scin    => siv(iu3_miss_match_offset),
            scout   => sov(iu3_miss_match_offset),
            din     => iu3_miss_match_d,
            dout    => iu3_miss_match_l2   );
miss_tid0_sm_a_latch:   tri_rlmreg_p
  generic map (width => 3, init => 2**(3-1), needs_sreset => 1, expand_type => expand_type)  
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
            scin    => siv(miss_tid0_sm_offset   to miss_tid0_sm_offset   + 2),
            scout   => sov(miss_tid0_sm_offset   to miss_tid0_sm_offset   + 2),
            din     => miss_tid0_sm_d(0   to 2),
            dout    => miss_tid0_sm_l2(0   to 2));
miss_tid1_sm_a_latch:   tri_rlmreg_p
  generic map (width => 3, init => 2**(3-1), needs_sreset => 1, expand_type => expand_type)  
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
            scin    => siv(miss_tid1_sm_offset   to miss_tid1_sm_offset   + 2),
            scout   => sov(miss_tid1_sm_offset   to miss_tid1_sm_offset   + 2),
            din     => miss_tid1_sm_d(0   to 2),
            dout    => miss_tid1_sm_l2(0   to 2));
miss_tid2_sm_a_latch:   tri_rlmreg_p
  generic map (width => 3, init => 2**(3-1), needs_sreset => 1, expand_type => expand_type)  
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
            scin    => siv(miss_tid2_sm_offset   to miss_tid2_sm_offset   + 2),
            scout   => sov(miss_tid2_sm_offset   to miss_tid2_sm_offset   + 2),
            din     => miss_tid2_sm_d(0   to 2),
            dout    => miss_tid2_sm_l2(0   to 2));
miss_tid3_sm_a_latch:   tri_rlmreg_p
  generic map (width => 3, init => 2**(3-1), needs_sreset => 1, expand_type => expand_type)  
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
            scin    => siv(miss_tid3_sm_offset   to miss_tid3_sm_offset   + 2),
            scout   => sov(miss_tid3_sm_offset   to miss_tid3_sm_offset   + 2),
            din     => miss_tid3_sm_d(0   to 2),
            dout    => miss_tid3_sm_l2(0   to 2));
miss_tid0_sm_b_latch:   tri_rlmreg_p
  generic map (width => miss_tid0_sm_l2'length-3,   init => 0, needs_sreset => 1, expand_type => expand_type)  
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => default_reld_act,
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(miss_tid0_sm_offset+3   to miss_tid0_sm_offset   + miss_tid0_sm_l2'length-1),
            scout   => sov(miss_tid0_sm_offset+3   to miss_tid0_sm_offset   + miss_tid0_sm_l2'length-1),
            din     => miss_tid0_sm_d(3   to miss_tid0_sm_l2'length-1),
            dout    => miss_tid0_sm_l2(3   to miss_tid0_sm_l2'length-1));
miss_tid1_sm_b_latch:   tri_rlmreg_p
  generic map (width => miss_tid1_sm_l2'length-3,   init => 0, needs_sreset => 1, expand_type => expand_type)  
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => default_reld_act,
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(miss_tid1_sm_offset+3   to miss_tid1_sm_offset   + miss_tid1_sm_l2'length-1),
            scout   => sov(miss_tid1_sm_offset+3   to miss_tid1_sm_offset   + miss_tid1_sm_l2'length-1),
            din     => miss_tid1_sm_d(3   to miss_tid1_sm_l2'length-1),
            dout    => miss_tid1_sm_l2(3   to miss_tid1_sm_l2'length-1));
miss_tid2_sm_b_latch:   tri_rlmreg_p
  generic map (width => miss_tid2_sm_l2'length-3,   init => 0, needs_sreset => 1, expand_type => expand_type)  
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => default_reld_act,
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(miss_tid2_sm_offset+3   to miss_tid2_sm_offset   + miss_tid2_sm_l2'length-1),
            scout   => sov(miss_tid2_sm_offset+3   to miss_tid2_sm_offset   + miss_tid2_sm_l2'length-1),
            din     => miss_tid2_sm_d(3   to miss_tid2_sm_l2'length-1),
            dout    => miss_tid2_sm_l2(3   to miss_tid2_sm_l2'length-1));
miss_tid3_sm_b_latch:   tri_rlmreg_p
  generic map (width => miss_tid3_sm_l2'length-3,   init => 0, needs_sreset => 1, expand_type => expand_type)  
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => default_reld_act,
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(miss_tid3_sm_offset+3   to miss_tid3_sm_offset   + miss_tid3_sm_l2'length-1),
            scout   => sov(miss_tid3_sm_offset+3   to miss_tid3_sm_offset   + miss_tid3_sm_l2'length-1),
            din     => miss_tid3_sm_d(3   to miss_tid3_sm_l2'length-1),
            dout    => miss_tid3_sm_l2(3   to miss_tid3_sm_l2'length-1));
miss_flush_occurred0_latch:   tri_rlmlatch_p
  generic map (init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => default_reld_act,
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(miss_flush_occurred0_offset),
            scout   => sov(miss_flush_occurred0_offset),
            din     => miss_flush_occurred0_d,
            dout    => miss_flush_occurred0_l2     );
miss_flush_occurred1_latch:   tri_rlmlatch_p
  generic map (init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => default_reld_act,
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(miss_flush_occurred1_offset),
            scout   => sov(miss_flush_occurred1_offset),
            din     => miss_flush_occurred1_d,
            dout    => miss_flush_occurred1_l2     );
miss_flush_occurred2_latch:   tri_rlmlatch_p
  generic map (init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => default_reld_act,
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(miss_flush_occurred2_offset),
            scout   => sov(miss_flush_occurred2_offset),
            din     => miss_flush_occurred2_d,
            dout    => miss_flush_occurred2_l2     );
miss_flush_occurred3_latch:   tri_rlmlatch_p
  generic map (init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => default_reld_act,
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(miss_flush_occurred3_offset),
            scout   => sov(miss_flush_occurred3_offset),
            din     => miss_flush_occurred3_d,
            dout    => miss_flush_occurred3_l2     );
miss_flushed0_latch:   tri_rlmlatch_p
  generic map (init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => default_reld_act,
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(miss_flushed0_offset),
            scout   => sov(miss_flushed0_offset),
            din     => miss_flushed0_d,
            dout    => miss_flushed0_l2     );
miss_flushed1_latch:   tri_rlmlatch_p
  generic map (init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => default_reld_act,
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(miss_flushed1_offset),
            scout   => sov(miss_flushed1_offset),
            din     => miss_flushed1_d,
            dout    => miss_flushed1_l2     );
miss_flushed2_latch:   tri_rlmlatch_p
  generic map (init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => default_reld_act,
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(miss_flushed2_offset),
            scout   => sov(miss_flushed2_offset),
            din     => miss_flushed2_d,
            dout    => miss_flushed2_l2     );
miss_flushed3_latch:   tri_rlmlatch_p
  generic map (init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => default_reld_act,
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(miss_flushed3_offset),
            scout   => sov(miss_flushed3_offset),
            din     => miss_flushed3_d,
            dout    => miss_flushed3_l2     );
miss_inval0_latch:   tri_rlmlatch_p
  generic map (init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => default_reld_act,
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(miss_inval0_offset),
            scout   => sov(miss_inval0_offset),
            din     => miss_inval0_d,
            dout    => miss_inval0_l2     );
miss_inval1_latch:   tri_rlmlatch_p
  generic map (init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => default_reld_act,
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(miss_inval1_offset),
            scout   => sov(miss_inval1_offset),
            din     => miss_inval1_d,
            dout    => miss_inval1_l2     );
miss_inval2_latch:   tri_rlmlatch_p
  generic map (init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => default_reld_act,
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(miss_inval2_offset),
            scout   => sov(miss_inval2_offset),
            din     => miss_inval2_d,
            dout    => miss_inval2_l2     );
miss_inval3_latch:   tri_rlmlatch_p
  generic map (init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => default_reld_act,
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(miss_inval3_offset),
            scout   => sov(miss_inval3_offset),
            din     => miss_inval3_d,
            dout    => miss_inval3_l2     );
miss_block_fp0_latch:   tri_rlmlatch_p
  generic map (init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => default_reld_act,
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(miss_block_fp0_offset),
            scout   => sov(miss_block_fp0_offset),
            din     => miss_block_fp0_d,
            dout    => miss_block_fp0_l2     );
miss_block_fp1_latch:   tri_rlmlatch_p
  generic map (init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => default_reld_act,
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(miss_block_fp1_offset),
            scout   => sov(miss_block_fp1_offset),
            din     => miss_block_fp1_d,
            dout    => miss_block_fp1_l2     );
miss_block_fp2_latch:   tri_rlmlatch_p
  generic map (init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => default_reld_act,
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(miss_block_fp2_offset),
            scout   => sov(miss_block_fp2_offset),
            din     => miss_block_fp2_d,
            dout    => miss_block_fp2_l2     );
miss_block_fp3_latch:   tri_rlmlatch_p
  generic map (init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => default_reld_act,
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(miss_block_fp3_offset),
            scout   => sov(miss_block_fp3_offset),
            din     => miss_block_fp3_d,
            dout    => miss_block_fp3_l2     );
miss_ecc_err0_latch:   tri_rlmlatch_p
  generic map (init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => default_reld_act,
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(miss_ecc_err0_offset),
            scout   => sov(miss_ecc_err0_offset),
            din     => miss_ecc_err0_d,
            dout    => miss_ecc_err0_l2     );
miss_ecc_err1_latch:   tri_rlmlatch_p
  generic map (init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => default_reld_act,
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(miss_ecc_err1_offset),
            scout   => sov(miss_ecc_err1_offset),
            din     => miss_ecc_err1_d,
            dout    => miss_ecc_err1_l2     );
miss_ecc_err2_latch:   tri_rlmlatch_p
  generic map (init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => default_reld_act,
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(miss_ecc_err2_offset),
            scout   => sov(miss_ecc_err2_offset),
            din     => miss_ecc_err2_d,
            dout    => miss_ecc_err2_l2     );
miss_ecc_err3_latch:   tri_rlmlatch_p
  generic map (init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => default_reld_act,
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(miss_ecc_err3_offset),
            scout   => sov(miss_ecc_err3_offset),
            din     => miss_ecc_err3_d,
            dout    => miss_ecc_err3_l2     );
miss_ecc_err_ue0_latch:   tri_rlmlatch_p
  generic map (init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => default_reld_act,
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(miss_ecc_err_ue0_offset),
            scout   => sov(miss_ecc_err_ue0_offset),
            din     => miss_ecc_err_ue0_d,
            dout    => miss_ecc_err_ue0_l2     );
miss_ecc_err_ue1_latch:   tri_rlmlatch_p
  generic map (init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => default_reld_act,
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(miss_ecc_err_ue1_offset),
            scout   => sov(miss_ecc_err_ue1_offset),
            din     => miss_ecc_err_ue1_d,
            dout    => miss_ecc_err_ue1_l2     );
miss_ecc_err_ue2_latch:   tri_rlmlatch_p
  generic map (init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => default_reld_act,
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(miss_ecc_err_ue2_offset),
            scout   => sov(miss_ecc_err_ue2_offset),
            din     => miss_ecc_err_ue2_d,
            dout    => miss_ecc_err_ue2_l2     );
miss_ecc_err_ue3_latch:   tri_rlmlatch_p
  generic map (init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => default_reld_act,
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(miss_ecc_err_ue3_offset),
            scout   => sov(miss_ecc_err_ue3_offset),
            din     => miss_ecc_err_ue3_d,
            dout    => miss_ecc_err_ue3_l2     );
miss_wrote_dir0_latch:   tri_rlmlatch_p
  generic map (init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => default_reld_act,
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(miss_wrote_dir0_offset),
            scout   => sov(miss_wrote_dir0_offset),
            din     => miss_wrote_dir0_d,
            dout    => miss_wrote_dir0_l2     );
miss_wrote_dir1_latch:   tri_rlmlatch_p
  generic map (init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => default_reld_act,
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(miss_wrote_dir1_offset),
            scout   => sov(miss_wrote_dir1_offset),
            din     => miss_wrote_dir1_d,
            dout    => miss_wrote_dir1_l2     );
miss_wrote_dir2_latch:   tri_rlmlatch_p
  generic map (init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => default_reld_act,
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(miss_wrote_dir2_offset),
            scout   => sov(miss_wrote_dir2_offset),
            din     => miss_wrote_dir2_d,
            dout    => miss_wrote_dir2_l2     );
miss_wrote_dir3_latch:   tri_rlmlatch_p
  generic map (init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => default_reld_act,
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(miss_wrote_dir3_offset),
            scout   => sov(miss_wrote_dir3_offset),
            din     => miss_wrote_dir3_d,
            dout    => miss_wrote_dir3_l2     );
miss_need_hold0_latch:   tri_rlmlatch_p
  generic map (init => 0, needs_sreset => 0, expand_type => expand_type)
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
            scin    => siv(miss_need_hold0_offset),
            scout   => sov(miss_need_hold0_offset),
            din     => miss_need_hold0_d,
            dout    => miss_need_hold0_l2     );
miss_need_hold1_latch:   tri_rlmlatch_p
  generic map (init => 0, needs_sreset => 0, expand_type => expand_type)
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
            scin    => siv(miss_need_hold1_offset),
            scout   => sov(miss_need_hold1_offset),
            din     => miss_need_hold1_d,
            dout    => miss_need_hold1_l2     );
miss_need_hold2_latch:   tri_rlmlatch_p
  generic map (init => 0, needs_sreset => 0, expand_type => expand_type)
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
            scin    => siv(miss_need_hold2_offset),
            scout   => sov(miss_need_hold2_offset),
            din     => miss_need_hold2_d,
            dout    => miss_need_hold2_l2     );
miss_need_hold3_latch:   tri_rlmlatch_p
  generic map (init => 0, needs_sreset => 0, expand_type => expand_type)
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
            scin    => siv(miss_need_hold3_offset),
            scout   => sov(miss_need_hold3_offset),
            din     => miss_need_hold3_d,
            dout    => miss_need_hold3_l2     );
miss_addr0_real_latch:   tri_rlmreg_p
  generic map (width => miss_addr0_real_l2'length,   init => 0, needs_sreset => 0, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => miss_act(0),
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(miss_addr0_real_offset   to miss_addr0_real_offset   + miss_addr0_real_l2'length-1),
            scout   => sov(miss_addr0_real_offset   to miss_addr0_real_offset   + miss_addr0_real_l2'length-1),
            din     => miss_addr0_real_d,
            dout    => miss_addr0_real_l2);
miss_addr1_real_latch:   tri_rlmreg_p
  generic map (width => miss_addr1_real_l2'length,   init => 0, needs_sreset => 0, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => miss_act(1),
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(miss_addr1_real_offset   to miss_addr1_real_offset   + miss_addr1_real_l2'length-1),
            scout   => sov(miss_addr1_real_offset   to miss_addr1_real_offset   + miss_addr1_real_l2'length-1),
            din     => miss_addr1_real_d,
            dout    => miss_addr1_real_l2);
miss_addr2_real_latch:   tri_rlmreg_p
  generic map (width => miss_addr2_real_l2'length,   init => 0, needs_sreset => 0, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => miss_act(2),
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(miss_addr2_real_offset   to miss_addr2_real_offset   + miss_addr2_real_l2'length-1),
            scout   => sov(miss_addr2_real_offset   to miss_addr2_real_offset   + miss_addr2_real_l2'length-1),
            din     => miss_addr2_real_d,
            dout    => miss_addr2_real_l2);
miss_addr3_real_latch:   tri_rlmreg_p
  generic map (width => miss_addr3_real_l2'length,   init => 0, needs_sreset => 0, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => miss_act(3),
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(miss_addr3_real_offset   to miss_addr3_real_offset   + miss_addr3_real_l2'length-1),
            scout   => sov(miss_addr3_real_offset   to miss_addr3_real_offset   + miss_addr3_real_l2'length-1),
            din     => miss_addr3_real_d,
            dout    => miss_addr3_real_l2);
miss_addr0_eff_latch:   tri_rlmreg_p
  generic map (width => miss_addr0_eff_l2'length,   init => 0, needs_sreset => 0, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => miss_act(0),
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(miss_addr0_eff_offset   to miss_addr0_eff_offset   + miss_addr0_eff_l2'length-1),
            scout   => sov(miss_addr0_eff_offset   to miss_addr0_eff_offset   + miss_addr0_eff_l2'length-1),
            din     => miss_addr0_eff_d,
            dout    => miss_addr0_eff_l2);
miss_addr1_eff_latch:   tri_rlmreg_p
  generic map (width => miss_addr1_eff_l2'length,   init => 0, needs_sreset => 0, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => miss_act(1),
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(miss_addr1_eff_offset   to miss_addr1_eff_offset   + miss_addr1_eff_l2'length-1),
            scout   => sov(miss_addr1_eff_offset   to miss_addr1_eff_offset   + miss_addr1_eff_l2'length-1),
            din     => miss_addr1_eff_d,
            dout    => miss_addr1_eff_l2);
miss_addr2_eff_latch:   tri_rlmreg_p
  generic map (width => miss_addr2_eff_l2'length,   init => 0, needs_sreset => 0, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => miss_act(2),
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(miss_addr2_eff_offset   to miss_addr2_eff_offset   + miss_addr2_eff_l2'length-1),
            scout   => sov(miss_addr2_eff_offset   to miss_addr2_eff_offset   + miss_addr2_eff_l2'length-1),
            din     => miss_addr2_eff_d,
            dout    => miss_addr2_eff_l2);
miss_addr3_eff_latch:   tri_rlmreg_p
  generic map (width => miss_addr3_eff_l2'length,   init => 0, needs_sreset => 0, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => miss_act(3),
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(miss_addr3_eff_offset   to miss_addr3_eff_offset   + miss_addr3_eff_l2'length-1),
            scout   => sov(miss_addr3_eff_offset   to miss_addr3_eff_offset   + miss_addr3_eff_l2'length-1),
            din     => miss_addr3_eff_d,
            dout    => miss_addr3_eff_l2);
miss_ci0_latch:   tri_rlmlatch_p
  generic map (init => 0, needs_sreset => 0, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => miss_act(0),
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(miss_ci0_offset),
            scout   => sov(miss_ci0_offset),
            din     => miss_ci0_d,
            dout    => miss_ci0_l2     );
miss_ci1_latch:   tri_rlmlatch_p
  generic map (init => 0, needs_sreset => 0, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => miss_act(1),
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(miss_ci1_offset),
            scout   => sov(miss_ci1_offset),
            din     => miss_ci1_d,
            dout    => miss_ci1_l2     );
miss_ci2_latch:   tri_rlmlatch_p
  generic map (init => 0, needs_sreset => 0, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => miss_act(2),
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(miss_ci2_offset),
            scout   => sov(miss_ci2_offset),
            din     => miss_ci2_d,
            dout    => miss_ci2_l2     );
miss_ci3_latch:   tri_rlmlatch_p
  generic map (init => 0, needs_sreset => 0, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => miss_act(3),
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(miss_ci3_offset),
            scout   => sov(miss_ci3_offset),
            din     => miss_ci3_d,
            dout    => miss_ci3_l2     );
miss_endian0_latch:   tri_rlmlatch_p
  generic map (init => 0, needs_sreset => 0, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => miss_act(0),
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(miss_endian0_offset),
            scout   => sov(miss_endian0_offset),
            din     => miss_endian0_d,
            dout    => miss_endian0_l2     );
miss_endian1_latch:   tri_rlmlatch_p
  generic map (init => 0, needs_sreset => 0, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => miss_act(1),
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(miss_endian1_offset),
            scout   => sov(miss_endian1_offset),
            din     => miss_endian1_d,
            dout    => miss_endian1_l2     );
miss_endian2_latch:   tri_rlmlatch_p
  generic map (init => 0, needs_sreset => 0, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => miss_act(2),
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(miss_endian2_offset),
            scout   => sov(miss_endian2_offset),
            din     => miss_endian2_d,
            dout    => miss_endian2_l2     );
miss_endian3_latch:   tri_rlmlatch_p
  generic map (init => 0, needs_sreset => 0, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => miss_act(3),
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(miss_endian3_offset),
            scout   => sov(miss_endian3_offset),
            din     => miss_endian3_d,
            dout    => miss_endian3_l2     );
miss_2ucode0_latch:   tri_rlmlatch_p
  generic map (init => 0, needs_sreset => 0, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => miss_act(0),
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(miss_2ucode0_offset),
            scout   => sov(miss_2ucode0_offset),
            din     => miss_2ucode0_d,
            dout    => miss_2ucode0_l2     );
miss_2ucode1_latch:   tri_rlmlatch_p
  generic map (init => 0, needs_sreset => 0, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => miss_act(1),
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(miss_2ucode1_offset),
            scout   => sov(miss_2ucode1_offset),
            din     => miss_2ucode1_d,
            dout    => miss_2ucode1_l2     );
miss_2ucode2_latch:   tri_rlmlatch_p
  generic map (init => 0, needs_sreset => 0, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => miss_act(2),
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(miss_2ucode2_offset),
            scout   => sov(miss_2ucode2_offset),
            din     => miss_2ucode2_d,
            dout    => miss_2ucode2_l2     );
miss_2ucode3_latch:   tri_rlmlatch_p
  generic map (init => 0, needs_sreset => 0, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => miss_act(3),
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(miss_2ucode3_offset),
            scout   => sov(miss_2ucode3_offset),
            din     => miss_2ucode3_d,
            dout    => miss_2ucode3_l2     );
miss_2ucode0_type_latch:   tri_rlmlatch_p
  generic map (init => 0, needs_sreset => 0, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => miss_act(0),
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(miss_2ucode0_type_offset),
            scout   => sov(miss_2ucode0_type_offset),
            din     => miss_2ucode0_type_d,
            dout    => miss_2ucode0_type_l2     );
miss_2ucode1_type_latch:   tri_rlmlatch_p
  generic map (init => 0, needs_sreset => 0, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => miss_act(1),
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(miss_2ucode1_type_offset),
            scout   => sov(miss_2ucode1_type_offset),
            din     => miss_2ucode1_type_d,
            dout    => miss_2ucode1_type_l2     );
miss_2ucode2_type_latch:   tri_rlmlatch_p
  generic map (init => 0, needs_sreset => 0, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => miss_act(2),
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(miss_2ucode2_type_offset),
            scout   => sov(miss_2ucode2_type_offset),
            din     => miss_2ucode2_type_d,
            dout    => miss_2ucode2_type_l2     );
miss_2ucode3_type_latch:   tri_rlmlatch_p
  generic map (init => 0, needs_sreset => 0, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => miss_act(3),
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(miss_2ucode3_type_offset),
            scout   => sov(miss_2ucode3_type_offset),
            din     => miss_2ucode3_type_d,
            dout    => miss_2ucode3_type_l2     );
miss_way0_latch:   tri_rlmreg_p
  generic map (width => miss_way0_l2'length,   init => 0, needs_sreset => 0, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => reld_r2_act,     
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(miss_way0_offset   to miss_way0_offset   + miss_way0_l2'length-1),
            scout   => sov(miss_way0_offset   to miss_way0_offset   + miss_way0_l2'length-1),
            din     => miss_way0_d,
            dout    => miss_way0_l2);
miss_way1_latch:   tri_rlmreg_p
  generic map (width => miss_way1_l2'length,   init => 0, needs_sreset => 0, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => reld_r2_act,     
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(miss_way1_offset   to miss_way1_offset   + miss_way1_l2'length-1),
            scout   => sov(miss_way1_offset   to miss_way1_offset   + miss_way1_l2'length-1),
            din     => miss_way1_d,
            dout    => miss_way1_l2);
miss_way2_latch:   tri_rlmreg_p
  generic map (width => miss_way2_l2'length,   init => 0, needs_sreset => 0, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => reld_r2_act,     
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(miss_way2_offset   to miss_way2_offset   + miss_way2_l2'length-1),
            scout   => sov(miss_way2_offset   to miss_way2_offset   + miss_way2_l2'length-1),
            din     => miss_way2_d,
            dout    => miss_way2_l2);
miss_way3_latch:   tri_rlmreg_p
  generic map (width => miss_way3_l2'length,   init => 0, needs_sreset => 0, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => reld_r2_act,     
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(miss_way3_offset   to miss_way3_offset   + miss_way3_l2'length-1),
            scout   => sov(miss_way3_offset   to miss_way3_offset   + miss_way3_l2'length-1),
            din     => miss_way3_d,
            dout    => miss_way3_l2);
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
lru_write_next_cycle_latch: tri_rlmreg_p
  generic map (width => lru_write_next_cycle_l2'length, init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => default_reld_act,
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(lru_write_next_cycle_offset to lru_write_next_cycle_offset + lru_write_next_cycle_l2'length-1),
            scout   => sov(lru_write_next_cycle_offset to lru_write_next_cycle_offset + lru_write_next_cycle_l2'length-1),
            din     => lru_write_next_cycle_d,
            dout    => lru_write_next_cycle_l2);
lru_write_latch: tri_rlmreg_p
  generic map (width => lru_write_l2'length, init => 0, needs_sreset => 1, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => default_reld_act,
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(lru_write_offset to lru_write_offset + lru_write_l2'length-1),
            scout   => sov(lru_write_offset to lru_write_offset + lru_write_l2'length-1),
            din     => lru_write_d,
            dout    => lru_write_l2);
miss_dbg_data1_latch: tri_rlmreg_p
  generic map (width => miss_dbg_data1_l2'length, init => 0, needs_sreset => 0, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => trace_bus_enable,
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(miss_dbg_data1_offset to miss_dbg_data1_offset + miss_dbg_data1_l2'length-1),
            scout   => sov(miss_dbg_data1_offset to miss_dbg_data1_offset + miss_dbg_data1_l2'length-1),
            din     => miss_dbg_data1_d,
            dout    => miss_dbg_data1_l2);
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
-----------------------------------------------------------------------
-- Scan
-----------------------------------------------------------------------
siv(0 TO scan_right) <=  sov(1 to scan_right) & scan_in;
scan_out  <=  sov(0);
END IUQ_IC_MISS;
