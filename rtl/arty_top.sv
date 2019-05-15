module arty_top (
  output [3:0]  led,
  input         sys_clk,
  input         sys_rstn
);

  logic         clk_i;     // 166MHz
  logic         clk;       // gated clock
  logic         rstn;
  logic         locked;

  logic         runtest;
  logic         sel;
  logic         tck;
  logic         tms;

  logic [31:0]  r_count;

  //-------------------------------------------------------------------------------
  // MISC
  //-------------------------------------------------------------------------------
  assign led[0] = locked;
  assign led[3:1] = r_count[23:21];

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
      rstn <= 0;
    else if (r_locked[7])
      rstn <= 1;
    else
      rstn <= 0;

  //-------------------------------------------------------------------------------
  // MMCM
  //-------------------------------------------------------------------------------
  mmcm u_mmcm(
    .clk_in1  (sys_clk),
    .resetn   (sys_rstn),
    .clk_out1 (clk_i),     // 166MHz
    .clk_out2 (),          // 200MHz
    .clk_out3 (),          // 25MHz for ether clock
    .locked   (locked)
  );

  // Enable/disalbe main clock by JTAG
  BUFGCE u_bufg(
    .I   (clk_i),
    .CE  (sel && runtest && !tms),
    .O   (clk)
  );

  //----------------------------------------------------------
  // JTAG I/F
  //----------------------------------------------------------

  BSCANE2 #(.JTAG_CHAIN(4))  // Value for USER command.
  u_bscan (
    .CAPTURE(),   // o: CAPTURE output from TAP controller.
    .DRCK(),      // o: Gated TCK output. When SEL is asserted, DRCK toggles when CAPTURE or SHIFT are asserted.
    .RESET(),     // o: Reset output for TAP controller.
    .RUNTEST(runtest), // o: Output asserted when TAP controller is in Run Test/Idle state.
    .SEL(sel),    // o: USER instruction active output.
    .SHIFT(),     // o: SHIFT output from TAP controller.
    .TCK(tck),    // o: Test Clock output. Fabric connection to TAP Clock pin.
    .TDI(),       // o: Test Data Input (TDI) output from TAP controller.
    .TMS(tms),    // o: Test Mode Select output. Fabric connection to TAP.
    .UPDATE(),    // o: UPDATE output from TAP controller
    .TDO(1'b0)    // i: Test Data Output (TDO) input for USER function.
  );

  //----------------------------------------------------------
  // DUT
  //----------------------------------------------------------

  always_ff @(posedge clk or negedge rstn) begin
    if (!rstn)
      r_count <= '0;
    else
      r_count <= r_count + 1;
  end

endmodule
