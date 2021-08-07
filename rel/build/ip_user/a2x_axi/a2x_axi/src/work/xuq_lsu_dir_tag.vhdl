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


library ibm, ieee, work, tri, support;
use ibm.std_ulogic_support.all;
use ibm.std_ulogic_function_support.all;
use ibm.std_ulogic_unsigned.all;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use tri.tri_latches_pkg.all;
use support.power_logic_pkg.all;

entity xuq_lsu_dir_tag is
generic(expand_type     : integer := 2;                 
        dc_size         : natural := 14;        
        cl_size         : natural := 6;         
        wayDataSize     : natural := 35;        
        parBits         : natural := 4;
	real_data_add	: integer := 42);               
port(

     ex2_stg_act                :in  std_ulogic;
     binv2_stg_act              :in  std_ulogic;

     rel_addr_early             :in  std_ulogic_vector(64-real_data_add to 63-cl_size);
     rel_way_upd_a              :in  std_ulogic;                        
     rel_way_upd_b              :in  std_ulogic;                        
     rel_way_upd_c              :in  std_ulogic;                        
     rel_way_upd_d              :in  std_ulogic;                        
     rel_way_upd_e              :in  std_ulogic;                        
     rel_way_upd_f              :in  std_ulogic;                        
     rel_way_upd_g              :in  std_ulogic;                        
     rel_way_upd_h              :in  std_ulogic;                        

     inv1_val                   :in  std_ulogic;                        

     xu_lsu_spr_xucr0_dcdis     :in  std_ulogic;

     ex1_p_addr_01              :in  std_ulogic_vector(64-(dc_size-3) to 63-cl_size);       
     ex1_p_addr_23              :in  std_ulogic_vector(64-(dc_size-3) to 63-cl_size);       
     ex1_p_addr_45              :in  std_ulogic_vector(64-(dc_size-3) to 63-cl_size);       
     ex1_p_addr_67              :in  std_ulogic_vector(64-(dc_size-3) to 63-cl_size); 
     ex2_ddir_acc_instr         :in  std_ulogic;

     pc_xu_inj_dcachedir_parity :in  std_ulogic;

     dir_arr_rd_addr_01         :out std_ulogic_vector(64-(dc_size-3) to 63-cl_size);
     dir_arr_rd_addr_23         :out std_ulogic_vector(64-(dc_size-3) to 63-cl_size);
     dir_arr_rd_addr_45         :out std_ulogic_vector(64-(dc_size-3) to 63-cl_size);
     dir_arr_rd_addr_67         :out std_ulogic_vector(64-(dc_size-3) to 63-cl_size);
     dir_arr_rd_data            :in  std_ulogic_vector(0 to 8*wayDataSize-1);

     dir_wr_way                 :out std_ulogic_vector(0 to 7);
     dir_arr_wr_addr            :out std_ulogic_vector(64-(dc_size-3) to 63-cl_size);
     dir_arr_wr_data            :out std_ulogic_vector(64-real_data_add to 64-real_data_add+wayDataSize-1);

     ex2_wayA_tag               :out std_ulogic_vector(64-real_data_add to 63-(dc_size-3));
     ex2_wayB_tag               :out std_ulogic_vector(64-real_data_add to 63-(dc_size-3));
     ex2_wayC_tag               :out std_ulogic_vector(64-real_data_add to 63-(dc_size-3));
     ex2_wayD_tag               :out std_ulogic_vector(64-real_data_add to 63-(dc_size-3));
     ex2_wayE_tag               :out std_ulogic_vector(64-real_data_add to 63-(dc_size-3));
     ex2_wayF_tag               :out std_ulogic_vector(64-real_data_add to 63-(dc_size-3));
     ex2_wayG_tag               :out std_ulogic_vector(64-real_data_add to 63-(dc_size-3));
     ex2_wayH_tag               :out std_ulogic_vector(64-real_data_add to 63-(dc_size-3));

     ex3_way_tag_par_a          :out std_ulogic_vector(0 to parBits-1);
     ex3_way_tag_par_b          :out std_ulogic_vector(0 to parBits-1);
     ex3_way_tag_par_c          :out std_ulogic_vector(0 to parBits-1);
     ex3_way_tag_par_d          :out std_ulogic_vector(0 to parBits-1);
     ex3_way_tag_par_e          :out std_ulogic_vector(0 to parBits-1);
     ex3_way_tag_par_f          :out std_ulogic_vector(0 to parBits-1);
     ex3_way_tag_par_g          :out std_ulogic_vector(0 to parBits-1);
     ex3_way_tag_par_h          :out std_ulogic_vector(0 to parBits-1);

     ex3_tag_way_perr           :out std_ulogic_vector(0 to 7);

     vdd                        :inout power_logic;
     gnd                        :inout power_logic;
     nclk                       :in  clk_logic;
     sg_0                       :in  std_ulogic;
     func_sl_thold_0_b          :in  std_ulogic;
     func_sl_force              :in  std_ulogic;
     func_slp_sl_thold_0_b      :in  std_ulogic;
     func_slp_sl_force          :in  std_ulogic;
     d_mode_dc                  :in  std_ulogic;
     delay_lclkr_dc             :in  std_ulogic;
     mpw1_dc_b                  :in  std_ulogic;
     mpw2_dc_b                  :in  std_ulogic;
     scan_in                    :in  std_ulogic;
     scan_out                   :out std_ulogic     
   );
-- synopsys translate_off
-- synopsys translate_on
end xuq_lsu_dir_tag;
architecture xuq_lsu_dir_tag of xuq_lsu_dir_tag is

constant uprTagBit              :natural := 64-real_data_add;
constant lwrTagBit              :natural := 63-(dc_size-3);
constant tagSize                :natural := lwrTagBit-uprTagBit+1;
constant parExtCalc             :natural := 8 - (tagSize mod 8);
constant uprCClassBit           :natural := 64-(dc_size-3);
constant lwrCClassBit           :natural := 63-cl_size;

