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

library ieee,ibm,support,tri,clib,work;
use ieee.std_logic_1164.all;
use ibm.std_ulogic_function_support.all;
use tri.tri_latches_pkg.all;
use support.power_logic_pkg.all;
use work.xuq_pkg.all;

entity xuq_byp_cr is
    generic (
        threads                             : integer := 4;
        expand_type                         : integer := 2;
        regsize                             : integer := 64);
    port (
        nclk                                : in clk_logic;

        vdd                                 : inout power_logic;
        gnd                                 : inout power_logic;

        d_mode_dc                           : in std_ulogic;
        delay_lclkr_dc                      : in std_ulogic;
        mpw1_dc_b                           : in std_ulogic;
        mpw2_dc_b                           : in std_ulogic;
        func_sl_force : in std_ulogic;
        func_sl_thold_0_b                   : in std_ulogic;
        func_nsl_force : in std_ulogic;
        func_nsl_thold_0_b                  : in std_ulogic;
        func_slp_sl_force : in std_ulogic;
        func_slp_sl_thold_0_b               : in std_ulogic;
        sg_0                                : in std_ulogic;
        scan_in                             : in std_ulogic;
        scan_out                            : out std_ulogic;
        
        trace_bus_enable                    : in std_ulogic;

        dec_byp_ex3_val                     : in std_ulogic_vector(0 to threads-1);

        xu_ex3_flush                        : in std_ulogic_vector(0 to threads-1);
        xu_ex4_flush                        : in std_ulogic_vector(0 to threads-1);
        xu_ex5_flush                        : in std_ulogic_vector(0 to threads-1);

        rf1_tid                             : in std_ulogic_vector(0 to threads-1);
        ex1_tid                             : in std_ulogic_vector(0 to threads-1);
        ex2_tid                             : in std_ulogic_vector(0 to threads-1);
        ex3_tid                             : in std_ulogic_vector(0 to threads-1);
        ex5_tid                             : in std_ulogic_vector(0 to threads-1);
        rf1_instr                           : in std_ulogic_vector(6 to 25);

        fxa_fxb_rf0_is_mfocrf               : in std_ulogic;
        dec_byp_rf1_cr_so_update            : in std_ulogic_vector(0 to 1);
        dec_byp_rf1_cr_we                   : in std_ulogic;
        dec_byp_rf1_is_mcrf                 : in std_ulogic;
        dec_byp_rf1_use_crfld0              : in std_ulogic;
        dec_byp_rf1_alu_cmp                 : in std_ulogic;
        dec_byp_rf1_is_mtcrf                : in std_ulogic;
        dec_byp_rf1_is_mtocrf               : in std_ulogic;
        dec_byp_rf1_is_isel                 : in std_ulogic;
        dec_byp_rf1_byp_val                 : in std_ulogic_vector(1 to 3);
        dec_byp_rf0_act                     : in std_ulogic;
        dec_byp_ex4_is_eratsxr              : in std_ulogic;

        dec_byp_ex4_dp_instr                : in std_ulogic;
        dec_byp_ex4_mtdp_val                : in std_ulogic;
        dec_byp_ex4_mfdp_val                : in std_ulogic;
        lsu_xu_ex4_mtdp_cr_status           : in std_ulogic;
        lsu_xu_ex4_mfdp_cr_status           : in std_ulogic;

        dec_byp_ex4_is_wchkall              : in std_ulogic;
        lsu_xu_ex4_cr_upd                   : in std_ulogic;
        lsu_xu_ex5_cr_rslt                  : in std_ulogic;

        byp_cpl_ex1_cr_bit                  : out std_ulogic;
        byp_alu_rf1_isel_fcn                : out std_ulogic_vector(0 to 3);

        alu_byp_ex2_cr_recform              : in std_ulogic_vector(0 to 3);
        alu_byp_ex5_cr_mul                  : in std_ulogic_vector(0 to 4);
        alu_byp_ex3_cr_div                  : in std_ulogic_vector(0 to 4);
        alu_ex2_div_done                    : in std_ulogic;

        fu_xu_ex4_cr_val                    : in std_ulogic_vector(0 to threads-1);
        fu_xu_ex4_cr_noflush                : in std_ulogic_vector(0 to threads-1);
        fu_xu_ex4_cr0                       : in std_ulogic_vector(0 to 3);
        fu_xu_ex4_cr0_bf                    : in std_ulogic_vector(0 to 2);
        fu_xu_ex4_cr1                       : in std_ulogic_vector(0 to 3);
        fu_xu_ex4_cr1_bf                    : in std_ulogic_vector(0 to 2);
        fu_xu_ex4_cr2                       : in std_ulogic_vector(0 to 3);
        fu_xu_ex4_cr2_bf                    : in std_ulogic_vector(0 to 2);
        fu_xu_ex4_cr3                       : in std_ulogic_vector(0 to 3);
        fu_xu_ex4_cr3_bf                    : in std_ulogic_vector(0 to 2);

        mm_xu_cr0_eq_valid                  : in std_ulogic_vector(0 to threads-1);
        mm_xu_cr0_eq                        : in std_ulogic_vector(0 to threads-1);

        an_ac_stcx_complete                 : in std_ulogic_vector(0 to threads-1);
        an_ac_stcx_pass                     : in std_ulogic_vector(0 to threads-1);

        an_ac_back_inv                      : in std_ulogic;
        an_ac_back_inv_addr                 : in std_ulogic_vector(58 to 63);
        an_ac_back_inv_target_bit3          : in std_ulogic;

        byp_ex5_mtcrxer                     : in std_ulogic_vector(32 to 63);
        byp_ex5_tlb_rt                      : in std_ulogic_vector(51 to 51);
        ex5_cr_rt                           : out std_ulogic_vector(32 to 63);
        ex1_mfocrf_rt                       : out std_ulogic_vector(64-regsize to 63);

        dec_cr_ex5_instr                    : in std_ulogic_vector(12 to 19);
        
        byp_perf_tx_events                  : out std_ulogic_vector(0 to 3*threads-1);

        byp_xer_so                          : in std_ulogic_vector(0 to threads-1);
        xer_cr_ex1_xer_ov_in_pipe           : in std_ulogic;
        xer_cr_ex2_xer_ov_in_pipe           : in std_ulogic;
        xer_cr_ex3_xer_ov_in_pipe           : in std_ulogic;
        xer_cr_ex5_xer_ov_in_pipe           : in std_ulogic;
        
        cr_grp0_debug                       : out std_ulogic_vector(0 to 87);
        cr_grp1_debug                       : out std_ulogic_vector(0 to 87)
    );

-- synopsys translate_off

