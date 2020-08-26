-- © IBM Corp. 2020
-- This softcore is licensed under and subject to the terms of the CC-BY 4.0
-- license (https://creativecommons.org/licenses/by/4.0/legalcode). 
-- Additional rights, including the right to physically implement a softcore 
-- that is compliant with the required sections of the Power ISA 
-- Specification, will be available at no cost via the OpenPOWER Foundation. 
-- This README will be updated with additional information when OpenPOWER's 
-- license is available.




---------------------------------------------------------------------

library ieee,ibm,support,tri,work;
   use ieee.std_logic_1164.all;
   use ibm.std_ulogic_unsigned.all;
   use ibm.std_ulogic_support.all; 
   use ibm.std_ulogic_function_support.all;
   use support.power_logic_pkg.all;
   use tri.tri_latches_pkg.all;
   use ibm.std_ulogic_ao_support.all; 
   use ibm.std_ulogic_mux_support.all; 
   use work.iuq_pkg.all;

---------------------------------------------------------------------


entity iuq_axu_fu_iss is
generic(
        expand_type                             : integer := 2;
        fpr_addr_width                          : integer := 5;
        needs_sreset                            : integer := 1); -- 0 - ibm tech, 1 - other );
port(
   	nclk                                 	: in  clk_logic;                
        ---------------------------------------------------------------------
        vdd                                 	: inout power_logic;
        gnd                                 	: inout power_logic;
        ---------------------------------------------------------------------
        iu_au_is1_flush                           : in  std_ulogic_vector(0 to 3);
        xu_iu_is2_flush                         : in  std_ulogic_vector(0 to 3);
        uc_flush                                : in  std_ulogic_vector(0 to 3);
        ---------------------------------------------------------------------
        -- pervasive
   	i_iss_si                           	: in  std_ulogic;           
   	i_iss_so                           	: out std_ulogic;              
        an_ac_scan_dis_dc_b                     : in std_ulogic;      
        pc_iu_func_sl_thold_2                   : in std_ulogic;
        pc_iu_sg_2                              : in std_ulogic;
        mpw1_b                                     : in std_ulogic;

        clkoff_b                                :in   std_ulogic; 
        
        tc_ac_ccflush_dc                            :in   std_ulogic;
        delay_lclkr                                : in std_ulogic;
     
        --------------------------------------------------------
        i_axu_is2_instr_match_t0                   : in  std_ulogic; 
        i_axu_is2_instr_match_t1                   : in  std_ulogic;
        i_axu_is2_instr_match_t2                   : in  std_ulogic;
        i_axu_is2_instr_match_t3                   : in  std_ulogic;

        i_afd_is2_is_ucode_t0                   : in  std_ulogic;
        i_afd_is2_is_ucode_t1                   : in  std_ulogic;
        i_afd_is2_is_ucode_t2                   : in  std_ulogic;
        i_afd_is2_is_ucode_t3                   : in  std_ulogic;

        i_afd_is2_t0_instr_v                    : in  std_ulogic;
        i_afd_is2_t1_instr_v                    : in  std_ulogic;
        i_afd_is2_t2_instr_v                    : in  std_ulogic;
        i_afd_is2_t3_instr_v                    : in  std_ulogic;
        
        i_afd_is2_t0_instr                      : in  std_ulogic_vector(0 to 31);
        i_afd_is2_t1_instr                      : in  std_ulogic_vector(0 to 31);
        i_afd_is2_t2_instr                      : in  std_ulogic_vector(0 to 31);
        i_afd_is2_t3_instr                      : in  std_ulogic_vector(0 to 31);

        i_afd_is2_fra_t0                        : in  std_ulogic_vector(0 to 6);
        i_afd_is2_fra_t1                        : in  std_ulogic_vector(0 to 6);
        i_afd_is2_fra_t2                        : in  std_ulogic_vector(0 to 6);
        i_afd_is2_fra_t3                        : in  std_ulogic_vector(0 to 6);

        i_afd_is2_frb_t0                        : in  std_ulogic_vector(0 to 6);
        i_afd_is2_frb_t1                        : in  std_ulogic_vector(0 to 6);
        i_afd_is2_frb_t2                        : in  std_ulogic_vector(0 to 6);
        i_afd_is2_frb_t3                        : in  std_ulogic_vector(0 to 6);

        i_afd_is2_frc_t0                        : in  std_ulogic_vector(0 to 6);
        i_afd_is2_frc_t1                        : in  std_ulogic_vector(0 to 6);
        i_afd_is2_frc_t2                        : in  std_ulogic_vector(0 to 6);
        i_afd_is2_frc_t3                        : in  std_ulogic_vector(0 to 6);

        i_afd_is2_frt_t0                        : in  std_ulogic_vector(0 to 6);
        i_afd_is2_frt_t1                        : in  std_ulogic_vector(0 to 6);
        i_afd_is2_frt_t2                        : in  std_ulogic_vector(0 to 6);
        i_afd_is2_frt_t3                        : in  std_ulogic_vector(0 to 6);

        i_afd_is2_fra_v_t0                        : in  std_ulogic;
        i_afd_is2_fra_v_t1                        : in  std_ulogic;
        i_afd_is2_fra_v_t2                        : in  std_ulogic;
        i_afd_is2_fra_v_t3                        : in  std_ulogic;
                                                               
        i_afd_is2_frb_v_t0                        : in  std_ulogic;
        i_afd_is2_frb_v_t1                        : in  std_ulogic;
        i_afd_is2_frb_v_t2                        : in  std_ulogic;
        i_afd_is2_frb_v_t3                        : in  std_ulogic;
                                                               
        i_afd_is2_frc_v_t0                        : in  std_ulogic;
        i_afd_is2_frc_v_t1                        : in  std_ulogic;
        i_afd_is2_frc_v_t2                        : in  std_ulogic;
        i_afd_is2_frc_v_t3                        : in  std_ulogic;

        i_afd_is2_bypsel_t0                       : in  std_ulogic_vector(0 to 5);   
        i_afd_is2_bypsel_t1                       : in  std_ulogic_vector(0 to 5);    
        i_afd_is2_bypsel_t2                       : in  std_ulogic_vector(0 to 5);    
        i_afd_is2_bypsel_t3                       : in  std_ulogic_vector(0 to 5);    
          
        i_afd_is2_ifar_t0                            : in  EFF_IFAR;
        i_afd_is2_ifar_t1                            : in  EFF_IFAR;
        i_afd_is2_ifar_t2                            : in  EFF_IFAR;
        i_afd_is2_ifar_t3                            : in  EFF_IFAR;


        i_axu_is1_dep_hit_t0_b                     : in  std_ulogic;
        i_axu_is1_dep_hit_t1_b                     : in  std_ulogic;
        i_axu_is1_dep_hit_t2_b                     : in  std_ulogic;
        i_axu_is1_dep_hit_t3_b                     : in  std_ulogic;
        
        i_axu_is1_early_v_t0                       : in  std_ulogic;
        i_axu_is1_early_v_t1                       : in  std_ulogic;
        i_axu_is1_early_v_t2                       : in  std_ulogic;
        i_axu_is1_early_v_t3                       : in  std_ulogic;                    
        
        ifdp_is2_est_bubble3_t0                : in  std_ulogic;
        ifdp_is2_est_bubble3_t1                : in  std_ulogic;
        ifdp_is2_est_bubble3_t2                : in  std_ulogic;
        ifdp_is2_est_bubble3_t3                : in  std_ulogic;

        iu_au_md_pri_mask                       : in std_ulogic_vector(0 to 3);
        iu_au_hi_pri_mask                       : in std_ulogic_vector(0 to 3);

        spr_fiss_pri_rand                          : in std_ulogic_vector(0 to 4); 
        spr_fiss_pri_rand_always                   : in std_ulogic;                
        spr_fiss_pri_rand_flush                    : in std_ulogic;                

        --------------------------------------------------------
        iu_is2_take_t                           : out std_ulogic_vector(0 to 3);
        iu_fu_is2_tid_decode                    : out std_ulogic_vector(0 to 3);
        --------------------------------------------------------
        -- to FU
        iu_fu_rf0_instr_match                   : out std_ulogic;
        iu_fu_rf0_instr                         : out std_ulogic_vector(0 to 31);      
        iu_fu_rf0_instr_v                       : out std_ulogic;
        iu_fu_rf0_is_ucode                      : out std_ulogic;

        iu_fu_rf0_fra                          : out std_ulogic_vector(0 to 6);        
        iu_fu_rf0_frb                          : out std_ulogic_vector(0 to 6);                  
        iu_fu_rf0_frc                          : out std_ulogic_vector(0 to 6);                  
        iu_fu_rf0_frt                          : out std_ulogic_vector(0 to 6);                  
                               
        iu_fu_rf0_fra_v                        : out std_ulogic;                
        iu_fu_rf0_frb_v                        : out std_ulogic;                 
        iu_fu_rf0_frc_v                        : out std_ulogic;
                 
        iu_fu_rf0_ucfmul                       : out std_ulogic;



        i_afd_ignore_flush_is2_t0               : in std_ulogic;  -- for ppc div or sqrt
        i_afd_ignore_flush_is2_t1               : in std_ulogic;
        i_afd_ignore_flush_is2_t2               : in std_ulogic;
        i_afd_ignore_flush_is2_t3               : in std_ulogic;

        i_afd_config_iucr_t0                    : in  std_ulogic_vector(2 to 4); 
        i_afd_config_iucr_t1                    : in  std_ulogic_vector(2 to 4); 
        i_afd_config_iucr_t2                    : in  std_ulogic_vector(2 to 4); 
        i_afd_config_iucr_t3                    : in  std_ulogic_vector(2 to 4); 
        
        i_afd_in_ucode_mode_or1d_b_t0           : in std_ulogic; 
        i_afd_in_ucode_mode_or1d_b_t1           : in std_ulogic; 
        i_afd_in_ucode_mode_or1d_b_t2           : in std_ulogic; 
        i_afd_in_ucode_mode_or1d_b_t3           : in std_ulogic; 
                
        fu_iss_debug                            : out std_ulogic_vector(0 to 23); 
              
        iu_fu_rf0_tid                           : out std_ulogic_vector(0 to 1);      
        
        iu_fu_rf0_bypsel                        : out std_ulogic_vector(0 to 5);       
                   
        iu_fu_rf0_ifar                          : out EFF_IFAR        
       
);

  -- synopsys translate_off
   


  

   -- synopsys translate_on

