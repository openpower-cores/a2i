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

entity iuq_ic_insmux is
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
       inslat_act                                :in  std_ulogic;

       iu2_rd_way_hit_b                          :in  std_ulogic_vector(0 to 3); 
       load_iu2                                  :in  std_ulogic               ; 

       icm_icd_reload_data                       :in  std_ulogic_vector(0 to 143);
       iu2_data_dataout_0                        :in  std_ulogic_vector(0 to 143);
       iu2_data_dataout_1                        :in  std_ulogic_vector(0 to 143);
       iu2_data_dataout_2                        :in  std_ulogic_vector(0 to 143);
       iu2_data_dataout_3                        :in  std_ulogic_vector(0 to 143);

       iu3_instr0_buf                            :out std_ulogic_vector(0 to 35) ;
       iu3_instr1_buf                            :out std_ulogic_vector(0 to 35) ;
       iu3_instr2_buf                            :out std_ulogic_vector(0 to 35) ;
       iu3_instr3_buf                            :out std_ulogic_vector(0 to 35)  
);

-- synopsys translate_off



-- synopsys translate_on


end iuq_ic_insmux; 

architecture iuq_ic_insmux of iuq_ic_insmux is

  constant tiup : std_ulogic := '1';
  constant tidn : std_ulogic := '0';

  signal inslat_lclk  :clk_logic;
  signal inslat_d1clk :std_ulogic;
  signal inslat_d2clk :std_ulogic;

  signal iu3_instr0_si, iu3_instr0_so, iu3_instr0_l2_b, iu3_instr0_d1, iu3_instr0_d2 :std_ulogic_vector(0 to 35);
  signal iu3_instr1_si, iu3_instr1_so, iu3_instr1_l2_b, iu3_instr1_d1, iu3_instr1_d2 :std_ulogic_vector(0 to 35);
  signal iu3_instr2_si, iu3_instr2_so, iu3_instr2_l2_b, iu3_instr2_d1, iu3_instr2_d2 :std_ulogic_vector(0 to 35);
  signal iu3_instr3_si, iu3_instr3_so, iu3_instr3_l2_b, iu3_instr3_d1, iu3_instr3_d2 :std_ulogic_vector(0 to 35);
  signal iu3_instr0_oth_b, iu3_instr1_oth_b, iu3_instr2_oth_b, iu3_instr3_oth_b      :std_ulogic_vector(0 to 35);
  signal iu3_instr0_dx0_b, iu3_instr0_dx1_b, iu3_instr0_dx2_b, iu3_instr0_dx3_b      :std_ulogic_vector(0 to 35);
  signal iu3_instr1_dx0_b, iu3_instr1_dx1_b, iu3_instr1_dx2_b, iu3_instr1_dx3_b      :std_ulogic_vector(0 to 35);
  signal iu3_instr2_dx0_b, iu3_instr2_dx1_b, iu3_instr2_dx2_b, iu3_instr2_dx3_b      :std_ulogic_vector(0 to 35);
  signal iu3_instr3_dx0_b, iu3_instr3_dx1_b, iu3_instr3_dx2_b, iu3_instr3_dx3_b      :std_ulogic_vector(0 to 35);


-- synopsys translate_off








-- synopsys translate_on




   signal hit0_en0, hit0_en1, hit0_en2, hit0_en3 :std_ulogic_vector(0 to 35);
   signal hit1_en0, hit1_en1, hit1_en2, hit1_en3 :std_ulogic_vector(0 to 35);
   signal hit2_en0, hit2_en1, hit2_en2, hit2_en3 :std_ulogic_vector(0 to 35);
   signal hit3_en0, hit3_en1, hit3_en2, hit3_en3 :std_ulogic_vector(0 to 35);
   signal cached_enable :std_ulogic;

   signal hit0, hit1, hit2, hit3 :std_ulogic;
-- synopsys translate_off
-- synopsys translate_on
   signal hit0_en_b, hit1_en_b, hit2_en_b, hit3_en_b :std_ulogic_vector(0 to 3);
-- synopsys translate_off
-- synopsys translate_on
   signal hit0_en  , hit1_en  , hit2_en  , hit3_en   :std_ulogic_vector(0 to 7);
-- synopsys translate_off







-- synopsys translate_on



