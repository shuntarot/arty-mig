module arty_top (
  input         sys_clk,
  input         sys_rstn,
  input         uart_rx,
  output        uart_tx,
  output [3:0]  led
);

  logic         clk;     // 100MHz
  logic         rstn;
  logic         interrupt;
  axi4lite_if   axi();

//-------------------------------------------------------------------------------
// Clock/Reset
//-------------------------------------------------------------------------------

   BUFG clk_buf(.O (clk), .I (sys_clk)); // 100MHz
   assign rstn = sys_rstn;

//-------------------------------------------------------------------------------
// MISC
//-------------------------------------------------------------------------------

  assign led = {3'b0, ~rstn};

//-------------------------------------------------------------------------------
// JTAG
//-------------------------------------------------------------------------------

  jtag_axilite u_jtag (
    .aclk				(clk),
    .aresetn			(rstn),
    .m_axi_awaddr		(axi.awaddr),
    .m_axi_awprot		(),
    .m_axi_awvalid		(axi.awvalid),
    .m_axi_awready		(axi.awready),
    .m_axi_wdata		(axi.wdata),
    .m_axi_wstrb		(axi.wstrb),
    .m_axi_wvalid		(axi.wvalid),
    .m_axi_wready		(axi.wready),
    .m_axi_bresp		(axi.bresp),
    .m_axi_bvalid		(axi.bvalid),
    .m_axi_bready		(axi.bready),
    .m_axi_araddr		(axi.araddr),
    .m_axi_arprot		(),
    .m_axi_arvalid		(axi.arvalid),
    .m_axi_arready		(axi.arready),
    .m_axi_rdata		(axi.rdata),
    .m_axi_rresp		(axi.rresp),
    .m_axi_rvalid		(axi.rvalid),
    .m_axi_rready		(axi.rready)
  );

//-------------------------------------------------------------------------------
// UART
//-------------------------------------------------------------------------------

  uart u_uart (
    .s_axi_aclk			(clk),
    .s_axi_aresetn		(rstn),
    .interrupt			(interrupt), // output
    .s_axi_awaddr		(axi.awaddr),
    .s_axi_awvalid		(axi.awvalid),
    .s_axi_awready		(axi.awready),
    .s_axi_wdata		(axi.wdata),
    .s_axi_wstrb		(axi.wstrb),
    .s_axi_wvalid		(axi.wvalid),
    .s_axi_wready		(axi.wready),
    .s_axi_bresp		(axi.bresp),
    .s_axi_bvalid		(axi.bvalid),
    .s_axi_bready		(axi.bready),
    .s_axi_araddr		(axi.araddr),
    .s_axi_arvalid		(axi.arvalid),
    .s_axi_arready		(axi.arready),
    .s_axi_rdata		(axi.rdata),
    .s_axi_rresp		(axi.rresp),
    .s_axi_rvalid		(axi.rvalid),
    .s_axi_rready		(axi.rready),
    .rx					(uart_rx),
    .tx					(uart_tx)
  );

endmodule
