/////////////////////////////////////////////////////
//
//  // HEADER //
//
//  FILE NAME = axi_base_sseqs.svh
//  ENGINEER  = Muskan
//  VERSION   = 1.0 
//  DESCRIPTION = contains all macro 
//
/////////////////////////////////////////////////////

`ifndef AXI_BASE_SSEQS
`define AXI_BASE_SSEQS

class axi_base_sseqs #(int DATA_WIDTH = 16 , ADD_WIDTH = 8)  extends uvm_sequence #(axi_sseq_item #(DATA_WIDTH, ADD_WIDTH));

   `uvm_object_param_utils(axi_base_sseqs #(DATA_WIDTH, ADD_WIDTH))

    axi_sseq_item #(DATA_WIDTH, ADD_WIDTH) req_item;
    axi_sseq_item #(DATA_WIDTH, ADD_WIDTH) req_item1;

   `uvm_declare_p_sequencer(axi_sseqr #(DATA_WIDTH , ADD_WIDTH))

   local bit[7:0] mem [int];

   function new (string name = "axi_base_sseqs");
      super.new(name);
   endfunction

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
        
          `uvm_info(" Slave Sequence Wrap ", $sformatf("|| addr_que[%0d] = %0d || upper_boundary = %0d || lower_boundary = %0d || wrap_boundary = %0d ||",i,addr_que[i],upper_boundary, lower_boundary, wrap_boundary), UVM_DEBUG );
         if ( addr_que[i] == upper_boundary  ) begin
            addr_que[i] =  lower_boundary ; 
          end 
     end

   endfunction


   function void write( axi_sseq_item #(DATA_WIDTH, ADD_WIDTH) wreq_item );
   int k = 0;

     if ( wreq_item.awburst == WRAP ) 
         wrap_addr_calculation(wreq_item.awlen, wreq_item.awsize, wreq_item.awaddr[0],wreq_item.awaddr) ;

     else begin
          //$display("| size = %0d |",wreq_item.awaddr.size());
         for ( int i=1; i<(( wreq_item.awlen + 1 )*( 2**wreq_item.awsize )); i++ )begin
             wreq_item.awaddr.push_back( wreq_item.awaddr[0] + i );
             //$display("i = %0d | awaddr[%0d] = %h | awaddr[0] = %h | size = %0d |",i,i,wreq_item.awaddr[i],wreq_item.awaddr[0],wreq_item.awaddr.size());
             end
      end 
         
      foreach( wreq_item.wstrb[i] ) begin
        for( int j=0; j<(DATA_WIDTH/8); j++) begin
          if( wreq_item.wstrb[i][j] == 1 ) begin
             mem[ wreq_item.awaddr[k] ] = wreq_item.wdata[i][(j*8) +: 8 ];
             //$display( " WDATA[i][(j*8) +: 8 ] = %h | %b || i = %0d || j = %0d |",wreq_item.wdata[i][(j*8) +: 8 ],wreq_item.wdata[i][(j*8) +: 8 ],i,j  );
             k++;
         end
      end
      end

      wreq_item.bid = wreq_item.awid;
      wreq_item.bresp = OKAY;

   endfunction

   function void read( axi_sseq_item #(DATA_WIDTH, ADD_WIDTH) rreq_item );
   bit[(DATA_WIDTH-1) : 0] temp;
   int k = 0;

     if ( rreq_item.arburst == WRAP ) 
         wrap_addr_calculation(rreq_item.arlen, rreq_item.arsize, rreq_item.araddr[0], rreq_item.araddr) ;

     else begin
         for ( int i=1; i<(( rreq_item.arlen + 1 )*( 2**rreq_item.arsize )); i++ )begin
             rreq_item.araddr.push_back( rreq_item.araddr[0] + i );
             end
      end

      for( int i=0; i<(rreq_item.arlen+1); i++ )begin
          if ( mem.exists( rreq_item.araddr[i] )) begin
              for( int j=0; j<(2**rreq_item.arsize); j++) begin
                 temp[(j*8) +: 8] = ( mem[ rreq_item.araddr[k] ] );
                 //$display( " RDATA = %h | %b ",temp[(j*8) +: 8],temp[(j*8) +: 8] );
                 k++;
              end
         end 
         //$display( " RDATA = %h | %b ",temp,temp );

         rreq_item.rid = rreq_item.arid;
         rreq_item.rdata.push_back( temp );
         rreq_item.rresp.push_back ( OKAY );
      end

   //   $display(" slave mem = %p ",mem );

   endfunction

    task body();

    forever begin

      p_sequencer.anl_sseqr_fifo.get(req_item1);
      req_item = new req_item1 ;

      //req_item.print();

      if ( req_item.operation == WRITE )begin
          write ( req_item );
          $display($time, ": Slave sequence WRITE response ");
          req_item.print();
          `uvm_send( req_item )
      end 
      else if ( req_item.operation == READ )begin
          read ( req_item );
          $display($time," : Slave sequence READ response ");
          req_item.print();
          `uvm_send( req_item )
          //send_request( req_item );
      end  
      
      //$display(" *** Req Item get at Sequence *** ");
      //req_item.print();

    end

    endtask

   
endclass 

`endif
