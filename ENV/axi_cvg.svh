/////////////////////////////////////////////////////
//
//  // HEADER //
//
//  FILE NAME = axi_coverage.svh
//  ENGINEER  = Muskan
//  VERSION   = 1.0 
//  DESCRIPTION =  
//
/////////////////////////////////////////////////////

`ifndef AXI_CVG
`define AXI_CVG

class axi_coverage extends uvm_object;  

   `uvm_object_utils(axi_coverage)

   axi_sseq_item #(32, 32) sseq_item;

   covergroup axi_cvg with function sample ( int wdata_index, int rdata_index );

   awaddr_cp : coverpoint sseq_item.awaddr[0] {
      bins l_rng_wadd_cb = {[0:20]};
      bins md_rng_wa_cb = {[200:120]};
      bins h_rng_wa_cb = {[32'h0FFF_FFFF:32'hFFFF_FFFF]};
    }
    
    araddr_cp : coverpoint sseq_item.araddr[0] {
      bins l_rng_radd_cb = {[0:20]};
      bins md_rng_radd_cb = {[200:120]};
      bins h_rng_radd_cb = {[32'h0FFF_FFFF:32'hFFFF_FFFF]};
    }

    wdata_cp : coverpoint sseq_item.wdata[wdata_index] {
        bins l_rng_wdata_cb = {[32'h0000_0000 : 32'h0000_000F]};
        bins md_rng_wdata_cb = {[32'h0000_FF00 : 32'h00FF_0000]};
        bins h_rng_wdata_cb = {[32'h0000_FFFF : 32'hFFFF_FFFF]};
    }
    
    wstrb_cp : coverpoint sseq_item.wstrb[wdata_index] {
        bins strb_cb[] = { 4'b0000, 4'b1111, 4'b1000, 4'b0100, 4'b0010, 4'b0001, 4'b0011, 4'b1100, 4'b1110 };
    } 
    
    rdata_cp : coverpoint sseq_item.rdata[rdata_index] {
        bins l_rng_wdata_cb = {[32'h0000_0000 : 32'h0000_000F]};
        bins md_rng_wdata_cb = {[32'h0000_FF00 : 32'h00FF_0000]};
        bins h_rng_wdata_cb = {[32'h0000_FFFF : 32'hFFFF_FFFF]};
    }

    awburst_cp : coverpoint sseq_item.awburst {
        ignore_bins ign_reserved_cb = {2'b11};
    }

    awlen_cp : coverpoint sseq_item.awlen {
        bins for_wrap_cb[] = { 1,3,7,15 };
        bins l_rng_len_cb[] = { [0:10] };
        bins h_rng_len_cb[] = { [200:255] };
    }

    awsize_cp : coverpoint sseq_item.awsize {
        bins all_wsize[] = { [0:7] };
    }

   // wstrb_cp : coverpoint sseq_item.wstrb[wdata_index] {

    cross_burst_len_cp : cross awburst_cp,awlen_cp { 
        bins wrap_x_len_cb1 = binsof(awburst_cp) intersect {axi_spkg::WRAP} && binsof(awlen_cp) intersect { 1,3,7,15 };
        bins incr_x_len_cb1 = binsof(awburst_cp) intersect {axi_spkg::INCR} && binsof(awlen_cp) intersect { [0:10],[200:255] };
        illegal_bins wrap_x_len_illegal_cb = binsof(awburst_cp) intersect {axi_spkg::WRAP} && binsof(awlen_cp) intersect { [16:255] };
    }

    //cross_burst_len_cp : cross awsize_cp,awlen_cp {

    cross_addr_wdata : cross awaddr_cp, wdata_cp ;

    endgroup  
   
   function new (string name = "axi_cvg");
      super.new(name);
      axi_cvg = new();
   endfunction
 

endclass 

`endif

