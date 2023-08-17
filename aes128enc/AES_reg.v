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
module AES_reg #(
    parameter KEYEXPPROD_REG_EN = 1
) (
    clk_i          // Clock, active rising edge    
  , srst_i         // synch reset, active HIGH
  , start_i        // Strobe to initiate computation, active HIGH
  , ctrl_st_ke     // Indicates the key expansion direct phase
  , ctrl_st_ike    // Indicates the key expansion inverse phase
  , ctrl_st_code   // Indicates the encryption phase
  , ctrl_st_out    // Indicates the output generation phase, when AES enc/dec done and last AddRoundKey or inverse Shift Rows applied.
                   // If shares enabled, there is also restored state sharing
  , ctrl_st_unmask // Inidicates that there is a time to unmask and store result in an output register
                   // If share disable - it is the same as ctrl_st_out, otherwise - at the next clock cycle after ctrl_st_out
  , ctrl_last      // last clock of encryption/decryption module (before the last AddRoundKey)
  , mode_i         // select AES (key) size: 01 - 128, 10 - 192, 11 - 256
  , State_input_i  // From input stage
  , State_code_i   // From encoding/decoding stage
  , Key_input_i    // From input stage
  , Key_ke_i       // From key expansion stage
  , noise_input_i  // Additive masking noise, just to save internaly to register
  , KeyExpProd_i   // Round constant for key expansion, just to save
  , rand_i         // Random noise
  , KeyExpProd_o   // Round constant for key expansion 
  , noise_o        // Additive masking noise
  , state_buf_o    // Output data block, to be connected to the core's result output
  , State_o        // Current state
  , Key_o          // Round key for both the encryption round (least significand half) and the key expansion stage
  , key_dec_prepared_o // prepared last round key that may be used as the first for decryption. It is output just in case. Actually, it is internal for now
  , Key_masked_o   // masked round key. This output always masked. It is need because of ability to use non-protected S-Boxes (based on Canright)
                   // for key sheduling. If key is unmasked (when Canright used), it must be musked before to use for interaction with a masked state
  , encode_i       // enc/dec comand; 1 - enc, 0 - dec
  , use_prepared_key // use prepare round key for decryption instead direct (re)expansion.
  , key_destruct_i // key destruction comand to erase all footprints of previous key processing
);

  // configure key and noise sizes
  localparam NOISE_SZ = 7;
  localparam KEY_SZ = 16;

  input wire clk_i;
  input wire srst_i;
  input wire start_i;
  input wire ctrl_st_ke;
  input wire ctrl_st_ike;
  input wire ctrl_st_code;
  input wire ctrl_st_out;
  input wire ctrl_st_unmask;
  input wire ctrl_last;
  input wire [1:0] mode_i;
  input wire [16*`L-1:0] State_input_i;
  input wire [16*`L-1:0] State_code_i;
  input wire [KEY_SZ*`L-1:0] Key_input_i;
  input wire [KEY_SZ*`L-1:0] Key_ke_i;
  input wire [NOISE_SZ*`L-1:0] noise_input_i;
  input wire [7:0] KeyExpProd_i;
  input wire [KEY_SZ*`L-1:0] rand_i;
  output reg [7:0] KeyExpProd_o;
  output reg [NOISE_SZ*`L-1:0] noise_o;
  output reg [127:0] state_buf_o;
  output wire [16*`L-1:0] State_o;
  output reg [KEY_SZ*`L-1:0] Key_o;
  output reg [KEY_SZ*`L-1:0] key_dec_prepared_o;
  output wire [KEY_SZ*`L-1:0] Key_masked_o;
  input wire encode_i;
  input wire use_prepared_key;
  input wire key_destruct_i;

  genvar i;
  // Error signals handling
  integer j;

  // State
  // protected state register with support of DFA protection
  AntiFI_StateReg sr (
      .clk_i(clk_i)
    , .srst_i(1'b0)
    , .code_enable(ctrl_st_code)
    , .State_code_i(State_code_i)
    , .Start_enable(start_i)
    , .State_start_i(State_input_i)
    , .State_o(State_o)  
  );
  integer k;

  // In this rtl DFA_PROTECTION affects only for using of error signal. If DFA_PROTECTION disabled, error signals not used
  always@(posedge clk_i) begin
`ifdef DEBUG_RESET
    if (srst_i)
        Key_o <= {(KEY_SZ*`L){1'b0}};
    else
`endif
    if (key_destruct_i)
      Key_o <= rand_i;
    else if (start_i) begin
      Key_o <= Key_input_i;
    end else if (ctrl_st_ke) // update next round key
      Key_o <= Key_ke_i;
  end


  // Noise saving
  always @(posedge clk_i) begin
    if (start_i)
      noise_o <= noise_input_i;
    else if (ctrl_st_code) // cycling noise for better protection
      noise_o <= {noise_o[0 +: (NOISE_SZ-1)*`L], noise_o[(NOISE_SZ-1)*`L +: `L]};
  end


// ==== State transformation for output, with the last AddRoundKey ============================

  wire [127:0] state_5_invord_sh;// Output buffer reduced

  wire [16*`L-1:0] state_to_unmask;
  // if shares enabled, key is already added at the previou clock cycle during share restoring
  assign state_to_unmask = (ctrl_st_unmask ? State_o : {(16*`L){1'b0}});

  // Convert to default representation 
  BasisToStd sb1s (state_to_unmask, state_5_invord_sh);

  // Buffering result output
  always@(posedge clk_i) begin
    if (srst_i)
      state_buf_o <= 0;
    else if (ctrl_st_unmask)
      state_buf_o <= state_5_invord_sh;
  end

  assign Key_masked_o = Key_o;
  
  // Save key expansion round constant 
  if (KEYEXPPROD_REG_EN) begin
    always @(posedge clk_i) begin // KeyExpProd
      if (start_i) begin
        KeyExpProd_o <= 0;
      end else
        KeyExpProd_o <= KeyExpProd_i;
    end
  end else begin
    always @* KeyExpProd_o = 8'h0;
  end
endmodule
