class uart_lhs_monitor extends uvm_monitor;
     `uvm_component_utils(uart_lhs_monitor)

     virtual uart_if lhs_if ;
     uart_configuration  lhs_config;

     uart_transaction trans_tx;
     uart_transaction trans_rx;
     uvm_analysis_port #(uart_transaction) lhs_monitor_tx;
     uvm_analysis_port #(uart_transaction) lhs_monitor_rx;

     function new (string name="uart_lhs_monitor", uvm_component parent);
          super.new(name,parent);
          //item_observed_port_tx = new("item_observed_port_tx", this);
          //item_observed_port_rx = new("item_observed_port_rx", this);
          lhs_monitor_tx = new("lhs_monitor_tx", this);
          lhs_monitor_rx = new("lhs_monitor_rx", this);

          trans_tx = new();
          trans_rx = new();
     endfunction: new

     virtual function void build_phase(uvm_phase phase);
          super.build_phase(phase);

          if (!uvm_config_db#(virtual uart_if)::get(this, "", "lhs_vif", lhs_if))
               `uvm_fatal(get_type_name(), $sformatf("Failed to get lhs_vif from uvm_config_db"))
          
          if (!uvm_config_db#(uart_configuration)::get(this, "", "lhs_config", lhs_config))
               `uvm_fatal(get_type_name(), $sformatf("Failed to get lhs_config from uvm_config_db"))

     endfunction: build_phase

     virtual task run_phase(uvm_phase phase);
          forever begin
               fork  
                    capture_tx();
                    capture_rx();
               join
          end
     endtask:run_phase

     task capture_tx();
          int baud_rate_tmp;
          int length;
          
          baud_rate_tmp = (10**9)/lhs_config.baud_rate;
          
          if (lhs_config.parity_mode != uart_configuration::NONE)
               length = lhs_config.data_width + lhs_config.num_of_stop_bit ;
          else
               length = lhs_config.data_width + lhs_config.num_of_stop_bit - 1;

          wait (lhs_if.tx == 0);
          #(baud_rate_tmp);
          //`uvm_info(get_type_name(), $sformatf("[Lhs_Monitor] Baud_rade_tmp: %d. Baud_rate configuration: %d", baud_rate_tmp, lhs_config.baud_rate ), UVM_LOW)
          `uvm_info(get_type_name(), $sformatf("[Lhs_Monitor] Capture data in TX"), UVM_LOW)
          
          for (int i = length; i >= 0; i = i - 1) begin
               trans_tx.data[i] = lhs_if.tx;
               #(baud_rate_tmp);
               //`uvm_info(get_type_name(), $sformatf("[Lhs_Monitor] Capture data in TX at index [%1d]: %p", i, trans_tx.data[i]), UVM_LOW)
          end

          `uvm_info(get_type_name(), $sformatf("[Lhs_Monitor] Capture data in TX: %b", trans_tx.data), UVM_LOW)
          lhs_monitor_tx.write(trans_tx);
    endtask
    task capture_rx();
          int baud_rate_tmp   ;
          int length          ;

          baud_rate_tmp = (10**9)/lhs_config.baud_rate;
          if (lhs_config.parity_mode != uart_configuration::NONE)
               length = lhs_config.data_width + lhs_config.num_of_stop_bit;
          else
               length = lhs_config.data_width + lhs_config.num_of_stop_bit - 1;

          @(negedge lhs_if.rx);
          #(baud_rate_tmp);
          //`uvm_info(get_type_name(), $sformatf("[Lhs_Monitor] Baud_rade_tmp: %d. Baud_rate configuration: %d", baud_rate_tmp, lhs_config.baud_rate ), UVM_LOW)
          `uvm_info(get_type_name(), $sformatf("[Lhs_Monitor] Capture data in RX"), UVM_LOW)
          for (int i = length ; i >= 0; i = i - 1) begin
               #(baud_rate_tmp);
               trans_rx.data[i] = lhs_if.rx;
               //`uvm_info(get_type_name(), $sformatf("[Lhs_Monitor] Capture data in RX at index [%1d]: %p", i, trans_rx.data[i]), UVM_LOW)
          end
          lhs_monitor_rx.write(trans_rx);
          `uvm_info(get_type_name(), $sformatf("[Lhs_Monitor] Capture data in RX: %b", trans_rx.data), UVM_LOW)
          `uvm_info(get_type_name(), $sformatf("[Lhs_Monitor] End of Capture RX"), UVM_LOW)
  endtask
endclass:uart_lhs_monitor
