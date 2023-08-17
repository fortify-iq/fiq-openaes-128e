// Copyright © 2023-present FortifyIQ, Inc. All rights reserved.
//
// This IP Core, FIQ-OpenAES-128e, is a free Soft Macro: you can redistribute it 
// and/or modify it under the terms and conditions of FortifyIQ’s free use
// license (”License”) which is located at
// https://raw.githubusercontent.com/fortify-iq/fiq-openaes-128e/master/LICENSE.
// This license governs use of the accompanying Soft Macro. If you use the
// Soft Macro, you accept this license. If you do not accept the license, do not
// use the Soft Macro.
//
// The License permits non-commercial use, but does not permit commercial use or
// resale. This IP core is distributed in the hope that it will be useful, but
// WITHOUT ANY WARRANTY OR RIGHT TO ECONOMIC DAMAGES; without even the implied
// warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
//
// If you have any questions regarding the Soft Macro of the license, please
// contact kreimer@fortifyiq.com


/*
 Arithmetics for AES encoder/decoder, redundant algo, verilog version 
*/

`include "defines.h"
// Redundant arithmetics, version 11d_238d (`RED = 13)

module DoubleByte(input  wire [8  -1:0] x
                 ,output wire [8  -1:0] q);
  // Matrix=(// Linear = 0x81, 0x3, 0x86, 0x8c, 0x98, 0x30, 0x60, 0xc0)
  assign q[0] = x[0] ^ x[7];
  assign q[1] = x[0] ^ x[1];
  assign q[2] = x[1] ^ x[2] ^ x[7];
  assign q[3] = x[2] ^ x[3] ^ x[7];
  assign q[4] = x[3] ^ x[4] ^ x[7];
  assign q[5] = x[4] ^ x[5];
  assign q[6] = x[5] ^ x[6];
  assign q[7] = x[6] ^ x[7];
endmodule

module InvDoubleByte(input  wire [8  -1:0] x
                    ,output wire [8  -1:0] q);
  // Matrix=(// Linear = 0xfe, 0xfc, 0x7, 0xf0, 0x1f, 0x3f, 0x7f, 0xff)
  assign q[0] = x[1] ^ x[2] ^ x[3] ^ x[4] ^ x[5] ^ x[6] ^ x[7];
  assign q[1] = x[2] ^ x[3] ^ x[4] ^ x[5] ^ x[6] ^ x[7];
  assign q[2] = x[0] ^ x[1] ^ x[2];
  assign q[3] = x[4] ^ x[5] ^ x[6] ^ x[7];
  assign q[4] = x[0] ^ x[1] ^ x[2] ^ x[3] ^ x[4];
  assign q[5] = x[0] ^ x[1] ^ x[2] ^ x[3] ^ x[4] ^ x[5];
  assign q[6] = x[0] ^ x[1] ^ x[2] ^ x[3] ^ x[4] ^ x[5] ^ x[6];
  assign q[7] = x[0] ^ x[1] ^ x[2] ^ x[3] ^ x[4] ^ x[5] ^ x[6] ^ x[7];
endmodule

module BasisFromStd #(parameter W=16) (input  wire [W*8 -1:0] in, output  wire [W*`L -1:0] out);
// Linear = 0xff, 0xaa, 0xcc, 0x88, 0xf0, 0xa0, 0xc0, 0x80
  genvar j;
  generate if(`RED != 13)ERROR_WRONG_PARAMETER_L COMPILE_ERROR(); endgenerate
  generate for(j=0;j<W;j=j+1) begin : G
    wire [7:0]  i; assign i = in[j*8+:8];
    wire [`L -1:0] o; assign out[j*`L+:`L] = o;  
      assign o[00] = i[0] ^ i[1] ^ i[2] ^ i[3] ^ i[4] ^ i[5] ^ i[6] ^ i[7];
      assign o[01] = i[1] ^ i[3] ^ i[5] ^ i[7];
      assign o[02] = i[2] ^ i[3] ^ i[6] ^ i[7];
      assign o[03] = i[3] ^ i[7];
      assign o[04] = i[4] ^ i[5] ^ i[6] ^ i[7];
      assign o[05] = i[5] ^ i[7];
      assign o[06] = i[6] ^ i[7];
      assign o[07] = i[7];
      assign o[08] = 1'b0;
      assign o[09] = 1'b0;
      assign o[10] = 1'b0;
      assign o[11] = 1'b0;
      assign o[12] = 1'b0;
      assign o[13] = 1'b0;
      assign o[14] = 1'b0;
      assign o[15] = 1'b0;
      assign o[16] = 1'b0;
      assign o[17] = 1'b0;
      assign o[18] = 1'b0;
      assign o[19] = 1'b0;
      assign o[20] = 1'b0;
  end endgenerate
endmodule

module BasisToStd #(parameter W=16) (input  wire [W*`L  -1:0] in, output  wire [W*8 -1:0] out);
// Linear = 0x3d0ff, 0x14faa, 0x18acc, 0x1d2388, 0x15edf0, 0x6b6a0, 0x1b24c0, 0x123880
  genvar j;
  generate for(j=0;j<W;j=j+1) begin : G
    wire [`L -1:0] i; assign i = in[j*`L+:`L];
    wire [7:0] o; assign out[j*8+:8] = o;  
      assign o[0] = i[00] ^ i[01] ^ i[02] ^ i[03] ^ i[04] ^ i[05] ^ i[06] ^ i[07] ^ i[12] ^ i[14] ^ i[15] ^ i[16] ^ i[17];
      assign o[1] = i[01] ^ i[03] ^ i[05] ^ i[07] ^ i[08] ^ i[09] ^ i[10] ^ i[11] ^ i[14] ^ i[16];
      assign o[2] = i[02] ^ i[03] ^ i[06] ^ i[07] ^ i[09] ^ i[11] ^ i[15] ^ i[16];
      assign o[3] = i[03] ^ i[07] ^ i[08] ^ i[09] ^ i[13] ^ i[16] ^ i[18] ^ i[19] ^ i[20];
      assign o[4] = i[04] ^ i[05] ^ i[06] ^ i[07] ^ i[08] ^ i[10] ^ i[11] ^ i[13] ^ i[14] ^ i[15] ^ i[16] ^ i[18] ^ i[20];
      assign o[5] = i[05] ^ i[07] ^ i[09] ^ i[10] ^ i[12] ^ i[13] ^ i[15] ^ i[17] ^ i[18];
      assign o[6] = i[06] ^ i[07] ^ i[10] ^ i[13] ^ i[16] ^ i[17] ^ i[19] ^ i[20];
      assign o[7] = i[07] ^ i[11] ^ i[12] ^ i[13] ^ i[17] ^ i[20];
  end endgenerate
endmodule

module Pow2(input  wire [`L -1:0] noise
           ,input  wire [`L -1:0] x
           ,output wire [`L -1:0] q);
