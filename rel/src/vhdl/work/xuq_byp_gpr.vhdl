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

--  Description:  XU Bypass Unit
--
library ieee,ibm,support,tri;
use ieee.std_logic_1164.all;
use ibm.std_ulogic_support.all;
use ibm.std_ulogic_function_support.all;
use tri.tri_latches_pkg.all;
use support.power_logic_pkg.all;
use work.xuq_pkg.all;

entity xuq_byp_gpr is
generic (
   threads                             : integer := 4;
   expand_type                         : integer := 2;
   regsize                             : integer := 64;
   eff_ifar                            : integer := 62);
port (
   nclk                                : in  clk_logic;
   vdd                                 : inout power_logic;
   gnd                                 : inout power_logic;
   d_mode_dc                           : in  std_ulogic;
   delay_lclkr_dc                      : in  std_ulogic;
   mpw1_dc_b                           : in  std_ulogic;
   mpw2_dc_b                           : in  std_ulogic;
   func_sl_force : in  std_ulogic;
   func_sl_thold_0_b                   : in  std_ulogic;
   func_slp_sl_force : in  std_ulogic;
   func_slp_sl_thold_0_b               : in  std_ulogic;
   func_nsl_force : in  std_ulogic;
   func_nsl_thold_0_b                  : in  std_ulogic;
   sg_0                                : in  std_ulogic;
   scan_in                             : in  std_ulogic;
   scan_out                            : out std_ulogic;
   
   dec_byp_ex3_instr_trace_val         : in  std_ulogic;
   dec_byp_ex3_instr_trace_gate        : in  std_ulogic;
   pc_xu_trace_bus_enable              : in  std_ulogic;
   trace_bus_enable                    : out std_ulogic;

   --<<FIX>>
   dec_rf1_tid                         : in  std_ulogic_vector(0 to threads-1);
   dec_ex2_tid                         : in  std_ulogic_vector(0 to threads-1);
   dec_byp_rf0_act                     : in  std_ulogic;

   -- Bypass Selects
   dec_byp_rf1_rs0_sel                 : in  std_ulogic_vector(1 to 9);
   dec_byp_rf1_rs1_sel                 : in  std_ulogic_vector(1 to 10);
   dec_byp_rf1_rs2_sel                 : in  std_ulogic_vector(1 to 9);

   -- Result Selects
   dec_alu_rf1_sel                     : in  std_ulogic_vector(2 to 2);
   fxa_fxb_rf0_is_mfocrf               : in  std_ulogic;
   dec_byp_ex1_spr_sel                 : in  std_ulogic;
   alu_ex2_div_done                    : in  std_ulogic;
   dec_byp_ex3_tlb_sel                 : in  std_ulogic_vector(0 to 1);
   alu_ex4_mul_done                    : in  std_ulogic;
   dec_byp_ex4_is_mfcr                 : in  std_ulogic;
   spr_byp_ex4_is_mfxer                : in  std_ulogic_vector(0 to 3);
   lsu_xu_ex5_wren                     : in  std_ulogic;

   -- Slow SPR Bus
   slowspr_val_in                      : in  std_ulogic;
   slowspr_rw_in                       : in  std_ulogic;
   slowspr_addr_in                     : in  std_ulogic_vector(0 to 9);
   slowspr_etid_in                     : in  std_ulogic_vector(0 to 1);
   slowspr_done_in                     : in  std_ulogic;
   
   -- DCR Bus
   dec_byp_ex4_dcr_ack                 : in  std_ulogic;
   an_ac_dcr_act                       : in  std_ulogic;
   an_ac_dcr_read                      : in  std_ulogic;
   an_ac_dcr_etid                      : in  std_ulogic_vector(0 to 1);
   an_ac_dcr_done                      : in  std_ulogic;

   -- SPR/DCR Done
   xu_iu_slowspr_done                  : out std_ulogic_vector(0 to 3);
   mux_cpl_slowspr_done                : out std_ulogic_vector(0 to 3);
   mux_cpl_slowspr_flush               : out std_ulogic_vector(0 to threads-1);
   

   -- Source Data
   dec_byp_rf1_imm                     : in  std_ulogic_vector(64-regsize to 63);
   fxa_fxb_rf1_do0                     : in  std_ulogic_vector(64-regsize to 63);
   fxa_fxb_rf1_do1                     : in  std_ulogic_vector(64-regsize to 63);
   fxa_fxb_rf1_do2                     : in  std_ulogic_vector(64-regsize to 63);

   -- Result Busses
   alu_byp_ex1_log_rt                  : in  std_ulogic_vector(64-regsize to 63);     -- ALU Logicals
   alu_byp_ex2_rt                      : in  std_ulogic_vector(64-regsize to 63);     -- ALU
   alu_byp_ex3_div_rt                  : in  std_ulogic_vector(64-regsize to 63);     -- Divide
   cpl_byp_ex3_spr_rt                  : in  std_ulogic_vector(64-regsize to 63);     -- CPL SPR
   spr_byp_ex3_spr_rt                  : in  std_ulogic_vector(64-regsize to 63);     -- SPR
   fspr_byp_ex3_spr_rt                 : in  std_ulogic_vector(64-regsize to 63);     -- FXU SPR
   lsu_xu_ex4_tlb_data                 : in  std_ulogic_vector(64-regsize to 63);     -- D-ERAT
   iu_xu_ex4_tlb_data                  : in  std_ulogic_vector(64-regsize to 63);     -- I-ERAT
   alu_byp_ex5_mul_rt                  : in  std_ulogic_vector(64-regsize to 63);     -- Multiply
   lsu_xu_rot_ex6_data_b               : in  std_ulogic_vector(64-regsize to 63);     -- Load/Store Hit
   lsu_xu_rot_rel_data                 : in  std_ulogic_vector(64-regsize to 63);     -- Load/Store Miss
   slowspr_data_in                     : in  std_ulogic_vector(64-regsize to 63);     -- Slow SPR
   an_ac_dcr_data                      : in  std_ulogic_vector(64-regsize to 63);     -- DCR

   byp_ex5_cr_rt                       : in  std_ulogic_vector(32 to 63);
   byp_ex5_xer_rt                      : in  std_ulogic_vector(54 to 63);
   ex1_mfocrf_rt                       : in  std_ulogic_vector(64-regsize to 63);

   -- Target Data
   byp_alu_ex1_rs0                     : out std_ulogic_vector(64-regsize to 63);
   byp_alu_ex1_rs1                     : out std_ulogic_vector(64-regsize to 63);
   byp_alu_ex1_mulsrc_0                : out std_ulogic_vector(64-regsize to 63);
   byp_alu_ex1_mulsrc_1                : out std_ulogic_vector(64-regsize to 63);
   byp_alu_ex1_divsrc_0                : out std_ulogic_vector(64-regsize to 63);
   byp_alu_ex1_divsrc_1                : out std_ulogic_vector(64-regsize to 63);
   xu_lsu_ex1_add_src0                 : out std_ulogic_vector(64-regsize to 63);
   xu_lsu_ex1_add_src1                 : out std_ulogic_vector(64-regsize to 63);

   -- Other Outputs
   xu_ex1_rs_is                        : out std_ulogic_vector(0 to 8);
   xu_ex1_ra_entry                     : out std_ulogic_vector(7 to 11);
   xu_ex1_rb                           : out std_ulogic_vector(64-regsize to 51);
   xu_ex4_rs_data                      : out std_ulogic_vector(64-regsize to 63);     -- TLB Write Data
   xu_mm_derat_epn                     : out std_ulogic_vector(62-eff_ifar to 51);    -- DERAT EPN
   xu_pc_ram_data                      : out std_ulogic_vector(64-regsize to 63);     -- RAM Result Capture
   mux_spr_ex6_rt                      : out std_ulogic_vector(64-regsize to 63);     -- SPR Write Data

   -- SPR Inputs
   spr_msr_cm                          : in  std_ulogic_vector(0 to threads-1);

   -- GPR Bypass
   mux_cpl_ex4_rt                      : out std_ulogic_vector(64-regsize to 63);
   byp_ex5_mtcrxer                     : out std_ulogic_vector(32 to 63);
   byp_ex5_tlb_rt                      : out std_ulogic_vector(51 to 51);
   byp_spr_ex6_rt                      : out std_ulogic_vector(64-regsize to 63);
   xu_lsu_ex1_store_data               : out std_ulogic_vector(64-regsize to 63);
   fxu_spr_ex1_rs2                     : out std_ulogic_vector(42 to 55);
   fxu_spr_ex1_rs1                     : out std_ulogic_vector(54 to 63);
   fxu_spr_ex1_rs0                     : out std_ulogic_vector(52 to 63);   
   fxb_fxa_ex7_wd0                     : out std_ulogic_vector(64-regsize to 63);
   
   byp_grp0_debug                      : out std_ulogic_vector( 0 to 87);
   byp_grp1_debug                      : out std_ulogic_vector( 0 to 87);
   byp_grp2_debug                      : out std_ulogic_vector( 0 to 87);
   byp_grp3_debug                      : out std_ulogic_vector(15 to 87);
   byp_grp4_debug                      : out std_ulogic_vector(14 to 87);
   byp_grp5_debug                      : out std_ulogic_vector(15 to 87)
   );
    
--  synopsys translate_off
--  synopsys translate_on
end xuq_byp_gpr;
architecture xuq_byp_gpr of xuq_byp_gpr is

