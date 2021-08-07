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



LIBRARY ieee;       USE ieee.std_logic_1164.all;
                    USE ieee.numeric_std.all;
LIBRARY ibm;        
                    USE ibm.std_ulogic_support.all;
                    USE ibm.std_ulogic_unsigned.all;
                    USE ibm.std_ulogic_function_support.all;
LIBRARY support;    
                    USE support.power_logic_pkg.all;
LIBRARY tri;        USE tri.tri_latches_pkg.all;
LIBRARY clib ;

   
entity xuq_lsu_data_rot32s_ru is
  generic (expand_type : integer := 2 );
  port (

        opsize                  :in  std_ulogic_vector(0 to 5); 
        le                      :in  std_ulogic;
        rotate_sel              :in  std_ulogic_vector(0 to 4);
        algebraic               :in  std_ulogic;
        algebraic_sel           :in  std_ulogic_vector(0 to 4);

        data                    :in  std_ulogic_vector(0 to 31); 
        data_latched            :out std_ulogic_vector(0 to 31); 
        data_rot                :out std_ulogic_vector(0 to 31); 
        algebraic_bit           :out std_ulogic_vector(0 to 5);

        nclk                    :in  clk_logic;
        vdd                     :inout power_logic;
        gnd                     :inout power_logic;
        delay_lclkr_dc          :in  std_ulogic;
        mpw1_dc_b               :in  std_ulogic;
        mpw2_dc_b               :in  std_ulogic;
        func_sl_force           :in  std_ulogic;
        func_sl_thold_0_b       :in  std_ulogic;
        sg_0                    :in  std_ulogic;
        act                     :in  std_ulogic;
        scan_in                 :in  std_ulogic;
        scan_out                :out std_ulogic
    );


end xuq_lsu_data_rot32s_ru;

architecture xuq_lsu_data_rot32s_ru of xuq_lsu_data_rot32s_ru is
   constant tiup                       : std_ulogic := '1';
   constant tidn                       : std_ulogic := '0';

   signal my_d1clk, my_d2clk :std_ulogic ;
   signal my_lclk             :clk_logic ;

   signal di_lat_si,         di_lat_so,         di_q_b,         di_q,         di_din         :std_ulogic_vector(0 to 31);
   signal shx16_gp0_lat_si,  shx16_gp0_lat_so,  shx16_gp0_q_b,  shx16_gp0_q,  shx16_gp0_din  :std_ulogic_vector(0 to 3); 
   signal shx16_gp1_lat_si,  shx16_gp1_lat_so,  shx16_gp1_q_b,  shx16_gp1_q,  shx16_gp1_din  :std_ulogic_vector(0 to 3);
   signal shx04_gp0_lat_si,  shx04_gp0_lat_so,  shx04_gp0_q_b,  shx04_gp0_q,  shx04_gp0_din  :std_ulogic_vector(0 to 3);
   signal shx04_gp1_lat_si,  shx04_gp1_lat_so,  shx04_gp1_q_b,  shx04_gp1_q,  shx04_gp1_din  :std_ulogic_vector(0 to 3);
   signal shx01_gp0_lat_si,  shx01_gp0_lat_so,  shx01_gp0_q_b,  shx01_gp0_q,  shx01_gp0_din  :std_ulogic_vector(0 to 3);
   signal shx01_gp1_lat_si,  shx01_gp1_lat_so,  shx01_gp1_q_b,  shx01_gp1_q,  shx01_gp1_din  :std_ulogic_vector(0 to 3);
   signal mask_lat_si,       mask_lat_so,       mask_q_b,       mask_q,       mask_din       :std_ulogic_vector(0 to 5);
   signal shx16_sgn0_lat_si, shx16_sgn0_lat_so, shx16_sgn0_q_b, shx16_sgn0_q, shx16_sgn0_din :std_ulogic_vector(0 to 1); 
   signal shx04_sgn0_lat_si, shx04_sgn0_lat_so, shx04_sgn0_q_b, shx04_sgn0_q, shx04_sgn0_din :std_ulogic_vector(0 to 3);
   signal shx01_sgn0_lat_si, shx01_sgn0_lat_so, shx01_sgn0_q_b, shx01_sgn0_q, shx01_sgn0_din :std_ulogic_vector(0 to 3);


   signal mx1_0_b, mx1_1_b, mx1 :std_ulogic_vector(0 to 31);
   signal sx1_0_b, sx1_1_b, sx1 :std_ulogic_vector(0 to 15);
   signal mx2_0_b, mx2_1_b, mx2 :std_ulogic_vector(0 to 31);
   signal sx2_0_b, sx2_1_b, sx2 :std_ulogic_vector(0 to 7);
   signal mx3_0_b, mx3_1_b, mx3 :std_ulogic_vector(0 to 31);
   signal sx3_0_b, sx3_1_b, sx3 :std_ulogic_vector(0 to 5);
   signal do_b  :std_ulogic_vector(0 to 31) ; 
   signal sign_copy_b  :std_ulogic_vector(0 to 5) ; 

   signal mx1_d0, mx1_d1, mx1_d2, mx1_d3 :std_ulogic_vector(0 to 31) ; 
   signal mx2_d0, mx2_d1, mx2_d2, mx2_d3 :std_ulogic_vector(0 to 31) ;
   signal sx2_d0, sx2_d1, sx2_d2, sx2_d3 :std_ulogic_vector(0 to 7) ;
   signal mx3_d0, mx3_d1, mx3_d2, mx3_d3 :std_ulogic_vector(0 to 31) ;
   signal sx3_d0, sx3_d1, sx3_d2, sx3_d3 :std_ulogic_vector(0 to 5) ;

   signal mx1_s0, mx1_s1, mx1_s2, mx1_s3 :std_ulogic_vector(0 to 31) ;
   signal sx1_s0, sx1_s1                 :std_ulogic_vector(0 to 15) ;
   signal mx2_s0, mx2_s1, mx2_s2, mx2_s3 :std_ulogic_vector(0 to 31) ;
   signal sx2_s0, sx2_s1, sx2_s2, sx2_s3 :std_ulogic_vector(0 to 7)  ;
   signal mx3_s0, mx3_s1, mx3_s2, mx3_s3 :std_ulogic_vector(0 to 31) ;
   signal sx3_s0, sx3_s1, sx3_s2, sx3_s3 :std_ulogic_vector(0 to 5) ;

   signal mask_en                           :std_ulogic_vector(0 to 31);
   signal shx16_sel , shx04_sel , shx01_sel :std_ulogic_vector(0 to 3);
   signal sgn_amt                           :std_ulogic_vector(0 to 4);
   signal shx04_sgn, shx01_sgn              :std_ulogic_vector(0 to 3);
   signal shx16_sgn                         :std_ulogic_vector(0 to 1);