signal arr_wr_addr		:std_ulogic_vector(uprCClassBit to lwrCClassBit);
signal arr_wr_data		:std_ulogic_vector(uprTagBit to lwrTagBit);
signal wayA_wen			:std_ulogic;
signal wayB_wen			:std_ulogic;
signal wayC_wen			:std_ulogic;
signal wayD_wen			:std_ulogic;
signal wayE_wen			:std_ulogic;
signal wayF_wen			:std_ulogic;
signal wayG_wen			:std_ulogic;
signal wayH_wen			:std_ulogic;
signal arr_wayA_tag		:std_ulogic_vector(uprTagBit to lwrTagBit);
signal arr_wayB_tag		:std_ulogic_vector(uprTagBit to lwrTagBit);
signal arr_wayC_tag		:std_ulogic_vector(uprTagBit to lwrTagBit);
signal arr_wayD_tag		:std_ulogic_vector(uprTagBit to lwrTagBit);
signal arr_wayE_tag		:std_ulogic_vector(uprTagBit to lwrTagBit);
signal arr_wayF_tag		:std_ulogic_vector(uprTagBit to lwrTagBit);
signal arr_wayG_tag		:std_ulogic_vector(uprTagBit to lwrTagBit);
signal arr_wayH_tag		:std_ulogic_vector(uprTagBit to lwrTagBit);
signal inval_val_d              :std_ulogic;
signal inval_val_q              :std_ulogic;
signal arr_rd_addr_01           :std_ulogic_vector(uprCClassBit to lwrCClassBit);
signal arr_rd_addr_23           :std_ulogic_vector(uprCClassBit to lwrCClassBit);
signal arr_rd_addr_45           :std_ulogic_vector(uprCClassBit to lwrCClassBit);
signal arr_rd_addr_67           :std_ulogic_vector(uprCClassBit to lwrCClassBit);
signal ex3_en_par_chk_d         :std_ulogic_vector(0 to 7);
signal ex3_en_par_chk_q         :std_ulogic_vector(0 to 7);
signal spr_xucr0_dcdis_d        :std_ulogic;
signal spr_xucr0_dcdis_q        :std_ulogic;
signal inj_dcachedir_parity_d   :std_ulogic;
signal inj_dcachedir_parity_q   :std_ulogic;
signal relu_addr_d              :std_ulogic_vector(uprCClassBit to lwrCClassBit);
signal relu_addr_q              :std_ulogic_vector(uprCClassBit to lwrCClassBit);
signal ex2_par_gen_a_1b         :std_ulogic_vector(0 to parBits-1);
signal ex2_par_gen_a_2b         :std_ulogic_vector(0 to parBits-1);
signal ex2_par_gen_b_1b         :std_ulogic_vector(0 to parBits-1);
signal ex2_par_gen_b_2b         :std_ulogic_vector(0 to parBits-1);
signal ex2_par_gen_c_1b         :std_ulogic_vector(0 to parBits-1);
signal ex2_par_gen_c_2b         :std_ulogic_vector(0 to parBits-1);
signal ex2_par_gen_d_1b         :std_ulogic_vector(0 to parBits-1);
signal ex2_par_gen_d_2b         :std_ulogic_vector(0 to parBits-1);
signal ex2_par_gen_e_1b         :std_ulogic_vector(0 to parBits-1);
signal ex2_par_gen_e_2b         :std_ulogic_vector(0 to parBits-1);
signal ex2_par_gen_f_1b         :std_ulogic_vector(0 to parBits-1);
signal ex2_par_gen_f_2b         :std_ulogic_vector(0 to parBits-1);
signal ex2_par_gen_g_1b         :std_ulogic_vector(0 to parBits-1);
signal ex2_par_gen_g_2b         :std_ulogic_vector(0 to parBits-1);
signal ex2_par_gen_h_1b         :std_ulogic_vector(0 to parBits-1);
signal ex2_par_gen_h_2b         :std_ulogic_vector(0 to parBits-1);
signal ex3_par_gen_a_1b_d       :std_ulogic_vector(0 to parBits-1);
signal ex3_par_gen_a_2b_d       :std_ulogic_vector(0 to parBits-1);
signal ex3_par_gen_a_1b_q       :std_ulogic_vector(0 to parBits-1);
signal ex3_par_gen_a_2b_q       :std_ulogic_vector(0 to parBits-1);
signal ex3_par_gen_b_1b_d       :std_ulogic_vector(0 to parBits-1);
signal ex3_par_gen_b_2b_d       :std_ulogic_vector(0 to parBits-1);
signal ex3_par_gen_b_1b_q       :std_ulogic_vector(0 to parBits-1);
signal ex3_par_gen_b_2b_q       :std_ulogic_vector(0 to parBits-1);
signal ex3_par_gen_c_1b_d       :std_ulogic_vector(0 to parBits-1);
signal ex3_par_gen_c_2b_d       :std_ulogic_vector(0 to parBits-1);
signal ex3_par_gen_c_1b_q       :std_ulogic_vector(0 to parBits-1);
signal ex3_par_gen_c_2b_q       :std_ulogic_vector(0 to parBits-1);
signal ex3_par_gen_d_1b_d       :std_ulogic_vector(0 to parBits-1);
signal ex3_par_gen_d_2b_d       :std_ulogic_vector(0 to parBits-1);
signal ex3_par_gen_d_1b_q       :std_ulogic_vector(0 to parBits-1);
signal ex3_par_gen_d_2b_q       :std_ulogic_vector(0 to parBits-1);
signal ex3_par_gen_e_1b_d       :std_ulogic_vector(0 to parBits-1);
signal ex3_par_gen_e_2b_d       :std_ulogic_vector(0 to parBits-1);
signal ex3_par_gen_e_1b_q       :std_ulogic_vector(0 to parBits-1);
signal ex3_par_gen_e_2b_q       :std_ulogic_vector(0 to parBits-1);
signal ex3_par_gen_f_1b_d       :std_ulogic_vector(0 to parBits-1);
signal ex3_par_gen_f_2b_d       :std_ulogic_vector(0 to parBits-1);
signal ex3_par_gen_f_1b_q       :std_ulogic_vector(0 to parBits-1);
signal ex3_par_gen_f_2b_q       :std_ulogic_vector(0 to parBits-1);
signal ex3_par_gen_g_1b_d       :std_ulogic_vector(0 to parBits-1);
signal ex3_par_gen_g_2b_d       :std_ulogic_vector(0 to parBits-1);
signal ex3_par_gen_g_1b_q       :std_ulogic_vector(0 to parBits-1);
signal ex3_par_gen_g_2b_q       :std_ulogic_vector(0 to parBits-1);
signal ex3_par_gen_h_1b_d       :std_ulogic_vector(0 to parBits-1);
signal ex3_par_gen_h_2b_d       :std_ulogic_vector(0 to parBits-1);
signal ex3_par_gen_h_1b_q       :std_ulogic_vector(0 to parBits-1);
signal ex3_par_gen_h_2b_q       :std_ulogic_vector(0 to parBits-1);
signal ex3_par_gen_a            :std_ulogic_vector(0 to parBits-1);
signal ex3_par_gen_b            :std_ulogic_vector(0 to parBits-1);
signal ex3_par_gen_c            :std_ulogic_vector(0 to parBits-1);
signal ex3_par_gen_d            :std_ulogic_vector(0 to parBits-1);
signal ex3_par_gen_e            :std_ulogic_vector(0 to parBits-1);
signal ex3_par_gen_f            :std_ulogic_vector(0 to parBits-1);
signal ex3_par_gen_g            :std_ulogic_vector(0 to parBits-1);
signal ex3_par_gen_h            :std_ulogic_vector(0 to parBits-1);
signal ex3_perr_det_a           :std_ulogic;
signal ex3_perr_det_b           :std_ulogic;
signal ex3_perr_det_c           :std_ulogic;
signal ex3_perr_det_d           :std_ulogic;
signal ex3_perr_det_e           :std_ulogic;
signal ex3_perr_det_f           :std_ulogic;
signal ex3_perr_det_g           :std_ulogic;
signal ex3_perr_det_h           :std_ulogic;
signal ex2_binv2_stg_act        :std_ulogic;
signal rel_wrt_data_d           :std_ulogic_vector(uprTagBit to uprTagBit+wayDataSize-1);
signal rel_wrt_data_q           :std_ulogic_vector(uprTagBit to uprTagBit+wayDataSize-1);
signal ex3_way_tag_par_a_d      :std_ulogic_vector(0 to parBits-1);
signal ex3_way_tag_par_a_q      :std_ulogic_vector(0 to parBits-1);
signal ex3_way_tag_par_b_d      :std_ulogic_vector(0 to parBits-1);
signal ex3_way_tag_par_b_q      :std_ulogic_vector(0 to parBits-1);
signal ex3_way_tag_par_c_d      :std_ulogic_vector(0 to parBits-1);
signal ex3_way_tag_par_c_q      :std_ulogic_vector(0 to parBits-1);
signal ex3_way_tag_par_d_d      :std_ulogic_vector(0 to parBits-1);
signal ex3_way_tag_par_d_q      :std_ulogic_vector(0 to parBits-1);
signal ex3_way_tag_par_e_d      :std_ulogic_vector(0 to parBits-1);
signal ex3_way_tag_par_e_q      :std_ulogic_vector(0 to parBits-1);
signal ex3_way_tag_par_f_d      :std_ulogic_vector(0 to parBits-1);
signal ex3_way_tag_par_f_q      :std_ulogic_vector(0 to parBits-1);
signal ex3_way_tag_par_g_d      :std_ulogic_vector(0 to parBits-1);
signal ex3_way_tag_par_g_q      :std_ulogic_vector(0 to parBits-1);
signal ex3_way_tag_par_h_d      :std_ulogic_vector(0 to parBits-1);
signal ex3_way_tag_par_h_q      :std_ulogic_vector(0 to parBits-1);
signal my_spare0_lclk           :clk_logic;
signal my_spare0_d1clk          :std_ulogic;
signal my_spare0_d2clk          :std_ulogic;
signal my_spare0_latches_d      :std_ulogic_vector(0 to 15);
signal my_spare0_latches_q      :std_ulogic_vector(0 to 15);
signal my_spare1_lclk           :clk_logic;
signal my_spare1_d1clk          :std_ulogic;
signal my_spare1_d2clk          :std_ulogic;
signal my_spare1_latches_d      :std_ulogic_vector(0 to 15);
signal my_spare1_latches_q      :std_ulogic_vector(0 to 15);

