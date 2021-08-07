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
                  generic( expand_type  : integer := 2  ); 
port(
       vdd                                       :inout power_logic;
       gnd                                       :inout power_logic;
       x          :in  std_ulogic_vector(1 to 15); 
       y          :in  std_ulogic_vector(7 to 22); 
       z          :in  std_ulogic_vector(0 to 20); 


       tbl_sum    :out std_ulogic_vector(0 to 36); 
       tbl_car    :out std_ulogic_vector(0 to 35)
);



end fuq_tblmul; 

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




 bd0: entity work.fuq_tblmul_bthdcd(fuq_tblmul_bthdcd) port map( 
        i0               => tidn                      ,
        i1               => x(1)                      ,
        i2               => x(2)                      ,
        s_neg            =>   s_neg(0)                ,
        s_x              =>     s_x(0)                ,
        s_x2             =>    s_x2(0)               );

 bd1: entity work.fuq_tblmul_bthdcd(fuq_tblmul_bthdcd) port map( 
        i0               => x(2)                      ,
        i1               => x(3)                      ,
        i2               => x(4)                      ,
        s_neg            =>   s_neg(1)                ,
        s_x              =>     s_x(1)                ,
        s_x2             =>    s_x2(1)               );

 bd2: entity work.fuq_tblmul_bthdcd(fuq_tblmul_bthdcd) port map( 
        i0               => x(4)                      ,
        i1               => x(5)                      ,
        i2               => x(6)                      ,
        s_neg            =>   s_neg(2)                ,
        s_x              =>     s_x(2)                ,
        s_x2             =>    s_x2(2)               );

 bd3: entity work.fuq_tblmul_bthdcd(fuq_tblmul_bthdcd) port map( 
        i0               => x(6)                      ,
        i1               => x(7)                      ,
        i2               => x(8)                      ,
        s_neg            =>   s_neg(3)                ,
        s_x              =>     s_x(3)                ,
        s_x2             =>    s_x2(3)               );

 bd4: entity work.fuq_tblmul_bthdcd(fuq_tblmul_bthdcd) port map( 
        i0               => x(8)                      ,
        i1               => x(9)                      ,
        i2               => x(10)                     ,
        s_neg            =>   s_neg(4)                ,
        s_x              =>     s_x(4)                ,
        s_x2             =>    s_x2(4)               );

 bd5: entity work.fuq_tblmul_bthdcd(fuq_tblmul_bthdcd) port map( 
        i0               => x(10)                     ,
        i1               => x(11)                     ,
        i2               => x(12)                     ,
        s_neg            =>   s_neg(5)                ,
        s_x              =>     s_x(5)                ,
        s_x2             =>    s_x2(5)               );

 bd6: entity work.fuq_tblmul_bthdcd(fuq_tblmul_bthdcd) port map( 
        i0               => x(12)                     ,
        i1               => x(13)                     ,
        i2               => x(14)                     ,
        s_neg            =>   s_neg(6)                ,
        s_x              =>     s_x(6)                ,
        s_x2             =>    s_x2(6)               );

 bd7: entity work.fuq_tblmul_bthdcd(fuq_tblmul_bthdcd) port map( 
        i0               => x(14)                     ,
        i1               => x(15)                     ,
        i2               => tidn                      ,
        s_neg            =>   s_neg(7)                ,
        s_x              =>     s_x(7)                ,
        s_x2             =>    s_x2(7)               );






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
        s_neg            => tidn                    ,
        s_x              => s_x(0)                  ,
        s_x2             => s_x2(0)                 ,
        x                => y(7 to 22)              ,
        q                => pp0_0(6 to 22)         );
                            pp0_0(23) <= tidn;
                            pp0_0(24) <= sub_adj_lsb(1);

                            pp0_1(6)  <= tiup;
                            pp0_1(7)  <= sub_adj_msb_b(1);
 bm1: entity work.fuq_tblmul_bthrow(fuq_tblmul_bthrow) port map( 
        s_neg            => s_neg(1)                ,
        s_x              =>   s_x(1)                ,
        s_x2             =>  s_x2(1)                ,
        x                => y(7 to 22)              ,
        q                => pp0_1(8 to 24)         );
                            pp0_1(25) <= tidn;
                            pp0_1(26) <= sub_adj_lsb(2);

                            pp0_2(8) <= tiup;
                            pp0_2(9) <= sub_adj_msb_b(2);
 bm2: entity work.fuq_tblmul_bthrow(fuq_tblmul_bthrow) port map( 
        s_neg            => s_neg(2)                ,
        s_x              =>   s_x(2)                ,
        s_x2             =>  s_x2(2)                ,
        x                => y(7 to 22)              ,
        q                => pp0_2(10 to 26)        );
                            pp0_2(27) <= tidn;
                            pp0_2(28) <= sub_adj_lsb(3);

                            pp0_3(10) <= tiup;
                            pp0_3(11) <= sub_adj_msb_b(3);
 bm3: entity work.fuq_tblmul_bthrow(fuq_tblmul_bthrow) port map( 
        s_neg            => s_neg(3)                ,
        s_x              =>   s_x(3)                ,
        s_x2             =>  s_x2(3)                ,
        x                => y(7 to 22)              ,
        q                => pp0_3(12 to 28)        );
                            pp0_3(29) <= tidn;
                            pp0_3(30) <= sub_adj_lsb(4);

                            pp0_4(12) <= tiup;
                            pp0_4(13) <= sub_adj_msb_b(4);
 bm4: entity work.fuq_tblmul_bthrow(fuq_tblmul_bthrow) port map( 
        s_neg            => s_neg(4)                ,
        s_x              =>   s_x(4)                ,
        s_x2             =>  s_x2(4)                ,
        x                => y(7 to 22)              ,
        q                => pp0_4(14 to 30)        );
                            pp0_4(31) <= tidn;
                            pp0_4(32) <= sub_adj_lsb(5);

                            pp0_5(14) <= tiup;
                            pp0_5(15) <= sub_adj_msb_b(5);
 bm5: entity work.fuq_tblmul_bthrow(fuq_tblmul_bthrow) port map( 
        s_neg            => s_neg(5)                ,
        s_x              =>   s_x(5)                ,
        s_x2             =>  s_x2(5)                ,
        x                => y(7 to 22)              ,
        q                => pp0_5(16 to 32)        );
                            pp0_5(33) <= tidn;
                            pp0_5(34) <= sub_adj_lsb(6);

                            pp0_6(16) <= tiup;
                            pp0_6(17) <= sub_adj_msb_b(6);
 bm6: entity work.fuq_tblmul_bthrow(fuq_tblmul_bthrow) port map( 
        s_neg            => s_neg(6)                ,
        s_x              =>   s_x(6)                ,
        s_x2             =>  s_x2(6)                ,
        x                => y(7 to 22)              ,
        q                => pp0_6(18 to 34)        );
                            pp0_6(35) <= tidn;
                            pp0_6(36) <= sub_adj_lsb(7);

                           pp0_7(17) <=  sub_adj_msb_b(7);
                           pp0_7(18) <=  sub_adj_msb_7x;
                           pp0_7(19) <=  sub_adj_msb_7y;
 bm7: entity work.fuq_tblmul_bthrow(fuq_tblmul_bthrow) port map( 
        s_neg            => s_neg(7)                ,
        s_x              =>   s_x(7)                ,
        s_x2             =>  s_x2(7)                ,
        x                => y(7 to 22)              ,
        q                => pp0_7(20 to 36)        );









    z_b(0 to 20)  <= not z(0 to 20);


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
 pp1_0_csa_20: entity clib.c_prism_csa32  port map(  
      vd               => vdd,
      gd               => gnd,
      a                => z_b(20)                           ,
      b                => pp0_0(20)                         ,
      c                => pp0_1(20)                         ,
      sum              => pp1_0_sum(20)                     ,
      car              => pp1_0_car(19)                    );
 pp1_0_csa_19: entity clib.c_prism_csa32  port map(  
      vd               => vdd,
      gd               => gnd,
      a                => z_b(19)                           ,
      b                => pp0_0(19)                         ,
      c                => pp0_1(19)                         ,
      sum              => pp1_0_sum(19)                     ,
      car              => pp1_0_car(18)                    );
 pp1_0_csa_18: entity clib.c_prism_csa32  port map(  
      vd               => vdd,
      gd               => gnd,
      a                => z_b(18)                           ,
      b                => pp0_0(18)                         ,
      c                => pp0_1(18)                         ,
      sum              => pp1_0_sum(18)                     ,
      car              => pp1_0_car(17)                    );
 pp1_0_csa_17: entity clib.c_prism_csa32  port map(  
      vd               => vdd,
      gd               => gnd,
      a                => z_b(17)                           ,
      b                => pp0_0(17)                         ,
      c                => pp0_1(17)                         ,
      sum              => pp1_0_sum(17)                     ,
      car              => pp1_0_car(16)                    );
 pp1_0_csa_16: entity clib.c_prism_csa32  port map(  
      vd               => vdd,
      gd               => gnd,
      a                => z_b(16)                           ,
      b                => pp0_0(16)                         ,
      c                => pp0_1(16)                         ,
      sum              => pp1_0_sum(16)                     ,
      car              => pp1_0_car(15)                    );
 pp1_0_csa_15: entity clib.c_prism_csa32  port map(  
      vd               => vdd,
      gd               => gnd,
      a                => z_b(15)                           ,
      b                => pp0_0(15)                         ,
      c                => pp0_1(15)                         ,
      sum              => pp1_0_sum(15)                     ,
      car              => pp1_0_car(14)                    );
 pp1_0_csa_14: entity clib.c_prism_csa32  port map(  
      vd               => vdd,
      gd               => gnd,
      a                => z_b(14)                           ,
      b                => pp0_0(14)                         ,
      c                => pp0_1(14)                         ,
      sum              => pp1_0_sum(14)                     ,
      car              => pp1_0_car(13)                    );
 pp1_0_csa_13: entity clib.c_prism_csa32  port map(  
      vd               => vdd,
      gd               => gnd,
      a                => z_b(13)                           ,
      b                => pp0_0(13)                         ,
      c                => pp0_1(13)                         ,
      sum              => pp1_0_sum(13)                     ,
      car              => pp1_0_car(12)                    );
 pp1_0_csa_12: entity clib.c_prism_csa32  port map(  
      vd               => vdd,
      gd               => gnd,
      a                => z_b(12)                           ,
      b                => pp0_0(12)                         ,
      c                => pp0_1(12)                         ,
      sum              => pp1_0_sum(12)                     ,
      car              => pp1_0_car(11)                    );
 pp1_0_csa_11: entity clib.c_prism_csa32  port map(  
      vd               => vdd,
      gd               => gnd,
      a                => z_b(11)                           ,
      b                => pp0_0(11)                         ,
      c                => pp0_1(11)                         ,
      sum              => pp1_0_sum(11)                     ,
      car              => pp1_0_car(10)                    );
 pp1_0_csa_10: entity clib.c_prism_csa32  port map(  
      vd               => vdd,
      gd               => gnd,
      a                => z_b(10)                           ,
      b                => pp0_0(10)                         ,
      c                => pp0_1(10)                         ,
      sum              => pp1_0_sum(10)                     ,
      car              => pp1_0_car(9)                     );
 pp1_0_csa_9: entity clib.c_prism_csa32  port map(  
      vd               => vdd,
      gd               => gnd,
      a                => z_b(9)                            ,
      b                => pp0_0(9)                          ,
      c                => pp0_1(9)                          ,
      sum              => pp1_0_sum(9)                      ,
      car              => pp1_0_car(8)                     );
 pp1_0_csa_8: entity clib.c_prism_csa32  port map(  
      vd               => vdd,
      gd               => gnd,
      a                => z_b(8)                            ,
      b                => pp0_0(8)                          ,
      c                => pp0_1(8)                          ,
      sum              => pp1_0_sum(8)                      ,
      car              => pp1_0_car(7)                     );
 pp1_0_csa_7: entity clib.c_prism_csa32  port map(  
      vd               => vdd,
      gd               => gnd,
      a                => z_b(7)                            ,
      b                => pp0_0(7)                          ,
      c                => pp0_1(7)                          ,
      sum              => pp1_0_sum(7)                      ,
      car              => pp1_0_car(6)                     );
 pp1_0_csa_6: entity clib.c_prism_csa32  port map(  
      vd               => vdd,
      gd               => gnd,
      a                => z_b(6)                            ,
      b                => pp0_0(6)                          ,
      c                => pp0_1(6)                          ,
      sum              => pp1_0_sum(6)                      ,
      car              => pp1_0_car(5)                     );
 pp1_0_csa_5: entity work.fuq_csa22_h2(fuq_csa22_h2) port map(  
      a                => z_b(5)                            ,
      b                => tiup                              ,
      sum              => pp1_0_sum(5)                      ,
      car              => pp1_0_car(4)                     );
 pp1_0_csa_4: entity work.fuq_csa22_h2(fuq_csa22_h2) port map(  
      a                => z_b(4)                            ,
      b                => tiup                              ,
      sum              => pp1_0_sum(4)                      ,
      car              => pp1_0_car(3)                     );
 pp1_0_csa_3: entity work.fuq_csa22_h2(fuq_csa22_h2) port map(  
      a                => z_b(3)                            ,
      b                => tiup                              ,
      sum              => pp1_0_sum(3)                      ,
      car              => pp1_0_car(2)                     );
 pp1_0_csa_2: entity work.fuq_csa22_h2(fuq_csa22_h2) port map(  
      a                => z_b(2)                            ,
      b                => tiup                              ,
      sum              => pp1_0_sum(2)                      ,
      car              => pp1_0_car(1)                     );
 pp1_0_csa_1: entity work.fuq_csa22_h2(fuq_csa22_h2) port map(  
      a                => z_b(1)                            ,
      b                => tiup                              ,
      sum              => pp1_0_sum(1)                      ,
      car              => pp1_0_car(0)                     );
 pp1_0_csa_0: entity work.fuq_csa22_h2(fuq_csa22_h2) port map(  
      a                => z_b(0)                            ,
      b                => tiup                              ,
      sum              => pp1_0_sum(0)                      ,
      car              => pp1_0_car_unused                 );



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
      a                => pp0_2(28)                         ,
      b                => pp0_3(28)                         ,
      c                => pp0_4(28)                         ,
      sum              => pp1_1_sum(28)                     ,
      car              => pp1_1_car(27)                    );
 pp1_1_csa_27: entity work.fuq_csa22_h2(fuq_csa22_h2) port map(  
      a                => pp0_3(27)                         ,
      b                => pp0_4(27)                         ,
      sum              => pp1_1_sum(27)                     ,
      car              => pp1_1_car(26)                    );
 pp1_1_csa_26: entity clib.c_prism_csa32  port map(  
      vd               => vdd,
      gd               => gnd,
      a                => pp0_2(26)                         ,
      b                => pp0_3(26)                         ,
      c                => pp0_4(26)                         ,
      sum              => pp1_1_sum(26)                     ,
      car              => pp1_1_car(25)                    );
 pp1_1_csa_25: entity clib.c_prism_csa32  port map(  
      vd               => vdd,
      gd               => gnd,
      a                => pp0_2(25)                         ,
      b                => pp0_3(25)                         ,
      c                => pp0_4(25)                         ,
      sum              => pp1_1_sum(25)                     ,
      car              => pp1_1_car(24)                    );
 pp1_1_csa_24: entity clib.c_prism_csa32  port map(  
      vd               => vdd,
      gd               => gnd,
      a                => pp0_2(24)                         ,
      b                => pp0_3(24)                         ,
      c                => pp0_4(24)                         ,
      sum              => pp1_1_sum(24)                     ,
      car              => pp1_1_car(23)                    );
 pp1_1_csa_23: entity clib.c_prism_csa32  port map(  
      vd               => vdd,
      gd               => gnd,
      a                => pp0_2(23)                         ,
      b                => pp0_3(23)                         ,
      c                => pp0_4(23)                         ,
      sum              => pp1_1_sum(23)                     ,
      car              => pp1_1_car(22)                    );
 pp1_1_csa_22: entity clib.c_prism_csa32  port map(  
      vd               => vdd,
      gd               => gnd,
      a                => pp0_2(22)                         ,
      b                => pp0_3(22)                         ,
      c                => pp0_4(22)                         ,
      sum              => pp1_1_sum(22)                     ,
      car              => pp1_1_car(21)                    );
 pp1_1_csa_21: entity clib.c_prism_csa32  port map(  
      vd               => vdd,
      gd               => gnd,
      a                => pp0_2(21)                         ,
      b                => pp0_3(21)                         ,
      c                => pp0_4(21)                         ,
      sum              => pp1_1_sum(21)                     ,
      car              => pp1_1_car(20)                    );
 pp1_1_csa_20: entity clib.c_prism_csa32  port map(  
      vd               => vdd,
      gd               => gnd,
      a                => pp0_2(20)                         ,
      b                => pp0_3(20)                         ,
      c                => pp0_4(20)                         ,
      sum              => pp1_1_sum(20)                     ,
      car              => pp1_1_car(19)                    );
 pp1_1_csa_19: entity clib.c_prism_csa32  port map(  
      vd               => vdd,
      gd               => gnd,
      a                => pp0_2(19)                         ,
      b                => pp0_3(19)                         ,
      c                => pp0_4(19)                         ,
      sum              => pp1_1_sum(19)                     ,
      car              => pp1_1_car(18)                    );
 pp1_1_csa_18: entity clib.c_prism_csa32  port map(  
      vd               => vdd,
      gd               => gnd,
      a                => pp0_2(18)                         ,
      b                => pp0_3(18)                         ,
      c                => pp0_4(18)                         ,
      sum              => pp1_1_sum(18)                     ,
      car              => pp1_1_car(17)                    );
 pp1_1_csa_17: entity clib.c_prism_csa32  port map(  
      vd               => vdd,
      gd               => gnd,
      a                => pp0_2(17)                         ,
      b                => pp0_3(17)                         ,
      c                => pp0_4(17)                         ,
      sum              => pp1_1_sum(17)                     ,
      car              => pp1_1_car(16)                    );
 pp1_1_csa_16: entity clib.c_prism_csa32  port map(  
      vd               => vdd,
      gd               => gnd,
      a                => pp0_2(16)                         ,
      b                => pp0_3(16)                         ,
      c                => pp0_4(16)                         ,
      sum              => pp1_1_sum(16)                     ,
      car              => pp1_1_car(15)                    );
 pp1_1_csa_15: entity clib.c_prism_csa32  port map(  
      vd               => vdd,
      gd               => gnd,
      a                => pp0_2(15)                         ,
      b                => pp0_3(15)                         ,
      c                => pp0_4(15)                         ,
      sum              => pp1_1_sum(15)                     ,
      car              => pp1_1_car(14)                    );
 pp1_1_csa_14: entity clib.c_prism_csa32  port map(  
      vd               => vdd,
      gd               => gnd,
      a                => pp0_2(14)                         ,
      b                => pp0_3(14)                         ,
      c                => pp0_4(14)                         ,
      sum              => pp1_1_sum(14)                     ,
      car              => pp1_1_car(13)                    );
 pp1_1_csa_13: entity clib.c_prism_csa32  port map(  
      vd               => vdd,
      gd               => gnd,
      a                => pp0_2(13)                         ,
      b                => pp0_3(13)                         ,
      c                => pp0_4(13)                         ,
      sum              => pp1_1_sum(13)                     ,
      car              => pp1_1_car(12)                    );
 pp1_1_csa_12: entity clib.c_prism_csa32  port map(  
      vd               => vdd,
      gd               => gnd,
      a                => pp0_2(12)                         ,
      b                => pp0_3(12)                         ,
      c                => pp0_4(12)                         ,
      sum              => pp1_1_sum(12)                     ,
      car              => pp1_1_car(11)                    );
 pp1_1_csa_11: entity work.fuq_csa22_h2(fuq_csa22_h2) port map(  
      a                => pp0_2(11)                         ,
      b                => pp0_3(11)                         ,
      sum              => pp1_1_sum(11)                     ,
      car              => pp1_1_car(10)                    );
 pp1_1_csa_10: entity work.fuq_csa22_h2(fuq_csa22_h2) port map(  
      a                => pp0_2(10)                         ,
      b                => pp0_3(10)                         ,
      sum              => pp1_1_sum(10)                     ,
      car              => pp1_1_car(9)                     );
    pp1_1_sum(9)                     <= pp0_2(9)                         ;
    pp1_1_sum(8)                     <= pp0_2(8)                         ;



    pp1_2_sum(36)                    <= pp0_6(36)                        ;
    pp1_2_car(36)                    <= pp0_7(36)                        ;
    pp1_2_sum(35)                    <= pp0_7(35)                        ;
    pp1_2_car(35)                    <= tidn                             ;
    pp1_2_car(34)                    <= tidn                             ;
 pp1_2_csa_34: entity clib.c_prism_csa32  port map(  
      vd               => vdd,
      gd               => gnd,
      a                => pp0_5(34)                         ,
      b                => pp0_6(34)                         ,
      c                => pp0_7(34)                         ,
      sum              => pp1_2_sum(34)                     ,
      car              => pp1_2_car(33)                    );
 pp1_2_csa_33: entity work.fuq_csa22_h2(fuq_csa22_h2) port map(  
      a                => pp0_6(33)                         ,
      b                => pp0_7(33)                         ,
      sum              => pp1_2_sum(33)                     ,
      car              => pp1_2_car(32)                    );
 pp1_2_csa_32: entity clib.c_prism_csa32  port map(  
      vd               => vdd,
      gd               => gnd,
      a                => pp0_5(32)                         ,
      b                => pp0_6(32)                         ,
      c                => pp0_7(32)                         ,
      sum              => pp1_2_sum(32)                     ,
      car              => pp1_2_car(31)                    );
 pp1_2_csa_31: entity clib.c_prism_csa32  port map(  
      vd               => vdd,
      gd               => gnd,
      a                => pp0_5(31)                         ,
      b                => pp0_6(31)                         ,
      c                => pp0_7(31)                         ,
      sum              => pp1_2_sum(31)                     ,
      car              => pp1_2_car(30)                    );
 pp1_2_csa_30: entity clib.c_prism_csa32  port map(  
      vd               => vdd,
      gd               => gnd,
      a                => pp0_5(30)                         ,
      b                => pp0_6(30)                         ,
      c                => pp0_7(30)                         ,
      sum              => pp1_2_sum(30)                     ,
      car              => pp1_2_car(29)                    );
 pp1_2_csa_29: entity clib.c_prism_csa32  port map(  
      vd               => vdd,
      gd               => gnd,
      a                => pp0_5(29)                         ,
      b                => pp0_6(29)                         ,
      c                => pp0_7(29)                         ,
      sum              => pp1_2_sum(29)                     ,
      car              => pp1_2_car(28)                    );
 pp1_2_csa_28: entity clib.c_prism_csa32  port map(  
      vd               => vdd,
      gd               => gnd,
      a                => pp0_5(28)                         ,
      b                => pp0_6(28)                         ,
      c                => pp0_7(28)                         ,
      sum              => pp1_2_sum(28)                     ,
      car              => pp1_2_car(27)                    );
 pp1_2_csa_27: entity clib.c_prism_csa32  port map(  
      vd               => vdd,
      gd               => gnd,
      a                => pp0_5(27)                         ,
      b                => pp0_6(27)                         ,
      c                => pp0_7(27)                         ,
      sum              => pp1_2_sum(27)                     ,
      car              => pp1_2_car(26)                    );
 pp1_2_csa_26: entity clib.c_prism_csa32  port map(  
      vd               => vdd,
      gd               => gnd,
      a                => pp0_5(26)                         ,
      b                => pp0_6(26)                         ,
      c                => pp0_7(26)                         ,
      sum              => pp1_2_sum(26)                     ,
      car              => pp1_2_car(25)                    );
 pp1_2_csa_25: entity clib.c_prism_csa32  port map(  
      vd               => vdd,
      gd               => gnd,
      a                => pp0_5(25)                         ,
      b                => pp0_6(25)                         ,
      c                => pp0_7(25)                         ,
      sum              => pp1_2_sum(25)                     ,
      car              => pp1_2_car(24)                    );
 pp1_2_csa_24: entity clib.c_prism_csa32  port map(  
      vd               => vdd,
      gd               => gnd,
      a                => pp0_5(24)                         ,
      b                => pp0_6(24)                         ,
      c                => pp0_7(24)                         ,
      sum              => pp1_2_sum(24)                     ,
      car              => pp1_2_car(23)                    );
 pp1_2_csa_23: entity clib.c_prism_csa32  port map(  
      vd               => vdd,
      gd               => gnd,
      a                => pp0_5(23)                         ,
      b                => pp0_6(23)                         ,
      c                => pp0_7(23)                         ,
      sum              => pp1_2_sum(23)                     ,
      car              => pp1_2_car(22)                    );
 pp1_2_csa_22: entity clib.c_prism_csa32  port map(  
      vd               => vdd,
      gd               => gnd,
      a                => pp0_5(22)                         ,
      b                => pp0_6(22)                         ,
      c                => pp0_7(22)                         ,
      sum              => pp1_2_sum(22)                     ,
      car              => pp1_2_car(21)                    );
 pp1_2_csa_21: entity clib.c_prism_csa32  port map(  
      vd               => vdd,
      gd               => gnd,
      a                => pp0_5(21)                         ,
      b                => pp0_6(21)                         ,
      c                => pp0_7(21)                         ,
      sum              => pp1_2_sum(21)                     ,
      car              => pp1_2_car(20)                    );
 pp1_2_csa_20: entity clib.c_prism_csa32  port map(  
      vd               => vdd,
      gd               => gnd,
      a                => pp0_5(20)                         ,
      b                => pp0_6(20)                         ,
      c                => pp0_7(20)                         ,
      sum              => pp1_2_sum(20)                     ,
      car              => pp1_2_car(19)                    );
 pp1_2_csa_19: entity clib.c_prism_csa32  port map(  
      vd               => vdd,
      gd               => gnd,
      a                => pp0_5(19)                         ,
      b                => pp0_6(19)                         ,
      c                => pp0_7(19)                         ,
      sum              => pp1_2_sum(19)                     ,
      car              => pp1_2_car(18)                    );
 pp1_2_csa_18: entity clib.c_prism_csa32  port map(  
      vd               => vdd,
      gd               => gnd,
      a                => pp0_5(18)                         ,
      b                => pp0_6(18)                         ,
      c                => pp0_7(18)                         ,
      sum              => pp1_2_sum(18)                     ,
      car              => pp1_2_car(17)                    );
 pp1_2_csa_17: entity clib.c_prism_csa32  port map(  
      vd               => vdd,
      gd               => gnd,
      a                => pp0_5(17)                         ,
      b                => pp0_6(17)                         ,
      c                => pp0_7(17)                         ,
      sum              => pp1_2_sum(17)                     ,
      car              => pp1_2_car(16)                    );
 pp1_2_csa_16: entity work.fuq_csa22_h2(fuq_csa22_h2) port map(  
      a                => pp0_5(16)                         ,
      b                => pp0_6(16)                         ,
      sum              => pp1_2_sum(16)                     ,
      car              => pp1_2_car(15)                    );
    pp1_2_sum(15)                    <= pp0_5(15)                        ;
    pp1_2_sum(14)                    <= pp0_5(14)                        ;









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
      a                => pp1_0_sum(24)                     ,
      b                => pp1_0_car(24)                     ,
      c                => pp1_1_sum(24)                     ,
      sum              => pp2_0_sum(24)                     ,
      car              => pp2_0_car(23)                    );
 pp2_0_csa_23: entity work.fuq_csa22_h2(fuq_csa22_h2) port map(  
      a                => pp1_0_sum(23)                     ,
      b                => pp1_1_sum(23)                     ,
      sum              => pp2_0_sum(23)                     ,
      car              => pp2_0_car(22)                    );
 pp2_0_csa_22: entity clib.c_prism_csa32  port map(  
      vd               => vdd,
      gd               => gnd,
      a                => pp1_0_sum(22)                     ,
      b                => pp1_0_car(22)                     ,
      c                => pp1_1_sum(22)                     ,
      sum              => pp2_0_sum(22)                     ,
      car              => pp2_0_car(21)                    );
 pp2_0_csa_21: entity clib.c_prism_csa32  port map(  
      vd               => vdd,
      gd               => gnd,
      a                => pp1_0_sum(21)                     ,
      b                => pp1_0_car(21)                     ,
      c                => pp1_1_sum(21)                     ,
      sum              => pp2_0_sum(21)                     ,
      car              => pp2_0_car(20)                    );
 pp2_0_csa_20: entity clib.c_prism_csa32  port map(  
      vd               => vdd,
      gd               => gnd,
      a                => pp1_0_sum(20)                     ,
      b                => pp1_0_car(20)                     ,
      c                => pp1_1_sum(20)                     ,
      sum              => pp2_0_sum(20)                     ,
      car              => pp2_0_car(19)                    );
 pp2_0_csa_19: entity clib.c_prism_csa32  port map(  
      vd               => vdd,
      gd               => gnd,
      a                => pp1_0_sum(19)                     ,
      b                => pp1_0_car(19)                     ,
      c                => pp1_1_sum(19)                     ,
      sum              => pp2_0_sum(19)                     ,
      car              => pp2_0_car(18)                    );
 pp2_0_csa_18: entity clib.c_prism_csa32  port map(  
      vd               => vdd,
      gd               => gnd,
      a                => pp1_0_sum(18)                     ,
      b                => pp1_0_car(18)                     ,
      c                => pp1_1_sum(18)                     ,
      sum              => pp2_0_sum(18)                     ,
      car              => pp2_0_car(17)                    );
 pp2_0_csa_17: entity clib.c_prism_csa32  port map(  
      vd               => vdd,
      gd               => gnd,
      a                => pp1_0_sum(17)                     ,
      b                => pp1_0_car(17)                     ,
      c                => pp1_1_sum(17)                     ,
      sum              => pp2_0_sum(17)                     ,
      car              => pp2_0_car(16)                    );
 pp2_0_csa_16: entity clib.c_prism_csa32  port map(  
      vd               => vdd,
      gd               => gnd,
      a                => pp1_0_sum(16)                     ,
      b                => pp1_0_car(16)                     ,
      c                => pp1_1_sum(16)                     ,
      sum              => pp2_0_sum(16)                     ,
      car              => pp2_0_car(15)                    );
 pp2_0_csa_15: entity clib.c_prism_csa32  port map(  
      vd               => vdd,
      gd               => gnd,
      a                => pp1_0_sum(15)                     ,
      b                => pp1_0_car(15)                     ,
      c                => pp1_1_sum(15)                     ,
      sum              => pp2_0_sum(15)                     ,
      car              => pp2_0_car(14)                    );
 pp2_0_csa_14: entity clib.c_prism_csa32  port map(  
      vd               => vdd,
      gd               => gnd,
      a                => pp1_0_sum(14)                     ,
      b                => pp1_0_car(14)                     ,
      c                => pp1_1_sum(14)                     ,
      sum              => pp2_0_sum(14)                     ,
      car              => pp2_0_car(13)                    );
 pp2_0_csa_13: entity clib.c_prism_csa32  port map(  
      vd               => vdd,
      gd               => gnd,
      a                => pp1_0_sum(13)                     ,
      b                => pp1_0_car(13)                     ,
      c                => pp1_1_sum(13)                     ,
      sum              => pp2_0_sum(13)                     ,
      car              => pp2_0_car(12)                    );
 pp2_0_csa_12: entity clib.c_prism_csa32  port map(  
      vd               => vdd,
      gd               => gnd,
      a                => pp1_0_sum(12)                     ,
      b                => pp1_0_car(12)                     ,
      c                => pp1_1_sum(12)                     ,
      sum              => pp2_0_sum(12)                     ,
      car              => pp2_0_car(11)                    );
 pp2_0_csa_11: entity clib.c_prism_csa32  port map(  
      vd               => vdd,
      gd               => gnd,
      a                => pp1_0_sum(11)                     ,
      b                => pp1_0_car(11)                     ,
      c                => pp1_1_sum(11)                     ,
      sum              => pp2_0_sum(11)                     ,
      car              => pp2_0_car(10)                    );
 pp2_0_csa_10: entity clib.c_prism_csa32  port map(  
      vd               => vdd,
      gd               => gnd,
      a                => pp1_0_sum(10)                     ,
      b                => pp1_0_car(10)                     ,
      c                => pp1_1_sum(10)                     ,
      sum              => pp2_0_sum(10)                     ,
      car              => pp2_0_car(9)                     );
 pp2_0_csa_9: entity clib.c_prism_csa32  port map(  
      vd               => vdd,
      gd               => gnd,
      a                => pp1_0_sum(9)                      ,
      b                => pp1_0_car(9)                      ,
      c                => pp1_1_sum(9)                      ,
      sum              => pp2_0_sum(9)                      ,
      car              => pp2_0_car(8)                     );
 pp2_0_csa_8: entity clib.c_prism_csa32  port map(  
      vd               => vdd,
      gd               => gnd,
      a                => pp1_0_sum(8)                      ,
      b                => pp1_0_car(8)                      ,
      c                => pp1_1_sum(8)                      ,
      sum              => pp2_0_sum(8)                      ,
      car              => pp2_0_car(7)                     );
 pp2_0_csa_7: entity work.fuq_csa22_h2(fuq_csa22_h2) port map(  
      a                => pp1_0_sum(7)                      ,
      b                => pp1_0_car(7)                      ,
      sum              => pp2_0_sum(7)                      ,
      car              => pp2_0_car(6)                     );
 pp2_0_csa_6: entity work.fuq_csa22_h2(fuq_csa22_h2) port map(  
      a                => pp1_0_sum(6)                      ,
      b                => pp1_0_car(6)                      ,
      sum              => pp2_0_sum(6)                      ,
      car              => pp2_0_car(5)                     );
 pp2_0_csa_5: entity work.fuq_csa22_h2(fuq_csa22_h2) port map(  
      a                => pp1_0_sum(5)                      ,
      b                => pp1_0_car(5)                      ,
      sum              => pp2_0_sum(5)                      ,
      car              => pp2_0_car(4)                     );
 pp2_0_csa_4: entity work.fuq_csa22_h2(fuq_csa22_h2) port map(  
      a                => pp1_0_sum(4)                      ,
      b                => pp1_0_car(4)                      ,
      sum              => pp2_0_sum(4)                      ,
      car              => pp2_0_car(3)                     );
 pp2_0_csa_3: entity work.fuq_csa22_h2(fuq_csa22_h2) port map(  
      a                => pp1_0_sum(3)                      ,
      b                => pp1_0_car(3)                      ,
      sum              => pp2_0_sum(3)                      ,
      car              => pp2_0_car(2)                     );
 pp2_0_csa_2: entity work.fuq_csa22_h2(fuq_csa22_h2) port map(  
      a                => pp1_0_sum(2)                      ,
      b                => pp1_0_car(2)                      ,
      sum              => pp2_0_sum(2)                      ,
      car              => pp2_0_car(1)                     );
 pp2_0_csa_1: entity work.fuq_csa22_h2(fuq_csa22_h2) port map(  
      a                => pp1_0_sum(1)                      ,
      b                => pp1_0_car(1)                      ,
      sum              => pp2_0_sum(1)                      ,
      car              => pp2_0_car(0)                     );
 pp2_0_csa_0: entity work.fuq_csa22_h2(fuq_csa22_h2) port map(  
      a                => pp1_0_sum(0)                      ,
      b                => pp1_0_car(0)                      ,
      sum              => pp2_0_sum(0)                      ,
      car              => pp2_0_car_unused                 );



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
      a                => pp1_1_car(30)                     ,
      b                => pp1_2_sum(30)                     ,
      c                => pp1_2_car(30)                     ,
      sum              => pp2_1_sum(30)                     ,
      car              => pp2_1_car(29)                    );
 pp2_1_csa_29: entity work.fuq_csa22_h2(fuq_csa22_h2) port map(  
      a                => pp1_2_sum(29)                     ,
      b                => pp1_2_car(29)                     ,
      sum              => pp2_1_sum(29)                     ,
      car              => pp2_1_car(28)                    );
 pp2_1_csa_28: entity work.fuq_csa22_h2(fuq_csa22_h2) port map(  
      a                => pp1_2_sum(28)                     ,
      b                => pp1_2_car(28)                     ,
      sum              => pp2_1_sum(28)                     ,
      car              => pp2_1_car(27)                    );
 pp2_1_csa_27: entity clib.c_prism_csa32  port map(  
      vd               => vdd,
      gd               => gnd,
      a                => pp1_1_car(27)                     ,
      b                => pp1_2_sum(27)                     ,
      c                => pp1_2_car(27)                     ,
      sum              => pp2_1_sum(27)                     ,
      car              => pp2_1_car(26)                    );
 pp2_1_csa_26: entity clib.c_prism_csa32  port map(  
      vd               => vdd,
      gd               => gnd,
      a                => pp1_1_car(26)                     ,
      b                => pp1_2_sum(26)                     ,
      c                => pp1_2_car(26)                     ,
      sum              => pp2_1_sum(26)                     ,
      car              => pp2_1_car(25)                    );
 pp2_1_csa_25: entity clib.c_prism_csa32  port map(  
      vd               => vdd,
      gd               => gnd,
      a                => pp1_1_car(25)                     ,
      b                => pp1_2_sum(25)                     ,
      c                => pp1_2_car(25)                     ,
      sum              => pp2_1_sum(25)                     ,
      car              => pp2_1_car(24)                    );
 pp2_1_csa_24: entity clib.c_prism_csa32  port map(  
      vd               => vdd,
      gd               => gnd,
      a                => pp1_1_car(24)                     ,
      b                => pp1_2_sum(24)                     ,
      c                => pp1_2_car(24)                     ,
      sum              => pp2_1_sum(24)                     ,
      car              => pp2_1_car(23)                    );
 pp2_1_csa_23: entity clib.c_prism_csa32  port map(  
      vd               => vdd,
      gd               => gnd,
      a                => pp1_1_car(23)                     ,
      b                => pp1_2_sum(23)                     ,
      c                => pp1_2_car(23)                     ,
      sum              => pp2_1_sum(23)                     ,
      car              => pp2_1_car(22)                    );
 pp2_1_csa_22: entity clib.c_prism_csa32  port map(  
      vd               => vdd,
      gd               => gnd,
      a                => pp1_1_car(22)                     ,
      b                => pp1_2_sum(22)                     ,
      c                => pp1_2_car(22)                     ,
      sum              => pp2_1_sum(22)                     ,
      car              => pp2_1_car(21)                    );
 pp2_1_csa_21: entity clib.c_prism_csa32  port map(  
      vd               => vdd,
      gd               => gnd,
      a                => pp1_1_car(21)                     ,
      b                => pp1_2_sum(21)                     ,
      c                => pp1_2_car(21)                     ,
      sum              => pp2_1_sum(21)                     ,
      car              => pp2_1_car(20)                    );
 pp2_1_csa_20: entity clib.c_prism_csa32  port map(  
      vd               => vdd,
      gd               => gnd,
      a                => pp1_1_car(20)                     ,
      b                => pp1_2_sum(20)                     ,
      c                => pp1_2_car(20)                     ,
      sum              => pp2_1_sum(20)                     ,
      car              => pp2_1_car(19)                    );
 pp2_1_csa_19: entity clib.c_prism_csa32  port map(  
      vd               => vdd,
      gd               => gnd,
      a                => pp1_1_car(19)                     ,
      b                => pp1_2_sum(19)                     ,
      c                => pp1_2_car(19)                     ,
      sum              => pp2_1_sum(19)                     ,
      car              => pp2_1_car(18)                    );
 pp2_1_csa_18: entity clib.c_prism_csa32  port map(  
      vd               => vdd,
      gd               => gnd,
      a                => pp1_1_car(18)                     ,
      b                => pp1_2_sum(18)                     ,
      c                => pp1_2_car(18)                     ,
      sum              => pp2_1_sum(18)                     ,
      car              => pp2_1_car(17)                    );
 pp2_1_csa_17: entity clib.c_prism_csa32  port map(  
      vd               => vdd,
      gd               => gnd,
      a                => pp1_1_car(17)                     ,
      b                => pp1_2_sum(17)                     ,
      c                => pp1_2_car(17)                     ,
      sum              => pp2_1_sum(17)                     ,
      car              => pp2_1_car(16)                    );
 pp2_1_csa_16: entity clib.c_prism_csa32  port map(  
      vd               => vdd,
      gd               => gnd,
      a                => pp1_1_car(16)                     ,
      b                => pp1_2_sum(16)                     ,
      c                => pp1_2_car(16)                     ,
      sum              => pp2_1_sum(16)                     ,
      car              => pp2_1_car(15)                    );
 pp2_1_csa_15: entity clib.c_prism_csa32  port map(  
      vd               => vdd,
      gd               => gnd,
      a                => pp1_1_car(15)                     ,
      b                => pp1_2_sum(15)                     ,
      c                => pp1_2_car(15)                     ,
      sum              => pp2_1_sum(15)                     ,
      car              => pp2_1_car(14)                    );
 pp2_1_csa_14: entity work.fuq_csa22_h2(fuq_csa22_h2) port map(  
      a                => pp1_1_car(14)                     ,
      b                => pp1_2_sum(14)                     ,
      sum              => pp2_1_sum(14)                     ,
      car              => pp2_1_car(13)                    );
    pp2_1_sum(13)                    <= pp1_1_car(13)                    ;
    pp2_1_sum(12)                    <= pp1_1_car(12)                    ;
    pp2_1_sum(11)                    <= pp1_1_car(11)                    ;
    pp2_1_sum(10)                    <= pp1_1_car(10)                    ;
    pp2_1_sum(9)                     <= pp1_1_car(9)                     ;








 pp3_0_csa_36: entity work.fuq_csa22_h2(fuq_csa22_h2) port map(  
      a                => pp2_1_sum(36)                     ,
      b                => pp2_1_car(36)                     ,
      sum              => pp3_0_sum(36)                     ,
      car              => pp3_0_car(35)                    );
    pp3_0_sum(35)                    <= pp2_1_sum(35)                    ;
    pp3_0_sum(34)                    <= pp2_1_sum(34)                    ;
    pp3_0_car(34)                    <= tidn                             ;
    pp3_0_sum(33)                    <= pp2_1_sum(33)                    ;
    pp3_0_car(33)                    <= pp2_1_car(33)                    ;
    pp3_0_car(32)                    <= tidn                             ;
 pp3_0_csa_32: entity clib.c_prism_csa32  port map(  
      vd               => vdd,
      gd               => gnd,
      a                => pp2_0_sum(32)                     ,
      b                => pp2_1_sum(32)                     ,
      c                => pp2_1_car(32)                     ,
      sum              => pp3_0_sum(32)                     ,
      car              => pp3_0_car(31)                    );
 pp3_0_csa_31: entity work.fuq_csa22_h2(fuq_csa22_h2) port map(  
      a                => pp2_1_sum(31)                     ,
      b                => pp2_1_car(31)                     ,
      sum              => pp3_0_sum(31)                     ,
      car              => pp3_0_car(30)                    );
 pp3_0_csa_30: entity work.fuq_csa22_h2(fuq_csa22_h2) port map(  
      a                => pp2_0_sum(30)                     ,
      b                => pp2_1_sum(30)                     ,
      sum              => pp3_0_sum(30)                     ,
      car              => pp3_0_car(29)                    );
 pp3_0_csa_29: entity clib.c_prism_csa32  port map(  
      vd               => vdd,
      gd               => gnd,
      a                => pp2_0_sum(29)                     ,
      b                => pp2_1_sum(29)                     ,
      c                => pp2_1_car(29)                     ,
      sum              => pp3_0_sum(29)                     ,
      car              => pp3_0_car(28)                    );
 pp3_0_csa_28: entity clib.c_prism_csa32  port map(  
      vd               => vdd,
      gd               => gnd,
      a                => pp2_0_sum(28)                     ,
      b                => pp2_1_sum(28)                     ,
      c                => pp2_1_car(28)                     ,
      sum              => pp3_0_sum(28)                     ,
      car              => pp3_0_car(27)                    );
 pp3_0_csa_27: entity clib.c_prism_csa32  port map(  
      vd               => vdd,
      gd               => gnd,
      a                => pp2_0_sum(27)                     ,
      b                => pp2_1_sum(27)                     ,
      c                => pp2_1_car(27)                     ,
      sum              => pp3_0_sum(27)                     ,
      car              => pp3_0_car(26)                    );
 pp3_0_csa_26: entity clib.c_prism_csa42  port map(  
      vd               => vdd,
      gd               => gnd,
      a                => pp2_0_sum(26)                     ,
      b                => pp2_0_car(26)                     ,
      c                => pp2_1_sum(26)                     ,
      d                => pp2_1_car(26)                     ,
      ki               => tidn                              ,
      ko               => pp3_0_ko(25)                      ,
      sum              => pp3_0_sum(26)                     ,
      car              => pp3_0_car(25)                    );
 pp3_0_csa_25: entity clib.c_prism_csa42  port map(  
      vd               => vdd,
      gd               => gnd,
      a                => pp2_0_sum(25)                     ,
      b                => tidn                              ,
      c                => pp2_1_sum(25)                     ,
      d                => pp2_1_car(25)                     ,
      ki               => pp3_0_ko(25)                      ,
      ko               => pp3_0_ko(24)                      ,
      sum              => pp3_0_sum(25)                     ,
      car              => pp3_0_car(24)                    );
 pp3_0_csa_24: entity clib.c_prism_csa42  port map(  
      vd               => vdd,
      gd               => gnd,
      a                => pp2_0_sum(24)                     ,
      b                => tidn                              ,
      c                => pp2_1_sum(24)                     ,
      d                => pp2_1_car(24)                     ,
      ki               => pp3_0_ko(24)                      ,
      ko               => pp3_0_ko(23)                      ,
      sum              => pp3_0_sum(24)                     ,
      car              => pp3_0_car(23)                    );
 pp3_0_csa_23: entity clib.c_prism_csa42  port map(  
      vd               => vdd,
      gd               => gnd,
      a                => pp2_0_sum(23)                     ,
      b                => pp2_0_car(23)                     ,
      c                => pp2_1_sum(23)                     ,
      d                => pp2_1_car(23)                     ,
      ki               => pp3_0_ko(23)                      ,
      ko               => pp3_0_ko(22)                      ,
      sum              => pp3_0_sum(23)                     ,
      car              => pp3_0_car(22)                    );
 pp3_0_csa_22: entity clib.c_prism_csa42  port map(  
      vd               => vdd,
      gd               => gnd,
      a                => pp2_0_sum(22)                     ,
      b                => pp2_0_car(22)                     ,
      c                => pp2_1_sum(22)                     ,
      d                => pp2_1_car(22)                     ,
      ki               => pp3_0_ko(22)                      ,
      ko               => pp3_0_ko(21)                      ,
      sum              => pp3_0_sum(22)                     ,
      car              => pp3_0_car(21)                    );
 pp3_0_csa_21: entity clib.c_prism_csa42  port map(  
      vd               => vdd,
      gd               => gnd,
      a                => pp2_0_sum(21)                     ,
      b                => pp2_0_car(21)                     ,
      c                => pp2_1_sum(21)                     ,
      d                => pp2_1_car(21)                     ,
      ki               => pp3_0_ko(21)                      ,
      ko               => pp3_0_ko(20)                      ,
      sum              => pp3_0_sum(21)                     ,
      car              => pp3_0_car(20)                    );
 pp3_0_csa_20: entity clib.c_prism_csa42  port map(  
      vd               => vdd,
      gd               => gnd,
      a                => pp2_0_sum(20)                     ,
      b                => pp2_0_car(20)                     ,
      c                => pp2_1_sum(20)                     ,
      d                => pp2_1_car(20)                     ,
      ki               => pp3_0_ko(20)                      ,
      ko               => pp3_0_ko(19)                      ,
      sum              => pp3_0_sum(20)                     ,
      car              => pp3_0_car(19)                    );
 pp3_0_csa_19: entity clib.c_prism_csa42  port map(  
      vd               => vdd,
      gd               => gnd,
      a                => pp2_0_sum(19)                     ,
      b                => pp2_0_car(19)                     ,
      c                => pp2_1_sum(19)                     ,
      d                => pp2_1_car(19)                     ,
      ki               => pp3_0_ko(19)                      ,
      ko               => pp3_0_ko(18)                      ,
      sum              => pp3_0_sum(19)                     ,
      car              => pp3_0_car(18)                    );
 pp3_0_csa_18: entity clib.c_prism_csa42  port map(  
      vd               => vdd,
      gd               => gnd,
      a                => pp2_0_sum(18)                     ,
      b                => pp2_0_car(18)                     ,
      c                => pp2_1_sum(18)                     ,
      d                => pp2_1_car(18)                     ,
      ki               => pp3_0_ko(18)                      ,
      ko               => pp3_0_ko(17)                      ,
      sum              => pp3_0_sum(18)                     ,
      car              => pp3_0_car(17)                    );
 pp3_0_csa_17: entity clib.c_prism_csa42  port map(  
      vd               => vdd,
      gd               => gnd,
      a                => pp2_0_sum(17)                     ,
      b                => pp2_0_car(17)                     ,
      c                => pp2_1_sum(17)                     ,
      d                => pp2_1_car(17)                     ,
      ki               => pp3_0_ko(17)                      ,
      ko               => pp3_0_ko(16)                      ,
      sum              => pp3_0_sum(17)                     ,
      car              => pp3_0_car(16)                    );
 pp3_0_csa_16: entity clib.c_prism_csa42  port map(  
      vd               => vdd,
      gd               => gnd,
      a                => pp2_0_sum(16)                     ,
      b                => pp2_0_car(16)                     ,
      c                => pp2_1_sum(16)                     ,
      d                => pp2_1_car(16)                     ,
      ki               => pp3_0_ko(16)                      ,
      ko               => pp3_0_ko(15)                      ,
      sum              => pp3_0_sum(16)                     ,
      car              => pp3_0_car(15)                    );
 pp3_0_csa_15: entity clib.c_prism_csa42  port map(  
      vd               => vdd,
      gd               => gnd,
      a                => pp2_0_sum(15)                     ,
      b                => pp2_0_car(15)                     ,
      c                => pp2_1_sum(15)                     ,
      d                => pp2_1_car(15)                     ,
      ki               => pp3_0_ko(15)                      ,
      ko               => pp3_0_ko(14)                      ,
      sum              => pp3_0_sum(15)                     ,
      car              => pp3_0_car(14)                    );
 pp3_0_csa_14: entity clib.c_prism_csa42  port map(  
      vd               => vdd,
      gd               => gnd,
      a                => pp2_0_sum(14)                     ,
      b                => pp2_0_car(14)                     ,
      c                => pp2_1_sum(14)                     ,
      d                => pp2_1_car(14)                     ,
      ki               => pp3_0_ko(14)                      ,
      ko               => pp3_0_ko(13)                      ,
      sum              => pp3_0_sum(14)                     ,
      car              => pp3_0_car(13)                    );
 pp3_0_csa_13: entity clib.c_prism_csa42  port map(  
      vd               => vdd,
      gd               => gnd,
      a                => pp2_0_sum(13)                     ,
      b                => pp2_0_car(13)                     ,
      c                => pp2_1_sum(13)                     ,
      d                => pp2_1_car(13)                     ,
      ki               => pp3_0_ko(13)                      ,
      ko               => pp3_0_ko(12)                      ,
      sum              => pp3_0_sum(13)                     ,
      car              => pp3_0_car(12)                    );
 pp3_0_csa_12: entity clib.c_prism_csa42  port map(  
      vd               => vdd,
      gd               => gnd,
      a                => pp2_0_sum(12)                     ,
      b                => pp2_0_car(12)                     ,
      c                => pp2_1_sum(12)                     ,
      d                => tidn                              ,
      ki               => pp3_0_ko(12)                      ,
      ko               => pp3_0_ko(11)                      ,
      sum              => pp3_0_sum(12)                     ,
      car              => pp3_0_car(11)                    );
 pp3_0_csa_11: entity clib.c_prism_csa42  port map(  
      vd               => vdd,
      gd               => gnd,
      a                => pp2_0_sum(11)                     ,
      b                => pp2_0_car(11)                     ,
      c                => pp2_1_sum(11)                     ,
      d                => tidn                              ,
      ki               => pp3_0_ko(11)                      ,
      ko               => pp3_0_ko(10)                      ,
      sum              => pp3_0_sum(11)                     ,
      car              => pp3_0_car(10)                    );
 pp3_0_csa_10: entity clib.c_prism_csa42  port map(  
      vd               => vdd,
      gd               => gnd,
      a                => pp2_0_sum(10)                     ,
      b                => pp2_0_car(10)                     ,
      c                => pp2_1_sum(10)                     ,
      d                => tidn                              ,
      ki               => pp3_0_ko(10)                      ,
      ko               => pp3_0_ko(9)                       ,
      sum              => pp3_0_sum(10)                     ,
      car              => pp3_0_car(9)                     );
 pp3_0_csa_9: entity clib.c_prism_csa42  port map(  
      vd               => vdd,
      gd               => gnd,
      a                => pp2_0_sum(9)                      ,
      b                => pp2_0_car(9)                      ,
      c                => pp2_1_sum(9)                      ,
      d                => tidn                              ,
      ki               => pp3_0_ko(9)                       ,
      ko               => pp3_0_ko(8)                       ,
      sum              => pp3_0_sum(9)                      ,
      car              => pp3_0_car(8)                     );
 pp3_0_csa_8: entity clib.c_prism_csa32  port map(  
      vd               => vdd,
      gd               => gnd,
      a                => pp2_0_sum(8)                      ,
      b                => pp2_0_car(8)                      ,
      c                => pp3_0_ko(8)                       ,
      sum              => pp3_0_sum(8)                      ,
      car              => pp3_0_car(7)                     );
 pp3_0_csa_7: entity work.fuq_csa22_h2(fuq_csa22_h2) port map(  
      a                => pp2_0_sum(7)                      ,
      b                => pp2_0_car(7)                      ,
      sum              => pp3_0_sum(7)                      ,
      car              => pp3_0_car(6)                     );
 pp3_0_csa_6: entity work.fuq_csa22_h2(fuq_csa22_h2) port map(  
      a                => pp2_0_sum(6)                      ,
      b                => pp2_0_car(6)                      ,
      sum              => pp3_0_sum(6)                      ,
      car              => pp3_0_car(5)                     );
 pp3_0_csa_5: entity work.fuq_csa22_h2(fuq_csa22_h2) port map(  
      a                => pp2_0_sum(5)                      ,
      b                => pp2_0_car(5)                      ,
      sum              => pp3_0_sum(5)                      ,
      car              => pp3_0_car(4)                     );
 pp3_0_csa_4: entity work.fuq_csa22_h2(fuq_csa22_h2) port map(  
      a                => pp2_0_sum(4)                      ,
      b                => pp2_0_car(4)                      ,
      sum              => pp3_0_sum(4)                      ,
      car              => pp3_0_car(3)                     );
 pp3_0_csa_3: entity work.fuq_csa22_h2(fuq_csa22_h2) port map(  
      a                => pp2_0_sum(3)                      ,
      b                => pp2_0_car(3)                      ,
      sum              => pp3_0_sum(3)                      ,
      car              => pp3_0_car(2)                     );
 pp3_0_csa_2: entity work.fuq_csa22_h2(fuq_csa22_h2) port map(  
      a                => pp2_0_sum(2)                      ,
      b                => pp2_0_car(2)                      ,
      sum              => pp3_0_sum(2)                      ,
      car              => pp3_0_car(1)                     );
 pp3_0_csa_1: entity work.fuq_csa22_h2(fuq_csa22_h2) port map(  
      a                => pp2_0_sum(1)                      ,
      b                => pp2_0_car(1)                      ,
      sum              => pp3_0_sum(1)                      ,
      car              => pp3_0_car(0)                     );
 pp3_0_csa_0: entity work.fuq_csa22_h2(fuq_csa22_h2) port map(  
      a                => pp2_0_sum(0)                      ,
      b                => pp2_0_car(0)                      ,
      sum              => pp3_0_sum(0)                      ,
      car              => pp3_0_car_unused                 );




   tbl_sum(0 to 36) <= pp3_0_sum(0 to 36); 
   tbl_car(0 to 35) <= pp3_0_car(0 to 35); 



   


end; 





     




