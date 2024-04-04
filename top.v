
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
	wire [14:0] bram_addr;
	wire bram_we;
	wire [7:0] bram_data_in;
	wire [7:0] bram_data_out;
	
	assign led0 = bram_addr[0];
	assign led1 = bram_addr[1];
	assign led2 = bram_addr[2];
	assign led3 = bram_addr[3];
	assign led4 = bram_addr[4];
	assign led5 = bram_addr[5];
	assign led6 = bram_addr[6];
	assign led7 = bram_addr[7];
	assign led8 = bram_addr[8];
	
	// 7-segments modules
	segment7 segment_seven_0 (
		.bcd(data_received[3:0]),
		.seg(hex0)
	);
	
	segment7 segment_seven_1 (
		.bcd(data_received[7:4]),
		.seg(hex1)
	);
	
	// Storage modules
	bram_image_storage bram_image(
		.clk(clk),
		.addr(bram_addr),
		.we(bram_we),
		.data_in(bram_data_in),
		.data_out(bram_data_out)
);
	
	// Communication modules
	data_transfer_controller dtc (
		.clk(clk),
		.rst(rst),
		.spi_cycle_done(spi_cycle_done),
		.spi_byte_in(data_received),
		.spi_byte_out(data_to_send),
		.bram_addr(bram_addr),
		.bram_we(bram_we),
		.bram_data_in(bram_data_in),
		.bram_data_out(bram_data_out),
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
