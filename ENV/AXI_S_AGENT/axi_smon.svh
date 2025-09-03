/////////////////////////////////////////////////////
//
//  // HEADER //
//
//  FILE NAME = axi_smon.svh
//  ENGINEER  = Muskan
//  VERSION   = 1.0 
//  DESCRIPTION = contains all macro 
//
/////////////////////////////////////////////////////

`ifndef AXI_SMON
`define AXI_SMON

class axi_smon #(int DATA_WIDTH = 16 , ADD_WIDTH = 8) extends uvm_monitor;

   `uvm_component_param_utils(axi_smon #(DATA_WIDTH, ADD_WIDTH))
  
    virtual axi_sinf #(DATA_WIDTH, ADD_WIDTH) svif;

  uvm_analysis_port #(axi_sseq_item #(DATA_WIDTH,ADD_WIDTH) ) anl_sport_sseqr;
  uvm_analysis_port #(axi_sseq_item #(DATA_WIDTH,ADD_WIDTH) ) anl_sport_ref_sb;

  axi_sseq_item #(DATA_WIDTH,ADD_WIDTH) witem_arr[ int ];
  axi_sseq_item #(DATA_WIDTH,ADD_WIDTH) ritem_arr[ int ];
  
  bit[7:0] awid_que [$];  // When there is no wid
 
  axi_sagt_cfg scfg_h; 

   function new (string name = "axi_smon", uvm_component parent = null);
      super.new(name,parent);
   endfunction
   
   function void build_phase (uvm_phase phase);
     super.build_phase(phase);
     anl_sport_ref_sb = new("anl_sport_ref_sb",this);
     anl_sport_sseqr = new("anl_sport_seqr",this);

     if(!uvm_config_db #(axi_sagt_cfg)::get(this,"","scfg_h", scfg_h))
       `uvm_fatal(get_name()," SLave config failed to get in monitor!!!")
 
   endfunction

  task run_phase (uvm_phase phase);
    forever begin 
       monitor();
    end
  endtask 

  task monitor();
       fork
       get_write_address();
       get_read_address();
       if(scfg_h.has_wid == 1)
           get_write_data_with_wid();
       else get_write_data_without_wid();
       sample_write_response();
       sample_read_response();
       join
  endtask
  
  task get_write_address ( );

  forever begin 
      @( svif.SMON_MP.smon_cb ) begin

      if ( svif.SMON_MP.smon_cb.awvalid && svif.SMON_MP.smon_cb.awready )begin
       
       if( !witem_arr.exists(svif.SMON_MP.smon_cb.awid))
            witem_arr[svif.SMON_MP.smon_cb.awid] = new($sformatf(" witem_arr[%0d] ",svif.SMON_MP.smon_cb.awid));

      witem_arr[svif.SMON_MP.smon_cb.awid].awid    = svif.SMON_MP.smon_cb.awid; 
       if(scfg_h.has_wid == 0) awid_que.push_back( svif.SMON_MP.smon_cb.awid );
      witem_arr[svif.SMON_MP.smon_cb.awid].awaddr.push_back( svif.SMON_MP.smon_cb.awaddr );
      witem_arr[svif.SMON_MP.smon_cb.awid].awlen   = svif.SMON_MP.smon_cb.awlen; 
      witem_arr[svif.SMON_MP.smon_cb.awid].awsize  = svif.SMON_MP.smon_cb.awsize; 
      witem_arr[svif.SMON_MP.smon_cb.awid].awburst = svif.SMON_MP.smon_cb.awburst;

      if( witem_arr[svif.SMON_MP.smon_cb.awid].awid == witem_arr[svif.SMON_MP.smon_cb.awid].wid ) begin
         if ( witem_arr[svif.SMON_MP.smon_cb.awid].wdata.size() == ( witem_arr[svif.SMON_MP.smon_cb.awid].awlen + 1 ) ) begin
           witem_arr[svif.SMON_MP.smon_cb.awid].operation = WRITE;  
           anl_sport_sseqr.write( witem_arr[svif.SMON_MP.smon_cb.awid] );
           $display($time," *** Slave Monitor Write *** ");
          //witem_arr[svif.SMON_MP.smon_cb.awid].print();
        end
       end
      end
     end
    end
  endtask
   
  task get_read_address ( );

  forever begin
      @( svif.SMON_MP.smon_cb ) begin
      
      if( svif.SMON_MP.smon_cb.arvalid && svif.SMON_MP.smon_cb.arready ) begin
  
          if( !ritem_arr.exists(svif.SMON_MP.smon_cb.arid) )
              ritem_arr[svif.SMON_MP.smon_cb.arid] = new($sformatf(" ritem_arr[%0d] ",svif.SMON_MP.smon_cb.arid));
     
     ritem_arr[svif.SMON_MP.smon_cb.arid].arid    = svif.SMON_MP.smon_cb.arid;
     ritem_arr[svif.SMON_MP.smon_cb.arid].araddr.push_back( svif.SMON_MP.smon_cb.araddr );
     ritem_arr[svif.SMON_MP.smon_cb.arid].arlen   = svif.SMON_MP.smon_cb.arlen; 
     ritem_arr[svif.SMON_MP.smon_cb.arid].arsize  = svif.SMON_MP.smon_cb.arsize; 
     ritem_arr[svif.SMON_MP.smon_cb.arid].arburst = svif.SMON_MP.smon_cb.arburst;
     
     ritem_arr[svif.SMON_MP.smon_cb.arid].operation = READ;  
     $display($time," *** Slave Monitor READ ADDR *** ");
     //ritem_arr[svif.SMON_MP.smon_cb.arid].print();
     anl_sport_sseqr.write( ritem_arr[svif.SMON_MP.smon_cb.arid] );

     end
    end 
   end
  endtask

  task get_write_data_with_wid ( );

  forever begin
      @( svif.SMON_MP.smon_cb ) begin
       if( svif.SMON_MP.smon_cb.wvalid  && svif.SMON_MP.smon_cb.wready ) begin

       if(!witem_arr.exists(svif.SMON_MP.smon_cb.wid))
           witem_arr[svif.SMON_MP.smon_cb.wid] = new($sformatf(" witem_arr[%0d] ",svif.SMON_MP.smon_cb.wid));

       witem_arr[svif.SMON_MP.smon_cb.wid].wid  =  svif.SMON_MP.smon_cb.wid ;
       witem_arr[svif.SMON_MP.smon_cb.wid].wdata.push_back(svif.SMON_MP.smon_cb.wdata);
       witem_arr[svif.SMON_MP.smon_cb.wid].wstrb.push_back(svif.SMON_MP.smon_cb.wstrb);
       
       if(svif.SMON_MP.smon_cb.wlast == 1'b1) begin
         if( witem_arr[svif.SMON_MP.smon_cb.wid].wid == witem_arr[svif.SMON_MP.smon_cb.wid].awid ) begin
             witem_arr[svif.SMON_MP.smon_cb.wid].operation = WRITE;  
             anl_sport_sseqr.write( witem_arr[svif.SMON_MP.smon_cb.wid] );
             $display($time," *** Slave Monitor Write Data *** ");
             //witem_arr[svif.SMON_MP.smon_cb.wid].print();
         end
       end 
     end
    end
   end
  endtask 

 task get_write_data_without_wid( );
  int temp_id;

  forever begin
      @( svif.SMON_MP.smon_cb ) begin
       if( svif.SMON_MP.smon_cb.wvalid  && svif.SMON_MP.smon_cb.wready )begin

       temp_id = awid_que.pop_back();

       do begin 
       if( witem_arr[temp_id].wdata.size() > 0 ) @( svif.SMON_MP.smon_cb );
       witem_arr[temp_id].wdata.push_back(svif.SMON_MP.smon_cb.wdata);
       witem_arr[temp_id].wstrb.push_back(svif.SMON_MP.smon_cb.wstrb);
       end 
       while(svif.SMON_MP.smon_cb.wlast !== 1'b1);
     
       if( witem_arr[temp_id].wid == witem_arr[temp_id].awid ) begin
         witem_arr[temp_id].operation = WRITE;  
         anl_sport_sseqr.write( witem_arr[temp_id] );
         $display($time," *** Slave Monitor Write Data *** ");
         //witem_arr[temp_id].print();
        end 
       end
      end
    end
  endtask


  task sample_write_response ( );
  axi_sseq_item #(DATA_WIDTH,ADD_WIDTH) rsp;
  
  forever begin 
      @( svif.SMON_MP.smon_cb ) begin
      if( svif.SMON_MP.smon_cb.bvalid && svif.SMON_MP.smon_cb.bready ) begin

     witem_arr[svif.SMON_MP.smon_cb.bid].bid   = svif.SMON_MP.smon_cb.bid;
     witem_arr[svif.SMON_MP.smon_cb.bid].bresp = svif.SMON_MP.smon_cb.bresp;
         
     anl_sport_ref_sb.write( witem_arr[svif.SMON_MP.smon_cb.bid] );
     $display($time," *** Slave Monitor Write Data with response *** ");
     //witem_arr[svif.SMON_MP.smon_cb.bid].print();
     //witem_arr[svif.SMON_MP.smon_cb.bid]
      // Delete existing transaction from array 
      end
     end
    end
  endtask

  task sample_read_response ( );
  
  forever begin 
      @( svif.SMON_MP.smon_cb ) begin
      
      if( svif.SMON_MP.smon_cb.rvalid && svif.SMON_MP.smon_cb.rready ) begin

      ritem_arr[svif.SMON_MP.smon_cb.rid].rid = svif.SMON_MP.smon_cb.rid;
      ritem_arr[svif.SMON_MP.smon_cb.rid].rresp.push_back(svif.SMON_MP.smon_cb.rresp);
      ritem_arr[svif.SMON_MP.smon_cb.rid].rdata.push_back(svif.SMON_MP.smon_cb.rdata); 
      
      if ( svif.SMON_MP.smon_cb.rlast === 1'b1 ) begin
           anl_sport_ref_sb.write( ritem_arr[svif.SMON_MP.smon_cb.rid] );
           $display($time," *** Slave Monitor READ Data with response *** ");
           ritem_arr[svif.SMON_MP.smon_cb.rid].print();
       end
      end 
     end 
   end  
  endtask
   
endclass 

`endif

