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

`include "defines.h"

`ifdef NEW_LA

module Prod (input [`L-1:0] rand_i, input [`L-1:0] src1, input [`L-1:0] src2, output [`L-1:0] res);
    wire [30:0] aDegs;
    wire [`L-1:0] part1, part2;
    Degs degs (aDegs, src1);
    ProdPart1 prodPart1(aDegs, src2, rand_i, part1);
    ProdPart2 prodPart2(aDegs, src2, part2);
    Xor xor_inst(part1, part2, res);
    //printf("%04x %04x %04x %04x\n", (uint16_t) rand_i.word, (uint16_t) src1.word, (uint16_t) src2.word, (uint16_t) res.word);
endmodule

module Pow16(input [`L-1:0] rand_i, input [`L-1:0] src, output [`L-1:0] res);
    wire [`L-1:0] part1, part2;
    Pow16Part1 pow16Part1(src, rand_i, part1);
    Pow16Part2 pow16Part2(src, part2);
    Xor xor_inst(part1, part2, res);
    
endmodule

module APow2(input [`L-1:0] rand_i, input [`L-1:0] src, output [`L-1:0] res);
    wire [`L-1:0] part1, part2;
    APow2Part1 aPow2Part1(src, rand_i, part1);
    APow2Part2 aPow2Part2(src, part2);
    Xor xor_inst(part1, part2, res);
    
endmodule

module APow2Double(input [`L-1:0] rand_i, input [`L-1:0] src, output [`L-1:0] res);
    wire [`L-1:0] part1, part2;
    APow2DoublePart1 aPow2DoublePart1(src, rand_i, part1);
    APow2DoublePart2 aPow2DoublePart2(src, part2);
    Xor xor_inst(part1, part2, res);
    
endmodule

module APow2Triple(input [`L-1:0] rand_i, input [`L-1:0] src, output [`L-1:0] res);
    wire [`L-1:0] part1, part2;
    APow2TriplePart1 aPow2TriplePart1(src, rand_i, part1);
    APow2TriplePart2 aPow2TriplePart2(src, part2);
    Xor xor_inst(part1, part2, res);
    
endmodule

module A(input [`L-1:0] rand_i, input [`L-1:0] src, output [`L-1:0] res);
    wire [`L-1:0] part1, part2;
    APart1 aPart1(src, rand_i, part1);
    APart2 aPart2(src, part2);
    Xor xor_inst(part1, part2, res);
    
endmodule

module ADouble(input [`L-1:0] rand_i, input [`L-1:0] src, output [`L-1:0] res);
    wire [`L-1:0] part1, part2;
    ADoublePart1 aDoublePart1(src, rand_i, part1);
    ADoublePart2 aDoublePart2(src, part2);
    Xor xor_inst(part1, part2, res);
    
endmodule

module ATriple(input [`L-1:0] rand_i, input [`L-1:0] src, output [`L-1:0] res);
    wire [`L-1:0] part1, part2;
    ATriplePart1 aTriplePart1(src, rand_i, part1);
    ATriplePart2 aTriplePart2(src, part2);
    Xor xor_inst(part1, part2, res);
    
endmodule

module Xor(input [`L-1:0] src1, input [`L-1:0] src2, output [`L-1:0] res);
    assign res = src1 ^ src2;
endmodule

