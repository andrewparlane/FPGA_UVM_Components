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

        // custom methods ----------------------------------------------------------
        function string outputs2string();
            string s;
            s = $sformatf(" out=%h, carryOut=%h", out, carryOut);
            return s;
        endfunction: outputs2string

        function void copy_inputs(two_input_with_carry_transaction #(.WIDTH(INPUT_WIDTH)) tx);
            super.do_copy(tx);
        endfunction: copy_inputs

        function logic compare_outputs(two_input_one_output_with_carry_transaction #(.INPUT_WIDTH(INPUT_WIDTH), .OUTPUT_WIDTH(OUTPUT_WIDTH)) tx);
            return (out === tx.out && carryOut === tx.carryOut);
        endfunction: compare_outputs

        // fill in the default transaction functions -------------------------------
        function void do_copy(uvm_object rhs);
            two_input_one_output_with_carry_transaction #(.INPUT_WIDTH(INPUT_WIDTH), .OUTPUT_WIDTH(OUTPUT_WIDTH)) castedRhs;

            // cast the generic uvm_object to our type
            // if it fails, then the object passed in was not of a valid type
            if (!$cast(castedRhs, rhs)) begin
                `uvm_error("two_input_one_output_with_carry_transaction", "do_copy $cast() failed");
                return;
            end

            // get our parent to do their work first (typical of children)
            super.do_copy(rhs);

            // copy our items over
            out = castedRhs.out;
            carryOut = castedRhs.carryOut;
        endfunction: do_copy

        function bit do_compare(uvm_object rhs, uvm_comparer comparer);
            two_input_one_output_with_carry_transaction #(.INPUT_WIDTH(INPUT_WIDTH), .OUTPUT_WIDTH(OUTPUT_WIDTH)) castedRhs;

            // cast the generic uvm_object to our type
            // if it fails, then the object passed in was not of a valid type
            if (!$cast(castedRhs, rhs)) begin
                `uvm_error("two_input_one_output_with_carry_transaction", "do_compare $cast() failed");
                return 0;
            end

            // check if our parent compares OK first
            // then compare our fields
            return (super.do_compare(rhs, comparer) &&
                    out === castedRhs.out &&
                    carryOut === castedRhs.carryOut);
        endfunction: do_compare

        function string convert2string();
            return { super.convert2string(), " ", outputs2string() };
        endfunction: convert2string

    endclass: two_input_one_output_with_carry_transaction
endpackage: two_input_one_output_with_carry_transaction_pkg
