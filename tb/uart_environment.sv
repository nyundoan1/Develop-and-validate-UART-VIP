class uart_environment extends uvm_env;
     `uvm_component_utils(uart_environment)
     
     virtual uart_if lhs_if;
     virtual uart_if rhs_if;

     uart_scoreboard uart_sb ;
     uart_lhs_agent  uart_lhs;
     uart_rhs_agent  uart_rhs;
     uart_configuration lhs_config;
     uart_configuration rhs_config;

     function new(string name="uart_environment", uvm_component parent);
          super.new(name, parent);
     endfunction: new

     virtual function void build_phase(uvm_phase phase);
          super.build_phase(phase);
          `uvm_info("build_phase", "Entered...", UVM_HIGH)

          if (!uvm_config_db#(virtual uart_if)::get(this, "", "lhs_vif", lhs_if))
               `uvm_fatal(get_type_name(), $sformatf("Failed to get lhs_vif from uvm_config_db"))

          if (!uvm_config_db#(virtual uart_if)::get(this, "", "rhs_vif", rhs_if))
               `uvm_fatal(get_type_name(), $sformatf("Failed to get rhs_vif from uvm_config_db"))

          if (!uvm_config_db#(uart_configuration)::get(this, "", "rhs_config", rhs_config))
               `uvm_fatal(get_type_name(), $sformatf("Failed to get rhs_config from uvm_config_db"))

          if (!uvm_config_db#(uart_configuration)::get(this, "", "lhs_config", lhs_config))     
               `uvm_fatal(get_type_name(), $sformatf("Failed to get lhs_config from uvm_config_db"))

          uart_rhs = uart_rhs_agent::type_id::create("uart_rhs", this);
          uart_lhs = uart_lhs_agent::type_id::create("uart_lhs", this);
          uart_sb  = uart_scoreboard::type_id::create("uart_scoreboard", this);
          
          //Interface passed from environment to agent
          uvm_config_db#(virtual uart_if)::set(this, "uart_rhs", "rhs_vif", rhs_if);
          uvm_config_db#(virtual uart_if)::set(this, "uart_lhs", "lhs_vif", lhs_if);
          
          //Configuration DB passed from environment to agent
          uvm_config_db#(uart_configuration)::set(this, "uart_lhs", "lhs_config", lhs_config);
          uvm_config_db#(uart_configuration)::set(this, "uart_rhs", "rhs_config", rhs_config);

          if (rhs_config == null)
               `uvm_fatal(get_type_name(), $sformatf("Configuration db is null"))
          //Configuration DB passed from environment to scoreboard
          uvm_config_db#(uart_configuration)::set(this, "uart_scoreboard", "lhs_config", lhs_config);
          uvm_config_db#(uart_configuration)::set(this, "uart_scoreboard", "rhs_config", rhs_config);
          `uvm_info("build_phase", "Exiting...", UVM_HIGH)
     endfunction: build_phase

     virtual function void connect_phase (uvm_phase phase);
          super.connect_phase(phase);
          `uvm_info("connect_phase", "Entered...", UVM_HIGH)
          //uart_lhs.monitor.item_observed_port_tx.connect(uart_sb.item_collected_export_tx);
          //uart_rhs.monitor.item_observed_port_rx.connect(uart_sb.item_collected_export_rx);
          uart_lhs.monitor.lhs_monitor_tx.connect(uart_sb.lhs_monitor_exp_tx);
          uart_lhs.monitor.lhs_monitor_rx.connect(uart_sb.lhs_monitor_exp_rx);
          uart_rhs.monitor.rhs_monitor_tx.connect(uart_sb.rhs_monitor_exp_tx);
          uart_rhs.monitor.rhs_monitor_rx.connect(uart_sb.rhs_monitor_exp_rx);

          //transaction
          `uvm_info("connect_phase", "Exiting...", UVM_HIGH)
     endfunction: connect_phase
endclass: uart_environment