module Degs(output [30:0] aDest, input [`L-1:0] src);
    assign aDest[ 0] = src[00];
    assign aDest[ 1] = src[15];
    assign aDest[ 2] = src[14];
    assign aDest[ 3] = src[13];
    assign aDest[ 4] = src[12];
    assign aDest[ 5] = src[11];
    assign aDest[ 6] = src[10];
    assign aDest[ 7] = src[09];
    assign aDest[ 8] = src[08];
    assign aDest[ 9] = src[07];
    assign aDest[10] = src[06];
    assign aDest[11] = src[05];
    assign aDest[12] = src[04];
    assign aDest[13] = src[03];
    assign aDest[14] = src[02];
    assign aDest[15] = src[01];
    assign aDest[16] = src[15] ^ src[00];
    assign aDest[17] = src[14] ^ src[15];
    assign aDest[18] = src[13] ^ src[14];
    assign aDest[19] = src[12] ^ src[13];
    assign aDest[20] = src[11] ^ src[12];
    assign aDest[21] = src[10] ^ src[11];
    assign aDest[22] = src[09] ^ src[10];
    assign aDest[23] = src[08] ^ src[09];
    assign aDest[24] = src[07] ^ src[08];
    assign aDest[25] = src[06] ^ src[07];
    assign aDest[26] = src[05] ^ src[06];
    assign aDest[27] = src[04] ^ src[05];
    assign aDest[28] = src[03] ^ src[04];
    assign aDest[29] = src[02] ^ src[03];
    assign aDest[30] = src[01] ^ src[02];
endmodule

module ProdPart1 (input [30:0] aDegs, input [`L-1:0] src, input [`L-1:0] rand_i, output [`L-1:0] res);

    assign res[00] =  rand_i[00]
    ^   (src[00] & aDegs[0])
    ^   (src[01] & aDegs[1])
    ^   (src[02] & aDegs[2])
    ^   (src[03] & aDegs[3])
    ^   (src[04] & aDegs[4])
    ^   (src[05] & aDegs[5])
    ^   (src[06] & aDegs[6])
    ^   (src[07] & aDegs[7])
        ;
    assign res[01] =  rand_i[01]
    ^   (src[00] & aDegs[15])
    ^   (src[01] & aDegs[16])
    ^   (src[02] & aDegs[17])
    ^   (src[03] & aDegs[18])
    ^   (src[04] & aDegs[19])
    ^   (src[05] & aDegs[20])
    ^   (src[06] & aDegs[21])
    ^   (src[07] & aDegs[22])
        ;
    assign res[02] =  rand_i[02]
    ^   (src[00] & aDegs[14])
    ^   (src[01] & aDegs[15])
    ^   (src[02] & aDegs[16])
    ^   (src[03] & aDegs[17])
    ^   (src[04] & aDegs[18])
    ^   (src[05] & aDegs[19])
    ^   (src[06] & aDegs[20])
    ^   (src[07] & aDegs[21])
        ;
    assign res[03] =  rand_i[03]
    ^   (src[00] & aDegs[13])
    ^   (src[01] & aDegs[14])
    ^   (src[02] & aDegs[15])
    ^   (src[03] & aDegs[16])
    ^   (src[04] & aDegs[17])
    ^   (src[05] & aDegs[18])
    ^   (src[06] & aDegs[19])
    ^   (src[07] & aDegs[20])
        ;
    assign res[04] =  rand_i[04]
    ^   (src[00] & aDegs[12])
    ^   (src[01] & aDegs[13])
    ^   (src[02] & aDegs[14])
    ^   (src[03] & aDegs[15])
    ^   (src[04] & aDegs[16])
    ^   (src[05] & aDegs[17])
    ^   (src[06] & aDegs[18])
    ^   (src[07] & aDegs[19])
        ;
    assign res[05] =  rand_i[05]
    ^   (src[00] & aDegs[11])
    ^   (src[01] & aDegs[12])
    ^   (src[02] & aDegs[13])
    ^   (src[03] & aDegs[14])
    ^   (src[04] & aDegs[15])
    ^   (src[05] & aDegs[16])
    ^   (src[06] & aDegs[17])
    ^   (src[07] & aDegs[18])
        ;
    assign res[06] =  rand_i[06]
    ^   (src[00] & aDegs[10])
    ^   (src[01] & aDegs[11])
    ^   (src[02] & aDegs[12])
    ^   (src[03] & aDegs[13])
    ^   (src[04] & aDegs[14])
    ^   (src[05] & aDegs[15])
    ^   (src[06] & aDegs[16])
    ^   (src[07] & aDegs[17])
        ;
    assign res[07] =  rand_i[07]
    ^   (src[00] & aDegs[9])
    ^   (src[01] & aDegs[10])
    ^   (src[02] & aDegs[11])
    ^   (src[03] & aDegs[12])
    ^   (src[04] & aDegs[13])
    ^   (src[05] & aDegs[14])
    ^   (src[06] & aDegs[15])
    ^   (src[07] & aDegs[16])
        ;
    assign res[08] =  rand_i[08]
    ^   (src[00] & aDegs[8])
    ^   (src[01] & aDegs[9])
    ^   (src[02] & aDegs[10])
    ^   (src[03] & aDegs[11])
    ^   (src[04] & aDegs[12])
    ^   (src[05] & aDegs[13])
    ^   (src[06] & aDegs[14])
    ^   (src[07] & aDegs[15])
        ;
    assign res[09] =  rand_i[09]
    ^   (src[00] & aDegs[7])
    ^   (src[01] & aDegs[8])
    ^   (src[02] & aDegs[9])
    ^   (src[03] & aDegs[10])
    ^   (src[04] & aDegs[11])
    ^   (src[05] & aDegs[12])
    ^   (src[06] & aDegs[13])
    ^   (src[07] & aDegs[14])
        ;
    assign res[10] =  rand_i[10]
    ^   (src[00] & aDegs[6])
    ^   (src[01] & aDegs[7])
    ^   (src[02] & aDegs[8])
    ^   (src[03] & aDegs[9])
    ^   (src[04] & aDegs[10])
    ^   (src[05] & aDegs[11])
    ^   (src[06] & aDegs[12])
    ^   (src[07] & aDegs[13])
        ;
    assign res[11] =  rand_i[11]
    ^   (src[00] & aDegs[5])
    ^   (src[01] & aDegs[6])
    ^   (src[02] & aDegs[7])
    ^   (src[03] & aDegs[8])
    ^   (src[04] & aDegs[9])
    ^   (src[05] & aDegs[10])
    ^   (src[06] & aDegs[11])
    ^   (src[07] & aDegs[12])
        ;
    assign res[12] =  rand_i[12]
    ^   (src[00] & aDegs[4])
    ^   (src[01] & aDegs[5])
    ^   (src[02] & aDegs[6])
    ^   (src[03] & aDegs[7])
    ^   (src[04] & aDegs[8])
    ^   (src[05] & aDegs[9])
    ^   (src[06] & aDegs[10])
    ^   (src[07] & aDegs[11])
        ;
    assign res[13] =  rand_i[13]
    ^   (src[00] & aDegs[3])
    ^   (src[01] & aDegs[4])
    ^   (src[02] & aDegs[5])
    ^   (src[03] & aDegs[6])
    ^   (src[04] & aDegs[7])
    ^   (src[05] & aDegs[8])
    ^   (src[06] & aDegs[9])
    ^   (src[07] & aDegs[10])
        ;
    assign res[14] =  rand_i[14]
    ^   (src[00] & aDegs[2])
    ^   (src[01] & aDegs[3])
    ^   (src[02] & aDegs[4])
    ^   (src[03] & aDegs[5])
    ^   (src[04] & aDegs[6])
    ^   (src[05] & aDegs[7])
    ^   (src[06] & aDegs[8])
    ^   (src[07] & aDegs[9])
        ;
    assign res[15] =  rand_i[15]
    ^   (src[00] & aDegs[1])
    ^   (src[01] & aDegs[2])
    ^   (src[02] & aDegs[3])
    ^   (src[03] & aDegs[4])
    ^   (src[04] & aDegs[5])
    ^   (src[05] & aDegs[6])
    ^   (src[06] & aDegs[7])
    ^   (src[07] & aDegs[8])
        ;

