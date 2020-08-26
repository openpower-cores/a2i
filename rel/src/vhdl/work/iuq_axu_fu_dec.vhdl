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


---------------------------------------------------------------------


entity iuq_axu_fu_dec is
generic(
        expand_type                             : integer := 2; -- 0 - ibm tech, 1 - other );
        fpr_addr_width                          : integer := 5;
        needs_sreset                            : integer := 1);  
port(
   	nclk                                 	: in clk_logic;                
        ---------------------------------------------------------------------
        vdd                                 	: inout power_logic;
        gnd                                 	: inout power_logic;
        ---------------------------------------------------------------------

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
        
        -- AXU interface signals---------------------------------------------
        iu_au_is0_instr_v                  	: in  std_ulogic;
        iu_au_is0_instr                  	: in  std_ulogic_vector(0 to 31);
        iu_au_is0_ucode_ext                  	: in  std_ulogic_vector(0 to 3);  -- TACB
        iu_au_is0_is_ucode                      : in  std_ulogic;   
        iu_au_is0_2ucode                     	: in  std_ulogic;
        iu_au_ucode_restart                    	: in  std_ulogic;
        
        iu_au_is0_cr_setter                    	: in  std_ulogic;  -- from FXU

        iu_au_is1_stall                     	: in  std_ulogic;
        iu_au_is0_flush                        	: in  std_ulogic;
        iu_au_is1_flush                        	: in  std_ulogic;

        iu_au_config_iucr                       : in  std_ulogic_vector(0 to 7);  -- 0: graphics mode, 1: disable axu bypass 5: disable clock gating
        ifdp_ex5_fmul_uc_complete               : in  std_ulogic; 

        -- out to AXU
        au_iu_is0_i_dec_b                  	        : out  std_ulogic;  -- decoded a valid FU instruction (inverted)
        au_iu_is0_to_ucode                  	        : out  std_ulogic;   
        au_iu_is0_ucode_only       	                : out  std_ulogic; 

        au_iu_is0_ldst                     	  : out  std_ulogic;  -- load or store
        au_iu_is0_ldst_v                     	  : out  std_ulogic;  -- load or store
        au_iu_is0_st_v                     	  : out  std_ulogic;  -- store
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
        ---------------------------------------------------------------------
        i_afd_is1_is_ucode                      : out  std_ulogic;      
        i_afd_is1_to_ucode                      : out  std_ulogic;

        i_afd_in_ucode_mode_or1d                : out  std_ulogic; 
        
        i_afd_config_iucr                       : out  std_ulogic_vector(1 to 7);  -- IUCR2(33 to 39)
         i_afd_fmul_uc_is1                      : out  std_ulogic;
         
        i_afd_is1_fra_v                     	: out  std_ulogic;                
        i_afd_is1_frb_v                     	: out  std_ulogic;                
        i_afd_is1_frc_v                     	: out  std_ulogic;
        i_afd_is1_frt_v                     	: out  std_ulogic;
        i_afd_is1_prebubble1                    : out  std_ulogic;               
        i_afd_is1_est_bubble3                   : out  std_ulogic;

        --i_afd_is1_cr_user                       : out  std_ulogic;
        i_afd_is1_cr_setter                     : out  std_ulogic;  --  FXU alters CR
        i_afd_is1_cr_writer                     : out  std_ulogic;  --  AXU alters CR
              
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

--------------------------------------------------------------------------------------------------------------------------------------------------------

architecture iuq_axu_fu_dec of iuq_axu_fu_dec is

  signal  tidn                           : std_ulogic;
  signal  tiup                           : std_ulogic;



  signal iu_au_config_iucr_int           : std_ulogic_vector(0 to 7);
  signal iu_au_config_iucr_l2           : std_ulogic_vector(0 to 7);
  signal iu_au_config_iucr_din           : std_ulogic_vector(0 to 7);
  signal is0_instr : std_ulogic_vector(00 to 31);        
  signal pri_is0 : std_ulogic_vector(0 to 5);    -- primary opcode
  signal sec_is0 : std_ulogic_vector(20 to 31);  -- secondary opcode
  signal av,bv,cv,tv : std_ulogic;       -- source/target valids
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

   

-- update # of inputs and outputs   .i xx   .o xx
-- run "espvhdlexpand iuq_axu_fu_dec.vhdl > iuq_axu_fu_dec_new.vhdl" to regenerate logic below table
--
   
--@@ ESPRESSO TABLE START @@
-- .i 20
-- .o 32
-- .ilb pri_is0(0) pri_is0(1) pri_is0(2) pri_is0(3) pri_is0(4) pri_is0(5)
--      is0_instr(16) is0_instr(17)
--      sec_is0(20) sec_is0(21) sec_is0(22) sec_is0(23) sec_is0(24) sec_is0(25) sec_is0(26) sec_is0(27) sec_is0(28) sec_is0(29) sec_is0(30) sec_is0(31)
-- .ob  isfu_dec_is0 tv av bv cv
--      bubble3 prebubble1
--      ld_st_is0 st_is0 indexed update_form forcealign single_precision_ldst int_word_ldst sign_ext_ldst ldst_extpid io_port io_port_ext
--      size(0) size(1) size(2) size(3) size(4) size(5)
--      cr_writer mffgpr mftgpr fdiv_is0
--      fsqrt_is0   only_from_ucode final_fmul_uc only_graphics_mode
-- .type fd
--#
--#
-- ###################################################################################################################
--#                                                                       s
--#                                                                       i
--#                                                                       n
--#                                                                       g                                         o
--#                                                                       l                                         n
--#                                                                       e                                         l
--#                                                                       |                                     o   y
--#                                                                       p                                     n   |
--#                                                                       r i s                                 l f g
--#                                                                       e n i                                 y i r
--#                                                                   u   c t g l  i                            | n a
--#                                                        p          p f i | n d  o                            f a p
--#                                                        r          d o s w | s  |               c            r l h
--#                                                        e    l     a r i o e t  p     LD/ST     r            o | i
--#                                                      b b    d   i t c o r x | io     size                   m f c
--#                                                      u u        n e e n d t e or     in        w   mm       | m s
--#                                                      b b    o s d   a | | | x |t     bytes     r   ff  f    u u |
--#pri_is000      sec_is0        i                       b b    r t e f l l l l t p|     1to16     i   ft fs    c l m
--#                              s                       l l      o x o i d d d p oe     pwrs      t   gg dq    o | o
--#000000   112 2222222223 3     F      T   A   B   C    e e    s r e r g s s s i rx     oftwo     e   pp ir    d u d
--#012345   670 1234567890 1     U      V   V   V   V    3 1    t e d m n t t t d tt    012345     r   rr vt    e c e
-- ############# ###############################################################################################################
                                                                                                                      
-- 000000   --- ---------- -     0      -   -   -   -    - -    0 0 - 0 - - - - 0 00    ------     -   00 00    0 0 0 # reserved
-- 000001   --- ---------- -     0      -   -   -   -    - -    0 0 - 0 - - - - 0 00    ------     -   00 00    0 0 0 # open for vxu new instructions
-- 000010   --- ---------- -     0      -   -   -   -    - -    0 0 - 0 - - - - 0 00    ------     -   00 00    0 0 0
-- 000011   --- ---------- -     0      -   -   -   -    - -    0 0 - 0 - - - - 0 00    ------     -   00 00    0 0 0
                                                                                                                      
-- 000100   --- 000------- -     0      -   -   -   -    - -    0 0 - 0 - - - - 0 00    ------     -   00 00    0 0 0
-- 000100   --- 0010------ -     0      -   -   -   -    - -    0 0 - 0 - - - - 0 00    ------     -   00 00    0 0 0
-- 000100   --- 00110000-- -     0      -   -   -   -    - -    0 0 - 0 - - - - 0 00    ------     -   00 00    0 0 0
-- 000100   --- 0011000100 -     0      -   -   -   -    - -    0 0 - 0 - - - - 0 00    ------     -   00 00    0 0 0
-- 000100   --- 0011000101 1     0      -   -   -   -    - -    0 0 - 0 - - - - 0 00    ------     -   00 00    0 0 0
-- 000100   --- 001100011- -     0      -   -   -   -    - -    0 0 - 0 - - - - 0 00    ------     -   00 00    0 0 0
-- 000100   --- 0011001--- -     0      -   -   -   -    - -    0 0 - 0 - - - - 0 00    ------     -   00 00    0 0 0
-- 000100   --- 001101---- -     0      -   -   -   -    - -    0 0 - 0 - - - - 0 00    ------     -   00 00    0 0 0
-- 000100   --- 00111000-- -     0      -   -   -   -    - -    0 0 - 0 - - - - 0 00    ------     -   00 00    0 0 0
-- 000100   --- 0011100100 -     0      -   -   -   -    - -    0 0 - 0 - - - - 0 00    ------     -   00 00    0 0 0
                                                                                                                      
-- 000100   --- 0011100101 1     0      -   -   -   -    - -    0 0 - 0 - - - - 0 00    ------     -   00 00    0 0 0
-- 000100   --- 001110011- -     0      -   -   -   -    - -    0 0 - 0 - - - - 0 00    ------     -   00 00    0 0 0
-- 000100   --- 0011101--- -     0      -   -   -   -    - -    0 0 - 0 - - - - 0 00    ------     -   00 00    0 0 0
-- 000100   --- 001111---- -     0      -   -   -   -    - -    0 0 - 0 - - - - 0 00    ------     -   00 00    0 0 0
-- 000100   --- 01-------- -     0      -   -   -   -    - -    0 0 - 0 - - - - 0 00    ------     -   00 00    0 0 0
-- 000100   --- 1--------- -     0      -   -   -   -    - -    0 0 - 0 - - - - 0 00    ------     -   00 00    0 0 0
                                                                                                                      
-- 000101   --- ---------- -     0      -   -   -   -    - -    0 0 - 0 - - - - 0 00    ------     -   00 00    0 0 0
-- 000110   --- ---------- -     0      -   -   -   -    - -    0 0 - 0 - - - - 0 00    ------     -   00 00    0 0 0
-- 000111   --- ---------- -     0      -   -   -   -    - -    0 0 - 0 - - - - 0 00    ------     -   00 00    0 0 0
-- 001---   --- ---------- -     0      -   -   -   -    - -    0 0 - 0 - - - - 0 00    ------     -   00 00    0 0 0
-- 010---   --- ---------- -     0      -   -   -   -    - -    0 0 - 0 - - - - 0 00    ------     -   00 00    0 0 0
-- 01-0--   --- ---------- -     0      -   -   -   -    - -    0 0 - 0 - - - - 0 00    ------     -   00 00    0 0 0
-- 01--0-   --- ---------- -     0      -   -   -   -    - -    0 0 - 0 - - - - 0 00    ------     -   00 00    0 0 0
-- 01---0   --- ---------- -     0      -   -   -   -    - -    0 0 - 0 - - - - 0 00    ------     -   00 00    0 0 0
                                                                                                                      
-- 011111   --- 0000000000 -     0      -   -   -   -    - -    0 0 - 0 - - - - 0 00    ------     -   00 00    0 0 0


-- 011111   001 0000000011 0     1      1   0   0   0    0 0    1 0 1 0 0 1 0 1 0 11    000000     0   10 00    0 0 0 # mfdpx  (DITC to FPR) 4 bytes
-- 011111   011 0000000011 0     1      1   0   0   0    0 0    1 0 1 0 0 0 0 0 0 11    000000     0   10 00    0 0 0 # mfdpx  (DITC to FPR) 8 bytes
-- 011111   1-1 0000000011 0     1      1   0   0   0    0 0    1 0 1 0 0 0 0 0 0 11    000000     0   00 00    0 0 0 # mfdpx  (DITC to FPR) >8 bytes

-- 011111   001 0000000011 1     1      1   0   0   0    0 0    1 0 1 0 0 1 0 1 0 11    000000     1   10 00    0 0 0 # mfdpx. (DITC to FPR) 4 bytes
-- 011111   011 0000000011 1     1      1   0   0   0    0 0    1 0 1 0 0 0 0 0 0 11    000000     1   10 00    0 0 0 # mfdpx. (DITC to FPR) 8 bytes
-- 011111   1-1 0000000011 1     1      1   0   0   0    0 0    1 0 1 0 0 0 0 0 0 11    000000     1   00 00    0 0 0 # mfdpx. (DITC to FPR) >8 bytes

                                                                                                                               
-- 011111   001 0000100011 0     1      1   0   0   0    0 0    1 0 0 0 0 1 0 1 0 10    000000     0   10 00    0 0 0 # mfdp   (DITC to FPR) 4 bytes
-- 011111   011 0000100011 0     1      1   0   0   0    0 0    1 0 0 0 0 0 0 0 0 10    000000     0   10 00    0 0 0 # mfdp   (DITC to FPR) 8 bytes
-- 011111   1-1 0000100011 0     1      1   0   0   0    0 0    1 0 0 0 0 0 0 0 0 10    000000     0   00 00    0 0 0 # mfdp   (DITC to FPR) >8 bytes

-- 011111   001 0000100011 1     1      1   0   0   0    0 0    1 0 0 0 0 1 0 1 0 10    000000     1   10 00    0 0 0 # mfdp.  (DITC to FPR) 4 bytes
-- 011111   011 0000100011 1     1      1   0   0   0    0 0    1 0 0 0 0 0 0 0 0 10    000000     1   10 00    0 0 0 # mfdp.  (DITC to FPR) 8 bytes
-- 011111   1-1 0000100011 1     1      1   0   0   0    0 0    1 0 0 0 0 0 0 0 0 10    000000     1   00 00    0 0 0 # mfdp.  (DITC to FPR) >8 bytes

                                                                                                                               
-- 011111   001 0001000011 0     1      0   1   0   0    0 0    1 1 1 0 0 1 0 1 0 11    000000     0   01 00    0 0 0 # mtdpx  (DITC from FPR) 4 bytes
-- 011111   011 0001000011 0     1      0   1   0   0    0 0    1 1 1 0 0 0 0 0 0 11    000000     0   01 00    0 0 0 # mtdpx  (DITC from FPR) 8 bytes
-- 011111   1-1 0001000011 0     1      0   1   0   0    0 0    1 1 1 0 0 0 0 0 0 11    000000     0   00 00    0 0 0 # mtdpx  (DITC from FPR) >8 bytes

-- 011111   001 0001000011 1     1      0   1   0   0    0 0    1 1 1 0 0 1 0 1 0 11    000000     1   01 00    0 0 0 # mtdpx. (DITC from FPR) 4 bytes
-- 011111   011 0001000011 1     1      0   1   0   0    0 0    1 1 1 0 0 0 0 0 0 11    000000     1   01 00    0 0 0 # mtdpx. (DITC from FPR) 8 bytes
-- 011111   1-1 0001000011 1     1      0   1   0   0    0 0    1 1 1 0 0 0 0 0 0 11    000000     1   00 00    0 0 0 # mtdpx. (DITC from FPR) >8 bytes


-- 011111   001 0001100011 0     1      0   1   0   0    0 0    1 1 0 0 0 1 0 1 0 10    000000     0   01 00    0 0 0 # mtdp   (DITC from FPR) 4 bytes
-- 011111   011 0001100011 0     1      0   1   0   0    0 0    1 1 0 0 0 0 0 0 0 10    000000     0   01 00    0 0 0 # mtdp   (DITC from FPR) 8 bytes
-- 011111   1-1 0001100011 0     1      0   1   0   0    0 0    1 1 0 0 0 0 0 0 0 10    000000     0   00 00    0 0 0 # mtdp   (DITC from FPR) >8 bytes

-- 011111   001 0001100011 1     1      0   1   0   0    0 0    1 1 0 0 0 1 0 1 0 10    000000     1   01 00    0 0 0 # mtdp.  (DITC from FPR) 4 bytes
-- 011111   011 0001100011 1     1      0   1   0   0    0 0    1 1 0 0 0 0 0 0 0 10    000000     1   01 00    0 0 0 # mtdp.  (DITC from FPR) 8 bytes
-- 011111   1-1 0001100011 1     1      0   1   0   0    0 0    1 1 0 0 0 0 0 0 0 10    000000     1   00 00    0 0 0 # mtdp.  (DITC from FPR) >8 bytes

                
-- 011111   --- 01-------- -     0      -   -   -   -    - -    0 0 - 0 - - - - 0 00    ------     -   00 00    0 0 0
-- 011111   --- 100000---- -     0      -   -   -   -    - -    0 0 - 0 - - - - 0 00    ------     -   00 00    0 0 0
-- 011111   --- 10000100-- -     0      -   -   -   -    - -    0 0 - 0 - - - - 0 00    ------     -   00 00    0 0 0
-- 011111   --- 100001010- -     0      -   -   -   -    - -    0 0 - 0 - - - - 0 00    ------     -   00 00    0 0 0
-- 011111   --- 1000010110 -     0      -   -   -   -    - -    0 0 - 0 - - - - 0 00    ------     -   00 00    0 0 0
-- 011111   --- 1000010111 -     1      1   0   0   0    0 0    1 0 1 0 0 1 0 0 0 00    000100     0   00 00    0 0 0 # lfsx
-- 011111   --- 1000011--- -     0      -   -   -   -    - -    0 0 - 0 - - - - 0 00    ------     -   00 00    0 0 0
--
-- 011111   --- 100010---- -     0      -   -   -   -    - -    0 0 - 0 - - - - 0 00    ------     -   00 00    0 0 0
-- 011111   --- 10001100-- -     0      -   -   -   -    - -    0 0 - 0 - - - - 0 00    ------     -   00 00    0 0 0
-- 011111   --- 100011010- -     0      -   -   -   -    - -    0 0 - 0 - - - - 0 00    ------     -   00 00    0 0 0
-- 011111   --- 1000110110 -     0      -   -   -   -    - -    0 0 - 0 - - - - 0 00    ------     -   00 00    0 0 0
-- 011111   --- 1000110111 -     1      1   0   0   0    0 0    1 0 1 1 0 1 0 0 0 00    000100     0   00 00    0 0 0 # lfsux
-- 011111   --- 1000111--- -     0      -   -   -   -    - -    0 0 - 0 - - - - 0 00    ------     -   00 00    0 0 0
-- 011111   --- 100100---- -     0      -   -   -   -    - -    0 0 - 0 - - - - 0 00    ------     -   00 00    0 0 0
-- 011111   --- 10010100-- -     0      -   -   -   -    - -    0 0 - 0 - - - - 0 00    ------     -   00 00    0 0 0
-- 011111   --- 100101010- -     0      -   -   -   -    - -    0 0 - 0 - - - - 0 00    ------     -   00 00    0 0 0
-- 011111   --- 1001010110 -     0      -   -   -   -    - -    0 0 - 0 - - - - 0 00    ------     -   00 00    0 0 0
-- 011111   --- 1001010111 -     1      1   0   0   0    0 0    1 0 1 0 0 0 0 0 0 00    001000     0   00 00    0 0 0 # lfdx
                                                                                                                      
-- 011111   --- 10010110-- -     0      -   -   -   -    - -    0 0 - 0 - - - - 0 00    ------     -   00 00    0 0 0
-- 011111   --- 100101110- -     0      -   -   -   -    - -    0 0 - 0 - - - - 0 00    ------     -   00 00    0 0 0
-- 011111   --- 1001011110 -     0      -   -   -   -    - -    0 0 - 0 - - - - 0 00    ------     -   00 00    0 0 0
-- 011111   --- 1001011111 -     1      1   0   0   0    0 0    1 0 1 0 0 0 0 0 1 00    001000     0   00 00    0 0 0 # lfdepx
-- 011111   --- 100110---- -     0      -   -   -   -    - -    0 0 - 0 - - - - 0 00    ------     -   00 00    0 0 0
-- 011111   --- 10011100-- -     0      -   -   -   -    - -    0 0 - 0 - - - - 0 00    ------     -   00 00    0 0 0
-- 011111   --- 100111010- -     0      -   -   -   -    - -    0 0 - 0 - - - - 0 00    ------     -   00 00    0 0 0
-- 011111   --- 1001110110 -     0      -   -   -   -    - -    0 0 - 0 - - - - 0 00    ------     -   00 00    0 0 0
-- 011111   --- 1001110111 -     1      1   0   0   0    0 0    1 0 1 1 0 0 0 0 0 00    001000     0   00 00    0 0 0 # lfdux
                                                                                                                      
-- 011111   --- 1001111100 -     1      1   0   0   0    0 0    1 0 1 0 0 0 1 1 0 00    000000     0   10 00    1 0 1 # mfifgpr (mffgpr for lfiwax)
-- 011111   --- 1001111101 -     1      1   0   0   0    0 0    1 0 1 0 0 0 1 0 0 00    000000     0   10 00    1 0 1 # mfixfgpr (mffgpr for lfiwzx)
                                                                                                                      
-- 011111   --- 1001111110 -     1      1   0   0   0    0 0    1 0 0 0 0 1 0 0 0 00    000000     0   10 00    1 0 1 # mfsfgpr (mffgpr for lfs, lfsu single)
-- 011111   --- 1001111111 -     1      1   0   0   0    0 0    1 0 0 0 0 0 0 0 0 00    000000     0   10 00    1 0 1 # mffgpr (mffgpr for lfd, lfdu double)
                                                                                                                      
-- 011111   --- 101000---- -     0      -   -   -   -    - -    0 0 - 0 - - - - 0 00    ------     -   00 00    0 0 0
-- 011111   --- 10100100-- -     0      -   -   -   -    - -    0 0 - 0 - - - - 0 00    ------     -   00 00    0 0 0
-- 011111   --- 101001010- -     0      -   -   -   -    - -    0 0 - 0 - - - - 0 00    ------     -   00 00    0 0 0
-- 011111   --- 1010010110 -     0      -   -   -   -    - -    0 0 - 0 - - - - 0 00    ------     -   00 00    0 0 0
-- 011111   --- 1010010111 -     1      0   1   0   0    0 0    1 1 1 0 0 1 0 0 0 00    000100     0   00 00    0 0 0 # stfsx
-- 011111   --- 1010011--- -     0      -   -   -   -    - -    0 0 - 0 - - - - 0 00    ------     -   00 00    0 0 0
--
-- 011111   --- 101010---- -     0      -   -   -   -    - -    0 0 - 0 - - - - 0 00    ------     -   00 00    0 0 0
-- 011111   --- 10101100-- -     0      -   -   -   -    - -    0 0 - 0 - - - - 0 00    ------     -   00 00    0 0 0
-- 011111   --- 101011010- -     0      -   -   -   -    - -    0 0 - 0 - - - - 0 00    ------     -   00 00    0 0 0
-- 011111   --- 1010110110 -     0      -   -   -   -    - -    0 0 - 0 - - - - 0 00    ------     -   00 00    0 0 0
-- 011111   --- 1010110111 -     1      0   1   0   0    0 0    1 1 1 1 0 1 0 0 0 00    000100     0   00 00    0 0 0 # stfsux
-- 011111   --- 1010111--- -     0      -   -   -   -    - -    0 0 - 0 - - - - 0 00    ------     -   00 00    0 0 0
--
-- 011111   --- 101100---- -     0      -   -   -   -    - -    0 0 - 0 - - - - 0 00    ------     -   00 00    0 0 0
-- 011111   --- 10110100-- -     0      -   -   -   -    - -    0 0 - 0 - - - - 0 00    ------     -   00 00    0 0 0
-- 011111   --- 101101010- -     0      -   -   -   -    - -    0 0 - 0 - - - - 0 00    ------     -   00 00    0 0 0
-- 011111   --- 1011010110 -     0      -   -   -   -    - -    0 0 - 0 - - - - 0 00    ------     -   00 00    0 0 0
-- 011111   --- 1011010111 -     1      0   1   0   0    0 0    1 1 1 0 0 0 0 0 0 00    001000     0   00 00    0 0 0 # stfdx
-- 011111   --- 10110110-- -     0      -   -   -   -    - -    0 0 - 0 - - - - 0 00    ------     -   00 00    0 0 0
-- 011111   --- 1011011100 -     0      -   -   -   -    - -    0 0 - 0 - - - - 0 00    ------     -   00 00    0 0 0
-- 011111   --- 1011011101 -     1      0   0   1   0    0 0    1 1 0 0 0 0 1 0 0 00    000000     0   01 00    1 0 1 # mfitgpr (mftgpr for stfiwx integer word)
-- 011111   --- 1011011110 -     0      -   -   -   -    - -    0 0 - 0 - - - - 0 00    ------     -   00 00    0 0 0
-- 011111   --- 1011011111 -     1      0   1   0   0    0 0    1 1 1 0 0 0 0 0 1 00    001000     0   00 00    0 0 0 # stfdepx
                                                                                                                      
-- 011111   --- 101110---- -     0      -   -   -   -    - -    0 0 - 0 - - - - 0 00    ------     -   00 00    0 0 0
-- 011111   --- 10111100-- -     0      -   -   -   -    - -    0 0 - 0 - - - - 0 00    ------     -   00 00    0 0 0
-- 011111   --- 101111010- -     0      -   -   -   -    - -    0 0 - 0 - - - - 0 00    ------     -   00 00    0 0 0
-- 011111   --- 1011110110 -     0      -   -   -   -    - -    0 0 - 0 - - - - 0 00    ------     -   00 00    0 0 0
-- 011111   --- 1011110111 -     1      0   1   0   0    0 0    1 1 1 1 0 0 0 0 0 00    001000     0   00 00    0 0 0 # stfdux
                                                                                                                      
-- 011111   --- 1011111110 -     1      0   0   1   0    0 0    1 1 0 0 0 1 0 0 0 00    000000     0   01 00    1 0 1 # mfstgpr (mftgpr single)
-- 011111   --- 1011111111 -     1      0   0   1   0    0 0    1 1 0 0 0 0 0 0 0 00    000000     0   01 00    1 0 1 # mftgpr (mftgpr double)
                                                                                                                      
-- 011111   --- 110000---- -     0      -   -   -   -    - -    0 0 - 0 - - - - 0 00    ------     -   00 00    0 0 0
-- 011111   --- 11000100-- -     0      -   -   -   -    - -    0 0 - 0 - - - - 0 00    ------     -   00 00    0 0 0
-- 011111   --- 110001010- -     0      -   -   -   -    - -    0 0 - 0 - - - - 0 00    ------     -   00 00    0 0 0
-- 011111   --- 1100010110 -     0      -   -   -   -    - -    0 0 - 0 - - - - 0 00    ------     -   00 00    0 0 0
--#011111   --- 1100010111 -     0      -   -   -   -    - -    0 0 - 0 - - - - 0 00    ------     -   00 00    0 0 0 # lfdpx  (ucoded)
-- 011111   --- 1100011--- -     0      -   -   -   -    - -    0 0 - 0 - - - - 0 00    ------     -   00 00    0 0 0
-- 011111   --- 11001----- -     0      -   -   -   -    - -    0 0 - 0 - - - - 0 00    ------     -   00 00    0 0 0
                                                                                                                      
-- 011111   --- 110100---- -     0      -   -   -   -    - -    0 0 - 0 - - - - 0 00    ------     -   00 00    0 0 0
-- 011111   --- 11010100-- -     0      -   -   -   -    - -    0 0 - 0 - - - - 0 00    ------     -   00 00    0 0 0
-- 011111   --- 110101010- -     0      -   -   -   -    - -    0 0 - 0 - - - - 0 00    ------     -   00 00    0 0 0
-- 011111   --- 1101010110 -     0      -   -   -   -    - -    0 0 - 0 - - - - 0 00    ------     -   00 00    0 0 0
-- 011111   --- 1101010111 -     1      1   0   0   0    0 0    1 0 1 0 0 0 1 1 0 00    000100     0   00 00    0 0 0 # lfiwax
-- 011111   --- 1101011--- -     0      -   -   -   -    - -    0 0 - 0 - - - - 0 00    ------     -   00 00    0 0 0
-- 011111   --- 1101110111 -     1      1   0   0   0    0 0    1 0 1 0 0 0 1 0 0 00    000100     0   00 00    0 0 0 # lfiwzx
                                                                                                                      
-- 011111   --- 111000---- -     0      -   -   -   -    - -    0 0 - 0 - - - - 0 00    ------     -   00 00    0 0 0
-- 011111   --- 11100100-- -     0      -   -   -   -    - -    0 0 - 0 - - - - 0 00    ------     -   00 00    0 0 0
-- 011111   --- 111001010- -     0      -   -   -   -    - -    0 0 - 0 - - - - 0 00    ------     -   00 00    0 0 0
-- 011111   --- 1110010110 -     0      -   -   -   -    - -    0 0 - 0 - - - - 0 00    ------     -   00 00    0 0 0
--#011111   --- 1110010111 -     0      -   -   -   -    - -    0 0 - 0 - - - - 0 00    ------     -   00 00    0 0 0 # stfdpx   (ucoded)
-- 011111   --- 1110011--- -     0      -   -   -   -    - -    0 0 - 0 - - - - 0 00    ------     -   00 00    0 0 0
-- 011111   --- 11101----- -     0      -   -   -   -    - -    0 0 - 0 - - - - 0 00    ------     -   00 00    0 0 0
-- 011111   --- 111100---- -     0      -   -   -   -    - -    0 0 - 0 - - - - 0 00    ------     -   00 00    0 0 0
-- 011111   --- 11110100-- -     0      -   -   -   -    - -    0 0 - 0 - - - - 0 00    ------     -   00 00    0 0 0
-- 011111   --- 111101010- -     0      -   -   -   -    - -    0 0 - 0 - - - - 0 00    ------     -   00 00    0 0 0
-- 011111   --- 1111010110 -     0      -   -   -   -    - -    0 0 - 0 - - - - 0 00    ------     -   00 00    0 0 0
-- 011111   --- 1111010111 -     1      0   1   0   0    0 0    1 1 1 0 0 0 1 0 0 00    000100     0   00 00    0 0 0 # stfiwx
-- 011111   --- 1111011--- -     0      -   -   -   -    - -    0 0 - 0 - - - - 0 00    ------     -   00 00    0 0 0
-- 011111   --- 11111----- -     0      -   -   -   -    - -    0 0 - 0 - - - - 0 00    ------     -   00 00    0 0 0
                                                                                                                      
-- 10----   --- ---------- -     0      -   -   -   -    - -    0 0 - 0 - - - - 0 00    ------     -   00 00    0 0 0
                                                                                                                      
-- 110000   --- ---------- -     1      1   0   0   0    0 0    1 0 0 0 0 1 0 0 0 00    000100     0   00 00    0 0 0 # lfs
                                                                                                                      
-- 110001   --- ---------- -     1      1   0   0   0    0 0    1 0 0 1 0 1 0 0 0 00    000100     0   00 00    0 0 0 # lfsu
                                                                                                                      
-- 110010   --- ---------- -     1      1   0   0   0    0 0    1 0 0 0 0 0 0 0 0 00    001000     0   00 00    0 0 0 # lfd
-- 110011   --- ---------- -     1      1   0   0   0    0 0    1 0 0 1 0 0 0 0 0 00    001000     0   00 00    0 0 0 # lfdu
-- 110100   --- ---------- -     1      0   1   0   0    0 0    1 1 0 0 0 1 0 0 0 00    000100     0   00 00    0 0 0 # stfs
                                                                                                                      
-- 110101   --- ---------- -     1      0   1   0   0    0 0    1 1 0 1 0 1 0 0 0 00    000100     0   00 00    0 0 0 # stfsu
--
-- 110110   --- ---------- -     1      0   1   0   0    0 0    1 1 0 0 0 0 0 0 0 00    001000     0   00 00    0 0 0 # stfd
--
-- 110111   --- ---------- -     1      0   1   0   0    0 0    1 1 0 1 0 0 0 0 0 00    001000     0   00 00    0 0 0 # stfdu
--
-- 111000   --- ---------- -     0      -   -   -   -    - -    0 0 - 0 - - - - 0 00    ------     -   00 00    0 0 0
--
--#111001   --- ---------0 0     0      -   -   -   -    - -    0 0 - 0 - - - - 0 00    ------     -   00 00    0 0 0 # lfdp    (ucoded)
                                                                                                                      
-- 111001   --- ---------0 1     0      -   -   -   -    - -    0 0 - 0 - - - - 0 00    ------     -   00 00    0 0 0
-- 111001   --- ---------1 -     0      -   -   -   -    - -    0 0 - 0 - - - - 0 00    ------     -   00 00    0 0 0
--
-- 111010   --- ---------- -     0      -   -   -   -    - -    0 0 - 0 - - - - 0 00    ------     -   00 00    0 0 0
                                                                                                                      
-- 111011   --- 000--0---- -     0      -   -   -   -    - -    0 0 - 0 - - - - 0 00    ------     -   00 00    0 0 0
-- 111011   --- 0010-0---- -     0      -   -   -   -    - -    0 0 - 0 - - - - 0 00    ------     -   00 00    0 0 0
-- 111011   --- 00110000-- -     0      -   -   -   -    - -    0 0 - 0 - - - - 0 00    ------     -   00 00    0 0 0
-- 111011   --- 0011000100 -     0      -   -   -   -    - -    0 0 - 0 - - - - 0 00    ------     -   00 00    0 0 0
-- 111011   --- 0011000101 0     1      1   0   1   0    0 0    0 0 0 0 0 - - - 0 00    ------     0   00 00    0 0 1 # fexptes
-- 111011   --- 001100011- -     0      -   -   -   -    - -    0 0 - 0 - - - - 0 00    ------     -   00 00    0 0 0
-- 111011   --- 00110010-- -     0      -   -   -   -    - -    0 0 - 0 - - - - 0 00    ------     -   00 00    0 0 0
-- 111011   --- 001100110- -     0      -   -   -   -    - -    0 0 - 0 - - - - 0 00    ------     -   00 00    0 0 0
-- 111011   --- 0011001110 0     0      1   0   1   0    0 0    0 0 0 0 0 0 0 0 0 00    ------     0   00 00    0 0 0 # fcfiwus  (removed)
-- 111011   --- 0011001110 1     0      1   0   1   0    1 0    0 0 0 0 0 0 0 0 0 00    ------     1   00 00    0 0 0 # fcfiwus. (removed)
-- 111011   --- 0011001111 -     0      -   -   -   -    - -    0 0 - 0 - - - - 0 00    ------     -   00 00    0 0 0
                                                                                                                      
-- 111011   --- 00111000-- -     0      -   -   -   -    - -    0 0 - 0 - - - - 0 00    ------     -   00 00    0 0 0
-- 111011   --- 0011100100 -     0      -   -   -   -    - -    0 0 - 0 - - - - 0 00    ------     -   00 00    0 0 0
-- 111011   --- 0011100101 0     1      1   0   1   0    0 0    0 0 0 0 0 - - - 0 00    ------     0   00 00    0 0 1 # floges
-- 111011   --- 001110011- -     0      -   -   -   -    - -    0 0 - 0 - - - - 0 00    ------     -   00 00    0 0 0
-- 111011   --- 0011101--- -     0      -   -   -   -    - -    0 0 - 0 - - - - 0 00    ------     -   00 00    0 0 0
-- 111011   --- 01---0---- -     0      -   -   -   -    - -    0 0 - 0 - - - - 0 00    ------     -   00 00    0 0 0
-- 111011   --- 10---0---- -     0      -   -   -   -    - -    0 0 - 0 - - - - 0 00    ------     -   00 00    0 0 0
-- 111011   --- 1100-0---- -     0      -   -   -   -    - -    0 0 - 0 - - - - 0 00    ------     -   00 00    0 0 0
-- 111011   --- 1101000--- -     0      -   -   -   -    - -    0 0 - 0 - - - - 0 00    ------     -   00 00    0 0 0
-- 111011   --- 11010010-- -     0      -   -   -   -    - -    0 0 - 0 - - - - 0 00    ------     -   00 00    0 0 0
-- 111011   --- 110100110- -     0      -   -   -   -    - -    0 0 - 0 - - - - 0 00    ------     -   00 00    0 0 0
-- 111011   --- 1101001110 0     1      1   0   1   0    0 0    0 0 0 0 0 0 0 0 0 00    ------     0   00 00    0 0 0 # fcfids
-- 111011   --- 1101001110 1     1      1   0   1   0    1 0    0 0 0 0 0 0 0 0 0 00    ------     1   00 00    0 0 0 # fcfids.
-- 111011   --- 1101001111 -     0      -   -   -   -    - -    0 0 - 0 - - - - 0 00    ------     -   00 00    0 0 0
-- 111011   --- 110110---- -     0      -   -   -   -    - -    0 0 - 0 - - - - 0 00    ------     -   00 00    0 0 0
-- 111011   --- 1110-0---- -     0      -   -   -   -    - -    0 0 - 0 - - - - 0 00    ------     -   00 00    0 0 0
-- 111011   --- 1111000--- -     0      -   -   -   -    - -    0 0 - 0 - - - - 0 00    ------     -   00 00    0 0 0
-- 111011   --- 11110010-- -     0      -   -   -   -    - -    0 0 - 0 - - - - 0 00    ------     -   00 00    0 0 0
-- 111011   --- 111100110- -     0      -   -   -   -    - -    0 0 - 0 - - - - 0 00    ------     -   00 00    0 0 0
-- 111011   --- 1111001110 0     1      1   0   1   0    0 0    0 0 0 0 0 0 0 0 0 00    ------     0   00 00    0 0 0 # fcfidus
-- 111011   --- 1111001110 1     1      1   0   1   0    1 0    0 0 0 0 0 0 0 0 0 00    ------     1   00 00    0 0 0 # fcfidus.
-- 111011   --- 1111001111 -     0      -   -   -   -    - -    0 0 - 0 - - - - 0 00    ------     -   00 00    0 0 0
-- 111011   --- 111110---- -     0      -   -   -   -    - -    0 0 - 0 - - - - 0 00    ------     -   00 00    0 0 0
                                                                                                                      
-- 111011   --- -----10000 -     0      -   -   -   -    - -    0 0 - 0 - - - - 0 00    ------     -   00 00    0 0 0
                                                                                                                      
-- 111011   --- -----10001 0     1      1   1   0   1    0 0    0 0 0 0 0 0 0 0 0 00    ------     0   00 00    1 1 0 # fmuls_uc  (last uc for fdivs, fsqrts) 11/07/07
-- 111011   --- -----10001 1     1      1   1   0   1    1 0    0 0 0 0 0 0 0 0 0 00    ------     1   00 00    1 1 0 # fmuls_uc. (last uc for fdivs, fsqrts) 11/07/07
-- 111011   --- -----10010 0     1      1   1   1   0    0 0    0 0 0 0 0 0 0 0 0 00    ------     0   00 10    0 0 0 # fdivs   (ucoded)
-- 111011   --- -----10010 1     1      1   1   1   0    0 0    0 0 0 0 0 0 0 0 0 00    ------     0   00 10    0 0 0 # fdivs.  (ucoded)
-- 111011   --- -----10011 -     0      -   -   -   -    - -    0 0 - 0 - - - - 0 00    ------     -   00 00    0 0 0
-- 111011   --- -----10100 0     1      1   1   1   0    0 0    0 0 0 0 0 0 0 0 0 00    ------     0   00 00    0 0 0 # fsubs
-- 111011   --- -----10100 1     1      1   1   1   0    1 0    0 0 0 0 0 0 0 0 0 00    ------     1   00 00    0 0 0 # fsubs.
-- 111011   --- -----10101 0     1      1   1   1   0    0 0    0 0 0 0 0 0 0 0 0 00    ------     0   00 00    0 0 0 # fadds
-- 111011   --- -----10101 1     1      1   1   1   0    1 0    0 0 0 0 0 0 0 0 0 00    ------     1   00 00    0 0 0 # fadds.
-- 111011   --- -----10110 0     1      1   0   1   0    0 0    0 0 0 0 0 0 0 0 0 00    ------     0   00 01    0 0 0 # fsqrts  (ucoded)
-- 111011   --- -----10110 1     1      1   0   1   0    0 0    0 0 0 0 0 0 0 0 0 00    ------     0   00 01    0 0 0 # fsqrts. (ucoded)
-- 111011   --- -----10111 -     0      -   -   -   -    - -    0 0 - 0 - - - - 0 00    ------     -   00 00    0 0 0
-- 111011   --- -----11000 0     1      1   0   1   0    0 0    0 0 0 0 0 0 0 0 0 00    ------     0   00 00    0 0 0 # fres
-- 111011   --- -----11000 1     1      1   0   1   0    1 0    0 0 0 0 0 0 0 0 0 00    ------     1   00 00    0 0 0 # fres.
-- 111011   --- -----11001 0     1      1   1   0   1    0 0    0 0 0 0 0 0 0 0 0 00    ------     0   00 00    0 0 0 # fmuls
-- 111011   --- -----11001 1     1      1   1   0   1    1 0    0 0 0 0 0 0 0 0 0 00    ------     1   00 00    0 0 0 # fmuls.
-- 111011   --- -----11010 0     1      1   0   1   0    0 0    0 0 0 0 0 0 0 0 0 00    ------     0   00 00    0 0 0 # frsqrtes
-- 111011   --- -----11010 1     1      1   0   1   0    1 0    0 0 0 0 0 0 0 0 0 00    ------     1   00 00    0 0 0 # frsqrtes.
-- 111011   --- -----11011 -     0      -   -   -   -    - -    0 0 - 0 - - - - 0 00    ------     -   00 00    0 0 0
                                                                                                                      
-- 111011   --- -----11100 0     1      1   1   1   1    0 0    0 0 0 0 0 0 0 0 0 00    ------     0   00 00    0 0 0 # fmsubs
-- 111011   --- -----11100 1     1      1   1   1   1    1 0    0 0 0 0 0 0 0 0 0 00    ------     1   00 00    0 0 0 # fmsubs.
                                                                                                                      
-- 111011   --- -----11101 0     1      1   1   1   1    0 0    0 0 0 0 0 0 0 0 0 00    ------     0   00 00    0 0 0 # fmadds
-- 111011   --- -----11101 1     1      1   1   1   1    1 0    0 0 0 0 0 0 0 0 0 00    ------     1   00 00    0 0 0 # fmadds.
-- 111011   --- -----11110 0     1      1   1   1   1    0 0    0 0 0 0 0 0 0 0 0 00    ------     0   00 00    0 0 0 # fnmsubs
-- 111011   --- -----11110 1     1      1   1   1   1    1 0    0 0 0 0 0 0 0 0 0 00    ------     1   00 00    0 0 0 # fnmsubs.
-- 111011   --- -----11111 0     1      1   1   1   1    0 0    0 0 0 0 0 0 0 0 0 00    ------     0   00 00    0 0 0 # fnmadds
-- 111011   --- -----11111 1     1      1   1   1   1    1 0    0 0 0 0 0 0 0 0 0 00    ------     1   00 00    0 0 0 # fnmadds.
-- 111100   --- ---------- -     0      -   -   -   -    - -    0 0 - 0 - - - - 0 00    ------     -   00 00    0 0 0
                                                                                                                      
--#111101   --- ---------0 0     0      -   -   -   -    - -    0 0 - 0 - - - - 0 00    ------     -   00 00    0 0 0 # stfdp  (ucoded)
                                                                                                                      
-- 111101   --- ---------0 1     0      -   -   -   -    - -    0 0 - 0 - - - - 0 00    ------     -   00 00    0 0 0
-- 111101   --- ---------1 -     0      -   -   -   -    - -    0 0 - 0 - - - - 0 00    ------     -   00 00    0 0 0
                                                                                                                      
                                                                                                                      
-- 111110   --- ---------- -     0      -   -   -   -    - -    0 0 - 0 - - - - 0 00    ------     -   00 00    0 0 0
                                                                                                                      
                                                                                                                      
--#111111   --- -----1---- -     0                              0 0             0 00                            0 0 0
-- 111111   --- 0000000000 -     1      0   1   1   0    0 0    0 0 0 0 0 0 0 0 0 00    ------     1   00 00    0 0 0 # fcmpu
-- 111111   --- 0000000001 -     0      -   -   -   -    - -    0 0 - 0 - - - - 0 00    ------     -   00 00    0 0 0
-- 111111   --- 000000001- -     0      -   -   -   -    - -    0 0 - 0 - - - - 0 00    ------     -   00 00    0 0 0
-- 111111   --- 00000001-- -     0      -   -   -   -    - -    0 0 - 0 - - - - 0 00    ------     -   00 00    0 0 0
--
-- 111111   --- 0000001000 0     1      1   1   1   0    0 0    0 0 0 0 0 0 0 0 0 00    ------     0   00 00    0 0 0 # fcpsgn
-- 111111   --- 0000001000 1     1      1   1   1   0    1 0    0 0 0 0 0 0 0 0 0 00    ------     1   00 00    0 0 0 # fcpsgn.
-- 111111   --- 0000001001 -     0      -   -   -   -    - -    0 0 - 0 - - - - 0 00    ------     -   00 00    0 0 0
-- 111111   --- 000000101- -     0      -   -   -   -    - -    0 0 - 0 - - - - 0 00    ------     -   00 00    0 0 0
-- 111111   --- 0000001100 0     1      1   0   1   0    0 0    0 0 0 0 0 0 0 0 0 00    ------     0   00 00    0 0 0 # frsp
-- 111111   --- 0000001100 1     1      1   0   1   0    1 0    0 0 0 0 0 0 0 0 0 00    ------     1   00 00    0 0 0 # frsp.
-- 111111   --- 0000001101 -     0      -   -   -   -    - -    0 0 - 0 - - - - 0 00    ------     -   00 00    0 0 0
-- 111111   --- 0000001110 0     1      1   0   1   0    0 0    0 0 0 0 0 0 0 0 0 00    ------     0   00 00    0 0 0 # fctiw
-- 111111   --- 0000001110 1     1      1   0   1   0    1 0    0 0 0 0 0 0 0 0 0 00    ------     1   00 00    0 0 0 # fctiw.
-- 111111   --- 0000001111 0     1      1   0   1   0    0 0    0 0 0 0 0 0 0 0 0 00    ------     0   00 00    0 0 0 # fctiwz
-- 111111   --- 0000001111 1     1      1   0   1   0    1 0    0 0 0 0 0 0 0 0 0 00    ------     1   00 00    0 0 0 # fctiwz.
-- 111111   --- -----10000 -     1      1   0   1   0    0 0    0 0 0 0 0 0 0 0 0 00    ------     0   00 00    1 0 0 # prenormalization
-- 111111   --- -----10001 0     1      1   1   0   1    0 0    0 0 0 0 0 0 0 0 0 00    ------     0   00 00    1 1 0 # fmul_uc  (last uc for fdiv, fsqrt) 11/07/07
-- 111111   --- -----10001 1     1      1   1   0   1    1 0    0 0 0 0 0 0 0 0 0 00    ------     1   00 00    1 1 0 # fmul_uc. (last uc for fdiv, fsqrt) 11/07/07
-- 111111   --- -----10010 0     1      1   1   1   0    0 0    0 0 0 0 0 0 0 0 0 00    ------     0   00 10    0 0 0 # fdiv   (ucoded)
-- 111111   --- -----10010 1     1      1   1   1   0    0 0    0 0 0 0 0 0 0 0 0 00    ------     0   00 10    0 0 0 # fdiv.  (ucoded)
-- 111111   --- -----10011 -     0      -   -   -   -    - -    0 0 - 0 - - - - 0 00    ------     -   00 00    0 0 0
-- 111111   --- -----10100 0     1      1   1   1   0    0 0    0 0 0 0 0 0 0 0 0 00    ------     0   00 00    0 0 0 # fsub
-- 111111   --- -----10100 1     1      1   1   1   0    1 0    0 0 0 0 0 0 0 0 0 00    ------     1   00 00    0 0 0 # fsub.
-- 111111   --- -----10101 0     1      1   1   1   0    0 0    0 0 0 0 0 0 0 0 0 00    ------     0   00 00    0 0 0 # fadd
-- 111111   --- -----10101 1     1      1   1   1   0    1 0    0 0 0 0 0 0 0 0 0 00    ------     1   00 00    0 0 0 # fadd.
-- 111111   --- -----10110 0     1      1   0   1   0    0 0    0 0 0 0 0 0 0 0 0 00    ------     0   00 01    0 0 0 # fsqrt  (ucoded)
-- 111111   --- -----10110 1     1      1   0   1   0    0 0    0 0 0 0 0 0 0 0 0 00    ------     0   00 01    0 0 0 # fsqrt. (ucoded)
-- 111111   --- -----10111 0     1      1   1   1   1    0 0    0 0 0 0 0 0 0 0 0 00    ------     0   00 00    0 0 0 # fsel
-- 111111   --- -----10111 1     1      1   1   1   1    1 0    0 0 0 0 0 0 0 0 0 00    ------     1   00 00    0 0 0 # fsel.
-- 111111   --- -----11000 0     1      1   0   1   0    0 0    0 0 0 0 0 0 0 0 0 00    ------     0   00 00    0 0 0 # fre
-- 111111   --- -----11000 1     1      1   0   1   0    1 0    0 0 0 0 0 0 0 0 0 00    ------     1   00 00    0 0 0 # fre.
-- 111111   --- -----11001 0     1      1   1   0   1    0 0    0 0 0 0 0 0 0 0 0 00    ------     0   00 00    0 0 0 # fmul
-- 111111   --- -----11001 1     1      1   1   0   1    1 0    0 0 0 0 0 0 0 0 0 00    ------     1   00 00    0 0 0 # fmul.
-- 111111   --- -----11010 0     1      1   0   1   0    0 0    0 0 0 0 0 0 0 0 0 00    ------     0   00 00    0 0 0 # frsqrte
-- 111111   --- -----11010 1     1      1   0   1   0    1 0    0 0 0 0 0 0 0 0 0 00    ------     1   00 00    0 0 0 # frsqrte.
-- 111111   --- -----11011 -     0      -   -   -   -    - -    0 0 - 0 - - - - 0 00    ------     -   00 00    0 0 0
-- 111111   --- -----11100 0     1      1   1   1   1    0 0    0 0 0 0 0 0 0 0 0 00    ------     0   00 00    0 0 0 # fmsub
-- 111111   --- -----11100 1     1      1   1   1   1    1 0    0 0 0 0 0 0 0 0 0 00    ------     1   00 00    0 0 0 # fmsub.
-- 111111   --- -----11101 0     1      1   1   1   1    0 0    0 0 0 0 0 0 0 0 0 00    ------     0   00 00    0 0 0 # fmadd
-- 111111   --- -----11101 1     1      1   1   1   1    1 0    0 0 0 0 0 0 0 0 0 00    ------     1   00 00    0 0 0 # fmadd.
-- 111111   --- -----11110 0     1      1   1   1   1    0 0    0 0 0 0 0 0 0 0 0 00    ------     0   00 00    0 0 0 # fnmsub
-- 111111   --- -----11110 1     1      1   1   1   1    1 0    0 0 0 0 0 0 0 0 0 00    ------     1   00 00    0 0 0 # fnmsub.
-- 111111   --- -----11111 0     1      1   1   1   1    0 0    0 0 0 0 0 0 0 0 0 00    ------     0   00 00    0 0 0 # fnmadd
-- 111111   --- -----11111 1     1      1   1   1   1    1 0    0 0 0 0 0 0 0 0 0 00    ------     1   00 00    0 0 0 # fnmadd.
                                                                                                                      
-- 111111   --- 0000100000 -     1      0   1   1   0    0 0    0 0 0 0 0 0 0 0 0 00    ------     1   00 00    0 0 0 # fcmpo
-- 111111   --- 0000100001 -     0      -   -   -   -    - -    0 0 - 0 - - - - 0 00    ------     -   00 00    0 0 0
-- 111111   --- 000010001- -     0      -   -   -   -    - -    0 0 - 0 - - - - 0 00    ------     -   00 00    0 0 0
-- 111111   --- 000010010- -     0      -   -   -   -    - -    0 0 - 0 - - - - 0 00    ------     -   00 00    0 0 0
-- 111111   --- 0000100110 0     1      0   0   0   0    0 0    0 0 0 0 0 0 0 0 0 00    ------     0   00 00    0 0 0 # mtfsb1
-- 111111   --- 0000100110 1     1      0   0   0   0    1 0    0 0 0 0 0 0 0 0 0 00    ------     1   00 00    0 0 0 # mtfsb1.
-- 111111   --- 0000100111 -     0      -   -   -   -    - -    0 0 - 0 - - - - 0 00    ------     -   00 00    0 0 0
-- 111111   --- 0000101000 0     1      1   0   1   0    0 0    0 0 0 0 0 0 0 0 0 00    ------     0   00 00    0 0 0 # fneg
-- 111111   --- 0000101000 1     1      1   0   1   0    1 0    0 0 0 0 0 0 0 0 0 00    ------     1   00 00    0 0 0 # fneg.
-- 111111   --- 0000101001 -     0      -   -   -   -    - -    0 0 - 0 - - - - 0 00    ------     -   00 00    0 0 0
-- 111111   --- 000010101- -     0      -   -   -   -    - -    0 0 - 0 - - - - 0 00    ------     -   00 00    0 0 0
-- 111111   --- 00001011-- -     0      -   -   -   -    - -    0 0 - 0 - - - - 0 00    ------     -   00 00    0 0 0
--#111111   --- 000011---- -     0                              0 0             0 00                            0 0 0
-- 111111   --- 0001000000 -     1      0   0   0   0    1 0    0 0 0 0 0 0 0 0 0 00    ------     1   00 00    0 0 0 # mcrfs
-- 111111   --- 0001000001 -     0      -   -   -   -    - -    0 0 - 0 - - - - 0 00    ------     -   00 00    0 0 0
-- 111111   --- 000100001- -     0      -   -   -   -    - -    0 0 - 0 - - - - 0 00    ------     -   00 00    0 0 0
-- 111111   --- 000100010- -     0      -   -   -   -    - -    0 0 - 0 - - - - 0 00    ------     -   00 00    0 0 0
-- 111111   --- 0001000110 0     1      0   0   0   0    0 0    0 0 0 0 0 0 0 0 0 00    ------     0   00 00    0 0 0 # mtfsb0
-- 111111   --- 0001000110 1     1      0   0   0   0    1 0    0 0 0 0 0 0 0 0 0 00    ------     1   00 00    0 0 0 # mtfsb0.
-- 111111   --- 0001000111 -     0      -   -   -   -    - -    0 0 - 0 - - - - 0 00    ------     -   00 00    0 0 0
-- 111111   --- 0001001000 0     1      1   0   1   0    0 0    0 0 0 0 0 0 0 0 0 00    ------     0   00 00    0 0 0 # fmr
-- 111111   --- 0001001000 1     1      1   0   1   0    1 0    0 0 0 0 0 0 0 0 0 00    ------     1   00 00    0 0 0 # fmr.
                                                                                                                      
-- 111111   --- 0001001001 -     0      -   -   -   -    - -    0 0 - 0 - - - - 0 00    ------     -   00 00    0 0 0
-- 111111   --- 000100101- -     0      -   -   -   -    - -    0 0 - 0 - - - - 0 00    ------     -   00 00    0 0 0
-- 111111   --- 00010011-- -     0      -   -   -   -    - -    0 0 - 0 - - - - 0 00    ------     -   00 00    0 0 0
--#111111   --- 000101---- -     0                              0 0             0 00                            0 0 0
-- 111111   --- 000110---- -     0      -   -   -   -    - -    0 0 - 0 - - - - 0 00    ------     -   00 00    0 0 0
--#111111   --- 000111---- -     0                              0 0             0 00                            0 0 0
                                                                                                                      
-- 111111   --- 0010000000 -     1      0   1   1   0    1 0    0 0 0 0 0 0 0 0 0 00    ------     1   00 00    0 0 0 # ftdiv
--
-- 111111   --- 001000010- -     0      -   -   -   -    - -    0 0 - 0 - - - - 0 00    ------     -   00 00    0 0 0
-- 111111   --- 0010000110 0     1      0   0   0   0    0 0    0 0 0 0 0 0 0 0 0 00    ------     0   00 00    0 0 0 # mtfsfi
-- 111111   --- 0010000110 1     1      0   0   0   0    1 0    0 0 0 0 0 0 0 0 0 00    ------     1   00 00    0 0 0 # mtfsfi.
                                                                                                                      
-- 111111   --- 0010000111 -     0      -   -   -   -    - -    0 0 - 0 - - - - 0 00    ------     -   00 00    0 0 0
-- 111111   --- 0010001000 0     1      1   0   1   0    0 0    0 0 0 0 0 0 0 0 0 00    ------     0   00 00    0 0 0 # fnabs
-- 111111   --- 0010001000 1     1      1   0   1   0    1 0    0 0 0 0 0 0 0 0 0 00    ------     1   00 00    0 0 0 # fnabs.
                                                                                                                      
-- 111111   --- 0010001001 -     0      -   -   -   -    - -    0 0 - 0 - - - - 0 00    ------     -   00 00    0 0 0
-- 111111   --- 001000101- -     0      -   -   -   -    - -    0 0 - 0 - - - - 0 00    ------     -   00 00    0 0 0
-- 111111   --- 001000110- -     0      -   -   -   -    - -    0 0 - 0 - - - - 0 00    ------     -   00 00    0 0 0
-- 111111   --- 0010001110 0     1      1   0   1   0    0 0    0 0 0 0 0 0 0 0 0 00    ------     0   00 00    0 0 0 # fctiwu
-- 111111   --- 0010001110 1     1      1   0   1   0    1 0    0 0 0 0 0 0 0 0 0 00    ------     1   00 00    0 0 0 # fctiwu.
-- 111111   --- 0010001111 0     1      1   0   1   0    0 0    0 0 0 0 0 0 0 0 0 00    ------     0   00 00    0 0 0 # fctiduz
-- 111111   --- 0010001111 1     1      1   0   1   0    1 0    0 0 0 0 0 0 0 0 0 00    ------     1   00 00    0 0 0 # fctiduz.
--#111111   --- 001001---- -     0                              0 0             0 00                            0 0 0
                                                                                                                      
-- 111111   --- 0010100000 -     1      0   0   1   0    1 0    0 0 0 0 0 0 0 0 0 00    ------     1   00 00    0 0 0 # ftsqrt
                                                                                                                      
--#111111   --- 001011---- -     0                              0 0             0 00                            0 0 0
-- 111111   --- 0011000--- -     0      -   -   -   -    - -    0 0 - 0 - - - - 0 00    ------     -   00 00    0 0 0
-- 111111   --- 00110010-- -     0      -   -   -   -    - -    0 0 - 0 - - - - 0 00    ------     -   00 00    0 0 0
-- 111111   --- 001100110- -     0      -   -   -   -    - -    0 0 - 0 - - - - 0 00    ------     -   00 00    0 0 0
-- 111111   --- 0011001110 0     0      1   0   1   0    0 0    0 0 0 0 0 0 0 0 0 00    ------     0   00 00    0 0 0 # fcfiwu  (removed)
-- 111111   --- 0011001110 1     0      1   0   1   0    1 0    0 0 0 0 0 0 0 0 0 00    ------     1   00 00    0 0 0 # fcfiwu. (removed)
-- 111111   --- 0011001111 -     0      -   -   -   -    - -    0 0 - 0 - - - - 0 00    ------     -   00 00    0 0 0
--#111111   --- 001101---- -     0                              0 0             0 00                            0 0 0
-- 111111   --- 001110---- -     0      -   -   -   -    - -    0 0 - 0 - - - - 0 00    ------     -   00 00    0 0 0
--#111111   --- 001111---- -     0                              0 0             0 00                            0 0 0
-- 111111   --- 0100000--- -     0      -   -   -   -    - -    0 0 - 0 - - - - 0 00    ------     -   00 00    0 0 0
-- 111111   --- 0100001000 0     1      1   0   1   0    0 0    0 0 0 0 0 0 0 0 0 00    ------     0   00 00    0 0 0 # fabs
-- 111111   --- 0100001000 1     1      1   0   1   0    1 0    0 0 0 0 0 0 0 0 0 00    ------     1   00 00    0 0 0 # fabs.
-- 111111   --- 0100001001 -     0      -   -   -   -    - -    0 0 - 0 - - - - 0 00    ------     -   00 00    0 0 0
-- 111111   --- 010000101- -     0      -   -   -   -    - -    0 0 - 0 - - - - 0 00    ------     -   00 00    0 0 0
-- 111111   --- 01000011-- -     0      -   -   -   -    - -    0 0 - 0 - - - - 0 00    ------     -   00 00    0 0 0
--#111111   --- 010001---- -     0                              0 0             0 00                            0 0 0
-- 111111   --- 010010---- -     0      -   -   -   -    - -    0 0 - 0 - - - - 0 00    ------     -   00 00    0 0 0
--#111111   --- 010011---- -     0                              0 0             0 00                            0 0 0
-- 111111   --- 010100---- -     0      -   -   -   -    - -    0 0 - 0 - - - - 0 00    ------     -   00 00    0 0 0
--#111111   --- 010101---- -     0                              0 0             0 00                            0 0 0
-- 111111   --- 010110---- -     0      -   -   -   -    - -    0 0 - 0 - - - - 0 00    ------     -   00 00    0 0 0
--#111111   --- 010111---- -     0                              0 0             0 00                            0 0 0
--
-- 111111   --- 0110000--- -     0      -   -   -   -    - -    0 0 - 0 - - - - 0 00    ------     -   00 00    0 0 0
-- 111111   --- 0110001000 0     1      1   0   1   0    0 0    0 0 0 0 0 0 0 0 0 00    ------     0   00 00    0 0 0 # frin
-- 111111   --- 0110001000 1     1      1   0   1   0    1 0    0 0 0 0 0 0 0 0 0 00    ------     1   00 00    0 0 0 # frin.
-- 111111   --- 0110001001 -     0      -   -   -   -    - -    0 0 - 0 - - - - 0 00    ------     -   00 00    0 0 0
-- 111111   --- 011000101- -     0      -   -   -   -    - -    0 0 - 0 - - - - 0 00    ------     -   00 00    0 0 0
-- 111111   --- 01100011-- -     0      -   -   -   -    - -    0 0 - 0 - - - - 0 00    ------     -   00 00    0 0 0
--
--#111111   --- 011001---- -     0                              0 0   0         0 00                            0 0 0
--
-- 111111   --- 0110100--- -     0      -   -   -   -    - -    0 0 - 0 - - - - 0 00    ------     -   00 00    0 0 0
-- 111111   --- 0110101000 0     1      1   0   1   0    0 0    0 0 0 0 0 0 0 0 0 00    ------     0   00 00    0 0 0 # friz
-- 111111   --- 0110101000 1     1      1   0   1   0    1 0    0 0 0 0 0 0 0 0 0 00    ------     1   00 00    0 0 0 # friz.
                                                                                                                      
-- 111111   --- 0110101001 -     0      -   -   -   -    - -    0 0 - 0 - - - - 0 00    ------     -   00 00    0 0 0
-- 111111   --- 011010101- -     0      -   -   -   -    - -    0 0 - 0 - - - - 0 00    ------     -   00 00    0 0 0
-- 111111   --- 01101011-- -     0      -   -   -   -    - -    0 0 - 0 - - - - 0 00    ------     -   00 00    0 0 0
--
--#111111   --- 011011---- -     0                              0 0   0         0 00                            0 0 0
--
-- 111111   --- 0111000--- -     0      -   -   -   -    - -    0 0 - 0 - - - - 0 00    ------     -   00 00    0 0 0
-- 111111   --- 0111001000 0     1      1   0   1   0    0 0    0 0 0 0 0 0 0 0 0 00    ------     0   00 00    0 0 0 # frip
-- 111111   --- 0111001000 1     1      1   0   1   0    1 0    0 0 0 0 0 0 0 0 0 00    ------     1   00 00    0 0 0 # frip.
                                                                                                                      
-- 111111   --- 0111001001 -     0      -   -   -   -    - -    0 0 - 0 - - - - 0 00    ------     -   00 00    0 0 0
-- 111111   --- 011100101- -     0      -   -   -   -    - -    0 0 - 0 - - - - 0 00    ------     -   00 00    0 0 0
-- 111111   --- 01110011-- -     0      -   -   -   -    - -    0 0 - 0 - - - - 0 00    ------     -   00 00    0 0 0
--
--#111111   --- 011101---- -     0                              0 0   0         0 00                            0 0 0
                                                                                                                      
-- 111111   --- 0111100--- -     0      -   -   -   -    - -    0 0 - 0 - - - - 0 00    ------     -   00 00    0 0 0
-- 111111   --- 0111101000 0     1      1   0   1   0    0 0    0 0 0 0 0 0 0 0 0 00    ------     0   00 00    0 0 0 # frim
-- 111111   --- 0111101000 1     1      1   0   1   0    1 0    0 0 0 0 0 0 0 0 0 00    ------     1   00 00    0 0 0 # frim.
                                                                                                                      
-- 111111   --- 0111101001 -     0      -   -   -   -    - -    0 0 - 0 - - - - 0 00    ------     -   00 00    0 0 0
-- 111111   --- 011110101- -     0      -   -   -   -    - -    0 0 - 0 - - - - 0 00    ------     -   00 00    0 0 0
-- 111111   --- 01111011-- -     0      -   -   -   -    - -    0 0 - 0 - - - - 0 00    ------     -   00 00    0 0 0
                                                                                                                      
--#111111   --- 011111---- -     0                              0 0             0 00                            0 0 0
-- 111111   --- 100000---- -     0      -   -   -   -    - -    0 0 - 0 - - - - 0 00    ------     -   00 00    0 0 0
--#111111   --- 100001---- -     0                              0 0             0 00                            0 0 0
-- 111111   --- 100010---- -     0      -   -   -   -    - -    0 0 - 0 - - - - 0 00    ------     -   00 00    0 0 0
--#111111   --- 100011---- -     0                              0 0             0 00                            0 0 0
-- 111111   --- 10010000-- -     0      -   -   -   -    - -    0 0 - 0 - - - - 0 00    ------     -   00 00    0 0 0
-- 111111   --- 100100010- -     0      -   -   -   -    - -    0 0 - 0 - - - - 0 00    ------     -   00 00    0 0 0
-- 111111   --- 1001000110 -     0      -   -   -   -    - -    0 0 - 0 - - - - 0 00    ------     -   00 00    0 0 0
-- 111111   --- 1001000111 0     1      1   0   0   0    0 1    0 0 0 0 0 0 0 0 0 00    ------     0   00 00    0 0 0 # mffs
-- 111111   --- 1001000111 1     1      1   0   0   0    1 1    0 0 0 0 0 0 0 0 0 00    ------     1   00 00    0 0 0 # mffs.
                                                                                                                      
-- 111111   --- 1001001--- -     0      -   -   -   -    - -    0 0 - 0 - - - - 0 00    ------     -   00 00    0 0 0
--#111111   --- 100101---- -     0                              0 0             0 00                            0 0 0
-- 111111   --- 100110---- -     0      -   -   -   -    - -    0 0 - 0 - - - - 0 00    ------     -   00 00    0 0 0
--#111111   --- 100111---- -     0                              0 0             0 00                            0 0 0
-- 111111   --- 101000---- -     0      -   -   -   -    - -    0 0 - 0 - - - - 0 00    ------     -   00 00    0 0 0
--#111111   --- 101001---- -     0                              0 0             0 00                            0 0 0
-- 111111   --- 101010---- -     0      -   -   -   -    - -    0 0 - 0 - - - - 0 00    ------     -   00 00    0 0 0
--#111111   --- 101011---- -     0                              0 0             0 00                            0 0 0
-- 111111   --- 10110000-- -     0      -   -   -   -    - -    0 0 - 0 - - - - 0 00    ------     -   00 00    0 0 0
-- 111111   --- 101100010- -     0      -   -   -   -    - -    0 0 - 0 - - - - 0 00    ------     -   00 00    0 0 0
-- 111111   --- 1011000110 -     0      -   -   -   -    - -    0 0 - 0 - - - - 0 00    ------     -   00 00    0 0 0
-- 111111   --- 1011000111 0     1      0   0   1   0    0 0    0 0 0 0 0 0 0 0 0 00    ------     0   00 00    0 0 0 # mtfsf
-- 111111   --- 1011000111 1     1      0   0   1   0    1 0    0 0 0 0 0 0 0 0 0 00    ------     1   00 00    0 0 0 # mtfsf.
                                                                                                                      
-- 111111   --- 1011001--- -     0      -   -   -   -    - -    0 0 - 0 - - - - 0 00    ------     -   00 00    0 0 0
--#111111   --- 101101---- -     0                              0 0             0 00                            0 0 0
-- 111111   --- 101110---- -     0      -   -   -   -    - -    0 0 - 0 - - - - 0 00    ------     -   00 00    0 0 0
--#111111   --- 101111---- -     0                              0 0             0 00                            0 0 0
-- 111111   --- 110000---- -     0      -   -   -   -    - -    0 0 - 0 - - - - 0 00    ------     -   00 00    0 0 0
--#111111   --- 110001---- -     0                              0 0             0 00                            0 0 0
-- 111111   --- 1100100--- -     0      -   -   -   -    - -    0 0 - 0 - - - - 0 00    ------     -   00 00    0 0 0
-- 111111   --- 11001010-- -     0      -   -   -   -    - -    0 0 - 0 - - - - 0 00    ------     -   00 00    0 0 0
-- 111111   --- 110010110- -     0      -   -   -   -    - -    0 0 - 0 - - - - 0 00    ------     -   00 00    0 0 0
-- 111111   --- 1100101110 0     1      1   0   1   0    0 0    0 0 0 0 0 0 0 0 0 00    ------     0   00 00    0 0 0 # fctid
-- 111111   --- 1100101110 1     1      1   0   1   0    1 0    0 0 0 0 0 0 0 0 0 00    ------     1   00 00    0 0 0 # fctid.
-- 111111   --- 1100101111 0     1      1   0   1   0    0 0    0 0 0 0 0 0 0 0 0 00    ------     0   00 00    0 0 0 # fctidz
-- 111111   --- 1100101111 1     1      1   0   1   0    1 0    0 0 0 0 0 0 0 0 0 00    ------     1   00 00    0 0 0 # fctidz.
                                                                                                                      
--#111111   --- 110011---- -     0                              0 0             0 00                            0 0 0
-- 111111   --- 1101000--- -     0      -   -   -   -    - -    0 0 - 0 - - - - 0 00    ------     -   00 00    0 0 0
-- 111111   --- 11010010-- -     0      -   -   -   -    - -    0 0 - 0 - - - - 0 00    ------     -   00 00    0 0 0
-- 111111   --- 110100110- -     0      -   -   -   -    - -    0 0 - 0 - - - - 0 00    ------     -   00 00    0 0 0
-- 111111   --- 1101001110 0     1      1   0   1   0    0 0    0 0 0 0 0 0 0 0 0 00    ------     0   00 00    0 0 0 # fcfid
-- 111111   --- 1101001110 1     1      1   0   1   0    1 0    0 0 0 0 0 0 0 0 0 00    ------     1   00 00    0 0 0 # fcfid.
                                                                                                                      
-- 111111   --- 1101001111 -     0      -   -   -   -    - -    0 0 - 0 - - - - 0 00    ------     -   00 00    0 0 0
--#111111   --- 110101---- -     0                              0 0             0 00                            0 0 0
-- 111111   --- 110110---- -     0      -   -   -   -    - -    0 0 - 0 - - - - 0 00    ------     -   00 00    0 0 0
--#111111   --- 110111---- -     0                              0 0             0 00                            0 0 0
-- 111111   --- 111000---- -     0      -   -   -   -    - -    0 0 - 0 - - - - 0 00    ------     -   00 00    0 0 0
--#111111   --- 111001---- -     0                              0 0             0 00                            0 0 0
-- 111111   --- 1110100--- -     0      -   -   -   -    - -    0 0 - 0 - - - - 0 00    ------     -   00 00    0 0 0
-- 111111   --- 11101010-- -     0      -   -   -   -    - -    0 0 - 0 - - - - 0 00    ------     -   00 00    0 0 0
-- 111111   --- 111010110- -     0      -   -   -   -    - -    0 0 - 0 - - - - 0 00    ------     -   00 00    0 0 0
-- 111111   --- 1110101110 0     1      1   0   1   0    0 0    0 0 0 0 0 0 0 0 0 00    ------     0   00 00    0 0 0 # fctidu
-- 111111   --- 1110101110 1     1      1   0   1   0    1 0    0 0 0 0 0 0 0 0 0 00    ------     1   00 00    0 0 0 # fctidu.
-- 111111   --- 1110101111 0     1      1   0   1   0    0 0    0 0 0 0 0 0 0 0 0 00    ------     0   00 00    0 0 0 # fctiwuz
-- 111111   --- 1110101111 1     1      1   0   1   0    1 0    0 0 0 0 0 0 0 0 0 00    ------     1   00 00    0 0 0 # fctiwuz.
--#111111   --- 111011---- -     0                              0 0             0 00                            0 0 0
-- 111111   --- 1111000--- -     0      -   -   -   -    - -    0 0 - 0 - - - - 0 00    000000     -   00 00    0 0 0
-- 111111   --- 11110010-- -     0      -   -   -   -    - -    0 0 - 0 - - - - 0 00    000000     -   00 00    0 0 0
-- 111111   --- 111100110- -     0      -   -   -   -    - -    0 0 - 0 - - - - 0 00    000000     -   00 00    0 0 0
-- 111111   --- 1111001110 0     1      1   0   1   0    0 0    0 0 0 0 0 0 0 0 0 00    ------     0   00 00    0 0 0 # fcfidu
-- 111111   --- 1111001110 1     1      1   0   1   0    1 0    0 0 0 0 0 0 0 0 0 00    ------     1   00 00    0 0 0 # fcfidu.
-- 111111   --- 1111001111 -     0      -   -   -   -    - -    0 0 - 0 - - - - 0 00    000000     -   00 00    0 0 0
--#111111   --- 111101---- -     0                              0 0             0 00                            0 0 0
--#111111   --- 111110---- -     0      -   -   -   -    - -    0 0 - 0 1 0 0 0 0 00    ------     -   00 00    1 0 0 # reserve for
--#111111   --- 111111---- -     0                              0 0             0 00                            0 0 0 # div rnd inst

-- #######################################################################
-- .e
--@@ ESPRESSO TABLE END @@

--@@ ESPRESSO LOGIC START @@
-- logic generated on: Wed Apr 21 11:18:41 2010
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

--@@ ESPRESSO LOGIC END @@












ldst_tag   <=   single_precision_ldst &
                int_word_ldst &
                sign_ext_ldst &         -- for lfiwax
                ldst_tag_addr(0 to 5);

tag_in_16to20 <= mftgpr and not io_port;
mftgpr_not_DITC <= mftgpr and not io_port;

ldst_tag_addr <= (iu_au_is0_ucode_ext(0) & is0_instr(06 to 10)) when tag_in_16to20='0' else
                 (iu_au_is0_ucode_ext(2) & is0_instr(16 to 20)) ;

ram_mode_v <= pc_au_ram_mode and pc_au_ram_thread_v;               
                      
------------------------------------------------------------------------------------------------------------------------
-- config bits
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
      ---------------------------------------------
      din            => iu_au_config_iucr_din,
      ---------------------------------------------
      dout           => iu_au_config_iucr_l2
      ---------------------------------------------
      );


