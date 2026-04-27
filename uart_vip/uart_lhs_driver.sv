class uart_lhs_driver extends uvm_driver #(uart_transaction);
     `uvm_component_utils(uart_lhs_driver)

     virtual uart_if lhs_if;
     uart_configuration  lhs_config;

     function new (string name="uart_lhs_driver", uvm_component parent);
          super.new(name,parent);
     endfunction: new

     virtual function void build_phase(uvm_phase phase);
          super.build_phase(phase);

          if (!uvm_config_db#(virtual uart_if)::get(this, "", "lhs_vif", lhs_if))
               `uvm_fatal(get_type_name(), $sformatf("Failed to get lhs_if from uvm_config_db"))

          if (!uvm_config_db#(uart_configuration)::get(this, "", "lhs_config", lhs_config))
              `uvm_fatal(get_type_name(), $sformatf("Failed to get lhs_config from uvm_config_db"))

      endfunction:build_phase

      virtual task run_phase(uvm_phase phase);
          `uvm_info(get_type_name(), $sformatf("[Driver] UART Configuartion\n %s", lhs_config.sprint()), UVM_LOW);
          forever begin
               lhs_if.tx = 1'b1;
               seq_item_port.get(req);
               drive(req);
               $cast(rsp, req.clone());
               rsp.set_id_info(req);
               seq_item_port.put(rsp);

          end
      endtask: run_phase

      task drive (uart_transaction req);
          int baud_rate_tmp;
          bit parity;
          bit [1:0] stop_bit;
          `uvm_info(get_type_name(), $sformatf("[Driver] Transmit data: %b", req.data), UVM_LOW)
          baud_rate_tmp = (10**9)/lhs_config.baud_rate;
          `uvm_info(get_type_name(), $sformatf("[Driver] Baud_rade_tmp: %d. Baud_rate configuration: %d", baud_rate_tmp, lhs_config.baud_rate ), UVM_LOW)
          lhs_if.tx = 1'b0;
          #(baud_rate_tmp);
          for (int i = 0; i <lhs_config.data_width; i = i + 1) begin
               lhs_if.tx = req.data[i];
              `uvm_info(get_type_name(), $sformatf("[Driver] Transmitting: %b", lhs_if.tx), UVM_LOW)
               parity = parity ^ req.data[i];
               //`uvm_info(get_type_name(), $sformatf("[Driver] Parity: %b",parity), UVM_LOW)
               #(baud_rate_tmp);
          end
          `uvm_info(get_type_name(), $sformatf("[Driver] Start of Parity bit. Parity: %p", lhs_config.parity_mode), UVM_LOW)
          if (lhs_config.parity_mode == uart_configuration::NONE)
          begin
               lhs_if.tx = 1'b1;
               #(lhs_config.num_of_stop_bit * baud_rate_tmp);
          end
          else if (lhs_config.parity_mode == uart_configuration::EVEN) begin
               lhs_if.tx = parity;
                #(baud_rate_tmp);
                lhs_if.tx = 1'b1;
                `uvm_info(get_type_name(), $sformatf("[Driver] Parity: %b. Num of stop bit: %2d", lhs_if.tx, lhs_config.num_of_stop_bit), UVM_LOW)
                #(lhs_config.num_of_stop_bit * baud_rate_tmp);
          end
          else if (lhs_config.parity_mode == uart_configuration::ODD) begin
               lhs_if.tx = parity;
               #(baud_rate_tmp);
               lhs_if.tx = 1'b1;
               `uvm_info(get_type_name(), $sformatf("[Driver] Parity: %b. Num of stop bit: %2d", lhs_if.tx, lhs_config.num_of_stop_bit), UVM_LOW)
               #(lhs_config.num_of_stop_bit * baud_rate_tmp);
          end
          else
               `uvm_fatal(get_type_name(), $sformatf("[Driver] Failed to transmit parity and stop bit"))
          `uvm_info(get_type_name(), $sformatf("[Driver] End of transmit data"), UVM_LOW)
               
     endtask
endclass:uart_lhs_driver
