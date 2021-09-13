module To_Execute (
    input clock,
    output exe_index_rs, // I will keep this till testing
    output is_to_execute; // I will keep this till testing
);
parameter RS_Rtype_Size = 3;

reg [1:0] Temp_Index = 0;
reg [1:0] Temp_Index2 = 0;
reg [1:0] exe_index_rs;
reg is_to_execute;
reg [5:0] is_ex_instruction;
reg [31:0] is_ex_src1;
reg [31:0] is_ex_src2;
reg [6:0] is_ex_dest_tag;
integer i;
always @(posedge clock) begin
    // need to check if there is valid entry in RS, if there need to send to execute unit
    is_to_execute = 0;
    for (i = 0;i < RS_Rtype_Size ;i = i + 1) begin
        if (tomasulo.RS_Rtype_valid[i] == 1) begin
            Temp_Index = tomasulo.RS_Rtype_instruction_index[i];
            if (Temp_Index2 == 0) begin
                Temp_Index2 = Temp_Index;
                exe_index_rs = i;
            end
            else if (Temp_Index < Temp_Index2) begin
                Temp_Index2 = Temp_Index;
                exe_index_rs = i;
            end
        end
    end
    if (Temp_Index2 != 0) begin
        is_to_execute = 1;
        Temp_Index2 = 0;
        is_to_instruction <= tomasulo.RS_Rtype_instruction[exe_index_rs];
        is_ex_src1 <= tomasulo.RS_Rtype_source1_value[exe_index_rs];
        is_ex_src2 <= tomasulo.RS_Rtype_source2_value[exe_index_rs];
        is_ex_dest_tag <= tomasulo.RS_Rtype_Dest_tag[exe_index_rs];
        Free_RRS_Entry FRE(exe_index_rs);
    end

    else if (Temp_Index2 = 0) begin
        is_to_execute = 0;
    end
end

Rtype_FUnit RFU(clock,is_to_execute,is_ex_instruction,is_ex_src1,is_ex_src2,is_ex_dest_tag);
endmodule