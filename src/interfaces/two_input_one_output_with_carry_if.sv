// This interface is for use with blocks that
// take two inputs of the same size and a carry bit
// and produce an output of a potentially different size, and a carry bit
// For example an adder, multiplier, ...
interface two_input_one_output_with_carry_if #(parameter INPUT_WIDTH = 1,
                                               parameter OUTPUT_WIDTH = 1);
    logic clk;

    logic [INPUT_WIDTH-1:0] in1;
    logic [INPUT_WIDTH-1:0] in2;
    logic carryIn;

    logic [OUTPUT_WIDTH-1:0] out;
    logic carryOut;
endinterface: two_input_one_output_with_carry_if
