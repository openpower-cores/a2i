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

entity iuq_bp is
generic(expand_type : integer := 2 ); 
port(

     bp_dbg_data0               : out std_ulogic_vector(0 to 87);
     bp_dbg_data1               : out std_ulogic_vector(0 to 87);

     iu3_0_bh_rd_data           : in  std_ulogic_vector(0 to 1);
     iu3_1_bh_rd_data           : in  std_ulogic_vector(0 to 1);
     iu3_2_bh_rd_data           : in  std_ulogic_vector(0 to 1);
     iu3_3_bh_rd_data           : in  std_ulogic_vector(0 to 1);

     iu1_bh_rd_addr             : out std_ulogic_vector(0 to 7);
     iu1_bh_rd_act              : out std_ulogic;
     ex6_bh_wr_data             : out std_ulogic_vector(0 to 1);
     ex6_bh_wr_addr             : out std_ulogic_vector(0 to 7);
     ex6_bh_wr_act              : out std_ulogic_vector(0 to 3);

     ic_bp_iu1_val              : in  std_ulogic;
     ic_bp_iu1_tid              : in  std_ulogic_vector(0 to 3);      
     ic_bp_iu1_ifar             : in  std_ulogic_vector(52 to 59);       


     ic_bp_iu3_val              : in  std_ulogic_vector(0 to 3);
     ic_bp_iu3_tid              : in  std_ulogic_vector(0 to 3);
     ic_bp_iu3_ifar             : in  EFF_IFAR;
     ic_bp_iu3_error            : in  std_ulogic_vector(0 to 2);
     ic_bp_iu3_2ucode           : in  std_ulogic;
     ic_bp_iu3_2ucode_type      : in  std_ulogic;
     ic_bp_iu3_flush            : in  std_ulogic;

     ic_bp_iu3_0_instr          : in  std_ulogic_vector(0 to 35);        
     ic_bp_iu3_1_instr          : in  std_ulogic_vector(0 to 35);        
     ic_bp_iu3_2_instr          : in  std_ulogic_vector(0 to 35);        
     ic_bp_iu3_3_instr          : in  std_ulogic_vector(0 to 35);        

     bp_ib_iu4_t0_val           : out std_ulogic_vector(0 to 3);
     bp_ib_iu4_t1_val           : out std_ulogic_vector(0 to 3);
     bp_ib_iu4_t2_val           : out std_ulogic_vector(0 to 3);
     bp_ib_iu4_t3_val           : out std_ulogic_vector(0 to 3);
     bp_ib_iu4_ifar             : out EFF_IFAR;       

     bp_ib_iu3_0_instr          : out std_ulogic_vector(0 to 31);        
     bp_ib_iu4_0_instr          : out std_ulogic_vector(32 to 43);        
     bp_ib_iu4_1_instr          : out std_ulogic_vector(0 to 43);        
     bp_ib_iu4_2_instr          : out std_ulogic_vector(0 to 43);        
     bp_ib_iu4_3_instr          : out std_ulogic_vector(0 to 43);        

     bp_ic_iu5_hold_tid         : out std_ulogic_vector(0 to 3);
     bp_ic_iu5_redirect_tid     : out std_ulogic_vector(0 to 3);         
     bp_ic_iu5_redirect_ifar    : out EFF_IFAR;

     xu_iu_ex5_ifar             : in  EFF_IFAR;       
     xu_iu_ex5_tid              : in  std_ulogic_vector(0 to 3);
     xu_iu_ex5_val              : in  std_ulogic;
     xu_iu_ex5_br_update        : in  std_ulogic;                        
     xu_iu_ex5_br_hist          : in  std_ulogic_vector(0 to 1);                        
     xu_iu_ex5_br_taken         : in  std_ulogic;                        
     xu_iu_ex5_bclr             : in  std_ulogic;                       
     xu_iu_ex5_getNIA           : in  std_ulogic;
     xu_iu_ex5_lk               : in  std_ulogic;
     xu_iu_ex5_bh               : in  std_ulogic_vector(0 to 1);
     xu_iu_ex5_gshare           : in  std_ulogic_vector(0 to 3);

     xu_iu_iu3_flush_tid        : in  std_ulogic_vector(0 to 3);         
     xu_iu_iu4_flush_tid        : in  std_ulogic_vector(0 to 3);         
     xu_iu_iu5_flush_tid        : in  std_ulogic_vector(0 to 3);
     xu_iu_ex5_flush_tid        : in  std_ulogic_vector(0 to 3);
     ib_ic_iu5_redirect_tid     : in  std_ulogic_vector(0 to 3);
     uc_flush_tid               : in  std_ulogic_vector(0 to 3);

     spr_bp_config              : in  std_ulogic_vector(0 to 3);
     spr_bp_gshare_mask         : in  std_ulogic_vector(0 to 3);

     vdd                        : inout power_logic;
     gnd                        : inout power_logic;
     nclk                       : in  clk_logic;
     an_ac_scan_dis_dc_b        : in  std_ulogic;
     pc_iu_sg_2                 : in  std_ulogic;
     pc_iu_func_sl_thold_2      : in  std_ulogic;
     clkoff_b                   : in  std_ulogic;
     tc_ac_ccflush_dc           : in  std_ulogic;
     delay_lclkr                : in  std_ulogic;
     mpw1_b                     : in  std_ulogic;
     scan_in                    : in  std_ulogic_vector(0 to 1);
     scan_out                   : out std_ulogic_vector(0 to 1)

);

-- synopsys translate_off


-- synopsys translate_on

end iuq_bp;
architecture iuq_bp of iuq_bp is



constant ic_bp_iu1_tid_offset           : natural := 0;
constant gshare_t0_offset               : natural := ic_bp_iu1_tid_offset       + 4;
constant gshare_t1_offset               : natural := gshare_t0_offset           + 4;
constant gshare_t2_offset               : natural := gshare_t1_offset           + 4;
constant gshare_t3_offset               : natural := gshare_t2_offset           + 4;
constant cp_gshare_t0_offset            : natural := gshare_t3_offset           + 4;
constant cp_gshare_t1_offset            : natural := cp_gshare_t0_offset        + 4;
constant cp_gshare_t2_offset            : natural := cp_gshare_t1_offset        + 4;
constant cp_gshare_t3_offset            : natural := cp_gshare_t2_offset        + 4;
constant iu2_gshare_offset              : natural := cp_gshare_t3_offset        + 4;
constant iu3_gshare_offset              : natural := iu2_gshare_offset          + 4;
constant iu4_bh_offset                  : natural := iu3_gshare_offset          + 4;
constant iu4_lk_offset                  : natural := iu4_bh_offset              + 2;
constant iu4_aa_offset                  : natural := iu4_lk_offset              + 1;
constant iu4_b_offset                   : natural := iu4_aa_offset              + 1;
constant iu4_opcode_offset              : natural := iu4_b_offset               + 1;
constant iu4_excode_offset              : natural := iu4_opcode_offset          + 6;
constant iu4_bo_offset                  : natural := iu4_excode_offset          + 10;
constant iu4_bi_offset                  : natural := iu4_bo_offset              + 5;
constant iu4_tar_offset                 : natural := iu4_bi_offset              + 5;
constant iu4_ifar_offset                : natural := iu4_tar_offset             + 24;
constant iu4_ifar_pri_offset            : natural := iu4_ifar_offset            + EFF_IFAR'length;
constant iu4_pr_taken_offset            : natural := iu4_ifar_pri_offset        + 2;
constant iu4_tid_offset                 : natural := iu4_pr_taken_offset        + 4;
constant iu4_t0_val_offset              : natural := iu4_tid_offset             + 4;
constant iu4_t1_val_offset              : natural := iu4_t0_val_offset          + 4;
constant iu4_t2_val_offset              : natural := iu4_t1_val_offset          + 4;
constant iu4_t3_val_offset              : natural := iu4_t2_val_offset          + 4;
constant iu4_0_instr_offset             : natural := iu4_t3_val_offset         + 4;
constant iu4_1_instr_offset             : natural := iu4_0_instr_offset         + 12;
constant iu4_2_instr_offset             : natural := iu4_1_instr_offset         + 44;
constant iu4_3_instr_offset             : natural := iu4_2_instr_offset         + 44;
constant iu5_redirect_ifar_offset       : natural := iu4_3_instr_offset         + 44;
constant iu5_redirect_tid_offset        : natural := iu5_redirect_ifar_offset   + EFF_IFAR'length;
constant iu5_hold_tid_offset            : natural := iu5_redirect_tid_offset    + 4;
constant iu5_ls_push_offset             : natural := iu5_hold_tid_offset        + 4;
constant iu5_ls_pop_offset              : natural := iu5_ls_push_offset         + 4;
constant iu5_ifar_offset                : natural := iu5_ls_pop_offset          + 4;
constant scan_right0                    : natural := iu5_ifar_offset            + EFF_IFAR'length - 1;

constant iu6_ls_t0_ptr_offset           : natural := 0;
constant iu6_ls_t1_ptr_offset           : natural := iu6_ls_t0_ptr_offset       + 4;
constant iu6_ls_t2_ptr_offset           : natural := iu6_ls_t1_ptr_offset       + 4;
constant iu6_ls_t3_ptr_offset           : natural := iu6_ls_t2_ptr_offset       + 4;
constant iu6_ls_t00_offset              : natural := iu6_ls_t3_ptr_offset       + 4;
constant iu6_ls_t01_offset              : natural := iu6_ls_t00_offset          + EFF_IFAR'length;
constant iu6_ls_t02_offset              : natural := iu6_ls_t01_offset          + EFF_IFAR'length;
constant iu6_ls_t03_offset              : natural := iu6_ls_t02_offset          + EFF_IFAR'length;
constant iu6_ls_t10_offset              : natural := iu6_ls_t03_offset          + EFF_IFAR'length;
constant iu6_ls_t11_offset              : natural := iu6_ls_t10_offset          + EFF_IFAR'length;
constant iu6_ls_t12_offset              : natural := iu6_ls_t11_offset          + EFF_IFAR'length;
constant iu6_ls_t13_offset              : natural := iu6_ls_t12_offset          + EFF_IFAR'length;
constant iu6_ls_t20_offset              : natural := iu6_ls_t13_offset          + EFF_IFAR'length;
constant iu6_ls_t21_offset              : natural := iu6_ls_t20_offset          + EFF_IFAR'length;
constant iu6_ls_t22_offset              : natural := iu6_ls_t21_offset          + EFF_IFAR'length;
constant iu6_ls_t23_offset              : natural := iu6_ls_t22_offset          + EFF_IFAR'length;
constant iu6_ls_t30_offset              : natural := iu6_ls_t23_offset          + EFF_IFAR'length;
constant iu6_ls_t31_offset              : natural := iu6_ls_t30_offset          + EFF_IFAR'length;
constant iu6_ls_t32_offset              : natural := iu6_ls_t31_offset          + EFF_IFAR'length;
constant iu6_ls_t33_offset              : natural := iu6_ls_t32_offset          + EFF_IFAR'length;
constant ex6_val_offset                 : natural := iu6_ls_t33_offset          + EFF_IFAR'length;
constant ex6_ifar_offset                : natural := ex6_val_offset             + 1;
constant ex6_tid_offset                 : natural := ex6_ifar_offset            + EFF_IFAR'length;
constant ex6_br_update_offset           : natural := ex6_tid_offset             + 4;
constant ex6_br_hist_offset             : natural := ex6_br_update_offset       + 1;
constant ex6_br_taken_offset            : natural := ex6_br_hist_offset         + 2;
constant ex6_bclr_offset                : natural := ex6_br_taken_offset        + 1;
constant ex6_lk_offset                  : natural := ex6_bclr_offset            + 1;
constant ex6_gshare_offset              : natural := ex6_lk_offset              + 1;
constant ex6_ls_push_offset             : natural := ex6_gshare_offset          + 4;
constant ex6_ls_pop_offset              : natural := ex6_ls_push_offset         + 4;
constant ex6_flush_tid_offset           : natural := ex6_ls_pop_offset          + 4;
constant ex7_ls_t0_ptr_offset           : natural := ex6_flush_tid_offset       + 4;
constant ex7_ls_t1_ptr_offset           : natural := ex7_ls_t0_ptr_offset       + 4;
constant ex7_ls_t2_ptr_offset           : natural := ex7_ls_t1_ptr_offset       + 4;
constant ex7_ls_t3_ptr_offset           : natural := ex7_ls_t2_ptr_offset       + 4;
constant bp_config_offset               : natural := ex7_ls_t3_ptr_offset       + 4;
constant gshare_mask_offset             : natural := bp_config_offset           + 4;
constant dft_offset                     : natural := gshare_mask_offset         + 4;
constant spare_offset                   : natural := dft_offset                 + 1;
constant scan_right1                    : natural := spare_offset               + 12 - 1;

signal spare_l2                 : std_ulogic_vector(0 to 11);


signal bp_dy_en                 : std_ulogic;
signal bp_st_en                 : std_ulogic;
signal bp_ti_en                 : std_ulogic;
signal bp_gs_en                 : std_ulogic;

signal bp_config_d              : std_ulogic_vector(0 to 3);
signal bp_config_q              : std_ulogic_vector(0 to 3);

signal iu1_bh_ti0gs1_rd_addr    : std_ulogic_vector(0 to 7);
signal iu1_bh_ti1gs1_rd_addr    : std_ulogic_vector(0 to 7);
signal iu1_gshare               : std_ulogic_vector(0 to 3);
signal iu1_tid_enc              : std_ulogic_vector(0 to 1);

signal ex6_bh_ti0gs1_wr_addr    : std_ulogic_vector(0 to 7);
signal ex6_bh_ti1gs1_wr_addr    : std_ulogic_vector(0 to 7);
signal ex6_gshare               : std_ulogic_vector(0 to 3);
signal ex6_tid_enc              : std_ulogic_vector(0 to 1);

signal gshare_act               : std_ulogic_vector(0 to 3);
signal gshare_taken             : std_ulogic_vector(0 to 3);

signal gshare_t0_shift1         : std_ulogic_vector(0 to 4);
signal gshare_t0_shift2         : std_ulogic_vector(0 to 4);
signal gshare_t0_shift3         : std_ulogic_vector(0 to 4);
signal gshare_t0_shift4         : std_ulogic_vector(1 to 4);
signal gshare_t0_shift          : std_ulogic_vector(1 to 4);

signal gshare_t1_shift1         : std_ulogic_vector(0 to 4);
signal gshare_t1_shift2         : std_ulogic_vector(0 to 4);
signal gshare_t1_shift3         : std_ulogic_vector(0 to 4);
signal gshare_t1_shift4         : std_ulogic_vector(1 to 4);
signal gshare_t1_shift          : std_ulogic_vector(1 to 4);

signal gshare_t2_shift1         : std_ulogic_vector(0 to 4);
signal gshare_t2_shift2         : std_ulogic_vector(0 to 4);
signal gshare_t2_shift3         : std_ulogic_vector(0 to 4);
signal gshare_t2_shift4         : std_ulogic_vector(1 to 4);
signal gshare_t2_shift          : std_ulogic_vector(1 to 4);

signal gshare_t3_shift1         : std_ulogic_vector(0 to 4);
signal gshare_t3_shift2         : std_ulogic_vector(0 to 4);
signal gshare_t3_shift3         : std_ulogic_vector(0 to 4);
signal gshare_t3_shift4         : std_ulogic_vector(1 to 4);
signal gshare_t3_shift          : std_ulogic_vector(1 to 4);

signal cp_gshare_act            : std_ulogic_vector(0 to 3);
signal cp_gshare_shift          : std_ulogic_vector(0 to 3);
signal cp_gshare_taken          : std_ulogic;
signal cp_gshare_t0_d           : std_ulogic_vector(0 to 3);
signal cp_gshare_t0_q           : std_ulogic_vector(0 to 3);
signal cp_gshare_t1_d           : std_ulogic_vector(0 to 3);
signal cp_gshare_t1_q           : std_ulogic_vector(0 to 3);
signal cp_gshare_t2_d           : std_ulogic_vector(0 to 3);
signal cp_gshare_t2_q           : std_ulogic_vector(0 to 3);
signal cp_gshare_t3_d           : std_ulogic_vector(0 to 3);
signal cp_gshare_t3_q           : std_ulogic_vector(0 to 3);