-- synopsys translate_on
end xuq_byp_cr;
architecture xuq_byp_cr of xuq_byp_cr is
    constant tiup                                       : std_ulogic := '1';
    constant tidn                                       : std_ulogic := '0';
    type CR_ARY                                         is array (0 to threads-1) of std_ulogic_vector(0 to 7);
    subtype s2                                          is std_ulogic_vector(0 to 1);
    subtype s5                                          is std_ulogic_vector(0 to 4);

   signal rf1_is_mfocrf_q                                        : std_ulogic;                               
   signal ex1_alu_cmp_q                                          : std_ulogic;                               
   signal ex1_any_mtcrf_q,           ex1_any_mtcrf_d             : std_ulogic;                               
   signal ex1_cr0_q                                              : std_ulogic_vector(0 to 3);                
   signal ex1_cr0_bit_q,             rf1_cr0_bit                 : std_ulogic;                               
   signal ex1_cr1_q                                              : std_ulogic_vector(0 to 3);                
   signal ex1_cr1_bit_q,             rf1_cr1_bit_i               : std_ulogic;                               
   signal ex1_cr_so_update_q                                     : std_ulogic_vector(0 to 1);                
   signal ex1_cr_we_q                                            : std_ulogic;                               
   signal ex1_crt_q,                 rf1_crt                     : std_ulogic_vector(0 to 3);                
   signal ex1_crt_mask_q,            rf1_crt_mask                : std_ulogic_vector(0 to 3);                
   signal ex1_instr_q                                            : std_ulogic_vector(6 to 19);               
   signal ex1_instr_2_q                                          : std_ulogic_vector(22 to 25);              
   signal ex1_is_mcrf_q                                          : std_ulogic;                               
   signal ex1_use_crfld0_q                                       : std_ulogic;                               
   signal ex2_alu_cmp_q                                          : std_ulogic;                               
   signal ex2_any_mtcrf_q                                        : std_ulogic;                               
   signal ex2_cr_q                                               : std_ulogic_vector(0 to 7);                
   signal ex2_cr_we_q                                            : std_ulogic;                               
   signal ex2_instr_q                                            : std_ulogic_vector(6 to 8);                
   signal ex2_use_crfld0_q                                       : std_ulogic;                               
   signal ex3_any_mtcrf_q                                        : std_ulogic;                               
   signal ex3_cr_q                                               : std_ulogic_vector(0 to 7);                
   signal ex3_div_done_q                                         : std_ulogic;                               
   signal ex3_instr_q                                            : std_ulogic_vector(6 to 8);                
   signal ex4_any_mtcrf_q                                        : std_ulogic;                               
   signal ex4_cr_q                                               : std_ulogic_vector(0 to 7);                
   signal ex4_instr_q                                            : std_ulogic_vector(6 to 8);                
   signal ex4_val_q,                 ex3_val                     : std_ulogic_vector(0 to threads-1);        
   signal ex5_any_mtcrf_q                                        : std_ulogic;                               
   signal ex5_axu_val_q,             ex4_axu_val                 : std_ulogic_vector(0 to threads-1);        
   signal ex5_cr_q                                               : std_ulogic_vector(0 to 7);                
   signal ex5_dp_instr_q                                         : std_ulogic;                               
   signal ex5_fu_cr0_q                                           : std_ulogic_vector(0 to 3);                
   signal ex5_fu_cr0_bf_q                                        : std_ulogic_vector(0 to 2);                
   signal ex5_fu_cr1_q                                           : std_ulogic_vector(0 to 3);                
   signal ex5_fu_cr1_bf_q                                        : std_ulogic_vector(0 to 2);                
   signal ex5_fu_cr2_q                                           : std_ulogic_vector(0 to 3);                
   signal ex5_fu_cr2_bf_q                                        : std_ulogic_vector(0 to 2);                
   signal ex5_fu_cr3_q                                           : std_ulogic_vector(0 to 3);                
   signal ex5_fu_cr3_bf_q                                        : std_ulogic_vector(0 to 2);                
   signal ex5_fu_cr_noflush_q                                    : std_ulogic_vector(0 to threads-1);        
   signal ex5_fu_cr_val_q                                        : std_ulogic_vector(0 to threads-1);        
   signal ex5_is_eratsxr_q                                       : std_ulogic;                               
   signal ex5_mfdp_cr_status_q                                   : std_ulogic;                               
   signal ex5_mfdp_val_q                                         : std_ulogic;                               
   signal ex5_mtdp_cr_status_q                                   : std_ulogic;                               
   signal ex5_mtdp_val_q                                         : std_ulogic;                               
   signal ex5_val_q,                 ex4_val                     : std_ulogic_vector(0 to threads-1);        
   signal ex5_watch_we_q,            ex5_watch_we_d              : std_ulogic;                               
   signal ex5_wchkall_fld_q,         ex5_wchkall_fld_d           : std_ulogic_vector(0 to 2);                
   signal an_ac_back_inv_q                                       : std_ulogic;                               
   signal an_ac_back_inv_addr_q                                  : std_ulogic_vector(58 to 63);              
   signal an_ac_back_inv_target_bit3_q                           : std_ulogic;                               
   signal back_inv_val_q,            back_inv_val_d              : std_ulogic;                               
   signal cr_barrier_we_q,           cr_barrier_we_d             : std_ulogic_vector(0 to threads-1);        
   signal exx_act_q,                 exx_act_d                   : std_ulogic_vector(0 to 4);                
   signal mmu_cr0_eq_q                                           : std_ulogic_vector(0 to threads-1);        
   signal mmu_cr0_eq_valid_q                                     : std_ulogic_vector(0 to threads-1);        
   signal stcx_complete_q                                        : std_ulogic_vector(0 to threads-1);        
   signal stcx_pass_q                                            : std_ulogic_vector(0 to threads-1);        
   signal ex1_cr0_byp_pri_dbg_q                                  : std_ulogic_vector(1 to 6);                
   signal ex1_cr1_byp_pri_dbg_q                                  : std_ulogic_vector(1 to 6);                
   signal ex1_crt_byp_pri_dbg_q                                  : std_ulogic_vector(1 to 6);                
   signal ex6_val_dbg_q                                          : std_ulogic_vector(0 to threads-1);        

   constant ex1_alu_cmp_offset                        : integer := 0;
   constant ex1_any_mtcrf_offset                      : integer := ex1_alu_cmp_offset             + 1;
   constant ex1_cr0_offset                            : integer := ex1_any_mtcrf_offset           + 1;
   constant ex1_cr0_bit_offset                        : integer := ex1_cr0_offset                 + ex1_cr0_q'length;
   constant ex1_cr1_offset                            : integer := ex1_cr0_bit_offset             + 1;
   constant ex1_cr1_bit_offset                        : integer := ex1_cr1_offset                 + ex1_cr1_q'length;
   constant ex1_cr_so_update_offset                   : integer := ex1_cr1_bit_offset             + 1;
   constant ex1_cr_we_offset                          : integer := ex1_cr_so_update_offset        + ex1_cr_so_update_q'length;
   constant ex1_crt_offset                            : integer := ex1_cr_we_offset               + 1;
   constant ex1_crt_mask_offset                       : integer := ex1_crt_offset                 + ex1_crt_q'length;
   constant ex1_instr_offset                          : integer := ex1_crt_mask_offset            + ex1_crt_mask_q'length;
   constant ex1_instr_2_offset                        : integer := ex1_instr_offset               + ex1_instr_q'length;
   constant ex1_is_mcrf_offset                        : integer := ex1_instr_2_offset             + ex1_instr_2_q'length;
   constant ex1_use_crfld0_offset                     : integer := ex1_is_mcrf_offset             + 1;
   constant ex3_any_mtcrf_offset                      : integer := ex1_use_crfld0_offset          + 1;
   constant ex3_cr_offset                             : integer := ex3_any_mtcrf_offset           + 1;
   constant ex3_div_done_offset                       : integer := ex3_cr_offset                  + ex3_cr_q'length;
   constant ex3_instr_offset                          : integer := ex3_div_done_offset            + 1;
   constant ex5_any_mtcrf_offset                      : integer := ex3_instr_offset               + ex3_instr_q'length;
   constant ex5_axu_val_offset                        : integer := ex5_any_mtcrf_offset           + 1;
   constant ex5_cr_offset                             : integer := ex5_axu_val_offset             + ex5_axu_val_q'length;
   constant ex5_dp_instr_offset                       : integer := ex5_cr_offset                  + ex5_cr_q'length;
   constant ex5_fu_cr0_offset                         : integer := ex5_dp_instr_offset            + 1;
   constant ex5_fu_cr0_bf_offset                      : integer := ex5_fu_cr0_offset              + ex5_fu_cr0_q'length;
   constant ex5_fu_cr1_offset                         : integer := ex5_fu_cr0_bf_offset           + ex5_fu_cr0_bf_q'length;
   constant ex5_fu_cr1_bf_offset                      : integer := ex5_fu_cr1_offset              + ex5_fu_cr1_q'length;
   constant ex5_fu_cr2_offset                         : integer := ex5_fu_cr1_bf_offset           + ex5_fu_cr1_bf_q'length;
   constant ex5_fu_cr2_bf_offset                      : integer := ex5_fu_cr2_offset              + ex5_fu_cr2_q'length;
   constant ex5_fu_cr3_offset                         : integer := ex5_fu_cr2_bf_offset           + ex5_fu_cr2_bf_q'length;
   constant ex5_fu_cr3_bf_offset                      : integer := ex5_fu_cr3_offset              + ex5_fu_cr3_q'length;
   constant ex5_fu_cr_noflush_offset                  : integer := ex5_fu_cr3_bf_offset           + ex5_fu_cr3_bf_q'length;
   constant ex5_fu_cr_val_offset                      : integer := ex5_fu_cr_noflush_offset       + ex5_fu_cr_noflush_q'length;
   constant ex5_is_eratsxr_offset                     : integer := ex5_fu_cr_val_offset           + ex5_fu_cr_val_q'length;
   constant ex5_mfdp_cr_status_offset                 : integer := ex5_is_eratsxr_offset          + 1;
   constant ex5_mfdp_val_offset                       : integer := ex5_mfdp_cr_status_offset      + 1;
   constant ex5_mtdp_cr_status_offset                 : integer := ex5_mfdp_val_offset            + 1;
   constant ex5_mtdp_val_offset                       : integer := ex5_mtdp_cr_status_offset      + 1;
   constant ex5_val_offset                            : integer := ex5_mtdp_val_offset            + 1;
   constant ex5_watch_we_offset                       : integer := ex5_val_offset                 + ex5_val_q'length;
   constant ex5_wchkall_fld_offset                    : integer := ex5_watch_we_offset            + 1;
   constant an_ac_back_inv_offset                     : integer := ex5_wchkall_fld_offset         + ex5_wchkall_fld_q'length;
   constant an_ac_back_inv_addr_offset                : integer := an_ac_back_inv_offset          + 1;
   constant an_ac_back_inv_target_bit3_offset         : integer := an_ac_back_inv_addr_offset     + an_ac_back_inv_addr_q'length;
   constant back_inv_val_offset                       : integer := an_ac_back_inv_target_bit3_offset + 1;
   constant cr_barrier_we_offset                      : integer := back_inv_val_offset            + 1;
   constant exx_act_offset                            : integer := cr_barrier_we_offset           + cr_barrier_we_q'length;
   constant mmu_cr0_eq_offset                         : integer := exx_act_offset                 + exx_act_q'length;
   constant mmu_cr0_eq_valid_offset                   : integer := mmu_cr0_eq_offset              + mmu_cr0_eq_q'length;
   constant stcx_complete_offset                      : integer := mmu_cr0_eq_valid_offset        + mmu_cr0_eq_valid_q'length;
   constant stcx_pass_offset                          : integer := stcx_complete_offset           + stcx_complete_q'length;
   constant ex1_cr0_byp_pri_dbg_offset                : integer := stcx_pass_offset               + stcx_pass_q'length;
   constant ex1_cr1_byp_pri_dbg_offset                : integer := ex1_cr0_byp_pri_dbg_offset     + ex1_cr0_byp_pri_dbg_q'length;
   constant ex1_crt_byp_pri_dbg_offset                : integer := ex1_cr1_byp_pri_dbg_offset     + ex1_cr1_byp_pri_dbg_q'length;
   constant ex6_val_dbg_offset                        : integer := ex1_crt_byp_pri_dbg_offset     + ex1_crt_byp_pri_dbg_q'length;
   constant cr_barrier_offset                         : integer := ex6_val_dbg_offset             + ex6_val_dbg_q'length;
   constant cr_offset                                 : integer := cr_barrier_offset              + 4*threads;
   constant scan_right                                : integer := cr_offset                      + 32*threads;
    signal siv                                          : std_ulogic_vector(0 to scan_right-1);
    signal sov                                          : std_ulogic_vector(0 to scan_right-1);
    signal rf1_cr0                                      : std_ulogic_vector(0 to 3);
    signal rf1_cr1                                      : std_ulogic_vector(0 to 3);
    signal rf1_cr0_cmp,     rf1_cr1_cmp                 : std_ulogic_vector(1 to 5);
    signal rf1_cr0_byp_pri, rf1_cr1_byp_pri             : std_ulogic_vector(1 to 6);
    signal rf1_crt_cmp                                  : std_ulogic_vector(1 to 5);
    signal rf1_crt_byp_pri                              : std_ulogic_vector(1 to 6);
    signal rf1_cr1_val                                  : std_ulogic_vector(1 to 5);
    signal rf1_cr0_val                                  : std_ulogic_vector(1 to 5);
    signal rf1_crt_val                                  : std_ulogic_vector(1 to 5);
    signal rf1_byp_val                                  : std_ulogic_vector(1 to 5);
    signal rf1_axu_byp_val                              : std_ulogic_vector(4 to 5);
    signal rf1_isel_fcn                                 : std_ulogic_vector(0 to 3);
    signal ex1_xer_so                                   : std_ulogic;
    signal ex2_xer_so                                   : std_ulogic;
    signal ex3_xer_so                                   : std_ulogic;
    signal ex5_xer_so                                   : std_ulogic;
    signal ex1_cr_so                                    : std_ulogic;
    signal ex2_cr_recform                               : std_ulogic_vector(0 to 7);
    signal ex3_cr_div                                   : std_ulogic_vector(0 to 7);
    signal ex5_cr_mul                                   : std_ulogic_vector(0 to 7);
    signal ex5_cr_dp                                    : std_ulogic_vector(0 to 7);
    signal ex1_cr                                       : std_ulogic_vector(0 to 7);
    signal ex3_cr                                       : std_ulogic_vector(0 to 7);
    signal ex2_cr                                       : std_ulogic_vector(0 to 7);
    signal ex4_cr                                       : std_ulogic_vector(0 to 7);
    signal ex5_cr, ex5_cr_fu                            : std_ulogic_vector(0 to 7);
    signal ex5_val, ex5_axu_val                         : std_ulogic_vector(0 to threads-1);
    signal cr_out                                       : std_ulogic_vector(0 to 32*threads-1);
    signal cr_mux                                       : std_ulogic_vector(0 to 31);
    signal cr0_out,         cr1_out                     : std_ulogic_vector(0 to 3);
    signal crt_out                                      : std_ulogic_vector(0 to 3);
    signal ex1_cr_mcrf                                  : std_ulogic_vector(0 to 7);
    signal ex1_cr_not_mcrf                              : std_ulogic_vector(0 to 7);
    signal rf1_mfocrf_src                               : std_ulogic_vector(0 to 2);
    signal rf1_cr0_source                               : std_ulogic_vector(0 to 2);
    signal rf1_cr1_source                               : std_ulogic_vector(0 to 4);
    signal icswx_tid                                    : std_ulogic_vector(0 to threads-1);
    signal ex5_eratsxr_we                               : std_ulogic_vector(0 to threads-1);
    signal ex5_cr_we                                    : std_ulogic_vector(0 to threads-1);    
    signal ex5_cr_act                                   : std_ulogic_vector(0 to threads-1);    
    signal ex1_log_cr_bit                               : std_ulogic;
    signal ex1_log_cr                                   : std_ulogic_vector(0 to 3);
    signal ex5_fu_cr                                    : CR_ARY;
    signal ex5_fu_cr_val                                : std_ulogic_vector(0 to threads-1);
    signal ex5_cr_watch                                 : std_ulogic_vector(0 to 7);   
    signal ex5_cr_instr                                 : std_ulogic_vector(0 to 7);   
    signal ex5_cr_instr_update_b                        : std_ulogic;
    signal ex5_instr_cr_dec                             : std_ulogic_vector(0 to 7);
    signal ex5_fu_cr_valid                              : std_ulogic;
    signal ex5_instr_cr_val                             : std_ulogic_vector(0 to threads-1);
    signal ex5_mtcr_val                                 : std_ulogic_vector(0 to threads-1);
    signal ex5_icswx_we                                 : std_ulogic_vector(0 to threads-1);
    signal cr_grp0_debug_int                            : std_ulogic_vector(0 to 87);
    signal exx_act                                      : std_ulogic_vector(0 to 4);
    signal ex4_axu_act                                  : std_ulogic;
    
