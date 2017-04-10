module sample_6_19_21;
  
  import uvm_pkg::*;
  
  class busop extends uvm_sequence_item;

    `uvm_object_utils_begin(busop)
    `uvm_object_utils_end
  
    // Implication operator
    // if-else operator, for true and false 
    // Bi-directional Constraint 

  endclass 
  
  busop  bus_h; 
  initial begin
    bus_h = new(); 
    bus_h.randomize(); 
    $display(); 
  end 

endmodule 
