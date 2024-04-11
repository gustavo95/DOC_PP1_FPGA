module bram_controller(
    input clk,
    input [16:0] com_addr,
    input [16:0] pdi_addr_read,
    input [16:0] pdi_addr_write,
    input [1:0] channel,
    input com_we,
    input pdi_we,
    input pdi_active,
    input [7:0] data_in,
    output reg [7:0] data_out,
    input [7:0] red_data_in,
    input [7:0] green_data_in,
    input [7:0] blue_data_in,
    output [7:0] red_data_out,
    output [7:0] green_data_out,
    output [7:0] blue_data_out
);

    reg red_we;
    reg green_we;
    reg blue_we;
    reg [16:0] addr_read;
    reg [16:0] addr_write;

    // wire [7:0] red_data_out;
    // wire [7:0] green_data_out;
    // wire [7:0] blue_data_out;

    always @ (*) begin
		if (pdi_active) begin
			addr_read <= pdi_addr_read;
            addr_write <= pdi_addr_write;
		end
		else begin
			addr_read <= com_addr;
            addr_write <= com_addr;
		end
	end

    always @ (*) begin
        case (channel)
            2'b10 : begin  // green channel
                red_we <= 1'b0;
                green_we <= com_we;
                blue_we <= 1'b0;
                data_out <= green_data_out;
            end
            2'b11 : begin // blue channel
                red_we <= 1'b0;
                green_we <= 1'b0;
                blue_we <= com_we;
                data_out <= blue_data_out;
            end
            default : begin // red channel
                red_we <= com_we;
                green_we <= 1'b0;
                blue_we <= 1'b0;
                data_out <= red_data_out;
            end
        endcase
    end

	bram_image_storage bram_image_red(
		.clk(clk),
        .addr_read(addr_read),
		.addr_write(addr_write),
		.we(red_we | pdi_we),
		.data_in(data_in | red_data_in),
		.data_out(red_data_out)
	);

    bram_image_storage bram_image_green(
        .clk(clk),
        .addr_read(addr_read),
		.addr_write(addr_write),
        .we(green_we | pdi_we),
        .data_in(data_in | green_data_in),
        .data_out(green_data_out)
    );

    bram_image_storage bram_image_blue(
        .clk(clk),
        .addr_read(addr_read),
		.addr_write(addr_write),
        .we(blue_we | pdi_we),
        .data_in(data_in | blue_data_in),
        .data_out(blue_data_out)
    );

endmodule