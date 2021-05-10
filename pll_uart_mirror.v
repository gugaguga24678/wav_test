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

reg [22:0] cnt = 23'd0;
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
        6'd39: data_buf <= xdata_reg[19:12];
        6'd40: data_buf <= xdata_reg[11:4];
        6'd41: data_buf <= xdata_reg[3:0];
        6'd42: data_buf <= ydata_reg[19:12];
        6'd43: data_buf <= ydata_reg[11:4];
        6'd44: data_buf <= ydata_reg[3:0];
        6'd45: data_buf <= zdata_reg[19:12];
        6'd46: data_buf <= zdata_reg[11:4];
        // 6'd47: data_buf <= rx_data_buf_47;
        6'd47: data_buf <= zdata_reg[3:0];
        
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
wire [19:0] xdata;
wire [19:0] ydata;
wire [19:0] zdata;


always@(posedge clk_42mhz)begin
  rx_eop_spi <= rx_eop;
end

assign req_spi = rx_eop_spi | rx_eop;

reg flag = 1'b0;
reg data_tx = 15'h2c01;
// always@(posedge clk_42mhz)begin
//   if(rx_eop)
//     flag <= ~flag;
//   else
//     flag <= flag;
// end

wire sclk_wr, sclk_rd, mosi_rd, mosi_wr, cs_n_rd, cs_n_wr, req_wr, req_rd;

spi_wr spi_wr(
.clk(clk_42mhz),
.rst(rst),
.sclk(sclk_wr),
.data_tx(data_tx),
.req(req_wr),
.tx(mosi_wr),
.rx(miso),
.cs_n(cs_n_wr),
.done(done)
);

assign req_wr = flag ? rx_eop : 1'b0;
assign req_rd = flag ? 1'b0 : rx_eop;

assign sclk = flag ? sclk_wr : sclk_rd;
assign mosi = flag ? mosi_wr : mosi_rd;
assign cs_n = flag ? cs_n_wr : cs_n_rd;

spi spi(
    .clk(clk_42mhz),
    .rst(rst),
    .sclk(sclk_rd),
    .data_tx(data_spi_tx),
    .req(req_rd),
    .tx(mosi_rd),
    .rx(miso),
    .data_rx(data_spi_rx),
    .cs_n(cs_n_rd),
    .done(done_spi)
);

// adxl355 adxl355(
//   .clk(clk_42mhz),
//   .rst(rst),
//   .uart_eop(rx_eop),
//   .rx(miso),
//   .tx(mosi),
//   .sclk(sclk),
//   .cs_n(cs_n),
//   .xdata(xdata),
//   .ydata(ydata),
//   .zdata(zdata),
//   .done(done_spi)
// );

// always@(posedge clk_42mhz)begin
//   if(done_spi)begin
//     xdata_reg <= xdata;
//     ydata_reg <= ydata;
//     zdata_reg <= zdata;
//   end
//   else begin
//     xdata_reg <= xdata_reg;
//     ydata_reg <= ydata_reg;
//     zdata_reg <= zdata_reg;
//   end
// end

// Loopback the TX and RX lines with no processing
// Useful as a sanity check ;-)
//assign TX = RX;

endmodule
