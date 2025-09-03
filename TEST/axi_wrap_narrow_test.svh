/////////////////////////////////////////////////////
//
//  // HEADER //
//
//  FILE NAME = axi_base_test.svh
//  ENGINEER  = Muskan
//  VERSION   = 1.0 
//  DESCRIPTION = contains all macro 
//
/////////////////////////////////////////////////////

`ifndef AXI_WRAP_NARROW_TEST
`define AXI_WRAP_NARROW_TEST

class axi_wrap_narrow_vseqs extends axi_base_virtual_seqs;

  `uvm_object_utils(axi_wrap_narrow_vseqs)
   
   axi_wrap_narrow_seqs mseqs_h;
   axi_base_sseqs #(32,32) sseqs_h;
  
   function new(string name = "axi_base_test");
      super.new(name);

      mseqs_h = axi_wrap_narrow_seqs::type_id::create("mseqs_h"); 
      sseqs_h = axi_base_sseqs #(32,32)::type_id::create("sseqs_h"); 

   endfunction

   task body();

     fork 
     `uvm_do_on(mseqs_h, p_sequencer.mseqr_h)
     `uvm_do_on(sseqs_h, p_sequencer.sseqr_h)
     join_any

   endtask 
  
endclass 

////////////////////////////// TEST //////////////////////////

class axi_wrap_narrow_test extends axi_base_test;

  `uvm_component_utils(axi_wrap_narrow_test)
  
  axi_wrap_narrow_vseqs vseqs_h;
   
   function new(string name = "axi_base_test", uvm_component parent = null);
      super.new(name,parent);
      vseqs_h = axi_wrap_narrow_vseqs::type_id::create("vseqs_h"); 
   endfunction

  task run_phase (uvm_phase phase);
    phase.raise_objection(this, "RAISE AT axi_wrap_narrow_test ");

    vseqs_h.start(env_h.vseqr_h);
    
    phase.drop_objection(this, "DROP AT axi_wrap_narrow_test ");
  endtask

endclass

`endif
