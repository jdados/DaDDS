module sum32 (              
    input wire [31:0] a,          
    input wire [31:0] b,         
    output reg [31:0] sum      
);
    assign sum = a + b;
endmodule

module sum16 (              
    input wire [15:0] a,          
    input wire [15:0] b,         
    output wire [15:0] sum      
);
    assign sum = a + b;
endmodule