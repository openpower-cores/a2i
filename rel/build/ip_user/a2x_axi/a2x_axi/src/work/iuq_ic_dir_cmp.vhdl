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
   use ieee.numeric_std.all;
   use ibm.std_ulogic_unsigned.all;
   use ibm.std_ulogic_support.all; 
   use ibm.std_ulogic_function_support.all;
   use support.power_logic_pkg.all;
   use tri.tri_latches_pkg.all;
   use ibm.std_ulogic_ao_support.all;
   use ibm.std_ulogic_mux_support.all;

entity iuq_ic_dir_cmp is
generic( expand_type: integer := 2  ); 
port(
       vdd                                       :inout power_logic;
       gnd                                       :inout power_logic;
       nclk                                      :in  clk_logic;
       delay_lclkr                               :in  std_ulogic;
       mpw1_b                                    :in  std_ulogic;
       mpw2_b                                    :in  std_ulogic;
       forcee                                    :in  std_ulogic;
       sg_0                                      :in  std_ulogic;
       thold_0_b                                 :in  std_ulogic;
       scan_in                                   :in  std_ulogic;
       scan_out                                  :out std_ulogic;

       dir_dataout_act                           :in  std_ulogic; 

       iu2_endian                                :in  std_ulogic                  ;
       ierat_iu_iu2_rpn                          :in  std_ulogic_vector(22 to 51) ;
       iu2_dir_dataout_0_d                       :in  std_ulogic_vector(22 to 52) ;
       iu2_dir_dataout_1_d                       :in  std_ulogic_vector(22 to 52) ;
       iu2_dir_dataout_2_d                       :in  std_ulogic_vector(22 to 52) ;
       iu2_dir_dataout_3_d                       :in  std_ulogic_vector(22 to 52) ;

       ierat_iu_iu2_rpn_noncmp                   :out std_ulogic_vector(22 to 51) ;
       iu2_dir_dataout_0_noncmp                  :out std_ulogic_vector(22 to 52) ;
       iu2_dir_dataout_1_noncmp                  :out std_ulogic_vector(22 to 52) ;
       iu2_dir_dataout_2_noncmp                  :out std_ulogic_vector(22 to 52) ;
       iu2_dir_dataout_3_noncmp                  :out std_ulogic_vector(22 to 52) ;

       iu2_dir_rd_val                            :in  std_ulogic_vector(0 to 3)  ;
       iu2_rd_way_tag_hit                        :out std_ulogic_vector(0 to 3)  ;

       iu2_rd_way_hit                            :out std_ulogic_vector(0 to 3)  ;
       iu2_rd_way_hit_insmux_b                   :out std_ulogic_vector(0 to 3)   
);

-- synopsys translate_off


-- synopsys translate_on