endmodule

module ProdPart2 (input [30:0] aDegs, input [`L-1:0] src, output [`L-1:0] res);

    assign res[00] = 
        (src[08] & aDegs[8])
    ^   (src[09] & aDegs[9])
    ^   (src[10] & aDegs[10])
    ^   (src[11] & aDegs[11])
    ^   (src[12] & aDegs[12])
    ^   (src[13] & aDegs[13])
    ^   (src[14] & aDegs[14])
    ^   (src[15] & aDegs[15])
        ;
    assign res[01] = 
        (src[08] & aDegs[23])
    ^   (src[09] & aDegs[24])
    ^   (src[10] & aDegs[25])
    ^   (src[11] & aDegs[26])
    ^   (src[12] & aDegs[27])
    ^   (src[13] & aDegs[28])
    ^   (src[14] & aDegs[29])
    ^   (src[15] & aDegs[30])
        ;
    assign res[02] = 
        (src[08] & aDegs[22])
    ^   (src[09] & aDegs[23])
    ^   (src[10] & aDegs[24])
    ^   (src[11] & aDegs[25])
    ^   (src[12] & aDegs[26])
    ^   (src[13] & aDegs[27])
    ^   (src[14] & aDegs[28])
    ^   (src[15] & aDegs[29])
        ;
    assign res[03] = 
        (src[08] & aDegs[21])
    ^   (src[09] & aDegs[22])
    ^   (src[10] & aDegs[23])
    ^   (src[11] & aDegs[24])
    ^   (src[12] & aDegs[25])
    ^   (src[13] & aDegs[26])
    ^   (src[14] & aDegs[27])
    ^   (src[15] & aDegs[28])
        ;
    assign res[04] = 
        (src[08] & aDegs[20])
    ^   (src[09] & aDegs[21])
    ^   (src[10] & aDegs[22])
    ^   (src[11] & aDegs[23])
    ^   (src[12] & aDegs[24])
    ^   (src[13] & aDegs[25])
    ^   (src[14] & aDegs[26])
    ^   (src[15] & aDegs[27])
        ;
    assign res[05] = 
        (src[08] & aDegs[19])
    ^   (src[09] & aDegs[20])
    ^   (src[10] & aDegs[21])
    ^   (src[11] & aDegs[22])
    ^   (src[12] & aDegs[23])
    ^   (src[13] & aDegs[24])
    ^   (src[14] & aDegs[25])
    ^   (src[15] & aDegs[26])
        ;
    assign res[06] = 
        (src[08] & aDegs[18])
    ^   (src[09] & aDegs[19])
    ^   (src[10] & aDegs[20])
    ^   (src[11] & aDegs[21])
    ^   (src[12] & aDegs[22])
    ^   (src[13] & aDegs[23])
    ^   (src[14] & aDegs[24])
    ^   (src[15] & aDegs[25])
        ;
    assign res[07] = 
        (src[08] & aDegs[17])
    ^   (src[09] & aDegs[18])
    ^   (src[10] & aDegs[19])
    ^   (src[11] & aDegs[20])
    ^   (src[12] & aDegs[21])
    ^   (src[13] & aDegs[22])
    ^   (src[14] & aDegs[23])
    ^   (src[15] & aDegs[24])
        ;
    assign res[08] = 
        (src[08] & aDegs[16])
    ^   (src[09] & aDegs[17])
    ^   (src[10] & aDegs[18])
    ^   (src[11] & aDegs[19])
    ^   (src[12] & aDegs[20])
    ^   (src[13] & aDegs[21])
    ^   (src[14] & aDegs[22])
    ^   (src[15] & aDegs[23])
        ;
    assign res[09] = 
        (src[08] & aDegs[15])
    ^   (src[09] & aDegs[16])
    ^   (src[10] & aDegs[17])
    ^   (src[11] & aDegs[18])
    ^   (src[12] & aDegs[19])
    ^   (src[13] & aDegs[20])
    ^   (src[14] & aDegs[21])
    ^   (src[15] & aDegs[22])
        ;
    assign res[10] = 
        (src[08] & aDegs[14])
    ^   (src[09] & aDegs[15])
    ^   (src[10] & aDegs[16])
    ^   (src[11] & aDegs[17])
    ^   (src[12] & aDegs[18])
    ^   (src[13] & aDegs[19])
    ^   (src[14] & aDegs[20])
    ^   (src[15] & aDegs[21])
        ;
    assign res[11] = 
        (src[08] & aDegs[13])
    ^   (src[09] & aDegs[14])
    ^   (src[10] & aDegs[15])
    ^   (src[11] & aDegs[16])
    ^   (src[12] & aDegs[17])
    ^   (src[13] & aDegs[18])
    ^   (src[14] & aDegs[19])
    ^   (src[15] & aDegs[20])
        ;
    assign res[12] = 
        (src[08] & aDegs[12])
    ^   (src[09] & aDegs[13])
    ^   (src[10] & aDegs[14])
    ^   (src[11] & aDegs[15])
    ^   (src[12] & aDegs[16])
    ^   (src[13] & aDegs[17])
    ^   (src[14] & aDegs[18])
    ^   (src[15] & aDegs[19])
        ;
    assign res[13] = 
        (src[08] & aDegs[11])
    ^   (src[09] & aDegs[12])
    ^   (src[10] & aDegs[13])
    ^   (src[11] & aDegs[14])
    ^   (src[12] & aDegs[15])
    ^   (src[13] & aDegs[16])
    ^   (src[14] & aDegs[17])
    ^   (src[15] & aDegs[18])
        ;
    assign res[14] = 
        (src[08] & aDegs[10])
    ^   (src[09] & aDegs[11])
    ^   (src[10] & aDegs[12])
    ^   (src[11] & aDegs[13])
    ^   (src[12] & aDegs[14])
    ^   (src[13] & aDegs[15])
    ^   (src[14] & aDegs[16])
    ^   (src[15] & aDegs[17])
        ;
    assign res[15] = 
        (src[08] & aDegs[9])
    ^   (src[09] & aDegs[10])
    ^   (src[10] & aDegs[11])
    ^   (src[11] & aDegs[12])
    ^   (src[12] & aDegs[13])
    ^   (src[13] & aDegs[14])
    ^   (src[14] & aDegs[15])
    ^   (src[15] & aDegs[16])
        ;