signal gshare_t0_d              : std_ulogic_vector(0 to 3);
signal gshare_t0_q              : std_ulogic_vector(0 to 3);
signal gshare_t1_d              : std_ulogic_vector(0 to 3);
signal gshare_t1_q              : std_ulogic_vector(0 to 3);
signal gshare_t2_d              : std_ulogic_vector(0 to 3);
signal gshare_t2_q              : std_ulogic_vector(0 to 3);
signal gshare_t3_d              : std_ulogic_vector(0 to 3);
signal gshare_t3_q              : std_ulogic_vector(0 to 3);

signal gshare_mask_d            : std_ulogic_vector(0 to 3);
signal gshare_mask_q            : std_ulogic_vector(0 to 3);

signal iu2_gshare_d             : std_ulogic_vector(0 to 3);
signal iu2_gshare_q             : std_ulogic_vector(0 to 3);
signal iu3_gshare_d             : std_ulogic_vector(0 to 3);
signal iu3_gshare_q             : std_ulogic_vector(0 to 3);



signal ic_bp_iu1_tid_d          : std_ulogic_vector(0 to 3);
signal ic_bp_iu1_tid_q          : std_ulogic_vector(0 to 3);

signal iu3_0_br_hist            : std_ulogic_vector(0 to 1);
signal iu3_1_br_hist            : std_ulogic_vector(0 to 1);
signal iu3_2_br_hist            : std_ulogic_vector(0 to 1);
signal iu3_3_br_hist            : std_ulogic_vector(0 to 1);

signal iu3_br_val               : std_ulogic_vector(0 to 3);
signal iu3_br_hard              : std_ulogic_vector(0 to 3);
signal iu3_hint_val             : std_ulogic_vector(0 to 3);
signal iu3_hint                 : std_ulogic_vector(0 to 3);
signal iu3_br_hist0             : std_ulogic_vector(0 to 3);
signal iu3_br_hist1             : std_ulogic_vector(0 to 3);

signal iu3_br_update            : std_ulogic_vector(0 to 3);
signal iu3_br_dynamic           : std_ulogic_vector(0 to 3);
signal iu3_br_static            : std_ulogic_vector(0 to 3);
signal iu3_br_pred              : std_ulogic_vector(0 to 3);

signal iu3_instr_pri            : std_ulogic_vector(0 to 31);
signal iu3_instr_val            : std_ulogic_vector(0 to 3);


signal iu4_b_d                  : std_ulogic;
signal iu4_b_q                  : std_ulogic;
signal iu4_bd                   : EFF_IFAR;
signal iu4_li                   : EFF_IFAR;

signal iu3_flush_tid            : std_ulogic_vector(0 to 3);

signal iu4_act                  : std_ulogic;
signal iu4_instr_act            : std_ulogic_vector(0 to 3);

signal iu4_br_update            : std_ulogic_vector(0 to 3);
signal iu4_br_pred              : std_ulogic_vector(0 to 3);

signal iu4_bh_d                 : std_ulogic_vector(0 to 1);
signal iu4_bh_q                 : std_ulogic_vector(0 to 1);
signal iu4_lk_d                 : std_ulogic;
signal iu4_lk_q                 : std_ulogic;
signal iu4_aa_d                 : std_ulogic;
signal iu4_aa_q                 : std_ulogic;


signal iu4_opcode_d             : std_ulogic_vector(0 to 5);
signal iu4_opcode_q             : std_ulogic_vector(0 to 5);
signal iu4_excode_d             : std_ulogic_vector(21 to 30);
signal iu4_excode_q             : std_ulogic_vector(21 to 30);
signal iu4_bclr                 : std_ulogic;
signal iu4_bcctr                : std_ulogic;

signal iu4_bo_d                 : std_ulogic_vector(6 to 10);
signal iu4_bo_q                 : std_ulogic_vector(6 to 10);
signal iu4_bi_d                 : std_ulogic_vector(11 to 15);
signal iu4_bi_q                 : std_ulogic_vector(11 to 15);
signal iu4_getNIA               : std_ulogic;

signal iu4_tar_d                : std_ulogic_vector(6 to 29);
signal iu4_tar_q                : std_ulogic_vector(6 to 29);
signal iu4_abs                  : EFF_IFAR;

signal iu4_ifar_d               : EFF_IFAR;
signal iu4_ifar_q               : EFF_IFAR;
signal iu4_ifar_pri_d           : std_ulogic_vector(60 to 61);
signal iu4_ifar_pri_q           : std_ulogic_vector(60 to 61);

signal iu4_off                  : EFF_IFAR;

signal iu4_bta                  : EFF_IFAR;
signal iu4_lnk                  : EFF_IFAR;

signal iu4_pr_taken_d           : std_ulogic_vector(0 to 3);
signal iu4_pr_taken_q           : std_ulogic_vector(0 to 3);

signal iu4_tid_d                : std_ulogic_vector(0 to 3);
signal iu4_tid_q                : std_ulogic_vector(0 to 3);


signal iu4_t0_val_d             : std_ulogic_vector(0 to 3);
signal iu4_t0_val_q             : std_ulogic_vector(0 to 3);
signal iu4_t1_val_d             : std_ulogic_vector(0 to 3);
signal iu4_t1_val_q             : std_ulogic_vector(0 to 3);
signal iu4_t2_val_d             : std_ulogic_vector(0 to 3);
signal iu4_t2_val_q             : std_ulogic_vector(0 to 3);
signal iu4_t3_val_d             : std_ulogic_vector(0 to 3);
signal iu4_t3_val_q             : std_ulogic_vector(0 to 3);


signal iu4_0_instr_d            : std_ulogic_vector(0 to 43);
signal iu4_0_instr_q            : std_ulogic_vector(32 to 43);
signal iu4_1_instr_d            : std_ulogic_vector(0 to 43);
signal iu4_1_instr_q            : std_ulogic_vector(0 to 43);
signal iu4_2_instr_d            : std_ulogic_vector(0 to 43);
signal iu4_2_instr_q            : std_ulogic_vector(0 to 43);
signal iu4_3_instr_d            : std_ulogic_vector(0 to 43);
signal iu4_3_instr_q            : std_ulogic_vector(0 to 43);

signal iu4_flush_tid            : std_ulogic_vector(0 to 3);
signal iu4_redirect_tid         : std_ulogic_vector(0 to 3);




signal iu5_flush_tid            : std_ulogic_vector(0 to 3);

signal iu5_redirect_ifar_d      : EFF_IFAR;
signal iu5_redirect_ifar_q      : EFF_IFAR;
signal iu5_redirect_tid_d       : std_ulogic_vector(0 to 3);
signal iu5_redirect_tid_q       : std_ulogic_vector(0 to 3);
signal iu5_redirect_act         : std_ulogic;

signal iu5_hold_tid_d           : std_ulogic_vector(0 to 3);
signal iu5_hold_tid_q           : std_ulogic_vector(0 to 3);

signal iu5_act                  : std_ulogic;

signal iu5_ls_push_d            : std_ulogic_vector(0 to 3);
signal iu5_ls_push_q            : std_ulogic_vector(0 to 3);
signal iu5_ls_pop_d             : std_ulogic_vector(0 to 3);
signal iu5_ls_pop_q             : std_ulogic_vector(0 to 3);

signal iu5_ifar_d               : EFF_IFAR;
signal iu5_ifar_q               : EFF_IFAR;

signal ex6_ifar_d               : EFF_IFAR;     
signal ex6_ifar_q               : EFF_IFAR;     
signal ex6_tid_d                : std_ulogic_vector(0 to 3);      
signal ex6_tid_q                : std_ulogic_vector(0 to 3);      
signal ex6_val_d                : std_ulogic;      
signal ex6_val_q                : std_ulogic;      
signal ex6_br_update_d          : std_ulogic;
signal ex6_br_update_q          : std_ulogic;
signal ex6_br_hist_d            : std_ulogic_vector(0 to 1);  
signal ex6_br_hist_q            : std_ulogic_vector(0 to 1);  
signal ex6_br_taken_d           : std_ulogic; 
signal ex6_br_taken_q           : std_ulogic; 
signal ex6_bclr_d               : std_ulogic;     
signal ex6_bclr_q               : std_ulogic;     
signal ex6_getNIA_d             : std_ulogic;       
signal ex6_lk_d                 : std_ulogic;       
signal ex6_lk_q                 : std_ulogic;       
signal ex6_bh_d                 : std_ulogic_vector(0 to 1);       
signal ex6_gshare_d             : std_ulogic_vector(0 to 3);       
signal ex6_gshare_q             : std_ulogic_vector(0 to 3);       

signal ex6_ls_push_d            : std_ulogic_vector(0 to 3);
signal ex6_ls_push_q            : std_ulogic_vector(0 to 3);
signal ex6_ls_pop_d             : std_ulogic_vector(0 to 3);
signal ex6_ls_pop_q             : std_ulogic_vector(0 to 3);

signal ex7_ls_t0_ptr_d          : std_ulogic_vector(0 to 3);
signal ex7_ls_t0_ptr_q          : std_ulogic_vector(0 to 3);
signal ex7_ls_t1_ptr_d          : std_ulogic_vector(0 to 3);
signal ex7_ls_t1_ptr_q          : std_ulogic_vector(0 to 3);
signal ex7_ls_t2_ptr_d          : std_ulogic_vector(0 to 3);
signal ex7_ls_t2_ptr_q          : std_ulogic_vector(0 to 3);
signal ex7_ls_t3_ptr_d          : std_ulogic_vector(0 to 3);
signal ex7_ls_t3_ptr_q          : std_ulogic_vector(0 to 3);
signal ex7_ls_ptr_act           : std_ulogic_vector(0 to 3);

signal ex6_flush_tid_d          : std_ulogic_vector(0 to 3);
signal ex6_flush_tid_q          : std_ulogic_vector(0 to 3);

signal ex6_br_hist_dec          : std_ulogic;
signal ex6_br_hist_inc          : std_ulogic;

signal ex6_flush                : std_ulogic;      
signal ex6_val                  : std_ulogic;      

signal iu6_ls_t0_ptr_d          : std_ulogic_vector(0 to 3);
signal iu6_ls_t0_ptr_q          : std_ulogic_vector(0 to 3);
signal iu6_ls_t1_ptr_d          : std_ulogic_vector(0 to 3);
signal iu6_ls_t1_ptr_q          : std_ulogic_vector(0 to 3);
signal iu6_ls_t2_ptr_d          : std_ulogic_vector(0 to 3);
signal iu6_ls_t2_ptr_q          : std_ulogic_vector(0 to 3);
signal iu6_ls_t3_ptr_d          : std_ulogic_vector(0 to 3);
signal iu6_ls_t3_ptr_q          : std_ulogic_vector(0 to 3);
signal iu6_ls_ptr_act           : std_ulogic_vector(0 to 3);

signal iu5_ls_update            : std_ulogic_vector(0 to 3);
signal ex6_ls_update            : std_ulogic_vector(0 to 3);
signal ex6_repair               : std_ulogic_vector(0 to 3);

signal iu5_nia                  : EFF_IFAR;
signal ex6_nia                  : EFF_IFAR;

signal iu6_ls_t00_d             : EFF_IFAR;
signal iu6_ls_t00_q             : EFF_IFAR;
signal iu6_ls_t01_d             : EFF_IFAR;
signal iu6_ls_t01_q             : EFF_IFAR;
signal iu6_ls_t02_d             : EFF_IFAR;
signal iu6_ls_t02_q             : EFF_IFAR;
signal iu6_ls_t03_d             : EFF_IFAR;
signal iu6_ls_t03_q             : EFF_IFAR;
signal iu6_ls_t0_act            : std_ulogic_vector(0 to 3);

signal iu6_ls_t10_d             : EFF_IFAR;
signal iu6_ls_t10_q             : EFF_IFAR;
signal iu6_ls_t11_d             : EFF_IFAR;
signal iu6_ls_t11_q             : EFF_IFAR;
signal iu6_ls_t12_d             : EFF_IFAR;
signal iu6_ls_t12_q             : EFF_IFAR;
signal iu6_ls_t13_d             : EFF_IFAR;
signal iu6_ls_t13_q             : EFF_IFAR;
signal iu6_ls_t1_act            : std_ulogic_vector(0 to 3);

signal iu6_ls_t20_d             : EFF_IFAR;
signal iu6_ls_t20_q             : EFF_IFAR;
signal iu6_ls_t21_d             : EFF_IFAR;
signal iu6_ls_t21_q             : EFF_IFAR;
signal iu6_ls_t22_d             : EFF_IFAR;
signal iu6_ls_t22_q             : EFF_IFAR;
signal iu6_ls_t23_d             : EFF_IFAR;
signal iu6_ls_t23_q             : EFF_IFAR;
signal iu6_ls_t2_act            : std_ulogic_vector(0 to 3);

signal iu6_ls_t30_d             : EFF_IFAR;
signal iu6_ls_t30_q             : EFF_IFAR;
signal iu6_ls_t31_d             : EFF_IFAR;
signal iu6_ls_t31_q             : EFF_IFAR;
signal iu6_ls_t32_d             : EFF_IFAR;
signal iu6_ls_t32_q             : EFF_IFAR;
signal iu6_ls_t33_d             : EFF_IFAR;
signal iu6_ls_t33_q             : EFF_IFAR;
signal iu6_ls_t3_act            : std_ulogic_vector(0 to 3);

signal tiup                     : std_ulogic;


signal pc_iu_func_sl_thold_1    : std_ulogic;
signal pc_iu_func_sl_thold_0    : std_ulogic;
signal pc_iu_func_sl_thold_0_b  : std_ulogic;
signal pc_iu_sg_1               : std_ulogic;
signal pc_iu_sg_0               : std_ulogic;
signal forcee                    : std_ulogic;

signal dclk                     : std_ulogic;
signal lclk                     : clk_logic;
signal dft_q                    : std_ulogic_vector(0 to 0);

signal siv0                     : std_ulogic_vector(0 to scan_right0);
signal sov0                     : std_ulogic_vector(0 to scan_right0);

signal siv1                     : std_ulogic_vector(0 to scan_right1);
signal sov1                     : std_ulogic_vector(0 to scan_right1);

signal act_dis                          : std_ulogic;
signal d_mode                           : std_ulogic;
signal mpw2_b                           : std_ulogic;


begin


tiup    <= '1';

act_dis <= '0';
d_mode  <= '0';
mpw2_b  <= '1';


bp_config_d(0 to 3)             <= spr_bp_config(0 to 3);

bp_dy_en                        <= bp_config_q(0);    
bp_st_en                        <= bp_config_q(1);    
bp_ti_en                        <= bp_config_q(2);    
bp_gs_en                        <= bp_config_q(3);    


ex6_flush_tid_d                 <= xu_iu_ex5_flush_tid;

ex6_ifar_d                      <= xu_iu_ex5_ifar;
ex6_tid_d                       <= xu_iu_ex5_tid;
ex6_val_d                       <= xu_iu_ex5_val;
ex6_br_update_d                 <= xu_iu_ex5_br_update;                        
ex6_br_hist_d                   <= xu_iu_ex5_br_hist;                        
ex6_br_taken_d                  <= xu_iu_ex5_br_taken;                        
ex6_bclr_d                      <= xu_iu_ex5_bclr;                       
ex6_getNIA_d                    <= xu_iu_ex5_getNIA;
ex6_lk_d                        <= xu_iu_ex5_lk;
ex6_bh_d                        <= xu_iu_ex5_bh;
ex6_gshare_d                    <= xu_iu_ex5_gshare;


iu1_bh_rd_act                   <= ic_bp_iu1_val;



iu1_bh_ti0gs1_rd_addr(0 to 7)   <=                       (ic_bp_iu1_ifar(52 to 55) xor iu1_gshare(0 to 3)) & ic_bp_iu1_ifar(56 to 59);
iu1_bh_ti1gs1_rd_addr(0 to 7)   <= iu1_tid_enc(0 to 1) & (ic_bp_iu1_ifar(54 to 57) xor iu1_gshare(0 to 3)) & ic_bp_iu1_ifar(58 to 59);

