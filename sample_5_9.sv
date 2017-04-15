module static_variable; 

  class transaction; 
  
    static int count = 0;
    int        id;
    
    function new();
      id = count++; 
    endfunction 
  
  endclass 
  
  transaction t1, t2; 
  initial begin
    t1=new();
    t2=new();
    $display(" Second id  %h, count %h ", t2.id, t2.count);
  end 

endmodule 
//  vcs -sverilog -timescale=1ns/1ns sample_5_9.sv ; ./simv &