begin

    exx_act_d           <= dec_byp_rf0_act & exx_act_q(0 to 3);

    exx_act(0)          <= exx_act_q(0);
    exx_act(1)          <= exx_act_q(1);
    exx_act(2)          <= exx_act_q(2);
    exx_act(3)          <= exx_act_q(3);
    exx_act(4)          <= exx_act_q(4);
    
    ex4_axu_act         <= '1';  

    ex1_any_mtcrf_d     <= (dec_byp_rf1_is_mtcrf or dec_byp_rf1_is_mtocrf);

    ex3_val             <= dec_byp_ex3_val   and not  xu_ex3_flush;
    ex4_val             <= ex4_val_q         and not  xu_ex4_flush;
    ex5_val             <= ex5_val_q         and not  xu_ex5_flush;

    ex4_axu_val         <= fu_xu_ex4_cr_val  and not (xu_ex4_flush and not fu_xu_ex4_cr_noflush);
    ex5_axu_val         <= ex5_axu_val_q     and not (xu_ex5_flush and not ex5_fu_cr_noflush_q);


    ex1_xer_so          <= or_reduce(byp_xer_so and ex1_tid) or xer_cr_ex1_xer_ov_in_pipe;
    ex2_xer_so          <= or_reduce(byp_xer_so and ex2_tid) or xer_cr_ex2_xer_ov_in_pipe;
    ex3_xer_so          <= or_reduce(byp_xer_so and ex3_tid) or xer_cr_ex3_xer_ov_in_pipe;
    ex5_xer_so          <= or_reduce(byp_xer_so and ex5_tid) or xer_cr_ex5_xer_ov_in_pipe;

    with ex1_cr_so_update_q select
    ex1_cr_so           <= (ex1_xer_so or ex1_log_cr(3))    when "01",
                           ex1_log_cr(3)                    when "10",
                           ex1_xer_so                       when others;


    ex1_cr_mcrf         <= ex1_cr1_q &
                           ex1_instr_q(6 to 8)&
                           ex1_cr_we_q;

    ex1_cr_not_mcrf     <= ex1_log_cr(0 to 2) & ex1_cr_so &
                           ex1_instr_q(6 to 8) &
                           ex1_cr_we_q;

    with ex1_is_mcrf_q select
        ex1_cr          <= ex1_cr_not_mcrf      when '0',
                           ex1_cr_mcrf          when others;

    ex2_cr_recform      <= alu_byp_ex2_cr_recform(0 to 2) & (alu_byp_ex2_cr_recform(3) or ex2_xer_so) &
                           (ex2_instr_q(6 to 8) and (6 to 8 => not ex2_use_crfld0_q)) &
                           ex2_cr_we_q;

    with ex2_alu_cmp_q select
        ex2_cr          <= ex2_cr_recform       when '1',
                           ex2_cr_q             when others;

    ex3_cr_div          <= alu_byp_ex3_cr_div(0 to 2) & (alu_byp_ex3_cr_div(3) or ex3_xer_so) &
                           (4 to 6 => tidn) &
                           alu_byp_ex3_cr_div(4);


    with ex3_div_done_q select
        ex3_cr          <= ex3_cr_div   when '1',
                           ex3_cr_q     when others;

    ex4_cr              <= ex4_cr_q;

    ex5_cr_dp           <= "00" &                                                           
                           ((ex5_mtdp_cr_status_q and ex5_mtdp_val_q) or
                            (ex5_mfdp_cr_status_q and ex5_mfdp_val_q)) &                    
                           ex5_xer_so &                                                     
                           (4 to 6 => tidn) &                                               
                           ex5_dp_instr_q;                                                  

    ex5_cr_mul          <= alu_byp_ex5_cr_mul(0 to 2) & (alu_byp_ex5_cr_mul(3) or ex5_xer_so) &
                           (4 to 6 => tidn) &
                           alu_byp_ex5_cr_mul(4);
                           
   
    ex5_wchkall_fld_d   <= gate(ex4_instr_q(6 to 8),dec_byp_ex4_is_wchkall);
    ex5_watch_we_d      <= dec_byp_ex4_is_wchkall or lsu_xu_ex4_cr_upd;

    ex5_cr_watch        <=("00" & lsu_xu_ex5_cr_rslt  & ex5_xer_so) &
                           ex5_wchkall_fld_q &
                           ex5_watch_we_q;
                           
    ex5_fu_cr(0)        <= ex5_fu_cr0_q & ex5_fu_cr0_bf_q & ex5_fu_cr_val_q(0);
    ex5_fu_cr(1)        <= ex5_fu_cr1_q & ex5_fu_cr1_bf_q & ex5_fu_cr_val_q(1);
    ex5_fu_cr(2)        <= ex5_fu_cr2_q & ex5_fu_cr2_bf_q & ex5_fu_cr_val_q(2);
    ex5_fu_cr(3)        <= ex5_fu_cr3_q & ex5_fu_cr3_bf_q & ex5_fu_cr_val_q(3);
    
   ex5_fu_cr_valid         <= or_reduce(rf1_tid and ex5_fu_cr_val_q);
   ex5_cr_instr_update_b   <= not(ex5_cr_dp(7) or ex5_cr_mul(7) or ex5_cr_watch(7));
   
   ex5_cr_fu      <= gate(ex5_fu_cr(0),   rf1_tid(0)) or
                     gate(ex5_fu_cr(1),   rf1_tid(1)) or           
                     gate(ex5_fu_cr(2),   rf1_tid(2)) or
                     gate(ex5_fu_cr(3),   rf1_tid(3));              


   ex5_cr_instr   <= gate(ex5_cr_dp,      ex5_cr_dp(7)         ) or
                     gate(ex5_cr_mul,     ex5_cr_mul(7)        ) or
                     gate(ex5_cr_watch,   ex5_cr_watch(7)      ) or
                     gate(ex5_cr_q,       ex5_cr_instr_update_b);
                  
   ex5_cr         <= gate(ex5_cr_instr,   not(ex5_fu_cr_valid)) or
                     gate(ex5_cr_fu,          ex5_fu_cr_valid );

    with rf1_instr(12 to 19) select
        rf1_mfocrf_src          <= "000"    when "10000000",
                                   "001"    when "01000000",
                                   "010"    when "00100000",
                                   "011"    when "00010000",
                                   "100"    when "00001000",
                                   "101"    when "00000100",
                                   "110"    when "00000010",
                                   "111"    when "00000001",
                                   "000"    when others;

    with rf1_is_mfocrf_q select
        rf1_cr0_source  <= rf1_mfocrf_src       when '1',
                           rf1_instr(16 to 18)  when others;

    with dec_byp_rf1_is_isel select
        rf1_cr1_source  <= rf1_instr(21 to 25)  when '1',
                           rf1_instr(11 to 15)  when others;

    rf1_axu_byp_val(4)   <= or_reduce(rf1_tid and  ex4_val_q);
    rf1_axu_byp_val(5)   <= or_reduce(rf1_tid and (ex5_val_q or ex5_fu_cr_val_q));

    rf1_byp_val(1)       <= ex1_cr(7)   and  dec_byp_rf1_byp_val(1);
    rf1_byp_val(2)       <= ex2_cr(7)   and  dec_byp_rf1_byp_val(2);
    rf1_byp_val(3)       <= ex3_cr(7)   and  dec_byp_rf1_byp_val(3);
    rf1_byp_val(4)       <= ex4_cr(7)   and  rf1_axu_byp_val(4);
    rf1_byp_val(5)       <= ex5_cr(7)   and  rf1_axu_byp_val(5);

    rf1_cr0_cmp(1)       <= '1' when rf1_cr0_source        = ex1_cr(4 to 6)     else '0';
    rf1_cr0_cmp(2)       <= '1' when rf1_cr0_source        = ex2_cr(4 to 6)     else '0';
    rf1_cr0_cmp(3)       <= '1' when rf1_cr0_source        = ex3_cr(4 to 6)     else '0';
    rf1_cr0_cmp(4)       <= '1' when rf1_cr0_source        = ex4_cr(4 to 6)     else '0';
    rf1_cr0_cmp(5)       <= '1' when rf1_cr0_source        = ex5_cr(4 to 6)     else '0';

    rf1_cr0_val          <= rf1_cr0_cmp and rf1_byp_val;

    rf1_cr0_byp_pri(1)   <=                                         rf1_cr0_val(1);
    rf1_cr0_byp_pri(2)   <= not           rf1_cr0_val(1)        and rf1_cr0_val(2);
    rf1_cr0_byp_pri(3)   <= not or_reduce(rf1_cr0_val(1 to 2))  and rf1_cr0_val(3);
    rf1_cr0_byp_pri(4)   <= not or_reduce(rf1_cr0_val(1 to 3))  and rf1_cr0_val(4);
    rf1_cr0_byp_pri(5)   <= not or_reduce(rf1_cr0_val(1 to 4))  and rf1_cr0_val(5);
    rf1_cr0_byp_pri(6)   <= not or_reduce(rf1_cr0_val(1 to 5));

    rf1_cr1_cmp(1)       <= '1' when rf1_cr1_source(0 to 2) = ex1_cr(4 to 6)     else '0';
    rf1_cr1_cmp(2)       <= '1' when rf1_cr1_source(0 to 2) = ex2_cr(4 to 6)     else '0';
    rf1_cr1_cmp(3)       <= '1' when rf1_cr1_source(0 to 2) = ex3_cr(4 to 6)     else '0';
    rf1_cr1_cmp(4)       <= '1' when rf1_cr1_source(0 to 2) = ex4_cr(4 to 6)     else '0';
    rf1_cr1_cmp(5)       <= '1' when rf1_cr1_source(0 to 2) = ex5_cr(4 to 6)     else '0';

    rf1_cr1_val          <= rf1_cr1_cmp and rf1_byp_val;

    rf1_cr1_byp_pri(1)   <=                                         rf1_cr1_val(1);
    rf1_cr1_byp_pri(2)   <= not           rf1_cr1_val(1)        and rf1_cr1_val(2);
    rf1_cr1_byp_pri(3)   <= not or_reduce(rf1_cr1_val(1 to 2))  and rf1_cr1_val(3);
    rf1_cr1_byp_pri(4)   <= not or_reduce(rf1_cr1_val(1 to 3))  and rf1_cr1_val(4);
    rf1_cr1_byp_pri(5)   <= not or_reduce(rf1_cr1_val(1 to 4))  and rf1_cr1_val(5);
    rf1_cr1_byp_pri(6)   <= not or_reduce(rf1_cr1_val(1 to 5));

    rf1_crt_cmp(1)       <= '1' when rf1_instr(6 to 8)     = ex1_cr(4 to 6)     else '0';
    rf1_crt_cmp(2)       <= '1' when rf1_instr(6 to 8)     = ex2_cr(4 to 6)     else '0';
    rf1_crt_cmp(3)       <= '1' when rf1_instr(6 to 8)     = ex3_cr(4 to 6)     else '0';
    rf1_crt_cmp(4)       <= '1' when rf1_instr(6 to 8)     = ex4_cr(4 to 6)     else '0';
    rf1_crt_cmp(5)       <= '1' when rf1_instr(6 to 8)     = ex5_cr(4 to 6)     else '0';

    rf1_crt_val          <= rf1_crt_cmp and rf1_byp_val;

    rf1_crt_byp_pri(1)   <=                                         rf1_crt_val(1);
    rf1_crt_byp_pri(2)   <= not           rf1_crt_val(1)        and rf1_crt_val(2);
    rf1_crt_byp_pri(3)   <= not or_reduce(rf1_crt_val(1 to 2))  and rf1_crt_val(3);
    rf1_crt_byp_pri(4)   <= not or_reduce(rf1_crt_val(1 to 3))  and rf1_crt_val(4);
    rf1_crt_byp_pri(5)   <= not or_reduce(rf1_crt_val(1 to 4))  and rf1_crt_val(5);
    rf1_crt_byp_pri(6)   <= not or_reduce(rf1_crt_val(1 to 5));


    rf1_cr0                     <= gate(ex1_cr(0 to 3),  rf1_cr0_byp_pri(1)) or
                                   gate(ex2_cr(0 to 3),  rf1_cr0_byp_pri(2)) or
                                   gate(ex3_cr(0 to 3),  rf1_cr0_byp_pri(3)) or
                                   gate(ex4_cr(0 to 3),  rf1_cr0_byp_pri(4)) or
                                   gate(ex5_cr(0 to 3),  rf1_cr0_byp_pri(5)) or
                                   gate(cr0_out(0 to 3), rf1_cr0_byp_pri(6));

    with rf1_instr(19 to 20) select
        rf1_cr0_bit             <= rf1_cr0(0)           when "00",
                                   rf1_cr0(1)           when "01",
                                   rf1_cr0(2)           when "10",
                                   rf1_cr0(3)           when others;

    rf1_cr1                     <= gate(ex1_cr(0 to 3),  rf1_cr1_byp_pri(1)) or
                                   gate(ex2_cr(0 to 3),  rf1_cr1_byp_pri(2)) or
                                   gate(ex3_cr(0 to 3),  rf1_cr1_byp_pri(3)) or
                                   gate(ex4_cr(0 to 3),  rf1_cr1_byp_pri(4)) or
                                   gate(ex5_cr(0 to 3),  rf1_cr1_byp_pri(5)) or
                                   gate(cr1_out(0 to 3), rf1_cr1_byp_pri(6));

    with rf1_cr1_source(3 to 4) select
        rf1_cr1_bit_i           <= rf1_cr1(0)           when "00",
                                   rf1_cr1(1)           when "01",
                                   rf1_cr1(2)           when "10",
                                   rf1_cr1(3)           when others;

    rf1_crt                     <= gate(ex1_cr(0 to 3),  rf1_crt_byp_pri(1)) or
                                   gate(ex2_cr(0 to 3),  rf1_crt_byp_pri(2)) or
                                   gate(ex3_cr(0 to 3),  rf1_crt_byp_pri(3)) or
                                   gate(ex4_cr(0 to 3),  rf1_crt_byp_pri(4)) or
                                   gate(ex5_cr(0 to 3),  rf1_crt_byp_pri(5)) or
                                   gate(crt_out(0 to 3), rf1_crt_byp_pri(6));

    rf1_isel_fcn              <= '0' & not(rf1_cr1_bit_i) & rf1_cr1_bit_i & '1';

    byp_alu_rf1_isel_fcn      <= gate(rf1_isel_fcn,dec_byp_rf1_is_isel);
    
   with rf1_instr(9 to 10) select
        rf1_crt_mask            <= "1000"               when "00",
                                   "0100"               when "01",
                                   "0010"               when "10",
                                   "0001"               when others;

   ex1_log_cr_bit <=
      (ex1_instr_2_q(25) and  not ex1_cr1_bit_q and not ex1_cr0_bit_q) or
      (ex1_instr_2_q(24) and  not ex1_cr1_bit_q and     ex1_cr0_bit_q) or
      (ex1_instr_2_q(23) and      ex1_cr1_bit_q and not ex1_cr0_bit_q) or
      (ex1_instr_2_q(22) and      ex1_cr1_bit_q and     ex1_cr0_bit_q);

   ex1_log_cr(0)     <= (ex1_crt_q(0) and not ex1_crt_mask_q(0)) or (ex1_log_cr_bit and ex1_crt_mask_q(0));
   ex1_log_cr(1)     <= (ex1_crt_q(1) and not ex1_crt_mask_q(1)) or (ex1_log_cr_bit and ex1_crt_mask_q(1));
   ex1_log_cr(2)     <= (ex1_crt_q(2) and not ex1_crt_mask_q(2)) or (ex1_log_cr_bit and ex1_crt_mask_q(2));
   ex1_log_cr(3)     <= (ex1_crt_q(3) and not ex1_crt_mask_q(3)) or (ex1_log_cr_bit and ex1_crt_mask_q(3));

   byp_cpl_ex1_cr_bit  <= ex1_cr1_bit_q;


   with ex5_cr_instr(4 to 6) select
      ex5_instr_cr_dec     <= "10000000" when "000",
                              "01000000" when "001",
                              "00100000" when "010",
                              "00010000" when "011",
                              "00001000" when "100",
                              "00000100" when "101",
                              "00000010" when "110",
                              "00000001" when others;
                                                           

   with an_ac_back_inv_addr_q(62 to 63) select
     icswx_tid               <= "1000"   when "00",
                                "0100"   when "01",
                                "0010"   when "10",
                                "0001"   when others;

   back_inv_val_d              <= an_ac_back_inv_q and an_ac_back_inv_target_bit3_q;
   ex5_icswx_we                <= gate(icswx_tid, back_inv_val_q);

   cr_barrier_we_d            <= stcx_complete_q or mmu_cr0_eq_valid_q or ex5_icswx_we;
   
   xuq_byp_cr_gen : for t in 0 to threads-1 generate

      signal cr_q,            cr_d              : std_ulogic_vector(32 to 63);
      signal cr_barrier_q,    cr_barrier_d      : std_ulogic_vector(32 to 35);

      signal ex5_fu_cr_dec                      : std_ulogic_vector(0 to 7);
      signal ex5_fu_we                          : std_ulogic_vector(0 to 7);
      signal ex5_instr_we                       : std_ulogic_vector(0 to 7);
      signal ex5_mtcr_we                        : std_ulogic_vector(0 to 7);

   begin

      with ex5_fu_cr(t)(4 to 6) select
         ex5_fu_cr_dec        <= "10000000" when "000",
                                 "01000000" when "001",
                                 "00100000" when "010",
                                 "00010000" when "011",
                                 "00001000" when "100",
                                 "00000100" when "101",
                                 "00000010" when "110",
                                 "00000001" when others;
                                 
      ex5_fu_cr_val(t)     <= ex5_fu_cr(t)(7) and ex5_axu_val(t);
      ex5_fu_we            <= gate(ex5_fu_cr_dec,ex5_fu_cr_val(t));

      ex5_instr_cr_val(t)  <= ex5_cr_instr(7) and ex5_val(t);
      ex5_instr_we         <= gate(ex5_instr_cr_dec,ex5_instr_cr_val(t));
      
      ex5_mtcr_val(t)      <= ex5_any_mtcrf_q and ex5_val(t);
      ex5_mtcr_we          <= gate(dec_cr_ex5_instr(12 to 19),ex5_mtcr_val(t));
      
      ex5_eratsxr_we(t)    <= ex5_is_eratsxr_q and ex5_val(t);


      with s3'(stcx_complete_q(t) & mmu_cr0_eq_valid_q(t) & ex5_icswx_we(t)) select
         cr_barrier_d(32 to 35)     <= "00" & stcx_pass_q(t)            & byp_xer_so(t)   when "100",
                                       "00" & mmu_cr0_eq_q(t)           & tidn            when "010",
                                       an_ac_back_inv_addr_q(58 to 60)  & tidn            when others;


      with s5'(ex5_eratsxr_we(t) & ex5_mtcr_we(0) & ex5_instr_we(0) & ex5_fu_we(0) & cr_barrier_we_q(t)) select
         cr_d(32 to 35)             <= "00" & byp_ex5_tlb_rt(51)        & tidn            when "10000",
                                       byp_ex5_mtcrxer(32 to 35)                          when "01000",
                                       ex5_cr_instr(0 to 3)                               when "00100",
                                       ex5_fu_cr(t)(0 to 3)                               when "00010",
                                       cr_barrier_q                                       when "00001",
                                       cr_q(32 to 35)                                     when others;
                                       
      xuq_byp_cr_field_gen : for f in 1 to 7 generate

         with s3'(ex5_mtcr_we(f) & ex5_instr_we(f) & ex5_fu_we(f)) select
            cr_d(32+f*4 to 35+f*4)        <= byp_ex5_mtcrxer(32+f*4 to 35+f*4)            when "100",
                                             ex5_cr_instr(0 to 3)                         when "010",
                                             ex5_fu_cr(t)(0 to 3)                         when "001",
                                             cr_q(32+f*4 to 35+f*4)                       when others;

      end generate;
      
      ex5_cr_act(t)              <= ex5_val_q(t) or ex5_axu_val_q(t) or cr_barrier_we_q(t);
      
      
      ex5_cr_we(t)               <=           ex5_eratsxr_we(t) or
                                              cr_barrier_we_q(t) or
                                    or_reduce(ex5_mtcr_we or ex5_instr_we or ex5_fu_we) or
                                    (ex5_val(t) and ex5_any_mtcrf_q);  
      
      cr_out(t*32 to t*32+31)    <= cr_q;

      byp_perf_tx_events(0+3*t)  <= stcx_complete_q(t) and not stcx_pass_q(t);               
      byp_perf_tx_events(1+3*t)  <= ex5_icswx_we(t)    and not an_ac_back_inv_addr_q(59);    
      byp_perf_tx_events(2+3*t)  <= ex5_icswx_we(t)    and     an_ac_back_inv_addr_q(59);    
      

      cr_barrier_latch : tri_rlmreg_p
         generic map (width => cr_barrier_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
         port map (nclk          => nclk,
                   vd            => vdd,
                   gd            => gnd,
                   act           => tiup,
                   forcee => func_sl_force,
                   d_mode        => d_mode_dc,
                   delay_lclkr   => delay_lclkr_dc,
                   mpw1_b        => mpw1_dc_b,
                   mpw2_b        => mpw2_dc_b,
                   thold_b       => func_sl_thold_0_b,
                   sg            => sg_0,
                   scin          => siv(cr_barrier_offset + cr_barrier_q'length*t to cr_barrier_offset + cr_barrier_q'length*(t+1)-1),
                   scout         => sov(cr_barrier_offset + cr_barrier_q'length*t to cr_barrier_offset + cr_barrier_q'length*(t+1)-1),
                   din           => cr_barrier_d,
                   dout          => cr_barrier_q);
      cr_latch : tri_rlmreg_p
         generic map (width => cr_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
         port map (nclk          => nclk,
                   vd            => vdd,
                   gd            => gnd,
                   act           => ex5_cr_act(t),
                   forcee => func_sl_force,
                   d_mode        => d_mode_dc,
                   delay_lclkr   => delay_lclkr_dc,
                   mpw1_b        => mpw1_dc_b,
                   mpw2_b        => mpw2_dc_b,
                   thold_b       => func_sl_thold_0_b,
                   sg            => sg_0,
                   scin          => siv(cr_offset + cr_q'length*t to cr_offset + cr_q'length*(t+1)-1),
                   scout         => sov(cr_offset + cr_q'length*t to cr_offset + cr_q'length*(t+1)-1),
                   din           => cr_d,
                   dout          => cr_q);
   end generate;
      
    xuq_byp_cr_mfocr : for t in 0 to 7 generate
        ex1_mfocrf_rt(t*4+32 to t*4+35) <= gate(ex1_cr0_q,ex1_instr_q(t+12));
    end generate;
    xuq_byp_cr_mfocr_z : if regsize > 32 generate
        ex1_mfocrf_rt(0 to 31)          <= (others=>'0');
    end generate;

    ex5_cr_rt       <= mux_t(cr_out,ex5_tid);

    cr_mux          <= mux_t(cr_out,rf1_tid);

    with rf1_cr0_source select
       cr0_out  <= cr_mux(0 to 3)    when "000",
                   cr_mux(4 to 7)    when "001",
                   cr_mux(8 to 11)   when "010",
                   cr_mux(12 to 15)  when "011",
                   cr_mux(16 to 19)  when "100",
                   cr_mux(20 to 23)  when "101",
                   cr_mux(24 to 27)  when "110",
                   cr_mux(28 to 31)  when others;

    with rf1_cr1_source(0 to 2) select
       cr1_out  <= cr_mux(0 to 3)    when "000",
                   cr_mux(4 to 7)    when "001",
                   cr_mux(8 to 11)   when "010",
                   cr_mux(12 to 15)  when "011",
                   cr_mux(16 to 19)  when "100",
                   cr_mux(20 to 23)  when "101",
                   cr_mux(24 to 27)  when "110",
                   cr_mux(28 to 31)  when others;

    with rf1_instr(6 to 8) select
       crt_out  <= cr_mux(0 to 3)    when "000",
                   cr_mux(4 to 7)    when "001",
                   cr_mux(8 to 11)   when "010",
                   cr_mux(12 to 15)  when "011",
                   cr_mux(16 to 19)  when "100",
                   cr_mux(20 to 23)  when "101",
                   cr_mux(24 to 27)  when "110",
                   cr_mux(28 to 31)  when others;


    mark_unused(ex5_cr_we);
    mark_unused(ex1_instr_q(9 to 11));
    mark_unused(an_ac_back_inv_addr_q(61));

      cr_grp0_debug     <= cr_grp0_debug_int;
      cr_grp0_debug_int <= ex6_val_dbg_q                    &
                           ex5_fu_cr_val_q                  &
                           ex5_fu_cr_noflush_q              &
                           ex1_cr_so_update_q(0 to 1)       &
                           ex1_is_mcrf_q                    &
                           ex2_alu_cmp_q                    &
                           ex3_div_done_q                   &
                           ex5_watch_we_q                   &
                           ex5_dp_instr_q                   &
                           alu_byp_ex5_cr_mul(4)            &
                           ex5_any_mtcrf_q                  &
                           ex5_is_eratsxr_q                 &
                           stcx_complete_q(0 to 3)          &
                           mmu_cr0_eq_valid_q(0 to 3)       &
                           ex1_cr1_bit_q                    &
                           an_ac_back_inv_q                 &
                           an_ac_back_inv_target_bit3_q     &                     
                           an_ac_back_inv_addr_q(62 to 63)  &
                           ex5_fu_cr(0)(4 to 6)             &
                           ex5_fu_cr(1)(4 to 6)             &
                           ex5_fu_cr(2)(4 to 6)             &
                           ex5_fu_cr(3)(4 to 6)             &
                           ex5_cr_instr(4 to 6)             &
                           dec_cr_ex5_instr(12 to 19)       &
                           ex1_cr0_q(0 to 3)                &
                           ex1_cr1_q(0 to 3)                &
                           ex1_crt_q(0 to 3)                &
                           ex1_cr0_byp_pri_dbg_q(1 to 6)    &
                           ex1_cr1_byp_pri_dbg_q(1 to 6)    &
                           ex1_crt_byp_pri_dbg_q(1 to 6);

      cr_grp1_debug     <= cr_grp0_debug_int(0 to 71)       &
                           ex3_cr_q(0 to 7)                 &
                           ex5_cr_q(0 to 7);

rf1_is_mfocrf_latch : tri_regk
  generic map (width => 1, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup                 ,
            forcee => func_nsl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_nsl_thold_0_b,
            din(0)  => fxa_fxb_rf0_is_mfocrf      ,
            dout(0) => rf1_is_mfocrf_q);
ex1_alu_cmp_latch : tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => exx_act(0)           ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex1_alu_cmp_offset),
            scout   => sov(ex1_alu_cmp_offset),
            din     => dec_byp_rf1_alu_cmp        ,
            dout    => ex1_alu_cmp_q);
