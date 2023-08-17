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
module AES_input #(
    parameter STATE_RANDOMIZATION_EN = 0
  , parameter KEY_RANDOMIZATION_EN = 0
  , parameter NOISE_GENERATION_EN = 1
  , parameter KEY_SZ = 32
  , parameter DAT_SZ = 16
) (
    state_i  // Input data block
  , key_i    // Input key
  , rand_i   // Random noise
  , noise_o  // Additive noise
  , state_o  // Input data block, converted to redundand masked representation
  , key_o    // Input key, converted to redundand masked representation
);
  
  input wire [DAT_SZ*8-1:0] state_i;
  input wire [KEY_SZ*8-1:0] key_i;
  // configure noise and random sizes regarding module parameters
  localparam NOISE_SIZE = 7;
  localparam RAND_SIZE = (KEY_RANDOMIZATION_EN ? KEY_SZ : 0)
                       + (STATE_RANDOMIZATION_EN ? DAT_SZ : 0)
                       + (NOISE_GENERATION_EN ? NOISE_SIZE : 0);
  input wire [(RAND_SIZE > 0 ? RAND_SIZE*`RED-1 : 0):0] rand_i;
  output wire [NOISE_SIZE*`L-1:0] noise_o;
  output wire [DAT_SZ*`L-1:0] state_o;
  output wire [KEY_SZ*`L-1:0] key_o;

  genvar i;
  wire [DAT_SZ*`L-1:0] State_sb;
  wire [DAT_SZ*`L-1:0] State_n;
  wire [KEY_SZ*`L-1:0] Key_sb;
  wire [KEY_SZ*`L-1:0] noise;
  wire [DAT_SZ*`L-1:0] st_noise;
  
  // Additive noise generation
  if (KEY_RANDOMIZATION_EN) begin
    GenerateNoise #(KEY_SZ) gn (rand_i[0+:KEY_SZ*`RED], noise);
  end
  if (STATE_RANDOMIZATION_EN) begin
    GenerateNoise sgn (rand_i[KEY_SZ*`RED+:DAT_SZ*`RED], st_noise);
  end

  if (NOISE_GENERATION_EN) begin
    localparam NOISE_GEN_POS = STATE_RANDOMIZATION_EN ? KEY_SZ + DAT_SZ : KEY_SZ;
    GenerateNoise #(NOISE_SIZE) ogn (rand_i[NOISE_GEN_POS*`RED+:NOISE_SIZE*`RED], noise_o);
  end else begin
    assign noise_o = {(NOISE_SIZE*`L){1'b0}};
  end

  // change basis of key and state
  BasisFromStd #(KEY_SZ) sbk(key_i, Key_sb);
  BasisFromStd #(DAT_SZ) sbs(state_i, State_sb);
    
  // Masking state and key with additive noise
  if (KEY_RANDOMIZATION_EN) begin
    assign key_o = Key_sb ^ noise;
  end else begin
    assign key_o = Key_sb;
  end
  
  if (STATE_RANDOMIZATION_EN) begin
    assign state_o = State_sb ^ st_noise;
  end else begin
    assign state_o = State_sb; // may be configured to not use a noise
  end
 
endmodule
