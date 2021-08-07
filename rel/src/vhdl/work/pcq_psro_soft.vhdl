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

--
--  Description: Core PSRO Sensor
--
--*****************************************************************************

library ieee;
use ieee.std_logic_1164.all ;
library support;
use support.power_logic_pkg.all;
library tri;


entity pcq_psro_soft is
  port (
         vdd               : inout power_logic; -- Local Voltage Grid
         gnd               : inout power_logic; -- Local Gnd
         pcq_psro_enable   : in std_ulogic_vector(0 to 2); -- from perv
         psro_pcq_ringsig  : out std_ulogic -- to the PBus, these need to be triple buffered
       );

end pcq_psro_soft;


architecture pcq_psro_soft of pcq_psro_soft is
begin

  pcq_init: entity tri.tri_psro_soft
    port map
    ( vdd           => vdd                      ,
      gnd           => gnd                      ,
      psro_enable   => pcq_psro_enable(0 to 2)  ,
      psro_ringsig  => psro_pcq_ringsig         );

end pcq_psro_soft;
