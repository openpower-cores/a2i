-- © IBM Corp. 2020
-- This softcore is licensed under and subject to the terms of the CC-BY 4.0
-- license (https://creativecommons.org/licenses/by/4.0/legalcode). 
-- Additional rights, including the right to physically implement a softcore 
-- that is compliant with the required sections of the Power ISA 
-- Specification, will be available at no cost via the OpenPOWER Foundation. 
-- This README will be updated with additional information when OpenPOWER's 
-- license is available.

--  Description:  XU LSU Compare Logic

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

entity xuq_lsu_cmp is
generic( expand_type: integer := 2  ); -- 0 - ibm tech, 1 - other );
port(
       vdd                                       :inout power_logic;
       gnd                                       :inout power_logic;
       nclk                                      :in  clk_logic;
       delay_lclkr                               :in  std_ulogic_vector(0 to 2);-- LCB input
       mpw1_b                                    :in  std_ulogic_vector(0 to 2);-- LCB input
       mpw2_b                                    :in  std_ulogic_vector(0 to 2);-- LCB input
       forcee                                    :in  std_ulogic_vector(0 to 2);-- LCB input
       sg_0                                      :in  std_ulogic_vector(0 to 2);-- LCB input
       thold_0_b                                 :in  std_ulogic_vector(0 to 2);-- LCB input
       scan_in                                   :in  std_ulogic_vector(0 to 2); --perv
       scan_out                                  :out std_ulogic_vector(0 to 2); --perv

       enable_lsb_lmq_b                          :in  std_ulogic ;--enable lsb in the compares
       enable_lsb_oth_b                          :in  std_ulogic ;--enable lsb in the compares
       enable_lsb_bi_b                           :in  std_ulogic ;--enable lsb in the compares

       ex2_erat_act                              :in  std_ulogic; -- erat act
       binv2_ex2_stg_act                         :in  std_ulogic; -- directory act
       lmq_entry_act                             :in  std_ulogic; -- act for lmq entries

       ex3_p_addr                                :in  std_ulogic_vector(22 to 51); -- erat array output
       ex2_p_addr_lwr                            :in  std_ulogic_vector(52 to 57);
       ex3_p_addr_o                              :out std_ulogic_vector(22 to 57);--output-- just a rename

       ex2_wayA_tag                              :in  std_ulogic_vector(22 to 52); -- directory output 0/1
       ex2_wayB_tag                              :in  std_ulogic_vector(22 to 52); -- directory output 0/1
       ex2_wayC_tag                              :in  std_ulogic_vector(22 to 52); -- directory output 2/3
       ex2_wayD_tag                              :in  std_ulogic_vector(22 to 52); -- directory output 2/3
       ex2_wayE_tag                              :in  std_ulogic_vector(22 to 52); -- directory output 4/5
       ex2_wayF_tag                              :in  std_ulogic_vector(22 to 52); -- directory output 4/5
       ex2_wayG_tag                              :in  std_ulogic_vector(22 to 52); -- directory output 6/7
       ex2_wayH_tag                              :in  std_ulogic_vector(22 to 52); -- directory output 6/7

       ex3_cClass_upd_way_a                      :in  std_ulogic; -- enable compare
       ex3_cClass_upd_way_b                      :in  std_ulogic; -- enable compare
       ex3_cClass_upd_way_c                      :in  std_ulogic; -- enable compare
       ex3_cClass_upd_way_d                      :in  std_ulogic; -- enable compare
       ex3_cClass_upd_way_e                      :in  std_ulogic; -- enable compare
       ex3_cClass_upd_way_f                      :in  std_ulogic; -- enable compare
       ex3_cClass_upd_way_g                      :in  std_ulogic; -- enable compare
       ex3_cClass_upd_way_h                      :in  std_ulogic; -- enable compare

       ex3_way_cmp_a                             :out std_ulogic; -- compare result (without the enable)
       ex3_way_cmp_b                             :out std_ulogic; -- compare result (without the enable)
       ex3_way_cmp_c                             :out std_ulogic; -- compare result (without the enable)
       ex3_way_cmp_d                             :out std_ulogic; -- compare result (without the enable)
       ex3_way_cmp_e                             :out std_ulogic; -- compare result (without the enable)
       ex3_way_cmp_f                             :out std_ulogic; -- compare result (without the enable)
       ex3_way_cmp_g                             :out std_ulogic; -- compare result (without the enable)
       ex3_way_cmp_h                             :out std_ulogic; -- compare result (without the enable)

       ex3_wayA_tag                              :out std_ulogic_vector(0 to 30); -- Way Tag
       ex3_wayB_tag                              :out std_ulogic_vector(0 to 30); -- Way Tag
       ex3_wayC_tag                              :out std_ulogic_vector(0 to 30); -- Way Tag
       ex3_wayD_tag                              :out std_ulogic_vector(0 to 30); -- Way Tag
       ex3_wayE_tag                              :out std_ulogic_vector(0 to 30); -- Way Tag
       ex3_wayF_tag                              :out std_ulogic_vector(0 to 30); -- Way Tag
       ex3_wayG_tag                              :out std_ulogic_vector(0 to 30); -- Way Tag
       ex3_wayH_tag                              :out std_ulogic_vector(0 to 30); -- Way Tag

       ldq_comp_val                              :in  std_ulogic_vector(0 to 7); -- enable compares against lmq
       ldq_match                                 :out std_ulogic_vector(0 to 7); -- compare result (without enable)

       ldq_fnd_b                                 :out std_ulogic; --  or 8 enabled ldq compares
       cmp_flush                                 :out std_ulogic; -- or all 16 enabled compares

       dir_eq_v_or_b                             :out std_ulogic; -- the 8 directory match with valid "OR"ed

       l_q_wrt_en                                :in  std_ulogic_vector(0 to 7);   -- load entry, (hold when not loading)
       ld_ex7_recov                              :in  std_ulogic    ;              -- alternate ldq wr select
       ex7_ld_recov_addr                         :in  std_ulogic_vector(22 to 57) ;-- alternate ldq wr data

       ex4_loadmiss_qentry                       :in  std_ulogic_vector(0 to 7);   -- mux 3 select
       ex4_ld_addr                               :out std_ulogic_vector(22 to 57); -- mux 3

       l_q_rd_en                                 :in  std_ulogic_vector(0 to 7);   -- mux 2 select
       l_miss_entry_addr                         :out std_ulogic_vector(22 to 57); -- mux 2

       rel_tag_1hot                              :in  std_ulogic_vector(0 to 7);   -- mux 1 select
       rel_addr                                  :out std_ulogic_vector(22 to 57); -- mux 1

       back_inv_addr                             :in  std_ulogic_vector(22 to 57); -- compare to each ldq entry
       back_inv_cmp_val                          :in  std_ulogic_vector(0 to 7);   --
       back_inv_addr_hit                         :out std_ulogic_vector(0 to 7);   --

       s_m_queue0_addr                           :in  std_ulogic_vector(22 to 57); --
       st_entry0_val                             :in  std_ulogic                 ; --
       ex3addr_hit_stq                           :out std_ulogic                 ; --

       ex4_st_entry_addr                         :in  std_ulogic_vector(22 to 57); --
       ex4_st_val                                :in  std_ulogic                 ; --
       ex3addr_hit_ex4st                         :out std_ulogic                   --

);



end xuq_lsu_cmp; -- ENTITY

