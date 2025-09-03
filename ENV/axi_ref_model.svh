/////////////////////////////////////////////////////
//
//  // HEADER //
//
//  FILE NAME = axi_ref_model.svh
//  ENGINEER  = Muskan
//  VERSION   = 1.0 
//  DESCRIPTION = contains all macro 
//
/////////////////////////////////////////////////////

`ifndef AXI_REF_MODEL
`define AXI_REF_MODEL

//`include "axi_mseq_item.svh"

class axi_ref_model extends uvm_component;

  `uvm_component_utils(axi_ref_model )

    parameter int ADD_WIDTH = 32, DATA_WIDTH = 32;

//// Analysis fifo to get the data broadcasted by monitor
	uvm_tlm_analysis_fifo #(axi_mseq_item #(DATA_WIDTH, ADD_WIDTH)) anl_ref_mfifo;
	uvm_tlm_analysis_fifo #(axi_sseq_item #(DATA_WIDTH, ADD_WIDTH)) anl_ref_sfifo;

//// TLM put port to fifo for scoreboard    
   uvm_blocking_put_port #(axi_mseq_item #(32, 32)) m_put_port;
   uvm_blocking_put_port #(axi_sseq_item #(32, 32)) s_put_port;

   axi_mseq_item #(32, 32) mreq_item;
   axi_mseq_item #(32, 32) mreq_item2;
   
   local bit[7:0] temp_mem [int];

   function new (string name = "axi_ref_model",uvm_component parent = null);
      super.new(name, parent);
   endfunction

    function void build_phase(uvm_phase phase);
     super.build_phase(phase);

//// By monitor
     anl_ref_mfifo = new ("anl_ref_mfifo", this);
     anl_ref_sfifo = new ("anl_ref_sfifo",this);
    
//// To scoreboard    
     m_put_port = new("m_put_port",this);
     s_put_port = new("s_put_port",this);

  endfunction

   task run_phase(uvm_phase phase);
    forever begin
      
      anl_ref_mfifo.get(mreq_item);
      mreq_item2 = new mreq_item;
      predict_exp_data( mreq_item2 ); 

      end
      
  endtask 
  
  task predict_exp_data (axi_mseq_item #(32, 32) req_item );
     
//      if(reset_drive_ev.triggered)begin  //TODO : 
//          foreach(temp_mem[i])
//            temp_mem[i] = `width'b0;
//        end
    
         if (req_item.operation == axi_mpkg::WRITE) begin
             $display ($time," REF_MODEL GET WRITE DATA ");
             write( req_item );  
             m_put_port.put( req_item );
         end 
         else if (req_item.operation == axi_mpkg::READ)begin 
             $display ($time," REF_MODEL GET READ DATA ");
             read( req_item );
             //req_item.print();
             m_put_port.put( req_item );
         end 
       
	 endtask 
     
   function void wrap_addr_calculation ( bit[7:0] alen = 0, bit[2:0] asize = 0, bit [(ADD_WIDTH-1) : 0 ] start_addr = 0, output bit [(ADD_WIDTH-1) : 0 ] addr_que[$]) ;

    bit [(ADD_WIDTH-1) : 0 ] upper_boundary;
    bit [(ADD_WIDTH-1) : 0 ] lower_boundary;
    bit [(ADD_WIDTH-1) : 0 ] wrap_boundary;
    
   wrap_boundary = ((alen + 1 )*( 2**asize ));
   lower_boundary = ( ( start_addr /  wrap_boundary ) * ( wrap_boundary ) );
   upper_boundary = lower_boundary + wrap_boundary;
   addr_que.push_back(start_addr);
    
      for ( int i=1; i<(( alen + 1 )*( 2**asize )); i++ )begin
          addr_que[i] = addr_que[(i-1)] + 1 ; 
        
          `uvm_info(" Ref_model Wrap ", $sformatf("|| addr_que[%0d] = %0d || upper_boundary = %0d || lower_boundary = %0d || wrap_boundary = %0d ||",i,addr_que[i],upper_boundary, lower_boundary, wrap_boundary), UVM_DEBUG );
         if ( addr_que[i] == upper_boundary  ) begin
            addr_que[i] =  lower_boundary ; 
          end 
     end

   endfunction


   function void write( axi_mseq_item #(DATA_WIDTH, ADD_WIDTH) wreq_item );
   int k = 0;
   
   bit [(ADD_WIDTH-1) : 0 ] waddr_que [$];

   waddr_que.delete();

     if ( wreq_item.awburst == axi_mpkg::WRAP ) 
         wrap_addr_calculation(wreq_item.awlen, wreq_item.awsize, wreq_item.awaddr, waddr_que);

     else begin
         for ( int i=0; i<(( wreq_item.awlen + 1 )*( 2**wreq_item.awsize )); i++ )begin
             waddr_que.push_back( wreq_item.awaddr + i );
          end
      end 
         
      foreach( wreq_item.wstrb[i] ) begin
        for( int j=0; j<(DATA_WIDTH/8); j++) begin
          if( wreq_item.wstrb[i][j] == 1 ) begin
             temp_mem[ waddr_que[k] ] = wreq_item.wdata[i][(j*8) +: 8 ];
             //$display( " WDATA[i][(j*8) +: 8 ] = %h | %b || i = %0d || j = %0d |",wreq_item.wdata[i][(j*8) +: 8 ],wreq_item.wdata[i][(j*8) +: 8 ],i,j  );
             k++;
         end
      end
      end

      wreq_item.bid = wreq_item.awid;
      wreq_item.bresp = axi_mpkg::OKAY;

   endfunction

   function void read( axi_mseq_item #(DATA_WIDTH, ADD_WIDTH) rreq_item );
   bit[(DATA_WIDTH-1) : 0] temp;
   bit [(ADD_WIDTH-1) : 0 ] raddr_que [$];
   int k = 0;

   raddr_que.delete();

     if ( rreq_item.arburst == axi_mpkg::WRAP ) 
         wrap_addr_calculation(rreq_item.arlen, rreq_item.arsize, rreq_item.araddr, raddr_que) ;

     else begin
         for ( int i=0; i<(( rreq_item.arlen + 1 )*( 2**rreq_item.arsize )); i++ )begin
             raddr_que.push_back( rreq_item.araddr + i );
           end
      end

      for( int i=0; i<(rreq_item.arlen+1); i++ )begin
          if ( temp_mem.exists( raddr_que[i] )) begin
              for( int j=0; j<(2**rreq_item.arsize); j++) begin
                 if ( temp_mem.exists( raddr_que[k] )) begin
                 temp[(j*8) +: 8] = ( temp_mem[ raddr_que[k] ] );
                 //$display( " RDATA = %h | %b ",temp[(j*8) +: 8],temp[(j*8) +: 8] );
                 k++;
              end
           end
         end 
         //$display( " RDATA = %h | %b ",temp,temp );

         rreq_item.rid = rreq_item.arid;
         rreq_item.rdata.push_back( temp );
         rreq_item.rresp.push_back ( axi_mpkg::OKAY );
      end

   //   $display(" slave temp_mem = %p ",temp_mem );

   endfunction 


endclass 

`endif

