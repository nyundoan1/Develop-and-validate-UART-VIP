class uart_lhs_config extends uvm_object;
     typedef enum bit [1:0] {
          NONE = 2'b00,
          ODD  = 2'b01,
          EVEN = 2'b10
     } parity_mode;

     rand     parity_mode parity   ;
     rand int data_width           ;
     rand int num_of_stop_bit      ;
     rand int baud_rate            ;
     rand bit use_discreate_baud   ;
     constraint config_c {
          data_width          inside {5, 6, 7, 8, 9};
          num_of_stop_bit     inside {1, 2};
          if (use_discreate_baud)
          {
               baud_rate      inside {4800, 9600, 19200, 57600, 115200};
          }
          else {
               baud_rate > 0       ;
               baud_rate < 115200  ;
          }
     }

     `uvm_object_utils_begin  (uart_lhs_config)
          `uvm_field_enum     (parity_mode,  parity,   UVM_ALL_ON)
          `uvm_field_int      (data_width ,            UVM_ALL_ON)
          `uvm_field_int      (num_of_stop_bit,        UVM_ALL_ON)
          `uvm_field_int      (baud_rate      ,        UVM_ALL_ON)
     `uvm_object_utils_end

     function new(string name = "uart_lhs_config");
          super.new(name);
     endfunction:new

endclass:uart_lhs_config

