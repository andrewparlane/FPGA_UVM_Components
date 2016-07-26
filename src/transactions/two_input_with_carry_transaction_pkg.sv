`include "uvm_macros.svh"

package two_input_with_carry_transaction_pkg;
    import uvm_pkg::*;

    class two_input_with_carry_transaction #(parameter WIDTH = 1) extends uvm_sequence_item;
        `uvm_object_param_utils(two_input_with_carry_transaction #(WIDTH))

        rand bit [WIDTH-1:0] in1;
        rand bit [WIDTH-1:0] in2;
        rand bit carryIn;

        function new(string name = "two_input_with_carry_transaction");
            super.new(name);
        endfunction: new

        // custom methods ----------------------------------------------------------
        function string inputs2string();
            string s;
            s = $sformatf("in1=%h, in2=%h, carryIn=%h", in1, in2, carryIn);
            return s;
        endfunction: inputs2string

        // fill in the default transaction functions -------------------------------
        function void do_copy(uvm_object rhs);
            two_input_with_carry_transaction #(.WIDTH(WIDTH)) castedRhs;

            // cast the generic uvm_object to our type
            // if it fails, then the object passed in was not of a valid type
            if (!$cast(castedRhs, rhs)) begin
                `uvm_error("two_input_with_carry_transaction", "do_copy $cast() failed");
                return;
            end

            // get our parent to do their work first (typical of children)
            super.do_copy(rhs);

            // copy our items over
            in1 = castedRhs.in1;
            in2 = castedRhs.in2;
            carryIn = castedRhs.carryIn;
        endfunction: do_copy

        function bit do_compare(uvm_object rhs, uvm_comparer comparer);
            two_input_with_carry_transaction #(.WIDTH(WIDTH)) castedRhs;

            // cast the generic uvm_object to our type
            // if it fails, then the object passed in was not of a valid type
            if (!$cast(castedRhs, rhs)) begin
                `uvm_error("two_input_with_carry_transaction", "do_compare $cast() failed");
                return 0;
            end

            // check if our parent compares OK first
            // then compare our fields
            return (super.do_compare(rhs, comparer) &&
                    in1 === castedRhs.in1 &&
                    in2 === castedRhs.in2 &&
                    carryIn === castedRhs.carryIn);
        endfunction: do_compare

        function string convert2string();
            return { super.convert2string(), " ", inputs2string() };
        endfunction: convert2string

    endclass: two_input_with_carry_transaction
endpackage: two_input_with_carry_transaction_pkg
