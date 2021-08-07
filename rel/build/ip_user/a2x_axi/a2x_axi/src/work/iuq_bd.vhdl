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



library ieee, ibm, support;

use ieee.std_logic_1164.all;
use ibm.std_ulogic_support.all;

entity iuq_bd is
port(
     instruction                : in  std_ulogic_vector(0 to 31);
     branch_decode              : out std_ulogic_vector(0 to 3);

     bp_bc_en                   : in  std_ulogic;
     bp_bclr_en                 : in  std_ulogic;
     bp_bcctr_en                : in  std_ulogic;
     bp_sw_en                   : in  std_ulogic
);

-- synopsys translate_off
-- synopsys translate_on
end iuq_bd;
architecture iuq_bd of iuq_bd is

signal b                        : std_ulogic;
signal bc                       : std_ulogic;
signal bclr                     : std_ulogic;
signal bcctr                    : std_ulogic;
signal br_val                   : std_ulogic;

signal bo                       : std_ulogic_vector(0 to 4);
signal hint                     : std_ulogic;
signal hint_val                 : std_ulogic;

signal unused_instruction       : std_ulogic_vector(0 to 10);

begin

unused_instruction <= instruction(11 to 20) & instruction(31);

b                               <=                 instruction(0 to 5) = "010010";
bc                              <= bp_bc_en    and instruction(0 to 5) = "010000";
bclr                            <= bp_bclr_en  and instruction(0 to 5) = "010011" and instruction(21 to 30) = "0000010000";
bcctr                           <= bp_bcctr_en and instruction(0 to 5) = "010011" and instruction(21 to 30) = "1000010000";

br_val                          <= b or bc or bclr or bcctr;

bo(0 to 4)                      <= instruction(6 to 10);


hint_val                        <= (bo(0) and bo(2)) or (bp_sw_en and ((bo(0) = '0' and bo(2) = '1' and bo(3) = '1') or
                                                                       (bo(0) = '1' and bo(2) = '0' and bo(1) = '1')));

hint                            <= (bo(0) and bo(2)) or bo(4);

branch_decode(0 to 3)           <= br_val & b & hint_val & hint;

end iuq_bd;
