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



library ieee,ibm,latches,clib, support;
use ieee.std_logic_1164.all;
use ibm.std_ulogic_support.all;
use ibm.std_ulogic_function_support.all;
use support.power_logic_pkg.all;

entity c_scom_addr_decode is
   generic( satid_nobits  : positive := 5        
          ; use_addr           : std_ulogic_vector := "1"
          ; addr_is_rdable     : std_ulogic_vector := "1"
          ; addr_is_wrable     : std_ulogic_vector := "1"
          );
   port( sc_addr     : in  std_ulogic_vector(0 to 11-satid_nobits-1) 
       ; scaddr_dec  : out std_ulogic_vector(0 to use_addr'length-1) 
       ; sc_req      : in  std_ulogic                                
       ; sc_r_nw     : in  std_ulogic                                
       ; scaddr_nvld : out std_ulogic                                
       ; sc_wr_nvld  : out std_ulogic                                
       ; sc_rd_nvld  : out std_ulogic                                
       ; vd : inout power_logic
       ; gd : inout power_logic
       );

end c_scom_addr_decode;



architecture c_scom_addr_decode of c_scom_addr_decode is
   signal address : std_ulogic_vector(0 to use_addr'length-1);
begin
   decode_it : for i in 0 to use_addr'length-1 generate
      address(i) <= ((sc_addr = tconv(i,sc_addr'length)) and (use_addr(i)='1'));
   end generate decode_it;

   scaddr_dec  <= address;
   scaddr_nvld <= sc_req and not or_reduce(address);
   sc_wr_nvld  <= not or_reduce(address and addr_is_wrable) and sc_req and not sc_r_nw;
   sc_rd_nvld  <= not or_reduce(address and addr_is_rdable) and sc_req and     sc_r_nw;
end c_scom_addr_decode;

