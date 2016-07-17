`include "uvm_macros.svh"

package two_input_one_output_with_carry_transaction_pkg;
    import uvm_pkg::*;
    import two_input_with_carry_transaction_pkg::*;

    // we extend the two_input_with_carry_transaction
    // and just add the output and output carry
    class two_input_one_output_with_carry_transaction #(parameter INPUT_WIDTH, parameter OUTPUT_WIDTH) extends two_input_with_carry_transaction #(.WIDTH(INPUT_WIDTH));
        `uvm_object_param_utils(two_input_one_output_with_carry_transaction #(INPUT_WIDTH, OUTPUT_WIDTH))

        logic [OUTPUT_WIDTH-1:0] out;
        logic carryOut;

        function new(string name = "two_input_one_output_with_carry_transaction");
            super.new(name);
        endfunction: new

        function string outputs2string();
            string s;
            s = $sformatf(" out=%h, carryOut=%h", out, carryOut);
            return s;
        endfunction: outputs2string

    endclass: two_input_one_output_with_carry_transaction
endpackage: two_input_one_output_with_carry_transaction_pkg
