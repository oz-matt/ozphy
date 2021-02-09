`include "ozdefs.sv"
module rxdriver 
  (
    input clk,
    input reset_n,
    input LTSSM_State ost,
    input en_n,
    input[39:0]ts1,
    input[39:0]ts2,
    output reg[7:0] rxdata,
    output reg rxdatak,
    output reg rxvalid
    );
  
  wire[7:0] ts11thru5[0:4];
  wire[7:0] ts21thru5[0:4];
  
  assign ts11thru5[0] = ts1[7:0];
  assign ts11thru5[1] = ts1[15:8];
  assign ts11thru5[2] = ts1[23:16];
  assign ts11thru5[3] = ts1[31:24];
  assign ts11thru5[4] = ts1[39:32];
  assign ts21thru5[0] = ts2[7:0];
  assign ts21thru5[1] = ts2[15:8];
  assign ts21thru5[2] = ts2[23:16];
  assign ts21thru5[3] = ts2[31:24];
  assign ts21thru5[4] = ts2[39:32];
  
  reg[7:0] skposdata[0:3];
  reg[7:0] ts1os[0:15];
  reg[7:0] ts2os[0:15];
  integer bufctr, bufctrmax;
  
  LTSSM_State currost;
  
  reg finished_os;
  
  function void UpdateCurrOsIfNeeded();
    if (currost != ost) begin
        currost <= ost;
        case(ost)
      POLLING_ACTIVE: bufctrmax = 4; // Listen for SKP sequence
        POLLING_ACTIVE_START_TS1: bufctrmax = 16; // Listen for TS1
        POLLING_CONFIG: bufctrmax = 16; //Listen for TS2
          default: bufctrmax= 1;
    endcase
      end 
  endfunction
  
  function void FinishedOs();
    bufctr <= 0;
    finished_os <= 1;
    UpdateCurrOsIfNeeded();
  endfunction
  
  function void InitOSets();
    skposdata[0] = `COM;
    skposdata[1] = `SKP;
    skposdata[2] = `SKP;
    skposdata[3] = `SKP;
    
    ts1os[0] = `COM;
    ts1os[6] = `TS1ID;
    ts1os[7] = `TS1ID;
    ts1os[8] = `TS1ID;
    ts1os[9] = `TS1ID;
    ts1os[10] = `TS1ID;
    ts1os[11] = `TS1ID;
    ts1os[12] = `TS1ID;
    ts1os[13] = `TS1ID;
    ts1os[14] = `TS1ID;
    ts1os[15] = `TS1ID;
    
    ts2os[0] = `COM;
    ts2os[6] = `TS2ID;
    ts2os[7] = `TS2ID;
    ts2os[8] = `TS2ID;
    ts2os[9] = `TS2ID;
    ts2os[10] = `TS2ID;
    ts2os[11] = `TS2ID;
    ts2os[12] = `TS2ID;
    ts2os[13] = `TS2ID;
    ts2os[14] = `TS2ID;
    ts2os[15] = `TS2ID;
  endfunction
  
  initial begin
    bufctr = 0;
    currost = DETECT_QUIET;
    finished_os = 0;
    InitOSets();
  end

  always @(posedge clk or negedge reset_n) begin
    if(!reset_n || en_n) begin
        rxdata <= 0;
        rxvalid <= 0;
        bufctr <= 0;
      currost = DETECT_QUIET;
    finished_os <= 0;
    end
    else begin
    finished_os <= 0;
        rxvalid <= 1;
        case (currost)
          
          POLLING_ACTIVE: begin
            rxdata <= skposdata[bufctr];
            if(bufctr >= (bufctrmax-1)) FinishedOs();
            else bufctr <= bufctr + 1;
          end
          
          POLLING_ACTIVE_START_TS1: begin
            rxdata <= ts1os[bufctr];
            if(bufctr >= (bufctrmax-1)) FinishedOs();
            else bufctr <= bufctr + 1;
          end
          
          POLLING_CONFIG: begin
            rxdata <= ts2os[bufctr];
            if(bufctr >= (bufctrmax-1)) FinishedOs();
            else bufctr <= bufctr + 1;
          end
            
            
          default: begin
            rxdata <= 0;
            UpdateCurrOsIfNeeded();
          end
        endcase
    end
  end
  
  always_comb begin
    ts1os[1:5] = ts11thru5[0:4];
    ts2os[1:5] = ts21thru5[0:4];
  end
  
  assign rxdatak = ((rxdata == `PAD) || (rxdata == `SKP) || (rxdata == `COM));
  
endmodule
