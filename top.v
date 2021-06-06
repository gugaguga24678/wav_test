module top(
  input clk,
  output sclk,
  output mosi,
  input  miso,
  output cs_n,
  input RX,
  output TX
);

wire clk_42mhz;

wire rx1_ready;
wire [7:0] rx1_data;
wire rx_idle;
wire rx_eop;

wire wren_1;
wire wren_2;
reg [8:0] rx_cnt = 9'b0;
//reg [23:0] cnt = 24'd0;
reg [15:0] data_in;
wire [13:0] addr_1;
wire [13:0] addr_2;
wire [15:0] data_out_1;
wire [15:0] data_out_2;
reg wr_done = 1'b0;

reg tx1_start;
reg [7:0] tx1_data;
wire tx1_busy;

reg [7:0] data_buf;
reg data_flag = 0;
reg data_check_busy = 0;
reg [8:0] tx_cnt = 9'd384;

reg pingpong_flag = 1'b0;
reg [3:0] rx_eop_cnt = 4'b0;

reg [4:0] cnt_d1;
reg [4:0] cnt = 4'd0;
reg spi_flag = 1'b0;

reg [15:0] data_tx = 16'h0B;
wire [7:0] data_rx;
reg req;
reg wr_en = 1'b0;
wire done;

reg [19:0] xdata;
reg [19:0] ydata;
reg [19:0] zdata;
reg [7:0] ram_data_in;
reg [7:0] temp1 = 8'h0;
reg [7:0] temp2;

reg [2:0] clk_cnt = 3'd0;
reg clk_1m92 = 1'b0;

// assign clk_42mhz = clk;

