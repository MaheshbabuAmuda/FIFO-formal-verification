module fifo_ppt ();

//define macro to bind rtl signals with the assertion signals 
  
    `define clk fifo.clk
    `define rst_n fifo.rst_n
    `define rd_n fifo.rd_n
    `define wr_n fifo.wr_n
    `define data_in fifo.data_in
    `define data_out fifo.data_out
    `define over_flow fifo.over_flow
    `define under_flow fifo.under_flow
    `define fifo_status fifo.fifo_status
    `define read_ptr fifo.read_ptr
    `define write_ptr fifo.write_ptr
    `define full fifo.full
    `define empty fifo.empty
    `define fifo_mem fifo.fifo_mem


//DATA_IN RANGE CHECK – On every clock edge (when reset is inactive), data_in should lie within the valid range of 0x00 to 0xFF

    assert property (@(posedge `clk) disable iff (!`rst_n)
        `data_in inside {[8'h00:8'hFF]});

// DATA_IN CHECK – On every clock edge (when reset is inactive), data_in should not contain unknown (X or Z) values. 
      
    assert property (@(posedge `clk) disable iff (!`rst_n)
        !$isunknown(`data_in));
      
//DATA_OUT CHECK – On every clock edge (when reset is inactive), data_out should not contain unknown (X or Z) values. 

    assert property (@(posedge `clk) disable iff (!`rst_n)
        !$isunknown(`data_out));
      
//DATA_OUT STABILITY CHECK – When no read operation is active or the FIFO is empty, data_out should remain stable in the next clock cycle

    assert property (@(posedge `clk) disable iff (!`rst_n)
        ((`rd_n == 1 || `empty) |=> $stable(`data_out)));
      
//MEMORY STABILITY CHECK – When no write operation is active (wr_n is high) or the FIFO is full, 
      the memory location pointed to by write_ptr should remain unchanged in the next clock cycle. 

    assert property (@(posedge `clk) disable iff (!`rst_n)
        (`wr_n || `full) |=> (`fifo_mem[`write_ptr] == $past(`fifo_mem[`write_ptr])));
      
// RESET PROPERTY - on reset read_ptr, write_ptr, fifo_status,over_flow and under_flow must be initialized with zero.

     property reset_prty;
        @(posedge `clk)
        $rose(`rst_n) |-> (`read_ptr ==0) && (`write_ptr ==0) && (`fifo_status == 0) && (`over_flow ==0) && (`under_flow == 0);
    endproperty
    RESET : assert property (reset_prty);

// FIFO FULL - If fifo_status is 15 & fifo is not full,and write signal is enabled next cycle full will go high

      property full_prty;
        @(posedge `clk) disable iff (!`rst_n)
        (`fifo_status == `FIFO_DEPTH-1 && !`wr_n && !`full) |=> `full;
    endproperty
    FIFO_FULL : assert property (full_prty);

//FIFO EMPTY - If fifo_status is 0 & fifo is not empty,and read signal is enabled next cycle empty will go high

    property empty_prty;
        @(posedge `clk) disable iff (!`rst_n)
        (`fifo_status == 0 && !`rd_n && !`empty) |=> `empty;
    endproperty
    FIFO_EMPTY : assert property (empty_prty);

//FIFO OVERFLOW - If fifo is full and only write signal is enabled next cycle overflow will go high

    property overflow_prty;
        @(posedge `clk) disable iff (!`rst_n)
        (`full && !`wr_n && `rd_n) |=> `over_flow;
    endproperty
    OVERFLOW : assert property (overflow_prty);

//FIFO UNDERFLOW - If fifo is empty and only read signal is enabled next cycle underflow will go high

    property underflow_prty;
        @(posedge `clk) disable iff (!`rst_n)
        (`empty && !`rd_n && `wr_n) |=> `under_flow;
    endproperty
    UNDERFLOW : assert property (underflow_prty);

// Write pointer reset - If write signal is enabled and write pointer is 15, next cycle the write pointer resets back to 0
      
     property wr_rst_prty;
        @(posedge `clk) disable iff (!`rst_n)
        ((!`wr_n && !`full ) && ( `write_ptr == (`FIFO_DEPTH - 1))) |=> (`write_ptr == 0);
    endproperty
    FIFO_WR_RST : assert property (wr_rst_prty);

//Read pointer reset - If read signal is enabled and read pointer is 15, next cycle the read pointer resets back to 0

    property rp_rst_prty;
        @(posedge `clk) disable iff (!`rst_n)
        ((`rd_n == 0 && !`empty ) && ( `read_ptr == (`FIFO_DEPTH - 1))) |=> (`read_ptr == 0);
    endproperty
    FIFO_RP_RST : assert property (rp_rst_prty);


//Write pointer increment - After every write operation write pointer should increment 
      
    property wr_pointer;
        @(posedge `clk) disable iff (!`rst_n)
        ((`wr_n == 0) && !`full && (`write_ptr !=(`FIFO_DEPTH-1))) |=>(`write_ptr == $past(`write_ptr)+1);
    endproperty
    WR_PTR : assert property (wr_pointer);

// Read pointer increment - After every read operation read pointer should increment

    property rd_pointer;
        @(posedge `clk) disable iff (!`rst_n)
        ((`rd_n == 0) && !`empty  && (`read_ptr !=(`FIFO_DEPTH-1))) |=>(`read_ptr == $past(`read_ptr)+1);
    endproperty
    RD_PTR : assert property (rd_pointer);

//Fifo status increment - If fifo status is not equal to 15, full is 0, and only write signal is enabled next cycle fifo status will increment

    property wcnt_prty;
        @(posedge `clk) disable iff (!`rst_n)
        (`wr_n == 0 && `rd_n == 1 && !`full && (`fifo_status < `FIFO_DEPTH-1)) |=> (`fifo_status == $past(`fifo_status) + 1);
    endproperty
    STATUS_WCNT : cover property (wcnt_prty);
      
 //Fifo status decrement - If fifo status is not equal to 0, empty is 0, and only read signal is enabled next cycle fifo status will decrement

    property rcnt_prty;
        @(posedge `clk) disable iff (!`rst_n)
        (`rd_n == 0 && `wr_n == 1 && !`empty  && (`fifo_status > 0) |=> `fifo_status == $past(`fifo_status) - 1);
    endproperty
    STATUS_RCNT : cover property (rcnt_prty);

endmodule: fifo_ppt

// Bind to DUT instance
bind fifo fifo_ppt inst (.*);

