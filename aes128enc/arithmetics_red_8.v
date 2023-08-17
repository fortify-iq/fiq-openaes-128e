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
// Redundant arithmetics, version 169_17b (`RED = 8)

module DoubleByte(input  wire [8  -1:0] x
                 ,output wire [8  -1:0] q);
  // Matrix=(// Linear = 0xd2, 0xa4, 0x49, 0x40, 0x80, 0xd3, 0x74, 0xe9)
  assign q[0] = x[1] ^ x[4] ^ x[6] ^ x[7];
  assign q[1] = x[2] ^ x[5] ^ x[7];
  assign q[2] = x[0] ^ x[3] ^ x[6];
  assign q[3] = x[6];
  assign q[4] = x[7];
  assign q[5] = x[0] ^ x[1] ^ x[4] ^ x[6] ^ x[7];
  assign q[6] = x[2] ^ x[4] ^ x[5] ^ x[6];
  assign q[7] = x[0] ^ x[3] ^ x[5] ^ x[6] ^ x[7];
endmodule

module InvDoubleByte(input  wire [8  -1:0] x
                    ,output wire [8  -1:0] q);
  // Matrix=(// Linear = 0x21, 0x43, 0x86, 0x2d, 0x5a, 0x94, 0x8, 0x10)
  assign q[0] = x[0] ^ x[5];
  assign q[1] = x[0] ^ x[1] ^ x[6];
  assign q[2] = x[1] ^ x[2] ^ x[7];
  assign q[3] = x[0] ^ x[2] ^ x[3] ^ x[5];
  assign q[4] = x[1] ^ x[3] ^ x[4] ^ x[6];
  assign q[5] = x[2] ^ x[4] ^ x[7];
  assign q[6] = x[3];
  assign q[7] = x[4];
endmodule

module BasisFromStd #(parameter W=16) (input  wire [W*8 -1:0] in, output  wire [W*`L -1:0] out);
// Linear = 0xf5, 0x8c, 0xaa, 0xc0, 0xe4, 0x1e, 0x60, 0x72
  genvar j;
  generate if(`RED != 8)ERROR_WRONG_PARAMETER_L COMPILE_ERROR(); endgenerate
  generate for(j=0;j<W;j=j+1) begin : G
    wire [7:0]  i; assign i = in[j*8+:8];
    wire [`L -1:0] o; assign out[j*`L+:`L] = o;  
      assign o[00] = i[0] ^ i[2] ^ i[4] ^ i[5] ^ i[6] ^ i[7];
      assign o[01] = i[2] ^ i[3] ^ i[7];
      assign o[02] = i[1] ^ i[3] ^ i[5] ^ i[7];
      assign o[03] = i[6] ^ i[7];
      assign o[04] = i[2] ^ i[5] ^ i[6] ^ i[7];
      assign o[05] = i[1] ^ i[2] ^ i[3] ^ i[4];
      assign o[06] = i[5] ^ i[6];
      assign o[07] = i[1] ^ i[4] ^ i[5] ^ i[6];
      assign o[08] = 1'b0;
      assign o[09] = 1'b0;
      assign o[10] = 1'b0;
      assign o[11] = 1'b0;
      assign o[12] = 1'b0;
      assign o[13] = 1'b0;
      assign o[14] = 1'b0;
      assign o[15] = 1'b0;
  end endgenerate
endmodule

module BasisToStd #(parameter W=16) (input  wire [W*`L  -1:0] in, output  wire [W*8 -1:0] out);
// Linear = 0xd7cf, 0x711e, 0xe7b2, 0xbf52, 0xc0de, 0x18aa, 0x77ea, 0x22e2
  genvar j;
  generate for(j=0;j<W;j=j+1) begin : G
    wire [`L -1:0] i; assign i = in[j*`L+:`L];
    wire [7:0] o; assign out[j*8+:8] = o;  
      assign o[0] = i[00] ^ i[01] ^ i[02] ^ i[03] ^ i[06] ^ i[07] ^ i[08] ^ i[09] ^ i[10] ^ i[12] ^ i[14] ^ i[15];
      assign o[1] = i[01] ^ i[02] ^ i[03] ^ i[04] ^ i[08] ^ i[12] ^ i[13] ^ i[14];
      assign o[2] = i[01] ^ i[04] ^ i[05] ^ i[07] ^ i[08] ^ i[09] ^ i[10] ^ i[13] ^ i[14] ^ i[15];
      assign o[3] = i[01] ^ i[04] ^ i[06] ^ i[08] ^ i[09] ^ i[10] ^ i[11] ^ i[12] ^ i[13] ^ i[15];
      assign o[4] = i[01] ^ i[02] ^ i[03] ^ i[04] ^ i[06] ^ i[07] ^ i[14] ^ i[15];
      assign o[5] = i[01] ^ i[03] ^ i[05] ^ i[07] ^ i[11] ^ i[12];
      assign o[6] = i[01] ^ i[03] ^ i[05] ^ i[06] ^ i[07] ^ i[08] ^ i[09] ^ i[10] ^ i[12] ^ i[13] ^ i[14];
      assign o[7] = i[01] ^ i[05] ^ i[06] ^ i[07] ^ i[09] ^ i[13];
  end endgenerate
endmodule

module Pow2(input  wire [`L -1:0] noise
           ,input  wire [`L -1:0] x
           ,output wire [`L -1:0] q);