iu1_bh_rd_addr(0 to 7)          <= gate(iu1_bh_ti0gs1_rd_addr(0 to 7), bp_ti_en = '0') or
                                   gate(iu1_bh_ti1gs1_rd_addr(0 to 7), bp_ti_en = '1') ;

ic_bp_iu1_tid_d                 <= ic_bp_iu1_tid; 

iu1_gshare(0 to 3)              <= gate(gshare_t0_q(0 to 3), bp_gs_en and ic_bp_iu1_tid_q(0)) or
                                   gate(gshare_t1_q(0 to 3), bp_gs_en and ic_bp_iu1_tid_q(1)) or
                                   gate(gshare_t2_q(0 to 3), bp_gs_en and ic_bp_iu1_tid_q(2)) or
                                   gate(gshare_t3_q(0 to 3), bp_gs_en and ic_bp_iu1_tid_q(3));

iu1_tid_enc(0 to 1)             <= gate("00", ic_bp_iu1_tid_q(0)) or
                                   gate("01", ic_bp_iu1_tid_q(1)) or
                                   gate("10", ic_bp_iu1_tid_q(2)) or
                                   gate("11", ic_bp_iu1_tid_q(3));

iu2_gshare_d(0 to 3)            <= iu1_gshare(0 to 3);
iu3_gshare_d(0 to 3)            <= iu2_gshare_q(0 to 3);




ex6_bh_ti0gs1_wr_addr(0 to 7)   <=                       (ex6_ifar_q(52 to 55) xor ex6_gshare(0 to 3)) & ex6_ifar_q(56 to 59);
ex6_bh_ti1gs1_wr_addr(0 to 7)   <= ex6_tid_enc(0 to 1) & (ex6_ifar_q(54 to 57) xor ex6_gshare(0 to 3)) & ex6_ifar_q(58 to 59);

ex6_bh_wr_addr(0 to 7)          <= gate(ex6_bh_ti0gs1_wr_addr(0 to 7), bp_ti_en = '0') or
                                   gate(ex6_bh_ti1gs1_wr_addr(0 to 7), bp_ti_en = '1') ;


ex6_gshare(0 to 3)              <= ex6_gshare_q(0 to 3);

ex6_tid_enc(0 to 1)             <= gate("00", ex6_tid_q(0)) or
                                   gate("01", ex6_tid_q(1)) or
                                   gate("10", ex6_tid_q(2)) or
                                   gate("11", ex6_tid_q(3));


ex6_flush                       <= or_reduce(ex6_tid_q(0 to 3) and ex6_flush_tid_q(0 to 3));
ex6_val                         <= not ex6_flush;

ex6_br_hist_dec                 <= ex6_val and ex6_val_q = '1' and ex6_br_update_q = '1' and ex6_br_taken_q = '0' and ex6_br_hist_q(0 to 1) /= "00";
ex6_br_hist_inc                 <= ex6_val and ex6_val_q = '1' and ex6_br_update_q = '1' and ex6_br_taken_q = '1' and ex6_br_hist_q(0 to 1) /= "11";

ex6_bh_wr_data(0 to 1)          <= ex6_br_hist_q(0 to 1) + 1 when  ex6_br_taken_q = '1' else
                                   ex6_br_hist_q(0 to 1) - 1;

ex6_bh_wr_act(0)                <= (ex6_br_hist_dec or ex6_br_hist_inc) and ex6_ifar_q(60 to 61) = "00";
ex6_bh_wr_act(1)                <= (ex6_br_hist_dec or ex6_br_hist_inc) and ex6_ifar_q(60 to 61) = "01";
ex6_bh_wr_act(2)                <= (ex6_br_hist_dec or ex6_br_hist_inc) and ex6_ifar_q(60 to 61) = "10";
ex6_bh_wr_act(3)                <= (ex6_br_hist_dec or ex6_br_hist_inc) and ex6_ifar_q(60 to 61) = "11";



gshare_mask_d(0 to 3)           <= spr_bp_gshare_mask(0 to 3);







gshare_t0_shift1(0 to 4)        <= "01000"                        when (iu4_t0_val_q(0) and iu4_br_update(0)) = '1' else "10000";
gshare_t0_shift2(0 to 4)        <= '0' & gshare_t0_shift1(0 to 3) when (iu4_t0_val_q(1) and iu4_br_update(1)) = '1' else gshare_t0_shift1(0 to 4);
gshare_t0_shift3(0 to 4)        <= '0' & gshare_t0_shift2(0 to 3) when (iu4_t0_val_q(2) and iu4_br_update(2)) = '1' else gshare_t0_shift2(0 to 4);
gshare_t0_shift4(1 to 4)        <=       gshare_t0_shift3(0 to 3) when (iu4_t0_val_q(3) and iu4_br_update(3)) = '1' else gshare_t0_shift3(1 to 4);
gshare_t0_shift(1 to 4)         <= gate( gshare_t0_shift4(1 to 4), not iu4_flush_tid(0));

gshare_t1_shift1(0 to 4)        <= "01000"                        when (iu4_t1_val_q(0) and iu4_br_update(0)) = '1' else "10000";
gshare_t1_shift2(0 to 4)        <= '0' & gshare_t1_shift1(0 to 3) when (iu4_t1_val_q(1) and iu4_br_update(1)) = '1' else gshare_t1_shift1(0 to 4);
gshare_t1_shift3(0 to 4)        <= '0' & gshare_t1_shift2(0 to 3) when (iu4_t1_val_q(2) and iu4_br_update(2)) = '1' else gshare_t1_shift2(0 to 4);
gshare_t1_shift4(1 to 4)        <=       gshare_t1_shift3(0 to 3) when (iu4_t1_val_q(3) and iu4_br_update(3)) = '1' else gshare_t1_shift3(1 to 4);
gshare_t1_shift(1 to 4)         <= gate( gshare_t1_shift4(1 to 4), not iu4_flush_tid(1));

gshare_t2_shift1(0 to 4)        <= "01000"                        when (iu4_t2_val_q(0) and iu4_br_update(0)) = '1' else "10000";
gshare_t2_shift2(0 to 4)        <= '0' & gshare_t2_shift1(0 to 3) when (iu4_t2_val_q(1) and iu4_br_update(1)) = '1' else gshare_t2_shift1(0 to 4);
gshare_t2_shift3(0 to 4)        <= '0' & gshare_t2_shift2(0 to 3) when (iu4_t2_val_q(2) and iu4_br_update(2)) = '1' else gshare_t2_shift2(0 to 4);
gshare_t2_shift4(1 to 4)        <=       gshare_t2_shift3(0 to 3) when (iu4_t2_val_q(3) and iu4_br_update(3)) = '1' else gshare_t2_shift3(1 to 4);
gshare_t2_shift(1 to 4)         <= gate( gshare_t2_shift4(1 to 4), not iu4_flush_tid(2));

gshare_t3_shift1(0 to 4)        <= "01000"                        when (iu4_t3_val_q(0) and iu4_br_update(0)) = '1' else "10000";
gshare_t3_shift2(0 to 4)        <= '0' & gshare_t3_shift1(0 to 3) when (iu4_t3_val_q(1) and iu4_br_update(1)) = '1' else gshare_t3_shift1(0 to 4);
gshare_t3_shift3(0 to 4)        <= '0' & gshare_t3_shift2(0 to 3) when (iu4_t3_val_q(2) and iu4_br_update(2)) = '1' else gshare_t3_shift2(0 to 4);
gshare_t3_shift4(1 to 4)        <=       gshare_t3_shift3(0 to 3) when (iu4_t3_val_q(3) and iu4_br_update(3)) = '1' else gshare_t3_shift3(1 to 4);
gshare_t3_shift(1 to 4)         <= gate( gshare_t3_shift4(1 to 4), not iu4_flush_tid(3));

gshare_taken(0)                 <= or_reduce(iu4_t0_val_q(0 to 3) and iu4_br_update(0 to 3) and iu4_br_pred(0 to 3));
gshare_taken(1)                 <= or_reduce(iu4_t1_val_q(0 to 3) and iu4_br_update(0 to 3) and iu4_br_pred(0 to 3));
gshare_taken(2)                 <= or_reduce(iu4_t2_val_q(0 to 3) and iu4_br_update(0 to 3) and iu4_br_pred(0 to 3));
gshare_taken(3)                 <= or_reduce(iu4_t3_val_q(0 to 3) and iu4_br_update(0 to 3) and iu4_br_pred(0 to 3));





gshare_t0_d(0 to 3)             <= cp_gshare_t0_d(0 to 3)                                                   when ex6_repair(0)      = '1' else 
                                   (gshare_taken(0) & "000"                     ) and gshare_mask_q(0 to 3) when gshare_t0_shift(4) = '1' else
                                   (gshare_taken(0) & "00" & gshare_t0_q(0)     ) and gshare_mask_q(0 to 3) when gshare_t0_shift(3) = '1' else
                                   (gshare_taken(0) & '0'  & gshare_t0_q(0 to 1)) and gshare_mask_q(0 to 3) when gshare_t0_shift(2) = '1' else
                                   (gshare_taken(0) &        gshare_t0_q(0 to 2)) and gshare_mask_q(0 to 3) when gshare_t0_shift(1) = '1' else
                                                             gshare_t0_q(0 to 3);

gshare_t1_d(0 to 3)             <= cp_gshare_t1_d(0 to 3)                                                   when ex6_repair(1)      = '1' else 
                                   (gshare_taken(1) & "000"                     ) and gshare_mask_q(0 to 3) when gshare_t1_shift(4) = '1' else
                                   (gshare_taken(1) & "00" & gshare_t1_q(0)     ) and gshare_mask_q(0 to 3) when gshare_t1_shift(3) = '1' else
                                   (gshare_taken(1) & '0'  & gshare_t1_q(0 to 1)) and gshare_mask_q(0 to 3) when gshare_t1_shift(2) = '1' else
                                   (gshare_taken(1) &        gshare_t1_q(0 to 2)) and gshare_mask_q(0 to 3) when gshare_t1_shift(1) = '1' else
                                                             gshare_t1_q(0 to 3);

gshare_t2_d(0 to 3)             <= cp_gshare_t2_d(0 to 3)                                                   when ex6_repair(2)      = '1' else 
                                   (gshare_taken(2) & "000"                     ) and gshare_mask_q(0 to 3) when gshare_t2_shift(4) = '1' else
                                   (gshare_taken(2) & "00" & gshare_t2_q(0)     ) and gshare_mask_q(0 to 3) when gshare_t2_shift(3) = '1' else
                                   (gshare_taken(2) & '0'  & gshare_t2_q(0 to 1)) and gshare_mask_q(0 to 3) when gshare_t2_shift(2) = '1' else
                                   (gshare_taken(2) &        gshare_t2_q(0 to 2)) and gshare_mask_q(0 to 3) when gshare_t2_shift(1) = '1' else
                                                             gshare_t2_q(0 to 3);
gshare_t3_d(0 to 3)             <= cp_gshare_t3_d(0 to 3)                                                   when ex6_repair(3)      = '1' else 
                                   (gshare_taken(3) & "000"                     ) and gshare_mask_q(0 to 3) when gshare_t3_shift(4) = '1' else
                                   (gshare_taken(3) & "00" & gshare_t3_q(0)     ) and gshare_mask_q(0 to 3) when gshare_t3_shift(3) = '1' else
                                   (gshare_taken(3) & '0'  & gshare_t3_q(0 to 1)) and gshare_mask_q(0 to 3) when gshare_t3_shift(2) = '1' else
                                   (gshare_taken(3) &        gshare_t3_q(0 to 2)) and gshare_mask_q(0 to 3) when gshare_t3_shift(1) = '1' else
                                                             gshare_t3_q(0 to 3);


gshare_act(0)                   <= tiup;
gshare_act(1)                   <= tiup;
gshare_act(2)                   <= tiup;
gshare_act(3)                   <= tiup;




cp_gshare_shift(0 to 3)         <= gate(ex6_tid_q(0 to 3) and not ex6_flush_tid_q(0 to 3), ex6_val_q and ex6_br_update_q);
cp_gshare_taken                 <= ex6_br_taken_q;

cp_gshare_t0_d(0 to 3)          <= (cp_gshare_taken & cp_gshare_t0_q(0 to 2)) and gshare_mask_q(0 to 3) when cp_gshare_shift(0) = '1' else
                                    cp_gshare_t0_q(0 to 3);
cp_gshare_t1_d(0 to 3)          <= (cp_gshare_taken & cp_gshare_t1_q(0 to 2)) and gshare_mask_q(0 to 3) when cp_gshare_shift(1) = '1' else
                                    cp_gshare_t1_q(0 to 3);
cp_gshare_t2_d(0 to 3)          <= (cp_gshare_taken & cp_gshare_t2_q(0 to 2)) and gshare_mask_q(0 to 3) when cp_gshare_shift(2) = '1' else
                                    cp_gshare_t2_q(0 to 3);
cp_gshare_t3_d(0 to 3)          <= (cp_gshare_taken & cp_gshare_t3_q(0 to 2)) and gshare_mask_q(0 to 3) when cp_gshare_shift(3) = '1' else
                                    cp_gshare_t3_q(0 to 3);


cp_gshare_act(0 to 3)           <= cp_gshare_shift(0 to 3);






with ic_bp_iu3_ifar(60 to 61) select
iu3_0_br_hist                   <= iu3_3_bh_rd_data(0 to 1) when "11",
                                   iu3_2_bh_rd_data(0 to 1) when "10",
                                   iu3_1_bh_rd_data(0 to 1) when "01",
                                   iu3_0_bh_rd_data(0 to 1) when others;

with ic_bp_iu3_ifar(60 to 61) select
iu3_1_br_hist                   <= iu3_3_bh_rd_data(0 to 1) when "10",
                                   iu3_2_bh_rd_data(0 to 1) when "01",
                                   iu3_1_bh_rd_data(0 to 1) when others;

with ic_bp_iu3_ifar(60 to 61) select
iu3_2_br_hist                   <= iu3_3_bh_rd_data(0 to 1) when "01",
                                   iu3_2_bh_rd_data(0 to 1) when others;

iu3_3_br_hist                   <= iu3_3_bh_rd_data(0 to 1);



iu3_br_val(0 to 3)              <= ic_bp_iu3_0_instr(32) & ic_bp_iu3_1_instr(32) & ic_bp_iu3_2_instr(32) & ic_bp_iu3_3_instr(32);
iu3_br_hard(0 to 3)             <= ic_bp_iu3_0_instr(33) & ic_bp_iu3_1_instr(33) & ic_bp_iu3_2_instr(33) & ic_bp_iu3_3_instr(33);
iu3_hint_val(0 to 3)            <= ic_bp_iu3_0_instr(34) & ic_bp_iu3_1_instr(34) & ic_bp_iu3_2_instr(34) & ic_bp_iu3_3_instr(34);
iu3_hint(0 to 3)                <= ic_bp_iu3_0_instr(35) & ic_bp_iu3_1_instr(35) & ic_bp_iu3_2_instr(35) & ic_bp_iu3_3_instr(35);

iu3_br_hist0(0 to 3)            <= iu3_0_br_hist(0) & iu3_1_br_hist(0) & iu3_2_br_hist(0) & iu3_3_br_hist(0);
iu3_br_hist1(0 to 3)            <= iu3_0_br_hist(1) & iu3_1_br_hist(1) & iu3_2_br_hist(1) & iu3_3_br_hist(1);




iu3_br_dynamic(0 to 3)          <= gate(not(iu3_br_hard(0 to 3) or iu3_hint_val(0 to 3)), bp_dy_en);
iu3_br_static(0 to 3)           <= gate(not(iu3_br_hard(0 to 3) or iu3_hint_val(0 to 3)), bp_st_en and not bp_dy_en);

iu3_br_pred(0 to 3)             <= iu3_br_val(0 to 3) and
                                   (iu3_br_hard(0 to 3) or
                                   (iu3_hint_val(0 to 3) and iu3_hint(0 to 3)) or
                                   (iu3_br_dynamic(0 to 3) and iu3_br_hist0(0 to 3)) or
                                   (iu3_br_static(0 to 3)));

