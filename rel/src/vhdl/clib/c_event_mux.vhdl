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
--* TITLE: Performance Event Mux Component
--*
--* NAME:  c_event_mux.vhdl
--*
--********************************************************************
--
library ieee,support,ibm;
use ieee.std_logic_1164.all;
use ibm.std_ulogic_function_support.all;
use support.power_logic_pkg.all;

entity c_event_mux is
  generic( events_in      : integer := 32;  -- Valid Settings: FU=32; MMU=64; IU/XU/LSU=128
           events_out     : integer := 8 ); -- Valid Settings: 8 outputs per event mux
  port(
     vd             : inout power_logic;
     gd             : inout power_logic;
     t0_events      : in  std_ulogic_vector(0 to events_in/4-1);
     t1_events      : in  std_ulogic_vector(0 to events_in/4-1);
     t2_events      : in  std_ulogic_vector(0 to events_in/4-1);
     t3_events      : in  std_ulogic_vector(0 to events_in/4-1);

     -- Select bit size depends on total events: 32 events=32, 64 events=40; 128 events=48
     select_bits    : in  std_ulogic_vector(0 to ((events_in/64+4)*events_out)-1);

     event_bits     : out std_ulogic_vector(0 to events_out-1)
);
-- synopsys translate_off

-- synopsys translate_on

end c_event_mux;


architecture c_event_mux of c_event_mux is

  -- Constants used to split select_bits into thrd_sel + inMux_sel vectors
  --                                                           Mux Size:  32 64 128
  constant INCR                 : natural := events_in/64+4;    -- INCR:   4  5   6
  constant SIZE                 : natural := events_in/64+1;    -- SIZE:   1  2   3

------ stopped here ------------------

  -- For each output bit decode select bits to select an input mux to use.
  signal inMuxDec               : std_ulogic_vector(0 to events_out*events_in/4-1);
  signal inMuxOut               : std_ulogic_vector(0 to events_out*events_in/4-1);

  -- thrd_sel size always = 8; inMux_sel size = select_bit size - thrd_sel size
  signal thrd_sel               : std_ulogic_vector(0 to events_out-1);
  signal inMux_sel              : std_ulogic_vector(0 to ((events_in/64+3)*events_out)-1);


begin
  -- Split the select_bits input into "thread_select" and "input mux select" vectors
  --  32: (0,4,8,12,16,20,24,28)
  --  64: (0,5,10,15,20,25,30,35)
  -- 128: (0,6,12,18,24,30,36,42)
  thrd_sel    <= select_bits(0*INCR) & select_bits(1*INCR) &
                 select_bits(2*INCR) & select_bits(3*INCR) &
                 select_bits(4*INCR) & select_bits(5*INCR) &
                 select_bits(6*INCR) & select_bits(7*INCR) ;

  --  32: (1:3,5:7,9:11,13:15,17:19,21:23,25:27,29:31)
  --  64: (1:4,6:9,11:14,16:19,21:24,26:29,31:34,36:39)
  -- 128: (1:5,7:11,13:17,19:23,25:29,31:35,37:41,43:47)
  inMux_sel   <= select_bits(0*INCR+1 to (0+1)*INCR-1) &
                 select_bits(1*INCR+1 to (1+1)*INCR-1) &
                 select_bits(2*INCR+1 to (2+1)*INCR-1) &
                 select_bits(3*INCR+1 to (3+1)*INCR-1) &
                 select_bits(4*INCR+1 to (4+1)*INCR-1) &
                 select_bits(5*INCR+1 to (5+1)*INCR-1) &
                 select_bits(6*INCR+1 to (6+1)*INCR-1) &
                 select_bits(7*INCR+1 to (7+1)*INCR-1) ;


  -- For each output bit, decode its inMux_sel bits to select the input mux it's using
  decode: for X in 0 to events_out-1 generate
    Mux32: if (events_in = 32) generate
        inMuxDec(X*events_in/4 to X*events_in/4+7)  <= decode_3to8(inMux_sel(X*3 to X*3+2));
    end generate Mux32;

    Mux64: if (events_in = 64) generate
        inMuxDec(X*events_in/4 to X*events_in/4+15) <= decode_4to16(inMux_sel(X*4 to X*4+3));
    end generate Mux64;

    Mux128: if (events_in = 128) generate
        inMuxDec(X*events_in/4 to X*events_in/4+31) <= decode_5to32(inMux_sel(X*5 to X*5+4));
    end generate Mux128;
  end generate decode;


  -- For each output bit, inMux and thrd_sel decodes are used to gate the selected event input
  inpMuxHi: for X in 0 to events_out/2-1 generate
      eventSel: for I in 0 to events_in/4-1 generate
          inMuxOut(X*events_in/4 + I) <=
              ((inMuxDec(X*events_in/4 + I) and not thrd_sel(X) and t0_events(I)) or  
               (inMuxDec(X*events_in/4 + I) and     thrd_sel(X) and t1_events(I)) );  
      end generate eventSel;
  end generate inpMuxHi;

  inpMuxLo: for X in events_out/2 to events_out-1 generate
      eventSel: for I in 0 to events_in/4-1 generate
          inMuxOut(X*events_in/4 + I) <=
              ((inMuxDec(X*events_in/4 + I) and not thrd_sel(X) and t2_events(I)) or  
               (inMuxDec(X*events_in/4 + I) and     thrd_sel(X) and t3_events(I)) ); 
      end generate eventSel;
  end generate inpMuxLo;


  -- ORing the input mux outputs to drive each event output bit.
  -- Only one selected at a time by each output bit's inMux decode value.
  bitOutHi: for X in 0 to events_out/2-1 generate
    Mux32: if (events_in = 32) generate
        event_bits(X) <= or_reduce(inMuxOut(X*events_in/4 to X*events_in/4 + 7));
    end generate Mux32;

    Mux64: if (events_in = 64) generate
        event_bits(X) <= or_reduce(inMuxOut(X*events_in/4 to X*events_in/4 + 15));
    end generate Mux64;

    Mux128: if (events_in = 128) generate
        event_bits(X) <= or_reduce(inMuxOut(X*events_in/4 to X*events_in/4 + 31));
    end generate Mux128;
  end generate bitOutHi;

  bitOutLo: for X in events_out/2 to events_out-1 generate
    Mux32: if (events_in = 32) generate
        event_bits(X) <= or_reduce(inMuxOut(X*events_in/4 to X*events_in/4 + 7));
    end generate Mux32;

    Mux64: if (events_in = 64) generate
        event_bits(X) <= or_reduce(inMuxOut(X*events_in/4 to X*events_in/4 + 15));
    end generate Mux64;

    Mux128: if (events_in = 128) generate
        event_bits(X) <= or_reduce(inMuxOut(X*events_in/4 to X*events_in/4 + 31));
    end generate Mux128;
  end generate bitOutLo;

end c_event_mux;
