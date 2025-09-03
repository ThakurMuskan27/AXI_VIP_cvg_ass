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

`ifndef AXI_BASE_TEST
`define AXI_BASE_TEST

class axi_base_test extends uvm_test;

  `uvm_component_utils(axi_base_test)
   
   axi_env env_h;
   axi_env_cfg  env_cfg;  
   axi_base_mseqs #(32,32) mseqs_h;
   axi_base_sseqs #(32,32) sseqs_h;
  
   function new(string name = "axi_base_test", uvm_component parent);
      super.new(name,parent);
   endfunction

   function void build_phase(uvm_phase phase);
     super.build_phase(phase);
     env_h = axi_env ::type_id::create("env_h",this);
     
     
     env_cfg = axi_env_cfg::type_id::create("env_cfg");
     
     env_cfg.env_mis_active = UVM_ACTIVE;
     env_cfg.env_sis_active = UVM_ACTIVE;
     env_cfg.has_master = 1;
     env_cfg.has_slave = 1;   
     env_cfg.no_of_slave = 1;  
     env_cfg.no_of_master = 1;
     env_cfg.m_has_wid = 1;
     env_cfg.s_has_wid = 1;
     
     uvm_config_db #(axi_env_cfg)::set(this,"*","env_cfg",env_cfg);
      // uvm_top.print_topology();
   endfunction

   function void connect_phase(uvm_phase phase);
      // uvm_top.print_topology();
   endfunction

   function void end_of_elaboration_phase(uvm_phase phase);
     //  uvm_top.print_topology();
   endfunction
  
  virtual task run_phase (uvm_phase phase);
    //super.run_phase(phase);
    mseqs_h = axi_base_mseqs #(32,32)::type_id::create("mseqs_h");
    sseqs_h = axi_base_sseqs #(32,32)::type_id::create("sseqs_h");
    
    //phase.phase_done.set_drain_time(this,500);
    
    $display(" RAISE at test " );
    phase.raise_objection(this, "RAISE AT TEST ");
    fork
    mseqs_h.start(env_h.muvc_h.magent_h32[0].mseqr_h);
    sseqs_h.start(env_h.suvc_h.sagent_h[0].sseqr_h);
    join_any
    phase.drop_objection(this, " DROP AT TEST ");
    $display(" DROP at test " );
  
  endtask 
 
endclass 

`endif

