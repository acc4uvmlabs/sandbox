// vcs -sverilog +systemverilogext+.sv -assert svaext assert.sv ; ./simv & ;
// Important points: 
// Also note that, there can be only one valid start on any give positive edge of the clock, but there can be multiple valid endings.
module assertion();

  bit assertion_check  = 1;
  bit cover_check ;

  logic   a, b;
  logic   c, d;
  logic   u, v;
  logic   x, y;
  logic   req, resp; 
  logic   rst, clk; 

  default clocking cb@(posedge clk);
  endclocking 

  // Dev's question 
  property a_rose_a_fell(sig_a);
    @(posedge clk) disable iff(!rst) (sig_a) |=> $fell(sig_a) |-> !(sig_a) throughout ##[1:100] $rose(sig_b);
  endproperty 

  // It can also be solved using "within" construct. 
  sequence s32a;
    @(posedge clk) $rose(req) ##1 $fell(req) ; 
  endsequence 

  sequence s32b;
    @(posedge clk) $fell(req) ##[2:100] $rose(req); 
  endsequence 

  sequence s32c;
    @(posedge clk) $rose(resp) ##[1:97] $fell(resp) ;  
  endsequence 

  sequence s32;
    @(posedge clk) s32c within s32b;    
  endsequence 

  property p32;
    @(posedge clk) s32a.ended |-> s32;	  
  endproperty 

  ap32 : assert property(p32)
  else 
    $error("Resp did not assert within s32b cycles");	  

  // property a_stable(sig_a, sig_b);
  //   @(posedge clk) disable iff(!rst) $fell(sig_a) |-> ##[0:100] $rose(sig_b); // && $stable(sig_a) ;  
  // endproperty 

  a_rose_a_fell_prop: assert property (a_rose_a_fell(a))
  else 
    $error(" A_ROSE_A_FELL_NOT_STABLE violated \n ");   	   

  // a_rose_b_property : assert property (a_stable(a, b))
  // else 
  //   $error(" A_ROSE_B_DID_NOT_RISE violated \n");   	   

  
  property C_D;
    @(posedge clk) c |=> ##2 d;    
  endproperty 

  // Timing windows in SVA Checkers
  property p14;
    @(posedge clk) a |-> ##[1:3] b ##[0:10]c;  // When a is detected high, b should assert after next to (next+3) clock, then c should assert between current to next 10 clocks. 
    // By using $ instead of a 2nd number in the square bracket will be an
    // indefinite timing window condition. This is a bad practice to writing
    // SVA. As it might have an impact on simulation performance.
  endproperty 

  ap14: assert property(p14); 

  A_C_D :assert property (C_D)
      $display("%0t:  C_D PASSED   ", $time);
    else 
      $error("%0t:  C_D Assert property failed", $time); 	    

  sequence s15a;
    @(posedge clk) u ##1 v;	  
  endsequence 

  sequence s15b;
    @(posedge clk) x ##1 y;	  
  endsequence 

  // There are 2 different ways of writing the same check. This first method
  // synchronizes the sequences based on the starting points of the sequences.
  property p15a;
    s15a |=> s15b;	  
  endproperty

  // This second method synchronizes the sequences based on the end points of the sequences.
  property p15b;
	  s15a.ended |-> ##2 s15b.ended;	  
  endproperty

  a15a : assert property(p15a); 
  a15b : assert property(p15b); 

  // SVA checker using paramters. 
  parameter delay = 1;

  property p16;
    @(posedge clk) a |=> ##delay b; 	  
  endproperty 

  ap16 : assert property(p16); // Parameter can be overwritten when instantiating this module 

  // SVA checker using a select operator. 
  property p17;
    @(posedge clk) c ? d==a : d ==b;
  endproperty

  ap17 : assert property(p17);

  initial begin : prop15
    u = 0; v = 0 ;
    repeat(2)@(posedge clk) ;
      u = 1;   x = 1;
    @(posedge clk) ;
      v = 1;   x = 1; 
    @(posedge clk) ;
      y = 1;
    u = 0; v = 0 ;
    repeat(2)@(posedge clk) ;
      u = 1;   ##1 v = 1;
    repeat(2)@(posedge clk) ;
      x = 0;   ##1 y = 1;
  end 

  // Consecutive repetition order "[*n]"
  // Consecutive repetition order on a sequence  
  // Consecutive repetition order on a sequence with a delay window. 
  // Go to repetition operator : "[->n]" a sequence will repeat itself n times continuously or intermittently. 
  // Non-consecutive repetition operator "[=n]" 

  /* Go to repetition operator [->] 
     property p25;
     @(posedge elk) $rose(start) |->
     ##2 (a[->3]) ##1 stop;
     endproperty
     a25: assert property{p25);

     After the third match on signal "a," a valid "stop" signal is expected on the next clock cycle. 
     
     Non-consecutive repetition operator [=]
     property p2 6;
     @(posedge elk) $rose(start) |->
     ##2 {a[=3]) ##1 stop ##1 istop;
     endproperty
     a26: assert property{p26);
     After the third match on signal "a," a valid "stop" signal is expected, not necessarily on the next clock cycle. 
  */ 

  initial begin
     c = 1;
     repeat(2)@(posedge clk) ;
       d = 1;     
     repeat(2)@(posedge clk) ;
       d = 0;     
  end 

  initial begin
    clk = 0 ;	  
    rst = 0 ;	  
    $assertoff(1, assertion.a_rose_a_fell_prop,assertion.a_rose_b_property, assertion.A_C_D, assertion.ap14, assertion.a15a );  // To disable properties, use assertoff system task. This is called dynamic assertion control
    // There is a way to control in static way too. by using `ifdef ASSERT_ON
    #30 rst = 1; 
    #200 $finish;
  end 

  always 
    #2 clk = !clk; 	  

  initial begin 
    $dumpvars(0, assertion);
    $dumpfile("assertion.vcd");    
  end 
  
  initial begin
    a = 1 ;
    #05  a = 0 ;
    #15  a = 1 ; b = 1 ;
    #05  a = 0 ; b = 0 ;
    #21  a = 1 ; b = 0 ;
    #04  a = 0 ; b = 0 ;
    #04  a = 0 ; b = 0 ;
    @(posedge clk) a = 0 ; b = 1 ;
    @(posedge clk) a = 0 ; b = 0 ;
    @(posedge clk) a = 1 ; b = 0 ;
    @(posedge clk) a = 1 ; b = 0 ;
    @(posedge clk) a = 1 ; b = 0 ;
  end 

