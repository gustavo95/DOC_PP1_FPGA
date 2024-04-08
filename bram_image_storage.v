module bram_image_storage(
    input clk,
    input [18:0] addr,
    input [1:0] channel,
    input we,
    input [7:0] data_in,
    output reg [7:0] data_out
);

reg [7:0] bram_r[76799:0];
reg [7:0] bram_g[76799:0];
reg [7:0] bram_b[76799:0];

always @(posedge clk) begin
    case (channel)
        2'b01: begin
            // if (we) bram_r[addr] <= data_in;
            data_out <= bram_r[addr];
        end
        2'b10: begin
            // if (we) bram_g[addr] <= data_in;
            data_out <= bram_g[addr];
        end
        default: begin  // Considera-se o último caso como default para o canal B
            // if (we) bram_b[addr] <= data_in;
            data_out <= bram_b[addr];
        end
    endcase
end

endmodule