class fifo_transaction;

    //-----------------------------------------
    // Random Inputs
    //-----------------------------------------

    rand bit write;
    rand bit read;

    rand bit [7:0] data;

    //-----------------------------------------
    // DUT Outputs
    //-----------------------------------------

    bit [7:0] rdata;

    //-----------------------------------------
    // Constraints
    //-----------------------------------------

    constraint valid_operation {

        write || read;

    }

    //-----------------------------------------
    // Display Method
    //-----------------------------------------

    function void display(string tag);

        $display("------------------------------------------");
        $display("[%s]", tag);
        $display("WRITE = %0d", write);
        $display("READ  = %0d", read);
        $display("WDATA = %0h", data);
        $display("RDATA = %0h", rdata);
        $display("------------------------------------------");

    endfunction

endclass
