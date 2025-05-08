module I2C_Wrapper (
    input start,
    input [7:0] Data,
    input clk, rst,
    output [7:0] received_data // Dữ liệu nhận từ slave khi thực hiện thao tác đọc
);   
    // Tín hiệu giữa Master và Slave
    wire SDA_M_S; // Tín hiệu SDA từ Master đến Slave
    wire SDA_S_M; // Tín hiệu SDA từ Slave đến Master
    wire SCL_M_S; // Tín hiệu SCL từ Master đến Slave
    wire SCL_S_M; // Tín hiệu SCL từ Slave đến Master

    // Khởi tạo I2C Master
    I2C_Master Master(
        .start(start),
        .Data(Data),
        .clk(clk),
        .rst(rst),
        .SCL_I(SCL_S_M),    // SCL từ Slave đến Master
        .SDA_I(SDA_S_M),    // SDA từ Slave đến Master
        .SCL_O(SCL_M_S),    // SCL từ Master đến Slave
        .SDA_O(SDA_M_S),    // SDA từ Master đến Slave
        .received_data(received_data)
    );

    // Khởi tạo Memory Slave
    Memory_Slave m_slave(
        .rst(rst),
        .SCL_I(SCL_M_S),    // SCL từ Master đến Slave
        .SDA_I(SDA_M_S),    // SDA từ Master đến Slave
        .SCL_O(SCL_S_M),    // SCL từ Slave đến Master
        .SDA_O(SDA_S_M)     // SDA từ Slave đến Master
    );

endmodule
