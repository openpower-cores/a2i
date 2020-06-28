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


 
entity fuq_alg_sh4 is
generic(       expand_type               : integer := 2  ); 
port(
      ex1_lvl1_shdcd000_b      :in   std_ulogic;
      ex1_lvl1_shdcd001_b      :in   std_ulogic;
      ex1_lvl1_shdcd002_b      :in   std_ulogic;
      ex1_lvl1_shdcd003_b      :in   std_ulogic;
      ex1_lvl2_shdcd000        :in   std_ulogic;
      ex1_lvl2_shdcd004        :in   std_ulogic;
      ex1_lvl2_shdcd008        :in   std_ulogic;
      ex1_lvl2_shdcd012        :in   std_ulogic;
      ex1_sel_special          :in   std_ulogic;

      ex1_b_sign               :in   std_ulogic;
      ex1_b_expo               :in   std_ulogic_vector(3 to 13) ;
      ex1_b_frac               :in   std_ulogic_vector(0 to 52) ;

      ex1_sh_lvl2              :out std_ulogic_vector(0 to 67)  
);



end fuq_alg_sh4; 

architecture fuq_alg_sh4 of fuq_alg_sh4 is

    constant tiup : std_ulogic := '1';
    constant tidn : std_ulogic := '0';

    signal ex1_special_fcfid :std_ulogic_vector(0 to 63);
    signal ex1_sh_lv1       :std_ulogic_vector(0 to 55);
    signal ex1_sh_lv1x_b     :std_ulogic_vector(0 to 53);
    signal ex1_sh_lv1y_b     :std_ulogic_vector(2 to 55);
    signal ex1_sh_lv2x_b :std_ulogic_vector(0 to 59);
    signal ex1_sh_lv2y_b :std_ulogic_vector(8 to 67);
    signal ex1_sh_lv2z_b :std_ulogic_vector(0 to 63);

 signal sh1v2dcd0_cp1    :std_ulogic;
 signal sh1v3dcd0_cp1_b  :std_ulogic;
 signal sh1v3dcd0_cp2_b  :std_ulogic;
 signal sh1v4dcd0_cp1    :std_ulogic;
 signal sh1v4dcd0_cp2    :std_ulogic;
 signal sh1v4dcd0_cp3    :std_ulogic;
 signal sh1v4dcd0_cp4    :std_ulogic;
 signal sh1v2dcd1_cp1    :std_ulogic;
 signal sh1v3dcd1_cp1_b  :std_ulogic;
 signal sh1v3dcd1_cp2_b  :std_ulogic;
 signal sh1v4dcd1_cp1    :std_ulogic;
 signal sh1v4dcd1_cp2    :std_ulogic;
 signal sh1v4dcd1_cp3    :std_ulogic;
 signal sh1v4dcd1_cp4    :std_ulogic;
 signal sh1v2dcd2_cp1    :std_ulogic;
 signal sh1v3dcd2_cp1_b  :std_ulogic;
 signal sh1v3dcd2_cp2_b  :std_ulogic;
 signal sh1v4dcd2_cp1    :std_ulogic;
 signal sh1v4dcd2_cp2    :std_ulogic;
 signal sh1v4dcd2_cp3    :std_ulogic;
 signal sh1v4dcd2_cp4    :std_ulogic;
 signal sh1v2dcd3_cp1    :std_ulogic;
 signal sh1v3dcd3_cp1_b  :std_ulogic;
 signal sh1v3dcd3_cp2_b  :std_ulogic;
 signal sh1v4dcd3_cp1    :std_ulogic;
 signal sh1v4dcd3_cp2    :std_ulogic;
 signal sh1v4dcd3_cp3    :std_ulogic;
 signal sh1v4dcd3_cp4    :std_ulogic;
 signal sh2v1dcd00_cp1_b :std_ulogic;
 signal sh2v2dcd00_cp1   :std_ulogic;
 signal sh2v3dcd00_cp1_b :std_ulogic;
 signal sh2v3dcd00_cp2_b :std_ulogic;
 signal sh2v4dcd00_cp1   :std_ulogic;
 signal sh2v4dcd00_cp2   :std_ulogic;
 signal sh2v4dcd00_cp3   :std_ulogic;
 signal sh2v4dcd00_cp4   :std_ulogic;
 signal sh2v1dcd04_cp1_b :std_ulogic;
 signal sh2v2dcd04_cp1   :std_ulogic;
 signal sh2v3dcd04_cp1_b :std_ulogic;
 signal sh2v3dcd04_cp2_b :std_ulogic;
 signal sh2v4dcd04_cp1   :std_ulogic;
 signal sh2v4dcd04_cp2   :std_ulogic;
 signal sh2v4dcd04_cp3   :std_ulogic;
 signal sh2v4dcd04_cp4   :std_ulogic;
 signal sh2v1dcd08_cp1_b :std_ulogic;
 signal sh2v2dcd08_cp1   :std_ulogic;
 signal sh2v3dcd08_cp1_b :std_ulogic;
 signal sh2v3dcd08_cp2_b :std_ulogic;
 signal sh2v4dcd08_cp1   :std_ulogic;
 signal sh2v4dcd08_cp2   :std_ulogic;
 signal sh2v4dcd08_cp3   :std_ulogic;
 signal sh2v4dcd08_cp4   :std_ulogic;
 signal sh2v1dcd12_cp1_b :std_ulogic;
 signal sh2v2dcd12_cp1   :std_ulogic;
 signal sh2v3dcd12_cp1_b :std_ulogic;
 signal sh2v3dcd12_cp2_b :std_ulogic;
 signal sh2v4dcd12_cp1   :std_ulogic;
 signal sh2v4dcd12_cp2   :std_ulogic;
 signal sh2v4dcd12_cp3   :std_ulogic;
 signal sh2v4dcd12_cp4   :std_ulogic;
 signal sh2v1dcdpp_cp1_b :std_ulogic;
 signal sh2v2dcdpp_cp1   :std_ulogic;
 signal sh2v3dcdpp_cp1_b :std_ulogic;
 signal sh2v3dcdpp_cp2_b :std_ulogic;
 signal sh2v4dcdpp_cp1   :std_ulogic;
 signal sh2v4dcdpp_cp2   :std_ulogic;
 signal sh2v4dcdpp_cp3   :std_ulogic;
 signal sh2v4dcdpp_cp4   :std_ulogic;
 









 











