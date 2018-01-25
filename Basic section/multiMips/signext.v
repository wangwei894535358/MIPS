module signext(inst, data);

input [15:0] inst;
output [31:0] data;

assign data = inst[15]?{16'b1, inst[15:0]}:{16'b0, inst[15:0]};
//sign number extend
endmodule
