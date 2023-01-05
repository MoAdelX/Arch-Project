/////////////////////////////////////////////////////
//                                                 //
//       MOHAMED GAD HAMZA METWALLY    1901131     //
//       ANDREW FAROUK MARKUS          1901134     //
//                                                 //
//                                                 //
/////////////////////////////////////////////////////
module UART_transmitter  
#(parameter DBIT = 8,       // n data bits
            SB_TICK = 16    //n stop bit ticks "1 stop bit"
            )
(
    input clk, reset_n,
    input tx_start, s_tick,
    input [DBIT - 1 : 0] tx_din,    
    output tx,
    reg tx_reg,
    output reg tx_done_tick
);

localparam  idle = 0,
            start = 1,
            data = 2,
            stop = 3;

reg [1:0] state_reg,state_next;
reg [3:0] s_reg, s_next;                      //counter to count number of ticks
reg [$clog2(DBIT) - 1 : 0] n_reg, n_next;    //counter to count number of shifted bits
reg [DBIT -1 : 0] b_reg , b_next;           //shift register
reg tx_next;

//state always block
always @(posedge clk , negedge reset_n) begin
     tx_done_tick = 1'b0;
    if(~reset_n) begin
        state_reg <= idle;
        s_reg <= 0;
        n_reg <= 0;
        b_reg <= 0;
        tx_reg <=1'b1;
    end
    else begin
        state_reg <= state_next;
        s_reg <= s_next;
        n_reg <= n_next;
        b_reg <= b_next;
        tx_reg <= tx_next;
    end
end
 
always @(*) begin
    state_next = state_reg;
    s_next = s_reg;
    n_next = n_reg;
    b_next = b_reg;

    case (state_reg)
        idle:
        begin
            tx_next = 1'b1;
            if (tx_start) begin
                tx_done_tick = 1'b1;
                s_next = 0;
                state_next = start;
            end
        end
             
        start:
        begin
            tx_next = 1'b0;

            if (s_tick) begin
                if (s_reg == 15) begin
                    s_next = 0;
                    n_next = 0;
                    b_next = tx_din;
                    state_next = data;
                end
                else
                    s_next = s_reg + 1 ;
            end
        end
            
        data:
        begin
            tx_next = b_reg[0];
            if (s_tick) begin
                if (s_reg == 15) begin
                    s_next = 0;
                    b_next = {1'b0, b_reg[DBIT -1 : 1]};  //right shift
                    if(n_reg == (DBIT - 1))
                        state_next = stop;
                    else
                        n_next = n_reg +1;
                end
                else
                    s_next = s_reg + 1 ;
            end
        end
            
        stop:
        begin
            tx_next = 1'b1;
            if (s_tick) begin
                if(s_reg == (SB_TICK -1)) begin
                    tx_done_tick = 1'b1;
                    state_next = idle;
                end
                else
                    s_next = s_reg +1;
            end
        end
            
        default:
            state_next = idle; 
    endcase
end

assign tx = tx_reg;

endmodule