// Linear = 0x10001, 0x800, 0x20002, 0x1000, 0x40004, 0x2000, 0x80008, 0x4000, 0x100010, 0x8000, 0x10020, 0x10800, 0x20040, 0x21000, 0x40080, 0x42000, 0x80100, 0x84000, 0x100200, 0x108000, 0x400
  assign q[00] = noise[00] ^ x[00] ^ x[16];
  assign q[01] = noise[01] ^ x[11];
  assign q[02] = noise[02] ^ x[01] ^ x[17];
  assign q[03] = noise[03] ^ x[12];
  assign q[04] = noise[04] ^ x[02] ^ x[18];
  assign q[05] = noise[05] ^ x[13];
  assign q[06] = noise[06] ^ x[03] ^ x[19];
  assign q[07] = noise[07] ^ x[14];
  assign q[08] = noise[08] ^ x[04] ^ x[20];
  assign q[09] = noise[09] ^ x[15];
  assign q[10] = noise[10] ^ x[05] ^ x[16];
  assign q[11] = noise[11] ^ x[11] ^ x[16];
  assign q[12] = noise[12] ^ x[06] ^ x[17];
  assign q[13] = noise[13] ^ x[12] ^ x[17];
  assign q[14] = noise[14] ^ x[07] ^ x[18];
  assign q[15] = noise[15] ^ x[13] ^ x[18];
  assign q[16] = noise[16] ^ x[08] ^ x[19];
  assign q[17] = noise[17] ^ x[14] ^ x[19];
  assign q[18] = noise[18] ^ x[09] ^ x[20];
  assign q[19] = noise[19] ^ x[15] ^ x[20];
  assign q[20] = noise[20] ^ x[10];
endmodule

module Pow4(input  wire [`L -1:0] noise
           ,input  wire [`L -1:0] x
           ,output wire [`L -1:0] q);
// Linear = 0x90101, 0x10800, 0x84800, 0x20040, 0x120202, 0x21000, 0x109000, 0x40080, 0x40404, 0x42000, 0x82100, 0x90900, 0x4008, 0xa4040, 0x104200, 0x121200, 0x8010, 0x148080, 0x8400, 0x42400, 0x10020
  assign q[00] = noise[00] ^ x[00] ^ x[08] ^ x[16] ^ x[19];
  assign q[01] = noise[01] ^ x[11] ^ x[16];
  assign q[02] = noise[02] ^ x[11] ^ x[14] ^ x[19];
  assign q[03] = noise[03] ^ x[06] ^ x[17];
  assign q[04] = noise[04] ^ x[01] ^ x[09] ^ x[17] ^ x[20];
  assign q[05] = noise[05] ^ x[12] ^ x[17];
  assign q[06] = noise[06] ^ x[12] ^ x[15] ^ x[20];
  assign q[07] = noise[07] ^ x[07] ^ x[18];
  assign q[08] = noise[08] ^ x[02] ^ x[10] ^ x[18];
  assign q[09] = noise[09] ^ x[13] ^ x[18];
  assign q[10] = noise[10] ^ x[08] ^ x[13] ^ x[19];
  assign q[11] = noise[11] ^ x[08] ^ x[11] ^ x[16] ^ x[19];
  assign q[12] = noise[12] ^ x[03] ^ x[14];
  assign q[13] = noise[13] ^ x[06] ^ x[14] ^ x[17] ^ x[19];
  assign q[14] = noise[14] ^ x[09] ^ x[14] ^ x[20];
  assign q[15] = noise[15] ^ x[09] ^ x[12] ^ x[17] ^ x[20];
  assign q[16] = noise[16] ^ x[04] ^ x[15];
  assign q[17] = noise[17] ^ x[07] ^ x[15] ^ x[18] ^ x[20];
  assign q[18] = noise[18] ^ x[10] ^ x[15];
  assign q[19] = noise[19] ^ x[10] ^ x[13] ^ x[18];
  assign q[20] = noise[20] ^ x[05] ^ x[16];
endmodule

module Pow8(input  wire [`L -1:0] noise
           ,input  wire [`L -1:0] x
           ,output wire [`L -1:0] q);
// Linear = 0x98111, 0x90900, 0x158880, 0x4008, 0x8cc00, 0xa4040, 0x62440, 0x104200, 0x130222, 0x121200, 0x29010, 0x98910, 0x41080, 0x14c088, 0x48480, 0xac440, 0x2004, 0x146600, 0x52020, 0x131220, 0x82100
  assign q[00] = noise[00] ^ x[00] ^ x[04] ^ x[08] ^ x[15] ^ x[16] ^ x[19];
  assign q[01] = noise[01] ^ x[08] ^ x[11] ^ x[16] ^ x[19];
  assign q[02] = noise[02] ^ x[07] ^ x[11] ^ x[15] ^ x[16] ^ x[18] ^ x[20];
  assign q[03] = noise[03] ^ x[03] ^ x[14];
  assign q[04] = noise[04] ^ x[10] ^ x[11] ^ x[14] ^ x[15] ^ x[19];
  assign q[05] = noise[05] ^ x[06] ^ x[14] ^ x[17] ^ x[19];
  assign q[06] = noise[06] ^ x[06] ^ x[10] ^ x[13] ^ x[17] ^ x[18];
  assign q[07] = noise[07] ^ x[09] ^ x[14] ^ x[20];
  assign q[08] = noise[08] ^ x[01] ^ x[05] ^ x[09] ^ x[16] ^ x[17] ^ x[20];
  assign q[09] = noise[09] ^ x[09] ^ x[12] ^ x[17] ^ x[20];
  assign q[10] = noise[10] ^ x[04] ^ x[12] ^ x[15] ^ x[17];
  assign q[11] = noise[11] ^ x[04] ^ x[08] ^ x[11] ^ x[15] ^ x[16] ^ x[19];
  assign q[12] = noise[12] ^ x[07] ^ x[12] ^ x[18];
  assign q[13] = noise[13] ^ x[03] ^ x[07] ^ x[14] ^ x[15] ^ x[18] ^ x[20];
  assign q[14] = noise[14] ^ x[07] ^ x[10] ^ x[15] ^ x[18];
  assign q[15] = noise[15] ^ x[06] ^ x[10] ^ x[14] ^ x[15] ^ x[17] ^ x[19];
  assign q[16] = noise[16] ^ x[02] ^ x[13];
  assign q[17] = noise[17] ^ x[09] ^ x[10] ^ x[13] ^ x[14] ^ x[18] ^ x[20];
  assign q[18] = noise[18] ^ x[05] ^ x[13] ^ x[16] ^ x[18];
  assign q[19] = noise[19] ^ x[05] ^ x[09] ^ x[12] ^ x[16] ^ x[17] ^ x[20];
  assign q[20] = noise[20] ^ x[08] ^ x[13] ^ x[19];
endmodule