iu_au_config_iucr_int(0 to 7) <= iu_au_config_iucr_l2(0 to 7);

       graphics_mode <= iu_au_config_iucr_int(0);  --IUCR2(32) GME
i_afd_config_iucr(1) <= iu_au_config_iucr_int(1);  --IUCR2(33) DISBYP
i_afd_config_iucr(2) <= iu_au_config_iucr_int(2);  --IUCR2(34) SSAXU
i_afd_config_iucr(3) <= iu_au_config_iucr_int(3);  --IUCR2(35) SSUC
i_afd_config_iucr(4) <= iu_au_config_iucr_int(4);  --IUCR2(36) RESERVED FOR BGQ (disable store bypass)
i_afd_config_iucr(5) <= iu_au_config_iucr_int(5);  --IUCR2(37) DISCGAT (disable clock gating in IU_AXU)
i_afd_config_iucr(6) <= iu_au_config_iucr_int(6);  --IUCR2(38) SSFDIVPN (PROPOSED, single step fdiv* and fsqrt* prenorms)
i_afd_config_iucr(7) <= iu_au_config_iucr_int(7);  --IUCR2(39) RESERVED FOR BGQ


spare_unused(4 to 7) <= tidn & tidn & tidn & tidn;
spare_unused(34) <= io_port_ext;


