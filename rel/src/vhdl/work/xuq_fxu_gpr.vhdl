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

--  Description:  XUQ_FXU GPR Top
--
LIBRARY ieee;       USE ieee.std_logic_1164.all;
                    USE ieee.numeric_std.all;
LIBRARY ibm;        
                    USE ibm.std_ulogic_support.all;
                    USE ibm.std_ulogic_unsigned.all;
                    USE ibm.std_ulogic_function_support.all;
LIBRARY support;    
                    USE support.power_logic_pkg.all;
LIBRARY tri;        USE tri.tri_latches_pkg.all;

entity xuq_fxu_gpr is
    generic(
        expand_type                         : integer := 2;
        regsize                             : integer := 64;
        threads                             : integer := 4);
    port (
        -- Clocks and Scan Cntls
        vdd                                 : inout power_logic;
        gnd                                 : inout power_logic;
        nclk                                : in clk_logic;

        -- Pervasive
        d_mode_dc                           : in std_ulogic;
        delay_lclkr_dc                      : in std_ulogic;
        clkoff_dc_b                         : in std_ulogic;
        mpw1_dc_b                           : in std_ulogic;
        mpw2_dc_b                           : in std_ulogic;
        func_sl_force : in std_ulogic;
        func_sl_thold_0_b                   : in std_ulogic;
        func_nsl_force : in std_ulogic;
        func_nsl_thold_0_b                  : in std_ulogic;
        sg_0                                : in std_ulogic;
        scan_in                             : in std_ulogic;
        scan_out                            : out std_ulogic;
        
        an_ac_scan_diag_dc                  : in  std_ulogic;

        -- ABIST/LBIST
        lbist_en                            : in  std_ulogic;
        abist_en                            : in  std_ulogic;
        abist_raw_dc_b                      : in  std_ulogic;
        r0e_sel_lbist                       : in  std_ulogic;
        r1e_sel_lbist                       : in  std_ulogic;
        r0e_abist_comp_en                   : in  std_ulogic;
        r1e_abist_comp_en                   : in  std_ulogic;
        r0e_addr_abist                      : in  std_ulogic_vector(2 to 9);
        r1e_addr_abist                      : in  std_ulogic_vector(2 to 9);
        r0e_en_abist                        : in  std_ulogic;
        r1e_en_abist                        : in  std_ulogic;
        w0e_addr_abist                      : in  std_ulogic_vector(2 to 9);
        w0l_addr_abist                      : in  std_ulogic_vector(2 to 9);
        w0e_en_abist                        : in  std_ulogic;
        w0l_en_abist                        : in  std_ulogic;
        w0e_data_abist                      : in  std_ulogic_vector(0 to 3);
        w0l_data_abist                      : in  std_ulogic_vector(0 to 3);

        -- BOLT-ON
        bo_enable_2                         : in  std_ulogic; -- general bolt-on enable, probably DC
        pc_xu_bo_reset                      : in  std_ulogic; -- execute sticky bit decode
        pc_xu_bo_unload                     : in  std_ulogic;
        pc_xu_bo_load                       : in  std_ulogic;
        pc_xu_bo_shdata                     : in  std_ulogic; -- shift data for timing write
        pc_xu_bo_select                     : in  std_ulogic_vector(0 to 1); -- select for mask and hier writes
        xu_pc_bo_fail                       : out std_ulogic_vector(0 to 1); -- fail/no-fix reg
        xu_pc_bo_diagout                    : out std_ulogic_vector(0 to 1);

        -- LCB Signals
        lcb_fce_0                           : in  std_ulogic;
        lcb_scan_diag_dc                    : in  std_ulogic;
        lcb_scan_dis_dc_b                   : in  std_ulogic;
        lcb_sg_0                            : in  std_ulogic;
        lcb_abst_sl_thold_0                 : in  std_ulogic;
        lcb_ary_nsl_thold_0                 : in  std_ulogic;
        lcb_time_sl_thold_0                 : in  std_ulogic;
        lcb_gptr_sl_thold_0                 : in  std_ulogic;
        lcb_bolt_sl_thold_0                 : in  std_ulogic;

        -- Scanchains
        gpr_gptr_scan_in                    : in  std_ulogic;
        gpr_gptr_scan_out                   : out std_ulogic;
        gpr_time_scan_in                    : in  std_ulogic;
        gpr_time_scan_out                   : out std_ulogic;
        gpr_abst_scan_in                    : in  std_ulogic;
        gpr_abst_scan_out                   : out std_ulogic;

        -- Parity
        pc_xu_inj_regfile_parity            : in std_ulogic_vector(0 to 3);
        xu_pc_err_regfile_parity            : out std_ulogic_vector(0 to threads-1);
        xu_pc_err_regfile_ue                : out std_ulogic_vector(0 to 3);
        gpr_cpl_ex3_regfile_err_det         : out std_ulogic;
        cpl_gpr_regfile_seq_beg             : in  std_ulogic;
        gpr_cpl_regfile_seq_end             : out std_ulogic;

        -- Read Port: 0
        r0_en                               : in  std_ulogic;                                       -- Read enable
        r0_addr_func                        : in  std_ulogic_vector(0 to 7);                        -- Read Address
        r0_data_out                         : out std_ulogic_vector(64-regsize to 69+regsize/8);    -- Read Data

        -- Read Port: 1
        r1_en                               : in  std_ulogic;
        r1_addr_func                        : in  std_ulogic_vector(0 to 7);
        r1_data_out                         : out std_ulogic_vector(64-regsize to 69+regsize/8);

        -- Read Port: 2
        r2_en                               : in  std_ulogic;
        r2_addr_func                        : in  std_ulogic_vector(0 to 7);
        r2_data_out                         : out std_ulogic_vector(64-regsize to 69+regsize/8);

        -- Read Port: 3
        r3_en                               : in  std_ulogic := '0';
        r3_addr_func                        : in  std_ulogic_vector(0 to 7) := "00000000";
        r3_data_out                         : out std_ulogic_vector(64-regsize to 69+regsize/8) := (others=>'0');

        -- Write Port: Early
        w_e_act                             : in  std_ulogic;
        w_e_addr_func                       : in  std_ulogic_vector(0 to 7);
        w_e_data_func                       : in  std_ulogic_vector(64-regsize to 63);

        -- Write Port: Late
        w_l_act                             : in  std_ulogic;
        w_l_addr_func                       : in  std_ulogic_vector(0 to 7);
        w_l_data_func                       : in  std_ulogic_vector(64-regsize to 69+regsize/8);
        
        gpr_debug                           : out std_ulogic_vector(0 to 21)
        
        );

        -- synopsys translate_off
        -- synopsys translate_on
end xuq_fxu_gpr;

