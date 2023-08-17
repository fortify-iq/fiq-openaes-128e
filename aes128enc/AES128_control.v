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
module AES128_control (
    input wire clk_i             // Clock, active rising edge    
  , input wire srst_i            // synch reset, active HIGH
  , input wire start_i           // Strobe to initiate computation, active HIGH
  , input wire encrypt_i         // Active HIGH for encryption mode, LOW for decryption.To be feed directly from the input
  , output wire done_o           // Strobe at output data valid
  , output wire ready_o          // Signals that we are ready to receive new task
  , output wire ctrl_last        // Indicates the processing of the last round    
  , output wire ctrl_st_ke       // Indicates the key expansion phase
  , output wire ctrl_st_ike      // Indicates the inverse key expansion phase
  , output wire ctrl_st_encode   // Indicates the encryption phase
  , output wire ctrl_st_decode   // Indicates the decryption phase
  , output wire ctrl_st_out      // Indicates the output generation phase
  , output wire ctrl_st_unmask   // Indicates the output generation phase
  , output wire ctrl_st_entry    // Indicates the first clock cycle of AES round
  , output wire ctrl_st_entry_ke // Indicates the first clock cycle of Key expansion stage.
                                 // FSM optimized for length, applied only for new key (when use_prepared_key = 0)
                                 // it is need for shares-implementation to unshare key at the first clock of processing.
                                 // If use_prepared_key = 1 (FSM optimized and the prepared key is used) the key is already unshared so no need to do it again
  , input wire use_prepared_key  // indication to use an already prepared last expaned round key as the first round key for decryption
);

  parameter KE_STAGES = 11;
  // In the cores with 20 S-Boxes there is hot-key FSM based on shift register
  // Base size of the register is defined by AES-128 standard. For AES-128 This size is 12.
  // It is 10 rounds plus 2 clocks for input and output processings.
  // If shares enabled, one additional clock cycle is added to share restore before unmasking
  // FSM is implemented in dedicated module with DFA protection support
  parameter FSM_NSTAGES = 13;
  wire [ FSM_NSTAGES -1: 0] stage;

  // Stage/FSM counter =========================================================
  
  assign ctrl_st_entry_ke = 1'b0;
  assign ctrl_st_decode = 1'b0;
  assign ctrl_st_ike = 1'b0;

  // one additional clock to restore shares before unmasking, so
  // final coding processes are further from the final stage for one clock cycle more
  assign ctrl_last = stage[ FSM_NSTAGES - 4 ];            // last stage of coding. There is only the last AddRounfKey after this stage 
  assign ctrl_st_ke = |(stage[ FSM_NSTAGES - 4 : 0]);     // Key expansion stage
  assign ctrl_st_encode = |(stage[ FSM_NSTAGES - 4 : 0]); // Encode/decode stage
  assign ctrl_st_out = stage[ FSM_NSTAGES - 3 ];          // write to output buffer
  assign ctrl_st_unmask = stage[FSM_NSTAGES-2];           // the pulse to unmask result to the output register.
  assign ctrl_st_entry = stage[0];                        // first clock of coing - entry to the coding process

  // FSM module that implemented to increase protection from FI attacks, detect it, and generate error flag on it
  OH_FSM #(
      .FSM_NSTAGES(FSM_NSTAGES)
  ) FSM (
      .clk_i(clk_i) 
    , .srst_i(srst_i)
    , .start_i(start_i)
    , .stage(stage)
    , .done_o(done_o)    // pusle at output valid
    , .ready_o(ready_o)
  );
endmodule