endmodule

module Pow16Part1(input [`L-1:0]  src, input [`L-1:0] rand_i, output [`L-1:0] res);
    assign res[00] =  rand_i[00] ^ src[00] ^ src[01] ^ src[02] ^ src[03] ^ src[04] ^ src[05] ^ src[06] ^ src[07];
    assign res[01] =  rand_i[01] ^ src[01] ^ src[03] ^ src[05] ^ src[07] ^ src[09] ^ src[11] ^ src[13] ^ src[15];
    assign res[02] =  rand_i[02] ^ src[02] ^ src[03] ^ src[06] ^ src[07] ^ src[10] ^ src[11] ^ src[14] ^ src[15];
    assign res[03] =  rand_i[03] ^ src[03] ^ src[07] ^ src[11] ^ src[15];
    assign res[04] =  rand_i[04] ^ src[04] ^ src[05] ^ src[06] ^ src[07] ^ src[12] ^ src[13] ^ src[14] ^ src[15];
    assign res[05] =  rand_i[05] ^ src[05] ^ src[07] ^ src[13] ^ src[15];
    assign res[06] =  rand_i[06] ^ src[06] ^ src[07] ^ src[14] ^ src[15];
    assign res[07] =  rand_i[07] ^ src[07] ^ src[15];
    assign res[08] =  rand_i[08] ^ src[08] ^ src[09] ^ src[10] ^ src[11] ^ src[12] ^ src[13] ^ src[14] ^ src[15];
    assign res[09] =  rand_i[09] ^ src[09] ^ src[11] ^ src[13] ^ src[15];
    assign res[10] =  rand_i[10] ^ src[10] ^ src[11] ^ src[14] ^ src[15];
    assign res[11] =  rand_i[11] ^ src[11] ^ src[15];
    assign res[12] =  rand_i[12] ^ src[12] ^ src[13] ^ src[14] ^ src[15];
    assign res[13] =  rand_i[13] ^ src[13] ^ src[15];
    assign res[14] =  rand_i[14] ^ src[14] ^ src[15];
    assign res[15] =  rand_i[15] ^ src[15];
endmodule

module Pow16Part2(input [`L-1:0] src, output [`L-1:0] res);
    assign res[00] =  src[08] ^ src[09] ^ src[10] ^ src[11] ^ src[12] ^ src[13] ^ src[14] ^ src[15];
    assign res[01] =  0;
    assign res[02] =  0;
    assign res[03] =  0;
    assign res[04] =  0;
    assign res[05] =  0;
    assign res[06] =  0;
    assign res[07] =  0;
    assign res[08] =  0;
    assign res[09] =  0;
    assign res[10] =  0;
    assign res[11] =  0;
    assign res[12] =  0;
    assign res[13] =  0;
    assign res[14] =  0;
    assign res[15] =  0;
endmodule

module APow2Part1(input [`L-1:0]  src, input [`L-1:0] rand_i, output [`L-1:0] res);
    assign res[00] =  rand_i[00] ^ src[00] ^ src[01] ^ src[03] ^ src[04] ^ src[06] ^ src[07];
    assign res[01] =  rand_i[01] ^ src[01] ^ src[02];
    assign res[02] =  rand_i[02] ^ src[01] ^ src[09];
    assign res[03] =  rand_i[03] ^ src[02] ^ src[03] ^ src[06] ^ src[10] ^ src[11] ^ src[14] ^ src[15] ^ 1;
    assign res[04] =  rand_i[04] ^ src[00] ^ src[02] ^ src[08] ^ src[11] ^ src[12] ^ src[13] ^ src[15];
    assign res[05] =  rand_i[05] ^ src[01] ^ src[05] ^ src[06] ^ src[07];
    assign res[06] =  rand_i[06] ^ src[01] ^ src[02] ^ src[03] ^ src[04] ^ src[07];
    assign res[07] =  rand_i[07] ^ src[03] ^ src[04] ^ src[05];
    assign res[08] =  rand_i[08] ^ src[04] ^ src[12];
    assign res[09] =  rand_i[09] ^ src[12];
    assign res[10] =  rand_i[10] ^ src[05] ^ src[13];
    assign res[11] =  rand_i[11] ^ src[13];
    assign res[12] =  rand_i[12] ^ src[06] ^ src[14];
    assign res[13] =  rand_i[13] ^ src[14];
    assign res[14] =  rand_i[14] ^ src[07] ^ src[15];
    assign res[15] =  rand_i[15] ^ src[15];
