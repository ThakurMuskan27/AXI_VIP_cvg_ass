/////////////////////////////////////////////////////
//
//  // HEADER //
//
//  FILE NAME = axi_test_pkg.svh
//  ENGINEER  = Muskan
//  VERSION   = 1.0 
//  DESCRIPTION = contains all macro 
//
/////////////////////////////////////////////////////

`ifndef AXI_TEST_PKG
`define AXI_TEST_PKG

package axi_test_pkg;

 `include "uvm_macros.svh"
  import uvm_pkg::*;

    import axi_mpkg::*;
    import axi_spkg::*;
    import axi_env_pkg::*;

   `include "axi_base_test.svh"
   
   `include "axi_incr_allign_narrow_seqs.svh"
   `include "axi_incr_allign_narrow_test.svh"
   
   `include "axi_wrap_narrow_seqs.svh"
   `include "axi_wrap_narrow_test.svh"
endpackage 

`endif