architecture xuq_lsu_cmp of xuq_lsu_cmp is

  constant tiup : std_ulogic := '1';
  constant tidn : std_ulogic := '0';

  signal ex3_erat_lclk,  dir_lclk  ,  lmq_lclk  :clk_logic;
  signal ex3_erat_d1clk, dir_d1clk ,  lmq_d1clk :std_ulogic;
  signal ex3_erat_d2clk, dir_d2clk ,  lmq_d2clk :std_ulogic;

  signal ex3_erat_q                                           :std_ulogic_vector(0 to 35);
  signal ex3_erat_q_b                                         :std_ulogic_vector(30 to 35);
  signal ex3_erat_si,  ex3_erat_so                            :std_ulogic_vector(0 to 5);
  signal dir0_si,      dir0_so,     dir0_q_b,     dir0_q      :std_ulogic_vector(0 to 30);
  signal dir1_si,      dir1_so,     dir1_q_b,     dir1_q      :std_ulogic_vector(0 to 30);
  signal dir2_si,      dir2_so,     dir2_q_b,     dir2_q      :std_ulogic_vector(0 to 30);
  signal dir3_si,      dir3_so,     dir3_q_b,     dir3_q      :std_ulogic_vector(0 to 30);
  signal dir4_si,      dir4_so,     dir4_q_b,     dir4_q      :std_ulogic_vector(0 to 30);
  signal dir5_si,      dir5_so,     dir5_q_b,     dir5_q      :std_ulogic_vector(0 to 30);
  signal dir6_si,      dir6_so,     dir6_q_b,     dir6_q      :std_ulogic_vector(0 to 30);
  signal dir7_si,      dir7_so,     dir7_q_b,     dir7_q      :std_ulogic_vector(0 to 30);
  signal lmq0_si,      lmq0_so,     lmq0_q_b,     lmq0_q     , lmq0_din     , lmq0_new_b   , lmq0_fbk_b    :std_ulogic_vector(0 to 35);
  signal lmq1_si,      lmq1_so,     lmq1_q_b,     lmq1_q     , lmq1_din     , lmq1_new_b   , lmq1_fbk_b    :std_ulogic_vector(0 to 35);
  signal lmq2_si,      lmq2_so,     lmq2_q_b,     lmq2_q     , lmq2_din     , lmq2_new_b   , lmq2_fbk_b    :std_ulogic_vector(0 to 35);
  signal lmq3_si,      lmq3_so,     lmq3_q_b,     lmq3_q     , lmq3_din     , lmq3_new_b   , lmq3_fbk_b    :std_ulogic_vector(0 to 35);
  signal lmq4_si,      lmq4_so,     lmq4_q_b,     lmq4_q     , lmq4_din     , lmq4_new_b   , lmq4_fbk_b    :std_ulogic_vector(0 to 35);
  signal lmq5_si,      lmq5_so,     lmq5_q_b,     lmq5_q     , lmq5_din     , lmq5_new_b   , lmq5_fbk_b    :std_ulogic_vector(0 to 35);
  signal lmq6_si,      lmq6_so,     lmq6_q_b,     lmq6_q     , lmq6_din     , lmq6_new_b   , lmq6_fbk_b    :std_ulogic_vector(0 to 35);
  signal lmq7_si,      lmq7_so,     lmq7_q_b,     lmq7_q     , lmq7_din     , lmq7_new_b   , lmq7_fbk_b    :std_ulogic_vector(0 to 35);

  signal l_q_wrt_en_b :std_ulogic_vector(0 to 7);


   signal  ex3_erat_i1_b  :std_ulogic_vector(0 to 35); --7p5 HOP OVER dir 23 , hop over dir latches
   signal  ex3_erat_i2    :std_ulogic_vector(0 to 35); --7p5 drive compare plus terminator
   signal  ex3_erat_i3_b  :std_ulogic_vector(0 to 35); --2   terminator
   signal  ex3_erat_i4    :std_ulogic_vector(0 to 35); --4   drive out off stack to compares
   signal  ex3_erat_i5_b  :std_ulogic_vector(0 to 35); --4   drive 2 compares
   signal  ex3_erat_i6    :std_ulogic_vector(0 to 35); --4   output
   signal  ex3_erat_din   :std_ulogic_vector(0 to 35); --4   hop to final comp
   signal ld_ex7_recov_b :std_ulogic ;
   signal ex3_lmq_wd0_b, ex3_lmq_wd1_b, ex3_lmq_wd, ex3_lmq_wd_b :std_ulogic_vector(0 to 35);


   signal dir4_q1_b, dir4_q0 :std_ulogic_vector(0 to 30);
   signal dir5_q1_b, dir5_q0 :std_ulogic_vector(0 to 30);
   signal dir6_q1_b, dir6_q0 :std_ulogic_vector(0 to 30);
   signal dir7_q1_b, dir7_q0 :std_ulogic_vector(0 to 30);
    

   signal lmq_eq, lmq_eq_b :std_ulogic_vector(0 to 7);
   signal dir_eq :std_ulogic_vector(0 to 7); 



    signal lmq0_i0_b , lmq0_ix , lmq0_ix1_b, lmq0_ix2, lmq0_iy :std_ulogic_vector(0 to 35);
    signal lmq1_i0_b , lmq1_ix , lmq1_ix1_b, lmq1_ix2, lmq1_iy :std_ulogic_vector(0 to 35);
    signal lmq2_i0_b , lmq2_ix , lmq2_ix1_b, lmq2_ix2, lmq2_iy :std_ulogic_vector(0 to 35);
    signal lmq3_i0_b , lmq3_ix , lmq3_ix1_b, lmq3_ix2, lmq3_iy :std_ulogic_vector(0 to 35);
    signal lmq4_i0_b , lmq4_ix , lmq4_ix1_b, lmq4_ix2, lmq4_iy :std_ulogic_vector(0 to 35);
    signal lmq5_i0_b , lmq5_ix , lmq5_ix1_b, lmq5_ix2, lmq5_iy :std_ulogic_vector(0 to 35);
    signal lmq6_i0_b , lmq6_ix , lmq6_ix1_b, lmq6_ix2, lmq6_iy :std_ulogic_vector(0 to 35);
    signal lmq7_i0_b , lmq7_ix , lmq7_ix1_b, lmq7_ix2, lmq7_iy :std_ulogic_vector(0 to 35);



   signal smq_addr_b, sto_addr_b :std_ulogic_vector(0 to 35);
   signal smq_eq, smq_eqv_b, sto_eq, sto_eqv_b :std_ulogic;

   signal binv_addr_b, binv_addr :std_ulogic_vector(0 to 35);
   signal binv_eq, binv_eqv_b    :std_ulogic_vector(0 to 7);


   signal mux1_lv1_01_b, mux1_lv1_23_b, mux1_lv1_45_b, mux1_lv1_67_b :std_ulogic_vector(0 to 35);
   signal mux1_lv2_03, mux1_lv2_47, mux1_lv3_07_b                    :std_ulogic_vector(0 to 35);

   signal mux2_lv1_01_b, mux2_lv1_23_b, mux2_lv1_45_b, mux2_lv1_67_b :std_ulogic_vector(0 to 35);
   signal mux2_lv2_03, mux2_lv2_47, mux2_lv3_07_b                    :std_ulogic_vector(0 to 35);

   signal mux3_lv1_01_b, mux3_lv1_23_b, mux3_lv1_45_b, mux3_lv1_67_b :std_ulogic_vector(0 to 35);
   signal mux3_lv2_03, mux3_lv2_47, mux3_lv3_07_b                    :std_ulogic_vector(0 to 35);


   signal cmpe_36_b :std_ulogic_vector(0 to 7);
   signal o2_36     :std_ulogic_vector(0 to 3);
   signal o4_36_b   :std_ulogic_vector(0 to 1);
   signal o8_36     :std_ulogic;

   signal cmpe_30_b :std_ulogic_vector(0 to 7);
   signal o2_30     :std_ulogic_vector(0 to 3);
   signal o4_30_b   :std_ulogic_vector(0 to 1);
   signal o8_30     :std_ulogic;
   signal hit_b, hit, hit_1_b, hit_2, hit_3_b   :std_ulogic ;


   signal dir_comp_val :std_ulogic_vector(0 to 7);


   signal enable_lsb_lmq, enable_lsb_oth, enable_lsb_bi :std_ulogic ;

   -----------------//---------------------------------------------------------------


begin

-- ################################################################
-- # inverters from array to latches : add later
-- ################################################################

-- ################################################################
-- # redrive networks after Latches
-- ################################################################

    ex3_erat_q(0 to 29) <= ex3_p_addr;
    u_ex3_erat_q   : ex3_erat_q   (30 to 35) <= not( ex3_erat_q_b  (30 to 35)); --7p5 HOP OVER dir 45
    u_ex3_erat_i1  : ex3_erat_i1_b (0 to 35) <= not( ex3_erat_q    (0 to 35) ); --7p5 HOP OVER dir 23 , hop over dir latches
    u_ex3_erat_i2  : ex3_erat_i2   (0 to 35) <= not( ex3_erat_i1_b (0 to 35) ); --7p5 drive compare plus terminator
    u_ex3_erat_i3  : ex3_erat_i3_b (0 to 35) <= not( ex3_erat_i2   (0 to 35) ); --2   terminator
    u_ex3_erat_i4  : ex3_erat_i4   (0 to 35) <= not( ex3_erat_i3_b (0 to 35) ); --4   hop to final comp <VERTICAL ESCAPE>
    u_ex3_erat_i5  : ex3_erat_i5_b (0 to 35) <= not( ex3_erat_i4   (0 to 35) ); --4   drive 2 compares
    u_ex3_erat_i6  : ex3_erat_i6   (0 to 35) <= not( ex3_erat_i5_b (0 to 35) ); --4   output
                      ex3_p_addr_o(22 to 57) <=       ex3_erat_i6  (0 to 35)  ; --output-- just a rename

    ld_ex7_recov_b <= not( ld_ex7_recov );

    u_ex3_lmq_wd0  : ex3_lmq_wd0_b(0 to 35) <= not( ex3_erat_i4       (0 to 35) and (0 to 35=> ld_ex7_recov_b) ) ; --1
    u_ex3_lmq_wd1  : ex3_lmq_wd1_b(0 to 35) <= not( ex7_ld_recov_addr(22 to 57) and (0 to 35=> ld_ex7_recov  ) ) ; --1
    u_ex3_lmq_wd   : ex3_lmq_wd   (0 to 35) <= not( ex3_lmq_wd0_b(0 to 35) and ex3_lmq_wd1_b(0 to 35) ) ; --2
    u_ex3_lmq_wdi  : ex3_lmq_wd_b (0 to 35) <= not( ex3_lmq_wd(0 to 35) ) ; --4
    u_ex3_erat_din : ex3_erat_din (0 to 35) <= not( ex3_lmq_wd_b(0 to 35) ); --6   drive 8  regs in queue



   -- also need to drive 8 latch datas

          -- 0/1 4/5 are above
          -- 2/3 6/7 are below        -- ltches 0123 4567  (4567 have extra distance)

    u_dir0_q:  dir0_q    (0 to 30) <= not( dir0_q_b    (0 to 30) );--4
    u_dir1_q:  dir1_q    (0 to 30) <= not( dir1_q_b    (0 to 30) );--4
    u_dir2_q:  dir2_q    (0 to 30) <= not( dir2_q_b    (0 to 30) );--4
    u_dir3_q:  dir3_q    (0 to 30) <= not( dir3_q_b    (0 to 30) );--4

    u_dir4_q0: dir4_q0   (0 to 30) <= not( dir4_q_b    (0 to 30) );--4
    u_dir5_q0: dir5_q0   (0 to 30) <= not( dir5_q_b    (0 to 30) );--4
    u_dir6_q0: dir6_q0   (0 to 30) <= not( dir6_q_b    (0 to 30) );--4
    u_dir7_q0: dir7_q0   (0 to 30) <= not( dir7_q_b    (0 to 30) );--4

    u_dir4_q1: dir4_q1_b (0 to 30) <= not( dir4_q0     (0 to 30) );--6
    u_dir5_q1: dir5_q1_b (0 to 30) <= not( dir5_q0     (0 to 30) );--6
    u_dir6_q1: dir6_q1_b (0 to 30) <= not( dir6_q0     (0 to 30) );--6
    u_dir7_q1: dir7_q1_b (0 to 30) <= not( dir7_q0     (0 to 30) );--6

    u_dir4_q:  dir4_q    (0 to 30) <= not( dir4_q1_b   (0 to 30) );--4
    u_dir5_q:  dir5_q    (0 to 30) <= not( dir5_q1_b   (0 to 30) );--4
    u_dir6_q:  dir6_q    (0 to 30) <= not( dir6_q1_b   (0 to 30) );--4
    u_dir7_q:  dir7_q    (0 to 30) <= not( dir7_q1_b   (0 to 30) );--4


