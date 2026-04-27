`uvm_analysis_imp_decl(_ltx)
`uvm_analysis_imp_decl(_lrx)
`uvm_analysis_imp_decl(_rtx)
`uvm_analysis_imp_decl(_rrx)
class uart_scoreboard extends uvm_scoreboard;
     `uvm_component_utils (uart_scoreboard)
     
     uvm_analysis_imp_ltx #(uart_transaction, uart_scoreboard) lhs_monitor_exp_tx;
     uvm_analysis_imp_lrx #(uart_transaction, uart_scoreboard) lhs_monitor_exp_rx;
     uvm_analysis_imp_rtx #(uart_transaction, uart_scoreboard) rhs_monitor_exp_tx;
     uvm_analysis_imp_rrx #(uart_transaction, uart_scoreboard) rhs_monitor_exp_rx;
     
     uart_transaction ltx_queue[$];
     uart_transaction lrx_queue[$];
     uart_transaction rtx_queue[$];
     uart_transaction rrx_queue[$];

     uart_configuration  lhs_config;
     uart_configuration  rhs_config;
     
     function new (string name = "uart_scoreboard", uvm_component parent);
          super.new (name, parent);
     endfunction:new

     virtual function void build_phase (uvm_phase phase);
          super.build_phase (phase);

          if (!uvm_config_db#(uart_configuration)::get(this, "", "lhs_config", lhs_config))
               `uvm_fatal(get_type_name(), $sformatf("Failed to get lhs_config from uvm_config_db"))

          if (!uvm_config_db#(uart_configuration)::get(this, "", "rhs_config", rhs_config))
               `uvm_fatal(get_type_name(), $sformatf("Failed to get rhs_config from uvm_config_db"))

          lhs_monitor_exp_tx = new("lhs_monitor_exp_tx", this);
          lhs_monitor_exp_rx = new("lhs_monitor_exp_rx", this);
          rhs_monitor_exp_tx = new("rhs_monitor_exp_tx", this);
          rhs_monitor_exp_rx = new("rhs_monitor_exp_rx", this);
          `uvm_info(get_type_name(), $sformatf("[Scoreboard] Build_phase done!"), UVM_LOW)
     endfunction:build_phase

     virtual task run_phase(uvm_phase phase);
     endtask: run_phase

     virtual function void write_ltx (uart_transaction trans);
          `uvm_info(get_type_name(), $sformatf("[Scoreboard] Transmit data = %0h", trans.data), UVM_LOW)
          ltx_queue.push_back(trans);
     endfunction: write_ltx
     
     virtual function void write_rrx (uart_transaction trans);
          uart_transaction tx_trans, rx_trans;
          `uvm_info("SCOREBOARD", $sformatf("Transmit data = %0h", trans.data), UVM_HIGH)
          rrx_queue.push_back(trans);
          //tx_trans = ltx_queue.pop_front();
          //rx_trans = rrx_queue.pop_front();
          //`uvm_info("SCOREBOARD", $sformatf("Received data = %0h", tx_trans.data), UVM_HIGH)
          // `uvm_info("SCOREBOARD", $sformatf("Transmit data = %0h", rx_trans.data), UVM_HIGH)
          if ((ltx_queue.size() > 0) && (rrx_queue.size() > 0)) begin
               tx_trans = ltx_queue.pop_front();
               rx_trans = rrx_queue.pop_front();
               compare_queue(tx_trans, rx_trans);
               `uvm_info("LHS Scoreboard", $sformatf("Transmit data = %0h. Received data = %0h", tx_trans.data, rx_trans.data), UVM_HIGH)
          end

     endfunction: write_rrx

     virtual function void write_rtx (uart_transaction trans);
          `uvm_info("Scoreboard", $sformatf("Transmit data = %0h", trans.data), UVM_HIGH)
          rtx_queue.push_back(trans);
     endfunction: write_rtx

     virtual function void write_lrx (uart_transaction trans);
          uart_transaction tx_trans, rx_trans;
          `uvm_info("SCOREBOARD", $sformatf("Transmit data = %0h", trans.data), UVM_HIGH)
          lrx_queue.push_back(trans);
          if ((rtx_queue.size() > 0) && (lrx_queue.size() > 0)) begin
               tx_trans = rtx_queue.pop_front();
               rx_trans = lrx_queue.pop_front();
               compare_queue(tx_trans, rx_trans);
               `uvm_info("RHS Scoreboard", $sformatf("Transmit data = %0h. Received data = %0h", tx_trans.data, rx_trans.data), UVM_HIGH)
          end
     endfunction: write_lrx

     function void compare_queue(uart_transaction tx_trans, rx_trans);
          int error = 0;
          bit parity_tx;
          bit parity_rx;
          int error_stop = 0;
          int error_data = 0;
          int length_data_rhs, length_data_lhs;

          length_data_lhs = lhs_config.data_width + lhs_config.num_of_stop_bit;
          length_data_rhs = rhs_config.data_width + rhs_config.num_of_stop_bit;
     
          //Check Parity
          if (rhs_config.parity_mode != uart_configuration::NONE) begin
               for (int i = (rhs_config.data_width + rhs_config.num_of_stop_bit); i > rhs_config.num_of_stop_bit; i = i - 1)
               begin
                    parity_rx = parity_rx ^ rx_trans.data[i];
                   // `uvm_info("Scoreboard", $sformatf("Data value: %b", rx_trans.data[i]), UVM_LOW)
               end
               //for (int i = 0; i <= (rhs_config.data_width + rhs_config.num_of_stop_bit); i = i + 1)
               //      `uvm_info("Scoreboard", $sformatf("Data value: %b. Index: %2d", rx_trans.data[i], i), UVM_LOW)
               if (parity_rx != rx_trans.data[length_data_rhs - rhs_config.data_width])
               begin
                    error += 1;
                    //`uvm_error("SCOREBOARD", $sformatf("FAILDED TEST. RECEIVED PARITY NOT CORRECT. Exp: %b. Act: %b, index: %2d", parity_rx, rx_trans.data[length_data_rhs - rhs_config.data_width], length_data_rhs - rhs_config.data_width))
               end
          end
          if (lhs_config.parity_mode != uart_configuration::NONE) begin
               for (int i = (lhs_config.data_width + lhs_config.num_of_stop_bit) ; i > lhs_config.num_of_stop_bit; i = i - 1)
                    parity_tx = parity_tx ^ tx_trans.data[i];
               if (parity_tx != tx_trans.data[length_data_lhs - lhs_config.data_width])
               begin
                    error += 1;
                    //`uvm_error("SCOREBOARD", $sformatf("FAILDED TEST. TRANSMIT PARITY NOT CORRECT. Exp: %b. Act: %b", parity_tx, tx_trans.data[length_data_lhs - lhs_config.data_width]))
               end
          end
          if (parity_rx != parity_tx)
          begin
               error += 1;
               //`uvm_error("SCOREBOARD", $sformatf("FAILDED TEST. PARITY NONE MATCHING"))
          end
          //Data value
          for (int i = 0; i < (lhs_config.data_width); i = i + 1)
               if (tx_trans.data[i] != rx_trans.data[i])
                    error_data +=1;
          if (error_data != 0)
               //`uvm_error("SCOREBOARD", $sformatf("FAILDED TEST. DATA NOT MATCHING. TRANSMIT DATA: %p. RECEIVED DATA: %p", tx_trans.data, rx_trans.data))
          //Stop bit
          if ((error != 0) && (error_data !=0) && (tx_trans.data != rx_trans.data))
          begin
                error_stop += 1;
               //`uvm_error("SCOREBOARD", $sformatf("FAILDED TEST. STOP BIT NOT CORRECT"))
          end
          if ((error == 0) && (error_data == 0) && (tx_trans.data == rx_trans.data) && (error_stop == 0))
               `uvm_info("SCOREBOARD", $sformatf("PASSED TEST"), UVM_HIGH)
          else
               `uvm_info("SCOREBOARD", $sformatf("FAILED TEST"), UVM_HIGH)
               //`uvm_info("SCOREBOARD", $sformatf("FAILED TEST. Error parity: %d. Error data: %d. Error stop bit: %d", error, error_data, error_stop), UVM_HIGH)
     endfunction: compare_queue
                              
endclass:uart_scoreboard