endmodule 



// `timescale 1ns/1ps
// 
// module ocpmon(Clk_i, MReset_ni, MCmd_i, MAddr_i, MByteEn_i,
//               SCmdAccept_i, MData_i, SResp_i, SData_i);
// 
//     input            Clk_i;
//     input            MReset_ni;
//     input  [2:0]     MCmd_i;
//     input  [15:0]    MAddr_i;
//     input  [3:0]     MByteEn_i;
//     input            SCmdAccept_i;
//     input  [31:0]    MData_i;
//     input  [1:0]     SResp_i;
//     input  [31:0]    SData_i;
//     reg    [2:0]     iMCmd;
//     reg    [15:0]    iMAddr;
// 
//     // Control Flag
//     bit assertion_check = 1; 
//     // bit cover_check = 1;   // Flag to enable coverage 
// 
//     default clocking cb @(posedge Clk_i);
//     endclocking
// 
//       /*********************************************************************************************/
//       // Rule 1.1.1
//       property signal_valid_signal_when_reset_inactive(sig);
//         @(posedge Clk_i) disable iff(!assertion_check)  (MReset_ni) |-> !$isunknown(sig);
//       endproperty
// 
//       /*********************************************************************************************/
//       // Rule 1.1.2
//       property request_valid_signal(sig);
//         @(posedge Clk_i) disable iff(!assertion_check)  (MReset_ni && (MCmd_i != 3'b000)) |-> !$isunknown(sig);
//       endproperty
// 
//       /*********************************************************************************************/
//       // Rule 1.2.3
//       property request_hold_signal(MCmd_i, SCmdAccept_i, sig);
//         @(posedge Clk_i) disable iff(!assertion_check)  ( MReset_ni && (MCmd_i != 3'b000) && (!SCmdAccept_i)) |=> ($stable(sig));
//       endproperty 
// 
//       /*********************************************************************************************/
//       // Rule 1.2.4
//       property request_value_MCmd_i_command;
//         @(posedge Clk_i) disable iff(!assertion_check)  (MReset_ni) |-> ((MCmd_i==3'b001) | (MCmd_i==3'b010) | (MCmd_i==3'b000));
//       endproperty
// 
//       /*********************************************************************************************/
//       // Rule 1.4.3
//        bit [7:0] req, resp; 
//        always @ (posedge Clk_i) begin 
//          if(!MReset_ni) begin 
//             req  = 0;
//          end 
//          else begin
//            if((MCmd_i == 3'b001)||(MCmd_i == 3'b010))  req = req+1;
//            else begin 
//              req = req;
//            end 
//          end 
//        end 
//        always @ (posedge Clk_i) begin 
//          if(!MReset_ni) begin 
//             resp  = 0;
//          end 
//          else begin
//            if ((SResp_i== 2'b01)) resp = resp+1;
//            else resp = resp ;
//          end 
//        end 
// 
//        property transfer_phase_order_response_before_request;
//          bit [7:0] num;
//        // @(posedge Clk_i)   (((MCmd_i==3'b001) | (MCmd_i==3'b010)), num = req) |-> ##[0:50] (SResp_i) && (num == resp) ;
//          @(posedge Clk_i)   (MReset_ni && (MCmd_i==3'b001) | (MCmd_i==3'b010)) |-> (req >= resp) ;
//        endproperty  
//       /*********************************************************************************************/
// 
//       // Rule 1.6.1
//       property signal_valid_signal(sig);
//         @(posedge Clk_i) disable iff(!assertion_check)  (!$isunknown(sig));
//       endproperty 
//       /*********************************************************************************************/
// 
//       // Rule 1.6.3
//       property signal_hold_signal_16_cycles(sig);
//         disable iff(!assertion_check)  $fell(sig) |-> (!sig[*16]) ;
//       endproperty 
//       /*********************************************************************************************/
// 
//     always @(posedge Clk_i) begin 
// 
//       /*********************************************************************************************/
//       // Rule 1.1.1 signal_valid_<signal>_when_reset_inactive 
//       MCmd_i_when_reset_inactive  : assert property(signal_valid_signal_when_reset_inactive(MCmd_i))
//       else
//         $error(" VIOLATED RULE 1.1.1 MCmd_i invalid when reset inactive ");  
//       MResp_i_when_reset_inactive : assert property(signal_valid_signal_when_reset_inactive(SResp_i))
//       else
//         $error(" VIOLATED RULE 1.1.1 SResp_i invalid when reset inactive ");  
//       /*********************************************************************************************/
// 
//       /*********************************************************************************************/
//       // // Rule 1.1.2 Request_Valid_<Signal>
//       request_valid_MAddr_i      : assert property(request_valid_signal(MAddr_i))
//       else
//         $error(" VIOLATED RULE 1.1.2 MAddr_i invalid when reset inactive ");  
//       request_valid_MByteEn_i    : assert property(request_valid_signal(MByteEn_i))
//       else
//         $error(" VIOLATED RULE 1.1.2 MByteEn_i invalid when reset inactive ");  
//       request_valid_SCmdAccept_i : assert property(request_valid_signal(SCmdAccept_i))
//       else
//         $error(" VIOLATED RULE 1.1.2 SCmdAccept_i invalid when reset inactive ");  
//        /*********************************************************************************************/
//       
//        /*********************************************************************************************/
//        // // Rule 1.2.3 Request_hold_<signal>
//        request_hold_MAddr_i  : assert property(request_hold_signal(MCmd_i, SCmdAccept_i, MAddr_i))
//        else
//          $error(" VIOLATED RULE 1.2.3 MAddr_i changed value before accepting SCmdAccept_i ");  
//        request_hold_MCmd_i   : assert property(request_hold_signal(MCmd_i, SCmdAccept_i, MCmd_i))
//        else
//          $error(" VIOLATED RULE 1.2.3 MCmd_i changed value before accepting SCmdAccept_i ");  
//        request_hold_MData_i  : assert property(request_hold_signal(MCmd_i, SCmdAccept_i, MData_i))
//        else
//          $error(" VIOLATED RULE 1.2.3 MData_i changed value before accepting SCmdAccept_i ");  
//        request_hold_MBteEn_i : assert property(request_hold_signal(MCmd_i, SCmdAccept_i, MByteEn_i))
//        else
//          $error(" VIOLATED RULE 1.2.3 MByteEn_i changed value before accepting SCmdAccept_i ");  
//        /*********************************************************************************************/
// 
//        /*********************************************************************************************/
//        // // Rule 1.2.4 Request_value_MCmd_<command>
//       request_value_MCmd_i_WR_RD : assert property(request_value_MCmd_i_command)
//       else
//         $error(" VIOLATED RULE 1.2.4 Invalid Command parameter setting ");  
//        /*********************************************************************************************/
//      
//        /*********************************************************************************************/
//      // Rule 1.2.5 Request_value_MAddr_word_alligned
//       request_value_MAddr_word_aligned : assert property ( 
//       disable iff (!assertion_check) (MReset_ni && MCmd_i !=0) |-> (MAddr_i[1:0] == 2'b00))
//       else
//         $error(" VIOLATED RULE 1.2.5 Data width error, MAddr is not word aligned to 32 bits of Data width ");  
//        /*********************************************************************************************/
//      
//        /*********************************************************************************************/
//        // NOT SURE OF THIS PROPERTY
//        // Rule 1.2.8 Request_value_MByteEn_force_aligned
//        // request_value_MByteEn_force_aligned : assert property ( 
//        //   disable iff (!assertion_check) (MAddr_i[1:0] == 2'b00) |-> ((MByteEn_i==4'b0001) | (MByteEn_i==4'b0010) | (MByteEn_i==4'b0100) | (MByteEn_i==4'b1000) | (MByteEn_i==4'b0011) | (MByteEn_i==4'b1100) | (MByteEn_i==4'b1111) | (MByteEn_i==4'b0000)) )                        // Check this property against 'x values of MAddr_i
//        //   else
//        //     $display(" MByteEn_i_force_aligned error ");  
//        /*********************************************************************************************/
//      
//        /*********************************************************************************************/
//        // The Fail response can occur only on a WRC request
//        // Rule 1.2.18 Response_value_SResp_FAIL_without_WRC
//         response_value_SResp_FAIL_without_WRC: assert property ( 
//         disable iff (!assertion_check) (MReset_ni) |-> !((SResp_i == 2'b10) && (MCmd_i != 3'b110))) 
//         else
//           $error(" VIOLATED RULE 1.2.18 MCmdWRC SResp_i asserted invalid value when MCmd!=3'b110 at %t", $time);  // it doesnt look correct. 
//        /*********************************************************************************************/
// 
//        /*********************************************************************************************/
//        // Rule 1.4.3 transfer_phase_order_response_before_request_begin
//         transfer_phase_order_response_before_request_begin: assert property(transfer_phase_order_response_before_request)
//         else 
//         $error(" VIOLATED RULE 1.4.3 Transfer phase order: response before request ERROR ");
//        /*********************************************************************************************/
// 
// 
//        /*********************************************************************************************/
//        // Rule 1.6.1 signal_valid_<signal>
//         signal_valid_MRreset_ni: assert property(signal_valid_signal(MReset_ni))
//         else 
//         $error(" VIOLATED RULE 1.6.1 Transfer phase order: response before request ERROR ");
//        /*********************************************************************************************/
// 
//        /*********************************************************************************************/
//        // Rule 1.6.3 signal_hold_<signal>_16_cycles 
//         signal_hold_signal_MReset_ni_16_cycles: assert property(signal_hold_signal_16_cycles(MReset_ni))
//         else 
//         $error(" VIOLATED RULE 1.6.3 MReset_ni 16 clocks hold violation, Reset was not held in active state for atleast 16 clocks");
//       /*********************************************************************************************/
// 
//     end 
// 
//     // always @(MCmd_i or SResp_i)  begin 
//     //    $display("MCMD_i   %h  SResp_i %h    %t", MCmd_i, SResp_i, $time);
//     // end 
//      
// endmodule

