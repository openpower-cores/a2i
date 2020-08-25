-- © IBM Corp. 2020
-- This softcore is licensed under and subject to the terms of the CC-BY 4.0
-- license (https://creativecommons.org/licenses/by/4.0/legalcode). 
-- Additional rights, including the right to physically implement a softcore 
-- that is compliant with the required sections of the Power ISA 
-- Specification, will be available at no cost via the OpenPOWER Foundation. 
-- This README will be updated with additional information when OpenPOWER's 
-- license is available.

			

library ieee;
use ieee.std_logic_1164.all;
library ibm;
use ibm.std_ulogic_unsigned.all;
use ibm.std_ulogic_support.all;
use ibm.std_ulogic_function_support.all;
library support;
use support.power_logic_pkg.all;
library tri;
use tri.tri_latches_pkg.all;
library work;
use work.iuq_pkg.all;

entity iuq_fxu_decode is
  generic(a2mode      : integer := 1;
          regmode     : integer := 6;
          expand_type : integer := 2  ); 
port(
     vdd                                : inout power_logic;
     gnd                                : inout power_logic;
     nclk                               : in clk_logic;

     pc_iu_sg_0                         : in std_ulogic;
     pc_iu_func_sl_thold_0_b            : in std_ulogic;
     forcee : in std_ulogic;
     d_mode                             : in std_ulogic;
     delay_lclkr                        : in std_ulogic;
     mpw1_b                             : in std_ulogic;
     mpw2_b                             : in std_ulogic;
     scan_in                            : in std_ulogic;
     scan_out                           : out std_ulogic;

     pc_au_ram_mode                     : in std_ulogic;
     pc_au_ram_thread_v                 : in std_ulogic;

     spr_dec_mask                       : in std_ulogic_vector(0 to 31);
     spr_dec_match                      : in std_ulogic_vector(0 to 31);


     au_iu_i_dec_b                      : in std_ulogic;                
     iu_au_is1_cr_user_v                : out std_ulogic;
     iu_au_is0_cr_setter                : out std_ulogic;

     au_iu_ib1_ldst                     : in std_ulogic;
     au_iu_ib1_ldst_v                   : in std_ulogic;
     au_iu_ib1_store                    : in std_ulogic;
     au_iu_ib1_ldst_size                : in std_ulogic_vector(0 to 5);
     au_iu_ib1_ldst_tag                 : in std_ulogic_vector(0 to 8);
     au_iu_ib1_ldst_ra_v                : in std_ulogic;
     au_iu_ib1_ldst_ra                  : in std_ulogic_vector(0 to 6);
     au_iu_ib1_ldst_rb_v                : in std_ulogic;
     au_iu_ib1_ldst_rb                  : in std_ulogic_vector(0 to 6);
     au_iu_ib1_ldst_dimm                : in std_ulogic_vector(0 to 15);
     au_iu_ib1_ldst_indexed             : in std_ulogic;
     au_iu_ib1_ldst_update              : in std_ulogic;
     au_iu_ib1_ldst_extpid              : in std_ulogic;
     au_iu_ib1_ldst_forcealign          : in std_ulogic;
     au_iu_ib1_ldst_forceexcept         : in std_ulogic;
     au_iu_ib1_mftgpr                   : in std_ulogic;
     au_iu_ib1_mffgpr                   : in std_ulogic;
     au_iu_ib1_movedp                  : in std_ulogic;
     au_iu_ib1_instr_type               : in std_ulogic_vector(0 to 2);

     iu_au_ib1_instr_vld                : in std_ulogic;
     iu_au_ib1_ifar                     : in EFF_IFAR;
     iu_au_ib1_instr                    : in std_ulogic_vector(0 to 31);
     iu_au_ib1_instr_ucode_ext          : in std_ulogic_vector(0 to 3);
     iu_au_ib1_instr_pred_vld           : in std_ulogic;
     iu_au_ib1_instr_pred_taken_cnt     : in std_ulogic_vector(0 to 1);
     iu_au_ib1_instr_gshare             : in std_ulogic_vector(0 to 3);
     iu_au_ib1_instr_error              : in std_ulogic_vector(0 to 2);
     iu_au_ib1_instr_is_ucode           : in std_ulogic;
     iu_au_ib1_instr_2ucode             : in std_ulogic;
     iu_au_ib1_instr_2ucode_type        : in std_ulogic;
     iu_au_ib1_instr_force_ram          : in std_ulogic;

     au_iu_is0_to_ucode                 : in  std_ulogic;
     au_iu_is0_ucode_only               : in  std_ulogic;
     iu_au_is1_stall                    : in  std_ulogic;

     xu_iu_ib1_flush                    : in  std_ulogic;
     fdep_fdec_buff_stall               : in  std_ulogic;
     fdep_fdec_weak_stall               : in  std_ulogic;
     fdec_ibuf_stall                    : out std_ulogic;

     fdec_fdep_is1_vld                  : out std_ulogic;
     fdec_fdep_is1_instr                : out std_ulogic_vector(0 to 31);
     fdec_fdep_is1_ta_vld               : out std_ulogic;
     fdec_fdep_is1_ta                   : out std_ulogic_vector(0 to 5);
     fdec_fdep_is1_s1_vld               : out std_ulogic;
     fdec_fdep_is1_s1                   : out std_ulogic_vector(0 to 5);
     fdec_fdep_is1_s2_vld               : out std_ulogic;
     fdec_fdep_is1_s2                   : out std_ulogic_vector(0 to 5);
     fdec_fdep_is1_s3_vld               : out std_ulogic;
     fdec_fdep_is1_s3                   : out std_ulogic_vector(0 to 5);
     fdec_fdep_is1_pred_update          : out std_ulogic;
     fdec_fdep_is1_pred_taken_cnt       : out std_ulogic_vector(0 to 1);
     fdec_fdep_is1_gshare               : out std_ulogic_vector(0 to 3);
     fdec_fdep_is1_UpdatesLR            : out std_ulogic;
     fdec_fdep_is1_UpdatesCR            : out std_ulogic;
     fdec_fdep_is1_UpdatesCTR           : out std_ulogic;
     fdec_fdep_is1_UpdatesXER           : out std_ulogic;
     fdec_fdep_is1_UpdatesMSR           : out std_ulogic;
     fdec_fdep_is1_UpdatesSPR           : out std_ulogic;
     fdec_fdep_is1_UsesLR               : out std_ulogic;
     fdec_fdep_is1_UsesCR               : out std_ulogic;
     fdec_fdep_is1_UsesCTR              : out std_ulogic;
     fdec_fdep_is1_UsesXER              : out std_ulogic;
     fdec_fdep_is1_UsesMSR              : out std_ulogic;
     fdec_fdep_is1_UsesSPR              : out std_ulogic;
     fdec_fdep_is1_hole_delay           : out std_ulogic_vector(0 to 2);
     fdec_fdep_is1_ld_vld                : out std_ulogic;
     fdec_fdep_is1_to_ucode             : out std_ulogic;
     fdec_fdep_is1_is_ucode             : out std_ulogic;
     fdec_fdep_is1_ifar                 : out EFF_IFAR;
     fdec_fdep_is1_error                : out std_ulogic_vector(0 to 2);
     fdec_fdep_is1_complete             : out std_ulogic_vector(0 to 4);
     fdec_fdep_is1_axu_ld_or_st         : out std_ulogic;
     fdec_fdep_is1_axu_store            : out std_ulogic;
     fdec_fdep_is1_axu_ldst_indexed     : out std_ulogic;
     fdec_fdep_is1_axu_ldst_tag         : out std_ulogic_vector(0 to 8);
     fdec_fdep_is1_axu_ldst_size        : out std_ulogic_vector(0 to 5);
     fdec_fdep_is1_axu_ldst_update      : out std_ulogic;
     fdec_fdep_is1_axu_ldst_extpid      : out std_ulogic;
     fdec_fdep_is1_axu_ldst_forcealign  : out std_ulogic;
     fdec_fdep_is1_axu_ldst_forceexcept : out std_ulogic;
     fdec_fdep_is1_axu_mftgpr           : out std_ulogic;
     fdec_fdep_is1_axu_mffgpr           : out std_ulogic;
     fdec_fdep_is1_axu_movedp          : out std_ulogic;
     fdec_fdep_is1_axu_instr_type       : out std_ulogic_vector(0 to 2);
     fdec_fdep_is1_2ucode               : out std_ulogic;
     fdec_fdep_is1_2ucode_type          : out std_ulogic;
     fdec_fdep_is1_force_ram            : out std_ulogic;
     fdec_fdep_is1_match                : out std_ulogic
);
end iuq_fxu_decode;
ARCHITECTURE IUQ_FXU_DECODE
          OF IUQ_FXU_DECODE
          IS
--@@  Signal Declarations
SIGNAL BR_DEP_PT                         : STD_ULOGIC_VECTOR(1 TO 105)  := 
(OTHERS=> 'U');
SIGNAL INSTRUCTION_DECODER1_PT           : STD_ULOGIC_VECTOR(1 TO 15)  := 
(OTHERS=> 'U');
SIGNAL INSTRUCTION_DECODER2_PT           : STD_ULOGIC_VECTOR(1 TO 121)  := 
(OTHERS=> 'U');
SIGNAL INSTRUCTION_DECODER_PT            : STD_ULOGIC_VECTOR(1 TO 58)  := 
(OTHERS=> 'U');
SIGNAL MICROCODE_PT                      : STD_ULOGIC_VECTOR(1 TO 13)  := 
(OTHERS=> 'U');
SIGNAL UpdatesCR                         : STD_ULOGIC  := 
'U';
SIGNAL UpdatesCTR                        : STD_ULOGIC  := 
'U';
SIGNAL UpdatesLR                         : STD_ULOGIC  := 
'U';
SIGNAL UpdatesMSR                        : STD_ULOGIC  := 
'U';
SIGNAL UpdatesSPR                        : STD_ULOGIC  := 
'U';
SIGNAL UpdatesXER                        : STD_ULOGIC  := 
'U';
SIGNAL UsesCR                            : STD_ULOGIC  := 
'U';
SIGNAL UsesCTR                           : STD_ULOGIC  := 
'U';
SIGNAL UsesLR                            : STD_ULOGIC  := 
'U';
SIGNAL UsesMSR                           : STD_ULOGIC  := 
'U';
SIGNAL UsesSPR                           : STD_ULOGIC  := 
'U';
SIGNAL UsesXER                           : STD_ULOGIC  := 
'U';
SIGNAL compl_ex                          : STD_ULOGIC_VECTOR(1 TO 5)  := 
"UUUUU";
SIGNAL hole_delay                        : STD_ULOGIC_VECTOR(1 TO 3)  := 
"UUU";
SIGNAL isFxuIssue                        : STD_ULOGIC  := 
'U';
SIGNAL ld_vld                            : STD_ULOGIC  := 
'U';
SIGNAL s1_sel                            : STD_ULOGIC  := 
'U';
SIGNAL s1_vld                            : STD_ULOGIC  := 
'U';
SIGNAL s2_sel                            : STD_ULOGIC  := 
'U';
SIGNAL s2_vld                            : STD_ULOGIC  := 
'U';
SIGNAL s3_sel                            : STD_ULOGIC  := 
'U';
SIGNAL s3_vld                            : STD_ULOGIC  := 
'U';
SIGNAL ta_sel                            : STD_ULOGIC  := 
'U';
SIGNAL ta_vld                            : STD_ULOGIC  := 
'U';
SIGNAL to_uc                             : STD_ULOGIC  := 
'U';
-- Scan chain connenctions
constant is1_vld_offset                 : natural := 0;
constant is1_vld_type_offset            : natural := is1_vld_offset + 1;
constant is1_instr_offset               : natural := is1_vld_type_offset + 3;
constant is1_axu_instr_offset           : natural := is1_instr_offset + 32;
constant is1_ta_vld_offset              : natural := is1_axu_instr_offset + 26;
constant is1_ta_offset                  : natural := is1_ta_vld_offset + 1;
constant is1_s1_vld_offset              : natural := is1_ta_offset + 6;
constant is1_s1_offset                  : natural := is1_s1_vld_offset + 1;
constant is1_s2_vld_offset              : natural := is1_s1_offset + 6;
constant is1_s2_offset                  : natural := is1_s2_vld_offset + 1;
constant is1_s3_vld_offset              : natural := is1_s2_offset + 6;
constant is1_s3_offset                  : natural := is1_s3_vld_offset + 1;
constant is1_ld_vld_offset              : natural := is1_s3_offset + 6;
constant is1_pred_update_offset         : natural := is1_ld_vld_offset + 1;
constant is1_pred_taken_cnt_offset      : natural := is1_pred_update_offset + 1;
constant is1_gshare_offset              : natural := is1_pred_taken_cnt_offset + 2;
constant is1_UpdatesLR_offset           : natural := is1_gshare_offset + 4;
constant is1_UpdatesCR_offset           : natural := is1_UpdatesLR_offset + 1;
constant is1_UpdatesCTR_offset          : natural := is1_UpdatesCR_offset + 1;
constant is1_UpdatesXER_offset          : natural := is1_UpdatesCTR_offset + 1;
constant is1_UpdatesMSR_offset          : natural := is1_UpdatesXER_offset + 1;
constant is1_UpdatesSPR_offset          : natural := is1_UpdatesMSR_offset + 1;
constant is1_UsesLR_offset              : natural := is1_UpdatesSPR_offset + 1;
constant is1_UsesCR_offset              : natural := is1_UsesLR_offset + 1;
constant is1_UsesCTR_offset             : natural := is1_UsesCR_offset + 1;
constant is1_UsesXER_offset             : natural := is1_UsesCTR_offset + 1;
constant is1_UsesMSR_offset             : natural := is1_UsesXER_offset + 1;
constant is1_UsesSPR_offset             : natural := is1_UsesMSR_offset + 1;
constant is1_to_ucode_offset            : natural := is1_UsesSPR_offset + 1;
constant is1_is_ucode_offset            : natural := is1_to_ucode_offset + 1;
constant is1_ifar_offset                : natural := is1_is_ucode_offset + 1;
constant is1_error_offset               : natural := is1_ifar_offset + EFF_IFAR'length;
constant is1_axu_ldst_ra_v_offset       : natural := is1_error_offset + 3;
constant is1_axu_ldst_rb_v_offset       : natural := is1_axu_ldst_ra_v_offset + 1;
constant is1_axu_ld_or_st_offset        : natural := is1_axu_ldst_rb_v_offset + 1;
constant is1_axu_store_offset           : natural := is1_axu_ld_or_st_offset + 1;
constant is1_axu_ldst_size_offset       : natural := is1_axu_store_offset + 1;
constant is1_axu_ldst_update_offset     : natural := is1_axu_ldst_size_offset + 6;
constant is1_axu_ldst_extpid_offset     : natural := is1_axu_ldst_update_offset + 1;
constant is1_axu_ldst_forcealign_offset : natural := is1_axu_ldst_extpid_offset + 1;
constant is1_axu_ldst_forceexcept_offset: natural := is1_axu_ldst_forcealign_offset + 1;
constant is1_axu_mftgpr_offset          : natural := is1_axu_ldst_forceexcept_offset + 1;
constant is1_axu_mffgpr_offset          : natural := is1_axu_mftgpr_offset + 1;
constant is1_axu_movedp_offset         : natural := is1_axu_mffgpr_offset + 1;
constant is1_axu_instr_type_offset      : natural := is1_axu_movedp_offset + 1;
constant is1_force_ram_offset           : natural := is1_axu_instr_type_offset + 3;
constant is1_2ucode_offset              : natural := is1_force_ram_offset + 1;
constant is1_2ucode_type_offset         : natural := is1_2ucode_offset + 1;
constant spare_offset                   : natural := is1_2ucode_type_offset + 1;
constant scan_right                     : natural := spare_offset + 6-1;
signal spare_l2                 : std_ulogic_vector(0 to 5);
-- signals for hooking up scanchains
signal siv                      : std_ulogic_vector(0 to scan_right);
signal sov                      : std_ulogic_vector(0 to scan_right);
signal tiup                     : std_ulogic;
signal is1_vld_d                : std_ulogic;
signal is1_vld_type_d           : std_ulogic_vector(0 to 2);
signal is1_instr_d              : std_ulogic_vector(0 to 31);
signal is1_axu_instr_d          : std_ulogic_vector(6 to 31);
signal is1_ta_vld_d             : std_ulogic;
signal is1_ta_d                 : std_ulogic_vector(0 to 5);
signal is1_s1_vld_d             : std_ulogic;
signal is1_s1_d                 : std_ulogic_vector(0 to 5);
signal is1_s2_vld_d             : std_ulogic;
signal is1_s2_d                 : std_ulogic_vector(0 to 5);
signal is1_s3_vld_d             : std_ulogic;
signal is1_s3_d                 : std_ulogic_vector(0 to 5);
signal is1_pred_update_d        : std_ulogic;
signal is1_pred_taken_cnt_d     : std_ulogic_vector(0 to 1);
signal is1_gshare_d             : std_ulogic_vector(0 to 3);
signal is1_UpdatesLR_d          : std_ulogic;
signal is1_UpdatesCR_d          : std_ulogic;
signal is1_UpdatesCTR_d         : std_ulogic;
signal is1_UpdatesXER_d         : std_ulogic;
signal is1_UpdatesMSR_d         : std_ulogic;
signal is1_UpdatesSPR_d         : std_ulogic;
signal is1_UsesLR_d             : std_ulogic;
signal is1_UsesCR_d             : std_ulogic;
signal is1_UsesCTR_d            : std_ulogic;
signal is1_UsesXER_d            : std_ulogic;
signal is1_UsesMSR_d            : std_ulogic;
signal is1_UsesSPR_d            : std_ulogic;
signal is1_ld_vld_d              : std_ulogic;
signal is1_to_ucode_d           : std_ulogic;
signal is1_is_ucode_d           : std_ulogic;
signal is1_ifar_d               : EFF_IFAR;
signal is1_error_d              : std_ulogic_vector(0 to 2);
signal is1_axu_ld_or_st_d       : std_ulogic;
signal is1_axu_store_d          : std_ulogic;
signal is1_axu_ldst_size_d      : std_ulogic_vector(0 to 5);
signal is1_axu_ldst_update_d    : std_ulogic;
signal is1_axu_ldst_extpid_d    : std_ulogic;
signal is1_axu_ldst_forcealign_d        : std_ulogic;
signal is1_axu_ldst_forceexcept_d       : std_ulogic;
signal is1_axu_mftgpr_d         : std_ulogic;
signal is1_axu_mffgpr_d         : std_ulogic;
signal is1_axu_movedp_d        : std_ulogic;
signal is1_axu_instr_type_d     : std_ulogic_vector(0 to 2);
signal is1_axu_ldst_ra_v_d      : std_ulogic;
signal is1_axu_ldst_rb_v_d      : std_ulogic;
signal is1_force_ram_d          : std_ulogic;
signal is1_2ucode_d              : std_ulogic;
signal is1_2ucode_type_d         : std_ulogic;
signal is1_vld_L2               : std_ulogic;
signal is1_vld_type_L2          : std_ulogic_vector(0 to 2);
signal is1_instr_L2             : std_ulogic_vector(0 to 31);
signal is1_axu_instr_L2         : std_ulogic_vector(6 to 31);
signal is1_ta_vld_L2            : std_ulogic;
signal is1_ta_L2                : std_ulogic_vector(0 to 5);
signal is1_s1_vld_L2            : std_ulogic;
signal is1_s1_L2                : std_ulogic_vector(0 to 5);
signal is1_s2_vld_L2            : std_ulogic;
signal is1_s2_L2                : std_ulogic_vector(0 to 5);
signal is1_s3_vld_L2            : std_ulogic;
signal is1_s3_L2                : std_ulogic_vector(0 to 5);
signal is1_pred_update_L2       : std_ulogic;
signal is1_pred_taken_cnt_L2    : std_ulogic_vector(0 to 1);
signal is1_gshare_L2            : std_ulogic_vector(0 to 3);
signal is1_UpdatesLR_L2         : std_ulogic;
signal is1_UpdatesCR_L2         : std_ulogic;
signal is1_UpdatesCTR_L2        : std_ulogic;
signal is1_UpdatesXER_L2        : std_ulogic;
signal is1_UpdatesMSR_L2        : std_ulogic;
signal is1_UpdatesSPR_L2        : std_ulogic;
signal is1_UsesLR_L2            : std_ulogic;
signal is1_UsesCR_L2            : std_ulogic;
signal is1_UsesCTR_L2           : std_ulogic;
signal is1_UsesXER_L2           : std_ulogic;
signal is1_UsesMSR_L2           : std_ulogic;
signal is1_UsesSPR_L2           : std_ulogic;
signal is1_ld_vld_L2             : std_ulogic;
signal is1_to_ucode_L2          : std_ulogic;
signal is1_is_ucode_L2          : std_ulogic;
signal is1_ifar_L2              : EFF_IFAR;
signal is1_error_L2             : std_ulogic_vector(0 to 2);
signal is1_axu_ld_or_st_L2      : std_ulogic;
signal is1_axu_store_L2         : std_ulogic;
signal is1_axu_ldst_size_L2     : std_ulogic_vector(0 to 5);
signal is1_axu_ldst_update_L2   : std_ulogic;
signal is1_axu_ldst_extpid_L2   : std_ulogic;
signal is1_axu_ldst_forcealign_L2       : std_ulogic;
signal is1_axu_ldst_forceexcept_L2      : std_ulogic;
signal is1_axu_mftgpr_L2        : std_ulogic;
signal is1_axu_mffgpr_L2        : std_ulogic;
signal is1_axu_movedp_L2       : std_ulogic;
signal is1_axu_instr_type_L2    : std_ulogic_vector(0 to 2);
signal is1_axu_ldst_ra_v_L2     : std_ulogic;
signal is1_axu_ldst_rb_v_L2     : std_ulogic;
signal is1_force_ram_L2         : std_ulogic;
signal is1_2ucode_L2             : std_ulogic;
signal is1_2ucode_type_L2        : std_ulogic;
signal is1_vld_din              : std_ulogic;
signal is1_vld_type_din         : std_ulogic_vector(0 to 2);
signal is1_instr_din            : std_ulogic_vector(0 to 31);
signal is1_axu_instr_din        : std_ulogic_vector(6 to 31);
signal is1_ta_vld_din           : std_ulogic;
signal is1_ta_din               : std_ulogic_vector(0 to 5);
signal is1_s1_vld_din           : std_ulogic;
signal is1_s1_din               : std_ulogic_vector(0 to 5);
signal is1_s2_vld_din           : std_ulogic;
signal is1_s2_din               : std_ulogic_vector(0 to 5);
signal is1_s3_vld_din           : std_ulogic;
signal is1_s3_din               : std_ulogic_vector(0 to 5);
signal is1_pred_update_din      : std_ulogic;
signal is1_pred_taken_cnt_din   : std_ulogic_vector(0 to 1);
signal is1_gshare_din           : std_ulogic_vector(0 to 3);
signal is1_UpdatesLR_din        : std_ulogic;
signal is1_UpdatesCR_din        : std_ulogic;
signal is1_UpdatesCTR_din       : std_ulogic;
signal is1_UpdatesXER_din       : std_ulogic;
signal is1_UpdatesMSR_din       : std_ulogic;
signal is1_UpdatesSPR_din       : std_ulogic;
signal is1_UsesLR_din           : std_ulogic;
signal is1_UsesCR_din           : std_ulogic;
signal is1_UsesCTR_din          : std_ulogic;
signal is1_UsesXER_din          : std_ulogic;
signal is1_UsesMSR_din          : std_ulogic;
signal is1_UsesSPR_din          : std_ulogic;
signal is1_ld_vld_din            : std_ulogic;
signal is1_to_ucode_din         : std_ulogic;
signal is1_is_ucode_din         : std_ulogic;
signal is1_ifar_din             : EFF_IFAR;
signal is1_error_din            : std_ulogic_vector(0 to 2);
signal is1_axu_ld_or_st_din     : std_ulogic;
signal is1_axu_store_din        : std_ulogic;
signal is1_axu_ldst_size_din    : std_ulogic_vector(0 to 5);
signal is1_axu_ldst_update_din  : std_ulogic;
signal is1_axu_ldst_extpid_din  : std_ulogic;
signal is1_axu_ldst_forcealign_din      : std_ulogic;
signal is1_axu_ldst_forceexcept_din     : std_ulogic;
signal is1_axu_mftgpr_din       : std_ulogic;
signal is1_axu_mffgpr_din       : std_ulogic;
signal is1_axu_movedp_din      : std_ulogic;
signal is1_axu_instr_type_din   : std_ulogic_vector(0 to 2);
signal is1_axu_ldst_ra_v_din    : std_ulogic;
signal is1_axu_ldst_rb_v_din    : std_ulogic;
signal is1_force_ram_din        : std_ulogic;
signal is1_2ucode_din            : std_ulogic;
signal is1_2ucode_type_din       : std_ulogic;
signal act_valid                : std_ulogic;
signal act_nonvalid             : std_ulogic;
signal is1_ta_d0                : std_ulogic_vector(0 to 5);
signal is1_s1_d0                : std_ulogic_vector(0 to 5);
signal is1_s2_d0                : std_ulogic_vector(0 to 5);
signal is1_s3_d0                : std_ulogic_vector(0 to 5);
signal core64                   : std_ulogic;
signal au_iu_i_dec              : std_ulogic;
signal au_ib1_ld_or_st          : std_ulogic;
signal au_ib1_store             : std_ulogic;
signal unused                   : std_ulogic_vector(0 to 1);
-- synopsys translate_off
-- synopsys translate_on
  BEGIN --@@ START OF EXECUTABLE CODE FOR IUQ_FXU_DECODE

unused(0) <=  au_iu_ib1_ldst_ra(0);
unused(1) <=  au_iu_ib1_ldst_rb(0);
-----------------------------------------------------------------------
tiup  <=  '1';
au_iu_i_dec           <=  not au_iu_i_dec_b and (not (au_iu_is0_ucode_only and not iu_au_ib1_instr_is_ucode) or (pc_au_ram_mode and pc_au_ram_thread_v));
au_ib1_ld_or_st       <=  au_iu_ib1_ldst_v and (not (au_iu_is0_ucode_only and not iu_au_ib1_instr_is_ucode) or (pc_au_ram_mode and pc_au_ram_thread_v));
au_ib1_store          <=  au_iu_ib1_store and (not (au_iu_is0_ucode_only and not iu_au_ib1_instr_is_ucode) or (pc_au_ram_mode and pc_au_ram_thread_v));
fdec_ibuf_stall          <=  fdep_fdec_buff_stall and iu_au_ib1_instr_vld and not xu_iu_ib1_flush;
--64-bit mode
c64: if (regmode = 6) generate
begin
core64                   <=  '1';
end generate;
--32-bit core
c32: if (regmode = 5) generate
begin
core64                   <=  '0';
end generate;
---------------------------------------------------------------------------------------------------------
-- branch dependency.  branches bite.  branches can update LR and CTR, and can use LR, CR, and CTR.
---------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------
-- Main Instruction Decoder.  Select and Type definitions
---------------------------------------------------------------------------------------------------------
----------------------------
-- ucode table
----------------------------
--
-- Final Table Listing
--      *INPUTS*====================================*OUTPUTS*=========================*
--      |                                           |                                 |
--      |                                           |  UpdatesLR                      |
--      |                                           |  | UpdatesCR                    |
--      |                                           |  | | UpdatesCTR                 |
--      |                                           |  | | | UpdatesXER               |
--      | core64                                    |  | | | | UpdatesMSR             |
--      | |                                         |  | | | | | UpdatesSPR           |
--      | | iu_au_ib1_instr                         |  | | | | | | UsesLR             |
--      | | |       iu_au_ib1_instr                 |  | | | | | | | UsesCR           |
--      | | |       |  iu_au_ib1_instr              |  | | | | | | | | UsesCTR        |
--      | | |       |  |           iu_au_ib1_instr  |  | | | | | | | | | UsesXER      |
--      | | |       |  |           |                |  | | | | | | | | | | UsesMSR    |
--      | | |       |  |           |                |  | | | | | | | | | | | UsesSPR  |
--      | | |       |  1111111112  22222222233      |  | | | | | | | | | | | |        |
--      | | 012345  8  1234567890  12345678901      |  | | | | | | | | | | | |        |
--      *TYPE*======================================+=================================+
--      | P PPPPPP  P  PPPPPPPPPP  PPPPPPPPPPP      |  S S S S S S S S S S S S        |
--      *POLARITY*--------------------------------->|  + + + + + + + + + + + +        |
--      *PHASE*------------------------------------>|  T T T T T T T T T T T T        |
--      *TERMS*=====================================+=================================+
--    1 | - 011111  -  0100000000  0111010011-      |  1 . . . . . . . . . . .        |
--    2 | - 011111  -  0100100000  0111010011-      |  . . 1 . . . . . . . . .        |
--    3 | - 011111  -  0100000000  0101010011-      |  . . . . . . 1 . . . . .        |
--    4 | - 011111  -  0100100000  0101010011-      |  . . . . . . . . 1 . . .        |
--    5 | - 011111  -  0000100000  0111010011-      |  . . . 1 . . . . . . . .        |
--    6 | - 0111-1  -  0000100000  0101010011-      |  . . . . . . . . . 1 . .        |
--    7 | - 01001-  -  ----------  00000100001      |  1 . . . . . . . . . . .        |
--    8 | - 010011  1  ----------  1000010000-      |  . . . . . . . 1 1 . . .        |
--    9 | - 01001-  1  ----------  -0000100001      |  1 . . . . . . . . . . .        |
--   10 | - 010011  0  ----------  0000010000-      |  . . 1 . . . . . 1 . . .        |
--   11 | - 010011  -  ----------  000-100110-      |  . . . . 1 . . . . . . 1        |
--   12 | - 010011  -  ----------  0000010000-      |  . . . . . . 1 1 . . . .        |
--   13 | - 011111  -  ----------  1110110110-      |  . . . . . . . . . . 1 1        |
--   14 | - 01-1-1  -  ----------  11101101101      |  . 1 . . . . . . . 1 . .        |
--   15 | - 011111  -  ---------1  0111010011-      |  . . . . . 1 . . . . . .        |
--   16 | - 011111  -  --------1-  0111010011-      |  . . . . . 1 . . . . . .        |
--   17 | - 011111  -  -------1--  0111010011-      |  . . . . . 1 . . . . . .        |
--   18 | - 011111  -  ------1---  0111010011-      |  . . . . . 1 . . . . . .        |
--   19 | - 011111  -  -----1----  0111010011-      |  . . . . . 1 . . . . . .        |
--   20 | - 011111  -  ---1------  0111010011-      |  . . . . . 1 . . . . . .        |
--   21 | - 011111  -  --1-------  0111010011-      |  . . . . . 1 . . . . . .        |
--   22 | - 011111  -  1---------  0111010011-      |  . . . . . 1 . . . . . .        |
--   23 | - 010011  -  ----------  0000000000-      |  . 1 . . . . . 1 . . . .        |
--   24 | 1 011111  -  ----------  110011101--      |  . . . 1 . . . . . . . .        |
--   25 | 1 01-1-1  -  ----------  110011101-1      |  . 1 . . . . . . . 1 . .        |
--   26 | 1 011111  -  ----------  10111010---      |  . . . 1 . . . . . . . .        |
--   27 | - 011111  -  ----------  00110101001      |  . 1 . . . 1 . . . 1 . .        |
--   28 | - 010011  -  ----------  0-00100001-      |  . 1 . . . . . 1 . . . .        |
--   29 | - 010011  -  ----------  01-0100001-      |  . 1 . . . . . 1 . . . .        |
--   30 | - 010011  -  ----------  000011001--      |  . . . . 1 . . . . . . 1        |
--   31 | - 011111  -  ----------  100-101000-      |  . . . 1 . . . . . . . .        |
--   32 | - 010011  -  ----------  0011-00001-      |  . 1 . . . . . 1 . . . .        |
--   33 | - 011111  -  ----------  0110010110-      |  . . . . . . . . . . 1 1        |
--   34 | - 011111  -  ----------  1110-00110-      |  . . . . . . . . . . . 1        |
--   35 | 1 0111--  -  ----------  00110101-01      |  . 1 . . . . . . . 1 . .        |
--   36 | - 010011  -  ----------  0-11000001-      |  . 1 . . . . . 1 . . . .        |
--   37 | - 011111  -  ----------  101110101--      |  . . . 1 . . . . . . . .        |
--   38 | - 010011  -  ----------  001-000001-      |  . 1 . . . . . 1 . . . .        |
--   39 | - 010011  -  ----------  0100-00001-      |  . 1 . . . . . 1 . . . .        |
--   40 | - 011111  -  ---------1  0101-10011-      |  . . . . . . . . . . . 1        |
--   41 | - 011111  -  --------1-  0101-10011-      |  . . . . . . . . . . . 1        |
--   42 | - 011111  -  -------1--  0101-10011-      |  . . . . . . . . . . . 1        |
--   43 | - 011111  -  ------1---  0101-10011-      |  . . . . . . . . . . . 1        |
--   44 | - 011111  -  -----1----  0101-10011-      |  . . . . . . . . . . . 1        |
--   45 | - 011111  -  ---1------  0101-10011-      |  . . . . . . . . . . . 1        |
--   46 | - 011111  -  --1-------  0101-10011-      |  . . . . . . . . . . . 1        |
--   47 | - 011111  -  1---------  0101-10011-      |  . . . . . . . . . . . 1        |
--   48 | - 0111-1  -  ----------  1110000110-      |  . 1 . . . . . . . 1 . .        |
--   49 | - 011111  -  ----------  0101110011-      |  . . . . . . . . . . . 1        |
--   50 | 1 011111  -  ----------  1100-110-0-      |  . . . 1 . . . . . . . .        |
--   51 | 1 01-1-1  -  ----------  1100-110-01      |  . 1 . . . . . . . 1 . .        |
--   52 | - 011111  -  ----------  0001010011-      |  . . . . . . . . . . 1 .        |
--   53 | - 011111  -  ----------  1100-11000-      |  . . . 1 . . . . . . . .        |
--   54 | - 011111  -  ----------  0010010010-      |  . . . . 1 . . . . . . .        |
--   55 | - 011111  -  ----------  1-00001010-      |  . . . 1 . . . . . . . .        |
--   56 | - 01-1-1  -  ----------  1100-110001      |  . 1 . . . . . . . 1 . .        |
--   57 | - 011111  -  ----------  0000010011-      |  . . . . . . . 1 . . . .        |
--   58 | - 0111-1  -  ----------  10-0010101-      |  . . . . . . . . . 1 . .        |
--   59 | - 01-1-1  -  ----------  000-1111001      |  . 1 . . . . . . . 1 . .        |
--   60 | - 011111  -  ----------  1000000000-      |  . 1 . 1 . . . . . 1 . .        |
--   61 | 1 011111  -  ----------  111--010-1-      |  . . . 1 . . . . . . . .        |
--   62 | 1 01-1-1  -  ----------  111-0110101      |  . 1 . . . . . . . 1 . .        |
--   63 | - 01-1-1  -  ----------  11010100101      |  . 1 . . . . . . . . . .        |
--   64 | - 011111  -  ----------  0010-00011-      |  . . . . 1 . . . . . . .        |
--   65 | 1 01-1-1  -  ----------  0000-110101      |  . 1 . . . . . . . 1 . .        |
--   66 | - 0111-1  -  ----------  0010010000-      |  . 1 . . . . . . . . . .        |
--   67 | - 01-1-1  -  ----------  011-0111001      |  . 1 . . . . . . . 1 . .        |
--   68 | - 01-1-1  -  ----------  00100100111      |  . 1 . . . . . . . . . .        |
--   69 | - 011111  -  ----------  111--01011-      |  . . . 1 . . . . . . . .        |
--   70 | - 01-1-1  -  ----------  111001-0101      |  . 1 . . . . . . . . . .        |
--   71 | - 01-1-1  -  ----------  -011-010-01      |  . 1 . . . . . . . . . .        |
--   72 | 1 01-1-1  -  ----------  -0000-10111      |  . 1 . . . . . . . 1 . .        |
--   73 | 1 01-1-1  -  ----------  -0111010--1      |  . 1 . . . . . . . 1 . .        |
--   74 | - 01-1-1  -  ----------  0-100101101      |  . 1 . . . . . . . 1 . .        |
--   75 | - 01-1-1  -  ----------  -01-0010-01      |  . 1 . . . . . . . . . .        |
--   76 | - 01-1-1  -  ----------  1110-110101      |  . 1 . . . . . . . 1 . .        |
--   77 | - 01-1-1  -  ----------  0-00-111001      |  . 1 . . . . . . . 1 . .        |
--   78 | - 01-1-1  -  ----------  01-0-111001      |  . 1 . . . . . . . 1 . .        |
--   79 | - 01-1-1  -  ----------  -00-1010001      |  . 1 . . . . . . . 1 . .        |
--   80 | - 01-1-1  -  ----------  -01110101-1      |  . 1 . . . . . . . 1 . .        |
--   81 | - 011111  -  ----------  -0-00010-0-      |  . . . 1 . . . . . . . .        |
--   82 | - 0111-1  -  ----------  0000-00000-      |  . 1 . . . . . . . 1 . .        |
--   83 | 1 01-1-1  -  ----------  -00-0010-11      |  . 1 . . . . . . . 1 . .        |
--   84 | - 01-1-1  -  ----------  -0000-10001      |  . 1 . . . . . . . 1 . .        |
--   85 | - 0111-1  -  ----------  -01-0010-0-      |  . . . . . . . . . 1 . .        |
--   86 | - 011111  -  ----------  -011-010-0-      |  . . . 1 . . . . . 1 . .        |
--   87 | - 01-1-1  -  ----------  --000010101      |  . 1 . . . . . . . 1 . .        |
--   88 | - 01-1-1  -  ----------  -00-0010111      |  . 1 . . . . . . . 1 . .        |
--   89 | - 010000  0  ----------  -----------      |  . . 1 . . . . . 1 . . .        |
--   90 | - 01-1-1  -  ----------  00000-10-01      |  . 1 . . . . . . . 1 . .        |
--   91 | 1 01-1-1  -  ----------  -11--010-11      |  . 1 . . . . . . . 1 . .        |
--   92 | - 011111  -  ----------  -----01111-      |  . . . . . . . 1 . . . .        |
--   93 | - 01-1-1  -  ----------  000--000111      |  . 1 . . . . . . . 1 . .        |
--   94 | - 01-1-1  -  ----------  -11--010111      |  . 1 . . . . . . . 1 . .        |
--   95 | - 010000  -  ----------  -----------      |  . . . . . . . 1 . . . .        |
--   96 | - 0100-0  -  ----------  ----------1      |  1 . . . . . . . . . . .        |
--   97 | 1 0111-0  -  ----------  -------00-1      |  . 1 . . . . . . . 1 . .        |
--   98 | - 001-00  -  ----------  -----------      |  . . . 1 . . . . . . . .        |
--   99 | - 010001  -  ----------  ---------1-      |  . . . . 1 1 . . . . 1 .        |
--   100 | 1 0111-0  -  ----------  ------0---1      |  . 1 . . . . . . . 1 . .        |
--   101 | - 00101-  -  ----------  -----------      |  . 1 . . . . . . . 1 . .        |
--   102 | - 001101  -  ----------  -----------      |  . 1 . 1 . . . . . 1 . .        |
--   103 | - 01-10-  -  ----------  ----------1      |  . 1 . . . . . . . 1 . .        |
--   104 | - 0101-1  -  ----------  ----------1      |  . 1 . . . . . . . 1 . .        |
--   105 | - 01110-  -  ----------  -----------      |  . 1 . . . . . . . 1 . .        |
--      *=============================================================================*
--
-- Table BR_DEP Signal Assignments for Product Terms
MQQ1:BR_DEP_PT(1) <=
    Eq(( IU_AU_IB1_INSTR(0) & IU_AU_IB1_INSTR(1) & 
    IU_AU_IB1_INSTR(2) & IU_AU_IB1_INSTR(3) & 
    IU_AU_IB1_INSTR(4) & IU_AU_IB1_INSTR(5) & 
    IU_AU_IB1_INSTR(11) & IU_AU_IB1_INSTR(12) & 
    IU_AU_IB1_INSTR(13) & IU_AU_IB1_INSTR(14) & 
    IU_AU_IB1_INSTR(15) & IU_AU_IB1_INSTR(16) & 
    IU_AU_IB1_INSTR(17) & IU_AU_IB1_INSTR(18) & 
    IU_AU_IB1_INSTR(19) & IU_AU_IB1_INSTR(20) & 
    IU_AU_IB1_INSTR(21) & IU_AU_IB1_INSTR(22) & 
    IU_AU_IB1_INSTR(23) & IU_AU_IB1_INSTR(24) & 
    IU_AU_IB1_INSTR(25) & IU_AU_IB1_INSTR(26) & 
    IU_AU_IB1_INSTR(27) & IU_AU_IB1_INSTR(28) & 
    IU_AU_IB1_INSTR(29) & IU_AU_IB1_INSTR(30)
     ) , STD_ULOGIC_VECTOR'("01111101000000000111010011"));
MQQ2:BR_DEP_PT(2) <=
    Eq(( IU_AU_IB1_INSTR(0) & IU_AU_IB1_INSTR(1) & 
    IU_AU_IB1_INSTR(2) & IU_AU_IB1_INSTR(3) & 
    IU_AU_IB1_INSTR(4) & IU_AU_IB1_INSTR(5) & 
    IU_AU_IB1_INSTR(11) & IU_AU_IB1_INSTR(12) & 
    IU_AU_IB1_INSTR(13) & IU_AU_IB1_INSTR(14) & 
    IU_AU_IB1_INSTR(15) & IU_AU_IB1_INSTR(16) & 
    IU_AU_IB1_INSTR(17) & IU_AU_IB1_INSTR(18) & 
    IU_AU_IB1_INSTR(19) & IU_AU_IB1_INSTR(20) & 
    IU_AU_IB1_INSTR(21) & IU_AU_IB1_INSTR(22) & 
    IU_AU_IB1_INSTR(23) & IU_AU_IB1_INSTR(24) & 
    IU_AU_IB1_INSTR(25) & IU_AU_IB1_INSTR(26) & 
    IU_AU_IB1_INSTR(27) & IU_AU_IB1_INSTR(28) & 
    IU_AU_IB1_INSTR(29) & IU_AU_IB1_INSTR(30)
     ) , STD_ULOGIC_VECTOR'("01111101001000000111010011"));
MQQ3:BR_DEP_PT(3) <=
    Eq(( IU_AU_IB1_INSTR(0) & IU_AU_IB1_INSTR(1) & 
    IU_AU_IB1_INSTR(2) & IU_AU_IB1_INSTR(3) & 
    IU_AU_IB1_INSTR(4) & IU_AU_IB1_INSTR(5) & 
    IU_AU_IB1_INSTR(11) & IU_AU_IB1_INSTR(12) & 
    IU_AU_IB1_INSTR(13) & IU_AU_IB1_INSTR(14) & 
    IU_AU_IB1_INSTR(15) & IU_AU_IB1_INSTR(16) & 
    IU_AU_IB1_INSTR(17) & IU_AU_IB1_INSTR(18) & 
    IU_AU_IB1_INSTR(19) & IU_AU_IB1_INSTR(20) & 
    IU_AU_IB1_INSTR(21) & IU_AU_IB1_INSTR(22) & 
    IU_AU_IB1_INSTR(23) & IU_AU_IB1_INSTR(24) & 
    IU_AU_IB1_INSTR(25) & IU_AU_IB1_INSTR(26) & 
    IU_AU_IB1_INSTR(27) & IU_AU_IB1_INSTR(28) & 
    IU_AU_IB1_INSTR(29) & IU_AU_IB1_INSTR(30)
     ) , STD_ULOGIC_VECTOR'("01111101000000000101010011"));
MQQ4:BR_DEP_PT(4) <=
    Eq(( IU_AU_IB1_INSTR(0) & IU_AU_IB1_INSTR(1) & 
    IU_AU_IB1_INSTR(2) & IU_AU_IB1_INSTR(3) & 
    IU_AU_IB1_INSTR(4) & IU_AU_IB1_INSTR(5) & 
    IU_AU_IB1_INSTR(11) & IU_AU_IB1_INSTR(12) & 
    IU_AU_IB1_INSTR(13) & IU_AU_IB1_INSTR(14) & 
    IU_AU_IB1_INSTR(15) & IU_AU_IB1_INSTR(16) & 
    IU_AU_IB1_INSTR(17) & IU_AU_IB1_INSTR(18) & 
    IU_AU_IB1_INSTR(19) & IU_AU_IB1_INSTR(20) & 
    IU_AU_IB1_INSTR(21) & IU_AU_IB1_INSTR(22) & 
    IU_AU_IB1_INSTR(23) & IU_AU_IB1_INSTR(24) & 
    IU_AU_IB1_INSTR(25) & IU_AU_IB1_INSTR(26) & 
    IU_AU_IB1_INSTR(27) & IU_AU_IB1_INSTR(28) & 
    IU_AU_IB1_INSTR(29) & IU_AU_IB1_INSTR(30)
     ) , STD_ULOGIC_VECTOR'("01111101001000000101010011"));
MQQ5:BR_DEP_PT(5) <=
    Eq(( IU_AU_IB1_INSTR(0) & IU_AU_IB1_INSTR(1) & 
    IU_AU_IB1_INSTR(2) & IU_AU_IB1_INSTR(3) & 
    IU_AU_IB1_INSTR(4) & IU_AU_IB1_INSTR(5) & 
    IU_AU_IB1_INSTR(11) & IU_AU_IB1_INSTR(12) & 
    IU_AU_IB1_INSTR(13) & IU_AU_IB1_INSTR(14) & 
    IU_AU_IB1_INSTR(15) & IU_AU_IB1_INSTR(16) & 
    IU_AU_IB1_INSTR(17) & IU_AU_IB1_INSTR(18) & 
    IU_AU_IB1_INSTR(19) & IU_AU_IB1_INSTR(20) & 
    IU_AU_IB1_INSTR(21) & IU_AU_IB1_INSTR(22) & 
    IU_AU_IB1_INSTR(23) & IU_AU_IB1_INSTR(24) & 
    IU_AU_IB1_INSTR(25) & IU_AU_IB1_INSTR(26) & 
    IU_AU_IB1_INSTR(27) & IU_AU_IB1_INSTR(28) & 
    IU_AU_IB1_INSTR(29) & IU_AU_IB1_INSTR(30)
     ) , STD_ULOGIC_VECTOR'("01111100001000000111010011"));
MQQ6:BR_DEP_PT(6) <=
    Eq(( IU_AU_IB1_INSTR(0) & IU_AU_IB1_INSTR(1) & 
    IU_AU_IB1_INSTR(2) & IU_AU_IB1_INSTR(3) & 
    IU_AU_IB1_INSTR(5) & IU_AU_IB1_INSTR(11) & 
    IU_AU_IB1_INSTR(12) & IU_AU_IB1_INSTR(13) & 
    IU_AU_IB1_INSTR(14) & IU_AU_IB1_INSTR(15) & 
    IU_AU_IB1_INSTR(16) & IU_AU_IB1_INSTR(17) & 
    IU_AU_IB1_INSTR(18) & IU_AU_IB1_INSTR(19) & 
    IU_AU_IB1_INSTR(20) & IU_AU_IB1_INSTR(21) & 
    IU_AU_IB1_INSTR(22) & IU_AU_IB1_INSTR(23) & 
    IU_AU_IB1_INSTR(24) & IU_AU_IB1_INSTR(25) & 
    IU_AU_IB1_INSTR(26) & IU_AU_IB1_INSTR(27) & 
    IU_AU_IB1_INSTR(28) & IU_AU_IB1_INSTR(29) & 
    IU_AU_IB1_INSTR(30) ) , STD_ULOGIC_VECTOR'("0111100001000000101010011"));
MQQ7:BR_DEP_PT(7) <=
    Eq(( IU_AU_IB1_INSTR(0) & IU_AU_IB1_INSTR(1) & 
    IU_AU_IB1_INSTR(2) & IU_AU_IB1_INSTR(3) & 
    IU_AU_IB1_INSTR(4) & IU_AU_IB1_INSTR(21) & 
    IU_AU_IB1_INSTR(22) & IU_AU_IB1_INSTR(23) & 
    IU_AU_IB1_INSTR(24) & IU_AU_IB1_INSTR(25) & 
    IU_AU_IB1_INSTR(26) & IU_AU_IB1_INSTR(27) & 
    IU_AU_IB1_INSTR(28) & IU_AU_IB1_INSTR(29) & 
    IU_AU_IB1_INSTR(30) & IU_AU_IB1_INSTR(31)
     ) , STD_ULOGIC_VECTOR'("0100100000100001"));
MQQ8:BR_DEP_PT(8) <=
    Eq(( IU_AU_IB1_INSTR(0) & IU_AU_IB1_INSTR(1) & 
    IU_AU_IB1_INSTR(2) & IU_AU_IB1_INSTR(3) & 
    IU_AU_IB1_INSTR(4) & IU_AU_IB1_INSTR(5) & 
    IU_AU_IB1_INSTR(8) & IU_AU_IB1_INSTR(21) & 
    IU_AU_IB1_INSTR(22) & IU_AU_IB1_INSTR(23) & 
    IU_AU_IB1_INSTR(24) & IU_AU_IB1_INSTR(25) & 
    IU_AU_IB1_INSTR(26) & IU_AU_IB1_INSTR(27) & 
    IU_AU_IB1_INSTR(28) & IU_AU_IB1_INSTR(29) & 
    IU_AU_IB1_INSTR(30) ) , STD_ULOGIC_VECTOR'("01001111000010000"));
MQQ9:BR_DEP_PT(9) <=
    Eq(( IU_AU_IB1_INSTR(0) & IU_AU_IB1_INSTR(1) & 
    IU_AU_IB1_INSTR(2) & IU_AU_IB1_INSTR(3) & 
    IU_AU_IB1_INSTR(4) & IU_AU_IB1_INSTR(8) & 
    IU_AU_IB1_INSTR(22) & IU_AU_IB1_INSTR(23) & 
    IU_AU_IB1_INSTR(24) & IU_AU_IB1_INSTR(25) & 
    IU_AU_IB1_INSTR(26) & IU_AU_IB1_INSTR(27) & 
    IU_AU_IB1_INSTR(28) & IU_AU_IB1_INSTR(29) & 
    IU_AU_IB1_INSTR(30) & IU_AU_IB1_INSTR(31)
     ) , STD_ULOGIC_VECTOR'("0100110000100001"));
MQQ10:BR_DEP_PT(10) <=
    Eq(( IU_AU_IB1_INSTR(0) & IU_AU_IB1_INSTR(1) & 
    IU_AU_IB1_INSTR(2) & IU_AU_IB1_INSTR(3) & 
    IU_AU_IB1_INSTR(4) & IU_AU_IB1_INSTR(5) & 
    IU_AU_IB1_INSTR(8) & IU_AU_IB1_INSTR(21) & 
    IU_AU_IB1_INSTR(22) & IU_AU_IB1_INSTR(23) & 
    IU_AU_IB1_INSTR(24) & IU_AU_IB1_INSTR(25) & 
    IU_AU_IB1_INSTR(26) & IU_AU_IB1_INSTR(27) & 
    IU_AU_IB1_INSTR(28) & IU_AU_IB1_INSTR(29) & 
    IU_AU_IB1_INSTR(30) ) , STD_ULOGIC_VECTOR'("01001100000010000"));
MQQ11:BR_DEP_PT(11) <=
    Eq(( IU_AU_IB1_INSTR(0) & IU_AU_IB1_INSTR(1) & 
    IU_AU_IB1_INSTR(2) & IU_AU_IB1_INSTR(3) & 
    IU_AU_IB1_INSTR(4) & IU_AU_IB1_INSTR(5) & 
    IU_AU_IB1_INSTR(21) & IU_AU_IB1_INSTR(22) & 
    IU_AU_IB1_INSTR(23) & IU_AU_IB1_INSTR(25) & 
    IU_AU_IB1_INSTR(26) & IU_AU_IB1_INSTR(27) & 
    IU_AU_IB1_INSTR(28) & IU_AU_IB1_INSTR(29) & 
    IU_AU_IB1_INSTR(30) ) , STD_ULOGIC_VECTOR'("010011000100110"));
MQQ12:BR_DEP_PT(12) <=
    Eq(( IU_AU_IB1_INSTR(0) & IU_AU_IB1_INSTR(1) & 
    IU_AU_IB1_INSTR(2) & IU_AU_IB1_INSTR(3) & 
    IU_AU_IB1_INSTR(4) & IU_AU_IB1_INSTR(5) & 
    IU_AU_IB1_INSTR(21) & IU_AU_IB1_INSTR(22) & 
    IU_AU_IB1_INSTR(23) & IU_AU_IB1_INSTR(24) & 
    IU_AU_IB1_INSTR(25) & IU_AU_IB1_INSTR(26) & 
    IU_AU_IB1_INSTR(27) & IU_AU_IB1_INSTR(28) & 
    IU_AU_IB1_INSTR(29) & IU_AU_IB1_INSTR(30)
     ) , STD_ULOGIC_VECTOR'("0100110000010000"));
MQQ13:BR_DEP_PT(13) <=
    Eq(( IU_AU_IB1_INSTR(0) & IU_AU_IB1_INSTR(1) & 
    IU_AU_IB1_INSTR(2) & IU_AU_IB1_INSTR(3) & 
    IU_AU_IB1_INSTR(4) & IU_AU_IB1_INSTR(5) & 
    IU_AU_IB1_INSTR(21) & IU_AU_IB1_INSTR(22) & 
    IU_AU_IB1_INSTR(23) & IU_AU_IB1_INSTR(24) & 
    IU_AU_IB1_INSTR(25) & IU_AU_IB1_INSTR(26) & 
    IU_AU_IB1_INSTR(27) & IU_AU_IB1_INSTR(28) & 
    IU_AU_IB1_INSTR(29) & IU_AU_IB1_INSTR(30)
     ) , STD_ULOGIC_VECTOR'("0111111110110110"));
MQQ14:BR_DEP_PT(14) <=
    Eq(( IU_AU_IB1_INSTR(0) & IU_AU_IB1_INSTR(1) & 
    IU_AU_IB1_INSTR(3) & IU_AU_IB1_INSTR(5) & 
    IU_AU_IB1_INSTR(21) & IU_AU_IB1_INSTR(22) & 
    IU_AU_IB1_INSTR(23) & IU_AU_IB1_INSTR(24) & 
    IU_AU_IB1_INSTR(25) & IU_AU_IB1_INSTR(26) & 
    IU_AU_IB1_INSTR(27) & IU_AU_IB1_INSTR(28) & 
    IU_AU_IB1_INSTR(29) & IU_AU_IB1_INSTR(30) & 
    IU_AU_IB1_INSTR(31) ) , STD_ULOGIC_VECTOR'("011111101101101"));
MQQ15:BR_DEP_PT(15) <=
    Eq(( IU_AU_IB1_INSTR(0) & IU_AU_IB1_INSTR(1) & 
    IU_AU_IB1_INSTR(2) & IU_AU_IB1_INSTR(3) & 
    IU_AU_IB1_INSTR(4) & IU_AU_IB1_INSTR(5) & 
    IU_AU_IB1_INSTR(20) & IU_AU_IB1_INSTR(21) & 
    IU_AU_IB1_INSTR(22) & IU_AU_IB1_INSTR(23) & 
    IU_AU_IB1_INSTR(24) & IU_AU_IB1_INSTR(25) & 
    IU_AU_IB1_INSTR(26) & IU_AU_IB1_INSTR(27) & 
    IU_AU_IB1_INSTR(28) & IU_AU_IB1_INSTR(29) & 
    IU_AU_IB1_INSTR(30) ) , STD_ULOGIC_VECTOR'("01111110111010011"));
MQQ16:BR_DEP_PT(16) <=
    Eq(( IU_AU_IB1_INSTR(0) & IU_AU_IB1_INSTR(1) & 
    IU_AU_IB1_INSTR(2) & IU_AU_IB1_INSTR(3) & 
    IU_AU_IB1_INSTR(4) & IU_AU_IB1_INSTR(5) & 
    IU_AU_IB1_INSTR(19) & IU_AU_IB1_INSTR(21) & 
    IU_AU_IB1_INSTR(22) & IU_AU_IB1_INSTR(23) & 
    IU_AU_IB1_INSTR(24) & IU_AU_IB1_INSTR(25) & 
    IU_AU_IB1_INSTR(26) & IU_AU_IB1_INSTR(27) & 
    IU_AU_IB1_INSTR(28) & IU_AU_IB1_INSTR(29) & 
    IU_AU_IB1_INSTR(30) ) , STD_ULOGIC_VECTOR'("01111110111010011"));
MQQ17:BR_DEP_PT(17) <=
    Eq(( IU_AU_IB1_INSTR(0) & IU_AU_IB1_INSTR(1) & 
    IU_AU_IB1_INSTR(2) & IU_AU_IB1_INSTR(3) & 
    IU_AU_IB1_INSTR(4) & IU_AU_IB1_INSTR(5) & 
    IU_AU_IB1_INSTR(18) & IU_AU_IB1_INSTR(21) & 
    IU_AU_IB1_INSTR(22) & IU_AU_IB1_INSTR(23) & 
    IU_AU_IB1_INSTR(24) & IU_AU_IB1_INSTR(25) & 
    IU_AU_IB1_INSTR(26) & IU_AU_IB1_INSTR(27) & 
    IU_AU_IB1_INSTR(28) & IU_AU_IB1_INSTR(29) & 
    IU_AU_IB1_INSTR(30) ) , STD_ULOGIC_VECTOR'("01111110111010011"));
MQQ18:BR_DEP_PT(18) <=
    Eq(( IU_AU_IB1_INSTR(0) & IU_AU_IB1_INSTR(1) & 
    IU_AU_IB1_INSTR(2) & IU_AU_IB1_INSTR(3) & 
    IU_AU_IB1_INSTR(4) & IU_AU_IB1_INSTR(5) & 
    IU_AU_IB1_INSTR(17) & IU_AU_IB1_INSTR(21) & 
    IU_AU_IB1_INSTR(22) & IU_AU_IB1_INSTR(23) & 
    IU_AU_IB1_INSTR(24) & IU_AU_IB1_INSTR(25) & 
    IU_AU_IB1_INSTR(26) & IU_AU_IB1_INSTR(27) & 
    IU_AU_IB1_INSTR(28) & IU_AU_IB1_INSTR(29) & 
    IU_AU_IB1_INSTR(30) ) , STD_ULOGIC_VECTOR'("01111110111010011"));
MQQ19:BR_DEP_PT(19) <=
    Eq(( IU_AU_IB1_INSTR(0) & IU_AU_IB1_INSTR(1) & 
    IU_AU_IB1_INSTR(2) & IU_AU_IB1_INSTR(3) & 
    IU_AU_IB1_INSTR(4) & IU_AU_IB1_INSTR(5) & 
    IU_AU_IB1_INSTR(16) & IU_AU_IB1_INSTR(21) & 
    IU_AU_IB1_INSTR(22) & IU_AU_IB1_INSTR(23) & 
    IU_AU_IB1_INSTR(24) & IU_AU_IB1_INSTR(25) & 
    IU_AU_IB1_INSTR(26) & IU_AU_IB1_INSTR(27) & 
    IU_AU_IB1_INSTR(28) & IU_AU_IB1_INSTR(29) & 
    IU_AU_IB1_INSTR(30) ) , STD_ULOGIC_VECTOR'("01111110111010011"));
MQQ20:BR_DEP_PT(20) <=
    Eq(( IU_AU_IB1_INSTR(0) & IU_AU_IB1_INSTR(1) & 
    IU_AU_IB1_INSTR(2) & IU_AU_IB1_INSTR(3) & 
    IU_AU_IB1_INSTR(4) & IU_AU_IB1_INSTR(5) & 
    IU_AU_IB1_INSTR(14) & IU_AU_IB1_INSTR(21) & 
    IU_AU_IB1_INSTR(22) & IU_AU_IB1_INSTR(23) & 
    IU_AU_IB1_INSTR(24) & IU_AU_IB1_INSTR(25) & 
    IU_AU_IB1_INSTR(26) & IU_AU_IB1_INSTR(27) & 
    IU_AU_IB1_INSTR(28) & IU_AU_IB1_INSTR(29) & 
    IU_AU_IB1_INSTR(30) ) , STD_ULOGIC_VECTOR'("01111110111010011"));
MQQ21:BR_DEP_PT(21) <=
    Eq(( IU_AU_IB1_INSTR(0) & IU_AU_IB1_INSTR(1) & 
    IU_AU_IB1_INSTR(2) & IU_AU_IB1_INSTR(3) & 
    IU_AU_IB1_INSTR(4) & IU_AU_IB1_INSTR(5) & 
    IU_AU_IB1_INSTR(13) & IU_AU_IB1_INSTR(21) & 
    IU_AU_IB1_INSTR(22) & IU_AU_IB1_INSTR(23) & 
    IU_AU_IB1_INSTR(24) & IU_AU_IB1_INSTR(25) & 
    IU_AU_IB1_INSTR(26) & IU_AU_IB1_INSTR(27) & 
    IU_AU_IB1_INSTR(28) & IU_AU_IB1_INSTR(29) & 
    IU_AU_IB1_INSTR(30) ) , STD_ULOGIC_VECTOR'("01111110111010011"));
MQQ22:BR_DEP_PT(22) <=
    Eq(( IU_AU_IB1_INSTR(0) & IU_AU_IB1_INSTR(1) & 
    IU_AU_IB1_INSTR(2) & IU_AU_IB1_INSTR(3) & 
    IU_AU_IB1_INSTR(4) & IU_AU_IB1_INSTR(5) & 
    IU_AU_IB1_INSTR(11) & IU_AU_IB1_INSTR(21) & 
    IU_AU_IB1_INSTR(22) & IU_AU_IB1_INSTR(23) & 
    IU_AU_IB1_INSTR(24) & IU_AU_IB1_INSTR(25) & 
    IU_AU_IB1_INSTR(26) & IU_AU_IB1_INSTR(27) & 
    IU_AU_IB1_INSTR(28) & IU_AU_IB1_INSTR(29) & 
    IU_AU_IB1_INSTR(30) ) , STD_ULOGIC_VECTOR'("01111110111010011"));
MQQ23:BR_DEP_PT(23) <=
    Eq(( IU_AU_IB1_INSTR(0) & IU_AU_IB1_INSTR(1) & 
    IU_AU_IB1_INSTR(2) & IU_AU_IB1_INSTR(3) & 
    IU_AU_IB1_INSTR(4) & IU_AU_IB1_INSTR(5) & 
    IU_AU_IB1_INSTR(21) & IU_AU_IB1_INSTR(22) & 
    IU_AU_IB1_INSTR(23) & IU_AU_IB1_INSTR(24) & 
    IU_AU_IB1_INSTR(25) & IU_AU_IB1_INSTR(26) & 
    IU_AU_IB1_INSTR(27) & IU_AU_IB1_INSTR(28) & 
    IU_AU_IB1_INSTR(29) & IU_AU_IB1_INSTR(30)
     ) , STD_ULOGIC_VECTOR'("0100110000000000"));
MQQ24:BR_DEP_PT(24) <=
    Eq(( CORE64 & IU_AU_IB1_INSTR(0) & 
    IU_AU_IB1_INSTR(1) & IU_AU_IB1_INSTR(2) & 
    IU_AU_IB1_INSTR(3) & IU_AU_IB1_INSTR(4) & 
    IU_AU_IB1_INSTR(5) & IU_AU_IB1_INSTR(21) & 
    IU_AU_IB1_INSTR(22) & IU_AU_IB1_INSTR(23) & 
    IU_AU_IB1_INSTR(24) & IU_AU_IB1_INSTR(25) & 
    IU_AU_IB1_INSTR(26) & IU_AU_IB1_INSTR(27) & 
    IU_AU_IB1_INSTR(28) & IU_AU_IB1_INSTR(29)
     ) , STD_ULOGIC_VECTOR'("1011111110011101"));
MQQ25:BR_DEP_PT(25) <=
    Eq(( CORE64 & IU_AU_IB1_INSTR(0) & 
    IU_AU_IB1_INSTR(1) & IU_AU_IB1_INSTR(3) & 
    IU_AU_IB1_INSTR(5) & IU_AU_IB1_INSTR(21) & 
    IU_AU_IB1_INSTR(22) & IU_AU_IB1_INSTR(23) & 
    IU_AU_IB1_INSTR(24) & IU_AU_IB1_INSTR(25) & 
    IU_AU_IB1_INSTR(26) & IU_AU_IB1_INSTR(27) & 
    IU_AU_IB1_INSTR(28) & IU_AU_IB1_INSTR(29) & 
    IU_AU_IB1_INSTR(31) ) , STD_ULOGIC_VECTOR'("101111100111011"));
MQQ26:BR_DEP_PT(26) <=
    Eq(( CORE64 & IU_AU_IB1_INSTR(0) & 
    IU_AU_IB1_INSTR(1) & IU_AU_IB1_INSTR(2) & 
    IU_AU_IB1_INSTR(3) & IU_AU_IB1_INSTR(4) & 
    IU_AU_IB1_INSTR(5) & IU_AU_IB1_INSTR(21) & 
    IU_AU_IB1_INSTR(22) & IU_AU_IB1_INSTR(23) & 
    IU_AU_IB1_INSTR(24) & IU_AU_IB1_INSTR(25) & 
    IU_AU_IB1_INSTR(26) & IU_AU_IB1_INSTR(27) & 
    IU_AU_IB1_INSTR(28) ) , STD_ULOGIC_VECTOR'("101111110111010"));
MQQ27:BR_DEP_PT(27) <=
    Eq(( IU_AU_IB1_INSTR(0) & IU_AU_IB1_INSTR(1) & 
    IU_AU_IB1_INSTR(2) & IU_AU_IB1_INSTR(3) & 
    IU_AU_IB1_INSTR(4) & IU_AU_IB1_INSTR(5) & 
    IU_AU_IB1_INSTR(21) & IU_AU_IB1_INSTR(22) & 
    IU_AU_IB1_INSTR(23) & IU_AU_IB1_INSTR(24) & 
    IU_AU_IB1_INSTR(25) & IU_AU_IB1_INSTR(26) & 
    IU_AU_IB1_INSTR(27) & IU_AU_IB1_INSTR(28) & 
    IU_AU_IB1_INSTR(29) & IU_AU_IB1_INSTR(30) & 
    IU_AU_IB1_INSTR(31) ) , STD_ULOGIC_VECTOR'("01111100110101001"));
MQQ28:BR_DEP_PT(28) <=
    Eq(( IU_AU_IB1_INSTR(0) & IU_AU_IB1_INSTR(1) & 
    IU_AU_IB1_INSTR(2) & IU_AU_IB1_INSTR(3) & 
    IU_AU_IB1_INSTR(4) & IU_AU_IB1_INSTR(5) & 
    IU_AU_IB1_INSTR(21) & IU_AU_IB1_INSTR(23) & 
    IU_AU_IB1_INSTR(24) & IU_AU_IB1_INSTR(25) & 
    IU_AU_IB1_INSTR(26) & IU_AU_IB1_INSTR(27) & 
    IU_AU_IB1_INSTR(28) & IU_AU_IB1_INSTR(29) & 
    IU_AU_IB1_INSTR(30) ) , STD_ULOGIC_VECTOR'("010011000100001"));
MQQ29:BR_DEP_PT(29) <=
    Eq(( IU_AU_IB1_INSTR(0) & IU_AU_IB1_INSTR(1) & 
    IU_AU_IB1_INSTR(2) & IU_AU_IB1_INSTR(3) & 
    IU_AU_IB1_INSTR(4) & IU_AU_IB1_INSTR(5) & 
    IU_AU_IB1_INSTR(21) & IU_AU_IB1_INSTR(22) & 
    IU_AU_IB1_INSTR(24) & IU_AU_IB1_INSTR(25) & 
    IU_AU_IB1_INSTR(26) & IU_AU_IB1_INSTR(27) & 
    IU_AU_IB1_INSTR(28) & IU_AU_IB1_INSTR(29) & 
    IU_AU_IB1_INSTR(30) ) , STD_ULOGIC_VECTOR'("010011010100001"));
MQQ30:BR_DEP_PT(30) <=
    Eq(( IU_AU_IB1_INSTR(0) & IU_AU_IB1_INSTR(1) & 
    IU_AU_IB1_INSTR(2) & IU_AU_IB1_INSTR(3) & 
    IU_AU_IB1_INSTR(4) & IU_AU_IB1_INSTR(5) & 
    IU_AU_IB1_INSTR(21) & IU_AU_IB1_INSTR(22) & 
    IU_AU_IB1_INSTR(23) & IU_AU_IB1_INSTR(24) & 
    IU_AU_IB1_INSTR(25) & IU_AU_IB1_INSTR(26) & 
    IU_AU_IB1_INSTR(27) & IU_AU_IB1_INSTR(28) & 
    IU_AU_IB1_INSTR(29) ) , STD_ULOGIC_VECTOR'("010011000011001"));
MQQ31:BR_DEP_PT(31) <=
    Eq(( IU_AU_IB1_INSTR(0) & IU_AU_IB1_INSTR(1) & 
    IU_AU_IB1_INSTR(2) & IU_AU_IB1_INSTR(3) & 
    IU_AU_IB1_INSTR(4) & IU_AU_IB1_INSTR(5) & 
    IU_AU_IB1_INSTR(21) & IU_AU_IB1_INSTR(22) & 
    IU_AU_IB1_INSTR(23) & IU_AU_IB1_INSTR(25) & 
    IU_AU_IB1_INSTR(26) & IU_AU_IB1_INSTR(27) & 
    IU_AU_IB1_INSTR(28) & IU_AU_IB1_INSTR(29) & 
    IU_AU_IB1_INSTR(30) ) , STD_ULOGIC_VECTOR'("011111100101000"));
MQQ32:BR_DEP_PT(32) <=
    Eq(( IU_AU_IB1_INSTR(0) & IU_AU_IB1_INSTR(1) & 
    IU_AU_IB1_INSTR(2) & IU_AU_IB1_INSTR(3) & 
    IU_AU_IB1_INSTR(4) & IU_AU_IB1_INSTR(5) & 
    IU_AU_IB1_INSTR(21) & IU_AU_IB1_INSTR(22) & 
    IU_AU_IB1_INSTR(23) & IU_AU_IB1_INSTR(24) & 
    IU_AU_IB1_INSTR(26) & IU_AU_IB1_INSTR(27) & 
    IU_AU_IB1_INSTR(28) & IU_AU_IB1_INSTR(29) & 
    IU_AU_IB1_INSTR(30) ) , STD_ULOGIC_VECTOR'("010011001100001"));
MQQ33:BR_DEP_PT(33) <=
    Eq(( IU_AU_IB1_INSTR(0) & IU_AU_IB1_INSTR(1) & 
    IU_AU_IB1_INSTR(2) & IU_AU_IB1_INSTR(3) & 
    IU_AU_IB1_INSTR(4) & IU_AU_IB1_INSTR(5) & 
    IU_AU_IB1_INSTR(21) & IU_AU_IB1_INSTR(22) & 
    IU_AU_IB1_INSTR(23) & IU_AU_IB1_INSTR(24) & 
    IU_AU_IB1_INSTR(25) & IU_AU_IB1_INSTR(26) & 
    IU_AU_IB1_INSTR(27) & IU_AU_IB1_INSTR(28) & 
    IU_AU_IB1_INSTR(29) & IU_AU_IB1_INSTR(30)
     ) , STD_ULOGIC_VECTOR'("0111110110010110"));
MQQ34:BR_DEP_PT(34) <=
    Eq(( IU_AU_IB1_INSTR(0) & IU_AU_IB1_INSTR(1) & 
    IU_AU_IB1_INSTR(2) & IU_AU_IB1_INSTR(3) & 
    IU_AU_IB1_INSTR(4) & IU_AU_IB1_INSTR(5) & 
    IU_AU_IB1_INSTR(21) & IU_AU_IB1_INSTR(22) & 
    IU_AU_IB1_INSTR(23) & IU_AU_IB1_INSTR(24) & 
    IU_AU_IB1_INSTR(26) & IU_AU_IB1_INSTR(27) & 
    IU_AU_IB1_INSTR(28) & IU_AU_IB1_INSTR(29) & 
    IU_AU_IB1_INSTR(30) ) , STD_ULOGIC_VECTOR'("011111111000110"));
MQQ35:BR_DEP_PT(35) <=
    Eq(( CORE64 & IU_AU_IB1_INSTR(0) & 
    IU_AU_IB1_INSTR(1) & IU_AU_IB1_INSTR(2) & 
    IU_AU_IB1_INSTR(3) & IU_AU_IB1_INSTR(21) & 
    IU_AU_IB1_INSTR(22) & IU_AU_IB1_INSTR(23) & 
    IU_AU_IB1_INSTR(24) & IU_AU_IB1_INSTR(25) & 
    IU_AU_IB1_INSTR(26) & IU_AU_IB1_INSTR(27) & 
    IU_AU_IB1_INSTR(28) & IU_AU_IB1_INSTR(30) & 
    IU_AU_IB1_INSTR(31) ) , STD_ULOGIC_VECTOR'("101110011010101"));
MQQ36:BR_DEP_PT(36) <=
    Eq(( IU_AU_IB1_INSTR(0) & IU_AU_IB1_INSTR(1) & 
    IU_AU_IB1_INSTR(2) & IU_AU_IB1_INSTR(3) & 
    IU_AU_IB1_INSTR(4) & IU_AU_IB1_INSTR(5) & 
    IU_AU_IB1_INSTR(21) & IU_AU_IB1_INSTR(23) & 
    IU_AU_IB1_INSTR(24) & IU_AU_IB1_INSTR(25) & 
    IU_AU_IB1_INSTR(26) & IU_AU_IB1_INSTR(27) & 
    IU_AU_IB1_INSTR(28) & IU_AU_IB1_INSTR(29) & 
    IU_AU_IB1_INSTR(30) ) , STD_ULOGIC_VECTOR'("010011011000001"));
MQQ37:BR_DEP_PT(37) <=
    Eq(( IU_AU_IB1_INSTR(0) & IU_AU_IB1_INSTR(1) & 
    IU_AU_IB1_INSTR(2) & IU_AU_IB1_INSTR(3) & 
    IU_AU_IB1_INSTR(4) & IU_AU_IB1_INSTR(5) & 
    IU_AU_IB1_INSTR(21) & IU_AU_IB1_INSTR(22) & 
    IU_AU_IB1_INSTR(23) & IU_AU_IB1_INSTR(24) & 
    IU_AU_IB1_INSTR(25) & IU_AU_IB1_INSTR(26) & 
    IU_AU_IB1_INSTR(27) & IU_AU_IB1_INSTR(28) & 
    IU_AU_IB1_INSTR(29) ) , STD_ULOGIC_VECTOR'("011111101110101"));
MQQ38:BR_DEP_PT(38) <=
    Eq(( IU_AU_IB1_INSTR(0) & IU_AU_IB1_INSTR(1) & 
    IU_AU_IB1_INSTR(2) & IU_AU_IB1_INSTR(3) & 
    IU_AU_IB1_INSTR(4) & IU_AU_IB1_INSTR(5) & 
    IU_AU_IB1_INSTR(21) & IU_AU_IB1_INSTR(22) & 
    IU_AU_IB1_INSTR(23) & IU_AU_IB1_INSTR(25) & 
    IU_AU_IB1_INSTR(26) & IU_AU_IB1_INSTR(27) & 
    IU_AU_IB1_INSTR(28) & IU_AU_IB1_INSTR(29) & 
    IU_AU_IB1_INSTR(30) ) , STD_ULOGIC_VECTOR'("010011001000001"));
MQQ39:BR_DEP_PT(39) <=
    Eq(( IU_AU_IB1_INSTR(0) & IU_AU_IB1_INSTR(1) & 
    IU_AU_IB1_INSTR(2) & IU_AU_IB1_INSTR(3) & 
    IU_AU_IB1_INSTR(4) & IU_AU_IB1_INSTR(5) & 
    IU_AU_IB1_INSTR(21) & IU_AU_IB1_INSTR(22) & 
    IU_AU_IB1_INSTR(23) & IU_AU_IB1_INSTR(24) & 
    IU_AU_IB1_INSTR(26) & IU_AU_IB1_INSTR(27) & 
    IU_AU_IB1_INSTR(28) & IU_AU_IB1_INSTR(29) & 
    IU_AU_IB1_INSTR(30) ) , STD_ULOGIC_VECTOR'("010011010000001"));
MQQ40:BR_DEP_PT(40) <=
    Eq(( IU_AU_IB1_INSTR(0) & IU_AU_IB1_INSTR(1) & 
    IU_AU_IB1_INSTR(2) & IU_AU_IB1_INSTR(3) & 
    IU_AU_IB1_INSTR(4) & IU_AU_IB1_INSTR(5) & 
    IU_AU_IB1_INSTR(20) & IU_AU_IB1_INSTR(21) & 
    IU_AU_IB1_INSTR(22) & IU_AU_IB1_INSTR(23) & 
    IU_AU_IB1_INSTR(24) & IU_AU_IB1_INSTR(26) & 
    IU_AU_IB1_INSTR(27) & IU_AU_IB1_INSTR(28) & 
    IU_AU_IB1_INSTR(29) & IU_AU_IB1_INSTR(30)
     ) , STD_ULOGIC_VECTOR'("0111111010110011"));
MQQ41:BR_DEP_PT(41) <=
    Eq(( IU_AU_IB1_INSTR(0) & IU_AU_IB1_INSTR(1) & 
    IU_AU_IB1_INSTR(2) & IU_AU_IB1_INSTR(3) & 
    IU_AU_IB1_INSTR(4) & IU_AU_IB1_INSTR(5) & 
    IU_AU_IB1_INSTR(19) & IU_AU_IB1_INSTR(21) & 
    IU_AU_IB1_INSTR(22) & IU_AU_IB1_INSTR(23) & 
    IU_AU_IB1_INSTR(24) & IU_AU_IB1_INSTR(26) & 
    IU_AU_IB1_INSTR(27) & IU_AU_IB1_INSTR(28) & 
    IU_AU_IB1_INSTR(29) & IU_AU_IB1_INSTR(30)
     ) , STD_ULOGIC_VECTOR'("0111111010110011"));
MQQ42:BR_DEP_PT(42) <=
    Eq(( IU_AU_IB1_INSTR(0) & IU_AU_IB1_INSTR(1) & 
    IU_AU_IB1_INSTR(2) & IU_AU_IB1_INSTR(3) & 
    IU_AU_IB1_INSTR(4) & IU_AU_IB1_INSTR(5) & 
    IU_AU_IB1_INSTR(18) & IU_AU_IB1_INSTR(21) & 
    IU_AU_IB1_INSTR(22) & IU_AU_IB1_INSTR(23) & 
    IU_AU_IB1_INSTR(24) & IU_AU_IB1_INSTR(26) & 
    IU_AU_IB1_INSTR(27) & IU_AU_IB1_INSTR(28) & 
    IU_AU_IB1_INSTR(29) & IU_AU_IB1_INSTR(30)
     ) , STD_ULOGIC_VECTOR'("0111111010110011"));
MQQ43:BR_DEP_PT(43) <=
    Eq(( IU_AU_IB1_INSTR(0) & IU_AU_IB1_INSTR(1) & 
    IU_AU_IB1_INSTR(2) & IU_AU_IB1_INSTR(3) & 
    IU_AU_IB1_INSTR(4) & IU_AU_IB1_INSTR(5) & 
    IU_AU_IB1_INSTR(17) & IU_AU_IB1_INSTR(21) & 
    IU_AU_IB1_INSTR(22) & IU_AU_IB1_INSTR(23) & 
    IU_AU_IB1_INSTR(24) & IU_AU_IB1_INSTR(26) & 
    IU_AU_IB1_INSTR(27) & IU_AU_IB1_INSTR(28) & 
    IU_AU_IB1_INSTR(29) & IU_AU_IB1_INSTR(30)
     ) , STD_ULOGIC_VECTOR'("0111111010110011"));
MQQ44:BR_DEP_PT(44) <=
    Eq(( IU_AU_IB1_INSTR(0) & IU_AU_IB1_INSTR(1) & 
    IU_AU_IB1_INSTR(2) & IU_AU_IB1_INSTR(3) & 
    IU_AU_IB1_INSTR(4) & IU_AU_IB1_INSTR(5) & 
    IU_AU_IB1_INSTR(16) & IU_AU_IB1_INSTR(21) & 
    IU_AU_IB1_INSTR(22) & IU_AU_IB1_INSTR(23) & 
    IU_AU_IB1_INSTR(24) & IU_AU_IB1_INSTR(26) & 
    IU_AU_IB1_INSTR(27) & IU_AU_IB1_INSTR(28) & 
    IU_AU_IB1_INSTR(29) & IU_AU_IB1_INSTR(30)
     ) , STD_ULOGIC_VECTOR'("0111111010110011"));
MQQ45:BR_DEP_PT(45) <=
    Eq(( IU_AU_IB1_INSTR(0) & IU_AU_IB1_INSTR(1) & 
    IU_AU_IB1_INSTR(2) & IU_AU_IB1_INSTR(3) & 
    IU_AU_IB1_INSTR(4) & IU_AU_IB1_INSTR(5) & 
    IU_AU_IB1_INSTR(14) & IU_AU_IB1_INSTR(21) & 
    IU_AU_IB1_INSTR(22) & IU_AU_IB1_INSTR(23) & 
    IU_AU_IB1_INSTR(24) & IU_AU_IB1_INSTR(26) & 
    IU_AU_IB1_INSTR(27) & IU_AU_IB1_INSTR(28) & 
    IU_AU_IB1_INSTR(29) & IU_AU_IB1_INSTR(30)
     ) , STD_ULOGIC_VECTOR'("0111111010110011"));
MQQ46:BR_DEP_PT(46) <=
    Eq(( IU_AU_IB1_INSTR(0) & IU_AU_IB1_INSTR(1) & 
    IU_AU_IB1_INSTR(2) & IU_AU_IB1_INSTR(3) & 
    IU_AU_IB1_INSTR(4) & IU_AU_IB1_INSTR(5) & 
    IU_AU_IB1_INSTR(13) & IU_AU_IB1_INSTR(21) & 
    IU_AU_IB1_INSTR(22) & IU_AU_IB1_INSTR(23) & 
    IU_AU_IB1_INSTR(24) & IU_AU_IB1_INSTR(26) & 
    IU_AU_IB1_INSTR(27) & IU_AU_IB1_INSTR(28) & 
    IU_AU_IB1_INSTR(29) & IU_AU_IB1_INSTR(30)
     ) , STD_ULOGIC_VECTOR'("0111111010110011"));
MQQ47:BR_DEP_PT(47) <=
    Eq(( IU_AU_IB1_INSTR(0) & IU_AU_IB1_INSTR(1) & 
    IU_AU_IB1_INSTR(2) & IU_AU_IB1_INSTR(3) & 
    IU_AU_IB1_INSTR(4) & IU_AU_IB1_INSTR(5) & 
    IU_AU_IB1_INSTR(11) & IU_AU_IB1_INSTR(21) & 
    IU_AU_IB1_INSTR(22) & IU_AU_IB1_INSTR(23) & 
    IU_AU_IB1_INSTR(24) & IU_AU_IB1_INSTR(26) & 
    IU_AU_IB1_INSTR(27) & IU_AU_IB1_INSTR(28) & 
    IU_AU_IB1_INSTR(29) & IU_AU_IB1_INSTR(30)
     ) , STD_ULOGIC_VECTOR'("0111111010110011"));
MQQ48:BR_DEP_PT(48) <=
    Eq(( IU_AU_IB1_INSTR(0) & IU_AU_IB1_INSTR(1) & 
    IU_AU_IB1_INSTR(2) & IU_AU_IB1_INSTR(3) & 
    IU_AU_IB1_INSTR(5) & IU_AU_IB1_INSTR(21) & 
    IU_AU_IB1_INSTR(22) & IU_AU_IB1_INSTR(23) & 
    IU_AU_IB1_INSTR(24) & IU_AU_IB1_INSTR(25) & 
    IU_AU_IB1_INSTR(26) & IU_AU_IB1_INSTR(27) & 
    IU_AU_IB1_INSTR(28) & IU_AU_IB1_INSTR(29) & 
    IU_AU_IB1_INSTR(30) ) , STD_ULOGIC_VECTOR'("011111110000110"));
MQQ49:BR_DEP_PT(49) <=
    Eq(( IU_AU_IB1_INSTR(0) & IU_AU_IB1_INSTR(1) & 
    IU_AU_IB1_INSTR(2) & IU_AU_IB1_INSTR(3) & 
    IU_AU_IB1_INSTR(4) & IU_AU_IB1_INSTR(5) & 
    IU_AU_IB1_INSTR(21) & IU_AU_IB1_INSTR(22) & 
    IU_AU_IB1_INSTR(23) & IU_AU_IB1_INSTR(24) & 
    IU_AU_IB1_INSTR(25) & IU_AU_IB1_INSTR(26) & 
    IU_AU_IB1_INSTR(27) & IU_AU_IB1_INSTR(28) & 
    IU_AU_IB1_INSTR(29) & IU_AU_IB1_INSTR(30)
     ) , STD_ULOGIC_VECTOR'("0111110101110011"));
MQQ50:BR_DEP_PT(50) <=
    Eq(( CORE64 & IU_AU_IB1_INSTR(0) & 
    IU_AU_IB1_INSTR(1) & IU_AU_IB1_INSTR(2) & 
    IU_AU_IB1_INSTR(3) & IU_AU_IB1_INSTR(4) & 
    IU_AU_IB1_INSTR(5) & IU_AU_IB1_INSTR(21) & 
    IU_AU_IB1_INSTR(22) & IU_AU_IB1_INSTR(23) & 
    IU_AU_IB1_INSTR(24) & IU_AU_IB1_INSTR(26) & 
    IU_AU_IB1_INSTR(27) & IU_AU_IB1_INSTR(28) & 
    IU_AU_IB1_INSTR(30) ) , STD_ULOGIC_VECTOR'("101111111001100"));
MQQ51:BR_DEP_PT(51) <=
    Eq(( CORE64 & IU_AU_IB1_INSTR(0) & 
    IU_AU_IB1_INSTR(1) & IU_AU_IB1_INSTR(3) & 
    IU_AU_IB1_INSTR(5) & IU_AU_IB1_INSTR(21) & 
    IU_AU_IB1_INSTR(22) & IU_AU_IB1_INSTR(23) & 
    IU_AU_IB1_INSTR(24) & IU_AU_IB1_INSTR(26) & 
    IU_AU_IB1_INSTR(27) & IU_AU_IB1_INSTR(28) & 
    IU_AU_IB1_INSTR(30) & IU_AU_IB1_INSTR(31)
     ) , STD_ULOGIC_VECTOR'("10111110011001"));
MQQ52:BR_DEP_PT(52) <=
    Eq(( IU_AU_IB1_INSTR(0) & IU_AU_IB1_INSTR(1) & 
    IU_AU_IB1_INSTR(2) & IU_AU_IB1_INSTR(3) & 
    IU_AU_IB1_INSTR(4) & IU_AU_IB1_INSTR(5) & 
    IU_AU_IB1_INSTR(21) & IU_AU_IB1_INSTR(22) & 
    IU_AU_IB1_INSTR(23) & IU_AU_IB1_INSTR(24) & 
    IU_AU_IB1_INSTR(25) & IU_AU_IB1_INSTR(26) & 
    IU_AU_IB1_INSTR(27) & IU_AU_IB1_INSTR(28) & 
    IU_AU_IB1_INSTR(29) & IU_AU_IB1_INSTR(30)
     ) , STD_ULOGIC_VECTOR'("0111110001010011"));
MQQ53:BR_DEP_PT(53) <=
    Eq(( IU_AU_IB1_INSTR(0) & IU_AU_IB1_INSTR(1) & 
    IU_AU_IB1_INSTR(2) & IU_AU_IB1_INSTR(3) & 
    IU_AU_IB1_INSTR(4) & IU_AU_IB1_INSTR(5) & 
    IU_AU_IB1_INSTR(21) & IU_AU_IB1_INSTR(22) & 
    IU_AU_IB1_INSTR(23) & IU_AU_IB1_INSTR(24) & 
    IU_AU_IB1_INSTR(26) & IU_AU_IB1_INSTR(27) & 
    IU_AU_IB1_INSTR(28) & IU_AU_IB1_INSTR(29) & 
    IU_AU_IB1_INSTR(30) ) , STD_ULOGIC_VECTOR'("011111110011000"));
MQQ54:BR_DEP_PT(54) <=
    Eq(( IU_AU_IB1_INSTR(0) & IU_AU_IB1_INSTR(1) & 
    IU_AU_IB1_INSTR(2) & IU_AU_IB1_INSTR(3) & 
    IU_AU_IB1_INSTR(4) & IU_AU_IB1_INSTR(5) & 
    IU_AU_IB1_INSTR(21) & IU_AU_IB1_INSTR(22) & 
    IU_AU_IB1_INSTR(23) & IU_AU_IB1_INSTR(24) & 
    IU_AU_IB1_INSTR(25) & IU_AU_IB1_INSTR(26) & 
    IU_AU_IB1_INSTR(27) & IU_AU_IB1_INSTR(28) & 
    IU_AU_IB1_INSTR(29) & IU_AU_IB1_INSTR(30)
     ) , STD_ULOGIC_VECTOR'("0111110010010010"));
MQQ55:BR_DEP_PT(55) <=
    Eq(( IU_AU_IB1_INSTR(0) & IU_AU_IB1_INSTR(1) & 
    IU_AU_IB1_INSTR(2) & IU_AU_IB1_INSTR(3) & 
    IU_AU_IB1_INSTR(4) & IU_AU_IB1_INSTR(5) & 
    IU_AU_IB1_INSTR(21) & IU_AU_IB1_INSTR(23) & 
    IU_AU_IB1_INSTR(24) & IU_AU_IB1_INSTR(25) & 
    IU_AU_IB1_INSTR(26) & IU_AU_IB1_INSTR(27) & 
    IU_AU_IB1_INSTR(28) & IU_AU_IB1_INSTR(29) & 
    IU_AU_IB1_INSTR(30) ) , STD_ULOGIC_VECTOR'("011111100001010"));
MQQ56:BR_DEP_PT(56) <=
    Eq(( IU_AU_IB1_INSTR(0) & IU_AU_IB1_INSTR(1) & 
    IU_AU_IB1_INSTR(3) & IU_AU_IB1_INSTR(5) & 
    IU_AU_IB1_INSTR(21) & IU_AU_IB1_INSTR(22) & 
    IU_AU_IB1_INSTR(23) & IU_AU_IB1_INSTR(24) & 
    IU_AU_IB1_INSTR(26) & IU_AU_IB1_INSTR(27) & 
    IU_AU_IB1_INSTR(28) & IU_AU_IB1_INSTR(29) & 
    IU_AU_IB1_INSTR(30) & IU_AU_IB1_INSTR(31)
     ) , STD_ULOGIC_VECTOR'("01111100110001"));
MQQ57:BR_DEP_PT(57) <=
    Eq(( IU_AU_IB1_INSTR(0) & IU_AU_IB1_INSTR(1) & 
    IU_AU_IB1_INSTR(2) & IU_AU_IB1_INSTR(3) & 
    IU_AU_IB1_INSTR(4) & IU_AU_IB1_INSTR(5) & 
    IU_AU_IB1_INSTR(21) & IU_AU_IB1_INSTR(22) & 
    IU_AU_IB1_INSTR(23) & IU_AU_IB1_INSTR(24) & 
    IU_AU_IB1_INSTR(25) & IU_AU_IB1_INSTR(26) & 
    IU_AU_IB1_INSTR(27) & IU_AU_IB1_INSTR(28) & 
    IU_AU_IB1_INSTR(29) & IU_AU_IB1_INSTR(30)
     ) , STD_ULOGIC_VECTOR'("0111110000010011"));
MQQ58:BR_DEP_PT(58) <=
    Eq(( IU_AU_IB1_INSTR(0) & IU_AU_IB1_INSTR(1) & 
    IU_AU_IB1_INSTR(2) & IU_AU_IB1_INSTR(3) & 
    IU_AU_IB1_INSTR(5) & IU_AU_IB1_INSTR(21) & 
    IU_AU_IB1_INSTR(22) & IU_AU_IB1_INSTR(24) & 
    IU_AU_IB1_INSTR(25) & IU_AU_IB1_INSTR(26) & 
    IU_AU_IB1_INSTR(27) & IU_AU_IB1_INSTR(28) & 
    IU_AU_IB1_INSTR(29) & IU_AU_IB1_INSTR(30)
     ) , STD_ULOGIC_VECTOR'("01111100010101"));
MQQ59:BR_DEP_PT(59) <=
    Eq(( IU_AU_IB1_INSTR(0) & IU_AU_IB1_INSTR(1) & 
    IU_AU_IB1_INSTR(3) & IU_AU_IB1_INSTR(5) & 
    IU_AU_IB1_INSTR(21) & IU_AU_IB1_INSTR(22) & 
    IU_AU_IB1_INSTR(23) & IU_AU_IB1_INSTR(25) & 
    IU_AU_IB1_INSTR(26) & IU_AU_IB1_INSTR(27) & 
    IU_AU_IB1_INSTR(28) & IU_AU_IB1_INSTR(29) & 
    IU_AU_IB1_INSTR(30) & IU_AU_IB1_INSTR(31)
     ) , STD_ULOGIC_VECTOR'("01110001111001"));
MQQ60:BR_DEP_PT(60) <=
    Eq(( IU_AU_IB1_INSTR(0) & IU_AU_IB1_INSTR(1) & 
    IU_AU_IB1_INSTR(2) & IU_AU_IB1_INSTR(3) & 
    IU_AU_IB1_INSTR(4) & IU_AU_IB1_INSTR(5) & 
    IU_AU_IB1_INSTR(21) & IU_AU_IB1_INSTR(22) & 
    IU_AU_IB1_INSTR(23) & IU_AU_IB1_INSTR(24) & 
    IU_AU_IB1_INSTR(25) & IU_AU_IB1_INSTR(26) & 
    IU_AU_IB1_INSTR(27) & IU_AU_IB1_INSTR(28) & 
    IU_AU_IB1_INSTR(29) & IU_AU_IB1_INSTR(30)
     ) , STD_ULOGIC_VECTOR'("0111111000000000"));
MQQ61:BR_DEP_PT(61) <=
    Eq(( CORE64 & IU_AU_IB1_INSTR(0) & 
    IU_AU_IB1_INSTR(1) & IU_AU_IB1_INSTR(2) & 
    IU_AU_IB1_INSTR(3) & IU_AU_IB1_INSTR(4) & 
    IU_AU_IB1_INSTR(5) & IU_AU_IB1_INSTR(21) & 
    IU_AU_IB1_INSTR(22) & IU_AU_IB1_INSTR(23) & 
    IU_AU_IB1_INSTR(26) & IU_AU_IB1_INSTR(27) & 
    IU_AU_IB1_INSTR(28) & IU_AU_IB1_INSTR(30)
     ) , STD_ULOGIC_VECTOR'("10111111110101"));
MQQ62:BR_DEP_PT(62) <=
    Eq(( CORE64 & IU_AU_IB1_INSTR(0) & 
    IU_AU_IB1_INSTR(1) & IU_AU_IB1_INSTR(3) & 
    IU_AU_IB1_INSTR(5) & IU_AU_IB1_INSTR(21) & 
    IU_AU_IB1_INSTR(22) & IU_AU_IB1_INSTR(23) & 
    IU_AU_IB1_INSTR(25) & IU_AU_IB1_INSTR(26) & 
    IU_AU_IB1_INSTR(27) & IU_AU_IB1_INSTR(28) & 
    IU_AU_IB1_INSTR(29) & IU_AU_IB1_INSTR(30) & 
    IU_AU_IB1_INSTR(31) ) , STD_ULOGIC_VECTOR'("101111110110101"));
MQQ63:BR_DEP_PT(63) <=
    Eq(( IU_AU_IB1_INSTR(0) & IU_AU_IB1_INSTR(1) & 
    IU_AU_IB1_INSTR(3) & IU_AU_IB1_INSTR(5) & 
    IU_AU_IB1_INSTR(21) & IU_AU_IB1_INSTR(22) & 
    IU_AU_IB1_INSTR(23) & IU_AU_IB1_INSTR(24) & 
    IU_AU_IB1_INSTR(25) & IU_AU_IB1_INSTR(26) & 
    IU_AU_IB1_INSTR(27) & IU_AU_IB1_INSTR(28) & 
    IU_AU_IB1_INSTR(29) & IU_AU_IB1_INSTR(30) & 
    IU_AU_IB1_INSTR(31) ) , STD_ULOGIC_VECTOR'("011111010100101"));
MQQ64:BR_DEP_PT(64) <=
    Eq(( IU_AU_IB1_INSTR(0) & IU_AU_IB1_INSTR(1) & 
    IU_AU_IB1_INSTR(2) & IU_AU_IB1_INSTR(3) & 
    IU_AU_IB1_INSTR(4) & IU_AU_IB1_INSTR(5) & 
    IU_AU_IB1_INSTR(21) & IU_AU_IB1_INSTR(22) & 
    IU_AU_IB1_INSTR(23) & IU_AU_IB1_INSTR(24) & 
    IU_AU_IB1_INSTR(26) & IU_AU_IB1_INSTR(27) & 
    IU_AU_IB1_INSTR(28) & IU_AU_IB1_INSTR(29) & 
    IU_AU_IB1_INSTR(30) ) , STD_ULOGIC_VECTOR'("011111001000011"));
MQQ65:BR_DEP_PT(65) <=
    Eq(( CORE64 & IU_AU_IB1_INSTR(0) & 
    IU_AU_IB1_INSTR(1) & IU_AU_IB1_INSTR(3) & 
    IU_AU_IB1_INSTR(5) & IU_AU_IB1_INSTR(21) & 
    IU_AU_IB1_INSTR(22) & IU_AU_IB1_INSTR(23) & 
    IU_AU_IB1_INSTR(24) & IU_AU_IB1_INSTR(26) & 
    IU_AU_IB1_INSTR(27) & IU_AU_IB1_INSTR(28) & 
    IU_AU_IB1_INSTR(29) & IU_AU_IB1_INSTR(30) & 
    IU_AU_IB1_INSTR(31) ) , STD_ULOGIC_VECTOR'("101110000110101"));
MQQ66:BR_DEP_PT(66) <=
    Eq(( IU_AU_IB1_INSTR(0) & IU_AU_IB1_INSTR(1) & 
    IU_AU_IB1_INSTR(2) & IU_AU_IB1_INSTR(3) & 
    IU_AU_IB1_INSTR(5) & IU_AU_IB1_INSTR(21) & 
    IU_AU_IB1_INSTR(22) & IU_AU_IB1_INSTR(23) & 
    IU_AU_IB1_INSTR(24) & IU_AU_IB1_INSTR(25) & 
    IU_AU_IB1_INSTR(26) & IU_AU_IB1_INSTR(27) & 
    IU_AU_IB1_INSTR(28) & IU_AU_IB1_INSTR(29) & 
    IU_AU_IB1_INSTR(30) ) , STD_ULOGIC_VECTOR'("011110010010000"));
MQQ67:BR_DEP_PT(67) <=
    Eq(( IU_AU_IB1_INSTR(0) & IU_AU_IB1_INSTR(1) & 
    IU_AU_IB1_INSTR(3) & IU_AU_IB1_INSTR(5) & 
    IU_AU_IB1_INSTR(21) & IU_AU_IB1_INSTR(22) & 
    IU_AU_IB1_INSTR(23) & IU_AU_IB1_INSTR(25) & 
    IU_AU_IB1_INSTR(26) & IU_AU_IB1_INSTR(27) & 
    IU_AU_IB1_INSTR(28) & IU_AU_IB1_INSTR(29) & 
    IU_AU_IB1_INSTR(30) & IU_AU_IB1_INSTR(31)
     ) , STD_ULOGIC_VECTOR'("01110110111001"));
MQQ68:BR_DEP_PT(68) <=
    Eq(( IU_AU_IB1_INSTR(0) & IU_AU_IB1_INSTR(1) & 
    IU_AU_IB1_INSTR(3) & IU_AU_IB1_INSTR(5) & 
    IU_AU_IB1_INSTR(21) & IU_AU_IB1_INSTR(22) & 
    IU_AU_IB1_INSTR(23) & IU_AU_IB1_INSTR(24) & 
    IU_AU_IB1_INSTR(25) & IU_AU_IB1_INSTR(26) & 
    IU_AU_IB1_INSTR(27) & IU_AU_IB1_INSTR(28) & 
    IU_AU_IB1_INSTR(29) & IU_AU_IB1_INSTR(30) & 
    IU_AU_IB1_INSTR(31) ) , STD_ULOGIC_VECTOR'("011100100100111"));
MQQ69:BR_DEP_PT(69) <=
    Eq(( IU_AU_IB1_INSTR(0) & IU_AU_IB1_INSTR(1) & 
    IU_AU_IB1_INSTR(2) & IU_AU_IB1_INSTR(3) & 
    IU_AU_IB1_INSTR(4) & IU_AU_IB1_INSTR(5) & 
    IU_AU_IB1_INSTR(21) & IU_AU_IB1_INSTR(22) & 
    IU_AU_IB1_INSTR(23) & IU_AU_IB1_INSTR(26) & 
    IU_AU_IB1_INSTR(27) & IU_AU_IB1_INSTR(28) & 
    IU_AU_IB1_INSTR(29) & IU_AU_IB1_INSTR(30)
     ) , STD_ULOGIC_VECTOR'("01111111101011"));
MQQ70:BR_DEP_PT(70) <=
    Eq(( IU_AU_IB1_INSTR(0) & IU_AU_IB1_INSTR(1) & 
    IU_AU_IB1_INSTR(3) & IU_AU_IB1_INSTR(5) & 
    IU_AU_IB1_INSTR(21) & IU_AU_IB1_INSTR(22) & 
    IU_AU_IB1_INSTR(23) & IU_AU_IB1_INSTR(24) & 
    IU_AU_IB1_INSTR(25) & IU_AU_IB1_INSTR(26) & 
    IU_AU_IB1_INSTR(28) & IU_AU_IB1_INSTR(29) & 
    IU_AU_IB1_INSTR(30) & IU_AU_IB1_INSTR(31)
     ) , STD_ULOGIC_VECTOR'("01111110010101"));
MQQ71:BR_DEP_PT(71) <=
    Eq(( IU_AU_IB1_INSTR(0) & IU_AU_IB1_INSTR(1) & 
    IU_AU_IB1_INSTR(3) & IU_AU_IB1_INSTR(5) & 
    IU_AU_IB1_INSTR(22) & IU_AU_IB1_INSTR(23) & 
    IU_AU_IB1_INSTR(24) & IU_AU_IB1_INSTR(26) & 
    IU_AU_IB1_INSTR(27) & IU_AU_IB1_INSTR(28) & 
    IU_AU_IB1_INSTR(30) & IU_AU_IB1_INSTR(31)
     ) , STD_ULOGIC_VECTOR'("011101101001"));
MQQ72:BR_DEP_PT(72) <=
    Eq(( CORE64 & IU_AU_IB1_INSTR(0) & 
    IU_AU_IB1_INSTR(1) & IU_AU_IB1_INSTR(3) & 
    IU_AU_IB1_INSTR(5) & IU_AU_IB1_INSTR(22) & 
    IU_AU_IB1_INSTR(23) & IU_AU_IB1_INSTR(24) & 
    IU_AU_IB1_INSTR(25) & IU_AU_IB1_INSTR(27) & 
    IU_AU_IB1_INSTR(28) & IU_AU_IB1_INSTR(29) & 
    IU_AU_IB1_INSTR(30) & IU_AU_IB1_INSTR(31)
     ) , STD_ULOGIC_VECTOR'("10111000010111"));
MQQ73:BR_DEP_PT(73) <=
    Eq(( CORE64 & IU_AU_IB1_INSTR(0) & 
    IU_AU_IB1_INSTR(1) & IU_AU_IB1_INSTR(3) & 
    IU_AU_IB1_INSTR(5) & IU_AU_IB1_INSTR(22) & 
    IU_AU_IB1_INSTR(23) & IU_AU_IB1_INSTR(24) & 
    IU_AU_IB1_INSTR(25) & IU_AU_IB1_INSTR(26) & 
    IU_AU_IB1_INSTR(27) & IU_AU_IB1_INSTR(28) & 
    IU_AU_IB1_INSTR(31) ) , STD_ULOGIC_VECTOR'("1011101110101"));
MQQ74:BR_DEP_PT(74) <=
    Eq(( IU_AU_IB1_INSTR(0) & IU_AU_IB1_INSTR(1) & 
    IU_AU_IB1_INSTR(3) & IU_AU_IB1_INSTR(5) & 
    IU_AU_IB1_INSTR(21) & IU_AU_IB1_INSTR(23) & 
    IU_AU_IB1_INSTR(24) & IU_AU_IB1_INSTR(25) & 
    IU_AU_IB1_INSTR(26) & IU_AU_IB1_INSTR(27) & 
    IU_AU_IB1_INSTR(28) & IU_AU_IB1_INSTR(29) & 
    IU_AU_IB1_INSTR(30) & IU_AU_IB1_INSTR(31)
     ) , STD_ULOGIC_VECTOR'("01110100101101"));
MQQ75:BR_DEP_PT(75) <=
    Eq(( IU_AU_IB1_INSTR(0) & IU_AU_IB1_INSTR(1) & 
    IU_AU_IB1_INSTR(3) & IU_AU_IB1_INSTR(5) & 
    IU_AU_IB1_INSTR(22) & IU_AU_IB1_INSTR(23) & 
    IU_AU_IB1_INSTR(25) & IU_AU_IB1_INSTR(26) & 
    IU_AU_IB1_INSTR(27) & IU_AU_IB1_INSTR(28) & 
    IU_AU_IB1_INSTR(30) & IU_AU_IB1_INSTR(31)
     ) , STD_ULOGIC_VECTOR'("011101001001"));
MQQ76:BR_DEP_PT(76) <=
    Eq(( IU_AU_IB1_INSTR(0) & IU_AU_IB1_INSTR(1) & 
    IU_AU_IB1_INSTR(3) & IU_AU_IB1_INSTR(5) & 
    IU_AU_IB1_INSTR(21) & IU_AU_IB1_INSTR(22) & 
    IU_AU_IB1_INSTR(23) & IU_AU_IB1_INSTR(24) & 
    IU_AU_IB1_INSTR(26) & IU_AU_IB1_INSTR(27) & 
    IU_AU_IB1_INSTR(28) & IU_AU_IB1_INSTR(29) & 
    IU_AU_IB1_INSTR(30) & IU_AU_IB1_INSTR(31)
     ) , STD_ULOGIC_VECTOR'("01111110110101"));
MQQ77:BR_DEP_PT(77) <=
    Eq(( IU_AU_IB1_INSTR(0) & IU_AU_IB1_INSTR(1) & 
    IU_AU_IB1_INSTR(3) & IU_AU_IB1_INSTR(5) & 
    IU_AU_IB1_INSTR(21) & IU_AU_IB1_INSTR(23) & 
    IU_AU_IB1_INSTR(24) & IU_AU_IB1_INSTR(26) & 
    IU_AU_IB1_INSTR(27) & IU_AU_IB1_INSTR(28) & 
    IU_AU_IB1_INSTR(29) & IU_AU_IB1_INSTR(30) & 
    IU_AU_IB1_INSTR(31) ) , STD_ULOGIC_VECTOR'("0111000111001"));
MQQ78:BR_DEP_PT(78) <=
    Eq(( IU_AU_IB1_INSTR(0) & IU_AU_IB1_INSTR(1) & 
    IU_AU_IB1_INSTR(3) & IU_AU_IB1_INSTR(5) & 
    IU_AU_IB1_INSTR(21) & IU_AU_IB1_INSTR(22) & 
    IU_AU_IB1_INSTR(24) & IU_AU_IB1_INSTR(26) & 
    IU_AU_IB1_INSTR(27) & IU_AU_IB1_INSTR(28) & 
    IU_AU_IB1_INSTR(29) & IU_AU_IB1_INSTR(30) & 
    IU_AU_IB1_INSTR(31) ) , STD_ULOGIC_VECTOR'("0111010111001"));
MQQ79:BR_DEP_PT(79) <=
    Eq(( IU_AU_IB1_INSTR(0) & IU_AU_IB1_INSTR(1) & 
    IU_AU_IB1_INSTR(3) & IU_AU_IB1_INSTR(5) & 
    IU_AU_IB1_INSTR(22) & IU_AU_IB1_INSTR(23) & 
    IU_AU_IB1_INSTR(25) & IU_AU_IB1_INSTR(26) & 
    IU_AU_IB1_INSTR(27) & IU_AU_IB1_INSTR(28) & 
    IU_AU_IB1_INSTR(29) & IU_AU_IB1_INSTR(30) & 
    IU_AU_IB1_INSTR(31) ) , STD_ULOGIC_VECTOR'("0111001010001"));
MQQ80:BR_DEP_PT(80) <=
    Eq(( IU_AU_IB1_INSTR(0) & IU_AU_IB1_INSTR(1) & 
    IU_AU_IB1_INSTR(3) & IU_AU_IB1_INSTR(5) & 
    IU_AU_IB1_INSTR(22) & IU_AU_IB1_INSTR(23) & 
    IU_AU_IB1_INSTR(24) & IU_AU_IB1_INSTR(25) & 
    IU_AU_IB1_INSTR(26) & IU_AU_IB1_INSTR(27) & 
    IU_AU_IB1_INSTR(28) & IU_AU_IB1_INSTR(29) & 
    IU_AU_IB1_INSTR(31) ) , STD_ULOGIC_VECTOR'("0111011101011"));
MQQ81:BR_DEP_PT(81) <=
    Eq(( IU_AU_IB1_INSTR(0) & IU_AU_IB1_INSTR(1) & 
    IU_AU_IB1_INSTR(2) & IU_AU_IB1_INSTR(3) & 
    IU_AU_IB1_INSTR(4) & IU_AU_IB1_INSTR(5) & 
    IU_AU_IB1_INSTR(22) & IU_AU_IB1_INSTR(24) & 
    IU_AU_IB1_INSTR(25) & IU_AU_IB1_INSTR(26) & 
    IU_AU_IB1_INSTR(27) & IU_AU_IB1_INSTR(28) & 
    IU_AU_IB1_INSTR(30) ) , STD_ULOGIC_VECTOR'("0111110000100"));
MQQ82:BR_DEP_PT(82) <=
    Eq(( IU_AU_IB1_INSTR(0) & IU_AU_IB1_INSTR(1) & 
    IU_AU_IB1_INSTR(2) & IU_AU_IB1_INSTR(3) & 
    IU_AU_IB1_INSTR(5) & IU_AU_IB1_INSTR(21) & 
    IU_AU_IB1_INSTR(22) & IU_AU_IB1_INSTR(23) & 
    IU_AU_IB1_INSTR(24) & IU_AU_IB1_INSTR(26) & 
    IU_AU_IB1_INSTR(27) & IU_AU_IB1_INSTR(28) & 
    IU_AU_IB1_INSTR(29) & IU_AU_IB1_INSTR(30)
     ) , STD_ULOGIC_VECTOR'("01111000000000"));
MQQ83:BR_DEP_PT(83) <=
    Eq(( CORE64 & IU_AU_IB1_INSTR(0) & 
    IU_AU_IB1_INSTR(1) & IU_AU_IB1_INSTR(3) & 
    IU_AU_IB1_INSTR(5) & IU_AU_IB1_INSTR(22) & 
    IU_AU_IB1_INSTR(23) & IU_AU_IB1_INSTR(25) & 
    IU_AU_IB1_INSTR(26) & IU_AU_IB1_INSTR(27) & 
    IU_AU_IB1_INSTR(28) & IU_AU_IB1_INSTR(30) & 
    IU_AU_IB1_INSTR(31) ) , STD_ULOGIC_VECTOR'("1011100001011"));
MQQ84:BR_DEP_PT(84) <=
    Eq(( IU_AU_IB1_INSTR(0) & IU_AU_IB1_INSTR(1) & 
    IU_AU_IB1_INSTR(3) & IU_AU_IB1_INSTR(5) & 
    IU_AU_IB1_INSTR(22) & IU_AU_IB1_INSTR(23) & 
    IU_AU_IB1_INSTR(24) & IU_AU_IB1_INSTR(25) & 
    IU_AU_IB1_INSTR(27) & IU_AU_IB1_INSTR(28) & 
    IU_AU_IB1_INSTR(29) & IU_AU_IB1_INSTR(30) & 
    IU_AU_IB1_INSTR(31) ) , STD_ULOGIC_VECTOR'("0111000010001"));
MQQ85:BR_DEP_PT(85) <=
    Eq(( IU_AU_IB1_INSTR(0) & IU_AU_IB1_INSTR(1) & 
    IU_AU_IB1_INSTR(2) & IU_AU_IB1_INSTR(3) & 
    IU_AU_IB1_INSTR(5) & IU_AU_IB1_INSTR(22) & 
    IU_AU_IB1_INSTR(23) & IU_AU_IB1_INSTR(25) & 
    IU_AU_IB1_INSTR(26) & IU_AU_IB1_INSTR(27) & 
    IU_AU_IB1_INSTR(28) & IU_AU_IB1_INSTR(30)
     ) , STD_ULOGIC_VECTOR'("011110100100"));
MQQ86:BR_DEP_PT(86) <=
    Eq(( IU_AU_IB1_INSTR(0) & IU_AU_IB1_INSTR(1) & 
    IU_AU_IB1_INSTR(2) & IU_AU_IB1_INSTR(3) & 
    IU_AU_IB1_INSTR(4) & IU_AU_IB1_INSTR(5) & 
    IU_AU_IB1_INSTR(22) & IU_AU_IB1_INSTR(23) & 
    IU_AU_IB1_INSTR(24) & IU_AU_IB1_INSTR(26) & 
    IU_AU_IB1_INSTR(27) & IU_AU_IB1_INSTR(28) & 
    IU_AU_IB1_INSTR(30) ) , STD_ULOGIC_VECTOR'("0111110110100"));
MQQ87:BR_DEP_PT(87) <=
    Eq(( IU_AU_IB1_INSTR(0) & IU_AU_IB1_INSTR(1) & 
    IU_AU_IB1_INSTR(3) & IU_AU_IB1_INSTR(5) & 
    IU_AU_IB1_INSTR(23) & IU_AU_IB1_INSTR(24) & 
    IU_AU_IB1_INSTR(25) & IU_AU_IB1_INSTR(26) & 
    IU_AU_IB1_INSTR(27) & IU_AU_IB1_INSTR(28) & 
    IU_AU_IB1_INSTR(29) & IU_AU_IB1_INSTR(30) & 
    IU_AU_IB1_INSTR(31) ) , STD_ULOGIC_VECTOR'("0111000010101"));
MQQ88:BR_DEP_PT(88) <=
    Eq(( IU_AU_IB1_INSTR(0) & IU_AU_IB1_INSTR(1) & 
    IU_AU_IB1_INSTR(3) & IU_AU_IB1_INSTR(5) & 
    IU_AU_IB1_INSTR(22) & IU_AU_IB1_INSTR(23) & 
    IU_AU_IB1_INSTR(25) & IU_AU_IB1_INSTR(26) & 
    IU_AU_IB1_INSTR(27) & IU_AU_IB1_INSTR(28) & 
    IU_AU_IB1_INSTR(29) & IU_AU_IB1_INSTR(30) & 
    IU_AU_IB1_INSTR(31) ) , STD_ULOGIC_VECTOR'("0111000010111"));
MQQ89:BR_DEP_PT(89) <=
    Eq(( IU_AU_IB1_INSTR(0) & IU_AU_IB1_INSTR(1) & 
    IU_AU_IB1_INSTR(2) & IU_AU_IB1_INSTR(3) & 
    IU_AU_IB1_INSTR(4) & IU_AU_IB1_INSTR(5) & 
    IU_AU_IB1_INSTR(8) ) , STD_ULOGIC_VECTOR'("0100000"));
MQQ90:BR_DEP_PT(90) <=
    Eq(( IU_AU_IB1_INSTR(0) & IU_AU_IB1_INSTR(1) & 
    IU_AU_IB1_INSTR(3) & IU_AU_IB1_INSTR(5) & 
    IU_AU_IB1_INSTR(21) & IU_AU_IB1_INSTR(22) & 
    IU_AU_IB1_INSTR(23) & IU_AU_IB1_INSTR(24) & 
    IU_AU_IB1_INSTR(25) & IU_AU_IB1_INSTR(27) & 
    IU_AU_IB1_INSTR(28) & IU_AU_IB1_INSTR(30) & 
    IU_AU_IB1_INSTR(31) ) , STD_ULOGIC_VECTOR'("0111000001001"));
MQQ91:BR_DEP_PT(91) <=
    Eq(( CORE64 & IU_AU_IB1_INSTR(0) & 
    IU_AU_IB1_INSTR(1) & IU_AU_IB1_INSTR(3) & 
    IU_AU_IB1_INSTR(5) & IU_AU_IB1_INSTR(22) & 
    IU_AU_IB1_INSTR(23) & IU_AU_IB1_INSTR(26) & 
    IU_AU_IB1_INSTR(27) & IU_AU_IB1_INSTR(28) & 
    IU_AU_IB1_INSTR(30) & IU_AU_IB1_INSTR(31)
     ) , STD_ULOGIC_VECTOR'("101111101011"));
MQQ92:BR_DEP_PT(92) <=
    Eq(( IU_AU_IB1_INSTR(0) & IU_AU_IB1_INSTR(1) & 
    IU_AU_IB1_INSTR(2) & IU_AU_IB1_INSTR(3) & 
    IU_AU_IB1_INSTR(4) & IU_AU_IB1_INSTR(5) & 
    IU_AU_IB1_INSTR(26) & IU_AU_IB1_INSTR(27) & 
    IU_AU_IB1_INSTR(28) & IU_AU_IB1_INSTR(29) & 
    IU_AU_IB1_INSTR(30) ) , STD_ULOGIC_VECTOR'("01111101111"));
MQQ93:BR_DEP_PT(93) <=
    Eq(( IU_AU_IB1_INSTR(0) & IU_AU_IB1_INSTR(1) & 
    IU_AU_IB1_INSTR(3) & IU_AU_IB1_INSTR(5) & 
    IU_AU_IB1_INSTR(21) & IU_AU_IB1_INSTR(22) & 
    IU_AU_IB1_INSTR(23) & IU_AU_IB1_INSTR(26) & 
    IU_AU_IB1_INSTR(27) & IU_AU_IB1_INSTR(28) & 
    IU_AU_IB1_INSTR(29) & IU_AU_IB1_INSTR(30) & 
    IU_AU_IB1_INSTR(31) ) , STD_ULOGIC_VECTOR'("0111000000111"));
MQQ94:BR_DEP_PT(94) <=
    Eq(( IU_AU_IB1_INSTR(0) & IU_AU_IB1_INSTR(1) & 
    IU_AU_IB1_INSTR(3) & IU_AU_IB1_INSTR(5) & 
    IU_AU_IB1_INSTR(22) & IU_AU_IB1_INSTR(23) & 
    IU_AU_IB1_INSTR(26) & IU_AU_IB1_INSTR(27) & 
    IU_AU_IB1_INSTR(28) & IU_AU_IB1_INSTR(29) & 
    IU_AU_IB1_INSTR(30) & IU_AU_IB1_INSTR(31)
     ) , STD_ULOGIC_VECTOR'("011111010111"));
MQQ95:BR_DEP_PT(95) <=
    Eq(( IU_AU_IB1_INSTR(0) & IU_AU_IB1_INSTR(1) & 
    IU_AU_IB1_INSTR(2) & IU_AU_IB1_INSTR(3) & 
    IU_AU_IB1_INSTR(4) & IU_AU_IB1_INSTR(5)
     ) , STD_ULOGIC_VECTOR'("010000"));
MQQ96:BR_DEP_PT(96) <=
    Eq(( IU_AU_IB1_INSTR(0) & IU_AU_IB1_INSTR(1) & 
    IU_AU_IB1_INSTR(2) & IU_AU_IB1_INSTR(3) & 
    IU_AU_IB1_INSTR(5) & IU_AU_IB1_INSTR(31)
     ) , STD_ULOGIC_VECTOR'("010001"));
MQQ97:BR_DEP_PT(97) <=
    Eq(( CORE64 & IU_AU_IB1_INSTR(0) & 
    IU_AU_IB1_INSTR(1) & IU_AU_IB1_INSTR(2) & 
    IU_AU_IB1_INSTR(3) & IU_AU_IB1_INSTR(5) & 
    IU_AU_IB1_INSTR(28) & IU_AU_IB1_INSTR(29) & 
    IU_AU_IB1_INSTR(31) ) , STD_ULOGIC_VECTOR'("101110001"));
MQQ98:BR_DEP_PT(98) <=
    Eq(( IU_AU_IB1_INSTR(0) & IU_AU_IB1_INSTR(1) & 
    IU_AU_IB1_INSTR(2) & IU_AU_IB1_INSTR(4) & 
    IU_AU_IB1_INSTR(5) ) , STD_ULOGIC_VECTOR'("00100"));
MQQ99:BR_DEP_PT(99) <=
    Eq(( IU_AU_IB1_INSTR(0) & IU_AU_IB1_INSTR(1) & 
    IU_AU_IB1_INSTR(2) & IU_AU_IB1_INSTR(3) & 
    IU_AU_IB1_INSTR(4) & IU_AU_IB1_INSTR(5) & 
    IU_AU_IB1_INSTR(30) ) , STD_ULOGIC_VECTOR'("0100011"));
MQQ100:BR_DEP_PT(100) <=
    Eq(( CORE64 & IU_AU_IB1_INSTR(0) & 
    IU_AU_IB1_INSTR(1) & IU_AU_IB1_INSTR(2) & 
    IU_AU_IB1_INSTR(3) & IU_AU_IB1_INSTR(5) & 
    IU_AU_IB1_INSTR(27) & IU_AU_IB1_INSTR(31)
     ) , STD_ULOGIC_VECTOR'("10111001"));
MQQ101:BR_DEP_PT(101) <=
    Eq(( IU_AU_IB1_INSTR(0) & IU_AU_IB1_INSTR(1) & 
    IU_AU_IB1_INSTR(2) & IU_AU_IB1_INSTR(3) & 
    IU_AU_IB1_INSTR(4) ) , STD_ULOGIC_VECTOR'("00101"));
MQQ102:BR_DEP_PT(102) <=
    Eq(( IU_AU_IB1_INSTR(0) & IU_AU_IB1_INSTR(1) & 
    IU_AU_IB1_INSTR(2) & IU_AU_IB1_INSTR(3) & 
    IU_AU_IB1_INSTR(4) & IU_AU_IB1_INSTR(5)
     ) , STD_ULOGIC_VECTOR'("001101"));
MQQ103:BR_DEP_PT(103) <=
    Eq(( IU_AU_IB1_INSTR(0) & IU_AU_IB1_INSTR(1) & 
    IU_AU_IB1_INSTR(3) & IU_AU_IB1_INSTR(4) & 
    IU_AU_IB1_INSTR(31) ) , STD_ULOGIC_VECTOR'("01101"));
MQQ104:BR_DEP_PT(104) <=
    Eq(( IU_AU_IB1_INSTR(0) & IU_AU_IB1_INSTR(1) & 
    IU_AU_IB1_INSTR(2) & IU_AU_IB1_INSTR(3) & 
    IU_AU_IB1_INSTR(5) & IU_AU_IB1_INSTR(31)
     ) , STD_ULOGIC_VECTOR'("010111"));
MQQ105:BR_DEP_PT(105) <=
    Eq(( IU_AU_IB1_INSTR(0) & IU_AU_IB1_INSTR(1) & 
    IU_AU_IB1_INSTR(2) & IU_AU_IB1_INSTR(3) & 
    IU_AU_IB1_INSTR(4) ) , STD_ULOGIC_VECTOR'("01110"));
-- Table BR_DEP Signal Assignments for Outputs
MQQ106:UPDATESLR <= 
    (BR_DEP_PT(1) OR BR_DEP_PT(7)
     OR BR_DEP_PT(9) OR BR_DEP_PT(96)
    );
MQQ107:UPDATESCR <= 
    (BR_DEP_PT(14) OR BR_DEP_PT(23)
     OR BR_DEP_PT(25) OR BR_DEP_PT(27)
     OR BR_DEP_PT(28) OR BR_DEP_PT(29)
     OR BR_DEP_PT(32) OR BR_DEP_PT(35)
     OR BR_DEP_PT(36) OR BR_DEP_PT(38)
     OR BR_DEP_PT(39) OR BR_DEP_PT(48)
     OR BR_DEP_PT(51) OR BR_DEP_PT(56)
     OR BR_DEP_PT(59) OR BR_DEP_PT(60)
     OR BR_DEP_PT(62) OR BR_DEP_PT(63)
     OR BR_DEP_PT(65) OR BR_DEP_PT(66)
     OR BR_DEP_PT(67) OR BR_DEP_PT(68)
     OR BR_DEP_PT(70) OR BR_DEP_PT(71)
     OR BR_DEP_PT(72) OR BR_DEP_PT(73)
     OR BR_DEP_PT(74) OR BR_DEP_PT(75)
     OR BR_DEP_PT(76) OR BR_DEP_PT(77)
     OR BR_DEP_PT(78) OR BR_DEP_PT(79)
     OR BR_DEP_PT(80) OR BR_DEP_PT(82)
     OR BR_DEP_PT(83) OR BR_DEP_PT(84)
     OR BR_DEP_PT(87) OR BR_DEP_PT(88)
     OR BR_DEP_PT(90) OR BR_DEP_PT(91)
     OR BR_DEP_PT(93) OR BR_DEP_PT(94)
     OR BR_DEP_PT(97) OR BR_DEP_PT(100)
     OR BR_DEP_PT(101) OR BR_DEP_PT(102)
     OR BR_DEP_PT(103) OR BR_DEP_PT(104)
     OR BR_DEP_PT(105));
MQQ108:UPDATESCTR <= 
    (BR_DEP_PT(2) OR BR_DEP_PT(10)
     OR BR_DEP_PT(89));
MQQ109:UPDATESXER <= 
    (BR_DEP_PT(5) OR BR_DEP_PT(24)
     OR BR_DEP_PT(26) OR BR_DEP_PT(31)
     OR BR_DEP_PT(37) OR BR_DEP_PT(50)
     OR BR_DEP_PT(53) OR BR_DEP_PT(55)
     OR BR_DEP_PT(60) OR BR_DEP_PT(61)
     OR BR_DEP_PT(69) OR BR_DEP_PT(81)
     OR BR_DEP_PT(86) OR BR_DEP_PT(98)
     OR BR_DEP_PT(102));
MQQ110:UPDATESMSR <= 
    (BR_DEP_PT(11) OR BR_DEP_PT(30)
     OR BR_DEP_PT(54) OR BR_DEP_PT(64)
     OR BR_DEP_PT(99));
MQQ111:UPDATESSPR <= 
    (BR_DEP_PT(15) OR BR_DEP_PT(16)
     OR BR_DEP_PT(17) OR BR_DEP_PT(18)
     OR BR_DEP_PT(19) OR BR_DEP_PT(20)
     OR BR_DEP_PT(21) OR BR_DEP_PT(22)
     OR BR_DEP_PT(27) OR BR_DEP_PT(99)
    );
MQQ112:USESLR <= 
    (BR_DEP_PT(3) OR BR_DEP_PT(12)
    );
MQQ113:USESCR <= 
    (BR_DEP_PT(8) OR BR_DEP_PT(12)
     OR BR_DEP_PT(23) OR BR_DEP_PT(28)
     OR BR_DEP_PT(29) OR BR_DEP_PT(32)
     OR BR_DEP_PT(36) OR BR_DEP_PT(38)
     OR BR_DEP_PT(39) OR BR_DEP_PT(57)
     OR BR_DEP_PT(92) OR BR_DEP_PT(95)
    );
MQQ114:USESCTR <= 
    (BR_DEP_PT(4) OR BR_DEP_PT(8)
     OR BR_DEP_PT(10) OR BR_DEP_PT(89)
    );
MQQ115:USESXER <= 
    (BR_DEP_PT(6) OR BR_DEP_PT(14)
     OR BR_DEP_PT(25) OR BR_DEP_PT(27)
     OR BR_DEP_PT(35) OR BR_DEP_PT(48)
     OR BR_DEP_PT(51) OR BR_DEP_PT(56)
     OR BR_DEP_PT(58) OR BR_DEP_PT(59)
     OR BR_DEP_PT(60) OR BR_DEP_PT(62)
     OR BR_DEP_PT(65) OR BR_DEP_PT(67)
     OR BR_DEP_PT(72) OR BR_DEP_PT(73)
     OR BR_DEP_PT(74) OR BR_DEP_PT(76)
     OR BR_DEP_PT(77) OR BR_DEP_PT(78)
     OR BR_DEP_PT(79) OR BR_DEP_PT(80)
     OR BR_DEP_PT(82) OR BR_DEP_PT(83)
     OR BR_DEP_PT(84) OR BR_DEP_PT(85)
     OR BR_DEP_PT(86) OR BR_DEP_PT(87)
     OR BR_DEP_PT(88) OR BR_DEP_PT(90)
     OR BR_DEP_PT(91) OR BR_DEP_PT(93)
     OR BR_DEP_PT(94) OR BR_DEP_PT(97)
     OR BR_DEP_PT(100) OR BR_DEP_PT(101)
     OR BR_DEP_PT(102) OR BR_DEP_PT(103)
     OR BR_DEP_PT(104) OR BR_DEP_PT(105)
    );
MQQ116:USESMSR <= 
    (BR_DEP_PT(13) OR BR_DEP_PT(33)
     OR BR_DEP_PT(52) OR BR_DEP_PT(99)
    );
MQQ117:USESSPR <= 
    (BR_DEP_PT(11) OR BR_DEP_PT(13)
     OR BR_DEP_PT(30) OR BR_DEP_PT(33)
     OR BR_DEP_PT(34) OR BR_DEP_PT(40)
     OR BR_DEP_PT(41) OR BR_DEP_PT(42)
     OR BR_DEP_PT(43) OR BR_DEP_PT(44)
     OR BR_DEP_PT(45) OR BR_DEP_PT(46)
     OR BR_DEP_PT(47) OR BR_DEP_PT(49)
    );

--
-- Final Table Listing
--      *INPUTS*====================================*OUTPUTS*================================*
--      |                                           |                                        |
--      | core64                                    |                                        |
--      | |                                         |                                        |
--      | | iu_au_ib1_instr                         | ta_vld  s1_vld  s2_vld  s3_vld  ld_vld |
--      | | |      iu_au_ib1_instr                  | |       |       |       |       |      |
--      | | |      |     iu_au_ib1_instr            | |       |       |       |       |      |
--      | | |      |     |          iu_au_ib1_instr | |       |       |       |       |      |
--      | | |      |     |          |               | |       |       |       |       |      |
--      | | |      |     |          |               | |       |       |       |       |      |
--      | | |      |     |          |               | |       |       |       |       |      |
--      | | |      |     |          |               | |       |       |       |       |      |
--      | | |      |     |          |               | |       |       |       |       |      |
--      | | |      |     |          |               | |       |       |       |       |      |
--      | | |      |     |          |               | |       |       |       |       |      |
--      | | |      |     |          |               | |       |       |       |       |      |
--      | | |      |     |          |               | |       |       |       |       |      |
--      | | |      |     |          |               | |       |       |       |       |      |
--      | | |      |   1 1111111112 22222222233     | |       |       |       |       |      |
--      | | 012345 67890 1234567890 12345678901     | |       |       |       |       |      |
--      *TYPE*======================================+========================================+
--      | P PPPPPP PPPPP PPPPPPPPPP PPPPPPPPPPP     | S       S       S       S       S      |
--      *POLARITY*--------------------------------->| +       +       +       +       +      |
--      *PHASE*------------------------------------>| C       C       T       T       T      |
--      *TERMS*=====================================+========================================+
--    1 | - -1-000 00000 0000000000 00000000000     | 1       1       .       .       .      |
--    2 | - -11111 ----- ---------- 001101--1--     | 1       .       1       1       .      |
--    3 | - -1-111 ----- ---------- -1-00-00---     | .       .       1       .       .      |
--    4 | - -11111 ----- ---------- --0-0100-1-     | .       1       .       .       .      |
--    5 | - -11111 ----- ---------- 1-0001-1---     | .       .       1       .       1      |
--    6 | - -11111 ----- ---------- --1001-1-1-     | 1       .       .       1       .      |
--    7 | - -11111 ----- ---------- 0----10100-     | .       .       1       .       1      |
--    8 | - -11111 ----- ---------- -1-100---0-     | .       1       .       .       .      |
--    9 | - -11111 ----- ---------- -00-11-0-1-     | 1       .       1       .       .      |
--   10 | - -11111 ----- ---------- --0-01-1-1-     | .       .       .       .       1      |
--   11 | - -11111 ----- ---------- --0-100-1--     | .       1       .       .       .      |
--   12 | - -11111 ----- ---------- 0----10110-     | 1       .       1       .       .      |
--   13 | - -1-111 ----- ---------- 1101---0---     | .       .       1       .       .      |
--   14 | - -11111 ----- ---------- -01-1-00---     | .       1       .       .       .      |
--   15 | - -11111 ----- ---------- 010---00---     | .       1       .       .       .      |
--   16 | - -11111 ----- ---------- 1---1-00-0-     | .       1       .       .       .      |
--   17 | - -11111 ----- ---------- --11--00-0-     | .       1       .       .       .      |
--   18 | - -11111 ----- ---------- -1-0-100-1-     | 1       .       1       1       .      |
--   19 | - -11111 ----- ---------- --10-101-0-     | 1       .       1       1       .      |
--   20 | - -11111 ----- ---------- --11--0-01-     | 1       .       .       1       .      |
--   21 | - -11111 ----- ---------- 1-01---1-0-     | 1       1       .       .       .      |
--   22 | - -1-111 ----- ---------- 0-0---0--0-     | .       .       1       .       .      |
--   23 | - -11111 ----- ---------- -0-1-000---     | 1       .       .       1       .      |
--   24 | - -11111 ----- ---------- 1-0-11-1---     | 1       1       .       .       .      |
--   25 | - -11111 ----- ---------- 0-0---01-1-     | .       .       1       .       1      |
--   26 | - -11111 ----- ---------- --1-110--1-     | .       .       1       1       .      |
--   27 | - -11111 ----- ---------- 1-1--1-11--     | 1       .       1       .       .      |
--   28 | - 01111- ----- ---------- ------1110-     | 1       1       .       .       .      |
--   29 | - 01-11- ----- ---------- 0----11-0--     | .       .       1       .       .      |
--   30 | - 01-11- ----- ---------- 1-0-0-1----     | .       .       1       .       .      |
--   31 | - 01-11- ----- ---------- ---0-010---     | .       .       1       .       .      |
--   32 | - -11111 ----- ---------- 1---000----     | .       1       .       .       .      |
--   33 | - -11111 ----- ---------- 10----00---     | .       1       .       .       .      |
--   34 | - -1111- ----- ---------- ----1111-1-     | 1       .       1       .       .      |
--   35 | - -11111 ----- ---------- --11--00---     | 1       .       .       .       .      |
--   36 | - -1-111 ----- ---------- ----10-1---     | .       .       1       .       .      |
--   37 | - -1-111 ----- ---------- --10-1---1-     | .       .       1       .       .      |
--   38 | - -1-111 ----- ---------- 01-0--0----     | .       .       1       .       .      |
--   39 | - -11111 ----- ---------- -0---0-1-0-     | 1       .       1       .       .      |
--   40 | - 01-110 ----- ---------- -------11--     | .       .       1       .       .      |
--   41 | - 101-10 ----- ---------- -----------     | .       .       .       .       1      |
--   42 | - 000-0- ----- ---------- -----------     | 1       1       .       .       .      |
--   43 | - -11111 ----- ---------- --1--00----     | 1       .       .       .       .      |
--   44 | - -11111 ----- ---------- ------00-0-     | 1       .       .       .       .      |
--   45 | - 01-110 ----- ---------- ------1----     | .       .       1       .       .      |
--   46 | - 00-01- ----- ---------- -----------     | 1       .       .       .       .      |
--   47 | - -1-11- ----- ---------- -----01--1-     | .       .       1       .       .      |
--   48 | - -1-11- ----- ---------- ----0-1--1-     | .       .       1       .       .      |
--   49 | - 0-01-0 ----- ---------- -----------     | .       .       1       .       .      |
--   50 | - 1--100 ----- ---------- -----------     | 1       .       .       1       .      |
--   51 | - 1-01-0 ----- ---------- -----------     | 1       .       .       1       .      |
--   52 | - 1--0-- ----- ---------- -----------     | .       .       .       .       1      |
--   53 | - 11-1-- ----- ---------- ----------0     | 1       .       .       .       .      |
--   54 | - 1-1111 ----- ---------- -----------     | 1       .       .       .       .      |
--   55 | - -100-- ----- ---------- -----------     | 1       1       .       .       .      |
--   56 | - 1--1-1 ----- ---------- -----------     | .       .       .       1       .      |
--   57 | - 11-1-- ----- ---------- -----------     | .       .       .       1       .      |
--   58 | - -1011- ----- ---------- -----------     | .       .       1       .       .      |
--      *====================================================================================*
--
-- Table INSTRUCTION_DECODER Signal Assignments for Product Terms
MQQ118:INSTRUCTION_DECODER_PT(1) <=
    Eq(( IU_AU_IB1_INSTR(1) & IU_AU_IB1_INSTR(3) & 
    IU_AU_IB1_INSTR(4) & IU_AU_IB1_INSTR(5) & 
    IU_AU_IB1_INSTR(6) & IU_AU_IB1_INSTR(7) & 
    IU_AU_IB1_INSTR(8) & IU_AU_IB1_INSTR(9) & 
    IU_AU_IB1_INSTR(10) & IU_AU_IB1_INSTR(11) & 
    IU_AU_IB1_INSTR(12) & IU_AU_IB1_INSTR(13) & 
    IU_AU_IB1_INSTR(14) & IU_AU_IB1_INSTR(15) & 
    IU_AU_IB1_INSTR(16) & IU_AU_IB1_INSTR(17) & 
    IU_AU_IB1_INSTR(18) & IU_AU_IB1_INSTR(19) & 
    IU_AU_IB1_INSTR(20) & IU_AU_IB1_INSTR(21) & 
    IU_AU_IB1_INSTR(22) & IU_AU_IB1_INSTR(23) & 
    IU_AU_IB1_INSTR(24) & IU_AU_IB1_INSTR(25) & 
    IU_AU_IB1_INSTR(26) & IU_AU_IB1_INSTR(27) & 
    IU_AU_IB1_INSTR(28) & IU_AU_IB1_INSTR(29) & 
    IU_AU_IB1_INSTR(30) & IU_AU_IB1_INSTR(31)
     ) , STD_ULOGIC_VECTOR'("100000000000000000000000000000"));
MQQ119:INSTRUCTION_DECODER_PT(2) <=
    Eq(( IU_AU_IB1_INSTR(1) & IU_AU_IB1_INSTR(2) & 
    IU_AU_IB1_INSTR(3) & IU_AU_IB1_INSTR(4) & 
    IU_AU_IB1_INSTR(5) & IU_AU_IB1_INSTR(21) & 
    IU_AU_IB1_INSTR(22) & IU_AU_IB1_INSTR(23) & 
    IU_AU_IB1_INSTR(24) & IU_AU_IB1_INSTR(25) & 
    IU_AU_IB1_INSTR(26) & IU_AU_IB1_INSTR(29)
     ) , STD_ULOGIC_VECTOR'("111110011011"));
MQQ120:INSTRUCTION_DECODER_PT(3) <=
    Eq(( IU_AU_IB1_INSTR(1) & IU_AU_IB1_INSTR(3) & 
    IU_AU_IB1_INSTR(4) & IU_AU_IB1_INSTR(5) & 
    IU_AU_IB1_INSTR(22) & IU_AU_IB1_INSTR(24) & 
    IU_AU_IB1_INSTR(25) & IU_AU_IB1_INSTR(27) & 
    IU_AU_IB1_INSTR(28) ) , STD_ULOGIC_VECTOR'("111110000"));
MQQ121:INSTRUCTION_DECODER_PT(4) <=
    Eq(( IU_AU_IB1_INSTR(1) & IU_AU_IB1_INSTR(2) & 
    IU_AU_IB1_INSTR(3) & IU_AU_IB1_INSTR(4) & 
    IU_AU_IB1_INSTR(5) & IU_AU_IB1_INSTR(23) & 
    IU_AU_IB1_INSTR(25) & IU_AU_IB1_INSTR(26) & 
    IU_AU_IB1_INSTR(27) & IU_AU_IB1_INSTR(28) & 
    IU_AU_IB1_INSTR(30) ) , STD_ULOGIC_VECTOR'("11111001001"));
MQQ122:INSTRUCTION_DECODER_PT(5) <=
    Eq(( IU_AU_IB1_INSTR(1) & IU_AU_IB1_INSTR(2) & 
    IU_AU_IB1_INSTR(3) & IU_AU_IB1_INSTR(4) & 
    IU_AU_IB1_INSTR(5) & IU_AU_IB1_INSTR(21) & 
    IU_AU_IB1_INSTR(23) & IU_AU_IB1_INSTR(24) & 
    IU_AU_IB1_INSTR(25) & IU_AU_IB1_INSTR(26) & 
    IU_AU_IB1_INSTR(28) ) , STD_ULOGIC_VECTOR'("11111100011"));
MQQ123:INSTRUCTION_DECODER_PT(6) <=
    Eq(( IU_AU_IB1_INSTR(1) & IU_AU_IB1_INSTR(2) & 
    IU_AU_IB1_INSTR(3) & IU_AU_IB1_INSTR(4) & 
    IU_AU_IB1_INSTR(5) & IU_AU_IB1_INSTR(23) & 
    IU_AU_IB1_INSTR(24) & IU_AU_IB1_INSTR(25) & 
    IU_AU_IB1_INSTR(26) & IU_AU_IB1_INSTR(28) & 
    IU_AU_IB1_INSTR(30) ) , STD_ULOGIC_VECTOR'("11111100111"));
MQQ124:INSTRUCTION_DECODER_PT(7) <=
    Eq(( IU_AU_IB1_INSTR(1) & IU_AU_IB1_INSTR(2) & 
    IU_AU_IB1_INSTR(3) & IU_AU_IB1_INSTR(4) & 
    IU_AU_IB1_INSTR(5) & IU_AU_IB1_INSTR(21) & 
    IU_AU_IB1_INSTR(26) & IU_AU_IB1_INSTR(27) & 
    IU_AU_IB1_INSTR(28) & IU_AU_IB1_INSTR(29) & 
    IU_AU_IB1_INSTR(30) ) , STD_ULOGIC_VECTOR'("11111010100"));
MQQ125:INSTRUCTION_DECODER_PT(8) <=
    Eq(( IU_AU_IB1_INSTR(1) & IU_AU_IB1_INSTR(2) & 
    IU_AU_IB1_INSTR(3) & IU_AU_IB1_INSTR(4) & 
    IU_AU_IB1_INSTR(5) & IU_AU_IB1_INSTR(22) & 
    IU_AU_IB1_INSTR(24) & IU_AU_IB1_INSTR(25) & 
    IU_AU_IB1_INSTR(26) & IU_AU_IB1_INSTR(30)
     ) , STD_ULOGIC_VECTOR'("1111111000"));
MQQ126:INSTRUCTION_DECODER_PT(9) <=
    Eq(( IU_AU_IB1_INSTR(1) & IU_AU_IB1_INSTR(2) & 
    IU_AU_IB1_INSTR(3) & IU_AU_IB1_INSTR(4) & 
    IU_AU_IB1_INSTR(5) & IU_AU_IB1_INSTR(22) & 
    IU_AU_IB1_INSTR(23) & IU_AU_IB1_INSTR(25) & 
    IU_AU_IB1_INSTR(26) & IU_AU_IB1_INSTR(28) & 
    IU_AU_IB1_INSTR(30) ) , STD_ULOGIC_VECTOR'("11111001101"));
MQQ127:INSTRUCTION_DECODER_PT(10) <=
    Eq(( IU_AU_IB1_INSTR(1) & IU_AU_IB1_INSTR(2) & 
    IU_AU_IB1_INSTR(3) & IU_AU_IB1_INSTR(4) & 
    IU_AU_IB1_INSTR(5) & IU_AU_IB1_INSTR(23) & 
    IU_AU_IB1_INSTR(25) & IU_AU_IB1_INSTR(26) & 
    IU_AU_IB1_INSTR(28) & IU_AU_IB1_INSTR(30)
     ) , STD_ULOGIC_VECTOR'("1111100111"));
MQQ128:INSTRUCTION_DECODER_PT(11) <=
    Eq(( IU_AU_IB1_INSTR(1) & IU_AU_IB1_INSTR(2) & 
    IU_AU_IB1_INSTR(3) & IU_AU_IB1_INSTR(4) & 
    IU_AU_IB1_INSTR(5) & IU_AU_IB1_INSTR(23) & 
    IU_AU_IB1_INSTR(25) & IU_AU_IB1_INSTR(26) & 
    IU_AU_IB1_INSTR(27) & IU_AU_IB1_INSTR(29)
     ) , STD_ULOGIC_VECTOR'("1111101001"));
MQQ129:INSTRUCTION_DECODER_PT(12) <=
    Eq(( IU_AU_IB1_INSTR(1) & IU_AU_IB1_INSTR(2) & 
    IU_AU_IB1_INSTR(3) & IU_AU_IB1_INSTR(4) & 
    IU_AU_IB1_INSTR(5) & IU_AU_IB1_INSTR(21) & 
    IU_AU_IB1_INSTR(26) & IU_AU_IB1_INSTR(27) & 
    IU_AU_IB1_INSTR(28) & IU_AU_IB1_INSTR(29) & 
    IU_AU_IB1_INSTR(30) ) , STD_ULOGIC_VECTOR'("11111010110"));
MQQ130:INSTRUCTION_DECODER_PT(13) <=
    Eq(( IU_AU_IB1_INSTR(1) & IU_AU_IB1_INSTR(3) & 
    IU_AU_IB1_INSTR(4) & IU_AU_IB1_INSTR(5) & 
    IU_AU_IB1_INSTR(21) & IU_AU_IB1_INSTR(22) & 
    IU_AU_IB1_INSTR(23) & IU_AU_IB1_INSTR(24) & 
    IU_AU_IB1_INSTR(28) ) , STD_ULOGIC_VECTOR'("111111010"));
MQQ131:INSTRUCTION_DECODER_PT(14) <=
    Eq(( IU_AU_IB1_INSTR(1) & IU_AU_IB1_INSTR(2) & 
    IU_AU_IB1_INSTR(3) & IU_AU_IB1_INSTR(4) & 
    IU_AU_IB1_INSTR(5) & IU_AU_IB1_INSTR(22) & 
    IU_AU_IB1_INSTR(23) & IU_AU_IB1_INSTR(25) & 
    IU_AU_IB1_INSTR(27) & IU_AU_IB1_INSTR(28)
     ) , STD_ULOGIC_VECTOR'("1111101100"));
MQQ132:INSTRUCTION_DECODER_PT(15) <=
    Eq(( IU_AU_IB1_INSTR(1) & IU_AU_IB1_INSTR(2) & 
    IU_AU_IB1_INSTR(3) & IU_AU_IB1_INSTR(4) & 
    IU_AU_IB1_INSTR(5) & IU_AU_IB1_INSTR(21) & 
    IU_AU_IB1_INSTR(22) & IU_AU_IB1_INSTR(23) & 
    IU_AU_IB1_INSTR(27) & IU_AU_IB1_INSTR(28)
     ) , STD_ULOGIC_VECTOR'("1111101000"));
MQQ133:INSTRUCTION_DECODER_PT(16) <=
    Eq(( IU_AU_IB1_INSTR(1) & IU_AU_IB1_INSTR(2) & 
    IU_AU_IB1_INSTR(3) & IU_AU_IB1_INSTR(4) & 
    IU_AU_IB1_INSTR(5) & IU_AU_IB1_INSTR(21) & 
    IU_AU_IB1_INSTR(25) & IU_AU_IB1_INSTR(27) & 
    IU_AU_IB1_INSTR(28) & IU_AU_IB1_INSTR(30)
     ) , STD_ULOGIC_VECTOR'("1111111000"));
MQQ134:INSTRUCTION_DECODER_PT(17) <=
    Eq(( IU_AU_IB1_INSTR(1) & IU_AU_IB1_INSTR(2) & 
    IU_AU_IB1_INSTR(3) & IU_AU_IB1_INSTR(4) & 
    IU_AU_IB1_INSTR(5) & IU_AU_IB1_INSTR(23) & 
    IU_AU_IB1_INSTR(24) & IU_AU_IB1_INSTR(27) & 
    IU_AU_IB1_INSTR(28) & IU_AU_IB1_INSTR(30)
     ) , STD_ULOGIC_VECTOR'("1111111000"));
MQQ135:INSTRUCTION_DECODER_PT(18) <=
    Eq(( IU_AU_IB1_INSTR(1) & IU_AU_IB1_INSTR(2) & 
    IU_AU_IB1_INSTR(3) & IU_AU_IB1_INSTR(4) & 
    IU_AU_IB1_INSTR(5) & IU_AU_IB1_INSTR(22) & 
    IU_AU_IB1_INSTR(24) & IU_AU_IB1_INSTR(26) & 
    IU_AU_IB1_INSTR(27) & IU_AU_IB1_INSTR(28) & 
    IU_AU_IB1_INSTR(30) ) , STD_ULOGIC_VECTOR'("11111101001"));
MQQ136:INSTRUCTION_DECODER_PT(19) <=
    Eq(( IU_AU_IB1_INSTR(1) & IU_AU_IB1_INSTR(2) & 
    IU_AU_IB1_INSTR(3) & IU_AU_IB1_INSTR(4) & 
    IU_AU_IB1_INSTR(5) & IU_AU_IB1_INSTR(23) & 
    IU_AU_IB1_INSTR(24) & IU_AU_IB1_INSTR(26) & 
    IU_AU_IB1_INSTR(27) & IU_AU_IB1_INSTR(28) & 
    IU_AU_IB1_INSTR(30) ) , STD_ULOGIC_VECTOR'("11111101010"));
MQQ137:INSTRUCTION_DECODER_PT(20) <=
    Eq(( IU_AU_IB1_INSTR(1) & IU_AU_IB1_INSTR(2) & 
    IU_AU_IB1_INSTR(3) & IU_AU_IB1_INSTR(4) & 
    IU_AU_IB1_INSTR(5) & IU_AU_IB1_INSTR(23) & 
    IU_AU_IB1_INSTR(24) & IU_AU_IB1_INSTR(27) & 
    IU_AU_IB1_INSTR(29) & IU_AU_IB1_INSTR(30)
     ) , STD_ULOGIC_VECTOR'("1111111001"));
MQQ138:INSTRUCTION_DECODER_PT(21) <=
    Eq(( IU_AU_IB1_INSTR(1) & IU_AU_IB1_INSTR(2) & 
    IU_AU_IB1_INSTR(3) & IU_AU_IB1_INSTR(4) & 
    IU_AU_IB1_INSTR(5) & IU_AU_IB1_INSTR(21) & 
    IU_AU_IB1_INSTR(23) & IU_AU_IB1_INSTR(24) & 
    IU_AU_IB1_INSTR(28) & IU_AU_IB1_INSTR(30)
     ) , STD_ULOGIC_VECTOR'("1111110110"));
MQQ139:INSTRUCTION_DECODER_PT(22) <=
    Eq(( IU_AU_IB1_INSTR(1) & IU_AU_IB1_INSTR(3) & 
    IU_AU_IB1_INSTR(4) & IU_AU_IB1_INSTR(5) & 
    IU_AU_IB1_INSTR(21) & IU_AU_IB1_INSTR(23) & 
    IU_AU_IB1_INSTR(27) & IU_AU_IB1_INSTR(30)
     ) , STD_ULOGIC_VECTOR'("11110000"));
MQQ140:INSTRUCTION_DECODER_PT(23) <=
    Eq(( IU_AU_IB1_INSTR(1) & IU_AU_IB1_INSTR(2) & 
    IU_AU_IB1_INSTR(3) & IU_AU_IB1_INSTR(4) & 
    IU_AU_IB1_INSTR(5) & IU_AU_IB1_INSTR(22) & 
    IU_AU_IB1_INSTR(24) & IU_AU_IB1_INSTR(26) & 
    IU_AU_IB1_INSTR(27) & IU_AU_IB1_INSTR(28)
     ) , STD_ULOGIC_VECTOR'("1111101000"));
MQQ141:INSTRUCTION_DECODER_PT(24) <=
    Eq(( IU_AU_IB1_INSTR(1) & IU_AU_IB1_INSTR(2) & 
    IU_AU_IB1_INSTR(3) & IU_AU_IB1_INSTR(4) & 
    IU_AU_IB1_INSTR(5) & IU_AU_IB1_INSTR(21) & 
    IU_AU_IB1_INSTR(23) & IU_AU_IB1_INSTR(25) & 
    IU_AU_IB1_INSTR(26) & IU_AU_IB1_INSTR(28)
     ) , STD_ULOGIC_VECTOR'("1111110111"));
MQQ142:INSTRUCTION_DECODER_PT(25) <=
    Eq(( IU_AU_IB1_INSTR(1) & IU_AU_IB1_INSTR(2) & 
    IU_AU_IB1_INSTR(3) & IU_AU_IB1_INSTR(4) & 
    IU_AU_IB1_INSTR(5) & IU_AU_IB1_INSTR(21) & 
    IU_AU_IB1_INSTR(23) & IU_AU_IB1_INSTR(27) & 
    IU_AU_IB1_INSTR(28) & IU_AU_IB1_INSTR(30)
     ) , STD_ULOGIC_VECTOR'("1111100011"));
MQQ143:INSTRUCTION_DECODER_PT(26) <=
    Eq(( IU_AU_IB1_INSTR(1) & IU_AU_IB1_INSTR(2) & 
    IU_AU_IB1_INSTR(3) & IU_AU_IB1_INSTR(4) & 
    IU_AU_IB1_INSTR(5) & IU_AU_IB1_INSTR(23) & 
    IU_AU_IB1_INSTR(25) & IU_AU_IB1_INSTR(26) & 
    IU_AU_IB1_INSTR(27) & IU_AU_IB1_INSTR(30)
     ) , STD_ULOGIC_VECTOR'("1111111101"));
MQQ144:INSTRUCTION_DECODER_PT(27) <=
    Eq(( IU_AU_IB1_INSTR(1) & IU_AU_IB1_INSTR(2) & 
    IU_AU_IB1_INSTR(3) & IU_AU_IB1_INSTR(4) & 
    IU_AU_IB1_INSTR(5) & IU_AU_IB1_INSTR(21) & 
    IU_AU_IB1_INSTR(23) & IU_AU_IB1_INSTR(26) & 
    IU_AU_IB1_INSTR(28) & IU_AU_IB1_INSTR(29)
     ) , STD_ULOGIC_VECTOR'("1111111111"));
MQQ145:INSTRUCTION_DECODER_PT(28) <=
    Eq(( IU_AU_IB1_INSTR(0) & IU_AU_IB1_INSTR(1) & 
    IU_AU_IB1_INSTR(2) & IU_AU_IB1_INSTR(3) & 
    IU_AU_IB1_INSTR(4) & IU_AU_IB1_INSTR(27) & 
    IU_AU_IB1_INSTR(28) & IU_AU_IB1_INSTR(29) & 
    IU_AU_IB1_INSTR(30) ) , STD_ULOGIC_VECTOR'("011111110"));
MQQ146:INSTRUCTION_DECODER_PT(29) <=
    Eq(( IU_AU_IB1_INSTR(0) & IU_AU_IB1_INSTR(1) & 
    IU_AU_IB1_INSTR(3) & IU_AU_IB1_INSTR(4) & 
    IU_AU_IB1_INSTR(21) & IU_AU_IB1_INSTR(26) & 
    IU_AU_IB1_INSTR(27) & IU_AU_IB1_INSTR(29)
     ) , STD_ULOGIC_VECTOR'("01110110"));
MQQ147:INSTRUCTION_DECODER_PT(30) <=
    Eq(( IU_AU_IB1_INSTR(0) & IU_AU_IB1_INSTR(1) & 
    IU_AU_IB1_INSTR(3) & IU_AU_IB1_INSTR(4) & 
    IU_AU_IB1_INSTR(21) & IU_AU_IB1_INSTR(23) & 
    IU_AU_IB1_INSTR(25) & IU_AU_IB1_INSTR(27)
     ) , STD_ULOGIC_VECTOR'("01111001"));
MQQ148:INSTRUCTION_DECODER_PT(31) <=
    Eq(( IU_AU_IB1_INSTR(0) & IU_AU_IB1_INSTR(1) & 
    IU_AU_IB1_INSTR(3) & IU_AU_IB1_INSTR(4) & 
    IU_AU_IB1_INSTR(24) & IU_AU_IB1_INSTR(26) & 
    IU_AU_IB1_INSTR(27) & IU_AU_IB1_INSTR(28)
     ) , STD_ULOGIC_VECTOR'("01110010"));
MQQ149:INSTRUCTION_DECODER_PT(32) <=
    Eq(( IU_AU_IB1_INSTR(1) & IU_AU_IB1_INSTR(2) & 
    IU_AU_IB1_INSTR(3) & IU_AU_IB1_INSTR(4) & 
    IU_AU_IB1_INSTR(5) & IU_AU_IB1_INSTR(21) & 
    IU_AU_IB1_INSTR(25) & IU_AU_IB1_INSTR(26) & 
    IU_AU_IB1_INSTR(27) ) , STD_ULOGIC_VECTOR'("111111000"));
MQQ150:INSTRUCTION_DECODER_PT(33) <=
    Eq(( IU_AU_IB1_INSTR(1) & IU_AU_IB1_INSTR(2) & 
    IU_AU_IB1_INSTR(3) & IU_AU_IB1_INSTR(4) & 
    IU_AU_IB1_INSTR(5) & IU_AU_IB1_INSTR(21) & 
    IU_AU_IB1_INSTR(22) & IU_AU_IB1_INSTR(27) & 
    IU_AU_IB1_INSTR(28) ) , STD_ULOGIC_VECTOR'("111111000"));
MQQ151:INSTRUCTION_DECODER_PT(34) <=
    Eq(( IU_AU_IB1_INSTR(1) & IU_AU_IB1_INSTR(2) & 
    IU_AU_IB1_INSTR(3) & IU_AU_IB1_INSTR(4) & 
    IU_AU_IB1_INSTR(25) & IU_AU_IB1_INSTR(26) & 
    IU_AU_IB1_INSTR(27) & IU_AU_IB1_INSTR(28) & 
    IU_AU_IB1_INSTR(30) ) , STD_ULOGIC_VECTOR'("111111111"));
MQQ152:INSTRUCTION_DECODER_PT(35) <=
    Eq(( IU_AU_IB1_INSTR(1) & IU_AU_IB1_INSTR(2) & 
    IU_AU_IB1_INSTR(3) & IU_AU_IB1_INSTR(4) & 
    IU_AU_IB1_INSTR(5) & IU_AU_IB1_INSTR(23) & 
    IU_AU_IB1_INSTR(24) & IU_AU_IB1_INSTR(27) & 
    IU_AU_IB1_INSTR(28) ) , STD_ULOGIC_VECTOR'("111111100"));
MQQ153:INSTRUCTION_DECODER_PT(36) <=
    Eq(( IU_AU_IB1_INSTR(1) & IU_AU_IB1_INSTR(3) & 
    IU_AU_IB1_INSTR(4) & IU_AU_IB1_INSTR(5) & 
    IU_AU_IB1_INSTR(25) & IU_AU_IB1_INSTR(26) & 
    IU_AU_IB1_INSTR(28) ) , STD_ULOGIC_VECTOR'("1111101"));
MQQ154:INSTRUCTION_DECODER_PT(37) <=
    Eq(( IU_AU_IB1_INSTR(1) & IU_AU_IB1_INSTR(3) & 
    IU_AU_IB1_INSTR(4) & IU_AU_IB1_INSTR(5) & 
    IU_AU_IB1_INSTR(23) & IU_AU_IB1_INSTR(24) & 
    IU_AU_IB1_INSTR(26) & IU_AU_IB1_INSTR(30)
     ) , STD_ULOGIC_VECTOR'("11111011"));
MQQ155:INSTRUCTION_DECODER_PT(38) <=
    Eq(( IU_AU_IB1_INSTR(1) & IU_AU_IB1_INSTR(3) & 
    IU_AU_IB1_INSTR(4) & IU_AU_IB1_INSTR(5) & 
    IU_AU_IB1_INSTR(21) & IU_AU_IB1_INSTR(22) & 
    IU_AU_IB1_INSTR(24) & IU_AU_IB1_INSTR(27)
     ) , STD_ULOGIC_VECTOR'("11110100"));
MQQ156:INSTRUCTION_DECODER_PT(39) <=
    Eq(( IU_AU_IB1_INSTR(1) & IU_AU_IB1_INSTR(2) & 
    IU_AU_IB1_INSTR(3) & IU_AU_IB1_INSTR(4) & 
    IU_AU_IB1_INSTR(5) & IU_AU_IB1_INSTR(22) & 
    IU_AU_IB1_INSTR(26) & IU_AU_IB1_INSTR(28) & 
    IU_AU_IB1_INSTR(30) ) , STD_ULOGIC_VECTOR'("111110010"));
MQQ157:INSTRUCTION_DECODER_PT(40) <=
    Eq(( IU_AU_IB1_INSTR(0) & IU_AU_IB1_INSTR(1) & 
    IU_AU_IB1_INSTR(3) & IU_AU_IB1_INSTR(4) & 
    IU_AU_IB1_INSTR(5) & IU_AU_IB1_INSTR(28) & 
    IU_AU_IB1_INSTR(29) ) , STD_ULOGIC_VECTOR'("0111011"));
MQQ158:INSTRUCTION_DECODER_PT(41) <=
    Eq(( IU_AU_IB1_INSTR(0) & IU_AU_IB1_INSTR(1) & 
    IU_AU_IB1_INSTR(2) & IU_AU_IB1_INSTR(4) & 
    IU_AU_IB1_INSTR(5) ) , STD_ULOGIC_VECTOR'("10110"));
MQQ159:INSTRUCTION_DECODER_PT(42) <=
    Eq(( IU_AU_IB1_INSTR(0) & IU_AU_IB1_INSTR(1) & 
    IU_AU_IB1_INSTR(2) & IU_AU_IB1_INSTR(4)
     ) , STD_ULOGIC_VECTOR'("0000"));
MQQ160:INSTRUCTION_DECODER_PT(43) <=
    Eq(( IU_AU_IB1_INSTR(1) & IU_AU_IB1_INSTR(2) & 
    IU_AU_IB1_INSTR(3) & IU_AU_IB1_INSTR(4) & 
    IU_AU_IB1_INSTR(5) & IU_AU_IB1_INSTR(23) & 
    IU_AU_IB1_INSTR(26) & IU_AU_IB1_INSTR(27)
     ) , STD_ULOGIC_VECTOR'("11111100"));
MQQ161:INSTRUCTION_DECODER_PT(44) <=
    Eq(( IU_AU_IB1_INSTR(1) & IU_AU_IB1_INSTR(2) & 
    IU_AU_IB1_INSTR(3) & IU_AU_IB1_INSTR(4) & 
    IU_AU_IB1_INSTR(5) & IU_AU_IB1_INSTR(27) & 
    IU_AU_IB1_INSTR(28) & IU_AU_IB1_INSTR(30)
     ) , STD_ULOGIC_VECTOR'("11111000"));
MQQ162:INSTRUCTION_DECODER_PT(45) <=
    Eq(( IU_AU_IB1_INSTR(0) & IU_AU_IB1_INSTR(1) & 
    IU_AU_IB1_INSTR(3) & IU_AU_IB1_INSTR(4) & 
    IU_AU_IB1_INSTR(5) & IU_AU_IB1_INSTR(27)
     ) , STD_ULOGIC_VECTOR'("011101"));
MQQ163:INSTRUCTION_DECODER_PT(46) <=
    Eq(( IU_AU_IB1_INSTR(0) & IU_AU_IB1_INSTR(1) & 
    IU_AU_IB1_INSTR(3) & IU_AU_IB1_INSTR(4)
     ) , STD_ULOGIC_VECTOR'("0001"));
MQQ164:INSTRUCTION_DECODER_PT(47) <=
    Eq(( IU_AU_IB1_INSTR(1) & IU_AU_IB1_INSTR(3) & 
    IU_AU_IB1_INSTR(4) & IU_AU_IB1_INSTR(26) & 
    IU_AU_IB1_INSTR(27) & IU_AU_IB1_INSTR(30)
     ) , STD_ULOGIC_VECTOR'("111011"));
MQQ165:INSTRUCTION_DECODER_PT(48) <=
    Eq(( IU_AU_IB1_INSTR(1) & IU_AU_IB1_INSTR(3) & 
    IU_AU_IB1_INSTR(4) & IU_AU_IB1_INSTR(25) & 
    IU_AU_IB1_INSTR(27) & IU_AU_IB1_INSTR(30)
     ) , STD_ULOGIC_VECTOR'("111011"));
MQQ166:INSTRUCTION_DECODER_PT(49) <=
    Eq(( IU_AU_IB1_INSTR(0) & IU_AU_IB1_INSTR(2) & 
    IU_AU_IB1_INSTR(3) & IU_AU_IB1_INSTR(5)
     ) , STD_ULOGIC_VECTOR'("0010"));
MQQ167:INSTRUCTION_DECODER_PT(50) <=
    Eq(( IU_AU_IB1_INSTR(0) & IU_AU_IB1_INSTR(3) & 
    IU_AU_IB1_INSTR(4) & IU_AU_IB1_INSTR(5)
     ) , STD_ULOGIC_VECTOR'("1100"));
MQQ168:INSTRUCTION_DECODER_PT(51) <=
    Eq(( IU_AU_IB1_INSTR(0) & IU_AU_IB1_INSTR(2) & 
    IU_AU_IB1_INSTR(3) & IU_AU_IB1_INSTR(5)
     ) , STD_ULOGIC_VECTOR'("1010"));
MQQ169:INSTRUCTION_DECODER_PT(52) <=
    Eq(( IU_AU_IB1_INSTR(0) & IU_AU_IB1_INSTR(3)
     ) , STD_ULOGIC_VECTOR'("10"));
MQQ170:INSTRUCTION_DECODER_PT(53) <=
    Eq(( IU_AU_IB1_INSTR(0) & IU_AU_IB1_INSTR(1) & 
    IU_AU_IB1_INSTR(3) & IU_AU_IB1_INSTR(31)
     ) , STD_ULOGIC_VECTOR'("1110"));
MQQ171:INSTRUCTION_DECODER_PT(54) <=
    Eq(( IU_AU_IB1_INSTR(0) & IU_AU_IB1_INSTR(2) & 
    IU_AU_IB1_INSTR(3) & IU_AU_IB1_INSTR(4) & 
    IU_AU_IB1_INSTR(5) ) , STD_ULOGIC_VECTOR'("11111"));
MQQ172:INSTRUCTION_DECODER_PT(55) <=
    Eq(( IU_AU_IB1_INSTR(1) & IU_AU_IB1_INSTR(2) & 
    IU_AU_IB1_INSTR(3) ) , STD_ULOGIC_VECTOR'("100"));
MQQ173:INSTRUCTION_DECODER_PT(56) <=
    Eq(( IU_AU_IB1_INSTR(0) & IU_AU_IB1_INSTR(3) & 
    IU_AU_IB1_INSTR(5) ) , STD_ULOGIC_VECTOR'("111"));
MQQ174:INSTRUCTION_DECODER_PT(57) <=
    Eq(( IU_AU_IB1_INSTR(0) & IU_AU_IB1_INSTR(1) & 
    IU_AU_IB1_INSTR(3) ) , STD_ULOGIC_VECTOR'("111"));
MQQ175:INSTRUCTION_DECODER_PT(58) <=
    Eq(( IU_AU_IB1_INSTR(1) & IU_AU_IB1_INSTR(2) & 
    IU_AU_IB1_INSTR(3) & IU_AU_IB1_INSTR(4)
     ) , STD_ULOGIC_VECTOR'("1011"));
-- Table INSTRUCTION_DECODER Signal Assignments for Outputs
MQQ176:TA_VLD <=  NOT (
    (INSTRUCTION_DECODER_PT(1) OR INSTRUCTION_DECODER_PT(2)
     OR INSTRUCTION_DECODER_PT(6) OR INSTRUCTION_DECODER_PT(9)
     OR INSTRUCTION_DECODER_PT(12) OR INSTRUCTION_DECODER_PT(18)
     OR INSTRUCTION_DECODER_PT(19) OR INSTRUCTION_DECODER_PT(20)
     OR INSTRUCTION_DECODER_PT(21) OR INSTRUCTION_DECODER_PT(23)
     OR INSTRUCTION_DECODER_PT(24) OR INSTRUCTION_DECODER_PT(27)
     OR INSTRUCTION_DECODER_PT(28) OR INSTRUCTION_DECODER_PT(34)
     OR INSTRUCTION_DECODER_PT(35) OR INSTRUCTION_DECODER_PT(39)
     OR INSTRUCTION_DECODER_PT(42) OR INSTRUCTION_DECODER_PT(43)
     OR INSTRUCTION_DECODER_PT(44) OR INSTRUCTION_DECODER_PT(46)
     OR INSTRUCTION_DECODER_PT(50) OR INSTRUCTION_DECODER_PT(51)
     OR INSTRUCTION_DECODER_PT(53) OR INSTRUCTION_DECODER_PT(54)
     OR INSTRUCTION_DECODER_PT(55)));
MQQ177:S1_VLD <=  NOT (
    (INSTRUCTION_DECODER_PT(1) OR INSTRUCTION_DECODER_PT(4)
     OR INSTRUCTION_DECODER_PT(8) OR INSTRUCTION_DECODER_PT(11)
     OR INSTRUCTION_DECODER_PT(14) OR INSTRUCTION_DECODER_PT(15)
     OR INSTRUCTION_DECODER_PT(16) OR INSTRUCTION_DECODER_PT(17)
     OR INSTRUCTION_DECODER_PT(21) OR INSTRUCTION_DECODER_PT(24)
     OR INSTRUCTION_DECODER_PT(28) OR INSTRUCTION_DECODER_PT(32)
     OR INSTRUCTION_DECODER_PT(33) OR INSTRUCTION_DECODER_PT(42)
     OR INSTRUCTION_DECODER_PT(55)));
MQQ178:S2_VLD <= 
    (INSTRUCTION_DECODER_PT(2) OR INSTRUCTION_DECODER_PT(3)
     OR INSTRUCTION_DECODER_PT(5) OR INSTRUCTION_DECODER_PT(7)
     OR INSTRUCTION_DECODER_PT(9) OR INSTRUCTION_DECODER_PT(12)
     OR INSTRUCTION_DECODER_PT(13) OR INSTRUCTION_DECODER_PT(18)
     OR INSTRUCTION_DECODER_PT(19) OR INSTRUCTION_DECODER_PT(22)
     OR INSTRUCTION_DECODER_PT(25) OR INSTRUCTION_DECODER_PT(26)
     OR INSTRUCTION_DECODER_PT(27) OR INSTRUCTION_DECODER_PT(29)
     OR INSTRUCTION_DECODER_PT(30) OR INSTRUCTION_DECODER_PT(31)
     OR INSTRUCTION_DECODER_PT(34) OR INSTRUCTION_DECODER_PT(36)
     OR INSTRUCTION_DECODER_PT(37) OR INSTRUCTION_DECODER_PT(38)
     OR INSTRUCTION_DECODER_PT(39) OR INSTRUCTION_DECODER_PT(40)
     OR INSTRUCTION_DECODER_PT(45) OR INSTRUCTION_DECODER_PT(47)
     OR INSTRUCTION_DECODER_PT(48) OR INSTRUCTION_DECODER_PT(49)
     OR INSTRUCTION_DECODER_PT(58));
MQQ179:S3_VLD <= 
    (INSTRUCTION_DECODER_PT(2) OR INSTRUCTION_DECODER_PT(6)
     OR INSTRUCTION_DECODER_PT(18) OR INSTRUCTION_DECODER_PT(19)
     OR INSTRUCTION_DECODER_PT(20) OR INSTRUCTION_DECODER_PT(23)
     OR INSTRUCTION_DECODER_PT(26) OR INSTRUCTION_DECODER_PT(50)
     OR INSTRUCTION_DECODER_PT(51) OR INSTRUCTION_DECODER_PT(56)
     OR INSTRUCTION_DECODER_PT(57));
MQQ180:LD_VLD <= 
    (INSTRUCTION_DECODER_PT(5) OR INSTRUCTION_DECODER_PT(7)
     OR INSTRUCTION_DECODER_PT(10) OR INSTRUCTION_DECODER_PT(25)
     OR INSTRUCTION_DECODER_PT(41) OR INSTRUCTION_DECODER_PT(52)
    );

--
-- Final Table Listing
--      *INPUTS*====================================*OUTPUTS*========================*
--      |                                           |                                |
--      | core64                                    |                                |
--      | |                                         |                                |
--      | | iu_au_ib1_instr                         |                                |
--      | | |      iu_au_ib1_instr                  |                                |
--      | | |      |     iu_au_ib1_instr            |  ta_sel  s1_sel  s2_sel  s3_sel|
--      | | |      |     |          iu_au_ib1_instr |  |       |       |       |     |
--      | | |      |     |          |               |  |       |       |       |     |
--      | | |      |     |          |               |  |       |       |       |     |
--      | | |      |     |          |               |  |       |       |       |     |
--      | | |      |     |          |               |  |       |       |       |     |
--      | | |      |     |          |               |  |       |       |       |     |
--      | | |      |     |          |               |  |       |       |       |     |
--      | | |      |     |          |               |  |       |       |       |     |
--      | | |      |     |          |               |  |       |       |       |     |
--      | | |      |     |          |               |  |       |       |       |     |
--      | | |      |     |          |               |  |       |       |       |     |
--      | | |      |   1 1111111112 22222222233     |  |       |       |       |     |
--      | | 012345 67890 1234567890 12345678901     |  |       |       |       |     |
--      *TYPE*======================================+================================+
--      | P PPPPPP PPPPP PPPPPPPPPP PPPPPPPPPPP     |  S       S       S       S     |
--      *POLARITY*--------------------------------->|  +       +       +       +     |
--      *PHASE*------------------------------------>|  T       T       T       T     |
--      *TERMS*=====================================+================================+
--    1 | - -1---1 ----- ---------- 0-1--1-0-0-     |  .       1       .       .     |
--    2 | - --1--- ----- ---------- 01----00---     |  .       .       1       .     |
--    3 | - 01---- ----- ---------- --1--00--1-     |  .       1       .       .     |
--    4 | - -11--1 ----- ---------- --1-11-0---     |  .       .       1       1     |
--    5 | - -11--1 ----- ---------- --11-1-0---     |  .       1       1       1     |
--    6 | - 01---- ----- ---------- --1-11-1---     |  1       .       .       .     |
--    7 | - 1--1-1 ----- ---------- -----------     |  1       .       .       .     |
--    8 | - -----0 ----- ---------- ------0----     |  .       .       1       .     |
--    9 | - 01---- ----- ---------- -----11--0-     |  1       1       .       .     |
--   10 | - 01---- ----- ---------- -----110---     |  1       1       .       .     |
--   11 | - -1-1-0 ----- ---------- -----------     |  1       .       .       .     |
--   12 | - 01---0 ----- ---------- -----------     |  .       1       .       .     |
--   13 | - 01-0-- ----- ---------- -----------     |  1       1       .       .     |
--   14 | - -10--- ----- ---------- -----------     |  1       1       .       .     |
--   15 | - -1--0- ----- ---------- -----------     |  1       1       1       .     |
--      *============================================================================*
--
-- Table INSTRUCTION_DECODER1 Signal Assignments for Product Terms
MQQ181:INSTRUCTION_DECODER1_PT(1) <=
    Eq(( IU_AU_IB1_INSTR(1) & IU_AU_IB1_INSTR(5) & 
    IU_AU_IB1_INSTR(21) & IU_AU_IB1_INSTR(23) & 
    IU_AU_IB1_INSTR(26) & IU_AU_IB1_INSTR(28) & 
    IU_AU_IB1_INSTR(30) ) , STD_ULOGIC_VECTOR'("1101100"));
MQQ182:INSTRUCTION_DECODER1_PT(2) <=
    Eq(( IU_AU_IB1_INSTR(2) & IU_AU_IB1_INSTR(21) & 
    IU_AU_IB1_INSTR(22) & IU_AU_IB1_INSTR(27) & 
    IU_AU_IB1_INSTR(28) ) , STD_ULOGIC_VECTOR'("10100"));
MQQ183:INSTRUCTION_DECODER1_PT(3) <=
    Eq(( IU_AU_IB1_INSTR(0) & IU_AU_IB1_INSTR(1) & 
    IU_AU_IB1_INSTR(23) & IU_AU_IB1_INSTR(26) & 
    IU_AU_IB1_INSTR(27) & IU_AU_IB1_INSTR(30)
     ) , STD_ULOGIC_VECTOR'("011001"));
MQQ184:INSTRUCTION_DECODER1_PT(4) <=
    Eq(( IU_AU_IB1_INSTR(1) & IU_AU_IB1_INSTR(2) & 
    IU_AU_IB1_INSTR(5) & IU_AU_IB1_INSTR(23) & 
    IU_AU_IB1_INSTR(25) & IU_AU_IB1_INSTR(26) & 
    IU_AU_IB1_INSTR(28) ) , STD_ULOGIC_VECTOR'("1111110"));
MQQ185:INSTRUCTION_DECODER1_PT(5) <=
    Eq(( IU_AU_IB1_INSTR(1) & IU_AU_IB1_INSTR(2) & 
    IU_AU_IB1_INSTR(5) & IU_AU_IB1_INSTR(23) & 
    IU_AU_IB1_INSTR(24) & IU_AU_IB1_INSTR(26) & 
    IU_AU_IB1_INSTR(28) ) , STD_ULOGIC_VECTOR'("1111110"));
MQQ186:INSTRUCTION_DECODER1_PT(6) <=
    Eq(( IU_AU_IB1_INSTR(0) & IU_AU_IB1_INSTR(1) & 
    IU_AU_IB1_INSTR(23) & IU_AU_IB1_INSTR(25) & 
    IU_AU_IB1_INSTR(26) & IU_AU_IB1_INSTR(28)
     ) , STD_ULOGIC_VECTOR'("011111"));
MQQ187:INSTRUCTION_DECODER1_PT(7) <=
    Eq(( IU_AU_IB1_INSTR(0) & IU_AU_IB1_INSTR(3) & 
    IU_AU_IB1_INSTR(5) ) , STD_ULOGIC_VECTOR'("111"));
MQQ188:INSTRUCTION_DECODER1_PT(8) <=
    Eq(( IU_AU_IB1_INSTR(5) & IU_AU_IB1_INSTR(27)
     ) , STD_ULOGIC_VECTOR'("00"));
MQQ189:INSTRUCTION_DECODER1_PT(9) <=
    Eq(( IU_AU_IB1_INSTR(0) & IU_AU_IB1_INSTR(1) & 
    IU_AU_IB1_INSTR(26) & IU_AU_IB1_INSTR(27) & 
    IU_AU_IB1_INSTR(30) ) , STD_ULOGIC_VECTOR'("01110"));
MQQ190:INSTRUCTION_DECODER1_PT(10) <=
    Eq(( IU_AU_IB1_INSTR(0) & IU_AU_IB1_INSTR(1) & 
    IU_AU_IB1_INSTR(26) & IU_AU_IB1_INSTR(27) & 
    IU_AU_IB1_INSTR(28) ) , STD_ULOGIC_VECTOR'("01110"));
MQQ191:INSTRUCTION_DECODER1_PT(11) <=
    Eq(( IU_AU_IB1_INSTR(1) & IU_AU_IB1_INSTR(3) & 
    IU_AU_IB1_INSTR(5) ) , STD_ULOGIC_VECTOR'("110"));
MQQ192:INSTRUCTION_DECODER1_PT(12) <=
    Eq(( IU_AU_IB1_INSTR(0) & IU_AU_IB1_INSTR(1) & 
    IU_AU_IB1_INSTR(5) ) , STD_ULOGIC_VECTOR'("010"));
MQQ193:INSTRUCTION_DECODER1_PT(13) <=
    Eq(( IU_AU_IB1_INSTR(0) & IU_AU_IB1_INSTR(1) & 
    IU_AU_IB1_INSTR(3) ) , STD_ULOGIC_VECTOR'("010"));
MQQ194:INSTRUCTION_DECODER1_PT(14) <=
    Eq(( IU_AU_IB1_INSTR(1) & IU_AU_IB1_INSTR(2)
     ) , STD_ULOGIC_VECTOR'("10"));
MQQ195:INSTRUCTION_DECODER1_PT(15) <=
    Eq(( IU_AU_IB1_INSTR(1) & IU_AU_IB1_INSTR(4)
     ) , STD_ULOGIC_VECTOR'("10"));
-- Table INSTRUCTION_DECODER1 Signal Assignments for Outputs
MQQ196:TA_SEL <= 
    (INSTRUCTION_DECODER1_PT(6) OR INSTRUCTION_DECODER1_PT(7)
     OR INSTRUCTION_DECODER1_PT(9) OR INSTRUCTION_DECODER1_PT(10)
     OR INSTRUCTION_DECODER1_PT(11) OR INSTRUCTION_DECODER1_PT(13)
     OR INSTRUCTION_DECODER1_PT(14) OR INSTRUCTION_DECODER1_PT(15)
    );
MQQ197:S1_SEL <= 
    (INSTRUCTION_DECODER1_PT(1) OR INSTRUCTION_DECODER1_PT(3)
     OR INSTRUCTION_DECODER1_PT(5) OR INSTRUCTION_DECODER1_PT(9)
     OR INSTRUCTION_DECODER1_PT(10) OR INSTRUCTION_DECODER1_PT(12)
     OR INSTRUCTION_DECODER1_PT(13) OR INSTRUCTION_DECODER1_PT(14)
     OR INSTRUCTION_DECODER1_PT(15));
MQQ198:S2_SEL <= 
    (INSTRUCTION_DECODER1_PT(2) OR INSTRUCTION_DECODER1_PT(4)
     OR INSTRUCTION_DECODER1_PT(5) OR INSTRUCTION_DECODER1_PT(8)
     OR INSTRUCTION_DECODER1_PT(15));
MQQ199:S3_SEL <= 
    (INSTRUCTION_DECODER1_PT(4) OR INSTRUCTION_DECODER1_PT(5)
    );

--
-- Final Table Listing
--      *INPUTS*====================================*OUTPUTS*=================================*
--      |                                           |                                         |
--      | core64                                    |                                         |
--      | |                                         |                                         |
--      | | is1_instr_L2                            |                                         |
--      | | |      is1_instr_L2                     |                                         |
--      | | |      |     is1_instr_L2               |                                         |
--      | | |      |     |          is1_instr_L2    |                                         |
--      | | |      |     |          |               |                                         |
--      | | |      |     |          |               |                                         |
--      | | |      |     |          |               |                                         |
--      | | |      |     |          |               |                                         |
--      | | |      |     |          |               | isFxuIssue                              |
--      | | |      |     |          |               | |                                       |
--      | | |      |     |          |               | |                                       |
--      | | |      |     |          |               | |                      hole_delay       |
--      | | |      |     |          |               | |                      |     compl_ex   |
--      | | |      |     |          |               | |                      |     |          |
--      | | |      |   1 1111111112 22222222233     | |                      |     |          |
--      | | 012345 67890 1234567890 12345678901     | |                      123   12345      |
--      *TYPE*======================================+=========================================+
--      | P PPPPPP PPPPP PPPPPPPPPP PPPPPPPPPPP     | S                      SSS   SSSSS      |
--      *POLARITY*--------------------------------->| +                      +++   +++++      |
--      *PHASE*------------------------------------>| T                      TTT   TTTTT      |
--      *TERMS*=====================================+=========================================+
--    1 | - 0--000 ----- ---------- 0100000000-     | 1                      ...   .....      |
--    2 | 1 011111 ----- ---------- 1011101001-     | 1                      ..1   .....      |
--    3 | 1 011111 ----- ---------- 0011101001-     | 1                      .1.   .....      |
--    4 | - 011111 ----- ---------- 011-0111000     | .                      ...   1....      |
--    5 | - 011111 ----- ---------- 000-1111000     | .                      ...   1....      |
--    6 | - 0-0011 ----- ---------- 0000000000-     | .                      ...   1....      |
--    7 | - 011111 ----- ---------- 01-0-111000     | .                      ...   1....      |
--    8 | - 011111 ----- 1--------- 000001001--     | .                      ...   1....      |
--    9 | - 011111 ----- ---------- 0-00-111000     | .                      ...   1....      |
--   10 | - 0-0-11 ----- ---------- 0010010110-     | 1                      ...   .....      |
--   11 | 1 011111 ----- ---------- 001-01011-1     | 1                      ...   1....      |
--   12 | - 0-0011 ----- ---------- 0-11000001-     | 1                      ...   1....      |
--   13 | - 0-0011 ----- ---------- 01-0100001-     | 1                      ...   1....      |
--   14 | 1 011111 ----- ---------- -00-001001-     | 1                      ..1   .....      |
--   15 | - 011111 ----- ---------- 001001011-1     | 1                      ...   1....      |
--   16 | - 0-0011 ----- ---------- 0011-00001-     | 1                      ...   1....      |
--   17 | - 0-0011 ----- ---------- 0-00100001-     | 1                      ...   1....      |
--   18 | - 0-0011 ----- ---------- 001-000001-     | 1                      ...   1....      |
--   19 | - 01-01- --1-- ---------- -000010000-     | 1                      ...   .....      |
--   20 | - 0-0011 ----- ---------- 0100-00001-     | 1                      ...   1....      |
--   21 | - 0-0011 ----- ---------- 000-100110-     | 1                      ...   1....      |
--   22 | - 011--1 ----- ---------- 00110101001     | 1                      ...   .....      |
--   23 | - 0-0011 ----- ---------- 000011001--     | 1                      ...   1....      |
--   24 | - 011--1 ----- ---------- 1110--0110-     | 1                      ...   .....      |
--   25 | 1 011--1 ----- ---------- 00-1111100-     | 1                      ...   .....      |
--   26 | - 01-01- ----- ---------- 00000-0000-     | 1                      ...   .....      |
--   27 | 1 011--1 ----- ---------- 110011101--     | 1                      ...   .1...      |
--   28 | 1 011--1 ----- ---------- 01-1111010-     | 1                      ...   .....      |
--   29 | - 011--1 ----- ---------- 1100110011-     | 1                      ...   .....      |
--   30 | - 011--1 ----- ----1----- 0101-10011-     | 1                      ...   ....1      |
--   31 | - 011--1 ----- ---------1 0101-10011-     | 1                      ...   ...1.      |
--   32 | - 011--1 ----- --------1- 0101-10011-     | 1                      ...   ...1.      |
--   33 | - 011--1 ----- -------1-- 0101-10011-     | 1                      ...   ...1.      |
--   34 | - 011--1 ----- ------1--- 0101-10011-     | 1                      ...   ...1.      |
--   35 | - 011--1 ----- -----1---- 0101-10011-     | 1                      ...   ...1.      |
--   36 | - 011--1 ----- ---1------ 0101-10011-     | 1                      ...   ...1.      |
--   37 | - 011--1 ----- --1------- 0101-10011-     | 1                      ...   ...1.      |
--   38 | - 011--1 ----- -1-------- 0101-10011-     | 1                      ...   ...1.      |
--   39 | - 011--1 ----- 1--------- 0101-10011-     | 1                      ...   ...1.      |
--   40 | 1 011--1 ----- ---------- -000011011-     | 1                      ...   .1...      |
--   41 | - 011--1 ----- ---------- 000001001--     | .                      ...   ....1      |
--   42 | 1 011--- ----- ---------- 10-001010--     | 1                      ...   .....      |
--   43 | 1 011--1 ----- ---------- 1100-110-0-     | 1                      ...   .1...      |
--   44 | - 011--1 ----- ---------- 0-11100110-     | 1                      ...   .....      |
--   45 | 1 011--1 ----- ---------- 111-01-010-     | 1                      ...   .1...      |
--   46 | - 011--1 ----- ---------- 010000111--     | 1                      ...   .....      |
--   47 | - 011--1 ----- ---------- 1100-11000-     | 1                      ...   .1...      |
--   48 | - 011--1 ----- ---------- -011110110-     | 1                      ...   .....      |
--   49 | - 011--1 ----- ---------- 1-0-010110-     | 1                      ...   .....      |
--   50 | - 011--1 ----- ---------- 1111--1111-     | 1                      ...   .....      |
--   51 | - 011--1 ----- ---------- 00-111-111-     | .                      ...   .1...      |
--   52 | - 011--1 ----- ---------- 01110-0011-     | 1                      ...   .....      |
--   53 | - 011--1 ----- ---------- 0-01111010-     | 1                      ...   .....      |
--   54 | - 011--1 ----- ---------- 00000-0100-     | 1                      ...   .....      |
--   55 | - 011--1 ----- ---------- 0010-00110-     | 1                      ...   .....      |
--   56 | - 011--1 ----- ---------- 000-111100-     | 1                      ...   .1...      |
--   57 | 1 011--- ----- ---------- 000-0-0100-     | 1                      ...   .....      |
--   58 | 1 111-10 ----- ---------- ---------01     | .                      ...   .1...      |
--   59 | 1 011--1 ----- ---------- 00-0-11010-     | 1                      ...   .....      |
--   60 | 1 011--- ----- ---------- 0101-101-1-     | 1                      ...   .....      |
--   61 | - 011--1 ----- ---------- 0101110-11-     | 1                      ...   ...1.      |
--   62 | - 011--1 ----- ---------- 11--010-101     | 1                      ...   .....      |
--   63 | - 011--1 ----- ---------- 0001-00011-     | 1                      ...   ....1      |
--   64 | - 011--1 ----- ---------- 00100100-0-     | 1                      ...   .....      |
--   65 | - 011--1 ----- ---------- 0011-0111--     | 1                      ...   .....      |
--   66 | - 011--1 ----- ---------- -00-101000-     | 1                      ...   .1...      |
--   67 | 1 011--- ----- ---------- 00-01101-1-     | 1                      ...   .1...      |
--   68 | - 011--1 ----- ---------- 10--010101-     | 1                      ...   .....      |
--   69 | - 011--1 ----- ---------- -00000-000-     | 1                      ...   .....      |
--   70 | - 011--1 ----- ---------- 0-0001011--     | 1                      ...   .....      |
--   71 | - 011--1 ----- ---------- 111-010-10-     | 1                      ...   .....      |
--   72 | - 011--1 ----- ---------- 111--10110-     | 1                      ...   .....      |
--   73 | - 011--1 ----- ---------- 000-01011--     | 1                      ...   .....      |
--   74 | - 011--1 ----- ---------- 00-1010011-     | 1                      ...   ...1.      |
--   75 | 1 011--1 ----- ---------- -11--010-1-     | 1                      ...   .....      |
--   76 | 1 011--1 ----- ---------- 00-001-1-1-     | 1                      ...   .....      |
--   77 | - 011--1 ----- ---------- -0000-1000-     | 1                      ...   .1...      |
--   78 | - 011--1 ----- ---------- 011--11100-     | 1                      ...   .1...      |
--   79 | - 011--1 ----- ---------- --11101-11-     | 1                      ...   ....1      |
--   80 | - 011--1 ----- ---------- 1110-1-010-     | 1                      ...   .1...      |
--   81 | - 011--1 ----- ---------- --00001010-     | 1                      ...   .1...      |
--   82 | - 011--1 ----- ---------- 01--000011-     | 1                      ...   .....      |
--   83 | - 011--1 ----- ---------- 0-00-1-111-     | 1                      ...   .....      |
--   84 | - 011111 ----- ---------- -----01111-     | 1                      ...   1....      |
--   85 | - 011--1 ----- ---------- 000011-11--     | 1                      ...   .....      |
--   86 | - 011--1 ----- ---------- 0000-0-000-     | 1                      ...   .1...      |
--   87 | - 011--1 ----- ---------- 0-00-11100-     | 1                      ...   .1...      |
--   88 | - 011--1 ----- ---------- -000-10110-     | 1                      ...   .....      |
--   89 | - 011--1 ----- ---------- -011-010-0-     | 1                      ...   .1...      |
--   90 | - 011--1 ----- ---------- 00-001-010-     | 1                      ...   .....      |
--   91 | - 011--1 ----- ---------- -01-0010-0-     | 1                      ...   .1...      |
--   92 | - 011--1 ----- ---------- -00-001-11-     | 1                      ...   ....1      |
--   93 | - 011--1 ----- ---------- -11-0-0110-     | 1                      ...   .....      |
--   94 | - 011--1 ----- ---------- 0-10-10111-     | 1                      ...   .1...      |
--   95 | - 011--1 ----- ---------- 1--0010-10-     | 1                      ...   .....      |
--   96 | - 011--1 ----- ---------- 10---10010-     | 1                      ...   .....      |
--   97 | - 011--1 ----- ---------- -11--01-11-     | 1                      ...   .....      |
--   98 | - 011--1 ----- ---------- 00-1-1-111-     | 1                      ...   .....      |
--   99 | - 011--1 ----- ---------- 0--0-00011-     | 1                      ...   .....      |
--   100 | - 011--1 ----- ---------- 0--001-111-     | 1                      ...   .....      |
--   101 | 1 --1010 ----- ---------- ----------0     | 1                      ...   .....      |
--   102 | - 011--1 ----- ---------- 0-0--10111-     | 1                      ...   .....      |
--   103 | - 011--1 ----- ---------- 00-0-10-11-     | 1                      ...   .....      |
--   104 | - 10-1-0 ----- ---------- -----------     | .                      ...   1....      |
--   105 | 1 -0-01- ----- ---------- -----------     | 1                      ...   .....      |
--   106 | 1 1-1-10 ----- ---------- ---------0-     | 1                      ...   .....      |
--   107 | - 000111 ----- ---------- -----------     | 1                      1..   .....      |
--   108 | - 10-1-- ----- ---------- -----------     | .                      ...   .1...      |
--   109 | 1 0-1--0 ----- ---------- -------00--     | 1                      ...   .1...      |
--   110 | - 01100- ----- ---------- -----------     | .                      ...   1....      |
--   111 | - 0110-0 ----- ---------- -----------     | .                      ...   1....      |
--   112 | - -0-011 ----- ---------- -----------     | 1                      ...   .1...      |
--   113 | 1 0-1--0 ----- ---------- ------0----     | 1                      ...   .1...      |
--   114 | - 01-0-0 ----- ---------- -----------     | 1                      ...   .....      |
--   115 | - 0101-1 ----- ---------- -----------     | 1                      ...   .1...      |
--   116 | - 10---- ----- ---------- -----------     | 1                      ...   .....      |
--   117 | - 001--0 ----- ---------- -----------     | 1                      ...   .1...      |
--   118 | - 01--0- ----- ---------- ---------1-     | 1                      ...   .....      |
--   119 | - 01-10- ----- ---------- -----------     | 1                      ...   .1...      |
--   120 | - -011-- ----- ---------- -----------     | 1                      ...   .1...      |
--   121 | - 0110-- ----- ---------- -----------     | 1                      ...   .1...      |
--      *=====================================================================================*
--
-- Table INSTRUCTION_DECODER2 Signal Assignments for Product Terms
MQQ200:INSTRUCTION_DECODER2_PT(1) <=
    Eq(( IS1_INSTR_L2(0) & IS1_INSTR_L2(3) & 
    IS1_INSTR_L2(4) & IS1_INSTR_L2(5) & 
    IS1_INSTR_L2(21) & IS1_INSTR_L2(22) & 
    IS1_INSTR_L2(23) & IS1_INSTR_L2(24) & 
    IS1_INSTR_L2(25) & IS1_INSTR_L2(26) & 
    IS1_INSTR_L2(27) & IS1_INSTR_L2(28) & 
    IS1_INSTR_L2(29) & IS1_INSTR_L2(30)
     ) , STD_ULOGIC_VECTOR'("00000100000000"));
MQQ201:INSTRUCTION_DECODER2_PT(2) <=
    Eq(( CORE64 & IS1_INSTR_L2(0) & 
    IS1_INSTR_L2(1) & IS1_INSTR_L2(2) & 
    IS1_INSTR_L2(3) & IS1_INSTR_L2(4) & 
    IS1_INSTR_L2(5) & IS1_INSTR_L2(21) & 
    IS1_INSTR_L2(22) & IS1_INSTR_L2(23) & 
    IS1_INSTR_L2(24) & IS1_INSTR_L2(25) & 
    IS1_INSTR_L2(26) & IS1_INSTR_L2(27) & 
    IS1_INSTR_L2(28) & IS1_INSTR_L2(29) & 
    IS1_INSTR_L2(30) ) , STD_ULOGIC_VECTOR'("10111111011101001"));
MQQ202:INSTRUCTION_DECODER2_PT(3) <=
    Eq(( CORE64 & IS1_INSTR_L2(0) & 
    IS1_INSTR_L2(1) & IS1_INSTR_L2(2) & 
    IS1_INSTR_L2(3) & IS1_INSTR_L2(4) & 
    IS1_INSTR_L2(5) & IS1_INSTR_L2(21) & 
    IS1_INSTR_L2(22) & IS1_INSTR_L2(23) & 
    IS1_INSTR_L2(24) & IS1_INSTR_L2(25) & 
    IS1_INSTR_L2(26) & IS1_INSTR_L2(27) & 
    IS1_INSTR_L2(28) & IS1_INSTR_L2(29) & 
    IS1_INSTR_L2(30) ) , STD_ULOGIC_VECTOR'("10111110011101001"));
MQQ203:INSTRUCTION_DECODER2_PT(4) <=
    Eq(( IS1_INSTR_L2(0) & IS1_INSTR_L2(1) & 
    IS1_INSTR_L2(2) & IS1_INSTR_L2(3) & 
    IS1_INSTR_L2(4) & IS1_INSTR_L2(5) & 
    IS1_INSTR_L2(21) & IS1_INSTR_L2(22) & 
    IS1_INSTR_L2(23) & IS1_INSTR_L2(25) & 
    IS1_INSTR_L2(26) & IS1_INSTR_L2(27) & 
    IS1_INSTR_L2(28) & IS1_INSTR_L2(29) & 
    IS1_INSTR_L2(30) & IS1_INSTR_L2(31)
     ) , STD_ULOGIC_VECTOR'("0111110110111000"));
MQQ204:INSTRUCTION_DECODER2_PT(5) <=
    Eq(( IS1_INSTR_L2(0) & IS1_INSTR_L2(1) & 
    IS1_INSTR_L2(2) & IS1_INSTR_L2(3) & 
    IS1_INSTR_L2(4) & IS1_INSTR_L2(5) & 
    IS1_INSTR_L2(21) & IS1_INSTR_L2(22) & 
    IS1_INSTR_L2(23) & IS1_INSTR_L2(25) & 
    IS1_INSTR_L2(26) & IS1_INSTR_L2(27) & 
    IS1_INSTR_L2(28) & IS1_INSTR_L2(29) & 
    IS1_INSTR_L2(30) & IS1_INSTR_L2(31)
     ) , STD_ULOGIC_VECTOR'("0111110001111000"));
MQQ205:INSTRUCTION_DECODER2_PT(6) <=
    Eq(( IS1_INSTR_L2(0) & IS1_INSTR_L2(2) & 
    IS1_INSTR_L2(3) & IS1_INSTR_L2(4) & 
    IS1_INSTR_L2(5) & IS1_INSTR_L2(21) & 
    IS1_INSTR_L2(22) & IS1_INSTR_L2(23) & 
    IS1_INSTR_L2(24) & IS1_INSTR_L2(25) & 
    IS1_INSTR_L2(26) & IS1_INSTR_L2(27) & 
    IS1_INSTR_L2(28) & IS1_INSTR_L2(29) & 
    IS1_INSTR_L2(30) ) , STD_ULOGIC_VECTOR'("000110000000000"));
MQQ206:INSTRUCTION_DECODER2_PT(7) <=
    Eq(( IS1_INSTR_L2(0) & IS1_INSTR_L2(1) & 
    IS1_INSTR_L2(2) & IS1_INSTR_L2(3) & 
    IS1_INSTR_L2(4) & IS1_INSTR_L2(5) & 
    IS1_INSTR_L2(21) & IS1_INSTR_L2(22) & 
    IS1_INSTR_L2(24) & IS1_INSTR_L2(26) & 
    IS1_INSTR_L2(27) & IS1_INSTR_L2(28) & 
    IS1_INSTR_L2(29) & IS1_INSTR_L2(30) & 
    IS1_INSTR_L2(31) ) , STD_ULOGIC_VECTOR'("011111010111000"));
MQQ207:INSTRUCTION_DECODER2_PT(8) <=
    Eq(( IS1_INSTR_L2(0) & IS1_INSTR_L2(1) & 
    IS1_INSTR_L2(2) & IS1_INSTR_L2(3) & 
    IS1_INSTR_L2(4) & IS1_INSTR_L2(5) & 
    IS1_INSTR_L2(11) & IS1_INSTR_L2(21) & 
    IS1_INSTR_L2(22) & IS1_INSTR_L2(23) & 
    IS1_INSTR_L2(24) & IS1_INSTR_L2(25) & 
    IS1_INSTR_L2(26) & IS1_INSTR_L2(27) & 
    IS1_INSTR_L2(28) & IS1_INSTR_L2(29)
     ) , STD_ULOGIC_VECTOR'("0111111000001001"));
MQQ208:INSTRUCTION_DECODER2_PT(9) <=
    Eq(( IS1_INSTR_L2(0) & IS1_INSTR_L2(1) & 
    IS1_INSTR_L2(2) & IS1_INSTR_L2(3) & 
    IS1_INSTR_L2(4) & IS1_INSTR_L2(5) & 
    IS1_INSTR_L2(21) & IS1_INSTR_L2(23) & 
    IS1_INSTR_L2(24) & IS1_INSTR_L2(26) & 
    IS1_INSTR_L2(27) & IS1_INSTR_L2(28) & 
    IS1_INSTR_L2(29) & IS1_INSTR_L2(30) & 
    IS1_INSTR_L2(31) ) , STD_ULOGIC_VECTOR'("011111000111000"));
MQQ209:INSTRUCTION_DECODER2_PT(10) <=
    Eq(( IS1_INSTR_L2(0) & IS1_INSTR_L2(2) & 
    IS1_INSTR_L2(4) & IS1_INSTR_L2(5) & 
    IS1_INSTR_L2(21) & IS1_INSTR_L2(22) & 
    IS1_INSTR_L2(23) & IS1_INSTR_L2(24) & 
    IS1_INSTR_L2(25) & IS1_INSTR_L2(26) & 
    IS1_INSTR_L2(27) & IS1_INSTR_L2(28) & 
    IS1_INSTR_L2(29) & IS1_INSTR_L2(30)
     ) , STD_ULOGIC_VECTOR'("00110010010110"));
MQQ210:INSTRUCTION_DECODER2_PT(11) <=
    Eq(( CORE64 & IS1_INSTR_L2(0) & 
    IS1_INSTR_L2(1) & IS1_INSTR_L2(2) & 
    IS1_INSTR_L2(3) & IS1_INSTR_L2(4) & 
    IS1_INSTR_L2(5) & IS1_INSTR_L2(21) & 
    IS1_INSTR_L2(22) & IS1_INSTR_L2(23) & 
    IS1_INSTR_L2(25) & IS1_INSTR_L2(26) & 
    IS1_INSTR_L2(27) & IS1_INSTR_L2(28) & 
    IS1_INSTR_L2(29) & IS1_INSTR_L2(31)
     ) , STD_ULOGIC_VECTOR'("1011111001010111"));
MQQ211:INSTRUCTION_DECODER2_PT(12) <=
    Eq(( IS1_INSTR_L2(0) & IS1_INSTR_L2(2) & 
    IS1_INSTR_L2(3) & IS1_INSTR_L2(4) & 
    IS1_INSTR_L2(5) & IS1_INSTR_L2(21) & 
    IS1_INSTR_L2(23) & IS1_INSTR_L2(24) & 
    IS1_INSTR_L2(25) & IS1_INSTR_L2(26) & 
    IS1_INSTR_L2(27) & IS1_INSTR_L2(28) & 
    IS1_INSTR_L2(29) & IS1_INSTR_L2(30)
     ) , STD_ULOGIC_VECTOR'("00011011000001"));
MQQ212:INSTRUCTION_DECODER2_PT(13) <=
    Eq(( IS1_INSTR_L2(0) & IS1_INSTR_L2(2) & 
    IS1_INSTR_L2(3) & IS1_INSTR_L2(4) & 
    IS1_INSTR_L2(5) & IS1_INSTR_L2(21) & 
    IS1_INSTR_L2(22) & IS1_INSTR_L2(24) & 
    IS1_INSTR_L2(25) & IS1_INSTR_L2(26) & 
    IS1_INSTR_L2(27) & IS1_INSTR_L2(28) & 
    IS1_INSTR_L2(29) & IS1_INSTR_L2(30)
     ) , STD_ULOGIC_VECTOR'("00011010100001"));
MQQ213:INSTRUCTION_DECODER2_PT(14) <=
    Eq(( CORE64 & IS1_INSTR_L2(0) & 
    IS1_INSTR_L2(1) & IS1_INSTR_L2(2) & 
    IS1_INSTR_L2(3) & IS1_INSTR_L2(4) & 
    IS1_INSTR_L2(5) & IS1_INSTR_L2(22) & 
    IS1_INSTR_L2(23) & IS1_INSTR_L2(25) & 
    IS1_INSTR_L2(26) & IS1_INSTR_L2(27) & 
    IS1_INSTR_L2(28) & IS1_INSTR_L2(29) & 
    IS1_INSTR_L2(30) ) , STD_ULOGIC_VECTOR'("101111100001001"));
MQQ214:INSTRUCTION_DECODER2_PT(15) <=
    Eq(( IS1_INSTR_L2(0) & IS1_INSTR_L2(1) & 
    IS1_INSTR_L2(2) & IS1_INSTR_L2(3) & 
    IS1_INSTR_L2(4) & IS1_INSTR_L2(5) & 
    IS1_INSTR_L2(21) & IS1_INSTR_L2(22) & 
    IS1_INSTR_L2(23) & IS1_INSTR_L2(24) & 
    IS1_INSTR_L2(25) & IS1_INSTR_L2(26) & 
    IS1_INSTR_L2(27) & IS1_INSTR_L2(28) & 
    IS1_INSTR_L2(29) & IS1_INSTR_L2(31)
     ) , STD_ULOGIC_VECTOR'("0111110010010111"));
MQQ215:INSTRUCTION_DECODER2_PT(16) <=
    Eq(( IS1_INSTR_L2(0) & IS1_INSTR_L2(2) & 
    IS1_INSTR_L2(3) & IS1_INSTR_L2(4) & 
    IS1_INSTR_L2(5) & IS1_INSTR_L2(21) & 
    IS1_INSTR_L2(22) & IS1_INSTR_L2(23) & 
    IS1_INSTR_L2(24) & IS1_INSTR_L2(26) & 
    IS1_INSTR_L2(27) & IS1_INSTR_L2(28) & 
    IS1_INSTR_L2(29) & IS1_INSTR_L2(30)
     ) , STD_ULOGIC_VECTOR'("00011001100001"));
MQQ216:INSTRUCTION_DECODER2_PT(17) <=
    Eq(( IS1_INSTR_L2(0) & IS1_INSTR_L2(2) & 
    IS1_INSTR_L2(3) & IS1_INSTR_L2(4) & 
    IS1_INSTR_L2(5) & IS1_INSTR_L2(21) & 
    IS1_INSTR_L2(23) & IS1_INSTR_L2(24) & 
    IS1_INSTR_L2(25) & IS1_INSTR_L2(26) & 
    IS1_INSTR_L2(27) & IS1_INSTR_L2(28) & 
    IS1_INSTR_L2(29) & IS1_INSTR_L2(30)
     ) , STD_ULOGIC_VECTOR'("00011000100001"));
MQQ217:INSTRUCTION_DECODER2_PT(18) <=
    Eq(( IS1_INSTR_L2(0) & IS1_INSTR_L2(2) & 
    IS1_INSTR_L2(3) & IS1_INSTR_L2(4) & 
    IS1_INSTR_L2(5) & IS1_INSTR_L2(21) & 
    IS1_INSTR_L2(22) & IS1_INSTR_L2(23) & 
    IS1_INSTR_L2(25) & IS1_INSTR_L2(26) & 
    IS1_INSTR_L2(27) & IS1_INSTR_L2(28) & 
    IS1_INSTR_L2(29) & IS1_INSTR_L2(30)
     ) , STD_ULOGIC_VECTOR'("00011001000001"));
MQQ218:INSTRUCTION_DECODER2_PT(19) <=
    Eq(( IS1_INSTR_L2(0) & IS1_INSTR_L2(1) & 
    IS1_INSTR_L2(3) & IS1_INSTR_L2(4) & 
    IS1_INSTR_L2(8) & IS1_INSTR_L2(22) & 
    IS1_INSTR_L2(23) & IS1_INSTR_L2(24) & 
    IS1_INSTR_L2(25) & IS1_INSTR_L2(26) & 
    IS1_INSTR_L2(27) & IS1_INSTR_L2(28) & 
    IS1_INSTR_L2(29) & IS1_INSTR_L2(30)
     ) , STD_ULOGIC_VECTOR'("01011000010000"));
MQQ219:INSTRUCTION_DECODER2_PT(20) <=
    Eq(( IS1_INSTR_L2(0) & IS1_INSTR_L2(2) & 
    IS1_INSTR_L2(3) & IS1_INSTR_L2(4) & 
    IS1_INSTR_L2(5) & IS1_INSTR_L2(21) & 
    IS1_INSTR_L2(22) & IS1_INSTR_L2(23) & 
    IS1_INSTR_L2(24) & IS1_INSTR_L2(26) & 
    IS1_INSTR_L2(27) & IS1_INSTR_L2(28) & 
    IS1_INSTR_L2(29) & IS1_INSTR_L2(30)
     ) , STD_ULOGIC_VECTOR'("00011010000001"));
MQQ220:INSTRUCTION_DECODER2_PT(21) <=
    Eq(( IS1_INSTR_L2(0) & IS1_INSTR_L2(2) & 
    IS1_INSTR_L2(3) & IS1_INSTR_L2(4) & 
    IS1_INSTR_L2(5) & IS1_INSTR_L2(21) & 
    IS1_INSTR_L2(22) & IS1_INSTR_L2(23) & 
    IS1_INSTR_L2(25) & IS1_INSTR_L2(26) & 
    IS1_INSTR_L2(27) & IS1_INSTR_L2(28) & 
    IS1_INSTR_L2(29) & IS1_INSTR_L2(30)
     ) , STD_ULOGIC_VECTOR'("00011000100110"));
MQQ221:INSTRUCTION_DECODER2_PT(22) <=
    Eq(( IS1_INSTR_L2(0) & IS1_INSTR_L2(1) & 
    IS1_INSTR_L2(2) & IS1_INSTR_L2(5) & 
    IS1_INSTR_L2(21) & IS1_INSTR_L2(22) & 
    IS1_INSTR_L2(23) & IS1_INSTR_L2(24) & 
    IS1_INSTR_L2(25) & IS1_INSTR_L2(26) & 
    IS1_INSTR_L2(27) & IS1_INSTR_L2(28) & 
    IS1_INSTR_L2(29) & IS1_INSTR_L2(30) & 
    IS1_INSTR_L2(31) ) , STD_ULOGIC_VECTOR'("011100110101001"));
MQQ222:INSTRUCTION_DECODER2_PT(23) <=
    Eq(( IS1_INSTR_L2(0) & IS1_INSTR_L2(2) & 
    IS1_INSTR_L2(3) & IS1_INSTR_L2(4) & 
    IS1_INSTR_L2(5) & IS1_INSTR_L2(21) & 
    IS1_INSTR_L2(22) & IS1_INSTR_L2(23) & 
    IS1_INSTR_L2(24) & IS1_INSTR_L2(25) & 
    IS1_INSTR_L2(26) & IS1_INSTR_L2(27) & 
    IS1_INSTR_L2(28) & IS1_INSTR_L2(29)
     ) , STD_ULOGIC_VECTOR'("00011000011001"));
MQQ223:INSTRUCTION_DECODER2_PT(24) <=
    Eq(( IS1_INSTR_L2(0) & IS1_INSTR_L2(1) & 
    IS1_INSTR_L2(2) & IS1_INSTR_L2(5) & 
    IS1_INSTR_L2(21) & IS1_INSTR_L2(22) & 
    IS1_INSTR_L2(23) & IS1_INSTR_L2(24) & 
    IS1_INSTR_L2(27) & IS1_INSTR_L2(28) & 
    IS1_INSTR_L2(29) & IS1_INSTR_L2(30)
     ) , STD_ULOGIC_VECTOR'("011111100110"));
MQQ224:INSTRUCTION_DECODER2_PT(25) <=
    Eq(( CORE64 & IS1_INSTR_L2(0) & 
    IS1_INSTR_L2(1) & IS1_INSTR_L2(2) & 
    IS1_INSTR_L2(5) & IS1_INSTR_L2(21) & 
    IS1_INSTR_L2(22) & IS1_INSTR_L2(24) & 
    IS1_INSTR_L2(25) & IS1_INSTR_L2(26) & 
    IS1_INSTR_L2(27) & IS1_INSTR_L2(28) & 
    IS1_INSTR_L2(29) & IS1_INSTR_L2(30)
     ) , STD_ULOGIC_VECTOR'("10111001111100"));
MQQ225:INSTRUCTION_DECODER2_PT(26) <=
    Eq(( IS1_INSTR_L2(0) & IS1_INSTR_L2(1) & 
    IS1_INSTR_L2(3) & IS1_INSTR_L2(4) & 
    IS1_INSTR_L2(21) & IS1_INSTR_L2(22) & 
    IS1_INSTR_L2(23) & IS1_INSTR_L2(24) & 
    IS1_INSTR_L2(25) & IS1_INSTR_L2(27) & 
    IS1_INSTR_L2(28) & IS1_INSTR_L2(29) & 
    IS1_INSTR_L2(30) ) , STD_ULOGIC_VECTOR'("0101000000000"));
MQQ226:INSTRUCTION_DECODER2_PT(27) <=
    Eq(( CORE64 & IS1_INSTR_L2(0) & 
    IS1_INSTR_L2(1) & IS1_INSTR_L2(2) & 
    IS1_INSTR_L2(5) & IS1_INSTR_L2(21) & 
    IS1_INSTR_L2(22) & IS1_INSTR_L2(23) & 
    IS1_INSTR_L2(24) & IS1_INSTR_L2(25) & 
    IS1_INSTR_L2(26) & IS1_INSTR_L2(27) & 
    IS1_INSTR_L2(28) & IS1_INSTR_L2(29)
     ) , STD_ULOGIC_VECTOR'("10111110011101"));
MQQ227:INSTRUCTION_DECODER2_PT(28) <=
    Eq(( CORE64 & IS1_INSTR_L2(0) & 
    IS1_INSTR_L2(1) & IS1_INSTR_L2(2) & 
    IS1_INSTR_L2(5) & IS1_INSTR_L2(21) & 
    IS1_INSTR_L2(22) & IS1_INSTR_L2(24) & 
    IS1_INSTR_L2(25) & IS1_INSTR_L2(26) & 
    IS1_INSTR_L2(27) & IS1_INSTR_L2(28) & 
    IS1_INSTR_L2(29) & IS1_INSTR_L2(30)
     ) , STD_ULOGIC_VECTOR'("10111011111010"));
MQQ228:INSTRUCTION_DECODER2_PT(29) <=
    Eq(( IS1_INSTR_L2(0) & IS1_INSTR_L2(1) & 
    IS1_INSTR_L2(2) & IS1_INSTR_L2(5) & 
    IS1_INSTR_L2(21) & IS1_INSTR_L2(22) & 
    IS1_INSTR_L2(23) & IS1_INSTR_L2(24) & 
    IS1_INSTR_L2(25) & IS1_INSTR_L2(26) & 
    IS1_INSTR_L2(27) & IS1_INSTR_L2(28) & 
    IS1_INSTR_L2(29) & IS1_INSTR_L2(30)
     ) , STD_ULOGIC_VECTOR'("01111100110011"));
MQQ229:INSTRUCTION_DECODER2_PT(30) <=
    Eq(( IS1_INSTR_L2(0) & IS1_INSTR_L2(1) & 
    IS1_INSTR_L2(2) & IS1_INSTR_L2(5) & 
    IS1_INSTR_L2(15) & IS1_INSTR_L2(21) & 
    IS1_INSTR_L2(22) & IS1_INSTR_L2(23) & 
    IS1_INSTR_L2(24) & IS1_INSTR_L2(26) & 
    IS1_INSTR_L2(27) & IS1_INSTR_L2(28) & 
    IS1_INSTR_L2(29) & IS1_INSTR_L2(30)
     ) , STD_ULOGIC_VECTOR'("01111010110011"));
MQQ230:INSTRUCTION_DECODER2_PT(31) <=
    Eq(( IS1_INSTR_L2(0) & IS1_INSTR_L2(1) & 
    IS1_INSTR_L2(2) & IS1_INSTR_L2(5) & 
    IS1_INSTR_L2(20) & IS1_INSTR_L2(21) & 
    IS1_INSTR_L2(22) & IS1_INSTR_L2(23) & 
    IS1_INSTR_L2(24) & IS1_INSTR_L2(26) & 
    IS1_INSTR_L2(27) & IS1_INSTR_L2(28) & 
    IS1_INSTR_L2(29) & IS1_INSTR_L2(30)
     ) , STD_ULOGIC_VECTOR'("01111010110011"));
MQQ231:INSTRUCTION_DECODER2_PT(32) <=
    Eq(( IS1_INSTR_L2(0) & IS1_INSTR_L2(1) & 
    IS1_INSTR_L2(2) & IS1_INSTR_L2(5) & 
    IS1_INSTR_L2(19) & IS1_INSTR_L2(21) & 
    IS1_INSTR_L2(22) & IS1_INSTR_L2(23) & 
    IS1_INSTR_L2(24) & IS1_INSTR_L2(26) & 
    IS1_INSTR_L2(27) & IS1_INSTR_L2(28) & 
    IS1_INSTR_L2(29) & IS1_INSTR_L2(30)
     ) , STD_ULOGIC_VECTOR'("01111010110011"));
MQQ232:INSTRUCTION_DECODER2_PT(33) <=
    Eq(( IS1_INSTR_L2(0) & IS1_INSTR_L2(1) & 
    IS1_INSTR_L2(2) & IS1_INSTR_L2(5) & 
    IS1_INSTR_L2(18) & IS1_INSTR_L2(21) & 
    IS1_INSTR_L2(22) & IS1_INSTR_L2(23) & 
    IS1_INSTR_L2(24) & IS1_INSTR_L2(26) & 
    IS1_INSTR_L2(27) & IS1_INSTR_L2(28) & 
    IS1_INSTR_L2(29) & IS1_INSTR_L2(30)
     ) , STD_ULOGIC_VECTOR'("01111010110011"));
MQQ233:INSTRUCTION_DECODER2_PT(34) <=
    Eq(( IS1_INSTR_L2(0) & IS1_INSTR_L2(1) & 
    IS1_INSTR_L2(2) & IS1_INSTR_L2(5) & 
    IS1_INSTR_L2(17) & IS1_INSTR_L2(21) & 
    IS1_INSTR_L2(22) & IS1_INSTR_L2(23) & 
    IS1_INSTR_L2(24) & IS1_INSTR_L2(26) & 
    IS1_INSTR_L2(27) & IS1_INSTR_L2(28) & 
    IS1_INSTR_L2(29) & IS1_INSTR_L2(30)
     ) , STD_ULOGIC_VECTOR'("01111010110011"));
MQQ234:INSTRUCTION_DECODER2_PT(35) <=
    Eq(( IS1_INSTR_L2(0) & IS1_INSTR_L2(1) & 
    IS1_INSTR_L2(2) & IS1_INSTR_L2(5) & 
    IS1_INSTR_L2(16) & IS1_INSTR_L2(21) & 
    IS1_INSTR_L2(22) & IS1_INSTR_L2(23) & 
    IS1_INSTR_L2(24) & IS1_INSTR_L2(26) & 
    IS1_INSTR_L2(27) & IS1_INSTR_L2(28) & 
    IS1_INSTR_L2(29) & IS1_INSTR_L2(30)
     ) , STD_ULOGIC_VECTOR'("01111010110011"));
MQQ235:INSTRUCTION_DECODER2_PT(36) <=
    Eq(( IS1_INSTR_L2(0) & IS1_INSTR_L2(1) & 
    IS1_INSTR_L2(2) & IS1_INSTR_L2(5) & 
    IS1_INSTR_L2(14) & IS1_INSTR_L2(21) & 
    IS1_INSTR_L2(22) & IS1_INSTR_L2(23) & 
    IS1_INSTR_L2(24) & IS1_INSTR_L2(26) & 
    IS1_INSTR_L2(27) & IS1_INSTR_L2(28) & 
    IS1_INSTR_L2(29) & IS1_INSTR_L2(30)
     ) , STD_ULOGIC_VECTOR'("01111010110011"));
MQQ236:INSTRUCTION_DECODER2_PT(37) <=
    Eq(( IS1_INSTR_L2(0) & IS1_INSTR_L2(1) & 
    IS1_INSTR_L2(2) & IS1_INSTR_L2(5) & 
    IS1_INSTR_L2(13) & IS1_INSTR_L2(21) & 
    IS1_INSTR_L2(22) & IS1_INSTR_L2(23) & 
    IS1_INSTR_L2(24) & IS1_INSTR_L2(26) & 
    IS1_INSTR_L2(27) & IS1_INSTR_L2(28) & 
    IS1_INSTR_L2(29) & IS1_INSTR_L2(30)
     ) , STD_ULOGIC_VECTOR'("01111010110011"));
MQQ237:INSTRUCTION_DECODER2_PT(38) <=
    Eq(( IS1_INSTR_L2(0) & IS1_INSTR_L2(1) & 
    IS1_INSTR_L2(2) & IS1_INSTR_L2(5) & 
    IS1_INSTR_L2(12) & IS1_INSTR_L2(21) & 
    IS1_INSTR_L2(22) & IS1_INSTR_L2(23) & 
    IS1_INSTR_L2(24) & IS1_INSTR_L2(26) & 
    IS1_INSTR_L2(27) & IS1_INSTR_L2(28) & 
    IS1_INSTR_L2(29) & IS1_INSTR_L2(30)
     ) , STD_ULOGIC_VECTOR'("01111010110011"));
MQQ238:INSTRUCTION_DECODER2_PT(39) <=
    Eq(( IS1_INSTR_L2(0) & IS1_INSTR_L2(1) & 
    IS1_INSTR_L2(2) & IS1_INSTR_L2(5) & 
    IS1_INSTR_L2(11) & IS1_INSTR_L2(21) & 
    IS1_INSTR_L2(22) & IS1_INSTR_L2(23) & 
    IS1_INSTR_L2(24) & IS1_INSTR_L2(26) & 
    IS1_INSTR_L2(27) & IS1_INSTR_L2(28) & 
    IS1_INSTR_L2(29) & IS1_INSTR_L2(30)
     ) , STD_ULOGIC_VECTOR'("01111010110011"));
MQQ239:INSTRUCTION_DECODER2_PT(40) <=
    Eq(( CORE64 & IS1_INSTR_L2(0) & 
    IS1_INSTR_L2(1) & IS1_INSTR_L2(2) & 
    IS1_INSTR_L2(5) & IS1_INSTR_L2(22) & 
    IS1_INSTR_L2(23) & IS1_INSTR_L2(24) & 
    IS1_INSTR_L2(25) & IS1_INSTR_L2(26) & 
    IS1_INSTR_L2(27) & IS1_INSTR_L2(28) & 
    IS1_INSTR_L2(29) & IS1_INSTR_L2(30)
     ) , STD_ULOGIC_VECTOR'("10111000011011"));
MQQ240:INSTRUCTION_DECODER2_PT(41) <=
    Eq(( IS1_INSTR_L2(0) & IS1_INSTR_L2(1) & 
    IS1_INSTR_L2(2) & IS1_INSTR_L2(5) & 
    IS1_INSTR_L2(21) & IS1_INSTR_L2(22) & 
    IS1_INSTR_L2(23) & IS1_INSTR_L2(24) & 
    IS1_INSTR_L2(25) & IS1_INSTR_L2(26) & 
    IS1_INSTR_L2(27) & IS1_INSTR_L2(28) & 
    IS1_INSTR_L2(29) ) , STD_ULOGIC_VECTOR'("0111000001001"));
MQQ241:INSTRUCTION_DECODER2_PT(42) <=
    Eq(( CORE64 & IS1_INSTR_L2(0) & 
    IS1_INSTR_L2(1) & IS1_INSTR_L2(2) & 
    IS1_INSTR_L2(21) & IS1_INSTR_L2(22) & 
    IS1_INSTR_L2(24) & IS1_INSTR_L2(25) & 
    IS1_INSTR_L2(26) & IS1_INSTR_L2(27) & 
    IS1_INSTR_L2(28) & IS1_INSTR_L2(29)
     ) , STD_ULOGIC_VECTOR'("101110001010"));
MQQ242:INSTRUCTION_DECODER2_PT(43) <=
    Eq(( CORE64 & IS1_INSTR_L2(0) & 
    IS1_INSTR_L2(1) & IS1_INSTR_L2(2) & 
    IS1_INSTR_L2(5) & IS1_INSTR_L2(21) & 
    IS1_INSTR_L2(22) & IS1_INSTR_L2(23) & 
    IS1_INSTR_L2(24) & IS1_INSTR_L2(26) & 
    IS1_INSTR_L2(27) & IS1_INSTR_L2(28) & 
    IS1_INSTR_L2(30) ) , STD_ULOGIC_VECTOR'("1011111001100"));
MQQ243:INSTRUCTION_DECODER2_PT(44) <=
    Eq(( IS1_INSTR_L2(0) & IS1_INSTR_L2(1) & 
    IS1_INSTR_L2(2) & IS1_INSTR_L2(5) & 
    IS1_INSTR_L2(21) & IS1_INSTR_L2(23) & 
    IS1_INSTR_L2(24) & IS1_INSTR_L2(25) & 
    IS1_INSTR_L2(26) & IS1_INSTR_L2(27) & 
    IS1_INSTR_L2(28) & IS1_INSTR_L2(29) & 
    IS1_INSTR_L2(30) ) , STD_ULOGIC_VECTOR'("0111011100110"));
MQQ244:INSTRUCTION_DECODER2_PT(45) <=
    Eq(( CORE64 & IS1_INSTR_L2(0) & 
    IS1_INSTR_L2(1) & IS1_INSTR_L2(2) & 
    IS1_INSTR_L2(5) & IS1_INSTR_L2(21) & 
    IS1_INSTR_L2(22) & IS1_INSTR_L2(23) & 
    IS1_INSTR_L2(25) & IS1_INSTR_L2(26) & 
    IS1_INSTR_L2(28) & IS1_INSTR_L2(29) & 
    IS1_INSTR_L2(30) ) , STD_ULOGIC_VECTOR'("1011111101010"));
MQQ245:INSTRUCTION_DECODER2_PT(46) <=
    Eq(( IS1_INSTR_L2(0) & IS1_INSTR_L2(1) & 
    IS1_INSTR_L2(2) & IS1_INSTR_L2(5) & 
    IS1_INSTR_L2(21) & IS1_INSTR_L2(22) & 
    IS1_INSTR_L2(23) & IS1_INSTR_L2(24) & 
    IS1_INSTR_L2(25) & IS1_INSTR_L2(26) & 
    IS1_INSTR_L2(27) & IS1_INSTR_L2(28) & 
    IS1_INSTR_L2(29) ) , STD_ULOGIC_VECTOR'("0111010000111"));
MQQ246:INSTRUCTION_DECODER2_PT(47) <=
    Eq(( IS1_INSTR_L2(0) & IS1_INSTR_L2(1) & 
    IS1_INSTR_L2(2) & IS1_INSTR_L2(5) & 
    IS1_INSTR_L2(21) & IS1_INSTR_L2(22) & 
    IS1_INSTR_L2(23) & IS1_INSTR_L2(24) & 
    IS1_INSTR_L2(26) & IS1_INSTR_L2(27) & 
    IS1_INSTR_L2(28) & IS1_INSTR_L2(29) & 
    IS1_INSTR_L2(30) ) , STD_ULOGIC_VECTOR'("0111110011000"));
MQQ247:INSTRUCTION_DECODER2_PT(48) <=
    Eq(( IS1_INSTR_L2(0) & IS1_INSTR_L2(1) & 
    IS1_INSTR_L2(2) & IS1_INSTR_L2(5) & 
    IS1_INSTR_L2(22) & IS1_INSTR_L2(23) & 
    IS1_INSTR_L2(24) & IS1_INSTR_L2(25) & 
    IS1_INSTR_L2(26) & IS1_INSTR_L2(27) & 
    IS1_INSTR_L2(28) & IS1_INSTR_L2(29) & 
    IS1_INSTR_L2(30) ) , STD_ULOGIC_VECTOR'("0111011110110"));
MQQ248:INSTRUCTION_DECODER2_PT(49) <=
    Eq(( IS1_INSTR_L2(0) & IS1_INSTR_L2(1) & 
    IS1_INSTR_L2(2) & IS1_INSTR_L2(5) & 
    IS1_INSTR_L2(21) & IS1_INSTR_L2(23) & 
    IS1_INSTR_L2(25) & IS1_INSTR_L2(26) & 
    IS1_INSTR_L2(27) & IS1_INSTR_L2(28) & 
    IS1_INSTR_L2(29) & IS1_INSTR_L2(30)
     ) , STD_ULOGIC_VECTOR'("011110010110"));
MQQ249:INSTRUCTION_DECODER2_PT(50) <=
    Eq(( IS1_INSTR_L2(0) & IS1_INSTR_L2(1) & 
    IS1_INSTR_L2(2) & IS1_INSTR_L2(5) & 
    IS1_INSTR_L2(21) & IS1_INSTR_L2(22) & 
    IS1_INSTR_L2(23) & IS1_INSTR_L2(24) & 
    IS1_INSTR_L2(27) & IS1_INSTR_L2(28) & 
    IS1_INSTR_L2(29) & IS1_INSTR_L2(30)
     ) , STD_ULOGIC_VECTOR'("011111111111"));
MQQ250:INSTRUCTION_DECODER2_PT(51) <=
    Eq(( IS1_INSTR_L2(0) & IS1_INSTR_L2(1) & 
    IS1_INSTR_L2(2) & IS1_INSTR_L2(5) & 
    IS1_INSTR_L2(21) & IS1_INSTR_L2(22) & 
    IS1_INSTR_L2(24) & IS1_INSTR_L2(25) & 
    IS1_INSTR_L2(26) & IS1_INSTR_L2(28) & 
    IS1_INSTR_L2(29) & IS1_INSTR_L2(30)
     ) , STD_ULOGIC_VECTOR'("011100111111"));
MQQ251:INSTRUCTION_DECODER2_PT(52) <=
    Eq(( IS1_INSTR_L2(0) & IS1_INSTR_L2(1) & 
    IS1_INSTR_L2(2) & IS1_INSTR_L2(5) & 
    IS1_INSTR_L2(21) & IS1_INSTR_L2(22) & 
    IS1_INSTR_L2(23) & IS1_INSTR_L2(24) & 
    IS1_INSTR_L2(25) & IS1_INSTR_L2(27) & 
    IS1_INSTR_L2(28) & IS1_INSTR_L2(29) & 
    IS1_INSTR_L2(30) ) , STD_ULOGIC_VECTOR'("0111011100011"));
MQQ252:INSTRUCTION_DECODER2_PT(53) <=
    Eq(( IS1_INSTR_L2(0) & IS1_INSTR_L2(1) & 
    IS1_INSTR_L2(2) & IS1_INSTR_L2(5) & 
    IS1_INSTR_L2(21) & IS1_INSTR_L2(23) & 
    IS1_INSTR_L2(24) & IS1_INSTR_L2(25) & 
    IS1_INSTR_L2(26) & IS1_INSTR_L2(27) & 
    IS1_INSTR_L2(28) & IS1_INSTR_L2(29) & 
    IS1_INSTR_L2(30) ) , STD_ULOGIC_VECTOR'("0111001111010"));
MQQ253:INSTRUCTION_DECODER2_PT(54) <=
    Eq(( IS1_INSTR_L2(0) & IS1_INSTR_L2(1) & 
    IS1_INSTR_L2(2) & IS1_INSTR_L2(5) & 
    IS1_INSTR_L2(21) & IS1_INSTR_L2(22) & 
    IS1_INSTR_L2(23) & IS1_INSTR_L2(24) & 
    IS1_INSTR_L2(25) & IS1_INSTR_L2(27) & 
    IS1_INSTR_L2(28) & IS1_INSTR_L2(29) & 
    IS1_INSTR_L2(30) ) , STD_ULOGIC_VECTOR'("0111000000100"));
MQQ254:INSTRUCTION_DECODER2_PT(55) <=
    Eq(( IS1_INSTR_L2(0) & IS1_INSTR_L2(1) & 
    IS1_INSTR_L2(2) & IS1_INSTR_L2(5) & 
    IS1_INSTR_L2(21) & IS1_INSTR_L2(22) & 
    IS1_INSTR_L2(23) & IS1_INSTR_L2(24) & 
    IS1_INSTR_L2(26) & IS1_INSTR_L2(27) & 
    IS1_INSTR_L2(28) & IS1_INSTR_L2(29) & 
    IS1_INSTR_L2(30) ) , STD_ULOGIC_VECTOR'("0111001000110"));
MQQ255:INSTRUCTION_DECODER2_PT(56) <=
    Eq(( IS1_INSTR_L2(0) & IS1_INSTR_L2(1) & 
    IS1_INSTR_L2(2) & IS1_INSTR_L2(5) & 
    IS1_INSTR_L2(21) & IS1_INSTR_L2(22) & 
    IS1_INSTR_L2(23) & IS1_INSTR_L2(25) & 
    IS1_INSTR_L2(26) & IS1_INSTR_L2(27) & 
    IS1_INSTR_L2(28) & IS1_INSTR_L2(29) & 
    IS1_INSTR_L2(30) ) , STD_ULOGIC_VECTOR'("0111000111100"));
MQQ256:INSTRUCTION_DECODER2_PT(57) <=
    Eq(( CORE64 & IS1_INSTR_L2(0) & 
    IS1_INSTR_L2(1) & IS1_INSTR_L2(2) & 
    IS1_INSTR_L2(21) & IS1_INSTR_L2(22) & 
    IS1_INSTR_L2(23) & IS1_INSTR_L2(25) & 
    IS1_INSTR_L2(27) & IS1_INSTR_L2(28) & 
    IS1_INSTR_L2(29) & IS1_INSTR_L2(30)
     ) , STD_ULOGIC_VECTOR'("101100000100"));
MQQ257:INSTRUCTION_DECODER2_PT(58) <=
    Eq(( CORE64 & IS1_INSTR_L2(0) & 
    IS1_INSTR_L2(1) & IS1_INSTR_L2(2) & 
    IS1_INSTR_L2(4) & IS1_INSTR_L2(5) & 
    IS1_INSTR_L2(30) & IS1_INSTR_L2(31)
     ) , STD_ULOGIC_VECTOR'("11111001"));
MQQ258:INSTRUCTION_DECODER2_PT(59) <=
    Eq(( CORE64 & IS1_INSTR_L2(0) & 
    IS1_INSTR_L2(1) & IS1_INSTR_L2(2) & 
    IS1_INSTR_L2(5) & IS1_INSTR_L2(21) & 
    IS1_INSTR_L2(22) & IS1_INSTR_L2(24) & 
    IS1_INSTR_L2(26) & IS1_INSTR_L2(27) & 
    IS1_INSTR_L2(28) & IS1_INSTR_L2(29) & 
    IS1_INSTR_L2(30) ) , STD_ULOGIC_VECTOR'("1011100011010"));
MQQ259:INSTRUCTION_DECODER2_PT(60) <=
    Eq(( CORE64 & IS1_INSTR_L2(0) & 
    IS1_INSTR_L2(1) & IS1_INSTR_L2(2) & 
    IS1_INSTR_L2(21) & IS1_INSTR_L2(22) & 
    IS1_INSTR_L2(23) & IS1_INSTR_L2(24) & 
    IS1_INSTR_L2(26) & IS1_INSTR_L2(27) & 
    IS1_INSTR_L2(28) & IS1_INSTR_L2(30)
     ) , STD_ULOGIC_VECTOR'("101101011011"));
MQQ260:INSTRUCTION_DECODER2_PT(61) <=
    Eq(( IS1_INSTR_L2(0) & IS1_INSTR_L2(1) & 
    IS1_INSTR_L2(2) & IS1_INSTR_L2(5) & 
    IS1_INSTR_L2(21) & IS1_INSTR_L2(22) & 
    IS1_INSTR_L2(23) & IS1_INSTR_L2(24) & 
    IS1_INSTR_L2(25) & IS1_INSTR_L2(26) & 
    IS1_INSTR_L2(27) & IS1_INSTR_L2(29) & 
    IS1_INSTR_L2(30) ) , STD_ULOGIC_VECTOR'("0111010111011"));
MQQ261:INSTRUCTION_DECODER2_PT(62) <=
    Eq(( IS1_INSTR_L2(0) & IS1_INSTR_L2(1) & 
    IS1_INSTR_L2(2) & IS1_INSTR_L2(5) & 
    IS1_INSTR_L2(21) & IS1_INSTR_L2(22) & 
    IS1_INSTR_L2(25) & IS1_INSTR_L2(26) & 
    IS1_INSTR_L2(27) & IS1_INSTR_L2(29) & 
    IS1_INSTR_L2(30) & IS1_INSTR_L2(31)
     ) , STD_ULOGIC_VECTOR'("011111010101"));
MQQ262:INSTRUCTION_DECODER2_PT(63) <=
    Eq(( IS1_INSTR_L2(0) & IS1_INSTR_L2(1) & 
    IS1_INSTR_L2(2) & IS1_INSTR_L2(5) & 
    IS1_INSTR_L2(21) & IS1_INSTR_L2(22) & 
    IS1_INSTR_L2(23) & IS1_INSTR_L2(24) & 
    IS1_INSTR_L2(26) & IS1_INSTR_L2(27) & 
    IS1_INSTR_L2(28) & IS1_INSTR_L2(29) & 
    IS1_INSTR_L2(30) ) , STD_ULOGIC_VECTOR'("0111000100011"));
MQQ263:INSTRUCTION_DECODER2_PT(64) <=
    Eq(( IS1_INSTR_L2(0) & IS1_INSTR_L2(1) & 
    IS1_INSTR_L2(2) & IS1_INSTR_L2(5) & 
    IS1_INSTR_L2(21) & IS1_INSTR_L2(22) & 
    IS1_INSTR_L2(23) & IS1_INSTR_L2(24) & 
    IS1_INSTR_L2(25) & IS1_INSTR_L2(26) & 
    IS1_INSTR_L2(27) & IS1_INSTR_L2(28) & 
    IS1_INSTR_L2(30) ) , STD_ULOGIC_VECTOR'("0111001001000"));
MQQ264:INSTRUCTION_DECODER2_PT(65) <=
    Eq(( IS1_INSTR_L2(0) & IS1_INSTR_L2(1) & 
    IS1_INSTR_L2(2) & IS1_INSTR_L2(5) & 
    IS1_INSTR_L2(21) & IS1_INSTR_L2(22) & 
    IS1_INSTR_L2(23) & IS1_INSTR_L2(24) & 
    IS1_INSTR_L2(26) & IS1_INSTR_L2(27) & 
    IS1_INSTR_L2(28) & IS1_INSTR_L2(29)
     ) , STD_ULOGIC_VECTOR'("011100110111"));
MQQ265:INSTRUCTION_DECODER2_PT(66) <=
    Eq(( IS1_INSTR_L2(0) & IS1_INSTR_L2(1) & 
    IS1_INSTR_L2(2) & IS1_INSTR_L2(5) & 
    IS1_INSTR_L2(22) & IS1_INSTR_L2(23) & 
    IS1_INSTR_L2(25) & IS1_INSTR_L2(26) & 
    IS1_INSTR_L2(27) & IS1_INSTR_L2(28) & 
    IS1_INSTR_L2(29) & IS1_INSTR_L2(30)
     ) , STD_ULOGIC_VECTOR'("011100101000"));
MQQ266:INSTRUCTION_DECODER2_PT(67) <=
    Eq(( CORE64 & IS1_INSTR_L2(0) & 
    IS1_INSTR_L2(1) & IS1_INSTR_L2(2) & 
    IS1_INSTR_L2(21) & IS1_INSTR_L2(22) & 
    IS1_INSTR_L2(24) & IS1_INSTR_L2(25) & 
    IS1_INSTR_L2(26) & IS1_INSTR_L2(27) & 
    IS1_INSTR_L2(28) & IS1_INSTR_L2(30)
     ) , STD_ULOGIC_VECTOR'("101100011011"));
MQQ267:INSTRUCTION_DECODER2_PT(68) <=
    Eq(( IS1_INSTR_L2(0) & IS1_INSTR_L2(1) & 
    IS1_INSTR_L2(2) & IS1_INSTR_L2(5) & 
    IS1_INSTR_L2(21) & IS1_INSTR_L2(22) & 
    IS1_INSTR_L2(25) & IS1_INSTR_L2(26) & 
    IS1_INSTR_L2(27) & IS1_INSTR_L2(28) & 
    IS1_INSTR_L2(29) & IS1_INSTR_L2(30)
     ) , STD_ULOGIC_VECTOR'("011110010101"));
MQQ268:INSTRUCTION_DECODER2_PT(69) <=
    Eq(( IS1_INSTR_L2(0) & IS1_INSTR_L2(1) & 
    IS1_INSTR_L2(2) & IS1_INSTR_L2(5) & 
    IS1_INSTR_L2(22) & IS1_INSTR_L2(23) & 
    IS1_INSTR_L2(24) & IS1_INSTR_L2(25) & 
    IS1_INSTR_L2(26) & IS1_INSTR_L2(28) & 
    IS1_INSTR_L2(29) & IS1_INSTR_L2(30)
     ) , STD_ULOGIC_VECTOR'("011100000000"));
MQQ269:INSTRUCTION_DECODER2_PT(70) <=
    Eq(( IS1_INSTR_L2(0) & IS1_INSTR_L2(1) & 
    IS1_INSTR_L2(2) & IS1_INSTR_L2(5) & 
    IS1_INSTR_L2(21) & IS1_INSTR_L2(23) & 
    IS1_INSTR_L2(24) & IS1_INSTR_L2(25) & 
    IS1_INSTR_L2(26) & IS1_INSTR_L2(27) & 
    IS1_INSTR_L2(28) & IS1_INSTR_L2(29)
     ) , STD_ULOGIC_VECTOR'("011100001011"));
MQQ270:INSTRUCTION_DECODER2_PT(71) <=
    Eq(( IS1_INSTR_L2(0) & IS1_INSTR_L2(1) & 
    IS1_INSTR_L2(2) & IS1_INSTR_L2(5) & 
    IS1_INSTR_L2(21) & IS1_INSTR_L2(22) & 
    IS1_INSTR_L2(23) & IS1_INSTR_L2(25) & 
    IS1_INSTR_L2(26) & IS1_INSTR_L2(27) & 
    IS1_INSTR_L2(29) & IS1_INSTR_L2(30)
     ) , STD_ULOGIC_VECTOR'("011111101010"));
MQQ271:INSTRUCTION_DECODER2_PT(72) <=
    Eq(( IS1_INSTR_L2(0) & IS1_INSTR_L2(1) & 
    IS1_INSTR_L2(2) & IS1_INSTR_L2(5) & 
    IS1_INSTR_L2(21) & IS1_INSTR_L2(22) & 
    IS1_INSTR_L2(23) & IS1_INSTR_L2(26) & 
    IS1_INSTR_L2(27) & IS1_INSTR_L2(28) & 
    IS1_INSTR_L2(29) & IS1_INSTR_L2(30)
     ) , STD_ULOGIC_VECTOR'("011111110110"));
MQQ272:INSTRUCTION_DECODER2_PT(73) <=
    Eq(( IS1_INSTR_L2(0) & IS1_INSTR_L2(1) & 
    IS1_INSTR_L2(2) & IS1_INSTR_L2(5) & 
    IS1_INSTR_L2(21) & IS1_INSTR_L2(22) & 
    IS1_INSTR_L2(23) & IS1_INSTR_L2(25) & 
    IS1_INSTR_L2(26) & IS1_INSTR_L2(27) & 
    IS1_INSTR_L2(28) & IS1_INSTR_L2(29)
     ) , STD_ULOGIC_VECTOR'("011100001011"));
MQQ273:INSTRUCTION_DECODER2_PT(74) <=
    Eq(( IS1_INSTR_L2(0) & IS1_INSTR_L2(1) & 
    IS1_INSTR_L2(2) & IS1_INSTR_L2(5) & 
    IS1_INSTR_L2(21) & IS1_INSTR_L2(22) & 
    IS1_INSTR_L2(24) & IS1_INSTR_L2(25) & 
    IS1_INSTR_L2(26) & IS1_INSTR_L2(27) & 
    IS1_INSTR_L2(28) & IS1_INSTR_L2(29) & 
    IS1_INSTR_L2(30) ) , STD_ULOGIC_VECTOR'("0111001010011"));
MQQ274:INSTRUCTION_DECODER2_PT(75) <=
    Eq(( CORE64 & IS1_INSTR_L2(0) & 
    IS1_INSTR_L2(1) & IS1_INSTR_L2(2) & 
    IS1_INSTR_L2(5) & IS1_INSTR_L2(22) & 
    IS1_INSTR_L2(23) & IS1_INSTR_L2(26) & 
    IS1_INSTR_L2(27) & IS1_INSTR_L2(28) & 
    IS1_INSTR_L2(30) ) , STD_ULOGIC_VECTOR'("10111110101"));
MQQ275:INSTRUCTION_DECODER2_PT(76) <=
    Eq(( CORE64 & IS1_INSTR_L2(0) & 
    IS1_INSTR_L2(1) & IS1_INSTR_L2(2) & 
    IS1_INSTR_L2(5) & IS1_INSTR_L2(21) & 
    IS1_INSTR_L2(22) & IS1_INSTR_L2(24) & 
    IS1_INSTR_L2(25) & IS1_INSTR_L2(26) & 
    IS1_INSTR_L2(28) & IS1_INSTR_L2(30)
     ) , STD_ULOGIC_VECTOR'("101110000111"));
MQQ276:INSTRUCTION_DECODER2_PT(77) <=
    Eq(( IS1_INSTR_L2(0) & IS1_INSTR_L2(1) & 
    IS1_INSTR_L2(2) & IS1_INSTR_L2(5) & 
    IS1_INSTR_L2(22) & IS1_INSTR_L2(23) & 
    IS1_INSTR_L2(24) & IS1_INSTR_L2(25) & 
    IS1_INSTR_L2(27) & IS1_INSTR_L2(28) & 
    IS1_INSTR_L2(29) & IS1_INSTR_L2(30)
     ) , STD_ULOGIC_VECTOR'("011100001000"));
MQQ277:INSTRUCTION_DECODER2_PT(78) <=
    Eq(( IS1_INSTR_L2(0) & IS1_INSTR_L2(1) & 
    IS1_INSTR_L2(2) & IS1_INSTR_L2(5) & 
    IS1_INSTR_L2(21) & IS1_INSTR_L2(22) & 
    IS1_INSTR_L2(23) & IS1_INSTR_L2(26) & 
    IS1_INSTR_L2(27) & IS1_INSTR_L2(28) & 
    IS1_INSTR_L2(29) & IS1_INSTR_L2(30)
     ) , STD_ULOGIC_VECTOR'("011101111100"));
MQQ278:INSTRUCTION_DECODER2_PT(79) <=
    Eq(( IS1_INSTR_L2(0) & IS1_INSTR_L2(1) & 
    IS1_INSTR_L2(2) & IS1_INSTR_L2(5) & 
    IS1_INSTR_L2(23) & IS1_INSTR_L2(24) & 
    IS1_INSTR_L2(25) & IS1_INSTR_L2(26) & 
    IS1_INSTR_L2(27) & IS1_INSTR_L2(29) & 
    IS1_INSTR_L2(30) ) , STD_ULOGIC_VECTOR'("01111110111"));
MQQ279:INSTRUCTION_DECODER2_PT(80) <=
    Eq(( IS1_INSTR_L2(0) & IS1_INSTR_L2(1) & 
    IS1_INSTR_L2(2) & IS1_INSTR_L2(5) & 
    IS1_INSTR_L2(21) & IS1_INSTR_L2(22) & 
    IS1_INSTR_L2(23) & IS1_INSTR_L2(24) & 
    IS1_INSTR_L2(26) & IS1_INSTR_L2(28) & 
    IS1_INSTR_L2(29) & IS1_INSTR_L2(30)
     ) , STD_ULOGIC_VECTOR'("011111101010"));
MQQ280:INSTRUCTION_DECODER2_PT(81) <=
    Eq(( IS1_INSTR_L2(0) & IS1_INSTR_L2(1) & 
    IS1_INSTR_L2(2) & IS1_INSTR_L2(5) & 
    IS1_INSTR_L2(23) & IS1_INSTR_L2(24) & 
    IS1_INSTR_L2(25) & IS1_INSTR_L2(26) & 
    IS1_INSTR_L2(27) & IS1_INSTR_L2(28) & 
    IS1_INSTR_L2(29) & IS1_INSTR_L2(30)
     ) , STD_ULOGIC_VECTOR'("011100001010"));
MQQ281:INSTRUCTION_DECODER2_PT(82) <=
    Eq(( IS1_INSTR_L2(0) & IS1_INSTR_L2(1) & 
    IS1_INSTR_L2(2) & IS1_INSTR_L2(5) & 
    IS1_INSTR_L2(21) & IS1_INSTR_L2(22) & 
    IS1_INSTR_L2(25) & IS1_INSTR_L2(26) & 
    IS1_INSTR_L2(27) & IS1_INSTR_L2(28) & 
    IS1_INSTR_L2(29) & IS1_INSTR_L2(30)
     ) , STD_ULOGIC_VECTOR'("011101000011"));
MQQ282:INSTRUCTION_DECODER2_PT(83) <=
    Eq(( IS1_INSTR_L2(0) & IS1_INSTR_L2(1) & 
    IS1_INSTR_L2(2) & IS1_INSTR_L2(5) & 
    IS1_INSTR_L2(21) & IS1_INSTR_L2(23) & 
    IS1_INSTR_L2(24) & IS1_INSTR_L2(26) & 
    IS1_INSTR_L2(28) & IS1_INSTR_L2(29) & 
    IS1_INSTR_L2(30) ) , STD_ULOGIC_VECTOR'("01110001111"));
MQQ283:INSTRUCTION_DECODER2_PT(84) <=
    Eq(( IS1_INSTR_L2(0) & IS1_INSTR_L2(1) & 
    IS1_INSTR_L2(2) & IS1_INSTR_L2(3) & 
    IS1_INSTR_L2(4) & IS1_INSTR_L2(5) & 
    IS1_INSTR_L2(26) & IS1_INSTR_L2(27) & 
    IS1_INSTR_L2(28) & IS1_INSTR_L2(29) & 
    IS1_INSTR_L2(30) ) , STD_ULOGIC_VECTOR'("01111101111"));
MQQ284:INSTRUCTION_DECODER2_PT(85) <=
    Eq(( IS1_INSTR_L2(0) & IS1_INSTR_L2(1) & 
    IS1_INSTR_L2(2) & IS1_INSTR_L2(5) & 
    IS1_INSTR_L2(21) & IS1_INSTR_L2(22) & 
    IS1_INSTR_L2(23) & IS1_INSTR_L2(24) & 
    IS1_INSTR_L2(25) & IS1_INSTR_L2(26) & 
    IS1_INSTR_L2(28) & IS1_INSTR_L2(29)
     ) , STD_ULOGIC_VECTOR'("011100001111"));
MQQ285:INSTRUCTION_DECODER2_PT(86) <=
    Eq(( IS1_INSTR_L2(0) & IS1_INSTR_L2(1) & 
    IS1_INSTR_L2(2) & IS1_INSTR_L2(5) & 
    IS1_INSTR_L2(21) & IS1_INSTR_L2(22) & 
    IS1_INSTR_L2(23) & IS1_INSTR_L2(24) & 
    IS1_INSTR_L2(26) & IS1_INSTR_L2(28) & 
    IS1_INSTR_L2(29) & IS1_INSTR_L2(30)
     ) , STD_ULOGIC_VECTOR'("011100000000"));
MQQ286:INSTRUCTION_DECODER2_PT(87) <=
    Eq(( IS1_INSTR_L2(0) & IS1_INSTR_L2(1) & 
    IS1_INSTR_L2(2) & IS1_INSTR_L2(5) & 
    IS1_INSTR_L2(21) & IS1_INSTR_L2(23) & 
    IS1_INSTR_L2(24) & IS1_INSTR_L2(26) & 
    IS1_INSTR_L2(27) & IS1_INSTR_L2(28) & 
    IS1_INSTR_L2(29) & IS1_INSTR_L2(30)
     ) , STD_ULOGIC_VECTOR'("011100011100"));
MQQ287:INSTRUCTION_DECODER2_PT(88) <=
    Eq(( IS1_INSTR_L2(0) & IS1_INSTR_L2(1) & 
    IS1_INSTR_L2(2) & IS1_INSTR_L2(5) & 
    IS1_INSTR_L2(22) & IS1_INSTR_L2(23) & 
    IS1_INSTR_L2(24) & IS1_INSTR_L2(26) & 
    IS1_INSTR_L2(27) & IS1_INSTR_L2(28) & 
    IS1_INSTR_L2(29) & IS1_INSTR_L2(30)
     ) , STD_ULOGIC_VECTOR'("011100010110"));
MQQ288:INSTRUCTION_DECODER2_PT(89) <=
    Eq(( IS1_INSTR_L2(0) & IS1_INSTR_L2(1) & 
    IS1_INSTR_L2(2) & IS1_INSTR_L2(5) & 
    IS1_INSTR_L2(22) & IS1_INSTR_L2(23) & 
    IS1_INSTR_L2(24) & IS1_INSTR_L2(26) & 
    IS1_INSTR_L2(27) & IS1_INSTR_L2(28) & 
    IS1_INSTR_L2(30) ) , STD_ULOGIC_VECTOR'("01110110100"));
MQQ289:INSTRUCTION_DECODER2_PT(90) <=
    Eq(( IS1_INSTR_L2(0) & IS1_INSTR_L2(1) & 
    IS1_INSTR_L2(2) & IS1_INSTR_L2(5) & 
    IS1_INSTR_L2(21) & IS1_INSTR_L2(22) & 
    IS1_INSTR_L2(24) & IS1_INSTR_L2(25) & 
    IS1_INSTR_L2(26) & IS1_INSTR_L2(28) & 
    IS1_INSTR_L2(29) & IS1_INSTR_L2(30)
     ) , STD_ULOGIC_VECTOR'("011100001010"));
MQQ290:INSTRUCTION_DECODER2_PT(91) <=
    Eq(( IS1_INSTR_L2(0) & IS1_INSTR_L2(1) & 
    IS1_INSTR_L2(2) & IS1_INSTR_L2(5) & 
    IS1_INSTR_L2(22) & IS1_INSTR_L2(23) & 
    IS1_INSTR_L2(25) & IS1_INSTR_L2(26) & 
    IS1_INSTR_L2(27) & IS1_INSTR_L2(28) & 
    IS1_INSTR_L2(30) ) , STD_ULOGIC_VECTOR'("01110100100"));
MQQ291:INSTRUCTION_DECODER2_PT(92) <=
    Eq(( IS1_INSTR_L2(0) & IS1_INSTR_L2(1) & 
    IS1_INSTR_L2(2) & IS1_INSTR_L2(5) & 
    IS1_INSTR_L2(22) & IS1_INSTR_L2(23) & 
    IS1_INSTR_L2(25) & IS1_INSTR_L2(26) & 
    IS1_INSTR_L2(27) & IS1_INSTR_L2(29) & 
    IS1_INSTR_L2(30) ) , STD_ULOGIC_VECTOR'("01110000111"));
MQQ292:INSTRUCTION_DECODER2_PT(93) <=
    Eq(( IS1_INSTR_L2(0) & IS1_INSTR_L2(1) & 
    IS1_INSTR_L2(2) & IS1_INSTR_L2(5) & 
    IS1_INSTR_L2(22) & IS1_INSTR_L2(23) & 
    IS1_INSTR_L2(25) & IS1_INSTR_L2(27) & 
    IS1_INSTR_L2(28) & IS1_INSTR_L2(29) & 
    IS1_INSTR_L2(30) ) , STD_ULOGIC_VECTOR'("01111100110"));
MQQ293:INSTRUCTION_DECODER2_PT(94) <=
    Eq(( IS1_INSTR_L2(0) & IS1_INSTR_L2(1) & 
    IS1_INSTR_L2(2) & IS1_INSTR_L2(5) & 
    IS1_INSTR_L2(21) & IS1_INSTR_L2(23) & 
    IS1_INSTR_L2(24) & IS1_INSTR_L2(26) & 
    IS1_INSTR_L2(27) & IS1_INSTR_L2(28) & 
    IS1_INSTR_L2(29) & IS1_INSTR_L2(30)
     ) , STD_ULOGIC_VECTOR'("011101010111"));
MQQ294:INSTRUCTION_DECODER2_PT(95) <=
    Eq(( IS1_INSTR_L2(0) & IS1_INSTR_L2(1) & 
    IS1_INSTR_L2(2) & IS1_INSTR_L2(5) & 
    IS1_INSTR_L2(21) & IS1_INSTR_L2(24) & 
    IS1_INSTR_L2(25) & IS1_INSTR_L2(26) & 
    IS1_INSTR_L2(27) & IS1_INSTR_L2(29) & 
    IS1_INSTR_L2(30) ) , STD_ULOGIC_VECTOR'("01111001010"));
MQQ295:INSTRUCTION_DECODER2_PT(96) <=
    Eq(( IS1_INSTR_L2(0) & IS1_INSTR_L2(1) & 
    IS1_INSTR_L2(2) & IS1_INSTR_L2(5) & 
    IS1_INSTR_L2(21) & IS1_INSTR_L2(22) & 
    IS1_INSTR_L2(26) & IS1_INSTR_L2(27) & 
    IS1_INSTR_L2(28) & IS1_INSTR_L2(29) & 
    IS1_INSTR_L2(30) ) , STD_ULOGIC_VECTOR'("01111010010"));
MQQ296:INSTRUCTION_DECODER2_PT(97) <=
    Eq(( IS1_INSTR_L2(0) & IS1_INSTR_L2(1) & 
    IS1_INSTR_L2(2) & IS1_INSTR_L2(5) & 
    IS1_INSTR_L2(22) & IS1_INSTR_L2(23) & 
    IS1_INSTR_L2(26) & IS1_INSTR_L2(27) & 
    IS1_INSTR_L2(29) & IS1_INSTR_L2(30)
     ) , STD_ULOGIC_VECTOR'("0111110111"));
MQQ297:INSTRUCTION_DECODER2_PT(98) <=
    Eq(( IS1_INSTR_L2(0) & IS1_INSTR_L2(1) & 
    IS1_INSTR_L2(2) & IS1_INSTR_L2(5) & 
    IS1_INSTR_L2(21) & IS1_INSTR_L2(22) & 
    IS1_INSTR_L2(24) & IS1_INSTR_L2(26) & 
    IS1_INSTR_L2(28) & IS1_INSTR_L2(29) & 
    IS1_INSTR_L2(30) ) , STD_ULOGIC_VECTOR'("01110011111"));
MQQ298:INSTRUCTION_DECODER2_PT(99) <=
    Eq(( IS1_INSTR_L2(0) & IS1_INSTR_L2(1) & 
    IS1_INSTR_L2(2) & IS1_INSTR_L2(5) & 
    IS1_INSTR_L2(21) & IS1_INSTR_L2(24) & 
    IS1_INSTR_L2(26) & IS1_INSTR_L2(27) & 
    IS1_INSTR_L2(28) & IS1_INSTR_L2(29) & 
    IS1_INSTR_L2(30) ) , STD_ULOGIC_VECTOR'("01110000011"));
MQQ299:INSTRUCTION_DECODER2_PT(100) <=
    Eq(( IS1_INSTR_L2(0) & IS1_INSTR_L2(1) & 
    IS1_INSTR_L2(2) & IS1_INSTR_L2(5) & 
    IS1_INSTR_L2(21) & IS1_INSTR_L2(24) & 
    IS1_INSTR_L2(25) & IS1_INSTR_L2(26) & 
    IS1_INSTR_L2(28) & IS1_INSTR_L2(29) & 
    IS1_INSTR_L2(30) ) , STD_ULOGIC_VECTOR'("01110001111"));
MQQ300:INSTRUCTION_DECODER2_PT(101) <=
    Eq(( CORE64 & IS1_INSTR_L2(2) & 
    IS1_INSTR_L2(3) & IS1_INSTR_L2(4) & 
    IS1_INSTR_L2(5) & IS1_INSTR_L2(31)
     ) , STD_ULOGIC_VECTOR'("110100"));
MQQ301:INSTRUCTION_DECODER2_PT(102) <=
    Eq(( IS1_INSTR_L2(0) & IS1_INSTR_L2(1) & 
    IS1_INSTR_L2(2) & IS1_INSTR_L2(5) & 
    IS1_INSTR_L2(21) & IS1_INSTR_L2(23) & 
    IS1_INSTR_L2(26) & IS1_INSTR_L2(27) & 
    IS1_INSTR_L2(28) & IS1_INSTR_L2(29) & 
    IS1_INSTR_L2(30) ) , STD_ULOGIC_VECTOR'("01110010111"));
MQQ302:INSTRUCTION_DECODER2_PT(103) <=
    Eq(( IS1_INSTR_L2(0) & IS1_INSTR_L2(1) & 
    IS1_INSTR_L2(2) & IS1_INSTR_L2(5) & 
    IS1_INSTR_L2(21) & IS1_INSTR_L2(22) & 
    IS1_INSTR_L2(24) & IS1_INSTR_L2(26) & 
    IS1_INSTR_L2(27) & IS1_INSTR_L2(29) & 
    IS1_INSTR_L2(30) ) , STD_ULOGIC_VECTOR'("01110001011"));
MQQ303:INSTRUCTION_DECODER2_PT(104) <=
    Eq(( IS1_INSTR_L2(0) & IS1_INSTR_L2(1) & 
    IS1_INSTR_L2(3) & IS1_INSTR_L2(5)
     ) , STD_ULOGIC_VECTOR'("1010"));
MQQ304:INSTRUCTION_DECODER2_PT(105) <=
    Eq(( CORE64 & IS1_INSTR_L2(1) & 
    IS1_INSTR_L2(3) & IS1_INSTR_L2(4)
     ) , STD_ULOGIC_VECTOR'("1001"));
MQQ305:INSTRUCTION_DECODER2_PT(106) <=
    Eq(( CORE64 & IS1_INSTR_L2(0) & 
    IS1_INSTR_L2(2) & IS1_INSTR_L2(4) & 
    IS1_INSTR_L2(5) & IS1_INSTR_L2(30)
     ) , STD_ULOGIC_VECTOR'("111100"));
MQQ306:INSTRUCTION_DECODER2_PT(107) <=
    Eq(( IS1_INSTR_L2(0) & IS1_INSTR_L2(1) & 
    IS1_INSTR_L2(2) & IS1_INSTR_L2(3) & 
    IS1_INSTR_L2(4) & IS1_INSTR_L2(5)
     ) , STD_ULOGIC_VECTOR'("000111"));
MQQ307:INSTRUCTION_DECODER2_PT(108) <=
    Eq(( IS1_INSTR_L2(0) & IS1_INSTR_L2(1) & 
    IS1_INSTR_L2(3) ) , STD_ULOGIC_VECTOR'("101"));
MQQ308:INSTRUCTION_DECODER2_PT(109) <=
    Eq(( CORE64 & IS1_INSTR_L2(0) & 
    IS1_INSTR_L2(2) & IS1_INSTR_L2(5) & 
    IS1_INSTR_L2(28) & IS1_INSTR_L2(29)
     ) , STD_ULOGIC_VECTOR'("101000"));
MQQ309:INSTRUCTION_DECODER2_PT(110) <=
    Eq(( IS1_INSTR_L2(0) & IS1_INSTR_L2(1) & 
    IS1_INSTR_L2(2) & IS1_INSTR_L2(3) & 
    IS1_INSTR_L2(4) ) , STD_ULOGIC_VECTOR'("01100"));
MQQ310:INSTRUCTION_DECODER2_PT(111) <=
    Eq(( IS1_INSTR_L2(0) & IS1_INSTR_L2(1) & 
    IS1_INSTR_L2(2) & IS1_INSTR_L2(3) & 
    IS1_INSTR_L2(5) ) , STD_ULOGIC_VECTOR'("01100"));
MQQ311:INSTRUCTION_DECODER2_PT(112) <=
    Eq(( IS1_INSTR_L2(1) & IS1_INSTR_L2(3) & 
    IS1_INSTR_L2(4) & IS1_INSTR_L2(5)
     ) , STD_ULOGIC_VECTOR'("0011"));
MQQ312:INSTRUCTION_DECODER2_PT(113) <=
    Eq(( CORE64 & IS1_INSTR_L2(0) & 
    IS1_INSTR_L2(2) & IS1_INSTR_L2(5) & 
    IS1_INSTR_L2(27) ) , STD_ULOGIC_VECTOR'("10100"));
MQQ313:INSTRUCTION_DECODER2_PT(114) <=
    Eq(( IS1_INSTR_L2(0) & IS1_INSTR_L2(1) & 
    IS1_INSTR_L2(3) & IS1_INSTR_L2(5)
     ) , STD_ULOGIC_VECTOR'("0100"));
MQQ314:INSTRUCTION_DECODER2_PT(115) <=
    Eq(( IS1_INSTR_L2(0) & IS1_INSTR_L2(1) & 
    IS1_INSTR_L2(2) & IS1_INSTR_L2(3) & 
    IS1_INSTR_L2(5) ) , STD_ULOGIC_VECTOR'("01011"));
MQQ315:INSTRUCTION_DECODER2_PT(116) <=
    Eq(( IS1_INSTR_L2(0) & IS1_INSTR_L2(1)
     ) , STD_ULOGIC_VECTOR'("10"));
MQQ316:INSTRUCTION_DECODER2_PT(117) <=
    Eq(( IS1_INSTR_L2(0) & IS1_INSTR_L2(1) & 
    IS1_INSTR_L2(2) & IS1_INSTR_L2(5)
     ) , STD_ULOGIC_VECTOR'("0010"));
MQQ317:INSTRUCTION_DECODER2_PT(118) <=
    Eq(( IS1_INSTR_L2(0) & IS1_INSTR_L2(1) & 
    IS1_INSTR_L2(4) & IS1_INSTR_L2(30)
     ) , STD_ULOGIC_VECTOR'("0101"));
MQQ318:INSTRUCTION_DECODER2_PT(119) <=
    Eq(( IS1_INSTR_L2(0) & IS1_INSTR_L2(1) & 
    IS1_INSTR_L2(3) & IS1_INSTR_L2(4)
     ) , STD_ULOGIC_VECTOR'("0110"));
MQQ319:INSTRUCTION_DECODER2_PT(120) <=
    Eq(( IS1_INSTR_L2(1) & IS1_INSTR_L2(2) & 
    IS1_INSTR_L2(3) ) , STD_ULOGIC_VECTOR'("011"));
MQQ320:INSTRUCTION_DECODER2_PT(121) <=
    Eq(( IS1_INSTR_L2(0) & IS1_INSTR_L2(1) & 
    IS1_INSTR_L2(2) & IS1_INSTR_L2(3)
     ) , STD_ULOGIC_VECTOR'("0110"));
-- Table INSTRUCTION_DECODER2 Signal Assignments for Outputs
MQQ321:ISFXUISSUE <= 
    (INSTRUCTION_DECODER2_PT(1) OR INSTRUCTION_DECODER2_PT(2)
     OR INSTRUCTION_DECODER2_PT(3) OR INSTRUCTION_DECODER2_PT(10)
     OR INSTRUCTION_DECODER2_PT(11) OR INSTRUCTION_DECODER2_PT(12)
     OR INSTRUCTION_DECODER2_PT(13) OR INSTRUCTION_DECODER2_PT(14)
     OR INSTRUCTION_DECODER2_PT(15) OR INSTRUCTION_DECODER2_PT(16)
     OR INSTRUCTION_DECODER2_PT(17) OR INSTRUCTION_DECODER2_PT(18)
     OR INSTRUCTION_DECODER2_PT(19) OR INSTRUCTION_DECODER2_PT(20)
     OR INSTRUCTION_DECODER2_PT(21) OR INSTRUCTION_DECODER2_PT(22)
     OR INSTRUCTION_DECODER2_PT(23) OR INSTRUCTION_DECODER2_PT(24)
     OR INSTRUCTION_DECODER2_PT(25) OR INSTRUCTION_DECODER2_PT(26)
     OR INSTRUCTION_DECODER2_PT(27) OR INSTRUCTION_DECODER2_PT(28)
     OR INSTRUCTION_DECODER2_PT(29) OR INSTRUCTION_DECODER2_PT(30)
     OR INSTRUCTION_DECODER2_PT(31) OR INSTRUCTION_DECODER2_PT(32)
     OR INSTRUCTION_DECODER2_PT(33) OR INSTRUCTION_DECODER2_PT(34)
     OR INSTRUCTION_DECODER2_PT(35) OR INSTRUCTION_DECODER2_PT(36)
     OR INSTRUCTION_DECODER2_PT(37) OR INSTRUCTION_DECODER2_PT(38)
     OR INSTRUCTION_DECODER2_PT(39) OR INSTRUCTION_DECODER2_PT(40)
     OR INSTRUCTION_DECODER2_PT(42) OR INSTRUCTION_DECODER2_PT(43)
     OR INSTRUCTION_DECODER2_PT(44) OR INSTRUCTION_DECODER2_PT(45)
     OR INSTRUCTION_DECODER2_PT(46) OR INSTRUCTION_DECODER2_PT(47)
     OR INSTRUCTION_DECODER2_PT(48) OR INSTRUCTION_DECODER2_PT(49)
     OR INSTRUCTION_DECODER2_PT(50) OR INSTRUCTION_DECODER2_PT(52)
     OR INSTRUCTION_DECODER2_PT(53) OR INSTRUCTION_DECODER2_PT(54)
     OR INSTRUCTION_DECODER2_PT(55) OR INSTRUCTION_DECODER2_PT(56)
     OR INSTRUCTION_DECODER2_PT(57) OR INSTRUCTION_DECODER2_PT(59)
     OR INSTRUCTION_DECODER2_PT(60) OR INSTRUCTION_DECODER2_PT(61)
     OR INSTRUCTION_DECODER2_PT(62) OR INSTRUCTION_DECODER2_PT(63)
     OR INSTRUCTION_DECODER2_PT(64) OR INSTRUCTION_DECODER2_PT(65)
     OR INSTRUCTION_DECODER2_PT(66) OR INSTRUCTION_DECODER2_PT(67)
     OR INSTRUCTION_DECODER2_PT(68) OR INSTRUCTION_DECODER2_PT(69)
     OR INSTRUCTION_DECODER2_PT(70) OR INSTRUCTION_DECODER2_PT(71)
     OR INSTRUCTION_DECODER2_PT(72) OR INSTRUCTION_DECODER2_PT(73)
     OR INSTRUCTION_DECODER2_PT(74) OR INSTRUCTION_DECODER2_PT(75)
     OR INSTRUCTION_DECODER2_PT(76) OR INSTRUCTION_DECODER2_PT(77)
     OR INSTRUCTION_DECODER2_PT(78) OR INSTRUCTION_DECODER2_PT(79)
     OR INSTRUCTION_DECODER2_PT(80) OR INSTRUCTION_DECODER2_PT(81)
     OR INSTRUCTION_DECODER2_PT(82) OR INSTRUCTION_DECODER2_PT(83)
     OR INSTRUCTION_DECODER2_PT(84) OR INSTRUCTION_DECODER2_PT(85)
     OR INSTRUCTION_DECODER2_PT(86) OR INSTRUCTION_DECODER2_PT(87)
     OR INSTRUCTION_DECODER2_PT(88) OR INSTRUCTION_DECODER2_PT(89)
     OR INSTRUCTION_DECODER2_PT(90) OR INSTRUCTION_DECODER2_PT(91)
     OR INSTRUCTION_DECODER2_PT(92) OR INSTRUCTION_DECODER2_PT(93)
     OR INSTRUCTION_DECODER2_PT(94) OR INSTRUCTION_DECODER2_PT(95)
     OR INSTRUCTION_DECODER2_PT(96) OR INSTRUCTION_DECODER2_PT(97)
     OR INSTRUCTION_DECODER2_PT(98) OR INSTRUCTION_DECODER2_PT(99)
     OR INSTRUCTION_DECODER2_PT(100) OR INSTRUCTION_DECODER2_PT(101)
     OR INSTRUCTION_DECODER2_PT(102) OR INSTRUCTION_DECODER2_PT(103)
     OR INSTRUCTION_DECODER2_PT(105) OR INSTRUCTION_DECODER2_PT(106)
     OR INSTRUCTION_DECODER2_PT(107) OR INSTRUCTION_DECODER2_PT(109)
     OR INSTRUCTION_DECODER2_PT(112) OR INSTRUCTION_DECODER2_PT(113)
     OR INSTRUCTION_DECODER2_PT(114) OR INSTRUCTION_DECODER2_PT(115)
     OR INSTRUCTION_DECODER2_PT(116) OR INSTRUCTION_DECODER2_PT(117)
     OR INSTRUCTION_DECODER2_PT(118) OR INSTRUCTION_DECODER2_PT(119)
     OR INSTRUCTION_DECODER2_PT(120) OR INSTRUCTION_DECODER2_PT(121)
    );
MQQ322:HOLE_DELAY(1) <= 
    (INSTRUCTION_DECODER2_PT(107));
MQQ323:HOLE_DELAY(2) <= 
    (INSTRUCTION_DECODER2_PT(3));
MQQ324:HOLE_DELAY(3) <= 
    (INSTRUCTION_DECODER2_PT(2) OR INSTRUCTION_DECODER2_PT(14)
    );
MQQ325:COMPL_EX(1) <= 
    (INSTRUCTION_DECODER2_PT(4) OR INSTRUCTION_DECODER2_PT(5)
     OR INSTRUCTION_DECODER2_PT(6) OR INSTRUCTION_DECODER2_PT(7)
     OR INSTRUCTION_DECODER2_PT(8) OR INSTRUCTION_DECODER2_PT(9)
     OR INSTRUCTION_DECODER2_PT(11) OR INSTRUCTION_DECODER2_PT(12)
     OR INSTRUCTION_DECODER2_PT(13) OR INSTRUCTION_DECODER2_PT(15)
     OR INSTRUCTION_DECODER2_PT(16) OR INSTRUCTION_DECODER2_PT(17)
     OR INSTRUCTION_DECODER2_PT(18) OR INSTRUCTION_DECODER2_PT(20)
     OR INSTRUCTION_DECODER2_PT(21) OR INSTRUCTION_DECODER2_PT(23)
     OR INSTRUCTION_DECODER2_PT(84) OR INSTRUCTION_DECODER2_PT(104)
     OR INSTRUCTION_DECODER2_PT(110) OR INSTRUCTION_DECODER2_PT(111)
    );
MQQ326:COMPL_EX(2) <= 
    (INSTRUCTION_DECODER2_PT(27) OR INSTRUCTION_DECODER2_PT(40)
     OR INSTRUCTION_DECODER2_PT(43) OR INSTRUCTION_DECODER2_PT(45)
     OR INSTRUCTION_DECODER2_PT(47) OR INSTRUCTION_DECODER2_PT(51)
     OR INSTRUCTION_DECODER2_PT(56) OR INSTRUCTION_DECODER2_PT(58)
     OR INSTRUCTION_DECODER2_PT(66) OR INSTRUCTION_DECODER2_PT(67)
     OR INSTRUCTION_DECODER2_PT(77) OR INSTRUCTION_DECODER2_PT(78)
     OR INSTRUCTION_DECODER2_PT(80) OR INSTRUCTION_DECODER2_PT(81)
     OR INSTRUCTION_DECODER2_PT(86) OR INSTRUCTION_DECODER2_PT(87)
     OR INSTRUCTION_DECODER2_PT(89) OR INSTRUCTION_DECODER2_PT(91)
     OR INSTRUCTION_DECODER2_PT(94) OR INSTRUCTION_DECODER2_PT(108)
     OR INSTRUCTION_DECODER2_PT(109) OR INSTRUCTION_DECODER2_PT(112)
     OR INSTRUCTION_DECODER2_PT(113) OR INSTRUCTION_DECODER2_PT(115)
     OR INSTRUCTION_DECODER2_PT(117) OR INSTRUCTION_DECODER2_PT(119)
     OR INSTRUCTION_DECODER2_PT(120) OR INSTRUCTION_DECODER2_PT(121)
    );
MQQ327:COMPL_EX(3) <= 
    ('0');
MQQ328:COMPL_EX(4) <= 
    (INSTRUCTION_DECODER2_PT(31) OR INSTRUCTION_DECODER2_PT(32)
     OR INSTRUCTION_DECODER2_PT(33) OR INSTRUCTION_DECODER2_PT(34)
     OR INSTRUCTION_DECODER2_PT(35) OR INSTRUCTION_DECODER2_PT(36)
     OR INSTRUCTION_DECODER2_PT(37) OR INSTRUCTION_DECODER2_PT(38)
     OR INSTRUCTION_DECODER2_PT(39) OR INSTRUCTION_DECODER2_PT(61)
     OR INSTRUCTION_DECODER2_PT(74));
MQQ329:COMPL_EX(5) <= 
    (INSTRUCTION_DECODER2_PT(30) OR INSTRUCTION_DECODER2_PT(41)
     OR INSTRUCTION_DECODER2_PT(63) OR INSTRUCTION_DECODER2_PT(79)
     OR INSTRUCTION_DECODER2_PT(92));

--
-- Final Table Listing
--      *INPUTS*=====================*OUTPUTS*==*
--      |                            |          |
--      | core64                     |          |
--      | |                          |          |
--      | | is1_instr_L2             | to_uc    |
--      | | |      is1_instr_L2      | |        |
--      | | |      |                 | |        |
--      | | |      22222222233       | |        |
--      | | 012345 12345678901       | |        |
--      *TYPE*=======================+==========+
--      | P PPPPPP PPPPPPPPPPP       | S        |
--      *POLARITY*------------------>| +        |
--      *PHASE*--------------------->| T        |
--      *TERMS*======================+==========+
--    1 | 1 011111 00-0-11010-       | 1        |
--    2 | 1 011111 01-1111010-       | 1        |
--    3 | - 011111 1000000000-       | 1        |
--    4 | 1 011111 01011101-1-       | 1        |
--    5 | 1 011111 0011111100-       | 1        |
--    6 | - 011111 10--010101-       | 1        |
--    7 | - 011111 00-0011010-       | 1        |
--    8 | 1 011111 00001101-1-       | 1        |
--    9 | - 011111 0-01111010-       | 1        |
--   10 | - 011111 0-0-110111-       | 1        |
--   11 | 1 111010 ---------01       | 1        |
--   12 | - 10-0-1 -----------       | 1        |
--   13 | - 10111- -----------       | 1        |
--      *=======================================*
--
-- Table MICROCODE Signal Assignments for Product Terms
MQQ330:MICROCODE_PT(1) <=
    Eq(( CORE64 & IS1_INSTR_L2(0) & 
    IS1_INSTR_L2(1) & IS1_INSTR_L2(2) & 
    IS1_INSTR_L2(3) & IS1_INSTR_L2(4) & 
    IS1_INSTR_L2(5) & IS1_INSTR_L2(21) & 
    IS1_INSTR_L2(22) & IS1_INSTR_L2(24) & 
    IS1_INSTR_L2(26) & IS1_INSTR_L2(27) & 
    IS1_INSTR_L2(28) & IS1_INSTR_L2(29) & 
    IS1_INSTR_L2(30) ) , STD_ULOGIC_VECTOR'("101111100011010"));
MQQ331:MICROCODE_PT(2) <=
    Eq(( CORE64 & IS1_INSTR_L2(0) & 
    IS1_INSTR_L2(1) & IS1_INSTR_L2(2) & 
    IS1_INSTR_L2(3) & IS1_INSTR_L2(4) & 
    IS1_INSTR_L2(5) & IS1_INSTR_L2(21) & 
    IS1_INSTR_L2(22) & IS1_INSTR_L2(24) & 
    IS1_INSTR_L2(25) & IS1_INSTR_L2(26) & 
    IS1_INSTR_L2(27) & IS1_INSTR_L2(28) & 
    IS1_INSTR_L2(29) & IS1_INSTR_L2(30)
     ) , STD_ULOGIC_VECTOR'("1011111011111010"));
MQQ332:MICROCODE_PT(3) <=
    Eq(( IS1_INSTR_L2(0) & IS1_INSTR_L2(1) & 
    IS1_INSTR_L2(2) & IS1_INSTR_L2(3) & 
    IS1_INSTR_L2(4) & IS1_INSTR_L2(5) & 
    IS1_INSTR_L2(21) & IS1_INSTR_L2(22) & 
    IS1_INSTR_L2(23) & IS1_INSTR_L2(24) & 
    IS1_INSTR_L2(25) & IS1_INSTR_L2(26) & 
    IS1_INSTR_L2(27) & IS1_INSTR_L2(28) & 
    IS1_INSTR_L2(29) & IS1_INSTR_L2(30)
     ) , STD_ULOGIC_VECTOR'("0111111000000000"));
MQQ333:MICROCODE_PT(4) <=
    Eq(( CORE64 & IS1_INSTR_L2(0) & 
    IS1_INSTR_L2(1) & IS1_INSTR_L2(2) & 
    IS1_INSTR_L2(3) & IS1_INSTR_L2(4) & 
    IS1_INSTR_L2(5) & IS1_INSTR_L2(21) & 
    IS1_INSTR_L2(22) & IS1_INSTR_L2(23) & 
    IS1_INSTR_L2(24) & IS1_INSTR_L2(25) & 
    IS1_INSTR_L2(26) & IS1_INSTR_L2(27) & 
    IS1_INSTR_L2(28) & IS1_INSTR_L2(30)
     ) , STD_ULOGIC_VECTOR'("1011111010111011"));
MQQ334:MICROCODE_PT(5) <=
    Eq(( CORE64 & IS1_INSTR_L2(0) & 
    IS1_INSTR_L2(1) & IS1_INSTR_L2(2) & 
    IS1_INSTR_L2(3) & IS1_INSTR_L2(4) & 
    IS1_INSTR_L2(5) & IS1_INSTR_L2(21) & 
    IS1_INSTR_L2(22) & IS1_INSTR_L2(23) & 
    IS1_INSTR_L2(24) & IS1_INSTR_L2(25) & 
    IS1_INSTR_L2(26) & IS1_INSTR_L2(27) & 
    IS1_INSTR_L2(28) & IS1_INSTR_L2(29) & 
    IS1_INSTR_L2(30) ) , STD_ULOGIC_VECTOR'("10111110011111100"));
MQQ335:MICROCODE_PT(6) <=
    Eq(( IS1_INSTR_L2(0) & IS1_INSTR_L2(1) & 
    IS1_INSTR_L2(2) & IS1_INSTR_L2(3) & 
    IS1_INSTR_L2(4) & IS1_INSTR_L2(5) & 
    IS1_INSTR_L2(21) & IS1_INSTR_L2(22) & 
    IS1_INSTR_L2(25) & IS1_INSTR_L2(26) & 
    IS1_INSTR_L2(27) & IS1_INSTR_L2(28) & 
    IS1_INSTR_L2(29) & IS1_INSTR_L2(30)
     ) , STD_ULOGIC_VECTOR'("01111110010101"));
MQQ336:MICROCODE_PT(7) <=
    Eq(( IS1_INSTR_L2(0) & IS1_INSTR_L2(1) & 
    IS1_INSTR_L2(2) & IS1_INSTR_L2(3) & 
    IS1_INSTR_L2(4) & IS1_INSTR_L2(5) & 
    IS1_INSTR_L2(21) & IS1_INSTR_L2(22) & 
    IS1_INSTR_L2(24) & IS1_INSTR_L2(25) & 
    IS1_INSTR_L2(26) & IS1_INSTR_L2(27) & 
    IS1_INSTR_L2(28) & IS1_INSTR_L2(29) & 
    IS1_INSTR_L2(30) ) , STD_ULOGIC_VECTOR'("011111000011010"));
MQQ337:MICROCODE_PT(8) <=
    Eq(( CORE64 & IS1_INSTR_L2(0) & 
    IS1_INSTR_L2(1) & IS1_INSTR_L2(2) & 
    IS1_INSTR_L2(3) & IS1_INSTR_L2(4) & 
    IS1_INSTR_L2(5) & IS1_INSTR_L2(21) & 
    IS1_INSTR_L2(22) & IS1_INSTR_L2(23) & 
    IS1_INSTR_L2(24) & IS1_INSTR_L2(25) & 
    IS1_INSTR_L2(26) & IS1_INSTR_L2(27) & 
    IS1_INSTR_L2(28) & IS1_INSTR_L2(30)
     ) , STD_ULOGIC_VECTOR'("1011111000011011"));
MQQ338:MICROCODE_PT(9) <=
    Eq(( IS1_INSTR_L2(0) & IS1_INSTR_L2(1) & 
    IS1_INSTR_L2(2) & IS1_INSTR_L2(3) & 
    IS1_INSTR_L2(4) & IS1_INSTR_L2(5) & 
    IS1_INSTR_L2(21) & IS1_INSTR_L2(23) & 
    IS1_INSTR_L2(24) & IS1_INSTR_L2(25) & 
    IS1_INSTR_L2(26) & IS1_INSTR_L2(27) & 
    IS1_INSTR_L2(28) & IS1_INSTR_L2(29) & 
    IS1_INSTR_L2(30) ) , STD_ULOGIC_VECTOR'("011111001111010"));
MQQ339:MICROCODE_PT(10) <=
    Eq(( IS1_INSTR_L2(0) & IS1_INSTR_L2(1) & 
    IS1_INSTR_L2(2) & IS1_INSTR_L2(3) & 
    IS1_INSTR_L2(4) & IS1_INSTR_L2(5) & 
    IS1_INSTR_L2(21) & IS1_INSTR_L2(23) & 
    IS1_INSTR_L2(25) & IS1_INSTR_L2(26) & 
    IS1_INSTR_L2(27) & IS1_INSTR_L2(28) & 
    IS1_INSTR_L2(29) & IS1_INSTR_L2(30)
     ) , STD_ULOGIC_VECTOR'("01111100110111"));
MQQ340:MICROCODE_PT(11) <=
    Eq(( CORE64 & IS1_INSTR_L2(0) & 
    IS1_INSTR_L2(1) & IS1_INSTR_L2(2) & 
    IS1_INSTR_L2(3) & IS1_INSTR_L2(4) & 
    IS1_INSTR_L2(5) & IS1_INSTR_L2(30) & 
    IS1_INSTR_L2(31) ) , STD_ULOGIC_VECTOR'("111101001"));
MQQ341:MICROCODE_PT(12) <=
    Eq(( IS1_INSTR_L2(0) & IS1_INSTR_L2(1) & 
    IS1_INSTR_L2(3) & IS1_INSTR_L2(5)
     ) , STD_ULOGIC_VECTOR'("1001"));
MQQ342:MICROCODE_PT(13) <=
    Eq(( IS1_INSTR_L2(0) & IS1_INSTR_L2(1) & 
    IS1_INSTR_L2(2) & IS1_INSTR_L2(3) & 
    IS1_INSTR_L2(4) ) , STD_ULOGIC_VECTOR'("10111"));
-- Table MICROCODE Signal Assignments for Outputs
MQQ343:TO_UC <= 
    (MICROCODE_PT(1) OR MICROCODE_PT(2)
     OR MICROCODE_PT(3) OR MICROCODE_PT(4)
     OR MICROCODE_PT(5) OR MICROCODE_PT(6)
     OR MICROCODE_PT(7) OR MICROCODE_PT(8)
     OR MICROCODE_PT(9) OR MICROCODE_PT(10)
     OR MICROCODE_PT(11) OR MICROCODE_PT(12)
     OR MICROCODE_PT(13));

is1_UpdatesLR_din     <=  UpdatesLR;
is1_UpdatesCR_din     <=  UpdatesCR;
is1_UpdatesCTR_din    <=  UpdatesCTR;
is1_UpdatesXER_din    <=  UpdatesXER;
is1_UpdatesMSR_din    <=  UpdatesMSR;
is1_UpdatesSPR_din    <=  UpdatesSPR;
is1_UsesLR_din        <=  UsesLR;
is1_UsesCR_din        <=  UsesCR;
is1_UsesCTR_din       <=  UsesCTR;
is1_UsesXER_din       <=  UsesXER;
is1_UsesMSR_din       <=  UsesMSR;
is1_UsesSPR_din       <=  UsesSPR;
is1_vld_din           <=  iu_au_ib1_instr_vld;
is1_vld_type_din(0) <=  au_iu_is0_to_ucode;
is1_vld_type_din(1) <=  au_ib1_ld_or_st;
is1_vld_type_din(2) <=  not au_iu_i_dec;
is1_ifar_din          <=  iu_au_ib1_ifar;
is1_instr_din(0 TO 31) <=  iu_au_ib1_instr(0 to 31);
is1_axu_instr_din(6 TO 31) <=  au_iu_ib1_ldst_indexed       &
                                   au_iu_ib1_ldst_tag(0 to 8)   &
                                   au_iu_ib1_ldst_dimm(0 to 15) ;
with ta_sel select is1_ta_d0  <= 
      iu_au_ib1_instr_ucode_ext(0) & iu_au_ib1_instr(6 to 10)   when '0',
      iu_au_ib1_instr_ucode_ext(0) & iu_au_ib1_instr(11 to 15)  when others;
is1_ta_vld_din        <=  ta_vld;
is1_ta_din            <=  au_iu_ib1_ldst_ra(1 to 6) when (au_iu_ib1_ldst_update  = '1' or au_iu_ib1_mftgpr = '1') else is1_ta_d0;
with s1_sel select is1_s1_d0  <= 
      iu_au_ib1_instr_ucode_ext(1) & iu_au_ib1_instr(11 to 15)  when '0',                
      iu_au_ib1_instr_ucode_ext(1) & iu_au_ib1_instr(6 to 10)   when others;
is1_s1_vld_din        <=  s1_vld;
is1_s1_din            <=  au_iu_ib1_ldst_ra(1 to 6) when au_iu_ib1_ldst = '1' else is1_s1_d0;
with s2_sel select is1_s2_d0  <= 
      iu_au_ib1_instr_ucode_ext(2) & iu_au_ib1_instr(16 to 20)  when '0',   
      iu_au_ib1_instr_ucode_ext(2) & iu_au_ib1_instr(11 to 15)  when others;
is1_s2_vld_din        <=  s2_vld;
is1_s2_din            <=  au_iu_ib1_ldst_rb(1 to 6) when au_iu_ib1_ldst_rb_v = '1' else is1_s2_d0;
with s3_sel select is1_s3_d0  <= 
      iu_au_ib1_instr_ucode_ext(3) & iu_au_ib1_instr(6 to 10)   when '0',           
      iu_au_ib1_instr_ucode_ext(3) & iu_au_ib1_instr(16 to 20)  when others;
is1_s3_vld_din        <=  s3_vld;
is1_s3_din            <=  au_iu_ib1_ldst_rb(1 to 6) when au_iu_ib1_mffgpr = '1' else is1_s3_d0;
is1_pred_update_din           <=  iu_au_ib1_instr_pred_vld;
is1_pred_taken_cnt_din        <=  iu_au_ib1_instr_pred_taken_cnt;
is1_gshare_din                <=  iu_au_ib1_instr_gshare;
is1_ld_vld_din                 <=  ld_vld;
is1_to_ucode_din              <=  au_iu_is0_to_ucode;
is1_is_ucode_din              <=  iu_au_ib1_instr_is_ucode;
is1_axu_ld_or_st_din          <=  au_ib1_ld_or_st;
is1_axu_store_din             <=  au_ib1_store;
is1_axu_ldst_size_din         <=  au_iu_ib1_ldst_size;
is1_axu_ldst_update_din       <=  au_iu_ib1_ldst_update;
is1_axu_ldst_extpid_din       <=  au_iu_ib1_ldst_extpid;
is1_axu_ldst_forcealign_din   <=  au_iu_ib1_ldst_forcealign;
is1_axu_ldst_forceexcept_din  <=  au_iu_ib1_ldst_forceexcept;
is1_axu_mftgpr_din            <=  au_iu_ib1_mftgpr;
is1_axu_mffgpr_din            <=  au_iu_ib1_mffgpr;
is1_axu_movedp_din           <=  au_iu_ib1_movedp;
is1_axu_instr_type_din        <=  au_iu_ib1_instr_type;
is1_error_din(0 TO 2) <=  iu_au_ib1_instr_error(0 to 2);
is1_force_ram_din             <=  iu_au_ib1_instr_force_ram;
is1_2ucode_din                <=  iu_au_ib1_instr_2ucode;
is1_2ucode_type_din           <=  iu_au_ib1_instr_2ucode_type;
is1_axu_ldst_ra_v_din         <=  au_iu_ib1_ldst_ra_v;
is1_axu_ldst_rb_v_din         <=  au_iu_ib1_ldst_rb_v;
is1_instr_proc : process (

xu_iu_ib1_flush,
iu_au_is1_stall,
is1_vld_din,
is1_vld_type_din,
is1_instr_din,
is1_axu_instr_din,
is1_ta_vld_din,          
is1_ta_din,              
is1_s1_vld_din,          
is1_s1_din,              
is1_s2_vld_din,          
is1_s2_din,              
is1_s3_vld_din,          
is1_s3_din,              
is1_pred_update_din,     
is1_pred_taken_cnt_din,  
is1_gshare_din,  

is1_UpdatesLR_din,       
is1_UpdatesCR_din,       
is1_UpdatesCTR_din,      
is1_UpdatesXER_din,      
is1_UpdatesMSR_din,      
is1_UpdatesSPR_din,      
is1_UsesLR_din,          
is1_UsesCR_din,          
is1_UsesCTR_din,         
is1_UsesXER_din,         
is1_UsesMSR_din,         
is1_UsesSPR_din,         

is1_ld_vld_din,           
is1_to_ucode_din,        
is1_is_ucode_din,        

is1_ifar_din,            
is1_error_din,
is1_axu_ldst_ra_v_din,        
is1_axu_ldst_rb_v_din,        
is1_axu_ld_or_st_din,    
is1_axu_store_din,       
is1_axu_ldst_size_din,   
is1_axu_ldst_update_din,
is1_axu_ldst_extpid_din,
is1_axu_ldst_forcealign_din,
is1_axu_ldst_forceexcept_din,
is1_axu_mftgpr_din,
is1_axu_mffgpr_din,
is1_axu_movedp_din,
is1_axu_instr_type_din,

is1_force_ram_din,
is1_2ucode_din,
is1_2ucode_type_din,
is1_vld_L2,
is1_vld_type_L2,
is1_instr_L2,
is1_axu_instr_L2,
is1_ta_vld_L2,          
is1_ta_L2,              
is1_s1_vld_L2,          
is1_s1_L2,              
is1_s2_vld_L2,          
is1_s2_L2,              
is1_s3_vld_L2,          
is1_s3_L2,              
is1_pred_update_L2,     
is1_pred_taken_cnt_L2,  
is1_gshare_L2,  

is1_UpdatesLR_L2,       
is1_UpdatesCR_L2,       
is1_UpdatesCTR_L2,      
is1_UpdatesXER_L2,      
is1_UpdatesMSR_L2,      
is1_UpdatesSPR_L2,      
is1_UsesLR_L2,          
is1_UsesCR_L2,          
is1_UsesCTR_L2,         
is1_UsesXER_L2,         
is1_UsesMSR_L2,         
is1_UsesSPR_L2,         

is1_ld_vld_L2,           
is1_to_ucode_L2,        
is1_is_ucode_L2,        

is1_ifar_L2,            
is1_error_L2,        
is1_axu_ldst_ra_v_L2,        
is1_axu_ldst_rb_v_L2,        
is1_axu_ld_or_st_L2,    
is1_axu_store_L2,       
is1_axu_ldst_size_L2,   
is1_axu_ldst_update_L2,
is1_axu_ldst_extpid_L2,
is1_axu_ldst_forcealign_L2,
is1_axu_ldst_forceexcept_L2,
is1_axu_mftgpr_L2,
is1_axu_mffgpr_L2,
is1_axu_movedp_L2,
is1_axu_instr_type_L2,

is1_force_ram_L2,
is1_2ucode_L2,
is1_2ucode_type_L2
)

begin

is1_vld_d              <=  is1_vld_din;
is1_vld_type_d         <=  is1_vld_type_din;
is1_instr_d            <=  is1_instr_din;
is1_axu_instr_d        <=  is1_axu_instr_din;
is1_ta_vld_d           <=  is1_ta_vld_din;
is1_ta_d               <=  is1_ta_din;
is1_s1_vld_d           <=  is1_s1_vld_din;
is1_s1_d               <=  is1_s1_din;
is1_s2_vld_d           <=  is1_s2_vld_din;
is1_s2_d               <=  is1_s2_din;
is1_s3_vld_d           <=  is1_s3_vld_din;
is1_s3_d               <=  is1_s3_din;
is1_pred_update_d      <=  is1_pred_update_din;
is1_pred_taken_cnt_d   <=  is1_pred_taken_cnt_din;
is1_gshare_d           <=  is1_gshare_din;
is1_UpdatesLR_d        <=  is1_UpdatesLR_din;
is1_UpdatesCR_d        <=  is1_UpdatesCR_din;
is1_UpdatesCTR_d       <=  is1_UpdatesCTR_din;
is1_UpdatesXER_d       <=  is1_UpdatesXER_din;
is1_UpdatesMSR_d       <=  is1_UpdatesMSR_din;
is1_UpdatesSPR_d       <=  is1_UpdatesSPR_din;
is1_UsesLR_d           <=  is1_UsesLR_din;
is1_UsesCR_d           <=  is1_UsesCR_din;
is1_UsesCTR_d          <=  is1_UsesCTR_din;
is1_UsesXER_d          <=  is1_UsesXER_din;
is1_UsesMSR_d          <=  is1_UsesMSR_din;
is1_UsesSPR_d          <=  is1_UsesSPR_din;
is1_ld_vld_d            <=  is1_ld_vld_din;
is1_to_ucode_d         <=  is1_to_ucode_din;
is1_is_ucode_d         <=  is1_is_ucode_din;
is1_ifar_d             <=  is1_ifar_din;
is1_error_d            <=  is1_error_din;
is1_axu_ldst_ra_v_d    <=  is1_axu_ldst_ra_v_din;
is1_axu_ldst_rb_v_d    <=  is1_axu_ldst_rb_v_din;
is1_axu_ld_or_st_d     <=  is1_axu_ld_or_st_din;
is1_axu_store_d        <=  is1_axu_store_din;
is1_axu_ldst_size_d    <=  is1_axu_ldst_size_din;
is1_axu_ldst_update_d  <=  is1_axu_ldst_update_din;
is1_axu_ldst_extpid_d  <=  is1_axu_ldst_extpid_din;
is1_axu_ldst_forcealign_d        <=  is1_axu_ldst_forcealign_din;
is1_axu_ldst_forceexcept_d       <=  is1_axu_ldst_forceexcept_din;
is1_axu_mftgpr_d         <=  is1_axu_mftgpr_din;
is1_axu_mffgpr_d         <=  is1_axu_mffgpr_din;
is1_axu_movedp_d        <=  is1_axu_movedp_din;
is1_axu_instr_type_d     <=  is1_axu_instr_type_din;
is1_force_ram_d          <=  is1_force_ram_din;
is1_2ucode_d             <=  is1_2ucode_din;
is1_2ucode_type_d        <=  is1_2ucode_type_din;
if (iu_au_is1_stall = '1') then
is1_vld_d              <=  is1_vld_l2;
is1_vld_type_d         <=  is1_vld_type_l2;
is1_instr_d            <=  is1_instr_l2;
is1_axu_instr_d        <=  is1_axu_instr_l2;
is1_ta_vld_d           <=  is1_ta_vld_l2;
is1_ta_d               <=  is1_ta_l2;
is1_s1_vld_d           <=  is1_s1_vld_l2;
is1_s1_d               <=  is1_s1_l2;
is1_s2_vld_d           <=  is1_s2_vld_l2;
is1_s2_d               <=  is1_s2_l2;
is1_s3_vld_d           <=  is1_s3_vld_l2;
is1_s3_d               <=  is1_s3_l2;
is1_pred_update_d      <=  is1_pred_update_l2;
is1_pred_taken_cnt_d   <=  is1_pred_taken_cnt_l2;
is1_gshare_d           <=  is1_gshare_l2;
is1_UpdatesLR_d        <=  is1_UpdatesLR_l2;
is1_UpdatesCR_d        <=  is1_UpdatesCR_l2;
is1_UpdatesCTR_d       <=  is1_UpdatesCTR_l2;
is1_UpdatesXER_d       <=  is1_UpdatesXER_l2;
is1_UpdatesMSR_d       <=  is1_UpdatesMSR_l2;
is1_UpdatesSPR_d       <=  is1_UpdatesSPR_l2;
is1_UsesLR_d           <=  is1_UsesLR_l2;
is1_UsesCR_d           <=  is1_UsesCR_l2;
is1_UsesCTR_d          <=  is1_UsesCTR_l2;
is1_UsesXER_d          <=  is1_UsesXER_l2;
is1_UsesMSR_d          <=  is1_UsesMSR_l2;
is1_UsesSPR_d          <=  is1_UsesSPR_l2;
is1_ld_vld_d            <=  is1_ld_vld_l2;
is1_to_ucode_d         <=  is1_to_ucode_l2;
is1_is_ucode_d         <=  is1_is_ucode_l2;
is1_ifar_d             <=  is1_ifar_l2;
is1_error_d            <=  is1_error_l2;
is1_axu_ldst_ra_v_d    <=  is1_axu_ldst_ra_v_l2;
is1_axu_ldst_rb_v_d    <=  is1_axu_ldst_rb_v_l2;
is1_axu_ld_or_st_d     <=  is1_axu_ld_or_st_l2;
is1_axu_store_d        <=  is1_axu_store_l2;
is1_axu_ldst_size_d    <=  is1_axu_ldst_size_l2;
is1_axu_ldst_update_d  <=  is1_axu_ldst_update_l2;
is1_axu_ldst_extpid_d  <=  is1_axu_ldst_extpid_l2;
is1_axu_ldst_forcealign_d        <=  is1_axu_ldst_forcealign_l2;
is1_axu_ldst_forceexcept_d       <=  is1_axu_ldst_forceexcept_l2;
is1_axu_mftgpr_d         <=  is1_axu_mftgpr_l2;
is1_axu_mffgpr_d         <=  is1_axu_mffgpr_l2;
is1_axu_movedp_d        <=  is1_axu_movedp_l2;
is1_axu_instr_type_d     <=  is1_axu_instr_type_l2;
is1_force_ram_d          <=  is1_force_ram_l2;
is1_2ucode_d             <=  is1_2ucode_l2;
is1_2ucode_type_d        <=  is1_2ucode_type_l2;
end if;
if (xu_iu_ib1_flush = '1') then
is1_vld_d              <=  '0';
end if;
end process is1_instr_proc;
act_valid  <=  tiup;
act_nonvalid     <=  not fdep_fdec_weak_stall;
is1_vld: tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type)
  port map (vd          => vdd,
            gd          => gnd,
            nclk    => nclk,
            act     => act_valid,
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(is1_vld_offset),
            scout   => sov(is1_vld_offset),
            din     => is1_vld_d,
            dout    => is1_vld_l2);
is1_vld_type: tri_rlmreg_p
  generic map (width => is1_vld_type_l2'length, init => 0, expand_type => expand_type)
  port map (vd          => vdd,
            gd          => gnd,
            nclk    => nclk,
            act     => act_nonvalid,
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(is1_vld_type_offset to is1_vld_type_offset + is1_vld_type_l2'length-1),
            scout   => sov(is1_vld_type_offset to is1_vld_type_offset + is1_vld_type_l2'length-1),
            din     => is1_vld_type_d,
            dout    => is1_vld_type_l2);
is1_instr: tri_rlmreg_p
  generic map (width => is1_instr_l2'length, init => 0, expand_type => expand_type)
  port map (vd          => vdd,
            gd          => gnd,
            nclk    => nclk,
            act     => act_nonvalid,
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(is1_instr_offset to is1_instr_offset + is1_instr_l2'length-1),
            scout   => sov(is1_instr_offset to is1_instr_offset + is1_instr_l2'length-1),
            din     => is1_instr_d,
            dout    => is1_instr_l2);
is1_axu_instr: tri_rlmreg_p
  generic map (width => is1_axu_instr_l2'length, init => 0, expand_type => expand_type)
  port map (vd          => vdd,
            gd          => gnd,
            nclk    => nclk,
            act     => act_nonvalid,
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(is1_axu_instr_offset to is1_axu_instr_offset + is1_axu_instr_l2'length-1),
            scout   => sov(is1_axu_instr_offset to is1_axu_instr_offset + is1_axu_instr_l2'length-1),
            din     => is1_axu_instr_d,
            dout    => is1_axu_instr_l2);
is1_ta_vld: tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type)
  port map (vd          => vdd,
            gd          => gnd,
            nclk    => nclk,
            act     => act_nonvalid,
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(is1_ta_vld_offset),
            scout   => sov(is1_ta_vld_offset),
            din     => is1_ta_vld_d,
            dout    => is1_ta_vld_l2);
is1_ta: tri_rlmreg_p
  generic map (width => is1_ta_l2'length, init => 0, expand_type => expand_type)
  port map (vd          => vdd,
            gd          => gnd,
            nclk    => nclk,
            act     => act_nonvalid,
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(is1_ta_offset to is1_ta_offset + is1_ta_l2'length-1),
            scout   => sov(is1_ta_offset to is1_ta_offset + is1_ta_l2'length-1),
            din     => is1_ta_d,
            dout    => is1_ta_l2);
is1_s1_vld:   tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type)
  port map (vd          => vdd,
            gd          => gnd,
            nclk    => nclk,
            act     => act_nonvalid,
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(is1_s1_vld_offset),
            scout   => sov(is1_s1_vld_offset),
            din     => is1_s1_vld_d,
            dout    => is1_s1_vld_l2);
is1_s1:   tri_rlmreg_p
  generic map (width => is1_s1_l2'length,   init => 0, expand_type => expand_type)
  port map (vd          => vdd,
            gd          => gnd,
            nclk    => nclk,
            act     => act_nonvalid,
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(is1_s1_offset   to is1_s1_offset   + is1_s1_l2'length-1),
            scout   => sov(is1_s1_offset   to is1_s1_offset   + is1_s1_l2'length-1),
            din     => is1_s1_d,
            dout    => is1_s1_l2);
is1_s2_vld:   tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type)
  port map (vd          => vdd,
            gd          => gnd,
            nclk    => nclk,
            act     => act_nonvalid,
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(is1_s2_vld_offset),
            scout   => sov(is1_s2_vld_offset),
            din     => is1_s2_vld_d,
            dout    => is1_s2_vld_l2);
is1_s2:   tri_rlmreg_p
  generic map (width => is1_s2_l2'length,   init => 0, expand_type => expand_type)
  port map (vd          => vdd,
            gd          => gnd,
            nclk    => nclk,
            act     => act_nonvalid,
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(is1_s2_offset   to is1_s2_offset   + is1_s2_l2'length-1),
            scout   => sov(is1_s2_offset   to is1_s2_offset   + is1_s2_l2'length-1),
            din     => is1_s2_d,
            dout    => is1_s2_l2);
is1_s3_vld:   tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type)
  port map (vd          => vdd,
            gd          => gnd,
            nclk    => nclk,
            act     => act_nonvalid,
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(is1_s3_vld_offset),
            scout   => sov(is1_s3_vld_offset),
            din     => is1_s3_vld_d,
            dout    => is1_s3_vld_l2);
is1_s3:   tri_rlmreg_p
  generic map (width => is1_s3_l2'length,   init => 0, expand_type => expand_type)
  port map (vd          => vdd,
            gd          => gnd,
            nclk    => nclk,
            act     => act_nonvalid,
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(is1_s3_offset   to is1_s3_offset   + is1_s3_l2'length-1),
            scout   => sov(is1_s3_offset   to is1_s3_offset   + is1_s3_l2'length-1),
            din     => is1_s3_d,
            dout    => is1_s3_l2);
is1_pred_update: tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type)
  port map (vd          => vdd,
            gd          => gnd,
            nclk    => nclk,
            act     => act_nonvalid,
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(is1_pred_update_offset),
            scout   => sov(is1_pred_update_offset),
            din     => is1_pred_update_d,
            dout    => is1_pred_update_l2);
is1_pred_taken_cnt: tri_rlmreg_p
  generic map (width => is1_pred_taken_cnt_l2'length, init => 0, expand_type => expand_type)
  port map (vd          => vdd,
            gd          => gnd,
            nclk    => nclk,
            act     => act_nonvalid,
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(is1_pred_taken_cnt_offset to is1_pred_taken_cnt_offset + is1_pred_taken_cnt_l2'length-1),
            scout   => sov(is1_pred_taken_cnt_offset to is1_pred_taken_cnt_offset + is1_pred_taken_cnt_l2'length-1),
            din     => is1_pred_taken_cnt_d,
            dout    => is1_pred_taken_cnt_l2);
is1_gshare: tri_rlmreg_p
  generic map (width => is1_gshare_l2'length, init => 0, expand_type => expand_type)
  port map (vd          => vdd,
            gd          => gnd,
            nclk    => nclk,
            act     => act_nonvalid,
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(is1_gshare_offset to is1_gshare_offset + is1_gshare_l2'length-1),
            scout   => sov(is1_gshare_offset to is1_gshare_offset + is1_gshare_l2'length-1),
            din     => is1_gshare_d,
            dout    => is1_gshare_l2);
is1_UpdatesLR: tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type)
  port map (vd          => vdd,
            gd          => gnd,
            nclk    => nclk,
            act     => act_nonvalid,
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(is1_UpdatesLR_offset),
            scout   => sov(is1_UpdatesLR_offset),
            din     => is1_UpdatesLR_d,
            dout    => is1_UpdatesLR_l2);
is1_UpdatesCR: tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type)
  port map (vd          => vdd,
            gd          => gnd,
            nclk    => nclk,
            act     => act_nonvalid,
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(is1_UpdatesCR_offset),
            scout   => sov(is1_UpdatesCR_offset),
            din     => is1_UpdatesCR_d,
            dout    => is1_UpdatesCR_l2);
is1_UpdatesCTR: tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type)
  port map (vd          => vdd,
            gd          => gnd,
            nclk    => nclk,
            act     => act_nonvalid,
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(is1_UpdatesCTR_offset),
            scout   => sov(is1_UpdatesCTR_offset),
            din     => is1_UpdatesCTR_d,
            dout    => is1_UpdatesCTR_l2);
is1_UpdatesXER: tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type)
  port map (vd          => vdd,
            gd          => gnd,
            nclk    => nclk,
            act     => act_nonvalid,
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(is1_UpdatesXER_offset),
            scout   => sov(is1_UpdatesXER_offset),
            din     => is1_UpdatesXER_d,
            dout    => is1_UpdatesXER_l2);
is1_UpdatesMSR: tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type)
  port map (vd          => vdd,
            gd          => gnd,
            nclk    => nclk,
            act     => act_nonvalid,
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(is1_UpdatesMSR_offset),
            scout   => sov(is1_UpdatesMSR_offset),
            din     => is1_UpdatesMSR_d,
            dout    => is1_UpdatesMSR_l2);
is1_UpdatesSPR: tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type)
  port map (vd          => vdd,
            gd          => gnd,
            nclk    => nclk,
            act     => act_nonvalid,
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(is1_UpdatesSPR_offset),
            scout   => sov(is1_UpdatesSPR_offset),
            din     => is1_UpdatesSPR_d,
            dout    => is1_UpdatesSPR_l2);
is1_UsesLR: tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type)
  port map (vd          => vdd,
            gd          => gnd,
            nclk    => nclk,
            act     => act_nonvalid,
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(is1_UsesLR_offset),
            scout   => sov(is1_UsesLR_offset),
            din     => is1_UsesLR_d,
            dout    => is1_UsesLR_l2);
is1_UsesCR: tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type)
  port map (vd          => vdd,
            gd          => gnd,
            nclk    => nclk,
            act     => act_nonvalid,
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(is1_UsesCR_offset),
            scout   => sov(is1_UsesCR_offset),
            din     => is1_UsesCR_d,
            dout    => is1_UsesCR_l2);
is1_UsesCTR: tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type)
  port map (vd          => vdd,
            gd          => gnd,
            nclk    => nclk,
            act     => act_nonvalid,
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(is1_UsesCTR_offset),
            scout   => sov(is1_UsesCTR_offset),
            din     => is1_UsesCTR_d,
            dout    => is1_UsesCTR_l2);
is1_UsesXER: tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type)
  port map (vd          => vdd,
            gd          => gnd,
            nclk    => nclk,
            act     => act_nonvalid,
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(is1_UsesXER_offset),
            scout   => sov(is1_UsesXER_offset),
            din     => is1_UsesXER_d,
            dout    => is1_UsesXER_l2);
is1_UsesMSR: tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type)
  port map (vd          => vdd,
            gd          => gnd,
            nclk    => nclk,
            act     => act_nonvalid,
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(is1_UsesMSR_offset),
            scout   => sov(is1_UsesMSR_offset),
            din     => is1_UsesMSR_d,
            dout    => is1_UsesMSR_l2);
is1_UsesSPR: tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type)
  port map (vd          => vdd,
            gd          => gnd,
            nclk    => nclk,
            act     => act_nonvalid,
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(is1_UsesSPR_offset),
            scout   => sov(is1_UsesSPR_offset),
            din     => is1_UsesSPR_d,
            dout    => is1_UsesSPR_l2);
is1_ld_vld: tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type)
  port map (vd          => vdd,
            gd          => gnd,
            nclk    => nclk,
            act     => act_nonvalid,
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(is1_ld_vld_offset),
            scout   => sov(is1_ld_vld_offset),
            din     => is1_ld_vld_d,
            dout    => is1_ld_vld_l2);
is1_is_ucode: tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type)
  port map (vd          => vdd,
            gd          => gnd,
            nclk    => nclk,
            act     => act_nonvalid,
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(is1_is_ucode_offset),
            scout   => sov(is1_is_ucode_offset),
            din     => is1_is_ucode_d,
            dout    => is1_is_ucode_l2);
is1_to_ucode: tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type)
  port map (vd          => vdd,
            gd          => gnd,
            nclk    => nclk,
            act     => act_nonvalid,
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(is1_to_ucode_offset),
            scout   => sov(is1_to_ucode_offset),
            din     => is1_to_ucode_d,
            dout    => is1_to_ucode_l2);
is1_ifar: tri_rlmreg_p
  generic map (width => is1_ifar_l2'length, init => 0, expand_type => expand_type)
  port map (vd          => vdd,
            gd          => gnd,
            nclk    => nclk,
            act     => act_nonvalid,
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(is1_ifar_offset to is1_ifar_offset + is1_ifar_l2'length-1),
            scout   => sov(is1_ifar_offset to is1_ifar_offset + is1_ifar_l2'length-1),
            din     => is1_ifar_d,
            dout    => is1_ifar_l2);
is1_error: tri_rlmreg_p
  generic map (width => is1_error_l2'length, init => 0, expand_type => expand_type)
  port map (vd          => vdd,
            gd          => gnd,
            nclk    => nclk,
            act     => act_nonvalid,
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(is1_error_offset to is1_error_offset + is1_error_l2'length-1),
            scout   => sov(is1_error_offset to is1_error_offset + is1_error_l2'length-1),
            din     => is1_error_d,
            dout    => is1_error_l2);
--axu
is1_axu_ldst_ra_v: tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type)
  port map (vd          => vdd,
            gd          => gnd,
            nclk    => nclk,
            act     => act_nonvalid,
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(is1_axu_ldst_ra_v_offset),
            scout   => sov(is1_axu_ldst_ra_v_offset),
            din     => is1_axu_ldst_ra_v_d,
            dout    => is1_axu_ldst_ra_v_l2);
is1_axu_ldst_rb_v: tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type)
  port map (vd          => vdd,
            gd          => gnd,
            nclk    => nclk,
            act     => act_nonvalid,
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(is1_axu_ldst_rb_v_offset),
            scout   => sov(is1_axu_ldst_rb_v_offset),
            din     => is1_axu_ldst_rb_v_d,
            dout    => is1_axu_ldst_rb_v_l2);
is1_axu_ld_or_st: tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type)
  port map (vd          => vdd,
            gd          => gnd,
            nclk    => nclk,
            act     => act_nonvalid,
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(is1_axu_ld_or_st_offset),
            scout   => sov(is1_axu_ld_or_st_offset),
            din     => is1_axu_ld_or_st_d,
            dout    => is1_axu_ld_or_st_l2);
is1_axu_store: tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type)
  port map (vd          => vdd,
            gd          => gnd,
            nclk    => nclk,
            act     => act_nonvalid,
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(is1_axu_store_offset),
            scout   => sov(is1_axu_store_offset),
            din     => is1_axu_store_d,
            dout    => is1_axu_store_l2);
is1_axu_ldst_size: tri_rlmreg_p
  generic map (width => is1_axu_ldst_size_l2'length, init => 0, expand_type => expand_type)
  port map (vd          => vdd,
            gd          => gnd,
            nclk    => nclk,
            act     => act_nonvalid,
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(is1_axu_ldst_size_offset to is1_axu_ldst_size_offset + is1_axu_ldst_size_l2'length-1),
            scout   => sov(is1_axu_ldst_size_offset to is1_axu_ldst_size_offset + is1_axu_ldst_size_l2'length-1),
            din     => is1_axu_ldst_size_d,
            dout    => is1_axu_ldst_size_l2);
is1_axu_ldst_update: tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type)
  port map (vd          => vdd,
            gd          => gnd,
            nclk    => nclk,
            act     => act_nonvalid,
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(is1_axu_ldst_update_offset),
            scout   => sov(is1_axu_ldst_update_offset),
            din     => is1_axu_ldst_update_d,
            dout    => is1_axu_ldst_update_l2);
is1_axu_ldst_extpid: tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type)
  port map (vd          => vdd,
            gd          => gnd,
            nclk    => nclk,
            act     => act_nonvalid,
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(is1_axu_ldst_extpid_offset),
            scout   => sov(is1_axu_ldst_extpid_offset),
            din     => is1_axu_ldst_extpid_d,
            dout    => is1_axu_ldst_extpid_l2);
is1_axu_ldst_forcealign: tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type)
  port map (vd          => vdd,
            gd          => gnd,
            nclk    => nclk,
            act     => act_nonvalid,
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(is1_axu_ldst_forcealign_offset),
            scout   => sov(is1_axu_ldst_forcealign_offset),
            din     => is1_axu_ldst_forcealign_d,
            dout    => is1_axu_ldst_forcealign_l2);
is1_axu_ldst_forceexcept: tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type)
  port map (vd          => vdd,
            gd          => gnd,
            nclk    => nclk,
            act     => act_nonvalid,
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(is1_axu_ldst_forceexcept_offset),
            scout   => sov(is1_axu_ldst_forceexcept_offset),
            din     => is1_axu_ldst_forceexcept_d,
            dout    => is1_axu_ldst_forceexcept_l2);
is1_axu_movedp: tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type)
  port map (vd          => vdd,
            gd          => gnd,
            nclk    => nclk,
            act     => act_nonvalid,
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(is1_axu_movedp_offset),
            scout   => sov(is1_axu_movedp_offset),
            din     => is1_axu_movedp_d,
            dout    => is1_axu_movedp_l2);
is1_axu_mffgpr: tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type)
  port map (vd          => vdd,
            gd          => gnd,
            nclk    => nclk,
            act     => act_nonvalid,
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(is1_axu_mffgpr_offset),
            scout   => sov(is1_axu_mffgpr_offset),
            din     => is1_axu_mffgpr_d,
            dout    => is1_axu_mffgpr_l2);
is1_axu_mftgpr: tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type)
  port map (vd          => vdd,
            gd          => gnd,
            nclk    => nclk,
            act     => act_nonvalid,
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(is1_axu_mftgpr_offset),
            scout   => sov(is1_axu_mftgpr_offset),
            din     => is1_axu_mftgpr_d,
            dout    => is1_axu_mftgpr_l2);
is1_axu_instr_type: tri_rlmreg_p
  generic map (width => is1_axu_instr_type_l2'length, init => 0, expand_type => expand_type)
  port map (vd          => vdd,
            gd          => gnd,
            nclk    => nclk,
            act     => act_nonvalid,
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(is1_axu_instr_type_offset to is1_axu_instr_type_offset + is1_axu_instr_type_l2'length-1),
            scout   => sov(is1_axu_instr_type_offset to is1_axu_instr_type_offset + is1_axu_instr_type_l2'length-1),
            din     => is1_axu_instr_type_d,
            dout    => is1_axu_instr_type_l2);
is1_force_ram: tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type)
  port map (vd          => vdd,
            gd          => gnd,
            nclk    => nclk,
            act     => act_nonvalid,
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(is1_force_ram_offset),
            scout   => sov(is1_force_ram_offset),
            din     => is1_force_ram_d,
            dout    => is1_force_ram_l2);
is1_2ucode: tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type)
  port map (vd          => vdd,
            gd          => gnd,
            nclk    => nclk,
            act     => act_nonvalid,
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(is1_2ucode_offset),
            scout   => sov(is1_2ucode_offset),
            din     => is1_2ucode_d,
            dout    => is1_2ucode_l2);
is1_2ucode_type: tri_rlmlatch_p
  generic map (init => 0, expand_type => expand_type)
  port map (vd          => vdd,
            gd          => gnd,
            nclk    => nclk,
            act     => act_nonvalid,
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(is1_2ucode_type_offset),
            scout   => sov(is1_2ucode_type_offset),
            din     => is1_2ucode_type_d,
            dout    => is1_2ucode_type_l2);
spare_latch: tri_rlmreg_p
  generic map (width => spare_l2'length, init => 0, expand_type => expand_type)
  port map (vd      => vdd,
            gd      => gnd,
            nclk    => nclk,
            act     => tiup,
            thold_b => pc_iu_func_sl_thold_0_b,
            sg      => pc_iu_sg_0,
            forcee => forcee,
            delay_lclkr => delay_lclkr,
            mpw1_b      => mpw1_b,
            mpw2_b      => mpw2_b,
            d_mode      => d_mode,
            scin    => siv(spare_offset to spare_offset + spare_l2'length-1),
            scout   => sov(spare_offset to spare_offset + spare_l2'length-1),
            din     => spare_l2,
            dout    => spare_l2);
iu_au_is1_cr_user_v              <=  is1_UsesCR_L2 and is1_vld_L2;
iu_au_is0_cr_setter              <=  UpdatesCR;
-- Outputs to FXU dependency
fdec_fdep_is1_vld                <=  is1_vld_L2 and or_reduce(is1_vld_type_L2(0 to 2));
fdec_fdep_is1_instr(0 TO 15) <=  is1_instr_L2(0 to 15);
fdec_fdep_is1_instr(16 TO 31) <=  is1_axu_instr_L2(16 to 31) when is1_axu_ld_or_st_L2 = '1' and is1_to_ucode_L2 = '0' else
                                     is1_instr_L2(16 to 31);
fdec_fdep_is1_axu_ldst_indexed     <=  is1_axu_instr_L2(6);
fdec_fdep_is1_axu_ldst_tag         <=  is1_axu_instr_L2(7 to 15);
fdec_fdep_is1_ta_vld             <=  (is1_ta_vld_L2 and is1_vld_type_L2(2)) or
                                   (is1_axu_ldst_update_L2 or (is1_axu_mftgpr_L2 and not is1_axu_movedp_L2));
fdec_fdep_is1_ta                 <=  is1_ta_L2;
fdec_fdep_is1_s1_vld             <=  (is1_s1_vld_L2 and is1_vld_type_L2(2)) or
                                    is1_axu_ldst_ra_v_L2;
fdec_fdep_is1_s1                 <=  is1_s1_L2;
fdec_fdep_is1_s2_vld             <=  (is1_s2_vld_L2 and is1_vld_type_L2(2)) or
                                    is1_axu_ldst_rb_v_L2;
fdec_fdep_is1_s2                 <=  is1_s2_L2;
fdec_fdep_is1_s3_vld             <=  (is1_s3_vld_L2 and is1_vld_type_L2(2)) or
                                   (is1_axu_ldst_rb_v_L2 and is1_axu_mffgpr_L2);
fdec_fdep_is1_s3                 <=  is1_s3_L2;
fdec_fdep_is1_pred_update        <=  is1_pred_update_L2;
fdec_fdep_is1_pred_taken_cnt     <=  is1_pred_taken_cnt_L2;
fdec_fdep_is1_gshare             <=  is1_gshare_L2;
fdec_fdep_is1_UpdatesLR          <=  is1_UpdatesLR_L2;
fdec_fdep_is1_UpdatesCR          <=  is1_UpdatesCR_L2;
fdec_fdep_is1_UpdatesCTR         <=  is1_UpdatesCTR_L2;
fdec_fdep_is1_UpdatesXER         <=  is1_UpdatesXER_L2;
fdec_fdep_is1_UpdatesMSR         <=  is1_UpdatesMSR_L2;
fdec_fdep_is1_UpdatesSPR         <=  is1_UpdatesSPR_L2;
fdec_fdep_is1_UsesLR             <=  is1_UsesLR_L2;
fdec_fdep_is1_UsesCR             <=  is1_UsesCR_L2;
fdec_fdep_is1_UsesCTR            <=  is1_UsesCTR_L2;
fdec_fdep_is1_UsesXER            <=  is1_UsesXER_L2;
fdec_fdep_is1_UsesMSR            <=  is1_UsesMSR_L2;
fdec_fdep_is1_UsesSPR            <=  is1_UsesSPR_L2;
fdec_fdep_is1_hole_delay         <=  hole_delay;
fdec_fdep_is1_ld_vld             <=  (is1_ld_vld_L2 and is1_vld_type_L2(2)) or
                                   (is1_axu_ldst_update_L2 and not is1_axu_store_L2);
fdec_fdep_is1_to_ucode           <=  is1_to_ucode_L2 or is1_2ucode_L2 or to_uc;
fdec_fdep_is1_is_ucode           <=  is1_is_ucode_L2;
fdec_fdep_is1_complete           <=  compl_ex;
fdec_fdep_is1_ifar               <=  is1_ifar_L2;
fdec_fdep_is1_error(0 TO 1) <=  is1_error_L2(0 to 1);
fdec_fdep_is1_error(2) <=  not is1_axu_ld_or_st_L2 and not is1_to_ucode_L2 and not isFxuIssue when is1_error_L2(0 to 1) = "00" else
                                   is1_error_L2(2);
fdec_fdep_is1_axu_ld_or_st       <=  is1_axu_ld_or_st_L2;
fdec_fdep_is1_axu_store          <=  is1_axu_store_L2;
fdec_fdep_is1_axu_ldst_size      <=  is1_axu_ldst_size_L2;
fdec_fdep_is1_axu_ldst_update      <=  is1_axu_ldst_update_L2;
fdec_fdep_is1_axu_ldst_extpid      <=  is1_axu_ldst_extpid_L2;
fdec_fdep_is1_axu_ldst_forcealign  <=  is1_axu_ldst_forcealign_L2;
fdec_fdep_is1_axu_ldst_forceexcept <=  is1_axu_ldst_forceexcept_L2;
fdec_fdep_is1_axu_mftgpr         <=  is1_axu_mftgpr_L2;
fdec_fdep_is1_axu_mffgpr         <=  is1_axu_mffgpr_L2;
fdec_fdep_is1_axu_movedp        <=  is1_axu_movedp_L2;
fdec_fdep_is1_axu_instr_type     <=  gate(is1_axu_instr_type_L2, is1_axu_ld_or_st_L2 or is1_to_ucode_L2);
fdec_fdep_is1_match              <=  (spr_dec_mask(0 to 31) and is1_instr_L2(0 to 31)) = (spr_dec_mask(0 to 31) and spr_dec_match(0 to 31));
fdec_fdep_is1_force_ram          <=  is1_force_ram_L2;
fdec_fdep_is1_2ucode             <=  is1_2ucode_L2;
fdec_fdep_is1_2ucode_type        <=  is1_2ucode_type_L2;
-----------------------------------------------------------------------
-- Scan
-----------------------------------------------------------------------
siv(0 TO scan_right) <=  sov(1 to scan_right) & scan_in;
scan_out  <=  sov(0);
END IUQ_FXU_DECODE;
