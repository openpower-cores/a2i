-- © IBM Corp. 2020
-- This softcore is licensed under and subject to the terms of the CC-BY 4.0
-- license (https://creativecommons.org/licenses/by/4.0/legalcode). 
-- Additional rights, including the right to physically implement a softcore 
-- that is compliant with the required sections of the Power ISA 
-- Specification, will be available at no cost via the OpenPOWER Foundation. 
-- This README will be updated with additional information when OpenPOWER's 
-- license is available.

library ieee,support,ibm;
use ieee.std_logic_1164.all;
use ibm.std_ulogic_function_support.all;
use support.power_logic_pkg.all;

entity c_event_mux is
  generic( events_in      : integer := 32;  
           events_out     : integer := 8 ); 
  port(
     vd             : inout power_logic;
     gd             : inout power_logic;
     t0_events      : in  std_ulogic_vector(0 to events_in/4-1);
     t1_events      : in  std_ulogic_vector(0 to events_in/4-1);
     t2_events      : in  std_ulogic_vector(0 to events_in/4-1);
     t3_events      : in  std_ulogic_vector(0 to events_in/4-1);

     select_bits    : in  std_ulogic_vector(0 to ((events_in/64+4)*events_out)-1);

     event_bits     : out std_ulogic_vector(0 to events_out-1)
);
-- synopsys translate_off

-- synopsys translate_on

end c_event_mux;


architecture c_event_mux of c_event_mux is

  constant INCR                 : natural := events_in/64+4;    
  constant SIZE                 : natural := events_in/64+1;    


  signal inMuxDec               : std_ulogic_vector(0 to events_out*events_in/4-1);
  signal inMuxOut               : std_ulogic_vector(0 to events_out*events_in/4-1);

  signal thrd_sel               : std_ulogic_vector(0 to events_out-1);
  signal inMux_sel              : std_ulogic_vector(0 to ((events_in/64+3)*events_out)-1);


begin
  thrd_sel    <= select_bits(0*INCR) & select_bits(1*INCR) &
                 select_bits(2*INCR) & select_bits(3*INCR) &
                 select_bits(4*INCR) & select_bits(5*INCR) &
                 select_bits(6*INCR) & select_bits(7*INCR) ;

  inMux_sel   <= select_bits(0*INCR+1 to (0+1)*INCR-1) &
                 select_bits(1*INCR+1 to (1+1)*INCR-1) &
                 select_bits(2*INCR+1 to (2+1)*INCR-1) &
                 select_bits(3*INCR+1 to (3+1)*INCR-1) &
                 select_bits(4*INCR+1 to (4+1)*INCR-1) &
                 select_bits(5*INCR+1 to (5+1)*INCR-1) &
                 select_bits(6*INCR+1 to (6+1)*INCR-1) &
                 select_bits(7*INCR+1 to (7+1)*INCR-1) ;


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

