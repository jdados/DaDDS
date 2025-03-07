/*
 * Copyright (c) 2024 Jeremiasz Dados
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none

module tt_um_DaDDS (
    input  wire [7:0] ui_in,    // Dedicated inputs
    output wire [7:0] uo_out,   // Dedicated outputs
    input  wire [7:0] uio_in,   // IOs: Input path
    output wire [7:0] uio_out,  // IOs: Output path
    output wire [7:0] uio_oe,   // IOs: Enable path (active high: 0=input, 1=output)
    input  wire ena,      // always 1 when the design is powered, so you can ignore it
    input  wire clk,      // clock
    input  wire rst_n     // reset_n - low to reset
);

  // All output pins must be assigned. If not used, assign to 0.
  assign uio_out [7:0] = 0;
  assign uio_oe [7:0] = 8'hFF;
  // List all unused inputs to prevent warnings
  wire _unused = &{ena, ui_in[2:0], ui_in[7:6], uio_in[7:0], 1'b0};
  
  DaDDS top_level(
    .clk(clk),
    .rst(!rst_n),
    .rx(ui_in[3]),
    .freq_sel(ui_in[4]),
    .rf_data(ui_in[5]),
    .dac(uo_out)
  );

endmodule
