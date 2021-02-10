`ifndef _LTSSMFXS_
`define _LTSSMFXS_

`include "ozdefs.sv"

virtual class Ltssm;

   parameter MAX_POSSIBLE_TS_LEN = 16;
  static reg[7:0] rcvrq[MAX_POSSIBLE_TS_LEN-1:0];

  static function int CheckIfPadTs1();
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
  
  static function int CheckIfPadTs2();
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
  
endclass

`endif
