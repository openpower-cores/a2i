-- © IBM Corp. 2020
-- This softcore is licensed under and subject to the terms of the CC-BY 4.0
-- license (https://creativecommons.org/licenses/by/4.0/legalcode). 
-- Additional rights, including the right to physically implement a softcore 
-- that is compliant with the required sections of the Power ISA 
-- Specification, will be available at no cost via the OpenPOWER Foundation. 
-- This README will be updated with additional information when OpenPOWER's 
-- license is available.



library ieee; use ieee.std_logic_1164.all;
library ibm;
library work; use work.all;
  use ibm.std_ulogic_support.all;
  use ibm.std_ulogic_function_support.all;
library support;
  use support.power_logic_pkg.all;
library tri;
use tri.tri_latches_pkg.all;

entity a2x_axi is
	generic (
     C_M00_AXI_ID_WIDTH	: integer	:= 4;
     C_M00_AXI_ADDR_WIDTH	: integer	:= 32;
	  C_M00_AXI_DATA_WIDTH	: integer	:= 32;
     C_M00_AXI_AWUSER_WIDTH	: integer	:= 4;
     C_M00_AXI_ARUSER_WIDTH	: integer	:= 4;
     C_M00_AXI_WUSER_WIDTH	: integer	:= 4;
     C_M00_AXI_RUSER_WIDTH	: integer	:= 4;
     C_M00_AXI_BUSER_WIDTH	: integer	:= 4
	);
   port (
   
      clk               : in std_logic;
      clk2x             : in std_logic;    
      reset_n           : in std_logic;                        
      thold             : in std_logic;                        
      
      core_id           : in std_logic_vector(0 to 7);         
      thread_stop       : in std_logic_vector(0 to 3);         
      thread_running    : out std_logic_vector(0 to 3);        
      
      ext_mchk          : in std_logic_vector(0 to 3);         
      ext_checkstop     : in std_logic;                        
      debug_stop        : in  std_logic;                       
      mchk              : out std_logic_vector(0 to 3);        
      recov_err         : out std_logic_vector(0 to 2);        
      checkstop         : out std_logic_vector(0 to 2);        
      a2l2_axi_err      : out std_logic_vector(0 to 3);        
      
      crit_interrupt    : in std_logic_vector(0 to 3);         
      ext_interrupt     : in std_logic_vector(0 to 3);         
      perf_interrupt    : in std_logic_vector(0 to 3);         
      
      tb_update_enable  : in std_logic;                        
      tb_update_pulse   : in std_logic;                        
      
      scom_sat_id       : in std_logic_vector(0 to 3);         
      scom_dch_in       : in std_logic;
      scom_cch_in       : in std_logic;
      scom_dch_out      : out std_logic;
      scom_cch_out      : out std_logic;
      
      flh2l2_gate       : in std_logic;
      hang_pulse        : in std_logic_vector(0 to 3);

		m00_axi_awid	: out std_logic_vector(C_M00_AXI_ID_WIDTH-1 downto 0);
		m00_axi_awaddr	: out std_logic_vector(C_M00_AXI_ADDR_WIDTH-1 downto 0);
		m00_axi_awlen	: out std_logic_vector(7 downto 0);
		m00_axi_awsize	: out std_logic_vector(2 downto 0);
		m00_axi_awburst	: out std_logic_vector(1 downto 0);
		m00_axi_awlock	: out std_logic;
		m00_axi_awcache	: out std_logic_vector(3 downto 0);
		m00_axi_awprot	: out std_logic_vector(2 downto 0);
		m00_axi_awqos	: out std_logic_vector(3 downto 0);
		m00_axi_awuser	: out std_logic_vector(C_M00_AXI_AWUSER_WIDTH-1 downto 0);
		m00_axi_awvalid	: out std_logic;
		m00_axi_awready	: in std_logic;
		m00_axi_wdata	: out std_logic_vector(C_M00_AXI_DATA_WIDTH-1 downto 0);
		m00_axi_wstrb	: out std_logic_vector(C_M00_AXI_DATA_WIDTH/8-1 downto 0);
		m00_axi_wlast	: out std_logic;
		m00_axi_wuser	: out std_logic_vector(C_M00_AXI_WUSER_WIDTH-1 downto 0);
		m00_axi_wvalid	: out std_logic;
		m00_axi_wready	: in std_logic;
		m00_axi_bid	: in std_logic_vector(C_M00_AXI_ID_WIDTH-1 downto 0);
		m00_axi_bresp	: in std_logic_vector(1 downto 0);
		m00_axi_buser	: in std_logic_vector(C_M00_AXI_BUSER_WIDTH-1 downto 0);
		m00_axi_bvalid	: in std_logic;
		m00_axi_bready	: out std_logic;
		m00_axi_arid	: out std_logic_vector(C_M00_AXI_ID_WIDTH-1 downto 0);
		m00_axi_araddr	: out std_logic_vector(C_M00_AXI_ADDR_WIDTH-1 downto 0);
		m00_axi_arlen	: out std_logic_vector(7 downto 0);
		m00_axi_arsize	: out std_logic_vector(2 downto 0);
		m00_axi_arburst	: out std_logic_vector(1 downto 0);
		m00_axi_arlock	: out std_logic;
		m00_axi_arcache	: out std_logic_vector(3 downto 0);
		m00_axi_arprot	: out std_logic_vector(2 downto 0);
		m00_axi_arqos	: out std_logic_vector(3 downto 0);
		m00_axi_aruser	: out std_logic_vector(C_M00_AXI_ARUSER_WIDTH-1 downto 0);
		m00_axi_arvalid	: out std_logic;
		m00_axi_arready	: in std_logic;
		m00_axi_rid	: in std_logic_vector(C_M00_AXI_ID_WIDTH-1 downto 0);
		m00_axi_rdata	: in std_logic_vector(C_M00_AXI_DATA_WIDTH-1 downto 0);
		m00_axi_rresp	: in std_logic_vector(1 downto 0);
		m00_axi_rlast	: in std_logic;
		m00_axi_ruser	: in std_logic_vector(C_M00_AXI_RUSER_WIDTH-1 downto 0);
		m00_axi_rvalid	: in std_logic;
		m00_axi_rready	: out std_logic
      
   );
end a2x_axi;   

architecture a2x_axi of a2x_axi is

  constant expand_type         : integer := 1;
  constant threads             : integer := 4;
  constant xu_real_data_add    : integer := 42;
  constant st_data_32b_mode    : integer := 1;
  constant ac_st_data_32b_mode : integer := 1;
  constant error_width         : integer := 3;
  constant expand_tlb_type     : integer := 2;
  constant extclass_width      : integer := 2;
  constant inv_seq_width       : integer := 4;
  constant lpid_width          : integer := 8;
  constant pid_width           : integer := 14;
  constant ra_entry_width      : integer := 12;
  constant real_addr_width     : integer := 42;
 
signal a2_nclk : clk_logic;
 
signal an_ac_sg_7              :  std_logic;
signal an_ac_back_inv          :  std_logic;
signal an_ac_back_inv_addr     :  std_logic_vector(22 to 63);
signal an_ac_back_inv_lbit     :  std_logic;
signal an_ac_back_inv_gs       :  std_logic;
signal an_ac_back_inv_ind      :  std_logic;
signal an_ac_back_inv_local    :  std_logic;
signal an_ac_back_inv_lpar_id  :  std_logic_vector(0 to 7);
signal an_ac_back_inv_target   :  std_logic_vector(0 to 4);
signal an_ac_dcr_act           :  std_logic;
signal an_ac_dcr_val           :  std_logic;
signal an_ac_dcr_read          :  std_logic;
signal an_ac_dcr_etid          :  std_logic_vector(0 to 1);
signal an_ac_dcr_data          :  std_logic_vector(0 to 63);
signal an_ac_dcr_done          :  std_logic;
signal an_ac_flh2l2_gate       :  std_logic;                       
signal an_ac_reld_core_tag     :  std_logic_vector(0 to 4);
signal an_ac_reld_data         :  std_logic_vector(0 to 127);
signal an_ac_reld_data_vld     :  std_logic;
signal an_ac_reld_ecc_err      :  std_logic;
signal an_ac_reld_ecc_err_ue   :  std_logic;
signal an_ac_reld_qw           :  std_logic_vector(57 to 59);
signal an_ac_reld_data_coming  :  std_logic;
signal an_ac_reld_ditc         :  std_logic;
signal an_ac_reld_crit_qw      :  std_logic;
signal an_ac_reld_l1_dump      :  std_logic;

signal an_ac_req_ld_pop        :  std_logic;
signal an_ac_req_st_gather     :  std_logic;
signal an_ac_req_st_pop        :  std_logic;
signal an_ac_req_st_pop_thrd   :  std_logic_vector(0 to 2);

signal an_ac_stcx_complete     :  std_logic_vector(0 to 3);
signal an_ac_stcx_pass         :  std_logic_vector(0 to 3);
signal an_ac_sync_ack          :  std_logic_vector(0 to 3);
signal an_ac_user_defined      :  std_logic_vector(0 to 3);
signal an_ac_reservation_vld   :  std_logic_vector(0 to 3);

signal an_ac_icbi_ack          :  std_ulogic;
signal an_ac_icbi_ack_thread   :  std_ulogic_vector(0 to 1);
signal an_ac_sleep_en          :  std_ulogic_vector(0 to 3);
signal ac_an_back_inv_reject   :  std_ulogic;
signal ac_an_box_empty         :  std_ulogic_vector(0 to 3);
signal ac_an_lpar_id           :  std_ulogic_vector(0 to 7);
signal ac_an_power_managed     :  std_ulogic;
signal ac_an_req               :  std_ulogic;
signal ac_an_req_endian        :  std_ulogic;
signal ac_an_req_ld_core_tag   :  std_ulogic_vector(0 to 4);
signal ac_an_req_ld_xfr_len    :  std_ulogic_vector(0 to 2);
signal ac_an_req_pwr_token     :  std_ulogic;
signal ac_an_req_ra            :  std_ulogic_vector(22 to 63);
signal ac_an_req_spare_ctrl_a0 :  std_ulogic_vector(0 to 3);
signal ac_an_req_thread        :  std_ulogic_vector(0 to 2);
signal ac_an_req_ttype         :  std_ulogic_vector(0 to 5);
signal ac_an_req_user_defined  :  std_ulogic_vector(0 to 3);
signal ac_an_req_wimg_g        :  std_ulogic;
signal ac_an_req_wimg_i        :  std_ulogic;
signal ac_an_req_wimg_m        :  std_ulogic;
signal ac_an_req_wimg_w        :  std_ulogic;
signal ac_an_reld_ditc_pop     :  std_ulogic_vector(0 to 3);
signal ac_an_rvwinkle_mode     :  std_ulogic;
signal ac_an_st_byte_enbl      :  std_ulogic_vector(0 to 31);
signal ac_an_st_data           :  std_ulogic_vector(0 to 255);
signal ac_an_st_data_pwr_token :  std_ulogic;
signal ac_an_fu_bypass_events  :  std_ulogic_vector(0 to 7);
signal ac_an_iu_bypass_events  :  std_ulogic_vector(0 to 7);
signal ac_an_mm_bypass_events  :  std_ulogic_vector(0 to 7);
signal an_ac_debug_stop        :  std_ulogic;
signal ac_an_psro_ringsig      :  std_ulogic;
signal an_ac_psro_enable_dc    :  std_ulogic_vector(0 to 2);
signal an_ac_req_spare_ctrl_a1 :  std_ulogic_vector(0 to 3);
signal alt_disp                :  std_ulogic;
signal d_mode                  :  std_ulogic;
signal delay_lclkr             :  std_ulogic;
signal mpw1_b                  :  std_ulogic;
signal mpw2_b                  :  std_ulogic;
signal scdis_b                 :  std_ulogic;

signal an_ac_abist_mode_dc     :  std_ulogic;
signal an_ac_abist_start_test  :  std_ulogic;
signal an_ac_abst_scan_in      :  std_ulogic_vector(0 to 9);
signal an_ac_atpg_en_dc        :  std_ulogic;
signal an_ac_bcfg_scan_in          :  std_ulogic_vector(0 to 4);
signal an_ac_lbist_ary_wrt_thru_dc  :  std_ulogic;
signal an_ac_ccenable_dc           :  std_ulogic;
signal an_ac_ccflush_dc            :  std_ulogic;
signal an_ac_reset_1_complete      :  std_ulogic;
signal an_ac_reset_2_complete      :  std_ulogic;
signal an_ac_reset_3_complete      :  std_ulogic;
signal an_ac_reset_wd_complete     :  std_ulogic;
signal an_ac_dcfg_scan_in          :  std_ulogic_vector(0 to 2);
signal an_ac_fce_7                 :  std_ulogic;
signal an_ac_func_scan_in          :  std_ulogic_vector(0 to 63);
signal an_ac_gptr_scan_in      :  std_ulogic;
signal an_ac_hang_pulse        :  std_ulogic_vector(0 to 3);
signal an_ac_lbist_en_dc       :  std_ulogic;    
signal an_ac_lbist_ac_mode_dc  :  std_ulogic; 
signal an_ac_lbist_ip_dc       :  std_ulogic;  
signal an_ac_malf_alert        :  std_ulogic;  
signal an_ac_gsd_test_enable_dc :  std_ulogic;
signal an_ac_gsd_test_acmode_dc :  std_ulogic;
signal an_ac_repr_scan_in      :  std_ulogic;
signal an_ac_scan_diag_dc      :  std_ulogic;
signal an_ac_scan_dis_dc_b     :  std_ulogic;
signal an_ac_scan_type_dc      :  std_ulogic_vector(0 to 8);
signal an_ac_scom_sat_id       :  std_ulogic_vector(0 to 3);
signal an_ac_checkstop         :  std_ulogic;
signal an_ac_machine_check     :  std_ulogic_vector(0 to 3);
signal an_ac_tb_update_enable  : std_ulogic;
signal an_ac_tb_update_pulse   : std_ulogic;
signal an_ac_time_scan_in      :  std_ulogic;
signal an_ac_regf_scan_in      :  std_ulogic_vector(0 to 11);

signal ac_an_debug_bus         :  std_ulogic_vector(0 to 87);
signal ac_an_event_bus         :  std_ulogic_vector(0 to 7);
signal ac_an_trace_triggers    :  std_ulogic_vector(0 to 11);
signal ac_an_abist_done_dc     :  std_ulogic;
signal ac_an_abst_scan_out     :  std_ulogic_vector(0 to 9);
signal ac_an_bcfg_scan_out     :  std_ulogic_vector(0 to 4);
signal ac_an_dcfg_scan_out     :  std_ulogic_vector(0 to 2);
signal ac_an_debug_trigger     :  std_ulogic_vector(0 to 3);
signal ac_an_func_scan_out     :  std_ulogic_vector(0 to 63);
signal ac_an_gptr_scan_out     :  std_ulogic;
signal ac_an_repr_scan_out     :  std_ulogic;
signal ac_an_time_scan_out     :  std_ulogic;
signal ac_an_special_attn      :  std_ulogic_vector(0 to 3);
signal ac_an_checkstop         :  std_ulogic_vector(0 to 2);
signal ac_an_dcr_act	       :  std_ulogic;
signal ac_an_dcr_val	       :  std_ulogic;
signal ac_an_dcr_read          :  std_ulogic;
signal ac_an_dcr_user          :  std_ulogic;
signal ac_an_dcr_etid          :  std_ulogic_vector(0 to 1);
signal ac_an_dcr_addr          :  std_ulogic_vector(11 to 20);
signal ac_an_dcr_data          :  std_ulogic_vector(0 to 63);

signal ac_an_machine_check     :  std_ulogic_vector(0 to 3);
signal ac_an_pm_thread_running :  std_ulogic_vector(0 to 3);
signal ac_an_recov_err         :  std_ulogic_vector(0 to 2);
signal ac_an_local_checkstop   :  std_ulogic_vector(0 to 2);  
signal an_ac_external_mchk     :  std_ulogic_vector(0 to 3);     

signal gnd                     :  power_logic;
signal vcs                     :  power_logic;
signal vdd                     :  power_logic;
signal vio                     :  power_logic;

signal node_scom_dch_in         : std_ulogic;
signal node_scom_cch_in         : std_ulogic;
signal node_scom_dch_out        : std_ulogic;
signal node_scom_cch_out        : std_ulogic;

signal an_ac_camfence_en_dc  : std_ulogic;

signal tidn                     : std_ulogic;
signal tiup                     : std_ulogic;

begin

tidn <= '0';
tiup <= '1';

a2_nclk.clk <= clk;
a2_nclk.clk2x <= clk2x;
a2_nclk.clk4x <= '0';
a2_nclk.sreset <= not reset_n;

alt_disp           <= tidn;
d_mode             <= tiup;
delay_lclkr        <= tidn;
mpw1_b             <= tidn;
mpw2_b             <= tidn;
scdis_b            <= tidn;
an_ac_ccenable_dc  <= tiup;
an_ac_scan_type_dc <= tiup & tiup & tiup & tiup & tiup & tiup & tiup & tiup & tiup;   

an_ac_func_scan_in <= (others => '0');
an_ac_regf_scan_in <= (others => '0');
an_ac_bcfg_scan_in <= (others => '0');
an_ac_dcfg_scan_in <= (others => '0');
an_ac_abst_scan_in <= (others => '0');
an_ac_gptr_scan_in <= '0';
an_ac_repr_scan_in <= '0';
an_ac_time_scan_in <= '0';
an_ac_atpg_en_dc <= '0';
an_ac_scan_dis_dc_b <= '1';
an_ac_camfence_en_dc <= '0';
an_ac_abist_start_test <= '0';
an_ac_abist_mode_dc <= '0';
an_ac_lbist_en_dc <= '0';
an_ac_lbist_ac_mode_dc <= '0';
an_ac_lbist_ip_dc <= '0';
an_ac_fce_7 <= '0';
an_ac_sg_7 <= '0';
an_ac_gsd_test_acmode_dc <= '0';
an_ac_lbist_ary_wrt_thru_dc <= '0';
an_ac_gsd_test_enable_dc <= '0';
an_ac_scan_diag_dc <= '0';
an_ac_psro_enable_dc <= (others => '0');
an_ac_ccflush_dc <= '0'; 

an_ac_flh2l2_gate <= flh2l2_gate;
an_ac_external_mchk <= ext_mchk;
an_ac_checkstop <= ext_checkstop; 
an_ac_debug_stop <= debug_stop;   
an_ac_hang_pulse <= hang_pulse;
thread_running <= ac_an_pm_thread_running;

mchk           <= ac_an_machine_check;
recov_err      <= ac_an_recov_err;
checkstop      <= ac_an_local_checkstop;      

an_ac_scom_sat_id <= scom_sat_id;
node_scom_dch_in <= scom_dch_in;
node_scom_cch_in <= scom_cch_in;
scom_dch_out <= node_scom_dch_out;
scom_cch_out <= node_scom_cch_out;

an_ac_user_defined <= (others => '0');
an_ac_req_spare_ctrl_a1 <= (others => '0');

an_ac_icbi_ack <= '0';
an_ac_icbi_ack_thread <= (others => '0');

an_ac_back_inv <= '0';
an_ac_back_inv_gs <= '0';
an_ac_back_inv_local <= '0';
an_ac_back_inv_lbit <= '0';
an_ac_back_inv_ind <= '0';
an_ac_back_inv_addr <= (others => '0');
an_ac_back_inv_lpar_id <= (others => '0');
an_ac_back_inv_target <= (others => '0');

an_ac_reld_ditc <= '0';

an_ac_dcr_act <= '0';
an_ac_dcr_val <= '0';
an_ac_dcr_read <= '0';
an_ac_dcr_etid <= (others => '0');
an_ac_dcr_data <= (others => '0');
an_ac_dcr_done <= '0';

an_ac_reset_1_complete <= '0';
an_ac_reset_2_complete <= '0';
an_ac_reset_3_complete <= '0';
an_ac_reset_wd_complete <= '0';

an_ac_sleep_en <= (others => '0'); 
an_ac_malf_alert <= '0';

acq: entity work.acq_soft(acq_soft) 
  generic map(
  error_width         => error_width,
  expand_type         => expand_type,
  expand_tlb_type     => expand_tlb_type,
  extclass_width      => extclass_width,
  inv_seq_width       => inv_seq_width,
  lpid_width          => lpid_width,
  pid_width           => pid_width,
  ra_entry_width      => ra_entry_width,
  real_addr_width     => real_addr_width,
  threads             => threads,

  xu_real_data_add    => xu_real_data_add,
  st_data_32b_mode    => st_data_32b_mode,
  ac_st_data_32b_mode => ac_st_data_32b_mode
   )
   port map (
      an_ac_back_inv          => an_ac_back_inv,
      an_ac_back_inv_addr     => an_ac_back_inv_addr,
      an_ac_back_inv_lbit     => an_ac_back_inv_lbit,
      an_ac_back_inv_gs       => an_ac_back_inv_gs,
      an_ac_back_inv_ind      => an_ac_back_inv_ind,
      an_ac_back_inv_local    => an_ac_back_inv_local,
      an_ac_back_inv_lpar_id  => an_ac_back_inv_lpar_id,
      an_ac_back_inv_target   => an_ac_back_inv_target,
      an_ac_crit_interrupt    => crit_interrupt,
      an_ac_dcr_act           => an_ac_dcr_act,
      an_ac_dcr_val           => an_ac_dcr_val,
      an_ac_dcr_read          => an_ac_dcr_read,
      an_ac_dcr_etid          => an_ac_dcr_etid,
      an_ac_dcr_data          => an_ac_dcr_data,
      an_ac_dcr_done          => an_ac_dcr_done,
      an_ac_ext_interrupt     => ext_interrupt,
      an_ac_flh2l2_gate       => an_ac_flh2l2_gate,
      an_ac_reld_core_tag     => an_ac_reld_core_tag,
      an_ac_reld_data         => an_ac_reld_data,
      an_ac_reld_data_vld     => an_ac_reld_data_vld,
      an_ac_reld_ecc_err      => an_ac_reld_ecc_err,
      an_ac_reld_ecc_err_ue   => an_ac_reld_ecc_err_ue,
      an_ac_reld_qw           => an_ac_reld_qw,
      an_ac_reld_data_coming  => an_ac_reld_data_coming,
      an_ac_reld_ditc         => an_ac_reld_ditc,
      an_ac_reld_crit_qw      => an_ac_reld_crit_qw,
      an_ac_reld_l1_dump      => an_ac_reld_l1_dump,
      an_ac_regf_scan_in      => an_ac_regf_scan_in,
      an_ac_req_ld_pop        => an_ac_req_ld_pop,
      an_ac_req_spare_ctrl_a1 => an_ac_req_spare_ctrl_a1,
      an_ac_req_st_gather     => an_ac_req_st_gather,
      an_ac_req_st_pop        => an_ac_req_st_pop,
      an_ac_req_st_pop_thrd   => an_ac_req_st_pop_thrd,
      an_ac_reservation_vld   => an_ac_reservation_vld,
      an_ac_sleep_en          => an_ac_sleep_en,
      an_ac_stcx_complete     => an_ac_stcx_complete,
      an_ac_stcx_pass         => an_ac_stcx_pass,
      an_ac_sync_ack          => an_ac_sync_ack,
      an_ac_icbi_ack          => an_ac_icbi_ack,
      an_ac_icbi_ack_thread   => an_ac_icbi_ack_thread,
      a2_nclk                 => a2_nclk,
      an_ac_abist_mode_dc     => an_ac_abist_mode_dc,
      an_ac_abist_start_test  => an_ac_abist_start_test,
      an_ac_abst_scan_in      => an_ac_abst_scan_in,
      an_ac_rtim_sl_thold_7   => thold,
      an_ac_ary_nsl_thold_7   => thold,
      an_ac_func_nsl_thold_7  => thold,
      an_ac_func_sl_thold_7   => thold,       
      an_ac_atpg_en_dc        => an_ac_atpg_en_dc,
      an_ac_bcfg_scan_in      => an_ac_bcfg_scan_in,
      an_ac_lbist_ary_wrt_thru_dc => an_ac_lbist_ary_wrt_thru_dc,
      an_ac_ccenable_dc       => an_ac_ccenable_dc,
      an_ac_ccflush_dc        => an_ac_ccflush_dc,
      an_ac_coreid            => core_id,
      an_ac_lbist_ip_dc       => an_ac_lbist_ip_dc,    
      an_ac_malf_alert        => an_ac_malf_alert,        
      an_ac_reset_1_complete  => an_ac_reset_1_complete,
      an_ac_reset_2_complete  => an_ac_reset_2_complete,
      an_ac_reset_3_complete  => an_ac_reset_3_complete,
      an_ac_reset_wd_complete => an_ac_reset_wd_complete,
      an_ac_dcfg_scan_in      => an_ac_dcfg_scan_in,
      an_ac_debug_stop        => an_ac_debug_stop,
      an_ac_external_mchk     => an_ac_external_mchk,
      an_ac_fce_7             => an_ac_fce_7,
     
      an_ac_func_scan_in      => an_ac_func_scan_in,
      an_ac_gptr_scan_in      => an_ac_gptr_scan_in,
      an_ac_gsd_test_acmode_dc => an_ac_gsd_test_acmode_dc,
      an_ac_gsd_test_enable_dc => an_ac_gsd_test_enable_dc,
      an_ac_hang_pulse        => an_ac_hang_pulse,
      an_ac_lbist_en_dc       => an_ac_lbist_en_dc,
      an_ac_lbist_ac_mode_dc  => an_ac_lbist_ac_mode_dc,
      an_ac_perf_interrupt    => perf_interrupt,
      an_ac_pm_thread_stop    => thread_stop,
      an_ac_psro_enable_dc    => an_ac_psro_enable_dc,
      an_ac_repr_scan_in      => an_ac_repr_scan_in,
      an_ac_scan_diag_dc      => an_ac_scan_diag_dc,
      an_ac_scan_dis_dc_b     => an_ac_scan_dis_dc_b,
      an_ac_scan_type_dc      => an_ac_scan_type_dc,
      an_ac_scom_cch          => node_scom_cch_in,     
      an_ac_scom_dch          => node_scom_dch_in,    
      an_ac_scom_sat_id       => an_ac_scom_sat_id,
      an_ac_sg_7              => an_ac_sg_7,
      an_ac_checkstop         => an_ac_checkstop,
      an_ac_tb_update_enable  => tb_update_enable,
      an_ac_tb_update_pulse   => tb_update_pulse,
      an_ac_time_scan_in      => an_ac_time_scan_in,
      ac_an_back_inv_reject   => ac_an_back_inv_reject,
      ac_an_box_empty         => ac_an_box_empty,
      ac_an_lpar_id           => ac_an_lpar_id,
      ac_an_machine_check     => ac_an_machine_check,
      ac_an_power_managed     => ac_an_power_managed,
      ac_an_req               => ac_an_req,
      ac_an_req_endian        => ac_an_req_endian,
      ac_an_req_ld_core_tag   => ac_an_req_ld_core_tag,
      ac_an_req_ld_xfr_len    => ac_an_req_ld_xfr_len,
      ac_an_req_pwr_token     => ac_an_req_pwr_token,
      ac_an_req_ra            => ac_an_req_ra,
      ac_an_req_spare_ctrl_a0 => ac_an_req_spare_ctrl_a0,
      ac_an_req_thread        => ac_an_req_thread,
      ac_an_req_ttype         => ac_an_req_ttype,
      ac_an_req_user_defined  => ac_an_req_user_defined,
      ac_an_req_wimg_g        => ac_an_req_wimg_g,
      ac_an_req_wimg_i        => ac_an_req_wimg_i,
      ac_an_req_wimg_m        => ac_an_req_wimg_m,
      ac_an_req_wimg_w        => ac_an_req_wimg_w,
      ac_an_reld_ditc_pop     => ac_an_reld_ditc_pop,
      ac_an_rvwinkle_mode     => ac_an_rvwinkle_mode,
      ac_an_st_byte_enbl      => ac_an_st_byte_enbl,
      ac_an_st_data           => ac_an_st_data,
      ac_an_st_data_pwr_token => ac_an_st_data_pwr_token,
      ac_an_fu_bypass_events  => ac_an_fu_bypass_events,
      ac_an_iu_bypass_events  => ac_an_iu_bypass_events,
      ac_an_mm_bypass_events  => ac_an_mm_bypass_events,
      ac_an_debug_bus         => ac_an_debug_bus,
      ac_an_event_bus         => ac_an_event_bus,
      ac_an_trace_triggers    => ac_an_trace_triggers,
      ac_an_abist_done_dc     => ac_an_abist_done_dc,
      ac_an_abst_scan_out     => ac_an_abst_scan_out,
      ac_an_bcfg_scan_out     => ac_an_bcfg_scan_out,
      ac_an_dcfg_scan_out     => ac_an_dcfg_scan_out,
      ac_an_debug_trigger     => ac_an_debug_trigger, 
      ac_an_func_scan_out     => ac_an_func_scan_out,
      ac_an_gptr_scan_out     => ac_an_gptr_scan_out,
      ac_an_pm_thread_running => ac_an_pm_thread_running,
      ac_an_psro_ringsig      => ac_an_psro_ringsig,
      ac_an_recov_err         => ac_an_recov_err,
      ac_an_repr_scan_out     => ac_an_repr_scan_out,
      ac_an_scom_cch          => node_scom_cch_out,    
      ac_an_scom_dch          => node_scom_dch_out,
      ac_an_time_scan_out     => ac_an_time_scan_out,
      ac_an_special_attn      => ac_an_special_attn,
      ac_an_checkstop         => ac_an_checkstop,
      ac_an_local_checkstop   => ac_an_local_checkstop,
      ac_an_dcr_act           => ac_an_dcr_act,
      ac_an_dcr_val           => ac_an_dcr_val,
      ac_an_dcr_read          => ac_an_dcr_read,
      ac_an_dcr_user          => ac_an_dcr_user,
      ac_an_dcr_etid          => ac_an_dcr_etid,
      ac_an_dcr_addr          => ac_an_dcr_addr,
      ac_an_dcr_data          => ac_an_dcr_data,
      an_ac_camfence_en_dc    => an_ac_camfence_en_dc, 
  
      gnd                     => gnd,
      vcs                     => vcs,
      vdd                     => vdd
   ); 
   
a2l2_axi: entity work.a2l2_axi(a2l2_axi) 
generic map(
     C_M00_AXI_ID_WIDTH	               => C_M00_AXI_ID_WIDTH,
     C_M00_AXI_ADDR_WIDTH              => C_M00_AXI_ADDR_WIDTH,
	  C_M00_AXI_DATA_WIDTH	            => C_M00_AXI_DATA_WIDTH,
     C_M00_AXI_AWUSER_WIDTH	         => C_M00_AXI_AWUSER_WIDTH,
     C_M00_AXI_ARUSER_WIDTH	         => C_M00_AXI_ARUSER_WIDTH, 
     C_M00_AXI_WUSER_WIDTH	            => C_M00_AXI_WUSER_WIDTH,
     C_M00_AXI_RUSER_WIDTH	            => C_M00_AXI_RUSER_WIDTH,
     C_M00_AXI_BUSER_WIDTH	            => C_M00_AXI_BUSER_WIDTH
     )
port map(
		clk                     => clk,
		reset_n                 => reset_n,
		err                     => a2l2_axi_err,
      ac_an_req               => ac_an_req,
      ac_an_req_endian        => ac_an_req_endian,
      ac_an_req_ld_core_tag   => ac_an_req_ld_core_tag,
      ac_an_req_ld_xfr_len    => ac_an_req_ld_xfr_len,
      ac_an_req_pwr_token     => ac_an_req_pwr_token,
      ac_an_req_ra            => ac_an_req_ra,
      ac_an_req_thread        => ac_an_req_thread,
      ac_an_req_ttype         => ac_an_req_ttype,
      ac_an_req_user_defined  => ac_an_req_user_defined,
      ac_an_req_wimg_g        => ac_an_req_wimg_g,
      ac_an_req_wimg_i        => ac_an_req_wimg_i,
      ac_an_req_wimg_m        => ac_an_req_wimg_m,
      ac_an_req_wimg_w        => ac_an_req_wimg_w,
      ac_an_st_byte_enbl      => ac_an_st_byte_enbl,
      ac_an_st_data           => ac_an_st_data,
      ac_an_st_data_pwr_token => ac_an_st_data_pwr_token,     
      an_ac_reld_core_tag     => an_ac_reld_core_tag,
      an_ac_reld_data         => an_ac_reld_data,
      an_ac_reld_data_vld     => an_ac_reld_data_vld,
      an_ac_reld_ecc_err      => an_ac_reld_ecc_err,
      an_ac_reld_ecc_err_ue   => an_ac_reld_ecc_err_ue,
      an_ac_reld_qw           => an_ac_reld_qw,
      an_ac_reld_data_coming  => an_ac_reld_data_coming,
      an_ac_reld_crit_qw      => an_ac_reld_crit_qw,
      an_ac_reld_l1_dump      => an_ac_reld_l1_dump,
      an_ac_req_ld_pop        => an_ac_req_ld_pop,
      an_ac_req_st_pop        => an_ac_req_st_pop,
      an_ac_req_st_gather     => an_ac_req_st_gather,      
      an_ac_req_st_pop_thrd   => an_ac_req_st_pop_thrd,
      an_ac_reservation_vld   => an_ac_reservation_vld,      
      an_ac_stcx_complete     => an_ac_stcx_complete,
      an_ac_stcx_pass         => an_ac_stcx_pass,
      an_ac_sync_ack          => an_ac_sync_ack,
		m00_axi_awid	 =>  m00_axi_awid,
		m00_axi_awaddr	 =>  m00_axi_awaddr,
		m00_axi_awlen	 =>  m00_axi_awlen,
		m00_axi_awsize	 =>  m00_axi_awsize,
		m00_axi_awburst	 =>  m00_axi_awburst,
		m00_axi_awlock	 =>  m00_axi_awlock,
		m00_axi_awcache	 =>  m00_axi_awcache,
		m00_axi_awprot	 =>  m00_axi_awprot,
		m00_axi_awqos	 =>  m00_axi_awqos,
		m00_axi_awuser	 =>  m00_axi_awuser,
		m00_axi_awvalid	 =>  m00_axi_awvalid,
		m00_axi_awready	 =>  m00_axi_awready,
		m00_axi_wdata	 =>  m00_axi_wdata,
		m00_axi_wstrb	 =>  m00_axi_wstrb,
		m00_axi_wlast	 =>  m00_axi_wlast,
		m00_axi_wuser	 =>  m00_axi_wuser,
		m00_axi_wvalid	 =>  m00_axi_wvalid,
		m00_axi_wready	 =>  m00_axi_wready,
		m00_axi_bid	 =>  m00_axi_bid,
		m00_axi_bresp	 =>  m00_axi_bresp,
		m00_axi_buser	 =>  m00_axi_buser,
		m00_axi_bvalid	 =>  m00_axi_bvalid,
		m00_axi_bready	 =>  m00_axi_bready,
		m00_axi_arid	 =>  m00_axi_arid,
		m00_axi_araddr	 =>  m00_axi_araddr,
		m00_axi_arlen	 =>  m00_axi_arlen,
		m00_axi_arsize	 =>  m00_axi_arsize,
		m00_axi_arburst	 =>  m00_axi_arburst,
		m00_axi_arlock	 =>  m00_axi_arlock,
		m00_axi_arcache	 =>  m00_axi_arcache,
		m00_axi_arprot	 =>  m00_axi_arprot,
		m00_axi_arqos	 =>  m00_axi_arqos,
		m00_axi_aruser	 =>  m00_axi_aruser,
		m00_axi_arvalid	 =>  m00_axi_arvalid,
		m00_axi_arready	 =>  m00_axi_arready,
		m00_axi_rid	 =>  m00_axi_rid,
		m00_axi_rdata	 =>  m00_axi_rdata,
		m00_axi_rresp	 =>  m00_axi_rresp,
		m00_axi_rlast	 =>  m00_axi_rlast,
		m00_axi_ruser	 =>  m00_axi_ruser,
		m00_axi_rvalid	 =>  m00_axi_rvalid,
		m00_axi_rready	 =>  m00_axi_rready
	   );

end a2x_axi;