// Linear = 0x101, 0x100, 0x202, 0x200, 0x404, 0x400, 0x808, 0x800, 0x1010, 0x1000, 0x2020, 0x2000, 0x4040, 0x4000, 0x8080, 0x8000
  assign q[00] = noise[00] ^ x[00] ^ x[08];
  assign q[01] = noise[01] ^ x[08];
  assign q[02] = noise[02] ^ x[01] ^ x[09];
  assign q[03] = noise[03] ^ x[09];
  assign q[04] = noise[04] ^ x[02] ^ x[10];
  assign q[05] = noise[05] ^ x[10];
  assign q[06] = noise[06] ^ x[03] ^ x[11];
  assign q[07] = noise[07] ^ x[11];
  assign q[08] = noise[08] ^ x[04] ^ x[12];
  assign q[09] = noise[09] ^ x[12];
  assign q[10] = noise[10] ^ x[05] ^ x[13];
  assign q[11] = noise[11] ^ x[13];
  assign q[12] = noise[12] ^ x[06] ^ x[14];
  assign q[13] = noise[13] ^ x[14];
  assign q[14] = noise[14] ^ x[07] ^ x[15];
  assign q[15] = noise[15] ^ x[15];
endmodule

module Pow4(input  wire [`L -1:0] noise
           ,input  wire [`L -1:0] x
           ,output wire [`L -1:0] q);
// Linear = 0x1111, 0x1010, 0x1100, 0x1000, 0x2222, 0x2020, 0x2200, 0x2000, 0x4444, 0x4040, 0x4400, 0x4000, 0x8888, 0x8080, 0x8800, 0x8000
  assign q[00] = noise[00] ^ x[00] ^ x[04] ^ x[08] ^ x[12];
  assign q[01] = noise[01] ^ x[04] ^ x[12];
  assign q[02] = noise[02] ^ x[08] ^ x[12];
  assign q[03] = noise[03] ^ x[12];
  assign q[04] = noise[04] ^ x[01] ^ x[05] ^ x[09] ^ x[13];
  assign q[05] = noise[05] ^ x[05] ^ x[13];
  assign q[06] = noise[06] ^ x[09] ^ x[13];
  assign q[07] = noise[07] ^ x[13];
  assign q[08] = noise[08] ^ x[02] ^ x[06] ^ x[10] ^ x[14];
  assign q[09] = noise[09] ^ x[06] ^ x[14];
  assign q[10] = noise[10] ^ x[10] ^ x[14];
  assign q[11] = noise[11] ^ x[14];
  assign q[12] = noise[12] ^ x[03] ^ x[07] ^ x[11] ^ x[15];
  assign q[13] = noise[13] ^ x[07] ^ x[15];
  assign q[14] = noise[14] ^ x[11] ^ x[15];
  assign q[15] = noise[15] ^ x[15];
endmodule

module Pow8(input  wire [`L -1:0] noise
           ,input  wire [`L -1:0] x
           ,output wire [`L -1:0] q);
// Linear = 0x5555, 0x4444, 0x5050, 0x4040, 0x5500, 0x4400, 0x5000, 0x4000, 0xaaaa, 0x8888, 0xa0a0, 0x8080, 0xaa00, 0x8800, 0xa000, 0x8000
  assign q[00] = noise[00] ^ x[00] ^ x[02] ^ x[04] ^ x[06] ^ x[08] ^ x[10] ^ x[12] ^ x[14];
  assign q[01] = noise[01] ^ x[02] ^ x[06] ^ x[10] ^ x[14];
  assign q[02] = noise[02] ^ x[04] ^ x[06] ^ x[12] ^ x[14];
  assign q[03] = noise[03] ^ x[06] ^ x[14];
  assign q[04] = noise[04] ^ x[08] ^ x[10] ^ x[12] ^ x[14];
  assign q[05] = noise[05] ^ x[10] ^ x[14];
  assign q[06] = noise[06] ^ x[12] ^ x[14];
  assign q[07] = noise[07] ^ x[14];
  assign q[08] = noise[08] ^ x[01] ^ x[03] ^ x[05] ^ x[07] ^ x[09] ^ x[11] ^ x[13] ^ x[15];
  assign q[09] = noise[09] ^ x[03] ^ x[07] ^ x[11] ^ x[15];
  assign q[10] = noise[10] ^ x[05] ^ x[07] ^ x[13] ^ x[15];
  assign q[11] = noise[11] ^ x[07] ^ x[15];
  assign q[12] = noise[12] ^ x[09] ^ x[11] ^ x[13] ^ x[15];
  assign q[13] = noise[13] ^ x[11] ^ x[15];
  assign q[14] = noise[14] ^ x[13] ^ x[15];
  assign q[15] = noise[15] ^ x[15];
endmodule

`ifndef NEW_LA

module Pow16(input  wire [`L -1:0] noise
            ,input  wire [`L -1:0] x
            ,output wire [`L -1:0] q);
// Linear = 0xffff, 0xaaaa, 0xcccc, 0x8888, 0xf0f0, 0xa0a0, 0xc0c0, 0x8080, 0xff00, 0xaa00, 0xcc00, 0x8800, 0xf000, 0xa000, 0xc000, 0x8000
  assign q[00] = noise[00] ^ x[00] ^ x[01] ^ x[02] ^ x[03] ^ x[04] ^ x[05] ^ x[06] ^ x[07] ^ x[08] ^ x[09] ^ x[10] ^ x[11] ^ x[12] ^ x[13] ^ x[14] ^ x[15];
  assign q[01] = noise[01] ^ x[01] ^ x[03] ^ x[05] ^ x[07] ^ x[09] ^ x[11] ^ x[13] ^ x[15];
  assign q[02] = noise[02] ^ x[02] ^ x[03] ^ x[06] ^ x[07] ^ x[10] ^ x[11] ^ x[14] ^ x[15];
  assign q[03] = noise[03] ^ x[03] ^ x[07] ^ x[11] ^ x[15];
  assign q[04] = noise[04] ^ x[04] ^ x[05] ^ x[06] ^ x[07] ^ x[12] ^ x[13] ^ x[14] ^ x[15];
  assign q[05] = noise[05] ^ x[05] ^ x[07] ^ x[13] ^ x[15];
  assign q[06] = noise[06] ^ x[06] ^ x[07] ^ x[14] ^ x[15];
  assign q[07] = noise[07] ^ x[07] ^ x[15];
  assign q[08] = noise[08] ^ x[08] ^ x[09] ^ x[10] ^ x[11] ^ x[12] ^ x[13] ^ x[14] ^ x[15];
  assign q[09] = noise[09] ^ x[09] ^ x[11] ^ x[13] ^ x[15];
  assign q[10] = noise[10] ^ x[10] ^ x[11] ^ x[14] ^ x[15];
  assign q[11] = noise[11] ^ x[11] ^ x[15];
  assign q[12] = noise[12] ^ x[12] ^ x[13] ^ x[14] ^ x[15];
  assign q[13] = noise[13] ^ x[13] ^ x[15];
  assign q[14] = noise[14] ^ x[14] ^ x[15];
  assign q[15] = noise[15] ^ x[15];
