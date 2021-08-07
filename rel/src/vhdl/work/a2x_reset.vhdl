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

library ieee;
use ieee.std_logic_1164.ALL;
use ieee.numeric_std.all;

-- both resets are negative-active!

entity a2x_reset is
  port (
        clk               : in  std_logic;
        reset_in          : in  std_logic;
        reset             : out std_logic
  );                       
end a2x_reset;              
                           
architecture a2x_reset of a2x_reset is
   constant reset_period   : integer := 32;
   signal reset_in_q : std_logic := '0';
   signal reset_q : std_logic := '0';
   signal counter_q : std_logic_vector(0 to 31) := x"00000000";

function inc(a: in std_logic_vector) return std_logic_vector is
  variable res: std_logic_vector(0 to a'length-1);
begin
  res := std_logic_vector(unsigned(a) + 1);
  return res;
end function;
function eq(a: in std_logic_vector; b: in integer) return boolean is
  variable res: boolean;
begin
  res := unsigned(a) = b;
  return res;
end function;
function leq(a: in std_logic_vector; b: in integer) return boolean is
  variable res: boolean;
begin
  res := unsigned(a) <= b;
  return res;
end function;

begin

   FF: process (clk) begin
  
   if (rising_edge(clk)) then
   
      reset_in_q <= reset_in;
      
      if (reset_in_q = '1' and reset_in = '0') then   -- edge-trigger hi->lo
         counter_q <= (others => '0');
	   elsif (leq(counter_q, reset_period)) then     -- reset period
         counter_q <= inc(counter_q);	
	      reset_q <= '0';
	   else                                            -- normal
         counter_q <= counter_q;	
	      reset_q <= '1';
	   end if;
   
   end if;
  
  end process;     
  
  reset <= reset_q;  

end architecture a2x_reset;
