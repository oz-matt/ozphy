`include "ozdefs.sv"

interface phy2macdriveriface(
    input logic clk,
    input logic en_n,
    input LTSSM_State currLtssmState,
    input logic[39:0] ts1Bytes1Thru5,
    input logic[39:0] ts2Bytes1Thru5,
    output logic[7:0] rxdata,
    output logic rxdatak,
    output logic rxvalid
  );


  //Interface IO
  
  logic p2md_rstn;
  
  //Driver vars
  
  //logic[7:0] ists115[4:0];
  //logic[7:0] ists215[4:0];
  
  logic[7:0] storedSkpSequence[0:3];
  logic[7:0] storedTs1Sequence[0:15];
  logic[7:0] storedTs2Sequence[0:15];
  
  integer seqPtrMax;
  
  LTSSM_State localLtssmState;
  
  logic finishedOs;
  
  function void UpdateCurrOsIfNeeded();
    if (localLtssmState != currLtssmState) begin
        localLtssmState <= currLtssmState;
        case(currLtssmState)
      POLLING_ACTIVE: seqPtrMax = 4; // Listen for SKP sequence
        POLLING_ACTIVE_START_TS1: seqPtrMax = 16; // Listen for TS1
        POLLING_CONFIG: seqPtrMax = 16; //Listen for TS2
        CONFIG_LINKWIDTH_START: seqPtrMax = 16; //Listen for TS1
        CONFIG_LINKWIDTH_ACCEPT: seqPtrMax = 16; //Listen for TS1
        CONFIG_LANENUM_ACCEPT: seqPtrMax = 16; //Listen for TS1
        CONFIG_COMPLETE: seqPtrMax = 16; //Listen for TS1
        CONFIG_IDLE: seqPtrMax = 16; //Listen for TS1
        L0: seqPtrMax = 16; //Listen for TS1
          default: seqPtrMax = 1;
    endcase
      end 
  endfunction
  
  function void FinishedOs();
    finishedOs <= 1;
    UpdateCurrOsIfNeeded();
  endfunction
  
  function void InitOSets();
    storedSkpSequence[0] = `COM;
    storedSkpSequence[1] = `SKP;
    storedSkpSequence[2] = `SKP;
    storedSkpSequence[3] = `SKP;
    
    storedTs1Sequence[0] = `COM;
    storedTs1Sequence[6] = `TS1ID;
    storedTs1Sequence[7] = `TS1ID;
    storedTs1Sequence[8] = `TS1ID;
    storedTs1Sequence[9] = `TS1ID;
    storedTs1Sequence[10] = `TS1ID;
    storedTs1Sequence[11] = `TS1ID;
    storedTs1Sequence[12] = `TS1ID;
    storedTs1Sequence[13] = `TS1ID;
    storedTs1Sequence[14] = `TS1ID;
    storedTs1Sequence[15] = `TS1ID;
    
    storedTs2Sequence[0] = `COM;
    storedTs2Sequence[6] = `TS2ID;
    storedTs2Sequence[7] = `TS2ID;
    storedTs2Sequence[8] = `TS2ID;
    storedTs2Sequence[9] = `TS2ID;
    storedTs2Sequence[10] = `TS2ID;
    storedTs2Sequence[11] = `TS2ID;
    storedTs2Sequence[12] = `TS2ID;
    storedTs2Sequence[13] = `TS2ID;
    storedTs2Sequence[14] = `TS2ID;
    storedTs2Sequence[15] = `TS2ID;
  endfunction
  
    assign storedTs1Sequence[1] = ts1Bytes1Thru5[7:0];
    assign storedTs1Sequence[2] = ts1Bytes1Thru5[15:8];
    assign storedTs1Sequence[3] = ts1Bytes1Thru5[23:16];
    assign storedTs1Sequence[4] = ts1Bytes1Thru5[31:24];
    assign storedTs1Sequence[5] = ts1Bytes1Thru5[39:32];
    assign storedTs2Sequence[1] = ts2Bytes1Thru5[7:0];
    assign storedTs2Sequence[2] = ts2Bytes1Thru5[15:8];
    assign storedTs2Sequence[3] = ts2Bytes1Thru5[23:16];
    assign storedTs2Sequence[4] = ts2Bytes1Thru5[31:24];
    assign storedTs2Sequence[5] = ts2Bytes1Thru5[39:32];
  
  initial begin
    localLtssmState = DETECT_QUIET;
    finishedOs = 0;
    InitOSets();
  end
  
  modport drvrside (
    input clk,
    input p2md_rstn,
    input en_n,
    input currLtssmState,
    input storedTs1Sequence,
    input storedTs2Sequence,
    input storedSkpSequence,
    inout localLtssmState,
    inout finishedOs,
    input seqPtrMax,
    output rxdata,
    output rxdatak,
    output rxvalid,
    import UpdateCurrOsIfNeeded,
    import FinishedOs
  );
     
endinterface
  
