`include "uvm_macros.svh"

// This scoreboard architecture is based off the second part of
// http://sunburst-design.com/papers/CummingsSNUG2013SV_UVM_Scoreboards.pdf
// Our scoreboard is just a container for a comparator and a predictor
// the predictor gets the inputs to the DUT and predicts the output.
// the prediction is passed to the comparator.
// the comparator receives a prediction and the actual output and compares them.

// requirements to use this:
//  the input transaction must have defined:
//   function string inputs2string()
//  the output transaction must have defined:
//   function string outputs2string()
//   function logic compare_outputs(output_transaction_type tx)
//   function void copy_inputs(input_transaction_type tx)
//  the predictor class must be extended and the predict_output function defined
//  you must pass in the inputs to the DUT and the outputs from the DUT using the relevant analysis ports

package basic_scoreboard_pkg;
    import uvm_pkg::*;

    // the predictor. We require that this is extended
    // since the predict_ouput function is pure virtual
    // the child class should be passed in to the basic_scoreboard class
    // as the predictor parameter.
    virtual class basic_scoreboard_predictor #(parameter type input_transaction_type, parameter type output_transaction_type) extends uvm_subscriber #(input_transaction_type);
        `uvm_component_param_utils(basic_scoreboard_predictor #(input_transaction_type, output_transaction_type))

        // our output analysis port (where we write the predicted output)
        // the input analysis port is defined in our parent class (uvm_subscriber)
        uvm_analysis_port #(output_transaction_type) output_aport;

        function new(string name, uvm_component parent);
            super.new(name, parent);
        endfunction: new

        function void build_phase(uvm_phase phase);
            output_aport = new("output_aport", this);
        endfunction: build_phase

        // this is the function that our child class must overwrite
        pure virtual function output_transaction_type predict_output(input_transaction_type tx);

        // This is the input analysis port's write function
        // ie. this is where we get the inputs to the DUT.
        function void write(input_transaction_type t);
            // get our prediction
            output_transaction_type predicted = predict_output(t);

            // fill the inputs into our prediction transaction
            predicted.copy_inputs(t);

            `uvm_info("basic_scoreboard_predictor", $psprintf("Got inputs: %s, predicted outptu %s", t.inputs2string(), predicted.outputs2string()),UVM_HIGH);

            // send it to the comparator
            output_aport.write(predicted);
        endfunction: write

    endclass: basic_scoreboard_predictor

    // our comparator.
    // This can be extended and the send_data_out_on_pass method overriden.
    // That allows you to pass data to a coverage collector (or other subscriber)
    // on a sucessfull comparison.
    class basic_scoreboard_comparator #(parameter type transaction_type) extends uvm_component;
        `uvm_component_param_utils(basic_scoreboard_comparator #(transaction_type))

        // our analysis ports. One for predictions coming from the predictor
        // and one for the outputs from the DUT coming from a monitor
        uvm_analysis_export #(transaction_type) prediction_aport;
        uvm_analysis_export #(transaction_type) actual_aport;

        // the aports get connected to fifos, which are read from in the run_phase
        uvm_tlm_analysis_fifo #(transaction_type) prediction_fifo;
        uvm_tlm_analysis_fifo #(transaction_type) actual_fifo;

        // stats
        integer txCount = 0;
        integer txFail = 0;

        function new(string name, uvm_component parent);
            super.new(name, parent);
        endfunction: new

        function void build_phase(uvm_phase phase);
            prediction_aport    = new("prediction_aport", this);
            actual_aport        = new("actual_aport", this);
            prediction_fifo     = new("prediction_fifo", this);
            actual_fifo         = new("actual_fifo", this);
        endfunction: build_phase

        function void connect_phase(uvm_phase phase);
            // connect our analysis ports to the fifos.
            prediction_aport.connect(prediction_fifo.analysis_export);
            actual_aport.connect(actual_fifo.analysis_export);
        endfunction: connect_phase

        task run_phase(uvm_phase phase);
            forever begin
                transaction_type prediction;
                transaction_type actual;

                // wait for a prediction
                `uvm_info("basic_scoreboard_comparator", "Waiting for a prediction", UVM_FULL);
                prediction_fifo.get(prediction);
                `uvm_info("basic_scoreboard_comparator", $psprintf("Got a prediction: %s", prediction.outputs2string()), UVM_HIGH);

                // raise an objection so that the simulation doesn't end
                // until we get our actual output from the monitor
                phase.raise_objection(this);

                // wait for an actual output
                `uvm_info("basic_scoreboard_comparator", "Waiting for an actual output", UVM_FULL);
                actual_fifo.get(actual);
                `uvm_info("basic_scoreboard_comparator", $psprintf("Got an actual output: %s", prediction.outputs2string()), UVM_HIGH);

                txCount++;

                // compare them
                if (actual.compare_outputs(prediction)) begin
                    // Pass
                    `uvm_info("basic_scoreboard_comparator", "pass", UVM_HIGH);
                    send_data_out_on_pass(actual, prediction);
                end else begin
                    // Fail
                    txFail++;
                    `uvm_error("basic_scoreboard_comparator", $psprintf("Compare failed: inputs %s - prediction %s - actual outputs %s", prediction.inputs2string(), prediction.outputs2string(), actual.outputs2string()));
                end

                // drop the objection. If the test also drops it's objections
                // then we can end the run phase
                phase.drop_objection(this);
            end
        endtask: run_phase

        function void report_phase(uvm_phase phase);
            if (!txCount) begin
                `uvm_error("basic_scoreboard_comparator", "No transactions detected");
            end else if (txFail) begin
                `uvm_error("basic_scoreboard_comparator", $psprintf("Errors detected: %d transactions, %d failed", txCount, txFail));
            end else begin
                `uvm_info("basic_scoreboard_comparator", $psprintf("%d transactions, all OK", txCount), UVM_NONE);
            end
        endfunction: report_phase

        virtual function void send_data_out_on_pass(transaction_type actual, transaction_type prediction);
            // by default does nothing

            // extend and overwrite to send data out on a pass.
            // data sent could be the transaction or it could be different.
            // See: https://verificationacademy.com/cookbook/coverage/block_level_functional_coverage_example
            // In that example, looking at the uart tx coverage, we send out the
            // value of the LCR register for coverage
        endfunction: send_data_out_on_pass
    endclass: basic_scoreboard_comparator

    // Our scoreboard.
    // This just connects the monitors, predictor and comparator together
    class basic_scoreboard #(parameter type predictor_type,
                             parameter type input_transaction_type,
                             parameter type output_transaction_type,
                             parameter type comparator_type = basic_scoreboard_comparator #(.transaction_type(output_transaction_type)))
                           extends uvm_scoreboard;
        `uvm_component_param_utils(basic_scoreboard #(predictor_type, input_transaction_type, output_transaction_type, comparator_type))

        // our predictor. Should be an extension of basic_scoreboard_predictor
        predictor_type predictor;

        // our comparator
        comparator_type comparator;

        // our analysis ports from the monitors
        // note: output_aport is actually the input from the monitor that looks at the DUT's outputs
        uvm_analysis_export #(input_transaction_type) input_aport;
        uvm_analysis_export #(output_transaction_type) output_aport;

        function new(string name, uvm_component parent);
            super.new(name, parent);
        endfunction: new

        function void build_phase(uvm_phase phase);
            // create our analysis ports
            input_aport = new("input_aport", this);
            output_aport = new("output_aport", this);

            // create our predictor and comparator
            predictor = predictor_type::type_id::create("predictor", this);
            comparator = comparator_type::type_id::create("comparator", this);
        endfunction: build_phase

        function void connect_phase(uvm_phase phase);
            // connect the monitor watching the DUT's inputs to the predictor
            input_aport.connect(predictor.analysis_export);

            // connect the monitor watching the DUT's outputs to the comparator
            output_aport.connect(comparator.actual_aport);

            // connect the predictor to the comparator
            predictor.output_aport.connect(comparator.prediction_aport);
        endfunction: connect_phase
    endclass: basic_scoreboard
endpackage
