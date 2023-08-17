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
 Various basic blocks implementing different functions based on redundancy-protected arithmetics, for SCA protected AES cores
 Note: all modules are combinational here, except for AntiFI_StateReg and ErrRstGen
*/
`include "defines.h"

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// State register
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
module AntiFI_StateReg (
    input wire clk_i                     // Clock, active rising edge 
  , input wire srst_i                    // Synchronous reset, active HIGH
  , input wire code_enable               // When HIGH, data from State_code_i will be latched to register on clk_i posedge
  , input wire [16*`L-1:0] State_code_i  // Data from encryption/decryption round
  , input wire Start_enable              // When HIGH, data from State_start_i will be latched to register on clk_i posedge
  , input wire [16*`L-1:0] State_start_i // Data from input processing block
  , output wire [16*`L-1:0] State_o      // Register's output data
);
  wire [16*`L-1:0] State_in;
  reg [16*`L-1:0] state;
  // Input select
  
  assign State_in = 
`ifdef DEBUG_RESET
    srst_i ? {16*`L{1'b0}} :
`endif
    code_enable ? State_code_i : State_start_i
  ;

  // Register
  always @(posedge clk_i) begin 
    if (
`ifdef DEBUG_RESET
      srst_i || 
`endif
      code_enable || Start_enable)
        state <= State_in;
  end
  assign State_o = state;

endmodule

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// AES Sbox substitution
// Uses external inversion
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
module Sbox_rand_ei(input  wire [   `L -1:0]     x_i // Input data
                   ,input  wire [ 4*`L -1:0] noise_i // Additive masking noise
                   ,input  wire [   `L -1:0]   inv_i // Input from external inversion
                   ,output wire [   `L -1:0]  inv0_o // U to external inversion
                   ,output wire [   `L -1:0]  inv1_o // u*2 to external inversion
                   ,output wire [   `L -1:0]    q0_o // "A" output data
                   ,output wire [   `L -1:0]    q1_o // "A*2" output data
                   ,output wire [   `L -1:0]    q2_o // "A*3" output data
);
  wire [`L  -1:0] u254, u2;
	Pow2         st1(noise_i[ 0+: `L], x_i, u2  );
  
  // Inverse part
  assign inv0_o = x_i;
  assign inv1_o = u2;
  assign u254 = inv_i;
  // Affine part
	A       st2(noise_i[ 1*`L +: `L], u254      , q0_o);
	ADouble st3(noise_i[ 2*`L +: `L], u254      , q1_o);
	ATriple st4(noise_i[ 3*`L +: `L], u254      , q2_o);
endmodule


// Compact version of invertor for 1 and 4 sbox versions
module Inverse_rand_2_3_12_14_15_240_254(input  wire [   `L -1:0]     u_i // "U" input data
                   ,input  wire [   `L -1:0]    u2_i // "u*2" input data
                   ,input  wire [ 6*`L -1:0] noise_i // Additive masking noise
                   ,output wire [   `L -1:0]    q_o  // Output data
);
  wire [`L  -1:0] u3, u12, u14, u15, u240;
  // Inverse part
  Prod         st0(noise_i[ 0*`L +: `L], u_i, u2_i, u3   );
  Pow4         st1(noise_i[ 1*`L +: `L], u3, u12  );
  Prod         st4(noise_i[ 2*`L +: `L], u2_i, u12, u14  );
  Prod         st5(noise_i[ 3*`L +: `L], u3 , u12, u15 );
  Pow16        st2(noise_i[ 4*`L +: `L], u15, u240  );
  Prod         st6(noise_i[ 5*`L +: `L], u14, u240, q_o  );

endmodule

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// MixColumns stage
// Uses special algorithm, totally complement to the HardwareFriendlyCode
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
module MixColumns(input  wire [16*`L -1:0] d0_i  
                 ,input  wire [16*`L -1:0] d0a_i // d0a and d0 are the same for forward MC
                 ,input  wire [16*`L -1:0] d1_i  
                 ,input  wire [16*`L -1:0] d2_i  
                 ,output wire [16*`L -1:0] q_o   
                 );
  genvar j,k;
	generate for (j = 0; j < 4; j=j+1) begin    : A
    wire [4*`L-1:0] i0;  assign i0  = d0_i [j*4*`L +:4*`L];
    wire [4*`L-1:0] i1;  assign i1  = d1_i [j*4*`L +:4*`L];
    wire [4*`L-1:0] i2;  assign i2  = d2_i [j*4*`L +:4*`L];
    wire [4*`L-1:0] i0a; assign i0a = d0a_i[j*4*`L +:4*`L];
    wire [4*`L-1:0] o;   assign q_o[j*4*`L +:4*`L] = o;  
    assign o[0*`L+:`L] = i1[0*`L+:`L] ^ i2[1*`L+:`L] ^ i0[2*`L+:`L] ^ i0a[3*`L+:`L];
	  assign o[1*`L+:`L] = i1[1*`L+:`L] ^ i2[2*`L+:`L] ^ i0[3*`L+:`L] ^ i0a[0*`L+:`L];
	  assign o[2*`L+:`L] = i1[2*`L+:`L] ^ i2[3*`L+:`L] ^ i0[0*`L+:`L] ^ i0a[1*`L+:`L];
	  assign o[3*`L+:`L] = i1[3*`L+:`L] ^ i2[0*`L+:`L] ^ i0[1*`L+:`L] ^ i0a[2*`L+:`L];
  end endgenerate
endmodule


`ifndef NEW_LA
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Protected product of two redundancy-masked values
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
module Prod (input  wire [`L -1:0] noise  // Additive masking noise 
            ,input  wire [`L -1:0] x      // 1st operand
            ,input  wire [`L -1:0] y      // 2nd operand
            ,output wire [`L -1:0] q      // Result
            );
	wire [`L-1:0] deg[0:`L], res[0:`L];
	assign deg[0] = x;
	assign res[0] = noise;
  genvar i, j;
	generate for (i = 0; i < `L; i=i+1) begin
    wire [`L-1:0] deg_y;
    for (j = 0; j < `L; j = j + 1) begin
        assign deg_y[j] = deg[i][j] & y[i];
    end
		assign res[i + 1] = res[i] ^ deg_y;
		Mul2 mul(deg[i], deg[i + 1]);
	end endgenerate
	assign q = res[`L];
endmodule

`endif
