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
  Output data and error flag register with data unmasking logic
*/
module AES_128e_reg_output (
    input wire clk_i               // clock
  , input wire srst_i              // synch reset, active level - 1
  , input wire [16*`L-1:0] state_i // masked (and randomized) input state to store
  , input wire ctrl_st_unmask      // unmask pulse. when 1, it is time to unmask and store the state. 
  , input wire ctrl_st_out         // AES coding end, data outputed from the coding stage. the error flag is captured at this pulse
  , output reg [127:0] state_buf_o // registerd unmasked output state
);

  genvar i;
  wire [127:0] state_5_invord_sh; // unmasked state
  // Convert to default representation 
  BasisToStd  sb1s( state_i, state_5_invord_sh );

  // Buffering result output
  always @(posedge clk_i) begin
    if (srst_i)
      state_buf_o <= 128'h0;
    else if (ctrl_st_unmask)
      state_buf_o <= state_5_invord_sh;
  end

endmodule
