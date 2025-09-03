/////////////////////////////////////////////////////
//
//  // HEADER //
//
//  FILE NAME = axi_spkg.svh
//  ENGINEER  = Muskan
//  VERSION   = 1.0 
//  DESCRIPTION = contains all macro 
//
/////////////////////////////////////////////////////

`ifndef AXI_SPKG
`define AXI_SPKG
 
   `include "axi_sinf.svh"

package axi_spkg; 

 `include "uvm_macros.svh"
  import uvm_pkg::*;
   
   uvm_event reset_sev;

   `include "axi_sagt_cfg.svh"
   `include "axi_s_defines.svh"
   `include "axi_sseq_item.svh"
   `include "axi_sseqr.svh"
   `include "axi_sdrv.svh"
   `include "axi_smon.svh"
   `include "axi_sagent.svh"
   
   `include "axi_base_sseqs.svh"
endpackage 

`endif

