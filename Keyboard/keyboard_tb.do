restart -f -nowave
config wave -signalnamewidth 1

add wave clk
add wave row
add wave col
add wave -radix hexadecimal seg


run 1000ns