ex1_any_mtcrf_latch : tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => exx_act(0)           ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex1_any_mtcrf_offset),
            scout   => sov(ex1_any_mtcrf_offset),
            din     => ex1_any_mtcrf_d,
            dout    => ex1_any_mtcrf_q);
ex1_cr0_latch : tri_rlmreg_p
  generic map (width => ex1_cr0_q'length, init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => exx_act(0)           ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex1_cr0_offset to ex1_cr0_offset + ex1_cr0_q'length-1),
            scout   => sov(ex1_cr0_offset to ex1_cr0_offset + ex1_cr0_q'length-1),
            din     => rf1_cr0                    ,
            dout    => ex1_cr0_q);
ex1_cr0_bit_latch : tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => exx_act(0)           ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex1_cr0_bit_offset),
            scout   => sov(ex1_cr0_bit_offset),
            din     => rf1_cr0_bit,
            dout    => ex1_cr0_bit_q);
ex1_cr1_latch : tri_rlmreg_p
  generic map (width => ex1_cr1_q'length, init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => exx_act(0)           ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex1_cr1_offset to ex1_cr1_offset + ex1_cr1_q'length-1),
            scout   => sov(ex1_cr1_offset to ex1_cr1_offset + ex1_cr1_q'length-1),
            din     => rf1_cr1                    ,
            dout    => ex1_cr1_q);
