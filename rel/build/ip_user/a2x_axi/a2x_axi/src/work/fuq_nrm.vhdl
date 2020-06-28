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

 
entity fuq_nrm is 
generic(       expand_type               : integer := 2  ); 
port( 
 
       vdd                                       :inout power_logic;
       gnd                                       :inout power_logic;
       clkoff_b                                  :in   std_ulogic; 
       act_dis                                   :in   std_ulogic; 
       flush                                     :in   std_ulogic; 
       delay_lclkr                               :in   std_ulogic_vector(4 to 5); 
       mpw1_b                                    :in   std_ulogic_vector(4 to 5); 
       mpw2_b                                    :in   std_ulogic_vector(0 to 1); 
       sg_1                                      :in   std_ulogic;
       thold_1                                   :in   std_ulogic;
       fpu_enable                                :in   std_ulogic; 
       nclk                                      :in   clk_logic;

       f_nrm_si                                 :in   std_ulogic                   ;
       f_nrm_so                                 :out  std_ulogic                   ;
       ex3_act_b                                :in   std_ulogic                   ;

       f_lza_ex4_lza_amt_cp1                    :in   std_ulogic_vector(0 to 7)    ;

       f_lza_ex4_lza_dcd64_cp1                  :in   std_ulogic_vector(0 to 2);    
       f_lza_ex4_lza_dcd64_cp2                  :in   std_ulogic_vector(0 to 1);    
       f_lza_ex4_lza_dcd64_cp3                  :in   std_ulogic_vector(0 to 0);    
       f_lza_ex4_sh_rgt_en                      :in   std_ulogic;

       f_add_ex4_res                             :in   std_ulogic_vector(0 to 162)  ;
       f_add_ex4_sticky                          :in   std_ulogic                   ;
       f_pic_ex4_byp_prod_nz                     :in   std_ulogic                   ;
       f_nrm_ex5_res                             :out  std_ulogic_vector(0 to 52)    ;
       f_nrm_ex5_int_sign                        :out  std_ulogic                   ;
       f_nrm_ex5_int_lsbs                        :out  std_ulogic_vector(1 to 12)    ;
       f_nrm_ex5_nrm_sticky_dp                   :out  std_ulogic                    ;
       f_nrm_ex5_nrm_guard_dp                    :out  std_ulogic                    ;
       f_nrm_ex5_nrm_lsb_dp                      :out  std_ulogic                    ;
       f_nrm_ex5_nrm_sticky_sp                   :out  std_ulogic                    ;
       f_nrm_ex5_nrm_guard_sp                    :out  std_ulogic                    ;
       f_nrm_ex5_nrm_lsb_sp                      :out  std_ulogic                    ;
       f_nrm_ex5_exact_zero                      :out  std_ulogic                    ;
       f_nrm_ex4_extra_shift                     :out  std_ulogic                    ;
       f_nrm_ex5_fpscr_wr_dat_dfp                :out  std_ulogic_vector(0 to 3)     ;
       f_nrm_ex5_fpscr_wr_dat                    :out  std_ulogic_vector(0 to 31)     


); 
 
 


