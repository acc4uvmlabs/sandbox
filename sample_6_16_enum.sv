module sample_6_16; 

class enum_random extends uvm_sequence_item;
  
  typedef enum { SUN, MON, TUES, WED, THUR, FRI, SAT } day_e; 
  days_e  days[$];

  rand days_e choice;  
  
  constraint  day_c { choice inside days ;}

endclass 

enum_random enum_h; 
initial begin
  enum_h = new();
  repeat(5) begin 
    enum_h.choice = { enum_random::SAT, enum_random::SUN };
    enum_h.randomize();
    $display("Weekend Days %s \n", enum_h.choice.name);

    enum_h.choice = { enum_random::MON, enum_random::TUES, enum_random::WED, 
                      enum_random::THUR, enum_random::FRI };
    enum_h.randomize();
    $display("Weekday Days %s \n", enum_h.choice.name);
  end 
end 

endmodule 
 