-- ################################################################
-- # directory compares against erat
-- ################################################################

 dir0cmp: entity work.xuq_lsu_cmp_cmp31(xuq_lsu_cmp_cmp31) port map(       
       d0(0 to 30)   =>  ex3_erat_i2(0 to 30)    ,--i--xuq_lsu_cmp_cmp31(dir0cmp)
       d1(0 to 30)   =>  dir0_q     (0 to 30)    ,--i--xuq_lsu_cmp_cmp31(dir0cmp)
       eq            =>  dir_eq(0)              );--o--xuq_lsu_cmp_cmp31(dir0cmp)

 dir1cmp: entity work.xuq_lsu_cmp_cmp31(xuq_lsu_cmp_cmp31) port map(       
       d0(0 to 30)   =>  ex3_erat_i2(0 to 30)    ,--i--xuq_lsu_cmp_cmp31(dir1cmp)
       d1(0 to 30)   =>  dir1_q     (0 to 30)    ,--i--xuq_lsu_cmp_cmp31(dir1cmp)
       eq            =>  dir_eq(1)              );--o--xuq_lsu_cmp_cmp31(dir1cmp)

 dir2cmp: entity work.xuq_lsu_cmp_cmp31(xuq_lsu_cmp_cmp31) port map(       
       d0(0 to 30)   =>  ex3_erat_i2(0 to 30)    ,--i--xuq_lsu_cmp_cmp31(dir2cmp)
       d1(0 to 30)   =>  dir2_q     (0 to 30)    ,--i--xuq_lsu_cmp_cmp31(dir2cmp)
       eq            =>  dir_eq(2)              );--o--xuq_lsu_cmp_cmp31(dir2cmp)

 dir3cmp: entity work.xuq_lsu_cmp_cmp31(xuq_lsu_cmp_cmp31) port map(       
       d0(0 to 30)   =>  ex3_erat_i2(0 to 30)    ,--i--xuq_lsu_cmp_cmp31(dir3cmp)
       d1(0 to 30)   =>  dir3_q     (0 to 30)    ,--i--xuq_lsu_cmp_cmp31(dir3cmp)
       eq            =>  dir_eq(3)              );--o--xuq_lsu_cmp_cmp31(dir3cmp)

 dir4cmp: entity work.xuq_lsu_cmp_cmp31(xuq_lsu_cmp_cmp31) port map(       
       d0(0 to 30)   =>  ex3_erat_i2(0 to 30)    ,--i--xuq_lsu_cmp_cmp31(dir4cmp)
       d1(0 to 30)   =>  dir4_q     (0 to 30)    ,--i--xuq_lsu_cmp_cmp31(dir4cmp)
       eq            =>  dir_eq(4)              );--o--xuq_lsu_cmp_cmp31(dir4cmp)

 dir5cmp: entity work.xuq_lsu_cmp_cmp31(xuq_lsu_cmp_cmp31) port map(       
       d0(0 to 30)   =>  ex3_erat_i2(0 to 30)    ,--i--xuq_lsu_cmp_cmp31(dir5cmp)
       d1(0 to 30)   =>  dir5_q     (0 to 30)    ,--i--xuq_lsu_cmp_cmp31(dir5cmp)
       eq            =>  dir_eq(5)              );--o--xuq_lsu_cmp_cmp31(dir5cmp)

 dir6cmp: entity work.xuq_lsu_cmp_cmp31(xuq_lsu_cmp_cmp31) port map(       
       d0(0 to 30)   =>  ex3_erat_i2(0 to 30)    ,--i--xuq_lsu_cmp_cmp31(dir6cmp)
       d1(0 to 30)   =>  dir6_q     (0 to 30)    ,--i--xuq_lsu_cmp_cmp31(dir6cmp)
       eq            =>  dir_eq(6)              );--o--xuq_lsu_cmp_cmp31(dir6cmp)

 dir7cmp: entity work.xuq_lsu_cmp_cmp31(xuq_lsu_cmp_cmp31) port map(       
       d0(0 to 30)   =>  ex3_erat_i2(0 to 30)    ,--i--xuq_lsu_cmp_cmp31(dir7cmp)
       d1(0 to 30)   =>  dir7_q     (0 to 30)    ,--i--xuq_lsu_cmp_cmp31(dir7cmp)
       eq            =>  dir_eq(7)              );--o--xuq_lsu_cmp_cmp31(dir7cmp)
   

ex3_way_cmp_a <= dir_eq(0); 
ex3_way_cmp_b <= dir_eq(1); 
ex3_way_cmp_c <= dir_eq(2); 
ex3_way_cmp_d <= dir_eq(3); 
ex3_way_cmp_e <= dir_eq(4); 
ex3_way_cmp_f <= dir_eq(5); 
ex3_way_cmp_g <= dir_eq(6); 
ex3_way_cmp_h <= dir_eq(7); 

ex3_wayA_tag <= not dir0_q_b;
ex3_wayB_tag <= not dir1_q_b;
ex3_wayC_tag <= not dir2_q_b;
ex3_wayD_tag <= not dir3_q_b;
ex3_wayE_tag <= not dir4_q_b;
ex3_wayF_tag <= not dir5_q_b;
ex3_wayG_tag <= not dir6_q_b;
ex3_wayH_tag <= not dir7_q_b;

-- ################################################################
-- # ldq compares against erat
-- ################################################################

 lmq0cmp: entity work.xuq_lsu_cmp_cmp36e(xuq_lsu_cmp_cmp36e) port map(       
       enable_lsb     =>  enable_lsb_lmq          ,--i--xuq_lsu_cmp_cmp36e(lmq0cmp)
       d0(0 to 35)    =>  ex3_erat_i2(0 to 35)    ,--i--xuq_lsu_cmp_cmp36e(lmq0cmp)
       d1(0 to 35)    =>  lmq0_iy    (0 to 35)    ,--i--xuq_lsu_cmp_cmp36e(lmq0cmp)
       eq             =>  lmq_eq(0)              );--o--xuq_lsu_cmp_cmp36e(lmq0cmp)

 lmq1cmp: entity work.xuq_lsu_cmp_cmp36e(xuq_lsu_cmp_cmp36e) port map(       
       enable_lsb     =>  enable_lsb_lmq          ,--i--xuq_lsu_cmp_cmp36e(lmq1cmp)
       d0(0 to 35)    =>  ex3_erat_i2(0 to 35)    ,--i--xuq_lsu_cmp_cmp36e(lmq1cmp)
       d1(0 to 35)    =>  lmq1_iy    (0 to 35)    ,--i--xuq_lsu_cmp_cmp36e(lmq1cmp)
       eq             =>  lmq_eq(1)              );--o--xuq_lsu_cmp_cmp36e(lmq1cmp)

 lmq2cmp: entity work.xuq_lsu_cmp_cmp36e(xuq_lsu_cmp_cmp36e) port map(       
       enable_lsb     =>  enable_lsb_lmq          ,--i--xuq_lsu_cmp_cmp36e(lmq2cmp)
       d0(0 to 35)    =>  ex3_erat_i2(0 to 35)    ,--i--xuq_lsu_cmp_cmp36e(lmq2cmp)
       d1(0 to 35)    =>  lmq2_iy    (0 to 35)    ,--i--xuq_lsu_cmp_cmp36e(lmq2cmp)
       eq             =>  lmq_eq(2)              );--o--xuq_lsu_cmp_cmp36e(lmq2cmp)

 lmq3cmp: entity work.xuq_lsu_cmp_cmp36e(xuq_lsu_cmp_cmp36e) port map(       
       enable_lsb     =>  enable_lsb_lmq          ,--i--xuq_lsu_cmp_cmp36e(lmq3cmp)
       d0(0 to 35)    =>  ex3_erat_i2(0 to 35)    ,--i--xuq_lsu_cmp_cmp36e(lmq3cmp)
       d1(0 to 35)    =>  lmq3_iy    (0 to 35)    ,--i--xuq_lsu_cmp_cmp36e(lmq3cmp)
       eq             =>  lmq_eq(3)              );--o--xuq_lsu_cmp_cmp36e(lmq3cmp)

 lmq4cmp: entity work.xuq_lsu_cmp_cmp36e(xuq_lsu_cmp_cmp36e) port map(       
       enable_lsb     =>  enable_lsb_lmq          ,--i--xuq_lsu_cmp_cmp36e(lmq4cmp)
       d0(0 to 35)    =>  ex3_erat_i2(0 to 35)    ,--i--xuq_lsu_cmp_cmp36e(lmq4cmp)
       d1(0 to 35)    =>  lmq4_iy    (0 to 35)    ,--i--xuq_lsu_cmp_cmp36e(lmq4cmp)
       eq             =>  lmq_eq(4)              );--o--xuq_lsu_cmp_cmp36e(lmq4cmp)

 lmq5cmp: entity work.xuq_lsu_cmp_cmp36e(xuq_lsu_cmp_cmp36e) port map(       
       enable_lsb     =>  enable_lsb_lmq          ,--i--xuq_lsu_cmp_cmp36e(lmq5cmp)
       d0(0 to 35)    =>  ex3_erat_i2(0 to 35)    ,--i--xuq_lsu_cmp_cmp36e(lmq5cmp)
       d1(0 to 35)    =>  lmq5_iy    (0 to 35)    ,--i--xuq_lsu_cmp_cmp36e(lmq5cmp)
       eq             =>  lmq_eq(5)              );--o--xuq_lsu_cmp_cmp36e(lmq5cmp)

 lmq6cmp: entity work.xuq_lsu_cmp_cmp36e(xuq_lsu_cmp_cmp36e) port map(       
       enable_lsb     =>  enable_lsb_lmq          ,--i--xuq_lsu_cmp_cmp36e(lmq6cmp)
       d0(0 to 35)    =>  ex3_erat_i2(0 to 35)    ,--i--xuq_lsu_cmp_cmp36e(lmq6cmp)
       d1(0 to 35)    =>  lmq6_iy    (0 to 35)    ,--i--xuq_lsu_cmp_cmp36e(lmq6cmp)
       eq             =>  lmq_eq(6)              );--o--xuq_lsu_cmp_cmp36e(lmq6cmp)

 lmq7cmp: entity work.xuq_lsu_cmp_cmp36e(xuq_lsu_cmp_cmp36e) port map(       
       enable_lsb     =>  enable_lsb_lmq          ,--i--xuq_lsu_cmp_cmp36e(lmq7cmp)
       d0(0 to 35)    =>  ex3_erat_i2(0 to 35)    ,--i--xuq_lsu_cmp_cmp36e(lmq7cmp)
       d1(0 to 35)    =>  lmq7_iy    (0 to 35)    ,--i--xuq_lsu_cmp_cmp36e(lmq7cmp)
       eq             =>  lmq_eq(7)              );--o--xuq_lsu_cmp_cmp36e(lmq7cmp)

 u_lmq_cmp_cp:  lmq_eq_b(0 to 7)  <= not( lmq_eq  (0 to 7) ); --ungated compare
                ldq_match(0 to 7) <= not( lmq_eq_b(0 to 7) ); --output-- --unmapped, match output phase, but allow synth to optimize out