endmodule

module APow2Part2(input [`L-1:0] src, output [`L-1:0] res);
    assign res[00] =  src[08] ^ src[10] ^ src[12] ^ src[13] ^ 1;
    assign res[01] =  src[08] ^ src[09] ^ src[10] ^ src[11] ^ src[15];
    assign res[02] =  0;
    assign res[03] =  0;
    assign res[04] =  0;
    assign res[05] =  src[09] ^ src[10] ^ src[13] ^ 1;
    assign res[06] =  src[09] ^ src[12] ^ src[13] ^ src[14] ^ src[15];
    assign res[07] =  src[09] ^ src[10] ^ src[11] ^ src[12] ^ 1;
    assign res[08] =  0;
    assign res[09] =  0;
    assign res[10] =  0;
    assign res[11] =  0;
    assign res[12] =  0;
    assign res[13] =  0;
    assign res[14] =  0;
    assign res[15] =  0;
endmodule

module APow2DoublePart1(input [`L-1:0]  src, input [`L-1:0] rand_i, output [`L-1:0] res);
    assign res[00] =  rand_i[00] ^ src[07] ^ src[12] ^ src[13] ^ src[15] ^ 1;
    assign res[01] =  rand_i[01] ^ src[05] ^ src[06] ^ src[07] ^ src[12] ^ src[14];
    assign res[02] =  rand_i[02] ^ src[00] ^ src[01] ^ src[03] ^ src[04] ^ src[05] ^ src[07];
    assign res[03] =  rand_i[03] ^ src[01] ^ src[02] ^ src[06] ^ src[07];
    assign res[04] =  rand_i[04] ^ src[01] ^ src[06] ^ src[07] ^ src[09] ^ 1;
    assign res[05] =  rand_i[05] ^ src[00] ^ src[01] ^ src[02] ^ src[04];
    assign res[06] =  rand_i[06] ^ src[00] ^ src[01] ^ src[07] ^ src[09] ^ src[10] ^ src[12] ^ src[13] ^ 1;
    assign res[07] =  rand_i[07] ^ src[00] ^ src[01] ^ src[03] ^ src[04] ^ src[05];
    assign res[08] =  rand_i[08] ^ src[02] ^ src[04] ^ src[06] ^ src[07];
    assign res[09] =  rand_i[09] ^ src[00] ^ src[01] ^ src[02] ^ src[03] ^ src[04] ^ src[05];
    assign res[10] =  rand_i[10] ^ src[01] ^ src[02] ^ src[03] ^ src[04] ^ src[05] ^ src[07];
    assign res[11] =  rand_i[11] ^ src[00] ^ src[01] ^ src[03] ^ src[04] ^ src[07];
    assign res[12] =  rand_i[12] ^ src[01] ^ src[03] ^ src[04] ^ src[05] ^ src[06] ^ src[07];
    assign res[13] =  rand_i[13] ^ src[01] ^ src[02] ^ src[03] ^ src[07] ^ src[09] ^ src[14] ^ src[15];
    assign res[14] =  rand_i[14] ^ src[03] ^ src[04] ^ src[05] ^ src[06] ^ src[09] ^ src[10] ^ src[11] ^ src[14];
    assign res[15] =  rand_i[15] ^ src[04] ^ src[05] ^ src[12] ^ src[13] ^ src[14];
endmodule

module APow2DoublePart2(input [`L-1:0] src, output [`L-1:0] res);
    assign res[00] =  0;
    assign res[01] =  0;
    assign res[02] =  src[08] ^ src[10] ^ src[12] ^ src[13] ^ src[15];
    assign res[03] =  src[08] ^ src[09] ^ src[10] ^ src[11] ^ src[13];
    assign res[04] =  0;
    assign res[05] =  src[08] ^ src[11] ^ src[12] ^ src[13] ^ src[15];
    assign res[06] =  0;
    assign res[07] =  src[08] ^ src[12] ^ src[15];
    assign res[08] =  src[08] ^ src[12] ^ src[13] ^ src[15];
    assign res[09] =  src[08] ^ src[10] ^ src[13] ^ src[15];
    assign res[10] =  src[09] ^ src[11] ^ src[12] ^ src[13] ^ src[14] ^ src[15];
    assign res[11] =  src[08] ^ src[09] ^ src[11] ^ src[12] ^ src[14];
    assign res[12] =  src[11] ^ src[12];
    assign res[13] =  0;
    assign res[14] =  0;
    assign res[15] =  0;
endmodule

module APow2TriplePart1(input [`L-1:0]  src, input [`L-1:0] rand_i, output [`L-1:0] res);
    assign res[00] =  rand_i[00] ^ src[00] ^ src[01] ^ src[03] ^ src[04] ^ src[06];
    assign res[01] =  rand_i[01] ^ src[01] ^ src[02] ^ src[05] ^ src[06] ^ src[07];
    assign res[02] =  rand_i[02] ^ src[00] ^ src[03] ^ src[04] ^ src[05] ^ src[07];
    assign res[03] =  rand_i[03] ^ src[01] ^ src[03] ^ src[07] ^ src[08] ^ src[09] ^ src[13] ^ src[14] ^ src[15] ^ 1;
    assign res[04] =  rand_i[04] ^ src[00] ^ src[01] ^ src[02] ^ src[06] ^ src[07];
    assign res[05] =  rand_i[05] ^ src[00] ^ src[02] ^ src[04] ^ src[05] ^ src[06] ^ src[07];
    assign res[06] =  rand_i[06] ^ src[00] ^ src[02] ^ src[03] ^ src[04] ^ src[10] ^ src[14] ^ src[15] ^ 1;
    assign res[07] =  rand_i[07] ^ src[00] ^ src[01] ^ src[08] ^ src[09] ^ src[10] ^ src[11] ^ src[15] ^ 1;
    assign res[08] =  rand_i[08] ^ src[02] ^ src[06] ^ src[07] ^ src[08] ^ src[13] ^ src[15];
    assign res[09] =  rand_i[09] ^ src[00] ^ src[01] ^ src[02] ^ src[03] ^ src[04] ^ src[05];
    assign res[10] =  rand_i[10] ^ src[01] ^ src[02] ^ src[03] ^ src[04] ^ src[07];
    assign res[11] =  rand_i[11] ^ src[00] ^ src[01] ^ src[03] ^ src[04] ^ src[07];
    assign res[12] =  rand_i[12] ^ src[01] ^ src[03] ^ src[04] ^ src[05] ^ src[07];
    assign res[13] =  rand_i[13] ^ src[01] ^ src[02] ^ src[03] ^ src[07] ^ src[09] ^ src[15];
    assign res[14] =  rand_i[14] ^ src[03] ^ src[04] ^ src[05] ^ src[06] ^ src[07];
    assign res[15] =  rand_i[15] ^ src[04] ^ src[05] ^ src[12] ^ src[13] ^ src[14] ^ src[15];