module Pow16(input  wire [`L -1:0] noise
            ,input  wire [`L -1:0] x
            ,output wire [`L -1:0] q);
// Linear = 0x9a115, 0x98910, 0x1d6f00, 0x41080, 0x10a8a0, 0x14c088, 0x135228, 0x48480, 0xed00, 0xac440, 0xa6044, 0x9a914, 0x124240, 0x107680, 0x156220, 0x11e0a8, 0x1002, 0x1796a0, 0x1a3300, 0x2e540, 0x29010
  assign q[00] = noise[00] ^ x[00] ^ x[02] ^ x[04] ^ x[08] ^ x[13] ^ x[15] ^ x[16] ^ x[19];
  assign q[01] = noise[01] ^ x[04] ^ x[08] ^ x[11] ^ x[15] ^ x[16] ^ x[19];
  assign q[02] = noise[02] ^ x[08] ^ x[09] ^ x[10] ^ x[11] ^ x[13] ^ x[14] ^ x[16] ^ x[18] ^ x[19] ^ x[20];
  assign q[03] = noise[03] ^ x[07] ^ x[12] ^ x[18];
  assign q[04] = noise[04] ^ x[05] ^ x[07] ^ x[11] ^ x[13] ^ x[15] ^ x[20];
  assign q[05] = noise[05] ^ x[03] ^ x[07] ^ x[14] ^ x[15] ^ x[18] ^ x[20];
  assign q[06] = noise[06] ^ x[03] ^ x[05] ^ x[09] ^ x[12] ^ x[14] ^ x[16] ^ x[17] ^ x[20];
  assign q[07] = noise[07] ^ x[07] ^ x[10] ^ x[15] ^ x[18];
  assign q[08] = noise[08] ^ x[08] ^ x[10] ^ x[11] ^ x[13] ^ x[14] ^ x[15];
  assign q[09] = noise[09] ^ x[06] ^ x[10] ^ x[14] ^ x[15] ^ x[17] ^ x[19];
  assign q[10] = noise[10] ^ x[02] ^ x[06] ^ x[13] ^ x[14] ^ x[17] ^ x[19];
  assign q[11] = noise[11] ^ x[02] ^ x[04] ^ x[08] ^ x[11] ^ x[13] ^ x[15] ^ x[16] ^ x[19];
  assign q[12] = noise[12] ^ x[06] ^ x[09] ^ x[14] ^ x[17] ^ x[20];
  assign q[13] = noise[13] ^ x[07] ^ x[09] ^ x[10] ^ x[12] ^ x[13] ^ x[14] ^ x[20];
  assign q[14] = noise[14] ^ x[05] ^ x[09] ^ x[13] ^ x[14] ^ x[16] ^ x[18] ^ x[20];
  assign q[15] = noise[15] ^ x[03] ^ x[05] ^ x[07] ^ x[13] ^ x[14] ^ x[15] ^ x[16] ^ x[20];
  assign q[16] = noise[16] ^ x[01] ^ x[12];
  assign q[17] = noise[17] ^ x[05] ^ x[07] ^ x[09] ^ x[10] ^ x[12] ^ x[15] ^ x[16] ^ x[17] ^ x[18] ^ x[20];
  assign q[18] = noise[18] ^ x[08] ^ x[09] ^ x[12] ^ x[13] ^ x[17] ^ x[19] ^ x[20];
  assign q[19] = noise[19] ^ x[06] ^ x[08] ^ x[10] ^ x[13] ^ x[14] ^ x[15] ^ x[17];
  assign q[20] = noise[20] ^ x[04] ^ x[12] ^ x[15] ^ x[17];
endmodule

module Pow64(input  wire [`L -1:0] noise
            ,input  wire [`L -1:0] x
            ,output wire [`L -1:0] q);
// Linear = 0xbb957, 0x9b916, 0x1e2e74, 0x4c488, 0x164be0, 0x5d4e0, 0x132f8, 0x1eb780, 0xd3c44, 0xa4580, 0x127ec0, 0xbb156, 0x1172a0, 0x1343e8, 0x1d3670, 0xd80b0, 0x14808, 0xdc738, 0x1b80ec, 0x25c4, 0x14d08a
  assign q[00] = noise[00] ^ x[00] ^ x[01] ^ x[02] ^ x[04] ^ x[06] ^ x[08] ^ x[11] ^ x[12] ^ x[13] ^ x[15] ^ x[16] ^ x[17] ^ x[19];
  assign q[01] = noise[01] ^ x[01] ^ x[02] ^ x[04] ^ x[08] ^ x[11] ^ x[12] ^ x[13] ^ x[15] ^ x[16] ^ x[19];
  assign q[02] = noise[02] ^ x[02] ^ x[04] ^ x[05] ^ x[06] ^ x[09] ^ x[10] ^ x[11] ^ x[13] ^ x[17] ^ x[18] ^ x[19] ^ x[20];
  assign q[03] = noise[03] ^ x[03] ^ x[07] ^ x[10] ^ x[14] ^ x[15] ^ x[18];
  assign q[04] = noise[04] ^ x[05] ^ x[06] ^ x[07] ^ x[08] ^ x[09] ^ x[11] ^ x[14] ^ x[17] ^ x[18] ^ x[20];
  assign q[05] = noise[05] ^ x[05] ^ x[06] ^ x[07] ^ x[10] ^ x[12] ^ x[14] ^ x[15] ^ x[16] ^ x[18];
  assign q[06] = noise[06] ^ x[03] ^ x[04] ^ x[05] ^ x[06] ^ x[07] ^ x[09] ^ x[12] ^ x[13] ^ x[16];
  assign q[07] = noise[07] ^ x[07] ^ x[08] ^ x[09] ^ x[10] ^ x[12] ^ x[13] ^ x[15] ^ x[17] ^ x[18] ^ x[19] ^ x[20];
  assign q[08] = noise[08] ^ x[02] ^ x[06] ^ x[10] ^ x[11] ^ x[12] ^ x[13] ^ x[16] ^ x[18] ^ x[19];
  assign q[09] = noise[09] ^ x[07] ^ x[08] ^ x[10] ^ x[14] ^ x[17] ^ x[19];
  assign q[10] = noise[10] ^ x[06] ^ x[07] ^ x[09] ^ x[10] ^ x[11] ^ x[12] ^ x[13] ^ x[14] ^ x[17] ^ x[20];
  assign q[11] = noise[11] ^ x[01] ^ x[02] ^ x[04] ^ x[06] ^ x[08] ^ x[12] ^ x[13] ^ x[15] ^ x[16] ^ x[17] ^ x[19];
  assign q[12] = noise[12] ^ x[05] ^ x[07] ^ x[09] ^ x[12] ^ x[13] ^ x[14] ^ x[16] ^ x[20];
  assign q[13] = noise[13] ^ x[03] ^ x[05] ^ x[06] ^ x[07] ^ x[08] ^ x[09] ^ x[14] ^ x[16] ^ x[17] ^ x[20];
  assign q[14] = noise[14] ^ x[04] ^ x[05] ^ x[06] ^ x[09] ^ x[10] ^ x[12] ^ x[13] ^ x[16] ^ x[18] ^ x[19] ^ x[20];
  assign q[15] = noise[15] ^ x[04] ^ x[05] ^ x[07] ^ x[15] ^ x[16] ^ x[18] ^ x[19];
  assign q[16] = noise[16] ^ x[03] ^ x[11] ^ x[14] ^ x[16];
  assign q[17] = noise[17] ^ x[03] ^ x[04] ^ x[05] ^ x[08] ^ x[09] ^ x[10] ^ x[14] ^ x[15] ^ x[16] ^ x[18] ^ x[19];
  assign q[18] = noise[18] ^ x[02] ^ x[03] ^ x[05] ^ x[06] ^ x[07] ^ x[15] ^ x[16] ^ x[17] ^ x[19] ^ x[20];
  assign q[19] = noise[19] ^ x[02] ^ x[06] ^ x[07] ^ x[08] ^ x[10] ^ x[13];
  assign q[20] = noise[20] ^ x[01] ^ x[03] ^ x[07] ^ x[12] ^ x[14] ^ x[15] ^ x[18] ^ x[20];
