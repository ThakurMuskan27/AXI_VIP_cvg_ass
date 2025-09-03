/////////////////////////////////////////////////////
//
//  // HEADER //
//
//  FILE NAME = axi_scrbrd.svh
//  ENGINEER  = Muskan
//  VERSION   = 1.0 
//  DESCRIPTION = contains all macro 
//
/////////////////////////////////////////////////////

`ifndef AXI_SCRBRD
`define AXI_SCRBRD

class axi_scrbrd extends uvm_scoreboard;

   `uvm_component_utils(axi_scrbrd)

   //// TLM get port to get to get data from fifo
   uvm_blocking_get_port #(axi_mseq_item #(32, 32)) m_get_port;
   uvm_blocking_get_port #(axi_sseq_item #(32, 32)) s_get_port;

   //// Analysis fifo to get the data broadcasted by monitor
   uvm_tlm_analysis_fifo #(axi_mseq_item #(32, 32)) anl_sb_mfifo;
   uvm_tlm_analysis_fifo #(axi_sseq_item #(32, 32)) anl_sb_sfifo;

   axi_mseq_item #(32, 32) exp_arr[int];
   axi_sseq_item #(32, 32) act_arr[int];
   
   axi_mseq_item #(32, 32) exp_item;
   axi_sseq_item #(32, 32) act_item;
   int temp_id; 
   
   axi_coverage axi_cvgh;
   
   function new (string name = "axi_scrbrd",uvm_component parent = null);
      super.new(name,parent);
   endfunction

 function void build_phase(uvm_phase phase);
     super.build_phase(phase);

//// By monitor
     anl_sb_mfifo = new ("anl_sb_mfifo",this);
     anl_sb_sfifo = new ("anl_sb_sfifo",this);
     
//// By ref_model     
     m_get_port = new("m_get_port",this);
     s_get_port = new("s_get_port",this);

     axi_cvgh = new("axi_cvgh");

  endfunction
  
  function void set_act_arr( bit[7:0] id, axi_sseq_item #(32, 32) data);
	      act_arr[id] = new data;
          temp_id = id;
          `uvm_info(" SCRBRD (set_act_arr)",$sformatf("act_arr[%0d] = %0d",id,act_arr[id]),UVM_DEBUG)
		 // ev.trigger();
  endfunction
  
  function void set_exp_arr( bit[7:0] id, axi_mseq_item #(32, 32) data);
	      exp_arr[id] = new data;
          `uvm_info(" SCRBRD (set_exp_arr)",$sformatf("exp_arr[%0d] = %0d",id,exp_arr[id]),UVM_DEBUG)
  endfunction

  task run_phase (uvm_phase phase);
  int count = 0;
    
  forever begin 
    fork 
      begin
        forever begin       
           m_get_port.get( exp_item );                          //// Expected
           if( exp_item.operation == axi_mpkg::WRITE ) 
               set_exp_arr( exp_item.awid, exp_item );
           else 
               set_exp_arr( exp_item.arid, exp_item );
           phase.raise_objection (this, " Raise Objection At Scoreboard (exp) ",1);
           count++;
           `uvm_info("SCRBRD EXPECTED",$sformatf(" RAISE | count = %0d ",count),UVM_DEBUG)
    
        end 
      end

      begin
        forever begin
           anl_sb_sfifo.get( act_item );                         //// Actual
           if( act_item.operation == axi_spkg::WRITE )
               set_act_arr( act_item.awid, act_item );
           else
               set_act_arr( act_item.arid, act_item );
           check_data( act_arr[temp_id], exp_arr[temp_id] );    //// Compare 
           phase.raise_objection (this, " Raise Objection At Scoreboard (act) ",1);
           count++; 
           `uvm_info("SCRBRD ACTUAL",$sformatf(" RAISE | count = %0d ",count),UVM_DEBUG)
        end
      end
    join_none
      
      wait ( ( count > 0 ) && ( count % 2 == 0 ) );
      count = count - 2;
      `uvm_info("SCRBRD",$sformatf(" DROP | count = %0d ",count),UVM_DEBUG)
      phase.drop_objection (this, " Drop Objection At Scoreboard ", 2);

    end    
  endtask 

   task check_data( axi_sseq_item #(32, 32) act_item, axi_mseq_item #(32, 32) exp_item);
   int i = 0 ;
         if ( act_item.operation == axi_spkg::WRITE ) begin
             if ( exp_item.bid == act_item.bid && exp_item.bresp == act_item.bresp ) begin
                 s_count++;
                 $display($time,"|| ---- WRITE RESPONSE SUCCESS !!!! ---- || Success Count = %0d",s_count);  
                 `uvm_info( " ACT ITEM ", act_item.sprint(), UVM_DEBUG );
                 `uvm_info( " EXP ITEM ", exp_item.sprint(), UVM_DEBUG );
                  axi_cvgh.sseq_item = act_item;
                  foreach(act_item.wdata[i])
                     axi_cvgh.axi_cvg.sample(i,0);
              end
              else begin
                 f_count++;
                 `uvm_warning(" FAIL ",$sformatf("|| ---- WRITE RESPONSE FAIL !!!! ---- || Fail Count = %0d",f_count))
                 `uvm_info( " ACT ITEM ", act_item.sprint(), UVM_NONE );
                 `uvm_info( " EXP ITEM ", exp_item.sprint(), UVM_NONE );
              end
         end

         else if ( act_item.operation == axi_spkg::READ ) begin
             while ( (( act_item.rdata[i] == exp_item.rdata[i] ) && ( act_item.rresp[i] == exp_item.rresp[i] ) && ( act_item.rid == exp_item.rid )) && ( i < exp_item.rdata.size() ) ) begin
                 axi_cvgh.axi_cvg.sample(0,i);
                 i++;
             end

             if( i < act_item.rdata.size() ) begin
                 f_count++;
                 `uvm_warning(" FAIL ",$sformatf("|| ---- READ RESPONSE FAIL !!!! ----|| Fail Index = %0d || Fail Count = %0d",i,f_count) )
                 `uvm_info( " ACT ITEM ", act_item.sprint(), UVM_NONE )
                 `uvm_info( " EXP ITEM ", exp_item.sprint(), UVM_NONE )
             end
             else if ( i == act_item.rdata.size() ) begin
                 s_count++;
                 $display($time,"|| ---- READ RESPONSE SUCCESS !!!! ---- || Success Count = %0d",s_count); 
             end
           end

	 endtask 

endclass 

`endif

