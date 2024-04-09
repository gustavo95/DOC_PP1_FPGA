module bram_controller(
    input clk,
    input [16:0] addr,
    input [1:0] channel,
    input we,
    input [7:0] data_in,
    output reg [7:0] data_out
);

    reg red_we;
    reg green_we;
    reg blue_we;
    wire [7:0] red_data_out;
    wire [7:0] green_data_out;
    wire [7:0] blue_data_out;

    always @ (*) begin
        case (channel)
            2'b10 : begin
                red_we <= 1'b0;
                green_we <= we;
                blue_we <= 1'b0;
                data_out <= green_data_out;
            end
            2'b11 : begin
                red_we <= 1'b0;
                green_we <= 1'b0;
                blue_we <= we;
                data_out <= blue_data_out;
            end
            default : begin
                red_we <= we;
                green_we <= 1'b0;
                blue_we <= 1'b0;
                data_out <= red_data_out;
            end
        endcase
    end

	bram_image_storage bram_image_red(
		.clk(clk),
		.addr(addr),
		.we(red_we),
		.data_in(data_in),
		.data_out(red_data_out)
	);

    bram_image_storage bram_image_green(
        .clk(clk),
        .addr(addr),
        .we(green_we),
        .data_in(data_in),
        .data_out(green_data_out)
    );

    bram_image_storage bram_image_blue(
        .clk(clk),
        .addr(addr),
        .we(blue_we),
        .data_in(data_in),
        .data_out(blue_data_out)
    );

endmodule