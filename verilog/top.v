/*
 * Module Name: top.
 *
 * Description: Verilog "main" module.
 *
 * Inputs:
 *    clk - Main clock signal from oscillator (AF14)
 *    rst - Reset signal from button key0 (AA14)
 *    ss - Chip select signal from SPI (Y18)
 *    mosi - Master out slave in signal from SPI (Y17)
 *    sck - Communication clock signal from SPI (AD17)
 *
 * Outputs:
 *    miso - Master in slave out signal to SPI (AC18)
 *    hex0 - 7-segment display 0 (AE26, AE27, AE28, AG27, AF28, AG28, AH28)
 *    hex1 - 7-segment display 1 (AJ29, AH29, AH30, AG30, AF29, AF30, AD27)
 *    led0 - LED 0 (V16)
 *    led1 - LED 1 (W16)
 *    led2 - LED 2 (V17)
 *    led3 - LED 3 (V18)
 *    led4 - LED 4 (W17)
 *    led5 - LED 5 (W19)
 *    led6 - LED 6 (Y19)
 *    led7 - LED 7 (W20)
 *    led8 - LED 8 (W21)
 *
 * Functionality:
 *    Connect the modules to each other.
 *    Define the inputs and outputs of the sistem.
 */

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

	wire [2:0] state;

	// SPI wires
	wire spi_cycle_done;
	wire [7:0] data_to_send;
	wire [7:0] data_received;
	
	// BRAM wires
	wire com_we;
	wire pdi_we;
	wire [1:0] bram_channel;
	wire [7:0] bram_data_in;
	wire [7:0] bram_data_out;
	wire [16:0] com_addr;
	wire [16:0] pdi_addr_read;
	wire [16:0] pdi_addr_write;

	// Image processing wires
	wire pdi_active;
	wire pdi_done;
	wire [7:0] red_data_in;
	wire [7:0] green_data_in;
	wire [7:0] blue_data_in;
	wire [7:0] red_data_out;
	wire [7:0] green_data_out;
	wire [7:0] blue_data_out;
	wire [16:0] hand_area;
	wire [16:0] hand_perimeter;
	wire [34:0] max_distance;
	wire [9:0] peaks;
	wire [3:0] classification;
	
	// LEDs assignments
	assign led0 = state[0];
	assign led1 = state[1];
	assign led2 = state[2];
	assign led3 = pdi_addr_write[0];
	assign led4 = pdi_addr_write[1];
	assign led5 = pdi_addr_write[2];
	assign led6 = miso;
	assign led7 = mosi;
	assign led8 = ss;
	
	// 7-segments modules
	segment7 segment_seven_0 (
		.bcd(4'b0000),
		.seg(hex0)
	);
	
	segment7 segment_seven_1 (
		.bcd(4'b0000),
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
		.hand_area(hand_area),
		.hand_perimeter(hand_perimeter),
		.max_distance(max_distance),
		.peaks(peaks),
		.classification(classification)
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
		.pdi_done(pdi_done),
		.hand_area(hand_area),
		.hand_perimeter(hand_perimeter),
		.state(state),
		.max_distance(max_distance),
		.peaks(peaks),
		.classification(classification)
	);
	
	spi_slave_2 spi(
		.i_Rst_L(rst),
		.i_Clk(clk),
		.o_RX_DV(spi_cycle_done),
		.o_RX_Byte(data_received),
		.i_TX_DV(1'b1),
		.i_TX_Byte(data_to_send),
		.i_SPI_Clk(sck),
		.o_SPI_MISO(miso),
		.i_SPI_MOSI(mosi),
		.i_SPI_CS_n(ss)
	);

endmodule