pll pll_inst(
   .PACKAGEPIN(clk),
   .PLLOUTCORE(clk_42mhz),
   .PLLOUTGLOBAL(),
   .RESET(1'b1)
);

uart_rx urx1 (
    .clk(clk_42mhz),
    .rx(RX),
    .rx_ready(rx1_ready),
    .rx_data(rx1_data),
    .rx_idle(rx_idle),
    .rx_eop(rx_eop)
);

SB_SPRAM256KA ramfn_inst1(
   .DATAIN(ram_data_in),
   .ADDRESS(addr_1),
   .MASKWREN(4'b1111),
   .WREN(wren_1),
   .CHIPSELECT(1'b1),
   .CLOCK(clk_42mhz),
   .STANDBY(1'b0),
   .SLEEP(1'b0),
   .POWEROFF(1'b1),
   .DATAOUT(data_out_1)
);

SB_SPRAM256KA ramfn_inst2(
   .DATAIN(ram_data_in),
   .ADDRESS(addr_2),
   .MASKWREN(4'b1111),
   .WREN(wren_2),
   .CHIPSELECT(1'b1),
   .CLOCK(clk_42mhz),
   .STANDBY(1'b0),
   .SLEEP(1'b0),
   .POWEROFF(1'b1),
   .DATAOUT(data_out_2)
);

uart_tx utx1 (
    .clk(clk_42mhz),
    .tx_start(tx1_start),
    .tx_data(tx1_data),
    .tx(TX),
    .tx_busy(tx1_busy)
);

always@(posedge clk_42mhz)begin
  if(rx_eop_cnt==4'd8)
    pingpong_flag <= ~pingpong_flag;
  else
    pingpong_flag <= pingpong_flag;
end

assign addr_1 = pingpong_flag ? rx_cnt : tx_cnt;
assign addr_2 = pingpong_flag ? tx_cnt : rx_cnt;

assign wren_1 = pingpong_flag ? rx1_ready : 1'b0;
assign wren_2 = pingpong_flag ? 1'b0 : rx1_ready;

always@(posedge clk_42mhz)begin
  if(rx1_ready)
    rx_cnt <= rx_cnt + 1'b1;
  else if(rx_eop_cnt==4'd8)
    rx_cnt <= 9'b0;
  else
    rx_cnt <= rx_cnt;
end

always@(posedge clk_42mhz)begin
  if(rx_eop_cnt<4'd8 && rx_eop)
    rx_eop_cnt <= rx_eop_cnt + 1'b1;
  else if(rx_eop_cnt==4'd8)
    rx_eop_cnt <= 1'b0;
  else
    rx_eop_cnt <= rx_eop_cnt;
end

always@(posedge clk_42mhz)begin
  case(rx_cnt)
    9'd35, 9'd83, 9'd131, 9'd179, 9'd227, 9'd275, 9'd323, 9'd371:
       ram_data_in <= temp1;
        // ram_data_in <= 8'h12;
    9'd36, 9'd84, 9'd132, 9'd180, 9'd228, 9'd276, 9'd324, 9'd372:
        ram_data_in <= temp2;
        // ram_data_in <= 8'hab;
    9'd37, 9'd85, 9'd133, 9'd181, 9'd229, 9'd277, 9'd325, 9'd373:
        ram_data_in <= xdata[19:12];
    9'd38, 9'd86, 9'd134, 9'd182, 9'd230, 9'd278, 9'd326, 9'd374:
        ram_data_in <= xdata[11:4];
    9'd39, 9'd87, 9'd135, 9'd183, 9'd231, 9'd279, 9'd327, 9'd375:
        ram_data_in <= xdata[3:0];
    9'd40, 9'd88, 9'd136, 9'd184, 9'd232, 9'd280, 9'd328, 9'd376:
        ram_data_in <= ydata[19:12];
    9'd41, 9'd89, 9'd137, 9'd185, 9'd233, 9'd281, 9'd329, 9'd377:
        ram_data_in <= ydata[11:4];
    9'd42, 9'd90, 9'd138, 9'd186, 9'd234, 9'd282, 9'd330, 9'd378:
        ram_data_in <= ydata[3:0];
    9'd43, 9'd91, 9'd139, 9'd187, 9'd235, 9'd283, 9'd331, 9'd379:
        ram_data_in <= zdata[19:12];
    9'd44, 9'd92, 9'd140, 9'd188, 9'd236, 9'd284, 9'd332, 9'd380:
        ram_data_in <= zdata[11:4];
    9'd45, 9'd93, 9'd141, 9'd189, 9'd237, 9'd285, 9'd333, 9'd381:
        ram_data_in <= zdata[3:0];
    default:
        ram_data_in <= rx1_data;
  endcase
end

// always@(posedge clk_42mhz)begin
//     data_flag <= data_flag_1;
// end

always @(posedge clk_42mhz) begin
  // we got a new data strobe
  // let's save it and set a flag
  if(rx_eop_cnt==4'd8)
    tx_cnt <= 9'd0;
  else if(tx_cnt <= 9'd383)begin
    if(~data_flag) begin
        data_buf <= pingpong_flag ? data_out_2[7:0] : data_out_1[7:0];
        data_flag <= 1;
        data_check_busy <= 1;
    end
    // new data flag is set let's try to send it
    if(data_flag) begin
      // First check if the previous transmission is over
      if(data_check_busy) begin
        if(~tx1_busy) begin
          data_check_busy <= 0;
        end // if(~tx1_busy)
      end else begin // try to send waiting for busy to go high to make sure
        if(~tx1_busy) begin
//          tx1_data <= data_buf;
          tx1_data <= pingpong_flag ? data_out_2[7:0] : data_out_1[7:0];
          tx1_start <= 1'b1;
        end else begin // Yey we did it!
          tx1_start <= 1'b0;
          data_flag <= 0;
          tx_cnt <= tx_cnt + 1'b1;
        end
      end
    end
  end
end

reg req_d1, req_d2, req_d3, req_d4, req_d5, req_d6, req_d7, req_d8, req_d9, req_d10, req_d11, req_d12, req_d13, req_d14, req_d15;
wire req_reg;
wire done_reg;
reg done_d1, done_d2, done_d3, done_d4, done_d5, done_d6, done_d7, done_d8, done_d9, done_d10, done_d11, done_d12, done_d13, done_d14, done_d15;

always@(posedge clk_42mhz)begin
    done_d1 <= done_reg;
    done_d2 <= done_d1;
    done_d3 <= done_d2;
    done_d4 <= done_d3;
    done_d5 <= done_d4;
    done_d6 <= done_d5;
    done_d7 <= done_d6;
    done_d8 <= done_d7;
    done_d9 <= done_d8;
    done_d10 <= done_d9;
    done_d11 <= done_d10;
    done_d12 <= done_d11;
    done_d13 <= done_d12;
    done_d14 <= done_d13;
    done_d15 <= done_d14;
end
spi_rm3100 spi_rm3100(
    .clk(clk_1m92),
    .rst(rst),
    .sclk(sclk),
    .data_tx(data_tx),
    .data_rx(data_rx),
    .req(req_reg),
    .wr_en(wr_en),
    .tx(mosi),
    .rx(miso),
    .cs_n(cs_n),
    .done(done_reg)
);

// always@(posedge clk_42mhz)begin
//     if(rx_cnt==6'd2&&rx1_ready)
//         req <= 1'b1;
//     else
//         req <= 1'b0;
// end

always@(posedge clk_42mhz)begin
    req_d1 <= req;
    req_d2 <= req_d1;
    req_d3 <= req_d2;
    req_d4 <= req_d3;
    req_d5 <= req_d4;
    req_d6 <= req_d5;
    req_d7 <= req_d6;
    req_d8 <= req_d7;
    req_d9 <= req_d8;
    req_d10 <= req_d9;
    req_d11 <= req_d10;
    req_d12 <= req_d11;
    req_d13 <= req_d12;
    req_d14 <= req_d13;
    req_d15 <= req_d14;
end

assign done = ~done_d14 & done_d15;

assign req_reg = req | req_d1 | req_d2 | req_d3 | req_d4 | req_d5 | req_d6 | req_d7 | req_d8 | req_d9 | req_d10 | req_d11 | req_d12 | req_d13 | req_d14 | req_d15;

always@(posedge clk_42mhz)begin
    clk_cnt <= clk_cnt + 1'b1;
end

always@(posedge clk_42mhz)begin
    if(clk_cnt==3'd3||clk_cnt==3'd7)
        clk_1m92 <= ~clk_1m92;
end

always@(posedge clk_42mhz)
    cnt_d1 <= cnt;
    
always@(posedge clk_42mhz)begin
    if(rx_cnt==6'd2&&rx1_ready)
        spi_flag <= 1'b1;
    else if(cnt==5'd21)
        spi_flag <= 1'b0;
    else
        spi_flag <= spi_flag;
end

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
                wr_en <= 1'b0;
                data_tx <= 16'h0004;
                // wr_en <= 1'b0;
                // data_tx <= 16'h0005;
                if(done) begin
                    // temp1 <= data_rx;
                    cnt <= cnt + 1'b1;
                end
                else begin
                    // temp1 <= temp1;
                    cnt <= cnt;
                end
            end
            5'd2:begin
                if(cnt_d1==5'd1)
                    req <= 1'b1;
                else
                    req <= 1'b0;
                wr_en <= 1'b1;
                data_tx <= 16'h3205;
                if(done) begin
                    cnt <= cnt + 1'b1;
                    // temp1 <= data_rx;
                end
                else begin
                    // temp1 <= temp1;
                    cnt <= cnt;
                end
            end
            5'd3:begin
                if(cnt_d1==5'd2)
                    req <= 1'b1;
                else
                    req <= 1'b0;
                wr_en <= 1'b0;
                data_tx <= 16'h0006;
                if(done)
                    cnt <= cnt + 1'b1;
                else
                    cnt <= cnt;
            end
            5'd4:begin
                if(cnt_d1==5'd3)
                    req <= 1'b1;
                else
                    req <= 1'b0;
                wr_en <= 1'b1;
                data_tx <= 16'h3207;
                if(done)
                    cnt <= cnt + 1'b1;
                else
                    cnt <= cnt;
            end
            5'd5:begin
                if(cnt_d1==5'd4)
                    req <= 1'b1;
                else
                    req <= 1'b0;
                wr_en <= 1'b0;
                data_tx <= 16'h0008;
                if(done)
                    cnt <= cnt + 1'b1;
                else
                    cnt <= cnt;
            end
            5'd6:begin
                if(cnt_d1==5'd5)
                    req <= 1'b1;
                else
                    req <= 1'b0;
                wr_en <= 1'b1;
                data_tx <= 16'h3209;
                if(done)
                    cnt <= cnt + 1'b1;
                else
                    cnt <= cnt;
            end
            5'd7:begin
                // if(cnt_d1==5'd6)
                //     req <= 1'b1;
                // else
                //     req <= 1'b0;
                // wr_en <= 1'b1;
                // data_tx <= 16'h950b;
                // if(done) begin
                //     // temp1 <= data_rx;
                //     cnt <= cnt + 1'b1;
                // end
                // else begin
                //     // temp1 <= temp1;
                //     cnt <= cnt;
                // end
                if(cnt_d1==5'd6)
                    req <= 1'b1;
                else
                    req <= 1'b0;
                wr_en <= 1'b0;
                data_tx <= 16'h000b;
                if(done) begin
                    temp2 <= data_rx;
                    cnt <= cnt + 1'b1;
                end
                else begin
                    temp2 <= temp2;
                    cnt <= cnt;
                end
            end
            5'd8:begin
                if(cnt_d1==5'd7)
                    req <= 1'b1;
                else
                    req <= 1'b0;
                wr_en <= 1'b1;
                data_tx <= 16'h7001;
                if(done)
                    cnt <= cnt + 1'b1;
                else
                    cnt <= cnt;
            end
            5'd9:begin
                if(cnt_d1==5'd8||cnt_d1==5'd21)
                    req <= 1'b1;
                else
                    req <= 1'b0;
                wr_en <= 1'b1;
                data_tx <= 16'h7000;
                if(done)begin
                    cnt <= cnt + 1'b1;
                    temp1 <= 8'h0;
                end
                else begin
                    cnt <= cnt;
                    temp1 <= temp1;
                end
            end
            5'd10:begin
                req <= 1'b0;
                wr_en <= 1'b0;
                data_tx <= data_tx;
                cnt <= cnt + 1'b1;
            end
            5'd11:begin
                if(cnt_d1==5'd10)
                    req <= 1'b1;
                else
                    req <= 1'b0;
                wr_en <= 1'b0;
                data_tx <= 16'h0034;
                if(done)begin
                    temp1 <= temp1+ 1'b1;
                    if(data_rx==8'h80)
                        cnt <= cnt + 1'b1;
                    else
                        cnt <= 5'd10;
                end
                else begin
                    temp1 <= temp1;
                    cnt <= cnt;
                end
            end
            5'd12:begin
                if(cnt_d1==5'd11)
                    req <= 1'b1;
                else
                    req <= 1'b0;
                wr_en <= 1'b0;
                data_tx <= 16'h0024;
                if(done)begin
                    xdata[19:12] = data_rx;
                    cnt <= cnt + 1'b1;
                end
                else begin
                    xdata <= xdata;
                    cnt <= cnt;
                end
            end
            5'd13:begin
                if(cnt_d1==5'd12)
                    req <= 1'b1;
                else
                    req <= 1'b0;
                wr_en <= 1'b0;
                data_tx <= 16'h025;
                if(done)begin
                    xdata[11:4] = data_rx;
                    cnt <= cnt + 1'b1;
                end
                else begin
                    xdata <= xdata;
                    cnt <= cnt;
                end
            end
            5'd14:begin
                if(cnt_d1==5'd13)
                    req <= 1'b1;
                else
                    req <= 1'b0;
                wr_en <= 1'b0;
                data_tx <= 16'h026;
                if(done)begin
                    xdata[3:0] = data_rx[7:4];
                    cnt <= cnt + 1'b1;
                end
                else begin
                    xdata <= xdata;
                    cnt <= cnt;
                end
            end
            5'd15:begin
                if(cnt_d1==5'd14)
                    req <= 1'b1;
                else
                    req <= 1'b0;
                wr_en <= 1'b0;
                data_tx <= 16'h0027;
                if(done)begin
                    ydata[19:12] = data_rx;
                    cnt <= cnt + 1'b1;
                end
                else begin
                    ydata <= ydata;
                    cnt <= cnt;
                end
            end
            5'd16:begin
                if(cnt_d1==5'd15)
                    req <= 1'b1;
                else
                    req <= 1'b0;
                wr_en <= 1'b0;
                data_tx <= 16'h028;
                if(done)begin
                    ydata[11:4] = data_rx;
                    cnt <= cnt + 1'b1;
                end
                else begin
                    ydata <= ydata;
                    cnt <= cnt;
                end
            end
            5'd17:begin
                if(cnt_d1==5'd16)
                    req <= 1'b1;
                else
                    req <= 1'b0;
                wr_en <= 1'b0;
                data_tx <= 16'h029;
                if(done)begin
                    ydata[3:0] = data_rx[7:4];
                    cnt <= cnt + 1'b1;
                end
                else begin
                    ydata <= ydata;
                    cnt <= cnt;
                end
            end
            5'd18:begin
                if(cnt_d1==5'd17)
                    req <= 1'b1;
                else
                    req <= 1'b0;
                wr_en <= 1'b0;
                data_tx <= 16'h002a;
                if(done)begin
                    zdata[19:12] = data_rx;
                    cnt <= cnt + 1'b1;
                end
                else begin
                    zdata <= zdata;
                    cnt <= cnt;
                end
            end
            5'd19:begin
                if(cnt_d1==5'd18)
                    req <= 1'b1;
                else
                    req <= 1'b0;
                wr_en <= 1'b0;
                data_tx <= 16'h02b;
                if(done)begin
                    zdata[11:4] = data_rx;
                    cnt <= cnt + 1'b1;
                end
                else begin
                    zdata <= zdata;
                    cnt <= cnt;
                end
            end
            5'd20:begin
                if(cnt_d1==5'd19)
                    req <= 1'b1;
                else
                    req <= 1'b0;
                wr_en <= 1'b0;
                data_tx <= 16'h002c;
                if(done)begin
                    zdata[3:0] = data_rx[7:4];
                    cnt <= cnt + 1'b1;
                end
                else begin
                    zdata <= zdata;
                    cnt <= cnt;
                end
            end
            5'd21:begin
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



endmodule
