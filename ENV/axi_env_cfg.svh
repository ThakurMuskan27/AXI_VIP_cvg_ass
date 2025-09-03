/////////////////////////////////////////////////////
//
//  // HEADER //
//
//  FILE NAME = axi_env_cfg.svh
//  ENGINEER  = Muskan
//  VERSION   = 1.0 
//  DESCRIPTION = contains all macro 
//
/////////////////////////////////////////////////////

`ifndef AXI_ENV_CFG
`define AXI_ENV_CFG

class axi_env_cfg extends uvm_object;

  uvm_active_passive_enum env_mis_active;
  uvm_active_passive_enum env_sis_active;
  
  bit has_master = 1;
  bit has_slave = 1;
  
  int no_of_master = 1;
  int no_of_slave = 1;

  bit m_has_wid; 
  bit s_has_wid; 

   `uvm_object_utils_begin(axi_env_cfg)
    `uvm_field_enum (uvm_active_passive_enum, env_mis_active, UVM_ALL_ON )
    `uvm_field_enum (uvm_active_passive_enum, env_sis_active, UVM_ALL_ON )
    `uvm_field_int (no_of_master, UVM_ALL_ON )  
    `uvm_field_int (no_of_slave, UVM_ALL_ON )  
    `uvm_field_int (has_master, UVM_ALL_ON )  
    `uvm_field_int (has_slave, UVM_ALL_ON ) 
    `uvm_field_int (m_has_wid, UVM_ALL_ON)
    `uvm_field_int (s_has_wid, UVM_ALL_ON)
   `uvm_object_utils_end

   function new (string name = "axi_env_cfg");
      super.new(name);
   endfunction

endclass 

`endif


