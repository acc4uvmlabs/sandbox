module constrain;
 
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  class weighted_constraints extends uvm_sequence_item;
  
    rand int val;
    int array[] = {1, 1, 2, 3,5, 8, 8, 8, 8, 8}; 
     
    constraint  val_c { val inside array;}
  
    `uvm_object_utils_begin(weighted_constraints)
      uvm_field_int(val, UVM_ALL_ON)
    `uvm_object_utils_end
   
    function new( string name ="weighted_constraints");
      super.new(name);
    endfunction 
  
  endclass 

  weighted_constraints wc_h; 

  initial begin   
    int count[9], maxx[$];
    wc_h  = new();
    repeat (2000) begin
      assert(wc_h.randomize());
      count[wc_h.val]++;
    end 
    
    maxx = count.max();

    // print histogram of count
    foreach(count[i]) begin
      $write("count[%0d] = %5d", i, count[i]);
      repeat (count[i]*40/maxx[0])  
        $write("*");
      $display();
    end 
  end 

endmodule 

