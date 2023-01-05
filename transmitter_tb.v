/////////////////////////////////////////////////////
//                                                 //
//       MOHAMED GAD HAMZA METWALLY    1901131     //
//       ANDREW FAROUK MARKUS          1901134     //
//                                                 //
//                                                 //
/////////////////////////////////////////////////////

`include "UART_transmitter.v"
`define CLK @(posedge clk)

module transmitter_tb();
   	
  	reg clk, reset_n, tx_start;
  	reg [7 : 0] tx_din;

    wire tx_done_tick;
  	
  	wire	tx;
  wire tx_reg;
  
    // CLock Implementation
     always begin
        clk = 1'b0;
        #5;
        clk = 1'b1;
        #5;
    end

  UART_transmitter dut(.clk(clk),
            .reset_n(reset_n),
              .tx_start(tx_start),
            .tx(tx),
            .tx_done_tick (tx_done_tick),
            .tx_din (tx_din),
              .s_tick(clk),
              .tx_reg(tx_reg)
                 );
  	
initial begin
        reset_n = 1'b0;
  		tx_din = 8'h36;
     	repeat (2) `CLK;
  		tx_start = 1'b1;
      	reset_n = 1'b1;
 
  
  repeat (161) `CLK;
  $finish();
end
    	
    initial begin
        $dumpfile("abp_master.vcd");
      $dumpvars(2,transmitter_tb);
    end

endmodule