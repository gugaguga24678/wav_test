module top(
  input clk,
  output sclk_16445,
  output mosi_16445,
  input  miso_16445,
  output cs_n_16445,
  output sclk_16209,
  output mosi_16209,
  input  miso_16209,
  output cs_n_16209,
  output sclk_355,
  output mosi_355,
  input  miso_355,
  output cs_n_355,
  output sclk_3100,
  output mosi_3100,
  input  miso_3100,
  output cs_n_3100,
  input RX_sensor,
  output TX_pc,
  input RX_pc,
  input RX_vector,
  output TX_vector
);

wire clk_15m36;
wire rst = 1'b0;
wire rx1_ready;
wire [7:0] rx1_data;
wire rx_idle;
wire rx_eop;

wire wren_1;
wire wren_2;
reg [13:0] rx_cnt = 9'b0;
//reg [23:0] cnt = 24'd0;
reg [15:0] data_in;
wire [13:0] addr_1;
wire [13:0] addr_2;
wire [15:0] data_out_1;
wire [15:0] data_out_2;
reg wr_done_16445 = 1'b0;

reg tx1_start;
reg [7:0] tx1_data;
wire tx1_busy;

reg [7:0] data_buf;
reg data_flag = 0;
reg data_check_busy = 0;
reg [13:0] tx_cnt = 9'd384;

reg pingpong_flag = 1'b0;
reg [4:0] rx_eop_cnt = 4'b0;
reg [7:0] ram_data_in;

reg [4:0] cnt_d1_16445;
reg [4:0] cnt_16445 = 4'd0;
reg spi_flag_16445 = 1'b0;

reg [15:0] data_tx_16445 = 16'h56;
wire [15:0] data_rx_16445;
reg req_16445;
reg wr_en_16445 = 1'b0;
wire done_16445;

reg [15:0] xgyro_16445;
reg [15:0] ygyro_16445;
reg [15:0] zgyro_16445;
reg [15:0] xaccl_16445;
reg [15:0] yaccl_16445;
reg [15:0] zaccl_16445;
reg [15:0] temp1_16445 = 16'haa;
reg [7:0] temp2_16445;

reg [15:0] data_tx_16209 = 16'h0e;
wire [15:0] data_rx_16209;
reg req_16209;
reg wr_en_16209 = 1'b0;
wire done_16209;

reg [15:0] temp_16209;
reg [15:0] xaccl_16209;
reg [15:0] yaccl_16209;
reg [15:0] xincl_16209;
reg [15:0] yincl_16209;

reg [19:0] zdata_16209;
reg [15:0] temp1_16209 = 16'haa;
reg [15:0] temp2_16209 = 16'haa;

reg [4:0] cnt_rm3100_d1;
reg [4:0] cnt_rm3100 = 4'd0;
reg spi_flag_3100 = 1'b0;

reg [15:0] data_tx_3100 = 16'h000b;
reg wr_en_3100 = 1'b0;

wire [7:0] data_rx_3100;
reg req_3100;
wire done_3100;

// wire [15:0] data_tx_3100 = 16'h000b;
// wire wr_en_3100 = 1'b0;

reg [19:0] xdata_rm3100 = 20'h3ffff;
reg [19:0] ydata_rm3100 = 20'h3ffff;
reg [19:0] zdata_rm3100 = 20'h3ffff;
reg [7:0] temp1_rm3100 = 8'h0;
reg [7:0] temp2_rm3100;

reg [3:0] cnt_355_d1;
reg [3:0] cnt_355 = 4'd0;
reg spi_flag_355 = 1'b0;

reg [15:0] data_tx_355 = 16'h0;
wire [7:0] data_rx_355;
reg req_355;
reg wr_en_355;
wire done_355;

reg [19:0] xdata_355;
reg [19:0] ydata_355;
reg [19:0] zdata_355;
reg [7:0] temp1;
reg [7:0] temp2;

reg [2:0] clk_cnt = 3'd0;
reg clk_1m92 = 1'b0;
reg [4:0] cnt_16209_d1;
reg [4:0] cnt_16209 = 5'b0;
reg spi_flag_16209;
wire wren_1_vector;
wire wren_2_vector;
reg pingpong_flag_vector=0;

reg [13:0] ram_wr_addr_vector=0;
wire [13:0] tx_cnt_vector;
//reg [13:0] tx_cnt='d600;
reg [13:0] ram_wr_addr_vector_reg=0;
wire rx_vector_ready;
wire rx_vector_ready_reg;
reg rx_vector_ready_reg_d1;
//reg [7:0] ram_data_in=0;

wire [15:0] vector_ram_data_out_1;
wire [15:0] vector_ram_data_out_2;

reg [63:0] vector_start_str;
reg [95:0] vector_stop_str_1;
reg [87:0] vector_stop_str_2;

reg vector_start_flag=0;
reg vector_stop_flag=0;
reg stop_cnt_flag=0;
reg stop_cnt_flag_d1=0;
reg vector_stop_flag_2=0;
wire stop_cnt_flag_pulse;
reg [23:0] stop_cnt=24'd0;
reg vector_start_flag_d1=0;
reg vector_stop_flag_d1=0;
wire vector_start_flag_pulse;
wire vector_stop_flag_pulse;
reg [9:0] tx_cnt_vector_1='d100;
reg data_flag_vector = 1'b0;
reg [7:0] tx_vector_data=0;
reg tx_vector_start=0;
reg data_check_busy_vector = 0;
wire [7:0] rx_vector_data;
wire [7:0] rx_pc_data;
reg [9:0] tx_cnt_vector_1_thres=10'd0;
wire vector_stop_flag_2_pulse;
reg vector_stop_flag_2_d1;

reg [23:0] vector_init_cnt=24'd0;
reg vector_int_flag=0;
reg vector_int_flag_d1;
wire vector_int_flag_pulse;
reg [63:0] vector_init_str;
reg [13:0] rx_cnt_uart = 9'b0;
wire [13:0] tx_cnt_uart;
wire [13:0] addr_1_vector;
wire [13:0] addr_2_vector;
reg [15:0] cnt_3100_success = 16'b0;
  // assign clk_15m36 = clk;

