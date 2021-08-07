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

--
--  Description: Pervasive ABIST bolt-on sync and staging
--
--*****************************************************************************

library ieee;
use ieee.std_logic_1164.all;
library ibm;
use ibm.std_ulogic_support.all;
use ibm.std_ulogic_function_support.all;
library support;
use support.power_logic_pkg.all;
library tri;
use tri.tri_latches_pkg.all;

entity pcq_abist_bolton_stg is
generic(expand_type             : integer := 2);     -- 0=ibm (umbra), 1=non-ibm, 2=ibm (mpg)
port(
     vdd              : inout power_logic;
     gnd              : inout power_logic;
     nclk             : in    clk_logic;
     pc_pc_ccflush_dc : in    std_ulogic;

     pu_pc_bo_enable   : in std_ulogic;
     pu_pc_bo_go       : in std_ulogic;
     pu_pc_bo_cntlclk  : in std_ulogic;
     pu_pc_bo_reset    : in std_ulogic;
     pu_pc_bo_fcshdata : in std_ulogic;
     pu_pc_bo_fcreset  : in std_ulogic;

     pc_bx_bo_enable_3   : out std_ulogic;
     pc_fu_bo_enable_3   : out std_ulogic;
     pc_iu_bo_enable_4   : out std_ulogic;
     pc_mm_bo_enable_4   : out std_ulogic;
     pc_xu_bo_enable_3   : out std_ulogic;
     pc_pc_bo_go_0       : out std_ulogic;
     pc_pc_bo_enable_0   : out std_ulogic;
     pc_pc_bo_cntlclk_0  : out std_ulogic;
     pc_pc_bo_reset_0    : out std_ulogic;
     pc_pc_bo_fcshdata_0 : out std_ulogic;
     pc_pc_bo_fcreset_0  : out std_ulogic);

-- synopsys translate_off



-- synopsys translate_on
end pcq_abist_bolton_stg;

architecture pcq_abist_bolton_stg of pcq_abist_bolton_stg is

signal pc_all_bolton_enable_5     : std_ulogic;
signal pc_all_bolton_enable_4     : std_ulogic;
signal pc_all_bolton_enable_3_int : std_ulogic;
signal pc_pc_bolton_enable_2      : std_ulogic;
signal pc_pc_bolton_enable_1      : std_ulogic;
signal pc_pc_bolton_go_1          : std_ulogic;
signal pc_pc_bc_cntlclk_1         : std_ulogic;
signal pc_pc_bc_reset_1           : std_ulogic;
signal pc_pc_bc_fcshdata_1        : std_ulogic;
signal pc_pc_bc_fcreset_1         : std_ulogic;

begin

    bolton_enable_sync_meta : entity tri.tri_plat -- non-scan plats, cannot use tri_async_lt scan latch for this
    generic map(
      width       => 6,
      expand_type => expand_type)
    port map(
	vd     => vdd,
	gd     => gnd,
	nclk   => nclk,
	flush  => pc_pc_ccflush_dc,
	din(0) => pu_pc_bo_enable,
	din(1) => pu_pc_bo_go,
	din(2) => pu_pc_bo_cntlclk,
	din(3) => pu_pc_bo_reset,
	din(4) => pu_pc_bo_fcshdata,
	din(5) => pu_pc_bo_fcreset,
	q(0)   => pc_all_bolton_enable_5,
	q(1)   => pc_pc_bolton_go_1,
	q(2)   => pc_pc_bc_cntlclk_1,
	q(3)   => pc_pc_bc_reset_1,
	q(4)   => pc_pc_bc_fcshdata_1,
	q(5)   => pc_pc_bc_fcreset_1);

    bolton_enable_sync : entity tri.tri_plat -- non-scan plats, cannot use tri_async_lt scan latch for this
    generic map(
      width       => 6,
      expand_type => expand_type)
    port map(
	vd     => vdd,
	gd     => gnd,
	nclk   => nclk,
	flush  => pc_pc_ccflush_dc,
	din(0)   => pc_all_bolton_enable_5,
	din(1)   => pc_pc_bolton_go_1,
	din(2)   => pc_pc_bc_cntlclk_1,
	din(3)   => pc_pc_bc_reset_1,
	din(4)   => pc_pc_bc_fcshdata_1,
	din(5)   => pc_pc_bc_fcreset_1,
	q(0) => pc_all_bolton_enable_4,
	q(1) => pc_pc_bo_go_0,
	q(2) => pc_pc_bo_cntlclk_0,
	q(3) => pc_pc_bo_reset_0,
	q(4) => pc_pc_bo_fcshdata_0,
	q(5) => pc_pc_bo_fcreset_0);


    bolton_enable_sync_2 : entity tri.tri_plat -- non-scan plats, cannot use tri_async_lt scan latch for this
    generic map(
      width       => 4,
      expand_type => expand_type)
    port map(
	vd     => vdd,
	gd     => gnd,
	nclk   => nclk,
	flush  => pc_pc_ccflush_dc,
	din(0)   => pc_all_bolton_enable_4,
	din(1)   => pc_all_bolton_enable_3_int,
	din(2)   => pc_pc_bolton_enable_2,
	din(3)   => pc_pc_bolton_enable_1,
	q(0) => pc_all_bolton_enable_3_int,
	q(1) => pc_pc_bolton_enable_2,
	q(2) => pc_pc_bolton_enable_1,
	q(3) => pc_pc_bo_enable_0);


-- Splitting out bx/fu/xu unit bolton_enable signals 4to3 staging for placement + timing
    bx_bolton_enable_4_3 : entity tri.tri_plat
    generic map( width => 1, expand_type => expand_type)
    port map(
      vd     => vdd,
      gd     => gnd,
      nclk   => nclk,
      flush  => pc_pc_ccflush_dc,
      din(0) => pc_all_bolton_enable_4,
      q(0)   => pc_bx_bo_enable_3 );

    fu_bolton_enable_4_3 : entity tri.tri_plat
    generic map( width => 1, expand_type => expand_type)
    port map(
      vd     => vdd,
      gd     => gnd,
      nclk   => nclk,
      flush  => pc_pc_ccflush_dc,
      din(0) => pc_all_bolton_enable_4,
      q(0)   => pc_fu_bo_enable_3 );

    xu_bolton_enable_4_3 : entity tri.tri_plat
    generic map( width => 1, expand_type => expand_type)
    port map(
      vd     => vdd,
      gd     => gnd,
      nclk   => nclk,
      flush  => pc_pc_ccflush_dc,
      din(0) => pc_all_bolton_enable_4,
      q(0)   => pc_xu_bo_enable_3 );


-- Splitting out iu/mm unit bolton_enable signals 5to4 staging for placement + timing
    iu_bolton_enable_5_4 : entity tri.tri_plat
    generic map( width => 1, expand_type => expand_type)
    port map(
      vd     => vdd,
      gd     => gnd,
      nclk   => nclk,
      flush  => pc_pc_ccflush_dc,
      din(0) => pc_all_bolton_enable_5,
      q(0)   => pc_iu_bo_enable_4 );

    mm_bolton_enable_5_4 : entity tri.tri_plat
    generic map( width => 1, expand_type => expand_type)
    port map(
      vd     => vdd,
      gd     => gnd,
      nclk   => nclk,
      flush  => pc_pc_ccflush_dc,
      din(0) => pc_all_bolton_enable_5,
      q(0)   => pc_mm_bo_enable_4 );


end architecture pcq_abist_bolton_stg;
