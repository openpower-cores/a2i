-- © IBM Corp. 2020
-- This softcore is licensed under and subject to the terms of the CC-BY 4.0
-- license (https://creativecommons.org/licenses/by/4.0/legalcode). 
-- Additional rights, including the right to physically implement a softcore 
-- that is compliant with the required sections of the Power ISA 
-- Specification, will be available at no cost via the OpenPOWER Foundation. 
-- This README will be updated with additional information when OpenPOWER's 
-- license is available.

--  Description:  XU LSU Load Data Rotator
--

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

-- ##########################################################################################
-- VHDL Contents
-- 1) 1 32Byte input
-- 2) 32 Byte Unaligned Rotate to the Right Rotator
-- ##########################################################################################
   
entity xuq_lsu_data_rot32_ru is
  generic (expand_type : integer := 2 );
  port (
                                                                                 
        opsize                  :in  std_ulogic_vector(0 to 5); -- (0)256 (1)128 (2)64 (3)32 (4)16 (5)8
        le                      :in  std_ulogic;
        rotate_sel              :in  std_ulogic_vector(0 to 4);

        data                    :in  std_ulogic_vector(0 to 31); -- data to rotate
        data_latched            :out std_ulogic_vector(0 to 31); -- latched data, not rotated
        data_rot                :out std_ulogic_vector(0 to 31); -- rotated data out

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


end xuq_lsu_data_rot32_ru;

architecture xuq_lsu_data_rot32_ru of xuq_lsu_data_rot32_ru is
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

   signal mx1_0_b, mx1_1_b, mx1 :std_ulogic_vector(0 to 31);
   signal mx2_0_b, mx2_1_b, mx2 :std_ulogic_vector(0 to 31);
   signal mx3_0_b, mx3_1_b, mx3 :std_ulogic_vector(0 to 31);
   signal do_b  :std_ulogic_vector(0 to 31) ; 

   signal mx1_d0, mx1_d1, mx1_d2, mx1_d3 :std_ulogic_vector(0 to 31) ; 
   signal mx2_d0, mx2_d1, mx2_d2, mx2_d3 :std_ulogic_vector(0 to 31) ;
   signal mx3_d0, mx3_d1, mx3_d2, mx3_d3 :std_ulogic_vector(0 to 31) ;

   signal mx1_s0, mx1_s1, mx1_s2, mx1_s3 :std_ulogic_vector(0 to 31) ;
   signal mx2_s0, mx2_s1, mx2_s2, mx2_s3 :std_ulogic_vector(0 to 31) ;
   signal mx3_s0, mx3_s1, mx3_s2, mx3_s3 :std_ulogic_vector(0 to 31) ;

   signal mask_en                           :std_ulogic_vector(0 to 31);
   signal shx16_sel , shx04_sel , shx01_sel :std_ulogic_vector(0 to 3);


begin

-- #############################################################################################
-- Little Endian Rotate Support
--         Optype2                      Optype4                       Optype8
--                                                              B31 => rot_data(248:255)
--                                                              B30 => rot_data(240:247)
--                                                              B29 => rot_data(232:239)
--                                                              B28 => rot_data(224:231)
--                              B31    => rot_data(248:255)     B27 => rot_data(216:223)
--                              B30    => rot_data(240:247)     B26 => rot_data(208:215)
-- B31    => rot_data(248:255)  B29    => rot_data(232:239)     B25 => rot_data(200:207)
-- B30    => rot_data(240:247)  B28    => rot_data(224:231)     B24 => rot_data(192:199)
--
--                        Optype16
-- B31 => rot_data(248:255)     B23 => rot_data(184:191)
-- B30 => rot_data(240:247)     B22 => rot_data(176:183)
-- B29 => rot_data(232:239)     B21 => rot_data(168:175)
-- B28 => rot_data(224:231)     B20 => rot_data(160:167)
-- B27 => rot_data(216:223)     B19 => rot_data(152:159)
-- B26 => rot_data(208:215)     B18 => rot_data(144:151)
-- B25 => rot_data(200:207)     B17 => rot_data(136:143)
-- B24 => rot_data(192:199)     B16 => rot_data(128:135)
--
--                                                      Optype32
-- B31 => rot_data(248:255)     B23 => rot_data(184:191)        B15 => rot_data(120:127)        B7 => rot_data(56:63)
-- B30 => rot_data(240:247)     B22 => rot_data(176:183)        B14 => rot_data(112:119)        B6 => rot_data(48:55)
-- B29 => rot_data(232:239)     B21 => rot_data(168:175)        B13 => rot_data(104:111)        B5 => rot_data(40:47)
-- B28 => rot_data(224:231)     B20 => rot_data(160:167)        B12 => rot_data(96:103)         B4 => rot_data(32:39)
-- B27 => rot_data(216:223)     B19 => rot_data(152:159)        B11 => rot_data(88:95)          B3 => rot_data(24:31)
-- B26 => rot_data(208:215)     B18 => rot_data(144:151)        B10 => rot_data(80:87)          B2 => rot_data(16:23)
-- B25 => rot_data(200:207)     B17 => rot_data(136:143)        B9  => rot_data(72:79)          B1 => rot_data(8:15)
-- B24 => rot_data(192:199)     B16 => rot_data(128:135)        B8  => rot_data(64:71)          B0 => rot_data(0:7)
-- #############################################################################################

---- 0,1,2,3 byte rotation
--with rot_sel(3 to 4) select
--    rot3210 <= rot_data(232 to 255) & rot_data(0 to 231) when "11",
--               rot_data(240 to 255) & rot_data(0 to 239) when "10",
--               rot_data(248 to 255) & rot_data(0 to 247) when "01",
--                                      rot_data(0 to 255) when others;
--
---- 0-3,4,8,12 byte rotation
--with rot_sel(1 to 2) select
--    rotC840 <= rot3210(160 to 255) & rot3210(0 to 159) when "11",
--               rot3210(192 to 255) & rot3210(0 to 191) when "10",
--               rot3210(224 to 255) & rot3210(0 to 223) when "01",
--                                     rot3210(0 to 255) when others;
--
----0-12, 16 byte rotation
--with rot_sel(0) select
--    rot10 <= rotC840(128 to 255) & rotC840(0 to 127) when '1',
--                                   rotC840(0 to 255) when others;

 -- ######################################################################
 -- ## BEFORE ROTATE CYCLE
 -- ######################################################################

    -- Rotate Control
    -- ----------------------------------
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

    -- Opsize Mask Generation
    -- ----------------------------------
    mask_din(0)           <= opsize(0)                ;-- for 0:15
    mask_din(1)           <= opsize(1) or mask_din(0) ;-- for 16:23
    mask_din(2)           <= opsize(2) or mask_din(1) ;-- for 24:27
    mask_din(3)           <= opsize(3) or mask_din(2) ;-- for 28:29
    mask_din(4)           <= opsize(4) or mask_din(3) ;-- for 30
    mask_din(5)           <= opsize(5) or mask_din(4) ;-- for 31

    -- Latch Inputs
    -- ----------------------------------
    di_din(0 to 31)       <= data(0 to 31);
    shx16_gp0_din(0 to 3) <= shx16_sel(0 to 3);
    shx16_gp1_din(0 to 3) <= shx16_sel(0 to 3);
    shx04_gp0_din(0 to 3) <= shx04_sel(0 to 3);
    shx04_gp1_din(0 to 3) <= shx04_sel(0 to 3);
    shx01_gp0_din(0 to 3) <= shx01_sel(0 to 3);
    shx01_gp1_din(0 to 3) <= shx01_sel(0 to 3);

 -- ######################################################################
 -- ## ROTATE CYCLE
 -- ######################################################################

    -- -------------------------------------------------------------------
    -- local latch inputs
    -- -------------------------------------------------------------------

     u_di_q: di_q(0 to 31)               <= not di_q_b(0 to 31)        ;
     u_shx16_gp0_q: shx16_gp0_q(0 to 3)  <= not shx16_gp0_q_b(0 to 3)  ;
     u_shx16_gp1_q: shx16_gp1_q(0 to 3)  <= not shx16_gp1_q_b(0 to 3)  ;
     u_shx04_gp0_q: shx04_gp0_q(0 to 3)  <= not shx04_gp0_q_b(0 to 3)  ;
     u_shx04_gp1_q: shx04_gp1_q(0 to 3)  <= not shx04_gp1_q_b(0 to 3)  ;
     u_shx01_gp0_q: shx01_gp0_q(0 to 3)  <= not shx01_gp0_q_b(0 to 3)  ;
     u_shx01_gp1_q: shx01_gp1_q(0 to 3)  <= not shx01_gp1_q_b(0 to 3)  ;
                    mask_q(0 to 5)       <= not mask_q_b(0 to 5)       ;

    -- ----------------------------------------------------------------------------------------
    -- first level of muxing <le/be, shift 0/16 bytes>
    -- ----------------------------------------------------------------------------------------
 
    mx1_s0( 0 to 15)  <= ( 0 to 15=> shx16_gp0_q(0) ) ; -- name reassign for select
    mx1_s1( 0 to 15)  <= ( 0 to 15=> shx16_gp0_q(1) ) ; -- name reassign for select
    mx1_s2( 0 to 15)  <= ( 0 to 15=> shx16_gp0_q(2) ) ; -- name reassign for select
    mx1_s3( 0 to 15)  <= ( 0 to 15=> shx16_gp0_q(3) ) ; -- name reassign for select
    mx1_s0(16 to 31)  <= (16 to 31=> shx16_gp1_q(0) ) ; -- name reassign for select
    mx1_s1(16 to 31)  <= (16 to 31=> shx16_gp1_q(1) ) ; -- name reassign for select
    mx1_s2(16 to 31)  <= (16 to 31=> shx16_gp1_q(2) ) ; -- name reassign for select
    mx1_s3(16 to 31)  <= (16 to 31=> shx16_gp1_q(3) ) ; -- name reassign for select
 
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

    -- ----------------------------------------------------------------------------------------
    -- second level of muxing <0,4,8,12 bytes>
    -- ----------------------------------------------------------------------------------------

    mx2_s0( 0 to 15)  <= ( 0 to 15=> shx04_gp0_q(0) ) ; -- name reassign for select
    mx2_s1( 0 to 15)  <= ( 0 to 15=> shx04_gp0_q(1) ) ; -- name reassign for select
    mx2_s2( 0 to 15)  <= ( 0 to 15=> shx04_gp0_q(2) ) ; -- name reassign for select
    mx2_s3( 0 to 15)  <= ( 0 to 15=> shx04_gp0_q(3) ) ; -- name reassign for select
    mx2_s0(16 to 31)  <= (16 to 31=> shx04_gp1_q(0) ) ; -- name reassign for select
    mx2_s1(16 to 31)  <= (16 to 31=> shx04_gp1_q(1) ) ; -- name reassign for select
    mx2_s2(16 to 31)  <= (16 to 31=> shx04_gp1_q(2) ) ; -- name reassign for select
    mx2_s3(16 to 31)  <= (16 to 31=> shx04_gp1_q(3) ) ; -- name reassign for select
 
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
   
   
    -- ----------------------------------------------------------------------------------------
    -- third level of muxing <0,1,2,3 bytes> , include mask on selects
    -- ----------------------------------------------------------------------------------------

    mask_en( 0 to 15) <= ( 0 to 15=> mask_q(0) ); -- 256
    mask_en(16 to 23) <= (16 to 23=> mask_q(1) ); -- 256,128
    mask_en(24 to 27) <= (24 to 27=> mask_q(2) ); -- 256,128,64
    mask_en(28 to 29) <= (28 to 29=> mask_q(3) ); -- 256,128,64,32
    mask_en(30)       <= (           mask_q(4) ); -- 256,128,64,32,16
    mask_en(31)       <= (           mask_q(5) ); -- 256,128,64,32,16,8 <not sure you really need this one>

    mx3_s0( 0 to 15)  <= ( 0 to 15=> shx01_gp0_q(0) ) and mask_en( 0 to 15); -- name reassign for select
    mx3_s1( 0 to 15)  <= ( 0 to 15=> shx01_gp0_q(1) ) and mask_en( 0 to 15); -- name reassign for select
    mx3_s2( 0 to 15)  <= ( 0 to 15=> shx01_gp0_q(2) ) and mask_en( 0 to 15); -- name reassign for select
    mx3_s3( 0 to 15)  <= ( 0 to 15=> shx01_gp0_q(3) ) and mask_en( 0 to 15); -- name reassign for select
    mx3_s0(16 to 31)  <= (16 to 31=> shx01_gp1_q(0) ) and mask_en(16 to 31); -- name reassign for select
    mx3_s1(16 to 31)  <= (16 to 31=> shx01_gp1_q(1) ) and mask_en(16 to 31); -- name reassign for select
    mx3_s2(16 to 31)  <= (16 to 31=> shx01_gp1_q(2) ) and mask_en(16 to 31); -- name reassign for select
    mx3_s3(16 to 31)  <= (16 to 31=> shx01_gp1_q(3) ) and mask_en(16 to 31); -- name reassign for select

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

  -- top   funny physical placement to minimize wrap wires ... also nice for LE adjust
  -----------
  --  0  31
  --  1  30
  --  2  29
  --  3  28
  --  4  27
  --  5  26
  --  6  25
  --  7  24
  -----------
  --  8  23
  --  9  22
  -- 10  21
  -- 11  20
  -- 12  19
  -- 13  18
  -- 14  17
  -- 15  16
  -----------
  -- bot

-- ###############################################################
-- ## Latches
-- ###############################################################

   di_lat:   entity tri.tri_inv_nlats(tri_inv_nlats) generic map (width=> 32, init=>(1 to 32=>'0'), btr => "NLI0001_X4_A12TH", expand_type => expand_type, needs_sreset => 0   ) port map (
        VD               => vdd                       ,--inout
        GD               => gnd                       ,--inout
        LCLK             => my_lclk                   ,--lclk.clk
        D1CLK            => my_d1clk                  ,
        D2CLK            => my_d2clk                  ,
        SCANIN           => di_lat_si                 ,                    
        SCANOUT          => di_lat_so                 ,          
        D                => di_din(0 to 31)           ,
        QB               => di_q_b(0 to 31)    );

   shx16_gp0_lat:   entity tri.tri_inv_nlats(tri_inv_nlats) generic map (width=> 4, init=>(1 to 4=>'0'),btr => "NLI0001_X4_A12TH", expand_type => expand_type, needs_sreset => 0   ) port map (
        VD               => vdd                       ,--inout
        GD               => gnd                       ,--inout
        LCLK             => my_lclk                   ,--lclk.clk
        D1CLK            => my_d1clk                  ,
        D2CLK            => my_d2clk                  ,
        SCANIN           => shx16_gp0_lat_si          ,                    
        SCANOUT          => shx16_gp0_lat_so          ,          
        D                => shx16_gp0_din             ,
        QB               => shx16_gp0_q_b(0 to 3)    );

   shx16_gp1_lat:   entity tri.tri_inv_nlats(tri_inv_nlats) generic map (width=> 4, init=>(1 to 4=>'0'),btr => "NLI0001_X4_A12TH", expand_type => expand_type, needs_sreset => 0   ) port map (
        VD               => vdd                       ,--inout
        GD               => gnd                       ,--inout
        LCLK             => my_lclk                   ,--lclk.clk
        D1CLK            => my_d1clk                  ,
        D2CLK            => my_d2clk                  ,
        SCANIN           => shx16_gp1_lat_si          ,                    
        SCANOUT          => shx16_gp1_lat_so          ,          
        D                => shx16_gp1_din             ,
        QB               => shx16_gp1_q_b(0 to 3)    );

   shx04_gp0_lat:   entity tri.tri_inv_nlats(tri_inv_nlats) generic map (width=> 4, init=>(1 to 4=>'0'),btr => "NLI0001_X2_A12TH", expand_type => expand_type, needs_sreset => 0   ) port map (
        VD               => vdd                       ,--inout
        GD               => gnd                       ,--inout
        LCLK             => my_lclk                   ,--lclk.clk
        D1CLK            => my_d1clk                  ,
        D2CLK            => my_d2clk                  ,
        SCANIN           => shx04_gp0_lat_si          ,                    
        SCANOUT          => shx04_gp0_lat_so          ,          
        D                => shx04_gp0_din             ,
        QB               => shx04_gp0_q_b(0 to 3)    );

   shx04_gp1_lat:   entity tri.tri_inv_nlats(tri_inv_nlats) generic map (width=> 4, init=>(1 to 4=>'0'),btr => "NLI0001_X2_A12TH", expand_type => expand_type, needs_sreset => 0   ) port map (
        VD               => vdd                       ,--inout
        GD               => gnd                       ,--inout
        LCLK             => my_lclk                   ,--lclk.clk
        D1CLK            => my_d1clk                  ,
        D2CLK            => my_d2clk                  ,
        SCANIN           => shx04_gp1_lat_si          ,                    
        SCANOUT          => shx04_gp1_lat_so          ,          
        D                => shx04_gp1_din             ,
        QB               => shx04_gp1_q_b(0 to 3)    );

   shx01_gp0_lat:   entity tri.tri_inv_nlats(tri_inv_nlats) generic map (width=> 4, init=>(1 to 4=>'0'),btr => "NLI0001_X1_A12TH", expand_type => expand_type, needs_sreset => 0   ) port map (
        VD               => vdd                       ,--inout
        GD               => gnd                       ,--inout
        LCLK             => my_lclk                   ,--lclk.clk
        D1CLK            => my_d1clk                  ,
        D2CLK            => my_d2clk                  ,
        SCANIN           => shx01_gp0_lat_si          ,                    
        SCANOUT          => shx01_gp0_lat_so          ,          
        D                => shx01_gp0_din             ,
        QB               => shx01_gp0_q_b(0 to 3)    );

   shx01_gp1_lat:   entity tri.tri_inv_nlats(tri_inv_nlats) generic map (width=> 4, init=>(1 to 4=>'0'),btr => "NLI0001_X1_A12TH", expand_type => expand_type, needs_sreset => 0   ) port map (
        VD               => vdd                       ,--inout
        GD               => gnd                       ,--inout
        LCLK             => my_lclk                   ,--lclk.clk
        D1CLK            => my_d1clk                  ,
        D2CLK            => my_d2clk                  ,
        SCANIN           => shx01_gp1_lat_si          ,                    
        SCANOUT          => shx01_gp1_lat_so          ,          
        D                => shx01_gp1_din             ,
        QB               => shx01_gp1_q_b(0 to 3)    );

   mask_lat:   entity tri.tri_inv_nlats(tri_inv_nlats) generic map (width=> 6, init=>(1 to 6=>'0'),btr => "NLI0001_X1_A12TH", expand_type => expand_type, needs_sreset => 0   ) port map (
        VD               => vdd                       ,--inout
        GD               => gnd                       ,--inout
        LCLK             => my_lclk                   ,--lclk.clk
        D1CLK            => my_d1clk                  ,
        D2CLK            => my_d2clk                  ,
        SCANIN           => mask_lat_si               ,                    
        SCANOUT          => mask_lat_so               ,          
        D                => mask_din                  ,
        QB               => mask_q_b(0 to 5)         );

-- ###############################################################
-- ## Scan Chain Hookup
-- ###############################################################

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
  scan_out                  <= mask_lat_so(5);


-- ###############################################################
-- ## LCBs
-- ###############################################################

    my_lcb: tri_lcbnd generic map (expand_type => expand_type) port map (
        delay_lclkr =>  delay_lclkr_dc     ,--in -- tidn ,
        mpw1_b      =>  mpw1_dc_b          ,--in -- tidn ,
        mpw2_b      =>  mpw2_dc_b          ,--in -- tidn ,
        forcee =>  func_sl_force      ,--in -- tidn ,
        nclk        =>  nclk               ,--in
        vd          =>  vdd                ,--inout
        gd          =>  gnd                ,--inout
        act         =>  act                ,--in
        sg          =>  sg_0               ,--in
        thold_b     =>  func_sl_thold_0_b  ,--in
        d1clk       =>  my_d1clk           ,--out
        d2clk       =>  my_d2clk           ,--out
        lclk        =>  my_lclk           );--out

end architecture xuq_lsu_data_rot32_ru;
