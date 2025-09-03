/////////////////////////////////////////////////////
//
//  // HEADER //
//
//  FILE NAME = axi_muvc.svh
//  ENGINEER  = Muskan
//  VERSION   = 1.0 
//  DESCRIPTION = contains all macro 
//
/////////////////////////////////////////////////////

`ifndef AXI_MUVC
`define AXI_MUVC

class axi_muvc extends uvm_component;

   `uvm_component_utils(axi_muvc)

  axi_magent #(32, 32) magent_h32[];
 // axi_magent #(64, 64) magent_h64[];
  axi_magt_cfg mcfg_h32[]; 
  axi_magt_cfg mcfg_h64[]; 
 
  axi_env_cfg env_cfg;

   function new (string name = "axi_muvc", uvm_component parent = null);
      super.new(name,parent);
   endfunction
   
   function void build_phase(uvm_phase phase);
     
     if(!uvm_config_db #(axi_env_cfg)::get(this,"", "env_cfg", env_cfg))
       `uvm_fatal(get_name()," Env config failed to get in uvc!!!")
       
       magent_h32 = new[env_cfg.no_of_master];   
    //   magent_h64 = new[env_cfg.no_of_master];   
       
       mcfg_h32 = new[env_cfg.no_of_master];   
   //    mcfg_h64 = new[env_cfg.no_of_master];   
     
     if ( env_cfg.has_master == 1 ) begin
       foreach(magent_h32[i]) begin
         magent_h32[i] = axi_magent #(32, 32) ::type_id::create($sformatf("magent_h32[%0d]",i),this);
         mcfg_h32[i] = axi_magt_cfg::type_id::create($sformatf("mcfg_h32[%0d]",i),this);
         magent_h32[i].mcfg_h = mcfg_h32[i];
       end
       end
 //    if ( env_cfg.has_master == 1 ) begin
 //      foreach(magent_h64[i]) begin
 //        magent_h64[i] = axi_magent #(64, 64) ::type_id::create($sformatf("magent_h64[%0d]",i),this);
 //        mcfg_h64[i] = axi_magt_cfg::type_id::create($sformatf("mcfg_h64[%0d]",i),this);
 //        magent_h64[i].mcfg_h = mcfg_h64[i];
 //    end 
 //    end
   
       
   endfunction
   
endclass 

`endif

