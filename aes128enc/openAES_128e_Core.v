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
  Masked core for AES-128 enc-only Core with 20 S-Boxes.
  It operate only with masked data. All masking and unmasking logic are external to the module
*/

module openAES_128e_Core (
    input wire clk_i                       // Clock, active rising edge
  , input wire srst_i                      // synch reset, active HIGH
  , input wire start_i                     // Strobe to initiate computation, active HIGH
  , input wire [16*`L-1 :0] state_i        // Input data block
  , input wire [16*`L-1:0] key_i // Input key
  , input wire [16*`L-1 :0] state_share2_i // Input data block random share 2 (if enabled)
  , input wire [16*`L-1 :0] key_share2_i   // Input data block random share 2 (if enabled)
  , output wire ctrl_st_unmask             // Indicates the output generation phase
  , output wire ctrl_st_out                // Indicates the first clock cycle of AES round
  , input wire [7*`RED-1:0] rand_i // Random input for protection system
  , output wire [16*`L-1:0] state_o        // Output data block
  , output wire done_o                     // Strobe at output data valid
  , output wire ready_o                    // Signals that we are ready to receive new task
  , input wire key_destruct_i              // key destruction comand to erase all footprints
);

  // State and Key lines
  wire [16*`L -1:0] State;                            // Currently saved state        
  wire [16*`L -1:0] State_o_shared, reg_state_code_i; // State_o_shared - restored sharing of state at the ctrl_st_out, reg_state_code_i - state to store in proteted reg
  wire [16*`L -1:0] State_4;                          // From encoding/decoding stage
  wire [7*`L -1:0] noise_2, noise;   // Additive noise
  wire [16*`L -1:0] Rkey; // Current Round key 
  wire [16*`L -1:0] Rkey_masked;                            // Current Round key, always masked. Rkey may be unmasked (if Canright used)
                                                            // It is wrong use unmasked key in AddRoundKey, so it must be masked
                                                            // This masked signal is used when need to interact with state
  wire [16*`L-1:0] Key_3; // From key expansion stage
  wire [16*`L-1:0] enc_state_i;                             // input for state encryption module
  wire [16*`L-1:0] enc_key_i; // input key for coding module

  wire [16*`L-1:0] key_unshared, state_unshared; // unshared masked key and state

  // Conrtol lines
  wire ctrl_enc_last;     // Indicates the processing of the last round    
  wire ctrl_st_ke;        // Indicates the key expansion phase
  wire ctrl_st_code;      // Indicates the encryption phase
  wire reg_ctrl_st_code;  // strob enabling update of the protected state register.
  wire ctrl_st_entry;     // start clock cycle of AES coding process

  // restore state share at the last lock cycle of coding (where last AddRoundKey) before unmasking
  assign State_o_shared = (ctrl_st_out ? State : 'h0) ^ (ctrl_st_out ? state_share2_i : 'h0);
  // remove sharing from masked data and key at the first clok of coding
  assign state_unshared = (ctrl_st_entry ? State : 'h0) ^ (ctrl_st_entry ? state_share2_i : 'h0);
  assign key_unshared = (ctrl_st_entry ? Rkey_masked : 'h0) ^ (ctrl_st_entry ? key_share2_i : 'h0);

  // Operation control =========================================================
  wire [8 -1:0] KeyExpProd, KeyExpProd_3;

  AES128_control ctrl(
      .clk_i(clk_i)
    , .srst_i(srst_i)
    , .start_i(start_i & ready_o)
    , .done_o(done_o)
    , .ready_o(ready_o)
    , .ctrl_last(ctrl_enc_last)
    , .ctrl_st_ke(ctrl_st_ke)
    , .ctrl_st_encode(ctrl_st_code)
    , .ctrl_st_out(ctrl_st_out)
    , .ctrl_st_unmask(ctrl_st_unmask)
    , .ctrl_st_entry(ctrl_st_entry)
    , .encrypt_i(1'b0)
    , .use_prepared_key(1'b0)
    , .ctrl_st_ike()
    , .ctrl_st_decode()
    , .ctrl_st_entry_ke()
  );

  // Registers and output logic ================================================
  wire [16*`L-1:0] rand_alligned; // allign random to fir key-size when it must be randomized when destrutioin
  localparam RAND_SIZE = 7;
  genvar i;
  for (i=0; i<(16*`L)/(RAND_SIZE*`RED); i=i+1) begin
    assign rand_alligned[i*RAND_SIZE*`RED +: RAND_SIZE*`RED] = rand_i;
  end
  if ((16*`L)%(RAND_SIZE*`RED) != 0) begin
    assign rand_alligned[((16*`L)/(RAND_SIZE*`RED))*(RAND_SIZE*`RED) +: (16*`L)%(RAND_SIZE*`RED)] = rand_i[0 +: (16*`L)%(RAND_SIZE*`RED)];
  end

  GenerateNoise #(RAND_SIZE) ogn (rand_i, noise_2);

  AES_reg #(
      .KEYEXPPROD_REG_EN(1)
  ) regs (
      .clk_i(clk_i)
    , .srst_i(srst_i)
    , .start_i(start_i & ready_o)
    , .ctrl_st_ke(ctrl_st_ke)
    , .ctrl_st_ike(1'b0)
    , .ctrl_st_code(reg_ctrl_st_code)
    , .ctrl_st_out(ctrl_st_out)
    , .ctrl_st_unmask(ctrl_st_unmask)
    , .ctrl_last(1'b0)
    , .mode_i(2'b00)
    , .State_input_i(state_i)
    , .State_code_i(reg_state_code_i)
    , .Key_input_i(key_i)
    , .Key_ke_i(Key_3)
    , .noise_input_i(noise_2)
    , .KeyExpProd_i(KeyExpProd_3)
    , .rand_i(rand_alligned)
    , .KeyExpProd_o(KeyExpProd)
    , .noise_o(noise)
    , .state_buf_o()
    , .State_o(State)
    , .Key_o(Rkey)
    , .key_dec_prepared_o()
    , .Key_masked_o(Rkey_masked)
    , .encode_i(1'b1)
    , .use_prepared_key(1'b0)
    , .key_destruct_i(key_destruct_i)
  );
  
  // When shares enabled, at the first clock of coding need to remove sharing from the state and key after its masked at the start_i
  // After coding done there is 1 additional clock cycle to restore shares before unmask result and write its shares to the output registers
  assign reg_state_code_i = ctrl_st_out ? State_o_shared ^ Rkey : State_4;
  assign reg_ctrl_st_code = ctrl_st_code | ctrl_st_out;
  assign enc_state_i = ctrl_st_code ? (ctrl_st_entry ? state_unshared : State) : 'h0;
  assign enc_key_i = ctrl_st_code ? (ctrl_st_entry ? key_unshared : Rkey_masked) : 'h0;

  AES128enc_Coding enc_base(
      .clk_i(clk_i)
    , .srst_i(srst_i)
    , .start_i(start_i)
    , .ctrl_st_ke(ctrl_st_ke)
    , .ctrl_st_code(ctrl_st_code)
    , .ctrl_enc_last(ctrl_enc_last)
    , .ctrl_st_out(ctrl_st_out)
    , .ctrl_st_unmask(ctrl_st_unmask)
    , .ctrl_st_entry(ctrl_st_entry)
    , .Rkey(enc_key_i)
    , .Rkey_masked(Rkey_masked)
    , .KeyExpProd_i(KeyExpProd)
    , .KeyExpProd_o(KeyExpProd_3)
    , .key_o(Key_3)
    , .State(enc_state_i)
    , .state_o(State_4)
    , .noise_i(noise)
  );

  assign state_o = ctrl_st_unmask ? State : {16*`L{1'b0}}; // if shares enabled, last AddRoundKey already done with share restoring at the previous clock cycle

endmodule

