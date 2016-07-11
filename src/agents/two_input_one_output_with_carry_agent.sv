`include "uvm_macros.svh"

package two_input_one_output_with_carry_agent_pkg;
    import uvm_pkg::*;
    import two_input_with_carry_driver_pkg::*;
    import two_input_with_carry_transaction_pkg::*;
    import agent_base_config_pkg::*;

    class two_input_one_output_with_carry_agent #(parameter INPUT_WIDTH, parameter OUTPUT_WIDTH) extends uvm_agent;
        `uvm_component_param_utils(two_input_one_output_with_carry_agent #(INPUT_WIDTH, OUTPUT_WIDTH))

        typedef two_input_with_carry_transaction #(.WIDTH(INPUT_WIDTH)) driver_transaction_type;

        typedef agent_base_config #(.INTERFACE(virtual two_input_one_output_with_carry_if #(.INPUT_WIDTH(INPUT_WIDTH), .OUTPUT_WIDTH(OUTPUT_WIDTH)))) config_type;
        typedef two_input_with_carry_driver #(.WIDTH(INPUT_WIDTH)) driver_type;
        typedef uvm_sequencer #(driver_transaction_type) sequencer_type;

        // our configuration, passed in from the test using the uvm_config_db
        config_type agentConfig;

        // we currently have a driver and a sequencer
        driver_type driver;
        sequencer_type sequencer;

        // our analysis port
        // acts as a pass through from the driver to the environment
        // the driver passes the inputs that go into the DUT
        uvm_analysis_port #(driver_transaction_type) driver_aport;

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

            // create our analysis port
            driver_aport = new("driver_aport", this);

            // pass the virtual DUT interface to the driver
            driver.vif = agentConfig.vif;
        endfunction: build_phase

        function void connect_phase(uvm_phase phase);
            // connect the sequencer to the driver
            driver.seq_item_port.connect(sequencer.seq_item_export);
            // connect the driver to our driver pass through analysis port
            driver.aport.connect(driver_aport);
        endfunction: connect_phase

    endclass: two_input_one_output_with_carry_agent
endpackage: two_input_one_output_with_carry_agent_pkg
