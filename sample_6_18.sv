module sample_6_18;

  import uvm_pkg::*;

  class randcinside extends uvm_sequence_item;
  
    int array[];    // Dynamic Array
    randc bit [15:0] index; 
   
    `uvm_object_utils_begin(randcinside)
      `uvm_int_field(index, UVM_ALL_ON) 
    `uvm_object_utils_end
  
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
    ri_h = new({1, 2, 4, 5, 7, 8, 10, 20});
    repeat(ri_h.array.size()) begin 
      ri_h.randomize();
      $display(" Picked  %2d [%0d]", ri.pick(), ri.index);
    end 
  end 

endmodule 
