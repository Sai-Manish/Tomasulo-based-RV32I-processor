module To_Execute (
    input clock,
    input reset
);

parameter WIDTH = 32;
parameter R_RS_size = 3;
parameter I_RS_size = 3;
parameter L_RS_size = 3;
parameter S_RS_size = 3;
parameter R_Cycles = 1;
parameter I_Cycles = 1;
parameter L_Cycles = 3;
parameter RoB_size = 128;

integer Temp_Idx_R;
integer Temp_Idx2_R;

integer exe_index_rs;
reg [5:0] is_ex_instruction_R;
reg [WIDTH-1:0] is_ex_instruction_index_R;
reg signed [31:0] is_ex_src1_R;
reg signed [31:0] is_ex_src2_R;
reg [6:0] is_ex_dest_tag_R;
reg signed [31:0] result_R;

integer Temp_Idx_I;
integer Temp_Idx2_I;

integer exe_index_rs_I;
reg [5:0] is_ex_instruction_I;
reg [WIDTH-1:0] is_ex_instruction_index_I;
reg signed [31:0] is_ex_src1_I;
reg signed [11:0] immediate_I;
reg [6:0] is_ex_dest_tag_I;
reg signed [31:0] result_I;

integer Temp_Idx_L;
integer Temp_Idx2_L;

integer exe_index_rs_L;
reg [5:0] is_ex_instruction_L;
reg [WIDTH-1:0] is_ex_instruction_index_L;
reg signed [31:0] is_ex_src1_L;
reg signed [31:0] offset_L;
reg [6:0] is_ex_dest_tag_L;
reg signed [31:0] result_L;
integer ei,ek,pk;
reg Bypassable;
integer matched;
integer latest;

