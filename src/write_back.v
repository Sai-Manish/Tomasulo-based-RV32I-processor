module Write_Back (
    input clock,
    input reset
);

parameter WIDTH = 32;
parameter R_RS_size = 3;
parameter I_RS_size = 3;
parameter L_RS_size = 3;
parameter RoB_size = 128;
integer ej,ek,eg,pj,pg;

always @(posedge clock) begin
    tomasulo.start_write_back = 0;
    if ((tomasulo.RoB_Head == tomasulo.RoB_Tail) && tomasulo.RoB_busy[tomasulo.RoB_Tail] == 0) begin
        // do nothing as RoB is empty
        tomasulo.start_write_back = 0;
    end

    else begin
        if (tomasulo.RoB_Head < tomasulo.RoB_Tail) begin
            for (ej = tomasulo.RoB_Head ; ej < tomasulo.RoB_Tail ; ej = ej + 1 ) begin
                if (tomasulo.Execute_valid[ej]) begin
                    if (tomasulo.Execute_cycles[ej] != 0) begin
                        //$display("%d", ej);
                        $display("%d",tomasulo.Execute_cycles[ej]);
                        tomasulo.Execute_cycles[ej] = tomasulo.Execute_cycles[ej] -  1;
                    end
                    
                    if (tomasulo.Execute_cycles[ej] == 0) begin
                        $display("cycles is %d and ej is %d",tomasulo.Execute_cycles[ej],ej);
                        if ((tomasulo.RoB_Instruction[ej] == 6'b001010 || tomasulo.RoB_Instruction[ej] == 6'b001011 || tomasulo.RoB_Instruction[ej] == 6'b001100 || tomasulo.RoB_Instruction[ej] == 6'b001101 || tomasulo.RoB_Instruction[ej] == 6'b001110 ) && tomasulo.bus_busy_with_load) begin
                            $display("It was a load in write back");
                            tomasulo.bus_busy_with_load = 0;
                        end

                        if (tomasulo.RoB_Instruction[ej] == 6'b001111 || tomasulo.RoB_Instruction[ej] == 6'b010000 || tomasulo.RoB_Instruction[ej] == 6'b010001) begin
                            $display("Came to wb stage for store");
                            tomasulo.Execute_cycles[ej] = tomasulo.Store_Cycles;
                            tomasulo.Execute_valid[ej] = 1'b0;
                        end
                        tomasulo.CDB_result[ej] = tomasulo.Execute_result[ej];
                        tomasulo.CDB_valid[ej] = 1'b1;
                        tomasulo.CDB_Instruction_Index[ej] = tomasulo.Execute_Instruction_Index[ej];
                        tomasulo.Execute_valid[ej] = 1'b0;
                        tomasulo.Instruction_state_register[tomasulo.RoB_Instruction_Index[ej]] = 3'b011;
                        // different things will come for store
                    end
                end
            end        
        end

        if (tomasulo.RoB_Head >= tomasulo.RoB_Tail) begin
            for (ek = tomasulo.RoB_Tail; ek < tomasulo.RoB_Head ; ek = ek + 1 ) begin
                if (tomasulo.Execute_valid[ek]) begin
                    if (tomasulo.Execute_cycles[ek] != 0) begin
                        tomasulo.Execute_cycles[ek] = tomasulo.Execute_cycles[ek] -  1;
                    end

                    if (tomasulo.Execute_cycles[ek] == 0) begin
                        
                        if ((tomasulo.RoB_Instruction[ej] == 6'b001010 || tomasulo.RoB_Instruction[ej] == 6'b001011 || tomasulo.RoB_Instruction[ej] == 6'b001100 || tomasulo.RoB_Instruction[ej] == 6'b001101 || tomasulo.RoB_Instruction[ej] == 6'b001110 ) && tomasulo.bus_busy_with_load) begin
                            tomasulo.bus_busy_with_load = 0;
                        end

                        if (tomasulo.RoB_Instruction[ej] == 6'b001111 || tomasulo.RoB_Instruction[ej] == 6'b010000 || tomasulo.RoB_Instruction[ej] == 6'b010001) begin
                            $display("Came to wb stage for store2");
                            tomasulo.Execute_cycles[ej] = tomasulo.Store_Cycles;
                            tomasulo.Execute_valid[ek] = 0;
                        end

                        tomasulo.CDB_result[ek] = tomasulo.Execute_result[ek];
                        tomasulo.CDB_valid[ek] = 1'b1;
                        tomasulo.CDB_Instruction_Index[ek] = tomasulo.Execute_Instruction_Index[ek];
                        tomasulo.Execute_valid[ek] = 0;
                        tomasulo.Instruction_state_register[tomasulo.RoB_Instruction_Index[ek]] = 3'b011;
                        // different things will come for store
                    end
                end
            end

            for (ek = 0; ek < tomasulo.RoB_Tail ; ek=ek+1 ) begin
                if (tomasulo.Execute_valid[ek]) begin
                   if (tomasulo.Execute_cycles[ek] != 0) begin
                        tomasulo.Execute_cycles[ek] = tomasulo.Execute_cycles[ek] -  1;
                    end
                    if (tomasulo.Execute_cycles[ek] == 0) begin
                        if ((tomasulo.RoB_Instruction[ej] == 6'b001010 || tomasulo.RoB_Instruction[ej] == 6'b001011 || tomasulo.RoB_Instruction[ej] == 6'b001100 || tomasulo.RoB_Instruction[ej] == 6'b001101 || tomasulo.RoB_Instruction[ej] == 6'b001110 ) && tomasulo.bus_busy_with_load) begin
                            tomasulo.bus_busy_with_load = 0;
                        end

                        if (tomasulo.RoB_Instruction[ej] == 6'b001111 || tomasulo.RoB_Instruction[ej] == 6'b010000 || tomasulo.RoB_Instruction[ej] == 6'b010001) begin
                            $display("Came to execute stage for store3");
                            tomasulo.Execute_cycles[ej] = tomasulo.Store_Cycles;
                        end

                        tomasulo.CDB_result[ek] = tomasulo.Execute_result[ek];
                        tomasulo.CDB_valid[ek] = 1'b1;
                        tomasulo.CDB_Instruction_Index[ek] = tomasulo.Execute_Instruction_Index[ek];
                        tomasulo.Execute_valid[ek] = 1'b0;
                        tomasulo.Instruction_state_register[tomasulo.RoB_Instruction_Index[ek]] = 3'b011;
                        // different things will come for store
                    end
                end
            end
        end
    end
    
    @(negedge clock);
    ///////////////// write back to RS1 or Rtype //////////////////
    for (eg = 0 ; eg < R_RS_size ; eg = eg + 1 ) begin
        if(tomasulo.RS_Rtype_busy[eg] == 1) begin
            if (tomasulo.RS_Rtype_source1_valid[eg] == 0) begin
                if (tomasulo.CDB_valid[tomasulo.RS_Rtype_source1_tag[eg]]) begin
                    tomasulo.RS_Rtype_source1_value[eg] = tomasulo.CDB_result[tomasulo.RS_Rtype_source1_tag[eg]];
                    tomasulo.RS_Rtype_source1_valid[eg] = 1;
                end
            end

            if (tomasulo.RS_Rtype_source2_valid[eg] == 0) begin 
                if (tomasulo.CDB_valid[tomasulo.RS_Rtype_source2_tag[eg]]) begin
                    tomasulo.RS_Rtype_source2_value[eg] = tomasulo.CDB_result[tomasulo.RS_Rtype_source2_tag[eg]];
                    tomasulo.RS_Rtype_source2_valid[eg] = 1;
                end
            end

            if (tomasulo.RS_Rtype_source1_valid[eg] == 1 && tomasulo.RS_Rtype_source2_valid[eg] == 1) begin
                tomasulo.RS_Rtype_valid[eg] = 1;
            end
        end
    end

    ///////////////////// Write back to RS2 or Itype ////////////////
    for (pg = 0 ; pg < I_RS_size ; pg = pg + 1 ) begin
        if(tomasulo.RS_Itype_busy[pg] == 1) begin
            if (tomasulo.RS_Itype_valid[pg] == 0) begin
                if (tomasulo.CDB_valid[tomasulo.RS_Itype_source1_tag[pg]]) begin
                    tomasulo.RS_Itype_source1_value[pg] = tomasulo.CDB_result[tomasulo.RS_Itype_source1_tag[pg]];
                    tomasulo.RS_Itype_valid[pg] = 1;
                end
            end
        end
    end
    
    ///////////////////// Write back to Load RS ///////////////////
    for (pg = 0 ; pg < L_RS_size ; pg = pg + 1 ) begin
        if(tomasulo.RS_Ltype_busy[pg] == 1) begin
            if (tomasulo.RS_Ltype_valid[pg] == 0) begin
                if (tomasulo.CDB_valid[tomasulo.RS_Ltype_source1_tag[pg]]) begin
                    tomasulo.RS_Ltype_source1_value[pg] = tomasulo.CDB_result[tomasulo.RS_Ltype_source1_tag[pg]];
                    tomasulo.RS_Ltype_valid[pg] = 1;
                end
            end
        end
    end

    ///////////////////// Write back to store buffer ///////////////////////
    if (tomasulo.StoreBuffer_Tail == tomasulo.StoreBuffer_Head && tomasulo.StoreBuffer_IsExe[tomasulo.StoreBuffer_Tail] == 0) begin
        // do nothing as store buffer is empty
        tomasulo.start_write_back = 0;
    end

    else begin
        if (tomasulo.StoreBuffer_Head < tomasulo.StoreBuffer_Tail) begin
            for (ek = tomasulo.StoreBuffer_Head; ek < tomasulo.StoreBuffer_Tail ; ek++) begin
                if (tomasulo.CDB_valid[tomasulo.StoreBuffer_source1_tag[ek]]) begin
                    if (tomasulo.StoreBuffer_source1_valid_bit[ek] == 0) begin
                       tomasulo.StoreBuffer_source1_value[ek] = tomasulo.CDB_result[tomasulo.StoreBuffer_source1_tag[ek]];
                       tomasulo.StoreBuffer_source1_valid_bit[ek] = 1;
                    end
                end
                if (tomasulo.CDB_valid[tomasulo.StoreBuffer_source2_tag[ek]]) begin
                    if (tomasulo.StoreBuffer_source2_valid_bit[ek] == 0) begin
                       tomasulo.StoreBuffer_source2_value[ek] = tomasulo.CDB_result[tomasulo.StoreBuffer_source2_tag[ek]];
                       tomasulo.StoreBuffer_source2_valid_bit[ek] = 1;
                    end
                end

                if ((tomasulo.StoreBuffer_source2_valid_bit[ek]==1) && (tomasulo.StoreBuffer_source1_valid_bit[ek]==1)) begin
                    tomasulo.StoreBuffer_Valid[ek] = 1;
                end
            end
        end

        if (tomasulo.StoreBuffer_Head > tomasulo.StoreBuffer_Tail) begin
            for (ek = tomasulo.StoreBuffer_Tail ; ek < 128 ; ek++ ) begin
                if (tomasulo.CDB_valid[tomasulo.StoreBuffer_source1_tag[ek]]) begin
                    if (tomasulo.StoreBuffer_source1_valid_bit[ek] == 0) begin
                       tomasulo.StoreBuffer_source1_value[ek] = tomasulo.CDB_result[tomasulo.StoreBuffer_source1_tag[ek]];
                       tomasulo.StoreBuffer_source1_valid_bit[ek] = 1;
                    end
                end
                if (tomasulo.CDB_valid[tomasulo.StoreBuffer_source2_tag[ek]]) begin
                    if (tomasulo.StoreBuffer_source2_valid_bit[ek] == 0) begin
                       tomasulo.StoreBuffer_source2_value[ek] = tomasulo.CDB_result[tomasulo.StoreBuffer_source2_tag[ek]];
                       tomasulo.StoreBuffer_source2_valid_bit[ek] = 1;
                    end
                end

                if ((tomasulo.StoreBuffer_source2_valid_bit[ek]==1) && (tomasulo.StoreBuffer_source1_valid_bit[ek]==1)) begin
                    tomasulo.StoreBuffer_Valid[ek] = 1;
                end
            end

            for (ek = 0;ek < tomasulo.StoreBuffer_Tail ; ek++ ) begin
                if (tomasulo.CDB_valid[tomasulo.StoreBuffer_source1_tag[ek]]) begin
                    if (tomasulo.StoreBuffer_source1_valid_bit[ek] == 0) begin
                       tomasulo.StoreBuffer_source1_value[ek] = tomasulo.CDB_result[tomasulo.StoreBuffer_source1_tag[ek]];
                       tomasulo.StoreBuffer_source1_valid_bit[ek] = 1;
                    end
                end
                if (tomasulo.CDB_valid[tomasulo.StoreBuffer_source2_tag[ek]]) begin
                    if (tomasulo.StoreBuffer_source2_valid_bit[ek] == 0) begin
                       tomasulo.StoreBuffer_source2_value[ek] = tomasulo.CDB_result[tomasulo.StoreBuffer_source2_tag[ek]];
                       tomasulo.StoreBuffer_source2_valid_bit[ek] = 1;
                    end
                end

                if ((tomasulo.StoreBuffer_source2_valid_bit[ek]==1) && (tomasulo.StoreBuffer_source1_valid_bit[ek]==1)) begin
                    tomasulo.StoreBuffer_Valid[ek] = 1;
                end
            end
        end
    end

    //@(posedge clock);
    /// code to write back to ROB
    if (tomasulo.RoB_Head == tomasulo.RoB_Tail && tomasulo.RoB_busy[tomasulo.RoB_Tail] == 0) begin
        // do nothing as RoB is empty
        tomasulo.start_write_back = 0;
    end

    else begin
        if (tomasulo.RoB_Head < tomasulo.RoB_Tail) begin
            for (pg = tomasulo.RoB_Head ; pg < tomasulo.RoB_Tail ; pg = pg + 1 ) begin
                if (tomasulo.CDB_valid[pg]) begin
                    if(tomasulo.RoB_busy[pg]) begin
                        tomasulo.RoB_Dest_Value[pg] = tomasulo.CDB_result[pg];
                        tomasulo.RoB_Valid[pg] = 1'b1;
                        //tomasulo.Instruction_state_register[tomasulo.RoB_Instruction_Index[pg]] = 3'b011;
                        tomasulo.CDB_valid[pg] = 0;
                    end
                end
            end
        end

        if (tomasulo.RoB_Head >= tomasulo.RoB_Tail) begin
            for (pg = tomasulo.RoB_Tail; pg <= tomasulo.RoB_Head ; pg = pg + 1 ) begin
                if (tomasulo.CDB_valid[pg]) begin
                    if(tomasulo.RoB_busy[pg]) begin
                        tomasulo.RoB_Dest_Value[pg] = tomasulo.CDB_result[pg];
                        tomasulo.RoB_Valid[pg] = 1'b1;
                        //tomasulo.Instruction_state_register[tomasulo.RoB_Instruction_Index[pg]] = 3'b011;
                        tomasulo.CDB_valid[pg] = 0;
                    end
                end
            end
        end
    end
    
end

endmodule
