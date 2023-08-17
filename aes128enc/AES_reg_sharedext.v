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

module AES_reg_sharedext (
    clk_i                  // Clock, active rising edge    
  , srst_i                 // synch reset, active HIGH
  , start_i                // Strobe to initiate computation, active HIGH
  , ctrl_st_unmask         // unmask comand, is not used, the same as with reset signal
  , ctrl_st_out            // last AddRoundKey flag, is not used, the same as with reset signal
  , state_share2_i         // bytes of state share 2 form input masking module
  , key_share2_i           // bytes of key share 2 form input masking module
  , state_rnd              // stored state (random) share 2. Masked if used state_share2_i from input masking module
  , state_share2_o         // output share 2 (random share) of result
  , key_rnd                // stored key (random) share 2. Masked if used key_share2_i was from input masking module
  , key_destruct_i         // key destruction comand to erase all footprints
);

  localparam KEY_SZ = 16;
  input wire clk_i;
  input wire srst_i;
  input wire start_i;
  input wire ctrl_st_unmask;
  input wire ctrl_st_out;
  input wire [16*`L-1:0] state_share2_i;
  input wire [KEY_SZ*`L-1:0] key_share2_i;
  output wire [16*`L-1:0] state_rnd;
  output reg [127:0] state_share2_o;
  output wire [KEY_SZ*`L-1:0] key_rnd;
  input wire key_destruct_i;

  genvar i;
  integer j;
  
  reg [16*8-1:0] state_rnd_reg;
  reg [KEY_SZ*8-1:0] key_rnd_reg;
  // for random shares no randomization for redundant bytes, only basis conversion, so it bits are zero
  // randomization performed for main (1st) shares
  for (i = 0; i < 16; i = i + 1) begin 
    assign state_rnd[i*`L+:8] = state_rnd_reg[i*8+:8];
    assign state_rnd[i*`L+8+:`RED] = `RED'b0;
  end
  for (i = 0; i < KEY_SZ; i = i + 1) begin
    assign key_rnd[i*`L+:8] = key_rnd_reg[i*8+:8];
    assign key_rnd[i*`L+8+:`RED] = `RED'b0;
  end
  
  wire [16*`L-1:0] state_rnd_to_unmask;
  for (i = 0; i < 16; i = i + 1) begin
    assign state_rnd_to_unmask[i*`L+:8] = state_rnd_reg[i*8+:8];
    assign state_rnd_to_unmask[i*`L+8+:`RED] = `RED'b0;
  end


  integer k;

  always @(posedge clk_i) begin
`ifdef DEBUG_RESET
    if (srst_i) begin
      state_rnd_reg <= '0;
      key_rnd_reg <= '0;
    end else begin
`endif
    if (start_i) begin
      for (k = 0; k < 16; k = k + 1) begin
        state_rnd_reg[k*8+:8] <= state_share2_i[k*`L+:8];
      end
      for (k = 0; k < KEY_SZ; k = k + 1) begin
        key_rnd_reg[k*8+:8] <= key_share2_i[k*`L+:8];
      end
    end
    if (key_destruct_i)
      key_rnd_reg <= {KEY_SZ*8{1'b0}};
`ifdef DEBUG_RESET
    end
`endif
  end


  wire [127:0] state_5_rnd_invord_sh ;// Output buffer reduced

  // Toggle endianness 
  // Convert to default representation 
  BasisToStd  sb1s_rnd( ctrl_st_unmask ? state_rnd_to_unmask : {16*`L{1'b0}}, state_5_rnd_invord_sh );
  // Buffering result output
  always@(posedge clk_i) begin
    if (srst_i)
      state_share2_o <= 0;
    else if (ctrl_st_unmask) // if registers are masked, need unmask before store to output register, otherwise - just from source registers
      state_share2_o <= state_5_rnd_invord_sh;
  end
  
endmodule
