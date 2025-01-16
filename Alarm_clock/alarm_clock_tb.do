restart -f -nowave
config wave -signalnamewidth 1

add wave -divider "Clock"
add wave clk_tb

add wave -divider State
add wave -radix decimal state_tb

add wave -divider Keypad
add wave row_tb
add wave col_tb

add wave -divider Display
add wave -radix hexadecimal AN_tb
add wave seg_tb
add wave seg_output_tb

add wave -divider "Trigger Signals"
add wave -radix binary -color green keypad_ctrl_tb
add wave -radix binary -color green ic_ctrl_tb

add wave -divider "LED Clock"
add wave -radix unsigned -color yellow led_h_tb
add wave -radix unsigned -color yellow led_min_tb
add wave -radix unsigned -color yellow led_sec_tb 

add wave -divider "Alarm Signals"
add wave speaker_tb
add wave alarm_led_tb



run 100000ns