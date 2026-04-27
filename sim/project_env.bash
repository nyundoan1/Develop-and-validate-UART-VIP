#!/bin/bash -f

setup_dva

## UVM library path
export UVM_HOME=/usr/local/questasim/verilog_src/uvm-1.2

## Verify root path
export UART_VIP_VERIF_PATH=./..

export UART_VIP_ROOT=$UART_VIP_VERIF_PATH/uart_vip