-- Latches                                                                                             Placed latches must have unique acts
signal exx_act_q,          exx_act_d               : std_ulogic_vector(0 to 6);              --                               act=>tiup
signal rf1_act_q                                   : std_ulogic;                             -- input=>dec_byp_rf0_act        act=>tiup,        sleep=>Y
signal rf1_is_mfocrf_q                             : std_ulogic;                             -- input=> fxa_fxb_rf0_is_mfocrf, act => tiup
signal ex1_rs0_u_b_q,      rf1_rs0_u               : std_ulogic_vector(64-regsize to 63);    --                               act=>rf1_act_q
signal ex1_rs0_l_b_q,      rf1_rs0_l               : std_ulogic_vector(64-regsize to 63);    --                               act=>rf1_act_q
signal ex1_rs1_u_b_q,      rf1_rs1_u               : std_ulogic_vector(64-regsize to 63);    --                               act=>rf1_act_q
signal ex1_rs1_l_b_q,      rf1_rs1_l               : std_ulogic_vector(64-regsize to 63);    --                               act=>rf1_act_q
signal ex1_rs1_nimm_b_q,   rf1_rs1_nimm            : std_ulogic_vector(59 to 63);            --                               act=>exx_act(0)
signal ex1_rs2_q,          rf1_rs2                 : std_ulogic_vector(64-regsize to 63);    --                               act=>exx_act(0)
signal ex1_do2_q                                   : std_ulogic_vector(64-regsize to 63);    -- input=>fxa_fxb_rf1_do2,       act=>exx_act(0)
signal ex1_rs2_gpr_sel_q,  ex1_rs2_gpr_sel_d       : std_ulogic_vector(0 to regsize/8-1);    --                               act=>exx_act(0)
signal ex1_rs2_rot_sel_q,  ex1_rs2_rot_sel_d       : std_ulogic_vector(0 to regsize/8-1);    --                               act=>exx_act(0)
signal ex1_log_sel_q                               : std_ulogic;                             -- input=>dec_alu_rf1_sel(2),    act=>exx_act(0)
signal ex1_msr_cm_q,       rf1_msr_cm              : std_ulogic_vector(0 to 3);              -- input=>rf1_msr_cm,            act=>exx_act(0)
signal ex2_rt_sel_q,       ex1_rt_sel              : std_ulogic_vector(0 to regsize/8-1);    --                               act=>exx_act(1),   scan=>N
signal ex2_rt_q,           ex1_rt                  : std_ulogic_vector(64-regsize to 63);    --                               act=>exx_act(1),   scan=>N
signal ex3_rt_q,           ex2_rt                  : std_ulogic_vector(64-regsize to 63);    --                               act=>exx_act(2)
signal ex4_rt_q,           ex3_rt                  : std_ulogic_vector(64-regsize to 63);    --                               act=>exx_act(3),   scan=>N
signal ex5_rt_q,           ex4_rt                  : std_ulogic_vector(64-regsize to 63);    --                               act=>exx_act(4)
signal ex6_rt_q,           ex5_rt                  : std_ulogic_vector(64-regsize to 63);    --                               act=>exx_act(5),   scan=>N
signal ex7_rt_q, ex7_rt_q_b,  ex6_rt               : std_ulogic_vector(64-regsize to 63);    --                               act=>exx_act(6)
signal ex7_rot_rt_q,       ex6_rot_rtu_b           : std_ulogic_vector(64-regsize to 63);    --                               act=>exx_act(6)
signal ex1_is_mfocrf_q,    ex1_is_mfocrf_d         : std_ulogic_vector(0 to regsize/8-1);    --                               act=>exx_act(0)
signal ex2_spr_sel_q                               : std_ulogic;                             -- input=>dec_byp_ex1_spr_sel,   act=>exx_act(1)
signal ex3_spr_sel_q                               : std_ulogic;                             -- input=>ex2_spr_sel_q,         act=>exx_act(2)
signal ex3_div_done_q,     ex3_div_done_d          : std_ulogic_vector(0 to regsize/8-1);    --                               act=>exx_act(2)
signal ex4_spr_sel_q,      ex4_spr_sel_d           : std_ulogic_vector(0 to regsize/8-1);    --                               act=>exx_act(3),   scan=>N
signal ex4_spr_rt_q,       ex4_spr_rt_d            : std_ulogic_vector(64-regsize to 63);    --                               act=>exx_act(3),   scan=>N
signal ex4_tlb_sel_q                               : std_ulogic_vector(0 to 1);              -- input=>dec_byp_ex3_tlb_sel    act=>exx_act(3),   scan=>N
signal ex5_is_mfxer_q,     ex5_is_mfxer_d          : std_ulogic_vector(0 to regsize/8-1);    --                               act=>exx_act(4)
signal ex5_is_mfcr_q,      ex5_is_mfcr_d           : std_ulogic_vector(0 to regsize/8-1);    --                               act=>exx_act(4)
signal ex5_mul_done_q,     ex5_mul_done_d          : std_ulogic_vector(0 to regsize/8-1);    --                               act=>exx_act(4)
signal ex5_dtlb_sel_q,     ex5_dtlb_sel_d          : std_ulogic_vector(0 to regsize/8-1);    --                               act=>exx_act(4)
signal ex5_itlb_sel_q,     ex5_itlb_sel_d          : std_ulogic_vector(0 to regsize/8-1);    --                               act=>exx_act(4)
signal ex5_tlb_data_iu_q                           : std_ulogic_vector(64-regsize to 63);    -- input=>iu_xu_ex4_tlb_data     act=>exx_act(4)
signal ex5_tlb_data_lsu_q                          : std_ulogic_vector(64-regsize to 63);    -- input=>lsu_xu_ex4_tlb_data    act=>exx_act(4)
signal ex5_slowspr_sel_q,  ex5_slowspr_sel_d       : std_ulogic_vector(0 to regsize/8-1);    --                               act=>ex4_slowspr_act
signal ex5_ones_sel_q,     ex5_ones_sel_d          : std_ulogic_vector(0 to regsize/8-1);    --                               act=>ex4_slowspr_act
signal ex5_slowspr_val_q                           : std_ulogic;                             -- input=>slowspr_val_in         act=>tiup
signal ex5_slowspr_data_q                          : std_ulogic_vector(64-regsize to 63);    -- input=>slowspr_data_in        act=>ex4_slowspr_act
signal ex5_slowspr_tid_q,  ex5_slowspr_tid_d       : std_ulogic_vector(0 to 3);              --                               act=>ex4_slowspr_act
signal ex5_slowspr_addr_q                          : std_ulogic_vector(0 to 9);              -- input=>slowspr_addr_in,       act=>ex4_slowspr_act
signal ex5_slowspr_wr_val_q,ex5_slowspr_wr_val_d   : std_ulogic;                             --                               act=>tiup
signal ex6_slowspr_flush_q,ex6_slowspr_flush_d     : std_ulogic_vector(0 to threads-1);      --                               act=>tiup
signal ex4_dcr_act_q                               : std_ulogic;                             -- input=>an_ac_dcr_act,         act=>tiup
signal ex5_dcr_sel_q,      ex5_dcr_sel_d           : std_ulogic_vector(0 to regsize/8-1);    --                               act=>exx_act(4)
signal ex5_dcr_ack_q                               : std_ulogic;                             -- input=>dec_byp_ex4_dcr_ack             act=>tiup
signal ex5_dcr_data_q                              : std_ulogic_vector(64-regsize to 63);    -- input=>an_ac_dcr_data,        act=>ex4_dcr_act_q
signal ex5_dcr_tid_q,      ex5_dcr_tid_d           : std_ulogic_vector(0 to 3);              --                               act=>ex4_dcr_act_q
signal ex6_lsu_wren_q,     ex6_lsu_wren_d          : std_ulogic_vector(0 to regsize/8);      --                               act=>exx_act(5),   scan=>N
signal ex3_derat_epn_q,    ex3_derat_epn_d         : std_ulogic_vector(62-eff_ifar to 51);   --                               act=>exx_act(2)
signal spr_msr_cm_q                                : std_ulogic_vector(0 to threads-1);      -- input=>spr_msr_cm             act=>tiup
signal trace_bus_enable_q                          : std_ulogic;                             -- input=>pc_xu_trace_bus_enable,                              sleep=>Y,   needs_sreset=>0
signal ex4_instr_trace_val_q                       : std_ulogic;                        -- input=>dec_byp_ex3_instr_trace_val,act=>trace_bus_enable_q,      sleep=>Y,   needs_sreset=>0
signal ex5_instr_trace_val_q                       : std_ulogic;                        -- input=>ex4_instr_trace_val_q,      act=>trace_bus_enable_q,      sleep=>Y,   needs_sreset=>0
signal ex4_instr_trace_gate_q                      : std_ulogic;                          -- input=>dec_byp_ex3_instr_trace_gate,act=>trace_bus_enable_q,      sleep=>Y,   needs_sreset=>0
signal ex5_instr_trace_gate_q, ex5_instr_trace_gate_d : std_ulogic_vector(0 to 3);        -- input=>ex5_instr_trace_gate_d,        act=>trace_bus_enable_q,      sleep=>Y,   needs_sreset=>0
signal ex1_rs0_sel_dbg_q                           : std_ulogic_vector(1 to 9);              -- input=>dec_byp_rf1_rs0_sel,   act=>trace_bus_enable_q,      sleep=>Y,   needs_sreset=>0
signal ex1_rs1_sel_dbg_q                           : std_ulogic_vector(1 to 10);             -- input=>dec_byp_rf1_rs1_sel,   act=>trace_bus_enable_q,      sleep=>Y,   needs_sreset=>0
signal ex1_rs2_sel_dbg_q                           : std_ulogic_vector(1 to 9);              -- input=>dec_byp_rf1_rs2_sel,   act=>trace_bus_enable_q,      sleep=>Y,   needs_sreset=>0
signal spare_0_q,                 spare_0_d        : std_ulogic_vector(0 to 15);               -- input=>spare_0_d,             act=>tiup,
signal spare_1_q,                 spare_1_d        : std_ulogic_vector(0 to 15);               -- input=>spare_1_d,             act=>tiup,
signal spare_2_q,                 spare_2_d        : std_ulogic_vector(0 to 15);               -- input=>spare_2_d,             act=>tiup,
signal spare_3_q,                 spare_3_d        : std_ulogic_vector(0 to 15);               -- input=>spare_3_d,             act=>tiup,
signal spare_4_q,                 spare_4_d        : std_ulogic_vector(0 to 15);               -- input=>spare_4_d,             act=>tiup,