integer Temp_Idx_S;
integer Temp_Idx2_S;
integer exe_index_sb_S;
reg [WIDTH-1:0] is_ex_instruction_index_S;
reg signed [31:0] is_ex_src1_S;
reg signed [31:0] offset_S;
reg [6:0] is_ex_dest_tag_S;
reg [31:0] result_S;
always @(posedge clock) begin
    // need to check if there is valid entry in RS, if there need to send to execute unit
    //tomasulo.is_to_execute = 0;
  Temp_Idx_R = -1;
  Temp_Idx2_R = -1;
  Temp_Idx_I = -1;
  Temp_Idx2_I = -1;
  Temp_Idx_L = -1;
  Temp_Idx2_L = -1;
  Temp_Idx_S = -1;
  Temp_Idx2_S = -1;
  tomasulo.is_to_execute_R = 0; 
  tomasulo.is_to_execute_I = 0;
  tomasulo.is_to_execute_L = 0;
  tomasulo.is_to_execute_S = 0;
  Bypassable = 0;

  if (reset == 0) begin
    for (ei = 0;ei < R_RS_size ;ei = ei + 1) begin
        if (tomasulo.RS_Rtype_valid[ei] == 1) begin
            $display("In start of execute stage, Both source operands are valid - instruction no : %d",tomasulo.RS_Rtype_instruction_index[ei]);
            Temp_Idx_R = tomasulo.RS_Rtype_instruction_index[ei];
            if (Temp_Idx2_R == -1) begin
                Temp_Idx2_R = Temp_Idx_R;
                exe_index_rs = ei;
            end
            else if (Temp_Idx_R < Temp_Idx2_R) begin
                Temp_Idx2_R = Temp_Idx_R;
                exe_index_rs = ei;
            end
        end
    end

    if (Temp_Idx2_R != -1) begin
        $display("Found a instruction which is ready to execute rtype");
        tomasulo.is_to_execute_R = 1;
        $display("will execute execute stage, Both source operands are valid - instruction no : %d",Temp_Idx2_R);

        is_ex_instruction_index_R = Temp_Idx2_R; // index of instruction
        is_ex_instruction_R = tomasulo.RS_Rtype_instruction[exe_index_rs]; // 
        is_ex_src1_R = tomasulo.RS_Rtype_source1_value[exe_index_rs];
        is_ex_src2_R = tomasulo.RS_Rtype_source2_value[exe_index_rs];
        is_ex_dest_tag_R = tomasulo.RS_Rtype_Dest_tag[exe_index_rs];
        
        //Free_RRS_Entry
        tomasulo.RS_Rtype_busy[exe_index_rs] = 1'b0;
		tomasulo.RS_Rtype_valid[exe_index_rs] = 1'b0;  
        tomasulo.RS_Rtype_source1_valid[exe_index_rs] = 1'b0;
        tomasulo.RS_Rtype_source2_valid[exe_index_rs] = 1'b0;
		tomasulo.need_to_stall = 1'b0;
        
    end

    else if (Temp_Idx2_R == -1) begin
        //$display("Found no instruction which is ready to execute rtype");
        tomasulo.is_to_execute_R = 0;
    end

    ///////////////////////// Itype ////////////////////////////
    for (ek = 0;ek < I_RS_size ;ek = ek + 1) begin
        if (tomasulo.RS_Itype_valid[ek] == 1) begin
            Temp_Idx_I = tomasulo.RS_Itype_instruction_index[ek];
            if (Temp_Idx2_I == -1) begin
                Temp_Idx2_I = Temp_Idx_I;
                exe_index_rs_I = ek;
            end
            else if (Temp_Idx_I < Temp_Idx2_I) begin
                Temp_Idx2_I = Temp_Idx_I;
                exe_index_rs_I = ek;
            end
        end
    end

    if (Temp_Idx2_I != -1) begin
        tomasulo.is_to_execute_I = 1;
        is_ex_instruction_index_I = Temp_Idx2_I;
        is_ex_instruction_I = tomasulo.RS_Itype_instruction[exe_index_rs_I];
        is_ex_src1_I = tomasulo.RS_Itype_source1_value[exe_index_rs_I];
        immediate_I = tomasulo.RS_Itype_immediate_value[exe_index_rs_I];
        is_ex_dest_tag_I = tomasulo.RS_Itype_Dest_tag[exe_index_rs_I];
        //Free_IRS_Entry
        
        tomasulo.RS_Itype_busy[exe_index_rs_I] = 1'b0;
		tomasulo.RS_Itype_valid[exe_index_rs_I] = 1'b0;  
		tomasulo.need_to_stall = 1'b0;
        
    end

    else if (Temp_Idx2_I == -1) begin
        tomasulo.is_to_execute_I = 0;
    end

    //// for load //////////
    for (ek = 0;ek < L_RS_size ;ek = ek + 1) begin
        if (tomasulo.RS_Ltype_valid[ek] == 1) begin
            Temp_Idx_L = tomasulo.RS_Ltype_instruction_index[ek];
            if (Temp_Idx2_L == -1) begin
                Temp_Idx2_L = Temp_Idx_L;
                exe_index_rs_L = ek;
            end
            else if (Temp_Idx_L < Temp_Idx2_L) begin
                Temp_Idx2_L = Temp_Idx_L;
                exe_index_rs_L = ek;
            end
        end
    end

    if (Temp_Idx2_L != -1) begin
        
        Bypassable = 1;
        // the below if condition tells that store buffer is empty
        if (tomasulo.StoreBuffer_Tail == tomasulo.StoreBuffer_Head && tomasulo.StoreBuffer_IsExe[tomasulo.StoreBuffer_Tail] == 0) begin
            Bypassable = 1;
        end

        else begin
            if (tomasulo.StoreBuffer_Head < tomasulo.StoreBuffer_Tail) begin
                for (ek = tomasulo.StoreBuffer_Head; ek < tomasulo.StoreBuffer_Tail ; ek++) begin
                    if (tomasulo.StoreBuffer_IsExe[ek] != 1) begin
                        Bypassable = 0;
                        ek = tomasulo.StoreBuffer_Tail;
                    end
                end
            end

            if (tomasulo.StoreBuffer_Head > tomasulo.StoreBuffer_Tail) begin
                for (ek = tomasulo.StoreBuffer_Tail ; ek < 128 ; ek++ ) begin
                    if (tomasulo.StoreBuffer_IsExe[ek] != 1) begin
                        Bypassable = 0;
                        ek = 128;
                    end
                end
                for (ek = 0;ek < tomasulo.StoreBuffer_Tail ; ek++ ) begin
                    if (tomasulo.StoreBuffer_IsExe[ek] != 1) begin
                        Bypassable = 0;
                        ek = tomasulo.StoreBuffer_Tail;
                    end
                end
            end
        end

        if (Bypassable) begin
            matched = 0; // if true/1 tells about if there is a store address match
            latest = 0; // tell about which is the store address that is matching to load
            if (tomasulo.StoreBuffer_Tail == tomasulo.StoreBuffer_Head && tomasulo.StoreBuffer_IsExe[tomasulo.StoreBuffer_Tail] == 0) begin
                matched = 0;
                latest = 0;
            end

            else begin
                if (tomasulo.StoreBuffer_Head < tomasulo.StoreBuffer_Tail) begin
                    for (ek = tomasulo.StoreBuffer_Head; ek < tomasulo.StoreBuffer_Tail ; ek++) begin
                        if (tomasulo.StoreBuffer_instruction_index[ek] < tomasulo.RS_Ltype_instruction_index[Temp_Idx2_L]) begin // checking store which are previous current load
                            if (tomasulo.RS_Ltype_source1_value[Temp_Idx2_L] + tomasulo.RS_Ltype_immediate_value[Temp_Idx2_L] == tomasulo.StoreBuffer_MemoryAccessAddr[ek]) begin
                                matched = 1;
                                if (ek > latest) begin
                                    latest = ek;
                                end
                            end
                        end
                    end
                end

                if (tomasulo.StoreBuffer_Head > tomasulo.StoreBuffer_Tail) begin
                    for (ek = tomasulo.StoreBuffer_Tail ; ek < 128 ; ek++ ) begin
                        if (tomasulo.StoreBuffer_instruction_index[ek] < tomasulo.RS_Ltype_instruction_index[Temp_Idx2_L]) begin // checking store which are previous current load
                            if (tomasulo.RS_Ltype_source1_value[Temp_Idx2_L] + tomasulo.RS_Ltype_immediate_value[Temp_Idx2_L] == tomasulo.StoreBuffer_MemoryAccessAddr[ek]) begin
                                matched = 1;
                                if (ek > latest) begin
                                    latest = ek;
                                end
                            end
                        end
                    end
                    for (ek = 0;ek < tomasulo.StoreBuffer_Tail ; ek++ ) begin
                        if (tomasulo.StoreBuffer_instruction_index[ek] < tomasulo.RS_Ltype_instruction_index[Temp_Idx2_L]) begin // checking store which are previous current load
                            if (tomasulo.RS_Ltype_source1_value[Temp_Idx2_L] + tomasulo.RS_Ltype_immediate_value[Temp_Idx2_L] == tomasulo.StoreBuffer_MemoryAccessAddr[ek]) begin
                                matched = 1;
                                if (ek > latest) begin
                                    latest = ek;
                                end
                            end
                        end
                    end
                end
            end
        end

        if((matched == 1 && tomasulo.StoreBuffer_source2_valid_bit[latest] == 1) || (matched == 0 && tomasulo.bus_busy_with_load == 0 && tomasulo.bus_busy_with_store == 0)) begin	
            is_ex_instruction_index_L = Temp_Idx2_L;
            is_ex_instruction_L = tomasulo.RS_Ltype_instruction[exe_index_rs_L];
            is_ex_src1_L = tomasulo.RS_Ltype_source1_value[exe_index_rs_L];
            offset_L = tomasulo.RS_Ltype_immediate_value[exe_index_rs_L];
            is_ex_dest_tag_L = tomasulo.RS_Ltype_Dest_tag[exe_index_rs_L];
            //Free_LRS_Entry
            tomasulo.RS_Ltype_busy[exe_index_rs_L] = 1'b0;
		    tomasulo.RS_Ltype_valid[exe_index_rs_L] = 1'b0; 
            tomasulo.Execute_cycles[is_ex_dest_tag_L] = 3; 
		    tomasulo.need_to_stall = 1'b0;		
			if(matched == 1 && tomasulo.StoreBuffer_source2_valid_bit[latest] == 1) begin
				tomasulo.Execute_cycles[is_ex_dest_tag_L] = 1; //modifying entry in XSCycles
                $display("Came to modified load in exececute in TE");
			end
					
			if(matched == 0 && tomasulo.bus_busy_with_load == 0 && tomasulo.bus_busy_with_store == 0) begin
				tomasulo.bus_busy_with_load = 1;
                
                $display("match not found");
			end
					
			tomasulo.is_to_execute_L = 1;
			//tomasulo.Instruction_state_register[is_ex_instruction_index_L] = 3'b010;
		end
    end

    else if (Temp_Idx2_L == -1) begin
        tomasulo.is_to_execute_L = 0;
    end

    ///////////// for store ////////////////
    if (tomasulo.StoreBuffer_Tail == tomasulo.StoreBuffer_Head && tomasulo.StoreBuffer_IsExe[tomasulo.StoreBuffer_Tail] == 0) begin
        // do nothing
        tomasulo.is_to_execute_S = 0;
    end

    else begin
        if (tomasulo.StoreBuffer_Head < tomasulo.StoreBuffer_Tail) begin
            for (ek = tomasulo.StoreBuffer_Head; ek < tomasulo.StoreBuffer_Tail ; ek++) begin
                if (tomasulo.StoreBuffer_IsExe[ek] == 0) begin
                    if (tomasulo.StoreBuffer_Valid[ek] == 1) begin
                       Temp_Idx_S = tomasulo.StoreBuffer_instruction_index[ek];
                        if (Temp_Idx2_S == -1) begin
                            Temp_Idx2_S = Temp_Idx_S;
                            exe_index_sb_S = ek;
                        end
                        else if (Temp_Idx_S < Temp_Idx2_S) begin
                            Temp_Idx2_S = Temp_Idx_S;
                            exe_index_sb_S = ek;
                        end 
                    end
                end
            end
        end

        if (tomasulo.StoreBuffer_Head > tomasulo.StoreBuffer_Tail) begin
            for (ek = tomasulo.StoreBuffer_Tail ; ek < 128 ; ek = ek +1 ) begin
                if (tomasulo.StoreBuffer_IsExe[ek] == 0) begin
                    if (tomasulo.StoreBuffer_Valid[ek] == 1) begin
                       Temp_Idx_S = tomasulo.StoreBuffer_instruction_index[ek];
                        if (Temp_Idx2_S == -1) begin
                            Temp_Idx2_S = Temp_Idx_S;
                            exe_index_sb_S = ek;
                        end
                        else if (Temp_Idx_S < Temp_Idx2_S) begin
                            Temp_Idx2_S = Temp_Idx_S;
                            exe_index_sb_S = ek;
                        end 
                    end
                end
            end

            for (ek = 0;ek < tomasulo.StoreBuffer_Tail ; ek = ek +1 ) begin
                if (tomasulo.StoreBuffer_IsExe[ek] == 0) begin
                    if (tomasulo.StoreBuffer_Valid[ek] == 1) begin
                       Temp_Idx_S = tomasulo.StoreBuffer_instruction_index[ek];
                        if (Temp_Idx2_S == -1) begin
                            Temp_Idx2_S = Temp_Idx_S;
                            exe_index_sb_S = ek;
                        end
                        else if (Temp_Idx_S < Temp_Idx2_S) begin
                            Temp_Idx2_S = Temp_Idx_S;
                            exe_index_sb_S = ek;
                        end 
                    end
                end
            end
        end

        if (Temp_Idx2_S != -1) begin
            tomasulo.is_to_execute_S = 1;
            is_ex_instruction_index_S = Temp_Idx2_S;
            is_ex_src1_S = tomasulo.StoreBuffer_source1_value[exe_index_sb_S];
            offset_S = tomasulo.StoreBuffer_signExtnd[exe_index_sb_S];
            is_ex_dest_tag_S = tomasulo.StoreBuffer_Dest_tag[exe_index_sb_S];
            //tomasulo.Instruction_state_register[is_ex_instruction_index_S] = 3'b010;
        end
    end
   end
