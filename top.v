
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

	wire spi_cycle_done;
	wire [2:0] state;
	wire [7:0] data_to_send;
	wire [7:0] data_received;
	
	wire bram_we;
	wire [1:0] bram_channel;
	wire [1:0] aux;
	wire [7:0] bram_data_in;
	wire [7:0] bram_data_out;
	wire [16:0] bram_addr;
	
	assign led0 = mosi;
	assign led1 = miso;
	assign led2 = ss;
	assign led3 = sck;
	assign led4 = rst;
	assign led5 = data_received[5];
	assign led6 = data_received[6];
	assign led7 = bram_channel[0];
	assign led8 = bram_channel[1];
	
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
	bram_image_storage bram_image_red(
		.clk(clk),
		.addr(bram_addr),
		.channel(bram_channel),
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
		.bram_channel(bram_channel),
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
