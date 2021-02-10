`include "ozdefs.sv"
`include "ltssmfxs.sv"

module txrecvr(mac2phyrcvriface.rcvrside prsi);
  
  always @(posedge prsi.clk or negedge prsi.reset_n) begin
    if (!prsi.reset_n || prsi.en_n) begin
      prsi.FlushQueue();
         prsi.ResetTs1Ctr();
      prsi.ResetTs2Ctr();
         prsi.rcvrq_ptr = 0;
    end
    else begin
      
      if(prsi.txdata == `COM) begin
        prsi.rcvrq_ptr <= 0;
        prsi.rcvrq[0] <= `COM;
        
        if(prsi.osNowInQueue == TS1) begin
        prsi.IncrementTs1Ctr();
        prsi.ts1_linkn <= prsi.rcvrq[1];
        prsi.ts1_lanen <= prsi.rcvrq[2];
        prsi.ts1_nfts <= prsi.rcvrq[3];
        prsi.ts1_dri <= prsi.rcvrq[4];
        prsi.ts1_tc <= prsi.rcvrq[5];
        end
        
        if(prsi.osNowInQueue == TS2) begin
        prsi.IncrementTs2Ctr();
        prsi.ts2_linkn <= prsi.rcvrq[1];
        prsi.ts2_lanen <= prsi.rcvrq[2];
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
  
endmodule

