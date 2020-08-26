-- © IBM Corp. 2020
-- This softcore is licensed under and subject to the terms of the CC-BY 4.0
-- license (https://creativecommons.org/licenses/by/4.0/legalcode). 
-- Additional rights, including the right to physically implement a softcore 
-- that is compliant with the required sections of the Power ISA 
-- Specification, will be available at no cost via the OpenPOWER Foundation. 
-- This README will be updated with additional information when OpenPOWER's 
-- license is available.



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
