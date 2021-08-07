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

library ieee,ibm,support,work,tri;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use support.power_logic_pkg.all;
use ibm.std_ulogic_support.all;
use ibm.std_ulogic_function_support.all;
use tri.tri_latches_pkg.all;
use work.xuq_pkg.all;
 
entity xuq_fxu_spr_cspr is
generic(
   hvmode                           :     integer := 1;
   a2mode                           :     integer := 1;
   expand_type                      :     integer := 2;
   threads                          :     integer := 4;
   regsize                          :     integer := 64;
   eff_ifar                         :     integer := 62);
port(
   nclk                             : in  clk_logic;
   
   d_mode_dc                        : in  std_ulogic;
   delay_lclkr_dc                   : in  std_ulogic;
   mpw1_dc_b                        : in  std_ulogic;
   mpw2_dc_b                        : in  std_ulogic;

   func_sl_force : in  std_ulogic;
   func_sl_thold_0_b                : in  std_ulogic;
   func_nsl_force : in  std_ulogic;
   func_nsl_thold_0_b               : in  std_ulogic;
   sg_0                             : in  std_ulogic;
   scan_in                          : in  std_ulogic;
   scan_out                         : out std_ulogic;

   ex1_instr                        : in  std_ulogic_vector(11 to 20);
   ex1_tid                          : in  std_ulogic_vector(0 to threads-1);
   dec_spr_ex1_is_mfspr             : in  std_ulogic;
   dec_spr_ex1_is_mtspr             : in  std_ulogic;

   ex6_valid                        : in  std_ulogic_vector(0 to threads-1);
   ex6_spr_wd                       : in  std_ulogic_vector(64-regsize to 63);

   cspr_tspr_ex6_is_mtspr           : out std_ulogic;
   cspr_tspr_ex6_instr              : out std_ulogic_vector(11 to 20);
   cspr_tspr_ex2_is_mfspr           : out std_ulogic;
   cspr_tspr_ex2_instr              : out std_ulogic_vector(11 to 20);

   tspr_cspr_ex2_tspr_rt            : in  std_ulogic_vector(0 to regsize*threads-1);
   fspr_byp_ex3_spr_rt              : out std_ulogic_vector(64-regsize to 63);
   mux_spr_ex2_rt                   : in std_ulogic_vector(64-regsize to 63);

   ex2_is_any_load_dac              : in  std_ulogic;
   ex2_is_any_store_dac             : in  std_ulogic;

   xu_lsu_ex4_dvc1_en               : out std_ulogic;
   xu_lsu_ex4_dvc2_en               : out std_ulogic;
   lsu_xu_ex2_dvc1_st_cmp           : in  std_ulogic_vector(8-regsize/8 to 7);
   lsu_xu_ex2_dvc2_st_cmp           : in  std_ulogic_vector(8-regsize/8 to 7);
   lsu_xu_ex8_dvc1_ld_cmp           : in  std_ulogic_vector(8-regsize/8 to 7);
   lsu_xu_ex8_dvc2_ld_cmp           : in  std_ulogic_vector(8-regsize/8 to 7);
   lsu_xu_rel_dvc1_en               : in  std_ulogic;
   lsu_xu_rel_dvc2_en               : in  std_ulogic;
   lsu_xu_rel_dvc_thrd_id           : in  std_ulogic_vector(0 to 3);
   lsu_xu_rel_dvc1_cmp              : in  std_ulogic_vector(8-regsize/8 to 7);
   lsu_xu_rel_dvc2_cmp              : in  std_ulogic_vector(8-regsize/8 to 7);       

   fxu_cpl_ex3_dac1r_cmpr_async     : out std_ulogic_vector(0 to threads-1);
   fxu_cpl_ex3_dac2r_cmpr_async     : out std_ulogic_vector(0 to threads-1);
   fxu_cpl_ex3_dac1r_cmpr           : out std_ulogic_vector(0 to threads-1);
   fxu_cpl_ex3_dac2r_cmpr           : out std_ulogic_vector(0 to threads-1);
   fxu_cpl_ex3_dac3r_cmpr           : out std_ulogic_vector(0 to threads-1);
   fxu_cpl_ex3_dac4r_cmpr           : out std_ulogic_vector(0 to threads-1);
   fxu_cpl_ex3_dac1w_cmpr           : out std_ulogic_vector(0 to threads-1);
   fxu_cpl_ex3_dac2w_cmpr           : out std_ulogic_vector(0 to threads-1);
   fxu_cpl_ex3_dac3w_cmpr           : out std_ulogic_vector(0 to threads-1);
   fxu_cpl_ex3_dac4w_cmpr           : out std_ulogic_vector(0 to threads-1);
   
   spr_bit_act                      : in  std_ulogic;
   spr_msr_pr                       : in  std_ulogic_vector(0 to threads-1);
   spr_msr_ds                       : in  std_ulogic_vector(0 to threads-1);

   spr_dbcr0_dac1                   : in  std_ulogic_vector(0 to 2*threads-1);
   spr_dbcr0_dac2                   : in  std_ulogic_vector(0 to 2*threads-1);
   spr_dbcr0_dac3                   : in  std_ulogic_vector(0 to 2*threads-1);
   spr_dbcr0_dac4                   : in  std_ulogic_vector(0 to 2*threads-1);

   tspr_cspr_dbcr2_dac1us           : in  std_ulogic_vector(0 to 2*threads-1);
   tspr_cspr_dbcr2_dac1er           : in  std_ulogic_vector(0 to 2*threads-1);
   tspr_cspr_dbcr2_dac2us           : in  std_ulogic_vector(0 to 2*threads-1);
   tspr_cspr_dbcr2_dac2er           : in  std_ulogic_vector(0 to 2*threads-1);
   tspr_cspr_dbcr3_dac3us           : in  std_ulogic_vector(0 to 2*threads-1);
   tspr_cspr_dbcr3_dac3er           : in  std_ulogic_vector(0 to 2*threads-1);
   tspr_cspr_dbcr3_dac4us           : in  std_ulogic_vector(0 to 2*threads-1);
   tspr_cspr_dbcr3_dac4er           : in  std_ulogic_vector(0 to 2*threads-1);

   tspr_cspr_dbcr2_dac12m           : in  std_ulogic_vector(0 to threads-1);
   tspr_cspr_dbcr3_dac34m           : in  std_ulogic_vector(0 to threads-1);
   tspr_cspr_dbcr2_dvc1m            : in  std_ulogic_vector(0 to 2*threads-1);
   tspr_cspr_dbcr2_dvc2m            : in  std_ulogic_vector(0 to 2*threads-1);
   tspr_cspr_dbcr2_dvc1be           : in  std_ulogic_vector(0 to 8*threads-1);
   tspr_cspr_dbcr2_dvc2be           : in  std_ulogic_vector(0 to 8*threads-1);


   vdd                              : inout power_logic;
   gnd                              : inout power_logic
);

-- synopsys translate_off

-- synopsys translate_on
end xuq_fxu_spr_cspr;
architecture xuq_fxu_spr_cspr of xuq_fxu_spr_cspr is

