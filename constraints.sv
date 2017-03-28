class constraints extends uvm_sequence_item;

  rand logic [11:0]  addr;
  rand logic [31:0]  data; 
  rand logic         wr;
  rand logic         rd; 

  `uvm_object_utils_begin(constraints)
    `uvm_int_field(addr, UVM_ALL_ON)
    `uvm_int_field(data, UVM_ALL_ON)
    `uvm_int_field(wr  , UVM_ALL_ON)
    `uvm_int_field(rd  , UVM_ALL_ON)
  `uvm_object_utils_end

   function new( string name="constraints");
     super.new(name);
   endfunction 

   constraint   addr_c { addr inside {[0:100]};}
   constraint   data_c { data inside !{[0:100]};}
   constraint   addr_c { addr inside {[0:100]};}
   constraint   addr_c { addr inside {[0:100]};}

endclass 