begin


    ex1_special_fcfid(0)        <= ex1_b_sign     ;  
    ex1_special_fcfid(1)        <= ex1_b_expo( 3) ;
    ex1_special_fcfid(2)        <= ex1_b_expo( 4) and ex1_b_frac(0) ;
    ex1_special_fcfid(3)        <= ex1_b_expo( 5) and ex1_b_frac(0) ;
    ex1_special_fcfid(4)        <= ex1_b_expo( 6) and ex1_b_frac(0) ;
    ex1_special_fcfid(5)        <= ex1_b_expo( 7) ;
    ex1_special_fcfid(6)        <= ex1_b_expo( 8) ;
    ex1_special_fcfid(7)        <= ex1_b_expo( 9) ;
    ex1_special_fcfid(8)        <= ex1_b_expo(10) ;
    ex1_special_fcfid(9)        <= ex1_b_expo(11) ;
    ex1_special_fcfid(10)       <= ex1_b_expo(12) ;
    ex1_special_fcfid(11)       <= ex1_b_expo(13) and ex1_b_frac(0) ;
    ex1_special_fcfid(12 to 63) <= ex1_b_frac(1 to 52); 




 s1v2d0c1:  sh1v2dcd0_cp1   <= not ex1_lvl1_shdcd000_b;
 s1v3d0c1:  sh1v3dcd0_cp1_b <= not sh1v2dcd0_cp1 ;
 s1v3d0c2:  sh1v3dcd0_cp2_b <= not sh1v2dcd0_cp1 ;
 s1v4d0c1:  sh1v4dcd0_cp1   <= not sh1v3dcd0_cp1_b; 
 s1v4d0c2:  sh1v4dcd0_cp2   <= not sh1v3dcd0_cp1_b; 
 s1v4d0c3:  sh1v4dcd0_cp3   <= not sh1v3dcd0_cp2_b; 
 s1v4d0c4:  sh1v4dcd0_cp4   <= not sh1v3dcd0_cp2_b; 

 s1v2d1c1:  sh1v2dcd1_cp1   <= not ex1_lvl1_shdcd001_b;
 s1v3d1c1:  sh1v3dcd1_cp1_b <= not sh1v2dcd1_cp1 ;
 s1v3d1c2:  sh1v3dcd1_cp2_b <= not sh1v2dcd1_cp1 ;
 s1v4d1c1:  sh1v4dcd1_cp1   <= not sh1v3dcd1_cp1_b; 
 s1v4d1c2:  sh1v4dcd1_cp2   <= not sh1v3dcd1_cp1_b; 
 s1v4d1c3:  sh1v4dcd1_cp3   <= not sh1v3dcd1_cp2_b; 
 s1v4d1c4:  sh1v4dcd1_cp4   <= not sh1v3dcd1_cp2_b; 

 s1v2d2c1:  sh1v2dcd2_cp1   <= not ex1_lvl1_shdcd002_b;
 s1v3d2c1:  sh1v3dcd2_cp1_b <= not sh1v2dcd2_cp1 ;
 s1v3d2c2:  sh1v3dcd2_cp2_b <= not sh1v2dcd2_cp1 ;
 s1v4d2c1:  sh1v4dcd2_cp1   <= not sh1v3dcd2_cp1_b; 
 s1v4d2c2:  sh1v4dcd2_cp2   <= not sh1v3dcd2_cp1_b; 
 s1v4d2c3:  sh1v4dcd2_cp3   <= not sh1v3dcd2_cp2_b; 
 s1v4d2c4:  sh1v4dcd2_cp4   <= not sh1v3dcd2_cp2_b; 

 s1v2d3c1:  sh1v2dcd3_cp1   <= not ex1_lvl1_shdcd003_b;
 s1v3d3c1:  sh1v3dcd3_cp1_b <= not sh1v2dcd3_cp1 ;
 s1v3d3c2:  sh1v3dcd3_cp2_b <= not sh1v2dcd3_cp1 ;
 s1v4d3c1:  sh1v4dcd3_cp1   <= not sh1v3dcd3_cp1_b; 
 s1v4d3c2:  sh1v4dcd3_cp2   <= not sh1v3dcd3_cp1_b; 
 s1v4d3c3:  sh1v4dcd3_cp3   <= not sh1v3dcd3_cp2_b; 
 s1v4d3c4:  sh1v4dcd3_cp4   <= not sh1v3dcd3_cp2_b; 


 s2v1d00c1:  sh2v1dcd00_cp1_b <= not ex1_lvl2_shdcd000;
 s2v2d00c1:  sh2v2dcd00_cp1   <= not sh2v1dcd00_cp1_b ;
 s2v3d00c1:  sh2v3dcd00_cp1_b <= not sh2v2dcd00_cp1 ;
 s2v3d00c2:  sh2v3dcd00_cp2_b <= not sh2v2dcd00_cp1 ;
 s2v4d00c1:  sh2v4dcd00_cp1   <= not sh2v3dcd00_cp1_b; 
 s2v4d00c2:  sh2v4dcd00_cp2   <= not sh2v3dcd00_cp1_b; 
 s2v4d00c3:  sh2v4dcd00_cp3   <= not sh2v3dcd00_cp2_b; 
 s2v4d00c4:  sh2v4dcd00_cp4   <= not sh2v3dcd00_cp2_b; 

 s2v1d04c1:  sh2v1dcd04_cp1_b <= not ex1_lvl2_shdcd004;
 s2v2d04c1:  sh2v2dcd04_cp1   <= not sh2v1dcd04_cp1_b ;
 s2v3d04c1:  sh2v3dcd04_cp1_b <= not sh2v2dcd04_cp1 ;
 s2v3d04c2:  sh2v3dcd04_cp2_b <= not sh2v2dcd04_cp1 ;
 s2v4d04c1:  sh2v4dcd04_cp1   <= not sh2v3dcd04_cp1_b; 
 s2v4d04c2:  sh2v4dcd04_cp2   <= not sh2v3dcd04_cp1_b; 
 s2v4d04c3:  sh2v4dcd04_cp3   <= not sh2v3dcd04_cp2_b; 
 s2v4d04c4:  sh2v4dcd04_cp4   <= not sh2v3dcd04_cp2_b; 

 s2v1d08c1:  sh2v1dcd08_cp1_b <= not ex1_lvl2_shdcd008;
 s2v2d08c1:  sh2v2dcd08_cp1   <= not sh2v1dcd08_cp1_b ;
 s2v3d08c1:  sh2v3dcd08_cp1_b <= not sh2v2dcd08_cp1 ;
 s2v3d08c2:  sh2v3dcd08_cp2_b <= not sh2v2dcd08_cp1 ;
 s2v4d08c1:  sh2v4dcd08_cp1   <= not sh2v3dcd08_cp1_b; 
 s2v4d08c2:  sh2v4dcd08_cp2   <= not sh2v3dcd08_cp1_b; 
 s2v4d08c3:  sh2v4dcd08_cp3   <= not sh2v3dcd08_cp2_b; 
 s2v4d08c4:  sh2v4dcd08_cp4   <= not sh2v3dcd08_cp2_b; 

 s2v1d12c1:  sh2v1dcd12_cp1_b <= not ex1_lvl2_shdcd012;
 s2v2d12c1:  sh2v2dcd12_cp1   <= not sh2v1dcd12_cp1_b ;
 s2v3d12c1:  sh2v3dcd12_cp1_b <= not sh2v2dcd12_cp1 ;
 s2v3d12c2:  sh2v3dcd12_cp2_b <= not sh2v2dcd12_cp1 ;
 s2v4d12c1:  sh2v4dcd12_cp1   <= not sh2v3dcd12_cp1_b; 
 s2v4d12c2:  sh2v4dcd12_cp2   <= not sh2v3dcd12_cp1_b; 
 s2v4d12c3:  sh2v4dcd12_cp3   <= not sh2v3dcd12_cp2_b; 
 s2v4d12c4:  sh2v4dcd12_cp4   <= not sh2v3dcd12_cp2_b; 

 s2v1dppc1:  sh2v1dcdpp_cp1_b <= not ex1_sel_special ;
 s2v2dppc1:  sh2v2dcdpp_cp1   <= not sh2v1dcdpp_cp1_b ;
 s2v3dppc1:  sh2v3dcdpp_cp1_b <= not sh2v2dcdpp_cp1 ;
 s2v3dppc2:  sh2v3dcdpp_cp2_b <= not sh2v2dcdpp_cp1 ;
 s2v4dppc1:  sh2v4dcdpp_cp1   <= not sh2v3dcdpp_cp1_b; 
 s2v4dppc2:  sh2v4dcdpp_cp2   <= not sh2v3dcdpp_cp1_b; 
 s2v4dppc3:  sh2v4dcdpp_cp3   <= not sh2v3dcdpp_cp2_b; 
 s2v4dppc4:  sh2v4dcdpp_cp4   <= not sh2v3dcdpp_cp2_b; 



  lv1x_00: ex1_sh_lv1x_b(0)  <= not(  sh1v4dcd0_cp1 and ex1_b_frac(0)  ) ;
  lv1x_01: ex1_sh_lv1x_b(1)  <= not( (sh1v4dcd0_cp1 and ex1_b_frac(1)  ) or (sh1v4dcd1_cp1 and ex1_b_frac(0)  ) );
  lv1x_02: ex1_sh_lv1x_b(2)  <= not( (sh1v4dcd0_cp1 and ex1_b_frac(2)  ) or (sh1v4dcd1_cp1 and ex1_b_frac(1)  ) );
  lv1x_03: ex1_sh_lv1x_b(3)  <= not( (sh1v4dcd0_cp1 and ex1_b_frac(3)  ) or (sh1v4dcd1_cp1 and ex1_b_frac(2)  ) );
  lv1x_04: ex1_sh_lv1x_b(4)  <= not( (sh1v4dcd0_cp1 and ex1_b_frac(4)  ) or (sh1v4dcd1_cp1 and ex1_b_frac(3)  ) );
  lv1x_05: ex1_sh_lv1x_b(5)  <= not( (sh1v4dcd0_cp1 and ex1_b_frac(5)  ) or (sh1v4dcd1_cp1 and ex1_b_frac(4)  ) );
  lv1x_06: ex1_sh_lv1x_b(6)  <= not( (sh1v4dcd0_cp1 and ex1_b_frac(6)  ) or (sh1v4dcd1_cp1 and ex1_b_frac(5)  ) );
  lv1x_07: ex1_sh_lv1x_b(7)  <= not( (sh1v4dcd0_cp1 and ex1_b_frac(7)  ) or (sh1v4dcd1_cp1 and ex1_b_frac(6)  ) );
  lv1x_08: ex1_sh_lv1x_b(8)  <= not( (sh1v4dcd0_cp1 and ex1_b_frac(8)  ) or (sh1v4dcd1_cp1 and ex1_b_frac(7)  ) );
  lv1x_09: ex1_sh_lv1x_b(9)  <= not( (sh1v4dcd0_cp1 and ex1_b_frac(9)  ) or (sh1v4dcd1_cp1 and ex1_b_frac(8)  ) );
  lv1x_10: ex1_sh_lv1x_b(10) <= not( (sh1v4dcd0_cp1 and ex1_b_frac(10) ) or (sh1v4dcd1_cp1 and ex1_b_frac(9)  ) );
  lv1x_11: ex1_sh_lv1x_b(11) <= not( (sh1v4dcd0_cp1 and ex1_b_frac(11) ) or (sh1v4dcd1_cp1 and ex1_b_frac(10) ) );
  lv1x_12: ex1_sh_lv1x_b(12) <= not( (sh1v4dcd0_cp1 and ex1_b_frac(12) ) or (sh1v4dcd1_cp1 and ex1_b_frac(11) ) );
  lv1x_13: ex1_sh_lv1x_b(13) <= not( (sh1v4dcd0_cp1 and ex1_b_frac(13) ) or (sh1v4dcd1_cp1 and ex1_b_frac(12) ) );
  lv1x_14: ex1_sh_lv1x_b(14) <= not( (sh1v4dcd0_cp2 and ex1_b_frac(14) ) or (sh1v4dcd1_cp2 and ex1_b_frac(13) ) );
  lv1x_15: ex1_sh_lv1x_b(15) <= not( (sh1v4dcd0_cp2 and ex1_b_frac(15) ) or (sh1v4dcd1_cp2 and ex1_b_frac(14) ) );
  lv1x_16: ex1_sh_lv1x_b(16) <= not( (sh1v4dcd0_cp2 and ex1_b_frac(16) ) or (sh1v4dcd1_cp2 and ex1_b_frac(15) ) );
  lv1x_17: ex1_sh_lv1x_b(17) <= not( (sh1v4dcd0_cp2 and ex1_b_frac(17) ) or (sh1v4dcd1_cp2 and ex1_b_frac(16) ) );
  lv1x_18: ex1_sh_lv1x_b(18) <= not( (sh1v4dcd0_cp2 and ex1_b_frac(18) ) or (sh1v4dcd1_cp2 and ex1_b_frac(17) ) );
  lv1x_19: ex1_sh_lv1x_b(19) <= not( (sh1v4dcd0_cp2 and ex1_b_frac(19) ) or (sh1v4dcd1_cp2 and ex1_b_frac(18) ) );
  lv1x_20: ex1_sh_lv1x_b(20) <= not( (sh1v4dcd0_cp2 and ex1_b_frac(20) ) or (sh1v4dcd1_cp2 and ex1_b_frac(19) ) );
  lv1x_21: ex1_sh_lv1x_b(21) <= not( (sh1v4dcd0_cp2 and ex1_b_frac(21) ) or (sh1v4dcd1_cp2 and ex1_b_frac(20) ) );
  lv1x_22: ex1_sh_lv1x_b(22) <= not( (sh1v4dcd0_cp2 and ex1_b_frac(22) ) or (sh1v4dcd1_cp2 and ex1_b_frac(21) ) );
  lv1x_23: ex1_sh_lv1x_b(23) <= not( (sh1v4dcd0_cp2 and ex1_b_frac(23) ) or (sh1v4dcd1_cp2 and ex1_b_frac(22) ) );
  lv1x_24: ex1_sh_lv1x_b(24) <= not( (sh1v4dcd0_cp2 and ex1_b_frac(24) ) or (sh1v4dcd1_cp2 and ex1_b_frac(23) ) );
  lv1x_25: ex1_sh_lv1x_b(25) <= not( (sh1v4dcd0_cp2 and ex1_b_frac(25) ) or (sh1v4dcd1_cp2 and ex1_b_frac(24) ) );
  lv1x_26: ex1_sh_lv1x_b(26) <= not( (sh1v4dcd0_cp2 and ex1_b_frac(26) ) or (sh1v4dcd1_cp2 and ex1_b_frac(25) ) );
  lv1x_27: ex1_sh_lv1x_b(27) <= not( (sh1v4dcd0_cp2 and ex1_b_frac(27) ) or (sh1v4dcd1_cp2 and ex1_b_frac(26) ) );
  lv1x_28: ex1_sh_lv1x_b(28) <= not( (sh1v4dcd0_cp3 and ex1_b_frac(28) ) or (sh1v4dcd1_cp3 and ex1_b_frac(27) ) );
  lv1x_29: ex1_sh_lv1x_b(29) <= not( (sh1v4dcd0_cp3 and ex1_b_frac(29) ) or (sh1v4dcd1_cp3 and ex1_b_frac(28) ) );
  lv1x_30: ex1_sh_lv1x_b(30) <= not( (sh1v4dcd0_cp3 and ex1_b_frac(30) ) or (sh1v4dcd1_cp3 and ex1_b_frac(29) ) );
  lv1x_31: ex1_sh_lv1x_b(31) <= not( (sh1v4dcd0_cp3 and ex1_b_frac(31) ) or (sh1v4dcd1_cp3 and ex1_b_frac(30) ) );
  lv1x_32: ex1_sh_lv1x_b(32) <= not( (sh1v4dcd0_cp3 and ex1_b_frac(32) ) or (sh1v4dcd1_cp3 and ex1_b_frac(31) ) );
  lv1x_33: ex1_sh_lv1x_b(33) <= not( (sh1v4dcd0_cp3 and ex1_b_frac(33) ) or (sh1v4dcd1_cp3 and ex1_b_frac(32) ) );
  lv1x_34: ex1_sh_lv1x_b(34) <= not( (sh1v4dcd0_cp3 and ex1_b_frac(34) ) or (sh1v4dcd1_cp3 and ex1_b_frac(33) ) );
  lv1x_35: ex1_sh_lv1x_b(35) <= not( (sh1v4dcd0_cp3 and ex1_b_frac(35) ) or (sh1v4dcd1_cp3 and ex1_b_frac(34) ) );
  lv1x_36: ex1_sh_lv1x_b(36) <= not( (sh1v4dcd0_cp3 and ex1_b_frac(36) ) or (sh1v4dcd1_cp3 and ex1_b_frac(35) ) );
  lv1x_37: ex1_sh_lv1x_b(37) <= not( (sh1v4dcd0_cp3 and ex1_b_frac(37) ) or (sh1v4dcd1_cp3 and ex1_b_frac(36) ) );
  lv1x_38: ex1_sh_lv1x_b(38) <= not( (sh1v4dcd0_cp3 and ex1_b_frac(38) ) or (sh1v4dcd1_cp3 and ex1_b_frac(37) ) );
  lv1x_39: ex1_sh_lv1x_b(39) <= not( (sh1v4dcd0_cp3 and ex1_b_frac(39) ) or (sh1v4dcd1_cp3 and ex1_b_frac(38) ) );
  lv1x_40: ex1_sh_lv1x_b(40) <= not( (sh1v4dcd0_cp3 and ex1_b_frac(40) ) or (sh1v4dcd1_cp3 and ex1_b_frac(39) ) );
  lv1x_41: ex1_sh_lv1x_b(41) <= not( (sh1v4dcd0_cp3 and ex1_b_frac(41) ) or (sh1v4dcd1_cp3 and ex1_b_frac(40) ) );
  lv1x_42: ex1_sh_lv1x_b(42) <= not( (sh1v4dcd0_cp4 and ex1_b_frac(42) ) or (sh1v4dcd1_cp4 and ex1_b_frac(41) ) );
  lv1x_43: ex1_sh_lv1x_b(43) <= not( (sh1v4dcd0_cp4 and ex1_b_frac(43) ) or (sh1v4dcd1_cp4 and ex1_b_frac(42) ) );
  lv1x_44: ex1_sh_lv1x_b(44) <= not( (sh1v4dcd0_cp4 and ex1_b_frac(44) ) or (sh1v4dcd1_cp4 and ex1_b_frac(43) ) );
  lv1x_45: ex1_sh_lv1x_b(45) <= not( (sh1v4dcd0_cp4 and ex1_b_frac(45) ) or (sh1v4dcd1_cp4 and ex1_b_frac(44) ) );
  lv1x_46: ex1_sh_lv1x_b(46) <= not( (sh1v4dcd0_cp4 and ex1_b_frac(46) ) or (sh1v4dcd1_cp4 and ex1_b_frac(45) ) );
  lv1x_47: ex1_sh_lv1x_b(47) <= not( (sh1v4dcd0_cp4 and ex1_b_frac(47) ) or (sh1v4dcd1_cp4 and ex1_b_frac(46) ) );
  lv1x_48: ex1_sh_lv1x_b(48) <= not( (sh1v4dcd0_cp4 and ex1_b_frac(48) ) or (sh1v4dcd1_cp4 and ex1_b_frac(47) ) );
  lv1x_49: ex1_sh_lv1x_b(49) <= not( (sh1v4dcd0_cp4 and ex1_b_frac(49) ) or (sh1v4dcd1_cp4 and ex1_b_frac(48) ) );
  lv1x_50: ex1_sh_lv1x_b(50) <= not( (sh1v4dcd0_cp4 and ex1_b_frac(50) ) or (sh1v4dcd1_cp4 and ex1_b_frac(49) ) );
  lv1x_51: ex1_sh_lv1x_b(51) <= not( (sh1v4dcd0_cp4 and ex1_b_frac(51) ) or (sh1v4dcd1_cp4 and ex1_b_frac(50) ) );
  lv1x_52: ex1_sh_lv1x_b(52) <= not( (sh1v4dcd0_cp4 and ex1_b_frac(52) ) or (sh1v4dcd1_cp4 and ex1_b_frac(51) ) );
  lv1x_53: ex1_sh_lv1x_b(53) <= not(                                         sh1v4dcd1_cp4 and ex1_b_frac(52)   );



  lv1y_02: ex1_sh_lv1y_b(2)  <= not(  sh1v4dcd2_cp1 and ex1_b_frac(0)  ) ;
  lv1y_03: ex1_sh_lv1y_b(3)  <= not( (sh1v4dcd2_cp1 and ex1_b_frac(1)  ) or (sh1v4dcd3_cp1 and ex1_b_frac(0)  ) );
  lv1y_04: ex1_sh_lv1y_b(4)  <= not( (sh1v4dcd2_cp1 and ex1_b_frac(2)  ) or (sh1v4dcd3_cp1 and ex1_b_frac(1)  ) );
  lv1y_05: ex1_sh_lv1y_b(5)  <= not( (sh1v4dcd2_cp1 and ex1_b_frac(3)  ) or (sh1v4dcd3_cp1 and ex1_b_frac(2)  ) );
  lv1y_06: ex1_sh_lv1y_b(6)  <= not( (sh1v4dcd2_cp1 and ex1_b_frac(4)  ) or (sh1v4dcd3_cp1 and ex1_b_frac(3)  ) );
  lv1y_07: ex1_sh_lv1y_b(7)  <= not( (sh1v4dcd2_cp1 and ex1_b_frac(5)  ) or (sh1v4dcd3_cp1 and ex1_b_frac(4)  ) );
  lv1y_08: ex1_sh_lv1y_b(8)  <= not( (sh1v4dcd2_cp1 and ex1_b_frac(6)  ) or (sh1v4dcd3_cp1 and ex1_b_frac(5)  ) );
  lv1y_09: ex1_sh_lv1y_b(9)  <= not( (sh1v4dcd2_cp1 and ex1_b_frac(7)  ) or (sh1v4dcd3_cp1 and ex1_b_frac(6)  ) );
  lv1y_10: ex1_sh_lv1y_b(10) <= not( (sh1v4dcd2_cp1 and ex1_b_frac(8)  ) or (sh1v4dcd3_cp1 and ex1_b_frac(7)  ) );
  lv1y_11: ex1_sh_lv1y_b(11) <= not( (sh1v4dcd2_cp1 and ex1_b_frac(9)  ) or (sh1v4dcd3_cp1 and ex1_b_frac(8)  ) );
  lv1y_12: ex1_sh_lv1y_b(12) <= not( (sh1v4dcd2_cp1 and ex1_b_frac(10) ) or (sh1v4dcd3_cp1 and ex1_b_frac(9)  ) );
  lv1y_13: ex1_sh_lv1y_b(13) <= not( (sh1v4dcd2_cp1 and ex1_b_frac(11) ) or (sh1v4dcd3_cp1 and ex1_b_frac(10) ) );
  lv1y_14: ex1_sh_lv1y_b(14) <= not( (sh1v4dcd2_cp2 and ex1_b_frac(12) ) or (sh1v4dcd3_cp2 and ex1_b_frac(11) ) );
  lv1y_15: ex1_sh_lv1y_b(15) <= not( (sh1v4dcd2_cp2 and ex1_b_frac(13) ) or (sh1v4dcd3_cp2 and ex1_b_frac(12) ) );
  lv1y_16: ex1_sh_lv1y_b(16) <= not( (sh1v4dcd2_cp2 and ex1_b_frac(14) ) or (sh1v4dcd3_cp2 and ex1_b_frac(13) ) );
  lv1y_17: ex1_sh_lv1y_b(17) <= not( (sh1v4dcd2_cp2 and ex1_b_frac(15) ) or (sh1v4dcd3_cp2 and ex1_b_frac(14) ) );
  lv1y_18: ex1_sh_lv1y_b(18) <= not( (sh1v4dcd2_cp2 and ex1_b_frac(16) ) or (sh1v4dcd3_cp2 and ex1_b_frac(15) ) );
  lv1y_19: ex1_sh_lv1y_b(19) <= not( (sh1v4dcd2_cp2 and ex1_b_frac(17) ) or (sh1v4dcd3_cp2 and ex1_b_frac(16) ) );
  lv1y_20: ex1_sh_lv1y_b(20) <= not( (sh1v4dcd2_cp2 and ex1_b_frac(18) ) or (sh1v4dcd3_cp2 and ex1_b_frac(17) ) );
  lv1y_21: ex1_sh_lv1y_b(21) <= not( (sh1v4dcd2_cp2 and ex1_b_frac(19) ) or (sh1v4dcd3_cp2 and ex1_b_frac(18) ) );
  lv1y_22: ex1_sh_lv1y_b(22) <= not( (sh1v4dcd2_cp2 and ex1_b_frac(20) ) or (sh1v4dcd3_cp2 and ex1_b_frac(19) ) );
  lv1y_23: ex1_sh_lv1y_b(23) <= not( (sh1v4dcd2_cp2 and ex1_b_frac(21) ) or (sh1v4dcd3_cp2 and ex1_b_frac(20) ) );
  lv1y_24: ex1_sh_lv1y_b(24) <= not( (sh1v4dcd2_cp2 and ex1_b_frac(22) ) or (sh1v4dcd3_cp2 and ex1_b_frac(21) ) );
  lv1y_25: ex1_sh_lv1y_b(25) <= not( (sh1v4dcd2_cp2 and ex1_b_frac(23) ) or (sh1v4dcd3_cp2 and ex1_b_frac(22) ) );
  lv1y_26: ex1_sh_lv1y_b(26) <= not( (sh1v4dcd2_cp2 and ex1_b_frac(24) ) or (sh1v4dcd3_cp2 and ex1_b_frac(23) ) );
  lv1y_27: ex1_sh_lv1y_b(27) <= not( (sh1v4dcd2_cp2 and ex1_b_frac(25) ) or (sh1v4dcd3_cp2 and ex1_b_frac(24) ) );
  lv1y_28: ex1_sh_lv1y_b(28) <= not( (sh1v4dcd2_cp3 and ex1_b_frac(26) ) or (sh1v4dcd3_cp3 and ex1_b_frac(25) ) );
  lv1y_29: ex1_sh_lv1y_b(29) <= not( (sh1v4dcd2_cp3 and ex1_b_frac(27) ) or (sh1v4dcd3_cp3 and ex1_b_frac(26) ) );
  lv1y_30: ex1_sh_lv1y_b(30) <= not( (sh1v4dcd2_cp3 and ex1_b_frac(28) ) or (sh1v4dcd3_cp3 and ex1_b_frac(27) ) );
  lv1y_31: ex1_sh_lv1y_b(31) <= not( (sh1v4dcd2_cp3 and ex1_b_frac(29) ) or (sh1v4dcd3_cp3 and ex1_b_frac(28) ) );
  lv1y_32: ex1_sh_lv1y_b(32) <= not( (sh1v4dcd2_cp3 and ex1_b_frac(30) ) or (sh1v4dcd3_cp3 and ex1_b_frac(29) ) );
  lv1y_33: ex1_sh_lv1y_b(33) <= not( (sh1v4dcd2_cp3 and ex1_b_frac(31) ) or (sh1v4dcd3_cp3 and ex1_b_frac(30) ) );
  lv1y_34: ex1_sh_lv1y_b(34) <= not( (sh1v4dcd2_cp3 and ex1_b_frac(32) ) or (sh1v4dcd3_cp3 and ex1_b_frac(31) ) );
  lv1y_35: ex1_sh_lv1y_b(35) <= not( (sh1v4dcd2_cp3 and ex1_b_frac(33) ) or (sh1v4dcd3_cp3 and ex1_b_frac(32) ) );
  lv1y_36: ex1_sh_lv1y_b(36) <= not( (sh1v4dcd2_cp3 and ex1_b_frac(34) ) or (sh1v4dcd3_cp3 and ex1_b_frac(33) ) );
  lv1y_37: ex1_sh_lv1y_b(37) <= not( (sh1v4dcd2_cp3 and ex1_b_frac(35) ) or (sh1v4dcd3_cp3 and ex1_b_frac(34) ) );
  lv1y_38: ex1_sh_lv1y_b(38) <= not( (sh1v4dcd2_cp3 and ex1_b_frac(36) ) or (sh1v4dcd3_cp3 and ex1_b_frac(35) ) );
  lv1y_39: ex1_sh_lv1y_b(39) <= not( (sh1v4dcd2_cp3 and ex1_b_frac(37) ) or (sh1v4dcd3_cp3 and ex1_b_frac(36) ) );
  lv1y_40: ex1_sh_lv1y_b(40) <= not( (sh1v4dcd2_cp3 and ex1_b_frac(38) ) or (sh1v4dcd3_cp3 and ex1_b_frac(37) ) );
  lv1y_41: ex1_sh_lv1y_b(41) <= not( (sh1v4dcd2_cp4 and ex1_b_frac(39) ) or (sh1v4dcd3_cp4 and ex1_b_frac(38) ) );
  lv1y_42: ex1_sh_lv1y_b(42) <= not( (sh1v4dcd2_cp4 and ex1_b_frac(40) ) or (sh1v4dcd3_cp4 and ex1_b_frac(39) ) );
  lv1y_43: ex1_sh_lv1y_b(43) <= not( (sh1v4dcd2_cp4 and ex1_b_frac(41) ) or (sh1v4dcd3_cp4 and ex1_b_frac(40) ) );
  lv1y_44: ex1_sh_lv1y_b(44) <= not( (sh1v4dcd2_cp4 and ex1_b_frac(42) ) or (sh1v4dcd3_cp4 and ex1_b_frac(41) ) );
  lv1y_45: ex1_sh_lv1y_b(45) <= not( (sh1v4dcd2_cp4 and ex1_b_frac(43) ) or (sh1v4dcd3_cp4 and ex1_b_frac(42) ) );
  lv1y_46: ex1_sh_lv1y_b(46) <= not( (sh1v4dcd2_cp4 and ex1_b_frac(44) ) or (sh1v4dcd3_cp4 and ex1_b_frac(43) ) );
  lv1y_47: ex1_sh_lv1y_b(47) <= not( (sh1v4dcd2_cp4 and ex1_b_frac(45) ) or (sh1v4dcd3_cp4 and ex1_b_frac(44) ) );
  lv1y_48: ex1_sh_lv1y_b(48) <= not( (sh1v4dcd2_cp4 and ex1_b_frac(46) ) or (sh1v4dcd3_cp4 and ex1_b_frac(45) ) );
  lv1y_49: ex1_sh_lv1y_b(49) <= not( (sh1v4dcd2_cp4 and ex1_b_frac(47) ) or (sh1v4dcd3_cp4 and ex1_b_frac(46) ) );
  lv1y_50: ex1_sh_lv1y_b(50) <= not( (sh1v4dcd2_cp4 and ex1_b_frac(48) ) or (sh1v4dcd3_cp4 and ex1_b_frac(47) ) );
  lv1y_51: ex1_sh_lv1y_b(51) <= not( (sh1v4dcd2_cp4 and ex1_b_frac(49) ) or (sh1v4dcd3_cp4 and ex1_b_frac(48) ) );
  lv1y_52: ex1_sh_lv1y_b(52) <= not( (sh1v4dcd2_cp4 and ex1_b_frac(50) ) or (sh1v4dcd3_cp4 and ex1_b_frac(49) ) );
  lv1y_53: ex1_sh_lv1y_b(53) <= not( (sh1v4dcd2_cp4 and ex1_b_frac(51) ) or (sh1v4dcd3_cp4 and ex1_b_frac(50) ) );
  lv1y_54: ex1_sh_lv1y_b(54) <= not( (sh1v4dcd2_cp4 and ex1_b_frac(52) ) or (sh1v4dcd3_cp4 and ex1_b_frac(51) ) );
  lv1y_55: ex1_sh_lv1y_b(55) <= not(                                         sh1v4dcd3_cp4 and ex1_b_frac(52)   );
  
  lv1_00: ex1_sh_lv1(0)  <= not( ex1_sh_lv1x_b(0)                         );
  lv1_01: ex1_sh_lv1(1)  <= not( ex1_sh_lv1x_b(1)                         );
  lv1_02: ex1_sh_lv1(2)  <= not( ex1_sh_lv1x_b(2)   and ex1_sh_lv1y_b(2)  );
  lv1_03: ex1_sh_lv1(3)  <= not( ex1_sh_lv1x_b(3)   and ex1_sh_lv1y_b(3)  );
  lv1_04: ex1_sh_lv1(4)  <= not( ex1_sh_lv1x_b(4)   and ex1_sh_lv1y_b(4)  );
  lv1_05: ex1_sh_lv1(5)  <= not( ex1_sh_lv1x_b(5)   and ex1_sh_lv1y_b(5)  );
  lv1_06: ex1_sh_lv1(6)  <= not( ex1_sh_lv1x_b(6)   and ex1_sh_lv1y_b(6)  );
  lv1_07: ex1_sh_lv1(7)  <= not( ex1_sh_lv1x_b(7)   and ex1_sh_lv1y_b(7)  );
  lv1_08: ex1_sh_lv1(8)  <= not( ex1_sh_lv1x_b(8)   and ex1_sh_lv1y_b(8)  );
  lv1_09: ex1_sh_lv1(9)  <= not( ex1_sh_lv1x_b(9)   and ex1_sh_lv1y_b(9)  );
  lv1_10: ex1_sh_lv1(10) <= not( ex1_sh_lv1x_b(10)  and ex1_sh_lv1y_b(10) );
  lv1_11: ex1_sh_lv1(11) <= not( ex1_sh_lv1x_b(11)  and ex1_sh_lv1y_b(11) );
  lv1_12: ex1_sh_lv1(12) <= not( ex1_sh_lv1x_b(12)  and ex1_sh_lv1y_b(12) );
  lv1_13: ex1_sh_lv1(13) <= not( ex1_sh_lv1x_b(13)  and ex1_sh_lv1y_b(13) );
  lv1_14: ex1_sh_lv1(14) <= not( ex1_sh_lv1x_b(14)  and ex1_sh_lv1y_b(14) );
  lv1_15: ex1_sh_lv1(15) <= not( ex1_sh_lv1x_b(15)  and ex1_sh_lv1y_b(15) );
  lv1_16: ex1_sh_lv1(16) <= not( ex1_sh_lv1x_b(16)  and ex1_sh_lv1y_b(16) );
  lv1_17: ex1_sh_lv1(17) <= not( ex1_sh_lv1x_b(17)  and ex1_sh_lv1y_b(17) );
  lv1_18: ex1_sh_lv1(18) <= not( ex1_sh_lv1x_b(18)  and ex1_sh_lv1y_b(18) );
  lv1_19: ex1_sh_lv1(19) <= not( ex1_sh_lv1x_b(19)  and ex1_sh_lv1y_b(19) );
  lv1_20: ex1_sh_lv1(20) <= not( ex1_sh_lv1x_b(20)  and ex1_sh_lv1y_b(20) );
  lv1_21: ex1_sh_lv1(21) <= not( ex1_sh_lv1x_b(21)  and ex1_sh_lv1y_b(21) );
  lv1_22: ex1_sh_lv1(22) <= not( ex1_sh_lv1x_b(22)  and ex1_sh_lv1y_b(22) );
  lv1_23: ex1_sh_lv1(23) <= not( ex1_sh_lv1x_b(23)  and ex1_sh_lv1y_b(23) );
  lv1_24: ex1_sh_lv1(24) <= not( ex1_sh_lv1x_b(24)  and ex1_sh_lv1y_b(24) );
  lv1_25: ex1_sh_lv1(25) <= not( ex1_sh_lv1x_b(25)  and ex1_sh_lv1y_b(25) );
  lv1_26: ex1_sh_lv1(26) <= not( ex1_sh_lv1x_b(26)  and ex1_sh_lv1y_b(26) );
  lv1_27: ex1_sh_lv1(27) <= not( ex1_sh_lv1x_b(27)  and ex1_sh_lv1y_b(27) );
  lv1_28: ex1_sh_lv1(28) <= not( ex1_sh_lv1x_b(28)  and ex1_sh_lv1y_b(28) );
  lv1_29: ex1_sh_lv1(29) <= not( ex1_sh_lv1x_b(29)  and ex1_sh_lv1y_b(29) );
  lv1_30: ex1_sh_lv1(30) <= not( ex1_sh_lv1x_b(30)  and ex1_sh_lv1y_b(30) );
  lv1_31: ex1_sh_lv1(31) <= not( ex1_sh_lv1x_b(31)  and ex1_sh_lv1y_b(31) );
  lv1_32: ex1_sh_lv1(32) <= not( ex1_sh_lv1x_b(32)  and ex1_sh_lv1y_b(32) );
  lv1_33: ex1_sh_lv1(33) <= not( ex1_sh_lv1x_b(33)  and ex1_sh_lv1y_b(33) );
  lv1_34: ex1_sh_lv1(34) <= not( ex1_sh_lv1x_b(34)  and ex1_sh_lv1y_b(34) );
  lv1_35: ex1_sh_lv1(35) <= not( ex1_sh_lv1x_b(35)  and ex1_sh_lv1y_b(35) );
  lv1_36: ex1_sh_lv1(36) <= not( ex1_sh_lv1x_b(36)  and ex1_sh_lv1y_b(36) );
  lv1_37: ex1_sh_lv1(37) <= not( ex1_sh_lv1x_b(37)  and ex1_sh_lv1y_b(37) );
  lv1_38: ex1_sh_lv1(38) <= not( ex1_sh_lv1x_b(38)  and ex1_sh_lv1y_b(38) );
  lv1_39: ex1_sh_lv1(39) <= not( ex1_sh_lv1x_b(39)  and ex1_sh_lv1y_b(39) );
  lv1_40: ex1_sh_lv1(40) <= not( ex1_sh_lv1x_b(40)  and ex1_sh_lv1y_b(40) );
  lv1_41: ex1_sh_lv1(41) <= not( ex1_sh_lv1x_b(41)  and ex1_sh_lv1y_b(41) );
  lv1_42: ex1_sh_lv1(42) <= not( ex1_sh_lv1x_b(42)  and ex1_sh_lv1y_b(42) );
  lv1_43: ex1_sh_lv1(43) <= not( ex1_sh_lv1x_b(43)  and ex1_sh_lv1y_b(43) );
  lv1_44: ex1_sh_lv1(44) <= not( ex1_sh_lv1x_b(44)  and ex1_sh_lv1y_b(44) );
  lv1_45: ex1_sh_lv1(45) <= not( ex1_sh_lv1x_b(45)  and ex1_sh_lv1y_b(45) );
  lv1_46: ex1_sh_lv1(46) <= not( ex1_sh_lv1x_b(46)  and ex1_sh_lv1y_b(46) );
  lv1_47: ex1_sh_lv1(47) <= not( ex1_sh_lv1x_b(47)  and ex1_sh_lv1y_b(47) );
  lv1_48: ex1_sh_lv1(48) <= not( ex1_sh_lv1x_b(48)  and ex1_sh_lv1y_b(48) );
  lv1_49: ex1_sh_lv1(49) <= not( ex1_sh_lv1x_b(49)  and ex1_sh_lv1y_b(49) );
  lv1_50: ex1_sh_lv1(50) <= not( ex1_sh_lv1x_b(50)  and ex1_sh_lv1y_b(50) );
  lv1_51: ex1_sh_lv1(51) <= not( ex1_sh_lv1x_b(51)  and ex1_sh_lv1y_b(51) );
  lv1_52: ex1_sh_lv1(52) <= not( ex1_sh_lv1x_b(52)  and ex1_sh_lv1y_b(52) );
  lv1_53: ex1_sh_lv1(53) <= not( ex1_sh_lv1x_b(53)  and ex1_sh_lv1y_b(53) );
  lv1_54: ex1_sh_lv1(54) <= not(                        ex1_sh_lv1y_b(54) );
  lv1_55: ex1_sh_lv1(55) <= not(                        ex1_sh_lv1y_b(55) );



  lv2x_00: ex1_sh_lv2x_b(0)  <= not(  sh2v4dcd00_cp1 and ex1_sh_lv1(0)                                            );
  lv2x_01: ex1_sh_lv2x_b(1)  <= not(  sh2v4dcd00_cp1 and ex1_sh_lv1(1)                                            );
  lv2x_02: ex1_sh_lv2x_b(2)  <= not(  sh2v4dcd00_cp1 and ex1_sh_lv1(2)                                            );
  lv2x_03: ex1_sh_lv2x_b(3)  <= not(  sh2v4dcd00_cp1 and ex1_sh_lv1(3)                                            );
  lv2x_04: ex1_sh_lv2x_b(4)  <= not( (sh2v4dcd00_cp1 and ex1_sh_lv1(4)  ) or (sh2v4dcd04_cp1 and ex1_sh_lv1(0)  ) );
  lv2x_05: ex1_sh_lv2x_b(5)  <= not( (sh2v4dcd00_cp1 and ex1_sh_lv1(5)  ) or (sh2v4dcd04_cp1 and ex1_sh_lv1(1)  ) );
  lv2x_06: ex1_sh_lv2x_b(6)  <= not( (sh2v4dcd00_cp1 and ex1_sh_lv1(6)  ) or (sh2v4dcd04_cp1 and ex1_sh_lv1(2)  ) );
  lv2x_07: ex1_sh_lv2x_b(7)  <= not( (sh2v4dcd00_cp1 and ex1_sh_lv1(7)  ) or (sh2v4dcd04_cp1 and ex1_sh_lv1(3)  ) );
  lv2x_08: ex1_sh_lv2x_b(8)  <= not( (sh2v4dcd00_cp1 and ex1_sh_lv1(8)  ) or (sh2v4dcd04_cp1 and ex1_sh_lv1(4)  ) );
  lv2x_09: ex1_sh_lv2x_b(9)  <= not( (sh2v4dcd00_cp1 and ex1_sh_lv1(9)  ) or (sh2v4dcd04_cp1 and ex1_sh_lv1(5)  ) );
  lv2x_10: ex1_sh_lv2x_b(10) <= not( (sh2v4dcd00_cp1 and ex1_sh_lv1(10) ) or (sh2v4dcd04_cp1 and ex1_sh_lv1(6)  ) );
  lv2x_11: ex1_sh_lv2x_b(11) <= not( (sh2v4dcd00_cp1 and ex1_sh_lv1(11) ) or (sh2v4dcd04_cp1 and ex1_sh_lv1(7)  ) );
  lv2x_12: ex1_sh_lv2x_b(12) <= not( (sh2v4dcd00_cp1 and ex1_sh_lv1(12) ) or (sh2v4dcd04_cp1 and ex1_sh_lv1(8)  ) );
  lv2x_13: ex1_sh_lv2x_b(13) <= not( (sh2v4dcd00_cp1 and ex1_sh_lv1(13) ) or (sh2v4dcd04_cp1 and ex1_sh_lv1(9)  ) );
  lv2x_14: ex1_sh_lv2x_b(14) <= not( (sh2v4dcd00_cp1 and ex1_sh_lv1(14) ) or (sh2v4dcd04_cp1 and ex1_sh_lv1(10) ) );
  lv2x_15: ex1_sh_lv2x_b(15) <= not( (sh2v4dcd00_cp2 and ex1_sh_lv1(15) ) or (sh2v4dcd04_cp2 and ex1_sh_lv1(11) ) );
  lv2x_16: ex1_sh_lv2x_b(16) <= not( (sh2v4dcd00_cp2 and ex1_sh_lv1(16) ) or (sh2v4dcd04_cp2 and ex1_sh_lv1(12) ) );
  lv2x_17: ex1_sh_lv2x_b(17) <= not( (sh2v4dcd00_cp2 and ex1_sh_lv1(17) ) or (sh2v4dcd04_cp2 and ex1_sh_lv1(13) ) );
  lv2x_18: ex1_sh_lv2x_b(18) <= not( (sh2v4dcd00_cp2 and ex1_sh_lv1(18) ) or (sh2v4dcd04_cp2 and ex1_sh_lv1(14) ) );
  lv2x_19: ex1_sh_lv2x_b(19) <= not( (sh2v4dcd00_cp2 and ex1_sh_lv1(19) ) or (sh2v4dcd04_cp2 and ex1_sh_lv1(15) ) );
  lv2x_20: ex1_sh_lv2x_b(20) <= not( (sh2v4dcd00_cp2 and ex1_sh_lv1(20) ) or (sh2v4dcd04_cp2 and ex1_sh_lv1(16) ) ); 
  lv2x_21: ex1_sh_lv2x_b(21) <= not( (sh2v4dcd00_cp2 and ex1_sh_lv1(21) ) or (sh2v4dcd04_cp2 and ex1_sh_lv1(17) ) );
  lv2x_22: ex1_sh_lv2x_b(22) <= not( (sh2v4dcd00_cp2 and ex1_sh_lv1(22) ) or (sh2v4dcd04_cp2 and ex1_sh_lv1(18) ) );
  lv2x_23: ex1_sh_lv2x_b(23) <= not( (sh2v4dcd00_cp2 and ex1_sh_lv1(23) ) or (sh2v4dcd04_cp2 and ex1_sh_lv1(19) ) );
  lv2x_24: ex1_sh_lv2x_b(24) <= not( (sh2v4dcd00_cp2 and ex1_sh_lv1(24) ) or (sh2v4dcd04_cp2 and ex1_sh_lv1(20) ) );
  lv2x_25: ex1_sh_lv2x_b(25) <= not( (sh2v4dcd00_cp2 and ex1_sh_lv1(25) ) or (sh2v4dcd04_cp2 and ex1_sh_lv1(21) ) );
  lv2x_26: ex1_sh_lv2x_b(26) <= not( (sh2v4dcd00_cp2 and ex1_sh_lv1(26) ) or (sh2v4dcd04_cp2 and ex1_sh_lv1(22) ) );
  lv2x_27: ex1_sh_lv2x_b(27) <= not( (sh2v4dcd00_cp2 and ex1_sh_lv1(27) ) or (sh2v4dcd04_cp2 and ex1_sh_lv1(23) ) );
  lv2x_28: ex1_sh_lv2x_b(28) <= not( (sh2v4dcd00_cp2 and ex1_sh_lv1(28) ) or (sh2v4dcd04_cp2 and ex1_sh_lv1(24) ) );
  lv2x_29: ex1_sh_lv2x_b(29) <= not( (sh2v4dcd00_cp2 and ex1_sh_lv1(29) ) or (sh2v4dcd04_cp2 and ex1_sh_lv1(25) ) );
  lv2x_30: ex1_sh_lv2x_b(30) <= not( (sh2v4dcd00_cp3 and ex1_sh_lv1(30) ) or (sh2v4dcd04_cp3 and ex1_sh_lv1(26) ) );
  lv2x_31: ex1_sh_lv2x_b(31) <= not( (sh2v4dcd00_cp3 and ex1_sh_lv1(31) ) or (sh2v4dcd04_cp3 and ex1_sh_lv1(27) ) );
  lv2x_32: ex1_sh_lv2x_b(32) <= not( (sh2v4dcd00_cp3 and ex1_sh_lv1(32) ) or (sh2v4dcd04_cp3 and ex1_sh_lv1(28) ) );
  lv2x_33: ex1_sh_lv2x_b(33) <= not( (sh2v4dcd00_cp3 and ex1_sh_lv1(33) ) or (sh2v4dcd04_cp3 and ex1_sh_lv1(29) ) );
  lv2x_34: ex1_sh_lv2x_b(34) <= not( (sh2v4dcd00_cp3 and ex1_sh_lv1(34) ) or (sh2v4dcd04_cp3 and ex1_sh_lv1(30) ) );
  lv2x_35: ex1_sh_lv2x_b(35) <= not( (sh2v4dcd00_cp3 and ex1_sh_lv1(35) ) or (sh2v4dcd04_cp3 and ex1_sh_lv1(31) ) );
  lv2x_36: ex1_sh_lv2x_b(36) <= not( (sh2v4dcd00_cp3 and ex1_sh_lv1(36) ) or (sh2v4dcd04_cp3 and ex1_sh_lv1(32) ) );
  lv2x_37: ex1_sh_lv2x_b(37) <= not( (sh2v4dcd00_cp3 and ex1_sh_lv1(37) ) or (sh2v4dcd04_cp3 and ex1_sh_lv1(33) ) );
  lv2x_38: ex1_sh_lv2x_b(38) <= not( (sh2v4dcd00_cp3 and ex1_sh_lv1(38) ) or (sh2v4dcd04_cp3 and ex1_sh_lv1(34) ) );
  lv2x_39: ex1_sh_lv2x_b(39) <= not( (sh2v4dcd00_cp3 and ex1_sh_lv1(39) ) or (sh2v4dcd04_cp3 and ex1_sh_lv1(35) ) );
  lv2x_40: ex1_sh_lv2x_b(40) <= not( (sh2v4dcd00_cp3 and ex1_sh_lv1(40) ) or (sh2v4dcd04_cp3 and ex1_sh_lv1(36) ) );
  lv2x_41: ex1_sh_lv2x_b(41) <= not( (sh2v4dcd00_cp3 and ex1_sh_lv1(41) ) or (sh2v4dcd04_cp3 and ex1_sh_lv1(37) ) );
  lv2x_42: ex1_sh_lv2x_b(42) <= not( (sh2v4dcd00_cp3 and ex1_sh_lv1(42) ) or (sh2v4dcd04_cp3 and ex1_sh_lv1(38) ) );
  lv2x_43: ex1_sh_lv2x_b(43) <= not( (sh2v4dcd00_cp3 and ex1_sh_lv1(43) ) or (sh2v4dcd04_cp3 and ex1_sh_lv1(39) ) );
  lv2x_44: ex1_sh_lv2x_b(44) <= not( (sh2v4dcd00_cp3 and ex1_sh_lv1(44) ) or (sh2v4dcd04_cp3 and ex1_sh_lv1(40) ) );
  lv2x_45: ex1_sh_lv2x_b(45) <= not( (sh2v4dcd00_cp4 and ex1_sh_lv1(45) ) or (sh2v4dcd04_cp4 and ex1_sh_lv1(41) ) );
  lv2x_46: ex1_sh_lv2x_b(46) <= not( (sh2v4dcd00_cp4 and ex1_sh_lv1(46) ) or (sh2v4dcd04_cp4 and ex1_sh_lv1(42) ) );
  lv2x_47: ex1_sh_lv2x_b(47) <= not( (sh2v4dcd00_cp4 and ex1_sh_lv1(47) ) or (sh2v4dcd04_cp4 and ex1_sh_lv1(43) ) );
  lv2x_48: ex1_sh_lv2x_b(48) <= not( (sh2v4dcd00_cp4 and ex1_sh_lv1(48) ) or (sh2v4dcd04_cp4 and ex1_sh_lv1(44) ) );
  lv2x_49: ex1_sh_lv2x_b(49) <= not( (sh2v4dcd00_cp4 and ex1_sh_lv1(49) ) or (sh2v4dcd04_cp4 and ex1_sh_lv1(45) ) );
  lv2x_50: ex1_sh_lv2x_b(50) <= not( (sh2v4dcd00_cp4 and ex1_sh_lv1(50) ) or (sh2v4dcd04_cp4 and ex1_sh_lv1(46) ) );
  lv2x_51: ex1_sh_lv2x_b(51) <= not( (sh2v4dcd00_cp4 and ex1_sh_lv1(51) ) or (sh2v4dcd04_cp4 and ex1_sh_lv1(47) ) );
  lv2x_52: ex1_sh_lv2x_b(52) <= not( (sh2v4dcd00_cp4 and ex1_sh_lv1(52) ) or (sh2v4dcd04_cp4 and ex1_sh_lv1(48) ) );
  lv2x_53: ex1_sh_lv2x_b(53) <= not( (sh2v4dcd00_cp4 and ex1_sh_lv1(53) ) or (sh2v4dcd04_cp4 and ex1_sh_lv1(49) ) );
  lv2x_54: ex1_sh_lv2x_b(54) <= not( (sh2v4dcd00_cp4 and ex1_sh_lv1(54) ) or (sh2v4dcd04_cp4 and ex1_sh_lv1(50) ) );
  lv2x_55: ex1_sh_lv2x_b(55) <= not( (sh2v4dcd00_cp4 and ex1_sh_lv1(55) ) or (sh2v4dcd04_cp4 and ex1_sh_lv1(51) ) );
  lv2x_56: ex1_sh_lv2x_b(56) <= not(                                          sh2v4dcd04_cp4 and ex1_sh_lv1(52)   );
  lv2x_57: ex1_sh_lv2x_b(57) <= not(                                          sh2v4dcd04_cp4 and ex1_sh_lv1(53)   );
  lv2x_58: ex1_sh_lv2x_b(58) <= not(                                          sh2v4dcd04_cp4 and ex1_sh_lv1(54)   );
  lv2x_59: ex1_sh_lv2x_b(59) <= not(                                          sh2v4dcd04_cp4 and ex1_sh_lv1(55)   );



  lv2y_08: ex1_sh_lv2y_b(8)  <= not(  sh2v4dcd08_cp1 and ex1_sh_lv1(0)                                            );
  lv2y_09: ex1_sh_lv2y_b(9)  <= not(  sh2v4dcd08_cp1 and ex1_sh_lv1(1)                                            );
  lv2y_10: ex1_sh_lv2y_b(10) <= not(  sh2v4dcd08_cp1 and ex1_sh_lv1(2)                                            );
  lv2y_11: ex1_sh_lv2y_b(11) <= not(  sh2v4dcd08_cp1 and ex1_sh_lv1(3)                                            );
  lv2y_12: ex1_sh_lv2y_b(12) <= not( (sh2v4dcd08_cp1 and ex1_sh_lv1(4)  ) or (sh2v4dcd12_cp1 and ex1_sh_lv1(0)  ) );
  lv2y_13: ex1_sh_lv2y_b(13) <= not( (sh2v4dcd08_cp1 and ex1_sh_lv1(5)  ) or (sh2v4dcd12_cp1 and ex1_sh_lv1(1)  ) );
  lv2y_14: ex1_sh_lv2y_b(14) <= not( (sh2v4dcd08_cp1 and ex1_sh_lv1(6)  ) or (sh2v4dcd12_cp1 and ex1_sh_lv1(2)  ) );
  lv2y_15: ex1_sh_lv2y_b(15) <= not( (sh2v4dcd08_cp1 and ex1_sh_lv1(7)  ) or (sh2v4dcd12_cp1 and ex1_sh_lv1(3)  ) );
  lv2y_16: ex1_sh_lv2y_b(16) <= not( (sh2v4dcd08_cp1 and ex1_sh_lv1(8)  ) or (sh2v4dcd12_cp1 and ex1_sh_lv1(4)  ) );
  lv2y_17: ex1_sh_lv2y_b(17) <= not( (sh2v4dcd08_cp1 and ex1_sh_lv1(9)  ) or (sh2v4dcd12_cp1 and ex1_sh_lv1(5)  ) );
  lv2y_18: ex1_sh_lv2y_b(18) <= not( (sh2v4dcd08_cp1 and ex1_sh_lv1(10) ) or (sh2v4dcd12_cp1 and ex1_sh_lv1(6)  ) );
  lv2y_19: ex1_sh_lv2y_b(19) <= not( (sh2v4dcd08_cp1 and ex1_sh_lv1(11) ) or (sh2v4dcd12_cp1 and ex1_sh_lv1(7)  ) );
  lv2y_20: ex1_sh_lv2y_b(20) <= not( (sh2v4dcd08_cp1 and ex1_sh_lv1(12) ) or (sh2v4dcd12_cp1 and ex1_sh_lv1(8)  ) );
  lv2y_21: ex1_sh_lv2y_b(21) <= not( (sh2v4dcd08_cp1 and ex1_sh_lv1(13) ) or (sh2v4dcd12_cp1 and ex1_sh_lv1(9)  ) );
  lv2y_22: ex1_sh_lv2y_b(22) <= not( (sh2v4dcd08_cp2 and ex1_sh_lv1(14) ) or (sh2v4dcd12_cp2 and ex1_sh_lv1(10) ) );
  lv2y_23: ex1_sh_lv2y_b(23) <= not( (sh2v4dcd08_cp2 and ex1_sh_lv1(15) ) or (sh2v4dcd12_cp2 and ex1_sh_lv1(11) ) );
  lv2y_24: ex1_sh_lv2y_b(24) <= not( (sh2v4dcd08_cp2 and ex1_sh_lv1(16) ) or (sh2v4dcd12_cp2 and ex1_sh_lv1(12) ) );
  lv2y_25: ex1_sh_lv2y_b(25) <= not( (sh2v4dcd08_cp2 and ex1_sh_lv1(17) ) or (sh2v4dcd12_cp2 and ex1_sh_lv1(13) ) );
  lv2y_26: ex1_sh_lv2y_b(26) <= not( (sh2v4dcd08_cp2 and ex1_sh_lv1(18) ) or (sh2v4dcd12_cp2 and ex1_sh_lv1(14) ) );
  lv2y_27: ex1_sh_lv2y_b(27) <= not( (sh2v4dcd08_cp2 and ex1_sh_lv1(19) ) or (sh2v4dcd12_cp2 and ex1_sh_lv1(15) ) );
  lv2y_28: ex1_sh_lv2y_b(28) <= not( (sh2v4dcd08_cp2 and ex1_sh_lv1(20) ) or (sh2v4dcd12_cp2 and ex1_sh_lv1(16) ) ); 
  lv2y_29: ex1_sh_lv2y_b(29) <= not( (sh2v4dcd08_cp2 and ex1_sh_lv1(21) ) or (sh2v4dcd12_cp2 and ex1_sh_lv1(17) ) );
  lv2y_30: ex1_sh_lv2y_b(30) <= not( (sh2v4dcd08_cp2 and ex1_sh_lv1(22) ) or (sh2v4dcd12_cp2 and ex1_sh_lv1(18) ) );
  lv2y_31: ex1_sh_lv2y_b(31) <= not( (sh2v4dcd08_cp2 and ex1_sh_lv1(23) ) or (sh2v4dcd12_cp2 and ex1_sh_lv1(19) ) );
  lv2y_32: ex1_sh_lv2y_b(32) <= not( (sh2v4dcd08_cp2 and ex1_sh_lv1(24) ) or (sh2v4dcd12_cp2 and ex1_sh_lv1(20) ) );
  lv2y_33: ex1_sh_lv2y_b(33) <= not( (sh2v4dcd08_cp2 and ex1_sh_lv1(25) ) or (sh2v4dcd12_cp2 and ex1_sh_lv1(21) ) );
  lv2y_34: ex1_sh_lv2y_b(34) <= not( (sh2v4dcd08_cp2 and ex1_sh_lv1(26) ) or (sh2v4dcd12_cp2 and ex1_sh_lv1(22) ) );
  lv2y_35: ex1_sh_lv2y_b(35) <= not( (sh2v4dcd08_cp2 and ex1_sh_lv1(27) ) or (sh2v4dcd12_cp2 and ex1_sh_lv1(23) ) );
  lv2y_36: ex1_sh_lv2y_b(36) <= not( (sh2v4dcd08_cp2 and ex1_sh_lv1(28) ) or (sh2v4dcd12_cp2 and ex1_sh_lv1(24) ) );
  lv2y_37: ex1_sh_lv2y_b(37) <= not( (sh2v4dcd08_cp3 and ex1_sh_lv1(29) ) or (sh2v4dcd12_cp3 and ex1_sh_lv1(25) ) );
  lv2y_38: ex1_sh_lv2y_b(38) <= not( (sh2v4dcd08_cp3 and ex1_sh_lv1(30) ) or (sh2v4dcd12_cp3 and ex1_sh_lv1(26) ) );
  lv2y_39: ex1_sh_lv2y_b(39) <= not( (sh2v4dcd08_cp3 and ex1_sh_lv1(31) ) or (sh2v4dcd12_cp3 and ex1_sh_lv1(27) ) );
  lv2y_40: ex1_sh_lv2y_b(40) <= not( (sh2v4dcd08_cp3 and ex1_sh_lv1(32) ) or (sh2v4dcd12_cp3 and ex1_sh_lv1(28) ) );
  lv2y_41: ex1_sh_lv2y_b(41) <= not( (sh2v4dcd08_cp3 and ex1_sh_lv1(33) ) or (sh2v4dcd12_cp3 and ex1_sh_lv1(29) ) );
  lv2y_42: ex1_sh_lv2y_b(42) <= not( (sh2v4dcd08_cp3 and ex1_sh_lv1(34) ) or (sh2v4dcd12_cp3 and ex1_sh_lv1(30) ) );
  lv2y_43: ex1_sh_lv2y_b(43) <= not( (sh2v4dcd08_cp3 and ex1_sh_lv1(35) ) or (sh2v4dcd12_cp3 and ex1_sh_lv1(31) ) );
  lv2y_44: ex1_sh_lv2y_b(44) <= not( (sh2v4dcd08_cp3 and ex1_sh_lv1(36) ) or (sh2v4dcd12_cp3 and ex1_sh_lv1(32) ) );
  lv2y_45: ex1_sh_lv2y_b(45) <= not( (sh2v4dcd08_cp3 and ex1_sh_lv1(37) ) or (sh2v4dcd12_cp3 and ex1_sh_lv1(33) ) );
  lv2y_46: ex1_sh_lv2y_b(46) <= not( (sh2v4dcd08_cp3 and ex1_sh_lv1(38) ) or (sh2v4dcd12_cp3 and ex1_sh_lv1(34) ) );
  lv2y_47: ex1_sh_lv2y_b(47) <= not( (sh2v4dcd08_cp3 and ex1_sh_lv1(39) ) or (sh2v4dcd12_cp3 and ex1_sh_lv1(35) ) );
  lv2y_48: ex1_sh_lv2y_b(48) <= not( (sh2v4dcd08_cp3 and ex1_sh_lv1(40) ) or (sh2v4dcd12_cp3 and ex1_sh_lv1(36) ) );
  lv2y_49: ex1_sh_lv2y_b(49) <= not( (sh2v4dcd08_cp3 and ex1_sh_lv1(41) ) or (sh2v4dcd12_cp3 and ex1_sh_lv1(37) ) );
  lv2y_50: ex1_sh_lv2y_b(50) <= not( (sh2v4dcd08_cp3 and ex1_sh_lv1(42) ) or (sh2v4dcd12_cp3 and ex1_sh_lv1(38) ) );
  lv2y_51: ex1_sh_lv2y_b(51) <= not( (sh2v4dcd08_cp3 and ex1_sh_lv1(43) ) or (sh2v4dcd12_cp3 and ex1_sh_lv1(39) ) );
  lv2y_52: ex1_sh_lv2y_b(52) <= not( (sh2v4dcd08_cp4 and ex1_sh_lv1(44) ) or (sh2v4dcd12_cp4 and ex1_sh_lv1(40) ) );
  lv2y_53: ex1_sh_lv2y_b(53) <= not( (sh2v4dcd08_cp4 and ex1_sh_lv1(45) ) or (sh2v4dcd12_cp4 and ex1_sh_lv1(41) ) );
  lv2y_54: ex1_sh_lv2y_b(54) <= not( (sh2v4dcd08_cp4 and ex1_sh_lv1(46) ) or (sh2v4dcd12_cp4 and ex1_sh_lv1(42) ) );
  lv2y_55: ex1_sh_lv2y_b(55) <= not( (sh2v4dcd08_cp4 and ex1_sh_lv1(47) ) or (sh2v4dcd12_cp4 and ex1_sh_lv1(43) ) );
  lv2y_56: ex1_sh_lv2y_b(56) <= not( (sh2v4dcd08_cp4 and ex1_sh_lv1(48) ) or (sh2v4dcd12_cp4 and ex1_sh_lv1(44) ) );
  lv2y_57: ex1_sh_lv2y_b(57) <= not( (sh2v4dcd08_cp4 and ex1_sh_lv1(49) ) or (sh2v4dcd12_cp4 and ex1_sh_lv1(45) ) );
  lv2y_58: ex1_sh_lv2y_b(58) <= not( (sh2v4dcd08_cp4 and ex1_sh_lv1(50) ) or (sh2v4dcd12_cp4 and ex1_sh_lv1(46) ) );
  lv2y_59: ex1_sh_lv2y_b(59) <= not( (sh2v4dcd08_cp4 and ex1_sh_lv1(51) ) or (sh2v4dcd12_cp4 and ex1_sh_lv1(47) ) );
  lv2y_60: ex1_sh_lv2y_b(60) <= not( (sh2v4dcd08_cp4 and ex1_sh_lv1(52) ) or (sh2v4dcd12_cp4 and ex1_sh_lv1(48) ) );
  lv2y_61: ex1_sh_lv2y_b(61) <= not( (sh2v4dcd08_cp4 and ex1_sh_lv1(53) ) or (sh2v4dcd12_cp4 and ex1_sh_lv1(49) ) );
  lv2y_62: ex1_sh_lv2y_b(62) <= not( (sh2v4dcd08_cp4 and ex1_sh_lv1(54) ) or (sh2v4dcd12_cp4 and ex1_sh_lv1(50) ) );
  lv2y_63: ex1_sh_lv2y_b(63) <= not( (sh2v4dcd08_cp4 and ex1_sh_lv1(55) ) or (sh2v4dcd12_cp4 and ex1_sh_lv1(51) ) );
  lv2y_64: ex1_sh_lv2y_b(64) <= not(                                          sh2v4dcd12_cp4 and ex1_sh_lv1(52)   );
  lv2y_65: ex1_sh_lv2y_b(65) <= not(                                          sh2v4dcd12_cp4 and ex1_sh_lv1(53)   );
  lv2y_66: ex1_sh_lv2y_b(66) <= not(                                          sh2v4dcd12_cp4 and ex1_sh_lv1(54)   );
  lv2y_67: ex1_sh_lv2y_b(67) <= not(                                          sh2v4dcd12_cp4 and ex1_sh_lv1(55)   );


  lv2z_00: ex1_sh_lv2z_b( 0) <= not( sh2v4dcdpp_cp1 and ex1_special_fcfid( 0) );
  lv2z_01: ex1_sh_lv2z_b( 1) <= not( sh2v4dcdpp_cp1 and ex1_special_fcfid( 1) );
  lv2z_02: ex1_sh_lv2z_b( 2) <= not( sh2v4dcdpp_cp1 and ex1_special_fcfid( 2) );
  lv2z_03: ex1_sh_lv2z_b( 3) <= not( sh2v4dcdpp_cp1 and ex1_special_fcfid( 3) );
  lv2z_04: ex1_sh_lv2z_b( 4) <= not( sh2v4dcdpp_cp1 and ex1_special_fcfid( 4) );
  lv2z_05: ex1_sh_lv2z_b( 5) <= not( sh2v4dcdpp_cp1 and ex1_special_fcfid( 5) );
  lv2z_06: ex1_sh_lv2z_b( 6) <= not( sh2v4dcdpp_cp1 and ex1_special_fcfid( 6) );
  lv2z_07: ex1_sh_lv2z_b( 7) <= not( sh2v4dcdpp_cp1 and ex1_special_fcfid( 7) );
  lv2z_08: ex1_sh_lv2z_b( 8) <= not( sh2v4dcdpp_cp1 and ex1_special_fcfid( 8) );
  lv2z_09: ex1_sh_lv2z_b( 9) <= not( sh2v4dcdpp_cp1 and ex1_special_fcfid( 9) );
  lv2z_10: ex1_sh_lv2z_b(10) <= not( sh2v4dcdpp_cp1 and ex1_special_fcfid(10) );
  lv2z_11: ex1_sh_lv2z_b(11) <= not( sh2v4dcdpp_cp1 and ex1_special_fcfid(11) );
  lv2z_12: ex1_sh_lv2z_b(12) <= not( sh2v4dcdpp_cp1 and ex1_special_fcfid(12) );
  lv2z_13: ex1_sh_lv2z_b(13) <= not( sh2v4dcdpp_cp1 and ex1_special_fcfid(13) );
  lv2z_14: ex1_sh_lv2z_b(14) <= not( sh2v4dcdpp_cp1 and ex1_special_fcfid(14) );
  lv2z_15: ex1_sh_lv2z_b(15) <= not( sh2v4dcdpp_cp1 and ex1_special_fcfid(15) );
  lv2z_16: ex1_sh_lv2z_b(16) <= not( sh2v4dcdpp_cp2 and ex1_special_fcfid(16) );
  lv2z_17: ex1_sh_lv2z_b(17) <= not( sh2v4dcdpp_cp2 and ex1_special_fcfid(17) );
  lv2z_18: ex1_sh_lv2z_b(18) <= not( sh2v4dcdpp_cp2 and ex1_special_fcfid(18) );
  lv2z_19: ex1_sh_lv2z_b(19) <= not( sh2v4dcdpp_cp2 and ex1_special_fcfid(19) );
  lv2z_20: ex1_sh_lv2z_b(20) <= not( sh2v4dcdpp_cp2 and ex1_special_fcfid(20) );
  lv2z_21: ex1_sh_lv2z_b(21) <= not( sh2v4dcdpp_cp2 and ex1_special_fcfid(21) );
  lv2z_22: ex1_sh_lv2z_b(22) <= not( sh2v4dcdpp_cp2 and ex1_special_fcfid(22) );
  lv2z_23: ex1_sh_lv2z_b(23) <= not( sh2v4dcdpp_cp2 and ex1_special_fcfid(23) );
  lv2z_24: ex1_sh_lv2z_b(24) <= not( sh2v4dcdpp_cp2 and ex1_special_fcfid(24) );
  lv2z_25: ex1_sh_lv2z_b(25) <= not( sh2v4dcdpp_cp2 and ex1_special_fcfid(25) );
  lv2z_26: ex1_sh_lv2z_b(26) <= not( sh2v4dcdpp_cp2 and ex1_special_fcfid(26) );
  lv2z_27: ex1_sh_lv2z_b(27) <= not( sh2v4dcdpp_cp2 and ex1_special_fcfid(27) );
  lv2z_28: ex1_sh_lv2z_b(28) <= not( sh2v4dcdpp_cp2 and ex1_special_fcfid(28) );
  lv2z_29: ex1_sh_lv2z_b(29) <= not( sh2v4dcdpp_cp2 and ex1_special_fcfid(29) );
  lv2z_30: ex1_sh_lv2z_b(30) <= not( sh2v4dcdpp_cp2 and ex1_special_fcfid(30) );
  lv2z_31: ex1_sh_lv2z_b(31) <= not( sh2v4dcdpp_cp2 and ex1_special_fcfid(31) );
  lv2z_32: ex1_sh_lv2z_b(32) <= not( sh2v4dcdpp_cp3 and ex1_special_fcfid(32) );
  lv2z_33: ex1_sh_lv2z_b(33) <= not( sh2v4dcdpp_cp3 and ex1_special_fcfid(33) );
  lv2z_34: ex1_sh_lv2z_b(34) <= not( sh2v4dcdpp_cp3 and ex1_special_fcfid(34) );
  lv2z_35: ex1_sh_lv2z_b(35) <= not( sh2v4dcdpp_cp3 and ex1_special_fcfid(35) );
  lv2z_36: ex1_sh_lv2z_b(36) <= not( sh2v4dcdpp_cp3 and ex1_special_fcfid(36) );
  lv2z_37: ex1_sh_lv2z_b(37) <= not( sh2v4dcdpp_cp3 and ex1_special_fcfid(37) );
  lv2z_38: ex1_sh_lv2z_b(38) <= not( sh2v4dcdpp_cp3 and ex1_special_fcfid(38) );
  lv2z_39: ex1_sh_lv2z_b(39) <= not( sh2v4dcdpp_cp3 and ex1_special_fcfid(39) );
  lv2z_40: ex1_sh_lv2z_b(40) <= not( sh2v4dcdpp_cp3 and ex1_special_fcfid(40) );
  lv2z_41: ex1_sh_lv2z_b(41) <= not( sh2v4dcdpp_cp3 and ex1_special_fcfid(41) );
  lv2z_42: ex1_sh_lv2z_b(42) <= not( sh2v4dcdpp_cp3 and ex1_special_fcfid(42) );
  lv2z_43: ex1_sh_lv2z_b(43) <= not( sh2v4dcdpp_cp3 and ex1_special_fcfid(43) );
  lv2z_44: ex1_sh_lv2z_b(44) <= not( sh2v4dcdpp_cp3 and ex1_special_fcfid(44) );
  lv2z_45: ex1_sh_lv2z_b(45) <= not( sh2v4dcdpp_cp3 and ex1_special_fcfid(45) );
  lv2z_46: ex1_sh_lv2z_b(46) <= not( sh2v4dcdpp_cp3 and ex1_special_fcfid(46) );
  lv2z_47: ex1_sh_lv2z_b(47) <= not( sh2v4dcdpp_cp3 and ex1_special_fcfid(47) );
  lv2z_48: ex1_sh_lv2z_b(48) <= not( sh2v4dcdpp_cp4 and ex1_special_fcfid(48) );
  lv2z_49: ex1_sh_lv2z_b(49) <= not( sh2v4dcdpp_cp4 and ex1_special_fcfid(49) );
  lv2z_50: ex1_sh_lv2z_b(50) <= not( sh2v4dcdpp_cp4 and ex1_special_fcfid(50) );
  lv2z_51: ex1_sh_lv2z_b(51) <= not( sh2v4dcdpp_cp4 and ex1_special_fcfid(51) );
  lv2z_52: ex1_sh_lv2z_b(52) <= not( sh2v4dcdpp_cp4 and ex1_special_fcfid(52) );
  lv2z_53: ex1_sh_lv2z_b(53) <= not( sh2v4dcdpp_cp4 and ex1_special_fcfid(53) );
  lv2z_54: ex1_sh_lv2z_b(54) <= not( sh2v4dcdpp_cp4 and ex1_special_fcfid(54) );
  lv2z_55: ex1_sh_lv2z_b(55) <= not( sh2v4dcdpp_cp4 and ex1_special_fcfid(55) );
  lv2z_56: ex1_sh_lv2z_b(56) <= not( sh2v4dcdpp_cp4 and ex1_special_fcfid(56) );
  lv2z_57: ex1_sh_lv2z_b(57) <= not( sh2v4dcdpp_cp4 and ex1_special_fcfid(57) );
  lv2z_58: ex1_sh_lv2z_b(58) <= not( sh2v4dcdpp_cp4 and ex1_special_fcfid(58) );
  lv2z_59: ex1_sh_lv2z_b(59) <= not( sh2v4dcdpp_cp4 and ex1_special_fcfid(59) );
  lv2z_60: ex1_sh_lv2z_b(60) <= not( sh2v4dcdpp_cp4 and ex1_special_fcfid(60) );
  lv2z_61: ex1_sh_lv2z_b(61) <= not( sh2v4dcdpp_cp4 and ex1_special_fcfid(61) );
  lv2z_62: ex1_sh_lv2z_b(62) <= not( sh2v4dcdpp_cp4 and ex1_special_fcfid(62) );
  lv2z_63: ex1_sh_lv2z_b(63) <= not( sh2v4dcdpp_cp4 and ex1_special_fcfid(63) );



  lv2_00: ex1_sh_lvl2(00) <= not( ex1_sh_lv2x_b(00) and                       ex1_sh_lv2z_b(00) ) ; 
  lv2_01: ex1_sh_lvl2(01) <= not( ex1_sh_lv2x_b(01) and                       ex1_sh_lv2z_b(01) ) ; 
  lv2_02: ex1_sh_lvl2(02) <= not( ex1_sh_lv2x_b(02) and                       ex1_sh_lv2z_b(02) ) ; 
  lv2_03: ex1_sh_lvl2(03) <= not( ex1_sh_lv2x_b(03) and                       ex1_sh_lv2z_b(03) ) ; 
  lv2_04: ex1_sh_lvl2(04) <= not( ex1_sh_lv2x_b(04) and                       ex1_sh_lv2z_b(04) ) ; 
  lv2_05: ex1_sh_lvl2(05) <= not( ex1_sh_lv2x_b(05) and                       ex1_sh_lv2z_b(05) ) ; 
  lv2_06: ex1_sh_lvl2(06) <= not( ex1_sh_lv2x_b(06) and                       ex1_sh_lv2z_b(06) ) ; 
  lv2_07: ex1_sh_lvl2(07) <= not( ex1_sh_lv2x_b(07) and                       ex1_sh_lv2z_b(07) ) ; 
  lv2_08: ex1_sh_lvl2(08) <= not( ex1_sh_lv2x_b(08) and ex1_sh_lv2y_b(08) and ex1_sh_lv2z_b(08) ) ; 
  lv2_09: ex1_sh_lvl2(09) <= not( ex1_sh_lv2x_b(09) and ex1_sh_lv2y_b(09) and ex1_sh_lv2z_b(09) ) ; 
  lv2_10: ex1_sh_lvl2(10) <= not( ex1_sh_lv2x_b(10) and ex1_sh_lv2y_b(10) and ex1_sh_lv2z_b(10) ) ; 
  lv2_11: ex1_sh_lvl2(11) <= not( ex1_sh_lv2x_b(11) and ex1_sh_lv2y_b(11) and ex1_sh_lv2z_b(11) ) ; 
  lv2_12: ex1_sh_lvl2(12) <= not( ex1_sh_lv2x_b(12) and ex1_sh_lv2y_b(12) and ex1_sh_lv2z_b(12) ) ; 
  lv2_13: ex1_sh_lvl2(13) <= not( ex1_sh_lv2x_b(13) and ex1_sh_lv2y_b(13) and ex1_sh_lv2z_b(13) ) ; 
  lv2_14: ex1_sh_lvl2(14) <= not( ex1_sh_lv2x_b(14) and ex1_sh_lv2y_b(14) and ex1_sh_lv2z_b(14) ) ; 
  lv2_15: ex1_sh_lvl2(15) <= not( ex1_sh_lv2x_b(15) and ex1_sh_lv2y_b(15) and ex1_sh_lv2z_b(15) ) ; 
  lv2_16: ex1_sh_lvl2(16) <= not( ex1_sh_lv2x_b(16) and ex1_sh_lv2y_b(16) and ex1_sh_lv2z_b(16) ) ; 
  lv2_17: ex1_sh_lvl2(17) <= not( ex1_sh_lv2x_b(17) and ex1_sh_lv2y_b(17) and ex1_sh_lv2z_b(17) ) ; 
  lv2_18: ex1_sh_lvl2(18) <= not( ex1_sh_lv2x_b(18) and ex1_sh_lv2y_b(18) and ex1_sh_lv2z_b(18) ) ; 
  lv2_19: ex1_sh_lvl2(19) <= not( ex1_sh_lv2x_b(19) and ex1_sh_lv2y_b(19) and ex1_sh_lv2z_b(19) ) ; 
  lv2_20: ex1_sh_lvl2(20) <= not( ex1_sh_lv2x_b(20) and ex1_sh_lv2y_b(20) and ex1_sh_lv2z_b(20) ) ; 
  lv2_21: ex1_sh_lvl2(21) <= not( ex1_sh_lv2x_b(21) and ex1_sh_lv2y_b(21) and ex1_sh_lv2z_b(21) ) ; 
  lv2_22: ex1_sh_lvl2(22) <= not( ex1_sh_lv2x_b(22) and ex1_sh_lv2y_b(22) and ex1_sh_lv2z_b(22) ) ; 
  lv2_23: ex1_sh_lvl2(23) <= not( ex1_sh_lv2x_b(23) and ex1_sh_lv2y_b(23) and ex1_sh_lv2z_b(23) ) ; 
  lv2_24: ex1_sh_lvl2(24) <= not( ex1_sh_lv2x_b(24) and ex1_sh_lv2y_b(24) and ex1_sh_lv2z_b(24) ) ; 
  lv2_25: ex1_sh_lvl2(25) <= not( ex1_sh_lv2x_b(25) and ex1_sh_lv2y_b(25) and ex1_sh_lv2z_b(25) ) ; 
  lv2_26: ex1_sh_lvl2(26) <= not( ex1_sh_lv2x_b(26) and ex1_sh_lv2y_b(26) and ex1_sh_lv2z_b(26) ) ; 
  lv2_27: ex1_sh_lvl2(27) <= not( ex1_sh_lv2x_b(27) and ex1_sh_lv2y_b(27) and ex1_sh_lv2z_b(27) ) ; 
  lv2_28: ex1_sh_lvl2(28) <= not( ex1_sh_lv2x_b(28) and ex1_sh_lv2y_b(28) and ex1_sh_lv2z_b(28) ) ; 
  lv2_29: ex1_sh_lvl2(29) <= not( ex1_sh_lv2x_b(29) and ex1_sh_lv2y_b(29) and ex1_sh_lv2z_b(29) ) ; 
  lv2_30: ex1_sh_lvl2(30) <= not( ex1_sh_lv2x_b(30) and ex1_sh_lv2y_b(30) and ex1_sh_lv2z_b(30) ) ; 
  lv2_31: ex1_sh_lvl2(31) <= not( ex1_sh_lv2x_b(31) and ex1_sh_lv2y_b(31) and ex1_sh_lv2z_b(31) ) ; 
  lv2_32: ex1_sh_lvl2(32) <= not( ex1_sh_lv2x_b(32) and ex1_sh_lv2y_b(32) and ex1_sh_lv2z_b(32) ) ; 
  lv2_33: ex1_sh_lvl2(33) <= not( ex1_sh_lv2x_b(33) and ex1_sh_lv2y_b(33) and ex1_sh_lv2z_b(33) ) ; 
  lv2_34: ex1_sh_lvl2(34) <= not( ex1_sh_lv2x_b(34) and ex1_sh_lv2y_b(34) and ex1_sh_lv2z_b(34) ) ; 
  lv2_35: ex1_sh_lvl2(35) <= not( ex1_sh_lv2x_b(35) and ex1_sh_lv2y_b(35) and ex1_sh_lv2z_b(35) ) ; 
  lv2_36: ex1_sh_lvl2(36) <= not( ex1_sh_lv2x_b(36) and ex1_sh_lv2y_b(36) and ex1_sh_lv2z_b(36) ) ; 
  lv2_37: ex1_sh_lvl2(37) <= not( ex1_sh_lv2x_b(37) and ex1_sh_lv2y_b(37) and ex1_sh_lv2z_b(37) ) ; 
  lv2_38: ex1_sh_lvl2(38) <= not( ex1_sh_lv2x_b(38) and ex1_sh_lv2y_b(38) and ex1_sh_lv2z_b(38) ) ; 
  lv2_39: ex1_sh_lvl2(39) <= not( ex1_sh_lv2x_b(39) and ex1_sh_lv2y_b(39) and ex1_sh_lv2z_b(39) ) ; 
  lv2_40: ex1_sh_lvl2(40) <= not( ex1_sh_lv2x_b(40) and ex1_sh_lv2y_b(40) and ex1_sh_lv2z_b(40) ) ; 
  lv2_41: ex1_sh_lvl2(41) <= not( ex1_sh_lv2x_b(41) and ex1_sh_lv2y_b(41) and ex1_sh_lv2z_b(41) ) ; 
  lv2_42: ex1_sh_lvl2(42) <= not( ex1_sh_lv2x_b(42) and ex1_sh_lv2y_b(42) and ex1_sh_lv2z_b(42) ) ; 
  lv2_43: ex1_sh_lvl2(43) <= not( ex1_sh_lv2x_b(43) and ex1_sh_lv2y_b(43) and ex1_sh_lv2z_b(43) ) ; 
  lv2_44: ex1_sh_lvl2(44) <= not( ex1_sh_lv2x_b(44) and ex1_sh_lv2y_b(44) and ex1_sh_lv2z_b(44) ) ; 
  lv2_45: ex1_sh_lvl2(45) <= not( ex1_sh_lv2x_b(45) and ex1_sh_lv2y_b(45) and ex1_sh_lv2z_b(45) ) ; 
  lv2_46: ex1_sh_lvl2(46) <= not( ex1_sh_lv2x_b(46) and ex1_sh_lv2y_b(46) and ex1_sh_lv2z_b(46) ) ; 
  lv2_47: ex1_sh_lvl2(47) <= not( ex1_sh_lv2x_b(47) and ex1_sh_lv2y_b(47) and ex1_sh_lv2z_b(47) ) ; 
  lv2_48: ex1_sh_lvl2(48) <= not( ex1_sh_lv2x_b(48) and ex1_sh_lv2y_b(48) and ex1_sh_lv2z_b(48) ) ; 
  lv2_49: ex1_sh_lvl2(49) <= not( ex1_sh_lv2x_b(49) and ex1_sh_lv2y_b(49) and ex1_sh_lv2z_b(49) ) ; 
  lv2_50: ex1_sh_lvl2(50) <= not( ex1_sh_lv2x_b(50) and ex1_sh_lv2y_b(50) and ex1_sh_lv2z_b(50) ) ; 
  lv2_51: ex1_sh_lvl2(51) <= not( ex1_sh_lv2x_b(51) and ex1_sh_lv2y_b(51) and ex1_sh_lv2z_b(51) ) ; 
  lv2_52: ex1_sh_lvl2(52) <= not( ex1_sh_lv2x_b(52) and ex1_sh_lv2y_b(52) and ex1_sh_lv2z_b(52) ) ; 
  lv2_53: ex1_sh_lvl2(53) <= not( ex1_sh_lv2x_b(53) and ex1_sh_lv2y_b(53) and ex1_sh_lv2z_b(53) ) ; 
  lv2_54: ex1_sh_lvl2(54) <= not( ex1_sh_lv2x_b(54) and ex1_sh_lv2y_b(54) and ex1_sh_lv2z_b(54) ) ; 
  lv2_55: ex1_sh_lvl2(55) <= not( ex1_sh_lv2x_b(55) and ex1_sh_lv2y_b(55) and ex1_sh_lv2z_b(55) ) ; 
  lv2_56: ex1_sh_lvl2(56) <= not( ex1_sh_lv2x_b(56) and ex1_sh_lv2y_b(56) and ex1_sh_lv2z_b(56) ) ; 
  lv2_57: ex1_sh_lvl2(57) <= not( ex1_sh_lv2x_b(57) and ex1_sh_lv2y_b(57) and ex1_sh_lv2z_b(57) ) ; 
  lv2_58: ex1_sh_lvl2(58) <= not( ex1_sh_lv2x_b(58) and ex1_sh_lv2y_b(58) and ex1_sh_lv2z_b(58) ) ; 
  lv2_59: ex1_sh_lvl2(59) <= not( ex1_sh_lv2x_b(59) and ex1_sh_lv2y_b(59) and ex1_sh_lv2z_b(59) ) ; 
  lv2_60: ex1_sh_lvl2(60) <= not(                       ex1_sh_lv2y_b(60) and ex1_sh_lv2z_b(60) ) ; 
  lv2_61: ex1_sh_lvl2(61) <= not(                       ex1_sh_lv2y_b(61) and ex1_sh_lv2z_b(61) ) ; 
  lv2_62: ex1_sh_lvl2(62) <= not(                       ex1_sh_lv2y_b(62) and ex1_sh_lv2z_b(62) ) ; 
  lv2_63: ex1_sh_lvl2(63) <= not(                       ex1_sh_lv2y_b(63) and ex1_sh_lv2z_b(63) ) ; 
  lv2_64: ex1_sh_lvl2(64) <= not(                       ex1_sh_lv2y_b(64)                       ) ; 
  lv2_65: ex1_sh_lvl2(65) <= not(                       ex1_sh_lv2y_b(65)                       ) ; 
  lv2_66: ex1_sh_lvl2(66) <= not(                       ex1_sh_lv2y_b(66)                       ) ; 
  lv2_67: ex1_sh_lvl2(67) <= not(                       ex1_sh_lv2y_b(67)                       ) ;



end; 
                




