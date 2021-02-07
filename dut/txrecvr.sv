
module txrecvr 
  (
    input clk,
    input reset_n,
    input[7:0] rxdata,
    input rxdatak,
    LTSSM_State curr_ltssm_state,
    output reg ts1_satisfied
    );

   parameter MAX_POSSIBLE_TS_LEN = 16;
  

    reg[15:0] setctr;
    reg[MAX_POSSIBLE_TS_LEN-1:0] rcvrq;
    reg[MAX_POSSIBLE_TS_LEN-1:0] rcvrq_ptr;
  
   initial begin
     rcvrq_ptr = 0;
   end  
  

endmodule