interface axi4lite_if ();
  parameter DATAW = 32;
  parameter BEN   = DATAW / 8;

  wire [31:0]        awaddr ;
  wire               awvalid;
  wire               awready;
  wire [DATAW-1:0]   wdata  ;
  wire [BEN-1:0]     wstrb  ;
  wire               wvalid ;
  wire               wready ;
  wire [1:0]         bresp  ;
  wire               bvalid ;
  wire               bready ;
  wire [31:0]        araddr ;
  wire               arvalid;
  wire               arready;
  wire [DATAW-1:0]   rdata  ;
  wire [1:0]         rresp  ;
  wire               rvalid ;
  wire               rready ;

  modport master (
    input  awready, wready, bresp, bvalid, arready, rdata, rresp, rvalid,
    output awaddr, awvalid, wdata, wstrb, wvalid, bready, araddr, arvalid, rready
  );

  modport slave (
    input  awaddr, awvalid, wdata, wstrb, wvalid, bready, araddr, arvalid, rready,
    output awready, wready, bresp, bvalid, arready, rdata, rresp, rvalid
  );

endinterface
