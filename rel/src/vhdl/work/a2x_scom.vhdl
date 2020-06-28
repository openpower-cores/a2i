-- © IBM Corp. 2020
-- This softcore is licensed under and subject to the terms of the CC-BY 4.0
-- license (https://creativecommons.org/licenses/by/4.0/legalcode). 
-- Additional rights, including the right to physically implement a softcore 
-- that is compliant with the required sections of the Power ISA 
-- Specification, will be available at no cost via the OpenPOWER Foundation. 
-- This README will be updated with additional information when OpenPOWER's 
-- license is available.


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.all;
use work.a2x_pkg.all;

entity a2x_scom is
	port (
	   clk                        : in  std_logic; 
      reset_n                    : in  std_logic;

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
end a2x_scom;

architecture a2x_scom of a2x_scom is


	
signal scom_seq_d, scom_seq_q     : std_logic_vector(0 to 3);

signal req_v_d, req_v_q           : std_logic;
signal req_sat_d, req_sat_q       : std_logic_vector(0 to 3);
signal req_addr_d, req_addr_q     : std_logic_vector(0 to 5);
signal req_rw_d, req_rw_q         : std_logic;
signal req_wr_data_d, req_wr_data_q : std_logic_vector(0 to 63);

signal rsp_v_d, rsp_v_q           : std_logic;
signal rsp_data_d, rsp_data_q     : std_logic;

signal cch_in_d, cch_in_q         : std_logic_vector(0 to 1);
signal cch_out_d, cch_out_q       : std_logic;
signal dch_in_d, dch_in_q         : std_logic;
signal dch_out_d, dch_out_q       : std_logic; 	
signal scom_err_d, scom_err_q     : std_logic; 	
   
signal cch_start                  : std_logic; 	
signal cch_end                    : std_logic; 	
signal scom_reset                 : std_logic; 	
signal scom_seq_err               : std_logic; 	

begin

                   
FF: process(clk) begin
	
if rising_edge(clk) then
	
   if reset_n = '0' then 
	   
      cch_in_q <= (others => '0');
      cch_out_q <= '0';
      dch_in_q <= '0';
      dch_out_q <= '0'; 
      scom_seq_q <= (others => '1');
      req_v_q <= '0';
      req_sat_q <= (others => '0');
      req_addr_q <= (others => '0');
      req_rw_q <= '0';      
      req_wr_data_q <= (others => '0');    
      rsp_v_q <= '0';  
      scom_err_q <= '0';                                       
	                	              
	else
	    
	   cch_in_q <= cch_in_d;
	   cch_out_q <= cch_out_d;
	   dch_in_q <= dch_in_d;	   
	   dch_out_q <= dch_out_d;	 
	   scom_seq_q <= scom_seq_d;
      req_v_q <= req_v_d;
      req_sat_q <= req_sat_d;
      req_addr_q <= req_addr_d;
      req_rw_q <= req_rw_d;
      req_wr_data_q <= req_wr_data_d;
      rsp_v_q <= rsp_v_q;
      scom_err_q <= scom_err_d;	     	   
	      
   end if;
	
end if;
	
end process FF;



req_v_d <= req_valid;
req_sat_d <= req_id;
req_addr_d <= req_addr;
req_rw_d <= (req_rw and req_valid) or (req_rw_q and not req_valid);
req_wr_data_d <= req_wr_data;







                   













cch_out_d <= cch_in;
cch_out <= cch_out_q;

dch_out_d <= dch_in;
dch_out <= dch_out_q;

err <= '0';

                      




end a2x_scom;

