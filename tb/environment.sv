class environment;

    //-----------------------------------------
    // Components
    //-----------------------------------------

    generator  gen;
    driver     drv;
    monitor    mon;
    scoreboard scb;

    //-----------------------------------------
    // Mailboxes
    //-----------------------------------------

    mailbox #(fifo_transaction) gen2drv;
    mailbox #(fifo_transaction) mon2scb;

    //-----------------------------------------
    // Virtual Interface
    //-----------------------------------------

    virtual fifo_if vif;

    //-----------------------------------------
    // Constructor
    //-----------------------------------------

    function new(virtual fifo_if vif);

        this.vif = vif;

        gen2drv = new();
        mon2scb = new();

        gen = new(gen2drv);
        drv = new(vif, gen2drv);
        mon = new(vif, mon2scb);
        scb = new(mon2scb);

    endfunction

    //-----------------------------------------
    // Run Task
    //-----------------------------------------

    task run();

        fork
            gen.run();
            drv.run();
            mon.run();
            scb.run();
        join_any

    endtask

endclass
