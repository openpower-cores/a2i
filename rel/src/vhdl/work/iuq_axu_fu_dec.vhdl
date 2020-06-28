-- © IBM Corp. 2020
-- This softcore is licensed under and subject to the terms of the CC-BY 4.0
-- license (https://creativecommons.org/licenses/by/4.0/legalcode). 
-- Additional rights, including the right to physically implement a softcore 
-- that is compliant with the required sections of the Power ISA 
-- Specification, will be available at no cost via the OpenPOWER Foundation. 
-- This README will be updated with additional information when OpenPOWER's 
-- license is available.







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




entity iuq_axu_fu_dec is
generic(
        expand_type                             : integer := 2; 
        fpr_addr_width                          : integer := 5;
        needs_sreset                            : integer := 1);  
port(
   	nclk                                 	: in clk_logic;                
        vdd                                 	: inout power_logic;
        gnd                                 	: inout power_logic;

   	i_dec_si                            	: in std_ulogic;
   	i_dec_so                           	: out std_ulogic;
   
        pc_iu_sg_0                         	: in std_ulogic;
   	pc_iu_func_sl_thold_0_b            	: in std_ulogic;
   	forcee : in std_ulogic;
   	d_mode                             	: in std_ulogic;
   	delay_lclkr                        	: in std_ulogic;
   	mpw1_b                             	: in std_ulogic;
        mpw2_b                             	: in std_ulogic;
        
        pc_au_ram_mode                     	: in  std_ulogic;
        pc_au_ram_thread_v                 	: in  std_ulogic;
        
        iu_au_is0_instr_v                  	: in  std_ulogic;
        iu_au_is0_instr                  	: in  std_ulogic_vector(0 to 31);
        iu_au_is0_ucode_ext                  	: in  std_ulogic_vector(0 to 3);  
        iu_au_is0_is_ucode                      : in  std_ulogic;   
        iu_au_is0_2ucode                     	: in  std_ulogic;
        iu_au_ucode_restart                    	: in  std_ulogic;
        
        iu_au_is0_cr_setter                    	: in  std_ulogic;  

        iu_au_is1_stall                     	: in  std_ulogic;
        iu_au_is0_flush                        	: in  std_ulogic;
        iu_au_is1_flush                        	: in  std_ulogic;

        iu_au_config_iucr                       : in  std_ulogic_vector(0 to 7);  
        ifdp_ex5_fmul_uc_complete               : in  std_ulogic; 

        au_iu_is0_i_dec_b                  	        : out  std_ulogic;  
        au_iu_is0_to_ucode                  	        : out  std_ulogic;   
        au_iu_is0_ucode_only       	                : out  std_ulogic; 

        au_iu_is0_ldst                     	  : out  std_ulogic;  
        au_iu_is0_ldst_v                     	  : out  std_ulogic;  
        au_iu_is0_st_v                     	  : out  std_ulogic;  
        au_iu_is0_mftgpr                          : out  std_ulogic;
        au_iu_is0_mffgpr                          : out  std_ulogic;
        au_iu_is0_movedp                          : out  std_ulogic;
        au_iu_is0_ldst_extpid                     : out  std_ulogic;
        au_iu_is0_instr_type                      : out  std_ulogic_vector(0 to 2);
        au_iu_is0_ldst_size                       : out  std_ulogic_vector(0 to 5);  
        au_iu_is0_ldst_tag                        : out  std_ulogic_vector(0 to 8);
        au_iu_is0_ldst_ra_v                       : out  std_ulogic;
        au_iu_is0_ldst_ra                         : out  std_ulogic_vector(0 to 6);
        au_iu_is0_ldst_rb_v                       : out  std_ulogic;
        au_iu_is0_ldst_rb                         : out  std_ulogic_vector(0 to 6);
        au_iu_is0_ldst_dimm                       : out  std_ulogic_vector(0 to 15);
        au_iu_is0_ldst_indexed                    : out  std_ulogic;
        au_iu_is0_ldst_update                     : out  std_ulogic;
        au_iu_is0_ldst_forcealign                 : out  std_ulogic; 
        au_iu_is0_ldst_forceexcept                : out  std_ulogic; 
        i_afd_is1_is_ucode                      : out  std_ulogic;      
        i_afd_is1_to_ucode                      : out  std_ulogic;

        i_afd_in_ucode_mode_or1d                : out  std_ulogic; 
        
        i_afd_config_iucr                       : out  std_ulogic_vector(1 to 7);  
         i_afd_fmul_uc_is1                      : out  std_ulogic;
         
        i_afd_is1_fra_v                     	: out  std_ulogic;                
        i_afd_is1_frb_v                     	: out  std_ulogic;                
        i_afd_is1_frc_v                     	: out  std_ulogic;
        i_afd_is1_frt_v                     	: out  std_ulogic;
        i_afd_is1_prebubble1                    : out  std_ulogic;               
        i_afd_is1_est_bubble3                   : out  std_ulogic;

        i_afd_is1_cr_setter                     : out  std_ulogic;  
        i_afd_is1_cr_writer                     : out  std_ulogic;  
              
        i_afd_is1_fra                     	: out  std_ulogic_vector(0 to 6);                
        i_afd_is1_frb                     	: out  std_ulogic_vector(0 to 6);                
        i_afd_is1_frc                     	: out  std_ulogic_vector(0 to 6);    
        i_afd_is1_frt                     	: out  std_ulogic_vector(0 to 6);
        i_afd_is1_fra_buf                       : out  std_ulogic_vector(1 to 6);  
        i_afd_is1_frb_buf                       : out  std_ulogic_vector(1 to 6);  
        i_afd_is1_frc_buf                       : out  std_ulogic_vector(1 to 6);  
        i_afd_is1_frt_buf                       : out  std_ulogic_vector(1 to 6);  
        
        i_afd_is1_instr_v                     	: out  std_ulogic;

        i_afd_is1_instr_ldst_v                  : out  std_ulogic;                   
        i_afd_is1_instr_ld_v                    : out  std_ulogic;                   
        i_afd_is1_instr_sto_v                   : out  std_ulogic;  

        i_afd_ignore_flush_is1                  : out  std_ulogic;
        
        i_afd_is1_divsqrt                        : out  std_ulogic; 
        i_afd_is1_stall_rep                      : out  std_ulogic; 

        fu_dec_debug                            : out  std_ulogic_vector(0 to 13)       
);




  
end iuq_axu_fu_dec;


architecture iuq_axu_fu_dec of iuq_axu_fu_dec is

  signal  tidn                           : std_ulogic;
  signal  tiup                           : std_ulogic;



  signal iu_au_config_iucr_int           : std_ulogic_vector(0 to 7);
  signal iu_au_config_iucr_l2           : std_ulogic_vector(0 to 7);
  signal iu_au_config_iucr_din           : std_ulogic_vector(0 to 7);
  signal is0_instr : std_ulogic_vector(00 to 31);        
  signal pri_is0 : std_ulogic_vector(0 to 5);    
  signal sec_is0 : std_ulogic_vector(20 to 31);  
  signal av,bv,cv,tv : std_ulogic;       
  signal isfu_dec_is0, ld_st_is0 : std_ulogic;      
  
  signal st_is0, indexed, fdiv_is0, fsqrt_is0: std_ulogic;
  signal update_form, forcealign  : std_ulogic;  
  signal cr_writer   : std_ulogic;
  signal is1_st   : std_ulogic;
  signal is1_ldst   : std_ulogic;
  signal is1_fra_v   : std_ulogic;
  signal is1_frb_v   : std_ulogic;
  signal is1_frc_v   : std_ulogic;
  signal is1_frt_v   : std_ulogic;

  
  signal is0_instr_v   : std_ulogic;
  signal ucode_restart   : std_ulogic;  
  signal is1_instr_v   : std_ulogic;
  signal   is1_cr_setter : std_ulogic;
  signal   is1_cr_writer : std_ulogic;
  signal   is1_is_ucode : std_ulogic;
  signal   is1_to_ucode : std_ulogic;
      
  signal mffgpr, mftgpr   : std_ulogic; 
  signal bubble3,prebubble1  :std_ulogic;
  signal ldst_tag  :std_ulogic_vector(0 to 8);
  signal ldst_tag_addr  :std_ulogic_vector(0 to 5);
  signal is0_to_ucode              : std_ulogic;


  signal cmd_is0_ld, cmd_is1_l2, cmd_is1_scin, cmd_is1_scout    : std_ulogic_vector(6 to 53);

  signal config_reg_scin  : std_ulogic_vector(0 to 7);
  signal config_reg_scout  : std_ulogic_vector(0 to 7);
  
 
  signal size : std_ulogic_vector(0 to 5);
  signal spare_unused : std_ulogic_vector(2 to 49);

  signal is0_is_ucode, in_ucode_mode,in_fdivsqrt_mode_is0,  only_from_ucode, only_graphics_mode ,graphics_mode  : std_ulogic;
  signal is0_invalid_kill, is0_invalid_kill_uc    : std_ulogic;  
  signal is0_in_divsqrt_mode_or1d,is1_in_divsqrt_mode_or1d : std_ulogic;

  signal ldst_extpid    : std_ulogic;
  signal single_precision_ldst  :std_ulogic;
  signal int_word_ldst  :std_ulogic;
  signal sign_ext_ldst  :std_ulogic;  
  signal is1_stall, is1_stall_b  :std_ulogic;
  signal io_port, io_port_ext  :std_ulogic;

  signal ignore_flush_is0 : std_ulogic;
  signal ucmodelat_din, ucmodelat_dout : std_ulogic;
  signal  final_fmul_uc : std_ulogic;
  signal is1_fmul_uc : std_ulogic;

  signal is0_st_or_mtdp  :std_ulogic;
  signal is0_mftgpr   :std_ulogic;
  signal is0_usual_fra   :std_ulogic;
  signal is0_kill_or_divsqrt_b  :std_ulogic;
  signal au_iu_is0_i_dec : std_ulogic;
  signal is0_i_dec_b : std_ulogic;

  signal is0_frt                        : std_ulogic_vector(0 to 5);
  signal is0_fra_or_frs                 : std_ulogic_vector(0 to 5);
  signal tag_in_16to20,mftgpr_not_DITC :std_ulogic;
  signal cmd_is0_40_part :std_ulogic;
  signal cmd_is0_41_part :std_ulogic;
  signal cmd_is0_43_part :std_ulogic;
  signal cmd_is0_50_part :std_ulogic;

  signal is1_frt_buf, is1_frt_buf_b                  : std_ulogic_vector(1 to 6);
  signal is1_fra_buf, is1_fra_buf_b                  : std_ulogic_vector(1 to 6);
  signal is1_frb_buf, is1_frb_buf_b                  : std_ulogic_vector(1 to 6);
  signal is1_frc_buf, is1_frc_buf_b                  : std_ulogic_vector(1 to 6);  

   signal is0_ins, is0_ins_b, is0_ins_dly,  is0_ins_dly_b :std_ulogic_vector(0 to 31);
   signal is0_ins_v, is0_ins_v_b :std_ulogic;
   signal is1_v_nstall1_b, is1_v_nstall2_b :std_ulogic;
   signal is1_v_nstall1, is1_v_nstall2,is1_v_nstall3,is1_v_nstall4,is1_v_nstall5,is1_v_nstall6,is1_v_nstall7,is1_v_nstall8 :std_ulogic;   
   
   signal is1_v_nstall01_INVA_b, is1_v_nstall01_INVB  :std_ulogic;
   signal is1_v_nstall02_INVA_b, is1_v_nstall02_INVB  :std_ulogic;
   signal is1_v_nstall03_INVA_b, is1_v_nstall03_INVB  :std_ulogic;
   signal is1_v_nstall04_INVA_b, is1_v_nstall04_INVB  :std_ulogic;
   signal is1_v_nstall05_INVA_b, is1_v_nstall05_INVB  :std_ulogic;
   signal is1_v_nstall06_INVA_b, is1_v_nstall06_INVB  :std_ulogic;
   signal is1_v_nstall07_INVA_b, is1_v_nstall07_INVB  :std_ulogic;
   signal is1_v_nstall08_INVA_b, is1_v_nstall08_INVB  :std_ulogic;
   signal is1_v_nstall09_INVA_b, is1_v_nstall09_INVB  :std_ulogic;
   signal is1_v_nstall10_INVA_b, is1_v_nstall10_INVB  :std_ulogic;
   signal is1_v_nstall11_INVA_b, is1_v_nstall11_INVB  :std_ulogic;
   signal is1_v_nstall12_INVA_b, is1_v_nstall12_INVB  :std_ulogic;
   signal is1_v_nstall13_INVA_b, is1_v_nstall13_INVB  :std_ulogic;
   signal is1_v_nstall14_INVA_b, is1_v_nstall14_INVB  :std_ulogic;
   signal is1_v_nstall15_INVA_b, is1_v_nstall15_INVB  :std_ulogic;
   signal is1_v_nstall16_INVA_b, is1_v_nstall16_INVB  :std_ulogic;
   signal is1_v_nstall17_INVA_b, is1_v_nstall17_INVB  :std_ulogic;
   signal is1_v_nstall18_INVA_b, is1_v_nstall18_INVB  :std_ulogic;
   signal is1_v_nstall19_INVA_b, is1_v_nstall19_INVB  :std_ulogic;
   signal is1_v_nstall20_INVA_b, is1_v_nstall20_INVB  :std_ulogic;
   signal is1_v_nstall21_INVA_b, is1_v_nstall21_INVB  :std_ulogic;
   signal is1_v_nstall22_INVA_b, is1_v_nstall22_INVB  :std_ulogic;
   signal is1_v_nstall23_INVA_b, is1_v_nstall23_INVB  :std_ulogic;
   signal is1_v_nstall24_INVA_b, is1_v_nstall24_INVB  :std_ulogic;
   signal is1_v_nstall25_INVA_b, is1_v_nstall25_INVB  :std_ulogic;
   signal is1_v_nstall26_INVA_b, is1_v_nstall26_INVB  :std_ulogic;
   signal is1_v_nstall27_INVA_b, is1_v_nstall27_INVB  :std_ulogic;
   signal is1_v_nstall28_INVA_b, is1_v_nstall28_INVB  :std_ulogic;
   signal is1_v_nstall29_INVA_b, is1_v_nstall29_INVB  :std_ulogic;
   signal is1_v_nstall30_INVA_b, is1_v_nstall30_INVB  :std_ulogic;
   signal is1_v_nstall31_INVA_b, is1_v_nstall31_INVB  :std_ulogic;
   signal is1_v_nstall32_INVA_b, is1_v_nstall32_INVB  :std_ulogic;

   signal ram_mode_v :std_ulogic;
   
   signal cmd_is0_go_b, cmd_is1_ho_b :std_ulogic_vector(6 to 53); 
signal iu_au_is0_flush_b, iu_au_is1_flush_b :std_ulogic;










    
                


  

  



      
                        





   
                             
  begin
  

   tidn      <= '0';
   tiup      <= '1';
   
   is1_stall <= iu_au_is1_stall;
   

   is0_instr <= iu_au_is0_instr;
   is0_instr_v  <= iu_au_is0_instr_v;
   ucode_restart <= iu_au_ucode_restart;
   spare_unused(48) <= tidn;

   pri_is0(0 to 5)   <= is0_instr(0 to 5);
   sec_is0(20 to 31) <= is0_instr(20 to 31);


   spare_unused(49) <= d_mode;

iu_au_is1_stall_INV:   is1_stall_b <= not iu_au_is1_stall;
   
is0_ins_inv:     is0_ins_b(0 to 31)     <= not( iu_au_is0_instr(0 to 31) );
is0_ins_buf:     is0_ins  (0 to 31)     <= not( is0_ins_b      (0 to 31) );
is0_ins_inv_dly: is0_ins_dly_b(0 to 31) <= not( is0_ins        (0 to 31) ); 
is0_ins_buf_dly: is0_ins_dly  (0 to 31) <= not( is0_ins_dly_b  (0 to 31) );
is0_ins_v_inv:   is0_ins_v_b            <= not( iu_au_is0_instr_v );
is0_ins_v_buf:   is0_ins_v              <= not( is0_ins_v_b        );

spare_unused(12 to 27) <= is0_ins_dly(0 to 15);
spare_unused(28 to 33) <= is0_ins_dly(26 to 31);

   

   
                                                                                                                      
                                                                                                                      
                                                                                                                      
                                                                                                                      
                                                                                                                      




                                                                                                                               


                                                                                                                               





                
                                                                                                                      
                                                                                                                      
                                                                                                                      
                                                                                                                      
                                                                                                                      
                                                                                                                      
                                                                                                                      
                                                                                                                      
                                                                                                                      
                                                                                                                      
                                                                                                                      
                                                                                                                      
                                                                                                                      
                                                                                                                      
                                                                                                                      
                                                                                                                      
                                                                                                                      
                                                                                                                      
                                                                                                                      
                                                                                                                      
                                                                                                                      
                                                                                                                      
                                                                                                                      
                                                                                                                      
                                                                                                                      
                                                                                                                      
                                                                                                                      
                                                                                                                      
                                                                                                                      
                                                                                                                      
                                                                                                                      
                                                                                                                      
                                                                                                                      
                                                                                                                      
                                                                                                                      
                                                                                                                      
                                                                                                                      
                                                                                                                      
                                                                                                                      
                                                                                                                      
                                                                                                                      
                                                                                                                      
                                                                                                                      


isfu_dec_is0 <= ( pri_is0(0) and  pri_is0(1) and  pri_is0(3) and  pri_is0(4)
		 and  pri_is0(5) and not sec_is0(21) and not sec_is0(22)
		 and not sec_is0(23) and not sec_is0(24) and not sec_is0(25)
		 and  sec_is0(27) and not sec_is0(29) and not sec_is0(30)) or
		( pri_is0(0) and  pri_is0(1) and  pri_is0(4) and  pri_is0(5)
		 and  sec_is0(26) and  sec_is0(28) and not sec_is0(30)) or
		( pri_is0(0) and  pri_is0(1) and  pri_is0(3) and  pri_is0(4)
		 and  pri_is0(5) and  sec_is0(26) and not sec_is0(30)) or
		( pri_is0(0) and  pri_is0(1) and  pri_is0(4) and  pri_is0(5)
		 and  sec_is0(26) and  sec_is0(27) and not sec_is0(30)) or
		(not pri_is0(0) and  pri_is0(1) and  pri_is0(2) and  pri_is0(3)
		 and  pri_is0(4) and  pri_is0(5) and  sec_is0(20)
		 and not sec_is0(21) and not sec_is0(22) and not sec_is0(23)
		 and not sec_is0(26) and not sec_is0(27) and not sec_is0(28)
		 and  sec_is0(29) and  sec_is0(30)) or
		( pri_is0(0) and  pri_is0(1) and  pri_is0(4) and  pri_is0(5)
		 and  sec_is0(21) and  sec_is0(22) and  sec_is0(24)
		 and not sec_is0(25) and  sec_is0(27) and  sec_is0(28)
		 and  sec_is0(29) and not sec_is0(30)) or
		( pri_is0(0) and  pri_is0(1) and not pri_is0(3) and  pri_is0(4)
		 and  pri_is0(5) and not sec_is0(21) and not sec_is0(22)
		 and  sec_is0(23) and  sec_is0(24) and not sec_is0(27)
		 and  sec_is0(28) and not sec_is0(29) and  sec_is0(30)
		 and not sec_is0(31)) or
		( pri_is0(0) and  pri_is0(1) and  pri_is0(3) and  pri_is0(4)
		 and  pri_is0(5) and not sec_is0(21) and  sec_is0(22)
		 and  sec_is0(23) and  sec_is0(27) and not sec_is0(28)
		 and not sec_is0(29) and not sec_is0(30)) or
		( pri_is0(0) and  pri_is0(1) and  pri_is0(3) and  pri_is0(4)
		 and  pri_is0(5) and  sec_is0(21) and  sec_is0(22)
		 and not sec_is0(24) and  sec_is0(25) and  sec_is0(27)
		 and  sec_is0(28) and  sec_is0(29)) or
		( pri_is0(0) and  pri_is0(1) and  pri_is0(3) and  pri_is0(4)
		 and  pri_is0(5) and not sec_is0(21) and not sec_is0(24)
		 and not sec_is0(25) and  sec_is0(27) and not sec_is0(28)
		 and not sec_is0(29) and not sec_is0(30)) or
		( pri_is0(1) and  pri_is0(2) and  pri_is0(3) and  pri_is0(4)
		 and  pri_is0(5) and  sec_is0(21) and  sec_is0(24)
		 and not sec_is0(25) and  sec_is0(26) and not sec_is0(27)
		 and  sec_is0(28) and  sec_is0(29) and  sec_is0(30)) or
		( pri_is0(1) and  pri_is0(2) and  pri_is0(3) and  pri_is0(4)
		 and  pri_is0(5) and  sec_is0(21) and not sec_is0(23)
		 and  sec_is0(24) and  sec_is0(26) and not sec_is0(27)
		 and  sec_is0(28) and  sec_is0(29) and  sec_is0(30)) or
		( pri_is0(1) and  pri_is0(2) and  pri_is0(3) and  pri_is0(4)
		 and  pri_is0(5) and  sec_is0(21) and not sec_is0(22)
		 and  sec_is0(23) and  sec_is0(24) and not sec_is0(25)
		 and  sec_is0(26) and  sec_is0(27) and  sec_is0(28)
		 and  sec_is0(30)) or
		( pri_is0(0) and  pri_is0(1) and  pri_is0(3) and  pri_is0(4)
		 and  pri_is0(5) and not sec_is0(21) and not sec_is0(22)
		 and not sec_is0(23) and not sec_is0(24) and not sec_is0(28)
		 and not sec_is0(29) and not sec_is0(30)) or
		( pri_is0(1) and  pri_is0(2) and  pri_is0(3) and  pri_is0(4)
		 and  pri_is0(5) and  sec_is0(21) and not sec_is0(22)
		 and not sec_is0(23) and  sec_is0(24) and  sec_is0(25)
		 and  sec_is0(26) and  sec_is0(27) and  sec_is0(28)) or
		( pri_is0(1) and  pri_is0(2) and  pri_is0(3) and  pri_is0(4)
		 and  pri_is0(5) and  sec_is0(21) and not sec_is0(22)
		 and  sec_is0(26) and not sec_is0(27) and  sec_is0(28)
		 and  sec_is0(29) and  sec_is0(30)) or
		( pri_is0(1) and  pri_is0(2) and  pri_is0(3) and  pri_is0(4)
		 and  pri_is0(5) and  sec_is0(21) and not sec_is0(22)
		 and  sec_is0(24) and  sec_is0(25) and  sec_is0(26)
		 and  sec_is0(27) and  sec_is0(28) and  sec_is0(29)) or
		( pri_is0(0) and  pri_is0(1) and  pri_is0(3) and  pri_is0(4)
		 and  pri_is0(5) and  sec_is0(21) and not sec_is0(22)
		 and  sec_is0(24) and not sec_is0(25) and not sec_is0(27)
		 and  sec_is0(28) and  sec_is0(29) and  sec_is0(30)) or
		( pri_is0(0) and  pri_is0(1) and  pri_is0(3) and  pri_is0(4)
		 and  pri_is0(5) and not sec_is0(21) and not sec_is0(22)
		 and not sec_is0(23) and not sec_is0(25) and not sec_is0(28)
		 and not sec_is0(29) and not sec_is0(30)) or
		( pri_is0(0) and  pri_is0(1) and  pri_is0(3) and  pri_is0(4)
		 and  pri_is0(5) and not sec_is0(21) and not sec_is0(22)
		 and  sec_is0(23) and not sec_is0(24) and not sec_is0(25)
		 and  sec_is0(28) and  sec_is0(29) and not sec_is0(30)) or
		( pri_is0(0) and  pri_is0(1) and  pri_is0(3) and  pri_is0(4)
		 and  pri_is0(5) and not sec_is0(21) and not sec_is0(22)
		 and not sec_is0(24) and not sec_is0(25) and  sec_is0(27)
		 and  sec_is0(28) and  sec_is0(29)) or
		( pri_is0(0) and  pri_is0(1) and  pri_is0(3) and  pri_is0(4)
		 and  pri_is0(5) and not sec_is0(21) and not sec_is0(22)
		 and not sec_is0(23) and not sec_is0(24) and  sec_is0(25)
		 and not sec_is0(27) and  sec_is0(28) and  sec_is0(29)
		 and not sec_is0(30)) or
		( pri_is0(1) and  pri_is0(2) and  pri_is0(3) and  pri_is0(4)
		 and  pri_is0(5) and  sec_is0(21) and not sec_is0(22)
		 and  sec_is0(24) and  sec_is0(26) and  sec_is0(28)
		 and  sec_is0(29) and  sec_is0(30)) or
		( pri_is0(0) and  pri_is0(1) and  pri_is0(3) and  pri_is0(4)
		 and  pri_is0(5) and not sec_is0(21) and not sec_is0(22)
		 and not sec_is0(24) and not sec_is0(27) and not sec_is0(28)
		 and not sec_is0(29) and not sec_is0(30)) or
		( pri_is0(0) and  pri_is0(1) and  pri_is0(3) and  pri_is0(4)
		 and  pri_is0(5) and not sec_is0(21) and not sec_is0(22)
		 and not sec_is0(23) and  sec_is0(24) and not sec_is0(25)
		 and not sec_is0(27) and  sec_is0(28) and  sec_is0(29)
		 and not sec_is0(30)) or
		( pri_is0(0) and  pri_is0(1) and  pri_is0(4) and  pri_is0(5)
		 and  sec_is0(26) and not sec_is0(29) and  sec_is0(30)) or
		( pri_is0(0) and  pri_is0(1) and  pri_is0(4) and  pri_is0(5)
		 and  sec_is0(26) and  sec_is0(29) and not sec_is0(30)) or
		( pri_is0(0) and  pri_is0(1) and  pri_is0(4) and  pri_is0(5)
		 and  sec_is0(26) and  sec_is0(27) and  sec_is0(28)) or
		( pri_is0(0) and  pri_is0(1) and not pri_is0(2)) or
		( pri_is0(0) and  pri_is0(1) and  pri_is0(3) and  pri_is0(4)
		 and  pri_is0(5) and  sec_is0(26) and  sec_is0(28));

tv <= (not pri_is0(3) and  sec_is0(30) and not sec_is0(31)) or
	( pri_is0(2) and  pri_is0(4) and not sec_is0(21) and  sec_is0(22)) or
	( pri_is0(2) and  sec_is0(20) and not sec_is0(23) and not sec_is0(24)
	 and not sec_is0(26) and not sec_is0(27) and not sec_is0(28) and  sec_is0(29)
	 and  sec_is0(30)) or
	( pri_is0(2) and  sec_is0(22) and not sec_is0(23) and  sec_is0(24)
	 and  sec_is0(26) and not sec_is0(27) and  sec_is0(28) and  sec_is0(29)
	 and  sec_is0(30)) or
	( pri_is0(2) and  pri_is0(4) and  sec_is0(22) and not sec_is0(24)
	 and  sec_is0(27)) or
	( pri_is0(2) and  pri_is0(4) and  sec_is0(21) and not sec_is0(22)
	 and not sec_is0(23) and  sec_is0(28)) or
	( pri_is0(0) and  pri_is0(2) and  pri_is0(4) and not sec_is0(25)
	 and  sec_is0(27)) or
	( pri_is0(0) and  pri_is0(2) and  pri_is0(4) and not sec_is0(23)
	 and  sec_is0(27)) or
	( pri_is0(0) and  pri_is0(2) and  pri_is0(4) and  sec_is0(26)) or
	(not pri_is0(2) and not pri_is0(3));

av <= ( pri_is0(3) and  sec_is0(20) and not sec_is0(22) and not sec_is0(23)
	 and  sec_is0(24) and not sec_is0(26) and not sec_is0(27) and not sec_is0(28)
	 and  sec_is0(29) and  sec_is0(30)) or
	( pri_is0(0) and  pri_is0(3) and  pri_is0(4) and not sec_is0(22)
	 and not sec_is0(23) and not sec_is0(24) and not sec_is0(25) and not sec_is0(26)
	 and not sec_is0(28)) or
	( pri_is0(0) and  pri_is0(3) and  pri_is0(4) and not sec_is0(23)
	 and  sec_is0(25) and not sec_is0(26) and not sec_is0(27) and not sec_is0(29)) or
	(not pri_is0(0) and  sec_is0(21) and  sec_is0(23) and  sec_is0(24)
	 and not sec_is0(25) and  sec_is0(29)) or
	( pri_is0(0) and  pri_is0(3) and  pri_is0(4) and not sec_is0(24)
	 and not sec_is0(25) and not sec_is0(26) and not sec_is0(27) and not sec_is0(29)
	 and not sec_is0(30)) or
	(not pri_is0(0) and  sec_is0(21) and not sec_is0(22) and  sec_is0(23)
	 and not sec_is0(27)) or
	( pri_is0(0) and  pri_is0(2) and  pri_is0(4) and  sec_is0(26)
	 and  sec_is0(27) and  sec_is0(28)) or
	( pri_is0(0) and  pri_is0(2) and  pri_is0(4) and  sec_is0(26)
	 and not sec_is0(27) and not sec_is0(28) and  sec_is0(29)) or
	( pri_is0(0) and  pri_is0(2) and  pri_is0(4) and  sec_is0(26)
	 and  sec_is0(28) and not sec_is0(29)) or
	( pri_is0(0) and  pri_is0(2) and  sec_is0(26) and  sec_is0(30)) or
	( pri_is0(1) and not pri_is0(2) and  pri_is0(3));

bv <= (not pri_is0(0) and  sec_is0(21) and not sec_is0(25) and not sec_is0(29)) or
	( pri_is0(2) and not pri_is0(3) and  sec_is0(28) and  sec_is0(30)
	 and not sec_is0(31)) or
	(not pri_is0(0) and  sec_is0(21) and  sec_is0(23) and  sec_is0(25)
	 and  sec_is0(27) and  sec_is0(28) and  sec_is0(29)) or
	( pri_is0(0) and  pri_is0(2) and  pri_is0(4) and not sec_is0(24)
	 and not sec_is0(27) and not sec_is0(28) and not sec_is0(29) and not sec_is0(30)) or
	( pri_is0(2) and  pri_is0(4) and  sec_is0(22) and not sec_is0(24)
	 and not sec_is0(26)) or
	( pri_is0(0) and  pri_is0(2) and  pri_is0(4) and  sec_is0(23)
	 and  sec_is0(24) and not sec_is0(25) and  sec_is0(29)) or
	( pri_is0(0) and  pri_is0(2) and  pri_is0(4) and not sec_is0(25)
	 and not sec_is0(26) and  sec_is0(27)) or
	( pri_is0(0) and  pri_is0(2) and  pri_is0(4) and not sec_is0(21)
	 and  sec_is0(24) and  sec_is0(27) and not sec_is0(30)) or
	( pri_is0(0) and  pri_is0(2) and  sec_is0(26) and  sec_is0(28)
	 and  sec_is0(30)) or
	( pri_is0(0) and  pri_is0(2) and  pri_is0(4) and not sec_is0(23)
	 and not sec_is0(26) and  sec_is0(27)) or
	( pri_is0(0) and  pri_is0(2) and  pri_is0(4) and  sec_is0(26)
	 and not sec_is0(30));

cv <= ( pri_is0(0) and  pri_is0(2) and  sec_is0(26) and not sec_is0(28)
	 and  sec_is0(30)) or
	( pri_is0(0) and  pri_is0(2) and  sec_is0(26) and  sec_is0(29)
	 and  sec_is0(30)) or
	( pri_is0(0) and  pri_is0(2) and  pri_is0(4) and  sec_is0(26)
	 and  sec_is0(27) and  sec_is0(28));

bubble3 <= ( pri_is0(0) and  pri_is0(2) and not sec_is0(23) and not sec_is0(26)
	 and  sec_is0(29) and  sec_is0(31)) or
	( pri_is0(0) and  pri_is0(2) and  pri_is0(4) and not sec_is0(23)
	 and  sec_is0(24) and not sec_is0(26) and not sec_is0(27) and not sec_is0(28)) or
	( pri_is0(0) and  pri_is0(2) and not sec_is0(25) and  sec_is0(27)
	 and  sec_is0(31)) or
	( pri_is0(2) and not sec_is0(21) and  sec_is0(22) and  sec_is0(27)
	 and  sec_is0(31)) or
	( pri_is0(0) and  pri_is0(2) and  pri_is0(4) and  sec_is0(23)
	 and not sec_is0(24) and not sec_is0(26) and not sec_is0(27) and not sec_is0(28)
	 and not sec_is0(29) and not sec_is0(30)) or
	( pri_is0(2) and  sec_is0(22) and not sec_is0(24) and  sec_is0(27)
	 and  sec_is0(31)) or
	( pri_is0(0) and  pri_is0(2) and not sec_is0(25) and not sec_is0(26)
	 and  sec_is0(28) and  sec_is0(29) and  sec_is0(31)) or
	( pri_is0(0) and  pri_is0(2) and not sec_is0(23) and  sec_is0(27)
	 and  sec_is0(31)) or
	( pri_is0(0) and  pri_is0(2) and  sec_is0(26) and  sec_is0(30)
	 and  sec_is0(31)) or
	( pri_is0(0) and  pri_is0(2) and  sec_is0(26) and  sec_is0(28)
	 and not sec_is0(29) and  sec_is0(31)) or
	( pri_is0(0) and  pri_is0(2) and  sec_is0(26) and  sec_is0(27)
	 and  sec_is0(31));

prebubble1 <= ( pri_is0(0) and  pri_is0(2) and not sec_is0(23) and not sec_is0(26)
	 and not sec_is0(27) and  sec_is0(30));

ld_st_is0 <= (not pri_is0(0) and  pri_is0(1) and  pri_is0(2) and  pri_is0(3)
	 and  pri_is0(4) and  pri_is0(5) and  sec_is0(20) and not sec_is0(21)
	 and not sec_is0(22) and not sec_is0(23) and not sec_is0(26) and not sec_is0(27)
	 and not sec_is0(28) and  sec_is0(29) and  sec_is0(30)) or
		(not pri_is0(0) and  pri_is0(1) and  pri_is0(2) and  pri_is0(3)
		 and  pri_is0(4) and  pri_is0(5) and  sec_is0(21)
		 and not sec_is0(22) and not sec_is0(23) and  sec_is0(24)
		 and  sec_is0(25) and  sec_is0(26) and  sec_is0(27)
		 and  sec_is0(28)) or
		(not pri_is0(0) and  pri_is0(1) and  pri_is0(2) and  pri_is0(3)
		 and  pri_is0(4) and  pri_is0(5) and  sec_is0(21)
		 and not sec_is0(22) and  sec_is0(23) and  sec_is0(24)
		 and not sec_is0(25) and  sec_is0(26) and  sec_is0(27)
		 and  sec_is0(28) and  sec_is0(30)) or
		(not pri_is0(0) and  pri_is0(1) and  pri_is0(2) and  pri_is0(3)
		 and  pri_is0(4) and  pri_is0(5) and  sec_is0(21)
		 and not sec_is0(22) and  sec_is0(24) and  sec_is0(25)
		 and  sec_is0(26) and  sec_is0(27) and  sec_is0(28)
		 and  sec_is0(29)) or
		(not pri_is0(0) and  pri_is0(1) and  pri_is0(2) and  pri_is0(3)
		 and  pri_is0(4) and  pri_is0(5) and  sec_is0(21)
		 and  sec_is0(24) and not sec_is0(25) and  sec_is0(26)
		 and not sec_is0(27) and  sec_is0(28) and  sec_is0(29)
		 and  sec_is0(30)) or
		(not pri_is0(0) and  pri_is0(1) and  pri_is0(2) and  pri_is0(3)
		 and  pri_is0(4) and  pri_is0(5) and  sec_is0(21)
		 and not sec_is0(22) and  sec_is0(26) and not sec_is0(27)
		 and  sec_is0(28) and  sec_is0(29) and  sec_is0(30)) or
		(not pri_is0(0) and  pri_is0(1) and  pri_is0(2) and  pri_is0(3)
		 and  pri_is0(4) and  pri_is0(5) and  sec_is0(21)
		 and not sec_is0(23) and  sec_is0(24) and  sec_is0(26)
		 and not sec_is0(27) and  sec_is0(28) and  sec_is0(29)
		 and  sec_is0(30)) or
		(not pri_is0(0) and  pri_is0(1) and  pri_is0(2) and  pri_is0(3)
		 and  pri_is0(4) and  pri_is0(5) and  sec_is0(21)
		 and not sec_is0(22) and  sec_is0(24) and  sec_is0(26)
		 and  sec_is0(28) and  sec_is0(29) and  sec_is0(30)) or
		( pri_is0(0) and  pri_is0(1) and not pri_is0(2));

st_is0 <= (not pri_is0(0) and  pri_is0(1) and  pri_is0(2) and  pri_is0(3)
		 and  pri_is0(4) and  pri_is0(5) and  sec_is0(20)
		 and not sec_is0(21) and not sec_is0(22) and not sec_is0(23)
		 and  sec_is0(24) and not sec_is0(26) and not sec_is0(27)
		 and not sec_is0(28) and  sec_is0(29) and  sec_is0(30)) or
	(not pri_is0(0) and  pri_is0(1) and  pri_is0(2) and  pri_is0(3)
	 and  pri_is0(4) and  pri_is0(5) and  sec_is0(21) and not sec_is0(22)
	 and  sec_is0(23) and  sec_is0(24) and  sec_is0(25) and  sec_is0(26)
	 and  sec_is0(27) and  sec_is0(28) and  sec_is0(29)) or
	(not pri_is0(0) and  pri_is0(1) and  pri_is0(2) and  pri_is0(3)
	 and  pri_is0(4) and  pri_is0(5) and  sec_is0(21) and not sec_is0(22)
	 and  sec_is0(23) and  sec_is0(24) and not sec_is0(25) and  sec_is0(26)
	 and  sec_is0(27) and  sec_is0(28) and  sec_is0(30)) or
	(not pri_is0(0) and  pri_is0(1) and  pri_is0(2) and  pri_is0(3)
	 and  pri_is0(4) and  pri_is0(5) and  sec_is0(21) and  sec_is0(23)
	 and  sec_is0(24) and not sec_is0(25) and  sec_is0(26) and not sec_is0(27)
	 and  sec_is0(28) and  sec_is0(29) and  sec_is0(30)) or
	(not pri_is0(0) and  pri_is0(1) and  pri_is0(2) and  pri_is0(3)
	 and  pri_is0(4) and  pri_is0(5) and  sec_is0(21) and not sec_is0(22)
	 and  sec_is0(23) and  sec_is0(26) and not sec_is0(27) and  sec_is0(28)
	 and  sec_is0(29) and  sec_is0(30)) or
	( pri_is0(0) and  pri_is0(1) and not pri_is0(2) and  pri_is0(3));

indexed <= ( pri_is0(2) and  sec_is0(20) and not sec_is0(23) and not sec_is0(25)
	 and not sec_is0(26) and not sec_is0(27) and not sec_is0(28) and  sec_is0(29)
	 and  sec_is0(30)) or
	(not pri_is0(0) and  sec_is0(21) and not sec_is0(25) and  sec_is0(27)
	 and  sec_is0(29)) or
	(not pri_is0(0) and  sec_is0(21) and not sec_is0(22) and not sec_is0(27)) or
	(not pri_is0(0) and  sec_is0(21) and  sec_is0(24) and  sec_is0(26)
	 and not sec_is0(27) and  sec_is0(28) and  sec_is0(29) and  sec_is0(30)) or
	(not pri_is0(0) and  sec_is0(21) and not sec_is0(22) and not sec_is0(23)
	 and  sec_is0(28) and not sec_is0(29));

update_form <= (not pri_is0(0) and  pri_is0(1) and  pri_is0(2) and  pri_is0(3)
	 and  pri_is0(4) and  pri_is0(5) and  sec_is0(21) and not sec_is0(22)
	 and  sec_is0(25) and  sec_is0(26) and not sec_is0(27) and  sec_is0(28)
	 and  sec_is0(29) and  sec_is0(30)) or
		( pri_is0(0) and  pri_is0(1) and not pri_is0(2) and  pri_is0(5));

forcealign <= '0';

single_precision_ldst <= ( pri_is0(2) and not is0_instr(16) and not is0_instr(17)
		 and  sec_is0(20) and not sec_is0(22) and not sec_is0(23)
		 and not sec_is0(26) and not sec_is0(27) and not sec_is0(28)
		 and  sec_is0(29) and  sec_is0(30)) or
		( pri_is0(1) and not pri_is0(2) and not pri_is0(4)) or
		(not pri_is0(0) and  sec_is0(21) and not sec_is0(22)
		 and  sec_is0(28) and  sec_is0(29) and not sec_is0(30)) or
		(not pri_is0(0) and  sec_is0(21) and not sec_is0(22)
		 and not sec_is0(24));

int_word_ldst <= (not pri_is0(0) and  sec_is0(22) and  sec_is0(24)
		 and  sec_is0(26) and not sec_is0(27) and  sec_is0(28)
		 and  sec_is0(29) and  sec_is0(30)) or
		(not pri_is0(0) and  sec_is0(21) and not sec_is0(22)
		 and not sec_is0(23) and  sec_is0(28) and not sec_is0(29)) or
		(not pri_is0(0) and  sec_is0(21) and not sec_is0(25)
		 and not sec_is0(29));

sign_ext_ldst <= ( pri_is0(2) and not is0_instr(16) and not is0_instr(17)
		 and  sec_is0(20) and not sec_is0(22) and not sec_is0(23)
		 and not sec_is0(26) and not sec_is0(27) and not sec_is0(28)
		 and  sec_is0(29) and  sec_is0(30)) or
		(not pri_is0(0) and  sec_is0(21) and not sec_is0(22)
		 and not sec_is0(23) and  sec_is0(28) and not sec_is0(29)
		 and not sec_is0(30)) or
		(not pri_is0(0) and  sec_is0(22) and not sec_is0(23)
		 and  sec_is0(24) and not sec_is0(25));

ldst_extpid <= (not pri_is0(0) and  pri_is0(1) and  pri_is0(2) and  pri_is0(3)
		 and  pri_is0(4) and  pri_is0(5) and  sec_is0(21)
		 and not sec_is0(22) and  sec_is0(24) and not sec_is0(25)
		 and  sec_is0(26) and  sec_is0(27) and  sec_is0(28)
		 and  sec_is0(29) and  sec_is0(30));

io_port <= (not pri_is0(0) and  pri_is0(1) and  pri_is0(2) and  pri_is0(3)
		 and  pri_is0(4) and  pri_is0(5) and  sec_is0(20)
		 and not sec_is0(21) and not sec_is0(22) and not sec_is0(23)
		 and not sec_is0(26) and not sec_is0(27) and not sec_is0(28)
		 and  sec_is0(29) and  sec_is0(30));

io_port_ext <= (not pri_is0(0) and  pri_is0(1) and  pri_is0(2) and  pri_is0(3)
		 and  pri_is0(4) and  pri_is0(5) and  sec_is0(20)
		 and not sec_is0(21) and not sec_is0(22) and not sec_is0(23)
		 and not sec_is0(25) and not sec_is0(26) and not sec_is0(27)
		 and not sec_is0(28) and  sec_is0(29) and  sec_is0(30));

size(0) <= '0';

size(1) <= '0';

size(2) <= (not pri_is0(0) and  sec_is0(21) and not sec_is0(25) and  sec_is0(27)
		 and  sec_is0(29)) or
	( pri_is0(4) and  sec_is0(21) and not sec_is0(22) and  sec_is0(24)
	 and not sec_is0(27)) or
	(not pri_is0(2) and  pri_is0(4));

size(3) <= (not pri_is0(0) and  sec_is0(21) and not sec_is0(22) and not sec_is0(24)) or
	( pri_is0(2) and  sec_is0(22) and  sec_is0(24) and  sec_is0(26)
	 and not sec_is0(27) and  sec_is0(28) and  sec_is0(29) and  sec_is0(30)) or
	( pri_is0(1) and not pri_is0(2) and not pri_is0(4));

size(4) <= '0';

size(5) <= '0';

cr_writer <= ( pri_is0(2) and  sec_is0(20) and not sec_is0(22) and not sec_is0(23)
	 and not sec_is0(26) and not sec_is0(27) and not sec_is0(28) and  sec_is0(29)
	 and  sec_is0(30) and  sec_is0(31)) or
		( pri_is0(0) and  pri_is0(2) and not sec_is0(21) and  sec_is0(24)
		 and  sec_is0(27) and  sec_is0(31)) or
		( pri_is0(0) and  pri_is0(2) and not sec_is0(25) and not sec_is0(26)
		 and not sec_is0(29) and not sec_is0(30) and  sec_is0(31)) or
		( pri_is0(2) and  sec_is0(22) and not sec_is0(24)
		 and  sec_is0(27) and  sec_is0(31)) or
		( pri_is0(0) and  pri_is0(2) and  pri_is0(4) and not sec_is0(22)
		 and not sec_is0(26) and not sec_is0(27) and not sec_is0(28)
		 and not sec_is0(29) and not sec_is0(30)) or
		( pri_is0(0) and  pri_is0(2) and not sec_is0(25) and not sec_is0(26)
		 and  sec_is0(28) and  sec_is0(29) and  sec_is0(31)) or
		( pri_is0(0) and  pri_is0(2) and not sec_is0(23) and not sec_is0(26)
		 and  sec_is0(31)) or
		( pri_is0(0) and  pri_is0(2) and  sec_is0(26) and  sec_is0(30)
		 and  sec_is0(31)) or
		( pri_is0(0) and  pri_is0(2) and  sec_is0(26) and  sec_is0(28)
		 and not sec_is0(29) and  sec_is0(31)) or
		( pri_is0(0) and  pri_is0(2) and  sec_is0(26) and  sec_is0(27)
		 and  sec_is0(31));

mffgpr <= (not pri_is0(0) and  pri_is0(1) and  pri_is0(2) and  pri_is0(3)
		 and  pri_is0(4) and  pri_is0(5) and  sec_is0(21)
		 and not sec_is0(22) and not sec_is0(23) and  sec_is0(24)
		 and  sec_is0(25) and  sec_is0(26) and  sec_is0(27)
		 and  sec_is0(28)) or
	(not pri_is0(0) and  pri_is0(1) and  pri_is0(2) and  pri_is0(3)
	 and  pri_is0(4) and  pri_is0(5) and not is0_instr(16) and  sec_is0(20)
	 and not sec_is0(21) and not sec_is0(22) and not sec_is0(23) and not sec_is0(24)
	 and not sec_is0(26) and not sec_is0(27) and not sec_is0(28) and  sec_is0(29)
	 and  sec_is0(30));

mftgpr <= (not pri_is0(0) and  pri_is0(1) and  pri_is0(2) and  pri_is0(3)
	 and  pri_is0(4) and  pri_is0(5) and  sec_is0(21) and not sec_is0(22)
	 and  sec_is0(23) and  sec_is0(24) and not sec_is0(25) and  sec_is0(26)
	 and  sec_is0(27) and  sec_is0(28) and not sec_is0(29) and  sec_is0(30)) or
	(not pri_is0(0) and  pri_is0(1) and  pri_is0(2) and  pri_is0(3)
	 and  pri_is0(4) and  pri_is0(5) and  sec_is0(21) and not sec_is0(22)
	 and  sec_is0(23) and  sec_is0(24) and  sec_is0(25) and  sec_is0(26)
	 and  sec_is0(27) and  sec_is0(28) and  sec_is0(29)) or
	(not pri_is0(0) and  pri_is0(1) and  pri_is0(2) and  pri_is0(3)
	 and  pri_is0(4) and  pri_is0(5) and not is0_instr(16) and  sec_is0(20)
	 and not sec_is0(21) and not sec_is0(22) and not sec_is0(23) and  sec_is0(24)
	 and not sec_is0(26) and not sec_is0(27) and not sec_is0(28) and  sec_is0(29)
	 and  sec_is0(30));

fdiv_is0 <= ( pri_is0(0) and  pri_is0(1) and  pri_is0(2) and  pri_is0(4)
	 and  pri_is0(5) and  sec_is0(26) and not sec_is0(27) and not sec_is0(28)
	 and  sec_is0(29) and not sec_is0(30));

fsqrt_is0 <= ( pri_is0(0) and  pri_is0(1) and  pri_is0(2) and  pri_is0(4)
	 and  pri_is0(5) and  sec_is0(26) and not sec_is0(27) and  sec_is0(28)
	 and  sec_is0(29) and not sec_is0(30));

only_from_ucode <= (not pri_is0(0) and  pri_is0(1) and  pri_is0(2) and  pri_is0(3)
	 and  pri_is0(4) and  pri_is0(5) and  sec_is0(21) and not sec_is0(22)
	 and  sec_is0(24) and  sec_is0(25) and  sec_is0(26) and  sec_is0(27)
	 and  sec_is0(28) and  sec_is0(29)) or
		(not pri_is0(0) and  pri_is0(1) and  pri_is0(2) and  pri_is0(3)
		 and  pri_is0(4) and  pri_is0(5) and  sec_is0(21)
		 and not sec_is0(22) and  sec_is0(23) and  sec_is0(24)
		 and not sec_is0(25) and  sec_is0(26) and  sec_is0(27)
		 and  sec_is0(28) and not sec_is0(29) and  sec_is0(30)) or
		(not pri_is0(0) and  pri_is0(1) and  pri_is0(2) and  pri_is0(3)
		 and  pri_is0(4) and  pri_is0(5) and  sec_is0(21)
		 and not sec_is0(22) and not sec_is0(23) and  sec_is0(24)
		 and  sec_is0(25) and  sec_is0(26) and  sec_is0(27)
		 and  sec_is0(28)) or
		( pri_is0(0) and  pri_is0(1) and  pri_is0(2) and  pri_is0(4)
		 and  pri_is0(5) and  sec_is0(26) and not sec_is0(27)
		 and not sec_is0(28) and not sec_is0(29) and  sec_is0(30)) or
		( pri_is0(0) and  pri_is0(1) and  pri_is0(2) and  pri_is0(3)
		 and  pri_is0(4) and  pri_is0(5) and  sec_is0(26)
		 and not sec_is0(27) and not sec_is0(28) and not sec_is0(29));

final_fmul_uc <= ( pri_is0(0) and  pri_is0(1) and  pri_is0(2) and  pri_is0(4)
		 and  pri_is0(5) and  sec_is0(26) and not sec_is0(27)
		 and not sec_is0(28) and not sec_is0(29) and  sec_is0(30));

only_graphics_mode <= ( pri_is0(0) and  pri_is0(1) and  pri_is0(2)
		 and not pri_is0(3) and  pri_is0(4) and  pri_is0(5)
		 and not sec_is0(21) and not sec_is0(22) and  sec_is0(23)
		 and  sec_is0(24) and not sec_is0(26) and not sec_is0(27)
		 and  sec_is0(28) and not sec_is0(29) and  sec_is0(30)
		 and not sec_is0(31)) or
		(not pri_is0(0) and  pri_is0(1) and  pri_is0(2) and  pri_is0(3)
		 and  pri_is0(4) and  pri_is0(5) and  sec_is0(21)
		 and not sec_is0(22) and not sec_is0(23) and  sec_is0(24)
		 and  sec_is0(25) and  sec_is0(26) and  sec_is0(27)
		 and  sec_is0(28)) or
		(not pri_is0(0) and  pri_is0(1) and  pri_is0(2) and  pri_is0(3)
		 and  pri_is0(4) and  pri_is0(5) and  sec_is0(21)
		 and not sec_is0(22) and  sec_is0(23) and  sec_is0(24)
		 and not sec_is0(25) and  sec_is0(26) and  sec_is0(27)
		 and  sec_is0(28) and not sec_is0(29) and  sec_is0(30)) or
		(not pri_is0(0) and  pri_is0(1) and  pri_is0(2) and  pri_is0(3)
		 and  pri_is0(4) and  pri_is0(5) and  sec_is0(21)
		 and not sec_is0(22) and  sec_is0(24) and  sec_is0(25)
		 and  sec_is0(26) and  sec_is0(27) and  sec_is0(28)
		 and  sec_is0(29));













ldst_tag   <=   single_precision_ldst &
                int_word_ldst &
                sign_ext_ldst &         
                ldst_tag_addr(0 to 5);

tag_in_16to20 <= mftgpr and not io_port;
mftgpr_not_DITC <= mftgpr and not io_port;

ldst_tag_addr <= (iu_au_is0_ucode_ext(0) & is0_instr(06 to 10)) when tag_in_16to20='0' else
                 (iu_au_is0_ucode_ext(2) & is0_instr(16 to 20)) ;

ram_mode_v <= pc_au_ram_mode and pc_au_ram_thread_v;               
                      
iu_au_config_iucr_din <= iu_au_config_iucr;

   config_reg: tri_rlmreg_p
   generic map (init => 0, expand_type => expand_type, needs_sreset => needs_sreset, width => iu_au_config_iucr_l2'length)
   port map (
      vd       => vdd,     gd       => gnd,
      forcee => forcee,   delay_lclkr => delay_lclkr,
      nclk     => nclk,    mpw1_b      => mpw1_b,
      act      => tiup,    mpw2_b      => mpw2_b,
      thold_b  => pc_iu_func_sl_thold_0_b,
      sg       => pc_iu_sg_0,
      scin     => config_reg_scin(0 to 7),
      scout    => config_reg_scout(0 to 7),
      din            => iu_au_config_iucr_din,
      dout           => iu_au_config_iucr_l2
      );


iu_au_config_iucr_int(0 to 7) <= iu_au_config_iucr_l2(0 to 7);

       graphics_mode <= iu_au_config_iucr_int(0);  
i_afd_config_iucr(1) <= iu_au_config_iucr_int(1);  
i_afd_config_iucr(2) <= iu_au_config_iucr_int(2);  
i_afd_config_iucr(3) <= iu_au_config_iucr_int(3);  
i_afd_config_iucr(4) <= iu_au_config_iucr_int(4);  
i_afd_config_iucr(5) <= iu_au_config_iucr_int(5);  
i_afd_config_iucr(6) <= iu_au_config_iucr_int(6);  
i_afd_config_iucr(7) <= iu_au_config_iucr_int(7);  


spare_unused(4 to 7) <= tidn & tidn & tidn & tidn;
spare_unused(34) <= io_port_ext;


is0_is_ucode <= iu_au_is0_is_ucode; 

in_ucode_mode  <= iu_au_is0_is_ucode and is0_instr_v;

in_fdivsqrt_mode_is0 <= (fdiv_is0 or fsqrt_is0) and (is0_instr_v and not iu_au_is0_flush);
is0_in_divsqrt_mode_or1d <= in_fdivsqrt_mode_is0 or ucmodelat_dout;
ucmodelat_din <= (in_fdivsqrt_mode_is0 or ucmodelat_dout) and (not ifdp_ex5_fmul_uc_complete);   

au_iu_is0_ucode_only <= only_from_ucode;


is0_invalid_kill_uc <= (not (in_ucode_mode or ram_mode_v) and only_from_ucode) or  
                       (not (graphics_mode or in_ucode_mode or ram_mode_v) and only_graphics_mode); 




is0_invalid_kill <=  (not (graphics_mode or in_ucode_mode or ram_mode_v) and only_graphics_mode); 

is0_kill_or_divsqrt_b <= not (is0_invalid_kill);

is0_i_dec_b    <= not (isfu_dec_is0 and is0_kill_or_divsqrt_b);  
au_iu_is0_i_dec_b <= is0_i_dec_b;

au_iu_is0_i_dec <= not is0_i_dec_b;
spare_unused(2) <= au_iu_is0_i_dec;
                                               


ignore_flush_is0 <= (fdiv_is0 or fsqrt_is0) and isfu_dec_is0;  

   is0_frt(0 to 5) <=  "100001"                                           when (fdiv_is0 ='1' or fsqrt_is0 ='1') else  
                       iu_au_is0_ucode_ext(0) & is0_instr(06 to 10);                                              


is0_st_or_mtdp <= st_is0 and not (mftgpr and not io_port);  
is0_mftgpr <= st_is0 and mftgpr and not io_port;    
is0_usual_fra <= not (st_is0 or mftgpr or io_port); 

is0_fra_or_frs(0 to 5) <=  ((iu_au_is0_ucode_ext(0) & is0_instr(06 to 10)) and (0 to 5 => is0_st_or_mtdp)) or
                           ((iu_au_is0_ucode_ext(2) & is0_instr(16 to 20)) and (0 to 5 => is0_mftgpr))  or
                           ((iu_au_is0_ucode_ext(1) & is0_instr(11 to 15)) and (0 to 5 => is0_usual_fra));
                       

is0_to_ucode          <= (iu_au_is0_2ucode or fdiv_is0 or fsqrt_is0) and isfu_dec_is0; 
au_iu_is0_to_ucode    <= (iu_au_is0_2ucode or fdiv_is0 or fsqrt_is0) and isfu_dec_is0;                     

au_iu_is0_ldst   <= ld_st_is0;
au_iu_is0_ldst_v <= ld_st_is0 and not is0_invalid_kill;       
au_iu_is0_st_v    <= st_is0 and not is0_invalid_kill;

au_iu_is0_instr_type <= "001";                 

au_iu_is0_mffgpr <= mffgpr; 
au_iu_is0_mftgpr <= mftgpr; 

au_iu_is0_movedp <= io_port and ld_st_is0; 

au_iu_is0_ldst_size     <= size(0 to 5);       
au_iu_is0_ldst_tag      <= ldst_tag;  
au_iu_is0_ldst_ra_v     <= ld_st_is0 and (not mftgpr or (io_port and indexed));                
au_iu_is0_ldst_ra       <= '0' & iu_au_is0_ucode_ext(1) & is0_instr(11 to 15) when mftgpr_not_DITC='0' else
                           '0' & iu_au_is0_ucode_ext(0) & is0_instr( 6 to 10);   
au_iu_is0_ldst_rb_v     <= (indexed or mffgpr) and ld_st_is0;                      
au_iu_is0_ldst_rb       <= '0' & iu_au_is0_ucode_ext(2) & is0_instr(16 to 20);   
au_iu_is0_ldst_dimm     <= is0_instr(16 to 31);                
au_iu_is0_ldst_indexed  <= indexed;                   
au_iu_is0_ldst_update        <= update_form; 
au_iu_is0_ldst_forcealign    <= forcealign;   
au_iu_is0_ldst_forceexcept   <= '0';

au_iu_is0_ldst_extpid <= ldst_extpid;


   

    


is1_v_nstall1_b_NAND2:   is1_v_nstall1_b <= not( is1_stall_b and is0_ins_v );
is1_v_nstall2_b_NAND2:   is1_v_nstall2_b <= not( is1_stall_b and is0_ins_v );

is1_v_nstall1_INV:       is1_v_nstall1  <= not( is1_v_nstall1_b );
is1_v_nstall2_INV:       is1_v_nstall2  <= not( is1_v_nstall1_b );
is1_v_nstall3_INV:       is1_v_nstall3  <= not( is1_v_nstall1_b );
is1_v_nstall4_INV:       is1_v_nstall4  <= not( is1_v_nstall1_b );

is1_v_nstall5_INV:       is1_v_nstall5  <= not( is1_v_nstall2_b );
is1_v_nstall6_INV:       is1_v_nstall6  <= not( is1_v_nstall2_b );
is1_v_nstall7_INV:       is1_v_nstall7  <= not( is1_v_nstall2_b );
is1_v_nstall8_INV:       is1_v_nstall8  <= not( is1_v_nstall2_b );


is1_v_nstall01_INVaa:      is1_v_nstall01_INVA_b   <= not( is1_v_nstall1);
is1_v_nstall02_INVaa:      is1_v_nstall02_INVA_b   <= not( is1_v_nstall1);
is1_v_nstall03_INVaa:      is1_v_nstall03_INVA_b   <= not( is1_v_nstall1);
is1_v_nstall04_INVaa:      is1_v_nstall04_INVA_b   <= not( is1_v_nstall1);
is1_v_nstall05_INVaa:      is1_v_nstall05_INVA_b   <= not( is1_v_nstall2);
is1_v_nstall06_INVaa:      is1_v_nstall06_INVA_b   <= not( is1_v_nstall2);
is1_v_nstall07_INVaa:      is1_v_nstall07_INVA_b   <= not( is1_v_nstall2);
is1_v_nstall08_INVaa:      is1_v_nstall08_INVA_b   <= not( is1_v_nstall2);
is1_v_nstall09_INVaa:      is1_v_nstall09_INVA_b   <= not( is1_v_nstall3);
is1_v_nstall10_INVaa:      is1_v_nstall10_INVA_b   <= not( is1_v_nstall3);
is1_v_nstall11_INVaa:      is1_v_nstall11_INVA_b   <= not( is1_v_nstall3);
is1_v_nstall12_INVaa:      is1_v_nstall12_INVA_b   <= not( is1_v_nstall3);
is1_v_nstall13_INVaa:      is1_v_nstall13_INVA_b   <= not( is1_v_nstall4);
is1_v_nstall14_INVaa:      is1_v_nstall14_INVA_b   <= not( is1_v_nstall4);
is1_v_nstall15_INVaa:      is1_v_nstall15_INVA_b   <= not( is1_v_nstall4);
is1_v_nstall16_INVaa:      is1_v_nstall16_INVA_b   <= not( is1_v_nstall4);
is1_v_nstall17_INVaa:      is1_v_nstall17_INVA_b   <= not( is1_v_nstall5);
is1_v_nstall18_INVaa:      is1_v_nstall18_INVA_b   <= not( is1_v_nstall5);
is1_v_nstall19_INVaa:      is1_v_nstall19_INVA_b   <= not( is1_v_nstall5);
is1_v_nstall20_INVaa:      is1_v_nstall20_INVA_b   <= not( is1_v_nstall5);
is1_v_nstall21_INVaa:      is1_v_nstall21_INVA_b   <= not( is1_v_nstall6);
is1_v_nstall22_INVaa:      is1_v_nstall22_INVA_b   <= not( is1_v_nstall6);
is1_v_nstall23_INVaa:      is1_v_nstall23_INVA_b   <= not( is1_v_nstall6);
is1_v_nstall24_INVaa:      is1_v_nstall24_INVA_b   <= not( is1_v_nstall6);
is1_v_nstall25_INVaa:      is1_v_nstall25_INVA_b   <= not( is1_v_nstall7);
is1_v_nstall26_INVaa:      is1_v_nstall26_INVA_b   <= not( is1_v_nstall7);
is1_v_nstall27_INVaa:      is1_v_nstall27_INVA_b   <= not( is1_v_nstall7);
is1_v_nstall28_INVaa:      is1_v_nstall28_INVA_b   <= not( is1_v_nstall7);
is1_v_nstall29_INVaa:      is1_v_nstall29_INVA_b   <= not( is1_v_nstall8);
is1_v_nstall30_INVaa:      is1_v_nstall30_INVA_b   <= not( is1_v_nstall8);
is1_v_nstall31_INVaa:      is1_v_nstall31_INVA_b   <= not( is1_v_nstall8);
is1_v_nstall32_INVaa:      is1_v_nstall32_INVA_b   <= not( is1_v_nstall8);



is1_v_nstall01_INVbb:      is1_v_nstall01_INVB     <= not( is1_v_nstall01_INVA_b );
is1_v_nstall02_INVbb:      is1_v_nstall02_INVB     <= not( is1_v_nstall02_INVA_b );
is1_v_nstall03_INVbb:      is1_v_nstall03_INVB     <= not( is1_v_nstall03_INVA_b );
is1_v_nstall04_INVbb:      is1_v_nstall04_INVB     <= not( is1_v_nstall04_INVA_b );
is1_v_nstall05_INVbb:      is1_v_nstall05_INVB     <= not( is1_v_nstall05_INVA_b );
is1_v_nstall06_INVbb:      is1_v_nstall06_INVB     <= not( is1_v_nstall06_INVA_b );
is1_v_nstall07_INVbb:      is1_v_nstall07_INVB     <= not( is1_v_nstall07_INVA_b );
is1_v_nstall08_INVbb:      is1_v_nstall08_INVB     <= not( is1_v_nstall08_INVA_b );
is1_v_nstall09_INVbb:      is1_v_nstall09_INVB     <= not( is1_v_nstall09_INVA_b );
is1_v_nstall10_INVbb:      is1_v_nstall10_INVB     <= not( is1_v_nstall10_INVA_b );
is1_v_nstall11_INVbb:      is1_v_nstall11_INVB     <= not( is1_v_nstall11_INVA_b );
is1_v_nstall12_INVbb:      is1_v_nstall12_INVB     <= not( is1_v_nstall12_INVA_b );
is1_v_nstall13_INVbb:      is1_v_nstall13_INVB     <= not( is1_v_nstall13_INVA_b );
is1_v_nstall14_INVbb:      is1_v_nstall14_INVB     <= not( is1_v_nstall14_INVA_b );
is1_v_nstall15_INVbb:      is1_v_nstall15_INVB     <= not( is1_v_nstall15_INVA_b );
is1_v_nstall16_INVbb:      is1_v_nstall16_INVB     <= not( is1_v_nstall16_INVA_b );
is1_v_nstall17_INVbb:      is1_v_nstall17_INVB     <= not( is1_v_nstall17_INVA_b );
is1_v_nstall18_INVbb:      is1_v_nstall18_INVB     <= not( is1_v_nstall18_INVA_b );
is1_v_nstall19_INVbb:      is1_v_nstall19_INVB     <= not( is1_v_nstall19_INVA_b );
is1_v_nstall20_INVbb:      is1_v_nstall20_INVB     <= not( is1_v_nstall20_INVA_b );
is1_v_nstall21_INVbb:      is1_v_nstall21_INVB     <= not( is1_v_nstall21_INVA_b );
is1_v_nstall22_INVbb:      is1_v_nstall22_INVB     <= not( is1_v_nstall22_INVA_b );
is1_v_nstall23_INVbb:      is1_v_nstall23_INVB     <= not( is1_v_nstall23_INVA_b );
is1_v_nstall24_INVbb:      is1_v_nstall24_INVB     <= not( is1_v_nstall24_INVA_b );
is1_v_nstall25_INVbb:      is1_v_nstall25_INVB     <= not( is1_v_nstall25_INVA_b );
is1_v_nstall26_INVbb:      is1_v_nstall26_INVB     <= not( is1_v_nstall26_INVA_b );
is1_v_nstall27_INVbb:      is1_v_nstall27_INVB     <= not( is1_v_nstall27_INVA_b );
is1_v_nstall28_INVbb:      is1_v_nstall28_INVB     <= not( is1_v_nstall28_INVA_b );
is1_v_nstall29_INVbb:      is1_v_nstall29_INVB     <= not( is1_v_nstall29_INVA_b );
is1_v_nstall30_INVbb:      is1_v_nstall30_INVB     <= not( is1_v_nstall30_INVA_b );
is1_v_nstall31_INVbb:      is1_v_nstall31_INVB     <= not( is1_v_nstall31_INVA_b );
is1_v_nstall32_INVbb:      is1_v_nstall32_INVB     <= not( is1_v_nstall32_INVA_b );


   iu_au_is0_flush_b <= not iu_au_is0_flush ;
   iu_au_is1_flush_b <= not iu_au_is1_flush ;

  cmd_is0_40_part <= ld_st_is0 and isfu_dec_is0 ;
  cmd_is0_41_part <= st_is0    and isfu_dec_is0 ;
  cmd_is0_43_part <= is0_ins_v and isfu_dec_is0 and not is0_invalid_kill_uc;
  cmd_is0_50_part <= bubble3   and isfu_dec_is0 ;
    

 cmd_is1_go_06: cmd_is0_go_b( 6) <= not( is1_v_nstall01_INVB and                          is0_frt(1)                 );         
 cmd_is1_go_07: cmd_is0_go_b( 7) <= not( is1_v_nstall02_INVB and                          is0_frt(2)                 );
 cmd_is1_go_08: cmd_is0_go_b( 8) <= not( is1_v_nstall03_INVB and                          is0_frt(3)                 );
 cmd_is1_go_09: cmd_is0_go_b( 9) <= not( is1_v_nstall04_INVB and                          is0_frt(4)                 );
 cmd_is1_go_10: cmd_is0_go_b(10) <= not( is1_v_nstall05_INVB and                          is0_frt(5)                 );
 cmd_is1_go_11: cmd_is0_go_b(11) <= not( is1_v_nstall06_INVB and                          is0_fra_or_frs(1)          );         
 cmd_is1_go_12: cmd_is0_go_b(12) <= not( is1_v_nstall07_INVB and                          is0_fra_or_frs(2)          );
 cmd_is1_go_13: cmd_is0_go_b(13) <= not( is1_v_nstall08_INVB and                          is0_fra_or_frs(3)          );
 cmd_is1_go_14: cmd_is0_go_b(14) <= not( is1_v_nstall09_INVB and                          is0_fra_or_frs(4)          );
 cmd_is1_go_15: cmd_is0_go_b(15) <= not( is1_v_nstall10_INVB and                          is0_fra_or_frs(5)          );
 cmd_is1_go_16: cmd_is0_go_b(16) <= not( is1_v_nstall11_INVB and                          is0_ins_dly(16)            );
 cmd_is1_go_17: cmd_is0_go_b(17) <= not( is1_v_nstall12_INVB and                          is0_ins_dly(17)            );
 cmd_is1_go_18: cmd_is0_go_b(18) <= not( is1_v_nstall13_INVB and                          is0_ins_dly(18)            );
 cmd_is1_go_19: cmd_is0_go_b(19) <= not( is1_v_nstall14_INVB and                          is0_ins_dly(19)            );
 cmd_is1_go_20: cmd_is0_go_b(20) <= not( is1_v_nstall15_INVB and                          is0_ins_dly(20)            );
 cmd_is1_go_21: cmd_is0_go_b(21) <= not( is1_v_nstall16_INVB and                          is0_ins_dly(21)            );
 cmd_is1_go_22: cmd_is0_go_b(22) <= not( is1_v_nstall17_INVB and                          is0_ins_dly(22)            );
 cmd_is1_go_23: cmd_is0_go_b(23) <= not( is1_v_nstall18_INVB and                          is0_ins_dly(23)            );
 cmd_is1_go_24: cmd_is0_go_b(24) <= not( is1_v_nstall19_INVB and                          is0_ins_dly(24)            );
 cmd_is1_go_25: cmd_is0_go_b(25) <= not( is1_v_nstall19_INVB and                          is0_ins_dly(25)            );
cmd_is0_go_b(26) <= tidn;               
cmd_is0_go_b(27) <= tidn;               
cmd_is0_go_b(28) <= tidn;               
cmd_is0_go_b(29) <= tidn;               
cmd_is0_go_b(30) <= tidn;               
cmd_is0_go_b(31) <= tidn;               

spare_unused(35 to 40) <= cmd_is0_go_b(26 to 31);


 cmd_is1_go_32: cmd_is0_go_b(32) <= not( is1_v_nstall20_INVB and                          is0_frt(0)                 );
 cmd_is1_go_33: cmd_is0_go_b(33) <= not( is1_v_nstall20_INVB and                          is0_fra_or_frs(0)          );
 cmd_is1_go_34: cmd_is0_go_b(34) <= not( is1_v_nstall21_INVB and                          iu_au_is0_ucode_ext(2)     );
 cmd_is1_go_35: cmd_is0_go_b(35) <= not( is1_v_nstall21_INVB and                          iu_au_is0_ucode_ext(3)     );
 cmd_is1_go_36: cmd_is0_go_b(36) <= not( is1_v_nstall22_INVB and                          tv                         );
 cmd_is1_go_37: cmd_is0_go_b(37) <= not( is1_v_nstall22_INVB and                          av                         );
 cmd_is1_go_38: cmd_is0_go_b(38) <= not( is1_v_nstall23_INVB and                          bv                         );
 cmd_is1_go_39: cmd_is0_go_b(39) <= not( is1_v_nstall23_INVB and                          cv                         );
 cmd_is1_go_40: cmd_is0_go_b(40) <= not( is1_v_nstall29_INVB and iu_au_is0_flush_b    and cmd_is0_40_part            );
 cmd_is1_go_41: cmd_is0_go_b(41) <= not( is1_v_nstall30_INVB and iu_au_is0_flush_b    and cmd_is0_41_part            );
 cmd_is1_go_42: cmd_is0_go_b(42) <= not( is1_v_nstall24_INVB and                          cr_writer                  );
 cmd_is1_go_43: cmd_is0_go_b(43) <= not( is1_v_nstall31_INVB and iu_au_is0_flush_b    and cmd_is0_43_part            );
 cmd_is1_go_44: cmd_is0_go_b(44) <= not( is1_v_nstall24_INVB and                          is0_in_divsqrt_mode_or1d   );
 cmd_is1_go_45: cmd_is0_go_b(45) <= not( is1_v_nstall25_INVB and                          tidn                       );
 cmd_is1_go_46: cmd_is0_go_b(46) <= ucode_restart; 
 cmd_is1_go_47: cmd_is0_go_b(47) <= not( is1_v_nstall26_INVB and                          is0_is_ucode               );
 cmd_is1_go_48: cmd_is0_go_b(48) <= not( is1_v_nstall26_INVB and                          iu_au_is0_cr_setter        );
 cmd_is1_go_49: cmd_is0_go_b(49) <= not( is1_v_nstall27_INVB and                          final_fmul_uc              );
 cmd_is1_go_50: cmd_is0_go_b(50) <= not( is1_v_nstall27_INVB and                          cmd_is0_50_part            );
 cmd_is1_go_51: cmd_is0_go_b(51) <= not( is1_v_nstall28_INVB and                          prebubble1                 );
 cmd_is1_go_52: cmd_is0_go_b(52) <= not( is1_v_nstall32_INVB and iu_au_is0_flush_b    and ignore_flush_is0           );
 cmd_is1_go_53: cmd_is0_go_b(53) <= not( is1_v_nstall28_INVB and                          is0_to_ucode               );  




 cmd_is1_ho_06: cmd_is1_ho_b( 6) <= not( is1_v_nstall01_INVA_b and                           is1_frt_buf(2) );
 cmd_is1_ho_07: cmd_is1_ho_b( 7) <= not( is1_v_nstall02_INVA_b and                           is1_frt_buf(3) );
 cmd_is1_ho_08: cmd_is1_ho_b( 8) <= not( is1_v_nstall03_INVA_b and                           is1_frt_buf(4) );
 cmd_is1_ho_09: cmd_is1_ho_b( 9) <= not( is1_v_nstall04_INVA_b and                           is1_frt_buf(5) );
 cmd_is1_ho_10: cmd_is1_ho_b(10) <= not( is1_v_nstall05_INVA_b and                           is1_frt_buf(6) );
 cmd_is1_ho_11: cmd_is1_ho_b(11) <= not( is1_v_nstall06_INVA_b and                           is1_fra_buf(2) );
 cmd_is1_ho_12: cmd_is1_ho_b(12) <= not( is1_v_nstall07_INVA_b and                           is1_fra_buf(3) );
 cmd_is1_ho_13: cmd_is1_ho_b(13) <= not( is1_v_nstall08_INVA_b and                           is1_fra_buf(4) );
 cmd_is1_ho_14: cmd_is1_ho_b(14) <= not( is1_v_nstall09_INVA_b and                           is1_fra_buf(5) );
 cmd_is1_ho_15: cmd_is1_ho_b(15) <= not( is1_v_nstall10_INVA_b and                           is1_fra_buf(6) );
 cmd_is1_ho_16: cmd_is1_ho_b(16) <= not( is1_v_nstall11_INVA_b and                           is1_frb_buf(2) );
 cmd_is1_ho_17: cmd_is1_ho_b(17) <= not( is1_v_nstall12_INVA_b and                           is1_frb_buf(3) );
 cmd_is1_ho_18: cmd_is1_ho_b(18) <= not( is1_v_nstall13_INVA_b and                           is1_frb_buf(4) );
 cmd_is1_ho_19: cmd_is1_ho_b(19) <= not( is1_v_nstall14_INVA_b and                           is1_frb_buf(5) );
 cmd_is1_ho_20: cmd_is1_ho_b(20) <= not( is1_v_nstall15_INVA_b and                           is1_frb_buf(6) );
 cmd_is1_ho_21: cmd_is1_ho_b(21) <= not( is1_v_nstall16_INVA_b and                           is1_frc_buf(2) );
 cmd_is1_ho_22: cmd_is1_ho_b(22) <= not( is1_v_nstall16_INVA_b and                           is1_frc_buf(3) );
 cmd_is1_ho_23: cmd_is1_ho_b(23) <= not( is1_v_nstall17_INVA_b and                           is1_frc_buf(4) );
 cmd_is1_ho_24: cmd_is1_ho_b(24) <= not( is1_v_nstall17_INVA_b and                           is1_frc_buf(5) );
 cmd_is1_ho_25: cmd_is1_ho_b(25) <= not( is1_v_nstall18_INVA_b and                           is1_frc_buf(6) );
cmd_is1_ho_b(26) <= tidn;               
cmd_is1_ho_b(27) <= tidn;               
cmd_is1_ho_b(28) <= tidn;               
cmd_is1_ho_b(29) <= tidn;               
cmd_is1_ho_b(30) <= tidn;               
cmd_is1_ho_b(31) <= tidn;               
spare_unused(41 to 46) <= cmd_is1_ho_b(26 to 31);

 cmd_is1_ho_32: cmd_is1_ho_b(32) <= not( is1_v_nstall18_INVA_b and                           is1_frt_buf(1) );
 cmd_is1_ho_33: cmd_is1_ho_b(33) <= not( is1_v_nstall19_INVA_b and                           is1_fra_buf(1) );
 cmd_is1_ho_34: cmd_is1_ho_b(34) <= not( is1_v_nstall19_INVA_b and                           is1_frb_buf(1) );
 cmd_is1_ho_35: cmd_is1_ho_b(35) <= not( is1_v_nstall20_INVA_b and                           is1_frc_buf(1) );
 cmd_is1_ho_36: cmd_is1_ho_b(36) <= not( is1_v_nstall20_INVA_b and                           cmd_is1_l2(36) );
 cmd_is1_ho_37: cmd_is1_ho_b(37) <= not( is1_v_nstall21_INVA_b and                           cmd_is1_l2(37) );
 cmd_is1_ho_38: cmd_is1_ho_b(38) <= not( is1_v_nstall21_INVA_b and                           cmd_is1_l2(38) );
 cmd_is1_ho_39: cmd_is1_ho_b(39) <= not( is1_v_nstall22_INVA_b and                           cmd_is1_l2(39) );
 cmd_is1_ho_40: cmd_is1_ho_b(40) <= not( is1_v_nstall26_INVA_b and  iu_au_is1_flush_b  and is1_stall   and cmd_is1_l2(40) );
 cmd_is1_ho_41: cmd_is1_ho_b(41) <= not( is1_v_nstall27_INVA_b and  iu_au_is1_flush_b  and is1_stall   and cmd_is1_l2(41) );
 cmd_is1_ho_42: cmd_is1_ho_b(42) <= not( is1_v_nstall22_INVA_b and                           cmd_is1_l2(42) );
 cmd_is1_ho_43: cmd_is1_ho_b(43) <= not( is1_v_nstall28_INVA_b and  iu_au_is1_flush_b  and is1_stall   and cmd_is1_l2(43) );
 cmd_is1_ho_44: cmd_is1_ho_b(44) <= not( is1_v_nstall29_INVA_b and  iu_au_is1_flush_b  and is1_stall   and cmd_is1_l2(44) );
 cmd_is1_ho_45: cmd_is1_ho_b(45) <= not( is1_v_nstall23_INVA_b and                           cmd_is1_l2(45) );
 cmd_is1_ho_46: cmd_is1_ho_b(46) <= tidn;  
 cmd_is1_ho_47: cmd_is1_ho_b(47) <= not( is1_v_nstall24_INVA_b and                           cmd_is1_l2(47) );
 cmd_is1_ho_48: cmd_is1_ho_b(48) <= not( is1_v_nstall24_INVA_b and                           cmd_is1_l2(48) );
 cmd_is1_ho_49: cmd_is1_ho_b(49) <= not( is1_v_nstall30_INVA_b and  iu_au_is1_flush_b  and is1_stall  and cmd_is1_l2(49) );
 cmd_is1_ho_50: cmd_is1_ho_b(50) <= not( is1_v_nstall31_INVA_b and  iu_au_is1_flush_b  and is1_stall  and cmd_is1_l2(50) );
 cmd_is1_ho_51: cmd_is1_ho_b(51) <= not( is1_v_nstall25_INVA_b and                           cmd_is1_l2(51) );
 cmd_is1_ho_52: cmd_is1_ho_b(52) <= not( is1_v_nstall32_INVA_b and  iu_au_is1_flush_b  and is1_stall   and cmd_is1_l2(52) );
 cmd_is1_ho_53: cmd_is1_ho_b(53) <= not( is1_v_nstall25_INVA_b and                           cmd_is1_l2(53) );






   is1_cmd_din_a:  cmd_is0_ld(06 to 25) <= not( cmd_is0_go_b(6 to 25) and cmd_is1_ho_b(6 to 25) );
   is1_cmd_din_b:  cmd_is0_ld(32 to 53) <= not( cmd_is0_go_b(32 to 53) and cmd_is1_ho_b(32 to 53) );


   cmd_is0_ld(26) <= ucmodelat_din;
               
   cmd_is0_ld(27 to 31) <= cmd_is1_l2(27 to 31);  


   cmd_reg_is1: tri_rlmreg_p
   generic map (init => 0, expand_type => expand_type, needs_sreset => needs_sreset, ibuf => false, width => 48)
   port map (
      vd       => vdd,     gd       => gnd,
      forcee => forcee,   delay_lclkr => delay_lclkr,
      nclk     => nclk,    mpw1_b      => mpw1_b,
      act      => tiup,    mpw2_b      => mpw2_b,
      thold_b  => pc_iu_func_sl_thold_0_b,
      sg       => pc_iu_sg_0,
      scin     => cmd_is1_scin(6 to 53),
      scout    => cmd_is1_scout(6 to 53),
      din            => cmd_is0_ld,
      dout           => cmd_is1_l2
      );



   ucmodelat_dout <= cmd_is1_l2(26);

   i_afd_fmul_uc_is1 <= cmd_is1_l2(49);
   is1_fmul_uc <= cmd_is1_l2(49);
   
   i_afd_is1_is_ucode     <= cmd_is1_l2(47);  
   i_afd_is1_to_ucode     <= cmd_is1_l2(53);  
   is1_is_ucode     <= cmd_is1_l2(47);  
   is1_to_ucode     <= cmd_is1_l2(53);  
     
   spare_unused(3) <= tidn;
   spare_unused(8 to 11) <= tidn & tidn & tidn & tidn;
   



        is1_instr_v   <= cmd_is1_l2(43);  
        is1_ldst      <= cmd_is1_l2(40);   
        is1_st     <= cmd_is1_l2(41);
        


                                    
        i_afd_is1_frt(0 to 6) <=  tidn & cmd_is1_l2(32) & cmd_is1_l2(06 to 10);
 
        i_afd_is1_fra(0 to 6) <=  tidn & cmd_is1_l2(33) & cmd_is1_l2(11 to 15);

        i_afd_is1_frb(0 to 6) <=  tidn & cmd_is1_l2(34) & cmd_is1_l2(16 to 20);     

        i_afd_is1_frc(0 to 6) <=  tidn & cmd_is1_l2(35) & cmd_is1_l2(21 to 25);     

   is1frtbufa:     is1_frt_buf_b <= not (cmd_is1_l2(32) & cmd_is1_l2(06 to 10));
   is1frabufa:     is1_fra_buf_b <= not (cmd_is1_l2(33) & cmd_is1_l2(11 to 15));
   is1frbbufa:     is1_frb_buf_b <= not (cmd_is1_l2(34) & cmd_is1_l2(16 to 20));
   is1frcbufa:     is1_frc_buf_b <= not (cmd_is1_l2(35) & cmd_is1_l2(21 to 25)); 
     
   is1frtbufb:     is1_frt_buf <= not is1_frt_buf_b;
   is1frabufb:     is1_fra_buf <= not is1_fra_buf_b;
   is1frbbufb:     is1_frb_buf <= not is1_frb_buf_b;
   is1frcbufb:     is1_frc_buf <= not is1_frc_buf_b;
   
   i_afd_is1_frt_buf <= is1_frt_buf;
   i_afd_is1_fra_buf <= is1_fra_buf;
   i_afd_is1_frb_buf <= is1_frb_buf;
   i_afd_is1_frc_buf <= is1_frc_buf;
   
        
        i_afd_is1_est_bubble3 <= cmd_is1_l2(50);
        i_afd_is1_prebubble1  <= cmd_is1_l2(51) or cmd_is1_l2(52);  

        i_afd_is1_instr_v     <= is1_instr_v;


        i_afd_is1_cr_writer   <= cmd_is1_l2(42);
        is1_cr_writer   <= cmd_is1_l2(42);
        spare_unused(47) <= cmd_is1_l2(46);
        
        i_afd_is1_cr_setter   <= cmd_is1_l2(48);  
        is1_cr_setter         <= cmd_is1_l2(48);  
        
        is1_in_divsqrt_mode_or1d <= cmd_is1_l2(44);
        i_afd_in_ucode_mode_or1d <= is1_in_divsqrt_mode_or1d;
        
        i_afd_is1_frt_v       <= cmd_is1_l2(36);
        i_afd_is1_fra_v       <= cmd_is1_l2(37);      
        i_afd_is1_frb_v       <= cmd_is1_l2(38);      
        i_afd_is1_frc_v       <= cmd_is1_l2(39);      
        is1_frt_v       <= cmd_is1_l2(36);
        is1_fra_v       <= cmd_is1_l2(37);      
        is1_frb_v       <= cmd_is1_l2(38);      
        is1_frc_v       <= cmd_is1_l2(39);
        
        i_afd_is1_instr_ldst_v <= is1_ldst;    
        i_afd_is1_instr_ld_v   <= is1_ldst and not is1_st;    
        i_afd_is1_instr_sto_v  <= is1_st;

        i_afd_is1_divsqrt         <= cmd_is1_l2(52);       
        i_afd_is1_stall_rep       <= is1_stall;

        
        i_afd_ignore_flush_is1  <= cmd_is1_l2(52) ;  




        


fu_dec_debug(0 to 13) <= is1_instr_v    & 
                         is1_frt_v      & 
                         is1_fra_v      & 
                         is1_frb_v      & 
                         is1_frc_v      & 
                         is1_ldst       & 
                         is1_st         & 
                         is1_cr_setter  & 
                         is1_cr_writer  & 
                         is1_is_ucode   & 
                         is1_to_ucode   & 
                         is1_frt_buf(1) & 
                         is1_fmul_uc    & 
                         is1_in_divsqrt_mode_or1d; 
                                      
                         

  





config_reg_scin(0) <= i_dec_si;
config_reg_scin(1 to 7) <= config_reg_scout(0 to 6);

cmd_is1_scin(6) <= config_reg_scout(7);  
cmd_is1_scin(7 to 53) <= cmd_is1_scout(6 to 52); 

i_dec_so <= cmd_is1_scout(53); 


end iuq_axu_fu_dec;

   





















































































































































































































































































































































































































































































































































































