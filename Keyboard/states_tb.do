restart -f -nowave
config wave -signalnamewidth 1

add wave -divider Essentials
add wave clk
add wave reset
add wave sclk

add wave -divider Keypad
add wave row
add wave col
add wave -divider 7-seg
add wave AN
add wave -radix hexadecimal seg
add wave -divider TB
add wave -radix decimal state
add wave an_lit_tb
add wave seg_h_tens_tb
add wave seg_h_ones_tb
add wave seg_m_tens_tb
add wave seg_m_ones_tb

run 100000ns