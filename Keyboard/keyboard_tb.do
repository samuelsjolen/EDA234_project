restart -f -nowave
config wave -signalnamewidth 1

add wave clk_tb
add wave row_tb
add wave col_tb
add wave -radix hexadecimal seg_tb




run 10000ns