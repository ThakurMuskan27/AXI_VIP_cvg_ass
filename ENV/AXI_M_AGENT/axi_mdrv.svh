/////////////////////////////////////////////////////
//
//  // HEADER //
//
//  FILE NAME = axi_mdrv.svh
//  ENGINEER  = Muskan
//  VERSION   = 1.0 
//  DESCRIPTION = contains all macro 
//
/////////////////////////////////////////////////////

`ifndef AXI_MDRV
`define AXI_MDRV

class axi_mdrv #(int DATA_WIDTH = 16 , ADD_WIDTH = 8) extends uvm_driver #(axi_mseq_item #(DATA_WIDTH, ADD_WIDTH));

   `uvm_component_param_utils(axi_mdrv #(DATA_WIDTH, ADD_WIDTH))
  
    virtual axi_minf #(DATA_WIDTH, ADD_WIDTH) mvif;
  
    axi_mseq_item #(DATA_WIDTH,ADD_WIDTH) mseq_item;
    axi_mseq_item #(DATA_WIDTH,ADD_WIDTH) pending_transaction_wadr[$];
    axi_mseq_item #(DATA_WIDTH,ADD_WIDTH) pending_transaction_wdata[$];
    axi_mseq_item #(DATA_WIDTH,ADD_WIDTH) pending_transaction_radr[$];
    
    axi_mseq_item #(DATA_WIDTH,ADD_WIDTH) write_resp_arr[int];
    axi_mseq_item #(DATA_WIDTH,ADD_WIDTH) read_resp_arr[int];

    uvm_event drop_obj_read;
    uvm_event drop_obj_write;

   function new (string name = "axi_mdrv", uvm_component parent = null);
      super.new(name,parent);
      drop_obj_read = new("drop_obj_read");
      drop_obj_write = new("drop_obj_write");
   endfunction
  
  task run_phase (uvm_phase phase);
  fork 
    forever begin 
      seq_item_port.get( mseq_item );
      if ( mseq_item.operation == SIM_WR ) begin
      pending_transaction_wadr.push_back(mseq_item);
      pending_transaction_radr.push_back(mseq_item);
      pending_transaction_wdata.push_back(mseq_item);
      
      $cast(write_resp_arr[ mseq_item.awid ],mseq_item.clone());
      write_resp_arr[ mseq_item.awid ].set_id_info(mseq_item);
      
      $cast(read_resp_arr[ mseq_item.arid ],mseq_item.clone());
      read_resp_arr[ mseq_item.arid ].set_id_info(mseq_item);
      phase.raise_objection (this, " Raise Objection At Master Driver [SIM_WR] ", 2);
      end

      else if ( mseq_item.operation == WRITE ) begin 
      pending_transaction_wadr.push_back(mseq_item);
      pending_transaction_wdata.push_back(mseq_item); 
      
      $cast(write_resp_arr[ mseq_item.awid ],mseq_item.clone());
      write_resp_arr[ mseq_item.awid ].set_id_info(mseq_item);
      $display($time," MASTER DRIVER RAISE OBJ [WRITE] ");
      phase.raise_objection (this, " Raise Objection At Master Driver [WRITE] ");
      fork
        begin
          drop_obj_write.wait_trigger();  //// TODO 
          $display($time," MASTER DRIVER DROP OBJ [WRITE] ");
          phase.drop_objection (this, " Drop Objection At Master Driver [WRITE] ");
        end
      join_none
      end

      else if ( mseq_item.operation == READ ) begin
      pending_transaction_radr.push_back(mseq_item);
      
      $cast(read_resp_arr[ mseq_item.arid ],mseq_item.clone());
      read_resp_arr[ mseq_item.arid ].set_id_info(mseq_item);
      $display($time," MASTER DRIVER RAISE OBJ [READ] ");
      phase.raise_objection (this, " Raise Objection At Master Driver [READ] ");
      fork 
        begin
        drop_obj_read.wait_trigger();
        $display($time," MASTER DRIVER DROP OBJ [READ] ");
        phase.drop_objection (this, " Drop Objection At Master Driver [READ] ");
        end
      join_none

      end


    end 
  join_none
     send_to_dut();
  endtask 

  task send_to_dut ();
       fork
       send_write_address();
       send_read_address();
       send_write_data();
       sample_write_response();
       sample_read_response();
       join
  endtask
  
  task send_write_address ( );
  axi_mseq_item #(DATA_WIDTH,ADD_WIDTH) req;
  forever begin
      
      wait (pending_transaction_wadr.size() > 0);
      
      @( mvif.MDRV_MP.mdrv_cb ) begin

      if(mvif.MDRV_MP.mdrv_cb.awvalid == 1'b1)
          wait (mvif.MDRV_MP.mdrv_cb.awready == 1'b1);

      req = pending_transaction_wadr.pop_front();
      mvif.MDRV_MP.mdrv_cb.awid    <= req.awid;
      mvif.MDRV_MP.mdrv_cb.awaddr  <= req.awaddr;
      mvif.MDRV_MP.mdrv_cb.awlen   <= req.awlen;
      mvif.MDRV_MP.mdrv_cb.awsize  <= req.awsize;
      mvif.MDRV_MP.mdrv_cb.awburst <= req.awburst;
      mvif.MDRV_MP.mdrv_cb.awvalid <= 1'b1;
      // mvif.MDRV_MP.mdrv_cb.bready <= 1'b1; // correct or not ?? // TODO       

      if ( pending_transaction_wadr.size() == 0 )begin 
          //wait (mvif.MDRV_MP.mdrv_cb.awready == 1'b1);
       
       /*do begin @(posedge mvif.MDRV_MP.aclk);
       $display($time," awready = %0d ",mvif.MDRV_MP.mdrv_cb.awready);
       end
       while ( mvif.MDRV_MP.mdrv_cb.awready !== 1'b1 );*/       
       @( mvif.MDRV_MP.mdrv_cb iff mvif.MDRV_MP.mdrv_cb.awready )

       mvif.MDRV_MP.mdrv_cb.awvalid <= 1'b0; 
       end
     end
   end 
  endtask
   
  task send_read_address ( );
  axi_mseq_item #(DATA_WIDTH,ADD_WIDTH) req;

  forever begin
      
      wait (pending_transaction_radr.size() > 0);
      
      @( mvif.MDRV_MP.mdrv_cb ) begin
      
      if(mvif.MDRV_MP.mdrv_cb.arvalid == 1'b1)
          wait (mvif.MDRV_MP.mdrv_cb.arready == 1'b1);
      
      req = pending_transaction_radr.pop_front();
      mvif.MDRV_MP.mdrv_cb.arid    <= req.arid;
      mvif.MDRV_MP.mdrv_cb.araddr  <= req.araddr;
      mvif.MDRV_MP.mdrv_cb.arlen   <= req.arlen;
      mvif.MDRV_MP.mdrv_cb.arsize  <= req.arsize;
      mvif.MDRV_MP.mdrv_cb.arburst <= req.arburst;
      mvif.MDRV_MP.mdrv_cb.arvalid <= 1'b1;
      
      if ( pending_transaction_radr.size() == 0 )begin 
       //   wait (mvif.MDRV_MP.mdrv_cb.arready == 1'b1);
       
       do @( mvif.MDRV_MP.mdrv_cb ); // --> @posedge aclk at top then @mdrv_cb here won't work  // because @posedge aclk and @cb both are different event which triggers at same time //
       while ( mvif.MDRV_MP.mdrv_cb.arready !== 1'b1 ); 
       //@( mvif.MDRV_MP.mdrv_cb iff mvif.MDRV_MP.mdrv_cb.arready )
        
       mvif.MDRV_MP.mdrv_cb.arvalid <= 1'b0; end

     end
   end
  endtask

  task send_write_data ( );
  axi_mseq_item #(DATA_WIDTH,ADD_WIDTH) req;

  forever
    begin
      wait (pending_transaction_wdata.size() > 0);
      
      @( mvif.MDRV_MP.mdrv_cb) begin
      req = pending_transaction_wdata.pop_front();
      
      while(req.wdata.size() > 0 ) begin
      if(mvif.MDRV_MP.mdrv_cb.wvalid === 1'b1)
          wait (mvif.MDRV_MP.mdrv_cb.wready === 1'b1);
      mvif.MDRV_MP.mdrv_cb.wid     <= req.wid;
      mvif.MDRV_MP.mdrv_cb.wvalid  <= 1'b1;

      mvif.MDRV_MP.mdrv_cb.wdata   <= req.wdata.pop_front();
      mvif.MDRV_MP.mdrv_cb.wstrb   <= req.wstrb.pop_front();
       
      if ( req.wdata.size() == 0 )  mvif.MDRV_MP.mdrv_cb.wlast   <= 1'b1; 
      else mvif.MDRV_MP.mdrv_cb.wlast   <= 1'b0; 
      
      if (req.wdata.size() > 0 ) @( mvif.MDRV_MP.mdrv_cb );
     end
     end
      if ( pending_transaction_wdata.size() == 0 ) begin
         // wait (mvif.MDRV_MP.mdrv_cb.wready == 1'b1);
        @( mvif.MDRV_MP.mdrv_cb iff mvif.MDRV_MP.mdrv_cb.wready )
        mvif.MDRV_MP.mdrv_cb.wvalid  <= 1'b0;
        mvif.MDRV_MP.mdrv_cb.wlast   <= 1'b0; 
     end 
    end
  endtask

  task sample_write_response ( );
  axi_mseq_item #(DATA_WIDTH,ADD_WIDTH) rsp;
  
  forever begin 
      @( mvif.MDRV_MP.mdrv_cb) begin
      @(negedge mvif.MDRV_MP.mdrv_cb.wlast) mvif.MDRV_MP.mdrv_cb.bready <= 1'b1; 
      // Callback method to add delay for bready
      wait ( mvif.MDRV_MP.mdrv_cb.bvalid && mvif.MDRV_MP.mdrv_cb.bready ); // TODO
      
      write_resp_arr[ mvif.MDRV_MP.mdrv_cb.bid ].bid   = mvif.MDRV_MP.mdrv_cb.bid;
      write_resp_arr[ mvif.MDRV_MP.mdrv_cb.bid ].bresp = mvif.MDRV_MP.mdrv_cb.bresp;
      $display($time," MASTER DRIVER WRITE RESPONSE ");
      //rsp.print();
      seq_item_port.put_response(write_resp_arr[ mvif.MDRV_MP.mdrv_cb.bid ]);
      // Send responce back to sequence  
      drop_obj_write.trigger();
    end
    end
  endtask

  task sample_read_response ( );
      //@(posedge mvif.MDRV_MP.mdrv_cb.arvalid)
      @(negedge mvif.MDRV_MP.mdrv_cb.arvalid)
      mvif.MDRV_MP.mdrv_cb.rready <= 1'b1;  /// To check rvalid assertion 
  
  forever begin 
      @( mvif.MDRV_MP.mdrv_cb ) begin

      wait( mvif.MDRV_MP.mdrv_cb.rvalid && mvif.MDRV_MP.mdrv_cb.rready ) begin
      
      read_resp_arr[ mvif.MDRV_MP.mdrv_cb.rid ].rid   = mvif.MDRV_MP.mdrv_cb.rid;
      read_resp_arr[ mvif.MDRV_MP.mdrv_cb.rid ].rresp.push_back(mvif.MDRV_MP.mdrv_cb.rresp);
      read_resp_arr[ mvif.MDRV_MP.mdrv_cb.rid ].rdata.push_back(mvif.MDRV_MP.mdrv_cb.rdata); 
      
      if ( mvif.MDRV_MP.mdrv_cb.rlast === 1'b1 )begin      
      // Send responce back to sequence  
      $display($time," MASTER DRIVER READ RESPONSE ");
      //rsp.print();
      seq_item_port.put_response(read_resp_arr[ mvif.MDRV_MP.mdrv_cb.rid ]);
      drop_obj_read.trigger();
      end
      end 
     end 
   end  
  endtask 


endclass 

`endif
