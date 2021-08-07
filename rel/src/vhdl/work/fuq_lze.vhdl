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


-- LZE (exponent for leading zeroes anticipater)

library ieee,ibm,support,tri,work;
   use ieee.std_logic_1164.all;
   use ibm.std_ulogic_unsigned.all;
   use ibm.std_ulogic_support.all; 
   use ibm.std_ulogic_function_support.all;
   use support.power_logic_pkg.all;
   use tri.tri_latches_pkg.all;
   use ibm.std_ulogic_ao_support.all; 
   use ibm.std_ulogic_mux_support.all; 


entity fuq_lze is
generic( expand_type: integer := 2  ); -- 0 - ibm tech, 1 - other );
port(
       vdd                                       :inout power_logic;
       gnd                                       :inout power_logic;
       clkoff_b                                  :in   std_ulogic; -- tiup
       act_dis                                   :in   std_ulogic; -- ??tidn??
       flush                                     :in   std_ulogic; -- ??tidn??
       delay_lclkr                               :in   std_ulogic_vector(2 to 3); -- tidn,
       mpw1_b                                    :in   std_ulogic_vector(2 to 3); -- tidn,
       mpw2_b                                    :in   std_ulogic_vector(0 to 0); -- tidn,
       sg_1                                      :in   std_ulogic;
       thold_1                                   :in   std_ulogic;
       fpu_enable                                :in   std_ulogic; --dc_act
       nclk                                      :in   clk_logic;

       f_lze_si                   :in  std_ulogic; --perv
       f_lze_so                   :out std_ulogic; --perv
       ex1_act_b                  :in  std_ulogic; --act

       f_eie_ex2_lzo_expo         :in  std_ulogic_vector(1 to 13)  ; 
       f_eie_ex2_b_expo           :in  std_ulogic_vector(1 to 13)  ; 
       f_eie_ex2_use_bexp         :in  std_ulogic;
       f_pic_ex2_lzo_dis_prod     :in  std_ulogic;
       f_pic_ex2_sp_lzo           :in  std_ulogic;
       f_pic_ex2_est_recip        :in  std_ulogic;
       f_pic_ex2_est_rsqrt        :in  std_ulogic;
       f_fmt_ex2_pass_msb_dp      :in  std_ulogic;
       f_pic_ex2_frsp_ue1         :in  std_ulogic;
       f_alg_ex2_byp_nonflip      :in  std_ulogic;
       f_pic_ex2_b_valid          :in  std_ulogic;
       f_alg_ex2_sel_byp          :in  std_ulogic;
       f_pic_ex2_to_integer       :in  std_ulogic;
       f_pic_ex2_prenorm          :in  std_ulogic; 

       f_lze_ex2_lzo_din          :out std_ulogic_vector(0 to 162);
       f_lze_ex3_sh_rgt_amt       :out std_ulogic_vector(0 to 7);
       f_lze_ex3_sh_rgt_en        :out std_ulogic  

);






end fuq_lze; -- ENTITY

architecture fuq_lze of fuq_lze is

    constant tiup : std_ulogic := '1';
    constant tidn : std_ulogic := '0';

    signal thold_0_b, thold_0, forcee, sg_0 :std_ulogic;
    signal ex1_act, ex2_act :std_ulogic;
    signal spare_unused :std_ulogic_vector(0 to 3);
 signal ex2_dp_001_by  :std_ulogic;
 signal ex2_sp_001_by :std_ulogic;
 signal ex2_addr_dp_by :std_ulogic;
 signal ex2_addr_sp_by :std_ulogic;
 signal ex2_en_addr_dp_by :std_ulogic;
 signal ex2_en_addr_sp_by :std_ulogic;
 signal ex2_lzo_en, ex2_lzo_en_rapsp      :std_ulogic;
 signal ex2_lzo_en_by   :std_ulogic;
 signal ex2_expo_neg_dp_by :std_ulogic;
 signal ex2_expo_neg_sp_by :std_ulogic;
 signal ex2_expo_6_adj_by :std_ulogic;
 signal ex2_addr_dp :std_ulogic;
 signal ex2_addr_sp, ex2_addr_sp_rap :std_ulogic;
 signal ex2_en_addr_dp :std_ulogic;
 signal ex2_en_addr_sp, ex2_en_addr_sp_rap :std_ulogic;
 signal ex2_lzo_cont    :std_ulogic;
 signal ex2_lzo_cont_dp :std_ulogic;
 signal ex2_lzo_cont_sp :std_ulogic;
 signal ex2_expo_neg_dp :std_ulogic;
 signal ex2_expo_neg_sp :std_ulogic;
 signal ex2_expo_6_adj  :std_ulogic; 
 signal ex2_ins_est      :std_ulogic;
 signal ex2_sh_rgt_en_by :std_ulogic;
 signal ex2_sh_rgt_en_p  :std_ulogic;
 signal ex2_sh_rgt_en    :std_ulogic;
 signal ex2_lzo_forbyp_0 :std_ulogic;
 signal ex2_lzo_nonbyp_0 :std_ulogic;
 signal ex3_sh_rgt_en  :std_ulogic;
 signal ex2_expo_by :std_ulogic_vector(1 to 13) ;
 signal ex2_lzo_dcd_hi_by :std_ulogic_vector( 0 to 0) ;
 signal ex2_lzo_dcd_lo_by :std_ulogic_vector( 0 to 0);
 signal ex2_expo :std_ulogic_vector(1 to 13) ;
 signal ex2_lzo_dcd_hi :std_ulogic_vector( 0 to 10);
 signal ex2_lzo_dcd_lo :std_ulogic_vector( 0 to 15);
 signal ex2_expo_p_sim_p :std_ulogic_vector(8 to 13);
 signal ex2_expo_p_sim_g :std_ulogic_vector(9 to 13);
 signal ex2_expo_p_sim :std_ulogic_vector(8 to 13)  ;
 signal ex2_expo_sim_p :std_ulogic_vector(8 to 13)  ;
 signal ex2_expo_sim_g :std_ulogic_vector(9 to 13)  ;
 signal ex2_expo_sim :std_ulogic_vector(8 to 13)   ;
 signal ex2_sh_rgt_amt :std_ulogic_vector(0 to 7);
 signal ex3_shr_so, ex3_shr_si :std_ulogic_vector(0 to 8);
 signal act_so, act_si :std_ulogic_vector(0 to 4);
 signal ex3_sh_rgt_amt :std_ulogic_vector(0 to 7);
 signal ex2_lzo_dcd_0    :std_ulogic;
 signal ex2_lzo_dcd_b :std_ulogic_vector(0 to 162); 
signal unused :std_ulogic;
signal f_alg_ex2_sel_byp_b , ex2_lzo_nonbyp_0_b , ex2_lzo_forbyp_0_b :std_ulogic ;




 

begin

 unused <= ex2_lzo_dcd_b(0) ;

---=###############################################################
---= pervasive
---=###############################################################

    
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


---=###############################################################
---= act
---=###############################################################

        ex1_act <= not ex1_act_b;

    act_lat:  tri_rlmreg_p generic map (width=> 5, expand_type => expand_type, needs_sreset => 0) port map ( 
        forcee => forcee,-- tidn,
        delay_lclkr      => delay_lclkr(2)   ,-- tidn,
        mpw1_b           => mpw1_b(2)        ,-- tidn,
        mpw2_b           => mpw2_b(0)        ,-- tidn,
        vd               => vdd,
        gd               => gnd,
        nclk             => nclk,
        act              => fpu_enable,
        thold_b          => thold_0_b,
        sg               => sg_0, 
        scout            => act_so  ,                      
        scin             => act_si  ,                    
        -------------------
         din(0)             => spare_unused(0),
         din(1)             => spare_unused(1),
         din(2)             => ex1_act,
         din(3)             => spare_unused(2),
         din(4)             => spare_unused(3),
        -------------------
        dout(0)             => spare_unused(0),
        dout(1)             => spare_unused(1),
        dout(2)             => ex2_act,
        dout(3)             => spare_unused(2) ,
        dout(4)             => spare_unused(3) );

---=###############################################################
---= ex2 logic
---=###############################################################


ex2_dp_001_by <= --x001
              not ex2_expo_by(1)  and 
              not ex2_expo_by(2)  and 
              not ex2_expo_by(3)  and 
              not ex2_expo_by(4)  and 
              not ex2_expo_by(5)  and 
              not ex2_expo_by(6)  and 
              not ex2_expo_by(7)  and 
              not ex2_expo_by(8)  and 
              not ex2_expo_by(9)  and 
              not ex2_expo_by(10) and 
              not ex2_expo_by(11) and 
              not ex2_expo_by(12) and 
                  ex2_expo_by(13)   ;

ex2_sp_001_by <=  --x381
              not ex2_expo_by(1)  and
              not ex2_expo_by(2)  and 
              not ex2_expo_by(3)  and 
                  ex2_expo_by(4)  and 
                  ex2_expo_by(5)  and 
                  ex2_expo_by(6)  and 
              not ex2_expo_by(7)  and 
              not ex2_expo_by(8)  and 
              not ex2_expo_by(9)  and 
              not ex2_expo_by(10) and 
              not ex2_expo_by(11) and 
              not ex2_expo_by(12) and 
                  ex2_expo_by(13)   ;



------------------------------------------------------------------
-- lzo dcd when B = denorm.
-- sp denorm in dp_format may need to denormalize.
-- sp is bypassed at [26] so there is room to do this on the left
------------------------------------------------------------------
-- if B is normalized when bypassed, then no need for denorm because it will not shift left ?
-- for EffSub, b MSB can move right 1 position ... only if BFrac = 0000111111,can't if bypass norm
-- If B==0 then should NOT bypass ... except for Move instructions.

