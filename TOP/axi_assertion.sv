
module axi_assertion #(int DATA_WIDTH = 16, ADD_WIDTH = 8, ID_WIDTH = 8 ) ( input logic aclk, areset, axi_minf inf);


////=============  RESET ===========================================================================================================//// 
      sequence reset_seqs1;
      ( (inf.awvalid !== 1) && (inf.arvalid !== 1) && (inf.wvalid !== 1) && (inf.rvalid !== 1) && (inf.bvalid !== 1) );
      endsequence
    
      sequence reset_seqs2;
      ( $rose(inf.awvalid) || $rose(inf.arvalid) || $rose(inf.wvalid) || $rose(inf.rvalid) || $rose(inf.bvalid) );
      endsequence

      property reset_prop;
      @(posedge aclk)
      ( ( areset !== 1'b1 ) |-> reset_seqs1 ) and ( $fell(areset) |=> ##[0:$] reset_seqs2 );
      endproperty

      Reset_property_check : assert property(reset_prop)
                             $info($time," RESET ASSERTION PASSED !!! ");
                             else $error($time," RESET ASSERTION FAILED !!!");

////=============  WRITE ADDR HANDSHAKING ===============================================================================================//// 
      sequence stable_awdata_seqs;
        ( $stable(inf.awaddr) && $stable(inf.awlen) && $stable(inf.awsize) && $stable(inf.awid) ) ;
        //( $stable(inf.awaddr) && $stable(inf.awlen) && $stable(inf.awsize) && $stable(inf.awid) ) throughout (inf.awready !== 1'b1 );
      endsequence
      
      sequence not_unknown_awdata_seqs;
        ( !$isunknown(inf.awaddr) && !$isunknown(inf.awlen) && !$isunknown(inf.awsize) && !$isunknown(inf.awid) ) ;
      endsequence

      property awready_prop1;
      @(posedge aclk )
      inf.awvalid |-> if (inf.awready !== 1'b1) ##1 stable_awdata_seqs;
      endproperty
      
      property awready_prop2;
      @(posedge aclk )
      inf.awvalid |-> not_unknown_awdata_seqs ;
      endproperty

      AWValid_Wait_property_check : assert property(awready_prop1)
                                   $info($time," WADDR CHANNEL HANDSHAKING ASSERTION PASSED [WAIT] !!! ");
                                   else $error($time," WADDR CHANNEL HANDSHAKING ASSERTION FAILED [WAIT] !!! ");
      
      AWValid_No_Wait_property_check : assert property(awready_prop2)
                                     $info($time," WADDR NOT UNKNOWN DATA HANDSHAKING ASSERTION PASSED !!! ");
                                     else $error($time," WADDR NOT UNKNOWN DATA HANDSHAKING ASSERTION FAILED !!! ");

////=============  READ ADDR HANDSHAKING ===============================================================================================//// 
      sequence stable_ardata_seqs;
       (  $stable(inf.araddr) && $stable(inf.arlen) && $stable(inf.arsize) && $stable(inf.arid) ) ;
       //(  $stable(inf.araddr) && $stable(inf.arlen) && $stable(inf.arsize) && $stable(inf.arid) ) throughout (inf.arready !== 1'b1 );
      endsequence
      
      sequence not_unknown_ardata_seqs;
       ( (!$isunknown(inf.araddr)) &&  (!$isunknown(inf.arlen))  &&  (!$isunknown(inf.arsize))  &&  (!$isunknown(inf.arid)) ) ;
      endsequence

      property arready_prop;
      @(posedge aclk )
      inf.arvalid |-> if (inf.arready !== 1'b1) ##1 stable_ardata_seqs; 
      endproperty
      
      property arready_prop1;
      @(posedge aclk )
      inf.arvalid |-> not_unknown_ardata_seqs ;
      endproperty

      ARValid_Ready_property_check : assert property(arready_prop)
                                   $info($time," RADDR CHANNEL HANDSHAKING ASSERTION PASSED !!! ");
                                   else $error($time," RADDR CHANNEL HANDSHAKING ASSERTION FAILED !!! ");
      
      ARValid_No_Wait_property_check : assert property(arready_prop1)
                                      $info($time," RADDR CHANNEL NOT UNKNOWN DATA ASSERTION PASSED !!! ");
                                      else $error($time," RADDR NOT UNKNOWN DATA ASSERTION FAILED !!! ");
      
////=============  WRITE DATA HANDSHAKING ===============================================================================================//// FAILING //// 
      sequence stable_wdata_seqs;
        //( $stable(inf.wdata) && $stable(inf.wstrb) && $stable(inf.wid) ) throughout (inf.wready !== 1'b1 );
        ( $stable(inf.wdata) && $stable(inf.wstrb) && $stable(inf.wlast) && $stable(inf.wid) ) ;
      endsequence
      
      sequence not_unknown_ardata_seqs;
       ( (!$isunknown(inf.wdata)) &&  (!$isunknown(inf.wstrb))  &&  (!$isunknown(inf.wlast))  &&  (!$isunknown(inf.wid)) ) ;
      endsequence
      
      property wready_prop;
      @(posedge aclk )
      (inf.wvalid) |->  if (inf.wready !== 1'b1) ##1 stable_wdata_seqs; 
      endproperty
      
      property wready_prop1;
      @(posedge aclk )
      (inf.wvalid) |-> not_unknown_ardata_seqs; 
      endproperty

      WValid_Ready_property_check : assert property(wready_prop)
                                   $info($time," WDATA CHANNEL HANDSHAKING ASSERTION PASSED !!! ");
                                   else $error($time," WDATA CHANNEL HANDSHAKING ASSERTION FAILED !!! ");
      
      WValid_No_Wait_property_check : assert property(wready_prop1)
                                   $info($time," WDATA NOT UNKNOWN ASSERTION PASSED !!! ");
                                   else $error($time," WDATA NOT UNKNOWN HANDSHAKING ASSERTION FAILED !!! ");
      
////=============  RVALID HANDSHAKING ===============================================================================================//// 

     sequence rvalid_seqs;
     $past( inf.arvalid , , inf.arvalid && inf.arready, ); ////TODO
     endsequence 
      
     property rvalid_prop;
      @(posedge aclk )
      (inf.rvalid) |-> rvalid_seqs; 
     endproperty
      
     Rvalid_Ready_property_check : assert property(rvalid_prop)
                                   $info($time," RDATA CHANNEL HANDSHAKING ASSERTION PASSED !!! ");
                                   else $error($time," RDATA CHANNEL HANDSHAKING ASSERTION FAILED !!! ");
      
endmodule 