begin




    shx16_sel(0) <= not le and not rotate_sel(0);
    shx16_sel(1) <= not le and     rotate_sel(0);
    shx16_sel(2) <=     le and not rotate_sel(0);
    shx16_sel(3) <=     le and     rotate_sel(0);

    shx04_sel(0) <= not rotate_sel(1) and not rotate_sel(2);
    shx04_sel(1) <= not rotate_sel(1) and     rotate_sel(2);
    shx04_sel(2) <=     rotate_sel(1) and not rotate_sel(2);
    shx04_sel(3) <=     rotate_sel(1) and     rotate_sel(2);

    shx01_sel(0) <= not rotate_sel(3) and not rotate_sel(4);
    shx01_sel(1) <= not rotate_sel(3) and     rotate_sel(4);
    shx01_sel(2) <=     rotate_sel(3) and not rotate_sel(4);
    shx01_sel(3) <=     rotate_sel(3) and     rotate_sel(4);




    sgn_amt(0) <= algebraic_sel(0);
    sgn_amt(1) <= algebraic_sel(1);
    sgn_amt(2) <= algebraic_sel(2);
    sgn_amt(3) <= algebraic_sel(3);
    sgn_amt(4) <= algebraic_sel(4);

    shx16_sgn(0) <=            not sgn_amt(0);
    shx16_sgn(1) <=                sgn_amt(0);

    shx04_sgn(0) <= not sgn_amt(1) and not sgn_amt(2);
    shx04_sgn(1) <= not sgn_amt(1) and     sgn_amt(2);
    shx04_sgn(2) <=     sgn_amt(1) and not sgn_amt(2);
    shx04_sgn(3) <=     sgn_amt(1) and     sgn_amt(2);

    shx01_sgn(0) <= not sgn_amt(3) and not sgn_amt(4) and algebraic ;
    shx01_sgn(1) <= not sgn_amt(3) and     sgn_amt(4) and algebraic ;
    shx01_sgn(2) <=     sgn_amt(3) and not sgn_amt(4) and algebraic ;
    shx01_sgn(3) <=     sgn_amt(3) and     sgn_amt(4) and algebraic ;

    mask_din(0)           <= opsize(0)                ;
    mask_din(1)           <= opsize(1) or mask_din(0) ;
    mask_din(2)           <= opsize(2) or mask_din(1) ;
    mask_din(3)           <= opsize(3) or mask_din(2) ;
    mask_din(4)           <= opsize(4) or mask_din(3) ;
    mask_din(5)           <= opsize(5) or mask_din(4) ;

    di_din(0 to 31)        <= data(0 to 31);
    shx16_gp0_din(0 to 3)  <= shx16_sel(0 to 3);
    shx16_gp1_din(0 to 3)  <= shx16_sel(0 to 3);
    shx04_gp0_din(0 to 3)  <= shx04_sel(0 to 3);
    shx04_gp1_din(0 to 3)  <= shx04_sel(0 to 3);
    shx01_gp0_din(0 to 3)  <= shx01_sel(0 to 3);
    shx01_gp1_din(0 to 3)  <= shx01_sel(0 to 3);
    shx16_sgn0_din(0 to 1) <= shx16_sgn(0 to 1);
    shx04_sgn0_din(0 to 3) <= shx04_sgn(0 to 3);
    shx01_sgn0_din(0 to 3) <= shx01_sgn(0 to 3);



     u_di_q:         di_q(0 to 31)         <= not di_q_b(0 to 31)        ;
     u_shx16_gp0_q:  shx16_gp0_q(0 to 3)   <= not shx16_gp0_q_b(0 to 3)  ;
     u_shx16_gp1_q:  shx16_gp1_q(0 to 3)   <= not shx16_gp1_q_b(0 to 3)  ;
     u_shx04_gp0_q:  shx04_gp0_q(0 to 3)   <= not shx04_gp0_q_b(0 to 3)  ;
     u_shx04_gp1_q:  shx04_gp1_q(0 to 3)   <= not shx04_gp1_q_b(0 to 3)  ;
     u_shx01_gp0_q:  shx01_gp0_q(0 to 3)   <= not shx01_gp0_q_b(0 to 3)  ;
     u_shx01_gp1_q:  shx01_gp1_q(0 to 3)   <= not shx01_gp1_q_b(0 to 3)  ;
     u_shx16_sgn0_q: shx16_sgn0_q(0 to 1)  <= not shx16_sgn0_q_b(0 to 1)  ;
     u_shx04_sgn0_q: shx04_sgn0_q(0 to 3)  <= not shx04_sgn0_q_b(0 to 3)  ;
     u_shx01_sgn0_q: shx01_sgn0_q(0 to 3)  <= not shx01_sgn0_q_b(0 to 3)  ;
                     mask_q(0 to 5)        <= not mask_q_b(0 to 5)       ;

 
    mx1_s0( 0 to 15)  <= ( 0 to 15=> shx16_gp0_q(0) ) ; 
    mx1_s1( 0 to 15)  <= ( 0 to 15=> shx16_gp0_q(1) ) ; 
    mx1_s2( 0 to 15)  <= ( 0 to 15=> shx16_gp0_q(2) ) ; 
    mx1_s3( 0 to 15)  <= ( 0 to 15=> shx16_gp0_q(3) ) ; 
    mx1_s0(16 to 31)  <= (16 to 31=> shx16_gp1_q(0) ) ; 
    mx1_s1(16 to 31)  <= (16 to 31=> shx16_gp1_q(1) ) ; 
    mx1_s2(16 to 31)  <= (16 to 31=> shx16_gp1_q(2) ) ; 
    mx1_s3(16 to 31)  <= (16 to 31=> shx16_gp1_q(3) ) ; 
 
    sx1_s0( 0 to 15)  <= ( 0 to 15=> shx16_sgn0_q(0) ) ; 
    sx1_s1( 0 to 15)  <= ( 0 to 15=> shx16_sgn0_q(1) ) ; 
 
    mx1_d0(0)  <= di_q(0)    ;  mx1_d1(0)  <= di_q(16)   ;  mx1_d2(0)  <= di_q(31)   ;  mx1_d3(0)  <= di_q(15)   ; 
    mx1_d0(1)  <= di_q(1)    ;  mx1_d1(1)  <= di_q(17)   ;  mx1_d2(1)  <= di_q(30)   ;  mx1_d3(1)  <= di_q(14)   ; 
    mx1_d0(2)  <= di_q(2)    ;  mx1_d1(2)  <= di_q(18)   ;  mx1_d2(2)  <= di_q(29)   ;  mx1_d3(2)  <= di_q(13)   ; 
    mx1_d0(3)  <= di_q(3)    ;  mx1_d1(3)  <= di_q(19)   ;  mx1_d2(3)  <= di_q(28)   ;  mx1_d3(3)  <= di_q(12)   ; 
    mx1_d0(4)  <= di_q(4)    ;  mx1_d1(4)  <= di_q(20)   ;  mx1_d2(4)  <= di_q(27)   ;  mx1_d3(4)  <= di_q(11)   ; 
    mx1_d0(5)  <= di_q(5)    ;  mx1_d1(5)  <= di_q(21)   ;  mx1_d2(5)  <= di_q(26)   ;  mx1_d3(5)  <= di_q(10)   ; 
    mx1_d0(6)  <= di_q(6)    ;  mx1_d1(6)  <= di_q(22)   ;  mx1_d2(6)  <= di_q(25)   ;  mx1_d3(6)  <= di_q(9)    ; 
    mx1_d0(7)  <= di_q(7)    ;  mx1_d1(7)  <= di_q(23)   ;  mx1_d2(7)  <= di_q(24)   ;  mx1_d3(7)  <= di_q(8)    ; 
    mx1_d0(8)  <= di_q(8)    ;  mx1_d1(8)  <= di_q(24)   ;  mx1_d2(8)  <= di_q(23)   ;  mx1_d3(8)  <= di_q(7)    ; 
    mx1_d0(9)  <= di_q(9)    ;  mx1_d1(9)  <= di_q(25)   ;  mx1_d2(9)  <= di_q(22)   ;  mx1_d3(9)  <= di_q(6)    ; 
    mx1_d0(10) <= di_q(10)   ;  mx1_d1(10) <= di_q(26)   ;  mx1_d2(10) <= di_q(21)   ;  mx1_d3(10) <= di_q(5)    ; 
    mx1_d0(11) <= di_q(11)   ;  mx1_d1(11) <= di_q(27)   ;  mx1_d2(11) <= di_q(20)   ;  mx1_d3(11) <= di_q(4)    ; 
    mx1_d0(12) <= di_q(12)   ;  mx1_d1(12) <= di_q(28)   ;  mx1_d2(12) <= di_q(19)   ;  mx1_d3(12) <= di_q(3)    ; 
    mx1_d0(13) <= di_q(13)   ;  mx1_d1(13) <= di_q(29)   ;  mx1_d2(13) <= di_q(18)   ;  mx1_d3(13) <= di_q(2)    ; 
    mx1_d0(14) <= di_q(14)   ;  mx1_d1(14) <= di_q(30)   ;  mx1_d2(14) <= di_q(17)   ;  mx1_d3(14) <= di_q(1)    ; 
    mx1_d0(15) <= di_q(15)   ;  mx1_d1(15) <= di_q(31)   ;  mx1_d2(15) <= di_q(16)   ;  mx1_d3(15) <= di_q(0)    ; 
    mx1_d0(16) <= di_q(16)   ;  mx1_d1(16) <= di_q(0)    ;  mx1_d2(16) <= di_q(15)   ;  mx1_d3(16) <= di_q(31)   ; 
    mx1_d0(17) <= di_q(17)   ;  mx1_d1(17) <= di_q(1)    ;  mx1_d2(17) <= di_q(14)   ;  mx1_d3(17) <= di_q(30)   ; 
    mx1_d0(18) <= di_q(18)   ;  mx1_d1(18) <= di_q(2)    ;  mx1_d2(18) <= di_q(13)   ;  mx1_d3(18) <= di_q(29)   ; 
    mx1_d0(19) <= di_q(19)   ;  mx1_d1(19) <= di_q(3)    ;  mx1_d2(19) <= di_q(12)   ;  mx1_d3(19) <= di_q(28)   ; 
    mx1_d0(20) <= di_q(20)   ;  mx1_d1(20) <= di_q(4)    ;  mx1_d2(20) <= di_q(11)   ;  mx1_d3(20) <= di_q(27)   ; 
    mx1_d0(21) <= di_q(21)   ;  mx1_d1(21) <= di_q(5)    ;  mx1_d2(21) <= di_q(10)   ;  mx1_d3(21) <= di_q(26)   ; 
    mx1_d0(22) <= di_q(22)   ;  mx1_d1(22) <= di_q(6)    ;  mx1_d2(22) <= di_q(9)    ;  mx1_d3(22) <= di_q(25)   ; 
    mx1_d0(23) <= di_q(23)   ;  mx1_d1(23) <= di_q(7)    ;  mx1_d2(23) <= di_q(8)    ;  mx1_d3(23) <= di_q(24)   ; 
    mx1_d0(24) <= di_q(24)   ;  mx1_d1(24) <= di_q(8)    ;  mx1_d2(24) <= di_q(7)    ;  mx1_d3(24) <= di_q(23)   ; 
    mx1_d0(25) <= di_q(25)   ;  mx1_d1(25) <= di_q(9)    ;  mx1_d2(25) <= di_q(6)    ;  mx1_d3(25) <= di_q(22)   ; 
    mx1_d0(26) <= di_q(26)   ;  mx1_d1(26) <= di_q(10)   ;  mx1_d2(26) <= di_q(5)    ;  mx1_d3(26) <= di_q(21)   ; 
    mx1_d0(27) <= di_q(27)   ;  mx1_d1(27) <= di_q(11)   ;  mx1_d2(27) <= di_q(4)    ;  mx1_d3(27) <= di_q(20)   ; 
    mx1_d0(28) <= di_q(28)   ;  mx1_d1(28) <= di_q(12)   ;  mx1_d2(28) <= di_q(3)    ;  mx1_d3(28) <= di_q(19)   ; 
    mx1_d0(29) <= di_q(29)   ;  mx1_d1(29) <= di_q(13)   ;  mx1_d2(29) <= di_q(2)    ;  mx1_d3(29) <= di_q(18)   ; 
    mx1_d0(30) <= di_q(30)   ;  mx1_d1(30) <= di_q(14)   ;  mx1_d2(30) <= di_q(1)    ;  mx1_d3(30) <= di_q(17)   ; 
    mx1_d0(31) <= di_q(31)   ;  mx1_d1(31) <= di_q(15)   ;  mx1_d2(31) <= di_q(0)    ;  mx1_d3(31) <= di_q(16)   ; 


    u_mx1_0:  mx1_0_b(0 to 31) <= not( (mx1_s0(0 to 31) and mx1_d0(0 to 31)  ) or
                                       (mx1_s1(0 to 31) and mx1_d1(0 to 31)  ) ); 

    u_mx1_1:  mx1_1_b(0 to 31) <= not( (mx1_s2(0 to 31) and mx1_d2(0 to 31)  ) or
                                       (mx1_s3(0 to 31) and mx1_d3(0 to 31)  ) ); 
 
    u_mx1:    mx1(0 to 31)     <= not( mx1_0_b(0 to 31) and mx1_1_b(0 to 31) );



  
    u_sx1_0:  sx1_0_b(0 to 15) <= not( sx1_s0(0 to 15)  and mx1_d0(0 to 15)  ) ;
    u_sx1_1:  sx1_1_b(0 to 15) <= not( sx1_s1(0 to 15)  and mx1_d1(0 to 15)  ) ; 
    u_sx1:    sx1(0 to 15)     <= not( sx1_0_b(0 to 15) and sx1_1_b(0 to 15) );


    mx2_s0( 0 to 15)  <= ( 0 to 15=> shx04_gp0_q(0) ) ; 
    mx2_s1( 0 to 15)  <= ( 0 to 15=> shx04_gp0_q(1) ) ; 
    mx2_s2( 0 to 15)  <= ( 0 to 15=> shx04_gp0_q(2) ) ; 
    mx2_s3( 0 to 15)  <= ( 0 to 15=> shx04_gp0_q(3) ) ; 
    mx2_s0(16 to 31)  <= (16 to 31=> shx04_gp1_q(0) ) ; 
    mx2_s1(16 to 31)  <= (16 to 31=> shx04_gp1_q(1) ) ; 
    mx2_s2(16 to 31)  <= (16 to 31=> shx04_gp1_q(2) ) ; 
    mx2_s3(16 to 31)  <= (16 to 31=> shx04_gp1_q(3) ) ; 
 

    mx2_d0(0)  <= mx1(0)    ;  mx2_d1(0)  <= mx1(28) ;  mx2_d2(0)  <= mx1(24) ;  mx2_d3(0)  <= mx1(20) ; 
    mx2_d0(1)  <= mx1(1)    ;  mx2_d1(1)  <= mx1(29) ;  mx2_d2(1)  <= mx1(25) ;  mx2_d3(1)  <= mx1(21) ; 
    mx2_d0(2)  <= mx1(2)    ;  mx2_d1(2)  <= mx1(30) ;  mx2_d2(2)  <= mx1(26) ;  mx2_d3(2)  <= mx1(22) ; 
    mx2_d0(3)  <= mx1(3)    ;  mx2_d1(3)  <= mx1(31) ;  mx2_d2(3)  <= mx1(27) ;  mx2_d3(3)  <= mx1(23) ; 
    mx2_d0(4)  <= mx1(4)    ;  mx2_d1(4)  <= mx1(0)  ;  mx2_d2(4)  <= mx1(28) ;  mx2_d3(4)  <= mx1(24) ; 
    mx2_d0(5)  <= mx1(5)    ;  mx2_d1(5)  <= mx1(1)  ;  mx2_d2(5)  <= mx1(29) ;  mx2_d3(5)  <= mx1(25) ; 
    mx2_d0(6)  <= mx1(6)    ;  mx2_d1(6)  <= mx1(2)  ;  mx2_d2(6)  <= mx1(30) ;  mx2_d3(6)  <= mx1(26) ; 
    mx2_d0(7)  <= mx1(7)    ;  mx2_d1(7)  <= mx1(3)  ;  mx2_d2(7)  <= mx1(31) ;  mx2_d3(7)  <= mx1(27) ; 
    mx2_d0(8)  <= mx1(8)    ;  mx2_d1(8)  <= mx1(4)  ;  mx2_d2(8)  <= mx1(0)  ;  mx2_d3(8)  <= mx1(28) ; 
    mx2_d0(9)  <= mx1(9)    ;  mx2_d1(9)  <= mx1(5)  ;  mx2_d2(9)  <= mx1(1)  ;  mx2_d3(9)  <= mx1(29) ; 
    mx2_d0(10) <= mx1(10)   ;  mx2_d1(10) <= mx1(6)  ;  mx2_d2(10) <= mx1(2)  ;  mx2_d3(10) <= mx1(30) ; 
    mx2_d0(11) <= mx1(11)   ;  mx2_d1(11) <= mx1(7)  ;  mx2_d2(11) <= mx1(3)  ;  mx2_d3(11) <= mx1(31) ; 
    mx2_d0(12) <= mx1(12)   ;  mx2_d1(12) <= mx1(8)  ;  mx2_d2(12) <= mx1(4)  ;  mx2_d3(12) <= mx1(0)  ; 
    mx2_d0(13) <= mx1(13)   ;  mx2_d1(13) <= mx1(9)  ;  mx2_d2(13) <= mx1(5)  ;  mx2_d3(13) <= mx1(1)  ; 
    mx2_d0(14) <= mx1(14)   ;  mx2_d1(14) <= mx1(10) ;  mx2_d2(14) <= mx1(6)  ;  mx2_d3(14) <= mx1(2)  ; 
    mx2_d0(15) <= mx1(15)   ;  mx2_d1(15) <= mx1(11) ;  mx2_d2(15) <= mx1(7)  ;  mx2_d3(15) <= mx1(3)  ; 
    mx2_d0(16) <= mx1(16)   ;  mx2_d1(16) <= mx1(12) ;  mx2_d2(16) <= mx1(8)  ;  mx2_d3(16) <= mx1(4)  ; 
    mx2_d0(17) <= mx1(17)   ;  mx2_d1(17) <= mx1(13) ;  mx2_d2(17) <= mx1(9)  ;  mx2_d3(17) <= mx1(5)  ; 
    mx2_d0(18) <= mx1(18)   ;  mx2_d1(18) <= mx1(14) ;  mx2_d2(18) <= mx1(10) ;  mx2_d3(18) <= mx1(6)  ; 
    mx2_d0(19) <= mx1(19)   ;  mx2_d1(19) <= mx1(15) ;  mx2_d2(19) <= mx1(11) ;  mx2_d3(19) <= mx1(7)  ; 
    mx2_d0(20) <= mx1(20)   ;  mx2_d1(20) <= mx1(16) ;  mx2_d2(20) <= mx1(12) ;  mx2_d3(20) <= mx1(8)  ; 
    mx2_d0(21) <= mx1(21)   ;  mx2_d1(21) <= mx1(17) ;  mx2_d2(21) <= mx1(13) ;  mx2_d3(21) <= mx1(9)  ; 
    mx2_d0(22) <= mx1(22)   ;  mx2_d1(22) <= mx1(18) ;  mx2_d2(22) <= mx1(14) ;  mx2_d3(22) <= mx1(10) ; 
    mx2_d0(23) <= mx1(23)   ;  mx2_d1(23) <= mx1(19) ;  mx2_d2(23) <= mx1(15) ;  mx2_d3(23) <= mx1(11) ; 
    mx2_d0(24) <= mx1(24)   ;  mx2_d1(24) <= mx1(20) ;  mx2_d2(24) <= mx1(16) ;  mx2_d3(24) <= mx1(12) ; 
    mx2_d0(25) <= mx1(25)   ;  mx2_d1(25) <= mx1(21) ;  mx2_d2(25) <= mx1(17) ;  mx2_d3(25) <= mx1(13) ; 
    mx2_d0(26) <= mx1(26)   ;  mx2_d1(26) <= mx1(22) ;  mx2_d2(26) <= mx1(18) ;  mx2_d3(26) <= mx1(14) ; 
    mx2_d0(27) <= mx1(27)   ;  mx2_d1(27) <= mx1(23) ;  mx2_d2(27) <= mx1(19) ;  mx2_d3(27) <= mx1(15) ; 
    mx2_d0(28) <= mx1(28)   ;  mx2_d1(28) <= mx1(24) ;  mx2_d2(28) <= mx1(20) ;  mx2_d3(28) <= mx1(16) ; 
    mx2_d0(29) <= mx1(29)   ;  mx2_d1(29) <= mx1(25) ;  mx2_d2(29) <= mx1(21) ;  mx2_d3(29) <= mx1(17) ; 
    mx2_d0(30) <= mx1(30)   ;  mx2_d1(30) <= mx1(26) ;  mx2_d2(30) <= mx1(22) ;  mx2_d3(30) <= mx1(18) ; 
    mx2_d0(31) <= mx1(31)   ;  mx2_d1(31) <= mx1(27) ;  mx2_d2(31) <= mx1(23) ;  mx2_d3(31) <= mx1(19) ; 
   
       
    u_mx2_0:  mx2_0_b(0 to 31) <= not( (mx2_s0(0 to 31) and mx2_d0(0 to 31)  ) or
                                       (mx2_s1(0 to 31) and mx2_d1(0 to 31)  ) ); 
    
    u_mx2_1:  mx2_1_b(0 to 31) <= not( (mx2_s2(0 to 31) and mx2_d2(0 to 31)  ) or
                                       (mx2_s3(0 to 31) and mx2_d3(0 to 31)  ) ); 
    
    u_mx2:    mx2(0 to 31)     <= not( mx2_0_b(0 to 31) and mx2_1_b(0 to 31) );
   

    sx2_s0( 0 to 7)  <= ( 0 to 7=> shx04_sgn0_q(0) ) ; 
    sx2_s1( 0 to 7)  <= ( 0 to 7=> shx04_sgn0_q(1) ) ; 
    sx2_s2( 0 to 7)  <= ( 0 to 7=> shx04_sgn0_q(2) ) ; 
    sx2_s3( 0 to 7)  <= ( 0 to 7=> shx04_sgn0_q(3) ) ; 

    sx2_d0(0)  <= sx1(0)    ;  sx2_d1(0)  <= sx1(4)    ;  sx2_d2(0)  <= sx1(8)    ;  sx2_d3(0)  <= sx1(12)   ; 
    sx2_d0(1)  <= sx1(1)    ;  sx2_d1(1)  <= sx1(5)    ;  sx2_d2(1)  <= sx1(9)    ;  sx2_d3(1)  <= sx1(13)   ; 
    sx2_d0(2)  <= sx1(2)    ;  sx2_d1(2)  <= sx1(6)    ;  sx2_d2(2)  <= sx1(10)   ;  sx2_d3(2)  <= sx1(14)   ; 
    sx2_d0(3)  <= sx1(3)    ;  sx2_d1(3)  <= sx1(7)    ;  sx2_d2(3)  <= sx1(11)   ;  sx2_d3(3)  <= sx1(15)   ; 
    sx2_d0(4)  <= sx1(0)    ;  sx2_d1(4)  <= sx1(4)    ;  sx2_d2(4)  <= sx1(8)    ;  sx2_d3(4)  <= sx1(12)   ; 
    sx2_d0(5)  <= sx1(1)    ;  sx2_d1(5)  <= sx1(5)    ;  sx2_d2(5)  <= sx1(9)    ;  sx2_d3(5)  <= sx1(13)   ; 
    sx2_d0(6)  <= sx1(2)    ;  sx2_d1(6)  <= sx1(6)    ;  sx2_d2(6)  <= sx1(10)   ;  sx2_d3(6)  <= sx1(14)   ; 
    sx2_d0(7)  <= sx1(3)    ;  sx2_d1(7)  <= sx1(7)    ;  sx2_d2(7)  <= sx1(11)   ;  sx2_d3(7)  <= sx1(15)   ; 




    u_sx2_0:  sx2_0_b(0 to 7) <= not( (sx2_s0(0 to 7) and sx2_d0(0 to 7)  ) or
                                      (sx2_s1(0 to 7) and sx2_d1(0 to 7)  ) ); 
    
    u_sx2_1:  sx2_1_b(0 to 7) <= not( (sx2_s2(0 to 7) and sx2_d2(0 to 7)  ) or
                                      (sx2_s3(0 to 7) and sx2_d3(0 to 7)  ) ); 
    
    u_sx2:    sx2(0 to 7)     <= not( sx2_0_b(0 to 7) and sx2_1_b(0 to 7) );


    mask_en( 0 to 15) <= ( 0 to 15=> mask_q(0) ); 
    mask_en(16 to 23) <= (16 to 23=> mask_q(1) ); 
    mask_en(24 to 27) <= (24 to 27=> mask_q(2) ); 
    mask_en(28 to 29) <= (28 to 29=> mask_q(3) ); 
    mask_en(30)       <= (           mask_q(4) ); 
    mask_en(31)       <= (           mask_q(5) ); 

    mx3_s0( 0 to 15)  <= ( 0 to 15=> shx01_gp0_q(0) ) and mask_en( 0 to 15); 
    mx3_s1( 0 to 15)  <= ( 0 to 15=> shx01_gp0_q(1) ) and mask_en( 0 to 15); 
    mx3_s2( 0 to 15)  <= ( 0 to 15=> shx01_gp0_q(2) ) and mask_en( 0 to 15); 
    mx3_s3( 0 to 15)  <= ( 0 to 15=> shx01_gp0_q(3) ) and mask_en( 0 to 15); 
    mx3_s0(16 to 31)  <= (16 to 31=> shx01_gp1_q(0) ) and mask_en(16 to 31); 
    mx3_s1(16 to 31)  <= (16 to 31=> shx01_gp1_q(1) ) and mask_en(16 to 31); 
    mx3_s2(16 to 31)  <= (16 to 31=> shx01_gp1_q(2) ) and mask_en(16 to 31); 
    mx3_s3(16 to 31)  <= (16 to 31=> shx01_gp1_q(3) ) and mask_en(16 to 31); 


    mx3_d0(0)  <= mx2(0)  ;  mx3_d1(0)  <= mx2(31) ;  mx3_d2(0)  <= mx2(30) ;  mx3_d3(0)  <= mx2(29) ; 
    mx3_d0(1)  <= mx2(1)  ;  mx3_d1(1)  <= mx2(0)  ;  mx3_d2(1)  <= mx2(31) ;  mx3_d3(1)  <= mx2(30) ; 
    mx3_d0(2)  <= mx2(2)  ;  mx3_d1(2)  <= mx2(1)  ;  mx3_d2(2)  <= mx2(0)  ;  mx3_d3(2)  <= mx2(31) ; 
    mx3_d0(3)  <= mx2(3)  ;  mx3_d1(3)  <= mx2(2)  ;  mx3_d2(3)  <= mx2(1)  ;  mx3_d3(3)  <= mx2(0)  ; 
    mx3_d0(4)  <= mx2(4)  ;  mx3_d1(4)  <= mx2(3)  ;  mx3_d2(4)  <= mx2(2)  ;  mx3_d3(4)  <= mx2(1)  ; 
    mx3_d0(5)  <= mx2(5)  ;  mx3_d1(5)  <= mx2(4)  ;  mx3_d2(5)  <= mx2(3)  ;  mx3_d3(5)  <= mx2(2)  ; 
    mx3_d0(6)  <= mx2(6)  ;  mx3_d1(6)  <= mx2(5)  ;  mx3_d2(6)  <= mx2(4)  ;  mx3_d3(6)  <= mx2(3)  ; 
    mx3_d0(7)  <= mx2(7)  ;  mx3_d1(7)  <= mx2(6)  ;  mx3_d2(7)  <= mx2(5)  ;  mx3_d3(7)  <= mx2(4)  ; 
    mx3_d0(8)  <= mx2(8)  ;  mx3_d1(8)  <= mx2(7)  ;  mx3_d2(8)  <= mx2(6)  ;  mx3_d3(8)  <= mx2(5)  ; 
    mx3_d0(9)  <= mx2(9)  ;  mx3_d1(9)  <= mx2(8)  ;  mx3_d2(9)  <= mx2(7)  ;  mx3_d3(9)  <= mx2(6)  ; 
    mx3_d0(10) <= mx2(10) ;  mx3_d1(10) <= mx2(9)  ;  mx3_d2(10) <= mx2(8)  ;  mx3_d3(10) <= mx2(7)  ; 
    mx3_d0(11) <= mx2(11) ;  mx3_d1(11) <= mx2(10) ;  mx3_d2(11) <= mx2(9)  ;  mx3_d3(11) <= mx2(8)  ; 
    mx3_d0(12) <= mx2(12) ;  mx3_d1(12) <= mx2(11) ;  mx3_d2(12) <= mx2(10) ;  mx3_d3(12) <= mx2(9)  ; 
    mx3_d0(13) <= mx2(13) ;  mx3_d1(13) <= mx2(12) ;  mx3_d2(13) <= mx2(11) ;  mx3_d3(13) <= mx2(10) ; 
    mx3_d0(14) <= mx2(14) ;  mx3_d1(14) <= mx2(13) ;  mx3_d2(14) <= mx2(12) ;  mx3_d3(14) <= mx2(11) ; 
    mx3_d0(15) <= mx2(15) ;  mx3_d1(15) <= mx2(14) ;  mx3_d2(15) <= mx2(13) ;  mx3_d3(15) <= mx2(12) ; 
    mx3_d0(16) <= mx2(16) ;  mx3_d1(16) <= mx2(15) ;  mx3_d2(16) <= mx2(14) ;  mx3_d3(16) <= mx2(13) ; 
    mx3_d0(17) <= mx2(17) ;  mx3_d1(17) <= mx2(16) ;  mx3_d2(17) <= mx2(15) ;  mx3_d3(17) <= mx2(14) ; 
    mx3_d0(18) <= mx2(18) ;  mx3_d1(18) <= mx2(17) ;  mx3_d2(18) <= mx2(16) ;  mx3_d3(18) <= mx2(15) ; 
    mx3_d0(19) <= mx2(19) ;  mx3_d1(19) <= mx2(18) ;  mx3_d2(19) <= mx2(17) ;  mx3_d3(19) <= mx2(16) ; 
    mx3_d0(20) <= mx2(20) ;  mx3_d1(20) <= mx2(19) ;  mx3_d2(20) <= mx2(18) ;  mx3_d3(20) <= mx2(17) ; 
    mx3_d0(21) <= mx2(21) ;  mx3_d1(21) <= mx2(20) ;  mx3_d2(21) <= mx2(19) ;  mx3_d3(21) <= mx2(18) ; 
    mx3_d0(22) <= mx2(22) ;  mx3_d1(22) <= mx2(21) ;  mx3_d2(22) <= mx2(20) ;  mx3_d3(22) <= mx2(19) ; 
    mx3_d0(23) <= mx2(23) ;  mx3_d1(23) <= mx2(22) ;  mx3_d2(23) <= mx2(21) ;  mx3_d3(23) <= mx2(20) ; 
    mx3_d0(24) <= mx2(24) ;  mx3_d1(24) <= mx2(23) ;  mx3_d2(24) <= mx2(22) ;  mx3_d3(24) <= mx2(21) ; 
    mx3_d0(25) <= mx2(25) ;  mx3_d1(25) <= mx2(24) ;  mx3_d2(25) <= mx2(23) ;  mx3_d3(25) <= mx2(22) ; 
    mx3_d0(26) <= mx2(26) ;  mx3_d1(26) <= mx2(25) ;  mx3_d2(26) <= mx2(24) ;  mx3_d3(26) <= mx2(23) ; 
    mx3_d0(27) <= mx2(27) ;  mx3_d1(27) <= mx2(26) ;  mx3_d2(27) <= mx2(25) ;  mx3_d3(27) <= mx2(24) ; 
    mx3_d0(28) <= mx2(28) ;  mx3_d1(28) <= mx2(27) ;  mx3_d2(28) <= mx2(26) ;  mx3_d3(28) <= mx2(25) ; 
    mx3_d0(29) <= mx2(29) ;  mx3_d1(29) <= mx2(28) ;  mx3_d2(29) <= mx2(27) ;  mx3_d3(29) <= mx2(26) ; 
    mx3_d0(30) <= mx2(30) ;  mx3_d1(30) <= mx2(29) ;  mx3_d2(30) <= mx2(28) ;  mx3_d3(30) <= mx2(27) ; 
    mx3_d0(31) <= mx2(31) ;  mx3_d1(31) <= mx2(30) ;  mx3_d2(31) <= mx2(29) ;  mx3_d3(31) <= mx2(28) ; 
   
    u_mx3_0:  mx3_0_b(0 to 31) <= not( (mx3_s0(0 to 31) and mx3_d0(0 to 31)  ) or
                                       (mx3_s1(0 to 31) and mx3_d1(0 to 31)  ) ); 
    
    u_mx3_1:  mx3_1_b(0 to 31) <= not( (mx3_s2(0 to 31) and mx3_d2(0 to 31)  ) or
                                       (mx3_s3(0 to 31) and mx3_d3(0 to 31)  ) ); 
    
    u_mx3:    mx3(0 to 31)     <= not( mx3_0_b(0 to 31) and mx3_1_b(0 to 31) );
   
    u_oi1:    do_b(0 to 31)     <= not( mx3(0 to 31) ) ;   
    u_oi2:    data_rot(0 to 31) <= not( do_b(0 to 31) ) ;

    u_oth_i: data_latched <= not di_q_b;

    sx3_s0( 0 to 3)  <= ( 0 to 3=> shx01_sgn0_q(0) ) ; 
    sx3_s1( 0 to 3)  <= ( 0 to 3=> shx01_sgn0_q(1) ) ; 
    sx3_s2( 0 to 3)  <= ( 0 to 3=> shx01_sgn0_q(2) ) ; 
    sx3_s3( 0 to 3)  <= ( 0 to 3=> shx01_sgn0_q(3) ) ; 

    sx3_s0( 4 to 5)  <= ( 4 to 5=> shx01_sgn0_q(0) ) and (4 to 5=> not mask_q(3) ); 
    sx3_s1( 4 to 5)  <= ( 4 to 5=> shx01_sgn0_q(1) ) and (4 to 5=> not mask_q(3) ); 
    sx3_s2( 4 to 5)  <= ( 4 to 5=> shx01_sgn0_q(2) ) and (4 to 5=> not mask_q(3) ); 
    sx3_s3( 4 to 5)  <= ( 4 to 5=> shx01_sgn0_q(3) ) and (4 to 5=> not mask_q(3) ); 

    sx3_d0(0)  <= sx2(0)     ;  sx3_d1(0)  <= sx2(1)     ;  sx3_d2(0)  <= sx2(2)     ;  sx3_d3(0)  <= sx2(3)     ; 
    sx3_d0(1)  <= sx2(0)     ;  sx3_d1(1)  <= sx2(1)     ;  sx3_d2(1)  <= sx2(2)     ;  sx3_d3(1)  <= sx2(3)     ; 
    sx3_d0(2)  <= sx2(0)     ;  sx3_d1(2)  <= sx2(1)     ;  sx3_d2(2)  <= sx2(2)     ;  sx3_d3(2)  <= sx2(3)     ; 
    sx3_d0(3)  <= sx2(4)     ;  sx3_d1(3)  <= sx2(5)     ;  sx3_d2(3)  <= sx2(6)     ;  sx3_d3(3)  <= sx2(7)     ; 
    sx3_d0(4)  <= sx2(4)     ;  sx3_d1(4)  <= sx2(5)     ;  sx3_d2(4)  <= sx2(6)     ;  sx3_d3(4)  <= sx2(7)     ; 
    sx3_d0(5)  <= sx2(4)     ;  sx3_d1(5)  <= sx2(5)     ;  sx3_d2(5)  <= sx2(6)     ;  sx3_d3(5)  <= sx2(7)     ; 

 
    u_sx3_0:  sx3_0_b(0 to 5) <= not( (sx3_s0(0 to 5) and sx3_d0(0 to 5)  ) or
                                      (sx3_s1(0 to 5) and sx3_d1(0 to 5)  ) ); 
    
    u_sx3_1:  sx3_1_b(0 to 5) <= not( (sx3_s2(0 to 5) and sx3_d2(0 to 5)  ) or
                                      (sx3_s3(0 to 5) and sx3_d3(0 to 5)  ) ); 
    
    u_sx3:    sx3(0 to 5)     <= not( sx3_0_b(0 to 5) and sx3_1_b(0 to 5) );
   
    u_oi1s:   sign_copy_b(0 to 5)   <= not( sx3(0 to 5) ) ;
    u_oi2s:   algebraic_bit(0 to 5) <= not( sign_copy_b(0 to 5) ) ;



   di_lat:   entity tri.tri_inv_nlats(tri_inv_nlats) generic map (width=> 32, init=>(1 to 32=>'0'), btr => "NLI0001_X4_A12TH", expand_type => expand_type, needs_sreset => 0   ) port map (
        VD               => vdd                       ,
        GD               => gnd                       ,
        LCLK             => my_lclk                   ,
        D1CLK            => my_d1clk                  ,
        D2CLK            => my_d2clk                  ,
        SCANIN           => di_lat_si                 ,                    
        SCANOUT          => di_lat_so                 ,          
        D                => di_din(0 to 31)           ,
        QB               => di_q_b(0 to 31)    );

   shx16_gp0_lat:   entity tri.tri_inv_nlats(tri_inv_nlats) generic map (width=> 4, init=>(1 to 4=>'0'), btr => "NLI0001_X4_A12TH", expand_type => expand_type, needs_sreset => 0   ) port map (
        VD               => vdd                       ,
        GD               => gnd                       ,
        LCLK             => my_lclk                   ,
        D1CLK            => my_d1clk                  ,
        D2CLK            => my_d2clk                  ,
        SCANIN           => shx16_gp0_lat_si          ,                    
        SCANOUT          => shx16_gp0_lat_so          ,          
        D                => shx16_gp0_din             ,
        QB               => shx16_gp0_q_b(0 to 3)    );

   shx16_gp1_lat:   entity tri.tri_inv_nlats(tri_inv_nlats) generic map (width=> 4, init=>(1 to 4=>'0'), btr => "NLI0001_X4_A12TH", expand_type => expand_type, needs_sreset => 0   ) port map (
        VD               => vdd                       ,
        GD               => gnd                       ,
        LCLK             => my_lclk                   ,
        D1CLK            => my_d1clk                  ,
        D2CLK            => my_d2clk                  ,
        SCANIN           => shx16_gp1_lat_si          ,                    
        SCANOUT          => shx16_gp1_lat_so          ,          
        D                => shx16_gp1_din             ,
        QB               => shx16_gp1_q_b(0 to 3)    );

   shx04_gp0_lat:   entity tri.tri_inv_nlats(tri_inv_nlats) generic map (width=> 4, init=>(1 to 4=>'0'), btr => "NLI0001_X2_A12TH", expand_type => expand_type, needs_sreset => 0   ) port map (
        VD               => vdd                       ,
        GD               => gnd                       ,
        LCLK             => my_lclk                   ,
        D1CLK            => my_d1clk                  ,
        D2CLK            => my_d2clk                  ,
        SCANIN           => shx04_gp0_lat_si          ,                    
        SCANOUT          => shx04_gp0_lat_so          ,          
        D                => shx04_gp0_din             ,
        QB               => shx04_gp0_q_b(0 to 3)    );

   shx04_gp1_lat:   entity tri.tri_inv_nlats(tri_inv_nlats) generic map (width=> 4, init=>(1 to 4=>'0'), btr => "NLI0001_X2_A12TH", expand_type => expand_type, needs_sreset => 0   ) port map (
        VD               => vdd                       ,
        GD               => gnd                       ,
        LCLK             => my_lclk                   ,
        D1CLK            => my_d1clk                  ,
        D2CLK            => my_d2clk                  ,
        SCANIN           => shx04_gp1_lat_si          ,                    
        SCANOUT          => shx04_gp1_lat_so          ,          
        D                => shx04_gp1_din             ,
        QB               => shx04_gp1_q_b(0 to 3)    );

   shx01_gp0_lat:   entity tri.tri_inv_nlats(tri_inv_nlats) generic map (width=> 4, init=>(1 to 4=>'0'), btr => "NLI0001_X1_A12TH", expand_type => expand_type, needs_sreset => 0   ) port map (
        VD               => vdd                       ,
        GD               => gnd                       ,
        LCLK             => my_lclk                   ,
        D1CLK            => my_d1clk                  ,
        D2CLK            => my_d2clk                  ,
        SCANIN           => shx01_gp0_lat_si          ,                    
        SCANOUT          => shx01_gp0_lat_so          ,          
        D                => shx01_gp0_din             ,
        QB               => shx01_gp0_q_b(0 to 3)    );

   shx01_gp1_lat:   entity tri.tri_inv_nlats(tri_inv_nlats) generic map (width=> 4, init=>(1 to 4=>'0'), btr => "NLI0001_X1_A12TH", expand_type => expand_type, needs_sreset => 0   ) port map (
        VD               => vdd                       ,
        GD               => gnd                       ,
        LCLK             => my_lclk                   ,
        D1CLK            => my_d1clk                  ,
        D2CLK            => my_d2clk                  ,
        SCANIN           => shx01_gp1_lat_si          ,                    
        SCANOUT          => shx01_gp1_lat_so          ,          
        D                => shx01_gp1_din             ,
        QB               => shx01_gp1_q_b(0 to 3)    );

   mask_lat:   entity tri.tri_inv_nlats(tri_inv_nlats) generic map (width=> 6, init=>(1 to 6=>'0'), btr => "NLI0001_X1_A12TH", expand_type => expand_type, needs_sreset => 0   ) port map (
        VD               => vdd                       ,
        GD               => gnd                       ,
        LCLK             => my_lclk                   ,
        D1CLK            => my_d1clk                  ,
        D2CLK            => my_d2clk                  ,
        SCANIN           => mask_lat_si               ,                    
        SCANOUT          => mask_lat_so               ,          
        D                => mask_din                  ,
        QB               => mask_q_b(0 to 5)         );



   shx16_sgn0_lat:   entity tri.tri_inv_nlats(tri_inv_nlats) generic map (width=> 2, init=>(1 to 2=>'0'),btr => "NLI0001_X4_A12TH", expand_type => expand_type, needs_sreset => 0   ) port map (
        VD               => vdd                       ,
        GD               => gnd                       ,
        LCLK             => my_lclk                   ,
        D1CLK            => my_d1clk                  ,
        D2CLK            => my_d2clk                  ,
        SCANIN           => shx16_sgn0_lat_si          ,                    
        SCANOUT          => shx16_sgn0_lat_so          ,          
        D                => shx16_sgn0_din             ,
        QB               => shx16_sgn0_q_b(0 to 1)    );


   shx04_sgn0_lat:   entity tri.tri_inv_nlats(tri_inv_nlats) generic map (width=> 4, init=>(1 to 4=>'0'),btr => "NLI0001_X2_A12TH", expand_type => expand_type, needs_sreset => 0   ) port map (
        VD               => vdd                       ,
        GD               => gnd                       ,
        LCLK             => my_lclk                   ,
        D1CLK            => my_d1clk                  ,
        D2CLK            => my_d2clk                  ,
        SCANIN           => shx04_sgn0_lat_si          ,                    
        SCANOUT          => shx04_sgn0_lat_so          ,          
        D                => shx04_sgn0_din             ,
        QB               => shx04_sgn0_q_b(0 to 3)    );

   shx01_sgn0_lat:   entity tri.tri_inv_nlats(tri_inv_nlats) generic map (width=> 4, init=>(1 to 4=>'0'),btr => "NLI0001_X1_A12TH", expand_type => expand_type, needs_sreset => 0   ) port map (
        VD               => vdd                       ,
        GD               => gnd                       ,
        LCLK             => my_lclk                   ,
        D1CLK            => my_d1clk                  ,
        D2CLK            => my_d2clk                  ,
        SCANIN           => shx01_sgn0_lat_si          ,                    
        SCANOUT          => shx01_sgn0_lat_so          ,          
        D                => shx01_sgn0_din             ,
        QB               => shx01_sgn0_q_b(0 to 3)    );


  di_lat_si(0)              <= scan_in;
  di_lat_si(1 to 31)        <= di_lat_so(0 to 30);
  shx16_gp0_lat_si(0)       <= di_lat_so(31);
  shx16_gp0_lat_si(1 to 3)  <= shx16_gp0_lat_so(0 to 2);
  shx16_gp1_lat_si(0)       <= shx16_gp0_lat_so(3);
  shx16_gp1_lat_si(1 to 3)  <= shx16_gp1_lat_so(0 to 2);
  shx04_gp0_lat_si(0)       <= shx16_gp1_lat_so(3);
  shx04_gp0_lat_si(1 to 3)  <= shx04_gp0_lat_so(0 to 2);
  shx04_gp1_lat_si(0)       <= shx04_gp0_lat_so(3);
  shx04_gp1_lat_si(1 to 3)  <= shx04_gp1_lat_so(0 to 2);
  shx01_gp0_lat_si(0)       <= shx04_gp1_lat_so(3);
  shx01_gp0_lat_si(1 to 3)  <= shx01_gp0_lat_so(0 to 2); 
  shx01_gp1_lat_si(0)       <= shx01_gp0_lat_so(3);
  shx01_gp1_lat_si(1 to 3)  <= shx01_gp1_lat_so(0 to 2);
  mask_lat_si(0)            <= shx01_gp1_lat_so(3);
  mask_lat_si(1 to 5)       <= mask_lat_so(0 to 4);
  shx16_sgn0_lat_si(0)      <= mask_lat_so(5);
  shx16_sgn0_lat_si(1)      <= shx16_sgn0_lat_so(0);
  shx04_sgn0_lat_si(0)      <= shx16_sgn0_lat_so(1);
  shx04_sgn0_lat_si(1 to 3) <= shx04_sgn0_lat_so(0 to 2);
  shx01_sgn0_lat_si(0)      <= shx04_sgn0_lat_so(3);
  shx01_sgn0_lat_si(1 to 3) <= shx01_sgn0_lat_so(0 to 2);
  scan_out                  <= shx01_sgn0_lat_so(3);


    my_lcb: tri_lcbnd generic map (expand_type => expand_type) port map (
        delay_lclkr =>  delay_lclkr_dc     ,
        mpw1_b      =>  mpw1_dc_b          ,
        mpw2_b      =>  mpw2_dc_b          ,
        forcee =>  func_sl_force      ,
        nclk        =>  nclk               ,
        vd          =>  vdd                ,
        gd          =>  gnd                ,
        act         =>  act                ,
        sg          =>  sg_0               ,
        thold_b     =>  func_sl_thold_0_b  ,
        d1clk       =>  my_d1clk           ,
        d2clk       =>  my_d2clk           ,
        lclk        =>  my_lclk           );

end architecture xuq_lsu_data_rot32s_ru;