ex2_expo_by(1 to 13) <=  f_eie_ex2_b_expo(1 to 13);



    --=#------------------------------------------------
    --=#-- LZO Decode
    --=#------------------------------------------------
      -- the product exponent points at [0] in the dataflow.
      -- the lzo puts a marker (false edge) at the point where shifting must stop
      -- so the lza will not create a denormal exponent. (001/897) dp/sp.
      -- if p_expo==1 then maker @ 0
      -- if p_expo==2 then maker @ 1
      -- if p_expo==3 then maker @ 2
      --
      -- false edges are also used to control shifting for to-integer, aligner-bypass


      ex2_addr_dp_by <= not ex2_expo_by(1) and
                        not ex2_expo_by(2) and  -- x001 (1) in bits above decode 256
                        not ex2_expo_by(3) and 
                        not ex2_expo_by(4) and 
                        not ex2_expo_by(5) ;

      ex2_addr_sp_by <= not ex2_expo_by(1) and
                        not ex2_expo_by(2) and -- x381 (897) in bits above decode 256
                        not ex2_expo_by(3) and 
                            ex2_expo_by(4) and 
                            ex2_expo_by(5) ;  

      ex2_en_addr_dp_by <=     ex2_addr_dp_by and ex2_lzo_cont_dp ;
      ex2_en_addr_sp_by <=     ex2_addr_sp_by and ex2_lzo_cont_sp ;



      -- want to avoid shift right for sp op with shOv of sp_den in dp format
      -- sp is bypassed 26 positions to the left , mark with LZO to create the denorm.

      ex2_lzo_en_by   <=  (ex2_en_addr_dp_by or ex2_en_addr_sp_by) and ex2_lzo_cont ;

      ex2_expo_neg_dp_by <=
            (ex2_lzo_en_by and ex2_lzo_dcd_hi_by( 0) and ex2_lzo_dcd_lo_by( 0) ) or --decode 0
            (ex2_expo_by(1)                                                    ) ; --negative exponent

              -- dp denorm starts at 0, but sp denorm starts at 896 (x380)
              -- sp addr 0_0011_xxxx_xxxx covers 0768-1023 <and with decode bits>
              --         0_000x_xxxx_xxxx covers 0000,0001
              --         0_00x0_xxxx_xxxx covers 0000,0010

    ex2_expo_neg_sp_by <=
        (    ex2_expo_by(1)) or -- negative
        (not ex2_expo_by(2) and not ex2_expo_by(3) and not ex2_expo_by(4)                                                ) or  
        (not ex2_expo_by(2) and not ex2_expo_by(3) and                        not ex2_expo_by(5)                         ) or 
        (not ex2_expo_by(2) and not ex2_expo_by(3) and                                               not ex2_expo_by(6)  ) or 
        (not ex2_expo_by(2) and not ex2_expo_by(3) and     ex2_expo_by(4) and     ex2_expo_by(5) and     ex2_expo_by(6)  and
              not(ex2_expo_by(7) or ex2_expo_by(8) or ex2_expo_by(9) or ex2_expo_by(10) or ex2_expo_by(11) or ex2_expo_by(12) or ex2_expo_by(13) )  );



      ex2_expo_6_adj_by  <= (not ex2_expo_by(6) and     f_pic_ex2_sp_lzo) or
                            (    ex2_expo_by(6) and not f_pic_ex2_sp_lzo) ;
                        

      ex2_lzo_dcd_0    <= ex2_lzo_dcd_hi( 0)     and ex2_lzo_dcd_lo(1) ;


      ex2_lzo_dcd_hi_by( 0) <= not ex2_expo_6_adj_by and not ex2_expo_by( 7) and not ex2_expo_by( 8) and not ex2_expo_by( 9) and ex2_lzo_en_by;

      ex2_lzo_dcd_lo_by( 0) <= not ex2_expo_by(10) and not ex2_expo_by(11) and not ex2_expo_by(12) and not ex2_expo_by(13) ;



    --=#------------------------------------------------
    --=#-- LZO Decode
    --=#------------------------------------------------
      -- the product exponent points at [0] in the dataflow.
      -- the lzo puts a marker (false edge) at the point where shifting must stop
      -- so the lza will not create a denormal exponent. (001/897) dp/sp.
      -- if p_expo==1 then maker @ 0
      -- if p_expo==2 then maker @ 1
      -- if p_expo==3 then maker @ 2
      --
      -- false edges are also used to control shifting for to-integer, aligner-bypass


      ex2_expo(1 to 13) <= f_eie_ex2_lzo_expo(1 to 13);
      ex2_addr_dp <= not ex2_expo(1) and
                     not ex2_expo(2) and  -- x001 (1) in bits above decode 256
                     not ex2_expo(3) and 
                     not ex2_expo(4) and 
                     not ex2_expo(5) ;

      ex2_addr_sp <= not ex2_expo(1) and
                     not ex2_expo(2) and -- x381 (897) in bits above decode 256
                     not ex2_expo(3) and 
                         ex2_expo(4) and 
                         ex2_expo(5) ;  

      ex2_addr_sp_rap <= not ex2_expo(1) and
                         not ex2_expo(2) and -- x381 (897) in bits above decode 256
                             ex2_expo(3) and 
                         not ex2_expo(4) and 
                         not ex2_expo(5) ;  

      ex2_en_addr_dp     <=     ex2_addr_dp     and ex2_lzo_cont_dp ;
      ex2_en_addr_sp     <=     ex2_addr_sp     and ex2_lzo_cont_sp ;
      ex2_en_addr_sp_rap <=     ex2_addr_sp_rap and ex2_lzo_cont_sp ;

      ex2_lzo_cont    <= not f_pic_ex2_lzo_dis_prod ;
      ex2_lzo_cont_dp <= not f_pic_ex2_lzo_dis_prod and not f_pic_ex2_sp_lzo ;
      ex2_lzo_cont_sp <= not f_pic_ex2_lzo_dis_prod and     f_pic_ex2_sp_lzo ;




      -- want to avoid shift right for sp op with shOv of sp_den in dp format
      -- sp is bypassed 26 positions to the left , mark with LZO to create the denorm.

      ex2_lzo_en        <=  (ex2_en_addr_dp or ex2_en_addr_sp) and ex2_lzo_cont ;
      ex2_lzo_en_rapsp  <=  (ex2_en_addr_dp or ex2_en_addr_sp_rap) and ex2_lzo_cont ;

      ex2_expo_neg_dp <=
            (ex2_lzo_en and ex2_lzo_dcd_hi( 0) and ex2_lzo_dcd_lo( 0) ) or --decode 0
            (ex2_expo(1)                        ) ; --negative exponent


    ex2_expo_neg_sp <=
        (    ex2_expo(1)) or -- negative
        (not ex2_expo(2) and not ex2_expo(3) and not ex2_expo(4)                                          ) or  
        (not ex2_expo(2) and not ex2_expo(3) and                     not ex2_expo(5)                      ) or 
        (not ex2_expo(2) and not ex2_expo(3) and                                         not ex2_expo(6)  ) or 
        (not ex2_expo(2) and not ex2_expo(3) and     ex2_expo(4) and     ex2_expo(5) and     ex2_expo(6)  and
              not(ex2_expo(7) or ex2_expo(8) or ex2_expo(9) or ex2_expo(10) or ex2_expo(11) or ex2_expo(12) or ex2_expo(13))  );



      ex2_expo_6_adj  <= (not ex2_expo(6) and     f_pic_ex2_sp_lzo) or
                         (    ex2_expo(6) and not f_pic_ex2_sp_lzo) ;
                        

      ex2_lzo_dcd_hi( 0) <= not ex2_expo_6_adj and not ex2_expo( 7) and not ex2_expo( 8) and not ex2_expo( 9) and ex2_lzo_en;
      ex2_lzo_dcd_hi( 1) <= not ex2_expo_6_adj and not ex2_expo( 7) and not ex2_expo( 8) and     ex2_expo( 9) and ex2_lzo_en;
      ex2_lzo_dcd_hi( 2) <= not ex2_expo_6_adj and not ex2_expo( 7) and     ex2_expo( 8) and not ex2_expo( 9) and ex2_lzo_en;
      ex2_lzo_dcd_hi( 3) <= not ex2_expo_6_adj and not ex2_expo( 7) and     ex2_expo( 8) and     ex2_expo( 9) and ex2_lzo_en;
      ex2_lzo_dcd_hi( 4) <= not ex2_expo_6_adj and     ex2_expo( 7) and not ex2_expo( 8) and not ex2_expo( 9) and ex2_lzo_en;
      ex2_lzo_dcd_hi( 5) <= not ex2_expo_6_adj and     ex2_expo( 7) and not ex2_expo( 8) and     ex2_expo( 9) and ex2_lzo_en;
      ex2_lzo_dcd_hi( 6) <= not ex2_expo_6_adj and     ex2_expo( 7) and     ex2_expo( 8) and not ex2_expo( 9) and ex2_lzo_en;
      ex2_lzo_dcd_hi( 7) <= not ex2_expo_6_adj and     ex2_expo( 7) and     ex2_expo( 8) and     ex2_expo( 9) and ex2_lzo_en;
      ex2_lzo_dcd_hi( 8) <=     ex2_expo_6_adj and not ex2_expo( 7) and not ex2_expo( 8) and not ex2_expo( 9) and ex2_lzo_en_rapsp;
      ex2_lzo_dcd_hi( 9) <=     ex2_expo_6_adj and not ex2_expo( 7) and not ex2_expo( 8) and     ex2_expo( 9) and ex2_lzo_en_rapsp;
      ex2_lzo_dcd_hi(10) <=     ex2_expo_6_adj and not ex2_expo( 7) and     ex2_expo( 8) and not ex2_expo( 9) and ex2_lzo_en_rapsp;

      ex2_lzo_dcd_lo( 0) <= not ex2_expo(10) and not ex2_expo(11) and not ex2_expo(12) and not ex2_expo(13) ;
      ex2_lzo_dcd_lo( 1) <= not ex2_expo(10) and not ex2_expo(11) and not ex2_expo(12) and     ex2_expo(13) ;
      ex2_lzo_dcd_lo( 2) <= not ex2_expo(10) and not ex2_expo(11) and     ex2_expo(12) and not ex2_expo(13) ;
      ex2_lzo_dcd_lo( 3) <= not ex2_expo(10) and not ex2_expo(11) and     ex2_expo(12) and     ex2_expo(13) ;
      ex2_lzo_dcd_lo( 4) <= not ex2_expo(10) and     ex2_expo(11) and not ex2_expo(12) and not ex2_expo(13) ;
      ex2_lzo_dcd_lo( 5) <= not ex2_expo(10) and     ex2_expo(11) and not ex2_expo(12) and     ex2_expo(13) ;
      ex2_lzo_dcd_lo( 6) <= not ex2_expo(10) and     ex2_expo(11) and     ex2_expo(12) and not ex2_expo(13) ;
      ex2_lzo_dcd_lo( 7) <= not ex2_expo(10) and     ex2_expo(11) and     ex2_expo(12) and     ex2_expo(13) ;
      ex2_lzo_dcd_lo( 8) <=     ex2_expo(10) and not ex2_expo(11) and not ex2_expo(12) and not ex2_expo(13) ;
      ex2_lzo_dcd_lo( 9) <=     ex2_expo(10) and not ex2_expo(11) and not ex2_expo(12) and     ex2_expo(13) ;
      ex2_lzo_dcd_lo(10) <=     ex2_expo(10) and not ex2_expo(11) and     ex2_expo(12) and not ex2_expo(13) ;
      ex2_lzo_dcd_lo(11) <=     ex2_expo(10) and not ex2_expo(11) and     ex2_expo(12) and     ex2_expo(13) ;
      ex2_lzo_dcd_lo(12) <=     ex2_expo(10) and     ex2_expo(11) and not ex2_expo(12) and not ex2_expo(13) ;
      ex2_lzo_dcd_lo(13) <=     ex2_expo(10) and     ex2_expo(11) and not ex2_expo(12) and     ex2_expo(13) ;
      ex2_lzo_dcd_lo(14) <=     ex2_expo(10) and     ex2_expo(11) and     ex2_expo(12) and not ex2_expo(13) ;
      ex2_lzo_dcd_lo(15) <=     ex2_expo(10) and     ex2_expo(11) and     ex2_expo(12) and     ex2_expo(13) ;



            
    
