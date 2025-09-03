/////////////////////////////////////////////////////
//
//  // HEADER //
//
//  FILE NAME = axi_base_virtual_seqs.svh
//  ENGINEER  = Muskan
//  VERSION   = 1.0 
//  DESCRIPTION = contains all macro 
//
/////////////////////////////////////////////////////

`ifndef AXI_BASE_VIRTUAL_SEQS
`define AXI_BASE_VIRTUAL_SEQS

class axi_base_virtual_seqs extends uvm_sequence #(uvm_sequence_item);

  `uvm_object_utils(axi_base_virtual_seqs)
  
  `uvm_declare_p_sequencer(axi_virtual_seqr)
   
   function new(string name = "axi_base_virtual_seqs");
      super.new(name);
   endfunction

 
endclass 

`endif