subtype DO                            is std_ulogic_vector(65-regsize to 64);
signal dac1_d         , dac1_q         : std_ulogic_vector(64-(regsize) to 63);
signal dac2_d         , dac2_q         : std_ulogic_vector(64-(regsize) to 63);
signal dac3_d         , dac3_q         : std_ulogic_vector(64-(regsize) to 63);
signal dac4_d         , dac4_q         : std_ulogic_vector(64-(regsize) to 63);
constant dac1_offset                   : natural := 0;
constant dac2_offset                   : natural := dac1_offset     + dac1_q'length*a2mode;
constant dac3_offset                   : natural := dac2_offset     + dac2_q'length*a2mode;
constant dac4_offset                   : natural := dac3_offset     + dac3_q'length;
constant last_reg_offset               : natural := dac4_offset     + dac4_q'length;
signal exx_act_q,                 exx_act_d                   : std_ulogic_vector(2 to 5);                
signal ex2_dac12m_q,              ex2_dac12m_d                : std_ulogic_vector(0 to 7);                
signal ex2_dac34m_q,              ex2_dac34m_d                : std_ulogic_vector(0 to 7);                
signal ex2_instr_q                                            : std_ulogic_vector(11 to 20);              
signal ex2_is_mfspr_q                                         : std_ulogic;                               
signal ex2_is_mtspr_q                                         : std_ulogic;                               
signal ex2_tid_q                                              : std_ulogic_vector(0 to threads-1);        
signal ex3_dac1r_cmpr_q,          ex2_dac1r_cmpr              : std_ulogic_vector(0 to threads-1);        
signal ex3_dac1w_cmpr_q,          ex2_dac1w_cmpr              : std_ulogic_vector(0 to threads-1);        
signal ex3_dac2r_cmpr_q,          ex2_dac2r_cmpr              : std_ulogic_vector(0 to threads-1);        
signal ex3_dac2w_cmpr_q,          ex2_dac2w_cmpr              : std_ulogic_vector(0 to threads-1);        
signal ex3_dac3r_cmpr_q,          ex2_dac3r_cmpr              : std_ulogic_vector(0 to threads-1);        
signal ex3_dac3w_cmpr_q,          ex2_dac3w_cmpr              : std_ulogic_vector(0 to threads-1);        
signal ex3_dac4r_cmpr_q,          ex2_dac4r_cmpr              : std_ulogic_vector(0 to threads-1);        
signal ex3_dac4w_cmpr_q,          ex2_dac4w_cmpr              : std_ulogic_vector(0 to threads-1);        
signal ex3_dvc1w_cmpr_q,          ex2_dvc1w_cmpr              : std_ulogic_vector(0 to threads-1);        
signal ex3_dvc2w_cmpr_q,          ex2_dvc2w_cmpr              : std_ulogic_vector(0 to threads-1);        
signal ex3_instr_q                                            : std_ulogic_vector(11 to 20);              
signal ex3_is_mtspr_q                                         : std_ulogic;                               
signal ex3_spr_rt_q,              ex3_spr_rt_d                : std_ulogic_vector(64-regsize to 63);      
signal ex4_dvc1_en_q,             ex3_dvc1_en                 : std_ulogic;                               
signal ex4_dvc2_en_q,             ex3_dvc2_en                 : std_ulogic;                               
signal ex4_instr_q                                            : std_ulogic_vector(11 to 20);              
signal ex4_is_mtspr_q                                         : std_ulogic;                               
signal ex5_dvc1_en_q                                          : std_ulogic;                               
signal ex5_dvc2_en_q                                          : std_ulogic;                               
signal ex5_instr_q                                            : std_ulogic_vector(11 to 20);              
signal ex5_is_mtspr_q                                         : std_ulogic;                               
signal ex6_dvc1_en_q                                          : std_ulogic;                               
signal ex6_dvc2_en_q                                          : std_ulogic;                               
signal ex6_instr_q                                            : std_ulogic_vector(11 to 20);              
signal ex6_is_mtspr_q                                         : std_ulogic;                               
signal ex7_dvc1_en_q                                          : std_ulogic;                               
signal ex7_dvc2_en_q                                          : std_ulogic;                               
signal ex7_val_q                                              : std_ulogic_vector(0 to threads-1);        
signal ex8_dvc1_en_q                                          : std_ulogic;                               
signal ex8_dvc2_en_q                                          : std_ulogic;                               
signal ex8_val_q                                              : std_ulogic_vector(0 to threads-1);        
signal dbcr0_dac1_q                                           : std_ulogic_vector(0 to 2*threads-1);      
signal dbcr0_dac2_q                                           : std_ulogic_vector(0 to 2*threads-1);      
signal dbcr0_dac3_q                                           : std_ulogic_vector(0 to 2*threads-1);      
signal dbcr0_dac4_q                                           : std_ulogic_vector(0 to 2*threads-1);      
signal dbcr2_dvc1m_on_q,          dbcr2_dvc1m_on_d            : std_ulogic_vector(0 to threads-1);        
signal dbcr2_dvc2m_on_q,          dbcr2_dvc2m_on_d            : std_ulogic_vector(0 to threads-1);        
signal dvc1r_cmpr_q,              dvc1r_cmpr_d                : std_ulogic_vector(0 to threads-1);        
signal dvc2r_cmpr_q,              dvc2r_cmpr_d                : std_ulogic_vector(0 to threads-1);        
signal msr_ds_q                                               : std_ulogic_vector(0 to threads-1);        
signal msr_pr_q                                               : std_ulogic_vector(0 to threads-1);        
signal spr_bit_act_q                                          : std_ulogic;                               
constant exx_act_offset                            : integer := last_reg_offset;
constant ex3_dac1r_cmpr_offset                     : integer := exx_act_offset                 + exx_act_q'length;
constant ex3_dac1w_cmpr_offset                     : integer := ex3_dac1r_cmpr_offset          + ex3_dac1r_cmpr_q'length;
constant ex3_dac2r_cmpr_offset                     : integer := ex3_dac1w_cmpr_offset          + ex3_dac1w_cmpr_q'length;
constant ex3_dac2w_cmpr_offset                     : integer := ex3_dac2r_cmpr_offset          + ex3_dac2r_cmpr_q'length;
constant ex3_dac3r_cmpr_offset                     : integer := ex3_dac2w_cmpr_offset          + ex3_dac2w_cmpr_q'length;
constant ex3_dac3w_cmpr_offset                     : integer := ex3_dac3r_cmpr_offset          + ex3_dac3r_cmpr_q'length;
constant ex3_dac4r_cmpr_offset                     : integer := ex3_dac3w_cmpr_offset          + ex3_dac3w_cmpr_q'length;
constant ex3_dac4w_cmpr_offset                     : integer := ex3_dac4r_cmpr_offset          + ex3_dac4r_cmpr_q'length;
constant ex3_dvc1w_cmpr_offset                     : integer := ex3_dac4w_cmpr_offset          + ex3_dac4w_cmpr_q'length;
constant ex3_dvc2w_cmpr_offset                     : integer := ex3_dvc1w_cmpr_offset          + ex3_dvc1w_cmpr_q'length;
constant ex3_instr_offset                          : integer := ex3_dvc2w_cmpr_offset          + ex3_dvc2w_cmpr_q'length;
constant ex3_is_mtspr_offset                       : integer := ex3_instr_offset               + ex3_instr_q'length;
constant ex3_spr_rt_offset                         : integer := ex3_is_mtspr_offset            + 1;
constant ex5_dvc1_en_offset                        : integer := ex3_spr_rt_offset              + ex3_spr_rt_q'length;
constant ex5_dvc2_en_offset                        : integer := ex5_dvc1_en_offset             + 1;
constant ex5_instr_offset                          : integer := ex5_dvc2_en_offset             + 1;
constant ex5_is_mtspr_offset                       : integer := ex5_instr_offset               + ex5_instr_q'length;
constant ex7_dvc1_en_offset                        : integer := ex5_is_mtspr_offset            + 1;
constant ex7_dvc2_en_offset                        : integer := ex7_dvc1_en_offset             + 1;
constant ex7_val_offset                            : integer := ex7_dvc2_en_offset             + 1;
constant ex8_val_offset                            : integer := ex7_val_offset                 + ex7_val_q'length;
constant dbcr0_dac1_offset                         : integer := ex8_val_offset                 + ex8_val_q'length;
constant dbcr0_dac2_offset                         : integer := dbcr0_dac1_offset              + dbcr0_dac1_q'length;
constant dbcr0_dac3_offset                         : integer := dbcr0_dac2_offset              + dbcr0_dac2_q'length;
constant dbcr0_dac4_offset                         : integer := dbcr0_dac3_offset              + dbcr0_dac3_q'length;
constant dbcr2_dvc1m_on_offset                     : integer := dbcr0_dac4_offset              + dbcr0_dac4_q'length;
constant dbcr2_dvc2m_on_offset                     : integer := dbcr2_dvc1m_on_offset          + dbcr2_dvc1m_on_q'length;
constant dvc1r_cmpr_offset                         : integer := dbcr2_dvc2m_on_offset          + dbcr2_dvc2m_on_q'length;
constant dvc2r_cmpr_offset                         : integer := dvc1r_cmpr_offset              + dvc1r_cmpr_q'length;
constant msr_ds_offset                             : integer := dvc2r_cmpr_offset              + dvc2r_cmpr_q'length;
constant msr_pr_offset                             : integer := msr_ds_offset                  + msr_ds_q'length;
constant spr_bit_act_offset                        : integer := msr_pr_offset                  + msr_pr_q'length;
constant scan_right                                : integer := spr_bit_act_offset             + 1;
signal siv                                         : std_ulogic_vector(0 to scan_right-1);
signal sov                                         : std_ulogic_vector(0 to scan_right-1);
signal tiup                                        : std_ulogic;
signal tidn                                        : std_ulogic_vector(00 to 63);
signal ex2_instr                                   : std_ulogic_vector(11 to 20);
signal ex6_is_mtspr                                : std_ulogic;
signal ex6_instr                                   : std_ulogic_vector(11 to 20);
signal ex6_val                                     : std_ulogic;
signal ex2_cspr_rt,ex2_tspr_rt                     : std_ulogic_vector(64-regsize to 63);
signal ex2_dac2_mask                               : std_ulogic_vector(64-regsize to 63);
signal ex2_dac4_mask                               : std_ulogic_vector(64-regsize to 63);
signal ex2_dac1_cmpr,          ex2_dac1_cmpr_sel   : std_ulogic;
signal ex2_dac2_cmpr,          ex2_dac2_cmpr_sel   : std_ulogic;
signal ex2_dac3_cmpr,          ex2_dac3_cmpr_sel   : std_ulogic;
signal ex2_dac4_cmpr,          ex2_dac4_cmpr_sel   : std_ulogic;
signal ex2_dac1r_en,           ex2_dac1w_en        : std_ulogic_vector(0 to threads-1);
signal ex2_dac2r_en,           ex2_dac2w_en        : std_ulogic_vector(0 to threads-1);
signal ex2_dac3r_en,           ex2_dac3w_en        : std_ulogic_vector(0 to threads-1);
signal ex2_dac4r_en,           ex2_dac4w_en        : std_ulogic_vector(0 to threads-1);
signal ex8_dvc1r_cmpr,rel_dvc1r_cmpr               : std_ulogic_vector(0 to threads-1);
signal ex8_dvc2r_cmpr,rel_dvc2r_cmpr               : std_ulogic_vector(0 to threads-1);
signal ex8_dvc1_en,            ex8_dvc2_en         : std_ulogic_vector(0 to threads-1);
signal rel_dvc1_en,            rel_dvc2_en         : std_ulogic_vector(0 to threads-1);
signal exx_act                                     : std_ulogic_vector(1 to 5);


