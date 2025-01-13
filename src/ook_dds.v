module DaDDS(
    input wire clk,
    input wire rst,
    input wire rx,
    input wire rf_data,
    input wire freq_sel,
    output wire [7:0] dac
);
    wire [15:0] adder_out;
    wire [15:0] freq0_reg_out;
    wire [15:0] freq1_reg_out;
    wire [15:0] sig_freq_reg_out;
    wire [15:0] phase_reg_out;

    uart_rx uart (
        .clk(clk),                  
        .rx(rx),                   
        .rst(rst),                 
        .done(), 
        .freq_sel(freq_sel),              
        .freq0(freq0_reg_out),
        .freq1(freq1_reg_out)                  
    );

    // Frequency switching for FSK
    assign sig_freq_reg_out = (rf_data == 0) ? freq0_reg_out : freq1_reg_out;

    sum16 adder (
        .a(sig_freq_reg_out),
        .b(phase_reg_out),
        .sum(adder_out)
    );

    reg16 phase_reg (
        .clk(clk),
        .en(1'b1),
        .rst(rst),
        .d(adder_out),
        .q(phase_reg_out)
    );

    wire [7:0] phase;
    wire [7:0] lut_out;   
    wire [7:0] sine [63:0];

    assign sine[0] = 8'h7F; assign sine[1] = 8'h82; assign sine[2] = 8'h85;
    assign sine[3] = 8'h88; assign sine[4] = 8'h8B; assign sine[5] = 8'h8F;
    assign sine[6] = 8'h92; assign sine[7] = 8'h95; assign sine[8] = 8'h98;
    assign sine[9] = 8'h9B; assign sine[10] = 8'h9E; assign sine[11] = 8'hA1;
    assign sine[12] = 8'hA4; assign sine[13] = 8'hA7; assign sine[14] = 8'hAA;
    assign sine[15] = 8'hAD; assign sine[16] = 8'hB0; assign sine[17] = 8'hB2;
    assign sine[18] = 8'hB5; assign sine[19] = 8'hB8; assign sine[20] = 8'hBB;
    assign sine[21] = 8'hBE; assign sine[22] = 8'hC0; assign sine[23] = 8'hC3;
    assign sine[24] = 8'hC6; assign sine[25] = 8'hC8; assign sine[26] = 8'hCB;
    assign sine[27] = 8'hCD; assign sine[28] = 8'hD0; assign sine[29] = 8'hD2;
    assign sine[30] = 8'hD4; assign sine[31] = 8'hD7; assign sine[32] = 8'hD9;
    assign sine[33] = 8'hDB; assign sine[34] = 8'hDD; assign sine[35] = 8'hDF;
    assign sine[36] = 8'hE1; assign sine[37] = 8'hE3; assign sine[38] = 8'hE5;
    assign sine[39] = 8'hE7; assign sine[40] = 8'hE9; assign sine[41] = 8'hEA;
    assign sine[42] = 8'hEC; assign sine[43] = 8'hEE; assign sine[44] = 8'hEF;
    assign sine[45] = 8'hF0; assign sine[46] = 8'hF2; assign sine[47] = 8'hF3;
    assign sine[48] = 8'hF4; assign sine[49] = 8'hF5; assign sine[50] = 8'hF7;
    assign sine[51] = 8'hF8; assign sine[52] = 8'hF9; assign sine[53] = 8'hF9;
    assign sine[54] = 8'hFA; assign sine[55] = 8'hFB; assign sine[56] = 8'hFC;
    assign sine[57] = 8'hFC; assign sine[58] = 8'hFD; assign sine[59] = 8'hFD;
    assign sine[60] = 8'hFD; assign sine[61] = 8'hFE; assign sine[62] = 8'hFE;
    assign sine[63] = 8'hFE;

    assign phase = phase_reg_out[15:8]; 

    wire [5:0] phase_index; 
    assign phase_index = (phase < 8'd64) ? phase[5:0] :
                         (phase < 8'd128) ? 6'd63 - phase[5:0] :  
                         (phase < 8'd192) ? phase[5:0]:   
                         6'd63 - phase[5:0];  

    assign lut_out = (phase < 8'd64) ? sine[phase_index] : 
                     (phase < 8'd128) ? sine[phase_index] :  
                     (phase < 8'd192) ? 8'd255 - sine[phase_index] : 
                     8'd255 - sine[phase_index];  

    //if the second register wasn't programmed, switch to OOK.
    assign dac = ((freq1_reg_out == 0) && (rf_data == 0)) ? 8'd128 : lut_out; 

endmodule