endmodule
`endif

module Pow64(input  wire [`L -1:0] noise
            ,input  wire [`L -1:0] x
            ,output wire [`L -1:0] q);
// Linear = 0xf, 0xf0, 0xf00, 0xf000, 0xa, 0xa0, 0xa00, 0xa000, 0xc, 0xc0, 0xc00, 0xc000, 0x8, 0x80, 0x800, 0x8000
  assign q[00] = noise[00] ^ x[00] ^ x[01] ^ x[02] ^ x[03];
  assign q[01] = noise[01] ^ x[04] ^ x[05] ^ x[06] ^ x[07];
  assign q[02] = noise[02] ^ x[08] ^ x[09] ^ x[10] ^ x[11];
  assign q[03] = noise[03] ^ x[12] ^ x[13] ^ x[14] ^ x[15];
  assign q[04] = noise[04] ^ x[01] ^ x[03];
  assign q[05] = noise[05] ^ x[05] ^ x[07];
  assign q[06] = noise[06] ^ x[09] ^ x[11];
  assign q[07] = noise[07] ^ x[13] ^ x[15];
  assign q[08] = noise[08] ^ x[02] ^ x[03];
  assign q[09] = noise[09] ^ x[06] ^ x[07];
  assign q[10] = noise[10] ^ x[10] ^ x[11];
  assign q[11] = noise[11] ^ x[14] ^ x[15];
  assign q[12] = noise[12] ^ x[03];
  assign q[13] = noise[13] ^ x[07];
  assign q[14] = noise[14] ^ x[11];
  assign q[15] = noise[15] ^ x[15];
endmodule

`ifndef NEW_LA

module APow2(input  wire [`L -1:0] noise
            ,input  wire [`L -1:0] x
            ,output wire [`L -1:0] q);
// Linear = 0x35db, 0x8f06, 0x202, 0xcc4c, 0xb905, 0x26e2, 0xf29e, 0x1e38, 0x1010, 0x1000, 0x2020, 0x2000, 0x4040, 0x4000, 0x8080, 0x8000
// Shift = 0xa9
  assign q[00] = noise[00] ^ x[00] ^ x[01] ^ x[03] ^ x[04] ^ x[06] ^ x[07] ^ x[08] ^ x[10] ^ x[12] ^ x[13] ^ 1'b1;
  assign q[01] = noise[01] ^ x[01] ^ x[02] ^ x[08] ^ x[09] ^ x[10] ^ x[11] ^ x[15];
  assign q[02] = noise[02] ^ x[01] ^ x[09];
  assign q[03] = noise[03] ^ x[02] ^ x[03] ^ x[06] ^ x[10] ^ x[11] ^ x[14] ^ x[15] ^ 1'b1;
  assign q[04] = noise[04] ^ x[00] ^ x[02] ^ x[08] ^ x[11] ^ x[12] ^ x[13] ^ x[15];
  assign q[05] = noise[05] ^ x[01] ^ x[05] ^ x[06] ^ x[07] ^ x[09] ^ x[10] ^ x[13] ^ 1'b1;
  assign q[06] = noise[06] ^ x[01] ^ x[02] ^ x[03] ^ x[04] ^ x[07] ^ x[09] ^ x[12] ^ x[13] ^ x[14] ^ x[15];
  assign q[07] = noise[07] ^ x[03] ^ x[04] ^ x[05] ^ x[09] ^ x[10] ^ x[11] ^ x[12] ^ 1'b1;
  assign q[08] = noise[08] ^ x[04] ^ x[12];
  assign q[09] = noise[09] ^ x[12];
  assign q[10] = noise[10] ^ x[05] ^ x[13];
  assign q[11] = noise[11] ^ x[13];
  assign q[12] = noise[12] ^ x[06] ^ x[14];
  assign q[13] = noise[13] ^ x[14];
  assign q[14] = noise[14] ^ x[07] ^ x[15];
  assign q[15] = noise[15] ^ x[15];
endmodule

