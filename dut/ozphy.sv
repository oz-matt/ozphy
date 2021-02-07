`include "../env/pcie_basic_if.sv"
`include "rxdriver.sv"
`include "encode.v"
`include "decode.v"


  `define PAD 8'hF7;
  `define D2_0 8'h02;
  `define D4_0 8'h04;
  `define D8_0 8'h08;


module ozphy(pcie_basic_if pcie_phy_if, output wire[9:0] testout);

  genvar c, j, ir1;

  reg[15:0][2:0] l_rxstatus;
  reg[15:0] l_phystatus;
  reg[15:0] l_rxelecidle;
  wire[15:0] l_rxvalid;

  reg[15:0] l_txdetectrx;
  reg[15:0][2:0] l_powerdown;

  wire[7:0] l_rxdata[15:0];
  wire[15:0] l_rxdatak;

  reg[5:0] ostype[0:15];
  //TS1 ordered set vals
  reg[5:0] tctr[0:15];

  reg[7:0] t1[0:4][0:15];
  reg[7:0] t2[0:4][0:15];

  reg dispin;
  wire dispout;

  typedef enum logic [3:0] {DETECT_QUIET, DETECT_ACTIVE, POLLING_ACTIVE, POLLING_ACTIVE_START_TS1, POLLING_CONFIG, CONFIG_LINKWIDTH_START, CONFIG_LINKWIDTH_ACCEPT, CONFIG_LANENUM_ACCEPT, CONFIG_COMPLETE, CONFIG_IDLE, L0} LTSSM_State;

  LTSSM_State curr_ltssm_state[15:0];
      
  /*    
  generate
    for(genvar lv=0; lv<16; lv=lv+1) begin
      always_comb begin
   t1[0][lv] = `PAD;
    t1[1][lv] = `PAD;
    t1[2][lv] = `D4_0;
    t1[3][lv] = `D2_0;
    t1[4][lv] = `D8_0;
    
    t2[0][lv] = `PAD;
    t2[1][lv] = `PAD;
    t2[2][lv] = `D4_0;
    t2[3][lv] = `D2_0;
    t2[4][lv] = `D8_0;
      end
    end
  endgenerate
    */
  generate
    for(genvar cv=0; cv<16; cv=cv+1) begin
      rxdriver rxdrv(.clk(pcie_phy_if.clk),
        .reset_n(pcie_phy_if.reset_n[cv]),
        .ost(ostype[cv]),
        .en_n(l_rxelecidle[cv]),
        .ts1({t1[0][cv], t1[1][cv], t1[2][cv], t1[3][cv], t1[4][cv]}),
        .ts2({t2[0][cv], t2[1][cv], t2[2][cv], t2[3][cv], t2[4][cv]}),
        .rxdata({l_rxdata[cv][7],l_rxdata[cv][6],l_rxdata[cv][5],l_rxdata[cv][4],l_rxdata[cv][3],l_rxdata[cv][2],l_rxdata[cv][1],l_rxdata[cv][0] }),
       // .rxdata(l_rxdata[cv][7:0]),
        .rxdatak(l_rxdatak[cv]),
        .rxvalid(l_rxvalid[cv])
      );
    end
  endgenerate
  

  always @(posedge pcie_phy_if.clk or negedge pcie_phy_if.reset_n) begin
    if(!pcie_phy_if.reset_n) l_txdetectrx <= 0;
    else l_txdetectrx                     <= pcie_phy_if.txdetectrx;
  end


  always @(posedge pcie_phy_if.clk or negedge pcie_phy_if.reset_n) begin
    if(!pcie_phy_if.reset_n) begin
      l_powerdown[0]  <= 2;
      l_powerdown[1]  <= 2;
      l_powerdown[2]  <= 2;
      l_powerdown[3]  <= 2;
      l_powerdown[4]  <= 2;
      l_powerdown[5]  <= 2;
      l_powerdown[6]  <= 2;
      l_powerdown[7]  <= 2;
      l_powerdown[8]  <= 2;
      l_powerdown[9]  <= 2;
      l_powerdown[10] <= 2;
      l_powerdown[11] <= 2;
      l_powerdown[12] <= 2;
      l_powerdown[13] <= 2;
      l_powerdown[14] <= 2;
      l_powerdown[15] <= 2;
    end
    else begin
      l_powerdown[0]  <= pcie_phy_if.powerdown0;
      l_powerdown[1]  <= pcie_phy_if.powerdown1;
      l_powerdown[2]  <= pcie_phy_if.powerdown2;
      l_powerdown[3]  <= pcie_phy_if.powerdown3;
      l_powerdown[4]  <= pcie_phy_if.powerdown4;
      l_powerdown[5]  <= pcie_phy_if.powerdown5;
      l_powerdown[6]  <= pcie_phy_if.powerdown6;
      l_powerdown[7]  <= pcie_phy_if.powerdown7;
      l_powerdown[8]  <= pcie_phy_if.powerdown8;
      l_powerdown[9]  <= pcie_phy_if.powerdown9;
      l_powerdown[10] <= pcie_phy_if.powerdown10;
      l_powerdown[11] <= pcie_phy_if.powerdown11;
      l_powerdown[12] <= pcie_phy_if.powerdown12;
      l_powerdown[13] <= pcie_phy_if.powerdown13;
      l_powerdown[14] <= pcie_phy_if.powerdown14;
      l_powerdown[15] <= pcie_phy_if.powerdown15;
    end
  end

  generate
    for(c=0; c<16; c=c+1) begin
      always @(posedge pcie_phy_if.clk or negedge pcie_phy_if.reset_n) begin
        if(!pcie_phy_if.reset_n) begin
          curr_ltssm_state[c] <= DETECT_QUIET;
          l_rxstatus[c]       <= 0;
          l_phystatus[c]      <= 0;
          l_rxelecidle[c]     <= 1'b1;
          ostype[c] = 0;
          tctr[c]   = 0;
        end
        else begin
          case (curr_ltssm_state[c])

            DETECT_QUIET: begin
              if (l_txdetectrx[c] == 1'b1) begin
                l_rxstatus[c]       <= 3;
                l_phystatus[c]      <= 1'b1;
                curr_ltssm_state[c] <= DETECT_ACTIVE;
                $display("GO DETECT ACTIVE!!!");
              end
              else begin
                l_rxstatus[c]       <= 0;
                l_phystatus[c]      <= 0;
              end
            end

            DETECT_ACTIVE: begin
              if (l_powerdown[c] == 0) begin
                l_phystatus[c]      <= 1'b1;
                curr_ltssm_state[c] <= POLLING_ACTIVE;
                $display("GO POLLING ACTIVE!!!");
              end
              else begin
                l_rxstatus[c]       <= 0;
                l_phystatus[c]      <= 0;
              end
            end

            POLLING_ACTIVE: begin
              if(tctr[c] > 3) begin
                tctr[c]             <= 0;
                curr_ltssm_state[c] <= POLLING_ACTIVE_START_TS1;
              end
              else tctr[c]          <= tctr[c] + 1;

              l_rxelecidle[c] <= 1'b0;
              l_phystatus[c]  <= 0;
              ostype[c] = 1;
            end
            POLLING_ACTIVE_START_TS1: begin
              ostype[c] = 2;
            end

          endcase
        end
      end
    end
  endgenerate

  initial begin
    dispin      = 0;
    l_phystatus = 0;
  end

  generate
    for(j=0; j<16; j=j+1) begin
      initial begin
        curr_ltssm_state[j] = DETECT_QUIET;
        l_rxstatus[j]   <= 0;
        l_powerdown[j]  <= 2;
        l_rxelecidle[j] <= 1'b1;
        ostype[j]           = 0;
        tctr[j]             = 0;

        t1[4][j]            = `PAD;
        t1[3][j]            = `PAD;
        t1[2][j]            = `D4_0;
        t1[1][j]            = `D2_0;
        t1[0][j]            = `D8_0;

        t2[4][j]            = `PAD;
        t2[3][j]            = `PAD;
        t2[2][j]            = `D4_0;
        t2[1][j]            = `D2_0;
        t2[0][j]            = `D8_0;

      end
    end
  endgenerate

  always @(posedge pcie_phy_if.clk) begin
    dispin <= dispout;
  end


 
  assign pcie_phy_if.pclk            = pcie_phy_if.clk;
  assign pcie_phy_if.rxclk           = pcie_phy_if.clk;
  assign pcie_phy_if.rxstatus0[2:0]  = l_rxstatus[0];
  assign pcie_phy_if.rxstatus1[2:0]  = l_rxstatus[1];
  assign pcie_phy_if.rxstatus2[2:0]  = l_rxstatus[2];
  assign pcie_phy_if.rxstatus3[2:0]  = l_rxstatus[3];
  assign pcie_phy_if.rxstatus4[2:0]  = l_rxstatus[4];
  assign pcie_phy_if.rxstatus5[2:0]  = l_rxstatus[5];
  assign pcie_phy_if.rxstatus6[2:0]  = l_rxstatus[6];
  assign pcie_phy_if.rxstatus7[2:0]  = l_rxstatus[7];
  assign pcie_phy_if.rxstatus8[2:0]  = l_rxstatus[8];
  assign pcie_phy_if.rxstatus9[2:0]  = l_rxstatus[9];
  assign pcie_phy_if.rxstatus10[2:0] = l_rxstatus[10];
  assign pcie_phy_if.rxstatus11[2:0] = l_rxstatus[11];
  assign pcie_phy_if.rxstatus12[2:0] = l_rxstatus[12];
  assign pcie_phy_if.rxstatus13[2:0] = l_rxstatus[13];
  assign pcie_phy_if.rxstatus14[2:0] = l_rxstatus[14];
  assign pcie_phy_if.rxstatus15[2:0] = l_rxstatus[15];
  assign pcie_phy_if.rxelecidle      = l_rxelecidle;
  assign pcie_phy_if.rxvalid         = l_rxvalid;
  assign pcie_phy_if.lane0_txdata    = l_rxdata[0];
  assign pcie_phy_if.lane1_txdata    = l_rxdata[1];
  assign pcie_phy_if.lane2_txdata    = l_rxdata[2];
  assign pcie_phy_if.lane3_txdata    = l_rxdata[3];
  assign pcie_phy_if.lane4_txdata    = l_rxdata[4];
  assign pcie_phy_if.lane5_txdata    = l_rxdata[5];
  assign pcie_phy_if.lane6_txdata    = l_rxdata[6];
  assign pcie_phy_if.lane7_txdata    = l_rxdata[7];
  assign pcie_phy_if.lane8_txdata    = l_rxdata[8];
  assign pcie_phy_if.lane9_txdata    = l_rxdata[9];
  assign pcie_phy_if.lane10_txdata   = l_rxdata[10];
  assign pcie_phy_if.lane11_txdata   = l_rxdata[11];
  assign pcie_phy_if.lane12_txdata   = l_rxdata[12];
  assign pcie_phy_if.lane13_txdata   = l_rxdata[13];
  assign pcie_phy_if.lane14_txdata   = l_rxdata[14];
  assign pcie_phy_if.lane15_txdata   = l_rxdata[15];
  assign pcie_phy_if.lane0_txdatak   = l_rxdatak[0];
  assign pcie_phy_if.lane1_txdatak   = l_rxdatak[1];
  assign pcie_phy_if.lane2_txdatak   = l_rxdatak[2];
  assign pcie_phy_if.lane3_txdatak   = l_rxdatak[3];
  assign pcie_phy_if.lane4_txdatak   = l_rxdatak[4];
  assign pcie_phy_if.lane5_txdatak   = l_rxdatak[5];
  assign pcie_phy_if.lane6_txdatak   = l_rxdatak[6];
  assign pcie_phy_if.lane7_txdatak   = l_rxdatak[7];
  assign pcie_phy_if.lane8_txdatak   = l_rxdatak[8];
  assign pcie_phy_if.lane9_txdatak   = l_rxdatak[9];
  assign pcie_phy_if.lane10_txdatak  = l_rxdatak[10];
  assign pcie_phy_if.lane11_txdatak  = l_rxdatak[11];
  assign pcie_phy_if.lane12_txdatak  = l_rxdatak[12];
  assign pcie_phy_if.lane13_txdatak  = l_rxdatak[13];
  assign pcie_phy_if.lane14_txdatak  = l_rxdatak[14];
  assign pcie_phy_if.lane15_txdatak  = l_rxdatak[15];
  assign pcie_phy_if.phystatus       = l_phystatus;

  encode DUTE (pcie_phy_if.lane0_txdata[7:0], dispin, testout, dispout);

endmodule : ozphy

