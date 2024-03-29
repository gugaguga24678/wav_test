module top(
  input clk,
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
reg [23:0] cnt = 24'd0;
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

reg [3:0] cnt_d1;
reg [3:0] cnt = 4'd0;
reg spi_flag = 1'b0;

reg [15:0] data_tx = 16'h0;
wire [7:0] data_rx;
reg req;
reg wr_en;
wire done;

reg [19:0] xdata;
reg [19:0] ydata;
reg [19:0] zdata;
reg [7:0] ram_data_in;
reg [7:0] temp1;
reg [7:0] temp2;
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
    9'd36, 9'd84, 9'd132, 9'd180, 9'd228, 9'd276, 9'd324, 9'd372:
        ram_data_in <= temp2;
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

spi spi(
    .clk(clk_42mhz),
    .rst(rst),
    .sclk(sclk),
    .data_tx(data_tx),
    .data_rx(data_rx),
    .req(req),
    .wr_en(wr_en),
    .tx(mosi),
    .rx(miso),
    .cs_n(cs_n),
    .done(done)
);

// always@(posedge clk_42mhz)begin
//     if(rx_cnt==6'd2&&rx1_ready)
//         req <= 1'b1;
//     else
//         req <= 1'b0;
// end

always@(posedge clk_42mhz)
    cnt_d1 <= cnt;
    
always@(posedge clk_42mhz)begin
    if(rx_cnt==6'd2&&rx1_ready)
        spi_flag <= 1'b1;
    else if(cnt==4'd13&&done)
        spi_flag <= 1'b0;
    else
        spi_flag <= spi_flag;
end

always@(posedge clk_42mhz)begin
    if(spi_flag)begin
        case(cnt)
            4'd0:
                cnt <= cnt + 1'b1;
            4'd1:begin
                if(cnt_d1==4'd0)
                    req <= 1'b1;
                else
                    req <= 1'b0;
                wr_en <= 1'b1;
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
                wr_en <= 1'b1;
                data_tx <= 16'h002d;
                if(done)
                    cnt <= cnt + 1'b1;
                else
                    cnt <= cnt;
            end
            4'd3:begin
                if(cnt_d1==4'd2||cnt_d1==4'd14)
                    req <= 1'b1;
                else
                    req <= 1'b0;
                wr_en <= 1'b0;
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
                wr_en <= 1'b0;
                data_tx <= 16'h009;
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
                wr_en <= 1'b0;
                data_tx <= 16'h00a;
                if(done)begin
                    xdata[3:0] = data_rx[7:4];
                    cnt <= cnt + 1'b1;
                end
                else begin
                    xdata <= xdata;
                    cnt <= cnt;
                end
            end
            4'd6:begin
                if(cnt_d1==4'd5)
                    req <= 1'b1;
                else
                    req <= 1'b0;
                wr_en <= 1'b0;
                data_tx <= 16'h000b;
                if(done)begin
                    ydata[19:12] = data_rx;
                    cnt <= cnt + 1'b1;
                end
                else begin
                    ydata <= ydata;
                    cnt <= cnt;
                end
            end
            4'd7:begin
                if(cnt_d1==4'd6)
                    req <= 1'b1;
                else
                    req <= 1'b0;
                wr_en <= 1'b0;
                data_tx <= 16'h00c;
                if(done)begin
                    ydata[11:4] = data_rx;
                    cnt <= cnt + 1'b1;
                end
                else begin
                    ydata <= ydata;
                    cnt <= cnt;
                end
            end
            4'd8:begin
                if(cnt_d1==4'd7)
                    req <= 1'b1;
                else
                    req <= 1'b0;
                wr_en <= 1'b0;
                data_tx <= 16'h00d;
                if(done)begin
                    ydata[3:0] = data_rx[7:4];
                    cnt <= cnt + 1'b1;
                end
                else begin
                    ydata <= ydata;
                    cnt <= cnt;
                end
            end
            4'd9:begin
                if(cnt_d1==4'd8)
                    req <= 1'b1;
                else
                    req <= 1'b0;
                wr_en <= 1'b0;
                data_tx <= 16'h000e;
                if(done)begin
                    zdata[19:12] = data_rx;
                    cnt <= cnt + 1'b1;
                end
                else begin
                    zdata <= zdata;
                    cnt <= cnt;
                end
            end
            4'd10:begin
                if(cnt_d1==4'd9)
                    req <= 1'b1;
                else
                    req <= 1'b0;
                wr_en <= 1'b0;
                data_tx <= 16'h00f;
                if(done)begin
                    zdata[11:4] = data_rx;
                    cnt <= cnt + 1'b1;
                end
                else begin
                    zdata <= zdata;
                    cnt <= cnt;
                end
            end
            4'd11:begin
                if(cnt_d1==4'd10)
                    req <= 1'b1;
                else
                    req <= 1'b0;
                wr_en <= 1'b0;
                data_tx <= 16'h0010;
                if(done)begin
                    zdata[3:0] = data_rx[7:4];
                    cnt <= cnt + 1'b1;
                end
                else begin
                    zdata <= zdata;
                    cnt <= cnt;
                end
            end
            4'd12:begin
                if(cnt_d1==4'd11)
                    req <= 1'b1;
                else
                    req <= 1'b0;
                wr_en <= 1'b0;
                data_tx <= 16'h006;
                if(done)begin
                    temp1 = data_rx;
                    cnt <= cnt + 1'b1;
                end
                else begin
                    temp1 <= temp1;
                    cnt <= cnt;
                end
            end
            4'd13:begin
                if(cnt_d1==4'd12)
                    req <= 1'b1;
                else
                    req <= 1'b0;
                wr_en <= 1'b0;
                data_tx <= 16'h007;
                if(done)begin
                    temp2 = data_rx;
                    cnt <= cnt + 1'b1;
                end
                else begin
                    temp2 <= temp2;
                    cnt <= cnt;
                end
            end
            4'd14:begin
                if(spi_flag)
                    cnt <= 4'd3;
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
    
/*
 *  icebreaker examples - Async uart mirror using pll
 *
 *  Copyright (C) 2018 Piotr Esden-Tempski <piotr@esden.net>
 *
 *  Permission to use, copy, modify, and/or distribute this software for any
 *  purpose with or without fee is hereby granted, provided that the above
 *  copyright notice and this permission notice appear in all copies.
 *
 *  THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
 *  WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
 *  MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
 *  ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
 *  WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
 *  ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
 *  OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
 *
 */


module top (
	input  clk,

  output sclk,
  output mosi,
  input  miso,
  output cs_n,

	input RX,
  	output TX
//	output reg LED_R,
//	output reg LED_G
);

reg LED_R;
reg LED_G;
reg [19:0] xdata;
reg [19:0] ydata;
reg [19:0] zdata;
wire clk_42mhz;
// assign clk_42mhz = clk;
SB_PLL40_PAD #(
.DIVR(4'b0000),
// 42MHz
.DIVF(7'b1010001),
.DIVQ(3'b110),
.FILTER_RANGE(3'b001),
.FEEDBACK_PATH("SIMPLE"),
.DELAY_ADJUSTMENT_MODE_FEEDBACK("FIXED"),
.FDA_FEEDBACK(4'b0000),
.DELAY_ADJUSTMENT_MODE_RELATIVE("FIXED"),
.FDA_RELATIVE(4'b0000),
.SHIFTREG_DIV_MODE(2'b00),
.PLLOUT_SELECT("GENCLK"),
.ENABLE_ICEGATE(1'b0)
) usb_pll_inst (
.PACKAGEPIN(clk),
.PLLOUTCORE(clk_42mhz),
.EXTFEEDBACK(),
.DYNAMICDELAY(),
.RESETB(1'b1),
.BYPASS(1'b0),
.LATCHINPUTVALUE(),
.LOCK(),
.SDI(),
.SDO(),
.SCLK()
);

/* local parameters */
//localparam clk_freq = 12_000_000; // 12MHz
localparam clk_freq = 42_000_000; // 42MHz
//localparam baud = 57600;
localparam baud = 115200;


/* instantiate the rx1 module */
wire rx1_ready;
wire [7:0] rx1_data;
wire rx_idle;
wire rx_eop;

uart_rx #(clk_freq, baud) urx1 (
	.clk(clk_42mhz),
	.rx(RX),
	.rx_ready(rx1_ready),
	.rx_data(rx1_data),
  .rx_idle(rx_idle),
  .rx_eop(rx_eop)
);

/* instantiate the tx1 module */
reg tx1_start;
reg [7:0] tx1_data;
wire tx1_busy;
uart_tx #(clk_freq, baud) utx1 (
	.clk(clk_42mhz),
	.tx_start(tx1_start),
	.tx_data(tx1_data),
	.tx(TX),
	.tx_busy(tx1_busy)
);

reg [5:0] rx_cnt = 6'd0;
reg [7:0] rx_data_buf_0 = 8'd1;
reg [7:0] rx_data_buf_1 = 8'd2;
reg [7:0] rx_data_buf_2 = 8'd3;
reg [7:0] rx_data_buf_3 = 8'd4;
reg [7:0] rx_data_buf_4 = 8'd5;
reg [7:0] rx_data_buf_5 = 8'd6;
reg [7:0] rx_data_buf_6 = 8'd0;
reg [7:0] rx_data_buf_7 = 8'd0;
reg [7:0] rx_data_buf_8 = 8'd0;
reg [7:0] rx_data_buf_9 = 8'd0;
reg [7:0] rx_data_buf_10 = 8'd0;
reg [7:0] rx_data_buf_11 = 8'd0;
reg [7:0] rx_data_buf_12 = 8'd0;
reg [7:0] rx_data_buf_13 = 8'd0;
reg [7:0] rx_data_buf_14 = 8'd0;
reg [7:0] rx_data_buf_15 = 8'd0;
reg [7:0] rx_data_buf_16 = 8'd0;
reg [7:0] rx_data_buf_17 = 8'd0;
reg [7:0] rx_data_buf_18 = 8'd0;
reg [7:0] rx_data_buf_19 = 8'd0;
reg [7:0] rx_data_buf_20 = 8'd0;
reg [7:0] rx_data_buf_21 = 8'd0;
reg [7:0] rx_data_buf_22 = 8'd0;
reg [7:0] rx_data_buf_23 = 8'd0;
reg [7:0] rx_data_buf_24 = 8'd0;
reg [7:0] rx_data_buf_25 = 8'd0;
reg [7:0] rx_data_buf_26 = 8'd0;
reg [7:0] rx_data_buf_27 = 8'd0;
reg [7:0] rx_data_buf_28 = 8'd0;
reg [7:0] rx_data_buf_29 = 8'd0;
reg [7:0] rx_data_buf_30 = 8'd0;
reg [7:0] rx_data_buf_31 = 8'd0;
reg [7:0] rx_data_buf_32 = 8'd0;
reg [7:0] rx_data_buf_33 = 8'd0;
reg [7:0] rx_data_buf_34 = 8'd0;
reg [7:0] rx_data_buf_35 = 8'd0;
reg [7:0] rx_data_buf_36 = 8'd0;
reg [7:0] rx_data_buf_37 = 8'd0;
reg [7:0] rx_data_buf_38 = 8'd0;
reg [7:0] rx_data_buf_39 = 8'd0;
reg [7:0] rx_data_buf_40 = 8'd0;
reg [7:0] rx_data_buf_41 = 8'd0;
reg [7:0] rx_data_buf_42 = 8'd0;
reg [7:0] rx_data_buf_43 = 8'd0;
reg [7:0] rx_data_buf_44 = 8'd0;
reg [7:0] rx_data_buf_45 = 8'd0;
reg [7:0] rx_data_buf_46 = 8'd0;
reg [7:0] rx_data_buf_47 = 8'd0;

//reg [22:0] cnt = 23'd0;
reg rx_eop_1 = 1'b0;


// always@(posedge clk_42mhz)begin
//     cnt <= cnt + 1'b1;
// end

// always@(posedge clk_42mhz)begin
//     if(cnt==23'd6000000||cnt==23'd6000001)begin
// //        data_tx <= 8'b0;
//         rx_eop_1 <= 1'b1;
//     end
//     else begin
// //        data_tx <= data_tx;
//         rx_eop_1 <= 1'b0;
//     end
// end



always@(posedge clk_42mhz)begin
  if(rx1_ready)
    rx_cnt <= rx_cnt + 1'b1;
  else if(rx_eop)
    rx_cnt <= 6'b0;
  else
    rx_cnt <= rx_cnt;
end

always@(posedge clk_42mhz)begin
  if(rx1_ready)
    case(rx_cnt)
      6'd0: rx_data_buf_0 <= rx1_data;
      6'd1: rx_data_buf_1 <= rx1_data;
      6'd2: rx_data_buf_2 <= rx1_data;
      6'd3: rx_data_buf_3 <= rx1_data;
      6'd4: rx_data_buf_4 <= rx1_data;
      6'd5: rx_data_buf_5 <= rx1_data;
      6'd6: rx_data_buf_6 <= rx1_data;
      6'd7: rx_data_buf_7 <= rx1_data;
      6'd8: rx_data_buf_8 <= rx1_data;
      6'd9: rx_data_buf_9 <= rx1_data;
      6'd10: rx_data_buf_10 <= rx1_data;
      6'd11: rx_data_buf_11 <= rx1_data;
      6'd12: rx_data_buf_12 <= rx1_data;
      6'd13: rx_data_buf_13 <= rx1_data;
      6'd14: rx_data_buf_14 <= rx1_data;
      6'd15: rx_data_buf_15 <= rx1_data;
      6'd16: rx_data_buf_16 <= rx1_data;
      6'd17: rx_data_buf_17 <= rx1_data;
      6'd18: rx_data_buf_18 <= rx1_data;
      6'd19: rx_data_buf_19 <= rx1_data;
      6'd20: rx_data_buf_20 <= rx1_data;
      6'd21: rx_data_buf_21 <= rx1_data;
      6'd22: rx_data_buf_22 <= rx1_data;
      6'd23: rx_data_buf_23 <= rx1_data;
      6'd24: rx_data_buf_24 <= rx1_data;
      6'd25: rx_data_buf_25 <= rx1_data;
      6'd26: rx_data_buf_26 <= rx1_data;
      6'd27: rx_data_buf_27 <= rx1_data;
      6'd28: rx_data_buf_28 <= rx1_data;
      6'd29: rx_data_buf_29 <= rx1_data;
      6'd30: rx_data_buf_30 <= rx1_data;
      6'd31: rx_data_buf_31 <= rx1_data;
      6'd32: rx_data_buf_32 <= rx1_data;
      6'd33: rx_data_buf_33 <= rx1_data;
      6'd34: rx_data_buf_34 <= rx1_data;
      6'd35: rx_data_buf_35 <= rx1_data;
      6'd36: rx_data_buf_36 <= rx1_data;
      6'd37: rx_data_buf_37 <= rx1_data;
      6'd38: rx_data_buf_38 <= rx1_data;
      6'd39: rx_data_buf_39 <= rx1_data;
      6'd40: rx_data_buf_40 <= rx1_data;
      6'd41: rx_data_buf_41 <= rx1_data;
      6'd42: rx_data_buf_42 <= rx1_data;
      6'd43: rx_data_buf_43 <= rx1_data;
      6'd44: rx_data_buf_44 <= rx1_data;
      6'd45: rx_data_buf_45 <= rx1_data;
      6'd46: rx_data_buf_46 <= rx1_data;
      6'd47: rx_data_buf_47 <= rx1_data;
      default:begin
        rx_data_buf_0 <= rx_data_buf_0;
        rx_data_buf_1 <= rx_data_buf_1;
        rx_data_buf_2 <= rx_data_buf_2;
        rx_data_buf_3 <= rx_data_buf_3;
        rx_data_buf_4 <= rx_data_buf_4;
        rx_data_buf_5 <= rx_data_buf_5;
        rx_data_buf_6 <= rx_data_buf_6;
        rx_data_buf_7 <= rx_data_buf_7;
        rx_data_buf_8 <= rx_data_buf_8;
        rx_data_buf_9 <= rx_data_buf_9;
        rx_data_buf_10 <= rx_data_buf_10;
        rx_data_buf_11 <= rx_data_buf_11;
        rx_data_buf_12 <= rx_data_buf_12;
        rx_data_buf_13 <= rx_data_buf_13;
        rx_data_buf_14 <= rx_data_buf_14;
        rx_data_buf_15 <= rx_data_buf_15;
        rx_data_buf_16 <= rx_data_buf_16;
        rx_data_buf_17 <= rx_data_buf_17;
        rx_data_buf_18 <= rx_data_buf_18;
        rx_data_buf_19 <= rx_data_buf_19;
        rx_data_buf_20 <= rx_data_buf_20;
        rx_data_buf_21 <= rx_data_buf_21;
        rx_data_buf_22 <= rx_data_buf_22;
        rx_data_buf_23 <= rx_data_buf_23;
        rx_data_buf_24 <= rx_data_buf_24;
        rx_data_buf_25 <= rx_data_buf_25;
        rx_data_buf_26 <= rx_data_buf_26;
        rx_data_buf_27 <= rx_data_buf_27;
        rx_data_buf_28 <= rx_data_buf_28;
        rx_data_buf_29 <= rx_data_buf_29;
        rx_data_buf_30 <= rx_data_buf_30;
        rx_data_buf_31 <= rx_data_buf_31;
        rx_data_buf_32 <= rx_data_buf_32;
        rx_data_buf_33 <= rx_data_buf_33;
        rx_data_buf_34 <= rx_data_buf_34;
        rx_data_buf_35 <= rx_data_buf_35;
        rx_data_buf_36 <= rx_data_buf_36;
        rx_data_buf_37 <= rx_data_buf_37;
        rx_data_buf_38 <= rx_data_buf_38;
        rx_data_buf_39 <= rx_data_buf_39;
        rx_data_buf_40 <= rx_data_buf_40;
        rx_data_buf_41 <= rx_data_buf_41;
        rx_data_buf_42 <= rx_data_buf_42;
        rx_data_buf_43 <= rx_data_buf_43;
        rx_data_buf_44 <= rx_data_buf_44;
        rx_data_buf_45 <= rx_data_buf_45;
        rx_data_buf_46 <= rx_data_buf_46;
        rx_data_buf_47 <= rx_data_buf_47;
      end
    endcase  
  else  begin
    rx_data_buf_0 <= rx_data_buf_0;
    rx_data_buf_1 <= rx_data_buf_1;
    rx_data_buf_2 <= rx_data_buf_2;
    rx_data_buf_3 <= rx_data_buf_3;
    rx_data_buf_4 <= rx_data_buf_4;
    rx_data_buf_5 <= rx_data_buf_5;
    rx_data_buf_6 <= rx_data_buf_6;
    rx_data_buf_7 <= rx_data_buf_7;
    rx_data_buf_8 <= rx_data_buf_8;
    rx_data_buf_9 <= rx_data_buf_9;
    rx_data_buf_10 <= rx_data_buf_10;
    rx_data_buf_11 <= rx_data_buf_11;
    rx_data_buf_12 <= rx_data_buf_12;
    rx_data_buf_13 <= rx_data_buf_13;
    rx_data_buf_14 <= rx_data_buf_14;
    rx_data_buf_15 <= rx_data_buf_15;
    rx_data_buf_16 <= rx_data_buf_16;
    rx_data_buf_17 <= rx_data_buf_17;
    rx_data_buf_18 <= rx_data_buf_18;
    rx_data_buf_19 <= rx_data_buf_19;
    rx_data_buf_20 <= rx_data_buf_20;
    rx_data_buf_21 <= rx_data_buf_21;
    rx_data_buf_22 <= rx_data_buf_22;
    rx_data_buf_23 <= rx_data_buf_23;
    rx_data_buf_24 <= rx_data_buf_24;
    rx_data_buf_25 <= rx_data_buf_25;
    rx_data_buf_26 <= rx_data_buf_26;
    rx_data_buf_27 <= rx_data_buf_27;
    rx_data_buf_28 <= rx_data_buf_28;
    rx_data_buf_29 <= rx_data_buf_29;
    rx_data_buf_30 <= rx_data_buf_30;
    rx_data_buf_31 <= rx_data_buf_31;
    rx_data_buf_32 <= rx_data_buf_32;
    rx_data_buf_33 <= rx_data_buf_33;
    rx_data_buf_34 <= rx_data_buf_34;
    rx_data_buf_35 <= rx_data_buf_35;
    rx_data_buf_36 <= rx_data_buf_36;
    rx_data_buf_37 <= rx_data_buf_37;
    rx_data_buf_38 <= rx_data_buf_38;
    rx_data_buf_39 <= rx_data_buf_39;
    rx_data_buf_40 <= rx_data_buf_40;
    rx_data_buf_41 <= rx_data_buf_41;
    rx_data_buf_42 <= rx_data_buf_42;
    rx_data_buf_43 <= rx_data_buf_43;
    rx_data_buf_44 <= rx_data_buf_44;
    rx_data_buf_45 <= rx_data_buf_45;
    rx_data_buf_46 <= rx_data_buf_46;
    rx_data_buf_47 <= rx_data_buf_47;
  end
end
// Send the received data immediately back

reg [7:0] data_buf;
reg data_flag = 0;
reg data_check_busy = 0;
reg [5:0] tx_cnt = 6'd48;
always @(posedge clk_42mhz) begin
  // we got a new data strobe
  // let's save it and set a flag
  if(rx_eop)
    tx_cnt <= 6'd0;
  else if(tx_cnt <= 6'd47)begin
    if(~data_flag) begin
      case(tx_cnt)
        6'd0: data_buf <= rx_data_buf_0;
        6'd1: data_buf <= rx_data_buf_1;
        6'd2: data_buf <= rx_data_buf_2;
        6'd3: data_buf <= rx_data_buf_3;
        6'd4: data_buf <= rx_data_buf_4;
        6'd5: data_buf <= rx_data_buf_5;
        6'd6: data_buf <= rx_data_buf_6;
        6'd7: data_buf <= rx_data_buf_7;
        6'd8: data_buf <= rx_data_buf_8;
        6'd9: data_buf <= rx_data_buf_9;
        6'd10: data_buf <= rx_data_buf_10;
        6'd11: data_buf <= rx_data_buf_11;
        6'd12: data_buf <= rx_data_buf_12;
        6'd13: data_buf <= rx_data_buf_13;
        6'd14: data_buf <= rx_data_buf_14;
        6'd15: data_buf <= rx_data_buf_15;
        6'd16: data_buf <= rx_data_buf_16;
        6'd17: data_buf <= rx_data_buf_17;
        6'd18: data_buf <= rx_data_buf_18;
        6'd19: data_buf <= rx_data_buf_19;
        6'd20: data_buf <= rx_data_buf_20;
        6'd21: data_buf <= rx_data_buf_21;
        6'd22: data_buf <= rx_data_buf_22;
        6'd23: data_buf <= rx_data_buf_23;
        6'd24: data_buf <= rx_data_buf_24;
        6'd25: data_buf <= rx_data_buf_25;
        6'd26: data_buf <= rx_data_buf_26;
        6'd27: data_buf <= rx_data_buf_27;
        6'd28: data_buf <= rx_data_buf_28;
        6'd29: data_buf <= rx_data_buf_29;
        6'd30: data_buf <= rx_data_buf_30;
        6'd31: data_buf <= rx_data_buf_31;
        6'd32: data_buf <= rx_data_buf_32;
        6'd33: data_buf <= rx_data_buf_33;
        6'd34: data_buf <= rx_data_buf_34;
        6'd35: data_buf <= rx_data_buf_35;
        6'd36: data_buf <= rx_data_buf_36;
        6'd37: data_buf <= rx_data_buf_37;
        6'd38: data_buf <= data_spi_rx;
        6'd39: data_buf <= xdata[19:12];
        6'd40: data_buf <= xdata[11:4];
        6'd41: data_buf <= xdata[3:0];
        6'd42: data_buf <= ydata[19:12];
        6'd43: data_buf <= ydata[11:4];
        6'd44: data_buf <= ydata[3:0];
        6'd45: data_buf <= zdata[19:12];
        6'd46: data_buf <= zdata[11:4];
        // 6'd47: data_buf <= rx_data_buf_47;
        6'd47: data_buf <= zdata[3:0];
        
        default: data_buf <= 8'b0;
      endcase
//      data_buf <= rx1_data;
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
          tx1_data <= data_buf;
          tx1_start <= 1'b1;
//          LED_R <= ~data_buf[0];
//          LED_G <= ~data_buf[1];
        end else begin // Yey we did it!
          tx1_start <= 1'b0;
          data_flag <= 0;
          tx_cnt <= tx_cnt + 1'b1;
        end
      end
    end
  end
end

reg rst = 1'b0;
reg [7:0] data_spi_tx = 8'h08;
wire [7:0] data_spi_rx;
wire req_spi;
wire done_spi;
reg rx_eop_spi = 1'b0;
reg [19:0] xdata_reg;
reg [19:0] ydata_reg;
reg [19:0] zdata_reg;
// wire [19:0] xdata;



always@(posedge clk_42mhz)begin
  rx_eop_spi <= rx_eop;
end

assign req_spi = rx_eop_spi | rx_eop;

reg flag = 1'b0;
//reg data_tx = 15'h2c01;
// always@(posedge clk_42mhz)begin
//   if(rx_eop)
//     flag <= ~flag;
//   else
//     flag <= flag;
// end

reg [3:0] cnt_d1;
reg [3:0] cnt = 4'd0;
reg spi_flag = 1'b0;

reg [15:0] data_tx = 16'h0;
wire [7:0] data_rx;
reg req;
reg wr_en;
wire done;


spi spi(
    .clk(clk_42mhz),
    .rst(rst),
    .sclk(sclk),
    .data_tx(data_tx),
    .data_rx(data_rx),
    .req(req),
    .wr_en(wr_en),
    .tx(mosi),
    .rx(miso),
    .cs_n(cs_n),
    .done(done)
);

// always@(posedge clk_42mhz)begin
//     if(rx_cnt==6'd2&&rx1_ready)
//         req <= 1'b1;
//     else
//         req <= 1'b0;
// end

always@(posedge clk_42mhz)
    cnt_d1 <= cnt;
    
always@(posedge clk_42mhz)begin
    if(rx_cnt==6'd2&&rx1_ready)
        spi_flag <= 1'b1;
    else if(cnt==4'd13&&done)
        spi_flag <= 1'b0;
    else
        spi_flag <= spi_flag;
end

always@(posedge clk_42mhz)begin
    if(spi_flag)begin
        case(cnt)
            4'd0:
                cnt <= cnt + 1'b1;
            4'd1:begin
                if(cnt_d1==4'd0)
                    req <= 1'b1;
                else
                    req <= 1'b0;
                wr_en <= 1'b1;
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
                wr_en <= 1'b1;
                data_tx <= 16'h002d;
                if(done)
                    cnt <= cnt + 1'b1;
                else
                    cnt <= cnt;
            end
            4'd3:begin
                if(cnt_d1==4'd2||cnt_d1==4'd14)
                    req <= 1'b1;
                else
                    req <= 1'b0;
                wr_en <= 1'b0;
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
                wr_en <= 1'b0;
                data_tx <= 16'h009;
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
                wr_en <= 1'b0;
                data_tx <= 16'h00a;
                if(done)begin
                    xdata[3:0] = data_rx[7:4];
                    cnt <= cnt + 1'b1;
                end
                else begin
                    xdata <= xdata;
                    cnt <= cnt;
                end
            end
            4'd6:begin
                if(cnt_d1==4'd5)
                    req <= 1'b1;
                else
                    req <= 1'b0;
                wr_en <= 1'b0;
                data_tx <= 16'h000b;
                if(done)begin
                    ydata[19:12] = data_rx;
                    cnt <= cnt + 1'b1;
                end
                else begin
                    ydata <= ydata;
                    cnt <= cnt;
                end
            end
            4'd7:begin
                if(cnt_d1==4'd6)
                    req <= 1'b1;
                else
                    req <= 1'b0;
                wr_en <= 1'b0;
                data_tx <= 16'h00c;
                if(done)begin
                    ydata[11:4] = data_rx;
                    cnt <= cnt + 1'b1;
                end
                else begin
                    ydata <= ydata;
                    cnt <= cnt;
                end
            end
            4'd8:begin
                if(cnt_d1==4'd7)
                    req <= 1'b1;
                else
                    req <= 1'b0;
                wr_en <= 1'b0;
                data_tx <= 16'h00d;
                if(done)begin
                    ydata[3:0] = data_rx[7:4];
                    cnt <= cnt + 1'b1;
                end
                else begin
                    ydata <= ydata;
                    cnt <= cnt;
                end
            end
            4'd9:begin
                if(cnt_d1==4'd8)
                    req <= 1'b1;
                else
                    req <= 1'b0;
                wr_en <= 1'b0;
                data_tx <= 16'h000e;
                if(done)begin
                    zdata[19:12] = data_rx;
                    cnt <= cnt + 1'b1;
                end
                else begin
                    zdata <= zdata;
                    cnt <= cnt;
                end
            end
            4'd10:begin
                if(cnt_d1==4'd9)
                    req <= 1'b1;
                else
                    req <= 1'b0;
                wr_en <= 1'b0;
                data_tx <= 16'h00f;
                if(done)begin
                    zdata[11:4] = data_rx;
                    cnt <= cnt + 1'b1;
                end
                else begin
                    zdata <= zdata;
                    cnt <= cnt;
                end
            end
            4'd11:begin
                if(cnt_d1==4'd10)
                    req <= 1'b1;
                else
                    req <= 1'b0;
                wr_en <= 1'b0;
                data_tx <= 16'h0010;
                if(done)begin
                    zdata[3:0] = data_rx[7:4];
                    cnt <= cnt + 1'b1;
                end
                else begin
                    zdata <= zdata;
                    cnt <= cnt;
                end
            end
            4'd12:begin
                if(cnt_d1==4'd11)
                    req <= 1'b1;
                else
                    req <= 1'b0;
                wr_en <= 1'b0;
                data_tx <= 16'h006;
                if(done)begin
                    temp1 = data_rx;
                    cnt <= cnt + 1'b1;
                end
                else begin
                    temp1 <= temp1;
                    cnt <= cnt;
                end
            end
            4'd13:begin
                if(cnt_d1==4'd12)
                    req <= 1'b1;
                else
                    req <= 1'b0;
                wr_en <= 1'b0;
                data_tx <= 16'h007;
                if(done)begin
                    temp2 = data_rx;
                    cnt <= cnt + 1'b1;
                end
                else begin
                    temp2 <= temp2;
                    cnt <= cnt;
                end
            end
            4'd14:begin
                if(spi_flag)
                    cnt <= 4'd3;
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