module APow2Double(input  wire [`L -1:0] noise
                  ,input  wire [`L -1:0] x
                  ,output wire [`L -1:0] q);
// Linear = 0xb080, 0x50e0, 0xb5bb, 0x2fc6, 0x2c2, 0xb917, 0x3683, 0x913b, 0xb1d4, 0xa53f, 0xfabe, 0x5b9b, 0x18fa, 0xc28e, 0x4e78, 0x7030
// Shift = 0x51
  assign q[00] = noise[00] ^ x[07] ^ x[12] ^ x[13] ^ x[15] ^ 1'b1;
  assign q[01] = noise[01] ^ x[05] ^ x[06] ^ x[07] ^ x[12] ^ x[14];
  assign q[02] = noise[02] ^ x[00] ^ x[01] ^ x[03] ^ x[04] ^ x[05] ^ x[07] ^ x[08] ^ x[10] ^ x[12] ^ x[13] ^ x[15];
  assign q[03] = noise[03] ^ x[01] ^ x[02] ^ x[06] ^ x[07] ^ x[08] ^ x[09] ^ x[10] ^ x[11] ^ x[13];
  assign q[04] = noise[04] ^ x[01] ^ x[06] ^ x[07] ^ x[09] ^ 1'b1;
  assign q[05] = noise[05] ^ x[00] ^ x[01] ^ x[02] ^ x[04] ^ x[08] ^ x[11] ^ x[12] ^ x[13] ^ x[15];
  assign q[06] = noise[06] ^ x[00] ^ x[01] ^ x[07] ^ x[09] ^ x[10] ^ x[12] ^ x[13] ^ 1'b1;
  assign q[07] = noise[07] ^ x[00] ^ x[01] ^ x[03] ^ x[04] ^ x[05] ^ x[08] ^ x[12] ^ x[15];
  assign q[08] = noise[08] ^ x[02] ^ x[04] ^ x[06] ^ x[07] ^ x[08] ^ x[12] ^ x[13] ^ x[15];
  assign q[09] = noise[09] ^ x[00] ^ x[01] ^ x[02] ^ x[03] ^ x[04] ^ x[05] ^ x[08] ^ x[10] ^ x[13] ^ x[15];
  assign q[10] = noise[10] ^ x[01] ^ x[02] ^ x[03] ^ x[04] ^ x[05] ^ x[07] ^ x[09] ^ x[11] ^ x[12] ^ x[13] ^ x[14] ^ x[15];
  assign q[11] = noise[11] ^ x[00] ^ x[01] ^ x[03] ^ x[04] ^ x[07] ^ x[08] ^ x[09] ^ x[11] ^ x[12] ^ x[14];
  assign q[12] = noise[12] ^ x[01] ^ x[03] ^ x[04] ^ x[05] ^ x[06] ^ x[07] ^ x[11] ^ x[12];
  assign q[13] = noise[13] ^ x[01] ^ x[02] ^ x[03] ^ x[07] ^ x[09] ^ x[14] ^ x[15];
  assign q[14] = noise[14] ^ x[03] ^ x[04] ^ x[05] ^ x[06] ^ x[09] ^ x[10] ^ x[11] ^ x[14];
  assign q[15] = noise[15] ^ x[04] ^ x[05] ^ x[12] ^ x[13] ^ x[14];
endmodule

module APow2Triple(input  wire [`L -1:0] noise
                  ,input  wire [`L -1:0] x
                  ,output wire [`L -1:0] q);
// Linear = 0x855b, 0xdfe6, 0xb7b9, 0xe38a, 0xbbc7, 0x9ff5, 0xc41d, 0x8f03, 0xa1c4, 0xb53f, 0xda9e, 0x7b9b, 0x58ba, 0x828e, 0xcef8, 0xf030
// Shift = 0xf8
  assign q[00] = noise[00] ^ x[00] ^ x[01] ^ x[03] ^ x[04] ^ x[06] ^ x[08] ^ x[10] ^ x[15];
  assign q[01] = noise[01] ^ x[01] ^ x[02] ^ x[05] ^ x[06] ^ x[07] ^ x[08] ^ x[09] ^ x[10] ^ x[11] ^ x[12] ^ x[14] ^ x[15];
  assign q[02] = noise[02] ^ x[00] ^ x[03] ^ x[04] ^ x[05] ^ x[07] ^ x[08] ^ x[09] ^ x[10] ^ x[12] ^ x[13] ^ x[15];
  assign q[03] = noise[03] ^ x[01] ^ x[03] ^ x[07] ^ x[08] ^ x[09] ^ x[13] ^ x[14] ^ x[15] ^ 1'b1;
  assign q[04] = noise[04] ^ x[00] ^ x[01] ^ x[02] ^ x[06] ^ x[07] ^ x[08] ^ x[09] ^ x[11] ^ x[12] ^ x[13] ^ x[15] ^ 1'b1;
  assign q[05] = noise[05] ^ x[00] ^ x[02] ^ x[04] ^ x[05] ^ x[06] ^ x[07] ^ x[08] ^ x[09] ^ x[10] ^ x[11] ^ x[12] ^ x[15] ^ 1'b1;
  assign q[06] = noise[06] ^ x[00] ^ x[02] ^ x[03] ^ x[04] ^ x[10] ^ x[14] ^ x[15] ^ 1'b1;
  assign q[07] = noise[07] ^ x[00] ^ x[01] ^ x[08] ^ x[09] ^ x[10] ^ x[11] ^ x[15] ^ 1'b1;
  assign q[08] = noise[08] ^ x[02] ^ x[06] ^ x[07] ^ x[08] ^ x[13] ^ x[15];
  assign q[09] = noise[09] ^ x[00] ^ x[01] ^ x[02] ^ x[03] ^ x[04] ^ x[05] ^ x[08] ^ x[10] ^ x[12] ^ x[13] ^ x[15];
  assign q[10] = noise[10] ^ x[01] ^ x[02] ^ x[03] ^ x[04] ^ x[07] ^ x[09] ^ x[11] ^ x[12] ^ x[14] ^ x[15];
  assign q[11] = noise[11] ^ x[00] ^ x[01] ^ x[03] ^ x[04] ^ x[07] ^ x[08] ^ x[09] ^ x[11] ^ x[12] ^ x[13] ^ x[14];
  assign q[12] = noise[12] ^ x[01] ^ x[03] ^ x[04] ^ x[05] ^ x[07] ^ x[11] ^ x[12] ^ x[14];
  assign q[13] = noise[13] ^ x[01] ^ x[02] ^ x[03] ^ x[07] ^ x[09] ^ x[15];
  assign q[14] = noise[14] ^ x[03] ^ x[04] ^ x[05] ^ x[06] ^ x[07] ^ x[09] ^ x[10] ^ x[11] ^ x[14] ^ x[15];
  assign q[15] = noise[15] ^ x[04] ^ x[05] ^ x[12] ^ x[13] ^ x[14] ^ x[15];
