module arty_top (
  inout [15:0]  ddr3_dq,
  inout [1:0]   ddr3_dqs_n,
  inout [1:0]   ddr3_dqs_p,
  output [13:0] ddr3_addr,
  output [2:0]  ddr3_ba,
  output        ddr3_ras_n,
  output        ddr3_cas_n,
  output        ddr3_we_n,
  output        ddr3_reset_n,
  output [0:0]  ddr3_ck_p,
  output [0:0]  ddr3_ck_n,
  output [0:0]  ddr3_cke,
  output [0:0]  ddr3_cs_n,
  output [1:0]  ddr3_dm,
  output [0:0]  ddr3_odt,
  output [3:0]  led,
  input         sys_clk,
  input         sys_rstn
);

   logic        sys_clk_i; // 166MHz
   logic        clk_ref_i; // 200MHz
   logic        locked;
   logic        mem_rstn;

   logic        clk;       // ui_clk 83.333MHz
   logic        srst;
   logic        init_calib_complete;
   logic        tg_compare_error;
   logic        mig_locked;
   logic        rstn;

   logic [3:0]   m_axi_awid;
   logic [31:0]  m_axi_awaddr;
   logic [7:0]   m_axi_awlen;
   logic [2:0]   m_axi_awsize;
   logic [1:0]   m_axi_awburst;
   logic         m_axi_awlock;
   logic [3:0]   m_axi_awcache;
   logic [2:0]   m_axi_awprot;
   logic         m_axi_awvalid;
   logic         m_axi_awready;
   logic [31:0]  m_axi_wdata;
   logic [3:0]   m_axi_wstrb;
   logic         m_axi_wlast;
   logic         m_axi_wvalid;
   logic         m_axi_wready;
   logic         m_axi_bready;
   logic [3:0]   m_axi_bid;
   logic [1:0]   m_axi_bresp;
   logic         m_axi_bvalid;
   logic [3:0]   m_axi_arid;
   logic [31:0]  m_axi_araddr;
   logic [7:0]   m_axi_arlen;
   logic [2:0]   m_axi_arsize;
   logic [1:0]   m_axi_arburst;
   logic         m_axi_arlock;
   logic [3:0]   m_axi_arcache;
   logic [2:0]   m_axi_arprot;
   logic         m_axi_arvalid;
   logic         m_axi_arready;
   logic         m_axi_rready;
   logic [3:0]   m_axi_rid;
   logic [31:0]  m_axi_rdata;
   logic [1:0]   m_axi_rresp;
   logic         m_axi_rlast;
   logic         m_axi_rvalid;

   logic [3:0]   s_axi_awid;
   logic [27:0]  s_axi_awaddr;
   logic [7:0]   s_axi_awlen;
   logic [2:0]   s_axi_awsize;
   logic [1:0]   s_axi_awburst;
   logic [0:0]   s_axi_awlock;
   logic [3:0]   s_axi_awcache;
   logic [2:0]   s_axi_awprot;
   logic         s_axi_awvalid;
   logic         s_axi_awready;
   logic [127:0] s_axi_wdata;
   logic [15:0]  s_axi_wstrb;
   logic         s_axi_wlast;
   logic         s_axi_wvalid;
   logic         s_axi_wready;
   logic         s_axi_bready;
   logic [3:0]   s_axi_bid;
   logic [1:0]   s_axi_bresp;
   logic         s_axi_bvalid;
   logic [3:0]   s_axi_arid;
   logic [27:0]  s_axi_araddr;
   logic [7:0]   s_axi_arlen;
   logic [2:0]   s_axi_arsize;
   logic [1:0]   s_axi_arburst;
   logic [0:0]   s_axi_arlock;
   logic [3:0]   s_axi_arcache;
   logic [2:0]   s_axi_arprot;
   logic         s_axi_arvalid;
   logic         s_axi_arready;
   logic         s_axi_rready;
   logic [3:0]   s_axi_rid;
   logic [127:0] s_axi_rdata;
   logic [1:0]   s_axi_rresp;
   logic         s_axi_rlast;
   logic         s_axi_rvalid;

//-------------------------------------------------------------------------------
// MISC
//-------------------------------------------------------------------------------
assign led[0] = locked;
assign led[1] = mig_locked;
assign led[2] = tg_compare_error;
assign led[3] = init_calib_complete;

