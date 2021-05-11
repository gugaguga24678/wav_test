module top_1(
    input clk,
    input rx,
    output tx,
    output cs_n,
    output sclk,
    input [5:0] rx_cnt,
    input rx1_ready
);

reg [3:0] cnt_d1;
reg [3:0] cnt = 4'd0;
reg spi_flag = 1'b0;

reg [15:0] data_tx;
wire [7:0] data_rx;
reg req;
reg wr_en;
wire done;
reg [19:0] xdata;
wire rst;

assign rst = 1'b0;

spi spi(
    .clk(clk),
    .rst(rst),
    .sclk(sclk),
    .data_tx(data_tx),
    .data_rx(data_rx),
    .req(req),
    .wr_en(wr_en),
    .tx(tx),
    .rx(rx),
    .cs_n(cs_n),
    .done(done)
);

always@(posedge clk)
    cnt_d1 <= cnt;
    
always@(posedge clk)begin
    if(rx_cnt==6'd2&&rx1_ready)
        spi_flag <= 1'b1;
    else if(cnt==4'd6)
        spi_flag <= 1'b0;
    else
        spi_flag <= spi_flag;
end

always@(posedge clk)begin
    if(spi_flag)begin
        case(cnt)
            4'd0:
                cnt <= cnt + 1'b1;
            4'd1:begin
                if(cnt_d1==4'd0)
                    req <= 1'b1;
                else
                    req <= 1'b0;
                wren <= 1'b1;
                data_tx <= 16'h0128;
                if(done)
                    cnt <= cnt + 1'b1;
                else
                    cnt <= cnt;
            end
            4'd2:begin
                if(cnt_d1==4'd1)
                    req <= 1'b1;
                else
                    req <= 1'b0;
                wren <= 1'b1;
                data_tx <= 16'h002d;
                if(done)
                    cnt <= cnt + 1'b1;
                else
                    cnt <= cnt;
            end
            4'd3:begin
                if(cnt_d1==4'd2||cnt_d1==4'd6)
                    req <= 1'b1;
                else
                    req <= 1'b0;
                wren <= 1'b0;
                data_tx <= 16'h0008;
                if(done)begin
                    xdata[19:12] = data_rx;
                    cnt <= cnt + 1'b1;
                end
                else begin
                    xdata <= xdata;
                    cnt <= cnt;
                end
            end
            4'd4:begin
                if(cnt_d1==4'd3)
                    req <= 1'b1;
                else
                    req <= 1'b0;
                wren <= 1'b0;
                data_tx <= 16'h0009;
                if(done)begin
                    xdata[11:4] = data_rx;
                    cnt <= cnt + 1'b1;
                end
                else begin
                    xdata <= xdata;
                    cnt <= cnt;
                end
            end
            4'd5:begin
                if(cnt_d1==4'd4)
                    req <= 1'b1;
                else
                    req <= 1'b0;
                wren <= 1'b0;
                data_tx <= 16'h0009;
                if(done)begin
                    xdata[3:0] = data_rx[7:4];
                    cnt <= cnt + 1'b1;
                end
                else begin
                    xdata <= xdata;
                    cnt <= cnt;
                    spi_flag <= spi_flag;
                end
            end
            4'd6:begin
                if(spi_flag)
                    cnt <= 4'd3;
                else
                    cnt <= cnt;
            end
            default:begin
                cnt <= cnt;
                xdata <= xdata;
                data_tx <= data_tx;
                req <= 1'b0;
                wr_en <= 1'b0;
            end
        endcase
    end
    else begin
        cnt <= cnt;
        xdata <= xdata;
        data_tx <= data_tx;
        req <= 1'b0;
        wr_en <= 1'b0;
    end
end

endmodule
