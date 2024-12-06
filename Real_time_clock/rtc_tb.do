restart -f -nowave
config wave -signalnamewidth 1

add wave -divider "Essentials"
add wave clk
add wave sclk
add wave reset
add wave CE

add wave -divider "Initial byte, shifts"
add wave init_byte_ver
add wave -divider "Transmitted bits"
add wave data_trans
add wave data_in
add wave data_out


run 10000000ns