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

--  Description:  XU SPR - per core registers & array
--
library ieee,ibm,support,work,tri;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use support.power_logic_pkg.all;
use ibm.std_ulogic_support.all;
use ibm.std_ulogic_function_support.all;
use tri.tri_latches_pkg.all;
use work.xuq_pkg.all;

entity xuq_cpl_spr_cspr is
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

   dcfg_sl_force : in  std_ulogic;
   dcfg_sl_thold_0_b                : in  std_ulogic;
   func_sl_force : in  std_ulogic;
   func_sl_thold_0_b                : in  std_ulogic;
   func_nsl_force : in  std_ulogic;
   func_nsl_thold_0_b               : in  std_ulogic;
   sg_0                             : in  std_ulogic;
   scan_in                          : in  std_ulogic;
   scan_out                         : out std_ulogic;
   dcfg_scan_in                     : in  std_ulogic;
   dcfg_scan_out                    : out std_ulogic;

   -- Decode
   spr_bit_act                      : in  std_ulogic;
   exx_act                          : in  std_ulogic_vector(1 to 4);
   ex1_instr                        : in  std_ulogic_vector(11 to 20);
   ex2_tid                          : in  std_ulogic_vector(0 to threads-1);
   ex1_is_mfspr                     : in  std_ulogic;
   ex1_is_mtspr                     : in  std_ulogic;

   -- IFAR
   ex2_ifar                         : in  std_ulogic_vector(0 to eff_ifar*threads-1);

   -- Write Interface
   ex5_valid                        : in  std_ulogic_vector(0 to threads-1);
   ex5_spr_wd                       : in  std_ulogic_vector(64-regsize to 63);

   ex2_mtiar                        : out std_ulogic;

   -- SPRT Interface
   cspr_tspr_ex5_is_mtspr           : out std_ulogic;
   cspr_tspr_ex5_instr              : out std_ulogic_vector(11 to 20);
   cspr_tspr_ex2_instr              : out std_ulogic_vector(11 to 20);

   -- Read Data
   tspr_cspr_ex2_tspr_rt            : in  std_ulogic_vector(0 to regsize*threads-1);
   cpl_byp_ex3_spr_rt               : out std_ulogic_vector(64-regsize to 63);
   
   
   -- IAC Compare
   ex3_iac1_cmpr                    : out std_ulogic_vector(0 to threads-1);
   ex3_iac2_cmpr                    : out std_ulogic_vector(0 to threads-1);
   ex3_iac3_cmpr                    : out std_ulogic_vector(0 to threads-1);
   ex3_iac4_cmpr                    : out std_ulogic_vector(0 to threads-1);

   -- SPRs
   spr_cpl_iac1_en                  : in  std_ulogic_vector(0 to threads-1);
   spr_cpl_iac2_en                  : in  std_ulogic_vector(0 to threads-1);
   spr_cpl_iac3_en                  : in  std_ulogic_vector(0 to threads-1);
   spr_cpl_iac4_en                  : in  std_ulogic_vector(0 to threads-1);
   spr_dbcr1_iac12m                 : in  std_ulogic_vector(0 to threads-1);
   spr_dbcr1_iac34m                 : in  std_ulogic_vector(0 to threads-1);
   spr_msr_cm                       : in  std_ulogic_vector(0 to threads-1);
	spr_givpr                        : out std_ulogic_vector(0 to eff_ifar-10-1);
	spr_ivpr                         : out std_ulogic_vector(0 to eff_ifar-10-1);
	spr_xucr3_hold1_dly              : out std_ulogic_vector(0 to 3);
	spr_xucr3_cm_hold_dly            : out std_ulogic_vector(0 to 3);
	spr_xucr3_stop_dly               : out std_ulogic_vector(0 to 3);
	spr_xucr3_hold0_dly              : out std_ulogic_vector(0 to 3);
	spr_xucr3_csi_dly                : out std_ulogic_vector(0 to 3);
	spr_xucr3_int_dly                : out std_ulogic_vector(0 to 3);
	spr_xucr3_asyncblk_dly           : out std_ulogic_vector(0 to 3);
	spr_xucr3_flush_dly              : out std_ulogic_vector(0 to 3);
	spr_xucr4_mmu_mchk               : out std_ulogic;
	spr_xucr4_mddmh                  : out std_ulogic;
	spr_xucr4_div_barr_thres         : out std_ulogic_vector(0 to 7);
	spr_xucr4_div_bar_dis            : out std_ulogic;
	spr_xucr4_lsu_bar_dis            : out std_ulogic;
	spr_xucr4_barr_dly               : out std_ulogic_vector(0 to 3);

   -- Power
   vdd                              : inout power_logic;
   gnd                              : inout power_logic
);

-- synopsys translate_off

-- synopsys translate_on
end xuq_cpl_spr_cspr;
architecture xuq_cpl_spr_cspr of xuq_cpl_spr_cspr is