-- Scanchains
constant exx_act_offset                            : integer := 0;
constant rf1_act_offset                            : integer := exx_act_offset                 + exx_act_q'length;
constant rf1_is_mfocrf_offset                      : integer := rf1_act_offset                 + 1;
constant ex1_rs0_u_b_offset                        : integer := rf1_is_mfocrf_offset           + 1;
constant ex1_rs0_l_b_offset                        : integer := ex1_rs0_u_b_offset             + ex1_rs0_u_b_q'length;
constant ex1_rs1_u_b_offset                        : integer := ex1_rs0_l_b_offset             + ex1_rs0_l_b_q'length;
constant ex1_rs1_l_b_offset                        : integer := ex1_rs1_u_b_offset             + ex1_rs1_u_b_q'length;
constant ex1_rs1_nimm_b_offset                     : integer := ex1_rs1_l_b_offset             + ex1_rs1_l_b_q'length;
constant ex1_rs2_offset                            : integer := ex1_rs1_nimm_b_offset          + ex1_rs1_nimm_b_q'length;
constant ex1_do2_offset                            : integer := ex1_rs2_offset                 + ex1_rs2_q'length;
constant ex1_rs2_gpr_sel_offset                    : integer := ex1_do2_offset                 + ex1_do2_q'length;
constant ex1_rs2_rot_sel_offset                    : integer := ex1_rs2_gpr_sel_offset         + ex1_rs2_gpr_sel_q'length;
constant ex1_log_sel_offset                        : integer := ex1_rs2_rot_sel_offset         + ex1_rs2_rot_sel_q'length;
constant ex1_msr_cm_offset                         : integer := ex1_log_sel_offset             + 1;
constant ex3_rt_offset                             : integer := ex1_msr_cm_offset              + ex1_msr_cm_q'length;
constant ex5_rt_offset                             : integer := ex3_rt_offset                  + ex3_rt_q'length;
constant ex7_rt_offset                             : integer := ex5_rt_offset                  + ex5_rt_q'length;
constant ex7_rot_rt_offset                         : integer := ex7_rt_offset                  + ex7_rt_q'length;
constant ex1_is_mfocrf_offset                      : integer := ex7_rot_rt_offset              + ex7_rot_rt_q'length;
constant ex2_spr_sel_offset                        : integer := ex1_is_mfocrf_offset           + ex1_is_mfocrf_q'length;
constant ex3_spr_sel_offset                        : integer := ex2_spr_sel_offset             + 1;
constant ex3_div_done_offset                       : integer := ex3_spr_sel_offset             + 1;
constant ex5_is_mfxer_offset                       : integer := ex3_div_done_offset            + ex3_div_done_q'length;
constant ex5_is_mfcr_offset                        : integer := ex5_is_mfxer_offset            + ex5_is_mfxer_q'length;
constant ex5_mul_done_offset                       : integer := ex5_is_mfcr_offset             + ex5_is_mfcr_q'length;
constant ex5_dtlb_sel_offset                       : integer := ex5_mul_done_offset            + ex5_mul_done_q'length;
constant ex5_itlb_sel_offset                       : integer := ex5_dtlb_sel_offset            + ex5_dtlb_sel_q'length;
constant ex5_tlb_data_iu_offset                    : integer := ex5_itlb_sel_offset            + ex5_itlb_sel_q'length;
constant ex5_tlb_data_lsu_offset                   : integer := ex5_tlb_data_iu_offset         + ex5_tlb_data_iu_q'length;
constant ex5_slowspr_sel_offset                    : integer := ex5_tlb_data_lsu_offset        + ex5_tlb_data_lsu_q'length;
constant ex5_ones_sel_offset                       : integer := ex5_slowspr_sel_offset         + ex5_slowspr_sel_q'length;
constant ex5_slowspr_val_offset                    : integer := ex5_ones_sel_offset            + ex5_ones_sel_q'length;
constant ex5_slowspr_data_offset                   : integer := ex5_slowspr_val_offset         + 1;
constant ex5_slowspr_tid_offset                    : integer := ex5_slowspr_data_offset        + ex5_slowspr_data_q'length;
constant ex5_slowspr_addr_offset                   : integer := ex5_slowspr_tid_offset         + ex5_slowspr_tid_q'length;
constant ex5_slowspr_wr_val_offset                 : integer := ex5_slowspr_addr_offset        + ex5_slowspr_addr_q'length;
constant ex6_slowspr_flush_offset                  : integer := ex5_slowspr_wr_val_offset      + 1;
constant ex4_dcr_act_offset                        : integer := ex6_slowspr_flush_offset       + ex6_slowspr_flush_q'length;
constant ex5_dcr_sel_offset                        : integer := ex4_dcr_act_offset             + 1;
constant ex5_dcr_ack_offset                        : integer := ex5_dcr_sel_offset             + ex5_dcr_sel_q'length;
constant ex5_dcr_data_offset                       : integer := ex5_dcr_ack_offset             + 1;
constant ex5_dcr_tid_offset                        : integer := ex5_dcr_data_offset            + ex5_dcr_data_q'length;
constant ex3_derat_epn_offset                      : integer := ex5_dcr_tid_offset             + ex5_dcr_tid_q'length;
constant spr_msr_cm_offset                         : integer := ex3_derat_epn_offset           + ex3_derat_epn_q'length;
constant trace_bus_enable_offset                   : integer := spr_msr_cm_offset              + spr_msr_cm_q'length;
constant ex4_instr_trace_val_offset                : integer := trace_bus_enable_offset        + 1;
constant ex5_instr_trace_val_offset                : integer := ex4_instr_trace_val_offset     + 1;
constant ex4_instr_trace_gate_offset               : integer := ex5_instr_trace_val_offset     + 1;
constant ex5_instr_trace_gate_offset               : integer := ex4_instr_trace_gate_offset    + 1;
constant ex1_rs0_sel_dbg_offset                    : integer := ex5_instr_trace_gate_offset    + ex5_instr_trace_gate_q'length;
constant ex1_rs1_sel_dbg_offset                    : integer := ex1_rs0_sel_dbg_offset         + ex1_rs0_sel_dbg_q'length;
constant ex1_rs2_sel_dbg_offset                    : integer := ex1_rs1_sel_dbg_offset         + ex1_rs1_sel_dbg_q'length;
constant spare_0_offset                            : integer := ex1_rs2_sel_dbg_offset         + ex1_rs2_sel_dbg_q'length;
constant spare_1_offset                            : integer := spare_0_offset                 + spare_0_q'length;
constant spare_2_offset                            : integer := spare_1_offset                 + spare_1_q'length;
constant spare_3_offset                            : integer := spare_2_offset                 + spare_2_q'length;
constant spare_4_offset                            : integer := spare_3_offset                 + spare_3_q'length;
constant scan_right                                : integer := spare_4_offset                 + spare_4_q'length;

signal siv                                         : std_ulogic_vector(0 to scan_right-1);
signal sov                                         : std_ulogic_vector(0 to scan_right-1);
-- Signals
signal tiup                                        : std_ulogic;
signal tidn                                        : std_ulogic_vector(0 to 63);
signal spare_0_lclk                                : clk_logic;
signal spare_1_lclk                                : clk_logic;
signal spare_2_lclk                                : clk_logic;
signal spare_3_lclk                                : clk_logic;
signal spare_4_lclk                                : clk_logic;
signal spare_0_d1clk, spare_0_d2clk                : std_ulogic;
signal spare_1_d1clk, spare_1_d2clk                : std_ulogic;
signal spare_2_d1clk, spare_2_d2clk                : std_ulogic;
signal spare_3_d1clk, spare_3_d2clk                : std_ulogic;
signal spare_4_d1clk, spare_4_d2clk                : std_ulogic;
signal ex1x_d1clk, ex1x_d2clk                      :std_ulogic  ;
signal ex1x_lclk                                   :clk_logic  ;
signal ex1_d1clk,  ex1_d2clk                       :std_ulogic  ;
signal ex1_lclk                                    :clk_logic  ;
signal ex1_slp_d1clk,  ex1_slp_d2clk               :std_ulogic  ;
signal ex1_slp_lclk                                :clk_logic  ;
signal ex7_d1clk,  ex7_d2clk                       :std_ulogic  ;
signal ex7_lclk                                    :clk_logic  ;
signal exx_act                                     : std_ulogic_vector(0 to 6);
signal rf1_rot_rs0_sel_b                           : std_ulogic_vector(64-regsize to 63);
signal rf1_rot_rs1_sel_b                           : std_ulogic_vector(64-regsize to 63);
signal rf1_rot_nimm_rs1_sel_b                      : std_ulogic_vector(59 to 63);
signal rf1_oth_rs0,        rf1_oth_rs0_b           : std_ulogic_vector(64-regsize to 63);
signal rf1_oth_rs1,        rf1_oth_rs1_b           : std_ulogic_vector(64-regsize to 63);
signal rf1_nlsu_rs0,       rf1_nlsu_rs0_b          : std_ulogic_vector(64-regsize to 63);
signal rf1_nlsu_rs1,       rf1_nlsu_rs1_b          : std_ulogic_vector(64-regsize to 63);
signal rf1_nimm_rs1,       rf1_nimm_rs1_b          : std_ulogic_vector(59 to 63);
signal rf1_gpr_rs0_b                               : std_ulogic_vector(64-regsize to 63);
signal rf1_gpr_rs1_b                               : std_ulogic_vector(64-regsize to 63);
signal rf1_imm_rs1_b                               : std_ulogic_vector(64-regsize to 63);
signal rf1_gpr_nimm_rs1_b, rf1_oth_nimm_rs1_b      : std_ulogic_vector(59 to 63);
signal ex1_lsu_src0_i1                             : std_ulogic_vector(64-regsize to 63);
signal ex1_lsu_src1_i1                             : std_ulogic_vector(64-regsize to 63);
signal ex1_lsu_src0_i1_b                           : std_ulogic_vector(64-regsize to 63);
signal ex1_lsu_src1_i1_b                           : std_ulogic_vector(64-regsize to 63);
signal ex6_rot_rtl_b , ex6_rot_rt                  : std_ulogic_vector(64-regsize to 63);
signal ex1_rs2                                     : std_ulogic_vector(64-regsize to 63);
signal ex4_ones_sel                                : std_ulogic;
signal ex4_slowspr_sel                             : std_ulogic;
signal ex4_dcr_sel                                 : std_ulogic;
signal ex5_rt_sel, ex5_nospr_rt_sel                : std_ulogic_vector(0 to regsize/8-1);
signal ex5_tlb_rt                                  : std_ulogic_vector(64-regsize to 63);
signal ex5_spr_rt, ex5_nospr_rt                    : std_ulogic_vector(64-regsize to 63);
signal ex5_cr                                      : std_ulogic_vector(64-regsize to 64);
signal ex5_xer                                     : std_ulogic_vector(64-regsize to 64);
signal ex6_xu_rt,          ex6_xu_rt_b             : std_ulogic_vector(64-regsize to 63);
signal ex6_lsu_wren_b                              : std_ulogic_vector(64-regsize to 63);
signal ex5_slowop_done                             : std_ulogic_vector(0 to 3);
signal ex2_msr_cm                                  : std_ulogic;
signal byp_rs0_debug, byp_rs1_debug, byp_rs2_debug : std_ulogic_vector(0 to 63);
signal byp_gpr_sel_debug                           : std_ulogic_vector(0 to 19);
signal dec_ex2_tid_int                             : std_ulogic_vector(0 to threads-1);
signal ex4_slowspr_act                             : std_ulogic;
signal ex5_slowspr_csync                           : std_ulogic;
signal ex5_rt_gated                                : std_ulogic_vector(64-regsize to 63);


begin


tiup                       <= '1';
tidn                       <= (others=>'0');

exx_act_d      <= dec_byp_rf0_act & exx_act(0 to 5);

exx_act(0)     <= exx_act_q(0);
exx_act(1)     <= exx_act_q(1);
exx_act(2)     <= exx_act_q(2) or alu_ex2_div_done;
exx_act(3)     <= exx_act_q(3);
exx_act(4)     <= exx_act_q(4) or alu_ex4_mul_done or dec_byp_ex4_dcr_ack;
exx_act(5)     <= exx_act_q(5) or ex5_slowspr_val_q;
exx_act(6)     <= exx_act_q(6);

ex4_slowspr_act <= '1'; 

---------------------------------------------------------------------
-- Result Muxing
---------------------------------------------------------------------

ex5_cr                     <= tidn(0 to regsize-32) & byp_ex5_cr_rt;
ex5_xer                    <= tidn(0 to regsize-32) & byp_ex5_xer_rt(54 to 56) & tidn(35 to 56) & byp_ex5_xer_rt(57 to 63);

ex4_spr_rt_d               <= spr_byp_ex3_spr_rt or cpl_byp_ex3_spr_rt or fspr_byp_ex3_spr_rt;

ex1_rt                     <= (ex1_mfocrf_rt          and     fanout(ex1_is_mfocrf_q,regsize)) or
                              (alu_byp_ex1_log_rt     and not fanout(ex1_is_mfocrf_q,regsize));

ex1_rt_sel                 <= (0 to regsize/8-1=>ex1_log_sel_q) or ex1_is_mfocrf_q;

ex2_rt                     <= (ex2_rt_q               and     fanout(ex2_rt_sel_q,regsize)) or
                              (alu_byp_ex2_rt         and not fanout(ex2_rt_sel_q,regsize));

ex3_rt                     <= (alu_byp_ex3_div_rt     and     fanout(ex3_div_done_q,regsize)) or
                              (ex3_rt_q               and not fanout(ex3_div_done_q,regsize));

ex4_rt                     <= (ex4_spr_rt_q           and     fanout(ex4_spr_sel_q, regsize)) or
                              (ex4_rt_q               and not fanout(ex4_spr_sel_q, regsize));


