/////////////////////////////////////////////////////
//
//  // HEADER //
//
//  FILE NAME = axi_sagent.svh
//  ENGINEER  = Muskan
//  VERSION   = 1.0 
//  DESCRIPTION = contains all macro 
//
/////////////////////////////////////////////////////

`ifndef AXI_SAGENT
`define AXI_SAGENT

class axi_sagent #(int DATA_WIDTH = 16 , ADD_WIDTH = 8) extends uvm_agent;

   `uvm_component_param_utils(axi_sagent #(DATA_WIDTH, ADD_WIDTH))

   axi_sseqr #(DATA_WIDTH, ADD_WIDTH) sseqr_h; 
   axi_sdrv #(DATA_WIDTH, ADD_WIDTH) sdrv_h; 
   axi_smon #(DATA_WIDTH, ADD_WIDTH) smon_h; 
   axi_sagt_cfg scfg_h; 
  
  virtual axi_sinf #(32,32) svif;
  
   function new (string name = "axi_sagent", uvm_component parent = null);
      super.new(name,parent);
   endfunction
   
   function void build_phase(uvm_phase phase);
     
     if(!uvm_config_db #(axi_sagt_cfg)::get(this,"","scfg_h", scfg_h))
       `uvm_fatal(get_name()," Slave config failed to get !!!")
       
       if(scfg_h.sagt_is_active == UVM_ACTIVE) begin
       sseqr_h = axi_sseqr #(DATA_WIDTH, ADD_WIDTH) ::type_id::create("sseqr_h",this);
       sdrv_h = axi_sdrv #(DATA_WIDTH, ADD_WIDTH) ::type_id::create("sdrv_h",this);
       end 
       smon_h = axi_smon #(DATA_WIDTH, ADD_WIDTH) ::type_id::create("smon_h",this);
     
     if(!uvm_config_db #(virtual axi_sinf#(DATA_WIDTH, ADD_WIDTH))::get(this,"", "svif", svif))
       `uvm_fatal(get_name(),"Slave Virtual interface failed of get !!!")
   endfunction

   function void connect_phase(uvm_phase phase);
      sdrv_h.seq_item_port.connect(sseqr_h.seq_item_export);
     
     if(scfg_h.sagt_is_active == UVM_ACTIVE) begin
       sdrv_h.svif = svif; end 
     smon_h.svif = svif;
     
   endfunction
endclass 

`endif

