#!/bin/bash
iverilog -o simulation.vvp alu_assign.v alu_assign_tb2.v
vvp simulation.vvp