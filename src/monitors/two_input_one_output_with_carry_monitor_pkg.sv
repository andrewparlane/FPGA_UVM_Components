`include "uvm_macros.svh"

package two_input_one_output_with_carry_monitor_pkg;
    import uvm_pkg::*;
    import two_input_one_output_with_carry_transaction_pkg::*;

    class two_input_one_output_with_carry_monitor #(parameter INPUT_WIDTH, parameter OUTPUT_WIDTH) extends uvm_monitor;
        `uvm_component_param_utils(two_input_one_output_with_carry_monitor #(INPUT_WIDTH, OUTPUT_WIDTH))

        typedef two_input_one_output_with_carry_transaction #(.INPUT_WIDTH(INPUT_WIDTH), .OUTPUT_WIDTH(OUTPUT_WIDTH)) transaction_type;

        // the virtual interface we use to talk to the DUT
        // passed in from the agent
        virtual two_input_one_output_with_carry_if #(.INPUT_WIDTH(INPUT_WIDTH),
                                                     .OUTPUT_WIDTH(OUTPUT_WIDTH)) vif;

        // the analysis port
        uvm_analysis_port #(transaction_type) aport;

        function new(string name, uvm_component parent);
            super.new(name, parent);
        endfunction: new

        function void build_phase(uvm_phase phase);
            // create the aport
            aport = new("aport", this);
        endfunction: build_phase

        task run_phase(uvm_phase phase);
            forever begin
                transaction_type tx;
                tx = transaction_type::type_id::create("tx");

                // sync to the falling of the clk,
                // as the driver sends on the rising edge
                // so we have time to see the results
                @(negedge vif.clk);
                // we only care about the output
                tx.out = vif.out;
                tx.carryOut = vif.carryOut;

                `uvm_info("monitor", $psprintf("Writing - %s", tx.outputs2string()), UVM_HIGH);
                aport.write(tx);
            end
        endtask: run_phase

    endclass: two_input_one_output_with_carry_monitor
endpackage: two_input_one_output_with_carry_monitor_pkg
