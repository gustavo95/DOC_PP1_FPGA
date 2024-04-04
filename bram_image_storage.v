module bram_image_storage(
    input wire clk,
    input wire [14:0] addr,
	 input wire we,
    input wire [7:0] data_in,
    output reg [7:0] data_out
);

reg [7:0] bram[19199:0];

always @(posedge clk) begin
    if (we) begin
        bram[addr] <= data_in;
    end
    data_out <= bram[addr];
end

endmodule
