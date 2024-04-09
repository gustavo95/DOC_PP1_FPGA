module bram_image_storage(
    input clk,
    input [16:0] addr,
    input we,
    input [7:0] data_in,
    output reg [7:0] data_out
);

reg [7:0] bram[76799:0];

always @(posedge clk) begin
    if (we) begin
        bram[addr] <= data_in;
    end
    data_out <= bram[addr];
end

endmodule