-- ###############################################################
-- # or the compares together
-- ###############################################################

  dir_comp_val(0) <=  ex3_cClass_upd_way_a ;
  dir_comp_val(1) <=  ex3_cClass_upd_way_b  ;
  dir_comp_val(2) <=  ex3_cClass_upd_way_c  ;
  dir_comp_val(3) <=  ex3_cClass_upd_way_d  ;
  dir_comp_val(4) <=  ex3_cClass_upd_way_e  ;
  dir_comp_val(5) <=  ex3_cClass_upd_way_f  ;
  dir_comp_val(6) <=  ex3_cClass_upd_way_g  ;
  dir_comp_val(7) <=  ex3_cClass_upd_way_h  ;


   u_cmpe_36: cmpe_36_b(0 to 7) <= not( lmq_eq(0 to 7) and ldq_comp_val(0 to 7) ) ;

   u_o2_36_0: o2_36(0) <= not( cmpe_36_b(0) and cmpe_36_b(1) );
   u_o2_36_1: o2_36(1) <= not( cmpe_36_b(2) and cmpe_36_b(3) );
   u_o2_36_2: o2_36(2) <= not( cmpe_36_b(4) and cmpe_36_b(5) );
   u_o2_36_3: o2_36(3) <= not( cmpe_36_b(6) and cmpe_36_b(7) );

   u_o4_36_0: o4_36_b(0) <= not(  o2_36(0) or  o2_36(1) );
   u_o4_36_1: o4_36_b(1) <= not(  o2_36(2) or  o2_36(3) );

   u_o8_36:   o8_36      <= not( o4_36_b(0) and o4_36_b(1) );


   u_cmpe_30: cmpe_30_b(0 to 7) <= not( dir_eq(0 to 7) and dir_comp_val(0 to 7) ) ;

   u_o2_30_0: o2_30(0) <= not( cmpe_30_b(0) and cmpe_30_b(1) );
   u_o2_30_1: o2_30(1) <= not( cmpe_30_b(2) and cmpe_30_b(3) );
   u_o2_30_2: o2_30(2) <= not( cmpe_30_b(4) and cmpe_30_b(5) );
   u_o2_30_3: o2_30(3) <= not( cmpe_30_b(6) and cmpe_30_b(7) );

   u_o4_30_0: o4_30_b(0) <= not(  o2_30(0) or  o2_30(1) );
   u_o4_30_1: o4_30_b(1) <= not(  o2_30(2) or  o2_30(3) );

   u_o8_30:   o8_30      <= not( o4_30_b(0) and o4_30_b(1) );


   u_o16i:  hit_b     <= not( o8_36 );
   u_o16:   hit       <= not( hit_b ); -- 1
   u_hit_1: hit_1_b   <= not( hit     ); 
   u_hit_2: hit_2     <= not( hit_1_b ); 
   u_hit_3: hit_3_b   <= not( hit_2   );
   u_hit_4: cmp_flush <= not( hit_3_b ); --output--


   u_o8_dir: dir_eq_v_or_b <= not( o8_30 );--output--
   u_o8_ldq: ldq_fnd_b     <= not( o8_36 );--output--




-- ################################################################
-- # 2 miscellaneous compares against erat (above stack)
-- ################################################################

       smq_addr_b(0 to 35) <= not( s_m_queue0_addr  (22 to 57) );
       sto_addr_b(0 to 35) <= not( ex4_st_entry_addr(22 to 57) );

 smq_cmp: entity work.xuq_lsu_cmp_cmp36e(xuq_lsu_cmp_cmp36e) port map(       
       enable_lsb     =>  enable_lsb_oth            ,--i--xuq_lsu_cmp_cmp36e(smq_cmp)
       d0(0 to 35)    =>  ex3_erat_i5_b(0 to 35)    ,--i--xuq_lsu_cmp_cmp36e(smq_cmp)
       d1(0 to 35)    =>  smq_addr_b   (0 to 35)    ,--i--xuq_lsu_cmp_cmp36e(smq_cmp)
       eq             =>  smq_eq                   );--o--xuq_lsu_cmp_cmp36e(smq_cmp)

 sto_cmp: entity work.xuq_lsu_cmp_cmp36e(xuq_lsu_cmp_cmp36e) port map(       
       enable_lsb     =>  enable_lsb_oth            ,--i--xuq_lsu_cmp_cmp36e(sto_cmp)
       d0(0 to 35)    =>  ex3_erat_i5_b(0 to 35)    ,--i--xuq_lsu_cmp_cmp36e(sto_cmp)
       d1(0 to 35)    =>  sto_addr_b   (0 to 35)    ,--i--xuq_lsu_cmp_cmp36e(sto_cmp)
       eq             =>  sto_eq                   );--o--xuq_lsu_cmp_cmp36e(sto_cmp)


       u_smq_eqv: smq_eqv_b <= not( smq_eq   and st_entry0_val );
       u_sto_eqv: sto_eqv_b <= not( sto_eq   and ex4_st_val    );

       ex3addr_hit_stq   <= not( smq_eqv_b ); --output--  let synth optimize out
       ex3addr_hit_ex4st <= not( sto_eqv_b ); --output--  let synth optimize out




