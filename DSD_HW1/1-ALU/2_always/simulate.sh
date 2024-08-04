#!/bin/bash
iverilog -o simulation.vvp alu_always.v alu_always_tb.v
vvp simulation.vvp