ex1_cr1_bit_latch : tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => exx_act(0)           ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex1_cr1_bit_offset),
            scout   => sov(ex1_cr1_bit_offset),
            din     => rf1_cr1_bit_i,
            dout    => ex1_cr1_bit_q);
ex1_cr_so_update_latch : tri_rlmreg_p
  generic map (width => ex1_cr_so_update_q'length, init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => exx_act(0)           ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex1_cr_so_update_offset to ex1_cr_so_update_offset + ex1_cr_so_update_q'length-1),
            scout   => sov(ex1_cr_so_update_offset to ex1_cr_so_update_offset + ex1_cr_so_update_q'length-1),
            din     => dec_byp_rf1_cr_so_update   ,
            dout    => ex1_cr_so_update_q);
ex1_cr_we_latch : tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup                 ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex1_cr_we_offset),
            scout   => sov(ex1_cr_we_offset),
            din     => dec_byp_rf1_cr_we          ,
            dout    => ex1_cr_we_q);
ex1_crt_latch : tri_rlmreg_p
  generic map (width => ex1_crt_q'length, init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => exx_act(0)           ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex1_crt_offset to ex1_crt_offset + ex1_crt_q'length-1),
            scout   => sov(ex1_crt_offset to ex1_crt_offset + ex1_crt_q'length-1),
            din     => rf1_crt,
            dout    => ex1_crt_q);