pll pll_inst(
 .PACKAGEPIN(clk),
 .PLLOUTCORE(clk_15m36),
 .PLLOUTGLOBAL(),
 .RESET(1'b1)
);

uart_rx sensor_rx (
    .clk(clk_15m36),
    .rx(RX_sensor),
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
 .CLOCK(clk_15m36),
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
 .CLOCK(clk_15m36),
 .STANDBY(1'b0),
 .SLEEP(1'b0),
 .POWEROFF(1'b1),
 .DATAOUT(data_out_2)
);

uart_tx_pc pc_tx (
	.clk(clk_15m36),
	.tx_start(tx1_start),
	.tx_data(tx1_data),
	.tx(TX_pc),
	.tx_busy(tx1_busy)
);

always@(posedge clk_15m36)begin
  if(rx_eop_cnt==5'd16)
    pingpong_flag <= ~pingpong_flag;
  else
    pingpong_flag <= pingpong_flag;
end

assign addr_1 = pingpong_flag ? rx_cnt_uart : tx_cnt_uart;
assign addr_2 = pingpong_flag ? tx_cnt_uart : rx_cnt_uart;

// assign addr_1 = pingpong_flag ? rx_cnt_uart : 14'd767;
// assign addr_2 = pingpong_flag ? 14'd767 : rx_cnt_uart;


assign wren_1 = pingpong_flag ? rx1_ready : 1'b0;
assign wren_2 = pingpong_flag ? 1'b0 : rx1_ready;

always@(posedge clk_15m36)begin
  if(rx1_ready)
    rx_cnt_uart <= rx_cnt_uart + 1'b1;
  else if(rx_eop_cnt==5'd16)
    rx_cnt_uart <= 10'b0;
  else
    rx_cnt_uart <= rx_cnt_uart;
end

always@(posedge clk_15m36)begin
  if(rx_eop_cnt<5'd16 && rx_eop)
    rx_eop_cnt <= rx_eop_cnt + 1'b1;
  else if(rx_eop_cnt==5'd16)
    rx_eop_cnt <= 1'b0;
  else
    rx_eop_cnt <= rx_eop_cnt;
end

// always@(posedge clk_15m36)begin
//     ram_data_in <= rx1_data;
// end

assign tx_cnt_uart = (tx_cnt <= 'd767) ? (tx_cnt - 1'b1) : 0;
assign tx_cnt_vector = (tx_cnt <= 'd767) ? 0 : tx_cnt-'d768;

always @(posedge clk_15m36) begin
  if(rx_eop_cnt==5'd16)
    tx_cnt <= 10'd0;
  else if(tx_cnt < 14'd768 + ram_wr_addr_vector_reg)begin
    if(~data_flag) begin
//        data_buf <= pingpong_flag ? data_out_2[7:0] : data_out_1[7:0];
        data_flag <= 1;
        data_check_busy <= 1;
    end
    if(data_flag) begin
      if(data_check_busy) begin
        if(~tx1_busy) begin
          data_check_busy <= 0;
        end
      end else begin
        if(~tx1_busy) begin
          if(tx_cnt==14'd0)
            tx1_data <= 8'haa;
          else if(tx_cnt==14'd1)
            tx1_data <= 8'hee;
          else if(tx_cnt==14'd2)
            tx1_data <= 8'haa;
          else if(tx_cnt==14'd3)
            tx1_data <= 8'hee;
          else if(tx_cnt<14'd768)
            tx1_data <= pingpong_flag ? data_out_2[7:0] : data_out_1[7:0];
          else if(tx_cnt>=14'd768)
            tx1_data <= pingpong_flag_vector ? vector_ram_data_out_2[7:0] : vector_ram_data_out_1[7:0];
          tx1_start <= 1'b1;
        end else begin
          tx1_start <= 1'b0;
          data_flag <= 0;
          tx_cnt <= tx_cnt + 1'b1;
        end
      end
    end
  end
end

always@(posedge clk_15m36)begin
  if(rx_eop_cnt==5'd16)
    pingpong_flag_vector <= ~pingpong_flag_vector;
  else
    pingpong_flag_vector <= pingpong_flag_vector;
end

assign addr_1_vector = pingpong_flag_vector ? ram_wr_addr_vector : tx_cnt_vector;
assign addr_2_vector = pingpong_flag_vector ? tx_cnt_vector : ram_wr_addr_vector;

assign wren_1_vector = pingpong_flag_vector ? rx_vector_ready : 1'b0;
assign wren_2_vector = pingpong_flag_vector ? 1'b0 : rx_vector_ready;

SB_SPRAM256KA vector_ram_1(
 .DATAIN(rx_vector_data),
 .ADDRESS(addr_1_vector),
 .MASKWREN(4'b1111),
 .WREN(wren_1_vector),
 .CHIPSELECT(1'b1),
 .CLOCK(clk_15m36),
 .STANDBY(1'b0),
 .SLEEP(1'b0),
 .POWEROFF(1'b1),
 .DATAOUT(vector_ram_data_out_1)
);

SB_SPRAM256KA vector_ram_2(
 .DATAIN(rx_vector_data),
 .ADDRESS(addr_2_vector),
 .MASKWREN(4'b1111),
 .WREN(wren_2_vector),
 .CHIPSELECT(1'b1),
 .CLOCK(clk_15m36),
 .STANDBY(1'b0),
 .SLEEP(1'b0),
 .POWEROFF(1'b1),
 .DATAOUT(vector_ram_data_out_2)
);
  
  reg [2:0] vector_clk_cnt = 3'b0;
  reg clk_m96 = 1'b0;

always@(posedge clk_15m36)begin
  vector_clk_cnt <= vector_clk_cnt + 1'b1;
end

always@(posedge clk_15m36)begin
  if(vector_clk_cnt==3'd7)
    clk_m96 <= ~clk_m96;
end

uart_rx vector_rx (
    .clk(clk_m96),
    .rx(RX_vector),
    .rx_ready(rx_vector_ready_reg),
    .rx_data(rx_vector_data),
    .rx_idle(rx_vector_idle),
    .rx_eop(rx_vector_eop)
);

always@(posedge clk_15m36)begin
  rx_vector_ready_reg_d1 <= rx_vector_ready_reg;
end

assign rx_vector_ready = rx_vector_ready_reg & ~rx_vector_ready_reg_d1;

uart_tx vector_tx (
	.clk(clk_m96),
	.tx_start(tx_vector_start),
	.tx_data(tx_vector_data),
	.tx(TX_vector),
	.tx_busy(tx_vector_busy)
);

uart_rx_pc pc_rx (
    .clk(clk_15m36),
    .rx(RX_pc),
    .rx_ready(rx_pc_ready),
    .rx_data(rx_pc_data),
    .rx_idle(rx_pc_idle),
    .rx_eop(rx_pc_eop)
);

always@(posedge clk_15m36) begin
  if(rx_eop_cnt==5'd16)begin
    ram_wr_addr_vector <= 8'd0;
  end
  else if(rx_vector_ready) begin
    ram_wr_addr_vector <= ram_wr_addr_vector + 1'b1;
  end
  else begin
    ram_wr_addr_vector <= ram_wr_addr_vector;
  end
end

always@(posedge clk_15m36) begin
  if(rx_eop_cnt==5'd16) begin
    ram_wr_addr_vector_reg <= ram_wr_addr_vector;
  end
  else begin
    ram_wr_addr_vector_reg <= ram_wr_addr_vector_reg;
  end
end

always@(posedge clk_15m36)begin
    if(rx_pc_data==8'hab&&rx_pc_ready)
        vector_int_flag <= 1'b1;
    else if(vector_int_flag&&tx_cnt_vector_1=='d9)
        vector_int_flag <= 1'b0;
    else if(rx_pc_data==8'hcd&&rx_pc_ready )
        vector_stop_flag <= 1'b1;
    else if(vector_stop_flag&&tx_cnt_vector_1=='d13)
        vector_stop_flag <= 1'b0;
    else begin
        vector_int_flag <= vector_int_flag;
        vector_stop_flag <= vector_stop_flag; 
    end
end
//
reg [23:0] start_cnt;
reg start_cnt_flag, start_cnt_flag_d1;
wire start_cnt_flag_pulse;
always@(posedge clk_15m36)begin
  if(vector_int_flag&&tx_cnt_vector_1=='d8)
    start_cnt_flag <= 1'b1;
  else
    start_cnt_flag <= 1'b0;
end

always@(posedge clk_15m36)begin
  start_cnt_flag_d1 <= start_cnt_flag;
end

assign start_cnt_flag_pulse = start_cnt_flag & ~start_cnt_flag_d1;

always@(posedge clk_15m36)begin
  if(start_cnt_flag_pulse)
    start_cnt <= 1'b1;
  else if(start_cnt < 'd15360000&&start_cnt>'d0)
    start_cnt <= start_cnt + 1'b1;
  else
    start_cnt <= start_cnt;
end

always@(posedge clk_15m36)begin
  if(start_cnt=='d15359999)
    vector_start_flag <= 1'b1;
  else if(vector_start_flag&&tx_cnt_vector_1=='d9)
    vector_start_flag <= 1'b0;
  else
    vector_start_flag <= vector_start_flag;
end
//

always@(posedge clk_15m36)begin
  if(vector_stop_flag&&tx_cnt_vector_1=='d12)
    stop_cnt_flag <= 1'b1;
  else
    stop_cnt_flag <= 1'b0;
end

always@(posedge clk_15m36)begin
  stop_cnt_flag_d1 <= stop_cnt_flag;
end

assign stop_cnt_flag_pulse = stop_cnt_flag & ~stop_cnt_flag_d1;

always@(posedge clk_15m36)begin
  if(stop_cnt_flag_pulse)
    stop_cnt <= 1'b1;
  else if(stop_cnt < 'd15360000&&stop_cnt>'d0)
    stop_cnt <= stop_cnt + 1'b1;
  else
    stop_cnt <= stop_cnt;
end

always@(posedge clk_15m36)begin
  if(stop_cnt=='d15359999)
    vector_stop_flag_2 <= 1'b1;
  else if(vector_stop_flag_2&&tx_cnt_vector_1=='d12)
    vector_stop_flag_2 <= 1'b0;
  else
    vector_stop_flag_2 <= vector_stop_flag_2;
end

always@(posedge clk_15m36)begin
  vector_start_flag_d1 <= vector_start_flag;
  vector_stop_flag_d1 <= vector_stop_flag;
end

assign vector_start_flag_pulse = vector_start_flag & ~vector_start_flag_d1;
assign vector_stop_flag_pulse = vector_stop_flag & ~vector_stop_flag_d1;

always@(posedge clk_15m36)begin
    if(vector_start_flag)
        tx_cnt_vector_1_thres <= 10'd8;
    else if(vector_stop_flag)
        tx_cnt_vector_1_thres <= 10'd12;
    else if(vector_stop_flag_2)
        tx_cnt_vector_1_thres <= 10'd11;
    else if(vector_int_flag)
        tx_cnt_vector_1_thres <= 10'd8;
    else
        tx_cnt_vector_1_thres <= tx_cnt_vector_1_thres;
end

always@(posedge clk_15m36)begin
    vector_stop_flag_2_d1 <= vector_stop_flag_2;
end

assign vector_stop_flag_2_pulse = vector_stop_flag_2 & ~vector_stop_flag_2_d1;

// always@(posedge clk_15m36)begin
//     if(vector_init_cnt<'d15360000)
//         vector_init_cnt <= vector_init_cnt+1'b1;
//     else
//         vector_init_cnt <= vector_init_cnt;
// end

// always@(posedge clk_15m36)begin
//     if(vector_init_cnt=='d15359999)
//         vector_int_flag <= 1'b1;
//     else if(vector_int_flag&&tx_cnt_vector_1=='d8)
//         vector_int_flag <= 1'b0;
//     else
//         vector_int_flag <= vector_int_flag;     
// end

always@(posedge clk_15m36)begin
    vector_int_flag_d1 <= vector_int_flag;
end

assign vector_int_flag_pulse = vector_int_flag & ~vector_int_flag_d1;

always @(posedge clk_15m36) begin
  if(vector_start_flag_pulse||vector_stop_flag_pulse||vector_stop_flag_2_pulse||vector_int_flag_pulse)begin
    tx_cnt_vector_1 <= 10'd1;
    vector_start_str <= 64'h5243205243205354;
    vector_stop_str_1 <= 95'h4040404040404b3157252151;
    vector_stop_str_2 <= 88'h4949204949204d43204949;
    vector_init_str <= 64'h4949204944204741;
  end
  else if(tx_cnt_vector_1<=tx_cnt_vector_1_thres&&tx_cnt_vector_1>'d0)begin
    if(~data_flag_vector) begin
        data_flag_vector <= 1;
        data_check_busy_vector <= 1;
    end
    if(data_flag_vector) begin
      if(data_check_busy_vector) begin
        if(~tx_vector_busy) begin
          data_check_busy_vector <= 0;
        end
      end 
      else begin
        if(~tx_vector_busy) begin
          if(vector_start_flag)begin
            tx_vector_data <= vector_start_str[63:56];
          end
          else if(vector_stop_flag)begin
            tx_vector_data <= vector_stop_str_1[95:88];
          end
          else if(vector_stop_flag_2)begin
            tx_vector_data <= vector_stop_str_2[87:80];
          end
          else if(vector_int_flag)
            tx_vector_data <= vector_init_str[63:56];
          tx_vector_start <= 1'b1;
        end 
        else begin
          tx_vector_start <= 1'b0;
          data_flag_vector <= 0;
          tx_cnt_vector_1 <= tx_cnt_vector_1 + 1'b1;
          if(vector_start_flag)begin
            vector_start_str <= {vector_start_str[55:0], vector_start_str[63:56]};
          end
          else if(vector_stop_flag)begin
            vector_stop_str_1 <= {vector_stop_str_1[87:0], vector_stop_str_1[95:88]};
          end
          else if(vector_stop_flag_2)begin
            vector_stop_str_2 <= {vector_stop_str_2[79:0], vector_stop_str_2[87:80]};
          end
          else if(vector_int_flag)
            vector_init_str <= {vector_init_str[55:0], vector_init_str[63:56]};
        end
      end
    end
  end
  else
    tx_cnt_vector_1 <= 10'd0;
end


reg req_16445_d1, req_16445_d2, req_16445_d3, req_16445_d4, req_16445_d5, req_16445_d6, req_16445_d7;//, req_16445_d8, req_16445_d9, req_16445_d10, req_16445_d11, req_16445_d12, req_16445_d13, req_16445_d14, req_16445_d15;
wire req_16445_reg;
wire done_16445_reg;
reg done_16445_d1, done_16445_d2, done_16445_d3, done_16445_d4, done_16445_d5, done_16445_d6, done_16445_d7, done_16445_d8, done_16445_d9, done_16445_d10, done_16445_d11, done_16445_d12, done_16445_d13, done_16445_d14, done_16445_d15, done_16445_d16;
reg done_16445_d17, done_16445_d18, done_16445_d19, done_16445_d20, done_16445_d21, done_16445_d22, done_16445_d23, done_16445_d24, done_16445_d25, done_16445_d26, done_16445_d27, done_16445_d28, done_16445_d29, done_16445_d30, done_16445_d31, done_16445_d32;
reg done_16445_d33,done_16445_d34,done_16445_d35,done_16445_d36,done_16445_d37,done_16445_d38,done_16445_d39,done_16445_d40,done_16445_d41,done_16445_d42,done_16445_d43,done_16445_d44,done_16445_d45,done_16445_d46,done_16445_d47,done_16445_d48,done_16445_d49,done_16445_d50,done_16445_d51,done_16445_d52,done_16445_d53,done_16445_d54,done_16445_d55,done_16445_d56,done_16445_d57,done_16445_d58,done_16445_d59,done_16445_d60,done_16445_d61,done_16445_d62,done_16445_d63,done_16445_d64;
reg done_16445_d65,done_16445_d66,done_16445_d67,done_16445_d68,done_16445_d69,done_16445_d70,done_16445_d71,done_16445_d72,done_16445_d73,done_16445_d74,done_16445_d75,done_16445_d76,done_16445_d77,done_16445_d78,done_16445_d79,done_16445_d80,done_16445_d81,done_16445_d82,done_16445_d83,done_16445_d84,done_16445_d85,done_16445_d86,done_16445_d87,done_16445_d88,done_16445_d89,done_16445_d90,done_16445_d91,done_16445_d92,done_16445_d93,done_16445_d94,done_16445_d95,done_16445_d96,done_16445_d97,done_16445_d98,done_16445_d99,done_16445_d100,done_16445_d101,done_16445_d102,done_16445_d103,done_16445_d104,done_16445_d105,done_16445_d106,done_16445_d107,done_16445_d108,done_16445_d109,done_16445_d110,done_16445_d111,done_16445_d112,done_16445_d113,done_16445_d114,done_16445_d115,done_16445_d116,done_16445_d117,done_16445_d118,done_16445_d119,done_16445_d120,done_16445_d121, done_16445_d122, done_16445_d123, done_16445_d124, done_16445_d125, done_16445_d126, done_16445_d127, done_16445_d128;
spi_adis16445 spi_adis16445(
    .clk(clk_15m36),
    .rst(rst),
    .sclk(sclk_16445),
    .data_tx(data_tx_16445),
    .data_rx(data_rx_16445),
    .req(req_16445_reg),
    .wr_en(wr_en_16445),
    .tx(mosi_16445),
    .rx(miso_16445),
    .cs_n(cs_n_16445),
    .done(done_16445_reg)
);

// always@(posedge clk_15m36)begin
//     if(rx_cnt==6'd2&&rx1_ready)
//         req_16445 <= 1'b1;
//     else
//         req_16445 <= 1'b0;
// end

always@(posedge clk_15m36)begin
    req_16445_d1 <= req_16445;
    req_16445_d2 <= req_16445_d1;
    req_16445_d3 <= req_16445_d2;
    req_16445_d4 <= req_16445_d3;
    req_16445_d5 <= req_16445_d4;
    req_16445_d6 <= req_16445_d5;
    req_16445_d7 <= req_16445_d6;
//    req_16445_d8 <= req_16445_d7;
//    req_16445_d9 <= req_16445_d8;
//    req_16445_d10 <= req_16445_d9;
//    req_16445_d11 <= req_16445_d10;
//    req_16445_d12 <= req_16445_d11;
//    req_16445_d13 <= req_16445_d12;
//    req_16445_d14 <= req_16445_d13;
end

always@(posedge clk_15m36)begin
    done_16445_d1 <= done_16445_reg;
    done_16445_d2 <= done_16445_d1;
    done_16445_d3 <= done_16445_d2;
    done_16445_d4 <= done_16445_d3;
    done_16445_d5 <= done_16445_d4;
    done_16445_d6 <= done_16445_d5;
    done_16445_d7 <= done_16445_d6;
    done_16445_d8 <= done_16445_d7;
    done_16445_d9 <= done_16445_d8;
    done_16445_d10 <= done_16445_d9;
    done_16445_d11 <= done_16445_d10;
    done_16445_d12 <= done_16445_d11;
    done_16445_d13 <= done_16445_d12;
    done_16445_d14 <= done_16445_d13;
    done_16445_d15 <= done_16445_d14;
    done_16445_d16 <= done_16445_d15;
    done_16445_d17 <= done_16445_d16;
    done_16445_d18 <= done_16445_d17;
    done_16445_d19 <= done_16445_d18;
    done_16445_d20 <= done_16445_d19;
    done_16445_d21 <= done_16445_d20;
    done_16445_d22 <= done_16445_d21;
    done_16445_d23 <= done_16445_d22;
    done_16445_d24 <= done_16445_d23;
    done_16445_d25 <= done_16445_d24;
    done_16445_d26 <= done_16445_d25;
    done_16445_d27 <= done_16445_d26;
    done_16445_d28 <= done_16445_d27;
    done_16445_d29 <= done_16445_d28;
    done_16445_d30 <= done_16445_d29;
    done_16445_d31 <= done_16445_d30;
    done_16445_d32 <= done_16445_d31;
    done_16445_d33 <= done_16445_d32;
    done_16445_d34 <= done_16445_d33;
    done_16445_d35 <= done_16445_d34;
    done_16445_d36 <= done_16445_d35;
    done_16445_d37 <= done_16445_d36;
    done_16445_d38 <= done_16445_d37;
    done_16445_d39 <= done_16445_d38;
    done_16445_d40 <= done_16445_d39;
    done_16445_d41 <= done_16445_d40;
    done_16445_d42 <= done_16445_d41;
    done_16445_d43 <= done_16445_d42;
    done_16445_d44 <= done_16445_d43;
    done_16445_d45 <= done_16445_d44;
    done_16445_d46 <= done_16445_d45;
    done_16445_d47 <= done_16445_d46;
    done_16445_d48 <= done_16445_d47;
    done_16445_d49 <= done_16445_d48;
    done_16445_d50 <= done_16445_d49;
    done_16445_d51 <= done_16445_d50;
    done_16445_d52 <= done_16445_d51;
    done_16445_d53 <= done_16445_d52;
    done_16445_d54 <= done_16445_d53;
    done_16445_d55 <= done_16445_d54;
    done_16445_d56 <= done_16445_d55;
    done_16445_d57 <= done_16445_d56;
    done_16445_d58 <= done_16445_d57;
    done_16445_d59 <= done_16445_d58;
    done_16445_d60 <= done_16445_d59;
    done_16445_d61 <= done_16445_d60;
    done_16445_d62 <= done_16445_d61;
    done_16445_d63 <= done_16445_d62;
    done_16445_d64 <= done_16445_d63;
    done_16445_d64 <= done_16445_d63;
    done_16445_d65 <= done_16445_d64;
    done_16445_d66 <= done_16445_d65;
    done_16445_d67 <= done_16445_d66;
    done_16445_d68 <= done_16445_d67;
    done_16445_d69 <= done_16445_d68;
    done_16445_d70 <= done_16445_d69;
    done_16445_d71 <= done_16445_d70;
    done_16445_d72 <= done_16445_d71;
    done_16445_d73 <= done_16445_d72;
    done_16445_d74 <= done_16445_d73;
    done_16445_d75 <= done_16445_d74;
    done_16445_d76 <= done_16445_d75;
    done_16445_d77 <= done_16445_d76;
    done_16445_d78 <= done_16445_d77;
    done_16445_d79 <= done_16445_d78;
    done_16445_d80 <= done_16445_d79;
    done_16445_d81 <= done_16445_d80;
    done_16445_d82 <= done_16445_d81;
    done_16445_d83 <= done_16445_d82;
    done_16445_d84 <= done_16445_d83;
    done_16445_d85 <= done_16445_d84;
    done_16445_d86 <= done_16445_d85;
    done_16445_d87 <= done_16445_d86;
    done_16445_d88 <= done_16445_d87;
    done_16445_d89 <= done_16445_d88;
    done_16445_d90 <= done_16445_d89;
    done_16445_d91 <= done_16445_d90;
    done_16445_d92 <= done_16445_d91;
    done_16445_d93 <= done_16445_d92;
    done_16445_d94 <= done_16445_d93;
    done_16445_d95 <= done_16445_d94;
    done_16445_d96 <= done_16445_d95;
    done_16445_d97 <= done_16445_d96;
    done_16445_d98 <= done_16445_d97;
    done_16445_d99 <= done_16445_d98;
    done_16445_d100 <= done_16445_d99;
    done_16445_d101 <= done_16445_d100;
    done_16445_d102 <= done_16445_d101;
    done_16445_d103 <= done_16445_d102;
    done_16445_d104 <= done_16445_d103;
    done_16445_d105 <= done_16445_d104;
    done_16445_d106 <= done_16445_d105;
    done_16445_d107 <= done_16445_d106;
    done_16445_d108 <= done_16445_d107;
    done_16445_d109 <= done_16445_d108;
    done_16445_d110 <= done_16445_d109;
    done_16445_d111 <= done_16445_d110;
    done_16445_d112 <= done_16445_d111;
    done_16445_d113 <= done_16445_d112;
    done_16445_d114 <= done_16445_d113;
    done_16445_d115 <= done_16445_d114;
    done_16445_d116 <= done_16445_d115;
    done_16445_d117 <= done_16445_d116;
    done_16445_d118 <= done_16445_d117;
    done_16445_d119 <= done_16445_d118;
    done_16445_d120 <= done_16445_d119;
    done_16445_d121 <= done_16445_d120;
    done_16445_d122 <= done_16445_d121;
    done_16445_d123 <= done_16445_d122;
    done_16445_d124 <= done_16445_d123;
    done_16445_d125 <= done_16445_d124;
    done_16445_d126 <= done_16445_d125;
    done_16445_d127 <= done_16445_d126;
    done_16445_d128 <= done_16445_d127;
end

assign done_16445 = ~done_16445_d127 & done_16445_d128;

assign req_16445_reg = req_16445 & ~req_16445_d1;// | req_16445_d2 | req_16445_d3 | req_16445_d4 | req_16445_d5 | req_16445_d6 | req_16445_d7;//| req_16445_d8 | req_16445_d9 | req_16445_d10 | req_16445_d11 | req_16445_d12 | req_16445_d13 | req_16445_d14 | req_16445_d15;

// always@(posedge clk_15m36)begin
//     clk_cnt <= clk_cnt + 1'b1;
// end

// always@(posedge clk_15m36)begin
//     if(clk_cnt==3'd3||clk_cnt==3'd7)
//         clk_1m92 <= ~clk_1m92;
// end

always@(posedge clk_15m36)
   cnt_d1_16445 <= cnt_16445;
    
always@(posedge clk_15m36)begin
   if(rx_cnt_uart==6'd2&&rx1_ready)
       spi_flag_16445 <= 1'b1;
   else if(cnt_16445==5'd7&&done_16445)
       spi_flag_16445 <= 1'b0;
   else
       spi_flag_16445 <= spi_flag_16445;
end

always@(posedge clk_15m36)begin
    if(spi_flag_16445)begin
        case(cnt_16445)
            5'd0:
                cnt_16445 <= cnt_16445 + 1'b1;
            5'd1:begin
                if(cnt_d1_16445==5'd0)
                    req_16445 <= 1'b1;
                else
                    req_16445 <= 1'b0;
                wr_en_16445 <= 1'b0;
                data_tx_16445 <= 16'h0004;
                if(done_16445) begin
                    cnt_16445 <= cnt_16445 + 1'b1;
                    temp1_16445 <= data_rx_16445;
                end
                else begin
                    temp1_16445 <= temp1_16445;
                    cnt_16445 <= cnt_16445;
                end
            end
            5'd2:begin
                if(cnt_d1_16445==5'd1)
                    req_16445 <= 1'b1;
                else
                    req_16445 <= 1'b0;
                wr_en_16445 <= 1'b0;
                data_tx_16445 <= 16'h0006;
                if(done_16445) begin
                    cnt_16445 <= cnt_16445 + 1'b1;
                    xgyro_16445 <= data_rx_16445;
                end
                else begin
                    xgyro_16445 <= xgyro_16445;
                    cnt_16445 <= cnt_16445;
                end
            end
            5'd3:begin
                if(cnt_d1_16445==5'd2)
                    req_16445 <= 1'b1;
                else
                    req_16445 <= 1'b0;
                wr_en_16445 <= 1'b0;
                data_tx_16445 <= 16'h0008;
                if(done_16445) begin
                    cnt_16445 <= cnt_16445 + 1'b1;
                    ygyro_16445 <= data_rx_16445;
                end
                else begin
                    ygyro_16445 <= ygyro_16445;
                    cnt_16445 <= cnt_16445;
                end
            end
            5'd4:begin
                if(cnt_d1_16445==5'd3)
                    req_16445 <= 1'b1;
                else
                    req_16445 <= 1'b0;
                wr_en_16445 <= 1'b0;
                data_tx_16445 <= 16'h000a;
                if(done_16445) begin
                    cnt_16445 <= cnt_16445 + 1'b1;
                    zgyro_16445 <= data_rx_16445;
                end
                else begin
                    zgyro_16445 <= zgyro_16445;
                    cnt_16445 <= cnt_16445;
                end
            end
            5'd5:begin
                if(cnt_d1_16445==5'd4)
                    req_16445 <= 1'b1;
                else
                    req_16445 <= 1'b0;
                wr_en_16445 <= 1'b0;
                data_tx_16445 <= 16'h000c;
                if(done_16445) begin
                    cnt_16445 <= cnt_16445 + 1'b1;
                    xaccl_16445 <= data_rx_16445;
                end
                else begin
                    xaccl_16445 <= xaccl_16445;
                    cnt_16445 <= cnt_16445;
                end
            end
            5'd6:begin
                if(cnt_d1_16445==5'd5)
                    req_16445 <= 1'b1;
                else
                    req_16445 <= 1'b0;
                wr_en_16445 <= 1'b0;
                data_tx_16445 <= 16'h000e;
                if(done_16445) begin
                    cnt_16445 <= cnt_16445 + 1'b1;
                    yaccl_16445 <= data_rx_16445;
                end
                else begin
                    yaccl_16445 <= yaccl_16445;
                    cnt_16445 <= cnt_16445;
                end
            end
            5'd7:begin
                if(cnt_d1_16445==5'd6)
                    req_16445 <= 1'b1;
                else
                    req_16445 <= 1'b0;
                wr_en_16445 <= 1'b0;
                data_tx_16445 <= 16'h0056;
                if(done_16445) begin
                    cnt_16445 <= cnt_16445 + 1'b1;
                    zaccl_16445 <= data_rx_16445;
                end
                else begin
                    zaccl_16445 <= zaccl_16445;
                    cnt_16445 <= cnt_16445;
                end
            end
            5'd8:begin
                if(spi_flag_16445)
                    cnt_16445 <= 5'd0;
                else
                    cnt_16445 <= cnt_16445;
            end
            default:begin
                cnt_16445 <= cnt_16445;
                xgyro_16445 <= xgyro_16445;
                ygyro_16445 <= ygyro_16445;
                zgyro_16445 <= zgyro_16445;
                xaccl_16445 <= xaccl_16445;
                yaccl_16445 <= yaccl_16445;
                zaccl_16445 <= zaccl_16445;
                data_tx_16445 <= data_tx_16445;
                req_16445 <= 1'b0;
                wr_en_16445 <= 1'b0;
            end
        endcase
    end
    else begin
        cnt_16445 <= cnt_16445;
        xgyro_16445 <= xgyro_16445;
        ygyro_16445 <= ygyro_16445;
        zgyro_16445 <= zgyro_16445;
        xaccl_16445 <= xaccl_16445;
        yaccl_16445 <= yaccl_16445;
        zaccl_16445 <= zaccl_16445;
        data_tx_16445 <= data_tx_16445;
        req_16445 <= 1'b0;
        wr_en_16445 <= 1'b0;
    end
end


reg req_16209_d1, req_16209_d2, req_16209_d3, req_16209_d4, req_16209_d5, req_16209_d6, req_16209_d7;//, req_16209_d8, req_16209_d9, req_16209_d10, req_16209_d11, req_16209_d12, req_16209_d13, req_16209_d14, req_16209_d15;
wire req_16209_reg;
wire done_16209_reg;
reg done_16209_d1, done_16209_d2, done_16209_d3, done_16209_d4, done_16209_d5, done_16209_d6, done_16209_d7, done_16209_d8, done_16209_d9, done_16209_d10, done_16209_d11, done_16209_d12, done_16209_d13, done_16209_d14, done_16209_d15, done_16209_d16;
reg done_16209_d17, done_16209_d18, done_16209_d19, done_16209_d20, done_16209_d21, done_16209_d22, done_16209_d23, done_16209_d24, done_16209_d25, done_16209_d26, done_16209_d27, done_16209_d28, done_16209_d29, done_16209_d30, done_16209_d31, done_16209_d32;
reg done_16209_d33,done_16209_d34,done_16209_d35,done_16209_d36,done_16209_d37,done_16209_d38,done_16209_d39,done_16209_d40,done_16209_d41,done_16209_d42,done_16209_d43,done_16209_d44,done_16209_d45,done_16209_d46,done_16209_d47,done_16209_d48,done_16209_d49,done_16209_d50,done_16209_d51,done_16209_d52,done_16209_d53,done_16209_d54,done_16209_d55,done_16209_d56,done_16209_d57,done_16209_d58,done_16209_d59,done_16209_d60,done_16209_d61,done_16209_d62,done_16209_d63,done_16209_d64;
reg done_16209_d65,done_16209_d66,done_16209_d67,done_16209_d68,done_16209_d69,done_16209_d70,done_16209_d71,done_16209_d72,done_16209_d73,done_16209_d74,done_16209_d75,done_16209_d76,done_16209_d77,done_16209_d78,done_16209_d79,done_16209_d80,done_16209_d81,done_16209_d82,done_16209_d83,done_16209_d84,done_16209_d85,done_16209_d86,done_16209_d87,done_16209_d88,done_16209_d89,done_16209_d90,done_16209_d91,done_16209_d92,done_16209_d93,done_16209_d94,done_16209_d95,done_16209_d96,done_16209_d97,done_16209_d98,done_16209_d99,done_16209_d100,done_16209_d101,done_16209_d102,done_16209_d103,done_16209_d104,done_16209_d105,done_16209_d106,done_16209_d107,done_16209_d108,done_16209_d109,done_16209_d110,done_16209_d111,done_16209_d112,done_16209_d113,done_16209_d114,done_16209_d115,done_16209_d116,done_16209_d117,done_16209_d118,done_16209_d119,done_16209_d120,done_16209_d121, done_16209_d122, done_16209_d123, done_16209_d124, done_16209_d125, done_16209_d126, done_16209_d127, done_16209_d128;
spi_adis16209 spi_adis16209(
    .clk(clk_15m36),
    .rst(rst),
    .sclk(sclk_16209),
    .data_tx(data_tx_16209),
    .data_rx(data_rx_16209),
    .req(req_16209_reg),
    .wr_en(wr_en_16209),
    .tx(mosi_16209),
    .rx(miso_16209),
    .cs_n(cs_n_16209),
    .done(done_16209_reg)
);

// always@(posedge clk_15m36)begin
//     if(rx_cnt==6'd2&&rx1_ready)
//         req_16209 <= 1'b1;
//     else
//         req_16209 <= 1'b0;
// end

always@(posedge clk_15m36)begin
    req_16209_d1 <= req_16209;
    req_16209_d2 <= req_16209_d1;
    req_16209_d3 <= req_16209_d2;
    req_16209_d4 <= req_16209_d3;
    req_16209_d5 <= req_16209_d4;
    req_16209_d6 <= req_16209_d5;
    req_16209_d7 <= req_16209_d6;
//    req_16209_d8 <= req_16209_d7;
//    req_16209_d9 <= req_16209_d8;
//    req_16209_d10 <= req_16209_d9;
//    req_16209_d11 <= req_16209_d10;
//    req_16209_d12 <= req_16209_d11;
//    req_16209_d13 <= req_16209_d12;
//    req_16209_d14 <= req_16209_d13;
end

always@(posedge clk_15m36)begin
    done_16209_d1 <= done_16209_reg;
    done_16209_d2 <= done_16209_d1;
    done_16209_d3 <= done_16209_d2;
    done_16209_d4 <= done_16209_d3;
    done_16209_d5 <= done_16209_d4;
    done_16209_d6 <= done_16209_d5;
    done_16209_d7 <= done_16209_d6;
    done_16209_d8 <= done_16209_d7;
    done_16209_d9 <= done_16209_d8;
    done_16209_d10 <= done_16209_d9;
    done_16209_d11 <= done_16209_d10;
    done_16209_d12 <= done_16209_d11;
    done_16209_d13 <= done_16209_d12;
    done_16209_d14 <= done_16209_d13;
    done_16209_d15 <= done_16209_d14;
    done_16209_d16 <= done_16209_d15;
    done_16209_d17 <= done_16209_d16;
    done_16209_d18 <= done_16209_d17;
    done_16209_d19 <= done_16209_d18;
    done_16209_d20 <= done_16209_d19;
    done_16209_d21 <= done_16209_d20;
    done_16209_d22 <= done_16209_d21;
    done_16209_d23 <= done_16209_d22;
    done_16209_d24 <= done_16209_d23;
    done_16209_d25 <= done_16209_d24;
    done_16209_d26 <= done_16209_d25;
    done_16209_d27 <= done_16209_d26;
    done_16209_d28 <= done_16209_d27;
    done_16209_d29 <= done_16209_d28;
    done_16209_d30 <= done_16209_d29;
    done_16209_d31 <= done_16209_d30;
    done_16209_d32 <= done_16209_d31;
    done_16209_d33 <= done_16209_d32;
    done_16209_d34 <= done_16209_d33;
    done_16209_d35 <= done_16209_d34;
    done_16209_d36 <= done_16209_d35;
    done_16209_d37 <= done_16209_d36;
    done_16209_d38 <= done_16209_d37;
    done_16209_d39 <= done_16209_d38;
    done_16209_d40 <= done_16209_d39;
    done_16209_d41 <= done_16209_d40;
    done_16209_d42 <= done_16209_d41;
    done_16209_d43 <= done_16209_d42;
    done_16209_d44 <= done_16209_d43;
    done_16209_d45 <= done_16209_d44;
    done_16209_d46 <= done_16209_d45;
    done_16209_d47 <= done_16209_d46;
    done_16209_d48 <= done_16209_d47;
    done_16209_d49 <= done_16209_d48;
    done_16209_d50 <= done_16209_d49;
    done_16209_d51 <= done_16209_d50;
    done_16209_d52 <= done_16209_d51;
    done_16209_d53 <= done_16209_d52;
    done_16209_d54 <= done_16209_d53;
    done_16209_d55 <= done_16209_d54;
    done_16209_d56 <= done_16209_d55;
    done_16209_d57 <= done_16209_d56;
    done_16209_d58 <= done_16209_d57;
    done_16209_d59 <= done_16209_d58;
    done_16209_d60 <= done_16209_d59;
    done_16209_d61 <= done_16209_d60;
    done_16209_d62 <= done_16209_d61;
    done_16209_d63 <= done_16209_d62;
    done_16209_d64 <= done_16209_d63;
    done_16209_d64 <= done_16209_d63;
    done_16209_d65 <= done_16209_d64;
    done_16209_d66 <= done_16209_d65;
    done_16209_d67 <= done_16209_d66;
    done_16209_d68 <= done_16209_d67;
    done_16209_d69 <= done_16209_d68;
    done_16209_d70 <= done_16209_d69;
    done_16209_d71 <= done_16209_d70;
    done_16209_d72 <= done_16209_d71;
    done_16209_d73 <= done_16209_d72;
    done_16209_d74 <= done_16209_d73;
    done_16209_d75 <= done_16209_d74;
    done_16209_d76 <= done_16209_d75;
    done_16209_d77 <= done_16209_d76;
    done_16209_d78 <= done_16209_d77;
    done_16209_d79 <= done_16209_d78;
    done_16209_d80 <= done_16209_d79;
    done_16209_d81 <= done_16209_d80;
    done_16209_d82 <= done_16209_d81;
    done_16209_d83 <= done_16209_d82;
    done_16209_d84 <= done_16209_d83;
    done_16209_d85 <= done_16209_d84;
    done_16209_d86 <= done_16209_d85;
    done_16209_d87 <= done_16209_d86;
    done_16209_d88 <= done_16209_d87;
    done_16209_d89 <= done_16209_d88;
    done_16209_d90 <= done_16209_d89;
    done_16209_d91 <= done_16209_d90;
    done_16209_d92 <= done_16209_d91;
    done_16209_d93 <= done_16209_d92;
    done_16209_d94 <= done_16209_d93;
    done_16209_d95 <= done_16209_d94;
    done_16209_d96 <= done_16209_d95;
    done_16209_d97 <= done_16209_d96;
    done_16209_d98 <= done_16209_d97;
    done_16209_d99 <= done_16209_d98;
    done_16209_d100 <= done_16209_d99;
    done_16209_d101 <= done_16209_d100;
    done_16209_d102 <= done_16209_d101;
    done_16209_d103 <= done_16209_d102;
    done_16209_d104 <= done_16209_d103;
    done_16209_d105 <= done_16209_d104;
    done_16209_d106 <= done_16209_d105;
    done_16209_d107 <= done_16209_d106;
    done_16209_d108 <= done_16209_d107;
    done_16209_d109 <= done_16209_d108;
    done_16209_d110 <= done_16209_d109;
    done_16209_d111 <= done_16209_d110;
    done_16209_d112 <= done_16209_d111;
    done_16209_d113 <= done_16209_d112;
    done_16209_d114 <= done_16209_d113;
    done_16209_d115 <= done_16209_d114;
    done_16209_d116 <= done_16209_d115;
    done_16209_d117 <= done_16209_d116;
    done_16209_d118 <= done_16209_d117;
    done_16209_d119 <= done_16209_d118;
    done_16209_d120 <= done_16209_d119;
    done_16209_d121 <= done_16209_d120;
    done_16209_d122 <= done_16209_d121;
    done_16209_d123 <= done_16209_d122;
    done_16209_d124 <= done_16209_d123;
    done_16209_d125 <= done_16209_d124;
    done_16209_d126 <= done_16209_d125;
    done_16209_d127 <= done_16209_d126;
    done_16209_d128 <= done_16209_d127;
end

assign done_16209 = ~done_16209_d127 & done_16209_d128;

assign req_16209_reg = req_16209 & ~req_16209_d1;// | req_16209_d2 | req_16209_d3 | req_16209_d4 | req_16209_d5 | req_16209_d6 | req_16209_d7;//| req_16209_d8 | req_16209_d9 | req_16209_d10 | req_16209_d11 | req_16209_d12 | req_16209_d13 | req_16209_d14 | req_16209_d15;

// always@(posedge clk_15m36)begin
//     clk_cnt <= clk_cnt + 1'b1;
// end

// always@(posedge clk_15m36)begin
//     if(clk_cnt==3'd3||clk_cnt==3'd7)
//         clk_1m92 <= ~clk_1m92;
// end

always@(posedge clk_15m36)
   cnt_16209_d1 <= cnt_16209;
    
always@(posedge clk_15m36)begin
   if(rx_cnt_uart==6'd2&&rx1_ready)
       spi_flag_16209 <= 1'b1;
   else if(cnt_16209==5'd8&&done_16209)
       spi_flag_16209 <= 1'b0;
   else
       spi_flag_16209 <= spi_flag_16209;
end

always@(posedge clk_15m36)begin
    if(spi_flag_16209)begin
        case(cnt_16209)
            5'd0:
                cnt_16209 <= cnt_16209 + 1'b1;
            5'd1:begin
                if(cnt_16209_d1==5'd0)
                    req_16209 <= 1'b1;
                else
                    req_16209 <= 1'b0;
                wr_en_16209 <= 1'b0;
                // data_tx_16209 <= 16'h0004;
                data_tx_16209 <= 16'h0004;
                if(done_16209) begin
                    cnt_16209 <= cnt_16209 + 1'b1;
                    // temp1_16209 <= data_rx_16209;
                end
                else begin
                    // temp1_16209 <= temp1_16209;
                    cnt_16209 <= cnt_16209;
                end
            end
            5'd2:begin
                if(cnt_16209_d1==5'd1)
                    req_16209 <= 1'b1;
                else
                    req_16209 <= 1'b0;
                wr_en_16209 <= 1'b0;
                data_tx_16209 <= 16'h0006;
                if(done_16209) begin
                    cnt_16209 <= cnt_16209 + 1'b1;
                    // temp2_16209 <= data_rx_16209;
                    xaccl_16209 <= data_rx_16209;
                end
                else begin
                    // temp2_16209 <= temp2_16209;
                    xaccl_16209 <= xaccl_16209;
                    cnt_16209 <= cnt_16209;
                end
            end
            5'd3:begin
                if(cnt_16209_d1==5'd2)
                    req_16209 <= 1'b1;
                else
                    req_16209 <= 1'b0;
                wr_en_16209 <= 1'b0;
                data_tx_16209 <= 16'h000a;
                if(done_16209) begin
                    cnt_16209 <= cnt_16209 + 1'b1;
                    yaccl_16209 <= data_rx_16209;
                end
                else begin
                    yaccl_16209 <= yaccl_16209;
                    cnt_16209 <= cnt_16209;
                end
            end
            5'd4:begin
                if(cnt_16209_d1==5'd3)
                    req_16209 <= 1'b1;
                else
                    req_16209 <= 1'b0;
                wr_en_16209 <= 1'b0;
                data_tx_16209 <= 16'h000c;
                if(done_16209) begin
                    cnt_16209 <= cnt_16209 + 1'b1;
                    temp_16209 <= data_rx_16209;
                end
                else begin
                    temp_16209 <= temp_16209;
                    cnt_16209 <= cnt_16209;
                end
            end
            5'd5:begin
                if(cnt_16209_d1==5'd4)
                    req_16209 <= 1'b1;
                else
                    req_16209 <= 1'b0;
                wr_en_16209 <= 1'b0;
                data_tx_16209 <= 16'h000e;
                if(done_16209) begin
                    cnt_16209 <= cnt_16209 + 1'b1;
                    xincl_16209 <= data_rx_16209;
                end
                else begin
                    xincl_16209 <= xincl_16209;
                    cnt_16209 <= cnt_16209;
                end
            end
            5'd6:begin
                if(cnt_16209_d1==5'd5)
                    req_16209 <= 1'b1;
                else
                    req_16209 <= 1'b0;
                wr_en_16209 <= 1'b0;
                data_tx_16209 <= 16'h003c;
                if(done_16209) begin
                    cnt_16209 <= cnt_16209 + 1'b1;
                    yincl_16209 <= data_rx_16209;
                end
                else begin
                    yincl_16209 <= yincl_16209;
                    cnt_16209 <= cnt_16209;
                end
            end
            5'd7:begin
                if(cnt_16209_d1==5'd6)
                    req_16209 <= 1'b1;
                else
                    req_16209 <= 1'b0;
                wr_en_16209 <= 1'b0;
                data_tx_16209 <= 16'h004a;
                if(done_16209) begin
                    cnt_16209 <= cnt_16209 + 1'b1;
                    temp2_16209 <= data_rx_16209;
                end
                else begin
                    temp2_16209 <= temp2_16209;
                    cnt_16209 <= cnt_16209;
                end
            end
            5'd8:begin
                if(cnt_16209_d1==5'd7)
                    req_16209 <= 1'b1;
                else
                    req_16209 <= 1'b0;
                wr_en_16209 <= 1'b1;
                data_tx_16209 <= 16'h103e;
                if(done_16209) begin
                    cnt_16209 <= cnt_16209 + 1'b1;
                    temp1_16209 <= data_rx_16209;
                end
                else begin
                    temp1_16209 <= temp1_16209;
                    cnt_16209 <= cnt_16209;
                end
            end
            5'd9:begin
                if(spi_flag_16209)
                    cnt_16209 <= 5'd0;
                else
                    cnt_16209 <= cnt_16209;
            end
            default:begin
                cnt_16209 <= cnt_16209;
                temp_16209 <= temp_16209;
                xaccl_16209  <= xaccl_16209;
                yaccl_16209  <= yaccl_16209;
                xincl_16209  <= xincl_16209;
                yincl_16209  <= yincl_16209;
                data_tx_16209 <= data_tx_16209;
                req_16209 <= 1'b0;
                wr_en_16209 <= 1'b0;
            end
        endcase
    end
    else begin
        cnt_16209 <= cnt_16209;
        temp_16209 <= temp_16209;
        xaccl_16209 <= xaccl_16209;
        yaccl_16209 <= yaccl_16209;
        xincl_16209 <= xincl_16209;
        yincl_16209 <= yincl_16209;
        data_tx_16209 <= data_tx_16209;
        req_16209 <= 1'b0;
        wr_en_16209 <= 1'b0;
    end
end

spi spi(
    .clk(clk_15m36),
    .rst(rst),
    .sclk(sclk_355),
    .data_tx(data_tx_355),
    .data_rx(data_rx_355),
    .req(req_355),
    .wr_en(wr_en_355),
    .tx(mosi_355),
    .rx(miso_355),
    .cs_n(cs_n_355),
    .done(done_355)
);

// always@(posedge clk_15m36)begin
//     if(rx_cnt==6'd2&&rx1_ready)
//         req_355 <= 1'b1;
//     else
//         req_355 <= 1'b0;
// end

always@(posedge clk_15m36)
    cnt_355_d1 <= cnt_355;
    
always@(posedge clk_15m36)begin
    if((rx_cnt_uart==10'd2||rx_cnt_uart==10'd50||rx_cnt_uart==10'd98||rx_cnt_uart==10'd146||rx_cnt_uart==10'd194||rx_cnt_uart==10'd242||rx_cnt_uart==10'd290||rx_cnt_uart==10'd338||rx_cnt_uart==10'd386||rx_cnt_uart==10'd434||rx_cnt_uart==10'd482||rx_cnt_uart==10'd530||rx_cnt_uart==10'd578||rx_cnt_uart==10'd626||rx_cnt_uart==10'd674||rx_cnt_uart==10'd722)&&rx1_ready)
        spi_flag_355 <= 1'b1;
    else if(cnt_355==4'd13&&done_355)
        spi_flag_355 <= 1'b0;
    else
        spi_flag_355 <= spi_flag_355;
end

always@(posedge clk_15m36)begin
    if(spi_flag_355)begin
        case(cnt_355)
            4'd0:
                cnt_355 <= cnt_355 + 1'b1;
            4'd1:begin
                if(cnt_355_d1==4'd0)
                    req_355 <= 1'b1;
                else
                    req_355 <= 1'b0;
                wr_en_355 <= 1'b1;
                data_tx_355 <= 16'h0128;
                if(done_355)
                    cnt_355 <= cnt_355 + 1'b1;
                else
                    cnt_355 <= cnt_355;
            end
            4'd2:begin
                if(cnt_355_d1==4'd1)
                    req_355 <= 1'b1;
                else
                    req_355 <= 1'b0;
                wr_en_355 <= 1'b1;
                data_tx_355 <= 16'h002d;
                if(done_355)
                    cnt_355 <= cnt_355 + 1'b1;
                else
                    cnt_355 <= cnt_355;
            end
            4'd3:begin
                if(cnt_355_d1==4'd2||cnt_355_d1==4'd14)
                    req_355 <= 1'b1;
                else
                    req_355 <= 1'b0;
                wr_en_355 <= 1'b0;
                data_tx_355 <= 16'h0008;
                if(done_355)begin
                    xdata_355[19:12] = data_rx_355;
                    cnt_355 <= cnt_355 + 1'b1;
                end
                else begin
                    xdata_355 <= xdata_355;
                    cnt_355 <= cnt_355;
                end
            end
            4'd4:begin
                if(cnt_355_d1==4'd3)
                    req_355 <= 1'b1;
                else
                    req_355 <= 1'b0;
                wr_en_355 <= 1'b0;
                data_tx_355 <= 16'h009;
                if(done_355)begin
                    xdata_355[11:4] = data_rx_355;
                    cnt_355 <= cnt_355 + 1'b1;
                end
                else begin
                    xdata_355 <= xdata_355;
                    cnt_355 <= cnt_355;
                end
            end
            4'd5:begin
                if(cnt_355_d1==4'd4)
                    req_355 <= 1'b1;
                else
                    req_355 <= 1'b0;
                wr_en_355 <= 1'b0;
                data_tx_355 <= 16'h00a;
                if(done_355)begin
                    xdata_355[3:0] = data_rx_355[7:4];
                    cnt_355 <= cnt_355 + 1'b1;
                end
                else begin
                    xdata_355 <= xdata_355;
                    cnt_355 <= cnt_355;
                end
            end
            4'd6:begin
                if(cnt_355_d1==4'd5)
                    req_355 <= 1'b1;
                else
                    req_355 <= 1'b0;
                wr_en_355 <= 1'b0;
                data_tx_355 <= 16'h000b;
                if(done_355)begin
                    ydata_355[19:12] = data_rx_355;
                    cnt_355 <= cnt_355 + 1'b1;
                end
                else begin
                    ydata_355 <= ydata_355;
                    cnt_355 <= cnt_355;
                end
            end
            4'd7:begin
                if(cnt_355_d1==4'd6)
                    req_355 <= 1'b1;
                else
                    req_355 <= 1'b0;
                wr_en_355 <= 1'b0;
                data_tx_355 <= 16'h00c;
                if(done_355)begin
                    ydata_355[11:4] = data_rx_355;
                    cnt_355 <= cnt_355 + 1'b1;
                end
                else begin
                    ydata_355 <= ydata_355;
                    cnt_355 <= cnt_355;
                end
            end
            4'd8:begin
                if(cnt_355_d1==4'd7)
                    req_355 <= 1'b1;
                else
                    req_355 <= 1'b0;
                wr_en_355 <= 1'b0;
                data_tx_355 <= 16'h00d;
                if(done_355)begin
                    ydata_355[3:0] = data_rx_355[7:4];
                    cnt_355 <= cnt_355 + 1'b1;
                end
                else begin
                    ydata_355 <= ydata_355;
                    cnt_355 <= cnt_355;
                end
            end
            4'd9:begin
                if(cnt_355_d1==4'd8)
                    req_355 <= 1'b1;
                else
                    req_355 <= 1'b0;
                wr_en_355 <= 1'b0;
                data_tx_355 <= 16'h000e;
                if(done_355)begin
                    zdata_355[19:12] = data_rx_355;
                    cnt_355 <= cnt_355 + 1'b1;
                end
                else begin
                    zdata_355 <= zdata_355;
                    cnt_355 <= cnt_355;
                end
            end
            4'd10:begin
                if(cnt_355_d1==4'd9)
                    req_355 <= 1'b1;
                else
                    req_355 <= 1'b0;
                wr_en_355 <= 1'b0;
                data_tx_355 <= 16'h00f;
                if(done_355)begin
                    zdata_355[11:4] = data_rx_355;
                    cnt_355 <= cnt_355 + 1'b1;
                end
                else begin
                    zdata_355 <= zdata_355;
                    cnt_355 <= cnt_355;
                end
            end
            4'd11:begin
                if(cnt_355_d1==4'd10)
                    req_355 <= 1'b1;
                else
                    req_355 <= 1'b0;
                wr_en_355 <= 1'b0;
                data_tx_355 <= 16'h0010;
                if(done_355)begin
                    zdata_355[3:0] = data_rx_355[7:4];
                    cnt_355 <= cnt_355 + 1'b1;
                end
                else begin
                    zdata_355 <= zdata_355;
                    cnt_355 <= cnt_355;
                end
            end
            4'd12:begin
                if(cnt_355_d1==4'd11)
                    req_355 <= 1'b1;
                else
                    req_355 <= 1'b0;
                wr_en_355 <= 1'b0;
                data_tx_355 <= 16'h006;
                if(done_355)begin
                    temp1 = data_rx_355;
                    cnt_355 <= cnt_355 + 1'b1;
                end
                else begin
                    temp1 <= temp1;
                    cnt_355 <= cnt_355;
                end
            end
            4'd13:begin
                if(cnt_355_d1==4'd12)
                    req_355 <= 1'b1;
                else
                    req_355 <= 1'b0;
                wr_en_355 <= 1'b0;
                data_tx_355 <= 16'h007;
                if(done_355)begin
                    temp2 = data_rx_355;
                    cnt_355 <= cnt_355 + 1'b1;
                end
                else begin
                    temp2 <= temp2;
                    cnt_355 <= cnt_355;
                end
            end
            4'd14:begin
                if(spi_flag_355)
                    cnt_355 <= 4'd3;
                else
                    cnt_355 <= cnt_355;
            end
            default:begin
                cnt_355 <= cnt_355;
                xdata_355 <= xdata_355;
                ydata_355 <= ydata_355;
                zdata_355 <= zdata_355;
                data_tx_355 <= data_tx_355;
                req_355 <= 1'b0;
                wr_en_355 <= 1'b0;
            end
        endcase
    end
    else begin
        cnt_355 <= cnt_355;
        xdata_355 <= xdata_355;
        ydata_355 <= ydata_355;
        zdata_355 <= zdata_355;
        data_tx_355 <= data_tx_355;
        req_355 <= 1'b0;
        wr_en_355 <= 1'b0;
    end
end

reg req_3100_d1, req_3100_d2, req_3100_d3, req_3100_d4, req_3100_d5, req_3100_d6, req_3100_d7, req_3100_d8, req_3100_d9, req_3100_d10, req_3100_d11, req_3100_d12, req_3100_d13, req_3100_d14, req_3100_d15;
wire req_3100_reg;
wire done_3100_reg;
reg done_3100_d1, done_3100_d2, done_3100_d3, done_3100_d4, done_3100_d5, done_3100_d6, done_3100_d7, done_3100_d8, done_3100_d9, done_3100_d10, done_3100_d11, done_3100_d12, done_3100_d13, done_3100_d14, done_3100_d15, done_3100_d16;
reg done_3100_d17, done_3100_d18, done_3100_d19, done_3100_d20, done_3100_d21, done_3100_d22, done_3100_d23, done_3100_d24, done_3100_d25, done_3100_d26, done_3100_d27, done_3100_d28, done_3100_d29, done_3100_d30, done_3100_d31, done_3100_d32;
reg done_3100_d33,done_3100_d34,done_3100_d35,done_3100_d36,done_3100_d37,done_3100_d38,done_3100_d39,done_3100_d40,done_3100_d41,done_3100_d42,done_3100_d43,done_3100_d44,done_3100_d45,done_3100_d46,done_3100_d47,done_3100_d48,done_3100_d49,done_3100_d50,done_3100_d51,done_3100_d52,done_3100_d53,done_3100_d54,done_3100_d55,done_3100_d56,done_3100_d57,done_3100_d58,done_3100_d59,done_3100_d60,done_3100_d61,done_3100_d62,done_3100_d63,done_3100_d64;
reg done_3100_d65,done_3100_d66,done_3100_d67,done_3100_d68,done_3100_d69,done_3100_d70,done_3100_d71,done_3100_d72,done_3100_d73,done_3100_d74,done_3100_d75,done_3100_d76,done_3100_d77,done_3100_d78,done_3100_d79,done_3100_d80,done_3100_d81,done_3100_d82,done_3100_d83,done_3100_d84,done_3100_d85,done_3100_d86,done_3100_d87,done_3100_d88,done_3100_d89,done_3100_d90,done_3100_d91,done_3100_d92,done_3100_d93,done_3100_d94,done_3100_d95,done_3100_d96,done_3100_d97,done_3100_d98,done_3100_d99,done_3100_d100,done_3100_d101,done_3100_d102,done_3100_d103,done_3100_d104,done_3100_d105,done_3100_d106,done_3100_d107,done_3100_d108,done_3100_d109,done_3100_d110,done_3100_d111,done_3100_d112,done_3100_d113,done_3100_d114,done_3100_d115,done_3100_d116,done_3100_d117,done_3100_d118,done_3100_d119,done_3100_d120,done_3100_d121, done_3100_d122, done_3100_d123, done_3100_d124, done_3100_d125, done_3100_d126, done_3100_d127, done_3100_d128;
reg done_3100_d129,done_3100_d130,done_3100_d131,done_3100_d132,done_3100_d133,done_3100_d134,done_3100_d135,done_3100_d136,done_3100_d137,done_3100_d138,done_3100_d139,done_3100_d140,done_3100_d141,done_3100_d142,done_3100_d143,done_3100_d144,done_3100_d145,done_3100_d146,done_3100_d147,done_3100_d148,done_3100_d149,done_3100_d150,done_3100_d151,done_3100_d152,done_3100_d153,done_3100_d154,done_3100_d155,done_3100_d156,done_3100_d157,done_3100_d158,done_3100_d159,done_3100_d160,done_3100_d161,done_3100_d162,done_3100_d163,done_3100_d164,done_3100_d165,done_3100_d166,done_3100_d167,done_3100_d168,done_3100_d169,done_3100_d170,done_3100_d171,done_3100_d172,done_3100_d173,done_3100_d174,done_3100_d175,done_3100_d176,done_3100_d177,done_3100_d178,done_3100_d179,done_3100_d180,done_3100_d181,done_3100_d182,done_3100_d183,done_3100_d184,done_3100_d185,done_3100_d186,done_3100_d187,done_3100_d188,done_3100_d189,done_3100_d190,done_3100_d191,done_3100_d192,done_3100_d193,done_3100_d194,done_3100_d195,done_3100_d196,done_3100_d197,done_3100_d198,done_3100_d199,done_3100_d200,done_3100_d201,done_3100_d202,done_3100_d203,done_3100_d204,done_3100_d205,done_3100_d206,done_3100_d207,done_3100_d208,done_3100_d209,done_3100_d210,done_3100_d211,done_3100_d212,done_3100_d213,done_3100_d214,done_3100_d215,done_3100_d216,done_3100_d217,done_3100_d218,done_3100_d219,done_3100_d220,done_3100_d221,done_3100_d222,done_3100_d223,done_3100_d224,done_3100_d225,done_3100_d226,done_3100_d227,done_3100_d228,done_3100_d229,done_3100_d230,done_3100_d231,done_3100_d232,done_3100_d233,done_3100_d234,done_3100_d235,done_3100_d236,done_3100_d237,done_3100_d238,done_3100_d239,done_3100_d240,done_3100_d241,done_3100_d242,done_3100_d243,done_3100_d244,done_3100_d245,done_3100_d246,done_3100_d247,done_3100_d248,done_3100_d249,done_3100_d250,done_3100_d251,done_3100_d252,done_3100_d253,done_3100_d254,done_3100_d255,done_3100_d256;
always@(posedge clk_15m36)begin
    done_3100_d1 <= done_3100_reg;
    done_3100_d2 <= done_3100_d1;
    done_3100_d3 <= done_3100_d2;
    done_3100_d4 <= done_3100_d3;
    done_3100_d5 <= done_3100_d4;
    done_3100_d6 <= done_3100_d5;
    done_3100_d7 <= done_3100_d6;
    done_3100_d8 <= done_3100_d7;
    done_3100_d9 <= done_3100_d8;
    done_3100_d10 <= done_3100_d9;
    done_3100_d11 <= done_3100_d10;
    done_3100_d12 <= done_3100_d11;
    done_3100_d13 <= done_3100_d12;
    done_3100_d14 <= done_3100_d13;
    done_3100_d15 <= done_3100_d14;
    done_3100_d16 <= done_3100_d15;
    done_3100_d17 <= done_3100_d16;
    done_3100_d18 <= done_3100_d17;
    done_3100_d19 <= done_3100_d18;
    done_3100_d20 <= done_3100_d19;
    done_3100_d21 <= done_3100_d20;
    done_3100_d22 <= done_3100_d21;
    done_3100_d23 <= done_3100_d22;
    done_3100_d24 <= done_3100_d23;
    done_3100_d25 <= done_3100_d24;
    done_3100_d26 <= done_3100_d25;
    done_3100_d27 <= done_3100_d26;
    done_3100_d28 <= done_3100_d27;
    done_3100_d29 <= done_3100_d28;
    done_3100_d30 <= done_3100_d29;
    done_3100_d31 <= done_3100_d30;
    done_3100_d32 <= done_3100_d31;
    done_3100_d33 <= done_3100_d32;
    done_3100_d34 <= done_3100_d33;
    done_3100_d35 <= done_3100_d34;
    done_3100_d36 <= done_3100_d35;
    done_3100_d37 <= done_3100_d36;
    done_3100_d38 <= done_3100_d37;
    done_3100_d39 <= done_3100_d38;
    done_3100_d40 <= done_3100_d39;
    done_3100_d41 <= done_3100_d40;
    done_3100_d42 <= done_3100_d41;
    done_3100_d43 <= done_3100_d42;
    done_3100_d44 <= done_3100_d43;
    done_3100_d45 <= done_3100_d44;
    done_3100_d46 <= done_3100_d45;
    done_3100_d47 <= done_3100_d46;
    done_3100_d48 <= done_3100_d47;
    done_3100_d49 <= done_3100_d48;
    done_3100_d50 <= done_3100_d49;
    done_3100_d51 <= done_3100_d50;
    done_3100_d52 <= done_3100_d51;
    done_3100_d53 <= done_3100_d52;
    done_3100_d54 <= done_3100_d53;
    done_3100_d55 <= done_3100_d54;
    done_3100_d56 <= done_3100_d55;
    done_3100_d57 <= done_3100_d56;
    done_3100_d58 <= done_3100_d57;
    done_3100_d59 <= done_3100_d58;
    done_3100_d60 <= done_3100_d59;
    done_3100_d61 <= done_3100_d60;
    done_3100_d62 <= done_3100_d61;
    done_3100_d63 <= done_3100_d62;
    done_3100_d64 <= done_3100_d63;
    done_3100_d65 <= done_3100_d64;
    done_3100_d66 <= done_3100_d65;
    done_3100_d67 <= done_3100_d66;
    done_3100_d68 <= done_3100_d67;
    done_3100_d69 <= done_3100_d68;
    done_3100_d70 <= done_3100_d69;
    done_3100_d71 <= done_3100_d70;
    done_3100_d72 <= done_3100_d71;
    done_3100_d73 <= done_3100_d72;
    done_3100_d74 <= done_3100_d73;
    done_3100_d75 <= done_3100_d74;
    done_3100_d76 <= done_3100_d75;
    done_3100_d77 <= done_3100_d76;
    done_3100_d78 <= done_3100_d77;
    done_3100_d79 <= done_3100_d78;
    done_3100_d80 <= done_3100_d79;
    done_3100_d81 <= done_3100_d80;
    done_3100_d82 <= done_3100_d81;
    done_3100_d83 <= done_3100_d82;
    done_3100_d84 <= done_3100_d83;
    done_3100_d85 <= done_3100_d84;
    done_3100_d86 <= done_3100_d85;
    done_3100_d87 <= done_3100_d86;
    done_3100_d88 <= done_3100_d87;
    done_3100_d89 <= done_3100_d88;
    done_3100_d90 <= done_3100_d89;
    done_3100_d91 <= done_3100_d90;
    done_3100_d92 <= done_3100_d91;
    done_3100_d93 <= done_3100_d92;
    done_3100_d94 <= done_3100_d93;
    done_3100_d95 <= done_3100_d94;
    done_3100_d96 <= done_3100_d95;
    done_3100_d97 <= done_3100_d96;
    done_3100_d98 <= done_3100_d97;
    done_3100_d99 <= done_3100_d98;
    done_3100_d100 <= done_3100_d99;
    done_3100_d101 <= done_3100_d100;
    done_3100_d102 <= done_3100_d101;
    done_3100_d103 <= done_3100_d102;
    done_3100_d104 <= done_3100_d103;
    done_3100_d105 <= done_3100_d104;
    done_3100_d106 <= done_3100_d105;
    done_3100_d107 <= done_3100_d106;
    done_3100_d108 <= done_3100_d107;
    done_3100_d109 <= done_3100_d108;
    done_3100_d110 <= done_3100_d109;
    done_3100_d111 <= done_3100_d110;
    done_3100_d112 <= done_3100_d111;
    done_3100_d113 <= done_3100_d112;
    done_3100_d114 <= done_3100_d113;
    done_3100_d115 <= done_3100_d114;
    done_3100_d116 <= done_3100_d115;
    done_3100_d117 <= done_3100_d116;
    done_3100_d118 <= done_3100_d117;
    done_3100_d119 <= done_3100_d118;
    done_3100_d120 <= done_3100_d119;
    done_3100_d121 <= done_3100_d120;
    done_3100_d122 <= done_3100_d121;
    done_3100_d123 <= done_3100_d122;
    done_3100_d124 <= done_3100_d123;
    done_3100_d125 <= done_3100_d124;
    done_3100_d126 <= done_3100_d125;
    done_3100_d127 <= done_3100_d126;
    done_3100_d128 <= done_3100_d127;
    done_3100_d129 <= done_3100_d128;
    done_3100_d130 <= done_3100_d129;
    done_3100_d131 <= done_3100_d130;
    done_3100_d132 <= done_3100_d131;
    done_3100_d133 <= done_3100_d132;
    done_3100_d134 <= done_3100_d133;
    done_3100_d135 <= done_3100_d134;
    done_3100_d136 <= done_3100_d135;
    done_3100_d137 <= done_3100_d136;
    done_3100_d138 <= done_3100_d137;
    done_3100_d139 <= done_3100_d138;
    done_3100_d140 <= done_3100_d139;
    done_3100_d141 <= done_3100_d140;
    done_3100_d142 <= done_3100_d141;
    done_3100_d143 <= done_3100_d142;
    done_3100_d144 <= done_3100_d143;
    done_3100_d145 <= done_3100_d144;
    done_3100_d146 <= done_3100_d145;
    done_3100_d147 <= done_3100_d146;
    done_3100_d148 <= done_3100_d147;
    done_3100_d149 <= done_3100_d148;
    done_3100_d150 <= done_3100_d149;
    done_3100_d151 <= done_3100_d150;
    done_3100_d152 <= done_3100_d151;
    done_3100_d153 <= done_3100_d152;
    done_3100_d154 <= done_3100_d153;
    done_3100_d155 <= done_3100_d154;
    done_3100_d156 <= done_3100_d155;
    done_3100_d157 <= done_3100_d156;
    done_3100_d158 <= done_3100_d157;
    done_3100_d159 <= done_3100_d158;
    done_3100_d160 <= done_3100_d159;
    done_3100_d161 <= done_3100_d160;
    done_3100_d162 <= done_3100_d161;
    done_3100_d163 <= done_3100_d162;
    done_3100_d164 <= done_3100_d163;
    done_3100_d165 <= done_3100_d164;
    done_3100_d166 <= done_3100_d165;
    done_3100_d167 <= done_3100_d166;
    done_3100_d168 <= done_3100_d167;
    done_3100_d169 <= done_3100_d168;
    done_3100_d170 <= done_3100_d169;
    done_3100_d171 <= done_3100_d170;
    done_3100_d172 <= done_3100_d171;
    done_3100_d173 <= done_3100_d172;
    done_3100_d174 <= done_3100_d173;
    done_3100_d175 <= done_3100_d174;
    done_3100_d176 <= done_3100_d175;
    done_3100_d177 <= done_3100_d176;
    done_3100_d178 <= done_3100_d177;
    done_3100_d179 <= done_3100_d178;
    done_3100_d180 <= done_3100_d179;
    done_3100_d181 <= done_3100_d180;
    done_3100_d182 <= done_3100_d181;
    done_3100_d183 <= done_3100_d182;
    done_3100_d184 <= done_3100_d183;
    done_3100_d185 <= done_3100_d184;
    done_3100_d186 <= done_3100_d185;
    done_3100_d187 <= done_3100_d186;
    done_3100_d188 <= done_3100_d187;
    done_3100_d189 <= done_3100_d188;
    done_3100_d190 <= done_3100_d189;
    done_3100_d191 <= done_3100_d190;
    done_3100_d192 <= done_3100_d191;
    done_3100_d193 <= done_3100_d192;
    done_3100_d194 <= done_3100_d193;
    done_3100_d195 <= done_3100_d194;
    done_3100_d196 <= done_3100_d195;
    done_3100_d197 <= done_3100_d196;
    done_3100_d198 <= done_3100_d197;
    done_3100_d199 <= done_3100_d198;
    done_3100_d200 <= done_3100_d199;
    done_3100_d201 <= done_3100_d200;
    done_3100_d202 <= done_3100_d201;
    done_3100_d203 <= done_3100_d202;
    done_3100_d204 <= done_3100_d203;
    done_3100_d205 <= done_3100_d204;
    done_3100_d206 <= done_3100_d205;
    done_3100_d207 <= done_3100_d206;
    done_3100_d208 <= done_3100_d207;
    done_3100_d209 <= done_3100_d208;
    done_3100_d210 <= done_3100_d209;
    done_3100_d211 <= done_3100_d210;
    done_3100_d212 <= done_3100_d211;
    done_3100_d213 <= done_3100_d212;
    done_3100_d214 <= done_3100_d213;
    done_3100_d215 <= done_3100_d214;
    done_3100_d216 <= done_3100_d215;
    done_3100_d217 <= done_3100_d216;
    done_3100_d218 <= done_3100_d217;
    done_3100_d219 <= done_3100_d218;
    done_3100_d220 <= done_3100_d219;
    done_3100_d221 <= done_3100_d220;
    done_3100_d222 <= done_3100_d221;
    done_3100_d223 <= done_3100_d222;
    done_3100_d224 <= done_3100_d223;
    done_3100_d225 <= done_3100_d224;
    done_3100_d226 <= done_3100_d225;
    done_3100_d227 <= done_3100_d226;
    done_3100_d228 <= done_3100_d227;
    done_3100_d229 <= done_3100_d228;
    done_3100_d230 <= done_3100_d229;
    done_3100_d231 <= done_3100_d230;
    done_3100_d232 <= done_3100_d231;
    done_3100_d233 <= done_3100_d232;
    done_3100_d234 <= done_3100_d233;
    done_3100_d235 <= done_3100_d234;
    done_3100_d236 <= done_3100_d235;
    done_3100_d237 <= done_3100_d236;
    done_3100_d238 <= done_3100_d237;
    done_3100_d239 <= done_3100_d238;
    done_3100_d240 <= done_3100_d239;
    done_3100_d241 <= done_3100_d240;
    done_3100_d242 <= done_3100_d241;
    done_3100_d243 <= done_3100_d242;
    done_3100_d244 <= done_3100_d243;
    done_3100_d245 <= done_3100_d244;
    done_3100_d246 <= done_3100_d245;
    done_3100_d247 <= done_3100_d246;
    done_3100_d248 <= done_3100_d247;
    done_3100_d249 <= done_3100_d248;
    done_3100_d250 <= done_3100_d249;
    done_3100_d251 <= done_3100_d250;
    done_3100_d252 <= done_3100_d251;
    done_3100_d253 <= done_3100_d252;
    done_3100_d254 <= done_3100_d253;
    done_3100_d255 <= done_3100_d254;
    done_3100_d256 <= done_3100_d255;
end

spi_rm3100 spi_rm3100(
    .clk(clk_15m36),
    .rst(rst),
    .sclk(sclk_3100),
    .data_tx(data_tx_3100),
    .data_rx(data_rx_3100),
    .req(req_3100_reg),
    .wr_en(wr_en_3100),
    .tx(mosi_3100),
    .rx(miso_3100),
    .cs_n(cs_n_3100),
    .done(done_3100_reg)
);

// always@(posedge clk_15m36)begin
//     if(rx_cnt_uart==6'd2&&rx1_ready)
//         req_3100 <= 1'b1;
//     else
//         req_3100 <= 1'b0;
// end

always@(posedge clk_15m36)begin
    req_3100_d1 <= req_3100;
    req_3100_d2 <= req_3100_d1;
    req_3100_d3 <= req_3100_d2;
    req_3100_d4 <= req_3100_d3;
    req_3100_d5 <= req_3100_d4;
    req_3100_d6 <= req_3100_d5;
    req_3100_d7 <= req_3100_d6;
    req_3100_d8 <= req_3100_d7;
    req_3100_d9 <= req_3100_d8;
    req_3100_d10 <= req_3100_d9;
    req_3100_d11 <= req_3100_d10;
    req_3100_d12 <= req_3100_d11;
    req_3100_d13 <= req_3100_d12;
    req_3100_d14 <= req_3100_d13;
    req_3100_d15 <= req_3100_d14;
end

assign done_3100 = ~done_3100_d255 & done_3100_d256;

assign req_3100_reg = req_3100 & ~req_3100_d1;

always@(posedge clk_15m36)
    cnt_rm3100_d1 <= cnt_rm3100;
    
always@(posedge clk_15m36)begin
    if(rx_cnt_uart==6'd2&&rx1_ready)
        spi_flag_3100 <= 1'b1;
    else if(cnt_rm3100==5'd20&&done_3100)
        spi_flag_3100 <= 1'b0;
    else
        spi_flag_3100 <= spi_flag_3100;
end

always@(posedge clk_15m36)begin
    if(spi_flag_3100)begin
        case(cnt_rm3100)
            5'd0:
                cnt_rm3100 <= cnt_rm3100 + 1'b1;
            5'd1:begin
                if(cnt_rm3100_d1==5'd0)
                    req_3100 <= 1'b1;
                else
                    req_3100 <= 1'b0;
                wr_en_3100 <= 1'b0;
                data_tx_3100 <= 16'h0005;
                // wr_en_3100 <= 1'b0;
                // data_tx_3100 <= 16'h0005;
                if(done_3100) begin
                    temp1_rm3100 <= data_rx_3100;
                    cnt_rm3100 <= cnt_rm3100 + 1'b1;
                end
                else begin
                    temp1_rm3100 <= temp1_rm3100;
                    cnt_rm3100 <= cnt_rm3100;
                end
            end
            5'd2:begin
                if(cnt_rm3100_d1==5'd1)
                    req_3100 <= 1'b1;
                else
                    req_3100 <= 1'b0;
                wr_en_3100 <= 1'b1;
                data_tx_3100 <= 16'h3205;
                if(done_3100) begin
                    cnt_rm3100 <= cnt_rm3100 + 1'b1;
                    // temp1_rm3100 <= data_rx_3100;
                end
                else begin
                    // temp1_rm3100 <= temp1_rm3100;
                    cnt_rm3100 <= cnt_rm3100;
                end
            end
            5'd3:begin
                if(cnt_rm3100_d1==5'd2)
                    req_3100 <= 1'b1;
                else
                    req_3100 <= 1'b0;
                wr_en_3100 <= 1'b0;
                data_tx_3100 <= 16'h0006;
                if(done_3100)
                    cnt_rm3100 <= cnt_rm3100 + 1'b1;
                else
                    cnt_rm3100 <= cnt_rm3100;
            end
            5'd4:begin
                if(cnt_rm3100_d1==5'd3)
                    req_3100 <= 1'b1;
                else
                    req_3100 <= 1'b0;
                wr_en_3100 <= 1'b1;
                data_tx_3100 <= 16'h3207;
                if(done_3100)
                    cnt_rm3100 <= cnt_rm3100 + 1'b1;
                else
                    cnt_rm3100 <= cnt_rm3100;
            end
            5'd5:begin
                if(cnt_rm3100_d1==5'd4)
                    req_3100 <= 1'b1;
                else
                    req_3100 <= 1'b0;
                wr_en_3100 <= 1'b0;
                data_tx_3100 <= 16'h0008;
                if(done_3100)
                    cnt_rm3100 <= cnt_rm3100 + 1'b1;
                else
                    cnt_rm3100 <= cnt_rm3100;
            end
            5'd6:begin
                if(cnt_rm3100_d1==5'd5)
                    req_3100 <= 1'b1;
                else
                    req_3100 <= 1'b0;
                wr_en_3100 <= 1'b1;
                data_tx_3100 <= 16'h3209;
                if(done_3100)
                    cnt_rm3100 <= cnt_rm3100 + 1'b1;
                else
                    cnt_rm3100 <= cnt_rm3100;
            end
            5'd7:begin
                if(cnt_rm3100_d1==5'd6)
                    req_3100 <= 1'b1;
                else
                    req_3100 <= 1'b0;
                wr_en_3100 <= 1'b1;
                data_tx_3100 <= 16'h950b;
                if(done_3100) begin
                    temp2_rm3100 <= data_rx_3100;
                    cnt_rm3100 <= cnt_rm3100 + 1'b1;
                end
                else begin
                    temp2_rm3100 <= temp2_rm3100;
                    cnt_rm3100 <= cnt_rm3100;
                end
            end
            5'd8:begin
                if(cnt_rm3100_d1==5'd7||cnt_rm3100_d1==5'd21)
                    req_3100 <= 1'b1;
                else
                    req_3100 <= 1'b0;
                wr_en_3100 <= 1'b1;
                data_tx_3100 <= 16'h7001;
                if(done_3100)
                    cnt_rm3100 <= cnt_rm3100 + 1'b1;
                else
                    cnt_rm3100 <= cnt_rm3100;
            end
            5'd9:begin
                if(cnt_rm3100_d1==5'd8||cnt_rm3100_d1==5'd21)
                    req_3100 <= 1'b1;
                else
                    req_3100 <= 1'b0;
                wr_en_3100 <= 1'b1;
                data_tx_3100 <= 16'h7000;
                if(done_3100)begin
                    cnt_rm3100 <= cnt_rm3100 + 1'b1;
//                    temp1_rm3100 <= 8'h0;
                end
                else begin
                    cnt_rm3100 <= cnt_rm3100;
//                    temp1_rm3100 <= temp1_rm3100;
                end
            end
            5'd10:begin
                req_3100 <= 1'b0;
                wr_en_3100 <= 1'b0;
                data_tx_3100 <= data_tx_3100;
                cnt_rm3100 <= cnt_rm3100 + 1'b1;
            end
            5'd11:begin
                if(cnt_rm3100_d1==5'd10)
                    req_3100 <= 1'b1;
                else
                    req_3100 <= 1'b0;
                wr_en_3100 <= 1'b0;
                data_tx_3100 <= 16'h0034;
                if(done_3100)begin
                    // temp1_rm3100 <= temp1_rm3100+ 1'b1;
                    if(data_rx_3100==8'h80)
                        cnt_rm3100 <= cnt_rm3100 + 1'b1;
                    else
                        cnt_rm3100 <= 5'd10;
                end
                else begin
                    // temp1_rm3100 <= temp1_rm3100;
                    cnt_rm3100 <= cnt_rm3100;
                end
            end
            5'd12:begin
                if(cnt_rm3100_d1==5'd11)
                    req_3100 <= 1'b1;
                else
                    req_3100 <= 1'b0;
                wr_en_3100 <= 1'b0;
                data_tx_3100 <= 16'h0024;
                if(done_3100)begin
                    cnt_3100_success <= cnt_3100_success + 1'b1;
                    xdata_rm3100[19:12] = data_rx_3100;
                    cnt_rm3100 <= cnt_rm3100 + 1'b1;
                end
                else begin
                    cnt_3100_success <= cnt_3100_success;
                    xdata_rm3100 <= xdata_rm3100;
                    cnt_rm3100 <= cnt_rm3100;
                end
            end
            5'd13:begin
                if(cnt_rm3100_d1==5'd12)
                    req_3100 <= 1'b1;
                else
                    req_3100 <= 1'b0;
                wr_en_3100 <= 1'b0;
                data_tx_3100 <= 16'h025;
                if(done_3100)begin
                    xdata_rm3100[11:4] = data_rx_3100;
                    cnt_rm3100 <= cnt_rm3100 + 1'b1;
                end
                else begin
                    xdata_rm3100 <= xdata_rm3100;
                    cnt_rm3100 <= cnt_rm3100;
                end
            end
            5'd14:begin
                if(cnt_rm3100_d1==5'd13)
                    req_3100 <= 1'b1;
                else
                    req_3100 <= 1'b0;
                wr_en_3100 <= 1'b0;
                data_tx_3100 <= 16'h026;
                if(done_3100)begin
                    xdata_rm3100[3:0] = data_rx_3100[7:4];
                    cnt_rm3100 <= cnt_rm3100 + 1'b1;
                end
                else begin
                    xdata_rm3100 <= xdata_rm3100;
                    cnt_rm3100 <= cnt_rm3100;
                end
            end
            5'd15:begin
                if(cnt_rm3100_d1==5'd14)
                    req_3100 <= 1'b1;
                else
                    req_3100 <= 1'b0;
                wr_en_3100 <= 1'b0;
                data_tx_3100 <= 16'h0027;
                if(done_3100)begin
                    ydata_rm3100[19:12] = data_rx_3100;
                    cnt_rm3100 <= cnt_rm3100 + 1'b1;
                end
                else begin
                    ydata_rm3100 <= ydata_rm3100;
                    cnt_rm3100 <= cnt_rm3100;
                end
            end
            5'd16:begin
                if(cnt_rm3100_d1==5'd15)
                    req_3100 <= 1'b1;
                else
                    req_3100 <= 1'b0;
                wr_en_3100 <= 1'b0;
                data_tx_3100 <= 16'h028;
                if(done_3100)begin
                    ydata_rm3100[11:4] = data_rx_3100;
                    cnt_rm3100 <= cnt_rm3100 + 1'b1;
                end
                else begin
                    ydata_rm3100 <= ydata_rm3100;
                    cnt_rm3100 <= cnt_rm3100;
                end
            end
            5'd17:begin
                if(cnt_rm3100_d1==5'd16)
                    req_3100 <= 1'b1;
                else
                    req_3100 <= 1'b0;
                wr_en_3100 <= 1'b0;
                data_tx_3100 <= 16'h029;
                if(done_3100)begin
                    ydata_rm3100[3:0] = data_rx_3100[7:4];
                    cnt_rm3100 <= cnt_rm3100 + 1'b1;
                end
                else begin
                    ydata_rm3100 <= ydata_rm3100;
                    cnt_rm3100 <= cnt_rm3100;
                end
            end
            5'd18:begin
                if(cnt_rm3100_d1==5'd17)
                    req_3100 <= 1'b1;
                else
                    req_3100 <= 1'b0;
                wr_en_3100 <= 1'b0;
                data_tx_3100 <= 16'h002a;
                if(done_3100)begin
                    zdata_rm3100[19:12] = data_rx_3100;
                    cnt_rm3100 <= cnt_rm3100 + 1'b1;
                end
                else begin
                    zdata_rm3100 <= zdata_rm3100;
                    cnt_rm3100 <= cnt_rm3100;
                end
            end
            5'd19:begin
                if(cnt_rm3100_d1==5'd18)
                    req_3100 <= 1'b1;
                else
                    req_3100 <= 1'b0;
                wr_en_3100 <= 1'b0;
                data_tx_3100 <= 16'h02b;
                if(done_3100)begin
                    zdata_rm3100[11:4] = data_rx_3100;
                    cnt_rm3100 <= cnt_rm3100 + 1'b1;
                end
                else begin
                    zdata_rm3100 <= zdata_rm3100;
                    cnt_rm3100 <= cnt_rm3100;
                end
            end
            5'd20:begin
                if(cnt_rm3100_d1==5'd19)
                    req_3100 <= 1'b1;
                else
                    req_3100 <= 1'b0;
                wr_en_3100 <= 1'b0;
                data_tx_3100 <= 16'h002c;
                if(done_3100)begin
                    zdata_rm3100[3:0] = data_rx_3100[7:4];
                    cnt_rm3100 <= cnt_rm3100 + 1'b1;
                end
                else begin
                    zdata_rm3100 <= zdata_rm3100;
                    cnt_rm3100 <= cnt_rm3100;
                end
            end
            5'd21:begin
                if(spi_flag_3100)
                    cnt_rm3100 <= 5'd8;
                else
                    cnt_rm3100 <= cnt_rm3100;
            end
            default:begin
                cnt_rm3100 <= cnt_rm3100;
                xdata_rm3100 <= xdata_rm3100;
                ydata_rm3100 <= ydata_rm3100;
                zdata_rm3100 <= zdata_rm3100;
                data_tx_3100 <= data_tx_3100;
                req_3100 <= 1'b0;
                wr_en_3100 <= 1'b0;
            end
        endcase
    end
    else begin
        cnt_rm3100 <= cnt_rm3100;
        xdata_rm3100 <= xdata_rm3100;
        ydata_rm3100 <= ydata_rm3100;
        zdata_rm3100 <= zdata_rm3100;
        data_tx_3100 <= data_tx_3100;
        req_3100 <= 1'b0;
        wr_en_3100 <= 1'b0;
    end
end


always@(posedge clk_15m36)begin
  case(rx_cnt_uart)
    14'd36,14'd84,14'd132,14'd180,14'd228,14'd276,14'd324,14'd372,14'd420,14'd468,14'd516,14'd564,14'd612,14'd660,14'd708,14'd756:
        ram_data_in <= xdata_355[19:12];
    14'd37,14'd85,14'd133,14'd181,14'd229,14'd277,14'd325,14'd373,14'd421,14'd469,14'd517,14'd565,14'd613,14'd661,14'd709,14'd757:
        ram_data_in <= xdata_355[11:4];
    14'd38,14'd86,14'd134,14'd182,14'd230,14'd278,14'd326,14'd374,14'd422,14'd470,14'd518,14'd566,14'd614,14'd662,14'd710,14'd758:
        ram_data_in <= {4'b0, xdata_355[3:0]};
    14'd39,14'd87,14'd135,14'd183,14'd231,14'd279,14'd327,14'd375,14'd423,14'd471,14'd519,14'd567,14'd615,14'd663,14'd711,14'd759:
        ram_data_in <= ydata_355[19:12];
    14'd40,14'd88,14'd136,14'd184,14'd232,14'd280,14'd328,14'd376,14'd424,14'd472,14'd520,14'd568,14'd616,14'd664,14'd712,14'd760:
        ram_data_in <= ydata_355[11:4];
    14'd41,14'd89,14'd137,14'd185,14'd233,14'd281,14'd329,14'd377,14'd425,14'd473,14'd521,14'd569,14'd617,14'd665,14'd713,14'd761:
        ram_data_in <= {4'b0, ydata_355[3:0]};
    14'd42,14'd90,14'd138,14'd186,14'd234,14'd282,14'd330,14'd378,14'd426,14'd474,14'd522,14'd570,14'd618,14'd666,14'd714,14'd762:
        ram_data_in <= zdata_355[19:12];
    14'd43,14'd91,14'd139,14'd187,14'd235,14'd283,14'd331,14'd379,14'd427,14'd475,14'd523,14'd571,14'd619,14'd667,14'd715,14'd763:
        ram_data_in <= zdata_355[11:4];
    14'd44,14'd92,14'd140,14'd188,14'd236,14'd284,14'd332,14'd380,14'd428,14'd476,14'd524,14'd572,14'd620,14'd668,14'd716,14'd764:
        ram_data_in <= {4'b0, zdata_355[3:0]};
    14'd45,14'd93,14'd141,14'd189,14'd237,14'd285,14'd333,14'd381,14'd429,14'd477,14'd525,14'd573,14'd621,14'd669,14'd717,14'd765:
        ram_data_in <= temp2;
    14'd46,14'd94,14'd142,14'd190,14'd238,14'd286,14'd334,14'd382,14'd430,14'd478,14'd526,14'd574,14'd622,14'd670,14'd718,14'd766:
        ram_data_in <= temp1;
    14'd47: ram_data_in <= xgyro_16445[15:8];
    14'd48: ram_data_in <= xgyro_16445[7:0];
    14'd49: ram_data_in <= ygyro_16445[15:8];
    14'd50: ram_data_in <= ygyro_16445[7:0];
    14'd95: ram_data_in <= zgyro_16445[15:8];
    14'd96: ram_data_in <= zgyro_16445[7:0];
    14'd97: ram_data_in <= xaccl_16445[15:8];
    14'd98: ram_data_in <= xaccl_16445[7:0];
    14'd143: ram_data_in <= yaccl_16445[15:8];
    14'd144: ram_data_in <= yaccl_16445[7:0];
    14'd145: ram_data_in <= zaccl_16445[15:8];
    14'd146: ram_data_in <= zaccl_16445[7:0];
    // 14'd145: ram_data_in <= 8'haa;
    // 14'd146: ram_data_in <= 8'hbb;    
    14'd191: ram_data_in <= xaccl_16209[15:8];
    14'd192: ram_data_in <= xaccl_16209[7:0];
    // 14'd191: ram_data_in <= temp1_16209[15:8];
    // 14'd192: ram_data_in <= temp1_16209[7:0];
    14'd193: ram_data_in <= yaccl_16209[15:8];
    14'd194: ram_data_in <= yaccl_16209[7:0];
    // 14'd193: ram_data_in <= temp2_16209[15:8];
    // 14'd194: ram_data_in <= temp2_16209[7:0];
    14'd239: ram_data_in <= temp_16209[15:8];
    14'd240: ram_data_in <= temp_16209[7:0];
    14'd241: ram_data_in <= xincl_16209[15:8];
    14'd242: ram_data_in <= xincl_16209[7:0];
    14'd287: ram_data_in <= yincl_16209[15:8];
    14'd288: ram_data_in <= yincl_16209[7:0];
    14'd289: ram_data_in <= xdata_rm3100[19:12];
    14'd290: ram_data_in <= xdata_rm3100[11:4];
    14'd335: ram_data_in <= {4'b0, xdata_rm3100[3:0]};
    14'd336: ram_data_in <= ydata_rm3100[19:12];
    14'd337: ram_data_in <= ydata_rm3100[11:4];
    14'd338: ram_data_in <= {4'b0, ydata_rm3100[3:0]};
    14'd383: ram_data_in <= zdata_rm3100[19:12];
    14'd384: ram_data_in <= zdata_rm3100[11:4];
    14'd385: ram_data_in <= {4'b0, zdata_rm3100[3:0]};
    14'd386: ram_data_in <= 8'haa;
    14'd431: ram_data_in <= temp1_16209[15:8];
    14'd432: ram_data_in <= temp1_16209[7:0];
    14'd433: ram_data_in <= temp2_16209[15:8];
    14'd434: ram_data_in <= temp2_16209[7:0];
    14'd479: ram_data_in <= cnt_3100_success[15:8];
    14'd480: ram_data_in <= cnt_3100_success[7:0];
    // 14'd290: ram_data_in <= 8'haa;
    // 14'd335: ram_data_in <= 8'haa;
    // 14'd336: ram_data_in <= 8'haa;
    // 14'd337: ram_data_in <= 8'haa;
    // 14'd338: ram_data_in <= 8'haa;
    // 14'd383: ram_data_in <= 8'haa;
    // 14'd384: ram_data_in <= 8'haa;
    // 14'd385: ram_data_in <= 8'haa;
    default: ram_data_in <= rx1_data;
  endcase
end

endmodule