-- ################################################################
-- # muxes in front of load miss queue , and repower
-- ################################################################

    l_q_wrt_en_b(0 to 7) <= not l_q_wrt_en(0 to 7);

    u_lmq0_q:    lmq0_q   (0 to 35) <= not( lmq0_q_b(0 to 35)  ); --2
    u_lmq1_q:    lmq1_q   (0 to 35) <= not( lmq1_q_b(0 to 35)  ); --2
    u_lmq2_q:    lmq2_q   (0 to 35) <= not( lmq2_q_b(0 to 35)  ); --2
    u_lmq3_q:    lmq3_q   (0 to 35) <= not( lmq3_q_b(0 to 35)  ); --2
    u_lmq4_q:    lmq4_q   (0 to 35) <= not( lmq4_q_b(0 to 35)  ); --2
    u_lmq5_q:    lmq5_q   (0 to 35) <= not( lmq5_q_b(0 to 35)  ); --2
    u_lmq6_q:    lmq6_q   (0 to 35) <= not( lmq6_q_b(0 to 35)  ); --2
    u_lmq7_q:    lmq7_q   (0 to 35) <= not( lmq7_q_b(0 to 35)  ); --2

    u_lmq0_i0:   lmq0_i0_b(0 to 35) <= not( lmq0_q   (0 to 35)  ); --4
    u_lmq1_i0:   lmq1_i0_b(0 to 35) <= not( lmq1_q   (0 to 35)  ); --4
    u_lmq2_i0:   lmq2_i0_b(0 to 35) <= not( lmq2_q   (0 to 35)  ); --4
    u_lmq3_i0:   lmq3_i0_b(0 to 35) <= not( lmq3_q   (0 to 35)  ); --4
    u_lmq4_i0:   lmq4_i0_b(0 to 35) <= not( lmq4_q   (0 to 35)  ); --4
    u_lmq5_i0:   lmq5_i0_b(0 to 35) <= not( lmq5_q   (0 to 35)  ); --4
    u_lmq6_i0:   lmq6_i0_b(0 to 35) <= not( lmq6_q   (0 to 35)  ); --4
    u_lmq7_i0:   lmq7_i0_b(0 to 35) <= not( lmq7_q   (0 to 35)  ); --4

    u_lmq0_iy:   lmq0_iy  (0 to 35) <= not( lmq0_i0_b(0 to 35)  ); --4 drives to left  (ERAT compares )
    u_lmq1_iy:   lmq1_iy  (0 to 35) <= not( lmq1_i0_b(0 to 35)  ); --4 drives to left  (ERAT compares )
    u_lmq2_iy:   lmq2_iy  (0 to 35) <= not( lmq2_i0_b(0 to 35)  ); --4 drives to left  (ERAT compares )
    u_lmq3_iy:   lmq3_iy  (0 to 35) <= not( lmq3_i0_b(0 to 35)  ); --4 drives to left  (ERAT compares )
    u_lmq4_iy:   lmq4_iy  (0 to 35) <= not( lmq4_i0_b(0 to 35)  ); --4 drives to left  (ERAT compares )
    u_lmq5_iy:   lmq5_iy  (0 to 35) <= not( lmq5_i0_b(0 to 35)  ); --4 drives to left  (ERAT compares )
    u_lmq6_iy:   lmq6_iy  (0 to 35) <= not( lmq6_i0_b(0 to 35)  ); --4 drives to left  (ERAT compares )
    u_lmq7_iy:   lmq7_iy  (0 to 35) <= not( lmq7_i0_b(0 to 35)  ); --4 drives to left  (ERAT compares )

    u_lmq0_ix:   lmq0_ix  (0 to 35) <= not( lmq0_i0_b(0 to 35)  ); --4 drives to right (other compares)
    u_lmq1_ix:   lmq1_ix  (0 to 35) <= not( lmq1_i0_b(0 to 35)  ); --4 drives to right (other compares)
    u_lmq2_ix:   lmq2_ix  (0 to 35) <= not( lmq2_i0_b(0 to 35)  ); --4 drives to right (other compares)
    u_lmq3_ix:   lmq3_ix  (0 to 35) <= not( lmq3_i0_b(0 to 35)  ); --4 drives to right (other compares)
    u_lmq4_ix:   lmq4_ix  (0 to 35) <= not( lmq4_i0_b(0 to 35)  ); --4 drives to right (other compares)
    u_lmq5_ix:   lmq5_ix  (0 to 35) <= not( lmq5_i0_b(0 to 35)  ); --4 drives to right (other compares)
    u_lmq6_ix:   lmq6_ix  (0 to 35) <= not( lmq6_i0_b(0 to 35)  ); --4 drives to right (other compares)
    u_lmq7_ix:   lmq7_ix  (0 to 35) <= not( lmq7_i0_b(0 to 35)  ); --4 drives to right (other compares)

    u_lmq0_ix1:   lmq0_ix1_b(0 to 35) <= not( lmq0_ix  (0 to 35)  ); --1 buffer off
    u_lmq1_ix1:   lmq1_ix1_b(0 to 35) <= not( lmq1_ix  (0 to 35)  ); --1
    u_lmq2_ix1:   lmq2_ix1_b(0 to 35) <= not( lmq2_ix  (0 to 35)  ); --1
    u_lmq3_ix1:   lmq3_ix1_b(0 to 35) <= not( lmq3_ix  (0 to 35)  ); --1
    u_lmq4_ix1:   lmq4_ix1_b(0 to 35) <= not( lmq4_ix  (0 to 35)  ); --1
    u_lmq5_ix1:   lmq5_ix1_b(0 to 35) <= not( lmq5_ix  (0 to 35)  ); --1
    u_lmq6_ix1:   lmq6_ix1_b(0 to 35) <= not( lmq6_ix  (0 to 35)  ); --1
    u_lmq7_ix1:   lmq7_ix1_b(0 to 35) <= not( lmq7_ix  (0 to 35)  ); --1

    u_lmq0_ix2:   lmq0_ix2  (0 to 35) <= not( lmq0_ix1_b(0 to 35)  ); --2 mux input
    u_lmq1_ix2:   lmq1_ix2  (0 to 35) <= not( lmq1_ix1_b(0 to 35)  ); --2
    u_lmq2_ix2:   lmq2_ix2  (0 to 35) <= not( lmq2_ix1_b(0 to 35)  ); --2
    u_lmq3_ix2:   lmq3_ix2  (0 to 35) <= not( lmq3_ix1_b(0 to 35)  ); --2
    u_lmq4_ix2:   lmq4_ix2  (0 to 35) <= not( lmq4_ix1_b(0 to 35)  ); --2
    u_lmq5_ix2:   lmq5_ix2  (0 to 35) <= not( lmq5_ix1_b(0 to 35)  ); --2
    u_lmq6_ix2:   lmq6_ix2  (0 to 35) <= not( lmq6_ix1_b(0 to 35)  ); --2
    u_lmq7_ix2:   lmq7_ix2  (0 to 35) <= not( lmq7_ix1_b(0 to 35)  ); --2


    u_lmq0_new: lmq0_new_b(0 to 35) <= not( ex3_erat_din(0 to 35)  and           (0 to 35=> l_q_wrt_en  (0) ) ); -- 0p5
    u_lmq1_new: lmq1_new_b(0 to 35) <= not( ex3_erat_din(0 to 35)  and           (0 to 35=> l_q_wrt_en  (1) ) ); -- 0p5
    u_lmq2_new: lmq2_new_b(0 to 35) <= not( ex3_erat_din(0 to 35)  and           (0 to 35=> l_q_wrt_en  (2) ) ); -- 0p5
    u_lmq3_new: lmq3_new_b(0 to 35) <= not( ex3_erat_din(0 to 35)  and           (0 to 35=> l_q_wrt_en  (3) ) ); -- 0p5
    u_lmq4_new: lmq4_new_b(0 to 35) <= not( ex3_erat_din(0 to 35)  and           (0 to 35=> l_q_wrt_en  (4) ) ); -- 0p5
    u_lmq5_new: lmq5_new_b(0 to 35) <= not( ex3_erat_din(0 to 35)  and           (0 to 35=> l_q_wrt_en  (5) ) ); -- 0p5
    u_lmq6_new: lmq6_new_b(0 to 35) <= not( ex3_erat_din(0 to 35)  and           (0 to 35=> l_q_wrt_en  (6) ) ); -- 0p5
    u_lmq7_new: lmq7_new_b(0 to 35) <= not( ex3_erat_din(0 to 35)  and           (0 to 35=> l_q_wrt_en  (7) ) ); -- 0p5

    u_lmq0_fbk: lmq0_fbk_b(0 to 35) <= not( lmq0_ix     (0 to 35)  and           (0 to 35=> l_q_wrt_en_b(0) ) ); -- 0p5
    u_lmq1_fbk: lmq1_fbk_b(0 to 35) <= not( lmq1_ix     (0 to 35)  and           (0 to 35=> l_q_wrt_en_b(1) ) ); -- 0p5
    u_lmq2_fbk: lmq2_fbk_b(0 to 35) <= not( lmq2_ix     (0 to 35)  and           (0 to 35=> l_q_wrt_en_b(2) ) ); -- 0p5
    u_lmq3_fbk: lmq3_fbk_b(0 to 35) <= not( lmq3_ix     (0 to 35)  and           (0 to 35=> l_q_wrt_en_b(3) ) ); -- 0p5
    u_lmq4_fbk: lmq4_fbk_b(0 to 35) <= not( lmq4_ix     (0 to 35)  and           (0 to 35=> l_q_wrt_en_b(4) ) ); -- 0p5
    u_lmq5_fbk: lmq5_fbk_b(0 to 35) <= not( lmq5_ix     (0 to 35)  and           (0 to 35=> l_q_wrt_en_b(5) ) ); -- 0p5
    u_lmq6_fbk: lmq6_fbk_b(0 to 35) <= not( lmq6_ix     (0 to 35)  and           (0 to 35=> l_q_wrt_en_b(6) ) ); -- 0p5
    u_lmq7_fbk: lmq7_fbk_b(0 to 35) <= not( lmq7_ix     (0 to 35)  and           (0 to 35=> l_q_wrt_en_b(7) ) ); -- 0p5

    u_lmq0_din: lmq0_din  (0 to 35) <= not( lmq0_new_b  (0 to 35)  and lmq0_fbk_b(0 to 35)                    ); -- 1
    u_lmq1_din: lmq1_din  (0 to 35) <= not( lmq1_new_b  (0 to 35)  and lmq1_fbk_b(0 to 35)                    ); -- 1
    u_lmq2_din: lmq2_din  (0 to 35) <= not( lmq2_new_b  (0 to 35)  and lmq2_fbk_b(0 to 35)                    ); -- 1
    u_lmq3_din: lmq3_din  (0 to 35) <= not( lmq3_new_b  (0 to 35)  and lmq3_fbk_b(0 to 35)                    ); -- 1
    u_lmq4_din: lmq4_din  (0 to 35) <= not( lmq4_new_b  (0 to 35)  and lmq4_fbk_b(0 to 35)                    ); -- 1
    u_lmq5_din: lmq5_din  (0 to 35) <= not( lmq5_new_b  (0 to 35)  and lmq5_fbk_b(0 to 35)                    ); -- 1
    u_lmq6_din: lmq6_din  (0 to 35) <= not( lmq6_new_b  (0 to 35)  and lmq6_fbk_b(0 to 35)                    ); -- 1
    u_lmq7_din: lmq7_din  (0 to 35) <= not( lmq7_new_b  (0 to 35)  and lmq7_fbk_b(0 to 35)                    ); -- 1




