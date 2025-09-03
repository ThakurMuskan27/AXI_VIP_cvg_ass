module axi_top ();

  `include "uvm_macros.svh"
  import uvm_pkg::*;
  import axi_test_pkg::*;

 bit aclk;
 bit areset;

  axi_minf #(32,32) minf_32(aclk,areset);
  axi_sinf #(32,32) sinf_32(aclk,areset);

  axi_minf #(64,64) minf_64(aclk,areset);
  axi_sinf #(64,64) sinf_64(aclk,areset);

  always begin
    #5 aclk = ~aclk;
  end
  // WRITE ADDRESS CHANNEL
  assign sinf_32.awaddr   = minf_32.awaddr;
  assign sinf_32.awid     = minf_32.awid;
  assign sinf_32.awlen    = minf_32.awlen;
  assign sinf_32.awsize   = minf_32.awsize;
  assign sinf_32.awburst  = minf_32.awburst;
  assign sinf_32.awvalid  = minf_32.awvalid;
  assign minf_32.awready  = sinf_32.awready;

  // WRITE DATA CHANNEL
  assign sinf_32.wdata     = minf_32.wdata;
  assign sinf_32.wid       = minf_32.wid;
  assign sinf_32.wstrb     = minf_32.wstrb;
  assign sinf_32.wlast     = minf_32.wlast;
  assign sinf_32.wvalid    = minf_32.wvalid;
  assign minf_32.wready    = sinf_32.wready;

  // WRITE RESPONSE CHANNEL
  assign minf_32.bid       = sinf_32.bid;
  assign minf_32.bresp     = sinf_32.bresp;
  assign minf_32.bvalid    = sinf_32.bvalid;
  assign sinf_32.bready    = minf_32.bready;

  // READ ADDRESS CHANNEL
  assign sinf_32.araddr    = minf_32.araddr;
  assign sinf_32.arid      = minf_32.arid;
  assign sinf_32.arlen     = minf_32.arlen;
  assign sinf_32.arsize    = minf_32.arsize;
  assign sinf_32.arburst   = minf_32.arburst;
  assign sinf_32.arvalid   = minf_32.arvalid;
  assign minf_32.arready   = sinf_32.arready;

  // READ DATA CHANNEL
  assign minf_32.rlast     = sinf_32.rlast;
  assign minf_32.rvalid    = sinf_32.rvalid;
  assign minf_32.rid       = sinf_32.rid;
  assign minf_32.rresp     = sinf_32.rresp;
  assign minf_32.rdata     = sinf_32.rdata;
  assign sinf_32.rready    = minf_32.rready;  

  axi_assertion #(32,32,8) axi_ass_inst ( aclk, areset, minf_32) ; 
  
  //bind axi_minf axi_assertion #(32,32,8) axi_ass_inst ( aclk, areset, minf_32)
  /*minf_32.awvalid, minf_32.awready, minf_32.arvalid, minf_32.arready, minf_32.wvalid, minf_32.wready, minf_32.wlast, minf_32.rvalid, minf_32.rready, minf_32.bvalid, minf_32.bready, minf_32.awaddr, minf_32.awid, minf_32.awlen, minf_32.awsize, minf_32.araddr, minf_32.arid, minf_32.arlen, minf_32.arsize, minf_32.wid, minf_32.wdata, minf_32.wstrb, minf_32.bid, minf_32.bresp, minf_32.rid, minf_32.rresp, minf_32.rdata ); */


  initial begin
     uvm_config_db #(virtual axi_minf #(32,32))::set(null, "uvm_test_top.env_h.muvc_h.magent_h32*", "mvif", minf_32);
     uvm_config_db #(virtual axi_sinf #(32,32))::set(null, "*sagent_h*", "svif", sinf_32);    
     
     uvm_config_db #(virtual axi_minf #(64,64))::set(null, "*magent_h64*", "mvif", minf_64);
  //   uvm_config_db #(virtual axi_sinf #(64,64))::set(null, "uvm_test_top.env_h.suvc_h.sagent_h*", "svif", sinf_64);    
     run_test("axi_incr_allign_narrow_test");
   end
  
/*  initial begin
    $dumpfile("dump.vcd");
    $dumpvars;
  end
*/
  
endmodule

