start system_testbench
add wave system_testbench/*
add wave system_testbench/DUT/*
add wave system_testbench/DUT/audio_controller/*
add wave system_testbench/DUT/streamer/*
add wave system_testbench/DUT/piezo_controller/*
add wave system_testbench/DUT/pushbutton_edge_detector/*
run 1000ms
