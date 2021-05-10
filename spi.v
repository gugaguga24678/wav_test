module spi(
    input               clk,
    input               rst,
    output reg          sclk = 1'b1,
    input       [7:0]   data_tx,
    input               req,
    output reg          tx,
    input               rx,
    output reg  [7:0]   data_rx,
    output reg          cs_n,
    output reg          done
);

reg tx_reg;
reg cs_n_reg;
reg [7:0] data_rx_reg = 8'd0;
reg [7:0] data_tx_reg = 8'd0;
reg [5:0] cnt = 0;
reg flag = 1'b0;
reg done = 1'b0;

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
            tx_reg <= data_tx_reg[6];
            data_rx_reg <= 8'b0;
            data_tx_reg <= data_tx_reg;
            data_rx <= data_rx;
            done = 1'b0;
            cs_n_reg <= 1'b0;
        end
        6'd3:begin
            tx_reg <= data_tx_reg[5];
            data_rx_reg <= 8'b0;
            data_tx_reg <= data_tx_reg;
            data_rx <= data_rx;
            done = 1'b0;
            cs_n_reg <= 1'b0;
        end
        6'd5:begin
            tx_reg <= data_tx_reg[4];
            data_rx_reg <= 8'b0;
            data_tx_reg <= data_tx_reg;
            data_rx <= data_rx;
            done = 1'b0;
            cs_n_reg <= 1'b0;
        end
        6'd7:begin
            tx_reg <= data_tx_reg[3];
            data_rx_reg <= 8'b0;
            data_tx_reg <= data_tx_reg;
            data_rx <= data_rx;
            done = 1'b0;
            cs_n_reg <= 1'b0;
        end
        6'd9:begin
            tx_reg <= data_tx_reg[2];
            data_rx_reg <= 8'b0;
            data_tx_reg <= data_tx_reg;
            data_rx <= data_rx;
            done = 1'b0;
            cs_n_reg <= 1'b0;
        end
        6'd11:begin
            tx_reg <= data_tx_reg[1];
            data_rx_reg <= 8'b0;
            data_tx_reg <= data_tx_reg;
            data_rx <= data_rx;
            done = 1'b0;
            cs_n_reg <= 1'b0;
        end
        6'd13:begin
            tx_reg <= data_tx_reg[0];
            data_rx_reg <= 8'b0;
            data_tx_reg <= data_tx_reg;
            data_rx <= data_rx;
            done = 1'b0;
            cs_n_reg <= 1'b0;
        end
        6'd15:begin
            tx_reg <= 1'b1;
            data_rx_reg <= 8'b0;
            data_tx_reg <= data_tx_reg;
            data_rx <= data_rx;
            done = 1'b0;
            cs_n_reg <= 1'b0;
        end
        6'd17:begin
            tx_reg <= 1'b0;
            data_rx_reg <= 8'b0;
            data_tx_reg <= data_tx_reg;
            data_rx <= data_rx;
            done = 1'b0;
            cs_n_reg <= 1'b0;
        end
        6'd19:begin
            tx_reg <= 1'b0;
            data_rx_reg[7] <= rx;
            data_tx_reg <= data_tx_reg;
            data_rx <= data_rx;
            done = 1'b0;
            cs_n_reg <= 1'b0;
        end
        6'd21:begin
            tx_reg <= 1'b0;
            data_rx_reg[6] <= rx;
            data_tx_reg <= data_tx_reg;
            data_rx <= data_rx;
            done = 1'b0;
            cs_n_reg <= 1'b0;
        end
        6'd23:begin
            tx_reg <= 1'b0;
            data_rx_reg[5] <= rx;
            data_tx_reg <= data_tx_reg;
            data_rx <= data_rx;
            done = 1'b0;
            cs_n_reg <= 1'b0;
        end
        6'd25:begin
            tx_reg <= 1'b0;
            data_rx_reg[4] <= rx;
            data_tx_reg <= data_tx_reg;
            data_rx <= data_rx;
            done = 1'b0;
            cs_n_reg <= 1'b0;
        end
        6'd27:begin
            tx_reg <= 1'b0;
            data_rx_reg[3] <= rx;
            data_tx_reg <= data_tx_reg;
            data_rx <= data_rx;
            done = 1'b0;
            cs_n_reg <= 1'b0;
        end
        6'd29:begin
            tx_reg <= 1'b0;
            data_rx_reg[2] <= rx;
            data_tx_reg <= data_tx_reg;
            data_rx <= data_rx;
            done = 1'b0;
            cs_n_reg <= 1'b0;
        end
        6'd31:begin
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
            done = 1'b0;
            cs_n_reg <= 1'b0;
        end
        6'd34:begin
            tx_reg <= 1'b0;
            data_rx_reg <= data_rx_reg;
            data_tx_reg <= data_tx_reg;
            data_rx <= data_rx_reg;
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