-- ################################################################
-- # 8 compares with the non-ERAT address
-- ################################################################


               binv_addr_b(0 to 35) <= not( back_inv_addr(22 to 57) ); -- not mapping
 u_binv_addr:  binv_addr  (0 to 35) <= not( binv_addr_b(0 to 35)    ); -- need to place

 binv0cmp: entity work.xuq_lsu_cmp_cmp36e(xuq_lsu_cmp_cmp36e) port map(       
       enable_lsb    =>  enable_lsb_bi           ,--i--xuq_lsu_cmp_cmp36e(binv0cmp)
       d0(0 to 35)   =>  binv_addr  (0 to 35)    ,--i--xuq_lsu_cmp_cmp36e(binv0cmp)
       d1(0 to 35)   =>  lmq0_ix    (0 to 35)    ,--i--xuq_lsu_cmp_cmp36e(binv0cmp)
       eq            =>  binv_eq(0)             );--o--xuq_lsu_cmp_cmp36e(binv0cmp)

 binv1cmp: entity work.xuq_lsu_cmp_cmp36e(xuq_lsu_cmp_cmp36e) port map(       
       enable_lsb    =>  enable_lsb_bi           ,--i--xuq_lsu_cmp_cmp36e(binv1cmp)
       d0(0 to 35)   =>  binv_addr  (0 to 35)    ,--i--xuq_lsu_cmp_cmp36e(binv1cmp)
       d1(0 to 35)   =>  lmq1_ix    (0 to 35)    ,--i--xuq_lsu_cmp_cmp36e(binv1cmp)
       eq            =>  binv_eq(1)             );--o--xuq_lsu_cmp_cmp36e(binv1cmp)

 binv2cmp: entity work.xuq_lsu_cmp_cmp36e(xuq_lsu_cmp_cmp36e) port map(       
       enable_lsb    =>  enable_lsb_bi           ,--i--xuq_lsu_cmp_cmp36e(binv2cmp)
       d0(0 to 35)   =>  binv_addr  (0 to 35)    ,--i--xuq_lsu_cmp_cmp36e(binv2cmp)
       d1(0 to 35)   =>  lmq2_ix    (0 to 35)    ,--i--xuq_lsu_cmp_cmp36e(binv2cmp)
       eq            =>  binv_eq(2)             );--o--xuq_lsu_cmp_cmp36e(binv2cmp)

 binv3cmp: entity work.xuq_lsu_cmp_cmp36e(xuq_lsu_cmp_cmp36e) port map(       
       enable_lsb    =>  enable_lsb_bi           ,--i--xuq_lsu_cmp_cmp36e(binv3cmp)
       d0(0 to 35)   =>  binv_addr  (0 to 35)    ,--i--xuq_lsu_cmp_cmp36e(binv3cmp)
       d1(0 to 35)   =>  lmq3_ix    (0 to 35)    ,--i--xuq_lsu_cmp_cmp36e(binv3cmp)
       eq            =>  binv_eq(3)             );--o--xuq_lsu_cmp_cmp36e(binv3cmp)

 binv4cmp: entity work.xuq_lsu_cmp_cmp36e(xuq_lsu_cmp_cmp36e) port map(       
       enable_lsb    =>  enable_lsb_bi           ,--i--xuq_lsu_cmp_cmp36e(binv4cmp)
       d0(0 to 35)   =>  binv_addr  (0 to 35)    ,--i--xuq_lsu_cmp_cmp36e(binv4cmp)
       d1(0 to 35)   =>  lmq4_ix    (0 to 35)    ,--i--xuq_lsu_cmp_cmp36e(binv4cmp)
       eq            =>  binv_eq(4)             );--o--xuq_lsu_cmp_cmp36e(binv4cmp)

 binv5cmp: entity work.xuq_lsu_cmp_cmp36e(xuq_lsu_cmp_cmp36e) port map(       
       enable_lsb    =>  enable_lsb_bi           ,--i--xuq_lsu_cmp_cmp36e(binv5cmp)
       d0(0 to 35)   =>  binv_addr  (0 to 35)    ,--i--xuq_lsu_cmp_cmp36e(binv5cmp)
       d1(0 to 35)   =>  lmq5_ix    (0 to 35)    ,--i--xuq_lsu_cmp_cmp36e(binv5cmp)
       eq            =>  binv_eq(5)             );--o--xuq_lsu_cmp_cmp36e(binv5cmp)

 binv6cmp: entity work.xuq_lsu_cmp_cmp36e(xuq_lsu_cmp_cmp36e) port map(       
       enable_lsb    =>  enable_lsb_bi           ,--i--xuq_lsu_cmp_cmp36e(binv6cmp)
       d0(0 to 35)   =>  binv_addr  (0 to 35)    ,--i--xuq_lsu_cmp_cmp36e(binv6cmp)
       d1(0 to 35)   =>  lmq6_ix    (0 to 35)    ,--i--xuq_lsu_cmp_cmp36e(binv6cmp)
       eq            =>  binv_eq(6)             );--o--xuq_lsu_cmp_cmp36e(binv6cmp)

 binv7cmp: entity work.xuq_lsu_cmp_cmp36e(xuq_lsu_cmp_cmp36e) port map(       
       enable_lsb    =>  enable_lsb_bi           ,--i--xuq_lsu_cmp_cmp36e(binv7cmp)
       d0(0 to 35)   =>  binv_addr  (0 to 35)    ,--i--xuq_lsu_cmp_cmp36e(binv7cmp)
       d1(0 to 35)   =>  lmq7_ix    (0 to 35)    ,--i--xuq_lsu_cmp_cmp36e(binv7cmp)
       eq            =>  binv_eq(7)             );--o--xuq_lsu_cmp_cmp36e(binv7cmp)


 u_binv_eqv: binv_eqv_b       (0 to 7) <= not( binv_eq(0 to 7) and back_inv_cmp_val(0 to 7) ); -- gated compare
             back_inv_addr_hit(0 to 7) <= not( binv_eqv_b(0 to 7) ); --output-- --unmapped, match output phase, but allow synth to optimize out


-- ################################################################
-- # output mux 1
-- ################################################################


   u_mux1_lv1_01: mux1_lv1_01_b(0 to 35) <= not( ( lmq0_ix2(0 to 35) and (0 to 35 => rel_tag_1hot(0) ) ) or
                                                 ( lmq1_ix2(0 to 35) and (0 to 35 => rel_tag_1hot(1) ) )  );
   u_mux1_lv1_23: mux1_lv1_23_b(0 to 35) <= not( ( lmq2_ix2(0 to 35) and (0 to 35 => rel_tag_1hot(2) ) ) or
                                                 ( lmq3_ix2(0 to 35) and (0 to 35 => rel_tag_1hot(3) ) )  );
   u_mux1_lv1_45: mux1_lv1_45_b(0 to 35) <= not( ( lmq4_ix2(0 to 35) and (0 to 35 => rel_tag_1hot(4) ) ) or
                                                 ( lmq5_ix2(0 to 35) and (0 to 35 => rel_tag_1hot(5) ) )  );
   u_mux1_lv1_67: mux1_lv1_67_b(0 to 35) <= not( ( lmq6_ix2(0 to 35) and (0 to 35 => rel_tag_1hot(6) ) ) or
                                                 ( lmq7_ix2(0 to 35) and (0 to 35 => rel_tag_1hot(7) ) )  );

   u_mux1_lv2_03: mux1_lv2_03(0 to 35) <= not( mux1_lv1_01_b(0 to 35) and mux1_lv1_23_b(0 to 35) );
   u_mux1_lv2_47: mux1_lv2_47(0 to 35) <= not( mux1_lv1_45_b(0 to 35) and mux1_lv1_67_b(0 to 35) );

   u_mux1_lv3_07: mux1_lv3_07_b(0 to 35) <= not( mux1_lv2_03(0 to 35) or mux1_lv2_47(0 to 35) );
    
   rel_addr(22 to 57) <= not mux1_lv3_07_b(0 to 35) ; -- let synth repower --