ex5_rt_sel                 <= not (ex5_dtlb_sel_q or 
                                   ex5_itlb_sel_q or 
                                   ex5_is_mfxer_q or 
                                   ex5_is_mfcr_q  or 
                                   ex5_mul_done_q);

ex5_nospr_rt_sel            <= not (ex5_slowspr_sel_q or 
                                    ex5_dcr_sel_q);

ex5_tlb_rt                 <= (ex5_tlb_data_lsu_q         and fanout(ex5_dtlb_sel_q,regsize)) or
                              (ex5_tlb_data_iu_q          and fanout(ex5_itlb_sel_q,regsize));

ex5_nospr_rt               <=  ex5_tlb_rt                                                     or
                              (ex5_xer(65-regsize to 64)  and fanout(ex5_is_mfxer_q,regsize)) or
                              (ex5_cr(65-regsize to 64)   and fanout(ex5_is_mfcr_q, regsize)) or
                              (alu_byp_ex5_mul_rt         and fanout(ex5_mul_done_q,regsize)) or
                              (ex5_rt_q                   and fanout(ex5_rt_sel,    regsize));

ex5_spr_rt                 <= (ex5_nospr_rt               and fanout(ex5_nospr_rt_sel, regsize)) or
                              (ex5_slowspr_data_q         and fanout(ex5_slowspr_sel_q,regsize)) or
                              (ex5_dcr_data_q             and fanout(ex5_dcr_sel_q,    regsize));

ex5_rt                     <=  ex5_spr_rt                 or  fanout(ex5_ones_sel_q,regsize);

ex6_lsu_wren_b             <=                             not fanout(ex6_lsu_wren_q(0 to 7),regsize);
ex6_xu_rt                  <= (ex6_rt_q and                          ex6_lsu_wren_b);
ex6_xu_rt_b                <= not ex6_xu_rt;

u_ex6_rt:  ex6_rt          <= (ex6_rot_rtu_b or ex6_lsu_wren_b) nand ex6_xu_rt_b;

---------------------------------------------------------------------
-- Result Outputs
---------------------------------------------------------------------
-- CPL needs SPR read data included for rfi's
mux_cpl_ex4_rt             <= ex4_rt;
byp_ex5_mtcrxer            <= ex5_rt_q(32 to 63);
byp_ex5_tlb_rt             <= ex5_tlb_rt(51 to 51);
byp_spr_ex6_rt             <= ex6_rt_q;
fxb_fxa_ex7_wd0            <= ex7_rt_q;

xu_pc_ram_data             <= ex6_rt_q;
mux_spr_ex6_rt             <= ex6_rt_q;
xu_ex4_rs_data             <= ex4_rt_q;

ex2_msr_cm                 <= or_reduce(spr_msr_cm_q and dec_ex2_tid);
ex3_derat_epn_d(62-eff_ifar to 31)   <= gate(ex2_rt(62-eff_ifar to 31),ex2_msr_cm);
ex3_derat_epn_d(32 to 51)            <=      ex2_rt(32 to 51);
xu_mm_derat_epn            <= ex3_derat_epn_q;


---------------------------------------------------------------------
-- Slow SPR
---------------------------------------------------------------------
with slowspr_etid_in select
   ex5_slowspr_tid_d       <= "1000" when "00",
                              "0100" when "01",
                              "0010" when "10",
                              "0001" when others;

with an_ac_dcr_etid select
   ex5_dcr_tid_d           <= "1000" when "00",
                              "0100" when "01",
                              "0010" when "10",
                              "0001" when others;

ex4_slowspr_sel            <= slowspr_val_in  and slowspr_rw_in  and     slowspr_done_in;
ex4_dcr_sel                <= dec_byp_ex4_dcr_ack      and an_ac_dcr_read and     an_ac_dcr_done;

ex4_ones_sel               <=(slowspr_val_in  and slowspr_rw_in  and not slowspr_done_in) or
                             (dec_byp_ex4_dcr_ack      and an_ac_dcr_read and not an_ac_dcr_done);

ex5_slowop_done            <=(ex5_slowspr_tid_q and (0 to 3=> ex5_slowspr_val_q)) or
                             (ex5_dcr_tid_q     and (0 to 3=> ex5_dcr_ack_q));
                             
ex5_slowspr_wr_val_d       <= slowspr_val_in and not slowspr_rw_in  and slowspr_done_in;
                             
ex5_slowspr_csync          <=(ex5_slowspr_addr_q(0 to 9) = "1111111101") or -- 1021 MMUCR1
                             (ex5_slowspr_addr_q(0 to 9) = "0000110000") or --   48 PID
                             (ex5_slowspr_addr_q(0 to 9) = "0101010010");   --  338 LPIDR
                             
ex6_slowspr_flush_d        <= gate(ex5_slowspr_tid_q,(ex5_slowspr_wr_val_q and ex5_slowspr_csync));

xu_iu_slowspr_done         <= ex5_slowop_done;
mux_cpl_slowspr_done       <= ex5_slowop_done;
mux_cpl_slowspr_flush      <= ex6_slowspr_flush_q;

---------------------------------------------------------------------
-- Mux Select Fanout
---------------------------------------------------------------------
ex1_is_mfocrf_d            <= (others=>rf1_is_mfocrf_q);
ex4_spr_sel_d              <= (others=>ex3_spr_sel_q);
ex3_div_done_d             <= (others=>alu_ex2_div_done);
ex5_dtlb_sel_d             <= (others=>ex4_tlb_sel_q(0));
ex5_itlb_sel_d             <= (others=>ex4_tlb_sel_q(1));
ex5_is_mfxer_d             <= (others=>or_reduce(spr_byp_ex4_is_mfxer));
ex5_is_mfcr_d              <= (others=>dec_byp_ex4_is_mfcr);
ex5_mul_done_d             <= (others=>alu_ex4_mul_done);
ex5_slowspr_sel_d          <= (others=>ex4_slowspr_sel);
ex5_dcr_sel_d              <= (others=>ex4_dcr_sel);
ex5_ones_sel_d             <= (others=>ex4_ones_sel);
ex6_lsu_wren_d             <= (others=>lsu_xu_ex5_wren);
ex5_instr_trace_gate_d     <= (others=>ex4_instr_trace_gate_q);

ex1_rs2_gpr_sel_d          <= (others=>dec_byp_rf1_rs2_sel(9));
ex1_rs2_rot_sel_d          <= (others=>(ex6_lsu_wren_q(8) and dec_byp_rf1_rs2_sel(6)));

-- rf1_rsX_byp_pri:
-- (0) Zeros
-- (1) EX1
-- (2) EX2
-- (3) EX3
-- (4) EX4
-- (5) EX5
-- (6) EX6
-- (7) EX7
-- (8) Rel
-- (.) GPR/Imm
-- (.) GPR

---------------------------------------------------------------------
-- Source 0
---------------------------------------------------------------------
rf1_oth_rs0             <= gate(ex1_rt,               dec_byp_rf1_rs0_sel(1)) or
                           gate(ex2_rt,               dec_byp_rf1_rs0_sel(2)) or
                           gate(ex3_rt,               dec_byp_rf1_rs0_sel(3)) or
                           gate(ex4_rt,               dec_byp_rf1_rs0_sel(4)) or
                           gate(ex5_rt,               dec_byp_rf1_rs0_sel(5)) or
                           gate(ex6_xu_rt,            dec_byp_rf1_rs0_sel(6)) or
                           gate(ex7_rt_q,             dec_byp_rf1_rs0_sel(7)) or
                           gate(lsu_xu_rot_rel_data,  dec_byp_rf1_rs0_sel(8));
                           
rf1_oth_rs0_b           <= not rf1_oth_rs0;

rf1_rot_rs0_sel_b       <= (others=>(ex6_lsu_wren_q(8) nand dec_byp_rf1_rs0_sel(6)));

                        
u_rf1_gpr_rs0_b:   rf1_gpr_rs0_b    <= fxa_fxb_rf1_do0  nand (0 to 63=> dec_byp_rf1_rs0_sel(9));

u_rf1_nlsu_rs0:    rf1_nlsu_rs0     <= rf1_gpr_rs0_b    nand rf1_oth_rs0_b;

u_rf1_nlsu_rs0_b:  rf1_nlsu_rs0_b   <= not(rf1_nlsu_rs0);

u_rf1_rs0_u_sel:   rf1_rs0_u        <= (ex6_rot_rtu_b or rf1_rot_rs0_sel_b) nand rf1_nlsu_rs0_b;
u_rf1_rs0_l_sel:   rf1_rs0_l        <= (ex6_rot_rtl_b or rf1_rot_rs0_sel_b) nand rf1_nlsu_rs0_b;

---------------------------------------------------------------------
-- Source 1
---------------------------------------------------------------------
rf1_oth_rs1             <= gate(ex1_rt,               dec_byp_rf1_rs1_sel(1)) or
                           gate(ex2_rt,               dec_byp_rf1_rs1_sel(2)) or
                           gate(ex3_rt,               dec_byp_rf1_rs1_sel(3)) or
                           gate(ex4_rt,               dec_byp_rf1_rs1_sel(4)) or
                           gate(ex5_rt,               dec_byp_rf1_rs1_sel(5)) or
                           gate(ex6_xu_rt,            dec_byp_rf1_rs1_sel(6)) or
                           gate(ex7_rt_q,             dec_byp_rf1_rs1_sel(7)) or
                           gate(lsu_xu_rot_rel_data,  dec_byp_rf1_rs1_sel(8));

rf1_rot_nimm_rs1_sel_b  <= (others=>not((ex6_lsu_wren_q(8) and dec_byp_rf1_rs1_sel(6))));
rf1_rot_rs1_sel_b       <= (others=>not((ex6_lsu_wren_q(8) and dec_byp_rf1_rs1_sel(6) and not dec_byp_rf1_rs1_sel(10))));

u_rf1_oth_nimm_rs1_b:
                   rf1_oth_nimm_rs1_b  <= not(rf1_oth_rs1(59 to 63));
u_rf1_oth_rs1_b:   rf1_oth_rs1_b       <=     rf1_oth_rs1            nand (0 to 63=>not(dec_byp_rf1_rs1_sel(10)));

u_rf1_gpr_nimm_rs1_b:
                   rf1_gpr_nimm_rs1_b  <= fxa_fxb_rf1_do1(59 to 63)  nand (59 to 63=> dec_byp_rf1_rs1_sel(9));
u_rf1_gpr_rs1_b:   rf1_gpr_rs1_b       <= fxa_fxb_rf1_do1            nand (0 to 63=>(dec_byp_rf1_rs1_sel(9) and not dec_byp_rf1_rs1_sel(10)));

u_rf1_imm_rs1_b:   rf1_imm_rs1_b       <= dec_byp_rf1_imm            nand (0 to 63=> dec_byp_rf1_rs1_sel(10));

u_rf1_nimm_rs1:    rf1_nimm_rs1     <= not(rf1_gpr_nimm_rs1_b(59 to 63)  and rf1_oth_nimm_rs1_b(59 to 63));
u_rf1_nlsu_rs1:    rf1_nlsu_rs1     <= not(rf1_gpr_rs1_b                 and rf1_oth_rs1_b            and rf1_imm_rs1_b);

u_rf1_nimm_rs1_b:  rf1_nimm_rs1_b   <= not(rf1_nimm_rs1);
u_rf1_nlsu_rs1_b:  rf1_nlsu_rs1_b   <= not(rf1_nlsu_rs1);