endmodule

module APow2TriplePart2(input [`L-1:0] src, output [`L-1:0] res);
    assign res[00] =  src[08] ^ src[10] ^ src[15];
    assign res[01] =  src[08] ^ src[09] ^ src[10] ^ src[11] ^ src[12] ^ src[14] ^ src[15];
    assign res[02] =  src[08] ^ src[09] ^ src[10] ^ src[12] ^ src[13] ^ src[15];
    assign res[03] =  0;
    assign res[04] =  src[08] ^ src[09] ^ src[11] ^ src[12] ^ src[13] ^ src[15] ^ 1;
    assign res[05] =  src[08] ^ src[09] ^ src[10] ^ src[11] ^ src[12] ^ src[15] ^ 1;
    assign res[06] =  0;
    assign res[07] =  0;
    assign res[08] =  0;
    assign res[09] =  src[08] ^ src[10] ^ src[12] ^ src[13] ^ src[15];
    assign res[10] =  src[09] ^ src[11] ^ src[12] ^ src[14] ^ src[15];
    assign res[11] =  src[08] ^ src[09] ^ src[11] ^ src[12] ^ src[13] ^ src[14];
    assign res[12] =  src[11] ^ src[12] ^ src[14];
    assign res[13] =  0;
    assign res[14] =  src[09] ^ src[10] ^ src[11] ^ src[14] ^ src[15];
    assign res[15] =  0;
