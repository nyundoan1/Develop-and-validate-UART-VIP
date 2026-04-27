class uart_configuration extends uvm_object;
     typedef enum bit [1:0] {
          NONE = 2'b00,
          ODD  = 2'b01,
          EVEN = 2'b10
     } parity;
     typedef enum bit [1:0] {
          TRANS = 2'b00,
          REV   = 2'b01,
          DUAL  = 2'b10
     }direction;

     rand     parity parity_mode   ;
     rand     direction direction_mode ;
     rand int data_width           ;   
     rand int num_of_stop_bit      ;
     rand int baud_rate            ;
     constraint config_c {
          data_width          inside {5, 6, 7, 8, 9}; 
          num_of_stop_bit     inside {1, 2};
          baud_rate > 0;
          baud_rate < 115201;
     }   
     `uvm_object_utils_begin  (uart_configuration)
          `uvm_field_enum     (parity,  parity_mode,   UVM_ALL_ON)
          `uvm_field_enum     (direction, direction_mode,   UVM_ALL_ON)
          `uvm_field_int      (data_width ,            UVM_ALL_ON)
          `uvm_field_int      (num_of_stop_bit,        UVM_ALL_ON)
          `uvm_field_int      (baud_rate      ,        UVM_ALL_ON)
     `uvm_object_utils_end

     function new(string name = "uart_configuration");
          super.new(name);
          `uvm_info("UART_configuration", "Set up done!", UVM_HIGH)
     endfunction:new

endclass:uart_configuration

