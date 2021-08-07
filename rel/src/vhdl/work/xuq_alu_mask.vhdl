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

entity xuq_alu_mask is  generic(expand_type: integer := 2 );   port (
        mb              :in std_ulogic_vector(0 to 5); -- where the mask begins
        me_b            :in std_ulogic_vector(0 to 5); -- where the mask ends
        zm              :in std_ulogic;                -- set mask to all zeroes. ... not a rot/sh op ... all bits are shifted out
        mb_gt_me        :in std_ulogic;
        mask            :out std_ulogic_vector(0 to 63)  -- mask shows which rotator bits to keep in the result.
);

-- synopsys translate_off
-- synopsys translate_on
end xuq_alu_mask;

architecture xuq_alu_mask of xuq_alu_mask is
    constant tiup                       : std_ulogic := '1';
    constant tidn                       : std_ulogic := '0';

   signal mask_en_and, mask_en_mb, mask_en_me :std_ulogic ;
   signal mask0_b, mask1_b, mask2_b           :std_ulogic_vector(0 to 63);
   signal mb_mask, me_mask :std_ulogic_vector(0 to 63) ;

   signal mb_msk45, mb_msk45_b :std_ulogic_vector(0 to 2);
   signal mb_msk23, mb_msk23_b :std_ulogic_vector(0 to 2);
   signal mb_msk01, mb_msk01_b :std_ulogic_vector(0 to 2);
   signal mb_msk25, mb_msk25_b :std_ulogic_vector(0 to 14);
   signal mb_msk01bb, mb_msk01bbb :std_ulogic_vector(0 to 2);
   signal me_msk01, me_msk01_b :std_ulogic_vector( 1 to 3);
   signal me_msk23, me_msk23_b :std_ulogic_vector( 1 to 3);
   signal me_msk45, me_msk45_b :std_ulogic_vector( 1 to 3);
   signal me_msk25,    me_msk25_b :std_ulogic_vector(1 to 15);
   signal me_msk01bbb, me_msk01bb :std_ulogic_vector(1 to 3);


