`include "uvm_macros.svh"

package two_input_with_carry_edge_cases_sequence_pkg;
    import uvm_pkg::*;
    import two_input_with_carry_transaction_pkg::*;

    class two_input_with_carry_edge_cases_sequence #(parameter WIDTH) extends uvm_sequence #(two_input_with_carry_transaction #(.WIDTH(WIDTH)));
        `uvm_object_param_utils(two_input_with_carry_edge_cases_sequence #(WIDTH))

        typedef two_input_with_carry_transaction #(.WIDTH(WIDTH)) transaction_type;

        rand integer transactionCount;

        constraint c_transactionCount { transactionCount > 0; transactionCount < 100; }

        function new(string name = "two_input_with_carry_edge_cases_sequence");
            super.new(name);
        endfunction: new

        task body;
            // we want to cover the cases:
            // in1 = 0,MAX,OTHER
            // in2 = 0,MAX,OTHER
            // carry = 0,1
            enum {
                ZERO = 0,
                MAX,
                OTHER,

                NUM_IN_VALS
            } in1Val, in2Val;

            // our transaction
            transaction_type tx;
            tx = transaction_type::type_id::create("tx");

            for (in1Val = in1Val.first; in1Val != NUM_IN_VALS; in1Val = in1Val.next) begin
                for (in2Val = in2Val.first; in2Val != NUM_IN_VALS; in2Val = in2Val.next) begin
                    repeat (transactionCount) begin
                        start_item(tx);
                        if (!tx.randomize()) begin
                            `uvm_error("two_input_with_carry_sequence", "randomize() failed");
                        end
                        tx.in1 = in1Val === ZERO ? 0  :
                                 in1Val === MAX  ? '1 :
                                                   tx.in1;   // the random var
                        tx.in2 = in2Val === ZERO ? 0  :
                                 in2Val === MAX  ? '1 :
                                                   tx.in2;   // the random var
                        finish_item(tx);
                    end
                end
            end
        endtask: body

    endclass: two_input_with_carry_edge_cases_sequence
endpackage: two_input_with_carry_edge_cases_sequence_pkg
