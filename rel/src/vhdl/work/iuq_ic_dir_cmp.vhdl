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


library ieee,ibm,support,tri,work;
   use ieee.std_logic_1164.all;
   use ieee.numeric_std.all;
   use ibm.std_ulogic_unsigned.all;
   use ibm.std_ulogic_support.all; 
   use ibm.std_ulogic_function_support.all;
   use support.power_logic_pkg.all;
   use tri.tri_latches_pkg.all;
   use ibm.std_ulogic_ao_support.all;
   use ibm.std_ulogic_mux_support.all;

entity iuq_ic_dir_cmp is
generic( expand_type: integer := 2  ); -- 0 - ibm tech, 1 - other );
port(
       vdd                                       :inout power_logic;
       gnd                                       :inout power_logic;
       nclk                                      :in  clk_logic;
       delay_lclkr                               :in  std_ulogic;-- LCB input
       mpw1_b                                    :in  std_ulogic;-- LCB input
       mpw2_b                                    :in  std_ulogic;-- LCB input
       forcee                                    :in  std_ulogic;-- LCB input
       sg_0                                      :in  std_ulogic;-- LCB input
       thold_0_b                                 :in  std_ulogic;-- LCB input
       scan_in                                   :in  std_ulogic;--perv
       scan_out                                  :out std_ulogic;--perv

       dir_dataout_act                           :in  std_ulogic; --act

       iu2_endian                                :in  std_ulogic                  ;--LE
       ierat_iu_iu2_rpn                          :in  std_ulogic_vector(22 to 51) ;--erat
       iu2_dir_dataout_0_d                       :in  std_ulogic_vector(22 to 52) ;--directory
       iu2_dir_dataout_1_d                       :in  std_ulogic_vector(22 to 52) ;--directory
       iu2_dir_dataout_2_d                       :in  std_ulogic_vector(22 to 52) ;--directory
       iu2_dir_dataout_3_d                       :in  std_ulogic_vector(22 to 52) ;--directory

       ierat_iu_iu2_rpn_noncmp                   :out std_ulogic_vector(22 to 51) ;-- for noncritical uses of rpn
       iu2_dir_dataout_0_noncmp                  :out std_ulogic_vector(22 to 52) ;-- for spr mux
       iu2_dir_dataout_1_noncmp                  :out std_ulogic_vector(22 to 52) ;-- for spr mux
       iu2_dir_dataout_2_noncmp                  :out std_ulogic_vector(22 to 52) ;-- for spr mux
       iu2_dir_dataout_3_noncmp                  :out std_ulogic_vector(22 to 52) ;-- for spr mux

       iu2_dir_rd_val                            :in  std_ulogic_vector(0 to 3)  ;
       iu2_rd_way_tag_hit                        :out std_ulogic_vector(0 to 3)  ;-- excludes LE

       iu2_rd_way_hit                            :out std_ulogic_vector(0 to 3)  ;-- includes LE --2009jun22
       iu2_rd_way_hit_insmux_b                   :out std_ulogic_vector(0 to 3)   -- includes LE --2009jun22
);

-- synopsys translate_off


-- synopsys translate_on

end iuq_ic_dir_cmp; -- ENTITY

architecture iuq_ic_dir_cmp of iuq_ic_dir_cmp is

  constant tiup : std_ulogic := '1';
  constant tidn : std_ulogic := '0';

  signal dir_lclk  :clk_logic;
  signal dir_d1clk :std_ulogic;
  signal dir_d2clk :std_ulogic;

  signal iu2_dir_dataout_0_l2_b , dir0_q , dir0_si, dir0_so , dir0_slow_b :std_ulogic_vector(0 to 30) ;
  signal iu2_dir_dataout_1_l2_b , dir1_q , dir1_si, dir1_so , dir1_slow_b :std_ulogic_vector(0 to 30) ;
  signal iu2_dir_dataout_2_l2_b , dir2_q , dir2_si, dir2_so , dir2_slow_b :std_ulogic_vector(0 to 30) ;
  signal iu2_dir_dataout_3_l2_b , dir3_q , dir3_si, dir3_so , dir3_slow_b :std_ulogic_vector(0 to 30) ;
  signal dir_eq_b :std_ulogic_vector(0 to 3);

  signal dir_val_le_b, le_cmp :std_ulogic_vector(0 to 3) ;
-- synopsys translate_off

-- synopsys translate_on


  signal                         erat_i1_b                     :std_ulogic_vector(0 to 29) ;
-- synopsys translate_off
-- synopsys translate_on



-- synopsys translate_off
-- synopsys translate_on


  signal                         iu2_rd_way_hit_0     :std_ulogic_vector(0 to 3)  ;
  signal                         iu2_rd_way_hit_1x_b  :std_ulogic_vector(0 to 3)  ;
  signal                         iu2_rd_way_hit_1y_b  :std_ulogic_vector(0 to 3)  ;
  signal                         iu2_rd_way_hit_2x    :std_ulogic_vector(0 to 3)  ;
