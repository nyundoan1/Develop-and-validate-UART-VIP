class uart_base_test extends uvm_test;
     `uvm_component_utils(uart_base_test)

     virtual uart_if lhs_if;
     virtual uart_if rhs_if;

     uart_environment uart_env;
     uart_configuration  lhs_config;
     uart_configuration  rhs_config;

     function new(string name="uart_base_test", uvm_component parent);
          super.new(name, parent);
     endfunction: new

     virtual function void build_phase(uvm_phase phase);
          super.build_phase(phase);
          `uvm_info("build_phase", "Entered...", UVM_HIGH)

          //Get lhs_if config db from testbench
          if (!uvm_config_db#(virtual uart_if)::get(this, "", "lhs_vif", lhs_if))
               `uvm_fatal(get_type_name(), $sformatf("Failed to get lhs_vif from uvm_config_db"))

          //Get rhs_if config db from testbench
          if (!uvm_config_db#(virtual uart_if)::get(this, "", "rhs_vif", rhs_if))
               `uvm_fatal(get_type_name(), $sformatf("Failed to get rhs_vif from uvm_config_db"))

          lhs_config = uart_configuration::type_id::create("lhs_config");
          rhs_config = uart_configuration::type_id::create("rhs_config");
          uart_env    = uart_environment::type_id::create("uart_env", this);
      
          if (!lhs_config.randomize) 
               `uvm_fatal(get_type_name(), $sformatf("Fatal to randomize lhs.config"))

          if (!rhs_config.randomize)
               `uvm_fatal(get_type_name(), $sformatf("Fatal to randomize rhs.config"))

          //Interface passed from base_test to environment
          uvm_config_db#(virtual uart_if)::set(this, "uart_env", "lhs_vif", lhs_if);
          uvm_config_db#(virtual uart_if)::set(this, "uart_env", "rhs_vif", rhs_if);
                    
          //Configuration DB passed from base_test to agent
          uvm_config_db#(uart_configuration)::set(this, "uart_env", "lhs_config", lhs_config);
          uvm_config_db#(uart_configuration)::set(this, "uart_env", "rhs_config", rhs_config);

          `uvm_info("build_phase", "Exiting...", UVM_HIGH)
     endfunction: build_phase

     virtual function void start_of_simulation_phase(uvm_phase phase);
          `uvm_info("start_of_simulation_phase", "Entered...", UVM_HIGH)
          uvm_top.print_topology();
          `uvm_info("start_of_simulation_phase", "Exiting...", UVM_HIGH)
     endfunction
endclass
          

