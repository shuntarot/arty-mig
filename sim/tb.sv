module tb;
   bit          clk = 0;
   bit          rstn = 0;
   bit   [3:0]  led;

   initial begin
      forever
    #5ns clk = ~clk; // 100MHz
   end

   initial begin
      rstn = 0;
      #10ns;
      rstn = 1;

      $display("Test start");

      #1us;
      $stop(0);
   end

   glbl glbl();

   arty_top dut (
     .sys_clk      (clk),
     .sys_rstn     (rstn),
     .uart_rx      (1'b0),
     .uart_tx      (),
     .led          (led)
   );

endmodule