ex1_crt_mask_latch : tri_rlmreg_p
  generic map (width => ex1_crt_mask_q'length, init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => exx_act(0)           ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex1_crt_mask_offset to ex1_crt_mask_offset + ex1_crt_mask_q'length-1),
            scout   => sov(ex1_crt_mask_offset to ex1_crt_mask_offset + ex1_crt_mask_q'length-1),
            din     => rf1_crt_mask,
            dout    => ex1_crt_mask_q);
ex1_instr_latch : tri_rlmreg_p
  generic map (width => ex1_instr_q'length, init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => exx_act(0)           ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex1_instr_offset to ex1_instr_offset + ex1_instr_q'length-1),
            scout   => sov(ex1_instr_offset to ex1_instr_offset + ex1_instr_q'length-1),
            din     => rf1_instr(6 to 19),
            dout    => ex1_instr_q);
ex1_instr_2_latch : tri_rlmreg_p
  generic map (width => ex1_instr_2_q'length, init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => exx_act(0)           ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex1_instr_2_offset to ex1_instr_2_offset + ex1_instr_2_q'length-1),
            scout   => sov(ex1_instr_2_offset to ex1_instr_2_offset + ex1_instr_2_q'length-1),
            din     => rf1_instr(22 to 25),
            dout    => ex1_instr_2_q);
ex1_is_mcrf_latch : tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => exx_act(0)           ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex1_is_mcrf_offset),
            scout   => sov(ex1_is_mcrf_offset),
            din     => dec_byp_rf1_is_mcrf        ,
            dout    => ex1_is_mcrf_q);
ex1_use_crfld0_latch : tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => exx_act(0)           ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex1_use_crfld0_offset),
            scout   => sov(ex1_use_crfld0_offset),
            din     => dec_byp_rf1_use_crfld0     ,
            dout    => ex1_use_crfld0_q);
ex2_alu_cmp_latch : tri_regk
  generic map (width => 1, init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => exx_act(1)           ,
            forcee => func_nsl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_nsl_thold_0_b,
            din(0)  => ex1_alu_cmp_q              ,
            dout(0) => ex2_alu_cmp_q);
ex2_any_mtcrf_latch : tri_regk
  generic map (width => 1, init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => exx_act(1)           ,
            forcee => func_nsl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_nsl_thold_0_b,
            din(0)  => ex1_any_mtcrf_q            ,
            dout(0) => ex2_any_mtcrf_q);
