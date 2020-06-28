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
library support;
use support.power_logic_pkg.all;
library tri;
use tri.tri_latches_pkg.all;

entity pcq_dbg_event is
generic(expand_type        : integer := 2  
);
port(
    vd                     : inout power_logic;
    gd                     : inout power_logic;
    event_mux_ctrls        : in    std_ulogic_vector(0 to 23);
    fu_event_data          : in    std_ulogic_vector(0 to 7);
    iu_event_data          : in    std_ulogic_vector(0 to 7);
    mm_event_data          : in    std_ulogic_vector(0 to 7);
    xu_event_data          : in    std_ulogic_vector(0 to 7);
    lsu_event_data         : in    std_ulogic_vector(0 to 7);
    trace_bus_data         : in    std_ulogic_vector(0 to 7);
    event_bus              : out   std_ulogic_vector(0 to 7)
);
-- synopsys translate_off

-- synopsys translate_on
end pcq_dbg_event;

architecture pcq_dbg_event of pcq_dbg_event is
signal event_signals_per_bit            : std_ulogic_vector(0 to 7);


begin


  with event_mux_ctrls(0 to 2)   select  
      event_signals_per_bit(0) <= xu_event_data(0)      when "000",
                                  iu_event_data(0)      when "001",
                                  fu_event_data(0)      when "010",
                                  mm_event_data(0)      when "011",
                                  lsu_event_data(0)     when "100",
                                  xu_event_data(4)      when "101",
                                  iu_event_data(4)      when "110",
                                  trace_bus_data(0)     when others;

  with event_mux_ctrls(3 to 5)   select  
      event_signals_per_bit(1) <= xu_event_data(1)      when "000",
                                  iu_event_data(1)      when "001",
                                  fu_event_data(1)      when "010",
                                  mm_event_data(1)      when "011",
                                  lsu_event_data(1)     when "100",
                                  xu_event_data(5)      when "101",
                                  iu_event_data(5)      when "110",
                                  trace_bus_data(1)     when others;

  with event_mux_ctrls(6 to 8)   select  
      event_signals_per_bit(2) <= xu_event_data(2)      when "000",
                                  iu_event_data(2)      when "001",
                                  fu_event_data(2)      when "010",
                                  mm_event_data(2)      when "011",
                                  lsu_event_data(2)     when "100",
                                  xu_event_data(6)      when "101",
                                  iu_event_data(6)      when "110",
                                  trace_bus_data(2)     when others;

  with event_mux_ctrls(9 to 11)  select  
      event_signals_per_bit(3) <= xu_event_data(3)      when "000",
                                  iu_event_data(3)      when "001",
                                  fu_event_data(3)      when "010",
                                  mm_event_data(3)      when "011",
                                  lsu_event_data(3)     when "100",
                                  xu_event_data(7)      when "101",
                                  iu_event_data(7)      when "110",
                                  trace_bus_data(3)     when others;

  with event_mux_ctrls(12 to 14) select  
      event_signals_per_bit(4) <= xu_event_data(4)      when "000",
                                  iu_event_data(4)      when "001",
                                  fu_event_data(4)      when "010",
                                  mm_event_data(4)      when "011",
                                  lsu_event_data(4)     when "100",
                                  xu_event_data(0)      when "101",
                                  iu_event_data(0)      when "110",
                                  trace_bus_data(4)     when others;

  with event_mux_ctrls(15 to 17) select  
      event_signals_per_bit(5) <= xu_event_data(5)      when "000",
                                  iu_event_data(5)      when "001",
                                  fu_event_data(5)      when "010",
                                  mm_event_data(5)      when "011",
                                  lsu_event_data(5)     when "100",
                                  xu_event_data(1)      when "101",
                                  iu_event_data(1)      when "110",
                                  trace_bus_data(5)     when others;

  with event_mux_ctrls(18 to 20) select  
      event_signals_per_bit(6) <= xu_event_data(6)      when "000",
                                  iu_event_data(6)      when "001",
                                  fu_event_data(6)      when "010",
                                  mm_event_data(6)      when "011",
                                  lsu_event_data(6)     when "100",
                                  xu_event_data(2)      when "101",
                                  iu_event_data(2)      when "110",
                                  trace_bus_data(6)     when others;

  with event_mux_ctrls(21 to 23) select  
      event_signals_per_bit(7) <= xu_event_data(7)      when "000",
                                  iu_event_data(7)      when "001",
                                  fu_event_data(7)      when "010",
                                  mm_event_data(7)      when "011",
                                  lsu_event_data(7)     when "100",
                                  xu_event_data(3)      when "101",
                                  iu_event_data(3)      when "110",
                                  trace_bus_data(7)     when others;


  event_bus(0 to 7)  <=  event_signals_per_bit(0 to 7);


end pcq_dbg_event;