begin

   -- -----------------------------------------------------------------------------------------
   -- generate the MB mask
   -- -----------------------------------------------------------------------------------------
   --        0123
   --       ------
   --  00 => 1111  (ge)
   --  01 => 0111
   --  10 => 0011
   --  11 => 0001

              -- level 1 (4 bit results) ------------ <3 loads on input>

   u_mb_msk45_0: mb_msk45(0) <= not( mb(4) or   mb(5) );
   u_mb_msk45_1: mb_msk45(1) <= not( mb(4)            );
   u_mb_msk45_2: mb_msk45(2) <= not( mb(4) and  mb(5) );
   u_mb_msk23_0: mb_msk23(0) <= not( mb(2) or   mb(3) );
   u_mb_msk23_1: mb_msk23(1) <= not( mb(2)            );
   u_mb_msk23_2: mb_msk23(2) <= not( mb(2) and  mb(3) );
   u_mb_msk01_0: mb_msk01(0) <= not( mb(0) or   mb(1) );
   u_mb_msk01_1: mb_msk01(1) <= not( mb(0)            );
   u_mb_msk01_2: mb_msk01(2) <= not( mb(0) and  mb(1) );

   u_mb_msk45b0: mb_msk45_b(0) <= not( mb_msk45(0) );
   u_mb_msk45b1: mb_msk45_b(1) <= not( mb_msk45(1) );
   u_mb_msk45b2: mb_msk45_b(2) <= not( mb_msk45(2) );
   u_mb_msk23b0: mb_msk23_b(0) <= not( mb_msk23(0) ); -- 7 loads on output
   u_mb_msk23b1: mb_msk23_b(1) <= not( mb_msk23(1) );
   u_mb_msk23b2: mb_msk23_b(2) <= not( mb_msk23(2) );
   u_mb_msk01b0: mb_msk01_b(0) <= not( mb_msk01(0) );
   u_mb_msk01b1: mb_msk01_b(1) <= not( mb_msk01(1) );
   u_mb_msk01b2: mb_msk01_b(2) <= not( mb_msk01(2) );


              -- level 2 (16 bit results) -------------

   u_mb_msk25_0:  mb_msk25(0)  <= not(                     mb_msk23_b(0) or  mb_msk45_b(0)    );
   u_mb_msk25_1:  mb_msk25(1)  <= not(                     mb_msk23_b(0) or  mb_msk45_b(1)    );
   u_mb_msk25_2:  mb_msk25(2)  <= not(                     mb_msk23_b(0) or  mb_msk45_b(2)    );
   u_mb_msk25_3:  mb_msk25(3)  <= not( mb_msk23_b(0)                                          );
   u_mb_msk25_4:  mb_msk25(4)  <= not( mb_msk23_b(0) and ( mb_msk23_b(1) or  mb_msk45_b(0) )  );
   u_mb_msk25_5:  mb_msk25(5)  <= not( mb_msk23_b(0) and ( mb_msk23_b(1) or  mb_msk45_b(1) )  );
   u_mb_msk25_6:  mb_msk25(6)  <= not( mb_msk23_b(0) and ( mb_msk23_b(1) or  mb_msk45_b(2) )  );
   u_mb_msk25_7:  mb_msk25(7)  <= not( mb_msk23_b(1)                                          );
   u_mb_msk25_8:  mb_msk25(8)  <= not( mb_msk23_b(1) and ( mb_msk23_b(2) or  mb_msk45_b(0) )  );
   u_mb_msk25_9:  mb_msk25(9)  <= not( mb_msk23_b(1) and ( mb_msk23_b(2) or  mb_msk45_b(1) )  );
   u_mb_msk25_10: mb_msk25(10) <= not( mb_msk23_b(1) and ( mb_msk23_b(2) or  mb_msk45_b(2) )  );
   u_mb_msk25_11: mb_msk25(11) <= not( mb_msk23_b(2)                                          );
   u_mb_msk25_12: mb_msk25(12) <= not( mb_msk23_b(2) and                     mb_msk45_b(0)    );
   u_mb_msk25_13: mb_msk25(13) <= not( mb_msk23_b(2) and                     mb_msk45_b(1)    );
   u_mb_msk25_14: mb_msk25(14) <= not( mb_msk23_b(2) and                     mb_msk45_b(2)    );

   u_mb_msk01bb0: mb_msk01bb(0) <= not( mb_msk01_b(0) );
   u_mb_msk01bb1: mb_msk01bb(1) <= not( mb_msk01_b(1) );
   u_mb_msk01bb2: mb_msk01bb(2) <= not( mb_msk01_b(2) );


   u_mb_msk25b0:  mb_msk25_b(0)  <= not( mb_msk25(0)  );
   u_mb_msk25b1:  mb_msk25_b(1)  <= not( mb_msk25(1)  );
   u_mb_msk25b2:  mb_msk25_b(2)  <= not( mb_msk25(2)  );
   u_mb_msk25b3:  mb_msk25_b(3)  <= not( mb_msk25(3)  );
   u_mb_msk25b4:  mb_msk25_b(4)  <= not( mb_msk25(4)  );
   u_mb_msk25b5:  mb_msk25_b(5)  <= not( mb_msk25(5)  );
   u_mb_msk25b6:  mb_msk25_b(6)  <= not( mb_msk25(6)  );
   u_mb_msk25b7:  mb_msk25_b(7)  <= not( mb_msk25(7)  );
   u_mb_msk25b8:  mb_msk25_b(8)  <= not( mb_msk25(8)  );
   u_mb_msk25b9:  mb_msk25_b(9)  <= not( mb_msk25(9)  );
   u_mb_msk25b10: mb_msk25_b(10) <= not( mb_msk25(10) );
   u_mb_msk25b11: mb_msk25_b(11) <= not( mb_msk25(11) );
   u_mb_msk25b12: mb_msk25_b(12) <= not( mb_msk25(12) );
   u_mb_msk25b13: mb_msk25_b(13) <= not( mb_msk25(13) );
   u_mb_msk25b14: mb_msk25_b(14) <= not( mb_msk25(14) );

   u_mb_msk01bbb0: mb_msk01bbb(0) <= not( mb_msk01bb(0) );
   u_mb_msk01bbb1: mb_msk01bbb(1) <= not( mb_msk01bb(1) );
   u_mb_msk01bbb2: mb_msk01bbb(2) <= not( mb_msk01bb(2) );

              -- level 3 -------------------------------------------------------
   u_mb_mask_0:  mb_mask(0)  <= not(                      mb_msk01bbb(0) or  mb_msk25_b(0)    );
   u_mb_mask_1:  mb_mask(1)  <= not(                      mb_msk01bbb(0) or  mb_msk25_b(1)    );
   u_mb_mask_2:  mb_mask(2)  <= not(                      mb_msk01bbb(0) or  mb_msk25_b(2)    );
   u_mb_mask_3:  mb_mask(3)  <= not(                      mb_msk01bbb(0) or  mb_msk25_b(3)    );
   u_mb_mask_4:  mb_mask(4)  <= not(                      mb_msk01bbb(0) or  mb_msk25_b(4)    );
   u_mb_mask_5:  mb_mask(5)  <= not(                      mb_msk01bbb(0) or  mb_msk25_b(5)    );
   u_mb_mask_6:  mb_mask(6)  <= not(                      mb_msk01bbb(0) or  mb_msk25_b(6)    );
   u_mb_mask_7:  mb_mask(7)  <= not(                      mb_msk01bbb(0) or  mb_msk25_b(7)    );
   u_mb_mask_8:  mb_mask(8)  <= not(                      mb_msk01bbb(0) or  mb_msk25_b(8)    );
   u_mb_mask_9:  mb_mask(9)  <= not(                      mb_msk01bbb(0) or  mb_msk25_b(9)    );
   u_mb_mask_10: mb_mask(10) <= not(                      mb_msk01bbb(0) or  mb_msk25_b(10)   );
   u_mb_mask_11: mb_mask(11) <= not(                      mb_msk01bbb(0) or  mb_msk25_b(11)   );
   u_mb_mask_12: mb_mask(12) <= not(                      mb_msk01bbb(0) or  mb_msk25_b(12)   );
   u_mb_mask_13: mb_mask(13) <= not(                      mb_msk01bbb(0) or  mb_msk25_b(13)   );
   u_mb_mask_14: mb_mask(14) <= not(                      mb_msk01bbb(0) or  mb_msk25_b(14)   );
   u_mb_mask_15: mb_mask(15) <= not(                      mb_msk01bbb(0)                      );
   u_mb_mask_16: mb_mask(16) <= not( mb_msk01bbb(0) and ( mb_msk01bbb(1) or  mb_msk25_b(0) )  );
   u_mb_mask_17: mb_mask(17) <= not( mb_msk01bbb(0) and ( mb_msk01bbb(1) or  mb_msk25_b(1) )  );
   u_mb_mask_18: mb_mask(18) <= not( mb_msk01bbb(0) and ( mb_msk01bbb(1) or  mb_msk25_b(2) )  );
   u_mb_mask_19: mb_mask(19) <= not( mb_msk01bbb(0) and ( mb_msk01bbb(1) or  mb_msk25_b(3) )  );
   u_mb_mask_20: mb_mask(20) <= not( mb_msk01bbb(0) and ( mb_msk01bbb(1) or  mb_msk25_b(4) )  );
   u_mb_mask_21: mb_mask(21) <= not( mb_msk01bbb(0) and ( mb_msk01bbb(1) or  mb_msk25_b(5) )  );
   u_mb_mask_22: mb_mask(22) <= not( mb_msk01bbb(0) and ( mb_msk01bbb(1) or  mb_msk25_b(6) )  );
   u_mb_mask_23: mb_mask(23) <= not( mb_msk01bbb(0) and ( mb_msk01bbb(1) or  mb_msk25_b(7) )  );
   u_mb_mask_24: mb_mask(24) <= not( mb_msk01bbb(0) and ( mb_msk01bbb(1) or  mb_msk25_b(8) )  );
   u_mb_mask_25: mb_mask(25) <= not( mb_msk01bbb(0) and ( mb_msk01bbb(1) or  mb_msk25_b(9) )  );
   u_mb_mask_26: mb_mask(26) <= not( mb_msk01bbb(0) and ( mb_msk01bbb(1) or  mb_msk25_b(10))  );
   u_mb_mask_27: mb_mask(27) <= not( mb_msk01bbb(0) and ( mb_msk01bbb(1) or  mb_msk25_b(11))  );
   u_mb_mask_28: mb_mask(28) <= not( mb_msk01bbb(0) and ( mb_msk01bbb(1) or  mb_msk25_b(12))  );
   u_mb_mask_29: mb_mask(29) <= not( mb_msk01bbb(0) and ( mb_msk01bbb(1) or  mb_msk25_b(13))  );
   u_mb_mask_30: mb_mask(30) <= not( mb_msk01bbb(0) and ( mb_msk01bbb(1) or  mb_msk25_b(14))  );
   u_mb_mask_31: mb_mask(31) <= not(                      mb_msk01bbb(1)                      );
   u_mb_mask_32: mb_mask(32) <= not( mb_msk01bbb(1) and ( mb_msk01bbb(2) or  mb_msk25_b(0) )  );
   u_mb_mask_33: mb_mask(33) <= not( mb_msk01bbb(1) and ( mb_msk01bbb(2) or  mb_msk25_b(1) )  );
   u_mb_mask_34: mb_mask(34) <= not( mb_msk01bbb(1) and ( mb_msk01bbb(2) or  mb_msk25_b(2) )  );
   u_mb_mask_35: mb_mask(35) <= not( mb_msk01bbb(1) and ( mb_msk01bbb(2) or  mb_msk25_b(3) )  );
   u_mb_mask_36: mb_mask(36) <= not( mb_msk01bbb(1) and ( mb_msk01bbb(2) or  mb_msk25_b(4) )  );
   u_mb_mask_37: mb_mask(37) <= not( mb_msk01bbb(1) and ( mb_msk01bbb(2) or  mb_msk25_b(5) )  );
   u_mb_mask_38: mb_mask(38) <= not( mb_msk01bbb(1) and ( mb_msk01bbb(2) or  mb_msk25_b(6) )  );
   u_mb_mask_39: mb_mask(39) <= not( mb_msk01bbb(1) and ( mb_msk01bbb(2) or  mb_msk25_b(7) )  );
   u_mb_mask_40: mb_mask(40) <= not( mb_msk01bbb(1) and ( mb_msk01bbb(2) or  mb_msk25_b(8) )  );
   u_mb_mask_41: mb_mask(41) <= not( mb_msk01bbb(1) and ( mb_msk01bbb(2) or  mb_msk25_b(9) )  );
   u_mb_mask_42: mb_mask(42) <= not( mb_msk01bbb(1) and ( mb_msk01bbb(2) or  mb_msk25_b(10))  );
   u_mb_mask_43: mb_mask(43) <= not( mb_msk01bbb(1) and ( mb_msk01bbb(2) or  mb_msk25_b(11))  );
   u_mb_mask_44: mb_mask(44) <= not( mb_msk01bbb(1) and ( mb_msk01bbb(2) or  mb_msk25_b(12))  );
   u_mb_mask_45: mb_mask(45) <= not( mb_msk01bbb(1) and ( mb_msk01bbb(2) or  mb_msk25_b(13))  );
   u_mb_mask_46: mb_mask(46) <= not( mb_msk01bbb(1) and ( mb_msk01bbb(2) or  mb_msk25_b(14))  );
   u_mb_mask_47: mb_mask(47) <= not(                      mb_msk01bbb(2)                      );
   u_mb_mask_48: mb_mask(48) <= not( mb_msk01bbb(2) and                      mb_msk25_b(0)    );
   u_mb_mask_49: mb_mask(49) <= not( mb_msk01bbb(2) and                      mb_msk25_b(1)    );
   u_mb_mask_50: mb_mask(50) <= not( mb_msk01bbb(2) and                      mb_msk25_b(2)    );
   u_mb_mask_51: mb_mask(51) <= not( mb_msk01bbb(2) and                      mb_msk25_b(3)    );
   u_mb_mask_52: mb_mask(52) <= not( mb_msk01bbb(2) and                      mb_msk25_b(4)    );
   u_mb_mask_53: mb_mask(53) <= not( mb_msk01bbb(2) and                      mb_msk25_b(5)    );
   u_mb_mask_54: mb_mask(54) <= not( mb_msk01bbb(2) and                      mb_msk25_b(6)    );
   u_mb_mask_55: mb_mask(55) <= not( mb_msk01bbb(2) and                      mb_msk25_b(7)    );
   u_mb_mask_56: mb_mask(56) <= not( mb_msk01bbb(2) and                      mb_msk25_b(8)    );
   u_mb_mask_57: mb_mask(57) <= not( mb_msk01bbb(2) and                      mb_msk25_b(9)    );
   u_mb_mask_58: mb_mask(58) <= not( mb_msk01bbb(2) and                      mb_msk25_b(10)   );
   u_mb_mask_59: mb_mask(59) <= not( mb_msk01bbb(2) and                      mb_msk25_b(11)   );
   u_mb_mask_60: mb_mask(60) <= not( mb_msk01bbb(2) and                      mb_msk25_b(12)   );
   u_mb_mask_61: mb_mask(61) <= not( mb_msk01bbb(2) and                      mb_msk25_b(13)   );
   u_mb_mask_62: mb_mask(62) <= not( mb_msk01bbb(2) and                      mb_msk25_b(14)   );
                 mb_mask(63) <= tiup ;



   -- -----------------------------------------------------------------------------------------
   -- generate the ME mask
   -- -----------------------------------------------------------------------------------------

              -- level 1 (4 bit results) ------------ <3 loads on input>

   u_me_msk45_1: me_msk45(1) <= not( me_b(4) and  me_b(5) );
   u_me_msk45_2: me_msk45(2) <= not( me_b(4)              );
   u_me_msk45_3: me_msk45(3) <= not( me_b(4) or   me_b(5) );

   u_me_msk23_1: me_msk23(1) <= not( me_b(2) and  me_b(3) );
   u_me_msk23_2: me_msk23(2) <= not( me_b(2)              );
   u_me_msk23_3: me_msk23(3) <= not( me_b(2) or   me_b(3) );

   u_me_msk01_1: me_msk01(1) <= not( me_b(0) and  me_b(1) );
   u_me_msk01_2: me_msk01(2) <= not( me_b(0)              );
   u_me_msk01_3: me_msk01(3) <= not( me_b(0) or   me_b(1) );


   u_me_msk45b1: me_msk45_b(1) <= not( me_msk45(1) );
   u_me_msk45b2: me_msk45_b(2) <= not( me_msk45(2) );
   u_me_msk45b3: me_msk45_b(3) <= not( me_msk45(3) );
   u_me_msk23b1: me_msk23_b(1) <= not( me_msk23(1) ); -- 7 loads on output
   u_me_msk23b2: me_msk23_b(2) <= not( me_msk23(2) );
   u_me_msk23b3: me_msk23_b(3) <= not( me_msk23(3) );
   u_me_msk01b1: me_msk01_b(1) <= not( me_msk01(1) );
   u_me_msk01b2: me_msk01_b(2) <= not( me_msk01(2) );
   u_me_msk01b3: me_msk01_b(3) <= not( me_msk01(3) );


            -- level 2 (16 bit results) -------------


   u_me_msk25_1:  me_msk25(1)  <= not( me_msk23_b(1) and                     me_msk45_b(1)    ); -- amt >=  1    4:15 + 1:3
   u_me_msk25_2:  me_msk25(2)  <= not( me_msk23_b(1) and                     me_msk45_b(2)    ); -- amt >=  2    4:15 + 2:3
   u_me_msk25_3:  me_msk25(3)  <= not( me_msk23_b(1) and                     me_msk45_b(3)    ); -- amt >=  3    4:15 + 3:3
   u_me_msk25_4:  me_msk25(4)  <= not( me_msk23_b(1)                                          ); -- amt >=  4    4:15
   u_me_msk25_5:  me_msk25(5)  <= not( me_msk23_b(2) and ( me_msk23_b(1) or  me_msk45_b(1) )  ); -- amt >=  5    8:15 + (4:15 * 1:3)
   u_me_msk25_6:  me_msk25(6)  <= not( me_msk23_b(2) and ( me_msk23_b(1) or  me_msk45_b(2) )  ); -- amt >=  6    8:15 + (4:15 * 2:3)
   u_me_msk25_7:  me_msk25(7)  <= not( me_msk23_b(2) and ( me_msk23_b(1) or  me_msk45_b(3) )  ); -- amt >=  7    8:15 + (4:15 * 3:3)
   u_me_msk25_8:  me_msk25(8)  <= not( me_msk23_b(2)                                          ); -- amt >=  8    8:15
   u_me_msk25_9:  me_msk25(9)  <= not( me_msk23_b(3) and ( me_msk23_b(2) or  me_msk45_b(1) )  ); -- amt >=  9   12:15 + (8:15 * 1:3)
   u_me_msk25_10: me_msk25(10) <= not( me_msk23_b(3) and ( me_msk23_b(2) or  me_msk45_b(2) )  ); -- amt >= 10   12:15 + (8:15 * 2:3)
   u_me_msk25_11: me_msk25(11) <= not( me_msk23_b(3) and ( me_msk23_b(2) or  me_msk45_b(3) )  ); -- amt >= 11   12:15 + (8:15 * 3:3)
   u_me_msk25_12: me_msk25(12) <= not( me_msk23_b(3)                                          ); -- amt >= 12   12:15
   u_me_msk25_13: me_msk25(13) <= not(                     me_msk23_b(3) or  me_msk45_b(1)    ); -- amt >= 13   12:15 & 1:3
   u_me_msk25_14: me_msk25(14) <= not(                     me_msk23_b(3) or  me_msk45_b(2)    ); -- amt >= 14   12:15 & 2:3
   u_me_msk25_15: me_msk25(15) <= not(                     me_msk23_b(3) or  me_msk45_b(3)    ); -- amt >= 15   12:15 & 3:3

   u_me_msk01bb1: me_msk01bb(1) <= not( me_msk01_b(1) );
   u_me_msk01bb2: me_msk01bb(2) <= not( me_msk01_b(2) );
   u_me_msk01bb3: me_msk01bb(3) <= not( me_msk01_b(3) );


   u_me_msk25b1:  me_msk25_b(1)  <= not( me_msk25(1)  );
   u_me_msk25b2:  me_msk25_b(2)  <= not( me_msk25(2)  );
   u_me_msk25b3:  me_msk25_b(3)  <= not( me_msk25(3)  );
   u_me_msk25b4:  me_msk25_b(4)  <= not( me_msk25(4)  );
   u_me_msk25b5:  me_msk25_b(5)  <= not( me_msk25(5)  );
   u_me_msk25b6:  me_msk25_b(6)  <= not( me_msk25(6)  );
   u_me_msk25b7:  me_msk25_b(7)  <= not( me_msk25(7)  );
   u_me_msk25b8:  me_msk25_b(8)  <= not( me_msk25(8)  );
   u_me_msk25b9:  me_msk25_b(9)  <= not( me_msk25(9)  );
   u_me_msk25b10: me_msk25_b(10) <= not( me_msk25(10) );
   u_me_msk25b11: me_msk25_b(11) <= not( me_msk25(11) );
   u_me_msk25b12: me_msk25_b(12) <= not( me_msk25(12) );
   u_me_msk25b13: me_msk25_b(13) <= not( me_msk25(13) );
   u_me_msk25b14: me_msk25_b(14) <= not( me_msk25(14) );
   u_me_msk25b15: me_msk25_b(15) <= not( me_msk25(15) );

   u_me_msk01bbb1: me_msk01bbb(1) <= not( me_msk01bb(1) );
   u_me_msk01bbb2: me_msk01bbb(2) <= not( me_msk01bb(2) );
   u_me_msk01bbb3: me_msk01bbb(3) <= not( me_msk01bb(3) );


            -- level 3 (16 bit results) -------------

                 me_mask(0)  <= tiup ;
   u_me_mask_1:  me_mask(1)  <= not( me_msk01bbb(1) and                     me_msk25_b(1)     );
   u_me_mask_2:  me_mask(2)  <= not( me_msk01bbb(1) and                     me_msk25_b(2)     );
   u_me_mask_3:  me_mask(3)  <= not( me_msk01bbb(1) and                     me_msk25_b(3)     );
   u_me_mask_4:  me_mask(4)  <= not( me_msk01bbb(1) and                     me_msk25_b(4)     );
   u_me_mask_5:  me_mask(5)  <= not( me_msk01bbb(1) and                     me_msk25_b(5)     );
   u_me_mask_6:  me_mask(6)  <= not( me_msk01bbb(1) and                     me_msk25_b(6)     );
   u_me_mask_7:  me_mask(7)  <= not( me_msk01bbb(1) and                     me_msk25_b(7)     );
   u_me_mask_8:  me_mask(8)  <= not( me_msk01bbb(1) and                     me_msk25_b(8)     );
   u_me_mask_9:  me_mask(9)  <= not( me_msk01bbb(1) and                     me_msk25_b(9)     );
   u_me_mask_10: me_mask(10) <= not( me_msk01bbb(1) and                     me_msk25_b(10)    );
   u_me_mask_11: me_mask(11) <= not( me_msk01bbb(1) and                     me_msk25_b(11)    );
   u_me_mask_12: me_mask(12) <= not( me_msk01bbb(1) and                     me_msk25_b(12)    );
   u_me_mask_13: me_mask(13) <= not( me_msk01bbb(1) and                     me_msk25_b(13)    );
   u_me_mask_14: me_mask(14) <= not( me_msk01bbb(1) and                     me_msk25_b(14)    );
   u_me_mask_15: me_mask(15) <= not( me_msk01bbb(1) and                     me_msk25_b(15)    );
   u_me_mask_16: me_mask(16) <= not( me_msk01bbb(1)                                           );
   u_me_mask_17: me_mask(17) <= not( me_msk01bbb(2) and ( me_msk01bbb(1) or  me_msk25_b(1) )  );
   u_me_mask_18: me_mask(18) <= not( me_msk01bbb(2) and ( me_msk01bbb(1) or  me_msk25_b(2) )  );
   u_me_mask_19: me_mask(19) <= not( me_msk01bbb(2) and ( me_msk01bbb(1) or  me_msk25_b(3) )  );
   u_me_mask_20: me_mask(20) <= not( me_msk01bbb(2) and ( me_msk01bbb(1) or  me_msk25_b(4) )  );
   u_me_mask_21: me_mask(21) <= not( me_msk01bbb(2) and ( me_msk01bbb(1) or  me_msk25_b(5) )  );
   u_me_mask_22: me_mask(22) <= not( me_msk01bbb(2) and ( me_msk01bbb(1) or  me_msk25_b(6) )  );
   u_me_mask_23: me_mask(23) <= not( me_msk01bbb(2) and ( me_msk01bbb(1) or  me_msk25_b(7) )  );
   u_me_mask_24: me_mask(24) <= not( me_msk01bbb(2) and ( me_msk01bbb(1) or  me_msk25_b(8) )  );
   u_me_mask_25: me_mask(25) <= not( me_msk01bbb(2) and ( me_msk01bbb(1) or  me_msk25_b(9) )  );
   u_me_mask_26: me_mask(26) <= not( me_msk01bbb(2) and ( me_msk01bbb(1) or  me_msk25_b(10))  );
   u_me_mask_27: me_mask(27) <= not( me_msk01bbb(2) and ( me_msk01bbb(1) or  me_msk25_b(11))  );
   u_me_mask_28: me_mask(28) <= not( me_msk01bbb(2) and ( me_msk01bbb(1) or  me_msk25_b(12))  );
   u_me_mask_29: me_mask(29) <= not( me_msk01bbb(2) and ( me_msk01bbb(1) or  me_msk25_b(13))  );
   u_me_mask_30: me_mask(30) <= not( me_msk01bbb(2) and ( me_msk01bbb(1) or  me_msk25_b(14))  );
   u_me_mask_31: me_mask(31) <= not( me_msk01bbb(2) and ( me_msk01bbb(1) or  me_msk25_b(15))  );
   u_me_mask_32: me_mask(32) <= not( me_msk01bbb(2)                                           );
   u_me_mask_33: me_mask(33) <= not( me_msk01bbb(3) and ( me_msk01bbb(2) or  me_msk25_b(1) )  );
   u_me_mask_34: me_mask(34) <= not( me_msk01bbb(3) and ( me_msk01bbb(2) or  me_msk25_b(2) )  );
   u_me_mask_35: me_mask(35) <= not( me_msk01bbb(3) and ( me_msk01bbb(2) or  me_msk25_b(3) )  );
   u_me_mask_36: me_mask(36) <= not( me_msk01bbb(3) and ( me_msk01bbb(2) or  me_msk25_b(4) )  );
   u_me_mask_37: me_mask(37) <= not( me_msk01bbb(3) and ( me_msk01bbb(2) or  me_msk25_b(5) )  );
   u_me_mask_38: me_mask(38) <= not( me_msk01bbb(3) and ( me_msk01bbb(2) or  me_msk25_b(6) )  );
   u_me_mask_39: me_mask(39) <= not( me_msk01bbb(3) and ( me_msk01bbb(2) or  me_msk25_b(7) )  );
   u_me_mask_40: me_mask(40) <= not( me_msk01bbb(3) and ( me_msk01bbb(2) or  me_msk25_b(8) )  );
   u_me_mask_41: me_mask(41) <= not( me_msk01bbb(3) and ( me_msk01bbb(2) or  me_msk25_b(9) )  );
   u_me_mask_42: me_mask(42) <= not( me_msk01bbb(3) and ( me_msk01bbb(2) or  me_msk25_b(10))  );
   u_me_mask_43: me_mask(43) <= not( me_msk01bbb(3) and ( me_msk01bbb(2) or  me_msk25_b(11))  );
   u_me_mask_44: me_mask(44) <= not( me_msk01bbb(3) and ( me_msk01bbb(2) or  me_msk25_b(12))  );
   u_me_mask_45: me_mask(45) <= not( me_msk01bbb(3) and ( me_msk01bbb(2) or  me_msk25_b(13))  );
   u_me_mask_46: me_mask(46) <= not( me_msk01bbb(3) and ( me_msk01bbb(2) or  me_msk25_b(14))  );
   u_me_mask_47: me_mask(47) <= not( me_msk01bbb(3) and ( me_msk01bbb(2) or  me_msk25_b(15))  );
   u_me_mask_48: me_mask(48) <= not( me_msk01bbb(3)                                           );
   u_me_mask_49: me_mask(49) <= not(                     me_msk01bbb(3) or  me_msk25_b(1)     );
   u_me_mask_50: me_mask(50) <= not(                     me_msk01bbb(3) or  me_msk25_b(2)     );
   u_me_mask_51: me_mask(51) <= not(                     me_msk01bbb(3) or  me_msk25_b(3)     );
   u_me_mask_52: me_mask(52) <= not(                     me_msk01bbb(3) or  me_msk25_b(4)     );
   u_me_mask_53: me_mask(53) <= not(                     me_msk01bbb(3) or  me_msk25_b(5)     );
   u_me_mask_54: me_mask(54) <= not(                     me_msk01bbb(3) or  me_msk25_b(6)     );
   u_me_mask_55: me_mask(55) <= not(                     me_msk01bbb(3) or  me_msk25_b(7)     );
   u_me_mask_56: me_mask(56) <= not(                     me_msk01bbb(3) or  me_msk25_b(8)     );
   u_me_mask_57: me_mask(57) <= not(                     me_msk01bbb(3) or  me_msk25_b(9)     );
   u_me_mask_58: me_mask(58) <= not(                     me_msk01bbb(3) or  me_msk25_b(10)    );
   u_me_mask_59: me_mask(59) <= not(                     me_msk01bbb(3) or  me_msk25_b(11)    );
   u_me_mask_60: me_mask(60) <= not(                     me_msk01bbb(3) or  me_msk25_b(12)    );
   u_me_mask_61: me_mask(61) <= not(                     me_msk01bbb(3) or  me_msk25_b(13)    );
   u_me_mask_62: me_mask(62) <= not(                     me_msk01bbb(3) or  me_msk25_b(14)    );
   u_me_mask_63: me_mask(63) <= not(                     me_msk01bbb(3) or  me_msk25_b(15)    );


   -- ------------------------------------------------------------------------------------------
   -- Generally the mask starts at bit MB[] and ends at bit ME[] ... (MB[] and ME[])
   -- For non-rotate/shift operations the mask is forced to zero by the ZM control.
   -- There are 3 rotate-word operations where MB could be greater than ME.
   -- in that case the mask is speced to be  (MB[] or ME[]).
   -- For those cases, the mask always comes from the instruction bits, is always word mode,
   -- and the MB>ME compare can be done during the instruction decode cycle.
   -- -------------------------------------------------------------------------------------------

   mask_en_and <= not mb_gt_me and not zm ; -- could restrict this to only rotates if shifts included below
   mask_en_mb <=      mb_gt_me and not zm ; -- could alternatively include shift right
   mask_en_me <=      mb_gt_me and not zm ; -- could alternatively include shift left

   u_mask0: mask0_b(0 to 63) <= not( mb_mask(0 to 63) and me_mask(0 to 63) and (0 to 63=> mask_en_and) );
   u_mask1: mask1_b(0 to 63) <= not( mb_mask(0 to 63) and                      (0 to 63=> mask_en_mb)  );
   u_mask2: mask2_b(0 to 63) <= not(                      me_mask(0 to 63) and (0 to 63=> mask_en_me)  );

   u_mask: mask(0 to 63) <= not( mask0_b(0 to 63) and mask1_b(0 to 63) and mask2_b(0 to 63) );


end architecture xuq_alu_mask;
