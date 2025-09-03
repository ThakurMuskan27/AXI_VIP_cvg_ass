/////////////////////////////////////////////////////
//
//  // HEADER //
//
//  FILE NAME = axi_sdrv.svh
//  ENGINEER  = Muskan
//  VERSION   = 1.0 
//  DESCRIPTION = contains all macro 
//
/////////////////////////////////////////////////////

`ifndef AXI_SDRV
`define AXI_SDRV

class axi_sdrv #(int DATA_WIDTH = 16, ADD_WIDTH = 8 ) extends uvm_driver #(axi_sseq_item #(DATA_WIDTH,ADD_WIDTH));

   `uvm_component_param_utils(axi_sdrv #(DATA_WIDTH, ADD_WIDTH))

    axi_sseq_item #(DATA_WIDTH,ADD_WIDTH) pending_bresp_que[$];
    axi_sseq_item #(DATA_WIDTH,ADD_WIDTH) pending_rresp_que[$];
    
    axi_sseq_item #(DATA_WIDTH,ADD_WIDTH) resp_item_g;
  
    virtual axi_sinf #(32,32) svif;

   function new (string name = "axi_sdrv", uvm_component parent = null);
      super.new(name,parent);
   endfunction
   
  task run_phase (uvm_phase phase);
    fork
      begin
        send_ready_resp();
      end
      begin
      forever begin 
         seq_item_port.get_next_item(resp_item_g);
         if( resp_item_g.operation == WRITE )
             pending_bresp_que.push_back(resp_item_g);
         else if ( resp_item_g.operation == READ ) 
             pending_rresp_que.push_back(resp_item_g);
         seq_item_port.item_done();
         end
       end 
    join_none

    drive_response();

  endtask

  task drive_response();

   fork
     drive_write_response();
     drive_read_response();
   join

  endtask 

  virtual task send_ready_resp ();
  fork
     drive_awready();
     drive_arready();
     drive_wready();
  join  
  endtask

  virtual task drive_awready();
   forever begin
      @( svif.SDRV_MP.sdrv_cb )
      svif.SDRV_MP.sdrv_cb.awready <= 1'b1;
      @( svif.SDRV_MP.sdrv_cb )
      svif.SDRV_MP.sdrv_cb.awready <= 1'b0;
   end 
  endtask 

  virtual task drive_arready();
   forever begin
      @( svif.SDRV_MP.sdrv_cb )
      svif.SDRV_MP.sdrv_cb.arready <= 1'b1;
   end 
  endtask

  virtual task drive_wready();
   forever begin
      @( svif.SDRV_MP.sdrv_cb )
      svif.SDRV_MP.sdrv_cb.wready <= 1'b1;
      @(posedge svif.SDRV_MP.sdrv_cb.wlast) 
      svif.SDRV_MP.sdrv_cb.wready <= 1'b0;   //// To check the wdata assertion 
      
      @( svif.SDRV_MP.sdrv_cb );
   end 
  endtask 

  task drive_write_response ();
    axi_sseq_item #(DATA_WIDTH,ADD_WIDTH) resp_item;

  forever begin

    wait ( pending_bresp_que.size > 0 );
    
    @( svif.SDRV_MP.sdrv_cb ) begin
    resp_item = pending_bresp_que.pop_front();

    if(svif.SDRV_MP.sdrv_cb.bvalid === 1'b1 )
        wait(svif.SDRV_MP.sdrv_cb.bready === 1'b1);

    svif.SDRV_MP.sdrv_cb.bvalid <= 1'b1;
    svif.SDRV_MP.sdrv_cb.bid    <= resp_item.bid;
    svif.SDRV_MP.sdrv_cb.bresp  <= resp_item.bresp;
    end 

   // wait (svif.SDRV_MP.sdrv_cb.bready == 1'b1 );
    if( pending_bresp_que.size == 0 ) begin
        do  @( svif.SDRV_MP.sdrv_cb );
        while (svif.SDRV_MP.sdrv_cb.bready!== 1'b1);
        svif.SDRV_MP.sdrv_cb.bvalid <= 1'b0;
    end
   end
    
  endtask 

  task drive_read_response ( );
    axi_sseq_item #(DATA_WIDTH,ADD_WIDTH) resp_item;
    axi_sseq_item #(DATA_WIDTH,ADD_WIDTH) resp_item2;
    
    @(negedge svif.SDRV_MP.sdrv_cb.wlast)
    svif.SDRV_MP.sdrv_cb.rvalid <= 1'b1;   ///// To check rvalid assertion  

  forever begin

    wait ( pending_rresp_que.size > 0 );
    
    @( svif.SDRV_MP.sdrv_cb ) begin
      resp_item2 = pending_rresp_que.pop_front();
      resp_item = new resp_item2;
    
    svif.SDRV_MP.sdrv_cb.rvalid <= 1'b1;
    svif.SDRV_MP.sdrv_cb.rid    <= resp_item.rid;

    while ( resp_item.rdata.size() != 0 ) begin
        svif.SDRV_MP.sdrv_cb.rresp   <= resp_item.rresp.pop_front();
        svif.SDRV_MP.sdrv_cb.rdata  <= resp_item.rdata.pop_front();

        if( resp_item.rdata.size() > 0 ) begin
            svif.SDRV_MP.sdrv_cb.rlast <= 1'b0;
            @(svif.SDRV_MP.sdrv_cb iff svif.SDRV_MP.sdrv_cb.rready );
            //do @( svif.SDRV_MP.sdrv_cb );
            //while ( svif.SDRV_MP.sdrv_cb.rready !== 1'b1 );
        end

        if( resp_item.rdata.size()== 1'b0 )begin
            svif.SDRV_MP.sdrv_cb.rlast <= 1'b1;
            do  @( svif.SDRV_MP.sdrv_cb );
            while (svif.SDRV_MP.sdrv_cb.rready !== 1'b1);
            svif.SDRV_MP.sdrv_cb.rlast <= 1'b0;
        end

      end
      
      if(pending_rresp_que.size == 0) svif.SDRV_MP.sdrv_cb.rvalid <= 1'b0;

     end
   end

  endtask

    
endclass 

`endif

