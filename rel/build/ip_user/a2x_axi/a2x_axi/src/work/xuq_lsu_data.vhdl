-- © IBM Corp. 2020
-- This softcore is licensed under and subject to the terms of the CC-BY 4.0
-- license (https://creativecommons.org/licenses/by/4.0/legalcode). 
-- Additional rights, including the right to physically implement a softcore 
-- that is compliant with the required sections of the Power ISA 
-- Specification, will be available at no cost via the OpenPOWER Foundation. 
-- This README will be updated with additional information when OpenPOWER's 
-- license is available.


library ibm, ieee, work, tri, support;
use ibm.std_ulogic_support.all;
use ibm.std_ulogic_function_support.all;
use ibm.std_ulogic_unsigned.all;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use tri.tri_latches_pkg.all;
use support.power_logic_pkg.all;

entity xuq_lsu_data is
generic(expand_type     : integer := 2;                 
        regmode         : integer := 6;                 
        dc_size         : natural := 14;                
        cl_size         : natural := 6;                 
        l_endian_m      : integer := 1);		
port(

     xu_lsu_rf1_data_act        :in  std_ulogic;
     xu_lsu_rf1_axu_ldst_falign :in  std_ulogic;
     xu_lsu_ex1_store_data      :in  std_ulogic_vector(64-(2**REGMODE) to 63);
     xu_lsu_ex1_eff_addr        :in  std_ulogic_vector(64-(dc_size-3) to 63);
     xu_lsu_ex1_rotsel_ovrd     :in  std_ulogic_vector(0 to 4);
     ex1_optype32               :in  std_ulogic;
     ex1_optype16               :in  std_ulogic;
     ex1_optype8                :in  std_ulogic;
     ex1_optype4                :in  std_ulogic;
     ex1_optype2                :in  std_ulogic;
     ex1_optype1                :in  std_ulogic;
     ex1_store_instr            :in  std_ulogic;
     ex1_axu_op_val             :in  std_ulogic;     
     ex1_saxu_instr             :in  std_ulogic;
     ex1_sdp_instr              :in  std_ulogic;
     ex1_stgpr_instr            :in  std_ulogic;

     fu_xu_ex2_store_data_val   :in  std_ulogic;                        
     fu_xu_ex2_store_data       :in  std_ulogic_vector(0 to 255);       

     ex3_algebraic              :in  std_ulogic;                        
     ex3_data_swap              :in  std_ulogic;                        
     ex3_thrd_id                :in  std_ulogic_vector(0 to 3);         
     ex5_dp_data                :in  std_ulogic_vector(0 to 127);       

     ex4_load_op_hit            :in  std_ulogic;
     ex4_store_hit              :in  std_ulogic;
     ex4_axu_op_val             :in  std_ulogic;
     spr_dvc1_act               :in  std_ulogic;
     spr_dvc2_act               :in  std_ulogic;
     spr_dvc1_dbg               :in  std_ulogic_vector(64-(2**regmode) to 63);
     spr_dvc2_dbg               :in  std_ulogic_vector(64-(2**regmode) to 63);

     rel_upd_dcarr_val          :in  std_ulogic;

     xu_lsu_ex4_flush           :in  std_ulogic_vector(0 to 3);         
     xu_lsu_ex4_flush_local     :in  std_ulogic_vector(0 to 3);         
     xu_lsu_ex5_flush           :in  std_ulogic_vector(0 to 3);         

     xu_pc_err_dcache_parity    :out std_ulogic;
     pc_xu_inj_dcache_parity    :in  std_ulogic;

     xu_lsu_spr_xucr0_dcdis     :in  std_ulogic;
     spr_xucr0_clkg_ctl_b0      :in  std_ulogic;

     ldq_rel_data_val_early     :in  std_ulogic;
     ldq_rel_algebraic          :in  std_ulogic;                        
     ldq_rel_data_val           :in  std_ulogic;                        
     ldq_rel_ci                 :in  std_ulogic;                        
     ldq_rel_thrd_id            :in  std_ulogic_vector(0 to 3);         
     ldq_rel_axu_val            :in  std_ulogic;                        
     ldq_rel_data               :in  std_ulogic_vector(0 to 255);       
     ldq_rel_rot_sel            :in  std_ulogic_vector(0 to 4);         
     ldq_rel_op_size            :in  std_ulogic_vector(0 to 5);         
     ldq_rel_le_mode            :in  std_ulogic;                        
     ldq_rel_dvc1_en            :in  std_ulogic;                        
     ldq_rel_dvc2_en            :in  std_ulogic;                        
     ldq_rel_beat_crit_qw       :in  std_ulogic;                        
     ldq_rel_beat_crit_qw_block :in  std_ulogic;                        
     ldq_rel_addr               :in  std_ulogic_vector(64-(dc_size-3) to 58);   

     dcarr_up_way_addr          :in  std_ulogic_vector(0 to 2);         

     ex4_256st_data             :out std_ulogic_vector(0 to 255);       
     ex6_ld_par_err             :out std_ulogic;                        
     lsu_xu_ex6_datc_par_err    :out std_ulogic;                        

     ex6_xu_ld_data_b           :out std_ulogic_vector(64-(2**regmode) to 63);
     rel_xu_ld_data             :out std_ulogic_vector(64-(2**regmode) to 64+((2**regmode)/8)-1);
     xu_fu_ex6_load_data        :out std_ulogic_vector(0 to 255);
     xu_fu_ex5_load_le          :out std_ulogic;                        

     lsu_xu_rel_dvc_thrd_id     :out std_ulogic_vector(0 to 3);         
     lsu_xu_ex2_dvc1_st_cmp     :out std_ulogic_vector(0 to ((2**regmode)/8)-1);
     lsu_xu_ex8_dvc1_ld_cmp     :out std_ulogic_vector(0 to ((2**regmode)/8)-1);
     lsu_xu_rel_dvc1_en         :out std_ulogic;
     lsu_xu_rel_dvc1_cmp        :out std_ulogic_vector(0 to ((2**regmode)/8)-1);
     lsu_xu_ex2_dvc2_st_cmp     :out std_ulogic_vector(0 to ((2**regmode)/8)-1);
     lsu_xu_ex8_dvc2_ld_cmp     :out std_ulogic_vector(0 to ((2**regmode)/8)-1);
     lsu_xu_rel_dvc2_en         :out std_ulogic;
     lsu_xu_rel_dvc2_cmp        :out std_ulogic_vector(0 to ((2**regmode)/8)-1);

     pc_xu_trace_bus_enable     :in  std_ulogic;
     lsudat_debug_mux_ctrls     :in  std_ulogic_vector(0 to 1);
     lsu_xu_data_debug0         :out std_ulogic_vector(0 to 87);
     lsu_xu_data_debug1         :out std_ulogic_vector(0 to 87);
     lsu_xu_data_debug2         :out std_ulogic_vector(0 to 87);

     vdd                        :inout power_logic;
     gnd                        :inout power_logic;
     vcs                        :inout power_logic;
     nclk                       :in  clk_logic;
     pc_xu_ccflush_dc           :in  std_ulogic;
     sg_2                       :in  std_ulogic;
     fce_2                      :in  std_ulogic;
     func_sl_thold_2            :in  std_ulogic;
     func_nsl_thold_2           :in  std_ulogic;
     clkoff_dc_b                :in  std_ulogic;
     d_mode_dc                  :in  std_ulogic;
     delay_lclkr_dc             :in  std_ulogic_vector(5 to 5);
     mpw1_dc_b                  :in  std_ulogic_vector(5 to 5);
     mpw2_dc_b                  :in  std_ulogic;
     g6t_clkoff_dc_b            :in  std_ulogic;
     g6t_d_mode_dc              :in  std_ulogic;
     g6t_delay_lclkr_dc         :in  std_ulogic_vector(0 to 4);
     g6t_mpw1_dc_b              :in  std_ulogic_vector(0 to 4);
     g6t_mpw2_dc_b              :in  std_ulogic;
     abst_sl_thold_2            :in  std_ulogic;
     time_sl_thold_2            :in  std_ulogic;
     ary_nsl_thold_2            :in  std_ulogic;
     repr_sl_thold_2            :in  std_ulogic;
     bolt_sl_thold_2            :in  std_ulogic;
     bo_enable_2                :in  std_ulogic;
     an_ac_scan_dis_dc_b        :in  std_ulogic;
     an_ac_scan_diag_dc         :in  std_ulogic;

     an_ac_lbist_ary_wrt_thru_dc :in std_ulogic;
     pc_xu_abist_ena_dc         :in  std_ulogic;
     pc_xu_abist_g6t_bw         :in  std_ulogic_vector(0 to 1);
     pc_xu_abist_di_g6t_2r      :in  std_ulogic_vector(0 to 3);
     pc_xu_abist_wl512_comp_ena :in  std_ulogic;
     pc_xu_abist_raw_dc_b       :in  std_ulogic;
     pc_xu_abist_dcomp_g6t_2r   :in  std_ulogic_vector(0 to 3);
     pc_xu_abist_raddr_0        :in  std_ulogic_vector(1 to 9);
     pc_xu_abist_g6t_r_wb       :in  std_ulogic;
     pc_xu_bo_unload            :in  std_ulogic;
     pc_xu_bo_repair            :in  std_ulogic;
     pc_xu_bo_reset             :in  std_ulogic;
     pc_xu_bo_shdata            :in  std_ulogic;
     pc_xu_bo_select            :in  std_ulogic_vector(5 to 6);
     xu_pc_bo_fail              :out std_ulogic_vector(5 to 6);
     xu_pc_bo_diagout           :out std_ulogic_vector(5 to 6);

     abst_scan_in               :in  std_ulogic_vector(0 to 1);
     time_scan_in               :in  std_ulogic;
     repr_scan_in               :in  std_ulogic;
     abst_scan_out              :out std_ulogic_vector(0 to 1);
     time_scan_out              :out std_ulogic;
     repr_scan_out              :out std_ulogic;
     func_scan_in               :in  std_ulogic_vector(0 to 2);
     func_scan_out              :out std_ulogic_vector(0 to 2)
);
-- synopsys translate_off


-- synopsys translate_on

end xuq_lsu_data;
architecture xuq_lsu_data of xuq_lsu_data is


constant rot_max_size                   :std_ulogic_vector(0 to 5) := "100000";
constant byte16_size                    :std_ulogic_vector(0 to 5) := "010000";
constant uprCClassBit                   :natural := 64-(dc_size-3);
constant lwrCClassBit                   :natural := 63-cl_size;

constant ex3_opsize_offset              :natural := 0;
constant ex3_ovrd_rot_offset            :natural := ex3_opsize_offset + 6;
constant ex4_le_mode_sel_offset         :natural := ex3_ovrd_rot_offset + 1;
constant ex4_be_mode_sel_offset         :natural := ex4_le_mode_sel_offset + 16;
constant ex5_load_hit_offset            :natural := ex4_be_mode_sel_offset + 16;
constant ex7_load_hit_offset            :natural := ex5_load_hit_offset + 1;
constant ex2_st_data_offset             :natural := ex7_load_hit_offset + 1;
constant axu_rel_upd_offset             :natural := ex2_st_data_offset + (2**regmode);
constant rel_data_val_offset            :natural := axu_rel_upd_offset + 16;
constant rel_addr_stg_offset            :natural := rel_data_val_offset + 16;
constant rel_addr_offset                :natural := rel_addr_stg_offset + 58-uprCClassBit+1;
constant ex5_axu_data_sel_offset        :natural := rel_addr_offset + 58-uprCClassBit+1;
constant ex3_stgpr_instr_offset         :natural := ex5_axu_data_sel_offset + 3;
constant ex4_stgpr_instr_offset         :natural := ex3_stgpr_instr_offset + 1;
constant ex3_sdp_instr_offset           :natural := ex4_stgpr_instr_offset + 1;
constant ex4_sdp_instr_offset           :natural := ex3_sdp_instr_offset + 1;
constant ex5_sdp_instr_offset           :natural := ex4_sdp_instr_offset + 1;
constant rot_addr_offset                :natural := ex5_sdp_instr_offset + 1;
constant rot_sel_non_le_offset          :natural := rot_addr_offset + 5;
constant ex5_dvc1_en_offset             :natural := rot_sel_non_le_offset + 5;
constant ex6_dvc1_en_offset             :natural := ex5_dvc1_en_offset + 1;
constant ex7_dvc1_en_offset             :natural := ex6_dvc1_en_offset + 1;
constant rel_dvc1_val_offset            :natural := ex7_dvc1_en_offset + ((2**regmode)/8);
constant ex8_ld_dvc1_cmp_offset         :natural := rel_dvc1_val_offset + 1;
constant rel_dvc1_val_stg_offset        :natural := ex8_ld_dvc1_cmp_offset + ((2**regmode)/8);
constant rel_dvc1_val_stg2_offset       :natural := rel_dvc1_val_stg_offset + 1;
constant rel_dvc2_val_stg_offset        :natural := rel_dvc1_val_stg2_offset + 1;
constant rel_dvc2_val_stg2_offset       :natural := rel_dvc2_val_stg_offset + 1;
constant ex5_dvc2_en_offset             :natural := rel_dvc2_val_stg2_offset + 1;
constant ex6_dvc2_en_offset             :natural := ex5_dvc2_en_offset + 1;
constant ex7_dvc2_en_offset             :natural := ex6_dvc2_en_offset + 1;
constant rel_dvc2_val_offset            :natural := ex7_dvc2_en_offset + ((2**regmode)/8);
constant ex8_ld_dvc2_cmp_offset         :natural := rel_dvc2_val_offset + 1;
constant ex2_optype32_offset            :natural := ex8_ld_dvc2_cmp_offset + ((2**regmode)/8);
constant ex2_optype16_offset            :natural := ex2_optype32_offset + 1;
constant ex2_optype8_offset             :natural := ex2_optype16_offset + 1;
constant ex2_optype4_offset             :natural := ex2_optype8_offset + 1;
constant ex2_optype2_offset             :natural := ex2_optype4_offset + 1;
constant ex2_optype1_offset             :natural := ex2_optype2_offset + 1;
constant ex2_p_addr_offset              :natural := ex2_optype1_offset + 1;
constant frc_p_addr_offset              :natural := ex2_p_addr_offset + 64-uprCClassBit;
constant ex2_store_instr_offset         :natural := frc_p_addr_offset + 6;
constant ex2_axu_op_val_offset          :natural := ex2_store_instr_offset + 1;
constant ex4_axu_op_val_offset          :natural := ex2_axu_op_val_offset + 1;
constant ex2_xu_cmp_val_offset          :natural := ex4_axu_op_val_offset + 1;
constant ex2_saxu_instr_offset          :natural := ex2_xu_cmp_val_offset + (2**regmode)/8;
constant ex2_sdp_instr_offset           :natural := ex2_saxu_instr_offset + 1;
constant ex2_stgpr_instr_offset         :natural := ex2_sdp_instr_offset + 1;
constant ex4_saxu_instr_offset          :natural := ex2_stgpr_instr_offset + 1;
constant ex4_algebraic_offset           :natural := ex4_saxu_instr_offset + 1;
constant ex2_ovrd_rot_sel_offset        :natural := ex4_algebraic_offset + 1;
constant ex4_p_addr_offset              :natural := ex2_ovrd_rot_sel_offset + 5;
constant spr_xucr0_dcdis_offset         :natural := ex4_p_addr_offset + 64-uprCClassBit;
constant clkg_ctl_override_offset       :natural := spr_xucr0_dcdis_offset + 1;
constant rel_dvc_tid_stg_offset         :natural := clkg_ctl_override_offset + 1;
constant inj_dcache_parity_offset       :natural := rel_dvc_tid_stg_offset + 4;
constant ex5_stgpr_dp_instr_offset      :natural := inj_dcache_parity_offset + 1;
constant ex6_stgpr_dp_instr_offset      :natural := ex5_stgpr_dp_instr_offset + 1;
constant ex6_stgpr_dp_data_offset       :natural := ex6_stgpr_dp_instr_offset + 1;
constant ex5_rel_le_mode_offset         :natural := ex6_stgpr_dp_data_offset + 128;
constant ex1_ldst_falign_offset         :natural := ex5_rel_le_mode_offset + 1;
constant ex5_thrd_id_offset             :natural := ex1_ldst_falign_offset + 1;
constant axu_rel_val_stg1_offset        :natural := ex5_thrd_id_offset + 4;
constant axu_rel_val_stg2_offset        :natural := axu_rel_val_stg1_offset + 1;
constant axu_rel_val_stg3_offset        :natural := axu_rel_val_stg2_offset + 1;
constant rel_256ld_data_stg2_offset     :natural := axu_rel_val_stg3_offset + 1;
constant rel_axu_le_val_offset          :natural := rel_256ld_data_stg2_offset + 256;
constant rel_axu_le_val_stg1_offset     :natural := rel_axu_le_val_offset + 1;
constant dcarr_wren_offset              :natural := rel_axu_le_val_stg1_offset + 1;
constant dat_dbg_arr_offset             :natural := dcarr_wren_offset + 1;
constant ld_alg_le_sel_offset           :natural := dat_dbg_arr_offset + 13;
constant ex1_stg_act_offset      	:natural := ld_alg_le_sel_offset + 5;
constant ex2_stg_act_offset      	:natural := ex1_stg_act_offset + 1;
constant ex3_stg_act_offset      	:natural := ex2_stg_act_offset + 1;
constant ex4_stg_act_offset      	:natural := ex3_stg_act_offset + 1;
constant ex5_stg_act_offset     	:natural := ex4_stg_act_offset + 1;
constant ex6_stg_act_offset             :natural := ex5_stg_act_offset + 1;
constant rel1_stg_act_offset            :natural := ex6_stg_act_offset + 1;
constant rel2_stg_act_offset            :natural := rel1_stg_act_offset + 1;
constant rel3_stg_act_offset            :natural := rel2_stg_act_offset + 1;
constant rel4_stg_act_offset            :natural := rel3_stg_act_offset + 1;
constant rel5_stg_act_offset            :natural := rel4_stg_act_offset + 1;
constant rel2_ex2_stg_act_offset        :natural := rel5_stg_act_offset + 1;
constant rel3_ex3_stg_act_offset        :natural := rel2_ex2_stg_act_offset + 1;
constant rel4_ex4_stg_act_offset        :natural := rel3_ex3_stg_act_offset + 1;
constant ex8_ld_par_err_offset          :natural := rel4_ex4_stg_act_offset + 1;
constant my_spare_latches_offset        :natural := ex8_ld_par_err_offset + 1;
constant scan_right0                    :natural := my_spare_latches_offset + 8 - 1;
constant l1dcar_offset                  :natural := 0;
constant l1dcld_offset                  :natural := l1dcar_offset + 1;
constant rel_data_offset                :natural := l1dcld_offset + 1;
constant rel_algebraic_offset           :natural := rel_data_offset + 256;
constant rel_rot_sel_offset             :natural := rel_algebraic_offset + 1;
constant rel_op_size_offset             :natural := rel_rot_sel_offset + 5;
constant rel_le_mode_offset             :natural := rel_op_size_offset + 6;
constant rel_dvc1_en_offset             :natural := rel_le_mode_offset + 1;
constant rel_dvc2_en_offset             :natural := rel_dvc1_en_offset + 1;
constant rel_upd_gpr_offset             :natural := rel_dvc2_en_offset + 1;
constant rel_axu_val_offset             :natural := rel_upd_gpr_offset + 1;
constant rel_ci_offset                  :natural := rel_axu_val_offset + 1;
constant rel_thrd_id_offset             :natural := rel_ci_offset + 1;
constant rel_data_val_stg_offset        :natural := rel_thrd_id_offset + 4;
constant spr_dvc1_dbg_offset            :natural := rel_data_val_stg_offset + 1;
constant spr_dvc2_dbg_offset            :natural := spr_dvc1_dbg_offset + (2**regmode);
constant trace_bus_enable_offset        :natural := spr_dvc2_dbg_offset + (2**regmode);
constant dat_debug_mux_ctrls_offset     :natural := trace_bus_enable_offset + 1;
constant dat_dbg_st_dat_offset          :natural := dat_debug_mux_ctrls_offset + 2;
constant scan_right1                    :natural := dat_dbg_st_dat_offset + 64 - 1;

signal op_size                  :std_ulogic_vector(0 to 5);
signal ex3_opsize_d             :std_ulogic_vector(0 to 5);
signal ex3_opsize_q             :std_ulogic_vector(0 to 5);
signal rot_addr                 :std_ulogic_vector(0 to 5);
signal rot_addr_le              :std_ulogic_vector(0 to 5);
signal rot_size                 :std_ulogic_vector(0 to 5);
signal rot_size_le              :std_ulogic_vector(0 to 5);
signal ex3_le_mode              :std_ulogic;
signal ex3_be_mode              :std_ulogic;
signal ex4_le_mode_d            :std_ulogic;
signal ex4_le_mode_q            :std_ulogic;
signal ex4_le_mode_sel_d        :std_ulogic_vector(0 to 15);
signal ex4_le_mode_sel_q        :std_ulogic_vector(0 to 15);
signal ex4_be_mode_sel_d        :std_ulogic_vector(0 to 15);
signal ex4_be_mode_sel_q        :std_ulogic_vector(0 to 15);
signal st_256data               :std_ulogic_vector(0 to 255);
signal ex3_byte_en              :std_ulogic_vector(0 to 31);
signal ex5_ld_data              :std_ulogic_vector(0 to 255);
signal ex5_ld_data_par          :std_ulogic_vector(0 to 31);
signal ex6_par_chk_val          :std_ulogic;
signal ex2_st_data_fixup        :std_ulogic_vector(0 to 127);
signal ex2_st_data_d            :std_ulogic_vector(64-(2**regmode) to 63);
signal ex2_st_data_q            :std_ulogic_vector(64-(2**regmode) to 63);
signal fu_ex2_store_data_val    :std_ulogic;
signal fu_ex2_store_data        :std_ulogic_vector(0 to 255);
signal rel_256ld_data           :std_ulogic_vector(0 to 255);
signal rel_64ld_data            :std_ulogic_vector(64-(2**regmode) to 63);
signal axu_rel_upd_d            :std_ulogic_vector(0 to 15);
signal axu_rel_upd_q            :std_ulogic_vector(0 to 15);
signal ex6_rot_sel              :std_ulogic_vector(0 to 31);
signal rot_sel_non_le           :std_ulogic_vector(0 to 5);
signal be_st_rot_sel            :std_ulogic_vector(1 to 5);
signal le_st_rot_sel            :std_ulogic_vector(0 to 3);
signal ex4_ld_rot_sel           :std_ulogic_vector(1 to 5);
signal st_ovrd_rot_sel          :std_ulogic_vector(0 to 4);
signal ex3_st_rot_sel_d         :std_ulogic_vector(0 to 4);
signal ex3_st_rot_sel_q         :std_ulogic_vector(0 to 4);
signal rel_algebraic            :std_ulogic;
signal rel_data                 :std_ulogic_vector(0 to 255);
signal rel_data_val             :std_ulogic_vector(0 to 15);
signal rel_upd_gpr_d            :std_ulogic;
signal rel_upd_gpr_q            :std_ulogic;
signal rel_rot_sel              :std_ulogic_vector(0 to 4);
signal rel_op_size              :std_ulogic_vector(0 to 5);
signal rel_le_mode              :std_ulogic;
signal rel_algebraic_d          :std_ulogic;
signal rel_data_val_d           :std_ulogic_vector(0 to 15);
signal rel_data_d               :std_ulogic_vector(0 to 255);
signal rel_rot_sel_d            :std_ulogic_vector(0 to 4);
signal rel_op_size_d            :std_ulogic_vector(0 to 5);
signal rel_le_mode_d            :std_ulogic;
signal rel_addr_d               :std_ulogic_vector(uprCClassBit to 58);
signal rel_algebraic_q          :std_ulogic;
signal rel_data_val_q           :std_ulogic_vector(0 to 15);
signal rel_data_q               :std_ulogic_vector(0 to 255);
signal rel_rot_sel_q            :std_ulogic_vector(0 to 4);
signal rel_op_size_q            :std_ulogic_vector(0 to 5);
signal rel_le_mode_q            :std_ulogic;
signal rel_addr_q               :std_ulogic_vector(uprCClassBit to 58);
signal rel_xu_ld_par            :std_ulogic_vector(0 to 7);
signal rel_ex2_data             :std_ulogic_vector(0 to 255);
signal rel_ex3_data_d           :std_ulogic_vector(0 to 255);
signal rel_ex3_data_q           :std_ulogic_vector(0 to 255);
signal rel_addr_stg_d           :std_ulogic_vector(uprCClassBit to 58);
signal rel_addr_stg_q           :std_ulogic_vector(uprCClassBit to 58);
signal rel_data_val_stg_d       :std_ulogic;
signal rel_data_val_stg_q       :std_ulogic;
signal rel_data_val_stg_dly_d   :std_ulogic;
signal rel_data_val_stg_dly_q   :std_ulogic;
signal ex4_parity_gen           :std_ulogic_vector(0 to 31);
signal non_le_byte_bit0         :std_ulogic_vector(0 to 31);
signal le_byte_bit0             :std_ulogic_vector(0 to 31);
signal alg_bit_sel              :std_ulogic_vector(0 to 4);
signal alg_byte                 :std_ulogic_vector(0 to 31);
signal algebraic_bit            :std_ulogic;
signal rel_alg_bit_d            :std_ulogic;
signal rel_alg_bit_q            :std_ulogic;
signal ex2_ovrd_rot             :std_ulogic;
signal ex3_ovrd_rot_d           :std_ulogic;
signal ex3_ovrd_rot_q           :std_ulogic;
signal ex3_sdp_instr_d          :std_ulogic;
signal ex3_sdp_instr_q          :std_ulogic;
signal ex4_sdp_instr_d          :std_ulogic;
signal ex4_sdp_instr_q          :std_ulogic;
signal ex5_sdp_instr_d          :std_ulogic;
signal ex5_sdp_instr_q          :std_ulogic;
signal ex3_stgpr_instr_d        :std_ulogic;
signal ex3_stgpr_instr_q        :std_ulogic;
signal ex4_stgpr_instr_d        :std_ulogic;
signal ex4_stgpr_instr_q        :std_ulogic;
signal ex5_stgpr_dp_instr_d     :std_ulogic;
signal ex5_stgpr_dp_instr_q     :std_ulogic;
signal ex6_stgpr_dp_instr_d     :std_ulogic;
signal ex6_stgpr_dp_instr_q     :std_ulogic;
signal ex6_stgpr_dp_instr_q_b   :std_ulogic;
signal ex4_stgpr_data           :std_ulogic_vector(64-(2**regmode) to 63);
signal ex5_stgpr_data_d         :std_ulogic_vector(64-(2**regmode) to 63);
signal ex5_stgpr_data_q         :std_ulogic_vector(64-(2**regmode) to 63);
signal ex6_stgpr_dp_data_d      :std_ulogic_vector(0 to 127);
signal ex6_stgpr_dp_data_q      :std_ulogic_vector(0 to 127);
signal rel_axu_le_mode          :std_ulogic;
signal rot_addr_d               :std_ulogic_vector(1 to 5);
signal rot_addr_q               :std_ulogic_vector(1 to 5);
signal ex4_rot_addr_d           :std_ulogic_vector(1 to 5);
signal ex4_rot_addr_q           :std_ulogic_vector(1 to 5);
signal rot_sel_non_le_d         :std_ulogic_vector(1 to 5);
signal rot_sel_non_le_q         :std_ulogic_vector(1 to 5);
signal ex4_rot_sel_non_le_d     :std_ulogic_vector(1 to 5);
signal ex4_rot_sel_non_le_q     :std_ulogic_vector(1 to 5);
signal rel_axu_val_d            :std_ulogic;
signal rel_axu_val_q            :std_ulogic;
signal rel_ci_d                 :std_ulogic;
signal rel_ci_q                 :std_ulogic;
signal rel_ci_dly_d             :std_ulogic;
signal rel_ci_dly_q             :std_ulogic;
signal ex2_st_dvc1_cmp_d        :std_ulogic_vector((64-(2**regmode))/8 to 7);
signal ex2_st_dvc1_cmp_q        :std_ulogic_vector((64-(2**regmode))/8 to 7);
signal ex2_st_dvc2_cmp_d        :std_ulogic_vector((64-(2**regmode))/8 to 7);
signal ex2_st_dvc2_cmp_q        :std_ulogic_vector((64-(2**regmode))/8 to 7);
signal ex8_ld_dvc1_cmp_d        :std_ulogic_vector((64-(2**regmode))/8 to 7);
signal ex8_ld_dvc1_cmp_q        :std_ulogic_vector((64-(2**regmode))/8 to 7);
signal ex8_ld_dvc2_cmp_d        :std_ulogic_vector((64-(2**regmode))/8 to 7);
signal ex8_ld_dvc2_cmp_q        :std_ulogic_vector((64-(2**regmode))/8 to 7);
signal rel_dvc1_cmp_d           :std_ulogic_vector((64-(2**regmode))/8 to 7);
signal rel_dvc1_cmp_q           :std_ulogic_vector((64-(2**regmode))/8 to 7);
signal rel_dvc2_cmp_d           :std_ulogic_vector((64-(2**regmode))/8 to 7);
signal rel_dvc2_cmp_q           :std_ulogic_vector((64-(2**regmode))/8 to 7);
signal rel_dvc1_val_stg_d       :std_ulogic;
signal rel_dvc1_val_stg_q       :std_ulogic;
signal rel_dvc1_val_stg2_d      :std_ulogic;
signal rel_dvc1_val_stg2_q      :std_ulogic;
signal rel_dvc2_val_stg_d       :std_ulogic;
signal rel_dvc2_val_stg_q       :std_ulogic;
signal rel_dvc2_val_stg2_d      :std_ulogic;
signal rel_dvc2_val_stg2_q      :std_ulogic;
signal ex5_dvc1_en_d            :std_ulogic;
signal ex5_dvc1_en_q            :std_ulogic;
signal ex6_dvc1_en_d            :std_ulogic;
signal ex6_dvc1_en_q            :std_ulogic;
signal ex7_dvc1_en_d            :std_ulogic_vector((64-(2**regmode))/8 to 7);
signal ex7_dvc1_en_q            :std_ulogic_vector((64-(2**regmode))/8 to 7);
signal ex5_dvc2_en_d            :std_ulogic;
signal ex5_dvc2_en_q            :std_ulogic;
signal ex6_dvc2_en_d            :std_ulogic;
signal ex6_dvc2_en_q            :std_ulogic;
signal ex7_dvc2_en_d            :std_ulogic_vector((64-(2**regmode))/8 to 7);
signal ex7_dvc2_en_q            :std_ulogic_vector((64-(2**regmode))/8 to 7);
signal rel_dvc1_en_d            :std_ulogic;
signal rel_dvc1_en_q            :std_ulogic;
signal rel_dvc2_en_d            :std_ulogic;
signal rel_dvc2_en_q            :std_ulogic;
signal rel_dvc1_val_d           :std_ulogic;
signal rel_dvc1_val_q           :std_ulogic;
signal rel_dvc2_val_d           :std_ulogic;
signal rel_dvc2_val_q           :std_ulogic;
signal ex1_op_size              :std_ulogic_vector(2 to 5);
signal ex1_st_byte_mask         :std_ulogic_vector(0 to 7);
signal ex2_optype32_d           :std_ulogic;
signal ex2_optype32_q           :std_ulogic;
signal ex2_optype16_d           :std_ulogic;
signal ex2_optype16_q           :std_ulogic;
signal ex2_optype8_d            :std_ulogic;
signal ex2_optype8_q            :std_ulogic;
signal ex2_optype4_d            :std_ulogic;
signal ex2_optype4_q            :std_ulogic;
signal ex2_optype2_d            :std_ulogic;
signal ex2_optype2_q            :std_ulogic;
signal ex2_optype1_d            :std_ulogic;
signal ex2_optype1_q            :std_ulogic;
signal ex2_p_addr_d             :std_ulogic_vector(uprCClassBit to 63);
signal ex2_p_addr_q             :std_ulogic_vector(uprCClassBit to 63);
signal ex3_fu_st_val_d          :std_ulogic;
signal ex3_fu_st_val_q          :std_ulogic;
signal frc_p_addr_d             :std_ulogic_vector(58 to 63);
signal frc_p_addr_q             :std_ulogic_vector(58 to 63);
signal ex2_store_instr_d        :std_ulogic;
signal ex2_store_instr_q        :std_ulogic;
signal ex3_store_instr_d        :std_ulogic;
signal ex3_store_instr_q        :std_ulogic;
signal ex2_axu_op_val_d         :std_ulogic;
signal ex2_axu_op_val_q         :std_ulogic;
signal ex3_axu_op_val_d         :std_ulogic;
signal ex3_axu_op_val_q         :std_ulogic;
signal ex4_axu_op_val_d         :std_ulogic;
signal ex4_axu_op_val_q         :std_ulogic;
signal ex2_xu_cmp_val_d         :std_ulogic_vector((64-(2**regmode))/8 to 7);
signal ex2_xu_cmp_val_q         :std_ulogic_vector((64-(2**regmode))/8 to 7);
signal ex2_saxu_instr_d         :std_ulogic;
signal ex2_saxu_instr_q         :std_ulogic;
signal ex2_sdp_instr_d          :std_ulogic;
signal ex2_sdp_instr_q          :std_ulogic;
signal ex2_stgpr_instr_d        :std_ulogic;
signal ex2_stgpr_instr_q        :std_ulogic;
signal ex3_saxu_instr_d         :std_ulogic;
signal ex3_saxu_instr_q         :std_ulogic;
signal ex4_saxu_instr_d         :std_ulogic;
signal ex4_saxu_instr_q         :std_ulogic;
signal ex4_algebraic_d          :std_ulogic;
signal ex4_algebraic_q          :std_ulogic;
signal ex2_ovrd_rot_sel_d       :std_ulogic_vector(0 to 4);
signal ex2_ovrd_rot_sel_q       :std_ulogic_vector(0 to 4);
signal ex3_p_addr_d             :std_ulogic_vector(uprCClassBit to 63);
signal ex3_p_addr_q             :std_ulogic_vector(uprCClassBit to 63);
signal ex4_p_addr_d             :std_ulogic_vector(uprCClassBit to 63);
signal ex4_p_addr_q             :std_ulogic_vector(uprCClassBit to 63);
signal rel_ex2_par_gen          :std_ulogic_vector(0 to 31);
signal rel_ex3_par_gen_d        :std_ulogic_vector(0 to 31);
signal rel_ex3_par_gen_q        :std_ulogic_vector(0 to 31);
signal ex2_fu_data_val          :std_ulogic;
signal rel_xu_data              :std_ulogic_vector(0 to 255);
signal spr_xucr0_dcdis_d        :std_ulogic;
signal spr_xucr0_dcdis_q        :std_ulogic;
signal clkg_ctl_override_d      :std_ulogic;
signal clkg_ctl_override_q      :std_ulogic;
signal rel_data_val_wren        :std_ulogic;
signal rel_thrd_id_d            :std_ulogic_vector(0 to 3);
signal rel_thrd_id_q            :std_ulogic_vector(0 to 3);
signal rel_dvc_thrd_id_d        :std_ulogic_vector(0 to 3);
signal rel_dvc_thrd_id_q        :std_ulogic_vector(0 to 3);
signal rel_dvc_tid_stg_d        :std_ulogic_vector(0 to 3);
signal rel_dvc_tid_stg_q        :std_ulogic_vector(0 to 3);
signal rel_dvc_tid_stg2_d       :std_ulogic_vector(0 to 3);
signal rel_dvc_tid_stg2_q       :std_ulogic_vector(0 to 3);
signal dont_do_this             :std_ulogic_vector(0 to 63);    
signal ex6_xld_data             :std_ulogic_vector(0 to 63);    
signal ex6_xld_data_b           :std_ulogic_vector(0 to 63);    
signal ex6_ld_alg_bit           :std_ulogic_vector(0 to 5);     
signal ex6_ld_dvc_byte_mask     :std_ulogic_vector((64-(2**regmode))/8 to 7);
signal ld_swzl_data             :std_ulogic_vector(0 to 255);   
signal axu_data_sel             :std_ulogic_vector(0 to 1);
signal ex5_axu_data_sel_d       :std_ulogic_vector(0 to 2);
signal ex5_axu_data_sel_q       :std_ulogic_vector(0 to 2);
signal ex6_axu_data_sel_d       :std_ulogic_vector(0 to 47);
signal ex6_axu_data_sel_q       :std_ulogic_vector(0 to 47);
signal inj_dcache_parity_d      :std_ulogic;
signal inj_dcache_parity_q      :std_ulogic;
signal ex5_rel_le_mode_d        :std_ulogic;
signal ex5_rel_le_mode_q        :std_ulogic;
signal ex1_ldst_falign_d        :std_ulogic;
signal ex1_ldst_falign_q        :std_ulogic;
signal ex1_frc_align32          :std_ulogic;
signal ex1_frc_align16          :std_ulogic;
signal ex1_frc_align8           :std_ulogic;
signal ex1_frc_align4           :std_ulogic;
signal ex1_frc_align2           :std_ulogic;
signal ex4_stg_flush            :std_ulogic;
signal ex5_stg_flush            :std_ulogic;
signal ex4_load_hit             :std_ulogic;
signal ex5_load_hit_d           :std_ulogic;
signal ex5_load_hit_q           :std_ulogic;
signal ex6_load_hit_d           :std_ulogic;
signal ex6_load_hit_q           :std_ulogic;
signal ex7_load_hit_d           :std_ulogic;
signal ex7_load_hit_q           :std_ulogic;
signal ex4_thrd_id_d            :std_ulogic_vector(0 to 3);
signal ex4_thrd_id_q            :std_ulogic_vector(0 to 3);
signal ex5_thrd_id_d            :std_ulogic_vector(0 to 3);
signal ex5_thrd_id_q            :std_ulogic_vector(0 to 3);
signal axu_rel_val_stg1_d       :std_ulogic;
signal axu_rel_val_stg1_q       :std_ulogic;
signal axu_rel_val_stg2_d       :std_ulogic;
signal axu_rel_val_stg2_q       :std_ulogic;
signal axu_rel_val_stg3_d       :std_ulogic;
signal axu_rel_val_stg3_q       :std_ulogic;
signal rel_data_rot_sel         :std_ulogic;
signal rel_256ld_data_stg1_d    :std_ulogic_vector(0 to 255);
signal rel_256ld_data_stg1_q    :std_ulogic_vector(0 to 255);
signal rel_256ld_data_stg2_d    :std_ulogic_vector(0 to 255);
signal rel_256ld_data_stg2_q    :std_ulogic_vector(0 to 255);
signal rel_axu_le_val_d         :std_ulogic;
signal rel_axu_le_val_q         :std_ulogic;
signal rel_axu_le_val_stg1_d    :std_ulogic;
signal rel_axu_le_val_stg1_q    :std_ulogic;
signal dcarr_rd_data            :std_ulogic_vector(0 to 287);
signal dcarr_bw                 :std_ulogic_vector(0 to 287);
signal dcarr_addr               :std_ulogic_vector(uprCClassBit to 58);
signal dcarr_wr_data            :std_ulogic_vector(0 to 287);
signal dcarr_bw_dly             :std_ulogic_vector(0 to 31);
signal dcarr_wren_b             :std_ulogic;
signal dcarr_wren               :std_ulogic;
signal dcarr_wren_d             :std_ulogic;
signal dcarr_wren_q             :std_ulogic;
signal ex4_store_hit_early_gate :std_ulogic;
signal rel_ex4_store_hit        :std_ulogic;
signal ex4_thrd_id_mask         :std_ulogic_vector(0 to 3);
signal dat_dbg_arr_d            :std_ulogic_vector(0 to 12);
signal dat_dbg_arr_q            :std_ulogic_vector(0 to 12);
signal ex4_256st_dataFixUp      :std_ulogic_vector(0 to 255);
signal alg_bit_le_sel           :std_ulogic_vector(0 to 5);
signal ex4_ld_alg_sel           :std_ulogic_vector(1 to 5);
signal ld_alg_le_sel_d          :std_ulogic_vector(1 to 5);
signal ld_alg_le_sel_q          :std_ulogic_vector(1 to 5);
signal ex4_ld_alg_le_sel_d      :std_ulogic_vector(1 to 5);
signal ex4_ld_alg_le_sel_q      :std_ulogic_vector(1 to 5);
signal ex6_axu_rel_gpr_data_sel :std_ulogic_vector(0 to 15);
signal ex6_axu_rel_gpr_data     :std_ulogic_vector(0 to 127);
signal ex7_ld_par_err           :std_ulogic_vector(0 to 1);
signal ex8_ld_par_err_d         :std_ulogic;
signal ex8_ld_par_err_q         :std_ulogic;
signal dcache_parity            :std_ulogic_vector(0 to 0);
signal ex6_ld_par_err_int       :std_ulogic;
signal spr_dvc1_dbg_d           :std_ulogic_vector(64-(2**regmode) to 63);
signal spr_dvc1_dbg_q           :std_ulogic_vector(64-(2**regmode) to 63);
signal spr_dvc2_dbg_d           :std_ulogic_vector(64-(2**regmode) to 63);
signal spr_dvc2_dbg_q           :std_ulogic_vector(64-(2**regmode) to 63);
signal ex7_xld_data_d           :std_ulogic_vector(64-(2**regmode) to 63);
signal ex7_xld_data_q           :std_ulogic_vector(64-(2**regmode) to 63);
signal ex4_stg_flush_lcl_b      :std_ulogic_vector(0 to 3);
signal ex4_flush_t01_b          :std_ulogic;
signal ex4_flush_t23_b          :std_ulogic;
signal rel_ex4_upd_en           :std_ulogic;
signal ex1_stg_act_d    	:std_ulogic;
signal ex1_stg_act_q     	:std_ulogic;
signal ex2_stg_act_d     	:std_ulogic;
signal ex2_stg_act_q     	:std_ulogic;
signal ex3_stg_act_d     	:std_ulogic;
signal ex3_stg_act_q     	:std_ulogic;
signal ex4_stg_act_d     	:std_ulogic;
signal ex4_stg_act_q     	:std_ulogic;
signal ex5_stg_act_d     	:std_ulogic;
signal ex5_stg_act_q     	:std_ulogic;
signal ex6_stg_act_d     	:std_ulogic;
signal ex6_stg_act_q     	:std_ulogic;
signal rel1_stg_act_d           :std_ulogic;
signal rel1_stg_act_q           :std_ulogic;
signal rel2_stg_act_d           :std_ulogic;
signal rel2_stg_act_q           :std_ulogic;
signal rel3_stg_act_d           :std_ulogic;
signal rel3_stg_act_q           :std_ulogic;
signal rel4_stg_act_d           :std_ulogic;
signal rel4_stg_act_q           :std_ulogic;
signal rel5_stg_act_d           :std_ulogic;
signal rel5_stg_act_q           :std_ulogic;
signal rel2_ex2_stg_act         :std_ulogic;
signal rel2_ex2_stg_act_d       :std_ulogic;
signal rel2_ex2_stg_act_q       :std_ulogic;
signal rel3_ex3_stg_act         :std_ulogic;
signal rel3_ex3_stg_act_d       :std_ulogic;
signal rel3_ex3_stg_act_q       :std_ulogic;
signal rel4_ex4_stg_act         :std_ulogic;
signal rel4_ex4_stg_act_d       :std_ulogic;
signal rel4_ex4_stg_act_q       :std_ulogic;
signal rel_dvc_byte_mask        :std_ulogic_vector((64-(2**regmode))/8 to 7);
signal trace_bus_enable_q       :std_ulogic;
signal dat_debug_mux_ctrls_q    :std_ulogic_vector(0 to 1);
signal rel_ex3_store_data0      :std_ulogic_vector(0 to 63);
signal rel_ex3_store_data1      :std_ulogic_vector(0 to 63);
signal rel_ex3_store_data2      :std_ulogic_vector(0 to 63);
signal rel_ex3_store_data3      :std_ulogic_vector(0 to 63);
signal dat_dbg_st_dat_d         :std_ulogic_vector(0 to 63);
signal dat_dbg_st_dat_q         :std_ulogic_vector(0 to 63);
signal dat_dbg_ld_dat           :std_ulogic_vector(0 to 63);
signal abst_scan_in_q           :std_ulogic_vector(0 to 1);
signal abst_scan_out_int        :std_ulogic_vector(0 to 1);
signal abst_scan_out_q          :std_ulogic_vector(0 to 1);
signal time_scan_in_q           :std_ulogic;
signal time_scan_out_int        :std_ulogic;
signal time_scan_out_q          :std_ulogic;
signal repr_scan_in_q           :std_ulogic;
signal repr_scan_out_int        :std_ulogic;
signal repr_scan_out_q          :std_ulogic;
signal func_scan_in_q           :std_ulogic_vector(0 to 2);
signal func_scan_in_2_q         :std_ulogic_vector(0 to 2);
signal func_scan_out_int        :std_ulogic_vector(0 to 2);
signal func_scan_out_q          :std_ulogic_vector(0 to 2);
signal func_scan_out_2_q        :std_ulogic_vector(0 to 2);
signal tiup                     :std_ulogic;
signal tidn                     :std_ulogic;
signal func_nsl_thold_1         :std_ulogic;
signal func_sl_thold_1          :std_ulogic;
signal sg_1                     :std_ulogic;
signal fce_1                    :std_ulogic;
signal func_nsl_thold_0         :std_ulogic;
signal func_sl_thold_0          :std_ulogic;
signal sg_0                     :std_ulogic;
signal fce_0                    :std_ulogic;
signal func_sl_force            :std_ulogic;
signal func_sl_thold_0_b        :std_ulogic;
signal func_nsl_force           :std_ulogic;
signal func_nsl_thold_0_b       :std_ulogic;
signal siv0                     :std_ulogic_vector(0 to scan_right0);
signal sov0                     :std_ulogic_vector(0 to scan_right0);
signal siv1                     :std_ulogic_vector(0 to scan_right1);
signal sov1                     :std_ulogic_vector(0 to scan_right1);
signal abist_siv                :std_ulogic_vector(0 to 21);
signal abist_sov                :std_ulogic_vector(0 to 21);
signal abst_sl_thold_1          :std_ulogic;
signal time_sl_thold_1          :std_ulogic;
signal ary_nsl_thold_1          :std_ulogic;
signal repr_sl_thold_1          :std_ulogic;
signal bolt_sl_thold_1          :std_ulogic;
signal abst_sl_thold_0          :std_ulogic;
signal time_sl_thold_0          :std_ulogic;
signal ary_nsl_thold_0          :std_ulogic;
signal repr_sl_thold_0          :std_ulogic;
signal bolt_sl_thold_0          :std_ulogic;
signal abst_sl_thold_0_b        :std_ulogic;
signal abst_sl_force            :std_ulogic;
signal pc_xu_abist_g6t_bw_q     :std_ulogic_vector(0 to 1);
signal pc_xu_abist_di_g6t_2r_q  :std_ulogic_vector(0 to 3);
signal pc_xu_abist_wl512_comp_ena_q :std_ulogic;
signal pc_xu_abist_dcomp_g6t_2r_q :std_ulogic_vector(0 to 3);
signal pc_xu_abist_raddr_0_q    :std_ulogic_vector(0 to 8);
signal pc_xu_abist_g6t_r_wb_q   :std_ulogic;
signal slat_force               :std_ulogic;
signal abst_slat_thold_b        :std_ulogic;
signal abst_slat_d2clk          :std_ulogic;
signal abst_slat_lclk           :clk_logic;
signal time_slat_thold_b        :std_ulogic;
signal time_slat_d2clk          :std_ulogic;
signal time_slat_lclk           :clk_logic;
signal repr_slat_thold_b        :std_ulogic;
signal repr_slat_d2clk          :std_ulogic;
signal repr_slat_lclk           :clk_logic;
signal func_slat_thold_b        :std_ulogic;
signal func_slat_d2clk          :std_ulogic;
signal func_slat_lclk           :clk_logic;
signal my_spare_latches_d       :std_ulogic_vector(0 to 7);
signal my_spare_latches_q       :std_ulogic_vector(0 to 7);
signal my_spare0_lclk           :clk_logic;
signal my_spare0_d1clk          :std_ulogic;
signal my_spare0_d2clk          :std_ulogic;

signal ex6_frot_b, ex6_fdat, ex6_rot_sel_bus, ex6_axu_oth_b :std_ulogic_vector(0 to 255); 
signal ex6_rot_d_b, ex6_rot_d, ex6_xld_rot_b, ex6_xld_oth_b :std_ulogic_vector(0 to 63);
signal ex6_xld_sgnx_b , ex6_xld_sgn_b, ex6_xld_sgn :std_ulogic_vector(0 to  5);


                                                     




begin

tiup <= '1';
tidn <= '0';


ex1_stg_act_d  <= xu_lsu_rf1_data_act or clkg_ctl_override_q;
ex2_stg_act_d  <= ex1_stg_act_q;
ex3_stg_act_d  <= ex2_stg_act_q;
ex4_stg_act_d  <= ex3_stg_act_q;
ex5_stg_act_d  <= ex4_stg_act_q;
ex6_stg_act_d  <= ex5_stg_act_q;
rel1_stg_act_d <= ldq_rel_data_val_early or clkg_ctl_override_q;
rel2_stg_act_d <= ldq_rel_ci or ldq_rel_data_val or clkg_ctl_override_q;
rel3_stg_act_d <= rel2_stg_act_q;
rel4_stg_act_d <= rel3_stg_act_q;
rel5_stg_act_d <= rel4_stg_act_q;
rel2_ex2_stg_act_d <= rel2_stg_act_d or ex2_stg_act_d;
rel3_ex3_stg_act_d <= rel3_stg_act_d or ex3_stg_act_d;
rel4_ex4_stg_act_d <= rel4_stg_act_d or ex4_stg_act_d;

rel2_ex2_stg_act <= rel2_ex2_stg_act_q;
rel3_ex3_stg_act <= rel3_ex3_stg_act_q;
rel4_ex4_stg_act <= rel4_ex4_stg_act_q;


rel_algebraic_d        <= ldq_rel_algebraic;
rel_data_d             <= ldq_rel_data;     
rel_rot_sel_d          <= ldq_rel_rot_sel;  
rel_op_size_d          <= ldq_rel_op_size;  
rel_le_mode_d          <= ldq_rel_le_mode;  
rel_dvc1_en_d          <= ldq_rel_dvc1_en;
rel_dvc2_en_d          <= ldq_rel_dvc2_en;
rel_upd_gpr_d          <= ldq_rel_beat_crit_qw;
rel_axu_val_d          <= ldq_rel_axu_val;
rel_ci_d               <= ldq_rel_ci;
rel_ci_dly_d           <= rel_ci_q;
rel_thrd_id_d          <= ldq_rel_thrd_id;
rel_data_val_stg_d     <= ldq_rel_data_val;
rel_data_val_stg_dly_d <= rel_data_val_stg_q;

rel_algebraic   <= rel_algebraic_q;
rel_data        <= rel_data_q;
rel_rot_sel     <= rel_rot_sel_q;
rel_op_size     <= rel_op_size_q;
rel_le_mode     <= rel_le_mode_q;

inj_dcache_parity_d <= pc_xu_inj_dcache_parity;

rel_data_rot_sel        <= rel_ci_q or rel_data_val_stg_q;
rel_data_val_wren       <= rel_data_val_stg_q and not spr_xucr0_dcdis_q;
rel_data_val_d(0 to 7)  <= (others=>rel_data_val_wren);
rel_data_val_d(8 to 15) <= (others=>(not rel_data_val_wren));
rel_data_val            <= rel_data_val_q;
rel_addr_stg_d          <= ldq_rel_addr;     
rel_addr_d              <= rel_addr_stg_q;

spr_xucr0_dcdis_d   <= xu_lsu_spr_xucr0_dcdis;
clkg_ctl_override_d <= spr_xucr0_clkg_ctl_b0;
ex1_ldst_falign_d   <= xu_lsu_rf1_axu_ldst_falign;
ex1_frc_align32     <= ex1_ldst_falign_q and ex1_optype32;
ex1_frc_align16     <= ex1_ldst_falign_q and ex1_optype16;
ex1_frc_align8      <= ex1_ldst_falign_q and ex1_optype8;
ex1_frc_align4      <= ex1_ldst_falign_q and ex1_optype4;
ex1_frc_align2      <= ex1_ldst_falign_q and ex1_optype2;
ex2_p_addr_d        <= xu_lsu_ex1_eff_addr(uprCClassBit to 63);
ex3_fu_st_val_d     <= fu_xu_ex2_store_data_val;
ex2_optype32_d      <= ex1_optype32;
ex2_optype16_d      <= ex1_optype16;
ex2_optype8_d       <= ex1_optype8;
ex2_optype4_d       <= ex1_optype4;
ex2_optype2_d       <= ex1_optype2;
ex2_optype1_d       <= ex1_optype1;
ex2_store_instr_d   <= ex1_store_instr;
ex3_store_instr_d   <= ex2_store_instr_q and ex2_stg_act_q;
ex2_axu_op_val_d    <= ex1_axu_op_val;
ex3_axu_op_val_d    <= ex2_axu_op_val_q;
ex4_axu_op_val_d    <= ex3_axu_op_val_q;
ex2_saxu_instr_d    <= ex1_saxu_instr;
ex2_sdp_instr_d     <= ex1_sdp_instr;
ex2_stgpr_instr_d   <= ex1_stgpr_instr;
ex3_saxu_instr_d    <= ex2_saxu_instr_q;
ex4_saxu_instr_d    <= ex3_saxu_instr_q;
ex4_algebraic_d     <= ex3_algebraic;
ex2_ovrd_rot_sel_d  <= xu_lsu_ex1_rotsel_ovrd;
ex3_p_addr_d        <= ex2_p_addr_q;
ex4_p_addr_d        <= ex3_p_addr_q;
ex4_thrd_id_d       <= ex3_thrd_id;
ex5_thrd_id_d       <= ex4_thrd_id_q;
ex4_load_hit        <= ex4_load_op_hit and not ex4_stg_flush;
ex5_load_hit_d      <= ex4_load_hit;
ex6_load_hit_d      <= ex5_load_hit_q;
ex7_load_hit_d      <= ex6_load_hit_q;
spr_dvc1_dbg_d      <= spr_dvc1_dbg;
spr_dvc2_dbg_d      <= spr_dvc2_dbg;

ex1_op_size <= ex1_optype8 & ex1_optype4 & ex1_optype2 & ex1_optype1;

with ex1_op_size(2 to 5) select
    ex1_st_byte_mask <= x"01" when "0001",
                        x"03" when "0010",
                        x"0F" when "0100",
                        x"FF" when others;

ex2_xu_cmp_val_d <= gate(ex1_st_byte_mask((64-(2**regmode))/8 to 7), (not ex1_axu_op_val and ex1_store_instr));

frc_p_addr_d(58) <= xu_lsu_ex1_eff_addr(58);
frc_p_addr_d(59) <= xu_lsu_ex1_eff_addr(59) and not  ex1_frc_align32;
frc_p_addr_d(60) <= xu_lsu_ex1_eff_addr(60) and not (ex1_frc_align32 or ex1_frc_align16);
frc_p_addr_d(61) <= xu_lsu_ex1_eff_addr(61) and not (ex1_frc_align32 or ex1_frc_align16 or ex1_frc_align8);
frc_p_addr_d(62) <= xu_lsu_ex1_eff_addr(62) and not (ex1_frc_align32 or ex1_frc_align16 or ex1_frc_align8 or ex1_frc_align4);
frc_p_addr_d(63) <= xu_lsu_ex1_eff_addr(63) and not (ex1_frc_align32 or ex1_frc_align16 or ex1_frc_align8 or ex1_frc_align4 or ex1_frc_align2);

axu_rel_val_stg1_d <= rel_axu_val_q;
axu_rel_val_stg2_d <= axu_rel_val_stg1_q and rel_upd_gpr_q;
axu_rel_val_stg3_d <= axu_rel_val_stg2_q;
axu_rel_upd_d      <= (others=>axu_rel_val_stg3_q);

op_size       <= ex2_optype32_q & ex2_optype16_q & ex2_optype8_q & ex2_optype4_q & ex2_optype2_q & ex2_optype1_q;
rot_addr      <= frc_p_addr_q(58 to 63);
ex3_le_mode   <= ex3_data_swap and not (ex3_ovrd_rot_q or rel_data_val(0));
ex3_be_mode   <= ex3_ovrd_rot_q or rel_data_val(0) or (not ex3_data_swap);
ex4_le_mode_sel_d(0 to 15) <= (others=>ex3_le_mode);
ex4_be_mode_sel_d(0 to 15) <= (others=>ex3_be_mode);
ex4_le_mode_d <= ex3_le_mode;

rot_size        <= std_ulogic_vector(unsigned(rot_addr) + unsigned(op_size));
rot_sel_non_le  <= std_ulogic_vector(unsigned(rot_max_size) - unsigned(rot_size));


rot_addr_le   <= std_ulogic_vector(unsigned(rot_addr)     + unsigned(byte16_size));
rot_size_le   <= std_ulogic_vector(unsigned(rot_max_size) - unsigned(rot_addr_le));

with op_size(0) select
    le_st_rot_sel <=       (others=>'0') when '1',
                     rot_size_le(2 to 5) when others;

be_st_rot_sel <= rot_sel_non_le(1 to 5);

with ex2_ovrd_rot select
    st_ovrd_rot_sel <= ex2_ovrd_rot_sel_q when '1',
                            be_st_rot_sel when others;

ex3_st_rot_sel_d <= st_ovrd_rot_sel;


rot_addr_d           <= rot_addr(1 to 5);
ex4_rot_addr_d       <= rot_addr_q;
rot_sel_non_le_d     <= rot_sel_non_le(1 to 5);
ex4_rot_sel_non_le_d <= rot_sel_non_le_q;

with ex4_le_mode_q select
    ex4_ld_rot_sel <=       ex4_rot_addr_q(1 to 5) when '1',
                      ex4_rot_sel_non_le_q(1 to 5) when others;

alg_bit_le_sel          <= std_ulogic_vector(unsigned(rot_size) - "000001");
ld_alg_le_sel_d(1 to 5) <= alg_bit_le_sel(1 to 5);
ex4_ld_alg_le_sel_d     <= ld_alg_le_sel_q;

with ex4_le_mode_q select
    ex4_ld_alg_sel <=      ex4_rot_addr_q when '0',
                      ex4_ld_alg_le_sel_q when others;

fu_ex2_store_data_val <= (ex2_axu_op_val_q and ex2_store_instr_q) or ex2_saxu_instr_q;
fu_ex2_store_data     <= fu_xu_ex2_store_data;

ex2_st_data_d                              <= xu_lsu_ex1_store_data;
ex2_st_data_fixup(0 to 127-(2**regmode))   <= (others=>'0');
ex2_st_data_fixup(128-(2**regmode) to 127) <= ex2_st_data_q;

with rel_data_rot_sel select
    rel_xu_data <=                              rel_data when '1',
                   ex2_st_data_fixup & ex2_st_data_fixup when others;

ex2_fu_data_val <= fu_ex2_store_data_val and not rel_data_rot_sel;

with ex2_fu_data_val select
    rel_ex2_data <= fu_ex2_store_data when '1',
                          rel_xu_data when others;

stDataFrmtBit : for bit in 0 to 7 generate begin
      stDataFrmtByte : for byte in 0 to 31 generate begin
            rel_ex3_data_d((bit*32)+byte) <= rel_ex2_data((byte*8)+bit);
      end generate stDataFrmtByte;
end generate stDataFrmtBit;




ex4_store_hit_early_gate <= ex4_store_hit and not ex7_ld_par_err(0);
rel_ex4_store_hit        <= ex4_store_hit_early_gate or rel_upd_dcarr_val;
ex4_thrd_id_mask         <= gate(ex4_thrd_id_q, not rel_upd_dcarr_val);

ex4Flushb0: ex4_stg_flush_lcl_b(0) <= not (xu_lsu_ex4_flush_local(0) and ex4_thrd_id_mask(0));
ex4Flushb1: ex4_stg_flush_lcl_b(1) <= not (xu_lsu_ex4_flush_local(1) and ex4_thrd_id_mask(1));
ex4Flushb2: ex4_stg_flush_lcl_b(2) <= not (xu_lsu_ex4_flush_local(2) and ex4_thrd_id_mask(2));
ex4Flushb3: ex4_stg_flush_lcl_b(3) <= not (xu_lsu_ex4_flush_local(3) and ex4_thrd_id_mask(3));

ex4Flush01b: ex4_flush_t01_b  <= not (ex4_stg_flush_lcl_b(0) and ex4_stg_flush_lcl_b(1));
ex4Flush23b: ex4_flush_t23_b  <= not (ex4_stg_flush_lcl_b(2) and ex4_stg_flush_lcl_b(3));
relex4UpdEn: rel_ex4_upd_en   <= not (ex4_flush_t01_b or ex4_flush_t23_b);

ex4_stg_flush <= (xu_lsu_ex4_flush(0) and ex4_thrd_id_q(0)) or
                 (xu_lsu_ex4_flush(1) and ex4_thrd_id_q(1)) or
                 (xu_lsu_ex4_flush(2) and ex4_thrd_id_q(2)) or
                 (xu_lsu_ex4_flush(3) and ex4_thrd_id_q(3));

ex5_stg_flush <= (xu_lsu_ex5_flush(0) and ex5_thrd_id_q(0)) or
                 (xu_lsu_ex5_flush(1) and ex5_thrd_id_q(1)) or
                 (xu_lsu_ex5_flush(2) and ex5_thrd_id_q(2)) or
                 (xu_lsu_ex5_flush(3) and ex5_thrd_id_q(3));


ex2_ovrd_rot      <= ex2_saxu_instr_q or ex2_stgpr_instr_q;
ex3_ovrd_rot_d    <= ex2_ovrd_rot;
ex3_stgpr_instr_d <= ex2_stgpr_instr_q;
ex4_stgpr_instr_d <= ex3_stgpr_instr_q;

stDataFixUp : for byte in 0 to 31 generate
    ex4_256st_dataFixUp(byte*8 to (byte*8)+7) <= st_256data(byte)     & st_256data(byte+32)  & st_256data(byte+64)  & st_256data(byte+96) &
                                                 st_256data(byte+128) & st_256data(byte+160) & st_256data(byte+192) & st_256data(byte+224);
end generate stDataFixUp;

ex4_stgpr_data   <= ex4_256st_dataFixUp(256-(2**regmode) to 255);
ex5_stgpr_data_d <= ex4_stgpr_data;
ex3_sdp_instr_d  <= ex2_sdp_instr_q;
ex4_sdp_instr_d  <= ex3_sdp_instr_q;
ex5_sdp_instr_d  <= ex4_sdp_instr_q;


pargen : for t in 0 to 31 generate begin
      rel_ex2_par_gen(t) <= xor_reduce(rel_ex2_data(t*8 to (t*8)+7));
end generate pargen;

rel_ex3_par_gen_d <= rel_ex2_par_gen;



non_le_byte_bit0 <= rel_data(0)   & rel_data(8)   & rel_data(16)  & rel_data(24)  & rel_data(32)  & rel_data(40)  & rel_data(48)  & rel_data(56)  &
                    rel_data(64)  & rel_data(72)  & rel_data(80)  & rel_data(88)  & rel_data(96)  & rel_data(104) & rel_data(112) & rel_data(120) &
                    rel_data(128) & rel_data(136) & rel_data(144) & rel_data(152) & rel_data(160) & rel_data(168) & rel_data(176) & rel_data(184) &
                    rel_data(192) & rel_data(200) & rel_data(208) & rel_data(216) & rel_data(224) & rel_data(232) & rel_data(240) & rel_data(248);

le_byte_bit0 <= rel_data(248) & rel_data(240) & rel_data(232) & rel_data(224) & rel_data(216) & rel_data(208) & rel_data(200) & rel_data(192) &
                rel_data(184) & rel_data(176) & rel_data(168) & rel_data(160) & rel_data(152) & rel_data(144) & rel_data(136) & rel_data(128) &
                rel_data(120) & rel_data(112) & rel_data(104) & rel_data(96)  & rel_data(88)  & rel_data(80)  & rel_data(72)  & rel_data(64)  &
                rel_data(56)  & rel_data(48)  & rel_data(40)  & rel_data(32)  & rel_data(24)  & rel_data(16)  & rel_data(8)   & rel_data(0);

with rel_le_mode select
    alg_byte <=     le_byte_bit0 when '1',
                non_le_byte_bit0 when others;

alg_bit_sel <= std_ulogic_vector(unsigned(rel_rot_sel) - unsigned(rel_op_size(1 to 5)));

with alg_bit_sel select
    algebraic_bit <= alg_byte(0)  when "00000",
                     alg_byte(1)  when "00001",
                     alg_byte(2)  when "00010",
                     alg_byte(3)  when "00011",
                     alg_byte(4)  when "00100",
                     alg_byte(5)  when "00101",
                     alg_byte(6)  when "00110",
                     alg_byte(7)  when "00111",
                     alg_byte(8)  when "01000",
                     alg_byte(9)  when "01001",
                     alg_byte(10) when "01010",
                     alg_byte(11) when "01011",
                     alg_byte(12) when "01100",
                     alg_byte(13) when "01101",
                     alg_byte(14) when "01110",
                     alg_byte(15) when "01111",
                     alg_byte(16) when "10000",
                     alg_byte(17) when "10001",
                     alg_byte(18) when "10010",
                     alg_byte(19) when "10011",
                     alg_byte(20) when "10100",
                     alg_byte(21) when "10101",
                     alg_byte(22) when "10110",
                     alg_byte(23) when "10111",
                     alg_byte(24) when "11000",
                     alg_byte(25) when "11001",
                     alg_byte(26) when "11010",
                     alg_byte(27) when "11011",
                     alg_byte(28) when "11100",
                     alg_byte(29) when "11101",
                     alg_byte(30) when "11110",
                     alg_byte(31) when others;

rel_alg_bit_d <= algebraic_bit;


l1dcst: entity work.xuq_lsu_data_st(xuq_lsu_data_st)
GENERIC MAP(expand_type         => expand_type,
            regmode             => regmode,
            l_endian_m          => l_endian_m)
PORT MAP(

     ex2_stg_act                => ex2_stg_act_q,
     ex3_stg_act                => ex3_stg_act_q,
     rel2_stg_act               => rel2_stg_act_q,
     rel3_stg_act               => rel3_stg_act_q,
     rel2_ex2_stg_act           => rel2_ex2_stg_act,
     rel3_ex3_stg_act           => rel3_ex3_stg_act,

     rel_data_rot_sel           => rel_data_rot_sel,
     ldq_rel_rot_sel            => rel_rot_sel,
     ldq_rel_op_size            => rel_op_size,
     ldq_rel_le_mode            => rel_le_mode,
     ldq_rel_algebraic          => rel_algebraic,
     ldq_rel_data_val           => rel_data_val,
     rel_alg_bit                => rel_alg_bit_q,

     ex2_opsize                 => op_size,
     ex2_rot_sel                => st_ovrd_rot_sel,
     ex2_rot_sel_le             => le_st_rot_sel,
     ex2_rot_addr               => rot_addr(1 to 5),
     ex4_le_mode_sel            => ex4_le_mode_sel_q,
     ex4_be_mode_sel            => ex4_be_mode_sel_q,

     rel_ex3_data               => rel_ex3_data_q,
     rel_ex3_par_gen            => rel_ex3_par_gen_q,

     rel_256ld_data             => rel_256ld_data,
     rel_64ld_data              => rel_64ld_data,
     rel_xu_ld_par              => rel_xu_ld_par,
     ex4_256st_data             => st_256data,
     ex3_byte_en                => ex3_byte_en,
     ex4_parity_gen             => ex4_parity_gen,
     rel_axu_le_mode            => rel_axu_le_mode,
     rel_dvc_byte_mask          => rel_dvc_byte_mask,

     vdd                        => vdd,
     gnd                        => gnd,
     nclk                       => nclk,
     sg_0                       => sg_0,
     func_sl_thold_0_b          => func_sl_thold_0_b,
     func_sl_force => func_sl_force,
     func_nsl_thold_0_b         => func_nsl_thold_0_b,
     func_nsl_force => func_nsl_force,
     d_mode_dc                  => d_mode_dc,
     delay_lclkr_dc             => delay_lclkr_dc(5),
     mpw1_dc_b                  => mpw1_dc_b(5),
     mpw2_dc_b                  => mpw2_dc_b,
     scan_in                    => func_scan_in_2_q(2),
     scan_out                   => func_scan_out_int(2)
);


l1dcarr : entity work.xuq_lsu_dc_arr(xuq_lsu_dc_arr)
generic map(expand_type => expand_type,         
            dc_size     => dc_size)             
port map(

     ex3_stg_act                => ex3_stg_act_q,
     ex4_stg_act                => ex4_stg_act_q,
     rel3_stg_act               => rel3_stg_act_q,
     rel4_stg_act               => rel4_stg_act_q,

     ex3_p_addr                 => ex3_p_addr_q(uprCClassBit to 58),
     ex3_byte_en                => ex3_byte_en,
     ex4_256st_data             => st_256data,
     ex4_parity_gen             => ex4_parity_gen,
     ex4_load_hit               => ex4_load_hit,
     ex5_stg_flush              => ex5_stg_flush,

     inj_dcache_parity          => inj_dcache_parity_q,

     ldq_rel_data_val           => rel_data_val(0),
     ldq_rel_addr               => rel_addr_q,

     dcarr_rd_data              => dcarr_rd_data,
     dcarr_bw                   => dcarr_bw,
     dcarr_addr                 => dcarr_addr,
     dcarr_wr_data              => dcarr_wr_data,
     dcarr_bw_dly               => dcarr_bw_dly,

     ex5_ld_data                => ex5_ld_data,
     ex5_ld_data_par            => ex5_ld_data_par,
     ex6_par_chk_val            => ex6_par_chk_val,

     vdd                        => vdd,
     gnd                        => gnd,
     nclk                       => nclk,
     sg_0                       => sg_0,
     func_sl_thold_0_b          => func_sl_thold_0_b,
     func_sl_force => func_sl_force,
     func_nsl_thold_0_b         => func_nsl_thold_0_b,
     func_nsl_force => func_nsl_force,
     d_mode_dc                  => d_mode_dc,
     delay_lclkr_dc             => delay_lclkr_dc(5),
     mpw1_dc_b                  => mpw1_dc_b(5),
     mpw2_dc_b                  => mpw2_dc_b,
     scan_in                    => siv1(l1dcar_offset),
     scan_out                   => sov1(l1dcar_offset)
);


dcArrWenb: dcarr_wren_b <= not (rel_ex4_store_hit and rel_ex4_upd_en);
dcArrWen:  dcarr_wren   <= not (dcarr_wren_b);

dcarr_wren_d  <= dcarr_wren;
dat_dbg_arr_d <= ex4_store_hit     & (not rel_ex4_upd_en) & rel_upd_dcarr_val & rel4_ex4_stg_act &
                 dcarr_up_way_addr & dcarr_addr;

dc16K: if (2**dc_size) = 16384 generate
    tridcarr: entity tri.tri_512x288_9(tri_512x288_9)       
      GENERIC Map(addressable_ports   => 512,                 
                  addressbus_width    => 6,                   
                  port_bitwidth       => 288,                 
                  bit_write_type      => 9,                   
                  ways                => 1,                   
                  expand_type         => expand_type)         
      PORT Map(
               vcs                        => vcs,
               vdd                        => vdd,
               gnd                        => gnd,

               nclk                       => nclk,
               act                        => rel4_ex4_stg_act,
               sg_0                       => sg_0,
               sg_1                       => sg_1,
               ary_nsl_thold_0            => ary_nsl_thold_0,
               abst_sl_thold_0            => abst_sl_thold_0,
               time_sl_thold_0            => time_sl_thold_0,
               repr_sl_thold_0            => repr_sl_thold_0,
               clkoff_dc_b                => g6t_clkoff_dc_b,
               ccflush_dc                 => pc_xu_ccflush_dc,
               scan_dis_dc_b              => an_ac_scan_dis_dc_b,
               scan_diag_dc               => an_ac_scan_diag_dc,
               d_mode_dc                  => g6t_d_mode_dc,
               act_dis_dc                 => tidn,
               lcb_delay_lclkr_np_dc      => g6t_delay_lclkr_dc(0),
               lcb_mpw1_pp_dc_b           => g6t_mpw1_dc_b(0),
               lcb_mpw1_2_pp_dc_b         => g6t_mpw1_dc_b(4),
               ctrl_lcb_delay_lclkr_np_dc => g6t_delay_lclkr_dc(1),
               ctrl_lcb_mpw1_np_dc_b      => g6t_mpw1_dc_b(1),
               dibw_lcb_delay_lclkr_np_dc => g6t_delay_lclkr_dc(2),
               dibw_lcb_mpw1_np_dc_b      => g6t_mpw1_dc_b(2),
               aodo_lcb_delay_lclkr_dc    => g6t_delay_lclkr_dc(3),
               aodo_lcb_mpw1_dc_b         => g6t_mpw1_dc_b(3),
               aodo_lcb_mpw2_dc_b         => g6t_mpw2_dc_b,

               bitw_abist                 => pc_xu_abist_g6t_bw_q,
               tc_lbist_ary_wrt_thru_dc   => an_ac_lbist_ary_wrt_thru_dc,
               abist_en_1                 => pc_xu_abist_ena_dc, 
               din_abist                  => pc_xu_abist_di_g6t_2r_q,
               abist_cmp_en               => pc_xu_abist_wl512_comp_ena_q,
               abist_raw_b_dc             => pc_xu_abist_raw_dc_b,
               data_cmp_abist             => pc_xu_abist_dcomp_g6t_2r_q,
               addr_abist                 => pc_xu_abist_raddr_0_q,
               r_wb_abist                 => pc_xu_abist_g6t_r_wb_q,

               abst_scan_in(0)            => abist_siv(0),
               abst_scan_in(1)            => abst_scan_in_q(1),
               time_scan_in               => time_scan_in_q,
               repr_scan_in               => repr_scan_in_q,
               abst_scan_out(0)           => abist_sov(0),
               abst_scan_out(1)           => abst_scan_out_int(1),
               time_scan_out              => time_scan_out_int,
               repr_scan_out              => repr_scan_out_int,

               lcb_bolt_sl_thold_0        => bolt_sl_thold_0,
               pc_bo_enable_2             => bo_enable_2,
               pc_bo_reset                => pc_xu_bo_reset,
               pc_bo_unload               => pc_xu_bo_unload,
               pc_bo_repair               => pc_xu_bo_repair,
               pc_bo_shdata               => pc_xu_bo_shdata,
               pc_bo_select               => pc_xu_bo_select,
               bo_pc_failout              => xu_pc_bo_fail,
               bo_pc_diagloop             => xu_pc_bo_diagout,
               tri_lcb_mpw1_dc_b          => mpw1_dc_b(5),
               tri_lcb_mpw2_dc_b          => mpw2_dc_b,
               tri_lcb_delay_lclkr_dc     => delay_lclkr_dc(5),
               tri_lcb_clkoff_dc_b        => clkoff_dc_b,
               tri_lcb_act_dis_dc         => tidn,


               write_enable               => dcarr_wren,
               bw                         => dcarr_bw,
               arr_up_addr                => dcarr_up_way_addr,
               addr                       => dcarr_addr,
               data_in                    => dcarr_wr_data,
               data_out                   => dcarr_rd_data
               );      
end generate dc16K;

dc32K: if (2**dc_size) = 32768 generate
    tridcarr: entity tri.tri_512x288_9(tri_512x288_9)       
      GENERIC Map(addressable_ports   => 1024,                
                  addressbus_width    => 7,                   
                  port_bitwidth       => 288,                 
                  bit_write_type      => 9,                   
                  ways                => 1,                   
                  expand_type         => expand_type)         
      PORT Map(
               vcs                        => vcs,
               vdd                        => vdd,
               gnd                        => gnd,

               nclk                       => nclk,
               act                        => rel4_ex4_stg_act,
               sg_0                       => sg_0,
               sg_1                       => sg_1,
               ary_nsl_thold_0            => ary_nsl_thold_0,
               abst_sl_thold_0            => abst_sl_thold_0,
               time_sl_thold_0            => time_sl_thold_0,
               repr_sl_thold_0            => repr_sl_thold_0,
               clkoff_dc_b                => g6t_clkoff_dc_b,
               ccflush_dc                 => pc_xu_ccflush_dc,
               scan_dis_dc_b              => an_ac_scan_dis_dc_b,
               scan_diag_dc               => an_ac_scan_diag_dc,
               d_mode_dc                  => g6t_d_mode_dc,
               act_dis_dc                 => tidn,
               lcb_delay_lclkr_np_dc      => g6t_delay_lclkr_dc(0),
               lcb_mpw1_pp_dc_b           => g6t_mpw1_dc_b(0),
               lcb_mpw1_2_pp_dc_b         => g6t_mpw1_dc_b(4),
               ctrl_lcb_delay_lclkr_np_dc => g6t_delay_lclkr_dc(1),
               ctrl_lcb_mpw1_np_dc_b      => g6t_mpw1_dc_b(1),
               dibw_lcb_delay_lclkr_np_dc => g6t_delay_lclkr_dc(2),
               dibw_lcb_mpw1_np_dc_b      => g6t_mpw1_dc_b(2),
               aodo_lcb_delay_lclkr_dc    => g6t_delay_lclkr_dc(3),
               aodo_lcb_mpw1_dc_b         => g6t_mpw1_dc_b(3),
               aodo_lcb_mpw2_dc_b         => g6t_mpw2_dc_b,

               bitw_abist                 => pc_xu_abist_g6t_bw_q,
               tc_lbist_ary_wrt_thru_dc   => an_ac_lbist_ary_wrt_thru_dc,
               abist_en_1                 => pc_xu_abist_ena_dc, 
               din_abist                  => pc_xu_abist_di_g6t_2r_q,
               abist_cmp_en               => pc_xu_abist_wl512_comp_ena_q,
               abist_raw_b_dc             => pc_xu_abist_raw_dc_b,
               data_cmp_abist             => pc_xu_abist_dcomp_g6t_2r_q,
               addr_abist                 => pc_xu_abist_raddr_0_q,
               r_wb_abist                 => pc_xu_abist_g6t_r_wb_q,

               abst_scan_in(0)            => abist_siv(0),
               abst_scan_in(1)            => abst_scan_in_q(1),
               time_scan_in               => time_scan_in_q,
               repr_scan_in               => repr_scan_in_q,
               abst_scan_out(0)           => abist_sov(0),
               abst_scan_out(1)           => abst_scan_out_int(1),
               time_scan_out              => time_scan_out_int,
               repr_scan_out              => repr_scan_out_int,

               lcb_bolt_sl_thold_0        => bolt_sl_thold_0,
               pc_bo_enable_2             => bo_enable_2,
               pc_bo_reset                => pc_xu_bo_reset,
               pc_bo_unload               => pc_xu_bo_unload,
               pc_bo_repair               => pc_xu_bo_repair,
               pc_bo_shdata               => pc_xu_bo_shdata,
               pc_bo_select               => pc_xu_bo_select,
               bo_pc_failout              => xu_pc_bo_fail,
               bo_pc_diagloop             => xu_pc_bo_diagout,
               tri_lcb_mpw1_dc_b          => mpw1_dc_b(5),
               tri_lcb_mpw2_dc_b          => mpw2_dc_b,
               tri_lcb_delay_lclkr_dc     => delay_lclkr_dc(5),
               tri_lcb_clkoff_dc_b        => clkoff_dc_b,
               tri_lcb_act_dis_dc         => tidn,
               
               write_enable               => dcarr_wren,
               bw                         => dcarr_bw,
               arr_up_addr                => dcarr_up_way_addr,
               addr                       => dcarr_addr,
               data_in                    => dcarr_wr_data,
               data_out                   => dcarr_rd_data
               );      
end generate dc32K;

ex3_opsize_d  <= op_size;

rel_axu_le_val_d      <= rel_axu_le_mode and rel_upd_gpr_q;
rel_axu_le_val_stg1_d <= rel_axu_le_val_q;
ex5_rel_le_mode_d     <= (ex4_le_mode_q and not rel_axu_le_val_stg1_q) or rel_axu_le_val_stg1_q;

l1dcld: entity work.xuq_lsu_data_ld(xuq_lsu_data_ld)
GENERIC MAP(expand_type         => expand_type,		
            regmode             => regmode,
            l_endian_m          => l_endian_m)          
PORT MAP(

     ex3_stg_act                => ex3_stg_act_q,
     ex4_stg_act                => ex4_stg_act_q,
     ex5_stg_act                => ex5_stg_act_q,

     ex3_opsize                 => ex3_opsize_q,
     ex3_algebraic              => ex3_algebraic,
     ex4_ld_rot_sel             => ex4_ld_rot_sel,
     ex4_ld_alg_sel             => ex4_ld_alg_sel,
     ex4_le_mode                => ex4_le_mode_q,
     ex5_ld_data                => ex5_ld_data,
     ex5_ld_data_par            => ex5_ld_data_par,
     ex6_par_chk_val            => ex6_par_chk_val,

     trace_bus_enable           => trace_bus_enable_q,
     dat_debug_mux_ctrls        => dat_debug_mux_ctrls_q,
     dat_dbg_ld_dat             => dat_dbg_ld_dat,

     ld_swzl_data (0 to 255)               => ld_swzl_data(0 to 255)  ,
     ex6_ld_alg_bit(0 to  5)               => ex6_ld_alg_bit(0 to  5)  ,
     ex6_ld_dvc_byte_mask       => ex6_ld_dvc_byte_mask,


     ex6_ld_par_err             => ex6_ld_par_err_int,
     ex7_ld_par_err             => ex7_ld_par_err,

     vdd                        => vdd,
     gnd                        => gnd,
     nclk                       => nclk,
     sg_0                       => sg_0,
     func_sl_thold_0_b          => func_sl_thold_0_b,
     func_sl_force => func_sl_force,
     func_nsl_thold_0_b         => func_nsl_thold_0_b,
     func_nsl_force => func_nsl_force,
     d_mode_dc                  => d_mode_dc,
     delay_lclkr_dc             => delay_lclkr_dc(5),
     mpw1_dc_b                  => mpw1_dc_b(5),
     mpw2_dc_b                  => mpw2_dc_b,
     scan_in                    => siv1(l1dcld_offset),
     scan_out                   => sov1(l1dcld_offset)
);


stDbgData : for byte in 0 to 7 generate begin
      rel_ex3_store_data0(byte*8 to (byte*8)+7) <= rel_ex3_data_q(byte+0)   & rel_ex3_data_q(byte+32)  & rel_ex3_data_q(byte+64)  & rel_ex3_data_q(byte+96) &
                                                   rel_ex3_data_q(byte+128) & rel_ex3_data_q(byte+160) & rel_ex3_data_q(byte+192) & rel_ex3_data_q(byte+224);
      rel_ex3_store_data1(byte*8 to (byte*8)+7) <= rel_ex3_data_q(8+byte+0)   & rel_ex3_data_q(8+byte+32)  & rel_ex3_data_q(8+byte+64)  & rel_ex3_data_q(8+byte+96) &
                                                   rel_ex3_data_q(8+byte+128) & rel_ex3_data_q(8+byte+160) & rel_ex3_data_q(8+byte+192) & rel_ex3_data_q(8+byte+224);
      rel_ex3_store_data2(byte*8 to (byte*8)+7) <= rel_ex3_data_q(16+byte+0)   & rel_ex3_data_q(16+byte+32)  & rel_ex3_data_q(16+byte+64)  & rel_ex3_data_q(16+byte+96) &
                                                   rel_ex3_data_q(16+byte+128) & rel_ex3_data_q(16+byte+160) & rel_ex3_data_q(16+byte+192) & rel_ex3_data_q(16+byte+224);
      rel_ex3_store_data3(byte*8 to (byte*8)+7) <= rel_ex3_data_q(24+byte+0)   & rel_ex3_data_q(24+byte+32)  & rel_ex3_data_q(24+byte+64)  & rel_ex3_data_q(24+byte+96) &
                                                   rel_ex3_data_q(24+byte+128) & rel_ex3_data_q(24+byte+160) & rel_ex3_data_q(24+byte+192) & rel_ex3_data_q(24+byte+224);
end generate stDbgData;

with dat_debug_mux_ctrls_q select
    dat_dbg_st_dat_d <= rel_ex3_store_data0 when "00",
                        rel_ex3_store_data1 when "01",
                        rel_ex3_store_data2 when "10",
                        rel_ex3_store_data3 when others;






lsu_xu_data_debug0(0 to 21)  <= ex4_saxu_instr_q & ex4_sdp_instr_q & ex4_stgpr_instr_q & ex4_axu_op_val_q &
                                ex4_algebraic_q  & ex4_le_mode_q   & ex4_ld_rot_sel    & ex4_p_addr_q;
lsu_xu_data_debug0(22 to 43) <= ex7_load_hit_q & ex7_ld_par_err(1) & dat_dbg_ld_dat(0 to 19);
lsu_xu_data_debug0(44 to 65) <= dat_dbg_ld_dat(20 to 41);
lsu_xu_data_debug0(66 to 87) <= dat_dbg_ld_dat(42 to 63);





lsu_xu_data_debug1(0 to 21)  <= dcarr_wren_q    & rel_ci_dly_q  & ex4_saxu_instr_q & ex4_stgpr_instr_q &
                                ex3_fu_st_val_q & ex4_le_mode_q & ex3_st_rot_sel_q & ex4_p_addr_q;
lsu_xu_data_debug1(22 to 43) <= ex3_store_instr_q & rel_data_val_stg_dly_q & dat_dbg_st_dat_q(0 to 19);
lsu_xu_data_debug1(44 to 65) <= dat_dbg_st_dat_q(20 to 41);
lsu_xu_data_debug1(66 to 87) <= dat_dbg_st_dat_q(42 to 63);




         
lsu_xu_data_debug2(0 to 21)  <= dat_dbg_arr_q(0 to 2) & dat_dbg_arr_q(4 to 12) & dcarr_bw_dly(0 to 9);
lsu_xu_data_debug2(22 to 43) <= dcarr_bw_dly(10 to 31);
lsu_xu_data_debug2(44 to 65) <= dat_dbg_arr_q(3) & dat_dbg_st_dat_q(21 to 41);
lsu_xu_data_debug2(66 to 87) <= dat_dbg_st_dat_q(42 to 63);


dvcCmpSt : for t in (64-(2**regmode))/8 to 7 generate begin
      ex2_st_dvc1_cmp_d(t) <= (xu_lsu_ex1_store_data(t*8 to (t*8)+7) =
                                      spr_dvc1_dbg_q(t*8 to (t*8)+7));
      ex2_st_dvc2_cmp_d(t) <= (xu_lsu_ex1_store_data(t*8 to (t*8)+7) =
                                      spr_dvc2_dbg_q(t*8 to (t*8)+7));
end generate dvcCmpSt;

ex5_dvc1_en_d <= ex4_load_hit and not ex4_axu_op_val;
ex5_dvc2_en_d <= ex4_load_hit and not ex4_axu_op_val;
ex6_dvc1_en_d <= ex5_dvc1_en_q;
ex6_dvc2_en_d <= ex5_dvc2_en_q;
ex7_dvc1_en_d <= gate(ex6_ld_dvc_byte_mask, ex6_dvc1_en_q);
ex7_dvc2_en_d <= gate(ex6_ld_dvc_byte_mask, ex6_dvc2_en_q);

dvcCmpLd : for t in (64-(2**regmode))/8 to 7 generate begin
      ex8_ld_dvc1_cmp_d(t) <= ex7_dvc1_en_q(t) and (ex7_xld_data_q(t*8 to (t*8)+7) =
                                                    spr_dvc1_dbg_q(t*8 to (t*8)+7));
      ex8_ld_dvc2_cmp_d(t) <= ex7_dvc2_en_q(t) and (ex7_xld_data_q(t*8 to (t*8)+7) =
                                                    spr_dvc2_dbg_q(t*8 to (t*8)+7));
end generate dvcCmpLd;

rel_dvc1_val_d      <= rel_dvc1_en_q and not rel_axu_val_q;
rel_dvc1_val_stg_d  <= rel_upd_gpr_q and rel_dvc1_val_q and not ldq_rel_beat_crit_qw_block;
rel_dvc1_val_stg2_d <= rel_dvc1_val_stg_q;
rel_dvc2_val_d      <= rel_dvc2_en_q and not rel_axu_val_q;
rel_dvc2_val_stg_d  <= rel_upd_gpr_q and rel_dvc2_val_q and not ldq_rel_beat_crit_qw_block;
rel_dvc2_val_stg2_d <= rel_dvc2_val_stg_q;
rel_dvc_thrd_id_d   <= rel_thrd_id_q;
rel_dvc_tid_stg_d   <= rel_dvc_thrd_id_q;
rel_dvc_tid_stg2_d  <= rel_dvc_tid_stg_q;

dvcCmpRl : for t in (64-(2**regmode))/8 to 7 generate begin
      rel_dvc1_cmp_d(t) <= (rel_64ld_data(t*8 to (t*8)+7) =
                           spr_dvc1_dbg_q(t*8 to (t*8)+7)) and rel_dvc_byte_mask(t);
      rel_dvc2_cmp_d(t) <= (rel_64ld_data(t*8 to (t*8)+7) =
                           spr_dvc2_dbg_q(t*8 to (t*8)+7)) and rel_dvc_byte_mask(t);
end generate dvcCmpRl;


ex6_stgpr_dp_data_d(0 to 127-(2**regmode))   <= ex5_dp_data(0 to 127-(2**regmode));
ex6_stgpr_dp_data_d(128-(2**regmode) to 127) <= gate(ex5_dp_data(128-(2**regmode) to 127), ex5_sdp_instr_q) or
                                                gate(ex5_stgpr_data_q(64-(2**regmode) to 63), not ex5_sdp_instr_q);

axu_data_sel <= (ex4_sdp_instr_q or ex4_stgpr_instr_q) & axu_rel_val_stg2_q;

with axu_data_sel select
    ex5_axu_data_sel_d <= "001" when "00",
                          "100" when "10",
                          "010" when others;

selGen : for sel in 0 to 15 generate begin
      ex6_axu_data_sel_d(3*sel to (3*sel)+2) <= ex5_axu_data_sel_q;
end generate selGen;

ex5_stgpr_dp_instr_d <= ex4_sdp_instr_q or ex4_stgpr_instr_q;
ex6_stgpr_dp_instr_d <= ex5_stgpr_dp_instr_q;


rel_256ld_data_stg1_d <= rel_256ld_data;
rel_256ld_data_stg2_d <= rel_256ld_data_stg1_q;


    ex6_rot_sel(0 to 15) <= not axu_rel_upd_q(0 to 15) ; 

 axuldreldata : for t in 0 to 15 generate begin

     ex6_axu_oth_b(t*8 to (t*8)+7) <= not( gate(rel_256ld_data_stg2_q(t*8 to (t*8)+7),     axu_rel_upd_q(t)) );

 end generate axuldreldata;

axuRelGpr : for byte in 0 to 15 generate
    ex6_axu_rel_gpr_data(8*byte to (8*byte)+7) <= gate(ex6_stgpr_dp_data_q(8*byte to (8*byte)+7), ex6_axu_data_sel_q((byte*3))) or
                                                  gate(rel_256ld_data_stg2_q(128+(8*byte) to 128+(8*byte)+7), ex6_axu_data_sel_q((byte*3)+1));

    ex6_axu_rel_gpr_data_sel(byte)   <= not ex6_axu_data_sel_q((byte*3)+2);
    ex6_rot_sel(16 + byte)           <=     ex6_axu_data_sel_q((byte*3)+2);

    ex6_axu_oth_b(128+(8*byte) to 128+(8*byte)+7) <= not(  gate(ex6_axu_rel_gpr_data(8*byte to (8*byte)+7),     ex6_axu_rel_gpr_data_sel(byte) )  ); 

end generate axuRelGpr;


   ex6_rot_sel_bus(0 to 255) <= (  0 to   7 => ex6_rot_sel( 0) ) &
                                (  0 to   7 => ex6_rot_sel( 1) ) &
                                (  0 to   7 => ex6_rot_sel( 2) ) &
                                (  0 to   7 => ex6_rot_sel( 3) ) &
                                (  0 to   7 => ex6_rot_sel( 4) ) &
                                (  0 to   7 => ex6_rot_sel( 5) ) &
                                (  0 to   7 => ex6_rot_sel( 6) ) &
                                (  0 to   7 => ex6_rot_sel( 7) ) &
                                (  0 to   7 => ex6_rot_sel( 8) ) &
                                (  0 to   7 => ex6_rot_sel( 9) ) &
                                (  0 to   7 => ex6_rot_sel(10) ) &
                                (  0 to   7 => ex6_rot_sel(11) ) &
                                (  0 to   7 => ex6_rot_sel(12) ) &
                                (  0 to   7 => ex6_rot_sel(13) ) &
                                (  0 to   7 => ex6_rot_sel(14) ) &
                                (  0 to   7 => ex6_rot_sel(15) ) &
                                (  0 to   7 => ex6_rot_sel(16) ) &
                                (  0 to   7 => ex6_rot_sel(17) ) &
                                (  0 to   7 => ex6_rot_sel(18) ) &
                                (  0 to   7 => ex6_rot_sel(19) ) &
                                (  0 to   7 => ex6_rot_sel(20) ) &
                                (  0 to   7 => ex6_rot_sel(21) ) &
                                (  0 to   7 => ex6_rot_sel(22) ) &
                                (  0 to   7 => ex6_rot_sel(23) ) &
                                (  0 to   7 => ex6_rot_sel(24) ) &
                                (  0 to   7 => ex6_rot_sel(25) ) &
                                (  0 to   7 => ex6_rot_sel(26) ) &
                                (  0 to   7 => ex6_rot_sel(27) ) &
                                (  0 to   7 => ex6_rot_sel(28) ) &
                                (  0 to   7 => ex6_rot_sel(29) ) &
                                (  0 to   7 => ex6_rot_sel(30) ) &
                                (  0 to   7 => ex6_rot_sel(31) ) ;


 u_axu_rot:      ex6_frot_b         (0 to 255) <= not( ld_swzl_data (0 to 255) and ex6_rot_sel_bus(0 to 255) ); 
 u_axu_dat:      ex6_fdat           (0 to 255) <= not( ex6_frot_b   (0 to 255) and ex6_axu_oth_b  (0 to 255) ); 

 u_axu_dati:     xu_fu_ex6_load_data  (0 to 255) <= ex6_fdat(0 to 255);


 ex6_stgpr_dp_instr_q_b <= not ex6_stgpr_dp_instr_q ;


 u_xrot_i:    ex6_rot_d_b(0 to 63)    <= not( ld_swzl_data(192 to 255) );
 u_xrot_ii:   ex6_rot_d  (0 to 63)    <= not( ex6_rot_d_b(0 to 63)     );

 u_xld_sgn:   ex6_xld_sgnx_b(0 to  5) <= not( ex6_ld_alg_bit(0 to 5)        and (0 to  5=> ex6_stgpr_dp_instr_q_b) );
 u_xld_sgni:  ex6_xld_sgn   (0 to  5) <= not( ex6_xld_sgnx_b(0 to 5) );
 u_xld_sgnii: ex6_xld_sgn_b (0 to  5) <= not( ex6_xld_sgn   (0 to 5) );

 u_xld_rot:   ex6_xld_rot_b(0 to 63)  <= not( ex6_rot_d(0 to 63)             and (0 to 63=> ex6_stgpr_dp_instr_q_b) );
 u_xld_oth:   ex6_xld_oth_b(0 to 63)  <= not( ex6_stgpr_dp_data_q(64 to 127) and (0 to 63=> ex6_stgpr_dp_instr_q  ) );

 u_xld_or_00: ex6_xld_data( 0) <= not( ex6_xld_rot_b( 0) and ex6_xld_sgn_b( 0) and ex6_xld_oth_b( 0) );
 u_xld_or_01: ex6_xld_data( 1) <= not( ex6_xld_rot_b( 1) and ex6_xld_sgn_b( 0) and ex6_xld_oth_b( 1) );
 u_xld_or_02: ex6_xld_data( 2) <= not( ex6_xld_rot_b( 2) and ex6_xld_sgn_b( 1) and ex6_xld_oth_b( 2) );
 u_xld_or_03: ex6_xld_data( 3) <= not( ex6_xld_rot_b( 3) and ex6_xld_sgn_b( 1) and ex6_xld_oth_b( 3) );
 u_xld_or_04: ex6_xld_data( 4) <= not( ex6_xld_rot_b( 4) and ex6_xld_sgn_b( 2) and ex6_xld_oth_b( 4) );
 u_xld_or_05: ex6_xld_data( 5) <= not( ex6_xld_rot_b( 5) and ex6_xld_sgn_b( 2) and ex6_xld_oth_b( 5) );
 u_xld_or_06: ex6_xld_data( 6) <= not( ex6_xld_rot_b( 6) and ex6_xld_sgn_b( 3) and ex6_xld_oth_b( 6) );
 u_xld_or_07: ex6_xld_data( 7) <= not( ex6_xld_rot_b( 7) and ex6_xld_sgn_b( 3) and ex6_xld_oth_b( 7) );

 u_xld_or_08: ex6_xld_data( 8) <= not( ex6_xld_rot_b( 8) and ex6_xld_sgn_b( 0) and ex6_xld_oth_b( 8) );
 u_xld_or_09: ex6_xld_data( 9) <= not( ex6_xld_rot_b( 9) and ex6_xld_sgn_b( 0) and ex6_xld_oth_b( 9) );
 u_xld_or_10: ex6_xld_data(10) <= not( ex6_xld_rot_b(10) and ex6_xld_sgn_b( 1) and ex6_xld_oth_b(10) );
 u_xld_or_11: ex6_xld_data(11) <= not( ex6_xld_rot_b(11) and ex6_xld_sgn_b( 1) and ex6_xld_oth_b(11) );
 u_xld_or_12: ex6_xld_data(12) <= not( ex6_xld_rot_b(12) and ex6_xld_sgn_b( 2) and ex6_xld_oth_b(12) );
 u_xld_or_13: ex6_xld_data(13) <= not( ex6_xld_rot_b(13) and ex6_xld_sgn_b( 2) and ex6_xld_oth_b(13) );
 u_xld_or_14: ex6_xld_data(14) <= not( ex6_xld_rot_b(14) and ex6_xld_sgn_b( 3) and ex6_xld_oth_b(14) );
 u_xld_or_15: ex6_xld_data(15) <= not( ex6_xld_rot_b(15) and ex6_xld_sgn_b( 3) and ex6_xld_oth_b(15) );

 u_xld_or_16: ex6_xld_data(16) <= not( ex6_xld_rot_b(16) and ex6_xld_sgn_b( 0) and ex6_xld_oth_b(16) );
 u_xld_or_17: ex6_xld_data(17) <= not( ex6_xld_rot_b(17) and ex6_xld_sgn_b( 0) and ex6_xld_oth_b(17) );
 u_xld_or_18: ex6_xld_data(18) <= not( ex6_xld_rot_b(18) and ex6_xld_sgn_b( 1) and ex6_xld_oth_b(18) );
 u_xld_or_19: ex6_xld_data(19) <= not( ex6_xld_rot_b(19) and ex6_xld_sgn_b( 1) and ex6_xld_oth_b(19) );
 u_xld_or_20: ex6_xld_data(20) <= not( ex6_xld_rot_b(20) and ex6_xld_sgn_b( 2) and ex6_xld_oth_b(20) );
 u_xld_or_21: ex6_xld_data(21) <= not( ex6_xld_rot_b(21) and ex6_xld_sgn_b( 2) and ex6_xld_oth_b(21) );
 u_xld_or_22: ex6_xld_data(22) <= not( ex6_xld_rot_b(22) and ex6_xld_sgn_b( 3) and ex6_xld_oth_b(22) );
 u_xld_or_23: ex6_xld_data(23) <= not( ex6_xld_rot_b(23) and ex6_xld_sgn_b( 3) and ex6_xld_oth_b(23) );

 u_xld_or_24: ex6_xld_data(24) <= not( ex6_xld_rot_b(24) and ex6_xld_sgn_b( 0) and ex6_xld_oth_b(24) );
 u_xld_or_25: ex6_xld_data(25) <= not( ex6_xld_rot_b(25) and ex6_xld_sgn_b( 0) and ex6_xld_oth_b(25) );
 u_xld_or_26: ex6_xld_data(26) <= not( ex6_xld_rot_b(26) and ex6_xld_sgn_b( 1) and ex6_xld_oth_b(26) );
 u_xld_or_27: ex6_xld_data(27) <= not( ex6_xld_rot_b(27) and ex6_xld_sgn_b( 1) and ex6_xld_oth_b(27) );
 u_xld_or_28: ex6_xld_data(28) <= not( ex6_xld_rot_b(28) and ex6_xld_sgn_b( 2) and ex6_xld_oth_b(28) );
 u_xld_or_29: ex6_xld_data(29) <= not( ex6_xld_rot_b(29) and ex6_xld_sgn_b( 2) and ex6_xld_oth_b(29) );
 u_xld_or_30: ex6_xld_data(30) <= not( ex6_xld_rot_b(30) and ex6_xld_sgn_b( 3) and ex6_xld_oth_b(30) );
 u_xld_or_31: ex6_xld_data(31) <= not( ex6_xld_rot_b(31) and ex6_xld_sgn_b( 3) and ex6_xld_oth_b(31) );

 u_xld_or_32: ex6_xld_data(32) <= not( ex6_xld_rot_b(32) and ex6_xld_sgn_b( 4) and ex6_xld_oth_b(32) );
 u_xld_or_33: ex6_xld_data(33) <= not( ex6_xld_rot_b(33) and ex6_xld_sgn_b( 4) and ex6_xld_oth_b(33) );
 u_xld_or_34: ex6_xld_data(34) <= not( ex6_xld_rot_b(34) and ex6_xld_sgn_b( 4) and ex6_xld_oth_b(34) );
 u_xld_or_35: ex6_xld_data(35) <= not( ex6_xld_rot_b(35) and ex6_xld_sgn_b( 4) and ex6_xld_oth_b(35) );
 u_xld_or_36: ex6_xld_data(36) <= not( ex6_xld_rot_b(36) and ex6_xld_sgn_b( 5) and ex6_xld_oth_b(36) );
 u_xld_or_37: ex6_xld_data(37) <= not( ex6_xld_rot_b(37) and ex6_xld_sgn_b( 5) and ex6_xld_oth_b(37) );
 u_xld_or_38: ex6_xld_data(38) <= not( ex6_xld_rot_b(38) and ex6_xld_sgn_b( 5) and ex6_xld_oth_b(38) );
 u_xld_or_39: ex6_xld_data(39) <= not( ex6_xld_rot_b(39) and ex6_xld_sgn_b( 5) and ex6_xld_oth_b(39) );

 u_xld_or_40: ex6_xld_data(40) <= not( ex6_xld_rot_b(40) and ex6_xld_sgn_b( 4) and ex6_xld_oth_b(40) );
 u_xld_or_41: ex6_xld_data(41) <= not( ex6_xld_rot_b(41) and ex6_xld_sgn_b( 4) and ex6_xld_oth_b(41) );
 u_xld_or_42: ex6_xld_data(42) <= not( ex6_xld_rot_b(42) and ex6_xld_sgn_b( 4) and ex6_xld_oth_b(42) );
 u_xld_or_43: ex6_xld_data(43) <= not( ex6_xld_rot_b(43) and ex6_xld_sgn_b( 4) and ex6_xld_oth_b(43) );
 u_xld_or_44: ex6_xld_data(44) <= not( ex6_xld_rot_b(44) and ex6_xld_sgn_b( 5) and ex6_xld_oth_b(44) );
 u_xld_or_45: ex6_xld_data(45) <= not( ex6_xld_rot_b(45) and ex6_xld_sgn_b( 5) and ex6_xld_oth_b(45) );
 u_xld_or_46: ex6_xld_data(46) <= not( ex6_xld_rot_b(46) and ex6_xld_sgn_b( 5) and ex6_xld_oth_b(46) );
 u_xld_or_47: ex6_xld_data(47) <= not( ex6_xld_rot_b(47) and ex6_xld_sgn_b( 5) and ex6_xld_oth_b(47) );

 u_xld_or_48: ex6_xld_data(48) <= not( ex6_xld_rot_b(48)                       and ex6_xld_oth_b(48) );
 u_xld_or_49: ex6_xld_data(49) <= not( ex6_xld_rot_b(49)                       and ex6_xld_oth_b(49) );
 u_xld_or_50: ex6_xld_data(50) <= not( ex6_xld_rot_b(50)                       and ex6_xld_oth_b(50) );
 u_xld_or_51: ex6_xld_data(51) <= not( ex6_xld_rot_b(51)                       and ex6_xld_oth_b(51) );
 u_xld_or_52: ex6_xld_data(52) <= not( ex6_xld_rot_b(52)                       and ex6_xld_oth_b(52) );
 u_xld_or_53: ex6_xld_data(53) <= not( ex6_xld_rot_b(53)                       and ex6_xld_oth_b(53) );
 u_xld_or_54: ex6_xld_data(54) <= not( ex6_xld_rot_b(54)                       and ex6_xld_oth_b(54) );
 u_xld_or_55: ex6_xld_data(55) <= not( ex6_xld_rot_b(55)                       and ex6_xld_oth_b(55) );
 u_xld_or_56: ex6_xld_data(56) <= not( ex6_xld_rot_b(56)                       and ex6_xld_oth_b(56) );
 u_xld_or_57: ex6_xld_data(57) <= not( ex6_xld_rot_b(57)                       and ex6_xld_oth_b(57) );
 u_xld_or_58: ex6_xld_data(58) <= not( ex6_xld_rot_b(58)                       and ex6_xld_oth_b(58) );
 u_xld_or_59: ex6_xld_data(59) <= not( ex6_xld_rot_b(59)                       and ex6_xld_oth_b(59) );
 u_xld_or_60: ex6_xld_data(60) <= not( ex6_xld_rot_b(60)                       and ex6_xld_oth_b(60) );
 u_xld_or_61: ex6_xld_data(61) <= not( ex6_xld_rot_b(61)                       and ex6_xld_oth_b(61) );
 u_xld_or_62: ex6_xld_data(62) <= not( ex6_xld_rot_b(62)                       and ex6_xld_oth_b(62) );
 u_xld_or_63: ex6_xld_data(63) <= not( ex6_xld_rot_b(63)                       and ex6_xld_oth_b(63) );


 u_xld_oi:       ex6_xld_data_b(0 to 63) <= not( ex6_xld_data  (0 to 63) );  
 u_dont_do_this: dont_do_this            <= not( ex6_xld_data_b(0 to 63) );  

ex7_xld_data_d <= dont_do_this(64-(2**regmode) to 63);

ex6_xu_ld_data_b(0 to 63) <= ex6_xld_data_b(0 to 63);


DCPerr: tri_direct_err_rpt
generic map(width => 1, expand_type => expand_type)
port map(
      vd      => vdd,
      gd      => gnd,
      err_in  => ex7_ld_par_err(0 to 0),
      err_out => dcache_parity(0 to 0)
);

ex8_ld_par_err_d <= ex7_ld_par_err(0);

my_spare_latches_d     <= not my_spare_latches_q;


xu_pc_err_dcache_parity <= dcache_parity(0);

lsu_xu_ex2_dvc1_st_cmp <= ex2_st_dvc1_cmp_q and ex2_xu_cmp_val_q;
lsu_xu_ex2_dvc2_st_cmp <= ex2_st_dvc2_cmp_q and ex2_xu_cmp_val_q;
lsu_xu_ex8_dvc1_ld_cmp <= gate(ex8_ld_dvc1_cmp_q, not ex8_ld_par_err_q);
lsu_xu_ex8_dvc2_ld_cmp <= gate(ex8_ld_dvc2_cmp_q, not ex8_ld_par_err_q);
lsu_xu_rel_dvc1_en     <= rel_dvc1_val_stg2_q;
lsu_xu_rel_dvc1_cmp    <= rel_dvc1_cmp_q;
lsu_xu_rel_dvc2_en     <= rel_dvc2_val_stg2_q;
lsu_xu_rel_dvc2_cmp    <= rel_dvc2_cmp_q;
lsu_xu_rel_dvc_thrd_id <= rel_dvc_tid_stg2_q;

ex4_256st_data <= ex4_256st_dataFixUp;

rel_xu_ld_data          <= rel_64ld_data(64-(2**regmode) to 63) & rel_xu_ld_par(0 to ((2**regmode)/8)-1);
lsu_xu_ex6_datc_par_err <= ex6_ld_par_err_int;
ex6_ld_par_err          <= ex6_ld_par_err_int;

xu_fu_ex5_load_le   <= ex5_rel_le_mode_q;

abst_scan_out    <= gate(abst_scan_out_q, an_ac_scan_dis_dc_b);
time_scan_out    <= time_scan_out_q    and an_ac_scan_dis_dc_b;
repr_scan_out    <= repr_scan_out_q    and an_ac_scan_dis_dc_b;
func_scan_out(0) <= func_scan_out_2_q(0) and an_ac_scan_dis_dc_b;
func_scan_out(1) <= func_scan_out_2_q(1) and an_ac_scan_dis_dc_b;
func_scan_out(2) <= func_scan_out_2_q(2) and an_ac_scan_dis_dc_b;

ex3_opsize_reg: tri_rlmreg_p
  generic map (width => 6, init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => ex2_stg_act_q,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc(5),
            mpw1_b  => mpw1_dc_b(5),
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv0(ex3_opsize_offset to ex3_opsize_offset + ex3_opsize_d'length-1),
            scout   => sov0(ex3_opsize_offset to ex3_opsize_offset + ex3_opsize_d'length-1),
            din     => ex3_opsize_d,
            dout    => ex3_opsize_q);

ex3_ovrd_rot_reg: tri_rlmlatch_p
generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => ex2_stg_act_q,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc(5),
            mpw1_b  => mpw1_dc_b(5),
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv0(ex3_ovrd_rot_offset),
            scout   => sov0(ex3_ovrd_rot_offset),
            din     => ex3_ovrd_rot_d,
            dout    => ex3_ovrd_rot_q);

ex4_le_mode_reg: tri_regk
generic map (width => 1, init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => rel3_ex3_stg_act,
            forcee => func_nsl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc(5),
            mpw1_b  => mpw1_dc_b(5),
            mpw2_b  => mpw2_dc_b,
            thold_b => func_nsl_thold_0_b,
            din(0)  => ex4_le_mode_d,
            dout(0) => ex4_le_mode_q);

ex4_le_mode_sel_reg: tri_rlmreg_p
generic map (width => 16, init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => rel3_ex3_stg_act,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc(5),
            mpw1_b  => mpw1_dc_b(5),
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv0(ex4_le_mode_sel_offset to ex4_le_mode_sel_offset + ex4_le_mode_sel_d'length-1),
            scout   => sov0(ex4_le_mode_sel_offset to ex4_le_mode_sel_offset + ex4_le_mode_sel_d'length-1),
            din     => ex4_le_mode_sel_d,
            dout    => ex4_le_mode_sel_q);

ex4_be_mode_sel_reg: tri_rlmreg_p
generic map (width => 16, init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => rel3_ex3_stg_act,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc(5),
            mpw1_b  => mpw1_dc_b(5),
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv0(ex4_be_mode_sel_offset to ex4_be_mode_sel_offset + ex4_be_mode_sel_d'length-1),
            scout   => sov0(ex4_be_mode_sel_offset to ex4_be_mode_sel_offset + ex4_be_mode_sel_d'length-1),
            din     => ex4_be_mode_sel_d,
            dout    => ex4_be_mode_sel_q);

ex5_load_hit_reg: tri_rlmlatch_p
generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => ex4_stg_act_q,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc(5),
            mpw1_b  => mpw1_dc_b(5),
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv0(ex5_load_hit_offset),
            scout   => sov0(ex5_load_hit_offset),
            din     => ex5_load_hit_d,
            dout    => ex5_load_hit_q);

ex6_load_hit_reg: tri_regk
generic map (width => 1, init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => ex5_stg_act_q,
            forcee => func_nsl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc(5),
            mpw1_b  => mpw1_dc_b(5),
            mpw2_b  => mpw2_dc_b,
            thold_b => func_nsl_thold_0_b,
            din(0)  => ex6_load_hit_d,
            dout(0) => ex6_load_hit_q);

ex7_load_hit_reg: tri_rlmlatch_p
generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => ex6_stg_act_q,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc(5),
            mpw1_b  => mpw1_dc_b(5),
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv0(ex7_load_hit_offset),
            scout   => sov0(ex7_load_hit_offset),
            din     => ex7_load_hit_d,
            dout    => ex7_load_hit_q);

ex2_st_data_reg: tri_rlmreg_p
generic map (width => (2**regmode), init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => ex1_stg_act_q,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc(5),
            mpw1_b  => mpw1_dc_b(5),
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv0(ex2_st_data_offset to ex2_st_data_offset + ex2_st_data_d'length-1),
            scout   => sov0(ex2_st_data_offset to ex2_st_data_offset + ex2_st_data_d'length-1),
            din     => ex2_st_data_d,
            dout    => ex2_st_data_q);

axu_rel_upd_reg: tri_rlmreg_p
generic map (width => 16, init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => tiup,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc(5),
            mpw1_b  => mpw1_dc_b(5),
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv0(axu_rel_upd_offset to axu_rel_upd_offset + axu_rel_upd_d'length-1),
            scout   => sov0(axu_rel_upd_offset to axu_rel_upd_offset + axu_rel_upd_d'length-1),
            din     => axu_rel_upd_d,
            dout    => axu_rel_upd_q);

rel_data_val_reg: tri_rlmreg_p
generic map (width => 16, init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => tiup,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc(5),
            mpw1_b  => mpw1_dc_b(5),
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv0(rel_data_val_offset to rel_data_val_offset + rel_data_val_d'length-1),
            scout   => sov0(rel_data_val_offset to rel_data_val_offset + rel_data_val_d'length-1),
            din     => rel_data_val_d,
            dout    => rel_data_val_q);

rel_addr_stg_reg: tri_rlmreg_p
generic map (width => 58-uprCClassBit+1, init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => rel1_stg_act_q,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc(5),
            mpw1_b  => mpw1_dc_b(5),
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv0(rel_addr_stg_offset to rel_addr_stg_offset + rel_addr_stg_d'length-1),
            scout   => sov0(rel_addr_stg_offset to rel_addr_stg_offset + rel_addr_stg_d'length-1),
            din     => rel_addr_stg_d,
            dout    => rel_addr_stg_q);

rel_addr_reg: tri_rlmreg_p
generic map (width => 58-uprCClassBit+1, init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => rel2_stg_act_q,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc(5),
            mpw1_b  => mpw1_dc_b(5),
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv0(rel_addr_offset to rel_addr_offset + rel_addr_d'length-1),
            scout   => sov0(rel_addr_offset to rel_addr_offset + rel_addr_d'length-1),
            din     => rel_addr_d,
            dout    => rel_addr_q);

ex5_axu_data_sel_reg: tri_rlmreg_p
generic map (width => 3, init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => tiup,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc(5),
            mpw1_b  => mpw1_dc_b(5),
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv0(ex5_axu_data_sel_offset to ex5_axu_data_sel_offset + ex5_axu_data_sel_d'length-1),
            scout   => sov0(ex5_axu_data_sel_offset to ex5_axu_data_sel_offset + ex5_axu_data_sel_d'length-1),
            din     => ex5_axu_data_sel_d,
            dout    => ex5_axu_data_sel_q);

rel_ex3_data_reg: tri_regk
  generic map (width => 256, init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => rel2_ex2_stg_act,
            forcee => func_nsl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc(5),
            mpw1_b  => mpw1_dc_b(5),
            mpw2_b  => mpw2_dc_b,
            thold_b => func_nsl_thold_0_b,
            din     => rel_ex3_data_d,
            dout    => rel_ex3_data_q);

rel_alg_bit_reg: tri_regk
generic map (width => 1, init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => rel2_stg_act_q,
            forcee => func_nsl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc(5),
            mpw1_b  => mpw1_dc_b(5),
            mpw2_b  => mpw2_dc_b,
            thold_b => func_nsl_thold_0_b,
            din(0)  => rel_alg_bit_d,
            dout(0) => rel_alg_bit_q);

ex5_stgpr_data_reg: tri_regk
  generic map (width => (2**regmode), init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => ex4_stg_act_q,
            forcee => func_nsl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc(5),
            mpw1_b  => mpw1_dc_b(5),
            mpw2_b  => mpw2_dc_b,
            thold_b => func_nsl_thold_0_b,
            din     => ex5_stgpr_data_d,
            dout    => ex5_stgpr_data_q);

ex6_axu_data_sel_0reg: tri_regk
  generic map (width => 24, init => 2396745, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => tiup,
            forcee => func_nsl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc(5),
            mpw1_b  => mpw1_dc_b(5),
            mpw2_b  => mpw2_dc_b,
            thold_b => func_nsl_thold_0_b,
            din     => ex6_axu_data_sel_d(0 to 23),
            dout    => ex6_axu_data_sel_q(0 to 23));

ex6_axu_data_sel_1reg: tri_regk
  generic map (width => 24, init => 2396745, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => tiup,
            forcee => func_nsl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc(5),
            mpw1_b  => mpw1_dc_b(5),
            mpw2_b  => mpw2_dc_b,
            thold_b => func_nsl_thold_0_b,
            din     => ex6_axu_data_sel_d(24 to 47),
            dout    => ex6_axu_data_sel_q(24 to 47));

ex3_stgpr_instr_reg: tri_rlmlatch_p
generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => tiup,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc(5),
            mpw1_b  => mpw1_dc_b(5),
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv0(ex3_stgpr_instr_offset),
            scout   => sov0(ex3_stgpr_instr_offset),
            din     => ex3_stgpr_instr_d,
            dout    => ex3_stgpr_instr_q);

ex4_stgpr_instr_reg: tri_rlmlatch_p
generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => tiup,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc(5),
            mpw1_b  => mpw1_dc_b(5),
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv0(ex4_stgpr_instr_offset),
            scout   => sov0(ex4_stgpr_instr_offset),
            din     => ex4_stgpr_instr_d,
            dout    => ex4_stgpr_instr_q);

ex3_sdp_instr_reg: tri_rlmlatch_p
generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => tiup,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc(5),
            mpw1_b  => mpw1_dc_b(5),
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv0(ex3_sdp_instr_offset),
            scout   => sov0(ex3_sdp_instr_offset),
            din     => ex3_sdp_instr_d,
            dout    => ex3_sdp_instr_q);

ex4_sdp_instr_reg: tri_rlmlatch_p
generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => tiup,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc(5),
            mpw1_b  => mpw1_dc_b(5),
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv0(ex4_sdp_instr_offset),
            scout   => sov0(ex4_sdp_instr_offset),
            din     => ex4_sdp_instr_d,
            dout    => ex4_sdp_instr_q);

ex5_sdp_instr_reg: tri_rlmlatch_p
generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => tiup,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc(5),
            mpw1_b  => mpw1_dc_b(5),
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv0(ex5_sdp_instr_offset),
            scout   => sov0(ex5_sdp_instr_offset),
            din     => ex5_sdp_instr_d,
            dout    => ex5_sdp_instr_q);

rot_addr_reg: tri_rlmreg_p
  generic map (width => 5, init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => ex2_stg_act_q,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc(5),
            mpw1_b  => mpw1_dc_b(5),
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv0(rot_addr_offset to rot_addr_offset + rot_addr_d'length-1),
            scout   => sov0(rot_addr_offset to rot_addr_offset + rot_addr_d'length-1),
            din     => rot_addr_d,
            dout    => rot_addr_q);

ex4_rot_addr_reg: tri_regk
  generic map (width => 5, init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => ex3_stg_act_q,
            forcee => func_nsl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc(5),
            mpw1_b  => mpw1_dc_b(5),
            mpw2_b  => mpw2_dc_b,
            thold_b => func_nsl_thold_0_b,
            din     => ex4_rot_addr_d,
            dout    => ex4_rot_addr_q);

rot_sel_non_le_reg: tri_rlmreg_p
  generic map (width => 5, init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => ex2_stg_act_q,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc(5),
            mpw1_b  => mpw1_dc_b(5),
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv0(rot_sel_non_le_offset to rot_sel_non_le_offset + rot_sel_non_le_d'length-1),
            scout   => sov0(rot_sel_non_le_offset to rot_sel_non_le_offset + rot_sel_non_le_d'length-1),
            din     => rot_sel_non_le_d,
            dout    => rot_sel_non_le_q);

ex4_rot_sel_non_le_reg: tri_regk
  generic map (width => 5, init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => ex3_stg_act_q,
            forcee => func_nsl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc(5),
            mpw1_b  => mpw1_dc_b(5),
            mpw2_b  => mpw2_dc_b,
            thold_b => func_nsl_thold_0_b,
            din     => ex4_rot_sel_non_le_d,
            dout    => ex4_rot_sel_non_le_q);

ex2_st_dvc1_cmp_reg: tri_regk
  generic map (width => ((2**regmode)/8), init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => ex1_stg_act_q,
            forcee => func_nsl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc(5),
            mpw1_b  => mpw1_dc_b(5),
            mpw2_b  => mpw2_dc_b,
            thold_b => func_nsl_thold_0_b,
            din     => ex2_st_dvc1_cmp_d,
            dout    => ex2_st_dvc1_cmp_q);

ex5_dvc1_en_reg: tri_rlmlatch_p
generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => tiup,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc(5),
            mpw1_b  => mpw1_dc_b(5),
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv0(ex5_dvc1_en_offset),
            scout   => sov0(ex5_dvc1_en_offset),
            din     => ex5_dvc1_en_d,
            dout    => ex5_dvc1_en_q);

ex6_dvc1_en_reg: tri_rlmlatch_p
generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => tiup,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc(5),
            mpw1_b  => mpw1_dc_b(5),
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv0(ex6_dvc1_en_offset),
            scout   => sov0(ex6_dvc1_en_offset),
            din     => ex6_dvc1_en_d,
            dout    => ex6_dvc1_en_q);

ex7_dvc1_en_reg: tri_rlmreg_p
generic map (width => ((2**regmode)/8), init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => tiup,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc(5),
            mpw1_b  => mpw1_dc_b(5),
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv0(ex7_dvc1_en_offset to ex7_dvc1_en_offset + ex7_dvc1_en_d'length-1),
            scout   => sov0(ex7_dvc1_en_offset to ex7_dvc1_en_offset + ex7_dvc1_en_d'length-1),
            din     => ex7_dvc1_en_d,
            dout    => ex7_dvc1_en_q);

rel_dvc1_val_reg: tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => rel2_stg_act_q,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc(5),
            mpw1_b  => mpw1_dc_b(5),
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv0(rel_dvc1_val_offset),
            scout   => sov0(rel_dvc1_val_offset),
            din     => rel_dvc1_val_d,
            dout    => rel_dvc1_val_q);

ex8_ld_dvc1_cmp_reg: tri_rlmreg_p
  generic map (width => ((2**regmode)/8), init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => tiup,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc(5),
            mpw1_b  => mpw1_dc_b(5),
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv0(ex8_ld_dvc1_cmp_offset to ex8_ld_dvc1_cmp_offset + ex8_ld_dvc1_cmp_d'length-1),
            scout   => sov0(ex8_ld_dvc1_cmp_offset to ex8_ld_dvc1_cmp_offset + ex8_ld_dvc1_cmp_d'length-1),
            din     => ex8_ld_dvc1_cmp_d,
            dout    => ex8_ld_dvc1_cmp_q);

rel_dvc1_val_stg_reg: tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => tiup,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc(5),
            mpw1_b  => mpw1_dc_b(5),
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv0(rel_dvc1_val_stg_offset),
            scout   => sov0(rel_dvc1_val_stg_offset),
            din     => rel_dvc1_val_stg_d,
            dout    => rel_dvc1_val_stg_q);

rel_dvc1_val_stg2_reg: tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => tiup,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc(5),
            mpw1_b  => mpw1_dc_b(5),
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv0(rel_dvc1_val_stg2_offset),
            scout   => sov0(rel_dvc1_val_stg2_offset),
            din     => rel_dvc1_val_stg2_d,
            dout    => rel_dvc1_val_stg2_q);

rel_dvc1_cmp_reg: tri_regk
  generic map (width => ((2**regmode)/8), init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => rel4_stg_act_q,
            forcee => func_nsl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc(5),
            mpw1_b  => mpw1_dc_b(5),
            mpw2_b  => mpw2_dc_b,
            thold_b => func_nsl_thold_0_b,
            din     => rel_dvc1_cmp_d,
            dout    => rel_dvc1_cmp_q);

rel_dvc2_val_stg_reg: tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => tiup,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc(5),
            mpw1_b  => mpw1_dc_b(5),
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv0(rel_dvc2_val_stg_offset),
            scout   => sov0(rel_dvc2_val_stg_offset),
            din     => rel_dvc2_val_stg_d,
            dout    => rel_dvc2_val_stg_q);

rel_dvc2_val_stg2_reg: tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => tiup,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc(5),
            mpw1_b  => mpw1_dc_b(5),
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv0(rel_dvc2_val_stg2_offset),
            scout   => sov0(rel_dvc2_val_stg2_offset),
            din     => rel_dvc2_val_stg2_d,
            dout    => rel_dvc2_val_stg2_q);

rel_dvc2_cmp_reg: tri_regk
  generic map (width => ((2**regmode)/8), init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => rel4_stg_act_q,
            forcee => func_nsl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc(5),
            mpw1_b  => mpw1_dc_b(5),
            mpw2_b  => mpw2_dc_b,
            thold_b => func_nsl_thold_0_b,
            din     => rel_dvc2_cmp_d,
            dout    => rel_dvc2_cmp_q);

ex2_st_dvc2_cmp_reg: tri_regk
  generic map (width => ((2**regmode)/8), init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => ex1_stg_act_q,
            forcee => func_nsl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc(5),
            mpw1_b  => mpw1_dc_b(5),
            mpw2_b  => mpw2_dc_b,
            thold_b => func_nsl_thold_0_b,
            din     => ex2_st_dvc2_cmp_d,
            dout    => ex2_st_dvc2_cmp_q);

ex5_dvc2_en_reg: tri_rlmlatch_p
generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => tiup,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc(5),
            mpw1_b  => mpw1_dc_b(5),
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv0(ex5_dvc2_en_offset),
            scout   => sov0(ex5_dvc2_en_offset),
            din     => ex5_dvc2_en_d,
            dout    => ex5_dvc2_en_q);

ex6_dvc2_en_reg: tri_rlmlatch_p
generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => tiup,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc(5),
            mpw1_b  => mpw1_dc_b(5),
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv0(ex6_dvc2_en_offset),
            scout   => sov0(ex6_dvc2_en_offset),
            din     => ex6_dvc2_en_d,
            dout    => ex6_dvc2_en_q);

ex7_dvc2_en_reg: tri_rlmreg_p
generic map (width => ((2**regmode)/8), init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => tiup,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc(5),
            mpw1_b  => mpw1_dc_b(5),
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv0(ex7_dvc2_en_offset to ex7_dvc2_en_offset + ex7_dvc2_en_d'length-1),
            scout   => sov0(ex7_dvc2_en_offset to ex7_dvc2_en_offset + ex7_dvc2_en_d'length-1),
            din     => ex7_dvc2_en_d,
            dout    => ex7_dvc2_en_q);

rel_dvc2_val_reg: tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => rel2_stg_act_q,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc(5),
            mpw1_b  => mpw1_dc_b(5),
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv0(rel_dvc2_val_offset),
            scout   => sov0(rel_dvc2_val_offset),
            din     => rel_dvc2_val_d,
            dout    => rel_dvc2_val_q);

ex8_ld_dvc2_cmp_reg: tri_rlmreg_p
  generic map (width => ((2**regmode)/8), init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => tiup,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc(5),
            mpw1_b  => mpw1_dc_b(5),
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv0(ex8_ld_dvc2_cmp_offset to ex8_ld_dvc2_cmp_offset + ex8_ld_dvc2_cmp_d'length-1),
            scout   => sov0(ex8_ld_dvc2_cmp_offset to ex8_ld_dvc2_cmp_offset + ex8_ld_dvc2_cmp_d'length-1),
            din     => ex8_ld_dvc2_cmp_d,
            dout    => ex8_ld_dvc2_cmp_q);

ex2_optype32_reg: tri_rlmlatch_p
generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => ex1_stg_act_q,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc(5),
            mpw1_b  => mpw1_dc_b(5),
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv0(ex2_optype32_offset),
            scout   => sov0(ex2_optype32_offset),
            din     => ex2_optype32_d,
            dout    => ex2_optype32_q);

ex2_optype16_reg: tri_rlmlatch_p
generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => ex1_stg_act_q,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc(5),
            mpw1_b  => mpw1_dc_b(5),
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv0(ex2_optype16_offset),
            scout   => sov0(ex2_optype16_offset),
            din     => ex2_optype16_d,
            dout    => ex2_optype16_q);

ex2_optype8_reg: tri_rlmlatch_p
generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => ex1_stg_act_q,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc(5),
            mpw1_b  => mpw1_dc_b(5),
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv0(ex2_optype8_offset),
            scout   => sov0(ex2_optype8_offset),
            din     => ex2_optype8_d,
            dout    => ex2_optype8_q);

ex2_optype4_reg: tri_rlmlatch_p
generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => ex1_stg_act_q,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc(5),
            mpw1_b  => mpw1_dc_b(5),
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv0(ex2_optype4_offset),
            scout   => sov0(ex2_optype4_offset),
            din     => ex2_optype4_d,
            dout    => ex2_optype4_q);

ex2_optype2_reg: tri_rlmlatch_p
generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => ex1_stg_act_q,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc(5),
            mpw1_b  => mpw1_dc_b(5),
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv0(ex2_optype2_offset),
            scout   => sov0(ex2_optype2_offset),
            din     => ex2_optype2_d,
            dout    => ex2_optype2_q);

ex2_optype1_reg: tri_rlmlatch_p
generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => ex1_stg_act_q,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc(5),
            mpw1_b  => mpw1_dc_b(5),
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv0(ex2_optype1_offset),
            scout   => sov0(ex2_optype1_offset),
            din     => ex2_optype1_d,
            dout    => ex2_optype1_q);

ex2_p_addr_reg: tri_rlmreg_p
  generic map (width => 64-uprCClassBit, init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => ex1_stg_act_q,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc(5),
            mpw1_b  => mpw1_dc_b(5),
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv0(ex2_p_addr_offset to ex2_p_addr_offset + ex2_p_addr_d'length-1),
            scout   => sov0(ex2_p_addr_offset to ex2_p_addr_offset + ex2_p_addr_d'length-1),
            din     => ex2_p_addr_d,
            dout    => ex2_p_addr_q);

ex3_fu_st_val_reg: tri_regk
generic map (width => 1, init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => ex2_stg_act_q,
            forcee => func_nsl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc(5),
            mpw1_b  => mpw1_dc_b(5),
            mpw2_b  => mpw2_dc_b,
            thold_b => func_nsl_thold_0_b,
            din(0)  => ex3_fu_st_val_d,
            dout(0) => ex3_fu_st_val_q);

frc_p_addr_reg: tri_rlmreg_p
  generic map (width => 6, init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => ex1_stg_act_q,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc(5),
            mpw1_b  => mpw1_dc_b(5),
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv0(frc_p_addr_offset to frc_p_addr_offset + frc_p_addr_d'length-1),
            scout   => sov0(frc_p_addr_offset to frc_p_addr_offset + frc_p_addr_d'length-1),
            din     => frc_p_addr_d,
            dout    => frc_p_addr_q);

ex2_store_instr_reg: tri_rlmlatch_p
generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => ex1_stg_act_q,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc(5),
            mpw1_b  => mpw1_dc_b(5),
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv0(ex2_store_instr_offset),
            scout   => sov0(ex2_store_instr_offset),
            din     => ex2_store_instr_d,
            dout    => ex2_store_instr_q);

ex3_store_instr_reg: tri_regk
generic map (width => 1, init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => ex2_stg_act_q,
            forcee => func_nsl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc(5),
            mpw1_b  => mpw1_dc_b(5),
            mpw2_b  => mpw2_dc_b,
            thold_b => func_nsl_thold_0_b,
            din(0)  => ex3_store_instr_d,
            dout(0) => ex3_store_instr_q);

ex3_st_rot_sel_reg: tri_regk
generic map (width => 5, init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => ex2_stg_act_q,
            forcee => func_nsl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc(5),
            mpw1_b  => mpw1_dc_b(5),
            mpw2_b  => mpw2_dc_b,
            thold_b => func_nsl_thold_0_b,
            din     => ex3_st_rot_sel_d,
            dout    => ex3_st_rot_sel_q);

ex2_axu_op_val_reg: tri_rlmlatch_p
generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => ex1_stg_act_q,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc(5),
            mpw1_b  => mpw1_dc_b(5),
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv0(ex2_axu_op_val_offset),
            scout   => sov0(ex2_axu_op_val_offset),
            din     => ex2_axu_op_val_d,
            dout    => ex2_axu_op_val_q);

ex3_axu_op_val_reg: tri_regk
generic map (width => 1, init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => ex2_stg_act_q,
            forcee => func_nsl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc(5),
            mpw1_b  => mpw1_dc_b(5),
            mpw2_b  => mpw2_dc_b,
            thold_b => func_nsl_thold_0_b,
            din(0)  => ex3_axu_op_val_d,
            dout(0) => ex3_axu_op_val_q);

ex4_axu_op_val_reg: tri_rlmlatch_p
generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => ex1_stg_act_q,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc(5),
            mpw1_b  => mpw1_dc_b(5),
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv0(ex4_axu_op_val_offset),
            scout   => sov0(ex4_axu_op_val_offset),
            din     => ex4_axu_op_val_d,
            dout    => ex4_axu_op_val_q);

ex2_xu_cmp_val_reg: tri_rlmreg_p
  generic map (width => (2**regmode)/8, init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => ex1_stg_act_q,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc(5),
            mpw1_b  => mpw1_dc_b(5),
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv0(ex2_xu_cmp_val_offset to ex2_xu_cmp_val_offset + ex2_xu_cmp_val_d'length-1),
            scout   => sov0(ex2_xu_cmp_val_offset to ex2_xu_cmp_val_offset + ex2_xu_cmp_val_d'length-1),
            din     => ex2_xu_cmp_val_d,
            dout    => ex2_xu_cmp_val_q);

ex2_saxu_instr_reg: tri_rlmlatch_p
generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => tiup,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc(5),
            mpw1_b  => mpw1_dc_b(5),
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv0(ex2_saxu_instr_offset),
            scout   => sov0(ex2_saxu_instr_offset),
            din     => ex2_saxu_instr_d,
            dout    => ex2_saxu_instr_q);

ex2_sdp_instr_reg: tri_rlmlatch_p
generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => tiup,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc(5),
            mpw1_b  => mpw1_dc_b(5),
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv0(ex2_sdp_instr_offset),
            scout   => sov0(ex2_sdp_instr_offset),
            din     => ex2_sdp_instr_d,
            dout    => ex2_sdp_instr_q);

ex2_stgpr_instr_reg: tri_rlmlatch_p
generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => tiup,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc(5),
            mpw1_b  => mpw1_dc_b(5),
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv0(ex2_stgpr_instr_offset),
            scout   => sov0(ex2_stgpr_instr_offset),
            din     => ex2_stgpr_instr_d,
            dout    => ex2_stgpr_instr_q);

ex3_saxu_instr_reg: tri_regk
generic map (width => 1, init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => tiup,
            forcee => func_nsl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc(5),
            mpw1_b  => mpw1_dc_b(5),
            mpw2_b  => mpw2_dc_b,
            thold_b => func_nsl_thold_0_b,
            din(0)  => ex3_saxu_instr_d,
            dout(0) => ex3_saxu_instr_q);

ex4_saxu_instr_reg: tri_rlmlatch_p
generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => tiup,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc(5),
            mpw1_b  => mpw1_dc_b(5),
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv0(ex4_saxu_instr_offset),
            scout   => sov0(ex4_saxu_instr_offset),
            din     => ex4_saxu_instr_d,
            dout    => ex4_saxu_instr_q);

ex4_algebraic_reg: tri_rlmlatch_p
generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => tiup,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc(5),
            mpw1_b  => mpw1_dc_b(5),
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv0(ex4_algebraic_offset),
            scout   => sov0(ex4_algebraic_offset),
            din     => ex4_algebraic_d,
            dout    => ex4_algebraic_q);

ex2_ovrd_rot_sel_reg: tri_rlmreg_p
  generic map (width => 5, init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => ex1_stg_act_q,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc(5),
            mpw1_b  => mpw1_dc_b(5),
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv0(ex2_ovrd_rot_sel_offset to ex2_ovrd_rot_sel_offset + ex2_ovrd_rot_sel_d'length-1),
            scout   => sov0(ex2_ovrd_rot_sel_offset to ex2_ovrd_rot_sel_offset + ex2_ovrd_rot_sel_d'length-1),
            din     => ex2_ovrd_rot_sel_d,
            dout    => ex2_ovrd_rot_sel_q);

ex3_p_addr_reg: tri_regk
  generic map (width => 64-uprCClassBit, init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => ex2_stg_act_q,
            forcee => func_nsl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc(5),
            mpw1_b  => mpw1_dc_b(5),
            mpw2_b  => mpw2_dc_b,
            thold_b => func_nsl_thold_0_b,
            din     => ex3_p_addr_d,
            dout    => ex3_p_addr_q);

ex4_p_addr_reg: tri_rlmreg_p
  generic map (width => 64-uprCClassBit, init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => ex3_stg_act_q,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc(5),
            mpw1_b  => mpw1_dc_b(5),
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv0(ex4_p_addr_offset to ex4_p_addr_offset + ex4_p_addr_d'length-1),
            scout   => sov0(ex4_p_addr_offset to ex4_p_addr_offset + ex4_p_addr_d'length-1),
            din     => ex4_p_addr_d,
            dout    => ex4_p_addr_q);

rel_ex3_par_gen_reg: tri_regk
  generic map (width => 32, init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => rel2_ex2_stg_act,
            forcee => func_nsl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc(5),
            mpw1_b  => mpw1_dc_b(5),
            mpw2_b  => mpw2_dc_b,
            thold_b => func_nsl_thold_0_b,
            din     => rel_ex3_par_gen_d,
            dout    => rel_ex3_par_gen_q);

spr_xucr0_dcdis_reg: tri_rlmlatch_p
generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => tiup,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc(5),
            mpw1_b  => mpw1_dc_b(5),
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv0(spr_xucr0_dcdis_offset),
            scout   => sov0(spr_xucr0_dcdis_offset),
            din     => spr_xucr0_dcdis_d,
            dout    => spr_xucr0_dcdis_q);

clkg_ctl_override_reg: tri_rlmlatch_p
generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => tiup,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc(5),
            mpw1_b  => mpw1_dc_b(5),
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv0(clkg_ctl_override_offset),
            scout   => sov0(clkg_ctl_override_offset),
            din     => clkg_ctl_override_d,
            dout    => clkg_ctl_override_q);

rel_dvc_thrd_id_reg: tri_regk
  generic map (width => 4, init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => rel2_stg_act_q,
            forcee => func_nsl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc(5),
            mpw1_b  => mpw1_dc_b(5),
            mpw2_b  => mpw2_dc_b,
            thold_b => func_nsl_thold_0_b,
            din     => rel_dvc_thrd_id_d,
            dout    => rel_dvc_thrd_id_q);

rel_dvc_tid_stg_reg: tri_rlmreg_p
  generic map (width => 4, init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => tiup,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc(5),
            mpw1_b  => mpw1_dc_b(5),
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv0(rel_dvc_tid_stg_offset to rel_dvc_tid_stg_offset + rel_dvc_tid_stg_d'length-1),
            scout   => sov0(rel_dvc_tid_stg_offset to rel_dvc_tid_stg_offset + rel_dvc_tid_stg_d'length-1),
            din     => rel_dvc_tid_stg_d,
            dout    => rel_dvc_tid_stg_q);

rel_dvc_tid_stg2_reg: tri_regk
  generic map (width => 4, init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => tiup,
            forcee => func_nsl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc(5),
            mpw1_b  => mpw1_dc_b(5),
            mpw2_b  => mpw2_dc_b,
            thold_b => func_nsl_thold_0_b,
            din     => rel_dvc_tid_stg2_d,
            dout    => rel_dvc_tid_stg2_q);

inj_dcache_parity_reg: tri_rlmlatch_p
generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => tiup,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc(5),
            mpw1_b  => mpw1_dc_b(5),
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv0(inj_dcache_parity_offset),
            scout   => sov0(inj_dcache_parity_offset),
            din     => inj_dcache_parity_d,
            dout    => inj_dcache_parity_q);

ex5_stgpr_dp_instr_reg: tri_rlmlatch_p
generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => tiup,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc(5),
            mpw1_b  => mpw1_dc_b(5),
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv0(ex5_stgpr_dp_instr_offset),
            scout   => sov0(ex5_stgpr_dp_instr_offset),
            din     => ex5_stgpr_dp_instr_d,
            dout    => ex5_stgpr_dp_instr_q);

ex6_stgpr_dp_instr_reg: tri_rlmlatch_p
generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => tiup,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc(5),
            mpw1_b  => mpw1_dc_b(5),
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv0(ex6_stgpr_dp_instr_offset),
            scout   => sov0(ex6_stgpr_dp_instr_offset),
            din     => ex6_stgpr_dp_instr_d,
            dout    => ex6_stgpr_dp_instr_q);

ex6_stgpr_dp_data_reg: tri_rlmreg_p
  generic map (width => 128, init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => ex5_stg_act_q,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc(5),
            mpw1_b  => mpw1_dc_b(5),
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv0(ex6_stgpr_dp_data_offset to ex6_stgpr_dp_data_offset + ex6_stgpr_dp_data_d'length-1),
            scout   => sov0(ex6_stgpr_dp_data_offset to ex6_stgpr_dp_data_offset + ex6_stgpr_dp_data_d'length-1),
            din     => ex6_stgpr_dp_data_d,
            dout    => ex6_stgpr_dp_data_q);

ex5_rel_le_mode_reg: tri_rlmlatch_p
generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => tiup,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc(5),
            mpw1_b  => mpw1_dc_b(5),
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv0(ex5_rel_le_mode_offset),
            scout   => sov0(ex5_rel_le_mode_offset),
            din     => ex5_rel_le_mode_d,
            dout    => ex5_rel_le_mode_q);

ex1_ldst_falign_reg: tri_rlmlatch_p
generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => tiup,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc(5),
            mpw1_b  => mpw1_dc_b(5),
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv0(ex1_ldst_falign_offset),
            scout   => sov0(ex1_ldst_falign_offset),
            din     => ex1_ldst_falign_d,
            dout    => ex1_ldst_falign_q);

ex4_thrd_id_reg: tri_regk
  generic map (width => 4, init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => tiup,
            forcee => func_nsl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc(5),
            mpw1_b  => mpw1_dc_b(5),
            mpw2_b  => mpw2_dc_b,
            thold_b => func_nsl_thold_0_b,
            din     => ex4_thrd_id_d,
            dout    => ex4_thrd_id_q);

ex5_thrd_id_reg: tri_rlmreg_p
  generic map (width => 4, init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => tiup,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc(5),
            mpw1_b  => mpw1_dc_b(5),
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv0(ex5_thrd_id_offset to ex5_thrd_id_offset + ex5_thrd_id_d'length-1),
            scout   => sov0(ex5_thrd_id_offset to ex5_thrd_id_offset + ex5_thrd_id_d'length-1),
            din     => ex5_thrd_id_d,
            dout    => ex5_thrd_id_q);

axu_rel_val_stg1_reg: tri_rlmlatch_p
generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => tiup,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc(5),
            mpw1_b  => mpw1_dc_b(5),
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv0(axu_rel_val_stg1_offset),
            scout   => sov0(axu_rel_val_stg1_offset),
            din     => axu_rel_val_stg1_d,
            dout    => axu_rel_val_stg1_q);

axu_rel_val_stg2_reg: tri_rlmlatch_p
generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => tiup,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc(5),
            mpw1_b  => mpw1_dc_b(5),
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv0(axu_rel_val_stg2_offset),
            scout   => sov0(axu_rel_val_stg2_offset),
            din     => axu_rel_val_stg2_d,
            dout    => axu_rel_val_stg2_q);

axu_rel_val_stg3_reg: tri_rlmlatch_p
generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => tiup,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc(5),
            mpw1_b  => mpw1_dc_b(5),
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv0(axu_rel_val_stg3_offset),
            scout   => sov0(axu_rel_val_stg3_offset),
            din     => axu_rel_val_stg3_d,
            dout    => axu_rel_val_stg3_q);

rel_256ld_data_stg1_reg: tri_regk
generic map (width => 256, init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => rel4_stg_act_q,
            forcee => func_nsl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc(5),
            mpw1_b  => mpw1_dc_b(5),
            mpw2_b  => mpw2_dc_b,
            thold_b => func_nsl_thold_0_b,
            din     => rel_256ld_data_stg1_d,
            dout    => rel_256ld_data_stg1_q);

rel_256ld_data_stg2_reg: tri_rlmreg_p
generic map (width => 256, init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => rel5_stg_act_q,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc(5),
            mpw1_b  => mpw1_dc_b(5),
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv0(rel_256ld_data_stg2_offset to rel_256ld_data_stg2_offset + rel_256ld_data_stg2_d'length-1),
            scout   => sov0(rel_256ld_data_stg2_offset to rel_256ld_data_stg2_offset + rel_256ld_data_stg2_d'length-1),
            din     => rel_256ld_data_stg2_d,
            dout    => rel_256ld_data_stg2_q);

rel_axu_le_val_reg: tri_rlmlatch_p
generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => tiup,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc(5),
            mpw1_b  => mpw1_dc_b(5),
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv0(rel_axu_le_val_offset),
            scout   => sov0(rel_axu_le_val_offset),
            din     => rel_axu_le_val_d,
            dout    => rel_axu_le_val_q);

rel_axu_le_val_stg1_reg: tri_rlmlatch_p
generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => tiup,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc(5),
            mpw1_b  => mpw1_dc_b(5),
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv0(rel_axu_le_val_stg1_offset),
            scout   => sov0(rel_axu_le_val_stg1_offset),
            din     => rel_axu_le_val_stg1_d,
            dout    => rel_axu_le_val_stg1_q);

dcarr_wren_reg: tri_rlmlatch_p
generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => rel4_ex4_stg_act_q,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc(5),
            mpw1_b  => mpw1_dc_b(5),
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv0(dcarr_wren_offset),
            scout   => sov0(dcarr_wren_offset),
            din     => dcarr_wren_d,
            dout    => dcarr_wren_q);

dat_dbg_arr_reg: tri_rlmreg_p
generic map (width => 13, init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => trace_bus_enable_q,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc(5),
            mpw1_b  => mpw1_dc_b(5),
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv0(dat_dbg_arr_offset to dat_dbg_arr_offset + dat_dbg_arr_d'length-1),
            scout   => sov0(dat_dbg_arr_offset to dat_dbg_arr_offset + dat_dbg_arr_d'length-1),
            din     => dat_dbg_arr_d,
            dout    => dat_dbg_arr_q);

ld_alg_le_sel_reg: tri_rlmreg_p
generic map (width => 5, init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => ex2_stg_act_q,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc(5),
            mpw1_b  => mpw1_dc_b(5),
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv0(ld_alg_le_sel_offset to ld_alg_le_sel_offset + ld_alg_le_sel_d'length-1),
            scout   => sov0(ld_alg_le_sel_offset to ld_alg_le_sel_offset + ld_alg_le_sel_d'length-1),
            din     => ld_alg_le_sel_d,
            dout    => ld_alg_le_sel_q);

ex4_ld_alg_le_sel_reg: tri_regk
generic map (width => 5, init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => ex3_stg_act_q,
            forcee => func_nsl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc(5),
            mpw1_b  => mpw1_dc_b(5),
            mpw2_b  => mpw2_dc_b,
            thold_b => func_nsl_thold_0_b,
            din     => ex4_ld_alg_le_sel_d,
            dout    => ex4_ld_alg_le_sel_q);

ex1_stg_act_reg: tri_rlmlatch_p
generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => tiup,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc(5),
            mpw1_b  => mpw1_dc_b(5),
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv0(ex1_stg_act_offset),
            scout   => sov0(ex1_stg_act_offset),
            din     => ex1_stg_act_d,
            dout    => ex1_stg_act_q);

ex2_stg_act_reg: tri_rlmlatch_p
generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => tiup,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc(5),
            mpw1_b  => mpw1_dc_b(5),
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv0(ex2_stg_act_offset),
            scout   => sov0(ex2_stg_act_offset),
            din     => ex2_stg_act_d,
            dout    => ex2_stg_act_q);

ex3_stg_act_reg: tri_rlmlatch_p
generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => tiup,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc(5),
            mpw1_b  => mpw1_dc_b(5),
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv0(ex3_stg_act_offset),
            scout   => sov0(ex3_stg_act_offset),
            din     => ex3_stg_act_d,
            dout    => ex3_stg_act_q);

ex4_stg_act_reg: tri_rlmlatch_p
generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => tiup,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc(5),
            mpw1_b  => mpw1_dc_b(5),
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv0(ex4_stg_act_offset),
            scout   => sov0(ex4_stg_act_offset),
            din     => ex4_stg_act_d,
            dout    => ex4_stg_act_q);

ex5_stg_act_reg: tri_rlmlatch_p
generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => tiup,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc(5),
            mpw1_b  => mpw1_dc_b(5),
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv0(ex5_stg_act_offset),
            scout   => sov0(ex5_stg_act_offset),
            din     => ex5_stg_act_d,
            dout    => ex5_stg_act_q);

ex6_stg_act_reg: tri_rlmlatch_p
generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => tiup,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc(5),
            mpw1_b  => mpw1_dc_b(5),
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv0(ex6_stg_act_offset),
            scout   => sov0(ex6_stg_act_offset),
            din     => ex6_stg_act_d,
            dout    => ex6_stg_act_q);

rel1_stg_act_reg: tri_rlmlatch_p
generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => tiup,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc(5),
            mpw1_b  => mpw1_dc_b(5),
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv0(rel1_stg_act_offset),
            scout   => sov0(rel1_stg_act_offset),
            din     => rel1_stg_act_d,
            dout    => rel1_stg_act_q);

rel2_stg_act_reg: tri_rlmlatch_p
generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => tiup,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc(5),
            mpw1_b  => mpw1_dc_b(5),
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv0(rel2_stg_act_offset),
            scout   => sov0(rel2_stg_act_offset),
            din     => rel2_stg_act_d,
            dout    => rel2_stg_act_q);

