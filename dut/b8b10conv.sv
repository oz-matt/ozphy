`include "ozdefs.sv"
`include "encode.v"
`include "decode.v"

module b8b10conv(
  input clk,
  input reset_n,
  input en_n,
  input[7:0] txdata,
  output logic [9:0] encoded_txdata
);
  logic disp ;
  logic[7:0] clkd_txdata;
  wire dispout;
  logic[9:0] gated_encoded_txdata;
  
  assign encoded_txdata = !en_n ? gated_encoded_txdata : 0;
  
  initial begin
    disp = 0;
    clkd_txdata = 0;
  end
  
  encode enc_i({0, clkd_txdata}, disp, gated_encoded_txdata, dispout);
  
  always @(posedge clk or negedge reset_n) begin
    if(!reset_n) begin
      disp = 0; 
      clkd_txdata = 0;
    end
    else begin 
      disp <= dispout;
      if($isunknown(txdata)) clkd_txdata <= 0;
      else clkd_txdata <= txdata;
    end
  end
  
endmodule

