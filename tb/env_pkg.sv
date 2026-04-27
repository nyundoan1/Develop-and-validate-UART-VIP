//=============================================================================
// Project       : UART VIP
//=============================================================================
// Filename      : env_pkg.sv
// Author        : Huy Nguyen
// Company       : NO
// Date          : 20-Dec-2021
//=============================================================================
// Description   : 
//
//
//
//=============================================================================
`ifndef GUARD_UART_ENV_PKG__SV
`define GUARD_UART_ENV_PKG__SV

package env_pkg;
  `include "uvm_macros.svh"
  import uvm_pkg::*;
  import uart_pkg::*;

  `include "uart_scoreboard.sv"
  `include "uart_environment.sv"
endpackage: env_pkg

`endif


