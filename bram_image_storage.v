module bram_image_storage(
    input clk,
    input [16:0] addr_read,
    input [16:0] addr_write,
    input we,
    input [7:0] data_in,
    output reg [7:0] data_out
);

reg [7:0] bram[76799:0];

always @(negedge clk) begin
    if (we) begin
        bram[(addr_write <= 17'd76799) ? addr_write : 17'd76799] <= data_in;
    end
    data_out <= bram[(addr_read <= 17'd76799) ? addr_read : 17'd76799];
end

endmodule