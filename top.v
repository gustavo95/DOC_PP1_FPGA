
module top (
	//Control
	input clk,
	input rst,
	
	//SPI
	input ss,
	input mosi,
	output miso,
	input sck,
	
	//7segments
	output [6:0] hex0,
	output [6:0] hex1,
	
	//led
	output led0,
	output led1,
	output led2,
	output led3,
	output led4,
	output led5,
	output led6,
	output led7,
	output led8
);

	reg [7:0] data_to_send;
	
	wire [7:0] data_received;
	wire spi_cycle_done;
	
	assign led0 = spi_cycle_done;
	assign led1 = rst;
	assign led2 = mosi;
	assign led3 = miso;
	assign led4 = sck;
	assign led5 = data_to_send[0];
	assign led6 = data_to_send[1];
	assign led7 = data_to_send[2];
	assign led8 = data_to_send[3];
	
	always @ (rst or spi_cycle_done) begin
		if (rst == 1'b0) begin
			data_to_send <= 8'b0;
		end
		else begin
			if (spi_cycle_done) begin
				data_to_send <= ~data_received;
			end
		end
	end
	
	segment7 segment_seven_0 (
		.bcd(data_received[3:0]),
		.seg(hex0)
	);
	
	segment7 segment_seven_1 (
		.bcd(data_received[7:4]),
		.seg(hex1)
	);
	
	spi_slave spi(
		.clk(clk),
		.rst(rst),
		.ss(ss),
		.mosi(mosi),
		.miso(miso),
		.sck(sck),
		.done(spi_cycle_done),
		.din(data_to_send),
		.dout(data_received)
	);

//	test_spi spi(
//		.clk(clk),
//		.rst(rst),
//		.ss(ss),
//		.mosi(mosi),
//		.miso(miso),
//		.sck(sck),
//		.done(done),
//		.din(data_to_send),
//		.dout(data_received),
//		.count(count)
//	);

endmodule
