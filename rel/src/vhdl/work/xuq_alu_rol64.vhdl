-- © IBM Corp. 2020
-- This softcore is licensed under and subject to the terms of the CC-BY 4.0
-- license (https://creativecommons.org/licenses/by/4.0/legalcode). 
-- Additional rights, including the right to physically implement a softcore 
-- that is compliant with the required sections of the Power ISA 
-- Specification, will be available at no cost via the OpenPOWER Foundation. 
-- This README will be updated with additional information when OpenPOWER's 
-- license is available.


LIBRARY ieee;       USE ieee.std_logic_1164.all;
                    use ieee.numeric_std.all;
LIBRARY ibm;        
                    use ibm.std_ulogic_support.all;
                    use ibm.std_ulogic_function_support.all;
LIBRARY support;    
                    use support.power_logic_pkg.all;
library tri;
use tri.tri_latches_pkg.all;

entity xuq_alu_rol64 is generic(expand_type: integer := 2 );    port (
        word            :in  std_ulogic_vector(0 to 1);  -- PPC word mode rotate <2 copies>
        right           :in  std_ulogic_vector(0 to 2);  -- emulate a shift right with a rotate left <2 copies>
        amt             :in  std_ulogic_vector(0 to 5);  -- shift amout [0:63]
        data_i          :in  std_ulogic_vector(0 to 63); -- data to be shifted
        res_rot         :out std_ulogic_vector(0 to 63)  -- mask shows which rotator bits to keep in the result.
);

-- synopsys translate_off
-- synopsys translate_on

end xuq_alu_rol64;

architecture xuq_alu_rol64 of xuq_alu_rol64 is
    constant tiup                       : std_ulogic := '1';
    constant tidn                       : std_ulogic := '0';

    signal right_b :std_ulogic_vector(0 to 2);
    signal amt_b   :std_ulogic_vector(0 to 5);
    signal word_b :std_ulogic_vector(0 to 1);
    signal word_bus, word_bus_b :std_ulogic_vector(0 to 31 );
    signal data_i0_adj_b :std_ulogic_vector(0 to 31 );
    signal data_i_adj, data_i1_adj_b :std_ulogic_vector(0 to 63);

    signal rolx16_0, rolx16_1, rolx16_2, rolx16_3           :std_ulogic_vector(0 to 63);
    signal rolx04_0, rolx04_1, rolx04_2, rolx04_3           :std_ulogic_vector(0 to 63);
    signal rolx01_0, rolx01_1, rolx01_2, rolx01_3, rolx01_4 :std_ulogic_vector(0 to 63);
    signal shd16, shd16_0_b, shd16_1_b :std_ulogic_vector(0 to 63) ;
    signal shd04, shd04_0_b, shd04_1_b :std_ulogic_vector(0 to 63) ;
    signal        shd01_0_b, shd01_1_b, shd01_2_b :std_ulogic_vector(0 to 63) ;
    signal x16_lft_b, x16_rgt_b, lftx16 :std_ulogic_vector(0 to 3);
    signal x04_lft_b, x04_rgt_b, lftx04 :std_ulogic_vector(0 to 3);
    signal x01_lft_b, x01_rgt_b         :std_ulogic_vector(0 to 3);
    signal                       lftx01 :std_ulogic_vector(0 to 4);


   signal lftx01_inv, lftx01_buf0, lftx01_buf1 :std_ulogic_vector(0 to 4);
   signal lftx04_inv, lftx04_buf0, lftx04_buf1 :std_ulogic_vector(0 to 3);
   signal lftx16_inv, lftx16_buf0, lftx16_buf1 :std_ulogic_vector(0 to 3);
   signal lftx16_0_bus, lftx16_1_bus, lftx16_2_bus, lftx16_3_bus               :std_ulogic_vector(0 to 63);
   signal lftx04_0_bus, lftx04_1_bus, lftx04_2_bus, lftx04_3_bus               :std_ulogic_vector(0 to 63);
   signal lftx01_0_bus, lftx01_1_bus, lftx01_2_bus, lftx01_3_bus, lftx01_4_bus :std_ulogic_vector(0 to 63);



begin

   -- -------------------------------------------------------------
   -- how the ppc emulates a rot32 using rot64 hardware.
   -- this makes the wrapping corect for the low order 32 bits.
   -- upper 32 result bits a garbage
   ----------------------------------------------------------------

   word_b(0 to 1) <= not word(0 to 1) ;

   word_bus_b( 0 to 15) <= (0  to 15 => word_b(0) );
   word_bus_b(16 to 31) <= (16 to 31 => word_b(1) );
   word_bus  ( 0 to 15) <= (0  to 15 => word  (0) );
   word_bus  (16 to 31) <= (16 to 31 => word  (1) );


   u_dhi0adj: data_i0_adj_b(0 to 31) <= not( data_i( 0 to 31) and  word_bus_b(0 to 31) );
   u_dhi1adj: data_i1_adj_b(0 to 31) <= not( data_i(32 to 63) and  word_bus  (0 to 31) );
   u_dhiadj:  data_i_adj   (0 to 31) <= not( data_i0_adj_b(0 to 31) and data_i1_adj_b(0 to 31) );

   u_dlo0adj: data_i1_adj_b(32 to 63) <= not( data_i(32 to 63)  );
   u_dloadj:  data_i_adj   (32 to 63) <= not( data_i1_adj_b(32 to 63) );

   -----------------------------------------------------------------
   -- decoder without the adder
   -----------------------------------------------------------------
   --rotate right by [n] == rotate_left by width -[n] == !n + 1

   right_b(0 to 2) <= not right(0 to 2) ;
   u_amt_b:  amt_b(0 to 5)   <= not amt(0 to 5) ;

   u_x16lft_0: x16_lft_b(0) <= not( right_b(0) and amt_b(0) and amt_b(1) );
   u_x16lft_1: x16_lft_b(1) <= not( right_b(0) and amt_b(0) and amt  (1) );
   u_x16lft_2: x16_lft_b(2) <= not( right_b(0) and amt  (0) and amt_b(1) );
   u_x16lft_3: x16_lft_b(3) <= not( right_b(0) and amt  (0) and amt  (1) );

   u_x16rgt_0: x16_rgt_b(0) <= not( right  (0) and amt_b(0) and amt_b(1) );
   u_x16rgt_1: x16_rgt_b(1) <= not( right  (0) and amt_b(0) and amt  (1) );
   u_x16rgt_2: x16_rgt_b(2) <= not( right  (0) and amt  (0) and amt_b(1) );
   u_x16rgt_3: x16_rgt_b(3) <= not( right  (0) and amt  (0) and amt  (1) );

   u_lftx16_0: lftx16(0) <=  not( x16_lft_b(0) and x16_rgt_b(3) ) ;
   u_lftx16_1: lftx16(1) <=  not( x16_lft_b(1) and x16_rgt_b(2) ) ;
   u_lftx16_2: lftx16(2) <=  not( x16_lft_b(2) and x16_rgt_b(1) ) ;
   u_lftx16_3: lftx16(3) <=  not( x16_lft_b(3) and x16_rgt_b(0) ) ;



   u_x04lft_0: x04_lft_b(0) <= not( right_b(1) and amt_b(2) and amt_b(3) );
   u_x04lft_1: x04_lft_b(1) <= not( right_b(1) and amt_b(2) and amt  (3) );
   u_x04lft_2: x04_lft_b(2) <= not( right_b(1) and amt  (2) and amt_b(3) );
   u_x04lft_3: x04_lft_b(3) <= not( right_b(1) and amt  (2) and amt  (3) );

   u_x04rgt_0: x04_rgt_b(0) <= not( right  (1) and amt_b(2) and amt_b(3) );
   u_x04rgt_1: x04_rgt_b(1) <= not( right  (1) and amt_b(2) and amt  (3) );
   u_x04rgt_2: x04_rgt_b(2) <= not( right  (1) and amt  (2) and amt_b(3) );
   u_x04rgt_3: x04_rgt_b(3) <= not( right  (1) and amt  (2) and amt  (3) );

   u_lftx04_0: lftx04(0) <=  not( x04_lft_b(0) and x04_rgt_b(3) ) ;
   u_lftx04_1: lftx04(1) <=  not( x04_lft_b(1) and x04_rgt_b(2) ) ;
   u_lftx04_2: lftx04(2) <=  not( x04_lft_b(2) and x04_rgt_b(1) ) ;
   u_lftx04_3: lftx04(3) <=  not( x04_lft_b(3) and x04_rgt_b(0) ) ;



   u_x01lft_0: x01_lft_b(0) <= not( right_b(2) and amt_b(4) and amt_b(5) );
   u_x01lft_1: x01_lft_b(1) <= not( right_b(2) and amt_b(4) and amt  (5) );
   u_x01lft_2: x01_lft_b(2) <= not( right_b(2) and amt  (4) and amt_b(5) );
   u_x01lft_3: x01_lft_b(3) <= not( right_b(2) and amt  (4) and amt  (5) );

   u_x01rgt_0: x01_rgt_b(0) <= not( right  (2) and amt_b(4) and amt_b(5) );
   u_x01rgt_1: x01_rgt_b(1) <= not( right  (2) and amt_b(4) and amt  (5) );
   u_x01rgt_2: x01_rgt_b(2) <= not( right  (2) and amt  (4) and amt_b(5) );
   u_x01rgt_3: x01_rgt_b(3) <= not( right  (2) and amt  (4) and amt  (5) );

   u_lftx01_0: lftx01(0) <=  not( x01_lft_b(0)                  ) ; -- the shift is like the +1
   u_lftx01_1: lftx01(1) <=  not( x01_lft_b(1) and x01_rgt_b(3) ) ;
   u_lftx01_2: lftx01(2) <=  not( x01_lft_b(2) and x01_rgt_b(2) ) ;
   u_lftx01_3: lftx01(3) <=  not( x01_lft_b(3) and x01_rgt_b(1) ) ;
   u_lftx01_4: lftx01(4) <=  not(                  x01_rgt_b(0) ) ;

   u_lftx16_inv:   lftx16_inv (0 to 3) <= not( lftx16    (0 to 3) );
   u_lftx16_buf0:  lftx16_buf0(0 to 3) <= not( lftx16_inv(0 to 3) );
   u_lftx16_buf1:  lftx16_buf1(0 to 3) <= not( lftx16_inv(0 to 3) );

   u_lftx04_inv:   lftx04_inv (0 to 3) <= not( lftx04    (0 to 3) );
   u_lftx04_buf0:  lftx04_buf0(0 to 3) <= not( lftx04_inv(0 to 3) );
   u_lftx04_buf1:  lftx04_buf1(0 to 3) <= not( lftx04_inv(0 to 3) );

   u_lftx01_inv:   lftx01_inv (0 to 4) <= not( lftx01    (0 to 4) );
   u_lftx01_buf0:  lftx01_buf0(0 to 4) <= not( lftx01_inv(0 to 4) );
   u_lftx01_buf1:  lftx01_buf1(0 to 4) <= not( lftx01_inv(0 to 4) );


   lftx16_0_bus( 0 to 31) <= ( 0 to 31 => lftx16_buf0(0) );
   lftx16_0_bus(32 to 63) <= (32 to 63 => lftx16_buf1(0) );
   lftx16_1_bus( 0 to 31) <= ( 0 to 31 => lftx16_buf0(1) );
   lftx16_1_bus(32 to 63) <= (32 to 63 => lftx16_buf1(1) );
   lftx16_2_bus( 0 to 31) <= ( 0 to 31 => lftx16_buf0(2) );
   lftx16_2_bus(32 to 63) <= (32 to 63 => lftx16_buf1(2) );
   lftx16_3_bus( 0 to 31) <= ( 0 to 31 => lftx16_buf0(3) );
   lftx16_3_bus(32 to 63) <= (32 to 63 => lftx16_buf1(3) );

   lftx04_0_bus( 0 to 31) <= ( 0 to 31 => lftx04_buf0(0) );
   lftx04_0_bus(32 to 63) <= (32 to 63 => lftx04_buf1(0) );
   lftx04_1_bus( 0 to 31) <= ( 0 to 31 => lftx04_buf0(1) );
   lftx04_1_bus(32 to 63) <= (32 to 63 => lftx04_buf1(1) );
   lftx04_2_bus( 0 to 31) <= ( 0 to 31 => lftx04_buf0(2) );
   lftx04_2_bus(32 to 63) <= (32 to 63 => lftx04_buf1(2) );
   lftx04_3_bus( 0 to 31) <= ( 0 to 31 => lftx04_buf0(3) );
   lftx04_3_bus(32 to 63) <= (32 to 63 => lftx04_buf1(3) );

   lftx01_0_bus( 0 to 31) <= ( 0 to 31 => lftx01_buf0(0) );
   lftx01_0_bus(32 to 63) <= (32 to 63 => lftx01_buf1(0) );
   lftx01_1_bus( 0 to 31) <= ( 0 to 31 => lftx01_buf0(1) );
   lftx01_1_bus(32 to 63) <= (32 to 63 => lftx01_buf1(1) );
   lftx01_2_bus( 0 to 31) <= ( 0 to 31 => lftx01_buf0(2) );
   lftx01_2_bus(32 to 63) <= (32 to 63 => lftx01_buf1(2) );
   lftx01_3_bus( 0 to 31) <= ( 0 to 31 => lftx01_buf0(3) );
   lftx01_3_bus(32 to 63) <= (32 to 63 => lftx01_buf1(3) );
   lftx01_4_bus( 0 to 31) <= ( 0 to 31 => lftx01_buf0(4) );
   lftx01_4_bus(32 to 63) <= (32 to 63 => lftx01_buf1(4) );



   -----------------------------------------------------------------
   -- the shifter
   -----------------------------------------------------------------


   rolx16_0(0 to 63) <= data_i_adj( 0 to 63)   ;
   rolx16_1(0 to 63) <= data_i_adj(16 to 63) & data_i_adj(0 to 15) ;
   rolx16_2(0 to 63) <= data_i_adj(32 to 63) & data_i_adj(0 to 31) ;
   rolx16_3(0 to 63) <= data_i_adj(48 to 63) & data_i_adj(0 to 47) ;


   u_shd16_0: shd16_0_b(0 to 63) <= not( ( lftx16_0_bus(0 to 63) and rolx16_0(0 to 63) )  or 
                                         ( lftx16_1_bus(0 to 63) and rolx16_1(0 to 63) )  ); 
   u_shd16_1: shd16_1_b(0 to 63) <= not( ( lftx16_2_bus(0 to 63) and rolx16_2(0 to 63) )  or 
                                         ( lftx16_3_bus(0 to 63) and rolx16_3(0 to 63) )  ); 
   u_shd16:   shd16    (0 to 63) <= not( shd16_0_b(0 to 63) and shd16_1_b(0 to 63) );


   rolx04_0(0 to 63) <= shd16( 0 to 63);
   rolx04_1(0 to 63) <= shd16( 4 to 63) & shd16( 0 to  3);
   rolx04_2(0 to 63) <= shd16( 8 to 63) & shd16( 0 to  7);
   rolx04_3(0 to 63) <= shd16(12 to 63) & shd16( 0 to 11);

   u_shd04_0: shd04_0_b(0 to 63) <= not( ( lftx04_0_bus(0 to 63) and rolx04_0(0 to 63) )  or 
                                         ( lftx04_1_bus(0 to 63) and rolx04_1(0 to 63) )  ); 
   u_shd04_1: shd04_1_b(0 to 63) <= not( ( lftx04_2_bus(0 to 63) and rolx04_2(0 to 63) )  or 
                                         ( lftx04_3_bus(0 to 63) and rolx04_3(0 to 63) )  ); 
   u_shd04:   shd04    (0 to 63) <= not( shd04_0_b(0 to 63) and shd04_1_b(0 to 63) );

   rolx01_0(0 to 63) <= shd04(0 to 63);
   rolx01_1(0 to 63) <= shd04(1 to 63) & shd04( 0 );
   rolx01_2(0 to 63) <= shd04(2 to 63) & shd04( 0 to 1);
   rolx01_3(0 to 63) <= shd04(3 to 63) & shd04( 0 to 2);
   rolx01_4(0 to 63) <= shd04(4 to 63) & shd04( 0 to 3);
    


   u_shd01_0: shd01_0_b(0 to 63) <= not( ( lftx01_0_bus(0 to 63) and rolx01_0(0 to 63) )  or 
                                         ( lftx01_1_bus(0 to 63) and rolx01_1(0 to 63) )  ); 
   u_shd01_1: shd01_1_b(0 to 63) <= not( ( lftx01_2_bus(0 to 63) and rolx01_2(0 to 63) )  or 
                                         ( lftx01_3_bus(0 to 63) and rolx01_3(0 to 63) )  ); 
   u_shd01_2: shd01_2_b(0 to 63) <= not(   lftx01_4_bus(0 to 63) and rolx01_4(0 to 63)    ); 
   u_shd01:   res_rot  (0 to 63) <= not( shd01_0_b(0 to 63) and shd01_1_b(0 to 63) and shd01_2_b(0 to 63) );

end architecture xuq_alu_rol64;
