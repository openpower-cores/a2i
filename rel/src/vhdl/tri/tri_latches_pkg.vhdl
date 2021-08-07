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

LIBRARY ieee; USE ieee.std_logic_1164.all;
LIBRARY support; USE support.power_logic_pkg.all;

PACKAGE tri_latches_pkg IS

  type clk_logic is record
    clk         : std_ulogic;
    sreset      : std_ulogic;
    clk2x       : std_ulogic;
    clk4x       : std_ulogic;
  end record;

  type clk_logic_vector is array ( NATURAL range <> ) of clk_logic;


  component tri_cw_nlat
    generic (
            bhc:string:="";
            ub:string:="";
            offset : natural  range 0 to 65535 := 0;
            width  : positive range 1 to 65536 := 1 ;
            init   : std_ulogic_vector := "0";
            needs_sreset : integer := 1 ; -- for inferred latches
            expand_type : integer := 1 ); -- 1 = non-ibm, 2 = ibm (MPG)
    port (
        vd       : inout power_logic;
        gd       : inout power_logic;
        d_b      : in    std_ulogic_vector(0 to width-1);
        scan_in  : in    std_ulogic_vector(0 to width-1);
        d1clk    : in    std_ulogic;
        d2clk    : in    std_ulogic;
        lclk     : in    clk_logic;
        q_b      : out   std_ulogic_vector(0 to width-1);
        scan_out : out   std_ulogic_vector(0 to width-1)
       );
  end component;

  component tri_direct_err_rpt
    generic (
      width         : positive := 1 ;      -- use to bundle error reporting checkers of the same exact type
      expand_type   : integer  := 1 );     -- 1 = non-ibm, 2 = ibm (MPG)
    port (
      vd            : inout power_logic;
      gd            : inout power_logic;

      err_in        : in  std_ulogic_vector(0 to width-1);
      err_out       : out std_ulogic_vector(0 to width-1)
    );
  end component;

  component tri_err_rpt
    generic (
      width        : positive := 1;               -- number of errors of the same type
      mask_reset_value : std_ulogic_vector := "0";-- use to set default/flush value for mask bits
      inline       : boolean := false;            -- make hold latch be inline; err_out is sticky -- default to shadow
      reset_hold   : boolean := false;            -- make Hold latch use reset input
      needs_sreset : integer := 1 ;        -- for inferred latches
      expand_type  : integer := 1 );       -- 1 = non-ibm, 2 = ibm (MPG)
    port (
      vd            : inout power_logic;
      gd            : inout power_logic;
      err_d1clk     : in  std_ulogic;           -- caution: if lcb uses powersavings, errors must always get reported
      err_d2clk     : in  std_ulogic;
      err_lclk      : in  clk_logic;
      -- error scan chain (func or mode)
      err_scan_in   : in  std_ulogic_vector(0 to width-1);
      err_scan_out  : out std_ulogic_vector(0 to width-1);
      -- clock gateable mode clocks
      mode_dclk     : in  std_ulogic;
      mode_lclk     : in  clk_logic;
      -- mode scan chain
      mode_scan_in  : in  std_ulogic_vector(0 to width-1);
      mode_scan_out : out std_ulogic_vector(0 to width-1);

      err_in        : in  std_ulogic_vector(0 to width-1);
      err_out       : out std_ulogic_vector(0 to width-1);

      hold_out      : out std_ulogic_vector(0 to width-1); -- sticky error hold latch for trap usage
      mask_out      : out std_ulogic_vector(0 to width-1)
    );
  end component;

  component tri_klat
    generic (
            width              : positive range 1 to 65536 := 1 ;
            offset             : natural  range 0 to 65535 := 0;
            init               : std_ulogic_vector         := "0" ;
            synthclonedlatch   : string                    := "" ;
            needs_sreset : integer := 1 ; -- for inferred latches
            expand_type : integer := 1 ); -- 1 = non-ibm, 2 = ibm (MPG)
    port (
        vd       : inout power_logic;
        gd       : inout power_logic;
        dclk     : in    std_ulogic;
        lclk     : in    clk_logic;
        din      : in    std_ulogic_vector(offset to offset+width-1);
        q        : out   std_ulogic_vector(offset to offset+width-1);
        q_b      : out   std_ulogic_vector(offset to offset+width-1)
       );
  end component;

  component tri_lcbcntl_array_mac
    generic ( expand_type : integer := 1 ); -- 1 = non-ibm, 2 = ibm (MPG)
    port (
        vdd            : inout power_logic;
        gnd            : inout power_logic;
        sg             : in    std_ulogic;
        nclk           : in    clk_logic;
        scan_in        : in    std_ulogic;
        scan_diag_dc   : in    std_ulogic;
        thold          : in    std_ulogic;
        clkoff_dc_b    : out   std_ulogic;
        delay_lclkr_dc : out   std_ulogic_vector(0 to 4);
        act_dis_dc     : out   std_ulogic;
        d_mode_dc      : out   std_ulogic;
        mpw1_dc_b      : out   std_ulogic_vector(0 to 4);
        mpw2_dc_b      : out   std_ulogic;
        scan_out       : out   std_ulogic
       );
  end component;

  component tri_lcbcntl_mac
    generic ( expand_type : integer := 1 ); -- 1 = non-ibm, 2 = ibm (MPG)
    port (
        vdd            : inout power_logic;
        gnd            : inout power_logic;
        sg             : in    std_ulogic;
        nclk           : in    clk_logic;
        scan_in        : in    std_ulogic;
        scan_diag_dc   : in    std_ulogic;
        thold          : in    std_ulogic;
        clkoff_dc_b    : out   std_ulogic;
        delay_lclkr_dc : out   std_ulogic_vector(0 to 4);
        act_dis_dc     : out   std_ulogic;
        d_mode_dc      : out   std_ulogic;
        mpw1_dc_b      : out   std_ulogic_vector(0 to 4);
        mpw2_dc_b      : out   std_ulogic;
        scan_out       : out   std_ulogic
       );
  end component;

  component tri_lcbkd
    generic ( expand_type : integer := 1 ); -- 1 = non-ibm, 2 = ibm (MPG)
    port (
        vd          : inout power_logic;
        gd          : inout power_logic;
        act         : in    std_ulogic;
        delay_lclkr : in    std_ulogic;
        mpw1_b      : in    std_ulogic;
        mpw2_b      : in    std_ulogic;
        nclk        : in    clk_logic;
        forcee       : in    std_ulogic;
        thold_b     : in    std_ulogic;
        dclk        : out   std_ulogic;
        lclk        : out   clk_logic
       );
  end component;

  component tri_lcbnd
    generic ( expand_type : integer := 1 ); -- 1 = non-ibm, 2 = ibm (MPG)
    port (
        vd          : inout power_logic;
        gd          : inout power_logic;
        act         : in    std_ulogic;
        delay_lclkr : in    std_ulogic;
        mpw1_b      : in    std_ulogic;
        mpw2_b      : in    std_ulogic;
        nclk        : in    clk_logic;
        forcee       : in    std_ulogic;
        sg          : in    std_ulogic;
        thold_b     : in    std_ulogic;
        d1clk       : out   std_ulogic;
        d2clk       : out   std_ulogic;
        lclk        : out   clk_logic
       );
  end component;

  component tri_lcbor
    generic ( expand_type : integer := 1 ); -- 1 = non-ibm, 2 = ibm (MPG)
    port (
        clkoff_b : in    std_ulogic;
        thold    : in    std_ulogic;
        sg       : in    std_ulogic;
        act_dis  : in    std_ulogic;
        forcee    : out   std_ulogic;
        thold_b  : out   std_ulogic
       );
  end component;

  component tri_lcbs
    generic ( expand_type : integer := 1 ); -- 1 = non-ibm, 2 = ibm (MPG)
    port (
        vd          : inout power_logic;
        gd          : inout power_logic;
        delay_lclkr : in    std_ulogic;
        nclk        : in    clk_logic;
        forcee       : in    std_ulogic;
        thold_b     : in    std_ulogic;
        dclk        : out   std_ulogic;
        lclk        : out   clk_logic
       );
  end component;

  component tri_nlat
    generic (
            offset             : natural  range 0 to 65535 := 0;
            reset_inverts_scan : boolean                   := true;
            width              : positive range 1 to 65536 := 1 ;
            init               : std_ulogic_vector         := "0" ;
            synthclonedlatch   : string                    := "" ;
            needs_sreset : integer := 1 ; -- for inferred latches
            expand_type : integer := 1 ); -- 1 = non-ibm, 2 = ibm (MPG)
    port (
        vd       : inout power_logic;
        gd       : inout power_logic;
        d1clk    : in    std_ulogic;
        d2clk    : in    std_ulogic;
        lclk     : in    clk_logic;
        scan_in  : in    std_ulogic;
        din      : in    std_ulogic_vector(offset to offset+width-1);
        q        : out   std_ulogic_vector(offset to offset+width-1);
        q_b      : out   std_ulogic_vector(offset to offset+width-1);
        scan_out : out   std_ulogic
       );
  end component;

  component tri_nlat_scan
    generic (
            offset             : natural  range 0 to 65535 := 0;
            width              : positive range 1 to 65536 := 1 ;
            init               : std_ulogic_vector         := "0" ;
            reset_inverts_scan : boolean                   := true;
            synthclonedlatch   : string                    := "" ;
            needs_sreset : integer := 1 ; -- for inferred latches
            expand_type : integer := 1 ); -- 1 = non-ibm, 2 = ibm (MPG)
    port (
        vd       : inout power_logic;
        gd       : inout power_logic;
        d1clk    : in    std_ulogic;
        d2clk    : in    std_ulogic;
        lclk     : in    clk_logic;
        din      : in    std_ulogic_vector(offset to offset+width-1);
        scan_in  : in    std_ulogic_vector(offset to offset+width-1);
        q        : out   std_ulogic_vector(offset to offset+width-1);
        q_b      : out   std_ulogic_vector(offset to offset+width-1);
        scan_out : out   std_ulogic_vector(offset to offset+width-1)
       );
  end component;

  component tri_plat
    generic (
      width       : positive range 1 to 65536 := 1 ;
      offset      : natural range 0 to 65535  := 0 ;
      init        : integer := 0;  -- will be converted to the least signficant 31 bits of init_v
      synthclonedlatch : string                    := "" ;
      flushlat         : boolean                   := true ;
      expand_type : integer := 1 ); -- 1 = non-ibm, 2 = ibm (MPG)
    port (
      vd      : inout power_logic;
      gd      : inout power_logic;
      nclk    : in    clk_logic;
      flush   : in    std_ulogic;
      din     : in    std_ulogic_vector(offset to offset+width-1);
      q       : out   std_ulogic_vector(offset to offset+width-1) );
  end component;

  component tri_regk
    generic (
      width       : integer := 4;
      offset      : integer range 0 to 65535 := 0 ; --starting bit
      init        : integer := 0;  -- will be converted to the least signficant
                                   -- 31 bits of init_v
      synthclonedlatch    : string  := "";
      needs_sreset        : integer := 1 ;                  -- for inferred latches
      expand_type : integer := 1 );-- 0 = ibm (Umbra), 1 = non-ibm, 2 = ibm (MPG)
    port (
      vd      : inout power_logic;
      gd      : inout power_logic;
      nclk    : in  clk_logic;
      act     : in  std_ulogic := '1'; -- 1: functional, 0: no clock
      forcee   : in  std_ulogic := '0'; -- 1: force LCB active
      thold_b : in  std_ulogic := '1'; -- 1: functional, 0: no clock
      d_mode  : in  std_ulogic := '0'; -- 1: disable pulse mode, 0: pulse mode
      delay_lclkr : in  std_ulogic := '0'; -- 0: functional
      mpw1_b  : in  std_ulogic := '1'; -- pulse width control bit
      mpw2_b  : in  std_ulogic := '1'; -- pulse width control bit
      din     : in  std_ulogic_vector(offset to offset+width-1);  -- data in
      dout    : out std_ulogic_vector(offset to offset+width-1) );
  end component;

  component tri_regs
    generic (
      width       : integer := 4;
      offset      : integer range 0 to 65535 := 0 ; --starting bit
      init        : integer := 0;  -- will be converted to the least signficant
                                   -- 31 bits of init_v
      ibuf        : boolean := false;       --inverted latch IOs, if set to true.
      dualscan    : string  := ""; -- if "S", marks data ports as scan for Moebius
      needs_sreset        : integer := 1 ;                  -- for inferred latches
      expand_type : integer := 1 );-- 0 = ibm (Umbra), 1 = non-ibm, 2 = ibm (MPG)
    port (
      vd      : inout power_logic;
      gd      : inout power_logic;
      nclk    : in  clk_logic;
      forcee   : in  std_ulogic := '0'; -- 1: force LCB active
      thold_b : in  std_ulogic := '1'; -- 1: functional, 0: no clock
      delay_lclkr : in  std_ulogic := '0'; -- 0: functional
      scin    : in  std_ulogic_vector(offset to offset+width-1);  -- scan in
      scout   : out std_ulogic_vector(offset to offset+width-1);
      dout    : out std_ulogic_vector(offset to offset+width-1) );
  end component;

  component tri_rlmlatch_p
    generic (
      init        : integer := 0;  -- will be converted to the least signficant
                                   -- 31 bits of init_v
      ibuf        : boolean := false;       --inverted latch IOs, if set to true.
      dualscan    : string  := ""; -- if "S", marks data ports as scan for Moebius
      needs_sreset: integer := 1 ; -- for inferred latches
      expand_type : integer := 1 );-- 0 = ibm (Umbra), 1 = non-ibm, 2 = ibm (MPG)
    port (
      vd      : inout power_logic;
      gd      : inout power_logic;
      nclk    : in  clk_logic;
      act     : in  std_ulogic := '1'; -- 1: functional, 0: no clock
      forcee   : in  std_ulogic := '0'; -- 1: force LCB active
      thold_b : in  std_ulogic := '1'; -- 1: functional, 0: no clock
      d_mode  : in  std_ulogic := '0'; -- 1: disable pulse mode, 0: pulse mode
      sg      : in  std_ulogic := '0'; -- 0: functional, 1: scan
      delay_lclkr : in  std_ulogic := '0'; -- 0: functional
      mpw1_b  : in  std_ulogic := '1'; -- pulse width control bit
      mpw2_b  : in  std_ulogic := '1'; -- pulse width control bit
      scin    : in  std_ulogic := '0'; -- scan in
      din     : in  std_ulogic;        -- data in
      scout   : out std_ulogic;        -- scan out
      dout    : out std_ulogic);       -- data out
  end component;

  component tri_rlmreg_p
    generic (
      width       : integer := 4;
      offset      : integer range 0 to 65535 := 0 ; --starting bit
      init        : integer := 0;  -- will be converted to the least signficant
                                   -- 31 bits of init_v
      ibuf        : boolean := false;       --inverted latch IOs, if set to true.
      dualscan    : string  := ""; -- if "S", marks data ports as scan for Moebius
      needs_sreset: integer := 1 ; -- for inferred latches
      expand_type : integer := 1 );-- 0 = ibm (Umbra), 1 = non-ibm, 2 = ibm (MPG)
    port (
      vd      : inout power_logic;
      gd      : inout power_logic;
      nclk    : in  clk_logic;
      act     : in  std_ulogic := '1'; -- 1: functional, 0: no clock
      forcee   : in  std_ulogic := '0'; -- 1: force LCB active
      thold_b : in  std_ulogic := '1'; -- 1: functional, 0: no clock
      d_mode  : in  std_ulogic := '0'; -- 1: disable pulse mode, 0: pulse mode
      sg      : in  std_ulogic := '0'; -- 0: functional, 1: scan
      delay_lclkr : in  std_ulogic := '0'; -- 0: functional
      mpw1_b  : in  std_ulogic := '1'; -- pulse width control bit
      mpw2_b  : in  std_ulogic := '1'; -- pulse width control bit
      scin    : in  std_ulogic_vector(offset to offset+width-1);  -- scan in
      din     : in  std_ulogic_vector(offset to offset+width-1);  -- data in
      scout   : out std_ulogic_vector(offset to offset+width-1);
      dout    : out std_ulogic_vector(offset to offset+width-1) );
  end component;

  component tri_slat
   generic (
    width              : positive range 1 to 65536 := 1;
    offset             : natural range 0 to 65535  := 0;
    init               : std_ulogic_vector         := "0";
    synthclonedlatch   : string                    := "";
    reset_inverts_scan : boolean                   := true;
    expand_type        : integer                   := 1);  -- 1 - other (FPGA), 2 - MPG
   port (
    vd       : inout power_logic;
    gd       : inout power_logic;
    dclk     : in    std_ulogic;
    lclk     : in    clk_logic;
    scan_in  : in    std_ulogic;
    scan_out : out   std_ulogic;
    q        : out   std_ulogic_vector(offset to offset+width-1);
    q_b      : out   std_ulogic_vector(offset to offset+width-1));
  end component;

  component tri_slat_lbist
   generic (
    width              : positive range 1 to 65536 := 1;
    offset             : natural range 0 to 65535  := 0;
    init               : std_ulogic_vector         := "0";
    synthclonedlatch   : string                    := "";
    reset_inverts_scan : boolean                   := true;
    expand_type        : integer                   := 1);  -- 1 - other (FPGA), 2 - MPG
   port (
    vd       : inout power_logic;
    gd       : inout power_logic;
    dclk     : in    std_ulogic;
    lclk     : in    clk_logic;
    tc_xx_lbist_ac_mode_dc : in    std_ulogic;
    scan_in  : in    std_ulogic;
    scan_out : out   std_ulogic;
    q        : out   std_ulogic_vector(offset to offset+width-1);
    q_b      : out   std_ulogic_vector(offset to offset+width-1));
  end component;

  component tri_slat_scan
    generic (
            width              : positive range 1 to 65536 := 1 ;
            offset             : natural  range 0 to 65535 := 0;
            init               : std_ulogic_vector         := "0" ;
            synthclonedlatch   : string                    := "" ;
            btr                : string                    := "c_slat_scan" ;
            reset_inverts_scan : boolean                   := true;
            expand_type : integer := 1 ); -- 1 = non-ibm, 2 = ibm (MPG)
  port (
        vd       : inout power_logic;
        gd       : inout power_logic;
        dclk     : in    std_ulogic;
        lclk     : in    clk_logic;
        scan_in  : in    std_ulogic_vector(offset to offset+width-1);
        scan_out : out   std_ulogic_vector(offset to offset+width-1);
        q        : out   std_ulogic_vector(offset to offset+width-1);
        q_b      : out   std_ulogic_vector(offset to offset+width-1)
       );
  end component;

  component tri_ser_rlmreg_p
   generic (
      width             : positive range 1 to 65536 := 1 ;
      offset            : natural  range 0 to 65535 := 0 ;
      init              : integer := 0;
      ibuf              : boolean := false;
      dualscan          : string  := "";
      needs_sreset      : integer := 1 ;
      expand_type       : integer := 1 );
   port (
      vd                : inout power_logic;
      gd                : inout power_logic;
      nclk              : in  clk_logic;
      act               : in  std_ulogic := '1';
      forcee             : in  std_ulogic := '0';
      thold_b           : in  std_ulogic := '1';
      d_mode            : in  std_ulogic := '0';
      sg                : in  std_ulogic := '0';
      delay_lclkr       : in  std_ulogic := '0';
      mpw1_b            : in  std_ulogic := '1';
      mpw2_b            : in  std_ulogic := '1';
      scin              : in  std_ulogic_vector(offset to offset+width-1);
      din               : in  std_ulogic_vector(offset to offset+width-1);
      scout             : out std_ulogic_vector(offset to offset+width-1);
      dout              : out std_ulogic_vector(offset to offset+width-1));
   end component;

   component tri_aoi22_nlats_wlcb
    generic (
      width             : integer := 4;
      offset            : integer range 0 to 65535 := 0 ; --starting bit
      init              : integer := 0;  -- will be converted to the least signficant
                                 -- 31 bits of init_v
      ibuf              : boolean := false;       --inverted latch IOs, if set to true.
      dualscan          : string  := ""; -- if "S", marks data ports as scan for Moebius
      needs_sreset      : integer := 1 ; -- for inferred latches
      expand_type       : integer := 1 ; -- 0 = ibm (Umbra), 1 = non-ibm, 2 = ibm (MPG)
      synthclonedlatch  : string                    := "" ;
      btr               : string                    := "NLL0001_X2_A12TH" );
   port (
      vd                : inout power_logic;
      gd                : inout power_logic;
      nclk              : in  clk_logic;
      act               : in  std_ulogic := '1'; -- 1: functional, 0: no clock
      forcee             : in  std_ulogic := '0'; -- 1: force LCB active
      thold_b           : in  std_ulogic := '1'; -- 1: functional, 0: no clock
      d_mode            : in  std_ulogic := '0'; -- 1: disable pulse mode, 0: pulse mode
      sg                : in  std_ulogic := '0'; -- 0: functional, 1: scan
      delay_lclkr       : in  std_ulogic := '0'; -- 0: functional
      mpw1_b            : in  std_ulogic := '1'; -- pulse width control bit
      mpw2_b            : in  std_ulogic := '1'; -- pulse width control bit
      scin              : in  std_ulogic_vector(offset to offset+width-1);  -- scan in
      scout             : out std_ulogic_vector(offset to offset+width-1);
      A1                : in    std_ulogic_vector(offset to offset+width-1); 
      A2                : in    std_ulogic_vector(offset to offset+width-1); 
      B1                : in    std_ulogic_vector(offset to offset+width-1); 
      B2                : in    std_ulogic_vector(offset to offset+width-1); 
      QB                : out   std_ulogic_vector(offset to offset+width-1));
   end component;

end tri_latches_pkg;

package body tri_latches_pkg is

end tri_latches_pkg;
