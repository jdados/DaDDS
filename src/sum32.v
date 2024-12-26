module sum32 (
    input wire clk,               
    input wire rst,              
    input wire en,                
    input wire [31:0] a,          
    input wire [31:0] b,         
    output reg [31:0] sum      
);
    always @(posedge clk or posedge rst) begin
        if (rst)
            sum <= 32'b0;   
        else if (en)
            sum <= a + b;        
    end
endmodule
