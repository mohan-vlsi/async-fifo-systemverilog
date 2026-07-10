class monitor;

    //-----------------------------------------
    // Virtual Interface
    //-----------------------------------------
    virtual fifo_if vif;

    //-----------------------------------------
    // Mailbox
    //-----------------------------------------
    mailbox #(fifo_transaction) mon2scb;

    //-----------------------------------------
    // Constructor
    //-----------------------------------------
    function new(virtual fifo_if vif,
                 mailbox #(fifo_transaction) mon2scb);

        this.vif = vif;
        this.mon2scb = mon2scb;

    endfunction

    //-----------------------------------------
    // Run Task
    //-----------------------------------------
    task run();

        fifo_transaction tr;

        forever begin

            tr = new();

            @(posedge vif.rclk);

            tr.write = vif.winc;
            tr.read  = vif.rinc;
            tr.data  = vif.wdata;
            tr.rdata = vif.rdata;

            mon2scb.put(tr);

            tr.display("MONITOR");

        end

    endtask

endclass
