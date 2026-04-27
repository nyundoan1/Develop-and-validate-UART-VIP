//=============================================================================
// Project       : UART VIP
//=============================================================================
// Filename      : seq_pkg.sv
// Author        : Huy Nguyen
// Company       : NO
// Date          : 20-Dec-2021
//=============================================================================
// Description   : 
//
//
//
//=============================================================================
`ifndef GUARD_UART_SEQ_PKG__SV
`define GUARD_UART_SEQ_PKG__SV

package seq_pkg;
  import uvm_pkg::*;
  import uart_pkg::*;

     `include "half_baud_sequence.sv"
     `include "parity_sequence.sv"
     `include "parity_1_odd_sequence.sv"
     `include "parity_0_odd_sequence.sv"
     `include "parity_1_even_sequence.sv"
     `include "parity_0_even_sequence.sv"
endpackage: seq_pkg

`endif