endmodule

module APart1(input [`L-1:0]  src, input [`L-1:0] rand_i, output [`L-1:0] res);
    assign res[00] =  rand_i[00] ^ src[00] ^ src[02] ^ src[03] ^ src[05] ^ src[06] ^ src[07];
    assign res[01] =  rand_i[01] ^ src[01] ^ src[02] ^ src[04] ^ src[07];
    assign res[02] =  rand_i[02] ^ src[02];
    assign res[03] =  rand_i[03] ^ src[04] ^ src[06] ^ src[12] ^ src[15] ^ 1;
    assign res[04] =  rand_i[04] ^ src[00] ^ src[04] ^ src[05] ^ src[07];
    assign res[05] =  rand_i[05] ^ src[02] ^ src[05];
    assign res[06] =  rand_i[06] ^ src[02] ^ src[04] ^ src[05] ^ src[06] ^ src[07];
    assign res[07] =  rand_i[07] ^ src[03] ^ src[05] ^ src[06] ^ src[08] ^ src[10] ^ src[11] ^ 1;
    assign res[08] =  rand_i[08] ^ src[08];
    assign res[09] =  rand_i[09] ^ src[09];
    assign res[10] =  rand_i[10] ^ src[10];
    assign res[11] =  rand_i[11] ^ src[11];
    assign res[12] =  rand_i[12] ^ src[12];
    assign res[13] =  rand_i[13] ^ src[13];
    assign res[14] =  rand_i[14] ^ src[14];
    assign res[15] =  rand_i[15] ^ src[15];
    
endmodule

module APart2(input [`L-1:0] src, output [`L-1:0] res);
    assign res[00] =  src[08] ^ src[11] ^ src[12] ^ src[13] ^ src[14] ^ src[15] ^ 1;
    assign res[01] =  src[15];
    assign res[02] =  0;
    assign res[03] =  0;
    assign res[04] =  src[09] ^ src[11] ^ src[15];
    assign res[05] =  src[10] ^ src[12] ^ src[13] ^ src[14] ^ src[15] ^ 1;
    assign res[06] =  src[08] ^ src[11] ^ src[13] ^ src[14];
    assign res[07] =  0;
    assign res[08] =  0;
    assign res[09] =  0;
    assign res[10] =  0;
    assign res[11] =  0;
    assign res[12] =  0;
    assign res[13] =  0;
    assign res[14] =  0;
    assign res[15] =  0;
endmodule

module ADoublePart1(input [`L-1:0]  src, input [`L-1:0] rand_i, output [`L-1:0] res);
    assign res[00] =  rand_i[00] ^ src[09] ^ src[11] ^ src[14] ^ 1;
    assign res[01] =  rand_i[01] ^ src[09] ^ src[10] ^ src[11] ^ src[12] ^ src[14] ^ src[15];
    assign res[02] =  rand_i[02] ^ src[00] ^ src[02] ^ src[03] ^ src[05] ^ src[06] ^ src[07];
    assign res[03] =  rand_i[03] ^ src[01] ^ src[02] ^ src[04] ^ src[07];
    assign res[04] =  rand_i[04] ^ src[02] ^ src[12] ^ src[13] ^ src[14] ^ src[15] ^ 1;
    assign res[05] =  rand_i[05] ^ src[00] ^ src[02] ^ src[03] ^ src[04] ^ src[05] ^ src[07];
    assign res[06] =  rand_i[06] ^ src[00] ^ src[01] ^ src[02] ^ src[05] ^ src[09] ^ src[11] ^ src[14] ^ src[15] ^ 1;
    assign res[07] =  rand_i[07] ^ src[00] ^ src[02] ^ src[03] ^ src[06] ^ src[07];
    assign res[08] =  rand_i[08] ^ src[01] ^ src[04] ^ src[05];
    assign res[09] =  rand_i[09] ^ src[00] ^ src[02] ^ src[03] ^ src[04] ^ src[06] ^ src[07];
    assign res[10] =  rand_i[10] ^ src[02] ^ src[04] ^ src[05] ^ src[06] ^ src[08] ^ src[10] ^ src[13] ^ src[14];
    assign res[11] =  rand_i[11] ^ src[00] ^ src[02] ^ src[06] ^ src[08] ^ src[13] ^ src[14] ^ src[15];
    assign res[12] =  rand_i[12] ^ src[02] ^ src[03] ^ src[06];
    assign res[13] =  rand_i[13] ^ src[02] ^ src[04] ^ src[05] ^ src[06] ^ src[07] ^ src[13] ^ src[14];
    assign res[14] =  rand_i[14] ^ src[03] ^ src[05] ^ src[06] ^ src[08] ^ src[09] ^ src[10] ^ src[11] ^ src[12];
    assign res[15] =  rand_i[15] ^ src[08] ^ src[10] ^ src[13];
