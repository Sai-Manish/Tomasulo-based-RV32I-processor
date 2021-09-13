module Free_RRS_Entry (
    input [1:0] RS_index
);
tomasulo.RS_Rtype_busy[RS_index] = 1'b0;
tomasulo.RS_Rtype_valid[RS_index] = 1'b0;  
tomasulo.need_to_stall = 1'b0;  
endmodule