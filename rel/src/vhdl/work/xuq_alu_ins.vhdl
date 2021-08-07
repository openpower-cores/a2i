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
                    use ieee.numeric_std.all;
LIBRARY ibm;        
                    use ibm.std_ulogic_support.all;
                    use ibm.std_ulogic_function_support.all;
LIBRARY support;    
                    use support.power_logic_pkg.all;
library tri;
use tri.tri_latches_pkg.all;

entity xuq_alu_ins is  generic(expand_type: integer := 2 );   port (

        ins_log_fcn     :in  std_ulogic_vector(0 to 3) ; -- use pass ra for rlwimi
                                                         -- rs, ra/rb
                                                         -- 0000 => "0"
                                                         -- 0001 => rs AND  rb
                                                         -- 0010 => rs AND !rb
                                                         -- 0011 => rs
                                                         -- 0100 => !rs and RB
                                                         -- 0101 =>         RB
                                                         -- 0110 => rs xor  RB
                                                         -- 0111 => rs or   RB
                                                         -- 1000 => rs nor  RB
                                                         -- 1001 => rs xnor RB (use for cmp-byt)
                                                         -- 1010 =>        !RB
                                                         -- 1011 => rs or  !rb
                                                         -- 1100 => !rs
                                                         -- 1101 => rs nand !rb, !rs or rb
                                                         -- 1110 => rs nand rb   ...
                                                         -- 1111 => "1"

        ins_cmp_byt     :in  std_ulogic ;
        ins_sra_wd          :in  std_ulogic ;
        ins_sra_dw          :in  std_ulogic ;

        ins_xtd_byte    :in  std_ulogic ;-- use with xtd
        ins_xtd_half    :in  std_ulogic ;-- use with xtd
        ins_xtd_wd      :in  std_ulogic ;-- use with xtd, sra


        data0_i         :in  std_ulogic_vector(0 to 63) ;--data input (rs)
        data1_i         :in  std_ulogic_vector(0 to 63) ;--data input (ra|rb)
        mrg_byp_log     :out std_ulogic_vector(0 to 63) ;
        res_ins         :out std_ulogic_vector(0 to 63)  --insert data (also result of logicals)
);

-- synopsys translate_off
-- synopsys translate_on
end xuq_alu_ins;

architecture xuq_alu_ins of xuq_alu_ins is
    constant tiup                       : std_ulogic := '1';
    constant tidn                       : std_ulogic := '0';

    signal                         mrg_byp_log_b       :std_ulogic_vector(0 to 63);

    signal res_log            :std_ulogic_vector(0 to 63);
    signal byt_cmp, byt_cmp_b :std_ulogic_vector(0 to 7);
    signal byt_cmp_bus, sign_xtd_bus :std_ulogic_vector(0 to 63);
    signal xtd_byte_bus, xtd_half_bus, xtd_wd_bus, sra_dw_bus, sra_wd_bus  :std_ulogic_vector(0 to 63);
    signal res_ins0_b, res_ins1_b, res_ins2_b :std_ulogic_vector(0 to 63);
    signal res_log0_b, res_log1_b, res_log2_b, res_log3_b :std_ulogic_vector(0 to 63);
    signal res_log_o0, res_log_o1, res_log_b  :std_ulogic_vector(0 to 63);
  signal byt0_cmp2_b :std_ulogic_vector(0 to 3) ;
  signal byt1_cmp2_b :std_ulogic_vector(0 to 3) ;
  signal byt2_cmp2_b :std_ulogic_vector(0 to 3) ;
  signal byt3_cmp2_b :std_ulogic_vector(0 to 3) ;
  signal byt4_cmp2_b :std_ulogic_vector(0 to 3) ;
  signal byt5_cmp2_b :std_ulogic_vector(0 to 3) ;
  signal byt6_cmp2_b :std_ulogic_vector(0 to 3) ;
  signal byt7_cmp2_b :std_ulogic_vector(0 to 3) ;

  signal byt0_cmp4 :std_ulogic_vector(0 to 1) ;
  signal byt1_cmp4 :std_ulogic_vector(0 to 1) ;
  signal byt2_cmp4 :std_ulogic_vector(0 to 1) ;
  signal byt3_cmp4 :std_ulogic_vector(0 to 1) ;
  signal byt4_cmp4 :std_ulogic_vector(0 to 1) ;
  signal byt5_cmp4 :std_ulogic_vector(0 to 1) ;
  signal byt6_cmp4 :std_ulogic_vector(0 to 1) ;
  signal byt7_cmp4 :std_ulogic_vector(0 to 1) ;
  
  signal sel_cmp_byt,sel_cmp_byt_b  : std_ulogic_vector(0 to 63);
  
  signal data0_b, data1_b           : std_ulogic_vector(0 to 63); 
  signal data0,   data1             : std_ulogic_vector(0 to 63);