rel3_stg_act_reg: tri_rlmlatch_p
generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => tiup,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc(5),
            mpw1_b  => mpw1_dc_b(5),
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv0(rel3_stg_act_offset),
            scout   => sov0(rel3_stg_act_offset),
            din     => rel3_stg_act_d,
            dout    => rel3_stg_act_q);

rel4_stg_act_reg: tri_rlmlatch_p
generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => tiup,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc(5),
            mpw1_b  => mpw1_dc_b(5),
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv0(rel4_stg_act_offset),
            scout   => sov0(rel4_stg_act_offset),
            din     => rel4_stg_act_d,
            dout    => rel4_stg_act_q);

rel5_stg_act_reg: tri_rlmlatch_p
generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => tiup,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc(5),
            mpw1_b  => mpw1_dc_b(5),
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv0(rel5_stg_act_offset),
            scout   => sov0(rel5_stg_act_offset),
            din     => rel5_stg_act_d,
            dout    => rel5_stg_act_q);

rel2_ex2_stg_act_reg: tri_rlmlatch_p
generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => tiup,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc(5),
            mpw1_b  => mpw1_dc_b(5),
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv0(rel2_ex2_stg_act_offset),
            scout   => sov0(rel2_ex2_stg_act_offset),
            din     => rel2_ex2_stg_act_d,
            dout    => rel2_ex2_stg_act_q);