constant inval_val_offset               :natural := 0;
constant ex3_en_par_chk_offset          :natural := inval_val_offset + 1;
constant spr_xucr0_dcdis_offset         :natural := ex3_en_par_chk_offset + 8;
constant inj_dcachedir_parity_offset    :natural := spr_xucr0_dcdis_offset + 1;
constant relu_addr_offset               :natural := inj_dcachedir_parity_offset + 1;
constant rel_wrt_data_offset            :natural := relu_addr_offset + lwrCClassBit-uprCClassBit+1;
constant ex3_par_gen_a_1b_offset        :natural := rel_wrt_data_offset + wayDataSize;
constant ex3_par_gen_a_2b_offset        :natural := ex3_par_gen_a_1b_offset + parBits;
constant ex3_par_gen_b_1b_offset        :natural := ex3_par_gen_a_2b_offset + parBits;
constant ex3_par_gen_b_2b_offset        :natural := ex3_par_gen_b_1b_offset + parBits;
constant ex3_par_gen_c_1b_offset        :natural := ex3_par_gen_b_2b_offset + parBits;
constant ex3_par_gen_c_2b_offset        :natural := ex3_par_gen_c_1b_offset + parBits;
constant ex3_par_gen_d_1b_offset        :natural := ex3_par_gen_c_2b_offset + parBits;
constant ex3_par_gen_d_2b_offset        :natural := ex3_par_gen_d_1b_offset + parBits;
constant ex3_par_gen_e_1b_offset        :natural := ex3_par_gen_d_2b_offset + parBits;
constant ex3_par_gen_e_2b_offset        :natural := ex3_par_gen_e_1b_offset + parBits;
constant ex3_par_gen_f_1b_offset        :natural := ex3_par_gen_e_2b_offset + parBits;
constant ex3_par_gen_f_2b_offset        :natural := ex3_par_gen_f_1b_offset + parBits;
constant ex3_par_gen_g_1b_offset        :natural := ex3_par_gen_f_2b_offset + parBits;
constant ex3_par_gen_g_2b_offset        :natural := ex3_par_gen_g_1b_offset + parBits;
constant ex3_par_gen_h_1b_offset        :natural := ex3_par_gen_g_2b_offset + parBits;
constant ex3_par_gen_h_2b_offset        :natural := ex3_par_gen_h_1b_offset + parBits;
constant ex3_way_tag_par_a_offset       :natural := ex3_par_gen_h_2b_offset + parBits;
constant ex3_way_tag_par_b_offset       :natural := ex3_way_tag_par_a_offset + parBits;
constant ex3_way_tag_par_c_offset       :natural := ex3_way_tag_par_b_offset + parBits;
constant ex3_way_tag_par_d_offset       :natural := ex3_way_tag_par_c_offset + parBits;
constant ex3_way_tag_par_e_offset       :natural := ex3_way_tag_par_d_offset + parBits;
constant ex3_way_tag_par_f_offset       :natural := ex3_way_tag_par_e_offset + parBits;
constant ex3_way_tag_par_g_offset       :natural := ex3_way_tag_par_f_offset + parBits;
constant ex3_way_tag_par_h_offset       :natural := ex3_way_tag_par_g_offset + parBits;
constant my_spare0_latches_offset       :natural := ex3_way_tag_par_h_offset + parBits;
constant my_spare1_latches_offset       :natural := my_spare0_latches_offset + 16;
constant scan_right                     :natural := my_spare1_latches_offset + 16 - 1;

