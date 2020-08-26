-- © IBM Corp. 2020
-- This softcore is licensed under and subject to the terms of the CC-BY 4.0
-- license (https://creativecommons.org/licenses/by/4.0/legalcode). 
-- Additional rights, including the right to physically implement a softcore 
-- that is compliant with the required sections of the Power ISA 
-- Specification, will be available at no cost via the OpenPOWER Foundation. 
-- This README will be updated with additional information when OpenPOWER's 
-- license is available.

--********************************************************************
--*
--* TITLE: Debug Mux Component (32:1 Debug Groups; 4:1 Trigger Groups)
--*
--* NAME: c_debug_mux32.vhdl
--*
--********************************************************************
--
library ieee; use ieee.std_logic_1164.all;
library support;
use support.power_logic_pkg.all;

entity c_debug_mux32 is
generic( DBG_WIDTH      : integer := 88         
);         
port(
     vd                 : inout power_logic;
     gd                 : inout power_logic;

     select_bits        : in std_ulogic_vector(0 to 15);
     trace_data_in      : in std_ulogic_vector(0 to DBG_WIDTH-1);
     trigger_data_in    : in std_ulogic_vector(0 to 11);

     dbg_group0         : in std_ulogic_vector(0 to DBG_WIDTH-1);
     dbg_group1         : in std_ulogic_vector(0 to DBG_WIDTH-1);
     dbg_group2         : in std_ulogic_vector(0 to DBG_WIDTH-1);
     dbg_group3         : in std_ulogic_vector(0 to DBG_WIDTH-1);
     dbg_group4         : in std_ulogic_vector(0 to DBG_WIDTH-1);
     dbg_group5         : in std_ulogic_vector(0 to DBG_WIDTH-1);
     dbg_group6         : in std_ulogic_vector(0 to DBG_WIDTH-1);
     dbg_group7         : in std_ulogic_vector(0 to DBG_WIDTH-1);
     dbg_group8         : in std_ulogic_vector(0 to DBG_WIDTH-1);
     dbg_group9         : in std_ulogic_vector(0 to DBG_WIDTH-1);
     dbg_group10        : in std_ulogic_vector(0 to DBG_WIDTH-1);
     dbg_group11        : in std_ulogic_vector(0 to DBG_WIDTH-1);
     dbg_group12        : in std_ulogic_vector(0 to DBG_WIDTH-1);
     dbg_group13        : in std_ulogic_vector(0 to DBG_WIDTH-1);
     dbg_group14        : in std_ulogic_vector(0 to DBG_WIDTH-1);
     dbg_group15        : in std_ulogic_vector(0 to DBG_WIDTH-1);
     dbg_group16        : in std_ulogic_vector(0 to DBG_WIDTH-1);
     dbg_group17        : in std_ulogic_vector(0 to DBG_WIDTH-1);
     dbg_group18        : in std_ulogic_vector(0 to DBG_WIDTH-1);
     dbg_group19        : in std_ulogic_vector(0 to DBG_WIDTH-1);
     dbg_group20        : in std_ulogic_vector(0 to DBG_WIDTH-1);
     dbg_group21        : in std_ulogic_vector(0 to DBG_WIDTH-1);
     dbg_group22        : in std_ulogic_vector(0 to DBG_WIDTH-1);
     dbg_group23        : in std_ulogic_vector(0 to DBG_WIDTH-1);
     dbg_group24        : in std_ulogic_vector(0 to DBG_WIDTH-1);
     dbg_group25        : in std_ulogic_vector(0 to DBG_WIDTH-1);
     dbg_group26        : in std_ulogic_vector(0 to DBG_WIDTH-1);
     dbg_group27        : in std_ulogic_vector(0 to DBG_WIDTH-1);
     dbg_group28        : in std_ulogic_vector(0 to DBG_WIDTH-1);
     dbg_group29        : in std_ulogic_vector(0 to DBG_WIDTH-1);
     dbg_group30        : in std_ulogic_vector(0 to DBG_WIDTH-1);
     dbg_group31        : in std_ulogic_vector(0 to DBG_WIDTH-1);

     trg_group0         : in std_ulogic_vector(0 to 11);
     trg_group1         : in std_ulogic_vector(0 to 11);
     trg_group2         : in std_ulogic_vector(0 to 11);
     trg_group3         : in std_ulogic_vector(0 to 11);

     trace_data_out     : out std_ulogic_vector(0 to DBG_WIDTH-1);
     trigger_data_out   : out std_ulogic_vector(0 to 11)
);
-- synopsys translate_off

-- synopsys translate_on

end c_debug_mux32;


architecture c_debug_mux32 of c_debug_mux32 is

constant DBG_1FOURTH            : positive := DBG_WIDTH/4;
constant DBG_2FOURTH            : positive := DBG_WIDTH/2;
constant DBG_3FOURTH            : positive := 3*DBG_WIDTH/4;

signal debug_grp_selected       : std_ulogic_vector(0 to DBG_WIDTH-1);
signal debug_grp_rotated        : std_ulogic_vector(0 to DBG_WIDTH-1);
signal trigg_grp_selected       : std_ulogic_vector(0 to 11);
signal trigg_grp_rotated        : std_ulogic_vector(0 to 11);

begin


-- Debug Mux
    with select_bits(0 to 4) select debug_grp_selected <= 
      dbg_group0    when "00000",
      dbg_group1    when "00001",
      dbg_group2    when "00010",
      dbg_group3    when "00011",
      dbg_group4    when "00100",
      dbg_group5    when "00101",
      dbg_group6    when "00110",
      dbg_group7    when "00111",
      dbg_group8    when "01000",
      dbg_group9    when "01001",
      dbg_group10   when "01010",
      dbg_group11   when "01011",
      dbg_group12   when "01100",
      dbg_group13   when "01101",
      dbg_group14   when "01110",
      dbg_group15   when "01111",
      dbg_group16   when "10000",
      dbg_group17   when "10001",
      dbg_group18   when "10010",
      dbg_group19   when "10011",
      dbg_group20   when "10100",
      dbg_group21   when "10101",
      dbg_group22   when "10110",
      dbg_group23   when "10111",
      dbg_group24   when "11000",
      dbg_group25   when "11001",
      dbg_group26   when "11010",
      dbg_group27   when "11011",
      dbg_group28   when "11100",
      dbg_group29   when "11101",
      dbg_group30   when "11110",
      dbg_group31   when others;

   with select_bits(5 to 6) select 
       debug_grp_rotated  <=  debug_grp_selected(DBG_1FOURTH to DBG_WIDTH-1) & debug_grp_selected(0 to DBG_1FOURTH-1) when "11",
                              debug_grp_selected(DBG_2FOURTH to DBG_WIDTH-1) & debug_grp_selected(0 to DBG_2FOURTH-1) when "10",
                              debug_grp_selected(DBG_3FOURTH to DBG_WIDTH-1) & debug_grp_selected(0 to DBG_3FOURTH-1) when "01",
                              debug_grp_selected(0 to DBG_WIDTH-1)                                                    when others;


   with select_bits(7)  select trace_data_out(0 to DBG_1FOURTH-1) <= 
      trace_data_in(0 to DBG_1FOURTH-1)                 when '0',
      debug_grp_rotated(0 to DBG_1FOURTH-1)             when others;

   with select_bits(8)  select trace_data_out(DBG_1FOURTH to DBG_2FOURTH-1) <= 
      trace_data_in(DBG_1FOURTH to DBG_2FOURTH-1)       when '0',
      debug_grp_rotated(DBG_1FOURTH to DBG_2FOURTH-1)   when others;

   with select_bits(9)  select trace_data_out(DBG_2FOURTH to DBG_3FOURTH-1) <= 
      trace_data_in(DBG_2FOURTH to DBG_3FOURTH-1)       when '0',
      debug_grp_rotated(DBG_2FOURTH to DBG_3FOURTH-1)   when others;

   with select_bits(10) select trace_data_out(DBG_3FOURTH to DBG_WIDTH-1) <= 
      trace_data_in(DBG_3FOURTH to DBG_WIDTH-1)         when '0',
      debug_grp_rotated(DBG_3FOURTH to DBG_WIDTH-1)     when others;



-- Trigger Mux
   with select_bits(11 to 12) select trigg_grp_selected <= 
      trg_group0    when "00",
      trg_group1    when "01",
      trg_group2    when "10",
      trg_group3    when others;

   with select_bits(13) select 
       trigg_grp_rotated  <=  trigg_grp_selected(6 to 11) & trigg_grp_selected(0 to 5) when '1',
                              trigg_grp_selected(0 to 11)                              when others;

   with select_bits(14) select trigger_data_out(0 to 5) <=
      trigger_data_in(0 to 5)       when '0',
      trigg_grp_rotated(0 to 5)     when others;

   with select_bits(15) select trigger_data_out(6 to 11) <=
      trigger_data_in(6 to 11)      when '0',
      trigg_grp_rotated(6 to 11)    when others;


end c_debug_mux32;