endmodule

module APow2(input  wire [`L -1:0] noise
            ,input  wire [`L -1:0] x
            ,output wire [`L -1:0] q);
// Linear = 0x10001, 0x800, 0x20002, 0x502d1, 0x132a55, 0x1d2ff2, 0x146c2a, 0x1a5fe4, 0x100010, 0x8000, 0x10020, 0x10800, 0x20040, 0x21000, 0x40080, 0x42000, 0x80100, 0x84000, 0x100200, 0x108000, 0x400
// Shift = 0x64
  assign q[00] = noise[00] ^ x[00] ^ x[16];
  assign q[01] = noise[01] ^ x[11];
  assign q[02] = noise[02] ^ x[01] ^ x[17] ^ 1'b1;
  assign q[03] = noise[03] ^ x[00] ^ x[04] ^ x[06] ^ x[07] ^ x[09] ^ x[16] ^ x[18];
  assign q[04] = noise[04] ^ x[00] ^ x[02] ^ x[04] ^ x[06] ^ x[09] ^ x[11] ^ x[13] ^ x[16] ^ x[17] ^ x[20];
  assign q[05] = noise[05] ^ x[01] ^ x[04] ^ x[05] ^ x[06] ^ x[07] ^ x[08] ^ x[09] ^ x[10] ^ x[11] ^ x[13] ^ x[16] ^ x[18] ^ x[19] ^ x[20] ^ 1'b1;
  assign q[06] = noise[06] ^ x[01] ^ x[03] ^ x[05] ^ x[10] ^ x[11] ^ x[13] ^ x[14] ^ x[18] ^ x[20] ^ 1'b1;
  assign q[07] = noise[07] ^ x[02] ^ x[05] ^ x[06] ^ x[07] ^ x[08] ^ x[09] ^ x[10] ^ x[11] ^ x[12] ^ x[14] ^ x[17] ^ x[19] ^ x[20];
  assign q[08] = noise[08] ^ x[04] ^ x[20];
  assign q[09] = noise[09] ^ x[15];
  assign q[10] = noise[10] ^ x[05] ^ x[16];
  assign q[11] = noise[11] ^ x[11] ^ x[16];
  assign q[12] = noise[12] ^ x[06] ^ x[17];
  assign q[13] = noise[13] ^ x[12] ^ x[17];
  assign q[14] = noise[14] ^ x[07] ^ x[18];
  assign q[15] = noise[15] ^ x[13] ^ x[18];
  assign q[16] = noise[16] ^ x[08] ^ x[19];
  assign q[17] = noise[17] ^ x[14] ^ x[19];
  assign q[18] = noise[18] ^ x[09] ^ x[20];
  assign q[19] = noise[19] ^ x[15] ^ x[20];
  assign q[20] = noise[20] ^ x[10];
endmodule

module APow2Double(input  wire [`L -1:0] noise
                  ,input  wire [`L -1:0] x
                  ,output wire [`L -1:0] q);
// Linear = 0x10401, 0x10801, 0x20802, 0x702d3, 0x162884, 0xe05a7, 0x943d8, 0xe33ce, 0xa5ff4, 0x108010, 0x18420, 0x820, 0x30840, 0x1040, 0x61080, 0x2080, 0xc2100, 0x4100, 0x184200, 0x8200, 0x108400
// Shift = 0xac
  assign q[00] = noise[00] ^ x[00] ^ x[10] ^ x[16];
  assign q[01] = noise[01] ^ x[00] ^ x[11] ^ x[16];
  assign q[02] = noise[02] ^ x[01] ^ x[11] ^ x[17] ^ 1'b1;
  assign q[03] = noise[03] ^ x[00] ^ x[01] ^ x[04] ^ x[06] ^ x[07] ^ x[09] ^ x[16] ^ x[17] ^ x[18] ^ 1'b1;
  assign q[04] = noise[04] ^ x[02] ^ x[07] ^ x[11] ^ x[13] ^ x[17] ^ x[18] ^ x[20];
  assign q[05] = noise[05] ^ x[00] ^ x[01] ^ x[02] ^ x[05] ^ x[07] ^ x[08] ^ x[10] ^ x[17] ^ x[18] ^ x[19] ^ 1'b1;
  assign q[06] = noise[06] ^ x[03] ^ x[04] ^ x[06] ^ x[07] ^ x[08] ^ x[09] ^ x[14] ^ x[16] ^ x[19];
  assign q[07] = noise[07] ^ x[01] ^ x[02] ^ x[03] ^ x[06] ^ x[07] ^ x[08] ^ x[09] ^ x[12] ^ x[13] ^ x[17] ^ x[18] ^ x[19] ^ 1'b1;
  assign q[08] = noise[08] ^ x[02] ^ x[04] ^ x[05] ^ x[06] ^ x[07] ^ x[08] ^ x[09] ^ x[10] ^ x[11] ^ x[12] ^ x[14] ^ x[17] ^ x[19];
  assign q[09] = noise[09] ^ x[04] ^ x[15] ^ x[20];
  assign q[10] = noise[10] ^ x[05] ^ x[10] ^ x[15] ^ x[16];
  assign q[11] = noise[11] ^ x[05] ^ x[11];
  assign q[12] = noise[12] ^ x[06] ^ x[11] ^ x[16] ^ x[17];
  assign q[13] = noise[13] ^ x[06] ^ x[12];
  assign q[14] = noise[14] ^ x[07] ^ x[12] ^ x[17] ^ x[18];
  assign q[15] = noise[15] ^ x[07] ^ x[13];
  assign q[16] = noise[16] ^ x[08] ^ x[13] ^ x[18] ^ x[19];
  assign q[17] = noise[17] ^ x[08] ^ x[14];
  assign q[18] = noise[18] ^ x[09] ^ x[14] ^ x[19] ^ x[20];
  assign q[19] = noise[19] ^ x[09] ^ x[15];
  assign q[20] = noise[20] ^ x[10] ^ x[15] ^ x[20];
