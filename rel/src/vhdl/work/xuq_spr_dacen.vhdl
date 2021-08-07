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

--  Description:  XU SPR - DAC Enable Component
--

library ieee;
use ieee.std_logic_1164.all;

entity xuq_spr_dacen is
generic(
   threads                          :     integer := 4);
port(
   spr_msr_pr                       : in  std_ulogic_vector(0 to threads-1);
   spr_msr_ds                       : in  std_ulogic_vector(0 to threads-1);

   spr_dbcr0_dac                    : in  std_ulogic_vector(0 to 2*threads-1);
   spr_dbcr_dac_us                  : in  std_ulogic_vector(0 to 2*threads-1);
   spr_dbcr_dac_er                  : in  std_ulogic_vector(0 to 2*threads-1);
   
   val                              : in  std_ulogic_vector(0 to threads-1);
   load                             : in  std_ulogic;   
   store                            : in  std_ulogic;
   
   dacr_en                          : out std_ulogic_vector(0 to threads-1);
   dacw_en                          : out std_ulogic_vector(0 to threads-1)
);

--  synopsys translate_off
--  synopsys translate_on

end xuq_spr_dacen;
architecture xuq_spr_dacen of xuq_spr_dacen is

-- Signals
signal dac_ld_en,dac_st_en    : std_ulogic_vector(0 to threads-1);
signal dac_us_en,dac_er_en    : std_ulogic_vector(0 to threads-1);

begin

dacen_gen : for t in 0 to threads-1 generate

   dac_ld_en(t)   <=      spr_dbcr0_dac(0+2*t)   and  load;
   dac_st_en(t)   <=      spr_dbcr0_dac(1+2*t)   and  store;

   dac_us_en(t)   <= (not spr_dbcr_dac_us(0+2*t) and not spr_dbcr_dac_us(1+2*t)) or
                     (    spr_dbcr_dac_us(0+2*t) and    (spr_dbcr_dac_us(1+2*t) xnor spr_msr_pr(t)));

   dac_er_en(t)   <= (not spr_dbcr_dac_er(0+2*t) and not spr_dbcr_dac_er(1+2*t)) or
                     (    spr_dbcr_dac_er(0+2*t) and    (spr_dbcr_dac_er(1+2*t) xnor spr_msr_ds(t)));

   dacr_en(t)     <= val(t) and dac_ld_en(t) and dac_us_en(t) and dac_er_en(t);
   dacw_en(t)     <= val(t) and dac_st_en(t) and dac_us_en(t) and dac_er_en(t);

end generate;

end architecture xuq_spr_dacen;