end iuq_axu_fu_iss;

--------------------------------------------------------------------------------------------------------------------------------------------------------

architecture iuq_axu_fu_iss of iuq_axu_fu_iss is
signal act_dis                          : std_ulogic;
signal d_mode                           : std_ulogic;
signal mpw2_b                           : std_ulogic;
  
signal tidn                           : std_ulogic;
signal tiup                           : std_ulogic;

signal is2_issue_sel    : std_ulogic_vector(0 to 3);

signal is2_issue_sel_buf1_b    : std_ulogic_vector(0 to 3);
signal is2_issue_sel_buf2      : std_ulogic_vector(0 to 3);
signal is2_issue_sel_buf3_b    : std_ulogic_vector(0 to 3);
signal is2_issue_sel_buf4      : std_ulogic_vector(0 to 3);


signal rf0_wpc_sp_latch_scout : std_ulogic_vector(0 to 4); 
signal rf0_wpc_sp_latch_scin  : std_ulogic_vector(0 to 4); 

signal debug_reg_scin           : std_ulogic_vector(0 to 4); 
signal debug_reg_scout          : std_ulogic_vector(0 to 4);

signal hi_n230, hi_n231, hi_n232    : std_ulogic;
signal hi_n220, hi_n221, hi_n210    : std_ulogic;
signal md_n230, md_n231, md_n232    : std_ulogic;
signal md_n220, md_n221, md_n210    : std_ulogic;


signal medpri_v, medpri_v_b, highpri_v, highpri_v_b    : std_ulogic_vector(0 to 3);

signal is2_bubble_latch_scin: std_ulogic_vector(0 to 2); 
signal is2_bubble_latch_scout: std_ulogic_vector(0 to 2); 
signal is2_skip_latch_scin: std_ulogic_vector(0 to 3); 
signal is2_skip_latch_scout: std_ulogic_vector(0 to 3); 




