/*
 * Module Name: img_processing.
 *
 * Description: Executes PDI.
 *
 * Inputs:
 *    clk - Main clock signal
 *    rst - Reset signal
 *    active - Signal that activates PDI execution
 *    red_data_in - Input byte data for red channel
 *    green_data_in - Input byte data for green channel
 *    blue_data_in - Input byte data for blue channel
 *
 * Outputs:
 *    done - Signal that indicates when a PDI cycle is done
 *    red_data_out - Output byte data for red channel
 *    green_data_out - Output byte data for green channel
 *    blue_data_out - Output byte data for blue channel
 *    we - BRAM write enable signal
 *    addr_read - Address for reading memory
 *    addr_write - Address for writing memory
 *    mean - Debug signal
 *
 * Functionality:
 *    State machine that processes PDI.
 *    States:
 *      - 000: Initializes values and waits for active signal
 *      - 001: Accumulates the data for the mean calculation
 *      - 010: Calculates the mean for each channel
 *      - 011: Calculates the max mean and prepares the data for the next state
 *      - 100: Executes the ilumination compesation
 */

module img_processing(
    input clk,
    input rst,
    input active,
    output reg done,

    input [7:0] red_data_in,
    input [7:0] green_data_in,
    input [7:0] blue_data_in,
    output reg [7:0] red_data_out,
    output reg [7:0] green_data_out,
    output reg [7:0] blue_data_out,

    output reg we,
    output reg [16:0] addr_read,
    output reg [16:0] addr_write,
    output reg [7:0] mean
);

    reg [2:0] state;

    reg [24:0] red_acumulator;
    reg [24:0] green_acumulator;
    reg [24:0] blue_acumulator;

    reg [7:0] red_mean;
    reg [7:0] green_mean;
    reg [7:0] blue_mean;
    reg [7:0] max_mean;

    reg [15:0] temp_red;
    reg [15:0] temp_green;
    reg [15:0] temp_blue;

    task init_values;
        begin
            state <= 3'b000;
            done <= 1'b0;
            we <= 1'b0;
            addr_read <= 17'b0;
            addr_write <= {17{1'b1}};
            mean <= 8'b0;
            red_acumulator <= 25'b0;
            green_acumulator <= 25'b0;
            blue_acumulator <= 25'b0;
            red_data_out <= 8'b0;
            green_data_out <= 8'b0;
            blue_data_out <= 8'b0;
            temp_blue <= 16'b0;
            temp_green <= 16'b0;
            temp_red <= 16'b0;
        end
    endtask

    always @ (posedge clk) begin
        if (!rst) begin
            init_values;
        end
        else begin
            case (state)
                3'b000: begin
                    if (active && !done) begin
                        state <= 3'b001;
                    end
                    else if (done) begin
                        if (!active) begin
                            done <= 1'b0; // Reset done signal when active signal is low
                        end
                    end
                    else begin
                        init_values;
                    end
                end
                3'b001: begin // Accumulate data for the mean calculation
                    addr_read <= addr_read + 1'b1;
                    red_acumulator <= red_acumulator + red_data_in;
                    green_acumulator <= green_acumulator + green_data_in;
                    blue_acumulator <= blue_acumulator + blue_data_in;
                    red_mean <= red_acumulator[7:0];
                    if (addr_read >= 17'd76799) begin
                        state <= 3'b010;
                    end
                end
                3'b010: begin // Calculate the mean for each channel
                    red_mean <= (red_acumulator/17'd76800);
                    green_mean <= (green_acumulator/17'd76800);
                    blue_mean <= (blue_acumulator/17'd76800);

                    addr_read <= 17'd76799;
                    state <= 3'b011;
                end
                3'b011: begin // Calculate the max mean
                    if (red_mean > green_mean && red_mean > blue_mean) begin
                        max_mean <= red_mean;
                    end
                    else if (green_mean > red_mean && green_mean > blue_mean) begin
                        max_mean <= green_mean;
                    end
                    else begin
                        max_mean <= blue_mean;
                    end
                    
                    // pre-calculate the 76799 pixel value
                    temp_red <= red_data_in*red_mean;
                    temp_green <= green_data_in*green_mean;
                    temp_blue <= blue_data_in*blue_mean;

                    addr_read <= 17'd0;
                    addr_write <= {17{1'b1}};
                    state <= 3'b100;
                end
                3'b100: begin // Execute the ilumination compesation
                    we <= 1'b1;
                    addr_read <= addr_read + 1'b1;
                    addr_write <= addr_read - 1'b1;
                    
                    // Multiply current interation pixel by the channel mean
                    temp_red <= red_data_in*red_mean;
                    temp_green <= green_data_in*green_mean;
                    temp_blue <= blue_data_in*blue_mean;

                    // Divide previous interation result by the max mean
                    red_data_out <= temp_red/max_mean;
                    green_data_out <= temp_green/max_mean;
                    blue_data_out <= temp_blue/max_mean;

                    if (addr_read >= 17'd76799) begin
                        state <= 3'b101;
                        addr_read <= 17'd0;
                        addr_write <= 17'd0;
                    end
                end
                3'b101: begin // Convert RGb to YCbCr
                    we <= 1'b1;
                    addr_read <= addr_read + 1'b1;
                    addr_write <= addr_read;

                    // Y
                    // red_data_out <= 16 + ((
                    //         (red_data_in<<6) + (red_data_in<<1) +
                    //         (green_data_in<<7) + green_data_in +
                    //         (blue_data_in<<4) + (blue_data_in<<3) + blue_data_in
                    //     )>>8);

                    // Cb
                    green_data_out <= 128 + ((
                            -((red_data_in<<5) + (red_data_in<<2) + (red_data_in<<1)) -
                            ((green_data_in<<6) + (green_data_in<<3) + (green_data_in<<1)) +
                            (blue_data_in<<7) - (blue_data_in<<4)
                        )>>8);

                    // Cr
                    blue_data_out <= 128 + ((
                            (red_data_in<<7) - (red_data_in<<4) -
                            ((green_data_in<<6) + (green_data_in<<5) - (green_data_in<<1)) -
                            ((blue_data_in<<4) + (blue_data_in<<1))
                        )>>8);

                    if (addr_read >= 17'd76799) begin
                        state <= 3'b110;
                        addr_read <= 17'd0;
                        addr_write <= 17'd0;
                    end 
                end
                3'b110: begin
                    we <= 1'b1;
                    addr_read <= addr_read + 1'b1;
                    addr_write <= addr_read;

                    if (green_data_in > 95 && green_data_in < 120 && blue_data_in > 140 && blue_data_in < 170) begin
                        red_data_out <= 255;
                        green_data_out <= 255;
                        blue_data_out <= 255;
                    end
                    else begin
                        red_data_out <= 0;
                        green_data_out <= 0;
                        blue_data_out <= 0;
                    end

                    if (addr_read >= 17'd76799) begin
                        done <= 1'b1;
                        state <= 3'b000;
                    end 
                end
                default: begin
                    init_values;
                end
            endcase
        end
    end

endmodule