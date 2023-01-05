
module gpio_tb();
   reg PCLK;  
   reg PSEL;
   reg PENABLE;
   reg PWRITE;
   reg [3:0]PADDR;
   reg [31:0]PWDATA;
   reg [31:0]gpio_in;
   reg PRESETn;
   wire PREADY;
   wire[31:0] gpio_out;
	 wire[31:0] gpio_dir;
	 wire[31:0] PRDATA;
 GPIO tb(PCLK,PSEL,PENABLE,PADDR,PWRITE,PWDATA,gpio_in,gpio_out,gpio_dir,PRDATA,PREADY);
initial
    begin
    // instantiate the gpio signals
     PCLK = 1'b1;
     PENABLE = 1'b0;
     PWRITE = 1'b0;
     PADDR = 0;
     PWDATA =0;
     PSEL = 1'b0;
     // Assert the reset signal
     PRESETn = 1'b0;
     // Deassert the reset signal
     #10
     PRESETn = 1'b1; // active low signal
     PSEL =1'b1;
     PENABLE = 1'b1;
     // Wait for the GPIO to stabilize
     #10;
 

    //write on gpio_dir
    PADDR  =4'h3; 
    PWRITE =1'b1;
    PWDATA =32'h0f0ff0f5; // 1 means OUTPUT , 0 means INPUT
    #10
    //write on gpio_out
    PADDR  =4'h2;
    PWRITE =1'b1;
    PWDATA =32'h01901573;
    #10
    //read from gpio_in
     PADDR  =4'h1;
     PWRITE = 1'b0;
     gpio_in = 32'hffffffff;
     #20
     // the gpio finish 
     PSEL =1'b0;
     PENABLE = 1'b0;
   end

    // Clock generator
    always #5 PCLK <= ~PCLK;
 
 
endmodule