endmodule

module APow2Triple(input  wire [`L -1:0] noise
                  ,input  wire [`L -1:0] x
                  ,output wire [`L -1:0] q);
// Linear = 0x400, 0x10001, 0x800, 0x20002, 0x502d1, 0x132a55, 0x1d2ff2, 0x146c2a, 0x1a5fe4, 0x100010, 0x8400, 0x10020, 0x10800, 0x20040, 0x21000, 0x40080, 0x42000, 0x80100, 0x84000, 0x100200, 0x108000
// Shift = 0xc8
  assign q[00] = noise[00] ^ x[10];
  assign q[01] = noise[01] ^ x[00] ^ x[16];
  assign q[02] = noise[02] ^ x[11];
  assign q[03] = noise[03] ^ x[01] ^ x[17] ^ 1'b1;
  assign q[04] = noise[04] ^ x[00] ^ x[04] ^ x[06] ^ x[07] ^ x[09] ^ x[16] ^ x[18];
  assign q[05] = noise[05] ^ x[00] ^ x[02] ^ x[04] ^ x[06] ^ x[09] ^ x[11] ^ x[13] ^ x[16] ^ x[17] ^ x[20];
  assign q[06] = noise[06] ^ x[01] ^ x[04] ^ x[05] ^ x[06] ^ x[07] ^ x[08] ^ x[09] ^ x[10] ^ x[11] ^ x[13] ^ x[16] ^ x[18] ^ x[19] ^ x[20] ^ 1'b1;
  assign q[07] = noise[07] ^ x[01] ^ x[03] ^ x[05] ^ x[10] ^ x[11] ^ x[13] ^ x[14] ^ x[18] ^ x[20] ^ 1'b1;
  assign q[08] = noise[08] ^ x[02] ^ x[05] ^ x[06] ^ x[07] ^ x[08] ^ x[09] ^ x[10] ^ x[11] ^ x[12] ^ x[14] ^ x[17] ^ x[19] ^ x[20];
  assign q[09] = noise[09] ^ x[04] ^ x[20];
  assign q[10] = noise[10] ^ x[10] ^ x[15];
  assign q[11] = noise[11] ^ x[05] ^ x[16];
  assign q[12] = noise[12] ^ x[11] ^ x[16];
  assign q[13] = noise[13] ^ x[06] ^ x[17];
  assign q[14] = noise[14] ^ x[12] ^ x[17];
  assign q[15] = noise[15] ^ x[07] ^ x[18];
  assign q[16] = noise[16] ^ x[13] ^ x[18];
  assign q[17] = noise[17] ^ x[08] ^ x[19];
  assign q[18] = noise[18] ^ x[14] ^ x[19];
  assign q[19] = noise[19] ^ x[09] ^ x[20];
  assign q[20] = noise[20] ^ x[15] ^ x[20];
endmodule

module Double(input  wire [`L -1:0] i
             ,output wire [`L -1:0] o);
// Linear = 0x100001, 0x3, 0x6, 0xc, 0x18, 0x30, 0x60, 0xc0, 0x180, 0x300, 0x100600, 0xc00, 0x1800, 0x3000, 0x6000, 0xc000, 0x18000, 0x30000, 0x60000, 0xc0000, 0x180000
  assign o[00] = i[00] ^ i[20];
  assign o[01] = i[00] ^ i[01];
  assign o[02] = i[01] ^ i[02];
  assign o[03] = i[02] ^ i[03];
  assign o[04] = i[03] ^ i[04];
  assign o[05] = i[04] ^ i[05];
  assign o[06] = i[05] ^ i[06];
  assign o[07] = i[06] ^ i[07];
  assign o[08] = i[07] ^ i[08];
  assign o[09] = i[08] ^ i[09];
  assign o[10] = i[09] ^ i[10] ^ i[20];
  assign o[11] = i[10] ^ i[11];
  assign o[12] = i[11] ^ i[12];
  assign o[13] = i[12] ^ i[13];
  assign o[14] = i[13] ^ i[14];
  assign o[15] = i[14] ^ i[15];
  assign o[16] = i[15] ^ i[16];
  assign o[17] = i[16] ^ i[17];
  assign o[18] = i[17] ^ i[18];
  assign o[19] = i[18] ^ i[19];
  assign o[20] = i[19] ^ i[20];
endmodule

module Mul2(input  wire [`L -1:0] i
           ,output wire [`L -1:0] o);
// Linear = 0x100000, 0x1, 0x2, 0x4, 0x8, 0x10, 0x20, 0x40, 0x80, 0x100, 0x100200, 0x400, 0x800, 0x1000, 0x2000, 0x4000, 0x8000, 0x10000, 0x20000, 0x40000, 0x80000
  assign o[00] = i[20];
  assign o[01] = i[00];
  assign o[02] = i[01];
  assign o[03] = i[02];
  assign o[04] = i[03];
  assign o[05] = i[04];
  assign o[06] = i[05];
  assign o[07] = i[06];
  assign o[08] = i[07];
  assign o[09] = i[08];
  assign o[10] = i[09] ^ i[20];
  assign o[11] = i[10];
  assign o[12] = i[11];
  assign o[13] = i[12];
  assign o[14] = i[13];
  assign o[15] = i[14];
  assign o[16] = i[15];
  assign o[17] = i[16];
  assign o[18] = i[17];
  assign o[19] = i[18];
  assign o[20] = i[19];
endmodule

module GenerateNoise #(parameter W=16)(input  wire [W*`RED -1:0] rand_i, output  wire [W*`L -1:0] noise_o);
// Linear = 0x1, 0x2, 0x5, 0xb, 0x17, 0x2e, 0x5c, 0xb8, 0x171, 0x2e2, 0x5c4, 0xb88, 0x1710, 0xe20, 0x1c40, 0x1880, 0x1100, 0x200, 0x400, 0x800, 0x1000
  genvar j;
  generate for(j=0;j<W;j=j+1) begin : G
    wire [12:0]  i; assign i = rand_i[j*`RED+:`RED];
    wire [20:0] o; assign noise_o[j*`L+:`L] = o;
    assign o[00] = i[00];
    assign o[01] = i[01];
    assign o[02] = i[00] ^ i[02];
    assign o[03] = i[00] ^ i[01] ^ i[03];
    assign o[04] = i[00] ^ i[01] ^ i[02] ^ i[04];
    assign o[05] = i[01] ^ i[02] ^ i[03] ^ i[05];
    assign o[06] = i[02] ^ i[03] ^ i[04] ^ i[06];
    assign o[07] = i[03] ^ i[04] ^ i[05] ^ i[07];
    assign o[08] = i[00] ^ i[04] ^ i[05] ^ i[06] ^ i[08];
    assign o[09] = i[01] ^ i[05] ^ i[06] ^ i[07] ^ i[09];
    assign o[10] = i[02] ^ i[06] ^ i[07] ^ i[08] ^ i[10];
    assign o[11] = i[03] ^ i[07] ^ i[08] ^ i[09] ^ i[11];
    assign o[12] = i[04] ^ i[08] ^ i[09] ^ i[10] ^ i[12];
    assign o[13] = i[05] ^ i[09] ^ i[10] ^ i[11];
    assign o[14] = i[06] ^ i[10] ^ i[11] ^ i[12];
    assign o[15] = i[07] ^ i[11] ^ i[12];
    assign o[16] = i[08] ^ i[12];
    assign o[17] = i[09];
    assign o[18] = i[10];
    assign o[19] = i[11];
    assign o[20] = i[12];
  end endgenerate
endmodule

module MulEstd(input  wire [`L -1:0] noise
              ,input  wire [`L -1:0] x
              ,output wire [`L -1:0] q);
