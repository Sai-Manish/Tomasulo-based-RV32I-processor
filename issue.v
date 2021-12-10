module Issue_stage (
  input [31:0] PC,
  input clock,
  input reset
  );
    integer ii,ij;
    parameter R_RS_size = 3;
    parameter I_RS_size = 3;
    reg [6:0] opcode;
    reg [5:0] funct;
    reg [31:0]instruction_to_be_decoded;

    reg R_type_instruct; // for if condition, tells it is R type instruction
    reg I_type_instruct; // for if condition, tells it is I type instruction
    reg L_type_instruct;
    reg S_type_instruct;
    // For R type
    reg RS_Rtype_empty; //if 0  it is empty
    reg [1:0] RS_Rtype_found;
    reg [4:0] R_rd;
    reg [4:0] R_rs1;
    reg [4:0] R_rs2;

    // For I type
    reg RS_Itype_empty; // if 0 it is empty
    reg [1:0] RS_Itype_found;
    reg [4:0] I_rd;
    reg [4:0] I_rs1;
    reg signed [11:0] immediate_value;

    // For L type for Load
    reg RS_Ltype_empty; // if 0 it is empty
    reg [1:0] RS_Ltype_found;
    reg [4:0] L_rd;
    reg [4:0] L_rs1;
    reg signed [11:0] L_offset;

    // For S type for Store
    reg RS_Stype_empty; // if 0 it is empty
    reg [1:0] RS_Stype_found;
    reg [4:0] S_rs1;
    reg [4:0] S_rs2;
    reg signed [11:0] S_offset;


    //assign instruction_to_be_decoded = instruction;
    //assign opcode = instruction_to_be_decoded[6:0];
    //considering integer register-register operations
    always @(posedge clock) begin
        RS_Itype_empty = 0;
        RS_Rtype_empty = 0;
        RS_Ltype_empty = 0;
        RS_Stype_empty = 0;
        R_type_instruct = 0;
        I_type_instruct = 0;
        L_type_instruct = 0;
        S_type_instruct = 0;

        if (reset == 0) begin
            instruction_to_be_decoded = tomasulo.instruction_memory[PC];
            opcode = instruction_to_be_decoded[6:0];
            tomasulo.done_fetch = 1;
        end
    end

    always @(posedge tomasulo.done_fetch) begin
        if (reset == 0) begin
            if(opcode == 7'b0110011) begin
                if(instruction_to_be_decoded[14:12] == 3'b000) begin
			        if(instruction_to_be_decoded[30] == 0) begin
				        funct = 6'b011011; //ADD
       
			        end
			        else if(instruction_to_be_decoded[30] == 1) begin
				        funct = 6'b011100; //SUB
			        end
                end

                else if(instruction_to_be_decoded[14:12] == 3'b001) begin
			        funct = 6'b011101; //SLL
      
		        end
		        
                else if(instruction_to_be_decoded[14:12] == 3'b010) begin
			        funct = 6'b011110; //SLT
		        end
		        
                else if(instruction_to_be_decoded[14:12] == 3'b011) begin
			        funct = 6'b011111; //SLTU
		        end

                else if(instruction_to_be_decoded[14:12] == 3'b100) begin
			        funct = 6'b100000; //XOR
		        end
		        
                else if(instruction_to_be_decoded[14:12] == 3'b101) begin
			        if(instruction_to_be_decoded[30] == 0) begin
				        funct = 6'b100001; //SRL
        
			        end
			        
                    else if(instruction_to_be_decoded[30] == 1) begin
				        funct = 6'b100010; //SRA
        
			        end
		        end

		        else if(instruction_to_be_decoded[14:12] == 3'b110) begin
			        funct = 6'b100011; //OR
                end

		        else if(instruction_to_be_decoded[14:12] == 3'b111) begin
			        funct = 6'b100100; //AND
		        end

                R_rd = instruction_to_be_decoded[11:7];
  	            R_rs1 = instruction_to_be_decoded[19:15];
  	            R_rs2 = instruction_to_be_decoded[24:20];
                R_type_instruct = 1;
                tomasulo.done_decode = 1;
            end

            else if (opcode == 7'b0010011) begin
                if (instruction_to_be_decoded[14:12] == 3'b000) begin
		            funct = 6'b010010; //ADDI
                end

                else if (instruction_to_be_decoded[14:12] == 3'b010) begin
                    funct = 6'b010011; // SLTI
                end

                else if (instruction_to_be_decoded[14:12] == 3'b011) begin
                    funct = 6'b010100; // SLTIU
        
                end
                
                else if (instruction_to_be_decoded[14:12] == 3'b100) begin
                    funct = 6'b010101; // XORI
                end

                else if (instruction_to_be_decoded[14:12] == 3'b110) begin
                    funct = 6'b010110; // ORI
                end

                else if (instruction_to_be_decoded[14:12] == 3'b111) begin
                    funct = 6'b010111; // ANDI
                end

                else if (instruction_to_be_decoded[14:12] == 3'b001) begin
                    funct = 6'b011000; // SLLI
        
                end

                else if (instruction_to_be_decoded[14:12] == 3'b101) begin
        
                    if (instruction_to_be_decoded[30] == 0) begin
                        funct = 6'b011001; // SRLI
                    end

                    else if (instruction_to_be_decoded[30] == 1) begin
                        funct = 6'b011010; // SRAI
                    end
                end

                I_rd = instruction_to_be_decoded[11:7];
  	            I_rs1 = instruction_to_be_decoded[19:15];
  	            immediate_value = instruction_to_be_decoded[31:20];
                I_type_instruct = 1;
                tomasulo.done_decode = 1;
            end

            else if (opcode == 7'b0000011) begin
			    if(instruction_to_be_decoded[14:12] == 3'b000) begin
				    funct = 6'b001010; //LB
			    end
			    
                else if(instruction_to_be_decoded[14:12] == 3'b001) begin
				    funct = 6'b001011; //LH
			    end
			    
                else if(instruction_to_be_decoded[14:12] == 3'b010) begin
				    funct = 6'b001100; //LW
			    end
			
                else if(instruction_to_be_decoded[14:12] == 3'b100) begin
				    funct = 6'b001101; //LBU
			    end
			    else if(instruction_to_be_decoded[14:12] == 3'b101) begin
				    funct = 6'b001110; //LHU
			    end
			
			    L_rd = instruction_to_be_decoded[11:7];
			
			    L_rs1 = instruction_to_be_decoded[19:15];
			
			    L_offset = instruction_to_be_decoded[31:20];

                L_type_instruct = 1;
				
			    tomasulo.done_decode = 1;

            end

            else if (opcode == 7'b0100011) begin
                $display("Decoded to be store instruction");
                if(instruction_to_be_decoded[14:12] == 3'b000) begin
				    funct = 6'b001111; //SB
			    end
			    else if(instruction_to_be_decoded[14:12] == 3'b001) begin
				    funct = 6'b010000; //SH
			    end
			    else if(instruction_to_be_decoded[14:12] == 3'b010) begin
				    funct = 6'b010001; //SW
			    end
			
			    S_rs1 = instruction_to_be_decoded[19:15];
                $display("%d", S_rs1);
			    S_rs2 = instruction_to_be_decoded[24:20];
                $display("%d", S_rs2);
			
			    S_offset = {instruction_to_be_decoded[31:25], instruction_to_be_decoded[11:7]};
				
                S_type_instruct = 1;
			    
                tomasulo.done_decode = 1;
            end
        end
    end

    always @(posedge tomasulo.done_decode) begin

        if(reset==0)begin    

            if (tomasulo.need_to_stall == 1'b0) begin
                // checking if rob is free or not
                if (tomasulo.RoB_busy[tomasulo.RoB_Tail] == 1'b1) begin

                    if (tomasulo.RoB_Head == tomasulo.RoB_Tail) begin

                        tomasulo.need_to_stall = 1'b1;
                        //$display("This part is working fine.");
                    end
                end
            
            
                else begin
            
                    // will dispatch to RS Rtype and rob
                    if (R_type_instruct == 1) begin
            
                        for (ii = 0 ;(ii < R_RS_size);ii = ii + 1 ) begin
                    
                            if (tomasulo.RS_Rtype_busy[ii] == 0) begin
                        
                                RS_Rtype_found = ii; // gives the index of RS which is free
                                //$display("free RS entry : RS_Rtype_found = %d",RS_Rtype_found);
                                RS_Rtype_empty = 1'b1; // found an empty entry
                                ii = R_RS_size;
                            end
                        end

                        // if there is no empty slot in RS the RS_Empty is 0 so we need to stall
                        if (RS_Rtype_empty == 1'b0) begin
                            tomasulo.need_to_stall = 1'b1;   	
                        end

                        else begin
                            // entering into RS
                            tomasulo.RS_Rtype_busy[RS_Rtype_found] = 1'b1; // setting rs entry busy bit
                            tomasulo.RS_Rtype_instruction[RS_Rtype_found] = funct; // entering type of function in rs entry
                            tomasulo.RS_Rtype_Dest_tag[RS_Rtype_found] = tomasulo.RoB_Tail; // destnation entry in RS
                            tomasulo.RS_Rtype_instruction_index[RS_Rtype_found] = tomasulo.Index; // which instruction number it is

                            //The below if else conditions is for finding whether there is valid entry of sources in RAT or not
                            // Accordingly writing the entries of RS entry

                            if(tomasulo.register_valid[R_rs1] == 1'b1 && R_rs1 != 5'b0) begin
                                tomasulo.RS_Rtype_source1_tag [RS_Rtype_found] = 7'b0; // if possible can put 7'bx, should find out whether it is correct keeping like that 
                                tomasulo.RS_Rtype_source1_value [RS_Rtype_found] = tomasulo.register_file[R_rs1];
                                tomasulo.RS_Rtype_source1_valid[RS_Rtype_found] = 1'b1;
                                $display("In dispatch stage, R_rs1 is valid");
                            end  

                            else if(tomasulo.register_valid[R_rs1] == 1'b0 && R_rs1 != 5'b0) begin
                                tomasulo.RS_Rtype_source1_tag [RS_Rtype_found] = tomasulo.register_tag[R_rs1];
                                tomasulo.RS_Rtype_source1_value [RS_Rtype_found] = 32'bx; // if possible can put 32'bx
                                tomasulo.RS_Rtype_source1_valid[RS_Rtype_found] = 1'b0;
                                $display("In dispatch stage, R_rs1 is not valid");
                            end

                            if(tomasulo.register_valid[R_rs2] == 1'b1 && R_rs2 != 5'b0) begin
                                tomasulo.RS_Rtype_source2_tag [RS_Rtype_found] = 7'b0; // if possible can put 7'bx
                                tomasulo.RS_Rtype_source2_value [RS_Rtype_found] = tomasulo.register_file[R_rs2];
                                tomasulo.RS_Rtype_source2_valid[RS_Rtype_found] = 1'b1;
                                $display("In dispatch stage, R_rs2 is valid");
                            end 

                            else if(tomasulo.register_valid[R_rs2] == 1'b0 && R_rs2 != 5'b0)begin
                                tomasulo.RS_Rtype_source2_tag [RS_Rtype_found] = tomasulo.register_tag[R_rs2];
                                tomasulo.RS_Rtype_source2_value [RS_Rtype_found] = 32'bx; // if possible can put 32'bx
                                tomasulo.RS_Rtype_source2_valid[RS_Rtype_found] = 1'b0;
                                $display("In dispatch stage, R_rs2 is not valid");
                            end

                            if(R_rs1 == 5'b0) begin
                                tomasulo.RS_Rtype_source1_tag [RS_Rtype_found] = 7'b0; // if possible can put 7'bx, should find out whether it is correct keeping like that 
                                tomasulo.RS_Rtype_source1_value [RS_Rtype_found] = tomasulo.register_file[R_rs1];
                                tomasulo.RS_Rtype_source1_valid[RS_Rtype_found] = 1'b1;
                                 $display("In dispatch stage, R_rs1 is 0 ");
                            end  

                            if(R_rs2 == 5'b0) begin
                                tomasulo.RS_Rtype_source2_tag [RS_Rtype_found] = 7'b0; // if possible can put 7'bx
                                tomasulo.RS_Rtype_source2_value [RS_Rtype_found] = tomasulo.register_file[R_rs2];
                                tomasulo.RS_Rtype_source2_valid[RS_Rtype_found] = 1'b1;
                                $display("In dispatch stage, R_rs2 is 0 ");
                            end

                            if (tomasulo.RS_Rtype_source1_valid[RS_Rtype_found] == 1'b1 && tomasulo.RS_Rtype_source2_valid[RS_Rtype_found] == 1'b1) begin
                                tomasulo.RS_Rtype_valid[RS_Rtype_found] = 1'b1;  
                                $display("In dispatch stage, Both source operands are valid ");          
                            end

                            else begin
                                tomasulo.RS_Rtype_valid[RS_Rtype_found] = 1'b0;
                                $display("In dispatch stage, Both source operands are not valid "); 
                            end

                            // updating in RAT
                            tomasulo.register_tag[R_rd] = tomasulo.RoB_Tail; // Tag in RAT
                            tomasulo.register_valid[R_rd] = 1'b0; // 0 means is not valid

                            //entering into ROB
                            tomasulo.RoB_busy[tomasulo.RoB_Tail] = 1'b1; // 1 means it is busy
                            tomasulo.RoB_Valid[tomasulo.RoB_Tail] = 1'b0; // 0 means it is invalid
                            tomasulo.RoB_Dest_Addr[tomasulo.RoB_Tail] = R_rd; // Register tag entry in RAT
                            tomasulo.RoB_Dest_Value[tomasulo.RoB_Tail] = 32'bx;  // if possible can put 32'bx
                            tomasulo.RoB_Instruction_Index[tomasulo.RoB_Tail] = tomasulo.Index;
                            tomasulo.RoB_Instruction[tomasulo.RoB_Tail] = funct;
                            tomasulo.RoB_Tail = $unsigned(tomasulo.RoB_Tail + 7'b0000001) % 128;
                            //tomasulo.RoB_Tail = tomasulo.RoB_Tail + 7'b0000001; // Incrementing RoB tail
        
                            // incrementing PC
                            tomasulo.PC = tomasulo.PC + 32'b0000_0000_0000_0000_0000_0000_0000_0001;
         
                            tomasulo.Instruction_state_register[tomasulo.Index] = 3'b001;

                            // incrementing index value
                            tomasulo.Index = tomasulo.Index + 32'b0000_0000_0000_0000_0000_0000_0000_0001;
         
                            // setting few variables used according the code functionality. will be helpful for doing some checks
                            RS_Rtype_empty = 1'b0;
                            tomasulo.done_fetch = 1'b0;
                            tomasulo.done_decode = 1'b0;
                            tomasulo.done_issue = 1'b1;
                            R_type_instruct = 0;    
                        end
                    end

                    if (I_type_instruct == 1) begin
                        for (ij = 0 ;(ij < 3);ij = ij + 1 ) begin
                            if (tomasulo.RS_Itype_busy[ij] == 0) begin
                                RS_Itype_found = ij;
                                //$display("free RS entry : RS_Rtype_found = %d",RS_Rtype_found);
                                RS_Itype_empty = 1'b1; // found an empty entry
                                ij = 3;
                            end
                        end

                        // if there is no empty slot in RS the RS_Empty is 0;

                        if (RS_Itype_empty == 1'b0) begin
                            tomasulo.need_to_stall = 1'b1;   	
                        end

                        else begin
                            // entering into RS
                            tomasulo.RS_Itype_busy[RS_Itype_found] = 1'b1; // setting rs entry busy bit
                            tomasulo.RS_Itype_instruction[RS_Itype_found] = funct; // entering type of function in rs entry
                            tomasulo.RS_Itype_instruction_index[RS_Itype_found] = tomasulo.Index;
                            
                            if (immediate_value[11] == 0) begin
                                tomasulo.RS_Itype_immediate_value[RS_Itype_found] = {20'b0,immediate_value};
                            end
                            else begin
                                tomasulo.RS_Itype_immediate_value[RS_Itype_found] = {20'b1,immediate_value};
                            end
                            //The below if else conditions is for finding whether there is valid entry of sources in RAT or not
                            // Accordingly writing the entries of RS entry

                            if(tomasulo.register_valid[I_rs1] == 1'b1 && I_rs1 != 5'b0) begin
                                tomasulo.RS_Itype_source1_tag [RS_Itype_found] = 7'b0; // if possible can put 7'bx, should find out whether it is correct keeping like that 
                                tomasulo.RS_Itype_source1_value [RS_Itype_found] = tomasulo.register_file[I_rs1];
                                tomasulo.RS_Itype_valid[RS_Itype_found] = 1'b1;
                            end  

                            else begin
                                if(I_rs1 == 5'b0)begin
                                    tomasulo.RS_Itype_source1_tag [RS_Itype_found] = 7'b0; // if possible can put 7'bx, should find out whether it is correct keeping like that 
                                    tomasulo.RS_Itype_source1_value [RS_Itype_found] = tomasulo.register_file[I_rs1];
                                    tomasulo.RS_Itype_valid[RS_Itype_found] = 1'b1;
                                end
                                else begin
                                    tomasulo.RS_Itype_source1_tag [RS_Itype_found] = tomasulo.register_tag[I_rs1];
                                    tomasulo.RS_Itype_source1_value [RS_Itype_found] = 32'bx; // if possible can put 32'bx
                                    tomasulo.RS_Itype_valid[RS_Itype_found] = 1'b0; 
                                end
                            end

                            // updating in RAT
                            tomasulo.RS_Itype_Dest_tag[RS_Itype_found] = tomasulo.RoB_Tail; // destnation entry in RS
                            tomasulo.register_tag[I_rd] = tomasulo.RoB_Tail; // Tag in RAT
                            tomasulo.register_valid[I_rd] = 1'b0; // 0 means is not valid
 
                            //entering into ROB
                            tomasulo.RoB_busy[tomasulo.RoB_Tail] = 1'b1; // 1 means it is busy
                            tomasulo.RoB_Valid[tomasulo.RoB_Tail] = 1'b0; // 0 means it is invalid
                            tomasulo.RoB_Dest_Addr[tomasulo.RoB_Tail] = I_rd; // Register tag entry in RAT
                            tomasulo.RoB_Dest_Value[tomasulo.RoB_Tail] = 32'bx;  // if possible can put 32'bx
                            tomasulo.RoB_Instruction_Index[tomasulo.RoB_Tail] = tomasulo.Index;
                            tomasulo.RoB_Instruction[tomasulo.RoB_Tail] = funct;
                            tomasulo.RoB_Tail = $unsigned(tomasulo.RoB_Tail + 7'b0000001) % 128;
                            //tomasulo.RoB_Tail = tomasulo.RoB_Tail + 7'b0000001; // Incrementing RoB tail
          
                            // incrementing PC
                            tomasulo.PC = tomasulo.PC + 32'b0000_0000_0000_0000_0000_0000_0000_0001;
         
                            tomasulo.Instruction_state_register[tomasulo.Index] = 3'b001;

                            // incrementing index value
                            tomasulo.Index = tomasulo.Index + 32'b0000_0000_0000_0000_0000_0000_0000_0001;
         
                            // setting few variables used according the code functionality. will be helpful for doing some checks
                            RS_Itype_empty = 1'b0;
                            tomasulo.done_fetch = 1'b0;
                            tomasulo.done_decode = 1'b0;
                            tomasulo.done_issue = 1'b1;    
                            I_type_instruct = 0;
                        end
                    end

                    if (L_type_instruct == 1'b1) begin
                        
                        for (ij = 0 ;(ij < 3);ij = ij + 1 ) begin
                            if (tomasulo.RS_Ltype_busy[ij] == 0) begin
                                RS_Ltype_found = ij;
                                RS_Ltype_empty = 1'b1; // found an empty entry
                                ij = 3;
                            end
                        end

                        if (RS_Ltype_empty != 1'b1) begin
                            tomasulo.need_to_stall = 1'b1;   	
                        end

                        else begin
                            // entering into RS
                            tomasulo.RS_Ltype_busy[RS_Ltype_found] = 1'b1; // setting rs entry busy bit
                            tomasulo.RS_Ltype_instruction[RS_Ltype_found] = funct; // entering type of function in rs entry
                            tomasulo.RS_Ltype_instruction_index[RS_Ltype_found] = tomasulo.Index;
                    
                            //The below if else conditions is for finding whether there is valid entry of sources in RAT or not
                            // Accordingly writing the entries of RS entry

                            if(tomasulo.register_valid[L_rs1] == 1'b1 && L_rs1 != 5'b0) begin
                                tomasulo.RS_Ltype_source1_tag [RS_Ltype_found] = 7'b0; // if possible can put 7'bx, should find out whether it is correct keeping like that 
                                tomasulo.RS_Ltype_source1_value [RS_Ltype_found] = tomasulo.register_file[L_rs1];
                                tomasulo.RS_Ltype_valid[RS_Ltype_found] = 1'b1;
                            end  

                            else begin
                                if(L_rs1 == 5'b0)begin
                                    tomasulo.RS_Ltype_source1_tag [RS_Ltype_found] = 7'b0; // if possible can put 7'bx, should find out whether it is correct keeping like that 
                                    tomasulo.RS_Ltype_source1_value [RS_Ltype_found] = tomasulo.register_file[L_rs1];
                                    tomasulo.RS_Ltype_valid[RS_Ltype_found] = 1'b1;
                                end
                                else begin
                                    tomasulo.RS_Ltype_source1_tag [RS_Ltype_found] = tomasulo.register_tag[L_rs1];
                                    tomasulo.RS_Ltype_source1_value [RS_Ltype_found] = 32'bx; // if possible can put 32'bx
                                    tomasulo.RS_Ltype_valid[RS_Ltype_found] = 1'b0; 
                                end
                            end

                            if (L_offset[11]==0) begin
                                tomasulo.RS_Ltype_immediate_value[RS_Ltype_found] = {20'b0,L_offset};
                            end

                            else begin
                                tomasulo.RS_Ltype_immediate_value[RS_Ltype_found] = {20'b1, L_offset};
                            end

                            // updating in RAT
                            tomasulo.RS_Ltype_Dest_tag[RS_Ltype_found] = tomasulo.RoB_Tail; // destnation entry in RS
                            tomasulo.register_tag[L_rd] = tomasulo.RoB_Tail; // Tag in RAT
                            tomasulo.register_valid[L_rd] = 1'b0; // 0 means is not valid
 
                            //entering into ROB
                            tomasulo.RoB_busy[tomasulo.RoB_Tail] = 1'b1; // 1 means it is busy
                            tomasulo.RoB_Valid[tomasulo.RoB_Tail] = 1'b0; // 0 means it is invalid
                            tomasulo.RoB_Dest_Addr[tomasulo.RoB_Tail] = L_rd; // Register tag entry in RAT
                            tomasulo.RoB_Dest_Value[tomasulo.RoB_Tail] = 32'bx;  // if possible can put 32'bx
                            tomasulo.RoB_Instruction_Index[tomasulo.RoB_Tail] = tomasulo.Index;
                            tomasulo.RoB_Instruction[tomasulo.RoB_Tail] = funct;
                            tomasulo.RoB_Tail = $unsigned(tomasulo.RoB_Tail + 7'b0000001) % 128;
                            //tomasulo.RoB_Tail = tomasulo.RoB_Tail + 7'b0000001; // Incrementing RoB tail
          
                            // incrementing PC
                            tomasulo.PC = tomasulo.PC + 32'b0000_0000_0000_0000_0000_0000_0000_0001;
         
                            tomasulo.Instruction_state_register[tomasulo.Index] = 3'b001;

                            // incrementing index value
                            tomasulo.Index = tomasulo.Index + 32'b0000_0000_0000_0000_0000_0000_0000_0001;
         
                            // setting few variables used according the code functionality. will be helpful for doing some checks
                            RS_Ltype_empty = 1'b0;
                            tomasulo.done_fetch = 1'b0;
                            tomasulo.done_decode = 1'b0;
                            tomasulo.done_issue = 1'b1;    
                            L_type_instruct = 0;
                        end    
                    end

                    if (S_type_instruct == 1) begin
                        $display("Came into S type dispatch unit");
                        //$display("%d", S_rs2);
                        tomasulo.StoreBuffer_IsExe[tomasulo.StoreBuffer_Tail] = 0;
                        tomasulo.StoreBuffer_instruction_index[tomasulo.StoreBuffer_Tail] = tomasulo.Index;
                        tomasulo.StoreBuffer_instruction_type[tomasulo.StoreBuffer_Tail] = funct;
                        tomasulo.StoreBuffer_Dest_tag[tomasulo.StoreBuffer_Tail] = tomasulo.RoB_Tail;
                        
                        if (S_rs1 != 0) begin
                            if(tomasulo.register_valid[S_rs1] == 1)begin
                                $display("SRC1 is valid"); 
                                tomasulo.StoreBuffer_source1_value[tomasulo.StoreBuffer_Tail] = tomasulo.register_file[S_rs1];
                                tomasulo.StoreBuffer_source1_valid_bit[tomasulo.StoreBuffer_Tail] = 1;
                            end
                            else begin
                                $display("SRC1 is not valid"); 
                                tomasulo.StoreBuffer_source1_tag[tomasulo.StoreBuffer_Tail] = tomasulo.register_tag[S_rs1];
                                tomasulo.StoreBuffer_source1_valid_bit[tomasulo.StoreBuffer_Tail] = 0;
                            end
                        end
                        
                        else begin
                            $display("SRC1 is valid and is 0"); 
                            tomasulo.StoreBuffer_source1_value[tomasulo.StoreBuffer_Tail] = tomasulo.register_file[S_rs1];
                            tomasulo.StoreBuffer_source1_valid_bit[tomasulo.StoreBuffer_Tail] = 1;
                        end

                        if (S_rs2 != 0) begin
                            if(tomasulo.register_valid[S_rs2] == 1)begin
                                $display("SRC2 is valid"); 
                                tomasulo.StoreBuffer_source2_value[tomasulo.StoreBuffer_Tail] = tomasulo.register_file[S_rs2];
                                tomasulo.StoreBuffer_source2_valid_bit[tomasulo.StoreBuffer_Tail] = 1;
                            end

                            else begin
                                $display("SRC2 is not valid"); 
                                tomasulo.StoreBuffer_source2_tag[tomasulo.StoreBuffer_Tail] = tomasulo.register_tag[S_rs2];
                                tomasulo.StoreBuffer_source2_valid_bit[tomasulo.StoreBuffer_Tail] = 0;
                            end  
                        end

                        else begin
                            $display("SRC2 is valid and is 0"); 
                            tomasulo.StoreBuffer_source2_value[tomasulo.StoreBuffer_Tail] = tomasulo.register_file[S_rs2];
                            tomasulo.StoreBuffer_source2_valid_bit[tomasulo.StoreBuffer_Tail] = 1;
                        end
                        
                        if (tomasulo.StoreBuffer_source2_valid_bit[tomasulo.StoreBuffer_Tail] == 1 && tomasulo.StoreBuffer_source1_valid_bit[tomasulo.StoreBuffer_Tail] == 1) begin
                            tomasulo.StoreBuffer_Valid[tomasulo.StoreBuffer_Tail] = 1;                            
                        end
                        
                        if (S_offset[11]==0) begin
                            $display("positive offset"); 
                            tomasulo.StoreBuffer_signExtnd[tomasulo.StoreBuffer_Tail] = {20'b0,S_offset};
                        end

                        else begin
                            $display("negative offset"); 
                            tomasulo.StoreBuffer_signExtnd[tomasulo.StoreBuffer_Tail] = {20'b1, S_offset};
                        end
                        //entering into ROB
                        tomasulo.RoB_busy[tomasulo.RoB_Tail] = 1'b1; // 1 means it is busy
                        tomasulo.RoB_Valid[tomasulo.RoB_Tail] = 1'b0; // 0 means it is invalid
                        tomasulo.RoB_Dest_Addr[tomasulo.RoB_Tail] = 7'bx; // nothing will be here, need to think what to put here
                        tomasulo.RoB_Dest_Value[tomasulo.RoB_Tail] = 32'bx;  // if possible can put 32'bx
                        tomasulo.RoB_Instruction_Index[tomasulo.RoB_Tail] = tomasulo.Index;
                        tomasulo.RoB_Instruction[tomasulo.RoB_Tail] = funct;
                        tomasulo.RoB_Tail = $unsigned(tomasulo.RoB_Tail + 7'b0000001) % 128;
                        tomasulo.StoreBuffer_Tail = $unsigned(tomasulo.StoreBuffer_Tail + 7'b0000001) % 128;
                        // incrementing PC
                        tomasulo.PC = tomasulo.PC + 32'b0000_0000_0000_0000_0000_0000_0000_0001;
         
                        tomasulo.Instruction_state_register[tomasulo.Index] = 3'b001;

                        // incrementing index value
                        tomasulo.Index = tomasulo.Index + 32'b0000_0000_0000_0000_0000_0000_0000_0001;
         
                        // setting few variables used according the code functionality. will be helpful for doing some checks
                        tomasulo.done_fetch = 1'b0;
                        tomasulo.done_decode = 1'b0;
                        tomasulo.done_issue = 1'b1;    
                    end
                end
            end
        end
    end
endmodule