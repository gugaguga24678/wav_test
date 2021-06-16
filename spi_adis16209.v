module spi_adis16209(
    input               clk,
    input               rst,
    output              sclk,
    input       [15:0]  data_tx,
    input               req,
    input               wr_en,
    output              tx,
    input               rx,
    output reg  [15:0]  data_rx,
    output              cs_n,
    output reg          done = 1'b0
);

reg sclk_reg = 1'b1;
reg clk_flag;
reg tx_reg;
reg cs_n_reg;
reg [15:0] data_rx_reg = 8'd0;
reg [15:0] data_tx_reg = 16'd0;
reg [8:0] cnt = 9'h0;
reg flag = 1'b0;
reg flag_reg = 1'b0;
reg req_d1;
wire req_reg;

reg [3:0] clk_cnt = 4'hf;
reg clk_0m96 = 1'b1;

always@(posedge clk)begin
    if(clk_cnt==4'd7)
        clk_0m96 <= 1'b0;
    else if(clk_cnt==4'd15)
        clk_0m96 <= 1'b1;
    else
        clk_0m96 <= clk_0m96;
end

always@(posedge clk)begin
    clk_cnt <= clk_cnt + 1'b1;
end

// always@(posedge clk)begin
    // req_d1 <= req;
// end

// assign req_reg = req_d1 | req;

// always@(posedge clk)begin
    // sclk_reg <= ~sclk_reg;
// end

always@(posedge clk)begin
    if(req)
        flag_reg <= 1'b1;
    else if(done)
        flag_reg <= 1'b0;
    else
        flag_reg <= flag_reg;
end

always@(posedge clk)begin
    if(flag_reg==1'b1&&clk_0m96==1'b1)
        flag <= 1'b1;
    else if(flag_reg==1'b0)
        flag <= 1'b0;
    else
        flag <= flag;
end

always@(posedge clk)begin
    if(flag==1'b1)
        cnt <= cnt + 1'b1;
    else
        cnt <= 9'b0;
end

always@(posedge clk)begin
    case(cnt)
        9'd0:begin
            clk_flag <= 1'b0;
            tx_reg <= 1'b0;
            data_rx_reg <= 8'b0;
            data_tx_reg <= data_tx;
            data_rx <= data_rx;
            done <= 1'b0;
            cs_n_reg <= 1'b1;
        end
        9'd1:begin
            clk_flag <= 1'b0;
            tx_reg <= 1'b0;
            data_rx_reg <= 8'b0;
            data_tx_reg <= data_tx;
            data_rx <= data_rx;
            done <= 1'b0;
            cs_n_reg <= 1'b0;
        end
        9'd6:begin
            clk_flag <= 1'b1;
            if(wr_en)
                tx_reg <= 1'b1;
            else
                tx_reg <= 1'b0;
            data_rx_reg <= 16'b0;
            data_tx_reg <= data_tx_reg;
            data_rx <= data_rx;
            done <= 1'b0;
            cs_n_reg <= 1'b0;
        end
        9'd14:begin
            clk_flag <= 1'b1;
            tx_reg <= tx_reg;
            data_rx_reg[15] <= rx;
            data_tx_reg <= data_tx_reg;
            data_rx <= data_rx;
            done <= 1'b0;
            cs_n_reg <= 1'b0;
        end
        9'd22:begin
            clk_flag <= 1'b1;
            tx_reg <= data_tx_reg[6];
            data_rx_reg <= data_rx_reg;
            data_tx_reg <= data_tx_reg;
            data_rx <= data_rx;
            done <= 1'b0;
            cs_n_reg <= 1'b0;
        end
        9'd30:begin
            clk_flag <= 1'b1;
            tx_reg <= tx_reg;
            data_rx_reg[14] <= rx;
            data_tx_reg <= data_tx_reg;
            data_rx <= data_rx;
            done <= 1'b0;
            cs_n_reg <= 1'b0;
        end
        9'd38:begin
            clk_flag <= 1'b1;
            tx_reg <= data_tx_reg[5];
            data_rx_reg <= data_rx_reg;
            data_tx_reg <= data_tx_reg;
            data_rx <= data_rx;
            done <= 1'b0;
            cs_n_reg <= 1'b0;
        end
        9'd46:begin
            clk_flag <= 1'b1;
            tx_reg <= tx_reg;
            data_rx_reg[13] <= rx;
            data_tx_reg <= data_tx_reg;
            data_rx <= data_rx;
            done <= 1'b0;
            cs_n_reg <= 1'b0;
        end
        9'd54:begin
            clk_flag <= 1'b1;
            tx_reg <= data_tx_reg[4];
            data_rx_reg <= data_rx_reg;
            data_tx_reg <= data_tx_reg;
            data_rx <= data_rx;
            done <= 1'b0;
            cs_n_reg <= 1'b0;
        end
        9'd62:begin
            clk_flag <= 1'b1;
            tx_reg <= tx_reg;
            data_rx_reg[12] <= rx;
            data_tx_reg <= data_tx_reg;
            data_rx <= data_rx;
            done <= 1'b0;
            cs_n_reg <= 1'b0;
        end
        9'd70:begin
            clk_flag <= 1'b1;
            tx_reg <= data_tx_reg[3];
            data_rx_reg <= data_rx_reg;
            data_tx_reg <= data_tx_reg;
            data_rx <= data_rx;
            done <= 1'b0;
            cs_n_reg <= 1'b0;
        end
        9'd78:begin
            clk_flag <= 1'b1;
            tx_reg <= tx_reg;
            data_rx_reg[11] <= rx;
            data_tx_reg <= data_tx_reg;
            data_rx <= data_rx;
            done <= 1'b0;
            cs_n_reg <= 1'b0;
        end
        9'd86:begin
            clk_flag <= 1'b1;
            tx_reg <= data_tx_reg[2];
            data_rx_reg <= data_rx_reg;
            data_tx_reg <= data_tx_reg;
            data_rx <= data_rx;
            done <= 1'b0;
            cs_n_reg <= 1'b0;
        end
        9'd94:begin
            clk_flag <= 1'b1;
            tx_reg <= tx_reg;
            data_rx_reg[10] <= rx;
            data_tx_reg <= data_tx_reg;
            data_rx <= data_rx;
            done <= 1'b0;
            cs_n_reg <= 1'b0;
        end
        9'd102:begin
            clk_flag <= 1'b1;
            tx_reg <= data_tx_reg[1];
            data_rx_reg <= data_rx_reg;
            data_tx_reg <= data_tx_reg;
            data_rx <= data_rx;
            done <= 1'b0;
            cs_n_reg <= 1'b0;
        end
        9'd110:begin
            clk_flag <= 1'b1;
            tx_reg <= tx_reg;
            data_rx_reg[9] <= rx;
            data_tx_reg <= data_tx_reg;
            data_rx <= data_rx;
            done <= 1'b0;
            cs_n_reg <= 1'b0;
        end
        9'd118:begin
            clk_flag <= 1'b1;
            tx_reg <= data_tx_reg[0];
            data_rx_reg <= data_rx_reg;
            data_tx_reg <= data_tx_reg;
            data_rx <= data_rx;
            done <= 1'b0;
            cs_n_reg <= 1'b0;
        end
        9'd126:begin
            clk_flag <= 1'b1;
            tx_reg <= tx_reg;
            data_rx_reg[8] <= rx;
            data_tx_reg <= data_tx_reg;
            data_rx <= data_rx;
            done <= 1'b0;
            cs_n_reg <= 1'b0;
        end
        9'd134:begin
            clk_flag <= 1'b1;
            if(wr_en)
                tx_reg <= data_tx_reg[15];
            else
                tx_reg <= 1'b0;
            data_rx_reg <= data_rx_reg;
            data_tx_reg <= data_tx_reg;
            data_rx <= data_rx;
            done <= 1'b0;
            cs_n_reg <= 1'b0;
        end
        9'd142:begin
            clk_flag <= 1'b1;
            tx_reg <= tx_reg;
            data_rx_reg[7] <= rx;
            data_tx_reg <= data_tx_reg;
            data_rx <= data_rx;
            done <= 1'b0;
            cs_n_reg <= 1'b0;
        end
        9'd150:begin
            clk_flag <= 1'b1;
            if(wr_en)
                tx_reg <= data_tx_reg[14];
            else
                tx_reg <= 1'b0;
            data_rx_reg <= data_rx_reg;
            data_tx_reg <= data_tx_reg;
            data_rx <= data_rx;
            done <= 1'b0;
            cs_n_reg <= 1'b0;
        end
        9'd158:begin
            clk_flag <= 1'b1;
            tx_reg <= tx_reg;
            data_rx_reg[6] <= rx;
            data_tx_reg <= data_tx_reg;
            data_rx <= data_rx;
            done <= 1'b0;
            cs_n_reg <= 1'b0;
        end
        9'd166:begin
            clk_flag <= 1'b1;
            if(wr_en)
                tx_reg <= data_tx_reg[13];
            else
                tx_reg <= 1'b0;
            data_rx_reg <= data_rx_reg;
            data_tx_reg <= data_tx_reg;
            data_rx <= data_rx;
            done <= 1'b0;
            cs_n_reg <= 1'b0;
        end
        9'd174:begin
            clk_flag <= 1'b1;
            tx_reg <= tx_reg;
            data_rx_reg[5] <= rx;
            data_tx_reg <= data_tx_reg;
            data_rx <= data_rx;
            done <= 1'b0;
            cs_n_reg <= 1'b0;
        end
        9'd182:begin
            clk_flag <= 1'b1;
            if(wr_en)
                tx_reg <= data_tx_reg[12];
            else
                tx_reg <= 1'b0;
            data_rx_reg <= data_rx_reg;
            data_tx_reg <= data_tx_reg;
            data_rx <= data_rx;
            done <= 1'b0;
            cs_n_reg <= 1'b0;
        end
        9'd190:begin
            clk_flag <= 1'b1;
            tx_reg <= tx_reg;
            data_rx_reg[4] <= rx;
            data_tx_reg <= data_tx_reg;
            data_rx <= data_rx;
            done <= 1'b0;
            cs_n_reg <= 1'b0;
        end
        9'd198:begin
            clk_flag <= 1'b1;
            if(wr_en)
                tx_reg <= data_tx_reg[11];
            else
                tx_reg <= 1'b0;
            data_rx_reg <= data_rx_reg;
            data_tx_reg <= data_tx_reg;
            data_rx <= data_rx;
            done <= 1'b0;
            cs_n_reg <= 1'b0;
        end
        9'd206:begin
            clk_flag <= 1'b1;
            tx_reg <= tx_reg;
            data_rx_reg[3] <= rx;
            data_tx_reg <= data_tx_reg;
            data_rx <= data_rx;
            done <= 1'b0;
            cs_n_reg <= 1'b0;
        end
        9'd214:begin
            clk_flag <= 1'b1;
            if(wr_en)
                tx_reg <= data_tx_reg[10];
            else
                tx_reg <= 1'b0;
            data_rx_reg <= data_rx_reg;
            data_tx_reg <= data_tx_reg;
            data_rx <= data_rx;
            done <= 1'b0;
            cs_n_reg <= 1'b0;
        end
        9'd222:begin
            clk_flag <= 1'b1;
            tx_reg <= tx_reg;
            data_rx_reg[2] <= rx;
            data_tx_reg <= data_tx_reg;
            data_rx <= data_rx;
            done <= 1'b0;
            cs_n_reg <= 1'b0;
        end
        9'd230:begin
            clk_flag <= 1'b1;
            if(wr_en)
                tx_reg <= data_tx_reg[9];
            else
                tx_reg <= 1'b0;
            data_rx_reg <= data_rx_reg;
            data_tx_reg <= data_tx_reg;
            data_rx <= data_rx;
            done <= 1'b0;
            cs_n_reg <= 1'b0;
        end
        9'd238:begin
            clk_flag <= 1'b1;
            tx_reg <= tx_reg;
            data_rx_reg[1] <= rx;
            data_tx_reg <= data_tx_reg;
            data_rx <= data_rx;
            done <= 1'b0;
            cs_n_reg <= 1'b0;
        end
        9'd246:begin
            clk_flag <= 1'b1;
            if(wr_en)
                tx_reg <= data_tx_reg[8];
            else
                tx_reg <= 1'b0;
            data_rx_reg <= data_rx_reg;
            data_tx_reg <= data_tx_reg;
            data_rx <= data_rx;
            done <= 1'b0;
            cs_n_reg <= 1'b0;
        end
        9'd254:begin
            clk_flag <= 1'b0;
            tx_reg <= tx_reg;
            data_rx_reg[0] <= rx;
            data_tx_reg <= data_tx_reg;
            data_rx <= data_rx;
            done <= 1'b0;
            cs_n_reg <= 1'b0;
        end
        9'd262:begin
            clk_flag <= 1'b0;
            tx_reg <= 1'b0;
            data_rx_reg <= data_rx_reg;
            data_tx_reg <= data_tx_reg;
            data_rx <= data_rx_reg;
            done <= 1'b1;
            cs_n_reg <= 1'b1;
        end
        default:begin
            clk_flag <= clk_flag;
            tx_reg <= tx_reg;
            data_rx_reg <= data_rx_reg;
            data_tx_reg <= data_tx_reg;
            data_rx <= data_rx;
            done <= done;
            cs_n_reg <= cs_n_reg;
        end
    endcase
end

always@(posedge clk)begin
    // tx <= tx_reg;
    //cs_n <= cs_n_reg;
end

assign tx = tx_reg;

assign cs_n = cs_n_reg;

assign sclk = clk_flag ? clk_0m96 : 1'b1;

endmodule