is0_is_ucode <= iu_au_is0_is_ucode; 

in_ucode_mode  <= iu_au_is0_is_ucode and is0_instr_v;

in_fdivsqrt_mode_is0 <= (fdiv_is0 or fsqrt_is0) and (is0_instr_v and not iu_au_is0_flush);
is0_in_divsqrt_mode_or1d <= in_fdivsqrt_mode_is0 or ucmodelat_dout;
ucmodelat_din <= (in_fdivsqrt_mode_is0 or ucmodelat_dout) and (not ifdp_ex5_fmul_uc_complete);   

au_iu_is0_ucode_only <= only_from_ucode;


is0_invalid_kill_uc <= (not (in_ucode_mode or ram_mode_v) and only_from_ucode) or  -- special ucode instructions getting issued when not doing ucode is bad
                       (not (graphics_mode or in_ucode_mode or ram_mode_v) and only_graphics_mode); -- can use any graphics mode insr in ucode




is0_invalid_kill <=  (not (graphics_mode or in_ucode_mode or ram_mode_v) and only_graphics_mode); -- can use any graphics mode insr in ucode

is0_kill_or_divsqrt_b <= not (is0_invalid_kill);

is0_i_dec_b    <= not (isfu_dec_is0 and is0_kill_or_divsqrt_b);  -- inverted for timing
au_iu_is0_i_dec_b <= is0_i_dec_b;

