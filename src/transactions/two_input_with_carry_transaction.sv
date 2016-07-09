`include "uvm_macros.svh"

package two_input_with_carry_transaction_pkg;
    import uvm_pkg::*;

    class two_input_with_carry_transaction #(parameter WIDTH = 1) extends uvm_sequence_item;
        `uvm_object_param_utils(two_input_with_carry_transaction #(WIDTH));

        rand bit [WIDTH-1:0] in1;
        rand bit [WIDTH-1:0] in2;
        rand bit carryIn;

        function new(string name = "two_input_with_carry_transaction");
            super.new(name);
        endfunction: new

        function string convert2string();
            string s;
            s = $sformatf("in1=%h, in2=%h, carryIn=%h", in1, in2, carryIn);
            return s;
        endfunction: convert2string

    endclass: two_input_with_carry_transaction
endpackage: two_input_with_carry_transaction_pkg
