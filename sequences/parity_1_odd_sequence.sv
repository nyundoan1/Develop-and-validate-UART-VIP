class parity_1_odd_sequence extends uvm_sequence #(uart_transaction);
  `uvm_object_utils(parity_1_odd_sequence)

  function new(string name="parity_1_odd_seq");
    super.new(name);
  endfunction

  virtual task body();
      req = uart_transaction::type_id::create("req");
      start_item(req);
      req.randomize () with {data == 14'b00_0000_1011_0101;  };
      `uvm_info(get_type_name(),$sformatf("Send req to driver: \n %s",req.sprint()),UVM_LOW);
      finish_item(req);
      get_response(rsp);
      #1us;
      `uvm_info(get_type_name(),$sformatf("Recevied rsp to driver: \n %s",rsp.sprint()),UVM_LOW);
  endtask

endclass