au_iu_is0_i_dec <= not is0_i_dec_b;
spare_unused(2) <= au_iu_is0_i_dec;
                                               
-- fdiv and fsqrt will be handled by ucode.  The fu may issue them lateer
-- This signal is passed down the pipe to rf1, because
-- these opcodes are used to initiate some operand checking so they should continue down the pipe and not be flushed because of ucode.


-- During fdiv/fsqrt the axu may select this thread before or after the "real" fxu selection.
-- If the axu selects this thread earlier than the fxu, s1 is simply updated early.
-- If the axu selects this thread later than the fxu, ucode instructions would get wiped out by the flush
-- This signal protects the instruction from being flushed
ignore_flush_is0 <= (fdiv_is0 or fsqrt_is0) and isfu_dec_is0;  -- these opcodes will not change the FpScr or any Fpr.  Only scratch reg s0 will be changed

-- Source/Target Muxing in IS0 for timing
   -- redirect the target of fdiv(s)(.) and fsqrt(s)(.) to scratch register 1
   is0_frt(0 to 5) <=  "100001"                                           when (fdiv_is0 ='1' or fsqrt_is0 ='1') else  -- scratch reg s1 (prenorm target fdiv, fsqrt)
                       iu_au_is0_ucode_ext(0) & is0_instr(06 to 10);                                              -- usual case

