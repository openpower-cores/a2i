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


entity xuq_add is
generic(       expand_type               : integer := 2  ); -- 0 - ibm tech, 1 - other );
port(
     x_b          :in  std_ulogic_vector(0 to 63) ; -- after xor
     y_b          :in  std_ulogic_vector(0 to 63) ;
     ci           :in  std_ulogic_vector(8 to 8)  ;

     sum          :out std_ulogic_vector(0 to 63);
     cout_32      :out std_ulogic ;
     cout_0       :out std_ulogic
);


end xuq_add; -- ENTITY

architecture xuq_add of xuq_add is

 constant tiup : std_ulogic := '1';
 constant tidn : std_ulogic := '0';

 signal g01, g01_b :std_ulogic_vector(0 to 63);
 signal t01, t01_b :std_ulogic_vector(0 to 63);
 signal sum_0, sum_1 :std_ulogic_vector(0 to 63);
 signal g08 :std_ulogic_vector(0 to 7);
 signal t08 :std_ulogic_vector(0 to 7);
 signal c64_b :std_ulogic_vector(0 to 7);
 signal cout_32x , cout_32y_b :std_ulogic;
 signal ci_cp1_lv1_b , ci_cp1_lv2 , ci_cp1_lv3_b , ci_cp1_lv4 :std_ulogic;
 signal                ci_cp2_lv2 , ci_cp2_lv3_b              :std_ulogic;


begin



u_ci_11:  ci_cp1_lv1_b <= not ci(8)        ; -- x2
u_ci_12:  ci_cp1_lv2   <= not ci_cp1_lv1_b ; -- x2
u_ci_13:  ci_cp1_lv3_b <= not ci_cp1_lv2   ; -- x3
u_ci_14:  ci_cp1_lv4   <= not ci_cp1_lv3_b ; -- x4

u_ci_22:  ci_cp2_lv2   <= not ci_cp1_lv1_b ; -- x2
u_ci_23:  ci_cp2_lv3_b <= not ci_cp2_lv2   ; -- x3


--//##################################################
--//## pgt
--//##################################################

   u_g01:   g01(0 to 63)   <= not( x_b(0 to 63) or  y_b(0 to 63) );
   u_t01:   t01(0 to 63)   <= not( x_b(0 to 63) and y_b(0 to 63) );
   u_g01b:  g01_b(0 to 63) <= not g01(0 to 63); -- small,  buffer off
   u_t01b:  t01_b(0 to 63) <= not t01(0 to 63); -- small,  buffer off


