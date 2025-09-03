/////////////////////////////////////////////////////
//
//  // HEADER //
//
//  FILE NAME = axi_sagt_cfg.svh
//  ENGINEER  = Muskan
//  VERSION   = 1.0 
//  DESCRIPTION = contains all macro 
//
/////////////////////////////////////////////////////

`ifndef AXI_SAGT_CFG
`define AXI_SAGT_CFG

class axi_sagt_cfg extends uvm_object;

  uvm_active_passive_enum sagt_is_active;
   bit has_wid; 

   `uvm_object_utils_begin(axi_sagt_cfg)
      `uvm_field_enum (uvm_active_passive_enum, sagt_is_active, UVM_ALL_ON )
      `uvm_field_int (has_wid, UVM_ALL_ON )
   `uvm_object_utils_end

   function new (string name = "axi_sagt_cfg");
      super.new(name);
   endfunction

   
endclass 

`endif