u_lzo_dcd_0:    ex2_lzo_dcd_b(  0) <= not( ex2_lzo_dcd_hi(0)  and  ex2_lzo_dcd_lo(1)  );
u_lzo_dcd_1:    ex2_lzo_dcd_b(  1) <= not( ex2_lzo_dcd_hi(0)  and  ex2_lzo_dcd_lo(2)  );
u_lzo_dcd_2:    ex2_lzo_dcd_b(  2) <= not( ex2_lzo_dcd_hi(0)  and  ex2_lzo_dcd_lo(3)  );
u_lzo_dcd_3:    ex2_lzo_dcd_b(  3) <= not( ex2_lzo_dcd_hi(0)  and  ex2_lzo_dcd_lo(4)  );
u_lzo_dcd_4:    ex2_lzo_dcd_b(  4) <= not( ex2_lzo_dcd_hi(0)  and  ex2_lzo_dcd_lo(5)  );
u_lzo_dcd_5:    ex2_lzo_dcd_b(  5) <= not( ex2_lzo_dcd_hi(0)  and  ex2_lzo_dcd_lo(6)  );
u_lzo_dcd_6:    ex2_lzo_dcd_b(  6) <= not( ex2_lzo_dcd_hi(0)  and  ex2_lzo_dcd_lo(7)  );
u_lzo_dcd_7:    ex2_lzo_dcd_b(  7) <= not( ex2_lzo_dcd_hi(0)  and  ex2_lzo_dcd_lo(8)  );
u_lzo_dcd_8:    ex2_lzo_dcd_b(  8) <= not( ex2_lzo_dcd_hi(0)  and  ex2_lzo_dcd_lo(9)  );
u_lzo_dcd_9:    ex2_lzo_dcd_b(  9) <= not( ex2_lzo_dcd_hi(0)  and  ex2_lzo_dcd_lo(10) );
u_lzo_dcd_10:   ex2_lzo_dcd_b( 10) <= not( ex2_lzo_dcd_hi(0)  and  ex2_lzo_dcd_lo(11) );
u_lzo_dcd_11:   ex2_lzo_dcd_b( 11) <= not( ex2_lzo_dcd_hi(0)  and  ex2_lzo_dcd_lo(12) );
u_lzo_dcd_12:   ex2_lzo_dcd_b( 12) <= not( ex2_lzo_dcd_hi(0)  and  ex2_lzo_dcd_lo(13) );
u_lzo_dcd_13:   ex2_lzo_dcd_b( 13) <= not( ex2_lzo_dcd_hi(0)  and  ex2_lzo_dcd_lo(14) );
u_lzo_dcd_14:   ex2_lzo_dcd_b( 14) <= not( ex2_lzo_dcd_hi(0)  and  ex2_lzo_dcd_lo(15) );

u_lzo_dcd_15:   ex2_lzo_dcd_b( 15) <= not( ex2_lzo_dcd_hi(1)  and  ex2_lzo_dcd_lo(0)  );
u_lzo_dcd_16:   ex2_lzo_dcd_b( 16) <= not( ex2_lzo_dcd_hi(1)  and  ex2_lzo_dcd_lo(1)  );
u_lzo_dcd_17:   ex2_lzo_dcd_b( 17) <= not( ex2_lzo_dcd_hi(1)  and  ex2_lzo_dcd_lo(2)  );
u_lzo_dcd_18:   ex2_lzo_dcd_b( 18) <= not( ex2_lzo_dcd_hi(1)  and  ex2_lzo_dcd_lo(3)  );
u_lzo_dcd_19:   ex2_lzo_dcd_b( 19) <= not( ex2_lzo_dcd_hi(1)  and  ex2_lzo_dcd_lo(4)  );
u_lzo_dcd_20:   ex2_lzo_dcd_b( 20) <= not( ex2_lzo_dcd_hi(1)  and  ex2_lzo_dcd_lo(5)  );
u_lzo_dcd_21:   ex2_lzo_dcd_b( 21) <= not( ex2_lzo_dcd_hi(1)  and  ex2_lzo_dcd_lo(6)  );
u_lzo_dcd_22:   ex2_lzo_dcd_b( 22) <= not( ex2_lzo_dcd_hi(1)  and  ex2_lzo_dcd_lo(7)  );
u_lzo_dcd_23:   ex2_lzo_dcd_b( 23) <= not( ex2_lzo_dcd_hi(1)  and  ex2_lzo_dcd_lo(8)  );
u_lzo_dcd_24:   ex2_lzo_dcd_b( 24) <= not( ex2_lzo_dcd_hi(1)  and  ex2_lzo_dcd_lo(9)  );
u_lzo_dcd_25:   ex2_lzo_dcd_b( 25) <= not( ex2_lzo_dcd_hi(1)  and  ex2_lzo_dcd_lo(10) );
u_lzo_dcd_26:   ex2_lzo_dcd_b( 26) <= not( ex2_lzo_dcd_hi(1)  and  ex2_lzo_dcd_lo(11) );
u_lzo_dcd_27:   ex2_lzo_dcd_b( 27) <= not( ex2_lzo_dcd_hi(1)  and  ex2_lzo_dcd_lo(12) );
u_lzo_dcd_28:   ex2_lzo_dcd_b( 28) <= not( ex2_lzo_dcd_hi(1)  and  ex2_lzo_dcd_lo(13) );
u_lzo_dcd_29:   ex2_lzo_dcd_b( 29) <= not( ex2_lzo_dcd_hi(1)  and  ex2_lzo_dcd_lo(14) );
u_lzo_dcd_30:   ex2_lzo_dcd_b( 30) <= not( ex2_lzo_dcd_hi(1)  and  ex2_lzo_dcd_lo(15) );

u_lzo_dcd_31:   ex2_lzo_dcd_b( 31) <= not( ex2_lzo_dcd_hi(2)  and  ex2_lzo_dcd_lo(0 ) );
u_lzo_dcd_32:   ex2_lzo_dcd_b( 32) <= not( ex2_lzo_dcd_hi(2)  and  ex2_lzo_dcd_lo(1 ) );
u_lzo_dcd_33:   ex2_lzo_dcd_b( 33) <= not( ex2_lzo_dcd_hi(2)  and  ex2_lzo_dcd_lo(2 ) );
u_lzo_dcd_34:   ex2_lzo_dcd_b( 34) <= not( ex2_lzo_dcd_hi(2)  and  ex2_lzo_dcd_lo(3 ) );
u_lzo_dcd_35:   ex2_lzo_dcd_b( 35) <= not( ex2_lzo_dcd_hi(2)  and  ex2_lzo_dcd_lo(4 ) );
u_lzo_dcd_36:   ex2_lzo_dcd_b( 36) <= not( ex2_lzo_dcd_hi(2)  and  ex2_lzo_dcd_lo(5 ) );
u_lzo_dcd_37:   ex2_lzo_dcd_b( 37) <= not( ex2_lzo_dcd_hi(2)  and  ex2_lzo_dcd_lo(6 ) );
u_lzo_dcd_38:   ex2_lzo_dcd_b( 38) <= not( ex2_lzo_dcd_hi(2)  and  ex2_lzo_dcd_lo(7 ) );
u_lzo_dcd_39:   ex2_lzo_dcd_b( 39) <= not( ex2_lzo_dcd_hi(2)  and  ex2_lzo_dcd_lo(8 ) );
u_lzo_dcd_40:   ex2_lzo_dcd_b( 40) <= not( ex2_lzo_dcd_hi(2)  and  ex2_lzo_dcd_lo(9 ) );
u_lzo_dcd_41:   ex2_lzo_dcd_b( 41) <= not( ex2_lzo_dcd_hi(2)  and  ex2_lzo_dcd_lo(10) );
u_lzo_dcd_42:   ex2_lzo_dcd_b( 42) <= not( ex2_lzo_dcd_hi(2)  and  ex2_lzo_dcd_lo(11) );
u_lzo_dcd_43:   ex2_lzo_dcd_b( 43) <= not( ex2_lzo_dcd_hi(2)  and  ex2_lzo_dcd_lo(12) );
u_lzo_dcd_44:   ex2_lzo_dcd_b( 44) <= not( ex2_lzo_dcd_hi(2)  and  ex2_lzo_dcd_lo(13) );
u_lzo_dcd_45:   ex2_lzo_dcd_b( 45) <= not( ex2_lzo_dcd_hi(2)  and  ex2_lzo_dcd_lo(14) );
u_lzo_dcd_46:   ex2_lzo_dcd_b( 46) <= not( ex2_lzo_dcd_hi(2)  and  ex2_lzo_dcd_lo(15) );

u_lzo_dcd_47:   ex2_lzo_dcd_b( 47) <= not( ex2_lzo_dcd_hi(3)  and  ex2_lzo_dcd_lo(0 ) );
u_lzo_dcd_48:   ex2_lzo_dcd_b( 48) <= not( ex2_lzo_dcd_hi(3)  and  ex2_lzo_dcd_lo(1 ) );
u_lzo_dcd_49:   ex2_lzo_dcd_b( 49) <= not( ex2_lzo_dcd_hi(3)  and  ex2_lzo_dcd_lo(2 ) );
u_lzo_dcd_50:   ex2_lzo_dcd_b( 50) <= not( ex2_lzo_dcd_hi(3)  and  ex2_lzo_dcd_lo(3 ) );
u_lzo_dcd_51:   ex2_lzo_dcd_b( 51) <= not( ex2_lzo_dcd_hi(3)  and  ex2_lzo_dcd_lo(4 ) );
u_lzo_dcd_52:   ex2_lzo_dcd_b( 52) <= not( ex2_lzo_dcd_hi(3)  and  ex2_lzo_dcd_lo(5 ) );
u_lzo_dcd_53:   ex2_lzo_dcd_b( 53) <= not( ex2_lzo_dcd_hi(3)  and  ex2_lzo_dcd_lo(6 ) );
u_lzo_dcd_54:   ex2_lzo_dcd_b( 54) <= not( ex2_lzo_dcd_hi(3)  and  ex2_lzo_dcd_lo(7 ) );
u_lzo_dcd_55:   ex2_lzo_dcd_b( 55) <= not( ex2_lzo_dcd_hi(3)  and  ex2_lzo_dcd_lo(8 ) );
u_lzo_dcd_56:   ex2_lzo_dcd_b( 56) <= not( ex2_lzo_dcd_hi(3)  and  ex2_lzo_dcd_lo(9 ) );
u_lzo_dcd_57:   ex2_lzo_dcd_b( 57) <= not( ex2_lzo_dcd_hi(3)  and  ex2_lzo_dcd_lo(10) );
u_lzo_dcd_58:   ex2_lzo_dcd_b( 58) <= not( ex2_lzo_dcd_hi(3)  and  ex2_lzo_dcd_lo(11) );
u_lzo_dcd_59:   ex2_lzo_dcd_b( 59) <= not( ex2_lzo_dcd_hi(3)  and  ex2_lzo_dcd_lo(12) );
u_lzo_dcd_60:   ex2_lzo_dcd_b( 60) <= not( ex2_lzo_dcd_hi(3)  and  ex2_lzo_dcd_lo(13) );
u_lzo_dcd_61:   ex2_lzo_dcd_b( 61) <= not( ex2_lzo_dcd_hi(3)  and  ex2_lzo_dcd_lo(14) );
u_lzo_dcd_62:   ex2_lzo_dcd_b( 62) <= not( ex2_lzo_dcd_hi(3)  and  ex2_lzo_dcd_lo(15) );

