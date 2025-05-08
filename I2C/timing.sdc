# Đặt clock chính - giả sử 50MHz (20ns period)
create_clock -name clk -period 20.0 [get_ports clk]

# Ràng buộc input delay (giả sử delay bên ngoài là 2ns)
set_input_delay -max 2.0 -clock clk [get_ports start]
set_input_delay -min 0.5 -clock clk [get_ports start]
set_input_delay -max 2.0 -clock clk [get_ports Data[*]]
set_input_delay -min 0.5 -clock clk [get_ports Data[*]]

# Ràng buộc output delay (giả sử delay bên ngoài là 2ns)
set_output_delay -max 2.0 -clock clk [get_ports received_data[*]]
set_output_delay -min 0.5 -clock clk [get_ports received_data[*]]

# Ràng buộc reset async
set_false_path -from [get_ports rst]

# Tùy chọn: bỏ qua các path liên quan đến SDA/SCL vì I2C là bidirectional open-drain và không đồng bộ với clk
set_false_path -from [get_ports SDA_M_S]
set_false_path -to   [get_ports SDA_S_M]
set_false_path -from [get_ports SCL_M_S]
set_false_path -to   [get_ports SCL_S_M]
