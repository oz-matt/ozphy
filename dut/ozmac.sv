`include "../env/pcie_basic_if.sv"
`include "rxdriver.sv"
`include "txrecvr.sv"
`include "encode.v"
`include "decode.v"
`include "ozdefs.sv"
`include "phy2macdriveriface.sv"
`include "mac2phyrcvriface.sv"

module ozmac #(
  parameter N_LANES = 16, //number of pcie lanes
  parameter nts = 1024 //number of ts1s and ts2s required during polling phase of ltssm. Spec cites 1024
  ) (
  pcie_basic_if pcie_phy_if, 
    output wire[9:0] testout
    );

  genvar c, j, ir1;

  reg[15:0][2:0] l_rxstatus;
  reg[15:0] l_phystatus;
  reg[15:0] l_rxelecidle;
  wire[15:0] l_txelecidle;
  wire[15:0] l_rxvalid;

  reg[15:0] l_txdetectrx;
  reg[15:0][2:0] l_powerdown;

  wire[7:0] l_rxdata[15:0];
  wire[7:0] l_txdata[15:0];
  wire[15:0] l_rxdatak;
  wire[15:0] l_txdatak;

  //TS1 ordered set vals
  reg[5:0] tctr[0:15];

  reg[7:0] t1[0:4][0:15];
  reg[7:0] t2[0:4][0:15];

  reg dispin;
  wire dispout;
  
  wire[15:0] l_ts1ctr[15:0];
  wire[15:0] l_ts2ctr[15:0];

  LTSSM_State curr_ltssm_state[15:0];
  
  reg[15:0] phyHasDetectedReceiverOnThisLane;
      
  logic[15:0] acceptancectr[15:0];
  
  generate
    for(genvar lv=0; lv<N_LANES; lv=lv+1) begin : m2pri_gen
    mac2phyrcvriface m2pri
  (
    .clk(pcie_phy_if.clk),
    .reset_n(pcie_phy_if.reset_n[lv]),
    .txdata({l_txdata[lv][7],l_txdata[lv][6],l_txdata[lv][5],l_txdata[lv][4],l_txdata[lv][3],l_txdata[lv][2],l_txdata[lv][1],l_txdata[lv][0] }),
    .en_n(pcie_phy_if.txelecidle[lv]),
    .txdatak(l_txdatak[lv]),
    .curr_ltssm_state(curr_ltssm_state[lv]),
    .ts1ctr(l_ts1ctr[lv]),
    .ts2ctr(l_ts2ctr[lv])
    );
    end
    for(genvar dv=0; dv<N_LANES; dv=dv+1) begin : txrv
      txrecvr txrv(m2pri_gen[dv].m2pri.rcvrside);
    end
    for(genvar cv=0; cv<N_LANES; cv=cv+1) begin : p2mdi_gen
      phy2macdriveriface p2mdi(
        .clk(pcie_phy_if.clk),
        .currLtssmState(curr_ltssm_state[cv]),
        .en_n(l_rxelecidle[cv]),
        .ts1Bytes1Thru5({t1[0][cv], t1[1][cv], t1[2][cv], t1[3][cv], t1[4][cv]}),
        .ts2Bytes1Thru5({t2[0][cv], t2[1][cv], t2[2][cv], t2[3][cv], t2[4][cv]}),
        .rxdata({l_rxdata[cv][7],l_rxdata[cv][6],l_rxdata[cv][5],l_rxdata[cv][4],l_rxdata[cv][3],l_rxdata[cv][2],l_rxdata[cv][1],l_rxdata[cv][0] }),
        .rxdatak(l_rxdatak[cv]),
        .rxvalid(l_rxvalid[cv])
      );
    end
    for(genvar kv=0; kv<N_LANES; kv=kv+1) begin : rxdrv
      rxdriver rxdrv(p2mdi_gen[kv].p2mdi.drvrside);
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
          tctr[c]   = 0;
        phyHasDetectedReceiverOnThisLane[c] <= 0;
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
            end
            
            POLLING_ACTIVE_START_TS1: begin
              if(EnterPollingConfigCriteriaSatisfied(l_ts1ctr[c], l_txelecidle[c])) begin
                curr_ltssm_state[c] <= POLLING_CONFIG;
              end
            end
            
            POLLING_CONFIG: begin
              if(EnterConfigCriteriaSatisfied(l_ts2ctr[c], l_txelecidle[c])) begin
                curr_ltssm_state[c] <= CONFIG_LINKWIDTH_START;
                phyHasDetectedReceiverOnThisLane[c] = 1;
                m2pri_gen[c].m2pri.ResetTs1Ctr(); //Now when ts1 and ts2 counters contain anything, we know it is new ts1/2 pkts
                m2pri_gen[c].m2pri.ResetTs2Ctr();
              end
            end

            CONFIG_LINKWIDTH_START: begin
              if(m2pri_gen[c].m2pri.linkProposed && (m2pri_gen[c].m2pri.ts1ctr > 7)) begin
                t1[4][c] <= m2pri_gen[c].m2pri.ts1_linkn;
                curr_ltssm_state[c] <= CONFIG_LINKWIDTH_ACCEPT;
              end
            end

            CONFIG_LINKWIDTH_ACCEPT: begin
            if(m2pri_gen[c].m2pri.laneProposed && (m2pri_gen[c].m2pri.ts1ctr > 15)) begin
                t1[3][c] <= m2pri_gen[c].m2pri.ts1_lanen;
                curr_ltssm_state[c] <= CONFIG_LANENUM_ACCEPT;
                end
            end
            
            CONFIG_LANENUM_ACCEPT: begin
            if(m2pri_gen[c].m2pri.configComplete) begin
                t2[3][c] <= m2pri_gen[c].m2pri.ts1_lanen;
                t2[4][c] <= m2pri_gen[c].m2pri.ts1_linkn;
                curr_ltssm_state[c] <= CONFIG_COMPLETE;
                end
            end
            
            CONFIG_COMPLETE: begin
              if(l_txdata[c] == `COM) begin
                if(acceptancectr[c] > 7) begin
                  curr_ltssm_state[c] <= CONFIG_IDLE;
                end
                else if((m2pri_gen[c].m2pri.osNowInQueue == TS2) &&
                (m2pri_gen[c].m2pri.rcvrq[1] == t1[4][c]) && //link width
                (m2pri_gen[c].m2pri.rcvrq[1] != `PAD) && 
                (m2pri_gen[c].m2pri.rcvrq[2] == t1[3][c]) && //lane num
                (m2pri_gen[c].m2pri.rcvrq[2] != `PAD) && 
                ((m2pri_gen[c].m2pri.rcvrq[4] & 8'b01000000) == (t1[1][c] & 8'b01000000))) 
                  acceptancectr[c]++;
                else acceptancectr[c] <= 0;
              end
              
            end
            
            CONFIG_IDLE: begin
              m2pri_gen[c].m2pri.enIdleCtr <= 1;
              if(m2pri_gen[c].m2pri.idlectr > 7) begin
                m2pri_gen[c].m2pri.enIdleCtr <= 0;
                curr_ltssm_state[c] <= L0;
              end
            end
            
            L0: begin
            
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
  
  function int EnterPollingConfigCriteriaSatisfied(logic[15:0] ts1ctr, logic txelecidle);
    return ((ts1ctr >= 16) && !txelecidle);
  endfunction

  function int EnterConfigCriteriaSatisfied(logic[15:0] ts2ctr, logic txelecidle);
    return ((ts2ctr >= 16) && !txelecidle);
  endfunction

  generate
    for(j=0; j<16; j=j+1) begin
      initial begin
        curr_ltssm_state[j] = DETECT_QUIET;
        l_rxstatus[j]   <= 0;
        l_powerdown[j]  <= 2;
        l_rxelecidle[j] <= 1'b1;
        tctr[j]         = 0;
        acceptancectr[j] = 0;
        phyHasDetectedReceiverOnThisLane[j] = 0;

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
  assign l_txelecidle = pcie_phy_if.txelecidle;
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
  
  assign l_txdata[0] = pcie_phy_if.lane0_rxdata;
  assign l_txdata[1] = pcie_phy_if.lane1_rxdata;
  assign l_txdata[2] = pcie_phy_if.lane2_rxdata;
  assign l_txdata[3] = pcie_phy_if.lane3_rxdata;
  assign l_txdata[4] = pcie_phy_if.lane4_rxdata;
  assign l_txdata[5] = pcie_phy_if.lane5_rxdata;
  assign l_txdata[6] = pcie_phy_if.lane6_rxdata;
  assign l_txdata[7] = pcie_phy_if.lane7_rxdata;
  assign l_txdata[8] = pcie_phy_if.lane8_rxdata;
  assign l_txdata[9] = pcie_phy_if.lane9_rxdata;
  assign l_txdata[10] = pcie_phy_if.lane10_rxdata;
  assign l_txdata[11] = pcie_phy_if.lane11_rxdata;
  assign l_txdata[12] = pcie_phy_if.lane12_rxdata;
  assign l_txdata[13] = pcie_phy_if.lane13_rxdata;
  assign l_txdata[14] = pcie_phy_if.lane14_rxdata;
  assign l_txdata[15] = pcie_phy_if.lane15_rxdata;
  assign l_txdatak[0] = pcie_phy_if.lane0_rxdatak;
  assign l_txdatak[1] = pcie_phy_if.lane1_rxdatak;
  assign l_txdatak[2] = pcie_phy_if.lane2_rxdatak;
  assign l_txdatak[3] = pcie_phy_if.lane3_rxdatak;
  assign l_txdatak[4] = pcie_phy_if.lane4_rxdatak;
  assign l_txdatak[5] = pcie_phy_if.lane5_rxdatak;
  assign l_txdatak[6] = pcie_phy_if.lane6_rxdatak;
  assign l_txdatak[7] = pcie_phy_if.lane7_rxdatak;
  assign l_txdatak[8] = pcie_phy_if.lane8_rxdatak;
  assign l_txdatak[9] = pcie_phy_if.lane9_rxdatak;
  assign l_txdatak[10] = pcie_phy_if.lane10_rxdatak;
  assign l_txdatak[11] = pcie_phy_if.lane11_rxdatak;
  assign l_txdatak[12] = pcie_phy_if.lane12_rxdatak;
  assign l_txdatak[13] = pcie_phy_if.lane13_rxdatak;
  assign l_txdatak[14] = pcie_phy_if.lane14_rxdatak;
  assign l_txdatak[15] = pcie_phy_if.lane15_rxdatak;
  
  assign pcie_phy_if.phystatus       = l_phystatus;

  encode DUTE (pcie_phy_if.lane0_txdata[7:0], dispin, testout, dispout);

endmodule : ozphy

