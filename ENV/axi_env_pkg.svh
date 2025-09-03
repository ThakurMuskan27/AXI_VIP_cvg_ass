/////////////////////////////////////////////////////
//
//  // HEADER //
//
//  FILE NAME = axi_env_pkg.svh
//  ENGINEER  = Muskan
//  VERSION   = 1.0 
//  DESCRIPTION = contains all macro 
//
/////////////////////////////////////////////////////

`ifndef AXI_ENV_PKG
`define AXI_ENV_PKG

package axi_env_pkg;

   int s_count;
   int f_count;

  `include "uvm_macros.svh"
   import uvm_pkg::*;

    import axi_mpkg::*;
    import axi_spkg::*;
   
   `include "axi_virtual_seqr.svh"
   `include "axi_base_virtual_seqs.svh"

   `include "axi_env_cfg.svh"
   `include "axi_cvg.svh"
   `include "axi_ref_model.svh"
   `include "axi_scrbrd.svh"
   `include "axi_muvc.svh"
   `include "axi_suvc.svh"
   `include "axi_env.svh"
   
endpackage 

`endif