endmodule

`endif

module Double(input  wire [`L -1:0] i
             ,output wire [`L -1:0] o);
// Linear = 0x4a00, 0xde00, 0xbc01, 0x7802, 0xf004, 0xe009, 0xc012, 0x8025, 0x4a, 0x94, 0x128, 0x250, 0x4a0, 0x940, 0x1280, 0x2500
  assign o[00] = i[09] ^ i[11] ^ i[14];
  assign o[01] = i[09] ^ i[10] ^ i[11] ^ i[12] ^ i[14] ^ i[15];
  assign o[02] = i[00] ^ i[10] ^ i[11] ^ i[12] ^ i[13] ^ i[15];
  assign o[03] = i[01] ^ i[11] ^ i[12] ^ i[13] ^ i[14];
  assign o[04] = i[02] ^ i[12] ^ i[13] ^ i[14] ^ i[15];
  assign o[05] = i[00] ^ i[03] ^ i[13] ^ i[14] ^ i[15];
  assign o[06] = i[01] ^ i[04] ^ i[14] ^ i[15];
  assign o[07] = i[00] ^ i[02] ^ i[05] ^ i[15];
  assign o[08] = i[01] ^ i[03] ^ i[06];
  assign o[09] = i[02] ^ i[04] ^ i[07];
  assign o[10] = i[03] ^ i[05] ^ i[08];
  assign o[11] = i[04] ^ i[06] ^ i[09];
  assign o[12] = i[05] ^ i[07] ^ i[10];
  assign o[13] = i[06] ^ i[08] ^ i[11];
  assign o[14] = i[07] ^ i[09] ^ i[12];
  assign o[15] = i[08] ^ i[10] ^ i[13];
endmodule

module Mul2(input  wire [`L -1:0] i
           ,output wire [`L -1:0] o);
// Linear = 0x8000, 0x8001, 0x2, 0x4, 0x8, 0x10, 0x20, 0x40, 0x80, 0x100, 0x200, 0x400, 0x800, 0x1000, 0x2000, 0x4000
  assign o[00] = i[15];
  assign o[01] = i[00] ^ i[15];
  assign o[02] = i[01];
  assign o[03] = i[02];
  assign o[04] = i[03];
  assign o[05] = i[04];
  assign o[06] = i[05];
  assign o[07] = i[06];
  assign o[08] = i[07];
  assign o[09] = i[08];
  assign o[10] = i[09];
  assign o[11] = i[10];
  assign o[12] = i[11];
  assign o[13] = i[12];
  assign o[14] = i[13];
  assign o[15] = i[14];
endmodule

module GenerateNoise #(parameter W=16)(input  wire [W*`RED -1:0] rand_i, output  wire [W*`L -1:0] noise_o);
// Linear = 0x1, 0x2, 0x4, 0x9, 0x12, 0x25, 0x4b, 0x96, 0x2d, 0x5a, 0xb4, 0x68, 0xd0, 0xa0, 0x40, 0x80
  genvar j;
  generate for(j=0;j<W;j=j+1) begin : G
    wire [7:0]  i; assign i = rand_i[j*`RED+:`RED];
    wire [15:0] o; assign noise_o[j*`L+:`L] = o;
    assign o[00] = i[0];
    assign o[01] = i[1];
    assign o[02] = i[2];
    assign o[03] = i[0] ^ i[3];
    assign o[04] = i[1] ^ i[4];
    assign o[05] = i[0] ^ i[2] ^ i[5];
    assign o[06] = i[0] ^ i[1] ^ i[3] ^ i[6];
    assign o[07] = i[1] ^ i[2] ^ i[4] ^ i[7];
    assign o[08] = i[0] ^ i[2] ^ i[3] ^ i[5];
    assign o[09] = i[1] ^ i[3] ^ i[4] ^ i[6];
    assign o[10] = i[2] ^ i[4] ^ i[5] ^ i[7];
    assign o[11] = i[3] ^ i[5] ^ i[6];
    assign o[12] = i[4] ^ i[6] ^ i[7];
    assign o[13] = i[5] ^ i[7];
    assign o[14] = i[6];
    assign o[15] = i[7];
  end endgenerate
endmodule

module MulEstd(input  wire [`L -1:0] noise
              ,input  wire [`L -1:0] x
              ,output wire [`L -1:0] q);
// Linear = 0x1a01, 0x2e02, 0x5c04, 0xb808, 0x7011, 0xe023, 0xc046, 0x808d, 0x11a, 0x234, 0x468, 0x8d0, 0x11a0, 0x2340, 0x4680, 0x8d00
  assign q[00] = noise[00] ^ x[00] ^ x[09] ^ x[11] ^ x[12];
  assign q[01] = noise[01] ^ x[01] ^ x[09] ^ x[10] ^ x[11] ^ x[13];
  assign q[02] = noise[02] ^ x[02] ^ x[10] ^ x[11] ^ x[12] ^ x[14];
  assign q[03] = noise[03] ^ x[03] ^ x[11] ^ x[12] ^ x[13] ^ x[15];
  assign q[04] = noise[04] ^ x[00] ^ x[04] ^ x[12] ^ x[13] ^ x[14];
  assign q[05] = noise[05] ^ x[00] ^ x[01] ^ x[05] ^ x[13] ^ x[14] ^ x[15];
  assign q[06] = noise[06] ^ x[01] ^ x[02] ^ x[06] ^ x[14] ^ x[15];
  assign q[07] = noise[07] ^ x[00] ^ x[02] ^ x[03] ^ x[07] ^ x[15];
  assign q[08] = noise[08] ^ x[01] ^ x[03] ^ x[04] ^ x[08];
  assign q[09] = noise[09] ^ x[02] ^ x[04] ^ x[05] ^ x[09];
  assign q[10] = noise[10] ^ x[03] ^ x[05] ^ x[06] ^ x[10];
  assign q[11] = noise[11] ^ x[04] ^ x[06] ^ x[07] ^ x[11];
  assign q[12] = noise[12] ^ x[05] ^ x[07] ^ x[08] ^ x[12];
  assign q[13] = noise[13] ^ x[06] ^ x[08] ^ x[09] ^ x[13];
  assign q[14] = noise[14] ^ x[07] ^ x[09] ^ x[10] ^ x[14];
  assign q[15] = noise[15] ^ x[08] ^ x[10] ^ x[11] ^ x[15];
