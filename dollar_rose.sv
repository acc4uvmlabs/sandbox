module dollar_rose();

  reg    a, a_d;
  reg    clk;
  wire   out;
  
  always@(posedge clk) begin
    a_d <= a;
  end 
  
  assign out = a & ~a_d; 
  
  
  initial begin
    clk = 1;
    @(posedge clk)
    a = 1 ;
    a_d = 0;
    #100 $finish;
  end 
  
  always 
    #2 clk = !clk;
  
  initial begin
    $dumpvars(0, dollar_rose);
    $dumpfile("rose.vcd");
  end 
  
endmodule 
