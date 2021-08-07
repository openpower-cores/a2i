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


library ieee,ibm,support,tri,work;
   use ieee.std_logic_1164.all;
   use ibm.std_ulogic_unsigned.all;
   use ibm.std_ulogic_support.all; 
   use ibm.std_ulogic_function_support.all;
   use support.power_logic_pkg.all;
   use tri.tri_latches_pkg.all;
   use ibm.std_ulogic_ao_support.all; 
   use ibm.std_ulogic_mux_support.all; 


 
entity fuq_alg_bypmux is
generic(       expand_type               : integer := 2  ); -- 0 - ibm tech, 1 - other );
port(
      ----------- BYPASS CONTROLS -----------------
      ex2_byp_sel_byp_neg      :in  std_ulogic;
      ex2_byp_sel_byp_pos      :in  std_ulogic;
      ex2_byp_sel_neg          :in  std_ulogic;
      ex2_byp_sel_pos          :in  std_ulogic;
      ex2_prd_sel_neg_hi       :in  std_ulogic;
      ex2_prd_sel_neg_lo       :in  std_ulogic;
      ex2_prd_sel_neg_lohi     :in  std_ulogic;
      ex2_prd_sel_pos_hi       :in  std_ulogic;
      ex2_prd_sel_pos_lo       :in  std_ulogic;
      ex2_prd_sel_pos_lohi     :in  std_ulogic;

      ----------- BYPASS DATA -----------------
      ex2_sh_lvl3              :in  std_ulogic_vector(0 to 162);
      f_fmt_ex2_pass_frac      :in  std_ulogic_vector(0 to 52);

      ---------- BYPASS OUTPUT ---------------
      f_alg_ex2_res            :out std_ulogic_vector(0 to 162)
);



end fuq_alg_bypmux; -- ENTITY

architecture fuq_alg_bypmux of fuq_alg_bypmux is

    constant tiup : std_ulogic := '1';
    constant tidn : std_ulogic := '0';

    signal m0_b, m1_b            :std_ulogic_vector(0 to 162);
    signal ex2_sh_lvl3_b         :std_ulogic_vector(0 to 162);
    signal f_fmt_ex2_pass_frac_b :std_ulogic_vector(0 to 52);


begin




i0:  ex2_sh_lvl3_b(0 to 162)        <= not( ex2_sh_lvl3(0 to 162)       );
i1:  f_fmt_ex2_pass_frac_b(0 to 52) <= not( f_fmt_ex2_pass_frac(0 to 52) );

----------------------------------------------------------------

m0_000:  m0_b(0 to 52)   <= not( ( (0 to 52=> ex2_byp_sel_pos)         and ex2_sh_lvl3          (0 to 52) ) or
                                 ( (0 to 52=> ex2_byp_sel_neg)         and ex2_sh_lvl3_b        (0 to 52) ) );

m1_000:  m1_b(0 to 52)   <= not( ( (0 to 52=> ex2_byp_sel_byp_pos)     and f_fmt_ex2_pass_frac  (0 to 52) ) or
                                 ( (0 to 52=> ex2_byp_sel_byp_neg)     and f_fmt_ex2_pass_frac_b(0 to 52) ) );
-----------------------------------------------------------------

m0_053:  m0_b(53 to 98)    <= not( (53 to 98=> ex2_prd_sel_pos_hi)     and ex2_sh_lvl3  (53 to 98) );
m1_053:  m1_b(53 to 98)    <= not( (53 to 98=> ex2_prd_sel_neg_hi)     and ex2_sh_lvl3_b(53 to 98) );

-----------------------------------------------------------------

m0_099:  m0_b(99 to 130)   <= not( (99 to 130=> ex2_prd_sel_pos_lohi)  and ex2_sh_lvl3  (99 to 130) );
m1_099:  m1_b(99 to 130)   <= not( (99 to 130=> ex2_prd_sel_neg_lohi)  and ex2_sh_lvl3_b(99 to 130) );

-----------------------------------------------------------------

m0_131:  m0_b(131 to 162)   <= not( (131 to 162=> ex2_prd_sel_pos_lo)  and ex2_sh_lvl3  (131 to 162) );
m1_131:  m1_b(131 to 162)   <= not( (131 to 162=> ex2_prd_sel_neg_lo)  and ex2_sh_lvl3_b(131 to 162) );

-----------------------------------------------------------------

mx: f_alg_ex2_res(0 to 162) <= not( m0_b(0 to 162) and m1_b(0 to 162 ) );

end; -- fuq_alg_bypmux ARCHITECTURE
