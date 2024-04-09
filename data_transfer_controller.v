module data_transfer_controller (
	input clk,
	input rst,
	
	input spi_cycle_done,
	input [7:0] spi_byte_in,
	output reg [7:0] spi_byte_out,
	
	output reg [16:0] bram_addr,
	output reg [1:0] bram_channel,
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
			bram_addr <= {17{1'b1}};
			bram_channel <= 2'b00;
			bram_we <= 1'b0;
		end
		else if (spi_cycle_done) begin
			case (state)
				3'd0 : begin // Reives the command byte
							if (spi_byte_in[3:2] == 2'b01) begin
								state <= 3'd1;
								size_byte_count <= 3'd4;
								bram_channel <= spi_byte_in[1:0];
							end
							else if (spi_byte_in[3:2] == 2'b10) begin
								state <= 3'd3;
								bram_addr <= 17'b0;
								bram_channel <= spi_byte_in[1:0];
							end
							else begin
								state <= 3'd0;
								size_byte_count <= 3'd0;
								img_height <= 16'b0;
								img_width <= 16'b0;
								img_height_count <= 16'b0;
								img_width_count <= 16'b0;
								spi_byte_out <= 8'b0;
								bram_addr <= {17{1'b1}};
								bram_channel <= 2'b00;
								bram_we <= 1'b0;
							end
						end
				3'd1 : begin // Recives the size bytes
							if (size_byte_count == 3'd4) begin
								img_height[15:8] <= spi_byte_in;
							end
							else if (size_byte_count == 3'd3) begin
								img_height[7:0] <= spi_byte_in;
							end
							else if (size_byte_count == 3'd2) begin
								img_width[15:8] <= spi_byte_in;
							end
							else if (size_byte_count == 3'd1) begin
								img_width[7:0] <= spi_byte_in;
							end
							
							size_byte_count <= size_byte_count - 1'd1;
							if ((size_byte_count - 1'd1) == 3'd0) begin
								state <= 3'd2;
								img_height_count <= img_height;
								img_width_count[15:8] <= img_width[15:8];
								img_width_count[7:0] <= spi_byte_in;
							end
						end
				3'd2 : begin // Reiceves the image data bytes
							bram_data_in <= spi_byte_in;
							bram_addr <= bram_addr + 17'b1;
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
							bram_addr <= bram_addr + 17'b1;
							if ((bram_addr + 1) >= 17'd76800) begin
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
							bram_addr <= {17{1'b1}};
							bram_channel <= 2'b00;
							bram_we <= 1'b0;
						end
			endcase
		end
	end

endmodule
