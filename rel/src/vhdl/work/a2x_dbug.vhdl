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

-- a2x dbug junk
--
-- 1. passthru threadstop and modify with trig if enabled
-- 2. enable trigger ack
-- 3. counter for stuff
-- 4. scom
--
-- others: debug stop

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.all;
use work.a2x_pkg.all;

entity a2x_dbug is
	port (
	   clk                        : in  std_logic; 
      reset_n                    : in  std_logic;
      
      threadstop_in              : in  std_logic_vector(0 to 3);

      trigger_in                 : in  std_logic;
      trigger_threadstop         : in  std_logic_vector(0 to 3);
      trigger_ack_enable         : in  std_logic;
      
      trigger_out                : out std_logic;
      trigger_ack_out            : out std_logic;
      threadstop_out             : out std_logic_vector(0 to 3);
      
      req_valid                  : in  std_logic; 
      req_id                     : in  std_logic_vector(0 to 3);
      req_addr                   : in  std_logic_vector(0 to 5);
      req_rw                     : in  std_logic; 
      req_wr_data                : in  std_logic_vector(0 to 63);
      
      rsp_valid                  : out std_logic;
      rsp_data                   : out std_logic_vector(0 to 63);
      
      dch_in                     : in  std_logic; 
      cch_in                     : in  std_logic; 
      dch_out                    : out std_logic;
      cch_out                    : out std_logic;  

      err                        : out std_logic
	);
	
end a2x_dbug;

architecture a2x_dbug of a2x_dbug is

-- FFs
signal counter_d, counter_q            : std_logic_vector(0 to 39);
signal trigger_ack_d, trigger_ack_q    : std_logic;
	
begin
                   
FF: process(clk) begin
	
if rising_edge(clk) then
	
   if reset_n = '0' then 
	   
      counter_q <= (others => '0');    
      trigger_ack_q <= '0';                                 
	                	              
	else
	    
      counter_q <= counter_d;    	   
      trigger_ack_q <= trigger_ack_d;
	      
   end if;
	
end if;
	
end process FF;



------------------------------------------------------------------------------------------------------------
-- counter
------------------------------------------------------------------------------------------------------------

counter_d <= inc(counter_q);

------------------------------------------------------------------------------------------------------------
-- threadstop
------------------------------------------------------------------------------------------------------------

threadstop_out <= threadstop_in or gate_and(trigger_in, trigger_threadstop);

------------------------------------------------------------------------------------------------------------
-- ILA
------------------------------------------------------------------------------------------------------------

trigger_out <= trigger_in;

-- acks until it goes away; or could do a pulse
trigger_ack_d   <= trigger_ack_enable and trigger_in;
trigger_ack_out <= trigger_ack_q;

------------------------------------------------------------------------------------------------------------
-- SCOM
------------------------------------------------------------------------------------------------------------

scom: entity work.a2x_scom(a2x_scom) 
   port map (
	   clk                        => clk,
      reset_n                    => reset_n,

      req_valid                  => req_valid,
      req_id                     => req_id,
      req_addr                   => req_addr,
      req_rw                     => req_rw,
      req_wr_data                => req_wr_data,
      
      rsp_valid                  => rsp_valid,
      rsp_data                   => rsp_data,
      
      dch_in                     => dch_in,
      cch_in                     => cch_in,
      dch_out                    => dch_out,
      cch_out                    => cch_out,     

      err                        => err
   ); 
   
end a2x_dbug;
