restart -f -nowave
config wave -signalnamewidth 1

add wave clk_sig
add wave key_sig
add wave -radix hexadecimal seg_sig 


run 1000ns