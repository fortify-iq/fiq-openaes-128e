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

/*
  Encryption module of AES-128 enc-only core
  It implements encryption and key expansion logic and supports ability to export round keys during key scheduling process
  to use it by external system (for example , it may be used in pipelined GCM module)
*/

module AES128enc_Coding (
    input wire clk_i                     // Clock, active rising edge
  , input wire srst_i                    // synch reset, active HIGH
  , input wire start_i                   // Strobe to initiate computation, active HIGH
  , input wire ctrl_st_ke                // key scheduling strob
  , input wire ctrl_st_code              // state coding strob
  , input wire ctrl_enc_last             // last lock ycle of encryption module (all before the last AddRoundKey)
  , input wire ctrl_st_out               // last clock of AES coding (when the last AddRoundKey)
  , input wire ctrl_st_unmask            // Indicate pulse when do unmasking of masked result
  , input wire ctrl_st_entry             // first clock of coding process
  , input wire [16*`L-1:0] Rkey // round key input (may be unmasked if Canright algo). Used for key expansion
  , input wire [16*`L-1:0] Rkey_masked   // masked round key input - to use when need to interact with state (AddRoundKey for example)
  , input wire [7:0] KeyExpProd_i        // key exp constants (rcon), KeyExpProd_i - latched, from register module
  , output wire [7:0] KeyExpProd_o       // KeyExpProd_o - next for latch in the register module
  , output wire [16*`L-1:0] key_o // next round key to the registers module
  , input wire [16*`L-1:0] State         // masked uurent state
  , output wire [16*`L-1:0] state_o      // next encrypted state
  , input wire [7*`L-1:0] noise_i // input noise for rerandomization
);
  
  // Key expansion =============================================================

  KeyExpansionStage_128e ke(
      .key_i(Rkey)
    , .prod_i(KeyExpProd_i)
    , .noise_i(noise_i)
    , .key_o(key_o)
    , .prod_o(KeyExpProd_o)
  );

  // Encryption round ==========================================================
  // the module includes 20 protected S-Boxes and invertors
  EncodingStage_128e enc(
      .last_i(ctrl_enc_last)
    , .state_i(State)
    , .key_i(Rkey) 
    , .noise_i(noise_i)
    , .state_o(state_o)
  );

endmodule
