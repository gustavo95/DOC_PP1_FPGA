module data_transfer_controller (
	input clk,
	input rst,
	
	input spi_cycle_done,
	input      [7:0] spi_byte_in,
	output reg [7:0] spi_byte_out,
	
	output reg [2:0] state
);

//	reg [2:0]  state;
	reg [1:0]  size_byte_count;
	reg [23:0] data_byte_count;

	always @ (posedge spi_cycle_done or negedge rst) begin
		if (!rst) begin
			state <= 3'd0;
			size_byte_count <= 2'b0;
			data_byte_count <= 24'b0;
			spi_byte_out <= 8'b0;
		end
		else if (spi_cycle_done) begin
			case (state)
				3'd0 : begin
							data_byte_count <= 24'b0;
							spi_byte_out <= 8'b0;
							if (spi_byte_in == 8'b00000001) begin
								state <= 3'd1;
								size_byte_count <= 2'b11;
							end
							else begin
								size_byte_count <= 2'b0;
							end
						end
				3'd1 : begin
							data_byte_count <= (data_byte_count << 8) | spi_byte_in;
							size_byte_count <= size_byte_count - 1'b1;
							if ((size_byte_count - 1'b1) == 3'b000) begin
								state <= 3'd2;
							end
						end
				3'd2 : begin
							spi_byte_out <= spi_byte_in;
							data_byte_count <= data_byte_count - 1'b1;
							if ((data_byte_count - 1'b1) == 24'b0) begin
								state <= 3'd0;
							end
						end 
				default : begin
							state <= 3'd0;
							size_byte_count <= 2'b0;
							data_byte_count <= 24'b0;
							spi_byte_out <= 8'b0;
						end
			endcase
		end
	end

endmodule