signal tiup                             :std_ulogic;
signal siv                              :std_ulogic_vector(0 to scan_right);
signal sov                              :std_ulogic_vector(0 to scan_right);

begin

tiup <= '1';
ex2_binv2_stg_act <= ex2_stg_act or binv2_stg_act;

relu_addr_d <= rel_addr_early(uprCClassBit to lwrCClassBit);
wayA_wen    <= rel_way_upd_a;
wayB_wen    <= rel_way_upd_b;
wayC_wen    <= rel_way_upd_c;
wayD_wen    <= rel_way_upd_d;
wayE_wen    <= rel_way_upd_e;
wayF_wen    <= rel_way_upd_f;
wayG_wen    <= rel_way_upd_g;
wayH_wen    <= rel_way_upd_h;

inval_val_d <= inv1_val;

spr_xucr0_dcdis_d      <= xu_lsu_spr_xucr0_dcdis;
inj_dcachedir_parity_d <= pc_xu_inj_dcachedir_parity;


arr_wr_addr <= relu_addr_q(uprCClassBit to lwrCClassBit);
arr_wr_data <= rel_addr_early(uprTagBit to lwrTagBit);

arr_rd_addr_01 <= ex1_p_addr_01;
arr_rd_addr_23 <= ex1_p_addr_23;
arr_rd_addr_45 <= ex1_p_addr_45;
arr_rd_addr_67 <= ex1_p_addr_67;


l1dcta : entity work.xuq_lsu_dir_tag_arr(xuq_lsu_dir_tag_arr)
GENERIC MAP(expand_type         => expand_type,		
            dc_size             => dc_size,
            cl_size             => cl_size,
            wayDataSize         => wayDataSize,
            parityBits          => parBits,
            real_data_add       => real_data_add)       
port map(

     waddr                      => arr_wr_addr,
     wdata			=> arr_wr_data,
     way_wen_a                  => wayA_wen,
     way_wen_b                  => wayB_wen,
     way_wen_c                  => wayC_wen,
     way_wen_d                  => wayD_wen,
     way_wen_e                  => wayE_wen,
     way_wen_f                  => wayF_wen,
     way_wen_g                  => wayG_wen,
     way_wen_h                  => wayH_wen,

     raddr_01			=> arr_rd_addr_01,
     raddr_23			=> arr_rd_addr_23,
     raddr_45			=> arr_rd_addr_45,
     raddr_67			=> arr_rd_addr_67,
     inj_parity_err             => inj_dcachedir_parity_q,

     dir_arr_rd_addr_01         => dir_arr_rd_addr_01,    
     dir_arr_rd_addr_23         => dir_arr_rd_addr_23,    
     dir_arr_rd_addr_45         => dir_arr_rd_addr_45,    
     dir_arr_rd_addr_67         => dir_arr_rd_addr_67,    
     dir_arr_rd_data            => dir_arr_rd_data,

     dir_wr_way                 => dir_wr_way,
     dir_arr_wr_addr            => dir_arr_wr_addr,
     dir_arr_wr_data            => rel_wrt_data_d,

     way_tag_a                  => arr_wayA_tag,
     way_tag_b                  => arr_wayB_tag,
     way_tag_c                  => arr_wayC_tag,
     way_tag_d                  => arr_wayD_tag,
     way_tag_e                  => arr_wayE_tag,
     way_tag_f                  => arr_wayF_tag,
     way_tag_g                  => arr_wayG_tag,                             
     way_tag_h                  => arr_wayH_tag,

     way_arr_par_a              => ex3_way_tag_par_a_d,
     way_arr_par_b              => ex3_way_tag_par_b_d,
     way_arr_par_c              => ex3_way_tag_par_c_d,
     way_arr_par_d              => ex3_way_tag_par_d_d,
     way_arr_par_e              => ex3_way_tag_par_e_d,
     way_arr_par_f              => ex3_way_tag_par_f_d,
     way_arr_par_g              => ex3_way_tag_par_g_d,
     way_arr_par_h              => ex3_way_tag_par_h_d,

     par_gen_a_1b               => ex2_par_gen_a_1b,
     par_gen_a_2b               => ex2_par_gen_a_2b,
     par_gen_b_1b               => ex2_par_gen_b_1b,
     par_gen_b_2b               => ex2_par_gen_b_2b,
     par_gen_c_1b               => ex2_par_gen_c_1b,
     par_gen_c_2b               => ex2_par_gen_c_2b,
     par_gen_d_1b               => ex2_par_gen_d_1b,
     par_gen_d_2b               => ex2_par_gen_d_2b,
     par_gen_e_1b               => ex2_par_gen_e_1b,
     par_gen_e_2b               => ex2_par_gen_e_2b,
     par_gen_f_1b               => ex2_par_gen_f_1b,
     par_gen_f_2b               => ex2_par_gen_f_2b,
     par_gen_g_1b               => ex2_par_gen_g_1b,
     par_gen_g_2b               => ex2_par_gen_g_2b,
     par_gen_h_1b               => ex2_par_gen_h_1b,
     par_gen_h_2b               => ex2_par_gen_h_2b
);


