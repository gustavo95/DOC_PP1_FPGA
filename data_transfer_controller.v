module data_transfer_controller (
	input clk,
	input rst,
	
	input spi_cycle_done,
	input      [7:0] spi_byte_in,
	output reg [7:0] spi_byte_out,
	
	output reg [14:0] bram_addr,
	output reg bram_we,
	output reg [7:0] bram_data_in,
	input [7:0] bram_data_out,
	
	output reg [2:0] state
);

//	reg [2:0]  state;
	reg [2:0]  size_byte_count;
	reg [15:0] img_height; // or data_size
	reg [15:0] img_width;
	reg [15:0] img_height_count;
	reg [15:0] img_width_count;

	always @ (posedge spi_cycle_done or negedge rst) begin
		if (!rst) begin
			state <= 3'd0;
			size_byte_count <= 3'd0;
			img_height <= 16'b0;
			img_width <= 16'b0;
			img_height_count <= 16'b0;
			img_width_count <= 16'b0;
			spi_byte_out <= 8'b0;
			bram_addr <= 15'b0 - 1;
			bram_we <= 1'b0;
		end
		else if (spi_cycle_done) begin
			case (state)
				3'd0 : begin // Reives the command byte
							img_height <= 16'b0;
							img_width <= 16'b0;
							img_height_count <= 16'b0;
							img_width_count <= 16'b0;
							spi_byte_out <= 8'b0;
							bram_addr <= 15'b0 - 1;
							bram_we <= 1'b0;
							if (spi_byte_in == 8'b00000001) begin
								state <= 3'd1;
								size_byte_count <= 3'd4;
							end
							else if (spi_byte_in == 8'b00000010) begin
								state <= 3'd3;
								bram_addr <= 15'b0;
							end
							else begin
								size_byte_count <= 3'd0;
							end
						end
				3'd1 : begin // Recives the size bytes
							if ((size_byte_count) >= 3'd3) begin
								img_height <= (img_height << 8) | spi_byte_in;
							end
							else begin
								img_width <= (img_width << 8) | spi_byte_in;
							end
							size_byte_count <= size_byte_count - 1'd1;
							if ((size_byte_count - 1'd1) == 3'd0) begin
								state <= 3'd2;
								img_height_count <= img_height;
								img_width_count <= (img_width << 8) | spi_byte_in;
							end
						end
				3'd2 : begin // Reiceves the image data bytes
							bram_data_in <= spi_byte_in;
							bram_addr <= bram_addr + 1;
							bram_we <= 1'b1;
							
							img_width_count <= img_width_count - 1'b1;
							if ((img_width_count - 1'b1) == 16'b0) begin
								img_height_count <= img_height_count - 1'b1;
								img_width_count <= img_width;
								if ((img_height_count - 1'b1) == 16'b0) begin
									state <= 3'd0;
								end
							end
						end
				3'd3 : begin // Send bram data
							spi_byte_out <= bram_data_out;
							bram_addr <= bram_addr + 1;
							if ((bram_addr + 1) >= 15'd19200) begin
								state <= 3'd0;
							end
						end
				default : begin
							state <= 3'd0;
							size_byte_count <= 3'd0;
							img_height <= 16'b0;
							img_width <= 16'b0;
							img_height_count <= 16'b0;
							img_width_count <= 16'b0;
							spi_byte_out <= 8'b0;
							bram_addr <= 15'b0 - 1;
							bram_we <= 1'b0;
						end
			endcase
		end
	end

endmodule
