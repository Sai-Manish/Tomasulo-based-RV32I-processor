`timescale 1ns/1ns
module tomasulo (clock,reset
);

  parameter WIDTH = 32;
  parameter R_RS_size = 3;
  parameter I_RS_size = 3;
  parameter L_RS_size = 3;
  parameter S_RS_size = 3;
  parameter RoB_size = 128;
  parameter StoreBuffer_size = 128;
  parameter R_Cycles = 2;
  parameter I_Cycles = 1;
  parameter Store_Cycles = 4;
  parameter No_of_instructions = 100;
  parameter Memory_lines = 65536;
  parameter Max_Cycles = 5;

  input clock,reset;
  // first declare all the necessary things needed.
  // then start arranging submodules accordingly.
  reg [WIDTH-1:0]PC;
  reg [WIDTH-1:0]Index;

  // control variable
  reg need_to_stall; // if ROB or RS is not free the instruction will be stalled and PC wont be incremented
  reg stall_due_to_Jtype;
  reg stall_due_to_Btype;
  reg done_decode;
  reg done_issue;
  reg done_fetch;
  reg is_to_execute_R;
  reg is_to_execute_I;
  reg is_to_execute_L;
  reg is_to_execute_S;
  reg done_execute_R;
  reg done_execute_I;
  reg done_execute_L;
  reg done_execute_S;
  reg start_write_back;
  reg start_commit;
  reg done_commit;
  reg bus_busy_with_load;
  reg bus_busy_with_store;

  reg signed [WIDTH-1:0] Execute_result[0:RoB_size - 1];
  //reg [6:0] Execute_dest_tag[0:RoB_size - 1];
  reg [WIDTH-1:0] Execute_Instruction_Index[0:RoB_size - 1];
  reg Execute_valid[0:RoB_size - 1];
  reg [$clog2(Max_Cycles + 1) - 1:0] Execute_cycles[0:RoB_size - 1];
  reg Execute_busy[0:RoB_size - 1];

  // CDB each functional unit will will have one cdb connected to it
  reg signed [WIDTH-1:0] CDB_result[0:RoB_size - 1];
  //reg [6:0] CDB_dest_tag[0:RoB_size - 1];
  reg [WIDTH-1:0] CDB_Instruction_Index[0:RoB_size - 1];
  reg CDB_valid[0:RoB_size - 1];
    
  ///// Instruction Memory /////
  reg [7:0] instruction_memory [0:No_of_instructions];
    
  // Instruction state register ////
  reg [2:0] Instruction_state_register [0:No_of_instructions];
  // 001 - In issue stage, 010 - In execute stage, 011 - In write_back stage, 100 - In commit stage
  wire [2:0] Instruction_0_state;
  wire [2:0] Instruction_1_state;
  wire [2:0] Instruction_2_state;
  wire [2:0] Instruction_3_state;
  wire [2:0] Instruction_4_state;
  wire [2:0] Instruction_5_state;
  wire [2:0] Instruction_6_state;
  wire [2:0] Instruction_7_state;
  wire [2:0] Instruction_8_state;
  wire [2:0] Instruction_9_state;
  wire [2:0] Instruction_10_state;
  wire [2:0] Instruction_11_state;
  wire [2:0] Instruction_12_state;
  wire [2:0] Instruction_13_state;
  wire [2:0] Instruction_14_state;
  wire [2:0] Instruction_15_state;
  wire [2:0] Instruction_16_state;
  wire [2:0] Instruction_17_state;
  wire [2:0] Instruction_18_state;
  wire [2:0] Instruction_19_state;
  wire [2:0] Instruction_20_state;
  wire [2:0] Instruction_21_state;
  wire [2:0] Instruction_22_state;
  wire [2:0] Instruction_23_state;
  wire [2:0] Instruction_24_state;
  wire [2:0] Instruction_25_state;
  wire [2:0] Instruction_26_state;
  wire [2:0] Instruction_27_state;
  wire [2:0] Instruction_28_state;
  wire [2:0] Instruction_29_state;
  wire [2:0] Instruction_30_state;
    
  ///// ARF and RAT /////
  reg signed [WIDTH-1:0] register_file [0:31];
  reg [6:0] register_tag [1:31];
  reg register_valid [1:31]; 

  wire [31:0] register_file0;
	wire [31:0] register_file1;
	wire [31:0] register_file2;
	wire [31:0] register_file3;
	wire [31:0] register_file4;
	wire [31:0] register_file5;
	wire [31:0] register_file6;
	wire [31:0] register_file7;
	wire [31:0] register_file8;
	wire [31:0] register_file9;
	wire [31:0] register_file10;
	wire [31:0] register_file11;
	wire [31:0] register_file12;
	wire [31:0] register_file13;
	wire [31:0] register_file14;
	wire [31:0] register_file15;
	wire [31:0] register_file16;
	wire [31:0] register_file17;
	wire [31:0] register_file18;
	wire [31:0] register_file19;
	wire [31:0] register_file20;
	wire [31:0] register_file21;
	wire [31:0] register_file22;
	wire [31:0] register_file23;
	wire [31:0] register_file24;
	wire [31:0] register_file25;
	wire [31:0] register_file26;
	wire [31:0] register_file27;
	wire [31:0] register_file28;
	wire [31:0] register_file29;
	wire [31:0] register_file30;
	wire [31:0] register_file31;

  ///// ROB /////
  reg [5:0] RoB_Instruction [0:RoB_size - 1]; //length(RoB) = 128; breadth(RoB) = 6 (instruction type) + 1 (busy bit) + 5 (destination address) + 32 (destination value)
  reg RoB_busy [0:RoB_size - 1];
  reg RoB_Valid [0:RoB_size - 1];
  reg [4:0] RoB_Dest_Addr[0:RoB_size - 1];
  reg signed [WIDTH-1:0] RoB_Dest_Value[0:RoB_size - 1];
  reg [WIDTH-1:0] RoB_Instruction_Index [0:RoB_size - 1]; // this to have track of instruction number and will help during cdb broadcast or commit
  reg [6:0] RoB_Head;
  reg [6:0] RoB_Tail;

	///// Reservation station /////
  //// R type Reservation ///
  reg RS_Rtype_valid [0:R_RS_size-1];// if 0 invalid if 1 valid //length(RS) = 3; breadth(RS) = 1 (valid bit) + 1 (busy bit)  + 6 (instruction type) + 7 (destination tag) + 7 (source1 tag) + 7 (source2 tag) + 32 (source1 value) + 32 (source2 value)  
	reg RS_Rtype_busy [0:R_RS_size-1];
  reg [5:0] RS_Rtype_instruction [0:R_RS_size -1];
  reg [6:0] RS_Rtype_Dest_tag [0:R_RS_size -1];
  reg [6:0] RS_Rtype_source1_tag [0:R_RS_size -1];
  reg [6:0] RS_Rtype_source2_tag [0:R_RS_size -1];
  reg signed [WIDTH-1:0] RS_Rtype_source1_value [0:R_RS_size -1];
  reg signed [WIDTH-1:0] RS_Rtype_source2_value [0:R_RS_size -1];
  reg RS_Rtype_source1_valid [0:R_RS_size -1];
  reg RS_Rtype_source2_valid [0:R_RS_size -1];
  reg [WIDTH-1:0] RS_Rtype_instruction_index [0:R_RS_size -1]; // this to have track of instruction number and will help during execute
    
  //// I type Reservation ///
  reg RS_Itype_valid [0:I_RS_size -1];// if 0 invalid if 1 valid //length(RS) = 3; breadth(RS) = 1 (valid bit) + 1 (busy bit)  + 6 (instruction type) + 7 (destination tag) + 7 (source1 tag) + 7 (source2 tag) + 32 (source1 value) + 32 (source2 value)  
	reg RS_Itype_busy [0:I_RS_size -1];
  reg [5:0] RS_Itype_instruction [0:I_RS_size -1];
  reg [6:0] RS_Itype_Dest_tag [0:I_RS_size -1];
  reg [6:0] RS_Itype_source1_tag [0:I_RS_size -1];
  reg signed [WIDTH-1:0] RS_Itype_source1_value [0:I_RS_size -1];
  reg signed [WIDTH-1:0] RS_Itype_immediate_value [0:I_RS_size -1]; // 2's complement number
  reg [WIDTH-1:0] RS_Itype_instruction_index [0:I_RS_size -1];

  ///// L type Reservation station ///
  // will have LB, LH, LW, LBU, LHU
  reg RS_Ltype_valid [0:L_RS_size -1];// if 0 invalid if 1 valid //length(RS) = 3; breadth(RS) = 1 (valid bit) + 1 (busy bit)  + 6 (instruction type) + 7 (destination tag) + 7 (source1 tag) + 7 (source2 tag) + 32 (source1 value) + 32 (source2 value)  
	reg RS_Ltype_busy [0:L_RS_size -1];
  reg [5:0] RS_Ltype_instruction [0:L_RS_size -1];
  reg [6:0] RS_Ltype_Dest_tag [0:L_RS_size -1];
  reg [6:0] RS_Ltype_source1_tag [0:L_RS_size -1];
  reg signed [31:0] RS_Ltype_source1_value [0:L_RS_size -1];
  reg signed [31:0] RS_Ltype_immediate_value [0:L_RS_size -1]; // 2's complement number
  reg [WIDTH-1:0] RS_Ltype_instruction_index [0:L_RS_size -1];
    
  ///// S type StoreBuffer or Store Reservation /////
  //for all store instructions SB, SH, and SW;
  // 32 (sign-extended offset) + 32 (memory address of LSB) 
  reg StoreBuffer_IsExe[0:StoreBuffer_size-1]; // bit indicates whether or not store instruction has been executed for addresss calculation.
  reg StoreBuffer_IsAccessing[0:StoreBuffer_size-1]; // bit indicates whether or not store instruction is accessing memory
  reg StoreBuffer_Valid[0:StoreBuffer_size-1]; // when both source 1 and source 2 are valid.
  reg [WIDTH-1:0] StoreBuffer_instruction_index[0:StoreBuffer_size-1]; // instruction number
  reg [5:0] StoreBuffer_instruction_type[0:StoreBuffer_size-1]; //instruction type
  reg [6:0] StoreBuffer_Dest_tag[0:StoreBuffer_size-1]; // destination tag
  reg StoreBuffer_source1_valid_bit[0:StoreBuffer_size-1];
  reg StoreBuffer_source2_valid_bit[0:StoreBuffer_size-1];
  reg [6:0] StoreBuffer_source1_tag[0:StoreBuffer_size-1];
  reg [6:0] StoreBuffer_source2_tag[0:StoreBuffer_size-1];
  reg signed [WIDTH-1:0] StoreBuffer_source1_value[0:StoreBuffer_size-1];
  reg signed [WIDTH-1:0] StoreBuffer_source2_value[0:StoreBuffer_size-1];
  reg signed [WIDTH-1:0] StoreBuffer_signExtnd[0:StoreBuffer_size-1];
  reg [WIDTH-1:0] StoreBuffer_MemoryAccessAddr[0:StoreBuffer_size-1];
  reg is_StoreBuffer_free;
  reg [6:0] StoreBuffer_Head;
  reg [6:0] StoreBuffer_Tail;


  //////////////// Memory Unit //////////////////////////
  reg [7:0] Data_Memory [0:Memory_lines-1]; // byte addressable memory

  integer i,j,k;
  always@(reset)begin
    if (reset == 1) begin // reset = 1 means to reset and reset = 0 is not to reset
      //initialising instruction_memory    
      $readmemb("instructions.txt", instruction_memory);

      for (i=0;i<3;i=i+1) begin
        RS_Rtype_busy[i] = 1'b0;
        RS_Rtype_valid[i] = 1'b0;
        RS_Rtype_instruction[i] = 6'b0;
        RS_Rtype_Dest_tag[i] = 7'b0;
        RS_Rtype_source1_tag[i] = 7'b0;
        RS_Rtype_source2_tag[i] = 7'b0;
        RS_Rtype_source1_value[i] = 32'b0;
        RS_Rtype_source2_value[i] = 32'b0;
        RS_Rtype_source1_valid[i] = 1'b0;
        RS_Rtype_source2_valid[i] = 1'b0;

        RS_Itype_busy[i] = 1'b0;
        RS_Itype_valid[i] = 1'b0;
        RS_Itype_instruction[i] = 6'b0;
        RS_Itype_Dest_tag[i] = 7'b0;
        RS_Itype_source1_tag[i] = 7'b0;
        RS_Itype_source1_value[i] = 32'b0;
        RS_Itype_immediate_value[i] = 12'b0;

        RS_Ltype_valid[i] = 1'b0;
        RS_Ltype_busy [i] = 1'b0;
        RS_Ltype_instruction [i] = 6'b0;
        RS_Ltype_Dest_tag [i] = 7'b0;
        RS_Ltype_source1_tag [i] = 7'bx;
        RS_Ltype_source1_value [i] = 32'b0;
        RS_Ltype_immediate_value [i] = 32'b0; // 2's complement number
        RS_Ltype_instruction_index [i] = 32'b0;

      end
      
      for (j=0;j<RoB_size;j=j+1) begin
        RoB_busy[j] = 0;
        RoB_Valid[j] = 0;
        RoB_Dest_Addr[j] = 5'b0;
        RoB_Dest_Value[j] = 32'b0;
        Execute_result[j] = 32'b0;
        //Execute_dest_tag[j] = 7'b0;
        Execute_Instruction_Index[j] = 32'b0;
        Execute_valid[j] = 0;
        CDB_Instruction_Index[j] = 32'b0;
        CDB_result[j] = 32'b0;
        CDB_valid[j] = 0;
        Execute_cycles[j] = 0;
        //CDB_dest_tag[j] = 7'b0;
        StoreBuffer_IsExe[j] = 0;
        StoreBuffer_IsAccessing[j] = 0;
        StoreBuffer_Valid[j] = 0;
        StoreBuffer_instruction_index[j] = 32'b0; // instruction number
        StoreBuffer_instruction_type[j] = 6'b0; //instruction type
        StoreBuffer_Dest_tag[j] = 7'b0; // destination tag
        StoreBuffer_source1_valid_bit[j] = 1'b0;
        StoreBuffer_source2_valid_bit[j] = 1'b0;
        StoreBuffer_source1_tag[j] = 7'b0;
        StoreBuffer_source2_tag[j] = 7'b0;
        StoreBuffer_source1_value[j] = 32'b0;
        StoreBuffer_source2_value[j] = 32'b0;
        StoreBuffer_MemoryAccessAddr[j] = 32'b0;

      end
      
      for (k=0;k<32;k=k+1)begin
        if (k==0) begin
          register_file[k] = k;
          register_valid[k] = 1'b1;
        end
        else begin
          register_file[k] = k;
          register_tag[k] = 7'b0;
          register_valid[k] = 1'b1;
        end
        
      end

      for (k = 0; k < Memory_lines; k++ ) begin
        Data_Memory[k] = 8'b00000000;
      end

      PC = 32'b0;
      Index = 32'b0;
      need_to_stall = 1'b0;
      stall_due_to_Jtype = 1'b0;
      stall_due_to_Btype = 1'b0;
      done_decode = 0;
  	  done_issue = 0;
      done_fetch = 0;
      is_to_execute_R = 0;
      is_to_execute_I = 0;
      done_execute_R = 0;
      done_execute_I = 0;
      done_execute_L = 0;
      done_execute_S = 0;

      start_write_back = 0;
      start_commit = 0;
      done_commit = 0;
      RoB_Head = 7'b0;
      RoB_Tail = 7'b0;
      
      StoreBuffer_Head = 7'b0;
      StoreBuffer_Tail = 7'b0;
      is_StoreBuffer_free = 1'b1;
      bus_busy_with_load = 1'b0;
      bus_busy_with_store = 1'b0;

	    Instruction_state_register[0] = 3'bx;
      Instruction_state_register[1] = 3'bx;
      Instruction_state_register[2] = 3'bx;
      Instruction_state_register[3] = 3'bx;
      Instruction_state_register[4] = 3'bx;
      Instruction_state_register[5] = 3'bx;
      Instruction_state_register[6] = 3'bx;
      Instruction_state_register[7] = 3'bx;
      Instruction_state_register[8] = 3'bx;
      Instruction_state_register[9] = 3'bx;
      Instruction_state_register[10] = 3'bx;
      Instruction_state_register[11] = 3'bx;
      Instruction_state_register[12] = 3'bx;
      Instruction_state_register[13] = 3'bx;
      Instruction_state_register[14] = 3'bx;
      Instruction_state_register[15] = 3'bx;
      Instruction_state_register[16] = 3'bx;
      Instruction_state_register[17] = 3'bx;
      Instruction_state_register[18] = 3'bx;
      Instruction_state_register[19] = 3'bx;
      Instruction_state_register[20] = 3'bx;
      Instruction_state_register[21] = 3'bx;
      Instruction_state_register[22] = 3'bx;
      Instruction_state_register[23] = 3'bx;
      Instruction_state_register[24] = 3'bx;
      Instruction_state_register[25] = 3'bx;
      Instruction_state_register[26] = 3'bx;
      Instruction_state_register[27] = 3'bx;
      Instruction_state_register[28] = 3'bx;
      Instruction_state_register[29] = 3'bx;
      Instruction_state_register[30] = 3'bx;

      /*instruction_memory[0] = 32'b00000000001000001000000110110011; //"add","x1","x2","x3"
      instruction_memory[1] = 32'b01000000000100011000001010110011; // "sub","x3","x1","x5"
      instruction_memory[2] = 32'b00000000001000001000000010110011;  // "add","x1","x2","x1" 
      instruction_memory[3] = 32'b00000000001000001010000000100011;  // "sw","x1","x2","0"
      instruction_memory[4] = 32'b00000000000000101010000010000011; // "lw","x5","0","x1"
      //instruction_memory[5] = 32'b00000000000000001010001100000011; // "lw","x1","0","x6"
      instruction_memory[5] = 32'b00000000001000011000000101100011; // "beq","x3","x2","2"
      //instruction_memory[6] = 32'b11111111100111111111000011101111; // "jal", "-1","x1"
      //instruction_memory[7] = 32'b00000000001000011000001111100111; // "jalr","x3","2","x7"
      //instruction_memory[7] = 32'b00000000001100010000000010110011; // "add", "x2", "x3", "x1"
      //instruction_memory[8] = 32'b11111110001000001001111111100011; // "bne","x1","x2","-1"
      instruction_memory[6] = 32'b00000000000000000000001011100111; //"jalr","x0","0","x5"
      // instruction_memory[12] = 32'b00000000001000000110000100010011; 
      // instruction_memory[13] = 32'b00000000001100010001000010110011;
      // instruction_memory[14] = 32'b00000000010000001000000110010011;
      // instruction_memory[15] = 32'b00000000001000010001000100010011;
      // instruction_memory[16] = 32'b00000000100000010101001000010011;*/
    end
  end

  Issue_stage IS(PC,clock,reset);

  To_Execute TE(clock,reset);
  
  Write_Back WB(clock,reset);
   
  Commit_stage CM(clock,reset);
  
  assign Instruction_0_state =  Instruction_state_register[0];
  assign Instruction_1_state =  Instruction_state_register[1];
  assign Instruction_2_state =  Instruction_state_register[2];
  assign Instruction_3_state =  Instruction_state_register[3];
  assign Instruction_4_state =  Instruction_state_register[4];
  assign Instruction_5_state =  Instruction_state_register[5];
  assign Instruction_6_state =  Instruction_state_register[6];
  assign Instruction_7_state =  Instruction_state_register[7];
  assign Instruction_8_state =  Instruction_state_register[8];
  assign Instruction_9_state =  Instruction_state_register[9];
  assign Instruction_10_state =  Instruction_state_register[10];
  assign Instruction_11_state =  Instruction_state_register[11];
  assign Instruction_12_state =  Instruction_state_register[12];
  assign Instruction_13_state =  Instruction_state_register[13];
  assign Instruction_14_state =  Instruction_state_register[14];
  assign Instruction_15_state =  Instruction_state_register[15];
  assign Instruction_16_state =  Instruction_state_register[16];
  assign Instruction_17_state =  Instruction_state_register[17];
  assign Instruction_18_state =  Instruction_state_register[18];
  assign Instruction_19_state =  Instruction_state_register[19];
  assign Instruction_20_state =  Instruction_state_register[20];
  assign Instruction_21_state =  Instruction_state_register[21];
  assign Instruction_22_state =  Instruction_state_register[22];
  assign Instruction_23_state =  Instruction_state_register[23];
  assign Instruction_24_state =  Instruction_state_register[24];
  assign Instruction_25_state =  Instruction_state_register[25];
  assign Instruction_26_state =  Instruction_state_register[26];
  assign Instruction_27_state =  Instruction_state_register[27];
  assign Instruction_28_state =  Instruction_state_register[28];
  assign Instruction_29_state =  Instruction_state_register[29];
  assign Instruction_30_state =  Instruction_state_register[30];


  assign register_file0 = register_file[0];
  assign register_file1 = register_file[1];
  assign register_file2 = register_file[2];
  assign register_file3 = register_file[3];
  assign register_file4 = register_file[4];
  assign register_file5 = register_file[5];
  assign register_file6 = register_file[6];
  assign register_file7 = register_file[7];
  assign register_file8 = register_file[8];
  assign register_file9 = register_file[9];
  assign register_file10 = register_file[10];
  assign register_file11 = register_file[11];
  assign register_file12 = register_file[12];
  assign register_file13 = register_file[13];
  assign register_file14 = register_file[14];
  assign register_file15 = register_file[15];
  assign register_file16 = register_file[16];
  assign register_file17 = register_file[17];
  assign register_file18 = register_file[18];
  assign register_file19 = register_file[19];
  assign register_file20 = register_file[20];
  assign register_file21 = register_file[21];
  assign register_file22 = register_file[22];
  assign register_file23 = register_file[23];
  assign register_file24 = register_file[24];
  assign register_file25 = register_file[25];
  assign register_file26 = register_file[26];
  assign register_file27 = register_file[27];
  assign register_file28 = register_file[28];
  assign register_file29 = register_file[29];
  assign register_file30 = register_file[30];
  assign register_file31 = register_file[31];
  
endmodule