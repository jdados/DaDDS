module ook_dds(
    input wire clk,
    input wire rst,
    input wire rx,
    input wire ook_data,
    output wire [7:0] dac
);

    wire [31:0] adder_out;
    wire [31:0] sig_freq_reg_out;
    wire [31:0] phase_reg_out;

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

    wire [8:0] phase;
    wire [7:0] lut_out;   
    wire [7:0] sine_values [127:0];

    // Assign the provided 128 values to the LUT
    assign sine_values[0] = 8'd127; assign sine_values[1] = 8'd129; assign sine_values[2] = 8'd130;
    assign sine_values[3] = 8'd132; assign sine_values[4] = 8'd133; assign sine_values[5] = 8'd135;
    assign sine_values[6] = 8'd136; assign sine_values[7] = 8'd138; assign sine_values[8] = 8'd139;
    assign sine_values[9] = 8'd141; assign sine_values[10] = 8'd143; assign sine_values[11] = 8'd144;
    assign sine_values[12] = 8'd146; assign sine_values[13] = 8'd147; assign sine_values[14] = 8'd149;
    assign sine_values[15] = 8'd150; assign sine_values[16] = 8'd152; assign sine_values[17] = 8'd153;
    assign sine_values[18] = 8'd155; assign sine_values[19] = 8'd156; assign sine_values[20] = 8'd158;
    assign sine_values[21] = 8'd159; assign sine_values[22] = 8'd161; assign sine_values[23] = 8'd162;
    assign sine_values[24] = 8'd164; assign sine_values[25] = 8'd165; assign sine_values[26] = 8'd167;
    assign sine_values[27] = 8'd168; assign sine_values[28] = 8'd170; assign sine_values[29] = 8'd171;
    assign sine_values[30] = 8'd173; assign sine_values[31] = 8'd174; assign sine_values[32] = 8'd176;
    assign sine_values[33] = 8'd177; assign sine_values[34] = 8'd178; assign sine_values[35] = 8'd180;
    assign sine_values[36] = 8'd181; assign sine_values[37] = 8'd183; assign sine_values[38] = 8'd184;
    assign sine_values[39] = 8'd185; assign sine_values[40] = 8'd187; assign sine_values[41] = 8'd188;
    assign sine_values[42] = 8'd190; assign sine_values[43] = 8'd191; assign sine_values[44] = 8'd192;
    assign sine_values[45] = 8'd194; assign sine_values[46] = 8'd195; assign sine_values[47] = 8'd196;
    assign sine_values[48] = 8'd198; assign sine_values[49] = 8'd199; assign sine_values[50] = 8'd200;
    assign sine_values[51] = 8'd201; assign sine_values[52] = 8'd203; assign sine_values[53] = 8'd204;
    assign sine_values[54] = 8'd205; assign sine_values[55] = 8'd206; assign sine_values[56] = 8'd208;
    assign sine_values[57] = 8'd209; assign sine_values[58] = 8'd210; assign sine_values[59] = 8'd211;
    assign sine_values[60] = 8'd212; assign sine_values[61] = 8'd213; assign sine_values[62] = 8'd215;
    assign sine_values[63] = 8'd216; assign sine_values[64] = 8'd217; assign sine_values[65] = 8'd218;
    assign sine_values[66] = 8'd219; assign sine_values[67] = 8'd220; assign sine_values[68] = 8'd221;
    assign sine_values[69] = 8'd222; assign sine_values[70] = 8'd223; assign sine_values[71] = 8'd224;
    assign sine_values[72] = 8'd225; assign sine_values[73] = 8'd226; assign sine_values[74] = 8'd227;
    assign sine_values[75] = 8'd228; assign sine_values[76] = 8'd229; assign sine_values[77] = 8'd230;
    assign sine_values[78] = 8'd231; assign sine_values[79] = 8'd232; assign sine_values[80] = 8'd233;
    assign sine_values[81] = 8'd233; assign sine_values[82] = 8'd234; assign sine_values[83] = 8'd235;
    assign sine_values[84] = 8'd236; assign sine_values[85] = 8'd237; assign sine_values[86] = 8'd238;
    assign sine_values[87] = 8'd238; assign sine_values[88] = 8'd239; assign sine_values[89] = 8'd240;
    assign sine_values[90] = 8'd240; assign sine_values[91] = 8'd241; assign sine_values[92] = 8'd242;
    assign sine_values[93] = 8'd242; assign sine_values[94] = 8'd243; assign sine_values[95] = 8'd244;
    assign sine_values[96] = 8'd244; assign sine_values[97] = 8'd245; assign sine_values[98] = 8'd245;
    assign sine_values[99] = 8'd246; assign sine_values[100] = 8'd247; assign sine_values[101] = 8'd247;
    assign sine_values[102] = 8'd248; assign sine_values[103] = 8'd248; assign sine_values[104] = 8'd249;
    assign sine_values[105] = 8'd249; assign sine_values[106] = 8'd249; assign sine_values[107] = 8'd250;
    assign sine_values[108] = 8'd250; assign sine_values[109] = 8'd251; assign sine_values[110] = 8'd251;
    assign sine_values[111] = 8'd251; assign sine_values[112] = 8'd252; assign sine_values[113] = 8'd252;
    assign sine_values[114] = 8'd252; assign sine_values[115] = 8'd252; assign sine_values[116] = 8'd253;
    assign sine_values[117] = 8'd253; assign sine_values[118] = 8'd253; assign sine_values[119] = 8'd253;
    assign sine_values[120] = 8'd253; assign sine_values[121] = 8'd254; assign sine_values[122] = 8'd254;
    assign sine_values[123] = 8'd254; assign sine_values[124] = 8'd254; assign sine_values[125] = 8'd254;
    assign sine_values[126] = 8'd254; assign sine_values[127] = 8'd254;

    assign phase = phase_reg_out[31:23]; 

    // Calculate phase_index based on phase
    wire [6:0] phase_index; 
    assign phase_index = (phase < 9'd128) ? phase[6:0] : 
                         (phase < 9'd256) ? 7'd127 - phase[6:0] :   
                         (phase < 9'd384) ? phase[6:0]:   
                         7'd127 - phase[6:0];              

    //LUT indexing
    assign lut_out = (phase < 9'd128) ? sine_values[phase_index] :  // 0° to 90° (use values directly)
                     (phase < 9'd256) ? sine_values[phase_index] :   // 90° to 180° (inverted)
                     (phase < 9'd384) ? 8'd255 - sine_values[phase_index] :   // 180° to 270° (inverted)
                     8'd255 - sine_values[phase_index];                        // 270° to 360° (use values directly)

    // OOK logic
    assign dac = (ook_data == 1'b1) ? lut_out : 8'd128;

endmodule