begin

  u_log_s0i:   data0_b              <= not data0_i;
  u_log_s1i:   data1_b              <= not data1_i;
  u_log_s0:    data0                <= not data0_b;
  u_log_s1:    data1                <= not data1_b;

  u_reslog0:   res_log0_b(0 to 63) <= not( (0 to 63=> ins_log_fcn(0)) and  data0_b(0 to 63) and data1_b(0 to 63) );
  u_reslog1:   res_log1_b(0 to 63) <= not( (0 to 63=> ins_log_fcn(1)) and  data0_b(0 to 63) and data1(0 to 63)   );
  u_reslog2:   res_log2_b(0 to 63) <= not( (0 to 63=> ins_log_fcn(2)) and  data0(0 to 63)   and data1_b(0 to 63) );
  u_reslog3:   res_log3_b(0 to 63) <= not( (0 to 63=> ins_log_fcn(3)) and  data0(0 to 63)   and data1(0 to 63)   );
  u_reslog_o0: res_log_o0(0 to 63) <= not( res_log0_b(0 to 63) and res_log1_b(0 to 63) );
  u_reslog_o1: res_log_o1(0 to 63) <= not( res_log2_b(0 to 63) and res_log3_b(0 to 63) );
  u_reslogb:   res_log_b (0 to 63) <= not( res_log_o0(0 to 63) or res_log_o1(0 to 63) );
  u_reslog:    res_log   (0 to 63) <= not( res_log_b(0 to 63) );

  u_mrg_byp_log_b: mrg_byp_log_b(0 to 63) <= not( res_log      (0 to 63) );
  u_mrg_byp_log:   mrg_byp_log  (0 to 63) <= not( mrg_byp_log_b(0 to 63) );

  u_byt0cmp2_0: byt0_cmp2_b(0)  <= not( res_log(0)  and res_log(1)  );
  u_byt0cmp2_1: byt0_cmp2_b(1)  <= not( res_log(2)  and res_log(3)  );
  u_byt0cmp2_2: byt0_cmp2_b(2)  <= not( res_log(4)  and res_log(5)  );
  u_byt0cmp2_3: byt0_cmp2_b(3)  <= not( res_log(6)  and res_log(7)  );
  u_byt1cmp2_0: byt1_cmp2_b(0)  <= not( res_log(8)  and res_log(9)  );
  u_byt1cmp2_1: byt1_cmp2_b(1)  <= not( res_log(10) and res_log(11) );
  u_byt1cmp2_2: byt1_cmp2_b(2)  <= not( res_log(12) and res_log(13) );
  u_byt1cmp2_3: byt1_cmp2_b(3)  <= not( res_log(14) and res_log(15) );
  u_byt2cmp2_0: byt2_cmp2_b(0)  <= not( res_log(16) and res_log(17) );
  u_byt2cmp2_1: byt2_cmp2_b(1)  <= not( res_log(18) and res_log(19) );
  u_byt2cmp2_2: byt2_cmp2_b(2)  <= not( res_log(20) and res_log(21) );
  u_byt2cmp2_3: byt2_cmp2_b(3)  <= not( res_log(22) and res_log(23) );
  u_byt3cmp2_0: byt3_cmp2_b(0)  <= not( res_log(24) and res_log(25) );
  u_byt3cmp2_1: byt3_cmp2_b(1)  <= not( res_log(26) and res_log(27) );
  u_byt3cmp2_2: byt3_cmp2_b(2)  <= not( res_log(28) and res_log(29) );
  u_byt3cmp2_3: byt3_cmp2_b(3)  <= not( res_log(30) and res_log(31) );
  u_byt4cmp2_0: byt4_cmp2_b(0)  <= not( res_log(32) and res_log(33) );
  u_byt4cmp2_1: byt4_cmp2_b(1)  <= not( res_log(34) and res_log(35) );
  u_byt4cmp2_2: byt4_cmp2_b(2)  <= not( res_log(36) and res_log(37) );
  u_byt4cmp2_3: byt4_cmp2_b(3)  <= not( res_log(38) and res_log(39) );
  u_byt5cmp2_0: byt5_cmp2_b(0)  <= not( res_log(40) and res_log(41) );
  u_byt5cmp2_1: byt5_cmp2_b(1)  <= not( res_log(42) and res_log(43) );
  u_byt5cmp2_2: byt5_cmp2_b(2)  <= not( res_log(44) and res_log(45) );
  u_byt5cmp2_3: byt5_cmp2_b(3)  <= not( res_log(46) and res_log(47) );
  u_byt6cmp2_0: byt6_cmp2_b(0)  <= not( res_log(48) and res_log(49) );
  u_byt6cmp2_1: byt6_cmp2_b(1)  <= not( res_log(50) and res_log(51) );
  u_byt6cmp2_2: byt6_cmp2_b(2)  <= not( res_log(52) and res_log(53) );
  u_byt6cmp2_3: byt6_cmp2_b(3)  <= not( res_log(54) and res_log(55) );
  u_byt7cmp2_0: byt7_cmp2_b(0)  <= not( res_log(56) and res_log(57) );
  u_byt7cmp2_1: byt7_cmp2_b(1)  <= not( res_log(58) and res_log(59) );
  u_byt7cmp2_2: byt7_cmp2_b(2)  <= not( res_log(60) and res_log(61) );
  u_byt7cmp2_3: byt7_cmp2_b(3)  <= not( res_log(62) and res_log(63) );


  u_byt0cmp4_0: byt0_cmp4(0) <= not( byt0_cmp2_b(0) or byt0_cmp2_b(1) );
  u_byt0cmp4_1: byt0_cmp4(1) <= not( byt0_cmp2_b(2) or byt0_cmp2_b(3) );
  u_byt1cmp4_0: byt1_cmp4(0) <= not( byt1_cmp2_b(0) or byt1_cmp2_b(1) );
  u_byt1cmp4_1: byt1_cmp4(1) <= not( byt1_cmp2_b(2) or byt1_cmp2_b(3) );
  u_byt2cmp4_0: byt2_cmp4(0) <= not( byt2_cmp2_b(0) or byt2_cmp2_b(1) );
  u_byt2cmp4_1: byt2_cmp4(1) <= not( byt2_cmp2_b(2) or byt2_cmp2_b(3) );
  u_byt3cmp4_0: byt3_cmp4(0) <= not( byt3_cmp2_b(0) or byt3_cmp2_b(1) );
  u_byt3cmp4_1: byt3_cmp4(1) <= not( byt3_cmp2_b(2) or byt3_cmp2_b(3) );
  u_byt4cmp4_0: byt4_cmp4(0) <= not( byt4_cmp2_b(0) or byt4_cmp2_b(1) );
  u_byt4cmp4_1: byt4_cmp4(1) <= not( byt4_cmp2_b(2) or byt4_cmp2_b(3) );
  u_byt5cmp4_0: byt5_cmp4(0) <= not( byt5_cmp2_b(0) or byt5_cmp2_b(1) );
  u_byt5cmp4_1: byt5_cmp4(1) <= not( byt5_cmp2_b(2) or byt5_cmp2_b(3) );
  u_byt6cmp4_0: byt6_cmp4(0) <= not( byt6_cmp2_b(0) or byt6_cmp2_b(1) );
  u_byt6cmp4_1: byt6_cmp4(1) <= not( byt6_cmp2_b(2) or byt6_cmp2_b(3) );
  u_byt7cmp4_0: byt7_cmp4(0) <= not( byt7_cmp2_b(0) or byt7_cmp2_b(1) );
  u_byt7cmp4_1: byt7_cmp4(1) <= not( byt7_cmp2_b(2) or byt7_cmp2_b(3) );

  u_byt0cmp8b:  byt_cmp_b(0) <= not( byt0_cmp4(0) and byt0_cmp4(1) );
  u_byt1cmp8b:  byt_cmp_b(1) <= not( byt1_cmp4(0) and byt1_cmp4(1) );
  u_byt2cmp8b:  byt_cmp_b(2) <= not( byt2_cmp4(0) and byt2_cmp4(1) );
  u_byt3cmp8b:  byt_cmp_b(3) <= not( byt3_cmp4(0) and byt3_cmp4(1) );
  u_byt4cmp8b:  byt_cmp_b(4) <= not( byt4_cmp4(0) and byt4_cmp4(1) );
  u_byt5cmp8b:  byt_cmp_b(5) <= not( byt5_cmp4(0) and byt5_cmp4(1) );
  u_byt6cmp8b:  byt_cmp_b(6) <= not( byt6_cmp4(0) and byt6_cmp4(1) );
  u_byt7cmp8b:  byt_cmp_b(7) <= not( byt7_cmp4(0) and byt7_cmp4(1) );


  u_byt0cmp8:  byt_cmp(0) <= not( byt_cmp_b(0) );
  u_byt1cmp8:  byt_cmp(1) <= not( byt_cmp_b(1) );
  u_byt2cmp8:  byt_cmp(2) <= not( byt_cmp_b(2) );
  u_byt3cmp8:  byt_cmp(3) <= not( byt_cmp_b(3) );
  u_byt4cmp8:  byt_cmp(4) <= not( byt_cmp_b(4) );
  u_byt5cmp8:  byt_cmp(5) <= not( byt_cmp_b(5) );
  u_byt6cmp8:  byt_cmp(6) <= not( byt_cmp_b(6) );
  u_byt7cmp8:  byt_cmp(7) <= not( byt_cmp_b(7) );


  byt_cmp_bus( 0 to  7) <= ( 0 to  7=> byt_cmp(0) );
  byt_cmp_bus( 8 to 15) <= ( 8 to 15=> byt_cmp(1) );
  byt_cmp_bus(16 to 23) <= (16 to 23=> byt_cmp(2) );
  byt_cmp_bus(24 to 31) <= (24 to 31=> byt_cmp(3) );
  byt_cmp_bus(32 to 39) <= (32 to 39=> byt_cmp(4) );
  byt_cmp_bus(40 to 47) <= (40 to 47=> byt_cmp(5) );
  byt_cmp_bus(48 to 55) <= (48 to 55=> byt_cmp(6) );
  byt_cmp_bus(56 to 63) <= (56 to 63=> byt_cmp(7) );



  xtd_byte_bus(0 to 63) <= (0 to 56 => data0(56) ) & data0(57 to 63) ;
  xtd_half_bus(0 to 63) <= (0 to 48 => data0(48) ) & data0(49 to 63) ;
  xtd_wd_bus  (0 to 63) <= (0 to 32 => data0(32) ) & data0(33 to 63) ;
  sra_wd_bus  (0 to 63) <= (0 to 63 => data0(32) );  -- all the bits for sra
  sra_dw_bus  (0 to 63) <= (0 to 63 => data0(0)  );  -- all the bits for sra


  sign_xtd_bus(0 to 63) <=
     ( (0 to 63=> ins_xtd_byte) and xtd_byte_bus(0 to 63) ) or
     ( (0 to 63=> ins_xtd_half) and xtd_half_bus(0 to 63) ) or
     ( (0 to 63=> ins_xtd_wd  ) and xtd_wd_bus  (0 to 63) ) or
     ( (0 to 63=> ins_sra_wd  ) and sra_wd_bus  (0 to 63) ) or
     ( (0 to 63=> ins_sra_dw  ) and sra_dw_bus  (0 to 63) ) ;

  sel_cmp_byt     <= (0 to 63=> ins_cmp_byt);
  sel_cmp_byt_b   <= (0 to 63=> not(ins_cmp_byt));

  u_res_ins0: res_ins0_b(0 to 63) <= not( sel_cmp_byt          and byt_cmp_bus(0 to 63)  );
  u_res_ins1: res_ins1_b(0 to 63) <= not( sel_cmp_byt_b        and res_log(0 to 63)      );
  u_res_ins2: res_ins2_b(0 to 63) <= not(                          sign_xtd_bus(0 to 63) );
  
  u_res_ins : res_ins   (0 to 63) <= not( res_ins0_b(0 to 63) and res_ins1_b(0 to 63) and res_ins2_b(0 to 63) );--output--


end architecture xuq_alu_ins;
