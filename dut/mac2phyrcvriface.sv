`include "ozdefs.sv"
`include "ltssmfxs.sv"

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
    reg[$clog2(MAX_POSSIBLE_TS_LEN):0] rcvrq_ptr;
    reg[$clog2(MAX_POSSIBLE_TS_LEN):0] rcvrq_ptr_max;
  

    reg[7:0] ts1_nfts;
    reg[7:0] ts1_dri;
    reg[7:0] ts1_tc;
  
    reg[7:0] ts2_nfts;
    reg[7:0] ts2_dri;
    reg[7:0] ts2_tc;
  
  function void FlushQueue();
    for(int i=0;i< MAX_POSSIBLE_TS_LEN; i=i+1) Ltssm::rcvrq[i] <= 8'h00;
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
        Ltssm::rcvrq[0] <= `COM;
        
        if(Ltssm::CheckIfPadTs1()) begin
        ts1ctr <= ts1ctr + 1;
        ts1_nfts <= Ltssm::rcvrq[3];
        ts1_dri <= Ltssm::rcvrq[4];
        ts1_tc <= Ltssm::rcvrq[5];
        end
        
        if(Ltssm::CheckIfPadTs2()) begin
        ts2ctr <= ts2ctr + 1;
        ts2_nfts <= Ltssm::rcvrq[3];
        ts2_dri <= Ltssm::rcvrq[4];
        ts2_tc <= Ltssm::rcvrq[5];
        end
      end
      else begin
        Ltssm::rcvrq[rcvrq_ptr+1] <= txdata;
        rcvrq_ptr <= rcvrq_ptr + 1;
      end
      
    end
  end
  
  initial begin
    ts1ctr = 0;
    ts2ctr = 0;
  end
  

endmodule