constant ui                            : integer := 62-eff_ifar;
-- Types
subtype DO                            is std_ulogic_vector(65-regsize to 64);
type IFAR_ARR                         is array (0 to threads-1) of std_ulogic_vector(62-eff_ifar to 61);
type IACM_ARR                         is array (0 to threads-1) of std_ulogic_vector(0 to regsize/8-1);
-- SPR Registers
signal givpr_d        , givpr_q        : std_ulogic_vector(64-(eff_ifar-10) to 63);
signal iac1_d         , iac1_q         : std_ulogic_vector(64-(eff_ifar) to 63);
signal iac2_d         , iac2_q         : std_ulogic_vector(64-(eff_ifar) to 63);
signal iac3_d         , iac3_q         : std_ulogic_vector(64-(eff_ifar) to 63);
signal iac4_d         , iac4_q         : std_ulogic_vector(64-(eff_ifar) to 63);
signal ivpr_d         , ivpr_q         : std_ulogic_vector(64-(eff_ifar-10) to 63);
signal xucr3_d        , xucr3_q        : std_ulogic_vector(32 to 63);
signal xucr4_d        , xucr4_q        : std_ulogic_vector(48 to 63);
-- FUNC Scanchain
constant givpr_offset                  : natural := 0;
constant iac1_offset                   : natural := givpr_offset    + givpr_q'length*hvmode;
constant iac2_offset                   : natural := iac1_offset     + iac1_q'length;
constant iac3_offset                   : natural := iac2_offset     + iac2_q'length;
constant iac4_offset                   : natural := iac3_offset     + iac3_q'length*a2mode;
constant ivpr_offset                   : natural := iac4_offset     + iac4_q'length*a2mode;
constant last_reg_offset               : natural := ivpr_offset     + ivpr_q'length;
-- BCFG Scanchain
constant last_reg_offset_bcfg          : natural := 1;
-- CCFG Scanchain
constant last_reg_offset_ccfg          : natural := 1;
-- DCFG Scanchain
constant xucr3_offset_dcfg             : natural := 0;
constant xucr4_offset_dcfg             : natural := xucr3_offset_dcfg + xucr3_q'length;
constant last_reg_offset_dcfg          : natural := xucr4_offset_dcfg + xucr4_q'length;
-- Latches
signal ex2_is_mfspr_q                  : std_ulogic;                                         -- ex1_is_mfspr       exx_act(1)
signal ex2_is_mtspr_q                  : std_ulogic;                                         -- ex1_is_mtspr       exx_act(1)
signal ex2_instr_q                     : std_ulogic_vector(11 to 20);                        -- ex1_instr                  exx_act(1)
signal ex3_is_mtspr_q                  : std_ulogic;                                         -- ex2_is_mtspr_q             exx_act(2)
signal ex3_instr_q                     : std_ulogic_vector(11 to 20);                        -- ex2_instr_q                exx_act(2)
signal ex3_spr_rt_q,    ex3_spr_rt_d   : std_ulogic_vector(64-regsize to 63);                --                            exx_act(2)
signal ex3_iac1_cmpr_q, ex3_iac1_cmpr_d: std_ulogic_vector(0 to threads-1);                  -- input=>ex3_iac1_cmpr_d   , act=>tiup     , scan=>Y, sleep=>N, ring=>func, needs_sreset=>0
signal ex3_iac2_cmpr_q, ex3_iac2_cmpr_d: std_ulogic_vector(0 to threads-1);                  -- input=>ex3_iac2_cmpr_d   , act=>tiup     , scan=>Y, sleep=>N, ring=>func, needs_sreset=>0
signal ex3_iac3_cmpr_q, ex3_iac3_cmpr_d: std_ulogic_vector(0 to threads-1);                  -- input=>ex3_iac3_cmpr_d   , act=>tiup     , scan=>Y, sleep=>N, ring=>func, needs_sreset=>0
signal ex3_iac4_cmpr_q, ex3_iac4_cmpr_d: std_ulogic_vector(0 to threads-1);                  -- input=>ex3_iac4_cmpr_d   , act=>tiup     , scan=>Y, sleep=>N, ring=>func, needs_sreset=>0
signal ex4_is_mtspr_q                  : std_ulogic;                                         -- ex3_is_mtspr_q             exx_act(3)
signal ex4_instr_q                     : std_ulogic_vector(11 to 20);                        -- ex3_instr_q                exx_act(3)
signal ex5_is_mtspr_q                  : std_ulogic;                                         -- ex4_is_mtspr_q             exx_act(4)
signal ex5_instr_q                     : std_ulogic_vector(11 to 20);                        -- ex4_instr_q                exx_act(4)
signal dbcr1_iac12m_2_q, dbcr1_iac12m_2_d  : IACM_ARR;                                       -- input=>dbcr1_iac12m_2_d    , act=>spr_bit_act  , scan=>N, sleep=>N, ring=>func, needs_sreset=>1
signal dbcr1_iac34m_2_q, dbcr1_iac34m_2_d  : IACM_ARR;                                       -- input=>dbcr1_iac34m_2_d    , act=>spr_bit_act  , scan=>N, sleep=>N, ring=>func, needs_sreset=>1
--signal msrovride_enab_q                : std_ulogic;                                         -- pc_xu_msrovride_enab
--signal msrovride_gs_q                  : std_ulogic;                                         -- pc_xu_msrovride_gs
--signal ram_thread_q                    : std_ulogic_vector(0 to 1);                          -- pc_xu_ram_thread
signal iac1_en_q                       : std_ulogic_vector(0 to threads-1);                  -- input=>spr_cpl_iac1_en
signal iac2_en_q                       : std_ulogic_vector(0 to threads-1);                  -- input=>spr_cpl_iac2_en
signal iac3_en_q                       : std_ulogic_vector(0 to threads-1);                  -- input=>spr_cpl_iac3_en
signal iac4_en_q                       : std_ulogic_vector(0 to threads-1);                  -- input=>spr_cpl_iac4_en
signal dbcr1_iac12m_q                  : std_ulogic_vector(0 to threads-1);                  -- input=>spr_dbcr1_iac12m
signal dbcr1_iac34m_q                  : std_ulogic_vector(0 to threads-1);                  -- input=>spr_dbcr1_iac34m
-- Scanchains
constant ex2_is_mfspr_offset           : integer := last_reg_offset;
constant ex2_is_mtspr_offset           : integer := ex2_is_mfspr_offset            + 1;
constant ex2_instr_offset              : integer := ex2_is_mtspr_offset            + 1;
constant ex3_is_mtspr_offset           : integer := ex2_instr_offset               + ex2_instr_q'length;
constant ex3_instr_offset              : integer := ex3_is_mtspr_offset            + 1;
constant ex3_spr_rt_offset             : integer := ex3_instr_offset               + ex3_instr_q'length;
constant ex3_iac1_cmpr_offset          : integer := ex3_spr_rt_offset              + ex3_spr_rt_q'length;
constant ex3_iac2_cmpr_offset          : integer := ex3_iac1_cmpr_offset           + ex3_iac1_cmpr_q'length;
constant ex3_iac3_cmpr_offset          : integer := ex3_iac2_cmpr_offset           + ex3_iac2_cmpr_q'length;
constant ex3_iac4_cmpr_offset          : integer := ex3_iac3_cmpr_offset           + ex3_iac3_cmpr_q'length;
constant ex4_is_mtspr_offset           : integer := ex3_iac4_cmpr_offset           + ex3_iac4_cmpr_q'length;
constant ex4_instr_offset              : integer := ex4_is_mtspr_offset            + 1;
constant ex5_is_mtspr_offset           : integer := ex4_instr_offset               + ex4_instr_q'length;
constant ex5_instr_offset              : integer := ex5_is_mtspr_offset            + 1;
constant iac1_en_offset                : integer := ex5_instr_offset               + ex5_instr_q'length;
constant iac2_en_offset                : integer := iac1_en_offset                 + iac1_en_q'length;
constant iac3_en_offset                : integer := iac2_en_offset                 + iac2_en_q'length;
constant iac4_en_offset                : integer := iac3_en_offset                 + iac3_en_q'length;
constant dbcr1_iac12m_offset           : integer := iac4_en_offset                 + iac4_en_q'length;
constant dbcr1_iac34m_offset           : integer := dbcr1_iac12m_offset            + dbcr1_iac12m_q'length;
constant scan_right                    : integer := dbcr1_iac34m_offset            + dbcr1_iac34m_q'length;
signal siv                             : std_ulogic_vector(0 to scan_right-1);
signal sov                             : std_ulogic_vector(0 to scan_right-1);
constant scan_right_dcfg               : integer := last_reg_offset_dcfg;
signal siv_dcfg                        : std_ulogic_vector(0 to scan_right_dcfg-1);
signal sov_dcfg                        : std_ulogic_vector(0 to scan_right_dcfg-1);
-- Signals
signal tiup                            : std_ulogic;
signal tidn                            : std_ulogic_vector(00 to 63);
signal ex2_iac1_cmprh                  : std_ulogic_vector(0 to threads-1);
signal ex2_iac2_cmprh                  : std_ulogic_vector(0 to threads-1);
signal ex2_iac3_cmprh                  : std_ulogic_vector(0 to threads-1);
signal ex2_iac4_cmprh                  : std_ulogic_vector(0 to threads-1);
signal ex2_iac1_cmprl                  : std_ulogic_vector(0 to threads-1);
signal ex2_iac2_cmprl                  : std_ulogic_vector(0 to threads-1);
signal ex2_iac3_cmprl                  : std_ulogic_vector(0 to threads-1);
signal ex2_iac4_cmprl                  : std_ulogic_vector(0 to threads-1);
signal ex2_iac1_cmpr                   : std_ulogic_vector(0 to threads-1);
signal ex2_iac2_cmpr                   : std_ulogic_vector(0 to threads-1);
signal ex2_iac3_cmpr                   : std_ulogic_vector(0 to threads-1);
signal ex2_iac4_cmpr                   : std_ulogic_vector(0 to threads-1);
signal ex2_iac1_cmpr_sel               : std_ulogic_vector(0 to threads-1);
signal ex2_iac2_cmpr_sel               : std_ulogic_vector(0 to threads-1);
signal ex2_iac3_cmpr_sel               : std_ulogic_vector(0 to threads-1);
signal ex2_iac4_cmpr_sel               : std_ulogic_vector(0 to threads-1);
signal ex2_instr                       : std_ulogic_vector(11 to 20);
signal ex5_is_mtspr                    : std_ulogic;
signal ex5_instr                       : std_ulogic_vector(11 to 20);
signal ex2_cspr_rt,ex2_tspr_rt         : std_ulogic_vector(64-regsize to 63);
signal ex5_val                         : std_ulogic;
-- Data

