#!/bin/bash
iverilog -o simulate.vvp simple_calculator.v simple_calculator_tb.v
vvp simulate.vvp