u_lzo_dcd_63:   ex2_lzo_dcd_b( 63) <= not( ex2_lzo_dcd_hi(4)  and  ex2_lzo_dcd_lo(0 ) );
u_lzo_dcd_64:   ex2_lzo_dcd_b( 64) <= not( ex2_lzo_dcd_hi(4)  and  ex2_lzo_dcd_lo(1 ) );
u_lzo_dcd_65:   ex2_lzo_dcd_b( 65) <= not( ex2_lzo_dcd_hi(4)  and  ex2_lzo_dcd_lo(2 ) );
u_lzo_dcd_66:   ex2_lzo_dcd_b( 66) <= not( ex2_lzo_dcd_hi(4)  and  ex2_lzo_dcd_lo(3 ) );
u_lzo_dcd_67:   ex2_lzo_dcd_b( 67) <= not( ex2_lzo_dcd_hi(4)  and  ex2_lzo_dcd_lo(4 ) );
u_lzo_dcd_68:   ex2_lzo_dcd_b( 68) <= not( ex2_lzo_dcd_hi(4)  and  ex2_lzo_dcd_lo(5 ) );
u_lzo_dcd_69:   ex2_lzo_dcd_b( 69) <= not( ex2_lzo_dcd_hi(4)  and  ex2_lzo_dcd_lo(6 ) );
u_lzo_dcd_70:   ex2_lzo_dcd_b( 70) <= not( ex2_lzo_dcd_hi(4)  and  ex2_lzo_dcd_lo(7 ) );
u_lzo_dcd_71:   ex2_lzo_dcd_b( 71) <= not( ex2_lzo_dcd_hi(4)  and  ex2_lzo_dcd_lo(8 ) );
u_lzo_dcd_72:   ex2_lzo_dcd_b( 72) <= not( ex2_lzo_dcd_hi(4)  and  ex2_lzo_dcd_lo(9 ) );
u_lzo_dcd_73:   ex2_lzo_dcd_b( 73) <= not( ex2_lzo_dcd_hi(4)  and  ex2_lzo_dcd_lo(10) );
u_lzo_dcd_74:   ex2_lzo_dcd_b( 74) <= not( ex2_lzo_dcd_hi(4)  and  ex2_lzo_dcd_lo(11) );
u_lzo_dcd_75:   ex2_lzo_dcd_b( 75) <= not( ex2_lzo_dcd_hi(4)  and  ex2_lzo_dcd_lo(12) );
u_lzo_dcd_76:   ex2_lzo_dcd_b( 76) <= not( ex2_lzo_dcd_hi(4)  and  ex2_lzo_dcd_lo(13) );
u_lzo_dcd_77:   ex2_lzo_dcd_b( 77) <= not( ex2_lzo_dcd_hi(4)  and  ex2_lzo_dcd_lo(14) );
u_lzo_dcd_78:   ex2_lzo_dcd_b( 78) <= not( ex2_lzo_dcd_hi(4)  and  ex2_lzo_dcd_lo(15) );

u_lzo_dcd_79:   ex2_lzo_dcd_b( 79) <= not( ex2_lzo_dcd_hi(5)  and  ex2_lzo_dcd_lo(0 ) );
u_lzo_dcd_80:   ex2_lzo_dcd_b( 80) <= not( ex2_lzo_dcd_hi(5)  and  ex2_lzo_dcd_lo(1 ) );
u_lzo_dcd_81:   ex2_lzo_dcd_b( 81) <= not( ex2_lzo_dcd_hi(5)  and  ex2_lzo_dcd_lo(2 ) );
u_lzo_dcd_82:   ex2_lzo_dcd_b( 82) <= not( ex2_lzo_dcd_hi(5)  and  ex2_lzo_dcd_lo(3 ) );
u_lzo_dcd_83:   ex2_lzo_dcd_b( 83) <= not( ex2_lzo_dcd_hi(5)  and  ex2_lzo_dcd_lo(4 ) );
u_lzo_dcd_84:   ex2_lzo_dcd_b( 84) <= not( ex2_lzo_dcd_hi(5)  and  ex2_lzo_dcd_lo(5 ) );
u_lzo_dcd_85:   ex2_lzo_dcd_b( 85) <= not( ex2_lzo_dcd_hi(5)  and  ex2_lzo_dcd_lo(6 ) );
u_lzo_dcd_86:   ex2_lzo_dcd_b( 86) <= not( ex2_lzo_dcd_hi(5)  and  ex2_lzo_dcd_lo(7 ) );
u_lzo_dcd_87:   ex2_lzo_dcd_b( 87) <= not( ex2_lzo_dcd_hi(5)  and  ex2_lzo_dcd_lo(8 ) );
u_lzo_dcd_88:   ex2_lzo_dcd_b( 88) <= not( ex2_lzo_dcd_hi(5)  and  ex2_lzo_dcd_lo(9 ) );
u_lzo_dcd_89:   ex2_lzo_dcd_b( 89) <= not( ex2_lzo_dcd_hi(5)  and  ex2_lzo_dcd_lo(10) );
u_lzo_dcd_90:   ex2_lzo_dcd_b( 90) <= not( ex2_lzo_dcd_hi(5)  and  ex2_lzo_dcd_lo(11) );
u_lzo_dcd_91:   ex2_lzo_dcd_b( 91) <= not( ex2_lzo_dcd_hi(5)  and  ex2_lzo_dcd_lo(12) );
u_lzo_dcd_92:   ex2_lzo_dcd_b( 92) <= not( ex2_lzo_dcd_hi(5)  and  ex2_lzo_dcd_lo(13) );
u_lzo_dcd_93:   ex2_lzo_dcd_b( 93) <= not( ex2_lzo_dcd_hi(5)  and  ex2_lzo_dcd_lo(14) );
u_lzo_dcd_94:   ex2_lzo_dcd_b( 94) <= not( ex2_lzo_dcd_hi(5)  and  ex2_lzo_dcd_lo(15) );

u_lzo_dcd_95:   ex2_lzo_dcd_b( 95) <= not( ex2_lzo_dcd_hi(6)  and  ex2_lzo_dcd_lo(0 ) );
u_lzo_dcd_96:   ex2_lzo_dcd_b( 96) <= not( ex2_lzo_dcd_hi(6)  and  ex2_lzo_dcd_lo(1 ) );
u_lzo_dcd_97:   ex2_lzo_dcd_b( 97) <= not( ex2_lzo_dcd_hi(6)  and  ex2_lzo_dcd_lo(2 ) );
u_lzo_dcd_98:   ex2_lzo_dcd_b( 98) <= not( ex2_lzo_dcd_hi(6)  and  ex2_lzo_dcd_lo(3 ) );
u_lzo_dcd_99:   ex2_lzo_dcd_b( 99) <= not( ex2_lzo_dcd_hi(6)  and  ex2_lzo_dcd_lo(4 ) );
u_lzo_dcd_100:  ex2_lzo_dcd_b(100) <= not( ex2_lzo_dcd_hi(6)  and  ex2_lzo_dcd_lo(5 ) );
u_lzo_dcd_101:  ex2_lzo_dcd_b(101) <= not( ex2_lzo_dcd_hi(6)  and  ex2_lzo_dcd_lo(6 ) );
u_lzo_dcd_102:  ex2_lzo_dcd_b(102) <= not( ex2_lzo_dcd_hi(6)  and  ex2_lzo_dcd_lo(7 ) );
u_lzo_dcd_103:  ex2_lzo_dcd_b(103) <= not( ex2_lzo_dcd_hi(6)  and  ex2_lzo_dcd_lo(8 ) );
u_lzo_dcd_104:  ex2_lzo_dcd_b(104) <= not( ex2_lzo_dcd_hi(6)  and  ex2_lzo_dcd_lo(9 ) );
u_lzo_dcd_105:  ex2_lzo_dcd_b(105) <= not( ex2_lzo_dcd_hi(6)  and  ex2_lzo_dcd_lo(10) );
u_lzo_dcd_106:  ex2_lzo_dcd_b(106) <= not( ex2_lzo_dcd_hi(6)  and  ex2_lzo_dcd_lo(11) );
u_lzo_dcd_107:  ex2_lzo_dcd_b(107) <= not( ex2_lzo_dcd_hi(6)  and  ex2_lzo_dcd_lo(12) );
u_lzo_dcd_108:  ex2_lzo_dcd_b(108) <= not( ex2_lzo_dcd_hi(6)  and  ex2_lzo_dcd_lo(13) );
u_lzo_dcd_109:  ex2_lzo_dcd_b(109) <= not( ex2_lzo_dcd_hi(6)  and  ex2_lzo_dcd_lo(14) );
u_lzo_dcd_110:  ex2_lzo_dcd_b(110) <= not( ex2_lzo_dcd_hi(6)  and  ex2_lzo_dcd_lo(15) );

u_lzo_dcd_111:  ex2_lzo_dcd_b(111) <= not( ex2_lzo_dcd_hi(7)  and  ex2_lzo_dcd_lo(0 ) );
u_lzo_dcd_112:  ex2_lzo_dcd_b(112) <= not( ex2_lzo_dcd_hi(7)  and  ex2_lzo_dcd_lo(1 ) );
u_lzo_dcd_113:  ex2_lzo_dcd_b(113) <= not( ex2_lzo_dcd_hi(7)  and  ex2_lzo_dcd_lo(2 ) );
u_lzo_dcd_114:  ex2_lzo_dcd_b(114) <= not( ex2_lzo_dcd_hi(7)  and  ex2_lzo_dcd_lo(3 ) );
u_lzo_dcd_115:  ex2_lzo_dcd_b(115) <= not( ex2_lzo_dcd_hi(7)  and  ex2_lzo_dcd_lo(4 ) );
u_lzo_dcd_116:  ex2_lzo_dcd_b(116) <= not( ex2_lzo_dcd_hi(7)  and  ex2_lzo_dcd_lo(5 ) );
u_lzo_dcd_117:  ex2_lzo_dcd_b(117) <= not( ex2_lzo_dcd_hi(7)  and  ex2_lzo_dcd_lo(6 ) );
u_lzo_dcd_118:  ex2_lzo_dcd_b(118) <= not( ex2_lzo_dcd_hi(7)  and  ex2_lzo_dcd_lo(7 ) );
u_lzo_dcd_119:  ex2_lzo_dcd_b(119) <= not( ex2_lzo_dcd_hi(7)  and  ex2_lzo_dcd_lo(8 ) );
u_lzo_dcd_120:  ex2_lzo_dcd_b(120) <= not( ex2_lzo_dcd_hi(7)  and  ex2_lzo_dcd_lo(9 ) );
u_lzo_dcd_121:  ex2_lzo_dcd_b(121) <= not( ex2_lzo_dcd_hi(7)  and  ex2_lzo_dcd_lo(10) );
u_lzo_dcd_122:  ex2_lzo_dcd_b(122) <= not( ex2_lzo_dcd_hi(7)  and  ex2_lzo_dcd_lo(11) );
u_lzo_dcd_123:  ex2_lzo_dcd_b(123) <= not( ex2_lzo_dcd_hi(7)  and  ex2_lzo_dcd_lo(12) );
u_lzo_dcd_124:  ex2_lzo_dcd_b(124) <= not( ex2_lzo_dcd_hi(7)  and  ex2_lzo_dcd_lo(13) );
u_lzo_dcd_125:  ex2_lzo_dcd_b(125) <= not( ex2_lzo_dcd_hi(7)  and  ex2_lzo_dcd_lo(14) );
u_lzo_dcd_126:  ex2_lzo_dcd_b(126) <= not( ex2_lzo_dcd_hi(7)  and  ex2_lzo_dcd_lo(15) );

