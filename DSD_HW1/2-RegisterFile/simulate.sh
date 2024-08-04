#!/bin/bash
iverilog -o simulation.vvp register_file.v register_file_tb.v
vvp simulation.vvp