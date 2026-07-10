class test;

    //-----------------------------------------
    // Environment
    //-----------------------------------------

    environment env;

    //-----------------------------------------
    // Constructor
    //-----------------------------------------

    function new(virtual fifo_if vif);

        env = new(vif);

    endfunction

    //-----------------------------------------
    // Run
    //-----------------------------------------

    task run();

        $display("--------------------------------");
        $display(" Starting FIFO Verification ");
        $display("--------------------------------");

        env.run();

    endtask

endclass
