`include "uvm_macros.svh"

package two_input_with_carry_transaction_pkg;
    import uvm_pkg::*;

    class two_input_with_carry_transaction #(parameter WIDTH = 1) extends uvm_sequence_item;
        rand bit [WIDTH-1:0] in1;
        rand bit [WIDTH-1:0] in2;
        rand bit carryIn;

        `uvm_object_param_utils_begin(two_input_with_carry_transaction #(WIDTH))
            `uvm_field_int(in1, UVM_ALL_ON)
            `uvm_field_int(in2, UVM_ALL_ON)
            `uvm_field_int(carryIn, UVM_ALL_ON)
        `uvm_object_utils_end

        function new(string name = "two_input_with_carry_transaction");
            super.new(name);
        endfunction: new

        function string inputs2string();
            string s;
            s = $sformatf("in1=%h, in2=%h, carryIn=%h", in1, in2, carryIn);
            return s;
        endfunction: inputs2string

    endclass: two_input_with_carry_transaction
endpackage: two_input_with_carry_transaction_pkg