// Linear = 0x40001, 0x80002, 0x100004, 0x9, 0x12, 0x24, 0x48, 0x90, 0x120, 0x240, 0x40480, 0x80900, 0x101200, 0x2400, 0x4800, 0x9000, 0x12000, 0x24000, 0x48000, 0x90000, 0x120000
  assign q[00] = noise[00] ^ x[00] ^ x[18];
  assign q[01] = noise[01] ^ x[01] ^ x[19];
  assign q[02] = noise[02] ^ x[02] ^ x[20];
  assign q[03] = noise[03] ^ x[00] ^ x[03];
  assign q[04] = noise[04] ^ x[01] ^ x[04];
  assign q[05] = noise[05] ^ x[02] ^ x[05];
  assign q[06] = noise[06] ^ x[03] ^ x[06];
  assign q[07] = noise[07] ^ x[04] ^ x[07];
  assign q[08] = noise[08] ^ x[05] ^ x[08];
  assign q[09] = noise[09] ^ x[06] ^ x[09];
  assign q[10] = noise[10] ^ x[07] ^ x[10] ^ x[18];
  assign q[11] = noise[11] ^ x[08] ^ x[11] ^ x[19];
  assign q[12] = noise[12] ^ x[09] ^ x[12] ^ x[20];
  assign q[13] = noise[13] ^ x[10] ^ x[13];
  assign q[14] = noise[14] ^ x[11] ^ x[14];
  assign q[15] = noise[15] ^ x[12] ^ x[15];
  assign q[16] = noise[16] ^ x[13] ^ x[16];
  assign q[17] = noise[17] ^ x[14] ^ x[17];
  assign q[18] = noise[18] ^ x[15] ^ x[18];
  assign q[19] = noise[19] ^ x[16] ^ x[19];
  assign q[20] = noise[20] ^ x[17] ^ x[20];
endmodule

module MulBstd(input  wire [`L -1:0] noise
              ,input  wire [`L -1:0] x
              ,output wire [`L -1:0] q);
// Linear = 0xc0001, 0x180002, 0x100005, 0xb, 0x16, 0x2c, 0x58, 0xb0, 0x160, 0x2c0, 0xc0580, 0x180b00, 0x101600, 0x2c00, 0x5800, 0xb000, 0x16000, 0x2c000, 0x58000, 0xb0000, 0x160000
  assign q[00] = noise[00] ^ x[00] ^ x[18] ^ x[19];
  assign q[01] = noise[01] ^ x[01] ^ x[19] ^ x[20];
  assign q[02] = noise[02] ^ x[00] ^ x[02] ^ x[20];
  assign q[03] = noise[03] ^ x[00] ^ x[01] ^ x[03];
  assign q[04] = noise[04] ^ x[01] ^ x[02] ^ x[04];
  assign q[05] = noise[05] ^ x[02] ^ x[03] ^ x[05];
  assign q[06] = noise[06] ^ x[03] ^ x[04] ^ x[06];
  assign q[07] = noise[07] ^ x[04] ^ x[05] ^ x[07];
  assign q[08] = noise[08] ^ x[05] ^ x[06] ^ x[08];
  assign q[09] = noise[09] ^ x[06] ^ x[07] ^ x[09];
  assign q[10] = noise[10] ^ x[07] ^ x[08] ^ x[10] ^ x[18] ^ x[19];
  assign q[11] = noise[11] ^ x[08] ^ x[09] ^ x[11] ^ x[19] ^ x[20];
  assign q[12] = noise[12] ^ x[09] ^ x[10] ^ x[12] ^ x[20];
  assign q[13] = noise[13] ^ x[10] ^ x[11] ^ x[13];
  assign q[14] = noise[14] ^ x[11] ^ x[12] ^ x[14];
  assign q[15] = noise[15] ^ x[12] ^ x[13] ^ x[15];
  assign q[16] = noise[16] ^ x[13] ^ x[14] ^ x[16];
  assign q[17] = noise[17] ^ x[14] ^ x[15] ^ x[17];
  assign q[18] = noise[18] ^ x[15] ^ x[16] ^ x[18];
  assign q[19] = noise[19] ^ x[16] ^ x[17] ^ x[19];
  assign q[20] = noise[20] ^ x[17] ^ x[18] ^ x[20];
endmodule

module MulDstd(input  wire [`L -1:0] noise
              ,input  wire [`L -1:0] x
              ,output wire [`L -1:0] q);
// Linear = 0x140001, 0x80003, 0x100006, 0xd, 0x1a, 0x34, 0x68, 0xd0, 0x1a0, 0x340, 0x140680, 0x80d00, 0x101a00, 0x3400, 0x6800, 0xd000, 0x1a000, 0x34000, 0x68000, 0xd0000, 0x1a0000
  assign q[00] = noise[00] ^ x[00] ^ x[18] ^ x[20];
  assign q[01] = noise[01] ^ x[00] ^ x[01] ^ x[19];
  assign q[02] = noise[02] ^ x[01] ^ x[02] ^ x[20];
  assign q[03] = noise[03] ^ x[00] ^ x[02] ^ x[03];
  assign q[04] = noise[04] ^ x[01] ^ x[03] ^ x[04];
  assign q[05] = noise[05] ^ x[02] ^ x[04] ^ x[05];
  assign q[06] = noise[06] ^ x[03] ^ x[05] ^ x[06];
  assign q[07] = noise[07] ^ x[04] ^ x[06] ^ x[07];
  assign q[08] = noise[08] ^ x[05] ^ x[07] ^ x[08];
  assign q[09] = noise[09] ^ x[06] ^ x[08] ^ x[09];
  assign q[10] = noise[10] ^ x[07] ^ x[09] ^ x[10] ^ x[18] ^ x[20];
  assign q[11] = noise[11] ^ x[08] ^ x[10] ^ x[11] ^ x[19];
  assign q[12] = noise[12] ^ x[09] ^ x[11] ^ x[12] ^ x[20];
  assign q[13] = noise[13] ^ x[10] ^ x[12] ^ x[13];
  assign q[14] = noise[14] ^ x[11] ^ x[13] ^ x[14];
  assign q[15] = noise[15] ^ x[12] ^ x[14] ^ x[15];
  assign q[16] = noise[16] ^ x[13] ^ x[15] ^ x[16];
  assign q[17] = noise[17] ^ x[14] ^ x[16] ^ x[17];
  assign q[18] = noise[18] ^ x[15] ^ x[17] ^ x[18];
  assign q[19] = noise[19] ^ x[16] ^ x[18] ^ x[19];
  assign q[20] = noise[20] ^ x[17] ^ x[19] ^ x[20];
