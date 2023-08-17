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
 Large subblocks, instantiated in basic cores :
 AES key expansion, encoding & decodnig stages
 Some additional modules, common for most of cores
**/
`include "defines.h"

// FSM for control blocks
// One-hot, with Fault Injection Attack detection
// Supports intersection of first and last states

module OH_FSM #(
    parameter FSM_NSTAGES = 12            // Total number of stages
) (
    input wire clk_i                      // Clock, active rising edge 
  , input wire srst_i                     // Synchronous reset, active HIGH
  , input wire start_i                    // strobe to set state 0
  , output reg [ FSM_NSTAGES -1: 0] stage // One-hot state value
  , output reg done_o                     // Pusle at the core's output valid
  , output reg ready_o                    // Indicates that the core is ready to start new computation
); 

  // Flow control logic ========================================================
  wire ctrl_st_ready;
  always @* begin
    done_o = stage[FSM_NSTAGES-1];
  end

  assign ctrl_st_ready = !(|(stage[FSM_NSTAGES-4 : 0]));
  
  always @(posedge clk_i) begin
    if (srst_i)
      ready_o <= 1;
    else
      ready_o <= ctrl_st_ready && (~start_i);
  end
  
  // Stage/FSM counter =========================================================
  always @(posedge clk_i) begin
    if (srst_i)
      stage <= 0;
    else // shift one-hot state register 
      stage <= {stage[FSM_NSTAGES-2:0], start_i};
  end

endmodule

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// AES key expansion round
// AES128 only
// Self-contained, i.e. doesn't need for external Sbox
// Combinational-only
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
module  KeyExpansionStage_128e (
    input  wire   [16*`L  -1:0]   key_i                         // Key input from previous round
  , input  wire   [    8  -1:0]   prod_i                        // Round constant from previous round
  , input  wire   [7*`L  -1:0]   noise_i // Masking additive noise
  , output wire   [16*`L  -1:0]   key_o                         // Round key
  , output wire   [    8  -1:0]   prod_o                        // round constant (to be saved to regiser externally)
);      
  // Sbox (SubBytes stage) 
  wire [4*`L -1:0] sbox,add;
  
  wire [4*`L -1:0] sbox_in;
  assign sbox_in[0*`L +: `L] = key_i[13*`L+:`L];
  assign sbox_in[1*`L +: `L] = key_i[14*`L+:`L];
  assign sbox_in[2*`L +: `L] = key_i[15*`L+:`L];
  assign sbox_in[3*`L +: `L] = key_i[12*`L+:`L];
  genvar i;
  for(i=0;i<4;i=i+1) begin : SB
    wire [`L -1:0]  inv_u_in, inv_u2_in, inv_out;
    wire [4*`L-1:0] sbox_noise;
    assign sbox_noise[4*`L-1:`L] = {4*`L{1'b0}};
    assign sbox_noise[`L-1:0] = noise_i[7*`L-1:6*`L];
    Sbox_rand_ei sb ( sbox_in[i*`L +: `L], sbox_noise, inv_out, inv_u_in, inv_u2_in, sbox[i*`L +: `L],,);  // SBox
    Inverse_rand_2_3_12_14_15_240_254 inv( inv_u_in, inv_u2_in, noise_i[6*`L-1:0*`L], inv_out);
  end
  
  // Round constant computation
  wire [8 -1:0] prod_temp; 
  DoubleByte p(prod_i,prod_temp); 
  assign prod_o = (~|(prod_i)) ? 'h1 : prod_temp;  // Special case of prod_i=0 for first stage compatibility
  
  // Output computation
  assign add = sbox ^ {{3*`L+`RED{1'b0}}, prod_o};
  assign key_o[     0 +: 4*`L] = key_i[     0 +: 4*`L] ^ add;
  assign key_o[1*4*`L +: 4*`L] = key_i[1*4*`L +: 4*`L] ^ key_o[     0 +: 4*`L];
  assign key_o[2*4*`L +: 4*`L] = key_i[2*4*`L +: 4*`L] ^ key_o[1*4*`L +: 4*`L];
  assign key_o[3*4*`L +: 4*`L] = key_i[3*4*`L +: 4*`L] ^ key_o[2*4*`L +: 4*`L];
 
endmodule 

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// AES encryption round
// Self-contained, i.e. doesn't need for external Sbox
// Combinational-only
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
module  EncodingStage_128e (
    input wire last_i  // Indicates the last round (to bypass MixColumns)
  , input wire [16*`L-1:0] state_i // State from previous round
  , input wire [16*`L-1:0] key_i   // Round key
  , input wire [7*`L-1:0] noise_i // Additive masking noise
  , output wire [16*`L-1:0] state_o // computed state
);
  genvar i;
  wire [16*`L  -1:0] aXOR,  aSBOX0, aSBOX1, aSBOX2, aSR, aMC;
  // Add Round Key (from previous "classic" round)
  assign aXOR = key_i ^ state_i;
  // sbox + shiftrows
  for(i=0;i<16;i=i+1) begin : SBR
    assign aSR[i*`L +: `L] = aXOR[( (i*5)%16 )*`L +: `L]; // shiftrows
    wire [`L -1:0]  inv_u_in, inv_u2_in, inv_out;
    wire [4*`L-1:0] sbox_noise;
    assign sbox_noise[4*`L-1:`L] = {4*`L{1'b0}};
    assign sbox_noise[`L-1:0] = noise_i[7*`L-1:6*`L];
    // protected s-box
    Sbox_rand_ei sb ( aSR[i*`L +: `L], sbox_noise, inv_out, inv_u_in, inv_u2_in, aSBOX0[i*`L +: `L], aSBOX1[i*`L +: `L], aSBOX2[i*`L +: `L]);  // SBox
    Inverse_rand_2_3_12_14_15_240_254 inv( inv_u_in, inv_u2_in, noise_i[6*`L-1:0*`L], inv_out);
  end
  // mixcolumns
  MixColumns  mc(aSBOX0, aSBOX0, aSBOX1, aSBOX2, aMC);  
  assign state_o = last_i ? aSBOX0 : aMC; 
endmodule

