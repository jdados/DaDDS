module ook_dds(
    input wire clk,
    input wire rst,
    input wire rx,
    input wire ook_data,
    output wire [7:0] dac
);
    wire [7:0] phase;
    wire [7:0] lut_out;   
    wire [7:0] sine_values [63:0];

    // Hardcoded sine values
    assign sine_values[0] = 8'd128; assign sine_values[1] = 8'd131; assign sine_values[2] = 8'd134; 
    assign sine_values[3] = 8'd137; assign sine_values[4] = 8'd140; assign sine_values[5] = 8'd143; 
    assign sine_values[6] = 8'd146; assign sine_values[7] = 8'd149; assign sine_values[8] = 8'd152; 
    assign sine_values[9] = 8'd156; assign sine_values[10] = 8'd159; assign sine_values[11] = 8'd162; 
    assign sine_values[12] = 8'd165; assign sine_values[13] = 8'd168; assign sine_values[14] = 8'd171; 
    assign sine_values[15] = 8'd174; assign sine_values[16] = 8'd176; assign sine_values[17] = 8'd179; 
    assign sine_values[18] = 8'd182; assign sine_values[19] = 8'd185; assign sine_values[20] = 8'd188; 
    assign sine_values[21] = 8'd191; assign sine_values[22] = 8'd193; assign sine_values[23] = 8'd196; 
    assign sine_values[24] = 8'd199; assign sine_values[25] = 8'd201; assign sine_values[26] = 8'd204; 
    assign sine_values[27] = 8'd206; assign sine_values[28] = 8'd209; assign sine_values[29] = 8'd211; 
    assign sine_values[30] = 8'd213; assign sine_values[31] = 8'd216; assign sine_values[32] = 8'd218; 
    assign sine_values[33] = 8'd220; assign sine_values[34] = 8'd222; assign sine_values[35] = 8'd224; 
    assign sine_values[36] = 8'd226; assign sine_values[37] = 8'd228; assign sine_values[38] = 8'd230; 
    assign sine_values[39] = 8'd232; assign sine_values[40] = 8'd234; assign sine_values[41] = 8'd235; 
    assign sine_values[42] = 8'd237; assign sine_values[43] = 8'd239; assign sine_values[44] = 8'd240; 
    assign sine_values[45] = 8'd242; assign sine_values[46] = 8'd243; assign sine_values[47] = 8'd244; 
    assign sine_values[48] = 8'd246; assign sine_values[49] = 8'd247; assign sine_values[50] = 8'd248; 
    assign sine_values[51] = 8'd249; assign sine_values[52] = 8'd250; assign sine_values[53] = 8'd251; 
    assign sine_values[54] = 8'd251; assign sine_values[55] = 8'd252; assign sine_values[56] = 8'd253; 
    assign sine_values[57] = 8'd253; assign sine_values[58] = 8'd254; assign sine_values[59] = 8'd254; 
    assign sine_values[60] = 8'd254; assign sine_values[61] = 8'd255; assign sine_values[62] = 8'd255; 
    assign sine_values[63] = 8'd255;

    // Symmetry-based addressing
    wire [5:0] phase_index;
    assign phase_index = 
        (phase < 8'd64) ? phase[5:0] :                // 0° to 90°
        (phase < 8'd128) ? (8'd127 - phase[5:0]) :    // 90° to 180° 
        (phase < 8'd192) ? (phase[5:0] - 8'd128) :    // 180° to 270°
                            (8'd255 - phase[5:0]);     // 270° to 360° 

    //LUT indexing
    assign lut_out = sine_values[phase_index];

    // Phase Accumulator
    wire [31:0] phase_reg_out;
    wire [31:0] adder_out;
    wire [31:0] sig_freq_reg_out;

    // Component instantiations
    uart_rx uart (
        .clk(clk),                  
        .rx(rx),                   
        .rst(rst),                 
        .done(),                   
        .tx_sig_freq(sig_freq_reg_out), 
        .byte_num(),                
        .state()                   
    );

    sum32 adder (
        .clk(clk),
        .en(1'b1),
        .rst(rst),
        .a(sig_freq_reg_out),
        .b(phase_reg_out),
        .sum(adder_out)
    );

    reg32 phase_reg (
        .clk(clk),
        .en(1'b1),
        .rst(rst),
        .d(adder_out),
        .q(phase_reg_out)
    );

    // Use 8 most significant bits
    assign phase = phase_reg_out[31:24]; 

    // OOK logic
    assign dac = (ook_data == 1'b1) ? lut_out : 8'd128;

endmodule