endmodule

module ADoublePart2(input [`L-1:0] src, output [`L-1:0] res);
    assign res[00] =  0;
    assign res[01] =  0;
    assign res[02] =  src[08] ^ src[10] ^ src[14];
    assign res[03] =  src[11] ^ src[12] ^ src[13] ^ src[14] ^ src[15];
    assign res[04] =  0;
    assign res[05] =  src[08] ^ src[11] ^ src[15];
    assign res[06] =  0;
    assign res[07] =  src[08] ^ src[10] ^ src[11] ^ src[15];
    assign res[08] =  src[08] ^ src[11] ^ src[12] ^ src[13] ^ src[14];
    assign res[09] =  src[08] ^ src[09] ^ src[10] ^ src[15];
    assign res[10] =  0;
    assign res[11] =  0;
    assign res[12] =  src[08] ^ src[10] ^ src[11] ^ src[12] ^ src[13] ^ src[14] ^ src[15];
    assign res[13] =  0;
    assign res[14] =  0;
    assign res[15] =  0;
endmodule

module ATriplePart1(input [`L-1:0]  src, input [`L-1:0] rand_i, output [`L-1:0] res);
    assign res[00] =  rand_i[00] ^ src[00] ^ src[02] ^ src[03] ^ src[05] ^ src[06] ^ src[07] ^ src[08] ^ src[09] ^ src[12] ^ src[13] ^ src[15];
    assign res[01] =  rand_i[01] ^ src[01] ^ src[02] ^ src[04] ^ src[07] ^ src[09] ^ src[10] ^ src[11] ^ src[12] ^ src[14];
    assign res[02] =  rand_i[02] ^ src[00] ^ src[03] ^ src[05] ^ src[06] ^ src[07] ^ src[08] ^ src[10] ^ src[14];
    assign res[03] =  rand_i[03] ^ src[01] ^ src[02] ^ src[06] ^ src[07] ^ src[11] ^ src[13] ^ src[14] ^ 1;
    assign res[04] =  rand_i[04] ^ src[00] ^ src[02] ^ src[04] ^ src[05] ^ src[07] ^ src[09] ^ src[11] ^ src[12] ^ src[13] ^ src[14] ^ 1;
    assign res[05] =  rand_i[05] ^ src[00] ^ src[03] ^ src[04] ^ src[07] ^ src[08] ^ src[10] ^ src[11] ^ src[12] ^ src[13] ^ src[14] ^ 1;
    assign res[06] =  rand_i[06] ^ src[00] ^ src[01] ^ src[04] ^ src[06] ^ src[07] ^ src[08] ^ src[09] ^ src[13] ^ src[15] ^ 1;
    assign res[07] =  rand_i[07] ^ src[00] ^ src[02] ^ src[05] ^ src[07] ^ src[15] ^ 1;
    assign res[08] =  rand_i[08] ^ src[01] ^ src[04] ^ src[05] ^ src[11] ^ src[12] ^ src[13] ^ src[14];
    assign res[09] =  rand_i[09] ^ src[00] ^ src[02] ^ src[03] ^ src[04] ^ src[06] ^ src[07] ^ src[08] ^ src[10] ^ src[15];
    assign res[10] =  rand_i[10] ^ src[02] ^ src[04] ^ src[05] ^ src[06] ^ src[08] ^ src[13] ^ src[14];
    assign res[11] =  rand_i[11] ^ src[00] ^ src[02] ^ src[06] ^ src[08] ^ src[11] ^ src[13] ^ src[14] ^ src[15];
    assign res[12] =  rand_i[12] ^ src[02] ^ src[03] ^ src[06] ^ src[08] ^ src[10] ^ src[11] ^ src[13] ^ src[14] ^ src[15];
    assign res[13] =  rand_i[13] ^ src[02] ^ src[04] ^ src[05] ^ src[06] ^ src[07] ^ src[14];
    assign res[14] =  rand_i[14] ^ src[03] ^ src[05] ^ src[06] ^ src[08] ^ src[09] ^ src[10] ^ src[11] ^ src[12] ^ src[14];
    assign res[15] =  rand_i[15] ^ src[08] ^ src[10] ^ src[13] ^ src[15];
endmodule

module ATriplePart2(input [`L-1:0] src, output [`L-1:0] res);
    assign res[00] =  0;
    assign res[01] =  0;
    assign res[02] =  0;
    assign res[03] =  0;
    assign res[04] =  0;
    assign res[05] =  0;
    assign res[06] =  0;
    assign res[07] =  0;
    assign res[08] =  0;
    assign res[09] =  0;
    assign res[10] =  0;
    assign res[11] =  0;
    assign res[12] =  0;
    assign res[13] =  0;
    assign res[14] =  0;
    assign res[15] =  0;
endmodule

`endif