end

//Rtype_FUnit RFU(clock,is_to_execute,is_ex_instruction,is_ex_src1,is_ex_src2,is_ex_dest_tag);
always @(posedge tomasulo.is_to_execute_R)begin
    tomasulo.done_execute_R = 0; 
   //$display("some instruction came to instruction unit");
    if (is_ex_instruction_R == 6'b011011)begin // ADD
        result_R = is_ex_src1_R + is_ex_src2_R; // overflow are ignored
        tomasulo.done_execute_R = 1; 
    end

    else if (is_ex_instruction_R == 6'b011100) begin // SUB
        result_R = is_ex_src1_R - is_ex_src2_R;  // overflow are ignored
        tomasulo.done_execute_R = 1; 
    end

    else if (is_ex_instruction_R ==  6'b100000) begin // XOR
        result_R = is_ex_src1_R ^ is_ex_src2_R;
        tomasulo.done_execute_R = 1;   
    end

    else if (is_ex_instruction_R == 6'b100011) begin // OR
        result_R = is_ex_src1_R | is_ex_src2_R;
        tomasulo.done_execute_R = 1;   
    end

    else if (is_ex_instruction_R ==  6'b100100) begin // AND
        result_R = is_ex_src1_R & is_ex_src2_R;  
        tomasulo.done_execute_R = 1; 
    end

    else if (is_ex_instruction_R ==  6'b011101) begin // SLL
        result_R = is_ex_src1_R << is_ex_src2_R[4:0]; 
        tomasulo.done_execute_R = 1;  
    end

    else if (is_ex_instruction_R == 6'b100001) begin // SRL
        result_R = is_ex_src1_R >> is_ex_src2_R[4:0];
        tomasulo.done_execute_R = 1; 
    end

    else if (is_ex_instruction_R == 6'b100010) begin // SRA
        result_R = is_ex_src1_R >>> is_ex_src2_R[4:0];
        tomasulo.done_execute_R = 1; 
    end

    else if (is_ex_instruction_R == 6'b011110) begin // SLT
        if((is_ex_src1_R) < (is_ex_src2_R))begin
            result_R = 32'b0000_0000_0000_0000_0000_0000_0000_0001;
            tomasulo.done_execute_R = 1; 
        end

        else begin
            result_R = 32'b0;
            tomasulo.done_execute_R = 1; 
        end
    end

    else if (is_ex_instruction_R == 6'b011111) begin // SLTU
        if($unsigned(is_ex_src1_R) < $unsigned(is_ex_src2_R))begin
            result_R = 32'b0000_0000_0000_0000_0000_0000_0000_0001;
            tomasulo.done_execute_R = 1; 
        end

        else begin
            result_R = 32'b0;
            tomasulo.done_execute_R = 1; 
        end
    end
end

///////////////////////////////////////////////////// FOR ITYPE /////////////////////////////////////////////////////////////////////////

//Itype_FUnit 
always @(posedge tomasulo.is_to_execute_I)begin
   tomasulo.done_execute_I = 0;
    if (is_ex_instruction_I == 6'b010010)begin // ADDI
      result_I = is_ex_src1_I + immediate_I; // overflow are ignored
      tomasulo.done_execute_I = 1; 
    end

    else if (is_ex_instruction_I == 6'b010011) begin // SLTI
        if((is_ex_src1_I) < (immediate_I))begin
            result_I = 32'b0000_0000_0000_0000_0000_0000_0000_0001;
            tomasulo.done_execute_I = 1; 
        end

        else begin
            result_I = 32'b0;
            tomasulo.done_execute_I = 1; 
        end
    end

    else if (is_ex_instruction_I == 6'b010100) begin // SLTIU
        if($unsigned(is_ex_src1_I) < $unsigned(immediate_I))begin
            result_I = 32'b0000_0000_0000_0000_0000_0000_0000_0001;
            tomasulo.done_execute_I = 1; 
        end

        else begin
            result_I = 32'b0;
            tomasulo.done_execute_I = 1; 
        end
    end
    else if (is_ex_instruction_I == 6'b010101) begin // XORI
        result_I = is_ex_src1_I ^ immediate_I;  
        tomasulo.done_execute_I = 1; 
    end

    else if (is_ex_instruction_I ==  6'b010110) begin // ORI
        result_I = is_ex_src1_I | immediate_I;  
        tomasulo.done_execute_I = 1; 
    end

    else if (is_ex_instruction_I == 6'b010111) begin // ANDI
        result_I = is_ex_src1_I & immediate_I;  
        tomasulo.done_execute_I = 1; 
    end

    else if (is_ex_instruction_I ==  6'b011000) begin // SLLI
        result_I = is_ex_src1_I << immediate_I[4:0];  
        tomasulo.done_execute_I = 1; 
    end

    else if (is_ex_instruction_I == 6'b011001) begin // SRLI
        result_I = is_ex_src1_I >> immediate_I[4:0];
        tomasulo.done_execute_I = 1; 
    end

    else if (is_ex_instruction_I == 6'b011010) begin // SRAI
        result_I = is_ex_src1_I >>> immediate_I[4:0];
        tomasulo.done_execute_I = 1; 
    end

end

/////////////////////////////////////////////// Ltype //////////////////////////////
always @(posedge tomasulo.is_to_execute_L) begin
    tomasulo.done_execute_L = 0;
    $display("In load execute stage");
    if(is_ex_instruction_L == 6'b001010) begin
		//LB
		if(matched) begin
			//load forwarding
			if(tomasulo.StoreBuffer_source2_value[latest][7] == 0) begin
				result_L = {24'b0, tomasulo.StoreBuffer_source2_value[latest][7:0]};
			end
			else begin
				result_L = {24'b111111111111111111111111, tomasulo.StoreBuffer_source2_value[latest][7:0]};
			end				
		end
		else begin
			if(tomasulo.Data_Memory[is_ex_src1_L + offset_L][7] == 0) begin
				result_L = {24'b0, tomasulo.Data_Memory[is_ex_src1_L + offset_L]};
			end
			else begin
				result_L = {24'b111111111111111111111111, tomasulo.Data_Memory[is_ex_src1_L + offset_L]};
			end
		end
			
		tomasulo.done_execute_L = 1;
	end
    
    else if (is_ex_instruction_L == 6'b001011) begin
        //LH
		if(matched) begin
			//load forwarding
			if(tomasulo.StoreBuffer_source2_value[latest][15] == 0) begin
				result_L = {16'b0, tomasulo.StoreBuffer_source2_value[latest][15:0]};
			end
			else begin
				result_L = {16'b1, tomasulo.StoreBuffer_source2_value[latest][15:0]};
			end				
		end
		else begin
			if(tomasulo.Data_Memory[is_ex_src1_L + offset_L][7] == 0) begin
				result_L = {16'b0, tomasulo.Data_Memory[is_ex_src1_L + offset_L + 1],tomasulo.Data_Memory[is_ex_src1_L + offset_L]};
			end
			else begin
				result_L = {16'b1, tomasulo.Data_Memory[is_ex_src1_L + offset_L + 1],tomasulo.Data_Memory[is_ex_src1_L + offset_L]};
			end
		end
			
		tomasulo.done_execute_L = 1;
    end

    else if (is_ex_instruction_L == 6'b001100) begin
        //LW
        $display("Its a lw insruction");
		if(matched) begin
			//load forwarding
            result_L = tomasulo.StoreBuffer_source2_value[latest];	
		end
		else begin
            $display("no match found so getting from memory");
            result_L = {tomasulo.Data_Memory[is_ex_src1_L + offset_L + 3],tomasulo.Data_Memory[is_ex_src1_L + offset_L + 2],tomasulo.Data_Memory[is_ex_src1_L + offset_L + 1],tomasulo.Data_Memory[is_ex_src1_L + offset_L]};
		end
			
		tomasulo.done_execute_L = 1;
    end

    else if(is_ex_instruction_L == 6'b001101) begin
		//LBU
		if(matched) begin
			//load forwarding
            result_L = {24'b0, tomasulo.StoreBuffer_source2_value[latest][7:0]};				
		end
		else begin
            result_L = {24'b0, tomasulo.Data_Memory[is_ex_src1_L + offset_L]};

		end
		tomasulo.done_execute_L = 1;
	end
    
    else if (is_ex_instruction_index_L == 6'b001101) begin
        //LHU
		if(matched) begin
			//load forwarding
            result_L = {16'b0, tomasulo.StoreBuffer_source2_value[latest][15:0]};

		end
		else begin
            result_L = {16'b0, tomasulo.Data_Memory[is_ex_src1_L + offset_L + 1],tomasulo.Data_Memory[is_ex_src1_L + offset_L]};
		end	
		tomasulo.done_execute_L = 1;
    end

end

//////////////////////////////////////// For S type ///////////////////////////////
always @(posedge tomasulo.is_to_execute_S) begin
    $display("executing store now....");
    tomasulo.done_execute_S = 0;
    result_S = is_ex_src1_S + offset_S;
    tomasulo.done_execute_S = 1;
end

//////////////////////////////////////////////
always @(posedge tomasulo.done_execute_I) begin
    tomasulo.Instruction_state_register[is_ex_instruction_index_I] = 3'b010;
    //tomasulo.Execute_dest_tag[is_ex_dest_tag_I] = is_ex_dest_tag_I;
    tomasulo.Execute_Instruction_Index[is_ex_dest_tag_I] = is_ex_instruction_index_I;
    tomasulo.Execute_result[is_ex_dest_tag_I] = result_I;
    tomasulo.Execute_valid[is_ex_dest_tag_I] = 1'b1;
    tomasulo.Execute_cycles[is_ex_dest_tag_I] = I_Cycles;
end

always @(posedge tomasulo.done_execute_R) begin
    tomasulo.Instruction_state_register[is_ex_instruction_index_R] = 3'b010;
    tomasulo.Execute_Instruction_Index[is_ex_dest_tag_R] = is_ex_instruction_index_R;
    //tomasulo.Execute_dest_tag_R = is_ex_dest_tag_R;
    tomasulo.Execute_result[is_ex_dest_tag_R] = result_R;
    tomasulo.Execute_valid[is_ex_dest_tag_R] = 1'b1;  
    tomasulo.Execute_cycles[is_ex_dest_tag_R] = R_Cycles;
end

always @(posedge tomasulo.done_execute_L) begin
    tomasulo.Instruction_state_register[is_ex_instruction_index_L] = 3'b010;
    //tomasulo.Execute_dest_tag[is_ex_dest_tag_I] = is_ex_dest_tag_I;
    tomasulo.Execute_Instruction_Index[is_ex_dest_tag_L] = is_ex_instruction_index_L;
    tomasulo.Execute_result[is_ex_dest_tag_L] = result_L;
    tomasulo.Execute_valid[is_ex_dest_tag_L] = 1'b1;
    //tomasulo.Execute_cycles[is_ex_dest_tag_L] = L_Cycles;
    
end

always @(posedge tomasulo.done_execute_S) begin
    $display("Done with store execute");
    tomasulo.Instruction_state_register[is_ex_instruction_index_S] = 3'b010;
    tomasulo.StoreBuffer_IsExe[exe_index_sb_S] = 1;
    tomasulo.StoreBuffer_MemoryAccessAddr[exe_index_sb_S] = result_S;
    tomasulo.Execute_valid[is_ex_dest_tag_S] = 1'b1;
    tomasulo.Execute_result[is_ex_dest_tag_S] = result_S;
    tomasulo.Execute_Instruction_Index[is_ex_dest_tag_S] = is_ex_instruction_index_S;
end

endmodule