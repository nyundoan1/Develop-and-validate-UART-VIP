class uart_lhs_agent extends uvm_agent;
     `uvm_component_utils(uart_lhs_agent)

     virtual uart_if lhs_if;

     uart_lhs_monitor    monitor   ;
     uart_lhs_driver     driver    ;
     uart_lhs_sequencer  sequencer ;
     uart_configuration  lhs_config;

     function new (string name="uart_lhs_agent", uvm_component parent);
          super.new (name, parent);
     endfunction: new

     virtual function void build_phase (uvm_phase phase);
          super.build_phase(phase);

          if (!uvm_config_db#(virtual uart_if)::get(this, "", "lhs_vif", lhs_if))
               `uvm_fatal(get_type_name(), $sformatf("Failed to get lhs_if from uvm_config_db"))
          
          if (!uvm_config_db#(uart_configuration)::get(this, "", "lhs_config", lhs_config))
              `uvm_fatal(get_type_name(), $sformatf("Failed to get lhs_config from uvm_config_db"))
          
          if (lhs_config.direction_mode == uart_configuration::REV)
          begin
               is_active = UVM_PASSIVE;
               lhs_if.tx = 1'b1;
          end
          else
               is_active = UVM_ACTIVE;

          if (is_active == UVM_ACTIVE) begin
               `uvm_info(get_type_name(), $sformatf("Active agent is configued"), UVM_LOW)
               driver    = uart_lhs_driver::type_id::create("driver", this);
               sequencer = uart_lhs_sequencer::type_id::create("sequencer", this);
               monitor   = uart_lhs_monitor::type_id::create("monitor", this);
          end
          else begin
               `uvm_info(get_type_name(), $sformatf("Passive agent is configued"), UVM_LOW)
               monitor   = uart_lhs_monitor::type_id::create("monitor", this);
          end
          
          uvm_config_db#(virtual uart_if)::set(this, "monitor", "lhs_vif", lhs_if);
          uvm_config_db#(virtual uart_if)::set(this, "driver", "lhs_vif", lhs_if);

          //`uvm_info(get_type_name(), $sformatf("baud_rate = %d, data_width = %d", lhs_config.baud_rate, lhs_config.data_width), UVM_LOW)
          uvm_config_db#(uart_configuration)::set(this, "monitor", "lhs_config", lhs_config);
          uvm_config_db#(uart_configuration)::set(this, "driver", "lhs_config", lhs_config);

     endfunction:build_phase

     virtual function void connect_phase(uvm_phase phase);
          super.connect_phase(phase);
          if(get_is_active() == UVM_ACTIVE) begin
               driver.seq_item_port.connect(sequencer.seq_item_export);
          end
     endfunction: connect_phase
endclass: uart_lhs_agent
