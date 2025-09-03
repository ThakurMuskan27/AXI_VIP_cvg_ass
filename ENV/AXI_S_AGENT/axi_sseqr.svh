/////////////////////////////////////////////////////
//
//  // HEADER //
//
//  FILE NAME = axi_sseqr.svh
//  ENGINEER  = Muskan
//  VERSION   = 1.0 
//  DESCRIPTION = contains all macro 
//
/////////////////////////////////////////////////////

`ifndef AXI_SSEQR
`define AXI_SSEQR

class axi_sseqr #(int DATA_WIDTH = 16 , ADD_WIDTH = 8 ) extends uvm_sequencer #(axi_sseq_item #(DATA_WIDTH,ADD_WIDTH));

   `uvm_component_param_utils(axi_sseqr #(DATA_WIDTH, ADD_WIDTH))

   uvm_tlm_analysis_fifo #(axi_sseq_item #(DATA_WIDTH, ADD_WIDTH)) anl_sseqr_fifo;

   function new (string name = "axi_sseqr", uvm_component parent = null);
      super.new(name,parent);
   endfunction

   function void build_phase (uvm_phase phase);
     super.build_phase(phase);
     anl_sseqr_fifo = new("anl_sseqr_fifo",this); 
   endfunction

   
endclass 

`endif