-- synopsys translate_off
-- synopsys translate_on

begin

-- ################################################################
-- # inverters from latches
-- ################################################################

   u_dir0_q: dir0_q(0 to 30) <= not( iu2_dir_dataout_0_l2_b(0 to 30) );
   u_dir1_q: dir1_q(0 to 30) <= not( iu2_dir_dataout_1_l2_b(0 to 30) );
   u_dir2_q: dir2_q(0 to 30) <= not( iu2_dir_dataout_2_l2_b(0 to 30) );
   u_dir3_q: dir3_q(0 to 30) <= not( iu2_dir_dataout_3_l2_b(0 to 30) );

   u_dir0_slowi: dir0_slow_b(0 to 30) <= not( dir0_q(0 to 30) );-- tiny
   u_dir1_slowi: dir1_slow_b(0 to 30) <= not( dir1_q(0 to 30) );-- tiny
   u_dir2_slowi: dir2_slow_b(0 to 30) <= not( dir2_q(0 to 30) );-- tiny
   u_dir3_slowi: dir3_slow_b(0 to 30) <= not( dir3_q(0 to 30) );-- tiny

   iu2_dir_dataout_0_noncmp(22 to 52) <= not dir0_slow_b(0 to 30) ;--output-- buffered off
   iu2_dir_dataout_1_noncmp(22 to 52) <= not dir1_slow_b(0 to 30) ;--output-- buffered off
   iu2_dir_dataout_2_noncmp(22 to 52) <= not dir2_slow_b(0 to 30) ;--output-- buffered off
   iu2_dir_dataout_3_noncmp(22 to 52) <= not dir3_slow_b(0 to 30) ;--output-- buffered off

   u_erat_i1: erat_i1_b(0 to 29) <= not( ierat_iu_iu2_rpn(22 to 51) );


   ierat_iu_iu2_rpn_noncmp(22 to 51) <= ierat_iu_iu2_rpn(22 to 51);

-- ################################################################
-- # directory compares against erat
-- ################################################################

 cmp0: entity work.iuq_ic_dir_cmp30(iuq_ic_dir_cmp30) port map(       
       d0_b(0 to 29) =>  erat_i1_b  (0 to 29)    ,--i--iuq_ic_dir_cmp30(dir0cmp)
       d1  (0 to 29) =>  dir0_q     (0 to 29)    ,--i--iuq_ic_dir_cmp30(dir0cmp)
       eq_b          =>  dir_eq_b(0)            );--o--iuq_ic_dir_cmp30(dir0cmp)

 cmp1: entity work.iuq_ic_dir_cmp30(iuq_ic_dir_cmp30) port map(       
       d0_b(0 to 29) =>  erat_i1_b  (0 to 29)    ,--i--iuq_ic_dir_cmp30(dir1cmp)
       d1  (0 to 29) =>  dir1_q     (0 to 29)    ,--i--iuq_ic_dir_cmp30(dir1cmp)
       eq_b          =>  dir_eq_b(1)            );--o--iuq_ic_dir_cmp30(dir1cmp)

 cmp2: entity work.iuq_ic_dir_cmp30(iuq_ic_dir_cmp30) port map(       
       d0_b(0 to 29) =>  erat_i1_b  (0 to 29)    ,--i--iuq_ic_dir_cmp30(dir2cmp)
       d1  (0 to 29) =>  dir2_q     (0 to 29)    ,--i--iuq_ic_dir_cmp30(dir2cmp)
       eq_b          =>  dir_eq_b(2)            );--o--iuq_ic_dir_cmp30(dir2cmp)

 cmp3: entity work.iuq_ic_dir_cmp30(iuq_ic_dir_cmp30) port map(       
       d0_b(0 to 29) =>  erat_i1_b  (0 to 29)    ,--i--iuq_ic_dir_cmp30(dir3cmp)
       d1  (0 to 29) =>  dir3_q     (0 to 29)    ,--i--iuq_ic_dir_cmp30(dir3cmp)
       eq_b          =>  dir_eq_b(3)            );--o--iuq_ic_dir_cmp30(dir3cmp)



  u_match30: iu2_rd_way_tag_hit(0 to 3) <= not( dir_eq_b(0 to 3) );
  u_match31: iu2_rd_way_hit_0(0 to 3) <= not( dir_eq_b(0 to 3) or dir_val_le_b(0 to 3) );                  

  u_match31_1x: iu2_rd_way_hit_1x_b    (0 to 3) <= not( iu2_rd_way_hit_0(0 to 3) ) ; --x11                 --2009jun22
  u_match31_1y: iu2_rd_way_hit_1y_b    (0 to 3) <= not( iu2_rd_way_hit_0(0 to 3) ) ; --x11                 --2009jun22

  u_match31_2x: iu2_rd_way_hit_2x      (0 to 3) <= not( iu2_rd_way_hit_1x_b(0 to 3) ) ; --x13              --2009jun22
                iu2_rd_way_hit         (0 to 3) <= not( iu2_rd_way_hit_1y_b(0 to 3) );--unsized --output-- --2009jun22

  u_match31_3x: iu2_rd_way_hit_insmux_b(0 to 3) <= not( iu2_rd_way_hit_2x  (0 to 3) ) ; --x13   --output-- --2009jun22




  dir_val_le_b(0 to 3) <= not( iu2_dir_rd_val(0 to 3) and le_cmp(0 to 3) ); -- not sized, not placed

  le_cmp(0) <= ( dir0_q(30) xnor iu2_endian );-- not sized, not placed
  le_cmp(1) <= ( dir1_q(30) xnor iu2_endian );-- not sized, not placed
  le_cmp(2) <= ( dir2_q(30) xnor iu2_endian );-- not sized, not placed
  le_cmp(3) <= ( dir3_q(30) xnor iu2_endian );-- not sized, not placed