signal rf0_stage_latch_scin  : std_ulogic_vector(0 to 76+EFF_IFAR'length);
signal rf0_stage_latch_scout : std_ulogic_vector(0 to 76+EFF_IFAR'length);


signal spare_unused     : std_ulogic_vector(00 to 10); 
signal spare_l2         : std_ulogic_vector(00 to 6); 



signal skip_b :std_ulogic_vector(0 to 3);

signal is2_insert_one_bubble, is2_insert_two_bubbles,  is2_insert_three_bubbles,  is2_insert_seven_bubbles :std_ulogic;
signal single_step_mode, single_step_divsqrt_mode, divsqrt_mode  :std_ulogic;

signal bubble_din, bubble_dout : std_ulogic_vector(2 to 4);
signal  skip_din, skip_dout     : std_ulogic_vector(0 to 3);

signal hi_mask_v_b, md_mask_v_b:  std_ulogic_vector(0 to 3);
signal hi_mask_v, md_mask_v:  std_ulogic_vector(0 to 3);

signal is2_v_t : std_ulogic_vector(0 to 3);

signal iu_fu_is2_instr_match  :  std_ulogic;                 
signal iu_fu_is2_instr        :  std_ulogic_vector(0 to 31);      
signal iu_fu_is2_instr_v      :  std_ulogic;
signal is2_instr_v, disable_cgat      :  std_ulogic;
signal is2_act_din, is2_act_l2, is2_act   :  std_ulogic;

signal iu_fu_is2_fra          :  std_ulogic_vector(0 to 6);        
signal iu_fu_is2_frb          :  std_ulogic_vector(0 to 6);                  
signal iu_fu_is2_frc          :  std_ulogic_vector(0 to 6);                  
signal iu_fu_is2_frt          :  std_ulogic_vector(0 to 6);            
signal iu_fu_is2_fra_v        :  std_ulogic;                
signal iu_fu_is2_frb_v        :  std_ulogic;                 
signal iu_fu_is2_frc_v        :  std_ulogic;                                                                       
signal iu_fu_is2_ucfmul       :  std_ulogic;
signal iu_fu_is2_tid          :  std_ulogic_vector(0 to 1);
signal rf0_tid                :  std_ulogic_vector(0 to 1);

signal iu_fu_is2_bypsel       :  std_ulogic_vector(0 to 5);
signal iu_fu_is2_bypsel_din   :  std_ulogic_vector(0 to 5);
signal is2_ifar               :  EFF_IFAR;
signal is2_ifar_t0               :  EFF_IFAR;
signal is2_ifar_t1               :  EFF_IFAR;
signal is2_ifar_t2               :  EFF_IFAR;
signal is2_ifar_t3               :  EFF_IFAR;

signal rf0_ifar               :  EFF_IFAR;        


signal pc_iu_sg_0,  pc_iu_sg_1       : std_ulogic;
signal pc_iu_func_sl_thold_0 , pc_iu_func_sl_thold_1    : std_ulogic;
signal pc_iu_func_sl_thold_0_b    : std_ulogic;
signal forcee                    : std_ulogic;

signal is2_flush         : std_ulogic_vector(0 to 3);

signal is2_is_ucode            : std_ulogic;
signal is2_issue_sel_db        : std_ulogic_vector(0 to 3);

signal is2_stall               : std_ulogic_vector(0 to 3);
signal dep_hit_b               : std_ulogic_vector(0 to 3);

signal is1_v_din_premux        : std_ulogic_vector(0 to 3);
signal is2_v_dout_premux       : std_ulogic_vector(0 to 3);
signal is1_v_din               : std_ulogic_vector(0 to 3);
signal is2_v_dout              : std_ulogic_vector(0 to 3);
signal ignore_flush_is2        : std_ulogic_vector(0 to 3);

signal is2v_scin, is2v_scout   : std_ulogic_vector(0 to 3); 
signal mask_scin, mask_scout   : std_ulogic_vector(0 to 7); 
signal hi_pri_mask_q           : std_ulogic_vector(0 to 3); 
signal md_pri_mask_q           : std_ulogic_vector(0 to 3);

signal rf0_took_latch_scout    : std_ulogic_vector(0 to 11);
signal rf0_took_latch_scin   : std_ulogic_vector(0 to 11);


signal hi_did0no1, hi_did0no2, hi_did0no3   : std_ulogic;
signal hi_did1no0, hi_did1no2, hi_did1no3   : std_ulogic;
signal hi_did2no1, hi_did2no0, hi_did2no3   : std_ulogic;
signal hi_did3no1, hi_did3no2, hi_did3no0   : std_ulogic;

signal md_did0no1, md_did0no2, md_did0no3   : std_ulogic;
signal md_did1no0, md_did1no2, md_did1no3   : std_ulogic;
signal md_did2no1, md_did2no0, md_did2no3   : std_ulogic;
signal md_did3no1, md_did3no2, md_did3no0   : std_ulogic;

signal hi_sel, hi_sel_b, md_sel, md_sel_b, hi_later, md_later      : std_ulogic_vector(0 to 3); 

signal hi_did3no0_din   : std_ulogic;
signal hi_did3no1_din   : std_ulogic;
signal hi_did3no2_din   : std_ulogic;
               
signal hi_did2no0_din   : std_ulogic;
signal hi_did2no1_din   : std_ulogic;
                
signal hi_did1no0_din   : std_ulogic;
    
signal md_did3no0_din   : std_ulogic;
signal md_did3no1_din   : std_ulogic;
signal md_did3no2_din   : std_ulogic;
               
signal md_did2no0_din   : std_ulogic;
signal md_did2no1_din   : std_ulogic;
                
signal md_did1no0_din   : std_ulogic;
signal pri_rand                 : std_ulogic_vector(0 to 5);
signal hi_did3no0_d   : std_ulogic;
signal hi_did3no1_d   : std_ulogic;
signal hi_did3no2_d   : std_ulogic;
                   
signal hi_did2no0_d   : std_ulogic;
signal hi_did2no1_d   : std_ulogic;
                   
signal hi_did1no0_d   : std_ulogic;
                   
signal md_did3no0_d   : std_ulogic;
signal md_did3no1_d   : std_ulogic;
signal md_did3no2_d   : std_ulogic;
                   
signal md_did2no0_d   : std_ulogic;
signal md_did2no1_d   : std_ulogic;
                   
signal md_did1no0_d   : std_ulogic;


signal issselhi_b, issselmd_b : std_ulogic_vector(0 to 3);
signal issselhi2_b, issselmd2_b : std_ulogic_vector(0 to 3);
signal no_hi_v,no_hi_v_n01, no_hi_v_n23 : std_ulogic;

signal hi_l30,  hi_l31,  hi_l32 : std_ulogic;
signal hi_l23,  hi_l20,  hi_l21 : std_ulogic;
signal hi_l12,  hi_l13,  hi_l10 : std_ulogic;
signal hi_l01,  hi_l02,  hi_l03 : std_ulogic;

signal md_l30,  md_l31,  md_l32 : std_ulogic;
signal md_l23,  md_l20,  md_l21 : std_ulogic;
signal md_l12,  md_l13,  md_l10 : std_ulogic;
signal md_l01,  md_l02,  md_l03 : std_ulogic;

signal iu_is2_take_t_int_b : std_ulogic_vector(0 to 3);
signal iu_is2_take_t_int : std_ulogic_vector(0 to 3);







   





   



   







   


      

          


                                    
   
      

          


          


   

                                    

   
            

   

   
            

   


          
   



begin

tidn      <= '0';
tiup      <= '1';

act_dis <= '0';
d_mode  <= '0';
mpw2_b  <= '1';

    
-- ############################################
-- # pervasive
-- ############################################
  









 auperv_2to1_reg: tri_plat
  generic map (width => 2, expand_type => expand_type)
  port map (vd          => vdd,
            gd          => gnd,
            nclk        => nclk,
            flush       => tc_ac_ccflush_dc,
            din(0)      => pc_iu_func_sl_thold_2,
            din(1)      => pc_iu_sg_2,
            q(0)        => pc_iu_func_sl_thold_1,
            q(1)        => pc_iu_sg_1);
auperv_1to0_reg: tri_plat
  generic map (width => 2, expand_type => expand_type)
  port map (vd          => vdd,
            gd          => gnd,
            nclk        => nclk,
            flush       => tc_ac_ccflush_dc,
            din(0)      => pc_iu_func_sl_thold_1,
            din(1)      => pc_iu_sg_1,
            q(0)        => pc_iu_func_sl_thold_0,
            q(1)        => pc_iu_sg_0);




    lcbor_0: tri_lcbor generic map (expand_type => expand_type ) port map (
        clkoff_b     => clkoff_b,
        thold        => pc_iu_func_sl_thold_0,  
        sg           => pc_iu_sg_0,
        act_dis      => act_dis,
        forcee => forcee,
        thold_b      => pc_iu_func_sl_thold_0_b );


             



    ignore_flush_is2(0 to 3) <= (i_afd_ignore_flush_is2_t0 and not xu_iu_is2_flush(0)) &
                                (i_afd_ignore_flush_is2_t1 and not xu_iu_is2_flush(1)) &
                                (i_afd_ignore_flush_is2_t2 and not xu_iu_is2_flush(2)) &
                                (i_afd_ignore_flush_is2_t3 and not xu_iu_is2_flush(3));


-- ############################################
-- # IS2 Early Valid Logic.  Duplicate latch in DEP
-- ############################################


   is2_stall(0 to 3) <= is2_v_t(0 to 3) and not is2_issue_sel(0 to 3);

   dep_hit_b(0 to 3) <= i_axu_is1_dep_hit_t0_b & i_axu_is1_dep_hit_t1_b & i_axu_is1_dep_hit_t2_b & i_axu_is1_dep_hit_t3_b;

   is1_v_din_premux(0 to 3) <= ((i_axu_is1_early_v_t0 & i_axu_is1_early_v_t1 & i_axu_is1_early_v_t2 & i_axu_is1_early_v_t3)
                               and not is2_stall(0 to 3))
                               and (not iu_au_is1_flush(0 to 3));        

   
   is1_v_din(0 to 3) <= (is1_v_din_premux(0 to 3)  and dep_hit_b(0 to 3)) or 
                        (is2_v_dout_premux(0 to 3) and is2_stall(0 to 3));

   is2v_reg:  tri_rlmreg_p
    generic map (init => 0, expand_type => expand_type, needs_sreset => needs_sreset,  width => 4)
    port map (
      nclk     => nclk,                  act      => tiup,
      vd       => vdd,                   gd       => gnd,     
      forcee => forcee,                 delay_lclkr => delay_lclkr,
      thold_b  => pc_iu_func_sl_thold_0_b, sg       => pc_iu_sg_0,
      mpw1_b      => mpw1_b,
      mpw2_b      => mpw2_b,           
      scin     => is2v_scin,
      scout    => is2v_scout ,
      ---------------------------------------------
      din(0 to 3)  => is1_v_din(0 to 3),
                              
      ---------------------------------------------
      dout(0 to 3) => is2_v_dout(0 to 3)

      ---------------------------------------------
      );

-- if a fdiv or fsqrt is issued in the fxu and stalled (in is2) by the axu, it should not be flushed
   is2_v_dout_premux(0 to 3) <= is2_v_dout(0 to 3) and (not is2_flush(0 to 3) or ignore_flush_is2(0 to 3));   

   is2_v_t(0 to 3) <= is2_v_dout(0 to 3);  



   mask_reg:  tri_rlmreg_p
    generic map (init => 0, expand_type => expand_type, needs_sreset => needs_sreset,  width => 8)
    port map (
      nclk     => nclk,                  act      => tiup,
      vd       => vdd,                   gd       => gnd,     
      forcee => forcee,                 delay_lclkr => delay_lclkr, 
      thold_b  => pc_iu_func_sl_thold_0_b, sg       => pc_iu_sg_0,
      mpw1_b      => mpw1_b,
      mpw2_b      => mpw2_b,         
      scin     => mask_scin,
      scout    => mask_scout ,
      ---------------------------------------------
      din(0 to 3)  => iu_au_hi_pri_mask(0 to 3),
      din(4 to 7)  => iu_au_md_pri_mask(0 to 3),
                              
      ---------------------------------------------
      dout(0 to 3) => hi_pri_mask_q(0 to 3),
      dout(4 to 7) => md_pri_mask_q(0 to 3)

      ---------------------------------------------
      );



-- iu_au_is2_flush
is2_flush(0 to 3) <= xu_iu_is2_flush(0 to 3) or uc_flush(0 to 3);


------------------------------------------------------------------------------------------------------------------------
-- Issue selection logic (replaced table 2/08/2008 -- priority scheme from NorthStar/Sherman
------------------------------------------------------------------------------------------------------------------------





                   skip_b(0) <= not skip_dout(0);
                   skip_b(1) <= not skip_dout(1);
                   skip_b(2) <= not skip_dout(2);
                   skip_b(3) <= not skip_dout(3);
                   

 
hi_mask_v_nand2: hi_mask_v_b <= not(hi_pri_mask_q(0 to 3) and is2_v_dout(0 to 3));
md_mask_v_nand2: md_mask_v_b <= not(md_pri_mask_q(0 to 3) and is2_v_dout(0 to 3));

hi_mask_v_inv:   hi_mask_v <= not hi_mask_v_b;
md_mask_v_inv:   md_mask_v <= not md_mask_v_b;

highpri0v_nand2: highpri_v_b(0) <= not(hi_mask_v(0) and skip_b(0));
highpri1v_nand2: highpri_v_b(1) <= not(hi_mask_v(1) and skip_b(1));
highpri2v_nand2: highpri_v_b(2) <= not(hi_mask_v(2) and skip_b(2));
highpri3v_nand2: highpri_v_b(3) <= not(hi_mask_v(3) and skip_b(3));


medpri0v_nand2: medpri_v_b(0) <= not(md_mask_v(0) and skip_b(0));
medpri1v_nand2: medpri_v_b(1) <= not(md_mask_v(1) and skip_b(1));
medpri2v_nand2: medpri_v_b(2) <= not(md_mask_v(2) and skip_b(2));
medpri3v_nand2: medpri_v_b(3) <= not(md_mask_v(3) and skip_b(3));


-- selection priority among high priority threads only
highpri0v_inv:   highpri_v(0) <= not highpri_v_b(0);
highpri1v_inv:   highpri_v(1) <= not highpri_v_b(1);
highpri2v_inv:   highpri_v(2) <= not highpri_v_b(2);
highpri3v_inv:   highpri_v(3) <= not highpri_v_b(3);

hi_sel_nor23:    hi_sel(3)  <= not (highpri_v_b(3) or hi_later(3));
hi_sel_nand33:   hi_later(3) <= not (hi_l30 and hi_l31 and hi_l32);
hi_sel_nand230:  hi_l30 <= not (hi_did3no0 and highpri_v(0)); 
hi_sel_nand231:  hi_l31 <= not (hi_did3no1 and highpri_v(1));  
hi_sel_nand232:  hi_l32 <= not (hi_did3no2 and highpri_v(2));

hi_sel_nor22:    hi_sel(2)   <= not (highpri_v_b(2) or hi_later(2)) ; 
hi_sel_nand32:   hi_later(2) <= not (hi_l23 and hi_l20 and hi_l21);
hi_sel_nand223:  hi_l23 <= not (hi_did2no3 and highpri_v(3));
hi_sel_nand220:  hi_l20 <= not (hi_did2no0 and highpri_v(0));  
hi_sel_nand221:  hi_l21 <= not (hi_did2no1 and highpri_v(1));

hi_sel_nor21:    hi_sel(1)   <= not (highpri_v_b(1) or hi_later(1)) ;
hi_sel_nand31:   hi_later(1) <= not (hi_l12 and hi_l13 and hi_l10);
hi_sel_nand212:  hi_l12 <= not (hi_did1no2 and highpri_v(2));
hi_sel_nand213:  hi_l13 <= not (hi_did1no3 and highpri_v(3));  
hi_sel_nand210:  hi_l10 <= not (hi_did1no0 and highpri_v(0));

hi_sel_nor20:    hi_sel(0)   <= not (highpri_v_b(0) or hi_later(0)) ;
hi_sel_nand30:   hi_later(0) <= not (hi_l01 and hi_l02 and hi_l03);
hi_sel_nand201:  hi_l01 <= not (hi_did0no1 and highpri_v(1));
hi_sel_nand202:  hi_l02 <= not (hi_did0no2 and highpri_v(2));  
hi_sel_nand203:  hi_l03 <= not (hi_did0no3 and highpri_v(3));


-- selection priority among med priority threads only
medpri0v_inv:   medpri_v(0) <= not medpri_v_b(0);
medpri1v_inv:   medpri_v(1) <= not medpri_v_b(1);
medpri2v_inv:   medpri_v(2) <= not medpri_v_b(2);
medpri3v_inv:   medpri_v(3) <= not medpri_v_b(3);

md_sel_nor23:    md_sel(3)  <= not (medpri_v_b(3) or md_later(3));
md_sel_nand33:   md_later(3) <= not (md_l30 and md_l31 and md_l32);
md_sel_nand230:  md_l30 <= not (md_did3no0 and medpri_v(0)); 
md_sel_nand231:  md_l31 <= not (md_did3no1 and medpri_v(1));  
md_sel_nand232:  md_l32 <= not (md_did3no2 and medpri_v(2));

md_sel_nor22:    md_sel(2)   <= not (medpri_v_b(2) or md_later(2)) ; 
md_sel_nand32:   md_later(2) <= not (md_l23 and md_l20 and md_l21);
md_sel_nand223:  md_l23 <= not (md_did2no3 and medpri_v(3));
md_sel_nand220:  md_l20 <= not (md_did2no0 and medpri_v(0));  
md_sel_nand221:  md_l21 <= not (md_did2no1 and medpri_v(1));

md_sel_nor21:    md_sel(1)   <= not (medpri_v_b(1) or md_later(1)) ;
md_sel_nand31:   md_later(1) <= not (md_l12 and md_l13 and md_l10);
md_sel_nand212:  md_l12 <= not (md_did1no2 and medpri_v(2));
md_sel_nand213:  md_l13 <= not (md_did1no3 and medpri_v(3));  
md_sel_nand210:  md_l10 <= not (md_did1no0 and medpri_v(0));

md_sel_nor20:    md_sel(0)   <= not (medpri_v_b(0) or md_later(0)) ;
md_sel_nand30:   md_later(0) <= not (md_l01 and md_l02 and md_l03);
md_sel_nand201:  md_l01 <= not (md_did0no1 and medpri_v(1));
md_sel_nand202:  md_l02 <= not (md_did0no2 and medpri_v(2));  
md_sel_nand203:  md_l03 <= not (md_did0no3 and medpri_v(3));




-- reorder section

hi_sel_inv0:    hi_sel_b(0) <= not hi_sel(0);
hi_sel_inv1:    hi_sel_b(1) <= not hi_sel(1);
hi_sel_inv2:    hi_sel_b(2) <= not hi_sel(2);
hi_sel_inv3:    hi_sel_b(3) <= not hi_sel(3);

hi_reordf_nand230:  hi_did3no0_din <= not (hi_sel_b(3) and hi_n230);
hi_reordf_nand231:  hi_did3no1_din <= not (hi_sel_b(3) and hi_n231);
hi_reordf_nand232:  hi_did3no2_din <= not (hi_sel_b(3) and hi_n232);
hi_reord_nand230:   hi_n230 <= not (hi_sel_b(0) and hi_did3no0);
hi_reord_nand231:   hi_n231 <= not (hi_sel_b(1) and hi_did3no1);
hi_reord_nand232:   hi_n232 <= not (hi_sel_b(2) and hi_did3no2);



hi_reordf_nand220:  hi_did2no0_din <= not(hi_sel_b(2) and hi_n220);
hi_reord_nand220:   hi_n220 <= not(hi_sel_b(0) and hi_did2no0);

hi_reordf_nand221:  hi_did2no1_din <= not(hi_sel_b(2) and hi_n221);
hi_reord_nand221:   hi_n221 <= not(hi_sel_b(1) and hi_did2no1);

hi_reord_inv23:  hi_did2no3     <= not hi_did3no2;

hi_reordf_nand210:  hi_did1no0_din <= not(hi_sel_b(1) and hi_n210);
hi_reord_nand210:   hi_n210 <= not(hi_sel_b(0) and hi_did1no0);

hi_reord_inv12:  hi_did1no2     <= not hi_did2no1;
hi_reord_inv13:  hi_did1no3     <= not hi_did3no1;

hi_reord_inv01:  hi_did0no1     <= not hi_did1no0;
hi_reord_inv02:  hi_did0no2     <= not hi_did2no0;
hi_reord_inv03:  hi_did0no3     <= not hi_did3no0;


-- med section

md_sel_inv0:    md_sel_b(0) <= not md_sel(0);
md_sel_inv1:    md_sel_b(1) <= not md_sel(1);
md_sel_inv2:    md_sel_b(2) <= not md_sel(2);
md_sel_inv3:    md_sel_b(3) <= not md_sel(3);

md_reordf_nand230:  md_did3no0_din <= not (md_sel_b(3) and md_n230);
md_reordf_nand231:  md_did3no1_din <= not (md_sel_b(3) and md_n231);
md_reordf_nand232:  md_did3no2_din <= not (md_sel_b(3) and md_n232);
md_reord_nand230:   md_n230 <= not (md_sel_b(0) and md_did3no0);
md_reord_nand231:   md_n231 <= not (md_sel_b(1) and md_did3no1);
md_reord_nand232:   md_n232 <= not (md_sel_b(2) and md_did3no2);


md_reordf_nand220:  md_did2no0_din <= not(md_sel_b(2) and md_n220);
md_reord_nand220:   md_n220 <= not(md_sel_b(0) and md_did2no0);

md_reordf_nand221:  md_did2no1_din <= not(md_sel_b(2) and md_n221);
md_reord_nand221:   md_n221 <= not(md_sel_b(1) and md_did2no1);

md_reord_inv23: md_did2no3     <= not md_did3no2;

md_reordf_nand210:  md_did1no0_din <= not(md_sel_b(1) and md_n210);
md_reord_nand210:   md_n210 <= not(md_sel_b(0) and md_did1no0);

md_reord_inv12: md_did1no2     <= not md_did2no1;
md_reord_inv13: md_did1no3     <= not md_did3no1;

md_reord_inv01: md_did0no1     <= not md_did1no0;
md_reord_inv02: md_did0no2     <= not md_did2no0;
md_reord_inv03: md_did0no3     <= not md_did3no0;





nohi_nand21:   no_hi_v_n01 <= not (hi_mask_v_b(0) and hi_mask_v_b(1));
nohi_nand22:   no_hi_v_n23 <= not (hi_mask_v_b(2) and hi_mask_v_b(3));
nohi_nor2:     no_hi_v     <= not (no_hi_v_n01 or no_hi_v_n23);


isssel0_inv: issselhi_b(0) <= not (hi_sel(0));
isssel1_inv: issselhi_b(1) <= not (hi_sel(1));
isssel2_inv: issselhi_b(2) <= not (hi_sel(2));
isssel3_inv: issselhi_b(3) <= not (hi_sel(3));

isssel0_bnand2: issselmd_b(0) <= not (md_sel(0) and no_hi_v);
isssel1_bnand2: issselmd_b(1) <= not (md_sel(1) and no_hi_v);
isssel2_bnand2: issselmd_b(2) <= not (md_sel(2) and no_hi_v);
isssel3_bnand2: issselmd_b(3) <= not (md_sel(3) and no_hi_v);

isssel0_2inv: issselhi2_b(0) <= not (hi_sel(0));
isssel1_2inv: issselhi2_b(1) <= not (hi_sel(1));
isssel2_2inv: issselhi2_b(2) <= not (hi_sel(2));
isssel3_2inv: issselhi2_b(3) <= not (hi_sel(3));

isssel0_2bnand2: issselmd2_b(0) <= not (md_sel(0) and no_hi_v);
isssel1_2bnand2: issselmd2_b(1) <= not (md_sel(1) and no_hi_v);
isssel2_2bnand2: issselmd2_b(2) <= not (md_sel(2) and no_hi_v);
isssel3_2bnand2: issselmd2_b(3) <= not (md_sel(3) and no_hi_v);




isssel0_fnand2:  iu_is2_take_t(0) <= not (issselhi2_b(0) and issselmd2_b(0));
isssel1_fnand2:  iu_is2_take_t(1) <= not (issselhi2_b(1) and issselmd2_b(1));
isssel2_fnand2:  iu_is2_take_t(2) <= not (issselhi2_b(2) and issselmd2_b(2));
isssel3_fnand2:  iu_is2_take_t(3) <= not (issselhi2_b(3) and issselmd2_b(3));

                          



 iu_is2_take_t_int(0) <= not (issselhi_b(0) and issselmd_b(0));
 iu_is2_take_t_int(1) <= not (issselhi_b(1) and issselmd_b(1));
 iu_is2_take_t_int(2) <= not (issselhi_b(2) and issselmd_b(2));
 iu_is2_take_t_int(3) <= not (issselhi_b(3) and issselmd_b(3));
                          

                          
fu_tid_invB0: iu_is2_take_t_int_b(0) <= not iu_is2_take_t_int(0);
fu_tid_invB1: iu_is2_take_t_int_b(1) <= not iu_is2_take_t_int(1);
fu_tid_invB2: iu_is2_take_t_int_b(2) <= not iu_is2_take_t_int(2);
fu_tid_invB3: iu_is2_take_t_int_b(3) <= not iu_is2_take_t_int(3);
                          
fu_tid_invA0: iu_fu_is2_tid_decode(0) <= not iu_is2_take_t_int_b(0);
fu_tid_invA1: iu_fu_is2_tid_decode(1) <= not iu_is2_take_t_int_b(1);
fu_tid_invA2: iu_fu_is2_tid_decode(2) <= not iu_is2_take_t_int_b(2);
fu_tid_invA3: iu_fu_is2_tid_decode(3) <= not iu_is2_take_t_int_b(3);

                          

is2_issue_sel(0 to 3) <= not (issselhi_b(0 to 3) and issselmd_b(0 to 3));



-- issue_sel mapping/buffering
is2_issue_sel_buf1_b(0 to 3)   <= not is2_issue_sel(0 to 3);

is2_issue_sel_buf2(0 to 3)     <= not is2_issue_sel_buf1_b(0 to 3);

is2_issue_sel_buf3_b(0 to 3)   <= not is2_issue_sel_buf2(0 to 3);

is2_issue_sel_buf4(0 to 3)     <= not is2_issue_sel_buf3_b(0 to 3);


------------------------------------------------------------------------------------------------------------------------
--
------------------------------------------------------------------------------------------------------------------------


iu_fu_is2_instr(0 to 31)  <= (i_afd_is2_t0_instr and (0 to 31 => is2_issue_sel_buf4(0))) or
                             (i_afd_is2_t1_instr and (0 to 31 => is2_issue_sel_buf4(1))) or
                             (i_afd_is2_t2_instr and (0 to 31 => is2_issue_sel_buf4(2))) or
                             (i_afd_is2_t3_instr and (0 to 31 => is2_issue_sel_buf4(3)));
                             
is2_instr_v <= i_afd_is2_t0_instr_v or i_afd_is2_t1_instr_v or i_afd_is2_t2_instr_v or i_afd_is2_t3_instr_v;

iu_fu_is2_instr_v <= ((i_afd_is2_t0_instr_v and (not is2_flush(0) or ignore_flush_is2(0))) and is2_issue_sel_buf4(0)) or     
                     ((i_afd_is2_t1_instr_v and (not is2_flush(1) or ignore_flush_is2(1))) and is2_issue_sel_buf4(1)) or     
                     ((i_afd_is2_t2_instr_v and (not is2_flush(2) or ignore_flush_is2(2))) and is2_issue_sel_buf4(2)) or 
                     ((i_afd_is2_t3_instr_v and (not is2_flush(3) or ignore_flush_is2(3))) and is2_issue_sel_buf4(3))   ;

                     
iu_fu_is2_fra     <=  (i_afd_is2_fra_t0 and (0 to 6 => is2_issue_sel_buf4(0))) or
                      (i_afd_is2_fra_t1 and (0 to 6 => is2_issue_sel_buf4(1))) or 
                      (i_afd_is2_fra_t2 and (0 to 6 => is2_issue_sel_buf4(2))) or 
                      (i_afd_is2_fra_t3 and (0 to 6 => is2_issue_sel_buf4(3))) ;
                      
iu_fu_is2_frb     <=  (i_afd_is2_frb_t0 and (0 to 6 => is2_issue_sel_buf4(0))) or
                      (i_afd_is2_frb_t1 and (0 to 6 => is2_issue_sel_buf4(1))) or 
                      (i_afd_is2_frb_t2 and (0 to 6 => is2_issue_sel_buf4(2))) or 
                      (i_afd_is2_frb_t3 and (0 to 6 => is2_issue_sel_buf4(3))) ;
                      
iu_fu_is2_frc     <=  (i_afd_is2_frc_t0 and (0 to 6 => is2_issue_sel_buf4(0))) or
                      (i_afd_is2_frc_t1 and (0 to 6 => is2_issue_sel_buf4(1))) or 
                      (i_afd_is2_frc_t2 and (0 to 6 => is2_issue_sel_buf4(2))) or 
                      (i_afd_is2_frc_t3 and (0 to 6 => is2_issue_sel_buf4(3))) ;
                      
iu_fu_is2_frt     <=  (i_afd_is2_frt_t0 and (0 to 6 => is2_issue_sel_buf4(0))) or
                      (i_afd_is2_frt_t1 and (0 to 6 => is2_issue_sel_buf4(1))) or 
                      (i_afd_is2_frt_t2 and (0 to 6 => is2_issue_sel_buf4(2))) or 
                      (i_afd_is2_frt_t3 and (0 to 6 => is2_issue_sel_buf4(3))) ;    
                      

iu_fu_is2_fra_v   <=  (i_afd_is2_fra_v_t0 and is2_issue_sel_buf4(0)) or
                      (i_afd_is2_fra_v_t1 and is2_issue_sel_buf4(1)) or
                      (i_afd_is2_fra_v_t2 and is2_issue_sel_buf4(2)) or
                      (i_afd_is2_fra_v_t3 and is2_issue_sel_buf4(3)) ;
                      
iu_fu_is2_frb_v   <=  (i_afd_is2_frb_v_t0 and is2_issue_sel_buf4(0)) or
                      (i_afd_is2_frb_v_t1 and is2_issue_sel_buf4(1)) or
                      (i_afd_is2_frb_v_t2 and is2_issue_sel_buf4(2)) or
                      (i_afd_is2_frb_v_t3 and is2_issue_sel_buf4(3)) ;
                      
iu_fu_is2_frc_v   <=  (i_afd_is2_frc_v_t0 and is2_issue_sel_buf4(0)) or
                      (i_afd_is2_frc_v_t1 and is2_issue_sel_buf4(1)) or
                      (i_afd_is2_frc_v_t2 and is2_issue_sel_buf4(2)) or
                      (i_afd_is2_frc_v_t3 and is2_issue_sel_buf4(3)) ;



iu_fu_is2_instr_match  <= (i_axu_is2_instr_match_t0 and is2_issue_sel_buf4(0)) or
                          (i_axu_is2_instr_match_t1 and is2_issue_sel_buf4(1)) or 
                          (i_axu_is2_instr_match_t2 and is2_issue_sel_buf4(2)) or 
                          (i_axu_is2_instr_match_t3 and is2_issue_sel_buf4(3))  ;



                      
-- Early decode for special fmul, ending for sp and dp fdiv/fsqrt

iu_fu_is2_ucfmul  <=  iu_fu_is2_instr(0 to 2) = "111" and iu_fu_is2_instr(4 to 5) = "11" and
                      iu_fu_is2_instr(26 to 30) = "10001";



-- "ORing" i_afd_ignore_flush_is2_t* gets is_ucode to go active during the original ppc instruction.  Otherwise it
-- would never go active on the special cases where the ucode instructions get blocked.
   is2_is_ucode  <=  (i_afd_is2_is_ucode_t0 and is2_issue_sel_buf4(0)) or    
                     (i_afd_is2_is_ucode_t1 and is2_issue_sel_buf4(1)) or    
                     (i_afd_is2_is_ucode_t2 and is2_issue_sel_buf4(2)) or    
                     (i_afd_is2_is_ucode_t3 and is2_issue_sel_buf4(3))  ; 

is2_ifar_t0 <= i_afd_is2_ifar_t0;
is2_ifar_t1 <= i_afd_is2_ifar_t1;
is2_ifar_t2 <= i_afd_is2_ifar_t2;
is2_ifar_t3 <= i_afd_is2_ifar_t3;
                     
                     
is2_ifar    <=  (is2_ifar_t0 and (0 to EFF_IFAR'length-1 => is2_issue_sel_buf4(0))) or   
                (is2_ifar_t1 and (0 to EFF_IFAR'length-1 => is2_issue_sel_buf4(1))) or   
                (is2_ifar_t2 and (0 to EFF_IFAR'length-1 => is2_issue_sel_buf4(2))) or   
                (is2_ifar_t3 and (0 to EFF_IFAR'length-1 => is2_issue_sel_buf4(3)))  ;  

                        
iu_fu_is2_tid(0)     <= is2_issue_sel(2) or is2_issue_sel(3); 
iu_fu_is2_tid(1)     <= is2_issue_sel(1) or is2_issue_sel(3); 




hi_did3no0_d     <=  pri_rand(0) when (spr_fiss_pri_rand_always or (spr_fiss_pri_rand_flush and or_reduce(xu_iu_is2_flush(0 to 3)))) = '1' else hi_did3no0_din;
hi_did3no1_d     <=  pri_rand(1) when (spr_fiss_pri_rand_always or (spr_fiss_pri_rand_flush and or_reduce(xu_iu_is2_flush(0 to 3)))) = '1' else hi_did3no1_din;
hi_did3no2_d     <=  pri_rand(2) when (spr_fiss_pri_rand_always or (spr_fiss_pri_rand_flush and or_reduce(xu_iu_is2_flush(0 to 3)))) = '1' else hi_did3no2_din;
hi_did2no0_d     <=  pri_rand(3) when (spr_fiss_pri_rand_always or (spr_fiss_pri_rand_flush and or_reduce(xu_iu_is2_flush(0 to 3)))) = '1' else hi_did2no0_din;
hi_did2no1_d     <=  pri_rand(4) when (spr_fiss_pri_rand_always or (spr_fiss_pri_rand_flush and or_reduce(xu_iu_is2_flush(0 to 3)))) = '1' else hi_did2no1_din;
hi_did1no0_d     <=  pri_rand(5) when (spr_fiss_pri_rand_always or (spr_fiss_pri_rand_flush and or_reduce(xu_iu_is2_flush(0 to 3)))) = '1' else hi_did1no0_din;
md_did3no0_d     <=  pri_rand(0) when (spr_fiss_pri_rand_always or (spr_fiss_pri_rand_flush and or_reduce(xu_iu_is2_flush(0 to 3)))) = '1' else md_did3no0_din;
md_did3no1_d     <=  pri_rand(1) when (spr_fiss_pri_rand_always or (spr_fiss_pri_rand_flush and or_reduce(xu_iu_is2_flush(0 to 3)))) = '1' else md_did3no1_din;
md_did3no2_d     <=  pri_rand(2) when (spr_fiss_pri_rand_always or (spr_fiss_pri_rand_flush and or_reduce(xu_iu_is2_flush(0 to 3)))) = '1' else md_did3no2_din;
md_did2no0_d     <=  pri_rand(3) when (spr_fiss_pri_rand_always or (spr_fiss_pri_rand_flush and or_reduce(xu_iu_is2_flush(0 to 3)))) = '1' else md_did2no0_din;
md_did2no1_d     <=  pri_rand(4) when (spr_fiss_pri_rand_always or (spr_fiss_pri_rand_flush and or_reduce(xu_iu_is2_flush(0 to 3)))) = '1' else md_did2no1_din;
md_did1no0_d     <=  pri_rand(5) when (spr_fiss_pri_rand_always or (spr_fiss_pri_rand_flush and or_reduce(xu_iu_is2_flush(0 to 3)))) = '1' else md_did1no0_din;

pri_rand(0 TO 5) <=  "001000" when spr_fiss_pri_rand(0 to 4) = "00000" else  
                    "100111" when spr_fiss_pri_rand(0 to 4) = "00001" else  
                    "110111" when spr_fiss_pri_rand(0 to 4) = "00010" else  
                    "000001" when spr_fiss_pri_rand(0 to 4) = "00011" else  
                    "000110" when spr_fiss_pri_rand(0 to 4) = "00100" else  
                    "001001" when spr_fiss_pri_rand(0 to 4) = "00101" else  
                    "011000" when spr_fiss_pri_rand(0 to 4) = "00110" else  
                    "111101" when spr_fiss_pri_rand(0 to 4) = "00111" else  
                    "100101" when spr_fiss_pri_rand(0 to 4) = "01000" else  
                    "010110" when spr_fiss_pri_rand(0 to 4) = "01001" else  
                    "101101" when spr_fiss_pri_rand(0 to 4) = "01010" else  
                    "111110" when spr_fiss_pri_rand(0 to 4) = "01011" else  
                    "110110" when spr_fiss_pri_rand(0 to 4) = "01100" else  
                    "101001" when spr_fiss_pri_rand(0 to 4) = "01101" else  
                    "000000" when spr_fiss_pri_rand(0 to 4) = "01110" else  
                    "111010" when spr_fiss_pri_rand(0 to 4) = "01111" else  
                    "000111" when spr_fiss_pri_rand(0 to 4) = "10000" else  
                    "111001" when spr_fiss_pri_rand(0 to 4) = "10001" else  
                    "111000" when spr_fiss_pri_rand(0 to 4) = "10010" else  
                    "011010" when spr_fiss_pri_rand(0 to 4) = "10011" else  
                    "111111" when spr_fiss_pri_rand(0 to 4) = "10100" else  
                    "010010" when spr_fiss_pri_rand(0 to 4) = "10101" else  
                    "000010" when spr_fiss_pri_rand(0 to 4) = "10110" else  
                    "000101" when spr_fiss_pri_rand(0 to 4) = "10111" else  
                    "111111" when spr_fiss_pri_rand(0 to 4) = "11000" else  
                    "000000" when spr_fiss_pri_rand(0 to 4) = "11001" else  
                    "011010" when spr_fiss_pri_rand(0 to 4) = "11010" else  
                    "100101" when spr_fiss_pri_rand(0 to 4) = "11011" else  
                    "001001" when spr_fiss_pri_rand(0 to 4) = "11100" else  
                    "110110" when spr_fiss_pri_rand(0 to 4) = "11101" else  
                    "000111" when spr_fiss_pri_rand(0 to 4) = "11110" else  
                    "111000" ;



                   
----------------------------------------------------------------------------------
---RF0 latches -------------------------------------------------------------------
----------------------------------------------------------------------------------

   rf0_took_latch:  tri_rlmreg_p --init to 000001000001
    generic map (init => 65, expand_type => expand_type, needs_sreset => needs_sreset,  width => 12)
    port map (
      nclk     => nclk,          act      => tiup,
      vd       => vdd,           gd       => gnd,      
      forcee => forcee,         delay_lclkr => delay_lclkr, 
      thold_b  => pc_iu_func_sl_thold_0_b,     sg       => pc_iu_sg_0,
      mpw1_b      => mpw1_b,
      mpw2_b      => mpw2_b,          
      scin     => rf0_took_latch_scin,
      scout    => rf0_took_latch_scout,
      ---------------------------------------------
      din(00)  => hi_did3no0_d,
      din(01)  => hi_did3no1_d,
      din(02)  => hi_did3no2_d,
      din(03)  => hi_did2no0_d,
      din(04)  => hi_did2no1_d,
      din(05)  => hi_did1no0_d,
      din(06)  => md_did3no0_d,
      din(07)  => md_did3no1_d,
      din(08)  => md_did3no2_d,
      din(09)  => md_did2no0_d,
      din(10)  => md_did2no1_d,
      din(11)  => md_did1no0_d,
                                                                     
      ---------------------------------------------
      dout(00) => hi_did3no0,
      dout(01) => hi_did3no1,
      dout(02) => hi_did3no2,
      dout(03) => hi_did2no0,
      dout(04) => hi_did2no1,
      dout(05) => hi_did1no0,
      dout(06) => md_did3no0,
      dout(07) => md_did3no1,
      dout(08) => md_did3no2,
      dout(09) => md_did2no0,
      dout(10) => md_did2no1,
      dout(11) => md_did1no0
                                                      
      ---------------------------------------------
      );



----------------------------------------------------------------------------------

   
is2_act <= is2_instr_v or is2_act_l2;

----------------------------------------------------------------------------------
   rf0_stage_latch:  tri_rlmreg_p
    generic map (init => 0, expand_type => expand_type, needs_sreset => needs_sreset,  width => 77+EFF_IFAR'length)
    port map (
      nclk     => nclk,                  act      => is2_act,
      vd       => vdd,                   gd       => gnd,      
      forcee => forcee,                 delay_lclkr => delay_lclkr, 
      thold_b  => pc_iu_func_sl_thold_0_b, sg       => pc_iu_sg_0,
      mpw1_b      => mpw1_b,
      mpw2_b      => mpw2_b,          
      scin     => rf0_stage_latch_scin,
      scout    => rf0_stage_latch_scout,
      ---------------------------------------------

      din(00 to 31)  => iu_fu_is2_instr(0 to 31),
      din(32      )  => iu_fu_is2_instr_v,
      din(33      )  => is2_is_ucode,
      din(34      )  => iu_fu_is2_fra_v,
      din(35 to 41)  => iu_fu_is2_fra(0 to 6),
      din(42      )  => iu_fu_is2_frb_v,
      din(43 to 49)  => iu_fu_is2_frb(0 to 6),
      din(50      )  => iu_fu_is2_frc_v,      
      din(51 to 57)  => iu_fu_is2_frc(0 to 6),
      din(58      )  => iu_fu_is2_ucfmul,      
      din(59 to 65)  => iu_fu_is2_frt(0 to 6),
      din(66      )  => spare_l2(0),
      din(67      )  => spare_l2(1),               
      din(68      )  => iu_fu_is2_instr_match,  
      din(69 to 70)  => iu_fu_is2_tid(0 to 1),     
      din(71 to 76)  => iu_fu_is2_bypsel_din(0 to 5),  
      din(77 to 76+EFF_IFAR'length)  => is2_ifar,    

      ---------------------------------------------
      dout(00 to 31)  => iu_fu_rf0_instr(0 to 31),
      dout(32      )  => iu_fu_rf0_instr_v,
      dout(33      )  => iu_fu_rf0_is_ucode,
      dout(34      )  => iu_fu_rf0_fra_v,
      dout(35 to 41)  => iu_fu_rf0_fra(0 to 6),
      dout(42      )  => iu_fu_rf0_frb_v,   
      dout(43 to 49)  => iu_fu_rf0_frb(0 to 6),
      dout(50      )  => iu_fu_rf0_frc_v,   
      dout(51 to 57)  => iu_fu_rf0_frc(0 to 6),
      dout(58      )  => iu_fu_rf0_ucfmul,      
      dout(59 to 65)  => iu_fu_rf0_frt(0 to 6),
      dout(66 to 67)  => spare_l2(0 to 1),      
      dout(68      )  => iu_fu_rf0_instr_match, 
      dout(69 to 70)  => rf0_tid(0 to 1),     
      dout(71 to 76)  => iu_fu_rf0_bypsel(0 to 5),  
      dout(77 to 76+EFF_IFAR'length)  => rf0_ifar    

      ---------------------------------------------
      );

iu_fu_rf0_ifar <= rf0_ifar;
iu_fu_rf0_tid <= rf0_tid;

spare_unused(0 to 1) <= tidn & tidn;

----------------------------------------------------------------------------------


                      
                                            
 --shadow pipe latches
 ---------------------------------------------
 ---------------------------------------------

   rf0_wpc_sp_latch:  tri_rlmreg_p
    generic map (init => 0, expand_type => expand_type, needs_sreset => needs_sreset,  width => 5)
    port map (
      nclk     => nclk,                  act      => tiup,
      vd       => vdd,                   gd       => gnd,     
      forcee => forcee,                 delay_lclkr => delay_lclkr, 
      thold_b  => pc_iu_func_sl_thold_0_b, sg       => pc_iu_sg_0,
      mpw1_b      => mpw1_b,
      mpw2_b      => mpw2_b,           
      scin     => rf0_wpc_sp_latch_scin,
      scout    => rf0_wpc_sp_latch_scout ,
      ---------------------------------------------
      din(0)  => is2_act_din,              
      din(1)  => spare_l2(2),
      din(2)  => spare_l2(3),
      din(3)  => spare_l2(4),
      din(4)  => spare_l2(5),
                              
      ---------------------------------------------
      dout(0) => is2_act_l2,
      dout(1) => spare_l2(2),
      dout(2) => spare_l2(3),
      dout(3) => spare_l2(4),
      dout(4) => spare_l2(5)

      ---------------------------------------------
      );

     disable_cgat <= i_afd_config_iucr_t0(4) or i_afd_config_iucr_t1(4) or i_afd_config_iucr_t2(4) or i_afd_config_iucr_t3(4);
     is2_act_din <= is2_instr_v or disable_cgat; 
      
     spare_unused(2) <= d_mode;
     spare_unused(3 to 6) <= tidn & tidn & tidn & tidn;
     spare_unused(8) <= tidn;  

----------------------------------------------------------------------------------
   debug_reg:  tri_rlmreg_p
    generic map (init => 0, expand_type => expand_type, needs_sreset => needs_sreset,  width => 5)
    port map (
      nclk     => nclk,                  act      => tiup,
      vd       => vdd,                   gd       => gnd,      
      forcee => forcee,                 delay_lclkr => delay_lclkr,  
      thold_b  => pc_iu_func_sl_thold_0_b, sg       => pc_iu_sg_0,
      mpw1_b      => mpw1_b,
      mpw2_b      => mpw2_b,          
      scin     => debug_reg_scin,
      scout    => debug_reg_scout,
      ---------------------------------------------
      din(0 to 3)  => is2_issue_sel(0 to 3),
      din(4)  => spare_l2(6),
                              
      ---------------------------------------------
      dout(0 to 3) => is2_issue_sel_db(0 to 3),
      dout(4) => spare_l2(6)

      ---------------------------------------------
      );
      
spare_unused(7) <= tidn;

----------------------------------------------------------------------------------


 
  

single_step_mode <= i_afd_config_iucr_t0(2) and i_afd_config_iucr_t1(2) and i_afd_config_iucr_t2(2) and i_afd_config_iucr_t3(2);
single_step_divsqrt_mode <= i_afd_config_iucr_t0(3) and i_afd_config_iucr_t1(3) and i_afd_config_iucr_t2(3) and i_afd_config_iucr_t3(3);

divsqrt_mode <= ((not i_afd_in_ucode_mode_or1d_b_t0) or
                 (not i_afd_in_ucode_mode_or1d_b_t1) or
                 (not i_afd_in_ucode_mode_or1d_b_t2) or
                 (not i_afd_in_ucode_mode_or1d_b_t3));               

-- this inserts a bubble in the pipe following the fp operation
        is2_insert_one_bubble    <= '0';  -- reserved
        spare_unused(09) <= is2_insert_one_bubble;
          
        is2_insert_two_bubbles   <= '0';  -- reserved
        spare_unused(10) <= is2_insert_two_bubbles;
        
 -- this inserts 3 bubbles in the pipe following the fp operation
        is2_insert_three_bubbles <= ((ifdp_is2_est_bubble3_t0 and is2_issue_sel(0)) or
                                     (ifdp_is2_est_bubble3_t1 and is2_issue_sel(1)) or
                                     (ifdp_is2_est_bubble3_t2 and is2_issue_sel(2)) or
                                     (ifdp_is2_est_bubble3_t3 and is2_issue_sel(3)));
         
        is2_insert_seven_bubbles <= (single_step_mode and or_reduce(is2_issue_sel(0 to 3))) or
                                    (single_step_divsqrt_mode and or_reduce(is2_issue_sel(0 to 3)) and divsqrt_mode);
        


skip_din(0) <= or_reduce(bubble_din(2 to 4));      
skip_din(1) <= or_reduce(bubble_din(2 to 4));
skip_din(2) <= or_reduce(bubble_din(2 to 4));      
skip_din(3) <= or_reduce(bubble_din(2 to 4));



--@@ ESPRESSO TABLE START @@
-- .i 5
-- .o 3
-- .ilb is2_insert_three_bubbles is2_insert_seven_bubbles bubble_dout(2) bubble_dout(3) bubble_dout(4)
-- .ob bubble_din(2)  bubble_din(3) bubble_din(4)
-- .type fd
--#
--#3 7 234   234
-- #######################################################################
-- 0 0 111   110
-- 0 0 110   101
-- 0 0 101   100
-- 0 0 100   011
-- 0 0 011   010
-- 0 0 010   001
-- 0 0 001   000
-- 0 0 000   000
--
-- 1 0 ---   011
-- 0 1 ---   111
-- 1 1 ---   111


-- #######################################################################
-- .e
--@@ ESPRESSO TABLE END @@

--@@ ESPRESSO LOGIC START @@
-- logic generated on: Mon May  5 10:46:28 2008
bubble_din(2) <= (not is2_insert_three_bubbles and  bubble_dout(2)
		 and  bubble_dout(3)) or
		(not is2_insert_three_bubbles and  bubble_dout(2)
		 and  bubble_dout(4)) or
		( is2_insert_seven_bubbles);

bubble_din(3) <= ( bubble_dout(2) and not bubble_dout(3) and not bubble_dout(4)) or
		( bubble_dout(3) and  bubble_dout(4)) or
		( is2_insert_three_bubbles) or
		( is2_insert_seven_bubbles);

bubble_din(4) <= ( bubble_dout(2) and not bubble_dout(4)) or
		( bubble_dout(3) and not bubble_dout(4)) or
		( is2_insert_three_bubbles) or
		( is2_insert_seven_bubbles);

--@@ ESPRESSO LOGIC END @@
--




is2_bubble_latch:  tri_rlmreg_p 
    generic map (init => 0, expand_type => expand_type, needs_sreset => needs_sreset,  width => 3)
    port map (
      nclk     => nclk,          act      => tiup,
      vd       => vdd,           gd       => gnd,     
      forcee => forcee,         delay_lclkr => delay_lclkr,  
      thold_b  => pc_iu_func_sl_thold_0_b,     sg       => pc_iu_sg_0,
      mpw1_b      => mpw1_b,
      mpw2_b      => mpw2_b,          
      scin     => is2_bubble_latch_scin,
      scout    => is2_bubble_latch_scout,
      ---------------------------------------------
      din(0 to 2)  => bubble_din,
      ---------------------------------------------
      dout(0 to 2) => bubble_dout
      ---------------------------------------------
    );



is2_skip_latch:  tri_rlmreg_p 
    generic map (init => 0, expand_type => expand_type, needs_sreset => needs_sreset,  width => 4)
    port map (
      nclk     => nclk,          act      => tiup,
      vd       => vdd,           gd       => gnd,     
      forcee => forcee,         delay_lclkr => delay_lclkr,  
      thold_b  => pc_iu_func_sl_thold_0_b,     sg       => pc_iu_sg_0,
      mpw1_b      => mpw1_b,
      mpw2_b      => mpw2_b,          
      scin     => is2_skip_latch_scin,
      scout    => is2_skip_latch_scout,
      ---------------------------------------------
      din(0 to 3)  => skip_din,
      ---------------------------------------------
      dout(0 to 3) => skip_dout
      ---------------------------------------------
    );
----------------------------------------------------------------------------------
 
 iu_fu_is2_bypsel <= (i_afd_is2_bypsel_t0 and (0 to 5 => is2_issue_sel_buf4(0))) or   
                     (i_afd_is2_bypsel_t1 and (0 to 5 => is2_issue_sel_buf4(1))) or   
                     (i_afd_is2_bypsel_t2 and (0 to 5 => is2_issue_sel_buf4(2))) or   
                     (i_afd_is2_bypsel_t3 and (0 to 5 => is2_issue_sel_buf4(3)))  ;  
                    
                   
 iu_fu_is2_bypsel_din <= iu_fu_is2_bypsel; 




fu_iss_debug(0 to 23) <= highpri_v(0 to 3) & medpri_v(0 to 3) &
                         hi_did3no0 &
                         hi_did3no1 &
                         hi_did3no2 &
                         hi_did2no1 &
                         hi_did2no0 &
                         hi_did1no0 &
                         md_did3no0 &
                         md_did3no1 &
                         md_did3no2 &
                         md_did2no1 &
                         md_did2no0 &
                         md_did1no0 &                         
                         is2_issue_sel_db(0 to 3); 


                   
-- scan chain ***********************************************************************************
         
is2v_scin(0 to 3) <= i_iss_si      & is2v_scout(0 to 2);
mask_scin(0 to 7) <= is2v_scout(3) & mask_scout(0 to 6);

rf0_took_latch_scin(0 to 11) <= mask_scout(7) & rf0_took_latch_scout(0 to 10);

rf0_stage_latch_scin(0 to 76+EFF_IFAR'length)  <=  rf0_took_latch_scout(11)   &   rf0_stage_latch_scout(0 to 75+EFF_IFAR'length);

rf0_wpc_sp_latch_scin <= rf0_stage_latch_scout(76+EFF_IFAR'length)  & rf0_wpc_sp_latch_scout(0 to 3); 


debug_reg_scin(0 to 4) <= rf0_wpc_sp_latch_scout(4) & debug_reg_scout(0 to 3); 


is2_bubble_latch_scin <= debug_reg_scout(4) & is2_bubble_latch_scout(0 to 1);
is2_skip_latch_scin <= is2_bubble_latch_scout(2) & is2_skip_latch_scout(0 to 2);


i_iss_so  <= is2_skip_latch_scout(3) and an_ac_scan_dis_dc_b; 


end iuq_axu_fu_iss;
