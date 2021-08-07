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

     x          :in  std_ulogic_vector(0 to 15); --
     s_neg      :in  std_ulogic;                 -- negate the row
     s_x        :in  std_ulogic;                 -- shift by 1
     s_x2       :in  std_ulogic;                 -- shift by 2
     q          :out std_ulogic_vector(0 to 16)  -- final output

);


end fuq_tblmul_bthrow; -- ENTITY

architecture fuq_tblmul_bthrow of fuq_tblmul_bthrow is

    constant tiup : std_ulogic := '1';
    constant tidn : std_ulogic := '0';

    signal left  :std_ulogic_vector(  0 to 16);
    signal unused :std_ulogic;
begin

--//################################################################
--//# A row of the repeated part of the booth_mux row
--//################################################################

  unused <= left(0);
 
  u00: entity work.fuq_mul_bthmux(fuq_mul_bthmux) port map( 
        SNEG             => s_neg                     ,--i--
        SX               => s_x                       ,--i--
        SX2              => s_x2                      ,--i--
        X                => tidn                      ,--i--  ********
        LEFT             => left(0)                   ,--o--  [n]
        RIGHT            => left(1)                   ,--i--  [n+1]
        Q                => q(0)                     );--o--

  u01: entity work.fuq_mul_bthmux(fuq_mul_bthmux) port map( 
        SNEG             => s_neg                     ,--i--
        SX               => s_x                       ,--i--
        SX2              => s_x2                      ,--i--
        X                => x(0)                      ,--i--  [n-1]
        LEFT             => left(1)                   ,--o--  [n]
        RIGHT            => left(2)                   ,--i--  [n+1]
        Q                => q(1)                     );--o--

  u02: entity work.fuq_mul_bthmux(fuq_mul_bthmux) port map( 
        SNEG             => s_neg                     ,--i--
        SX               => s_x                       ,--i--
        SX2              => s_x2                      ,--i--
        X                => x(1)                      ,--i--
        LEFT             => left(2)                   ,--o--
        RIGHT            => left(3)                   ,--i--
        Q                => q(2)                     );--o--

  u03: entity work.fuq_mul_bthmux(fuq_mul_bthmux) port map( 
        SNEG             => s_neg                     ,--i--
        SX               => s_x                       ,--i--
        SX2              => s_x2                      ,--i--
        X                => x(2)                      ,--i--
        LEFT             => left(3)                   ,--o--
        RIGHT            => left(4)                   ,--i--
        Q                => q(3)                     );--o--

  u04: entity work.fuq_mul_bthmux(fuq_mul_bthmux) port map( 
        SNEG             => s_neg                     ,--i--
        SX               => s_x                       ,--i--
        SX2              => s_x2                      ,--i--
        X                => x(3)                      ,--i--
        LEFT             => left(4)                   ,--o--
        RIGHT            => left(5)                   ,--i--
        Q                => q(4)                     );--o--

  u05: entity work.fuq_mul_bthmux(fuq_mul_bthmux) port map( 
        SNEG             => s_neg                     ,--i--
        SX               => s_x                       ,--i--
        SX2              => s_x2                      ,--i--
        X                => x(4)                      ,--i--
        LEFT             => left(5)                   ,--o--
        RIGHT            => left(6)                   ,--i--
        Q                => q(5)                     );--o--

  u06: entity work.fuq_mul_bthmux(fuq_mul_bthmux) port map( 
        SNEG             => s_neg                     ,--i--
        SX               => s_x                       ,--i--
        SX2              => s_x2                      ,--i--
        X                => x(5)                      ,--i--
        LEFT             => left(6)                   ,--o--
        RIGHT            => left(7)                   ,--i--
        Q                => q(6)                     );--o--

  u07: entity work.fuq_mul_bthmux(fuq_mul_bthmux) port map( 
        SNEG             => s_neg                     ,--i--
        SX               => s_x                       ,--i--
        SX2              => s_x2                      ,--i--
        X                => x(6)                      ,--i--
        LEFT             => left(7)                   ,--o--
        RIGHT            => left(8)                   ,--i--
        Q                => q(7)                     );--o--

  u08: entity work.fuq_mul_bthmux(fuq_mul_bthmux) port map( 
        SNEG             => s_neg                     ,--i--
        SX               => s_x                       ,--i--
        SX2              => s_x2                      ,--i--
        X                => x(7)                      ,--i--
        LEFT             => left(8)                   ,--o--
        RIGHT            => left(9)                   ,--i--
        Q                => q(8)                     );--o--

  u09: entity work.fuq_mul_bthmux(fuq_mul_bthmux) port map( 
        SNEG             => s_neg                     ,--i--
        SX               => s_x                       ,--i--
        SX2              => s_x2                      ,--i--
        X                => x(8)                      ,--i--
        LEFT             => left(9)                   ,--o--
        RIGHT            => left(10)                  ,--i--
        Q                => q(9)                     );--o--

  u10: entity work.fuq_mul_bthmux(fuq_mul_bthmux) port map( 
        SNEG             => s_neg                     ,--i--
        SX               => s_x                       ,--i--
        SX2              => s_x2                      ,--i--
        X                => x(9)                      ,--i--
        LEFT             => left(10)                  ,--o--
        RIGHT            => left(11)                  ,--i--
        Q                => q(10)                    );--o--

  u11: entity work.fuq_mul_bthmux(fuq_mul_bthmux) port map( 
        SNEG             => s_neg                     ,--i--
        SX               => s_x                       ,--i--
        SX2              => s_x2                      ,--i--
        X                => x(10)                     ,--i--
        LEFT             => left(11)                  ,--o--
        RIGHT            => left(12)                  ,--i--
        Q                => q(11)                    );--o--

  u12: entity work.fuq_mul_bthmux(fuq_mul_bthmux) port map( 
        SNEG             => s_neg                     ,--i--
        SX               => s_x                       ,--i--
        SX2              => s_x2                      ,--i--
        X                => x(11)                     ,--i--
        LEFT             => left(12)                  ,--o--
        RIGHT            => left(13)                  ,--i--
        Q                => q(12)                    );--o--

  u13: entity work.fuq_mul_bthmux(fuq_mul_bthmux) port map( 
        SNEG             => s_neg                     ,--i--
        SX               => s_x                       ,--i--
        SX2              => s_x2                      ,--i--
        X                => x(12)                     ,--i--
        LEFT             => left(13)                  ,--o--
        RIGHT            => left(14)                  ,--i--
        Q                => q(13)                    );--o--

  u14: entity work.fuq_mul_bthmux(fuq_mul_bthmux) port map( 
        SNEG             => s_neg                     ,--i--
        SX               => s_x                       ,--i--
        SX2              => s_x2                      ,--i--
        X                => x(13)                     ,--i--
        LEFT             => left(14)                  ,--o--
        RIGHT            => left(15)                  ,--i--
        Q                => q(14)                    );--o--

  u15: entity work.fuq_mul_bthmux(fuq_mul_bthmux) port map( 
        SNEG             => s_neg                     ,--i--
        SX               => s_x                       ,--i--
        SX2              => s_x2                      ,--i--
        X                => x(14)                     ,--i--
        LEFT             => left(15)                  ,--o--
        RIGHT            => left(16)                  ,--i--
        Q                => q(15)                    );--o--

  u16: entity work.fuq_mul_bthmux(fuq_mul_bthmux) port map( 
        SNEG             => s_neg                     ,--i--
        SX               => s_x                       ,--i--
        SX2              => s_x2                      ,--i--
        X                => x(15)                     ,--i--
        LEFT             => left(16)                  ,--o--
        RIGHT            => s_neg                     ,--i--
        Q                => q(16)                    );--o--



end; -- fuq_tblmul_bthrow ARCHITECTURE
