module uart_rx (
    input wire clk,
    input wire rx,
    input wire rst,
    output wire done,
    output wire [31:0] tx_sig_freq,
    output wire [1:0] byte_num,
    output wire [2:0] state
  );

  parameter idle = 3'b000;
  parameter start_bit = 3'b001;
  parameter data_bits = 3'b010;
  parameter stop_bit  = 3'b011;
  parameter complete  = 3'b100;

  reg rx_data_r_reg = 1'b1;
  reg rx_data_reg = 1'b1;

  reg [11:0] clk_count_reg = 0;
  reg [3:0] bit_index_reg = 0; 
  reg [31:0] tx_sig_freq_reg = 0;
  reg done_reg = 0;
  reg [2:0] state_reg = 0;
  reg [1:0] byte_number_reg = 0;

  integer clk_cycles_per_bit = 521; // Clock cycles per UART bit (115200 baud rate)

  always @(posedge clk) begin
    rx_data_r_reg <= rx;
    rx_data_reg <= rx_data_r_reg;
  end

  always @(posedge clk or posedge rst) begin
    if (rst) begin
      state_reg <= idle;
      clk_count_reg <= 0;
      bit_index_reg <= 0;
      byte_number_reg <= 0;
      tx_sig_freq_reg <= 0;
      done_reg <= 0;

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
              state_reg <= data_bits;
            end else
              state_reg <= idle;
          end else
            clk_count_reg <= clk_count_reg + 1;
        end

        data_bits: begin
          if (clk_count_reg < clk_cycles_per_bit - 1) begin
            clk_count_reg <= clk_count_reg + 1;
          end else begin
            clk_count_reg <= 0;
            // Shift in received bit into the appropriate position
            tx_sig_freq_reg[((3-byte_number_reg) * 8) + (8 - bit_index_reg)] <= rx_data_reg;

            if (bit_index_reg < 8) begin
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
            if (byte_number_reg == 2'd3) begin
              done_reg <= 1'b1;
              state_reg <= complete;
            end else begin
              byte_number_reg <= byte_number_reg + 1;
              state_reg <= idle;
            end
          end
        end

        complete: begin
          byte_number_reg <= 0;
          state_reg <= idle;
          done_reg <= 1'b0;
        end

        default: state_reg <= idle;
      endcase
    end
  end

  assign done = done_reg;
  assign tx_sig_freq = tx_sig_freq_reg;
  assign byte_num = byte_number_reg;
  assign state = state_reg;

endmodule