iu3_br_update(0 to 3)           <= iu3_br_val(0 to 3) and iu3_br_dynamic(0 to 3);





iu3_instr_pri(0 to 31)          <= ic_bp_iu3_0_instr(0 to 31)   when iu3_br_pred(0) = '1'       else
                                   ic_bp_iu3_1_instr(0 to 31)   when iu3_br_pred(1) = '1'       else
                                   ic_bp_iu3_2_instr(0 to 31)   when iu3_br_pred(2) = '1'       else
                                   ic_bp_iu3_3_instr(0 to 31);

iu4_b_d                         <= ic_bp_iu3_0_instr(33)        when iu3_br_pred(0) = '1'       else
                                   ic_bp_iu3_1_instr(33)        when iu3_br_pred(1) = '1'       else
                                   ic_bp_iu3_2_instr(33)        when iu3_br_pred(2) = '1'       else
                                   ic_bp_iu3_3_instr(33);

iu4_ifar_pri_d(60 to 61)        <= ic_bp_iu3_ifar(60 to 61)     when iu3_br_pred(0) = '1'       else
                                   ic_bp_iu3_ifar(60 to 61) + 1 when iu3_br_pred(1) = '1'       else
                                   ic_bp_iu3_ifar(60 to 61) + 2 when iu3_br_pred(2) = '1'       else
                                   ic_bp_iu3_ifar(60 to 61) + 3;





iu4_tar_d(6 to 29)              <= iu3_instr_pri(6 to 29);


sign_extend: for i in EFF_IFAR'left to 61 generate
begin
  bd0:if(i < 48) generate begin iu4_bd(i) <= iu4_tar_q(16);         end generate;
  bd1:if(i > 47) generate begin iu4_bd(i) <= iu4_tar_q(i - 32);     end generate;
  li0:if(i < 38) generate begin iu4_li(i) <= iu4_tar_q(6);          end generate;
  li1:if(i > 37) generate begin iu4_li(i) <= iu4_tar_q(i - 32);     end generate;
end generate;

iu4_bh_d(0 to 1)                <= iu3_instr_pri(19 to 20);
iu4_lk_d                        <= iu3_instr_pri(31);
iu4_aa_d                        <= iu3_instr_pri(30);


iu4_opcode_d(0 to 5)            <= iu3_instr_pri(0 to 5);
iu4_excode_d(21 to 30)          <= iu3_instr_pri(21 to 30);

iu4_bclr                        <= (iu4_opcode_q(0 to 5) = "010011" and iu4_excode_q(21 to 30) = "0000010000") or dft_q(0);
iu4_bcctr                       <=  iu4_opcode_q(0 to 5) = "010011" and iu4_excode_q(21 to 30) = "1000010000";

iu4_bo_d( 6 to 10)              <= iu3_instr_pri( 6 to 10);
iu4_bi_d(11 to 15)              <= iu3_instr_pri(11 to 15);

