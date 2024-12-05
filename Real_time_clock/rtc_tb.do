restart -f -nowave
config wave -signalnamewidth 1

add wave -divider "Essentials"
add wave clk_tb
add wave SCLK_tb
add wave reset_tb
add wave CE_tb

add wave -divider "Transmitted bits"
add wave data_trans_tb
add wave recieved
add wave -divider "Initial byte, shifts"
add wave init_byte_ver



run 10000ns