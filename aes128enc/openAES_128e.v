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
 AES128 encryption core
 Standard version with 20 Sbox'es
 Data and key ports are big-endian
 
 Latency      size       enc/dec           Sbox #
 12 cycles    AES-128    encryption only   20 Sboxes
*/
 
`include "defines.h"

module openAES_128e (
    input wire clk_i                      // Clock, active rising edge    
  , input wire srst_i                     // synch reset, active HIGH
  , input wire start_i                    // Strobe to initiate computation, active HIGH
  , input wire [127 :0] state_i           // Input data block
  , input wire [127 :0] key_i             // Input key
  , input wire [127 :0] state_share2_i    // Input data block share 2 (if enabled)
  , input wire [127 :0] key_share2_i      // Input key share 2 (if enabled)
  , input wire [39*`RED-1:0] rand_i // Random input for protection system
  , output wire [127:0] state_o           // Output data block
  , output wire [127:0] state_share2_o    // Output data block share 2 (if enabled)
  , output wire done_o                    // Strobe at output data valid
  , output wire ready_o                   // Signals that we are ready to receive new task
  , input wire key_destruct_i             // destruct key command, to clean off the stored key
);
  parameter CORE_TYPE = "AES128enc";
  parameter AES_STD = "AES-128";

  generate  if(`RED+8 != `L )ERROR_WRONG_PARAMETER_L COMPILE_ERROR(); endgenerate  // Check for macro parameter correctness
  genvar i;
  
  // State and Key lines
  wire [16*`L-1:0] State; // Currently saved state        
  wire [16*`L-1:0] State_2, State_rnd_2; // Masked state and state share 2 from input stage
  wire [16*`L-1:0] state_rnd, key_rnd; // masked state and key shares 2 from shares registers
  // stored state and key shares (masked of unmasked regarding configurations)
  wire [16*`L-1:0] state_rnd_stored, key_rnd_stored;
  wire [16*`L-1:0] Key_2, Key_rnd_2; // Masked key and key share 2 from input stage
  
  // Conrtol lines
  wire ctrl_st_out;    // Indicates the output generation phase
  wire ctrl_st_unmask; // unmask-pulse - when to unmask the result, actual code-strob for coding stage

  // Input processing module ( ShiftBlock and AddNoise ) =======================
  AES_input #(
      .STATE_RANDOMIZATION_EN(1)
    , .KEY_RANDOMIZATION_EN(1)
    , .NOISE_GENERATION_EN(0)
    , .KEY_SZ(16)
    , .DAT_SZ(16)
  ) in (
      .state_i(state_i)
    , .key_i(key_i)
    , .rand_i(rand_i[32*`RED-1:0])
    , .noise_o()
    , .state_o(State_2)
    , .key_o(Key_2)
  );

  // protected AES kernel. It operate with masked shares (if enabled) of input state and key
  // All masking and unmasking logic are in the dedicated modules on the top-level
  openAES_128e_Core core (
      .clk_i(clk_i)
    , .srst_i(srst_i)
    , .start_i(start_i)
    , .state_i(State_2)
    , .key_i(Key_2)
    , .state_share2_i(state_rnd)
    , .key_share2_i(key_rnd)
    , .ctrl_st_unmask(ctrl_st_unmask)
    , .ctrl_st_out(ctrl_st_out)
    , .rand_i(rand_i[32*`RED +: 7*`RED])
    , .state_o(State)
    , .done_o(done_o)
    , .ready_o(ready_o)
    , .key_destruct_i(key_destruct_i)
  );

  // output state register with unmasking logic. If shares enabled it is for share 1
  AES_128e_reg_output regout (
      .clk_i(clk_i)
    , .srst_i(srst_i)
    , .state_i(State)
    , .ctrl_st_unmask(ctrl_st_unmask)
    , .ctrl_st_out(ctrl_st_out)
    , .state_buf_o(state_o)
  );
  
// ==============================================================================================================
  // Input processing module ( ShiftBlock and AddNoise ) =======================
  // If enabled, 2nd shares input process is the same as for general inputs
  // but it is able to configure: masked or unmasked shares storage.
  // if unmasked, the masked logit is between unmasked regiters and coding logic.
  // if masked, the masked shares are directly passed to the XOR (to unshare) before coding logic.
  AES_input #(
      .STATE_RANDOMIZATION_EN(0)
    , .KEY_RANDOMIZATION_EN(0)
    , .NOISE_GENERATION_EN(0)
    , .KEY_SZ(16)
    , .DAT_SZ(16)
  ) in_rnd (
      .state_i(state_share2_i)
    , .key_i(key_share2_i)
    , .rand_i(1'b0)
    , .noise_o()
    , .state_o(State_rnd_2)
    , .key_o(Key_rnd_2)
  );

  assign state_rnd = state_rnd_stored;
  assign key_rnd = key_rnd_stored;

  // configurable storage for shares 2 of state and key
  AES_reg_sharedext reg_rnd(
      .clk_i(clk_i)
    , .srst_i(srst_i)
    , .start_i(start_i & ready_o)
    , .ctrl_st_unmask(ctrl_st_unmask)
    , .ctrl_st_out(ctrl_st_out)
    , .state_share2_i(State_rnd_2)
    , .key_share2_i(Key_rnd_2)
    , .state_rnd(state_rnd_stored)
    , .state_share2_o(state_share2_o)
    , .key_rnd(key_rnd_stored)
    , .key_destruct_i(key_destruct_i)
  );
endmodule