endmodule

module A(input  wire [`L -1:0] noise
        ,input  wire [`L -1:0] x
        ,output wire [`L -1:0] q);
// Linear = 0x1, 0x2, 0x4, 0x47109, 0xc9313, 0x1d5726, 0x1aae4c, 0x155c98, 0x100, 0x200, 0x400, 0x800, 0x1000, 0x2000, 0x4000, 0x8000, 0x10000, 0x20000, 0x40000, 0x80000, 0x100000
// Shift = 0x64
  assign q[00] = noise[00] ^ x[00];
  assign q[01] = noise[01] ^ x[01];
  assign q[02] = noise[02] ^ x[02] ^ 1'b1;
  assign q[03] = noise[03] ^ x[00] ^ x[03] ^ x[08] ^ x[12] ^ x[13] ^ x[14] ^ x[18];
  assign q[04] = noise[04] ^ x[00] ^ x[01] ^ x[04] ^ x[08] ^ x[09] ^ x[12] ^ x[15] ^ x[18] ^ x[19];
  assign q[05] = noise[05] ^ x[01] ^ x[02] ^ x[05] ^ x[08] ^ x[09] ^ x[10] ^ x[12] ^ x[14] ^ x[16] ^ x[18] ^ x[19] ^ x[20] ^ 1'b1;
  assign q[06] = noise[06] ^ x[02] ^ x[03] ^ x[06] ^ x[09] ^ x[10] ^ x[11] ^ x[13] ^ x[15] ^ x[17] ^ x[19] ^ x[20] ^ 1'b1;
  assign q[07] = noise[07] ^ x[03] ^ x[04] ^ x[07] ^ x[10] ^ x[11] ^ x[12] ^ x[14] ^ x[16] ^ x[18] ^ x[20];
  assign q[08] = noise[08] ^ x[08];
  assign q[09] = noise[09] ^ x[09];
  assign q[10] = noise[10] ^ x[10];
  assign q[11] = noise[11] ^ x[11];
  assign q[12] = noise[12] ^ x[12];
  assign q[13] = noise[13] ^ x[13];
  assign q[14] = noise[14] ^ x[14];
  assign q[15] = noise[15] ^ x[15];
  assign q[16] = noise[16] ^ x[16];
  assign q[17] = noise[17] ^ x[17];
  assign q[18] = noise[18] ^ x[18];
  assign q[19] = noise[19] ^ x[19];
  assign q[20] = noise[20] ^ x[20];
endmodule

module ADouble(input  wire [`L -1:0] noise
              ,input  wire [`L -1:0] x
              ,output wire [`L -1:0] q);
// Linear = 0x100001, 0x3, 0x6, 0x4710d, 0x8e21a, 0x11c435, 0x7f96a, 0xff2d4, 0x155d98, 0x300, 0x100600, 0xc00, 0x1800, 0x3000, 0x6000, 0xc000, 0x18000, 0x30000, 0x60000, 0xc0000, 0x180000
// Shift = 0xac
  assign q[00] = noise[00] ^ x[00] ^ x[20];
  assign q[01] = noise[01] ^ x[00] ^ x[01];
  assign q[02] = noise[02] ^ x[01] ^ x[02] ^ 1'b1;
  assign q[03] = noise[03] ^ x[00] ^ x[02] ^ x[03] ^ x[08] ^ x[12] ^ x[13] ^ x[14] ^ x[18] ^ 1'b1;
  assign q[04] = noise[04] ^ x[01] ^ x[03] ^ x[04] ^ x[09] ^ x[13] ^ x[14] ^ x[15] ^ x[19];
  assign q[05] = noise[05] ^ x[00] ^ x[02] ^ x[04] ^ x[05] ^ x[10] ^ x[14] ^ x[15] ^ x[16] ^ x[20] ^ 1'b1;
  assign q[06] = noise[06] ^ x[01] ^ x[03] ^ x[05] ^ x[06] ^ x[08] ^ x[11] ^ x[12] ^ x[13] ^ x[14] ^ x[15] ^ x[16] ^ x[17] ^ x[18];
  assign q[07] = noise[07] ^ x[02] ^ x[04] ^ x[06] ^ x[07] ^ x[09] ^ x[12] ^ x[13] ^ x[14] ^ x[15] ^ x[16] ^ x[17] ^ x[18] ^ x[19] ^ 1'b1;
  assign q[08] = noise[08] ^ x[03] ^ x[04] ^ x[07] ^ x[08] ^ x[10] ^ x[11] ^ x[12] ^ x[14] ^ x[16] ^ x[18] ^ x[20];
  assign q[09] = noise[09] ^ x[08] ^ x[09];
  assign q[10] = noise[10] ^ x[09] ^ x[10] ^ x[20];
  assign q[11] = noise[11] ^ x[10] ^ x[11];
  assign q[12] = noise[12] ^ x[11] ^ x[12];
  assign q[13] = noise[13] ^ x[12] ^ x[13];
  assign q[14] = noise[14] ^ x[13] ^ x[14];
  assign q[15] = noise[15] ^ x[14] ^ x[15];
  assign q[16] = noise[16] ^ x[15] ^ x[16];
  assign q[17] = noise[17] ^ x[16] ^ x[17];
  assign q[18] = noise[18] ^ x[17] ^ x[18];
  assign q[19] = noise[19] ^ x[18] ^ x[19];
  assign q[20] = noise[20] ^ x[19] ^ x[20];
endmodule

