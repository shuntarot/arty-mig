//------------------------------------------------------------------------------
//
// FIFO
//
//------------------------------------------------------------------------------

module cmn_fifo #(
  parameter DW = 32,
  parameter AW = 8
)(
  input  logic          clk,
  input  logic          rstn,
  input  logic          we,
  input  logic [DW-1:0] wdata,
  input  logic          re,
  output logic [DW-1:0] rdata,
  output logic          full,
  output logic          empty
);

localparam WORD = (1 << AW);
localparam PW = (AW == 0) ? 1 : AW;

logic [PW-1:0] r_wp;
logic [PW-1:0] r_rp;
logic [AW:0]   r_wc;

always_ff @(posedge clk, negedge rstn)
  if (!rstn)
     r_wp <= 0;
  else if (we)
     r_wp <= r_wp + 1;

always_ff @(posedge clk, negedge rstn)
  if (!rstn)
     r_rp <= 0;
  else if (re)
     r_rp <= r_rp + 1;

always_ff @(posedge clk, negedge rstn)
  if (!rstn)
     r_wc <= 0;
  else if (we || re) begin
     case ({we, re})
       2'b01: r_wc <= r_wc - 1;
       2'b10: r_wc <= r_wc + 1;
     endcase
  end

assign empty = (r_wc == 0);
assign full  = (r_wc >= WORD);

cmn_tp #(.DW(DW), .AW(AW)) u_mem (
  .clk    (clk),
  .rstn   (rstn),
  .mea    (we),
  .wea    (we),
  .adra   (r_wp),
  .da     (wdata),
  .meb    (re),
  .adrb   (r_rp),
  .qb     (rdata)
);

endmodule

//------------------------------------------------------------------------------
//
// Two-port RAM/FF
//
//------------------------------------------------------------------------------

module cmn_tp #(
  parameter  DW = 32,
  parameter  AW = 8,
  parameter  USE_BUF = 0,
  localparam PW = (AW == 0) ? 1 : AW
)(
  input  logic          clk,
  input  logic          rstn,
  input  logic          mea,
  input  logic          wea,
  input  logic [PW-1:0] adra,
  input  logic [DW-1:0] da,
  input  logic          meb,
  input  logic [PW-1:0] adrb,
  output logic [DW-1:0] qb
);

localparam WORD = (1 << AW);

logic [PW-1:0] w_adra;
logic [PW-1:0] w_adrb;
logic [DW-1:0] r_mem[0:WORD-1];
logic [DW-1:0] r_buf;

assign w_adra = (AW == 0) ? 0 : adra;
assign w_adrb = (AW == 0) ? 0 : adrb;
   
always_ff @(posedge clk) begin
  if (mea && wea)
    r_mem[w_adra] <= da;
end

generate
if (USE_BUF) begin : use_buf
   always_ff @(posedge clk) begin
     if (meb)
       r_buf <= r_mem[w_adrb];
   end
end
else begin : no_buf
   assign r_buf = r_mem[w_adrb];
end
endgenerate

assign qb = r_buf;

endmodule