endmodule

module MulBstd(input  wire [`L -1:0] noise
              ,input  wire [`L -1:0] x
              ,output wire [`L -1:0] q);
// Linear = 0x8201, 0x8603, 0xc06, 0x180c, 0x3018, 0x6030, 0xc060, 0x80c1, 0x182, 0x304, 0x608, 0xc10, 0x1820, 0x3040, 0x6080, 0xc100
  assign q[00] = noise[00] ^ x[00] ^ x[09] ^ x[15];
  assign q[01] = noise[01] ^ x[00] ^ x[01] ^ x[09] ^ x[10] ^ x[15];
  assign q[02] = noise[02] ^ x[01] ^ x[02] ^ x[10] ^ x[11];
  assign q[03] = noise[03] ^ x[02] ^ x[03] ^ x[11] ^ x[12];
  assign q[04] = noise[04] ^ x[03] ^ x[04] ^ x[12] ^ x[13];
  assign q[05] = noise[05] ^ x[04] ^ x[05] ^ x[13] ^ x[14];
  assign q[06] = noise[06] ^ x[05] ^ x[06] ^ x[14] ^ x[15];
  assign q[07] = noise[07] ^ x[00] ^ x[06] ^ x[07] ^ x[15];
  assign q[08] = noise[08] ^ x[01] ^ x[07] ^ x[08];
  assign q[09] = noise[09] ^ x[02] ^ x[08] ^ x[09];
  assign q[10] = noise[10] ^ x[03] ^ x[09] ^ x[10];
  assign q[11] = noise[11] ^ x[04] ^ x[10] ^ x[11];
  assign q[12] = noise[12] ^ x[05] ^ x[11] ^ x[12];
  assign q[13] = noise[13] ^ x[06] ^ x[12] ^ x[13];
  assign q[14] = noise[14] ^ x[07] ^ x[13] ^ x[14];
  assign q[15] = noise[15] ^ x[08] ^ x[14] ^ x[15];
endmodule

module MulDstd(input  wire [`L -1:0] noise
              ,input  wire [`L -1:0] x
              ,output wire [`L -1:0] q);
// Linear = 0x5000, 0xf000, 0xe001, 0xc002, 0x8005, 0xa, 0x14, 0x28, 0x50, 0xa0, 0x140, 0x280, 0x500, 0xa00, 0x1400, 0x2800
  assign q[00] = noise[00] ^ x[12] ^ x[14];
  assign q[01] = noise[01] ^ x[12] ^ x[13] ^ x[14] ^ x[15];
  assign q[02] = noise[02] ^ x[00] ^ x[13] ^ x[14] ^ x[15];
  assign q[03] = noise[03] ^ x[01] ^ x[14] ^ x[15];
  assign q[04] = noise[04] ^ x[00] ^ x[02] ^ x[15];
  assign q[05] = noise[05] ^ x[01] ^ x[03];
  assign q[06] = noise[06] ^ x[02] ^ x[04];
  assign q[07] = noise[07] ^ x[03] ^ x[05];
  assign q[08] = noise[08] ^ x[04] ^ x[06];
  assign q[09] = noise[09] ^ x[05] ^ x[07];
  assign q[10] = noise[10] ^ x[06] ^ x[08];
  assign q[11] = noise[11] ^ x[07] ^ x[09];
  assign q[12] = noise[12] ^ x[08] ^ x[10];
  assign q[13] = noise[13] ^ x[09] ^ x[11];
  assign q[14] = noise[14] ^ x[10] ^ x[12];
  assign q[15] = noise[15] ^ x[11] ^ x[13];
endmodule

`ifndef NEW_LA

module A(input  wire [`L -1:0] noise
        ,input  wire [`L -1:0] x
        ,output wire [`L -1:0] q);
// Linear = 0xf9ed, 0x8096, 0x4, 0x9050, 0x8ab1, 0xf424, 0x69f4, 0xd68, 0x100, 0x200, 0x400, 0x800, 0x1000, 0x2000, 0x4000, 0x8000
// Shift = 0xa9
  assign q[00] = noise[00] ^ x[00] ^ x[02] ^ x[03] ^ x[05] ^ x[06] ^ x[07] ^ x[08] ^ x[11] ^ x[12] ^ x[13] ^ x[14] ^ x[15] ^ 1'b1;
  assign q[01] = noise[01] ^ x[01] ^ x[02] ^ x[04] ^ x[07] ^ x[15];
  assign q[02] = noise[02] ^ x[02];
  assign q[03] = noise[03] ^ x[04] ^ x[06] ^ x[12] ^ x[15] ^ 1'b1;
  assign q[04] = noise[04] ^ x[00] ^ x[04] ^ x[05] ^ x[07] ^ x[09] ^ x[11] ^ x[15];
  assign q[05] = noise[05] ^ x[02] ^ x[05] ^ x[10] ^ x[12] ^ x[13] ^ x[14] ^ x[15] ^ 1'b1;
  assign q[06] = noise[06] ^ x[02] ^ x[04] ^ x[05] ^ x[06] ^ x[07] ^ x[08] ^ x[11] ^ x[13] ^ x[14];
  assign q[07] = noise[07] ^ x[03] ^ x[05] ^ x[06] ^ x[08] ^ x[10] ^ x[11] ^ 1'b1;
  assign q[08] = noise[08] ^ x[08];
  assign q[09] = noise[09] ^ x[09];
  assign q[10] = noise[10] ^ x[10];
  assign q[11] = noise[11] ^ x[11];
  assign q[12] = noise[12] ^ x[12];
  assign q[13] = noise[13] ^ x[13];
  assign q[14] = noise[14] ^ x[14];
  assign q[15] = noise[15] ^ x[15];
