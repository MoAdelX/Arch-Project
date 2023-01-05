module GPIO(PCLK,PSEL,PENABLE,PADDR,PWRITE,PWDATA,gpio_in,gpio_out,gpio_dir,PRDATA,PREADY);
  input PCLK,PSEL,PENABLE,PWRITE;
  input [3:0]PADDR;
	input [31:0]PWDATA,gpio_in;
	output reg [31:0]gpio_out,gpio_dir,PRDATA;
	output reg PREADY;
	
localparam in_adr = 4'h1,
           out_adr = 4'h2,
           dir_adr = 4'h3;
 
 
reg [31:0]INPUT,OUTPUT,DIR;
integer i;
always @(posedge PCLK)
  begin
    gpio_dir=DIR;
 
    for(i=0; i<32; i=i+1)
      begin
        /*
        dir[i] = 0  input
               = 1  output
        */
        gpio_out[i] <= gpio_dir[i]? OUTPUT[i] : 1'bz; // 
        INPUT[i] <= gpio_dir[i]? 1'bz : gpio_in[i];
      end
    if(!PSEL) 
    PREADY=1'b0;
    if (PENABLE && PSEL)
      begin
        PREADY=1'b1;
          if(PWRITE)
            begin
              if(PADDR == out_adr)
                begin
                  OUTPUT=PWDATA;
                end
                else if(PADDR == dir_adr)
                  begin
                    DIR=PWDATA;
                  end
            end
            else
              begin
                if(PADDR == in_adr)
                  begin
                    PRDATA=INPUT;
                  end
                if(PADDR == dir_adr)
                  begin
                    PRDATA=DIR;
                  end
              end
     end
  end
 
endmodule



