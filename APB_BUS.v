module APB_BUS #(parameter DATA_WIDTH = 'd32,ADDRESS_WIDTH = 'd4,STRB_WIDTH = 'd4,SLAVES_NUM = 'd2) 
    (
    input  wire  [DATA_WIDTH-1:0]    PRDATA,
    input  wire  IN_WRITE,
    input  wire  [STRB_WIDTH-1:0]    IN_STRB,
    input  wire  Transfer,PREADY,PSLVERR,PCLK,PRESETn,
    /*PSLVERR error signal for failure in transfer,PRESET is active low,
    pready means that slave is ready to accept transactions */
    input  wire  [ADDRESS_WIDTH-1:0] IN_ADDR, //Address that'll be processed
    input  wire  [DATA_WIDTH-1:0]    IN_DATA,
    output reg   [DATA_WIDTH-1:0]    PWDATA,//Data to be written
    output reg   PWRITE,PENABLE,OUT_SLVERR,
    /*PWRITE to indicate direction of transaction, PPENABLE to control access to the bus */
    output reg   [STRB_WIDTH-1:0]    PSTRB      ,
    output reg   [DATA_WIDTH-1:0]    OUT_RDATA  ,
    output reg   [ADDRESS_WIDTH-1:0] PADDR, //Adress of data to be accessed
    output reg   [SLAVES_NUM-1:0]  PSEL //Select GPIO or UART
  ); 

  reg  [1:0]  current_state,next_state; // for the purposes of FSM

  localparam   [1:0]   IDLE     = 2'b00 ,
                       SETUP    = 2'b01 ,
                       ACCESS   = 2'b11 ;

  always @(posedge PCLK or negedge PRESETn)
    begin
      if(!PRESETn)
        begin
          current_state <= IDLE; //Initial state is always IDLE         
        end
      else
        begin
          current_state <= next_state; 
        end 
    end

  always@(*) //monitor all variables in the always block
    begin
      case(current_state)            
            IDLE:begin 
                    if(!Transfer)
                      begin next_state = IDLE; end
                    else
                      begin next_state = SETUP; end
                    end
          SETUP:begin next_state = ACCESS; 
                end
          ACCESS:begin
                  if(Transfer & !PSLVERR) //Transfer is starting without errors
                    begin
                      if(PREADY)
                      begin next_state = SETUP; end
                  else if(Transfer & !PREADY)
                      begin next_state = ACCESS; end
                    end
                  else 
                    begin next_state = IDLE; end
                  end
          default: next_state = IDLE; 
      endcase
    end
  //Address decoding stage and checking whether reset is asserted
  always @(posedge PCLK, negedge PRESETn) 
    begin
      if (!PRESETn)
        begin PSEL = 'b0; end
      else if (next_state == IDLE)
        begin
          PSEL = 'b0 ;
        end
      else
        begin
     	    case(IN_ADDR[3]) //choosing which slave, default is none if no address was coming
            1'b0: begin 
                      PSEL = 'b0000_0001 ;
                    end
            1'b1: begin 
                      PSEL = 'b0000_0010 ;
                    end
            default:begin 
                      PSEL = 'b0000_0000 ;
                    end
          endcase
        end
    end  

 always @(posedge PCLK, negedge PRESETn)
   begin
     if(!PRESETn)  //If the reset signal is asserted, then reset all signals
       begin
         PENABLE    <= 1'b0 ;
         PADDR      <= 8'b0 ;
         PWDATA     <=  'b0 ;
         PWRITE     <= 1'b0 ;
         OUT_RDATA  <=  'b0 ;
         PSTRB      <=  'b0 ;
         OUT_SLVERR <= 1'b0 ;
       end
     else if(next_state == SETUP)
       begin
         PENABLE   <= 1'b0     ; //Will be high only during the second cycle of transaction
         PADDR     <= IN_ADDR  ; //Take The address from the master
         PWRITE    <= IN_WRITE ; //Decide whether to read or write
         if(IN_WRITE)
           begin
             PWDATA <= IN_DATA ;
             PSTRB  <= IN_STRB ;
           end
         else 
           begin
             PSTRB <= 'b0 ;
           end 
       end
     else if(next_state == ACCESS)
       begin
         PENABLE <= 1'b1; //Slave is ready to communicate
         if(PREADY)
           OUT_SLVERR <= PSLVERR; 
           begin
             if(!IN_WRITE)
               begin OUT_RDATA <= PRDATA; end //Data is read from the slave
           end
          end 
      else
        begin
          PENABLE <= 1'b0; //Transfer has finished
        end 

   end 

 endmodule

