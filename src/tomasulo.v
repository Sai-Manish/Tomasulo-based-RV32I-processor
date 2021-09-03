`timescale 1ns/1ps
module tomasulo (
    input clock,reset,
  	input [31:0] instruction
);
    // first declare all the necessary things needed.
    // then start arranging submodules accordingly.
  	reg [31:0]PC = 32'b0;
    reg need_to_stall = 1'b0; // if ROB or RS is not free the instruction will be stalled and PC wont be incremented
    wire done_decode;
  	wire done_issue;
    ///// ARF and RAT /////
    reg [31:0] register_file [0:31];
    reg [6:0] register_tag [0:31];
    reg register_valid [0:31]; 

    ///// ROB /////
    reg [5:0] RoB_Instruction [0:127]; //length(RoB) = 128; breadth(RoB) = 6 (instruction type) + 1 (busy bit) + 5 (destination address) + 32 (destination value)
    reg RoB_busy [0:127];
    reg RoB_Valid [0:127];
    reg [4:0] RoB_Dest_Addr[0:127];
    reg [31:0] RoB_Dest_Value[0:127];
    reg [6:0] RoB_Head = 7'b0;
    reg [6:0] RoB_Tail = 7'b0;
	///// Reservation station /////
    reg RS_Rtype_valid [0:2];// if 0 invalid if 1 valid //length(RS) = 3; breadth(RS) = 1 (valid bit) + 1 (busy bit)  + 6 (instruction type) + 7 (destination tag) + 7 (source1 tag) + 7 (source2 tag) + 32 (source1 value) + 32 (source2 value)  
	  reg RS_Rtype_busy [0:2];
    reg [5:0] RS_Rtype_instruction [0:2];
    reg [6:0] RS_Rtype_Dest_tag [0:2];
    reg [6:0] RS_Rtype_source1_tag [0:2];
    reg [6:0] RS_Rtype_source2_tag [0:2];
    reg [31:0] RS_Rtype_source1_value [0:2];
    reg [31:0] RS_Rtype_source2_value [0:2];
    reg [1:0]RS_Rtype_count = 2'b0;
    
  integer i,j,k;
  initial begin
      for (i=0;i<3;i=i+1) begin
        RS_Rtype_busy[i] <= 1'b0;
        RS_Rtype_instruction[i] <= 6'b0;
        RS_Rtype_Dest_tag[i] <= 7'b0;
        RS_Rtype_source1_tag[i] <= 7'b0;
        RS_Rtype_source2_tag[i] <= 7'b0;
        RS_Rtype_source1_value[i] <= 32'b0;
        RS_Rtype_source2_value[i] <= 32'b0;
      end
      
      for (j=0;j<128;j=j+1) begin
        RoB_busy[j] <= 0;
        RoB_Valid[j] <= 0;
        RoB_Dest_Addr[j] <= 5'b0;
        RoB_Dest_Value[j] <= 32'b0;
      end
      
      for (k=0;k<32;k=k+1)begin
        register_file[k] <= k;
        register_tag[k] <= 7'b0;
        register_valid[k] <= 1'b1;
        
      end
  end
  
  Issue_stage IS(PC,clock,instruction,done_decode,done_issue);  
  
endmodule