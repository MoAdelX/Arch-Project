/////////////////////////////////////////////////////
//                                                 //
//       MOHAMED GAD HAMZA METWALLY    1901131     //
//       ANDREW FAROUK MARKUS          1901134     //
//                                                 //
//                                                 //
/////////////////////////////////////////////////////


//`include "timer_input.v"
`include "UART_receiver.v"
`include "UART_transmitter.v"
`include "fifo.v"

module uart
  #(
    parameter DBIT = 8,		// # number of data bits
    		  SB_TICK =16	// # number of ticks
  )
  (
    input clk, reset_n,
    	
    
    
   	//transmitter ports
    input [DBIT -1 : 0] w_data,	//data input parallel to uart
    input wr_uart,				//enable write to uart port
    output tx,					//serial output data
    output tx_full,				//indicate that FIFO is full
    
    //receiver ports
    input rd_uart,				//flag to start reading from uart
    input rx,					//serial data input
    output rx_empty,			//flag to indicate that the FIFO is empty and there is no data to read
    output [DBIT - 1: 0] r_data,	//parallel output data
    output rx_done_tick,
    output [DBIT - 1 : 0] rx_dout,
    output fifo_full
    
  );
  
  //receiver
  //wire rx_done_tick;
  //wire [DBIT - 1 : 0] rx_dout;
  
  UART_receiver #(.DBIT(DBIT), .SB_TICK(SB_TICK)) receiver(
    .clk(clk),
    .reset_n(reset_n),
    .rx(rx),
    .s_tick(clk),
    .rx_done_tick(rx_done_tick),
    .rx_dout(rx_dout)
  );

