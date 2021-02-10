`include "ozdefs.sv"

interface mac2phyrcvriface(
    input logic clk,
    input logic reset_n,
    input logic[7:0] txdata,
    input logic en_n,
    input logic txdatak,
    input LTSSM_State curr_ltssm_state,
    output logic[15:0] ts1ctr,
    output logic[15:0] ts2ctr
  );
  
    parameter MAX_POSSIBLE_TS_LEN = 16;
  
    logic[7:0] rcvrq[MAX_POSSIBLE_TS_LEN-1:0];
    logic[$clog2(MAX_POSSIBLE_TS_LEN):0] rcvrq_ptr;
    logic[$clog2(MAX_POSSIBLE_TS_LEN):0] rcvrq_ptr_max;
  
    logic[7:0] ts1_nfts;
    logic[7:0] ts1_dri;
    logic[7:0] ts1_tc;
    logic[7:0] ts1_lanen;
    logic[7:0] ts1_linkn;
  
    logic[7:0] ts2_nfts;
    logic[7:0] ts2_dri;
    logic[7:0] ts2_tc;
    logic[7:0] ts2_lanen;
    logic[7:0] ts2_linkn;
  
    logic[15:0] ts1ctr;
    logic[15:0] ts2ctr;
    
    logic linkProposed;
    
    OsType osNowInQueue;
    
    always_comb begin
      if(CheckIfSkp()) osNowInQueue= SKP;
      else if(CheckIfTs1()) osNowInQueue= TS1;
      else if(CheckIfTs2()) osNowInQueue= TS2;
      else osNowInQueue= NONE;
    end
    
    assign linkProposed = ((osNowInQueue == TS1) &&
      (rcvrq[1] != `PAD) &&
      (curr_ltssm_state == CONFIG_LINKWIDTH_START)) ? 1 : 0;
    
  function void FlushQueue();
    for(int i=0;i< MAX_POSSIBLE_TS_LEN; i=i+1) rcvrq[i] <= 8'h00;
  endfunction
  
  function int CheckIfTs1();
    if((rcvrq[0] == `COM) &&
      (rcvrq[6] == `TS1ID) &&
      (rcvrq[7] == `TS1ID) &&
      (rcvrq[8] == `TS1ID) &&
      (rcvrq[9] == `TS1ID) &&
      (rcvrq[10] == `TS1ID) &&
      (rcvrq[11] == `TS1ID) &&
      (rcvrq[12] == `TS1ID) &&
      (rcvrq[13] == `TS1ID) &&
      (rcvrq[14] == `TS1ID) &&
      (rcvrq[15] == `TS1ID))
        return 1;
     else return 0;
  endfunction
  
  function int CheckIfSkp();
    if((rcvrq[0] == `COM) &&
      (rcvrq[1] == `SKP) &&
      (rcvrq[2] == `SKP) )
        return 1;
     else return 0;
  endfunction
  
  function int CheckIfTs2();
    if((rcvrq[0] == `COM) &&
      (rcvrq[6] == `TS2ID) &&
      (rcvrq[7] == `TS2ID) &&
      (rcvrq[8] == `TS2ID) &&
      (rcvrq[9] == `TS2ID) &&
      (rcvrq[10] == `TS2ID) &&
      (rcvrq[11] == `TS2ID) &&
      (rcvrq[12] == `TS2ID) &&
      (rcvrq[13] == `TS2ID) &&
      (rcvrq[14] == `TS2ID) &&
      (rcvrq[15] == `TS2ID))
        return 1;
     else return 0;
  endfunction
  
  function void IncrementTs1Ctr();
    ts1ctr++;
  endfunction
  
  function void IncrementTs2Ctr();
    ts2ctr++;
  endfunction
  
  function void ResetTs1Ctr();
    ts1ctr <= 0;
  endfunction
  
  function void ResetTs2Ctr();
    ts2ctr <= 0;
  endfunction
  
  initial begin
    ts1ctr = 0;
    ts2ctr = 0;
  end
  
  modport rcvrside (
    input clk,
    input reset_n,
    input txdata,
    input en_n,
    input txdatak,
    input curr_ltssm_state,
    input osNowInQueue,
    inout rcvrq,
    inout rcvrq_ptr,
    inout rcvrq_ptr_max,
    output ts1_linkn,
    output ts1_lanen,
    output ts1_nfts,
    output ts1_dri,
    output ts1_tc,
    output ts2_linkn,
    output ts2_lanen,
    output ts2_nfts,
    output ts2_dri,
    output ts2_tc,
    import IncrementTs1Ctr,
    import IncrementTs2Ctr,
    import ResetTs1Ctr,
    import ResetTs2Ctr,
    import FlushQueue
  );

endinterface
  
