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



library ieee; 
  use ieee.std_logic_1164.all ; 
library ibm; 
  use ibm.std_ulogic_support.all; 
  use ibm.std_ulogic_function_support.all; 
  use ibm.std_ulogic_ao_support.all; 
  use ibm.std_ulogic_mux_support.all; 

ENTITY fuq_tblmul_bthrow IS
PORT(

     x          :in  std_ulogic_vector(0 to 15); 
     s_neg      :in  std_ulogic;                 
     s_x        :in  std_ulogic;                 
     s_x2       :in  std_ulogic;                 
     q          :out std_ulogic_vector(0 to 16)  

);


end fuq_tblmul_bthrow; 

architecture fuq_tblmul_bthrow of fuq_tblmul_bthrow is

    constant tiup : std_ulogic := '1';
    constant tidn : std_ulogic := '0';

    signal left  :std_ulogic_vector(  0 to 16);
    signal unused :std_ulogic;
begin


  unused <= left(0);
 
  u00: entity work.fuq_mul_bthmux(fuq_mul_bthmux) port map( 
        SNEG             => s_neg                     ,
        SX               => s_x                       ,
        SX2              => s_x2                      ,
        X                => tidn                      ,
        LEFT             => left(0)                   ,
        RIGHT            => left(1)                   ,
        Q                => q(0)                     );

  u01: entity work.fuq_mul_bthmux(fuq_mul_bthmux) port map( 
        SNEG             => s_neg                     ,
        SX               => s_x                       ,
        SX2              => s_x2                      ,
        X                => x(0)                      ,
        LEFT             => left(1)                   ,
        RIGHT            => left(2)                   ,
        Q                => q(1)                     );

  u02: entity work.fuq_mul_bthmux(fuq_mul_bthmux) port map( 
        SNEG             => s_neg                     ,
        SX               => s_x                       ,
        SX2              => s_x2                      ,
        X                => x(1)                      ,
        LEFT             => left(2)                   ,
        RIGHT            => left(3)                   ,
        Q                => q(2)                     );

  u03: entity work.fuq_mul_bthmux(fuq_mul_bthmux) port map( 
        SNEG             => s_neg                     ,
        SX               => s_x                       ,
        SX2              => s_x2                      ,
        X                => x(2)                      ,
        LEFT             => left(3)                   ,
        RIGHT            => left(4)                   ,
        Q                => q(3)                     );

  u04: entity work.fuq_mul_bthmux(fuq_mul_bthmux) port map( 
        SNEG             => s_neg                     ,
        SX               => s_x                       ,
        SX2              => s_x2                      ,
        X                => x(3)                      ,
        LEFT             => left(4)                   ,
        RIGHT            => left(5)                   ,
        Q                => q(4)                     );

  u05: entity work.fuq_mul_bthmux(fuq_mul_bthmux) port map( 
        SNEG             => s_neg                     ,
        SX               => s_x                       ,
        SX2              => s_x2                      ,
        X                => x(4)                      ,
        LEFT             => left(5)                   ,
        RIGHT            => left(6)                   ,
        Q                => q(5)                     );

  u06: entity work.fuq_mul_bthmux(fuq_mul_bthmux) port map( 
        SNEG             => s_neg                     ,
        SX               => s_x                       ,
        SX2              => s_x2                      ,
        X                => x(5)                      ,
        LEFT             => left(6)                   ,
        RIGHT            => left(7)                   ,
        Q                => q(6)                     );

  u07: entity work.fuq_mul_bthmux(fuq_mul_bthmux) port map( 
        SNEG             => s_neg                     ,
        SX               => s_x                       ,
        SX2              => s_x2                      ,
        X                => x(6)                      ,
        LEFT             => left(7)                   ,
        RIGHT            => left(8)                   ,
        Q                => q(7)                     );

  u08: entity work.fuq_mul_bthmux(fuq_mul_bthmux) port map( 
        SNEG             => s_neg                     ,
        SX               => s_x                       ,
        SX2              => s_x2                      ,
        X                => x(7)                      ,
        LEFT             => left(8)                   ,
        RIGHT            => left(9)                   ,
        Q                => q(8)                     );

  u09: entity work.fuq_mul_bthmux(fuq_mul_bthmux) port map( 
        SNEG             => s_neg                     ,
        SX               => s_x                       ,
        SX2              => s_x2                      ,
        X                => x(8)                      ,
        LEFT             => left(9)                   ,
        RIGHT            => left(10)                  ,
        Q                => q(9)                     );

  u10: entity work.fuq_mul_bthmux(fuq_mul_bthmux) port map( 
        SNEG             => s_neg                     ,
        SX               => s_x                       ,
        SX2              => s_x2                      ,
        X                => x(9)                      ,
        LEFT             => left(10)                  ,
        RIGHT            => left(11)                  ,
        Q                => q(10)                    );

  u11: entity work.fuq_mul_bthmux(fuq_mul_bthmux) port map( 
        SNEG             => s_neg                     ,
        SX               => s_x                       ,
        SX2              => s_x2                      ,
        X                => x(10)                     ,
        LEFT             => left(11)                  ,
        RIGHT            => left(12)                  ,
        Q                => q(11)                    );

  u12: entity work.fuq_mul_bthmux(fuq_mul_bthmux) port map( 
        SNEG             => s_neg                     ,
        SX               => s_x                       ,
        SX2              => s_x2                      ,
        X                => x(11)                     ,
        LEFT             => left(12)                  ,
        RIGHT            => left(13)                  ,
        Q                => q(12)                    );

  u13: entity work.fuq_mul_bthmux(fuq_mul_bthmux) port map( 
        SNEG             => s_neg                     ,
        SX               => s_x                       ,
        SX2              => s_x2                      ,
        X                => x(12)                     ,
        LEFT             => left(13)                  ,
        RIGHT            => left(14)                  ,
        Q                => q(13)                    );

  u14: entity work.fuq_mul_bthmux(fuq_mul_bthmux) port map( 
        SNEG             => s_neg                     ,
        SX               => s_x                       ,
        SX2              => s_x2                      ,
        X                => x(13)                     ,
        LEFT             => left(14)                  ,
        RIGHT            => left(15)                  ,
        Q                => q(14)                    );

  u15: entity work.fuq_mul_bthmux(fuq_mul_bthmux) port map( 
        SNEG             => s_neg                     ,
        SX               => s_x                       ,
        SX2              => s_x2                      ,
        X                => x(14)                     ,
        LEFT             => left(15)                  ,
        RIGHT            => left(16)                  ,
        Q                => q(15)                    );

  u16: entity work.fuq_mul_bthmux(fuq_mul_bthmux) port map( 
        SNEG             => s_neg                     ,
        SX               => s_x                       ,
        SX2              => s_x2                      ,
        X                => x(15)                     ,
        LEFT             => left(16)                  ,
        RIGHT            => s_neg                     ,
        Q                => q(16)                    );






end; 





     




