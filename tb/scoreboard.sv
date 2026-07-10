class scoreboard;

    //-----------------------------------------
    // Mailbox
    //-----------------------------------------
    mailbox #(fifo_transaction) mon2scb;

    //-----------------------------------------
    // Reference FIFO
    //-----------------------------------------
    bit [7:0] ref_fifo[$];

    //-----------------------------------------
    // Statistics
    //-----------------------------------------
    int pass_count = 0;
    int fail_count = 0;

    //-----------------------------------------
    // Constructor
    //-----------------------------------------
    function new(mailbox #(fifo_transaction) mon2scb);

        this.mon2scb = mon2scb;

    endfunction

    //-----------------------------------------
    // Run Task
    //-----------------------------------------
    task run();

        fifo_transaction tr;
        bit [7:0] expected;

        forever begin

            mon2scb.get(tr);

            //---------------------------------
            // Write
            //---------------------------------
            if(tr.write)
                ref_fifo.push_back(tr.data);

            //---------------------------------
            // Read
            //---------------------------------
            if(tr.read && ref_fifo.size() > 0)
            begin

                expected = ref_fifo.pop_front();

                if(expected == tr.rdata)
                begin
                    pass_count++;
                    $display("[PASS] Expected=%0h Actual=%0h",
                             expected,tr.rdata);
                end
                else
                begin
                    fail_count++;
                    $display("[FAIL] Expected=%0h Actual=%0h",
                             expected,tr.rdata);
                end

            end

        end

    endtask

endclass