ex2_cr_latch : tri_regk
  generic map (width => ex2_cr_q'length, init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => exx_act(1)           ,
            forcee => func_nsl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_nsl_thold_0_b,
            din     => ex1_cr                     ,
            dout    => ex2_cr_q);
ex2_cr_we_latch : tri_regk
  generic map (width => 1, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup                 ,
            forcee => func_nsl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_nsl_thold_0_b,
            din(0)  => ex1_cr_we_q                ,
            dout(0) => ex2_cr_we_q);
ex2_instr_latch : tri_regk
  generic map (width => ex2_instr_q'length, init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => exx_act(1)           ,
            forcee => func_nsl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_nsl_thold_0_b,
            din     => ex1_instr_q(6 to 8),
            dout    => ex2_instr_q);
ex2_use_crfld0_latch : tri_regk
  generic map (width => 1, init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => exx_act(1)           ,
            forcee => func_nsl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_nsl_thold_0_b,
            din(0)  => ex1_use_crfld0_q           ,
            dout(0) => ex2_use_crfld0_q);
ex3_any_mtcrf_latch : tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => exx_act(2)           ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex3_any_mtcrf_offset),
            scout   => sov(ex3_any_mtcrf_offset),
            din     => ex2_any_mtcrf_q            ,
            dout    => ex3_any_mtcrf_q);
ex3_cr_latch : tri_rlmreg_p
  generic map (width => ex3_cr_q'length, init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => exx_act(2)           ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex3_cr_offset to ex3_cr_offset + ex3_cr_q'length-1),
            scout   => sov(ex3_cr_offset to ex3_cr_offset + ex3_cr_q'length-1),
            din     => ex2_cr                     ,
            dout    => ex3_cr_q);
ex3_div_done_latch : tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => exx_act(2)           ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex3_div_done_offset),
            scout   => sov(ex3_div_done_offset),
            din     => alu_ex2_div_done           ,
            dout    => ex3_div_done_q);
ex3_instr_latch : tri_rlmreg_p
  generic map (width => ex3_instr_q'length, init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => exx_act(2)           ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex3_instr_offset to ex3_instr_offset + ex3_instr_q'length-1),
            scout   => sov(ex3_instr_offset to ex3_instr_offset + ex3_instr_q'length-1),
            din     => ex2_instr_q                ,
            dout    => ex3_instr_q);
ex4_any_mtcrf_latch : tri_regk
  generic map (width => 1, init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => exx_act(3)           ,
            forcee => func_nsl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_nsl_thold_0_b,
            din(0)  => ex3_any_mtcrf_q            ,
            dout(0) => ex4_any_mtcrf_q);
ex4_cr_latch : tri_regk
  generic map (width => ex4_cr_q'length, init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => exx_act(3)           ,
            forcee => func_nsl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_nsl_thold_0_b,
            din     => ex3_cr                     ,
            dout    => ex4_cr_q);
ex4_instr_latch : tri_regk
  generic map (width => ex4_instr_q'length, init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => exx_act(3)           ,
            forcee => func_nsl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_nsl_thold_0_b,
            din     => ex3_instr_q                ,
            dout    => ex4_instr_q);
ex4_val_latch : tri_regk
  generic map (width => ex4_val_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup                 ,
            forcee => func_nsl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_nsl_thold_0_b,
            din     => ex3_val,
            dout    => ex4_val_q);
ex5_any_mtcrf_latch : tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => exx_act(4)           ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex5_any_mtcrf_offset),
            scout   => sov(ex5_any_mtcrf_offset),
            din     => ex4_any_mtcrf_q            ,
            dout    => ex5_any_mtcrf_q);
ex5_axu_val_latch : tri_rlmreg_p
  generic map (width => ex5_axu_val_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup                 ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex5_axu_val_offset to ex5_axu_val_offset + ex5_axu_val_q'length-1),
            scout   => sov(ex5_axu_val_offset to ex5_axu_val_offset + ex5_axu_val_q'length-1),
            din     => ex4_axu_val,
            dout    => ex5_axu_val_q);
ex5_cr_latch : tri_rlmreg_p
  generic map (width => ex5_cr_q'length, init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => exx_act(4)           ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex5_cr_offset to ex5_cr_offset + ex5_cr_q'length-1),
            scout   => sov(ex5_cr_offset to ex5_cr_offset + ex5_cr_q'length-1),
            din     => ex4_cr                     ,
            dout    => ex5_cr_q);
ex5_dp_instr_latch : tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => exx_act(4)           ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex5_dp_instr_offset),
            scout   => sov(ex5_dp_instr_offset),
            din     => dec_byp_ex4_dp_instr       ,
            dout    => ex5_dp_instr_q);
ex5_fu_cr0_latch : tri_rlmreg_p
  generic map (width => ex5_fu_cr0_q'length, init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => ex4_axu_act           ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex5_fu_cr0_offset to ex5_fu_cr0_offset + ex5_fu_cr0_q'length-1),
            scout   => sov(ex5_fu_cr0_offset to ex5_fu_cr0_offset + ex5_fu_cr0_q'length-1),
            din     => fu_xu_ex4_cr0              ,
            dout    => ex5_fu_cr0_q);
ex5_fu_cr0_bf_latch : tri_rlmreg_p
  generic map (width => ex5_fu_cr0_bf_q'length, init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => ex4_axu_act           ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex5_fu_cr0_bf_offset to ex5_fu_cr0_bf_offset + ex5_fu_cr0_bf_q'length-1),
            scout   => sov(ex5_fu_cr0_bf_offset to ex5_fu_cr0_bf_offset + ex5_fu_cr0_bf_q'length-1),
            din     => fu_xu_ex4_cr0_bf           ,
            dout    => ex5_fu_cr0_bf_q);
ex5_fu_cr1_latch : tri_rlmreg_p
  generic map (width => ex5_fu_cr1_q'length, init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => ex4_axu_act           ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex5_fu_cr1_offset to ex5_fu_cr1_offset + ex5_fu_cr1_q'length-1),
            scout   => sov(ex5_fu_cr1_offset to ex5_fu_cr1_offset + ex5_fu_cr1_q'length-1),
            din     => fu_xu_ex4_cr1              ,
            dout    => ex5_fu_cr1_q);
ex5_fu_cr1_bf_latch : tri_rlmreg_p
  generic map (width => ex5_fu_cr1_bf_q'length, init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => ex4_axu_act           ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex5_fu_cr1_bf_offset to ex5_fu_cr1_bf_offset + ex5_fu_cr1_bf_q'length-1),
            scout   => sov(ex5_fu_cr1_bf_offset to ex5_fu_cr1_bf_offset + ex5_fu_cr1_bf_q'length-1),
            din     => fu_xu_ex4_cr1_bf           ,
            dout    => ex5_fu_cr1_bf_q);
ex5_fu_cr2_latch : tri_rlmreg_p
  generic map (width => ex5_fu_cr2_q'length, init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => ex4_axu_act           ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex5_fu_cr2_offset to ex5_fu_cr2_offset + ex5_fu_cr2_q'length-1),
            scout   => sov(ex5_fu_cr2_offset to ex5_fu_cr2_offset + ex5_fu_cr2_q'length-1),
            din     => fu_xu_ex4_cr2              ,
            dout    => ex5_fu_cr2_q);
ex5_fu_cr2_bf_latch : tri_rlmreg_p
  generic map (width => ex5_fu_cr2_bf_q'length, init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => ex4_axu_act           ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex5_fu_cr2_bf_offset to ex5_fu_cr2_bf_offset + ex5_fu_cr2_bf_q'length-1),
            scout   => sov(ex5_fu_cr2_bf_offset to ex5_fu_cr2_bf_offset + ex5_fu_cr2_bf_q'length-1),
            din     => fu_xu_ex4_cr2_bf           ,
            dout    => ex5_fu_cr2_bf_q);
ex5_fu_cr3_latch : tri_rlmreg_p
  generic map (width => ex5_fu_cr3_q'length, init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => ex4_axu_act           ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex5_fu_cr3_offset to ex5_fu_cr3_offset + ex5_fu_cr3_q'length-1),
            scout   => sov(ex5_fu_cr3_offset to ex5_fu_cr3_offset + ex5_fu_cr3_q'length-1),
            din     => fu_xu_ex4_cr3              ,
            dout    => ex5_fu_cr3_q);
ex5_fu_cr3_bf_latch : tri_rlmreg_p
  generic map (width => ex5_fu_cr3_bf_q'length, init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => ex4_axu_act           ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex5_fu_cr3_bf_offset to ex5_fu_cr3_bf_offset + ex5_fu_cr3_bf_q'length-1),
            scout   => sov(ex5_fu_cr3_bf_offset to ex5_fu_cr3_bf_offset + ex5_fu_cr3_bf_q'length-1),
            din     => fu_xu_ex4_cr3_bf           ,
            dout    => ex5_fu_cr3_bf_q);
ex5_fu_cr_noflush_latch : tri_rlmreg_p
  generic map (width => ex5_fu_cr_noflush_q'length, init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex5_fu_cr_noflush_offset to ex5_fu_cr_noflush_offset + ex5_fu_cr_noflush_q'length-1),
            scout   => sov(ex5_fu_cr_noflush_offset to ex5_fu_cr_noflush_offset + ex5_fu_cr_noflush_q'length-1),
            din     => fu_xu_ex4_cr_noflush       ,
            dout    => ex5_fu_cr_noflush_q);
