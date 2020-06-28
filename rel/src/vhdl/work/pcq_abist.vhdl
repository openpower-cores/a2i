-- © IBM Corp. 2020
-- This softcore is licensed under and subject to the terms of the CC-BY 4.0
-- license (https://creativecommons.org/licenses/by/4.0/legalcode). 
-- Additional rights, including the right to physically implement a softcore 
-- that is compliant with the required sections of the Power ISA 
-- Specification, will be available at no cost via the OpenPOWER Foundation. 
-- This README will be updated with additional information when OpenPOWER's 
-- license is available.

library ieee, ibm;
use ieee.std_logic_1164.all;
use ibm.std_ulogic_support.all;
library support;
USE support.power_logic_pkg.all;
library tri;
use tri.tri_latches_pkg.all;

entity pcq_abist is
generic(expand_type     : integer := 2 );    
Port   (vdd                             : INOUT power_logic;
        gnd                             : INOUT power_logic;
        nclk                            : In    clk_logic;
        scan_dis_dc_b                   : In    std_ulogic;
        lcb_clkoff_dc_b                 : In    std_ulogic;
        lcb_mpw1_dc_b                   : In    std_ulogic;
        lcb_mpw2_dc_b                   : In    std_ulogic;
        lcb_delay_lclkr_dc              : In    std_ulogic;
        lcb_delay_lclkr_np_dc           : In    std_ulogic;
        lcb_act_dis_dc                  : In    std_ulogic;
        lcb_d_mode_dc                   : In    std_ulogic;
        gptr_thold                      : In    std_ulogic;
        gptr_scan_in                    : In    std_ulogic;
        gptr_scan_out                   : Out   std_ulogic;
        abist_thold                     : In    std_ulogic;
        abist_sg                        : In    std_ulogic;
        abist_scan_in                   : In    std_ulogic;
        abist_scan_out                  : Out   std_ulogic;
        bo_enable                       : in    std_ulogic;
        bo_abist_eng_si                 : in    std_ulogic;
        abist_done_in_dc                : In    std_ulogic;
        abist_done_out_dc               : Out   std_ulogic;
        abist_mode_dc                   : In    std_ulogic;
        abist_start_test                : In    std_ulogic;
        lbist_mode_dc                   : In    std_ulogic;
        lbist_ac_mode_dc                : In    std_ulogic;
        pc_bx_abist_di_0                : Out   std_ulogic_vector(0 to 3);
        pc_bx_abist_ena_dc              : Out   std_ulogic;
        pc_bx_abist_g8t1p_renb_0        : Out   std_ulogic;
        pc_bx_abist_g8t_bw_0            : Out   std_ulogic;
        pc_bx_abist_g8t_bw_1            : Out   std_ulogic;
        pc_bx_abist_g8t_dcomp           : Out   std_ulogic_vector(0 to 3);
        pc_bx_abist_g8t_wenb            : Out   std_ulogic;
        pc_bx_abist_raddr_0             : Out   std_ulogic_vector(0 to 9);
        pc_bx_abist_raw_dc_b            : Out   std_ulogic;
        pc_bx_abist_waddr_0             : Out   std_ulogic_vector(0 to 9);
        pc_bx_abist_wl64_g8t_comp_ena   : Out   std_ulogic;
        pc_fu_abist_di_0                : Out   std_ulogic_vector(0 to 3);
        pc_fu_abist_di_1                : Out   std_ulogic_vector(0 to 3);
        pc_fu_abist_ena_dc              : Out   std_ulogic;
        pc_fu_abist_grf_renb_0          : Out   std_ulogic;
        pc_fu_abist_grf_renb_1          : Out   std_ulogic;
        pc_fu_abist_grf_wenb_0          : Out   std_ulogic;      
        pc_fu_abist_grf_wenb_1          : Out   std_ulogic;      
        pc_fu_abist_raddr_0             : Out   std_ulogic_vector(0 to 9);
        pc_fu_abist_raddr_1             : Out   std_ulogic_vector(0 to 9);
        pc_fu_abist_raw_dc_b            : Out   std_ulogic;
        pc_fu_abist_waddr_0             : Out   std_ulogic_vector(0 to 9);
        pc_fu_abist_waddr_1             : Out   std_ulogic_vector(0 to 9);
        pc_fu_abist_wl144_comp_ena      : Out   std_ulogic;
        pc_iu_abist_dcomp_g6t_2r        : Out   std_ulogic_vector(0 to 3);
        pc_iu_abist_di_0                : Out   std_ulogic_vector(0 to 3);
        pc_iu_abist_di_g6t_2r           : Out   std_ulogic_vector(0 to 3);
        pc_iu_abist_ena_dc              : Out   std_ulogic;
        pc_iu_abist_g6t_bw              : Out   std_ulogic_vector(0 to 1);
        pc_iu_abist_g6t_r_wb            : Out   std_ulogic;
        pc_iu_abist_g8t1p_renb_0        : Out   std_ulogic;
        pc_iu_abist_g8t_bw_0            : Out   std_ulogic;
        pc_iu_abist_g8t_bw_1            : Out   std_ulogic;
        pc_iu_abist_g8t_dcomp           : Out   std_ulogic_vector(0 to 3);
        pc_iu_abist_g8t_wenb            : Out   std_ulogic;
        pc_iu_abist_raddr_0             : Out   std_ulogic_vector(0 to 9);
        pc_iu_abist_raw_dc_b            : Out   std_ulogic;
        pc_iu_abist_waddr_0             : Out   std_ulogic_vector(0 to 9);
        pc_iu_abist_wl128_g8t_comp_ena  : Out   std_ulogic;
        pc_iu_abist_wl256_comp_ena      : Out   std_ulogic;
        pc_iu_abist_wl64_g8t_comp_ena   : Out   std_ulogic;
        pc_mm_abist_dcomp_g6t_2r        : Out   std_ulogic_vector(0 to 3);
        pc_mm_abist_di_0                : Out   std_ulogic_vector(0 to 3);
        pc_mm_abist_di_g6t_2r           : Out   std_ulogic_vector(0 to 3);
        pc_mm_abist_ena_dc              : Out   std_ulogic;
        pc_mm_abist_g6t_r_wb            : Out   std_ulogic;
        pc_mm_abist_g8t1p_renb_0        : Out   std_ulogic;
        pc_mm_abist_g8t_bw_0            : Out   std_ulogic;
        pc_mm_abist_g8t_bw_1            : Out   std_ulogic;
        pc_mm_abist_g8t_dcomp           : Out   std_ulogic_vector(0 to 3);
        pc_mm_abist_g8t_wenb            : Out   std_ulogic;
        pc_mm_abist_raddr_0             : Out   std_ulogic_vector(0 to 9);
        pc_mm_abist_raw_dc_b            : Out   std_ulogic;
        pc_mm_abist_waddr_0             : Out   std_ulogic_vector(0 to 9);
        pc_mm_abist_wl128_g8t_comp_ena  : Out   std_ulogic;
        pc_xu_abist_dcomp_g6t_2r        : Out   std_ulogic_vector(0 to 3);
        pc_xu_abist_di_0                : Out   std_ulogic_vector(0 to 3);
        pc_xu_abist_di_1                : Out   std_ulogic_vector(0 to 3);
        pc_xu_abist_di_g6t_2r           : Out   std_ulogic_vector(0 to 3);
        pc_xu_abist_ena_dc              : Out   std_ulogic;
        pc_xu_abist_g6t_bw              : Out   std_ulogic_vector(0 to 1);
        pc_xu_abist_g6t_r_wb            : Out   std_ulogic;
        pc_xu_abist_g8t1p_renb_0        : Out   std_ulogic;
        pc_xu_abist_g8t_bw_0            : Out   std_ulogic;
        pc_xu_abist_g8t_bw_1            : Out   std_ulogic;
        pc_xu_abist_g8t_dcomp           : Out   std_ulogic_vector(0 to 3);
        pc_xu_abist_g8t_wenb            : Out   std_ulogic;
        pc_xu_abist_grf_renb_0          : Out   std_ulogic;
        pc_xu_abist_grf_renb_1          : Out   std_ulogic;
        pc_xu_abist_grf_wenb_0          : Out   std_ulogic;      
        pc_xu_abist_grf_wenb_1          : Out   std_ulogic;
        pc_xu_abist_raddr_0             : Out   std_ulogic_vector(0 to 9);
        pc_xu_abist_raddr_1             : Out   std_ulogic_vector(0 to 9);
        pc_xu_abist_raw_dc_b            : Out   std_ulogic;
        pc_xu_abist_waddr_0             : Out   std_ulogic_vector(0 to 9);
        pc_xu_abist_waddr_1             : Out   std_ulogic_vector(0 to 9);
        pc_xu_abist_wl144_comp_ena      : Out   std_ulogic;
        pc_xu_abist_wl32_g8t_comp_ena   : Out   std_ulogic;
        pc_xu_abist_wl512_comp_ena      : Out   std_ulogic
);

-- synopsys translate_off




-- synopsys translate_on
end pcq_abist;

architecture pcq_abist of pcq_abist is


constant staging1_size             : positive := 1;
constant staging2_size             : positive := 73;
constant staging3_size             : positive := 42;
constant staging4_size             : positive := 44;
constant staging1_offset           : natural := 0;
constant staging2_offset           : natural := staging1_offset + staging1_size;
constant staging3_offset           : natural := staging2_offset + staging2_size;
constant staging4_offset           : natural := staging3_offset + staging3_size;
constant abst_right                : natural := staging4_offset + staging4_size - 1;

signal abist_start_test_q          : std_ulogic;
signal force_abist                 : std_ulogic;
signal abist_thold_b               : std_ulogic;
signal abist_engine_so             : std_ulogic;
signal abst_siv, abst_sov          : std_ulogic_vector(0 to abst_right);

signal abist_raddr_0               : std_ulogic_vector(0 to 9);
signal abist_raddr_1               : std_ulogic_vector(0 to 9);
signal abist_grf_renb_0            : std_ulogic;
signal abist_grf_renb_1            : std_ulogic;
signal abist_g8t1p_renb_0          : std_ulogic;
signal abist_waddr_0               : std_ulogic_vector(0 to 9);
signal abist_waddr_1               : std_ulogic_vector(0 to 9);
signal abist_grf_wenb_0            : std_ulogic;
signal abist_grf_wenb_1            : std_ulogic;
signal abist_g8t_wenb              : std_ulogic;
signal abist_di_0                  : std_ulogic_vector(0 to 3);
signal abist_di_1                  : std_ulogic_vector(0 to 3);
signal abist_di_g6t_2r             : std_ulogic_vector(0 to 3);
signal abist_g6t_r_wb              : std_ulogic;
signal abist_dcomp                 : std_ulogic_vector(0 to 3);
signal abist_dcomp_g6t_2r          : std_ulogic_vector(0 to 3);
signal abist_wl32_g8t_comp_ena     : std_ulogic;
signal abist_wl64_g8t_comp_ena     : std_ulogic;
signal abist_wl128_g8t_comp_ena    : std_ulogic;
signal abist_wl144_comp_ena        : std_ulogic;
signal abist_wl256_comp_ena        : std_ulogic;
signal abist_wl512_comp_ena        : std_ulogic;
signal abist_bw_0                  : std_ulogic;
signal abist_bw_1                  : std_ulogic;

signal abist_raddr_0_q                  : std_ulogic_vector(0 to 9);
signal abist_raddr_1_q                  : std_ulogic_vector(0 to 9);
signal abist_grf_renb_0_q               : std_ulogic;
signal abist_grf_renb_1_q               : std_ulogic;
signal abist_g8t1p_renb_0_q             : std_ulogic;
signal abist_waddr_0_q                  : std_ulogic_vector(0 to 9);
signal abist_waddr_1_q                  : std_ulogic_vector(0 to 9);
signal abist_grf_wenb_0_q               : std_ulogic;
signal abist_grf_wenb_1_q               : std_ulogic;
signal abist_g8t_wenb_q                 : std_ulogic;
signal abist_di_0_q                     : std_ulogic_vector(0 to 3);
signal abist_di_1_q                     : std_ulogic_vector(0 to 3);
signal abist_di_g6t_2r_q                : std_ulogic_vector(0 to 3);
signal abist_g6t_r_wb_q                 : std_ulogic;
signal abist_dcomp_q                    : std_ulogic_vector(0 to 3);
signal abist_dcomp_g6t_2r_q             : std_ulogic_vector(0 to 3);
signal abist_wl32_g8t_comp_ena_q        : std_ulogic;
signal abist_wl64_g8t_comp_ena_q        : std_ulogic;
signal abist_wl144_comp_ena_q           : std_ulogic;
signal abist_wl512_comp_ena_q           : std_ulogic;
signal abist_bw_0_q                     : std_ulogic;
signal abist_bw_1_q                     : std_ulogic;
signal abist_ena_dc                     : std_ulogic;
signal abist_raw_dc_b                   : std_ulogic;

signal mm_abist_waddr_0_q               : std_ulogic_vector(0 to 9);
signal mm_abist_g8t_wenb_q              : std_ulogic;
signal mm_abist_raddr_0_q               : std_ulogic_vector(0 to 9);
signal mm_abist_g8t1p_renb_0_q          : std_ulogic;
signal mm_abist_g6t_r_wb_q              : std_ulogic;
signal mm_abist_di_0_q                  : std_ulogic_vector(0 to 3);
signal mm_abist_di_g6t_2r_q             : std_ulogic_vector(0 to 3);
signal mm_abist_bw_0_q                  : std_ulogic;
signal mm_abist_bw_1_q                  : std_ulogic;
signal mm_abist_wl128_g8t_comp_ena_q    : std_ulogic;
signal mm_abist_dcomp_q                 : std_ulogic_vector(0 to 3);
signal mm_abist_dcomp_g6t_2r_q          : std_ulogic_vector(0 to 3);

signal iu_abist_waddr_0_q               : std_ulogic_vector(0 to 9);
signal iu_abist_g8t_wenb_q              : std_ulogic;
signal iu_abist_raddr_0_q               : std_ulogic_vector(0 to 9);
signal iu_abist_g8t1p_renb_0_q          : std_ulogic;
signal iu_abist_g6t_r_wb_q              : std_ulogic;
signal iu_abist_di_0_q                  : std_ulogic_vector(0 to 3);
signal iu_abist_di_g6t_2r_q             : std_ulogic_vector(0 to 3);
signal iu_abist_bw_0_q                  : std_ulogic;
signal iu_abist_bw_1_q                  : std_ulogic;
signal iu_abist_wl64_g8t_comp_ena_q     : std_ulogic;
signal iu_abist_wl128_g8t_comp_ena_q    : std_ulogic;
signal iu_abist_wl256_comp_ena_q        : std_ulogic;
signal iu_abist_dcomp_q                 : std_ulogic_vector(0 to 3);
signal iu_abist_dcomp_g6t_2r_q          : std_ulogic_vector(0 to 3);


begin


abist_engine: entity tri.tri_caa_prism_abist
  port map (   abist_done_in_dc           =>  abist_done_in_dc         
             , abist_done_out_dc          =>  abist_done_out_dc        
             , abist_mode_dc              =>  abist_mode_dc            
             , lbist_mode_dc              =>  lbist_mode_dc            
             , lbist_ac_mode_dc           =>  lbist_ac_mode_dc
     
             , abist_waddr_0              =>  abist_waddr_0(0 to 9)
             , abist_waddr_1              =>  abist_waddr_1(0 to 9)
             , abist_grf_wenb_0           =>  abist_grf_wenb_0
             , abist_grf_wenb_1           =>  abist_grf_wenb_1
             , abist_raddr_0              =>  abist_raddr_0(0 to 9)
             , abist_raddr_1              =>  abist_raddr_1(0 to 9)
             , abist_grf_renb_0           =>  abist_grf_renb_0
             , abist_grf_renb_1           =>  abist_grf_renb_1
             , abist_g8t_wenb             =>  abist_g8t_wenb
             , abist_g8t1p_renb_0         =>  abist_g8t1p_renb_0
             , abist_g6t_r_wb             =>  abist_g6t_r_wb
             , abist_di_g6t_2r            =>  abist_di_g6t_2r(0 to 3)
             , abist_di_0                 =>  abist_di_0(0 to 3)
             , abist_di_1                 =>  abist_di_1(0 to 3)
             , abist_dcomp                =>  abist_dcomp(0 to 3)
             , abist_dcomp_g6t_2r         =>  abist_dcomp_g6t_2r(0 to 3)
             , abist_bw_0                 =>  abist_bw_0
             , abist_bw_1                 =>  abist_bw_1
             , abist_wl32_g8t_comp_ena    =>  abist_wl32_g8t_comp_ena
             , abist_wl64_g8t_comp_ena    =>  abist_wl64_g8t_comp_ena  
             , abist_wl128_g8t_comp_ena   =>  abist_wl128_g8t_comp_ena  
             , abist_wl144_comp_ena       =>  abist_wl144_comp_ena
             , abist_wl256_comp_ena       =>  abist_wl256_comp_ena
             , abist_wl512_comp_ena       =>  abist_wl512_comp_ena
             , abist_ena_dc               =>  abist_ena_dc
             , abist_raw_dc_b             =>  abist_raw_dc_b

             , lcb_clkoff_dc_b            =>  lcb_clkoff_dc_b          
             , lcb_act_dis_dc             =>  lcb_act_dis_dc           
             , lcb_d_mode_dc              =>  lcb_d_mode_dc            
             , lcb_delay_lclkr_dc         =>  lcb_delay_lclkr_dc       
             , lcb_delay_lclkr_np_dc      =>  lcb_delay_lclkr_np_dc
             , lcb_mpw1_dc_b              =>  lcb_mpw1_dc_b            
             , lcb_mpw2_dc_b              =>  lcb_mpw2_dc_b            
             , abist_scan_in              =>  abst_sov(abst_right)            
             , abist_scan_out             =>  abist_engine_so           
             , abist_sg                   =>  abist_sg                 
             , abist_thold                =>  abist_thold              
             , gptr_scan_in               =>  gptr_scan_in             
             , gptr_scan_out              =>  gptr_scan_out            
             , gptr_thold                 =>  gptr_thold               
             , nclk                       =>  nclk                    
             , abist_start_test           =>  abist_start_test_q       
             , scan_dis_dc_b              =>  scan_dis_dc_b            
             , vdd                        =>  vdd                      
             , gnd                        =>  gnd
           );


         lcbor_abist: tri_lcbor
             generic map (expand_type => expand_type )
             port map ( clkoff_b => lcb_clkoff_dc_b,
                        thold    => abist_thold,
                        sg       => abist_sg,
                        act_dis  => lcb_act_dis_dc,
                        forcee => force_abist,
                        thold_b  => abist_thold_b );
   
         abist_start_repower: tri_rlmreg_p  
             generic map (width => staging1_size, init => 0, expand_type => expand_type)
             port map (vd       => vdd,
                       gd       => gnd,
                       nclk     => nclk,
                       act      => '1',
                       thold_b  => abist_thold_b,
                       sg       => abist_sg,
                       forcee => force_abist,
                       delay_lclkr => lcb_delay_lclkr_dc,
                       mpw1_b   => lcb_mpw1_dc_b,
                       mpw2_b   => lcb_mpw2_dc_b,
                       scin     => abst_siv(staging1_offset to staging1_offset + staging1_size-1),
                       scout    => abst_sov(staging1_offset to staging1_offset + staging1_size-1),
                       din(0)   => abist_start_test,   
                       dout(0)  => abist_start_test_q );
   
         abist_eng_repower: tri_rlmreg_p  
             generic map (width => staging2_size, init => 0, expand_type => expand_type)
             port map (vd       => vdd,
                       gd       => gnd,
                       nclk     => nclk,
                       act      => abist_mode_dc,
                       thold_b  => abist_thold_b,
                       sg       => abist_sg,
                       forcee => force_abist,
                       delay_lclkr => lcb_delay_lclkr_dc,
                       mpw1_b   => lcb_mpw1_dc_b,
                       mpw2_b   => lcb_mpw2_dc_b,
                       scin     => abst_siv(staging2_offset to staging2_offset + staging2_size-1),
                       scout    => abst_sov(staging2_offset to staging2_offset + staging2_size-1),
                       din(0)   => abist_grf_wenb_0,   
                       din(1)   => abist_grf_wenb_1,   
                       din(2)   => abist_g8t_wenb,     
                       din(3)   => abist_grf_renb_0,   
                       din(4)   => abist_grf_renb_1,   
                       din(5)   => abist_g8t1p_renb_0, 
                       din(6)   => abist_g6t_r_wb,     
                       din(7)   => abist_bw_0,         
                       din(8)   => abist_bw_1,         
                       din(9)   => abist_wl32_g8t_comp_ena,  
                       din(10)  => abist_wl64_g8t_comp_ena,  
                       din(11)  => abist_wl144_comp_ena, 
                       din(12)  => abist_wl512_comp_ena, 
                       din(13 to 22)  => abist_waddr_0,
                       din(23 to 32)  => abist_waddr_1,
                       din(33 to 42)  => abist_raddr_0,
                       din(43 to 52)  => abist_raddr_1,
                       din(53 to 56)  => abist_di_0,        
                       din(57 to 60)  => abist_di_1,        
                       din(61 to 64)  => abist_di_g6t_2r,   
                       din(65 to 68)  => abist_dcomp,       
                       din(69 to 72)  => abist_dcomp_g6t_2r,
                       dout(0)  => abist_grf_wenb_0_q,   
                       dout(1)  => abist_grf_wenb_1_q,   
                       dout(2)  => abist_g8t_wenb_q,     
                       dout(3)  => abist_grf_renb_0_q,   
                       dout(4)  => abist_grf_renb_1_q,   
                       dout(5)  => abist_g8t1p_renb_0_q, 
                       dout(6)  => abist_g6t_r_wb_q,     
                       dout(7)  => abist_bw_0_q,         
                       dout(8)  => abist_bw_1_q,         
                       dout(9)  => abist_wl32_g8t_comp_ena_q,  
                       dout(10) => abist_wl64_g8t_comp_ena_q,  
                       dout(11) => abist_wl144_comp_ena_q, 
                       dout(12) => abist_wl512_comp_ena_q, 
                       dout(13 to 22) => abist_waddr_0_q,
                       dout(23 to 32) => abist_waddr_1_q,
                       dout(33 to 42) => abist_raddr_0_q,
                       dout(43 to 52) => abist_raddr_1_q,
                       dout(53 to 56) => abist_di_0_q,        
                       dout(57 to 60) => abist_di_1_q,        
                       dout(61 to 64) => abist_di_g6t_2r_q,   
                       dout(65 to 68) => abist_dcomp_q,       
                       dout(69 to 72) => abist_dcomp_g6t_2r_q );
    
         abist_mm_repower: tri_rlmreg_p  
             generic map (width => staging3_size, init => 0, expand_type => expand_type)
             port map (vd       => vdd,
                       gd       => gnd,
                       nclk     => nclk,
                       act      => abist_mode_dc,
                       thold_b  => abist_thold_b,
                       sg       => abist_sg,
                       forcee => force_abist,
                       delay_lclkr => lcb_delay_lclkr_dc,
                       mpw1_b   => lcb_mpw1_dc_b,
                       mpw2_b   => lcb_mpw2_dc_b,
                       scin     => abst_siv(staging3_offset to staging3_offset + staging3_size-1),
                       scout    => abst_sov(staging3_offset to staging3_offset + staging3_size-1),
                       din(0)   => abist_g8t_wenb,     
                       din(1)   => abist_g8t1p_renb_0, 
                       din(2)   => abist_g6t_r_wb,     
                       din(3)   => abist_bw_0,         
                       din(4)   => abist_bw_1,         
                       din(5)   => abist_wl128_g8t_comp_ena, 
                       din(6 to 15)   => abist_waddr_0,
                       din(16 to 25)  => abist_raddr_0,
                       din(26 to 29)  => abist_di_0,        
                       din(30 to 33)  => abist_di_g6t_2r,   
                       din(34 to 37)  => abist_dcomp,       
                       din(38 to 41)  => abist_dcomp_g6t_2r,
                       dout(0)  => mm_abist_g8t_wenb_q,     
                       dout(1)  => mm_abist_g8t1p_renb_0_q, 
                       dout(2)  => mm_abist_g6t_r_wb_q,     
                       dout(3)  => mm_abist_bw_0_q,         
                       dout(4)  => mm_abist_bw_1_q,         
                       dout(5)  => mm_abist_wl128_g8t_comp_ena_q, 
                       dout(6 to 15)  => mm_abist_waddr_0_q,
                       dout(16 to 25) => mm_abist_raddr_0_q,
                       dout(26 to 29) => mm_abist_di_0_q,        
                       dout(30 to 33) => mm_abist_di_g6t_2r_q,   
                       dout(34 to 37) => mm_abist_dcomp_q,       
                       dout(38 to 41) => mm_abist_dcomp_g6t_2r_q );
   
         abist_iu_repower: tri_rlmreg_p  
             generic map (width => staging4_size, init => 0, expand_type => expand_type)
             port map (vd       => vdd,
                       gd       => gnd,
                       nclk     => nclk,
                       act      => abist_mode_dc,
                       thold_b  => abist_thold_b,
                       sg       => abist_sg,
                       forcee => force_abist,
                       delay_lclkr => lcb_delay_lclkr_dc,
                       mpw1_b   => lcb_mpw1_dc_b,
                       mpw2_b   => lcb_mpw2_dc_b,
                       scin     => abst_siv(staging4_offset to staging4_offset + staging4_size-1),
                       scout    => abst_sov(staging4_offset to staging4_offset + staging4_size-1),
                       din(0)   => abist_g8t_wenb,     
                       din(1)   => abist_g8t1p_renb_0, 
                       din(2)   => abist_g6t_r_wb,     
                       din(3)   => abist_bw_0,         
                       din(4)   => abist_bw_1,         
                       din(5)   => abist_wl64_g8t_comp_ena,  
                       din(6)   => abist_wl128_g8t_comp_ena, 
                       din(7)   => abist_wl256_comp_ena, 
                       din(8 to 17)   => abist_waddr_0,
                       din(18 to 27)  => abist_raddr_0,
                       din(28 to 31)  => abist_di_0,        
                       din(32 to 35)  => abist_di_g6t_2r,   
                       din(36 to 39)  => abist_dcomp,       
                       din(40 to 43)  => abist_dcomp_g6t_2r,
                       dout(0)  => iu_abist_g8t_wenb_q,     
                       dout(1)  => iu_abist_g8t1p_renb_0_q, 
                       dout(2)  => iu_abist_g6t_r_wb_q,     
                       dout(3)  => iu_abist_bw_0_q,         
                       dout(4)  => iu_abist_bw_1_q,         
                       dout(5)  => iu_abist_wl64_g8t_comp_ena_q,  
                       dout(6)  => iu_abist_wl128_g8t_comp_ena_q, 
                       dout(7)  => iu_abist_wl256_comp_ena_q, 
                       dout(8 to 17)  => iu_abist_waddr_0_q,
                       dout(18 to 27) => iu_abist_raddr_0_q,
                       dout(28 to 31) => iu_abist_di_0_q,        
                       dout(32 to 35) => iu_abist_di_g6t_2r_q,   
                       dout(36 to 39) => iu_abist_dcomp_q,       
                       dout(40 to 43) => iu_abist_dcomp_g6t_2r_q );
  
      abst_siv(0 TO abst_right-1) <= (abist_scan_in and not bo_enable) & abst_sov(0 to abst_right-2);
      abst_siv(abst_right) <= bo_abist_eng_si when bo_enable='1' else abst_sov(abst_right-1);
      abist_scan_out <= abist_engine_so and scan_dis_dc_b;



  pc_bx_abist_waddr_0           <= abist_waddr_0_q(0 to 9);
  pc_iu_abist_waddr_0           <= iu_abist_waddr_0_q(0 to 9);
  pc_fu_abist_waddr_0           <= abist_waddr_0_q(0 to 9);
  pc_mm_abist_waddr_0           <= mm_abist_waddr_0_q(0 to 9);
  pc_xu_abist_waddr_0           <= abist_waddr_0_q(0 to 9);

  pc_fu_abist_waddr_1           <= abist_waddr_1_q(0 to 9);
  pc_xu_abist_waddr_1           <= abist_waddr_1_q(0 to 9);

  pc_fu_abist_grf_wenb_0        <= abist_grf_wenb_0_q;      
  pc_xu_abist_grf_wenb_0        <= abist_grf_wenb_0_q;      

  pc_fu_abist_grf_wenb_1        <= abist_grf_wenb_1_q;      
  pc_xu_abist_grf_wenb_1        <= abist_grf_wenb_1_q;

  pc_bx_abist_g8t_wenb          <= abist_g8t_wenb_q;
  pc_iu_abist_g8t_wenb          <= iu_abist_g8t_wenb_q;
  pc_mm_abist_g8t_wenb          <= mm_abist_g8t_wenb_q;
  pc_xu_abist_g8t_wenb          <= abist_g8t_wenb_q;

  pc_bx_abist_raddr_0           <= abist_raddr_0_q(0 to 9);
  pc_iu_abist_raddr_0           <= iu_abist_raddr_0_q(0 to 9);
  pc_fu_abist_raddr_0           <= abist_raddr_0_q(0 to 9);
  pc_mm_abist_raddr_0           <= mm_abist_raddr_0_q(0 to 9);
  pc_xu_abist_raddr_0           <= abist_raddr_0_q(0 to 9);

  pc_fu_abist_raddr_1           <= abist_raddr_1_q(0 to 9);
  pc_xu_abist_raddr_1           <= abist_raddr_1_q(0 to 9);

  pc_fu_abist_grf_renb_0        <= abist_grf_renb_0_q;
  pc_xu_abist_grf_renb_0        <= abist_grf_renb_0_q;

  pc_fu_abist_grf_renb_1        <= abist_grf_renb_1_q;
  pc_xu_abist_grf_renb_1        <= abist_grf_renb_1_q;

  pc_bx_abist_g8t1p_renb_0      <= abist_g8t1p_renb_0_q;
  pc_iu_abist_g8t1p_renb_0      <= iu_abist_g8t1p_renb_0_q;
  pc_mm_abist_g8t1p_renb_0      <= mm_abist_g8t1p_renb_0_q;
  pc_xu_abist_g8t1p_renb_0      <= abist_g8t1p_renb_0_q;

  pc_iu_abist_g6t_r_wb          <= iu_abist_g6t_r_wb_q;
  pc_mm_abist_g6t_r_wb          <= mm_abist_g6t_r_wb_q;
  pc_xu_abist_g6t_r_wb          <= abist_g6t_r_wb_q;

  pc_bx_abist_di_0              <= abist_di_0_q(0 to 3);
  pc_iu_abist_di_0              <= iu_abist_di_0_q(0 to 3);
  pc_fu_abist_di_0              <= abist_di_0_q(0 to 3);
  pc_mm_abist_di_0              <= mm_abist_di_0_q(0 to 3);
  pc_xu_abist_di_0              <= abist_di_0_q(0 to 3);

  pc_fu_abist_di_1              <= abist_di_1_q(0 to 3);
  pc_xu_abist_di_1              <= abist_di_1_q(0 to 3);

  pc_iu_abist_di_g6t_2r         <= iu_abist_di_g6t_2r_q(0 to 3);
  pc_mm_abist_di_g6t_2r         <= mm_abist_di_g6t_2r_q(0 to 3);
  pc_xu_abist_di_g6t_2r         <= abist_di_g6t_2r_q(0 to 3);

  pc_bx_abist_g8t_bw_0          <= abist_bw_0_q;
  pc_iu_abist_g8t_bw_0          <= iu_abist_bw_0_q;
  pc_mm_abist_g8t_bw_0          <= mm_abist_bw_0_q;
  pc_xu_abist_g8t_bw_0          <= abist_bw_0_q;

  pc_bx_abist_g8t_bw_1          <= abist_bw_1_q;
  pc_iu_abist_g8t_bw_1          <= iu_abist_bw_1_q;
  pc_mm_abist_g8t_bw_1          <= mm_abist_bw_1_q;
  pc_xu_abist_g8t_bw_1          <= abist_bw_1_q;

  pc_iu_abist_g6t_bw            <= iu_abist_bw_0_q & iu_abist_bw_1_q;
  pc_xu_abist_g6t_bw            <= abist_bw_0_q & abist_bw_1_q;

  pc_xu_abist_wl32_g8t_comp_ena  <= abist_wl32_g8t_comp_ena_q;
  pc_bx_abist_wl64_g8t_comp_ena  <= abist_wl64_g8t_comp_ena_q;
  pc_iu_abist_wl64_g8t_comp_ena  <= iu_abist_wl64_g8t_comp_ena_q;
  pc_iu_abist_wl128_g8t_comp_ena <= iu_abist_wl128_g8t_comp_ena_q;
  pc_mm_abist_wl128_g8t_comp_ena <= mm_abist_wl128_g8t_comp_ena_q;
  pc_fu_abist_wl144_comp_ena     <= abist_wl144_comp_ena_q;
  pc_xu_abist_wl144_comp_ena     <= abist_wl144_comp_ena_q;
  pc_iu_abist_wl256_comp_ena     <= iu_abist_wl256_comp_ena_q;
  pc_xu_abist_wl512_comp_ena     <= abist_wl512_comp_ena_q;

  pc_bx_abist_g8t_dcomp         <= abist_dcomp_q(0 to 3);
  pc_iu_abist_g8t_dcomp         <= iu_abist_dcomp_q(0 to 3);
  pc_mm_abist_g8t_dcomp         <= mm_abist_dcomp_q(0 to 3);
  pc_xu_abist_g8t_dcomp         <= abist_dcomp_q(0 to 3);

  pc_iu_abist_dcomp_g6t_2r      <= iu_abist_dcomp_g6t_2r_q(0 to 3);
  pc_mm_abist_dcomp_g6t_2r      <= mm_abist_dcomp_g6t_2r_q(0 to 3);
  pc_xu_abist_dcomp_g6t_2r      <= abist_dcomp_g6t_2r_q(0 to 3);

  pc_bx_abist_ena_dc            <= abist_ena_dc;
  pc_iu_abist_ena_dc            <= abist_ena_dc;
  pc_fu_abist_ena_dc            <= abist_ena_dc;
  pc_mm_abist_ena_dc            <= abist_ena_dc;
  pc_xu_abist_ena_dc            <= abist_ena_dc;

  pc_bx_abist_raw_dc_b          <= abist_raw_dc_b;
  pc_iu_abist_raw_dc_b          <= abist_raw_dc_b;
  pc_fu_abist_raw_dc_b          <= abist_raw_dc_b;
  pc_mm_abist_raw_dc_b          <= abist_raw_dc_b;
  pc_xu_abist_raw_dc_b          <= abist_raw_dc_b;


end pcq_abist;
