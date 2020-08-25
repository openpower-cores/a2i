-- © IBM Corp. 2020
-- This softcore is licensed under and subject to the terms of the CC-BY 4.0
-- license (https://creativecommons.org/licenses/by/4.0/legalcode). 
-- Additional rights, including the right to physically implement a softcore 
-- that is compliant with the required sections of the Power ISA 
-- Specification, will be available at no cost via the OpenPOWER Foundation. 
-- This README will be updated with additional information when OpenPOWER's 
-- license is available.

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