-- ################################################################
-- # output mux 2
-- ################################################################

   u_mux2_lv1_01: mux2_lv1_01_b(0 to 35) <= not( ( lmq0_ix2(0 to 35) and (0 to 35 => l_q_rd_en(0) ) ) or
                                                 ( lmq1_ix2(0 to 35) and (0 to 35 => l_q_rd_en(1) ) )  );
   u_mux2_lv1_23: mux2_lv1_23_b(0 to 35) <= not( ( lmq2_ix2(0 to 35) and (0 to 35 => l_q_rd_en(2) ) ) or
                                                 ( lmq3_ix2(0 to 35) and (0 to 35 => l_q_rd_en(3) ) )  );
   u_mux2_lv1_45: mux2_lv1_45_b(0 to 35) <= not( ( lmq4_ix2(0 to 35) and (0 to 35 => l_q_rd_en(4) ) ) or
                                                 ( lmq5_ix2(0 to 35) and (0 to 35 => l_q_rd_en(5) ) )  );
   u_mux2_lv1_67: mux2_lv1_67_b(0 to 35) <= not( ( lmq6_ix2(0 to 35) and (0 to 35 => l_q_rd_en(6) ) ) or
                                                 ( lmq7_ix2(0 to 35) and (0 to 35 => l_q_rd_en(7) ) )  );


   u_mux2_lv2_03: mux2_lv2_03(0 to 35) <= not( mux2_lv1_01_b(0 to 35) and mux2_lv1_23_b(0 to 35) );
   u_mux2_lv2_47: mux2_lv2_47(0 to 35) <= not( mux2_lv1_45_b(0 to 35) and mux2_lv1_67_b(0 to 35) );

   u_mux2_lv3_07: mux2_lv3_07_b(0 to 35) <= not( mux2_lv2_03(0 to 35) or mux2_lv2_47(0 to 35) );
    
   l_miss_entry_addr(22 to 57) <= not mux2_lv3_07_b(0 to 35) ; -- let synth repower --


-- ################################################################
-- # output mux 3
-- ################################################################


   u_mux3_lv1_01: mux3_lv1_01_b(0 to 35) <= not( ( lmq0_ix2(0 to 35) and (0 to 35 => ex4_loadmiss_qentry(0) ) ) or
                                                 ( lmq1_ix2(0 to 35) and (0 to 35 => ex4_loadmiss_qentry(1) ) )  );
   u_mux3_lv1_23: mux3_lv1_23_b(0 to 35) <= not( ( lmq2_ix2(0 to 35) and (0 to 35 => ex4_loadmiss_qentry(2) ) ) or
                                                 ( lmq3_ix2(0 to 35) and (0 to 35 => ex4_loadmiss_qentry(3) ) )  );
   u_mux3_lv1_45: mux3_lv1_45_b(0 to 35) <= not( ( lmq4_ix2(0 to 35) and (0 to 35 => ex4_loadmiss_qentry(4) ) ) or
                                                 ( lmq5_ix2(0 to 35) and (0 to 35 => ex4_loadmiss_qentry(5) ) )  );
   u_mux3_lv1_67: mux3_lv1_67_b(0 to 35) <= not( ( lmq6_ix2(0 to 35) and (0 to 35 => ex4_loadmiss_qentry(6) ) ) or
                                                 ( lmq7_ix2(0 to 35) and (0 to 35 => ex4_loadmiss_qentry(7) ) )  );


   u_mux3_lv2_03: mux3_lv2_03(0 to 35) <= not( mux3_lv1_01_b(0 to 35) and mux3_lv1_23_b(0 to 35) );
   u_mux3_lv2_47: mux3_lv2_47(0 to 35) <= not( mux3_lv1_45_b(0 to 35) and mux3_lv1_67_b(0 to 35) );

   u_mux3_lv3_07: mux3_lv3_07_b(0 to 35) <= not( mux3_lv2_03(0 to 35) or mux3_lv2_47(0 to 35) );
    
   ex4_ld_addr(22 to 57) <= not mux3_lv3_07_b(0 to 35) ; -- let synth repower --


   u_en_lsb_lmq: enable_lsb_lmq <= not( enable_lsb_lmq_b );
   u_en_lsb_oth: enable_lsb_oth <= not( enable_lsb_oth_b );
   u_en_lsb_bi:  enable_lsb_bi  <= not( enable_lsb_bi_b  );



-- ################################################################
-- # Latches
-- ################################################################

    lmq0_lat: entity tri.tri_inv_nlats   generic map (width => 36, init=> (1 to 36=>'0'), btr=> "NLI0001_X1_A12TH", expand_type => expand_type) port map (
        VD             => vdd                      ,
        GD             => gnd                      ,
        LCLK           => lmq_lclk                 ,
        D1CLK          => lmq_d1clk                ,
        D2CLK          => lmq_d2clk                ,
        SCANIN         => lmq0_si                  ,
        SCANOUT        => lmq0_so                  ,
        D              => lmq0_din(0 to 35)        ,
        QB             => lmq0_q_b(0 to 35)       );

    lmq1_lat: entity tri.tri_inv_nlats   generic map (width => 36, init=> (1 to 36=>'0'), btr=> "NLI0001_X1_A12TH", expand_type => expand_type) port map (
        VD             => vdd                      ,
        GD             => gnd                      ,
        LCLK           => lmq_lclk                 ,
        D1CLK          => lmq_d1clk                ,
        D2CLK          => lmq_d2clk                ,
        SCANIN         => lmq1_si                  ,
        SCANOUT        => lmq1_so                  ,
        D              => lmq1_din(0 to 35)        ,
        QB             => lmq1_q_b(0 to 35)       );

    lmq2_lat: entity tri.tri_inv_nlats   generic map (width => 36, init=> (1 to 36=>'0'), btr=> "NLI0001_X1_A12TH", expand_type => expand_type) port map (
        VD             => vdd                      ,
        GD             => gnd                      ,
        LCLK           => lmq_lclk                 ,
        D1CLK          => lmq_d1clk                ,
        D2CLK          => lmq_d2clk                ,
        SCANIN         => lmq2_si                  ,
        SCANOUT        => lmq2_so                  ,
        D              => lmq2_din(0 to 35)        ,
        QB             => lmq2_q_b(0 to 35)       );

    lmq3_lat: entity tri.tri_inv_nlats   generic map (width => 36, init=> (1 to 36=>'0'), btr=> "NLI0001_X1_A12TH", expand_type => expand_type) port map (
        VD             => vdd                      ,
        GD             => gnd                      ,
        LCLK           => lmq_lclk                 ,
        D1CLK          => lmq_d1clk                ,
        D2CLK          => lmq_d2clk                ,
        SCANIN         => lmq3_si                  ,
        SCANOUT        => lmq3_so                  ,
        D              => lmq3_din(0 to 35)        ,
        QB             => lmq3_q_b(0 to 35)       );

    lmq4_lat: entity tri.tri_inv_nlats   generic map (width => 36, init=> (1 to 36=>'0'), btr=> "NLI0001_X1_A12TH", expand_type => expand_type) port map (
        VD             => vdd                      ,
        GD             => gnd                      ,
        LCLK           => lmq_lclk                 ,
        D1CLK          => lmq_d1clk                ,
        D2CLK          => lmq_d2clk                ,
        SCANIN         => lmq4_si                  ,
        SCANOUT        => lmq4_so                  ,
        D              => lmq4_din(0 to 35)        ,
        QB             => lmq4_q_b(0 to 35)       );

    lmq5_lat: entity tri.tri_inv_nlats   generic map (width => 36, init=> (1 to 36=>'0'), btr=> "NLI0001_X1_A12TH", expand_type => expand_type) port map (
        VD             => vdd                      ,
        GD             => gnd                      ,
        LCLK           => lmq_lclk                 ,
        D1CLK          => lmq_d1clk                ,
        D2CLK          => lmq_d2clk                ,
        SCANIN         => lmq5_si                  ,
        SCANOUT        => lmq5_so                  ,
        D              => lmq5_din(0 to 35)        ,
        QB             => lmq5_q_b(0 to 35)       );

    lmq6_lat: entity tri.tri_inv_nlats   generic map (width => 36, init=> (1 to 36=>'0'), btr=> "NLI0001_X1_A12TH", expand_type => expand_type) port map (
        VD             => vdd                      ,
        GD             => gnd                      ,
        LCLK           => lmq_lclk                 ,
        D1CLK          => lmq_d1clk                ,
        D2CLK          => lmq_d2clk                ,
        SCANIN         => lmq6_si                  ,
        SCANOUT        => lmq6_so                  ,
        D              => lmq6_din(0 to 35)        ,
        QB             => lmq6_q_b(0 to 35)       );

    lmq7_lat: entity tri.tri_inv_nlats   generic map (width => 36, init=> (1 to 36=>'0'), btr=> "NLI0001_X1_A12TH", expand_type => expand_type) port map (
        VD             => vdd                      ,
        GD             => gnd                      ,
        LCLK           => lmq_lclk                 ,
        D1CLK          => lmq_d1clk                ,
        D2CLK          => lmq_d2clk                ,
        SCANIN         => lmq7_si                  ,
        SCANOUT        => lmq7_so                  ,
        D              => lmq7_din(0 to 35)        ,
        QB             => lmq7_q_b(0 to 35)       );

    ex3_erat_lat: entity tri.tri_inv_nlats   generic map (width => 6, init=> (1 to 6=>'0'), btr=> "NLI0001_X4_A12TH", expand_type => expand_type) port map (
        VD             => vdd                      ,
        GD             => gnd                      ,
        LCLK           => ex3_erat_lclk                ,
        D1CLK          => ex3_erat_d1clk               ,
        D2CLK          => ex3_erat_d2clk               ,
        SCANIN         => ex3_erat_si                  ,
        SCANOUT        => ex3_erat_so                  ,
        D              => ex2_p_addr_lwr(52 to 57)     ,
        QB             => ex3_erat_q_b(30 to 35)      );

    dir0_lat: entity tri.tri_inv_nlats   generic map (width => 31, init=> (1 to 31=>'0'), btr=> "NLI0001_X2_A12TH", expand_type => expand_type) port map (
        VD             => vdd                      ,
        GD             => gnd                      ,
        LCLK           => dir_lclk                 ,
        D1CLK          => dir_d1clk                ,
        D2CLK          => dir_d2clk                ,
        SCANIN         => dir0_si                  ,
        SCANOUT        => dir0_so                  ,
        D              => ex2_wayA_tag(22 to 52)   ,
        QB             => dir0_q_b(0 to 30)       );

    dir1_lat: entity tri.tri_inv_nlats   generic map (width => 31, init=> (1 to 31=>'0'), btr=> "NLI0001_X2_A12TH", expand_type => expand_type) port map (
        VD             => vdd                      ,
        GD             => gnd                      ,
        LCLK           => dir_lclk                 ,
        D1CLK          => dir_d1clk                ,
        D2CLK          => dir_d2clk                ,
        SCANIN         => dir1_si                  ,
        SCANOUT        => dir1_so                  ,
        D              => ex2_wayB_tag(22 to 52)   ,
        QB             => dir1_q_b(0 to 30)       );

    dir2_lat: entity tri.tri_inv_nlats   generic map (width => 31, init=> (1 to 31=>'0'), btr=> "NLI0001_X2_A12TH", expand_type => expand_type) port map (
        VD             => vdd                      ,
        GD             => gnd                      ,
        LCLK           => dir_lclk                 ,
        D1CLK          => dir_d1clk                ,
        D2CLK          => dir_d2clk                ,
        SCANIN         => dir2_si                  ,
        SCANOUT        => dir2_so                  ,
        D              => ex2_wayC_tag(22 to 52)   ,
        QB             => dir2_q_b(0 to 30)       );

    dir3_lat: entity tri.tri_inv_nlats   generic map (width => 31, init=> (1 to 31=>'0'), btr=> "NLI0001_X2_A12TH", expand_type => expand_type) port map (
        VD             => vdd                      ,
        GD             => gnd                      ,
        LCLK           => dir_lclk                 ,
        D1CLK          => dir_d1clk                ,
        D2CLK          => dir_d2clk                ,
        SCANIN         => dir3_si                  ,
        SCANOUT        => dir3_so                  ,
        D              => ex2_wayD_tag(22 to 52)   ,
        QB             => dir3_q_b(0 to 30)       );

    dir4_lat: entity tri.tri_inv_nlats   generic map (width => 31, init=> (1 to 31=>'0'), btr=> "NLI0001_X2_A12TH", expand_type => expand_type) port map (
        VD             => vdd                      ,
        GD             => gnd                      ,
        LCLK           => dir_lclk                 ,
        D1CLK          => dir_d1clk                ,
        D2CLK          => dir_d2clk                ,
        SCANIN         => dir4_si                  ,
        SCANOUT        => dir4_so                  ,
        D              => ex2_wayE_tag(22 to 52)   ,
        QB             => dir4_q_b(0 to 30)       );

    dir5_lat: entity tri.tri_inv_nlats   generic map (width => 31, init=> (1 to 31=>'0'), btr=> "NLI0001_X2_A12TH", expand_type => expand_type) port map (
        VD             => vdd                      ,
        GD             => gnd                      ,
        LCLK           => dir_lclk                 ,
        D1CLK          => dir_d1clk                ,
        D2CLK          => dir_d2clk                ,
        SCANIN         => dir5_si                  ,
        SCANOUT        => dir5_so                  ,
        D              => ex2_wayF_tag(22 to 52)   ,
        QB             => dir5_q_b(0 to 30)       );

    dir6_lat: entity tri.tri_inv_nlats   generic map (width => 31, init=> (1 to 31=>'0'), btr=> "NLI0001_X2_A12TH", expand_type => expand_type) port map (
        VD             => vdd                      ,
        GD             => gnd                      ,
        LCLK           => dir_lclk                 ,
        D1CLK          => dir_d1clk                ,
        D2CLK          => dir_d2clk                ,
        SCANIN         => dir6_si                  ,
        SCANOUT        => dir6_so                  ,
        D              => ex2_wayG_tag(22 to 52)   ,
        QB             => dir6_q_b(0 to 30)       );

    dir7_lat: entity tri.tri_inv_nlats   generic map (width => 31, init=> (1 to 31=>'0'), btr=> "NLI0001_X2_A12TH", expand_type => expand_type) port map (
        VD             => vdd                      ,
        GD             => gnd                      ,
        LCLK           => dir_lclk                 ,
        D1CLK          => dir_d1clk                ,
        D2CLK          => dir_d2clk                ,
        SCANIN         => dir7_si                  ,
        SCANOUT        => dir7_so                  ,
        D              => ex2_wayH_tag(22 to 52)   ,
        QB             => dir7_q_b(0 to 30)       );




