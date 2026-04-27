class error_stop_bit_test extends uart_base_test;
     `uvm_component_utils(error_stop_bit_test)

     half_baud_sequence half_baud_seq;

     uart_configuration  lhs_config     ;
     uart_configuration  rhs_config     ;

     function new(string name="error_stop_bit_test", uvm_component parent);
          super.new(name, parent);
     endfunction: new
     
     virtual function void build_phase (uvm_phase phase);
          super.build_phase (phase);
          
          lhs_config  = uart_configuration::type_id::create("lhs_config");
          rhs_config  = uart_configuration::type_id::create("rhs_config");

          lhs_config.randomize () with {num_of_stop_bit == 1; data_width == 5; baud_rate == 9600; parity_mode == uart_configuration::NONE; direction_mode == uart_configuration::DUAL;};
          rhs_config.randomize () with {num_of_stop_bit == 2; data_width == 5; baud_rate == 9600; parity_mode == uart_configuration::NONE; direction_mode == uart_configuration::DUAL;};
         `uvm_info(get_type_name(), $sformatf("Baud_rate in lhs_config: %d", lhs_config.sprint()), UVM_LOW)
          uvm_config_db#(uart_configuration)::set(this, "uart_env", "lhs_config", lhs_config);
          uvm_config_db#(uart_configuration)::set(this, "uart_env", "rhs_config", rhs_config);

     endfunction: build_phase

     virtual task run_phase(uvm_phase phase);
          phase.raise_objection(this);

          half_baud_seq = half_baud_sequence::type_id::create("half_baud_seq");
          half_baud_seq.start(uart_env.uart_lhs.sequencer);
          #50ns;
          half_baud_seq.start(uart_env.uart_lhs.sequencer);
          half_baud_seq.start(uart_env.uart_rhs.sequencer);
          #50ns;
          half_baud_seq.start(uart_env.uart_rhs.sequencer);
          phase.drop_objection(this);
     endtask: run_phase

endclass: error_stop_bit_test

