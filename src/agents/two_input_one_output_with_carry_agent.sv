`include "uvm_macros.svh"

package two_input_one_output_with_carry_agent_pkg;
    import uvm_pkg::*;
    import two_input_with_carry_driver_pkg::*;
    import two_input_with_carry_transaction_pkg::*;
    import agent_base_config_pkg::*;

    class two_input_one_output_with_carry_agent #(parameter WIDTH = 1) extends uvm_agent;
        `uvm_component_param_utils(two_input_one_output_with_carry_agent #(WIDTH))

        typedef agent_base_config #(.INTERFACE(virtual two_input_one_output_with_carry_if #(.INPUT_WIDTH(WIDTH), .OUTPUT_WIDTH(WIDTH)))) config_type;
        typedef two_input_with_carry_driver #(.WIDTH(WIDTH)) driver_type;
        typedef uvm_sequencer #(two_input_with_carry_transaction #(.WIDTH(WIDTH))) sequencer_type;

        // our configuration, passed in from the test using the uvm_config_db
        config_type agentConfig;

        // we currently have a driver and a sequencer
        driver_type driver;
        sequencer_type sequencer;

        function new (string name, uvm_component parent);
            super.new(name, parent);
        endfunction: new

        function void build_phase(uvm_phase phase);
            // create our config and get it from the config DB
            agentConfig = config_type::type_id::create("agentConfig");
            assert(uvm_config_db #(config_type)::get(this, "", "agent_config", agentConfig));

            // create our driver and sequencer
            driver = driver_type::type_id::create("driver", this);
            sequencer = sequencer_type::type_id::create("sequencer", this);

            // pass the virtual DUT interface to the driver
            driver.vif = agentConfig.vif;
        endfunction: build_phase

        function void connect_phase(uvm_phase phase);
            // connect the sequencer to the driver
            driver.seq_item_port.connect(sequencer.seq_item_export);
        endfunction: connect_phase

    endclass: two_input_one_output_with_carry_agent
endpackage: two_input_one_output_with_carry_agent_pkg