//-------------------------------------------------------------------------------
// Clock/Reset
//-------------------------------------------------------------------------------
logic [7:0]      r_locked;

always @(posedge sys_clk, negedge sys_rstn)
  if (!sys_rstn)
    r_locked <= 0;
  else if (!locked)
    r_locked <= 0;
  else if (locked && r_locked != 8'hff)
    r_locked <= r_locked + 1;

always @(posedge sys_clk, negedge sys_rstn)
  if (!sys_rstn)
    mem_rstn <= 0;
  else if (r_locked[7])
    mem_rstn <= 1;
  else
    mem_rstn <= 0;

always @(posedge clk)
  if (mig_locked)
    rstn <= ~srst;
  else
    rstn <= 1'b0;

//-------------------------------------------------------------------------------
// MMCM
//-------------------------------------------------------------------------------
mmcm u_mmcm(
  .clk_in1  (sys_clk),
  .resetn   (sys_rstn),
  .clk_out1 (sys_clk_i), // 166MHz
  .clk_out2 (clk_ref_i), // 200MHz
  .clk_out3 (),          // 25MHz for ether clock
  .locked   (locked)
);

//-------------------------------------------------------------------------------
// AXI
//-------------------------------------------------------------------------------

// AW/W
logic  awf_full;
logic  awf_empty;
logic  w_awready;
logic  [1:0] w_wsel;
logic  [3:0] w_wstrb;
logic  w_wready;

assign w_awready     = s_axi_awready && !awf_full;
assign s_axi_awvalid = m_axi_awvalid && w_awready;
assign m_axi_awready = w_awready;

assign s_axi_awid    = m_axi_awid;
assign s_axi_awaddr  = {m_axi_awaddr[27:4], 4'b0};
assign s_axi_awlen   = m_axi_awlen;
assign s_axi_awsize  = m_axi_awsize;
assign s_axi_awburst = m_axi_awburst;
assign s_axi_awlock  = m_axi_awlock;
assign s_axi_awcache = m_axi_awcache;
assign s_axi_awprot  = m_axi_awprot;

cmn_fifo #(.DW(4+2), .AW(1))
u_awfifo(
  .clk      (clk),
  .rstn     (rstn),
  .we       (m_axi_awvalid && m_axi_awready),
  .wdata    ({m_axi_wstrb, m_axi_awaddr[3:2]}),
  .re       (s_axi_wvalid && s_axi_wready),
  .rdata    ({w_wstrb, w_wsel}),
  .full     (awf_full),
  .empty    (awf_empty)
);

assign w_wready     = s_axi_wready && !awf_empty;
assign s_axi_wvalid = m_axi_wvalid && w_wready;
assign m_axi_wready = w_wready;

assign s_axi_wdata = {4{m_axi_wdata}};
   
always_comb
   case (w_wsel)
     2'h0: s_axi_wstrb = {12'b0, w_wstrb};
     2'h1: s_axi_wstrb = { 8'b0, w_wstrb, 4'b0};
     2'h2: s_axi_wstrb = { 4'b0, w_wstrb, 8'b0};
     2'h3: s_axi_wstrb = {w_wstrb, 12'b0};
   endcase
   
assign s_axi_wlast = m_axi_wlast;

// B
assign m_axi_bid    = s_axi_bid;
assign m_axi_bresp  = s_axi_bresp;
assign m_axi_bvalid = s_axi_bvalid;
assign s_axi_bready = m_axi_bready;

// AR
logic  arf_full;
logic  arf_empty;
logic  w_arready;
logic  [1:0] w_rsel;

assign w_arready     = s_axi_arready && !arf_full;
assign s_axi_arvalid = m_axi_arvalid && w_arready;
assign m_axi_arready = w_arready;