end iuq_ic_dir_cmp; 

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


   u_dir0_q: dir0_q(0 to 30) <= not( iu2_dir_dataout_0_l2_b(0 to 30) );
   u_dir1_q: dir1_q(0 to 30) <= not( iu2_dir_dataout_1_l2_b(0 to 30) );
   u_dir2_q: dir2_q(0 to 30) <= not( iu2_dir_dataout_2_l2_b(0 to 30) );
   u_dir3_q: dir3_q(0 to 30) <= not( iu2_dir_dataout_3_l2_b(0 to 30) );

   u_dir0_slowi: dir0_slow_b(0 to 30) <= not( dir0_q(0 to 30) );
   u_dir1_slowi: dir1_slow_b(0 to 30) <= not( dir1_q(0 to 30) );
   u_dir2_slowi: dir2_slow_b(0 to 30) <= not( dir2_q(0 to 30) );
   u_dir3_slowi: dir3_slow_b(0 to 30) <= not( dir3_q(0 to 30) );

   iu2_dir_dataout_0_noncmp(22 to 52) <= not dir0_slow_b(0 to 30) ;
   iu2_dir_dataout_1_noncmp(22 to 52) <= not dir1_slow_b(0 to 30) ;
   iu2_dir_dataout_2_noncmp(22 to 52) <= not dir2_slow_b(0 to 30) ;
   iu2_dir_dataout_3_noncmp(22 to 52) <= not dir3_slow_b(0 to 30) ;

   u_erat_i1: erat_i1_b(0 to 29) <= not( ierat_iu_iu2_rpn(22 to 51) );


   ierat_iu_iu2_rpn_noncmp(22 to 51) <= ierat_iu_iu2_rpn(22 to 51);


 cmp0: entity work.iuq_ic_dir_cmp30(iuq_ic_dir_cmp30) port map(       
       d0_b(0 to 29) =>  erat_i1_b  (0 to 29)    ,
       d1  (0 to 29) =>  dir0_q     (0 to 29)    ,
       eq_b          =>  dir_eq_b(0)            );

 cmp1: entity work.iuq_ic_dir_cmp30(iuq_ic_dir_cmp30) port map(       
       d0_b(0 to 29) =>  erat_i1_b  (0 to 29)    ,
       d1  (0 to 29) =>  dir1_q     (0 to 29)    ,
       eq_b          =>  dir_eq_b(1)            );

 cmp2: entity work.iuq_ic_dir_cmp30(iuq_ic_dir_cmp30) port map(       
       d0_b(0 to 29) =>  erat_i1_b  (0 to 29)    ,
       d1  (0 to 29) =>  dir2_q     (0 to 29)    ,
       eq_b          =>  dir_eq_b(2)            );

 cmp3: entity work.iuq_ic_dir_cmp30(iuq_ic_dir_cmp30) port map(       
       d0_b(0 to 29) =>  erat_i1_b  (0 to 29)    ,
       d1  (0 to 29) =>  dir3_q     (0 to 29)    ,
       eq_b          =>  dir_eq_b(3)            );



  u_match30: iu2_rd_way_tag_hit(0 to 3) <= not( dir_eq_b(0 to 3) );
  u_match31: iu2_rd_way_hit_0(0 to 3) <= not( dir_eq_b(0 to 3) or dir_val_le_b(0 to 3) );                  

  u_match31_1x: iu2_rd_way_hit_1x_b    (0 to 3) <= not( iu2_rd_way_hit_0(0 to 3) ) ; 
  u_match31_1y: iu2_rd_way_hit_1y_b    (0 to 3) <= not( iu2_rd_way_hit_0(0 to 3) ) ; 

  u_match31_2x: iu2_rd_way_hit_2x      (0 to 3) <= not( iu2_rd_way_hit_1x_b(0 to 3) ) ; 
                iu2_rd_way_hit         (0 to 3) <= not( iu2_rd_way_hit_1y_b(0 to 3) );

  u_match31_3x: iu2_rd_way_hit_insmux_b(0 to 3) <= not( iu2_rd_way_hit_2x  (0 to 3) ) ; 




  dir_val_le_b(0 to 3) <= not( iu2_dir_rd_val(0 to 3) and le_cmp(0 to 3) ); 

  le_cmp(0) <= ( dir0_q(30) xnor iu2_endian );
  le_cmp(1) <= ( dir1_q(30) xnor iu2_endian );
  le_cmp(2) <= ( dir2_q(30) xnor iu2_endian );
  le_cmp(3) <= ( dir3_q(30) xnor iu2_endian );



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


    dir_lcb : tri_lcbnd generic map (expand_type => expand_type) port map(
        nclk        =>  nclk                 ,
        vd          =>  vdd                  ,
        gd          =>  gnd                  ,
        act         =>  dir_dataout_act      ,
        delay_lclkr =>  delay_lclkr          ,
        mpw1_b      =>  mpw1_b               ,
        mpw2_b      =>  mpw2_b               ,
        forcee => forcee,
        sg          =>  sg_0                 ,
        thold_b     =>  thold_0_b            ,
        d1clk       =>  dir_d1clk            ,
        d2clk       =>  dir_d2clk            ,
        lclk        =>  dir_lclk            );






end; 

