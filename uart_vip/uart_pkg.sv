//=============================================================================
// Project       : UART VIP
//=============================================================================
// Filename      : uart_pkg.sv
// Author        : Huy Nguyen
// Company       : NO
// Date          : 20-Dec-2021
//=============================================================================
// Description   : 
//
//
//
//=============================================================================
`ifndef GUARD_UART_PKG__SV
`define GUARD_UART_PKG__SV
package uart_pkg;
  import uvm_pkg::*;

  `include "uart_define.sv"
  `include "uart_configuration.sv"
  `include "uart_transaction.sv"
  `include "uart_lhs_sequencer.sv"
  `include "uart_rhs_sequencer.sv"
  `include "uart_lhs_driver.sv"
  `include "uart_rhs_driver.sv"
  `include "uart_lhs_monitor.sv"
  `include "uart_rhs_monitor.sv"
  `include "uart_lhs_agent.sv"
  `include "uart_rhs_agent.sv"

endpackage: uart_pkg

`endif