assign s_axi_arid    = m_axi_arid;
assign s_axi_araddr  = {m_axi_araddr[27:4], 4'b0};
assign s_axi_arlen   = m_axi_arlen;
assign s_axi_arsize  = m_axi_arsize;
assign s_axi_arburst = m_axi_arburst;
assign s_axi_arlock  = m_axi_arlock;
assign s_axi_arcache = m_axi_arcache;
assign s_axi_arprot  = m_axi_arprot;

cmn_fifo #(.DW(2), .AW(1))
u_arfifo(
  .clk      (clk),
  .rstn     (rstn),
  .we       (m_axi_arvalid && m_axi_arready),
  .wdata    (m_axi_araddr[3:2]),
  .re       (m_axi_rvalid && m_axi_rready),
  .rdata    (w_rsel),
  .full     (arf_full),
  .empty    (arf_empty)
);

// R
assign m_axi_rvalid = s_axi_rvalid;
assign m_axi_rid    = s_axi_rid;
   
always_comb
   case (w_rsel)
     2'h0: m_axi_rdata = s_axi_rdata[31:0];
     2'h1: m_axi_rdata = s_axi_rdata[63:32];
     2'h2: m_axi_rdata = s_axi_rdata[95:64];
     2'h3: m_axi_rdata = s_axi_rdata[127:96];
   endcase
   
assign m_axi_rresp  = s_axi_rresp;
assign m_axi_rlast  = s_axi_rlast;
assign s_axi_rready = m_axi_rready;

jtag_axi u_jtag_axi (
  .aclk(clk),                     // input wire aclk
  .aresetn(rstn),                 // input wire aresetn
  .m_axi_awid(m_axi_awid),        // output wire [3 : 0] m_axi_awid
  .m_axi_awaddr(m_axi_awaddr),    // output wire [31 : 0] m_axi_awaddr
  .m_axi_awlen(m_axi_awlen),      // output wire [7 : 0] m_axi_awlen
  .m_axi_awsize(m_axi_awsize),    // output wire [2 : 0] m_axi_awsize
  .m_axi_awburst(m_axi_awburst),  // output wire [1 : 0] m_axi_awburst
  .m_axi_awlock(m_axi_awlock),    // output wire m_axi_awlock
  .m_axi_awcache(m_axi_awcache),  // output wire [3 : 0] m_axi_awcache
  .m_axi_awprot(m_axi_awprot),    // output wire [2 : 0] m_axi_awprot
  .m_axi_awqos(),                 // output wire [3 : 0] m_axi_awqos
  .m_axi_awvalid(m_axi_awvalid),  // output wire m_axi_awvalid
  .m_axi_awready(m_axi_awready),  // input wire m_axi_awready
  .m_axi_wdata(m_axi_wdata),      // output wire [31 : 0] m_axi_wdata
  .m_axi_wstrb(m_axi_wstrb),      // output wire [3 : 0] m_axi_wstrb
  .m_axi_wlast(m_axi_wlast),      // output wire m_axi_wlast
  .m_axi_wvalid(m_axi_wvalid),    // output wire m_axi_wvalid
  .m_axi_wready(m_axi_wready),    // input wire m_axi_wready
  .m_axi_bid(m_axi_bid),          // input wire [3 : 0] m_axi_bid
  .m_axi_bresp(m_axi_bresp),      // input wire [1 : 0] m_axi_bresp
  .m_axi_bvalid(m_axi_bvalid),    // input wire m_axi_bvalid
  .m_axi_bready(m_axi_bready),    // output wire m_axi_bready
  .m_axi_arid(m_axi_arid),        // output wire [3 : 0] m_axi_arid
  .m_axi_araddr(m_axi_araddr),    // output wire [31 : 0] m_axi_araddr
  .m_axi_arlen(m_axi_arlen),      // output wire [7 : 0] m_axi_arlen
  .m_axi_arsize(m_axi_arsize),    // output wire [2 : 0] m_axi_arsize
  .m_axi_arburst(m_axi_arburst),  // output wire [1 : 0] m_axi_arburst
  .m_axi_arlock(m_axi_arlock),    // output wire m_axi_arlock
  .m_axi_arcache(m_axi_arcache),  // output wire [3 : 0] m_axi_arcache
  .m_axi_arprot(m_axi_arprot),    // output wire [2 : 0] m_axi_arprot
  .m_axi_arqos(),                 // output wire [3 : 0] m_axi_arqos
  .m_axi_arvalid(m_axi_arvalid),  // output wire m_axi_arvalid
  .m_axi_arready(m_axi_arready),  // input wire m_axi_arready
  .m_axi_rid(m_axi_rid),          // input wire [3 : 0] m_axi_rid
  .m_axi_rdata(m_axi_rdata),      // input wire [31 : 0] m_axi_rdata
  .m_axi_rresp(m_axi_rresp),      // input wire [1 : 0] m_axi_rresp
  .m_axi_rlast(m_axi_rlast),      // input wire m_axi_rlast
  .m_axi_rvalid(m_axi_rvalid),    // input wire m_axi_rvalid
  .m_axi_rready(m_axi_rready)     // output wire m_axi_rready
);

//-------------------------------------------------------------------------------
// MIG
//-------------------------------------------------------------------------------
mig u_mig (
// Memory interface ports
  .ddr3_addr                      (ddr3_addr),
  .ddr3_ba                        (ddr3_ba),
  .ddr3_cas_n                     (ddr3_cas_n),
  .ddr3_ck_n                      (ddr3_ck_n),
  .ddr3_ck_p                      (ddr3_ck_p),
  .ddr3_cke                       (ddr3_cke),
  .ddr3_ras_n                     (ddr3_ras_n),
  .ddr3_we_n                      (ddr3_we_n),
  .ddr3_dq                        (ddr3_dq),
  .ddr3_dqs_n                     (ddr3_dqs_n),
  .ddr3_dqs_p                     (ddr3_dqs_p),
  .ddr3_reset_n                   (ddr3_reset_n),
  .init_calib_complete            (init_calib_complete),
  .ddr3_cs_n                      (ddr3_cs_n),
  .ddr3_dm                        (ddr3_dm),
  .ddr3_odt                       (ddr3_odt),
// Application interface ports
  .ui_clk                         (clk),  // out
  .ui_clk_sync_rst                (srst), // out
  .mmcm_locked                    (mig_locked),
  .aresetn                        (rstn),
  .app_sr_req                     (1'b0),
  .app_ref_req                    (1'b0),
  .app_zq_req                     (1'b0),
  .app_sr_active                  (),
  .app_ref_ack                    (),
  .app_zq_ack                     (),
// Slave Interface Write Address Ports
  .s_axi_awid                     (s_axi_awid),
  .s_axi_awaddr                   (s_axi_awaddr),
  .s_axi_awlen                    (s_axi_awlen),
  .s_axi_awsize                   (s_axi_awsize),
  .s_axi_awburst                  (s_axi_awburst),
  .s_axi_awlock                   (s_axi_awlock),
  .s_axi_awcache                  (s_axi_awcache),
  .s_axi_awprot                   (s_axi_awprot),
  .s_axi_awqos                    (4'h0),
  .s_axi_awvalid                  (s_axi_awvalid),
  .s_axi_awready                  (s_axi_awready),
// Slave Interface Write Data Ports
  .s_axi_wdata                    (s_axi_wdata),
  .s_axi_wstrb                    (s_axi_wstrb),
  .s_axi_wlast                    (s_axi_wlast),
  .s_axi_wvalid                   (s_axi_wvalid),
  .s_axi_wready                   (s_axi_wready),
// Slave Interface Write Response Ports
  .s_axi_bid                      (s_axi_bid),
  .s_axi_bresp                    (s_axi_bresp),
  .s_axi_bvalid                   (s_axi_bvalid),
  .s_axi_bready                   (s_axi_bready),
// Slave Interface Read Address Ports
  .s_axi_arid                     (s_axi_arid),
  .s_axi_araddr                   (s_axi_araddr),
  .s_axi_arlen                    (s_axi_arlen),
  .s_axi_arsize                   (s_axi_arsize),
  .s_axi_arburst                  (s_axi_arburst),
  .s_axi_arlock                   (s_axi_arlock),
  .s_axi_arcache                  (s_axi_arcache),
  .s_axi_arprot                   (s_axi_arprot),
  .s_axi_arqos                    (4'h0),
  .s_axi_arvalid                  (s_axi_arvalid),
  .s_axi_arready                  (s_axi_arready),
// Slave Interface Read Data Ports
  .s_axi_rid                      (s_axi_rid),
  .s_axi_rdata                    (s_axi_rdata),
  .s_axi_rresp                    (s_axi_rresp),
  .s_axi_rlast                    (s_axi_rlast),
  .s_axi_rvalid                   (s_axi_rvalid),
  .s_axi_rready                   (s_axi_rready),
// System Clock Ports
  .sys_clk_i                      (sys_clk_i),
// Reference Clock Ports
  .clk_ref_i                      (clk_ref_i),
  .device_temp                    (),
  .sys_rst                        (mem_rstn)
);


endmodule
