`timescale 1ns/100ps
module APB_BUS_TB ();

//defining test parameters
parameter DATA_WIDTH_TB = 'd32,ADDRESS_WIDTH_TB = 'd4,STRB_WIDTH_TB = 'd4,SLAVES_NUM_TB = 'd2;
  	reg  [DATA_WIDTH_TB-1:0] IN_DATA_TB,PRDATA_TB;            
	reg  IN_WRITE_TB  ;   
	reg  [STRB_WIDTH_TB-1:0]     IN_STRB_TB;    
	reg                          Transfer_TB,PREADY_TB,PSLVERR_TB,PCLK_TB,PRESETn_TB;  
	reg  [ADDRESS_WIDTH_TB-1:0]  IN_ADDR_TB   ;    
              
 	wire                          OUT_SLVERR_TB;  
 	wire   [DATA_WIDTH_TB-1:0]    OUT_RDATA_TB ;  
 	wire   [ADDRESS_WIDTH_TB-1:0] PADDR_TB     ;      
 	wire   [DATA_WIDTH_TB-1:0]    PWDATA_TB    ;     
 	wire                          PWRITE_TB    ;     
 	wire                          PENABLE_TB   ;         
 	wire   [STRB_WIDTH_TB-1:0]    PSTRB_TB     ;      
 	wire   [SLAVES_NUM_TB-1:0]    PSEL_TB      ;  

initial
begin
	init();
	
	rst();
	
    $display("////////////////////////////////////// write opteration with no waits//////////////////////////////////////////");
    write_no_wait('b10,'b01);
  
    $display("/////////////////////////////////////Test write opteration with waits////////////////////////////////////////////");
    write_with_wait('b10,'b01);
  
  	$display("/////////////////////////////////////Test read opteration with no waits//////////////////////////////////////////");
    read_no_wait('b10,'b01);
  
    $display("/////////////////////////////////////Test read opteration with waits////////////////////////////////////////////");
    read_with_wait('b10,'b01);
	
  #20

$finish;
end

always #5 PCLK_TB = ~ PCLK_TB; //Generate a clock
 
 APB_BUS #(.DATA_WIDTH(DATA_WIDTH_TB),  .ADDRESS_WIDTH(ADDRESS_WIDTH_TB), .STRB_WIDTH(STRB_WIDTH_TB), .SLAVES_NUM(SLAVES_NUM_TB))
 DUT (.PCLK(PCLK_TB),.PRESETn(PRESETn_TB),.IN_ADDR(IN_ADDR_TB),.IN_DATA(IN_DATA_TB),.PRDATA(PRDATA_TB),.IN_WRITE(IN_WRITE_TB),.Transfer(Transfer_TB),
 .PREADY(PREADY_TB),.PSLVERR(PSLVERR_TB),.IN_STRB(IN_STRB_TB),.PSTRB(PSTRB_TB),.OUT_SLVERR(OUT_SLVERR_TB),.OUT_RDATA(OUT_RDATA_TB),.PADDR(PADDR_TB),.PWDATA(PWDATA_TB),
 .PWRITE(PWRITE_TB),.PENABLE(PENABLE_TB),.PSEL(PSEL_TB));


task init(); //initially set everything to default
 begin
	# 10

	PCLK_TB = 'b0;
	PRESETn_TB = 'b1;
	PSLVERR_TB = 'b0;
	Transfer_TB = 'b0;
	PREADY_TB = 'b0;
	IN_ADDR_TB = 4'b1011;
	IN_DATA_TB = 'd0;
	IN_STRB_TB = 'b0101;
	IN_WRITE_TB = 'b0;
	PRDATA_TB = 'b0;
	end 
endtask

task rst();
 begin
	PRESETn_TB = 'b1;	
	#10 	
	PRESETn_TB = 'b0;	
	#10 	
	PRESETn_TB = 'b1;	
	end 
endtask

//Write operation with no wait
task write_no_wait(input reg  [SLAVES_NUM_TB-1:0]  SLAVE1,SLAVE2); 
begin
    #10
    Transfer_TB = 'b1;
	IN_ADDR_TB = 4'b1111;   //address chosen is 1111
	IN_DATA_TB = 'd240;     //desired data to be dested
	IN_WRITE_TB = 'b1;
	PREADY_TB = 'b0;
    #15
    $display("First write with no wait test");
    if (PSEL_TB == SLAVE1 && PADDR_TB == IN_ADDR_TB && PWDATA_TB == IN_DATA_TB)
       $display("First Setup success");	
	else
       $display("An error has occured with the first setup");	
	#5
	PREADY_TB = 'b1;
	#10
	//Put the second transfer data
	IN_ADDR_TB = 4'b0001;  //now send in address 0001
	IN_DATA_TB = 'd15;
	PREADY_TB = 'b0;
	#5
    if (PENABLE_TB == 1'b0)
       $display("First write operation is successful");	
	else
       $display("First write operation has failed");	
  
	#5
	$display("Second write operation");
    if(PSEL_TB == SLAVE2 && PADDR_TB == IN_ADDR_TB && PWDATA_TB == IN_DATA_TB)
       $display("Second write operation is successful");	
	else
       $display("Second write operation has failed");	
	   
	PREADY_TB = 'b1;
	Transfer_TB = 'b0;
	#10
	PREADY_TB = 'b0;
	#5
    if(PENABLE_TB == 1'b0)
       $display("Successful");	
	else
       $display("Error with second operation");	
    
	  #15
	if(PENABLE_TB == 1'b0)
       $display("Master returns to IDLE");	
	else
       $display("Error with master operation");
end
endtask

//Write operation with wait
task write_with_wait(
    input reg  [SLAVES_NUM_TB-1:0]  SLAVE1,input reg  [SLAVES_NUM_TB-1:0]  SLAVE2);
begin
  	#10
  	Transfer_TB = 'b1;
	IN_ADDR_TB = 4'b1111; //address will be initially 1111
	IN_DATA_TB = 'd240;
	IN_WRITE_TB = 'b1;
	PREADY_TB = 'b0;
    #15
    $display("First write test");
    if (PSEL_TB == SLAVE1 && PADDR_TB == IN_ADDR_TB && PWDATA_TB == IN_DATA_TB)
       $display("First setup with no errors");	
	else
       $display("Error with first setup");	
	#25
	if (PENABLE_TB == 1'b1)
       $display("Master is waiting");	
	else
       $display("Error: Master didn't wait");	
       
	PREADY_TB = 'b1;
	#10
	//put the second transfer data
	IN_ADDR_TB = 4'b0001;    
	IN_DATA_TB = 'd15;
	PREADY_TB = 'b0;
	#5
    if (PENABLE_TB == 1'b0)
       $display("First write operation is done");	
	else
       $display("First write operation reported an error");	
  
	#5
	$display("Second write operation");
    if (PSEL_TB == SLAVE2 && PADDR_TB == IN_ADDR_TB && PWDATA_TB == IN_DATA_TB)
       $display("Second setup was successful");	
	else
       $display("An error occured with the second setup");
	
	#20
	if (PENABLE_TB == 1'b1)
       $display("Master is waiting");	
	else
       $display("Error: Master didn't wait");	
       
	PREADY_TB = 'b1;
	Transfer_TB = 'b0;
	#10
	PREADY_TB = 'b0;
	#5
    if (PENABLE_TB == 1'b0)
       $display("Second write operation was successful");	
	else
       $display("Second write operation reported an error");	
    
	  #15
	  if (PENABLE_TB == 1'b0)
       $display("Master returns to IDLE state");	
	else
       $display("Error in Master operation");
end
endtask

// read with no wait 
task read_no_wait(
    input reg  [SLAVES_NUM_TB-1:0]  SLAVE1,
	 input reg  [SLAVES_NUM_TB-1:0]  SLAVE2
);
begin
    #10
    Transfer_TB = 'b1;
	IN_ADDR_TB = 4'b1111; //address to 1111
	IN_WRITE_TB = 'b0;
	PREADY_TB = 'b0;
    #15
    $display("First read with no wait test");
    if (PSEL_TB == SLAVE1 && PADDR_TB == IN_ADDR_TB)
       $display("First setup was successful");	
	else
       $display("Something went wrong with the first setup");	
	#5
	
	PREADY_TB = 'b1; //ready to begin transaction
	PRDATA_TB = 'd240;
	#10
  	//prepare for the second transfer simultaneously
	IN_ADDR_TB = 4'b0001;  //to address 0001
	PREADY_TB = 'b0;

	#5
	if (OUT_RDATA_TB == PRDATA_TB && PENABLE_TB == 1'b0)
       $display("First read operation was successful");	
	else
       $display("First read operation reported an error");	

	   
	$display("Second read operation");
    if (PSEL_TB == SLAVE2 && PADDR_TB == IN_ADDR_TB)
       $display("Second read setup was successful");	
	else
       $display("Second read setup reported an error");		
	   
	#5
	PREADY_TB = 'b1;
	PRDATA_TB = 'd15;
	#5
	Transfer_TB = 'b0;
    #5
	PREADY_TB = 'b0;
	#5
    if (OUT_RDATA_TB == PRDATA_TB && PENABLE_TB == 1'b0)
       $display("Second read finished with no errors");	
	else
       $display("an error occured with the second read operation");	
	#25
	if (PENABLE_TB == 1'b0)
       $display("Operations have finished and master returns to IDLE");	
	else
       $display("Master has an error");
end
endtask

// Read with wait
task read_with_wait(
    input reg  [SLAVES_NUM_TB-1:0]  SLAVE1,
	 input reg  [SLAVES_NUM_TB-1:0]  SLAVE2
);
begin
    #10
    Transfer_TB = 'b1;
	IN_ADDR_TB = 4'b1111;
	IN_WRITE_TB = 'b0;
	PREADY_TB = 'b0;
    #15
    $display("First read operation");
    if (PSEL_TB == SLAVE1 && PADDR_TB == IN_ADDR_TB)
       $display("First setup operation went with no errors");	
	else
       $display("Something went wrong with the first setup");		
	#25
	if (PENABLE_TB == 1'b1)
       $display("Master is waiting for the slave to be ready");	
	else
       $display("Error: Master didn't wait");	
	
	PREADY_TB = 'b1;
	PRDATA_TB = 'd240;
    #10

	IN_ADDR_TB = 4'b0001; 
	PREADY_TB = 'b0;

	#5
	if (OUT_RDATA_TB == PRDATA_TB && PENABLE_TB == 1'b0)
       $display("First read operation was done with no errors");	
	else
       $display("First read operation reported an error");
	
  
	$display("Second read operation");
    if (PSEL_TB == SLAVE2 && PADDR_TB == IN_ADDR_TB)
       $display("Second read setup was done successfully");	
	else
       $display("Second read setup reported an error");
	   
	#25
	if (PENABLE_TB == 1'b1)
       $display("Master is waiting for the slave to be ready");	
	else
       $display("Error: Master didn'tw ait");	
	   
	PREADY_TB = 'b1;
	PRDATA_TB = 'd15;
	#5
	Transfer_TB = 'b0;
    #5
	PREADY_TB = 'b0;
	#5
    if (OUT_RDATA_TB == PRDATA_TB && PENABLE_TB == 1'b0)
       $display("Second read operation was done with no errors");	
	else
       $display("Second read operation encountered an error");	
  
	
	#25
	if (PENABLE_TB == 1'b0)
    	$display("Master has returned to IDLE");	
	else
       $display("Master reported an error while finishing");
end
endtask
endmodule


