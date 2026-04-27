class uart_rhs_monitor extends uvm_monitor;
     `uvm_component_utils(uart_rhs_monitor)

     virtual uart_if rhs_if ;

     uart_configuration  rhs_config;

     uart_transaction trans_tx;
     uart_transaction trans_rx;
     //uvm_analysis_port #(uart_transaction) item_observed_port_tx;
     //uvm_analysis_port #(uart_transaction) item_observed_port_rx;
     uvm_analysis_port #(uart_transaction) rhs_monitor_tx;
     uvm_analysis_port #(uart_transaction) rhs_monitor_rx;

     function new (string name="uart_rhs_monitor", uvm_component parent);
          super.new(name,parent);
          //item_observed_port_tx = new("item_observed_port_tx", this);
          //item_observed_port_rx = new("item_observed_port_rx", this);
          rhs_monitor_tx = new("rhs_monitor_tx", this);
          rhs_monitor_rx = new("rhs_monitor_rx", this);

          trans_tx = new();
          trans_rx = new(); 
     endfunction: new

     virtual function void build_phase(uvm_phase phase);
          super.build_phase(phase);

          if (!uvm_config_db#(virtual uart_if)::get(this, "", "rhs_vif", rhs_if))
               `uvm_fatal(get_type_name(), $sformatf("Failed to get rhs_vif from uvm_config_db"))

          if (!uvm_config_db#(uart_configuration)::get(this, "", "rhs_config", rhs_config))
               `uvm_fatal(get_type_name(), $sformatf("Failed to get rhs_config from uvm_config_db"))

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
          int baud_rate_tmp   ;
          int length          ;

          baud_rate_tmp = (10**9)/rhs_config.baud_rate;
          if (rhs_config.parity_mode != uart_configuration::NONE)
               length = rhs_config.data_width + rhs_config.num_of_stop_bit ;
          else
               length = rhs_config.data_width + rhs_config.num_of_stop_bit - 1;

          @(negedge rhs_if.tx);
          #(baud_rate_tmp);
          `uvm_info(get_type_name(), $sformatf("[Rhs_Monitor] Baud_rade_tmp: %d. Baud_rate configuration: %d", baud_rate_tmp, rhs_config.baud_rate ), UVM_LOW)
          for (int i = length ; i >= 0; i = i - 1) begin
               trans_tx.data[i] = rhs_if.tx;
               #(baud_rate_tmp);
               //trans_tx.data[i] = rhs_if.tx;
               //`uvm_info(get_type_name(), $sformatf("[Rhs_Monitor] Capture data in TX: [%1d]: %p", i, trans_tx.data[i]), UVM_LOW)
          end
          rhs_monitor_tx.write(trans_tx);
          `uvm_info(get_type_name(), $sformatf("[Rhs_Monitor] Capture data in TX: %b", trans_tx.data), UVM_LOW)
    endtask

    task capture_rx();
          //bit parity = 0;
          int baud_rate_tmp   ;
          int length          ;

          baud_rate_tmp = (10**9)/rhs_config.baud_rate;
          if (rhs_config.parity_mode != uart_configuration::NONE)
               length = rhs_config.data_width + rhs_config.num_of_stop_bit;
          else
               length = rhs_config.data_width + rhs_config.num_of_stop_bit - 1;

          @(negedge rhs_if.rx);
          #(baud_rate_tmp);
          //`uvm_info(get_type_name(), $sformatf("[Rhs_Monitor] Capture data in RX"), UVM_LOW)

          for (int i = length; i >= 0; i = i - 1) begin
               #(baud_rate_tmp);
               trans_rx.data[i] = rhs_if.rx;
               //`uvm_info(get_type_name(), $sformatf("[Rhs_Monitor] Capture data in RX: [%1d]: %p", i, trans_rx.data[i]), UVM_LOW)
          end
          
          rhs_monitor_rx.write(trans_rx);
          `uvm_info(get_type_name(), $sformatf("[Rhs_Monitor] Capture data in RX: %b", trans_rx.data), UVM_LOW)
          `uvm_info(get_type_name(), $sformatf("[Rhs_Monitor] End of Capture RX"), UVM_LOW)
  endtask
endclass:uart_rhs_monitor