is0_st_or_mtdp <= st_is0 and not (mftgpr and not io_port);  -- 100, 111
is0_mftgpr <= st_is0 and mftgpr and not io_port;    -- 110
is0_usual_fra <= not (st_is0 or mftgpr or io_port); -- 000

is0_fra_or_frs(0 to 5) <=  ((iu_au_is0_ucode_ext(0) & is0_instr(06 to 10)) and (0 to 5 => is0_st_or_mtdp)) or
                           ((iu_au_is0_ucode_ext(2) & is0_instr(16 to 20)) and (0 to 5 => is0_mftgpr))  or
                           ((iu_au_is0_ucode_ext(1) & is0_instr(11 to 15)) and (0 to 5 => is0_usual_fra));
                       
------------------------------------------------------------------------------------------------------------------------

is0_to_ucode          <= (iu_au_is0_2ucode or fdiv_is0 or fsqrt_is0) and isfu_dec_is0; --uCode from either a denorm or fdiv(s)(.) or fsqrt(s)(.)
au_iu_is0_to_ucode    <= (iu_au_is0_2ucode or fdiv_is0 or fsqrt_is0) and isfu_dec_is0;                     

au_iu_is0_ldst   <= ld_st_is0;
au_iu_is0_ldst_v <= ld_st_is0 and not is0_invalid_kill;       
au_iu_is0_st_v    <= st_is0 and not is0_invalid_kill;

