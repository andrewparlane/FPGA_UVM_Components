`include "uvm_macros.svh"

package two_input_with_carry_sequence_pkg;
    import uvm_pkg::*;
    import two_input_with_carry_transaction_pkg::*;

    class two_input_with_carry_sequence #(parameter WIDTH) extends uvm_sequence #(two_input_with_carry_transaction #(.WIDTH(WIDTH)));
        `uvm_object_param_utils(two_input_with_carry_sequence #(WIDTH))

        typedef two_input_with_carry_transaction #(.WIDTH(WIDTH)) transaction_type;

        rand integer transactionCount;

        constraint c_transactionCount { transactionCount > 0; transactionCount < 100; }

        function new(string name = "two_input_with_carry_sequence");
            super.new(name);
        endfunction: new

        task body;
            repeat (transactionCount) begin
                transaction_type tx;
                tx = transaction_type::type_id::create("tx");

                start_item(tx);
                assert(tx.randomize());
                finish_item(tx);
            end
        endtask: body

    endclass: two_input_with_carry_sequence
endpackage: two_input_with_carry_sequence_pkg