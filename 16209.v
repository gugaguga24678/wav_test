always@(posedge clk_42mhz)begin
    if(spi_flag)begin
        case(cnt)
            5'd0:
                cnt <= cnt + 1'b1;
            5'd1:begin
                if(cnt_d1==5'd0)
                    req <= 1'b1;
                else
                    req <= 1'b0;
                wr_en <= 1'b1;
                data_tx <= 16'h0004;
                if(done)
                    cnt <= cnt + 1'b1;
                else
                    cnt <= cnt;
            end
            5'd2:begin
                if(cnt_d1==5'd1)
                    req <= 1'b1;
                else
                    req <= 1'b0;
                wr_en <= 1'b1;
                data_tx <= 16'h7000;
                if(done)
                    cnt <= cnt + 1'b1;
                else
                    cnt <= cnt;
            end
            5'd3:begin
                if(cnt_d1==5'd2||cnt_d1==5'd6)
                    req <= 1'b1;
                else
                    req <= 1'b0;
                wr_en <= 1'b0;
                data_tx <= 16'h0034;
                if(done)begin
                    temp <= data_rx;
                    cnt <= cnt + 1'b1;
                end
                else begin
                    xdata <= xdata;
                    cnt <= cnt;
                end
            end
            5'd4:begin
                if(cnt_d1==5'd3)
                    req <= 1'b1;
                else
                    req <= 1'b0;
                wr_en <= 1'b0;
                data_tx <= 16'h0024;
                if(done)begin
                    xdata <= data_rx;
                    cnt <= cnt + 1'b1;
                end
                else begin
                    xdata <= xdata;
                    cnt <= cnt;
                end
            end
            5'd5:begin
                if(cnt_d1==5'd4)
                    req <= 1'b1;
                else
                    req <= 1'b0;
                wr_en <= 1'b0;
                data_tx <= 16'h025;
                if(done)begin
                    ydata <= data_rx;
                    cnt <= cnt + 1'b1;
                end
                else begin
                    ydata <= ydata;
                    cnt <= cnt;
                end
            end
            5'd6:begin
                if(spi_flag)
                    cnt <= 5'd9;
                else
                    cnt <= cnt;
            end
            default:begin
                cnt <= cnt;
                xdata <= xdata;
                ydata <= ydata;
                zdata <= zdata;
                data_tx <= data_tx;
                req <= 1'b0;
                wr_en <= 1'b0;
            end
        endcase
    end
    else begin
        cnt <= cnt;
        xdata <= xdata;
        ydata <= ydata;
        zdata <= zdata;
        data_tx <= data_tx;
        req <= 1'b0;
        wr_en <= 1'b0;
    end
end

module spi_adis16209(
    input               clk,
    input               rst,
    output reg          sclk = 1'b1,
    input       [15:0]  data_tx,
    input               req,
    input               wr_en,
    output reg          tx,
    input               rx,
    output reg  [15:0]  data_rx,
    output reg          cs_n,
    output reg          done = 1'b0
);

reg tx_reg;
reg cs_n_reg;
reg [7:0] data_rx_reg = 8'd0;
reg [15:0] data_tx_reg = 8'd0;
reg [5:0] cnt = 0;
reg flag = 1'b0;

reg req_d1;
wire req_reg;

always@(posedge clk)begin
    req_d1 <= req;
end

assign req_reg = req_d1 | req;

always@(posedge clk)begin
    sclk = ~sclk;
end

always@(posedge clk)begin
    if(sclk&&req_reg)
        flag <= 1'b1;
    else if(done)
        flag <= 1'b0;
    else
        flag <= flag;
end

always@(posedge clk)begin
    if(flag==1'b1)
        cnt <= cnt + 1'b1;
    else
        cnt <= 6'b0;
end

always@(posedge clk)begin
    case(cnt)
        6'd0:begin
            tx_reg <= 1'b0;
            data_rx_reg <= 8'b0;
            data_tx_reg <= data_tx;
            data_rx <= data_rx;
            done = 1'b0;
            cs_n_reg <= 1'b1;
        end
        6'd1:begin
            if(wr_en)
                tx_reg <= 1'b1;
            end
                tx_reg <= 1'b0;
            data_rx_reg <= data_rx_reg;
            data_tx_reg <= data_tx_reg;
            data_rx <= data_rx;
            done = 1'b0;
            cs_n_reg <= 1'b0;
        end
        6'd3:begin
            tx_reg <= data_tx_reg[6];
            data_rx_reg[15] <= rx;
            data_tx_reg <= data_tx_reg;
            data_rx <= data_rx;
            done = 1'b0;
            cs_n_reg <= 1'b0;
        end
        6'd5:begin
            tx_reg <= data_tx_reg[5];
            data_rx_reg[14] <= rx;
            data_tx_reg <= data_tx_reg;
            data_rx <= data_rx;
            done = 1'b0;
            cs_n_reg <= 1'b0;
        end
        6'd7:begin
            tx_reg <= data_tx_reg[4];
            data_rx_reg[13] <= rx;
            data_tx_reg <= data_tx_reg;
            data_rx <= data_rx;
            done = 1'b0;
            cs_n_reg <= 1'b0;
        end
        6'd9:begin
            tx_reg <= data_tx_reg[3];
            data_rx_reg[12] <= rx;
            data_tx_reg <= data_tx_reg;
            data_rx <= data_rx;
            done = 1'b0;
            cs_n_reg <= 1'b0;
        end
        6'd11:begin
            tx_reg <= data_tx_reg[2];
            data_rx_reg[11] <= rx;
            data_tx_reg <= data_tx_reg;
            data_rx <= data_rx;
            done = 1'b0;
            cs_n_reg <= 1'b0;
        end
        6'd13:begin
            tx_reg <= data_tx_reg[1];
            data_rx_reg[10] <= rx;
            data_tx_reg <= data_tx_reg;
            data_rx <= data_rx;
            done = 1'b0;
            cs_n_reg <= 1'b0;
        end
        6'd15:begin
            tx_reg <= data_tx_reg[0];
            data_rx_reg[9] <= rx;
            data_tx_reg <= data_tx_reg;
            data_rx <= data_rx;
            done = 1'b0;
            cs_n_reg <= 1'b0;
        end
        6'd17:begin
            if(wr_en)
                tx_reg <= data_tx_reg[15];
            else
                tx_reg <= 1'b0;
            data_rx_reg[8] <= rx;
            data_tx_reg <= data_tx_reg;
            data_rx <= data_rx;
            done = 1'b0;
            cs_n_reg <= 1'b0;
        end
        6'd19:begin
            if(wr_en)
                tx_reg <= data_tx_reg[14];
            else
                tx_reg <= 1'b0;
            data_rx_reg[7] <= rx;
            data_tx_reg <= data_tx_reg;
            data_rx <= data_rx;
            done = 1'b0;
            cs_n_reg <= 1'b0;
        end
        6'd21:begin
            if(wr_en)
                tx_reg <= data_tx_reg[13];
            else
                tx_reg <= 1'b0;
            data_rx_reg[6] <= rx;
            data_tx_reg <= data_tx_reg;
            data_rx <= data_rx;
            done = 1'b0;
            cs_n_reg <= 1'b0;
        end
        6'd23:begin
            if(wr_en)
                tx_reg <= data_tx_reg[12];
            else
                tx_reg <= 1'b0;
            data_rx_reg[5] <= rx;
            data_tx_reg <= data_tx_reg;
            data_rx <= data_rx;
            done = 1'b0;
            cs_n_reg <= 1'b0;
        end
        6'd25:begin
            if(wr_en)
                tx_reg <= data_tx_reg[11];
            else
                tx_reg <= 1'b0;
            data_rx_reg[4] <= rx;
            data_tx_reg <= data_tx_reg;
            data_rx <= data_rx;
            done = 1'b0;
            cs_n_reg <= 1'b0;
        end
        6'd27:begin
            if(wr_en)
                tx_reg <= data_tx_reg[10];
            else
                tx_reg <= 1'b0;
            data_rx_reg[3] <= rx;
            data_tx_reg <= data_tx_reg;
            data_rx <= data_rx;
            done = 1'b0;
            cs_n_reg <= 1'b0;
        end
        6'd29:begin
            if(wr_en)
                tx_reg <= data_tx_reg[9];
            else
                tx_reg <= 1'b0;
            data_rx_reg[2] <= rx;
            data_tx_reg <= data_tx_reg;
            data_rx <= data_rx;
            done = 1'b0;
            cs_n_reg <= 1'b0;
        end
        6'd31:begin
            if(wr_en)
                tx_reg <= data_tx_reg[8];
            else
                tx_reg <= 1'b0;
            data_rx_reg[1] <= rx;
            data_tx_reg <= data_tx_reg;
            data_rx <= data_rx;
            done = 1'b0;
            cs_n_reg <= 1'b0;
        end
        6'd33:begin
            tx_reg <= 1'b0;
            data_rx_reg[0] <= rx;
            data_tx_reg <= data_tx_reg;
            data_rx <= data_rx;
            if(wr_en)begin
                done = 1'b1;
                cs_n_reg <= 1'b1;   
            end
            else begin
                done = 1'b0;
                cs_n_reg <= 1'b0;
            end
        end
        6'd34:begin
            tx_reg <= 1'b0;
            data_rx_reg <= data_rx_reg;
            data_tx_reg <= data_tx_reg;
            data_rx <= data_rx_reg;
            if(wr_en)
                done <= 1'b0;
            else
                done = 1'b1;
            cs_n_reg <= 1'b1;
        end
        6'd35:begin
            tx_reg <= 1'b0;
            data_rx_reg <= data_rx_reg;
            data_tx_reg <= data_tx_reg;
            data_rx <= data_rx_reg;
            done = 1'b0;
            cs_n_reg <= 1'b1;
        end
        
        default:begin
            tx_reg <= tx_reg;
            data_rx_reg <= data_rx_reg;
            data_tx_reg <= data_tx_reg;
            data_rx <= data_rx;
            done = done;
            cs_n_reg <= cs_n_reg;
        end
    endcase
end

always@(posedge clk)begin
    tx <= tx_reg;
    cs_n <= cs_n_reg;
end

endmodule
