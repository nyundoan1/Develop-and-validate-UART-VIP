class half_rcv_parity_none_test extends uart_base_test;
     `uvm_component_utils(half_rcv_parity_none_test)

     parity_sequence parity_seq;

     uart_configuration  uart_config    ;
     uart_configuration  lhs_config     ;
     uart_configuration  rhs_config     ;

     function new(string name="half_rcv_parity_none_test", uvm_component parent);
          super.new(name, parent);
     endfunction: new
     
     virtual function void build_phase (uvm_phase phase);
          super.build_phase (phase);
          
          uart_config = uart_configuration::type_id::create("uart_config");
          lhs_config  = uart_configuration::type_id::create("lhs_config");
          rhs_config  = uart_configuration::type_id::create("rhs_config");

          uart_config.randomize () with {parity_mode == NONE;  direction_mode == uart_configuration::REV;};
          lhs_config.copy(uart_config);
          rhs_config.copy(uart_config);

         `uvm_info(get_type_name(), $sformatf("Parity in lhs_config: %d", lhs_config.sprint()), UVM_LOW)
          uvm_config_db#(uart_configuration)::set(this, "uart_env", "lhs_config", lhs_config);
          uvm_config_db#(uart_configuration)::set(this, "uart_env", "rhs_config", rhs_config);

     endfunction: build_phase

     virtual task run_phase(uvm_phase phase);
          phase.raise_objection(this);

          parity_seq = parity_sequence::type_id::create("parity_seq");
          parity_seq.start(uart_env.uart_rhs.sequencer);

          phase.drop_objection(this);
     endtask: run_phase

endclass: half_rcv_parity_none_test

