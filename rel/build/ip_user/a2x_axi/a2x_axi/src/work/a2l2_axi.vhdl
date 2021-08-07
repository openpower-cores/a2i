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

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.all;
use work.a2x_pkg.all;

entity a2l2_axi is
	generic (
     threads                              : integer := 4;
     xu_real_data_add                     : integer := 42;     
     st_data_32b_mode                     : integer := 1;   
     ac_st_data_32b_mode                  : integer := 1;
     stores_32B                           : boolean := false;   
     lpid_width                           : integer := 8; 
     ld_queue_size                        : integer := 4;    
     st_queue_size                        : integer := 16;
     C_m00_AXI_ID_WIDTH	                  : integer := 4;
     C_m00_AXI_ADDR_WIDTH	               : integer := 32;
	  C_m00_AXI_DATA_WIDTH	               : integer := 32;
     C_m00_AXI_AWUSER_WIDTH	            : integer := 4;
     C_m00_AXI_ARUSER_WIDTH	            : integer := 4;
     C_m00_AXI_WUSER_WIDTH	               : integer := 4;
     C_m00_AXI_RUSER_WIDTH	               : integer := 4;
     C_m00_AXI_BUSER_WIDTH	               : integer := 4
	);
	port (
		clk                        : in     std_logic; 
		reset_n                    : in     std_logic;
		err                        : out    std_logic_vector(0 to 3);
		      
      ac_an_req_pwr_token        : in     std_logic;
      ac_an_req                  : in     std_logic;
      ac_an_req_endian           : in     std_logic;
      ac_an_req_ld_core_tag      : in     std_logic_vector(0 to 4);
      ac_an_req_ld_xfr_len       : in     std_logic_vector(0 to 2);
      ac_an_req_ra               : in     std_logic_vector(64-xu_real_data_add to 63);
      ac_an_req_thread           : in     std_logic_vector(0 to 2);
      ac_an_req_ttype            : in     std_logic_vector(0 to 5);
      ac_an_req_user_defined     : in     std_logic_vector(0 to 3);
      ac_an_req_wimg_g           : in     std_logic;
      ac_an_req_wimg_i           : in     std_logic;
      ac_an_req_wimg_m           : in     std_logic;
      ac_an_req_wimg_w           : in     std_logic;

      ac_an_st_data_pwr_token    : in     std_logic;       
      ac_an_st_byte_enbl         : in     std_logic_vector(0 to 15+(st_data_32b_mode*16));
      ac_an_st_data              : in     std_logic_vector(0 to 127+(st_data_32b_mode*128));
      
      an_ac_reld_data_coming     : out    std_logic;
      an_ac_reld_core_tag        : out    std_logic_vector(0 to 4);
      an_ac_reld_data            : out    std_logic_vector(0 to 127);
      an_ac_reld_data_vld        : out    std_logic;
      an_ac_reld_ecc_err         : out    std_logic;
      an_ac_reld_ecc_err_ue      : out    std_logic;
      an_ac_reld_qw              : out    std_logic_vector(57 to 59);
      an_ac_reld_crit_qw         : out    std_logic;
      an_ac_reld_l1_dump         : out    std_logic;
      
      an_ac_req_ld_pop           : out    std_logic;
      an_ac_req_st_pop           : out    std_logic;      
      an_ac_req_st_gather        : out    std_logic;
      an_ac_req_st_pop_thrd      : out    std_logic_vector(0 to 2);
      an_ac_reservation_vld      : out    std_logic_vector(0 to threads-1);
      an_ac_stcx_complete        : out    std_logic_vector(0 to 3);
      an_ac_stcx_pass            : out    std_logic_vector(0 to 3);
      an_ac_sync_ack             : out    std_logic_vector(0 to 3);

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
end a2l2_axi;

architecture a2l2_axi of a2l2_axi is

signal reload_d: A2L2RELOAD;
signal reload_q: A2L2RELOAD;	
   
signal rld_seq_d      : std_logic_vector(0 to 4);
signal rld_seq_q      : std_logic_vector(0 to 4);
signal rld_dseq_d     : std_logic_vector(0 to 3);
signal rld_dseq_q     : std_logic_vector(0 to 3);     	
	
signal req_pwr_d: std_logic;
signal req_pwr_q: std_logic;
signal store_pwr_d: std_logic;
signal store_pwr_q: std_logic;
	
signal load_queue_d: LOADQUEUE;
signal load_queue_q: LOADQUEUE;	
signal ldq_head_d: std_logic_vector(0 to clog2(ld_queue_size)-1);
signal ldq_head_q: std_logic_vector(0 to clog2(ld_queue_size)-1);	
signal ldq_send_d: std_logic_vector(0 to clog2(ld_queue_size)-1);
signal ldq_send_q: std_logic_vector(0 to clog2(ld_queue_size)-1);	
signal ldq_data_d: std_logic_vector(0 to clog2(ld_queue_size)-1);
signal ldq_data_q: std_logic_vector(0 to clog2(ld_queue_size)-1);			
signal ldq_tail_d: std_logic_vector(0 to clog2(ld_queue_size)-1);	
signal ldq_tail_q: std_logic_vector(0 to clog2(ld_queue_size)-1);	
signal ldq_count_d: std_logic_vector(0 to clog2(ld_queue_size));	
signal ldq_count_q: std_logic_vector(0 to clog2(ld_queue_size)); 
signal load_dep_d: LOADQUEUEDEP;
signal load_dep_q: LOADQUEUEDEP;
   
signal load_data_ready_d, load_data_ready_q : std_logic;
signal load_data_queue_d  : LOADDATAQUEUE;
signal load_data_queue_q  : LOADDATAQUEUE;   
signal rdataq_head_d      : std_logic_vector(0 to clog2(ld_queue_size*16)-1);   
signal rdataq_head_q      : std_logic_vector(0 to clog2(ld_queue_size*16)-1);     
signal rdataq_tail_d      : std_logic_vector(0 to clog2(ld_queue_size*16)-1);   
signal rdataq_tail_q      : std_logic_vector(0 to clog2(ld_queue_size*16)-1);    

signal store_queue_d      : STOREQUEUE;
signal store_queue_q      : STOREQUEUE;   
signal store_data_queue_d : STOREDATAQUEUE;
signal store_data_queue_q : STOREDATAQUEUE;   
signal store_rsp_ready_d, store_rsp_ready_q : std_logic;
signal stq_head_d: std_logic_vector(0 to clog2(st_queue_size)-1);
signal stq_head_q: std_logic_vector(0 to clog2(st_queue_size)-1);	
signal stq_send_d: std_logic_vector(0 to clog2(st_queue_size)-1);
signal stq_send_q: std_logic_vector(0 to clog2(st_queue_size)-1);	
signal stq_data_d: std_logic_vector(0 to clog2(st_queue_size)-1);
signal stq_data_q: std_logic_vector(0 to clog2(st_queue_size)-1);			
signal stq_tail_d: std_logic_vector(0 to clog2(st_queue_size)-1);	
signal stq_tail_q: std_logic_vector(0 to clog2(st_queue_size)-1);	
signal stq_count_d: std_logic_vector(0 to clog2(st_queue_size));	
signal stq_count_q: std_logic_vector(0 to clog2(st_queue_size));    
signal st_data_xfer_d: std_logic_vector(0 to 2);
signal st_data_xfer_q: std_logic_vector(0 to 2);	
signal store_pop_pending_d: std_logic_vector(0 to clog2(st_queue_size)-1);	
signal store_pop_pending_q: std_logic_vector(0 to clog2(st_queue_size)-1);   
signal store_dep_d: STOREQUEUEDEP;
signal store_dep_q: STOREQUEUEDEP;	

signal resv_d: RESVARRAY;
signal resv_q: RESVARRAY;

signal req_p1_d: A2L2REQUEST;   
signal req_p1_q: A2L2REQUEST;   
signal ld_p1_entry_d: std_logic_vector(0 to clog2(ld_queue_size));
signal ld_p1_entry_q: std_logic_vector(0 to clog2(ld_queue_size));
signal st_p1_entry_d: std_logic_vector(0 to clog2(st_queue_size));
signal st_p1_entry_q: std_logic_vector(0 to clog2(st_queue_size));
signal status_d: A2L2STATUS;
signal status_q: A2L2STATUS;
signal err_d, err_q: std_logic_vector(0 to 3);

signal axi_load_ready   : std_logic;    
signal axi_load_valid   : std_logic; 
signal axi_load_id      : std_logic_vector(C_M00_AXI_ID_WIDTH-1 downto 0);
signal axi_load_ra      : std_logic_vector(C_M00_AXI_ADDR_WIDTH-1 downto 0);
signal axi_load_ra_hi   : std_logic_vector(C_M00_AXI_ADDR_WIDTH-1 downto 6);   
signal axi_load_ra_lo   : std_logic_vector(5 downto 0);      
signal axi_load_len     : std_logic_vector(6 downto 0);   
signal axi_load_mod     : std_logic_vector(11 downto 0);

signal axi_load_data_ready  : std_logic;   
signal axi_load_data_valid  : std_logic;
signal axi_load_data_id     : std_logic_vector(C_M00_AXI_ID_WIDTH-1 downto 0);
signal axi_load_data_resp   : std_logic_vector(1 downto 0);
signal axi_load_data_last   : std_logic;
signal axi_load_data        : std_logic_vector(C_M00_AXI_DATA_WIDTH-1 downto 0);   

signal axi_store_valid      : std_logic; 
signal axi_store_id         : std_logic_vector(C_M00_AXI_ID_WIDTH-1 downto 0);
signal axi_store_ra         : std_logic_vector(C_M00_AXI_ADDR_WIDTH-1 downto 0);
signal axi_store_len        : std_logic_vector(6 downto 0);   
signal axi_store_mod        : std_logic_vector(11 downto 0);

signal axi_store_data_ready : std_logic; 
signal axi_store_data_valid : std_logic; 
signal axi_store_data       : std_logic_vector(C_M00_AXI_DATA_WIDTH-1 downto 0);
signal axi_store_data_be    : std_logic_vector(C_M00_AXI_DATA_WIDTH/8-1 downto 0); 

signal axi_store_rsp_ready : std_logic;   
signal axi_store_rsp_valid : std_logic;
signal axi_store_rsp_id    : std_logic_vector(C_M00_AXI_ID_WIDTH-1 downto 0);
signal axi_store_rsp_resp  : std_logic_vector(1 downto 0);
signal store_complete      : std_logic;

signal store_data_in       : std_logic_vector(0 to 127);
signal store_be_in         : std_logic_vector(0 to 15);
  
signal req_in: A2L2REQUEST;   
signal req_clr : A2L2REQUEST;
signal ld_req: A2L2REQUEST;
signal req_in_load  : std_logic;
signal load_len     : std_logic_vector(6 downto 0);   
signal ldq_oflow : std_logic;
signal ldq_uflow : std_logic;
signal ldq_write_sel: std_logic_vector(0 to 2);  
signal ldq_count_sel: std_logic_vector(0 to 1);      
signal axi_load_taken : std_logic;    
signal load_queue_clr : A2L2REQUEST;
signal load_queue_fb  : LOADQUEUE;   
signal load_complete  : std_logic;
signal ldq_valid_rst  : std_logic_vector(0 to ld_queue_size-1);
signal ldq_sent_set   : std_logic_vector(0 to ld_queue_size-1);
signal ldq_data_set   : std_logic_vector(0 to ld_queue_size-1); 
signal ldq_data_rst   : std_logic_vector(0 to ld_queue_size-1);     
signal rdataq_write_sel  : std_logic_vector(0 to 63);
signal rld_single : std_logic; 
signal rld_ready : std_logic;     
signal rld_data_ready : std_logic;    
signal rld_tag : std_logic_vector(0 to 4);
signal rdataq_head_sel : std_logic_vector(0 to 1);
signal rld_complete : std_logic;
signal rld_crit_qw : std_logic_vector(0 to 1);
signal rld_data_0 : std_logic_vector(0 to 31);   
signal rld_data_1 : std_logic_vector(0 to 31);   
signal rld_data_2 : std_logic_vector(0 to 31);   
signal rld_data_3 : std_logic_vector(0 to 31);      
signal rld_data_4 : std_logic_vector(0 to 31);        
signal rld_data_5 : std_logic_vector(0 to 31);        
signal rld_data_6 : std_logic_vector(0 to 31);        
signal rld_data_7 : std_logic_vector(0 to 31);        
signal rld_data_8 : std_logic_vector(0 to 31);        
signal rld_data_9 : std_logic_vector(0 to 31);        
signal rld_data_10 : std_logic_vector(0 to 31);                            
signal rld_data_11 : std_logic_vector(0 to 31);        
signal rld_data_12 : std_logic_vector(0 to 31);        
signal rld_data_13 : std_logic_vector(0 to 31);        
signal rld_data_14 : std_logic_vector(0 to 31);        
signal rld_data_15 : std_logic_vector(0 to 31);    
signal rld_data_qw0 : std_logic_vector(0 to 127); 
signal rld_data_qw1 : std_logic_vector(0 to 127);                                             
signal rld_data_qw2 : std_logic_vector(0 to 127);                                             
signal rld_data_qw3 : std_logic_vector(0 to 127);                                                                                                  
signal rld_seq_err : std_logic;
signal rld_dseq_err : std_logic;
signal rld_data_valid : std_logic;
signal start_rld_data : std_logic;       
signal rld_data_qw : std_logic_vector(0 to 1);
signal st_req_send : A2L2REQUEST;
signal st_req_data : A2L2REQUEST;
signal req_in_store: std_logic;
signal store_queue_clr : A2L2REQUEST;
signal store_queue_fb  : STOREQUEUE;     
signal store_data_queue_clr : A2L2STOREDATA;
signal st_data : A2L2STOREDATA;
signal stq_count_sel: std_logic_vector(0 to 1);     
signal axi_store_ready : std_logic;    
signal store_taken : std_logic;    
signal store_advance : std_logic;    
signal axi_store_data_taken : std_logic;    
signal axi_store_data_last : std_logic;    
signal stq_valid_rst  : std_logic_vector(0 to st_queue_size-1);     
signal stq_sent_set  : std_logic_vector(0 to st_queue_size-1);     
signal stq_data_rst  : std_logic_vector(0 to st_queue_size-1);   
signal st_data_last_xfer : std_logic; 
signal st_data_xfer_hold : std_logic; 
signal st_data_xfer_inc : std_logic; 
signal st_data_xfer_done : std_logic; 
signal stq_oflow : std_logic;
signal stq_uflow : std_logic;       
signal req_in_spec: std_logic;
signal req_p1_addr_hit_lhs : std_logic_vector(0 to st_queue_size-1);
signal req_p1_sync_lhs :  std_logic_vector(0 to st_queue_size-1);
signal req_p1_any_lhs: std_logic_vector(0 to st_queue_size-1);
signal req_p1_addr_hit_shl: std_logic_vector(0 to ld_queue_size-1);
signal req_p1_sync_shl: std_logic_vector(0 to ld_queue_size-1);
signal req_p1_any_shl: std_logic_vector(0 to ld_queue_size-1);
signal ld_req_stall: std_logic;
signal st_req_stall: std_logic;
signal load_queue_set_dep : std_logic_vector(0 to ld_queue_size-1);
signal load_queue_rst_dep : std_logic_vector(0 to ld_queue_size-1);
signal store_queue_set_dep : std_logic_vector(0 to st_queue_size-1);
signal store_queue_rst_dep : std_logic_vector(0 to st_queue_size-1);
signal lhs_ordered : std_logic_vector(0 to st_queue_size-1);     
signal lhs_ordered_youngest : std_logic_vector(0 to st_queue_size-1);                                     
signal lhs_youngest : std_logic_vector(0 to st_queue_size-1);     
signal lhs_entry : std_logic_vector(0 to 1+clog2(st_queue_size-1)-1); 
signal shl_ordered : std_logic_vector(0 to ld_queue_size-1);     
signal shl_ordered_youngest : std_logic_vector(0 to ld_queue_size-1);                                     
signal shl_youngest : std_logic_vector(0 to ld_queue_size-1);     
signal shl_entry : std_logic_vector(0 to 1+clog2(ld_queue_size-1)-1); 
signal reload_clr : A2L2RELOAD;
signal resv_clr : A2L2RESV;
signal status_clr : A2L2STATUS;
signal req_ra_line : std_logic_vector(64-xu_real_data_add to 59);
signal larx_t : std_logic_vector(0 to 3);
signal stcx_t : std_logic_vector(0 to 3);
signal store_t : std_logic_vector(0 to 3);
signal stcx_store_t : std_logic_vector(0 to 3);
signal resv_ra_hit : std_logic_vector(0 to 3);
signal resv_set : std_logic_vector(0 to 3);
signal resv_rst : std_logic_vector(0 to 3);
signal store_spec_valid : std_logic;
signal lwsync_complete : std_logic;
signal hwsync_complete : std_logic;
signal store_spec_complete : std_logic;
signal hwsync_valid : std_logic;
signal lwsync_valid : std_logic;
signal store_pop_delayed : std_logic;
signal store_rsp_complete : std_logic;
signal store_pop_pending_sel : std_logic_vector(0 to 2);
signal ld_dep: std_logic_vector(0 to clog2(st_queue_size));    
signal st_dep: std_logic_vector(0 to clog2(ld_queue_size));    

begin

req_clr <= (valid => '0', sent => '0', data => '0', dseq => (others => '0'), endian => '0', tag => (others => '0'), len => (others => '0'),
            ra => (others => '0'), thread => (others => '0'), ditc => '0', spec => '0', ttype => (others => '0'), user => (others => '0'), wimg => (others => '0'), hwsync => '0');
load_queue_clr <= req_clr;
reload_clr <= (valid => '0', coming => '0', tag => (others => '0'), data => (others => '0'), qw => (others => '0'), crit => '0', dump => '0', ee => '0', ue => '0');   
store_queue_clr <= req_clr;                 
store_data_queue_clr <= (data => (others => '0'), be => (others => '0'));  
status_clr <= (ld_pop => '0', st_pop => '0', st_pop_thrd => (others => '0'), gather => '0', res_valid => (others => '0'), stcx_complete => (others => '0'),
               stcx_pass => (others => '0'), sync_ack => (others => '0'));
resv_clr <= (valid => '0', ra => (others => '0'));
                   
FF: process(clk) begin
	
if rising_edge(clk) then
	
   if reset_n = '0' then 
	   
      req_pwr_q <= '0';
      req_p1_q <= req_clr;
      ld_p1_entry_q <= (others => '0');
      st_p1_entry_q <= (others => '0');      
      rld_seq_q <= (others => '1');
      rld_dseq_q <= (others => '1');                             
      ldq_count_q <= (others => '0');	      
      ldq_head_q <= (others => '0');
      ldq_send_q <= (others => '0');      
      ldq_data_q <= (others => '0');               
      ldq_tail_q <= (others => '0');
      for i in 0 to 63 loop
         load_data_queue_q(i) <= (others => '0');
      end loop;
      rdataq_head_q <= (others => '0');
      rdataq_tail_q <= (others => '0');
      reload_q <= reload_clr;            
 	   store_pwr_q <= '0';	  
      for i in 0 to 3 loop
         load_queue_q(i) <= load_queue_clr;  
         load_dep_q(i) <= (others => '0');           
      end loop;	
      for i in 0 to st_queue_size-1 loop
         store_queue_q(i) <= store_queue_clr;         
         store_data_queue_q(i) <= store_data_queue_clr; 
         store_dep_q(i) <= (others => '0');                
      end loop;	      
      stq_count_q <= (others => '0');	      
      stq_head_q <= (others => '0');
      stq_send_q <= (others => '0');      
      stq_data_q <= (others => '0');               
      stq_tail_q <= (others => '0');     
      st_data_xfer_q <= (others => '0');          
      store_pop_pending_q <= (others => '0');               
	   status_q <= status_clr;
      for i in 0 to 3 loop
   	   resv_q(i) <= resv_clr;
   	end loop;
   	load_data_ready_q <= '0';
   	store_rsp_ready_q <= '0';
   	err_q <= (others => '0');
	                	              
	else
	    
	   req_pwr_q <= req_pwr_d;
	   req_p1_q <= req_p1_d;
	   ld_p1_entry_q <= ld_p1_entry_d;
	   st_p1_entry_q <= st_p1_entry_d;	   
      rld_seq_q <= rld_seq_d;	      
      rld_dseq_q <= rld_dseq_d;	               
	   ldq_count_q <= ldq_count_d;
	   ldq_head_q <= ldq_head_d;
	   ldq_send_q <= ldq_send_d;	
	   ldq_data_q <= ldq_data_d;	      	            
	   ldq_tail_q <= ldq_tail_d;
      for i in 0 to 63 loop
         load_data_queue_q(i) <= load_data_queue_d(i);
      end loop;
      rdataq_head_q <= rdataq_head_d;
      rdataq_tail_q <= rdataq_tail_d;         
      reload_q <= reload_d;
	   store_pwr_q <= store_pwr_d; 
      for i in 0 to 3 loop
   	   load_queue_q(i) <= load_queue_d(i);
         load_dep_q(i) <= load_dep_d(i); 
      end loop;
      for i in 0 to st_queue_size-1 loop  	   
   	   store_queue_q(i) <= store_queue_d(i);         	         
         store_data_queue_q(i) <= store_data_queue_d(i);
         store_dep_q(i) <= store_dep_d(i);          
      end loop;	
      stq_count_q <= stq_count_d;	      
      stq_head_q <= stq_head_d;
      stq_send_q <= stq_send_d;      
      stq_data_q <= stq_data_d;               
      stq_tail_q <= stq_tail_d;    
      st_data_xfer_q <= st_data_xfer_d; 
      store_pop_pending_q <= store_pop_pending_d;         	        	      	      
      status_q <= status_d;
      for i in 0 to 3 loop      
         resv_q(i) <= resv_d(i);
      end loop;
   	load_data_ready_q <= load_data_ready_d;
   	store_rsp_ready_q <= store_rsp_ready_d;
   	err_q <= err_d;
	      
   end if;
	
end if;
	
end process FF;



 

req_pwr_d <= ac_an_req_pwr_token; 
 
req_in.valid <= ac_an_req and req_pwr_q;
req_in.sent <= '0';
req_in.data <= '0';
req_in.endian <= ac_an_req_endian;
req_in.tag <= ac_an_req_ld_core_tag;
req_in.len <= ac_an_req_ld_xfr_len;
req_in.ra <= ac_an_req_ra;
req_in.thread <= ac_an_req_thread(0 to 1);
req_in.ditc <= ac_an_req_thread(2);
req_in.spec <= req_in_spec;
req_in.ttype <= ac_an_req_ttype;
req_in.user <= ac_an_req_user_defined;
req_in.wimg <= ac_an_req_wimg_w & ac_an_req_wimg_i & ac_an_req_wimg_m & ac_an_req_wimg_g;
req_in.hwsync <= req_in.spec; 


    
with req_in_load select
   ldq_tail_d <= inc(ldq_tail_q) when '1',
                 ldq_tail_q      when others;

ldq_write_sel <= req_in_load & ldq_tail_q;
   
gen_load_queue_fb: for i in 0 to 3 generate
   
   load_queue_fb(i).valid  <= load_queue_q(i).valid and not ldq_valid_rst(i);
   load_queue_fb(i).sent   <= (load_queue_q(i).sent or ldq_sent_set(i)) and not ldq_valid_rst(i);
   load_queue_fb(i).data   <= (load_queue_q(i).data or ldq_data_set(i)) and not ldq_data_rst(i);
   load_queue_fb(i).dseq   <= "000";        
   load_queue_fb(i).endian <= load_queue_q(i).endian;
   load_queue_fb(i).tag    <= load_queue_q(i).tag;
   load_queue_fb(i).len    <= load_queue_q(i).len;
   load_queue_fb(i).ra     <= load_queue_q(i).ra; 
   load_queue_fb(i).thread <= load_queue_q(i).thread;   
   load_queue_fb(i).ditc   <= load_queue_q(i).ditc;
   load_queue_fb(i).spec   <= load_queue_q(i).spec;
   load_queue_fb(i).ttype  <= load_queue_q(i).ttype;    
   load_queue_fb(i).user   <= load_queue_q(i).user;     
   load_queue_fb(i).wimg   <= load_queue_q(i).wimg;       
   load_queue_fb(i).hwsync <= load_queue_q(i).hwsync;

   load_dep_d(i) <= gate_and(load_queue_set_dep(i), lhs_entry) or 
                    gate_and(not load_queue_set_dep(i) and not load_queue_rst_dep(i), load_dep_q(i));

   
end generate;
  
with ldq_write_sel select
     load_queue_d(0) <= req_in           when "100",
                        load_queue_fb(0) when others;
with ldq_write_sel select
     load_queue_d(1) <= req_in           when "101",
                        load_queue_fb(1) when others;
with ldq_write_sel select
     load_queue_d(2) <= req_in           when "110",
                        load_queue_fb(2) when others;                         
with ldq_write_sel select
     load_queue_d(3) <= req_in           when "111",
                        load_queue_fb(3) when others;
                            
axi_load_id <= "0000";  
   
with ldq_send_q select
   ld_req <= load_queue_q(0) when "00",
             load_queue_q(1) when "01",
             load_queue_q(2) when "10",
             load_queue_q(3) when others; 

with ldq_send_q select
   ld_dep <= load_dep_q(0) when "00",
             load_dep_q(1) when "01",
             load_dep_q(2) when "10",
             load_dep_q(3) when others; 

axi_load_valid <= ld_req.valid and not ld_req.sent and not ld_req_stall;
   
axi_load_ra_hi <= ld_req.ra(64-C_M00_AXI_ADDR_WIDTH to 57);
with ld_req.wimg(1) select
   axi_load_ra_lo <= "000000"            when '0',
                     ld_req.ra(58 to 63) when others;
axi_load_ra <= axi_load_ra_hi & axi_load_ra_lo;
   
axi_load_mod <= "000000000000";

with ld_req.len select 
   load_len <= "0000001" when "001",
               "0000010" when "010",
               "0000100" when "100",               
               "0001000" when "101",               
               "0010000" when "110",               
               "0100000" when others;       

with ld_req.wimg(1) select 
   axi_load_len <= load_len  when '1',
                   "1000000" when others;   

axi_load_taken <= axi_load_valid and axi_load_ready;     
   
ldq_sent_set(0) <= axi_load_taken and eq(ldq_send_q, "00");
ldq_sent_set(1) <= axi_load_taken and eq(ldq_send_q, "01");
ldq_sent_set(2) <= axi_load_taken and eq(ldq_send_q, "10");
ldq_sent_set(3) <= axi_load_taken and eq(ldq_send_q, "11");              
                                                                                                      
with axi_load_taken select
   ldq_send_d <= inc(ldq_send_q) when '1',
                 ldq_send_q      when others;
    
ldq_data_set(0) <= axi_load_data_last and eq(ldq_data_q, "00");
ldq_data_set(1) <= axi_load_data_last and eq(ldq_data_q, "01");
ldq_data_set(2) <= axi_load_data_last and eq(ldq_data_q, "10");
ldq_data_set(3) <= axi_load_data_last and eq(ldq_data_q, "11"); 

with axi_load_data_last select
   ldq_data_d <= inc(ldq_data_q) when '1',
                 ldq_data_q      when others;   
    
with load_complete select
    ldq_head_d <= inc(ldq_head_q) when '1',
                  ldq_head_q      when others;

ldq_count_sel <= req_in_load & load_complete;
with ldq_count_sel select
   ldq_count_d <= inc(ldq_count_q) when "10",
                  dec(ldq_count_q) when "01",
                  ldq_count_q      when others;                    
                       
ldq_oflow <= eq(ldq_count_q, "100") and eq(ldq_count_sel, "10");
ldq_uflow <= eq(ldq_count_q, "000") and eq(ldq_count_sel, "01");                  


load_data_ready_d <= '1';
axi_load_data_ready <= load_data_ready_q;
      
with axi_load_data_valid select
   rdataq_tail_d <= inc(rdataq_tail_q) when '1',
                    rdataq_tail_q      when others;
   
  
      
gen_load_load_data_queue: for i in 0 to 63 generate
   rdataq_write_sel(i) <= axi_load_data_valid and eq(rdataq_tail_q, i);   
   with rdataq_write_sel(i) select
      load_data_queue_d(i) <= axi_load_data(7 downto 0) & axi_load_data(15 downto 8) & axi_load_data(23 downto 16) & axi_load_data(31 downto 24) when '1',
                              load_data_queue_q(i)                                                                                               when others;
end generate;                     


with ldq_head_q select
   rld_data_valid <= load_queue_q(0).valid and load_queue_q(0).data when "00",
                     load_queue_q(1).valid and load_queue_q(1).data when "01",
                     load_queue_q(2).valid and load_queue_q(2).data when "10",
                     load_queue_q(3).valid and load_queue_q(3).data when others; 

with ldq_head_q select
   rld_tag <= load_queue_q(0).tag when "00",
              load_queue_q(1).tag when "01",
              load_queue_q(2).tag when "10",
              load_queue_q(3).tag when others;      

with ldq_head_q select
   rld_single <= load_queue_q(0).wimg(1) when "00",
                 load_queue_q(1).wimg(1) when "01",
                 load_queue_q(2).wimg(1) when "10",
                 load_queue_q(3).wimg(1) when others;      
  
with ldq_head_q select
   rld_crit_qw <= load_queue_q(0).ra(58 to 59) when "00",
                  load_queue_q(1).ra(58 to 59) when "01",
                  load_queue_q(2).ra(58 to 59) when "10",
                  load_queue_q(3).ra(58 to 59) when others;                                              

reload_d.tag <= rld_tag;
reload_d.ue <= '0';
reload_d.ee <= '0';                              
reload_d.dump <= '0';

rld_ready <= axi_load_data_last or rld_data_valid; 

ldq_data_rst(0) <= start_rld_data and eq(ldq_head_q, "00");
ldq_data_rst(1) <= start_rld_data and eq(ldq_head_q, "01");
ldq_data_rst(2) <= start_rld_data and eq(ldq_head_q, "10");
ldq_data_rst(3) <= start_rld_data and eq(ldq_head_q, "11");



   
load_complete <= rld_complete; 
   
ldq_valid_rst(0) <= rld_complete and eq(ldq_head_q, "00");
ldq_valid_rst(1) <= rld_complete and eq(ldq_head_q, "01");
ldq_valid_rst(2) <= rld_complete and eq(ldq_head_q, "10");
ldq_valid_rst(3) <= rld_complete and eq(ldq_head_q, "11");     
   
status_d.ld_pop <= rld_complete;      

an_ac_reld_data_coming <= reload_q.coming;
an_ac_reld_data_vld <= reload_q.valid;   
an_ac_reld_core_tag <= reload_q.tag;
an_ac_reld_qw <= reload_q.qw;   
an_ac_reld_crit_qw <= reload_q.crit;
an_ac_reld_ecc_err <= reload_q.ee;
an_ac_reld_ecc_err_ue <= reload_q.ue;
an_ac_reld_l1_dump <= reload_q.dump;
an_ac_reld_data <= reload_q.data; 
     
an_ac_req_ld_pop <= status_q.ld_pop;            
an_ac_req_st_pop <= status_q.st_pop;
an_ac_req_st_pop_thrd <= status_q.st_pop_thrd;
an_ac_req_st_gather <= status_q.gather;   
an_ac_reservation_vld <= status_q.res_valid;
an_ac_stcx_complete <= status_q.stcx_complete;
an_ac_stcx_pass <= status_q.stcx_pass;
an_ac_sync_ack <= status_q.sync_ack;
   
rdataq_head_sel <= rld_complete & rld_single;
with rdataq_head_sel select
  rdataq_head_d <= inc(rdataq_head_q, 4)  when "11",
                   inc(rdataq_head_q, 16) when "10",
                   rdataq_head_q          when others;

rld_data_0  <= mux_queue(load_data_queue_q, rdataq_head_q);
rld_data_1  <= mux_queue(load_data_queue_q, inc(rdataq_head_q, 1));   
rld_data_2  <= mux_queue(load_data_queue_q, inc(rdataq_head_q, 2));   
rld_data_3  <= mux_queue(load_data_queue_q, inc(rdataq_head_q, 3));   
rld_data_4  <= mux_queue(load_data_queue_q, inc(rdataq_head_q, 4));   
rld_data_5  <= mux_queue(load_data_queue_q, inc(rdataq_head_q, 5));   
rld_data_6  <= mux_queue(load_data_queue_q, inc(rdataq_head_q, 6));   
rld_data_7  <= mux_queue(load_data_queue_q, inc(rdataq_head_q, 7));   
rld_data_8  <= mux_queue(load_data_queue_q, inc(rdataq_head_q, 8));   
rld_data_9  <= mux_queue(load_data_queue_q, inc(rdataq_head_q, 9));   
rld_data_10 <= mux_queue(load_data_queue_q, inc(rdataq_head_q, 10));   
rld_data_11 <= mux_queue(load_data_queue_q, inc(rdataq_head_q, 11));   
rld_data_12 <= mux_queue(load_data_queue_q, inc(rdataq_head_q, 12));   
rld_data_13 <= mux_queue(load_data_queue_q, inc(rdataq_head_q, 13));
rld_data_14 <= mux_queue(load_data_queue_q, inc(rdataq_head_q, 14));
rld_data_15 <= mux_queue(load_data_queue_q, inc(rdataq_head_q, 15));                           
   
rld_data_qw0 <= rld_data_0  & rld_data_1  & rld_data_2  & rld_data_3;
rld_data_qw1 <= rld_data_4  & rld_data_5  & rld_data_6  & rld_data_7;
rld_data_qw2 <= rld_data_8  & rld_data_9  & rld_data_10 & rld_data_11;
rld_data_qw3 <= rld_data_12 & rld_data_13 & rld_data_14 & rld_data_15;     
   
with rld_data_qw select
   reload_d.data <= rld_data_qw0 when "00",    
                    rld_data_qw1 when "01",    
                    rld_data_qw2 when "10",                           
                    rld_data_qw3 when others;


store_pwr_d <= ac_an_st_data_pwr_token;       
      
with req_in_store select
   stq_tail_d <= inc(stq_tail_q) when '1',
                 stq_tail_q      when others;

gen_store_queue_fb: for i in 0 to st_queue_size-1 generate
   
   store_queue_fb(i).valid  <= store_queue_q(i).valid and not stq_valid_rst(i);                          
   store_queue_fb(i).sent   <= store_queue_q(i).sent or stq_sent_set(i);
   store_queue_fb(i).data   <= (store_queue_q(i).data or stq_sent_set(i)) and not stq_data_rst(i);
   store_queue_fb(i).dseq   <= "000";         
   store_queue_fb(i).endian <= store_queue_q(i).endian;
   store_queue_fb(i).tag    <= store_queue_q(i).tag;
   store_queue_fb(i).len    <= store_queue_q(i).len;
   store_queue_fb(i).ra     <= store_queue_q(i).ra; 
   store_queue_fb(i).thread <= store_queue_q(i).thread; 
   store_queue_fb(i).ditc   <= store_queue_q(i).ditc;     
   store_queue_fb(i).spec   <= store_queue_q(i).spec;   
   store_queue_fb(i).ttype  <= store_queue_q(i).ttype;    
   store_queue_fb(i).user   <= store_queue_q(i).user;     
   store_queue_fb(i).wimg   <= store_queue_q(i).wimg; 
   store_queue_fb(i).hwsync <= store_queue_q(i).hwsync;

   store_dep_d(i) <= gate_and(store_queue_set_dep(i), shl_entry) or 
                     gate_and(not store_queue_set_dep(i) and not store_queue_rst_dep(i), store_dep_q(i));
   
end generate;

gen_store_queue: for i in 0 to st_queue_size-1 generate

   store_queue_d(i) <= req_in when b(req_in_store and eq(stq_tail_q, i)) else store_queue_fb(i);

end generate;                      
                           
axi_store_id <= "0000";  
   
st_req_send <= mux_queue(store_queue_q, stq_send_q);
st_dep <= mux_queue(store_dep_q, stq_send_q);

axi_store_valid <= st_req_send.valid and not st_req_send.spec and not st_req_send.sent; 
axi_store_mod <= "000000000000";

axi_store_ra <= st_req_send.ra(64-C_M00_AXI_ADDR_WIDTH to 59) & "0000";


gen_store_len_16B: if st_data_32b_mode = 0 generate
   store_data_in <= ac_an_st_data;
   store_be_in <= ac_an_st_byte_enbl;
end generate;   
gen_store_len_32B: if st_data_32b_mode = 1 generate
   with req_in.ra(59) select 
      store_data_in <= ac_an_st_data(128 to 255) when '1',
                       ac_an_st_data(0 to 127)   when others;
   with req_in.ra(59) select 
      store_be_in <= ac_an_st_byte_enbl(16 to 31) when '1',
                     ac_an_st_byte_enbl(0 to 15)  when others;                       
end generate; 


store_spec_valid <= st_req_send.valid and st_req_send.spec; 

hwsync_valid <= store_spec_valid and st_req_send.hwsync;
                
lwsync_valid <= store_spec_valid and 
                (eq(st_req_send.ttype, LWSYNC) or
                 eq(st_req_send.ttype, MBAR) or
                 eq(st_req_send.ttype, TLBSYNC) or
                 eq(st_req_send.ttype, DCBI));                             

store_taken <= ((axi_store_valid and axi_store_ready) or store_spec_valid) and not st_req_stall;

gen_stq_sent: for i in 0 to st_queue_size-1 generate
   stq_sent_set(i) <= store_taken and eq(stq_send_q, i); 
end generate;           

store_advance <= (store_taken and not hwsync_valid) or hwsync_complete;

with store_advance select
   stq_send_d <= inc(stq_send_q) when '1',
                 stq_send_q      when others;


gen_store_data_queue: for i in 0 to st_queue_size-1 generate
   store_data_queue_d(i) <= (data => store_data_in, be => store_be_in) when b(req_in_store and eq(stq_tail_q, i)) else store_data_queue_q(i);
end generate;              

st_req_data <= mux_queue(store_queue_q, stq_data_q);
st_data <= mux_queue(store_data_queue_q, stq_data_q);
              
axi_store_data_valid <= st_req_data.valid and st_req_data.data and not st_req_data.spec;

axi_store_data_taken <= axi_store_data_valid and axi_store_data_ready;               

st_data_xfer_inc <= axi_store_data_taken and not st_data_last_xfer;
st_data_xfer_done <= axi_store_data_taken and st_data_last_xfer;              
st_data_xfer_hold <= not st_data_xfer_inc and not st_data_xfer_done;

st_data_xfer_d <= gate_and(st_data_xfer_inc, inc(st_data_xfer_q)) or
                  gate_and(st_data_xfer_done, "000") or
                  gate_and(st_data_xfer_hold, st_data_xfer_q);                        


gen_store_data_16B: if not stores_32B generate     

axi_store_len <= "0010000";                    
st_data_last_xfer <= eq(st_data_xfer_q, "011");

with st_data_xfer_q select
   axi_store_data <= st_data.data(24  to  31) & st_data.data(16  to  23) & st_data.data(8   to  15) & st_data.data(0   to   7) when "000",
                     st_data.data(56  to  63) & st_data.data(48  to  55) & st_data.data(40  to  47) & st_data.data(32  to  39) when "001",
                     st_data.data(88  to  95) & st_data.data(80  to  87) & st_data.data(72  to  79) & st_data.data(64  to  71) when "010",
                     st_data.data(120 to 127) & st_data.data(112 to 119) & st_data.data(104 to 111) & st_data.data(96  to 103) when others;

with st_data_xfer_q select
   axi_store_data_be <= st_data.be( 3) & st_data.be( 2) & st_data.be( 1) & st_data.be( 0) when "000",
                        st_data.be( 7) & st_data.be( 6) & st_data.be( 5) & st_data.be( 4) when "001",
                        st_data.be(11) & st_data.be(10) & st_data.be( 9) & st_data.be( 8) when "010",
                        st_data.be(15) & st_data.be(14) & st_data.be(13) & st_data.be(12) when others;                     
end generate;     

gen_store_data_32B: if stores_32B generate     

axi_store_len <= "0100000";
st_data_last_xfer <= eq(st_data_xfer_q, "111");
                    
with st_data_xfer_q select
   axi_store_data <= st_data.data(24  to  31) & st_data.data(16  to  23) & st_data.data(8   to  15) & st_data.data(0   to   7) when "000",
                     st_data.data(56  to  63) & st_data.data(48  to  55) & st_data.data(40  to  47) & st_data.data(32  to  39) when "001",
                     st_data.data(87  to  95) & st_data.data(80  to  87) & st_data.data(72  to  79) & st_data.data(64  to  71) when "010",
                     st_data.data(120 to 127) & st_data.data(112 to 119) & st_data.data(104 to 111) & st_data.data(96  to 103) when "011",
                     st_data.data(152 to 159) & st_data.data(144 to 151) & st_data.data(136 to 143) & st_data.data(128 to 135) when "100",                     
                     st_data.data(184 to 191) & st_data.data(176 to 183) & st_data.data(168 to 175) & st_data.data(160 to 167) when "101",                     
                     st_data.data(216 to 223) & st_data.data(208 to 215) & st_data.data(200 to 207) & st_data.data(192 to 199) when "110",                                          
                     st_data.data(248 to 255) & st_data.data(240 to 247) & st_data.data(232 to 239) & st_data.data(224 to 231) when others;

with st_data_xfer_q select
   axi_store_data_be <= st_data.be( 3) & st_data.be( 2) & st_data.be( 1) & st_data.be( 0) when "000",
                        st_data.be( 7) & st_data.be( 6) & st_data.be( 5) & st_data.be( 4) when "001",
                        st_data.be(11) & st_data.be(10) & st_data.be( 9) & st_data.be( 8) when "010",
                        st_data.be(15) & st_data.be(14) & st_data.be(13) & st_data.be(12) when "011",
                        st_data.be(19) & st_data.be(18) & st_data.be(17) & st_data.be(16) when "100",
                        st_data.be(23) & st_data.be(22) & st_data.be(21) & st_data.be(20) when "101",
                        st_data.be(27) & st_data.be(26) & st_data.be(25) & st_data.be(24) when "110",
                        st_data.be(31) & st_data.be(30) & st_data.be(29) & st_data.be(28) when others;
end generate;      

axi_store_data_last <= st_data_last_xfer;                  

        
with st_data_xfer_done or store_spec_complete select
    stq_data_d <= inc(stq_data_q) when '1',
                  stq_data_q      when others;

gen_store_data_rst: for i in 0 to st_queue_size-1 generate
   stq_data_rst(i) <= st_data_xfer_done and eq(stq_data_q, i);
end generate;


store_rsp_ready_d <= '1';
axi_store_rsp_ready <= store_rsp_ready_q;

lwsync_complete <= st_req_data.valid and st_req_data.data and st_req_data.spec and not st_req_data.hwsync;
hwsync_complete <= st_req_data.valid and st_req_data.data and st_req_data.spec and st_req_data.hwsync and not st_req_stall;
store_spec_complete <= lwsync_complete or hwsync_complete;
    
store_rsp_complete <= (axi_store_rsp_valid and eq(axi_store_rsp_resp, "00"));
store_complete <= store_rsp_complete or store_spec_complete;   

store_pop_delayed <= or_reduce(store_pop_pending_q);                     
store_pop_pending_sel <= store_rsp_complete & store_spec_complete & store_pop_delayed;
with store_pop_pending_sel select
  store_pop_pending_d <= dec(store_pop_pending_q) when "001",                                         
                         inc(store_pop_pending_q) when "110",                         
                         inc(store_pop_pending_q) when "111",                  
                         store_pop_pending_q      when others;                                                                                                                    
                      
status_d.st_pop <= store_complete or store_pop_delayed;
status_d.st_pop_thrd <= "000";    
status_d.gather <= '0';           
             
with store_complete select
    stq_head_d <= inc(stq_head_q) when '1',
                  stq_head_q      when others;

stq_count_sel <= req_in_store & store_complete;
with stq_count_sel select
   stq_count_d <= inc(stq_count_q) when "10",
                  dec(stq_count_q) when "01",
                  stq_count_q      when others;                 
              
gen_stq_valid_rst: for i in 0 to st_queue_size-1 generate                  
   stq_valid_rst(i) <= store_complete and eq(stq_head_q, i);   
end generate;
                       
stq_oflow <= eq(stq_count_q, st_queue_size) and req_in_store;
stq_uflow <= eq(stq_count_q, 0) and store_complete;  
                       



    
stcx_store_t(0) <= stcx_t(0) or store_t(0);
stcx_store_t(1) <= stcx_t(1) or store_t(1);
stcx_store_t(2) <= stcx_t(2) or store_t(2);
stcx_store_t(3) <= stcx_t(3) or store_t(3);

req_ra_line <= req_in.ra(64-xu_real_data_add to 59);
resv_ra_hit(0) <= eq(req_ra_line, resv_q(0).ra);
resv_ra_hit(1) <= eq(req_ra_line, resv_q(1).ra);
resv_ra_hit(2) <= eq(req_ra_line, resv_q(2).ra);
resv_ra_hit(3) <= eq(req_ra_line, resv_q(3).ra);

resv_set(0) <= larx_t(0);
resv_set(1) <= larx_t(1);
resv_set(2) <= larx_t(2);
resv_set(3) <= larx_t(3);

resv_rst(0) <= resv_ra_hit(0) and (stcx_store_t(0) or stcx_store_t(1) or stcx_store_t(2) or stcx_store_t(3));
resv_rst(1) <= resv_ra_hit(1) and (stcx_store_t(0) or stcx_store_t(1) or stcx_store_t(2) or stcx_store_t(3));
resv_rst(2) <= resv_ra_hit(2) and (stcx_store_t(0) or stcx_store_t(1) or stcx_store_t(2) or stcx_store_t(3));
resv_rst(3) <= resv_ra_hit(3) and (stcx_store_t(0) or stcx_store_t(1) or stcx_store_t(2) or stcx_store_t(3));

resv_d(0).valid <= (resv_q(0).valid or resv_set(0)) and not resv_rst(0);
resv_d(1).valid <= (resv_q(1).valid or resv_set(1)) and not resv_rst(1);
resv_d(2).valid <= (resv_q(2).valid or resv_set(2)) and not resv_rst(2);
resv_d(3).valid <= (resv_q(3).valid or resv_set(3)) and not resv_rst(3);

with resv_set(0) select
   resv_d(0).ra <= req_ra_line  when '1',
                   resv_q(0).ra when others;
                     
with resv_set(1) select
   resv_d(1).ra <= req_ra_line  when '1',
                   resv_q(1).ra when others;
                     
with resv_set(2) select
   resv_d(2).ra <= req_ra_line  when '1',
                   resv_q(2).ra when others;
                     
with resv_set(3) select
   resv_d(3).ra <= req_ra_line  when '1',
                   resv_q(3).ra when others;                                                               

status_d.res_valid(0) <= resv_q(0).valid;
status_d.res_valid(1) <= resv_q(1).valid;            
status_d.res_valid(2) <= resv_q(2).valid;            
status_d.res_valid(3) <= resv_q(3).valid;                        

status_d.stcx_complete(0) <= stcx_t(0);
status_d.stcx_complete(1) <= stcx_t(1);
status_d.stcx_complete(2) <= stcx_t(2);
status_d.stcx_complete(3) <= stcx_t(3);

status_d.stcx_pass(0) <= stcx_t(0) and resv_q(0).valid and resv_ra_hit(0);                                         
status_d.stcx_pass(1) <= stcx_t(1) and resv_q(1).valid and resv_ra_hit(1);                                         
status_d.stcx_pass(2) <= stcx_t(2) and resv_q(2).valid and resv_ra_hit(2);                                         
status_d.stcx_pass(3) <= stcx_t(3) and resv_q(3).valid and resv_ra_hit(3);   


status_d.sync_ack(0) <= hwsync_complete and eq(st_req_data.ttype, HWSYNC) and eq(st_req_data.thread, "00");
status_d.sync_ack(1) <= hwsync_complete and eq(st_req_data.ttype, HWSYNC) and eq(st_req_data.thread, "01");
status_d.sync_ack(2) <= hwsync_complete and eq(st_req_data.ttype, HWSYNC) and eq(st_req_data.thread, "10");
status_d.sync_ack(3) <= hwsync_complete and eq(st_req_data.ttype, HWSYNC) and eq(st_req_data.thread, "11");                                                              
                       
               

req_p1_d <= req_in;

ld_p1_entry_d <= req_in_load & ldq_head_q;
st_p1_entry_d <= req_in_store & stq_head_q;

gen_dep_addr_cmp_l: for i in 0 to st_queue_size-1 generate          
                                     
req_p1_addr_hit_lhs(i) <= ld_p1_entry_q(0) and                             
                          address_check(req_p1_q, store_queue_q(i)) and    
                          (not stq_valid_rst(i));                          

req_p1_sync_lhs(i) <= ld_p1_entry_q(0) and                                 
                      store_queue_q(i).valid and                           
                      store_queue_q(i).hwsync and                          
                      (not stq_valid_rst(i));                              

req_p1_any_lhs(i) <= req_p1_addr_hit_lhs(i) or req_p1_sync_lhs(i);                         

end generate;

lhs_ordered <= rotl(req_p1_any_lhs, ldq_head_q);

lhs_ordered_youngest <= right_one(lhs_ordered);

lhs_youngest <= rotr(lhs_ordered_youngest, ldq_head_q);

lhs_entry <= gate_and(or_reduce(lhs_youngest), '1' & enc(lhs_youngest));
                                
gen_dep_addr_cmp_s: for i in 0 to ld_queue_size-1 generate          
                                     
req_p1_addr_hit_shl(i) <= st_p1_entry_q(0) and                             
                          not req_p1_q.spec and                            
                          address_check(req_p1_q, load_queue_q(i)) and     
                          (not ldq_valid_rst(i));                          
                          
req_p1_sync_shl(i) <= st_p1_entry_q(0) and                                 
                      load_queue_q(i).valid and                            
                      req_p1_q.hwsync and                                  
                      (not ldq_valid_rst(i));                              
                      
req_p1_any_shl(i) <= req_p1_addr_hit_shl(i) or req_p1_sync_shl(i);                                           

end generate;

shl_ordered <= rotl(req_p1_any_shl, stq_head_q);

shl_ordered_youngest <= right_one(shl_ordered);

shl_youngest <= rotr(shl_ordered_youngest, stq_head_q);

shl_entry <= gate_and(or_reduce(shl_youngest), '1' & enc(shl_youngest));                         


ld_req_stall <= lhs_entry(0) or ld_dep(0);
st_req_stall <= shl_entry(0) or st_dep(0) or 
                (st_req_data.hwsync and not eq(stq_send_q, stq_head_q));  

gen_ldq_set_dep: for i in 0 to ld_queue_size-1 generate
load_queue_set_dep(i) <= ld_p1_entry_q(0) and eq(ld_p1_entry_q(1 to clog2(ld_queue_size)), std_logic_vector(to_unsigned(i, 2))) and lhs_entry(0);
end generate;

gen_stq_set_dep: for i in 0 to st_queue_size-1 generate
store_queue_set_dep(i) <= st_p1_entry_q(0) and eq(st_p1_entry_q(1 to clog2(st_queue_size)), std_logic_vector(to_unsigned(i, 2))) and shl_entry(0);
end generate;

gen_ldq_rst_dep: for i in 0 to ld_queue_size-1 generate
load_queue_rst_dep(i) <= store_complete and load_dep_q(i)(0) and eq(load_dep_q(i)(1 to clog2(st_queue_size)), stq_head_q);
end generate;

gen_stq_rst_dep: for i in 0 to st_queue_size-1 generate
store_queue_rst_dep(i) <= load_complete and store_dep_q(i)(0) and eq(store_dep_q(i)(1 to clog2(ld_queue_size)), ldq_head_q);
end generate;
 


axi_load_ready  <= m00_axi_arready;
m00_axi_arvalid <= axi_load_valid;   
m00_axi_arid  	 <= axi_load_id;
m00_axi_araddr  <= axi_load_ra;
	
with axi_load_len select 
   m00_axi_arlen <= x"00" when "0000001", 
  	                 x"00" when "0000010", 
                    x"00" when "0000100", 
                    x"01" when "0001000", 
                    x"03" when "0010000", 
                    x"07" when "0100000", 
 	                 x"0F" when "1000000", 
 	                 x"00" when others;
   	               
m00_axi_arsize  <= "010";
m00_axi_arburst <= "01";
	
m00_axi_arlock  <= '0';
m00_axi_arcache <= "0011";
m00_axi_arprot	 <= "000";
m00_axi_arqos	 <= x"0";
m00_axi_aruser	 <= (others => '1');


m00_axi_rready      <= axi_load_data_ready;
axi_load_data_valid <= m00_axi_rvalid;
axi_load_data_id    <= m00_axi_rid;		
axi_load_data       <= m00_axi_rdata;		
axi_load_data_resp  <= m00_axi_rresp;		
axi_load_data_last  <= m00_axi_rlast;			
	

axi_store_ready <= m00_axi_awready;  
m00_axi_awvalid <= axi_store_valid;
m00_axi_awid	 <= axi_store_id;
m00_axi_awaddr	 <= axi_store_ra;

with axi_store_len select 
  m00_axi_awlen <= x"03" when "0010000", 
                   x"07" when "0100000", 
                   x"00" when others;
   	                  
m00_axi_awsize	 <= "010";
m00_axi_awburst <= "01";
	
m00_axi_awlock	 <= '0';
m00_axi_awcache <= "0010";
m00_axi_awprot	 <= "000";
m00_axi_awqos	 <= x"0";
m00_axi_awuser  <= (others => '1');
	
   	
axi_store_data_ready <= m00_axi_wready;
m00_axi_wvalid <= axi_store_data_valid;
m00_axi_wdata  <= axi_store_data;
m00_axi_wstrb  <= axi_store_data_be;
m00_axi_wlast	<= axi_store_data_last;
m00_axi_wuser  <= (others => '0');


m00_axi_bready       <= axi_store_rsp_ready;
axi_store_rsp_valid  <= m00_axi_bvalid;
axi_store_rsp_id     <= m00_axi_bid;
axi_store_rsp_resp   <= m00_axi_bresp;	


err_d(0) <= ldq_uflow;
err_d(1) <= ldq_oflow;
err_d(2) <= stq_uflow;
err_d(3) <= stq_oflow;

err <= err_q;
                      

req_in_load <= 
  (req_in.valid and not req_in.ttype(0) and not req_in.ttype(1) and not req_in.ttype(2) and not req_in.ttype(3) and not req_in.ttype(4) and not req_in.ttype(5)) or
  (req_in.valid and not req_in.ttype(0) and not req_in.ttype(1) and not req_in.ttype(2) and not req_in.ttype(3) and not req_in.ttype(4) and req_in.ttype(5)) or
  (req_in.valid and not req_in.ttype(0) and not req_in.ttype(1) and req_in.ttype(2) and not req_in.ttype(3) and not req_in.ttype(4) and not req_in.ttype(5)) or
  (req_in.valid and not req_in.ttype(0) and not req_in.ttype(1) and req_in.ttype(2) and not req_in.ttype(3) and not req_in.ttype(4) and req_in.ttype(5) and not req_in.thread(0) and not req_in.thread(1)) or
  (req_in.valid and not req_in.ttype(0) and not req_in.ttype(1) and req_in.ttype(2) and not req_in.ttype(3) and not req_in.ttype(4) and req_in.ttype(5) and not req_in.thread(0) and req_in.thread(1)) or
  (req_in.valid and not req_in.ttype(0) and not req_in.ttype(1) and req_in.ttype(2) and not req_in.ttype(3) and not req_in.ttype(4) and req_in.ttype(5) and req_in.thread(0) and not req_in.thread(1)) or
  (req_in.valid and not req_in.ttype(0) and not req_in.ttype(1) and req_in.ttype(2) and not req_in.ttype(3) and not req_in.ttype(4) and req_in.ttype(5) and req_in.thread(0) and req_in.thread(1));
req_in_store <= 
  (req_in.valid and req_in.ttype(0) and not req_in.ttype(1) and not req_in.ttype(2) and not req_in.ttype(3) and not req_in.ttype(4) and not req_in.ttype(5) and not req_in.thread(0) and not req_in.thread(1)) or
  (req_in.valid and req_in.ttype(0) and not req_in.ttype(1) and not req_in.ttype(2) and not req_in.ttype(3) and not req_in.ttype(4) and not req_in.ttype(5) and not req_in.thread(0) and req_in.thread(1)) or
  (req_in.valid and req_in.ttype(0) and not req_in.ttype(1) and not req_in.ttype(2) and not req_in.ttype(3) and not req_in.ttype(4) and not req_in.ttype(5) and req_in.thread(0) and not req_in.thread(1)) or
  (req_in.valid and req_in.ttype(0) and not req_in.ttype(1) and not req_in.ttype(2) and not req_in.ttype(3) and not req_in.ttype(4) and not req_in.ttype(5) and req_in.thread(0) and req_in.thread(1)) or
  (req_in.valid and req_in.ttype(0) and not req_in.ttype(1) and req_in.ttype(2) and not req_in.ttype(3) and not req_in.ttype(4) and req_in.ttype(5) and not req_in.thread(0) and not req_in.thread(1)) or
  (req_in.valid and req_in.ttype(0) and not req_in.ttype(1) and req_in.ttype(2) and not req_in.ttype(3) and not req_in.ttype(4) and req_in.ttype(5) and not req_in.thread(0) and req_in.thread(1)) or
  (req_in.valid and req_in.ttype(0) and not req_in.ttype(1) and req_in.ttype(2) and not req_in.ttype(3) and not req_in.ttype(4) and req_in.ttype(5) and req_in.thread(0) and not req_in.thread(1)) or
  (req_in.valid and req_in.ttype(0) and not req_in.ttype(1) and req_in.ttype(2) and not req_in.ttype(3) and not req_in.ttype(4) and req_in.ttype(5) and req_in.thread(0) and req_in.thread(1)) or
  (req_in.valid and req_in.ttype(0) and not req_in.ttype(1) and req_in.ttype(2) and not req_in.ttype(3) and req_in.ttype(4) and not req_in.ttype(5)) or
  (req_in.valid and req_in.ttype(0) and not req_in.ttype(1) and req_in.ttype(2) and not req_in.ttype(3) and req_in.ttype(4) and req_in.ttype(5)) or
  (req_in.valid and req_in.ttype(0) and req_in.ttype(1) and req_in.ttype(2) and not req_in.ttype(3) and req_in.ttype(4) and not req_in.ttype(5)) or
  (req_in.valid and req_in.ttype(0) and req_in.ttype(1) and req_in.ttype(2) and req_in.ttype(3) and req_in.ttype(4) and req_in.ttype(5));
req_in_spec <= 
  (req_in.valid and req_in.ttype(0) and not req_in.ttype(1) and req_in.ttype(2) and not req_in.ttype(3) and req_in.ttype(4) and not req_in.ttype(5)) or
  (req_in.valid and req_in.ttype(0) and not req_in.ttype(1) and req_in.ttype(2) and not req_in.ttype(3) and req_in.ttype(4) and req_in.ttype(5)) or
  (req_in.valid and req_in.ttype(0) and req_in.ttype(1) and req_in.ttype(2) and not req_in.ttype(3) and req_in.ttype(4) and not req_in.ttype(5)) or
  (req_in.valid and req_in.ttype(0) and req_in.ttype(1) and req_in.ttype(2) and req_in.ttype(3) and req_in.ttype(4) and req_in.ttype(5));
larx_t(0) <= 
  (req_in.valid and not req_in.ttype(0) and not req_in.ttype(1) and req_in.ttype(2) and not req_in.ttype(3) and not req_in.ttype(4) and req_in.ttype(5) and not req_in.thread(0) and not req_in.thread(1));
larx_t(1) <= 
  (req_in.valid and not req_in.ttype(0) and not req_in.ttype(1) and req_in.ttype(2) and not req_in.ttype(3) and not req_in.ttype(4) and req_in.ttype(5) and not req_in.thread(0) and req_in.thread(1));
larx_t(2) <= 
  (req_in.valid and not req_in.ttype(0) and not req_in.ttype(1) and req_in.ttype(2) and not req_in.ttype(3) and not req_in.ttype(4) and req_in.ttype(5) and req_in.thread(0) and not req_in.thread(1));
larx_t(3) <= 
  (req_in.valid and not req_in.ttype(0) and not req_in.ttype(1) and req_in.ttype(2) and not req_in.ttype(3) and not req_in.ttype(4) and req_in.ttype(5) and req_in.thread(0) and req_in.thread(1));
stcx_t(0) <= 
  (req_in.valid and req_in.ttype(0) and not req_in.ttype(1) and req_in.ttype(2) and not req_in.ttype(3) and not req_in.ttype(4) and req_in.ttype(5) and not req_in.thread(0) and not req_in.thread(1));
stcx_t(1) <= 
  (req_in.valid and req_in.ttype(0) and not req_in.ttype(1) and req_in.ttype(2) and not req_in.ttype(3) and not req_in.ttype(4) and req_in.ttype(5) and not req_in.thread(0) and req_in.thread(1));
stcx_t(2) <= 
  (req_in.valid and req_in.ttype(0) and not req_in.ttype(1) and req_in.ttype(2) and not req_in.ttype(3) and not req_in.ttype(4) and req_in.ttype(5) and req_in.thread(0) and not req_in.thread(1));
stcx_t(3) <= 
  (req_in.valid and req_in.ttype(0) and not req_in.ttype(1) and req_in.ttype(2) and not req_in.ttype(3) and not req_in.ttype(4) and req_in.ttype(5) and req_in.thread(0) and req_in.thread(1));
store_t(0) <= 
  (req_in.valid and req_in.ttype(0) and not req_in.ttype(1) and not req_in.ttype(2) and not req_in.ttype(3) and not req_in.ttype(4) and not req_in.ttype(5) and not req_in.thread(0) and not req_in.thread(1));
store_t(1) <= 
  (req_in.valid and req_in.ttype(0) and not req_in.ttype(1) and not req_in.ttype(2) and not req_in.ttype(3) and not req_in.ttype(4) and not req_in.ttype(5) and not req_in.thread(0) and req_in.thread(1));
store_t(2) <= 
  (req_in.valid and req_in.ttype(0) and not req_in.ttype(1) and not req_in.ttype(2) and not req_in.ttype(3) and not req_in.ttype(4) and not req_in.ttype(5) and req_in.thread(0) and not req_in.thread(1));
store_t(3) <= 
  (req_in.valid and req_in.ttype(0) and not req_in.ttype(1) and not req_in.ttype(2) and not req_in.ttype(3) and not req_in.ttype(4) and not req_in.ttype(5) and req_in.thread(0) and req_in.thread(1));
            
rld_seq_d(0) <= 
  (rld_seq_q(0) and rld_seq_q(1) and rld_seq_q(2) and rld_seq_q(3) and rld_seq_q(4) and not rld_ready) or
  (rld_seq_q(0) and rld_seq_q(1) and rld_seq_q(2) and rld_seq_q(3) and rld_seq_q(4) and rld_ready and not rld_crit_qw(0) and not rld_crit_qw(1) and not rld_single) or
  (rld_seq_q(0) and rld_seq_q(1) and rld_seq_q(2) and rld_seq_q(3) and rld_seq_q(4) and rld_ready and not rld_crit_qw(0) and rld_crit_qw(1) and not rld_single) or
  (rld_seq_q(0) and rld_seq_q(1) and rld_seq_q(2) and rld_seq_q(3) and rld_seq_q(4) and rld_ready and rld_crit_qw(0) and not rld_crit_qw(1) and not rld_single) or
  (rld_seq_q(0) and rld_seq_q(1) and rld_seq_q(2) and rld_seq_q(3) and rld_seq_q(4) and rld_ready and rld_crit_qw(0) and rld_crit_qw(1) and not rld_single) or
  (not rld_seq_q(0) and not rld_seq_q(1) and not rld_seq_q(2) and rld_seq_q(3) and rld_seq_q(4)) or
  (rld_seq_q(0) and not rld_seq_q(1) and not rld_seq_q(2) and not rld_seq_q(3) and not rld_seq_q(4)) or
  (rld_seq_q(0) and not rld_seq_q(1) and not rld_seq_q(2) and not rld_seq_q(3) and rld_seq_q(4)) or
  (rld_seq_q(0) and not rld_seq_q(1) and not rld_seq_q(2) and rld_seq_q(3) and not rld_seq_q(4)) or
  (rld_seq_q(0) and not rld_seq_q(1) and not rld_seq_q(2) and rld_seq_q(3) and rld_seq_q(4)) or
  (rld_seq_q(0) and not rld_seq_q(1) and rld_seq_q(2) and not rld_seq_q(3) and not rld_seq_q(4)) or
  (rld_seq_q(0) and not rld_seq_q(1) and rld_seq_q(2) and not rld_seq_q(3) and rld_seq_q(4)) or
  (rld_seq_q(0) and not rld_seq_q(1) and rld_seq_q(2) and rld_seq_q(3) and not rld_seq_q(4)) or
  (rld_seq_q(0) and not rld_seq_q(1) and rld_seq_q(2) and rld_seq_q(3) and rld_seq_q(4)) or
  (rld_seq_q(0) and rld_seq_q(1) and not rld_seq_q(2) and not rld_seq_q(3) and not rld_seq_q(4)) or
  (rld_seq_q(0) and rld_seq_q(1) and not rld_seq_q(2) and not rld_seq_q(3) and rld_seq_q(4)) or
  (rld_seq_q(0) and rld_seq_q(1) and not rld_seq_q(2) and rld_seq_q(3) and not rld_seq_q(4)) or
  (rld_seq_q(0) and rld_seq_q(1) and not rld_seq_q(2) and rld_seq_q(3) and rld_seq_q(4)) or
  (rld_seq_q(0) and rld_seq_q(1) and rld_seq_q(2) and not rld_seq_q(3) and not rld_seq_q(4)) or
  (rld_seq_q(0) and rld_seq_q(1) and rld_seq_q(2) and not rld_seq_q(3) and rld_seq_q(4)) or
  (rld_seq_q(0) and rld_seq_q(1) and rld_seq_q(2) and rld_seq_q(3) and not rld_seq_q(4));
rld_seq_d(1) <= 
  (rld_seq_q(0) and rld_seq_q(1) and rld_seq_q(2) and rld_seq_q(3) and rld_seq_q(4) and not rld_ready) or
  (not rld_seq_q(0) and not rld_seq_q(1) and not rld_seq_q(2) and rld_seq_q(3) and rld_seq_q(4)) or
  (rld_seq_q(0) and not rld_seq_q(1) and not rld_seq_q(2) and not rld_seq_q(3) and rld_seq_q(4)) or
  (rld_seq_q(0) and not rld_seq_q(1) and not rld_seq_q(2) and rld_seq_q(3) and rld_seq_q(4)) or
  (rld_seq_q(0) and not rld_seq_q(1) and rld_seq_q(2) and not rld_seq_q(3) and rld_seq_q(4)) or
  (rld_seq_q(0) and not rld_seq_q(1) and rld_seq_q(2) and rld_seq_q(3) and rld_seq_q(4)) or
  (rld_seq_q(0) and rld_seq_q(1) and not rld_seq_q(2) and not rld_seq_q(3) and not rld_seq_q(4)) or
  (rld_seq_q(0) and rld_seq_q(1) and not rld_seq_q(2) and not rld_seq_q(3) and rld_seq_q(4)) or
  (rld_seq_q(0) and rld_seq_q(1) and not rld_seq_q(2) and rld_seq_q(3) and not rld_seq_q(4)) or
  (rld_seq_q(0) and rld_seq_q(1) and not rld_seq_q(2) and rld_seq_q(3) and rld_seq_q(4)) or
  (rld_seq_q(0) and rld_seq_q(1) and rld_seq_q(2) and not rld_seq_q(3) and not rld_seq_q(4)) or
  (rld_seq_q(0) and rld_seq_q(1) and rld_seq_q(2) and not rld_seq_q(3) and rld_seq_q(4)) or
  (rld_seq_q(0) and rld_seq_q(1) and rld_seq_q(2) and rld_seq_q(3) and not rld_seq_q(4));
rld_seq_d(2) <= 
  (rld_seq_q(0) and rld_seq_q(1) and rld_seq_q(2) and rld_seq_q(3) and rld_seq_q(4) and not rld_ready) or
  (rld_seq_q(0) and rld_seq_q(1) and rld_seq_q(2) and rld_seq_q(3) and rld_seq_q(4) and rld_ready and rld_crit_qw(0) and not rld_crit_qw(1) and not rld_single) or
  (rld_seq_q(0) and rld_seq_q(1) and rld_seq_q(2) and rld_seq_q(3) and rld_seq_q(4) and rld_ready and rld_crit_qw(0) and rld_crit_qw(1) and not rld_single) or
  (not rld_seq_q(0) and not rld_seq_q(1) and not rld_seq_q(2) and rld_seq_q(3) and rld_seq_q(4)) or
  (rld_seq_q(0) and not rld_seq_q(1) and rld_seq_q(2) and not rld_seq_q(3) and not rld_seq_q(4)) or
  (rld_seq_q(0) and not rld_seq_q(1) and rld_seq_q(2) and rld_seq_q(3) and not rld_seq_q(4)) or
  (rld_seq_q(0) and rld_seq_q(1) and not rld_seq_q(2) and not rld_seq_q(3) and rld_seq_q(4)) or
  (rld_seq_q(0) and rld_seq_q(1) and not rld_seq_q(2) and rld_seq_q(3) and rld_seq_q(4)) or
  (not rld_seq_q(0) and not rld_seq_q(1) and rld_seq_q(2) and not rld_seq_q(3) and not rld_seq_q(4)) or
  (not rld_seq_q(0) and not rld_seq_q(1) and rld_seq_q(2) and not rld_seq_q(3) and rld_seq_q(4)) or
  (not rld_seq_q(0) and not rld_seq_q(1) and rld_seq_q(2) and rld_seq_q(3) and not rld_seq_q(4)) or
  (not rld_seq_q(0) and not rld_seq_q(1) and rld_seq_q(2) and rld_seq_q(3) and rld_seq_q(4)) or
  (rld_seq_q(0) and rld_seq_q(1) and rld_seq_q(2) and not rld_seq_q(3) and not rld_seq_q(4)) or
  (rld_seq_q(0) and rld_seq_q(1) and rld_seq_q(2) and not rld_seq_q(3) and rld_seq_q(4)) or
  (rld_seq_q(0) and rld_seq_q(1) and rld_seq_q(2) and rld_seq_q(3) and not rld_seq_q(4));
rld_seq_d(3) <= 
  (rld_seq_q(0) and rld_seq_q(1) and rld_seq_q(2) and rld_seq_q(3) and rld_seq_q(4) and not rld_ready) or
  (rld_seq_q(0) and rld_seq_q(1) and rld_seq_q(2) and rld_seq_q(3) and rld_seq_q(4) and rld_ready and not rld_crit_qw(0) and rld_crit_qw(1) and not rld_single) or
  (rld_seq_q(0) and rld_seq_q(1) and rld_seq_q(2) and rld_seq_q(3) and rld_seq_q(4) and rld_ready and rld_crit_qw(0) and rld_crit_qw(1) and not rld_single) or
  (not rld_seq_q(0) and not rld_seq_q(1) and not rld_seq_q(2) and not rld_seq_q(3) and rld_seq_q(4)) or
  (not rld_seq_q(0) and not rld_seq_q(1) and not rld_seq_q(2) and rld_seq_q(3) and not rld_seq_q(4)) or
  (not rld_seq_q(0) and not rld_seq_q(1) and not rld_seq_q(2) and rld_seq_q(3) and rld_seq_q(4)) or
  (rld_seq_q(0) and not rld_seq_q(1) and not rld_seq_q(2) and not rld_seq_q(3) and rld_seq_q(4)) or
  (rld_seq_q(0) and not rld_seq_q(1) and not rld_seq_q(2) and rld_seq_q(3) and not rld_seq_q(4)) or
  (rld_seq_q(0) and not rld_seq_q(1) and not rld_seq_q(2) and rld_seq_q(3) and rld_seq_q(4)) or
  (rld_seq_q(0) and not rld_seq_q(1) and rld_seq_q(2) and rld_seq_q(3) and not rld_seq_q(4)) or
  (rld_seq_q(0) and rld_seq_q(1) and not rld_seq_q(2) and not rld_seq_q(3) and rld_seq_q(4)) or
  (rld_seq_q(0) and rld_seq_q(1) and not rld_seq_q(2) and rld_seq_q(3) and not rld_seq_q(4)) or
  (rld_seq_q(0) and rld_seq_q(1) and not rld_seq_q(2) and rld_seq_q(3) and rld_seq_q(4)) or
  (not rld_seq_q(0) and not rld_seq_q(1) and rld_seq_q(2) and rld_seq_q(3) and not rld_seq_q(4)) or
  (not rld_seq_q(0) and not rld_seq_q(1) and rld_seq_q(2) and rld_seq_q(3) and rld_seq_q(4)) or
  (rld_seq_q(0) and rld_seq_q(1) and rld_seq_q(2) and rld_seq_q(3) and not rld_seq_q(4));
rld_seq_d(4) <= 
  (rld_seq_q(0) and rld_seq_q(1) and rld_seq_q(2) and rld_seq_q(3) and rld_seq_q(4) and not rld_ready) or
  (rld_seq_q(0) and rld_seq_q(1) and rld_seq_q(2) and rld_seq_q(3) and rld_seq_q(4) and rld_ready and rld_single) or
  (not rld_seq_q(0) and not rld_seq_q(1) and not rld_seq_q(2) and rld_seq_q(3) and not rld_seq_q(4)) or
  (not rld_seq_q(0) and not rld_seq_q(1) and not rld_seq_q(2) and rld_seq_q(3) and rld_seq_q(4)) or
  (rld_seq_q(0) and not rld_seq_q(1) and not rld_seq_q(2) and not rld_seq_q(3) and not rld_seq_q(4)) or
  (rld_seq_q(0) and not rld_seq_q(1) and not rld_seq_q(2) and rld_seq_q(3) and not rld_seq_q(4)) or
  (rld_seq_q(0) and not rld_seq_q(1) and rld_seq_q(2) and not rld_seq_q(3) and not rld_seq_q(4)) or
  (rld_seq_q(0) and not rld_seq_q(1) and rld_seq_q(2) and rld_seq_q(3) and not rld_seq_q(4)) or
  (rld_seq_q(0) and rld_seq_q(1) and not rld_seq_q(2) and not rld_seq_q(3) and not rld_seq_q(4)) or
  (rld_seq_q(0) and rld_seq_q(1) and not rld_seq_q(2) and not rld_seq_q(3) and rld_seq_q(4)) or
  (rld_seq_q(0) and rld_seq_q(1) and not rld_seq_q(2) and rld_seq_q(3) and not rld_seq_q(4)) or
  (rld_seq_q(0) and rld_seq_q(1) and not rld_seq_q(2) and rld_seq_q(3) and rld_seq_q(4)) or
  (not rld_seq_q(0) and not rld_seq_q(1) and rld_seq_q(2) and not rld_seq_q(3) and rld_seq_q(4)) or
  (not rld_seq_q(0) and not rld_seq_q(1) and rld_seq_q(2) and rld_seq_q(3) and rld_seq_q(4)) or
  (rld_seq_q(0) and rld_seq_q(1) and rld_seq_q(2) and not rld_seq_q(3) and rld_seq_q(4));
reload_d.coming <= 
  (rld_seq_q(0) and rld_seq_q(1) and rld_seq_q(2) and rld_seq_q(3) and rld_seq_q(4) and rld_ready and not rld_crit_qw(0) and not rld_crit_qw(1) and not rld_single) or
  (rld_seq_q(0) and rld_seq_q(1) and rld_seq_q(2) and rld_seq_q(3) and rld_seq_q(4) and rld_ready and not rld_crit_qw(0) and rld_crit_qw(1) and not rld_single) or
  (rld_seq_q(0) and rld_seq_q(1) and rld_seq_q(2) and rld_seq_q(3) and rld_seq_q(4) and rld_ready and rld_crit_qw(0) and not rld_crit_qw(1) and not rld_single) or
  (rld_seq_q(0) and rld_seq_q(1) and rld_seq_q(2) and rld_seq_q(3) and rld_seq_q(4) and rld_ready and rld_crit_qw(0) and rld_crit_qw(1) and not rld_single) or
  (rld_seq_q(0) and rld_seq_q(1) and rld_seq_q(2) and rld_seq_q(3) and rld_seq_q(4) and rld_ready and rld_single) or
  (rld_seq_q(0) and not rld_seq_q(1) and not rld_seq_q(2) and not rld_seq_q(3) and rld_seq_q(4)) or
  (rld_seq_q(0) and not rld_seq_q(1) and not rld_seq_q(2) and rld_seq_q(3) and rld_seq_q(4)) or
  (rld_seq_q(0) and not rld_seq_q(1) and rld_seq_q(2) and not rld_seq_q(3) and rld_seq_q(4)) or
  (rld_seq_q(0) and not rld_seq_q(1) and rld_seq_q(2) and rld_seq_q(3) and rld_seq_q(4));
reload_d.valid <= 
  (not rld_seq_q(0) and not rld_seq_q(1) and not rld_seq_q(2) and not rld_seq_q(3) and rld_seq_q(4)) or
  (rld_seq_q(0) and not rld_seq_q(1) and not rld_seq_q(2) and not rld_seq_q(3) and not rld_seq_q(4)) or
  (rld_seq_q(0) and not rld_seq_q(1) and not rld_seq_q(2) and not rld_seq_q(3) and rld_seq_q(4)) or
  (rld_seq_q(0) and not rld_seq_q(1) and not rld_seq_q(2) and rld_seq_q(3) and not rld_seq_q(4)) or
  (rld_seq_q(0) and not rld_seq_q(1) and not rld_seq_q(2) and rld_seq_q(3) and rld_seq_q(4)) or
  (rld_seq_q(0) and not rld_seq_q(1) and rld_seq_q(2) and not rld_seq_q(3) and not rld_seq_q(4)) or
  (rld_seq_q(0) and not rld_seq_q(1) and rld_seq_q(2) and not rld_seq_q(3) and rld_seq_q(4)) or
  (rld_seq_q(0) and not rld_seq_q(1) and rld_seq_q(2) and rld_seq_q(3) and not rld_seq_q(4)) or
  (rld_seq_q(0) and not rld_seq_q(1) and rld_seq_q(2) and rld_seq_q(3) and rld_seq_q(4)) or
  (rld_seq_q(0) and rld_seq_q(1) and not rld_seq_q(2) and not rld_seq_q(3) and not rld_seq_q(4)) or
  (rld_seq_q(0) and rld_seq_q(1) and not rld_seq_q(2) and not rld_seq_q(3) and rld_seq_q(4)) or
  (rld_seq_q(0) and rld_seq_q(1) and not rld_seq_q(2) and rld_seq_q(3) and not rld_seq_q(4)) or
  (rld_seq_q(0) and rld_seq_q(1) and not rld_seq_q(2) and rld_seq_q(3) and rld_seq_q(4));
reload_d.qw(58) <= 
  (rld_seq_q(0) and not rld_seq_q(1) and rld_seq_q(2) and not rld_seq_q(3) and not rld_seq_q(4)) or
  (rld_seq_q(0) and not rld_seq_q(1) and rld_seq_q(2) and not rld_seq_q(3) and rld_seq_q(4)) or
  (rld_seq_q(0) and not rld_seq_q(1) and rld_seq_q(2) and rld_seq_q(3) and not rld_seq_q(4)) or
  (rld_seq_q(0) and not rld_seq_q(1) and rld_seq_q(2) and rld_seq_q(3) and rld_seq_q(4)) or
  (rld_seq_q(0) and rld_seq_q(1) and not rld_seq_q(2) and rld_seq_q(3) and not rld_seq_q(4)) or
  (rld_seq_q(0) and rld_seq_q(1) and not rld_seq_q(2) and rld_seq_q(3) and rld_seq_q(4));
reload_d.qw(59) <= 
  (rld_seq_q(0) and not rld_seq_q(1) and not rld_seq_q(2) and not rld_seq_q(3) and rld_seq_q(4)) or
  (rld_seq_q(0) and not rld_seq_q(1) and not rld_seq_q(2) and rld_seq_q(3) and not rld_seq_q(4)) or
  (rld_seq_q(0) and not rld_seq_q(1) and rld_seq_q(2) and not rld_seq_q(3) and rld_seq_q(4)) or
  (rld_seq_q(0) and not rld_seq_q(1) and rld_seq_q(2) and rld_seq_q(3) and not rld_seq_q(4)) or
  (rld_seq_q(0) and rld_seq_q(1) and not rld_seq_q(2) and not rld_seq_q(3) and rld_seq_q(4)) or
  (rld_seq_q(0) and rld_seq_q(1) and not rld_seq_q(2) and rld_seq_q(3) and rld_seq_q(4));
reload_d.crit <= 
  (rld_seq_q(0) and not rld_seq_q(1) and not rld_seq_q(2) and not rld_seq_q(3) and not rld_seq_q(4)) or
  (rld_seq_q(0) and not rld_seq_q(1) and not rld_seq_q(2) and rld_seq_q(3) and not rld_seq_q(4)) or
  (rld_seq_q(0) and not rld_seq_q(1) and rld_seq_q(2) and not rld_seq_q(3) and not rld_seq_q(4)) or
  (rld_seq_q(0) and not rld_seq_q(1) and rld_seq_q(2) and rld_seq_q(3) and not rld_seq_q(4));
start_rld_data <= 
  (not rld_seq_q(0) and not rld_seq_q(1) and not rld_seq_q(2) and rld_seq_q(3) and rld_seq_q(4)) or
  (rld_seq_q(0) and rld_seq_q(1) and not rld_seq_q(2) and not rld_seq_q(3) and not rld_seq_q(4)) or
  (rld_seq_q(0) and rld_seq_q(1) and not rld_seq_q(2) and rld_seq_q(3) and not rld_seq_q(4));
rld_seq_err <= 
  (not rld_seq_q(0) and not rld_seq_q(1) and not rld_seq_q(2) and not rld_seq_q(3) and not rld_seq_q(4)) or
  (not rld_seq_q(0) and not rld_seq_q(1) and rld_seq_q(2) and not rld_seq_q(3) and not rld_seq_q(4)) or
  (not rld_seq_q(0) and not rld_seq_q(1) and rld_seq_q(2) and not rld_seq_q(3) and rld_seq_q(4)) or
  (not rld_seq_q(0) and not rld_seq_q(1) and rld_seq_q(2) and rld_seq_q(3) and not rld_seq_q(4)) or
  (not rld_seq_q(0) and not rld_seq_q(1) and rld_seq_q(2) and rld_seq_q(3) and rld_seq_q(4)) or
  (rld_seq_q(0) and rld_seq_q(1) and rld_seq_q(2) and not rld_seq_q(3) and not rld_seq_q(4)) or
  (rld_seq_q(0) and rld_seq_q(1) and rld_seq_q(2) and not rld_seq_q(3) and rld_seq_q(4)) or
  (rld_seq_q(0) and rld_seq_q(1) and rld_seq_q(2) and rld_seq_q(3) and not rld_seq_q(4));

rld_dseq_d(0) <= 
  (rld_dseq_q(0) and rld_dseq_q(1) and rld_dseq_q(2) and rld_dseq_q(3) and not start_rld_data) or
  (rld_dseq_q(0) and rld_dseq_q(1) and rld_dseq_q(2) and rld_dseq_q(3) and start_rld_data and rld_single) or
  (not rld_dseq_q(0) and not rld_dseq_q(1) and not rld_dseq_q(2) and rld_dseq_q(3)) or
  (not rld_dseq_q(0) and not rld_dseq_q(1) and rld_dseq_q(2) and not rld_dseq_q(3)) or
  (not rld_dseq_q(0) and not rld_dseq_q(1) and rld_dseq_q(2) and rld_dseq_q(3)) or
  (not rld_dseq_q(0) and rld_dseq_q(1) and not rld_dseq_q(2) and not rld_dseq_q(3)) or
  (rld_dseq_q(0) and not rld_dseq_q(1) and not rld_dseq_q(2) and rld_dseq_q(3)) or
  (rld_dseq_q(0) and not rld_dseq_q(1) and rld_dseq_q(2) and not rld_dseq_q(3)) or
  (rld_dseq_q(0) and not rld_dseq_q(1) and rld_dseq_q(2) and rld_dseq_q(3)) or
  (rld_dseq_q(0) and rld_dseq_q(1) and not rld_dseq_q(2) and not rld_dseq_q(3)) or
  (rld_dseq_q(0) and not rld_dseq_q(1) and not rld_dseq_q(2) and not rld_dseq_q(3)) or
  (rld_dseq_q(0) and rld_dseq_q(1) and not rld_dseq_q(2) and rld_dseq_q(3)) or
  (rld_dseq_q(0) and rld_dseq_q(1) and rld_dseq_q(2) and not rld_dseq_q(3));
rld_dseq_d(1) <= 
  (rld_dseq_q(0) and rld_dseq_q(1) and rld_dseq_q(2) and rld_dseq_q(3) and not start_rld_data) or
  (rld_dseq_q(0) and rld_dseq_q(1) and rld_dseq_q(2) and rld_dseq_q(3) and start_rld_data and rld_crit_qw(0) and rld_crit_qw(1) and not rld_single) or
  (rld_dseq_q(0) and rld_dseq_q(1) and rld_dseq_q(2) and rld_dseq_q(3) and start_rld_data and rld_single) or
  (rld_dseq_q(0) and not rld_dseq_q(1) and rld_dseq_q(2) and not rld_dseq_q(3)) or
  (rld_dseq_q(0) and not rld_dseq_q(1) and rld_dseq_q(2) and rld_dseq_q(3)) or
  (rld_dseq_q(0) and rld_dseq_q(1) and not rld_dseq_q(2) and not rld_dseq_q(3)) or
  (not rld_dseq_q(0) and rld_dseq_q(1) and not rld_dseq_q(2) and rld_dseq_q(3)) or
  (not rld_dseq_q(0) and rld_dseq_q(1) and rld_dseq_q(2) and not rld_dseq_q(3)) or
  (not rld_dseq_q(0) and rld_dseq_q(1) and rld_dseq_q(2) and rld_dseq_q(3)) or
  (rld_dseq_q(0) and rld_dseq_q(1) and not rld_dseq_q(2) and rld_dseq_q(3)) or
  (rld_dseq_q(0) and rld_dseq_q(1) and rld_dseq_q(2) and not rld_dseq_q(3));
rld_dseq_d(2) <= 
  (rld_dseq_q(0) and rld_dseq_q(1) and rld_dseq_q(2) and rld_dseq_q(3) and not start_rld_data) or
  (rld_dseq_q(0) and rld_dseq_q(1) and rld_dseq_q(2) and rld_dseq_q(3) and start_rld_data and not rld_crit_qw(0) and rld_crit_qw(1) and not rld_single) or
  (rld_dseq_q(0) and rld_dseq_q(1) and rld_dseq_q(2) and rld_dseq_q(3) and start_rld_data and rld_crit_qw(0) and not rld_crit_qw(1) and not rld_single) or
  (rld_dseq_q(0) and rld_dseq_q(1) and rld_dseq_q(2) and rld_dseq_q(3) and start_rld_data and rld_single) or
  (not rld_dseq_q(0) and not rld_dseq_q(1) and not rld_dseq_q(2) and rld_dseq_q(3)) or
  (not rld_dseq_q(0) and not rld_dseq_q(1) and rld_dseq_q(2) and not rld_dseq_q(3)) or
  (rld_dseq_q(0) and not rld_dseq_q(1) and not rld_dseq_q(2) and rld_dseq_q(3)) or
  (rld_dseq_q(0) and not rld_dseq_q(1) and rld_dseq_q(2) and not rld_dseq_q(3)) or
  (rld_dseq_q(0) and rld_dseq_q(1) and not rld_dseq_q(2) and not rld_dseq_q(3)) or
  (not rld_dseq_q(0) and rld_dseq_q(1) and rld_dseq_q(2) and not rld_dseq_q(3)) or
  (not rld_dseq_q(0) and rld_dseq_q(1) and rld_dseq_q(2) and rld_dseq_q(3)) or
  (rld_dseq_q(0) and rld_dseq_q(1) and rld_dseq_q(2) and not rld_dseq_q(3));
rld_dseq_d(3) <= 
  (rld_dseq_q(0) and rld_dseq_q(1) and rld_dseq_q(2) and rld_dseq_q(3) and not start_rld_data) or
  (rld_dseq_q(0) and rld_dseq_q(1) and rld_dseq_q(2) and rld_dseq_q(3) and start_rld_data and not rld_crit_qw(0) and not rld_crit_qw(1) and not rld_single) or
  (rld_dseq_q(0) and rld_dseq_q(1) and rld_dseq_q(2) and rld_dseq_q(3) and start_rld_data and rld_crit_qw(0) and not rld_crit_qw(1) and not rld_single) or
  (rld_dseq_q(0) and rld_dseq_q(1) and rld_dseq_q(2) and rld_dseq_q(3) and start_rld_data and rld_single) or
  (not rld_dseq_q(0) and not rld_dseq_q(1) and not rld_dseq_q(2) and rld_dseq_q(3)) or
  (not rld_dseq_q(0) and not rld_dseq_q(1) and rld_dseq_q(2) and not rld_dseq_q(3)) or
  (not rld_dseq_q(0) and not rld_dseq_q(1) and rld_dseq_q(2) and rld_dseq_q(3)) or
  (not rld_dseq_q(0) and rld_dseq_q(1) and not rld_dseq_q(2) and not rld_dseq_q(3)) or
  (rld_dseq_q(0) and not rld_dseq_q(1) and rld_dseq_q(2) and not rld_dseq_q(3)) or
  (rld_dseq_q(0) and rld_dseq_q(1) and not rld_dseq_q(2) and not rld_dseq_q(3)) or
  (not rld_dseq_q(0) and rld_dseq_q(1) and not rld_dseq_q(2) and rld_dseq_q(3)) or
  (not rld_dseq_q(0) and rld_dseq_q(1) and rld_dseq_q(2) and rld_dseq_q(3)) or
  (rld_dseq_q(0) and rld_dseq_q(1) and not rld_dseq_q(2) and rld_dseq_q(3));
rld_data_qw(0) <= 
  (rld_dseq_q(0) and rld_dseq_q(1) and rld_dseq_q(2) and rld_dseq_q(3) and start_rld_data and rld_crit_qw(0) and not rld_crit_qw(1) and not rld_single) or
  (rld_dseq_q(0) and rld_dseq_q(1) and rld_dseq_q(2) and rld_dseq_q(3) and start_rld_data and rld_crit_qw(0) and rld_crit_qw(1) and not rld_single) or
  (not rld_dseq_q(0) and not rld_dseq_q(1) and rld_dseq_q(2) and rld_dseq_q(3)) or
  (not rld_dseq_q(0) and rld_dseq_q(1) and not rld_dseq_q(2) and not rld_dseq_q(3)) or
  (rld_dseq_q(0) and not rld_dseq_q(1) and rld_dseq_q(2) and rld_dseq_q(3)) or
  (rld_dseq_q(0) and rld_dseq_q(1) and not rld_dseq_q(2) and not rld_dseq_q(3));
rld_data_qw(1) <= 
  (rld_dseq_q(0) and rld_dseq_q(1) and rld_dseq_q(2) and rld_dseq_q(3) and start_rld_data and not rld_crit_qw(0) and rld_crit_qw(1) and not rld_single) or
  (rld_dseq_q(0) and rld_dseq_q(1) and rld_dseq_q(2) and rld_dseq_q(3) and start_rld_data and rld_crit_qw(0) and rld_crit_qw(1) and not rld_single) or
  (not rld_dseq_q(0) and not rld_dseq_q(1) and not rld_dseq_q(2) and rld_dseq_q(3)) or
  (not rld_dseq_q(0) and not rld_dseq_q(1) and rld_dseq_q(2) and rld_dseq_q(3)) or
  (rld_dseq_q(0) and not rld_dseq_q(1) and rld_dseq_q(2) and not rld_dseq_q(3)) or
  (rld_dseq_q(0) and rld_dseq_q(1) and not rld_dseq_q(2) and not rld_dseq_q(3));
rld_complete <= 
  (rld_dseq_q(0) and rld_dseq_q(1) and rld_dseq_q(2) and rld_dseq_q(3) and start_rld_data and rld_single) or
  (rld_dseq_q(0) and not rld_dseq_q(1) and rld_dseq_q(2) and not rld_dseq_q(3)) or
  (rld_dseq_q(0) and rld_dseq_q(1) and not rld_dseq_q(2) and not rld_dseq_q(3));
rld_dseq_err <= 
  (not rld_dseq_q(0) and not rld_dseq_q(1) and not rld_dseq_q(2) and not rld_dseq_q(3)) or
  (not rld_dseq_q(0) and rld_dseq_q(1) and not rld_dseq_q(2) and rld_dseq_q(3)) or
  (not rld_dseq_q(0) and rld_dseq_q(1) and rld_dseq_q(2) and not rld_dseq_q(3)) or
  (not rld_dseq_q(0) and rld_dseq_q(1) and rld_dseq_q(2) and rld_dseq_q(3)) or
  (rld_dseq_q(0) and not rld_dseq_q(1) and not rld_dseq_q(2) and not rld_dseq_q(3)) or
  (rld_dseq_q(0) and rld_dseq_q(1) and not rld_dseq_q(2) and rld_dseq_q(3)) or
  (rld_dseq_q(0) and rld_dseq_q(1) and rld_dseq_q(2) and not rld_dseq_q(3));


end a2l2_axi;
