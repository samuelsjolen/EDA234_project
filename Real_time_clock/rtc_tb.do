restart -f -nowave
config wave -signalnamewidth 1

add wave -divider "Essentials"
add wave clk
add wave sclk
add wave reset
add wave ce
add wave ce_internal

add wave -divider "Flags"
add wave transmitted_ver
add wave recieved_ver

add wave -divider "Verification signals"
add wave -radix decimal state
add wave init_byte_ver
add wave -divider "Transmitted bits"
add wave data_trans
add wave data_to_tb
add wave data_from_tb

add wave -divider Recieved
add wave data_recieved_ver



run 100000ns