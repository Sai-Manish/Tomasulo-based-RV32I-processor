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
    reg B_type_instruct;
    reg J_type_instruct;
    reg J2_type_instruct;
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

    // For J for JAL ///
    reg [4:0] J_rd;
    reg signed [19:0] J_offset;

    // For J for JALR ///
    reg [4:0] J2_rd;
    reg [4:0] J2_rs1;
    reg signed [11:0] J2_offset;

    // For B for Branch ///
    reg [4:0] B_rs1;
    reg [4:0] B_rs2;
    reg signed [11:0] B_offset;


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
        B_type_instruct = 0;
        J_type_instruct = 0;
        J2_type_instruct = 0;
        tomasulo.done_fetch = 1'b0;
        tomasulo.done_decode = 1'b0;
        tomasulo.done_issue = 1'b0;

        if (reset == 0) begin
            instruction_to_be_decoded = {tomasulo.instruction_memory[PC],tomasulo.instruction_memory[PC+32'b00000000000000000000000000000001],tomasulo.instruction_memory[PC+32'b00000000000000000000000000000010],tomasulo.instruction_memory[PC+32'b00000000000000000000000000000011]};
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
                $display("I_rd = %d", I_rd);
  	            I_rs1 = instruction_to_be_decoded[19:15];
                $display("I_rs1 = %d", I_rs1);
  	            immediate_value = instruction_to_be_decoded[31:20];
                $display("I_immediate value = %d", immediate_value);
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
                
                // control signals
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
				
                // control signals
                S_type_instruct = 1;
                tomasulo.done_decode = 1;
            end

            /// JAL ///
            else if (opcode == 7'b1101111) begin
                funct = 6'b000010;
                
                J_rd = instruction_to_be_decoded[11:7];

                J_offset = {instruction_to_be_decoded[31],instruction_to_be_decoded[19:12],instruction_to_be_decoded[20],instruction_to_be_decoded[30:21]};

                // control signals
                J_type_instruct = 1;
                tomasulo.done_decode = 1;

            end

            /// JALR ///
            else if (opcode == 7'b1100111) begin
                funct = 6'b000011;
                
                J2_rd = instruction_to_be_decoded[11:7];

                J2_rs1 = instruction_to_be_decoded[19:15];

                J2_offset = instruction_to_be_decoded[31:20];

                // control signals
                J2_type_instruct = 1;
                tomasulo.done_decode = 1;
            end

            /// Branch instruction ///
            else if (opcode == 7'b1100011) begin
                $display("Decoded Branch");
                if (instruction_to_be_decoded[14:12] == 3'b000) begin
                    funct = 6'b000100; // BEQ
                end

                else if (instruction_to_be_decoded[14:12] == 3'b001) begin
                    funct = 6'b000101; // BNE
                end

                else if (instruction_to_be_decoded[14:12] == 3'b100) begin
                    funct = 6'b000110; // BLT
                end

                else if (instruction_to_be_decoded[14:12] == 3'b101) begin
                    funct = 6'b000111; // BGE
                end

                else if (instruction_to_be_decoded[14:12] == 3'b110) begin
                    funct = 6'b001000; // BLTU
                end
                
                else if (instruction_to_be_decoded[14:12] == 3'b111) begin
                    funct = 6'b001001; // BGEU
                end

                B_rs1 = instruction_to_be_decoded[19:15];
                $display("B_rs1 : %d", B_rs1);
                B_rs2 = instruction_to_be_decoded[24:20];
                $display("B_rs2 : %d", B_rs2);
                B_offset = {instruction_to_be_decoded[31],instruction_to_be_decoded[7],instruction_to_be_decoded[30:25],instruction_to_be_decoded[11:8]};
                $display("B_offset : %d", $signed(B_offset));
                
                // control signals
                B_type_instruct = 1;
                tomasulo.done_decode = 1;
            end
        end
    end

    always @(posedge tomasulo.done_decode) begin

        if(reset==0)begin    

            if (tomasulo.need_to_stall == 1'b0 && tomasulo.stall_due_to_Jtype == 1'b0 && tomasulo.stall_due_to_Btype == 1'b0) begin
                // checking if rob is free or not
                if (tomasulo.RoB_busy[tomasulo.RoB_Tail] == 1'b1) begin

                    if (tomasulo.RoB_Head == 0 && tomasulo.RoB_Tail == 0) begin

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
                                $display("In dispatch stage, R_rs1 is %d", R_rs1);
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
                                $display("In dispatch stage, R_rs2 is %d", R_rs2);
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
                            tomasulo.PC = tomasulo.PC + 32'b0000_0000_0000_0000_0000_0000_0000_0100;
         
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
                            tomasulo.PC = tomasulo.PC + 32'b0000_0000_0000_0000_0000_0000_0000_0100;
         
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
                        $display("Its a load dispatch stage");
                        for (ij = 0 ;(ij < 3);ij = ij + 1 ) begin
                            if (tomasulo.RS_Ltype_busy[ij] == 0) begin
                                RS_Ltype_found = ij;
                                RS_Ltype_empty = 1'b1; // found an empty entry
                                ij = 3;
                            end
                        end

                        if (RS_Ltype_empty != 1'b1) begin
                            tomasulo.need_to_stall = 1'b1;   	
                            $display("Load RS is not free");
                        end

                        else begin
                            // entering into RS
                            $display("Load RS is free, found empty slot");
                            tomasulo.RS_Ltype_busy[RS_Ltype_found] = 1'b1; // setting rs entry busy bit
                            tomasulo.RS_Ltype_instruction[RS_Ltype_found] = funct; // entering type of function in rs entry
                            tomasulo.RS_Ltype_instruction_index[RS_Ltype_found] = tomasulo.Index;
                    
                            //The below if else conditions is for finding whether there is valid entry of sources in RAT or not
                            // Accordingly writing the entries of RS entry

                            $display("load L_rs1 = %d", L_rs1);
                            if(tomasulo.register_valid[L_rs1] == 1'b1 && L_rs1 != 5'b0) begin
                                tomasulo.RS_Ltype_source1_tag [RS_Ltype_found] = 7'b0; // if possible can put 7'bx, should find out whether it is correct keeping like that 
                                tomasulo.RS_Ltype_source1_value [RS_Ltype_found] = tomasulo.register_file[L_rs1];
                                tomasulo.RS_Ltype_valid[RS_Ltype_found] = 1'b1;
                                $display("load L_rs1 = %d is valid", tomasulo.register_valid[L_rs1]);
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
                                    $display("load L_rs1 = %d is not valid", tomasulo.register_valid[L_rs1]);
                                    $display("Source tag is = %d", tomasulo.RS_Ltype_source1_tag [RS_Ltype_found]);
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
                            tomasulo.PC = tomasulo.PC + 32'b0000_0000_0000_0000_0000_0000_0000_0100;
         
                            tomasulo.Instruction_state_register[tomasulo.Index] = 3'b001;

                            // incrementing index value
                            tomasulo.Index = tomasulo.Index + 32'b0000_0000_0000_0000_0000_0000_0000_0001;
         
                            // setting few variables used according the code functionality. will be helpful for doing some checks
                            RS_Ltype_empty = 1'b0;
                            tomasulo.done_fetch = 1'b0;
                            tomasulo.done_decode = 1'b0;
                            tomasulo.done_issue = 1'b1;    
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
                        tomasulo.PC = tomasulo.PC + 32'b0000_0000_0000_0000_0000_0000_0000_0100;
         
                        tomasulo.Instruction_state_register[tomasulo.Index] = 3'b001;

                        // incrementing index value
                        tomasulo.Index = tomasulo.Index + 32'b0000_0000_0000_0000_0000_0000_0000_0001;
         
                        // setting few variables used according the code functionality. will be helpful for doing some checks
                        tomasulo.done_fetch = 1'b0;
                        tomasulo.done_decode = 1'b0;
                        tomasulo.done_issue = 1'b1;    
                    end

                    if (J_type_instruct == 1) begin
                        tomasulo.RoB_busy[tomasulo.RoB_Tail] = 1'b1; // 1 means it is busy
                        tomasulo.RoB_Valid[tomasulo.RoB_Tail] = 1'b1; // 0 means it is invalid
                        tomasulo.RoB_Dest_Addr[tomasulo.RoB_Tail] = J_rd; // storing rd register
                        tomasulo.RoB_Dest_Value[tomasulo.RoB_Tail] = tomasulo.PC + 32'b0000_0000_0000_0000_0000_0000_0000_0100;  // if possible can put 32'bx
                        tomasulo.RoB_Instruction_Index[tomasulo.RoB_Tail] = tomasulo.Index;
                        tomasulo.RoB_Instruction[tomasulo.RoB_Tail] = funct;

                        tomasulo.register_tag[J_rd] = tomasulo.RoB_Tail; // Tag in RAT
                        tomasulo.register_valid[J_rd] = 1'b0; // 0 means is not valid
 
                        tomasulo.RoB_Tail = $unsigned(tomasulo.RoB_Tail + 7'b0000001) % 128;

                        if (J_offset[19] == 1) begin
                            $display("befor JAL PC : %d", tomasulo.PC);
                            $display("offset : %d", J_offset);
                            tomasulo.PC = tomasulo.PC + {12'b111111111111, J_offset};
                            $display("JAL PC : %d", tomasulo.PC);
                        end

                        else if (J_offset[19] == 0) begin
                            tomasulo.PC = tomasulo.PC + {12'b0, J_offset};
                        end

                        tomasulo.Instruction_state_register[tomasulo.Index] = 3'b001;

                        // incrementing index value
                        tomasulo.Index = tomasulo.Index + 32'b0000_0000_0000_0000_0000_0000_0000_0001;
                        tomasulo.done_fetch = 1'b0;
                        tomasulo.done_decode = 1'b0;
                        tomasulo.done_issue = 1'b1; 

                    end

                    if (J2_type_instruct == 1) begin
                        
                        if (tomasulo.register_valid[J2_rs1] == 1) begin
                            if (J2_offset[11] == 0) begin
                                tomasulo.PC = tomasulo.register_file[J2_rs1] + {20'b0, J2_offset}; 
                            end

                            else if (J2_offset[11] == 1) begin
                                tomasulo.PC = tomasulo.register_file[J2_rs1] + {20'b11111111111111111111, J2_offset};
                            end
                            tomasulo.PC[0] = 1'b0;
                        end

                        else if (tomasulo.register_valid[J2_rs1] == 0) begin
                            if (tomasulo.RoB_Valid[tomasulo.register_tag[J2_rs1]] == 1) begin
                                if (J2_offset[11] == 0) begin
                                    tomasulo.PC = tomasulo.RoB_Dest_Value[tomasulo.register_tag[J2_rs1]] + {20'b0, J2_offset};
                                    tomasulo.PC[0] = 1'b0; // newly added this
                                end

                                else if (J2_offset[11] == 1) begin
                                    tomasulo.PC = tomasulo.RoB_Dest_Value[tomasulo.register_tag[J2_rs1]] + {20'b11111111111111111111, J2_offset};
                                    tomasulo.PC[0] = 1'b0;
                                end
                            end

                            else if (tomasulo.RoB_Valid[tomasulo.register_tag[J2_rs1]] == 0) begin
                                tomasulo.stall_due_to_Jtype = 1;
                                tomasulo.PC = tomasulo.PC;
                            end
                        end

                        tomasulo.register_tag[J2_rd] = tomasulo.RoB_Tail; // Tag in RAT
                        tomasulo.register_valid[J2_rd] = 1'b0; // 0 means is not valid
                        
                        tomasulo.RoB_busy[tomasulo.RoB_Tail] = 1'b1; // 1 means it is busy
                        tomasulo.RoB_Valid[tomasulo.RoB_Tail] = 1'b1; // 0 means it is invalid
                        tomasulo.RoB_Dest_Addr[tomasulo.RoB_Tail] = J2_rd; // storing rd register
                        tomasulo.RoB_Dest_Value[tomasulo.RoB_Tail] = tomasulo.PC + 32'b0000_0000_0000_0000_0000_0000_0000_0100;  // if possible can put 32'bx
                        tomasulo.RoB_Instruction_Index[tomasulo.RoB_Tail] = tomasulo.Index;
                        tomasulo.RoB_Instruction[tomasulo.RoB_Tail] = funct;
                        tomasulo.RoB_Tail = $unsigned(tomasulo.RoB_Tail + 7'b0000001) % 128;

                        tomasulo.Instruction_state_register[tomasulo.Index] = 3'b001;
                        // incrementing index value
                        tomasulo.Index = tomasulo.Index + 32'b0000_0000_0000_0000_0000_0000_0000_0001;
                        tomasulo.done_fetch = 1'b0;
                        tomasulo.done_decode = 1'b0;
                        tomasulo.done_issue = 1'b1; 
                    end

                    if (B_type_instruct == 1) begin
                        $display("Came to branch dispatch after decode");
                        $display("In dispatch tomasulo.register_valid[B_rs1] is %d", tomasulo.register_valid[B_rs1]);
                        $display("in dispatch tomasulo.register_valid[B_rs2] is %d", tomasulo.register_valid[B_rs2]);
                        if (((tomasulo.register_valid[B_rs1] == 1) && (tomasulo.register_valid[B_rs2] == 1) && (B_rs1 == 0 || B_rs2 == 0))) begin
                            ///// fast branching /////
                            $display("Fast Branching");
                            if (((funct == 6'b000100) && (tomasulo.register_file[B_rs1] == tomasulo.register_file[B_rs2])) || ((funct == 6'b000101) && (tomasulo.register_file[B_rs1] != tomasulo.register_file[B_rs2])) || ((funct == 6'b000110) && (tomasulo.register_file[B_rs1] < tomasulo.register_file[B_rs2])) || ((funct == 6'b000111) && (tomasulo.register_file[B_rs1] >= tomasulo.register_file[B_rs2])) || ((funct == 6'b001000) && ($unsigned(tomasulo.register_file[B_rs1]) < $unsigned(tomasulo.register_file[B_rs2]))) || ((funct == 6'b001001) && ($unsigned(tomasulo.register_file[B_rs1]) >= $unsigned(tomasulo.register_file[B_rs2])))) begin
                                    
                                if (B_offset[11] == 1) begin
                                    tomasulo.PC = tomasulo.PC + {12'b111111111111, B_offset};   
                                end

                                else if (B_offset[11] == 0) begin
                                    tomasulo.PC = tomasulo.PC + {12'b0, B_offset};
                                end
                            end

                            else begin
                                    
                                tomasulo.PC = tomasulo.PC + 32'b0000_0000_0000_0000_0000_0000_0000_0100;
                            end

                        end

                        else if (((tomasulo.register_valid[B_rs1] == 0) || (tomasulo.register_valid[B_rs2] == 0)) && (B_rs1 == 0 || B_rs2 == 0)) begin
                            $display("Fast Branching");
                            if ((tomasulo.register_valid[B_rs1] == 0) && (tomasulo.register_valid[B_rs2] == 0)) begin
                                if ((tomasulo.RoB_Valid[tomasulo.register_tag[B_rs1]] == 1) && (tomasulo.RoB_Valid[tomasulo.register_tag[B_rs2]] == 1)) begin
                                        
                                    ///// fast branching /////
                                    if (((funct == 6'b000100) && (tomasulo.RoB_Dest_Value[tomasulo.register_tag[B_rs1]] == tomasulo.RoB_Dest_Value[tomasulo.register_tag[B_rs2]])) || ((funct == 6'b000101) && (tomasulo.RoB_Dest_Value[tomasulo.register_tag[B_rs1]] != tomasulo.RoB_Dest_Value[tomasulo.register_tag[B_rs2]])) || ((funct == 6'b000110) && (tomasulo.RoB_Dest_Value[tomasulo.register_tag[B_rs1]] < tomasulo.RoB_Dest_Value[tomasulo.register_tag[B_rs2]])) || ((funct == 6'b000111) && (tomasulo.RoB_Dest_Value[tomasulo.register_tag[B_rs1]] >= tomasulo.RoB_Dest_Value[tomasulo.register_tag[B_rs2]])) || ((funct == 6'b001000) && ($unsigned(tomasulo.RoB_Dest_Value[tomasulo.register_tag[B_rs1]]) < $unsigned(tomasulo.RoB_Dest_Value[tomasulo.register_tag[B_rs2]]))) || ((funct == 6'b001001) && ($unsigned(tomasulo.RoB_Dest_Value[tomasulo.register_tag[B_rs1]]) >= $unsigned(tomasulo.RoB_Dest_Value[tomasulo.register_tag[B_rs2]])))) begin //BEQ
                                        if (B_offset[11] == 1) begin
                                            tomasulo.PC = tomasulo.PC + {12'b111111111111, B_offset};
                                        end

                                        else if (B_offset[11] == 0) begin
                                            tomasulo.PC = tomasulo.PC + {12'b0, B_offset};
                                        end
                                    end
                                        
                                    else begin
                                        tomasulo.PC = tomasulo.PC + 32'b0000_0000_0000_0000_0000_0000_0000_0100;
                                    end

                                end

                                else begin
                                    tomasulo.stall_due_to_Btype = 1;
                                    tomasulo.PC = tomasulo.PC;
                                end
                            end

                            else if (tomasulo.register_valid[B_rs1] == 1 && tomasulo.register_valid[B_rs2] == 0) begin
                                    
                                if (tomasulo.RoB_Valid[tomasulo.register_tag[B_rs2]] == 1) begin
                                    // fast branching
                                    if (((funct == 6'b000100) && (tomasulo.register_file[B_rs1] == tomasulo.RoB_Dest_Value[tomasulo.register_tag[B_rs2]])) || ((funct == 6'b000101) && (tomasulo.register_file[B_rs1] != tomasulo.RoB_Dest_Value[tomasulo.register_tag[B_rs2]])) || ((funct == 6'b000110) && (tomasulo.register_file[B_rs1] < tomasulo.RoB_Dest_Value[tomasulo.register_tag[B_rs2]])) || ((funct == 6'b000111) && (tomasulo.register_file[B_rs1] >= tomasulo.RoB_Dest_Value[tomasulo.register_tag[B_rs2]])) || ((funct == 6'b001000) && ($unsigned(tomasulo.register_file[B_rs1]) < $unsigned(tomasulo.RoB_Dest_Value[tomasulo.register_tag[B_rs2]]))) || ((funct == 6'b001001) && ($unsigned(tomasulo.register_file[B_rs1]) >= $unsigned(tomasulo.RoB_Dest_Value[tomasulo.register_tag[B_rs2]])))) begin //BEQ validating
                                        if (B_offset[11] == 1) begin
                                            tomasulo.PC = tomasulo.PC + {12'b111111111111, B_offset};
                                        end

                                        else if (B_offset[11] == 0) begin
                                            tomasulo.PC = tomasulo.PC + {12'b0, B_offset};
                                        end
                                    end

                                    else begin
                                        tomasulo.PC = tomasulo.PC + 32'b0000_0000_0000_0000_0000_0000_0000_0100;
                                    end
                                end

                                else begin
                                    $display("going to branch stall");
                                    tomasulo.stall_due_to_Btype = 1;
                                    tomasulo.PC = tomasulo.PC;
                                end
                            end

                            else if (tomasulo.register_valid[B_rs1] == 0 && tomasulo.register_valid[B_rs2] == 1) begin
                                if (tomasulo.RoB_Valid[tomasulo.register_tag[B_rs1]] == 1) begin
                                     // fast branching
                                    if (((funct == 6'b000100) && (tomasulo.register_file[B_rs2] == tomasulo.RoB_Dest_Value[tomasulo.register_tag[B_rs1]]))|| ((funct == 6'b000101) && (tomasulo.register_file[B_rs2] != tomasulo.RoB_Dest_Value[tomasulo.register_tag[B_rs1]])) || ((funct == 6'b000110) && (tomasulo.register_file[B_rs2] > tomasulo.RoB_Dest_Value[tomasulo.register_tag[B_rs1]])) || ((funct == 6'b000111) && (tomasulo.register_file[B_rs2] <= tomasulo.RoB_Dest_Value[tomasulo.register_tag[B_rs1]])) || ((funct == 6'b001000) && ($unsigned(tomasulo.register_file[B_rs2]) > $unsigned(tomasulo.RoB_Dest_Value[tomasulo.register_tag[B_rs1]]))) || ((funct == 6'b001001) && ($unsigned(tomasulo.register_file[B_rs2]) <= $unsigned(tomasulo.RoB_Dest_Value[tomasulo.register_tag[B_rs1]])))) begin //BEQ
                                       if (B_offset[11] == 1) begin
                                            tomasulo.PC = tomasulo.PC + {12'b111111111111, B_offset};
                                        end

                                        else if (B_offset[11] == 0) begin
                                            tomasulo.PC = tomasulo.PC + {12'b0, B_offset};
                                        end
                                    end

                                    else begin
                                        tomasulo.PC = tomasulo.PC + 32'b0000_0000_0000_0000_0000_0000_0000_0100;
                                    end
                                end

                                else begin
                                    tomasulo.stall_due_to_Btype = 1;
                                    tomasulo.PC = tomasulo.PC;
                                end 
                            end
                        end

                        if ((B_rs1 == 0 || B_rs2 == 0)) begin
                            if (B_rs1 == 0 && B_rs2 == 0) begin
                                $display("Fast Branching");
                                if (((funct == 6'b000100) && (tomasulo.register_file[B_rs1] == tomasulo.register_file[B_rs2])) || ((funct == 6'b000101) && (tomasulo.register_file[B_rs1] != tomasulo.register_file[B_rs2])) || ((funct == 6'b000110) && (tomasulo.register_file[B_rs1] < tomasulo.register_file[B_rs2])) || ((funct == 6'b000111) && (tomasulo.register_file[B_rs1] >= tomasulo.register_file[B_rs2])) || ((funct == 6'b001000) && ($unsigned(tomasulo.register_file[B_rs1]) < $unsigned(tomasulo.register_file[B_rs2]))) || ((funct == 6'b001001) && ($unsigned(tomasulo.register_file[B_rs1]) >= $unsigned(tomasulo.register_file[B_rs2])))) begin
                                    
                                    if (B_offset[11] == 1) begin
                                        tomasulo.PC = tomasulo.PC + {12'b111111111111, B_offset};   
                                    end

                                    else if (B_offset[11] == 0) begin
                                        tomasulo.PC = tomasulo.PC + {12'b0, B_offset};
                                    end
                                end

                                else begin
                                    
                                    tomasulo.PC = tomasulo.PC + 32'b0000_0000_0000_0000_0000_0000_0000_0100;
                                end
                            end

                            else if (B_rs1 == 0 && B_rs2 != 0) begin
                                if (tomasulo.register_valid[B_rs2] == 1) begin
                                    ///// fast branching /////
                                    $display("Fast Branching");
                                    if (((funct == 6'b000100) && (tomasulo.register_file[B_rs1] == tomasulo.register_file[B_rs2])) || ((funct == 6'b000101) && (tomasulo.register_file[B_rs1] != tomasulo.register_file[B_rs2])) || ((funct == 6'b000110) && (tomasulo.register_file[B_rs1] < tomasulo.register_file[B_rs2])) || ((funct == 6'b000111) && (tomasulo.register_file[B_rs1] >= tomasulo.register_file[B_rs2])) || ((funct == 6'b001000) && ($unsigned(tomasulo.register_file[B_rs1]) < $unsigned(tomasulo.register_file[B_rs2]))) || ((funct == 6'b001001) && ($unsigned(tomasulo.register_file[B_rs1]) >= $unsigned(tomasulo.register_file[B_rs2])))) begin
                                    
                                        if (B_offset[11] == 1) begin
                                            tomasulo.PC = tomasulo.PC + {12'b111111111111, B_offset};   
                                        end

                                        else if (B_offset[11] == 0) begin
                                            tomasulo.PC = tomasulo.PC + {12'b0, B_offset};
                                        end
                                    end

                                    else begin
                                    
                                        tomasulo.PC = tomasulo.PC + 32'b0000_0000_0000_0000_0000_0000_0000_0100;
                                    end

                                end

                                else begin
                                    if (tomasulo.RoB_Valid[tomasulo.register_tag[B_rs2]] == 1) begin
                                        // fast branching
                                        if (((funct == 6'b000100) && (tomasulo.register_file[B_rs1] == tomasulo.RoB_Dest_Value[tomasulo.register_tag[B_rs2]])) || ((funct == 6'b000101) && (tomasulo.register_file[B_rs1] != tomasulo.RoB_Dest_Value[tomasulo.register_tag[B_rs2]])) || ((funct == 6'b000110) && (tomasulo.register_file[B_rs1] < tomasulo.RoB_Dest_Value[tomasulo.register_tag[B_rs2]])) || ((funct == 6'b000111) && (tomasulo.register_file[B_rs1] >= tomasulo.RoB_Dest_Value[tomasulo.register_tag[B_rs2]])) || ((funct == 6'b001000) && ($unsigned(tomasulo.register_file[B_rs1]) < $unsigned(tomasulo.RoB_Dest_Value[tomasulo.register_tag[B_rs2]]))) || ((funct == 6'b001001) && ($unsigned(tomasulo.register_file[B_rs1]) >= $unsigned(tomasulo.RoB_Dest_Value[tomasulo.register_tag[B_rs2]])))) begin //BEQ validating
                                            if (B_offset[11] == 1) begin
                                                tomasulo.PC = tomasulo.PC + {12'b111111111111, B_offset};
                                            end

                                            else if (B_offset[11] == 0) begin
                                                tomasulo.PC = tomasulo.PC + {12'b0, B_offset};
                                            end
                                        end

                                        else begin
                                            tomasulo.PC = tomasulo.PC + 32'b0000_0000_0000_0000_0000_0000_0000_0100;
                                        end
                                    end

                                    else begin
                                        $display("going to branch stall");
                                        tomasulo.stall_due_to_Btype = 1;
                                        tomasulo.PC = tomasulo.PC;
                                    end
                                end
                            end

                            else if (B_rs1 != 0 && B_rs2 == 0) begin
                                if (tomasulo.register_valid[B_rs1] == 1) begin
                                    ///// fast branching /////
                                    $display("Fast Branching");
                                    if (((funct == 6'b000100) && (tomasulo.register_file[B_rs1] == tomasulo.register_file[B_rs2])) || ((funct == 6'b000101) && (tomasulo.register_file[B_rs1] != tomasulo.register_file[B_rs2])) || ((funct == 6'b000110) && (tomasulo.register_file[B_rs1] < tomasulo.register_file[B_rs2])) || ((funct == 6'b000111) && (tomasulo.register_file[B_rs1] >= tomasulo.register_file[B_rs2])) || ((funct == 6'b001000) && ($unsigned(tomasulo.register_file[B_rs1]) < $unsigned(tomasulo.register_file[B_rs2]))) || ((funct == 6'b001001) && ($unsigned(tomasulo.register_file[B_rs1]) >= $unsigned(tomasulo.register_file[B_rs2])))) begin
                                    
                                        if (B_offset[11] == 1) begin
                                            tomasulo.PC = tomasulo.PC + {12'b111111111111, B_offset};   
                                        end

                                        else if (B_offset[11] == 0) begin
                                            tomasulo.PC = tomasulo.PC + {12'b0, B_offset};
                                        end
                                    end

                                    else begin
                                    
                                        tomasulo.PC = tomasulo.PC + 32'b0000_0000_0000_0000_0000_0000_0000_0100;
                                    end

                                end

                                else begin
                                    if (tomasulo.RoB_Valid[tomasulo.register_tag[B_rs1]] == 1) begin
                                        // fast branching
                                        if (((funct == 6'b000100) && (tomasulo.register_file[B_rs2] == tomasulo.RoB_Dest_Value[tomasulo.register_tag[B_rs1]])) || ((funct == 6'b000101) && (tomasulo.register_file[B_rs2] != tomasulo.RoB_Dest_Value[tomasulo.register_tag[B_rs1]])) || ((funct == 6'b000110) && (tomasulo.register_file[B_rs2] > tomasulo.RoB_Dest_Value[tomasulo.register_tag[B_rs1]])) || ((funct == 6'b000111) && (tomasulo.register_file[B_rs2] <= tomasulo.RoB_Dest_Value[tomasulo.register_tag[B_rs1]])) || ((funct == 6'b001000) && ($unsigned(tomasulo.register_file[B_rs2]) > $unsigned(tomasulo.RoB_Dest_Value[tomasulo.register_tag[B_rs1]]))) || ((funct == 6'b001001) && ($unsigned(tomasulo.register_file[B_rs2]) <= $unsigned(tomasulo.RoB_Dest_Value[tomasulo.register_tag[B_rs1]])))) begin //BEQ validating
                                            if (B_offset[11] == 1) begin
                                                tomasulo.PC = tomasulo.PC + {12'b111111111111, B_offset};
                                            end

                                            else if (B_offset[11] == 0) begin
                                                tomasulo.PC = tomasulo.PC + {12'b0, B_offset};
                                            end
                                        end

                                        else begin
                                            tomasulo.PC = tomasulo.PC + 32'b0000_0000_0000_0000_0000_0000_0000_0100;
                                        end
                                    end

                                    else begin
                                        $display("going to branch stall");
                                        tomasulo.stall_due_to_Btype = 1;
                                        tomasulo.PC = tomasulo.PC;
                                    end
                                end
                            end
                        end

                        tomasulo.Instruction_state_register[tomasulo.Index] = 3'b001;
                        // incrementing index value
                        tomasulo.Index = tomasulo.Index + 32'b0000_0000_0000_0000_0000_0000_0000_0001;
                        tomasulo.done_fetch = 1'b0;
                        tomasulo.done_decode = 1'b0;
                        tomasulo.done_issue = 1'b1; 
                    end
                end
            end
            
            if (tomasulo.stall_due_to_Jtype == 1) begin
                $display("Came to stall of JALR");
                if (tomasulo.register_valid[J2_rs1] == 1) begin
                    $display("JALR stall rs1 is valid");
                    $display("PC is %d before adding", tomasulo.PC);
                    if (J2_offset[11] == 0) begin
                        tomasulo.PC = tomasulo.register_file[J2_rs1] + {20'b0, J2_offset}; 
                    end

                    else if (J2_offset[11] == 1) begin
                        tomasulo.PC = tomasulo.register_file[J2_rs1] + {20'b11111111111111111111, J2_offset};
                    end

                    tomasulo.PC[0] = 0;
                    tomasulo.stall_due_to_Jtype = 0;   
                end
                $display("tomasulo.register_file[J2_rs1] = %d",tomasulo.register_file[J2_rs1]);
                $display("J2_offset = %d", J2_offset);
                $display("Need to stall bit = %d", tomasulo.need_to_stall);
                $display("stall_due_to_Jtype = %d", tomasulo.stall_due_to_Jtype);
                $display("PC is %d after adding", tomasulo.PC);
            end

            if (tomasulo.stall_due_to_Btype == 1) begin
                $display("Branch stall block");
                $display("tomasulo.RoB_Valid[tomasulo.register_tag[B_rs1]] is : %d", tomasulo.RoB_Valid[tomasulo.register_tag[B_rs1]]);
                $display("tomasulo.RoB_Valid[tomasulo.register_tag[B_rs2]] is : %d", tomasulo.RoB_Valid[tomasulo.register_tag[B_rs2]]);
                $display("tomasulo.register_valid[B_rs1] is %d", tomasulo.register_valid[B_rs1]);
                $display("tomasulo.register_valid[B_rs2] is %d", tomasulo.register_valid[B_rs2]);
               

                if ((tomasulo.register_valid[B_rs1] == 1 && tomasulo.register_valid[B_rs2] == 1) || (tomasulo.register_valid[B_rs1] == 1 && B_rs2 == 0) || (tomasulo.register_valid[B_rs2] == 1 && B_rs1 == 0)) begin
                    if (((funct == 6'b000100) && (tomasulo.register_file[B_rs1] == tomasulo.register_file[B_rs2])) || ((funct == 6'b000101) && (tomasulo.register_file[B_rs1] != tomasulo.register_file[B_rs2])) || ((funct == 6'b000110) && (tomasulo.register_file[B_rs1] < tomasulo.register_file[B_rs2])) || ((funct == 6'b000111) && (tomasulo.register_file[B_rs1] >= tomasulo.register_file[B_rs2])) || ((funct == 6'b001000) && ($unsigned(tomasulo.register_file[B_rs1]) < $unsigned(tomasulo.register_file[B_rs2]))) || ((funct == 6'b001001) && ($unsigned(tomasulo.register_file[B_rs1]) >= $unsigned(tomasulo.register_file[B_rs2])))) begin 
                        if (B_offset[11] == 1) begin
                            tomasulo.PC = tomasulo.PC + {20'b11111111111111111111, B_offset};
                        end

                        else if (B_offset[11] == 0) begin
                            tomasulo.PC = tomasulo.PC + {20'b0, B_offset};
                        end
                    end

                    else begin
                        tomasulo.PC = tomasulo.PC + 32'b0000_0000_0000_0000_0000_0000_0000_0100;
                    end

                    tomasulo.stall_due_to_Btype = 0;
                    $display("Need to stall bit = %d", tomasulo.need_to_stall);
                    $display("stall_due_to_Btype = %d", tomasulo.stall_due_to_Btype);
                    $display("PC is %d", tomasulo.PC);
          
                end
            end
        end
    end

endmodule