end fuq_nrm; 
 
 
architecture fuq_nrm of fuq_nrm is 
 
    constant tiup  :std_ulogic := '1';
    constant tidn  :std_ulogic := '0';
 
    signal sg_0                                  :std_ulogic                   ;
    signal thold_0_b, thold_0, forcee              :std_ulogic                   ;
    signal ex3_act                                 :std_ulogic                   ;
    signal ex4_act                                 :std_ulogic                   ;
    signal act_spare_unused                        :std_ulogic_vector(0 to 2)    ;
    signal act_so                                  :std_ulogic_vector(0 to 3)    ;
    signal act_si                                  :std_ulogic_vector(0 to 3)    ;
    signal ex5_res_so                              :std_ulogic_vector(0 to 52)   ;
    signal ex5_res_si                              :std_ulogic_vector(0 to 52)   ;
    signal ex5_nrm_lg_so                           :std_ulogic_vector(0 to 3)    ;
    signal ex5_nrm_lg_si                           :std_ulogic_vector(0 to 3)    ;
    signal ex5_nrm_x_so                            :std_ulogic_vector(0 to 2)    ;
    signal ex5_nrm_x_si                            :std_ulogic_vector(0 to 2)    ;
    signal ex5_nrm_pass_so                         :std_ulogic_vector(0 to 12)   ;
    signal ex5_nrm_pass_si                         :std_ulogic_vector(0 to 12)   ;
    signal ex5_fmv_so                              :std_ulogic_vector(0 to 35)   ;
    signal ex5_fmv_si                              :std_ulogic_vector(0 to 35)   ;
    signal ex4_sh2                                 :std_ulogic_vector(26 to 72) ;
    signal ex4_sh4_25                              :std_ulogic  ;
    signal ex4_sh4_54                              :std_ulogic  ;
    signal ex4_nrm_res   , ex4_sh5_x_b, ex4_sh5_y_b                          :std_ulogic_vector(0 to  53)  ;
    signal ex4_lt064_x                             :std_ulogic                   ;
    signal ex4_lt128_x                             :std_ulogic                   ;
    signal ex4_lt016_x                             :std_ulogic                   ;
    signal ex4_lt032_x                             :std_ulogic                   ;
    signal ex4_lt048_x                             :std_ulogic                   ;
    signal ex4_lt016                               :std_ulogic                   ;
    signal ex4_lt032                               :std_ulogic                   ;
    signal ex4_lt048                               :std_ulogic                   ;
    signal ex4_lt064                               :std_ulogic                   ;
    signal ex4_lt080                               :std_ulogic                   ;
    signal ex4_lt096                               :std_ulogic                   ;
    signal ex4_lt112                               :std_ulogic                   ;
    signal ex4_lt128                               :std_ulogic                   ;
    signal ex4_lt04_x                              :std_ulogic                   ;
    signal ex4_lt08_x                              :std_ulogic                   ;
    signal ex4_lt12_x                              :std_ulogic                   ;
    signal ex4_lt01_x                              :std_ulogic                   ;
    signal ex4_lt02_x                              :std_ulogic                   ;
    signal ex4_lt03_x                              :std_ulogic                   ;
    signal ex4_sticky_sp                           :std_ulogic                   ;
    signal ex4_sticky_dp                           :std_ulogic                   ;
    signal ex4_sticky16_dp                         :std_ulogic                   ;
    signal ex4_sticky16_sp                         :std_ulogic                   ;
    signal ex4_or_grp16                            :std_ulogic_vector(0 to 10)   ;
    signal ex4_lt                                  :std_ulogic_vector(0 to 14)   ;
    signal ex4_exact_zero                          :std_ulogic                   ;
    signal ex4_exact_zero_b                        :std_ulogic                   ;
    signal ex5_res                                 :std_ulogic_vector(0 to 52);  
    signal ex5_nrm_sticky_dp                       :std_ulogic;
    signal ex5_nrm_guard_dp                        :std_ulogic;
    signal ex5_nrm_lsb_dp                          :std_ulogic;
    signal ex5_nrm_sticky_sp                       :std_ulogic;
    signal ex5_nrm_guard_sp                        :std_ulogic;
    signal ex5_nrm_lsb_sp                          :std_ulogic;
    signal ex5_exact_zero                          :std_ulogic;
    signal ex5_int_sign                            :std_ulogic;
    signal ex5_int_lsbs                            :std_ulogic_vector(1 to 12);
    signal ex5_fpscr_wr_dat                      :std_ulogic_vector(0 to 31);
    signal ex5_fpscr_wr_dat_dfp                  :std_ulogic_vector(0 to 3);
    signal ex4_rgt_4more, ex4_rgt_3more, ex4_rgt_2more   :std_ulogic;
    signal ex4_shift_extra_cp2 :std_ulogic;
    signal unused :std_ulogic;

  signal ex4_sticky_dp_x2_b, ex4_sticky_dp_x1_b, ex4_sticky_dp_x1 :std_ulogic;
  signal ex4_sticky_sp_x2_b, ex4_sticky_sp_x1_b, ex4_sticky_sp_x1 :std_ulogic;
   signal ex5_d1clk, ex5_d2clk :std_ulogic ; 
   signal ex5_lclk :clk_logic; 
    signal ex4_sticky_stuff :std_ulogic ;