signal ex6_dac1_di                     : std_ulogic_vector(dac1_q'range);
signal ex6_dac2_di                     : std_ulogic_vector(dac2_q'range);
signal ex6_dac3_di                     : std_ulogic_vector(dac3_q'range);
signal ex6_dac4_di                     : std_ulogic_vector(dac4_q'range);
signal
	ex2_dac1_rdec  , ex2_dac2_rdec  , ex2_dac3_rdec  , ex2_dac4_rdec  
													: std_ulogic;
signal
	ex2_dac1_re    , ex2_dac2_re    , ex2_dac3_re    , ex2_dac4_re    
													: std_ulogic;
signal
	ex6_dac1_wdec  , ex6_dac2_wdec  , ex6_dac3_wdec  , ex6_dac4_wdec  
													: std_ulogic;
signal
	ex6_dac1_we    , ex6_dac2_we    , ex6_dac3_we    , ex6_dac4_we    
													: std_ulogic;
signal
	dac1_act       , dac2_act       , dac3_act       , dac4_act       
													: std_ulogic;
signal
	dac1_do        , dac2_do        , dac3_do        , dac4_do        
													: std_ulogic_vector(0 to 64);

begin


tiup           <= '1';
tidn           <= (others=>'0');


exx_act_d         <= exx_act(1 to 4);

exx_act(1)        <= or_reduce(ex1_tid);
exx_act(2)        <= exx_act_q(2);
exx_act(3)        <= exx_act_q(3);
exx_act(4)        <= exx_act_q(4);
exx_act(5)        <= exx_act_q(5);

ex2_instr      <= ex2_instr_q;
ex6_is_mtspr   <= ex6_is_mtspr_q;
ex6_instr      <= ex6_instr_q;
ex6_val        <= or_reduce(ex6_valid);

cspr_tspr_ex6_is_mtspr  <= ex6_is_mtspr_q;
cspr_tspr_ex6_instr     <= ex6_instr_q;
cspr_tspr_ex2_is_mfspr  <= ex2_is_mfspr_q;
cspr_tspr_ex2_instr     <= ex2_instr_q;

dac1_act       <= ex6_dac1_we;
dac1_d         <= ex6_dac1_di;

dac2_act       <= ex6_dac2_we;
dac2_d         <= ex6_dac2_di;

dac3_act       <= ex6_dac3_we;
dac3_d         <= ex6_dac3_di;

dac4_act       <= ex6_dac4_we;
dac4_d         <= ex6_dac4_di;


ex2_dac12m_d               <= fanout(or_reduce(tspr_cspr_dbcr2_dac12m and ex1_tid),ex2_dac12m_d'length);
ex2_dac34m_d               <= fanout(or_reduce(tspr_cspr_dbcr3_dac34m and ex1_tid),ex2_dac34m_d'length);

ex2_dac2_mask              <= dac2_q or not fanout(ex2_dac12m_q,regsize);
ex2_dac4_mask              <= dac4_q or not fanout(ex2_dac34m_q,regsize);

ex2_dac1_cmpr              <= and_reduce((mux_spr_ex2_rt xnor dac1_q) or not ex2_dac2_mask);
ex2_dac2_cmpr              <= and_reduce((mux_spr_ex2_rt xnor dac2_q)                     );
ex2_dac3_cmpr              <= and_reduce((mux_spr_ex2_rt xnor dac3_q) or not ex2_dac4_mask);
ex2_dac4_cmpr              <= and_reduce((mux_spr_ex2_rt xnor dac4_q)                     );

ex2_dac1_cmpr_sel          <= ex2_dac1_cmpr;
ex2_dac2_cmpr_sel          <= ex2_dac2_cmpr when ex2_dac12m_q(0)='0' else ex2_dac1_cmpr;
ex2_dac3_cmpr_sel          <= ex2_dac3_cmpr;
ex2_dac4_cmpr_sel          <= ex2_dac4_cmpr when ex2_dac34m_q(0)='0' else ex2_dac3_cmpr;

xuq_fxu_spr_dac1en : entity work.xuq_spr_dacen(xuq_spr_dacen)
generic map(
   threads                          => threads)
port map(
   spr_msr_pr                       => msr_pr_q,
   spr_msr_ds                       => msr_ds_q,
   spr_dbcr0_dac                    => dbcr0_dac1_q,
   spr_dbcr_dac_us                  => tspr_cspr_dbcr2_dac1us,
   spr_dbcr_dac_er                  => tspr_cspr_dbcr2_dac1er,   
   val                              => ex2_tid_q,
   load                             => ex2_is_any_load_dac,
   store                            => ex2_is_any_store_dac,
   dacr_en                          => ex2_dac1r_en,
   dacw_en                          => ex2_dac1w_en);

xuq_fxu_spr_dac2en : entity work.xuq_spr_dacen(xuq_spr_dacen)
generic map(
   threads                          => threads)
port map(
   spr_msr_pr                       => msr_pr_q,
   spr_msr_ds                       => msr_ds_q,
   spr_dbcr0_dac                    => dbcr0_dac2_q,
   spr_dbcr_dac_us                  => tspr_cspr_dbcr2_dac2us,
   spr_dbcr_dac_er                  => tspr_cspr_dbcr2_dac2er,   
   val                              => ex2_tid_q,
   load                             => ex2_is_any_load_dac,
   store                            => ex2_is_any_store_dac,
   dacr_en                          => ex2_dac2r_en,
   dacw_en                          => ex2_dac2w_en);


xuq_fxu_spr_dac3en : entity work.xuq_spr_dacen(xuq_spr_dacen)
generic map(
   threads                          => threads)
port map(
   spr_msr_pr                       => msr_pr_q,
   spr_msr_ds                       => msr_ds_q,
   spr_dbcr0_dac                    => dbcr0_dac3_q,
   spr_dbcr_dac_us                  => tspr_cspr_dbcr3_dac3us,
   spr_dbcr_dac_er                  => tspr_cspr_dbcr3_dac3er,   
   val                              => ex2_tid_q,
   load                             => ex2_is_any_load_dac,
   store                            => ex2_is_any_store_dac,
   dacr_en                          => ex2_dac3r_en,
   dacw_en                          => ex2_dac3w_en);


xuq_fxu_spr_dac4en : entity work.xuq_spr_dacen(xuq_spr_dacen)
generic map(
   threads                          => threads)
port map(
   spr_msr_pr                       => msr_pr_q,
   spr_msr_ds                       => msr_ds_q,
   spr_dbcr0_dac                    => dbcr0_dac4_q,
   spr_dbcr_dac_us                  => tspr_cspr_dbcr3_dac4us,
   spr_dbcr_dac_er                  => tspr_cspr_dbcr3_dac4er,   
   val                              => ex2_tid_q,
   load                             => ex2_is_any_load_dac,
   store                            => ex2_is_any_store_dac,
   dacr_en                          => ex2_dac4r_en,
   dacw_en                          => ex2_dac4w_en);


ex8_dvc1_en       <= gate(ex8_val_q,ex8_dvc1_en_q);
ex8_dvc2_en       <= gate(ex8_val_q,ex8_dvc2_en_q);

rel_dvc1_en       <= gate(lsu_xu_rel_dvc_thrd_id,lsu_xu_rel_dvc1_en);
rel_dvc2_en       <= gate(lsu_xu_rel_dvc_thrd_id,lsu_xu_rel_dvc2_en);

xuq_fxu_spr_dvc_cmp : for t in 0 to threads-1 generate
begin
  
   dbcr2_dvc1m_on_d(t)     <= or_reduce(tspr_cspr_dbcr2_dvc1m(2*t to 2*t+1)) and or_reduce(tspr_cspr_dbcr2_dvc1be(t*8+8-lsu_xu_ex2_dvc1_st_cmp'length to t*8+7));
   dbcr2_dvc2m_on_d(t)     <= or_reduce(tspr_cspr_dbcr2_dvc2m(2*t to 2*t+1)) and or_reduce(tspr_cspr_dbcr2_dvc2be(t*8+8-lsu_xu_ex2_dvc2_st_cmp'length to t*8+7));

   dvc1_st : entity work.xuq_spr_dvccmp(xuq_spr_dvccmp)
   generic map(regsize => regsize)
   port map(
      en             => '1',
      cmp            => lsu_xu_ex2_dvc1_st_cmp,
      dvcm           => tspr_cspr_dbcr2_dvc1m(2*t to 2*t+1),
      dvcbe          => tspr_cspr_dbcr2_dvc1be(t*8+8-lsu_xu_ex2_dvc1_st_cmp'length to t*8+7),
      dvc_cmpr       => ex2_dvc1w_cmpr(t)
      );

   dvc2_st : entity work.xuq_spr_dvccmp(xuq_spr_dvccmp)
   generic map(regsize => regsize)
   port map(
      en             => '1',
      cmp            => lsu_xu_ex2_dvc2_st_cmp,
      dvcm           => tspr_cspr_dbcr2_dvc2m(2*t to 2*t+1),
      dvcbe          => tspr_cspr_dbcr2_dvc2be(t*8+8-lsu_xu_ex2_dvc2_st_cmp'length to t*8+7),
      dvc_cmpr       => ex2_dvc2w_cmpr(t)
      );

   dvc1_ld : entity work.xuq_spr_dvccmp(xuq_spr_dvccmp)
   generic map(regsize => regsize)
   port map(
      en             => ex8_dvc1_en(t),
      en00           => '0',
      cmp            => lsu_xu_ex8_dvc1_ld_cmp,
      dvcm           => tspr_cspr_dbcr2_dvc1m(2*t to 2*t+1),
      dvcbe          => tspr_cspr_dbcr2_dvc1be(t*8+8-lsu_xu_ex8_dvc1_ld_cmp'length to t*8+7),
      dvc_cmpr       => ex8_dvc1r_cmpr(t)
      );

   dvc2_ld : entity work.xuq_spr_dvccmp(xuq_spr_dvccmp)
   generic map(regsize => regsize)
   port map(
      en             => ex8_dvc2_en(t),
      en00           => '0',
      cmp            => lsu_xu_ex8_dvc2_ld_cmp,
      dvcm           => tspr_cspr_dbcr2_dvc2m(2*t to 2*t+1),
      dvcbe          => tspr_cspr_dbcr2_dvc2be(t*8+8-lsu_xu_ex8_dvc2_ld_cmp'length to t*8+7),
      dvc_cmpr       => ex8_dvc2r_cmpr(t)
      );

   dvc1_rel : entity work.xuq_spr_dvccmp(xuq_spr_dvccmp)
   generic map(regsize => regsize)
   port map(
      en             => rel_dvc1_en(t),
      en00           => '0',
      cmp            => lsu_xu_rel_dvc1_cmp,
      dvcm           => tspr_cspr_dbcr2_dvc1m(2*t to 2*t+1),
      dvcbe          => tspr_cspr_dbcr2_dvc1be(t*8+8-lsu_xu_rel_dvc1_cmp'length to t*8+7),
      dvc_cmpr       => rel_dvc1r_cmpr(t)
      );

   dvc2_rel : entity work.xuq_spr_dvccmp(xuq_spr_dvccmp)
   generic map(regsize => regsize)
   port map(
      en             => rel_dvc2_en(t),
      en00           => '0',
      cmp            => lsu_xu_rel_dvc2_cmp,
      dvcm           => tspr_cspr_dbcr2_dvc2m(2*t to 2*t+1),
      dvcbe          => tspr_cspr_dbcr2_dvc2be(t*8+8-lsu_xu_rel_dvc2_cmp'length to t*8+7),
      dvc_cmpr       => rel_dvc2r_cmpr(t)
      );

end generate;

ex2_dac1r_cmpr          <= gate(ex2_dac1r_en,ex2_dac1_cmpr_sel);
ex2_dac2r_cmpr          <= gate(ex2_dac2r_en,ex2_dac2_cmpr_sel);
ex2_dac3r_cmpr          <= gate(ex2_dac3r_en,ex2_dac3_cmpr_sel);
ex2_dac4r_cmpr          <= gate(ex2_dac4r_en,ex2_dac4_cmpr_sel);
                
ex2_dac1w_cmpr          <= gate(ex2_dac1w_en,ex2_dac1_cmpr_sel);
ex2_dac2w_cmpr          <= gate(ex2_dac2w_en,ex2_dac2_cmpr_sel);
ex2_dac3w_cmpr          <= gate(ex2_dac3w_en,ex2_dac3_cmpr_sel);
ex2_dac4w_cmpr          <= gate(ex2_dac4w_en,ex2_dac4_cmpr_sel);

dvc1r_cmpr_d            <= ex8_dvc1r_cmpr or rel_dvc1r_cmpr;
dvc2r_cmpr_d            <= ex8_dvc2r_cmpr or rel_dvc2r_cmpr;

ex3_dvc1_en             <= or_reduce(ex3_dac1r_cmpr_q and     dbcr2_dvc1m_on_q);
ex3_dvc2_en             <= or_reduce(ex3_dac2r_cmpr_q and     dbcr2_dvc2m_on_q);

fxu_cpl_ex3_dac1r_cmpr_async  <= dvc1r_cmpr_q;
fxu_cpl_ex3_dac2r_cmpr_async  <= dvc2r_cmpr_q;
fxu_cpl_ex3_dac1r_cmpr     <=(ex3_dac1r_cmpr_q and not dbcr2_dvc1m_on_q);
fxu_cpl_ex3_dac2r_cmpr     <=(ex3_dac2r_cmpr_q and not dbcr2_dvc2m_on_q);
fxu_cpl_ex3_dac3r_cmpr     <= ex3_dac3r_cmpr_q; 
fxu_cpl_ex3_dac4r_cmpr     <= ex3_dac4r_cmpr_q;

fxu_cpl_ex3_dac1w_cmpr     <= ex3_dac1w_cmpr_q and (ex3_dvc1w_cmpr_q or not dbcr2_dvc1m_on_q);
fxu_cpl_ex3_dac2w_cmpr     <= ex3_dac2w_cmpr_q and (ex3_dvc2w_cmpr_q or not dbcr2_dvc2m_on_q);
fxu_cpl_ex3_dac3w_cmpr     <= ex3_dac3w_cmpr_q;
fxu_cpl_ex3_dac4w_cmpr     <= ex3_dac4w_cmpr_q;

xu_lsu_ex4_dvc1_en         <= ex4_dvc1_en_q;
xu_lsu_ex4_dvc2_en         <= ex4_dvc2_en_q;


readmux_00 : if a2mode = 0 and hvmode = 0 generate
ex2_cspr_rt <=
	(dac3_do(DO'range)        and (DO'range => ex2_dac3_re    )) or
	(dac4_do(DO'range)        and (DO'range => ex2_dac4_re    ));
end generate;
readmux_01 : if a2mode = 0 and hvmode = 1 generate
ex2_cspr_rt <=
	(dac3_do(DO'range)        and (DO'range => ex2_dac3_re    )) or
	(dac4_do(DO'range)        and (DO'range => ex2_dac4_re    ));
end generate;
readmux_10 : if a2mode = 1 and hvmode = 0 generate
ex2_cspr_rt <=
	(dac1_do(DO'range)        and (DO'range => ex2_dac1_re    )) or
	(dac2_do(DO'range)        and (DO'range => ex2_dac2_re    )) or
	(dac3_do(DO'range)        and (DO'range => ex2_dac3_re    )) or
	(dac4_do(DO'range)        and (DO'range => ex2_dac4_re    ));
end generate;
readmux_11 : if a2mode = 1 and hvmode = 1 generate
ex2_cspr_rt <=
	(dac1_do(DO'range)        and (DO'range => ex2_dac1_re    )) or
	(dac2_do(DO'range)        and (DO'range => ex2_dac2_re    )) or
	(dac3_do(DO'range)        and (DO'range => ex2_dac3_re    )) or
	(dac4_do(DO'range)        and (DO'range => ex2_dac4_re    ));
end generate;

ex2_tspr_rt                <= mux_t(tspr_cspr_ex2_tspr_rt,ex2_tid_q);
ex3_spr_rt_d               <= gate((ex2_tspr_rt or ex2_cspr_rt),ex2_is_mfspr_q);
fspr_byp_ex3_spr_rt        <= ex3_spr_rt_q;

mark_unused(tidn);


ex2_dac1_rdec     <= (ex2_instr(11 to 20) = "1110001001");   
ex2_dac2_rdec     <= (ex2_instr(11 to 20) = "1110101001");   
ex2_dac3_rdec     <= (ex2_instr(11 to 20) = "1000111010");   
ex2_dac4_rdec     <= (ex2_instr(11 to 20) = "1001011010");   
ex2_dac1_re       <=  ex2_dac1_rdec;
ex2_dac2_re       <=  ex2_dac2_rdec;
ex2_dac3_re       <=  ex2_dac3_rdec;
ex2_dac4_re       <=  ex2_dac4_rdec;

ex6_dac1_wdec     <= (ex6_instr(11 to 20) = "1110001001");   
ex6_dac2_wdec     <= (ex6_instr(11 to 20) = "1110101001");   
ex6_dac3_wdec     <= (ex6_instr(11 to 20) = "1000111010");   
ex6_dac4_wdec     <= (ex6_instr(11 to 20) = "1001011010");   
ex6_dac1_we       <= ex6_val and ex6_is_mtspr and  ex6_dac1_wdec;
ex6_dac2_we       <= ex6_val and ex6_is_mtspr and  ex6_dac2_wdec;
ex6_dac3_we       <= ex6_val and ex6_is_mtspr and  ex6_dac3_wdec;
ex6_dac4_we       <= ex6_val and ex6_is_mtspr and  ex6_dac4_wdec;



ex6_dac1_di    <= ex6_spr_wd(64-(regsize) to 63)   ; 
dac1_do        <= tidn(0 to 64-(regsize))          &
						dac1_q(64-(regsize) to 63)       ; 
ex6_dac2_di    <= ex6_spr_wd(64-(regsize) to 63)   ; 
dac2_do        <= tidn(0 to 64-(regsize))          &
						dac2_q(64-(regsize) to 63)       ; 
ex6_dac3_di    <= ex6_spr_wd(64-(regsize) to 63)   ; 
dac3_do        <= tidn(0 to 64-(regsize))          &
						dac3_q(64-(regsize) to 63)       ; 
ex6_dac4_di    <= ex6_spr_wd(64-(regsize) to 63)   ; 
dac4_do        <= tidn(0 to 64-(regsize))          &
						dac4_q(64-(regsize) to 63)       ; 

mark_unused(dac1_do(0 to 64-regsize));
mark_unused(dac2_do(0 to 64-regsize));
mark_unused(dac3_do(0 to 64-regsize));
mark_unused(dac4_do(0 to 64-regsize));

dac1_latch_gen : if a2mode = 1 generate
dac1_latch : tri_ser_rlmreg_p
generic map(width   => dac1_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
   port map(nclk    => nclk, vd => vdd, gd => gnd,
            act     => dac1_act,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(dac1_offset to dac1_offset + dac1_q'length-1),
            scout   => sov(dac1_offset to dac1_offset + dac1_q'length-1),
            din     => dac1_d,
            dout    => dac1_q);
end generate;
dac1_latch_tie : if a2mode = 0 generate
	dac1_q          <= (others=>'0');
end generate;
dac2_latch_gen : if a2mode = 1 generate
dac2_latch : tri_ser_rlmreg_p
generic map(width   => dac2_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
   port map(nclk    => nclk, vd => vdd, gd => gnd,
            act     => dac2_act,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(dac2_offset to dac2_offset + dac2_q'length-1),
            scout   => sov(dac2_offset to dac2_offset + dac2_q'length-1),
            din     => dac2_d,
            dout    => dac2_q);
end generate;
dac2_latch_tie : if a2mode = 0 generate
	dac2_q          <= (others=>'0');
end generate;
dac3_latch : tri_ser_rlmreg_p
generic map(width   => dac3_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
   port map(nclk    => nclk, vd => vdd, gd => gnd,
            act     => dac3_act,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(dac3_offset to dac3_offset + dac3_q'length-1),
            scout   => sov(dac3_offset to dac3_offset + dac3_q'length-1),
            din     => dac3_d,
            dout    => dac3_q);
dac4_latch : tri_ser_rlmreg_p
generic map(width   => dac4_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
   port map(nclk    => nclk, vd => vdd, gd => gnd,
            act     => dac4_act,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(dac4_offset to dac4_offset + dac4_q'length-1),
            scout   => sov(dac4_offset to dac4_offset + dac4_q'length-1),
            din     => dac4_d,
            dout    => dac4_q);


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
ex2_dac12m_latch : tri_regk
  generic map (width => ex2_dac12m_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => exx_act(1)           ,
            forcee => func_nsl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_nsl_thold_0_b,
            din     => ex2_dac12m_d,
            dout    => ex2_dac12m_q);
ex2_dac34m_latch : tri_regk
  generic map (width => ex2_dac34m_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => exx_act(1)           ,
            forcee => func_nsl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_nsl_thold_0_b,
            din     => ex2_dac34m_d,
            dout    => ex2_dac34m_q);
ex2_instr_latch : tri_regk
  generic map (width => ex2_instr_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => exx_act(1)           ,
            forcee => func_nsl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_nsl_thold_0_b,
            din     => ex1_instr                  ,
            dout    => ex2_instr_q);
ex2_is_mfspr_latch : tri_regk
  generic map (width => 1, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => exx_act(1)           ,
            forcee => func_nsl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_nsl_thold_0_b,
            din(0)  => dec_spr_ex1_is_mfspr       ,
            dout(0) => ex2_is_mfspr_q);
ex2_is_mtspr_latch : tri_regk
  generic map (width => 1, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => exx_act(1)           ,
            forcee => func_nsl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_nsl_thold_0_b,
            din(0)  => dec_spr_ex1_is_mtspr       ,
            dout(0) => ex2_is_mtspr_q);
ex2_tid_latch : tri_regk
  generic map (width => ex2_tid_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => exx_act(1)           ,
            forcee => func_nsl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_nsl_thold_0_b,
            din     => ex1_tid                    ,
            dout    => ex2_tid_q);
ex3_dac1r_cmpr_latch : tri_rlmreg_p
  generic map (width => ex3_dac1r_cmpr_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => exx_act(2)           ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex3_dac1r_cmpr_offset to ex3_dac1r_cmpr_offset + ex3_dac1r_cmpr_q'length-1),
            scout   => sov(ex3_dac1r_cmpr_offset to ex3_dac1r_cmpr_offset + ex3_dac1r_cmpr_q'length-1),
            din     => ex2_dac1r_cmpr,
            dout    => ex3_dac1r_cmpr_q);
ex3_dac1w_cmpr_latch : tri_rlmreg_p
  generic map (width => ex3_dac1w_cmpr_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => exx_act(2)           ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex3_dac1w_cmpr_offset to ex3_dac1w_cmpr_offset + ex3_dac1w_cmpr_q'length-1),
            scout   => sov(ex3_dac1w_cmpr_offset to ex3_dac1w_cmpr_offset + ex3_dac1w_cmpr_q'length-1),
            din     => ex2_dac1w_cmpr,
            dout    => ex3_dac1w_cmpr_q);
ex3_dac2r_cmpr_latch : tri_rlmreg_p
  generic map (width => ex3_dac2r_cmpr_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => exx_act(2)           ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex3_dac2r_cmpr_offset to ex3_dac2r_cmpr_offset + ex3_dac2r_cmpr_q'length-1),
            scout   => sov(ex3_dac2r_cmpr_offset to ex3_dac2r_cmpr_offset + ex3_dac2r_cmpr_q'length-1),
            din     => ex2_dac2r_cmpr,
            dout    => ex3_dac2r_cmpr_q);
ex3_dac2w_cmpr_latch : tri_rlmreg_p
  generic map (width => ex3_dac2w_cmpr_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => exx_act(2)           ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex3_dac2w_cmpr_offset to ex3_dac2w_cmpr_offset + ex3_dac2w_cmpr_q'length-1),
            scout   => sov(ex3_dac2w_cmpr_offset to ex3_dac2w_cmpr_offset + ex3_dac2w_cmpr_q'length-1),
            din     => ex2_dac2w_cmpr,
            dout    => ex3_dac2w_cmpr_q);
ex3_dac3r_cmpr_latch : tri_rlmreg_p
  generic map (width => ex3_dac3r_cmpr_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => exx_act(2)           ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex3_dac3r_cmpr_offset to ex3_dac3r_cmpr_offset + ex3_dac3r_cmpr_q'length-1),
            scout   => sov(ex3_dac3r_cmpr_offset to ex3_dac3r_cmpr_offset + ex3_dac3r_cmpr_q'length-1),
            din     => ex2_dac3r_cmpr,
            dout    => ex3_dac3r_cmpr_q);
ex3_dac3w_cmpr_latch : tri_rlmreg_p
  generic map (width => ex3_dac3w_cmpr_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => exx_act(2)           ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex3_dac3w_cmpr_offset to ex3_dac3w_cmpr_offset + ex3_dac3w_cmpr_q'length-1),
            scout   => sov(ex3_dac3w_cmpr_offset to ex3_dac3w_cmpr_offset + ex3_dac3w_cmpr_q'length-1),
            din     => ex2_dac3w_cmpr,
            dout    => ex3_dac3w_cmpr_q);
ex3_dac4r_cmpr_latch : tri_rlmreg_p
  generic map (width => ex3_dac4r_cmpr_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => exx_act(2)           ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex3_dac4r_cmpr_offset to ex3_dac4r_cmpr_offset + ex3_dac4r_cmpr_q'length-1),
            scout   => sov(ex3_dac4r_cmpr_offset to ex3_dac4r_cmpr_offset + ex3_dac4r_cmpr_q'length-1),
            din     => ex2_dac4r_cmpr,
            dout    => ex3_dac4r_cmpr_q);
ex3_dac4w_cmpr_latch : tri_rlmreg_p
  generic map (width => ex3_dac4w_cmpr_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => exx_act(2)           ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex3_dac4w_cmpr_offset to ex3_dac4w_cmpr_offset + ex3_dac4w_cmpr_q'length-1),
            scout   => sov(ex3_dac4w_cmpr_offset to ex3_dac4w_cmpr_offset + ex3_dac4w_cmpr_q'length-1),
            din     => ex2_dac4w_cmpr,
            dout    => ex3_dac4w_cmpr_q);
ex3_dvc1w_cmpr_latch : tri_rlmreg_p
  generic map (width => ex3_dvc1w_cmpr_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => exx_act(2)           ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex3_dvc1w_cmpr_offset to ex3_dvc1w_cmpr_offset + ex3_dvc1w_cmpr_q'length-1),
            scout   => sov(ex3_dvc1w_cmpr_offset to ex3_dvc1w_cmpr_offset + ex3_dvc1w_cmpr_q'length-1),
            din     => ex2_dvc1w_cmpr,
            dout    => ex3_dvc1w_cmpr_q);
ex3_dvc2w_cmpr_latch : tri_rlmreg_p
  generic map (width => ex3_dvc2w_cmpr_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => exx_act(2)           ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex3_dvc2w_cmpr_offset to ex3_dvc2w_cmpr_offset + ex3_dvc2w_cmpr_q'length-1),
            scout   => sov(ex3_dvc2w_cmpr_offset to ex3_dvc2w_cmpr_offset + ex3_dvc2w_cmpr_q'length-1),
            din     => ex2_dvc2w_cmpr,
            dout    => ex3_dvc2w_cmpr_q);
ex3_instr_latch : tri_rlmreg_p
  generic map (width => ex3_instr_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
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
ex3_is_mtspr_latch : tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => exx_act(2)           ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex3_is_mtspr_offset),
            scout   => sov(ex3_is_mtspr_offset),
            din     => ex2_is_mtspr_q             ,
            dout    => ex3_is_mtspr_q);
ex3_spr_rt_latch : tri_rlmreg_p
  generic map (width => ex3_spr_rt_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => exx_act(2)           ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex3_spr_rt_offset to ex3_spr_rt_offset + ex3_spr_rt_q'length-1),
            scout   => sov(ex3_spr_rt_offset to ex3_spr_rt_offset + ex3_spr_rt_q'length-1),
            din     => ex3_spr_rt_d,
            dout    => ex3_spr_rt_q);
ex4_dvc1_en_latch : tri_regk
  generic map (width => 1, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => exx_act(3)           ,
            forcee => func_nsl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_nsl_thold_0_b,
            din(0)  => ex3_dvc1_en,
            dout(0) => ex4_dvc1_en_q);
ex4_dvc2_en_latch : tri_regk
  generic map (width => 1, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => exx_act(3)           ,
            forcee => func_nsl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_nsl_thold_0_b,
            din(0)  => ex3_dvc2_en,
            dout(0) => ex4_dvc2_en_q);
ex4_instr_latch : tri_regk
  generic map (width => ex4_instr_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => exx_act(3)           ,
            forcee => func_nsl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_nsl_thold_0_b,
            din     => ex3_instr_q                ,
            dout    => ex4_instr_q);
ex4_is_mtspr_latch : tri_regk
  generic map (width => 1, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => exx_act(3)           ,
            forcee => func_nsl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_nsl_thold_0_b,
            din(0)  => ex3_is_mtspr_q             ,
            dout(0) => ex4_is_mtspr_q);
ex5_dvc1_en_latch : tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => exx_act(4)           ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex5_dvc1_en_offset),
            scout   => sov(ex5_dvc1_en_offset),
            din     => ex4_dvc1_en_q              ,
            dout    => ex5_dvc1_en_q);
ex5_dvc2_en_latch : tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => exx_act(4)           ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex5_dvc2_en_offset),
            scout   => sov(ex5_dvc2_en_offset),
            din     => ex4_dvc2_en_q              ,
            dout    => ex5_dvc2_en_q);
ex5_instr_latch : tri_rlmreg_p
  generic map (width => ex5_instr_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => exx_act(4)           ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex5_instr_offset to ex5_instr_offset + ex5_instr_q'length-1),
            scout   => sov(ex5_instr_offset to ex5_instr_offset + ex5_instr_q'length-1),
            din     => ex4_instr_q                ,
            dout    => ex5_instr_q);
ex5_is_mtspr_latch : tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => exx_act(4)           ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex5_is_mtspr_offset),
            scout   => sov(ex5_is_mtspr_offset),
            din     => ex4_is_mtspr_q             ,
            dout    => ex5_is_mtspr_q);
ex6_dvc1_en_latch : tri_regk
  generic map (width => 1, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => exx_act(5)           ,
            forcee => func_nsl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_nsl_thold_0_b,
            din(0)  => ex5_dvc1_en_q              ,
            dout(0) => ex6_dvc1_en_q);
ex6_dvc2_en_latch : tri_regk
  generic map (width => 1, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => exx_act(5)           ,
            forcee => func_nsl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_nsl_thold_0_b,
            din(0)  => ex5_dvc2_en_q              ,
            dout(0) => ex6_dvc2_en_q);
ex6_instr_latch : tri_regk
  generic map (width => ex6_instr_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => exx_act(5)           ,
            forcee => func_nsl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_nsl_thold_0_b,
            din     => ex5_instr_q                ,
            dout    => ex6_instr_q);
ex6_is_mtspr_latch : tri_regk
  generic map (width => 1, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => exx_act(5)           ,
            forcee => func_nsl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_nsl_thold_0_b,
            din(0)  => ex5_is_mtspr_q             ,
            dout(0) => ex6_is_mtspr_q);
ex7_dvc1_en_latch : tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup                 ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex7_dvc1_en_offset),
            scout   => sov(ex7_dvc1_en_offset),
            din     => ex6_dvc1_en_q              ,
            dout    => ex7_dvc1_en_q);
ex7_dvc2_en_latch : tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup                 ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex7_dvc2_en_offset),
            scout   => sov(ex7_dvc2_en_offset),
            din     => ex6_dvc2_en_q              ,
            dout    => ex7_dvc2_en_q);
ex7_val_latch : tri_rlmreg_p
  generic map (width => ex7_val_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup                 ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex7_val_offset to ex7_val_offset + ex7_val_q'length-1),
            scout   => sov(ex7_val_offset to ex7_val_offset + ex7_val_q'length-1),
            din     => ex6_valid                  ,
            dout    => ex7_val_q);
ex8_dvc1_en_latch : tri_regk
  generic map (width => 1, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup                 ,
            forcee => func_nsl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_nsl_thold_0_b,
            din(0)  => ex7_dvc1_en_q              ,
            dout(0) => ex8_dvc1_en_q);
ex8_dvc2_en_latch : tri_regk
  generic map (width => 1, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup                 ,
            forcee => func_nsl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_nsl_thold_0_b,
            din(0)  => ex7_dvc2_en_q              ,
            dout(0) => ex8_dvc2_en_q);
ex8_val_latch : tri_rlmreg_p
  generic map (width => ex8_val_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup                 ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex8_val_offset to ex8_val_offset + ex8_val_q'length-1),
            scout   => sov(ex8_val_offset to ex8_val_offset + ex8_val_q'length-1),
            din     => ex7_val_q                  ,
            dout    => ex8_val_q);
dbcr0_dac1_latch : tri_rlmreg_p
  generic map (width => dbcr0_dac1_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => spr_bit_act_q          ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(dbcr0_dac1_offset to dbcr0_dac1_offset + dbcr0_dac1_q'length-1),
            scout   => sov(dbcr0_dac1_offset to dbcr0_dac1_offset + dbcr0_dac1_q'length-1),
            din     => spr_dbcr0_dac1             ,
            dout    => dbcr0_dac1_q);
dbcr0_dac2_latch : tri_rlmreg_p
  generic map (width => dbcr0_dac2_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => spr_bit_act_q          ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(dbcr0_dac2_offset to dbcr0_dac2_offset + dbcr0_dac2_q'length-1),
            scout   => sov(dbcr0_dac2_offset to dbcr0_dac2_offset + dbcr0_dac2_q'length-1),
            din     => spr_dbcr0_dac2             ,
            dout    => dbcr0_dac2_q);
dbcr0_dac3_latch : tri_rlmreg_p
  generic map (width => dbcr0_dac3_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => spr_bit_act_q          ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(dbcr0_dac3_offset to dbcr0_dac3_offset + dbcr0_dac3_q'length-1),
            scout   => sov(dbcr0_dac3_offset to dbcr0_dac3_offset + dbcr0_dac3_q'length-1),
            din     => spr_dbcr0_dac3             ,
            dout    => dbcr0_dac3_q);
dbcr0_dac4_latch : tri_rlmreg_p
  generic map (width => dbcr0_dac4_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => spr_bit_act_q          ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(dbcr0_dac4_offset to dbcr0_dac4_offset + dbcr0_dac4_q'length-1),
            scout   => sov(dbcr0_dac4_offset to dbcr0_dac4_offset + dbcr0_dac4_q'length-1),
            din     => spr_dbcr0_dac4             ,
            dout    => dbcr0_dac4_q);
dbcr2_dvc1m_on_latch : tri_rlmreg_p
  generic map (width => dbcr2_dvc1m_on_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => spr_bit_act_q          ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(dbcr2_dvc1m_on_offset to dbcr2_dvc1m_on_offset + dbcr2_dvc1m_on_q'length-1),
            scout   => sov(dbcr2_dvc1m_on_offset to dbcr2_dvc1m_on_offset + dbcr2_dvc1m_on_q'length-1),
            din     => dbcr2_dvc1m_on_d,
            dout    => dbcr2_dvc1m_on_q);
dbcr2_dvc2m_on_latch : tri_rlmreg_p
  generic map (width => dbcr2_dvc2m_on_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => spr_bit_act_q          ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(dbcr2_dvc2m_on_offset to dbcr2_dvc2m_on_offset + dbcr2_dvc2m_on_q'length-1),
            scout   => sov(dbcr2_dvc2m_on_offset to dbcr2_dvc2m_on_offset + dbcr2_dvc2m_on_q'length-1),
            din     => dbcr2_dvc2m_on_d,
            dout    => dbcr2_dvc2m_on_q);
dvc1r_cmpr_latch : tri_rlmreg_p
  generic map (width => dvc1r_cmpr_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => spr_bit_act_q          ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(dvc1r_cmpr_offset to dvc1r_cmpr_offset + dvc1r_cmpr_q'length-1),
            scout   => sov(dvc1r_cmpr_offset to dvc1r_cmpr_offset + dvc1r_cmpr_q'length-1),
            din     => dvc1r_cmpr_d,
            dout    => dvc1r_cmpr_q);
dvc2r_cmpr_latch : tri_rlmreg_p
  generic map (width => dvc2r_cmpr_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => spr_bit_act_q          ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(dvc2r_cmpr_offset to dvc2r_cmpr_offset + dvc2r_cmpr_q'length-1),
            scout   => sov(dvc2r_cmpr_offset to dvc2r_cmpr_offset + dvc2r_cmpr_q'length-1),
            din     => dvc2r_cmpr_d,
            dout    => dvc2r_cmpr_q);
msr_ds_latch : tri_rlmreg_p
  generic map (width => msr_ds_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup                 ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(msr_ds_offset to msr_ds_offset + msr_ds_q'length-1),
            scout   => sov(msr_ds_offset to msr_ds_offset + msr_ds_q'length-1),
            din     => spr_msr_ds                 ,
            dout    => msr_ds_q);
msr_pr_latch : tri_rlmreg_p
  generic map (width => msr_pr_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup                 ,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(msr_pr_offset to msr_pr_offset + msr_pr_q'length-1),
            scout   => sov(msr_pr_offset to msr_pr_offset + msr_pr_q'length-1),
            din     => spr_msr_pr                 ,
            dout    => msr_pr_q);
spr_bit_act_latch : tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(spr_bit_act_offset),
            scout   => sov(spr_bit_act_offset),
            din     => spr_bit_act,
            dout    => spr_bit_act_q);

siv(0 to scan_right-1)  <= sov(1 to scan_right-1) & scan_in;
scan_out                <= sov(0);

end architecture xuq_fxu_spr_cspr;