ex3_en_par_chk_d(0) <= (ex2_ddir_acc_instr or inval_val_q) and not spr_xucr0_dcdis_q;
ex3_en_par_chk_d(1) <= (ex2_ddir_acc_instr or inval_val_q) and not spr_xucr0_dcdis_q;
ex3_en_par_chk_d(2) <= (ex2_ddir_acc_instr or inval_val_q) and not spr_xucr0_dcdis_q;
ex3_en_par_chk_d(3) <= (ex2_ddir_acc_instr or inval_val_q) and not spr_xucr0_dcdis_q;
ex3_en_par_chk_d(4) <= (ex2_ddir_acc_instr or inval_val_q) and not spr_xucr0_dcdis_q;
ex3_en_par_chk_d(5) <= (ex2_ddir_acc_instr or inval_val_q) and not spr_xucr0_dcdis_q;
ex3_en_par_chk_d(6) <= (ex2_ddir_acc_instr or inval_val_q) and not spr_xucr0_dcdis_q;
ex3_en_par_chk_d(7) <= (ex2_ddir_acc_instr or inval_val_q) and not spr_xucr0_dcdis_q;

ex3_par_gen_a_1b_d  <= ex2_par_gen_a_1b;
ex3_par_gen_a_2b_d  <= ex2_par_gen_a_2b;
ex3_par_gen_b_1b_d  <= ex2_par_gen_b_1b;
ex3_par_gen_b_2b_d  <= ex2_par_gen_b_2b;
ex3_par_gen_c_1b_d  <= ex2_par_gen_c_1b;
ex3_par_gen_c_2b_d  <= ex2_par_gen_c_2b;
ex3_par_gen_d_1b_d  <= ex2_par_gen_d_1b;
ex3_par_gen_d_2b_d  <= ex2_par_gen_d_2b;
ex3_par_gen_e_1b_d  <= ex2_par_gen_e_1b;
ex3_par_gen_e_2b_d  <= ex2_par_gen_e_2b;
ex3_par_gen_f_1b_d  <= ex2_par_gen_f_1b;
ex3_par_gen_f_2b_d  <= ex2_par_gen_f_2b;
ex3_par_gen_g_1b_d  <= ex2_par_gen_g_1b;
ex3_par_gen_g_2b_d  <= ex2_par_gen_g_2b;
ex3_par_gen_h_1b_d  <= ex2_par_gen_h_1b;
ex3_par_gen_h_2b_d  <= ex2_par_gen_h_2b;

ex3_par_gen_a       <= ex3_par_gen_a_1b_q xor ex3_par_gen_a_2b_q;
ex3_par_gen_b       <= ex3_par_gen_b_1b_q xor ex3_par_gen_b_2b_q;
ex3_par_gen_c       <= ex3_par_gen_c_1b_q xor ex3_par_gen_c_2b_q;
ex3_par_gen_d       <= ex3_par_gen_d_1b_q xor ex3_par_gen_d_2b_q;
ex3_par_gen_e       <= ex3_par_gen_e_1b_q xor ex3_par_gen_e_2b_q;
ex3_par_gen_f       <= ex3_par_gen_f_1b_q xor ex3_par_gen_f_2b_q;
ex3_par_gen_g       <= ex3_par_gen_g_1b_q xor ex3_par_gen_g_2b_q;
ex3_par_gen_h       <= ex3_par_gen_h_1b_q xor ex3_par_gen_h_2b_q;

ex3_perr_det_a <= or_reduce(ex3_way_tag_par_a_q xor ex3_par_gen_a) and ex3_en_par_chk_q(0);
ex3_perr_det_b <= or_reduce(ex3_way_tag_par_b_q xor ex3_par_gen_b) and ex3_en_par_chk_q(1);
ex3_perr_det_c <= or_reduce(ex3_way_tag_par_c_q xor ex3_par_gen_c) and ex3_en_par_chk_q(2);
ex3_perr_det_d <= or_reduce(ex3_way_tag_par_d_q xor ex3_par_gen_d) and ex3_en_par_chk_q(3);
ex3_perr_det_e <= or_reduce(ex3_way_tag_par_e_q xor ex3_par_gen_e) and ex3_en_par_chk_q(4);
ex3_perr_det_f <= or_reduce(ex3_way_tag_par_f_q xor ex3_par_gen_f) and ex3_en_par_chk_q(5);
ex3_perr_det_g <= or_reduce(ex3_way_tag_par_g_q xor ex3_par_gen_g) and ex3_en_par_chk_q(6);
ex3_perr_det_h <= or_reduce(ex3_way_tag_par_h_q xor ex3_par_gen_h) and ex3_en_par_chk_q(7);

my_spare0_latches_d <= not my_spare0_latches_q;
my_spare1_latches_d <= not my_spare1_latches_q;

ex2_wayA_tag <= arr_wayA_tag;
ex2_wayB_tag <= arr_wayB_tag;
ex2_wayC_tag <= arr_wayC_tag;
ex2_wayD_tag <= arr_wayD_tag;
ex2_wayE_tag <= arr_wayE_tag;
ex2_wayF_tag <= arr_wayF_tag;
ex2_wayG_tag <= arr_wayG_tag;
ex2_wayH_tag <= arr_wayH_tag;

dir_arr_wr_data <= rel_wrt_data_q;

ex3_way_tag_par_a <= ex3_way_tag_par_a_q;
ex3_way_tag_par_b <= ex3_way_tag_par_b_q;
ex3_way_tag_par_c <= ex3_way_tag_par_c_q;
ex3_way_tag_par_d <= ex3_way_tag_par_d_q;
ex3_way_tag_par_e <= ex3_way_tag_par_e_q;
ex3_way_tag_par_f <= ex3_way_tag_par_f_q;
ex3_way_tag_par_g <= ex3_way_tag_par_g_q;
ex3_way_tag_par_h <= ex3_way_tag_par_h_q;

