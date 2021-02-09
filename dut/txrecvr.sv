`include "ozdefs.sv"

module txrecvr 
  (
    input clk,
    input reset_n,
    input[7:0] txdata,
    input en_n,
    input txdatak,
    input LTSSM_State curr_ltssm_state,
    output reg[15:0] ts1ctr,
    output reg[15:0] ts2ctr
    );

   parameter MAX_POSSIBLE_TS_LEN = 16;
  

    reg[15:0] setctr;
    reg[7:0] rcvrq[MAX_POSSIBLE_TS_LEN-1:0];
    reg[$clog2(MAX_POSSIBLE_TS_LEN):0] rcvrq_ptr;
    reg[$clog2(MAX_POSSIBLE_TS_LEN):0] rcvrq_ptr_max;
  
    reg[7:0] ts1_nfts;
    reg[7:0] ts1_dri;
    reg[7:0] ts1_tc;
  
    reg[7:0] ts2_nfts;
    reg[7:0] ts2_dri;
    reg[7:0] ts2_tc;
  
  function int CheckIfPadTs1();
    if((rcvrq[0] == `COM) &&
      (rcvrq[1] == `PAD) &&
      (rcvrq[2] == `PAD) &&
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
  
  function int CheckIfPadTs2();
    if((rcvrq[0] == `COM) &&
      (rcvrq[1] == `PAD) &&
      (rcvrq[2] == `PAD) &&
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
  
  function void FlushQueue();
    for(int i=0;i< MAX_POSSIBLE_TS_LEN; i=i+1) rcvrq[i] <= 8'h00;
  endfunction
  
  always @(posedge clk or negedge reset_n) begin
    if (!reset_n || en_n) begin
         setctr = 0;
      FlushQueue();
         ts1ctr = 0;
      ts2ctr = 0;
         rcvrq_ptr = 0;
    end
    else begin
      
      if(txdata == `COM) begin
        rcvrq_ptr <= 0;
        rcvrq[0] <= `COM;
        
        if(CheckIfPadTs1()) begin
        ts1ctr <= ts1ctr + 1;
        ts1_nfts <= rcvrq[3];
        ts1_dri <= rcvrq[4];
        ts1_tc <= rcvrq[5];
        end
        
        if(CheckIfPadTs2()) begin
        ts2ctr <= ts2ctr + 1;
        ts2_nfts <= rcvrq[3];
        ts2_dri <= rcvrq[4];
        ts2_tc <= rcvrq[5];
        end
      end
      else begin
        rcvrq[rcvrq_ptr+1] <= txdata;
        rcvrq_ptr <= rcvrq_ptr + 1;
      end
      
    end
  end
  
  initial begin
    ts1ctr = 0;
    ts2ctr = 0;
  end
  

endmodule
