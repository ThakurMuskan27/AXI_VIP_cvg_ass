/////////////////////////////////////////////////////
//
//  // HEADER //
//
//  FILE NAME = axi_env.svh
//  ENGINEER  = Muskan
//  VERSION   = 1.0 
//  DESCRIPTION = contains all macro 
//
/////////////////////////////////////////////////////

`ifndef AXI_ENV
`define AXI_ENV

class axi_env extends uvm_env;

  `uvm_component_utils(axi_env)
  
  axi_env_cfg env_cfg;

   axi_suvc suvc_h;
   axi_muvc muvc_h;
  
  axi_magt_cfg mcfg_h; 
  axi_sagt_cfg scfg_h;

  axi_ref_model ref_h;
  axi_scrbrd    sb_h;

  axi_virtual_seqr vseqr_h;  

 uvm_tlm_fifo #(axi_sseq_item #(32, 32)) ref_2_sb_sfifo;
 uvm_tlm_fifo #(axi_mseq_item #(32, 32)) ref_2_sb_mfifo;
 
 function new (string name = "axi_env", uvm_component parent = null);
      super.new(name,parent);
   endfunction

   function void build_phase(uvm_phase phase);
     super.build_phase(phase);
     
     if(!uvm_config_db #(axi_env_cfg)::get(this,"", "env_cfg", env_cfg))
       `uvm_fatal(get_name()," Env config failed to get !!!")
       
      suvc_h = axi_suvc ::type_id::create("suvc_h",this);
      muvc_h = axi_muvc ::type_id::create("muvc_h",this);
     
      mcfg_h = axi_magt_cfg::type_id::create("mcfg_h");
      scfg_h = axi_sagt_cfg::type_id::create("scfg_h");
     
     mcfg_h.magt_is_active = env_cfg.env_mis_active;
     mcfg_h.has_wid = env_cfg.m_has_wid;
     scfg_h.sagt_is_active = env_cfg.env_sis_active;    
     scfg_h.has_wid = env_cfg.s_has_wid;    
     
     uvm_config_db #(axi_magt_cfg)::set(this,"*", "mcfg_h", mcfg_h);
     uvm_config_db #(axi_sagt_cfg)::set(this,"*", "scfg_h", scfg_h);
     
     ref_2_sb_mfifo = new("ref_2_sb_mfifo",this);
     ref_2_sb_sfifo = new("ref_2_sb_sfifo",this);
     
     ref_h = axi_ref_model::type_id::create("ref_h",this);
     sb_h = axi_scrbrd::type_id::create("sb_h",this);
     
     vseqr_h = axi_virtual_seqr::type_id::create("vseqr_h",this);
   endfunction


   function void connect_phase(uvm_phase phase);
     super.connect_phase(phase);

    //// TLM fifo put port connection with ref
    ref_h.m_put_port.connect(ref_2_sb_mfifo.put_export);
    ref_h.s_put_port.connect(ref_2_sb_sfifo.put_export);

    //// TLM fifo get port connection with sb
    sb_h.m_get_port.connect(ref_2_sb_mfifo.get_export);
    sb_h.s_get_port.connect(ref_2_sb_sfifo.get_export);

    //// Analysis fifo connection with ref     
     muvc_h.magent_h32[0].mmon_h.anl_mport.connect(ref_h.anl_ref_mfifo.analysis_export);
     suvc_h.sagent_h[0].smon_h.anl_sport_ref_sb.connect(ref_h.anl_ref_sfifo.analysis_export);
    
     /// Analysis fifo connection with slave sequencer
     suvc_h.sagent_h[0].smon_h.anl_sport_sseqr.connect(suvc_h.sagent_h[0].sseqr_h.anl_sseqr_fifo.analysis_export);

     //// Analysis fifo connection with scoreboard     
     muvc_h.magent_h32[0].mmon_h.anl_mport.connect(sb_h.anl_sb_mfifo.analysis_export);
     suvc_h.sagent_h[0].smon_h.anl_sport_ref_sb.connect(sb_h.anl_sb_sfifo.analysis_export);

     //// Virtual sequencer connection 
     vseqr_h.mseqr_h = muvc_h.magent_h32[0].mseqr_h;
     vseqr_h.sseqr_h = suvc_h.sagent_h[0].sseqr_h;

     endfunction

endclass 

`endif


