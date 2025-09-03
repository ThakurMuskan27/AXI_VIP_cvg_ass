/////////////////////////////////////////////////////
//
//  // HEADER //
//
//  FILE NAME = axi_suvc.svh
//  ENGINEER  = Muskan
//  VERSION   = 1.0 
//  DESCRIPTION = contains all macro 
//
/////////////////////////////////////////////////////

`ifndef AXI_SUVC
`define AXI_SUVC

class axi_suvc extends uvm_component;

   `uvm_component_utils(axi_suvc)

  axi_sagent #(32, 32) sagent_h[];
  axi_sagt_cfg scfg_h[];

  axi_env_cfg env_cfg;  

   function new (string name = "axi_suvc", uvm_component parent = null);
      super.new(name,parent);
   endfunction

   function void build_phase(uvm_phase phase);
     
     if(!uvm_config_db #(axi_env_cfg)::get(this,"", "env_cfg", env_cfg))
       `uvm_fatal(get_name()," Env config failed to get in uvc!!!")
       
       sagent_h = new[env_cfg.no_of_slave];   
       scfg_h = new[env_cfg.no_of_slave];   
     
     if ( env_cfg.has_slave == 1 ) begin
       foreach(sagent_h[i]) begin
         sagent_h[i] = axi_sagent #(32, 32) ::type_id::create($sformatf("sagent_h[%0d]",i),this);
         scfg_h[i] = axi_sagt_cfg::type_id::create($sformatf("scfg_h[%0d]",i),this);
         sagent_h[i].scfg_h = scfg_h[i];
       end
     end
   endfunction

   
endclass 

`endif

