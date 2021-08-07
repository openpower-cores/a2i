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

library ieee,ibm;
use ieee.std_logic_1164.all;
use ibm.std_ulogic_function_support.all;

library tri;
use tri.tri_latches_pkg.all;
entity xuq_spr_dvccmp is
generic(
   regsize                          :     integer := 64);
port(
   en                               : in  std_ulogic;
   en00                             : in  std_ulogic := '1';
   cmp                              : in  std_ulogic_vector(8-regsize/8 to 7);
   dvcm                             : in  std_ulogic_vector(0 to 1);
   dvcbe                            : in  std_ulogic_vector(8-regsize/8 to 7);   
   dvc_cmpr                         : out std_ulogic
);


--  synopsys translate_off
--  synopsys translate_on
end xuq_spr_dvccmp;
architecture xuq_spr_dvccmp of xuq_spr_dvccmp is

signal cmp_mask_or,cmp_mask_and     : std_ulogic_vector(8-regsize/8 to 7);
signal cmp_and,cmp_or,cmp_andor     : std_ulogic;

begin

   cmp_mask_or          <= gate((cmp or not dvcbe),or_reduce(dvcbe));
   cmp_mask_and         <=      (cmp and    dvcbe);

   cmp_and              <= and_reduce(cmp_mask_or);

   cmp_or               <=  or_reduce(cmp_mask_and);
   
   cmp_andor_gen32 : if regsize = 32 generate
   cmp_andor            <= (and_reduce(cmp_mask_or(4 to 5)) and or_reduce(dvcbe(4 to 5))) or
                           (and_reduce(cmp_mask_or(6 to 7)) and or_reduce(dvcbe(6 to 7)));
   end generate;
   cmp_andor_gen64 : if regsize = 64 generate
   cmp_andor            <= (and_reduce(cmp_mask_or(0 to 1)) and or_reduce(dvcbe(0 to 1))) or
                           (and_reduce(cmp_mask_or(2 to 3)) and or_reduce(dvcbe(2 to 3))) or
                           (and_reduce(cmp_mask_or(4 to 5)) and or_reduce(dvcbe(4 to 5))) or
                           (and_reduce(cmp_mask_or(6 to 7)) and or_reduce(dvcbe(6 to 7)));
   end generate;

   with dvcm(0 to 1) select
      dvc_cmpr          <= en and en00             when "00",
                           en and cmp_and          when "01",
                           en and cmp_or           when "10",
                           en and cmp_andor        when others;

end architecture xuq_spr_dvccmp;
