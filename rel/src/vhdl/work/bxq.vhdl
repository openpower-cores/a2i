-- © IBM Corp. 2020
-- This softcore is licensed under and subject to the terms of the CC-BY 4.0
-- license (https://creativecommons.org/licenses/by/4.0/legalcode). 
-- Additional rights, including the right to physically implement a softcore 
-- that is compliant with the required sections of the Power ISA 
-- Specification, will be available at no cost via the OpenPOWER Foundation. 
-- This README will be updated with additional information when OpenPOWER's 
-- license is available.

--  Description:  XU Inbox/Outbox logic for message passing between processors
--

LIBRARY ieee;     USE ieee.std_logic_1164.all ;
                  USE ieee.numeric_std.all;
LIBRARY ibm;      
                  USE ibm.std_ulogic_support.all ;
                  USE ibm.std_ulogic_function_support.all;
                  USE ibm.std_ulogic_unsigned.all;
LIBRARY tri;      USE tri.tri_latches_pkg.all;
LIBRARY support;  
                  USE support.power_logic_pkg.all;
LIBRARY clib;     


ENTITY bxq IS
   generic(expand_type      : integer := 2;             -- 0 = ibm (Umbra), 1 = non-ibm, 2 = ibm (MPG)
           regmode          : integer := 6;             -- 5 = 32bit mode, 6 = 64bit mode
	   real_data_add    : integer := 42 );		-- 42 bit real address
   PORT (
     xu_bx_ccr2_en_ditc           :in     std_ulogic;
     xu_ex2_flush                 :in     std_ulogic_vector(0 to 3);
     xu_ex3_flush                 :in     std_ulogic_vector(0 to 3);
     xu_ex4_flush                 :in     std_ulogic_vector(0 to 3);
     xu_ex5_flush                 :in     std_ulogic_vector(0 to 3);
     xu_bx_ex1_mtdp_val           :in     std_ulogic;                  -- command from mtdp is valid
     xu_bx_ex1_mfdp_val           :in     std_ulogic;                  -- command from mtdp is valid
     xu_bx_ex1_ipc_thrd            :in     std_ulogic_vector(0 to 1);   -- Thread ID
     xu_bx_ex2_ipc_ba              :in     std_ulogic_vector(0 to 4);   -- offset into the active 64B buffer
     xu_bx_ex2_ipc_sz              :in     std_ulogic_vector(0 to 1);   -- size of data (00=4B, 10=16B)
    xu_bx_ex4_256st_data          :in     std_ulogic_vector(0 to 127); -- 16B of data to put into outbox buffer

     bx_xu_ex4_mtdp_cr_status     :out    std_ulogic;                  -- status (pas/fail) of the mtdp (sets CR)
     bx_xu_ex4_mfdp_cr_status     :out    std_ulogic;                  -- status (pas/fail) of the mfdp (sets CR)
     bx_xu_ex5_dp_data            :out    std_ulogic_vector(0 to 127); -- 16B of data from the inbox buffer

     -- outputs to network or l2 from outbox
     bx_lsu_ob_pwr_tok       :out    std_ulogic;
     bx_lsu_ob_req_val       :out    std_ulogic;                  -- message buffer data is ready to send
     bx_lsu_ob_ditc_val      :out    std_ulogic;                  -- send dtic command
     bx_lsu_ob_thrd          :out    std_ulogic_vector(0 to 1);   -- source thread
     bx_lsu_ob_qw            :out    std_ulogic_vector(58 to 59); -- quadword data pointer
     bx_lsu_ob_dest          :out    std_ulogic_vector(0 to 14);  -- destination for the packet
     bx_lsu_ob_data          :out    std_ulogic_vector(0 to 127); -- 16B of data from the outbox
     bx_lsu_ob_addr          :out    std_ulogic_vector(64-real_data_add to 57); -- address for boxes message

     ac_an_reld_ditc_pop        :out    std_ulogic_vector(0 to 3);   -- return credit from inbox (per thread)

     bx_ib_empty                :out    std_ulogic_vector(0 to 3);   -- inbox is empty
     bx_xu_quiesce              :out    std_ulogic_vector(0 to 3);   -- inbox and outbox are empty

     -- inputs from lsu
     lsu_bx_cmd_avail           :in     std_ulogic;
     lsu_bx_cmd_sent            :in     std_ulogic;
     lsu_bx_cmd_stall           :in     std_ulogic;

     -- inputs from network or l2 going to inbox

     lsu_reld_data_vld        :in     std_ulogic;                      -- reload data is coming in 2 cycles
     lsu_reld_core_tag        :in     std_ulogic_vector(3 to 4);       -- reload data destinatoin tag (thread)
     lsu_reld_qw              :in     std_ulogic_vector(58 to 59);       -- reload data quadword pointer
     lsu_reld_ditc            :in     std_ulogic;                      -- reload data is for ditc (inbox)
     lsu_reld_data            :in     std_ulogic_vector(0 to 127);     -- reload data
     lsu_reld_ecc_err         :in     std_ulogic;                      -- reload data has ecc error

     lsu_req_st_pop           :in     std_ulogic;                  -- decrement outbox credit count
     lsu_req_st_pop_thrd      :in     std_ulogic_vector(0 to 2);   -- decrement outbox credit count

     -- Slow SPR Bus
     slowspr_val_in             :in  std_ulogic;
     slowspr_rw_in              :in  std_ulogic;
     slowspr_etid_in            :in  std_ulogic_vector(0 to 1);
     slowspr_addr_in            :in  std_ulogic_vector(0 to 9);
     slowspr_data_in            :in  std_ulogic_vector(64-(2**REGMODE) to 63);
     slowspr_done_in            :in  std_ulogic;
     slowspr_val_out            :out std_ulogic;
     slowspr_rw_out             :out std_ulogic;
     slowspr_etid_out           :out std_ulogic_vector(0 to 1);
     slowspr_addr_out           :out std_ulogic_vector(0 to 9);
     slowspr_data_out           :out std_ulogic_vector(64-(2**REGMODE) to 63);
     slowspr_done_out           :out std_ulogic;

     bx_pc_err_inbox_ecc        :out    std_ulogic;                                              
     bx_pc_err_outbox_ecc       :out    std_ulogic;                                                
     bx_pc_err_inbox_ue         :out    std_ulogic;                                              
     bx_pc_err_outbox_ue        :out    std_ulogic;                                                
     pc_bx_inj_inbox_ecc        :in     std_ulogic;                                              
     pc_bx_inj_outbox_ecc       :in     std_ulogic;                                                

     -- debug connections
     pc_bx_trace_bus_enable     : in  std_ulogic;
     pc_bx_debug_mux1_ctrls     : in  std_ulogic_vector(0 to 15);
     trigger_data_in            : in  std_ulogic_vector(0 to 11);
     debug_data_in              : in  std_ulogic_vector(0 to 87);
     trigger_data_out           : out std_ulogic_vector(0 to 11);
     debug_data_out             : out std_ulogic_vector(0 to 87);
     

-- power
     vdd                        : inout power_logic;
     gnd                        : inout power_logic;
     vcs                        : inout power_logic;

     pc_bx_abist_di_0                :in std_ulogic_vector(0 to 3);
     pc_bx_abist_g8t_bw_1            :in std_ulogic;
     pc_bx_abist_g8t_bw_0            :in std_ulogic;
     pc_bx_abist_waddr_0             :in std_ulogic_vector(4 to 9);
     pc_bx_abist_g8t_wenb            :in std_ulogic;
     pc_bx_abist_raddr_0             :in std_ulogic_vector(4 to 9);
     pc_bx_abist_g8t1p_renb_0        :in std_ulogic;
     an_ac_lbist_ary_wrt_thru_dc     :in std_ulogic;
     pc_bx_abist_ena_dc              :in std_ulogic;
     pc_bx_abist_wl64_comp_ena       :in std_ulogic;
     pc_bx_abist_raw_dc_b            :in std_ulogic;
     pc_bx_abist_g8t_dcomp           :in std_ulogic_vector(0 to 3);

     nclk                       :in  clk_logic;
     pc_bx_ccflush_dc           : in  std_ulogic;
     pc_bx_sg_3                 : in  std_ulogic;
     pc_bx_func_sl_thold_3      : in  std_ulogic;
     pc_bx_func_slp_sl_thold_3  : in  std_ulogic;
     pc_bx_gptr_sl_thold_3      : in  std_ulogic;
     pc_bx_abst_sl_thold_3      : in  std_ulogic;
     pc_bx_time_sl_thold_3      : in  std_ulogic;
     pc_bx_ary_nsl_thold_3      : in  std_ulogic;
     pc_bx_ary_slp_nsl_thold_3  : in  std_ulogic;
     pc_bx_repr_sl_thold_3      : in  std_ulogic;
     pc_bx_bolt_sl_thold_3      : in  std_ulogic;
     an_ac_scan_diag_dc         : in  std_ulogic;
     an_ac_scan_dis_dc_b        : in  std_ulogic;

      pc_bx_bo_enable_3         : in  std_ulogic;
      pc_bx_bo_unload           : in  std_ulogic;
      pc_bx_bo_repair           : in  std_ulogic;
      pc_bx_bo_reset            : in  std_ulogic;
      pc_bx_bo_shdata           : in  std_ulogic;
      pc_bx_bo_select           : in  std_ulogic_vector(0 to 3);
      bx_pc_bo_fail             : out std_ulogic_vector(0 to 3);
      bx_pc_bo_diagout          : out std_ulogic_vector(0 to 3);


     time_scan_in               : in std_ulogic;
     repr_scan_in               : in std_ulogic;
     abst_scan_in               : in std_ulogic;
     time_scan_out              : out std_ulogic;
     repr_scan_out              : out std_ulogic;
     abst_scan_out              : out std_ulogic;
     gptr_scan_in               : in  std_ulogic;
     gptr_scan_out              : out std_ulogic;
     func_scan_in               :in  std_ulogic_vector(0 to 1);
     func_scan_out              :out std_ulogic_vector(0 to 1)
    );






END ;

ARCHITECTURE bxq OF bxq IS

signal ex4_mtdp_val_gated       :std_ulogic;

signal ob0_wrt_entry_ptr_d       :std_ulogic_vector(0 to 1);    -- outbox thread 0 write buffer entry pointer
signal ob0_wrt_entry_ptr_q       :std_ulogic_vector(0 to 1);
signal ob0_set_val               :std_ulogic;
signal ob1_wrt_entry_ptr_d       :std_ulogic_vector(0 to 1);    -- outbox thread 1 write buffer entry pointer
signal ob1_wrt_entry_ptr_q       :std_ulogic_vector(0 to 1);
signal ob1_set_val               :std_ulogic;
signal ob2_wrt_entry_ptr_d       :std_ulogic_vector(0 to 1);    -- outbox thread 2 write buffer entry pointer
signal ob2_wrt_entry_ptr_q       :std_ulogic_vector(0 to 1);
signal ob2_set_val               :std_ulogic;
signal ob3_wrt_entry_ptr_d       :std_ulogic_vector(0 to 1);    -- outbox thread 3 write buffer entry pointer
signal ob3_wrt_entry_ptr_q       :std_ulogic_vector(0 to 1);
signal ob3_set_val               :std_ulogic;
 
signal ob_status_reg_newdata     :std_ulogic_vector(0 to 17);     -- data to be written into message buffer complete and status registers
signal ob0_buf0_status_d         :std_ulogic_vector(0 to 17);     -- outbox thread 0 buffer 0 message buffer complete register
signal ob0_buf1_status_d         :std_ulogic_vector(0 to 17);     -- outbox thread 0 buffer 1 message buffer complete register
signal ob0_buf2_status_d         :std_ulogic_vector(0 to 17);     -- outbox thread 0 buffer 2 message buffer complete register
signal ob0_buf3_status_d         :std_ulogic_vector(0 to 17);     -- outbox thread 0 buffer 3 message buffer complete register
signal ob1_buf0_status_d         :std_ulogic_vector(0 to 17);     -- outbox thread 1 buffer 0 message buffer complete register
signal ob1_buf1_status_d         :std_ulogic_vector(0 to 17);     -- outbox thread 1 buffer 1 message buffer complete register
signal ob1_buf2_status_d         :std_ulogic_vector(0 to 17);     -- outbox thread 1 buffer 2 message buffer complete register
signal ob1_buf3_status_d         :std_ulogic_vector(0 to 17);     -- outbox thread 1 buffer 3 message buffer complete register
signal ob2_buf0_status_d         :std_ulogic_vector(0 to 17);     -- outbox thread 2 buffer 0 message buffer complete register
signal ob2_buf1_status_d         :std_ulogic_vector(0 to 17);     -- outbox thread 2 buffer 1 message buffer complete register
signal ob2_buf2_status_d         :std_ulogic_vector(0 to 17);     -- outbox thread 2 buffer 2 message buffer complete register
signal ob2_buf3_status_d         :std_ulogic_vector(0 to 17);     -- outbox thread 2 buffer 3 message buffer complete register
signal ob3_buf0_status_d         :std_ulogic_vector(0 to 17);     -- outbox thread 3 buffer 0 message buffer complete register
signal ob3_buf1_status_d         :std_ulogic_vector(0 to 17);     -- outbox thread 3 buffer 1 message buffer complete register
signal ob3_buf2_status_d         :std_ulogic_vector(0 to 17);     -- outbox thread 3 buffer 2 message buffer complete register
signal ob3_buf3_status_d         :std_ulogic_vector(0 to 17);     -- outbox thread 3 buffer 3 message buffer complete register
signal ob0_buf0_status_q         :std_ulogic_vector(0 to 17);     -- outbox thread 0 buffer 0 message buffer complete register
signal ob0_buf1_status_q         :std_ulogic_vector(0 to 17);     -- outbox thread 0 buffer 1 message buffer complete register
signal ob0_buf2_status_q         :std_ulogic_vector(0 to 17);     -- outbox thread 0 buffer 2 message buffer complete register
signal ob0_buf3_status_q         :std_ulogic_vector(0 to 17);     -- outbox thread 0 buffer 3 message buffer complete register
signal ob1_buf0_status_q         :std_ulogic_vector(0 to 17);     -- outbox thread 1 buffer 0 message buffer complete register
signal ob1_buf1_status_q         :std_ulogic_vector(0 to 17);     -- outbox thread 1 buffer 1 message buffer complete register
signal ob1_buf2_status_q         :std_ulogic_vector(0 to 17);     -- outbox thread 1 buffer 2 message buffer complete register
signal ob1_buf3_status_q         :std_ulogic_vector(0 to 17);     -- outbox thread 1 buffer 3 message buffer complete register
signal ob2_buf0_status_q         :std_ulogic_vector(0 to 17);     -- outbox thread 2 buffer 0 message buffer complete register
signal ob2_buf1_status_q         :std_ulogic_vector(0 to 17);     -- outbox thread 2 buffer 1 message buffer complete register
signal ob2_buf2_status_q         :std_ulogic_vector(0 to 17);     -- outbox thread 2 buffer 2 message buffer complete register
signal ob2_buf3_status_q         :std_ulogic_vector(0 to 17);     -- outbox thread 2 buffer 3 message buffer complete register
signal ob3_buf0_status_q         :std_ulogic_vector(0 to 17);     -- outbox thread 3 buffer 0 message buffer complete register
signal ob3_buf1_status_q         :std_ulogic_vector(0 to 17);     -- outbox thread 3 buffer 1 message buffer complete register
signal ob3_buf2_status_q         :std_ulogic_vector(0 to 17);     -- outbox thread 3 buffer 2 message buffer complete register
signal ob3_buf3_status_q         :std_ulogic_vector(0 to 17);     -- outbox thread 3 buffer 3 message buffer complete register
signal wrt_ob0_buf0_status       :std_ulogic;
signal wrt_ob0_buf1_status       :std_ulogic;
signal wrt_ob0_buf2_status       :std_ulogic;
signal wrt_ob0_buf3_status       :std_ulogic;
signal wrt_ob1_buf0_status       :std_ulogic;
signal wrt_ob1_buf1_status       :std_ulogic;
signal wrt_ob1_buf2_status       :std_ulogic;
signal wrt_ob1_buf3_status       :std_ulogic;
signal wrt_ob2_buf0_status       :std_ulogic;
signal wrt_ob2_buf1_status       :std_ulogic;
signal wrt_ob2_buf2_status       :std_ulogic;
signal wrt_ob2_buf3_status       :std_ulogic;
signal wrt_ob3_buf0_status       :std_ulogic;
signal wrt_ob3_buf1_status       :std_ulogic;
signal wrt_ob3_buf2_status       :std_ulogic;
signal wrt_ob3_buf3_status       :std_ulogic;
signal ex4_wrt_ob_status         :std_ulogic_vector(0 to 15);
signal ex5_wrt_ob_status_q       :std_ulogic_vector(0 to 15);
signal ex5_wrt_ob_status_gated   :std_ulogic_vector(0 to 15);
signal ex6_wrt_ob_status_q       :std_ulogic_vector(0 to 15);
signal ex5_ob0_buf0_flushed      :std_ulogic;
signal ex5_ob0_buf1_flushed      :std_ulogic;
signal ex5_ob0_buf2_flushed      :std_ulogic;
signal ex5_ob0_buf3_flushed      :std_ulogic;
signal ex5_ob1_buf0_flushed      :std_ulogic;
signal ex5_ob1_buf1_flushed      :std_ulogic;
signal ex5_ob1_buf2_flushed      :std_ulogic;
signal ex5_ob1_buf3_flushed      :std_ulogic;
signal ex5_ob2_buf0_flushed      :std_ulogic;
signal ex5_ob2_buf1_flushed      :std_ulogic;
signal ex5_ob2_buf2_flushed      :std_ulogic;
signal ex5_ob2_buf3_flushed      :std_ulogic;
signal ex5_ob3_buf0_flushed      :std_ulogic;
signal ex5_ob3_buf1_flushed      :std_ulogic;
signal ex5_ob3_buf2_flushed      :std_ulogic;
signal ex5_ob3_buf3_flushed      :std_ulogic;
signal ex5_ob0_flushed           :std_ulogic;
signal ex5_ob1_flushed           :std_ulogic;
signal ex5_ob2_flushed           :std_ulogic;
signal ex5_ob3_flushed           :std_ulogic;
signal ex6_ob0_buf0_flushed      :std_ulogic;
signal ex6_ob0_buf1_flushed      :std_ulogic;
signal ex6_ob0_buf2_flushed      :std_ulogic;
signal ex6_ob0_buf3_flushed      :std_ulogic;
signal ex6_ob1_buf0_flushed      :std_ulogic;
signal ex6_ob1_buf1_flushed      :std_ulogic;
signal ex6_ob1_buf2_flushed      :std_ulogic;
signal ex6_ob1_buf3_flushed      :std_ulogic;
signal ex6_ob2_buf0_flushed      :std_ulogic;
signal ex6_ob2_buf1_flushed      :std_ulogic;
signal ex6_ob2_buf2_flushed      :std_ulogic;
signal ex6_ob2_buf3_flushed      :std_ulogic;
signal ex6_ob3_buf0_flushed      :std_ulogic;
signal ex6_ob3_buf1_flushed      :std_ulogic;
signal ex6_ob3_buf2_flushed      :std_ulogic;
signal ex6_ob3_buf3_flushed      :std_ulogic;
signal ex6_ob0_flushed           :std_ulogic;
signal ex6_ob1_flushed           :std_ulogic;
signal ex6_ob2_flushed           :std_ulogic;
signal ex6_ob3_flushed           :std_ulogic;
signal ob0_buf0_status_val       :std_ulogic;
signal ob0_buf1_status_val       :std_ulogic;
signal ob0_buf2_status_val       :std_ulogic;
signal ob0_buf3_status_val       :std_ulogic;
signal ob1_buf0_status_val       :std_ulogic;
signal ob1_buf1_status_val       :std_ulogic;
signal ob1_buf2_status_val       :std_ulogic;
signal ob1_buf3_status_val       :std_ulogic;
signal ob2_buf0_status_val       :std_ulogic;
signal ob2_buf1_status_val       :std_ulogic;
signal ob2_buf2_status_val       :std_ulogic;
signal ob2_buf3_status_val       :std_ulogic;
signal ob3_buf0_status_val       :std_ulogic;
signal ob3_buf1_status_val       :std_ulogic;
signal ob3_buf2_status_val       :std_ulogic;
signal ob3_buf3_status_val       :std_ulogic;

signal ob_rd_data                :std_ulogic_vector(0 to 127);
signal ob_rd_data1_l2            :std_ulogic_vector(0 to 127);
signal ob_rd_data_cor            :std_ulogic_vector(0 to 127);
signal ob_rd_data_cor_l2         :std_ulogic_vector(0 to 127);
signal ob_rd_data_ecc0           :std_ulogic_vector(0 to 6);
signal ob_rd_data_ecc1           :std_ulogic_vector(0 to 6);
signal ob_rd_data_ecc2           :std_ulogic_vector(0 to 6);
signal ob_rd_data_ecc3           :std_ulogic_vector(0 to 6);
signal ob_rd_data_ecc0_l2        :std_ulogic_vector(0 to 6);
signal ob_rd_data_ecc1_l2        :std_ulogic_vector(0 to 6);
signal ob_rd_data_ecc2_l2        :std_ulogic_vector(0 to 6);
signal ob_rd_data_ecc3_l2        :std_ulogic_vector(0 to 6);
signal ob_rd_data_nsyn0          :std_ulogic_vector(0 to 6);
signal ob_rd_data_nsyn1          :std_ulogic_vector(0 to 6);
signal ob_rd_data_nsyn2          :std_ulogic_vector(0 to 6);
signal ob_rd_data_nsyn3          :std_ulogic_vector(0 to 6);
signal ob_ary_sbe                :std_ulogic_vector(0 to 3);
signal ob_ary_sbe_q              :std_ulogic_vector(0 to 3);
signal ob_ary_sbe_or             :std_ulogic;
signal ob_ary_ue                 :std_ulogic_vector(0 to 3);
signal ob_ary_ue_q               :std_ulogic_vector(0 to 3);
signal ob_ary_ue_or              :std_ulogic;
signal ob_datain_ecc0            :std_ulogic_vector(0 to 6);
signal ob_datain_ecc1            :std_ulogic_vector(0 to 6);
signal ob_datain_ecc2            :std_ulogic_vector(0 to 6);
signal ob_datain_ecc3            :std_ulogic_vector(0 to 6);
signal ob_wrt_entry_ptr          :std_ulogic_vector(0 to 1);
signal ob_wrt_addr               :std_ulogic_vector(0 to 5);
signal ob_ary_wrt_addr_l2        :std_ulogic_vector(0 to 5);
signal ob_ary_rd_addr            :std_ulogic_vector(0 to 5);
signal ob_buf_status_val         :std_ulogic;
signal ex3_ob_buf_status_val     :std_ulogic;
signal ob_wen                    :std_ulogic_vector(0 to 3);
signal ob_ary_wen_l2             :std_ulogic_vector(0 to 3);
signal ob_ary_wrt_data_l2        :std_ulogic_vector(0 to 127);

signal ob0_rd_entry_ptr_d        :std_ulogic_vector(0 to 1);
signal ob0_rd_entry_ptr_q        :std_ulogic_vector(0 to 1);
signal ob1_rd_entry_ptr_d        :std_ulogic_vector(0 to 1);
signal ob1_rd_entry_ptr_q        :std_ulogic_vector(0 to 1);
signal ob2_rd_entry_ptr_d        :std_ulogic_vector(0 to 1);
signal ob2_rd_entry_ptr_q        :std_ulogic_vector(0 to 1);
signal ob3_rd_entry_ptr_d        :std_ulogic_vector(0 to 1);
signal ob3_rd_entry_ptr_q        :std_ulogic_vector(0 to 1);

signal ob_to_node_status_reg     :std_ulogic_vector(1 to 17);
signal ob0_to_nd_status_reg      :std_ulogic_vector(0 to 17);
signal ob1_to_nd_status_reg      :std_ulogic_vector(0 to 17);
signal ob2_to_nd_status_reg      :std_ulogic_vector(0 to 17);
signal ob3_to_nd_status_reg      :std_ulogic_vector(0 to 17);

signal ob_to_node_sel_d          :std_ulogic_vector(0 to 3);
signal ob_to_node_sel_q          :std_ulogic_vector(0 to 3);
signal ob_to_node_sel_sav_d      :std_ulogic_vector(0 to 3);
signal ob_to_node_sel_sav_q      :std_ulogic_vector(0 to 3);
signal ob_to_nd_val_t0           :std_ulogic;
signal ob_to_nd_val_t1           :std_ulogic;
signal ob_to_nd_val_t2           :std_ulogic;
signal ob_to_nd_val_t3           :std_ulogic;
signal ob_to_nd_status_reg_vals  :std_ulogic_vector(0 to 3);

signal send_ob_idle              :std_ulogic;
signal send_ob_data1             :std_ulogic;
signal send_ob_data2             :std_ulogic;
signal send_ob_data3             :std_ulogic;
signal send_ob_data4             :std_ulogic;
signal send_ob_ditc              :std_ulogic;
signal send_ob_wait              :std_ulogic;
signal send_ob_nxt_idle          :std_ulogic;
signal send_ob_nxt_data1         :std_ulogic;
signal send_ob_nxt_data2         :std_ulogic;
signal send_ob_nxt_data3         :std_ulogic;
signal send_ob_nxt_data4         :std_ulogic;
signal send_ob_nxt_ditc          :std_ulogic;
signal send_ob_nxt_wait          :std_ulogic;
signal ob_to_nd_done_d           :std_ulogic;
signal send_ob_nxt_state         :std_ulogic_vector(0 to 6);
signal send_ob_state_q           :std_ulogic_vector(0 to 6);

signal ob0_buf_done               :std_ulogic;
signal ob1_buf_done               :std_ulogic;
signal ob2_buf_done               :std_ulogic;
signal ob3_buf_done               :std_ulogic;
signal ob0_buf0_done              :std_ulogic;
signal ob0_buf1_done              :std_ulogic;
signal ob0_buf2_done              :std_ulogic;
signal ob0_buf3_done              :std_ulogic;
signal ob1_buf0_done              :std_ulogic;
signal ob1_buf1_done              :std_ulogic;
signal ob1_buf2_done              :std_ulogic;
signal ob1_buf3_done              :std_ulogic;
signal ob2_buf0_done              :std_ulogic;
signal ob2_buf1_done              :std_ulogic;
signal ob2_buf2_done              :std_ulogic;
signal ob2_buf3_done              :std_ulogic;
signal ob3_buf0_done              :std_ulogic;
signal ob3_buf1_done              :std_ulogic;
signal ob3_buf2_done              :std_ulogic;
signal ob3_buf3_done              :std_ulogic;

signal ob_to_node_selected_thrd   :std_ulogic_vector(0 to 1);
signal ob_to_node_selected_rd_ptr :std_ulogic_vector(0 to 1);
signal ob_to_node_data_ptr        :std_ulogic_vector(0 to 1);
signal send_ob_seq_ptr            :std_ulogic_vector(0 to 1);

signal dly_ob_cmd_val_q           :std_ulogic_vector(0 to 1);
signal dly_ob_cmd_val_d           :std_ulogic_vector(0 to 1);
signal bx_lsu_ob_req_val_d        :std_ulogic;
signal bx_lsu_ob_req_val_int      :std_ulogic;
signal send_ob_data_val           :std_ulogic;
signal send_ob_ditc_val           :std_ulogic;
signal dly_ob_ditc_val_q          :std_ulogic_vector(0 to 1);
signal dly_ob_ditc_val_d          :std_ulogic_vector(0 to 1);
signal dly_ob_qw                  :std_ulogic_vector(58 to 59);
signal dly1_ob_qw                 :std_ulogic_vector(58 to 59);
signal ob_addr_d                  :std_ulogic_vector(64-real_data_add to 57);

signal lat_st_pop             :std_ulogic;
signal lat_st_pop_thrd        :std_ulogic_vector(0 to 2);
signal ob_pop                     :std_ulogic_vector(0 to 3);
signal ob_cmd_count_incr_t0       :std_ulogic_vector(0 to 1);
signal ob_cmd_count_decr_t0       :std_ulogic_vector(0 to 1);
signal ob_cmd_count_t0_d          :std_ulogic_vector(0 to 1);
signal ob_cmd_count_t0_q          :std_ulogic_vector(0 to 1);
signal ob_credit_t0               :std_ulogic;
signal ob_cmd_count_incr_t1       :std_ulogic_vector(0 to 1);
signal ob_cmd_count_decr_t1       :std_ulogic_vector(0 to 1);
signal ob_cmd_count_t1_d          :std_ulogic_vector(0 to 1);
signal ob_cmd_count_t1_q          :std_ulogic_vector(0 to 1);
signal ob_credit_t1               :std_ulogic;
signal ob_cmd_count_incr_t2       :std_ulogic_vector(0 to 1);
signal ob_cmd_count_decr_t2       :std_ulogic_vector(0 to 1);
signal ob_cmd_count_t2_d          :std_ulogic_vector(0 to 1);
signal ob_cmd_count_t2_q          :std_ulogic_vector(0 to 1);
signal ob_credit_t2               :std_ulogic;
signal ob_cmd_count_incr_t3       :std_ulogic_vector(0 to 1);
signal ob_cmd_count_decr_t3       :std_ulogic_vector(0 to 1);
signal ob_cmd_count_t3_d          :std_ulogic_vector(0 to 1);
signal ob_cmd_count_t3_q          :std_ulogic_vector(0 to 1);
signal ob_credit_t3               :std_ulogic;
signal ob_to_nd_ready             :std_ulogic;
signal ob_lsu_complete            :std_ulogic;
signal lsu_cmd_avail_q            :std_ulogic;
signal lsu_cmd_sent_q             :std_ulogic;
signal lsu_cmd_stall_q            :std_ulogic;
signal ob_cmd_sent_count_d        :std_ulogic_vector(0 to 2);
signal ob_cmd_sent_count_q        :std_ulogic_vector(0 to 2);

signal wrt_ib0_buf0_status        :std_ulogic;
signal wrt_ib0_buf1_status        :std_ulogic;
signal wrt_ib0_buf2_status        :std_ulogic;
signal wrt_ib0_buf3_status        :std_ulogic;
signal wrt_ib1_buf0_status        :std_ulogic;
signal wrt_ib1_buf1_status        :std_ulogic;
signal wrt_ib1_buf2_status        :std_ulogic;
signal wrt_ib1_buf3_status        :std_ulogic;
signal wrt_ib2_buf0_status        :std_ulogic;
signal wrt_ib2_buf1_status        :std_ulogic;
signal wrt_ib2_buf2_status        :std_ulogic;
signal wrt_ib2_buf3_status        :std_ulogic;
signal wrt_ib3_buf0_status        :std_ulogic;
signal wrt_ib3_buf1_status        :std_ulogic;
signal wrt_ib3_buf2_status        :std_ulogic;
signal wrt_ib3_buf3_status        :std_ulogic;
signal ib0_incr_ptr              :std_ulogic;
signal ib1_incr_ptr              :std_ulogic;
signal ib2_incr_ptr              :std_ulogic;
signal ib3_incr_ptr              :std_ulogic;
signal ib0_decr_ptr              :std_ulogic;
signal ib1_decr_ptr              :std_ulogic;
signal ib2_decr_ptr              :std_ulogic;
signal ib3_decr_ptr              :std_ulogic;
signal ib0_decr_ptr_by2          :std_ulogic;
signal ib1_decr_ptr_by2          :std_ulogic;
signal ib2_decr_ptr_by2          :std_ulogic;
signal ib3_decr_ptr_by2          :std_ulogic;
signal ib0_decr_ptr_by3          :std_ulogic;
signal ib1_decr_ptr_by3          :std_ulogic;
signal ib2_decr_ptr_by3          :std_ulogic;
signal ib3_decr_ptr_by3          :std_ulogic;
signal ex4_wrt_ib_status         :std_ulogic_vector(0 to 15);
signal ex5_wrt_ib_status_q       :std_ulogic_vector(0 to 15);
signal ex5_wrt_ib_status_gated   :std_ulogic_vector(0 to 15);
signal ex6_wrt_ib_status_q       :std_ulogic_vector(0 to 15);
signal ex5_ib0_buf0_flushed      :std_ulogic;
signal ex5_ib0_buf1_flushed      :std_ulogic;
signal ex5_ib0_buf2_flushed      :std_ulogic;
signal ex5_ib0_buf3_flushed      :std_ulogic;
signal ex5_ib1_buf0_flushed      :std_ulogic;
signal ex5_ib1_buf1_flushed      :std_ulogic;
signal ex5_ib1_buf2_flushed      :std_ulogic;
signal ex5_ib1_buf3_flushed      :std_ulogic;
signal ex5_ib2_buf0_flushed      :std_ulogic;
signal ex5_ib2_buf1_flushed      :std_ulogic;
signal ex5_ib2_buf2_flushed      :std_ulogic;
signal ex5_ib2_buf3_flushed      :std_ulogic;
signal ex5_ib3_buf0_flushed      :std_ulogic;
signal ex5_ib3_buf1_flushed      :std_ulogic;
signal ex5_ib3_buf2_flushed      :std_ulogic;
signal ex5_ib3_buf3_flushed      :std_ulogic;
signal ex4_ib0_flushed           :std_ulogic;
signal ex4_ib1_flushed           :std_ulogic;
signal ex4_ib2_flushed           :std_ulogic;
signal ex4_ib3_flushed           :std_ulogic;
signal ex5_ib0_flushed           :std_ulogic;
signal ex5_ib1_flushed           :std_ulogic;
signal ex5_ib2_flushed           :std_ulogic;
signal ex5_ib3_flushed           :std_ulogic;
signal ex6_ib0_buf0_flushed      :std_ulogic;
signal ex6_ib0_buf1_flushed      :std_ulogic;
signal ex6_ib0_buf2_flushed      :std_ulogic;
signal ex6_ib0_buf3_flushed      :std_ulogic;
signal ex6_ib1_buf0_flushed      :std_ulogic;
signal ex6_ib1_buf1_flushed      :std_ulogic;
signal ex6_ib1_buf2_flushed      :std_ulogic;
signal ex6_ib1_buf3_flushed      :std_ulogic;
signal ex6_ib2_buf0_flushed      :std_ulogic;
signal ex6_ib2_buf1_flushed      :std_ulogic;
signal ex6_ib2_buf2_flushed      :std_ulogic;
signal ex6_ib2_buf3_flushed      :std_ulogic;
signal ex6_ib3_buf0_flushed      :std_ulogic;
signal ex6_ib3_buf1_flushed      :std_ulogic;
signal ex6_ib3_buf2_flushed      :std_ulogic;
signal ex6_ib3_buf3_flushed      :std_ulogic;
signal ex6_ib0_flushed           :std_ulogic;
signal ex6_ib1_flushed           :std_ulogic;
signal ex6_ib2_flushed           :std_ulogic;
signal ex6_ib3_flushed           :std_ulogic;
signal ib_t0_pop_d               :std_ulogic;
signal ib_t1_pop_d               :std_ulogic;
signal ib_t2_pop_d               :std_ulogic;
signal ib_t3_pop_d               :std_ulogic;

signal ib0_buf0_val_d            :std_ulogic;     -- outbox thread 0 buffer 0 val register
signal ib0_buf1_val_d            :std_ulogic;     -- outbox thread 0 buffer 1 val register
signal ib0_buf2_val_d            :std_ulogic;     -- outbox thread 0 buffer 2 val register
signal ib0_buf3_val_d            :std_ulogic;     -- outbox thread 0 buffer 3 val register
signal ib1_buf0_val_d            :std_ulogic;     -- outbox thread 1 buffer 0 val register
signal ib1_buf1_val_d            :std_ulogic;     -- outbox thread 1 buffer 1 val register
signal ib1_buf2_val_d            :std_ulogic;     -- outbox thread 1 buffer 2 val register
signal ib1_buf3_val_d            :std_ulogic;     -- outbox thread 1 buffer 3 val register
signal ib2_buf0_val_d            :std_ulogic;     -- outbox thread 2 buffer 0 val register
signal ib2_buf1_val_d            :std_ulogic;     -- outbox thread 2 buffer 1 val register
signal ib2_buf2_val_d            :std_ulogic;     -- outbox thread 2 buffer 2 val register
signal ib2_buf3_val_d            :std_ulogic;     -- outbox thread 2 buffer 3 val register
signal ib3_buf0_val_d            :std_ulogic;     -- outbox thread 3 buffer 0 val register
signal ib3_buf1_val_d            :std_ulogic;     -- outbox thread 3 buffer 1 val register
signal ib3_buf2_val_d            :std_ulogic;     -- outbox thread 3 buffer 2 val register
signal ib3_buf3_val_d            :std_ulogic;     -- outbox thread 3 buffer 3 val register
signal ib0_buf0_val_q            :std_ulogic;     -- outbox thread 0 buffer 0 val register
signal ib0_buf1_val_q            :std_ulogic;     -- outbox thread 0 buffer 1 val register
signal ib0_buf2_val_q            :std_ulogic;     -- outbox thread 0 buffer 2 val register
signal ib0_buf3_val_q            :std_ulogic;     -- outbox thread 0 buffer 3 val register
signal ib1_buf0_val_q            :std_ulogic;     -- outbox thread 1 buffer 0 val register
signal ib1_buf1_val_q            :std_ulogic;     -- outbox thread 1 buffer 1 val register
signal ib1_buf2_val_q            :std_ulogic;     -- outbox thread 1 buffer 2 val register
signal ib1_buf3_val_q            :std_ulogic;     -- outbox thread 1 buffer 3 val register
signal ib2_buf0_val_q            :std_ulogic;     -- outbox thread 2 buffer 0 val register
signal ib2_buf1_val_q            :std_ulogic;     -- outbox thread 2 buffer 1 val register
signal ib2_buf2_val_q            :std_ulogic;     -- outbox thread 2 buffer 2 val register
signal ib2_buf3_val_q            :std_ulogic;     -- outbox thread 2 buffer 3 val register
signal ib3_buf0_val_q            :std_ulogic;     -- outbox thread 3 buffer 0 val register
signal ib3_buf1_val_q            :std_ulogic;     -- outbox thread 3 buffer 1 val register
signal ib3_buf2_val_q            :std_ulogic;     -- outbox thread 3 buffer 2 val register
signal ib3_buf3_val_q            :std_ulogic;     -- outbox thread 3 buffer 3 val register
signal ib0_rd_val_reg            :std_ulogic;
signal ib1_rd_val_reg            :std_ulogic;
signal ib2_rd_val_reg            :std_ulogic;
signal ib3_rd_val_reg            :std_ulogic;
signal ex4_ib_rd_status_reg      :std_ulogic;
signal ex4_ib_val_save           :std_ulogic;
signal ex5_ib_val_save_q         :std_ulogic;
signal ex6_ib_val_save_q         :std_ulogic;
signal ib_empty_d                :std_ulogic_vector(0 to 3);
signal quiesce_d                 :std_ulogic_vector(0 to 3);

signal ex3_data_w0_sel           :std_ulogic_vector(0 to 3);
signal ex3_data_w1_sel           :std_ulogic_vector(0 to 3);
signal ex3_data_w2_sel           :std_ulogic_vector(0 to 3);
signal ex3_data_w3_sel           :std_ulogic_vector(0 to 3);
signal ex3_data_sel_status       :std_ulogic;
signal ex3_inbox_data            :std_ulogic_vector(0 to 127);
signal ex4_inbox_data            :std_ulogic_vector(0 to 127);
signal ex5_inbox_data_cor        :std_ulogic_vector(0 to 127);

signal ib0_buf0_set_val             :std_ulogic;
signal ib0_buf1_set_val             :std_ulogic;
signal ib0_buf2_set_val             :std_ulogic;
signal ib0_buf3_set_val             :std_ulogic;
signal ib1_buf0_set_val             :std_ulogic;
signal ib1_buf1_set_val             :std_ulogic;
signal ib1_buf2_set_val             :std_ulogic;
signal ib1_buf3_set_val             :std_ulogic;
signal ib2_buf0_set_val             :std_ulogic;
signal ib2_buf1_set_val             :std_ulogic;
signal ib2_buf2_set_val             :std_ulogic;
signal ib2_buf3_set_val             :std_ulogic;
signal ib3_buf0_set_val             :std_ulogic;
signal ib3_buf1_set_val             :std_ulogic;
signal ib3_buf2_set_val             :std_ulogic;
signal ib3_buf3_set_val             :std_ulogic;
signal ib0_buf0_reset_val             :std_ulogic;
signal ib0_buf1_reset_val             :std_ulogic;
signal ib0_buf2_reset_val             :std_ulogic;
signal ib0_buf3_reset_val             :std_ulogic;
signal ib1_buf0_reset_val             :std_ulogic;
signal ib1_buf1_reset_val             :std_ulogic;
signal ib1_buf2_reset_val             :std_ulogic;
signal ib1_buf3_reset_val             :std_ulogic;
signal ib2_buf0_reset_val             :std_ulogic;
signal ib2_buf1_reset_val             :std_ulogic;
signal ib2_buf2_reset_val             :std_ulogic;
signal ib2_buf3_reset_val             :std_ulogic;
signal ib3_buf0_reset_val             :std_ulogic;
signal ib3_buf1_reset_val             :std_ulogic;
signal ib3_buf2_reset_val             :std_ulogic;
signal ib3_buf3_reset_val             :std_ulogic;

signal ib0_rd_entry_ptr_d        :std_ulogic_vector(0 to 1);
signal ib1_rd_entry_ptr_d        :std_ulogic_vector(0 to 1);
signal ib2_rd_entry_ptr_d        :std_ulogic_vector(0 to 1);
signal ib3_rd_entry_ptr_d        :std_ulogic_vector(0 to 1);
signal ib0_rd_entry_ptr_q        :std_ulogic_vector(0 to 1);
signal ib1_rd_entry_ptr_q        :std_ulogic_vector(0 to 1);
signal ib2_rd_entry_ptr_q        :std_ulogic_vector(0 to 1);
signal ib3_rd_entry_ptr_q        :std_ulogic_vector(0 to 1);
signal ib0_rd_entry_ptr_dly_q    :std_ulogic_vector(0 to 1);
signal ib1_rd_entry_ptr_dly_q    :std_ulogic_vector(0 to 1);
signal ib2_rd_entry_ptr_dly_q    :std_ulogic_vector(0 to 1);
signal ib3_rd_entry_ptr_dly_q    :std_ulogic_vector(0 to 1);
 signal ib_rd_entry_ptr           :std_ulogic_vector(0 to 1);

signal ib_ary_rd_addr            :std_ulogic_vector(0 to 5);
signal ib_wen                    :std_ulogic;
signal ib_ary_wen                :std_ulogic_vector(0 to 3);
signal ib_ary_wrt_addr           :std_ulogic_vector(0 to 5);
signal ib_rd_data                :std_ulogic_vector(0 to 127);
signal ib_rd_data_cor            :std_ulogic_vector(0 to 127);
signal ib_rd_data_ecc0           :std_ulogic_vector(0 to 6);
signal ib_rd_data_ecc1           :std_ulogic_vector(0 to 6);
signal ib_rd_data_ecc2           :std_ulogic_vector(0 to 6);
signal ib_rd_data_ecc3           :std_ulogic_vector(0 to 6);
signal ex3_ib_data_ecc0          :std_ulogic_vector(0 to 6);
signal ex3_ib_data_ecc1          :std_ulogic_vector(0 to 6);
signal ex3_ib_data_ecc2          :std_ulogic_vector(0 to 6);
signal ex3_ib_data_ecc3          :std_ulogic_vector(0 to 6);
signal ex4_ib_data_ecc0          :std_ulogic_vector(0 to 6);
signal ex4_ib_data_ecc1          :std_ulogic_vector(0 to 6);
signal ex4_ib_data_ecc2          :std_ulogic_vector(0 to 6);
signal ex4_ib_data_ecc3          :std_ulogic_vector(0 to 6);
signal ib_rd_data_nsyn0          :std_ulogic_vector(0 to 6);
signal ib_rd_data_nsyn1          :std_ulogic_vector(0 to 6);
signal ib_rd_data_nsyn2          :std_ulogic_vector(0 to 6);
signal ib_rd_data_nsyn3          :std_ulogic_vector(0 to 6);
signal ib_datain_ecc0            :std_ulogic_vector(0 to 6);
signal ib_datain_ecc1            :std_ulogic_vector(0 to 6);
signal ib_datain_ecc2            :std_ulogic_vector(0 to 6);
signal ib_datain_ecc3            :std_ulogic_vector(0 to 6);
signal ex4_ib_ecc_val            :std_ulogic;
signal ex5_ib_ecc_val            :std_ulogic;
signal ib_ary_ue_or              :std_ulogic;
signal ib_ary_ue                 :std_ulogic_vector(0 to 3);
signal ib_ary_ue_q               :std_ulogic_vector(0 to 3);
signal ib_ary_sbe_or             :std_ulogic;
signal ib_ary_sbe                :std_ulogic_vector(0 to 3);
signal ib_ary_sbe_q              :std_ulogic_vector(0 to 3);
signal ob_abst_scan_out          :std_ulogic;
signal ib_abst_scan_out          :std_ulogic;
signal ob_time_scan_out          :std_ulogic;
signal ib_time_scan_out          :std_ulogic;
signal ob_repr_scan_out          :std_ulogic;

signal lat_reld_data_val         :std_ulogic;
signal lat_reld_ditc             :std_ulogic;
signal lat_reld_ecc_err          :std_ulogic;
signal reld_data_val_dminus2     :std_ulogic;
signal reld_data_val_dminus1     :std_ulogic;
signal reld_data_val             :std_ulogic;
signal reld_data_val_dplus1      :std_ulogic;
signal lat_reld_core_tag         :std_ulogic_vector(3 to 4);
signal reld_core_tag_dminus1     :std_ulogic_vector(3 to 4);
signal reld_core_tag             :std_ulogic_vector(3 to 4);
signal reld_core_tag_dplus1      :std_ulogic_vector(3 to 4);
signal lat_reld_qw               :std_ulogic_vector(58 to 59);
signal reld_qw_dminus1           :std_ulogic_vector(58 to 59);
signal reld_qw                   :std_ulogic_vector(58 to 59);
signal lat_reld_data             :std_ulogic_vector(0 to 127);

signal ib0_wrt_entry_ptr_d       :std_ulogic_vector(0 to 1);
signal ib1_wrt_entry_ptr_d       :std_ulogic_vector(0 to 1);
signal ib2_wrt_entry_ptr_d       :std_ulogic_vector(0 to 1);
signal ib3_wrt_entry_ptr_d       :std_ulogic_vector(0 to 1);
signal ib0_wrt_entry_ptr_q       :std_ulogic_vector(0 to 1);
signal ib1_wrt_entry_ptr_q       :std_ulogic_vector(0 to 1);
signal ib2_wrt_entry_ptr_q       :std_ulogic_vector(0 to 1);
signal ib3_wrt_entry_ptr_q       :std_ulogic_vector(0 to 1);
signal ib0_wrt_entry_ptr         :std_ulogic_vector(0 to 1);
signal ib1_wrt_entry_ptr         :std_ulogic_vector(0 to 1);
signal ib2_wrt_entry_ptr         :std_ulogic_vector(0 to 1);
signal ib3_wrt_entry_ptr         :std_ulogic_vector(0 to 1);
signal ib0_wrt_entry_ptr_minus1  :std_ulogic_vector(0 to 1);
signal ib1_wrt_entry_ptr_minus1  :std_ulogic_vector(0 to 1);
signal ib2_wrt_entry_ptr_minus1  :std_ulogic_vector(0 to 1);
signal ib3_wrt_entry_ptr_minus1  :std_ulogic_vector(0 to 1);
signal dec_ib0_wrt_entry_ptr     :std_ulogic;
signal dec_ib1_wrt_entry_ptr     :std_ulogic;
signal dec_ib2_wrt_entry_ptr     :std_ulogic;
signal dec_ib3_wrt_entry_ptr     :std_ulogic;
signal ib0_wrt_data_ctr_d       :std_ulogic_vector(0 to 1);
signal ib1_wrt_data_ctr_d       :std_ulogic_vector(0 to 1);
signal ib2_wrt_data_ctr_d       :std_ulogic_vector(0 to 1);
signal ib3_wrt_data_ctr_d       :std_ulogic_vector(0 to 1);
signal ib0_wrt_data_ctr_q       :std_ulogic_vector(0 to 1);
signal ib1_wrt_data_ctr_q       :std_ulogic_vector(0 to 1);
signal ib2_wrt_data_ctr_q       :std_ulogic_vector(0 to 1);
signal ib3_wrt_data_ctr_q       :std_ulogic_vector(0 to 1);


signal ib_wrt_thrd               :std_ulogic_vector(0 to 1);
signal ib_wrt_entry_pointer      :std_ulogic_vector(0 to 1);

signal ib0_set_val               :std_ulogic;
signal ib1_set_val               :std_ulogic;
signal ib2_set_val               :std_ulogic;
signal ib3_set_val               :std_ulogic;
signal ib0_set_val_q             :std_ulogic;
signal ib1_set_val_q             :std_ulogic;
signal ib2_set_val_q             :std_ulogic;
signal ib3_set_val_q             :std_ulogic;
signal ib0_ecc_err_d             :std_ulogic;
signal ib1_ecc_err_d             :std_ulogic;
signal ib2_ecc_err_d             :std_ulogic;
signal ib3_ecc_err_d             :std_ulogic;
signal ib0_ecc_err_q             :std_ulogic;
signal ib1_ecc_err_q             :std_ulogic;
signal ib2_ecc_err_q             :std_ulogic;
signal ib3_ecc_err_q             :std_ulogic;

signal inbox_ecc_err_q           :std_ulogic;
signal inbox_ue_q                :std_ulogic;
signal outbox_ecc_err_q          :std_ulogic;
signal outbox_ue_q               :std_ulogic;

signal ob0_buf0_clr             :std_ulogic;
signal ob0_buf1_clr             :std_ulogic;
signal ob0_buf2_clr             :std_ulogic;
signal ob0_buf3_clr             :std_ulogic;
signal ob1_buf0_clr             :std_ulogic;
signal ob1_buf1_clr             :std_ulogic;
signal ob1_buf2_clr             :std_ulogic;
signal ob1_buf3_clr             :std_ulogic;
signal ob2_buf0_clr             :std_ulogic;
signal ob2_buf1_clr             :std_ulogic;
signal ob2_buf2_clr             :std_ulogic;
signal ob2_buf3_clr             :std_ulogic;
signal ob3_buf0_clr             :std_ulogic;
signal ob3_buf1_clr             :std_ulogic;
signal ob3_buf2_clr             :std_ulogic;
signal ob3_buf3_clr             :std_ulogic;
signal ob0_buf0_status_avail    :std_ulogic;
signal ob0_buf1_status_avail    :std_ulogic;
signal ob0_buf2_status_avail    :std_ulogic;
signal ob0_buf3_status_avail    :std_ulogic;
signal ob1_buf0_status_avail    :std_ulogic;
signal ob1_buf1_status_avail    :std_ulogic;
signal ob1_buf2_status_avail    :std_ulogic;
signal ob1_buf3_status_avail    :std_ulogic;
signal ob2_buf0_status_avail    :std_ulogic;
signal ob2_buf1_status_avail    :std_ulogic;
signal ob2_buf2_status_avail    :std_ulogic;
signal ob2_buf3_status_avail    :std_ulogic;
signal ob3_buf0_status_avail    :std_ulogic;
signal ob3_buf1_status_avail    :std_ulogic;
signal ob3_buf2_status_avail    :std_ulogic;
signal ob3_buf3_status_avail    :std_ulogic;
signal ob_buf_status_avail_d    :std_ulogic_vector(0 to 15);
signal ob_buf_status_avail_q    :std_ulogic_vector(0 to 15);

signal my_ccr2_en_ditc_q       :std_ulogic;
signal my_ex3_flush            :std_ulogic;
signal my_ex3_flush_q          :std_ulogic_vector(0 to 3);
signal my_ex4_flush_q          :std_ulogic_vector(0 to 3);
signal my_ex5_flush_q          :std_ulogic_vector(0 to 3);
signal my_ex6_flush_q          :std_ulogic_vector(0 to 3);
signal my_ex4_stg_flush        :std_ulogic;
signal my_ex5_stg_flush        :std_ulogic;
signal my_ex6_stg_flush        :std_ulogic;
signal ex2_mfdp_val_q         :std_ulogic;                  -- command from mtdp is valid
signal ex3_mfdp_val_q         :std_ulogic;                  -- command from mtdp is valid
signal ex4_mfdp_val_q         :std_ulogic;                  -- command from mtdp is valid
signal ex5_mfdp_val_q         :std_ulogic;                  -- command from mtdp is valid
signal ex6_mfdp_val_q         :std_ulogic;                  -- command from mtdp is valid
signal ex3_mtdp_val           :std_ulogic;                  -- command from mtdp is valid
signal ex2_mtdp_val_q         :std_ulogic;                  -- command from mtdp is valid
signal ex3_mtdp_val_q         :std_ulogic;                  -- command from mtdp is valid
signal ex2_ipc_thrd_q          :std_ulogic_vector(0 to 1);   -- Thread ID
signal ex3_ipc_thrd_q          :std_ulogic_vector(0 to 1);   -- Thread ID
signal ex3_ipc_ba_q            :std_ulogic_vector(0 to 4);   -- offset into the active 64B buffer
signal ex3_ipc_sz_q            :std_ulogic_vector(0 to 1);   -- size of data (00=4B, 10=16B)
signal ex4_mtdp_val_q         :std_ulogic;                  -- command from mtdp is valid
signal ex5_mtdp_val_q         :std_ulogic;                  -- command from mtdp is valid
signal ex6_mtdp_val_q         :std_ulogic;                  -- command from mtdp is valid
signal ex7_mtdp_val_q         :std_ulogic;                  -- command from mtdp is valid
signal ex4_ipc_thrd_q          :std_ulogic_vector(0 to 1);   -- Thread ID
signal ex5_ipc_thrd_q          :std_ulogic_vector(0 to 1);   -- Thread ID
signal ex6_ipc_thrd_q          :std_ulogic_vector(0 to 1);   -- Thread ID
signal ex4_ipc_ba_q            :std_ulogic_vector(0 to 4);   -- offset into the active 64B buffer
signal ex4_ipc_sz_q            :std_ulogic_vector(0 to 1);   -- size of data (00=4B, 10=16B)
--signal ex4_256st_data_q        :std_ulogic_vector(0 to 127); -- 16B of data to put into outbox buffer
--signal ex4_256st_data_par_q    :std_ulogic_vector(0 to 15);  -- parity accross the st_data
signal ex3_mtdp_cr_status     :std_ulogic;
signal ex4_mtdp_cr_status     :std_ulogic;
signal ex3_mfdp_cr_status     :std_ulogic;
signal ex4_mfdp_cr_status_i   :std_ulogic;

signal ditc_addr_sel          :std_ulogic;
signal ditc_addr_wen          :std_ulogic;
signal ditc_addr_t0_wen       :std_ulogic;
signal ditc_addr_t1_wen       :std_ulogic;
signal ditc_addr_t2_wen       :std_ulogic;
signal ditc_addr_t3_wen       :std_ulogic;
signal ditc_addr_t0_d         :std_ulogic_vector(64-real_data_add to 57);
signal ditc_addr_t1_d         :std_ulogic_vector(64-real_data_add to 57);
signal ditc_addr_t2_d         :std_ulogic_vector(64-real_data_add to 57);
signal ditc_addr_t3_d         :std_ulogic_vector(64-real_data_add to 57);
signal ditc_addr_t0_q         :std_ulogic_vector(64-real_data_add to 57);
signal ditc_addr_t1_q         :std_ulogic_vector(64-real_data_add to 57);
signal ditc_addr_t2_q         :std_ulogic_vector(64-real_data_add to 57);
signal ditc_addr_t3_q         :std_ulogic_vector(64-real_data_add to 57);
signal ditc_addr_reg          :std_ulogic_vector(64-(2**REGMODE) to 63);
signal ditc_addr_rd_val       :std_ulogic;
signal xu_slowspr_data_d      :std_ulogic_vector(64-(2**REGMODE) to 63);
signal xu_slowspr_done_d      :std_ulogic;
signal xu_slowspr_val_d       :std_ulogic;
signal xu_slowspr_rw_d        :std_ulogic;
signal xu_slowspr_etid_d      :std_ulogic_vector(0 to 1);
signal xu_slowspr_addr_d      :std_ulogic_vector(0 to 9);
signal bx_slowspr_val_q       :std_ulogic;
signal bx_slowspr_rw_q        :std_ulogic;
signal bx_slowspr_etid_q      :std_ulogic_vector(0 to 1);
signal bx_slowspr_addr_q      :std_ulogic_vector(0 to 9);
signal bx_slowspr_data_q      :std_ulogic_vector(64-(2**REGMODE) to 63);
signal bx_slowspr_done_q      :std_ulogic;

signal ob_rd_logic_act        :std_ulogic;
signal ob_rd_logic_act_d      :std_ulogic;
signal ob_rd_logic_act_q      :std_ulogic;
signal mtdp_ex3_to_7_val      :std_ulogic;
signal ib_buf_val_act         :std_ulogic;
signal dp_op_val              :std_ulogic;

signal abist_di_0             :std_ulogic_vector(0 to 3);
signal abist_g8t_bw_1         :std_ulogic;
signal abist_g8t_bw_0         :std_ulogic;
signal abist_waddr_0          :std_ulogic_vector(4 to 9);
signal abist_g8t_wenb         :std_ulogic;
signal abist_raddr_0          :std_ulogic_vector(4 to 9);
signal abist_g8t1p_renb_0     :std_ulogic;
signal abist_wl64_comp_ena    :std_ulogic;
signal abist_g8t_dcomp        :std_ulogic_vector(0 to 3);

signal dbg_group0_d           :std_ulogic_vector(0 to 17);
signal dbg_group0_q           :std_ulogic_vector(0 to 17);
signal dbg_group0             :std_ulogic_vector(0 to 87);
signal dbg_group1             :std_ulogic_vector(0 to 87);
signal dbg_group2             :std_ulogic_vector(0 to 87);
signal dbg_group3             :std_ulogic_vector(0 to 87);
signal trg_group0             :std_ulogic_vector(0 to 11);
signal trg_group1             :std_ulogic_vector(0 to 11);
signal trg_group2             :std_ulogic_vector(0 to 11);
signal trg_group3             :std_ulogic_vector(0 to 11);
signal debug_mux1_ctrls_q     :std_ulogic_vector(0 to 15);
signal debug_mux_out_d        :std_ulogic_vector(0 to 87);
signal trigger_mux_out_d      :std_ulogic_vector(0 to 11);
signal trace_bus_enable_q     :std_ulogic;
signal spare0_l2              :std_ulogic_vector(0 to 7);
signal spare1_l2              :std_ulogic_vector(0 to 3);

signal sg_2                       :std_ulogic;
signal func_sl_thold_2            :std_ulogic;
signal func_slp_sl_thold_2        :std_ulogic;
signal abst_sl_thold_2            :std_ulogic;
signal time_sl_thold_2            :std_ulogic;
signal ary_nsl_thold_2            :std_ulogic;
signal ary_slp_nsl_thold_2        :std_ulogic;
signal gptr_sl_thold_2            :std_ulogic;
signal repr_sl_thold_2            :std_ulogic;
signal bolt_sl_thold_2            :std_ulogic;
signal bolt_enable_2              :std_ulogic;
signal func_sl_thold_1            :std_ulogic;
signal func_slp_sl_thold_1        :std_ulogic;
signal abst_sl_thold_1            :std_ulogic;
signal time_sl_thold_1            :std_ulogic;
signal ary_nsl_thold_1            :std_ulogic;
signal ary_slp_nsl_thold_1        :std_ulogic;
signal gptr_sl_thold_1            :std_ulogic;
signal repr_sl_thold_1            :std_ulogic;
signal bolt_sl_thold_1            :std_ulogic;
signal func_sl_thold_0            :std_ulogic;
signal func_slp_sl_thold_0        :std_ulogic;
signal ary_nsl_thold_0            :std_ulogic;
signal ary_slp_nsl_thold_0        :std_ulogic;
signal abst_sl_thold_0            :std_ulogic;
signal time_sl_thold_0            :std_ulogic;
signal repr_sl_thold_0            :std_ulogic;
signal gptr_sl_thold_0            :std_ulogic;
signal bolt_sl_thold_0            :std_ulogic;
signal slat_force                 :std_ulogic;
signal time_slat_thold_b          :std_ulogic;
signal time_slat_d2clk            :std_ulogic;
signal time_slat_lclk             :clk_logic;
signal time_scan_out_stg          :std_ulogic;
signal repr_slat_thold_b          :std_ulogic;
signal repr_slat_d2clk            :std_ulogic;
signal repr_slat_lclk             :clk_logic;

signal clkoff_dc_b                :std_ulogic;
signal d_mode_dc                  :std_ulogic;
signal delay_lclkr_dc             :std_ulogic;
signal delay_lclkr_dc_v           :std_ulogic_vector(0 to 4);
signal mpw1_dc_b                  :std_ulogic;
signal mpw1_dc_b_v                :std_ulogic_vector(0 to 4);
signal mpw2_dc_b                  :std_ulogic;
signal ary0_clkoff_dc_b            :std_ulogic;
signal ary0_d_mode_dc              :std_ulogic;
signal ary0_delay_lclkr_dc_v       :std_ulogic_vector(0 to 4);
signal ary0_mpw1_dc_b_v            :std_ulogic_vector(0 to 4);
signal ary0_mpw2_dc_b              :std_ulogic;
signal ary1_clkoff_dc_b            :std_ulogic;
signal ary1_d_mode_dc              :std_ulogic;
signal ary1_delay_lclkr_dc_v       :std_ulogic_vector(0 to 4);
signal ary1_mpw1_dc_b_v            :std_ulogic_vector(0 to 4);
signal ary1_mpw2_dc_b              :std_ulogic;
signal int1_gptr_scan_out          :std_ulogic;
signal int0_gptr_scan_out          :std_ulogic;
signal int_repr_scan_out          :std_ulogic;
signal repr_scan_out_q            :std_ulogic;
signal repr_scan_in_q             :std_ulogic;
signal int_gptr_scan_out          :std_ulogic;
signal time_scan_in_q             :std_ulogic;

signal ob_err_inj_q               :std_ulogic;
signal ib_err_inj_q               :std_ulogic;
signal ob_ary_wrt_data_0          :std_ulogic;
signal lat_reld_data_0            :std_ulogic;

signal sg_1                               : std_ulogic;
signal sg_0                               : std_ulogic;
signal func_sl_force                      : std_ulogic;
signal func_sl_thold_0_b                  : std_ulogic;
signal func_slp_sl_force                  : std_ulogic;
signal func_slp_sl_thold_0_b              : std_ulogic;
signal abst_sl_force                      : std_ulogic;
signal abst_sl_thold_0_b                  : std_ulogic;

signal tidn                               : std_ulogic;
signal unused                 :std_ulogic_vector(0 to 23);

constant my_ex3_flush_offset               : natural := 0;
constant my_ex4_flush_offset               : natural :=my_ex3_flush_offset         + my_ex3_flush_q'length;
constant my_ex5_flush_offset               : natural :=my_ex4_flush_offset         + my_ex4_flush_q'length;
constant my_ex6_flush_offset               : natural :=my_ex5_flush_offset         + my_ex5_flush_q'length;
constant my_ccr2_en_ditc_offset            : natural :=my_ex6_flush_offset         + my_ex6_flush_q'length;
constant ex2_mtdp_val_offset               : natural :=my_ccr2_en_ditc_offset      + 1;
constant ex3_mtdp_val_offset               : natural :=ex2_mtdp_val_offset         + 1;
constant ex4_mtdp_val_offset               : natural :=ex3_mtdp_val_offset         + 1;
constant ex5_mtdp_val_offset               : natural :=ex4_mtdp_val_offset         + 1;
constant ex6_mtdp_val_offset               : natural :=ex5_mtdp_val_offset         + 1;
constant ex7_mtdp_val_offset               : natural :=ex6_mtdp_val_offset         + 1;
constant ex2_mfdp_val_offset               : natural :=ex7_mtdp_val_offset         + 1;
constant ex3_mfdp_val_offset               : natural :=ex2_mfdp_val_offset         + 1;
constant ex4_mfdp_val_offset               : natural :=ex3_mfdp_val_offset         + 1;
constant ex5_mfdp_val_offset               : natural :=ex4_mfdp_val_offset         + 1;
constant ex6_mfdp_val_offset               : natural :=ex5_mfdp_val_offset         + 1;
constant ex2_ipc_thrd_offset               : natural :=ex6_mfdp_val_offset         + 1;
constant ex3_ipc_thrd_offset               : natural :=ex2_ipc_thrd_offset         + ex2_ipc_thrd_q'length;
constant ex3_ipc_ba_offset                 : natural :=ex3_ipc_thrd_offset         + ex3_ipc_thrd_q'length;
constant ex3_ipc_sz_offset                 : natural :=ex3_ipc_ba_offset           + ex3_ipc_ba_q'length;
constant bx_slowspr_val_offset             : natural :=ex3_ipc_sz_offset           + ex3_ipc_sz_q'length;
constant bx_slowspr_rw_offset              : natural :=bx_slowspr_val_offset       + 1;
constant bx_slowspr_etid_offset            : natural :=bx_slowspr_rw_offset        + 1;
constant bx_slowspr_addr_offset            : natural :=bx_slowspr_etid_offset      + bx_slowspr_etid_q'length;
constant bx_slowspr_data_offset            : natural :=bx_slowspr_addr_offset      + bx_slowspr_addr_q'length;
constant bx_slowspr_done_offset            : natural :=bx_slowspr_data_offset      + bx_slowspr_data_q'length;
constant xu_slowspr_val_offset             : natural :=bx_slowspr_done_offset      + 1;
constant xu_slowspr_rw_offset              : natural :=xu_slowspr_val_offset       + 1;
constant xu_slowspr_etid_offset            : natural :=xu_slowspr_rw_offset        + 1;
constant xu_slowspr_addr_offset            : natural :=xu_slowspr_etid_offset      + xu_slowspr_etid_d'length;
constant xu_slowspr_data_offset            : natural :=xu_slowspr_addr_offset      + xu_slowspr_addr_d'length;
constant xu_slowspr_done_offset            : natural :=xu_slowspr_data_offset      + xu_slowspr_data_d'length;
constant ditc_addr_t0_offset               : natural :=xu_slowspr_done_offset      + 1;
constant ditc_addr_t1_offset               : natural :=ditc_addr_t0_offset         + ditc_addr_t0_d'length;
constant ditc_addr_t2_offset               : natural :=ditc_addr_t1_offset         + ditc_addr_t1_d'length;
constant ditc_addr_t3_offset               : natural :=ditc_addr_t2_offset         + ditc_addr_t2_d'length;
constant ob0_wrt_entry_ptr_offset          : natural :=ditc_addr_t3_offset         + ditc_addr_t3_d'length;
constant ob1_wrt_entry_ptr_offset          : natural :=ob0_wrt_entry_ptr_offset    + ob0_wrt_entry_ptr_q'length;
constant ob2_wrt_entry_ptr_offset          : natural :=ob1_wrt_entry_ptr_offset    + ob1_wrt_entry_ptr_q'length;
constant ob3_wrt_entry_ptr_offset          : natural :=ob2_wrt_entry_ptr_offset    + ob2_wrt_entry_ptr_q'length;
constant ob_rd_logic_act_offset            : natural :=ob3_wrt_entry_ptr_offset    + ob3_wrt_entry_ptr_q'length;
constant ex5_wrt_ob_status_offset          : natural :=ob_rd_logic_act_offset      + 1;
constant ex6_wrt_ob_status_offset          : natural :=ex5_wrt_ob_status_offset    + ex5_wrt_ob_status_q'length;
constant ob0_buf0_status_offset            : natural :=ex6_wrt_ob_status_offset    + ex6_wrt_ob_status_q'length;
constant ob0_buf1_status_offset            : natural :=ob0_buf0_status_offset      + ob0_buf0_status_q'length;
constant ob0_buf2_status_offset            : natural :=ob0_buf1_status_offset      + ob0_buf1_status_q'length;
constant ob0_buf3_status_offset            : natural :=ob0_buf2_status_offset      + ob0_buf2_status_q'length;
constant ob1_buf0_status_offset            : natural :=ob0_buf3_status_offset      + ob0_buf3_status_q'length;
constant ob1_buf1_status_offset            : natural :=ob1_buf0_status_offset      + ob1_buf0_status_q'length;
constant ob1_buf2_status_offset            : natural :=ob1_buf1_status_offset      + ob1_buf1_status_q'length;
constant ob1_buf3_status_offset            : natural :=ob1_buf2_status_offset      + ob1_buf2_status_q'length;
constant ob2_buf0_status_offset            : natural :=ob1_buf3_status_offset      + ob1_buf3_status_q'length;
constant ob2_buf1_status_offset            : natural :=ob2_buf0_status_offset      + ob2_buf0_status_q'length;
constant ob2_buf2_status_offset            : natural :=ob2_buf1_status_offset      + ob2_buf1_status_q'length;
constant ob2_buf3_status_offset            : natural :=ob2_buf2_status_offset      + ob2_buf2_status_q'length;
constant ob3_buf0_status_offset            : natural :=ob2_buf3_status_offset      + ob2_buf3_status_q'length;
constant ob3_buf1_status_offset            : natural :=ob3_buf0_status_offset      + ob3_buf0_status_q'length;
constant ob3_buf2_status_offset            : natural :=ob3_buf1_status_offset      + ob3_buf1_status_q'length;
constant ob3_buf3_status_offset            : natural :=ob3_buf2_status_offset      + ob3_buf2_status_q'length;
constant spare0_offset                     : natural :=ob3_buf3_status_offset      + ob3_buf3_status_q'length;
constant ob_buf_status_avail_offset        : natural :=spare0_offset               + spare0_l2'length;
constant ex4_mtdp_cr_status_offset         : natural :=ob_buf_status_avail_offset  + ob_buf_status_avail_q'length;
constant ob_wrt_data_offset                : natural :=ex4_mtdp_cr_status_offset   + 1;
constant ob_ary_wen_offset                 : natural :=ob_wrt_data_offset          + ob_ary_wrt_data_l2'length;
constant ob_ary_wrt_addr_offset            : natural :=ob_ary_wen_offset           + ob_ary_wen_l2'length;
constant ob_err_inj_offset                 : natural :=ob_ary_wrt_addr_offset      + ob_ary_wrt_addr_l2'length;
constant ob_rd_data1_offset                : natural :=ob_err_inj_offset           + 1;


constant ob_rd_data_ecc0_offset            : natural :=ob_rd_data1_offset          + ob_rd_data1_l2'length;
constant ob_rd_data_ecc1_offset            : natural :=ob_rd_data_ecc0_offset      + ob_rd_data_ecc0'length;
constant ob_rd_data_ecc2_offset            : natural :=ob_rd_data_ecc1_offset      + ob_rd_data_ecc1'length;
constant ob_rd_data_ecc3_offset            : natural :=ob_rd_data_ecc2_offset      + ob_rd_data_ecc2'length;


constant ob_ary_sbe_offset                 : natural :=ob_rd_data_ecc3_offset      + ob_rd_data_ecc3'length;
constant ob_ary_ue_offset                  : natural :=ob_ary_sbe_offset           + ob_ary_sbe_q'length;
constant ob_rd_data_cor_offset             : natural :=ob_ary_ue_offset            + ob_ary_ue_q'length;
constant outbox_ecc_err_offset             : natural :=ob_rd_data_cor_offset       + ob_rd_data_cor'length;
constant outbox_ue_offset                  : natural :=outbox_ecc_err_offset       + 1;
constant ob0_rd_entry_ptr_offset           : natural :=outbox_ue_offset            + 1;
constant ob1_rd_entry_ptr_offset           : natural :=ob0_rd_entry_ptr_offset     + ob0_rd_entry_ptr_q'length;
constant ob2_rd_entry_ptr_offset           : natural :=ob1_rd_entry_ptr_offset     + ob1_rd_entry_ptr_q'length;
constant ob3_rd_entry_ptr_offset           : natural :=ob2_rd_entry_ptr_offset     + ob2_rd_entry_ptr_q'length;
constant ob_to_node_sel_offset             : natural :=ob3_rd_entry_ptr_offset     + ob3_rd_entry_ptr_q'length;

constant scan_right0                       : natural :=ob_to_node_sel_offset       + ob_to_node_sel_q'length;

constant ob_to_node_sel_sav_offset         : natural :=ob_to_node_sel_offset       + ob_to_node_sel_q'length;
constant lsu_cmd_avail_offset              : natural :=ob_to_node_sel_sav_offset   + ob_to_node_sel_sav_q'length;
constant lsu_cmd_sent_offset               : natural :=lsu_cmd_avail_offset        + 1;
constant lsu_cmd_stall_offset              : natural :=lsu_cmd_sent_offset         + 1;
constant ob_cmd_sent_count_offset          : natural :=lsu_cmd_stall_offset        + 1;
constant send_ob_state_offset              : natural :=ob_cmd_sent_count_offset    + ob_cmd_sent_count_q'length;
constant spare1_offset                     : natural :=send_ob_state_offset        + send_ob_state_q'length;
constant dly_ob_cmd_val_offset             : natural :=spare1_offset               + spare1_l2'length;
constant bxlsu_ob_req_val_offset           : natural :=dly_ob_cmd_val_offset       + dly_ob_cmd_val_q'length;
constant dly_ob_ditc_val_offset            : natural :=bxlsu_ob_req_val_offset     + 1;
constant bxlsu_ob_ditc_val_offset          : natural :=dly_ob_ditc_val_offset      + dly_ob_ditc_val_q'length;
constant dly_ob_qw_offset                  : natural :=bxlsu_ob_ditc_val_offset    + 1;
constant dly1_ob_qw_offset                 : natural :=dly_ob_qw_offset              + dly_ob_qw'length;
constant bxlsu_ob_qw_offset                : natural :=dly1_ob_qw_offset             + dly1_ob_qw'length;
constant bxlsu_ob_thrd_offset              : natural :=bxlsu_ob_qw_offset            + bx_lsu_ob_qw'length;
constant bxlsu_ob_addr_offset              : natural :=bxlsu_ob_thrd_offset          + bx_lsu_ob_thrd'length;
constant bxlsu_ob_dest_offset              : natural :=bxlsu_ob_addr_offset          + bx_lsu_ob_addr'length;
constant st_pop_offset                     : natural :=bxlsu_ob_dest_offset          + bx_lsu_ob_dest'length;
constant st_pop_thrd_offset                : natural :=st_pop_offset                 + 1;
constant ob_cmd_count_t0_offset            : natural :=st_pop_thrd_offset            + lat_st_pop_thrd'length;
constant ob_cmd_count_t1_offset            : natural :=ob_cmd_count_t0_offset        + ob_cmd_count_t0_q'length;
constant ob_cmd_count_t2_offset            : natural :=ob_cmd_count_t1_offset        + ob_cmd_count_t1_q'length;
constant ob_cmd_count_t3_offset            : natural :=ob_cmd_count_t2_offset        + ob_cmd_count_t2_q'length;
constant ex5_wrt_ib_status_offset          : natural :=ob_cmd_count_t3_offset       + ob_cmd_count_t3_q'length;
constant ex6_wrt_ib_status_offset          : natural :=ex5_wrt_ib_status_offset     + ex5_wrt_ib_status_q'length;
constant ipc_ib_t0_pop_offset              : natural :=ex6_wrt_ib_status_offset     + ex6_wrt_ib_status_q'length;
constant ipc_ib_t1_pop_offset              : natural :=ipc_ib_t0_pop_offset         + 1;
constant ipc_ib_t2_pop_offset              : natural :=ipc_ib_t1_pop_offset         + 1;
constant ipc_ib_t3_pop_offset              : natural :=ipc_ib_t2_pop_offset         + 1;
constant ib0_buf0_val_offset               : natural :=ipc_ib_t3_pop_offset         + 1;
constant ib0_buf1_val_offset               : natural :=ib0_buf0_val_offset          + 1;
constant ib0_buf2_val_offset               : natural :=ib0_buf1_val_offset          + 1;
constant ib0_buf3_val_offset               : natural :=ib0_buf2_val_offset          + 1;
constant ib1_buf0_val_offset               : natural :=ib0_buf3_val_offset          + 1;
constant ib1_buf1_val_offset               : natural :=ib1_buf0_val_offset          + 1;
constant ib1_buf2_val_offset               : natural :=ib1_buf1_val_offset          + 1;
constant ib1_buf3_val_offset               : natural :=ib1_buf2_val_offset          + 1;
constant ib2_buf0_val_offset               : natural :=ib1_buf3_val_offset          + 1;
constant ib2_buf1_val_offset               : natural :=ib2_buf0_val_offset          + 1;
constant ib2_buf2_val_offset               : natural :=ib2_buf1_val_offset          + 1;
constant ib2_buf3_val_offset               : natural :=ib2_buf2_val_offset          + 1;
constant ib3_buf0_val_offset               : natural :=ib2_buf3_val_offset          + 1;
constant ib3_buf1_val_offset               : natural :=ib3_buf0_val_offset          + 1;
constant ib3_buf2_val_offset               : natural :=ib3_buf1_val_offset          + 1;
constant ib3_buf3_val_offset               : natural :=ib3_buf2_val_offset          + 1;
constant ex5_ib_val_save_offset            : natural :=ib3_buf3_val_offset          + 1;
constant ex6_ib_val_save_offset            : natural :=ex5_ib_val_save_offset       + 1;
constant ib_empty_offset                   : natural :=ex6_ib_val_save_offset       + 1;
constant quiesce_offset                    : natural :=ib_empty_offset              + ib_empty_d'length;
constant ib0_rd_entry_ptr_offset           : natural :=quiesce_offset               + quiesce_d'length;
constant ib1_rd_entry_ptr_offset           : natural :=ib0_rd_entry_ptr_offset      + ib0_rd_entry_ptr_q'length;
constant ib2_rd_entry_ptr_offset           : natural :=ib1_rd_entry_ptr_offset      + ib1_rd_entry_ptr_q'length;
constant ib3_rd_entry_ptr_offset           : natural :=ib2_rd_entry_ptr_offset      + ib2_rd_entry_ptr_q'length;
constant ib0_rd_entry_ptr_dly_offset       : natural :=ib3_rd_entry_ptr_offset      + ib3_rd_entry_ptr_q'length;
constant ib1_rd_entry_ptr_dly_offset       : natural :=ib0_rd_entry_ptr_dly_offset  + ib0_rd_entry_ptr_dly_q'length;
constant ib2_rd_entry_ptr_dly_offset       : natural :=ib1_rd_entry_ptr_dly_offset  + ib1_rd_entry_ptr_dly_q'length;
constant ib3_rd_entry_ptr_dly_offset       : natural :=ib2_rd_entry_ptr_dly_offset  + ib2_rd_entry_ptr_dly_q'length;


constant ib_err_inj_offset                 : natural :=ib3_rd_entry_ptr_dly_offset  + ib3_rd_entry_ptr_dly_q'length;
constant ex5_inbox_data_cor_offset         : natural :=ib_err_inj_offset            + 1;
constant ib_ary_sbe_offset                 : natural :=ex5_inbox_data_cor_offset    + ex5_inbox_data_cor'length;
constant ib_ary_ue_offset                  : natural :=ib_ary_sbe_offset            + ib_ary_sbe_q'length;
constant inbox_ecc_err_offset              : natural :=ib_ary_ue_offset             + ib_ary_ue_q'length;
constant inbox_ue_offset                   : natural :=inbox_ecc_err_offset         + 1;
constant ex4_ipc_thrd_offset               : natural :=inbox_ue_offset              + 1;
constant ex5_ipc_thrd_offset               : natural :=ex4_ipc_thrd_offset          + ex4_ipc_thrd_q'length;
constant ex6_ipc_thrd_offset               : natural :=ex5_ipc_thrd_offset          + ex5_ipc_thrd_q'length;
constant ex4_ipc_ba_offset                 : natural :=ex6_ipc_thrd_offset          + ex6_ipc_thrd_q'length;
constant ex4_ipc_sz_offset                 : natural :=ex4_ipc_ba_offset            + ex4_ipc_ba_q'length;
constant ex4_dp_data_offset                : natural :=ex4_ipc_sz_offset            + ex4_ipc_sz_q'length;
constant ex4_ib_data_ecc0_offset           : natural :=ex4_dp_data_offset           + ex4_inbox_data'length;
constant ex4_ib_data_ecc1_offset           : natural :=ex4_ib_data_ecc0_offset      + ex4_ib_data_ecc0'length;
constant ex4_ib_data_ecc2_offset           : natural :=ex4_ib_data_ecc1_offset      + ex4_ib_data_ecc1'length;
constant ex4_ib_data_ecc3_offset           : natural :=ex4_ib_data_ecc2_offset      + ex4_ib_data_ecc2'length;
constant ex4_mfdp_cr_status_offset         : natural :=ex4_ib_data_ecc3_offset      + ex4_ib_data_ecc3'length;
constant ex5_ib_ecc_val_offset             : natural :=ex4_mfdp_cr_status_offset    + 1;
constant reld_data_val_offset              : natural :=ex5_ib_ecc_val_offset    + 1;
constant reld_data_val_dplus1_offset       : natural :=reld_data_val_offset         + 1;
constant reld_ditc_offset                  : natural :=reld_data_val_dplus1_offset         + 1;
constant reld_ecc_err_offset               : natural :=reld_ditc_offset             + 1;
constant reld_data_val_dminus2_offset      : natural :=reld_ecc_err_offset             + 1;
constant reld_data_val_dminus1_offset      : natural :=reld_data_val_dminus2_offset + 1;
constant reld_core_tag_dminus2_offset      : natural :=reld_data_val_dminus1_offset + 1;
constant reld_core_tag_dminus1_offset      : natural :=reld_core_tag_dminus2_offset + lat_reld_core_tag'length;
constant reld_core_tag_offset              : natural :=reld_core_tag_dminus1_offset + reld_core_tag_dminus1'length;
constant reld_core_tag_dplus1_offset       : natural :=reld_core_tag_offset         + reld_core_tag'length;
constant reld_qw_dminus2_offset            : natural :=reld_core_tag_dplus1_offset  + reld_core_tag_dplus1'length;
constant reld_qw_dminus1_offset            : natural :=reld_qw_dminus2_offset       + lat_reld_qw'length;
constant reld_qw_offset                    : natural :=reld_qw_dminus1_offset       + reld_qw_dminus1'length;
constant reld_data_offset                  : natural :=reld_qw_offset               + reld_qw'length;
constant ib0_wrt_entry_ptr_offset          : natural :=reld_data_offset             + lat_reld_data'length;
constant ib1_wrt_entry_ptr_offset          : natural :=ib0_wrt_entry_ptr_offset     + ib0_wrt_entry_ptr_q'length;
constant ib2_wrt_entry_ptr_offset          : natural :=ib1_wrt_entry_ptr_offset     + ib1_wrt_entry_ptr_q'length;
constant ib3_wrt_entry_ptr_offset          : natural :=ib2_wrt_entry_ptr_offset     + ib2_wrt_entry_ptr_q'length;
constant ib0_wrt_data_ctr_offset           : natural :=ib3_wrt_entry_ptr_offset     + ib3_wrt_entry_ptr_q'length;
constant ib1_wrt_data_ctr_offset           : natural :=ib0_wrt_data_ctr_offset      + ib0_wrt_data_ctr_q'length;
constant ib2_wrt_data_ctr_offset           : natural :=ib1_wrt_data_ctr_offset      + ib1_wrt_data_ctr_q'length;
constant ib3_wrt_data_ctr_offset           : natural :=ib2_wrt_data_ctr_offset      + ib2_wrt_data_ctr_q'length;
constant ib0_ecc_err_offset                : natural :=ib3_wrt_data_ctr_offset      + ib3_wrt_data_ctr_q'length;
constant ib1_ecc_err_offset                : natural :=ib0_ecc_err_offset          + 1;
constant ib2_ecc_err_offset                : natural :=ib1_ecc_err_offset          + 1;
constant ib3_ecc_err_offset                : natural :=ib2_ecc_err_offset          + 1;
constant ib0_set_val_offset                : natural :=ib3_ecc_err_offset          + 1;
constant ib1_set_val_offset                : natural :=ib0_set_val_offset          + 1;
constant ib2_set_val_offset                : natural :=ib1_set_val_offset          + 1;
constant ib3_set_val_offset                : natural :=ib2_set_val_offset          + 1;
constant debug_dbg_group0_offset           : natural :=ib3_set_val_offset          + 1;
constant trace_bus_enable_offset           : natural :=debug_dbg_group0_offset      + dbg_group0_q'length;
constant debug_mux_ctrls_offset            : natural :=trace_bus_enable_offset      + 1;
constant debug_mux_out_offset              : natural :=debug_mux_ctrls_offset       + debug_mux1_ctrls_q'length;
constant trigger_mux_out_offset            : natural :=debug_mux_out_offset         + debug_mux_out_d'length;

constant scan_right1                       : natural :=trigger_mux_out_offset       + trigger_mux_out_d'length;

signal siv                                : std_ulogic_vector(0 to scan_right1-1);
signal sov                                : std_ulogic_vector(0 to scan_right1-1);
signal ab_reg_si                          : std_ulogic_vector(0 to 24);
signal ab_reg_so                          : std_ulogic_vector(0 to 24);

signal unused_signals                   : std_ulogic;

begin


tidn <= '0';

unused_signals <= or_reduce(unused & delay_lclkr_dc_v(1 to 4) & mpw1_dc_b_v(1 to 4));

dp_op_val <= mtdp_ex3_to_7_val or ex3_mfdp_val_q or ex4_mfdp_val_q or ex5_mfdp_val_q or ex6_mfdp_val_q;

--**********************************************************************************************
-- Latch XU interface signals
--**********************************************************************************************

latch_my_ex3_flush : tri_rlmreg_p
  generic map (width => my_ex3_flush_q'length, init => 0, expand_type => expand_type)
  port map (nclk    => nclk,
            act     => '1',
            forcee   => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(my_ex3_flush_offset to my_ex3_flush_offset + my_ex3_flush_q'length-1),
            scout   => sov(my_ex3_flush_offset to my_ex3_flush_offset + my_ex3_flush_q'length-1),
            din     => xu_ex2_flush,
            dout    => my_ex3_flush_q );

my_ex3_flush <= (my_ex3_flush_q(0) and ex3_ipc_thrd_q="00") or
                (my_ex3_flush_q(1) and ex3_ipc_thrd_q="01") or
                (my_ex3_flush_q(2) and ex3_ipc_thrd_q="10") or
                (my_ex3_flush_q(3) and ex3_ipc_thrd_q="11");

latch_my_ex4_flush : tri_rlmreg_p
  generic map (width => my_ex4_flush_q'length, init => 0, expand_type => expand_type)
  port map (nclk    => nclk,
            act     => dp_op_val,
            forcee   => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(my_ex4_flush_offset to my_ex4_flush_offset + my_ex4_flush_q'length-1),
            scout   => sov(my_ex4_flush_offset to my_ex4_flush_offset + my_ex4_flush_q'length-1),
            din     => xu_ex3_flush,
            dout    => my_ex4_flush_q );

my_ex4_stg_flush <= (my_ex4_flush_q(0) and (ex4_ipc_thrd_q(0 to 1)="00")) or 
                    (my_ex4_flush_q(1) and (ex4_ipc_thrd_q(0 to 1)="01")) or 
                    (my_ex4_flush_q(2) and (ex4_ipc_thrd_q(0 to 1)="10")) or 
                    (my_ex4_flush_q(3) and (ex4_ipc_thrd_q(0 to 1)="11"));

latch_my_ex5_flush : tri_rlmreg_p
  generic map (width => my_ex4_flush_q'length, init => 0, expand_type => expand_type)
  port map (nclk    => nclk,
            act     => dp_op_val,
            forcee   => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(my_ex5_flush_offset to my_ex5_flush_offset + my_ex5_flush_q'length-1),
            scout   => sov(my_ex5_flush_offset to my_ex5_flush_offset + my_ex5_flush_q'length-1),
            din     => xu_ex4_flush,
            dout    => my_ex5_flush_q );

my_ex5_stg_flush <= (my_ex5_flush_q(0) and (ex5_ipc_thrd_q(0 to 1)="00")) or 
                    (my_ex5_flush_q(1) and (ex5_ipc_thrd_q(0 to 1)="01")) or 
                    (my_ex5_flush_q(2) and (ex5_ipc_thrd_q(0 to 1)="10")) or 
                    (my_ex5_flush_q(3) and (ex5_ipc_thrd_q(0 to 1)="11"));

latch_my_ex6_flush : tri_rlmreg_p
  generic map (width => my_ex4_flush_q'length, init => 0, expand_type => expand_type)
  port map (nclk    => nclk,
            act     => dp_op_val,
            forcee   => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(my_ex6_flush_offset to my_ex6_flush_offset + my_ex6_flush_q'length-1),
            scout   => sov(my_ex6_flush_offset to my_ex6_flush_offset + my_ex6_flush_q'length-1),
            din     => xu_ex5_flush,
            dout    => my_ex6_flush_q );

my_ex6_stg_flush <= (my_ex6_flush_q(0) and (ex6_ipc_thrd_q(0 to 1)="00")) or 
                    (my_ex6_flush_q(1) and (ex6_ipc_thrd_q(0 to 1)="01")) or 
                    (my_ex6_flush_q(2) and (ex6_ipc_thrd_q(0 to 1)="10")) or 
                    (my_ex6_flush_q(3) and (ex6_ipc_thrd_q(0 to 1)="11"));

latch_my_ccr2_en_ditc : tri_rlmreg_p
  generic map (width => 1, init => 0, expand_type => expand_type)
  port map (nclk    => nclk,
            act     => '1',
            forcee   => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(my_ccr2_en_ditc_offset to my_ccr2_en_ditc_offset),
            scout   => sov(my_ccr2_en_ditc_offset to my_ccr2_en_ditc_offset),
            din(0)  => xu_bx_ccr2_en_ditc,
            dout(0) => my_ccr2_en_ditc_q );

latch_ex2_mtdp_val : tri_rlmreg_p
  generic map (width => 1, init => 0, expand_type => expand_type)
  port map (nclk    => nclk,
            act     => '1',
            forcee   => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(ex2_mtdp_val_offset to ex2_mtdp_val_offset),
            scout   => sov(ex2_mtdp_val_offset to ex2_mtdp_val_offset),
            din(0)  => xu_bx_ex1_mtdp_val,
            dout(0) => ex2_mtdp_val_q );

latch_ex3_mtdp_val : tri_rlmreg_p
  generic map (width => 1, init => 0, expand_type => expand_type)
  port map (nclk    => nclk,
            act     => '1',
            forcee   => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(ex3_mtdp_val_offset to ex3_mtdp_val_offset),
            scout   => sov(ex3_mtdp_val_offset to ex3_mtdp_val_offset),
            din(0)  => ex2_mtdp_val_q,
            dout(0) => ex3_mtdp_val_q );

ex3_mtdp_val <= ex3_mtdp_val_q and not my_ex3_flush and my_ccr2_en_ditc_q;

latch_ex4_mtdp_val : tri_rlmreg_p
  generic map (width => 1, init => 0, expand_type => expand_type)
  port map (nclk    => nclk,
            act     => mtdp_ex3_to_7_val,
            forcee   => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(ex4_mtdp_val_offset to ex4_mtdp_val_offset),
            scout   => sov(ex4_mtdp_val_offset to ex4_mtdp_val_offset),
            din(0)  => ex3_mtdp_val,
            dout(0) => ex4_mtdp_val_q );
latch_ex5_mtdp_val : tri_rlmreg_p
  generic map (width => 1, init => 0, expand_type => expand_type)
  port map (nclk    => nclk,
            act     => mtdp_ex3_to_7_val,
            forcee   => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(ex5_mtdp_val_offset to ex5_mtdp_val_offset),
            scout   => sov(ex5_mtdp_val_offset to ex5_mtdp_val_offset),
            din(0)  => ex4_mtdp_val_q,
            dout(0) => ex5_mtdp_val_q );
latch_ex6_mtdp_val : tri_rlmreg_p
  generic map (width => 1, init => 0, expand_type => expand_type)
  port map (nclk    => nclk,
            act     => mtdp_ex3_to_7_val,
            forcee   => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(ex6_mtdp_val_offset to ex6_mtdp_val_offset),
            scout   => sov(ex6_mtdp_val_offset to ex6_mtdp_val_offset),
            din(0)  => ex5_mtdp_val_q,
            dout(0) => ex6_mtdp_val_q );
latch_ex7_mtdp_val : tri_rlmreg_p
  generic map (width => 1, init => 0, expand_type => expand_type)
  port map (nclk    => nclk,
            act     => mtdp_ex3_to_7_val,
            forcee   => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(ex7_mtdp_val_offset to ex7_mtdp_val_offset),
            scout   => sov(ex7_mtdp_val_offset to ex7_mtdp_val_offset),
            din(0)  => ex6_mtdp_val_q,
            dout(0) => ex7_mtdp_val_q );

mtdp_ex3_to_7_val <= ex3_mtdp_val_q or ex4_mtdp_val_q or ex5_mtdp_val_q or ex6_mtdp_val_q or ex7_mtdp_val_q;
 
latch_ex2_mfdp_val : tri_rlmreg_p
  generic map (width => 1, init => 0, expand_type => expand_type)
  port map (nclk    => nclk,
            act     => '1',
            forcee   => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(ex2_mfdp_val_offset to ex2_mfdp_val_offset),
            scout   => sov(ex2_mfdp_val_offset to ex2_mfdp_val_offset),
            din(0)  => xu_bx_ex1_mfdp_val,
            dout(0) => ex2_mfdp_val_q );
latch_ex3_mfdp_val : tri_rlmreg_p
  generic map (width => 1, init => 0, expand_type => expand_type)
  port map (nclk    => nclk,
            act     => '1',
            forcee   => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(ex3_mfdp_val_offset to ex3_mfdp_val_offset),
            scout   => sov(ex3_mfdp_val_offset to ex3_mfdp_val_offset),
            din(0)  => ex2_mfdp_val_q,
            dout(0) => ex3_mfdp_val_q );
latch_ex4_mfdp_val : tri_rlmreg_p
  generic map (width => 1, init => 0, expand_type => expand_type)
  port map (nclk    => nclk,
            act     => dp_op_val,
            forcee   => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(ex4_mfdp_val_offset to ex4_mfdp_val_offset),
            scout   => sov(ex4_mfdp_val_offset to ex4_mfdp_val_offset),
            din(0)  => ex3_mfdp_val_q,
            dout(0) => ex4_mfdp_val_q );
latch_ex5_mfdp_val : tri_rlmreg_p
  generic map (width => 1, init => 0, expand_type => expand_type)
  port map (nclk    => nclk,
            act     => dp_op_val,
            forcee   => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(ex5_mfdp_val_offset to ex5_mfdp_val_offset),
            scout   => sov(ex5_mfdp_val_offset to ex5_mfdp_val_offset),
            din(0)  => ex4_mfdp_val_q,
            dout(0) => ex5_mfdp_val_q );
latch_ex6_mfdp_val : tri_rlmreg_p
  generic map (width => 1, init => 0, expand_type => expand_type)
  port map (nclk    => nclk,
            act     => dp_op_val,
            forcee   => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(ex6_mfdp_val_offset to ex6_mfdp_val_offset),
            scout   => sov(ex6_mfdp_val_offset to ex6_mfdp_val_offset),
            din(0)  => ex5_mfdp_val_q,
            dout(0) => ex6_mfdp_val_q );
latch_ex2_ipc_thrd : tri_rlmreg_p
  generic map (width => ex2_ipc_thrd_q'length, init => 0, expand_type => expand_type)
  port map (nclk    => nclk,
            act     => '1',
            forcee   => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(ex2_ipc_thrd_offset to ex2_ipc_thrd_offset + ex2_ipc_thrd_q'length-1),
            scout   => sov(ex2_ipc_thrd_offset to ex2_ipc_thrd_offset + ex2_ipc_thrd_q'length-1),
            din     => xu_bx_ex1_ipc_thrd(0 to 1),
            dout    => ex2_ipc_thrd_q(0 to 1) );
latch_ex3_ipc_thrd : tri_rlmreg_p
  generic map (width => ex3_ipc_thrd_q'length, init => 0, expand_type => expand_type)
  port map (nclk    => nclk,
            act     => '1',
            forcee   => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(ex3_ipc_thrd_offset to ex3_ipc_thrd_offset + ex3_ipc_thrd_q'length-1),
            scout   => sov(ex3_ipc_thrd_offset to ex3_ipc_thrd_offset + ex3_ipc_thrd_q'length-1),
            din     => ex2_ipc_thrd_q(0 to 1),
            dout    => ex3_ipc_thrd_q(0 to 1) );
latch_ex3_ipc_ba : tri_rlmreg_p
  generic map (width => ex3_ipc_ba_q'length, init => 0, expand_type => expand_type)
  port map (nclk    => nclk,
            act     => '1',
            forcee   => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(ex3_ipc_ba_offset to ex3_ipc_ba_offset + ex3_ipc_ba_q'length-1),
            scout   => sov(ex3_ipc_ba_offset to ex3_ipc_ba_offset + ex3_ipc_ba_q'length-1),
            din     => xu_bx_ex2_ipc_ba(0 to 4),
            dout    => ex3_ipc_ba_q(0 to 4) );
latch_ex3_ipc_sz : tri_rlmreg_p
  generic map (width => ex3_ipc_sz_q'length, init => 0, expand_type => expand_type)
  port map (nclk    => nclk,
            act     => '1',
            forcee   => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(ex3_ipc_sz_offset to ex3_ipc_sz_offset + ex3_ipc_sz_q'length-1),
            scout   => sov(ex3_ipc_sz_offset to ex3_ipc_sz_offset + ex3_ipc_sz_q'length-1),
            din     => xu_bx_ex2_ipc_sz(0 to 1),
            dout    => ex3_ipc_sz_q(0 to 1) );

-- XXXXXXXXXXXXXXXXXX
-- Slow SPR's
-- XXXXXXXXXXXXXXXXXX

ditc_addr_sel <= (bx_slowspr_addr_q = "11" & x"DF");

ditc_addr_wen <= bx_slowspr_val_q and ditc_addr_sel and not bx_slowspr_rw_q;

-- SLOWSPR Writes

-- Thread 0 SlowSPR Register
ditc_addr_t0_wen   <= ditc_addr_wen and (bx_slowspr_etid_q = "00");

ditc_addr_t0_d <= bx_slowspr_data_q(64-real_data_add to 57) when ditc_addr_t0_wen='1' else 
                  ditc_addr_t0_q;

-- Thread 1 SlowSPR Register
ditc_addr_t1_wen   <= ditc_addr_wen and (bx_slowspr_etid_q = "01");

ditc_addr_t1_d <= bx_slowspr_data_q(64-real_data_add to 57) when ditc_addr_t1_wen='1' else 
                  ditc_addr_t1_q;

-- Thread 2 SlowSPR Register
ditc_addr_t2_wen   <= ditc_addr_wen and (bx_slowspr_etid_q = "10");

ditc_addr_t2_d <= bx_slowspr_data_q(64-real_data_add to 57) when ditc_addr_t2_wen='1' else 
                  ditc_addr_t2_q;

-- Thread 3 SlowSPR Register
ditc_addr_t3_wen   <= ditc_addr_wen and (bx_slowspr_etid_q = "11");

ditc_addr_t3_d <= bx_slowspr_data_q(64-real_data_add to 57) when ditc_addr_t3_wen='1' else 
                  ditc_addr_t3_q;


-- SLOWSPR Read
-- Thread Register Selection
with bx_slowspr_etid_q select
    ditc_addr_reg(64-real_data_add to 57) <= ditc_addr_t0_q when "00",
                                             ditc_addr_t1_q when "01",
                                             ditc_addr_t2_q when "10",
                                             ditc_addr_t3_q when others;

ditc_addr_reg(64-(2**REGMODE) to 64-real_data_add-1) <= (others=>'0');
ditc_addr_reg(58 to 63)                              <= (others=>'0');

-- SlowSPR Selection
ditc_addr_rd_val <= bx_slowspr_val_q and ditc_addr_sel and bx_slowspr_rw_q;

xu_slowspr_data_d <= ditc_addr_reg        when ditc_addr_rd_val='1' else 
                     bx_slowspr_data_q;

-- Operation Complete
xu_slowspr_done_d <= (bx_slowspr_val_q and ditc_addr_sel) or bx_slowspr_done_q;


xu_slowspr_val_d  <= bx_slowspr_val_q;
xu_slowspr_rw_d   <= bx_slowspr_rw_q;
xu_slowspr_etid_d <= bx_slowspr_etid_q;
xu_slowspr_addr_d <= bx_slowspr_addr_q; 

latch_bx_slowspr_val : tri_rlmreg_p
  generic map (width => 1, init => 0, expand_type => expand_type)
  port map (nclk    => nclk,
            act     => '1',
            forcee   => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(bx_slowspr_val_offset to bx_slowspr_val_offset),
            scout   => sov(bx_slowspr_val_offset to bx_slowspr_val_offset),
            din(0)  => slowspr_val_in,
            dout(0) => bx_slowspr_val_q );
 
latch_bx_slowspr_rw : tri_rlmreg_p
  generic map (width => 1, init => 0, expand_type => expand_type)
  port map (nclk    => nclk,
            act     => slowspr_val_in,
            forcee   => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(bx_slowspr_rw_offset to bx_slowspr_rw_offset),
            scout   => sov(bx_slowspr_rw_offset to bx_slowspr_rw_offset),
            din(0)  => slowspr_rw_in,
            dout(0) => bx_slowspr_rw_q );

latch_bx_slowspr_etid : tri_rlmreg_p
  generic map (width => bx_slowspr_etid_q'length, init => 0, expand_type => expand_type)
  port map (nclk    => nclk,
            act     => slowspr_val_in,
            forcee   => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(bx_slowspr_etid_offset to bx_slowspr_etid_offset + bx_slowspr_etid_q'length-1),
            scout   => sov(bx_slowspr_etid_offset to bx_slowspr_etid_offset + bx_slowspr_etid_q'length-1),
            din     => slowspr_etid_in,
            dout    => bx_slowspr_etid_q );

latch_bx_slowspr_addr : tri_rlmreg_p
  generic map (width => bx_slowspr_addr_q'length, init => 0, expand_type => expand_type)
  port map (nclk    => nclk,
            act     => slowspr_val_in,
            forcee   => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(bx_slowspr_addr_offset to bx_slowspr_addr_offset + bx_slowspr_addr_q'length-1),
            scout   => sov(bx_slowspr_addr_offset to bx_slowspr_addr_offset + bx_slowspr_addr_q'length-1),
            din     => slowspr_addr_in,
            dout    => bx_slowspr_addr_q );

latch_bx_slowspr_data : tri_rlmreg_p
  generic map (width => bx_slowspr_data_q'length, init => 0, expand_type => expand_type)
  port map (nclk    => nclk,
            act     => slowspr_val_in,
            forcee   => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(bx_slowspr_data_offset to bx_slowspr_data_offset + bx_slowspr_data_q'length-1),
            scout   => sov(bx_slowspr_data_offset to bx_slowspr_data_offset + bx_slowspr_data_q'length-1),
            din     => slowspr_data_in,
            dout    => bx_slowspr_data_q );

latch_bx_slowspr_done : tri_rlmreg_p
  generic map (width => 1, init => 0, expand_type => expand_type)
  port map (nclk    => nclk,
            act     => slowspr_val_in,
            forcee   => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(bx_slowspr_done_offset to bx_slowspr_done_offset),
            scout   => sov(bx_slowspr_done_offset to bx_slowspr_done_offset),
            din(0)  => slowspr_done_in,
            dout(0) => bx_slowspr_done_q );

latch_xu_slowspr_val : tri_rlmreg_p
  generic map (width => 1, init => 0, expand_type => expand_type)
  port map (nclk    => nclk,
            act     => '1',
            forcee   => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(xu_slowspr_val_offset to xu_slowspr_val_offset),
            scout   => sov(xu_slowspr_val_offset to xu_slowspr_val_offset),
            din(0)  => xu_slowspr_val_d,
            dout(0) => slowspr_val_out );

 
latch_xu_slowspr_rw : tri_rlmreg_p
  generic map (width => 1, init => 0, expand_type => expand_type)
  port map (nclk    => nclk,
            act     => bx_slowspr_val_q,
            forcee   => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(xu_slowspr_rw_offset to xu_slowspr_rw_offset),
            scout   => sov(xu_slowspr_rw_offset to xu_slowspr_rw_offset),
            din(0)  => xu_slowspr_rw_d,
            dout(0) => slowspr_rw_out );

latch_xu_slowspr_etid : tri_rlmreg_p
  generic map (width => xu_slowspr_etid_d'length, init => 0, expand_type => expand_type)
  port map (nclk    => nclk,
            act     => bx_slowspr_val_q,
            forcee   => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(xu_slowspr_etid_offset to xu_slowspr_etid_offset + xu_slowspr_etid_d'length-1),
            scout   => sov(xu_slowspr_etid_offset to xu_slowspr_etid_offset + xu_slowspr_etid_d'length-1),
            din     => xu_slowspr_etid_d,
            dout   => slowspr_etid_out );

latch_xu_slowspr_addr : tri_rlmreg_p
  generic map (width => xu_slowspr_addr_d'length, init => 0, expand_type => expand_type)
  port map (nclk    => nclk,
            act     => bx_slowspr_val_q,
            forcee   => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(xu_slowspr_addr_offset to xu_slowspr_addr_offset + xu_slowspr_addr_d'length-1),
            scout   => sov(xu_slowspr_addr_offset to xu_slowspr_addr_offset + xu_slowspr_addr_d'length-1),
            din     => xu_slowspr_addr_d,
            dout   => slowspr_addr_out );

latch_xu_slowspr_data : tri_rlmreg_p
  generic map (width => xu_slowspr_data_d'length, init => 0, expand_type => expand_type)
  port map (nclk    => nclk,
            act     => bx_slowspr_val_q,
            forcee   => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(xu_slowspr_data_offset to xu_slowspr_data_offset + xu_slowspr_data_d'length-1),
            scout   => sov(xu_slowspr_data_offset to xu_slowspr_data_offset + xu_slowspr_data_d'length-1),
            din     => xu_slowspr_data_d,
            dout   => slowspr_data_out );

latch_xu_slowspr_done : tri_rlmreg_p
  generic map (width => 1, init => 0, expand_type => expand_type)
  port map (nclk    => nclk,
            act     => bx_slowspr_val_q,
            forcee   => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(xu_slowspr_done_offset to xu_slowspr_done_offset),
            scout   => sov(xu_slowspr_done_offset to xu_slowspr_done_offset),
            din(0)  => xu_slowspr_done_d,
            dout(0) => slowspr_done_out );

latch_ditc_addr_t0 : tri_rlmreg_p
  generic map (width => ditc_addr_t0_d'length, init => 0, expand_type => expand_type)
  port map (nclk    => nclk,
            act     => ditc_addr_wen,
            forcee   => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(ditc_addr_t0_offset to ditc_addr_t0_offset + ditc_addr_t0_d'length-1),
            scout   => sov(ditc_addr_t0_offset to ditc_addr_t0_offset + ditc_addr_t0_d'length-1),
            din     => ditc_addr_t0_d,
            dout    => ditc_addr_t0_q );

latch_ditc_addr_t1 : tri_rlmreg_p
  generic map (width => ditc_addr_t1_d'length, init => 0, expand_type => expand_type)
  port map (nclk    => nclk,
            act     => ditc_addr_wen,
            forcee   => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(ditc_addr_t1_offset to ditc_addr_t1_offset + ditc_addr_t1_d'length-1),
            scout   => sov(ditc_addr_t1_offset to ditc_addr_t1_offset + ditc_addr_t1_d'length-1),
            din     => ditc_addr_t1_d,
            dout    => ditc_addr_t1_q );

latch_ditc_addr_t2 : tri_rlmreg_p
  generic map (width => ditc_addr_t2_d'length, init => 0, expand_type => expand_type)
  port map (nclk    => nclk,
            act     => ditc_addr_wen,
            forcee   => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(ditc_addr_t2_offset to ditc_addr_t2_offset + ditc_addr_t2_d'length-1),
            scout   => sov(ditc_addr_t2_offset to ditc_addr_t2_offset + ditc_addr_t2_d'length-1),
            din     => ditc_addr_t2_d,
            dout    => ditc_addr_t2_q );

latch_ditc_addr_t3 : tri_rlmreg_p
  generic map (width => ditc_addr_t3_d'length, init => 0, expand_type => expand_type)
  port map (nclk    => nclk,
            act     => ditc_addr_wen,
            forcee   => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(ditc_addr_t3_offset to ditc_addr_t3_offset + ditc_addr_t3_d'length-1),
            scout   => sov(ditc_addr_t3_offset to ditc_addr_t3_offset + ditc_addr_t3_d'length-1),
            din     => ditc_addr_t3_d,
            dout    => ditc_addr_t3_q );

-- ********************************************************************************************
--
-- OUTBOX
--
-- ********************************************************************************************

ex4_mtdp_val_gated <= ex4_mtdp_val_q and not my_ex4_stg_flush;


--**********************************************************************************************
-- increment outbox buffer write pointer when message buffer complete reg is written valid
-- there is one buffer pointer per thread
--**********************************************************************************************

ob0_wrt_entry_ptr_d <= std_ulogic_vector(unsigned(ob0_wrt_entry_ptr_q) + 1)  when ob0_set_val='1'   else
                       std_ulogic_vector(unsigned(ob0_wrt_entry_ptr_q) - 1)  when (ex5_ob0_flushed xor ex6_ob0_flushed)='1'   else
                       std_ulogic_vector(unsigned(ob0_wrt_entry_ptr_q) - 2)  when (ex5_ob0_flushed and ex6_ob0_flushed)='1'   else
                       ob0_wrt_entry_ptr_q(0 to 1);

ob1_wrt_entry_ptr_d <= std_ulogic_vector(unsigned(ob1_wrt_entry_ptr_q) + 1)  when ob1_set_val='1'   else
                       std_ulogic_vector(unsigned(ob1_wrt_entry_ptr_q) - 1)  when (ex5_ob1_flushed xor ex6_ob1_flushed)='1'   else
                       std_ulogic_vector(unsigned(ob1_wrt_entry_ptr_q) - 2)  when (ex5_ob1_flushed and ex6_ob1_flushed)='1'   else
                       ob1_wrt_entry_ptr_q(0 to 1);

ob2_wrt_entry_ptr_d <= std_ulogic_vector(unsigned(ob2_wrt_entry_ptr_q) + 1)  when ob2_set_val='1'   else
                       std_ulogic_vector(unsigned(ob2_wrt_entry_ptr_q) - 1)  when (ex5_ob2_flushed xor ex6_ob2_flushed)='1'   else
                       std_ulogic_vector(unsigned(ob2_wrt_entry_ptr_q) - 2)  when (ex5_ob2_flushed and ex6_ob2_flushed)='1'   else
                       ob2_wrt_entry_ptr_q(0 to 1);

ob3_wrt_entry_ptr_d <= std_ulogic_vector(unsigned(ob3_wrt_entry_ptr_q) + 1)  when ob3_set_val='1'   else
                       std_ulogic_vector(unsigned(ob3_wrt_entry_ptr_q) - 1)  when (ex5_ob3_flushed xor ex6_ob3_flushed)='1'   else
                       std_ulogic_vector(unsigned(ob3_wrt_entry_ptr_q) - 2)  when (ex5_ob3_flushed and ex6_ob3_flushed)='1'   else
                       ob3_wrt_entry_ptr_q(0 to 1);

--**********************************************************************************************************
-- Dealing with flushed ops:
--
-- In order to deal with flushed ops up until ex5, these pointers will be pipeline staged until ex5.
-- If the op is flushed in ex5, the new pointer will be loaded from the staged ex5 pointer.
-- An additional bit for each message buffer complete reg will get set in ex5 if the op is not flushed.
-- Before the buffer is eligible to be sent to node, both the valid and committed bits must be set (could
-- probably just look at the committed bit which will not be set unless the valid is on).  If the
-- committed bit is not set in ex5 because of a flush, then the messge buffer complete reg should be
-- cleared.
-- Probably have to stage the thread ID until ex5 too so that I know which buffer to use in ex5.
--**********************************************************************************************************


latch_ob0_wrt_entry_ptr : tri_rlmreg_p
  generic map (width => ob0_wrt_entry_ptr_q'length, init => 0, expand_type => expand_type)
  port map (nclk    => nclk,
            act     => mtdp_ex3_to_7_val,
            forcee   => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(ob0_wrt_entry_ptr_offset to ob0_wrt_entry_ptr_offset + ob0_wrt_entry_ptr_q'length-1),
            scout   => sov(ob0_wrt_entry_ptr_offset to ob0_wrt_entry_ptr_offset + ob0_wrt_entry_ptr_q'length-1),
            din     => ob0_wrt_entry_ptr_d(0 to 1),
            dout    => ob0_wrt_entry_ptr_q(0 to 1) );

latch_ob1_wrt_entry_ptr : tri_rlmreg_p
  generic map (width => ob1_wrt_entry_ptr_q'length, init => 0, expand_type => expand_type)
  port map (nclk    => nclk,
            act     => mtdp_ex3_to_7_val,
            forcee   => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(ob1_wrt_entry_ptr_offset to ob1_wrt_entry_ptr_offset + ob1_wrt_entry_ptr_q'length-1),
            scout   => sov(ob1_wrt_entry_ptr_offset to ob1_wrt_entry_ptr_offset + ob1_wrt_entry_ptr_q'length-1),
            din     => ob1_wrt_entry_ptr_d(0 to 1),
            dout    => ob1_wrt_entry_ptr_q(0 to 1) );

latch_ob2_wrt_entry_ptr : tri_rlmreg_p
  generic map (width => ob2_wrt_entry_ptr_q'length, init => 0, expand_type => expand_type)
  port map (nclk    => nclk,
            act     => mtdp_ex3_to_7_val,
            forcee   => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(ob2_wrt_entry_ptr_offset to ob2_wrt_entry_ptr_offset + ob2_wrt_entry_ptr_q'length-1),
            scout   => sov(ob2_wrt_entry_ptr_offset to ob2_wrt_entry_ptr_offset + ob2_wrt_entry_ptr_q'length-1),
            din     => ob2_wrt_entry_ptr_d(0 to 1),
            dout    => ob2_wrt_entry_ptr_q(0 to 1) );

latch_ob3_wrt_entry_ptr : tri_rlmreg_p
  generic map (width => ob3_wrt_entry_ptr_q'length, init => 0, expand_type => expand_type)
  port map (nclk    => nclk,
            act     => mtdp_ex3_to_7_val,
            forcee   => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(ob3_wrt_entry_ptr_offset to ob3_wrt_entry_ptr_offset + ob3_wrt_entry_ptr_q'length-1),
            scout   => sov(ob3_wrt_entry_ptr_offset to ob3_wrt_entry_ptr_offset + ob3_wrt_entry_ptr_q'length-1),
            din     => ob3_wrt_entry_ptr_d(0 to 1),
            dout    => ob3_wrt_entry_ptr_q(0 to 1) );

--****************************************************************************
-- write to the data port message buffer complete register when BA = 10001
-- since ba(3:4)=01 the rotator will put the data on word 1
--****************************************************************************

ob_status_reg_newdata(0 to 17) <= xu_bx_ex4_256st_data(32) &               -- valid bit
                                  xu_bx_ex4_256st_data(33 to 34) &         -- length
                                  xu_bx_ex4_256st_data(49 to 55) &         -- dest node
                                  xu_bx_ex4_256st_data(56 to 63);          -- dest thread

wrt_ob0_buf0_status <= not ob0_buf0_status_avail and ex4_mtdp_val_gated and (ex4_ipc_thrd_q = "00") and (ex4_ipc_ba_q = "10001") and (ob0_wrt_entry_ptr_q = "00");
wrt_ob0_buf1_status <= not ob0_buf1_status_avail and ex4_mtdp_val_gated and (ex4_ipc_thrd_q = "00") and (ex4_ipc_ba_q = "10001") and (ob0_wrt_entry_ptr_q = "01");
wrt_ob0_buf2_status <= not ob0_buf2_status_avail and ex4_mtdp_val_gated and (ex4_ipc_thrd_q = "00") and (ex4_ipc_ba_q = "10001") and (ob0_wrt_entry_ptr_q = "10");
wrt_ob0_buf3_status <= not ob0_buf3_status_avail and ex4_mtdp_val_gated and (ex4_ipc_thrd_q = "00") and (ex4_ipc_ba_q = "10001") and (ob0_wrt_entry_ptr_q = "11");
wrt_ob1_buf0_status <= not ob1_buf0_status_avail and ex4_mtdp_val_gated and (ex4_ipc_thrd_q = "01") and (ex4_ipc_ba_q = "10001") and (ob1_wrt_entry_ptr_q = "00");
wrt_ob1_buf1_status <= not ob1_buf1_status_avail and ex4_mtdp_val_gated and (ex4_ipc_thrd_q = "01") and (ex4_ipc_ba_q = "10001") and (ob1_wrt_entry_ptr_q = "01");
wrt_ob1_buf2_status <= not ob1_buf2_status_avail and ex4_mtdp_val_gated and (ex4_ipc_thrd_q = "01") and (ex4_ipc_ba_q = "10001") and (ob1_wrt_entry_ptr_q = "10");
wrt_ob1_buf3_status <= not ob1_buf3_status_avail and ex4_mtdp_val_gated and (ex4_ipc_thrd_q = "01") and (ex4_ipc_ba_q = "10001") and (ob1_wrt_entry_ptr_q = "11");
wrt_ob2_buf0_status <= not ob2_buf0_status_avail and ex4_mtdp_val_gated and (ex4_ipc_thrd_q = "10") and (ex4_ipc_ba_q = "10001") and (ob2_wrt_entry_ptr_q = "00");
wrt_ob2_buf1_status <= not ob2_buf1_status_avail and ex4_mtdp_val_gated and (ex4_ipc_thrd_q = "10") and (ex4_ipc_ba_q = "10001") and (ob2_wrt_entry_ptr_q = "01");
wrt_ob2_buf2_status <= not ob2_buf2_status_avail and ex4_mtdp_val_gated and (ex4_ipc_thrd_q = "10") and (ex4_ipc_ba_q = "10001") and (ob2_wrt_entry_ptr_q = "10");
wrt_ob2_buf3_status <= not ob2_buf3_status_avail and ex4_mtdp_val_gated and (ex4_ipc_thrd_q = "10") and (ex4_ipc_ba_q = "10001") and (ob2_wrt_entry_ptr_q = "11");
wrt_ob3_buf0_status <= not ob3_buf0_status_avail and ex4_mtdp_val_gated and (ex4_ipc_thrd_q = "11") and (ex4_ipc_ba_q = "10001") and (ob3_wrt_entry_ptr_q = "00");
wrt_ob3_buf1_status <= not ob3_buf1_status_avail and ex4_mtdp_val_gated and (ex4_ipc_thrd_q = "11") and (ex4_ipc_ba_q = "10001") and (ob3_wrt_entry_ptr_q = "01");
wrt_ob3_buf2_status <= not ob3_buf2_status_avail and ex4_mtdp_val_gated and (ex4_ipc_thrd_q = "11") and (ex4_ipc_ba_q = "10001") and (ob3_wrt_entry_ptr_q = "10");
wrt_ob3_buf3_status <= not ob3_buf3_status_avail and ex4_mtdp_val_gated and (ex4_ipc_thrd_q = "11") and (ex4_ipc_ba_q = "10001") and (ob3_wrt_entry_ptr_q = "11");

ob0_set_val <= wrt_ob0_buf0_status or wrt_ob0_buf1_status or wrt_ob0_buf2_status or wrt_ob0_buf3_status;
ob1_set_val <= wrt_ob1_buf0_status or wrt_ob1_buf1_status or wrt_ob1_buf2_status or wrt_ob1_buf3_status;
ob2_set_val <= wrt_ob2_buf0_status or wrt_ob2_buf1_status or wrt_ob2_buf2_status or wrt_ob2_buf3_status;
ob3_set_val <= wrt_ob3_buf0_status or wrt_ob3_buf1_status or wrt_ob3_buf2_status or wrt_ob3_buf3_status;

-- remember which status reg written last cycle

ex4_wrt_ob_status(0 to 15) <=  wrt_ob0_buf0_status & wrt_ob0_buf1_status & wrt_ob0_buf2_status & wrt_ob0_buf3_status &
                               wrt_ob1_buf0_status & wrt_ob1_buf1_status & wrt_ob1_buf2_status & wrt_ob1_buf3_status &
                               wrt_ob2_buf0_status & wrt_ob2_buf1_status & wrt_ob2_buf2_status & wrt_ob2_buf3_status &
                               wrt_ob3_buf0_status & wrt_ob3_buf1_status & wrt_ob3_buf2_status & wrt_ob3_buf3_status;

ob_rd_logic_act_d <= ex4_mtdp_val_q or 
                     ob0_buf0_status_q(0) or ob0_buf1_status_q(0) or ob0_buf2_status_q(0) or ob0_buf3_status_q(0) or 
                     ob1_buf0_status_q(0) or ob1_buf1_status_q(0) or ob1_buf2_status_q(0) or ob1_buf3_status_q(0) or 
                     ob2_buf0_status_q(0) or ob2_buf1_status_q(0) or ob2_buf2_status_q(0) or ob2_buf3_status_q(0) or 
                     ob3_buf0_status_q(0) or ob3_buf1_status_q(0) or ob3_buf2_status_q(0) or ob3_buf3_status_q(0);

latch_ob_rd_logic_act : tri_rlmreg_p
  generic map (width => 1, init => 0, expand_type => expand_type)
  port map (nclk    => nclk,
            act     => ob_rd_logic_act,
            forcee   => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(ob_rd_logic_act_offset to ob_rd_logic_act_offset),
            scout   => sov(ob_rd_logic_act_offset to ob_rd_logic_act_offset),
            din(0)  => ob_rd_logic_act_d,
            dout(0) => ob_rd_logic_act_q );

ob_rd_logic_act <= ob_rd_logic_act_q or ex4_mtdp_val_q or ex5_mtdp_val_q or ex6_mtdp_val_q;

latch_ex5_wrt_ob_status : tri_rlmreg_p
  generic map (width => ex5_wrt_ob_status_q'length, init => 0, expand_type => expand_type)
  port map (nclk    => nclk,
            act     => ob_rd_logic_act,
            forcee   => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(ex5_wrt_ob_status_offset to ex5_wrt_ob_status_offset + ex5_wrt_ob_status_q'length-1),
            scout   => sov(ex5_wrt_ob_status_offset to ex5_wrt_ob_status_offset + ex5_wrt_ob_status_q'length-1),
            din     => ex4_wrt_ob_status(0 to 15),
            dout    => ex5_wrt_ob_status_q(0 to 15) );

ex5_wrt_ob_status_gated(0 to 15) <= gate_and(not my_ex5_stg_flush, ex5_wrt_ob_status_q(0 to 15));

latch_ex6_wrt_ob_status : tri_rlmreg_p
  generic map (width => ex6_wrt_ob_status_q'length, init => 0, expand_type => expand_type)
  port map (nclk    => nclk,
            act     => ob_rd_logic_act,
            forcee   => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(ex6_wrt_ob_status_offset to ex6_wrt_ob_status_offset + ex6_wrt_ob_status_q'length-1),
            scout   => sov(ex6_wrt_ob_status_offset to ex6_wrt_ob_status_offset + ex6_wrt_ob_status_q'length-1),
            din     => ex5_wrt_ob_status_gated(0 to 15),
            dout    => ex6_wrt_ob_status_q(0 to 15) );

ex5_ob0_buf0_flushed <= ex5_wrt_ob_status_q(0)  and my_ex5_stg_flush;
ex5_ob0_buf1_flushed <= ex5_wrt_ob_status_q(1)  and my_ex5_stg_flush;
ex5_ob0_buf2_flushed <= ex5_wrt_ob_status_q(2)  and my_ex5_stg_flush;
ex5_ob0_buf3_flushed <= ex5_wrt_ob_status_q(3)  and my_ex5_stg_flush;
ex5_ob1_buf0_flushed <= ex5_wrt_ob_status_q(4)  and my_ex5_stg_flush;
ex5_ob1_buf1_flushed <= ex5_wrt_ob_status_q(5)  and my_ex5_stg_flush;
ex5_ob1_buf2_flushed <= ex5_wrt_ob_status_q(6)  and my_ex5_stg_flush;
ex5_ob1_buf3_flushed <= ex5_wrt_ob_status_q(7)  and my_ex5_stg_flush;
ex5_ob2_buf0_flushed <= ex5_wrt_ob_status_q(8)  and my_ex5_stg_flush;
ex5_ob2_buf1_flushed <= ex5_wrt_ob_status_q(9)  and my_ex5_stg_flush;
ex5_ob2_buf2_flushed <= ex5_wrt_ob_status_q(10) and my_ex5_stg_flush;
ex5_ob2_buf3_flushed <= ex5_wrt_ob_status_q(11) and my_ex5_stg_flush;
ex5_ob3_buf0_flushed <= ex5_wrt_ob_status_q(12) and my_ex5_stg_flush;
ex5_ob3_buf1_flushed <= ex5_wrt_ob_status_q(13) and my_ex5_stg_flush;
ex5_ob3_buf2_flushed <= ex5_wrt_ob_status_q(14) and my_ex5_stg_flush;
ex5_ob3_buf3_flushed <= ex5_wrt_ob_status_q(15) and my_ex5_stg_flush;

ex5_ob0_flushed <= ex5_ob0_buf0_flushed or ex5_ob0_buf1_flushed or ex5_ob0_buf2_flushed or ex5_ob0_buf3_flushed;
ex5_ob1_flushed <= ex5_ob1_buf0_flushed or ex5_ob1_buf1_flushed or ex5_ob1_buf2_flushed or ex5_ob1_buf3_flushed;
ex5_ob2_flushed <= ex5_ob2_buf0_flushed or ex5_ob2_buf1_flushed or ex5_ob2_buf2_flushed or ex5_ob2_buf3_flushed;
ex5_ob3_flushed <= ex5_ob3_buf0_flushed or ex5_ob3_buf1_flushed or ex5_ob3_buf2_flushed or ex5_ob3_buf3_flushed;
 
ex6_ob0_buf0_flushed <= ex6_wrt_ob_status_q(0)  and my_ex6_stg_flush;
ex6_ob0_buf1_flushed <= ex6_wrt_ob_status_q(1)  and my_ex6_stg_flush;
ex6_ob0_buf2_flushed <= ex6_wrt_ob_status_q(2)  and my_ex6_stg_flush;
ex6_ob0_buf3_flushed <= ex6_wrt_ob_status_q(3)  and my_ex6_stg_flush;
ex6_ob1_buf0_flushed <= ex6_wrt_ob_status_q(4)  and my_ex6_stg_flush;
ex6_ob1_buf1_flushed <= ex6_wrt_ob_status_q(5)  and my_ex6_stg_flush;
ex6_ob1_buf2_flushed <= ex6_wrt_ob_status_q(6)  and my_ex6_stg_flush;
ex6_ob1_buf3_flushed <= ex6_wrt_ob_status_q(7)  and my_ex6_stg_flush;
ex6_ob2_buf0_flushed <= ex6_wrt_ob_status_q(8)  and my_ex6_stg_flush;
ex6_ob2_buf1_flushed <= ex6_wrt_ob_status_q(9)  and my_ex6_stg_flush;
ex6_ob2_buf2_flushed <= ex6_wrt_ob_status_q(10) and my_ex6_stg_flush;
ex6_ob2_buf3_flushed <= ex6_wrt_ob_status_q(11) and my_ex6_stg_flush;
ex6_ob3_buf0_flushed <= ex6_wrt_ob_status_q(12) and my_ex6_stg_flush;
ex6_ob3_buf1_flushed <= ex6_wrt_ob_status_q(13) and my_ex6_stg_flush;
ex6_ob3_buf2_flushed <= ex6_wrt_ob_status_q(14) and my_ex6_stg_flush;
ex6_ob3_buf3_flushed <= ex6_wrt_ob_status_q(15) and my_ex6_stg_flush;

ex6_ob0_flushed <= ex6_ob0_buf0_flushed or ex6_ob0_buf1_flushed or ex6_ob0_buf2_flushed or ex6_ob0_buf3_flushed;
ex6_ob1_flushed <= ex6_ob1_buf0_flushed or ex6_ob1_buf1_flushed or ex6_ob1_buf2_flushed or ex6_ob1_buf3_flushed;
ex6_ob2_flushed <= ex6_ob2_buf0_flushed or ex6_ob2_buf1_flushed or ex6_ob2_buf2_flushed or ex6_ob2_buf3_flushed;
ex6_ob3_flushed <= ex6_ob3_buf0_flushed or ex6_ob3_buf1_flushed or ex6_ob3_buf2_flushed or ex6_ob3_buf3_flushed;

ob0_buf0_clr <= ob0_buf0_done or ex5_ob0_buf0_flushed or ex6_ob0_buf0_flushed;

ob0_buf0_status_avail <= ob0_buf0_status_q(0) and not ex5_ob0_buf0_flushed and not ex6_ob0_buf0_flushed;

ob0_buf0_status_d(0 to 17) <= ob_status_reg_newdata(0 to 17)  when wrt_ob0_buf0_status='1' else
                              (others => '0')                 when ob0_buf0_clr='1'        else
                              ob0_buf0_status_q(0 to 17);

ob0_buf1_clr <= ob0_buf1_done or ex5_ob0_buf1_flushed or ex6_ob0_buf1_flushed;

ob0_buf1_status_avail <= ob0_buf1_status_q(0) and not ex5_ob0_buf1_flushed and not ex6_ob0_buf1_flushed;

ob0_buf1_status_d(0 to 17) <= ob_status_reg_newdata(0 to 17)  when wrt_ob0_buf1_status='1' else
                              (others => '0')                 when ob0_buf1_clr='1'        else
                              ob0_buf1_status_q(0 to 17);

ob0_buf2_clr <= ob0_buf2_done or ex5_ob0_buf2_flushed or ex6_ob0_buf2_flushed;

ob0_buf2_status_avail <= ob0_buf2_status_q(0) and not ex5_ob0_buf2_flushed and not ex6_ob0_buf2_flushed;

ob0_buf2_status_d(0 to 17) <= ob_status_reg_newdata(0 to 17)  when wrt_ob0_buf2_status='1' else
                              (others => '0')                 when ob0_buf2_clr='1'        else
                              ob0_buf2_status_q(0 to 17);

ob0_buf3_clr <= ob0_buf3_done or ex5_ob0_buf3_flushed or ex6_ob0_buf3_flushed;

ob0_buf3_status_avail <= ob0_buf3_status_q(0) and not ex5_ob0_buf3_flushed and not ex6_ob0_buf3_flushed;

ob0_buf3_status_d(0 to 17) <= ob_status_reg_newdata(0 to 17)  when wrt_ob0_buf3_status='1' else
                              (others => '0')                 when ob0_buf3_clr='1'        else
                              ob0_buf3_status_q(0 to 17);

ob1_buf0_clr <= ob1_buf0_done or ex5_ob1_buf0_flushed or ex6_ob1_buf0_flushed;

ob1_buf0_status_avail <= ob1_buf0_status_q(0) and not ex5_ob1_buf0_flushed and not ex6_ob1_buf0_flushed;

ob1_buf0_status_d(0 to 17) <= ob_status_reg_newdata(0 to 17)  when wrt_ob1_buf0_status='1' else
                              (others => '0')                 when ob1_buf0_clr='1'        else
                              ob1_buf0_status_q(0 to 17);

ob1_buf1_clr <= ob1_buf1_done or ex5_ob1_buf1_flushed or ex6_ob1_buf1_flushed;

ob1_buf1_status_avail <= ob1_buf1_status_q(0) and not ex5_ob1_buf1_flushed and not ex6_ob1_buf1_flushed;

ob1_buf1_status_d(0 to 17) <= ob_status_reg_newdata(0 to 17)  when wrt_ob1_buf1_status='1' else
                              (others => '0')                 when ob1_buf1_clr='1'        else
                              ob1_buf1_status_q(0 to 17);

ob1_buf2_clr <= ob1_buf2_done or ex5_ob1_buf2_flushed or ex6_ob1_buf2_flushed;

ob1_buf2_status_avail <= ob1_buf2_status_q(0) and not ex5_ob1_buf2_flushed and not ex6_ob1_buf2_flushed;

ob1_buf2_status_d(0 to 17) <= ob_status_reg_newdata(0 to 17)  when wrt_ob1_buf2_status='1' else
                              (others => '0')                 when ob1_buf2_clr='1'        else
                              ob1_buf2_status_q(0 to 17);

ob1_buf3_clr <= ob1_buf3_done or ex5_ob1_buf3_flushed or ex6_ob1_buf3_flushed;

ob1_buf3_status_avail <= ob1_buf3_status_q(0) and not ex5_ob1_buf3_flushed and not ex6_ob1_buf3_flushed;

ob1_buf3_status_d(0 to 17) <= ob_status_reg_newdata(0 to 17)  when wrt_ob1_buf3_status='1' else
                              (others => '0')                 when ob1_buf3_clr='1'        else
                              ob1_buf3_status_q(0 to 17);

ob2_buf0_clr <= ob2_buf0_done or ex5_ob2_buf0_flushed or ex6_ob2_buf0_flushed;

ob2_buf0_status_avail <= ob2_buf0_status_q(0) and not ex5_ob2_buf0_flushed and not ex6_ob2_buf0_flushed;

ob2_buf0_status_d(0 to 17) <= ob_status_reg_newdata(0 to 17)  when wrt_ob2_buf0_status='1' else
                              (others => '0')                 when ob2_buf0_clr='1'        else
                              ob2_buf0_status_q(0 to 17);

ob2_buf1_clr <= ob2_buf1_done or ex5_ob2_buf1_flushed or ex6_ob2_buf1_flushed;

ob2_buf1_status_avail <= ob2_buf1_status_q(0) and not ex5_ob2_buf1_flushed and not ex6_ob2_buf1_flushed;

ob2_buf1_status_d(0 to 17) <= ob_status_reg_newdata(0 to 17)  when wrt_ob2_buf1_status='1' else
                              (others => '0')                 when ob2_buf1_clr='1'        else
                              ob2_buf1_status_q(0 to 17);

ob2_buf2_clr <= ob2_buf2_done or ex5_ob2_buf2_flushed or ex6_ob2_buf2_flushed;

ob2_buf2_status_avail <= ob2_buf2_status_q(0) and not ex5_ob2_buf2_flushed and not ex6_ob2_buf2_flushed;

ob2_buf2_status_d(0 to 17) <= ob_status_reg_newdata(0 to 17)  when wrt_ob2_buf2_status='1' else
                              (others => '0')                 when ob2_buf2_clr='1'        else
                              ob2_buf2_status_q(0 to 17);

ob2_buf3_clr <= ob2_buf3_done or ex5_ob2_buf3_flushed or ex6_ob2_buf3_flushed;

ob2_buf3_status_avail <= ob2_buf3_status_q(0) and not ex5_ob2_buf3_flushed and not ex6_ob2_buf3_flushed;

ob2_buf3_status_d(0 to 17) <= ob_status_reg_newdata(0 to 17)  when wrt_ob2_buf3_status='1' else
                              (others => '0')                 when ob2_buf3_clr='1'        else
                              ob2_buf3_status_q(0 to 17);

ob3_buf0_clr <= ob3_buf0_done or ex5_ob3_buf0_flushed or ex6_ob3_buf0_flushed;

ob3_buf0_status_avail <= ob3_buf0_status_q(0) and not ex5_ob3_buf0_flushed and not ex6_ob3_buf0_flushed;

ob3_buf0_status_d(0 to 17) <= ob_status_reg_newdata(0 to 17)  when wrt_ob3_buf0_status='1' else
                              (others => '0')                 when ob3_buf0_clr='1'        else
                              ob3_buf0_status_q(0 to 17);

ob3_buf1_clr <= ob3_buf1_done or ex5_ob3_buf1_flushed or ex6_ob3_buf1_flushed;

ob3_buf1_status_avail <= ob3_buf1_status_q(0) and not ex5_ob3_buf1_flushed and not ex6_ob3_buf1_flushed;

ob3_buf1_status_d(0 to 17) <= ob_status_reg_newdata(0 to 17)  when wrt_ob3_buf1_status='1' else
                              (others => '0')                 when ob3_buf1_clr='1'        else
                              ob3_buf1_status_q(0 to 17);

ob3_buf2_clr <= ob3_buf2_done or ex5_ob3_buf2_flushed or ex6_ob3_buf2_flushed;

ob3_buf2_status_avail <= ob3_buf2_status_q(0) and not ex5_ob3_buf2_flushed and not ex6_ob3_buf2_flushed;

ob3_buf2_status_d(0 to 17) <= ob_status_reg_newdata(0 to 17)  when wrt_ob3_buf2_status='1' else
                              (others => '0')                 when ob3_buf2_clr='1'        else
                              ob3_buf2_status_q(0 to 17);

ob3_buf3_clr <= ob3_buf3_done or ex5_ob3_buf3_flushed or ex6_ob3_buf3_flushed;

ob3_buf3_status_avail <= ob3_buf3_status_q(0) and not ex5_ob3_buf3_flushed and not ex6_ob3_buf3_flushed;

ob3_buf3_status_d(0 to 17) <= ob_status_reg_newdata(0 to 17)  when wrt_ob3_buf3_status='1' else
                              (others => '0')                 when ob3_buf3_clr='1'        else
                              ob3_buf3_status_q(0 to 17);

latch_ob0_buf0_status : tri_rlmreg_p
  generic map (width => ob0_buf0_status_q'length, init => 0, expand_type => expand_type)
  port map (nclk    => nclk,
            act     => ob_rd_logic_act,
            forcee   => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(ob0_buf0_status_offset to ob0_buf0_status_offset + ob0_buf0_status_q'length-1),
            scout   => sov(ob0_buf0_status_offset to ob0_buf0_status_offset + ob0_buf0_status_q'length-1),
            din     => ob0_buf0_status_d,
            dout    => ob0_buf0_status_q );


latch_ob0_buf1_status : tri_rlmreg_p
  generic map (width => ob0_buf1_status_q'length, init => 0, expand_type => expand_type)
  port map (nclk    => nclk,
            act     => ob_rd_logic_act,
            forcee   => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(ob0_buf1_status_offset to ob0_buf1_status_offset + ob0_buf1_status_q'length-1),
            scout   => sov(ob0_buf1_status_offset to ob0_buf1_status_offset + ob0_buf1_status_q'length-1),
            din     => ob0_buf1_status_d,
            dout    => ob0_buf1_status_q );

latch_ob0_buf2_status : tri_rlmreg_p
  generic map (width => ob0_buf2_status_q'length, init => 0, expand_type => expand_type)
  port map (nclk    => nclk,
            act     => ob_rd_logic_act,
            forcee   => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(ob0_buf2_status_offset to ob0_buf2_status_offset + ob0_buf2_status_q'length-1),
            scout   => sov(ob0_buf2_status_offset to ob0_buf2_status_offset + ob0_buf2_status_q'length-1),
            din     => ob0_buf2_status_d,
            dout    => ob0_buf2_status_q );

latch_ob0_buf3_status : tri_rlmreg_p
  generic map (width => ob0_buf3_status_q'length, init => 0, expand_type => expand_type)
  port map (nclk    => nclk,
            act     => ob_rd_logic_act,
            forcee   => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(ob0_buf3_status_offset to ob0_buf3_status_offset + ob0_buf3_status_q'length-1),
            scout   => sov(ob0_buf3_status_offset to ob0_buf3_status_offset + ob0_buf3_status_q'length-1),
            din     => ob0_buf3_status_d,
            dout    => ob0_buf3_status_q );

latch_ob1_buf0_status : tri_rlmreg_p
  generic map (width => ob1_buf0_status_q'length, init => 0, expand_type => expand_type)
  port map (nclk    => nclk,
            act     => ob_rd_logic_act,
            forcee   => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(ob1_buf0_status_offset to ob1_buf0_status_offset + ob1_buf0_status_q'length-1),
            scout   => sov(ob1_buf0_status_offset to ob1_buf0_status_offset + ob1_buf0_status_q'length-1),
            din     => ob1_buf0_status_d,
            dout    => ob1_buf0_status_q );


latch_ob1_buf1_status : tri_rlmreg_p
  generic map (width => ob1_buf1_status_q'length, init => 0, expand_type => expand_type)
  port map (nclk    => nclk,
            act     => ob_rd_logic_act,
            forcee   => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(ob1_buf1_status_offset to ob1_buf1_status_offset + ob1_buf1_status_q'length-1),
            scout   => sov(ob1_buf1_status_offset to ob1_buf1_status_offset + ob1_buf1_status_q'length-1),
            din     => ob1_buf1_status_d,
            dout    => ob1_buf1_status_q );

latch_ob1_buf2_status : tri_rlmreg_p
  generic map (width => ob1_buf2_status_q'length, init => 0, expand_type => expand_type)
  port map (nclk    => nclk,
            act     => ob_rd_logic_act,
            forcee   => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(ob1_buf2_status_offset to ob1_buf2_status_offset + ob1_buf2_status_q'length-1),
            scout   => sov(ob1_buf2_status_offset to ob1_buf2_status_offset + ob1_buf2_status_q'length-1),
            din     => ob1_buf2_status_d,
            dout    => ob1_buf2_status_q );

latch_ob1_buf3_status : tri_rlmreg_p
  generic map (width => ob1_buf3_status_q'length, init => 0, expand_type => expand_type)
  port map (nclk    => nclk,
            act     => ob_rd_logic_act,
            forcee   => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(ob1_buf3_status_offset to ob1_buf3_status_offset + ob1_buf3_status_q'length-1),
            scout   => sov(ob1_buf3_status_offset to ob1_buf3_status_offset + ob1_buf3_status_q'length-1),
            din     => ob1_buf3_status_d,
            dout    => ob1_buf3_status_q );

latch_ob2_buf0_status : tri_rlmreg_p
  generic map (width => ob2_buf0_status_q'length, init => 0, expand_type => expand_type)
  port map (nclk    => nclk,
            act     => ob_rd_logic_act,
            forcee   => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(ob2_buf0_status_offset to ob2_buf0_status_offset + ob2_buf0_status_q'length-1),
            scout   => sov(ob2_buf0_status_offset to ob2_buf0_status_offset + ob2_buf0_status_q'length-1),
            din     => ob2_buf0_status_d,
            dout    => ob2_buf0_status_q );


latch_ob2_buf1_status : tri_rlmreg_p
  generic map (width => ob2_buf1_status_q'length, init => 0, expand_type => expand_type)
  port map (nclk    => nclk,
            act     => ob_rd_logic_act,
            forcee   => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(ob2_buf1_status_offset to ob2_buf1_status_offset + ob2_buf1_status_q'length-1),
            scout   => sov(ob2_buf1_status_offset to ob2_buf1_status_offset + ob2_buf1_status_q'length-1),
            din     => ob2_buf1_status_d,
            dout    => ob2_buf1_status_q );

latch_ob2_buf2_status : tri_rlmreg_p
  generic map (width => ob2_buf2_status_q'length, init => 0, expand_type => expand_type)
  port map (nclk    => nclk,
            act     => ob_rd_logic_act,
            forcee   => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(ob2_buf2_status_offset to ob2_buf2_status_offset + ob2_buf2_status_q'length-1),
            scout   => sov(ob2_buf2_status_offset to ob2_buf2_status_offset + ob2_buf2_status_q'length-1),
            din     => ob2_buf2_status_d,
            dout    => ob2_buf2_status_q );

latch_ob2_buf3_status : tri_rlmreg_p
  generic map (width => ob2_buf3_status_q'length, init => 0, expand_type => expand_type)
  port map (nclk    => nclk,
            act     => ob_rd_logic_act,
            forcee   => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(ob2_buf3_status_offset to ob2_buf3_status_offset + ob2_buf3_status_q'length-1),
            scout   => sov(ob2_buf3_status_offset to ob2_buf3_status_offset + ob2_buf3_status_q'length-1),
            din     => ob2_buf3_status_d,
            dout    => ob2_buf3_status_q );

latch_ob3_buf0_status : tri_rlmreg_p
  generic map (width => ob3_buf0_status_q'length, init => 0, expand_type => expand_type)
  port map (nclk    => nclk,
            act     => ob_rd_logic_act,
            forcee   => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(ob3_buf0_status_offset to ob3_buf0_status_offset + ob3_buf0_status_q'length-1),
            scout   => sov(ob3_buf0_status_offset to ob3_buf0_status_offset + ob3_buf0_status_q'length-1),
            din     => ob3_buf0_status_d,
            dout    => ob3_buf0_status_q );


latch_ob3_buf1_status : tri_rlmreg_p
  generic map (width => ob3_buf1_status_q'length, init => 0, expand_type => expand_type)
  port map (nclk    => nclk,
            act     => ob_rd_logic_act,
            forcee   => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(ob3_buf1_status_offset to ob3_buf1_status_offset + ob3_buf1_status_q'length-1),
            scout   => sov(ob3_buf1_status_offset to ob3_buf1_status_offset + ob3_buf1_status_q'length-1),
            din     => ob3_buf1_status_d,
            dout    => ob3_buf1_status_q );

latch_ob3_buf2_status : tri_rlmreg_p
  generic map (width => ob3_buf2_status_q'length, init => 0, expand_type => expand_type)
  port map (nclk    => nclk,
            act     => ob_rd_logic_act,
            forcee   => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(ob3_buf2_status_offset to ob3_buf2_status_offset + ob3_buf2_status_q'length-1),
            scout   => sov(ob3_buf2_status_offset to ob3_buf2_status_offset + ob3_buf2_status_q'length-1),
            din     => ob3_buf2_status_d,
            dout    => ob3_buf2_status_q );

latch_ob3_buf3_status : tri_rlmreg_p
  generic map (width => ob3_buf3_status_q'length, init => 0, expand_type => expand_type)
  port map (nclk    => nclk,
            act     => ob_rd_logic_act,
            forcee   => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(ob3_buf3_status_offset to ob3_buf3_status_offset + ob3_buf3_status_q'length-1),
            scout   => sov(ob3_buf3_status_offset to ob3_buf3_status_offset + ob3_buf3_status_q'length-1),
            din     => ob3_buf3_status_d,
            dout    => ob3_buf3_status_q );

ob_buf_status_avail_d <= ob0_buf0_status_avail & ob0_buf1_status_avail & ob0_buf2_status_avail & ob0_buf3_status_avail &
                         ob1_buf0_status_avail & ob1_buf1_status_avail & ob1_buf2_status_avail & ob1_buf3_status_avail &
                         ob2_buf0_status_avail & ob2_buf1_status_avail & ob2_buf2_status_avail & ob2_buf3_status_avail &
                         ob3_buf0_status_avail & ob3_buf1_status_avail & ob3_buf2_status_avail & ob3_buf3_status_avail;

latch_ob_buf_status_avail : tri_rlmreg_p
  generic map (width => ob_buf_status_avail_q'length, init => 0, expand_type => expand_type)
  port map (nclk    => nclk,
            act     => ob_rd_logic_act,
            forcee   => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(ob_buf_status_avail_offset to ob_buf_status_avail_offset + ob_buf_status_avail_q'length-1),
            scout   => sov(ob_buf_status_avail_offset to ob_buf_status_avail_offset + ob_buf_status_avail_q'length-1),
            din     => ob_buf_status_avail_d,
            dout    => ob_buf_status_avail_q );

ob0_buf0_status_val <= ob_buf_status_avail_q(0) and not ex6_ob0_buf0_flushed;  -- buffer ready to go out to node if not flushed
ob0_buf1_status_val <= ob_buf_status_avail_q(1) and not ex6_ob0_buf1_flushed;
ob0_buf2_status_val <= ob_buf_status_avail_q(2) and not ex6_ob0_buf2_flushed;
ob0_buf3_status_val <= ob_buf_status_avail_q(3) and not ex6_ob0_buf3_flushed;
ob1_buf0_status_val <= ob_buf_status_avail_q(4) and not ex6_ob1_buf0_flushed;
ob1_buf1_status_val <= ob_buf_status_avail_q(5) and not ex6_ob1_buf1_flushed;
ob1_buf2_status_val <= ob_buf_status_avail_q(6) and not ex6_ob1_buf2_flushed;
ob1_buf3_status_val <= ob_buf_status_avail_q(7) and not ex6_ob1_buf3_flushed;
ob2_buf0_status_val <= ob_buf_status_avail_q(8) and not ex6_ob2_buf0_flushed;
ob2_buf1_status_val <= ob_buf_status_avail_q(9) and not ex6_ob2_buf1_flushed;
ob2_buf2_status_val <= ob_buf_status_avail_q(10) and not ex6_ob2_buf2_flushed;
ob2_buf3_status_val <= ob_buf_status_avail_q(11) and not ex6_ob2_buf3_flushed;
ob3_buf0_status_val <= ob_buf_status_avail_q(12) and not ex6_ob3_buf0_flushed;
ob3_buf1_status_val <= ob_buf_status_avail_q(13) and not ex6_ob3_buf1_flushed;
ob3_buf2_status_val <= ob_buf_status_avail_q(14) and not ex6_ob3_buf2_flushed;
ob3_buf3_status_val <= ob_buf_status_avail_q(15) and not ex6_ob3_buf3_flushed;


--****************************************************************************
-- outbox array write address
--****************************************************************************

with ex4_ipc_thrd_q(0 to 1) select 
   ob_wrt_entry_ptr(0 to 1) <= ob0_wrt_entry_ptr_q(0 to 1)   when "00",
                               ob1_wrt_entry_ptr_q(0 to 1)   when "01", 
                               ob2_wrt_entry_ptr_q(0 to 1)   when "10", 
                               ob3_wrt_entry_ptr_q(0 to 1)   when others;

ob_wrt_addr(0 to 5) <= ex4_ipc_thrd_q(0 to 1) & ob_wrt_entry_ptr(0 to 1) & ex4_ipc_ba_q(1 to 2);

--****************************************************************************
-- outbox array write enable
--****************************************************************************
ob_buf_status_val <= (ob0_buf0_status_avail and (ex4_ipc_thrd_q="00") and ob0_wrt_entry_ptr_q="00") or
                     (ob0_buf1_status_avail and (ex4_ipc_thrd_q="00") and ob0_wrt_entry_ptr_q="01") or
                     (ob0_buf2_status_avail and (ex4_ipc_thrd_q="00") and ob0_wrt_entry_ptr_q="10") or
                     (ob0_buf3_status_avail and (ex4_ipc_thrd_q="00") and ob0_wrt_entry_ptr_q="11") or
                     (ob1_buf0_status_avail and (ex4_ipc_thrd_q="01") and ob1_wrt_entry_ptr_q="00") or
                     (ob1_buf1_status_avail and (ex4_ipc_thrd_q="01") and ob1_wrt_entry_ptr_q="01") or
                     (ob1_buf2_status_avail and (ex4_ipc_thrd_q="01") and ob1_wrt_entry_ptr_q="10") or
                     (ob1_buf3_status_avail and (ex4_ipc_thrd_q="01") and ob1_wrt_entry_ptr_q="11") or
                     (ob2_buf0_status_avail and (ex4_ipc_thrd_q="10") and ob2_wrt_entry_ptr_q="00") or
                     (ob2_buf1_status_avail and (ex4_ipc_thrd_q="10") and ob2_wrt_entry_ptr_q="01") or
                     (ob2_buf2_status_avail and (ex4_ipc_thrd_q="10") and ob2_wrt_entry_ptr_q="10") or
                     (ob2_buf3_status_avail and (ex4_ipc_thrd_q="10") and ob2_wrt_entry_ptr_q="11") or
                     (ob3_buf0_status_avail and (ex4_ipc_thrd_q="11") and ob3_wrt_entry_ptr_q="00") or
                     (ob3_buf1_status_avail and (ex4_ipc_thrd_q="11") and ob3_wrt_entry_ptr_q="01") or
                     (ob3_buf2_status_avail and (ex4_ipc_thrd_q="11") and ob3_wrt_entry_ptr_q="10") or
                     (ob3_buf3_status_avail and (ex4_ipc_thrd_q="11") and ob3_wrt_entry_ptr_q="11");

ob_wen(0) <= ex4_mtdp_val_gated and not ob_buf_status_val and ex4_ipc_ba_q(0)='0' and 
             ( (ex4_ipc_ba_q(3 to 4)="00") or (ex4_ipc_sz_q="10") or
               (ex4_ipc_ba_q(3 to 4)="11" and ex4_ipc_sz_q="01")      ); 
ob_wen(1) <= ex4_mtdp_val_gated and not ob_buf_status_val and ex4_ipc_ba_q(0)='0' and 
              ( (ex4_ipc_ba_q(3 to 4)="01") or (ex4_ipc_sz_q="10") or
                (ex4_ipc_ba_q(3 to 4)="00" and ex4_ipc_sz_q="01")    );
ob_wen(2) <= ex4_mtdp_val_gated and not ob_buf_status_val and ex4_ipc_ba_q(0)='0' and
             ( (ex4_ipc_ba_q(3 to 4)="10") or (ex4_ipc_sz_q="10") or
               (ex4_ipc_ba_q(3 to 4)="01" and ex4_ipc_sz_q="01")    );
ob_wen(3) <= ex4_mtdp_val_gated and not ob_buf_status_val and ex4_ipc_ba_q(0)='0' and
             ( (ex4_ipc_ba_q(3 to 4)="11") or (ex4_ipc_sz_q="10") or 
               (ex4_ipc_ba_q(3 to 4)="10" and ex4_ipc_sz_q="01")    );


--****************************************************************************
-- determine pass/fail CR status of mtdp
--****************************************************************************

ex3_ob_buf_status_val <= (ob0_buf0_status_avail and (ex3_ipc_thrd_q="00") and ob0_wrt_entry_ptr_d="00") or
                         (ob0_buf1_status_avail and (ex3_ipc_thrd_q="00") and ob0_wrt_entry_ptr_d="01") or
                         (ob0_buf2_status_avail and (ex3_ipc_thrd_q="00") and ob0_wrt_entry_ptr_d="10") or
                         (ob0_buf3_status_avail and (ex3_ipc_thrd_q="00") and ob0_wrt_entry_ptr_d="11") or
                         (ob1_buf0_status_avail and (ex3_ipc_thrd_q="01") and ob1_wrt_entry_ptr_d="00") or
                         (ob1_buf1_status_avail and (ex3_ipc_thrd_q="01") and ob1_wrt_entry_ptr_d="01") or
                         (ob1_buf2_status_avail and (ex3_ipc_thrd_q="01") and ob1_wrt_entry_ptr_d="10") or
                         (ob1_buf3_status_avail and (ex3_ipc_thrd_q="01") and ob1_wrt_entry_ptr_d="11") or
                         (ob2_buf0_status_avail and (ex3_ipc_thrd_q="10") and ob2_wrt_entry_ptr_d="00") or
                         (ob2_buf1_status_avail and (ex3_ipc_thrd_q="10") and ob2_wrt_entry_ptr_d="01") or
                         (ob2_buf2_status_avail and (ex3_ipc_thrd_q="10") and ob2_wrt_entry_ptr_d="10") or
                         (ob2_buf3_status_avail and (ex3_ipc_thrd_q="10") and ob2_wrt_entry_ptr_d="11") or
                         (ob3_buf0_status_avail and (ex3_ipc_thrd_q="11") and ob3_wrt_entry_ptr_d="00") or
                         (ob3_buf1_status_avail and (ex3_ipc_thrd_q="11") and ob3_wrt_entry_ptr_d="01") or
                         (ob3_buf2_status_avail and (ex3_ipc_thrd_q="11") and ob3_wrt_entry_ptr_d="10") or
                         (ob3_buf3_status_avail and (ex3_ipc_thrd_q="11") and ob3_wrt_entry_ptr_d="11");


ex3_mtdp_cr_status <= ex3_mtdp_val and (not ex3_ob_buf_status_val or (ex3_ipc_ba_q = "10000"));   -- 1=mtdp passed, 0=mtdp failed

latch_ex4_mtdp_cr_status : tri_rlmreg_p
  generic map (width => 1, init => 0, expand_type => expand_type)
  port map (nclk    => nclk,
            act     => mtdp_ex3_to_7_val,
            forcee   => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(ex4_mtdp_cr_status_offset to ex4_mtdp_cr_status_offset),
            scout   => sov(ex4_mtdp_cr_status_offset to ex4_mtdp_cr_status_offset),
            din(0)  => ex3_mtdp_cr_status,
            dout(0) => ex4_mtdp_cr_status );

bx_xu_ex4_mtdp_cr_status <= ex4_mtdp_cr_status;


-- latch data for ecc gen before writing array
latch_ob_wrt_data : tri_rlmreg_p
  generic map (width => ob_ary_wrt_data_l2'length, init => 0, expand_type => expand_type)  
  port map (nclk    => nclk,
            act     => ex4_mtdp_val_q,
            forcee   => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(ob_wrt_data_offset to ob_wrt_data_offset + ob_ary_wrt_data_l2'length-1),
            scout   => sov(ob_wrt_data_offset to ob_wrt_data_offset + ob_ary_wrt_data_l2'length-1),
            din     => xu_bx_ex4_256st_data,
            dout    => ob_ary_wrt_data_l2 );

latch_ob_ary_wen : tri_rlmreg_p
  generic map (width => ob_ary_wen_l2'length, init => 0, expand_type => expand_type)  
  port map (nclk    => nclk,
            act     => mtdp_ex3_to_7_val,
            forcee   => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(ob_ary_wen_offset to ob_ary_wen_offset + ob_ary_wen_l2'length-1),
            scout   => sov(ob_ary_wen_offset to ob_ary_wen_offset + ob_ary_wen_l2'length-1),
            din     => ob_wen,
            dout    => ob_ary_wen_l2 );

latch_ob_ary_wrt_addr : tri_rlmreg_p
  generic map (width => ob_ary_wrt_addr_l2'length, init => 0, expand_type => expand_type)  
  port map (nclk    => nclk,
            act     => ex4_mtdp_val_q,
            forcee   => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(ob_ary_wrt_addr_offset to ob_ary_wrt_addr_offset + ob_ary_wrt_addr_l2'length-1),
            scout   => sov(ob_ary_wrt_addr_offset to ob_ary_wrt_addr_offset + ob_ary_wrt_addr_l2'length-1),
            din     => ob_wrt_addr,
            dout    => ob_ary_wrt_addr_l2 );

-- setting check bits to 1s causes the ecc bits to be inverted which will cause the downstream
-- ecccgen to produce an inverted syn which is what eccchk wants.
ob_di_eccgen0:  entity work.xuq_eccgen(xuq_eccgen)
   generic map ( regsize => 32 )
   port map(din(0 to 31)  => ob_ary_wrt_data_l2(0 to 31),
            din(32 to 38) => "1111111",                      
            syn           => ob_datain_ecc0  );

ob_di_eccgen1:  entity work.xuq_eccgen(xuq_eccgen)
   generic map ( regsize => 32 )
   port map(din(0 to 31)  => ob_ary_wrt_data_l2(32 to 63),
            din(32 to 38) => "1111111",
            syn           => ob_datain_ecc1  );

ob_di_eccgen2:  entity work.xuq_eccgen(xuq_eccgen)
   generic map ( regsize => 32 )
   port map(din(0 to 31)  => ob_ary_wrt_data_l2(64 to 95),
            din(32 to 38) => "1111111",
            syn           => ob_datain_ecc2  );

ob_di_eccgen3:  entity work.xuq_eccgen(xuq_eccgen)
   generic map ( regsize => 32 )
   port map(din(0 to 31)  => ob_ary_wrt_data_l2(96 to 127),
            din(32 to 38) => "1111111",
            syn           => ob_datain_ecc3  );


--****************************************************************************
-- outbox error inject
--****************************************************************************

latch_ob_err_inj : tri_rlmreg_p
  generic map (width => 1, init => 0, expand_type => expand_type)
  port map (nclk    => nclk,
            act     => '1',
            forcee   => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(ob_err_inj_offset to ob_err_inj_offset),
            scout   => sov(ob_err_inj_offset to ob_err_inj_offset),
            din(0)  => pc_bx_inj_outbox_ecc,
            dout(0) => ob_err_inj_q );

ob_ary_wrt_data_0 <= ob_ary_wrt_data_l2(0) xor ob_err_inj_q;

--****************************************************************************
-- outbox array
--****************************************************************************

ob_array:  entity tri.tri_64x42_4w_1r1w(tri_64x42_4w_1r1w)
  generic map ( expand_type => expand_type )
  port map(
-- functional ports
    wr_way               => ob_ary_wen_l2(0 to 3),
    wr_adr               => ob_ary_wrt_addr_l2(0 to 5),

    di(0)                => ob_ary_wrt_data_0,
    di(1 to 31)          => ob_ary_wrt_data_l2(1 to 31),
    di(32 to 38)         => ob_datain_ecc0(0 to 6),
    di(39 to 41)         => "000",

    di(42 to 73)         => ob_ary_wrt_data_l2(32 to 63),
    di(74 to 80)         => ob_datain_ecc1(0 to 6),
    di(81 to 83)         => "000",

    di(84 to 115)        => ob_ary_wrt_data_l2(64 to 95),
    di(116 to 122)       => ob_datain_ecc2(0 to 6),
    di(123 to 125)       => "000",

    di(126 to 157)       => ob_ary_wrt_data_l2(96 to 127),
    di(158 to 164)       => ob_datain_ecc3(0 to 6),
    di(165 to 167)       => "000",

    rd0_adr              => ob_ary_rd_addr(0 to 5),

    do0(0 to 31)         => ob_rd_data(0 to 31),
    do0(32 to 38)        => ob_rd_data_ecc0(0 to 6),
    do0(39 to 41)        => unused(0 to 2),

    do0(42 to 73)        => ob_rd_data(32 to 63),
    do0(74 to 80)        => ob_rd_data_ecc1(0 to 6),
    do0(81 to 83)        => unused(3 to 5),

    do0(84 to 115)       => ob_rd_data(64 to 95),
    do0(116 to 122)      => ob_rd_data_ecc2(0 to 6),
    do0(123 to 125)      => unused(6 to 8),

    do0(126 to 157)      => ob_rd_data(96 to 127),
    do0(158 to 164)      => ob_rd_data_ecc3(0 to 6),
    do0(165 to 167)      => unused(9 to 11),

   -- ABIST
   abist_di              => abist_di_0,
   abist_bw_odd          => abist_g8t_bw_1,
   abist_bw_even         => abist_g8t_bw_0,
   abist_wr_adr          => abist_waddr_0(4 to 9),
   wr_abst_act           => abist_g8t_wenb,
   abist_rd0_adr         => abist_raddr_0(4 to 9),
   rd0_abst_act          => abist_g8t1p_renb_0,
   tc_lbist_ary_wrt_thru_dc => an_ac_lbist_ary_wrt_thru_dc,
   abist_ena_1           => pc_bx_abist_ena_dc,
   abist_g8t_rd0_comp_ena => abist_wl64_comp_ena,
   abist_raw_dc_b        => pc_bx_abist_raw_dc_b,
   obs0_abist_cmp        => abist_g8t_dcomp,

   -- BOLT-ON
   lcb_bolt_sl_thold_0   => bolt_sl_thold_0,
   pc_bo_enable_2        => bolt_enable_2,
   pc_bo_reset           => pc_bx_bo_reset,
   pc_bo_unload          => pc_bx_bo_unload,
   pc_bo_repair          => pc_bx_bo_repair,
   pc_bo_shdata          => pc_bx_bo_shdata,
   pc_bo_select          => pc_bx_bo_select(0 to 1),
   bo_pc_failout         => bx_pc_bo_fail(0 to 1),
   bo_pc_diagloop        => bx_pc_bo_diagout(0 to 1),
   tri_lcb_mpw1_dc_b     => mpw1_dc_b,
   tri_lcb_mpw2_dc_b     => mpw2_dc_b,
   tri_lcb_delay_lclkr_dc => delay_lclkr_dc,
   tri_lcb_clkoff_dc_b  => clkoff_dc_b,
   tri_lcb_act_dis_dc   => tidn,

-- pervasive ports
    gnd                 => gnd,
    vdd                 => vdd,
    vcs                 => vcs,
    nclk                => nclk,
    rd0_act             => ob_rd_logic_act,
    wr_act              => ex5_mtdp_val_q,
    sg_0                => sg_0,
    abst_sl_thold_0     => abst_sl_thold_0,
    ary_nsl_thold_0     => ary_nsl_thold_0,
    time_sl_thold_0     => time_sl_thold_0,
    repr_sl_thold_0     => repr_sl_thold_0,
    scan_dis_dc_b       => an_ac_scan_dis_dc_b,
    scan_diag_dc        => an_ac_scan_diag_dc,
    ccflush_dc          => pc_bx_ccflush_dc,

    ary0_clkoff_dc_b    => ary0_clkoff_dc_b,
    ary0_d_mode_dc      => ary0_d_mode_dc,
    ary0_mpw1_dc_b      => ary0_mpw1_dc_b_v,
    ary0_mpw2_dc_b      => ary0_mpw2_dc_b,
    ary0_delay_lclkr_dc => ary0_delay_lclkr_dc_v,

    ary1_clkoff_dc_b    => ary1_clkoff_dc_b,
    ary1_d_mode_dc      => ary1_d_mode_dc,
    ary1_mpw1_dc_b      => ary1_mpw1_dc_b_v,
    ary1_mpw2_dc_b      => ary1_mpw2_dc_b,
    ary1_delay_lclkr_dc => ary1_delay_lclkr_dc_v,

    abst_scan_in        => abst_scan_in,
    time_scan_in        => time_scan_in_q,
    repr_scan_in        => repr_scan_in_q,
    abst_scan_out       => ob_abst_scan_out,
    time_scan_out       => ob_time_scan_out,
    repr_scan_out       => ob_repr_scan_out
);


--****************************************************************************
-- Latch output of array
--****************************************************************************

latch_ob_rd_data1 : tri_rlmreg_p
  generic map (width => ob_rd_data1_l2'length, init => 0, expand_type => expand_type)  
  port map (nclk    => nclk,
            act     => ob_rd_logic_act,
            forcee   => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(ob_rd_data1_offset to ob_rd_data1_offset + ob_rd_data1_l2'length-1),
            scout   => sov(ob_rd_data1_offset to ob_rd_data1_offset + ob_rd_data1_l2'length-1),
            din     => ob_rd_data(0 to 127),
            dout    => ob_rd_data1_l2 );

latch_ob_rd_data_ecc0 : tri_rlmreg_p
  generic map (width => ob_rd_data_ecc0'length, init => 0, expand_type => expand_type)  
  port map (nclk    => nclk,
            act     => ob_rd_logic_act,
            forcee   => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(ob_rd_data_ecc0_offset to ob_rd_data_ecc0_offset + ob_rd_data_ecc0'length-1),
            scout   => sov(ob_rd_data_ecc0_offset to ob_rd_data_ecc0_offset + ob_rd_data_ecc0'length-1),
            din     => ob_rd_data_ecc0(0 to 6),
            dout    => ob_rd_data_ecc0_l2 );

latch_ob_rd_data_ecc1 : tri_rlmreg_p
  generic map (width => ob_rd_data_ecc1'length, init => 0, expand_type => expand_type)  
  port map (nclk    => nclk,
            act     => ob_rd_logic_act,
            forcee   => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(ob_rd_data_ecc1_offset to ob_rd_data_ecc1_offset + ob_rd_data_ecc1'length-1),
            scout   => sov(ob_rd_data_ecc1_offset to ob_rd_data_ecc1_offset + ob_rd_data_ecc1'length-1),
            din     => ob_rd_data_ecc1(0 to 6),
            dout    => ob_rd_data_ecc1_l2 );

latch_ob_rd_data_ecc2 : tri_rlmreg_p
  generic map (width => ob_rd_data_ecc2'length, init => 0, expand_type => expand_type)  
  port map (nclk    => nclk,
            act     => ob_rd_logic_act,
            forcee   => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(ob_rd_data_ecc2_offset to ob_rd_data_ecc2_offset + ob_rd_data_ecc2'length-1),
            scout   => sov(ob_rd_data_ecc2_offset to ob_rd_data_ecc2_offset + ob_rd_data_ecc2'length-1),
            din     => ob_rd_data_ecc2(0 to 6),
            dout    => ob_rd_data_ecc2_l2 );

latch_ob_rd_data_ecc3 : tri_rlmreg_p
  generic map (width => ob_rd_data_ecc3'length, init => 0, expand_type => expand_type)  
  port map (nclk    => nclk,
            act     => ob_rd_logic_act,
            forcee   => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(ob_rd_data_ecc3_offset to ob_rd_data_ecc3_offset + ob_rd_data_ecc3'length-1),
            scout   => sov(ob_rd_data_ecc3_offset to ob_rd_data_ecc3_offset + ob_rd_data_ecc3'length-1),
            din     => ob_rd_data_ecc3(0 to 6),
            dout    => ob_rd_data_ecc3_l2 );

--****************************************************************************
-- Check OB data for ECC error
--****************************************************************************



ob_do_eccgen0:  entity work.xuq_eccgen(xuq_eccgen)
   generic map ( regsize => 32 )
   port map(din(0 to 31)  => ob_rd_data1_l2(0 to 31),
            din(32 to 38) => ob_rd_data_ecc0_l2,
            syn           => ob_rd_data_nsyn0  );

ob_do_eccgen1:  entity work.xuq_eccgen(xuq_eccgen)
   generic map ( regsize => 32 )
   port map(din(0 to 31)  => ob_rd_data1_l2(32 to 63),
            din(32 to 38) => ob_rd_data_ecc1_l2,
            syn           => ob_rd_data_nsyn1  );

ob_do_eccgen2:  entity work.xuq_eccgen(xuq_eccgen)
   generic map ( regsize => 32 )
   port map(din(0 to 31)  => ob_rd_data1_l2(64 to 95),
            din(32 to 38) => ob_rd_data_ecc2_l2,
            syn           => ob_rd_data_nsyn2  );

ob_do_eccgen3:  entity work.xuq_eccgen(xuq_eccgen)
   generic map ( regsize => 32 )
   port map(din(0 to 31)  => ob_rd_data1_l2(96 to 127),
            din(32 to 38) => ob_rd_data_ecc3_l2,
            syn           => ob_rd_data_nsyn3  );

ob_di_eccchk0:  entity work.xuq_eccchk(xuq_eccchk)
   generic map ( regsize => 32 )
   port map(din    => ob_rd_data1_l2(0 to 31),
            EnCorr => '1',
            NSyn   => ob_rd_data_nsyn0,
            Corrd  => ob_rd_data_cor(0 to 31),
            sbe    => ob_ary_sbe(0),
            ue     => ob_ary_ue(0)    );


ob_di_eccchk1:  entity work.xuq_eccchk(xuq_eccchk)
   generic map ( regsize => 32 )
   port map(din    => ob_rd_data1_l2(32 to 63),
            EnCorr => '1',
            NSyn   => ob_rd_data_nsyn1,
            Corrd  => ob_rd_data_cor(32 to 63),
            sbe    => ob_ary_sbe(1),
            ue     => ob_ary_ue(1)    );

ob_di_eccchk2:  entity work.xuq_eccchk(xuq_eccchk)
   generic map ( regsize => 32 )
   port map(din    => ob_rd_data1_l2(64 to 95),
            EnCorr => '1',
            NSyn   => ob_rd_data_nsyn2,
            Corrd  => ob_rd_data_cor(64 to 95),
            sbe    => ob_ary_sbe(2),
            ue     => ob_ary_ue(2)    );

ob_di_eccchk3:  entity work.xuq_eccchk(xuq_eccchk)
   generic map ( regsize => 32 )
   port map(din    => ob_rd_data1_l2(96 to 127),
            EnCorr => '1',
            NSyn   => ob_rd_data_nsyn3,
            Corrd  => ob_rd_data_cor(96 to 127),
            sbe    => ob_ary_sbe(3),
            ue     => ob_ary_ue(3)    );

latch_ob_ary_sbe : tri_rlmreg_p
  generic map (width => ob_ary_sbe_q'length, init => 0, expand_type => expand_type)
  port map (nclk    => nclk,
            act     => ob_rd_logic_act,
            forcee   => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(ob_ary_sbe_offset to ob_ary_sbe_offset + ob_ary_sbe_q'length-1),
            scout   => sov(ob_ary_sbe_offset to ob_ary_sbe_offset + ob_ary_sbe_q'length-1),
            din     => ob_ary_sbe(0 to 3),
            dout    => ob_ary_sbe_q(0 to 3) );

latch_ob_ary_ue : tri_rlmreg_p
  generic map (width => ob_ary_ue_q'length, init => 0, expand_type => expand_type)
  port map (nclk    => nclk,
            act     => ob_rd_logic_act,
            forcee   => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(ob_ary_ue_offset to ob_ary_ue_offset + ob_ary_ue_q'length-1),
            scout   => sov(ob_ary_ue_offset to ob_ary_ue_offset + ob_ary_ue_q'length-1),
            din     => ob_ary_ue(0 to 3),
            dout    => ob_ary_ue_q(0 to 3) );

ob_ary_sbe_or <= (ob_ary_sbe_q(0) or ob_ary_sbe_q(1) or ob_ary_sbe_q(2) or ob_ary_sbe_q(3)) and bx_lsu_ob_req_val_int;

ob_ary_ue_or <= (ob_ary_ue_q(0) or ob_ary_ue_q(1) or ob_ary_ue_q(2) or ob_ary_ue_q(3)) and bx_lsu_ob_req_val_int;




latch_ob_rd_data_cor : tri_rlmreg_p
  generic map (width => ob_rd_data_cor'length, init => 0, expand_type => expand_type)  
  port map (nclk    => nclk,
            act     => ob_rd_logic_act,
            forcee   => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(ob_rd_data_cor_offset to ob_rd_data_cor_offset + ob_rd_data_cor'length-1),
            scout   => sov(ob_rd_data_cor_offset to ob_rd_data_cor_offset + ob_rd_data_cor'length-1),
            din     => ob_rd_data_cor(0 to 127),
            dout    => ob_rd_data_cor_l2 );

-- latch parity error and send to pervasive


latch_outbox_ecc_err : tri_rlmreg_p
  generic map (width =>  1, init => 0, expand_type => expand_type)  
  port map (nclk    => nclk,
            act     => ob_rd_logic_act,
            forcee   => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(outbox_ecc_err_offset to outbox_ecc_err_offset),
            scout   => sov(outbox_ecc_err_offset to outbox_ecc_err_offset),
            din(0)  => ob_ary_sbe_or,
            dout(0) => outbox_ecc_err_q );

latch_outbox_ue : tri_rlmreg_p
  generic map (width =>  1, init => 0, expand_type => expand_type)  
  port map (nclk    => nclk,
            act     => ob_rd_logic_act,
            forcee   => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(outbox_ue_offset to outbox_ue_offset),
            scout   => sov(outbox_ue_offset to outbox_ue_offset),
            din(0)  => ob_ary_ue_or,
            dout(0) => outbox_ue_q );

   outbox_err_rpt : entity tri.tri_direct_err_rpt
     generic map
      (  width          => 2
       , expand_type    => expand_type
      ) 
     port map
      ( vd    => vdd
      , gd    => gnd
      , err_in(0)       => outbox_ecc_err_q
      , err_in(1)       => outbox_ue_q
      , err_out(0)      => bx_pc_err_outbox_ecc
      , err_out(1)      => bx_pc_err_outbox_ue
     );

--****************************************************************************
-- increment outbox buffer read pointer when message buffer complete reg valid is reset
-- there is one buffer pointer per thread
--****************************************************************************

ob0_rd_entry_ptr_d <= std_ulogic_vector(unsigned(ob0_rd_entry_ptr_q) + 1)  when ob0_buf_done='1'      else
                      ob0_rd_entry_ptr_q(0 to 1);

ob1_rd_entry_ptr_d <= std_ulogic_vector(unsigned(ob1_rd_entry_ptr_q) + 1)  when ob1_buf_done='1'      else
                      ob1_rd_entry_ptr_q(0 to 1);

ob2_rd_entry_ptr_d <= std_ulogic_vector(unsigned(ob2_rd_entry_ptr_q) + 1)  when ob2_buf_done='1'      else
                      ob2_rd_entry_ptr_q(0 to 1);

ob3_rd_entry_ptr_d <= std_ulogic_vector(unsigned(ob3_rd_entry_ptr_q) + 1)  when ob3_buf_done='1'      else
                      ob3_rd_entry_ptr_q(0 to 1);

latch_ob0_rd_entry_ptr : tri_rlmreg_p
  generic map (width => ob0_rd_entry_ptr_q'length, init => 0, expand_type => expand_type)
  port map (nclk    => nclk,
            act     => ob_rd_logic_act,
            forcee   => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(ob0_rd_entry_ptr_offset to ob0_rd_entry_ptr_offset + ob0_rd_entry_ptr_q'length-1),
            scout   => sov(ob0_rd_entry_ptr_offset to ob0_rd_entry_ptr_offset + ob0_rd_entry_ptr_q'length-1),
            din     => ob0_rd_entry_ptr_d(0 to 1),
            dout    => ob0_rd_entry_ptr_q(0 to 1) );

latch_ob1_rd_entry_ptr : tri_rlmreg_p
  generic map (width => ob1_rd_entry_ptr_q'length, init => 0, expand_type => expand_type)
  port map (nclk    => nclk,
            act     => ob_rd_logic_act,
            forcee   => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(ob1_rd_entry_ptr_offset to ob1_rd_entry_ptr_offset + ob1_rd_entry_ptr_q'length-1),
            scout   => sov(ob1_rd_entry_ptr_offset to ob1_rd_entry_ptr_offset + ob1_rd_entry_ptr_q'length-1),
            din     => ob1_rd_entry_ptr_d(0 to 1),
            dout    => ob1_rd_entry_ptr_q(0 to 1) );

latch_ob2_rd_entry_ptr : tri_rlmreg_p
  generic map (width => ob2_rd_entry_ptr_q'length, init => 0, expand_type => expand_type)
  port map (nclk    => nclk,
            act     => ob_rd_logic_act,
            forcee   => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(ob2_rd_entry_ptr_offset to ob2_rd_entry_ptr_offset + ob2_rd_entry_ptr_q'length-1),
            scout   => sov(ob2_rd_entry_ptr_offset to ob2_rd_entry_ptr_offset + ob2_rd_entry_ptr_q'length-1),
            din     => ob2_rd_entry_ptr_d(0 to 1),
            dout    => ob2_rd_entry_ptr_q(0 to 1) );

latch_ob3_rd_entry_ptr : tri_rlmreg_p
  generic map (width => ob3_rd_entry_ptr_q'length, init => 0, expand_type => expand_type)
  port map (nclk    => nclk,
            act     => ob_rd_logic_act,
            forcee   => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(ob3_rd_entry_ptr_offset to ob3_rd_entry_ptr_offset + ob3_rd_entry_ptr_q'length-1),
            scout   => sov(ob3_rd_entry_ptr_offset to ob3_rd_entry_ptr_offset + ob3_rd_entry_ptr_q'length-1),
            din     => ob3_rd_entry_ptr_d(0 to 1),
            dout    => ob3_rd_entry_ptr_q(0 to 1) );

--****************************************************************************
-- use read pointer to select message buffer complete reg for each thread
--****************************************************************************

with ob0_rd_entry_ptr_q(0 to 1) select
   ob0_to_nd_status_reg <= ob0_buf0_status_val & ob0_buf0_status_q(1 to 17)   when "00",
                           ob0_buf1_status_val & ob0_buf1_status_q(1 to 17)   when "01",
                           ob0_buf2_status_val & ob0_buf2_status_q(1 to 17)   when "10",
                           ob0_buf3_status_val & ob0_buf3_status_q(1 to 17)   when others;

with ob1_rd_entry_ptr_q(0 to 1) select
   ob1_to_nd_status_reg <= ob1_buf0_status_val & ob1_buf0_status_q(1 to 17)   when "00",
                           ob1_buf1_status_val & ob1_buf1_status_q(1 to 17)   when "01",
                           ob1_buf2_status_val & ob1_buf2_status_q(1 to 17)   when "10",
                           ob1_buf3_status_val & ob1_buf3_status_q(1 to 17)   when others;

with ob2_rd_entry_ptr_q(0 to 1) select
   ob2_to_nd_status_reg <= ob2_buf0_status_val & ob2_buf0_status_q(1 to 17)   when "00",
                           ob2_buf1_status_val & ob2_buf1_status_q(1 to 17)   when "01",
                           ob2_buf2_status_val & ob2_buf2_status_q(1 to 17)   when "10",
                           ob2_buf3_status_val & ob2_buf3_status_q(1 to 17)   when others;

with ob3_rd_entry_ptr_q(0 to 1) select
   ob3_to_nd_status_reg <= ob3_buf0_status_val & ob3_buf0_status_q(1 to 17)   when "00",
                           ob3_buf1_status_val & ob3_buf1_status_q(1 to 17)   when "01",
                           ob3_buf2_status_val & ob3_buf2_status_q(1 to 17)   when "10",
                           ob3_buf3_status_val & ob3_buf3_status_q(1 to 17)   when others;

--****************************************************************************
-- Determine which thread gets selected to send to node
--
-- This logic is best described with this table macro
-- the AND OR equations from the table are written below
--****************************************************************************

--
-- ?TABLE ob_to_node_sel LISTING(final) OPTIMIZE PARMS(ON-SET,OFF-SET);
-- *INPUTS*=================================================*OUTPUTS*=====================*
-- |                                                        |                             |
-- | ob0_to_nd_status_reg                                   | ob_to_node_sel_d            |
-- | | ob1_to_nd_status_reg                                 | |                           |
-- | | | ob2_to_nd_status_reg                               | |                           |
-- | | | | ob3_to_nd_status_reg                             | |                           |
-- | | | | |  ob_to_node_sel_q                              | |         ob_to_nd_val      |
-- | | | | |  |     send_ob_idle                            | |         |                 |
-- | | | | |  |     |                                       | |         |                 |
-- | 0 0 0 0  0123  |                                       | 0123      |                 |
-- *TYPE*===================================================+=============================+
-- | . . . .  ....  .                                       | ....      .                 |
-- *OPTIMIZE*---------------------------------------------->| AAAA      B                 |
-- *TERMS*==================================================+=============================+
-- | 0 0 0 0  0001  -                                       | 0001      0                 |
-- | 0 0 0 0  0010  -                                       | 0010      0                 |
-- | 0 0 0 0  0100  -                                       | 0100      0                 |
-- | 0 0 0 0  1000  -                                       | 1000      0                 |
-- | - - - -  0001  0                                       | 0001      0                 |
-- | - - - -  0010  0                                       | 0010      0                 |
-- | - - - -  0100  0                                       | 0100      0                 |
-- | - - - -  1000  0                                       | 1000      0                 |
-- *========================================================+=============================+
-- | 1 - - -  0001  1                                       | 1000      1                 |
-- | 0 1 - -  0001  1                                       | 0100      1                 |
-- | 0 0 1 -  0001  1                                       | 0010      1                 |
-- | 0 0 0 1  0001  1                                       | 0001      1                 |
-- *========================================================+=============================+
-- | - 1 - -  1000  1                                       | 0100      1                 |
-- | - 0 1 -  1000  1                                       | 0010      1                 |
-- | - 0 0 1  1000  1                                       | 0001      1                 |
-- | 1 0 0 0  1000  1                                       | 1000      1                 |
-- *========================================================+=============================+
-- | - - 1 -  0100  1                                       | 0010      1                 |
-- | - - 0 1  0100  1                                       | 0001      1                 |
-- | 1 - 0 0  0100  1                                       | 1000      1                 |
-- | 0 1 0 0  0100  1                                       | 0100      1                 |
-- *========================================================+=============================+
-- | - - - 1  0010  1                                       | 0001      1                 |
-- | 1 - - 0  0010  1                                       | 1000      1                 |
-- | 0 1 - 0  0010  1                                       | 0100      1                 |
-- | 0 0 1 0  0010  1                                       | 0010      1                 |
-- *END*====================================================+=============================+
-- ?TABLE END ob_to_node_sel ;

ob_to_nd_status_reg_vals(0 to 3) <= ob0_to_nd_status_reg(0) &
                                    ob1_to_nd_status_reg(0) & 
                                    ob2_to_nd_status_reg(0) & 
                                    ob3_to_nd_status_reg(0);


ob_to_node_sel_d(0) <= (ob_to_nd_status_reg_vals(0) and ob_to_node_sel_q(3)) or
                       (ob_to_nd_status_reg_vals(0) and ob_to_node_sel_q(2) and ob_to_nd_status_reg_vals(3)='0' ) or
                       (ob_to_nd_status_reg_vals(0) and ob_to_node_sel_q(1) and ob_to_nd_status_reg_vals(2 to 3)="00" ) or
                       (ob_to_nd_status_reg_vals(0) and ob_to_node_sel_q(0) and ob_to_nd_status_reg_vals(1 to 3)="000" ) or
                       (ob_to_node_sel_q(0) and ob_to_nd_status_reg_vals(0 to 3)="0000" );

ob_to_node_sel_d(1) <= (ob_to_nd_status_reg_vals(1) and ob_to_node_sel_q(0)) or
                       (ob_to_nd_status_reg_vals(1) and ob_to_node_sel_q(3) and ob_to_nd_status_reg_vals(0)='0' ) or
                       (ob_to_nd_status_reg_vals(1) and ob_to_node_sel_q(2) and ob_to_nd_status_reg_vals(3)='0' and ob_to_nd_status_reg_vals(0)='0' ) or
                       (ob_to_nd_status_reg_vals(1) and ob_to_node_sel_q(1) and ob_to_nd_status_reg_vals(2 to 3)="00" and ob_to_nd_status_reg_vals(0)='0' ) or
                       (ob_to_node_sel_q(1) and ob_to_nd_status_reg_vals(0 to 3)="0000" );

ob_to_node_sel_d(2) <= (ob_to_nd_status_reg_vals(2) and ob_to_node_sel_q(1)) or
                       (ob_to_nd_status_reg_vals(2) and ob_to_node_sel_q(0) and ob_to_nd_status_reg_vals(1)='0' ) or
                       (ob_to_nd_status_reg_vals(2) and ob_to_node_sel_q(3) and ob_to_nd_status_reg_vals(0 to 1)="00" ) or
                       (ob_to_nd_status_reg_vals(2) and ob_to_node_sel_q(2) and ob_to_nd_status_reg_vals(3)='0' and ob_to_nd_status_reg_vals(0 to 1)="00" ) or
                       (ob_to_node_sel_q(2) and ob_to_nd_status_reg_vals(0 to 3)="0000" );

ob_to_node_sel_d(3) <= (ob_to_nd_status_reg_vals(3) and ob_to_node_sel_q(2)) or
                       (ob_to_nd_status_reg_vals(3) and ob_to_node_sel_q(1) and ob_to_nd_status_reg_vals(2)='0' ) or
                       (ob_to_nd_status_reg_vals(3) and ob_to_node_sel_q(0) and ob_to_nd_status_reg_vals(1 to 2)="00" ) or
                       (ob_to_nd_status_reg_vals(3) and ob_to_node_sel_q(3) and ob_to_nd_status_reg_vals(0 to 2)="000" ) or
                       (ob_to_node_sel_q(3) and ob_to_nd_status_reg_vals(0 to 3)="0000" );


-- latch the outbox to node select

latch_ob_to_node_sel : tri_rlmreg_p
  generic map (width => ob_to_node_sel_q'length, init => 1, expand_type => expand_type)
  port map (nclk    => nclk,
            act     => ob_rd_logic_act,
            forcee   => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(ob_to_node_sel_offset to ob_to_node_sel_offset + ob_to_node_sel_q'length-1),
            scout   => sov(ob_to_node_sel_offset to ob_to_node_sel_offset + ob_to_node_sel_q'length-1),
            din     => ob_to_node_sel_d(0 to 3),
            dout    => ob_to_node_sel_q(0 to 3) );

ob_to_node_sel_sav_d(0 to 3) <= ob_to_node_sel_q(0 to 3)       when send_ob_idle='1' else
                                ob_to_node_sel_sav_q(0 to 3);

latch_ob_to_node_sel_sav : tri_rlmreg_p
  generic map (width => ob_to_node_sel_sav_q'length, init => 1, expand_type => expand_type)
  port map (nclk    => nclk,
            act     => ob_rd_logic_act,
            forcee   => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(ob_to_node_sel_sav_offset to ob_to_node_sel_sav_offset + ob_to_node_sel_sav_q'length-1),
            scout   => sov(ob_to_node_sel_sav_offset to ob_to_node_sel_sav_offset + ob_to_node_sel_sav_q'length-1),
            din     => ob_to_node_sel_sav_d(0 to 3),
            dout    => ob_to_node_sel_sav_q(0 to 3) );

ob_to_node_status_reg(1 to 17) <= gate_and( ob_to_node_sel_sav_q(0), ob0_to_nd_status_reg(1 to 17) ) or 
                                  gate_and( ob_to_node_sel_sav_q(1), ob1_to_nd_status_reg(1 to 17) ) or
                                  gate_and( ob_to_node_sel_sav_q(2), ob2_to_nd_status_reg(1 to 17) ) or
                                  gate_and( ob_to_node_sel_sav_q(3), ob3_to_nd_status_reg(1 to 17) );


ob_to_nd_val_t0 <= send_ob_idle and ob0_to_nd_status_reg(0) and ob_to_node_sel_q(0);
ob_to_nd_val_t1 <= send_ob_idle and ob1_to_nd_status_reg(0) and ob_to_node_sel_q(1);
ob_to_nd_val_t2 <= send_ob_idle and ob2_to_nd_status_reg(0) and ob_to_node_sel_q(2);
ob_to_nd_val_t3 <= send_ob_idle and ob3_to_nd_status_reg(0) and ob_to_node_sel_q(3);


-- delay the ipc outbox command 1 cycle so that it lines up with the data
--latch_ipc_ob_cmd : tri_rlmreg_p
--  generic map (width => ipc_ob_cmd_q'length, init => 0, expand_type => expand_type)
--  port map (nclk    => nclk,
--            act     => '1',
--            forcee   => func_sl_force,
--            d_mode  => d_mode_dc,
--            delay_lclkr => delay_lclkr_dc,
--            mpw1_b  => mpw1_dc_b,
--            mpw2_b  => mpw2_dc_b,
--            thold_b => func_sl_thold_0_b,
--            sg      => sg_0,
--            vd      => vdd,
--            gd      => gnd,
--            sreset  => func_sl_thold_0_b,
--            scin    => siv(ipc_ob_cmd_offset to ipc_ob_cmd_offset + ipc_ob_cmd_q'length-1),
--            scout   => sov(ipc_ob_cmd_offset to ipc_ob_cmd_offset + ipc_ob_cmd_q'length-1),
--            din     => ob_to_node_status_reg(0 to 18),
--            dout    => ipc_ob_cmd_q(0 to 18) );

--****************************************************************************
-- LSU interface
--****************************************************************************

latch_lsu_cmd_avail : tri_rlmreg_p
  generic map (width => 1, init => 0, expand_type => expand_type)  
  port map (nclk    => nclk,
            act     => ob_rd_logic_act,
            forcee   => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(lsu_cmd_avail_offset to lsu_cmd_avail_offset),
            scout   => sov(lsu_cmd_avail_offset to lsu_cmd_avail_offset),
            din(0)  => lsu_bx_cmd_avail,
            dout(0) => lsu_cmd_avail_q );

latch_lsu_cmd_sent : tri_rlmreg_p
  generic map (width => 1, init => 0, expand_type => expand_type)  
  port map (nclk    => nclk,
            act     => ob_rd_logic_act,
            forcee   => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(lsu_cmd_sent_offset to lsu_cmd_sent_offset),
            scout   => sov(lsu_cmd_sent_offset to lsu_cmd_sent_offset),
            din(0)  => lsu_bx_cmd_sent,
            dout(0) => lsu_cmd_sent_q );

latch_lsu_cmd_stall : tri_rlmreg_p
  generic map (width => 1, init => 0, expand_type => expand_type)  
  port map (nclk    => nclk,
            act     => ob_rd_logic_act,
            forcee   => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(lsu_cmd_stall_offset to lsu_cmd_stall_offset),
            scout   => sov(lsu_cmd_stall_offset to lsu_cmd_stall_offset),
            din(0)  => lsu_bx_cmd_stall,
            dout(0) => lsu_cmd_stall_q );


--****************************************************************************
-- outbox data transfer stall counter:  Counts OB commands that have been
-- sent from the LSU and keeps track of which one needs to be resent when
-- the LSU stalls.
--
-- 000 -> no transfers sent from LSU,            resend the 2nd data beat on a stall
-- 001 -> count the 1st transfer sent from LSU,  resend the 3rd data beat on a stall
-- 010 -> count the 2nd transfer sent from LSU,  resend the 4rd data beat on a stall
-- 011 -> count the 3rd transfer sent from LSU,  resend the DITC on a stall
-- 100 -> count the 4th transfer sent from LSU,  LSU already has DITC - don't need to resend
-- 101 -> count the DITC transfer sent from LSU, OB message is done
--****************************************************************************

ob_cmd_sent_count_d(0 to 2) <= "000"                                                 when ob_to_nd_done_d = '1' else
                               std_ulogic_vector(unsigned(ob_cmd_sent_count_q) + 1)  when lsu_cmd_sent_q  = '1' else
                               ob_cmd_sent_count_q(0 to 2);


latch_ob_cmd_sent_count : tri_rlmreg_p
  generic map (width => ob_cmd_sent_count_q'length, init => 0, expand_type => expand_type)
  port map (nclk    => nclk,
            act     => ob_rd_logic_act,
            forcee   => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(ob_cmd_sent_count_offset to ob_cmd_sent_count_offset + ob_cmd_sent_count_q'length-1),
            scout   => sov(ob_cmd_sent_count_offset to ob_cmd_sent_count_offset + ob_cmd_sent_count_q'length-1),
            din     => ob_cmd_sent_count_d(0 to 2),
            dout    => ob_cmd_sent_count_q(0 to 2) );

--****************************************************************************
-- State machine for sending packet from outbox to node
--****************************************************************************

ob_to_nd_ready <= ((ob_to_nd_val_t0 and ob_credit_t0) or
                   (ob_to_nd_val_t1 and ob_credit_t1) or 
                   (ob_to_nd_val_t2 and ob_credit_t2) or 
                   (ob_to_nd_val_t3 and ob_credit_t3)) and lsu_cmd_avail_q;

ob_lsu_complete <= (((ob_cmd_sent_count_q = "100") and (ob_to_node_status_reg(1 to 2) = "11")) or    -- len is 64B
                    ((ob_cmd_sent_count_q = "011") and (ob_to_node_status_reg(1 to 2) = "10")) or    -- len is 48B
                    ((ob_cmd_sent_count_q = "010") and (ob_to_node_status_reg(1 to 2) = "01")) or    -- len is 32B
                    ((ob_cmd_sent_count_q = "001") and (ob_to_node_status_reg(1 to 2) = "00")))    and lsu_cmd_sent_q;

send_ob_idle  <= send_ob_state_q(6);
send_ob_data1 <= send_ob_state_q(0);
send_ob_data2 <= send_ob_state_q(1);
send_ob_data3 <= send_ob_state_q(2);
send_ob_data4 <= send_ob_state_q(3);
send_ob_ditc  <= send_ob_state_q(4);
send_ob_wait  <= send_ob_state_q(5);

send_ob_state_mach:  process(send_ob_idle, send_ob_data1, send_ob_data2, send_ob_data3, send_ob_data4, send_ob_ditc, send_ob_wait, ob_to_nd_ready, ob_to_node_status_reg(1 to 2), lsu_cmd_stall_q, ob_cmd_sent_count_q, ob_lsu_complete, ob_ary_ue_or) begin

   send_ob_nxt_idle  <= '0';
   send_ob_nxt_data1 <= '0';
   send_ob_nxt_data2 <= '0';
   send_ob_nxt_data3 <= '0';
   send_ob_nxt_data4 <= '0';
   send_ob_nxt_ditc  <= '0';
   send_ob_nxt_wait  <= '0';
   ob_to_nd_done_d   <= '0';

   if send_ob_idle = '1' then
      if ob_to_nd_ready = '1' then
            send_ob_nxt_data1 <= '1';
      else 
         send_ob_nxt_idle <= '1';
      end if;
   end if;

   if send_ob_data1 = '1' then
      if  ob_ary_ue_or = '1' then
         send_ob_nxt_idle <= '1';
         ob_to_nd_done_d <= '1';
      elsif ob_to_node_status_reg(1 to 2) = "00" then     -- length of transfer is 16B
         send_ob_nxt_ditc <= '1';
      else 
         send_ob_nxt_data2 <= '1';
      end if;
   end if;

   if send_ob_data2 = '1' then
      if  ob_ary_ue_or = '1' then
         send_ob_nxt_idle <= '1';
         ob_to_nd_done_d <= '1';
      elsif lsu_cmd_stall_q = '0' then 
         if ob_to_node_status_reg(1 to 2) = "01" then     -- length of transfer is 32B
            send_ob_nxt_ditc <= '1';
         else 
            send_ob_nxt_data3 <= '1';
         end if;
      else   -- stall = 1
         send_ob_nxt_data2 <= '1';
      end if;
   end if;

   if send_ob_data3 = '1' then
      if  ob_ary_ue_or = '1' then
         send_ob_nxt_idle <= '1';
         ob_to_nd_done_d <= '1';
      elsif lsu_cmd_stall_q = '0' then 
         if ob_to_node_status_reg(1 to 2) = "10" then     -- length of transfer is 48B
            send_ob_nxt_ditc <= '1';
         else 
            send_ob_nxt_data4 <= '1';
         end if;
      else   -- stall = 1
         send_ob_nxt_data3 <= '1';
      end if;
   end if;

   if send_ob_data4 = '1' then
      if  ob_ary_ue_or = '1' then
         send_ob_nxt_idle <= '1';
         ob_to_nd_done_d <= '1';
      elsif lsu_cmd_stall_q = '0' then 
            send_ob_nxt_ditc <= '1';
      else   -- stall = 1
         send_ob_nxt_data4 <= '1';
      end if;
   end if;

   if send_ob_ditc = '1' then
      if  ob_ary_ue_or = '1' then
         send_ob_nxt_idle <= '1';
         ob_to_nd_done_d <= '1';
      elsif lsu_cmd_stall_q = '0' then
         send_ob_nxt_wait <= '1';
      else   -- stall = 1
         send_ob_nxt_ditc <= '1';
      end if;
   end if;

   if send_ob_wait = '1' then
      if  ob_ary_ue_or = '1' then
         send_ob_nxt_idle <= '1';
         ob_to_nd_done_d <= '1';
      elsif lsu_cmd_stall_q = '0' then 
         if (ob_lsu_complete = '1') then 
            send_ob_nxt_idle <= '1';
            ob_to_nd_done_d <= '1';
         else
            send_ob_nxt_wait <= '1';
         end if;
      else  -- stall = 1
         if ob_cmd_sent_count_q = "000" then 
            send_ob_nxt_data2 <= '1';
         elsif ob_cmd_sent_count_q = "001" then 
            send_ob_nxt_data3 <= '1';
         elsif ob_cmd_sent_count_q = "010" then 
            send_ob_nxt_data4 <= '1';
         elsif ob_cmd_sent_count_q = "011" then
            send_ob_nxt_ditc <= '1';
         else  -- count = 100
            send_ob_nxt_wait <= '1';
         end if;
      end if;
   end if;

end process;

send_ob_nxt_state(6) <= send_ob_nxt_idle;
send_ob_nxt_state(0) <= send_ob_nxt_data1;
send_ob_nxt_state(1) <= send_ob_nxt_data2;
send_ob_nxt_state(2) <= send_ob_nxt_data3;
send_ob_nxt_state(3) <= send_ob_nxt_data4;
send_ob_nxt_state(4) <= send_ob_nxt_ditc;
send_ob_nxt_state(5) <= send_ob_nxt_wait;

latch_send_ob_state : tri_rlmreg_p
  generic map (width => send_ob_state_q'length, init => 1, expand_type => expand_type)
  port map (nclk    => nclk,
            act     => ob_rd_logic_act,
            forcee   => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(send_ob_state_offset to send_ob_state_offset + send_ob_state_q'length-1),
            scout   => sov(send_ob_state_offset to send_ob_state_offset + send_ob_state_q'length-1),
            din     => send_ob_nxt_state,
            dout    => send_ob_state_q );




ob0_buf_done <= ob_to_nd_done_d and ob_to_node_sel_sav_q(0);
ob1_buf_done <= ob_to_nd_done_d and ob_to_node_sel_sav_q(1);
ob2_buf_done <= ob_to_nd_done_d and ob_to_node_sel_sav_q(2);
ob3_buf_done <= ob_to_nd_done_d and ob_to_node_sel_sav_q(3);

ob0_buf0_done <= ob_to_nd_done_d and ob_to_node_sel_sav_q(0) and ob0_rd_entry_ptr_q(0 to 1)="00";
ob0_buf1_done <= ob_to_nd_done_d and ob_to_node_sel_sav_q(0) and ob0_rd_entry_ptr_q(0 to 1)="01";
ob0_buf2_done <= ob_to_nd_done_d and ob_to_node_sel_sav_q(0) and ob0_rd_entry_ptr_q(0 to 1)="10";
ob0_buf3_done <= ob_to_nd_done_d and ob_to_node_sel_sav_q(0) and ob0_rd_entry_ptr_q(0 to 1)="11";
ob1_buf0_done <= ob_to_nd_done_d and ob_to_node_sel_sav_q(1) and ob1_rd_entry_ptr_q(0 to 1)="00";
ob1_buf1_done <= ob_to_nd_done_d and ob_to_node_sel_sav_q(1) and ob1_rd_entry_ptr_q(0 to 1)="01";
ob1_buf2_done <= ob_to_nd_done_d and ob_to_node_sel_sav_q(1) and ob1_rd_entry_ptr_q(0 to 1)="10";
ob1_buf3_done <= ob_to_nd_done_d and ob_to_node_sel_sav_q(1) and ob1_rd_entry_ptr_q(0 to 1)="11";
ob2_buf0_done <= ob_to_nd_done_d and ob_to_node_sel_sav_q(2) and ob2_rd_entry_ptr_q(0 to 1)="00";
ob2_buf1_done <= ob_to_nd_done_d and ob_to_node_sel_sav_q(2) and ob2_rd_entry_ptr_q(0 to 1)="01";
ob2_buf2_done <= ob_to_nd_done_d and ob_to_node_sel_sav_q(2) and ob2_rd_entry_ptr_q(0 to 1)="10";
ob2_buf3_done <= ob_to_nd_done_d and ob_to_node_sel_sav_q(2) and ob2_rd_entry_ptr_q(0 to 1)="11";
ob3_buf0_done <= ob_to_nd_done_d and ob_to_node_sel_sav_q(3) and ob3_rd_entry_ptr_q(0 to 1)="00";
ob3_buf1_done <= ob_to_nd_done_d and ob_to_node_sel_sav_q(3) and ob3_rd_entry_ptr_q(0 to 1)="01";
ob3_buf2_done <= ob_to_nd_done_d and ob_to_node_sel_sav_q(3) and ob3_rd_entry_ptr_q(0 to 1)="10";
ob3_buf3_done <= ob_to_nd_done_d and ob_to_node_sel_sav_q(3) and ob3_rd_entry_ptr_q(0 to 1)="11";


--****************************************************************************
-- determine outbox array read pointer
--****************************************************************************

ob_to_node_selected_thrd(0) <= ob_to_node_sel_sav_q(2) or ob_to_node_sel_sav_q(3);
ob_to_node_selected_thrd(1) <= ob_to_node_sel_sav_q(1) or ob_to_node_sel_sav_q(3);

ob_to_node_selected_rd_ptr(0 to 1) <= gate_and(ob_to_node_sel_sav_q(0) , ob0_rd_entry_ptr_q(0 to 1) ) or
                                      gate_and(ob_to_node_sel_sav_q(1) , ob1_rd_entry_ptr_q(0 to 1) ) or
                                      gate_and(ob_to_node_sel_sav_q(2) , ob2_rd_entry_ptr_q(0 to 1) ) or
                                      gate_and(ob_to_node_sel_sav_q(3) , ob3_rd_entry_ptr_q(0 to 1) );

send_ob_seq_ptr(0) <= send_ob_data3 or send_ob_data4;
send_ob_seq_ptr(1) <= send_ob_data2 or send_ob_data4;

ob_to_node_data_ptr(0 to 1) <= send_ob_seq_ptr(0 to 1)       when lsu_cmd_stall_q = '0'       else  -- send data pointed to by state machine
                               "01"                          when ob_cmd_sent_count_q = "000" else  -- resend 2nd data beat
                               "10"                          when ob_cmd_sent_count_q = "001" else  -- resend 3rd data beat
                               "11";                      -- when ob_cmd_sent_count_q = "010" else  -- resend 4th data beat

ob_ary_rd_addr(0 to 5) <= ob_to_node_selected_thrd & ob_to_node_selected_rd_ptr & ob_to_node_data_ptr;


--****************************************************************************
-- send command to the lsu
--****************************************************************************

send_ob_data_val <= ((send_ob_data1 or send_ob_data2 or send_ob_data3 or send_ob_data4) and not lsu_cmd_stall_q);

dly_ob_cmd_val_d(0) <= send_ob_data_val and not ob_ary_ue_or;
dly_ob_cmd_val_d(1) <= dly_ob_cmd_val_q(0) and not ob_ary_ue_or;

latch_dly_ob_cmd_val : tri_rlmreg_p
  generic map (width => dly_ob_cmd_val_q'length, init => 0, expand_type => expand_type)  
  port map (nclk    => nclk,
            act     => ob_rd_logic_act,
            forcee   => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(dly_ob_cmd_val_offset to dly_ob_cmd_val_offset + dly_ob_cmd_val_q'length-1),
            scout   => sov(dly_ob_cmd_val_offset to dly_ob_cmd_val_offset + dly_ob_cmd_val_q'length-1),
            din     => dly_ob_cmd_val_d(0 to 1),
            dout    => dly_ob_cmd_val_q(0 to 1) );

bx_lsu_ob_pwr_tok <= dly_ob_cmd_val_q(1) or dly_ob_ditc_val_q(1);

bx_lsu_ob_req_val_d <= dly_ob_cmd_val_q(1) and not ob_ary_ue_or;

latch_bxlsu_ob_req_val : tri_rlmreg_p
  generic map (width => 1, init => 0, expand_type => expand_type)  
  port map (nclk    => nclk,
            act     => ob_rd_logic_act,
            forcee   => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(bxlsu_ob_req_val_offset to bxlsu_ob_req_val_offset),
            scout   => sov(bxlsu_ob_req_val_offset to bxlsu_ob_req_val_offset),
            din(0)  => bx_lsu_ob_req_val_d,
            dout(0) => bx_lsu_ob_req_val_int );

bx_lsu_ob_req_val <= bx_lsu_ob_req_val_int;

send_ob_ditc_val <= (send_ob_ditc and not lsu_cmd_stall_q);

dly_ob_ditc_val_d(0) <= send_ob_ditc_val and not ob_ary_ue_or;
dly_ob_ditc_val_d(1) <= dly_ob_ditc_val_q(0) and not ob_ary_ue_or;

latch_dly_ob_ditc_val : tri_rlmreg_p
  generic map (width => dly_ob_ditc_val_q'length, init => 0, expand_type => expand_type)  
  port map (nclk    => nclk,
            act     => ob_rd_logic_act,
            forcee   => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(dly_ob_ditc_val_offset to dly_ob_ditc_val_offset + dly_ob_ditc_val_q'length-1),
            scout   => sov(dly_ob_ditc_val_offset to dly_ob_ditc_val_offset + dly_ob_ditc_val_q'length-1),
            din     => dly_ob_ditc_val_d(0 to 1),
            dout    => dly_ob_ditc_val_q(0 to 1) );

latch_bxlsu_ob_ditc_val : tri_rlmreg_p
  generic map (width => 1, init => 0, expand_type => expand_type)  
  port map (nclk    => nclk,
            act     => ob_rd_logic_act,
            forcee   => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(bxlsu_ob_ditc_val_offset to bxlsu_ob_ditc_val_offset),
            scout   => sov(bxlsu_ob_ditc_val_offset to bxlsu_ob_ditc_val_offset),
            din(0)  => dly_ob_ditc_val_q(1),
            dout(0) => bx_lsu_ob_ditc_val );

latch_dly_ob_qw : tri_rlmreg_p
  generic map (width => dly_ob_qw'length, init => 0, expand_type => expand_type)  
  port map (nclk    => nclk,
            act     => ob_rd_logic_act,
            forcee   => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(dly_ob_qw_offset to dly_ob_qw_offset + dly_ob_qw'length-1),
            scout   => sov(dly_ob_qw_offset to dly_ob_qw_offset + dly_ob_qw'length-1),
            din     => ob_to_node_data_ptr(0 to 1),
            dout    => dly_ob_qw );

latch_dly1_ob_qw : tri_rlmreg_p
  generic map (width => dly1_ob_qw'length, init => 0, expand_type => expand_type)  
  port map (nclk    => nclk,
            act     => ob_rd_logic_act,
            forcee   => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(dly1_ob_qw_offset to dly1_ob_qw_offset + dly1_ob_qw'length-1),
            scout   => sov(dly1_ob_qw_offset to dly1_ob_qw_offset + dly1_ob_qw'length-1),
            din     => dly_ob_qw,
            dout    => dly1_ob_qw );


latch_bxlsu_ob_qw : tri_rlmreg_p
  generic map (width => bx_lsu_ob_qw'length, init => 0, expand_type => expand_type)  
  port map (nclk    => nclk,
            act     => ob_rd_logic_act,
            forcee   => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(bxlsu_ob_qw_offset to bxlsu_ob_qw_offset + bx_lsu_ob_qw'length-1),
            scout   => sov(bxlsu_ob_qw_offset to bxlsu_ob_qw_offset + bx_lsu_ob_qw'length-1),
            din     => dly1_ob_qw,
            dout    => bx_lsu_ob_qw );


latch_bxlsu_ob_thrd : tri_rlmreg_p
  generic map (width => bx_lsu_ob_thrd'length, init => 0, expand_type => expand_type)  
  port map (nclk    => nclk,
            act     => ob_rd_logic_act,
            forcee   => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(bxlsu_ob_thrd_offset to bxlsu_ob_thrd_offset + bx_lsu_ob_thrd'length-1),
            scout   => sov(bxlsu_ob_thrd_offset to bxlsu_ob_thrd_offset + bx_lsu_ob_thrd'length-1),
            din     => ob_to_node_selected_thrd(0 to 1),
            dout    => bx_lsu_ob_thrd );

with ob_to_node_selected_thrd(0 to 1) select
   ob_addr_d <= ditc_addr_t0_q  when "00",
                ditc_addr_t1_q  when "01",
                ditc_addr_t2_q  when "10",
                ditc_addr_t3_q  when others;

latch_bxlsu_ob_addr : tri_rlmreg_p
  generic map (width => bx_lsu_ob_addr'length, init => 0, expand_type => expand_type)  
  port map (nclk    => nclk,
            act     => ob_rd_logic_act,
            forcee   => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(bxlsu_ob_addr_offset to bxlsu_ob_addr_offset + bx_lsu_ob_addr'length-1),
            scout   => sov(bxlsu_ob_addr_offset to bxlsu_ob_addr_offset + bx_lsu_ob_addr'length-1),
            din     => ob_addr_d,
            dout    => bx_lsu_ob_addr );


latch_bxlsu_ob_dest : tri_rlmreg_p
  generic map (width => bx_lsu_ob_dest'length, init => 0, expand_type => expand_type)  
  port map (nclk    => nclk,
            act     => ob_rd_logic_act,
            forcee   => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(bxlsu_ob_dest_offset to bxlsu_ob_dest_offset + bx_lsu_ob_dest'length-1),
            scout   => sov(bxlsu_ob_dest_offset to bxlsu_ob_dest_offset + bx_lsu_ob_dest'length-1),
            din     => ob_to_node_status_reg(3 to 17),
            dout    => bx_lsu_ob_dest );


bx_lsu_ob_data <= ob_rd_data_cor_l2;

--****************************************************************************
-- nd interface credit counter for outbox
--****************************************************************************

-- latch the pop signal from the node interface

latch_st_pop : tri_rlmreg_p
  generic map (width => 1, init => 0, expand_type => expand_type)  
  port map (nclk    => nclk,
            act     => '1',
            forcee   => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(st_pop_offset to st_pop_offset),
            scout   => sov(st_pop_offset to st_pop_offset),
            din(0)  => lsu_req_st_pop,
            dout(0) => lat_st_pop );

latch_st_pop_thrd : tri_rlmreg_p
  generic map (width => lat_st_pop_thrd'length, init => 0, expand_type => expand_type)  
  port map (nclk    => nclk,
            act     => '1',
            forcee   => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(st_pop_thrd_offset to st_pop_thrd_offset + lat_st_pop_thrd'length-1),
            scout   => sov(st_pop_thrd_offset to st_pop_thrd_offset + lat_st_pop_thrd'length-1),
            din     => lsu_req_st_pop_thrd(0 to 2),
            dout    => lat_st_pop_thrd(0 to 2) );

ob_cmd_count_incr_t0(0 to 1) <= std_ulogic_vector(unsigned(ob_cmd_count_t0_q) + 1);
ob_cmd_count_decr_t0(0 to 1) <= std_ulogic_vector(unsigned(ob_cmd_count_t0_q) - 1);

ob_cmd_count_incr_t1(0 to 1) <= std_ulogic_vector(unsigned(ob_cmd_count_t1_q) + 1);
ob_cmd_count_decr_t1(0 to 1) <= std_ulogic_vector(unsigned(ob_cmd_count_t1_q) - 1);

ob_cmd_count_incr_t2(0 to 1) <= std_ulogic_vector(unsigned(ob_cmd_count_t2_q) + 1);
ob_cmd_count_decr_t2(0 to 1) <= std_ulogic_vector(unsigned(ob_cmd_count_t2_q) - 1);

ob_cmd_count_incr_t3(0 to 1) <= std_ulogic_vector(unsigned(ob_cmd_count_t3_q) + 1);
ob_cmd_count_decr_t3(0 to 1) <= std_ulogic_vector(unsigned(ob_cmd_count_t3_q) - 1);

ob_pop(0) <= lat_st_pop and lat_st_pop_thrd(2) and lat_st_pop_thrd(0 to 1)="00";
ob_pop(1) <= lat_st_pop and lat_st_pop_thrd(2) and lat_st_pop_thrd(0 to 1)="01";
ob_pop(2) <= lat_st_pop and lat_st_pop_thrd(2) and lat_st_pop_thrd(0 to 1)="10";
ob_pop(3) <= lat_st_pop and lat_st_pop_thrd(2) and lat_st_pop_thrd(0 to 1)="11";

ob_cmd_count_t0_d(0 to 1) <= ob_cmd_count_incr_t0(0 to 1)  when (    (ob_to_nd_val_t0 and ob_credit_t0 and lsu_cmd_avail_q) and not ob_pop(0)) = '1'  else
                             ob_cmd_count_decr_t0(0 to 1)  when (not (ob_to_nd_val_t0 and ob_credit_t0 and lsu_cmd_avail_q) and     ob_pop(0)) = '1'  else
                             ob_cmd_count_t0_q;

ob_cmd_count_t1_d(0 to 1) <= ob_cmd_count_incr_t1(0 to 1)  when (    (ob_to_nd_val_t1 and ob_credit_t1 and lsu_cmd_avail_q) and not ob_pop(1)) = '1'  else
                             ob_cmd_count_decr_t1(0 to 1)  when (not (ob_to_nd_val_t1 and ob_credit_t1 and lsu_cmd_avail_q) and     ob_pop(1)) = '1'  else
                             ob_cmd_count_t1_q;

ob_cmd_count_t2_d(0 to 1) <= ob_cmd_count_incr_t2(0 to 1)  when (    (ob_to_nd_val_t2 and ob_credit_t2 and lsu_cmd_avail_q) and not ob_pop(2)) = '1'  else
                             ob_cmd_count_decr_t2(0 to 1)  when (not (ob_to_nd_val_t2 and ob_credit_t2 and lsu_cmd_avail_q) and     ob_pop(2)) = '1'  else
                             ob_cmd_count_t2_q;

ob_cmd_count_t3_d(0 to 1) <= ob_cmd_count_incr_t3(0 to 1)  when (    (ob_to_nd_val_t3 and ob_credit_t3 and lsu_cmd_avail_q) and not ob_pop(3)) = '1'  else
                             ob_cmd_count_decr_t3(0 to 1)  when (not (ob_to_nd_val_t3 and ob_credit_t3 and lsu_cmd_avail_q) and     ob_pop(3)) = '1'  else
                             ob_cmd_count_t3_q;

latch_ob_cmd_count_t0 : tri_rlmreg_p
  generic map (width => ob_cmd_count_t0_q'length, init => 0, expand_type => expand_type)  
  port map (nclk    => nclk,
            act     => '1',
            forcee   => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(ob_cmd_count_t0_offset to ob_cmd_count_t0_offset + ob_cmd_count_t0_q'length-1),
            scout   => sov(ob_cmd_count_t0_offset to ob_cmd_count_t0_offset + ob_cmd_count_t0_q'length-1),
            din     => ob_cmd_count_t0_d(0 to 1),
            dout    => ob_cmd_count_t0_q(0 to 1) );

latch_ob_cmd_count_t1 : tri_rlmreg_p
  generic map (width => ob_cmd_count_t1_q'length, init => 0, expand_type => expand_type)  
  port map (nclk    => nclk,
            act     => '1',
            forcee   => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(ob_cmd_count_t1_offset to ob_cmd_count_t1_offset + ob_cmd_count_t1_q'length-1),
            scout   => sov(ob_cmd_count_t1_offset to ob_cmd_count_t1_offset + ob_cmd_count_t1_q'length-1),
            din     => ob_cmd_count_t1_d(0 to 1),
            dout    => ob_cmd_count_t1_q(0 to 1) );

latch_ob_cmd_count_t2 : tri_rlmreg_p
  generic map (width => ob_cmd_count_t2_q'length, init => 0, expand_type => expand_type)  
  port map (nclk    => nclk,
            act     => '1',
            forcee   => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(ob_cmd_count_t2_offset to ob_cmd_count_t2_offset + ob_cmd_count_t2_q'length-1),
            scout   => sov(ob_cmd_count_t2_offset to ob_cmd_count_t2_offset + ob_cmd_count_t2_q'length-1),
            din     => ob_cmd_count_t2_d(0 to 1),
            dout    => ob_cmd_count_t2_q(0 to 1) );

latch_ob_cmd_count_t3 : tri_rlmreg_p
  generic map (width => ob_cmd_count_t3_q'length, init => 0, expand_type => expand_type)  
  port map (nclk    => nclk,
            act     => '1',
            forcee   => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(ob_cmd_count_t3_offset to ob_cmd_count_t3_offset + ob_cmd_count_t3_q'length-1),
            scout   => sov(ob_cmd_count_t3_offset to ob_cmd_count_t3_offset + ob_cmd_count_t3_q'length-1),
            din     => ob_cmd_count_t3_d(0 to 1),
            dout    => ob_cmd_count_t3_q(0 to 1) );

ob_credit_t0 <= not ob_cmd_count_t0_q(0);   -- when cmd count gets to 2, there are no credits left
ob_credit_t1 <= not ob_cmd_count_t1_q(0);   -- when cmd count gets to 2, there are no credits left
ob_credit_t2 <= not ob_cmd_count_t2_q(0);   -- when cmd count gets to 2, there are no credits left
ob_credit_t3 <= not ob_cmd_count_t3_q(0);   -- when cmd count gets to 2, there are no credits left


-- ********************************************************************************************
--
-- INBOX
--
-- ********************************************************************************************

--****************************************************************************
-- write to the input data port status register when BA = 10000
-- since ba(3:4)=00 the rotator will put the data on word 0
--****************************************************************************

wrt_ib0_buf0_status <= ex4_mtdp_val_gated and (ex4_ipc_thrd_q = "00") and (ex4_ipc_ba_q = "10000") and (ib0_rd_entry_ptr_dly_q = "00");
wrt_ib0_buf1_status <= ex4_mtdp_val_gated and (ex4_ipc_thrd_q = "00") and (ex4_ipc_ba_q = "10000") and (ib0_rd_entry_ptr_dly_q = "01");
wrt_ib0_buf2_status <= ex4_mtdp_val_gated and (ex4_ipc_thrd_q = "00") and (ex4_ipc_ba_q = "10000") and (ib0_rd_entry_ptr_dly_q = "10");
wrt_ib0_buf3_status <= ex4_mtdp_val_gated and (ex4_ipc_thrd_q = "00") and (ex4_ipc_ba_q = "10000") and (ib0_rd_entry_ptr_dly_q = "11");
wrt_ib1_buf0_status <= ex4_mtdp_val_gated and (ex4_ipc_thrd_q = "01") and (ex4_ipc_ba_q = "10000") and (ib1_rd_entry_ptr_dly_q = "00");
wrt_ib1_buf1_status <= ex4_mtdp_val_gated and (ex4_ipc_thrd_q = "01") and (ex4_ipc_ba_q = "10000") and (ib1_rd_entry_ptr_dly_q = "01");
wrt_ib1_buf2_status <= ex4_mtdp_val_gated and (ex4_ipc_thrd_q = "01") and (ex4_ipc_ba_q = "10000") and (ib1_rd_entry_ptr_dly_q = "10");
wrt_ib1_buf3_status <= ex4_mtdp_val_gated and (ex4_ipc_thrd_q = "01") and (ex4_ipc_ba_q = "10000") and (ib1_rd_entry_ptr_dly_q = "11");
wrt_ib2_buf0_status <= ex4_mtdp_val_gated and (ex4_ipc_thrd_q = "10") and (ex4_ipc_ba_q = "10000") and (ib2_rd_entry_ptr_dly_q = "00");
wrt_ib2_buf1_status <= ex4_mtdp_val_gated and (ex4_ipc_thrd_q = "10") and (ex4_ipc_ba_q = "10000") and (ib2_rd_entry_ptr_dly_q = "01");
wrt_ib2_buf2_status <= ex4_mtdp_val_gated and (ex4_ipc_thrd_q = "10") and (ex4_ipc_ba_q = "10000") and (ib2_rd_entry_ptr_dly_q = "10");
wrt_ib2_buf3_status <= ex4_mtdp_val_gated and (ex4_ipc_thrd_q = "10") and (ex4_ipc_ba_q = "10000") and (ib2_rd_entry_ptr_dly_q = "11");
wrt_ib3_buf0_status <= ex4_mtdp_val_gated and (ex4_ipc_thrd_q = "11") and (ex4_ipc_ba_q = "10000") and (ib3_rd_entry_ptr_dly_q = "00");
wrt_ib3_buf1_status <= ex4_mtdp_val_gated and (ex4_ipc_thrd_q = "11") and (ex4_ipc_ba_q = "10000") and (ib3_rd_entry_ptr_dly_q = "01");
wrt_ib3_buf2_status <= ex4_mtdp_val_gated and (ex4_ipc_thrd_q = "11") and (ex4_ipc_ba_q = "10000") and (ib3_rd_entry_ptr_dly_q = "10");
wrt_ib3_buf3_status <= ex4_mtdp_val_gated and (ex4_ipc_thrd_q = "11") and (ex4_ipc_ba_q = "10000") and (ib3_rd_entry_ptr_dly_q = "11");

ib0_incr_ptr <= ex3_mtdp_val and (ex3_ipc_thrd_q = "00") and (ex3_ipc_ba_q = "10000");   -- used to update entry ptr
ib1_incr_ptr <= ex3_mtdp_val and (ex3_ipc_thrd_q = "01") and (ex3_ipc_ba_q = "10000");
ib2_incr_ptr <= ex3_mtdp_val and (ex3_ipc_thrd_q = "10") and (ex3_ipc_ba_q = "10000");
ib3_incr_ptr <= ex3_mtdp_val and (ex3_ipc_thrd_q = "11") and (ex3_ipc_ba_q = "10000");

-- remember which status reg written last cycle

ex4_wrt_ib_status(0 to 15) <=  wrt_ib0_buf0_status & wrt_ib0_buf1_status & wrt_ib0_buf2_status & wrt_ib0_buf3_status &
                               wrt_ib1_buf0_status & wrt_ib1_buf1_status & wrt_ib1_buf2_status & wrt_ib1_buf3_status &
                               wrt_ib2_buf0_status & wrt_ib2_buf1_status & wrt_ib2_buf2_status & wrt_ib2_buf3_status &
                               wrt_ib3_buf0_status & wrt_ib3_buf1_status & wrt_ib3_buf2_status & wrt_ib3_buf3_status;

ex4_ib0_flushed <= ex4_mtdp_val_q and (ex4_ipc_thrd_q = "00") and (ex4_ipc_ba_q = "10000") and my_ex4_stg_flush;
ex4_ib1_flushed <= ex4_mtdp_val_q and (ex4_ipc_thrd_q = "01") and (ex4_ipc_ba_q = "10000") and my_ex4_stg_flush;
ex4_ib2_flushed <= ex4_mtdp_val_q and (ex4_ipc_thrd_q = "10") and (ex4_ipc_ba_q = "10000") and my_ex4_stg_flush;
ex4_ib3_flushed <= ex4_mtdp_val_q and (ex4_ipc_thrd_q = "11") and (ex4_ipc_ba_q = "10000") and my_ex4_stg_flush;

latch_ex5_wrt_ib_status : tri_rlmreg_p
  generic map (width => ex5_wrt_ib_status_q'length, init => 0, expand_type => expand_type)
  port map (nclk    => nclk,
            act     => mtdp_ex3_to_7_val,
            forcee   => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(ex5_wrt_ib_status_offset to ex5_wrt_ib_status_offset + ex5_wrt_ib_status_q'length-1),
            scout   => sov(ex5_wrt_ib_status_offset to ex5_wrt_ib_status_offset + ex5_wrt_ib_status_q'length-1),
            din     => ex4_wrt_ib_status(0 to 15),
            dout    => ex5_wrt_ib_status_q(0 to 15) );

ex5_wrt_ib_status_gated(0 to 15) <= gate_and(not my_ex5_stg_flush, ex5_wrt_ib_status_q(0 to 15));

latch_ex6_wrt_ib_status : tri_rlmreg_p
  generic map (width => ex6_wrt_ib_status_q'length, init => 0, expand_type => expand_type)
  port map (nclk    => nclk,
            act     => mtdp_ex3_to_7_val,
            forcee   => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(ex6_wrt_ib_status_offset to ex6_wrt_ib_status_offset + ex6_wrt_ib_status_q'length-1),
            scout   => sov(ex6_wrt_ib_status_offset to ex6_wrt_ib_status_offset + ex6_wrt_ib_status_q'length-1),
            din     => ex5_wrt_ib_status_gated(0 to 15),
            dout    => ex6_wrt_ib_status_q(0 to 15) );

ex5_ib0_buf0_flushed <= ex5_wrt_ib_status_q(0)  and my_ex5_stg_flush;
ex5_ib0_buf1_flushed <= ex5_wrt_ib_status_q(1)  and my_ex5_stg_flush;
ex5_ib0_buf2_flushed <= ex5_wrt_ib_status_q(2)  and my_ex5_stg_flush;
ex5_ib0_buf3_flushed <= ex5_wrt_ib_status_q(3)  and my_ex5_stg_flush;
ex5_ib1_buf0_flushed <= ex5_wrt_ib_status_q(4)  and my_ex5_stg_flush;
ex5_ib1_buf1_flushed <= ex5_wrt_ib_status_q(5)  and my_ex5_stg_flush;
ex5_ib1_buf2_flushed <= ex5_wrt_ib_status_q(6)  and my_ex5_stg_flush;
ex5_ib1_buf3_flushed <= ex5_wrt_ib_status_q(7)  and my_ex5_stg_flush;
ex5_ib2_buf0_flushed <= ex5_wrt_ib_status_q(8)  and my_ex5_stg_flush;
ex5_ib2_buf1_flushed <= ex5_wrt_ib_status_q(9)  and my_ex5_stg_flush;
ex5_ib2_buf2_flushed <= ex5_wrt_ib_status_q(10) and my_ex5_stg_flush;
ex5_ib2_buf3_flushed <= ex5_wrt_ib_status_q(11) and my_ex5_stg_flush;
ex5_ib3_buf0_flushed <= ex5_wrt_ib_status_q(12) and my_ex5_stg_flush;
ex5_ib3_buf1_flushed <= ex5_wrt_ib_status_q(13) and my_ex5_stg_flush;
ex5_ib3_buf2_flushed <= ex5_wrt_ib_status_q(14) and my_ex5_stg_flush;
ex5_ib3_buf3_flushed <= ex5_wrt_ib_status_q(15) and my_ex5_stg_flush;

ex5_ib0_flushed <= ex5_ib0_buf0_flushed or ex5_ib0_buf1_flushed or ex5_ib0_buf2_flushed or ex5_ib0_buf3_flushed;
ex5_ib1_flushed <= ex5_ib1_buf0_flushed or ex5_ib1_buf1_flushed or ex5_ib1_buf2_flushed or ex5_ib1_buf3_flushed;
ex5_ib2_flushed <= ex5_ib2_buf0_flushed or ex5_ib2_buf1_flushed or ex5_ib2_buf2_flushed or ex5_ib2_buf3_flushed;
ex5_ib3_flushed <= ex5_ib3_buf0_flushed or ex5_ib3_buf1_flushed or ex5_ib3_buf2_flushed or ex5_ib3_buf3_flushed;

ex6_ib0_buf0_flushed <= ex6_wrt_ib_status_q(0)  and my_ex6_stg_flush;
ex6_ib0_buf1_flushed <= ex6_wrt_ib_status_q(1)  and my_ex6_stg_flush;
ex6_ib0_buf2_flushed <= ex6_wrt_ib_status_q(2)  and my_ex6_stg_flush;
ex6_ib0_buf3_flushed <= ex6_wrt_ib_status_q(3)  and my_ex6_stg_flush;
ex6_ib1_buf0_flushed <= ex6_wrt_ib_status_q(4)  and my_ex6_stg_flush;
ex6_ib1_buf1_flushed <= ex6_wrt_ib_status_q(5)  and my_ex6_stg_flush;
ex6_ib1_buf2_flushed <= ex6_wrt_ib_status_q(6)  and my_ex6_stg_flush;
ex6_ib1_buf3_flushed <= ex6_wrt_ib_status_q(7)  and my_ex6_stg_flush;
ex6_ib2_buf0_flushed <= ex6_wrt_ib_status_q(8)  and my_ex6_stg_flush;
ex6_ib2_buf1_flushed <= ex6_wrt_ib_status_q(9)  and my_ex6_stg_flush;
ex6_ib2_buf2_flushed <= ex6_wrt_ib_status_q(10) and my_ex6_stg_flush;
ex6_ib2_buf3_flushed <= ex6_wrt_ib_status_q(11) and my_ex6_stg_flush;
ex6_ib3_buf0_flushed <= ex6_wrt_ib_status_q(12) and my_ex6_stg_flush;
ex6_ib3_buf1_flushed <= ex6_wrt_ib_status_q(13) and my_ex6_stg_flush;
ex6_ib3_buf2_flushed <= ex6_wrt_ib_status_q(14) and my_ex6_stg_flush;
ex6_ib3_buf3_flushed <= ex6_wrt_ib_status_q(15) and my_ex6_stg_flush;

ex6_ib0_flushed <= ex6_ib0_buf0_flushed or ex6_ib0_buf1_flushed or ex6_ib0_buf2_flushed or ex6_ib0_buf3_flushed;
ex6_ib1_flushed <= ex6_ib1_buf0_flushed or ex6_ib1_buf1_flushed or ex6_ib1_buf2_flushed or ex6_ib1_buf3_flushed;
ex6_ib2_flushed <= ex6_ib2_buf0_flushed or ex6_ib2_buf1_flushed or ex6_ib2_buf2_flushed or ex6_ib2_buf3_flushed;
ex6_ib3_flushed <= ex6_ib3_buf0_flushed or ex6_ib3_buf1_flushed or ex6_ib3_buf2_flushed or ex6_ib3_buf3_flushed;


-- **************************************************************************
-- return credit to node/L2 for the IPC inbox (one credit counter per thread)
-- when inbox status register is written to invalid
-- **************************************************************************
ib_t0_pop_d <= (ex6_wrt_ib_status_q(0) or ex6_wrt_ib_status_q(1) or ex6_wrt_ib_status_q(2) or ex6_wrt_ib_status_q(3)) and
               not my_ex6_stg_flush;

ib_t1_pop_d <= (ex6_wrt_ib_status_q(4) or ex6_wrt_ib_status_q(5) or ex6_wrt_ib_status_q(6) or ex6_wrt_ib_status_q(7)) and
               not my_ex6_stg_flush;

ib_t2_pop_d <= (ex6_wrt_ib_status_q(8) or ex6_wrt_ib_status_q(9) or ex6_wrt_ib_status_q(10) or ex6_wrt_ib_status_q(11)) and
               not my_ex6_stg_flush;

ib_t3_pop_d <= (ex6_wrt_ib_status_q(12) or ex6_wrt_ib_status_q(13) or ex6_wrt_ib_status_q(14) or ex6_wrt_ib_status_q(15)) and
               not my_ex6_stg_flush;

latch_ipc_ib_t0_pop : tri_rlmreg_p
  generic map (width => 1, init => 0, expand_type => expand_type)  
  port map (nclk    => nclk,
            act     => mtdp_ex3_to_7_val,
            forcee   => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(ipc_ib_t0_pop_offset to ipc_ib_t0_pop_offset),
            scout   => sov(ipc_ib_t0_pop_offset to ipc_ib_t0_pop_offset),
            din(0)  => ib_t0_pop_d,
            dout(0) => ac_an_reld_ditc_pop(0) );

latch_ipc_ib_t1_pop : tri_rlmreg_p
  generic map (width => 1, init => 0, expand_type => expand_type)  
  port map (nclk    => nclk,
            act     => mtdp_ex3_to_7_val,
            forcee   => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(ipc_ib_t1_pop_offset to ipc_ib_t1_pop_offset),
            scout   => sov(ipc_ib_t1_pop_offset to ipc_ib_t1_pop_offset),
            din(0)  => ib_t1_pop_d,
            dout(0) => ac_an_reld_ditc_pop(1) );

latch_ipc_ib_t2_pop : tri_rlmreg_p
  generic map (width => 1, init => 0, expand_type => expand_type)  
  port map (nclk    => nclk,
            act     => mtdp_ex3_to_7_val,
            forcee   => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(ipc_ib_t2_pop_offset to ipc_ib_t2_pop_offset),
            scout   => sov(ipc_ib_t2_pop_offset to ipc_ib_t2_pop_offset),
            din(0)  => ib_t2_pop_d,
            dout(0) => ac_an_reld_ditc_pop(2) );

latch_ipc_ib_t3_pop : tri_rlmreg_p
  generic map (width => 1, init => 0, expand_type => expand_type)  
  port map (nclk    => nclk,
            act     => mtdp_ex3_to_7_val,
            forcee   => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(ipc_ib_t3_pop_offset to ipc_ib_t3_pop_offset),
            scout   => sov(ipc_ib_t3_pop_offset to ipc_ib_t3_pop_offset),
            din(0)  => ib_t3_pop_d,
            dout(0) => ac_an_reld_ditc_pop(3) );


                        

ib0_buf0_val_d <= '0'                 when wrt_ib0_buf0_status='1'  else
                  ex5_ib_val_save_q   when ex5_ib0_buf0_flushed='1' else 
                  ex6_ib_val_save_q   when ex6_ib0_buf0_flushed='1' else 
                  '1'                 when ib0_buf0_set_val='1'     else
                  '0'                 when ib0_buf0_reset_val='1'   else
                  ib0_buf0_val_q;

ib0_buf1_val_d <= '0'                 when wrt_ib0_buf1_status='1'  else
                  ex5_ib_val_save_q   when ex5_ib0_buf1_flushed='1' else 
                  ex6_ib_val_save_q   when ex6_ib0_buf1_flushed='1' else 
                  '1'                 when ib0_buf1_set_val='1'     else
                  '0'                 when ib0_buf1_reset_val='1'   else
                  ib0_buf1_val_q;

ib0_buf2_val_d <= '0'                 when wrt_ib0_buf2_status='1'  else
                  ex5_ib_val_save_q   when ex5_ib0_buf2_flushed='1' else 
                  ex6_ib_val_save_q   when ex6_ib0_buf2_flushed='1' else 
                  '1'                 when ib0_buf2_set_val='1'     else
                  '0'                 when ib0_buf2_reset_val='1'   else
                  ib0_buf2_val_q;

ib0_buf3_val_d <= '0'                 when wrt_ib0_buf3_status='1'  else
                  ex5_ib_val_save_q   when ex5_ib0_buf3_flushed='1' else 
                  ex6_ib_val_save_q   when ex6_ib0_buf3_flushed='1' else 
                  '1'                 when ib0_buf3_set_val='1'     else
                  '0'                 when ib0_buf3_reset_val='1'   else
                  ib0_buf3_val_q;

ib1_buf0_val_d <= '0'                 when wrt_ib1_buf0_status='1'  else
                  ex5_ib_val_save_q   when ex5_ib1_buf0_flushed='1' else 
                  ex6_ib_val_save_q   when ex6_ib1_buf0_flushed='1' else 
                  '1'                 when ib1_buf0_set_val='1'     else
                  '0'                 when ib1_buf0_reset_val='1'   else
                  ib1_buf0_val_q;

ib1_buf1_val_d <= '0'                 when wrt_ib1_buf1_status='1'  else
                  ex5_ib_val_save_q   when ex5_ib1_buf1_flushed='1' else 
                  ex6_ib_val_save_q   when ex6_ib1_buf1_flushed='1' else 
                  '1'                 when ib1_buf1_set_val='1'     else
                  '0'                 when ib1_buf1_reset_val='1'   else
                  ib1_buf1_val_q;

ib1_buf2_val_d <= '0'                 when wrt_ib1_buf2_status='1'  else
                  ex5_ib_val_save_q   when ex5_ib1_buf2_flushed='1' else 
                  ex6_ib_val_save_q   when ex6_ib1_buf2_flushed='1' else 
                  '1'                 when ib1_buf2_set_val='1'     else
                  '0'                 when ib1_buf2_reset_val='1'   else
                  ib1_buf2_val_q;

ib1_buf3_val_d <= '0'                 when wrt_ib1_buf3_status='1'  else
                  ex5_ib_val_save_q   when ex5_ib1_buf3_flushed='1' else 
                  ex6_ib_val_save_q   when ex6_ib1_buf3_flushed='1' else 
                  '1'                 when ib1_buf3_set_val='1'     else
                  '0'                 when ib1_buf3_reset_val='1'   else
                  ib1_buf3_val_q;

ib2_buf0_val_d <= '0'                 when wrt_ib2_buf0_status='1'  else
                  ex5_ib_val_save_q   when ex5_ib2_buf0_flushed='1' else 
                  ex6_ib_val_save_q   when ex6_ib2_buf0_flushed='1' else 
                  '1'                 when ib2_buf0_set_val='1'     else
                  '0'                 when ib2_buf0_reset_val='1'   else
                  ib2_buf0_val_q;

ib2_buf1_val_d <= '0'                 when wrt_ib2_buf1_status='1'  else
                  ex5_ib_val_save_q   when ex5_ib2_buf1_flushed='1' else 
                  ex6_ib_val_save_q   when ex6_ib2_buf1_flushed='1' else 
                  '1'                 when ib2_buf1_set_val='1'     else
                  '0'                 when ib2_buf1_reset_val='1'   else
                  ib2_buf1_val_q;

ib2_buf2_val_d <= '0'                 when wrt_ib2_buf2_status='1'  else
                  ex5_ib_val_save_q   when ex5_ib2_buf2_flushed='1' else 
                  ex6_ib_val_save_q   when ex6_ib2_buf2_flushed='1' else 
                  '1'                 when ib2_buf2_set_val='1'     else
                  '0'                 when ib2_buf2_reset_val='1'   else
                  ib2_buf2_val_q;

ib2_buf3_val_d <= '0'                 when wrt_ib2_buf3_status='1'  else
                  ex5_ib_val_save_q   when ex5_ib2_buf3_flushed='1' else 
                  ex6_ib_val_save_q   when ex6_ib2_buf3_flushed='1' else 
                  '1'                 when ib2_buf3_set_val='1'     else
                  '0'                 when ib2_buf3_reset_val='1'   else
                  ib2_buf3_val_q;

ib3_buf0_val_d <= '0'                 when wrt_ib3_buf0_status='1'  else
                  ex5_ib_val_save_q   when ex5_ib3_buf0_flushed='1' else 
                  ex6_ib_val_save_q   when ex6_ib3_buf0_flushed='1' else 
                  '1'                 when ib3_buf0_set_val='1'     else
                  '0'                 when ib3_buf0_reset_val='1'   else
                  ib3_buf0_val_q;

ib3_buf1_val_d <= '0'                 when wrt_ib3_buf1_status='1'  else
                  ex5_ib_val_save_q   when ex5_ib3_buf1_flushed='1' else 
                  ex6_ib_val_save_q   when ex6_ib3_buf1_flushed='1' else 
                  '1'                 when ib3_buf1_set_val='1'     else
                  '0'                 when ib3_buf1_reset_val='1'   else
                  ib3_buf1_val_q;

ib3_buf2_val_d <= '0'                 when wrt_ib3_buf2_status='1'  else
                  ex5_ib_val_save_q   when ex5_ib3_buf2_flushed='1' else 
                  ex6_ib_val_save_q   when ex6_ib3_buf2_flushed='1' else 
                  '1'                 when ib3_buf2_set_val='1'     else
                  '0'                 when ib3_buf2_reset_val='1'   else
                  ib3_buf2_val_q;

ib3_buf3_val_d <= '0'                 when wrt_ib3_buf3_status='1'  else
                  ex5_ib_val_save_q   when ex5_ib3_buf3_flushed='1' else 
                  ex6_ib_val_save_q   when ex6_ib3_buf3_flushed='1' else 
                  '1'                 when ib3_buf3_set_val='1'     else
                  '0'                 when ib3_buf3_reset_val='1'   else
                  ib3_buf3_val_q;

ex4_ib_val_save <= gate_and(wrt_ib0_buf0_status, ib0_buf0_val_q) or 
                   gate_and(wrt_ib0_buf1_status, ib0_buf1_val_q) or 
                   gate_and(wrt_ib0_buf2_status, ib0_buf2_val_q) or 
                   gate_and(wrt_ib0_buf3_status, ib0_buf3_val_q) or 
                   gate_and(wrt_ib1_buf0_status, ib1_buf0_val_q) or 
                   gate_and(wrt_ib1_buf1_status, ib1_buf1_val_q) or 
                   gate_and(wrt_ib1_buf2_status, ib1_buf2_val_q) or 
                   gate_and(wrt_ib1_buf3_status, ib1_buf3_val_q) or 
                   gate_and(wrt_ib2_buf0_status, ib2_buf0_val_q) or 
                   gate_and(wrt_ib2_buf1_status, ib2_buf1_val_q) or 
                   gate_and(wrt_ib2_buf2_status, ib2_buf2_val_q) or 
                   gate_and(wrt_ib2_buf3_status, ib2_buf3_val_q) or 
                   gate_and(wrt_ib3_buf0_status, ib3_buf0_val_q) or 
                   gate_and(wrt_ib3_buf1_status, ib3_buf1_val_q) or 
                   gate_and(wrt_ib3_buf2_status, ib3_buf2_val_q) or 
                   gate_and(wrt_ib3_buf3_status, ib3_buf3_val_q);


ib_buf_val_act <= reld_data_val or mtdp_ex3_to_7_val;

latch_ib0_buf0_val : tri_rlmreg_p
  generic map (width => 1, init => 0, expand_type => expand_type)
  port map (nclk    => nclk,
            act     => ib_buf_val_act,
            forcee   => func_slp_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_slp_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(ib0_buf0_val_offset to ib0_buf0_val_offset),
            scout   => sov(ib0_buf0_val_offset to ib0_buf0_val_offset),
            din(0)  => ib0_buf0_val_d,
            dout(0) => ib0_buf0_val_q );


latch_ib0_buf1_val : tri_rlmreg_p
  generic map (width => 1, init => 0, expand_type => expand_type)
  port map (nclk    => nclk,
            act     => ib_buf_val_act,
            forcee   => func_slp_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_slp_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(ib0_buf1_val_offset to ib0_buf1_val_offset),
            scout   => sov(ib0_buf1_val_offset to ib0_buf1_val_offset),
            din(0)  => ib0_buf1_val_d,
            dout(0) => ib0_buf1_val_q );

latch_ib0_buf2_val : tri_rlmreg_p
  generic map (width => 1, init => 0, expand_type => expand_type)
  port map (nclk    => nclk,
            act     => ib_buf_val_act,
            forcee   => func_slp_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_slp_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(ib0_buf2_val_offset to ib0_buf2_val_offset),
            scout   => sov(ib0_buf2_val_offset to ib0_buf2_val_offset),
            din(0)  => ib0_buf2_val_d,
            dout(0) => ib0_buf2_val_q );

latch_ib0_buf3_val : tri_rlmreg_p
  generic map (width => 1, init => 0, expand_type => expand_type)
  port map (nclk    => nclk,
            act     => ib_buf_val_act,
            forcee   => func_slp_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_slp_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(ib0_buf3_val_offset to ib0_buf3_val_offset),
            scout   => sov(ib0_buf3_val_offset to ib0_buf3_val_offset),
            din(0)  => ib0_buf3_val_d,
            dout(0) => ib0_buf3_val_q );

latch_ib1_buf0_val : tri_rlmreg_p
  generic map (width => 1, init => 0, expand_type => expand_type)
  port map (nclk    => nclk,
            act     => ib_buf_val_act,
            forcee   => func_slp_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_slp_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(ib1_buf0_val_offset to ib1_buf0_val_offset),
            scout   => sov(ib1_buf0_val_offset to ib1_buf0_val_offset),
            din(0)  => ib1_buf0_val_d,
            dout(0) => ib1_buf0_val_q );


latch_ib1_buf1_val : tri_rlmreg_p
  generic map (width => 1, init => 0, expand_type => expand_type)
  port map (nclk    => nclk,
            act     => ib_buf_val_act,
            forcee   => func_slp_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_slp_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(ib1_buf1_val_offset to ib1_buf1_val_offset),
            scout   => sov(ib1_buf1_val_offset to ib1_buf1_val_offset),
            din(0)  => ib1_buf1_val_d,
            dout(0) => ib1_buf1_val_q );

latch_ib1_buf2_val : tri_rlmreg_p
  generic map (width => 1, init => 0, expand_type => expand_type)
  port map (nclk    => nclk,
            act     => ib_buf_val_act,
            forcee   => func_slp_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_slp_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(ib1_buf2_val_offset to ib1_buf2_val_offset),
            scout   => sov(ib1_buf2_val_offset to ib1_buf2_val_offset),
            din(0)  => ib1_buf2_val_d,
            dout(0) => ib1_buf2_val_q );

latch_ib1_buf3_val : tri_rlmreg_p
  generic map (width => 1, init => 0, expand_type => expand_type)
  port map (nclk    => nclk,
            act     => ib_buf_val_act,
            forcee   => func_slp_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_slp_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(ib1_buf3_val_offset to ib1_buf3_val_offset),
            scout   => sov(ib1_buf3_val_offset to ib1_buf3_val_offset),
            din(0)  => ib1_buf3_val_d,
            dout(0) => ib1_buf3_val_q );

latch_ib2_buf0_val : tri_rlmreg_p
  generic map (width => 1, init => 0, expand_type => expand_type)
  port map (nclk    => nclk,
            act     => ib_buf_val_act,
            forcee   => func_slp_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_slp_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(ib2_buf0_val_offset to ib2_buf0_val_offset),
            scout   => sov(ib2_buf0_val_offset to ib2_buf0_val_offset),
            din(0)  => ib2_buf0_val_d,
            dout(0) => ib2_buf0_val_q );


latch_ib2_buf1_val : tri_rlmreg_p
  generic map (width => 1, init => 0, expand_type => expand_type)
  port map (nclk    => nclk,
            act     => ib_buf_val_act,
            forcee   => func_slp_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_slp_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(ib2_buf1_val_offset to ib2_buf1_val_offset),
            scout   => sov(ib2_buf1_val_offset to ib2_buf1_val_offset),
            din(0)  => ib2_buf1_val_d,
            dout(0) => ib2_buf1_val_q );

latch_ib2_buf2_val : tri_rlmreg_p
  generic map (width => 1, init => 0, expand_type => expand_type)
  port map (nclk    => nclk,
            act     => ib_buf_val_act,
            forcee   => func_slp_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_slp_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(ib2_buf2_val_offset to ib2_buf2_val_offset),
            scout   => sov(ib2_buf2_val_offset to ib2_buf2_val_offset),
            din(0)  => ib2_buf2_val_d,
            dout(0) => ib2_buf2_val_q );

latch_ib2_buf3_val : tri_rlmreg_p
  generic map (width => 1, init => 0, expand_type => expand_type)
  port map (nclk    => nclk,
            act     => ib_buf_val_act,
            forcee   => func_slp_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_slp_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(ib2_buf3_val_offset to ib2_buf3_val_offset),
            scout   => sov(ib2_buf3_val_offset to ib2_buf3_val_offset),
            din(0)  => ib2_buf3_val_d,
            dout(0) => ib2_buf3_val_q );

latch_ib3_buf0_val : tri_rlmreg_p
  generic map (width => 1, init => 0, expand_type => expand_type)
  port map (nclk    => nclk,
            act     => ib_buf_val_act,
            forcee   => func_slp_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_slp_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(ib3_buf0_val_offset to ib3_buf0_val_offset),
            scout   => sov(ib3_buf0_val_offset to ib3_buf0_val_offset),
            din(0)  => ib3_buf0_val_d,
            dout(0) => ib3_buf0_val_q );


latch_ib3_buf1_val : tri_rlmreg_p
  generic map (width => 1, init => 0, expand_type => expand_type)
  port map (nclk    => nclk,
            act     => ib_buf_val_act,
            forcee   => func_slp_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_slp_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(ib3_buf1_val_offset to ib3_buf1_val_offset),
            scout   => sov(ib3_buf1_val_offset to ib3_buf1_val_offset),
            din(0)  => ib3_buf1_val_d,
            dout(0) => ib3_buf1_val_q );

latch_ib3_buf2_val : tri_rlmreg_p
  generic map (width => 1, init => 0, expand_type => expand_type)
  port map (nclk    => nclk,
            act     => ib_buf_val_act,
            forcee   => func_slp_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_slp_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(ib3_buf2_val_offset to ib3_buf2_val_offset),
            scout   => sov(ib3_buf2_val_offset to ib3_buf2_val_offset),
            din(0)  => ib3_buf2_val_d,
            dout(0) => ib3_buf2_val_q );

latch_ib3_buf3_val : tri_rlmreg_p
  generic map (width => 1, init => 0, expand_type => expand_type)
  port map (nclk    => nclk,
            act     => ib_buf_val_act,
            forcee   => func_slp_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_slp_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(ib3_buf3_val_offset to ib3_buf3_val_offset),
            scout   => sov(ib3_buf3_val_offset to ib3_buf3_val_offset),
            din(0)  => ib3_buf3_val_d,
            dout(0) => ib3_buf3_val_q );

latch_ex5_ib_val_save : tri_rlmreg_p
  generic map (width => 1, init => 0, expand_type => expand_type)
  port map (nclk    => nclk,
            act     => mtdp_ex3_to_7_val,
            forcee   => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(ex5_ib_val_save_offset to ex5_ib_val_save_offset),
            scout   => sov(ex5_ib_val_save_offset to ex5_ib_val_save_offset),
            din(0)  => ex4_ib_val_save,
            dout(0) => ex5_ib_val_save_q );

latch_ex6_ib_val_save : tri_rlmreg_p
  generic map (width => 1, init => 0, expand_type => expand_type)
  port map (nclk    => nclk,
            act     => mtdp_ex3_to_7_val,
            forcee   => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(ex6_ib_val_save_offset to ex6_ib_val_save_offset),
            scout   => sov(ex6_ib_val_save_offset to ex6_ib_val_save_offset),
            din(0)  => ex5_ib_val_save_q,
            dout(0) => ex6_ib_val_save_q );


ib_empty_d(0) <= not (ib0_buf0_val_q or ib0_buf1_val_q or ib0_buf2_val_q or ib0_buf3_val_q);
ib_empty_d(1) <= not (ib1_buf0_val_q or ib1_buf1_val_q or ib1_buf2_val_q or ib1_buf3_val_q);
ib_empty_d(2) <= not (ib2_buf0_val_q or ib2_buf1_val_q or ib2_buf2_val_q or ib2_buf3_val_q);
ib_empty_d(3) <= not (ib3_buf0_val_q or ib3_buf1_val_q or ib3_buf2_val_q or ib3_buf3_val_q);

quiesce_d(0) <= ib_empty_d(0) and not (ob0_buf0_status_q(0) or ob0_buf1_status_q(0) or ob0_buf2_status_q(0) or ob0_buf3_status_q(0));
quiesce_d(1) <= ib_empty_d(1) and not (ob1_buf0_status_q(0) or ob1_buf1_status_q(0) or ob1_buf2_status_q(0) or ob1_buf3_status_q(0));
quiesce_d(2) <= ib_empty_d(2) and not (ob2_buf0_status_q(0) or ob2_buf1_status_q(0) or ob2_buf2_status_q(0) or ob2_buf3_status_q(0));
quiesce_d(3) <= ib_empty_d(3) and not (ob3_buf0_status_q(0) or ob3_buf1_status_q(0) or ob3_buf2_status_q(0) or ob3_buf3_status_q(0));

latch_ib_empty : tri_rlmreg_p
  generic map (width => ib_empty_d'length, init => 0, expand_type => expand_type)
  port map (nclk    => nclk,
            act     => '1',
            forcee   => func_slp_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_slp_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(ib_empty_offset to ib_empty_offset + ib_empty_d'length-1),
            scout   => sov(ib_empty_offset to ib_empty_offset + ib_empty_d'length-1),
            din     => ib_empty_d(0 to 3),
            dout    => bx_ib_empty(0 to 3) );

latch_quiesce : tri_rlmreg_p
  generic map (width => quiesce_d'length, init => 0, expand_type => expand_type)
  port map (nclk    => nclk,
            act     => '1',
            forcee   => func_slp_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_slp_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(quiesce_offset to quiesce_offset + quiesce_d'length-1),
            scout   => sov(quiesce_offset to quiesce_offset + quiesce_d'length-1),
            din     => quiesce_d(0 to 3),
            dout    => bx_xu_quiesce(0 to 3) );



--**********************************************************************************************
-- increment inbox buffer read pointer when the status register is written in-valid
-- there is one buffer pointer per thread
-- the entry pointer gets updated in ex3 even though the status reg is written in ex4
-- this allows the logic to use the latched version of the entry pointer
--**********************************************************************************************

ib0_decr_ptr     <= (ex4_ib0_flushed & ex5_ib0_flushed & ex6_ib0_flushed = "100") or 
                    (ex4_ib0_flushed & ex5_ib0_flushed & ex6_ib0_flushed = "010") or
                    (ex4_ib0_flushed & ex5_ib0_flushed & ex6_ib0_flushed = "001");

ib0_decr_ptr_by2 <= (ex4_ib0_flushed & ex5_ib0_flushed & ex6_ib0_flushed = "110") or
                    (ex4_ib0_flushed & ex5_ib0_flushed & ex6_ib0_flushed = "101") or
                    (ex4_ib0_flushed & ex5_ib0_flushed & ex6_ib0_flushed = "011");

ib0_decr_ptr_by3 <= ex4_ib0_flushed & ex5_ib0_flushed & ex6_ib0_flushed = "111";

ib0_rd_entry_ptr_d <= std_ulogic_vector(unsigned(ib0_rd_entry_ptr_q) + 1)  when ib0_incr_ptr='1'   else
                      std_ulogic_vector(unsigned(ib0_rd_entry_ptr_q) - 1)  when ib0_decr_ptr='1' else
                      std_ulogic_vector(unsigned(ib0_rd_entry_ptr_q) - 2)  when ib0_decr_ptr_by2='1' else
                      std_ulogic_vector(unsigned(ib0_rd_entry_ptr_q) - 3)  when ib0_decr_ptr_by3='1' else
                      ib0_rd_entry_ptr_q(0 to 1);

ib1_decr_ptr     <= (ex4_ib1_flushed & ex5_ib1_flushed & ex6_ib1_flushed = "100") or 
                    (ex4_ib1_flushed & ex5_ib1_flushed & ex6_ib1_flushed = "010") or
                    (ex4_ib1_flushed & ex5_ib1_flushed & ex6_ib1_flushed = "001");

ib1_decr_ptr_by2 <= (ex4_ib1_flushed & ex5_ib1_flushed & ex6_ib1_flushed = "110") or
                    (ex4_ib1_flushed & ex5_ib1_flushed & ex6_ib1_flushed = "101") or
                    (ex4_ib1_flushed & ex5_ib1_flushed & ex6_ib1_flushed = "011");

ib1_decr_ptr_by3 <= ex4_ib1_flushed & ex5_ib1_flushed & ex6_ib1_flushed = "111";

ib1_rd_entry_ptr_d <= std_ulogic_vector(unsigned(ib1_rd_entry_ptr_q) + 1)  when ib1_incr_ptr='1'   else
                      std_ulogic_vector(unsigned(ib1_rd_entry_ptr_q) - 1)  when ib1_decr_ptr='1' else
                      std_ulogic_vector(unsigned(ib1_rd_entry_ptr_q) - 2)  when ib1_decr_ptr_by2='1' else
                      std_ulogic_vector(unsigned(ib1_rd_entry_ptr_q) - 3)  when ib1_decr_ptr_by3='1' else
                      ib1_rd_entry_ptr_q(0 to 1);

ib2_decr_ptr     <= (ex4_ib2_flushed & ex5_ib2_flushed & ex6_ib2_flushed = "100") or 
                    (ex4_ib2_flushed & ex5_ib2_flushed & ex6_ib2_flushed = "010") or
                    (ex4_ib2_flushed & ex5_ib2_flushed & ex6_ib2_flushed = "001");

ib2_decr_ptr_by2 <= (ex4_ib2_flushed & ex5_ib2_flushed & ex6_ib2_flushed = "110") or
                    (ex4_ib2_flushed & ex5_ib2_flushed & ex6_ib2_flushed = "101") or
                    (ex4_ib2_flushed & ex5_ib2_flushed & ex6_ib2_flushed = "011");

ib2_decr_ptr_by3 <= ex4_ib2_flushed & ex5_ib2_flushed & ex6_ib2_flushed = "111";

ib2_rd_entry_ptr_d <= std_ulogic_vector(unsigned(ib2_rd_entry_ptr_q) + 1)  when ib2_incr_ptr='1'   else
                      std_ulogic_vector(unsigned(ib2_rd_entry_ptr_q) - 1)  when ib2_decr_ptr='1' else
                      std_ulogic_vector(unsigned(ib2_rd_entry_ptr_q) - 2)  when ib2_decr_ptr_by2='1' else
                      std_ulogic_vector(unsigned(ib2_rd_entry_ptr_q) - 3)  when ib2_decr_ptr_by3='1' else
                      ib2_rd_entry_ptr_q(0 to 1);

ib3_decr_ptr     <= (ex4_ib3_flushed & ex5_ib3_flushed & ex6_ib3_flushed = "100") or 
                    (ex4_ib3_flushed & ex5_ib3_flushed & ex6_ib3_flushed = "010") or
                    (ex4_ib3_flushed & ex5_ib3_flushed & ex6_ib3_flushed = "001");

ib3_decr_ptr_by2 <= (ex4_ib3_flushed & ex5_ib3_flushed & ex6_ib3_flushed = "110") or
                    (ex4_ib3_flushed & ex5_ib3_flushed & ex6_ib3_flushed = "101") or
                    (ex4_ib3_flushed & ex5_ib3_flushed & ex6_ib3_flushed = "011");

ib3_decr_ptr_by3 <= ex4_ib3_flushed & ex5_ib3_flushed & ex6_ib3_flushed = "111";

ib3_rd_entry_ptr_d <= std_ulogic_vector(unsigned(ib3_rd_entry_ptr_q) + 1)  when ib3_incr_ptr='1'   else
                      std_ulogic_vector(unsigned(ib3_rd_entry_ptr_q) - 1)  when ib3_decr_ptr='1' else
                      std_ulogic_vector(unsigned(ib3_rd_entry_ptr_q) - 2)  when ib3_decr_ptr_by2='1' else
                      std_ulogic_vector(unsigned(ib3_rd_entry_ptr_q) - 3)  when ib3_decr_ptr_by3='1' else
                      ib3_rd_entry_ptr_q(0 to 1);

latch_ib0_rd_entry_ptr : tri_rlmreg_p
  generic map (width => ib0_rd_entry_ptr_q'length, init => 0, expand_type => expand_type)
  port map (nclk    => nclk,
            act     => mtdp_ex3_to_7_val,
            forcee   => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(ib0_rd_entry_ptr_offset to ib0_rd_entry_ptr_offset + ib0_rd_entry_ptr_q'length-1),
            scout   => sov(ib0_rd_entry_ptr_offset to ib0_rd_entry_ptr_offset + ib0_rd_entry_ptr_q'length-1),
            din     => ib0_rd_entry_ptr_d(0 to 1),
            dout    => ib0_rd_entry_ptr_q(0 to 1) );

latch_ib1_rd_entry_ptr : tri_rlmreg_p
  generic map (width => ib1_rd_entry_ptr_q'length, init => 0, expand_type => expand_type)
  port map (nclk    => nclk,
            act     => mtdp_ex3_to_7_val,
            forcee   => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(ib1_rd_entry_ptr_offset to ib1_rd_entry_ptr_offset + ib1_rd_entry_ptr_q'length-1),
            scout   => sov(ib1_rd_entry_ptr_offset to ib1_rd_entry_ptr_offset + ib1_rd_entry_ptr_q'length-1),
            din     => ib1_rd_entry_ptr_d(0 to 1),
            dout    => ib1_rd_entry_ptr_q(0 to 1) );

latch_ib2_rd_entry_ptr : tri_rlmreg_p
  generic map (width => ib2_rd_entry_ptr_q'length, init => 0, expand_type => expand_type)
  port map (nclk    => nclk,
            act     => mtdp_ex3_to_7_val,
            forcee   => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(ib2_rd_entry_ptr_offset to ib2_rd_entry_ptr_offset + ib2_rd_entry_ptr_q'length-1),
            scout   => sov(ib2_rd_entry_ptr_offset to ib2_rd_entry_ptr_offset + ib2_rd_entry_ptr_q'length-1),
            din     => ib2_rd_entry_ptr_d(0 to 1),
            dout    => ib2_rd_entry_ptr_q(0 to 1) );

latch_ib3_rd_entry_ptr : tri_rlmreg_p
  generic map (width => ib3_rd_entry_ptr_q'length, init => 0, expand_type => expand_type)
  port map (nclk    => nclk,
            act     => mtdp_ex3_to_7_val,
            forcee   => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(ib3_rd_entry_ptr_offset to ib3_rd_entry_ptr_offset + ib3_rd_entry_ptr_q'length-1),
            scout   => sov(ib3_rd_entry_ptr_offset to ib3_rd_entry_ptr_offset + ib3_rd_entry_ptr_q'length-1),
            din     => ib3_rd_entry_ptr_d(0 to 1),
            dout    => ib3_rd_entry_ptr_q(0 to 1) );

latch_ib0_rd_entry_ptr_dly : tri_rlmreg_p
  generic map (width => ib0_rd_entry_ptr_dly_q'length, init => 0, expand_type => expand_type)
  port map (nclk    => nclk,
            act     => mtdp_ex3_to_7_val,
            forcee   => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(ib0_rd_entry_ptr_dly_offset to ib0_rd_entry_ptr_dly_offset + ib0_rd_entry_ptr_dly_q'length-1),
            scout   => sov(ib0_rd_entry_ptr_dly_offset to ib0_rd_entry_ptr_dly_offset + ib0_rd_entry_ptr_dly_q'length-1),
            din     => ib0_rd_entry_ptr_q(0 to 1),
            dout    => ib0_rd_entry_ptr_dly_q(0 to 1) );

latch_ib1_rd_entry_ptr_dly : tri_rlmreg_p
  generic map (width => ib1_rd_entry_ptr_dly_q'length, init => 0, expand_type => expand_type)
  port map (nclk    => nclk,
            act     => mtdp_ex3_to_7_val,
            forcee   => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(ib1_rd_entry_ptr_dly_offset to ib1_rd_entry_ptr_dly_offset + ib1_rd_entry_ptr_dly_q'length-1),
            scout   => sov(ib1_rd_entry_ptr_dly_offset to ib1_rd_entry_ptr_dly_offset + ib1_rd_entry_ptr_dly_q'length-1),
            din     => ib1_rd_entry_ptr_q(0 to 1),
            dout    => ib1_rd_entry_ptr_dly_q(0 to 1) );

latch_ib2_rd_entry_ptr_dly : tri_rlmreg_p
  generic map (width => ib2_rd_entry_ptr_dly_q'length, init => 0, expand_type => expand_type)
  port map (nclk    => nclk,
            act     => mtdp_ex3_to_7_val,
            forcee   => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(ib2_rd_entry_ptr_dly_offset to ib2_rd_entry_ptr_dly_offset + ib2_rd_entry_ptr_dly_q'length-1),
            scout   => sov(ib2_rd_entry_ptr_dly_offset to ib2_rd_entry_ptr_dly_offset + ib2_rd_entry_ptr_dly_q'length-1),
            din     => ib2_rd_entry_ptr_q(0 to 1),
            dout    => ib2_rd_entry_ptr_dly_q(0 to 1) );

latch_ib3_rd_entry_ptr_dly : tri_rlmreg_p
  generic map (width => ib3_rd_entry_ptr_dly_q'length, init => 0, expand_type => expand_type)
  port map (nclk    => nclk,
            act     => mtdp_ex3_to_7_val,
            forcee   => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(ib3_rd_entry_ptr_dly_offset to ib3_rd_entry_ptr_dly_offset + ib3_rd_entry_ptr_dly_q'length-1),
            scout   => sov(ib3_rd_entry_ptr_dly_offset to ib3_rd_entry_ptr_dly_offset + ib3_rd_entry_ptr_dly_q'length-1),
            din     => ib3_rd_entry_ptr_q(0 to 1),
            dout    => ib3_rd_entry_ptr_dly_q(0 to 1) );

--**********************************************************************************************
-- use thread id to select one of the inbox read pointers to use in the inbox array read address
--**********************************************************************************************

with ex2_ipc_thrd_q(0 to 1) select 
   ib_rd_entry_ptr(0 to 1) <= ib0_rd_entry_ptr_d(0 to 1)   when "00",
                              ib1_rd_entry_ptr_d(0 to 1)   when "01", 
                              ib2_rd_entry_ptr_d(0 to 1)   when "10", 
                              ib3_rd_entry_ptr_d(0 to 1)   when others;

ib_ary_rd_addr(0 to 5) <= ex2_ipc_thrd_q(0 to 1) & ib_rd_entry_ptr(0 to 1) & xu_bx_ex2_ipc_ba(1 to 2);


--****************************************************************************
-- inbox error inject
--****************************************************************************

latch_ib_err_inj : tri_rlmreg_p
  generic map (width => 1, init => 0, expand_type => expand_type)
  port map (nclk    => nclk,
            act     => '1',
            forcee   => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(ib_err_inj_offset to ib_err_inj_offset),
            scout   => sov(ib_err_inj_offset to ib_err_inj_offset),
            din(0)  => pc_bx_inj_inbox_ecc,
            dout(0) => ib_err_inj_q );

lat_reld_data_0 <= lat_reld_data(0) xor ib_err_inj_q;

--****************************************************************************
-- inbox array
--****************************************************************************

ib_array:  entity tri.tri_64x42_4w_1r1w(tri_64x42_4w_1r1w)
  generic map ( expand_type => expand_type )
  port map(
-- functional ports
    wr_way               => ib_ary_wen(0 to 3),
    wr_adr               => ib_ary_wrt_addr(0 to 5),

    di(0)                => lat_reld_data_0,
    di(1 to 31)          => lat_reld_data(1 to 31),
    di(32 to 38)         => ib_datain_ecc0(0 to 6),
    di(39 to 41)         => "000",

    di(42 to 73)         => lat_reld_data(32 to 63),
    di(74 to 80)         => ib_datain_ecc1(0 to 6),
    di(81 to 83)         => "000",

    di(84 to 115)        => lat_reld_data(64 to 95),
    di(116 to 122)       => ib_datain_ecc2(0 to 6),
    di(123 to 125)       => "000",

    di(126 to 157)       => lat_reld_data(96 to 127),
    di(158 to 164)       => ib_datain_ecc3(0 to 6),
    di(165 to 167)       => "000",

    rd0_adr              => ib_ary_rd_addr(0 to 5),

    do0(0 to 31)         => ib_rd_data(0 to 31),
    do0(32 to 38)        => ib_rd_data_ecc0(0 to 6),
    do0(39 to 41)        => unused(12 to 14),

    do0(42 to 73)        => ib_rd_data(32 to 63),
    do0(74 to 80)        => ib_rd_data_ecc1(0 to 6),
    do0(81 to 83)        => unused(15 to 17),

    do0(84 to 115)       => ib_rd_data(64 to 95),
    do0(116 to 122)      => ib_rd_data_ecc2(0 to 6),
    do0(123 to 125)      => unused(18 to 20),

    do0(126 to 157)      => ib_rd_data(96 to 127),
    do0(158 to 164)      => ib_rd_data_ecc3(0 to 6),
    do0(165 to 167)      => unused(21 to 23),

   -- ABIST
   abist_di              => abist_di_0,
   abist_bw_odd          => abist_g8t_bw_1,
   abist_bw_even         => abist_g8t_bw_0,
   abist_wr_adr          => abist_waddr_0(4 to 9),
   wr_abst_act           => abist_g8t_wenb,
   abist_rd0_adr         => abist_raddr_0(4 to 9),
   rd0_abst_act          => abist_g8t1p_renb_0,
   tc_lbist_ary_wrt_thru_dc => an_ac_lbist_ary_wrt_thru_dc,
   abist_ena_1           => pc_bx_abist_ena_dc,
   abist_g8t_rd0_comp_ena => abist_wl64_comp_ena,
   abist_raw_dc_b        => pc_bx_abist_raw_dc_b,
   obs0_abist_cmp        => abist_g8t_dcomp,

   -- BOLT-ON
   lcb_bolt_sl_thold_0   => bolt_sl_thold_0,
   pc_bo_enable_2        => bolt_enable_2,
   pc_bo_reset           => pc_bx_bo_reset,
   pc_bo_unload          => pc_bx_bo_unload,
   pc_bo_repair          => pc_bx_bo_repair,
   pc_bo_shdata          => pc_bx_bo_shdata,
   pc_bo_select          => pc_bx_bo_select(2 to 3),
   bo_pc_failout         => bx_pc_bo_fail(2 to 3),
   bo_pc_diagloop        => bx_pc_bo_diagout(2 to 3),
   tri_lcb_mpw1_dc_b     => mpw1_dc_b,
   tri_lcb_mpw2_dc_b     => mpw2_dc_b,
   tri_lcb_delay_lclkr_dc => delay_lclkr_dc,
   tri_lcb_clkoff_dc_b  => clkoff_dc_b,
   tri_lcb_act_dis_dc   => tidn,

-- pervasive ports
    gnd                 => gnd,
    vdd                 => vdd,
    vcs                 => vcs,
    nclk                => nclk,
    rd0_act             => ex2_mfdp_val_q,
    wr_act              => reld_data_val,
    sg_0                => sg_0,
    abst_sl_thold_0     => abst_sl_thold_0,
    ary_nsl_thold_0     => ary_slp_nsl_thold_0,
    time_sl_thold_0     => time_sl_thold_0,
    repr_sl_thold_0     => repr_sl_thold_0,
    scan_dis_dc_b       => an_ac_scan_dis_dc_b,
    scan_diag_dc        => an_ac_scan_diag_dc,
    ccflush_dc          => pc_bx_ccflush_dc,

    ary0_clkoff_dc_b    => ary0_clkoff_dc_b,
    ary0_d_mode_dc      => ary0_d_mode_dc,
    ary0_mpw1_dc_b      => ary0_mpw1_dc_b_v,
    ary0_mpw2_dc_b      => ary0_mpw2_dc_b,
    ary0_delay_lclkr_dc => ary0_delay_lclkr_dc_v,

    ary1_clkoff_dc_b    => ary1_clkoff_dc_b,
    ary1_d_mode_dc      => ary1_d_mode_dc,
    ary1_mpw1_dc_b      => ary1_mpw1_dc_b_v,
    ary1_mpw2_dc_b      => ary1_mpw2_dc_b,
    ary1_delay_lclkr_dc => ary1_delay_lclkr_dc_v,

    abst_scan_in        => ob_abst_scan_out,
    time_scan_in        => ob_time_scan_out,
    repr_scan_in        => ob_repr_scan_out,
    abst_scan_out       => ib_abst_scan_out,
    time_scan_out       => ib_time_scan_out,
    repr_scan_out       => int_repr_scan_out
);




ib_do_eccgen0:  entity work.xuq_eccgen(xuq_eccgen)
   generic map ( regsize => 32 )
   port map(din(0 to 31)  => ex4_inbox_data(0 to 31),
            din(32 to 38) => ex4_ib_data_ecc0,
            syn           => ib_rd_data_nsyn0  );

ib_do_eccgen1:  entity work.xuq_eccgen(xuq_eccgen)
   generic map ( regsize => 32 )
   port map(din(0 to 31)  => ex4_inbox_data(32 to 63),
            din(32 to 38) => ex4_ib_data_ecc1,
            syn           => ib_rd_data_nsyn1  );

ib_do_eccgen2:  entity work.xuq_eccgen(xuq_eccgen)
   generic map ( regsize => 32 )
   port map(din(0 to 31)  => ex4_inbox_data(64 to 95),
            din(32 to 38) => ex4_ib_data_ecc2,
            syn           => ib_rd_data_nsyn2  );

ib_do_eccgen3:  entity work.xuq_eccgen(xuq_eccgen)
   generic map ( regsize => 32 )
   port map(din(0 to 31)  => ex4_inbox_data(96 to 127),
            din(32 to 38) => ex4_ib_data_ecc3,
            syn           => ib_rd_data_nsyn3  );


ib_di_eccchk0:  entity work.xuq_eccchk(xuq_eccchk)
   generic map ( regsize => 32 )
   port map(din    => ex4_inbox_data(0 to 31),
            EnCorr => '1',
            NSyn   => ib_rd_data_nsyn0,
            Corrd  => ib_rd_data_cor(0 to 31),
            sbe    => ib_ary_sbe(0),
            ue     => ib_ary_ue(0)  );

ib_di_eccchk1:  entity work.xuq_eccchk(xuq_eccchk)
   generic map ( regsize => 32 )
   port map(din    => ex4_inbox_data(32 to 63),
            EnCorr => '1',
            NSyn   => ib_rd_data_nsyn1,
            Corrd  => ib_rd_data_cor(32 to 63),
            sbe    => ib_ary_sbe(1),
            ue     => ib_ary_ue(1)  );

ib_di_eccchk2:  entity work.xuq_eccchk(xuq_eccchk)
   generic map ( regsize => 32 )
   port map(din    => ex4_inbox_data(64 to 95),
            EnCorr => '1',
            NSyn   => ib_rd_data_nsyn2,
            Corrd  => ib_rd_data_cor(64 to 95),
            sbe    => ib_ary_sbe(2),
            ue     => ib_ary_ue(2)  );

ib_di_eccchk3:  entity work.xuq_eccchk(xuq_eccchk)
   generic map ( regsize => 32 )
   port map(din    => ex4_inbox_data(96 to 127),
            EnCorr => '1',
            NSyn   => ib_rd_data_nsyn3,
            Corrd  => ib_rd_data_cor(96 to 127),
            sbe    => ib_ary_sbe(3),
            ue     => ib_ary_ue(3)  );

latch_ex5_inbox_data_cor : tri_rlmreg_p
  generic map (width => ex5_inbox_data_cor'length, init => 0, expand_type => expand_type)
  port map (nclk    => nclk,
            act     => ex4_mfdp_val_q,
            forcee   => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(ex5_inbox_data_cor_offset to ex5_inbox_data_cor_offset + ex5_inbox_data_cor'length-1),
            scout   => sov(ex5_inbox_data_cor_offset to ex5_inbox_data_cor_offset + ex5_inbox_data_cor'length-1),
            din     => ib_rd_data_cor(0 to 127),
            dout    => ex5_inbox_data_cor(0 to 127) );

latch_ib_ary_sbe : tri_rlmreg_p
  generic map (width => ib_ary_sbe_q'length, init => 0, expand_type => expand_type)
  port map (nclk    => nclk,
            act     => ex4_mfdp_val_q,
            forcee   => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(ib_ary_sbe_offset to ib_ary_sbe_offset + ib_ary_sbe_q'length-1),
            scout   => sov(ib_ary_sbe_offset to ib_ary_sbe_offset + ib_ary_sbe_q'length-1),
            din     => ib_ary_sbe(0 to 3),
            dout    => ib_ary_sbe_q(0 to 3) );

latch_ib_ary_ue : tri_rlmreg_p
  generic map (width => ib_ary_ue_q'length, init => 0, expand_type => expand_type)
  port map (nclk    => nclk,
            act     => ex4_mfdp_val_q,
            forcee   => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(ib_ary_ue_offset to ib_ary_ue_offset + ib_ary_ue_q'length-1),
            scout   => sov(ib_ary_ue_offset to ib_ary_ue_offset + ib_ary_ue_q'length-1),
            din     => ib_ary_ue(0 to 3),
            dout    => ib_ary_ue_q(0 to 3) );

ib_ary_sbe_or <= (ib_ary_sbe_q(0) or ib_ary_sbe_q(1) or ib_ary_sbe_q(2) or ib_ary_sbe_q(3)) and ex5_ib_ecc_val;

ib_ary_ue_or <= (ib_ary_ue_q(0) or ib_ary_ue_q(1) or ib_ary_ue_q(2) or ib_ary_ue_q(3)) and ex5_ib_ecc_val;

-- latch read address(0:1) (thread select bits) to use for parity error detection


latch_inbox_ecc_err : tri_rlmreg_p
  generic map (width =>  1, init => 0, expand_type => expand_type)  
  port map (nclk    => nclk,
            act     => dp_op_val,
            forcee   => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(inbox_ecc_err_offset to inbox_ecc_err_offset),
            scout   => sov(inbox_ecc_err_offset to inbox_ecc_err_offset),
            din(0)  => ib_ary_sbe_or,
            dout(0) => inbox_ecc_err_q );

latch_inbox_ue : tri_rlmreg_p
  generic map (width =>  1, init => 0, expand_type => expand_type)  
  port map (nclk    => nclk,
            act     => dp_op_val,
            forcee   => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(inbox_ue_offset to inbox_ue_offset),
            scout   => sov(inbox_ue_offset to inbox_ue_offset),
            din(0)  => ib_ary_ue_or,
            dout(0) => inbox_ue_q );

   inbox_err_rpt : entity tri.tri_direct_err_rpt
     generic map
      (  width          => 2
       , expand_type    => expand_type
      ) 
     port map
      ( vd    => vdd
      , gd    => gnd
      , err_in(0)       => inbox_ecc_err_q
      , err_in(1)       => inbox_ue_q
      , err_out(0)      => bx_pc_err_inbox_ecc
      , err_out(1)      => bx_pc_err_inbox_ue
     );

--****************************************************************************
-- use read pointer to select status register for each thread
--****************************************************************************

with ib0_rd_entry_ptr_q(0 to 1) select
   ib0_rd_val_reg <= (ib0_buf0_val_q and not ib0_buf0_reset_val)   when "00",
                     (ib0_buf1_val_q and not ib0_buf1_reset_val)   when "01",
                     (ib0_buf2_val_q and not ib0_buf2_reset_val)   when "10",
                     (ib0_buf3_val_q and not ib0_buf3_reset_val)   when others;

with ib1_rd_entry_ptr_q(0 to 1) select
   ib1_rd_val_reg <= (ib1_buf0_val_q and not ib1_buf0_reset_val)   when "00",
                     (ib1_buf1_val_q and not ib1_buf1_reset_val)   when "01",
                     (ib1_buf2_val_q and not ib1_buf2_reset_val)   when "10",
                     (ib1_buf3_val_q and not ib1_buf3_reset_val)   when others;

with ib2_rd_entry_ptr_q(0 to 1) select
   ib2_rd_val_reg <= (ib2_buf0_val_q and not ib2_buf0_reset_val)   when "00",
                     (ib2_buf1_val_q and not ib2_buf1_reset_val)   when "01",
                     (ib2_buf2_val_q and not ib2_buf2_reset_val)   when "10",
                     (ib2_buf3_val_q and not ib2_buf3_reset_val)   when others;

with ib3_rd_entry_ptr_q(0 to 1) select
   ib3_rd_val_reg <= (ib3_buf0_val_q and not ib3_buf0_reset_val)   when "00",
                     (ib3_buf1_val_q and not ib3_buf1_reset_val)   when "01",
                     (ib3_buf2_val_q and not ib3_buf2_reset_val)   when "10",
                     (ib3_buf3_val_q and not ib3_buf3_reset_val)   when others;


--****************************************************************************
-- stage thread and ba to ex4 for mfdp status reg mux controls
--****************************************************************************


latch_ex4_ipc_thrd : tri_rlmreg_p
  generic map (width => ex4_ipc_thrd_q'length, init => 0, expand_type => expand_type)
  port map (nclk    => nclk,
            act     => dp_op_val,
            forcee   => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(ex4_ipc_thrd_offset to ex4_ipc_thrd_offset + ex4_ipc_thrd_q'length-1),
            scout   => sov(ex4_ipc_thrd_offset to ex4_ipc_thrd_offset + ex4_ipc_thrd_q'length-1),
            din     => ex3_ipc_thrd_q(0 to 1),
            dout    => ex4_ipc_thrd_q(0 to 1) );

latch_ex5_ipc_thrd : tri_rlmreg_p
  generic map (width => ex5_ipc_thrd_q'length, init => 0, expand_type => expand_type)
  port map (nclk    => nclk,
            act     => dp_op_val,
            forcee   => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(ex5_ipc_thrd_offset to ex5_ipc_thrd_offset + ex5_ipc_thrd_q'length-1),
            scout   => sov(ex5_ipc_thrd_offset to ex5_ipc_thrd_offset + ex5_ipc_thrd_q'length-1),
            din     => ex4_ipc_thrd_q(0 to 1),
            dout    => ex5_ipc_thrd_q(0 to 1) );

latch_ex6_ipc_thrd : tri_rlmreg_p
  generic map (width => ex6_ipc_thrd_q'length, init => 0, expand_type => expand_type)
  port map (nclk    => nclk,
            act     => dp_op_val,
            forcee   => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(ex6_ipc_thrd_offset to ex6_ipc_thrd_offset + ex6_ipc_thrd_q'length-1),
            scout   => sov(ex6_ipc_thrd_offset to ex6_ipc_thrd_offset + ex6_ipc_thrd_q'length-1),
            din     => ex5_ipc_thrd_q(0 to 1),
            dout    => ex6_ipc_thrd_q(0 to 1) );

latch_ex4_ipc_ba : tri_rlmreg_p
  generic map (width => ex4_ipc_ba_q'length, init => 0, expand_type => expand_type)
  port map (nclk    => nclk,
            act     => dp_op_val,
            forcee   => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(ex4_ipc_ba_offset to ex4_ipc_ba_offset + ex4_ipc_ba_q'length-1),
            scout   => sov(ex4_ipc_ba_offset to ex4_ipc_ba_offset + ex4_ipc_ba_q'length-1),
            din     => ex3_ipc_ba_q(0 to 4),
            dout    => ex4_ipc_ba_q(0 to 4) );

latch_ex4_ipc_sz : tri_rlmreg_p
  generic map (width => ex4_ipc_sz_q'length, init => 0, expand_type => expand_type)
  port map (nclk    => nclk,
            act     => dp_op_val,
            forcee   => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(ex4_ipc_sz_offset to ex4_ipc_sz_offset + ex4_ipc_sz_q'length-1),
            scout   => sov(ex4_ipc_sz_offset to ex4_ipc_sz_offset + ex4_ipc_sz_q'length-1),
            din     => ex3_ipc_sz_q(0 to 1),
            dout    => ex4_ipc_sz_q(0 to 1) );

--****************************************************************************
-- use thread id to select which threads status reg to return
--****************************************************************************

with ex4_ipc_thrd_q(0 to 1) select 
   ex4_ib_rd_status_reg <= ib0_rd_val_reg    when "00",
                           ib1_rd_val_reg    when "01", 
                           ib2_rd_val_reg    when "10", 
                           ib3_rd_val_reg    when others;


--****************************************************************************
-- return data to the processor on a mfdp op
--****************************************************************************
ex3_data_w0_sel(0) <= (ex3_ipc_sz_q="00" and ex3_ipc_ba_q(3 to 4)="00" and ex3_ipc_ba_q(0)='0') or ex3_ipc_sz_q="10" or
                      (ex3_ipc_sz_q="01" and ex3_ipc_ba_q(3)='0');
ex3_data_w0_sel(1) <=  ex3_ipc_sz_q="00" and ex3_ipc_ba_q(3 to 4)="01";
ex3_data_w0_sel(2) <= (ex3_ipc_sz_q="00" and ex3_ipc_ba_q(3 to 4)="10") or
                      (ex3_ipc_sz_q="01" and ex3_ipc_ba_q(3)='1');
ex3_data_w0_sel(3) <=  ex3_ipc_sz_q="00" and ex3_ipc_ba_q(3 to 4)="11";
ex3_data_sel_status <= ex3_ipc_ba_q = "10000";
 
ex3_inbox_data(0 to 31) <= gate_and(ex3_data_w0_sel(0), ib_rd_data(0  to 31)) or
                           gate_and(ex3_data_w0_sel(1), ib_rd_data(32 to 63)) or
                           gate_and(ex3_data_w0_sel(2), ib_rd_data(64 to 95)) or
                           gate_and(ex3_data_w0_sel(3), ib_rd_data(96 to 127)) or
                           gate_and(ex3_data_sel_status, x"0000000" & "000" & ex4_ib_rd_status_reg);
 
ex3_ib_data_ecc0(0 to 6)<= gate_and(ex3_data_w0_sel(0), ib_rd_data_ecc0(0  to 6)) or
                           gate_and(ex3_data_w0_sel(1), ib_rd_data_ecc1(0  to 6)) or
                           gate_and(ex3_data_w0_sel(2), ib_rd_data_ecc2(0  to 6)) or
                           gate_and(ex3_data_w0_sel(3), ib_rd_data_ecc3(0  to 6));

ex3_data_w1_sel(0) <=  ex3_ipc_sz_q="00" and ex3_ipc_ba_q(3 to 4)="00" and ex3_ipc_ba_q(0)='0';
ex3_data_w1_sel(1) <= (ex3_ipc_sz_q="00" and ex3_ipc_ba_q(3 to 4)="01")  or ex3_ipc_sz_q="10" or 
                      (ex3_ipc_sz_q="01" and ex3_ipc_ba_q(3)='0');
ex3_data_w1_sel(2) <=  ex3_ipc_sz_q="00" and ex3_ipc_ba_q(3 to 4)="10";
ex3_data_w1_sel(3) <= (ex3_ipc_sz_q="00" and ex3_ipc_ba_q(3 to 4)="11") or 
                      (ex3_ipc_sz_q="01" and ex3_ipc_ba_q(3)='1');
 
ex3_inbox_data(32 to 63) <= gate_and(ex3_data_w1_sel(0), ib_rd_data(0  to 31)) or
                            gate_and(ex3_data_w1_sel(1), ib_rd_data(32 to 63)) or
                            gate_and(ex3_data_w1_sel(2), ib_rd_data(64 to 95)) or
                            gate_and(ex3_data_w1_sel(3), ib_rd_data(96 to 127)) or
                            gate_and(ex3_data_sel_status, x"0000000" & "000" & ex4_ib_rd_status_reg);
 
ex3_ib_data_ecc1(0 to 6)<= gate_and(ex3_data_w1_sel(0), ib_rd_data_ecc0(0  to 6)) or
                           gate_and(ex3_data_w1_sel(1), ib_rd_data_ecc1(0  to 6)) or
                           gate_and(ex3_data_w1_sel(2), ib_rd_data_ecc2(0  to 6)) or
                           gate_and(ex3_data_w1_sel(3), ib_rd_data_ecc3(0  to 6));

ex3_data_w2_sel(0) <= (ex3_ipc_sz_q="00" and ex3_ipc_ba_q(3 to 4)="00" and ex3_ipc_ba_q(0)='0') or 
                      (ex3_ipc_sz_q="01" and ex3_ipc_ba_q(3)='0');
ex3_data_w2_sel(1) <=  ex3_ipc_sz_q="00" and ex3_ipc_ba_q(3 to 4)="01";
ex3_data_w2_sel(2) <= (ex3_ipc_sz_q="00" and ex3_ipc_ba_q(3 to 4)="10")  or ex3_ipc_sz_q="10"  or 
                      (ex3_ipc_sz_q="01" and ex3_ipc_ba_q(3)='1');
ex3_data_w2_sel(3) <=  ex3_ipc_sz_q="00" and ex3_ipc_ba_q(3 to 4)="11";
 
ex3_inbox_data(64 to 95) <= gate_and(ex3_data_w2_sel(0), ib_rd_data(0  to 31)) or
                            gate_and(ex3_data_w2_sel(1), ib_rd_data(32 to 63)) or
                            gate_and(ex3_data_w2_sel(2), ib_rd_data(64 to 95)) or
                            gate_and(ex3_data_w2_sel(3), ib_rd_data(96 to 127)) or
                            gate_and(ex3_data_sel_status, x"0000000" & "000" & ex4_ib_rd_status_reg);
 
ex3_ib_data_ecc2(0 to 6)<= gate_and(ex3_data_w2_sel(0), ib_rd_data_ecc0(0  to 6)) or
                           gate_and(ex3_data_w2_sel(1), ib_rd_data_ecc1(0  to 6)) or
                           gate_and(ex3_data_w2_sel(2), ib_rd_data_ecc2(0  to 6)) or
                           gate_and(ex3_data_w2_sel(3), ib_rd_data_ecc3(0  to 6));

ex3_data_w3_sel(0) <=  ex3_ipc_sz_q="00" and ex3_ipc_ba_q(3 to 4)="00" and ex3_ipc_ba_q(0)='0';
ex3_data_w3_sel(1) <= (ex3_ipc_sz_q="00" and ex3_ipc_ba_q(3 to 4)="01") or 
                      (ex3_ipc_sz_q="01" and ex3_ipc_ba_q(3)='0');
ex3_data_w3_sel(2) <=  ex3_ipc_sz_q="00" and ex3_ipc_ba_q(3 to 4)="10";
ex3_data_w3_sel(3) <= (ex3_ipc_sz_q="00" and ex3_ipc_ba_q(3 to 4)="11")  or ex3_ipc_sz_q="10" or 
                      (ex3_ipc_sz_q="01" and ex3_ipc_ba_q(3)='1');

ex3_inbox_data(96 to 127) <= gate_and(ex3_data_w3_sel(0), ib_rd_data(0  to 31)) or
                             gate_and(ex3_data_w3_sel(1), ib_rd_data(32 to 63)) or
                             gate_and(ex3_data_w3_sel(2), ib_rd_data(64 to 95)) or
                             gate_and(ex3_data_w3_sel(3), ib_rd_data(96 to 127)) or
                             gate_and(ex3_data_sel_status, x"0000000" & "000" & ex4_ib_rd_status_reg);
 
ex3_ib_data_ecc3(0 to 6)<= gate_and(ex3_data_w3_sel(0), ib_rd_data_ecc0(0  to 6)) or
                           gate_and(ex3_data_w3_sel(1), ib_rd_data_ecc1(0  to 6)) or
                           gate_and(ex3_data_w3_sel(2), ib_rd_data_ecc2(0  to 6)) or
                           gate_and(ex3_data_w3_sel(3), ib_rd_data_ecc3(0  to 6));

-- latch data before returning it to xu

latch_ex4_dp_data : tri_rlmreg_p
  generic map (width => ex4_inbox_data'length, init => 0, expand_type => expand_type)
  port map (nclk    => nclk,
            act     => ex3_mfdp_val_q,
            forcee   => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(ex4_dp_data_offset to ex4_dp_data_offset + ex4_inbox_data'length-1),
            scout   => sov(ex4_dp_data_offset to ex4_dp_data_offset + ex4_inbox_data'length-1),
            din     => ex3_inbox_data(0 to 127),
            dout    => ex4_inbox_data(0 to 127) );


latch_ex4_ib_data_ecc0 : tri_rlmreg_p
  generic map (width => ex4_ib_data_ecc0'length, init => 0, expand_type => expand_type)
  port map (nclk    => nclk,
            act     => ex3_mfdp_val_q,
            forcee   => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(ex4_ib_data_ecc0_offset to ex4_ib_data_ecc0_offset + ex4_ib_data_ecc0'length-1),
            scout   => sov(ex4_ib_data_ecc0_offset to ex4_ib_data_ecc0_offset + ex4_ib_data_ecc0'length-1),
            din     => ex3_ib_data_ecc0(0 to 6),
            dout    => ex4_ib_data_ecc0(0 to 6) );

latch_ex4_ib_data_ecc1 : tri_rlmreg_p
  generic map (width => ex4_ib_data_ecc1'length, init => 0, expand_type => expand_type)
  port map (nclk    => nclk,
            act     => ex3_mfdp_val_q,
            forcee   => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(ex4_ib_data_ecc1_offset to ex4_ib_data_ecc1_offset + ex4_ib_data_ecc1'length-1),
            scout   => sov(ex4_ib_data_ecc1_offset to ex4_ib_data_ecc1_offset + ex4_ib_data_ecc1'length-1),
            din     => ex3_ib_data_ecc1(0 to 6),
            dout    => ex4_ib_data_ecc1(0 to 6) );

latch_ex4_ib_data_ecc2 : tri_rlmreg_p
  generic map (width => ex4_ib_data_ecc2'length, init => 0, expand_type => expand_type)
  port map (nclk    => nclk,
            act     => ex3_mfdp_val_q,
            forcee   => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(ex4_ib_data_ecc2_offset to ex4_ib_data_ecc2_offset + ex4_ib_data_ecc2'length-1),
            scout   => sov(ex4_ib_data_ecc2_offset to ex4_ib_data_ecc2_offset + ex4_ib_data_ecc2'length-1),
            din     => ex3_ib_data_ecc2(0 to 6),
            dout    => ex4_ib_data_ecc2(0 to 6) );

latch_ex4_ib_data_ecc3 : tri_rlmreg_p
  generic map (width => ex4_ib_data_ecc3'length, init => 0, expand_type => expand_type)
  port map (nclk    => nclk,
            act     => ex3_mfdp_val_q,
            forcee   => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(ex4_ib_data_ecc3_offset to ex4_ib_data_ecc3_offset + ex4_ib_data_ecc3'length-1),
            scout   => sov(ex4_ib_data_ecc3_offset to ex4_ib_data_ecc3_offset + ex4_ib_data_ecc3'length-1),
            din     => ex3_ib_data_ecc3(0 to 6),
            dout    => ex4_ib_data_ecc3(0 to 6) );

bx_xu_ex5_dp_data(0 to 127) <= ex5_inbox_data_cor(0 to 127);

ex3_mfdp_cr_status <= ex3_mfdp_val_q and ( (ib0_rd_val_reg and ex3_ipc_thrd_q="00") or      -- 1=mfdp pass, 0=mfdp fail
                                           (ib1_rd_val_reg and ex3_ipc_thrd_q="01") or 
                                           (ib2_rd_val_reg and ex3_ipc_thrd_q="10") or 
                                           (ib3_rd_val_reg and ex3_ipc_thrd_q="11"));

latch_ex4_mfdp_cr_status : tri_rlmreg_p
  generic map (width => 1, init => 0, expand_type => expand_type)
  port map (nclk    => nclk,
            act     => dp_op_val,
            forcee   => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(ex4_mfdp_cr_status_offset to ex4_mfdp_cr_status_offset),
            scout   => sov(ex4_mfdp_cr_status_offset to ex4_mfdp_cr_status_offset),
            din(0)  => ex3_mfdp_cr_status,
            dout(0) => ex4_mfdp_cr_status_i );

bx_xu_ex4_mfdp_cr_status <= ex4_mfdp_cr_status_i;


ex4_ib_ecc_val <= ex4_mfdp_cr_status_i and not ex4_ipc_ba_q(0);  -- mfdp valid and not status reg (data from array)

latch_ex5_ib_ecc_val : tri_rlmreg_p
  generic map (width => 1, init => 0, expand_type => expand_type)
  port map (nclk    => nclk,
            act     => dp_op_val,
            forcee   => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(ex5_ib_ecc_val_offset to ex5_ib_ecc_val_offset),
            scout   => sov(ex5_ib_ecc_val_offset to ex5_ib_ecc_val_offset),
            din(0)  => ex4_ib_ecc_val,
            dout(0) => ex5_ib_ecc_val );


--**********************************************************************************************
-- latch the inputs from the node/L2
--**********************************************************************************************

latch_reld_data_val_dminus2 : tri_rlmreg_p
  generic map (width => 1, init => 0, expand_type => expand_type)
  port map (nclk    => nclk,
            act     => '1',
            forcee   => func_slp_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_slp_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(reld_data_val_dminus2_offset to reld_data_val_dminus2_offset),
            scout   => sov(reld_data_val_dminus2_offset to reld_data_val_dminus2_offset),
            din(0)  => lsu_reld_data_vld,
            dout(0) => lat_reld_data_val );

latch_reld_ditc : tri_rlmreg_p
  generic map (width => 1, init => 0, expand_type => expand_type)
  port map (nclk    => nclk,
            act     => '1',
            forcee   => func_slp_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_slp_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(reld_ditc_offset to reld_ditc_offset),
            scout   => sov(reld_ditc_offset to reld_ditc_offset),
            din(0)  => lsu_reld_ditc,
            dout(0) => lat_reld_ditc );

latch_reld_ecc_err : tri_rlmreg_p
  generic map (width => 1, init => 0, expand_type => expand_type)
  port map (nclk    => nclk,
            act     => '1',
            forcee   => func_slp_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_slp_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(reld_ecc_err_offset to reld_ecc_err_offset),
            scout   => sov(reld_ecc_err_offset to reld_ecc_err_offset),
            din(0)  => lsu_reld_ecc_err,
            dout(0) => lat_reld_ecc_err );

reld_data_val_dminus2 <= lat_reld_data_val and lat_reld_ditc;

latch_reld_data_val_dminus1 : tri_rlmreg_p
  generic map (width => 1, init => 0, expand_type => expand_type)
  port map (nclk    => nclk,
            act     => '1',
            forcee   => func_slp_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_slp_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(reld_data_val_dminus1_offset to reld_data_val_dminus1_offset),
            scout   => sov(reld_data_val_dminus1_offset to reld_data_val_dminus1_offset),
            din(0)  => reld_data_val_dminus2,
            dout(0) => reld_data_val_dminus1 );

latch_reld_data_val : tri_rlmreg_p
  generic map (width => 1, init => 0, expand_type => expand_type)
  port map (nclk    => nclk,
            act     => '1',
            forcee   => func_slp_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_slp_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(reld_data_val_offset to reld_data_val_offset),
            scout   => sov(reld_data_val_offset to reld_data_val_offset),
            din(0)  => reld_data_val_dminus1,
            dout(0) => reld_data_val );

latch_reld_data_val_dplus1 : tri_rlmreg_p
  generic map (width => 1, init => 0, expand_type => expand_type)
  port map (nclk    => nclk,
            act     => '1',
            forcee   => func_slp_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_slp_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(reld_data_val_dplus1_offset to reld_data_val_dplus1_offset),
            scout   => sov(reld_data_val_dplus1_offset to reld_data_val_dplus1_offset),
            din(0)  => reld_data_val,
            dout(0) => reld_data_val_dplus1 );

latch_reld_core_tag_dminus2 : tri_rlmreg_p
  generic map (width => lat_reld_core_tag'length, init => 0, expand_type => expand_type)
  port map (nclk    => nclk,
            act     => '1',
            forcee   => func_slp_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_slp_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(reld_core_tag_dminus2_offset to reld_core_tag_dminus2_offset + lat_reld_core_tag'length-1),
            scout   => sov(reld_core_tag_dminus2_offset to reld_core_tag_dminus2_offset + lat_reld_core_tag'length-1),
            din     => lsu_reld_core_tag,
            dout    => lat_reld_core_tag );
 
latch_reld_core_tag_dminus1 : tri_rlmreg_p
  generic map (width => reld_core_tag_dminus1'length, init => 0, expand_type => expand_type)
  port map (nclk    => nclk,
            act     => '1',
            forcee   => func_slp_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_slp_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(reld_core_tag_dminus1_offset to reld_core_tag_dminus1_offset + reld_core_tag_dminus1'length-1),
            scout   => sov(reld_core_tag_dminus1_offset to reld_core_tag_dminus1_offset + reld_core_tag_dminus1'length-1),
            din     => lat_reld_core_tag,
            dout    => reld_core_tag_dminus1 );
 
latch_reld_core_tag : tri_rlmreg_p
  generic map (width => reld_core_tag'length, init => 0, expand_type => expand_type)
  port map (nclk    => nclk,
            act     => '1',
            forcee   => func_slp_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_slp_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(reld_core_tag_offset to reld_core_tag_offset + reld_core_tag'length-1),
            scout   => sov(reld_core_tag_offset to reld_core_tag_offset + reld_core_tag'length-1),
            din     => reld_core_tag_dminus1,
            dout    => reld_core_tag );
 
latch_reld_core_tag_dplus1 : tri_rlmreg_p
  generic map (width => reld_core_tag_dplus1'length, init => 0, expand_type => expand_type)
  port map (nclk    => nclk,
            act     => '1',
            forcee   => func_slp_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_slp_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(reld_core_tag_dplus1_offset to reld_core_tag_dplus1_offset + reld_core_tag_dplus1'length-1),
            scout   => sov(reld_core_tag_dplus1_offset to reld_core_tag_dplus1_offset + reld_core_tag_dplus1'length-1),
            din     => reld_core_tag,
            dout    => reld_core_tag_dplus1 );

latch_reld_qw_dminus2 : tri_rlmreg_p
  generic map (width => lat_reld_qw'length, init => 0, expand_type => expand_type)
  port map (nclk    => nclk,
            act     => '1',
            forcee   => func_slp_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_slp_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(reld_qw_dminus2_offset to reld_qw_dminus2_offset + lat_reld_qw'length-1),
            scout   => sov(reld_qw_dminus2_offset to reld_qw_dminus2_offset + lat_reld_qw'length-1),
            din     => lsu_reld_qw,
            dout    => lat_reld_qw );
 
latch_reld_qw_dminus1 : tri_rlmreg_p
  generic map (width => reld_qw_dminus1'length, init => 0, expand_type => expand_type)
  port map (nclk    => nclk,
            act     => '1',
            forcee   => func_slp_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_slp_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(reld_qw_dminus1_offset to reld_qw_dminus1_offset + reld_qw_dminus1'length-1),
            scout   => sov(reld_qw_dminus1_offset to reld_qw_dminus1_offset + reld_qw_dminus1'length-1),
            din     => lat_reld_qw,
            dout    => reld_qw_dminus1 );
 
latch_reld_qw : tri_rlmreg_p
  generic map (width => reld_qw'length, init => 0, expand_type => expand_type)
  port map (nclk    => nclk,
            act     => '1',
            forcee   => func_slp_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_slp_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(reld_qw_offset to reld_qw_offset + reld_qw'length-1),
            scout   => sov(reld_qw_offset to reld_qw_offset + reld_qw'length-1),
            din     => reld_qw_dminus1,
            dout    => reld_qw );

latch_reld_data : tri_rlmreg_p
  generic map (width => lat_reld_data'length, init => 0, expand_type => expand_type)
  port map (nclk    => nclk,
            act     => reld_data_val_dminus1,
            forcee   => func_slp_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_slp_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(reld_data_offset to reld_data_offset + lat_reld_data'length-1),
            scout   => sov(reld_data_offset to reld_data_offset + lat_reld_data'length-1),
            din     => lsu_reld_data,
            dout    => lat_reld_data );

--****************************************************************************
-- Generate ECC for IB array write data
--****************************************************************************


ib_di_eccgen0:  entity work.xuq_eccgen(xuq_eccgen)
   generic map ( regsize => 32 )
   port map(din(0 to 31)  => lat_reld_data(0 to 31),
            din(32 to 38) => "1111111",
            syn           => ib_datain_ecc0  );

ib_di_eccgen1:  entity work.xuq_eccgen(xuq_eccgen)
   generic map ( regsize => 32 )
   port map(din(0 to 31)  => lat_reld_data(32 to 63),
            din(32 to 38) => "1111111",
            syn           => ib_datain_ecc1  );

ib_di_eccgen2:  entity work.xuq_eccgen(xuq_eccgen)
   generic map ( regsize => 32 )
   port map(din(0 to 31)  => lat_reld_data(64 to 95),
            din(32 to 38) => "1111111",
            syn           => ib_datain_ecc2  );

ib_di_eccgen3:  entity work.xuq_eccgen(xuq_eccgen)
   generic map ( regsize => 32 )
   port map(din(0 to 31)  => lat_reld_data(96 to 127),
            din(32 to 38) => "1111111",
            syn           => ib_datain_ecc3  );

--**********************************************************************************************
-- increment inbox buffer write pointer when the status register is written valid from nd_to_ib
-- there is one buffer pointer per thread
--**********************************************************************************************

ib0_wrt_entry_ptr_minus1 <= std_ulogic_vector(unsigned(ib0_wrt_entry_ptr_q) - 1);
ib1_wrt_entry_ptr_minus1 <= std_ulogic_vector(unsigned(ib1_wrt_entry_ptr_q) - 1);
ib2_wrt_entry_ptr_minus1 <= std_ulogic_vector(unsigned(ib2_wrt_entry_ptr_q) - 1);
ib3_wrt_entry_ptr_minus1 <= std_ulogic_vector(unsigned(ib3_wrt_entry_ptr_q) - 1);

dec_ib0_wrt_entry_ptr <= ib0_set_val_q and lat_reld_ecc_err;
dec_ib1_wrt_entry_ptr <= ib1_set_val_q and lat_reld_ecc_err;
dec_ib2_wrt_entry_ptr <= ib2_set_val_q and lat_reld_ecc_err;
dec_ib3_wrt_entry_ptr <= ib3_set_val_q and lat_reld_ecc_err;

ib0_wrt_entry_ptr_d <= std_ulogic_vector(unsigned(ib0_wrt_entry_ptr_q) + 1)  when ib0_set_val='1'             else
                       std_ulogic_vector(unsigned(ib0_wrt_entry_ptr_q) - 1)  when dec_ib0_wrt_entry_ptr='1'   else
                       ib0_wrt_entry_ptr_q(0 to 1);

ib1_wrt_entry_ptr_d <= std_ulogic_vector(unsigned(ib1_wrt_entry_ptr_q) + 1)  when ib1_set_val='1'   else
                       std_ulogic_vector(unsigned(ib1_wrt_entry_ptr_q) - 1)  when dec_ib1_wrt_entry_ptr='1'   else
                       ib1_wrt_entry_ptr_q(0 to 1);

ib2_wrt_entry_ptr_d <= std_ulogic_vector(unsigned(ib2_wrt_entry_ptr_q) + 1)  when ib2_set_val='1'   else
                       std_ulogic_vector(unsigned(ib2_wrt_entry_ptr_q) - 1)  when dec_ib2_wrt_entry_ptr='1'   else
                       ib2_wrt_entry_ptr_q(0 to 1);

ib3_wrt_entry_ptr_d <= std_ulogic_vector(unsigned(ib3_wrt_entry_ptr_q) + 1)  when ib3_set_val='1'   else
                       std_ulogic_vector(unsigned(ib3_wrt_entry_ptr_q) - 1)  when dec_ib3_wrt_entry_ptr='1'   else
                       ib3_wrt_entry_ptr_q(0 to 1);


latch_ib0_wrt_entry_ptr : tri_rlmreg_p
  generic map (width => ib0_wrt_entry_ptr_q'length, init => 0, expand_type => expand_type)
  port map (nclk    => nclk,
            act     => reld_data_val,
            forcee   => func_slp_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_slp_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(ib0_wrt_entry_ptr_offset to ib0_wrt_entry_ptr_offset + ib0_wrt_entry_ptr_q'length-1),
            scout   => sov(ib0_wrt_entry_ptr_offset to ib0_wrt_entry_ptr_offset + ib0_wrt_entry_ptr_q'length-1),
            din     => ib0_wrt_entry_ptr_d(0 to 1),
            dout    => ib0_wrt_entry_ptr_q(0 to 1) );

latch_ib1_wrt_entry_ptr : tri_rlmreg_p
  generic map (width => ib1_wrt_entry_ptr_q'length, init => 0, expand_type => expand_type)
  port map (nclk    => nclk,
            act     => reld_data_val,
            forcee   => func_slp_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_slp_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(ib1_wrt_entry_ptr_offset to ib1_wrt_entry_ptr_offset + ib1_wrt_entry_ptr_q'length-1),
            scout   => sov(ib1_wrt_entry_ptr_offset to ib1_wrt_entry_ptr_offset + ib1_wrt_entry_ptr_q'length-1),
            din     => ib1_wrt_entry_ptr_d(0 to 1),
            dout    => ib1_wrt_entry_ptr_q(0 to 1) );

latch_ib2_wrt_entry_ptr : tri_rlmreg_p
  generic map (width => ib2_wrt_entry_ptr_q'length, init => 0, expand_type => expand_type)
  port map (nclk    => nclk,
            act     => reld_data_val,
            forcee   => func_slp_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_slp_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(ib2_wrt_entry_ptr_offset to ib2_wrt_entry_ptr_offset + ib2_wrt_entry_ptr_q'length-1),
            scout   => sov(ib2_wrt_entry_ptr_offset to ib2_wrt_entry_ptr_offset + ib2_wrt_entry_ptr_q'length-1),
            din     => ib2_wrt_entry_ptr_d(0 to 1),
            dout    => ib2_wrt_entry_ptr_q(0 to 1) );

latch_ib3_wrt_entry_ptr : tri_rlmreg_p
  generic map (width => ib3_wrt_entry_ptr_q'length, init => 0, expand_type => expand_type)
  port map (nclk    => nclk,
            act     => reld_data_val,
            forcee   => func_slp_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_slp_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(ib3_wrt_entry_ptr_offset to ib3_wrt_entry_ptr_offset + ib3_wrt_entry_ptr_q'length-1),
            scout   => sov(ib3_wrt_entry_ptr_offset to ib3_wrt_entry_ptr_offset + ib3_wrt_entry_ptr_q'length-1),
            din     => ib3_wrt_entry_ptr_d(0 to 1),
            dout    => ib3_wrt_entry_ptr_q(0 to 1) );

ib0_wrt_entry_ptr <= ib0_wrt_entry_ptr_q        when dec_ib0_wrt_entry_ptr='0' else
                     ib0_wrt_entry_ptr_minus1;

ib1_wrt_entry_ptr <= ib1_wrt_entry_ptr_q        when dec_ib1_wrt_entry_ptr='0' else
                     ib1_wrt_entry_ptr_minus1;

ib2_wrt_entry_ptr <= ib2_wrt_entry_ptr_q        when dec_ib2_wrt_entry_ptr='0' else
                     ib2_wrt_entry_ptr_minus1;

ib3_wrt_entry_ptr <= ib3_wrt_entry_ptr_q        when dec_ib3_wrt_entry_ptr='0' else
                     ib3_wrt_entry_ptr_minus1;

--****************************************************************************
-- Count data beats for each thread's inbox
--****************************************************************************

ib0_wrt_data_ctr_d(0 to 1) <= std_ulogic_vector(unsigned(ib0_wrt_data_ctr_q) + 1)   when (reld_data_val_dminus1='1' and reld_core_tag_dminus1="00") else
                              ib0_wrt_data_ctr_q;

ib1_wrt_data_ctr_d(0 to 1) <= std_ulogic_vector(unsigned(ib1_wrt_data_ctr_q) + 1)   when (reld_data_val_dminus1='1' and reld_core_tag_dminus1="01") else
                              ib1_wrt_data_ctr_q;

ib2_wrt_data_ctr_d(0 to 1) <= std_ulogic_vector(unsigned(ib2_wrt_data_ctr_q) + 1)   when (reld_data_val_dminus1='1' and reld_core_tag_dminus1="10") else
                              ib2_wrt_data_ctr_q;

ib3_wrt_data_ctr_d(0 to 1) <= std_ulogic_vector(unsigned(ib3_wrt_data_ctr_q) + 1)   when (reld_data_val_dminus1='1' and reld_core_tag_dminus1="11") else
                              ib3_wrt_data_ctr_q;

latch_ib0_wrt_data_ctr : tri_rlmreg_p
  generic map (width => ib0_wrt_data_ctr_q'length, init => 3, expand_type => expand_type)
  port map (nclk    => nclk,
            act     => reld_data_val_dminus1,
            forcee   => func_slp_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_slp_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(ib0_wrt_data_ctr_offset to ib0_wrt_data_ctr_offset + ib0_wrt_data_ctr_q'length-1),
            scout   => sov(ib0_wrt_data_ctr_offset to ib0_wrt_data_ctr_offset + ib0_wrt_data_ctr_q'length-1),
            din     => ib0_wrt_data_ctr_d(0 to 1),
            dout    => ib0_wrt_data_ctr_q(0 to 1));

latch_ib1_wrt_data_ctr : tri_rlmreg_p
  generic map (width => ib1_wrt_data_ctr_q'length, init => 3, expand_type => expand_type)
  port map (nclk    => nclk,
            act     => reld_data_val_dminus1,
            forcee   => func_slp_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_slp_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(ib1_wrt_data_ctr_offset to ib1_wrt_data_ctr_offset + ib1_wrt_data_ctr_q'length-1),
            scout   => sov(ib1_wrt_data_ctr_offset to ib1_wrt_data_ctr_offset + ib1_wrt_data_ctr_q'length-1),
            din     => ib1_wrt_data_ctr_d(0 to 1),
            dout    => ib1_wrt_data_ctr_q(0 to 1));

latch_ib2_wrt_data_ctr : tri_rlmreg_p
  generic map (width => ib2_wrt_data_ctr_q'length, init => 3, expand_type => expand_type)
  port map (nclk    => nclk,
            act     => reld_data_val_dminus1,
            forcee   => func_slp_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_slp_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(ib2_wrt_data_ctr_offset to ib2_wrt_data_ctr_offset + ib2_wrt_data_ctr_q'length-1),
            scout   => sov(ib2_wrt_data_ctr_offset to ib2_wrt_data_ctr_offset + ib2_wrt_data_ctr_q'length-1),
            din     => ib2_wrt_data_ctr_d(0 to 1),
            dout    => ib2_wrt_data_ctr_q(0 to 1));

latch_ib3_wrt_data_ctr : tri_rlmreg_p
  generic map (width => ib3_wrt_data_ctr_q'length, init => 3, expand_type => expand_type)
  port map (nclk    => nclk,
            act     => reld_data_val_dminus1,
            forcee   => func_slp_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_slp_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(ib3_wrt_data_ctr_offset to ib3_wrt_data_ctr_offset + ib3_wrt_data_ctr_q'length-1),
            scout   => sov(ib3_wrt_data_ctr_offset to ib3_wrt_data_ctr_offset + ib3_wrt_data_ctr_q'length-1),
            din     => ib3_wrt_data_ctr_d(0 to 1),
            dout    => ib3_wrt_data_ctr_q(0 to 1));


-- select thread id for node to inbox command
ib_wrt_thrd(0 to 1) <= reld_core_tag(3 to 4);

-- use thread to select write pointer
with ib_wrt_thrd select
   ib_wrt_entry_pointer <= ib0_wrt_entry_ptr   when "00",
                           ib1_wrt_entry_ptr   when "01",
                           ib2_wrt_entry_ptr   when "10",
                           ib3_wrt_entry_ptr   when others;


-- assemble inbox array write address
ib_ary_wrt_addr(0 to 5) <= ib_wrt_thrd & ib_wrt_entry_pointer & reld_qw(58 to 59);

ib_wen <= reld_data_val;
ib_ary_wen <= (others => ib_wen);


ib0_ecc_err_d <= (reld_data_val_dplus1 and lat_reld_ecc_err and not(ib0_wrt_data_ctr_q="11") and not ib0_set_val_q and reld_core_tag_dplus1="00") or
                 (ib0_ecc_err_q and not (ib0_wrt_data_ctr_q="11"));

ib1_ecc_err_d <= (reld_data_val_dplus1 and lat_reld_ecc_err and not(ib1_wrt_data_ctr_q="11") and not ib1_set_val_q and reld_core_tag_dplus1="01") or
                 (ib1_ecc_err_q and not (ib1_wrt_data_ctr_q="11"));

ib2_ecc_err_d <= (reld_data_val_dplus1 and lat_reld_ecc_err and not(ib2_wrt_data_ctr_q="11") and not ib2_set_val_q and reld_core_tag_dplus1="10") or
                 (ib2_ecc_err_q and not (ib2_wrt_data_ctr_q="11"));

ib3_ecc_err_d <= (reld_data_val_dplus1 and lat_reld_ecc_err and not(ib3_wrt_data_ctr_q="11") and not ib3_set_val_q and reld_core_tag_dplus1="11") or
                 (ib3_ecc_err_q and not (ib3_wrt_data_ctr_q="11"));

latch_ib0_ecc_err : tri_rlmreg_p
  generic map (width => 1, init => 0, expand_type => expand_type)
  port map (nclk    => nclk,
            act     => '1',
            forcee   => func_slp_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_slp_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(ib0_ecc_err_offset to ib0_ecc_err_offset),
            scout   => sov(ib0_ecc_err_offset to ib0_ecc_err_offset),
            din(0)  => ib0_ecc_err_d,
            dout(0) => ib0_ecc_err_q );

latch_ib1_ecc_err : tri_rlmreg_p
  generic map (width => 1, init => 0, expand_type => expand_type)
  port map (nclk    => nclk,
            act     => '1',
            forcee   => func_slp_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_slp_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(ib1_ecc_err_offset to ib1_ecc_err_offset),
            scout   => sov(ib1_ecc_err_offset to ib1_ecc_err_offset),
            din(0)  => ib1_ecc_err_d,
            dout(0) => ib1_ecc_err_q );

latch_ib2_ecc_err : tri_rlmreg_p
  generic map (width => 1, init => 0, expand_type => expand_type)
  port map (nclk    => nclk,
            act     => '1',
            forcee   => func_slp_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_slp_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(ib2_ecc_err_offset to ib2_ecc_err_offset),
            scout   => sov(ib2_ecc_err_offset to ib2_ecc_err_offset),
            din(0)  => ib2_ecc_err_d,
            dout(0) => ib2_ecc_err_q );

latch_ib3_ecc_err : tri_rlmreg_p
  generic map (width => 1, init => 0, expand_type => expand_type)
  port map (nclk    => nclk,
            act     => '1',
            forcee   => func_slp_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_slp_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(ib3_ecc_err_offset to ib3_ecc_err_offset),
            scout   => sov(ib3_ecc_err_offset to ib3_ecc_err_offset),
            din(0)  => ib3_ecc_err_d,
            dout(0) => ib3_ecc_err_q );

-- detemine which threads and buffers to set valid
ib0_set_val <= ib0_wrt_data_ctr_q="11" and reld_data_val and ib_wrt_thrd="00" and not (ib0_ecc_err_q or (reld_data_val_dplus1 and lat_reld_ecc_err and reld_core_tag_dplus1="00"));
ib1_set_val <= ib1_wrt_data_ctr_q="11" and reld_data_val and ib_wrt_thrd="01" and not (ib1_ecc_err_q or (reld_data_val_dplus1 and lat_reld_ecc_err and reld_core_tag_dplus1="01"));
ib2_set_val <= ib2_wrt_data_ctr_q="11" and reld_data_val and ib_wrt_thrd="10" and not (ib2_ecc_err_q or (reld_data_val_dplus1 and lat_reld_ecc_err and reld_core_tag_dplus1="10"));
ib3_set_val <= ib3_wrt_data_ctr_q="11" and reld_data_val and ib_wrt_thrd="11" and not (ib3_ecc_err_q or (reld_data_val_dplus1 and lat_reld_ecc_err and reld_core_tag_dplus1="11"));


ib0_buf0_set_val <= ib0_set_val and ib0_wrt_entry_ptr_q="00";
ib0_buf1_set_val <= ib0_set_val and ib0_wrt_entry_ptr_q="01";
ib0_buf2_set_val <= ib0_set_val and ib0_wrt_entry_ptr_q="10";
ib0_buf3_set_val <= ib0_set_val and ib0_wrt_entry_ptr_q="11";
ib1_buf0_set_val <= ib1_set_val and ib1_wrt_entry_ptr_q="00";
ib1_buf1_set_val <= ib1_set_val and ib1_wrt_entry_ptr_q="01";
ib1_buf2_set_val <= ib1_set_val and ib1_wrt_entry_ptr_q="10";
ib1_buf3_set_val <= ib1_set_val and ib1_wrt_entry_ptr_q="11";
ib2_buf0_set_val <= ib2_set_val and ib2_wrt_entry_ptr_q="00";
ib2_buf1_set_val <= ib2_set_val and ib2_wrt_entry_ptr_q="01";
ib2_buf2_set_val <= ib2_set_val and ib2_wrt_entry_ptr_q="10";
ib2_buf3_set_val <= ib2_set_val and ib2_wrt_entry_ptr_q="11";
ib3_buf0_set_val <= ib3_set_val and ib3_wrt_entry_ptr_q="00";
ib3_buf1_set_val <= ib3_set_val and ib3_wrt_entry_ptr_q="01";
ib3_buf2_set_val <= ib3_set_val and ib3_wrt_entry_ptr_q="10";
ib3_buf3_set_val <= ib3_set_val and ib3_wrt_entry_ptr_q="11";

ib0_buf0_reset_val <= ib0_set_val_q and lat_reld_ecc_err and ib0_wrt_entry_ptr="00";
ib0_buf1_reset_val <= ib0_set_val_q and lat_reld_ecc_err and ib0_wrt_entry_ptr="01";
ib0_buf2_reset_val <= ib0_set_val_q and lat_reld_ecc_err and ib0_wrt_entry_ptr="10";
ib0_buf3_reset_val <= ib0_set_val_q and lat_reld_ecc_err and ib0_wrt_entry_ptr="11";
ib1_buf0_reset_val <= ib1_set_val_q and lat_reld_ecc_err and ib1_wrt_entry_ptr="00";
ib1_buf1_reset_val <= ib1_set_val_q and lat_reld_ecc_err and ib1_wrt_entry_ptr="01";
ib1_buf2_reset_val <= ib1_set_val_q and lat_reld_ecc_err and ib1_wrt_entry_ptr="10";
ib1_buf3_reset_val <= ib1_set_val_q and lat_reld_ecc_err and ib1_wrt_entry_ptr="11";
ib2_buf0_reset_val <= ib2_set_val_q and lat_reld_ecc_err and ib2_wrt_entry_ptr="00";
ib2_buf1_reset_val <= ib2_set_val_q and lat_reld_ecc_err and ib2_wrt_entry_ptr="01";
ib2_buf2_reset_val <= ib2_set_val_q and lat_reld_ecc_err and ib2_wrt_entry_ptr="10";
ib2_buf3_reset_val <= ib2_set_val_q and lat_reld_ecc_err and ib2_wrt_entry_ptr="11";
ib3_buf0_reset_val <= ib3_set_val_q and lat_reld_ecc_err and ib3_wrt_entry_ptr="00";
ib3_buf1_reset_val <= ib3_set_val_q and lat_reld_ecc_err and ib3_wrt_entry_ptr="01";
ib3_buf2_reset_val <= ib3_set_val_q and lat_reld_ecc_err and ib3_wrt_entry_ptr="10";
ib3_buf3_reset_val <= ib3_set_val_q and lat_reld_ecc_err and ib3_wrt_entry_ptr="11";

latch_ib0_set_val : tri_rlmreg_p
  generic map (width => 1, init => 0, expand_type => expand_type)
  port map (nclk    => nclk,
            act     => '1',
            forcee   => func_slp_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_slp_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(ib0_set_val_offset to ib0_set_val_offset),
            scout   => sov(ib0_set_val_offset to ib0_set_val_offset),
            din(0)  => ib0_set_val,
            dout(0) => ib0_set_val_q );

latch_ib1_set_val : tri_rlmreg_p
  generic map (width => 1, init => 0, expand_type => expand_type)
  port map (nclk    => nclk,
            act     => '1',
            forcee   => func_slp_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_slp_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(ib1_set_val_offset to ib1_set_val_offset),
            scout   => sov(ib1_set_val_offset to ib1_set_val_offset),
            din(0)  => ib1_set_val,
            dout(0) => ib1_set_val_q );

latch_ib2_set_val : tri_rlmreg_p
  generic map (width => 1, init => 0, expand_type => expand_type)
  port map (nclk    => nclk,
            act     => '1',
            forcee   => func_slp_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_slp_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(ib2_set_val_offset to ib2_set_val_offset),
            scout   => sov(ib2_set_val_offset to ib2_set_val_offset),
            din(0)  => ib2_set_val,
            dout(0) => ib2_set_val_q );

latch_ib3_set_val : tri_rlmreg_p
  generic map (width => 1, init => 0, expand_type => expand_type)
  port map (nclk    => nclk,
            act     => '1',
            forcee   => func_slp_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_slp_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(ib3_set_val_offset to ib3_set_val_offset),
            scout   => sov(ib3_set_val_offset to ib3_set_val_offset),
            din(0)  => ib3_set_val,
            dout(0) => ib3_set_val_q );

-------------------------------------------------
-- Debug
-------------------------------------------------

dbg_group0_d <= ob_status_reg_newdata;

dbg_group0 <= my_ex3_flush &
              my_ex4_stg_flush &
              my_ex5_stg_flush &
              my_ex6_stg_flush &
              my_ccr2_en_ditc_q &
              ex4_mtdp_val_q &
              ex4_ipc_thrd_q &
              ex4_ipc_ba_q &
              ex4_ipc_sz_q &
              ob0_wrt_entry_ptr_q &
              ob1_wrt_entry_ptr_q &
              ob2_wrt_entry_ptr_q &
              ob3_wrt_entry_ptr_q &
              dbg_group0_q &
              ob0_buf0_status_q(0) &
              ob0_buf1_status_q(0) &
              ob0_buf2_status_q(0) &
              ob0_buf3_status_q(0) &
              ob1_buf0_status_q(0) &
              ob1_buf1_status_q(0) &
              ob1_buf2_status_q(0) &
              ob1_buf3_status_q(0) &
              ob2_buf0_status_q(0) &
              ob2_buf1_status_q(0) &
              ob2_buf2_status_q(0) &
              ob2_buf3_status_q(0) &
              ob3_buf0_status_q(0) &
              ob3_buf1_status_q(0) &
              ob3_buf2_status_q(0) &
              ob3_buf3_status_q(0) &
              ob_wen &
              ex4_mtdp_cr_status &
              outbox_ecc_err_q &
              outbox_ue_q &
              ob0_rd_entry_ptr_q &
              ob1_rd_entry_ptr_q &
              ob2_rd_entry_ptr_q &
              ob3_rd_entry_ptr_q &
              ob_to_node_data_ptr &
              ob_to_node_sel_q &
              ob_to_node_sel_sav_q & -- 8
              bx_slowspr_val_q &
              ditc_addr_sel &
              bx_slowspr_rw_q &
              bx_slowspr_etid_q &
              ob_err_inj_q ;

dbg_group1 <= ob_to_node_status_reg &
              ob_to_nd_val_t0 &
              ob_to_nd_val_t1 &
              ob_to_nd_val_t2 &
              ob_to_nd_val_t3 &
              lsu_cmd_avail_q &
              lsu_cmd_sent_q &
              lsu_cmd_stall_q &
              ob_cmd_sent_count_q &
              ob_cmd_count_t0_q &
              ob_cmd_count_t1_q &
              ob_cmd_count_t2_q &
              ob_cmd_count_t3_q &
              send_ob_state_q &
              dly_ob_cmd_val_q(1) &
              dly_ob_ditc_val_q(1) &
              dly1_ob_qw &
              ob_to_node_selected_thrd(0 to 1) &
              ob_addr_d &
              lat_st_pop &
              lat_st_pop_thrd(0 to 2);

dbg_group2 <= my_ex3_flush &
              my_ex4_stg_flush &
              my_ex5_stg_flush &
              my_ex6_stg_flush &
              my_ccr2_en_ditc_q &
              ex4_mfdp_val_q &
              ex4_mtdp_val_q &
              ex4_ipc_thrd_q &
              ex4_ipc_ba_q &
              ex4_ipc_sz_q &
              ib0_rd_entry_ptr_q &
              ib1_rd_entry_ptr_q &
              ib2_rd_entry_ptr_q &
              ib3_rd_entry_ptr_q &
              ib_t0_pop_d & 
              ib_t1_pop_d &
              ib_t2_pop_d &
              ib_t3_pop_d &
              ib0_buf0_val_q &
              ib0_buf1_val_q &
              ib0_buf2_val_q &
              ib0_buf3_val_q &
              ib1_buf0_val_q &
              ib1_buf1_val_q &
              ib1_buf2_val_q &
              ib1_buf3_val_q &
              ib2_buf0_val_q &
              ib2_buf1_val_q &
              ib2_buf2_val_q &
              ib2_buf3_val_q &
              ib3_buf0_val_q &
              ib3_buf1_val_q &
              ib3_buf2_val_q &
              ib3_buf3_val_q &
              ex5_ib_val_save_q &
              ex6_ib_val_save_q &
              inbox_ecc_err_q &
              inbox_ue_q &
              ex4_ib_rd_status_reg &
              ex4_mfdp_cr_status_i &
              lat_reld_data_val &
              lat_reld_ditc &
              lat_reld_core_tag &
              lat_reld_qw &
              ib0_wrt_entry_ptr_q &
              ib1_wrt_entry_ptr_q &
              ib2_wrt_entry_ptr_q &
              ib3_wrt_entry_ptr_q &
              ib0_wrt_data_ctr_q &
              ib1_wrt_data_ctr_q &
              ib2_wrt_data_ctr_q &
              ib3_wrt_data_ctr_q &
              lat_reld_data(24 to 31) &
              ex5_inbox_data_cor(24 to 31);

dbg_group3 <= lat_reld_data(56 to 63) &
              lat_reld_data(88 to 95) &
              ex5_inbox_data_cor(56 to 63) &
              ex5_inbox_data_cor(88 to 95) &
              ex5_inbox_data_cor(120 to 127) &
              ob_ary_wrt_data_l2(24 to 31) &
              ob_ary_wrt_data_l2(56 to 63) &
              ob_ary_wrt_data_l2(88 to 95) &
              ob_rd_data_cor_l2(24 to 31) &
              ob_rd_data_cor_l2(56 to 63) &
              ob_rd_data_cor_l2(120 to 127);

trg_group0 <= ex4_mtdp_val_q &
              ex4_mfdp_val_q &
              my_ex4_stg_flush &
              my_ex5_stg_flush &
              my_ex6_stg_flush &
              ob_to_nd_ready &
              dly_ob_cmd_val_q(1) &
              dly_ob_ditc_val_q(1) &
              ob_credit_t0 &
              ob_credit_t1 &
              ob_credit_t2 &
              ob_credit_t3;

trg_group1 <= ex5_ob0_flushed &
              ex5_ob1_flushed &
              ex5_ob2_flushed &
              ex5_ob3_flushed &
              ex6_ob0_flushed &
              ex6_ob1_flushed &
              ex6_ob2_flushed &
              ex6_ob3_flushed &
              ex4_mtdp_cr_status &
              ob_lsu_complete &
              outbox_ecc_err_q &
              outbox_ue_q ;

trg_group2 <= ex4_ipc_thrd_q &
              ex4_ipc_ba_q &
              ex4_ib0_flushed &
              ex4_ib1_flushed &
              ex4_ib2_flushed &
              ex4_ib3_flushed &
              ex4_mfdp_cr_status_i;

trg_group3 <= ex5_ib0_flushed &
              ex5_ib1_flushed &
              ex5_ib2_flushed &
              ex5_ib3_flushed &
              ex6_ib0_flushed &
              ex6_ib1_flushed &
              ex6_ib2_flushed &
              ex6_ib3_flushed &
              lat_reld_data_val &
              lat_reld_ditc &
              lat_reld_core_tag ;

-- latch one set of debug input signals to represent that latches that may be needed when the real signals are used
latch_debug_dbg_group0 : tri_rlmreg_p
  generic map (width => dbg_group0_q'length, init => 0, expand_type => expand_type)
  port map (nclk    => nclk,
            act     => trace_bus_enable_q,
            forcee   => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(debug_dbg_group0_offset to debug_dbg_group0_offset + dbg_group0_q'length-1),
            scout   => sov(debug_dbg_group0_offset to debug_dbg_group0_offset + dbg_group0_q'length-1),
            din     => dbg_group0_d,
            dout    => dbg_group0_q);
 

latch_trace_bus_enable : tri_rlmreg_p
  generic map (width => 1, init => 0, expand_type => expand_type)
  port map (nclk    => nclk,
            act     => '1',
            forcee   => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(trace_bus_enable_offset to trace_bus_enable_offset),
            scout   => sov(trace_bus_enable_offset to trace_bus_enable_offset),
            din(0)  => pc_bx_trace_bus_enable,
            dout(0) => trace_bus_enable_q );

latch_debug_mux_ctrls : tri_rlmreg_p
  generic map (width => debug_mux1_ctrls_q'length, init => 0, expand_type => expand_type)
  port map (nclk    => nclk,
            act     => trace_bus_enable_q,
            forcee   => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(debug_mux_ctrls_offset to debug_mux_ctrls_offset + debug_mux1_ctrls_q'length-1),
            scout   => sov(debug_mux_ctrls_offset to debug_mux_ctrls_offset + debug_mux1_ctrls_q'length-1),
            din     => pc_bx_debug_mux1_ctrls(0 to 15),
            dout    => debug_mux1_ctrls_q(0 to 15));

debug_mux : entity clib.c_debug_mux4(c_debug_mux4)
   port map (
     vd                 => vdd,
     gd                 => gnd,
     select_bits        => debug_mux1_ctrls_q,
     trace_data_in      => debug_data_in,
     trigger_data_in    => trigger_data_in,

     dbg_group0         => dbg_group0,
     dbg_group1         => dbg_group1,
     dbg_group2         => dbg_group2,
     dbg_group3         => dbg_group3,
                           
     trg_group0         => trg_group0,
     trg_group1         => trg_group1,
     trg_group2         => trg_group2,
     trg_group3         => trg_group3,

     trace_data_out     => debug_mux_out_d,
     trigger_data_out   => trigger_mux_out_d
   );


latch_debug_mux_out : tri_rlmreg_p
  generic map (width => debug_mux_out_d'length, init => 0, expand_type => expand_type)
  port map (nclk    => nclk,
            act     => trace_bus_enable_q,
            forcee   => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(debug_mux_out_offset to debug_mux_out_offset + debug_mux_out_d'length-1),
            scout   => sov(debug_mux_out_offset to debug_mux_out_offset + debug_mux_out_d'length-1),
            din     => debug_mux_out_d(0 to 87),
            dout    => debug_data_out(0 to 87));


latch_trigger_mux_out : tri_rlmreg_p
  generic map (width => trigger_mux_out_d'length, init => 0, expand_type => expand_type)
  port map (nclk    => nclk,
            act     => trace_bus_enable_q,
            forcee   => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(trigger_mux_out_offset to trigger_mux_out_offset + trigger_mux_out_d'length-1),
            scout   => sov(trigger_mux_out_offset to trigger_mux_out_offset + trigger_mux_out_d'length-1),
            din     => trigger_mux_out_d(0 to 11),
            dout    => trigger_data_out(0 to 11));

-------------------------------------------------
-- Pervasive
-------------------------------------------------

perv_3to2_reg: tri_plat
  generic map (width => 11, expand_type => expand_type)
port map (vd             => vdd,
            gd             => gnd,
            nclk           => nclk,
            flush          => pc_bx_ccflush_dc,
            din(0)         => pc_bx_func_sl_thold_3,
            din(1)         => pc_bx_gptr_sl_thold_3,
            din(2)         => pc_bx_sg_3,
            din(3)         => pc_bx_abst_sl_thold_3,
            din(4)         => pc_bx_time_sl_thold_3,
            din(5)         => pc_bx_ary_nsl_thold_3,
            din(6)         => pc_bx_repr_sl_thold_3,
            din(7)         => pc_bx_func_slp_sl_thold_3,
            din(8)         => pc_bx_ary_slp_nsl_thold_3,
            din(9)         => pc_bx_bolt_sl_thold_3,
            din(10)        => pc_bx_bo_enable_3,
            q(0)           => func_sl_thold_2,
            q(1)           => gptr_sl_thold_2,
            q(2)           => sg_2,
            q(3)           => abst_sl_thold_2,
            q(4)           => time_sl_thold_2, 
            q(5)           => ary_nsl_thold_2,
            q(6)           => repr_sl_thold_2,
            q(7)           => func_slp_sl_thold_2,
            q(8)           => ary_slp_nsl_thold_2,
            q(9)           => bolt_sl_thold_2,
            q(10)          => bolt_enable_2);


perv_2to1_reg: tri_plat
  generic map (width => 10, expand_type => expand_type)
port map (vd             => vdd,
            gd             => gnd,
            nclk           => nclk,
            flush          => pc_bx_ccflush_dc,
            din(0)         => func_sl_thold_2,
            din(1)         => gptr_sl_thold_2,
            din(2)         => sg_2,
            din(3)         => abst_sl_thold_2,
            din(4)         => time_sl_thold_2,
            din(5)         => ary_nsl_thold_2,
            din(6)         => repr_sl_thold_2,
            din(7)         => func_slp_sl_thold_2,
            din(8)         => ary_slp_nsl_thold_2,
            din(9)         => bolt_sl_thold_2,
            q(0)           => func_sl_thold_1,
            q(1)           => gptr_sl_thold_1,
            q(2)           => sg_1,
            q(3)           => abst_sl_thold_1,
            q(4)           => time_sl_thold_1, 
            q(5)           => ary_nsl_thold_1,
            q(6)           => repr_sl_thold_1,
            q(7)           => func_slp_sl_thold_1,
            q(8)           => ary_slp_nsl_thold_1,
            q(9)           => bolt_sl_thold_1);

perv_1to0_reg: tri_plat
  generic map (width => 10, expand_type => expand_type)
port map (vd             => vdd,
            gd             => gnd,
            nclk           => nclk,
            flush          => pc_bx_ccflush_dc,
            din(0)         => func_sl_thold_1,
            din(1)         => gptr_sl_thold_1,
            din(2)         => sg_1,
            din(3)         => abst_sl_thold_1,
            din(4)         => time_sl_thold_1,
            din(5)         => ary_nsl_thold_1,
            din(6)         => repr_sl_thold_1,
            din(7)         => func_slp_sl_thold_1,
            din(8)         => ary_slp_nsl_thold_1,
            din(9)         => bolt_sl_thold_1,
            q(0)           => func_sl_thold_0,
            q(1)           => gptr_sl_thold_0,
            q(2)           => sg_0,
            q(3)           => abst_sl_thold_0,
            q(4)           => time_sl_thold_0, 
            q(5)           => ary_nsl_thold_0,
            q(6)           => repr_sl_thold_0,
            q(7)           => func_slp_sl_thold_0,
            q(8)           => ary_slp_nsl_thold_0,
            q(9)           => bolt_sl_thold_0);

perv_lcbor_func_sl: tri_lcbor
  generic map (expand_type => expand_type)
  port map (clkoff_b    => clkoff_dc_b,
            thold       => func_sl_thold_0,
            sg          => sg_0,
            act_dis     => tidn,
            forcee       => func_sl_force,
            thold_b     => func_sl_thold_0_b);

perv_lcbor_func_slp_sl: tri_lcbor
  generic map (expand_type => expand_type)
  port map (clkoff_b    => clkoff_dc_b,
            thold       => func_slp_sl_thold_0,
            sg          => sg_0,
            act_dis     => tidn,
            forcee       => func_slp_sl_force,
            thold_b     => func_slp_sl_thold_0_b);

ab_lcbor_func_sl: tri_lcbor
  generic map (expand_type => expand_type)
  port map (clkoff_b    => clkoff_dc_b,
            thold       => abst_sl_thold_0,
            sg          => sg_0,
            act_dis     => tidn,
            forcee       => abst_sl_force,
            thold_b     => abst_sl_thold_0_b);

perv_lcbctrl_0: tri_lcbcntl_mac
  generic map (expand_type => expand_type)
port map (
            vdd            => vdd,
            gnd            => gnd,
            sg             => sg_0,
            nclk           => nclk,
            scan_in        => gptr_scan_in,
            scan_diag_dc   => an_ac_scan_diag_dc,
            thold          => gptr_sl_thold_0,
            clkoff_dc_b    => clkoff_dc_b,
            delay_lclkr_dc => delay_lclkr_dc_v(0 to 4),
            act_dis_dc     => open,
            d_mode_dc      => d_mode_dc,
            mpw1_dc_b      => mpw1_dc_b_v(0 to 4),
            mpw2_dc_b      => mpw2_dc_b,
            scan_out       => int_gptr_scan_out);

delay_lclkr_dc <= delay_lclkr_dc_v(0);
mpw1_dc_b <= mpw1_dc_b_v(0);

perv_lcbctrl_ary_0: tri_lcbcntl_array_mac
  generic map (expand_type => expand_type)
port map (
            vdd            => vdd,
            gnd            => gnd,
            sg             => sg_0,
            nclk           => nclk,
            scan_in        => int_gptr_scan_out,
            scan_diag_dc   => an_ac_scan_diag_dc,
            thold          => gptr_sl_thold_0,
            clkoff_dc_b    => ary0_clkoff_dc_b,
            delay_lclkr_dc => ary0_delay_lclkr_dc_v(0 to 4),
            act_dis_dc     => open,
            d_mode_dc      => ary0_d_mode_dc,
            mpw1_dc_b      => ary0_mpw1_dc_b_v(0 to 4),
            mpw2_dc_b      => ary0_mpw2_dc_b,
            scan_out       => int0_gptr_scan_out);

perv_lcbctrl_ary_1: tri_lcbcntl_array_mac
  generic map (expand_type => expand_type)
port map (
            vdd            => vdd,
            gnd            => gnd,
            sg             => sg_0,
            nclk           => nclk,
            scan_in        => int0_gptr_scan_out,
            scan_diag_dc   => an_ac_scan_diag_dc,
            thold          => gptr_sl_thold_0,
            clkoff_dc_b    => ary1_clkoff_dc_b,
            delay_lclkr_dc => ary1_delay_lclkr_dc_v(0 to 4),
            act_dis_dc     => open,
            d_mode_dc      => ary1_d_mode_dc,
            mpw1_dc_b      => ary1_mpw1_dc_b_v(0 to 4),
            mpw2_dc_b      => ary1_mpw2_dc_b,
            scan_out       => int1_gptr_scan_out);

gptr_scan_out <= int1_gptr_scan_out and an_ac_scan_dis_dc_b;

-- LCBs for scan only staging latches
slat_force        <= sg_0;
time_slat_thold_b <= NOT time_sl_thold_0;

perv_lcbs_time: tri_lcbs
  generic map (expand_type => expand_type )
  port map (
      vd          => vdd,
      gd          => gnd,
      delay_lclkr => delay_lclkr_dc,
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
              scan_in(1)  => ib_time_scan_out,
              scan_out(0) => time_scan_in_q,
              scan_out(1) => time_scan_out_stg );

time_scan_out <= time_scan_out_stg and an_ac_scan_dis_dc_b;

repr_slat_thold_b <= NOT repr_sl_thold_0;

perv_lcbs_repr: tri_lcbs
  generic map (expand_type => expand_type )
  port map (
      vd          => vdd,
      gd          => gnd,
      delay_lclkr => delay_lclkr_dc,
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
              scan_in(1)  => int_repr_scan_out,
              scan_out(0) => repr_scan_in_q,
              scan_out(1) => repr_scan_out_q );

repr_scan_out <= repr_scan_out_q and an_ac_scan_dis_dc_b;

-- ABIST timing latches
ab_reg: tri_rlmreg_p   generic map (init => 0, expand_type => expand_type, width => 25, needs_sreset => 0)
port map (nclk    => nclk,
          act     => pc_bx_abist_ena_dc,
          forcee => abst_sl_force,
          delay_lclkr => delay_lclkr_dc,
          mpw1_b      => mpw1_dc_b,
          mpw2_b      => mpw2_dc_b,
          thold_b => abst_sl_thold_0_b,
          sg      => sg_0,
          vd      => vdd,
          gd      => gnd,
          scin    => ab_reg_si(0 to 24),
          scout   => ab_reg_so(0 to 24),
          din ( 0 to  3) => pc_bx_abist_di_0(0 to 3)   ,
          din (       4) => pc_bx_abist_g8t_bw_1     ,
          din (       5) => pc_bx_abist_g8t_bw_0     ,
          din ( 6 to 11) => pc_bx_abist_waddr_0(4 to 9)     ,
          din (      12) => pc_bx_abist_g8t_wenb     ,
          din (13 to 18) => pc_bx_abist_raddr_0(4 to 9),
          din (      19) => pc_bx_abist_g8t1p_renb_0,
          din (      20) => pc_bx_abist_wl64_comp_ena,
          din (21 to 24) => pc_bx_abist_g8t_dcomp(0 to 3) ,
          dout( 0 to  3) => abist_di_0(0 to 3)   ,
          dout(       4) => abist_g8t_bw_1     ,
          dout(       5) => abist_g8t_bw_0     ,
          dout( 6 to 11) => abist_waddr_0(4 to 9)     ,
          dout(      12) => abist_g8t_wenb     ,
          dout(13 to 18) => abist_raddr_0(4 to 9),
          dout(      19) => abist_g8t1p_renb_0,
          dout(      20) => abist_wl64_comp_ena,
          dout(21 to 24) => abist_g8t_dcomp(0 to 3)    );


-- *********************************************************************************
-- Spare latches

latch_spare0 : tri_rlmreg_p
  generic map (width => spare0_l2'length, init => 0, expand_type => expand_type)
  port map (nclk    => nclk,
            act     => '1',
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(spare0_offset to spare0_offset + spare0_l2'length-1),
            scout   => sov(spare0_offset to spare0_offset + spare0_l2'length-1),
            din     => spare0_l2(0 to 7),
            dout    => spare0_l2(0 to 7) );

latch_spare1 : tri_rlmreg_p
  generic map (width => spare1_l2'length, init => 0, expand_type => expand_type)
  port map (nclk    => nclk,
            act     => '1',
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            vd      => vdd,
            gd      => gnd,
            scin    => siv(spare1_offset to spare1_offset + spare1_l2'length-1),
            scout   => sov(spare1_offset to spare1_offset + spare1_l2'length-1),
            din     => spare1_l2,
            dout    => spare1_l2 );


-- scan in and scan out connections
siv(0 to scan_right0-1)  <= sov(1 to  scan_right0-1) & func_scan_in(0);
func_scan_out(0) <= sov(0) and an_ac_scan_dis_dc_b;

siv(scan_right0 to siv'right)  <= sov(scan_right0+1 to siv'right) & func_scan_in(1);
func_scan_out(1) <= sov(scan_right0) and an_ac_scan_dis_dc_b;

ab_reg_si(0 to 24) <= ab_reg_so(1 to 24) & ib_abst_scan_out;
abst_scan_out <= ab_reg_so(0) and an_ac_scan_dis_dc_b;

end bxq;
