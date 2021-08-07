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



library ieee; 
  use ieee.std_logic_1164.all ; 
library ibm; 
  use ibm.std_ulogic_support.all; 
  use ibm.std_ulogic_function_support.all; 
  use ibm.std_ulogic_ao_support.all; 
  use ibm.std_ulogic_mux_support.all; 
library support; 
   use support.power_logic_pkg.all;
library tri; use tri.tri_latches_pkg.all;
library clib;

entity fuq_tblmul is
                  generic( expand_type  : integer := 2  ); -- 0 - ibm tech, 1 - other );
port(
       vdd                                       :inout power_logic;
       gnd                                       :inout power_logic;
       x          :in  std_ulogic_vector(1 to 15); -- rng from lookup (recode)
       y          :in  std_ulogic_vector(7 to 22); -- b operand bits  (shift)
       z          :in  std_ulogic_vector(0 to 20); -- estimate from table

       -- multiplier output msb comes out at [6]

       tbl_sum    :out std_ulogic_vector(0 to 36); 
       tbl_car    :out std_ulogic_vector(0 to 35)
);


end fuq_tblmul; -- ENTITY

architecture fuq_tblmul of fuq_tblmul is

    constant tiup : std_ulogic := '1';
    constant tidn : std_ulogic := '0';

    signal sub_adj_lsb, sub_adj_lsb_b :std_ulogic_vector(1 to 7);
    signal              sub_adj_msb_b :std_ulogic_vector(1 to 7);
    signal sub_adj_msb_7x_b, sub_adj_msb_7x, sub_adj_msb_7y :std_ulogic;
    signal s_x, s_x2, s_neg :std_ulogic_vector(0 to 7);

    signal pp0_0 :std_ulogic_vector( 6 to 24);
    signal pp0_1 :std_ulogic_vector( 6 to 26);
    signal pp0_2 :std_ulogic_vector( 8 to 28);
    signal pp0_3 :std_ulogic_vector(10 to 30);
    signal pp0_4 :std_ulogic_vector(12 to 32);
    signal pp0_5 :std_ulogic_vector(14 to 34);
    signal pp0_6 :std_ulogic_vector(16 to 36);
    signal pp0_7 :std_ulogic_vector(17 to 36);


  signal pp1_0_sum :std_ulogic_vector(0 to 26); 
  signal pp1_0_car :std_ulogic_vector(0 to 24); 
  signal pp1_1_sum :std_ulogic_vector(8 to 32); 
  signal pp1_1_car :std_ulogic_vector(9 to 30); 
  signal pp1_2_sum :std_ulogic_vector(14 to 36); 
  signal pp1_2_car :std_ulogic_vector(15 to 36); 
  signal pp1_0_car_unused  :std_ulogic;


  signal pp2_0_sum :std_ulogic_vector(0 to 32); 
  signal pp2_0_car :std_ulogic_vector(0 to 26); 
  signal pp2_1_sum :std_ulogic_vector(9 to 36); 
  signal pp2_1_car :std_ulogic_vector(13 to 36); 
  signal pp2_0_car_unused  :std_ulogic;


     signal pp3_0_sum :std_ulogic_vector(0 to 36);
     signal pp3_0_ko  :std_ulogic_vector(8 to 25);
     signal pp3_0_car :std_ulogic_vector(0 to 35);
     signal pp3_0_car_unused  :std_ulogic;
     signal z_b :std_ulogic_vector(0 to 20);
     signal unused :std_ulogic; 








begin

 unused <= pp1_0_car_unused or
           pp2_0_car_unused  or 
           pp3_0_car_unused  or 
           pp0_0(23)  or 
           pp0_1(25)  or 
           pp0_2(27)  or 
           pp0_3(29)  or 
           pp0_4(31)  or 
           pp0_5(33)  or 
           pp0_6(35)  or 
           pp1_0_car(23)  or 
           pp1_0_sum(25)  or 
           pp1_1_car(28)  or 
           pp1_1_sum(31)  or 
           pp1_2_car(34)  or 
           pp2_0_car(24)  or 
           pp2_0_sum(31)  or 
           pp2_1_car(30)  or 
           pp2_1_car(34)  or 
           s_neg(0) or 
          pp1_1_car(29)  or 
          pp1_2_car(35)  or 
          pp2_0_car(25)  or 
          pp2_1_car(35)  ;



--=#################################################
--= Booth Decoders
--=#################################################
--   0     1     2     3     4      5      6        7
-- (x,1) (2,3) (4,5) (6,7) (8,9) (10,11) (12,13) (14,15)

 bd0: entity work.fuq_tblmul_bthdcd(fuq_tblmul_bthdcd) port map( 
        i0               => tidn                      ,--i--
        i1               => x(1)                      ,--i--
        i2               => x(2)                      ,--i--
        s_neg            =>   s_neg(0)                ,--o--
        s_x              =>     s_x(0)                ,--o--
        s_x2             =>    s_x2(0)               );--o--

 bd1: entity work.fuq_tblmul_bthdcd(fuq_tblmul_bthdcd) port map( 
        i0               => x(2)                      ,--i--
        i1               => x(3)                      ,--i--
        i2               => x(4)                      ,--i--
        s_neg            =>   s_neg(1)                ,--o--
        s_x              =>     s_x(1)                ,--o--
        s_x2             =>    s_x2(1)               );--o--

 bd2: entity work.fuq_tblmul_bthdcd(fuq_tblmul_bthdcd) port map( 
        i0               => x(4)                      ,--i--
        i1               => x(5)                      ,--i--
        i2               => x(6)                      ,--i--
        s_neg            =>   s_neg(2)                ,--o--
        s_x              =>     s_x(2)                ,--o--
        s_x2             =>    s_x2(2)               );--o--

 bd3: entity work.fuq_tblmul_bthdcd(fuq_tblmul_bthdcd) port map( 
        i0               => x(6)                      ,--i--
        i1               => x(7)                      ,--i--
        i2               => x(8)                      ,--i--
        s_neg            =>   s_neg(3)                ,--o--
        s_x              =>     s_x(3)                ,--o--
        s_x2             =>    s_x2(3)               );--o--

 bd4: entity work.fuq_tblmul_bthdcd(fuq_tblmul_bthdcd) port map( 
        i0               => x(8)                      ,--i--
        i1               => x(9)                      ,--i--
        i2               => x(10)                     ,--i--
        s_neg            =>   s_neg(4)                ,--o--
        s_x              =>     s_x(4)                ,--o--
        s_x2             =>    s_x2(4)               );--o--

 bd5: entity work.fuq_tblmul_bthdcd(fuq_tblmul_bthdcd) port map( 
        i0               => x(10)                     ,--i--
        i1               => x(11)                     ,--i--
        i2               => x(12)                     ,--i--
        s_neg            =>   s_neg(5)                ,--o--
        s_x              =>     s_x(5)                ,--o--
        s_x2             =>    s_x2(5)               );--o--

 bd6: entity work.fuq_tblmul_bthdcd(fuq_tblmul_bthdcd) port map( 
        i0               => x(12)                     ,--i--
        i1               => x(13)                     ,--i--
        i2               => x(14)                     ,--i--
        s_neg            =>   s_neg(6)                ,--o--
        s_x              =>     s_x(6)                ,--o--
        s_x2             =>    s_x2(6)               );--o--

 bd7: entity work.fuq_tblmul_bthdcd(fuq_tblmul_bthdcd) port map( 
        i0               => x(14)                     ,--i--
        i1               => x(15)                     ,--i--
        i2               => tidn                      ,--i--
        s_neg            =>   s_neg(7)                ,--o--
        s_x              =>     s_x(7)                ,--o--
        s_x2             =>    s_x2(7)               );--o--




--=###############################################################
--= booth muxes
--=###############################################################

