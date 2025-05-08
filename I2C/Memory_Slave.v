module Memory_Slave #(
    parameter MEM_DEPTH = 256,
    parameter ADDR_SIZE = 8
)(
    input clk,      // clock for SRAM
    input rst,
    input vdd,
    input gnd,
    input SCL_I,
    input SDA_I,
    output reg SCL_O,
    output reg SDA_O
);
    // SRAM connections
    wire [7:0] sram_dout;
    reg  [7:0] sram_din;
    reg  [ADDR_SIZE-1:0] sram_addr;
    reg  sram_csb;
    reg  sram_web;

    // FSM logic
    reg [2:0] slave_counter;
    reg [2:0] cs, ns;
    reg ack_flag, correct, not_correct, done;
    reg [7:0] slave_address;
    reg [7:0] slave_data;

    // FSM states
    localparam IDLE     = 3'd0,
               CHK_ADDR = 3'd1,
               ACK_S    = 3'd2,
               NACK_S   = 3'd3,
               WAIT     = 3'd4,
               R        = 3'd5,
               W        = 3'd6,
               STOP     = 3'd7;

    // SRAM instance
    sram_8_256_sky130A SRAM (
        .vdd(vdd),
        .gnd(gnd),
        .clk0(clk),
        .csb0(sram_csb),
        .web0(sram_web),
        .addr0(sram_addr),
        .din0(sram_din),
        .dout0(sram_dout)
    );

    // State memory
    always @(negedge SCL_I or negedge rst) begin
        if (~rst)
            cs <= IDLE;
        else
            cs <= ns;
    end

    // Next state logic
    always @(*) begin
        case(cs)
            IDLE:        ns = (!SDA_I) ? CHK_ADDR : IDLE;
            CHK_ADDR:    ns = correct ? ACK_S : (not_correct ? NACK_S : CHK_ADDR);
            ACK_S:       ns = ack_flag ? STOP : WAIT;
            WAIT:        ns = slave_address[0] ? R : W;
            NACK_S:      ns = IDLE;
            R:           ns = done ? ACK_S : R;
            W:           ns = done ? ACK_S : W;
            STOP:        ns = IDLE;
            default:     ns = IDLE;
        endcase
    end

    // Output logic
    always @(negedge SCL_I) begin
        case(cs)
            IDLE: begin
                slave_address   = 0;
                slave_counter   = 7;
                correct         <= 0;
                not_correct     <= 0;
                ack_flag        <= 0;
                done            <= 0;
                SDA_O           <= 1;
                SCL_O           <= 0;
                sram_csb        <= 1; // disable SRAM
                sram_web        <= 1; // read mode (inactive)
            end
            CHK_ADDR: begin
                slave_address[slave_counter] <= SDA_I;
                if (slave_counter == 0) begin
                    if (slave_address[7:1] == 7'b0011111)
                        correct <= 1;
                    else
                        not_correct <= 1;
                end
                slave_counter <= slave_counter - 1;
            end
            ACK_S: begin
                slave_counter <= 7;
                ack_flag      <= 1;
                SDA_O         <= 0;
                correct       <= 0;
                not_correct   <= 0;

                if (slave_address[0]) begin // READ
                    sram_addr  <= slave_address[7:1];
                    sram_csb   <= 0;
                    sram_web   <= 1;
                    slave_data <= sram_dout; // latch read data
                end
            end
            WAIT: begin
                SDA_O <= 1;
                SCL_O <= 0;
            end
            NACK_S: begin
                SDA_O       <= 0;
                SCL_O       <= 1;
                correct     <= 0;
                not_correct <= 0;
            end
            R: begin
                SCL_O <= 0;
                SDA_O <= slave_data[slave_counter];
                if (slave_counter == 0)
                    done <= 1;
                else
                    slave_counter <= slave_counter - 1;
            end
            W: begin
                SDA_O <= 1;
                SCL_O <= 0;
                slave_data[slave_counter] <= SDA_I;
                if (slave_counter == 0)
                    done <= 1;
                else
                    slave_counter <= slave_counter - 1;
            end
            STOP: begin
                if (~slave_address[0]) begin // WRITE
                    sram_addr <= slave_address[7:1];
                    sram_din  <= slave_data;
                    sram_csb  <= 0;
                    sram_web  <= 0;
                end
                SDA_O <= 1;
                SCL_O <= 1;
            end
        endcase
    end
endmodule