module ATriple(input  wire [`L -1:0] noise
              ,input  wire [`L -1:0] x
              ,output wire [`L -1:0] q);
// Linear = 0x100000, 0x1, 0x2, 0x4, 0x47109, 0xc9313, 0x1d5726, 0x1aae4c, 0x155c98, 0x100, 0x100200, 0x400, 0x800, 0x1000, 0x2000, 0x4000, 0x8000, 0x10000, 0x20000, 0x40000, 0x80000
// Shift = 0xc8
  assign q[00] = noise[00] ^ x[20];
  assign q[01] = noise[01] ^ x[00];
  assign q[02] = noise[02] ^ x[01];
  assign q[03] = noise[03] ^ x[02] ^ 1'b1;
  assign q[04] = noise[04] ^ x[00] ^ x[03] ^ x[08] ^ x[12] ^ x[13] ^ x[14] ^ x[18];
  assign q[05] = noise[05] ^ x[00] ^ x[01] ^ x[04] ^ x[08] ^ x[09] ^ x[12] ^ x[15] ^ x[18] ^ x[19];
  assign q[06] = noise[06] ^ x[01] ^ x[02] ^ x[05] ^ x[08] ^ x[09] ^ x[10] ^ x[12] ^ x[14] ^ x[16] ^ x[18] ^ x[19] ^ x[20] ^ 1'b1;
  assign q[07] = noise[07] ^ x[02] ^ x[03] ^ x[06] ^ x[09] ^ x[10] ^ x[11] ^ x[13] ^ x[15] ^ x[17] ^ x[19] ^ x[20] ^ 1'b1;
  assign q[08] = noise[08] ^ x[03] ^ x[04] ^ x[07] ^ x[10] ^ x[11] ^ x[12] ^ x[14] ^ x[16] ^ x[18] ^ x[20];
  assign q[09] = noise[09] ^ x[08];
  assign q[10] = noise[10] ^ x[09] ^ x[20];
  assign q[11] = noise[11] ^ x[10];
  assign q[12] = noise[12] ^ x[11];
  assign q[13] = noise[13] ^ x[12];
  assign q[14] = noise[14] ^ x[13];
  assign q[15] = noise[15] ^ x[14];
  assign q[16] = noise[16] ^ x[15];
  assign q[17] = noise[17] ^ x[16];
  assign q[18] = noise[18] ^ x[17];
  assign q[19] = noise[19] ^ x[18];
  assign q[20] = noise[20] ^ x[19];
endmodule

module InvA(input  wire [`L -1:0] noise
           ,input  wire [`L -1:0] x
           ,output wire [`L -1:0] q);
// Linear = 0x1, 0x2, 0x4, 0x47109, 0xc9313, 0x1d5726, 0x1edf4d, 0x1dbe9a, 0x100, 0x200, 0x400, 0x800, 0x1000, 0x2000, 0x4000, 0x8000, 0x10000, 0x20000, 0x40000, 0x80000, 0x100000
// Shift = 0x4
  assign q[00] = noise[00] ^ x[00];
  assign q[01] = noise[01] ^ x[01];
  assign q[02] = noise[02] ^ x[02] ^ 1'b1;
  assign q[03] = noise[03] ^ x[00] ^ x[03] ^ x[08] ^ x[12] ^ x[13] ^ x[14] ^ x[18];
  assign q[04] = noise[04] ^ x[00] ^ x[01] ^ x[04] ^ x[08] ^ x[09] ^ x[12] ^ x[15] ^ x[18] ^ x[19];
  assign q[05] = noise[05] ^ x[01] ^ x[02] ^ x[05] ^ x[08] ^ x[09] ^ x[10] ^ x[12] ^ x[14] ^ x[16] ^ x[18] ^ x[19] ^ x[20];
  assign q[06] = noise[06] ^ x[00] ^ x[02] ^ x[03] ^ x[06] ^ x[08] ^ x[09] ^ x[10] ^ x[11] ^ x[12] ^ x[14] ^ x[15] ^ x[17] ^ x[18] ^ x[19] ^ x[20];
  assign q[07] = noise[07] ^ x[01] ^ x[03] ^ x[04] ^ x[07] ^ x[09] ^ x[10] ^ x[11] ^ x[12] ^ x[13] ^ x[15] ^ x[16] ^ x[18] ^ x[19] ^ x[20];
  assign q[08] = noise[08] ^ x[08];
  assign q[09] = noise[09] ^ x[09];
  assign q[10] = noise[10] ^ x[10];
  assign q[11] = noise[11] ^ x[11];
  assign q[12] = noise[12] ^ x[12];
  assign q[13] = noise[13] ^ x[13];
  assign q[14] = noise[14] ^ x[14];
  assign q[15] = noise[15] ^ x[15];
  assign q[16] = noise[16] ^ x[16];
  assign q[17] = noise[17] ^ x[17];
  assign q[18] = noise[18] ^ x[18];
  assign q[19] = noise[19] ^ x[19];
  assign q[20] = noise[20] ^ x[20];
endmodule

module Pow2InvA(input  wire [`L -1:0] noise
               ,input  wire [`L -1:0] x
               ,output wire [`L -1:0] q);
// Linear = 0x10001, 0x800, 0x20002, 0x1000, 0x40004, 0x2000, 0xc7109, 0x4000, 0x1c9313, 0x8000, 0x1c5726, 0x10800, 0x1cdf4d, 0x21000, 0x19be9a, 0x42000, 0x80100, 0x84000, 0x100200, 0x108000, 0x400
// Shift = 0x10
  assign q[00] = noise[00] ^ x[00] ^ x[16];
  assign q[01] = noise[01] ^ x[11];
  assign q[02] = noise[02] ^ x[01] ^ x[17];
  assign q[03] = noise[03] ^ x[12];
  assign q[04] = noise[04] ^ x[02] ^ x[18] ^ 1'b1;
  assign q[05] = noise[05] ^ x[13];
  assign q[06] = noise[06] ^ x[00] ^ x[03] ^ x[08] ^ x[12] ^ x[13] ^ x[14] ^ x[18] ^ x[19];
  assign q[07] = noise[07] ^ x[14];
  assign q[08] = noise[08] ^ x[00] ^ x[01] ^ x[04] ^ x[08] ^ x[09] ^ x[12] ^ x[15] ^ x[18] ^ x[19] ^ x[20];
  assign q[09] = noise[09] ^ x[15];
  assign q[10] = noise[10] ^ x[01] ^ x[02] ^ x[05] ^ x[08] ^ x[09] ^ x[10] ^ x[12] ^ x[14] ^ x[18] ^ x[19] ^ x[20];
  assign q[11] = noise[11] ^ x[11] ^ x[16];
  assign q[12] = noise[12] ^ x[00] ^ x[02] ^ x[03] ^ x[06] ^ x[08] ^ x[09] ^ x[10] ^ x[11] ^ x[12] ^ x[14] ^ x[15] ^ x[18] ^ x[19] ^ x[20];
  assign q[13] = noise[13] ^ x[12] ^ x[17];
  assign q[14] = noise[14] ^ x[01] ^ x[03] ^ x[04] ^ x[07] ^ x[09] ^ x[10] ^ x[11] ^ x[12] ^ x[13] ^ x[15] ^ x[16] ^ x[19] ^ x[20];
  assign q[15] = noise[15] ^ x[13] ^ x[18];
  assign q[16] = noise[16] ^ x[08] ^ x[19];
  assign q[17] = noise[17] ^ x[14] ^ x[19];
  assign q[18] = noise[18] ^ x[09] ^ x[20];
  assign q[19] = noise[19] ^ x[15] ^ x[20];
  assign q[20] = noise[20] ^ x[10];
endmodule
