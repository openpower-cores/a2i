-- © IBM Corp. 2020
-- This softcore is licensed under and subject to the terms of the CC-BY 4.0
-- license (https://creativecommons.org/licenses/by/4.0/legalcode). 
-- Additional rights, including the right to physically implement a softcore 
-- that is compliant with the required sections of the Power ISA 
-- Specification, will be available at no cost via the OpenPOWER Foundation. 
-- This README will be updated with additional information when OpenPOWER's 
-- license is available.


library ieee,ibm,support,tri,work;
   use ieee.std_logic_1164.all;
   use ibm.std_ulogic_unsigned.all;
   use ibm.std_ulogic_support.all; 
   use ibm.std_ulogic_function_support.all;
   use support.power_logic_pkg.all;
   use tri.tri_latches_pkg.all;
   use ibm.std_ulogic_ao_support.all; 
   use ibm.std_ulogic_mux_support.all; 


 
entity fuq_alg_sh16 is
generic(       expand_type               : integer := 2  ); 
port(
      ex2_lvl3_shdcd000        :in   std_ulogic;
      ex2_lvl3_shdcd016        :in   std_ulogic;
      ex2_lvl3_shdcd032        :in   std_ulogic;
      ex2_lvl3_shdcd048        :in   std_ulogic;
      ex2_lvl3_shdcd064        :in   std_ulogic;
      ex2_lvl3_shdcd080        :in   std_ulogic;
      ex2_lvl3_shdcd096        :in   std_ulogic;
      ex2_lvl3_shdcd112        :in   std_ulogic;
      ex2_lvl3_shdcd128        :in   std_ulogic;
      ex2_lvl3_shdcd144        :in   std_ulogic;
      ex2_lvl3_shdcd160        :in   std_ulogic;
      ex2_lvl3_shdcd192        :in   std_ulogic;
      ex2_lvl3_shdcd208        :in   std_ulogic;
      ex2_lvl3_shdcd224        :in   std_ulogic;
      ex2_lvl3_shdcd240        :in   std_ulogic;
      ex2_sel_special          :in   std_ulogic;

      ex2_sh_lvl2              :in   std_ulogic_vector(0 to 67) ;

      ex2_sh16_162             :out std_ulogic ;
      ex2_sh16_163             :out std_ulogic ;
      ex2_sh_lvl3              :out std_ulogic_vector(0 to 162)  
);



end fuq_alg_sh16; 

architecture fuq_alg_sh16 of fuq_alg_sh16 is

    constant tiup : std_ulogic := '1';
    constant tidn : std_ulogic := '0';

    signal ex2_sh16_r1_b, ex2_sh16_r2_b, ex2_sh16_r3_b : std_ulogic_vector(0 to 162);
    signal ex2_special :std_ulogic_vector(99 to 162);

    
 signal cpx_spc_b :std_ulogic;
 signal cpx_000_b :std_ulogic;
 signal cpx_016_b :std_ulogic;
 signal cpx_032_b :std_ulogic;
 signal cpx_048_b :std_ulogic;
 signal cpx_064_b :std_ulogic;
 signal cpx_080_b :std_ulogic;
 signal cpx_096_b :std_ulogic;
 signal cpx_112_b :std_ulogic;
 signal cpx_128_b :std_ulogic;
 signal cpx_144_b :std_ulogic;
 signal cpx_160_b :std_ulogic;
 signal cpx_192_b :std_ulogic;
 signal cpx_208_b :std_ulogic;
 signal cpx_224_b :std_ulogic;
 signal cpx_240_b :std_ulogic;
 signal cp1_spc   :std_ulogic;
 signal cp1_000   :std_ulogic;
 signal cp1_016   :std_ulogic;
 signal cp1_032   :std_ulogic;
 signal cp1_048   :std_ulogic;
 signal cp1_064   :std_ulogic;
 signal cp1_080   :std_ulogic;
 signal cp1_096   :std_ulogic;
 signal cp1_112   :std_ulogic;
 signal cp1_128   :std_ulogic;
 signal cp1_144   :std_ulogic;
 signal cp1_160   :std_ulogic;
 signal cp1_192   :std_ulogic;
 signal cp1_208   :std_ulogic;
 signal cp1_224   :std_ulogic;
 signal cp1_240   :std_ulogic;
 signal cp2_spc   :std_ulogic;
 signal cp2_000   :std_ulogic;
 signal cp2_016   :std_ulogic;
 signal cp2_032   :std_ulogic;
 signal cp2_048   :std_ulogic;
 signal cp2_064   :std_ulogic;
 signal cp2_080   :std_ulogic;
 signal cp2_096   :std_ulogic;
 signal cp2_112   :std_ulogic;
 signal cp2_128   :std_ulogic;
 signal cp2_144   :std_ulogic;
 signal cp2_208   :std_ulogic;
 signal cp2_224   :std_ulogic;
 signal cp2_240   :std_ulogic;
 signal cp3_spc   :std_ulogic;
 signal cp3_000   :std_ulogic;
 signal cp3_016   :std_ulogic;
 signal cp3_032   :std_ulogic;
 signal cp3_048   :std_ulogic;
 signal cp3_064   :std_ulogic;
 signal cp3_080   :std_ulogic;
 signal cp3_096   :std_ulogic;
 signal cp3_112   :std_ulogic;
 signal cp3_128   :std_ulogic;
 signal cp3_224   :std_ulogic;
 signal cp3_240   :std_ulogic;
 signal cp4_spc   :std_ulogic;
 signal cp4_000   :std_ulogic;
 signal cp4_016   :std_ulogic;
 signal cp4_032   :std_ulogic;
 signal cp4_048   :std_ulogic;
 signal cp4_064   :std_ulogic;
 signal cp4_080   :std_ulogic;
 signal cp4_096   :std_ulogic;
 signal cp4_112   :std_ulogic;
 signal cp4_240   :std_ulogic;
 signal cp5_spc   :std_ulogic;
 signal cp5_000   :std_ulogic;
 signal cp5_016   :std_ulogic;
 signal cp5_032   :std_ulogic;
 signal cp5_048   :std_ulogic;
 signal cp5_064   :std_ulogic;
 signal cp5_080   :std_ulogic;
 signal cp5_096   :std_ulogic;
signal ex2_sh16_r1_162_b, ex2_sh16_r2_162_b, ex2_sh16_r3_162_b :std_ulogic;
signal ex2_sh16_r1_163_b, ex2_sh16_r2_163_b, ex2_sh16_r3_163_b :std_ulogic;


     






begin





     ex2_special(99 to 162) <= ex2_sh_lvl2(0 to 63); 





cxspcb: cpx_spc_b <= not ex2_sel_special    ;
cx000b: cpx_000_b <= not ex2_lvl3_shdcd000 ;
cx016b: cpx_016_b <= not ex2_lvl3_shdcd016  ;
cx032b: cpx_032_b <= not ex2_lvl3_shdcd032  ;
cx048b: cpx_048_b <= not ex2_lvl3_shdcd048  ;
cx064b: cpx_064_b <= not ex2_lvl3_shdcd064  ;
cx080b: cpx_080_b <= not ex2_lvl3_shdcd080  ;
cx096b: cpx_096_b <= not ex2_lvl3_shdcd096  ;
cx112b: cpx_112_b <= not ex2_lvl3_shdcd112  ;
cx128b: cpx_128_b <= not ex2_lvl3_shdcd128  ;
cx144b: cpx_144_b <= not ex2_lvl3_shdcd144  ;
cx160b: cpx_160_b <= not ex2_lvl3_shdcd160  ;
cx192b: cpx_192_b <= not ex2_lvl3_shdcd192  ;
cx208b: cpx_208_b <= not ex2_lvl3_shdcd208  ;
cx224b: cpx_224_b <= not ex2_lvl3_shdcd224  ;
cx240b: cpx_240_b <= not ex2_lvl3_shdcd240  ;


c1_spc: cp1_spc <= not cpx_spc_b ;
c1_000: cp1_000 <= not cpx_000_b ;
c1_016: cp1_016 <= not cpx_016_b ;
c1_032: cp1_032 <= not cpx_032_b ;
c1_048: cp1_048 <= not cpx_048_b ;
c1_064: cp1_064 <= not cpx_064_b ;
c1_080: cp1_080 <= not cpx_080_b ;
c1_096: cp1_096 <= not cpx_096_b ;
c1_112: cp1_112 <= not cpx_112_b ;
c1_128: cp1_128 <= not cpx_128_b ;
c1_144: cp1_144 <= not cpx_144_b ;
c1_160: cp1_160 <= not cpx_160_b ;
c1_192: cp1_192 <= not cpx_192_b ;
c1_208: cp1_208 <= not cpx_208_b ;
c1_224: cp1_224 <= not cpx_224_b ;
c1_240: cp1_240 <= not cpx_240_b ;

c2_spc: cp2_spc <= not cpx_spc_b ;
c2_000: cp2_000 <= not cpx_000_b ;
c2_016: cp2_016 <= not cpx_016_b ;
c2_032: cp2_032 <= not cpx_032_b ;
c2_048: cp2_048 <= not cpx_048_b ;
c2_064: cp2_064 <= not cpx_064_b ;
c2_080: cp2_080 <= not cpx_080_b ;
c2_096: cp2_096 <= not cpx_096_b ;
c2_112: cp2_112 <= not cpx_112_b ;
c2_128: cp2_128 <= not cpx_128_b ;
c2_144: cp2_144 <= not cpx_144_b ;
c2_208: cp2_208 <= not cpx_208_b ;
c2_224: cp2_224 <= not cpx_224_b ;
c2_240: cp2_240 <= not cpx_240_b ;

c3_spc: cp3_spc <= not cpx_spc_b ;
c3_000: cp3_000 <= not cpx_000_b ;
c3_016: cp3_016 <= not cpx_016_b ;
c3_032: cp3_032 <= not cpx_032_b ;
c3_048: cp3_048 <= not cpx_048_b ;
c3_064: cp3_064 <= not cpx_064_b ;
c3_080: cp3_080 <= not cpx_080_b ;
c3_096: cp3_096 <= not cpx_096_b ;
c3_112: cp3_112 <= not cpx_112_b ;
c3_128: cp3_128 <= not cpx_128_b ;
c3_224: cp3_224 <= not cpx_224_b ;
c3_240: cp3_240 <= not cpx_240_b ;

c4_spc: cp4_spc <= not cpx_spc_b ;
c4_000: cp4_000 <= not cpx_000_b ;
c4_016: cp4_016 <= not cpx_016_b ;
c4_032: cp4_032 <= not cpx_032_b ;
c4_048: cp4_048 <= not cpx_048_b ;
c4_064: cp4_064 <= not cpx_064_b ;
c4_080: cp4_080 <= not cpx_080_b ;
c4_096: cp4_096 <= not cpx_096_b ;
c4_112: cp4_112 <= not cpx_112_b ;
c4_240: cp4_240 <= not cpx_240_b ;

c5_spc: cp5_spc <= not cpx_spc_b ;
c5_000: cp5_000 <= not cpx_000_b ;
c5_016: cp5_016 <= not cpx_016_b ;
c5_032: cp5_032 <= not cpx_032_b ;
c5_048: cp5_048 <= not cpx_048_b ;
c5_064: cp5_064 <= not cpx_064_b ;
c5_080: cp5_080 <= not cpx_080_b ;
c5_096: cp5_096 <= not cpx_096_b ;





r1_000:   ex2_sh16_r1_b(0)     <= not( (cp1_192    and ex2_sh_lvl2(64)     ) or (cp1_208    and ex2_sh_lvl2(48)     ) );
r1_001:   ex2_sh16_r1_b(1)     <= not( (cp1_192    and ex2_sh_lvl2(65)     ) or (cp1_208    and ex2_sh_lvl2(49)     ) );
r1_002:   ex2_sh16_r1_b(2)     <= not( (cp1_192    and ex2_sh_lvl2(66)     ) or (cp1_208    and ex2_sh_lvl2(50)     ) );
r1_003:   ex2_sh16_r1_b(3)     <= not( (cp1_192    and ex2_sh_lvl2(67)     ) or (cp1_208    and ex2_sh_lvl2(51)     ) );
r1_004:   ex2_sh16_r1_b(4)     <= not(  cp1_208    and ex2_sh_lvl2(52)       );
r1_005:   ex2_sh16_r1_b(5)     <= not(  cp1_208    and ex2_sh_lvl2(53)       );
r1_006:   ex2_sh16_r1_b(6)     <= not(  cp1_208    and ex2_sh_lvl2(54)       );
r1_007:   ex2_sh16_r1_b(7)     <= not(  cp1_208    and ex2_sh_lvl2(55)       );
r1_008:   ex2_sh16_r1_b(8)     <= not(  cp1_208    and ex2_sh_lvl2(56)       );
r1_009:   ex2_sh16_r1_b(9)     <= not(  cp1_208    and ex2_sh_lvl2(57)       );
r1_010:   ex2_sh16_r1_b(10)    <= not(  cp1_208    and ex2_sh_lvl2(58)       );
r1_011:   ex2_sh16_r1_b(11)    <= not(  cp1_208    and ex2_sh_lvl2(59)       );
r1_012:   ex2_sh16_r1_b(12)    <= not(  cp1_208    and ex2_sh_lvl2(60)       );
r1_013:   ex2_sh16_r1_b(13)    <= not(  cp1_208    and ex2_sh_lvl2(61)       );
r1_014:   ex2_sh16_r1_b(14)    <= not(  cp1_208    and ex2_sh_lvl2(62)       );
r1_015:   ex2_sh16_r1_b(15)    <= not(  cp1_208    and ex2_sh_lvl2(63)       );

r1_016:   ex2_sh16_r1_b(16)    <= not( (cp2_208    and ex2_sh_lvl2(64)     ) or (cp2_224    and ex2_sh_lvl2(48)     ) );
r1_017:   ex2_sh16_r1_b(17)    <= not( (cp2_208    and ex2_sh_lvl2(65)     ) or (cp2_224    and ex2_sh_lvl2(49)     ) );
r1_018:   ex2_sh16_r1_b(18)    <= not( (cp2_208    and ex2_sh_lvl2(66)     ) or (cp2_224    and ex2_sh_lvl2(50)     ) );
r1_019:   ex2_sh16_r1_b(19)    <= not( (cp2_208    and ex2_sh_lvl2(67)     ) or (cp2_224    and ex2_sh_lvl2(51)     ) );
r1_020:   ex2_sh16_r1_b(20)    <= not(  cp2_224    and ex2_sh_lvl2(52)       );
r1_021:   ex2_sh16_r1_b(21)    <= not(  cp2_224    and ex2_sh_lvl2(53)       );
r1_022:   ex2_sh16_r1_b(22)    <= not(  cp2_224    and ex2_sh_lvl2(54)       );
r1_023:   ex2_sh16_r1_b(23)    <= not(  cp2_224    and ex2_sh_lvl2(55)       );
r1_024:   ex2_sh16_r1_b(24)    <= not(  cp2_224    and ex2_sh_lvl2(56)       );
r1_025:   ex2_sh16_r1_b(25)    <= not(  cp2_224    and ex2_sh_lvl2(57)       );
r1_026:   ex2_sh16_r1_b(26)    <= not(  cp2_224    and ex2_sh_lvl2(58)       );
r1_027:   ex2_sh16_r1_b(27)    <= not(  cp2_224    and ex2_sh_lvl2(59)       );
r1_028:   ex2_sh16_r1_b(28)    <= not(  cp2_224    and ex2_sh_lvl2(60)       );
r1_029:   ex2_sh16_r1_b(29)    <= not(  cp2_224    and ex2_sh_lvl2(61)       );
r1_030:   ex2_sh16_r1_b(30)    <= not(  cp2_224    and ex2_sh_lvl2(62)       );
r1_031:   ex2_sh16_r1_b(31)    <= not(  cp2_224    and ex2_sh_lvl2(63)       );

r1_032:   ex2_sh16_r1_b(32)    <= not( (cp3_224    and ex2_sh_lvl2(64)     ) or (cp3_240    and ex2_sh_lvl2(48)     ) );
r1_033:   ex2_sh16_r1_b(33)    <= not( (cp3_224    and ex2_sh_lvl2(65)     ) or (cp3_240    and ex2_sh_lvl2(49)     ) );
r1_034:   ex2_sh16_r1_b(34)    <= not( (cp3_224    and ex2_sh_lvl2(66)     ) or (cp3_240    and ex2_sh_lvl2(50)     ) );
r1_035:   ex2_sh16_r1_b(35)    <= not( (cp3_224    and ex2_sh_lvl2(67)     ) or (cp3_240    and ex2_sh_lvl2(51)     ) );
r1_036:   ex2_sh16_r1_b(36)    <= not(  cp3_240    and ex2_sh_lvl2(52)       );
r1_037:   ex2_sh16_r1_b(37)    <= not(  cp3_240    and ex2_sh_lvl2(53)       );
r1_038:   ex2_sh16_r1_b(38)    <= not(  cp3_240    and ex2_sh_lvl2(54)       );
r1_039:   ex2_sh16_r1_b(39)    <= not(  cp3_240    and ex2_sh_lvl2(55)       );
r1_040:   ex2_sh16_r1_b(40)    <= not(  cp3_240    and ex2_sh_lvl2(56)       );
r1_041:   ex2_sh16_r1_b(41)    <= not(  cp3_240    and ex2_sh_lvl2(57)       );
r1_042:   ex2_sh16_r1_b(42)    <= not(  cp3_240    and ex2_sh_lvl2(58)       );
r1_043:   ex2_sh16_r1_b(43)    <= not(  cp3_240    and ex2_sh_lvl2(59)       );
r1_044:   ex2_sh16_r1_b(44)    <= not(  cp3_240    and ex2_sh_lvl2(60)       );
r1_045:   ex2_sh16_r1_b(45)    <= not(  cp3_240    and ex2_sh_lvl2(61)       );
r1_046:   ex2_sh16_r1_b(46)    <= not(  cp3_240    and ex2_sh_lvl2(62)       );   
r1_047:   ex2_sh16_r1_b(47)    <= not(  cp3_240    and ex2_sh_lvl2(63)       );

r1_048:   ex2_sh16_r1_b(48)    <= not( (cp4_240    and ex2_sh_lvl2(64)     ) or (cp4_000    and ex2_sh_lvl2(48)     ) );
r1_049:   ex2_sh16_r1_b(49)    <= not( (cp4_240    and ex2_sh_lvl2(65)     ) or (cp4_000    and ex2_sh_lvl2(49)     ) );
r1_050:   ex2_sh16_r1_b(50)    <= not( (cp4_240    and ex2_sh_lvl2(66)     ) or (cp4_000    and ex2_sh_lvl2(50)     ) );
r1_051:   ex2_sh16_r1_b(51)    <= not( (cp4_240    and ex2_sh_lvl2(67)     ) or (cp4_000    and ex2_sh_lvl2(51)     ) );
r1_052:   ex2_sh16_r1_b(52)    <= not(  cp4_000    and ex2_sh_lvl2(52)       );
r1_053:   ex2_sh16_r1_b(53)    <= not(  cp4_000    and ex2_sh_lvl2(53)       );
r1_054:   ex2_sh16_r1_b(54)    <= not(  cp4_000    and ex2_sh_lvl2(54)       );
r1_055:   ex2_sh16_r1_b(55)    <= not(  cp4_000    and ex2_sh_lvl2(55)       );
r1_056:   ex2_sh16_r1_b(56)    <= not(  cp4_000    and ex2_sh_lvl2(56)       );
r1_057:   ex2_sh16_r1_b(57)    <= not(  cp4_000    and ex2_sh_lvl2(57)       );
r1_058:   ex2_sh16_r1_b(58)    <= not(  cp4_000    and ex2_sh_lvl2(58)       );  
r1_059:   ex2_sh16_r1_b(59)    <= not(  cp4_000    and ex2_sh_lvl2(59)       );
r1_060:   ex2_sh16_r1_b(60)    <= not(  cp4_000    and ex2_sh_lvl2(60)       );
r1_061:   ex2_sh16_r1_b(61)    <= not(  cp4_000    and ex2_sh_lvl2(61)       );
r1_062:   ex2_sh16_r1_b(62)    <= not(  cp4_000    and ex2_sh_lvl2(62)       );
r1_063:   ex2_sh16_r1_b(63)    <= not(  cp4_000    and ex2_sh_lvl2(63)       );

r1_064:   ex2_sh16_r1_b(64)    <= not( (cp5_000    and ex2_sh_lvl2(64)     ) or (cp4_016    and ex2_sh_lvl2(48)     ) );
r1_065:   ex2_sh16_r1_b(65)    <= not( (cp5_000    and ex2_sh_lvl2(65)     ) or (cp4_016    and ex2_sh_lvl2(49)     ) );
r1_066:   ex2_sh16_r1_b(66)    <= not( (cp5_000    and ex2_sh_lvl2(66)     ) or (cp4_016    and ex2_sh_lvl2(50)     ) );
r1_067:   ex2_sh16_r1_b(67)    <= not( (cp5_000    and ex2_sh_lvl2(67)     ) or (cp4_016    and ex2_sh_lvl2(51)     ) );
r1_068:   ex2_sh16_r1_b(68)    <= not(  cp4_016    and ex2_sh_lvl2(52)       );
r1_069:   ex2_sh16_r1_b(69)    <= not(  cp4_016    and ex2_sh_lvl2(53)       );
r1_070:   ex2_sh16_r1_b(70)    <= not(  cp4_016    and ex2_sh_lvl2(54)       );
r1_071:   ex2_sh16_r1_b(71)    <= not(  cp4_016    and ex2_sh_lvl2(55)       );
r1_072:   ex2_sh16_r1_b(72)    <= not(  cp4_016    and ex2_sh_lvl2(56)       );
r1_073:   ex2_sh16_r1_b(73)    <= not(  cp4_016    and ex2_sh_lvl2(57)       );
r1_074:   ex2_sh16_r1_b(74)    <= not(  cp4_016    and ex2_sh_lvl2(58)       );
r1_075:   ex2_sh16_r1_b(75)    <= not(  cp4_016    and ex2_sh_lvl2(59)       );
r1_076:   ex2_sh16_r1_b(76)    <= not(  cp4_016    and ex2_sh_lvl2(60)       );
r1_077:   ex2_sh16_r1_b(77)    <= not(  cp4_016    and ex2_sh_lvl2(61)       );
r1_078:   ex2_sh16_r1_b(78)    <= not(  cp4_016    and ex2_sh_lvl2(62)       );
r1_079:   ex2_sh16_r1_b(79)    <= not(  cp4_016    and ex2_sh_lvl2(63)       );

r1_080:   ex2_sh16_r1_b(80)    <= not( (cp5_016    and ex2_sh_lvl2(64)     ) or (cp4_032    and ex2_sh_lvl2(48)     ) );
r1_081:   ex2_sh16_r1_b(81)    <= not( (cp5_016    and ex2_sh_lvl2(65)     ) or (cp4_032    and ex2_sh_lvl2(49)     ) );
r1_082:   ex2_sh16_r1_b(82)    <= not( (cp5_016    and ex2_sh_lvl2(66)     ) or (cp4_032    and ex2_sh_lvl2(50)     ) );
r1_083:   ex2_sh16_r1_b(83)    <= not( (cp5_016    and ex2_sh_lvl2(67)     ) or (cp4_032    and ex2_sh_lvl2(51)     ) );
r1_084:   ex2_sh16_r1_b(84)    <= not(  cp4_032    and ex2_sh_lvl2(52)       );
r1_085:   ex2_sh16_r1_b(85)    <= not(  cp4_032    and ex2_sh_lvl2(53)       );
r1_086:   ex2_sh16_r1_b(86)    <= not(  cp4_032    and ex2_sh_lvl2(54)       );
r1_087:   ex2_sh16_r1_b(87)    <= not(  cp4_032    and ex2_sh_lvl2(55)       );
r1_088:   ex2_sh16_r1_b(88)    <= not(  cp4_032    and ex2_sh_lvl2(56)       );
r1_089:   ex2_sh16_r1_b(89)    <= not(  cp4_032    and ex2_sh_lvl2(57)       );
r1_090:   ex2_sh16_r1_b(90)    <= not(  cp4_032    and ex2_sh_lvl2(58)       );
r1_091:   ex2_sh16_r1_b(91)    <= not(  cp4_032    and ex2_sh_lvl2(59)       );
r1_092:   ex2_sh16_r1_b(92)    <= not(  cp4_032    and ex2_sh_lvl2(60)       );
r1_093:   ex2_sh16_r1_b(93)    <= not(  cp4_032    and ex2_sh_lvl2(61)       );
r1_094:   ex2_sh16_r1_b(94)    <= not(  cp4_032    and ex2_sh_lvl2(62)       );
r1_095:   ex2_sh16_r1_b(95)    <= not(  cp4_032    and ex2_sh_lvl2(63)       );

r1_096:   ex2_sh16_r1_b(96)    <= not( (cp5_032    and ex2_sh_lvl2(64)     ) or (cp4_048    and ex2_sh_lvl2(48)     ) );
r1_097:   ex2_sh16_r1_b(97)    <= not( (cp5_032    and ex2_sh_lvl2(65)     ) or (cp4_048    and ex2_sh_lvl2(49)     ) );
r1_098:   ex2_sh16_r1_b(98)    <= not( (cp5_032    and ex2_sh_lvl2(66)     ) or (cp4_048    and ex2_sh_lvl2(50)     ) );
r1_099:   ex2_sh16_r1_b(99)    <= not( (cp5_032    and ex2_sh_lvl2(67)     ) or (cp4_048    and ex2_sh_lvl2(51)     ) );
r1_100:   ex2_sh16_r1_b(100)   <= not(  cp4_048    and ex2_sh_lvl2(52)       );
r1_101:   ex2_sh16_r1_b(101)   <= not(  cp4_048    and ex2_sh_lvl2(53)       );
r1_102:   ex2_sh16_r1_b(102)   <= not(  cp4_048    and ex2_sh_lvl2(54)       );
r1_103:   ex2_sh16_r1_b(103)   <= not(  cp4_048    and ex2_sh_lvl2(55)       );
r1_104:   ex2_sh16_r1_b(104)   <= not(  cp4_048    and ex2_sh_lvl2(56)       );
r1_105:   ex2_sh16_r1_b(105)   <= not(  cp4_048    and ex2_sh_lvl2(57)       );
r1_106:   ex2_sh16_r1_b(106)   <= not(  cp4_048    and ex2_sh_lvl2(58)       );
r1_107:   ex2_sh16_r1_b(107)   <= not(  cp4_048    and ex2_sh_lvl2(59)       );
r1_108:   ex2_sh16_r1_b(108)   <= not(  cp4_048    and ex2_sh_lvl2(60)       );
r1_109:   ex2_sh16_r1_b(109)   <= not(  cp4_048    and ex2_sh_lvl2(61)       );
r1_110:   ex2_sh16_r1_b(110)   <= not(  cp4_048    and ex2_sh_lvl2(62)       );
r1_111:   ex2_sh16_r1_b(111)   <= not(  cp4_048    and ex2_sh_lvl2(63)       );

r1_112:   ex2_sh16_r1_b(112)   <= not( (cp5_048    and ex2_sh_lvl2(64)     ) or (cp4_064    and ex2_sh_lvl2(48)     ) );
r1_113:   ex2_sh16_r1_b(113)   <= not( (cp5_048    and ex2_sh_lvl2(65)     ) or (cp4_064    and ex2_sh_lvl2(49)     ) );
r1_114:   ex2_sh16_r1_b(114)   <= not( (cp5_048    and ex2_sh_lvl2(66)     ) or (cp4_064    and ex2_sh_lvl2(50)     ) );
r1_115:   ex2_sh16_r1_b(115)   <= not( (cp5_048    and ex2_sh_lvl2(67)     ) or (cp4_064    and ex2_sh_lvl2(51)     ) );
r1_116:   ex2_sh16_r1_b(116)   <= not(  cp4_064    and ex2_sh_lvl2(52)       );
r1_117:   ex2_sh16_r1_b(117)   <= not(  cp4_064    and ex2_sh_lvl2(53)       );
r1_118:   ex2_sh16_r1_b(118)   <= not(  cp4_064    and ex2_sh_lvl2(54)       );
r1_119:   ex2_sh16_r1_b(119)   <= not(  cp4_064    and ex2_sh_lvl2(55)       );
r1_120:   ex2_sh16_r1_b(120)   <= not(  cp4_064    and ex2_sh_lvl2(56)       );
r1_121:   ex2_sh16_r1_b(121)   <= not(  cp4_064    and ex2_sh_lvl2(57)       );
r1_122:   ex2_sh16_r1_b(122)   <= not(  cp4_064    and ex2_sh_lvl2(58)       );
r1_123:   ex2_sh16_r1_b(123)   <= not(  cp4_064    and ex2_sh_lvl2(59)       );
r1_124:   ex2_sh16_r1_b(124)   <= not(  cp4_064    and ex2_sh_lvl2(60)       );
r1_125:   ex2_sh16_r1_b(125)   <= not(  cp4_064    and ex2_sh_lvl2(61)       );
r1_126:   ex2_sh16_r1_b(126)   <= not(  cp4_064    and ex2_sh_lvl2(62)       );
r1_127:   ex2_sh16_r1_b(127)   <= not(  cp4_064    and ex2_sh_lvl2(63)       );      

r1_128:   ex2_sh16_r1_b(128)   <= not( (cp5_064    and ex2_sh_lvl2(64)     ) or (cp4_080    and ex2_sh_lvl2(48)     ) );
r1_129:   ex2_sh16_r1_b(129)   <= not( (cp5_064    and ex2_sh_lvl2(65)     ) or (cp4_080    and ex2_sh_lvl2(49)     ) );
r1_130:   ex2_sh16_r1_b(130)   <= not( (cp5_064    and ex2_sh_lvl2(66)     ) or (cp4_080    and ex2_sh_lvl2(50)     ) );
r1_131:   ex2_sh16_r1_b(131)   <= not( (cp5_064    and ex2_sh_lvl2(67)     ) or (cp4_080    and ex2_sh_lvl2(51)     ) );
r1_132:   ex2_sh16_r1_b(132)   <= not(  cp4_080    and ex2_sh_lvl2(52)       );
r1_133:   ex2_sh16_r1_b(133)   <= not(  cp4_080    and ex2_sh_lvl2(53)       );
r1_134:   ex2_sh16_r1_b(134)   <= not(  cp4_080    and ex2_sh_lvl2(54)       );
r1_135:   ex2_sh16_r1_b(135)   <= not(  cp4_080    and ex2_sh_lvl2(55)       );
r1_136:   ex2_sh16_r1_b(136)   <= not(  cp4_080    and ex2_sh_lvl2(56)       );
r1_137:   ex2_sh16_r1_b(137)   <= not(  cp4_080    and ex2_sh_lvl2(57)       );
r1_138:   ex2_sh16_r1_b(138)   <= not(  cp4_080    and ex2_sh_lvl2(58)       );
r1_139:   ex2_sh16_r1_b(139)   <= not(  cp4_080    and ex2_sh_lvl2(59)       );
r1_140:   ex2_sh16_r1_b(140)   <= not(  cp4_080    and ex2_sh_lvl2(60)       );
r1_141:   ex2_sh16_r1_b(141)   <= not(  cp4_080    and ex2_sh_lvl2(61)       );
r1_142:   ex2_sh16_r1_b(142)   <= not(  cp4_080    and ex2_sh_lvl2(62)       );
r1_143:   ex2_sh16_r1_b(143)   <= not(  cp4_080    and ex2_sh_lvl2(63)       );

r1_144:   ex2_sh16_r1_b(144)   <= not( (cp5_080    and ex2_sh_lvl2(64)     ) or (cp4_096    and ex2_sh_lvl2(48)     ) );
r1_145:   ex2_sh16_r1_b(145)   <= not( (cp5_080    and ex2_sh_lvl2(65)     ) or (cp4_096    and ex2_sh_lvl2(49)     ) );
r1_146:   ex2_sh16_r1_b(146)   <= not( (cp5_080    and ex2_sh_lvl2(66)     ) or (cp4_096    and ex2_sh_lvl2(50)     ) );
r1_147:   ex2_sh16_r1_b(147)   <= not( (cp5_080    and ex2_sh_lvl2(67)     ) or (cp4_096    and ex2_sh_lvl2(51)     ) );
r1_148:   ex2_sh16_r1_b(148)   <= not(  cp4_096    and ex2_sh_lvl2(52)       );
r1_149:   ex2_sh16_r1_b(149)   <= not(  cp4_096    and ex2_sh_lvl2(53)       );
r1_150:   ex2_sh16_r1_b(150)   <= not(  cp4_096    and ex2_sh_lvl2(54)       );
r1_151:   ex2_sh16_r1_b(151)   <= not(  cp4_096    and ex2_sh_lvl2(55)       );
r1_152:   ex2_sh16_r1_b(152)   <= not(  cp4_096    and ex2_sh_lvl2(56)       );
r1_153:   ex2_sh16_r1_b(153)   <= not(  cp4_096    and ex2_sh_lvl2(57)       );
r1_154:   ex2_sh16_r1_b(154)   <= not(  cp4_096    and ex2_sh_lvl2(58)       );
r1_155:   ex2_sh16_r1_b(155)   <= not(  cp4_096    and ex2_sh_lvl2(59)       );
r1_156:   ex2_sh16_r1_b(156)   <= not(  cp4_096    and ex2_sh_lvl2(60)       );
r1_157:   ex2_sh16_r1_b(157)   <= not(  cp4_096    and ex2_sh_lvl2(61)       );
r1_158:   ex2_sh16_r1_b(158)   <= not(  cp4_096    and ex2_sh_lvl2(62)       );
r1_159:   ex2_sh16_r1_b(159)   <= not(  cp4_096    and ex2_sh_lvl2(63)       );

r1_160:   ex2_sh16_r1_b(160)   <= not( (cp5_096    and ex2_sh_lvl2(64)     ) or (cp4_112    and ex2_sh_lvl2(48)     ) );
r1_161:   ex2_sh16_r1_b(161)   <= not( (cp5_096    and ex2_sh_lvl2(65)     ) or (cp4_112    and ex2_sh_lvl2(49)     ) );
r1_162:   ex2_sh16_r1_b(162)   <= not( (cp5_096    and ex2_sh_lvl2(66)     ) or (cp4_112    and ex2_sh_lvl2(50)     ) );

r2_000:   ex2_sh16_r2_b(0)     <= not( (cp1_224    and ex2_sh_lvl2(32)     ) or (cp1_240    and ex2_sh_lvl2(16)     ) );
r2_001:   ex2_sh16_r2_b(1)     <= not( (cp1_224    and ex2_sh_lvl2(33)     ) or (cp1_240    and ex2_sh_lvl2(17)     ) );
r2_002:   ex2_sh16_r2_b(2)     <= not( (cp1_224    and ex2_sh_lvl2(34)     ) or (cp1_240    and ex2_sh_lvl2(18)     ) );
r2_003:   ex2_sh16_r2_b(3)     <= not( (cp1_224    and ex2_sh_lvl2(35)     ) or (cp1_240    and ex2_sh_lvl2(19)     ) );
r2_004:   ex2_sh16_r2_b(4)     <= not( (cp1_224    and ex2_sh_lvl2(36)     ) or (cp1_240    and ex2_sh_lvl2(20)     ) );
r2_005:   ex2_sh16_r2_b(5)     <= not( (cp1_224    and ex2_sh_lvl2(37)     ) or (cp1_240    and ex2_sh_lvl2(21)     ) );
r2_006:   ex2_sh16_r2_b(6)     <= not( (cp1_224    and ex2_sh_lvl2(38)     ) or (cp1_240    and ex2_sh_lvl2(22)     ) );
r2_007:   ex2_sh16_r2_b(7)     <= not( (cp1_224    and ex2_sh_lvl2(39)     ) or (cp1_240    and ex2_sh_lvl2(23)     ) );
r2_008:   ex2_sh16_r2_b(8)     <= not( (cp1_224    and ex2_sh_lvl2(40)     ) or (cp1_240    and ex2_sh_lvl2(24)     ) );
r2_009:   ex2_sh16_r2_b(9)     <= not( (cp1_224    and ex2_sh_lvl2(41)     ) or (cp1_240    and ex2_sh_lvl2(25)     ) );
r2_010:   ex2_sh16_r2_b(10)    <= not( (cp1_224    and ex2_sh_lvl2(42)     ) or (cp1_240    and ex2_sh_lvl2(26)     ) );
r2_011:   ex2_sh16_r2_b(11)    <= not( (cp1_224    and ex2_sh_lvl2(43)     ) or (cp1_240    and ex2_sh_lvl2(27)     ) );
r2_012:   ex2_sh16_r2_b(12)    <= not( (cp1_224    and ex2_sh_lvl2(44)     ) or (cp1_240    and ex2_sh_lvl2(28)     ) );
r2_013:   ex2_sh16_r2_b(13)    <= not( (cp1_224    and ex2_sh_lvl2(45)     ) or (cp1_240    and ex2_sh_lvl2(29)     ) );
r2_014:   ex2_sh16_r2_b(14)    <= not( (cp1_224    and ex2_sh_lvl2(46)     ) or (cp1_240    and ex2_sh_lvl2(30)     ) );
r2_015:   ex2_sh16_r2_b(15)    <= not( (cp1_224    and ex2_sh_lvl2(47)     ) or (cp1_240    and ex2_sh_lvl2(31)     ) );

r2_016:   ex2_sh16_r2_b(16)    <= not( (cp2_240    and ex2_sh_lvl2(32)     ) or (cp2_000    and ex2_sh_lvl2(16)     ) );
r2_017:   ex2_sh16_r2_b(17)    <= not( (cp2_240    and ex2_sh_lvl2(33)     ) or (cp2_000    and ex2_sh_lvl2(17)     ) );
r2_018:   ex2_sh16_r2_b(18)    <= not( (cp2_240    and ex2_sh_lvl2(34)     ) or (cp2_000    and ex2_sh_lvl2(18)     ) );
r2_019:   ex2_sh16_r2_b(19)    <= not( (cp2_240    and ex2_sh_lvl2(35)     ) or (cp2_000    and ex2_sh_lvl2(19)     ) );
r2_020:   ex2_sh16_r2_b(20)    <= not( (cp2_240    and ex2_sh_lvl2(36)     ) or (cp2_000    and ex2_sh_lvl2(20)     ) );
r2_021:   ex2_sh16_r2_b(21)    <= not( (cp2_240    and ex2_sh_lvl2(37)     ) or (cp2_000    and ex2_sh_lvl2(21)     ) );
r2_022:   ex2_sh16_r2_b(22)    <= not( (cp2_240    and ex2_sh_lvl2(38)     ) or (cp2_000    and ex2_sh_lvl2(22)     ) );
r2_023:   ex2_sh16_r2_b(23)    <= not( (cp2_240    and ex2_sh_lvl2(39)     ) or (cp2_000    and ex2_sh_lvl2(23)     ) );
r2_024:   ex2_sh16_r2_b(24)    <= not( (cp2_240    and ex2_sh_lvl2(40)     ) or (cp2_000    and ex2_sh_lvl2(24)     ) );
r2_025:   ex2_sh16_r2_b(25)    <= not( (cp2_240    and ex2_sh_lvl2(41)     ) or (cp2_000    and ex2_sh_lvl2(25)     ) );
r2_026:   ex2_sh16_r2_b(26)    <= not( (cp2_240    and ex2_sh_lvl2(42)     ) or (cp2_000    and ex2_sh_lvl2(26)     ) );
r2_027:   ex2_sh16_r2_b(27)    <= not( (cp2_240    and ex2_sh_lvl2(43)     ) or (cp2_000    and ex2_sh_lvl2(27)     ) );
r2_028:   ex2_sh16_r2_b(28)    <= not( (cp2_240    and ex2_sh_lvl2(44)     ) or (cp2_000    and ex2_sh_lvl2(28)     ) );
r2_029:   ex2_sh16_r2_b(29)    <= not( (cp2_240    and ex2_sh_lvl2(45)     ) or (cp2_000    and ex2_sh_lvl2(29)     ) );
r2_030:   ex2_sh16_r2_b(30)    <= not( (cp2_240    and ex2_sh_lvl2(46)     ) or (cp2_000    and ex2_sh_lvl2(30)     ) );
r2_031:   ex2_sh16_r2_b(31)    <= not( (cp2_240    and ex2_sh_lvl2(47)     ) or (cp2_000    and ex2_sh_lvl2(31)     ) );

r2_032:   ex2_sh16_r2_b(32)    <= not( (cp3_000    and ex2_sh_lvl2(32)     ) or (cp2_016    and ex2_sh_lvl2(16)     ) );
r2_033:   ex2_sh16_r2_b(33)    <= not( (cp3_000    and ex2_sh_lvl2(33)     ) or (cp2_016    and ex2_sh_lvl2(17)     ) );
r2_034:   ex2_sh16_r2_b(34)    <= not( (cp3_000    and ex2_sh_lvl2(34)     ) or (cp2_016    and ex2_sh_lvl2(18)     ) );
r2_035:   ex2_sh16_r2_b(35)    <= not( (cp3_000    and ex2_sh_lvl2(35)     ) or (cp2_016    and ex2_sh_lvl2(19)     ) );
r2_036:   ex2_sh16_r2_b(36)    <= not( (cp3_000    and ex2_sh_lvl2(36)     ) or (cp2_016    and ex2_sh_lvl2(20)     ) );
r2_037:   ex2_sh16_r2_b(37)    <= not( (cp3_000    and ex2_sh_lvl2(37)     ) or (cp2_016    and ex2_sh_lvl2(21)     ) );
r2_038:   ex2_sh16_r2_b(38)    <= not( (cp3_000    and ex2_sh_lvl2(38)     ) or (cp2_016    and ex2_sh_lvl2(22)     ) );
r2_039:   ex2_sh16_r2_b(39)    <= not( (cp3_000    and ex2_sh_lvl2(39)     ) or (cp2_016    and ex2_sh_lvl2(23)     ) );
r2_040:   ex2_sh16_r2_b(40)    <= not( (cp3_000    and ex2_sh_lvl2(40)     ) or (cp2_016    and ex2_sh_lvl2(24)     ) );
r2_041:   ex2_sh16_r2_b(41)    <= not( (cp3_000    and ex2_sh_lvl2(41)     ) or (cp2_016    and ex2_sh_lvl2(25)     ) );
r2_042:   ex2_sh16_r2_b(42)    <= not( (cp3_000    and ex2_sh_lvl2(42)     ) or (cp2_016    and ex2_sh_lvl2(26)     ) );
r2_043:   ex2_sh16_r2_b(43)    <= not( (cp3_000    and ex2_sh_lvl2(43)     ) or (cp2_016    and ex2_sh_lvl2(27)     ) );
r2_044:   ex2_sh16_r2_b(44)    <= not( (cp3_000    and ex2_sh_lvl2(44)     ) or (cp2_016    and ex2_sh_lvl2(28)     ) );
r2_045:   ex2_sh16_r2_b(45)    <= not( (cp3_000    and ex2_sh_lvl2(45)     ) or (cp2_016    and ex2_sh_lvl2(29)     ) );
r2_046:   ex2_sh16_r2_b(46)    <= not( (cp3_000    and ex2_sh_lvl2(46)     ) or (cp2_016    and ex2_sh_lvl2(30)     ) );
r2_047:   ex2_sh16_r2_b(47)    <= not( (cp3_000    and ex2_sh_lvl2(47)     ) or (cp2_016    and ex2_sh_lvl2(31)     ) );

r2_048:   ex2_sh16_r2_b(48)    <= not( (cp3_016    and ex2_sh_lvl2(32)     ) or (cp2_032    and ex2_sh_lvl2(16)     ) );
r2_049:   ex2_sh16_r2_b(49)    <= not( (cp3_016    and ex2_sh_lvl2(33)     ) or (cp2_032    and ex2_sh_lvl2(17)     ) );
r2_050:   ex2_sh16_r2_b(50)    <= not( (cp3_016    and ex2_sh_lvl2(34)     ) or (cp2_032    and ex2_sh_lvl2(18)     ) );
r2_051:   ex2_sh16_r2_b(51)    <= not( (cp3_016    and ex2_sh_lvl2(35)     ) or (cp2_032    and ex2_sh_lvl2(19)     ) );
r2_052:   ex2_sh16_r2_b(52)    <= not( (cp3_016    and ex2_sh_lvl2(36)     ) or (cp2_032    and ex2_sh_lvl2(20)     ) );
r2_053:   ex2_sh16_r2_b(53)    <= not( (cp3_016    and ex2_sh_lvl2(37)     ) or (cp2_032    and ex2_sh_lvl2(21)     ) );
r2_054:   ex2_sh16_r2_b(54)    <= not( (cp3_016    and ex2_sh_lvl2(38)     ) or (cp2_032    and ex2_sh_lvl2(22)     ) );
r2_055:   ex2_sh16_r2_b(55)    <= not( (cp3_016    and ex2_sh_lvl2(39)     ) or (cp2_032    and ex2_sh_lvl2(23)     ) );
r2_056:   ex2_sh16_r2_b(56)    <= not( (cp3_016    and ex2_sh_lvl2(40)     ) or (cp2_032    and ex2_sh_lvl2(24)     ) );
r2_057:   ex2_sh16_r2_b(57)    <= not( (cp3_016    and ex2_sh_lvl2(41)     ) or (cp2_032    and ex2_sh_lvl2(25)     ) );
r2_058:   ex2_sh16_r2_b(58)    <= not( (cp3_016    and ex2_sh_lvl2(42)     ) or (cp2_032    and ex2_sh_lvl2(26)     ) );
r2_059:   ex2_sh16_r2_b(59)    <= not( (cp3_016    and ex2_sh_lvl2(43)     ) or (cp2_032    and ex2_sh_lvl2(27)     ) );
r2_060:   ex2_sh16_r2_b(60)    <= not( (cp3_016    and ex2_sh_lvl2(44)     ) or (cp2_032    and ex2_sh_lvl2(28)     ) );
r2_061:   ex2_sh16_r2_b(61)    <= not( (cp3_016    and ex2_sh_lvl2(45)     ) or (cp2_032    and ex2_sh_lvl2(29)     ) );
r2_062:   ex2_sh16_r2_b(62)    <= not( (cp3_016    and ex2_sh_lvl2(46)     ) or (cp2_032    and ex2_sh_lvl2(30)     ) );
r2_063:   ex2_sh16_r2_b(63)    <= not( (cp3_016    and ex2_sh_lvl2(47)     ) or (cp2_032    and ex2_sh_lvl2(31)     ) );

r2_064:   ex2_sh16_r2_b(64)    <= not( (cp3_032    and ex2_sh_lvl2(32)     ) or (cp2_048    and ex2_sh_lvl2(16)     ) );
r2_065:   ex2_sh16_r2_b(65)    <= not( (cp3_032    and ex2_sh_lvl2(33)     ) or (cp2_048    and ex2_sh_lvl2(17)     ) );
r2_066:   ex2_sh16_r2_b(66)    <= not( (cp3_032    and ex2_sh_lvl2(34)     ) or (cp2_048    and ex2_sh_lvl2(18)     ) );
r2_067:   ex2_sh16_r2_b(67)    <= not( (cp3_032    and ex2_sh_lvl2(35)     ) or (cp2_048    and ex2_sh_lvl2(19)     ) );
r2_068:   ex2_sh16_r2_b(68)    <= not( (cp3_032    and ex2_sh_lvl2(36)     ) or (cp2_048    and ex2_sh_lvl2(20)     ) );
r2_069:   ex2_sh16_r2_b(69)    <= not( (cp3_032    and ex2_sh_lvl2(37)     ) or (cp2_048    and ex2_sh_lvl2(21)     ) );
r2_070:   ex2_sh16_r2_b(70)    <= not( (cp3_032    and ex2_sh_lvl2(38)     ) or (cp2_048    and ex2_sh_lvl2(22)     ) );
r2_071:   ex2_sh16_r2_b(71)    <= not( (cp3_032    and ex2_sh_lvl2(39)     ) or (cp2_048    and ex2_sh_lvl2(23)     ) );
r2_072:   ex2_sh16_r2_b(72)    <= not( (cp3_032    and ex2_sh_lvl2(40)     ) or (cp2_048    and ex2_sh_lvl2(24)     ) );
r2_073:   ex2_sh16_r2_b(73)    <= not( (cp3_032    and ex2_sh_lvl2(41)     ) or (cp2_048    and ex2_sh_lvl2(25)     ) );
r2_074:   ex2_sh16_r2_b(74)    <= not( (cp3_032    and ex2_sh_lvl2(42)     ) or (cp2_048    and ex2_sh_lvl2(26)     ) );
r2_075:   ex2_sh16_r2_b(75)    <= not( (cp3_032    and ex2_sh_lvl2(43)     ) or (cp2_048    and ex2_sh_lvl2(27)     ) );
r2_076:   ex2_sh16_r2_b(76)    <= not( (cp3_032    and ex2_sh_lvl2(44)     ) or (cp2_048    and ex2_sh_lvl2(28)     ) );
r2_077:   ex2_sh16_r2_b(77)    <= not( (cp3_032    and ex2_sh_lvl2(45)     ) or (cp2_048    and ex2_sh_lvl2(29)     ) );
r2_078:   ex2_sh16_r2_b(78)    <= not( (cp3_032    and ex2_sh_lvl2(46)     ) or (cp2_048    and ex2_sh_lvl2(30)     ) );
r2_079:   ex2_sh16_r2_b(79)    <= not( (cp3_032    and ex2_sh_lvl2(47)     ) or (cp2_048    and ex2_sh_lvl2(31)     ) );

r2_080:   ex2_sh16_r2_b(80)    <= not( (cp3_048    and ex2_sh_lvl2(32)     ) or (cp2_064    and ex2_sh_lvl2(16)     ) );
r2_081:   ex2_sh16_r2_b(81)    <= not( (cp3_048    and ex2_sh_lvl2(33)     ) or (cp2_064    and ex2_sh_lvl2(17)     ) );
r2_082:   ex2_sh16_r2_b(82)    <= not( (cp3_048    and ex2_sh_lvl2(34)     ) or (cp2_064    and ex2_sh_lvl2(18)     ) );
r2_083:   ex2_sh16_r2_b(83)    <= not( (cp3_048    and ex2_sh_lvl2(35)     ) or (cp2_064    and ex2_sh_lvl2(19)     ) );
r2_084:   ex2_sh16_r2_b(84)    <= not( (cp3_048    and ex2_sh_lvl2(36)     ) or (cp2_064    and ex2_sh_lvl2(20)     ) );
r2_085:   ex2_sh16_r2_b(85)    <= not( (cp3_048    and ex2_sh_lvl2(37)     ) or (cp2_064    and ex2_sh_lvl2(21)     ) );
r2_086:   ex2_sh16_r2_b(86)    <= not( (cp3_048    and ex2_sh_lvl2(38)     ) or (cp2_064    and ex2_sh_lvl2(22)     ) );
r2_087:   ex2_sh16_r2_b(87)    <= not( (cp3_048    and ex2_sh_lvl2(39)     ) or (cp2_064    and ex2_sh_lvl2(23)     ) );
r2_088:   ex2_sh16_r2_b(88)    <= not( (cp3_048    and ex2_sh_lvl2(40)     ) or (cp2_064    and ex2_sh_lvl2(24)     ) );
r2_089:   ex2_sh16_r2_b(89)    <= not( (cp3_048    and ex2_sh_lvl2(41)     ) or (cp2_064    and ex2_sh_lvl2(25)     ) );
r2_090:   ex2_sh16_r2_b(90)    <= not( (cp3_048    and ex2_sh_lvl2(42)     ) or (cp2_064    and ex2_sh_lvl2(26)     ) );
r2_091:   ex2_sh16_r2_b(91)    <= not( (cp3_048    and ex2_sh_lvl2(43)     ) or (cp2_064    and ex2_sh_lvl2(27)     ) );
r2_092:   ex2_sh16_r2_b(92)    <= not( (cp3_048    and ex2_sh_lvl2(44)     ) or (cp2_064    and ex2_sh_lvl2(28)     ) );
r2_093:   ex2_sh16_r2_b(93)    <= not( (cp3_048    and ex2_sh_lvl2(45)     ) or (cp2_064    and ex2_sh_lvl2(29)     ) );
r2_094:   ex2_sh16_r2_b(94)    <= not( (cp3_048    and ex2_sh_lvl2(46)     ) or (cp2_064    and ex2_sh_lvl2(30)     ) );
r2_095:   ex2_sh16_r2_b(95)    <= not( (cp3_048    and ex2_sh_lvl2(47)     ) or (cp2_064    and ex2_sh_lvl2(31)     ) );

r2_096:   ex2_sh16_r2_b(96)    <= not( (cp3_064    and ex2_sh_lvl2(32)     ) or (cp2_080    and ex2_sh_lvl2(16)     ) );
r2_097:   ex2_sh16_r2_b(97)    <= not( (cp3_064    and ex2_sh_lvl2(33)     ) or (cp2_080    and ex2_sh_lvl2(17)     ) );
r2_098:   ex2_sh16_r2_b(98)    <= not( (cp3_064    and ex2_sh_lvl2(34)     ) or (cp2_080    and ex2_sh_lvl2(18)     ) );
r2_099:   ex2_sh16_r2_b(99)    <= not( (cp3_064    and ex2_sh_lvl2(35)     ) or (cp2_080    and ex2_sh_lvl2(19)     ) );
r2_100:   ex2_sh16_r2_b(100)   <= not( (cp3_064    and ex2_sh_lvl2(36)     ) or (cp2_080    and ex2_sh_lvl2(20)     ) );
r2_101:   ex2_sh16_r2_b(101)   <= not( (cp3_064    and ex2_sh_lvl2(37)     ) or (cp2_080    and ex2_sh_lvl2(21)     ) );
r2_102:   ex2_sh16_r2_b(102)   <= not( (cp3_064    and ex2_sh_lvl2(38)     ) or (cp2_080    and ex2_sh_lvl2(22)     ) );
r2_103:   ex2_sh16_r2_b(103)   <= not( (cp3_064    and ex2_sh_lvl2(39)     ) or (cp2_080    and ex2_sh_lvl2(23)     ) );
r2_104:   ex2_sh16_r2_b(104)   <= not( (cp3_064    and ex2_sh_lvl2(40)     ) or (cp2_080    and ex2_sh_lvl2(24)     ) );
r2_105:   ex2_sh16_r2_b(105)   <= not( (cp3_064    and ex2_sh_lvl2(41)     ) or (cp2_080    and ex2_sh_lvl2(25)     ) );
r2_106:   ex2_sh16_r2_b(106)   <= not( (cp3_064    and ex2_sh_lvl2(42)     ) or (cp2_080    and ex2_sh_lvl2(26)     ) );
r2_107:   ex2_sh16_r2_b(107)   <= not( (cp3_064    and ex2_sh_lvl2(43)     ) or (cp2_080    and ex2_sh_lvl2(27)     ) );
r2_108:   ex2_sh16_r2_b(108)   <= not( (cp3_064    and ex2_sh_lvl2(44)     ) or (cp2_080    and ex2_sh_lvl2(28)     ) );
r2_109:   ex2_sh16_r2_b(109)   <= not( (cp3_064    and ex2_sh_lvl2(45)     ) or (cp2_080    and ex2_sh_lvl2(29)     ) );
r2_110:   ex2_sh16_r2_b(110)   <= not( (cp3_064    and ex2_sh_lvl2(46)     ) or (cp2_080    and ex2_sh_lvl2(30)     ) );
r2_111:   ex2_sh16_r2_b(111)   <= not( (cp3_064    and ex2_sh_lvl2(47)     ) or (cp2_080    and ex2_sh_lvl2(31)     ) );

r2_112:   ex2_sh16_r2_b(112)   <= not( (cp3_080    and ex2_sh_lvl2(32)     ) or (cp2_096    and ex2_sh_lvl2(16)     ) );
r2_113:   ex2_sh16_r2_b(113)   <= not( (cp3_080    and ex2_sh_lvl2(33)     ) or (cp2_096    and ex2_sh_lvl2(17)     ) );
r2_114:   ex2_sh16_r2_b(114)   <= not( (cp3_080    and ex2_sh_lvl2(34)     ) or (cp2_096    and ex2_sh_lvl2(18)     ) );
r2_115:   ex2_sh16_r2_b(115)   <= not( (cp3_080    and ex2_sh_lvl2(35)     ) or (cp2_096    and ex2_sh_lvl2(19)     ) );
r2_116:   ex2_sh16_r2_b(116)   <= not( (cp3_080    and ex2_sh_lvl2(36)     ) or (cp2_096    and ex2_sh_lvl2(20)     ) );
r2_117:   ex2_sh16_r2_b(117)   <= not( (cp3_080    and ex2_sh_lvl2(37)     ) or (cp2_096    and ex2_sh_lvl2(21)     ) );
r2_118:   ex2_sh16_r2_b(118)   <= not( (cp3_080    and ex2_sh_lvl2(38)     ) or (cp2_096    and ex2_sh_lvl2(22)     ) );
r2_119:   ex2_sh16_r2_b(119)   <= not( (cp3_080    and ex2_sh_lvl2(39)     ) or (cp2_096    and ex2_sh_lvl2(23)     ) );
r2_120:   ex2_sh16_r2_b(120)   <= not( (cp3_080    and ex2_sh_lvl2(40)     ) or (cp2_096    and ex2_sh_lvl2(24)     ) );
r2_121:   ex2_sh16_r2_b(121)   <= not( (cp3_080    and ex2_sh_lvl2(41)     ) or (cp2_096    and ex2_sh_lvl2(25)     ) );
r2_122:   ex2_sh16_r2_b(122)   <= not( (cp3_080    and ex2_sh_lvl2(42)     ) or (cp2_096    and ex2_sh_lvl2(26)     ) );
r2_123:   ex2_sh16_r2_b(123)   <= not( (cp3_080    and ex2_sh_lvl2(43)     ) or (cp2_096    and ex2_sh_lvl2(27)     ) );
r2_124:   ex2_sh16_r2_b(124)   <= not( (cp3_080    and ex2_sh_lvl2(44)     ) or (cp2_096    and ex2_sh_lvl2(28)     ) );
r2_125:   ex2_sh16_r2_b(125)   <= not( (cp3_080    and ex2_sh_lvl2(45)     ) or (cp2_096    and ex2_sh_lvl2(29)     ) );
r2_126:   ex2_sh16_r2_b(126)   <= not( (cp3_080    and ex2_sh_lvl2(46)     ) or (cp2_096    and ex2_sh_lvl2(30)     ) );
r2_127:   ex2_sh16_r2_b(127)   <= not( (cp3_080    and ex2_sh_lvl2(47)     ) or (cp2_096    and ex2_sh_lvl2(31)     ) );

r2_128:   ex2_sh16_r2_b(128)   <= not( (cp3_096    and ex2_sh_lvl2(32)     ) or (cp2_112    and ex2_sh_lvl2(16)     ) );
r2_129:   ex2_sh16_r2_b(129)   <= not( (cp3_096    and ex2_sh_lvl2(33)     ) or (cp2_112    and ex2_sh_lvl2(17)     ) );
r2_130:   ex2_sh16_r2_b(130)   <= not( (cp3_096    and ex2_sh_lvl2(34)     ) or (cp2_112    and ex2_sh_lvl2(18)     ) );
r2_131:   ex2_sh16_r2_b(131)   <= not( (cp3_096    and ex2_sh_lvl2(35)     ) or (cp2_112    and ex2_sh_lvl2(19)     ) );
r2_132:   ex2_sh16_r2_b(132)   <= not( (cp3_096    and ex2_sh_lvl2(36)     ) or (cp2_112    and ex2_sh_lvl2(20)     ) );
r2_133:   ex2_sh16_r2_b(133)   <= not( (cp3_096    and ex2_sh_lvl2(37)     ) or (cp2_112    and ex2_sh_lvl2(21)     ) );
r2_134:   ex2_sh16_r2_b(134)   <= not( (cp3_096    and ex2_sh_lvl2(38)     ) or (cp2_112    and ex2_sh_lvl2(22)     ) );
r2_135:   ex2_sh16_r2_b(135)   <= not( (cp3_096    and ex2_sh_lvl2(39)     ) or (cp2_112    and ex2_sh_lvl2(23)     ) );
r2_136:   ex2_sh16_r2_b(136)   <= not( (cp3_096    and ex2_sh_lvl2(40)     ) or (cp2_112    and ex2_sh_lvl2(24)     ) );
r2_137:   ex2_sh16_r2_b(137)   <= not( (cp3_096    and ex2_sh_lvl2(41)     ) or (cp2_112    and ex2_sh_lvl2(25)     ) );
r2_138:   ex2_sh16_r2_b(138)   <= not( (cp3_096    and ex2_sh_lvl2(42)     ) or (cp2_112    and ex2_sh_lvl2(26)     ) );
r2_139:   ex2_sh16_r2_b(139)   <= not( (cp3_096    and ex2_sh_lvl2(43)     ) or (cp2_112    and ex2_sh_lvl2(27)     ) );
r2_140:   ex2_sh16_r2_b(140)   <= not( (cp3_096    and ex2_sh_lvl2(44)     ) or (cp2_112    and ex2_sh_lvl2(28)     ) );
r2_141:   ex2_sh16_r2_b(141)   <= not( (cp3_096    and ex2_sh_lvl2(45)     ) or (cp2_112    and ex2_sh_lvl2(29)     ) );
r2_142:   ex2_sh16_r2_b(142)   <= not( (cp3_096    and ex2_sh_lvl2(46)     ) or (cp2_112    and ex2_sh_lvl2(30)     ) );
r2_143:   ex2_sh16_r2_b(143)   <= not( (cp3_096    and ex2_sh_lvl2(47)     ) or (cp2_112    and ex2_sh_lvl2(31)     ) );

r2_144:   ex2_sh16_r2_b(144)   <= not( (cp3_112    and ex2_sh_lvl2(32)     ) or (cp2_128    and ex2_sh_lvl2(16)     ) );
r2_145:   ex2_sh16_r2_b(145)   <= not( (cp3_112    and ex2_sh_lvl2(33)     ) or (cp2_128    and ex2_sh_lvl2(17)     ) );
r2_146:   ex2_sh16_r2_b(146)   <= not( (cp3_112    and ex2_sh_lvl2(34)     ) or (cp2_128    and ex2_sh_lvl2(18)     ) );
r2_147:   ex2_sh16_r2_b(147)   <= not( (cp3_112    and ex2_sh_lvl2(35)     ) or (cp2_128    and ex2_sh_lvl2(19)     ) );
r2_148:   ex2_sh16_r2_b(148)   <= not( (cp3_112    and ex2_sh_lvl2(36)     ) or (cp2_128    and ex2_sh_lvl2(20)     ) );
r2_149:   ex2_sh16_r2_b(149)   <= not( (cp3_112    and ex2_sh_lvl2(37)     ) or (cp2_128    and ex2_sh_lvl2(21)     ) );
r2_150:   ex2_sh16_r2_b(150)   <= not( (cp3_112    and ex2_sh_lvl2(38)     ) or (cp2_128    and ex2_sh_lvl2(22)     ) );
r2_151:   ex2_sh16_r2_b(151)   <= not( (cp3_112    and ex2_sh_lvl2(39)     ) or (cp2_128    and ex2_sh_lvl2(23)     ) );
r2_152:   ex2_sh16_r2_b(152)   <= not( (cp3_112    and ex2_sh_lvl2(40)     ) or (cp2_128    and ex2_sh_lvl2(24)     ) );
r2_153:   ex2_sh16_r2_b(153)   <= not( (cp3_112    and ex2_sh_lvl2(41)     ) or (cp2_128    and ex2_sh_lvl2(25)     ) );
r2_154:   ex2_sh16_r2_b(154)   <= not( (cp3_112    and ex2_sh_lvl2(42)     ) or (cp2_128    and ex2_sh_lvl2(26)     ) );
r2_155:   ex2_sh16_r2_b(155)   <= not( (cp3_112    and ex2_sh_lvl2(43)     ) or (cp2_128    and ex2_sh_lvl2(27)     ) );
r2_156:   ex2_sh16_r2_b(156)   <= not( (cp3_112    and ex2_sh_lvl2(44)     ) or (cp2_128    and ex2_sh_lvl2(28)     ) );
r2_157:   ex2_sh16_r2_b(157)   <= not( (cp3_112    and ex2_sh_lvl2(45)     ) or (cp2_128    and ex2_sh_lvl2(29)     ) );
r2_158:   ex2_sh16_r2_b(158)   <= not( (cp3_112    and ex2_sh_lvl2(46)     ) or (cp2_128    and ex2_sh_lvl2(30)     ) );
r2_159:   ex2_sh16_r2_b(159)   <= not( (cp3_112    and ex2_sh_lvl2(47)     ) or (cp2_128    and ex2_sh_lvl2(31)     ) );

r2_160:   ex2_sh16_r2_b(160)   <= not( (cp3_128    and ex2_sh_lvl2(32)     ) or (cp2_144    and ex2_sh_lvl2(16)     ) );
r2_161:   ex2_sh16_r2_b(161)   <= not( (cp3_128    and ex2_sh_lvl2(33)     ) or (cp2_144    and ex2_sh_lvl2(17)     ) );
r2_162:   ex2_sh16_r2_b(162)   <= not( (cp3_128    and ex2_sh_lvl2(34)     ) or (cp2_144    and ex2_sh_lvl2(18)     ) );

r3_000:   ex2_sh16_r3_b(0)     <= not(  cp1_000    and ex2_sh_lvl2(0)        );
r3_001:   ex2_sh16_r3_b(1)     <= not(  cp1_000    and ex2_sh_lvl2(1)        );
r3_002:   ex2_sh16_r3_b(2)     <= not(  cp1_000    and ex2_sh_lvl2(2)        );
r3_003:   ex2_sh16_r3_b(3)     <= not(  cp1_000    and ex2_sh_lvl2(3)        );
r3_004:   ex2_sh16_r3_b(4)     <= not(  cp1_000    and ex2_sh_lvl2(4)        );
r3_005:   ex2_sh16_r3_b(5)     <= not(  cp1_000    and ex2_sh_lvl2(5)        );
r3_006:   ex2_sh16_r3_b(6)     <= not(  cp1_000    and ex2_sh_lvl2(6)        );
r3_007:   ex2_sh16_r3_b(7)     <= not(  cp1_000    and ex2_sh_lvl2(7)        );
r3_008:   ex2_sh16_r3_b(8)     <= not(  cp1_000    and ex2_sh_lvl2(8)        );
r3_009:   ex2_sh16_r3_b(9)     <= not(  cp1_000    and ex2_sh_lvl2(9)        );
r3_010:   ex2_sh16_r3_b(10)    <= not(  cp1_000    and ex2_sh_lvl2(10)       );
r3_011:   ex2_sh16_r3_b(11)    <= not(  cp1_000    and ex2_sh_lvl2(11)       );
r3_012:   ex2_sh16_r3_b(12)    <= not(  cp1_000    and ex2_sh_lvl2(12)       );
r3_013:   ex2_sh16_r3_b(13)    <= not(  cp1_000    and ex2_sh_lvl2(13)       );
r3_014:   ex2_sh16_r3_b(14)    <= not(  cp1_000    and ex2_sh_lvl2(14)       );
r3_015:   ex2_sh16_r3_b(15)    <= not(  cp1_000    and ex2_sh_lvl2(15)       );

r3_016:   ex2_sh16_r3_b(16)    <= not(  cp1_016    and ex2_sh_lvl2(0)        );
r3_017:   ex2_sh16_r3_b(17)    <= not(  cp1_016    and ex2_sh_lvl2(1)        );
r3_018:   ex2_sh16_r3_b(18)    <= not(  cp1_016    and ex2_sh_lvl2(2)        );
r3_019:   ex2_sh16_r3_b(19)    <= not(  cp1_016    and ex2_sh_lvl2(3)        );
r3_020:   ex2_sh16_r3_b(20)    <= not(  cp1_016    and ex2_sh_lvl2(4)        );
r3_021:   ex2_sh16_r3_b(21)    <= not(  cp1_016    and ex2_sh_lvl2(5)        );
r3_022:   ex2_sh16_r3_b(22)    <= not(  cp1_016    and ex2_sh_lvl2(6)        );
r3_023:   ex2_sh16_r3_b(23)    <= not(  cp1_016    and ex2_sh_lvl2(7)        );
r3_024:   ex2_sh16_r3_b(24)    <= not(  cp1_016    and ex2_sh_lvl2(8)        );
r3_025:   ex2_sh16_r3_b(25)    <= not(  cp1_016    and ex2_sh_lvl2(9)        );
r3_026:   ex2_sh16_r3_b(26)    <= not(  cp1_016    and ex2_sh_lvl2(10)       );
r3_027:   ex2_sh16_r3_b(27)    <= not(  cp1_016    and ex2_sh_lvl2(11)       );
r3_028:   ex2_sh16_r3_b(28)    <= not(  cp1_016    and ex2_sh_lvl2(12)       );
r3_029:   ex2_sh16_r3_b(29)    <= not(  cp1_016    and ex2_sh_lvl2(13)       );
r3_030:   ex2_sh16_r3_b(30)    <= not(  cp1_016    and ex2_sh_lvl2(14)       );
r3_031:   ex2_sh16_r3_b(31)    <= not(  cp1_016    and ex2_sh_lvl2(15)       );

r3_032:   ex2_sh16_r3_b(32)    <= not(  cp1_032    and ex2_sh_lvl2(0)        );
r3_033:   ex2_sh16_r3_b(33)    <= not(  cp1_032    and ex2_sh_lvl2(1)        );
r3_034:   ex2_sh16_r3_b(34)    <= not(  cp1_032    and ex2_sh_lvl2(2)        );
r3_035:   ex2_sh16_r3_b(35)    <= not(  cp1_032    and ex2_sh_lvl2(3)        );
r3_036:   ex2_sh16_r3_b(36)    <= not(  cp1_032    and ex2_sh_lvl2(4)        );
r3_037:   ex2_sh16_r3_b(37)    <= not(  cp1_032    and ex2_sh_lvl2(5)        );
r3_038:   ex2_sh16_r3_b(38)    <= not(  cp1_032    and ex2_sh_lvl2(6)        );
r3_039:   ex2_sh16_r3_b(39)    <= not(  cp1_032    and ex2_sh_lvl2(7)        );
r3_040:   ex2_sh16_r3_b(40)    <= not(  cp1_032    and ex2_sh_lvl2(8)        );
r3_041:   ex2_sh16_r3_b(41)    <= not(  cp1_032    and ex2_sh_lvl2(9)        );
r3_042:   ex2_sh16_r3_b(42)    <= not(  cp1_032    and ex2_sh_lvl2(10)       );
r3_043:   ex2_sh16_r3_b(43)    <= not(  cp1_032    and ex2_sh_lvl2(11)       );
r3_044:   ex2_sh16_r3_b(44)    <= not(  cp1_032    and ex2_sh_lvl2(12)       );
r3_045:   ex2_sh16_r3_b(45)    <= not(  cp1_032    and ex2_sh_lvl2(13)       );
r3_046:   ex2_sh16_r3_b(46)    <= not(  cp1_032    and ex2_sh_lvl2(14)       );
r3_047:   ex2_sh16_r3_b(47)    <= not(  cp1_032    and ex2_sh_lvl2(15)       );

r3_048:   ex2_sh16_r3_b(48)    <= not(  cp1_048    and ex2_sh_lvl2(0)        );
r3_049:   ex2_sh16_r3_b(49)    <= not(  cp1_048    and ex2_sh_lvl2(1)        );
r3_050:   ex2_sh16_r3_b(50)    <= not(  cp1_048    and ex2_sh_lvl2(2)        );
r3_051:   ex2_sh16_r3_b(51)    <= not(  cp1_048    and ex2_sh_lvl2(3)        );
r3_052:   ex2_sh16_r3_b(52)    <= not(  cp1_048    and ex2_sh_lvl2(4)        );
r3_053:   ex2_sh16_r3_b(53)    <= not(  cp1_048    and ex2_sh_lvl2(5)        );
r3_054:   ex2_sh16_r3_b(54)    <= not(  cp1_048    and ex2_sh_lvl2(6)        );
r3_055:   ex2_sh16_r3_b(55)    <= not(  cp1_048    and ex2_sh_lvl2(7)        );
r3_056:   ex2_sh16_r3_b(56)    <= not(  cp1_048    and ex2_sh_lvl2(8)        );
r3_057:   ex2_sh16_r3_b(57)    <= not(  cp1_048    and ex2_sh_lvl2(9)        );
r3_058:   ex2_sh16_r3_b(58)    <= not(  cp1_048    and ex2_sh_lvl2(10)       );
r3_059:   ex2_sh16_r3_b(59)    <= not(  cp1_048    and ex2_sh_lvl2(11)       );
r3_060:   ex2_sh16_r3_b(60)    <= not(  cp1_048    and ex2_sh_lvl2(12)       );
r3_061:   ex2_sh16_r3_b(61)    <= not(  cp1_048    and ex2_sh_lvl2(13)       );
r3_062:   ex2_sh16_r3_b(62)    <= not(  cp1_048    and ex2_sh_lvl2(14)       );
r3_063:   ex2_sh16_r3_b(63)    <= not(  cp1_048    and ex2_sh_lvl2(15)       );

r3_064:   ex2_sh16_r3_b(64)    <= not(  cp1_064    and ex2_sh_lvl2(0)        );
r3_065:   ex2_sh16_r3_b(65)    <= not(  cp1_064    and ex2_sh_lvl2(1)        );
r3_066:   ex2_sh16_r3_b(66)    <= not(  cp1_064    and ex2_sh_lvl2(2)        );
r3_067:   ex2_sh16_r3_b(67)    <= not(  cp1_064    and ex2_sh_lvl2(3)        );
r3_068:   ex2_sh16_r3_b(68)    <= not(  cp1_064    and ex2_sh_lvl2(4)        );
r3_069:   ex2_sh16_r3_b(69)    <= not(  cp1_064    and ex2_sh_lvl2(5)        );
r3_070:   ex2_sh16_r3_b(70)    <= not(  cp1_064    and ex2_sh_lvl2(6)        );
r3_071:   ex2_sh16_r3_b(71)    <= not(  cp1_064    and ex2_sh_lvl2(7)        );
r3_072:   ex2_sh16_r3_b(72)    <= not(  cp1_064    and ex2_sh_lvl2(8)        );
r3_073:   ex2_sh16_r3_b(73)    <= not(  cp1_064    and ex2_sh_lvl2(9)        );
r3_074:   ex2_sh16_r3_b(74)    <= not(  cp1_064    and ex2_sh_lvl2(10)       );
r3_075:   ex2_sh16_r3_b(75)    <= not(  cp1_064    and ex2_sh_lvl2(11)       );
r3_076:   ex2_sh16_r3_b(76)    <= not(  cp1_064    and ex2_sh_lvl2(12)       );
r3_077:   ex2_sh16_r3_b(77)    <= not(  cp1_064    and ex2_sh_lvl2(13)       );
r3_078:   ex2_sh16_r3_b(78)    <= not(  cp1_064    and ex2_sh_lvl2(14)       );
r3_079:   ex2_sh16_r3_b(79)    <= not(  cp1_064    and ex2_sh_lvl2(15)       );

r3_080:   ex2_sh16_r3_b(80)    <= not(  cp1_080    and ex2_sh_lvl2(0)        );
r3_081:   ex2_sh16_r3_b(81)    <= not(  cp1_080    and ex2_sh_lvl2(1)        );
r3_082:   ex2_sh16_r3_b(82)    <= not(  cp1_080    and ex2_sh_lvl2(2)        );
r3_083:   ex2_sh16_r3_b(83)    <= not(  cp1_080    and ex2_sh_lvl2(3)        );
r3_084:   ex2_sh16_r3_b(84)    <= not(  cp1_080    and ex2_sh_lvl2(4)        );
r3_085:   ex2_sh16_r3_b(85)    <= not(  cp1_080    and ex2_sh_lvl2(5)        );
r3_086:   ex2_sh16_r3_b(86)    <= not(  cp1_080    and ex2_sh_lvl2(6)        );
r3_087:   ex2_sh16_r3_b(87)    <= not(  cp1_080    and ex2_sh_lvl2(7)        );
r3_088:   ex2_sh16_r3_b(88)    <= not(  cp1_080    and ex2_sh_lvl2(8)        );
r3_089:   ex2_sh16_r3_b(89)    <= not(  cp1_080    and ex2_sh_lvl2(9)        );
r3_090:   ex2_sh16_r3_b(90)    <= not(  cp1_080    and ex2_sh_lvl2(10)       );
r3_091:   ex2_sh16_r3_b(91)    <= not(  cp1_080    and ex2_sh_lvl2(11)       );
r3_092:   ex2_sh16_r3_b(92)    <= not(  cp1_080    and ex2_sh_lvl2(12)       );
r3_093:   ex2_sh16_r3_b(93)    <= not(  cp1_080    and ex2_sh_lvl2(13)       );
r3_094:   ex2_sh16_r3_b(94)    <= not(  cp1_080    and ex2_sh_lvl2(14)       );
r3_095:   ex2_sh16_r3_b(95)    <= not(  cp1_080    and ex2_sh_lvl2(15)       );

r3_096:   ex2_sh16_r3_b(96)    <= not(  cp1_096    and ex2_sh_lvl2(0)      ) ;
r3_097:   ex2_sh16_r3_b(97)    <= not(  cp1_096    and ex2_sh_lvl2(1)      ) ;
r3_098:   ex2_sh16_r3_b(98)    <= not(  cp1_096    and ex2_sh_lvl2(2)      ) ;
r3_099:   ex2_sh16_r3_b(99)    <= not( (cp1_096    and ex2_sh_lvl2(3)      ) or (cp1_spc      and ex2_special(99)     ) );
r3_100:   ex2_sh16_r3_b(100)   <= not( (cp1_096    and ex2_sh_lvl2(4)      ) or (cp1_spc      and ex2_special(100)    ) );
r3_101:   ex2_sh16_r3_b(101)   <= not( (cp1_096    and ex2_sh_lvl2(5)      ) or (cp1_spc      and ex2_special(101)    ) );
r3_102:   ex2_sh16_r3_b(102)   <= not( (cp1_096    and ex2_sh_lvl2(6)      ) or (cp1_spc      and ex2_special(102)    ) );
r3_103:   ex2_sh16_r3_b(103)   <= not( (cp1_096    and ex2_sh_lvl2(7)      ) or (cp1_spc      and ex2_special(103)    ) );
r3_104:   ex2_sh16_r3_b(104)   <= not( (cp1_096    and ex2_sh_lvl2(8)      ) or (cp1_spc      and ex2_special(104)    ) );
r3_105:   ex2_sh16_r3_b(105)   <= not( (cp1_096    and ex2_sh_lvl2(9)      ) or (cp1_spc      and ex2_special(105)    ) );
r3_106:   ex2_sh16_r3_b(106)   <= not( (cp1_096    and ex2_sh_lvl2(10)     ) or (cp1_spc      and ex2_special(106)    ) );
r3_107:   ex2_sh16_r3_b(107)   <= not( (cp1_096    and ex2_sh_lvl2(11)     ) or (cp1_spc      and ex2_special(107)    ) );
r3_108:   ex2_sh16_r3_b(108)   <= not( (cp1_096    and ex2_sh_lvl2(12)     ) or (cp1_spc      and ex2_special(108)    ) );
r3_109:   ex2_sh16_r3_b(109)   <= not( (cp1_096    and ex2_sh_lvl2(13)     ) or (cp1_spc      and ex2_special(109)    ) );
r3_110:   ex2_sh16_r3_b(110)   <= not( (cp1_096    and ex2_sh_lvl2(14)     ) or (cp1_spc      and ex2_special(110)    ) );
r3_111:   ex2_sh16_r3_b(111)   <= not( (cp1_096    and ex2_sh_lvl2(15)     ) or (cp1_spc      and ex2_special(111)    ) );

r3_112:   ex2_sh16_r3_b(112)   <= not( (cp1_112    and ex2_sh_lvl2(0)      ) or (cp2_spc      and ex2_special(112)    ) );
r3_113:   ex2_sh16_r3_b(113)   <= not( (cp1_112    and ex2_sh_lvl2(1)      ) or (cp2_spc      and ex2_special(113)    ) );
r3_114:   ex2_sh16_r3_b(114)   <= not( (cp1_112    and ex2_sh_lvl2(2)      ) or (cp2_spc      and ex2_special(114)    ) );
r3_115:   ex2_sh16_r3_b(115)   <= not( (cp1_112    and ex2_sh_lvl2(3)      ) or (cp2_spc      and ex2_special(115)    ) );
r3_116:   ex2_sh16_r3_b(116)   <= not( (cp1_112    and ex2_sh_lvl2(4)      ) or (cp2_spc      and ex2_special(116)    ) );
r3_117:   ex2_sh16_r3_b(117)   <= not( (cp1_112    and ex2_sh_lvl2(5)      ) or (cp2_spc      and ex2_special(117)    ) );
r3_118:   ex2_sh16_r3_b(118)   <= not( (cp1_112    and ex2_sh_lvl2(6)      ) or (cp2_spc      and ex2_special(118)    ) );
r3_119:   ex2_sh16_r3_b(119)   <= not( (cp1_112    and ex2_sh_lvl2(7)      ) or (cp2_spc      and ex2_special(119)    ) );
r3_120:   ex2_sh16_r3_b(120)   <= not( (cp1_112    and ex2_sh_lvl2(8)      ) or (cp2_spc      and ex2_special(120)    ) );
r3_121:   ex2_sh16_r3_b(121)   <= not( (cp1_112    and ex2_sh_lvl2(9)      ) or (cp2_spc      and ex2_special(121)    ) );
r3_122:   ex2_sh16_r3_b(122)   <= not( (cp1_112    and ex2_sh_lvl2(10)     ) or (cp2_spc      and ex2_special(122)    ) );
r3_123:   ex2_sh16_r3_b(123)   <= not( (cp1_112    and ex2_sh_lvl2(11)     ) or (cp2_spc      and ex2_special(123)    ) );
r3_124:   ex2_sh16_r3_b(124)   <= not( (cp1_112    and ex2_sh_lvl2(12)     ) or (cp2_spc      and ex2_special(124)    ) );
r3_125:   ex2_sh16_r3_b(125)   <= not( (cp1_112    and ex2_sh_lvl2(13)     ) or (cp2_spc      and ex2_special(125)    ) );
r3_126:   ex2_sh16_r3_b(126)   <= not( (cp1_112    and ex2_sh_lvl2(14)     ) or (cp2_spc      and ex2_special(126)    ) );
r3_127:   ex2_sh16_r3_b(127)   <= not( (cp1_112    and ex2_sh_lvl2(15)     ) or (cp2_spc      and ex2_special(127)    ) );

r3_128:   ex2_sh16_r3_b(128)   <= not( (cp1_128    and ex2_sh_lvl2(0)      ) or (cp3_spc      and ex2_special(128)    ) );
r3_129:   ex2_sh16_r3_b(129)   <= not( (cp1_128    and ex2_sh_lvl2(1)      ) or (cp3_spc      and ex2_special(129)    ) );
r3_130:   ex2_sh16_r3_b(130)   <= not( (cp1_128    and ex2_sh_lvl2(2)      ) or (cp3_spc      and ex2_special(130)    ) );
r3_131:   ex2_sh16_r3_b(131)   <= not( (cp1_128    and ex2_sh_lvl2(3)      ) or (cp3_spc      and ex2_special(131)    ) );
r3_132:   ex2_sh16_r3_b(132)   <= not( (cp1_128    and ex2_sh_lvl2(4)      ) or (cp3_spc      and ex2_special(132)    ) );
r3_133:   ex2_sh16_r3_b(133)   <= not( (cp1_128    and ex2_sh_lvl2(5)      ) or (cp3_spc      and ex2_special(133)    ) );
r3_134:   ex2_sh16_r3_b(134)   <= not( (cp1_128    and ex2_sh_lvl2(6)      ) or (cp3_spc      and ex2_special(134)    ) );
r3_135:   ex2_sh16_r3_b(135)   <= not( (cp1_128    and ex2_sh_lvl2(7)      ) or (cp3_spc      and ex2_special(135)    ) );
r3_136:   ex2_sh16_r3_b(136)   <= not( (cp1_128    and ex2_sh_lvl2(8)      ) or (cp3_spc      and ex2_special(136)    ) );
r3_137:   ex2_sh16_r3_b(137)   <= not( (cp1_128    and ex2_sh_lvl2(9)      ) or (cp3_spc      and ex2_special(137)    ) );
r3_138:   ex2_sh16_r3_b(138)   <= not( (cp1_128    and ex2_sh_lvl2(10)     ) or (cp3_spc      and ex2_special(138)    ) );
r3_139:   ex2_sh16_r3_b(139)   <= not( (cp1_128    and ex2_sh_lvl2(11)     ) or (cp3_spc      and ex2_special(139)    ) );
r3_140:   ex2_sh16_r3_b(140)   <= not( (cp1_128    and ex2_sh_lvl2(12)     ) or (cp3_spc      and ex2_special(140)    ) );
r3_141:   ex2_sh16_r3_b(141)   <= not( (cp1_128    and ex2_sh_lvl2(13)     ) or (cp3_spc      and ex2_special(141)    ) );
r3_142:   ex2_sh16_r3_b(142)   <= not( (cp1_128    and ex2_sh_lvl2(14)     ) or (cp3_spc      and ex2_special(142)    ) );
r3_143:   ex2_sh16_r3_b(143)   <= not( (cp1_128    and ex2_sh_lvl2(15)     ) or (cp3_spc      and ex2_special(143)    ) );

r3_144:   ex2_sh16_r3_b(144)   <= not( (cp1_144    and ex2_sh_lvl2(0)      ) or (cp4_spc      and ex2_special(144)    ) );
r3_145:   ex2_sh16_r3_b(145)   <= not( (cp1_144    and ex2_sh_lvl2(1)      ) or (cp4_spc      and ex2_special(145)    ) );
r3_146:   ex2_sh16_r3_b(146)   <= not( (cp1_144    and ex2_sh_lvl2(2)      ) or (cp4_spc      and ex2_special(146)    ) );
r3_147:   ex2_sh16_r3_b(147)   <= not( (cp1_144    and ex2_sh_lvl2(3)      ) or (cp4_spc      and ex2_special(147)    ) );
r3_148:   ex2_sh16_r3_b(148)   <= not( (cp1_144    and ex2_sh_lvl2(4)      ) or (cp4_spc      and ex2_special(148)    ) );
r3_149:   ex2_sh16_r3_b(149)   <= not( (cp1_144    and ex2_sh_lvl2(5)      ) or (cp4_spc      and ex2_special(149)    ) );
r3_150:   ex2_sh16_r3_b(150)   <= not( (cp1_144    and ex2_sh_lvl2(6)      ) or (cp4_spc      and ex2_special(150)    ) );
r3_151:   ex2_sh16_r3_b(151)   <= not( (cp1_144    and ex2_sh_lvl2(7)      ) or (cp4_spc      and ex2_special(151)    ) );
r3_152:   ex2_sh16_r3_b(152)   <= not( (cp1_144    and ex2_sh_lvl2(8)      ) or (cp4_spc      and ex2_special(152)    ) );
r3_153:   ex2_sh16_r3_b(153)   <= not( (cp1_144    and ex2_sh_lvl2(9)      ) or (cp4_spc      and ex2_special(153)    ) );
r3_154:   ex2_sh16_r3_b(154)   <= not( (cp1_144    and ex2_sh_lvl2(10)     ) or (cp4_spc      and ex2_special(154)    ) );
r3_155:   ex2_sh16_r3_b(155)   <= not( (cp1_144    and ex2_sh_lvl2(11)     ) or (cp4_spc      and ex2_special(155)    ) );
r3_156:   ex2_sh16_r3_b(156)   <= not( (cp1_144    and ex2_sh_lvl2(12)     ) or (cp4_spc      and ex2_special(156)    ) );
r3_157:   ex2_sh16_r3_b(157)   <= not( (cp1_144    and ex2_sh_lvl2(13)     ) or (cp4_spc      and ex2_special(157)    ) );
r3_158:   ex2_sh16_r3_b(158)   <= not( (cp1_144    and ex2_sh_lvl2(14)     ) or (cp4_spc      and ex2_special(158)    ) );
r3_159:   ex2_sh16_r3_b(159)   <= not( (cp1_144    and ex2_sh_lvl2(15)     ) or (cp4_spc      and ex2_special(159)    ) );

r3_160:   ex2_sh16_r3_b(160)   <= not( (cp1_160    and ex2_sh_lvl2(0)      ) or (cp5_spc      and ex2_special(160)    ) );
r3_161:   ex2_sh16_r3_b(161)   <= not( (cp1_160    and ex2_sh_lvl2(1)      ) or (cp5_spc      and ex2_special(161)    ) );
r3_162:   ex2_sh16_r3_b(162)   <= not( (cp1_160    and ex2_sh_lvl2(2)      ) or (cp5_spc      and ex2_special(162)    ) );


o_000:    ex2_sh_lvl3(0)       <= not( ex2_sh16_r1_b(0)     and ex2_sh16_r2_b(0)     and ex2_sh16_r3_b(0)     );
o_001:    ex2_sh_lvl3(1)       <= not( ex2_sh16_r1_b(1)     and ex2_sh16_r2_b(1)     and ex2_sh16_r3_b(1)     );
o_002:    ex2_sh_lvl3(2)       <= not( ex2_sh16_r1_b(2)     and ex2_sh16_r2_b(2)     and ex2_sh16_r3_b(2)     );
o_003:    ex2_sh_lvl3(3)       <= not( ex2_sh16_r1_b(3)     and ex2_sh16_r2_b(3)     and ex2_sh16_r3_b(3)     );
o_004:    ex2_sh_lvl3(4)       <= not( ex2_sh16_r1_b(4)     and ex2_sh16_r2_b(4)     and ex2_sh16_r3_b(4)     );
o_005:    ex2_sh_lvl3(5)       <= not( ex2_sh16_r1_b(5)     and ex2_sh16_r2_b(5)     and ex2_sh16_r3_b(5)     );
o_006:    ex2_sh_lvl3(6)       <= not( ex2_sh16_r1_b(6)     and ex2_sh16_r2_b(6)     and ex2_sh16_r3_b(6)     );
o_007:    ex2_sh_lvl3(7)       <= not( ex2_sh16_r1_b(7)     and ex2_sh16_r2_b(7)     and ex2_sh16_r3_b(7)     );
o_008:    ex2_sh_lvl3(8)       <= not( ex2_sh16_r1_b(8)     and ex2_sh16_r2_b(8)     and ex2_sh16_r3_b(8)     );
o_009:    ex2_sh_lvl3(9)       <= not( ex2_sh16_r1_b(9)     and ex2_sh16_r2_b(9)     and ex2_sh16_r3_b(9)     );
o_010:    ex2_sh_lvl3(10)      <= not( ex2_sh16_r1_b(10)    and ex2_sh16_r2_b(10)    and ex2_sh16_r3_b(10)    );
o_011:    ex2_sh_lvl3(11)      <= not( ex2_sh16_r1_b(11)    and ex2_sh16_r2_b(11)    and ex2_sh16_r3_b(11)    );
o_012:    ex2_sh_lvl3(12)      <= not( ex2_sh16_r1_b(12)    and ex2_sh16_r2_b(12)    and ex2_sh16_r3_b(12)    );
o_013:    ex2_sh_lvl3(13)      <= not( ex2_sh16_r1_b(13)    and ex2_sh16_r2_b(13)    and ex2_sh16_r3_b(13)    );
o_014:    ex2_sh_lvl3(14)      <= not( ex2_sh16_r1_b(14)    and ex2_sh16_r2_b(14)    and ex2_sh16_r3_b(14)    );
o_015:    ex2_sh_lvl3(15)      <= not( ex2_sh16_r1_b(15)    and ex2_sh16_r2_b(15)    and ex2_sh16_r3_b(15)    );
o_016:    ex2_sh_lvl3(16)      <= not( ex2_sh16_r1_b(16)    and ex2_sh16_r2_b(16)    and ex2_sh16_r3_b(16)    );
o_017:    ex2_sh_lvl3(17)      <= not( ex2_sh16_r1_b(17)    and ex2_sh16_r2_b(17)    and ex2_sh16_r3_b(17)    );
o_018:    ex2_sh_lvl3(18)      <= not( ex2_sh16_r1_b(18)    and ex2_sh16_r2_b(18)    and ex2_sh16_r3_b(18)    );
o_019:    ex2_sh_lvl3(19)      <= not( ex2_sh16_r1_b(19)    and ex2_sh16_r2_b(19)    and ex2_sh16_r3_b(19)    );
o_020:    ex2_sh_lvl3(20)      <= not( ex2_sh16_r1_b(20)    and ex2_sh16_r2_b(20)    and ex2_sh16_r3_b(20)    );
o_021:    ex2_sh_lvl3(21)      <= not( ex2_sh16_r1_b(21)    and ex2_sh16_r2_b(21)    and ex2_sh16_r3_b(21)    );
o_022:    ex2_sh_lvl3(22)      <= not( ex2_sh16_r1_b(22)    and ex2_sh16_r2_b(22)    and ex2_sh16_r3_b(22)    );
o_023:    ex2_sh_lvl3(23)      <= not( ex2_sh16_r1_b(23)    and ex2_sh16_r2_b(23)    and ex2_sh16_r3_b(23)    );
o_024:    ex2_sh_lvl3(24)      <= not( ex2_sh16_r1_b(24)    and ex2_sh16_r2_b(24)    and ex2_sh16_r3_b(24)    );
o_025:    ex2_sh_lvl3(25)      <= not( ex2_sh16_r1_b(25)    and ex2_sh16_r2_b(25)    and ex2_sh16_r3_b(25)    );
o_026:    ex2_sh_lvl3(26)      <= not( ex2_sh16_r1_b(26)    and ex2_sh16_r2_b(26)    and ex2_sh16_r3_b(26)    );
o_027:    ex2_sh_lvl3(27)      <= not( ex2_sh16_r1_b(27)    and ex2_sh16_r2_b(27)    and ex2_sh16_r3_b(27)    );
o_028:    ex2_sh_lvl3(28)      <= not( ex2_sh16_r1_b(28)    and ex2_sh16_r2_b(28)    and ex2_sh16_r3_b(28)    );
o_029:    ex2_sh_lvl3(29)      <= not( ex2_sh16_r1_b(29)    and ex2_sh16_r2_b(29)    and ex2_sh16_r3_b(29)    );
o_030:    ex2_sh_lvl3(30)      <= not( ex2_sh16_r1_b(30)    and ex2_sh16_r2_b(30)    and ex2_sh16_r3_b(30)    );
o_031:    ex2_sh_lvl3(31)      <= not( ex2_sh16_r1_b(31)    and ex2_sh16_r2_b(31)    and ex2_sh16_r3_b(31)    );
o_032:    ex2_sh_lvl3(32)      <= not( ex2_sh16_r1_b(32)    and ex2_sh16_r2_b(32)    and ex2_sh16_r3_b(32)    );
o_033:    ex2_sh_lvl3(33)      <= not( ex2_sh16_r1_b(33)    and ex2_sh16_r2_b(33)    and ex2_sh16_r3_b(33)    );
o_034:    ex2_sh_lvl3(34)      <= not( ex2_sh16_r1_b(34)    and ex2_sh16_r2_b(34)    and ex2_sh16_r3_b(34)    );
o_035:    ex2_sh_lvl3(35)      <= not( ex2_sh16_r1_b(35)    and ex2_sh16_r2_b(35)    and ex2_sh16_r3_b(35)    );
o_036:    ex2_sh_lvl3(36)      <= not( ex2_sh16_r1_b(36)    and ex2_sh16_r2_b(36)    and ex2_sh16_r3_b(36)    );
o_037:    ex2_sh_lvl3(37)      <= not( ex2_sh16_r1_b(37)    and ex2_sh16_r2_b(37)    and ex2_sh16_r3_b(37)    );
o_038:    ex2_sh_lvl3(38)      <= not( ex2_sh16_r1_b(38)    and ex2_sh16_r2_b(38)    and ex2_sh16_r3_b(38)    );
o_039:    ex2_sh_lvl3(39)      <= not( ex2_sh16_r1_b(39)    and ex2_sh16_r2_b(39)    and ex2_sh16_r3_b(39)    );
o_040:    ex2_sh_lvl3(40)      <= not( ex2_sh16_r1_b(40)    and ex2_sh16_r2_b(40)    and ex2_sh16_r3_b(40)    );
o_041:    ex2_sh_lvl3(41)      <= not( ex2_sh16_r1_b(41)    and ex2_sh16_r2_b(41)    and ex2_sh16_r3_b(41)    );
o_042:    ex2_sh_lvl3(42)      <= not( ex2_sh16_r1_b(42)    and ex2_sh16_r2_b(42)    and ex2_sh16_r3_b(42)    );
o_043:    ex2_sh_lvl3(43)      <= not( ex2_sh16_r1_b(43)    and ex2_sh16_r2_b(43)    and ex2_sh16_r3_b(43)    );
o_044:    ex2_sh_lvl3(44)      <= not( ex2_sh16_r1_b(44)    and ex2_sh16_r2_b(44)    and ex2_sh16_r3_b(44)    );
o_045:    ex2_sh_lvl3(45)      <= not( ex2_sh16_r1_b(45)    and ex2_sh16_r2_b(45)    and ex2_sh16_r3_b(45)    );
o_046:    ex2_sh_lvl3(46)      <= not( ex2_sh16_r1_b(46)    and ex2_sh16_r2_b(46)    and ex2_sh16_r3_b(46)    );
o_047:    ex2_sh_lvl3(47)      <= not( ex2_sh16_r1_b(47)    and ex2_sh16_r2_b(47)    and ex2_sh16_r3_b(47)    );
o_048:    ex2_sh_lvl3(48)      <= not( ex2_sh16_r1_b(48)    and ex2_sh16_r2_b(48)    and ex2_sh16_r3_b(48)    );
o_049:    ex2_sh_lvl3(49)      <= not( ex2_sh16_r1_b(49)    and ex2_sh16_r2_b(49)    and ex2_sh16_r3_b(49)    );
o_050:    ex2_sh_lvl3(50)      <= not( ex2_sh16_r1_b(50)    and ex2_sh16_r2_b(50)    and ex2_sh16_r3_b(50)    );
o_051:    ex2_sh_lvl3(51)      <= not( ex2_sh16_r1_b(51)    and ex2_sh16_r2_b(51)    and ex2_sh16_r3_b(51)    );
o_052:    ex2_sh_lvl3(52)      <= not( ex2_sh16_r1_b(52)    and ex2_sh16_r2_b(52)    and ex2_sh16_r3_b(52)    );
o_053:    ex2_sh_lvl3(53)      <= not( ex2_sh16_r1_b(53)    and ex2_sh16_r2_b(53)    and ex2_sh16_r3_b(53)    );
o_054:    ex2_sh_lvl3(54)      <= not( ex2_sh16_r1_b(54)    and ex2_sh16_r2_b(54)    and ex2_sh16_r3_b(54)    );
o_055:    ex2_sh_lvl3(55)      <= not( ex2_sh16_r1_b(55)    and ex2_sh16_r2_b(55)    and ex2_sh16_r3_b(55)    );
o_056:    ex2_sh_lvl3(56)      <= not( ex2_sh16_r1_b(56)    and ex2_sh16_r2_b(56)    and ex2_sh16_r3_b(56)    );
o_057:    ex2_sh_lvl3(57)      <= not( ex2_sh16_r1_b(57)    and ex2_sh16_r2_b(57)    and ex2_sh16_r3_b(57)    );
o_058:    ex2_sh_lvl3(58)      <= not( ex2_sh16_r1_b(58)    and ex2_sh16_r2_b(58)    and ex2_sh16_r3_b(58)    );
o_059:    ex2_sh_lvl3(59)      <= not( ex2_sh16_r1_b(59)    and ex2_sh16_r2_b(59)    and ex2_sh16_r3_b(59)    );
o_060:    ex2_sh_lvl3(60)      <= not( ex2_sh16_r1_b(60)    and ex2_sh16_r2_b(60)    and ex2_sh16_r3_b(60)    );
o_061:    ex2_sh_lvl3(61)      <= not( ex2_sh16_r1_b(61)    and ex2_sh16_r2_b(61)    and ex2_sh16_r3_b(61)    );
o_062:    ex2_sh_lvl3(62)      <= not( ex2_sh16_r1_b(62)    and ex2_sh16_r2_b(62)    and ex2_sh16_r3_b(62)    );
o_063:    ex2_sh_lvl3(63)      <= not( ex2_sh16_r1_b(63)    and ex2_sh16_r2_b(63)    and ex2_sh16_r3_b(63)    );
o_064:    ex2_sh_lvl3(64)      <= not( ex2_sh16_r1_b(64)    and ex2_sh16_r2_b(64)    and ex2_sh16_r3_b(64)    );
o_065:    ex2_sh_lvl3(65)      <= not( ex2_sh16_r1_b(65)    and ex2_sh16_r2_b(65)    and ex2_sh16_r3_b(65)    );
o_066:    ex2_sh_lvl3(66)      <= not( ex2_sh16_r1_b(66)    and ex2_sh16_r2_b(66)    and ex2_sh16_r3_b(66)    );
o_067:    ex2_sh_lvl3(67)      <= not( ex2_sh16_r1_b(67)    and ex2_sh16_r2_b(67)    and ex2_sh16_r3_b(67)    );
o_068:    ex2_sh_lvl3(68)      <= not( ex2_sh16_r1_b(68)    and ex2_sh16_r2_b(68)    and ex2_sh16_r3_b(68)    );
o_069:    ex2_sh_lvl3(69)      <= not( ex2_sh16_r1_b(69)    and ex2_sh16_r2_b(69)    and ex2_sh16_r3_b(69)    );
o_070:    ex2_sh_lvl3(70)      <= not( ex2_sh16_r1_b(70)    and ex2_sh16_r2_b(70)    and ex2_sh16_r3_b(70)    );
o_071:    ex2_sh_lvl3(71)      <= not( ex2_sh16_r1_b(71)    and ex2_sh16_r2_b(71)    and ex2_sh16_r3_b(71)    );
o_072:    ex2_sh_lvl3(72)      <= not( ex2_sh16_r1_b(72)    and ex2_sh16_r2_b(72)    and ex2_sh16_r3_b(72)    );
o_073:    ex2_sh_lvl3(73)      <= not( ex2_sh16_r1_b(73)    and ex2_sh16_r2_b(73)    and ex2_sh16_r3_b(73)    );
o_074:    ex2_sh_lvl3(74)      <= not( ex2_sh16_r1_b(74)    and ex2_sh16_r2_b(74)    and ex2_sh16_r3_b(74)    );
o_075:    ex2_sh_lvl3(75)      <= not( ex2_sh16_r1_b(75)    and ex2_sh16_r2_b(75)    and ex2_sh16_r3_b(75)    );
o_076:    ex2_sh_lvl3(76)      <= not( ex2_sh16_r1_b(76)    and ex2_sh16_r2_b(76)    and ex2_sh16_r3_b(76)    );
o_077:    ex2_sh_lvl3(77)      <= not( ex2_sh16_r1_b(77)    and ex2_sh16_r2_b(77)    and ex2_sh16_r3_b(77)    );
o_078:    ex2_sh_lvl3(78)      <= not( ex2_sh16_r1_b(78)    and ex2_sh16_r2_b(78)    and ex2_sh16_r3_b(78)    );
o_079:    ex2_sh_lvl3(79)      <= not( ex2_sh16_r1_b(79)    and ex2_sh16_r2_b(79)    and ex2_sh16_r3_b(79)    );
o_080:    ex2_sh_lvl3(80)      <= not( ex2_sh16_r1_b(80)    and ex2_sh16_r2_b(80)    and ex2_sh16_r3_b(80)    );
o_081:    ex2_sh_lvl3(81)      <= not( ex2_sh16_r1_b(81)    and ex2_sh16_r2_b(81)    and ex2_sh16_r3_b(81)    );
o_082:    ex2_sh_lvl3(82)      <= not( ex2_sh16_r1_b(82)    and ex2_sh16_r2_b(82)    and ex2_sh16_r3_b(82)    );
o_083:    ex2_sh_lvl3(83)      <= not( ex2_sh16_r1_b(83)    and ex2_sh16_r2_b(83)    and ex2_sh16_r3_b(83)    );
o_084:    ex2_sh_lvl3(84)      <= not( ex2_sh16_r1_b(84)    and ex2_sh16_r2_b(84)    and ex2_sh16_r3_b(84)    );
o_085:    ex2_sh_lvl3(85)      <= not( ex2_sh16_r1_b(85)    and ex2_sh16_r2_b(85)    and ex2_sh16_r3_b(85)    );
o_086:    ex2_sh_lvl3(86)      <= not( ex2_sh16_r1_b(86)    and ex2_sh16_r2_b(86)    and ex2_sh16_r3_b(86)    );
o_087:    ex2_sh_lvl3(87)      <= not( ex2_sh16_r1_b(87)    and ex2_sh16_r2_b(87)    and ex2_sh16_r3_b(87)    );
o_088:    ex2_sh_lvl3(88)      <= not( ex2_sh16_r1_b(88)    and ex2_sh16_r2_b(88)    and ex2_sh16_r3_b(88)    );
o_089:    ex2_sh_lvl3(89)      <= not( ex2_sh16_r1_b(89)    and ex2_sh16_r2_b(89)    and ex2_sh16_r3_b(89)    );
o_090:    ex2_sh_lvl3(90)      <= not( ex2_sh16_r1_b(90)    and ex2_sh16_r2_b(90)    and ex2_sh16_r3_b(90)    );
o_091:    ex2_sh_lvl3(91)      <= not( ex2_sh16_r1_b(91)    and ex2_sh16_r2_b(91)    and ex2_sh16_r3_b(91)    );
o_092:    ex2_sh_lvl3(92)      <= not( ex2_sh16_r1_b(92)    and ex2_sh16_r2_b(92)    and ex2_sh16_r3_b(92)    );
o_093:    ex2_sh_lvl3(93)      <= not( ex2_sh16_r1_b(93)    and ex2_sh16_r2_b(93)    and ex2_sh16_r3_b(93)    );
o_094:    ex2_sh_lvl3(94)      <= not( ex2_sh16_r1_b(94)    and ex2_sh16_r2_b(94)    and ex2_sh16_r3_b(94)    );
o_095:    ex2_sh_lvl3(95)      <= not( ex2_sh16_r1_b(95)    and ex2_sh16_r2_b(95)    and ex2_sh16_r3_b(95)    );
o_096:    ex2_sh_lvl3(96)      <= not( ex2_sh16_r1_b(96)    and ex2_sh16_r2_b(96)    and ex2_sh16_r3_b(96)    );
o_097:    ex2_sh_lvl3(97)      <= not( ex2_sh16_r1_b(97)    and ex2_sh16_r2_b(97)    and ex2_sh16_r3_b(97)    );
o_098:    ex2_sh_lvl3(98)      <= not( ex2_sh16_r1_b(98)    and ex2_sh16_r2_b(98)    and ex2_sh16_r3_b(98)    );
o_099:    ex2_sh_lvl3(99)      <= not( ex2_sh16_r1_b(99)    and ex2_sh16_r2_b(99)    and ex2_sh16_r3_b(99)    );
o_100:    ex2_sh_lvl3(100)     <= not( ex2_sh16_r1_b(100)   and ex2_sh16_r2_b(100)   and ex2_sh16_r3_b(100)   );
o_101:    ex2_sh_lvl3(101)     <= not( ex2_sh16_r1_b(101)   and ex2_sh16_r2_b(101)   and ex2_sh16_r3_b(101)   );
o_102:    ex2_sh_lvl3(102)     <= not( ex2_sh16_r1_b(102)   and ex2_sh16_r2_b(102)   and ex2_sh16_r3_b(102)   );
o_103:    ex2_sh_lvl3(103)     <= not( ex2_sh16_r1_b(103)   and ex2_sh16_r2_b(103)   and ex2_sh16_r3_b(103)   );
o_104:    ex2_sh_lvl3(104)     <= not( ex2_sh16_r1_b(104)   and ex2_sh16_r2_b(104)   and ex2_sh16_r3_b(104)   );
o_105:    ex2_sh_lvl3(105)     <= not( ex2_sh16_r1_b(105)   and ex2_sh16_r2_b(105)   and ex2_sh16_r3_b(105)   );
o_106:    ex2_sh_lvl3(106)     <= not( ex2_sh16_r1_b(106)   and ex2_sh16_r2_b(106)   and ex2_sh16_r3_b(106)   );
o_107:    ex2_sh_lvl3(107)     <= not( ex2_sh16_r1_b(107)   and ex2_sh16_r2_b(107)   and ex2_sh16_r3_b(107)   );
o_108:    ex2_sh_lvl3(108)     <= not( ex2_sh16_r1_b(108)   and ex2_sh16_r2_b(108)   and ex2_sh16_r3_b(108)   );
o_109:    ex2_sh_lvl3(109)     <= not( ex2_sh16_r1_b(109)   and ex2_sh16_r2_b(109)   and ex2_sh16_r3_b(109)   );
o_110:    ex2_sh_lvl3(110)     <= not( ex2_sh16_r1_b(110)   and ex2_sh16_r2_b(110)   and ex2_sh16_r3_b(110)   );
o_111:    ex2_sh_lvl3(111)     <= not( ex2_sh16_r1_b(111)   and ex2_sh16_r2_b(111)   and ex2_sh16_r3_b(111)   );
o_112:    ex2_sh_lvl3(112)     <= not( ex2_sh16_r1_b(112)   and ex2_sh16_r2_b(112)   and ex2_sh16_r3_b(112)   );
o_113:    ex2_sh_lvl3(113)     <= not( ex2_sh16_r1_b(113)   and ex2_sh16_r2_b(113)   and ex2_sh16_r3_b(113)   );
o_114:    ex2_sh_lvl3(114)     <= not( ex2_sh16_r1_b(114)   and ex2_sh16_r2_b(114)   and ex2_sh16_r3_b(114)   );
o_115:    ex2_sh_lvl3(115)     <= not( ex2_sh16_r1_b(115)   and ex2_sh16_r2_b(115)   and ex2_sh16_r3_b(115)   );
o_116:    ex2_sh_lvl3(116)     <= not( ex2_sh16_r1_b(116)   and ex2_sh16_r2_b(116)   and ex2_sh16_r3_b(116)   );
o_117:    ex2_sh_lvl3(117)     <= not( ex2_sh16_r1_b(117)   and ex2_sh16_r2_b(117)   and ex2_sh16_r3_b(117)   );
o_118:    ex2_sh_lvl3(118)     <= not( ex2_sh16_r1_b(118)   and ex2_sh16_r2_b(118)   and ex2_sh16_r3_b(118)   );
o_119:    ex2_sh_lvl3(119)     <= not( ex2_sh16_r1_b(119)   and ex2_sh16_r2_b(119)   and ex2_sh16_r3_b(119)   );
o_120:    ex2_sh_lvl3(120)     <= not( ex2_sh16_r1_b(120)   and ex2_sh16_r2_b(120)   and ex2_sh16_r3_b(120)   );
o_121:    ex2_sh_lvl3(121)     <= not( ex2_sh16_r1_b(121)   and ex2_sh16_r2_b(121)   and ex2_sh16_r3_b(121)   );
o_122:    ex2_sh_lvl3(122)     <= not( ex2_sh16_r1_b(122)   and ex2_sh16_r2_b(122)   and ex2_sh16_r3_b(122)   );
o_123:    ex2_sh_lvl3(123)     <= not( ex2_sh16_r1_b(123)   and ex2_sh16_r2_b(123)   and ex2_sh16_r3_b(123)   );
o_124:    ex2_sh_lvl3(124)     <= not( ex2_sh16_r1_b(124)   and ex2_sh16_r2_b(124)   and ex2_sh16_r3_b(124)   );
o_125:    ex2_sh_lvl3(125)     <= not( ex2_sh16_r1_b(125)   and ex2_sh16_r2_b(125)   and ex2_sh16_r3_b(125)   );
o_126:    ex2_sh_lvl3(126)     <= not( ex2_sh16_r1_b(126)   and ex2_sh16_r2_b(126)   and ex2_sh16_r3_b(126)   );
o_127:    ex2_sh_lvl3(127)     <= not( ex2_sh16_r1_b(127)   and ex2_sh16_r2_b(127)   and ex2_sh16_r3_b(127)   );
o_128:    ex2_sh_lvl3(128)     <= not( ex2_sh16_r1_b(128)   and ex2_sh16_r2_b(128)   and ex2_sh16_r3_b(128)   );
o_129:    ex2_sh_lvl3(129)     <= not( ex2_sh16_r1_b(129)   and ex2_sh16_r2_b(129)   and ex2_sh16_r3_b(129)   );
o_130:    ex2_sh_lvl3(130)     <= not( ex2_sh16_r1_b(130)   and ex2_sh16_r2_b(130)   and ex2_sh16_r3_b(130)   );
o_131:    ex2_sh_lvl3(131)     <= not( ex2_sh16_r1_b(131)   and ex2_sh16_r2_b(131)   and ex2_sh16_r3_b(131)   );
o_132:    ex2_sh_lvl3(132)     <= not( ex2_sh16_r1_b(132)   and ex2_sh16_r2_b(132)   and ex2_sh16_r3_b(132)   );
o_133:    ex2_sh_lvl3(133)     <= not( ex2_sh16_r1_b(133)   and ex2_sh16_r2_b(133)   and ex2_sh16_r3_b(133)   );
o_134:    ex2_sh_lvl3(134)     <= not( ex2_sh16_r1_b(134)   and ex2_sh16_r2_b(134)   and ex2_sh16_r3_b(134)   );
o_135:    ex2_sh_lvl3(135)     <= not( ex2_sh16_r1_b(135)   and ex2_sh16_r2_b(135)   and ex2_sh16_r3_b(135)   );
o_136:    ex2_sh_lvl3(136)     <= not( ex2_sh16_r1_b(136)   and ex2_sh16_r2_b(136)   and ex2_sh16_r3_b(136)   );
o_137:    ex2_sh_lvl3(137)     <= not( ex2_sh16_r1_b(137)   and ex2_sh16_r2_b(137)   and ex2_sh16_r3_b(137)   );
o_138:    ex2_sh_lvl3(138)     <= not( ex2_sh16_r1_b(138)   and ex2_sh16_r2_b(138)   and ex2_sh16_r3_b(138)   );
o_139:    ex2_sh_lvl3(139)     <= not( ex2_sh16_r1_b(139)   and ex2_sh16_r2_b(139)   and ex2_sh16_r3_b(139)   );
o_140:    ex2_sh_lvl3(140)     <= not( ex2_sh16_r1_b(140)   and ex2_sh16_r2_b(140)   and ex2_sh16_r3_b(140)   );
o_141:    ex2_sh_lvl3(141)     <= not( ex2_sh16_r1_b(141)   and ex2_sh16_r2_b(141)   and ex2_sh16_r3_b(141)   );
o_142:    ex2_sh_lvl3(142)     <= not( ex2_sh16_r1_b(142)   and ex2_sh16_r2_b(142)   and ex2_sh16_r3_b(142)   );
o_143:    ex2_sh_lvl3(143)     <= not( ex2_sh16_r1_b(143)   and ex2_sh16_r2_b(143)   and ex2_sh16_r3_b(143)   );
o_144:    ex2_sh_lvl3(144)     <= not( ex2_sh16_r1_b(144)   and ex2_sh16_r2_b(144)   and ex2_sh16_r3_b(144)   );
o_145:    ex2_sh_lvl3(145)     <= not( ex2_sh16_r1_b(145)   and ex2_sh16_r2_b(145)   and ex2_sh16_r3_b(145)   );
o_146:    ex2_sh_lvl3(146)     <= not( ex2_sh16_r1_b(146)   and ex2_sh16_r2_b(146)   and ex2_sh16_r3_b(146)   );
o_147:    ex2_sh_lvl3(147)     <= not( ex2_sh16_r1_b(147)   and ex2_sh16_r2_b(147)   and ex2_sh16_r3_b(147)   );
o_148:    ex2_sh_lvl3(148)     <= not( ex2_sh16_r1_b(148)   and ex2_sh16_r2_b(148)   and ex2_sh16_r3_b(148)   );
o_149:    ex2_sh_lvl3(149)     <= not( ex2_sh16_r1_b(149)   and ex2_sh16_r2_b(149)   and ex2_sh16_r3_b(149)   );
o_150:    ex2_sh_lvl3(150)     <= not( ex2_sh16_r1_b(150)   and ex2_sh16_r2_b(150)   and ex2_sh16_r3_b(150)   );
o_151:    ex2_sh_lvl3(151)     <= not( ex2_sh16_r1_b(151)   and ex2_sh16_r2_b(151)   and ex2_sh16_r3_b(151)   );
o_152:    ex2_sh_lvl3(152)     <= not( ex2_sh16_r1_b(152)   and ex2_sh16_r2_b(152)   and ex2_sh16_r3_b(152)   );
o_153:    ex2_sh_lvl3(153)     <= not( ex2_sh16_r1_b(153)   and ex2_sh16_r2_b(153)   and ex2_sh16_r3_b(153)   );
o_154:    ex2_sh_lvl3(154)     <= not( ex2_sh16_r1_b(154)   and ex2_sh16_r2_b(154)   and ex2_sh16_r3_b(154)   );
o_155:    ex2_sh_lvl3(155)     <= not( ex2_sh16_r1_b(155)   and ex2_sh16_r2_b(155)   and ex2_sh16_r3_b(155)   );
o_156:    ex2_sh_lvl3(156)     <= not( ex2_sh16_r1_b(156)   and ex2_sh16_r2_b(156)   and ex2_sh16_r3_b(156)   );
o_157:    ex2_sh_lvl3(157)     <= not( ex2_sh16_r1_b(157)   and ex2_sh16_r2_b(157)   and ex2_sh16_r3_b(157)   );
o_158:    ex2_sh_lvl3(158)     <= not( ex2_sh16_r1_b(158)   and ex2_sh16_r2_b(158)   and ex2_sh16_r3_b(158)   );
o_159:    ex2_sh_lvl3(159)     <= not( ex2_sh16_r1_b(159)   and ex2_sh16_r2_b(159)   and ex2_sh16_r3_b(159)   );
o_160:    ex2_sh_lvl3(160)     <= not( ex2_sh16_r1_b(160)   and ex2_sh16_r2_b(160)   and ex2_sh16_r3_b(160)   );
o_161:    ex2_sh_lvl3(161)     <= not( ex2_sh16_r1_b(161)   and ex2_sh16_r2_b(161)   and ex2_sh16_r3_b(161)   );
o_162:    ex2_sh_lvl3(162)     <= not( ex2_sh16_r1_b(162)   and ex2_sh16_r2_b(162)   and ex2_sh16_r3_b(162)   );





rr3_162:   ex2_sh16_r3_162_b    <= not( (ex2_lvl3_shdcd160 and ex2_sh_lvl2(2)      ) or (ex2_sel_special   and ex2_special(162)    ) );
rr3_163:   ex2_sh16_r3_163_b    <= not(  ex2_lvl3_shdcd160 and ex2_sh_lvl2(3)      );

rr2_162:   ex2_sh16_r2_162_b    <= not( (ex2_lvl3_shdcd128 and ex2_sh_lvl2(34)     ) or (ex2_lvl3_shdcd144 and ex2_sh_lvl2(18)     ) );
rr2_163:   ex2_sh16_r2_163_b    <= not( (ex2_lvl3_shdcd128 and ex2_sh_lvl2(35)     ) or (ex2_lvl3_shdcd144 and ex2_sh_lvl2(19)     ) );

rr1_162:   ex2_sh16_r1_162_b    <= not( (ex2_lvl3_shdcd096 and ex2_sh_lvl2(66)     ) or (ex2_lvl3_shdcd112 and ex2_sh_lvl2(50)     ) );
rr1_163:   ex2_sh16_r1_163_b    <= not( (ex2_lvl3_shdcd096 and ex2_sh_lvl2(67)     ) or (ex2_lvl3_shdcd112 and ex2_sh_lvl2(51)     ) );

ro_162:    ex2_sh16_162         <= not( ex2_sh16_r1_162_b  and ex2_sh16_r2_162_b and ex2_sh16_r3_162_b  );
ro_163:    ex2_sh16_163         <= not( ex2_sh16_r1_163_b  and ex2_sh16_r2_163_b and ex2_sh16_r3_163_b  );



end; 



