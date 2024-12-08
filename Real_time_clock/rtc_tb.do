restart -f -nowave
config wave -signalnamewidth 1

add wave -divider "Essentials"
add wave clk
add wave sclk
add wave reset
add wave ce
add wave ce_internal

add wave -divider "Verification signals"
add wave -radix decimal state
add wave init_byte_ver
add wave -divider "Transmitted bits"
add wave data_trans
add wave data_in
add wave data_out



run 100000ns