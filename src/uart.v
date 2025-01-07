module uart_rx (
    input wire clk,
    input wire rx,
    input wire rst,
    input wire freq_sel,
    input wire rf_data,
    output wire done,
    output wire [15:0] freq0,
    output wire [15:0] freq1
  );

  parameter idle = 3'b000;
  parameter start_bit = 3'b001;
  parameter byte_num_bit = 3'b010;
  parameter data_bits = 3'b011;
  parameter stop_bit  = 3'b100;
  parameter complete  = 3'b101;

  reg rx_data_reg = 1'b1;
  reg [11:0] clk_count_reg = 0;
  reg [3:0] bit_index_reg = 0; 
  reg byte_number = 0;
  reg done_reg = 0;
  reg [2:0] state_reg = 0;

  integer clk_cycles_per_bit = 521; // Clock cycles per UART bit (115200 baud rate)

  // Output registers
  reg [15:0] freq0_reg = 0;
  reg [15:0] freq1_reg = 0;

  always @(posedge clk) begin
    rx_data_reg <= rx;
  end

  always @(posedge clk or posedge rst) begin
    if (rst) begin
      state_reg <= idle;
      clk_count_reg <= 0;
      bit_index_reg <= 0;
      done_reg <= 0;
      byte_number <= 0;
    end else begin
      case (state_reg)
        idle: begin
          done_reg <= 1'b0;
          clk_count_reg <= 0;
          bit_index_reg <= 0;

          if (rx_data_reg == 1'b0)
            state_reg <= start_bit;
          else
            state_reg <= idle;
        end

        start_bit: begin
          if (clk_count_reg == (clk_cycles_per_bit - 1) / 2) begin
            if (rx_data_reg == 1'b0) begin
              clk_count_reg <= 0;
              bit_index_reg <= 0;
              state_reg <= byte_num_bit;
            end else
              state_reg <= idle;
          end else
            clk_count_reg <= clk_count_reg + 1;
        end

        byte_num_bit : begin
          if (clk_count_reg == (clk_cycles_per_bit - 1) / 2) begin
              clk_count_reg <= 0;
              byte_number <= rx_data_reg;
              state_reg <= data_bits;
          end else begin
              clk_count_reg <= clk_count_reg + 1;
          end
        end

        data_bits: begin
          if (clk_count_reg < clk_cycles_per_bit - 1) begin
              clk_count_reg <= clk_count_reg + 1;
          end else begin
              clk_count_reg <= 0;

              if (byte_number == 1'b1) begin
                  if (freq_sel == 1'b0) begin
                    freq0_reg[8 + bit_index_reg] <= rx_data_reg; 
                  end else begin
                    freq1_reg[8 + bit_index_reg] <= rx_data_reg; 
                  end
              end else begin
                  if (freq_sel == 1'b0) begin
                    freq0_reg[bit_index_reg] <= rx_data_reg; 
                  end else begin
                    freq1_reg[bit_index_reg] <= rx_data_reg; 
                  end
              end

              if (bit_index_reg < 7) begin
                  bit_index_reg <= bit_index_reg + 1;
              end else begin
                  bit_index_reg <= 0;
                  state_reg <= stop_bit;
              end
          end
        end

        stop_bit: begin
          if (clk_count_reg < clk_cycles_per_bit - 1) begin
            clk_count_reg <= clk_count_reg + 1;
          end else begin
            clk_count_reg <= 0;
            bit_index_reg <= 0;
            done_reg <= 1'b1;
            state_reg <= complete;
          end
        end

        complete: begin
          state_reg <= idle;
          done_reg <= 1'b0;
        end

        default: state_reg <= idle;
      endcase
    end
  end

  assign done = done_reg;
  assign freq0 = freq0_reg;
  assign freq1 = freq1_reg;
endmodule