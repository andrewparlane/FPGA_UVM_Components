`include "uvm_macros.svh"

package two_input_with_carry_driver_pkg;
    import uvm_pkg::*;
    import two_input_with_carry_transaction_pkg::*;

    class two_input_with_carry_driver #(parameter WIDTH = 1) extends uvm_driver #(two_input_with_carry_transaction #(.WIDTH(WIDTH)));
        `uvm_component_param_utils(two_input_with_carry_driver #(WIDTH))

        typedef two_input_with_carry_transaction #(.WIDTH(WIDTH)) transaction_type;

        // tracks how many transactions have been sent out
        int txCount = 0;

        // the virtual interface we use to talk to the DUT
        virtual two_input_one_output_with_carry_if #(.INPUT_WIDTH(WIDTH),
                                                     .OUTPUT_WIDTH(WIDTH)) vif;

        function new(string name, uvm_component parent);
            super.new(name, parent);
        endfunction: new

        task run_phase(uvm_phase phase);
            forever begin
                transaction_type tx;

                @(posedge vif.clk);
                seq_item_port.get_next_item(tx);
                txCount++;
                `uvm_info("driver", $psprintf("tx %d - %s", txCount, tx.convert2string()), UVM_HIGH);
                vif.in1 = tx.in1;
                vif.in2 = tx.in2;
                vif.carryIn = tx.carryIn;

                seq_item_port.item_done();
            end
        endtask: run_phase
    endclass: two_input_with_carry_driver
endpackage: two_input_with_carry_driver_pkg