architecture xuq_fxu_gpr of xuq_fxu_gpr is
    constant tiup                                                   : std_ulogic := '1';
    constant tidn                                                   : std_ulogic := '0';
    subtype s3                                                      is std_ulogic_vector(0 to 2);

    ---------------------------------------------------------------------
    -- Signals
    ---------------------------------------------------------------------
    signal siv_abst, sov_abst                                       : std_ulogic_vector(0 to 7);
    signal siv_time, sov_time                                       : std_ulogic_vector(0 to 1);
    
    signal lcb_clkoff_dc_b                                          : std_ulogic_vector(0 to 1);
    signal lcb_delay_lclkr_dc                                       : std_ulogic_vector(0 to 4);
    signal lcb_act_dis_dc                                           : std_ulogic;
    signal lcb_d_mode_dc                                            : std_ulogic;
    signal lcb_mpw1_dc_b                                            : std_ulogic_vector(0 to 4);
    signal lcb_mpw2_dc_b                                            : std_ulogic;
    signal arr_delay_lclkr_dc                                       : std_ulogic_vector(0 to 9);
    signal arr_mpw1_dc_b                                            : std_ulogic_vector(1 to 9);
    signal r0_array_data                                            : std_ulogic_vector(64-regsize to 69+regsize/8);
    signal r1_array_data                                            : std_ulogic_vector(64-regsize to 69+regsize/8);
    signal r2_array_data                                            : std_ulogic_vector(64-regsize to 69+regsize/8);
    signal r3_array_data                                            : std_ulogic_vector(64-regsize to 69+regsize/8);
    signal gpr_do0_par                                              : std_ulogic_vector(8-regsize/8 to 7);
    signal gpr_do0_par_err                                          : std_ulogic;
    signal gpr_do1_par                                              : std_ulogic_vector(8-regsize/8 to 7);
    signal gpr_do1_par_err                                          : std_ulogic;
    signal gpr_do2_par                                              : std_ulogic_vector(8-regsize/8 to 7);
    signal gpr_do2_par_err                                          : std_ulogic;
    signal gpr_do3_par                                              : std_ulogic_vector(8-regsize/8 to 7);
    signal gpr_do3_par_err                                          : std_ulogic;
    signal r0_read_enable                                           : std_ulogic;
    signal r1_read_enable                                           : std_ulogic;
    signal r2_read_enable                                           : std_ulogic;
    signal r3_read_enable                                           : std_ulogic;
    signal r0_read_addr                                             : std_ulogic_vector(0 to 7);
    signal r1_read_addr                                             : std_ulogic_vector(0 to 7);
    signal r2_read_addr                                             : std_ulogic_vector(0 to 7);
    signal r3_read_addr                                             : std_ulogic_vector(0 to 7);
    signal w_e_data, w0e_data, w1e_data                             : std_ulogic_vector(64-regsize to 69+regsize/8);
    signal w_l_data                                                 : std_ulogic_vector(64-regsize to 69+regsize/8);
    signal w_e_enable                                               : std_ulogic;
    signal w_l_enable                                               : std_ulogic;
    signal w_e_addr                                                 : std_ulogic_vector(0 to 7);
    signal w_l_addr                                                 : std_ulogic_vector(0 to 7);
    signal w_e_data_func_par                                        : std_ulogic_vector(64-regsize to 69+regsize/8);
    signal w_e_parity                                               : std_ulogic_vector(8-regsize/8 to 7);
    signal perr_sm_next                                             : std_ulogic_vector(0 to 4);
    signal perr_write_data_sel                                      : std_ulogic_vector(0 to 1);
    signal tri_err_in                                               : std_ulogic_vector(0 to 7);
    signal tri_err_out                                              : std_ulogic_vector(0 to 7);
    signal r0_byp_r                                                 : std_ulogic;
    signal r1_byp_r                                                 : std_ulogic;
    signal r2_byp_r                                                 : std_ulogic;
    signal r3_byp_r                                                 : std_ulogic;
    signal perr_tid                                                 : std_ulogic_vector(0 to threads-1);
    signal perr_ue, perr_ce                                         : std_ulogic;
    signal w_e_tid                                                  : std_ulogic_vector(0 to threads-1);
    signal perr_inj                                                 : std_ulogic;

    ---------------------------------------------------------------------
    -- Latches
    ---------------------------------------------------------------------
   signal ex3_regfile_err_det_q,    ex2_regfile_err_det          : std_ulogic;                               -- input=>ex2_regfile_err_det        , act=>tiup                 , scan=>Y, needs_sreset=>0
   signal gpr_do0_par_err_q                                      : std_ulogic;                               -- input=>gpr_do0_par_err            , act=>tiup                 , scan=>Y, needs_sreset=>0
   signal gpr_do1_par_err_q                                      : std_ulogic;                               -- input=>gpr_do1_par_err            , act=>tiup                 , scan=>Y, needs_sreset=>0
   signal gpr_do2_par_err_q                                      : std_ulogic;                               -- input=>gpr_do2_par_err            , act=>tiup                 , scan=>Y, needs_sreset=>0
   signal gpr_do3_par_err_q                                      : std_ulogic;                               -- input=>gpr_do3_par_err            , act=>tiup                 , scan=>Y, needs_sreset=>0
   signal r0_array_data_q                                        : std_ulogic_vector(0 to 63+regsize/8);     -- input=>r0_array_data              , act=>r0_read_enable_q     , scan=>Y, needs_sreset=>0
   signal r0_read_addr_q                                         : std_ulogic_vector(0 to 7);                -- input=>r0_read_addr               , act=>r0_read_enable       , scan=>N, needs_sreset=>0
   signal r0_read_addr_1_q                                       : std_ulogic_vector(0 to 7);                -- input=>r0_read_addr_q             , act=>r0_read_enable_q     , scan=>Y, needs_sreset=>0
   signal r0_read_addr_2_q                                       : std_ulogic_vector(0 to 7);                -- input=>r0_read_addr_1_q           , act=>r0_read_val_q        , scan=>N, needs_sreset=>0
   signal r0_read_enable_q                                       : std_ulogic;                               -- input=>r0_read_enable             , act=>tiup                 , scan=>N, needs_sreset=>1
   signal r0_read_val_q                                          : std_ulogic;                               -- input=>r0_read_enable_q           , act=>tiup                 , scan=>Y, needs_sreset=>1
   signal r1_array_data_q                                        : std_ulogic_vector(0 to 63+regsize/8);     -- input=>r1_array_data              , act=>r1_read_enable_q     , scan=>Y, needs_sreset=>0
   signal r1_read_addr_q                                         : std_ulogic_vector(0 to 7);                -- input=>r1_read_addr               , act=>r1_read_enable       , scan=>N, needs_sreset=>0
   signal r1_read_addr_1_q                                       : std_ulogic_vector(0 to 7);                -- input=>r1_read_addr_q             , act=>r1_read_enable_q     , scan=>Y, needs_sreset=>0
   signal r1_read_addr_2_q                                       : std_ulogic_vector(0 to 7);                -- input=>r1_read_addr_1_q           , act=>r1_read_val_q        , scan=>N, needs_sreset=>0
   signal r1_read_enable_q                                       : std_ulogic;                               -- input=>r1_read_enable             , act=>tiup                 , scan=>N, needs_sreset=>1
   signal r1_read_val_q                                          : std_ulogic;                               -- input=>r1_read_enable_q           , act=>tiup                 , scan=>Y, needs_sreset=>1
   signal r2_array_data_q                                        : std_ulogic_vector(0 to 63+regsize/8);     -- input=>r2_array_data              , act=>r2_read_enable_q     , scan=>Y, needs_sreset=>0
   signal r2_read_addr_q                                         : std_ulogic_vector(0 to 7);                -- input=>r2_read_addr               , act=>r2_read_enable       , scan=>N, needs_sreset=>0
   signal r2_read_addr_1_q                                       : std_ulogic_vector(0 to 7);                -- input=>r2_read_addr_q             , act=>r2_read_enable_q     , scan=>Y, needs_sreset=>0
   signal r2_read_addr_2_q                                       : std_ulogic_vector(0 to 7);                -- input=>r2_read_addr_1_q           , act=>r2_read_val_q        , scan=>N, needs_sreset=>0
   signal r2_read_enable_q                                       : std_ulogic;                               -- input=>r2_read_enable             , act=>tiup                 , scan=>N, needs_sreset=>1
   signal r2_read_val_q                                          : std_ulogic;                               -- input=>r2_read_enable_q           , act=>tiup                 , scan=>Y, needs_sreset=>1
   signal r3_array_data_q                                        : std_ulogic_vector(0 to 63+regsize/8);     -- input=>r3_array_data              , act=>r3_read_enable_q     , scan=>Y, needs_sreset=>0
   signal r3_read_enable_q                                       : std_ulogic;                               -- input=>r3_read_enable             , act=>tiup                 , scan=>N, needs_sreset=>1
   signal r3_read_val_q                                          : std_ulogic;                               -- input=>r3_read_enable_q           , act=>tiup                 , scan=>Y, needs_sreset=>1
   signal perr_addr_q,               perr_addr_d                 : std_ulogic_vector(0 to 7);                -- input=>perr_addr_d                , act=>tiup                 , scan=>Y, needs_sreset=>0
   signal perr_direction_q,          perr_direction_d            : std_ulogic_vector(0 to 1);                -- input=>perr_direction_d           , act=>tiup                 , scan=>Y, needs_sreset=>0
   signal perr_inj_q                                             : std_ulogic_vector(0 to 3);                -- input=>pc_xu_inj_regfile_parity   , act=>tiup                 , scan=>Y, needs_sreset=>0
   signal perr_sm_q,                 perr_sm_d                   : std_ulogic_vector(0 to 4);                -- input=>perr_sm_d                  , act=>tiup                 , scan=>Y, needs_sreset=>1, init=>2**(perr_sm_q'length-1)
   signal perr_write_data_q,         perr_write_data_d           : std_ulogic_vector(64-regsize to 69+regsize/8);-- input=>perr_write_data_d      , act=>perr_sm_q(2)         , scan=>Y, needs_sreset=>0
   signal err_regfile_parity_q,      err_regfile_parity_d        : std_ulogic_vector(0 to threads-1);        -- input=>err_regfile_parity_d       , act=>tiup                 , scan=>Y, needs_sreset=>1
   signal err_regfile_ue_q,          err_regfile_ue_d            : std_ulogic_vector(0 to threads-1);        -- input=>err_regfile_ue_d           , act=>tiup                 , scan=>Y, needs_sreset=>1
   signal err_seq_0_q                                            : std_ulogic;                               -- input=>cpl_gpr_regfile_seq_beg    , act=>tiup                 , scan=>Y, needs_sreset=>1
   signal wthru_r0_w_e_q,            wthru_r0_w_e_d              : std_ulogic;                               -- input=>wthru_r0_w_e_d             , act=>tiup                 , scan=>Y, needs_sreset=>1
   signal wthru_r0_w_l_q,            wthru_r0_w_l_d              : std_ulogic;                               -- input=>wthru_r0_w_l_d             , act=>tiup                 , scan=>Y, needs_sreset=>1
   signal wthru_r1_w_e_q,            wthru_r1_w_e_d              : std_ulogic;                               -- input=>wthru_r1_w_e_d             , act=>tiup                 , scan=>Y, needs_sreset=>1
   signal wthru_r1_w_l_q,            wthru_r1_w_l_d              : std_ulogic;                               -- input=>wthru_r1_w_l_d             , act=>tiup                 , scan=>Y, needs_sreset=>1
   signal wthru_r2_w_e_q,            wthru_r2_w_e_d              : std_ulogic;                               -- input=>wthru_r2_w_e_d             , act=>tiup                 , scan=>Y, needs_sreset=>1
   signal wthru_r2_w_l_q,            wthru_r2_w_l_d              : std_ulogic;                               -- input=>wthru_r2_w_l_d             , act=>tiup                 , scan=>Y, needs_sreset=>1
   signal wthru_r3_w_e_q,            wthru_r3_w_e_d              : std_ulogic;                               -- input=>wthru_r3_w_e_d             , act=>tiup                 , scan=>Y, needs_sreset=>1
   signal wthru_r3_w_l_q,            wthru_r3_w_l_d              : std_ulogic;                               -- input=>wthru_r3_w_l_d             , act=>tiup                 , scan=>Y, needs_sreset=>1
    ---------------------------------------------------------------------
    -- Scanchain
    ---------------------------------------------------------------------
   constant ex3_regfile_err_det_offset                : integer := 0;
   constant gpr_do0_par_err_offset                    : integer := ex3_regfile_err_det_offset     + 1;
   constant gpr_do1_par_err_offset                    : integer := gpr_do0_par_err_offset         + 1;
   constant gpr_do2_par_err_offset                    : integer := gpr_do1_par_err_offset         + 1;
   constant gpr_do3_par_err_offset                    : integer := gpr_do2_par_err_offset         + 1;
   constant r0_array_data_offset                      : integer := gpr_do3_par_err_offset         + 1;
   constant r0_read_addr_1_offset                     : integer := r0_array_data_offset           + r0_array_data_q'length;
   constant r0_read_val_offset                        : integer := r0_read_addr_1_offset          + r0_read_addr_1_q'length;
   constant r1_array_data_offset                      : integer := r0_read_val_offset             + 1;
   constant r1_read_addr_1_offset                     : integer := r1_array_data_offset           + r1_array_data_q'length;
   constant r1_read_val_offset                        : integer := r1_read_addr_1_offset          + r1_read_addr_1_q'length;
   constant r2_array_data_offset                      : integer := r1_read_val_offset             + 1;
   constant r2_read_addr_1_offset                     : integer := r2_array_data_offset           + r2_array_data_q'length;
   constant r2_read_val_offset                        : integer := r2_read_addr_1_offset          + r2_read_addr_1_q'length;
   constant r3_array_data_offset                      : integer := r2_read_val_offset             + 1;
   constant r3_read_val_offset                        : integer := r3_array_data_offset           + r3_array_data_q'length;
   constant perr_addr_offset                          : integer := r3_read_val_offset             + 1;
   constant perr_direction_offset                     : integer := perr_addr_offset               + perr_addr_q'length;
   constant perr_inj_offset                           : integer := perr_direction_offset          + perr_direction_q'length;
   constant perr_sm_offset                            : integer := perr_inj_offset                + perr_inj_q'length;
   constant perr_write_data_offset                    : integer := perr_sm_offset                 + perr_sm_q'length;
   constant err_regfile_parity_offset                 : integer := perr_write_data_offset         + perr_write_data_q'length;
   constant err_regfile_ue_offset                     : integer := err_regfile_parity_offset      + err_regfile_parity_q'length;
   constant err_seq_0_offset                          : integer := err_regfile_ue_offset          + err_regfile_ue_q'length;
   constant wthru_r0_w_e_offset                       : integer := err_seq_0_offset               + 1;
   constant wthru_r0_w_l_offset                       : integer := wthru_r0_w_e_offset            + 1;
   constant wthru_r1_w_e_offset                       : integer := wthru_r0_w_l_offset            + 1;
   constant wthru_r1_w_l_offset                       : integer := wthru_r1_w_e_offset            + 1;
   constant wthru_r2_w_e_offset                       : integer := wthru_r1_w_l_offset            + 1;
   constant wthru_r2_w_l_offset                       : integer := wthru_r2_w_e_offset            + 1;
   constant wthru_r3_w_e_offset                       : integer := wthru_r2_w_l_offset            + 1;
   constant wthru_r3_w_l_offset                       : integer := wthru_r3_w_e_offset            + 1;
   constant scan_right                                : integer := wthru_r3_w_l_offset            + 1;
   signal siv                                                      : std_ulogic_vector(0 to scan_right-1);
   signal sov                                                      : std_ulogic_vector(0 to scan_right-1);

begin


    ---------------------------------------------------------------------
    -- Pervasive
    ---------------------------------------------------------------------
    tri_err_in                  <= err_regfile_parity_q & err_regfile_ue_q;

    xu_gpr_err_rpt : entity tri.tri_direct_err_rpt(tri_direct_err_rpt)
    generic map(
        width => 8,
        expand_type => expand_type)
    port map(
        vd                      => vdd,
        gd                      => gnd,
        err_in                  => tri_err_in,
        err_out                 => tri_err_out);

    xu_pc_err_regfile_parity    <= tri_err_out(0 to 3);
    xu_pc_err_regfile_ue        <= tri_err_out(4 to 7);


    ---------------------------------------------------------------------
    -- Parity Generation / Error injection
    ---------------------------------------------------------------------
gpr_64b_par_gen : if regsize = 64 generate
    w_e_parity(0)   <= xor_reduce(w_e_data_func(0  to 7 ));
    w_e_parity(1)   <= xor_reduce(w_e_data_func(8  to 15));
    w_e_parity(2)   <= xor_reduce(w_e_data_func(16 to 23));
    w_e_parity(3)   <= xor_reduce(w_e_data_func(24 to 31));
    w_e_parity(4)   <= xor_reduce(w_e_data_func(32 to 39));
    w_e_parity(5)   <= xor_reduce(w_e_data_func(40 to 47));
    w_e_parity(6)   <= xor_reduce(w_e_data_func(48 to 55));
    w_e_parity(7)   <= xor_reduce(w_e_data_func(56 to 63));
end generate;

gpr_32b_par_gen : if regsize = 32 generate
    w_e_parity(4)   <= xor_reduce(w_e_data_func(32 to 39));
    w_e_parity(5)   <= xor_reduce(w_e_data_func(40 to 47));
    w_e_parity(6)   <= xor_reduce(w_e_data_func(48 to 55));
    w_e_parity(7)   <= xor_reduce(w_e_data_func(56 to 63));
end generate;

    ---------------------------------------------------------------------
    -- Assign outputs
    ---------------------------------------------------------------------
    r0_data_out                 <= r0_array_data(64-regsize to 69+regsize/8);
    r1_data_out                 <= r1_array_data(64-regsize to 69+regsize/8);
    r2_data_out                 <= r2_array_data(64-regsize to 69+regsize/8);
    r3_data_out                 <= r3_array_data(64-regsize to 69+regsize/8);

gpr_64b_data_out : if regsize = 64 generate
    w_e_data_func_par             <= w_e_data_func & w_e_parity & "000000";

    with perr_sm_q(3) select
        w_e_data                <= w_e_data_func_par    when '0',
                                   perr_write_data_q    when others;

    w_l_data                    <= w_l_data_func;
end generate;
gpr_32b_data_out : if regsize = 32 generate
    w_e_data_func_par             <= w_e_data_func & w_e_parity & "0000000000";

    with perr_sm_q(3) select
        w_e_data                <= (0 to 31 => tidn) & w_e_data_func_par    when '0',
                                   (0 to 31 => tidn) & perr_write_data_q    when others;

    w_l_data                    <= (0 to 31 => tidn) & w_l_data_func;
end generate;

    with w_e_addr_func(6 to 7) select
      w_e_tid        <= "0100"   when "01",
                        "0010"   when "10",
                        "0001"   when "11",
                        "1000"   when others;
                        
    perr_inj         <= or_reduce(w_e_tid and perr_inj_q) and perr_sm_q(0);    

    w0e_data(64-regsize)                  <= w_e_data(64-regsize) xor perr_inj;
    w0e_data(65-regsize to 69+regsize/8)  <= w_e_data(65-regsize to 69+regsize/8);

    w1e_data(64-regsize)                  <= w_e_data(64-regsize); 
    w1e_data(65-regsize to 69+regsize/8)  <= w_e_data(65-regsize to 69+regsize/8);

    ---------------------------------------------------------------------
    -- Read Enables and Addresses
    ---------------------------------------------------------------------
    -- Ports 1 and 3 are used for reading out data for error correction.
    -- Enables
    r0_read_enable              <= r0_en or lbist_en;
    with perr_sm_q(1) select
        r1_read_enable          <=(r1_en or lbist_en) when '0',
                                   '1'                when others;
    r2_read_enable              <=(r2_en or lbist_en);
    with perr_sm_q(1) select
        r3_read_enable          <=(r3_en or lbist_en) when '0',
                                   '1'                when others;

    -- Addresses
    r0_read_addr                <= r0_addr_func;
    with perr_sm_q(1) select
        r1_read_addr            <= r1_addr_func     when '0',
                                   perr_addr_q      when others;
    r2_read_addr                <= r2_addr_func;
    with perr_sm_q(1) select
        r3_read_addr            <= (others=>tidn)   when '0',
                                   perr_addr_q      when others;

    ---------------------------------------------------------------------
    -- Writeback
    ---------------------------------------------------------------------
    -- Use early port to write back parity data
    with perr_sm_q(3) select
        w_e_enable              <= w_e_act              when '0',
                                   '1'                  when others;
    w_l_enable                  <= w_l_act;

    with perr_sm_q(3) select
        w_e_addr                <= w_e_addr_func        when '0',
                                   perr_addr_q          when others;
    w_l_addr                    <= w_l_addr_func;

    ---------------------------------------------------------------------
    -- Parity Checking, Error Correction
    ---------------------------------------------------------------------
    
    -- Arg... what a mess
    -- RF0  r0_read_enable    r0_read_addr
    -- RF1  r0_read_enable_q  r0_read_addr_q    r0_array_data
    -- EX1  r0_read_val_q     r0_read_addr_1_q  r0_array_data_q   gpr_do0_par_err
    -- EX2                    r0_read_addr_2_q                    gpr_do0_par_err_q
    
gpr_parity_chk : for i in (8-regsize/8) to 7 generate
    gpr_do0_par(i)              <= xor_reduce(r0_array_data_q(8*i to 8*i+7));
    gpr_do1_par(i)              <= xor_reduce(r1_array_data_q(8*i to 8*i+7));
    gpr_do2_par(i)              <= xor_reduce(r2_array_data_q(8*i to 8*i+7));
    gpr_do3_par(i)              <= xor_reduce(r3_array_data_q(8*i to 8*i+7));
end generate;

    gpr_do0_par_err             <= r0_read_val_q and (r0_array_data_q(64 to 63+regsize/8) /= gpr_do0_par);
    gpr_do1_par_err             <= r1_read_val_q and (r1_array_data_q(64 to 63+regsize/8) /= gpr_do1_par);
    gpr_do2_par_err             <= r2_read_val_q and (r2_array_data_q(64 to 63+regsize/8) /= gpr_do2_par);
    gpr_do3_par_err             <= r3_read_val_q and (r3_array_data_q(64 to 63+regsize/8) /= gpr_do3_par);

    -- Parity error detected
    ex2_regfile_err_det         <= perr_sm_q(0) and (gpr_do0_par_err_q or gpr_do1_par_err_q or gpr_do2_par_err_q);
    gpr_cpl_ex3_regfile_err_det <= ex3_regfile_err_det_q;
    

    -- Save the offending address on any parity error and hold.
    perr_addr_d                 <= r0_read_addr_2_q when (gpr_do0_par_err_q and perr_sm_q(0)) = '1' else
                                   r1_read_addr_2_q when (gpr_do1_par_err_q and perr_sm_q(0)) = '1' else
                                   r2_read_addr_2_q when (gpr_do2_par_err_q and perr_sm_q(0)) = '1' else
                                   perr_addr_q;
    -- Save the direction of transfer
    perr_direction_d            <= "10"         when ((gpr_do0_par_err_q or gpr_do1_par_err_q) and perr_sm_q(0)) = '1' else    -- gpr_b writes to gpr_a
                                   "01"         when ( gpr_do2_par_err_q                       and perr_sm_q(0)) = '1' else    -- gpr_a writes to gpr_b
                                   perr_direction_q;

    -- Save data read out to write in next cycle
    perr_write_data_sel         <= perr_direction_q and (0 to 1 => perr_sm_q(2));
    with perr_write_data_sel select
        perr_write_data_d       <= r1_array_data    when "01",
                                   r3_array_data    when "10",
                                   (others=>tidn)   when others;
                                                                    
    ---------------------------------------------------------------------
    -- State Machine
    ---------------------------------------------------------------------
    -- State 0 = 1000 = Default, no parity error
    -- State 1 = 0100 = Parity error detected.  Flush System, read out both entries
    -- State 2 = 0010 = Write back corrected entry
    -- State 3 = 0001 = Flag Unrecoverable Error

    perr_sm_d                   <= ("10000"     and (0 to 4 => perr_sm_next(0))) or
                                   ("01000"     and (0 to 4 => perr_sm_next(1))) or
                                   ("00100"     and (0 to 4 => perr_sm_next(2))) or
                                   ("00010"     and (0 to 4 => perr_sm_next(3))) or
                                   ("00001"     and (0 to 4 => perr_sm_next(4))) or
                                   (perr_sm_q   and (0 to 4 => not (or_reduce(perr_sm_next))));

    -- Go to State 0 at the end of the sequence.  That's either after a UE, or writeback is done
    perr_sm_next(0)             <= perr_sm_q(4);
    gpr_cpl_regfile_seq_end     <= perr_sm_q(3);  -- fix later to 4

    -- Go to State 1 when a parity error is detected.
    perr_sm_next(1)             <= perr_sm_q(0) and err_seq_0_q;

    -- Go to State 2 when both sets of data have been read out
    perr_sm_next(2)             <= perr_sm_q(1);
    
    -- Go to State 3 after read has completed, check for parity error
    perr_sm_next(3)             <= perr_sm_q(2);
    perr_sm_next(4)             <= perr_sm_q(3);

    with perr_addr_q(6 to 7) select
      perr_tid          <= "1000"   when "00",
                           "0100"   when "01",
                           "0010"   when "10",
                           "0001"   when others;

    -- Check for parity error on the read that holds the "corrected data"
    -- If we get a parity error here, this is not correctable
    perr_ue                   <= perr_sm_q(4) and
                                ((perr_direction_q(0) and gpr_do3_par_err_q) or
                                 (perr_direction_q(1) and gpr_do1_par_err_q));

    perr_ce                   <= perr_sm_q(4) and not perr_ue;

    err_regfile_parity_d        <= gate(perr_tid,perr_ce);
    err_regfile_ue_d            <= gate(perr_tid,perr_ue);

    ---------------------------------------------------------------------
    -- GPR Write-through
    ---------------------------------------------------------------------
    wthru_r0_w_e_d         <= (r0_addr_func = w_e_addr_func) and w_e_act;
    wthru_r1_w_e_d         <= (r1_addr_func = w_e_addr_func) and w_e_act;
    wthru_r2_w_e_d         <= (r2_addr_func = w_e_addr_func) and w_e_act;
    wthru_r3_w_e_d         <= (r3_addr_func = w_e_addr_func) and w_e_act;

    wthru_r0_w_l_d         <= (r0_addr_func = w_l_addr_func) and w_l_act;
    wthru_r1_w_l_d         <= (r1_addr_func = w_l_addr_func) and w_l_act;
    wthru_r2_w_l_d         <= (r2_addr_func = w_l_addr_func) and w_l_act;
    wthru_r3_w_l_d         <= (r3_addr_func = w_l_addr_func) and w_l_act;
    
    r0_byp_r               <= not (wthru_r0_w_e_q or wthru_r0_w_l_q);
    r1_byp_r               <= not (wthru_r1_w_e_q or wthru_r1_w_l_q);
    r2_byp_r               <= not (wthru_r2_w_e_q or wthru_r2_w_l_q);
    r3_byp_r               <= not (wthru_r3_w_e_q or wthru_r3_w_l_q);
    
    
    gpr_debug              <= perr_sm_q(0 to 3) & perr_direction_q & perr_addr_q(0 to 7) &
                              wthru_r0_w_e_q & wthru_r0_w_l_q &
                              wthru_r1_w_e_q & wthru_r1_w_l_q &
                              wthru_r2_w_e_q & wthru_r2_w_l_q &
                              wthru_r3_w_e_q & wthru_r3_w_l_q;

    ---------------------------------------------------------------------
    -- ABIST Scan Ring
    ---------------------------------------------------------------------
    xu_gpr_a : entity tri.tri_144x78_2r2w_eco(tri_144x78_2r2w_eco)
    generic map(
       expand_type              => expand_type)
    port map(
       vdd                      => vdd,
       gnd                      => gnd,
       nclk                     => nclk,
       abist_en                 => abist_en,
       lbist_en                 => lbist_en,
       abist_raw_dc_b           => abist_raw_dc_b,
       r0e_abist_comp_en        => r0e_abist_comp_en,
       r1e_abist_comp_en        => r1e_abist_comp_en,
       lcb_act_dis_dc           => lcb_act_dis_dc,
       lcb_clkoff_dc_b          => lcb_clkoff_dc_b,
       lcb_d_mode_dc            => lcb_d_mode_dc,
       lcb_delay_lclkr_dc       => arr_delay_lclkr_dc,
       lcb_fce_0                => lcb_fce_0,
       lcb_mpw1_dc_b            => arr_mpw1_dc_b,
       lcb_mpw2_dc_b            => lcb_mpw2_dc_b,
       lcb_scan_diag_dc         => lcb_scan_diag_dc,
       lcb_scan_dis_dc_b        => lcb_scan_dis_dc_b,
       lcb_sg_0                 => lcb_sg_0,
       lcb_abst_sl_thold_0      => lcb_abst_sl_thold_0,
       lcb_ary_nsl_thold_0      => lcb_ary_nsl_thold_0,
       lcb_time_sl_thold_0      => lcb_time_sl_thold_0,       
       lcb_obs0_sg_0            => lcb_sg_0,
       lcb_obs0_sl_thold_0      => lcb_abst_sl_thold_0,
       lcb_time_sg_0            => lcb_sg_0,
       obs0_scan_in             => siv_abst(0),
       obs0_scan_out            => sov_abst(0),
       lcb_obs1_sg_0            => lcb_sg_0,
       lcb_obs1_sl_thold_0      => lcb_abst_sl_thold_0,
       obs1_scan_in             => siv_abst(1),
       obs1_scan_out            => sov_abst(1),
       time_scan_in             => siv_time(0),
       time_scan_out            => sov_time(0),
       r_scan_in                => siv_abst(2),
       r_scan_out               => sov_abst(2),
       w_scan_in                => siv_abst(3),
       w_scan_out               => sov_abst(3),
       lcb_bolt_sl_thold_0      => lcb_bolt_sl_thold_0,
       pc_bo_enable_2           => bo_enable_2,                
       pc_bo_reset              => pc_xu_bo_reset,             
       pc_bo_unload             => pc_xu_bo_unload,
       pc_bo_load               => pc_xu_bo_load,
       pc_bo_shdata             => pc_xu_bo_shdata,
       pc_bo_select             => pc_xu_bo_select(0),
       bo_pc_failout            => xu_pc_bo_fail(0),
       bo_pc_diagloop           => xu_pc_bo_diagout(0),
       tri_lcb_mpw1_dc_b        => mpw1_dc_b,
       tri_lcb_mpw2_dc_b        => mpw2_dc_b,
       tri_lcb_delay_lclkr_dc   => delay_lclkr_dc,
       tri_lcb_clkoff_dc_b      => clkoff_dc_b,
       tri_lcb_act_dis_dc       => tidn,
       r0e_act                  => r0_read_enable,
       r0e_en_func              => r0_read_enable,
       r0e_en_abist             => r0e_en_abist,
       r0e_sel_lbist            => r0e_sel_lbist,
       r0e_addr_func            => r0_read_addr,
       r0e_addr_abist           => r0e_addr_abist,
       r0e_data_out             => r0_array_data,
       r0e_byp_e                => wthru_r0_w_e_q,
       r0e_byp_l                => wthru_r0_w_l_q,
       r0e_byp_r                => r0_byp_r,
       r1e_act                  => r1_read_enable,
       r1e_en_func              => r1_read_enable,
       r1e_en_abist             => r1e_en_abist,
       r1e_sel_lbist            => r1e_sel_lbist,
       r1e_addr_func            => r1_read_addr,
       r1e_addr_abist           => r1e_addr_abist,
       r1e_data_out             => r1_array_data,
       r1e_byp_e                => wthru_r1_w_e_q,
       r1e_byp_l                => wthru_r1_w_l_q,
       r1e_byp_r                => r1_byp_r,
       w0e_act                  => w_e_enable,
       w0e_en_func              => w_e_enable,
       w0e_en_abist             => w0e_en_abist,
       w0e_addr_func            => w_e_addr,
       w0e_addr_abist           => w0e_addr_abist,
       w0e_data_func            => w0e_data,
       w0e_data_abist           => w0e_data_abist,
       w0l_act                  => w_l_enable,
       w0l_en_func              => w_l_enable,
       w0l_en_abist             => w0l_en_abist,
       w0l_addr_func            => w_l_addr,
       w0l_addr_abist           => w0l_addr_abist,
       w0l_data_func            => w_l_data,
       w0l_data_abist           => w0l_data_abist);

    xu_gpr_b : entity tri.tri_144x78_2r2w_eco(tri_144x78_2r2w_eco)
    generic map(
       expand_type              => expand_type)
    port map(
       vdd                      => vdd,
       gnd                      => gnd,
       nclk                     => nclk,
       abist_en                 => abist_en,
       lbist_en                 => lbist_en,
       abist_raw_dc_b           => abist_raw_dc_b,
       r0e_abist_comp_en        => r0e_abist_comp_en,
       r1e_abist_comp_en        => r1e_abist_comp_en,
       lcb_act_dis_dc           => lcb_act_dis_dc,
       lcb_clkoff_dc_b          => lcb_clkoff_dc_b,
       lcb_d_mode_dc            => lcb_d_mode_dc,
       lcb_delay_lclkr_dc       => arr_delay_lclkr_dc,
       lcb_fce_0                => lcb_fce_0,
       lcb_mpw1_dc_b            => arr_mpw1_dc_b,
       lcb_mpw2_dc_b            => lcb_mpw2_dc_b,
       lcb_scan_diag_dc         => lcb_scan_diag_dc,
       lcb_scan_dis_dc_b        => lcb_scan_dis_dc_b,
       lcb_sg_0                 => lcb_sg_0,
       lcb_abst_sl_thold_0      => lcb_abst_sl_thold_0,
       lcb_ary_nsl_thold_0      => lcb_ary_nsl_thold_0,
       lcb_time_sg_0            => lcb_sg_0,
       lcb_time_sl_thold_0      => lcb_time_sl_thold_0,       
       lcb_obs0_sg_0            => lcb_sg_0,
       lcb_obs0_sl_thold_0      => lcb_abst_sl_thold_0,
       obs0_scan_in             => siv_abst(4),
       obs0_scan_out            => sov_abst(4),
       lcb_obs1_sg_0            => lcb_sg_0,
       lcb_obs1_sl_thold_0      => lcb_abst_sl_thold_0,
       obs1_scan_in             => siv_abst(5),
       obs1_scan_out            => sov_abst(5),
       time_scan_in             => siv_time(1),
       time_scan_out            => sov_time(1),
       r_scan_in                => siv_abst(6),
       r_scan_out               => sov_abst(6),
       w_scan_in                => siv_abst(7),
       w_scan_out               => sov_abst(7),
       lcb_bolt_sl_thold_0      => lcb_bolt_sl_thold_0,
       pc_bo_enable_2           => bo_enable_2,
       pc_bo_reset              => pc_xu_bo_reset,             
       pc_bo_unload             => pc_xu_bo_unload,
       pc_bo_load               => pc_xu_bo_load,
       pc_bo_shdata             => pc_xu_bo_shdata,
       pc_bo_select             => pc_xu_bo_select(1),
       bo_pc_failout            => xu_pc_bo_fail(1),
       bo_pc_diagloop           => xu_pc_bo_diagout(1),
       tri_lcb_mpw1_dc_b        => mpw1_dc_b,
       tri_lcb_mpw2_dc_b        => mpw2_dc_b,
       tri_lcb_delay_lclkr_dc   => delay_lclkr_dc,
       tri_lcb_clkoff_dc_b      => clkoff_dc_b,
       tri_lcb_act_dis_dc       => tidn,
       r0e_act                  => r2_read_enable,
       r0e_en_func              => r2_read_enable,
       r0e_en_abist             => r0e_en_abist,
       r0e_sel_lbist            => r0e_sel_lbist,
       r0e_addr_func            => r2_read_addr,
       r0e_addr_abist           => r0e_addr_abist,
       r0e_data_out             => r2_array_data,
       r0e_byp_e                => wthru_r2_w_e_q,
       r0e_byp_l                => wthru_r2_w_l_q,
       r0e_byp_r                => r2_byp_r,
       r1e_act                  => r3_read_enable,
       r1e_en_func              => r3_read_enable,
       r1e_en_abist             => r1e_en_abist,
       r1e_sel_lbist            => r1e_sel_lbist,
       r1e_addr_func            => r3_read_addr,
       r1e_addr_abist           => r1e_addr_abist,
       r1e_data_out             => r3_array_data,
       r1e_byp_e                => wthru_r3_w_e_q,
       r1e_byp_l                => wthru_r3_w_l_q,
       r1e_byp_r                => r3_byp_r,
       w0e_act                  => w_e_enable,  
       w0e_en_func              => w_e_enable,
       w0e_en_abist             => w0e_en_abist,
       w0e_addr_func            => w_e_addr,
       w0e_addr_abist           => w0e_addr_abist,
       w0e_data_func            => w1e_data,
       w0e_data_abist           => w0e_data_abist,
       w0l_act                  => w_l_enable,  
       w0l_en_func              => w_l_enable,
       w0l_en_abist             => w0l_en_abist,
       w0l_addr_func            => w_l_addr,
       w0l_addr_abist           => w0l_addr_abist,
       w0l_data_func            => w_l_data,
       w0l_data_abist           => w0l_data_abist);

perv_lcbctrl_regf_0: tri_lcbcntl_array_mac
generic map (expand_type => expand_type)
port map (
            vdd            => vdd,
            gnd            => gnd,
            sg             => lcb_sg_0,
            nclk           => nclk,
            scan_in        => gpr_gptr_scan_in,
            scan_diag_dc   => an_ac_scan_diag_dc,
            thold          => lcb_gptr_sl_thold_0,
            clkoff_dc_b    => lcb_clkoff_dc_b(0),
            delay_lclkr_dc => lcb_delay_lclkr_dc,
            act_dis_dc     => lcb_act_dis_dc,
            d_mode_dc      => lcb_d_mode_dc,
            mpw1_dc_b      => lcb_mpw1_dc_b,
            mpw2_dc_b      => lcb_mpw2_dc_b,
            scan_out       => gpr_gptr_scan_out);
            
    lcb_clkoff_dc_b(1)           <= lcb_clkoff_dc_b(0);

    arr_delay_lclkr_dc(0)        <= lcb_delay_lclkr_dc(0);
    arr_delay_lclkr_dc(1)        <= lcb_delay_lclkr_dc(1);
    arr_delay_lclkr_dc(2)        <= lcb_delay_lclkr_dc(0);
    arr_delay_lclkr_dc(3)        <= lcb_delay_lclkr_dc(1);
    arr_delay_lclkr_dc(4)        <= lcb_delay_lclkr_dc(2);
    arr_delay_lclkr_dc(5)        <= lcb_delay_lclkr_dc(3);
    arr_delay_lclkr_dc(6)        <= lcb_delay_lclkr_dc(4);
    arr_delay_lclkr_dc(7)        <= lcb_delay_lclkr_dc(4);
    arr_delay_lclkr_dc(8)        <= lcb_delay_lclkr_dc(3);
    arr_delay_lclkr_dc(9)        <= lcb_delay_lclkr_dc(3);
    
    arr_mpw1_dc_b(1)             <= lcb_mpw1_dc_b(0);
    arr_mpw1_dc_b(2)             <= lcb_mpw1_dc_b(0);
    arr_mpw1_dc_b(3)             <= lcb_mpw1_dc_b(0);
    arr_mpw1_dc_b(4)             <= lcb_mpw1_dc_b(1);
    arr_mpw1_dc_b(5)             <= lcb_mpw1_dc_b(2);
    arr_mpw1_dc_b(6)             <= lcb_mpw1_dc_b(3);
    arr_mpw1_dc_b(7)             <= lcb_mpw1_dc_b(4);
    arr_mpw1_dc_b(8)             <= lcb_mpw1_dc_b(2);
    arr_mpw1_dc_b(9)             <= lcb_mpw1_dc_b(2);
            
    ---------------------------------------------------------------------
    -- Latches
    ---------------------------------------------------------------------
   ex3_regfile_err_det_latch : tri_rlmlatch_p
     generic map (init => 0, expand_type => expand_type, needs_sreset => 0)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => tiup                 ,
               forcee => func_sl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_sl_thold_0_b,
               sg      => sg_0,
               scin    => siv(ex3_regfile_err_det_offset),
               scout   => sov(ex3_regfile_err_det_offset),
               din     => ex2_regfile_err_det,
               dout    => ex3_regfile_err_det_q);
   gpr_do0_par_err_latch : tri_rlmlatch_p
     generic map (init => 0, expand_type => expand_type, needs_sreset => 0)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => tiup                 ,
               forcee => func_sl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_sl_thold_0_b,
               sg      => sg_0,
               scin    => siv(gpr_do0_par_err_offset),
               scout   => sov(gpr_do0_par_err_offset),
               din     => gpr_do0_par_err            ,
               dout    => gpr_do0_par_err_q);
   gpr_do1_par_err_latch : tri_rlmlatch_p
     generic map (init => 0, expand_type => expand_type, needs_sreset => 0)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => tiup                 ,
               forcee => func_sl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_sl_thold_0_b,
               sg      => sg_0,
               scin    => siv(gpr_do1_par_err_offset),
               scout   => sov(gpr_do1_par_err_offset),
               din     => gpr_do1_par_err            ,
               dout    => gpr_do1_par_err_q);
   gpr_do2_par_err_latch : tri_rlmlatch_p
     generic map (init => 0, expand_type => expand_type, needs_sreset => 0)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => tiup                 ,
               forcee => func_sl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_sl_thold_0_b,
               sg      => sg_0,
               scin    => siv(gpr_do2_par_err_offset),
               scout   => sov(gpr_do2_par_err_offset),
               din     => gpr_do2_par_err            ,
               dout    => gpr_do2_par_err_q);
   gpr_do3_par_err_latch : tri_rlmlatch_p
     generic map (init => 0, expand_type => expand_type, needs_sreset => 0)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => tiup                 ,
               forcee => func_sl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_sl_thold_0_b,
               sg      => sg_0,
               scin    => siv(gpr_do3_par_err_offset),
               scout   => sov(gpr_do3_par_err_offset),
               din     => gpr_do3_par_err            ,
               dout    => gpr_do3_par_err_q);
   r0_array_data_latch : tri_rlmreg_p
     generic map (width => r0_array_data_q'length, init => 0, expand_type => expand_type, needs_sreset => 0)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => r0_read_enable_q     ,
               forcee => func_sl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_sl_thold_0_b,
               sg      => sg_0,
               scin    => siv(r0_array_data_offset to r0_array_data_offset + r0_array_data_q'length-1),
               scout   => sov(r0_array_data_offset to r0_array_data_offset + r0_array_data_q'length-1),
               din     => r0_array_data(0 to 63+regsize/8),
               dout    => r0_array_data_q);
   r0_read_addr_latch : tri_regk
     generic map (width => r0_read_addr_q'length, init => 0, expand_type => expand_type, needs_sreset => 0)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => r0_read_enable       ,
               forcee => func_nsl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_nsl_thold_0_b,
               din     => r0_read_addr               ,
               dout    => r0_read_addr_q);
   r0_read_addr_1_latch : tri_rlmreg_p
     generic map (width => r0_read_addr_1_q'length, init => 0, expand_type => expand_type, needs_sreset => 0)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => r0_read_enable_q     ,
               forcee => func_sl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_sl_thold_0_b,
               sg      => sg_0,
               scin    => siv(r0_read_addr_1_offset to r0_read_addr_1_offset + r0_read_addr_1_q'length-1),
               scout   => sov(r0_read_addr_1_offset to r0_read_addr_1_offset + r0_read_addr_1_q'length-1),
               din     => r0_read_addr_q             ,
               dout    => r0_read_addr_1_q);
   r0_read_addr_2_latch : tri_regk
     generic map (width => r0_read_addr_2_q'length, init => 0, expand_type => expand_type, needs_sreset => 0)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => r0_read_val_q        ,
               forcee => func_nsl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_nsl_thold_0_b,
               din     => r0_read_addr_1_q           ,
               dout    => r0_read_addr_2_q);
   r0_read_enable_latch : tri_regk
     generic map (width => 1, init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => tiup                 ,
               forcee => func_nsl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_nsl_thold_0_b,
               din(0)  => r0_read_enable             ,
               dout(0) => r0_read_enable_q);
   r0_read_val_latch : tri_rlmlatch_p
     generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => tiup                 ,
               forcee => func_sl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_sl_thold_0_b,
               sg      => sg_0,
               scin    => siv(r0_read_val_offset),
               scout   => sov(r0_read_val_offset),
               din     => r0_read_enable_q           ,
               dout    => r0_read_val_q);
   r1_array_data_latch : tri_rlmreg_p
     generic map (width => r1_array_data_q'length, init => 0, expand_type => expand_type, needs_sreset => 0)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => r1_read_enable_q     ,
               forcee => func_sl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_sl_thold_0_b,
               sg      => sg_0,
               scin    => siv(r1_array_data_offset to r1_array_data_offset + r1_array_data_q'length-1),
               scout   => sov(r1_array_data_offset to r1_array_data_offset + r1_array_data_q'length-1),
               din     => r1_array_data(0 to 63+regsize/8),
               dout    => r1_array_data_q);
   r1_read_addr_latch : tri_regk
     generic map (width => r1_read_addr_q'length, init => 0, expand_type => expand_type, needs_sreset => 0)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => r1_read_enable       ,
               forcee => func_nsl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_nsl_thold_0_b,
               din     => r1_read_addr               ,
               dout    => r1_read_addr_q);
   r1_read_addr_1_latch : tri_rlmreg_p
     generic map (width => r1_read_addr_1_q'length, init => 0, expand_type => expand_type, needs_sreset => 0)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => r1_read_enable_q     ,
               forcee => func_sl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_sl_thold_0_b,
               sg      => sg_0,
               scin    => siv(r1_read_addr_1_offset to r1_read_addr_1_offset + r1_read_addr_1_q'length-1),
               scout   => sov(r1_read_addr_1_offset to r1_read_addr_1_offset + r1_read_addr_1_q'length-1),
               din     => r1_read_addr_q             ,
               dout    => r1_read_addr_1_q);
   r1_read_addr_2_latch : tri_regk
     generic map (width => r1_read_addr_2_q'length, init => 0, expand_type => expand_type, needs_sreset => 0)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => r1_read_val_q        ,
               forcee => func_nsl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_nsl_thold_0_b,
               din     => r1_read_addr_1_q           ,
               dout    => r1_read_addr_2_q);
   r1_read_enable_latch : tri_regk
     generic map (width => 1, init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => tiup                 ,
               forcee => func_nsl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_nsl_thold_0_b,
               din(0)  => r1_read_enable             ,
               dout(0) => r1_read_enable_q);
   r1_read_val_latch : tri_rlmlatch_p
     generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => tiup                 ,
               forcee => func_sl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_sl_thold_0_b,
               sg      => sg_0,
               scin    => siv(r1_read_val_offset),
               scout   => sov(r1_read_val_offset),
               din     => r1_read_enable_q           ,
               dout    => r1_read_val_q);
   r2_array_data_latch : tri_rlmreg_p
     generic map (width => r2_array_data_q'length, init => 0, expand_type => expand_type, needs_sreset => 0)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => r2_read_enable_q     ,
               forcee => func_sl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_sl_thold_0_b,
               sg      => sg_0,
               scin    => siv(r2_array_data_offset to r2_array_data_offset + r2_array_data_q'length-1),
               scout   => sov(r2_array_data_offset to r2_array_data_offset + r2_array_data_q'length-1),
               din     => r2_array_data(0 to 63+regsize/8),
               dout    => r2_array_data_q);
   r2_read_addr_latch : tri_regk
     generic map (width => r2_read_addr_q'length, init => 0, expand_type => expand_type, needs_sreset => 0)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => r2_read_enable       ,
               forcee => func_nsl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_nsl_thold_0_b,
               din     => r2_read_addr               ,
               dout    => r2_read_addr_q);
   r2_read_addr_1_latch : tri_rlmreg_p
     generic map (width => r2_read_addr_1_q'length, init => 0, expand_type => expand_type, needs_sreset => 0)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => r2_read_enable_q     ,
               forcee => func_sl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_sl_thold_0_b,
               sg      => sg_0,
               scin    => siv(r2_read_addr_1_offset to r2_read_addr_1_offset + r2_read_addr_1_q'length-1),
               scout   => sov(r2_read_addr_1_offset to r2_read_addr_1_offset + r2_read_addr_1_q'length-1),
               din     => r2_read_addr_q             ,
               dout    => r2_read_addr_1_q);
   r2_read_addr_2_latch : tri_regk
     generic map (width => r2_read_addr_2_q'length, init => 0, expand_type => expand_type, needs_sreset => 0)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => r2_read_val_q        ,
               forcee => func_nsl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_nsl_thold_0_b,
               din     => r2_read_addr_1_q           ,
               dout    => r2_read_addr_2_q);
   r2_read_enable_latch : tri_regk
     generic map (width => 1, init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => tiup                 ,
               forcee => func_nsl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_nsl_thold_0_b,
               din(0)  => r2_read_enable             ,
               dout(0) => r2_read_enable_q);
   r2_read_val_latch : tri_rlmlatch_p
     generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => tiup                 ,
               forcee => func_sl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_sl_thold_0_b,
               sg      => sg_0,
               scin    => siv(r2_read_val_offset),
               scout   => sov(r2_read_val_offset),
               din     => r2_read_enable_q           ,
               dout    => r2_read_val_q);
   r3_array_data_latch : tri_rlmreg_p
     generic map (width => r3_array_data_q'length, init => 0, expand_type => expand_type, needs_sreset => 0)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => r3_read_enable_q     ,
               forcee => func_sl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_sl_thold_0_b,
               sg      => sg_0,
               scin    => siv(r3_array_data_offset to r3_array_data_offset + r3_array_data_q'length-1),
               scout   => sov(r3_array_data_offset to r3_array_data_offset + r3_array_data_q'length-1),
               din     => r3_array_data(0 to 63+regsize/8),
               dout    => r3_array_data_q);
   r3_read_enable_latch : tri_regk
     generic map (width => 1, init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => tiup                 ,
               forcee => func_nsl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_nsl_thold_0_b,
               din(0)  => r3_read_enable             ,
               dout(0) => r3_read_enable_q);
   r3_read_val_latch : tri_rlmlatch_p
     generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => tiup                 ,
               forcee => func_sl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_sl_thold_0_b,
               sg      => sg_0,
               scin    => siv(r3_read_val_offset),
               scout   => sov(r3_read_val_offset),
               din     => r3_read_enable_q           ,
               dout    => r3_read_val_q);
   perr_addr_latch : tri_rlmreg_p
     generic map (width => perr_addr_q'length, init => 0, expand_type => expand_type, needs_sreset => 0)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => tiup,
               forcee => func_sl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_sl_thold_0_b,
               sg      => sg_0,
               scin    => siv(perr_addr_offset to perr_addr_offset + perr_addr_q'length-1),
               scout   => sov(perr_addr_offset to perr_addr_offset + perr_addr_q'length-1),
               din     => perr_addr_d,
               dout    => perr_addr_q);
   perr_direction_latch : tri_rlmreg_p
     generic map (width => perr_direction_q'length, init => 0, expand_type => expand_type, needs_sreset => 0)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => tiup,
               forcee => func_sl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_sl_thold_0_b,
               sg      => sg_0,
               scin    => siv(perr_direction_offset to perr_direction_offset + perr_direction_q'length-1),
               scout   => sov(perr_direction_offset to perr_direction_offset + perr_direction_q'length-1),
               din     => perr_direction_d,
               dout    => perr_direction_q);
   perr_inj_latch : tri_rlmreg_p
     generic map (width => perr_inj_q'length, init => 0, expand_type => expand_type, needs_sreset => 0)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => tiup                 ,
               forcee => func_sl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_sl_thold_0_b,
               sg      => sg_0,
               scin    => siv(perr_inj_offset to perr_inj_offset + perr_inj_q'length-1),
               scout   => sov(perr_inj_offset to perr_inj_offset + perr_inj_q'length-1),
               din     => pc_xu_inj_regfile_parity   ,
               dout    => perr_inj_q);
   perr_sm_latch : tri_rlmreg_p
     generic map (width => perr_sm_q'length, init => 2**(perr_sm_q'length-1), expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => tiup                 ,
               forcee => func_sl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_sl_thold_0_b,
               sg      => sg_0,
               scin    => siv(perr_sm_offset to perr_sm_offset + perr_sm_q'length-1),
               scout   => sov(perr_sm_offset to perr_sm_offset + perr_sm_q'length-1),
               din     => perr_sm_d,
               dout    => perr_sm_q);
   perr_write_data_latch : tri_rlmreg_p
     generic map (width => perr_write_data_q'length, init => 0, expand_type => expand_type, needs_sreset => 0)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => perr_sm_q(2)         ,
               forcee => func_sl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_sl_thold_0_b,
               sg      => sg_0,
               scin    => siv(perr_write_data_offset to perr_write_data_offset + perr_write_data_q'length-1),
               scout   => sov(perr_write_data_offset to perr_write_data_offset + perr_write_data_q'length-1),
               din     => perr_write_data_d,
               dout    => perr_write_data_q);
   err_regfile_parity_latch : tri_rlmreg_p
     generic map (width => err_regfile_parity_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => tiup                 ,
               forcee => func_sl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_sl_thold_0_b,
               sg      => sg_0,
               scin    => siv(err_regfile_parity_offset to err_regfile_parity_offset + err_regfile_parity_q'length-1),
               scout   => sov(err_regfile_parity_offset to err_regfile_parity_offset + err_regfile_parity_q'length-1),
               din     => err_regfile_parity_d,
               dout    => err_regfile_parity_q);
   err_regfile_ue_latch : tri_rlmreg_p
     generic map (width => err_regfile_ue_q'length, init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => tiup                 ,
               forcee => func_sl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_sl_thold_0_b,
               sg      => sg_0,
               scin    => siv(err_regfile_ue_offset to err_regfile_ue_offset + err_regfile_ue_q'length-1),
               scout   => sov(err_regfile_ue_offset to err_regfile_ue_offset + err_regfile_ue_q'length-1),
               din     => err_regfile_ue_d,
               dout    => err_regfile_ue_q);
   err_seq_0_latch : tri_rlmlatch_p
     generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => tiup                 ,
               forcee => func_sl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_sl_thold_0_b,
               sg      => sg_0,
               scin    => siv(err_seq_0_offset),
               scout   => sov(err_seq_0_offset),
               din     => cpl_gpr_regfile_seq_beg    ,
               dout    => err_seq_0_q);
   wthru_r0_w_e_latch : tri_rlmlatch_p
     generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => tiup                 ,
               forcee => func_sl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_sl_thold_0_b,
               sg      => sg_0,
               scin    => siv(wthru_r0_w_e_offset),
               scout   => sov(wthru_r0_w_e_offset),
               din     => wthru_r0_w_e_d,
               dout    => wthru_r0_w_e_q);
   wthru_r0_w_l_latch : tri_rlmlatch_p
     generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => tiup                 ,
               forcee => func_sl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_sl_thold_0_b,
               sg      => sg_0,
               scin    => siv(wthru_r0_w_l_offset),
               scout   => sov(wthru_r0_w_l_offset),
               din     => wthru_r0_w_l_d,
               dout    => wthru_r0_w_l_q);
   wthru_r1_w_e_latch : tri_rlmlatch_p
     generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => tiup                 ,
               forcee => func_sl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_sl_thold_0_b,
               sg      => sg_0,
               scin    => siv(wthru_r1_w_e_offset),
               scout   => sov(wthru_r1_w_e_offset),
               din     => wthru_r1_w_e_d,
               dout    => wthru_r1_w_e_q);
   wthru_r1_w_l_latch : tri_rlmlatch_p
     generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => tiup                 ,
               forcee => func_sl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_sl_thold_0_b,
               sg      => sg_0,
               scin    => siv(wthru_r1_w_l_offset),
               scout   => sov(wthru_r1_w_l_offset),
               din     => wthru_r1_w_l_d,
               dout    => wthru_r1_w_l_q);
   wthru_r2_w_e_latch : tri_rlmlatch_p
     generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => tiup                 ,
               forcee => func_sl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_sl_thold_0_b,
               sg      => sg_0,
               scin    => siv(wthru_r2_w_e_offset),
               scout   => sov(wthru_r2_w_e_offset),
               din     => wthru_r2_w_e_d,
               dout    => wthru_r2_w_e_q);
   wthru_r2_w_l_latch : tri_rlmlatch_p
     generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => tiup                 ,
               forcee => func_sl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_sl_thold_0_b,
               sg      => sg_0,
               scin    => siv(wthru_r2_w_l_offset),
               scout   => sov(wthru_r2_w_l_offset),
               din     => wthru_r2_w_l_d,
               dout    => wthru_r2_w_l_q);
   wthru_r3_w_e_latch : tri_rlmlatch_p
     generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => tiup                 ,
               forcee => func_sl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_sl_thold_0_b,
               sg      => sg_0,
               scin    => siv(wthru_r3_w_e_offset),
               scout   => sov(wthru_r3_w_e_offset),
               din     => wthru_r3_w_e_d,
               dout    => wthru_r3_w_e_q);
   wthru_r3_w_l_latch : tri_rlmlatch_p
     generic map (init => 0, expand_type => expand_type, needs_sreset => 1)
     port map (nclk    => nclk, vd => vdd, gd => gnd,
               act     => tiup                 ,
               forcee => func_sl_force,
               d_mode  => d_mode_dc, delay_lclkr => delay_lclkr_dc,
               mpw1_b  => mpw1_dc_b, mpw2_b  => mpw2_dc_b,
               thold_b => func_sl_thold_0_b,
               sg      => sg_0,
               scin    => siv(wthru_r3_w_l_offset),
               scout   => sov(wthru_r3_w_l_offset),
               din     => wthru_r3_w_l_d,
               dout    => wthru_r3_w_l_q);

    siv(0 to siv'right)  <= sov(1 to siv'right) & scan_in;
    scan_out <= sov(0);

    siv_abst(0 to siv_abst'right)  <= sov_abst(1 to siv_abst'right) & gpr_abst_scan_in;
    gpr_abst_scan_out <= sov_abst(0);

    siv_time(0 to siv_time'right)  <= sov_time(1 to siv_time'right) & gpr_time_scan_in;
    gpr_time_scan_out <= sov_time(0);


end architecture xuq_fxu_gpr;
