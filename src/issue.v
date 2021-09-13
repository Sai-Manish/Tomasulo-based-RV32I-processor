module Issue_stage (
    input [31:0] PC,
    input clock,
  	//input [31:0] instruction,
    output done_decode,
  	output done_issue
    // for other instruction format need to add outputs
);

integer i;
reg done_decode = 0;
reg done_issue = 0; 
reg done_fetch = 0;
reg RS_Rtype_empty; //if 0  it is empty
reg [1:0] RS_Rtype_found;
reg [6:0] opcode;
reg [5:0] funct;
reg [4:0] R_rd;
reg [4:0] R_rs1;
reg [4:0] R_rs2;
reg [31:0]instruction_to_be_decoded;

//assign instruction_to_be_decoded = instruction;
//assign opcode = instruction_to_be_decoded[6:0];
//considering integer register-register operations
always @(posedge clock) begin
  instruction_to_be_decoded = tomasulo.instruction_memory[PC];
  opcode = instruction_to_be_decoded[6:0];
  done_fetch = 1;
end

always @(posedge done_fetch) begin
    if (opcode == 7'b0110011) begin
	    if (instruction_to_be_decoded[30] == 0) begin
		    if (instruction_to_be_decoded[14:12] == 3'b000) begin
			    funct = 6'b011011; //ADD
		    end
		    else if (instruction_to_be_decoded[14:12] == 3'b001) begin
			    funct <= 6'b011101; //SLL
		    end
		    else if (instruction_to_be_decoded[14:12] == 3'b010) begin
			    funct <= 6'b011110; //SLT
		    end
		    else if (instruction_to_be_decoded[14:12] == 3'b011) begin
			    funct <= 6'b011111; //SLTU
		    end
		    else if (instruction_to_be_decoded[14:12] == 3'b100) begin
			    funct <= 6'b100000; //XOR
		    end
		    else if (instruction_to_be_decoded[14:12] == 3'b101) begin
			    funct <= 6'b100001; //SRL
		    end
		    else if (instruction_to_be_decoded[14:12] == 3'b110) begin
			    funct <= 6'b100011; //OR
		    end
		    else if (instruction_to_be_decoded[14:12] == 3'b111) begin
			    funct <= 6'b100100; //AND
		    end
	    end
    
	    else if (instruction_to_be_decoded[30] == 1) begin
		    if (instruction_to_be_decoded[14:12] == 3'b000) begin
			    funct <= 6'b011100; //SUB
		    end
		    else if (instruction_to_be_decoded[14:12] == 3'b101) begin
			    funct <= 6'b100010; //SRA
		    end
	    end
	
	  R_rd <= instruction_to_be_decoded[11:7];
  	R_rs1 <= instruction_to_be_decoded[19:15];
  	R_rs2 <= instruction_to_be_decoded[24:20];
    done_decode = 1;
  end
end

always @(posedge done_decode) begin
  
  if (tomasulo.need_to_stall == 1'b0) begin
      if (tomasulo.RoB_busy[tomasulo.RoB_Tail] == 1'b1) begin
        if (tomasulo.RoB_Head == tomasulo.RoB_Tail) begin
            tomasulo.need_to_stall <= 1'b1;
          	// This part is working fine.
        end
      end
      
      else begin
        for (i = 0 ;(i < 2);i = i + 1 ) begin
            if (tomasulo.RS_Rtype_busy[i] == 0) begin
                RS_Rtype_found = i;
                RS_Rtype_empty = 1'b1; // found an empty entry
              	i = 2;
            end
        end
			
            // if there is no empty slot in RS the RS_Empty is 0;
        if (RS_Rtype_empty == 1'b0) begin
              tomasulo.need_to_stall = 1'b1;   	
        end

        else begin
          // entering into RS
          tomasulo.RS_Rtype_busy[RS_Rtype_found] <= 1'b1; // setting rs entry busy bit
          tomasulo.RS_Rtype_instruction[RS_Rtype_found] <= funct; // entering type of function in rs entry
          tomasulo.RS_Rtype_Dest_tag[RS_Rtype_found] <= tomasulo.RoB_Tail; // destnation entry in RS
          tomasulo.RS_Rtype_instruction_index[RS_Rtype_found] <= tomasulo.Index;

          // updating in RAT
          tomasulo.register_tag[R_rd] <= tomasulo.RoB_Tail; // Tag in RAT
          tomasulo.register_valid[R_rd] <= 1'b0; // 0 means is not valid

          //entering into ROB
          tomasulo.RoB_busy[tomasulo.RoB_Tail] <= 1'b1; // 1 means it is busy
          tomasulo.RoB_Valid[tomasulo.RoB_Tail] <= 1'b0; // 0 means it is invalid
          tomasulo.RoB_Dest_Addr[tomasulo.RoB_Tail] <= R_rd; // Register tag entry in RAT
          tomasulo.RoB_Dest_Value[tomasulo.RoB_Tail] <= 32'bx;  // if possible can put 32'bx
          tomasulo.RoB_Instruction_Index[tomasulo.RoB_Tail] <= tomasulo.Index;
          tomasulo.RoB_Tail = tomasulo.RoB_Tail + 7'b0000001; // Incrementing RoB tail

          //The below if else conditions is for finding whether there is valid entry of sources in RAT or not
          // Accordingly writing the entries of RS entry
          if(tomasulo.register_valid[R_rs1] == 1'b1) begin
              tomasulo.RS_Rtype_source1_tag [RS_Rtype_found] <= 7'bx; // if possible can put 7'bx, should find out whether it is correct keeping like that 
              tomasulo.RS_Rtype_source1_value [RS_Rtype_found] <= tomasulo.register_file[R_rs1];
          end   
          else begin
            tomasulo.RS_Rtype_source1_tag [RS_Rtype_found] <= tomasulo.register_tag[R_rs1];
            tomasulo.RS_Rtype_source1_value [RS_Rtype_found] <= 32'bx; // if possible can put 32'bx
            tomasulo.RS_Rtype_valid[RS_Rtype_found] <= 1'b0;
          end

          if(tomasulo.register_valid[R_rs2] == 1'b1) begin
              tomasulo.RS_Rtype_source2_tag [RS_Rtype_found] <= 7'bx; // if possible can put 7'bx
              tomasulo.RS_Rtype_source2_value [RS_Rtype_found] <= tomasulo.register_file[R_rs2];
          end   
          else begin
              tomasulo.RS_Rtype_source2_tag [RS_Rtype_found] <= tomasulo.register_tag[R_rs2];
              tomasulo.RS_Rtype_source2_value [RS_Rtype_found] <= 32'bx; // if possible can put 32'bx
              tomasulo.RS_Rtype_valid[RS_Rtype_found] <= 1'b0;
          end
         
         // incrementing PC
         tomasulo.PC = tomasulo.PC + 32'b0000_0000_0000_0000_0000_0000_0000_0001;
         // incrementing index value
         tomasulo.Index = tomasulo.Index + 11'b00000000001;
         // setting few variables used according the code functionality. will be helpful for doing some checks
         RS_Rtype_empty = 1'b0;
         done_fetch = 1'b0;
         done_decode = 1'b0;
         done_issue = 1;     	
        end 
      end
  end
end
endmodule