ex3_tag_way_perr <= ex3_perr_det_a & ex3_perr_det_b & ex3_perr_det_c & ex3_perr_det_d &
                    ex3_perr_det_e & ex3_perr_det_f & ex3_perr_det_g & ex3_perr_det_h;


inval_val_reg: tri_rlmlatch_p
generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => tiup,
            forcee => func_slp_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_slp_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(inval_val_offset),
            scout   => sov(inval_val_offset),
            din     => inval_val_d,
            dout    => inval_val_q);

ex3_en_par_chk_reg: tri_rlmreg_p
generic map (width => 8, init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => tiup,
            forcee => func_slp_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_slp_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex3_en_par_chk_offset to ex3_en_par_chk_offset + ex3_en_par_chk_d'length-1),
            scout   => sov(ex3_en_par_chk_offset to ex3_en_par_chk_offset + ex3_en_par_chk_d'length-1),
            din     => ex3_en_par_chk_d,
            dout    => ex3_en_par_chk_q);

spr_xucr0_dcdis_reg: tri_rlmlatch_p
generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => tiup,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(spr_xucr0_dcdis_offset),
            scout   => sov(spr_xucr0_dcdis_offset),
            din     => spr_xucr0_dcdis_d,
            dout    => spr_xucr0_dcdis_q);

inj_dcachedir_parity_reg: tri_rlmlatch_p
generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => tiup,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(inj_dcachedir_parity_offset),
            scout   => sov(inj_dcachedir_parity_offset),
            din     => inj_dcachedir_parity_d,
            dout    => inj_dcachedir_parity_q);

