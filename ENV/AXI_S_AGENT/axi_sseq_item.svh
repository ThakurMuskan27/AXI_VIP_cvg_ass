/////////////////////////////////////////////////////
//
//  // HEADER //
//
//  FILE NAME = axi_sseq_item.svh
//  ENGINEER  = Muskan
//  VERSION   = 1.0 
//  DESCRIPTION =  
//
/////////////////////////////////////////////////////

`ifndef AXI_SSEQ_ITEM
`define AXI_SSEQ_ITEM

typedef enum bit [1:0] { OKAY, EX_OKAY, SLVERR, DECERR } axi_resp_se;

typedef enum bit [1:0] { FIXED, INCR, WRAP } axi_burst_se;

typedef enum bit [2:0] {
    size_1_BYTE    = 3'b000,
    size_2_BYTES   = 3'b001,
    size_4_BYTES   = 3'b010,
    size_8_BYTES   = 3'b011,
    size_16_BYTES  = 3'b100,
    size_32_BYTES  = 3'b101,
    size_64_BYTES  = 3'b110,
    size_128_BYTES = 3'b111
 } axi_size_se;

typedef enum bit[1:0] { READ, WRITE, SIM_WR } operation_se;

class axi_sseq_item #( int DATA_WIDTH = 16 , ADD_WIDTH = 8 ) extends uvm_sequence_item;

 operation_se operation;

//-------------------------------------- WRITE ADDRESS ------//
        bit [7:0] awid;
        bit [(ADD_WIDTH-1) : 0 ] awaddr[$];
        bit [7:0] awlen;
        axi_size_se  awsize;
   
        axi_burst_se awburst;

// ---------------------------------------WRITE DATA -------//
        bit [7:0] wid;
        bit [(DATA_WIDTH-1) : 0] wdata[$];
        bit [((DATA_WIDTH/8) - 1 ) : 0] wstrb[$];

//-------------------------------------- WRITE RESPONSE ------//
        bit [7:0] bid;
        axi_resp_se bresp;

//-------------------------------------- READ ADDRESS ------ //
        bit [7:0] arid;
        bit [(ADD_WIDTH-1) : 0 ] araddr[$];
        bit [7:0] arlen;
        axi_size_se arsize;
   
        axi_burst_se arburst;

// -------------------------------------- READ DATA ------ //
    bit [7:0] rid;
    bit [(DATA_WIDTH-1) : 0] rdata[$];
    axi_resp_se rresp[$];


  `uvm_object_param_utils_begin(axi_sseq_item#(DATA_WIDTH, ADD_WIDTH))
  
      `uvm_field_enum (operation_se, operation, UVM_ALL_ON | UVM_STRING )
      `uvm_field_int ( awid, UVM_ALL_ON | UVM_DEC )
      `uvm_field_queue_int ( awaddr, UVM_ALL_ON | UVM_HEX )
      `uvm_field_int ( awlen, UVM_ALL_ON | UVM_DEC )
      `uvm_field_enum (axi_size_se, awsize, UVM_ALL_ON | UVM_STRING )
      `uvm_field_enum (axi_burst_se, awburst, UVM_ALL_ON | UVM_STRING )
  
  
      `uvm_field_int ( wid, UVM_ALL_ON | UVM_DEC )
      `uvm_field_queue_int ( wdata, UVM_ALL_ON | UVM_HEX )
      `uvm_field_queue_int ( wstrb, UVM_ALL_ON | UVM_BIN )
  
  
      `uvm_field_int ( bid, UVM_ALL_ON | UVM_DEC )
      `uvm_field_enum (axi_resp_se, bresp, UVM_ALL_ON | UVM_STRING )  
  
  
      `uvm_field_int ( arid, UVM_ALL_ON | UVM_DEC )
      `uvm_field_queue_int ( araddr, UVM_ALL_ON | UVM_HEX )
      `uvm_field_int ( arlen, UVM_ALL_ON | UVM_DEC )
      `uvm_field_enum (axi_size_se, arsize, UVM_ALL_ON | UVM_STRING )
      `uvm_field_enum (axi_burst_se, arburst, UVM_ALL_ON | UVM_STRING )
  
  
      `uvm_field_int ( rid, UVM_ALL_ON | UVM_DEC )
      `uvm_field_queue_int ( rdata, UVM_ALL_ON | UVM_HEX )
      `uvm_field_queue_enum (axi_resp_se, rresp, UVM_ALL_ON | UVM_STRING )
  
   `uvm_object_utils_end

   function void do_print(uvm_printer printer);
    super.do_print(printer);
    $display(" == %s == ",get_full_name());
  endfunction 

  function new (string name = "axi_sseq_item");
      super.new(name);
   endfunction

   
endclass 


`endif

