module tb;
   bit          clk = 0;
   bit          rstn = 0;
   bit   [3:0]  led;

   wire         ddr3_reset_n;
   wire  [15:0] ddr3_dq;
   wire  [1:0]  ddr3_dqs_p;
   wire  [1:0]  ddr3_dqs_n;
   wire  [13:0] ddr3_addr;
   wire  [2:0]  ddr3_ba;
   wire         ddr3_ras_n;
   wire         ddr3_cas_n;
   wire         ddr3_we_n;
   wire  [0:0]  ddr3_ck_p;
   wire  [0:0]  ddr3_ck_n;
   wire  [0:0]  ddr3_cke;
   wire  [0:0] 	ddr3_cs_n;
   wire  [1:0]  ddr3_dm;
   wire  [0:0]  ddr3_odt;

   
   initial begin
      forever
	#5ns clk = ~clk; // 100MHz
   end

   initial begin
      rstn = 0;
      #10ns;
      rstn = 1;

      wait(dut.init_calib_complete);
      $display("Calibration Done");

      #1us;
      $stop(0);
   end

   glbl glbl();
   
   arty_top dut (
     .ddr3_dq      (ddr3_dq),
     .ddr3_dqs_n   (ddr3_dqs_n),
     .ddr3_dqs_p   (ddr3_dqs_p),
     .ddr3_addr	   (ddr3_addr),
     .ddr3_ba	   (ddr3_ba),
     .ddr3_ras_n   (ddr3_ras_n),
     .ddr3_cas_n   (ddr3_cas_n),
     .ddr3_we_n	   (ddr3_we_n),
     .ddr3_reset_n (ddr3_reset_n),
     .ddr3_ck_p	   (ddr3_ck_p),
     .ddr3_ck_n	   (ddr3_ck_n),
     .ddr3_cke	   (ddr3_cke),
     .ddr3_cs_n	   (ddr3_cs_n),
     .ddr3_dm      (ddr3_dm),
     .ddr3_odt     (ddr3_odt),
     .sys_clk      (clk),
     .sys_rstn     (rstn),
     .led          (led)
   );


   ddr3_model u_comp_ddr3
   (
     .rst_n     (ddr3_reset_n),
     .ck        (ddr3_ck_p),
     .ck_n      (ddr3_ck_n),
     .cke       (ddr3_cke),
     .cs_n      (ddr3_cs_n),
     .ras_n     (ddr3_ras_n),
     .cas_n     (ddr3_cas_n),
     .we_n      (ddr3_we_n),
     .dm_tdqs   (ddr3_dm),
     .ba        (ddr3_ba),
     .addr      (ddr3_addr),
     .dq        (ddr3_dq),
     .dqs       (ddr3_dqs_p),
     .dqs_n     (ddr3_dqs_n),
     .tdqs_n    (),
     .odt       (ddr3_odt)
    );

endmodule