ex5_fu_cr_val_latch : tri_rlmreg_p
  generic map (width => ex5_fu_cr_val_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup                 ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex5_fu_cr_val_offset to ex5_fu_cr_val_offset + ex5_fu_cr_val_q'length-1),
            scout   => sov(ex5_fu_cr_val_offset to ex5_fu_cr_val_offset + ex5_fu_cr_val_q'length-1),
            din     => fu_xu_ex4_cr_val           ,
            dout    => ex5_fu_cr_val_q);
ex5_is_eratsxr_latch : tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => exx_act(4)           ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex5_is_eratsxr_offset),
            scout   => sov(ex5_is_eratsxr_offset),
            din     => dec_byp_ex4_is_eratsxr     ,
            dout    => ex5_is_eratsxr_q);
ex5_mfdp_cr_status_latch : tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => exx_act(4)           ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex5_mfdp_cr_status_offset),
            scout   => sov(ex5_mfdp_cr_status_offset),
            din     => lsu_xu_ex4_mfdp_cr_status  ,
            dout    => ex5_mfdp_cr_status_q);
ex5_mfdp_val_latch : tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => exx_act(4)           ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex5_mfdp_val_offset),
            scout   => sov(ex5_mfdp_val_offset),
            din     => dec_byp_ex4_mfdp_val       ,
            dout    => ex5_mfdp_val_q);
ex5_mtdp_cr_status_latch : tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => exx_act(4)           ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex5_mtdp_cr_status_offset),
            scout   => sov(ex5_mtdp_cr_status_offset),
            din     => lsu_xu_ex4_mtdp_cr_status  ,
            dout    => ex5_mtdp_cr_status_q);
ex5_mtdp_val_latch : tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup                 ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex5_mtdp_val_offset),
            scout   => sov(ex5_mtdp_val_offset),
            din     => dec_byp_ex4_mtdp_val       ,
            dout    => ex5_mtdp_val_q);
ex5_val_latch : tri_rlmreg_p
  generic map (width => ex5_val_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup                 ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex5_val_offset to ex5_val_offset + ex5_val_q'length-1),
            scout   => sov(ex5_val_offset to ex5_val_offset + ex5_val_q'length-1),
            din     => ex4_val,
            dout    => ex5_val_q);
ex5_watch_we_latch : tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup                 ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex5_watch_we_offset),
            scout   => sov(ex5_watch_we_offset),
            din     => ex5_watch_we_d,
            dout    => ex5_watch_we_q);
ex5_wchkall_fld_latch : tri_rlmreg_p
  generic map (width => ex5_wchkall_fld_q'length, init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => exx_act(4)           ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex5_wchkall_fld_offset to ex5_wchkall_fld_offset + ex5_wchkall_fld_q'length-1),
            scout   => sov(ex5_wchkall_fld_offset to ex5_wchkall_fld_offset + ex5_wchkall_fld_q'length-1),
            din     => ex5_wchkall_fld_d,
            dout    => ex5_wchkall_fld_q);
an_ac_back_inv_latch : tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup                 ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(an_ac_back_inv_offset),
            scout   => sov(an_ac_back_inv_offset),
            din     => an_ac_back_inv             ,
            dout    => an_ac_back_inv_q);
an_ac_back_inv_addr_latch : tri_rlmreg_p
  generic map (width => an_ac_back_inv_addr_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup                 ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(an_ac_back_inv_addr_offset to an_ac_back_inv_addr_offset + an_ac_back_inv_addr_q'length-1),
            scout   => sov(an_ac_back_inv_addr_offset to an_ac_back_inv_addr_offset + an_ac_back_inv_addr_q'length-1),
            din     => an_ac_back_inv_addr        ,
            dout    => an_ac_back_inv_addr_q);
an_ac_back_inv_target_bit3_latch : tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup                 ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(an_ac_back_inv_target_bit3_offset),
            scout   => sov(an_ac_back_inv_target_bit3_offset),
            din     => an_ac_back_inv_target_bit3 ,
            dout    => an_ac_back_inv_target_bit3_q);
back_inv_val_latch : tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup                 ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(back_inv_val_offset),
            scout   => sov(back_inv_val_offset),
            din     => back_inv_val_d,
            dout    => back_inv_val_q);
cr_barrier_we_latch : tri_rlmreg_p
  generic map (width => cr_barrier_we_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup                 ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(cr_barrier_we_offset to cr_barrier_we_offset + cr_barrier_we_q'length-1),
            scout   => sov(cr_barrier_we_offset to cr_barrier_we_offset + cr_barrier_we_q'length-1),
            din     => cr_barrier_we_d,
            dout    => cr_barrier_we_q);
exx_act_latch : tri_rlmreg_p
  generic map (width => exx_act_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup                 ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(exx_act_offset to exx_act_offset + exx_act_q'length-1),
            scout   => sov(exx_act_offset to exx_act_offset + exx_act_q'length-1),
            din     => exx_act_d,
            dout    => exx_act_q);
mmu_cr0_eq_latch : tri_rlmreg_p
  generic map (width => mmu_cr0_eq_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup                 ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(mmu_cr0_eq_offset to mmu_cr0_eq_offset + mmu_cr0_eq_q'length-1),
            scout   => sov(mmu_cr0_eq_offset to mmu_cr0_eq_offset + mmu_cr0_eq_q'length-1),
            din     => mm_xu_cr0_eq               ,
            dout    => mmu_cr0_eq_q);
mmu_cr0_eq_valid_latch : tri_rlmreg_p
  generic map (width => mmu_cr0_eq_valid_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup                 ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(mmu_cr0_eq_valid_offset to mmu_cr0_eq_valid_offset + mmu_cr0_eq_valid_q'length-1),
            scout   => sov(mmu_cr0_eq_valid_offset to mmu_cr0_eq_valid_offset + mmu_cr0_eq_valid_q'length-1),
            din     => mm_xu_cr0_eq_valid         ,
            dout    => mmu_cr0_eq_valid_q);
stcx_complete_latch : tri_rlmreg_p
  generic map (width => stcx_complete_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup                 ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(stcx_complete_offset to stcx_complete_offset + stcx_complete_q'length-1),
            scout   => sov(stcx_complete_offset to stcx_complete_offset + stcx_complete_q'length-1),
            din     => an_ac_stcx_complete        ,
            dout    => stcx_complete_q);
stcx_pass_latch : tri_rlmreg_p
  generic map (width => stcx_pass_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup                 ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(stcx_pass_offset to stcx_pass_offset + stcx_pass_q'length-1),
            scout   => sov(stcx_pass_offset to stcx_pass_offset + stcx_pass_q'length-1),
            din     => an_ac_stcx_pass            ,
            dout    => stcx_pass_q);
ex1_cr0_byp_pri_dbg_latch : tri_rlmreg_p
  generic map (width => ex1_cr0_byp_pri_dbg_q'length, init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => trace_bus_enable     ,
            forcee => func_slp_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_slp_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex1_cr0_byp_pri_dbg_offset to ex1_cr0_byp_pri_dbg_offset + ex1_cr0_byp_pri_dbg_q'length-1),
            scout   => sov(ex1_cr0_byp_pri_dbg_offset to ex1_cr0_byp_pri_dbg_offset + ex1_cr0_byp_pri_dbg_q'length-1),
            din     => rf1_cr0_byp_pri            ,
            dout    => ex1_cr0_byp_pri_dbg_q);
ex1_cr1_byp_pri_dbg_latch : tri_rlmreg_p
  generic map (width => ex1_cr1_byp_pri_dbg_q'length, init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => trace_bus_enable     ,
            forcee => func_slp_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_slp_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex1_cr1_byp_pri_dbg_offset to ex1_cr1_byp_pri_dbg_offset + ex1_cr1_byp_pri_dbg_q'length-1),
            scout   => sov(ex1_cr1_byp_pri_dbg_offset to ex1_cr1_byp_pri_dbg_offset + ex1_cr1_byp_pri_dbg_q'length-1),
            din     => rf1_cr1_byp_pri            ,
            dout    => ex1_cr1_byp_pri_dbg_q);
ex1_crt_byp_pri_dbg_latch : tri_rlmreg_p
  generic map (width => ex1_crt_byp_pri_dbg_q'length, init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => trace_bus_enable     ,
            forcee => func_slp_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_slp_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex1_crt_byp_pri_dbg_offset to ex1_crt_byp_pri_dbg_offset + ex1_crt_byp_pri_dbg_q'length-1),
            scout   => sov(ex1_crt_byp_pri_dbg_offset to ex1_crt_byp_pri_dbg_offset + ex1_crt_byp_pri_dbg_q'length-1),
            din     => rf1_crt_byp_pri            ,
            dout    => ex1_crt_byp_pri_dbg_q);
ex6_val_dbg_latch : tri_rlmreg_p
  generic map (width => ex6_val_dbg_q'length, init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => trace_bus_enable     ,
            forcee => func_slp_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_slp_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex6_val_dbg_offset to ex6_val_dbg_offset + ex6_val_dbg_q'length-1),
            scout   => sov(ex6_val_dbg_offset to ex6_val_dbg_offset + ex6_val_dbg_q'length-1),
            din     => ex5_val                    ,
            dout    => ex6_val_dbg_q);

siv(0 to siv'right)  <= sov(1 to siv'right) & scan_in;
scan_out             <= sov(0);


end architecture xuq_byp_cr;