u_lzo_dcd_127:  ex2_lzo_dcd_b(127) <= not( ex2_lzo_dcd_hi(8)  and  ex2_lzo_dcd_lo(0 ) );
u_lzo_dcd_128:  ex2_lzo_dcd_b(128) <= not( ex2_lzo_dcd_hi(8)  and  ex2_lzo_dcd_lo(1 ) );
u_lzo_dcd_129:  ex2_lzo_dcd_b(129) <= not( ex2_lzo_dcd_hi(8)  and  ex2_lzo_dcd_lo(2 ) );
u_lzo_dcd_130:  ex2_lzo_dcd_b(130) <= not( ex2_lzo_dcd_hi(8)  and  ex2_lzo_dcd_lo(3 ) );
u_lzo_dcd_131:  ex2_lzo_dcd_b(131) <= not( ex2_lzo_dcd_hi(8)  and  ex2_lzo_dcd_lo(4 ) );
u_lzo_dcd_132:  ex2_lzo_dcd_b(132) <= not( ex2_lzo_dcd_hi(8)  and  ex2_lzo_dcd_lo(5 ) );
u_lzo_dcd_133:  ex2_lzo_dcd_b(133) <= not( ex2_lzo_dcd_hi(8)  and  ex2_lzo_dcd_lo(6 ) );
u_lzo_dcd_134:  ex2_lzo_dcd_b(134) <= not( ex2_lzo_dcd_hi(8)  and  ex2_lzo_dcd_lo(7 ) );
u_lzo_dcd_135:  ex2_lzo_dcd_b(135) <= not( ex2_lzo_dcd_hi(8)  and  ex2_lzo_dcd_lo(8 ) );
u_lzo_dcd_136:  ex2_lzo_dcd_b(136) <= not( ex2_lzo_dcd_hi(8)  and  ex2_lzo_dcd_lo(9 ) );
u_lzo_dcd_137:  ex2_lzo_dcd_b(137) <= not( ex2_lzo_dcd_hi(8)  and  ex2_lzo_dcd_lo(10) );
u_lzo_dcd_138:  ex2_lzo_dcd_b(138) <= not( ex2_lzo_dcd_hi(8)  and  ex2_lzo_dcd_lo(11) );
u_lzo_dcd_139:  ex2_lzo_dcd_b(139) <= not( ex2_lzo_dcd_hi(8)  and  ex2_lzo_dcd_lo(12) );
u_lzo_dcd_140:  ex2_lzo_dcd_b(140) <= not( ex2_lzo_dcd_hi(8)  and  ex2_lzo_dcd_lo(13) );
u_lzo_dcd_141:  ex2_lzo_dcd_b(141) <= not( ex2_lzo_dcd_hi(8)  and  ex2_lzo_dcd_lo(14) );
u_lzo_dcd_142:  ex2_lzo_dcd_b(142) <= not( ex2_lzo_dcd_hi(8)  and  ex2_lzo_dcd_lo(15) );

u_lzo_dcd_143:  ex2_lzo_dcd_b(143) <= not( ex2_lzo_dcd_hi(9)  and  ex2_lzo_dcd_lo(0 ) );
u_lzo_dcd_144:  ex2_lzo_dcd_b(144) <= not( ex2_lzo_dcd_hi(9)  and  ex2_lzo_dcd_lo(1 ) );
u_lzo_dcd_145:  ex2_lzo_dcd_b(145) <= not( ex2_lzo_dcd_hi(9)  and  ex2_lzo_dcd_lo(2 ) );
u_lzo_dcd_146:  ex2_lzo_dcd_b(146) <= not( ex2_lzo_dcd_hi(9)  and  ex2_lzo_dcd_lo(3 ) );
u_lzo_dcd_147:  ex2_lzo_dcd_b(147) <= not( ex2_lzo_dcd_hi(9)  and  ex2_lzo_dcd_lo(4 ) );
u_lzo_dcd_148:  ex2_lzo_dcd_b(148) <= not( ex2_lzo_dcd_hi(9)  and  ex2_lzo_dcd_lo(5 ) );
u_lzo_dcd_149:  ex2_lzo_dcd_b(149) <= not( ex2_lzo_dcd_hi(9)  and  ex2_lzo_dcd_lo(6 ) );
u_lzo_dcd_150:  ex2_lzo_dcd_b(150) <= not( ex2_lzo_dcd_hi(9)  and  ex2_lzo_dcd_lo(7 ) );
u_lzo_dcd_151:  ex2_lzo_dcd_b(151) <= not( ex2_lzo_dcd_hi(9)  and  ex2_lzo_dcd_lo(8 ) );
u_lzo_dcd_152:  ex2_lzo_dcd_b(152) <= not( ex2_lzo_dcd_hi(9)  and  ex2_lzo_dcd_lo(9 ) );
u_lzo_dcd_153:  ex2_lzo_dcd_b(153) <= not( ex2_lzo_dcd_hi(9)  and  ex2_lzo_dcd_lo(10) );
u_lzo_dcd_154:  ex2_lzo_dcd_b(154) <= not( ex2_lzo_dcd_hi(9)  and  ex2_lzo_dcd_lo(11) );
u_lzo_dcd_155:  ex2_lzo_dcd_b(155) <= not( ex2_lzo_dcd_hi(9)  and  ex2_lzo_dcd_lo(12) );
u_lzo_dcd_156:  ex2_lzo_dcd_b(156) <= not( ex2_lzo_dcd_hi(9)  and  ex2_lzo_dcd_lo(13) );
u_lzo_dcd_157:  ex2_lzo_dcd_b(157) <= not( ex2_lzo_dcd_hi(9)  and  ex2_lzo_dcd_lo(14) );
u_lzo_dcd_158:  ex2_lzo_dcd_b(158) <= not( ex2_lzo_dcd_hi(9)  and  ex2_lzo_dcd_lo(15) );

u_lzo_dcd_159:  ex2_lzo_dcd_b(159) <= not( ex2_lzo_dcd_hi(10) and  ex2_lzo_dcd_lo(0) );
u_lzo_dcd_160:  ex2_lzo_dcd_b(160) <= not( ex2_lzo_dcd_hi(10) and  ex2_lzo_dcd_lo(1) );
u_lzo_dcd_161:  ex2_lzo_dcd_b(161) <= not( ex2_lzo_dcd_hi(10) and  ex2_lzo_dcd_lo(2) );
u_lzo_dcd_162:  ex2_lzo_dcd_b(162) <= not( ex2_lzo_dcd_hi(10) and  ex2_lzo_dcd_lo(3) );



f_alg_ex2_sel_byp_b  <= not( f_alg_ex2_sel_byp ); 
ex2_lzo_nonbyp_0_b   <= not( ex2_lzo_nonbyp_0  );
ex2_lzo_forbyp_0_b   <= not( ex2_lzo_forbyp_0  );


u_lzo_din_0:   f_lze_ex2_lzo_din(  0) <= not( (  f_alg_ex2_sel_byp   or ex2_lzo_nonbyp_0_b ) and -- neg input and/or
                                              (  f_alg_ex2_sel_byp_b or ex2_lzo_forbyp_0_b )    );