-- ###############################################################
-- # LCBs
-- ###############################################################

    ex3_erat_lcb : tri_lcbnd generic map (expand_type => expand_type) port map(
        nclk        =>  nclk                 ,--in
        vd          =>  vdd                  ,--inout
        gd          =>  gnd                  ,--inout
        act         =>  ex2_erat_act         ,--in
        delay_lclkr =>  delay_lclkr (0)      ,--in
        mpw1_b      =>  mpw1_b      (0)      ,--in
        mpw2_b      =>  mpw2_b      (0)      ,--in
        forcee =>  forcee       (0)      ,--in
        sg          =>  sg_0        (0)      ,--in
        thold_b     =>  thold_0_b   (0)      ,--in
        d1clk       =>  ex3_erat_d1clk       ,--out
        d2clk       =>  ex3_erat_d2clk       ,--out
        lclk        =>  ex3_erat_lclk       );--out

    dir_lcb : tri_lcbnd generic map (expand_type => expand_type) port map(
        nclk        =>  nclk                 ,--in
        vd          =>  vdd                  ,--inout
        gd          =>  gnd                  ,--inout
        act         =>  binv2_ex2_stg_act    ,--in
        delay_lclkr =>  delay_lclkr (1)      ,--in
        mpw1_b      =>  mpw1_b      (1)      ,--in
        mpw2_b      =>  mpw2_b      (1)      ,--in
        forcee =>  forcee       (1)      ,--in
        sg          =>  sg_0        (1)      ,--in
        thold_b     =>  thold_0_b   (1)      ,--in
        d1clk       =>  dir_d1clk            ,--out
        d2clk       =>  dir_d2clk            ,--out
        lclk        =>  dir_lclk            );--out

    lmq_lcb : tri_lcbnd generic map (expand_type => expand_type) port map(
        nclk        =>  nclk                 ,--in
        vd          =>  vdd                  ,--inout
        gd          =>  gnd                  ,--inout
        act         =>  lmq_entry_act        ,--in
        delay_lclkr =>  delay_lclkr (2)      ,--in
        mpw1_b      =>  mpw1_b      (2)      ,--in
        mpw2_b      =>  mpw2_b      (2)      ,--in
        forcee =>  forcee       (2)      ,--in
        sg          =>  sg_0        (2)      ,--in
        thold_b     =>  thold_0_b   (2)      ,--in
        d1clk       =>  lmq_d1clk            ,--out
        d2clk       =>  lmq_d2clk            ,--out
        lclk        =>  lmq_lclk            );--out


 
--=###############################################################


  ex3_erat_si(5)       <= scan_in(0);
  ex3_erat_si(0 to 4)  <= ex3_erat_so(1 to 5);
  scan_out(0)          <= ex3_erat_so(0);

  dir0_si(0)           <= scan_in(1);
  dir0_si(1 to 30)     <= dir0_so(0 to 29);
  dir1_si(30)          <= dir0_so(30) ;
  dir1_si(0 to 29)     <= dir1_so(1 to 30);
  dir2_si(0)           <= dir1_so(0)  ;
  dir2_si(1 to 30)     <= dir2_so(0 to 29);
  dir3_si(30)          <= dir2_so(30) ;
  dir3_si(0 to 29)     <= dir3_so(1 to 30);
  dir4_si(0)           <= dir3_so(0)  ;
  dir4_si(1 to 30)     <= dir4_so(0 to 29);
  dir5_si(30)          <= dir4_so(30) ;
  dir5_si(0 to 29)     <= dir5_so(1 to 30);
  dir6_si(0)           <= dir5_so(0)  ;
  dir6_si(1 to 30)     <= dir6_so(0 to 29);
  dir7_si(30)          <= dir6_so(30) ;
  dir7_si(0 to 29)     <= dir7_so(1 to 30);
  scan_out(1)          <= dir7_so(0) ;

  lmq0_si(0)           <= scan_in(2);
  lmq0_si(1 to 35)     <= lmq0_so(0 to 34);
  lmq1_si(35)          <= lmq0_so(35) ;
  lmq1_si(0 to 34)     <= lmq1_so(1 to 35);
  lmq2_si(0)           <= lmq1_so(0)  ;
  lmq2_si(1 to 35)     <= lmq2_so(0 to 34);
  lmq3_si(35)          <= lmq2_so(35) ;
  lmq3_si(0 to 34)     <= lmq3_so(1 to 35);
  lmq4_si(0)           <= lmq3_so(0)  ;
  lmq4_si(1 to 35)     <= lmq4_so(0 to 34);
  lmq5_si(35)          <= lmq4_so(35) ;
  lmq5_si(0 to 34)     <= lmq5_so(1 to 35);
  lmq6_si(0)           <= lmq5_so(0)  ;
  lmq6_si(1 to 35)     <= lmq6_so(0 to 34);
  lmq7_si(35)          <= lmq6_so(35) ;
  lmq7_si(0 to 34)     <= lmq7_so(1 to 35);
  scan_out(2)          <= lmq7_so(0) ;


end; -- xuq_lsu_cmp ARCHITECTURE
