/*
 * Module Name: data_transfer_contoller.
 *
 * Description: Controls SPI communication.
 *
 * Inputs:
 *    clk - Main clock signal
 *    rst - Reset signal
 *    spi_cycle_done - Signal that indicates when a SPI cycle is done for spi_slave (receiving or sending a byte)
 *    spi_byte_in - Input byte data from spi_slave
 *	  bram_data_out - Data obtained from BRAM
 *    pdi_done - Signal that indicates when PDI is done
 *
 * Outputs:
 *    spi_byte_out - Output byte data to spi_slave
 *    bram_addr - Address for reading and writing memory
 *    bram_channel - Channel to write data (01:R, 10:G, 11:B)
 *    bram_we - BRAM write enable signal
 *    bram_data_in - Data to be written in BRAM
 *    pdi_active - Signal that activates PDI execution
 *
 * Functionality:
 *    State machine that processes SPI communication data.
 *    States:
 *      - 0: Receives the command byte
 *      - 1: Receives the data image size bytes
 *      - 2: Receives the image data bytes for one channel and writes to BRAM
 *      - 3: Sends BRAM data for one channel
 *      - 4: Run and wait for PDI
 */

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

	output reg pdi_active,
	input pdi_done
);

	reg [2:0]  state;
	reg [2:0]  size_byte_count;
	reg [15:0] img_height; // or data_size
	reg [15:0] img_width;
	reg [15:0] img_height_count;
	reg [15:0] img_width_count;

	task init_values;
		begin
			state <= 3'd0;
			size_byte_count <= 3'd0;
			img_height <= 16'b0;
			img_width <= 16'b0;
			img_height_count <= 16'b0;
			img_width_count <= 16'b0;
			spi_byte_out <= 8'b0;
			bram_addr <= {17{1'b1}}; // Initial at the maximum value so that when the increment is made the value goes to 0
			bram_channel <= 2'b00;
			bram_we <= 1'b0;
			pdi_active <= 1'b0;
			bram_data_in <= 8'b0;
		end
	endtask

	always @ (posedge clk or negedge rst) begin
		if (!rst) begin
			init_values;
		end
		else if (spi_cycle_done) begin
			case (state)
				3'd0 : begin // Recives the command byte
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
							else if (spi_byte_in[3:2] == 2'b11) begin
								state <= 3'd4;
								pdi_active <= 1'b1;
							end
							else begin
								init_values;
							end
						end
				3'd1 : begin // Recives the data size bytes
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
							
							// Update image size counters
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
							if (bram_addr >= 17'd76799) begin
								state <= 3'd0;
							end
						end
				4'd4 : begin // Wait for PDI
							spi_byte_out <= 8'b00010000; //Indicates that PDI is running
						end
				default : begin
							init_values;
						end
			endcase
		end
		else if (pdi_done) begin
			// PDI is done
			pdi_active <= 1'b0;
			state <= 3'd0;
		end
	end

endmodule