u_lzo_din_1:   f_lze_ex2_lzo_din(  1) <= not( f_alg_ex2_sel_byp    or ex2_lzo_dcd_b(1)  ); -- neg input and --
u_lzo_din_2:   f_lze_ex2_lzo_din(  2) <= not( f_alg_ex2_sel_byp    or ex2_lzo_dcd_b(2)  ); -- neg input and --
u_lzo_din_3:   f_lze_ex2_lzo_din(  3) <= not( f_alg_ex2_sel_byp    or ex2_lzo_dcd_b(3)  ); -- neg input and --
u_lzo_din_4:   f_lze_ex2_lzo_din(  4) <= not( f_alg_ex2_sel_byp    or ex2_lzo_dcd_b(4)  ); -- neg input and --
u_lzo_din_5:   f_lze_ex2_lzo_din(  5) <= not( f_alg_ex2_sel_byp    or ex2_lzo_dcd_b(5)  ); -- neg input and --
u_lzo_din_6:   f_lze_ex2_lzo_din(  6) <= not( f_alg_ex2_sel_byp    or ex2_lzo_dcd_b(6)  ); -- neg input and --
u_lzo_din_7:   f_lze_ex2_lzo_din(  7) <= not( f_alg_ex2_sel_byp    or ex2_lzo_dcd_b(7)  ); -- neg input and --
u_lzo_din_8:   f_lze_ex2_lzo_din(  8) <= not( f_alg_ex2_sel_byp    or ex2_lzo_dcd_b(8)  ); -- neg input and --
u_lzo_din_9:   f_lze_ex2_lzo_din(  9) <= not( f_alg_ex2_sel_byp    or ex2_lzo_dcd_b(9)  ); -- neg input and --
u_lzo_din_10:  f_lze_ex2_lzo_din( 10) <= not( f_alg_ex2_sel_byp    or ex2_lzo_dcd_b(10) ); -- neg input and --
u_lzo_din_11:  f_lze_ex2_lzo_din( 11) <= not( f_alg_ex2_sel_byp    or ex2_lzo_dcd_b(11) ); -- neg input and --
u_lzo_din_12:  f_lze_ex2_lzo_din( 12) <= not( f_alg_ex2_sel_byp    or ex2_lzo_dcd_b(12) ); -- neg input and --
u_lzo_din_13:  f_lze_ex2_lzo_din( 13) <= not( f_alg_ex2_sel_byp    or ex2_lzo_dcd_b(13) ); -- neg input and --
u_lzo_din_14:  f_lze_ex2_lzo_din( 14) <= not( f_alg_ex2_sel_byp    or ex2_lzo_dcd_b(14) ); -- neg input and --
u_lzo_din_15:  f_lze_ex2_lzo_din( 15) <= not( f_alg_ex2_sel_byp    or ex2_lzo_dcd_b(15) ); -- neg input and --
u_lzo_din_16:  f_lze_ex2_lzo_din( 16) <= not( f_alg_ex2_sel_byp    or ex2_lzo_dcd_b(16) ); -- neg input and --
u_lzo_din_17:  f_lze_ex2_lzo_din( 17) <= not( f_alg_ex2_sel_byp    or ex2_lzo_dcd_b(17) ); -- neg input and --
u_lzo_din_18:  f_lze_ex2_lzo_din( 18) <= not( f_alg_ex2_sel_byp    or ex2_lzo_dcd_b(18) ); -- neg input and --
u_lzo_din_19:  f_lze_ex2_lzo_din( 19) <= not( f_alg_ex2_sel_byp    or ex2_lzo_dcd_b(19) ); -- neg input and --
u_lzo_din_20:  f_lze_ex2_lzo_din( 20) <= not( f_alg_ex2_sel_byp    or ex2_lzo_dcd_b(20) ); -- neg input and --
u_lzo_din_21:  f_lze_ex2_lzo_din( 21) <= not( f_alg_ex2_sel_byp    or ex2_lzo_dcd_b(21) ); -- neg input and --
u_lzo_din_22:  f_lze_ex2_lzo_din( 22) <= not( f_alg_ex2_sel_byp    or ex2_lzo_dcd_b(22) ); -- neg input and --
u_lzo_din_23:  f_lze_ex2_lzo_din( 23) <= not( f_alg_ex2_sel_byp    or ex2_lzo_dcd_b(23) ); -- neg input and --
u_lzo_din_24:  f_lze_ex2_lzo_din( 24) <= not( f_alg_ex2_sel_byp    or ex2_lzo_dcd_b(24) ); -- neg input and --
u_lzo_din_25:  f_lze_ex2_lzo_din( 25) <= not( f_alg_ex2_sel_byp    or ex2_lzo_dcd_b(25) ); -- neg input and --
u_lzo_din_26:  f_lze_ex2_lzo_din( 26) <= not( f_alg_ex2_sel_byp    or ex2_lzo_dcd_b(26) ); -- neg input and --
u_lzo_din_27:  f_lze_ex2_lzo_din( 27) <= not( f_alg_ex2_sel_byp    or ex2_lzo_dcd_b(27) ); -- neg input and --
u_lzo_din_28:  f_lze_ex2_lzo_din( 28) <= not( f_alg_ex2_sel_byp    or ex2_lzo_dcd_b(28) ); -- neg input and --
u_lzo_din_29:  f_lze_ex2_lzo_din( 29) <= not( f_alg_ex2_sel_byp    or ex2_lzo_dcd_b(29) ); -- neg input and --
u_lzo_din_30:  f_lze_ex2_lzo_din( 30) <= not( f_alg_ex2_sel_byp    or ex2_lzo_dcd_b(30) ); -- neg input and --
u_lzo_din_31:  f_lze_ex2_lzo_din( 31) <= not( f_alg_ex2_sel_byp    or ex2_lzo_dcd_b(31) ); -- neg input and --
u_lzo_din_32:  f_lze_ex2_lzo_din( 32) <= not( f_alg_ex2_sel_byp    or ex2_lzo_dcd_b(32) ); -- neg input and --
u_lzo_din_33:  f_lze_ex2_lzo_din( 33) <= not( f_alg_ex2_sel_byp    or ex2_lzo_dcd_b(33) ); -- neg input and --
u_lzo_din_34:  f_lze_ex2_lzo_din( 34) <= not( f_alg_ex2_sel_byp    or ex2_lzo_dcd_b(34) ); -- neg input and --
u_lzo_din_35:  f_lze_ex2_lzo_din( 35) <= not( f_alg_ex2_sel_byp    or ex2_lzo_dcd_b(35) ); -- neg input and --
u_lzo_din_36:  f_lze_ex2_lzo_din( 36) <= not( f_alg_ex2_sel_byp    or ex2_lzo_dcd_b(36) ); -- neg input and --
u_lzo_din_37:  f_lze_ex2_lzo_din( 37) <= not( f_alg_ex2_sel_byp    or ex2_lzo_dcd_b(37) ); -- neg input and --
u_lzo_din_38:  f_lze_ex2_lzo_din( 38) <= not( f_alg_ex2_sel_byp    or ex2_lzo_dcd_b(38) ); -- neg input and --
u_lzo_din_39:  f_lze_ex2_lzo_din( 39) <= not( f_alg_ex2_sel_byp    or ex2_lzo_dcd_b(39) ); -- neg input and --
u_lzo_din_40:  f_lze_ex2_lzo_din( 40) <= not( f_alg_ex2_sel_byp    or ex2_lzo_dcd_b(40) ); -- neg input and --
u_lzo_din_41:  f_lze_ex2_lzo_din( 41) <= not( f_alg_ex2_sel_byp    or ex2_lzo_dcd_b(41) ); -- neg input and --
u_lzo_din_42:  f_lze_ex2_lzo_din( 42) <= not( f_alg_ex2_sel_byp    or ex2_lzo_dcd_b(42) ); -- neg input and --
u_lzo_din_43:  f_lze_ex2_lzo_din( 43) <= not( f_alg_ex2_sel_byp    or ex2_lzo_dcd_b(43) ); -- neg input and --
u_lzo_din_44:  f_lze_ex2_lzo_din( 44) <= not( f_alg_ex2_sel_byp    or ex2_lzo_dcd_b(44) ); -- neg input and --
u_lzo_din_45:  f_lze_ex2_lzo_din( 45) <= not( f_alg_ex2_sel_byp    or ex2_lzo_dcd_b(45) ); -- neg input and --
u_lzo_din_46:  f_lze_ex2_lzo_din( 46) <= not( f_alg_ex2_sel_byp    or ex2_lzo_dcd_b(46) ); -- neg input and --
u_lzo_din_47:  f_lze_ex2_lzo_din( 47) <= not( f_alg_ex2_sel_byp    or ex2_lzo_dcd_b(47) ); -- neg input and --
u_lzo_din_48:  f_lze_ex2_lzo_din( 48) <= not( f_alg_ex2_sel_byp    or ex2_lzo_dcd_b(48) ); -- neg input and --
u_lzo_din_49:  f_lze_ex2_lzo_din( 49) <= not( f_alg_ex2_sel_byp    or ex2_lzo_dcd_b(49) ); -- neg input and --
u_lzo_din_50:  f_lze_ex2_lzo_din( 50) <= not( f_alg_ex2_sel_byp    or ex2_lzo_dcd_b(50) ); -- neg input and --
u_lzo_din_51:  f_lze_ex2_lzo_din( 51) <= not( f_alg_ex2_sel_byp    or ex2_lzo_dcd_b(51) ); -- neg input and --
u_lzo_din_52:  f_lze_ex2_lzo_din( 52) <= not( f_alg_ex2_sel_byp    or ex2_lzo_dcd_b(52) ); -- neg input and --
u_lzo_din_53:  f_lze_ex2_lzo_din( 53) <= not( f_alg_ex2_sel_byp    or ex2_lzo_dcd_b(53) ); -- neg input and --
u_lzo_din_54:  f_lze_ex2_lzo_din( 54) <= not( f_alg_ex2_sel_byp    or ex2_lzo_dcd_b(54) ); -- neg input and --
u_lzo_din_55:  f_lze_ex2_lzo_din( 55) <= not ex2_lzo_dcd_b(55) ;
u_lzo_din_56:  f_lze_ex2_lzo_din( 56) <= not ex2_lzo_dcd_b(56) ;
u_lzo_din_57:  f_lze_ex2_lzo_din( 57) <= not ex2_lzo_dcd_b(57) ;
u_lzo_din_58:  f_lze_ex2_lzo_din( 58) <= not ex2_lzo_dcd_b(58) ;
u_lzo_din_59:  f_lze_ex2_lzo_din( 59) <= not ex2_lzo_dcd_b(59) ;
u_lzo_din_60:  f_lze_ex2_lzo_din( 60) <= not ex2_lzo_dcd_b(60) ;
u_lzo_din_61:  f_lze_ex2_lzo_din( 61) <= not ex2_lzo_dcd_b(61) ;
u_lzo_din_62:  f_lze_ex2_lzo_din( 62) <= not ex2_lzo_dcd_b(62) ;
u_lzo_din_63:  f_lze_ex2_lzo_din( 63) <= not ex2_lzo_dcd_b(63) ;
u_lzo_din_64:  f_lze_ex2_lzo_din( 64) <= not ex2_lzo_dcd_b(64) ;
u_lzo_din_65:  f_lze_ex2_lzo_din( 65) <= not ex2_lzo_dcd_b(65) ;
u_lzo_din_66:  f_lze_ex2_lzo_din( 66) <= not ex2_lzo_dcd_b(66) ;
u_lzo_din_67:  f_lze_ex2_lzo_din( 67) <= not ex2_lzo_dcd_b(67) ;
u_lzo_din_68:  f_lze_ex2_lzo_din( 68) <= not ex2_lzo_dcd_b(68) ;
u_lzo_din_69:  f_lze_ex2_lzo_din( 69) <= not ex2_lzo_dcd_b(69) ;
u_lzo_din_70:  f_lze_ex2_lzo_din( 70) <= not ex2_lzo_dcd_b(70) ;
u_lzo_din_71:  f_lze_ex2_lzo_din( 71) <= not ex2_lzo_dcd_b(71) ;
u_lzo_din_72:  f_lze_ex2_lzo_din( 72) <= not ex2_lzo_dcd_b(72) ;
u_lzo_din_73:  f_lze_ex2_lzo_din( 73) <= not ex2_lzo_dcd_b(73) ;
u_lzo_din_74:  f_lze_ex2_lzo_din( 74) <= not ex2_lzo_dcd_b(74) ;
u_lzo_din_75:  f_lze_ex2_lzo_din( 75) <= not ex2_lzo_dcd_b(75) ;
u_lzo_din_76:  f_lze_ex2_lzo_din( 76) <= not ex2_lzo_dcd_b(76) ;
u_lzo_din_77:  f_lze_ex2_lzo_din( 77) <= not ex2_lzo_dcd_b(77) ;
u_lzo_din_78:  f_lze_ex2_lzo_din( 78) <= not ex2_lzo_dcd_b(78) ;
u_lzo_din_79:  f_lze_ex2_lzo_din( 79) <= not ex2_lzo_dcd_b(79) ;
u_lzo_din_80:  f_lze_ex2_lzo_din( 80) <= not ex2_lzo_dcd_b(80) ;
u_lzo_din_81:  f_lze_ex2_lzo_din( 81) <= not ex2_lzo_dcd_b(81) ;
u_lzo_din_82:  f_lze_ex2_lzo_din( 82) <= not ex2_lzo_dcd_b(82) ;
u_lzo_din_83:  f_lze_ex2_lzo_din( 83) <= not ex2_lzo_dcd_b(83) ;
u_lzo_din_84:  f_lze_ex2_lzo_din( 84) <= not ex2_lzo_dcd_b(84) ;
u_lzo_din_85:  f_lze_ex2_lzo_din( 85) <= not ex2_lzo_dcd_b(85) ;
u_lzo_din_86:  f_lze_ex2_lzo_din( 86) <= not ex2_lzo_dcd_b(86) ;
u_lzo_din_87:  f_lze_ex2_lzo_din( 87) <= not ex2_lzo_dcd_b(87) ;
u_lzo_din_88:  f_lze_ex2_lzo_din( 88) <= not ex2_lzo_dcd_b(88) ;
u_lzo_din_89:  f_lze_ex2_lzo_din( 89) <= not ex2_lzo_dcd_b(89) ;
u_lzo_din_90:  f_lze_ex2_lzo_din( 90) <= not ex2_lzo_dcd_b(90) ;
u_lzo_din_91:  f_lze_ex2_lzo_din( 91) <= not ex2_lzo_dcd_b(91) ;
u_lzo_din_92:  f_lze_ex2_lzo_din( 92) <= not ex2_lzo_dcd_b(92) ;
u_lzo_din_93:  f_lze_ex2_lzo_din( 93) <= not ex2_lzo_dcd_b(93) ;
u_lzo_din_94:  f_lze_ex2_lzo_din( 94) <= not ex2_lzo_dcd_b(94) ;
u_lzo_din_95:  f_lze_ex2_lzo_din( 95) <= not ex2_lzo_dcd_b(95) ;
u_lzo_din_96:  f_lze_ex2_lzo_din( 96) <= not ex2_lzo_dcd_b(96) ;
u_lzo_din_97:  f_lze_ex2_lzo_din( 97) <= not ex2_lzo_dcd_b(97) ;
u_lzo_din_98:  f_lze_ex2_lzo_din( 98) <= not ex2_lzo_dcd_b(98) ;
u_lzo_din_99:  f_lze_ex2_lzo_din( 99) <= not(ex2_lzo_dcd_b(99) and not f_pic_ex2_to_integer );
u_lzo_din_100: f_lze_ex2_lzo_din(100) <= not ex2_lzo_dcd_b(100) ;
u_lzo_din_101: f_lze_ex2_lzo_din(101) <= not ex2_lzo_dcd_b(101) ;
u_lzo_din_102: f_lze_ex2_lzo_din(102) <= not ex2_lzo_dcd_b(102) ;
u_lzo_din_103: f_lze_ex2_lzo_din(103) <= not ex2_lzo_dcd_b(103) ;
u_lzo_din_104: f_lze_ex2_lzo_din(104) <= not ex2_lzo_dcd_b(104) ;
u_lzo_din_105: f_lze_ex2_lzo_din(105) <= not ex2_lzo_dcd_b(105) ;
u_lzo_din_106: f_lze_ex2_lzo_din(106) <= not ex2_lzo_dcd_b(106) ;
u_lzo_din_107: f_lze_ex2_lzo_din(107) <= not ex2_lzo_dcd_b(107) ;
u_lzo_din_108: f_lze_ex2_lzo_din(108) <= not ex2_lzo_dcd_b(108) ;
u_lzo_din_109: f_lze_ex2_lzo_din(109) <= not ex2_lzo_dcd_b(109) ;
u_lzo_din_110: f_lze_ex2_lzo_din(110) <= not ex2_lzo_dcd_b(110) ;
u_lzo_din_111: f_lze_ex2_lzo_din(111) <= not ex2_lzo_dcd_b(111) ;
u_lzo_din_112: f_lze_ex2_lzo_din(112) <= not ex2_lzo_dcd_b(112) ;
u_lzo_din_113: f_lze_ex2_lzo_din(113) <= not ex2_lzo_dcd_b(113) ;
u_lzo_din_114: f_lze_ex2_lzo_din(114) <= not ex2_lzo_dcd_b(114) ;
u_lzo_din_115: f_lze_ex2_lzo_din(115) <= not ex2_lzo_dcd_b(115) ;
u_lzo_din_116: f_lze_ex2_lzo_din(116) <= not ex2_lzo_dcd_b(116) ;
u_lzo_din_117: f_lze_ex2_lzo_din(117) <= not ex2_lzo_dcd_b(117) ;
u_lzo_din_118: f_lze_ex2_lzo_din(118) <= not ex2_lzo_dcd_b(118) ;
u_lzo_din_119: f_lze_ex2_lzo_din(119) <= not ex2_lzo_dcd_b(119) ;
u_lzo_din_120: f_lze_ex2_lzo_din(120) <= not ex2_lzo_dcd_b(120) ;
u_lzo_din_121: f_lze_ex2_lzo_din(121) <= not ex2_lzo_dcd_b(121) ;
u_lzo_din_122: f_lze_ex2_lzo_din(122) <= not ex2_lzo_dcd_b(122) ;
u_lzo_din_123: f_lze_ex2_lzo_din(123) <= not ex2_lzo_dcd_b(123) ;
u_lzo_din_124: f_lze_ex2_lzo_din(124) <= not ex2_lzo_dcd_b(124) ;
u_lzo_din_125: f_lze_ex2_lzo_din(125) <= not ex2_lzo_dcd_b(125) ;
u_lzo_din_126: f_lze_ex2_lzo_din(126) <= not ex2_lzo_dcd_b(126) ;
u_lzo_din_127: f_lze_ex2_lzo_din(127) <= not ex2_lzo_dcd_b(127) ;
u_lzo_din_128: f_lze_ex2_lzo_din(128) <= not ex2_lzo_dcd_b(128) ;
u_lzo_din_129: f_lze_ex2_lzo_din(129) <= not ex2_lzo_dcd_b(129) ;
u_lzo_din_130: f_lze_ex2_lzo_din(130) <= not ex2_lzo_dcd_b(130) ;
u_lzo_din_131: f_lze_ex2_lzo_din(131) <= not ex2_lzo_dcd_b(131) ;
u_lzo_din_132: f_lze_ex2_lzo_din(132) <= not ex2_lzo_dcd_b(132) ;
u_lzo_din_133: f_lze_ex2_lzo_din(133) <= not ex2_lzo_dcd_b(133) ;
u_lzo_din_134: f_lze_ex2_lzo_din(134) <= not ex2_lzo_dcd_b(134) ;
u_lzo_din_135: f_lze_ex2_lzo_din(135) <= not ex2_lzo_dcd_b(135) ;
u_lzo_din_136: f_lze_ex2_lzo_din(136) <= not ex2_lzo_dcd_b(136) ;
u_lzo_din_137: f_lze_ex2_lzo_din(137) <= not ex2_lzo_dcd_b(137) ;
u_lzo_din_138: f_lze_ex2_lzo_din(138) <= not ex2_lzo_dcd_b(138) ;
u_lzo_din_139: f_lze_ex2_lzo_din(139) <= not ex2_lzo_dcd_b(139) ;
u_lzo_din_140: f_lze_ex2_lzo_din(140) <= not ex2_lzo_dcd_b(140) ;
u_lzo_din_141: f_lze_ex2_lzo_din(141) <= not ex2_lzo_dcd_b(141) ;
u_lzo_din_142: f_lze_ex2_lzo_din(142) <= not ex2_lzo_dcd_b(142) ;
u_lzo_din_143: f_lze_ex2_lzo_din(143) <= not ex2_lzo_dcd_b(143) ;
u_lzo_din_144: f_lze_ex2_lzo_din(144) <= not ex2_lzo_dcd_b(144) ;
u_lzo_din_145: f_lze_ex2_lzo_din(145) <= not ex2_lzo_dcd_b(145) ;
u_lzo_din_146: f_lze_ex2_lzo_din(146) <= not ex2_lzo_dcd_b(146) ;
u_lzo_din_147: f_lze_ex2_lzo_din(147) <= not ex2_lzo_dcd_b(147) ;
u_lzo_din_148: f_lze_ex2_lzo_din(148) <= not ex2_lzo_dcd_b(148) ;
u_lzo_din_149: f_lze_ex2_lzo_din(149) <= not ex2_lzo_dcd_b(149) ;
u_lzo_din_150: f_lze_ex2_lzo_din(150) <= not ex2_lzo_dcd_b(150) ;
u_lzo_din_151: f_lze_ex2_lzo_din(151) <= not ex2_lzo_dcd_b(151) ;
u_lzo_din_152: f_lze_ex2_lzo_din(152) <= not ex2_lzo_dcd_b(152) ;
u_lzo_din_153: f_lze_ex2_lzo_din(153) <= not ex2_lzo_dcd_b(153) ;
u_lzo_din_154: f_lze_ex2_lzo_din(154) <= not ex2_lzo_dcd_b(154) ;
u_lzo_din_155: f_lze_ex2_lzo_din(155) <= not ex2_lzo_dcd_b(155) ;
u_lzo_din_156: f_lze_ex2_lzo_din(156) <= not ex2_lzo_dcd_b(156) ;
u_lzo_din_157: f_lze_ex2_lzo_din(157) <= not ex2_lzo_dcd_b(157) ;
u_lzo_din_158: f_lze_ex2_lzo_din(158) <= not ex2_lzo_dcd_b(158) ;
u_lzo_din_159: f_lze_ex2_lzo_din(159) <= not ex2_lzo_dcd_b(159) ;
u_lzo_din_160: f_lze_ex2_lzo_din(160) <= not ex2_lzo_dcd_b(160) ;
u_lzo_din_161: f_lze_ex2_lzo_din(161) <= not ex2_lzo_dcd_b(161) ;
u_lzo_din_162: f_lze_ex2_lzo_din(162) <= not ex2_lzo_dcd_b(162) ;
 




   ex2_ins_est <= f_pic_ex2_est_recip or f_pic_ex2_est_rsqrt ;

   ex2_sh_rgt_en_by <= -- set LZO[0] so can just OR into result
         (    f_eie_ex2_use_bexp and ex2_expo_neg_sp_by and ex2_lzo_cont_sp and not f_alg_ex2_byp_nonflip and not ex2_ins_est) or 
         (    f_eie_ex2_use_bexp and ex2_expo_neg_dp_by and ex2_lzo_cont_dp and not f_alg_ex2_byp_nonflip and not ex2_ins_est) ;
   ex2_sh_rgt_en_p <= -- set LZO[0] so can just OR into result
         (not f_eie_ex2_use_bexp and ex2_expo_neg_sp    and ex2_lzo_cont_sp and not f_alg_ex2_byp_nonflip) or 
         (not f_eie_ex2_use_bexp and ex2_expo_neg_dp    and ex2_lzo_cont_dp and not f_alg_ex2_byp_nonflip) ;

   ex2_sh_rgt_en <= ex2_sh_rgt_en_by or ex2_sh_rgt_en_p;

