{signal: [
  {name: 'clk'         , wave: 'p..........'},
  {name: 'desc_i_rdy'  , wave: '01........0', data: ['D1']},
  {name: 'desc_i'      , wave: 'x2........x', data: ['desc_in']},
  {name: 'desc_i_vld'  , wave: '010........', data: ['addr1']},
  {name: 'desc_o'      , wave: 'x222222222x', data: ['d1', 'd2', 'd3', 'd4', 'd5', 'd6', 'd7', 'd8', 'd9']},
  {name: 'desc_o_vld'  , wave: '01........0'},
  {name: 'split_flag'  , wave: 'x22......2x', data: ['sop(01)', '11', 'eop(10)']},
  {name: 'size_rq'     , wave: 'x222222222x', data: ['size1', 'size2', 'size3', 'size4', 'size5', 'size6', 'size7', 'size8', 'size9']},
  {name: 'size_pkt'    , wave: 'x2........x', data: ['psize1']},
  {name: 'npd_type'    , wave: 'x2........x', data: ['type1']},
  {name: 'offset1'     , wave: 'x2........x', data: ['addr1']},
  {name: 'offset2'     , wave: 'x222222222x', data: ['addr1', 'addr2', 'addr3', 'addr4', 'addr5', 'addr6', 'addr7', 'addr8', 'addr9']},
  {name: 'tag_comp'    , wave: 'x2........x', data: ['d1']},
  {name: 'desc_fun'    , wave: 'x2........x', data: ['func1']},
  {name: 'desc_index'  , wave: 'x2........x', data: ['index1']},
  {name: 'ctrl_vld'    , wave: '01........0'}
  ],
  config: { hscale: 1.5 } 
}














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

reg [15:0] data_tx = 16'h0e;
wire [15:0] data_rx;
reg req;
reg wr_en = 1'b0;
wire done;

reg [15:0] xdata = 16'haa;
reg [15:0] ydata = 16'haa;
reg [19:0] zdata;
reg [15:0] ram_data_in;
reg [15:0] temp1 = 16'haa;
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

assign addr_1 = pingpong_flag ? rx_cnt : tx_cnt_uart;
assign addr_2 = pingpong_flag ? tx_cnt_uart : rx_cnt;

assign wren_1 = pingpong_flag ? rx1_ready : 1'b0;
assign wren_2 = pingpong_flag ? 1'b0 : rx1_ready;



always@(posedge clk_42mhz)begin
  if(rx_eop_cnt<4'd8 && rx_eop)
    rx_eop_cnt <= rx_eop_cnt + 1'b1;
  else if(rx_eop_cnt==4'd8)
    rx_eop_cnt <= 1'b0;
  else
    rx_eop_cnt <= rx_eop_cnt;
end

assign tx_cnt_uart <= (tx_cnt <= 'd383) ? tx_cnt : 0;
assign tx_cnt_vector <= (tx_cnt <= 'd383) ? 0 : tx_cnt-'d383;

// always@(posedge clk_42mhz)begin
//     data_flag <= data_flag_1;
// end

always @(posedge clk_42mhz) begin
  // we got a new data strobe
  // let's save it and set a flag
  if(rx_eop_cnt==4'd8)
    tx_cnt <= 9'd0;
  else if(tx_cnt <= 9'd383 + ram_wr_addr_vector_reg)begin
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


always@(posedge clk_42mhz)begin
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
   .CLOCK(clk_42mhz),
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
   .CLOCK(clk_42mhz),
   .STANDBY(1'b0),
   .SLEEP(1'b0),
   .POWEROFF(1'b1),
   .DATAOUT(vector_ram_data_out_2)
);
  
always@(posedge clk) begin
  if(rx_eop_cnt_sensor==5'd16)begin
    ram_wr_addr_vector <= 8'd0;
  end
  else if(rx_vector_ready) begin
    ram_wr_addr_vector <= ram_wr_addr_vector + 1'b1;
  end
  else begin
    ram_wr_addr_vector <= ram_wr_addr_vector;
  end
end

always@(posedge clk) begin
  if(rx_sensor_ready) begin
    ram_wr_addr_vector_reg <= ram_wr_addr_vector;
  end
  else if(发送完成&&ram_wr_addr_vector_reg>0) begin
    ram_wr_addr_vector_reg <= ram_wr_addr_vector_reg - 1'b1;
  end
  else begin
    ram_wr_addr_vector_reg <= ram_wr_addr_vector_reg;
  end
end

always@(posedge clk)begin
  
