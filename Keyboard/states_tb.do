restart -f -nowave
config wave -signalnamewidth 1

add wave -divider Basics
add wave clk
add wave reset
add wave sclk

add wave -divider Others
add wave row
add wave col
add wave -radix decimal state
add wave AN

run 10000ns