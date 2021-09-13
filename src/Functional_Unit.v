module Rtype_FUnit (
    input clock,
    input control,
    input [5:0] instruction,
    input [31:0] src_value1,
    input [31:0] src_value2,
    input [6:0] dest_tag
);

reg result;
reg done_execute;
if (control) begin
    To_Execute.is_to_execute = 0;
    if (instruction == 6'b011011)begin // ADD
      result = src_value1 + src_value2; // overflow are ignored
    end

    else if (instruction == 6'b011100) begin // SUB
        result = src_value1 - src_value2;  // overflow are ignored
    end

    else if (instruction ==  6'b100000) begin // XOR
        result = src_value1 ^ src_value2;  
    end

    else if (instruction ==  6'b100011) begin // OR
        result = src_value1 | src_value2;  
    end

    else if (instruction ==  6'b100100) begin // AND
        result = src_value1 & src_value2;  
    end

    else if (instruction ==  6'b011101) begin // SLL
        result = src_value1 << src_value2[4:0];  
    end

    else if (instruction == 6'b100001) begin // SRL
        result = src_value1 >> src_value2[4:0];
    end

    else if (instruction == 6'b100010) begin // SRA
        result = src_value1 >>> src_value2[4:0];
    end

    else if (instruction == 6'b011110) begin // SLT
        if($signed(src_value1) < $signed(src_value2))begin
            result = 32'b0000_0000_0000_0000_0000_0000_0000_0001;
        end;

        else begin
             result = 32'b0;
        end
    end

    else if (instruction == 6'b011110) begin // SLTU
        if(src_value1 < src_value2)begin
            result = 32'b0000_0000_0000_0000_0000_0000_0000_0001;
        end;

        else begin
             result = 32'b0;
        end
    end
    done_execute = 1;
end

if (done_execute) begin
    CDB cdb_unit(clock,done_execute,dest_tag,result);
    done_execute = 0;
end
endmodule