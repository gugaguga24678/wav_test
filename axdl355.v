module adxl355(
    input clk,
    input rst,
    input uart_eop,
    input rx,
    output reg tx,
    output reg sclk,
    output reg cs_n,
    output reg [19:0] xdata,
    output reg [19:0] ydata,
    output reg [19:0] zdata,
    output reg done = 0
);

reg [14:0] wr_data_tx;
reg flag = 1'b0;
reg [3:0] cnt = 4'd0;
reg [3:0] cnt_d1 = 4'd0;

wire wr_sclk;
wire wr_tx;
wire wr_cs_n;
reg wr_req;
wire wr_done;

wire rd_sclk;
wire rd_tx;
wire rd_cs_n;
wire [7:0] rd_data_rx;
reg [7:0] addr;
reg rd_req;
wire rd_done;

spi_wr spi_wr(
    .clk(clk),
    .rst(rst),
    .sclk(wr_sclk),
    .tx(wr_tx),
    .rx(rx),
    .cs_n(wr_cs_n),
    .data_tx(wr_data_tx),
    .req(wr_req),
    .done(wr_done)
);


spi spi(
    .clk(clk),
    .rst(rst),
    .sclk(rd_sclk),
    .tx(rd_tx),
    .rx(rx),
    .cs_n(rd_cs_n),
    .data_rx(rd_data_rx),
    .data_tx(addr),
    .req(rd_req),
    .done(rd_done)
);

always@(posedge clk)begin
    if(uart_eop)
        flag <= 1'b1;
    else if(cnt==4'd11)
        flag <= 1'b0;
    else
        flag <= flag;
end

always@(posedge clk)begin
    case(cnt)
        4'd0:
            cnt <= cnt + 1'b1;
        4'd1:begin
            if(cnt_d1==4'd0)
                wr_req <= 1'b1;
            else
                wr_req <= 1'b0;
            wr_data_tx <= 15'h2801;
            if(wr_done)
                cnt <= cnt + 1'b1;
            else
                cnt <= cnt;
        end
        4'd2:begin
            if(cnt_d1==4'd1)
                wr_req <= 1'b1;
            else
                wr_req <= 1'b0;
            wr_data_tx <= 15'h2d00;
            if(wr_done)
                cnt <= cnt + 1'b1;
            else
                cnt <= cnt;
        end
        4'd3:begin
            if(cnt_d1==4'd2|cnt_d1==4'd12)
                rd_req <= 1'b1;
            else
                rd_req <= 1'b0;
            addr <= 8'h00;
            if(rd_done) begin
                xdata[19:12] <= rd_data_rx;
                cnt <= cnt + 1'b1;
            end
            else
                cnt <= cnt;
        end
        4'd4:begin
            if(cnt_d1==4'd3)
                rd_req <= 1'b1;
            else
                rd_req <= 1'b0;
            addr <= 8'h01;
            if(rd_done)begin
                xdata[11:4] <= rd_data_rx;
                cnt <= cnt + 1'b1;
            end
            else
                cnt <= cnt;
        end
        4'd5:begin
            if(cnt_d1==4'd4)
                rd_req <= 1'b1;
            else
                rd_req <= 1'b0;
            addr <= 8'ha;
            if(rd_done)begin
                xdata[3:0] <= rd_data_rx[7:4];
                cnt <= cnt + 1'b1;
            end
            else
                cnt <= cnt;
        end
        4'd6:begin
            if(cnt_d1==4'd5)
                rd_req <= 1'b1;
            else
                rd_req <= 1'b0;
            addr <= 8'hb;
            if(rd_done)begin
                ydata[19:12] <= rd_data_rx;
                cnt <= cnt + 1'b1;
            end
            else
                cnt <= cnt;
        end
        4'd7:begin
            if(cnt_d1==4'd6)
                rd_req <= 1'b1;
            else
                rd_req <= 1'b0;
            addr <= 8'hc;
            if(rd_done)begin
                ydata[11:4] <= rd_data_rx;
                cnt <= cnt + 1'b1;
            end
            else
                cnt <= cnt;
        end
        4'd8:begin
            if(cnt_d1==4'd7)
                rd_req <= 1'b1;
            else
                rd_req <= 1'b0;
            addr <= 8'hd;
            if(rd_done)begin
                ydata[3:0] <= rd_data_rx[7:4];
                cnt <= cnt + 1'b1;
            end
            else
                cnt <= cnt;
        end
        4'd9:begin
            if(cnt_d1==4'd8)
                rd_req <= 1'b1;
            else
                rd_req <= 1'b0;
            addr <= 8'he;
            if(rd_done)begin
                zdata[19:12] <= rd_data_rx;
                cnt <= cnt + 1'b1;
            end
            else
                cnt <= cnt;
        end
        4'd10:begin
            if(cnt_d1==4'd9)
                rd_req <= 1'b1;
            else
                rd_req <= 1'b0;
            addr <= 8'hf;
            if(rd_done)begin
                zdata[11:4] <= rd_data_rx;
                cnt <= cnt + 1'b1;
            end
            else
                cnt <= cnt;
        end
        4'd11:begin
            if(cnt_d1==4'd10)
                rd_req <= 1'b1;
            else
                rd_req <= 1'b0;
            addr <= 8'h10;
            if(rd_done)begin
                zdata[3:0] <= rd_data_rx[7:4];
                cnt <= cnt + 1'b1;
                done <= 1'b1;
            end
            else
                cnt <= cnt;
        end
        4'd12:begin
            if(flag)
                cnt <= 4'd3;
            else
                cnt <= cnt;
            done <= 1'b0;
        end
        default:begin
            cnt <= cnt;
            wr_req <= wr_req;
            wr_data_tx <= wr_data_tx;
            rd_req <= rd_req;
            addr <= addr;
            xdata <= xdata;
            ydata <= ydata;
            zdata <= zdata;
            done <= done;
        end
    endcase
end

always@(posedge clk)begin
    if(cnt<3) begin
        tx <= wr_tx;
        sclk <= wr_sclk;
        cs_n <= wr_cs_n;
    end
    else begin
        tx <= wr_tx;
        sclk <= wr_sclk;
        cs_n <= wr_cs_n;
    end
end

always@(posedge clk)begin
   cnt_d1 <= cnt; 
end

endmodule