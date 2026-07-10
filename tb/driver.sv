class driver;

    //-----------------------------------------
    // Virtual Interface
    //-----------------------------------------
    virtual fifo_if vif;

    //-----------------------------------------
    // Mailbox
    //-----------------------------------------
    mailbox #(fifo_transaction) gen2drv;

    //-----------------------------------------
    // Constructor
    //-----------------------------------------
    function new(virtual fifo_if vif,
                 mailbox #(fifo_transaction) gen2drv);

        this.vif     = vif;
        this.gen2drv = gen2drv;

    endfunction

    //-----------------------------------------
    // Run Task
    //-----------------------------------------
    task run();

        fifo_transaction tr;

        forever begin

            gen2drv.get(tr);

            // Drive write side
            @(posedge vif.wclk);
            vif.winc  <= tr.write;
            vif.wdata <= tr.data;

            // Drive read side
            @(posedge vif.rclk);
            vif.rinc <= tr.read;

            tr.display("DRIVER");

        end

    endtask

endclass
