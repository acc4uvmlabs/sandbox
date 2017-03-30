class constraints extends uvm_sequence_item;

  rand logic [11:0]  addr;
  rand logic [11:0]  not_addr;
  rand logic [31:0]  data; 
  rand logic         wr;
  rand logic         rd; 
  rand logic [11:0]  src, dst;
  rand logic [03:0]  size ;
  rand bit           dst_flag; 
  rand logic [4:0]   distribution;
 
  // Declare an enum data-type. 
 
  `uvm_object_utils_begin(constraints)
    `uvm_int_field(addr, UVM_ALL_ON)
    `uvm_int_field(not_addr, UVM_ALL_ON)
    `uvm_int_field(data, UVM_ALL_ON)
    `uvm_int_field(wr  , UVM_ALL_ON)
    `uvm_int_field(rd  , UVM_ALL_ON)
    `uvm_int_field(src , UVM_ALL_ON)
    `uvm_int_field(dst , UVM_ALL_ON)
    `uvm_int_field(size , UVM_ALL_ON)
    `uvm_int_field(dst_flag , UVM_ALL_ON)
    `uvm_int_field(distribution , UVM_ALL_ON)
  `uvm_object_utils_end

   function new( string name="constraints");
     super.new(name);
   endfunction 

   // Values are in hexadecimal. 
   // Constraints execute in Consecutive style. 
   // Inputs to the DUT are randomized. 
   constraint   addr_c    { addr inside {[0:100]};}
   constraint   notaddr_c { !(not_addr inside {[0:100]};)}
   constraint   data_c    { data inside {[0:100]};}
   constraint   wr_rd_c   { wr !== rd ;}
   constraint   size_c    { size inside {[0,1,3,7,0f]};}
   constraint   src_c     { src == 2**size; }
   // Conditional Contraint 
   constraint   dst_c     { if (dst_flag) {dst == src;} 
			    else {dst !== src; } }
   constraint   dist_c    { distribution dist {[0:7]:=10, [8:21]:=90, [22:26]:/20, [27:31]:/30}; 
                            }

endclass 