begin







   cached_enable <= not load_iu2  ; 

   u_hit0_i1:     hit0         <= not( iu2_rd_way_hit_b(0) ); 
   u_hit1_i1:     hit1         <= not( iu2_rd_way_hit_b(1) ); 
   u_hit2_i1:     hit2         <= not( iu2_rd_way_hit_b(2) ); 
   u_hit3_i1:     hit3         <= not( iu2_rd_way_hit_b(3) ); 

   u_hit0_a2_cp0: hit0_en_b(0) <= not( hit0 and cached_enable) ; 
   u_hit0_a2_cp1: hit0_en_b(1) <= not( hit0 and cached_enable) ; 
   u_hit0_a2_cp2: hit0_en_b(2) <= not( hit0 and cached_enable) ; 
   u_hit0_a2_cp3: hit0_en_b(3) <= not( hit0 and cached_enable) ; 

   u_hit1_a2_cp0: hit1_en_b(0) <= not( hit1 and cached_enable) ; 
   u_hit1_a2_cp1: hit1_en_b(1) <= not( hit1 and cached_enable) ; 
   u_hit1_a2_cp2: hit1_en_b(2) <= not( hit1 and cached_enable) ; 
   u_hit1_a2_cp3: hit1_en_b(3) <= not( hit1 and cached_enable) ; 

   u_hit2_a2_cp0: hit2_en_b(0) <= not( hit2 and cached_enable) ; 
   u_hit2_a2_cp1: hit2_en_b(1) <= not( hit2 and cached_enable) ; 
   u_hit2_a2_cp2: hit2_en_b(2) <= not( hit2 and cached_enable) ; 
   u_hit2_a2_cp3: hit2_en_b(3) <= not( hit2 and cached_enable) ; 

   u_hit3_a2_cp0: hit3_en_b(0) <= not( hit3 and cached_enable) ; 
   u_hit3_a2_cp1: hit3_en_b(1) <= not( hit3 and cached_enable) ; 
   u_hit3_a2_cp2: hit3_en_b(2) <= not( hit3 and cached_enable) ; 
   u_hit3_a2_cp3: hit3_en_b(3) <= not( hit3 and cached_enable) ; 


   u_hit0_i2_cp0: hit0_en(0)  <= not( hit0_en_b(0) ) ; 
   u_hit0_i2_cp1: hit0_en(1)  <= not( hit0_en_b(0) ) ; 
   u_hit0_i2_cp2: hit0_en(2)  <= not( hit0_en_b(1) ) ; 
   u_hit0_i2_cp3: hit0_en(3)  <= not( hit0_en_b(1) ) ; 
   u_hit0_i2_cp4: hit0_en(4)  <= not( hit0_en_b(2) ) ; 
   u_hit0_i2_cp5: hit0_en(5)  <= not( hit0_en_b(2) ) ; 
   u_hit0_i2_cp6: hit0_en(6)  <= not( hit0_en_b(3) ) ; 
   u_hit0_i2_cp7: hit0_en(7)  <= not( hit0_en_b(3) ) ; 

   u_hit1_i2_cp0: hit1_en(0)  <= not( hit1_en_b(0) ) ; 
   u_hit1_i2_cp1: hit1_en(1)  <= not( hit1_en_b(0) ) ; 
   u_hit1_i2_cp2: hit1_en(2)  <= not( hit1_en_b(1) ) ; 
   u_hit1_i2_cp3: hit1_en(3)  <= not( hit1_en_b(1) ) ; 
   u_hit1_i2_cp4: hit1_en(4)  <= not( hit1_en_b(2) ) ; 
   u_hit1_i2_cp5: hit1_en(5)  <= not( hit1_en_b(2) ) ; 
   u_hit1_i2_cp6: hit1_en(6)  <= not( hit1_en_b(3) ) ; 
   u_hit1_i2_cp7: hit1_en(7)  <= not( hit1_en_b(3) ) ; 

   u_hit2_i2_cp0: hit2_en(0)  <= not( hit2_en_b(0) ) ; 
   u_hit2_i2_cp1: hit2_en(1)  <= not( hit2_en_b(0) ) ; 
   u_hit2_i2_cp2: hit2_en(2)  <= not( hit2_en_b(1) ) ; 
   u_hit2_i2_cp3: hit2_en(3)  <= not( hit2_en_b(1) ) ; 
   u_hit2_i2_cp4: hit2_en(4)  <= not( hit2_en_b(2) ) ; 
   u_hit2_i2_cp5: hit2_en(5)  <= not( hit2_en_b(2) ) ; 
   u_hit2_i2_cp6: hit2_en(6)  <= not( hit2_en_b(3) ) ; 
   u_hit2_i2_cp7: hit2_en(7)  <= not( hit2_en_b(3) ) ; 

   u_hit3_i2_cp0: hit3_en(0)  <= not( hit3_en_b(0) ) ; 
   u_hit3_i2_cp1: hit3_en(1)  <= not( hit3_en_b(0) ) ; 
   u_hit3_i2_cp2: hit3_en(2)  <= not( hit3_en_b(1) ) ; 
   u_hit3_i2_cp3: hit3_en(3)  <= not( hit3_en_b(1) ) ; 
   u_hit3_i2_cp4: hit3_en(4)  <= not( hit3_en_b(2) ) ; 
   u_hit3_i2_cp5: hit3_en(5)  <= not( hit3_en_b(2) ) ; 
   u_hit3_i2_cp6: hit3_en(6)  <= not( hit3_en_b(3) ) ; 
   u_hit3_i2_cp7: hit3_en(7)  <= not( hit3_en_b(3) ) ; 

  


   hit0_en0( 0 to 17) <= ( 0 to 17 => hit0_en(0) );
   hit0_en0(18 to 35) <= (18 to 35 => hit0_en(1) );
   hit0_en1( 0 to 17) <= ( 0 to 17 => hit0_en(2) );
   hit0_en1(18 to 35) <= (18 to 35 => hit0_en(3) );
   hit0_en2( 0 to 17) <= ( 0 to 17 => hit0_en(4) );
   hit0_en2(18 to 35) <= (18 to 35 => hit0_en(5) );
   hit0_en3( 0 to 17) <= ( 0 to 17 => hit0_en(6) );
   hit0_en3(18 to 35) <= (18 to 35 => hit0_en(7) );

   hit1_en0( 0 to 17) <= ( 0 to 17 => hit1_en(0) );
   hit1_en0(18 to 35) <= (18 to 35 => hit1_en(1) );
   hit1_en1( 0 to 17) <= ( 0 to 17 => hit1_en(2) );
   hit1_en1(18 to 35) <= (18 to 35 => hit1_en(3) );
   hit1_en2( 0 to 17) <= ( 0 to 17 => hit1_en(4) );
   hit1_en2(18 to 35) <= (18 to 35 => hit1_en(5) );
   hit1_en3( 0 to 17) <= ( 0 to 17 => hit1_en(6) );
   hit1_en3(18 to 35) <= (18 to 35 => hit1_en(7) );

   hit2_en0( 0 to 17) <= ( 0 to 17 => hit2_en(0) );
   hit2_en0(18 to 35) <= (18 to 35 => hit2_en(1) );
   hit2_en1( 0 to 17) <= ( 0 to 17 => hit2_en(2) );
   hit2_en1(18 to 35) <= (18 to 35 => hit2_en(3) );
   hit2_en2( 0 to 17) <= ( 0 to 17 => hit2_en(4) );
   hit2_en2(18 to 35) <= (18 to 35 => hit2_en(5) );
   hit2_en3( 0 to 17) <= ( 0 to 17 => hit2_en(6) );
   hit2_en3(18 to 35) <= (18 to 35 => hit2_en(7) );

   hit3_en0( 0 to 17) <= ( 0 to 17 => hit3_en(0) );
   hit3_en0(18 to 35) <= (18 to 35 => hit3_en(1) );
   hit3_en1( 0 to 17) <= ( 0 to 17 => hit3_en(2) );
   hit3_en1(18 to 35) <= (18 to 35 => hit3_en(3) );
   hit3_en2( 0 to 17) <= ( 0 to 17 => hit3_en(4) );
   hit3_en2(18 to 35) <= (18 to 35 => hit3_en(5) );
   hit3_en3( 0 to 17) <= ( 0 to 17 => hit3_en(6) );
   hit3_en3(18 to 35) <= (18 to 35 => hit3_en(7) );




   u_iu3_instr0_dx0: iu3_instr0_dx0_b(  0 to  35) <= not( hit0_en0(0 to 35) and iu2_data_dataout_0(  0 to  35) ) ;
   u_iu3_instr0_dx1: iu3_instr0_dx1_b(  0 to  35) <= not( hit1_en0(0 to 35) and iu2_data_dataout_1(  0 to  35) ) ;  
   u_iu3_instr0_dx2: iu3_instr0_dx2_b(  0 to  35) <= not( hit2_en0(0 to 35) and iu2_data_dataout_2(  0 to  35) ) ;  
   u_iu3_instr0_dx3: iu3_instr0_dx3_b(  0 to  35) <= not( hit3_en0(0 to 35) and iu2_data_dataout_3(  0 to  35) ) ;  

   u_iu3_instr1_dx0: iu3_instr1_dx0_b(  0 to  35) <= not( hit0_en1(0 to 35) and iu2_data_dataout_0( 36 to  71) ) ;
   u_iu3_instr1_dx1: iu3_instr1_dx1_b(  0 to  35) <= not( hit1_en1(0 to 35) and iu2_data_dataout_1( 36 to  71) ) ;  
   u_iu3_instr1_dx2: iu3_instr1_dx2_b(  0 to  35) <= not( hit2_en1(0 to 35) and iu2_data_dataout_2( 36 to  71) ) ;  
   u_iu3_instr1_dx3: iu3_instr1_dx3_b(  0 to  35) <= not( hit3_en1(0 to 35) and iu2_data_dataout_3( 36 to  71) ) ;  

   u_iu3_instr2_dx0: iu3_instr2_dx0_b(  0 to  35) <= not( hit0_en2(0 to 35) and iu2_data_dataout_0( 72 to 107) ) ;
   u_iu3_instr2_dx1: iu3_instr2_dx1_b(  0 to  35) <= not( hit1_en2(0 to 35) and iu2_data_dataout_1( 72 to 107) ) ;  
   u_iu3_instr2_dx2: iu3_instr2_dx2_b(  0 to  35) <= not( hit2_en2(0 to 35) and iu2_data_dataout_2( 72 to 107) ) ;  
   u_iu3_instr2_dx3: iu3_instr2_dx3_b(  0 to  35) <= not( hit3_en2(0 to 35) and iu2_data_dataout_3( 72 to 107) ) ;  

   u_iu3_instr3_dx0: iu3_instr3_dx0_b(  0 to  35) <= not( hit0_en3(0 to 35) and iu2_data_dataout_0(108 to 143) ) ;
   u_iu3_instr3_dx1: iu3_instr3_dx1_b(  0 to  35) <= not( hit1_en3(0 to 35) and iu2_data_dataout_1(108 to 143) ) ;  
   u_iu3_instr3_dx2: iu3_instr3_dx2_b(  0 to  35) <= not( hit2_en3(0 to 35) and iu2_data_dataout_2(108 to 143) ) ;  
   u_iu3_instr3_dx3: iu3_instr3_dx3_b(  0 to  35) <= not( hit3_en3(0 to 35) and iu2_data_dataout_3(108 to 143) ) ;  



   u_iu3_instr0_d1: iu3_instr0_d1(0 to 35) <= not( iu3_instr0_dx0_b(0 to 35) and iu3_instr0_dx1_b(0 to 35) and iu3_instr0_oth_b(0 to 35) );
   u_iu3_instr0_d2: iu3_instr0_d2(0 to 35) <= not( iu3_instr0_dx2_b(0 to 35) and iu3_instr0_dx3_b(0 to 35) );

   u_iu3_instr1_d1: iu3_instr1_d1(0 to 35) <= not( iu3_instr1_dx0_b(0 to 35) and iu3_instr1_dx1_b(0 to 35) and iu3_instr1_oth_b(0 to 35) );
   u_iu3_instr1_d2: iu3_instr1_d2(0 to 35) <= not( iu3_instr1_dx2_b(0 to 35) and iu3_instr1_dx3_b(0 to 35) );

   u_iu3_instr2_d1: iu3_instr2_d1(0 to 35) <= not( iu3_instr2_dx0_b(0 to 35) and iu3_instr2_dx1_b(0 to 35) and iu3_instr2_oth_b(0 to 35) );
   u_iu3_instr2_d2: iu3_instr2_d2(0 to 35) <= not( iu3_instr2_dx2_b(0 to 35) and iu3_instr2_dx3_b(0 to 35) );

   u_iu3_instr3_d1: iu3_instr3_d1(0 to 35) <= not( iu3_instr3_dx0_b(0 to 35) and iu3_instr3_dx1_b(0 to 35) and iu3_instr3_oth_b(0 to 35) );
   u_iu3_instr3_d2: iu3_instr3_d2(0 to 35) <= not( iu3_instr3_dx2_b(0 to 35) and iu3_instr3_dx3_b(0 to 35) );




   iu3_instr0_oth_b(0 to 35) <= not( 
         icm_icd_reload_data(  0 to  35) and (0 to 35=> load_iu2  )     );

   iu3_instr1_oth_b(0 to 35) <= not( 
         icm_icd_reload_data( 36 to  71) and (0 to 35=> load_iu2  )     );

   iu3_instr2_oth_b(0 to 35) <= not( 
         icm_icd_reload_data( 72 to 107) and (0 to 35=> load_iu2  )     );

   iu3_instr3_oth_b(0 to 35) <= not( 
         icm_icd_reload_data(108 to 143) and (0 to 35=> load_iu2  )     );




    iu3_instr0_lat: entity tri.tri_nor2_nlats   generic map (width => 36, btr=> "NLO0001_X2_A12TH", needs_sreset => 0, expand_type => expand_type) port map (
        VD             => vdd                              , 
        GD             => gnd                              ,
        LCLK           => inslat_lclk                      ,
        D1CLK          => inslat_d1clk                     ,
        D2CLK          => inslat_d2clk                     ,
        SCANIN         => iu3_instr0_si                    ,
        SCANOUT        => iu3_instr0_so                    ,
        A1             => iu3_instr0_d1  (0 to 35)         ,
        A2             => iu3_instr0_d2  (0 to 35)         ,
        QB             => iu3_instr0_l2_b(0 to 35)        );

    iu3_instr1_lat: entity tri.tri_nor2_nlats   generic map (width => 36, btr=> "NLO0001_X2_A12TH", needs_sreset => 0, expand_type => expand_type) port map (
        VD             => vdd                              , 
        GD             => gnd                              ,
        LCLK           => inslat_lclk                      ,
        D1CLK          => inslat_d1clk                     ,
        D2CLK          => inslat_d2clk                     ,
        SCANIN         => iu3_instr1_si                    ,
        SCANOUT        => iu3_instr1_so                    ,
        A1             => iu3_instr1_d1  (0 to 35)         ,
        A2             => iu3_instr1_d2  (0 to 35)         ,
        QB             => iu3_instr1_l2_b(0 to 35)        );

    iu3_instr2_lat: entity tri.tri_nor2_nlats   generic map (width => 36, btr=> "NLO0001_X2_A12TH", needs_sreset => 0, expand_type => expand_type) port map (
        VD             => vdd                              , 
        GD             => gnd                              ,
        LCLK           => inslat_lclk                      ,
        D1CLK          => inslat_d1clk                     ,
        D2CLK          => inslat_d2clk                     ,
        SCANIN         => iu3_instr2_si                    ,
        SCANOUT        => iu3_instr2_so                    ,
        A1             => iu3_instr2_d1  (0 to 35)         ,
        A2             => iu3_instr2_d2  (0 to 35)         ,
        QB             => iu3_instr2_l2_b(0 to 35)        );

    iu3_instr3_lat: entity tri.tri_nor2_nlats   generic map (width => 36, btr=> "NLO0001_X2_A12TH", needs_sreset => 0, expand_type => expand_type) port map (
        VD             => vdd                              , 
        GD             => gnd                              ,
        LCLK           => inslat_lclk                      ,
        D1CLK          => inslat_d1clk                     ,
        D2CLK          => inslat_d2clk                     ,
        SCANIN         => iu3_instr3_si                    ,
        SCANOUT        => iu3_instr3_so                    ,
        A1             => iu3_instr3_d1  (0 to 35)         ,
        A2             => iu3_instr3_d2  (0 to 35)         ,
        QB             => iu3_instr3_l2_b(0 to 35)        );


     u_iu3_instr0_inv: iu3_instr0_buf <= not( iu3_instr0_l2_b ); 
     u_iu3_instr1_inv: iu3_instr1_buf <= not( iu3_instr1_l2_b ); 
     u_iu3_instr2_inv: iu3_instr2_buf <= not( iu3_instr2_l2_b ); 
     u_iu3_instr3_inv: iu3_instr3_buf <= not( iu3_instr3_l2_b ); 




   iu3_instr0_si(0 to 35) <= scan_in                & iu3_instr0_so(0 to 34);
   iu3_instr1_si(0 to 35) <= iu3_instr1_so(1 to 35) & iu3_instr0_so(35);
   iu3_instr2_si(0 to 35) <= iu3_instr1_so(0)       & iu3_instr2_so(0 to 34) ;
   iu3_instr3_si(0 to 35) <= iu3_instr3_so(1 to 35) & iu3_instr2_so(35) ;
   scan_out               <= iu3_instr3_so(0) ;


    inslat_lcb : tri_lcbnd generic map (expand_type => expand_type) port map(
        nclk        =>  nclk                 ,
        vd          =>  vdd                  ,
        gd          =>  gnd                  ,
        act         =>  inslat_act           ,
        delay_lclkr =>  delay_lclkr          ,
        mpw1_b      =>  mpw1_b               ,
        mpw2_b      =>  mpw2_b               ,
        forcee => forcee,
        sg          =>  sg_0                 ,
        thold_b     =>  thold_0_b            ,
        d1clk       =>  inslat_d1clk         ,
        d2clk       =>  inslat_d2clk         ,
        lclk        =>  inslat_lclk         );

 


end; 

