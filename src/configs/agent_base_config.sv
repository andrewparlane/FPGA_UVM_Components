`include "uvm_macros.svh"

package agent_base_config_pkg;
    import uvm_pkg::*;

    class agent_base_config #(type INTERFACE) extends uvm_object;
        `uvm_object_param_utils(agent_base_config #(INTERFACE))

        // our virtual interface through which we talk to the DUT
        INTERFACE vif;

        function new(string name = "agent_base_config");
            super.new(name);
        endfunction: new

    endclass: agent_base_config
endpackage: agent_base_config_pkg