iu4_getNIA                      <= iu4_opcode_q(0 to 5)         = "010000"      and
                                   iu4_bo_q(6 to 10)            = "10100"       and
                                   iu4_bi_q(11 to 15)           = "11111"       and
                                   iu4_bd(EFF_IFAR'left to 61)  = 1             and
                                   iu4_aa_q                     = '0'           and
                                   iu4_lk_q                     = '1'           ;

iu4_pr_taken_d(0)               <= ic_bp_iu3_tid(0) and not iu3_flush_tid(0) and or_reduce(iu3_br_pred(0 to 3) and ic_bp_iu3_val(0 to 3));          
iu4_pr_taken_d(1)               <= ic_bp_iu3_tid(1) and not iu3_flush_tid(1) and or_reduce(iu3_br_pred(0 to 3) and ic_bp_iu3_val(0 to 3));          
iu4_pr_taken_d(2)               <= ic_bp_iu3_tid(2) and not iu3_flush_tid(2) and or_reduce(iu3_br_pred(0 to 3) and ic_bp_iu3_val(0 to 3));          
iu4_pr_taken_d(3)               <= ic_bp_iu3_tid(3) and not iu3_flush_tid(3) and or_reduce(iu3_br_pred(0 to 3) and ic_bp_iu3_val(0 to 3));

  




iu4_abs(EFF_IFAR'left to 61)    <= iu4_li(EFF_IFAR'left to 61) when iu4_b_q = '1' else
                                   iu4_bd(EFF_IFAR'left to 61);

iu4_off(EFF_IFAR'left to 61)    <= iu4_abs(EFF_IFAR'left to 61) + (iu4_ifar_q(EFF_IFAR'left to 59) & iu4_ifar_pri_q(60 to 61));

iu4_bta(EFF_IFAR'left to 61)    <= iu4_abs(EFF_IFAR'left to 61) when iu4_aa_q = '1' else
                                   iu4_off(EFF_IFAR'left to 61);
                    

iu4_act                         <= ic_bp_iu3_val(0);
iu4_instr_act(0 to 3)           <= ic_bp_iu3_val(0 to 3);

iu4_tid_d(0 to 3)               <= ic_bp_iu3_tid(0 to 3);
iu4_ifar_d(EFF_IFAR'left to 61) <= ic_bp_iu3_ifar(EFF_IFAR'left to 61);



iu3_instr_val(0)                <= ic_bp_iu3_val(0);
iu3_instr_val(1)                <= ic_bp_iu3_val(1) and not iu3_br_pred(0);
iu3_instr_val(2)                <= ic_bp_iu3_val(2) and not iu3_br_pred(0) and not iu3_br_pred(1);
iu3_instr_val(3)                <= ic_bp_iu3_val(3) and not iu3_br_pred(0) and not iu3_br_pred(1) and not iu3_br_pred(2);



iu4_t0_val_d(0 to 3)            <= gate(iu3_instr_val(0 to 3), ic_bp_iu3_tid(0) and not iu3_flush_tid(0));
iu4_t1_val_d(0 to 3)            <= gate(iu3_instr_val(0 to 3), ic_bp_iu3_tid(1) and not iu3_flush_tid(1));
iu4_t2_val_d(0 to 3)            <= gate(iu3_instr_val(0 to 3), ic_bp_iu3_tid(2) and not iu3_flush_tid(2));
iu4_t3_val_d(0 to 3)            <= gate(iu3_instr_val(0 to 3), ic_bp_iu3_tid(3) and not iu3_flush_tid(3));


iu4_0_instr_d(0 to 31)          <= ic_bp_iu3_0_instr(0 to 31);
iu4_1_instr_d(0 to 31)          <= ic_bp_iu3_1_instr(0 to 31);
iu4_2_instr_d(0 to 31)          <= ic_bp_iu3_2_instr(0 to 31);
iu4_3_instr_d(0 to 31)          <= ic_bp_iu3_3_instr(0 to 31);

iu4_0_instr_d(32)               <= iu3_br_pred(0);
iu4_1_instr_d(32)               <= iu3_br_pred(1);
iu4_2_instr_d(32)               <= iu3_br_pred(2);
iu4_3_instr_d(32)               <= iu3_br_pred(3);

iu4_0_instr_d(33)               <= iu3_br_hist1(0);
iu4_1_instr_d(33)               <= iu3_br_hist1(1);
iu4_2_instr_d(33)               <= iu3_br_hist1(2);
iu4_3_instr_d(33)               <= iu3_br_hist1(3);

iu4_0_instr_d(34)               <= iu3_br_update(0);
iu4_1_instr_d(34)               <= iu3_br_update(1);
iu4_2_instr_d(34)               <= iu3_br_update(2);
iu4_3_instr_d(34)               <= iu3_br_update(3);

iu4_0_instr_d(35 to 37)         <= ic_bp_iu3_error(0 to 2);
iu4_1_instr_d(35 to 37)         <= ic_bp_iu3_error(0 to 2);
iu4_2_instr_d(35 to 37)         <= ic_bp_iu3_error(0 to 2);
iu4_3_instr_d(35 to 37)         <= ic_bp_iu3_error(0 to 2);

iu4_0_instr_d(38)               <= ic_bp_iu3_2ucode;
iu4_1_instr_d(38)               <= ic_bp_iu3_2ucode;
iu4_2_instr_d(38)               <= ic_bp_iu3_2ucode;
iu4_3_instr_d(38)               <= ic_bp_iu3_2ucode;

iu4_0_instr_d(39)               <= ic_bp_iu3_2ucode_type;
iu4_1_instr_d(39)               <= ic_bp_iu3_2ucode_type;
iu4_2_instr_d(39)               <= ic_bp_iu3_2ucode_type;
iu4_3_instr_d(39)               <= ic_bp_iu3_2ucode_type;

iu4_0_instr_d(40 to 43)         <= iu3_gshare_q(0 to 3);
iu4_1_instr_d(40 to 43)         <= iu3_gshare_q(0 to 3);
iu4_2_instr_d(40 to 43)         <= iu3_gshare_q(0 to 3);
iu4_3_instr_d(40 to 43)         <= iu3_gshare_q(0 to 3);


iu4_br_pred(0 to 3)             <= iu4_0_instr_q(32) & iu4_1_instr_q(32) & iu4_2_instr_q(32) & iu4_3_instr_q(32);
iu4_br_update(0 to 3)           <= iu4_0_instr_q(34) & iu4_1_instr_q(34) & iu4_2_instr_q(34) & iu4_3_instr_q(34);




iu3_flush_tid(0 to 3)           <= xu_iu_iu3_flush_tid(0 to 3) or (0 to 3 => ic_bp_iu3_flush)    or iu4_redirect_tid(0 to 3) or
                                   iu5_redirect_tid_q(0 to 3)  or ib_ic_iu5_redirect_tid(0 to 3) or uc_flush_tid(0 to 3)      ;


iu4_flush_tid(0 to 3)           <= xu_iu_iu4_flush_tid(0 to 3) or iu5_redirect_tid_q(0 to 3) or ib_ic_iu5_redirect_tid(0 to 3) or uc_flush_tid(0 to 3);


iu5_flush_tid(0 to 3)           <= xu_iu_iu5_flush_tid(0 to 3) or ib_ic_iu5_redirect_tid(0 to 3) or uc_flush_tid(0 to 3);




ex6_ls_push_d(0 to 3)   <= gate(ex6_tid_d(0 to 3) and not ex6_flush_tid_d(0 to 3), ex6_val_d and ex6_br_taken_d and not ex6_bclr_d and ex6_lk_d and not ex6_getNIA_d);
ex6_ls_pop_d(0 to 3)    <= gate(ex6_tid_d(0 to 3) and not ex6_flush_tid_d(0 to 3), ex6_val_d and ex6_br_taken_d and     ex6_bclr_d and ex6_bh_d(0 to 1) = "00");

ex7_ls_t0_ptr_d(0 to 3)         <= ex7_ls_t0_ptr_q(3) & ex7_ls_t0_ptr_q(0 to 2) when ex6_ls_push_q(0) = '1' and ex6_ls_pop_q(0) = '0' else
                                   ex7_ls_t0_ptr_q(1 to 3) & ex7_ls_t0_ptr_q(0) when ex6_ls_push_q(0) = '0' and ex6_ls_pop_q(0) = '1' else
                                   ex7_ls_t0_ptr_q(0 to 3); 
ex7_ls_t1_ptr_d(0 to 3)         <= ex7_ls_t1_ptr_q(3) & ex7_ls_t1_ptr_q(0 to 2) when ex6_ls_push_q(1) = '1' and ex6_ls_pop_q(1) = '0' else
                                   ex7_ls_t1_ptr_q(1 to 3) & ex7_ls_t1_ptr_q(0) when ex6_ls_push_q(1) = '0' and ex6_ls_pop_q(1) = '1' else
                                   ex7_ls_t1_ptr_q(0 to 3); 
ex7_ls_t2_ptr_d(0 to 3)         <= ex7_ls_t2_ptr_q(3) & ex7_ls_t2_ptr_q(0 to 2) when ex6_ls_push_q(2) = '1' and ex6_ls_pop_q(2) = '0' else
                                   ex7_ls_t2_ptr_q(1 to 3) & ex7_ls_t2_ptr_q(0) when ex6_ls_push_q(2) = '0' and ex6_ls_pop_q(2) = '1' else
                                   ex7_ls_t2_ptr_q(0 to 3); 
ex7_ls_t3_ptr_d(0 to 3)         <= ex7_ls_t3_ptr_q(3) & ex7_ls_t3_ptr_q(0 to 2) when ex6_ls_push_q(3) = '1' and ex6_ls_pop_q(3) = '0' else
                                   ex7_ls_t3_ptr_q(1 to 3) & ex7_ls_t3_ptr_q(0) when ex6_ls_push_q(3) = '0' and ex6_ls_pop_q(3) = '1' else
                                   ex7_ls_t3_ptr_q(0 to 3);

ex7_ls_ptr_act(0 to 3)          <= ex6_ls_push_q(0 to 3) xor ex6_ls_pop_q(0 to 3);


iu5_ls_push_d(0 to 3)           <= gate(iu4_pr_taken_q(0 to 3) and not iu4_flush_tid(0 to 3), not iu4_bclr and iu4_lk_q and not iu4_getNIA);
iu5_ls_pop_d(0 to 3)            <= gate(iu4_pr_taken_q(0 to 3) and not iu4_flush_tid(0 to 3),     iu4_bclr and iu4_bh_q(0 to 1) = "00");

ex6_repair(0 to 3)              <= gate(ex6_tid_q(0 to 3) and not ex6_flush_tid_q(0 to 3), ex6_val_q and (ex6_br_taken_q xor ex6_br_hist_q(0))) or
                                   ex6_flush_tid_q(0 to 3);


iu6_ls_t0_ptr_d(0 to 3)         <= ex7_ls_t0_ptr_d(0 to 3) when ex6_repair(0) = '1' else 
                                   iu6_ls_t0_ptr_q(3) & iu6_ls_t0_ptr_q(0 to 2) when iu5_ls_push_q(0) = '1' and iu5_ls_pop_q(0) = '0' else
                                   iu6_ls_t0_ptr_q(1 to 3) & iu6_ls_t0_ptr_q(0) when iu5_ls_push_q(0) = '0' and iu5_ls_pop_q(0) = '1' else
                                   iu6_ls_t0_ptr_q(0 to 3); 
iu6_ls_t1_ptr_d(0 to 3)         <= ex7_ls_t1_ptr_d(0 to 3) when ex6_repair(1) = '1' else 
                                   iu6_ls_t1_ptr_q(3) & iu6_ls_t1_ptr_q(0 to 2) when iu5_ls_push_q(1) = '1' and iu5_ls_pop_q(1) = '0' else
                                   iu6_ls_t1_ptr_q(1 to 3) & iu6_ls_t1_ptr_q(0) when iu5_ls_push_q(1) = '0' and iu5_ls_pop_q(1) = '1' else
                                   iu6_ls_t1_ptr_q(0 to 3); 
iu6_ls_t2_ptr_d(0 to 3)         <= ex7_ls_t2_ptr_d(0 to 3) when ex6_repair(2) = '1' else 
                                   iu6_ls_t2_ptr_q(3) & iu6_ls_t2_ptr_q(0 to 2) when iu5_ls_push_q(2) = '1' and iu5_ls_pop_q(2) = '0' else
                                   iu6_ls_t2_ptr_q(1 to 3) & iu6_ls_t2_ptr_q(0) when iu5_ls_push_q(2) = '0' and iu5_ls_pop_q(2) = '1' else
                                   iu6_ls_t2_ptr_q(0 to 3); 
iu6_ls_t3_ptr_d(0 to 3)         <= ex7_ls_t3_ptr_d(0 to 3) when ex6_repair(3) = '1' else 
                                   iu6_ls_t3_ptr_q(3) & iu6_ls_t3_ptr_q(0 to 2) when iu5_ls_push_q(3) = '1' and iu5_ls_pop_q(3) = '0' else
                                   iu6_ls_t3_ptr_q(1 to 3) & iu6_ls_t3_ptr_q(0) when iu5_ls_push_q(3) = '0' and iu5_ls_pop_q(3) = '1' else
                                   iu6_ls_t3_ptr_q(0 to 3);

iu6_ls_ptr_act(0 to 3)          <= ex6_repair(0 to 3) or not ib_ic_iu5_redirect_tid(0 to 3); 


iu5_ls_update(0 to 3)                   <= iu5_ls_push_q(0 to 3) and not ib_ic_iu5_redirect_tid(0 to 3); 
ex6_ls_update(0 to 3)                   <= gate(ex6_ls_push_q(0 to 3), not ex6_br_hist_q(0));

iu5_ifar_d(EFF_IFAR'left to 61)         <= (iu4_ifar_q(EFF_IFAR'left to 59) & iu4_ifar_pri_q(60 to 61));
iu5_act                                 <= or_reduce(iu4_pr_taken_q(0 to 3)) and iu4_lk_q;

iu5_nia(EFF_IFAR'left to 61)            <= iu5_ifar_q(EFF_IFAR'left to 61) + 1;
ex6_nia(EFF_IFAR'left to 61)            <= ex6_ifar_q(EFF_IFAR'left to 61) + 1;


iu6_ls_t00_d(EFF_IFAR'left to 61)       <= ex6_nia(EFF_IFAR'left to 61) when ex6_ls_update(0) = '1' else
                                           iu5_nia(EFF_IFAR'left to 61) when iu5_ls_update(0) = '1' else
                                           iu6_ls_t00_q(EFF_IFAR'left to 61);
iu6_ls_t01_d(EFF_IFAR'left to 61)       <= ex6_nia(EFF_IFAR'left to 61) when ex6_ls_update(0) = '1' else
                                           iu5_nia(EFF_IFAR'left to 61) when iu5_ls_update(0) = '1' else
                                           iu6_ls_t01_q(EFF_IFAR'left to 61);
iu6_ls_t02_d(EFF_IFAR'left to 61)       <= ex6_nia(EFF_IFAR'left to 61) when ex6_ls_update(0) = '1' else
                                           iu5_nia(EFF_IFAR'left to 61) when iu5_ls_update(0) = '1' else
                                           iu6_ls_t02_q(EFF_IFAR'left to 61);
iu6_ls_t03_d(EFF_IFAR'left to 61)       <= ex6_nia(EFF_IFAR'left to 61) when ex6_ls_update(0) = '1' else
                                           iu5_nia(EFF_IFAR'left to 61) when iu5_ls_update(0) = '1' else
                                           iu6_ls_t03_q(EFF_IFAR'left to 61);

iu6_ls_t0_act(0 to 3)                   <= ex7_ls_t0_ptr_d(0 to 3)      when ex6_ls_update(0) = '1' else
                                           iu6_ls_t0_ptr_d(0 to 3)      when iu5_ls_push_q(0) = '1' else
                                            "0000";

iu6_ls_t10_d(EFF_IFAR'left to 61)       <= ex6_nia(EFF_IFAR'left to 61) when ex6_ls_update(1) = '1' else
                                           iu5_nia(EFF_IFAR'left to 61) when iu5_ls_update(1) = '1' else
                                           iu6_ls_t10_q(EFF_IFAR'left to 61);
iu6_ls_t11_d(EFF_IFAR'left to 61)       <= ex6_nia(EFF_IFAR'left to 61) when ex6_ls_update(1) = '1' else
                                           iu5_nia(EFF_IFAR'left to 61) when iu5_ls_update(1) = '1' else
                                           iu6_ls_t11_q(EFF_IFAR'left to 61);
iu6_ls_t12_d(EFF_IFAR'left to 61)       <= ex6_nia(EFF_IFAR'left to 61) when ex6_ls_update(1) = '1' else
                                           iu5_nia(EFF_IFAR'left to 61) when iu5_ls_update(1) = '1' else
                                           iu6_ls_t12_q(EFF_IFAR'left to 61);
iu6_ls_t13_d(EFF_IFAR'left to 61)       <= ex6_nia(EFF_IFAR'left to 61) when ex6_ls_update(1) = '1' else
                                           iu5_nia(EFF_IFAR'left to 61) when iu5_ls_update(1) = '1' else
                                           iu6_ls_t13_q(EFF_IFAR'left to 61);

iu6_ls_t1_act(0 to 3)                   <= ex7_ls_t1_ptr_d(0 to 3)      when ex6_ls_update(1) = '1' else
                                           iu6_ls_t1_ptr_d(0 to 3)      when iu5_ls_push_q(1) = '1' else
                                            "0000";

iu6_ls_t20_d(EFF_IFAR'left to 61)       <= ex6_nia(EFF_IFAR'left to 61) when ex6_ls_update(2) = '1' else
                                           iu5_nia(EFF_IFAR'left to 61) when iu5_ls_update(2) = '1' else
                                           iu6_ls_t20_q(EFF_IFAR'left to 61);
iu6_ls_t21_d(EFF_IFAR'left to 61)       <= ex6_nia(EFF_IFAR'left to 61) when ex6_ls_update(2) = '1' else
                                           iu5_nia(EFF_IFAR'left to 61) when iu5_ls_update(2) = '1' else
                                           iu6_ls_t21_q(EFF_IFAR'left to 61);
iu6_ls_t22_d(EFF_IFAR'left to 61)       <= ex6_nia(EFF_IFAR'left to 61) when ex6_ls_update(2) = '1' else
                                           iu5_nia(EFF_IFAR'left to 61) when iu5_ls_update(2) = '1' else
                                           iu6_ls_t22_q(EFF_IFAR'left to 61);
iu6_ls_t23_d(EFF_IFAR'left to 61)       <= ex6_nia(EFF_IFAR'left to 61) when ex6_ls_update(2) = '1' else
                                           iu5_nia(EFF_IFAR'left to 61) when iu5_ls_update(2) = '1' else
                                           iu6_ls_t23_q(EFF_IFAR'left to 61);

iu6_ls_t2_act(0 to 3)                   <= ex7_ls_t2_ptr_d(0 to 3)      when ex6_ls_update(2) = '1' else
                                           iu6_ls_t2_ptr_d(0 to 3)      when iu5_ls_push_q(2) = '1' else
                                            "0000";

iu6_ls_t30_d(EFF_IFAR'left to 61)       <= ex6_nia(EFF_IFAR'left to 61) when ex6_ls_update(3) = '1' else
                                           iu5_nia(EFF_IFAR'left to 61) when iu5_ls_update(3) = '1' else
                                           iu6_ls_t30_q(EFF_IFAR'left to 61);
iu6_ls_t31_d(EFF_IFAR'left to 61)       <= ex6_nia(EFF_IFAR'left to 61) when ex6_ls_update(3) = '1' else
                                           iu5_nia(EFF_IFAR'left to 61) when iu5_ls_update(3) = '1' else
                                           iu6_ls_t31_q(EFF_IFAR'left to 61);
iu6_ls_t32_d(EFF_IFAR'left to 61)       <= ex6_nia(EFF_IFAR'left to 61) when ex6_ls_update(3) = '1' else
                                           iu5_nia(EFF_IFAR'left to 61) when iu5_ls_update(3) = '1' else
                                           iu6_ls_t32_q(EFF_IFAR'left to 61);
iu6_ls_t33_d(EFF_IFAR'left to 61)       <= ex6_nia(EFF_IFAR'left to 61) when ex6_ls_update(3) = '1' else
                                           iu5_nia(EFF_IFAR'left to 61) when iu5_ls_update(3) = '1' else
                                           iu6_ls_t33_q(EFF_IFAR'left to 61);

iu6_ls_t3_act(0 to 3)                   <= ex7_ls_t3_ptr_d(0 to 3)      when ex6_ls_update(3) = '1' else
                                           iu6_ls_t3_ptr_d(0 to 3)      when iu5_ls_push_q(3) = '1' else
                                            "0000";


iu4_lnk(EFF_IFAR'left to 61)    <= gate(iu6_ls_t00_q(EFF_IFAR'left to 61), iu4_tid_q(0) and iu6_ls_t0_ptr_q(0)) or 
                                   gate(iu6_ls_t01_q(EFF_IFAR'left to 61), iu4_tid_q(0) and iu6_ls_t0_ptr_q(1)) or 
                                   gate(iu6_ls_t02_q(EFF_IFAR'left to 61), iu4_tid_q(0) and iu6_ls_t0_ptr_q(2)) or 
                                   gate(iu6_ls_t03_q(EFF_IFAR'left to 61), iu4_tid_q(0) and iu6_ls_t0_ptr_q(3)) or

                                   gate(iu6_ls_t10_q(EFF_IFAR'left to 61), iu4_tid_q(1) and iu6_ls_t1_ptr_q(0)) or 
                                   gate(iu6_ls_t11_q(EFF_IFAR'left to 61), iu4_tid_q(1) and iu6_ls_t1_ptr_q(1)) or 
                                   gate(iu6_ls_t12_q(EFF_IFAR'left to 61), iu4_tid_q(1) and iu6_ls_t1_ptr_q(2)) or 
                                   gate(iu6_ls_t13_q(EFF_IFAR'left to 61), iu4_tid_q(1) and iu6_ls_t1_ptr_q(3)) or

                                   gate(iu6_ls_t20_q(EFF_IFAR'left to 61), iu4_tid_q(2) and iu6_ls_t2_ptr_q(0)) or 
                                   gate(iu6_ls_t21_q(EFF_IFAR'left to 61), iu4_tid_q(2) and iu6_ls_t2_ptr_q(1)) or 
                                   gate(iu6_ls_t22_q(EFF_IFAR'left to 61), iu4_tid_q(2) and iu6_ls_t2_ptr_q(2)) or 
                                   gate(iu6_ls_t23_q(EFF_IFAR'left to 61), iu4_tid_q(2) and iu6_ls_t2_ptr_q(3)) or

                                   gate(iu6_ls_t30_q(EFF_IFAR'left to 61), iu4_tid_q(3) and iu6_ls_t3_ptr_q(0)) or 
                                   gate(iu6_ls_t31_q(EFF_IFAR'left to 61), iu4_tid_q(3) and iu6_ls_t3_ptr_q(1)) or 
                                   gate(iu6_ls_t32_q(EFF_IFAR'left to 61), iu4_tid_q(3) and iu6_ls_t3_ptr_q(2)) or 
                                   gate(iu6_ls_t33_q(EFF_IFAR'left to 61), iu4_tid_q(3) and iu6_ls_t3_ptr_q(3)) ;







iu5_hold_tid_d(0)               <= '0' when iu5_flush_tid(0) = '1' else
                                   '1' when iu4_pr_taken_q(0) = '1' and not iu4_flush_tid(0) = '1' and iu4_bcctr = '1' else
                                    iu5_hold_tid_q(0);

iu5_hold_tid_d(1)               <= '0' when iu5_flush_tid(1) = '1' else
                                   '1' when iu4_pr_taken_q(1) = '1' and not iu4_flush_tid(1) = '1' and iu4_bcctr = '1' else
                                    iu5_hold_tid_q(1);

iu5_hold_tid_d(2)               <= '0' when iu5_flush_tid(2) = '1' else
                                   '1' when iu4_pr_taken_q(2) = '1' and not iu4_flush_tid(2) = '1' and iu4_bcctr = '1' else
                                    iu5_hold_tid_q(2);

iu5_hold_tid_d(3)               <= '0' when iu5_flush_tid(3) = '1' else
                                   '1' when iu4_pr_taken_q(3) = '1' and not iu4_flush_tid(3) = '1' and iu4_bcctr = '1' else
                                    iu5_hold_tid_q(3);

bp_ic_iu5_hold_tid(0 to 3)      <= iu5_hold_tid_q(0 to 3);


iu5_redirect_act                                <= or_reduce(iu4_redirect_tid(0 to 3));

iu5_redirect_ifar_d(EFF_IFAR'left to 61)        <= iu4_lnk(EFF_IFAR'left to 61) when iu4_bclr = '1' else
                                                   iu4_bta(EFF_IFAR'left to 61);

iu4_redirect_tid(0 to 3)                        <= iu4_pr_taken_q(0 to 3);
iu5_redirect_tid_d(0 to 3)                      <= iu4_redirect_tid(0 to 3) and not iu4_flush_tid(0 to 3);

bp_ic_iu5_redirect_ifar(EFF_IFAR'left to 61)    <= iu5_redirect_ifar_q(EFF_IFAR'left to 61);
bp_ic_iu5_redirect_tid(0 to 3)                  <= iu5_redirect_tid_q(0 to 3);



bp_ib_iu4_ifar(EFF_IFAR'left to 61)     <= iu4_ifar_q(EFF_IFAR'left to 61);

bp_ib_iu4_t0_val(0 to 3)                <= iu4_t0_val_q(0 to 3);
bp_ib_iu4_t1_val(0 to 3)                <= iu4_t1_val_q(0 to 3);
bp_ib_iu4_t2_val(0 to 3)                <= iu4_t2_val_q(0 to 3);
bp_ib_iu4_t3_val(0 to 3)                <= iu4_t3_val_q(0 to 3);

bp_ib_iu3_0_instr(0 to 31)              <= iu4_0_instr_d(0 to 31);
bp_ib_iu4_0_instr(32 to 43)             <= iu4_0_instr_q(32 to 43);
bp_ib_iu4_1_instr(0 to 43)              <= iu4_1_instr_q(0 to 43);
bp_ib_iu4_2_instr(0 to 43)              <= iu4_2_instr_q(0 to 43);
bp_ib_iu4_3_instr(0 to 43)              <= iu4_3_instr_q(0 to 43);


bp_dbg_data0(0 to 7)    <= iu6_ls_t00_q(54 to 61);
bp_dbg_data0(8 to 15)   <= iu6_ls_t01_q(54 to 61);
bp_dbg_data0(16 to 23)  <= iu6_ls_t02_q(54 to 61);
bp_dbg_data0(24 to 31)  <= iu6_ls_t03_q(54 to 61);

bp_dbg_data0(32 to 39)  <= iu6_ls_t10_q(54 to 61);
bp_dbg_data0(40 to 47)  <= iu6_ls_t11_q(54 to 61);
bp_dbg_data0(48 to 55)  <= iu6_ls_t12_q(54 to 61);
bp_dbg_data0(56 to 63)  <= iu6_ls_t13_q(54 to 61);

bp_dbg_data0(64 to 67)  <= iu6_ls_t0_ptr_q;
bp_dbg_data0(68 to 71)  <= iu6_ls_t1_ptr_q;
bp_dbg_data0(72 to 75)  <= ex7_ls_t0_ptr_q;
bp_dbg_data0(76 to 79)  <= ex7_ls_t1_ptr_q;

bp_dbg_data0(80 to 83)  <= ex6_tid_q;
bp_dbg_data0(84)        <= ex6_val_q;
bp_dbg_data0(85)        <= ex6_br_update_q;
bp_dbg_data0(86 to 87)  <= ex6_br_hist_q(0 to 1);

bp_dbg_data1(0 to 7)    <= iu6_ls_t20_q(54 to 61);
bp_dbg_data1(8 to 15)   <= iu6_ls_t21_q(54 to 61);
bp_dbg_data1(16 to 23)  <= iu6_ls_t22_q(54 to 61);
bp_dbg_data1(24 to 31)  <= iu6_ls_t23_q(54 to 61);

bp_dbg_data1(32 to 39)  <= iu6_ls_t30_q(54 to 61);
bp_dbg_data1(40 to 47)  <= iu6_ls_t31_q(54 to 61);
bp_dbg_data1(48 to 55)  <= iu6_ls_t32_q(54 to 61);
bp_dbg_data1(56 to 63)  <= iu6_ls_t33_q(54 to 61);

bp_dbg_data1(64 to 67)  <= iu6_ls_t2_ptr_q;
bp_dbg_data1(68 to 71)  <= iu6_ls_t3_ptr_q;
bp_dbg_data1(72 to 75)  <= ex7_ls_t2_ptr_q;
bp_dbg_data1(76 to 79)  <= ex7_ls_t3_ptr_q;

bp_dbg_data1(80 to 83)  <= ex6_gshare_q(0 to 3);
bp_dbg_data1(84)        <= ex6_br_taken_q;
bp_dbg_data1(85)        <= ex6_bclr_q;
bp_dbg_data1(86)        <= ex6_lk_q;
bp_dbg_data1(87)        <= '0';



ic_bp_iu1_tid_reg: tri_rlmreg_p
  generic map (width => 4, init => 0, expand_type => expand_type) 
  port map (vd          => vdd,
            gd          => gnd,
            nclk        => nclk,
            act         => tiup,
            thold_b     => pc_iu_func_sl_thold_0_b,
            sg          => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin        => siv0(ic_bp_iu1_tid_offset to ic_bp_iu1_tid_offset+3),
            scout       => sov0(ic_bp_iu1_tid_offset to ic_bp_iu1_tid_offset+3),
            din         => ic_bp_iu1_tid_d(0 to 3),
            dout        => ic_bp_iu1_tid_q(0 to 3));

gshare_t0_reg: tri_rlmreg_p
  generic map (width => 4, init => 0, expand_type => expand_type) 
  port map (vd          => vdd,
            gd          => gnd,
            nclk        => nclk,
            act         => gshare_act(0),
            thold_b     => pc_iu_func_sl_thold_0_b,
            sg          => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin        => siv0(gshare_t0_offset to gshare_t0_offset+3),
            scout       => sov0(gshare_t0_offset to gshare_t0_offset+3),
            din         => gshare_t0_d(0 to 3),
            dout        => gshare_t0_q(0 to 3));

gshare_t1_reg: tri_rlmreg_p
  generic map (width => 4, init => 0, expand_type => expand_type) 
  port map (vd          => vdd,
            gd          => gnd,
            nclk        => nclk,
            act         => gshare_act(1),
            thold_b     => pc_iu_func_sl_thold_0_b,
            sg          => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin        => siv0(gshare_t1_offset to gshare_t1_offset+3),
            scout       => sov0(gshare_t1_offset to gshare_t1_offset+3),
            din         => gshare_t1_d(0 to 3),
            dout        => gshare_t1_q(0 to 3));

gshare_t2_reg: tri_rlmreg_p
  generic map (width => 4, init => 0, expand_type => expand_type) 
  port map (vd          => vdd,
            gd          => gnd,
            nclk        => nclk,
            act         => gshare_act(2),
            thold_b     => pc_iu_func_sl_thold_0_b,
            sg          => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin        => siv0(gshare_t2_offset to gshare_t2_offset+3),
            scout       => sov0(gshare_t2_offset to gshare_t2_offset+3),
            din         => gshare_t2_d(0 to 3),
            dout        => gshare_t2_q(0 to 3));

gshare_t3_reg: tri_rlmreg_p
  generic map (width => 4, init => 0, expand_type => expand_type) 
  port map (vd          => vdd,
            gd          => gnd,
            nclk        => nclk,
            act         => gshare_act(3),
            thold_b     => pc_iu_func_sl_thold_0_b,
            sg          => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin        => siv0(gshare_t3_offset to gshare_t3_offset+3),
            scout       => sov0(gshare_t3_offset to gshare_t3_offset+3),
            din         => gshare_t3_d(0 to 3),
            dout        => gshare_t3_q(0 to 3));

cp_gshare_t0_reg: tri_rlmreg_p
  generic map (width => 4, init => 0, expand_type => expand_type) 
  port map (vd          => vdd,
            gd          => gnd,
            nclk        => nclk,
            act         => cp_gshare_act(0),
            thold_b     => pc_iu_func_sl_thold_0_b,
            sg          => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin        => siv0(cp_gshare_t0_offset to cp_gshare_t0_offset+3),
            scout       => sov0(cp_gshare_t0_offset to cp_gshare_t0_offset+3),
            din         => cp_gshare_t0_d(0 to 3),
            dout        => cp_gshare_t0_q(0 to 3));

cp_gshare_t1_reg: tri_rlmreg_p
  generic map (width => 4, init => 0, expand_type => expand_type) 
  port map (vd          => vdd,
            gd          => gnd,
            nclk        => nclk,
            act         => cp_gshare_act(1),
            thold_b     => pc_iu_func_sl_thold_0_b,
            sg          => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin        => siv0(cp_gshare_t1_offset to cp_gshare_t1_offset+3),
            scout       => sov0(cp_gshare_t1_offset to cp_gshare_t1_offset+3),
            din         => cp_gshare_t1_d(0 to 3),
            dout        => cp_gshare_t1_q(0 to 3));

cp_gshare_t2_reg: tri_rlmreg_p
  generic map (width => 4, init => 0, expand_type => expand_type) 
  port map (vd          => vdd,
            gd          => gnd,
            nclk        => nclk,
            act         => cp_gshare_act(2),
            thold_b     => pc_iu_func_sl_thold_0_b,
            sg          => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin        => siv0(cp_gshare_t2_offset to cp_gshare_t2_offset+3),
            scout       => sov0(cp_gshare_t2_offset to cp_gshare_t2_offset+3),
            din         => cp_gshare_t2_d(0 to 3),
            dout        => cp_gshare_t2_q(0 to 3));

cp_gshare_t3_reg: tri_rlmreg_p
  generic map (width => 4, init => 0, expand_type => expand_type) 
  port map (vd          => vdd,
            gd          => gnd,
            nclk        => nclk,
            act         => cp_gshare_act(3),
            thold_b     => pc_iu_func_sl_thold_0_b,
            sg          => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin        => siv0(cp_gshare_t3_offset to cp_gshare_t3_offset+3),
            scout       => sov0(cp_gshare_t3_offset to cp_gshare_t3_offset+3),
            din         => cp_gshare_t3_d(0 to 3),
            dout        => cp_gshare_t3_q(0 to 3));

iu2_gshare_reg: tri_rlmreg_p
  generic map (width => 4, init => 0, expand_type => expand_type) 
  port map (vd          => vdd,
            gd          => gnd,
            nclk        => nclk,
            act         => tiup,
            thold_b     => pc_iu_func_sl_thold_0_b,
            sg          => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin        => siv0(iu2_gshare_offset to iu2_gshare_offset+3),
            scout       => sov0(iu2_gshare_offset to iu2_gshare_offset+3),
            din         => iu2_gshare_d(0 to 3),
            dout        => iu2_gshare_q(0 to 3));

iu3_gshare_reg: tri_rlmreg_p
  generic map (width => 4, init => 0, expand_type => expand_type) 
  port map (vd          => vdd,
            gd          => gnd,
            nclk        => nclk,
            act         => tiup,
            thold_b     => pc_iu_func_sl_thold_0_b,
            sg          => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin        => siv0(iu3_gshare_offset to iu3_gshare_offset+3),
            scout       => sov0(iu3_gshare_offset to iu3_gshare_offset+3),
            din         => iu3_gshare_d(0 to 3),
            dout        => iu3_gshare_q(0 to 3));


iu4_bh_reg: tri_rlmreg_p
  generic map (width => 2, init => 0, expand_type => expand_type) 
  port map (vd          => vdd,
            gd          => gnd,
            nclk        => nclk,
            act         => iu4_act,
            thold_b     => pc_iu_func_sl_thold_0_b,
            sg          => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin        => siv0(iu4_bh_offset to iu4_bh_offset+1),
            scout       => sov0(iu4_bh_offset to iu4_bh_offset+1),
            din         => iu4_bh_d(0 to 1),
            dout        => iu4_bh_q(0 to 1));

iu4_lk_reg: tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type)
  port map (vd          => vdd,
            gd          => gnd,
            nclk        => nclk,
            act         => iu4_act,
            thold_b     => pc_iu_func_sl_thold_0_b,
            sg          => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin        => siv0(iu4_lk_offset),
            scout       => sov0(iu4_lk_offset),
            din         => iu4_lk_d,
            dout        => iu4_lk_q);

iu4_aa_reg: tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type)
  port map (vd          => vdd,
            gd          => gnd,
            nclk        => nclk,
            act         => iu4_act,
            thold_b     => pc_iu_func_sl_thold_0_b,
            sg          => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin        => siv0(iu4_aa_offset),
            scout       => sov0(iu4_aa_offset),
            din         => iu4_aa_d,
            dout        => iu4_aa_q);

iu4_b_reg: tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type)
  port map (vd          => vdd,
            gd          => gnd,
            nclk        => nclk,
            act         => iu4_act,
            thold_b     => pc_iu_func_sl_thold_0_b,
            sg          => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin        => siv0(iu4_b_offset),
            scout       => sov0(iu4_b_offset),
            din         => iu4_b_d,
            dout        => iu4_b_q);


iu4_opcode_reg: tri_rlmreg_p
  generic map (width => 6, init => 0, expand_type => expand_type) 
  port map (vd          => vdd,
            gd          => gnd,
            nclk        => nclk,
            act         => iu4_act,
            thold_b     => pc_iu_func_sl_thold_0_b,
            sg          => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin        => siv0(iu4_opcode_offset to iu4_opcode_offset+5),
            scout       => sov0(iu4_opcode_offset to iu4_opcode_offset+5),
            din         => iu4_opcode_d(0 to 5),
            dout        => iu4_opcode_q(0 to 5));

iu4_excode_reg: tri_rlmreg_p
  generic map (width => 10, init => 0, expand_type => expand_type) 
  port map (vd          => vdd,
            gd          => gnd,
            nclk        => nclk,
            act         => iu4_act,
            thold_b     => pc_iu_func_sl_thold_0_b,
            sg          => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin        => siv0(iu4_excode_offset to iu4_excode_offset+9),
            scout       => sov0(iu4_excode_offset to iu4_excode_offset+9),
            din         => iu4_excode_d(21 to 30),
            dout        => iu4_excode_q(21 to 30));

iu4_bo_reg: tri_rlmreg_p
  generic map (width => 5, init => 0, expand_type => expand_type) 
  port map (vd          => vdd,
            gd          => gnd,
            nclk        => nclk,
            act         => iu4_act,
            thold_b     => pc_iu_func_sl_thold_0_b,
            sg          => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin        => siv0(iu4_bo_offset to iu4_bo_offset+4),
            scout       => sov0(iu4_bo_offset to iu4_bo_offset+4),
            din         => iu4_bo_d(6 to 10),
            dout        => iu4_bo_q(6 to 10));

iu4_bi_reg: tri_rlmreg_p
  generic map (width => 5, init => 0, expand_type => expand_type) 
  port map (vd          => vdd,
            gd          => gnd,
            nclk        => nclk,
            act         => iu4_act,
            thold_b     => pc_iu_func_sl_thold_0_b,
            sg          => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin        => siv0(iu4_bi_offset to iu4_bi_offset+4),
            scout       => sov0(iu4_bi_offset to iu4_bi_offset+4),
            din         => iu4_bi_d(11 to 15),
            dout        => iu4_bi_q(11 to 15));


iu4_tar_reg: tri_rlmreg_p
  generic map (width => 24, init => 0, expand_type => expand_type) 
  port map (vd          => vdd,
            gd          => gnd,
            nclk        => nclk,
            act         => iu4_act,
            thold_b     => pc_iu_func_sl_thold_0_b,
            sg          => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin        => siv0(iu4_tar_offset to iu4_tar_offset+23),
            scout       => sov0(iu4_tar_offset to iu4_tar_offset+23),
            din         => iu4_tar_d(6 to 29),
            dout        => iu4_tar_q(6 to 29));

iu4_ifar_reg: tri_rlmreg_p
  generic map (width => EFF_IFAR'length, init => 0, expand_type => expand_type) 
  port map (vd          => vdd,
            gd          => gnd,
            nclk        => nclk,
            act         => iu4_act,
            thold_b     => pc_iu_func_sl_thold_0_b,
            sg          => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin        => siv0(iu4_ifar_offset to iu4_ifar_offset+EFF_IFAR'length-1),
            scout       => sov0(iu4_ifar_offset to iu4_ifar_offset+EFF_IFAR'length-1),
            din         => iu4_ifar_d(EFF_IFAR'left to 61),
            dout        => iu4_ifar_q(EFF_IFAR'left to 61));

iu4_ifar_pri_reg: tri_rlmreg_p
  generic map (width => 2, init => 0, expand_type => expand_type) 
  port map (vd          => vdd,
            gd          => gnd,
            nclk        => nclk,
            act         => iu4_act,
            thold_b     => pc_iu_func_sl_thold_0_b,
            sg          => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin        => siv0(iu4_ifar_pri_offset to iu4_ifar_pri_offset+1),
            scout       => sov0(iu4_ifar_pri_offset to iu4_ifar_pri_offset+1),
            din         => iu4_ifar_pri_d(60 to 61),
            dout        => iu4_ifar_pri_q(60 to 61));


iu4_pr_taken_reg: tri_rlmreg_p
  generic map (width => 4, init => 0, expand_type => expand_type)
  port map (vd          => vdd,
            gd          => gnd,
            nclk        => nclk,
            act         => tiup,
            thold_b     => pc_iu_func_sl_thold_0_b,
            sg          => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin        => siv0(iu4_pr_taken_offset to iu4_pr_taken_offset+3),
            scout       => sov0(iu4_pr_taken_offset to iu4_pr_taken_offset+3),
            din         => iu4_pr_taken_d(0 to 3),
            dout        => iu4_pr_taken_q(0 to 3));

iu4_tid_reg: tri_rlmreg_p
  generic map (width => 4, init => 0, expand_type => expand_type) 
  port map (vd          => vdd,
            gd          => gnd,
            nclk        => nclk,
            act         => iu4_act,
            thold_b     => pc_iu_func_sl_thold_0_b,
            sg          => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin        => siv0(iu4_tid_offset to iu4_tid_offset+3),
            scout       => sov0(iu4_tid_offset to iu4_tid_offset+3),
            din         => iu4_tid_d(0 to 3),
            dout        => iu4_tid_q(0 to 3));


iu4_t0_val_reg: tri_rlmreg_p
  generic map (width => 4, init => 0, expand_type => expand_type) 
  port map (vd          => vdd,
            gd          => gnd,
            nclk        => nclk,
            act         => tiup,
            thold_b     => pc_iu_func_sl_thold_0_b,
            sg          => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin        => siv0(iu4_t0_val_offset to iu4_t0_val_offset+3),
            scout       => sov0(iu4_t0_val_offset to iu4_t0_val_offset+3),
            din         => iu4_t0_val_d(0 to 3),
            dout        => iu4_t0_val_q(0 to 3));

iu4_t1_val_reg: tri_rlmreg_p
  generic map (width => 4, init => 0, expand_type => expand_type) 
  port map (vd          => vdd,
            gd          => gnd,
            nclk        => nclk,
            act         => tiup,
            thold_b     => pc_iu_func_sl_thold_0_b,
            sg          => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin        => siv0(iu4_t1_val_offset to iu4_t1_val_offset+3),
            scout       => sov0(iu4_t1_val_offset to iu4_t1_val_offset+3),
            din         => iu4_t1_val_d(0 to 3),
            dout        => iu4_t1_val_q(0 to 3));

iu4_t2_val_reg: tri_rlmreg_p
  generic map (width => 4, init => 0, expand_type => expand_type) 
  port map (vd          => vdd,
            gd          => gnd,
            nclk        => nclk,
            act         => tiup,
            thold_b     => pc_iu_func_sl_thold_0_b,
            sg          => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin        => siv0(iu4_t2_val_offset to iu4_t2_val_offset+3),
            scout       => sov0(iu4_t2_val_offset to iu4_t2_val_offset+3),
            din         => iu4_t2_val_d(0 to 3),
            dout        => iu4_t2_val_q(0 to 3));

iu4_t3_val_reg: tri_rlmreg_p
  generic map (width => 4, init => 0, expand_type => expand_type) 
  port map (vd          => vdd,
            gd          => gnd,
            nclk        => nclk,
            act         => tiup,
            thold_b     => pc_iu_func_sl_thold_0_b,
            sg          => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin        => siv0(iu4_t3_val_offset to iu4_t3_val_offset+3),
            scout       => sov0(iu4_t3_val_offset to iu4_t3_val_offset+3),
            din         => iu4_t3_val_d(0 to 3),
            dout        => iu4_t3_val_q(0 to 3));


iu4_0_instr_reg: tri_rlmreg_p
  generic map (width => 12, init => 0, expand_type => expand_type) 
  port map (vd          => vdd,
            gd          => gnd,
            nclk        => nclk,
            act         => iu4_instr_act(0),
            thold_b     => pc_iu_func_sl_thold_0_b,
            sg          => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin        => siv0(iu4_0_instr_offset to iu4_0_instr_offset+11),
            scout       => sov0(iu4_0_instr_offset to iu4_0_instr_offset+11),
            din         => iu4_0_instr_d(32 to 43),
            dout        => iu4_0_instr_q(32 to 43));

iu4_1_instr_reg: tri_rlmreg_p
  generic map (width => 44, init => 0, expand_type => expand_type) 
  port map (vd          => vdd,
            gd          => gnd,
            nclk        => nclk,
            act         => iu4_instr_act(1),
            thold_b     => pc_iu_func_sl_thold_0_b,
            sg          => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin        => siv0(iu4_1_instr_offset to iu4_1_instr_offset+43),
            scout       => sov0(iu4_1_instr_offset to iu4_1_instr_offset+43),
            din         => iu4_1_instr_d(0 to 43),
            dout        => iu4_1_instr_q(0 to 43));

iu4_2_instr_reg: tri_rlmreg_p
  generic map (width => 44, init => 0, expand_type => expand_type) 
  port map (vd          => vdd,
            gd          => gnd,
            nclk        => nclk,
            act         => iu4_instr_act(2),
            thold_b     => pc_iu_func_sl_thold_0_b,
            sg          => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin        => siv0(iu4_2_instr_offset to iu4_2_instr_offset+43),
            scout       => sov0(iu4_2_instr_offset to iu4_2_instr_offset+43),
            din         => iu4_2_instr_d(0 to 43),
            dout        => iu4_2_instr_q(0 to 43));

iu4_3_instr_reg: tri_rlmreg_p
  generic map (width => 44, init => 0, expand_type => expand_type) 
  port map (vd          => vdd,
            gd          => gnd,
            nclk        => nclk,
            act         => iu4_instr_act(3),
            thold_b     => pc_iu_func_sl_thold_0_b,
            sg          => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin        => siv0(iu4_3_instr_offset to iu4_3_instr_offset+43),
            scout       => sov0(iu4_3_instr_offset to iu4_3_instr_offset+43),
            din         => iu4_3_instr_d(0 to 43),
            dout        => iu4_3_instr_q(0 to 43));

iu5_redirect_ifar_reg: tri_rlmreg_p
  generic map (width => EFF_IFAR'length, init => 0, expand_type => expand_type) 
  port map (vd          => vdd,
            gd          => gnd,
            nclk        => nclk,
            act         => iu5_redirect_act,
            thold_b     => pc_iu_func_sl_thold_0_b,
            sg          => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin        => siv0(iu5_redirect_ifar_offset to iu5_redirect_ifar_offset+EFF_IFAR'length-1),
            scout       => sov0(iu5_redirect_ifar_offset to iu5_redirect_ifar_offset+EFF_IFAR'length-1),
            din         => iu5_redirect_ifar_d(EFF_IFAR'left to 61),
            dout        => iu5_redirect_ifar_q(EFF_IFAR'left to 61));

iu5_redirect_tid_reg: tri_rlmreg_p
  generic map (width => 4, init => 0, expand_type => expand_type) 
  port map (vd          => vdd,
            gd          => gnd,
            nclk        => nclk,
            act         => tiup,
            thold_b     => pc_iu_func_sl_thold_0_b,
            sg          => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin        => siv0(iu5_redirect_tid_offset to iu5_redirect_tid_offset+3),
            scout       => sov0(iu5_redirect_tid_offset to iu5_redirect_tid_offset+3),
            din         => iu5_redirect_tid_d(0 to 3),
            dout        => iu5_redirect_tid_q(0 to 3));

iu5_hold_tid_reg: tri_rlmreg_p
  generic map (width => 4, init => 0, expand_type => expand_type) 
  port map (vd          => vdd,
            gd          => gnd,
            nclk        => nclk,
            act         => tiup,
            thold_b     => pc_iu_func_sl_thold_0_b,
            sg          => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin        => siv0(iu5_hold_tid_offset to iu5_hold_tid_offset+3),
            scout       => sov0(iu5_hold_tid_offset to iu5_hold_tid_offset+3),
            din         => iu5_hold_tid_d(0 to 3),
            dout        => iu5_hold_tid_q(0 to 3));


iu5_ls_push_reg: tri_rlmreg_p
  generic map (width => 4, init => 0, expand_type => expand_type) 
  port map (vd          => vdd,
            gd          => gnd,
            nclk        => nclk,
            act         => tiup,
            thold_b     => pc_iu_func_sl_thold_0_b,
            sg          => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin        => siv0(iu5_ls_push_offset to iu5_ls_push_offset+3),
            scout       => sov0(iu5_ls_push_offset to iu5_ls_push_offset+3),
            din         => iu5_ls_push_d(0 to 3),
            dout        => iu5_ls_push_q(0 to 3));

iu5_ls_pop_reg: tri_rlmreg_p
  generic map (width => 4, init => 0, expand_type => expand_type) 
  port map (vd          => vdd,
            gd          => gnd,
            nclk        => nclk,
            act         => tiup,
            thold_b     => pc_iu_func_sl_thold_0_b,
            sg          => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin        => siv0(iu5_ls_pop_offset to iu5_ls_pop_offset+3),
            scout       => sov0(iu5_ls_pop_offset to iu5_ls_pop_offset+3),
            din         => iu5_ls_pop_d(0 to 3),
            dout        => iu5_ls_pop_q(0 to 3));

iu5_ifar_reg: tri_rlmreg_p
  generic map (width => EFF_IFAR'length, init => 0, expand_type => expand_type) 
  port map (vd          => vdd,
            gd          => gnd,
            nclk        => nclk,
            act         => iu5_act,
            thold_b     => pc_iu_func_sl_thold_0_b,
            sg          => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin        => siv0(iu5_ifar_offset to iu5_ifar_offset+EFF_IFAR'length-1),
            scout       => sov0(iu5_ifar_offset to iu5_ifar_offset+EFF_IFAR'length-1),
            din         => iu5_ifar_d(EFF_IFAR'left to 61),
            dout        => iu5_ifar_q(EFF_IFAR'left to 61));

iu6_ls_t0_ptr_reg: tri_rlmreg_p
  generic map (width => 4, init => 8, expand_type => expand_type) 
  port map (vd          => vdd,
            gd          => gnd,
            nclk        => nclk,
            act         => iu6_ls_ptr_act(0),
            thold_b     => pc_iu_func_sl_thold_0_b,
            sg          => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin        => siv1(iu6_ls_t0_ptr_offset to iu6_ls_t0_ptr_offset+3),
            scout       => sov1(iu6_ls_t0_ptr_offset to iu6_ls_t0_ptr_offset+3),
            din         => iu6_ls_t0_ptr_d(0 to 3),
            dout        => iu6_ls_t0_ptr_q(0 to 3));

iu6_ls_t1_ptr_reg: tri_rlmreg_p
  generic map (width => 4, init => 8, expand_type => expand_type) 
  port map (vd          => vdd,
            gd          => gnd,
            nclk        => nclk,
            act         => iu6_ls_ptr_act(1),
            thold_b     => pc_iu_func_sl_thold_0_b,
            sg          => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin        => siv1(iu6_ls_t1_ptr_offset to iu6_ls_t1_ptr_offset+3),
            scout       => sov1(iu6_ls_t1_ptr_offset to iu6_ls_t1_ptr_offset+3),
            din         => iu6_ls_t1_ptr_d(0 to 3),
            dout        => iu6_ls_t1_ptr_q(0 to 3));

iu6_ls_t2_ptr_reg: tri_rlmreg_p
  generic map (width => 4, init => 8, expand_type => expand_type) 
  port map (vd          => vdd,
            gd          => gnd,
            nclk        => nclk,
            act         => iu6_ls_ptr_act(2),
            thold_b     => pc_iu_func_sl_thold_0_b,
            sg          => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin        => siv1(iu6_ls_t2_ptr_offset to iu6_ls_t2_ptr_offset+3),
            scout       => sov1(iu6_ls_t2_ptr_offset to iu6_ls_t2_ptr_offset+3),
            din         => iu6_ls_t2_ptr_d(0 to 3),
            dout        => iu6_ls_t2_ptr_q(0 to 3));

iu6_ls_t3_ptr_reg: tri_rlmreg_p
  generic map (width => 4, init => 8, expand_type => expand_type) 
  port map (vd          => vdd,
            gd          => gnd,
            nclk        => nclk,
            act         => iu6_ls_ptr_act(3),
            thold_b     => pc_iu_func_sl_thold_0_b,
            sg          => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin        => siv1(iu6_ls_t3_ptr_offset to iu6_ls_t3_ptr_offset+3),
            scout       => sov1(iu6_ls_t3_ptr_offset to iu6_ls_t3_ptr_offset+3),
            din         => iu6_ls_t3_ptr_d(0 to 3),
            dout        => iu6_ls_t3_ptr_q(0 to 3));

iu6_ls_t00_reg: tri_rlmreg_p
  generic map (width => EFF_IFAR'length, init => 0, expand_type => expand_type) 
  port map (vd          => vdd,
            gd          => gnd,
            nclk        => nclk,
            act         => iu6_ls_t0_act(0),
            thold_b     => pc_iu_func_sl_thold_0_b,
            sg          => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin        => siv1(iu6_ls_t00_offset to iu6_ls_t00_offset+EFF_IFAR'length-1),
            scout       => sov1(iu6_ls_t00_offset to iu6_ls_t00_offset+EFF_IFAR'length-1),
            din         => iu6_ls_t00_d(EFF_IFAR'left to 61),
            dout        => iu6_ls_t00_q(EFF_IFAR'left to 61));

iu6_ls_t01_reg: tri_rlmreg_p
  generic map (width => EFF_IFAR'length, init => 0, expand_type => expand_type) 
  port map (vd          => vdd,
            gd          => gnd,
            nclk        => nclk,
            act         => iu6_ls_t0_act(1),
            thold_b     => pc_iu_func_sl_thold_0_b,
            sg          => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin        => siv1(iu6_ls_t01_offset to iu6_ls_t01_offset+EFF_IFAR'length-1),
            scout       => sov1(iu6_ls_t01_offset to iu6_ls_t01_offset+EFF_IFAR'length-1),
            din         => iu6_ls_t01_d(EFF_IFAR'left to 61),
            dout        => iu6_ls_t01_q(EFF_IFAR'left to 61));

iu6_ls_t02_reg: tri_rlmreg_p
  generic map (width => EFF_IFAR'length, init => 0, expand_type => expand_type) 
  port map (vd          => vdd,
            gd          => gnd,
            nclk        => nclk,
            act         => iu6_ls_t0_act(2),
            thold_b     => pc_iu_func_sl_thold_0_b,
            sg          => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin        => siv1(iu6_ls_t02_offset to iu6_ls_t02_offset+EFF_IFAR'length-1),
            scout       => sov1(iu6_ls_t02_offset to iu6_ls_t02_offset+EFF_IFAR'length-1),
            din         => iu6_ls_t02_d(EFF_IFAR'left to 61),
            dout        => iu6_ls_t02_q(EFF_IFAR'left to 61));

iu6_ls_t03_reg: tri_rlmreg_p
  generic map (width => EFF_IFAR'length, init => 0, expand_type => expand_type) 
  port map (vd          => vdd,
            gd          => gnd,
            nclk        => nclk,
            act         => iu6_ls_t0_act(3),
            thold_b     => pc_iu_func_sl_thold_0_b,
            sg          => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin        => siv1(iu6_ls_t03_offset to iu6_ls_t03_offset+EFF_IFAR'length-1),
            scout       => sov1(iu6_ls_t03_offset to iu6_ls_t03_offset+EFF_IFAR'length-1),
            din         => iu6_ls_t03_d(EFF_IFAR'left to 61),
            dout        => iu6_ls_t03_q(EFF_IFAR'left to 61));

iu6_ls_t10_reg: tri_rlmreg_p
  generic map (width => EFF_IFAR'length, init => 0, expand_type => expand_type) 
  port map (vd          => vdd,
            gd          => gnd,
            nclk        => nclk,
            act         => iu6_ls_t1_act(0),
            thold_b     => pc_iu_func_sl_thold_0_b,
            sg          => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin        => siv1(iu6_ls_t10_offset to iu6_ls_t10_offset+EFF_IFAR'length-1),
            scout       => sov1(iu6_ls_t10_offset to iu6_ls_t10_offset+EFF_IFAR'length-1),
            din         => iu6_ls_t10_d(EFF_IFAR'left to 61),
            dout        => iu6_ls_t10_q(EFF_IFAR'left to 61));

iu6_ls_t11_reg: tri_rlmreg_p
  generic map (width => EFF_IFAR'length, init => 0, expand_type => expand_type) 
  port map (vd          => vdd,
            gd          => gnd,
            nclk        => nclk,
            act         => iu6_ls_t1_act(1),
            thold_b     => pc_iu_func_sl_thold_0_b,
            sg          => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin        => siv1(iu6_ls_t11_offset to iu6_ls_t11_offset+EFF_IFAR'length-1),
            scout       => sov1(iu6_ls_t11_offset to iu6_ls_t11_offset+EFF_IFAR'length-1),
            din         => iu6_ls_t11_d(EFF_IFAR'left to 61),
            dout        => iu6_ls_t11_q(EFF_IFAR'left to 61));

iu6_ls_t12_reg: tri_rlmreg_p
  generic map (width => EFF_IFAR'length, init => 0, expand_type => expand_type) 
  port map (vd          => vdd,
            gd          => gnd,
            nclk        => nclk,
            act         => iu6_ls_t1_act(2),
            thold_b     => pc_iu_func_sl_thold_0_b,
            sg          => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin        => siv1(iu6_ls_t12_offset to iu6_ls_t12_offset+EFF_IFAR'length-1),
            scout       => sov1(iu6_ls_t12_offset to iu6_ls_t12_offset+EFF_IFAR'length-1),
            din         => iu6_ls_t12_d(EFF_IFAR'left to 61),
            dout        => iu6_ls_t12_q(EFF_IFAR'left to 61));

iu6_ls_t13_reg: tri_rlmreg_p
  generic map (width => EFF_IFAR'length, init => 0, expand_type => expand_type) 
  port map (vd          => vdd,
            gd          => gnd,
            nclk        => nclk,
            act         => iu6_ls_t1_act(3),
            thold_b     => pc_iu_func_sl_thold_0_b,
            sg          => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin        => siv1(iu6_ls_t13_offset to iu6_ls_t13_offset+EFF_IFAR'length-1),
            scout       => sov1(iu6_ls_t13_offset to iu6_ls_t13_offset+EFF_IFAR'length-1),
            din         => iu6_ls_t13_d(EFF_IFAR'left to 61),
            dout        => iu6_ls_t13_q(EFF_IFAR'left to 61));

iu6_ls_t20_reg: tri_rlmreg_p
  generic map (width => EFF_IFAR'length, init => 0, expand_type => expand_type) 
  port map (vd          => vdd,
            gd          => gnd,
            nclk        => nclk,
            act         => iu6_ls_t2_act(0),
            thold_b     => pc_iu_func_sl_thold_0_b,
            sg          => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin        => siv1(iu6_ls_t20_offset to iu6_ls_t20_offset+EFF_IFAR'length-1),
            scout       => sov1(iu6_ls_t20_offset to iu6_ls_t20_offset+EFF_IFAR'length-1),
            din         => iu6_ls_t20_d(EFF_IFAR'left to 61),
            dout        => iu6_ls_t20_q(EFF_IFAR'left to 61));

iu6_ls_t21_reg: tri_rlmreg_p
  generic map (width => EFF_IFAR'length, init => 0, expand_type => expand_type) 
  port map (vd          => vdd,
            gd          => gnd,
            nclk        => nclk,
            act         => iu6_ls_t2_act(1),
            thold_b     => pc_iu_func_sl_thold_0_b,
            sg          => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin        => siv1(iu6_ls_t21_offset to iu6_ls_t21_offset+EFF_IFAR'length-1),
            scout       => sov1(iu6_ls_t21_offset to iu6_ls_t21_offset+EFF_IFAR'length-1),
            din         => iu6_ls_t21_d(EFF_IFAR'left to 61),
            dout        => iu6_ls_t21_q(EFF_IFAR'left to 61));

iu6_ls_t22_reg: tri_rlmreg_p
  generic map (width => EFF_IFAR'length, init => 0, expand_type => expand_type) 
  port map (vd          => vdd,
            gd          => gnd,
            nclk        => nclk,
            act         => iu6_ls_t2_act(2),
            thold_b     => pc_iu_func_sl_thold_0_b,
            sg          => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin        => siv1(iu6_ls_t22_offset to iu6_ls_t22_offset+EFF_IFAR'length-1),
            scout       => sov1(iu6_ls_t22_offset to iu6_ls_t22_offset+EFF_IFAR'length-1),
            din         => iu6_ls_t22_d(EFF_IFAR'left to 61),
            dout        => iu6_ls_t22_q(EFF_IFAR'left to 61));

iu6_ls_t23_reg: tri_rlmreg_p
  generic map (width => EFF_IFAR'length, init => 0, expand_type => expand_type) 
  port map (vd          => vdd,
            gd          => gnd,
            nclk        => nclk,
            act         => iu6_ls_t2_act(3),
            thold_b     => pc_iu_func_sl_thold_0_b,
            sg          => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin        => siv1(iu6_ls_t23_offset to iu6_ls_t23_offset+EFF_IFAR'length-1),
            scout       => sov1(iu6_ls_t23_offset to iu6_ls_t23_offset+EFF_IFAR'length-1),
            din         => iu6_ls_t23_d(EFF_IFAR'left to 61),
            dout        => iu6_ls_t23_q(EFF_IFAR'left to 61));

iu6_ls_t30_reg: tri_rlmreg_p
  generic map (width => EFF_IFAR'length, init => 0, expand_type => expand_type) 
  port map (vd          => vdd,
            gd          => gnd,
            nclk        => nclk,
            act         => iu6_ls_t3_act(0),
            thold_b     => pc_iu_func_sl_thold_0_b,
            sg          => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin        => siv1(iu6_ls_t30_offset to iu6_ls_t30_offset+EFF_IFAR'length-1),
            scout       => sov1(iu6_ls_t30_offset to iu6_ls_t30_offset+EFF_IFAR'length-1),
            din         => iu6_ls_t30_d(EFF_IFAR'left to 61),
            dout        => iu6_ls_t30_q(EFF_IFAR'left to 61));

iu6_ls_t31_reg: tri_rlmreg_p
  generic map (width => EFF_IFAR'length, init => 0, expand_type => expand_type) 
  port map (vd          => vdd,
            gd          => gnd,
            nclk        => nclk,
            act         => iu6_ls_t3_act(1),
            thold_b     => pc_iu_func_sl_thold_0_b,
            sg          => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin        => siv1(iu6_ls_t31_offset to iu6_ls_t31_offset+EFF_IFAR'length-1),
            scout       => sov1(iu6_ls_t31_offset to iu6_ls_t31_offset+EFF_IFAR'length-1),
            din         => iu6_ls_t31_d(EFF_IFAR'left to 61),
            dout        => iu6_ls_t31_q(EFF_IFAR'left to 61));

iu6_ls_t32_reg: tri_rlmreg_p
  generic map (width => EFF_IFAR'length, init => 0, expand_type => expand_type) 
  port map (vd          => vdd,
            gd          => gnd,
            nclk        => nclk,
            act         => iu6_ls_t3_act(2),
            thold_b     => pc_iu_func_sl_thold_0_b,
            sg          => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin        => siv1(iu6_ls_t32_offset to iu6_ls_t32_offset+EFF_IFAR'length-1),
            scout       => sov1(iu6_ls_t32_offset to iu6_ls_t32_offset+EFF_IFAR'length-1),
            din         => iu6_ls_t32_d(EFF_IFAR'left to 61),
            dout        => iu6_ls_t32_q(EFF_IFAR'left to 61));

iu6_ls_t33_reg: tri_rlmreg_p
  generic map (width => EFF_IFAR'length, init => 0, expand_type => expand_type) 
  port map (vd          => vdd,
            gd          => gnd,
            nclk        => nclk,
            act         => iu6_ls_t3_act(3),
            thold_b     => pc_iu_func_sl_thold_0_b,
            sg          => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin        => siv1(iu6_ls_t33_offset to iu6_ls_t33_offset+EFF_IFAR'length-1),
            scout       => sov1(iu6_ls_t33_offset to iu6_ls_t33_offset+EFF_IFAR'length-1),
            din         => iu6_ls_t33_d(EFF_IFAR'left to 61),
            dout        => iu6_ls_t33_q(EFF_IFAR'left to 61));

ex6_val_reg: tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type)
  port map (vd          => vdd,
            gd          => gnd,
            nclk        => nclk,
            act         => tiup,
            thold_b     => pc_iu_func_sl_thold_0_b,
            sg          => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin        => siv1(ex6_val_offset),
            scout       => sov1(ex6_val_offset),
            din         => ex6_val_d,
            dout        => ex6_val_q);

ex6_ifar_reg: tri_rlmreg_p
  generic map (width => EFF_IFAR'length, init => 0, expand_type => expand_type) 
  port map (vd          => vdd,
            gd          => gnd,
            nclk        => nclk,
            act         => ex6_val_d,
            thold_b     => pc_iu_func_sl_thold_0_b,
            sg          => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin        => siv1(ex6_ifar_offset to ex6_ifar_offset+EFF_IFAR'length-1),
            scout       => sov1(ex6_ifar_offset to ex6_ifar_offset+EFF_IFAR'length-1),
            din         => ex6_ifar_d(EFF_IFAR'left to 61),
            dout        => ex6_ifar_q(EFF_IFAR'left to 61));

ex6_tid_reg: tri_rlmreg_p
  generic map (width => 4, init => 0, expand_type => expand_type) 
  port map (vd          => vdd,
            gd          => gnd,
            nclk        => nclk,
            act         => ex6_val_d,
            thold_b     => pc_iu_func_sl_thold_0_b,
            sg          => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin        => siv1(ex6_tid_offset to ex6_tid_offset+3),
            scout       => sov1(ex6_tid_offset to ex6_tid_offset+3),
            din         => ex6_tid_d(0 to 3),
            dout        => ex6_tid_q(0 to 3));

ex6_br_update_reg: tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type)
  port map (vd          => vdd,
            gd          => gnd,
            nclk        => nclk,
            act         => ex6_val_d,
            thold_b     => pc_iu_func_sl_thold_0_b,
            sg          => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin        => siv1(ex6_br_update_offset),
            scout       => sov1(ex6_br_update_offset),
            din         => ex6_br_update_d,
            dout        => ex6_br_update_q);

ex6_br_hist_reg: tri_rlmreg_p
  generic map (width => 2, init => 0, expand_type => expand_type) 
  port map (vd          => vdd,
            gd          => gnd,
            nclk        => nclk,
            act         => ex6_val_d,
            thold_b     => pc_iu_func_sl_thold_0_b,
            sg          => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin        => siv1(ex6_br_hist_offset to ex6_br_hist_offset+1),
            scout       => sov1(ex6_br_hist_offset to ex6_br_hist_offset+1),
            din         => ex6_br_hist_d(0 to 1),
            dout        => ex6_br_hist_q(0 to 1));

ex6_br_taken_reg: tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type)
  port map (vd          => vdd,
            gd          => gnd,
            nclk        => nclk,
            act         => ex6_val_d,
            thold_b     => pc_iu_func_sl_thold_0_b,
            sg          => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin        => siv1(ex6_br_taken_offset),
            scout       => sov1(ex6_br_taken_offset),
            din         => ex6_br_taken_d,
            dout        => ex6_br_taken_q);

ex6_bclr_reg: tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type)
  port map (vd          => vdd,
            gd          => gnd,
            nclk        => nclk,
            act         => ex6_val_d,
            thold_b     => pc_iu_func_sl_thold_0_b,
            sg          => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin        => siv1(ex6_bclr_offset),
            scout       => sov1(ex6_bclr_offset),
            din         => ex6_bclr_d,
            dout        => ex6_bclr_q);


ex6_lk_reg: tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type)
  port map (vd          => vdd,
            gd          => gnd,
            nclk        => nclk,
            act         => ex6_val_d,
            thold_b     => pc_iu_func_sl_thold_0_b,
            sg          => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin        => siv1(ex6_lk_offset),
            scout       => sov1(ex6_lk_offset),
            din         => ex6_lk_d,
            dout        => ex6_lk_q);


ex6_gshare_reg: tri_rlmreg_p
  generic map (width => 4, init => 0, expand_type => expand_type) 
  port map (vd          => vdd,
            gd          => gnd,
            nclk        => nclk,
            act         => ex6_val_d,
            thold_b     => pc_iu_func_sl_thold_0_b,
            sg          => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin        => siv1(ex6_gshare_offset to ex6_gshare_offset+3),
            scout       => sov1(ex6_gshare_offset to ex6_gshare_offset+3),
            din         => ex6_gshare_d(0 to 3),
            dout        => ex6_gshare_q(0 to 3));

ex6_ls_push_reg: tri_rlmreg_p
  generic map (width => 4, init => 0, expand_type => expand_type) 
  port map (vd          => vdd,
            gd          => gnd,
            nclk        => nclk,
            act         => tiup,
            thold_b     => pc_iu_func_sl_thold_0_b,
            sg          => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin        => siv1(ex6_ls_push_offset to ex6_ls_push_offset+3),
            scout       => sov1(ex6_ls_push_offset to ex6_ls_push_offset+3),
            din         => ex6_ls_push_d(0 to 3),
            dout        => ex6_ls_push_q(0 to 3));

ex6_ls_pop_reg: tri_rlmreg_p
  generic map (width => 4, init => 0, expand_type => expand_type) 
  port map (vd          => vdd,
            gd          => gnd,
            nclk        => nclk,
            act         => tiup,
            thold_b     => pc_iu_func_sl_thold_0_b,
            sg          => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin        => siv1(ex6_ls_pop_offset to ex6_ls_pop_offset+3),
            scout       => sov1(ex6_ls_pop_offset to ex6_ls_pop_offset+3),
            din         => ex6_ls_pop_d(0 to 3),
            dout        => ex6_ls_pop_q(0 to 3));

ex6_flush_tid_reg: tri_rlmreg_p
  generic map (width => 4, init => 0, expand_type => expand_type) 
  port map (vd          => vdd,
            gd          => gnd,
            nclk        => nclk,
            act         => tiup,
            thold_b     => pc_iu_func_sl_thold_0_b,
            sg          => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin        => siv1(ex6_flush_tid_offset to ex6_flush_tid_offset+3),
            scout       => sov1(ex6_flush_tid_offset to ex6_flush_tid_offset+3),
            din         => ex6_flush_tid_d(0 to 3),
            dout        => ex6_flush_tid_q(0 to 3));

ex7_ls_t0_ptr_reg: tri_rlmreg_p
  generic map (width => 4, init => 8, expand_type => expand_type) 
  port map (vd          => vdd,
            gd          => gnd,
            nclk        => nclk,
            act         => ex7_ls_ptr_act(0),
            thold_b     => pc_iu_func_sl_thold_0_b,
            sg          => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin        => siv1(ex7_ls_t0_ptr_offset to ex7_ls_t0_ptr_offset+3),
            scout       => sov1(ex7_ls_t0_ptr_offset to ex7_ls_t0_ptr_offset+3),
            din         => ex7_ls_t0_ptr_d(0 to 3),
            dout        => ex7_ls_t0_ptr_q(0 to 3));

ex7_ls_t1_ptr_reg: tri_rlmreg_p
  generic map (width => 4, init => 8, expand_type => expand_type) 
  port map (vd          => vdd,
            gd          => gnd,
            nclk        => nclk,
            act         => ex7_ls_ptr_act(1),
            thold_b     => pc_iu_func_sl_thold_0_b,
            sg          => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin        => siv1(ex7_ls_t1_ptr_offset to ex7_ls_t1_ptr_offset+3),
            scout       => sov1(ex7_ls_t1_ptr_offset to ex7_ls_t1_ptr_offset+3),
            din         => ex7_ls_t1_ptr_d(0 to 3),
            dout        => ex7_ls_t1_ptr_q(0 to 3));

ex7_ls_t2_ptr_reg: tri_rlmreg_p
  generic map (width => 4, init => 8, expand_type => expand_type) 
  port map (vd          => vdd,
            gd          => gnd,
            nclk        => nclk,
            act         => ex7_ls_ptr_act(2),
            thold_b     => pc_iu_func_sl_thold_0_b,
            sg          => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin        => siv1(ex7_ls_t2_ptr_offset to ex7_ls_t2_ptr_offset+3),
            scout       => sov1(ex7_ls_t2_ptr_offset to ex7_ls_t2_ptr_offset+3),
            din         => ex7_ls_t2_ptr_d(0 to 3),
            dout        => ex7_ls_t2_ptr_q(0 to 3));

ex7_ls_t3_ptr_reg: tri_rlmreg_p
  generic map (width => 4, init => 8, expand_type => expand_type) 
  port map (vd          => vdd,
            gd          => gnd,
            nclk        => nclk,
            act         => ex7_ls_ptr_act(3),
            thold_b     => pc_iu_func_sl_thold_0_b,
            sg          => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin        => siv1(ex7_ls_t3_ptr_offset to ex7_ls_t3_ptr_offset+3),
            scout       => sov1(ex7_ls_t3_ptr_offset to ex7_ls_t3_ptr_offset+3),
            din         => ex7_ls_t3_ptr_d(0 to 3),
            dout        => ex7_ls_t3_ptr_q(0 to 3));

bp_config_reg: tri_rlmreg_p
  generic map (width => 4, init => 0, expand_type => expand_type) 
  port map (vd          => vdd,
            gd          => gnd,
            nclk        => nclk,
            act         => tiup,
            thold_b     => pc_iu_func_sl_thold_0_b,
            sg          => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin        => siv1(bp_config_offset to bp_config_offset+3),
            scout       => sov1(bp_config_offset to bp_config_offset+3),
            din         => bp_config_d(0 to 3),
            dout        => bp_config_q(0 to 3));

gshare_mask_reg: tri_rlmreg_p
  generic map (width => 4, init => 0, expand_type => expand_type) 
  port map (vd          => vdd,
            gd          => gnd,
            nclk        => nclk,
            act         => tiup,
            thold_b     => pc_iu_func_sl_thold_0_b,
            sg          => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,

            scin        => siv1(gshare_mask_offset to gshare_mask_offset+3),
            scout       => sov1(gshare_mask_offset to gshare_mask_offset+3),
            din         => gshare_mask_d(0 to 3),
            dout        => gshare_mask_q(0 to 3));

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
            scin    => siv1(spare_offset to spare_offset + spare_l2'length-1),
            scout   => sov1(spare_offset to spare_offset + spare_l2'length-1),
            din     => spare_l2,
            dout    => spare_l2);



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

slat_lcb: tri_lcbs
  generic map (expand_type => expand_type)
  port map (vd          => vdd,
            gd          => gnd, 
            delay_lclkr => delay_lclkr,
            nclk        => nclk,
            forcee => forcee,
            thold_b     => pc_iu_func_sl_thold_0_b,
            dclk        => dclk,
            lclk        => lclk  );

dft_latch: tri_slat_scan
  generic map (width => 1, init => "0", expand_type => expand_type)
  port map (vd          => vdd,
            gd          => gnd, 
            dclk        => dclk,
            lclk        => lclk,
            scan_in     => siv1(dft_offset to dft_offset),
            scan_out    => sov1(dft_offset to dft_offset),
            q           => dft_q,
            q_b         => open);



siv0(0 to scan_right0)  <= scan_in(0) & sov0(0 to scan_right0-1);
scan_out(0)             <= sov0(scan_right0) and an_ac_scan_dis_dc_b;

siv1(0 to scan_right1)  <= scan_in(1) & sov1(0 to scan_right1-1);
scan_out(1)             <= sov1(scan_right1) and an_ac_scan_dis_dc_b;

end iuq_bp;
