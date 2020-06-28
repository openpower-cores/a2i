//Copyright 1986-2019 Xilinx, Inc. All Rights Reserved.
//--------------------------------------------------------------------------------
//Tool Version: Vivado v.2019.1.3_CR1055600 (lin64) Build 2644227 Wed Sep  4 09:44:18 MDT 2019
//Date        : Wed Apr  8 10:49:50 2020
//Host        : apdegl15aa.pok.ibm.com running 64-bit Red Hat Enterprise Linux Workstation release 7.5 (Maipo)
//Command     : generate_target a2x_axi_bd_wrapper.bd
//Design      : a2x_axi_bd_wrapper
//Purpose     : IP block netlist
//--------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

module a2x_axi_bd_wrapper
   (clk_in1_n_0,
    clk_in1_p_0);
  input clk_in1_n_0;
  input clk_in1_p_0;

  wire clk_in1_n_0;
  wire clk_in1_p_0;

  a2x_axi_bd a2x_axi_bd_i
       (.clk_in1_n_0(clk_in1_n_0),
        .clk_in1_p_0(clk_in1_p_0));
endmodule
