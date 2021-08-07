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

