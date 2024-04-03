
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

	wire [7:0] data_to_send;
	wire [7:0] data_received;
	wire spi_cycle_done;
	wire [2:0] state;
	
	assign led0 = spi_cycle_done;
	assign led1 = rst;
	assign led2 = mosi;
	assign led3 = miso;
	assign led4 = sck;
	assign led5 = state[0];
	assign led6 = state[1];
	assign led7 = state[2];
	assign led8 = 1'b0;
	
	// 7-segments modules
	segment7 segment_seven_0 (
		.bcd(data_received[3:0]),
		.seg(hex0)
	);
	
	segment7 segment_seven_1 (
		.bcd(data_received[7:4]),
		.seg(hex1)
	);
	
	
	// Communication modules
	data_transfer_controller dtc (
		.clk(clk),
		.rst(rst),
		.spi_cycle_done(spi_cycle_done),
		.spi_byte_in(data_received),
		.spi_byte_out(data_to_send),
		.state(state)
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
