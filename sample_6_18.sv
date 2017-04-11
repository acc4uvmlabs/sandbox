// SV based class. Need to fix it for  UVM 
module sample_6_18;

  // import uvm_pkg::*;

  class randcinside ; // extends uvm_sequence_item;
  
    int array[];    // Dynamic Array
    randc bit [15:0] index; 
   
    // `uvm_object_utils_begin(randcinside)
    //   `uvm_field_int(index, UVM_ALL_ON) 
    // `uvm_object_utils_end
  
    function new(input int a[]);   // Initialize an array when creating an object
      array = a; 
    endfunction 

    function int pick;        // Return most recent picks
      return array[index];
    endfunction 

    constraint  c_size { index < array.size(); }

  endclass 

  randcinside   ri_h;
  initial begin 
    ri_h = new({'h1, 'h2, 'h4, 'h5, 'h7, 'h8, 'h10, 'h20});
    repeat(ri_h.array.size()) begin 
      ri_h.randomize();
      $display(" Picked  %2h [%0h]", ri_h.pick(), ri_h.index);
    end 
  end 

endmodule 

