restart -f -nowave
config wave -signalnamewidth 1

add wave led_sec
add wave led_min
add wave led_h
add wave num_ctrl

run 10000ns