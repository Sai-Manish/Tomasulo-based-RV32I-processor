module Commit_stage (
    input clock,
    input reset
);

    integer i;
    always @(negedge clock) begin
        tomasulo.start_commit = 0;
        if(reset == 0) begin
            if (tomasulo.RoB_Head == tomasulo.RoB_Tail && tomasulo.RoB_busy[tomasulo.RoB_Tail] == 0) begin
                // do nothing as RoB is empty
                tomasulo.start_commit = 0;
            end
            else begin
                if (tomasulo.RoB_Valid[tomasulo.RoB_Head]) begin
                   tomasulo.start_commit = 1; 
                end
            end
        end
    end

    always @(posedge clock) begin
        tomasulo.done_commit = 0;
        if (tomasulo.start_commit) begin
            if (tomasulo.RoB_Instruction[tomasulo.RoB_Head] != 6'b001111 && tomasulo.RoB_Instruction[tomasulo.RoB_Head] != 6'b010000 && tomasulo.RoB_Instruction[tomasulo.RoB_Head] != 6'b010001) begin
               if (tomasulo.RoB_Dest_Addr[tomasulo.RoB_Head] != 0) begin
                    tomasulo.register_file[tomasulo.RoB_Dest_Addr[tomasulo.RoB_Head]] = tomasulo.RoB_Dest_Value[tomasulo.RoB_Head];
                    if(tomasulo.register_tag[tomasulo.RoB_Dest_Addr[tomasulo.RoB_Head]] == tomasulo.RoB_Head)begin
                        tomasulo.register_valid[tomasulo.RoB_Dest_Addr[tomasulo.RoB_Head]] = 1'b1;
                    end
                    tomasulo.RoB_busy[tomasulo.RoB_Head] = 0;
                    tomasulo.RoB_Valid[tomasulo.RoB_Head] = 0;
                    tomasulo.Instruction_state_register[tomasulo.RoB_Instruction_Index[tomasulo.RoB_Head]] = 3'b100;
                    tomasulo.RoB_Head = $unsigned(tomasulo.RoB_Head + 7'b0000001) % 128;
                    tomasulo.done_commit = 1;
                end     
            end

            else begin
                $display("Came to commit stage for store instruction");
                if (tomasulo.bus_busy_with_load == 0 && tomasulo.bus_busy_with_store == 0) begin
                    tomasulo.bus_busy_with_store = 1;

                    if (tomasulo.StoreBuffer_instruction_type[tomasulo.StoreBuffer_Head] == 6'b001111) begin
                        tomasulo.Data_Memory[tomasulo.RoB_Dest_Value[tomasulo.RoB_Head]] = tomasulo.StoreBuffer_source2_value[tomasulo.StoreBuffer_Head][7:0];
                    end

                    else if (tomasulo.StoreBuffer_instruction_type[tomasulo.StoreBuffer_Head] == 6'b010000) begin
                        tomasulo.Data_Memory[tomasulo.RoB_Dest_Addr[tomasulo.RoB_Head]] = tomasulo.StoreBuffer_source2_value[tomasulo.StoreBuffer_Head][7:0];
                        tomasulo.Data_Memory[tomasulo.RoB_Dest_Addr[tomasulo.RoB_Head] + 32'b00000000000000000000000000000001] = tomasulo.StoreBuffer_source2_value[tomasulo.StoreBuffer_Head][15:8];
                    end

                    else if (tomasulo.StoreBuffer_instruction_type[tomasulo.StoreBuffer_Head] == 6'b010001) begin
                        tomasulo.Data_Memory[tomasulo.RoB_Dest_Addr[tomasulo.RoB_Head]] = tomasulo.StoreBuffer_source2_value[tomasulo.StoreBuffer_Head][7:0];
                        tomasulo.Data_Memory[tomasulo.RoB_Dest_Addr[tomasulo.RoB_Head] + 32'b00000000000000000000000000000001] = tomasulo.StoreBuffer_source2_value[tomasulo.StoreBuffer_Head][15:8];
                        tomasulo.Data_Memory[tomasulo.RoB_Dest_Addr[tomasulo.RoB_Head] + 32'b00000000000000000000000000000010] = tomasulo.StoreBuffer_source2_value[tomasulo.StoreBuffer_Head][23:16];
                        tomasulo.Data_Memory[tomasulo.RoB_Dest_Addr[tomasulo.RoB_Head] + 32'b00000000000000000000000000000011] = tomasulo.StoreBuffer_source2_value[tomasulo.StoreBuffer_Head][31:14];
                    end
                    tomasulo.Instruction_state_register[tomasulo.RoB_Instruction_Index[tomasulo.RoB_Head]] = 3'b100;
                end

                if (tomasulo.bus_busy_with_store == 1) begin
                    tomasulo.Execute_cycles[tomasulo.RoB_Head] = tomasulo.Execute_cycles[tomasulo.RoB_Head] - 1;
                end
                
                if (tomasulo.Execute_cycles[tomasulo.RoB_Head] == 0) begin
                    tomasulo.bus_busy_with_store = 0;
                    tomasulo.StoreBuffer_IsExe[tomasulo.StoreBuffer_Head] = 0;
                    tomasulo.StoreBuffer_IsAccessing[tomasulo.StoreBuffer_Head] = 0;
                    tomasulo.StoreBuffer_Head = $unsigned(tomasulo.StoreBuffer_Head + 7'b0000001) % 128;
                    tomasulo.RoB_busy[tomasulo.RoB_Head] = 0;
                    tomasulo.RoB_Valid[tomasulo.RoB_Head] = 0;
                    tomasulo.RoB_Head = $unsigned(tomasulo.RoB_Head + 7'b0000001) % 128;
                    tomasulo.done_commit = 1;
                    $display("Done storing the value");
                end
            end
                    
        end
    end
endmodule