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


LIBRARY ieee;       USE ieee.std_logic_1164.all;
                    USE ieee.numeric_std.all;
LIBRARY ibm;        
                    USE ibm.std_ulogic_support.all;
                    USE ibm.std_ulogic_unsigned.all;
                    USE ibm.std_ulogic_function_support.all;
LIBRARY support;    
                    USE support.power_logic_pkg.all;
LIBRARY tri;        USE tri.tri_latches_pkg.all;
LIBRARY clib;

entity xuq_alu_mult_boothrow is
    port(
        s_neg           : in std_ulogic;                  
        s_x             : in std_ulogic;                  
        s_x2            : in std_ulogic;                  
        sign_bit_adj    : in std_ulogic;
        x               : in std_ulogic_vector(0 to 31);  
        q               : out std_ulogic_vector(0 to 32); 
        hot_one         : out std_ulogic;                 
        vdd             : inout power_logic;
        gnd             : inout power_logic
    );
--  synopsys translate_off
--  synopsys translate_on
end xuq_alu_mult_boothrow; 

architecture xuq_alu_mult_boothrow of xuq_alu_mult_boothrow is
    constant tiup   : std_ulogic := '1';
    constant tidn   : std_ulogic := '0';

    signal left     : std_ulogic_vector(1 to 32);