-- ################################################################
-- # Latches
-- ################################################################

    iu2_dir_dataout_0_lat: entity tri.tri_inv_nlats   generic map (width => 31, btr=> "NLI0001_X2_A12TH", needs_sreset => 0, expand_type => expand_type) port map (
        VD             => vdd                               ,
        GD             => gnd                               ,
        LCLK           => dir_lclk                          ,
        D1CLK          => dir_d1clk                         ,
        D2CLK          => dir_d2clk                         ,
        SCANIN         => dir0_si                           ,
        SCANOUT        => dir0_so                           ,
        D              => iu2_dir_dataout_0_d(22 to 52)     ,
        QB             => iu2_dir_dataout_0_l2_b(0 to 30)  );

    iu2_dir_dataout_1_lat: entity tri.tri_inv_nlats   generic map (width => 31, btr=> "NLI0001_X2_A12TH", needs_sreset => 0, expand_type => expand_type) port map (
        VD             => vdd                              ,
        GD             => gnd                              ,
        LCLK           => dir_lclk                         ,
        D1CLK          => dir_d1clk                        ,
        D2CLK          => dir_d2clk                        ,
        SCANIN         => dir1_si                          ,
        SCANOUT        => dir1_so                          ,
        D              => iu2_dir_dataout_1_d(22 to 52)    ,
        QB             => iu2_dir_dataout_1_l2_b(0 to 30) );

    iu2_dir_dataout_2_lat: entity tri.tri_inv_nlats   generic map (width => 31, btr=> "NLI0001_X2_A12TH", needs_sreset => 0, expand_type => expand_type) port map (
        VD             => vdd                              ,
        GD             => gnd                              ,
        LCLK           => dir_lclk                         ,
        D1CLK          => dir_d1clk                        ,
        D2CLK          => dir_d2clk                        ,
        SCANIN         => dir2_si                          ,
        SCANOUT        => dir2_so                          ,
        D              => iu2_dir_dataout_2_d(22 to 52)    ,
        QB             => iu2_dir_dataout_2_l2_b(0 to 30) );

    iu2_dir_dataout_3_lat: entity tri.tri_inv_nlats   generic map (width => 31, btr=> "NLI0001_X2_A12TH", needs_sreset => 0, expand_type => expand_type) port map (
        VD             => vdd                              ,
        GD             => gnd                              ,
        LCLK           => dir_lclk                         ,
        D1CLK          => dir_d1clk                        ,
        D2CLK          => dir_d2clk                        ,
        SCANIN         => dir3_si                          ,
        SCANOUT        => dir3_so                          ,
        D              => iu2_dir_dataout_3_d(22 to 52)    ,
        QB             => iu2_dir_dataout_3_l2_b(0 to 30) );


   dir0_si(0 to 30) <= scan_in          & dir0_so(0 to 29);
   dir1_si(0 to 30) <= dir1_so(1 to 30) & dir0_so(30);
   dir2_si(0 to 30) <= dir1_so(0)       & dir2_so(0 to 29) ;
   dir3_si(0 to 30) <= dir3_so(1 to 30) & dir2_so(30) ;
   scan_out         <= dir3_so(0) ;

-- ###############################################################
-- # LCBs
-- ###############################################################

    dir_lcb : tri_lcbnd generic map (expand_type => expand_type) port map(
        nclk        =>  nclk                 ,--in
        vd          =>  vdd                  ,--inout
        gd          =>  gnd                  ,--inout
        act         =>  dir_dataout_act      ,--in
        delay_lclkr =>  delay_lclkr          ,--in
        mpw1_b      =>  mpw1_b               ,--in
        mpw2_b      =>  mpw2_b               ,--in
        forcee => forcee,--in
        sg          =>  sg_0                 ,--in
        thold_b     =>  thold_0_b            ,--in
        d1clk       =>  dir_d1clk            ,--out
        d2clk       =>  dir_d2clk            ,--out
        lclk        =>  dir_lclk            );--out


--=###############################################################



end; -- iuq_ic_dir_cmp ARCHITECTURE