rel3_ex3_stg_act_reg: tri_rlmlatch_p
generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => tiup,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc(5),
            mpw1_b  => mpw1_dc_b(5),
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv0(rel3_ex3_stg_act_offset),
            scout   => sov0(rel3_ex3_stg_act_offset),
            din     => rel3_ex3_stg_act_d,
            dout    => rel3_ex3_stg_act_q);

rel4_ex4_stg_act_reg: tri_rlmlatch_p
generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => tiup,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc(5),
            mpw1_b  => mpw1_dc_b(5),
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv0(rel4_ex4_stg_act_offset),
            scout   => sov0(rel4_ex4_stg_act_offset),
            din     => rel4_ex4_stg_act_d,
            dout    => rel4_ex4_stg_act_q);

ex8_ld_par_err_reg: tri_rlmlatch_p
generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => tiup,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc(5),
            mpw1_b  => mpw1_dc_b(5),
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv0(ex8_ld_par_err_offset),
            scout   => sov0(ex8_ld_par_err_offset),
            din     => ex8_ld_par_err_d,
            dout    => ex8_ld_par_err_q);

my_spare0_lcb : entity tri.tri_lcbnd(tri_lcbnd)
generic map (expand_type => expand_type)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => tiup,
            forcee => func_sl_force,
            delay_lclkr => delay_lclkr_dc(5),
            mpw1_b  => mpw1_dc_b(5),
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            d1clk   => my_spare0_d1clk,
            d2clk   => my_spare0_d2clk,
            lclk    => my_spare0_lclk);