begin

  unused <= or_reduce( ex4_sh2(41 to 54) ) or  
            or_reduce( ex4_nrm_res(0 to 53) ) or  
            ex4_sticky_sp    or   
            ex4_sticky_dp    or   
            ex4_exact_zero   ;    

    
    
    thold_reg_0:  tri_plat  generic map (expand_type => expand_type) port map (
         vd        => vdd,
         gd        => gnd,
         nclk      => nclk,  
         flush     => flush ,
         din(0)    => thold_1,   
         q(0)      => thold_0  ); 
    
    sg_reg_0:  tri_plat     generic map (expand_type => expand_type) port map (
         vd        => vdd,
         gd        => gnd,
         nclk      => nclk,
         flush     => flush ,
         din(0)    => sg_1  ,     
         q(0)      => sg_0  );   


    lcbor_0: tri_lcbor generic map (expand_type => expand_type ) port map (
        clkoff_b     => clkoff_b,
        thold        => thold_0,  
        sg           => sg_0,
        act_dis      => act_dis,
        forcee => forcee,
        thold_b      => thold_0_b );

    ex5_lcb : tri_lcbnd generic map (expand_type => expand_type) port map( 
        delay_lclkr =>  delay_lclkr(5) ,
        mpw1_b      =>  mpw1_b(5)      ,
        mpw2_b      =>  mpw2_b(1)      ,
        forcee => forcee,
        nclk        =>  nclk        ,
        vd          =>  vdd         ,
        gd          =>  gnd         ,
        act         =>  ex4_act     ,
        sg          =>  sg_0        ,
        thold_b     =>  thold_0_b   ,
        d1clk       =>  ex5_d1clk   ,
        d2clk       =>  ex5_d2clk   ,
        lclk        =>  ex5_lclk   );





    ex3_act <= not ex3_act_b ;

    act_lat:  tri_rlmreg_p generic map (width=> 4, expand_type => expand_type, needs_sreset => 0) port map ( 
        forcee => forcee,
        delay_lclkr      => delay_lclkr(4)  ,
        mpw1_b           => mpw1_b(4)       ,
        mpw2_b           => mpw2_b(0)       ,
        vd               => vdd,
        gd               => gnd,
        nclk             => nclk, 
        thold_b          => thold_0_b,
        sg               => sg_0, 
        act              => fpu_enable, 
        scout            => act_so  (0 to 3),                      
        scin             => act_si  (0 to 3),                    
         din(0)             => act_spare_unused(0),
         din(1)             => act_spare_unused(1),
         din(2)             => ex3_act,
         din(3)             => act_spare_unused(2),
        dout(0)             => act_spare_unused(0),
        dout(1)             => act_spare_unused(1),
        dout(2)             => ex4_act,
        dout(3)             => act_spare_unused(2) );


 sh: entity work.fuq_nrm_sh(fuq_nrm_sh) generic map (expand_type => expand_type) port map(
      f_lza_ex4_sh_rgt_en                => f_lza_ex4_sh_rgt_en               ,
      f_lza_ex4_lza_amt_cp1(2 to 7)      => f_lza_ex4_lza_amt_cp1(2 to 7)     ,
      f_lza_ex4_lza_dcd64_cp1(0 to 2)    => f_lza_ex4_lza_dcd64_cp1(0 to 2)   ,
      f_lza_ex4_lza_dcd64_cp2(0 to 1)    => f_lza_ex4_lza_dcd64_cp2(0 to 1)   ,
      f_lza_ex4_lza_dcd64_cp3(0 to 0)    => f_lza_ex4_lza_dcd64_cp3(0 to 0)   ,
      f_add_ex4_res(0 to 162)            => f_add_ex4_res(0 to 162)           ,
      ex4_shift_extra_cp1                => f_nrm_ex4_extra_shift             ,
      ex4_shift_extra_cp2                => ex4_shift_extra_cp2               ,
      ex4_sh4_25                         => ex4_sh4_25                        ,
      ex4_sh4_54                         => ex4_sh4_54                        ,
      ex4_sh2_o(26 to 72)                => ex4_sh2(26 to 72)                 ,
      ex4_sh5_x_b(0 to 53)               => ex4_sh5_x_b(0 to 53)              ,
      ex4_sh5_y_b(0 to 53)               => ex4_sh5_y_b(0 to 53)             );

     ex4_nrm_res(0 to 53) <= not( ex4_sh5_x_b(0 to 53) and ex4_sh5_y_b(0 to 53) ) ; 



  ex4_lt064_x <= not( f_lza_ex4_lza_amt_cp1(0) or  f_lza_ex4_lza_amt_cp1(1) ); 
  ex4_lt128_x <= not( f_lza_ex4_lza_amt_cp1(0)                              ); 
 
  ex4_lt016_x <= not( f_lza_ex4_lza_amt_cp1(2) or  f_lza_ex4_lza_amt_cp1(3) ); 
  ex4_lt032_x <= not( f_lza_ex4_lza_amt_cp1(2)                              ); 
  ex4_lt048_x <= not( f_lza_ex4_lza_amt_cp1(2) and f_lza_ex4_lza_amt_cp1(3) ); 

  ex4_lt016   <=                 ex4_lt064_x and ex4_lt016_x ; 
  ex4_lt032   <=                 ex4_lt064_x and ex4_lt032_x ; 
  ex4_lt048   <=                 ex4_lt064_x and ex4_lt048_x ; 
  ex4_lt064   <=                 ex4_lt064_x                 ; 
  ex4_lt080   <= ex4_lt064_x or (ex4_lt128_x and ex4_lt016_x); 
  ex4_lt096   <= ex4_lt064_x or (ex4_lt128_x and ex4_lt032_x); 
  ex4_lt112   <= ex4_lt064_x or (ex4_lt128_x and ex4_lt048_x); 
  ex4_lt128   <=                 ex4_lt128_x                 ; 




  

  ex4_rgt_2more  <= f_lza_ex4_sh_rgt_en and ( not f_lza_ex4_lza_amt_cp1(2) or  not f_lza_ex4_lza_amt_cp1(3) ); 
  ex4_rgt_3more  <= f_lza_ex4_sh_rgt_en and ( not f_lza_ex4_lza_amt_cp1(2)                                  ); 
  ex4_rgt_4more  <= f_lza_ex4_sh_rgt_en and ( not f_lza_ex4_lza_amt_cp1(2) and not f_lza_ex4_lza_amt_cp1(3) ); 




 or16: entity work.fuq_nrm_or16(fuq_nrm_or16) generic map (expand_type => expand_type) port map(
      f_add_ex4_res(0 to 162)            => f_add_ex4_res(0 to 162)           ,
      ex4_or_grp16(0 to 10)              => ex4_or_grp16(0 to 10)            );




    ex4_sticky_stuff <= 
        ( f_pic_ex4_byp_prod_nz          ) or 
        ( f_add_ex4_sticky               ) ;

    ex4_sticky16_dp <=
        ( ex4_or_grp16(1)  and               ex4_rgt_4more        ) or 
        ( ex4_or_grp16(2)  and               ex4_rgt_3more        ) or 
        ( ex4_or_grp16(3)  and               ex4_rgt_2more        ) or 
        ( ex4_or_grp16(4)  and               f_lza_ex4_sh_rgt_en  ) or 
        ( ex4_or_grp16(5)  and (ex4_lt016 or f_lza_ex4_sh_rgt_en) ) or 
        ( ex4_or_grp16(6)  and (ex4_lt032 or f_lza_ex4_sh_rgt_en) ) or 
        ( ex4_or_grp16(7)  and (ex4_lt048 or f_lza_ex4_sh_rgt_en) ) or 
        ( ex4_or_grp16(8)  and (ex4_lt064 or f_lza_ex4_sh_rgt_en) ) or 
        ( ex4_or_grp16(9)  and (ex4_lt080 or f_lza_ex4_sh_rgt_en) ) or 
        ( ex4_or_grp16(10) and (ex4_lt096 or f_lza_ex4_sh_rgt_en) ) or 
        ( ex4_sh2(70)                    ) or 
        ( ex4_sh2(71)                    ) or 
        ( ex4_sh2(72)                    ) or 
        ( ex4_sticky_stuff               ) ;

    ex4_sticky16_sp <=
        ( ex4_or_grp16(0)  and               ex4_rgt_3more         ) or 
        ( ex4_or_grp16(1)  and               ex4_rgt_2more         ) or 
        ( ex4_or_grp16(2)  and               f_lza_ex4_sh_rgt_en   ) or 
        ( ex4_or_grp16(3)  and (ex4_lt016 or f_lza_ex4_sh_rgt_en)  ) or 
        ( ex4_or_grp16(4)  and (ex4_lt032 or f_lza_ex4_sh_rgt_en)  ) or 
        ( ex4_or_grp16(5)  and (ex4_lt048 or f_lza_ex4_sh_rgt_en)  ) or 
        ( ex4_or_grp16(6)  and (ex4_lt064 or f_lza_ex4_sh_rgt_en)  ) or 
        ( ex4_or_grp16(7)  and (ex4_lt080 or f_lza_ex4_sh_rgt_en)  ) or 
        ( ex4_or_grp16(8)  and (ex4_lt096 or f_lza_ex4_sh_rgt_en)  ) or 
        ( ex4_or_grp16(9)  and (ex4_lt112 or f_lza_ex4_sh_rgt_en)  ) or 
        ( ex4_or_grp16(10) and (ex4_lt128 or f_lza_ex4_sh_rgt_en)  ) or 
        ( ex4_sticky_stuff               ) ;

    ex4_exact_zero_b <=
            ex4_or_grp16(0) or 
            ex4_or_grp16(1) or 
            ex4_or_grp16(2) or 
            ex4_or_grp16(3) or 
            ex4_or_grp16(4) or 
            ex4_or_grp16(5) or 
            ex4_or_grp16(6) or 
            ex4_or_grp16(7) or 
            ex4_or_grp16(8) or 
            ex4_or_grp16(9) or 
            ex4_or_grp16(10) or 
        ( ex4_sticky_stuff               ) ;


    ex4_exact_zero <= not ex4_exact_zero_b ;


  ex4_lt04_x <= not( f_lza_ex4_lza_amt_cp1(4) or  f_lza_ex4_lza_amt_cp1(5) ); 
  ex4_lt08_x <= not( f_lza_ex4_lza_amt_cp1(4)                              ); 
  ex4_lt12_x <= not( f_lza_ex4_lza_amt_cp1(4) and f_lza_ex4_lza_amt_cp1(5) ); 

  ex4_lt01_x <= not( f_lza_ex4_lza_amt_cp1(6) or  f_lza_ex4_lza_amt_cp1(7) ); 
  ex4_lt02_x <= not( f_lza_ex4_lza_amt_cp1(6)                              ); 
  ex4_lt03_x <= not( f_lza_ex4_lza_amt_cp1(6) and f_lza_ex4_lza_amt_cp1(7) ); 

  ex4_lt(0)   <=                 ex4_lt04_x and ex4_lt01_x ; 
  ex4_lt(1)   <=                 ex4_lt04_x and ex4_lt02_x ; 
  ex4_lt(2)   <=                 ex4_lt04_x and ex4_lt03_x ; 
  ex4_lt(3)   <=                 ex4_lt04_x                ; 

  ex4_lt(4)   <=  ex4_lt04_x or (ex4_lt08_x and ex4_lt01_x); 
  ex4_lt(5)   <=  ex4_lt04_x or (ex4_lt08_x and ex4_lt02_x); 
  ex4_lt(6)   <=  ex4_lt04_x or (ex4_lt08_x and ex4_lt03_x); 
  ex4_lt(7)   <=                (ex4_lt08_x               ); 

  ex4_lt(8)   <=  ex4_lt08_x or (ex4_lt12_x and ex4_lt01_x); 
  ex4_lt(9)   <=  ex4_lt08_x or (ex4_lt12_x and ex4_lt02_x); 
  ex4_lt(10)  <=  ex4_lt08_x or (ex4_lt12_x and ex4_lt03_x); 
  ex4_lt(11)  <=                (ex4_lt12_x               ); 

  ex4_lt(12)  <=  ex4_lt12_x or                 ex4_lt01_x ; 
  ex4_lt(13)  <=  ex4_lt12_x or                 ex4_lt02_x ; 
  ex4_lt(14)  <=  ex4_lt12_x or                 ex4_lt03_x ; 


    ex4_sticky_sp_x1 <= 
       (ex4_lt(14)      and ex4_sh2(40)  ) or  
       (ex4_lt(13)      and ex4_sh2(39)  ) or  
       (ex4_lt(12)      and ex4_sh2(38)  ) or  
       (ex4_lt(11)      and ex4_sh2(37)  ) or  
       (ex4_lt(10)      and ex4_sh2(36)  ) or  
       (ex4_lt(9)       and ex4_sh2(35)  ) or  
       (ex4_lt(8)       and ex4_sh2(34)  ) or  
       (ex4_lt(7)       and ex4_sh2(33)  ) or  
       (ex4_lt(6)       and ex4_sh2(32)  ) or  
       (ex4_lt(5)       and ex4_sh2(31)  ) or  
       (ex4_lt(4)       and ex4_sh2(30)  ) or  
       (ex4_lt(3)       and ex4_sh2(29)  ) or  
       (ex4_lt(2)       and ex4_sh2(28)  ) or  
       (ex4_lt(1)       and ex4_sh2(27)  ) or  
       (ex4_lt(0)       and ex4_sh2(26)  ) or  
       (ex4_sticky16_sp                  ) ;


   ex4_sticky_sp_x2_b <= not(not ex4_shift_extra_cp2 and ex4_sh4_25   );
   ex4_sticky_sp_x1_b <= not  ex4_sticky_sp_x1 ;
   ex4_sticky_sp      <= not( ex4_sticky_sp_x1_b and ex4_sticky_sp_x2_b );

          


    ex4_sticky_dp_x1 <=
       (ex4_lt(14)      and ex4_sh2(69)  ) or  
       (ex4_lt(13)      and ex4_sh2(68)  ) or  
       (ex4_lt(12)      and ex4_sh2(67)  ) or  
       (ex4_lt(11)      and ex4_sh2(66)  ) or  
       (ex4_lt(10)      and ex4_sh2(65)  ) or  
       (ex4_lt(9)       and ex4_sh2(64)  ) or  
       (ex4_lt(8)       and ex4_sh2(63)  ) or  
       (ex4_lt(7)       and ex4_sh2(62)  ) or  
       (ex4_lt(6)       and ex4_sh2(61)  ) or  
       (ex4_lt(5)       and ex4_sh2(60)  ) or  
       (ex4_lt(4)       and ex4_sh2(59)  ) or  
       (ex4_lt(3)       and ex4_sh2(58)  ) or  
       (ex4_lt(2)       and ex4_sh2(57)  ) or  
       (ex4_lt(1)       and ex4_sh2(56)  ) or  
       (ex4_lt(0)       and ex4_sh2(55)  ) or  
       (ex4_sticky16_dp                  ) ;

   ex4_sticky_dp_x2_b <= not(not ex4_shift_extra_cp2 and  ex4_sh4_54 ) ;
   ex4_sticky_dp_x1_b <= not  ex4_sticky_dp_x1 ;
   ex4_sticky_dp      <= not( ex4_sticky_dp_x1_b and ex4_sticky_dp_x2_b );

 
 


    ex5_res_lat:  entity tri.tri_nand2_nlats(tri_nand2_nlats) generic map (width=> 53, btr => "NLA0001_X1_A12TH", expand_type => expand_type, needs_sreset => 0) port map ( 
        vd               => vdd,
        gd               => gnd,
        LCLK             => ex5_lclk              ,
        D1CLK            => ex5_d1clk             ,
        D2CLK            => ex5_d2clk             ,
        SCANIN           => ex5_res_si            ,                    
        SCANOUT          => ex5_res_so            ,                      
        A1               => ex4_sh5_x_b(0 to 52)  ,   
        A2               => ex4_sh5_y_b(0 to 52)  ,
        QB               => ex5_res(0 to 52)     );

    ex5_nrm_lg_lat: entity tri.tri_nand2_nlats(tri_nand2_nlats) generic map (width=> 4, btr => "NLA0001_X1_A12TH", expand_type => expand_type, needs_sreset => 0 ) port map ( 
        vd               => vdd,
        gd               => gnd,
        LCLK             => ex5_lclk              ,
        D1CLK            => ex5_d1clk             ,
        D2CLK            => ex5_d2clk             ,
        SCANIN           => ex5_nrm_lg_si         ,                    
        SCANOUT          => ex5_nrm_lg_so         ,                      
        A1(0)            => ex4_sh5_x_b(23)       ,
        A1(1)            => ex4_sh5_x_b(24)       ,
        A1(2)            => ex4_sh5_x_b(52)       ,
        A1(3)            => ex4_sh5_x_b(53)       ,
        A2(0)            => ex4_sh5_y_b(23)       ,
        A2(1)            => ex4_sh5_y_b(24)       ,
        A2(2)            => ex4_sh5_y_b(52)       ,
        A2(3)            => ex4_sh5_y_b(53)       ,
        QB(0)            => ex5_nrm_lsb_sp             ,
        QB(1)            => ex5_nrm_guard_sp           ,
        QB(2)            => ex5_nrm_lsb_dp             ,
        QB(3)            => ex5_nrm_guard_dp          );





    ex5_nrm_x_lat:  entity tri.tri_nand2_nlats(tri_nand2_nlats) generic map (width=> 3, btr => "NLA0001_X1_A12TH", expand_type => expand_type, needs_sreset => 0 ) port map ( 
        vd               => vdd,
        gd               => gnd,
        LCLK             => ex5_lclk              ,
        D1CLK            => ex5_d1clk             ,
        D2CLK            => ex5_d2clk             ,
        SCANIN           => ex5_nrm_x_si          ,                    
        SCANOUT          => ex5_nrm_x_so          ,                      
        A1(0)            => ex4_sticky_sp_x2_b    ,
        A1(1)            => ex4_sticky_dp_x2_b    , 
        A1(2)            => ex4_exact_zero_b      ,
        A2(0)            => ex4_sticky_sp_x1_b    ,
        A2(1)            => ex4_sticky_dp_x1_b    , 
        A2(2)            => tiup                  ,
        QB(0)            => ex5_nrm_sticky_sp     ,
        QB(1)            => ex5_nrm_sticky_dp     ,
        QB(2)            => ex5_exact_zero       );

    ex5_nrm_pass_lat:  tri_rlmreg_p generic map (width=> 13, expand_type => expand_type,  ibuf => true, needs_sreset => 0) port map ( 
        forcee => forcee,
        delay_lclkr      => delay_lclkr(5)  ,
        mpw1_b           => mpw1_b(5)       ,
        mpw2_b           => mpw2_b(1)       ,
        vd               => vdd,
        gd               => gnd,
        nclk             => nclk, 
        thold_b          => thold_0_b,
        sg               => sg_0, 
        act              => ex4_act, 
        scout            => ex5_nrm_pass_so,
        scin             => ex5_nrm_pass_si,
         din(0)             => f_add_ex4_res(99)               ,
         din(1 to 12)       => f_add_ex4_res(151 to 162)       , 
        dout(0)             => ex5_int_sign               ,
        dout(1 to 12)       => ex5_int_lsbs  (1 to 12)   );

    ex5_fmv_lat:  tri_rlmreg_p generic map (width=> 36, expand_type => expand_type,  ibuf => true, needs_sreset => 1) port map ( 
        forcee => forcee,
        delay_lclkr      => delay_lclkr(5)  ,
        mpw1_b           => mpw1_b(5)       ,
        mpw2_b           => mpw2_b(1)       ,
        vd               => vdd,
        gd               => gnd,
        nclk             => nclk, 
        thold_b          => thold_0_b,
        sg               => sg_0, 
        act              => ex4_act, 
        scout            => ex5_fmv_so  ,                      
        scin             => ex5_fmv_si  ,                    
        din              => f_add_ex4_res(17 to 52)       ,
        dout(0 to 3)     => ex5_fpscr_wr_dat_dfp(0 to 3) ,
        dout(4 to 35)    => ex5_fpscr_wr_dat(0 to 31) );



       f_nrm_ex5_res              <=     ex5_res(0 to 52)             ;
       f_nrm_ex5_nrm_lsb_sp       <=     ex5_nrm_lsb_sp               ;
       f_nrm_ex5_nrm_guard_sp     <=     ex5_nrm_guard_sp             ;
       f_nrm_ex5_nrm_sticky_sp    <=     ex5_nrm_sticky_sp            ;
       f_nrm_ex5_nrm_lsb_dp       <=     ex5_nrm_lsb_dp               ;
       f_nrm_ex5_nrm_guard_dp     <=     ex5_nrm_guard_dp             ;
       f_nrm_ex5_nrm_sticky_dp    <=     ex5_nrm_sticky_dp            ;
       f_nrm_ex5_exact_zero       <=     ex5_exact_zero               ;
       f_nrm_ex5_int_lsbs         <=     ex5_int_lsbs  (1 to 12)      ;
       f_nrm_ex5_fpscr_wr_dat     <=     ex5_fpscr_wr_dat(0 to 31)    ;
       f_nrm_ex5_fpscr_wr_dat_dfp <=     ex5_fpscr_wr_dat_dfp(0 to 3) ;
       f_nrm_ex5_int_sign         <=     ex5_int_sign                 ;
   


    act_si  (0 to 3)         <= act_so  (1 to 3)          & f_nrm_si;
    ex5_res_si  (0 to 52)    <= ex5_res_so  (1 to 52)     & act_so(0) ;
    ex5_nrm_lg_si(0 to 3)    <= ex5_nrm_lg_so(1 to 3)     & ex5_res_so(0);
    ex5_nrm_x_si(0 to 2)     <= ex5_nrm_x_so(1 to 2)      & ex5_nrm_lg_so(0);
    ex5_nrm_pass_si(0 to 12) <= ex5_nrm_pass_so(1 to 12)  & ex5_nrm_x_so(0);
    ex5_fmv_si  (0 to 35)    <= ex5_fmv_so  (1 to 35)     & ex5_nrm_pass_so(0);
    f_nrm_so                 <= ex5_fmv_so  (0)  ;
 


end; 
 