begin



    u00: entity clib.c_prism_bthmx generic map( btr => "BTHMX_X1_A12TH" ) port map(
        vd      => vdd,
        gd      => gnd,
        sneg    => s_neg,
        SX      => s_x,
        SX2     => s_x2,
        X       => sign_bit_adj,
        RIGHT   => left(1),
        LEFT    => open,
        Q       => q(0));

    u01: entity clib.c_prism_bthmx generic map( btr => "BTHMX_X1_A12TH" ) port map(
        vd      => vdd,
        gd      => gnd,
        sneg    => s_neg,
        SX      => s_x,
        SX2     => s_x2,
        X       => x(0),
        RIGHT   => left(2),
        LEFT    => left(1),
        Q       => q(1));

    u02: entity clib.c_prism_bthmx generic map( btr => "BTHMX_X1_A12TH" ) port map(
        vd      => vdd,
        gd      => gnd,
        sneg    => s_neg,
        SX      => s_x,
        SX2     => s_x2,
        X       => x(1),
        RIGHT   => left(3),
        LEFT    => left(2),
        Q       => q(2));

    u03: entity clib.c_prism_bthmx generic map( btr => "BTHMX_X1_A12TH" ) port map(
        vd      => vdd,
        gd      => gnd,
        sneg    => s_neg,
        SX      => s_x,
        SX2     => s_x2,
        X       => x(2),
        RIGHT   => left(4),
        LEFT    => left(3),
        Q       => q(3));

    u04: entity clib.c_prism_bthmx generic map( btr => "BTHMX_X1_A12TH" ) port map(
        vd      => vdd,
        gd      => gnd,
        sneg    => s_neg,
        SX      => s_x,
        SX2     => s_x2,
        X       => x(3),
        RIGHT   => left(5),
        LEFT    => left(4),
        Q       => q(4));

    u05: entity clib.c_prism_bthmx generic map( btr => "BTHMX_X1_A12TH" ) port map(
        vd      => vdd,
        gd      => gnd,
        sneg    => s_neg,
        SX      => s_x,
        SX2     => s_x2,
        X       => x(4),
        RIGHT   => left(6),
        LEFT    => left(5),
        Q       => q(5));

    u06: entity clib.c_prism_bthmx generic map( btr => "BTHMX_X1_A12TH" ) port map(
        vd      => vdd,
        gd      => gnd,
        sneg    => s_neg,
        SX      => s_x,
        SX2     => s_x2,
        X       => x(5),
        RIGHT   => left(7),
        LEFT    => left(6),
        Q       => q(6));

    u07: entity clib.c_prism_bthmx generic map( btr => "BTHMX_X1_A12TH" ) port map(
        vd      => vdd,
        gd      => gnd,
        sneg    => s_neg,
        SX      => s_x,
        SX2     => s_x2,
        X       => x(6),
        RIGHT   => left(8),
        LEFT    => left(7),
        Q       => q(7));

    u08: entity clib.c_prism_bthmx generic map( btr => "BTHMX_X1_A12TH" ) port map(
        vd      => vdd,
        gd      => gnd,
        sneg    => s_neg,
        SX      => s_x,
        SX2     => s_x2,
        X       => x(7),
        RIGHT   => left(9),
        LEFT    => left(8),
        Q       => q(8));

    u09: entity clib.c_prism_bthmx generic map( btr => "BTHMX_X1_A12TH" ) port map(
        vd      => vdd,
        gd      => gnd,
        sneg    => s_neg,
        SX      => s_x,
        SX2     => s_x2,
        X       => x(8),
        RIGHT   => left(10),
        LEFT    => left(9),
        Q       => q(9));

    u10: entity clib.c_prism_bthmx generic map( btr => "BTHMX_X1_A12TH" ) port map(
        vd      => vdd,
        gd      => gnd,
        sneg    => s_neg,
        SX      => s_x,
        SX2     => s_x2,
        X       => x(9),
        RIGHT   => left(11),
        LEFT    => left(10),
        Q       => q(10));

    u11: entity clib.c_prism_bthmx generic map( btr => "BTHMX_X1_A12TH" ) port map(
        vd      => vdd,
        gd      => gnd,
        sneg    => s_neg,
        SX      => s_x,
        SX2     => s_x2,
        X       => x(10),
        RIGHT   => left(12),
        LEFT    => left(11),
        Q       => q(11));

    u12: entity clib.c_prism_bthmx generic map( btr => "BTHMX_X1_A12TH" ) port map(
        vd      => vdd,
        gd      => gnd,
        sneg    => s_neg,
        SX      => s_x,
        SX2     => s_x2,
        X       => x(11),
        RIGHT   => left(13),
        LEFT    => left(12),
        Q       => q(12));

    u13: entity clib.c_prism_bthmx generic map( btr => "BTHMX_X1_A12TH" ) port map(
        vd      => vdd,
        gd      => gnd,
        sneg    => s_neg,
        SX      => s_x,
        SX2     => s_x2,
        X       => x(12),
        RIGHT   => left(14),
        LEFT    => left(13),
        Q       => q(13));

    u14: entity clib.c_prism_bthmx generic map( btr => "BTHMX_X1_A12TH" ) port map(
        vd      => vdd,
        gd      => gnd,
        sneg    => s_neg,
        SX      => s_x,
        SX2     => s_x2,
        X       => x(13),
        RIGHT   => left(15),
        LEFT    => left(14),
        Q       => q(14));

    u15: entity clib.c_prism_bthmx generic map( btr => "BTHMX_X1_A12TH" ) port map(
        vd      => vdd,
        gd      => gnd,
        sneg    => s_neg,
        SX      => s_x,
        SX2     => s_x2,
        X       => x(14),
        RIGHT   => left(16),
        LEFT    => left(15),
        Q       => q(15));

    u16: entity clib.c_prism_bthmx generic map( btr => "BTHMX_X1_A12TH" ) port map(
        vd      => vdd,
        gd      => gnd,
        sneg    => s_neg,
        SX      => s_x,
        SX2     => s_x2,
        X       => x(15),
        RIGHT   => left(17),
        LEFT    => left(16),
        Q       => q(16));

    u17: entity clib.c_prism_bthmx generic map( btr => "BTHMX_X1_A12TH" ) port map(
        vd      => vdd,
        gd      => gnd,
        sneg    => s_neg,
        SX      => s_x,
        SX2     => s_x2,
        X       => x(16),
        RIGHT   => left(18),
        LEFT    => left(17),
        Q       => q(17));

    u18: entity clib.c_prism_bthmx generic map( btr => "BTHMX_X1_A12TH" ) port map(
        vd      => vdd,
        gd      => gnd,
        sneg    => s_neg,
        SX      => s_x,
        SX2     => s_x2,
        X       => x(17),
        RIGHT   => left(19),
        LEFT    => left(18),
        Q       => q(18));

    u19: entity clib.c_prism_bthmx generic map( btr => "BTHMX_X1_A12TH" ) port map(
        vd      => vdd,
        gd      => gnd,
        sneg    => s_neg,
        SX      => s_x,
        SX2     => s_x2,
        X       => x(18),
        RIGHT   => left(20),
        LEFT    => left(19),
        Q       => q(19));

    u20: entity clib.c_prism_bthmx generic map( btr => "BTHMX_X1_A12TH" ) port map(
        vd      => vdd,
        gd      => gnd,
        sneg    => s_neg,
        SX      => s_x,
        SX2     => s_x2,
        X       => x(19),
        RIGHT   => left(21),
        LEFT    => left(20),
        Q       => q(20));

    u21: entity clib.c_prism_bthmx generic map( btr => "BTHMX_X1_A12TH" ) port map(
        vd      => vdd,
        gd      => gnd,
        sneg    => s_neg,
        SX      => s_x,
        SX2     => s_x2,
        X       => x(20),
        RIGHT   => left(22),
        LEFT    => left(21),
        Q       => q(21));

    u22: entity clib.c_prism_bthmx generic map( btr => "BTHMX_X1_A12TH" ) port map(
        vd      => vdd,
        gd      => gnd,
        sneg    => s_neg,
        SX      => s_x,
        SX2     => s_x2,
        X       => x(21),
        RIGHT   => left(23),
        LEFT    => left(22),
        Q       => q(22));

    u23: entity clib.c_prism_bthmx generic map( btr => "BTHMX_X1_A12TH" ) port map(
        vd      => vdd,
        gd      => gnd,
        sneg    => s_neg,
        SX      => s_x,
        SX2     => s_x2,
        X       => x(22),
        RIGHT   => left(24),
        LEFT    => left(23),
        Q       => q(23));

    u24: entity clib.c_prism_bthmx generic map( btr => "BTHMX_X1_A12TH" ) port map(
        vd      => vdd,
        gd      => gnd,
        sneg    => s_neg,
        SX      => s_x,
        SX2     => s_x2,
        X       => x(23),
        RIGHT   => left(25),
        LEFT    => left(24),
        Q       => q(24));

    u25: entity clib.c_prism_bthmx generic map( btr => "BTHMX_X1_A12TH" ) port map(
        vd      => vdd,
        gd      => gnd,
        sneg    => s_neg,
        SX      => s_x,
        SX2     => s_x2,
        X       => x(24),
        RIGHT   => left(26),
        LEFT    => left(25),
        Q       => q(25));

    u26: entity clib.c_prism_bthmx generic map( btr => "BTHMX_X1_A12TH" ) port map(
        vd      => vdd,
        gd      => gnd,
        sneg    => s_neg,
        SX      => s_x,
        SX2     => s_x2,
        X       => x(25),
        RIGHT   => left(27),
        LEFT    => left(26),
        Q       => q(26));

    u27: entity clib.c_prism_bthmx generic map( btr => "BTHMX_X1_A12TH" ) port map(
        vd      => vdd,
        gd      => gnd,
        sneg    => s_neg,
        SX      => s_x,
        SX2     => s_x2,
        X       => x(26),
        RIGHT   => left(28),
        LEFT    => left(27),
        Q       => q(27));

    u28: entity clib.c_prism_bthmx generic map( btr => "BTHMX_X1_A12TH" ) port map(
        vd      => vdd,
        gd      => gnd,
        sneg    => s_neg,
        SX      => s_x,
        SX2     => s_x2,
        X       => x(27),
        RIGHT   => left(29),
        LEFT    => left(28),
        Q       => q(28));

    u29: entity clib.c_prism_bthmx generic map( btr => "BTHMX_X1_A12TH" ) port map(
        vd      => vdd,
        gd      => gnd,
        sneg    => s_neg,
        SX      => s_x,
        SX2     => s_x2,
        X       => x(28),
        RIGHT   => left(30),
        LEFT    => left(29),
        Q       => q(29));

    u30: entity clib.c_prism_bthmx generic map( btr => "BTHMX_X1_A12TH" ) port map(
        vd      => vdd,
        gd      => gnd,
        sneg    => s_neg,
        SX      => s_x,
        SX2     => s_x2,
        X       => x(29),
        RIGHT   => left(31),
        LEFT    => left(30),
        Q       => q(30));

    u31: entity clib.c_prism_bthmx generic map( btr => "BTHMX_X1_A12TH" ) port map(
        vd      => vdd,
        gd      => gnd,
        sneg    => s_neg,
        SX      => s_x,
        SX2     => s_x2,
        X       => x(30),
        RIGHT   => left(32),
        LEFT    => left(31),
        Q       => q(31));

    u32: entity clib.c_prism_bthmx generic map( btr => "BTHMX_X1_A12TH" ) port map(
        vd      => vdd,
        gd      => gnd,
        sneg    => s_neg,
        SX      => s_x,
        SX2     => s_x2,
        X       => x(31),
        RIGHT   => s_neg,
        LEFT    => left(32),
        Q       => q(32));


    u33: hot_one <= s_neg and (s_x or s_x2) ;
end;

