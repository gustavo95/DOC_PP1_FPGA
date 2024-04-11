
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
	wire [7:0] data_to_send;
	wire [7:0] data_received;
	
	wire com_we;
	wire pdi_we;
	wire [1:0] bram_channel;
	wire [7:0] bram_data_in;
	wire [7:0] bram_data_out;
	wire [16:0] com_addr;
	wire [16:0] pdi_addr_read;
	wire [16:0] pdi_addr_write;

	wire pdi_active;
	wire pdi_done;
	wire [7:0] mean;
	wire [7:0] red_data_in;
	wire [7:0] green_data_in;
	wire [7:0] blue_data_in;
	wire [7:0] red_data_out;
	wire [7:0] green_data_out;
	wire [7:0] blue_data_out;
	
	assign led0 = pdi_addr_read[0];
	assign led1 = pdi_addr_read[1];
	assign led2 = pdi_addr_read[2];
	assign led3 = pdi_addr_write[0];
	assign led4 = pdi_addr_write[1];
	assign led5 = pdi_addr_write[2];
	assign led6 = data_received[6];
	assign led7 = bram_channel[0];
	assign led8 = pdi_done;
	
	// 7-segments modules
	segment7 segment_seven_0 (
		.bcd(mean[3:0]),
		.seg(hex0)
	);
	
	segment7 segment_seven_1 (
		.bcd(mean[7:4]),
		.seg(hex1)
	);

	// Image processing modules
	img_processing img_proc (
		.clk(clk),
		.rst(rst),
		.active(pdi_active),
		.done(pdi_done),
		.red_data_in(red_data_out),
		.green_data_in(green_data_out),
		.blue_data_in(blue_data_out),
		.red_data_out(red_data_in),
		.green_data_out(green_data_in),
		.blue_data_out(blue_data_in),
		.we(pdi_we),
		.addr_read(pdi_addr_read),
		.addr_write(pdi_addr_write),
		.mean(mean)
	);
	
	// Storage modules
	bram_controller bram_ctrl (
		.clk(clk),
		.com_addr(com_addr),
		.pdi_addr_read(pdi_addr_read),
		.pdi_addr_write(pdi_addr_write),
		.channel(bram_channel),
		.com_we(com_we),
		.pdi_we(pdi_we),
		.pdi_active(pdi_active),
		.data_in(bram_data_in),
		.data_out(bram_data_out),
		.red_data_in(red_data_in),
		.green_data_in(green_data_in),
		.blue_data_in(blue_data_in),
		.red_data_out(red_data_out),
		.green_data_out(green_data_out),
		.blue_data_out(blue_data_out)
	);
	
	// Communication modules
	data_transfer_controller dtc (
		.clk(clk),
		.rst(rst),
		.spi_cycle_done(spi_cycle_done),
		.spi_byte_in(data_received),
		.spi_byte_out(data_to_send),
		.bram_addr(com_addr),
		.bram_channel(bram_channel),
		.bram_we(com_we),
		.bram_data_in(bram_data_in),
		.bram_data_out(bram_data_out),
		.pdi_active(pdi_active),
		.pdi_done(pdi_done)
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
