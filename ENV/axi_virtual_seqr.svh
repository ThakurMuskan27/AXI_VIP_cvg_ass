/////////////////////////////////////////////////////
//
//  // HEADER //
//
//  FILE NAME = axi_virtual_seqr.svh
//  ENGINEER  = Muskan
//  VERSION   = 1.0 
//  DESCRIPTION = contains all macro 
//
/////////////////////////////////////////////////////

`ifndef AXI_VIRTUAL_SEQR
`define AXI_VIRTUAL_SEQR

class axi_virtual_seqr extends uvm_sequencer #(uvm_sequence_item);

  `uvm_component_utils(axi_virtual_seqr)

   axi_sseqr #(32,32) sseqr_h;
   axi_mseqr #(32,32) mseqr_h;
  
   function new(string name = "axi_virtual_seqr",uvm_component parent = null);
      super.new(name,parent);
   endfunction

 
endclass 

`endif

