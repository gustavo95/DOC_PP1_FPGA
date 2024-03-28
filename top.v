
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
	output done,
	output reg led1,
	output reg led2,
	output reg led3,
	output reg led4,
	output reg led5,
	output reg led6,
	output reg led7,
	output reg led8
);

	reg [3:0] hex1_data;
	reg [3:0] hex2_data;
	reg [3:0] aux1;
	reg [3:0] aux2;
	reg [7:0] data_to_send;
	
	wire [7:0] data_received;
	wire outsck;
	
	always @ (clk) begin
		led2 <= mosi;
		led3 <= miso;
		led4 <= sck;
		led5 <= data_to_send[0];
		led6 <= data_to_send[1];
		led7 <= data_to_send[2];
		led8 <= data_to_send[3];
	end
	
	always @ (rst or done) begin
		led1 = rst;
		if (rst == 1'b0) begin
			hex1_data <= 4'b0000;
			hex2_data <= 4'b0000;
			data_to_send <= 8'b0;
		end
		else begin
			if (done) begin
				hex1_data <= data_received[3:0];
				hex2_data <= data_received[7:4];
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
		.done(done),
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
