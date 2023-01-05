/////////////////////////////////////////////////////
//                                                 //
//       MOHAMED GAD HAMZA METWALLY    1901131     //
//       ANDREW FAROUK MARKUS          1901134     //
//                                                 //
//                                                 //
/////////////////////////////////////////////////////


module fifo(
    input [7:0] data_in, 
    input clk, rst, rd, wr,
    output empty, full, 
    output reg [7:0] data_out
    );

    reg [3:0] fifo_count;
    reg [7:0] fifo_ram[0:7];
    reg [2:0] rd_ptr, wr_ptr;
    assign empty = (fifo_count == 0);
    assign full = (fifo_count == 8);

  always @( posedge clk) begin: write 
        if(wr && !full)
            fifo_ram[wr_ptr] <= data_in;
    end

    always @(posedge clk ) begin: read
      if(rd && !empty)
            data_out <= fifo_ram[rd_ptr]; 
    end

    always @(posedge clk) begin: pointer //added negedge rst 
        if(~rst) begin 
            wr_ptr <= 0;
            rd_ptr <= 0;
        end else begin 
            wr_ptr <= ((wr && !full)) ? wr_ptr+1 : wr_ptr;
            rd_ptr <= ((rd && !empty)) ? rd_ptr+1 : rd_ptr;
        end
    end

    always @(posedge clk) begin: count //added negedge rst
      if(~rst) fifo_count = 0;
        else begin
            case({wr,rd})
                2'b00 : fifo_count <= fifo_count;
                2'b01 : fifo_count <= (fifo_count == 0) ? 0 : fifo_count-1;
                2'b10 : fifo_count <= (fifo_count == 8) ? 8 : fifo_count+1;
                default : fifo_count <= fifo_count;
            endcase
        end
    end
endmodule