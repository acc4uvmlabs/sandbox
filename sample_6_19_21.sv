// constraint blocks are not procedural code, executing from top to bottom. They are declarative code, all active at the same time. 
// SystemVerilog constraints are bidirectional, which means that the constraints on all
// random variables are solved concurrently

module sample_6_19_21;
  
  import uvm_pkg::*;
  
  class busop extends uvm_sequence_item;

         bit          io_space_flag;
    rand logic [7:0]  addr;
    rand logic [7:0]  rd_addr;
    rand logic [7:0]  wr_addr;
    rand logic [1:0]  to_align;
    rand int          r, s ,t ; 
    
    typedef enum { WR, RD, IDLE } op;
    rand op           op_e;    
  
    `uvm_object_utils_begin(busop)
      `uvm_field_int(io_space_flag, UVM_ALL_ON)   // To register a property to a factory, it doesn't have to be a 'rand' type. 
      `uvm_field_int(addr, UVM_ALL_ON)
      `uvm_field_int(wr_addr, UVM_ALL_ON)
      `uvm_field_int(rd_addr, UVM_ALL_ON)
      `uvm_field_int(r      , UVM_ALL_ON | UVM_DEC)
      `uvm_field_int(s      , UVM_ALL_ON | UVM_DEC)
      `uvm_field_int(t      , UVM_ALL_ON | UVM_DEC)
      `uvm_field_enum(op, op_e, UVM_ALL_ON)
    `uvm_object_utils_end
  
    // Solve ... before ... 
    constraint  sol_before { solve to_align before addr ;}
    // This solve before didnt really matter. Have to learn real applications
    // to use Solve .. before .. 

    // Implication operator
    constraint  addr_c { (io_space_flag) -> 
	                  addr[7:4] == 'h1 && addr[3:0] == 2**to_align  ;}
    
    // if-else operator, for true and false 
    constraint  if_else_c { if (op_e == RD) 
                              rd_addr[2:0] == 0;
	                    else if (op_e == WR) 
			      wr_addr == rd_addr; 
		            else          // op_e == IDLE 
			      wr_addr == 0;
		              rd_addr == 0; 
	                   }
    // There is a problem with the if(op_e == WR) condition. If I do that as
    // if, op_e always takes WR value. 
     
    // Bi-directional Constraint. Constraints execute concurrently. they are
    // declarative in nature. 
    constraint  bi_c     { r < t;
                           s == r ; 
			   t < 30;
			   s >= 25; 
                          }

  endclass 
  
  busop  bus_h; 
  initial begin
    bus_h = new(); 
    bus_h.io_space_flag = 1'b1;
    repeat (30) begin 
      bus_h.randomize(); 
      bus_h.print(); 
      $display( "Addr  %h , io_space_flag %h  to_align %h", bus_h.addr, bus_h.io_space_flag, bus_h.to_align); 
      bus_h.io_space_flag = !bus_h.io_space_flag; 
    end 
  end 

endmodule 

// vcs -sverilog -ntb_opts uvm-1.1 -timescale=1ns/1ns sample_6_19_21.sv; ./simv & 