endmodule

module ADouble(input  wire [`L -1:0] noise
              ,input  wire [`L -1:0] x
              ,output wire [`L -1:0] q);
// Linear = 0x4a00, 0xde00, 0x45ed, 0xf896, 0xf004, 0x89bd, 0xca27, 0x8dcd, 0x7932, 0x87dd, 0x6574, 0xe145, 0xfd4c, 0x60f4, 0x1f68, 0x2500
// Shift = 0x51
  assign q[00] = noise[00] ^ x[09] ^ x[11] ^ x[14] ^ 1'b1;
  assign q[01] = noise[01] ^ x[09] ^ x[10] ^ x[11] ^ x[12] ^ x[14] ^ x[15];
  assign q[02] = noise[02] ^ x[00] ^ x[02] ^ x[03] ^ x[05] ^ x[06] ^ x[07] ^ x[08] ^ x[10] ^ x[14];
  assign q[03] = noise[03] ^ x[01] ^ x[02] ^ x[04] ^ x[07] ^ x[11] ^ x[12] ^ x[13] ^ x[14] ^ x[15];
  assign q[04] = noise[04] ^ x[02] ^ x[12] ^ x[13] ^ x[14] ^ x[15] ^ 1'b1;
  assign q[05] = noise[05] ^ x[00] ^ x[02] ^ x[03] ^ x[04] ^ x[05] ^ x[07] ^ x[08] ^ x[11] ^ x[15];
  assign q[06] = noise[06] ^ x[00] ^ x[01] ^ x[02] ^ x[05] ^ x[09] ^ x[11] ^ x[14] ^ x[15] ^ 1'b1;
  assign q[07] = noise[07] ^ x[00] ^ x[02] ^ x[03] ^ x[06] ^ x[07] ^ x[08] ^ x[10] ^ x[11] ^ x[15];
  assign q[08] = noise[08] ^ x[01] ^ x[04] ^ x[05] ^ x[08] ^ x[11] ^ x[12] ^ x[13] ^ x[14];
  assign q[09] = noise[09] ^ x[00] ^ x[02] ^ x[03] ^ x[04] ^ x[06] ^ x[07] ^ x[08] ^ x[09] ^ x[10] ^ x[15];
  assign q[10] = noise[10] ^ x[02] ^ x[04] ^ x[05] ^ x[06] ^ x[08] ^ x[10] ^ x[13] ^ x[14];
  assign q[11] = noise[11] ^ x[00] ^ x[02] ^ x[06] ^ x[08] ^ x[13] ^ x[14] ^ x[15];
  assign q[12] = noise[12] ^ x[02] ^ x[03] ^ x[06] ^ x[08] ^ x[10] ^ x[11] ^ x[12] ^ x[13] ^ x[14] ^ x[15];
  assign q[13] = noise[13] ^ x[02] ^ x[04] ^ x[05] ^ x[06] ^ x[07] ^ x[13] ^ x[14];
  assign q[14] = noise[14] ^ x[03] ^ x[05] ^ x[06] ^ x[08] ^ x[09] ^ x[10] ^ x[11] ^ x[12];
  assign q[15] = noise[15] ^ x[08] ^ x[10] ^ x[13];
endmodule

module ATriple(input  wire [`L -1:0] noise
              ,input  wire [`L -1:0] x
              ,output wire [`L -1:0] q);
// Linear = 0xb3ed, 0x5e96, 0x45e9, 0x68c6, 0x7ab5, 0x7d99, 0xa3d3, 0x80a5, 0x7832, 0x85dd, 0x6174, 0xe945, 0xed4c, 0x40f4, 0x5f68, 0xa500
// Shift = 0xf8
  assign q[00] = noise[00] ^ x[00] ^ x[02] ^ x[03] ^ x[05] ^ x[06] ^ x[07] ^ x[08] ^ x[09] ^ x[12] ^ x[13] ^ x[15];
  assign q[01] = noise[01] ^ x[01] ^ x[02] ^ x[04] ^ x[07] ^ x[09] ^ x[10] ^ x[11] ^ x[12] ^ x[14];
  assign q[02] = noise[02] ^ x[00] ^ x[03] ^ x[05] ^ x[06] ^ x[07] ^ x[08] ^ x[10] ^ x[14];
  assign q[03] = noise[03] ^ x[01] ^ x[02] ^ x[06] ^ x[07] ^ x[11] ^ x[13] ^ x[14] ^ 1'b1;
  assign q[04] = noise[04] ^ x[00] ^ x[02] ^ x[04] ^ x[05] ^ x[07] ^ x[09] ^ x[11] ^ x[12] ^ x[13] ^ x[14] ^ 1'b1;
  assign q[05] = noise[05] ^ x[00] ^ x[03] ^ x[04] ^ x[07] ^ x[08] ^ x[10] ^ x[11] ^ x[12] ^ x[13] ^ x[14] ^ 1'b1;
  assign q[06] = noise[06] ^ x[00] ^ x[01] ^ x[04] ^ x[06] ^ x[07] ^ x[08] ^ x[09] ^ x[13] ^ x[15] ^ 1'b1;
  assign q[07] = noise[07] ^ x[00] ^ x[02] ^ x[05] ^ x[07] ^ x[15] ^ 1'b1;
  assign q[08] = noise[08] ^ x[01] ^ x[04] ^ x[05] ^ x[11] ^ x[12] ^ x[13] ^ x[14];
  assign q[09] = noise[09] ^ x[00] ^ x[02] ^ x[03] ^ x[04] ^ x[06] ^ x[07] ^ x[08] ^ x[10] ^ x[15];
  assign q[10] = noise[10] ^ x[02] ^ x[04] ^ x[05] ^ x[06] ^ x[08] ^ x[13] ^ x[14];
  assign q[11] = noise[11] ^ x[00] ^ x[02] ^ x[06] ^ x[08] ^ x[11] ^ x[13] ^ x[14] ^ x[15];
  assign q[12] = noise[12] ^ x[02] ^ x[03] ^ x[06] ^ x[08] ^ x[10] ^ x[11] ^ x[13] ^ x[14] ^ x[15];
  assign q[13] = noise[13] ^ x[02] ^ x[04] ^ x[05] ^ x[06] ^ x[07] ^ x[14];
  assign q[14] = noise[14] ^ x[03] ^ x[05] ^ x[06] ^ x[08] ^ x[09] ^ x[10] ^ x[11] ^ x[12] ^ x[14];
  assign q[15] = noise[15] ^ x[08] ^ x[10] ^ x[13] ^ x[15];