--//##################################################
--//## local part of byte group
--//##################################################

 loc_0: entity work.xuq_add_loc(xuq_add_loc) port map(
        g01_b(0 to 7) =>  g01_b(0 to 7)       ,--i--
        t01_b(0 to 7) =>  t01_b(0 to 7)       ,--i--
        sum_0(0 to 7) =>  sum_0(0 to 7)       ,--o--
        sum_1(0 to 7) =>  sum_1(0 to 7)      );--o--

 loc_1: entity work.xuq_add_loc(xuq_add_loc) port map(
        g01_b(0 to 7) =>  g01_b(8 to 15)      ,--i--
        t01_b(0 to 7) =>  t01_b(8 to 15)      ,--i--
        sum_0(0 to 7) =>  sum_0(8 to 15)      ,--o--
        sum_1(0 to 7) =>  sum_1(8 to 15)     );--o--

 loc_2: entity work.xuq_add_loc(xuq_add_loc) port map(
        g01_b(0 to 7) =>  g01_b(16 to 23)     ,--i--
        t01_b(0 to 7) =>  t01_b(16 to 23)     ,--i--
        sum_0(0 to 7) =>  sum_0(16 to 23)     ,--o--
        sum_1(0 to 7) =>  sum_1(16 to 23)    );--o--

 loc_3: entity work.xuq_add_loc(xuq_add_loc) port map(
        g01_b(0 to 7) =>  g01_b(24 to 31)     ,--i--
        t01_b(0 to 7) =>  t01_b(24 to 31)     ,--i--
        sum_0(0 to 7) =>  sum_0(24 to 31)     ,--o--
        sum_1(0 to 7) =>  sum_1(24 to 31)    );--o--

 loc_4: entity work.xuq_add_loc(xuq_add_loc) port map(
        g01_b(0 to 7) =>  g01_b(32 to 39)     ,--i--
        t01_b(0 to 7) =>  t01_b(32 to 39)     ,--i--
        sum_0(0 to 7) =>  sum_0(32 to 39)     ,--o--
        sum_1(0 to 7) =>  sum_1(32 to 39)    );--o--

 loc_5: entity work.xuq_add_loc(xuq_add_loc) port map(
        g01_b(0 to 7) =>  g01_b(40 to 47)     ,--i--
        t01_b(0 to 7) =>  t01_b(40 to 47)     ,--i--
        sum_0(0 to 7) =>  sum_0(40 to 47)     ,--o--
        sum_1(0 to 7) =>  sum_1(40 to 47)    );--o--

 loc_6: entity work.xuq_add_loc(xuq_add_loc) port map(
        g01_b(0 to 7) =>  g01_b(48 to 55)     ,--i--
        t01_b(0 to 7) =>  t01_b(48 to 55)     ,--i--
        sum_0(0 to 7) =>  sum_0(48 to 55)     ,--o--
        sum_1(0 to 7) =>  sum_1(48 to 55)    );--o--

 loc_7: entity work.xuq_add_loc(xuq_add_loc) port map(
        g01_b(0 to 7) =>  g01_b(56 to 63)     ,--i--
        t01_b(0 to 7) =>  t01_b(56 to 63)     ,--i--
        sum_0(0 to 7) =>  sum_0(56 to 63)     ,--o--
        sum_1(0 to 7) =>  sum_1(56 to 63)    );--o--


--//##################################################
--//## local part of global carry
--//##################################################

 gclc_0: entity work.xuq_add_glbloc(xuq_add_glbloc) port map(
      g01(0 to 7)  => g01(0 to 7)        ,--i--
      t01(0 to 7)  => t01(0 to 7)        ,--i--
      g08          => g08(0)             ,--o--
      t08          => t08(0)            );--o--

 gclc_1: entity work.xuq_add_glbloc(xuq_add_glbloc) port map(
      g01(0 to 7)  => g01(8 to 15)       ,--i--
      t01(0 to 7)  => t01(8 to 15)       ,--i--
      g08          => g08(1)             ,--o--
      t08          => t08(1)            );--o--

 gclc_2: entity work.xuq_add_glbloc(xuq_add_glbloc) port map(
      g01(0 to 7)  => g01(16 to 23)      ,--i--
      t01(0 to 7)  => t01(16 to 23)      ,--i--
      g08          => g08(2)             ,--o--
      t08          => t08(2)            );--o--

 gclc_3: entity work.xuq_add_glbloc(xuq_add_glbloc) port map(
      g01(0 to 7)  => g01(24 to 31)      ,--i--
      t01(0 to 7)  => t01(24 to 31)      ,--i--
      g08          => g08(3)             ,--o--
      t08          => t08(3)            );--o--

 gclc_4: entity work.xuq_add_glbloc(xuq_add_glbloc) port map(
      g01(0 to 7)  => g01(32 to 39)      ,--i--
      t01(0 to 7)  => t01(32 to 39)      ,--i--
      g08          => g08(4)             ,--o--
      t08          => t08(4)            );--o--

 gclc_5: entity work.xuq_add_glbloc(xuq_add_glbloc) port map(
      g01(0 to 7)  => g01(40 to 47)      ,--i--
      t01(0 to 7)  => t01(40 to 47)      ,--i--
      g08          => g08(5)             ,--o--
      t08          => t08(5)            );--o--

 gclc_6: entity work.xuq_add_glbloc(xuq_add_glbloc) port map(
      g01(0 to 7)  => g01(48 to 55)      ,--i--
      t01(0 to 7)  => t01(48 to 55)      ,--i--
      g08          => g08(6)             ,--o--
      t08          => t08(6)            );--o--

 gclc_7: entity work.xuq_add_glbloc(xuq_add_glbloc) port map(
      g01(0 to 7)  => g01(56 to 63)      ,--i--
      t01(0 to 7)  => t01(56 to 63)      ,--i--
      g08          => g08(7)             ,--o--
      t08          => t08(7)            );--o--


