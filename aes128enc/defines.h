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

`ifndef DEFINE_H
`define DEFINE_H
  `ifndef CONFIG_FROM_TOOL
    `include "config.h"
  `endif
  
 `ifdef REDUNDANCY_8  
  `define RED 8 
  `define L   16
  `define PQ "169_17B"
  `ifdef NEW_LA_EN
    `define NEW_LA
  `endif
 `endif

 `timescale 1ns/1ps

 `ifdef REDUNDANCY_13
  `define RED 13 
  `define L   21
  `define PQ "11D_238D"
 `endif

 `define RANDOM_SIZE 39*`RED
`endif
 
