class parity_0_even_sequence extends uvm_sequence #(uart_transaction);
  `uvm_object_utils(parity_0_even_sequence)

  function new(string name="parity_0_even_seq");
    super.new(name);
  endfunction

  virtual task body();
      req = uart_transaction::type_id::create("req");
      start_item(req);
      req.randomize () with {data == 13'b1101111111110;  };
      `uvm_info(get_type_name(),$sformatf("Send req to driver: \n %s",req.sprint()),UVM_LOW);
      finish_item(req);
      get_response(rsp);
      #1us;
      `uvm_info(get_type_name(),$sformatf("Recevied rsp to driver: \n %s",rsp.sprint()),UVM_LOW);
  endtask

endclass