my_spare_latches_reg: entity tri.tri_inv_nlats(tri_inv_nlats)
generic map (width => 8, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            lclk    => my_spare0_lclk,
            d1clk   => my_spare0_d1clk,
            d2clk   => my_spare0_d2clk,
            scanin  => siv0(my_spare_latches_offset to  my_spare_latches_offset + my_spare_latches_d'length-1),
            scanout => sov0(my_spare_latches_offset to  my_spare_latches_offset + my_spare_latches_d'length-1),
            d       => my_spare_latches_d,
            qb      => my_spare_latches_q);

rel_data_reg: tri_rlmreg_p
generic map (width => 256, init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => rel1_stg_act_q,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc(5),
            mpw1_b  => mpw1_dc_b(5),
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv1(rel_data_offset to rel_data_offset + rel_data_d'length-1),
            scout   => sov1(rel_data_offset to rel_data_offset + rel_data_d'length-1),
            din     => rel_data_d,
            dout    => rel_data_q);

rel_algebraic_reg: tri_rlmlatch_p
generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => rel1_stg_act_q,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc(5),
            mpw1_b  => mpw1_dc_b(5),
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv1(rel_algebraic_offset),
            scout   => sov1(rel_algebraic_offset),
            din     => rel_algebraic_d,
            dout    => rel_algebraic_q);

rel_rot_sel_reg: tri_rlmreg_p
generic map (width => 5, init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => rel1_stg_act_q,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc(5),
            mpw1_b  => mpw1_dc_b(5),
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv1(rel_rot_sel_offset to rel_rot_sel_offset + rel_rot_sel_d'length-1),
            scout   => sov1(rel_rot_sel_offset to rel_rot_sel_offset + rel_rot_sel_d'length-1),
            din     => rel_rot_sel_d,
            dout    => rel_rot_sel_q);

rel_op_size_reg: tri_rlmreg_p
generic map (width => 6, init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => rel1_stg_act_q,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc(5),
            mpw1_b  => mpw1_dc_b(5),
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv1(rel_op_size_offset to rel_op_size_offset + rel_op_size_d'length-1),
            scout   => sov1(rel_op_size_offset to rel_op_size_offset + rel_op_size_d'length-1),
            din     => rel_op_size_d,
            dout    => rel_op_size_q);

rel_le_mode_reg: tri_rlmlatch_p
generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => rel1_stg_act_q,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc(5),
            mpw1_b  => mpw1_dc_b(5),
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv1(rel_le_mode_offset),
            scout   => sov1(rel_le_mode_offset),
            din     => rel_le_mode_d,
            dout    => rel_le_mode_q);

rel_dvc1_en_reg: tri_rlmlatch_p
generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => rel1_stg_act_q,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc(5),
            mpw1_b  => mpw1_dc_b(5),
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv1(rel_dvc1_en_offset),
            scout   => sov1(rel_dvc1_en_offset),
            din     => rel_dvc1_en_d,
            dout    => rel_dvc1_en_q);

rel_dvc2_en_reg: tri_rlmlatch_p
generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => rel1_stg_act_q,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc(5),
            mpw1_b  => mpw1_dc_b(5),
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv1(rel_dvc2_en_offset),
            scout   => sov1(rel_dvc2_en_offset),
            din     => rel_dvc2_en_d,
            dout    => rel_dvc2_en_q);

rel_upd_gpr_reg: tri_rlmlatch_p
generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => tiup,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc(5),
            mpw1_b  => mpw1_dc_b(5),
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv1(rel_upd_gpr_offset),
            scout   => sov1(rel_upd_gpr_offset),
            din     => rel_upd_gpr_d,
            dout    => rel_upd_gpr_q);

rel_axu_val_reg: tri_rlmlatch_p
generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => rel1_stg_act_q,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc(5),
            mpw1_b  => mpw1_dc_b(5),
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv1(rel_axu_val_offset),
            scout   => sov1(rel_axu_val_offset),
            din     => rel_axu_val_d,
            dout    => rel_axu_val_q);

rel_ci_reg: tri_rlmlatch_p
generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => tiup,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc(5),
            mpw1_b  => mpw1_dc_b(5),
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv1(rel_ci_offset),
            scout   => sov1(rel_ci_offset),
            din     => rel_ci_d,
            dout    => rel_ci_q);

rel_ci_dly_reg: tri_regk
generic map (width => 1, init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => tiup,
            forcee => func_nsl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc(5),
            mpw1_b  => mpw1_dc_b(5),
            mpw2_b  => mpw2_dc_b,
            thold_b => func_nsl_thold_0_b,
            din(0)  => rel_ci_dly_d,
            dout(0) => rel_ci_dly_q);

rel_thrd_id_reg: tri_rlmreg_p
  generic map (width => 4, init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => rel1_stg_act_q,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc(5),
            mpw1_b  => mpw1_dc_b(5),
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv1(rel_thrd_id_offset to rel_thrd_id_offset + rel_thrd_id_d'length-1),
            scout   => sov1(rel_thrd_id_offset to rel_thrd_id_offset + rel_thrd_id_d'length-1),
            din     => rel_thrd_id_d,
            dout    => rel_thrd_id_q);

rel_data_val_stg_reg: tri_rlmlatch_p
generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => tiup,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc(5),
            mpw1_b  => mpw1_dc_b(5),
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv1(rel_data_val_stg_offset),
            scout   => sov1(rel_data_val_stg_offset),
            din     => rel_data_val_stg_d,
            dout    => rel_data_val_stg_q);

rel_data_val_stg_dly_reg: tri_regk
generic map (width => 1, init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => tiup,
            forcee => func_nsl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc(5),
            mpw1_b  => mpw1_dc_b(5),
            mpw2_b  => mpw2_dc_b,
            thold_b => func_nsl_thold_0_b,
            din(0)  => rel_data_val_stg_dly_d,
            dout(0) => rel_data_val_stg_dly_q);

spr_dvc1_dbg_reg: tri_ser_rlmreg_p
generic map (width => (2**regmode), init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => spr_dvc1_act,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc(5),
            mpw1_b  => mpw1_dc_b(5),
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv1(spr_dvc1_dbg_offset to spr_dvc1_dbg_offset + spr_dvc1_dbg_d'length-1),
            scout   => sov1(spr_dvc1_dbg_offset to spr_dvc1_dbg_offset + spr_dvc1_dbg_d'length-1),
            din     => spr_dvc1_dbg_d,
            dout    => spr_dvc1_dbg_q);

spr_dvc2_dbg_reg: tri_ser_rlmreg_p
generic map (width => (2**regmode), init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => spr_dvc2_act,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc(5),
            mpw1_b  => mpw1_dc_b(5),
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv1(spr_dvc2_dbg_offset to spr_dvc2_dbg_offset + spr_dvc2_dbg_d'length-1),
            scout   => sov1(spr_dvc2_dbg_offset to spr_dvc2_dbg_offset + spr_dvc2_dbg_d'length-1),
            din     => spr_dvc2_dbg_d,
            dout    => spr_dvc2_dbg_q);

ex7_xld_data_reg: tri_regk
generic map (width => (2**regmode), init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => ex6_stg_act_q,
            forcee => func_nsl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc(5),
            mpw1_b  => mpw1_dc_b(5),
            mpw2_b  => mpw2_dc_b,
            thold_b => func_nsl_thold_0_b,
            din     => ex7_xld_data_d,
            dout    => ex7_xld_data_q);

trace_bus_enable_latch : tri_rlmlatch_p
generic map (init => 0, expand_type => expand_type, needs_sreset => 0)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => tiup,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc(5),
            mpw1_b  => mpw1_dc_b(5),
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv1(trace_bus_enable_offset),
            scout   => sov1(trace_bus_enable_offset),
            din     => pc_xu_trace_bus_enable,
            dout    => trace_bus_enable_q);

dat_debug_mux_ctrls_reg: tri_rlmreg_p
  generic map (width => 2, init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => rel1_stg_act_q,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc(5),
            mpw1_b  => mpw1_dc_b(5),
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv1(dat_debug_mux_ctrls_offset to dat_debug_mux_ctrls_offset + dat_debug_mux_ctrls_q'length-1),
            scout   => sov1(dat_debug_mux_ctrls_offset to dat_debug_mux_ctrls_offset + dat_debug_mux_ctrls_q'length-1),
            din     => lsudat_debug_mux_ctrls,
            dout    => dat_debug_mux_ctrls_q);

dat_dbg_st_dat_reg: tri_rlmreg_p
  generic map (width => 64, init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => trace_bus_enable_q,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc(5),
            mpw1_b  => mpw1_dc_b(5),
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv1(dat_dbg_st_dat_offset to dat_dbg_st_dat_offset + dat_dbg_st_dat_d'length-1),
            scout   => sov1(dat_dbg_st_dat_offset to dat_dbg_st_dat_offset + dat_dbg_st_dat_d'length-1),
            din     => dat_dbg_st_dat_d,
            dout    => dat_dbg_st_dat_q);

abist_reg: tri_rlmreg_p
  generic map (init => 0, expand_type => expand_type, width => 21, needs_sreset => 0)
  port map (vd             => vdd,
            gd             => gnd,
            nclk           => nclk,
            act            => pc_xu_abist_ena_dc,
            thold_b        => abst_sl_thold_0_b,
            sg             => sg_0,
            forcee => abst_sl_force,
            delay_lclkr    => delay_lclkr_dc(5),
            mpw1_b         => mpw1_dc_b(5),
            mpw2_b         => mpw2_dc_b,
            d_mode         => d_mode_dc,
            scin           => abist_siv(1 to 21),
            scout          => abist_sov(1 to 21),
            din(0  to 1)   => pc_xu_abist_g6t_bw,
            din(2  to 5)   => pc_xu_abist_di_g6t_2r,
            din(6)         => pc_xu_abist_wl512_comp_ena,
            din(7  to 10)  => pc_xu_abist_dcomp_g6t_2r,
            din(11 to 19)  => pc_xu_abist_raddr_0,
            din(20)        => pc_xu_abist_g6t_r_wb,
            dout(0  to 1)  => pc_xu_abist_g6t_bw_q,
            dout(2  to 5)  => pc_xu_abist_di_g6t_2r_q,
            dout(6)        => pc_xu_abist_wl512_comp_ena_q,
            dout(7  to 10) => pc_xu_abist_dcomp_g6t_2r_q,
            dout(11 to 19) => pc_xu_abist_raddr_0_q,
            dout(20)       => pc_xu_abist_g6t_r_wb_q);

perv_2to1_reg: tri_plat
  generic map (width => 9, expand_type => expand_type)
port map (vd          => vdd,
            gd          => gnd,
            nclk        => nclk,
            flush       => pc_xu_ccflush_dc,
            din(0)      => func_nsl_thold_2,
            din(1)      => func_sl_thold_2,
            din(2)      => ary_nsl_thold_2,
            din(3)      => abst_sl_thold_2,
            din(4)      => time_sl_thold_2,
            din(5)      => repr_sl_thold_2,
            din(6)      => bolt_sl_thold_2,
            din(7)      => sg_2,
            din(8)      => fce_2,
            q(0)        => func_nsl_thold_1,
            q(1)        => func_sl_thold_1,
            q(2)        => ary_nsl_thold_1,
            q(3)        => abst_sl_thold_1,
            q(4)        => time_sl_thold_1,
            q(5)        => repr_sl_thold_1,
            q(6)        => bolt_sl_thold_1,
            q(7)        => sg_1,
            q(8)        => fce_1);

perv_1to0_reg: tri_plat
  generic map (width => 9, expand_type => expand_type)
port map (vd          => vdd,
            gd          => gnd,
            nclk        => nclk,
            flush       => pc_xu_ccflush_dc,
            din(0)      => func_nsl_thold_1,
            din(1)      => func_sl_thold_1,
            din(2)      => ary_nsl_thold_1,
            din(3)      => abst_sl_thold_1,
            din(4)      => time_sl_thold_1,
            din(5)      => repr_sl_thold_1,
            din(6)      => bolt_sl_thold_1,
            din(7)      => sg_1,
            din(8)      => fce_1,
            q(0)        => func_nsl_thold_0,
            q(1)        => func_sl_thold_0,
            q(2)        => ary_nsl_thold_0,
            q(3)        => abst_sl_thold_0,
            q(4)        => time_sl_thold_0,
            q(5)        => repr_sl_thold_0,
            q(6)        => bolt_sl_thold_0,
            q(7)        => sg_0,
            q(8)        => fce_0);

perv_lcbor_func_sl: tri_lcbor
  generic map (expand_type => expand_type)
port map (clkoff_b    => clkoff_dc_b,
            thold       => func_sl_thold_0,
            sg          => sg_0,
            act_dis     => tidn,
            forcee => func_sl_force,
            thold_b     => func_sl_thold_0_b);

perv_lcbor_func_nsl: tri_lcbor
  generic map (expand_type => expand_type)
port map (clkoff_b    => clkoff_dc_b,
            thold       => func_nsl_thold_0,
            sg          => fce_0,
            act_dis     => tidn,
            forcee => func_nsl_force,
            thold_b     => func_nsl_thold_0_b);

perv_lcbor_abst_sl: tri_lcbor
  generic map (expand_type => expand_type)
  port map (clkoff_b    => clkoff_dc_b,
            thold       => abst_sl_thold_0,
            sg          => sg_0,
            act_dis     => tidn,
            forcee => abst_sl_force,
            thold_b     => abst_sl_thold_0_b);

slat_force        <= sg_0;
abst_slat_thold_b <= NOT abst_sl_thold_0;
time_slat_thold_b <= NOT time_sl_thold_0;
repr_slat_thold_b <= NOT repr_sl_thold_0;
func_slat_thold_b <= NOT func_sl_thold_0;

perv_lcbs_abst: tri_lcbs
  generic map (expand_type => expand_type )
  port map (
      vd          => vdd,
      gd          => gnd,
      delay_lclkr => delay_lclkr_dc(5),
      nclk        => nclk,
      forcee => slat_force,
      thold_b     => abst_slat_thold_b,
      dclk        => abst_slat_d2clk,
      lclk        => abst_slat_lclk );

perv_abst_stg: tri_slat_scan  
   generic map (width => 4, init => "0000", expand_type => expand_type)
   port map ( vd               => vdd,
              gd               => gnd,
              dclk             => abst_slat_d2clk,
              lclk             => abst_slat_lclk,
              scan_in(0 to 1)  => abst_scan_in,
              scan_in(2 to 3)  => abst_scan_out_int,
              scan_out(0 to 1) => abst_scan_in_q,
              scan_out(2 to 3) => abst_scan_out_q );

perv_lcbs_time: tri_lcbs
  generic map (expand_type => expand_type )
  port map (
      vd          => vdd,
      gd          => gnd,
      delay_lclkr => delay_lclkr_dc(5),
      nclk        => nclk,
      forcee => slat_force,
      thold_b     => time_slat_thold_b,
      dclk        => time_slat_d2clk,
      lclk        => time_slat_lclk );

perv_time_stg: tri_slat_scan  
   generic map (width => 2, init => "00", expand_type => expand_type)
   port map ( vd          => vdd,
              gd          => gnd,
              dclk        => time_slat_d2clk,
              lclk        => time_slat_lclk,
              scan_in(0)  => time_scan_in,
              scan_in(1)  => time_scan_out_int,
              scan_out(0) => time_scan_in_q,
              scan_out(1) => time_scan_out_q );

perv_lcbs_repr: tri_lcbs
  generic map (expand_type => expand_type )
  port map (
      vd          => vdd,
      gd          => gnd,
      delay_lclkr => delay_lclkr_dc(5),
      nclk        => nclk,
      forcee => slat_force,
      thold_b     => repr_slat_thold_b,
      dclk        => repr_slat_d2clk,
      lclk        => repr_slat_lclk );

perv_repr_stg: tri_slat_scan  
   generic map (width => 2, init => "00", expand_type => expand_type)
   port map ( vd          => vdd,
              gd          => gnd,
              dclk        => repr_slat_d2clk,
              lclk        => repr_slat_lclk,
              scan_in(0)  => repr_scan_in,
              scan_in(1)  => repr_scan_out_int,
              scan_out(0) => repr_scan_in_q,
              scan_out(1) => repr_scan_out_q );

perv_lcbs_func: tri_lcbs
  generic map (expand_type => expand_type )
  port map (
      vd          => vdd,
      gd          => gnd,
      delay_lclkr => delay_lclkr_dc(5),
      nclk        => nclk,
      forcee => slat_force,
      thold_b     => func_slat_thold_b,
      dclk        => func_slat_d2clk,
      lclk        => func_slat_lclk );

perv_func_stg: tri_slat_scan  
   generic map (width => 12, init => (1 to 12=>'0'), expand_type => expand_type)
   port map ( vd          => vdd,
              gd          => gnd,
              dclk        => func_slat_d2clk,
              lclk        => func_slat_lclk,
              scan_in(0)  => func_scan_in(0),
              scan_in(1)  => func_scan_in(1),
              scan_in(2)  => func_scan_in(2),
              scan_in(3)  => func_scan_out_int(0),
              scan_in(4)  => func_scan_out_int(1),
              scan_in(5)  => func_scan_out_int(2),
              scan_in(6)  => func_scan_in_q(0),
              scan_in(7)  => func_scan_in_q(1),
              scan_in(8)  => func_scan_in_q(2),
              scan_in(9)  => func_scan_out_q(0),
              scan_in(10) => func_scan_out_q(1),
              scan_in(11) => func_scan_out_q(2),              
              scan_out(0) => func_scan_in_q(0),
              scan_out(1) => func_scan_in_q(1),
              scan_out(2) => func_scan_in_q(2),
              scan_out(3) => func_scan_out_q(0),
              scan_out(4) => func_scan_out_q(1),
              scan_out(5) => func_scan_out_q(2),                            
              scan_out(6) => func_scan_in_2_q(0),
              scan_out(7) => func_scan_in_2_q(1),
              scan_out(8) => func_scan_in_2_q(2),
              scan_out(9) => func_scan_out_2_q(0),
              scan_out(10)=> func_scan_out_2_q(1),
              scan_out(11)=> func_scan_out_2_q(2)
               );

siv0                 <= sov0(1 to scan_right0) & func_scan_in_2_q(0);
func_scan_out_int(0) <= sov0(0);

siv1                 <= sov1(1 to scan_right1) & func_scan_in_2_q(1);
func_scan_out_int(1) <= sov1(0);

abist_siv            <= abist_sov(1 to abist_sov'right) & abst_scan_in_q(0);
abst_scan_out_int(0) <= abist_sov(0);

end xuq_lsu_data;