u_rf1_rs1_u_sel: rf1_rs1_u   <= (ex6_rot_rtu_b or rf1_rot_rs1_sel_b) nand rf1_nlsu_rs1_b;
u_rf1_rs1_l_sel: rf1_rs1_l   <= (ex6_rot_rtl_b or rf1_rot_rs1_sel_b) nand rf1_nlsu_rs1_b;

-- RA Entry Garbage.  For eratwe, I want RS to go down the pipe, but still need RA to go to the erats.
u_rf1_rs1_nimm: rf1_rs1_nimm <= (ex6_rot_rtu_b(59 to 63) or rf1_rot_nimm_rs1_sel_b(59 to 63)) nand rf1_nimm_rs1_b(59 to 63);

---------------------------------------------------------------------
-- Source 2
---------------------------------------------------------------------
rf1_rs2                 <= gate(ex1_rt,               dec_byp_rf1_rs2_sel(1)) or
                           gate(ex2_rt,               dec_byp_rf1_rs2_sel(2)) or
                           gate(ex3_rt,               dec_byp_rf1_rs2_sel(3)) or
                           gate(ex4_rt,               dec_byp_rf1_rs2_sel(4)) or
                           gate(ex5_rt,               dec_byp_rf1_rs2_sel(5)) or
                           gate(ex6_xu_rt,            dec_byp_rf1_rs2_sel(6)) or
                           gate(ex7_rt_q,             dec_byp_rf1_rs2_sel(7)) or
                           gate(lsu_xu_rot_rel_data,  dec_byp_rf1_rs2_sel(8));

ex1_rs2                 <= (ex1_do2_q     and fanout(ex1_rs2_gpr_sel_q,regsize)) or
                           (ex7_rot_rt_q  and fanout(ex1_rs2_rot_sel_q,regsize)) or
                            ex1_rs2_q;

---------------------------------------------------------------------
-- Assign output
---------------------------------------------------------------------
xu_ex1_rs_is            <= ex1_rs2(55 to 63);
xu_lsu_ex1_store_data   <= ex1_rs2;
fxu_spr_ex1_rs2         <= ex1_rs2(42 to 55);
xu_ex1_ra_entry         <= not ex1_rs1_nimm_b_q(59 to 63);

rf1_msr_cm                    <=(others=>or_reduce(spr_msr_cm_q and dec_rf1_tid));
xu_ex1_rb(64-regsize to 31)   <=(not ex1_rs1_u_b_q(64-regsize to 31)) and fanout(ex1_msr_cm_q,32);
xu_ex1_rb(32 to 51)           <= not ex1_rs1_u_b_q(32 to 51);

u_rot_rt_i1:      ex6_rot_rt                  <= not lsu_xu_rot_ex6_data_b;
u_rot_rt_i2u:     ex6_rot_rtu_b               <= not ex6_rot_rt           ;
u_rot_rt_i2l:     ex6_rot_rtl_b               <= not ex6_rot_rt           ;

u_rs0_i1:         byp_alu_ex1_rs0             <= not ex1_rs0_u_b_q; 
u_rs1_i1:         byp_alu_ex1_rs1             <= not ex1_rs1_u_b_q; 


u_lsu_src0_i1:    ex1_lsu_src0_i1             <= not ex1_rs0_l_b_q;               
                  xu_lsu_ex1_add_src0         <=     ex1_lsu_src0_i1;             
u_lsu_src0_i2:    ex1_lsu_src0_i1_b           <= not ex1_lsu_src0_i1;             
                  byp_alu_ex1_mulsrc_0        <= not ex1_lsu_src0_i1_b;           
                  byp_alu_ex1_divsrc_0        <= not ex1_lsu_src0_i1_b;           
                  fxu_spr_ex1_rs0             <= not ex1_lsu_src0_i1_b(52 to 63); 
		

u_lsu_src1_i1:    ex1_lsu_src1_i1             <= not ex1_rs1_l_b_q;               
                  xu_lsu_ex1_add_src1         <=     ex1_lsu_src1_i1;             
u_lsu_src1_i2:    ex1_lsu_src1_i1_b           <= not ex1_lsu_src1_i1;             
                  byp_alu_ex1_mulsrc_1        <= not ex1_lsu_src1_i1_b;           
                  byp_alu_ex1_divsrc_1        <= not ex1_lsu_src1_i1_b;           
                  fxu_spr_ex1_rs1             <= not ex1_lsu_src1_i1_b(54 to 63);
                  
---------------------------------------------------------------------
-- Debug
---------------------------------------------------------------------
byp_rs0_debug        <= not ex1_rs0_u_b_q;
byp_rs1_debug        <= not ex1_rs1_u_b_q;
byp_rs2_debug        <= ex1_rs2;

byp_gpr_sel_debug    <= ex1_is_mfocrf_q(0)   &
                        ex1_log_sel_q        &
                        ex2_rt_sel_q(0)      &
                        ex3_div_done_q(0)    &
                        ex4_spr_sel_q(0)     &
                        ex5_dtlb_sel_q(0)    &
                        ex5_itlb_sel_q(0)    &
                        ex5_is_mfxer_q(0)    &
                        ex5_is_mfcr_q(0)     &
                        ex5_mul_done_q(0)    &
                        ex5_slowspr_sel_q(0) &
                        ex5_dcr_sel_q(0)     &
                        ex5_ones_sel_q(0)    &
                        ex6_lsu_wren_q(0)    &
                        ex5_dcr_ack_q        &
                        ex5_slowspr_val_q    &
                        ex5_slowop_done;

dec_ex2_tid_int(0)      <= dec_ex2_tid(0) and not ex5_instr_trace_val_q;
dec_ex2_tid_int(1 to 2) <= dec_ex2_tid(1 to 2);
dec_ex2_tid_int(3)      <= dec_ex2_tid(3) or ex5_instr_trace_val_q;

ex5_rt_gated(0 to 31)   <= ex5_rt_q(0 to 31) and not fanout(ex5_instr_trace_gate_q,regsize/2);
ex5_rt_gated(32 to 63)  <= ex5_rt_q(32 to 63);

--                      0:63          64:67
byp_grp0_debug    <= ex3_rt_q     & dec_ex2_tid     & byp_gpr_sel_debug;
byp_grp1_debug    <= ex5_rt_gated & dec_ex2_tid_int & byp_gpr_sel_debug;
byp_grp2_debug    <= ex7_rt_q     & dec_ex2_tid     & byp_gpr_sel_debug;
--                       [14]15:22          23:87
byp_grp3_debug    <= ex1_rs0_sel_dbg_q & byp_rs0_debug;  -- ex1_s1_q & ex1_ta_q(0 to 5) & ex1_gpr_we_q
byp_grp4_debug    <= ex1_rs1_sel_dbg_q & byp_rs1_debug;  -- ex1_s2_q & ex1_ta_q(0 to 5)
byp_grp5_debug    <= ex1_rs2_sel_dbg_q & byp_rs2_debug;  -- ex1_s3_q & ex1_ta_q(0 to 5) & ex1_gpr_we_q

trace_bus_enable  <= trace_bus_enable_q;

-- Misc
mark_unused(ex5_cr(64-regsize));
mark_unused(ex5_xer(64-regsize));
mark_unused(ex1_mfocrf_rt(64-regsize));
mark_unused(tidn(0 to 63));

