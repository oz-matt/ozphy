`include "ozdefs.sv"
module rxdriver (phy2macdriveriface.drvrside mdsi);

  integer seqPtr;
  
  initial begin
    seqPtr = 0;
  end

  always @(posedge mdsi.clk or negedge mdsi.p2md_rstn) begin
    if(!mdsi.p2md_rstn || mdsi.en_n) begin
        mdsi.rxdata <= 0;
        mdsi.rxvalid <= 0;
        seqPtr <= 0;
      mdsi.localLtssmState = DETECT_QUIET;
    mdsi.finishedOs <= 0;
    end
    else begin
    mdsi.finishedOs <= 0;
        mdsi.rxvalid <= 1;
        case (mdsi.localLtssmState)
          
          POLLING_ACTIVE: begin
            mdsi.rxdata <= mdsi.storedSkpSequence[seqPtr];
            if(seqPtr >= (mdsi.seqPtrMax-1)) begin
              mdsi.FinishedOs();
              seqPtr <= 0;
            end
            else seqPtr <= seqPtr + 1;
          end
          
          POLLING_ACTIVE_START_TS1: begin
            mdsi.rxdata <= mdsi.storedTs1Sequence[seqPtr];
            if(seqPtr >= (mdsi.seqPtrMax-1)) begin
              mdsi.FinishedOs();
              seqPtr <= 0;
            end
            else seqPtr <= seqPtr + 1;
          end
          
          POLLING_CONFIG: begin
            mdsi.rxdata <= mdsi.storedTs2Sequence[seqPtr];
            if(seqPtr >= (mdsi.seqPtrMax-1)) begin
              mdsi.FinishedOs();
              seqPtr <= 0;
            end
            else seqPtr <= seqPtr + 1;
          end
            
            
          default: begin
            mdsi.rxdata <= 0;
            mdsi.UpdateCurrOsIfNeeded();
          end
        endcase
    end
  end
  
  assign mdsi.rxdatak = ((mdsi.rxdata == `PAD) || (mdsi.rxdata == `SKP) || (mdsi.rxdata == `COM));
  
endmodule