relu_addr_reg: tri_rlmreg_p
generic map (width => lwrCClassBit-uprCClassBit+1, init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => tiup,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(relu_addr_offset to relu_addr_offset + relu_addr_d'length-1),
            scout   => sov(relu_addr_offset to relu_addr_offset + relu_addr_d'length-1),
            din     => relu_addr_d,
            dout    => relu_addr_q);

rel_wrt_data_reg: tri_rlmreg_p
generic map (width => wayDataSize, init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => tiup,
            forcee => func_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(rel_wrt_data_offset to rel_wrt_data_offset + rel_wrt_data_d'length-1),
            scout   => sov(rel_wrt_data_offset to rel_wrt_data_offset + rel_wrt_data_d'length-1),
            din     => rel_wrt_data_d,
            dout    => rel_wrt_data_q);

ex3_par_gen_a_1b_reg: tri_rlmreg_p
generic map (width => parBits, init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => ex2_binv2_stg_act,
            forcee => func_slp_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_slp_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex3_par_gen_a_1b_offset to ex3_par_gen_a_1b_offset + ex3_par_gen_a_1b_d'length-1),
            scout   => sov(ex3_par_gen_a_1b_offset to ex3_par_gen_a_1b_offset + ex3_par_gen_a_1b_d'length-1),
            din     => ex3_par_gen_a_1b_d,
            dout    => ex3_par_gen_a_1b_q);

ex3_par_gen_a_2b_reg: tri_rlmreg_p
generic map (width => parBits, init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => ex2_binv2_stg_act,
            forcee => func_slp_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_slp_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex3_par_gen_a_2b_offset to ex3_par_gen_a_2b_offset + ex3_par_gen_a_2b_d'length-1),
            scout   => sov(ex3_par_gen_a_2b_offset to ex3_par_gen_a_2b_offset + ex3_par_gen_a_2b_d'length-1),
            din     => ex3_par_gen_a_2b_d,
            dout    => ex3_par_gen_a_2b_q);

ex3_par_gen_b_1b_reg: tri_rlmreg_p
generic map (width => parBits, init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => ex2_binv2_stg_act,
            forcee => func_slp_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_slp_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex3_par_gen_b_1b_offset to ex3_par_gen_b_1b_offset + ex3_par_gen_b_1b_d'length-1),
            scout   => sov(ex3_par_gen_b_1b_offset to ex3_par_gen_b_1b_offset + ex3_par_gen_b_1b_d'length-1),
            din     => ex3_par_gen_b_1b_d,
            dout    => ex3_par_gen_b_1b_q);

ex3_par_gen_b_2b_reg: tri_rlmreg_p
generic map (width => parBits, init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => ex2_binv2_stg_act,
            forcee => func_slp_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_slp_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex3_par_gen_b_2b_offset to ex3_par_gen_b_2b_offset + ex3_par_gen_b_2b_d'length-1),
            scout   => sov(ex3_par_gen_b_2b_offset to ex3_par_gen_b_2b_offset + ex3_par_gen_b_2b_d'length-1),
            din     => ex3_par_gen_b_2b_d,
            dout    => ex3_par_gen_b_2b_q);

ex3_par_gen_c_1b_reg: tri_rlmreg_p
generic map (width => parBits, init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => ex2_binv2_stg_act,
            forcee => func_slp_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_slp_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex3_par_gen_c_1b_offset to ex3_par_gen_c_1b_offset + ex3_par_gen_c_1b_d'length-1),
            scout   => sov(ex3_par_gen_c_1b_offset to ex3_par_gen_c_1b_offset + ex3_par_gen_c_1b_d'length-1),
            din     => ex3_par_gen_c_1b_d,
            dout    => ex3_par_gen_c_1b_q);

ex3_par_gen_c_2b_reg: tri_rlmreg_p
generic map (width => parBits, init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => ex2_binv2_stg_act,
            forcee => func_slp_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_slp_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex3_par_gen_c_2b_offset to ex3_par_gen_c_2b_offset + ex3_par_gen_c_2b_d'length-1),
            scout   => sov(ex3_par_gen_c_2b_offset to ex3_par_gen_c_2b_offset + ex3_par_gen_c_2b_d'length-1),
            din     => ex3_par_gen_c_2b_d,
            dout    => ex3_par_gen_c_2b_q);

ex3_par_gen_d_1b_reg: tri_rlmreg_p
generic map (width => parBits, init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => ex2_binv2_stg_act,
            forcee => func_slp_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_slp_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex3_par_gen_d_1b_offset to ex3_par_gen_d_1b_offset + ex3_par_gen_d_1b_d'length-1),
            scout   => sov(ex3_par_gen_d_1b_offset to ex3_par_gen_d_1b_offset + ex3_par_gen_d_1b_d'length-1),
            din     => ex3_par_gen_d_1b_d,
            dout    => ex3_par_gen_d_1b_q);

ex3_par_gen_d_2b_reg: tri_rlmreg_p
generic map (width => parBits, init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => ex2_binv2_stg_act,
            forcee => func_slp_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_slp_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex3_par_gen_d_2b_offset to ex3_par_gen_d_2b_offset + ex3_par_gen_d_2b_d'length-1),
            scout   => sov(ex3_par_gen_d_2b_offset to ex3_par_gen_d_2b_offset + ex3_par_gen_d_2b_d'length-1),
            din     => ex3_par_gen_d_2b_d,
            dout    => ex3_par_gen_d_2b_q);

ex3_par_gen_e_1b_reg: tri_rlmreg_p
generic map (width => parBits, init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => ex2_binv2_stg_act,
            forcee => func_slp_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_slp_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex3_par_gen_e_1b_offset to ex3_par_gen_e_1b_offset + ex3_par_gen_e_1b_d'length-1),
            scout   => sov(ex3_par_gen_e_1b_offset to ex3_par_gen_e_1b_offset + ex3_par_gen_e_1b_d'length-1),
            din     => ex3_par_gen_e_1b_d,
            dout    => ex3_par_gen_e_1b_q);

ex3_par_gen_e_2b_reg: tri_rlmreg_p
generic map (width => parBits, init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => ex2_binv2_stg_act,
            forcee => func_slp_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_slp_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex3_par_gen_e_2b_offset to ex3_par_gen_e_2b_offset + ex3_par_gen_e_2b_d'length-1),
            scout   => sov(ex3_par_gen_e_2b_offset to ex3_par_gen_e_2b_offset + ex3_par_gen_e_2b_d'length-1),
            din     => ex3_par_gen_e_2b_d,
            dout    => ex3_par_gen_e_2b_q);

ex3_par_gen_f_1b_reg: tri_rlmreg_p
generic map (width => parBits, init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => ex2_binv2_stg_act,
            forcee => func_slp_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_slp_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex3_par_gen_f_1b_offset to ex3_par_gen_f_1b_offset + ex3_par_gen_f_1b_d'length-1),
            scout   => sov(ex3_par_gen_f_1b_offset to ex3_par_gen_f_1b_offset + ex3_par_gen_f_1b_d'length-1),
            din     => ex3_par_gen_f_1b_d,
            dout    => ex3_par_gen_f_1b_q);

ex3_par_gen_f_2b_reg: tri_rlmreg_p
generic map (width => parBits, init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => ex2_binv2_stg_act,
            forcee => func_slp_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_slp_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex3_par_gen_f_2b_offset to ex3_par_gen_f_2b_offset + ex3_par_gen_f_2b_d'length-1),
            scout   => sov(ex3_par_gen_f_2b_offset to ex3_par_gen_f_2b_offset + ex3_par_gen_f_2b_d'length-1),
            din     => ex3_par_gen_f_2b_d,
            dout    => ex3_par_gen_f_2b_q);

ex3_par_gen_g_1b_reg: tri_rlmreg_p
generic map (width => parBits, init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => ex2_binv2_stg_act,
            forcee => func_slp_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_slp_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex3_par_gen_g_1b_offset to ex3_par_gen_g_1b_offset + ex3_par_gen_g_1b_d'length-1),
            scout   => sov(ex3_par_gen_g_1b_offset to ex3_par_gen_g_1b_offset + ex3_par_gen_g_1b_d'length-1),
            din     => ex3_par_gen_g_1b_d,
            dout    => ex3_par_gen_g_1b_q);

ex3_par_gen_g_2b_reg: tri_rlmreg_p
generic map (width => parBits, init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => ex2_binv2_stg_act,
            forcee => func_slp_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_slp_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex3_par_gen_g_2b_offset to ex3_par_gen_g_2b_offset + ex3_par_gen_g_2b_d'length-1),
            scout   => sov(ex3_par_gen_g_2b_offset to ex3_par_gen_g_2b_offset + ex3_par_gen_g_2b_d'length-1),
            din     => ex3_par_gen_g_2b_d,
            dout    => ex3_par_gen_g_2b_q);

ex3_par_gen_h_1b_reg: tri_rlmreg_p
generic map (width => parBits, init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => ex2_binv2_stg_act,
            forcee => func_slp_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_slp_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex3_par_gen_h_1b_offset to ex3_par_gen_h_1b_offset + ex3_par_gen_h_1b_d'length-1),
            scout   => sov(ex3_par_gen_h_1b_offset to ex3_par_gen_h_1b_offset + ex3_par_gen_h_1b_d'length-1),
            din     => ex3_par_gen_h_1b_d,
            dout    => ex3_par_gen_h_1b_q);

ex3_par_gen_h_2b_reg: tri_rlmreg_p
generic map (width => parBits, init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => ex2_binv2_stg_act,
            forcee => func_slp_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_slp_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex3_par_gen_h_2b_offset to ex3_par_gen_h_2b_offset + ex3_par_gen_h_2b_d'length-1),
            scout   => sov(ex3_par_gen_h_2b_offset to ex3_par_gen_h_2b_offset + ex3_par_gen_h_2b_d'length-1),
            din     => ex3_par_gen_h_2b_d,
            dout    => ex3_par_gen_h_2b_q);

ex3_way_tag_par_a_reg: tri_rlmreg_p
generic map (width => parBits, init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => ex2_binv2_stg_act,
            forcee => func_slp_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_slp_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex3_way_tag_par_a_offset to ex3_way_tag_par_a_offset + ex3_way_tag_par_a_d'length-1),
            scout   => sov(ex3_way_tag_par_a_offset to ex3_way_tag_par_a_offset + ex3_way_tag_par_a_d'length-1),
            din     => ex3_way_tag_par_a_d,
            dout    => ex3_way_tag_par_a_q);

ex3_way_tag_par_b_reg: tri_rlmreg_p
generic map (width => parBits, init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => ex2_binv2_stg_act,
            forcee => func_slp_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_slp_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex3_way_tag_par_b_offset to ex3_way_tag_par_b_offset + ex3_way_tag_par_b_d'length-1),
            scout   => sov(ex3_way_tag_par_b_offset to ex3_way_tag_par_b_offset + ex3_way_tag_par_b_d'length-1),
            din     => ex3_way_tag_par_b_d,
            dout    => ex3_way_tag_par_b_q);

ex3_way_tag_par_c_reg: tri_rlmreg_p
generic map (width => parBits, init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => ex2_binv2_stg_act,
            forcee => func_slp_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_slp_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex3_way_tag_par_c_offset to ex3_way_tag_par_c_offset + ex3_way_tag_par_c_d'length-1),
            scout   => sov(ex3_way_tag_par_c_offset to ex3_way_tag_par_c_offset + ex3_way_tag_par_c_d'length-1),
            din     => ex3_way_tag_par_c_d,
            dout    => ex3_way_tag_par_c_q);

ex3_way_tag_par_d_reg: tri_rlmreg_p
generic map (width => parBits, init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => ex2_binv2_stg_act,
            forcee => func_slp_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_slp_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex3_way_tag_par_d_offset to ex3_way_tag_par_d_offset + ex3_way_tag_par_d_d'length-1),
            scout   => sov(ex3_way_tag_par_d_offset to ex3_way_tag_par_d_offset + ex3_way_tag_par_d_d'length-1),
            din     => ex3_way_tag_par_d_d,
            dout    => ex3_way_tag_par_d_q);

ex3_way_tag_par_e_reg: tri_rlmreg_p
generic map (width => parBits, init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => ex2_binv2_stg_act,
            forcee => func_slp_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_slp_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex3_way_tag_par_e_offset to ex3_way_tag_par_e_offset + ex3_way_tag_par_e_d'length-1),
            scout   => sov(ex3_way_tag_par_e_offset to ex3_way_tag_par_e_offset + ex3_way_tag_par_e_d'length-1),
            din     => ex3_way_tag_par_e_d,
            dout    => ex3_way_tag_par_e_q);

ex3_way_tag_par_f_reg: tri_rlmreg_p
generic map (width => parBits, init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => ex2_binv2_stg_act,
            forcee => func_slp_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_slp_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex3_way_tag_par_f_offset to ex3_way_tag_par_f_offset + ex3_way_tag_par_f_d'length-1),
            scout   => sov(ex3_way_tag_par_f_offset to ex3_way_tag_par_f_offset + ex3_way_tag_par_f_d'length-1),
            din     => ex3_way_tag_par_f_d,
            dout    => ex3_way_tag_par_f_q);

ex3_way_tag_par_g_reg: tri_rlmreg_p
generic map (width => parBits, init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => ex2_binv2_stg_act,
            forcee => func_slp_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_slp_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex3_way_tag_par_g_offset to ex3_way_tag_par_g_offset + ex3_way_tag_par_g_d'length-1),
            scout   => sov(ex3_way_tag_par_g_offset to ex3_way_tag_par_g_offset + ex3_way_tag_par_g_d'length-1),
            din     => ex3_way_tag_par_g_d,
            dout    => ex3_way_tag_par_g_q);

ex3_way_tag_par_h_reg: tri_rlmreg_p
generic map (width => parBits, init => 0, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => ex2_binv2_stg_act,
            forcee => func_slp_sl_force,
            d_mode  => d_mode_dc,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_slp_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex3_way_tag_par_h_offset to ex3_way_tag_par_h_offset + ex3_way_tag_par_h_d'length-1),
            scout   => sov(ex3_way_tag_par_h_offset to ex3_way_tag_par_h_offset + ex3_way_tag_par_h_d'length-1),
            din     => ex3_way_tag_par_h_d,
            dout    => ex3_way_tag_par_h_q);

my_spare0_lcb : entity tri.tri_lcbnd(tri_lcbnd)
generic map (expand_type => expand_type)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => tiup,
            forcee => func_slp_sl_force,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_slp_sl_thold_0_b,
            sg      => sg_0,
            d1clk   => my_spare0_d1clk,
            d2clk   => my_spare0_d2clk,
            lclk    => my_spare0_lclk);
my_spare0_latches_reg: entity tri.tri_inv_nlats(tri_inv_nlats)
generic map (width => 16, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            lclk    => my_spare0_lclk,
            d1clk   => my_spare0_d1clk,
            d2clk   => my_spare0_d2clk,
            scanin  => siv(my_spare0_latches_offset to  my_spare0_latches_offset + my_spare0_latches_d'length-1),
            scanout => sov(my_spare0_latches_offset to  my_spare0_latches_offset + my_spare0_latches_d'length-1),
            d       => my_spare0_latches_d,
            qb      => my_spare0_latches_q);

my_spare1_lcb : entity tri.tri_lcbnd(tri_lcbnd)
generic map (expand_type => expand_type)
port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => tiup,
            forcee => func_slp_sl_force,
            delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b,
            mpw2_b  => mpw2_dc_b,
            thold_b => func_slp_sl_thold_0_b,
            sg      => sg_0,
            d1clk   => my_spare1_d1clk,
            d2clk   => my_spare1_d2clk,
            lclk    => my_spare1_lclk);
my_spare1_latches_reg: entity tri.tri_inv_nlats(tri_inv_nlats)
generic map (width => 16, expand_type => expand_type, needs_sreset => 1)
port map (vd      => vdd,
            gd      => gnd,
            lclk    => my_spare1_lclk,
            d1clk   => my_spare1_d1clk,
            d2clk   => my_spare1_d2clk,
            scanin  => siv(my_spare1_latches_offset to  my_spare1_latches_offset + my_spare1_latches_d'length-1),
            scanout => sov(my_spare1_latches_offset to  my_spare1_latches_offset + my_spare1_latches_d'length-1),
            d       => my_spare1_latches_d,
            qb      => my_spare1_latches_q);

siv(0 to scan_right) <= sov(1 to scan_right) & scan_in;
scan_out <= sov(0);
end xuq_lsu_dir_tag;