--//----------------------------------------------------------------------------------------------
--// you might be thinking that the shift right amount needs a limiter (so that amounts > 64
--// do not wrap a round and leave bits in the result when the result should be zero).
--// (1) if the shift amount belongs to the "B" operand, (bypass) and since we only shift right
--//     when B is a denorm (it has a bit on) then the maximum shift right is (52) because
--//     the smallest b exponent (expo min) after prenorm is -52.
--//     there is the possibility that a divide could create an artificially small Bexpo.
--//     if that is true the shift right amount should be zero (right 64 followed by left 0).
--// (2) otherwise the right shift amount comes from the product exponent.
--//     the product exponent could be very small, however for a multiply add if it becomes
--//     too small then the exponent will come from the addend, so no problem.
--//     a multiply instruction does not have an addend, and it could have a very small exponent.
--//     BUT, the lead bit is at [55] and even if the shift right goes right 64 followed by left 64,
--//     it will not but a bit into the result or guard fields.
--//-----------------------------------------------------------------------------------------------

    -- calculate shift right amount (DP) ... expo must be correct value to subtract in expo logic
       -- decode =  0 shift right 1     -(-1) for expo   0_0000_0000_0000 -> 1_1111_1111_1111  -x = !x + 1,   !x = -x - 1
       -- decode = -1 shift right 2     -(-2) for expo   0_0000_0000_0001 -> 1_1111_1111_1110
       -- decode = -2 shift right 3     -(-3) for expo   0_0000_0000_0010 -> 1_1111_1111_1101
       --
       -- max = -53                                      0_0000_0011_0101 -> 1_1111_1100_1010
       --                                                                    * **** **dd_dddd

    -- calculate shift right amount (SP)
       -- decode = x380 shift right 1     -(-1) for expo   0_0011_1000_0000 -> 1_1100_0111_1111  -x = !x + 1,   !x = -x - 1
       -- decode = x37F shift right 2     -(-2) for expo   0_0011_1000_0001 -> 1_1100_0111_1110
       -- decode = x37E shift right 3     -(-3) for expo   0_0011_1000_0010 -> 1_1100_0111_1101
       --                                                                      * **** **dd_dddd

      -- expo = Bexpo - lza
      --        Bexpo + (!lza)  ... lza is usually sign extended and inverted to make a negative number,
      --        Bexpo must be added to in denorm cases
      --        Make lza a negative number, so that when it is flipped it becomes a positive number.
      --
      --                              expo_adj
      -- expo = x380 896 0_0011_1000_0000    1  -( 1)      1111_1111
      -- expo = x37f 895 0_0011_0111_1111    2  -( 2)      1111_1110
      -- expo = x37e 894 0_0011_0111_1110    3             1111_1101
      -- expo = x37d 893 0_0011_0111_1101    4             1111_1100
      -- expo = x37c 892 0_0011_0111_1100    5
      -- expo = x37b 891 0_0011_0111_1011    6
      -- expo = x37a 890 0_0011_0111_1010    7
      -- expo = x379 889 0_0011_0111_1001    8
      -- expo = x378 888 0_0011_0111_1000    9
      -- expo = x377 887 0_0011_0111_0111   10
      -- expo = x376 886 0_0011_0111_0110   11
      -- expo = x375 885 0_0011_0111_0101   12
      -- expo = x374 884 0_0011_0111_0100   13
      -- expo = x373 883 0_0011_0111_0011   14
      -- expo = x372 882 0_0011_0111_0010   15
      -- expo = x371 881 0_0011_0111_0001   16
      -- expo = x370 880 0_0011_0111_0000   17
      -- expo = x36f 879 0_0011_0110_1111   18
      -- expo = x36e 878 0_0011_0110_1110   19
      -- expo = x36d 877 0_0011_0110_1101   20
      -- expo = x36c 876 0_0011_0110_1100   21
      -- expo = x36b 875 0_0011_0110_1011   22
      -- expo = x36a 874 0_0011_0110_1010   23 -(23)       1110_1001
      -------------------------------
      -- expo = x369 873 0_0011_0110_1001   24 -(24)       1110_1000