endmodule

`endif

module InvA(input  wire [`L -1:0] noise
           ,input  wire [`L -1:0] x
           ,output wire [`L -1:0] q);
// Linear = 0xf9ed, 0x7df, 0x4, 0xe31d, 0x8ab1, 0xf424, 0x1ab9, 0xd68, 0x100, 0x200, 0x400, 0x800, 0x1000, 0x2000, 0x4000, 0x8000
// Shift = 0x32
  assign q[00] = noise[00] ^ x[00] ^ x[02] ^ x[03] ^ x[05] ^ x[06] ^ x[07] ^ x[08] ^ x[11] ^ x[12] ^ x[13] ^ x[14] ^ x[15];
  assign q[01] = noise[01] ^ x[00] ^ x[01] ^ x[02] ^ x[03] ^ x[04] ^ x[06] ^ x[07] ^ x[08] ^ x[09] ^ x[10] ^ 1'b1;
  assign q[02] = noise[02] ^ x[02];
  assign q[03] = noise[03] ^ x[00] ^ x[02] ^ x[03] ^ x[04] ^ x[08] ^ x[09] ^ x[13] ^ x[14] ^ x[15];
  assign q[04] = noise[04] ^ x[00] ^ x[04] ^ x[05] ^ x[07] ^ x[09] ^ x[11] ^ x[15] ^ 1'b1;
  assign q[05] = noise[05] ^ x[02] ^ x[05] ^ x[10] ^ x[12] ^ x[13] ^ x[14] ^ x[15] ^ 1'b1;
  assign q[06] = noise[06] ^ x[00] ^ x[03] ^ x[04] ^ x[05] ^ x[07] ^ x[09] ^ x[11] ^ x[12];
  assign q[07] = noise[07] ^ x[03] ^ x[05] ^ x[06] ^ x[08] ^ x[10] ^ x[11];
  assign q[08] = noise[08] ^ x[08];
  assign q[09] = noise[09] ^ x[09];
  assign q[10] = noise[10] ^ x[10];
  assign q[11] = noise[11] ^ x[11];
  assign q[12] = noise[12] ^ x[12];
  assign q[13] = noise[13] ^ x[13];
  assign q[14] = noise[14] ^ x[14];
  assign q[15] = noise[15] ^ x[15];
endmodule

module Pow2InvA(input  wire [`L -1:0] noise
               ,input  wire [`L -1:0] x
               ,output wire [`L -1:0] q);
// Linear = 0xf8ed, 0x100, 0x5df, 0x200, 0x404, 0x400, 0xeb1d, 0x800, 0x9ab1, 0x1000, 0xd424, 0x2000, 0x5ab9, 0x4000, 0x8d68, 0x8000
// Shift = 0xa0
  assign q[00] = noise[00] ^ x[00] ^ x[02] ^ x[03] ^ x[05] ^ x[06] ^ x[07] ^ x[11] ^ x[12] ^ x[13] ^ x[14] ^ x[15];
  assign q[01] = noise[01] ^ x[08];
  assign q[02] = noise[02] ^ x[00] ^ x[01] ^ x[02] ^ x[03] ^ x[04] ^ x[06] ^ x[07] ^ x[08] ^ x[10];
  assign q[03] = noise[03] ^ x[09];
  assign q[04] = noise[04] ^ x[02] ^ x[10];
  assign q[05] = noise[05] ^ x[10] ^ 1'b1;
  assign q[06] = noise[06] ^ x[00] ^ x[02] ^ x[03] ^ x[04] ^ x[08] ^ x[09] ^ x[11] ^ x[13] ^ x[14] ^ x[15];
  assign q[07] = noise[07] ^ x[11] ^ 1'b1;
  assign q[08] = noise[08] ^ x[00] ^ x[04] ^ x[05] ^ x[07] ^ x[09] ^ x[11] ^ x[12] ^ x[15];
  assign q[09] = noise[09] ^ x[12];
  assign q[10] = noise[10] ^ x[02] ^ x[05] ^ x[10] ^ x[12] ^ x[14] ^ x[15];
  assign q[11] = noise[11] ^ x[13];
  assign q[12] = noise[12] ^ x[00] ^ x[03] ^ x[04] ^ x[05] ^ x[07] ^ x[09] ^ x[11] ^ x[12] ^ x[14];
  assign q[13] = noise[13] ^ x[14];
  assign q[14] = noise[14] ^ x[03] ^ x[05] ^ x[06] ^ x[08] ^ x[10] ^ x[11] ^ x[15];
  assign q[15] = noise[15] ^ x[15];
endmodule