--= NUMBERING SYSTEM RELATIVE TO COMPRESSOR TREE
--=
--=    00000000000000000000000000000000000000
--=    00000000001111111111222222222233333333
--=    01234567890123456789012345678901234567
--=  0 .......DddddddddddddddddD0s................
--=  1 .......1aDddddddddddddddddD0s..............
--=  2 .........1aDddddddddddddddddD0s............
--=  3 ...........1aDddddddddddddddddD0s..........
--=  4 .............1aDddddddddddddddddD0s........
--=  5 ...............1aDddddddddddddddddD0s......
--=  6 .................1aDddddddddddddddddD0s....
--=  7 ..................assDddddddddddddddddD....
--= EST dddddddddddddddddddd  (the ass from sgnXtd.7 is already added into the est.
--=
--=############################
--= want (est - mult )
--= will calc   -(r - e) = -(r + !e + 1)
--=                      = -(r + !e) -1
--=                      = !(r + !e) + 1 - 1
--=                      = !(r + !e)
--=                      = !(R + ASS + !e)  ... seperate out the overlapping SGNxtd piece
--=                      = !(R + (ASS + !e))  .... invert the final adder output
--=
--= table estimate will be : ADD    !e + 100
--=                          SUB    !e + 011
--=
--= more "0" in table if read out POS version of est, then invert
--=
--=   !e + adj   = -e -1 + adj
--=              = -(e +1 -adj)
--=              = -(e -adj) -1
--=              = !(e -adj) +1 -1
--=              = !(e -adj) ... invert the table input

 sa1_1_lsb: sub_adj_lsb_b(1) <= not( s_neg(1) and ( s_x(1) or s_x2(1) ) );
 sa2_1_lsb: sub_adj_lsb_b(2) <= not( s_neg(2) and ( s_x(2) or s_x2(2) ) );
 sa3_1_lsb: sub_adj_lsb_b(3) <= not( s_neg(3) and ( s_x(3) or s_x2(3) ) );
 sa4_1_lsb: sub_adj_lsb_b(4) <= not( s_neg(4) and ( s_x(4) or s_x2(4) ) );
 sa5_1_lsb: sub_adj_lsb_b(5) <= not( s_neg(5) and ( s_x(5) or s_x2(5) ) );
 sa6_1_lsb: sub_adj_lsb_b(6) <= not( s_neg(6) and ( s_x(6) or s_x2(6) ) );
 sa7_1_lsb: sub_adj_lsb_b(7) <= not( s_neg(7) and ( s_x(7) or s_x2(7) ) );

 sa1_2_lsb: sub_adj_lsb  (1) <= not sub_adj_lsb_b(1);
 sa2_2_lsb: sub_adj_lsb  (2) <= not sub_adj_lsb_b(2);
 sa3_2_lsb: sub_adj_lsb  (3) <= not sub_adj_lsb_b(3);
 sa4_2_lsb: sub_adj_lsb  (4) <= not sub_adj_lsb_b(4);
 sa5_2_lsb: sub_adj_lsb  (5) <= not sub_adj_lsb_b(5);
 sa6_2_lsb: sub_adj_lsb  (6) <= not sub_adj_lsb_b(6);
 sa7_2_lsb: sub_adj_lsb  (7) <= not sub_adj_lsb_b(7);

 sa1_1_msb:  sub_adj_msb_b(1) <= not( s_neg(1) and ( s_x(1) or s_x2(1) ) );
 sa2_1_msb:  sub_adj_msb_b(2) <= not( s_neg(2) and ( s_x(2) or s_x2(2) ) );
 sa3_1_msb:  sub_adj_msb_b(3) <= not( s_neg(3) and ( s_x(3) or s_x2(3) ) );
 sa4_1_msb:  sub_adj_msb_b(4) <= not( s_neg(4) and ( s_x(4) or s_x2(4) ) );
 sa5_1_msb:  sub_adj_msb_b(5) <= not( s_neg(5) and ( s_x(5) or s_x2(5) ) );
 sa6_1_msb:  sub_adj_msb_b(6) <= not( s_neg(6) and ( s_x(6) or s_x2(6) ) );
 sa7_1_msb:  sub_adj_msb_b(7) <= not( s_neg(7) and ( s_x(7) or s_x2(7) ) ); 
 sa7x_1_msb: sub_adj_msb_7x_b <= not( s_neg(7) and ( s_x(7) or s_x2(7) ) ); 

 sa7x_2_msb: sub_adj_msb_7x   <= not sub_adj_msb_7x_b ;
 sa7y_2_msb: sub_adj_msb_7y   <= not sub_adj_msb_7x_b ;

 
 bm0: entity work.fuq_tblmul_bthrow(fuq_tblmul_bthrow) port map( 
        s_neg            => tidn                    ,--i--  (tidn) msb term is never sub
        s_x              => s_x(0)                  ,--i--
        s_x2             => s_x2(0)                 ,--i--
        x                => y(7 to 22)              ,--i--
        q                => pp0_0(6 to 22)         );--o--
                            pp0_0(23) <= tidn;
                            pp0_0(24) <= sub_adj_lsb(1);

                            pp0_1(6)  <= tiup;
                            pp0_1(7)  <= sub_adj_msb_b(1);
 bm1: entity work.fuq_tblmul_bthrow(fuq_tblmul_bthrow) port map( 
        s_neg            => s_neg(1)                ,--i--
        s_x              =>   s_x(1)                ,--i--
        s_x2             =>  s_x2(1)                ,--i--
        x                => y(7 to 22)              ,--i--
        q                => pp0_1(8 to 24)         );--o--
                            pp0_1(25) <= tidn;
                            pp0_1(26) <= sub_adj_lsb(2);

                            pp0_2(8) <= tiup;
                            pp0_2(9) <= sub_adj_msb_b(2);
 bm2: entity work.fuq_tblmul_bthrow(fuq_tblmul_bthrow) port map( 
        s_neg            => s_neg(2)                ,--i--
        s_x              =>   s_x(2)                ,--i--
        s_x2             =>  s_x2(2)                ,--i--
        x                => y(7 to 22)              ,--i--
        q                => pp0_2(10 to 26)        );--o--
                            pp0_2(27) <= tidn;
                            pp0_2(28) <= sub_adj_lsb(3);

                            pp0_3(10) <= tiup;
                            pp0_3(11) <= sub_adj_msb_b(3);
 bm3: entity work.fuq_tblmul_bthrow(fuq_tblmul_bthrow) port map( 
        s_neg            => s_neg(3)                ,--i--
        s_x              =>   s_x(3)                ,--i--
        s_x2             =>  s_x2(3)                ,--i--
        x                => y(7 to 22)              ,--i--
        q                => pp0_3(12 to 28)        );--o--
                            pp0_3(29) <= tidn;
                            pp0_3(30) <= sub_adj_lsb(4);

                            pp0_4(12) <= tiup;
                            pp0_4(13) <= sub_adj_msb_b(4);
 bm4: entity work.fuq_tblmul_bthrow(fuq_tblmul_bthrow) port map( 
        s_neg            => s_neg(4)                ,--i--
        s_x              =>   s_x(4)                ,--i--
        s_x2             =>  s_x2(4)                ,--i--
        x                => y(7 to 22)              ,--i--
        q                => pp0_4(14 to 30)        );--o--
                            pp0_4(31) <= tidn;
                            pp0_4(32) <= sub_adj_lsb(5);

                            pp0_5(14) <= tiup;
                            pp0_5(15) <= sub_adj_msb_b(5);
 bm5: entity work.fuq_tblmul_bthrow(fuq_tblmul_bthrow) port map( 
        s_neg            => s_neg(5)                ,--i--
        s_x              =>   s_x(5)                ,--i--
        s_x2             =>  s_x2(5)                ,--i--
        x                => y(7 to 22)              ,--i--
        q                => pp0_5(16 to 32)        );--o--
                            pp0_5(33) <= tidn;
                            pp0_5(34) <= sub_adj_lsb(6);

                            pp0_6(16) <= tiup;
                            pp0_6(17) <= sub_adj_msb_b(6);
 bm6: entity work.fuq_tblmul_bthrow(fuq_tblmul_bthrow) port map( 
        s_neg            => s_neg(6)                ,--i--
        s_x              =>   s_x(6)                ,--i--
        s_x2             =>  s_x2(6)                ,--i--
        x                => y(7 to 22)              ,--i--
        q                => pp0_6(18 to 34)        );--o--
                            pp0_6(35) <= tidn;
                            pp0_6(36) <= sub_adj_lsb(7);

                           pp0_7(17) <=  sub_adj_msb_b(7);
                           pp0_7(18) <=  sub_adj_msb_7x;
                           pp0_7(19) <=  sub_adj_msb_7y;
 bm7: entity work.fuq_tblmul_bthrow(fuq_tblmul_bthrow) port map( 
        s_neg            => s_neg(7)                ,--i--
        s_x              =>   s_x(7)                ,--i--
        s_x2             =>  s_x2(7)                ,--i--
        x                => y(7 to 22)              ,--i--
        q                => pp0_7(20 to 36)        );--o--



--=####################################################################
--=# compressor tree level 1
--=####################################################################
--= 0         1         2         3
--= 0123456789012345678901234567890123456
--==-------------------------------------
--  ddddddddddddddddddddd________________
--  111111ddddddddddddddddd_S____________     bm0
--  ______1addddddddddddddddd_S__________     bm1
--  ________1addddddddddddddddd_S________     bm2
--  __________1addddddddddddddddd_S______     bm3
--  ____________1addddddddddddddddd_S____     bm4
--  ______________1addddddddddddddddd_S__     bm5
--  ________________1addddddddddddddddd_S     bm6
--  _________________assddddddddddddddddd     bm7

--= 0         1         2         3
--= 0123456789012345678901234567890123456
--==-------------------------------------
--  ddddddddddddddddddddd________________
--  111111ddddddddddddddddd_S____________     bm0
--  ______1addddddddddddddddd_S__________     bm1
--  111111333333333333333221201
--  sssssssssssssssssssssssss_s               pp1_0_sum
--  ccccccccccccccccccccccc_c__               pp1_0_car


--= 0         1         2         3
--= 0123456789012345678901234567890123456
--==-------------------------------------
--  ________1addddddddddddddddd_S________     bm2
--  __________1addddddddddddddddd_S______     bm3
--  ____________1addddddddddddddddd_S____     bm4
--          1122333333333333333231201
--  ________sssssssssssssssssssssss_s         pp1_1_sum
--          _ccccccccccccccccccc__c__         pp1_1_car

--= 0         1         2         3
--= 0123456789012345678901234567890123456
--==-------------------------------------
--  ______________1addddddddddddddddd_S__     bm5
--  ________________1addddddddddddddddd_S     bm6
--  _________________assddddddddddddddddd     bm7
--                11233333333333333332312
--                sssssssssssssssssssssss     pp1_2_sum
--                _ccccccccccccccccccc__c     pp1_2_car


    z_b(0 to 20)  <= not z(0 to 20);

--======================================================
--== compressor level 1 , row 0
--======================================================

    pp1_0_sum(26)                    <= pp0_1(26)                        ;
    pp1_0_sum(25)                    <= tidn                             ;
    pp1_0_sum(24)                    <= pp0_0(24)                        ;
    pp1_0_car(24)                    <= pp0_1(24)                        ;
    pp1_0_sum(23)                    <= pp0_1(23)                        ;
    pp1_0_car(23)                    <= tidn                             ;
    pp1_0_sum(22)                    <= pp0_0(22)                        ;
    pp1_0_car(22)                    <= pp0_1(22)                        ;
    pp1_0_sum(21)                    <= pp0_0(21)                        ;
    pp1_0_car(21)                    <= pp0_1(21)                        ;
    pp1_0_car(20)                    <= tidn                             ;
 pp1_0_csa_20: entity clib.c_prism_csa32  port map(  -- MLT32_X1_A12TH
      vd               => vdd,
      gd               => gnd,
      a                => z_b(20)                           ,--i--
      b                => pp0_0(20)                         ,--i--
      c                => pp0_1(20)                         ,--i--
      sum              => pp1_0_sum(20)                     ,--o--
      car              => pp1_0_car(19)                    );--o--
 pp1_0_csa_19: entity clib.c_prism_csa32  port map(  
      vd               => vdd,
      gd               => gnd,
      a                => z_b(19)                           ,--i--
      b                => pp0_0(19)                         ,--i--
      c                => pp0_1(19)                         ,--i--
      sum              => pp1_0_sum(19)                     ,--o--
      car              => pp1_0_car(18)                    );--o--
 pp1_0_csa_18: entity clib.c_prism_csa32  port map(  
      vd               => vdd,
      gd               => gnd,
      a                => z_b(18)                           ,--i--
      b                => pp0_0(18)                         ,--i--
      c                => pp0_1(18)                         ,--i--
      sum              => pp1_0_sum(18)                     ,--o--
      car              => pp1_0_car(17)                    );--o--
 pp1_0_csa_17: entity clib.c_prism_csa32  port map(  
      vd               => vdd,
      gd               => gnd,
      a                => z_b(17)                           ,--i--
      b                => pp0_0(17)                         ,--i--
      c                => pp0_1(17)                         ,--i--
      sum              => pp1_0_sum(17)                     ,--o--
      car              => pp1_0_car(16)                    );--o--
 pp1_0_csa_16: entity clib.c_prism_csa32  port map(  
      vd               => vdd,
      gd               => gnd,
      a                => z_b(16)                           ,--i--
      b                => pp0_0(16)                         ,--i--
      c                => pp0_1(16)                         ,--i--
      sum              => pp1_0_sum(16)                     ,--o--
      car              => pp1_0_car(15)                    );--o--
 pp1_0_csa_15: entity clib.c_prism_csa32  port map(  
      vd               => vdd,
      gd               => gnd,
      a                => z_b(15)                           ,--i--
      b                => pp0_0(15)                         ,--i--
      c                => pp0_1(15)                         ,--i--
      sum              => pp1_0_sum(15)                     ,--o--
      car              => pp1_0_car(14)                    );--o--
 pp1_0_csa_14: entity clib.c_prism_csa32  port map(  
      vd               => vdd,
      gd               => gnd,
      a                => z_b(14)                           ,--i--
      b                => pp0_0(14)                         ,--i--
      c                => pp0_1(14)                         ,--i--
      sum              => pp1_0_sum(14)                     ,--o--
      car              => pp1_0_car(13)                    );--o--
 pp1_0_csa_13: entity clib.c_prism_csa32  port map(  
      vd               => vdd,
      gd               => gnd,
      a                => z_b(13)                           ,--i--
      b                => pp0_0(13)                         ,--i--
      c                => pp0_1(13)                         ,--i--
      sum              => pp1_0_sum(13)                     ,--o--
      car              => pp1_0_car(12)                    );--o--
 pp1_0_csa_12: entity clib.c_prism_csa32  port map(  
      vd               => vdd,
      gd               => gnd,
      a                => z_b(12)                           ,--i--
      b                => pp0_0(12)                         ,--i--
      c                => pp0_1(12)                         ,--i--
      sum              => pp1_0_sum(12)                     ,--o--
      car              => pp1_0_car(11)                    );--o--
 pp1_0_csa_11: entity clib.c_prism_csa32  port map(  
      vd               => vdd,
      gd               => gnd,
      a                => z_b(11)                           ,--i--
      b                => pp0_0(11)                         ,--i--
      c                => pp0_1(11)                         ,--i--
      sum              => pp1_0_sum(11)                     ,--o--
      car              => pp1_0_car(10)                    );--o--
 pp1_0_csa_10: entity clib.c_prism_csa32  port map(  
      vd               => vdd,
      gd               => gnd,
      a                => z_b(10)                           ,--i--
      b                => pp0_0(10)                         ,--i--
      c                => pp0_1(10)                         ,--i--
      sum              => pp1_0_sum(10)                     ,--o--
      car              => pp1_0_car(9)                     );--o--
 pp1_0_csa_9: entity clib.c_prism_csa32  port map(  
      vd               => vdd,
      gd               => gnd,
      a                => z_b(9)                            ,--i--
      b                => pp0_0(9)                          ,--i--
      c                => pp0_1(9)                          ,--i--
      sum              => pp1_0_sum(9)                      ,--o--
      car              => pp1_0_car(8)                     );--o--
 pp1_0_csa_8: entity clib.c_prism_csa32  port map(  
      vd               => vdd,
      gd               => gnd,
      a                => z_b(8)                            ,--i--
      b                => pp0_0(8)                          ,--i--
      c                => pp0_1(8)                          ,--i--
      sum              => pp1_0_sum(8)                      ,--o--
      car              => pp1_0_car(7)                     );--o--
 pp1_0_csa_7: entity clib.c_prism_csa32  port map(  
      vd               => vdd,
      gd               => gnd,
      a                => z_b(7)                            ,--i--
      b                => pp0_0(7)                          ,--i--
      c                => pp0_1(7)                          ,--i--
      sum              => pp1_0_sum(7)                      ,--o--
      car              => pp1_0_car(6)                     );--o--
 pp1_0_csa_6: entity clib.c_prism_csa32  port map(  
      vd               => vdd,
      gd               => gnd,
      a                => z_b(6)                            ,--i--
      b                => pp0_0(6)                          ,--i--
      c                => pp0_1(6)                          ,--i--
      sum              => pp1_0_sum(6)                      ,--o--
      car              => pp1_0_car(5)                     );--o--
 pp1_0_csa_5: entity work.fuq_csa22_h2(fuq_csa22_h2) port map(  
      a                => z_b(5)                            ,--i--
      b                => tiup                              ,--i--
      sum              => pp1_0_sum(5)                      ,--o--
      car              => pp1_0_car(4)                     );--o--
 pp1_0_csa_4: entity work.fuq_csa22_h2(fuq_csa22_h2) port map(  
      a                => z_b(4)                            ,--i--
      b                => tiup                              ,--i--
      sum              => pp1_0_sum(4)                      ,--o--
      car              => pp1_0_car(3)                     );--o--
 pp1_0_csa_3: entity work.fuq_csa22_h2(fuq_csa22_h2) port map(  
      a                => z_b(3)                            ,--i--
      b                => tiup                              ,--i--
      sum              => pp1_0_sum(3)                      ,--o--
      car              => pp1_0_car(2)                     );--o--
 pp1_0_csa_2: entity work.fuq_csa22_h2(fuq_csa22_h2) port map(  
      a                => z_b(2)                            ,--i--
      b                => tiup                              ,--i--
      sum              => pp1_0_sum(2)                      ,--o--
      car              => pp1_0_car(1)                     );--o--
 pp1_0_csa_1: entity work.fuq_csa22_h2(fuq_csa22_h2) port map(  
      a                => z_b(1)                            ,--i--
      b                => tiup                              ,--i--
      sum              => pp1_0_sum(1)                      ,--o--
      car              => pp1_0_car(0)                     );--o--
 pp1_0_csa_0: entity work.fuq_csa22_h2(fuq_csa22_h2) port map(  
      a                => z_b(0)                            ,--i--
      b                => tiup                              ,--i--
      sum              => pp1_0_sum(0)                      ,--o--
      car              => pp1_0_car_unused                 );--o--


--======================================================
--== compressor level 1 , row 1
--======================================================

    pp1_1_sum(32)                    <= pp0_4(32)                        ;
    pp1_1_sum(31)                    <= tidn                             ;
    pp1_1_sum(30)                    <= pp0_3(30)                        ;
    pp1_1_car(30)                    <= pp0_4(30)                        ;
    pp1_1_sum(29)                    <= pp0_4(29)                        ;
    pp1_1_car(29)                    <= tidn                             ;
    pp1_1_car(28)                    <= tidn                             ;
 pp1_1_csa_28: entity clib.c_prism_csa32  port map(  
      vd               => vdd,
      gd               => gnd,
      a                => pp0_2(28)                         ,--i--
      b                => pp0_3(28)                         ,--i--
      c                => pp0_4(28)                         ,--i--
      sum              => pp1_1_sum(28)                     ,--o--
      car              => pp1_1_car(27)                    );--o--
 pp1_1_csa_27: entity work.fuq_csa22_h2(fuq_csa22_h2) port map(  
      a                => pp0_3(27)                         ,--i--
      b                => pp0_4(27)                         ,--i--
      sum              => pp1_1_sum(27)                     ,--o--
      car              => pp1_1_car(26)                    );--o--
 pp1_1_csa_26: entity clib.c_prism_csa32  port map(  
      vd               => vdd,
      gd               => gnd,
      a                => pp0_2(26)                         ,--i--
      b                => pp0_3(26)                         ,--i--
      c                => pp0_4(26)                         ,--i--
      sum              => pp1_1_sum(26)                     ,--o--
      car              => pp1_1_car(25)                    );--o--
 pp1_1_csa_25: entity clib.c_prism_csa32  port map(  
      vd               => vdd,
      gd               => gnd,
      a                => pp0_2(25)                         ,--i--
      b                => pp0_3(25)                         ,--i--
      c                => pp0_4(25)                         ,--i--
      sum              => pp1_1_sum(25)                     ,--o--
      car              => pp1_1_car(24)                    );--o--
 pp1_1_csa_24: entity clib.c_prism_csa32  port map(  
      vd               => vdd,
      gd               => gnd,
      a                => pp0_2(24)                         ,--i--
      b                => pp0_3(24)                         ,--i--
      c                => pp0_4(24)                         ,--i--
      sum              => pp1_1_sum(24)                     ,--o--
      car              => pp1_1_car(23)                    );--o--
 pp1_1_csa_23: entity clib.c_prism_csa32  port map(  
      vd               => vdd,
      gd               => gnd,
      a                => pp0_2(23)                         ,--i--
      b                => pp0_3(23)                         ,--i--
      c                => pp0_4(23)                         ,--i--
      sum              => pp1_1_sum(23)                     ,--o--
      car              => pp1_1_car(22)                    );--o--
 pp1_1_csa_22: entity clib.c_prism_csa32  port map(  
      vd               => vdd,
      gd               => gnd,
      a                => pp0_2(22)                         ,--i--
      b                => pp0_3(22)                         ,--i--
      c                => pp0_4(22)                         ,--i--
      sum              => pp1_1_sum(22)                     ,--o--
      car              => pp1_1_car(21)                    );--o--
 pp1_1_csa_21: entity clib.c_prism_csa32  port map(  
      vd               => vdd,
      gd               => gnd,
      a                => pp0_2(21)                         ,--i--
      b                => pp0_3(21)                         ,--i--
      c                => pp0_4(21)                         ,--i--
      sum              => pp1_1_sum(21)                     ,--o--
      car              => pp1_1_car(20)                    );--o--
 pp1_1_csa_20: entity clib.c_prism_csa32  port map(  
      vd               => vdd,
      gd               => gnd,
      a                => pp0_2(20)                         ,--i--
      b                => pp0_3(20)                         ,--i--
      c                => pp0_4(20)                         ,--i--
      sum              => pp1_1_sum(20)                     ,--o--
      car              => pp1_1_car(19)                    );--o--
 pp1_1_csa_19: entity clib.c_prism_csa32  port map(  
      vd               => vdd,
      gd               => gnd,
      a                => pp0_2(19)                         ,--i--
      b                => pp0_3(19)                         ,--i--
      c                => pp0_4(19)                         ,--i--
      sum              => pp1_1_sum(19)                     ,--o--
      car              => pp1_1_car(18)                    );--o--
 pp1_1_csa_18: entity clib.c_prism_csa32  port map(  
      vd               => vdd,
      gd               => gnd,
      a                => pp0_2(18)                         ,--i--
      b                => pp0_3(18)                         ,--i--
      c                => pp0_4(18)                         ,--i--
      sum              => pp1_1_sum(18)                     ,--o--
      car              => pp1_1_car(17)                    );--o--
 pp1_1_csa_17: entity clib.c_prism_csa32  port map(  
      vd               => vdd,
      gd               => gnd,
      a                => pp0_2(17)                         ,--i--
      b                => pp0_3(17)                         ,--i--
      c                => pp0_4(17)                         ,--i--
      sum              => pp1_1_sum(17)                     ,--o--
      car              => pp1_1_car(16)                    );--o--
 pp1_1_csa_16: entity clib.c_prism_csa32  port map(  
      vd               => vdd,
      gd               => gnd,
      a                => pp0_2(16)                         ,--i--
      b                => pp0_3(16)                         ,--i--
      c                => pp0_4(16)                         ,--i--
      sum              => pp1_1_sum(16)                     ,--o--
      car              => pp1_1_car(15)                    );--o--
 pp1_1_csa_15: entity clib.c_prism_csa32  port map(  
      vd               => vdd,
      gd               => gnd,
      a                => pp0_2(15)                         ,--i--
      b                => pp0_3(15)                         ,--i--
      c                => pp0_4(15)                         ,--i--
      sum              => pp1_1_sum(15)                     ,--o--
      car              => pp1_1_car(14)                    );--o--
 pp1_1_csa_14: entity clib.c_prism_csa32  port map(  
      vd               => vdd,
      gd               => gnd,
      a                => pp0_2(14)                         ,--i--
      b                => pp0_3(14)                         ,--i--
      c                => pp0_4(14)                         ,--i--
      sum              => pp1_1_sum(14)                     ,--o--
      car              => pp1_1_car(13)                    );--o--
 pp1_1_csa_13: entity clib.c_prism_csa32  port map(  
      vd               => vdd,
      gd               => gnd,
      a                => pp0_2(13)                         ,--i--
      b                => pp0_3(13)                         ,--i--
      c                => pp0_4(13)                         ,--i--
      sum              => pp1_1_sum(13)                     ,--o--
      car              => pp1_1_car(12)                    );--o--
 pp1_1_csa_12: entity clib.c_prism_csa32  port map(  
      vd               => vdd,
      gd               => gnd,
      a                => pp0_2(12)                         ,--i--
      b                => pp0_3(12)                         ,--i--
      c                => pp0_4(12)                         ,--i--
      sum              => pp1_1_sum(12)                     ,--o--
      car              => pp1_1_car(11)                    );--o--
 pp1_1_csa_11: entity work.fuq_csa22_h2(fuq_csa22_h2) port map(  
      a                => pp0_2(11)                         ,--i--
      b                => pp0_3(11)                         ,--i--
      sum              => pp1_1_sum(11)                     ,--o--
      car              => pp1_1_car(10)                    );--o--
 pp1_1_csa_10: entity work.fuq_csa22_h2(fuq_csa22_h2) port map(  
      a                => pp0_2(10)                         ,--i--
      b                => pp0_3(10)                         ,--i--
      sum              => pp1_1_sum(10)                     ,--o--
      car              => pp1_1_car(9)                     );--o--
    pp1_1_sum(9)                     <= pp0_2(9)                         ;
    pp1_1_sum(8)                     <= pp0_2(8)                         ;


--======================================================
--== compressor level 1 , row 2
--======================================================

    pp1_2_sum(36)                    <= pp0_6(36)                        ;
    pp1_2_car(36)                    <= pp0_7(36)                        ;
    pp1_2_sum(35)                    <= pp0_7(35)                        ;
    pp1_2_car(35)                    <= tidn                             ;
    pp1_2_car(34)                    <= tidn                             ;
 pp1_2_csa_34: entity clib.c_prism_csa32  port map(  
      vd               => vdd,
      gd               => gnd,
      a                => pp0_5(34)                         ,--i--
      b                => pp0_6(34)                         ,--i--
      c                => pp0_7(34)                         ,--i--
      sum              => pp1_2_sum(34)                     ,--o--
      car              => pp1_2_car(33)                    );--o--
 pp1_2_csa_33: entity work.fuq_csa22_h2(fuq_csa22_h2) port map(  
      a                => pp0_6(33)                         ,--i--
      b                => pp0_7(33)                         ,--i--
      sum              => pp1_2_sum(33)                     ,--o--
      car              => pp1_2_car(32)                    );--o--
 pp1_2_csa_32: entity clib.c_prism_csa32  port map(  
      vd               => vdd,
      gd               => gnd,
      a                => pp0_5(32)                         ,--i--
      b                => pp0_6(32)                         ,--i--
      c                => pp0_7(32)                         ,--i--
      sum              => pp1_2_sum(32)                     ,--o--
      car              => pp1_2_car(31)                    );--o--
 pp1_2_csa_31: entity clib.c_prism_csa32  port map(  
      vd               => vdd,
      gd               => gnd,
      a                => pp0_5(31)                         ,--i--
      b                => pp0_6(31)                         ,--i--
      c                => pp0_7(31)                         ,--i--
      sum              => pp1_2_sum(31)                     ,--o--
      car              => pp1_2_car(30)                    );--o--
 pp1_2_csa_30: entity clib.c_prism_csa32  port map(  
      vd               => vdd,
      gd               => gnd,
      a                => pp0_5(30)                         ,--i--
      b                => pp0_6(30)                         ,--i--
      c                => pp0_7(30)                         ,--i--
      sum              => pp1_2_sum(30)                     ,--o--
      car              => pp1_2_car(29)                    );--o--
 pp1_2_csa_29: entity clib.c_prism_csa32  port map(  
      vd               => vdd,
      gd               => gnd,
      a                => pp0_5(29)                         ,--i--
      b                => pp0_6(29)                         ,--i--
      c                => pp0_7(29)                         ,--i--
      sum              => pp1_2_sum(29)                     ,--o--
      car              => pp1_2_car(28)                    );--o--
 pp1_2_csa_28: entity clib.c_prism_csa32  port map(  
      vd               => vdd,
      gd               => gnd,
      a                => pp0_5(28)                         ,--i--
      b                => pp0_6(28)                         ,--i--
      c                => pp0_7(28)                         ,--i--
      sum              => pp1_2_sum(28)                     ,--o--
      car              => pp1_2_car(27)                    );--o--
 pp1_2_csa_27: entity clib.c_prism_csa32  port map(  
      vd               => vdd,
      gd               => gnd,
      a                => pp0_5(27)                         ,--i--
      b                => pp0_6(27)                         ,--i--
      c                => pp0_7(27)                         ,--i--
      sum              => pp1_2_sum(27)                     ,--o--
      car              => pp1_2_car(26)                    );--o--
 pp1_2_csa_26: entity clib.c_prism_csa32  port map(  
      vd               => vdd,
      gd               => gnd,
      a                => pp0_5(26)                         ,--i--
      b                => pp0_6(26)                         ,--i--
      c                => pp0_7(26)                         ,--i--
      sum              => pp1_2_sum(26)                     ,--o--
      car              => pp1_2_car(25)                    );--o--
 pp1_2_csa_25: entity clib.c_prism_csa32  port map(  
      vd               => vdd,
      gd               => gnd,
      a                => pp0_5(25)                         ,--i--
      b                => pp0_6(25)                         ,--i--
      c                => pp0_7(25)                         ,--i--
      sum              => pp1_2_sum(25)                     ,--o--
      car              => pp1_2_car(24)                    );--o--
 pp1_2_csa_24: entity clib.c_prism_csa32  port map(  
      vd               => vdd,
      gd               => gnd,
      a                => pp0_5(24)                         ,--i--
      b                => pp0_6(24)                         ,--i--
      c                => pp0_7(24)                         ,--i--
      sum              => pp1_2_sum(24)                     ,--o--
      car              => pp1_2_car(23)                    );--o--
 pp1_2_csa_23: entity clib.c_prism_csa32  port map(  
      vd               => vdd,
      gd               => gnd,
      a                => pp0_5(23)                         ,--i--
      b                => pp0_6(23)                         ,--i--
      c                => pp0_7(23)                         ,--i--
      sum              => pp1_2_sum(23)                     ,--o--
      car              => pp1_2_car(22)                    );--o--
 pp1_2_csa_22: entity clib.c_prism_csa32  port map(  
      vd               => vdd,
      gd               => gnd,
      a                => pp0_5(22)                         ,--i--
      b                => pp0_6(22)                         ,--i--
      c                => pp0_7(22)                         ,--i--
      sum              => pp1_2_sum(22)                     ,--o--
      car              => pp1_2_car(21)                    );--o--
 pp1_2_csa_21: entity clib.c_prism_csa32  port map(  
      vd               => vdd,
      gd               => gnd,
      a                => pp0_5(21)                         ,--i--
      b                => pp0_6(21)                         ,--i--
      c                => pp0_7(21)                         ,--i--
      sum              => pp1_2_sum(21)                     ,--o--
      car              => pp1_2_car(20)                    );--o--
 pp1_2_csa_20: entity clib.c_prism_csa32  port map(  
      vd               => vdd,
      gd               => gnd,
      a                => pp0_5(20)                         ,--i--
      b                => pp0_6(20)                         ,--i--
      c                => pp0_7(20)                         ,--i--
      sum              => pp1_2_sum(20)                     ,--o--
      car              => pp1_2_car(19)                    );--o--
 pp1_2_csa_19: entity clib.c_prism_csa32  port map(  
      vd               => vdd,
      gd               => gnd,
      a                => pp0_5(19)                         ,--i--
      b                => pp0_6(19)                         ,--i--
      c                => pp0_7(19)                         ,--i--
      sum              => pp1_2_sum(19)                     ,--o--
      car              => pp1_2_car(18)                    );--o--
 pp1_2_csa_18: entity clib.c_prism_csa32  port map(  
      vd               => vdd,
      gd               => gnd,
      a                => pp0_5(18)                         ,--i--
      b                => pp0_6(18)                         ,--i--
      c                => pp0_7(18)                         ,--i--
      sum              => pp1_2_sum(18)                     ,--o--
      car              => pp1_2_car(17)                    );--o--
 pp1_2_csa_17: entity clib.c_prism_csa32  port map(  
      vd               => vdd,
      gd               => gnd,
      a                => pp0_5(17)                         ,--i--
      b                => pp0_6(17)                         ,--i--
      c                => pp0_7(17)                         ,--i--
      sum              => pp1_2_sum(17)                     ,--o--
      car              => pp1_2_car(16)                    );--o--
 pp1_2_csa_16: entity work.fuq_csa22_h2(fuq_csa22_h2) port map(  
      a                => pp0_5(16)                         ,--i--
      b                => pp0_6(16)                         ,--i--
      sum              => pp1_2_sum(16)                     ,--o--
      car              => pp1_2_car(15)                    );--o--
    pp1_2_sum(15)                    <= pp0_5(15)                        ;
    pp1_2_sum(14)                    <= pp0_5(14)                        ;


--=####################################################################
--=# compressor tree level 2
--=####################################################################

--= 0         1         2         3
--= 0123456789012345678901234567890123456
--==-------------------------------------
--  sssssssssssssssssssssssss_s______         pp1_0_sum
--  ccccccccccccccccccccccc_c________         pp1_0_car
--  ________sssssssssssssssssssssss_s         pp1_1_sum
--  222222223333333333333332312111101
--  sssssssssssssssssssssssssssssss_s         pp2_0_sum
--  cccccccccccccccccccccccc__c               pp2_0_car


--= 0         1         2         3
--= 0123456789012345678901234567890123456
--==-------------------------------------
--  _________ccccccccccccccccccc__c______     pp1_1_car
--  ______________sssssssssssssssssssssss     pp1_2_sum
--  _______________ccccccccccccccccccc__c     pp1_2_car
--           1111123333333333333223222112
--           ssssssssssssssssssssssssssss     pp2_1_sum
--               ccccccccccccccccc_ccc__c     pp2_1_car

--======================================================
--== compressor level 2 , row 0
--======================================================



    pp2_0_sum(32)                    <= pp1_1_sum(32)                    ;
    pp2_0_sum(31)                    <= tidn                             ;
    pp2_0_sum(30)                    <= pp1_1_sum(30)                    ;
    pp2_0_sum(29)                    <= pp1_1_sum(29)                    ;
    pp2_0_sum(28)                    <= pp1_1_sum(28)                    ;
    pp2_0_sum(27)                    <= pp1_1_sum(27)                    ;
    pp2_0_sum(26)                    <= pp1_0_sum(26)                    ;
    pp2_0_car(26)                    <= pp1_1_sum(26)                    ;
    pp2_0_sum(25)                    <= pp1_1_sum(25)                    ;
    pp2_0_car(25)                    <= tidn                             ;
    pp2_0_car(24)                    <= tidn                             ;
 pp2_0_csa_24: entity clib.c_prism_csa32  port map(  
      vd               => vdd,
      gd               => gnd,
      a                => pp1_0_sum(24)                     ,--i--
      b                => pp1_0_car(24)                     ,--i--
      c                => pp1_1_sum(24)                     ,--i--
      sum              => pp2_0_sum(24)                     ,--o--
      car              => pp2_0_car(23)                    );--o--
 pp2_0_csa_23: entity work.fuq_csa22_h2(fuq_csa22_h2) port map(  
      a                => pp1_0_sum(23)                     ,--i--
      b                => pp1_1_sum(23)                     ,--i--
      sum              => pp2_0_sum(23)                     ,--o--
      car              => pp2_0_car(22)                    );--o--
 pp2_0_csa_22: entity clib.c_prism_csa32  port map(  
      vd               => vdd,
      gd               => gnd,
      a                => pp1_0_sum(22)                     ,--i--
      b                => pp1_0_car(22)                     ,--i--
      c                => pp1_1_sum(22)                     ,--i--
      sum              => pp2_0_sum(22)                     ,--o--
      car              => pp2_0_car(21)                    );--o--
 pp2_0_csa_21: entity clib.c_prism_csa32  port map(  
      vd               => vdd,
      gd               => gnd,
      a                => pp1_0_sum(21)                     ,--i--
      b                => pp1_0_car(21)                     ,--i--
      c                => pp1_1_sum(21)                     ,--i--
      sum              => pp2_0_sum(21)                     ,--o--
      car              => pp2_0_car(20)                    );--o--
 pp2_0_csa_20: entity clib.c_prism_csa32  port map(  
      vd               => vdd,
      gd               => gnd,
      a                => pp1_0_sum(20)                     ,--i--
      b                => pp1_0_car(20)                     ,--i--
      c                => pp1_1_sum(20)                     ,--i--
      sum              => pp2_0_sum(20)                     ,--o--
      car              => pp2_0_car(19)                    );--o--
 pp2_0_csa_19: entity clib.c_prism_csa32  port map(  
      vd               => vdd,
      gd               => gnd,
      a                => pp1_0_sum(19)                     ,--i--
      b                => pp1_0_car(19)                     ,--i--
      c                => pp1_1_sum(19)                     ,--i--
      sum              => pp2_0_sum(19)                     ,--o--
      car              => pp2_0_car(18)                    );--o--
 pp2_0_csa_18: entity clib.c_prism_csa32  port map(  
      vd               => vdd,
      gd               => gnd,
      a                => pp1_0_sum(18)                     ,--i--
      b                => pp1_0_car(18)                     ,--i--
      c                => pp1_1_sum(18)                     ,--i--
      sum              => pp2_0_sum(18)                     ,--o--
      car              => pp2_0_car(17)                    );--o--
 pp2_0_csa_17: entity clib.c_prism_csa32  port map(  
      vd               => vdd,
      gd               => gnd,
      a                => pp1_0_sum(17)                     ,--i--
      b                => pp1_0_car(17)                     ,--i--
      c                => pp1_1_sum(17)                     ,--i--
      sum              => pp2_0_sum(17)                     ,--o--
      car              => pp2_0_car(16)                    );--o--
 pp2_0_csa_16: entity clib.c_prism_csa32  port map(  
      vd               => vdd,
      gd               => gnd,
      a                => pp1_0_sum(16)                     ,--i--
      b                => pp1_0_car(16)                     ,--i--
      c                => pp1_1_sum(16)                     ,--i--
      sum              => pp2_0_sum(16)                     ,--o--
      car              => pp2_0_car(15)                    );--o--
 pp2_0_csa_15: entity clib.c_prism_csa32  port map(  
      vd               => vdd,
      gd               => gnd,
      a                => pp1_0_sum(15)                     ,--i--
      b                => pp1_0_car(15)                     ,--i--
      c                => pp1_1_sum(15)                     ,--i--
      sum              => pp2_0_sum(15)                     ,--o--
      car              => pp2_0_car(14)                    );--o--
 pp2_0_csa_14: entity clib.c_prism_csa32  port map(  
      vd               => vdd,
      gd               => gnd,
      a                => pp1_0_sum(14)                     ,--i--
      b                => pp1_0_car(14)                     ,--i--
      c                => pp1_1_sum(14)                     ,--i--
      sum              => pp2_0_sum(14)                     ,--o--
      car              => pp2_0_car(13)                    );--o--
 pp2_0_csa_13: entity clib.c_prism_csa32  port map(  
      vd               => vdd,
      gd               => gnd,
      a                => pp1_0_sum(13)                     ,--i--
      b                => pp1_0_car(13)                     ,--i--
      c                => pp1_1_sum(13)                     ,--i--
      sum              => pp2_0_sum(13)                     ,--o--
      car              => pp2_0_car(12)                    );--o--
 pp2_0_csa_12: entity clib.c_prism_csa32  port map(  
      vd               => vdd,
      gd               => gnd,
      a                => pp1_0_sum(12)                     ,--i--
      b                => pp1_0_car(12)                     ,--i--
      c                => pp1_1_sum(12)                     ,--i--
      sum              => pp2_0_sum(12)                     ,--o--
      car              => pp2_0_car(11)                    );--o--
 pp2_0_csa_11: entity clib.c_prism_csa32  port map(  
      vd               => vdd,
      gd               => gnd,
      a                => pp1_0_sum(11)                     ,--i--
      b                => pp1_0_car(11)                     ,--i--
      c                => pp1_1_sum(11)                     ,--i--
      sum              => pp2_0_sum(11)                     ,--o--
      car              => pp2_0_car(10)                    );--o--
 pp2_0_csa_10: entity clib.c_prism_csa32  port map(  
      vd               => vdd,
      gd               => gnd,
      a                => pp1_0_sum(10)                     ,--i--
      b                => pp1_0_car(10)                     ,--i--
      c                => pp1_1_sum(10)                     ,--i--
      sum              => pp2_0_sum(10)                     ,--o--
      car              => pp2_0_car(9)                     );--o--
 pp2_0_csa_9: entity clib.c_prism_csa32  port map(  
      vd               => vdd,
      gd               => gnd,
      a                => pp1_0_sum(9)                      ,--i--
      b                => pp1_0_car(9)                      ,--i--
      c                => pp1_1_sum(9)                      ,--i--
      sum              => pp2_0_sum(9)                      ,--o--
      car              => pp2_0_car(8)                     );--o--
 pp2_0_csa_8: entity clib.c_prism_csa32  port map(  
      vd               => vdd,
      gd               => gnd,
      a                => pp1_0_sum(8)                      ,--i--
      b                => pp1_0_car(8)                      ,--i--
      c                => pp1_1_sum(8)                      ,--i--
      sum              => pp2_0_sum(8)                      ,--o--
      car              => pp2_0_car(7)                     );--o--
 pp2_0_csa_7: entity work.fuq_csa22_h2(fuq_csa22_h2) port map(  
      a                => pp1_0_sum(7)                      ,--i--
      b                => pp1_0_car(7)                      ,--i--
      sum              => pp2_0_sum(7)                      ,--o--
      car              => pp2_0_car(6)                     );--o--
 pp2_0_csa_6: entity work.fuq_csa22_h2(fuq_csa22_h2) port map(  
      a                => pp1_0_sum(6)                      ,--i--
      b                => pp1_0_car(6)                      ,--i--
      sum              => pp2_0_sum(6)                      ,--o--
      car              => pp2_0_car(5)                     );--o--
 pp2_0_csa_5: entity work.fuq_csa22_h2(fuq_csa22_h2) port map(  
      a                => pp1_0_sum(5)                      ,--i--
      b                => pp1_0_car(5)                      ,--i--
      sum              => pp2_0_sum(5)                      ,--o--
      car              => pp2_0_car(4)                     );--o--
 pp2_0_csa_4: entity work.fuq_csa22_h2(fuq_csa22_h2) port map(  
      a                => pp1_0_sum(4)                      ,--i--
      b                => pp1_0_car(4)                      ,--i--
      sum              => pp2_0_sum(4)                      ,--o--
      car              => pp2_0_car(3)                     );--o--
 pp2_0_csa_3: entity work.fuq_csa22_h2(fuq_csa22_h2) port map(  
      a                => pp1_0_sum(3)                      ,--i--
      b                => pp1_0_car(3)                      ,--i--
      sum              => pp2_0_sum(3)                      ,--o--
      car              => pp2_0_car(2)                     );--o--
 pp2_0_csa_2: entity work.fuq_csa22_h2(fuq_csa22_h2) port map(  
      a                => pp1_0_sum(2)                      ,--i--
      b                => pp1_0_car(2)                      ,--i--
      sum              => pp2_0_sum(2)                      ,--o--
      car              => pp2_0_car(1)                     );--o--
 pp2_0_csa_1: entity work.fuq_csa22_h2(fuq_csa22_h2) port map(  
      a                => pp1_0_sum(1)                      ,--i--
      b                => pp1_0_car(1)                      ,--i--
      sum              => pp2_0_sum(1)                      ,--o--
      car              => pp2_0_car(0)                     );--o--
 pp2_0_csa_0: entity work.fuq_csa22_h2(fuq_csa22_h2) port map(  
      a                => pp1_0_sum(0)                      ,--i--
      b                => pp1_0_car(0)                      ,--i--
      sum              => pp2_0_sum(0)                      ,--o--
      car              => pp2_0_car_unused                 );--o--

--======================================================
--== compressor level 2 , row 1
--======================================================

--======================================================
--== compressor level 2 , row 1
--======================================================

    pp2_1_sum(36)                    <= pp1_2_sum(36)                    ;
    pp2_1_car(36)                    <= pp1_2_car(36)                    ;
    pp2_1_sum(35)                    <= pp1_2_sum(35)                    ;
    pp2_1_car(35)                    <= tidn                             ;
    pp2_1_sum(34)                    <= pp1_2_sum(34)                    ;
    pp2_1_car(34)                    <= tidn                             ;
    pp2_1_sum(33)                    <= pp1_2_sum(33)                    ;
    pp2_1_car(33)                    <= pp1_2_car(33)                    ;
    pp2_1_sum(32)                    <= pp1_2_sum(32)                    ;
    pp2_1_car(32)                    <= pp1_2_car(32)                    ;
    pp2_1_sum(31)                    <= pp1_2_sum(31)                    ;
    pp2_1_car(31)                    <= pp1_2_car(31)                    ;
    pp2_1_car(30)                    <= tidn                             ;
 pp2_1_csa_30: entity clib.c_prism_csa32  port map(  
      vd               => vdd,
      gd               => gnd,
      a                => pp1_1_car(30)                     ,--i--
      b                => pp1_2_sum(30)                     ,--i--
      c                => pp1_2_car(30)                     ,--i--
      sum              => pp2_1_sum(30)                     ,--o--
      car              => pp2_1_car(29)                    );--o--
 pp2_1_csa_29: entity work.fuq_csa22_h2(fuq_csa22_h2) port map(  
      a                => pp1_2_sum(29)                     ,--i--
      b                => pp1_2_car(29)                     ,--i--
      sum              => pp2_1_sum(29)                     ,--o--
      car              => pp2_1_car(28)                    );--o--
 pp2_1_csa_28: entity work.fuq_csa22_h2(fuq_csa22_h2) port map(  
      a                => pp1_2_sum(28)                     ,--i--
      b                => pp1_2_car(28)                     ,--i--
      sum              => pp2_1_sum(28)                     ,--o--
      car              => pp2_1_car(27)                    );--o--
 pp2_1_csa_27: entity clib.c_prism_csa32  port map(  
      vd               => vdd,
      gd               => gnd,
      a                => pp1_1_car(27)                     ,--i--
      b                => pp1_2_sum(27)                     ,--i--
      c                => pp1_2_car(27)                     ,--i--
      sum              => pp2_1_sum(27)                     ,--o--
      car              => pp2_1_car(26)                    );--o--
 pp2_1_csa_26: entity clib.c_prism_csa32  port map(  
      vd               => vdd,
      gd               => gnd,
      a                => pp1_1_car(26)                     ,--i--
      b                => pp1_2_sum(26)                     ,--i--
      c                => pp1_2_car(26)                     ,--i--
      sum              => pp2_1_sum(26)                     ,--o--
      car              => pp2_1_car(25)                    );--o--
 pp2_1_csa_25: entity clib.c_prism_csa32  port map(  
      vd               => vdd,
      gd               => gnd,
      a                => pp1_1_car(25)                     ,--i--
      b                => pp1_2_sum(25)                     ,--i--
      c                => pp1_2_car(25)                     ,--i--
      sum              => pp2_1_sum(25)                     ,--o--
      car              => pp2_1_car(24)                    );--o--
 pp2_1_csa_24: entity clib.c_prism_csa32  port map(  
      vd               => vdd,
      gd               => gnd,
      a                => pp1_1_car(24)                     ,--i--
      b                => pp1_2_sum(24)                     ,--i--
      c                => pp1_2_car(24)                     ,--i--
      sum              => pp2_1_sum(24)                     ,--o--
      car              => pp2_1_car(23)                    );--o--
 pp2_1_csa_23: entity clib.c_prism_csa32  port map(  
      vd               => vdd,
      gd               => gnd,
      a                => pp1_1_car(23)                     ,--i--
      b                => pp1_2_sum(23)                     ,--i--
      c                => pp1_2_car(23)                     ,--i--
      sum              => pp2_1_sum(23)                     ,--o--
      car              => pp2_1_car(22)                    );--o--
 pp2_1_csa_22: entity clib.c_prism_csa32  port map(  
      vd               => vdd,
      gd               => gnd,
      a                => pp1_1_car(22)                     ,--i--
      b                => pp1_2_sum(22)                     ,--i--
      c                => pp1_2_car(22)                     ,--i--
      sum              => pp2_1_sum(22)                     ,--o--
      car              => pp2_1_car(21)                    );--o--
 pp2_1_csa_21: entity clib.c_prism_csa32  port map(  
      vd               => vdd,
      gd               => gnd,
      a                => pp1_1_car(21)                     ,--i--
      b                => pp1_2_sum(21)                     ,--i--
      c                => pp1_2_car(21)                     ,--i--
      sum              => pp2_1_sum(21)                     ,--o--
      car              => pp2_1_car(20)                    );--o--
 pp2_1_csa_20: entity clib.c_prism_csa32  port map(  
      vd               => vdd,
      gd               => gnd,
      a                => pp1_1_car(20)                     ,--i--
      b                => pp1_2_sum(20)                     ,--i--
      c                => pp1_2_car(20)                     ,--i--
      sum              => pp2_1_sum(20)                     ,--o--
      car              => pp2_1_car(19)                    );--o--
 pp2_1_csa_19: entity clib.c_prism_csa32  port map(  
      vd               => vdd,
      gd               => gnd,
      a                => pp1_1_car(19)                     ,--i--
      b                => pp1_2_sum(19)                     ,--i--
      c                => pp1_2_car(19)                     ,--i--
      sum              => pp2_1_sum(19)                     ,--o--
      car              => pp2_1_car(18)                    );--o--
 pp2_1_csa_18: entity clib.c_prism_csa32  port map(  
      vd               => vdd,
      gd               => gnd,
      a                => pp1_1_car(18)                     ,--i--
      b                => pp1_2_sum(18)                     ,--i--
      c                => pp1_2_car(18)                     ,--i--
      sum              => pp2_1_sum(18)                     ,--o--
      car              => pp2_1_car(17)                    );--o--
 pp2_1_csa_17: entity clib.c_prism_csa32  port map(  
      vd               => vdd,
      gd               => gnd,
      a                => pp1_1_car(17)                     ,--i--
      b                => pp1_2_sum(17)                     ,--i--
      c                => pp1_2_car(17)                     ,--i--
      sum              => pp2_1_sum(17)                     ,--o--
      car              => pp2_1_car(16)                    );--o--
 pp2_1_csa_16: entity clib.c_prism_csa32  port map(  
      vd               => vdd,
      gd               => gnd,
      a                => pp1_1_car(16)                     ,--i--
      b                => pp1_2_sum(16)                     ,--i--
      c                => pp1_2_car(16)                     ,--i--
      sum              => pp2_1_sum(16)                     ,--o--
      car              => pp2_1_car(15)                    );--o--
 pp2_1_csa_15: entity clib.c_prism_csa32  port map(  
      vd               => vdd,
      gd               => gnd,
      a                => pp1_1_car(15)                     ,--i--
      b                => pp1_2_sum(15)                     ,--i--
      c                => pp1_2_car(15)                     ,--i--
      sum              => pp2_1_sum(15)                     ,--o--
      car              => pp2_1_car(14)                    );--o--
 pp2_1_csa_14: entity work.fuq_csa22_h2(fuq_csa22_h2) port map(  
      a                => pp1_1_car(14)                     ,--i--
      b                => pp1_2_sum(14)                     ,--i--
      sum              => pp2_1_sum(14)                     ,--o--
      car              => pp2_1_car(13)                    );--o--
    pp2_1_sum(13)                    <= pp1_1_car(13)                    ;
    pp2_1_sum(12)                    <= pp1_1_car(12)                    ;
    pp2_1_sum(11)                    <= pp1_1_car(11)                    ;
    pp2_1_sum(10)                    <= pp1_1_car(10)                    ;
    pp2_1_sum(9)                     <= pp1_1_car(9)                     ;





--=####################################################################
--=# compressor tree level 3
--=####################################################################

--= 0         1         2         3
--= 0123456789012345678901234567890123456
--==-------------------------------------
--  sssssssssssssssssssssssssssssss_s         pp2_0_sum
--  cccccccccccccccccccccccc__c               pp2_0_car
--           ssssssssssssssssssssssssssss     pp2_1_sum
--               ccccccccccccccccc_ccc__c     pp2_1_car
--  2222222223333444444444443343332232112

--======================================================
--== compressor level 3 , row 0
--======================================================

 pp3_0_csa_36: entity work.fuq_csa22_h2(fuq_csa22_h2) port map(  
      a                => pp2_1_sum(36)                     ,--i--
      b                => pp2_1_car(36)                     ,--i--
      sum              => pp3_0_sum(36)                     ,--o--
      car              => pp3_0_car(35)                    );--o--
    pp3_0_sum(35)                    <= pp2_1_sum(35)                    ;
    pp3_0_sum(34)                    <= pp2_1_sum(34)                    ;
    pp3_0_car(34)                    <= tidn                             ;
    pp3_0_sum(33)                    <= pp2_1_sum(33)                    ;
    pp3_0_car(33)                    <= pp2_1_car(33)                    ;
    pp3_0_car(32)                    <= tidn                             ;
 pp3_0_csa_32: entity clib.c_prism_csa32  port map(  
      vd               => vdd,
      gd               => gnd,
      a                => pp2_0_sum(32)                     ,--i--
      b                => pp2_1_sum(32)                     ,--i--
      c                => pp2_1_car(32)                     ,--i--
      sum              => pp3_0_sum(32)                     ,--o--
      car              => pp3_0_car(31)                    );--o--
 pp3_0_csa_31: entity work.fuq_csa22_h2(fuq_csa22_h2) port map(  
      a                => pp2_1_sum(31)                     ,--i--
      b                => pp2_1_car(31)                     ,--i--
      sum              => pp3_0_sum(31)                     ,--o--
      car              => pp3_0_car(30)                    );--o--
 pp3_0_csa_30: entity work.fuq_csa22_h2(fuq_csa22_h2) port map(  
      a                => pp2_0_sum(30)                     ,--i--
      b                => pp2_1_sum(30)                     ,--i--
      sum              => pp3_0_sum(30)                     ,--o--
      car              => pp3_0_car(29)                    );--o--
 pp3_0_csa_29: entity clib.c_prism_csa32  port map(  
      vd               => vdd,
      gd               => gnd,
      a                => pp2_0_sum(29)                     ,--i--
      b                => pp2_1_sum(29)                     ,--i--
      c                => pp2_1_car(29)                     ,--i--
      sum              => pp3_0_sum(29)                     ,--o--
      car              => pp3_0_car(28)                    );--o--
 pp3_0_csa_28: entity clib.c_prism_csa32  port map(  
      vd               => vdd,
      gd               => gnd,
      a                => pp2_0_sum(28)                     ,--i--
      b                => pp2_1_sum(28)                     ,--i--
      c                => pp2_1_car(28)                     ,--i--
      sum              => pp3_0_sum(28)                     ,--o--
      car              => pp3_0_car(27)                    );--o--
 pp3_0_csa_27: entity clib.c_prism_csa32  port map(  
      vd               => vdd,
      gd               => gnd,
      a                => pp2_0_sum(27)                     ,--i--
      b                => pp2_1_sum(27)                     ,--i--
      c                => pp2_1_car(27)                     ,--i--
      sum              => pp3_0_sum(27)                     ,--o--
      car              => pp3_0_car(26)                    );--o--
 pp3_0_csa_26: entity clib.c_prism_csa42  port map(  -- MLT42_X1_A12TH
      vd               => vdd,
      gd               => gnd,
      a                => pp2_0_sum(26)                     ,--i--
      b                => pp2_0_car(26)                     ,--i--
      c                => pp2_1_sum(26)                     ,--i--
      d                => pp2_1_car(26)                     ,--i--
      ki               => tidn                              ,--i--
      ko               => pp3_0_ko(25)                      ,--i--
      sum              => pp3_0_sum(26)                     ,--o--
      car              => pp3_0_car(25)                    );--o--
 pp3_0_csa_25: entity clib.c_prism_csa42  port map(  
      vd               => vdd,
      gd               => gnd,
      a                => pp2_0_sum(25)                     ,--i--
      b                => tidn                              ,--i--
      c                => pp2_1_sum(25)                     ,--i--
      d                => pp2_1_car(25)                     ,--i--
      ki               => pp3_0_ko(25)                      ,--i--
      ko               => pp3_0_ko(24)                      ,--i--
      sum              => pp3_0_sum(25)                     ,--o--
      car              => pp3_0_car(24)                    );--o--
 pp3_0_csa_24: entity clib.c_prism_csa42  port map(  
      vd               => vdd,
      gd               => gnd,
      a                => pp2_0_sum(24)                     ,--i--
      b                => tidn                              ,--i--
      c                => pp2_1_sum(24)                     ,--i--
      d                => pp2_1_car(24)                     ,--i--
      ki               => pp3_0_ko(24)                      ,--i--
      ko               => pp3_0_ko(23)                      ,--i--
      sum              => pp3_0_sum(24)                     ,--o--
      car              => pp3_0_car(23)                    );--o--
 pp3_0_csa_23: entity clib.c_prism_csa42  port map(  
      vd               => vdd,
      gd               => gnd,
      a                => pp2_0_sum(23)                     ,--i--
      b                => pp2_0_car(23)                     ,--i--
      c                => pp2_1_sum(23)                     ,--i--
      d                => pp2_1_car(23)                     ,--i--
      ki               => pp3_0_ko(23)                      ,--i--
      ko               => pp3_0_ko(22)                      ,--i--
      sum              => pp3_0_sum(23)                     ,--o--
      car              => pp3_0_car(22)                    );--o--
 pp3_0_csa_22: entity clib.c_prism_csa42  port map(  
      vd               => vdd,
      gd               => gnd,
      a                => pp2_0_sum(22)                     ,--i--
      b                => pp2_0_car(22)                     ,--i--
      c                => pp2_1_sum(22)                     ,--i--
      d                => pp2_1_car(22)                     ,--i--
      ki               => pp3_0_ko(22)                      ,--i--
      ko               => pp3_0_ko(21)                      ,--i--
      sum              => pp3_0_sum(22)                     ,--o--
      car              => pp3_0_car(21)                    );--o--
 pp3_0_csa_21: entity clib.c_prism_csa42  port map(  
      vd               => vdd,
      gd               => gnd,
      a                => pp2_0_sum(21)                     ,--i--
      b                => pp2_0_car(21)                     ,--i--
      c                => pp2_1_sum(21)                     ,--i--
      d                => pp2_1_car(21)                     ,--i--
      ki               => pp3_0_ko(21)                      ,--i--
      ko               => pp3_0_ko(20)                      ,--i--
      sum              => pp3_0_sum(21)                     ,--o--
      car              => pp3_0_car(20)                    );--o--
 pp3_0_csa_20: entity clib.c_prism_csa42  port map(  
      vd               => vdd,
      gd               => gnd,
      a                => pp2_0_sum(20)                     ,--i--
      b                => pp2_0_car(20)                     ,--i--
      c                => pp2_1_sum(20)                     ,--i--
      d                => pp2_1_car(20)                     ,--i--
      ki               => pp3_0_ko(20)                      ,--i--
      ko               => pp3_0_ko(19)                      ,--i--
      sum              => pp3_0_sum(20)                     ,--o--
      car              => pp3_0_car(19)                    );--o--
 pp3_0_csa_19: entity clib.c_prism_csa42  port map(  
      vd               => vdd,
      gd               => gnd,
      a                => pp2_0_sum(19)                     ,--i--
      b                => pp2_0_car(19)                     ,--i--
      c                => pp2_1_sum(19)                     ,--i--
      d                => pp2_1_car(19)                     ,--i--
      ki               => pp3_0_ko(19)                      ,--i--
      ko               => pp3_0_ko(18)                      ,--i--
      sum              => pp3_0_sum(19)                     ,--o--
      car              => pp3_0_car(18)                    );--o--
 pp3_0_csa_18: entity clib.c_prism_csa42  port map(  
      vd               => vdd,
      gd               => gnd,
      a                => pp2_0_sum(18)                     ,--i--
      b                => pp2_0_car(18)                     ,--i--
      c                => pp2_1_sum(18)                     ,--i--
      d                => pp2_1_car(18)                     ,--i--
      ki               => pp3_0_ko(18)                      ,--i--
      ko               => pp3_0_ko(17)                      ,--i--
      sum              => pp3_0_sum(18)                     ,--o--
      car              => pp3_0_car(17)                    );--o--
 pp3_0_csa_17: entity clib.c_prism_csa42  port map(  
      vd               => vdd,
      gd               => gnd,
      a                => pp2_0_sum(17)                     ,--i--
      b                => pp2_0_car(17)                     ,--i--
      c                => pp2_1_sum(17)                     ,--i--
      d                => pp2_1_car(17)                     ,--i--
      ki               => pp3_0_ko(17)                      ,--i--
      ko               => pp3_0_ko(16)                      ,--i--
      sum              => pp3_0_sum(17)                     ,--o--
      car              => pp3_0_car(16)                    );--o--
 pp3_0_csa_16: entity clib.c_prism_csa42  port map(  
      vd               => vdd,
      gd               => gnd,
      a                => pp2_0_sum(16)                     ,--i--
      b                => pp2_0_car(16)                     ,--i--
      c                => pp2_1_sum(16)                     ,--i--
      d                => pp2_1_car(16)                     ,--i--
      ki               => pp3_0_ko(16)                      ,--i--
      ko               => pp3_0_ko(15)                      ,--i--
      sum              => pp3_0_sum(16)                     ,--o--
      car              => pp3_0_car(15)                    );--o--
 pp3_0_csa_15: entity clib.c_prism_csa42  port map(  
      vd               => vdd,
      gd               => gnd,
      a                => pp2_0_sum(15)                     ,--i--
      b                => pp2_0_car(15)                     ,--i--
      c                => pp2_1_sum(15)                     ,--i--
      d                => pp2_1_car(15)                     ,--i--
      ki               => pp3_0_ko(15)                      ,--i--
      ko               => pp3_0_ko(14)                      ,--i--
      sum              => pp3_0_sum(15)                     ,--o--
      car              => pp3_0_car(14)                    );--o--
 pp3_0_csa_14: entity clib.c_prism_csa42  port map(  
      vd               => vdd,
      gd               => gnd,
      a                => pp2_0_sum(14)                     ,--i--
      b                => pp2_0_car(14)                     ,--i--
      c                => pp2_1_sum(14)                     ,--i--
      d                => pp2_1_car(14)                     ,--i--
      ki               => pp3_0_ko(14)                      ,--i--
      ko               => pp3_0_ko(13)                      ,--i--
      sum              => pp3_0_sum(14)                     ,--o--
      car              => pp3_0_car(13)                    );--o--
 pp3_0_csa_13: entity clib.c_prism_csa42  port map(  
      vd               => vdd,
      gd               => gnd,
      a                => pp2_0_sum(13)                     ,--i--
      b                => pp2_0_car(13)                     ,--i--
      c                => pp2_1_sum(13)                     ,--i--
      d                => pp2_1_car(13)                     ,--i--
      ki               => pp3_0_ko(13)                      ,--i--
      ko               => pp3_0_ko(12)                      ,--i--
      sum              => pp3_0_sum(13)                     ,--o--
      car              => pp3_0_car(12)                    );--o--
 pp3_0_csa_12: entity clib.c_prism_csa42  port map(  
      vd               => vdd,
      gd               => gnd,
      a                => pp2_0_sum(12)                     ,--i--
      b                => pp2_0_car(12)                     ,--i--
      c                => pp2_1_sum(12)                     ,--i--
      d                => tidn                              ,--i--
      ki               => pp3_0_ko(12)                      ,--i--
      ko               => pp3_0_ko(11)                      ,--i--
      sum              => pp3_0_sum(12)                     ,--o--
      car              => pp3_0_car(11)                    );--o--
 pp3_0_csa_11: entity clib.c_prism_csa42  port map(  
      vd               => vdd,
      gd               => gnd,
      a                => pp2_0_sum(11)                     ,--i--
      b                => pp2_0_car(11)                     ,--i--
      c                => pp2_1_sum(11)                     ,--i--
      d                => tidn                              ,--i--
      ki               => pp3_0_ko(11)                      ,--i--
      ko               => pp3_0_ko(10)                      ,--i--
      sum              => pp3_0_sum(11)                     ,--o--
      car              => pp3_0_car(10)                    );--o--
 pp3_0_csa_10: entity clib.c_prism_csa42  port map(  
      vd               => vdd,
      gd               => gnd,
      a                => pp2_0_sum(10)                     ,--i--
      b                => pp2_0_car(10)                     ,--i--
      c                => pp2_1_sum(10)                     ,--i--
      d                => tidn                              ,--i--
      ki               => pp3_0_ko(10)                      ,--i--
      ko               => pp3_0_ko(9)                       ,--i--
      sum              => pp3_0_sum(10)                     ,--o--
      car              => pp3_0_car(9)                     );--o--
 pp3_0_csa_9: entity clib.c_prism_csa42  port map(  
      vd               => vdd,
      gd               => gnd,
      a                => pp2_0_sum(9)                      ,--i--
      b                => pp2_0_car(9)                      ,--i--
      c                => pp2_1_sum(9)                      ,--i--
      d                => tidn                              ,--i--
      ki               => pp3_0_ko(9)                       ,--i--
      ko               => pp3_0_ko(8)                       ,--i--
      sum              => pp3_0_sum(9)                      ,--o--
      car              => pp3_0_car(8)                     );--o--
 pp3_0_csa_8: entity clib.c_prism_csa32  port map(  
      vd               => vdd,
      gd               => gnd,
      a                => pp2_0_sum(8)                      ,--i--
      b                => pp2_0_car(8)                      ,--i--
      c                => pp3_0_ko(8)                       ,--i--
      sum              => pp3_0_sum(8)                      ,--o--
      car              => pp3_0_car(7)                     );--o--
 pp3_0_csa_7: entity work.fuq_csa22_h2(fuq_csa22_h2) port map(  
      a                => pp2_0_sum(7)                      ,--i--
      b                => pp2_0_car(7)                      ,--i--
      sum              => pp3_0_sum(7)                      ,--o--
      car              => pp3_0_car(6)                     );--o--
 pp3_0_csa_6: entity work.fuq_csa22_h2(fuq_csa22_h2) port map(  
      a                => pp2_0_sum(6)                      ,--i--
      b                => pp2_0_car(6)                      ,--i--
      sum              => pp3_0_sum(6)                      ,--o--
      car              => pp3_0_car(5)                     );--o--
 pp3_0_csa_5: entity work.fuq_csa22_h2(fuq_csa22_h2) port map(  
      a                => pp2_0_sum(5)                      ,--i--
      b                => pp2_0_car(5)                      ,--i--
      sum              => pp3_0_sum(5)                      ,--o--
      car              => pp3_0_car(4)                     );--o--
 pp3_0_csa_4: entity work.fuq_csa22_h2(fuq_csa22_h2) port map(  
      a                => pp2_0_sum(4)                      ,--i--
      b                => pp2_0_car(4)                      ,--i--
      sum              => pp3_0_sum(4)                      ,--o--
      car              => pp3_0_car(3)                     );--o--
 pp3_0_csa_3: entity work.fuq_csa22_h2(fuq_csa22_h2) port map(  
      a                => pp2_0_sum(3)                      ,--i--
      b                => pp2_0_car(3)                      ,--i--
      sum              => pp3_0_sum(3)                      ,--o--
      car              => pp3_0_car(2)                     );--o--
 pp3_0_csa_2: entity work.fuq_csa22_h2(fuq_csa22_h2) port map(  
      a                => pp2_0_sum(2)                      ,--i--
      b                => pp2_0_car(2)                      ,--i--
      sum              => pp3_0_sum(2)                      ,--o--
      car              => pp3_0_car(1)                     );--o--
 pp3_0_csa_1: entity work.fuq_csa22_h2(fuq_csa22_h2) port map(  
      a                => pp2_0_sum(1)                      ,--i--
      b                => pp2_0_car(1)                      ,--i--
      sum              => pp3_0_sum(1)                      ,--o--
      car              => pp3_0_car(0)                     );--o--
 pp3_0_csa_0: entity work.fuq_csa22_h2(fuq_csa22_h2) port map(  
      a                => pp2_0_sum(0)                      ,--i--
      b                => pp2_0_car(0)                      ,--i--
      sum              => pp3_0_sum(0)                      ,--o--
      car              => pp3_0_car_unused                 );--o--


--=====================================================================


   tbl_sum(0 to 36) <= pp3_0_sum(0 to 36); 
   tbl_car(0 to 35) <= pp3_0_car(0 to 35); 



end; -- fuq_tblmul ARCHITECTURE
