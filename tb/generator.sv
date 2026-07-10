class generator;

    //-----------------------------------------
    // Mailbox
    //-----------------------------------------

    mailbox #(fifo_transaction) gen2drv;

    //-----------------------------------------
    // Event
    //-----------------------------------------

    event done;

    //-----------------------------------------
    // Number of Transactions
    //-----------------------------------------

    int num_transactions = 200;

    //-----------------------------------------
    // Constructor
    //-----------------------------------------

    function new(mailbox #(fifo_transaction) gen2drv);

        this.gen2drv = gen2drv;

    endfunction

    //-----------------------------------------
    // Run Task
    //-----------------------------------------

    task run();

        fifo_transaction tr;

        repeat(num_transactions)
        begin

            tr = new();

            assert(tr.randomize())
            else
                $fatal("Randomization Failed");

            gen2drv.put(tr);

            tr.display("GENERATOR");

        end

        ->done;

    endtask

endclass