signal ex5_givpr_di                    : std_ulogic_vector(givpr_q'range);
signal ex5_iac1_di                     : std_ulogic_vector(iac1_q'range);
signal ex5_iac2_di                     : std_ulogic_vector(iac2_q'range);
signal ex5_iac3_di                     : std_ulogic_vector(iac3_q'range);
signal ex5_iac4_di                     : std_ulogic_vector(iac4_q'range);
signal ex5_ivpr_di                     : std_ulogic_vector(ivpr_q'range);
signal ex5_xucr3_di                    : std_ulogic_vector(xucr3_q'range);
signal ex5_xucr4_di                    : std_ulogic_vector(xucr4_q'range);
signal
	ex2_givpr_rdec , ex2_iac1_rdec  , ex2_iac2_rdec  , ex2_iac3_rdec  
 , ex2_iac4_rdec  , ex2_ivpr_rdec  , ex2_xucr3_rdec , ex2_xucr4_rdec 
													: std_ulogic;
signal
	ex2_givpr_re   , ex2_iac1_re    , ex2_iac2_re    , ex2_iac3_re    
 , ex2_iac4_re    , ex2_ivpr_re    , ex2_xucr3_re   , ex2_xucr4_re   
													: std_ulogic;
signal
	ex5_givpr_wdec , ex5_iac1_wdec  , ex5_iac2_wdec  , ex5_iac3_wdec  
 , ex5_iac4_wdec  , ex5_ivpr_wdec  , ex5_xucr3_wdec , ex5_xucr4_wdec 
													: std_ulogic;
signal
	ex5_givpr_we   , ex5_iac1_we    , ex5_iac2_we    , ex5_iac3_we    
 , ex5_iac4_we    , ex5_ivpr_we    , ex5_xucr3_we   , ex5_xucr4_we   
													: std_ulogic;
signal
	givpr_act      , iac1_act       , iac2_act       , iac3_act       
 , iac4_act       , ivpr_act       , xucr3_act      , xucr4_act      
													: std_ulogic;
signal
	givpr_do       , iac1_do        , iac2_do        , iac3_do        
 , iac4_do        , ivpr_do        , xucr3_do       , xucr4_do       
													: std_ulogic_vector(0 to 64);

begin


tiup           <= '1';
tidn           <= (others=>'0');

ex2_instr      <= ex2_instr_q;
ex5_is_mtspr   <= ex5_is_mtspr_q;
ex5_instr      <= ex5_instr_q;
ex5_val        <= or_reduce(ex5_valid);

ex2_mtiar      <= ex2_is_mtspr_q and (ex2_instr_q(11 to 20) = "1001011011");   --  882

cspr_tspr_ex5_is_mtspr  <= ex5_is_mtspr_q;
cspr_tspr_ex5_instr     <= ex5_instr_q;
cspr_tspr_ex2_instr     <= ex2_instr_q;


-- SPR Input Control
-- IAC1
iac1_act       <= ex5_iac1_we;
iac1_d         <= ex5_iac1_di;

-- IAC2
iac2_act       <= ex5_iac2_we;
iac2_d         <= ex5_iac2_di;

-- IAC3
iac3_act       <= ex5_iac3_we;
iac3_d         <= ex5_iac3_di;

-- IAC4
iac4_act       <= ex5_iac4_we;
iac4_d         <= ex5_iac4_di;

-- IVPR
ivpr_act       <= ex5_ivpr_we;
ivpr_d         <= ex5_ivpr_di;

-- GIVR
givpr_act      <= ex5_givpr_we;
givpr_d        <= ex5_givpr_di;

-- XUCR3
xucr3_act      <= ex5_xucr3_we;
xucr3_d        <= ex5_xucr3_di;

-- XUCR4
xucr4_act      <= ex5_xucr4_we;
xucr4_d        <= ex5_xucr4_di;



-- IAC Compares
ex3_iac1_cmpr        <= ex3_iac1_cmpr_q;
ex3_iac2_cmpr        <= ex3_iac2_cmpr_q;
ex3_iac3_cmpr        <= ex3_iac3_cmpr_q;
ex3_iac4_cmpr        <= ex3_iac4_cmpr_q;

ifar_cmp : for t in 0 to threads-1 generate
signal ex2_ifar_int                    : std_ulogic_vector(62-eff_ifar to 61);
signal ex2_iac2_mask                   : std_ulogic_vector(62-eff_ifar to 61);
signal ex2_iac4_mask                   : std_ulogic_vector(62-eff_ifar to 61);
begin
   
   ex2_ifar_int            <= ex2_ifar(eff_ifar*t to eff_ifar*(t+1)-1);

   ex2_iac2_mask           <=  iac2_q or not fanout(dbcr1_iac12m_2_q(t),eff_ifar);
   ex2_iac4_mask           <=  iac4_q or not fanout(dbcr1_iac34m_2_q(t),eff_ifar);
   
   xuq_spr_iac_cmprh_gen0 : if eff_ifar > 32 generate -- ui=62-eff_ifar
   ex2_iac1_cmprh(t)       <= and_reduce((ex2_ifar_int(ui to 31) xnor iac1_q(ui+2 to 33)) or not ex2_iac2_mask(ui to 31));   
   ex2_iac2_cmprh(t)       <= and_reduce((ex2_ifar_int(ui to 31) xnor iac2_q(ui+2 to 33))                               );   
   ex2_iac3_cmprh(t)       <= and_reduce((ex2_ifar_int(ui to 31) xnor iac3_q(ui+2 to 33)) or not ex2_iac4_mask(ui to 31));   
   ex2_iac4_cmprh(t)       <= and_reduce((ex2_ifar_int(ui to 31) xnor iac4_q(ui+2 to 33))                               );   

   ex2_iac1_cmprl(t)       <= and_reduce((ex2_ifar_int(32 to 61) xnor iac1_q(32+2 to 63)) or not ex2_iac2_mask(32 to 61));   
   ex2_iac2_cmprl(t)       <= and_reduce((ex2_ifar_int(32 to 61) xnor iac2_q(32+2 to 63))                               );   
   ex2_iac3_cmprl(t)       <= and_reduce((ex2_ifar_int(32 to 61) xnor iac3_q(32+2 to 63)) or not ex2_iac4_mask(32 to 61));   
   ex2_iac4_cmprl(t)       <= and_reduce((ex2_ifar_int(32 to 61) xnor iac4_q(32+2 to 63))                               );

   ex2_iac1_cmpr(t)        <= ex2_iac1_cmprl(t) and (ex2_iac1_cmprh(t) or not spr_msr_cm(t));
   ex2_iac2_cmpr(t)        <= ex2_iac2_cmprl(t) and (ex2_iac2_cmprh(t) or not spr_msr_cm(t));
   ex2_iac3_cmpr(t)        <= ex2_iac3_cmprl(t) and (ex2_iac3_cmprh(t) or not spr_msr_cm(t));
   ex2_iac4_cmpr(t)        <= ex2_iac4_cmprl(t) and (ex2_iac4_cmprh(t) or not spr_msr_cm(t));
   end generate;

   xuq_spr_iac_cmprh_gen1 : if eff_ifar <= 32 generate -- ui=62-eff_ifar
   ex2_iac1_cmprh(t)       <= '1';   
   ex2_iac2_cmprh(t)       <= '1';   
   ex2_iac3_cmprh(t)       <= '1';   
   ex2_iac4_cmprh(t)       <= '1';   

   ex2_iac1_cmprl(t)       <= and_reduce((ex2_ifar(ui to 61) xnor iac1_q(ui+2 to 63)) or not ex2_iac2_mask(ui to 61));   
   ex2_iac2_cmprl(t)       <= and_reduce((ex2_ifar(ui to 61) xnor iac2_q(ui+2 to 63))                               );   
   ex2_iac3_cmprl(t)       <= and_reduce((ex2_ifar(ui to 61) xnor iac3_q(ui+2 to 63)) or not ex2_iac4_mask(ui to 61));   
   ex2_iac4_cmprl(t)       <= and_reduce((ex2_ifar(ui to 61) xnor iac4_q(ui+2 to 63))                               );

   ex2_iac1_cmpr(t)        <= ex2_iac1_cmprl(t);
   ex2_iac2_cmpr(t)        <= ex2_iac2_cmprl(t);
   ex2_iac3_cmpr(t)        <= ex2_iac3_cmprl(t);
   ex2_iac4_cmpr(t)        <= ex2_iac4_cmprl(t);
   end generate;

   ex2_iac1_cmpr_sel(t)    <= ex2_iac1_cmpr(t);
   ex2_iac2_cmpr_sel(t)    <= ex2_iac2_cmpr(t) when dbcr1_iac12m_2_q(t)(0)='0' else ex2_iac1_cmpr(t);
   ex2_iac3_cmpr_sel(t)    <= ex2_iac3_cmpr(t);
   ex2_iac4_cmpr_sel(t)    <= ex2_iac4_cmpr(t) when dbcr1_iac34m_2_q(t)(0)='0' else ex2_iac3_cmpr(t);

   ex3_iac1_cmpr_d(t)      <= ex2_iac1_cmpr_sel(t) and iac1_en_q(t);
   ex3_iac2_cmpr_d(t)      <= ex2_iac2_cmpr_sel(t) and iac2_en_q(t);
   ex3_iac3_cmpr_d(t)      <= ex2_iac3_cmpr_sel(t) and iac3_en_q(t);
   ex3_iac4_cmpr_d(t)      <= ex2_iac4_cmpr_sel(t) and iac4_en_q(t);
end generate;

-- MSR Override
               

readmux_00 : if a2mode = 0 and hvmode = 0 generate
ex2_cspr_rt <=
	(iac1_do(DO'range)        and (DO'range => ex2_iac1_re    )) or
	(iac2_do(DO'range)        and (DO'range => ex2_iac2_re    )) or
	(ivpr_do(DO'range)        and (DO'range => ex2_ivpr_re    )) or
	(xucr3_do(DO'range)       and (DO'range => ex2_xucr3_re   )) or
	(xucr4_do(DO'range)       and (DO'range => ex2_xucr4_re   ));
end generate;
readmux_01 : if a2mode = 0 and hvmode = 1 generate
ex2_cspr_rt <=
	(givpr_do(DO'range)       and (DO'range => ex2_givpr_re   )) or
	(iac1_do(DO'range)        and (DO'range => ex2_iac1_re    )) or
	(iac2_do(DO'range)        and (DO'range => ex2_iac2_re    )) or
	(ivpr_do(DO'range)        and (DO'range => ex2_ivpr_re    )) or
	(xucr3_do(DO'range)       and (DO'range => ex2_xucr3_re   )) or
	(xucr4_do(DO'range)       and (DO'range => ex2_xucr4_re   ));
end generate;
readmux_10 : if a2mode = 1 and hvmode = 0 generate
ex2_cspr_rt <=
	(iac1_do(DO'range)        and (DO'range => ex2_iac1_re    )) or
	(iac2_do(DO'range)        and (DO'range => ex2_iac2_re    )) or
	(iac3_do(DO'range)        and (DO'range => ex2_iac3_re    )) or
	(iac4_do(DO'range)        and (DO'range => ex2_iac4_re    )) or
	(ivpr_do(DO'range)        and (DO'range => ex2_ivpr_re    )) or
	(xucr3_do(DO'range)       and (DO'range => ex2_xucr3_re   )) or
	(xucr4_do(DO'range)       and (DO'range => ex2_xucr4_re   ));
end generate;
readmux_11 : if a2mode = 1 and hvmode = 1 generate
ex2_cspr_rt <=
	(givpr_do(DO'range)       and (DO'range => ex2_givpr_re   )) or
	(iac1_do(DO'range)        and (DO'range => ex2_iac1_re    )) or
	(iac2_do(DO'range)        and (DO'range => ex2_iac2_re    )) or
	(iac3_do(DO'range)        and (DO'range => ex2_iac3_re    )) or
	(iac4_do(DO'range)        and (DO'range => ex2_iac4_re    )) or
	(ivpr_do(DO'range)        and (DO'range => ex2_ivpr_re    )) or
	(xucr3_do(DO'range)       and (DO'range => ex2_xucr3_re   )) or
	(xucr4_do(DO'range)       and (DO'range => ex2_xucr4_re   ));
end generate;

-- Read Muxing
ex2_tspr_rt                <= mux_t(tspr_cspr_ex2_tspr_rt,ex2_tid);
ex3_spr_rt_d               <= gate((ex2_tspr_rt or ex2_cspr_rt),ex2_is_mfspr_q);
cpl_byp_ex3_spr_rt         <= ex3_spr_rt_q;


ex2_givpr_rdec    <= (ex2_instr(11 to 20) = "1111101101");   --  447
ex2_iac1_rdec     <= (ex2_instr(11 to 20) = "1100001001");   --  312
ex2_iac2_rdec     <= (ex2_instr(11 to 20) = "1100101001");   --  313
ex2_iac3_rdec     <= (ex2_instr(11 to 20) = "1101001001");   --  314
ex2_iac4_rdec     <= (ex2_instr(11 to 20) = "1101101001");   --  315
ex2_ivpr_rdec     <= (ex2_instr(11 to 20) = "1111100001");   --   63
ex2_xucr3_rdec    <= (ex2_instr(11 to 20) = "1010011010");   --  852
ex2_xucr4_rdec    <= (ex2_instr(11 to 20) = "1010111010");   --  853
ex2_givpr_re      <=  ex2_givpr_rdec;
ex2_iac1_re       <=  ex2_iac1_rdec;
ex2_iac2_re       <=  ex2_iac2_rdec;
ex2_iac3_re       <=  ex2_iac3_rdec;
ex2_iac4_re       <=  ex2_iac4_rdec;
ex2_ivpr_re       <=  ex2_ivpr_rdec;
ex2_xucr3_re      <=  ex2_xucr3_rdec;
ex2_xucr4_re      <=  ex2_xucr4_rdec;

ex5_givpr_wdec    <= (ex5_instr(11 to 20) = "1111101101");   --  447
ex5_iac1_wdec     <= (ex5_instr(11 to 20) = "1100001001");   --  312
ex5_iac2_wdec     <= (ex5_instr(11 to 20) = "1100101001");   --  313
ex5_iac3_wdec     <= (ex5_instr(11 to 20) = "1101001001");   --  314
ex5_iac4_wdec     <= (ex5_instr(11 to 20) = "1101101001");   --  315
ex5_ivpr_wdec     <= (ex5_instr(11 to 20) = "1111100001");   --   63
ex5_xucr3_wdec    <= (ex5_instr(11 to 20) = "1010011010");   --  852
ex5_xucr4_wdec    <= (ex5_instr(11 to 20) = "1010111010");   --  853
ex5_givpr_we      <= ex5_val and ex5_is_mtspr and  ex5_givpr_wdec;
ex5_iac1_we       <= ex5_val and ex5_is_mtspr and  ex5_iac1_wdec;
ex5_iac2_we       <= ex5_val and ex5_is_mtspr and  ex5_iac2_wdec;
ex5_iac3_we       <= ex5_val and ex5_is_mtspr and  ex5_iac3_wdec;
ex5_iac4_we       <= ex5_val and ex5_is_mtspr and  ex5_iac4_wdec;
ex5_ivpr_we       <= ex5_val and ex5_is_mtspr and  ex5_ivpr_wdec;
ex5_xucr3_we      <= ex5_val and ex5_is_mtspr and  ex5_xucr3_wdec;
ex5_xucr4_we      <= ex5_val and ex5_is_mtspr and  ex5_xucr4_wdec;

spr_givpr                  <= givpr_q(64-(eff_ifar-10) to 63);
spr_ivpr                   <= ivpr_q(64-(eff_ifar-10) to 63);
spr_xucr3_hold1_dly        <= xucr3_q(32 to 35);
spr_xucr3_cm_hold_dly      <= xucr3_q(36 to 39);
spr_xucr3_stop_dly         <= xucr3_q(40 to 43);
spr_xucr3_hold0_dly        <= xucr3_q(44 to 47);
spr_xucr3_csi_dly          <= xucr3_q(48 to 51);
spr_xucr3_int_dly          <= xucr3_q(52 to 55);
spr_xucr3_asyncblk_dly     <= xucr3_q(56 to 59);
spr_xucr3_flush_dly        <= xucr3_q(60 to 63);
spr_xucr4_mmu_mchk         <= xucr4_q(48);
spr_xucr4_mddmh            <= xucr4_q(49);
spr_xucr4_div_barr_thres   <= xucr4_q(50 to 57);
spr_xucr4_div_bar_dis      <= xucr4_q(58);
spr_xucr4_lsu_bar_dis      <= xucr4_q(59);
spr_xucr4_barr_dly         <= xucr4_q(60 to 63);

-- GIVPR
ex5_givpr_di   <= ex5_spr_wd(52-(eff_ifar-10) to 51); --GIVPR
givpr_do       <= tidn(0 to 52-(eff_ifar-10))      &
						givpr_q(64-(eff_ifar-10) to 63)  & --GIVPR
						tidn(52 to 63)                   ; --///
-- IAC1
ex5_iac1_di    <= ex5_spr_wd(62-(eff_ifar) to 61)  ; --IAC1
iac1_do        <= tidn(0 to 62-(eff_ifar))         &
						iac1_q(64-(eff_ifar) to 63)      & --IAC1
						tidn(62 to 63)                   ; --///
-- IAC2
ex5_iac2_di    <= ex5_spr_wd(62-(eff_ifar) to 61)  ; --IAC2
iac2_do        <= tidn(0 to 62-(eff_ifar))         &
						iac2_q(64-(eff_ifar) to 63)      & --IAC2
						tidn(62 to 63)                   ; --///
-- IAC3
ex5_iac3_di    <= ex5_spr_wd(62-(eff_ifar) to 61)  ; --IAC3
iac3_do        <= tidn(0 to 62-(eff_ifar))         &
						iac3_q(64-(eff_ifar) to 63)      & --IAC3
						tidn(62 to 63)                   ; --///
-- IAC4
ex5_iac4_di    <= ex5_spr_wd(62-(eff_ifar) to 61)  ; --IAC4
iac4_do        <= tidn(0 to 62-(eff_ifar))         &
						iac4_q(64-(eff_ifar) to 63)      & --IAC4
						tidn(62 to 63)                   ; --///
-- IVPR
ex5_ivpr_di    <= ex5_spr_wd(52-(eff_ifar-10) to 51); --IVPR
ivpr_do        <= tidn(0 to 52-(eff_ifar-10))      &
						ivpr_q(64-(eff_ifar-10) to 63)   & --IVPR
						tidn(52 to 63)                   ; --///
-- XUCR3
ex5_xucr3_di   <= ex5_spr_wd(32 to 35)             & --HOLD1_DLY
						ex5_spr_wd(36 to 39)             & --CM_HOLD_DLY
						ex5_spr_wd(40 to 43)             & --STOP_DLY
						ex5_spr_wd(44 to 47)             & --HOLD0_DLY
						ex5_spr_wd(48 to 51)             & --CSI_DLY
						ex5_spr_wd(52 to 55)             & --INT_DLY
						ex5_spr_wd(56 to 59)             & --ASYNCBLK_DLY
						ex5_spr_wd(60 to 63)             ; --FLUSH_DLY
xucr3_do       <= tidn(0 to 0)                     &
						tidn(0 to 31)                    & --///
						xucr3_q(32 to 35)                & --HOLD1_DLY
						xucr3_q(36 to 39)                & --CM_HOLD_DLY
						xucr3_q(40 to 43)                & --STOP_DLY
						xucr3_q(44 to 47)                & --HOLD0_DLY
						xucr3_q(48 to 51)                & --CSI_DLY
						xucr3_q(52 to 55)                & --INT_DLY
						xucr3_q(56 to 59)                & --ASYNCBLK_DLY
						xucr3_q(60 to 63)                ; --FLUSH_DLY
-- XUCR4
ex5_xucr4_di   <= ex5_spr_wd(46 to 46)             & --MMU_MCHK
						ex5_spr_wd(47 to 47)             & --MDDMH
						ex5_spr_wd(48 to 55)             & --DIV_BARR_THRES
						ex5_spr_wd(58 to 58)             & --DIV_BAR_DIS
						ex5_spr_wd(59 to 59)             & --LSU_BAR_DIS
						ex5_spr_wd(60 to 63)             ; --BARR_DLY
xucr4_do       <= tidn(0 to 0)                     &
						tidn(0 to 31)                    & --///
						tidn(32 to 45)                   & --///
						xucr4_q(48 to 48)                & --MMU_MCHK
						xucr4_q(49 to 49)                & --MDDMH
						xucr4_q(50 to 57)                & --DIV_BARR_THRES
						tidn(56 to 57)                   & --///
						xucr4_q(58 to 58)                & --DIV_BAR_DIS
						xucr4_q(59 to 59)                & --LSU_BAR_DIS
						xucr4_q(60 to 63)                ; --BARR_DLY

-- Unused Signals
mark_unused(givpr_do(0 to 64-regsize));
mark_unused(iac1_do(0 to 64-regsize));
mark_unused(iac2_do(0 to 64-regsize));
mark_unused(iac3_do(0 to 64-regsize));
mark_unused(iac4_do(0 to 64-regsize));
mark_unused(ivpr_do(0 to 64-regsize));
mark_unused(xucr3_do(0 to 64-regsize));
mark_unused(xucr4_do(0 to 64-regsize));

givpr_latch_gen : if hvmode = 1 generate
givpr_latch : tri_ser_rlmreg_p
generic map(width   => givpr_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
   port map(nclk    => nclk, vd => vdd, gd => gnd,
            act     => givpr_act,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(givpr_offset to givpr_offset + givpr_q'length-1),
            scout   => sov(givpr_offset to givpr_offset + givpr_q'length-1),
            din     => givpr_d,
            dout    => givpr_q);
end generate;
givpr_latch_tie : if hvmode = 0 generate
	givpr_q         <= (others=>'0');
end generate;
iac1_latch : tri_ser_rlmreg_p
generic map(width   => iac1_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
   port map(nclk    => nclk, vd => vdd, gd => gnd,
            act     => iac1_act,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(iac1_offset to iac1_offset + iac1_q'length-1),
            scout   => sov(iac1_offset to iac1_offset + iac1_q'length-1),
            din     => iac1_d,
            dout    => iac1_q);
iac2_latch : tri_ser_rlmreg_p
generic map(width   => iac2_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
   port map(nclk    => nclk, vd => vdd, gd => gnd,
            act     => iac2_act,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(iac2_offset to iac2_offset + iac2_q'length-1),
            scout   => sov(iac2_offset to iac2_offset + iac2_q'length-1),
            din     => iac2_d,
            dout    => iac2_q);
iac3_latch_gen : if a2mode = 1 generate
iac3_latch : tri_ser_rlmreg_p
generic map(width   => iac3_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
   port map(nclk    => nclk, vd => vdd, gd => gnd,
            act     => iac3_act,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(iac3_offset to iac3_offset + iac3_q'length-1),
            scout   => sov(iac3_offset to iac3_offset + iac3_q'length-1),
            din     => iac3_d,
            dout    => iac3_q);
end generate;
iac3_latch_tie : if a2mode = 0 generate
	iac3_q          <= (others=>'0');
end generate;
iac4_latch_gen : if a2mode = 1 generate
iac4_latch : tri_ser_rlmreg_p
generic map(width   => iac4_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
   port map(nclk    => nclk, vd => vdd, gd => gnd,
            act     => iac4_act,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(iac4_offset to iac4_offset + iac4_q'length-1),
            scout   => sov(iac4_offset to iac4_offset + iac4_q'length-1),
            din     => iac4_d,
            dout    => iac4_q);
end generate;
iac4_latch_tie : if a2mode = 0 generate
	iac4_q          <= (others=>'0');
end generate;
ivpr_latch : tri_ser_rlmreg_p
generic map(width   => ivpr_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
   port map(nclk    => nclk, vd => vdd, gd => gnd,
            act     => ivpr_act,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ivpr_offset to ivpr_offset + ivpr_q'length-1),
            scout   => sov(ivpr_offset to ivpr_offset + ivpr_q'length-1),
            din     => ivpr_d,
            dout    => ivpr_q);
xucr3_latch : tri_ser_rlmreg_p
generic map(width   => xucr3_q'length, init => 37753921, expand_type => expand_type, needs_sreset => 1)
   port map(nclk    => nclk, vd => vdd, gd => gnd,
            act     => xucr3_act,
            forcee => dcfg_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b => mpw2_dc_b,
            thold_b => dcfg_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv_dcfg(xucr3_offset_dcfg to xucr3_offset_dcfg + xucr3_q'length-1),
            scout   => sov_dcfg(xucr3_offset_dcfg to xucr3_offset_dcfg + xucr3_q'length-1),
            din     => xucr3_d,
            dout    => xucr3_q);
xucr4_latch : tri_ser_rlmreg_p
generic map(width   => xucr4_q'length, init => 320, expand_type => expand_type, needs_sreset => 1)
   port map(nclk    => nclk, vd => vdd, gd => gnd,
            act     => xucr4_act,
            forcee => dcfg_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b => mpw2_dc_b,
            thold_b => dcfg_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv_dcfg(xucr4_offset_dcfg to xucr4_offset_dcfg + xucr4_q'length-1),
            scout   => sov_dcfg(xucr4_offset_dcfg to xucr4_offset_dcfg + xucr4_q'length-1),
            din     => xucr4_d,
            dout    => xucr4_q);


mark_unused(tidn(46 to 51));

-- Latch Instances
ex2_is_mfspr_latch : tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => exx_act(1),
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex2_is_mfspr_offset),
            scout   => sov(ex2_is_mfspr_offset),
            din     => ex1_is_mfspr,
            dout    => ex2_is_mfspr_q);
ex2_is_mtspr_latch : tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => exx_act(1),
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex2_is_mtspr_offset),
            scout   => sov(ex2_is_mtspr_offset),
            din     => ex1_is_mtspr,
            dout    => ex2_is_mtspr_q);
ex2_instr_latch : tri_rlmreg_p
  generic map (width => ex2_instr_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => exx_act(1),
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex2_instr_offset to ex2_instr_offset + ex2_instr_q'length-1),
            scout   => sov(ex2_instr_offset to ex2_instr_offset + ex2_instr_q'length-1),
            din     => ex1_instr,
            dout    => ex2_instr_q);
ex3_is_mtspr_latch : tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => exx_act(2),
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex3_is_mtspr_offset),
            scout   => sov(ex3_is_mtspr_offset),
            din     => ex2_is_mtspr_q,
            dout    => ex3_is_mtspr_q);
ex3_instr_latch : tri_rlmreg_p
  generic map (width => ex3_instr_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => exx_act(2),
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex3_instr_offset to ex3_instr_offset + ex3_instr_q'length-1),
            scout   => sov(ex3_instr_offset to ex3_instr_offset + ex3_instr_q'length-1),
            din     => ex2_instr_q,
            dout    => ex3_instr_q);
ex3_spr_rt_latch : tri_rlmreg_p
  generic map (width => ex3_spr_rt_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => exx_act(2),
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex3_spr_rt_offset to ex3_spr_rt_offset + ex3_spr_rt_q'length-1),
            scout   => sov(ex3_spr_rt_offset to ex3_spr_rt_offset + ex3_spr_rt_q'length-1),
            din     => ex3_spr_rt_d,
            dout    => ex3_spr_rt_q);
ex3_iac1_cmpr_latch : tri_rlmreg_p
  generic map (width => ex3_iac1_cmpr_q'length, init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex3_iac1_cmpr_offset to ex3_iac1_cmpr_offset + ex3_iac1_cmpr_q'length-1),
            scout   => sov(ex3_iac1_cmpr_offset to ex3_iac1_cmpr_offset + ex3_iac1_cmpr_q'length-1),
            din     => ex3_iac1_cmpr_d,
            dout    => ex3_iac1_cmpr_q);
ex3_iac2_cmpr_latch : tri_rlmreg_p
  generic map (width => ex3_iac2_cmpr_q'length, init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex3_iac2_cmpr_offset to ex3_iac2_cmpr_offset + ex3_iac2_cmpr_q'length-1),
            scout   => sov(ex3_iac2_cmpr_offset to ex3_iac2_cmpr_offset + ex3_iac2_cmpr_q'length-1),
            din     => ex3_iac2_cmpr_d,
            dout    => ex3_iac2_cmpr_q);
ex3_iac3_cmpr_latch : tri_rlmreg_p
  generic map (width => ex3_iac3_cmpr_q'length, init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex3_iac3_cmpr_offset to ex3_iac3_cmpr_offset + ex3_iac3_cmpr_q'length-1),
            scout   => sov(ex3_iac3_cmpr_offset to ex3_iac3_cmpr_offset + ex3_iac3_cmpr_q'length-1),
            din     => ex3_iac3_cmpr_d,
            dout    => ex3_iac3_cmpr_q);
ex3_iac4_cmpr_latch : tri_rlmreg_p
  generic map (width => ex3_iac4_cmpr_q'length, init => 0, expand_type => expand_type, needs_sreset => 0)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex3_iac4_cmpr_offset to ex3_iac4_cmpr_offset + ex3_iac4_cmpr_q'length-1),
            scout   => sov(ex3_iac4_cmpr_offset to ex3_iac4_cmpr_offset + ex3_iac4_cmpr_q'length-1),
            din     => ex3_iac4_cmpr_d,
            dout    => ex3_iac4_cmpr_q);
ex4_is_mtspr_latch : tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => exx_act(3),
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex4_is_mtspr_offset),
            scout   => sov(ex4_is_mtspr_offset),
            din     => ex3_is_mtspr_q,
            dout    => ex4_is_mtspr_q);
ex4_instr_latch : tri_rlmreg_p
  generic map (width => ex4_instr_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => exx_act(3),
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex4_instr_offset to ex4_instr_offset + ex4_instr_q'length-1),
            scout   => sov(ex4_instr_offset to ex4_instr_offset + ex4_instr_q'length-1),
            din     => ex3_instr_q,
            dout    => ex4_instr_q);
ex5_is_mtspr_latch : tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => exx_act(4),
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex5_is_mtspr_offset),
            scout   => sov(ex5_is_mtspr_offset),
            din     => ex4_is_mtspr_q,
            dout    => ex5_is_mtspr_q);
ex5_instr_latch : tri_rlmreg_p
  generic map (width => ex5_instr_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => exx_act(4),
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex5_instr_offset to ex5_instr_offset + ex5_instr_q'length-1),
            scout   => sov(ex5_instr_offset to ex5_instr_offset + ex5_instr_q'length-1),
            din     => ex4_instr_q,
            dout    => ex5_instr_q);

dbcr1_iacm_gen : for t in 0 to threads-1 generate
dbcr1_iac12m_2_latch : tri_regk
  generic map (width => dbcr1_iac12m_2_q(t)'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => spr_bit_act,
            forcee => func_nsl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_nsl_thold_0_b,
            din     => dbcr1_iac12m_2_d(t),
            dout    => dbcr1_iac12m_2_q(t));
dbcr1_iac34m_2_latch : tri_regk
  generic map (width => dbcr1_iac34m_2_q(t)'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => spr_bit_act,
            forcee => func_nsl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_nsl_thold_0_b,
            din     => dbcr1_iac34m_2_d(t),
            dout    => dbcr1_iac34m_2_q(t));
dbcr1_iac12m_2_d(t)     <= (others=>dbcr1_iac12m_q(t));
dbcr1_iac34m_2_d(t)     <= (others=>dbcr1_iac34m_q(t));
end generate;

iac1_en_latch : tri_rlmreg_p
  generic map (width => iac1_en_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => spr_bit_act,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(iac1_en_offset to iac1_en_offset + iac1_en_q'length-1),
            scout   => sov(iac1_en_offset to iac1_en_offset + iac1_en_q'length-1),
            din     => spr_cpl_iac1_en ,
            dout    => iac1_en_q);
iac2_en_latch : tri_rlmreg_p
  generic map (width => iac2_en_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => spr_bit_act,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(iac2_en_offset to iac2_en_offset + iac2_en_q'length-1),
            scout   => sov(iac2_en_offset to iac2_en_offset + iac2_en_q'length-1),
            din     => spr_cpl_iac2_en ,
            dout    => iac2_en_q);
iac3_en_latch : tri_rlmreg_p
  generic map (width => iac3_en_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => spr_bit_act,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(iac3_en_offset to iac3_en_offset + iac3_en_q'length-1),
            scout   => sov(iac3_en_offset to iac3_en_offset + iac3_en_q'length-1),
            din     => spr_cpl_iac3_en ,
            dout    => iac3_en_q);
iac4_en_latch : tri_rlmreg_p
  generic map (width => iac4_en_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => spr_bit_act,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(iac4_en_offset to iac4_en_offset + iac4_en_q'length-1),
            scout   => sov(iac4_en_offset to iac4_en_offset + iac4_en_q'length-1),
            din     => spr_cpl_iac4_en ,
            dout    => iac4_en_q);
dbcr1_iac12m_latch : tri_rlmreg_p
  generic map (width => dbcr1_iac12m_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => spr_bit_act,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(dbcr1_iac12m_offset to dbcr1_iac12m_offset + dbcr1_iac12m_q'length-1),
            scout   => sov(dbcr1_iac12m_offset to dbcr1_iac12m_offset + dbcr1_iac12m_q'length-1),
            din     => spr_dbcr1_iac12m,
            dout    => dbcr1_iac12m_q);
dbcr1_iac34m_latch : tri_rlmreg_p
  generic map (width => dbcr1_iac34m_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => spr_bit_act,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(dbcr1_iac34m_offset to dbcr1_iac34m_offset + dbcr1_iac34m_q'length-1),
            scout   => sov(dbcr1_iac34m_offset to dbcr1_iac34m_offset + dbcr1_iac34m_q'length-1),
            din     => spr_dbcr1_iac34m,
            dout    => dbcr1_iac34m_q);

siv(0 to scan_right-1)  <= sov(1 to scan_right-1) & scan_in;
scan_out                <= sov(0);


dcfg_l : if sov_dcfg'length > 1 generate
siv_dcfg(0 to scan_right_dcfg-1) <= sov_dcfg(1 to scan_right_dcfg-1) & dcfg_scan_in;
dcfg_scan_out                    <= sov_dcfg(0);
end generate;
dcfg_s : if sov_dcfg'length <= 1 generate
dcfg_scan_out                    <= dcfg_scan_in;
sov_dcfg                         <= (others=>'0');
siv_dcfg                         <= (others=>'0');
end generate;

end architecture xuq_cpl_spr_cspr;