-- if p_exp an be more neg then -63 , then this needs to be detected and shAmt forced to a const.

   ex2_expo_p_sim_p(8 to 13) <=  not ex2_expo(8 to 13);

   ex2_expo_p_sim_g(13)      <= ex2_expo(13) ;
   ex2_expo_p_sim_g(12)      <= ex2_expo(13) or ex2_expo(12) ;
   ex2_expo_p_sim_g(11)      <= ex2_expo(13) or ex2_expo(12) or ex2_expo(11) ;
   ex2_expo_p_sim_g(10)      <= ex2_expo(13) or ex2_expo(12) or ex2_expo(11) or ex2_expo(10) ;
   ex2_expo_p_sim_g( 9)      <= ex2_expo(13) or ex2_expo(12) or ex2_expo(11) or ex2_expo(10) or ex2_expo( 9) ;

   ex2_expo_p_sim(13) <= ex2_expo_p_sim_p(13) ; 
   ex2_expo_p_sim(12) <= ex2_expo_p_sim_p(12) xor ( ex2_expo_p_sim_g(13) ) ;
   ex2_expo_p_sim(11) <= ex2_expo_p_sim_p(11) xor ( ex2_expo_p_sim_g(12) ) ;
   ex2_expo_p_sim(10) <= ex2_expo_p_sim_p(10) xor ( ex2_expo_p_sim_g(11) ) ;
   ex2_expo_p_sim( 9) <= ex2_expo_p_sim_p( 9) xor ( ex2_expo_p_sim_g(10) ) ;
   ex2_expo_p_sim( 8) <= ex2_expo_p_sim_p( 8) xor ( ex2_expo_p_sim_g( 9) );




   ex2_expo_sim_p(8 to 13) <=  not ex2_expo_by(8 to 13);

   ex2_expo_sim_g(13)      <= ex2_expo_by(13) ;
   ex2_expo_sim_g(12)      <= ex2_expo_by(13) or ex2_expo_by(12) ;
   ex2_expo_sim_g(11)      <= ex2_expo_by(13) or ex2_expo_by(12) or ex2_expo_by(11) ;
   ex2_expo_sim_g(10)      <= ex2_expo_by(13) or ex2_expo_by(12) or ex2_expo_by(11) or ex2_expo_by(10) ;
   ex2_expo_sim_g( 9)      <= ex2_expo_by(13) or ex2_expo_by(12) or ex2_expo_by(11) or ex2_expo_by(10) or ex2_expo_by( 9) ;

   ex2_expo_sim(13) <= ex2_expo_sim_p(13) ; 
   ex2_expo_sim(12) <= ex2_expo_sim_p(12) xor ( ex2_expo_sim_g(13) ) ;
   ex2_expo_sim(11) <= ex2_expo_sim_p(11) xor ( ex2_expo_sim_g(12) ) ;
   ex2_expo_sim(10) <= ex2_expo_sim_p(10) xor ( ex2_expo_sim_g(11) ) ;
   ex2_expo_sim( 9) <= ex2_expo_sim_p( 9) xor ( ex2_expo_sim_g(10) ) ;
   ex2_expo_sim( 8) <= ex2_expo_sim_p( 8) xor ( ex2_expo_sim_g( 9) );



 ex2_lzo_forbyp_0 <= 
       (    f_pic_ex2_est_recip                ) or -- could include these in lzo dis
       (    f_pic_ex2_est_rsqrt                ) or -- could include these in lzo_dis
       (    f_alg_ex2_byp_nonflip  and not f_pic_ex2_prenorm  ) or 
       (not f_fmt_ex2_pass_msb_dp                and not f_pic_ex2_lzo_dis_prod   ) or   -- allow norm to decr MSB then renormalize
       (   (ex2_expo_neg_dp_by or ex2_dp_001_by) and ex2_lzo_cont_dp              ) or 
       (   (ex2_expo_neg_sp_by or ex2_sp_001_by) and ex2_lzo_cont_sp              ) ;  





 ex2_lzo_nonbyp_0        <=  ( ex2_lzo_dcd_0                      ) or
                             ( ex2_expo_neg_dp and ex2_lzo_cont_dp) or
                             ( ex2_expo_neg_sp and ex2_lzo_cont_sp) or  
                             ( f_pic_ex2_est_recip                ) or 
                             ( f_pic_ex2_est_rsqrt                ) ;


            
    ex2_sh_rgt_amt(0)      <= ex2_sh_rgt_en  ;-- huge shift right should give "0"
    ex2_sh_rgt_amt(1)      <= ex2_sh_rgt_en  ;-- huge shift right should give "0"
    ex2_sh_rgt_amt(2)      <= (ex2_sh_rgt_en_p and  ex2_expo_p_sim( 8)) or (ex2_sh_rgt_en_by and  ex2_expo_sim( 8));
    ex2_sh_rgt_amt(3)      <= (ex2_sh_rgt_en_p and  ex2_expo_p_sim( 9)) or (ex2_sh_rgt_en_by and  ex2_expo_sim( 9));
    ex2_sh_rgt_amt(4)      <= (ex2_sh_rgt_en_p and  ex2_expo_p_sim(10)) or (ex2_sh_rgt_en_by and  ex2_expo_sim(10));
    ex2_sh_rgt_amt(5)      <= (ex2_sh_rgt_en_p and  ex2_expo_p_sim(11)) or (ex2_sh_rgt_en_by and  ex2_expo_sim(11));
    ex2_sh_rgt_amt(6)      <= (ex2_sh_rgt_en_p and  ex2_expo_p_sim(12)) or (ex2_sh_rgt_en_by and  ex2_expo_sim(12));
    ex2_sh_rgt_amt(7)      <= (ex2_sh_rgt_en_p and  ex2_expo_p_sim(13)) or (ex2_sh_rgt_en_by and  ex2_expo_sim(13));


-- bit_to_set   |------ b_expo ----------|
--  0           897  x381 0_0011_1000_0001  <== all normal SP numbers go here
--  1           896  x380 0_0011_1000_0000
--  2           895  x37f 0_0011_0111_1111
--  3           894  x37e 0_0011_0111_1110
--  4           893  x37d 0_0011_0111_1101
--  5           892  x37c 0_0011_0111_1100
--  6           891  x37b 0_0011_0111_1011
--  7           890  x37a 0_0011_0111_1010
--  8           889  x379 0_0011_0111_1001
--  9           888  x378 0_0011_0111_1000
-- 10           887  x377 0_0011_0111_0111
-- 11           886  x376 0_0011_0111_0110
-- 12           885  x375 0_0011_0111_0101
-- 13           884  x374 0_0011_0111_0100  expo = (884 +26 -13) = 884 + 13 = 897
-- 14           883  x373 0_0011_0111_0011
-- 15           882  x372 0_0011_0111_0010
-- 16           881  x371 0_0011_0111_0001
-- 17           880  x370 0_0011_0111_0000
-- 18           879  x36f 0_0011_0011_1111
-- 19           878  x36e 0_0011_0011_1110
-- 20           877  x36d 0_0011_0011_1101
-- 21           876  x36c 0_0011_0011_1100
-- 22           875  x36b 0_0011_0011_1011
-- 23           874  x36a 0_0011_0011_1010
-- -----------------------------------------
-- 24           873  x369 0_0011_0011_1001 <=== if this or smaller do nothing (special case sp invalid)
--

---=###############################################################
---=## ex3 latches
---=###############################################################

    ex3_shr_lat:  tri_rlmreg_p generic map (width=> 9, expand_type => expand_type, needs_sreset => 0) port map ( 
        forcee => forcee,-- tidn,
        delay_lclkr      => delay_lclkr(3)   ,-- tidn,
        mpw1_b           => mpw1_b(3)        ,-- tidn,
        mpw2_b           => mpw2_b(0)        ,-- tidn,
        vd               => vdd,
        gd               => gnd,
        nclk             => nclk,
        act              => ex2_act,
        thold_b          => thold_0_b,
        sg               => sg_0, 
        scout            => ex3_shr_so  ,                      
        scin             => ex3_shr_si  ,                    
        -------------------
        din(0 to 7)      => ex2_sh_rgt_amt(0 to 7),
        din(8)           => ex2_sh_rgt_en ,
        -------------------
        dout(0 to 7)     => ex3_sh_rgt_amt(0 to 7),
        dout(8)          => ex3_sh_rgt_en  );



       f_lze_ex3_sh_rgt_amt(0 to 7)  <= ex3_sh_rgt_amt(0 to 7)  ; --OUTPUT--
       f_lze_ex3_sh_rgt_en           <= ex3_sh_rgt_en           ; --OUTPUT--


---=###############################################################
---= scan string
---=###############################################################

  ex3_shr_si(0 to 8) <= ex3_shr_so(1 to 8) & f_lze_si ;
  act_si    (0 to 4) <= act_so    (1 to 4) & ex3_shr_so(0);
  f_lze_so           <=   act_so(0);



end; -- fuq_lze ARCHITECTURE