au_iu_is0_instr_type <= "001";                 -- 0=AP,1=Vec,2=FP

au_iu_is0_mffgpr <= mffgpr; -- and ld_st_is0;      -- This is for LVSL, and also misaligned loads
au_iu_is0_mftgpr <= mftgpr; -- and ld_st_is0;      -- This is for misaligned stores

au_iu_is0_movedp <= io_port and ld_st_is0; 

au_iu_is0_ldst_size     <= size(0 to 5);       
au_iu_is0_ldst_tag      <= ldst_tag;  
au_iu_is0_ldst_ra_v     <= ld_st_is0 and (not mftgpr or (io_port and indexed));                -- mftgpr uses ra as targ,
                                                                             --  but don't want source dep checks
au_iu_is0_ldst_ra       <= '0' & iu_au_is0_ucode_ext(1) & is0_instr(11 to 15) when mftgpr_not_DITC='0' else
                           '0' & iu_au_is0_ucode_ext(0) & is0_instr( 6 to 10);   -- for mftgpr, make RA the target, same as updates
au_iu_is0_ldst_rb_v     <= (indexed or mffgpr) and ld_st_is0;                      
au_iu_is0_ldst_rb       <= '0' & iu_au_is0_ucode_ext(2) & is0_instr(16 to 20);   -- todo should ucode bit be tied down? should be okay if we don't use AXU ldst's in ucode
au_iu_is0_ldst_dimm     <= is0_instr(16 to 31);                
au_iu_is0_ldst_indexed  <= indexed;                   
au_iu_is0_ldst_update        <= update_form; 
au_iu_is0_ldst_forcealign    <= forcealign;   
au_iu_is0_ldst_forceexcept   <= '0';

