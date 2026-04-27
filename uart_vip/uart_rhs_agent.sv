class uart_rhs_agent extends uvm_agent;
     `uvm_component_utils(uart_rhs_agent)

     virtual uart_if rhs_if  ;

     uart_rhs_monitor    monitor   ;
     uart_rhs_driver     driver    ;
     uart_rhs_sequencer  sequencer ;
     uart_configuration  rhs_config;

     function new (string name="uart_rhs_agent", uvm_component parent);
          super.new (name, parent);
     endfunction: new

     virtual function void build_phase (uvm_phase phase);
          super.build_phase(phase);

          if (!uvm_config_db#(virtual uart_if)::get(this, "", "rhs_vif", rhs_if))
               `uvm_fatal(get_type_name(), $sformatf("Failed to get rhs_if from uvm_config_db"))
          
          if (!uvm_config_db#(uart_configuration)::get(this, "", "rhs_config", rhs_config))
              `uvm_fatal(get_type_name(), $sformatf("Failed to get rhs_config from uvm_config_db"))
          
          if (rhs_config.direction_mode == uart_configuration::TRANS)
          begin
               is_active = UVM_PASSIVE;
               rhs_if.tx = 1'b1;
          end
          else
               is_active = UVM_ACTIVE;

          if (is_active == UVM_ACTIVE) begin
               `uvm_info(get_type_name(), $sformatf("Active agent is configued"), UVM_LOW)
               sequencer = uart_rhs_sequencer::type_id::create("sequencer", this);
               monitor   = uart_rhs_monitor::type_id::create("monitor", this);
               driver    = uart_rhs_driver::type_id::create("driver", this);
          end 
          else begin
               `uvm_info(get_type_name(), $sformatf("Passive agent is configued"), UVM_LOW)
               monitor   = uart_rhs_monitor::type_id::create("monitor", this);
          end
          uvm_config_db#(virtual uart_if)::set(this, "monitor", "rhs_vif", rhs_if);
          uvm_config_db#(virtual uart_if)::set(this, "driver", "rhs_vif", rhs_if);

          if (rhs_config == null)
               `uvm_fatal(get_type_name(), $sformatf("Configuration db is null"))
          uvm_config_db#(uart_configuration)::set(this, "monitor", "rhs_config", rhs_config);
          uvm_config_db#(uart_configuration)::set(this, "driver", "rhs_config", rhs_config);
     
     endfunction:build_phase

     virtual function void connect_phase(uvm_phase phase);
          super.connect_phase(phase);
          if(get_is_active() == UVM_ACTIVE) begin
               driver.seq_item_port.connect(sequencer.seq_item_export);
          end 
     endfunction: connect_phase
endclass: uart_rhs_agent
