module CDB(
    input clock,
    input control,
    input [6:0] dest_tag,
    input [31:0] result
);
parameter RS_Rtype_Size = 3;
parameter RoB_Size = 128;
reg control;
reg dest_tag;
reg result;
integer i,j;
always @(posedge clock) begin
    if(control)begin
        Rtype_FUnit.done_execute = 0;
        for (i = 0; i < RS_Rtype_Size ; i = i + 1 ) begin
            if(tomasulo.RS_Rtype_busy[i] = 1)begin
                if(tomasulo.RS_Rtype_source1_tag[i] == dest_tag)begin
                    tomasulo.RS_Rtype_source1_value[i] = result;
                end
                if(tomasulo.RS_Rtype_source2_tag[i] == dest_tag)begin
                    tomasulo.RS_Rtype_source2_value[i] = result;
                end
            end
        end

        tomasulo.RoB_Dest_Value[dest_tag] = result;
        tomasulo.RoB_Valid[dest_tag] = 1'b1;
    end
end

endmodule