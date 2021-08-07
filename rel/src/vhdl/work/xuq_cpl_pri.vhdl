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

--  Description:  Prioritizer
--
library ieee,ibm,support;
use ieee.std_logic_1164.all;
use ibm.std_ulogic_function_support.reverse;

entity xuq_cpl_pri is
generic(
   size                             :     integer range 3 to 32 := 32;  -- Size of "cond"
   rev                              :     integer range 0 to 1  := 0;   -- 0 = 0 is highest,   1 = 0 is lowest
   cmp_zero                         :     integer range 0 to 1  := 0);  -- 1 = include comparing cond to zero in pri vector
port(
   cond                             : in  std_ulogic_vector(0 to size-1);
   pri                              : out std_ulogic_vector(0 to size-1+cmp_zero);
   or_cond                          : out std_ulogic
);

-- synopsys translate_off
-- synopsys translate_on

end xuq_cpl_pri;
architecture xuq_cpl_pri of xuq_cpl_pri is

constant s                          : integer := size-1;
signal l0                           : std_ulogic_vector(0 to s);                    
signal or_l1,or_l2,or_l3,or_l4,or_l5: std_ulogic_vector(0 to s);


begin
   
rev_gen0   : if rev  = 0 generate
          l0(0 to s)    <= cond(0 to s);
end generate;
rev_gen1   : if rev  = 1 generate
          l0(0 to s)    <= reverse(cond(0 to s));
end generate;  

-- Odd Numbered Levels are inverted

l1_not:  or_l1(0)       <= not   l0(0);
l1_nor:  or_l1(1 to s)  <=       l0(0 to s-1) nor     l0(1 to s);


or_l2_gen0 : if s >= 2 generate
         or_l2(0 to 1)  <= not or_l1(0 to 1);
         or_l2(2 to s)  <=     or_l1(2 to s)  nand or_l1(0 to s-2);
end generate;
or_l2_gen1 : if s <  2 generate
         or_l2          <= not or_l1;
end generate;

or_l3_gen0 : if s >= 4 generate
         or_l3(0 to 3)  <= not or_l2(0 to 3);
         or_l3(4 to s)  <=     or_l2(4 to s)  nor  or_l2(0 to s-4);
end generate;
or_l3_gen1 : if s <  4 generate
         or_l3          <= not or_l2;
end generate;

or_l4_gen0 : if s >= 8 generate
         or_l4(0 to 7)  <= not or_l3(0 to 7);
         or_l4(8 to s)  <=     or_l3(8 to s)  nand or_l3(0 to s-8);
end generate;
or_l4_gen1 : if s <  8 generate
         or_l4          <= not or_l3;
end generate;

or_l5_gen0 : if s >= 16 generate
         or_l5(0 to 15) <= not or_l4(0 to 15);
         or_l5(16 to s) <=     or_l4(16 to s) nor  or_l4(0 to s-16);
end generate;
or_l5_gen1 : if s <  16 generate
         or_l5          <= not or_l4;
end generate;


pri(0)      <= cond(0);
pri(1 to s) <= cond(1 to s) and or_l5(0 to s-1);

cmp_zero_gen : if cmp_zero = 1 generate
pri(s+1)    <= or_l5(s);
end generate;

or_cond     <= not or_l5(s);



end architecture xuq_cpl_pri;
