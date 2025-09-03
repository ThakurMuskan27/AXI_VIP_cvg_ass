/////////////////////////////////////////////////////
//
//  // HEADER //
//
//  FILE NAME = axi_wrap_narrow_seqs.svh
//  ENGINEER  = Muskan
//  VERSION   = 1.0 
//  DESCRIPTION = contains all macro 
//
/////////////////////////////////////////////////////

`ifndef AXI_WRAP_NARROW_SEQS
`define AXI_WRAP_NARROW_SEQS

class axi_wrap_narrow_seqs extends axi_base_mseqs ;

  axi_mseq_item #(32,32) mseq_item[$];

  `uvm_object_utils(axi_wrap_narrow_seqs)
   
   function new(string name = "axi_wrap_narrow_seqs");
      super.new(name);
   endfunction

  task body ();

  repeat(10) begin 
  
      mseq_item1 = axi_mseq_item #(32,32)::type_id::create("mseq_item1");
      if(!mseq_item1.randomize with { operation == axi_mpkg::WRITE ; awlen inside {[1:10]} ; awsize < 2; awburst== axi_mpkg::WRAP; } )
       `uvm_fatal(get_name(),"Randomization failed !!! ")

      $cast(mseq_item2, mseq_item1.clone());
      mseq_item.push_back(mseq_item2);
      $display($time," === Sequence Data === ") ;
 //   mseq_item2.print();

       `uvm_send(mseq_item2)
   end

   repeat(10) begin
   get_response(rsp);
   end 

  repeat(10) begin

       mseq_item2 = mseq_item.pop_front(); 
       mseq_item2.araddr  = mseq_item2.awaddr;
       mseq_item2.arsize  = mseq_item2.awsize;
       mseq_item2.arlen   = mseq_item2.awlen;
       mseq_item2.arburst = axi_mpkg::WRAP;
       mseq_item2.operation = axi_mpkg::READ;

       $display($time," === Sequence Data === ") ;
 //      mseq_item2.print();

       `uvm_send(mseq_item2)
  end 

  repeat(10) begin 
  get_response(rsp);
  end    
  
  repeat(10) begin 
  
      mseq_item1 = axi_mseq_item #(32,32)::type_id::create("mseq_item1");
      if(!mseq_item1.randomize with { operation == axi_mpkg::WRITE ; awlen inside {[1:10]} ; awsize < 2; awburst== axi_mpkg::WRAP; } )
       `uvm_fatal(get_name(),"Randomization failed !!! ")

      $cast(mseq_item2, mseq_item1.clone());
      mseq_item.push_back(mseq_item2);
      $display($time," === Sequence Data === ") ;
 //   mseq_item2.print();

       `uvm_send(mseq_item2)
   end

   repeat(10) begin
   get_response(rsp);
   end 

  repeat(10) begin

       mseq_item2 = mseq_item.pop_front(); 
       mseq_item2.araddr  = mseq_item2.awaddr;
       mseq_item2.arsize  = mseq_item2.awsize;
       mseq_item2.arlen   = mseq_item2.awlen;
       mseq_item2.arburst = axi_mpkg::WRAP;
       mseq_item2.operation = axi_mpkg::READ;

       $display($time," === Sequence Data === ") ;
 //      mseq_item2.print();

       `uvm_send(mseq_item2)
  end 

  repeat(10) begin 
  get_response(rsp);
  end    

  
  endtask 
 
endclass 

`endif