au_iu_is0_ldst_extpid <= ldst_extpid;


   
------------------------------------------------------------------------------------------------------------------------

    


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
cmd_is0_go_b(26) <= tidn;               -- spare
cmd_is0_go_b(27) <= tidn;               -- spare
cmd_is0_go_b(28) <= tidn;               -- spare
cmd_is0_go_b(29) <= tidn;               -- spare
cmd_is0_go_b(30) <= tidn;               -- spare
cmd_is0_go_b(31) <= tidn;               -- spare

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
cmd_is1_ho_b(26) <= tidn;               -- spare
cmd_is1_ho_b(27) <= tidn;               -- spare
cmd_is1_ho_b(28) <= tidn;               -- spare
cmd_is1_ho_b(29) <= tidn;               -- spare
cmd_is1_ho_b(30) <= tidn;               -- spare
cmd_is1_ho_b(31) <= tidn;               -- spare
spare_unused(41 to 46) <= cmd_is1_ho_b(26 to 31);

 cmd_is1_ho_32: cmd_is1_ho_b(32) <= not( is1_v_nstall18_INVA_b and                           is1_frt_buf(1) );
 cmd_is1_ho_33: cmd_is1_ho_b(33) <= not( is1_v_nstall19_INVA_b and                           is1_fra_buf(1) );
 cmd_is1_ho_34: cmd_is1_ho_b(34) <= not( is1_v_nstall19_INVA_b and                           is1_frb_buf(1) );
 cmd_is1_ho_35: cmd_is1_ho_b(35) <= not( is1_v_nstall20_INVA_b and                           is1_frc_buf(1) );
 cmd_is1_ho_36: cmd_is1_ho_b(36) <= not( is1_v_nstall20_INVA_b and                           cmd_is1_l2(36) );
 cmd_is1_ho_37: cmd_is1_ho_b(37) <= not( is1_v_nstall21_INVA_b and                           cmd_is1_l2(37) );
 cmd_is1_ho_38: cmd_is1_ho_b(38) <= not( is1_v_nstall21_INVA_b and                           cmd_is1_l2(38) );
 cmd_is1_ho_39: cmd_is1_ho_b(39) <= not( is1_v_nstall22_INVA_b and                           cmd_is1_l2(39) );
 cmd_is1_ho_40: cmd_is1_ho_b(40) <= not( is1_v_nstall26_INVA_b and  iu_au_is1_flush_b  and is1_stall   and cmd_is1_l2(40) );--<NOT redundant and iu_au_is1_stall>  -- ldst val
 cmd_is1_ho_41: cmd_is1_ho_b(41) <= not( is1_v_nstall27_INVA_b and  iu_au_is1_flush_b  and is1_stall   and cmd_is1_l2(41) );--<NOT redundant and iu_au_is1_stall>  --  st val
 cmd_is1_ho_42: cmd_is1_ho_b(42) <= not( is1_v_nstall22_INVA_b and                           cmd_is1_l2(42) );
 cmd_is1_ho_43: cmd_is1_ho_b(43) <= not( is1_v_nstall28_INVA_b and  iu_au_is1_flush_b  and is1_stall   and cmd_is1_l2(43) );--<NOT redundant and iu_au_is1_stall>  -- Valid
 cmd_is1_ho_44: cmd_is1_ho_b(44) <= not( is1_v_nstall29_INVA_b and  iu_au_is1_flush_b  and is1_stall   and cmd_is1_l2(44) );
 cmd_is1_ho_45: cmd_is1_ho_b(45) <= not( is1_v_nstall23_INVA_b and                           cmd_is1_l2(45) );
 cmd_is1_ho_46: cmd_is1_ho_b(46) <= tidn;  
 cmd_is1_ho_47: cmd_is1_ho_b(47) <= not( is1_v_nstall24_INVA_b and                           cmd_is1_l2(47) );
 cmd_is1_ho_48: cmd_is1_ho_b(48) <= not( is1_v_nstall24_INVA_b and                           cmd_is1_l2(48) );
 cmd_is1_ho_49: cmd_is1_ho_b(49) <= not( is1_v_nstall30_INVA_b and  iu_au_is1_flush_b  and is1_stall  and cmd_is1_l2(49) );
 cmd_is1_ho_50: cmd_is1_ho_b(50) <= not( is1_v_nstall31_INVA_b and  iu_au_is1_flush_b  and is1_stall  and cmd_is1_l2(50) );--<NOT redundant and iu_au_is1_stall>  -- bubble3
 cmd_is1_ho_51: cmd_is1_ho_b(51) <= not( is1_v_nstall25_INVA_b and                           cmd_is1_l2(51) );
 cmd_is1_ho_52: cmd_is1_ho_b(52) <= not( is1_v_nstall32_INVA_b and  iu_au_is1_flush_b  and is1_stall   and cmd_is1_l2(52) );--<NOT redundant and iu_au_is1_stall>  -- ignore flush
 cmd_is1_ho_53: cmd_is1_ho_b(53) <= not( is1_v_nstall25_INVA_b and                           cmd_is1_l2(53) );






   is1_cmd_din_a:  cmd_is0_ld(06 to 25) <= not( cmd_is0_go_b(6 to 25) and cmd_is1_ho_b(6 to 25) );
   is1_cmd_din_b:  cmd_is0_ld(32 to 53) <= not( cmd_is0_go_b(32 to 53) and cmd_is1_ho_b(32 to 53) );


   cmd_is0_ld(26) <= ucmodelat_din;
               
   cmd_is0_ld(27 to 31) <= cmd_is1_l2(27 to 31);  -- spares


   -- note that ibuf=>true and init=>1 in this latch here (prevents a built in inverter on the output)
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
      ---------------------------------------------
      din            => cmd_is0_ld,
      ---------------------------------------------
      dout           => cmd_is1_l2
      ---------------------------------------------
      );



   ucmodelat_dout <= cmd_is1_l2(26);

   i_afd_fmul_uc_is1 <= cmd_is1_l2(49);
   is1_fmul_uc <= cmd_is1_l2(49);
   
   i_afd_is1_is_ucode     <= cmd_is1_l2(47);  -- to _fu_dep for div and sqrt
   i_afd_is1_to_ucode     <= cmd_is1_l2(53);  -- to _fu_dep for div and sqrt
   is1_is_ucode     <= cmd_is1_l2(47);  -- to _fu_dep for div and sqrt
   is1_to_ucode     <= cmd_is1_l2(53);  -- to _fu_dep for div and sqrt
     
   spare_unused(3) <= tidn;
   spare_unused(8 to 11) <= tidn & tidn & tidn & tidn;
   



        -- internal renaming
        is1_instr_v   <= cmd_is1_l2(43);  
        is1_ldst      <= cmd_is1_l2(40);   
        is1_st     <= cmd_is1_l2(41);
        


                                    
        -- external signals
        i_afd_is1_frt(0 to 6) <=  tidn & cmd_is1_l2(32) & cmd_is1_l2(06 to 10);
 
        i_afd_is1_fra(0 to 6) <=  tidn & cmd_is1_l2(33) & cmd_is1_l2(11 to 15);

        i_afd_is1_frb(0 to 6) <=  tidn & cmd_is1_l2(34) & cmd_is1_l2(16 to 20);     -- cmd_is1_l2(35) indicates scratch reg

        i_afd_is1_frc(0 to 6) <=  tidn & cmd_is1_l2(35) & cmd_is1_l2(21 to 25);     -- cmd_is1_l2(34) indicates scratch reg

   -- buffered these off for timing
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
        
        i_afd_is1_cr_setter   <= cmd_is1_l2(48);  -- fxu
        is1_cr_setter         <= cmd_is1_l2(48);  -- fxu cr setter
        
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




        


fu_dec_debug(0 to 13) <= is1_instr_v    & -- 00
                         is1_frt_v      & -- 01
                         is1_fra_v      & -- 02
                         is1_frb_v      & -- 03
                         is1_frc_v      & -- 04
                         is1_ldst       & -- 05
                         is1_st         & -- 06
                         is1_cr_setter  & -- 07 FXU CR
                         is1_cr_writer  & -- 08 AXU CR
                         is1_is_ucode   & -- 09
                         is1_to_ucode   & -- 10
                         is1_frt_buf(1) & -- 11 frt scratch bit
                         is1_fmul_uc    & -- 12
                         is1_in_divsqrt_mode_or1d; -- 13
                                      
                         

-- ##################################################
-- pre-scanopt scanchain
  
config_reg_scin(0) <= i_dec_si;
config_reg_scin(1 to 7) <= config_reg_scout(0 to 6);

cmd_is1_scin(6) <= config_reg_scout(7);  
cmd_is1_scin(7 to 53) <= cmd_is1_scout(6 to 52); -- starts with bit 6

i_dec_so <= cmd_is1_scout(53); 


end iuq_axu_fu_dec;
