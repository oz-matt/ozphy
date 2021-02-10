`include "ozdefs.sv"
`include "ltssmfxs.sv"

module txrecvr(mac2phyrcvriface.rcvrside prsi);
  
  always @(posedge prsi.clk or negedge prsi.reset_n) begin
    if (!prsi.reset_n || prsi.en_n) begin
      prsi.FlushQueue();
         prsi.ts1ctr = 0;
      prsi.ts2ctr = 0;
         prsi.rcvrq_ptr = 0;
    end
    else begin
      
      if(prsi.txdata == `COM) begin
        prsi.rcvrq_ptr <= 0;
        prsi.rcvrq[0] <= `COM;
        
        if(prsi.CheckIfPadTs1()) begin
        prsi.ts1ctr <= prsi.ts1ctr + 1;
        prsi.ts1_nfts <= prsi.rcvrq[3];
        prsi.ts1_dri <= prsi.rcvrq[4];
        prsi.ts1_tc <= prsi.rcvrq[5];
        end
        
        if(prsi.CheckIfPadTs2()) begin
        prsi.ts2ctr <= prsi.ts2ctr + 1;
        prsi.ts2_nfts <= prsi.rcvrq[3];
        prsi.ts2_dri <= prsi.rcvrq[4];
        prsi.ts2_tc <= prsi.rcvrq[5];
        end
      end
      else begin
        prsi.rcvrq[prsi.rcvrq_ptr+1] <= prsi.txdata;
        prsi.rcvrq_ptr <= prsi.rcvrq_ptr + 1;
      end
      
    end
  end
  /*
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
  
*/
endmodule

