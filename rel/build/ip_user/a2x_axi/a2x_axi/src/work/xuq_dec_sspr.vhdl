-- © IBM Corp. 2020
-- This softcore is licensed under and subject to the terms of the CC-BY 4.0
-- license (https://creativecommons.org/licenses/by/4.0/legalcode). 
-- Additional rights, including the right to physically implement a softcore 
-- that is compliant with the required sections of the Power ISA 
-- Specification, will be available at no cost via the OpenPOWER Foundation. 
-- This README will be updated with additional information when OpenPOWER's 
-- license is available.

library ieee,ibm,support,work,tri;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use support.power_logic_pkg.all;
use ibm.std_ulogic_support.all;
use ibm.std_ulogic_function_support.all;
use tri.tri_latches_pkg.all;
use work.xuq_pkg.all;

entity xuq_dec_sspr is
generic(
   expand_type                      :     integer := 2;
   threads                          :     integer := 4;
   ctr_size                         :     integer := 5);
port(
   nclk                             : in  clk_logic;
   
   d_mode_dc                        : in  std_ulogic;
   delay_lclkr_dc                   : in  std_ulogic;
   mpw1_dc_b                        : in  std_ulogic;
   mpw2_dc_b                        : in  std_ulogic;

   func_sl_force : in  std_ulogic;
   func_sl_thold_0_b                : in  std_ulogic;
   sg_0                             : in  std_ulogic;
   scan_in                          : in  std_ulogic;
   scan_out                         : out std_ulogic;
   
   rf1_act                          : in  std_ulogic;
   rf1_val                          : in  std_ulogic_vector(0 to threads-1);
   rf1_instr                        : in  std_ulogic_vector(0 to 31);
   
   spr_dec_spr_xucr0_ssdly          : in  std_ulogic_vector(0 to ctr_size-1);
   
   slowspr_need_hole                : out std_ulogic;
   ex1_is_slowspr_rd                : out std_ulogic;
   ex1_is_slowspr_wr                : out std_ulogic;

   vdd                              : inout power_logic;
   gnd                              : inout power_logic
);

-- synopsys translate_off

-- synopsys translate_on
end xuq_dec_sspr;
architecture xuq_dec_sspr of xuq_dec_sspr is

subtype s2        is std_ulogic_vector(0 to 1);
type T_ctr  is array (0 to threads-1) of std_ulogic_vector(0 to ctr_size-1);
signal slowspr_ctr_q,         slowspr_ctr_d           : T_ctr;
signal spr_xucr0_ssdly_q                              : std_ulogic_vector(0 to ctr_size-1);     
signal ex1_is_slowspr_wr_q,   rf1_is_slowspr_wr       : std_ulogic;
signal ex1_is_slowspr_rd_q,   rf1_is_slowspr_rd       : std_ulogic;
signal slowspr_hole_q,        slowspr_hole_d          : std_ulogic;
constant slowspr_ctr_offset                           : integer := 0;
constant spr_xucr0_ssdly_offset                       : integer := slowspr_ctr_offset             + slowspr_ctr_q(0)'length*threads;
constant ex1_is_slowspr_wr_offset                     : integer := spr_xucr0_ssdly_offset         + spr_xucr0_ssdly_q'length;
constant ex1_is_slowspr_rd_offset                     : integer := ex1_is_slowspr_wr_offset       + 1;
constant slowspr_hole_offset                          : integer := ex1_is_slowspr_rd_offset       + 1;
constant scan_right                                   : integer := slowspr_hole_offset            + 1;
signal siv                                            : std_ulogic_vector(0 to scan_right-1);
signal sov                                            : std_ulogic_vector(0 to scan_right-1);
signal tiup                                           : std_ulogic;
signal rf1_opcode_is_31                               : std_ulogic;
signal rf1_is_mfspr,          rf1_is_mtspr            : std_ulogic;
signal rf1_slowspr_range                              : std_ulogic;
signal rf1_sspr_ctr_init,     rf1_sspr_ctr_act        : std_ulogic_vector(0 to threads-1);
signal slowspr_ctr_zero,      slowspr_ctr_one         : std_ulogic_vector(0 to threads-1);
signal slowspr_hole                                   : std_ulogic_vector(0 to threads-1);
signal slowspr_ctr_m1                                 : T_ctr;
signal
	rf1_dvc1_re    , rf1_dvc2_re    , rf1_eplc_re    , rf1_epsc_re    
 , rf1_eptcfg_re  , rf1_immr_re    , rf1_imr_re     , rf1_iucr0_re   
 , rf1_iucr1_re   , rf1_iucr2_re   , rf1_iudbg0_re  , rf1_iudbg1_re  
 , rf1_iudbg2_re  , rf1_iulfsr_re  , rf1_iullcr_re  , rf1_lper_re    
 , rf1_lperu_re   , rf1_lpidr_re   , rf1_lratcfg_re , rf1_lratps_re  
 , rf1_mas0_re    , rf1_mas0_mas1_re, rf1_mas1_re    , rf1_mas2_re    
 , rf1_mas2u_re   , rf1_mas3_re    , rf1_mas4_re    , rf1_mas5_re    
 , rf1_mas5_mas6_re, rf1_mas6_re    , rf1_mas7_re    , rf1_mas7_mas3_re
 , rf1_mas8_re    , rf1_mas8_mas1_re, rf1_mmucfg_re  , rf1_mmucr0_re  
 , rf1_mmucr1_re  , rf1_mmucr2_re  , rf1_mmucr3_re  , rf1_mmucsr0_re 
 , rf1_pid_re     , rf1_ppr32_re   , rf1_tlb0cfg_re , rf1_tlb0ps_re  
 , rf1_xucr2_re   , rf1_xudbg0_re  , rf1_xudbg1_re  , rf1_xudbg2_re  
													: std_ulogic;
signal
	rf1_dvc1_we    , rf1_dvc2_we    , rf1_eplc_we    , rf1_epsc_we    
 , rf1_immr_we    , rf1_imr_we     , rf1_iucr0_we   , rf1_iucr1_we   
 , rf1_iucr2_we   , rf1_iudbg0_we  , rf1_iulfsr_we  , rf1_iullcr_we  
 , rf1_lper_we    , rf1_lperu_we   , rf1_lpidr_we   , rf1_mas0_we    
 , rf1_mas0_mas1_we, rf1_mas1_we    , rf1_mas2_we    , rf1_mas2u_we   
 , rf1_mas3_we    , rf1_mas4_we    , rf1_mas5_we    , rf1_mas5_mas6_we
 , rf1_mas6_we    , rf1_mas7_we    , rf1_mas7_mas3_we, rf1_mas8_we    
 , rf1_mas8_mas1_we, rf1_mmucr0_we  , rf1_mmucr1_we  , rf1_mmucr2_we  
 , rf1_mmucr3_we  , rf1_mmucsr0_we , rf1_pid_we     , rf1_ppr32_we   
 , rf1_xucr2_we   , rf1_xudbg0_we  
													: std_ulogic;
signal
	rf1_dvc1_rdec  , rf1_dvc2_rdec  , rf1_eplc_rdec  , rf1_epsc_rdec  
 , rf1_eptcfg_rdec, rf1_immr_rdec  , rf1_imr_rdec   , rf1_iucr0_rdec 
 , rf1_iucr1_rdec , rf1_iucr2_rdec , rf1_iudbg0_rdec, rf1_iudbg1_rdec
 , rf1_iudbg2_rdec, rf1_iulfsr_rdec, rf1_iullcr_rdec, rf1_lper_rdec  
 , rf1_lperu_rdec , rf1_lpidr_rdec , rf1_lratcfg_rdec, rf1_lratps_rdec
 , rf1_mas0_rdec  , rf1_mas0_mas1_rdec, rf1_mas1_rdec  , rf1_mas2_rdec  
 , rf1_mas2u_rdec , rf1_mas3_rdec  , rf1_mas4_rdec  , rf1_mas5_rdec  
 , rf1_mas5_mas6_rdec, rf1_mas6_rdec  , rf1_mas7_rdec  , rf1_mas7_mas3_rdec
 , rf1_mas8_rdec  , rf1_mas8_mas1_rdec, rf1_mmucfg_rdec, rf1_mmucr0_rdec
 , rf1_mmucr1_rdec, rf1_mmucr2_rdec, rf1_mmucr3_rdec, rf1_mmucsr0_rdec
 , rf1_pid_rdec   , rf1_ppr32_rdec , rf1_tlb0cfg_rdec, rf1_tlb0ps_rdec
 , rf1_xucr2_rdec , rf1_xudbg0_rdec, rf1_xudbg1_rdec, rf1_xudbg2_rdec
													: std_ulogic;
signal
	rf1_dvc1_wdec  , rf1_dvc2_wdec  , rf1_eplc_wdec  , rf1_epsc_wdec  
 , rf1_immr_wdec  , rf1_imr_wdec   , rf1_iucr0_wdec , rf1_iucr1_wdec 
 , rf1_iucr2_wdec , rf1_iudbg0_wdec, rf1_iulfsr_wdec, rf1_iullcr_wdec
 , rf1_lper_wdec  , rf1_lperu_wdec , rf1_lpidr_wdec , rf1_mas0_wdec  
 , rf1_mas0_mas1_wdec, rf1_mas1_wdec  , rf1_mas2_wdec  , rf1_mas2u_wdec 
 , rf1_mas3_wdec  , rf1_mas4_wdec  , rf1_mas5_wdec  , rf1_mas5_mas6_wdec
 , rf1_mas6_wdec  , rf1_mas7_wdec  , rf1_mas7_mas3_wdec, rf1_mas8_wdec  
 , rf1_mas8_mas1_wdec, rf1_mmucr0_wdec, rf1_mmucr1_wdec, rf1_mmucr2_wdec
 , rf1_mmucr3_wdec, rf1_mmucsr0_wdec, rf1_pid_wdec   , rf1_ppr32_wdec 
 , rf1_xucr2_wdec , rf1_xudbg0_wdec
													: std_ulogic;

begin

tiup <= '1';

slowspr_hole_gen : for t in 0 to threads-1 generate

   rf1_sspr_ctr_act(t)     <= rf1_val(t) or not slowspr_ctr_zero(t);

   rf1_sspr_ctr_init(t)    <= rf1_val(t) and rf1_is_mfspr and rf1_is_slowspr_rd;
   
   slowspr_ctr_m1(t)       <= std_ulogic_vector(unsigned(slowspr_ctr_q(t)) - 1);

   with s2'(rf1_sspr_ctr_init(t) & slowspr_ctr_zero(t)) select
      slowspr_ctr_d(t)     <= slowspr_ctr_m1(t)       when "00",     
                              (others=>'0')           when "01",     
                              spr_xucr0_ssdly_q       when others;   

   slowspr_ctr_zero(t)     <= not or_reduce(slowspr_ctr_q(t));
   
   slowspr_ctr_one(t)      <= not or_reduce(slowspr_ctr_q(t)(0 to ctr_size-2)) and slowspr_ctr_q(t)(ctr_size-1);
   
   with (not or_reduce(spr_xucr0_ssdly_q)) select
      slowspr_hole(t)         <= rf1_sspr_ctr_init(t)       when '1',
                                 slowspr_ctr_one(t)         when others;

end generate;

slowspr_hole_d             <= or_reduce(slowspr_hole);
slowspr_need_hole          <= slowspr_hole_q;
ex1_is_slowspr_wr          <= ex1_is_slowspr_wr_q;
ex1_is_slowspr_rd          <= ex1_is_slowspr_rd_q;

rf1_opcode_is_31  <= rf1_instr(0 to 5) = "011111";
rf1_is_mfspr      <= '1' when rf1_opcode_is_31='1' and rf1_instr(21 to 30) = "0101010011" else '0'; 
rf1_is_mtspr      <= '1' when rf1_opcode_is_31='1' and rf1_instr(21 to 30) = "0111010011" else '0'; 
rf1_slowspr_range <=((rf1_instr(16 to 20) =      "11110") or   
                     (rf1_instr(16 to 20) =      "11100"))     
                                        and rf1_instr(11);
rf1_dvc1_rdec     <= (rf1_instr(11 to 20) = "1111001001");   
rf1_dvc2_rdec     <= (rf1_instr(11 to 20) = "1111101001");   
rf1_eplc_rdec     <= (rf1_instr(11 to 20) = "1001111101");   
rf1_epsc_rdec     <= (rf1_instr(11 to 20) = "1010011101");   
rf1_eptcfg_rdec   <= (rf1_instr(11 to 20) = "1111001010");   
rf1_immr_rdec     <= (rf1_instr(11 to 20) = "1000111011");   
rf1_imr_rdec      <= (rf1_instr(11 to 20) = "1000011011");   
rf1_iucr0_rdec    <= (rf1_instr(11 to 20) = "1001111111");   
rf1_iucr1_rdec    <= (rf1_instr(11 to 20) = "1001111011");   
rf1_iucr2_rdec    <= (rf1_instr(11 to 20) = "1010011011");   
rf1_iudbg0_rdec   <= (rf1_instr(11 to 20) = "1100011011");   
rf1_iudbg1_rdec   <= (rf1_instr(11 to 20) = "1100111011");   
rf1_iudbg2_rdec   <= (rf1_instr(11 to 20) = "1101011011");   
rf1_iulfsr_rdec   <= (rf1_instr(11 to 20) = "1101111011");   
rf1_iullcr_rdec   <= (rf1_instr(11 to 20) = "1110011011");   
rf1_lper_rdec     <= (rf1_instr(11 to 20) = "1100000001");   
rf1_lperu_rdec    <= (rf1_instr(11 to 20) = "1100100001");   
rf1_lpidr_rdec    <= (rf1_instr(11 to 20) = "1001001010");   
rf1_lratcfg_rdec  <= (rf1_instr(11 to 20) = "1011001010");   
rf1_lratps_rdec   <= (rf1_instr(11 to 20) = "1011101010");   
rf1_mas0_rdec     <= (rf1_instr(11 to 20) = "1000010011");   
rf1_mas0_mas1_rdec<= (rf1_instr(11 to 20) = "1010101011");   
rf1_mas1_rdec     <= (rf1_instr(11 to 20) = "1000110011");   
rf1_mas2_rdec     <= (rf1_instr(11 to 20) = "1001010011");   
rf1_mas2u_rdec    <= (rf1_instr(11 to 20) = "1011110011");   
rf1_mas3_rdec     <= (rf1_instr(11 to 20) = "1001110011");   
rf1_mas4_rdec     <= (rf1_instr(11 to 20) = "1010010011");   
rf1_mas5_rdec     <= (rf1_instr(11 to 20) = "1001101010");   
rf1_mas5_mas6_rdec<= (rf1_instr(11 to 20) = "1110001010");   
rf1_mas6_rdec     <= (rf1_instr(11 to 20) = "1011010011");   
rf1_mas7_rdec     <= (rf1_instr(11 to 20) = "1000011101");   
rf1_mas7_mas3_rdec<= (rf1_instr(11 to 20) = "1010001011");   
rf1_mas8_rdec     <= (rf1_instr(11 to 20) = "1010101010");   
rf1_mas8_mas1_rdec<= (rf1_instr(11 to 20) = "1110101010");   
rf1_mmucfg_rdec   <= (rf1_instr(11 to 20) = "1011111111");   
rf1_mmucr0_rdec   <= (rf1_instr(11 to 20) = "1110011111");   
rf1_mmucr1_rdec   <= (rf1_instr(11 to 20) = "1110111111");   
rf1_mmucr2_rdec   <= (rf1_instr(11 to 20) = "1111011111");   
rf1_mmucr3_rdec   <= (rf1_instr(11 to 20) = "1111111111");   
rf1_mmucsr0_rdec  <= (rf1_instr(11 to 20) = "1010011111");   
rf1_pid_rdec      <= (rf1_instr(11 to 20) = "1000000001");   
rf1_ppr32_rdec    <= (rf1_instr(11 to 20) = "0001011100");   
rf1_tlb0cfg_rdec  <= (rf1_instr(11 to 20) = "1000010101");   
rf1_tlb0ps_rdec   <= (rf1_instr(11 to 20) = "1100001010");   
rf1_xucr2_rdec    <= (rf1_instr(11 to 20) = "1100011111");   
rf1_xudbg0_rdec   <= (rf1_instr(11 to 20) = "1010111011");   
rf1_xudbg1_rdec   <= (rf1_instr(11 to 20) = "1011011011");   
rf1_xudbg2_rdec   <= (rf1_instr(11 to 20) = "1011111011");   
rf1_dvc1_re       <=  rf1_dvc1_rdec;
rf1_dvc2_re       <=  rf1_dvc2_rdec;
rf1_eplc_re       <=  rf1_eplc_rdec;
rf1_epsc_re       <=  rf1_epsc_rdec;
rf1_eptcfg_re     <=  rf1_eptcfg_rdec;
rf1_immr_re       <=  rf1_immr_rdec;
rf1_imr_re        <=  rf1_imr_rdec;
rf1_iucr0_re      <=  rf1_iucr0_rdec;
rf1_iucr1_re      <=  rf1_iucr1_rdec;
rf1_iucr2_re      <=  rf1_iucr2_rdec;
rf1_iudbg0_re     <=  rf1_iudbg0_rdec;
rf1_iudbg1_re     <=  rf1_iudbg1_rdec;
rf1_iudbg2_re     <=  rf1_iudbg2_rdec;
rf1_iulfsr_re     <=  rf1_iulfsr_rdec;
rf1_iullcr_re     <=  rf1_iullcr_rdec;
rf1_lper_re       <=  rf1_lper_rdec;
rf1_lperu_re      <=  rf1_lperu_rdec;
rf1_lpidr_re      <=  rf1_lpidr_rdec;
rf1_lratcfg_re    <=  rf1_lratcfg_rdec;
rf1_lratps_re     <=  rf1_lratps_rdec;
rf1_mas0_re       <=  rf1_mas0_rdec;
rf1_mas0_mas1_re  <=  rf1_mas0_mas1_rdec;
rf1_mas1_re       <=  rf1_mas1_rdec;
rf1_mas2_re       <=  rf1_mas2_rdec;
rf1_mas2u_re      <=  rf1_mas2u_rdec;
rf1_mas3_re       <=  rf1_mas3_rdec;
rf1_mas4_re       <=  rf1_mas4_rdec;
rf1_mas5_re       <=  rf1_mas5_rdec;
rf1_mas5_mas6_re  <=  rf1_mas5_mas6_rdec;
rf1_mas6_re       <=  rf1_mas6_rdec;
rf1_mas7_re       <=  rf1_mas7_rdec;
rf1_mas7_mas3_re  <=  rf1_mas7_mas3_rdec;
rf1_mas8_re       <=  rf1_mas8_rdec;
rf1_mas8_mas1_re  <=  rf1_mas8_mas1_rdec;
rf1_mmucfg_re     <=  rf1_mmucfg_rdec;
rf1_mmucr0_re     <=  rf1_mmucr0_rdec;
rf1_mmucr1_re     <=  rf1_mmucr1_rdec;
rf1_mmucr2_re     <=  rf1_mmucr2_rdec;
rf1_mmucr3_re     <=  rf1_mmucr3_rdec;
rf1_mmucsr0_re    <=  rf1_mmucsr0_rdec;
rf1_pid_re        <=  rf1_pid_rdec;
rf1_ppr32_re      <=  rf1_ppr32_rdec;
rf1_tlb0cfg_re    <=  rf1_tlb0cfg_rdec;
rf1_tlb0ps_re     <=  rf1_tlb0ps_rdec;
rf1_xucr2_re      <=  rf1_xucr2_rdec;
rf1_xudbg0_re     <=  rf1_xudbg0_rdec;
rf1_xudbg1_re     <=  rf1_xudbg1_rdec;
rf1_xudbg2_re     <=  rf1_xudbg2_rdec;
rf1_dvc1_wdec     <= rf1_dvc1_rdec;
rf1_dvc2_wdec     <= rf1_dvc2_rdec;
rf1_eplc_wdec     <= rf1_eplc_rdec;
rf1_epsc_wdec     <= rf1_epsc_rdec;
rf1_immr_wdec     <= rf1_immr_rdec;
rf1_imr_wdec      <= rf1_imr_rdec;
rf1_iucr0_wdec    <= rf1_iucr0_rdec;
rf1_iucr1_wdec    <= rf1_iucr1_rdec;
rf1_iucr2_wdec    <= rf1_iucr2_rdec;
rf1_iudbg0_wdec   <= rf1_iudbg0_rdec;
rf1_iulfsr_wdec   <= rf1_iulfsr_rdec;
rf1_iullcr_wdec   <= rf1_iullcr_rdec;
rf1_lper_wdec     <= rf1_lper_rdec;
rf1_lperu_wdec    <= rf1_lperu_rdec;
rf1_lpidr_wdec    <= rf1_lpidr_rdec;
rf1_mas0_wdec     <= rf1_mas0_rdec;
rf1_mas0_mas1_wdec<= rf1_mas0_mas1_rdec;
rf1_mas1_wdec     <= rf1_mas1_rdec;
rf1_mas2_wdec     <= rf1_mas2_rdec;
rf1_mas2u_wdec    <= rf1_mas2u_rdec;
rf1_mas3_wdec     <= rf1_mas3_rdec;
rf1_mas4_wdec     <= rf1_mas4_rdec;
rf1_mas5_wdec     <= rf1_mas5_rdec;
rf1_mas5_mas6_wdec<= rf1_mas5_mas6_rdec;
rf1_mas6_wdec     <= rf1_mas6_rdec;
rf1_mas7_wdec     <= rf1_mas7_rdec;
rf1_mas7_mas3_wdec<= rf1_mas7_mas3_rdec;
rf1_mas8_wdec     <= rf1_mas8_rdec;
rf1_mas8_mas1_wdec<= rf1_mas8_mas1_rdec;
rf1_mmucr0_wdec   <= rf1_mmucr0_rdec;
rf1_mmucr1_wdec   <= rf1_mmucr1_rdec;
rf1_mmucr2_wdec   <= rf1_mmucr2_rdec;
rf1_mmucr3_wdec   <= rf1_mmucr3_rdec;
rf1_mmucsr0_wdec  <= rf1_mmucsr0_rdec;
rf1_pid_wdec      <= rf1_pid_rdec;
rf1_ppr32_wdec    <= rf1_ppr32_rdec;
rf1_xucr2_wdec    <= rf1_xucr2_rdec;
rf1_xudbg0_wdec   <= rf1_xudbg0_rdec;
rf1_dvc1_we       <=  rf1_dvc1_wdec;
rf1_dvc2_we       <=  rf1_dvc2_wdec;
rf1_eplc_we       <=  rf1_eplc_wdec;
rf1_epsc_we       <=  rf1_epsc_wdec;
rf1_immr_we       <=  rf1_immr_wdec;
rf1_imr_we        <=  rf1_imr_wdec;
rf1_iucr0_we      <=  rf1_iucr0_wdec;
rf1_iucr1_we      <=  rf1_iucr1_wdec;
rf1_iucr2_we      <=  rf1_iucr2_wdec;
rf1_iudbg0_we     <=  rf1_iudbg0_wdec;
rf1_iulfsr_we     <=  rf1_iulfsr_wdec;
rf1_iullcr_we     <=  rf1_iullcr_wdec;
rf1_lper_we       <=  rf1_lper_wdec;
rf1_lperu_we      <=  rf1_lperu_wdec;
rf1_lpidr_we      <=  rf1_lpidr_wdec;
rf1_mas0_we       <=  rf1_mas0_wdec;
rf1_mas0_mas1_we  <=  rf1_mas0_mas1_wdec;
rf1_mas1_we       <=  rf1_mas1_wdec;
rf1_mas2_we       <=  rf1_mas2_wdec;
rf1_mas2u_we      <=  rf1_mas2u_wdec;
rf1_mas3_we       <=  rf1_mas3_wdec;
rf1_mas4_we       <=  rf1_mas4_wdec;
rf1_mas5_we       <=  rf1_mas5_wdec;
rf1_mas5_mas6_we  <=  rf1_mas5_mas6_wdec;
rf1_mas6_we       <=  rf1_mas6_wdec;
rf1_mas7_we       <=  rf1_mas7_wdec;
rf1_mas7_mas3_we  <=  rf1_mas7_mas3_wdec;
rf1_mas8_we       <=  rf1_mas8_wdec;
rf1_mas8_mas1_we  <=  rf1_mas8_mas1_wdec;
rf1_mmucr0_we     <=  rf1_mmucr0_wdec;
rf1_mmucr1_we     <=  rf1_mmucr1_wdec;
rf1_mmucr2_we     <=  rf1_mmucr2_wdec;
rf1_mmucr3_we     <=  rf1_mmucr3_wdec;
rf1_mmucsr0_we    <=  rf1_mmucsr0_wdec;
rf1_pid_we        <=  rf1_pid_wdec;
rf1_ppr32_we      <=  rf1_ppr32_wdec;
rf1_xucr2_we      <=  rf1_xucr2_wdec;
rf1_xudbg0_we     <=  rf1_xudbg0_wdec;

rf1_is_slowspr_wr <=(rf1_is_mtspr and (rf1_slowspr_range or
                              rf1_dvc1_we          or rf1_dvc2_we          or rf1_eplc_we          
                           or rf1_epsc_we          or rf1_immr_we          or rf1_imr_we           
                           or rf1_iucr0_we         or rf1_iucr1_we         or rf1_iucr2_we         
                           or rf1_iudbg0_we        or rf1_iulfsr_we        or rf1_iullcr_we        
                           or rf1_lper_we          or rf1_lperu_we         or rf1_lpidr_we         
                           or rf1_mas0_we          or rf1_mas0_mas1_we     or rf1_mas1_we          
                           or rf1_mas2_we          or rf1_mas2u_we         or rf1_mas3_we          
                           or rf1_mas4_we          or rf1_mas5_we          or rf1_mas5_mas6_we     
                           or rf1_mas6_we          or rf1_mas7_we          or rf1_mas7_mas3_we     
                           or rf1_mas8_we          or rf1_mas8_mas1_we     or rf1_mmucr0_we        
                           or rf1_mmucr1_we        or rf1_mmucr2_we        or rf1_mmucr3_we        
                           or rf1_mmucsr0_we       or rf1_pid_we           or rf1_ppr32_we         
                           or rf1_xucr2_we         or rf1_xudbg0_we        ));
rf1_is_slowspr_rd <= (rf1_is_mfspr and (rf1_slowspr_range or
                              rf1_dvc1_re          or rf1_dvc2_re          or rf1_eplc_re          
                           or rf1_epsc_re          or rf1_eptcfg_re        or rf1_immr_re          
                           or rf1_imr_re           or rf1_iucr0_re         or rf1_iucr1_re         
                           or rf1_iucr2_re         or rf1_iudbg0_re        or rf1_iudbg1_re        
                           or rf1_iudbg2_re        or rf1_iulfsr_re        or rf1_iullcr_re        
                           or rf1_lper_re          or rf1_lperu_re         or rf1_lpidr_re         
                           or rf1_lratcfg_re       or rf1_lratps_re        or rf1_mas0_re          
                           or rf1_mas0_mas1_re     or rf1_mas1_re          or rf1_mas2_re          
                           or rf1_mas2u_re         or rf1_mas3_re          or rf1_mas4_re          
                           or rf1_mas5_re          or rf1_mas5_mas6_re     or rf1_mas6_re          
                           or rf1_mas7_re          or rf1_mas7_mas3_re     or rf1_mas8_re          
                           or rf1_mas8_mas1_re     or rf1_mmucfg_re        or rf1_mmucr0_re        
                           or rf1_mmucr1_re        or rf1_mmucr2_re        or rf1_mmucr3_re        
                           or rf1_mmucsr0_re       or rf1_pid_re           or rf1_ppr32_re         
                           or rf1_tlb0cfg_re       or rf1_tlb0ps_re        or rf1_xucr2_re         
                           or rf1_xudbg0_re        or rf1_xudbg1_re        or rf1_xudbg2_re        ));

mark_unused(rf1_instr(6 to 10));
mark_unused(rf1_instr(31));

slowspr_ctr_gen : for t in 0 to threads-1 generate
slowspr_ctr_latch : tri_rlmreg_p
  generic map (width => slowspr_ctr_q(t)'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => rf1_sspr_ctr_act(t),
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(slowspr_ctr_offset+slowspr_ctr_q(t)'length*t to slowspr_ctr_offset+slowspr_ctr_q(t)'length*(t+1)-1),
            scout   => sov(slowspr_ctr_offset+slowspr_ctr_q(t)'length*t to slowspr_ctr_offset+slowspr_ctr_q(t)'length*(t+1)-1),
            din     => slowspr_ctr_d(t),
            dout    => slowspr_ctr_q(t));
end generate;
spr_xucr0_ssdly_latch : tri_rlmreg_p
  generic map (width => spr_xucr0_ssdly_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(spr_xucr0_ssdly_offset to spr_xucr0_ssdly_offset + spr_xucr0_ssdly_q'length-1),
            scout   => sov(spr_xucr0_ssdly_offset to spr_xucr0_ssdly_offset + spr_xucr0_ssdly_q'length-1),
            din     => spr_dec_spr_xucr0_ssdly,
            dout    => spr_xucr0_ssdly_q);
ex1_is_slowspr_wr_latch : tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => rf1_act,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex1_is_slowspr_wr_offset),
            scout   => sov(ex1_is_slowspr_wr_offset),
            din     => rf1_is_slowspr_wr,
            dout    => ex1_is_slowspr_wr_q);
ex1_is_slowspr_rd_latch : tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => rf1_act,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(ex1_is_slowspr_rd_offset),
            scout   => sov(ex1_is_slowspr_rd_offset),
            din     => rf1_is_slowspr_rd,
            dout    => ex1_is_slowspr_rd_q);
slowspr_hole_latch : tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
  port map (nclk    => nclk, vd => vdd, gd => gnd,
            act     => tiup,
            forcee => func_sl_force,
            d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
            mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
            thold_b => func_sl_thold_0_b,
            sg      => sg_0,
            scin    => siv(slowspr_hole_offset),
            scout   => sov(slowspr_hole_offset),
            din     => slowspr_hole_d,
            dout    => slowspr_hole_q);

siv(0 to siv'right)     <= sov(1 to siv'right)      & scan_in;
scan_out                <= sov(0);

end architecture xuq_dec_sspr;