---------------------------------------------------------------------
-- Latch Instances
---------------------------------------------------------------------
exx_act_latch : tri_rlmreg_p
  generic map (width => exx_act_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(exx_act_offset to exx_act_offset + exx_act_q'length-1),
            scout   => sov(exx_act_offset to exx_act_offset + exx_act_q'length-1),
            din     => exx_act_d,
            dout    => exx_act_q);
rf1_act_latch : tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup,
            forcee => func_slp_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_slp_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(rf1_act_offset),
            scout   => sov(rf1_act_offset),
            din     => dec_byp_rf0_act,
            dout    => rf1_act_q);
rf1_is_mfocrf_latch : tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(rf1_is_mfocrf_offset),
            scout   => sov(rf1_is_mfocrf_offset),
            din     => fxa_fxb_rf0_is_mfocrf,
            dout    => rf1_is_mfocrf_q);    
 
   ex1_rs0_u_b_lat: entity tri.tri_inv_nlats(tri_inv_nlats)                                                   
     generic map (width=>  ex1_rs0_l_b_q'length, btr => "NLI0001_X4_A12TH", expand_type => expand_type, needs_sreset => 1, init => (ex1_rs0_l_b_q'range=>'0') )  port map (  
        VD               => vdd                                                                              ,
        GD               => gnd                                                                              ,
        LCLK             => ex1_lclk                                                                         ,
        D1CLK            => ex1_d1clk                                                                        ,
        D2CLK            => ex1_d2clk                                                                        ,
        SCANIN           => siv(ex1_rs0_u_b_offset to ex1_rs0_u_b_offset + ex1_rs0_u_b_q'length-1)           ,
        SCANOUT          => sov(ex1_rs0_u_b_offset to ex1_rs0_u_b_offset + ex1_rs0_u_b_q'length-1)           ,
        D                => rf1_rs0_u                                                                        ,
        QB               => ex1_rs0_u_b_q                                                                   );

   ex1_rs0_l_b_lat: entity tri.tri_inv_nlats(tri_inv_nlats)                                                   
     generic map (width=>  ex1_rs0_l_b_q'length, btr => "NLI0001_X4_A12TH", expand_type => expand_type, needs_sreset => 1, init => (ex1_rs0_l_b_q'range=>'0') )  port map (  
        VD               => vdd                                                                              ,
        GD               => gnd                                                                              ,
        LCLK             => ex1_slp_lclk                                                                     ,
        D1CLK            => ex1_slp_d1clk                                                                    ,
        D2CLK            => ex1_slp_d2clk                                                                    ,
        SCANIN           => siv(ex1_rs0_l_b_offset to ex1_rs0_l_b_offset + ex1_rs0_l_b_q'length-1)           ,
        SCANOUT          => sov(ex1_rs0_l_b_offset to ex1_rs0_l_b_offset + ex1_rs0_l_b_q'length-1)           ,
        D                => rf1_rs0_l                                                                        ,
        QB               => ex1_rs0_l_b_q                                                                   );

   ex1_rs1_u_b_lat: entity tri.tri_inv_nlats(tri_inv_nlats)                                                   
     generic map (width=>  ex1_rs1_l_b_q'length, btr => "NLI0001_X4_A12TH", expand_type => expand_type, needs_sreset => 1, init => (ex1_rs1_l_b_q'range=>'0') )  port map (  
        VD               => vdd                                                                              ,
        GD               => gnd                                                                              ,
        LCLK             => ex1_lclk                                                                         ,
        D1CLK            => ex1_d1clk                                                                        ,
        D2CLK            => ex1_d2clk                                                                        ,
        SCANIN           => siv(ex1_rs1_u_b_offset to ex1_rs1_u_b_offset + ex1_rs1_u_b_q'length-1)           ,
        SCANOUT          => sov(ex1_rs1_u_b_offset to ex1_rs1_u_b_offset + ex1_rs1_u_b_q'length-1)           ,
        D                => rf1_rs1_u                                                                        ,
        QB               => ex1_rs1_u_b_q                                                                   );

   ex1_rs1_l_b_lat: entity tri.tri_inv_nlats(tri_inv_nlats)                                                   
     generic map (width=>  ex1_rs1_l_b_q'length, btr => "NLI0001_X4_A12TH", expand_type => expand_type, needs_sreset => 1, init => (ex1_rs1_l_b_q'range=>'0') )  port map (  
        VD               => vdd                                                                              ,
        GD               => gnd                                                                              ,
        LCLK             => ex1_slp_lclk                                                                     ,
        D1CLK            => ex1_slp_d1clk                                                                    ,
        D2CLK            => ex1_slp_d2clk                                                                    ,
        SCANIN           => siv(ex1_rs1_l_b_offset to ex1_rs1_l_b_offset + ex1_rs1_l_b_q'length-1)           ,
        SCANOUT          => sov(ex1_rs1_l_b_offset to ex1_rs1_l_b_offset + ex1_rs1_l_b_q'length-1)           ,
        D                => rf1_rs1_l                                                                        ,
        QB               => ex1_rs1_l_b_q                                                                   );

   ex1_rs1_nimm_b_lat: entity tri.tri_inv_nlats(tri_inv_nlats)                                                
     generic map (width=>  ex1_rs1_nimm_b_q'length, btr => "NLI0001_X1_A12TH", expand_type => expand_type, needs_sreset => 1, init => (ex1_rs1_nimm_b_q'range=>'0') ) port map (  
        VD               => vdd                                                                              ,
        GD               => gnd                                                                              ,
        LCLK             => ex1x_lclk                                                                        ,
        D1CLK            => ex1x_d1clk                                                                       ,
        D2CLK            => ex1x_d2clk                                                                       ,
        SCANIN           => siv(ex1_rs1_nimm_b_offset to ex1_rs1_nimm_b_offset + ex1_rs1_nimm_b_q'length-1)  ,
        SCANOUT          => sov(ex1_rs1_nimm_b_offset to ex1_rs1_nimm_b_offset + ex1_rs1_nimm_b_q'length-1)  ,
        D                => rf1_rs1_nimm                                                                     ,
        QB               => ex1_rs1_nimm_b_q                                                                );

ex1_rs2_latch : tri_rlmreg_p
  generic map (width => ex1_rs2_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => exx_act(0),
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex1_rs2_offset to ex1_rs2_offset + ex1_rs2_q'length-1),
            scout   => sov(ex1_rs2_offset to ex1_rs2_offset + ex1_rs2_q'length-1),
            din     => rf1_rs2,
            dout    => ex1_rs2_q);
ex1_do2_latch : tri_rlmreg_p
  generic map (width => ex1_do2_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => exx_act(0),
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex1_do2_offset to ex1_do2_offset + ex1_do2_q'length-1),
            scout   => sov(ex1_do2_offset to ex1_do2_offset + ex1_do2_q'length-1),
            din     => fxa_fxb_rf1_do2,
            dout    => ex1_do2_q);
ex1_rs2_gpr_sel_latch : tri_rlmreg_p
  generic map (width => ex1_rs2_gpr_sel_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => exx_act(0),
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex1_rs2_gpr_sel_offset to ex1_rs2_gpr_sel_offset + ex1_rs2_gpr_sel_q'length-1),
            scout   => sov(ex1_rs2_gpr_sel_offset to ex1_rs2_gpr_sel_offset + ex1_rs2_gpr_sel_q'length-1),
            din     => ex1_rs2_gpr_sel_d,
            dout    => ex1_rs2_gpr_sel_q);
ex1_log_sel_latch : tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => exx_act(0),
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex1_log_sel_offset),
            scout   => sov(ex1_log_sel_offset),
            din     => dec_alu_rf1_sel(2),
            dout    => ex1_log_sel_q);
ex1_rs2_rot_sel_latch : tri_rlmreg_p
  generic map (width => ex1_rs2_rot_sel_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => exx_act(0),
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex1_rs2_rot_sel_offset to ex1_rs2_rot_sel_offset + ex1_rs2_rot_sel_q'length-1),
            scout   => sov(ex1_rs2_rot_sel_offset to ex1_rs2_rot_sel_offset + ex1_rs2_rot_sel_q'length-1),
            din     => ex1_rs2_rot_sel_d,
            dout    => ex1_rs2_rot_sel_q);
ex1_msr_cm_latch : tri_rlmreg_p
  generic map (width => ex1_msr_cm_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => exx_act(0),
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex1_msr_cm_offset to ex1_msr_cm_offset + ex1_msr_cm_q'length-1),
            scout   => sov(ex1_msr_cm_offset to ex1_msr_cm_offset + ex1_msr_cm_q'length-1),
            din     => rf1_msr_cm,
            dout    => ex1_msr_cm_q);
ex2_rt_sel_latch : tri_regk
  generic map (width => ex2_rt_sel_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => exx_act(1),
            forcee => func_nsl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_nsl_thold_0_b,
            din     => ex1_rt_sel,
            dout    => ex2_rt_sel_q);
ex2_rt_latch : tri_regk
  generic map (width => ex2_rt_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => exx_act(1),
            forcee => func_nsl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_nsl_thold_0_b,
            din     => ex1_rt,
            dout    => ex2_rt_q);
ex3_rt_latch : tri_rlmreg_p
  generic map (width => ex3_rt_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => exx_act(2),
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex3_rt_offset to ex3_rt_offset + ex3_rt_q'length-1),
            scout   => sov(ex3_rt_offset to ex3_rt_offset + ex3_rt_q'length-1),
            din     => ex2_rt,
            dout    => ex3_rt_q);
ex4_rt_latch : tri_regk
  generic map (width => ex4_rt_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => exx_act(3),
            forcee => func_nsl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_nsl_thold_0_b,
            din     => ex3_rt,
            dout    => ex4_rt_q);
ex5_rt_latch : tri_rlmreg_p
  generic map (width => ex5_rt_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => exx_act(4),
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex5_rt_offset to ex5_rt_offset + ex5_rt_q'length-1),
            scout   => sov(ex5_rt_offset to ex5_rt_offset + ex5_rt_q'length-1),
            din     => ex4_rt,
            dout    => ex5_rt_q);
ex6_rt_latch : tri_regk
  generic map (width => ex6_rt_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => exx_act(5),
            forcee => func_nsl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_nsl_thold_0_b,
            din     => ex5_rt,
            dout    => ex6_rt_q);

   ex7_rt_lat: entity tri.tri_inv_nlats(tri_inv_nlats)                                          
     generic map (width=> ex7_rot_rt_q'length, btr => "NLI0001_X1_A12TH", expand_type => expand_type, needs_sreset => 1, init => (ex7_rot_rt_q'range=>'0') )    port map (  
        VD               => vdd                                                                ,
        GD               => gnd                                                                ,
        LCLK             => ex7_lclk                                                           ,
        D1CLK            => ex7_d1clk                                                          ,
        D2CLK            => ex7_d2clk                                                          ,
        SCANIN           => siv(ex7_rt_offset to ex7_rt_offset + ex7_rt_q'length-1)            ,
        SCANOUT          => sov(ex7_rt_offset to ex7_rt_offset + ex7_rt_q'length-1)            ,
        D                => ex6_rt                                                             ,
        QB               => ex7_rt_q_b                                                        );
	    
	    ex7_rt_q <= not ex7_rt_q_b ; 
	    
   ex7_rot_rt_lat: entity tri.tri_inv_nlats(tri_inv_nlats)                                      
     generic map (width=> ex7_rot_rt_q'length, btr => "NLI0001_X1_A12TH", expand_type => expand_type, needs_sreset => 1, init => (ex7_rot_rt_q'range=>'0') )    port map (  
        VD               => vdd                                                                ,
        GD               => gnd                                                                ,
        LCLK             => ex7_lclk                                                           ,
        D1CLK            => ex7_d1clk                                                          ,
        D2CLK            => ex7_d2clk                                                          ,
        SCANIN           => siv(ex7_rot_rt_offset to ex7_rot_rt_offset + ex7_rot_rt_q'length-1),
        SCANOUT          => sov(ex7_rot_rt_offset to ex7_rot_rt_offset + ex7_rot_rt_q'length-1),
        D                => ex6_rot_rtu_b                                                      ,
        QB               => ex7_rot_rt_q                                                      );
	    
	    
	    
ex1_is_mfocrf_latch : tri_rlmreg_p
  generic map (width => ex1_is_mfocrf_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => exx_act(0),
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex1_is_mfocrf_offset to ex1_is_mfocrf_offset + ex1_is_mfocrf_q'length-1),
            scout   => sov(ex1_is_mfocrf_offset to ex1_is_mfocrf_offset + ex1_is_mfocrf_q'length-1),
            din     => ex1_is_mfocrf_d,
            dout    => ex1_is_mfocrf_q);
ex2_spr_sel_latch : tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex2_spr_sel_offset),
            scout   => sov(ex2_spr_sel_offset),
            din     => dec_byp_ex1_spr_sel,
            dout    => ex2_spr_sel_q);
ex3_spr_sel_latch : tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => exx_act(2),
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex3_spr_sel_offset),
            scout   => sov(ex3_spr_sel_offset),
            din     => ex2_spr_sel_q,
            dout    => ex3_spr_sel_q);
ex3_div_done_latch : tri_rlmreg_p
  generic map (width => ex3_div_done_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => exx_act(2),
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex3_div_done_offset to ex3_div_done_offset + ex3_div_done_q'length-1),
            scout   => sov(ex3_div_done_offset to ex3_div_done_offset + ex3_div_done_q'length-1),
            din     => ex3_div_done_d,
            dout    => ex3_div_done_q);
ex4_spr_sel_latch : tri_regk
  generic map (width => ex4_spr_sel_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => exx_act(3),
            forcee => func_nsl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_nsl_thold_0_b,
            din     => ex4_spr_sel_d,
            dout    => ex4_spr_sel_q);
ex4_spr_rt_latch : tri_regk
  generic map (width => ex4_spr_rt_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => exx_act(3),
            forcee => func_nsl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_nsl_thold_0_b,
            din     => ex4_spr_rt_d,
            dout    => ex4_spr_rt_q);
ex4_tlb_sel_latch : tri_regk
  generic map (width => ex4_tlb_sel_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup,
            forcee => func_nsl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_nsl_thold_0_b,
            din     => dec_byp_ex3_tlb_sel,
            dout    => ex4_tlb_sel_q);
ex5_is_mfxer_latch : tri_rlmreg_p
  generic map (width => ex5_is_mfxer_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => exx_act(4),
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex5_is_mfxer_offset to ex5_is_mfxer_offset + ex5_is_mfxer_q'length-1),
            scout   => sov(ex5_is_mfxer_offset to ex5_is_mfxer_offset + ex5_is_mfxer_q'length-1),
            din     => ex5_is_mfxer_d,
            dout    => ex5_is_mfxer_q);
ex5_is_mfcr_latch : tri_rlmreg_p
  generic map (width => ex5_is_mfcr_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => exx_act(4),
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex5_is_mfcr_offset to ex5_is_mfcr_offset + ex5_is_mfcr_q'length-1),
            scout   => sov(ex5_is_mfcr_offset to ex5_is_mfcr_offset + ex5_is_mfcr_q'length-1),
            din     => ex5_is_mfcr_d,
            dout    => ex5_is_mfcr_q);
ex5_mul_done_latch : tri_rlmreg_p
  generic map (width => ex5_mul_done_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => exx_act(4),
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex5_mul_done_offset to ex5_mul_done_offset + ex5_mul_done_q'length-1),
            scout   => sov(ex5_mul_done_offset to ex5_mul_done_offset + ex5_mul_done_q'length-1),
            din     => ex5_mul_done_d,
            dout    => ex5_mul_done_q);
ex5_dtlb_sel_latch : tri_rlmreg_p
  generic map (width => ex5_dtlb_sel_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => exx_act(4),
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex5_dtlb_sel_offset to ex5_dtlb_sel_offset + ex5_dtlb_sel_q'length-1),
            scout   => sov(ex5_dtlb_sel_offset to ex5_dtlb_sel_offset + ex5_dtlb_sel_q'length-1),
            din     => ex5_dtlb_sel_d,
            dout    => ex5_dtlb_sel_q);
ex5_itlb_sel_latch : tri_rlmreg_p
  generic map (width => ex5_itlb_sel_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => exx_act(4),
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex5_itlb_sel_offset to ex5_itlb_sel_offset + ex5_itlb_sel_q'length-1),
            scout   => sov(ex5_itlb_sel_offset to ex5_itlb_sel_offset + ex5_itlb_sel_q'length-1),
            din     => ex5_itlb_sel_d,
            dout    => ex5_itlb_sel_q);
ex5_tlb_data_iu_latch : tri_rlmreg_p
  generic map (width => ex5_tlb_data_iu_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => exx_act(4),
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex5_tlb_data_iu_offset to ex5_tlb_data_iu_offset + ex5_tlb_data_iu_q'length-1),
            scout   => sov(ex5_tlb_data_iu_offset to ex5_tlb_data_iu_offset + ex5_tlb_data_iu_q'length-1),
            din     => iu_xu_ex4_tlb_data,
            dout    => ex5_tlb_data_iu_q);
ex5_tlb_data_lsu_latch : tri_rlmreg_p
  generic map (width => ex5_tlb_data_lsu_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => exx_act(4),
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex5_tlb_data_lsu_offset to ex5_tlb_data_lsu_offset + ex5_tlb_data_lsu_q'length-1),
            scout   => sov(ex5_tlb_data_lsu_offset to ex5_tlb_data_lsu_offset + ex5_tlb_data_lsu_q'length-1),
            din     => lsu_xu_ex4_tlb_data,
            dout    => ex5_tlb_data_lsu_q);
ex5_slowspr_sel_latch : tri_rlmreg_p
  generic map (width => ex5_slowspr_sel_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => ex4_slowspr_act,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex5_slowspr_sel_offset to ex5_slowspr_sel_offset + ex5_slowspr_sel_q'length-1),
            scout   => sov(ex5_slowspr_sel_offset to ex5_slowspr_sel_offset + ex5_slowspr_sel_q'length-1),
            din     => ex5_slowspr_sel_d,
            dout    => ex5_slowspr_sel_q);
ex5_ones_sel_latch : tri_rlmreg_p
  generic map (width => ex5_ones_sel_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => ex4_slowspr_act,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex5_ones_sel_offset to ex5_ones_sel_offset + ex5_ones_sel_q'length-1),
            scout   => sov(ex5_ones_sel_offset to ex5_ones_sel_offset + ex5_ones_sel_q'length-1),
            din     => ex5_ones_sel_d,
            dout    => ex5_ones_sel_q);
ex5_slowspr_val_latch : tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex5_slowspr_val_offset),
            scout   => sov(ex5_slowspr_val_offset),
            din     => slowspr_val_in,
            dout    => ex5_slowspr_val_q);
ex5_slowspr_data_latch : tri_rlmreg_p
  generic map (width => ex5_slowspr_data_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => ex4_slowspr_act,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex5_slowspr_data_offset to ex5_slowspr_data_offset + ex5_slowspr_data_q'length-1),
            scout   => sov(ex5_slowspr_data_offset to ex5_slowspr_data_offset + ex5_slowspr_data_q'length-1),
            din     => slowspr_data_in,
            dout    => ex5_slowspr_data_q);
ex5_slowspr_tid_latch : tri_rlmreg_p
  generic map (width => ex5_slowspr_tid_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => ex4_slowspr_act,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex5_slowspr_tid_offset to ex5_slowspr_tid_offset + ex5_slowspr_tid_q'length-1),
            scout   => sov(ex5_slowspr_tid_offset to ex5_slowspr_tid_offset + ex5_slowspr_tid_q'length-1),
            din     => ex5_slowspr_tid_d,
            dout    => ex5_slowspr_tid_q);
ex5_slowspr_addr_latch : tri_rlmreg_p
  generic map (width => ex5_slowspr_addr_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => ex4_slowspr_act,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex5_slowspr_addr_offset to ex5_slowspr_addr_offset + ex5_slowspr_addr_q'length-1),
            scout   => sov(ex5_slowspr_addr_offset to ex5_slowspr_addr_offset + ex5_slowspr_addr_q'length-1),
            din     => slowspr_addr_in,
            dout    => ex5_slowspr_addr_q);
ex5_slowspr_wr_val_latch : tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex5_slowspr_wr_val_offset),
            scout   => sov(ex5_slowspr_wr_val_offset),
            din     => ex5_slowspr_wr_val_d,
            dout    => ex5_slowspr_wr_val_q);
ex6_slowspr_flush_latch : tri_rlmreg_p
  generic map (width => ex6_slowspr_flush_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex6_slowspr_flush_offset to ex6_slowspr_flush_offset + ex6_slowspr_flush_q'length-1),
            scout   => sov(ex6_slowspr_flush_offset to ex6_slowspr_flush_offset + ex6_slowspr_flush_q'length-1),
            din     => ex6_slowspr_flush_d,
            dout    => ex6_slowspr_flush_q);
ex4_dcr_act_latch : tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex4_dcr_act_offset),
            scout   => sov(ex4_dcr_act_offset),
            din     => an_ac_dcr_act,
            dout    => ex4_dcr_act_q);
ex5_dcr_sel_latch : tri_rlmreg_p
  generic map (width => ex5_dcr_sel_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => exx_act(4),
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex5_dcr_sel_offset to ex5_dcr_sel_offset + ex5_dcr_sel_q'length-1),
            scout   => sov(ex5_dcr_sel_offset to ex5_dcr_sel_offset + ex5_dcr_sel_q'length-1),
            din     => ex5_dcr_sel_d,
            dout    => ex5_dcr_sel_q);
ex5_dcr_ack_latch : tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex5_dcr_ack_offset),
            scout   => sov(ex5_dcr_ack_offset),
            din     => dec_byp_ex4_dcr_ack,
            dout    => ex5_dcr_ack_q);
ex5_dcr_data_latch : tri_rlmreg_p
  generic map (width => ex5_dcr_data_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => ex4_dcr_act_q,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex5_dcr_data_offset to ex5_dcr_data_offset + ex5_dcr_data_q'length-1),
            scout   => sov(ex5_dcr_data_offset to ex5_dcr_data_offset + ex5_dcr_data_q'length-1),
            din     => an_ac_dcr_data,
            dout    => ex5_dcr_data_q);
ex5_dcr_tid_latch : tri_rlmreg_p
  generic map (width => ex5_dcr_tid_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => ex4_dcr_act_q,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex5_dcr_tid_offset to ex5_dcr_tid_offset + ex5_dcr_tid_q'length-1),
            scout   => sov(ex5_dcr_tid_offset to ex5_dcr_tid_offset + ex5_dcr_tid_q'length-1),
            din     => ex5_dcr_tid_d,
            dout    => ex5_dcr_tid_q);
ex6_lsu_wren_latch : tri_regk
  generic map (width => ex6_lsu_wren_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => exx_act(5),
            forcee => func_nsl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_nsl_thold_0_b,
            din     => ex6_lsu_wren_d,
            dout    => ex6_lsu_wren_q);
ex3_derat_epn_latch : tri_rlmreg_p
  generic map (width => ex3_derat_epn_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => exx_act(2),
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex3_derat_epn_offset to ex3_derat_epn_offset + ex3_derat_epn_q'length-1),
            scout   => sov(ex3_derat_epn_offset to ex3_derat_epn_offset + ex3_derat_epn_q'length-1),
            din     => ex3_derat_epn_d,
            dout    => ex3_derat_epn_q);
spr_msr_cm_latch : tri_rlmreg_p
  generic map (width => spr_msr_cm_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(spr_msr_cm_offset to spr_msr_cm_offset + spr_msr_cm_q'length-1),
            scout   => sov(spr_msr_cm_offset to spr_msr_cm_offset + spr_msr_cm_q'length-1),
            din     => spr_msr_cm,
            dout    => spr_msr_cm_q);
trace_bus_enable_latch : tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup,
            forcee => func_slp_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_slp_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(trace_bus_enable_offset),
            scout   => sov(trace_bus_enable_offset),
            din     => pc_xu_trace_bus_enable,
            dout    => trace_bus_enable_q);
ex4_instr_trace_val_latch : tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => trace_bus_enable_q,
            forcee => func_slp_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_slp_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex4_instr_trace_val_offset),
            scout   => sov(ex4_instr_trace_val_offset),
            din     => dec_byp_ex3_instr_trace_val,
            dout    => ex4_instr_trace_val_q);
ex5_instr_trace_val_latch : tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => trace_bus_enable_q,
            forcee => func_slp_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_slp_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex5_instr_trace_val_offset),
            scout   => sov(ex5_instr_trace_val_offset),
            din     => ex4_instr_trace_val_q,
            dout    => ex5_instr_trace_val_q);
ex4_instr_trace_gate_latch : tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => trace_bus_enable_q,
            forcee => func_slp_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_slp_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex4_instr_trace_gate_offset),
            scout   => sov(ex4_instr_trace_gate_offset),
            din     => dec_byp_ex3_instr_trace_gate,
            dout    => ex4_instr_trace_gate_q);
ex5_instr_trace_gate_latch : tri_rlmreg_p
  generic map (width => ex5_instr_trace_gate_q'length, init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => trace_bus_enable_q,
            forcee => func_slp_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_slp_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex5_instr_trace_gate_offset to ex5_instr_trace_gate_offset + ex5_instr_trace_gate_q'length-1),
            scout   => sov(ex5_instr_trace_gate_offset to ex5_instr_trace_gate_offset + ex5_instr_trace_gate_q'length-1),
            din     => ex5_instr_trace_gate_d,
            dout    => ex5_instr_trace_gate_q);
ex1_rs0_sel_dbg_latch : tri_rlmreg_p
  generic map (width => ex1_rs0_sel_dbg_q'length, init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => trace_bus_enable_q,
            forcee => func_slp_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_slp_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex1_rs0_sel_dbg_offset to ex1_rs0_sel_dbg_offset + ex1_rs0_sel_dbg_q'length-1),
            scout   => sov(ex1_rs0_sel_dbg_offset to ex1_rs0_sel_dbg_offset + ex1_rs0_sel_dbg_q'length-1),
            din     => dec_byp_rf1_rs0_sel,
            dout    => ex1_rs0_sel_dbg_q);
ex1_rs1_sel_dbg_latch : tri_rlmreg_p
  generic map (width => ex1_rs1_sel_dbg_q'length, init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => trace_bus_enable_q,
            forcee => func_slp_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_slp_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex1_rs1_sel_dbg_offset to ex1_rs1_sel_dbg_offset + ex1_rs1_sel_dbg_q'length-1),
            scout   => sov(ex1_rs1_sel_dbg_offset to ex1_rs1_sel_dbg_offset + ex1_rs1_sel_dbg_q'length-1),
            din     => dec_byp_rf1_rs1_sel,
            dout    => ex1_rs1_sel_dbg_q);
ex1_rs2_sel_dbg_latch : tri_rlmreg_p
  generic map (width => ex1_rs2_sel_dbg_q'length, init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => trace_bus_enable_q,
            forcee => func_slp_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_slp_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex1_rs2_sel_dbg_offset to ex1_rs2_sel_dbg_offset + ex1_rs2_sel_dbg_q'length-1),
            scout   => sov(ex1_rs2_sel_dbg_offset to ex1_rs2_sel_dbg_offset + ex1_rs2_sel_dbg_q'length-1),
            din     => dec_byp_rf1_rs2_sel,
            dout    => ex1_rs2_sel_dbg_q);


spare_0_lcb: entity tri.tri_lcbnd(tri_lcbnd)
   port map(vd          => vdd,
            gd          => gnd,
            act         => tidn(0),
            nclk        => nclk,
            forcee => func_sl_force,
            thold_b     => func_sl_thold_0_b,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b      => mpw1_dc_b,
            mpw2_b      => mpw2_dc_b,
            sg          => sg_0,
            lclk        => spare_0_lclk,
            d1clk       => spare_0_d1clk,
            d2clk       => spare_0_d2clk);
spare_0_latch : entity tri.tri_inv_nlats(tri_inv_nlats)
  generic map (width => spare_0_q'length, expand_type => expand_type, btr => "NLI0001_X2_A12TH", init=>(spare_0_q'range=>'0'))
  port map (vd => vdd, gd => gnd,
            LCLK    => spare_0_lclk,
            D1CLK   => spare_0_d1clk,
            D2CLK   => spare_0_d2clk,
            SCANIN  => siv(spare_0_offset to spare_0_offset + spare_0_q'length-1),
            SCANOUT => sov(spare_0_offset to spare_0_offset + spare_0_q'length-1),
            D       => spare_0_d,
            QB      => spare_0_q);
spare_0_d   <= not spare_0_q;
mark_unused(spare_0_q);

spare_1_lcb: entity tri.tri_lcbnd(tri_lcbnd)
   port map(vd          => vdd,
            gd          => gnd,
            act         => tidn(0),
            nclk        => nclk,
            forcee => func_sl_force,
            thold_b     => func_sl_thold_0_b,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b      => mpw1_dc_b,
            mpw2_b      => mpw2_dc_b,
            sg          => sg_0,
            lclk        => spare_1_lclk,
            d1clk       => spare_1_d1clk,
            d2clk       => spare_1_d2clk);
spare_1_latch : entity tri.tri_inv_nlats(tri_inv_nlats)
  generic map (width => spare_1_q'length, expand_type => expand_type, btr => "NLI0001_X2_A12TH", init=>(spare_1_q'range=>'0'))
  port map (vd => vdd, gd => gnd,
            LCLK    => spare_1_lclk,
            D1CLK   => spare_1_d1clk,
            D2CLK   => spare_1_d2clk,
            SCANIN  => siv(spare_1_offset to spare_1_offset + spare_1_q'length-1),
            SCANOUT => sov(spare_1_offset to spare_1_offset + spare_1_q'length-1),
            D       => spare_1_d,
            QB      => spare_1_q);
spare_1_d   <= not spare_1_q;
mark_unused(spare_1_q);

spare_2_lcb: entity tri.tri_lcbnd(tri_lcbnd)
   port map(vd          => vdd,
            gd          => gnd,
            act         => tidn(0),
            nclk        => nclk,
            forcee => func_sl_force,
            thold_b     => func_sl_thold_0_b,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b      => mpw1_dc_b,
            mpw2_b      => mpw2_dc_b,
            sg          => sg_0,
            lclk        => spare_2_lclk,
            d1clk       => spare_2_d1clk,
            d2clk       => spare_2_d2clk);
spare_2_latch : entity tri.tri_inv_nlats(tri_inv_nlats)
  generic map (width => spare_2_q'length, expand_type => expand_type, btr => "NLI0001_X2_A12TH", init=>(spare_2_q'range=>'0'))
  port map (vd => vdd, gd => gnd,
            LCLK    => spare_2_lclk,
            D1CLK   => spare_2_d1clk,
            D2CLK   => spare_2_d2clk,
            SCANIN  => siv(spare_2_offset to spare_2_offset + spare_2_q'length-1),
            SCANOUT => sov(spare_2_offset to spare_2_offset + spare_2_q'length-1),
            D       => spare_2_d,
            QB      => spare_2_q);
spare_2_d   <= not spare_2_q;
mark_unused(spare_2_q);

spare_3_lcb: entity tri.tri_lcbnd(tri_lcbnd)
   port map(vd          => vdd,
            gd          => gnd,
            act         => tidn(0),
            nclk        => nclk,
            forcee => func_sl_force,
            thold_b     => func_sl_thold_0_b,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b      => mpw1_dc_b,
            mpw2_b      => mpw2_dc_b,
            sg          => sg_0,
            lclk        => spare_3_lclk,
            d1clk       => spare_3_d1clk,
            d2clk       => spare_3_d2clk);
spare_3_latch : entity tri.tri_inv_nlats(tri_inv_nlats)
  generic map (width => spare_3_q'length, expand_type => expand_type, btr => "NLI0001_X2_A12TH", init=>(spare_3_q'range=>'0'))
  port map (vd => vdd, gd => gnd,
            LCLK    => spare_3_lclk,
            D1CLK   => spare_3_d1clk,
            D2CLK   => spare_3_d2clk,
            SCANIN  => siv(spare_3_offset to spare_3_offset + spare_3_q'length-1),
            SCANOUT => sov(spare_3_offset to spare_3_offset + spare_3_q'length-1),
            D       => spare_3_d,
            QB      => spare_3_q);
spare_3_d   <= not spare_3_q;
mark_unused(spare_3_q);

spare_4_lcb: entity tri.tri_lcbnd(tri_lcbnd)
   port map(vd          => vdd,
            gd          => gnd,
            act         => tidn(0),
            nclk        => nclk,
            forcee => func_sl_force,
            thold_b     => func_sl_thold_0_b,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b      => mpw1_dc_b,
            mpw2_b      => mpw2_dc_b,
            sg          => sg_0,
            lclk        => spare_4_lclk,
            d1clk       => spare_4_d1clk,
            d2clk       => spare_4_d2clk);
spare_4_latch : entity tri.tri_inv_nlats(tri_inv_nlats)
  generic map (width => spare_4_q'length, expand_type => expand_type, btr => "NLI0001_X2_A12TH", init=>(spare_4_q'range=>'0'))
  port map (vd => vdd, gd => gnd,
            LCLK    => spare_4_lclk,
            D1CLK   => spare_4_d1clk,
            D2CLK   => spare_4_d2clk,
            SCANIN  => siv(spare_4_offset to spare_4_offset + spare_4_q'length-1),
            SCANOUT => sov(spare_4_offset to spare_4_offset + spare_4_q'length-1),
            D       => spare_4_d,
            QB      => spare_4_q);
spare_4_d   <= not spare_4_q;
mark_unused(spare_4_q);




siv(0 to siv'right)  <= sov(1 to siv'right) & scan_in;
scan_out             <= sov(0);


-- ###############################################################
-- ## LCBs
-- ###############################################################

    ex1x_lcb: tri_lcbnd generic map (expand_type => expand_type) port map (
        delay_lclkr =>  delay_lclkr_dc     ,--in -- tidn ,
        mpw1_b      =>  mpw1_dc_b          ,--in -- tidn ,
        mpw2_b      =>  mpw2_dc_b          ,--in -- tidn ,
        forcee =>  func_sl_force      ,--in -- tidn ,
        nclk        =>  nclk               ,--in
        vd          =>  vdd                ,--inout
        gd          =>  gnd                ,--inout
        act         =>  rf1_act_q          ,--in
        sg          =>  sg_0               ,--in
        thold_b     =>  func_sl_thold_0_b  ,--in
        d1clk       =>  ex1x_d1clk         ,--out
        d2clk       =>  ex1x_d2clk         ,--out
        lclk        =>  ex1x_lclk         );--out


    ex1_lcb: tri_lcbnd generic map (expand_type => expand_type) port map ( 
        delay_lclkr =>  delay_lclkr_dc     ,--in -- tidn ,
        mpw1_b      =>  mpw1_dc_b          ,--in -- tidn ,
        mpw2_b      =>  mpw2_dc_b          ,--in -- tidn ,
        forcee =>  func_sl_force      ,--in -- tidn ,
        nclk        =>  nclk               ,--in
        vd          =>  vdd                ,--inout
        gd          =>  gnd                ,--inout
        act         =>  rf1_act_q          ,--in
        sg          =>  sg_0               ,--in
        thold_b     =>  func_sl_thold_0_b  ,--in
        d1clk       =>  ex1_d1clk          ,--out
        d2clk       =>  ex1_d2clk          ,--out
        lclk        =>  ex1_lclk          );--out

    ex1_slp_lcb: tri_lcbnd generic map (expand_type => expand_type) port map ( 
        delay_lclkr =>  delay_lclkr_dc     ,--in -- tidn ,
        mpw1_b      =>  mpw1_dc_b          ,--in -- tidn ,
        mpw2_b      =>  mpw2_dc_b          ,--in -- tidn ,
        forcee =>  func_slp_sl_force  ,--in -- tidn ,
        nclk        =>  nclk               ,--in
        vd          =>  vdd                ,--inout
        gd          =>  gnd                ,--inout
        act         =>  rf1_act_q          ,--in
        sg          =>  sg_0               ,--in
        thold_b     =>  func_slp_sl_thold_0_b,--in
        d1clk       =>  ex1_slp_d1clk      ,--out
        d2clk       =>  ex1_slp_d2clk      ,--out
        lclk        =>  ex1_slp_lclk      );--out


    ex7_lcb: tri_lcbnd generic map (expand_type => expand_type) port map ( 
        delay_lclkr =>  delay_lclkr_dc     ,--in -- tidn ,
        mpw1_b      =>  mpw1_dc_b          ,--in -- tidn ,
        mpw2_b      =>  mpw2_dc_b          ,--in -- tidn ,
        forcee =>  func_sl_force      ,--in -- tidn ,
        nclk        =>  nclk               ,--in
        vd          =>  vdd                ,--inout
        gd          =>  gnd                ,--inout
        act         =>  exx_act(6)         ,--in
        sg          =>  sg_0               ,--in
        thold_b     =>  func_sl_thold_0_b  ,--in
        d1clk       =>  ex7_d1clk          ,--out
        d2clk       =>  ex7_d2clk          ,--out
        lclk        =>  ex7_lclk          );--out


end architecture xuq_byp_gpr;