--//##################################################
--//## global part of global carry
--//##################################################

 gc: entity work.xuq_add_glbglbci(xuq_add_glbglbci) port map(
     g08(0 to 7)    => g08(0 to 7)    ,--i--
     t08(0 to 7)    => t08(0 to 7)    ,--i--
     ci             => ci_cp1_lv4     ,--i--
     c64_b(0 to 7)  => c64_b(0 to 7) );--o--

 u_c32x: cout_32x   <= not c64_b(4)   ; --(small)
 u_c32y: cout_32y_b <= not cout_32x   ;
 u_c32:  cout_32    <= not cout_32y_b ; --output--

 u_c64:  cout_0     <= not c64_b(0)   ; --output-- --rename--

--//##################################################
--//## final mux
--//##################################################

 fm_0: entity work.xuq_add_csmux(xuq_add_csmux) port map(
  ci_b             => c64_b(1)           ,--i--
  sum_0(0 to 7)    => sum_0(0 to 7)      ,--i--
  sum_1(0 to 7)    => sum_1(0 to 7)      ,--i--
  sum  (0 to 7)    => sum  (0 to 7)     );--o--

 fm_1: entity work.xuq_add_csmux(xuq_add_csmux) port map(
  ci_b             => c64_b(2)           ,--i--
  sum_0(0 to 7)    => sum_0(8 to 15)     ,--i--
  sum_1(0 to 7)    => sum_1(8 to 15)     ,--i--
  sum  (0 to 7)    => sum  (8 to 15)    );--o--

 fm_2: entity work.xuq_add_csmux(xuq_add_csmux) port map(
  ci_b             => c64_b(3)           ,--i--
  sum_0(0 to 7)    => sum_0(16 to 23)    ,--i--
  sum_1(0 to 7)    => sum_1(16 to 23)    ,--i--
  sum  (0 to 7)    => sum  (16 to 23)   );--o--

 fm_3: entity work.xuq_add_csmux(xuq_add_csmux) port map(
  ci_b             => c64_b(4)           ,--i--
  sum_0(0 to 7)    => sum_0(24 to 31)    ,--i--
  sum_1(0 to 7)    => sum_1(24 to 31)    ,--i--
  sum  (0 to 7)    => sum  (24 to 31)   );--o--

 fm_4: entity work.xuq_add_csmux(xuq_add_csmux) port map(
  ci_b             => c64_b(5)           ,--i--
  sum_0(0 to 7)    => sum_0(32 to 39)    ,--i--
  sum_1(0 to 7)    => sum_1(32 to 39)    ,--i--
  sum  (0 to 7)    => sum  (32 to 39)   );--o--

 fm_5: entity work.xuq_add_csmux(xuq_add_csmux) port map(
  ci_b             => c64_b(6)           ,--i--
  sum_0(0 to 7)    => sum_0(40 to 47)    ,--i--
  sum_1(0 to 7)    => sum_1(40 to 47)    ,--i--
  sum  (0 to 7)    => sum  (40 to 47)   );--o--

 fm_6: entity work.xuq_add_csmux(xuq_add_csmux) port map(
  ci_b             => c64_b(7)           ,--i--
  sum_0(0 to 7)    => sum_0(48 to 55)    ,--i--
  sum_1(0 to 7)    => sum_1(48 to 55)    ,--i--
  sum  (0 to 7)    => sum  (48 to 55)   );--o--

 fm_7: entity work.xuq_add_csmux(xuq_add_csmux) port map(
  ci_b             => ci_cp2_lv3_b       ,--i--
  sum_0(0 to 7)    => sum_0(56 to 63)    ,--i--
  sum_1(0 to 7)    => sum_1(56 to 63)    ,--i--
  sum  (0 to 7)    => sum  (56 to 63)   );--o--

end; -- xuq_add ARCHITECTURE

